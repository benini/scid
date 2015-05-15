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
#include "stored.h"
#include "spellchk.h"
#include <algorithm>
#include <math.h>

void scidBaseT::Init() {
	idx = new Index;
	nb = new NameBase;
	game = new Game;
	gameNumber = -1;
	gameAltered = false;
	inUse = false;
	tree.moveCount = tree.totalCount = 0;
	treeCache = NULL;
	fileMode = FMODE_Both;
	gfile = new GFile;
	bbuf = new ByteBuffer(BBUF_SIZE);
	tbuf = new TextBuffer;
	tbuf->SetBufferSize (TBUF_SIZE);
	dbFilter = new Filter(0);
	treeFilter = new Filter(0);
	duplicates = NULL;
	stats_ = NULL;
	validStats_ = false;
}

scidBaseT::~scidBaseT() {
	if (duplicates != NULL) delete[] duplicates;
	if (idx != NULL) delete idx;
	if (nb != NULL) delete nb;
	if (game != NULL) delete game;
	if (treeCache != NULL) delete treeCache;
	if (gfile != NULL) delete gfile;
	if (bbuf != NULL) delete bbuf;
	if (tbuf != NULL) delete tbuf;
	if (stats_ != NULL) delete stats_;
	if (dbFilter != NULL) delete dbFilter;
	if (treeFilter != NULL) delete treeFilter;
	for (uint i=0; i < filters_.size(); i++) {
		if (filters_[i].second != NULL) delete filters_[i].second;
	}
}

errorT scidBaseT::Close () {
	errorT errIdx = idx->Close();
	errorT errGFile = gfile->Close();
	//TODO:
	//if (errIdx != OK || errGFile != OK) do not close the database:
	//maybe the user can try something to avoid the data loss
	nb->Clear();
	clear();
	game->Clear();
	inUse = false;
	fileName_ = "<empty>";
	gameNumber = -1;
	gameAltered = false;
	dbFilter->Init(0);
	treeFilter->Init(0);
	for (size_t i=0, n = filters_.size(); i < n; i++) delete filters_[i].second;
	filters_.clear();
	return (errIdx != OK) ? errIdx : errGFile;
}

void scidBaseT::clear() {
	validStats_ = false;
	if (duplicates != NULL) { delete[] duplicates; duplicates = NULL; }
	if (treeCache != NULL) treeCache->Clear();
	for (nameT nt = NAME_FIRST; nt <= NAME_LAST; nt++) nameFreq_[nt].resize(0);
}

errorT scidBaseT::clearCaches(gamenumT gNum, bool writeFiles) {
	clear();
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
                        const Progress& progress) {
	if (inUse) return ERROR_FileInUse;
	if (filename == 0) filename = "";

	inUse = true;
	fileMode = mode;
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
		} else {
			err = idx->Open(filename, fileMode);
			if (err == OK) err = nb->ReadEntireFile(filename);
			if (err == OK && spell != 0 && spell->HasEloData()) {
				for (idNumberT id=0, n = nb->GetNumNames(NAME_PLAYER); id < n; id++) {
					if ((id % 1000) == 0) progress.report(id +1, n);
					if (nb->GetElo(id) != 0) continue;
					const char* name = nb->GetName (NAME_PLAYER, id);
					if (! strIsSurnameOnly (name)) {
						const char* text = spell->GetCommentExact (name);
						if (text != NULL) {
							nb->AddElo (id, SpellChecker::GetPeakRating (text));
						}
					}
				}
			}
			if (err == OK) err = gfile->Open (filename, fileMode);
			if (err == OK) err = idx->ReadEntireFile (nb, progress);
		}
	}
	if (err != OK && err != ERROR_NameDataLoss) {
		idx->Close();
		nb->Clear();
		gfile->Close();
		inUse = false;
		return err;
	}

	fileName_ = filename;
	gameNumber = -1;

	// Initialise the filters: all games match at move 1 by default.
	Filter* f; int i_filters=0;
	while ( (f = fetchFilter(i_filters++)) ) f->Init(numGames());

	// Ensure an old treefile is not still around:
	std::remove((fileName_ + ".stc").c_str());
	if (treeCache == NULL) {
		// TreeCache size for each open database:
		const uint SCID_TreeCacheSize = 1000;
		treeCache = new TreeCache;
		treeCache->SetCacheSize (SCID_TreeCacheSize);
	}

	return err;
}

