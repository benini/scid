/*
* Copyright (C) 2014  Fulvio Benini

* This file is part of Scid (Shane's Chess Information Database).
*
* Scid is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation.
*
* Scid is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Scid.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "common.h"
#include "scidbase.h"
#include "fastgame.h"
#include "stored.h"
#include "math.h"
#include <algorithm>

void scidBaseT::Init() {
	idx = new Index;
	nb = new NameBase;
	game = new Game;
	for (int u = 0; u < UNDO_MAX; u++) undoGame[u] = NULL;
	undoMax = -1;
	undoIndex = -1;
	undoCurrent = -1;
	undoFull = false;
	gameNumber = -1;
	gameAltered = false;
	inUse = false;
	numGames = 0;
	memoryOnly = false;
	tree.moveCount = tree.totalCount = 0;
	treeCache = NULL;
	backupCache = NULL;
	fileName[0] = 0;
	fileMode = FMODE_Both;
	gfile = new GFile;
	bbuf = new ByteBuffer;
	bbuf->SetBufferSize (BBUF_SIZE);
	tbuf = new TextBuffer;
	tbuf->SetBufferSize (TBUF_SIZE);
	dbFilter = new Filter(0);
	treeFilter = new Filter(0);
	duplicates = NULL;
	validStats = false;
}

scidBaseT::~scidBaseT() {
	for (int u = 0; u < UNDO_MAX; u++) {
		if ( undoGame[u] != NULL ) delete undoGame[u];
	}
	if (duplicates != NULL) delete[] duplicates;
	if (idx != NULL) delete idx;
	if (nb != NULL) delete nb;
	if (game != NULL) delete game;
	if (treeCache != NULL) delete treeCache;
	if (backupCache != NULL) delete backupCache;
	if (gfile != NULL) delete gfile;
	if (bbuf != NULL) delete bbuf;
	if (tbuf != NULL) delete tbuf;
	if (dbFilter != NULL) delete dbFilter;
	if (treeFilter != NULL) delete treeFilter;
	for (uint i=0; i < filters_.size(); i++) {
		if (filters_[i].second != NULL) delete filters_[i].second;
	}
}

errorT scidBaseT::Close () {
	clear();
	game->Clear();
	errorT errIdx = idx->Close();
	nb->Clear();
	errorT errGFile = gfile->Close();
	inUse = false;
	fileName[0] = 0;
	gameNumber = -1;
	numGames = 0;
	gameAltered = false;
	strCopy (fileName, "<empty>");
	dbFilter->Init(0);
	treeFilter->Init(0);
	Filter* f;
	while ( (f = getFilter(2)) ) deleteFilter(f);
	return (errIdx != OK) ? errIdx : errGFile;
}

void scidBaseT::clear() {
	validStats = false;
	undoMax = undoIndex = undoCurrent = -1;
	undoFull = false;
	for (int i = 0; i < UNDO_MAX; i++) {
		if (undoGame[i] != NULL ) { delete undoGame[i]; undoGame[i] = NULL; }
	}
	if (duplicates != NULL) { delete[] duplicates; duplicates = NULL; }
	treeCache->Clear();
	backupCache->Clear();
	for (nameT nt = NAME_FIRST; nt <= NAME_LAST; nt++) nameFreq_[nt].resize(0);
}

errorT scidBaseT::clearCaches(uint gNum, bool writeFiles) {
	clear();
	if (fileMode != FMODE_Memory) removeFile (fileName, TREEFILE_SUFFIX);
	if (fileMode != FMODE_Memory && writeFiles) {
		gfile->FlushAll();
		calcNameFreq();
		errorT errNb = nb->WriteNameFile(nameFreq_);
		if (errNb != OK) return errNb;
		errorT errIdx = idx->WriteHeader();
		if (errIdx != OK) return errIdx;
	}
	idx->IndexUpdated(gNum);

	return OK;
}

errorT scidBaseT::Open (fileModeT mode,
                        const char* filename,
                        bool create,
                        SpellChecker* spell,
                        void (progressFn)(void*, unsigned int, unsigned int),
                        void* progressData) {
	if (inUse) return ERROR_FileInUse;
	if (filename == 0) filename = "";

	inUse = true;
	fileMode = mode;
	memoryOnly = (fileMode == FMODE_Memory);
	errorT err = OK;

	if (fileMode == FMODE_Memory) {
		idx->SetDescription ("In-memory database");
		gfile->CreateMemoryOnly();
	} else {
		if (create) {
			idx->SetDescription ("");
			err = idx->Create(filename);
			if (err == OK) err = idx->WriteHeader();
			if (err == OK) err = nb->Create(filename);
			if (err == OK) err = gfile->Create (filename, FMODE_Both);
			if (err == OK) {
				// Ensure an old treefile is not still around:
				removeFile (filename, TREEFILE_SUFFIX);
			}
		} else {
			err = idx->Open(filename, fileMode);
			if (err == OK) err = nb->ReadEntireFile(filename);
			if (err == OK) nb->recalcEstimatedRatings (spell);
			if (err == OK) err = gfile->Open (filename, fileMode);
			if (err == OK) err = idx->ReadEntireFile (nb, progressFn, progressData);
		}
	}
	if (err != OK && err != ERROR_NameDataLoss) {
		idx->Close();
		nb->Clear();
		gfile->Close();
		inUse = false;
		return err;
	}

	numGames = idx->GetNumGames();
	strCopy (fileName, filename);
	gameNumber = -1;

	// Initialise the filters: all games match at move 1 by default.
	Filter* f; int i_filters=0;
	while ( (f = getFilter(i_filters++)) ) f->Init(numGames);

	if (treeCache == NULL) {
		// TreeCache size for each open database:
		const uint SCID_TreeCacheSize = 1000;
		// Secondary (memory only) TreeCache size:
		const uint SCID_BackupCacheSize = 100;
		treeCache = new TreeCache;
		treeCache->SetCacheSize (SCID_TreeCacheSize);
		backupCache = new TreeCache;
		backupCache->SetCacheSize (SCID_BackupCacheSize);
		backupCache->SetPolicy (TREECACHE_Oldest);
	}

	return err;
}

errorT scidBaseT::addGame(scidBaseT* sourceBase, uint gNum) {
	errorT errAddGame = addGame_(sourceBase, gNum);
	errorT errClear = clearCaches(numGames -1);
	return (errAddGame == OK) ? errClear : errAddGame;
}

errorT scidBaseT::addGames(scidBaseT* sourceBase, Filter* filter,
                           bool (progressFn)(void*, unsigned int, unsigned int), void* progressData) {
	errorT err = OK;
	uint iProgress = 0;
	uint totGames = filter->Count();
	Filter* f; int i_filters=0;
	while ( (f = getFilter(i_filters++)) ) f->SetCapacity(numGames + totGames);
	for (uint gNum = 0;gNum < sourceBase->numGames; gNum++) {
		if (filter->Get(gNum) == 0) continue;
		err = addGame_(sourceBase, gNum);
		if (err != OK) break;
		if (iProgress++ % 10000 == 0) {
			bool interrupt = progressFn(progressData, iProgress, totGames);
			if (interrupt) break;
		}
	}
	errorT errClear = clearCaches();
	return (err == OK) ? errClear : err;
}

errorT scidBaseT::addGame_(scidBaseT* sourceBase, uint gNum) {
	IndexEntry* srcIe = sourceBase->idx->FetchEntry (gNum);
	errorT err = sourceBase->gfile->ReadGame(sourceBase->bbuf, srcIe->GetOffset(), srcIe->GetLength());
	if (err != OK) return err;

	IndexEntry iE = *srcIe;
	if (iE.SetWhiteName(nb, srcIe->GetWhiteName(sourceBase->nb)) != OK)
		return ERROR_NameBaseFull;
	if (iE.SetBlackName(nb, srcIe->GetBlackName(sourceBase->nb)) != OK)
		return ERROR_NameBaseFull;
	if (iE.SetEventName(nb, srcIe->GetEventName(sourceBase->nb)) != OK)
		return ERROR_NameBaseFull;
	if (iE.SetSiteName(nb, srcIe->GetSiteName(sourceBase->nb)) != OK)
		return ERROR_NameBaseFull;
	if (iE.SetRoundName(nb, srcIe->GetRoundName(sourceBase->nb)) != OK)
		return ERROR_NameBaseFull;

	return saveGame_(&iE, sourceBase->bbuf);
}

errorT scidBaseT::saveGame(Game* game, bool clearCache, int idx) {
	if (fileMode == FMODE_ReadOnly) return ERROR_FileReadOnly;

	IndexEntry iE;
	iE.Init();
	errorT err = game->Encode (bbuf, &iE);
	if (err != OK) return err;

	if (iE.SetWhiteName(nb, game->GetWhiteStr()) != OK) return ERROR_NameBaseFull;
	if (iE.SetBlackName(nb, game->GetBlackStr()) != OK) return ERROR_NameBaseFull;
	if (iE.SetEventName(nb, game->GetEventStr()) != OK) return ERROR_NameBaseFull;
	if (iE.SetSiteName(nb, game->GetSiteStr()) != OK) return ERROR_NameBaseFull;
	if (iE.SetRoundName(nb, game->GetRoundStr()) != OK) return ERROR_NameBaseFull;

	errorT errSave = saveGame_(&iE, bbuf, idx);
	errorT errClear = OK;
	if (clearCache) {
		if (idx < 0) idx = static_cast<int> (numGames -1);
		errClear = clearCaches(idx);
	}
	return (errSave == OK) ? errClear : errSave;
}

errorT scidBaseT::saveGame_(IndexEntry* iE, ByteBuffer* bytebuf, int oldIdx) {
	// Now try writing the game to the gfile:
	uint offset = 0;
	errorT errGFile = gfile->AddGame (bytebuf, &offset);
	if (errGFile != OK) return errGFile;
	iE->SetOffset (offset);
	iE->SetLength (bytebuf->GetByteCount());

	nb->AddElo(iE->GetWhite(), iE->GetWhiteElo());
	nb->AddElo(iE->GetBlack(), iE->GetBlackElo());

	// Last of all, we write the new idxEntry, but NOT the index header
	// or the name file, since there might be more games saved yet and
	// writing them now would then be a waste of time.
	if (oldIdx >= 0) {
		IndexEntry* ieOld = idx->FetchEntry(oldIdx);
		// Remember previous user-settable flags:
		for (uint flag = IDX_FLAG_DELETE; flag < IDX_NUM_FLAGS; flag++) {
			iE->SetFlag(1 << flag, ieOld->GetFlag(1 << flag));
		}
		errorT err = idx->WriteEntries (iE, oldIdx);
		if (err != OK) return err;
	} else {
		errorT err = idx->AddGame(iE);
		if (err != OK) return err;
		numGames = idx->GetNumGames();

		// Add the new game to filters
		Filter* f; int i_filters=0;
		while ( (f = getFilter(i_filters++)) ) f->Append(f->isWhole() ? 1 : 0);
	}

	return OK;
}

std::string scidBaseT::newFilter() {
	std::string newname = filters_.size() ? filters_.back().first : "a";
	if (newname[0] == 'z') newname = 'a' + newname;
	else newname = ++(newname[0]) + newname.substr(1);
	filters_.push_back(std::make_pair(newname, new Filter(numGames)));
	return newname;
}

void scidBaseT::deleteFilter(Filter* filter) {
	for (uint i=0; i < filters_.size(); i++) {
		if (filters_[i].second == filter) {
			delete filters_[i].second;
			filters_.erase(filters_.begin() + i);
			break;
		}
	}
}

Filter* scidBaseT::getFilter (const char* filterName) {
	Filter* res = 0;
	Filter* mask = 0;
	std::string name = filterName;
	int split = 0;
	if (filterName[split++] == '+') {
		while (filterName[split] != '+') {
			if (filterName[split++] == 0) return 0; // Malformed filterName
		}
		name = name.substr(1, split -1);
		mask = getFilter(filterName + split + 1);
	}

	if (name == "dbfilter") res = dbFilter;
	else if (name == "tree") res = treeFilter;
	else {
		for (uint i=0; i < filters_.size(); i++) {
			if (filters_[i].first == name) {
				res = filters_[i].second;
				break;
			}
		}
	}
	if (res) res->PositionMask(mask);
	return res;
}

void scidBaseT::calcNameFreq () {
	for (nameT n = NAME_PLAYER; n < NUM_NAME_TYPES; n++) {
		nameFreq_[n].clear();
		nameFreq_[n].resize(nb->GetNumNames(n), 0);
	}

	for (size_t i=0; i < idx->GetNumGames(); i++) {
		IndexEntry* ie = idx->FetchEntry (i);
		nameFreq_[NAME_PLAYER][ie->GetWhite()] += 1;
		nameFreq_[NAME_PLAYER][ie->GetBlack()] += 1;
		nameFreq_[NAME_EVENT][ie->GetEvent()] += 1;
		nameFreq_[NAME_SITE][ie->GetSite()] += 1;
		nameFreq_[NAME_ROUND][ie->GetRound()] += 1;
	}
}

scidBaseT::Stats* scidBaseT::getStats() {
	if (validStats) return &stats;

	uint i;
	// Zero out all stats:
	for (i = 0; i < IDX_NUM_FLAGS; i++) { stats.flagCount[i] = 0; }
	stats.nRatings = 0;
	stats.sumRatings = 0;
	stats.minRating = 0;
	stats.maxRating = 0;
	stats.minDate = ZERO_DATE;
	stats.maxDate = ZERO_DATE;
	stats.nYears = 0;
	stats.sumYears = 0;
	for (i=0; i < NUM_RESULT_TYPES; i++) {
		stats.nResults[i] = 0;
	}
	for (i=0; i < 1; i++) {
		stats.ecoCount0[i].count = 0;
		stats.ecoCount0[i].results[RESULT_White] = 0;
		stats.ecoCount0[i].results[RESULT_Black] = 0;
		stats.ecoCount0[i].results[RESULT_Draw] = 0;
		stats.ecoCount0[i].results[RESULT_None] = 0;
	}
	for (i=0; i < 5; i++) {
		stats.ecoCount1[i].count = 0;
		stats.ecoCount1[i].results[RESULT_White] = 0;
		stats.ecoCount1[i].results[RESULT_Black] = 0;
		stats.ecoCount1[i].results[RESULT_Draw] = 0;
		stats.ecoCount1[i].results[RESULT_None] = 0;
	}
	for (i=0; i < 50; i++) {
		stats.ecoCount2[i].count = 0;
		stats.ecoCount2[i].results[RESULT_White] = 0;
		stats.ecoCount2[i].results[RESULT_Black] = 0;
		stats.ecoCount2[i].results[RESULT_Draw] = 0;
		stats.ecoCount2[i].results[RESULT_None] = 0;
	}
	for (i=0; i < 500; i++) {
		stats.ecoCount3[i].count = 0;
		stats.ecoCount3[i].results[RESULT_White] = 0;
		stats.ecoCount3[i].results[RESULT_Black] = 0;
		stats.ecoCount3[i].results[RESULT_Draw] = 0;
		stats.ecoCount3[i].results[RESULT_None] = 0;
	}
	for (i=0; i < 500*26; i++) {
		stats.ecoCount4[i].count = 0;
		stats.ecoCount4[i].results[RESULT_White] = 0;
		stats.ecoCount4[i].results[RESULT_Black] = 0;
		stats.ecoCount4[i].results[RESULT_Draw] = 0;
		stats.ecoCount4[i].results[RESULT_None] = 0;
	}
	// Read stats from index entry of each game:
	for (uint gnum=0; gnum < numGames; gnum++) {
		IndexEntry * ie = idx->FetchEntry (gnum);
		stats.nResults[ie->GetResult()]++;
		eloT elo = ie->GetWhiteElo();
		if (elo > 0) {
			stats.nRatings++;
			stats.sumRatings += elo;
			if (stats.minRating == 0) { stats.minRating = elo; }
			if (elo < stats.minRating) { stats.minRating = elo; }
			if (elo > stats.maxRating) { stats.maxRating = elo; }
			nb->AddElo (ie->GetWhite(), elo);
		}
		elo = ie->GetBlackElo();
		if (elo > 0) {
			stats.nRatings++;
			stats.sumRatings += elo;
			if (stats.minRating == 0) { stats.minRating = elo; }
			if (elo < stats.minRating) { stats.minRating = elo; }
			if (elo > stats.maxRating) { stats.maxRating = elo; }
			nb->AddElo (ie->GetBlack(), elo);
		}
		dateT date = ie->GetDate();
		if (gnum == 0) {
			stats.maxDate = stats.minDate = date;
		}
		if (date_GetYear(date) > 0) {
			if (date < stats.minDate) { stats.minDate = date; }
			if (date > stats.maxDate) { stats.maxDate = date; }
			stats.nYears++;
			stats.sumYears += date_GetYear (date);
			nb->AddDate (ie->GetWhite(), date);
			nb->AddDate (ie->GetBlack(), date);
		}

		for (uint flag = 0; flag < IDX_NUM_FLAGS; flag++) {
			bool value = ie->GetFlag (1 << flag);
			if (value) {
				stats.flagCount[flag]++;
			}
		}

		ecoT eco = ie->GetEcoCode();
		ecoStringT ecoStr;
		eco_ToExtendedString (eco, ecoStr);
		uint length = strLength (ecoStr);
		resultT result = ie->GetResult();
		if (length >= 3) {
			uint code = 0;
			stats.ecoCount0[code].count++;
			stats.ecoCount0[code].results[result]++;
			code = ecoStr[0] - 'A';
			stats.ecoCount1[code].count++;
			stats.ecoCount1[code].results[result]++;
			code = (code * 10) + (ecoStr[1] - '0');
			stats.ecoCount2[code].count++;
			stats.ecoCount2[code].results[result]++;
			code = (code * 10) + (ecoStr[2] - '0');
			stats.ecoCount3[code].count++;
			stats.ecoCount3[code].results[result]++;
			if (length >= 4) {
				code = (code * 26) + (ecoStr[3] - 'a');
				stats.ecoCount4[code].count++;
				stats.ecoCount4[code].results[result]++;
			}
		}
	}

	validStats = true;
	return &stats;
}

double scidBaseT::TreeStat::expVect_[1600];

scidBaseT::TreeStat::TreeStat()
: toMove(NOCOLOR), resultW(0), resultD(0), resultB(0), exp(0), ngames(0), nexp(0)
{
	if (TreeStat::expVect_[0] == 0) {
		for (int i=-800; i < 800; i++) TreeStat::expVect_[i+800] = 1/(1 + pow(10, i/400.0));
	}
}

std::vector<scidBaseT::TreeStat> scidBaseT::getTreeStat(Filter* filter) {
	std::vector<FullMove> v1;
	v1.reserve(50);
	std::vector<scidBaseT::TreeStat> v2;
	v2.reserve(50);
	for(uint gnum=0; gnum < numGames; gnum++) {
		if(filter->Get(gnum) == 0) continue;
		uint ply = filter->Get(gnum) - 1;
		IndexEntry* ie = idx->FetchEntry (gnum);
		FullMove move = StoredLine::getMove(ie->GetStoredLineCode(), ply);
		if (move.isNull()) {
			move = gfile->ReadGame(ie->GetOffset(), ie->GetLength()).getMove(ply);
		}
		uint i=0;
		while (i < v1.size() && v1[i] != move) i++;
		if (i == v1.size()) {
			v1.push_back(move);
			v2.push_back(scidBaseT::TreeStat());
		}
		v2[i].add(ie->GetResult(), ie->GetWhiteElo(nb), ie->GetBlackElo(nb));
	}

	for (uint i=0; i < v1.size(); i++) {
		v2[i].SAN = (v1[i].isNull()) ? "[end]" : v1[i].getSAN(&(v2[i].toMove));
	}

	std::sort(v2.begin(), v2.end());
	return v2;
}

errorT scidBaseT::getCompactStat(uint* n_deleted,
                                 uint* n_unused,
                                 uint* n_sparse,
                                 uint* n_badNameId) {
	std::vector<uint> nbFreq[NUM_NAME_TYPES];
	for (nameT n = NAME_PLAYER; n < NUM_NAME_TYPES; n++) {
		nbFreq[n].resize(nb->GetNumNames(n), 0);
	}

	uint last_offset = 0;
	*n_sparse = 0;
	*n_deleted = 0;
	for (size_t i=0; i < idx->GetNumGames(); i++) {
		IndexEntry* ie = idx->FetchEntry (i);
		if (ie->GetDeleteFlag()) { *n_deleted += 1; continue; }

		uint offset = ie->GetOffset();
		if (offset < last_offset) *n_sparse += 1;
		last_offset = offset;

		nbFreq[NAME_PLAYER][ie->GetWhite()] += 1;
		nbFreq[NAME_PLAYER][ie->GetBlack()] += 1;
		nbFreq[NAME_EVENT][ie->GetEvent()] += 1;
		nbFreq[NAME_SITE][ie->GetSite()] += 1;
		nbFreq[NAME_ROUND][ie->GetRound()] += 1;
	}

	*n_unused = 0;
	for (nameT n = NAME_PLAYER; n < NUM_NAME_TYPES; n++) {
		*n_unused += std::count(nbFreq[n].begin(), nbFreq[n].end(), 0);
	}

	*n_badNameId = idx->GetBadNameIdCount();
	return OK;
}

errorT scidBaseT::compact(SpellChecker* spellChk,
                          bool (progressFn)(void*, unsigned int, unsigned int),
                          void* progressData) {

	if (fileMode != FMODE_Both) return ERROR_FileMode;

	//1) Create the list of games to be copied
	typedef std::vector< std::pair<byte, size_t> > sort_t;
	sort_t sort;
	uint n_deleted = 0;
	for (size_t i=0; i < idx->GetNumGames(); i++) {
		IndexEntry* ie = idx->FetchEntry (i);
		if (ie->GetDeleteFlag()) { n_deleted++; continue; }
		uint stLine = ie->GetStoredLineCode();
		sort.push_back(std::make_pair(stLine, i));
	}
	std::stable_sort(sort.begin(), sort.end());

	//2) Create a new temporary database
	std::string filename = fileName;
	std::string tmpfile = filename + "__TEMP__";
	scidBaseT tmp;
	errorT err_Create = tmp.Open(FMODE_Both, tmpfile.c_str());
	if (err_Create != OK) return err_Create;

	//3) Copy the Index Header
	tmp.idx->SetType (idx->GetType());
	tmp.idx->SetDescription (idx->GetDescription());
	tmp.idx->SetAutoLoad (idx->GetAutoLoad());
	char newDesc[ CUSTOM_FLAG_DESC_LENGTH + 1 ];
	for (byte b = 1 ; b <= CUSTOM_FLAG_MAX ; b++ ) {
		idx->GetCustomFlagDesc (newDesc, b);
		tmp.idx->SetCustomFlagDesc (newDesc, b);
	}

	//4) Copy the games
	uint iProgress = 0;
	bool err_UserCancel = false;
	errorT err_AddGame = OK;
	for (sort_t::iterator it = sort.begin(); it != sort.end(); it++) {
		err_AddGame = tmp.addGame_(this, (*it).second);
		if (err_AddGame != OK) break;
		if (iProgress++ % 10000 == 0) {
			bool interrupt = progressFn(progressData, iProgress, sort.size());
			if (interrupt) {
				err_UserCancel = true;
				break;
			}
		}
	}

	//5) Finalize the new database
	tmp.calcNameFreq();
	errorT err_NbWrite = tmp.nb->WriteNameFile(tmp.nameFreq_);
	errorT err_Close = tmp.Close();

	//6) Error: cleanup and report
	if (err_NbWrite != OK || err_Close != OK || err_UserCancel || err_AddGame != OK) {
		removeFile (tmpfile.c_str(), INDEX_SUFFIX);
		removeFile (tmpfile.c_str(), NAMEBASE_SUFFIX);
		removeFile (tmpfile.c_str(), GFILE_SUFFIX);
		if (err_UserCancel) return ERROR_UserCancel;
		return (err_Close != OK) ? err_Close : ((err_NbWrite != OK) ? err_NbWrite : err_AddGame);
	}

	//7) Success: Reset the filters and replace the old database
	std::vector<std::string> filters(filters_.size());
	for (size_t i = 0; i < filters_.size(); i++) filters[i] = filters_[i].first;
	Close();
	removeFile (filename.c_str(), INDEX_SUFFIX);
	removeFile (filename.c_str(), NAMEBASE_SUFFIX);
	removeFile (filename.c_str(), GFILE_SUFFIX);
	renameFile (tmpfile.c_str(), filename.c_str(), INDEX_SUFFIX);
	renameFile (tmpfile.c_str(), filename.c_str(), NAMEBASE_SUFFIX);
	renameFile (tmpfile.c_str(), filename.c_str(), GFILE_SUFFIX);
	Open(FMODE_Both, filename.c_str(), false, spellChk);
	for (size_t i = 0; i <filters.size(); i++) {
		filters_.push_back(std::make_pair(filters[i], new Filter(numGames)));
	}
	return OK;
}