errorT scidBaseT::addGame(scidBaseT* sourceBase, uint gNum) {
	if (fileMode == FMODE_ReadOnly) return ERROR_FileReadOnly;
	errorT err = addGame_(sourceBase, gNum);
	if (err != OK) return err;
	ASSERT(numGames() > 0);
	return clearCaches(numGames() -1);
}

errorT scidBaseT::addGames(scidBaseT* sourceBase, const HFilter& filter, const Progress& progress) {
	ASSERT(*filter);
	if (fileMode == FMODE_ReadOnly) return ERROR_FileReadOnly;
	errorT err = OK;
	uint iProgress = 0;
	uint totGames = filter.count();
	Filter* f; int i_filters=0;
	while ( (f = fetchFilter(i_filters++)) ) f->SetCapacity(numGames() + totGames);
	for (gamenumT gNum = 0, n = sourceBase->numGames(); gNum < n; gNum++) {
		if (filter.get(gNum) == 0) continue;
		err = addGame_(sourceBase, gNum);
		if (err != OK) break;
		if (iProgress++ % 10000 == 0) {
			if (!progress.report(iProgress, totGames)) break;
		}
	}
	errorT errClear = clearCaches();
	return (err == OK) ? errClear : err;
}

errorT scidBaseT::addGame_(scidBaseT* sourceBase, uint gNum) {
	const IndexEntry* srcIe = sourceBase->getIndexEntry(gNum);
	errorT err = sourceBase->gfile->ReadGame(sourceBase->bbuf, srcIe->GetOffset(), srcIe->GetLength());
	if (err != OK) return err;

	IndexEntry iE = *srcIe;
	if ((err = iE.SetWhiteName(nb, srcIe->GetWhiteName(sourceBase->nb))) != OK) return err;
	if ((err = iE.SetBlackName(nb, srcIe->GetBlackName(sourceBase->nb))) != OK) return err;
	if ((err = iE.SetEventName(nb, srcIe->GetEventName(sourceBase->nb))) != OK) return err;
	if ((err = iE.SetSiteName (nb, srcIe->GetSiteName(sourceBase->nb) )) != OK) return err;
	if ((err = iE.SetRoundName(nb, srcIe->GetRoundName(sourceBase->nb))) != OK) return err;

	return saveGame_(&iE, sourceBase->bbuf);
}

errorT scidBaseT::saveGame(Game* game, bool clearCache, gamenumT gnum) {
	if (fileMode == FMODE_ReadOnly) return ERROR_FileReadOnly;

	IndexEntry iE;
	iE.Init();
	errorT err = game->Encode (bbuf, &iE);
	if (err != OK) return err;

	if ((err = iE.SetWhiteName(nb, game->GetWhiteStr())) != OK) return err;
	if ((err = iE.SetBlackName(nb, game->GetBlackStr())) != OK) return err;
	if ((err = iE.SetEventName(nb, game->GetEventStr())) != OK) return err;
	if ((err = iE.SetSiteName (nb, game->GetSiteStr() )) != OK) return err;
	if ((err = iE.SetRoundName(nb, game->GetRoundStr())) != OK) return err;

	errorT errSave = saveGame_(&iE, bbuf, gnum);
	if (errSave == OK && clearCache) {
		if (gnum >= numGames()) {
			ASSERT(numGames() > 0);
			gnum = numGames() -1;
		}
		return clearCaches(gnum);
	}
	return errSave;
}

errorT scidBaseT::saveGame_(IndexEntry* iE, ByteBuffer* bytebuf, gamenumT oldIdx) {
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
	if (oldIdx < numGames()) {
		const IndexEntry* ieOld = getIndexEntry(oldIdx);
		// Remember previous user-settable flags:
		for (uint flag = IDX_FLAG_DELETE; flag < IDX_NUM_FLAGS; flag++) {
			iE->SetFlag(1 << flag, ieOld->GetFlag(1 << flag));
		}
		errorT err = idx->WriteEntries (iE, oldIdx);
		if (err != OK) return err;
	} else {
		errorT err = idx->AddGame(iE);
		if (err != OK) return err;

		// Add the new game to filters
		Filter* f; int i_filters=0;
		while ( (f = fetchFilter(i_filters++)) ) f->Append(f->isWhole() ? 1 : 0);
	}

	return OK;
}

std::string scidBaseT::newFilter() {
	std::string newname = (filters_.size() == 0) ? "a_" : filters_.back().first;
	if (newname[0] == 'z') newname = 'a' + newname;
	else newname = ++(newname[0]) + newname.substr(1);
	filters_.push_back(std::make_pair(newname, new Filter(numGames())));
	return newname;
}

void scidBaseT::deleteFilter(const char* filterName) {
	for (uint i=0; i < filters_.size(); i++) {
		if (filters_[i].first == filterName) {
			delete filters_[i].second;
			filters_.erase(filters_.begin() + i);
			break;
		}
	}
}

HFilter scidBaseT::getFilter (const char* filterName) {
	const Filter* mask = 0;
	std::string name = filterName;
	int split = 0;
	if (filterName[split++] == '+') {
		while (filterName[split] != '+') {
			if (filterName[split++] == 0) return HFilter(); // Malformed filterName
		}
		name = name.substr(1, split -1);
		mask = fetchFilter(filterName + split + 1);
	}
	return HFilter(fetchFilter(name), mask);
}


void scidBaseT::calcNameFreq () {
	for (nameT n = NAME_PLAYER; n < NUM_NAME_TYPES; n++) {
		nameFreq_[n].clear();
		nameFreq_[n].resize(nb->GetNumNames(n), 0);
	}

	for (gamenumT i=0, n = numGames(); i < n; i++) {
		const IndexEntry* ie = getIndexEntry (i);
		nameFreq_[NAME_PLAYER][ie->GetWhite()] += 1;
		nameFreq_[NAME_PLAYER][ie->GetBlack()] += 1;
		nameFreq_[NAME_EVENT][ie->GetEvent()] += 1;
		nameFreq_[NAME_SITE][ie->GetSite()] += 1;
		nameFreq_[NAME_ROUND][ie->GetRound()] += 1;
	}
}

const scidBaseT::Stats* scidBaseT::getStats() const {
	if (validStats_) return stats_;
	if (stats_ == NULL) stats_ = new scidBaseT::Stats;

	uint i;
	// Zero out all stats:
	for (i = 0; i < IDX_NUM_FLAGS; i++) { stats_->flagCount[i] = 0; }
	stats_->nRatings = 0;
	stats_->sumRatings = 0;
	stats_->minRating = 0;
	stats_->maxRating = 0;
	stats_->minDate = ZERO_DATE;
	stats_->maxDate = ZERO_DATE;
	stats_->nYears = 0;
	stats_->sumYears = 0;
	for (i=0; i < NUM_RESULT_TYPES; i++) {
		stats_->nResults[i] = 0;
	}
	for (i=0; i < 1; i++) {
		stats_->ecoCount0[i].count = 0;
		stats_->ecoCount0[i].results[RESULT_White] = 0;
		stats_->ecoCount0[i].results[RESULT_Black] = 0;
		stats_->ecoCount0[i].results[RESULT_Draw] = 0;
		stats_->ecoCount0[i].results[RESULT_None] = 0;
	}
	for (i=0; i < 5; i++) {
		stats_->ecoCount1[i].count = 0;
		stats_->ecoCount1[i].results[RESULT_White] = 0;
		stats_->ecoCount1[i].results[RESULT_Black] = 0;
		stats_->ecoCount1[i].results[RESULT_Draw] = 0;
		stats_->ecoCount1[i].results[RESULT_None] = 0;
	}
	for (i=0; i < 50; i++) {
		stats_->ecoCount2[i].count = 0;
		stats_->ecoCount2[i].results[RESULT_White] = 0;
		stats_->ecoCount2[i].results[RESULT_Black] = 0;
		stats_->ecoCount2[i].results[RESULT_Draw] = 0;
		stats_->ecoCount2[i].results[RESULT_None] = 0;
	}
	for (i=0; i < 500; i++) {
		stats_->ecoCount3[i].count = 0;
		stats_->ecoCount3[i].results[RESULT_White] = 0;
		stats_->ecoCount3[i].results[RESULT_Black] = 0;
		stats_->ecoCount3[i].results[RESULT_Draw] = 0;
		stats_->ecoCount3[i].results[RESULT_None] = 0;
	}
	for (i=0; i < 500*26; i++) {
		stats_->ecoCount4[i].count = 0;
		stats_->ecoCount4[i].results[RESULT_White] = 0;
		stats_->ecoCount4[i].results[RESULT_Black] = 0;
		stats_->ecoCount4[i].results[RESULT_Draw] = 0;
		stats_->ecoCount4[i].results[RESULT_None] = 0;
	}
	// Read stats from index entry of each game:
	for (gamenumT gnum=0, n = numGames(); gnum < n; gnum++) {
		const IndexEntry* ie = getIndexEntry(gnum);
		stats_->nResults[ie->GetResult()]++;
		eloT elo = ie->GetWhiteElo();
		if (elo > 0) {
			stats_->nRatings++;
			stats_->sumRatings += elo;
			if (stats_->minRating == 0) { stats_->minRating = elo; }
			if (elo < stats_->minRating) { stats_->minRating = elo; }
			if (elo > stats_->maxRating) { stats_->maxRating = elo; }
			nb->AddElo (ie->GetWhite(), elo);
		}
		elo = ie->GetBlackElo();
		if (elo > 0) {
			stats_->nRatings++;
			stats_->sumRatings += elo;
			if (stats_->minRating == 0) { stats_->minRating = elo; }
			if (elo < stats_->minRating) { stats_->minRating = elo; }
			if (elo > stats_->maxRating) { stats_->maxRating = elo; }
			nb->AddElo (ie->GetBlack(), elo);
		}
		dateT date = ie->GetDate();
		if (gnum == 0) {
			stats_->maxDate = stats_->minDate = date;
		}
		if (date_GetYear(date) > 0) {
			if (date < stats_->minDate) { stats_->minDate = date; }
			if (date > stats_->maxDate) { stats_->maxDate = date; }
			stats_->nYears++;
			stats_->sumYears += date_GetYear (date);
			nb->AddDate (ie->GetWhite(), date);
			nb->AddDate (ie->GetBlack(), date);
		}

		for (uint flag = 0; flag < IDX_NUM_FLAGS; flag++) {
			bool value = ie->GetFlag (1 << flag);
			if (value) {
				stats_->flagCount[flag]++;
			}
		}

		ecoT eco = ie->GetEcoCode();
		ecoStringT ecoStr;
		eco_ToExtendedString (eco, ecoStr);
		uint length = strLength (ecoStr);
		resultT result = ie->GetResult();
		if (length >= 3) {
			uint code = 0;
			stats_->ecoCount0[code].count++;
			stats_->ecoCount0[code].results[result]++;
			code = ecoStr[0] - 'A';
			stats_->ecoCount1[code].count++;
			stats_->ecoCount1[code].results[result]++;
			code = (code * 10) + (ecoStr[1] - '0');
			stats_->ecoCount2[code].count++;
			stats_->ecoCount2[code].results[result]++;
			code = (code * 10) + (ecoStr[2] - '0');
			stats_->ecoCount3[code].count++;
			stats_->ecoCount3[code].results[result]++;
			if (length >= 4) {
				code = (code * 26) + (ecoStr[3] - 'a');
				stats_->ecoCount4[code].count++;
				stats_->ecoCount4[code].results[result]++;
			}
		}
	}

	validStats_ = true;
	return stats_;
}

double scidBaseT::TreeStat::expVect_[1600];

scidBaseT::TreeStat::TreeStat()
: toMove(NOCOLOR), resultW(0), resultD(0), resultB(0), exp(0), ngames(0), nexp(0)
{
	if (TreeStat::expVect_[0] == 0) {
		for (int i=-800; i < 800; i++) TreeStat::expVect_[i+800] = 1/(1 + pow(10, i/400.0));
	}
}

std::vector<scidBaseT::TreeStat> scidBaseT::getTreeStat(const HFilter& filter) {
	ASSERT(*filter);
	std::vector<FullMove> v1;
	v1.reserve(50);
	std::vector<scidBaseT::TreeStat> v2;
	v2.reserve(50);
	for(gamenumT gnum=0, n = numGames(); gnum < n; gnum++) {
		if(filter.get(gnum) == 0) continue;
		uint ply = filter.get(gnum) - 1;
		const IndexEntry* ie = getIndexEntry (gnum);
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
	for (gamenumT i=0, n = numGames(); i < n; i++) {
		const IndexEntry* ie = getIndexEntry (i);
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

errorT scidBaseT::compact(SpellChecker* spellChk, const Progress& progress) {
	if (fileMode != FMODE_Both) {
		//Older scid version to be upgraded are opened read only
		if (idx->GetVersion() == SCID_VERSION) return ERROR_FileMode;
	}

	//1) Create the list of games to be copied
	typedef std::vector< std::pair<byte, uint> > sort_t;
	sort_t sort;
	uint n_deleted = 0;
	for (gamenumT i=0, n= numGames(); i < n; i++) {
		const IndexEntry* ie = getIndexEntry (i);
		if (ie->GetDeleteFlag()) { n_deleted++; continue; }
		uint stLine = ie->GetStoredLineCode();
		sort.push_back(std::make_pair(stLine, i));
	}
	std::stable_sort(sort.begin(), sort.end());

	//2) Create a new temporary database
	std::string filename = fileName_;
	std::string tmpfile = filename + "__COMPACT__";
	scidBaseT tmp;
	errorT err_Create = tmp.Open(FMODE_Both, tmpfile.c_str());
	if (err_Create != OK) return err_Create;

	//3) Copy the Index Header
	tmp.idx->SetType (idx->GetType());
	tmp.idx->SetDescription (idx->GetDescription());
	tmp.idx->SetAutoLoad (idx->GetAutoLoad());
	for (byte b = IDX_FLAG_CUSTOM1; b < IDX_FLAG_CUSTOM1 + CUSTOM_FLAG_MAX ; b++ ) {
		const char* flagDesc = idx->GetCustomFlagDesc(b);
		tmp.idx->SetCustomFlagDesc(b, flagDesc);
	}

	//4) Copy the games
	uint iProgress = 0;
	bool err_UserCancel = false;
	errorT err_AddGame = OK;
	for (sort_t::iterator it = sort.begin(); it != sort.end(); it++) {
		err_AddGame = tmp.addGame_(this, (*it).second);
		if (err_AddGame != OK) break;
		//TODO:
		//- update bookmarks game number
		//- update autoload game number
		//  (*it).second   == old game number
		//  tmp.numGames() == new game number
		if (iProgress++ % 10000 == 0) {
			if (!progress.report(iProgress, sort.size())) {
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
		std::remove((tmpfile + INDEX_SUFFIX).c_str());
		std::remove((tmpfile + NAMEBASE_SUFFIX).c_str());
		std::remove((tmpfile + GFILE_SUFFIX).c_str());
		if (err_UserCancel) return ERROR_UserCancel;
		return (err_Close != OK) ? err_Close : ((err_NbWrite != OK) ? err_NbWrite : err_AddGame);
	}

	//7) Reset the filters and remove the old database
	std::vector<std::string> filters(filters_.size());
	for (size_t i = 0; i < filters_.size(); i++) filters[i] = filters_[i].first;
	if (Close() != OK) return ERROR_FileInUse;
	if (std::remove((filename + INDEX_SUFFIX).c_str())    != 0) return ERROR_FileWrite;
	if (std::remove((filename + NAMEBASE_SUFFIX).c_str()) != 0) return ERROR_FileWrite;
	if (std::remove((filename + GFILE_SUFFIX).c_str())    != 0) return ERROR_FileWrite;

	//8) Success: rename the files and open the new database
	renameFile (tmpfile.c_str(), filename.c_str(), INDEX_SUFFIX);
	renameFile (tmpfile.c_str(), filename.c_str(), NAMEBASE_SUFFIX);
	renameFile (tmpfile.c_str(), filename.c_str(), GFILE_SUFFIX);
	errorT res = Open(FMODE_Both, filename.c_str(), false, spellChk);
	for (size_t i = 0; i <filters.size(); i++) {
		filters_.push_back(std::make_pair(filters[i], new Filter(numGames())));
	}
	return res;
}

errorT scidBaseT::getExtraInfo(const std::string& tagname, std::string* res) const {
	if (tagname == "description") {
		*res = idx->GetDescription();
	} else if (tagname == "autoload") {
		*res = to_string(idx->GetAutoLoad());
	} else if (tagname == "type") {
		*res = to_string(idx->GetType());
	} else if (tagname.length() == 5 && tagname.find("flag") == 0) {
		uint flagType = IndexEntry::CharToFlag(tagname[4]);
		if (flagType == 0) return ERROR_BadArg;
		const char* desc = idx->GetCustomFlagDesc(flagType);;
		if (desc == 0) return ERROR_BadArg;
		*res = desc;
	} else {
		return ERROR_BadArg;
	}
	return OK;
}

errorT scidBaseT::setExtraInfo(const std::string& tagname, const char* new_value) {
	if (tagname == "description") {
		idx->SetDescription(new_value);
	} else if (tagname == "autoload") {
		idx->SetAutoLoad(strGetUnsigned(new_value));
	} else if (tagname == "type") {
		idx->SetType(strGetUnsigned(new_value));
	} else if (tagname.length() == 5 && tagname.find("flag") == 0) {
		uint flagType = IndexEntry::CharToFlag(tagname[4]);
		if (flagType == 0) return ERROR_BadArg;
		if (idx->GetCustomFlagDesc(flagType) == 0) return ERROR_BadArg;
		idx->SetCustomFlagDesc(flagType, new_value);
	} else {
		return ERROR_BadArg;
	}
	return idx->WriteHeader();
}
