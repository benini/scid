/*
* Copyright (C) 2014-2016  Fulvio Benini

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
	fileMode = FMODE_Both;
	gfile = new GFile;
	bbuf = new ByteBuffer(BBUF_SIZE);
	dbFilter = new Filter(0);
	treeFilter = new Filter(0);
	duplicates_ = NULL;
	stats_ = NULL;
}

scidBaseT::~scidBaseT() {
	if (duplicates_ != NULL) delete[] duplicates_;
	if (idx != NULL) delete idx;
	if (nb != NULL) delete nb;
	if (game != NULL) delete game;
	if (gfile != NULL) delete gfile;
	if (bbuf != NULL) delete bbuf;
	if (stats_ != NULL) delete stats_;
	if (dbFilter != NULL) delete dbFilter;
	if (treeFilter != NULL) delete treeFilter;
	for (uint i=0; i < filters_.size(); i++) {
		if (filters_[i].second != NULL) delete filters_[i].second;
	}
}

errorT scidBaseT::Open (fileModeT mode,
                        const char* filename,
                        bool create,
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
	//Default treeCache size: 250
	treeCache.CacheResize(250);

	return err;
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
	if (stats_ != NULL) { delete stats_; stats_ = NULL;}
	if (duplicates_ != NULL) { delete[] duplicates_; duplicates_ = NULL; }
	treeCache.Clear();
	for (nameT nt = NAME_PLAYER; nt < NUM_NAME_TYPES; nt++) {
		nameFreq_[nt].resize(0);
	}
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

/**
* scidBaseT::makeGamePos() - constructs a GamePos object
* @game: a Game object with a valid current position
* @ravNum: current variation number
*
* This function extracts informations from the current position of Game @game
* and create a GamePos object with the corresponding informations:
* RAVdepth: current variation depth.
* RAVnum: current variation num.
* FEN: "Forsyth-Edwards Notation" describing the current position.
* NAGS: "Numeric Annotation Glyph" is a non-negative integer from 0 to 255
*       used to indicate a simple annotation in a language independent manner.
* comment: text annotation of the current position.
* lastMoveSAN: the last move that was played to reach the current position.
*              The move is indicated using English "Standard Algebraic Notation".
*/
scidBaseT::GamePos scidBaseT::makeGamePos(Game& game, unsigned int ravNum) {
	GamePos res;
	res.RAVdepth = game.GetVarLevel();
	res.RAVnum = ravNum;
	char strBuf[256];
	game.GetCurrentPos()->PrintFEN(strBuf, FEN_ALL_FIELDS);
	res.FEN = strBuf;
	for (byte* nag = game.GetNags(); *nag; nag++) {
		res.NAGs.push_back(*nag);
	}
	res.comment = game.GetMoveComment();
	game.GetPrevSAN(strBuf);
	res.lastMoveSAN = strBuf;
	return res;
}

/**
* scidBaseT::getGame() - returns all the positions of a game
* @ie: a valid pointer to the IndexEntry of the desired game
* @dest: a container of GamePos objects where the positions will be stored.
*
* This function iterate alle the positions of the game pointed by @ie and
* stores the positions in @dest. The container is NOT automatically cleared
* and the container should support push_back().
* The order of positions and of Recursive Annotation Variations (RAV)
* follows the pgn standard: "The alternate move sequence given by an RAV is
* one that may be legally played by first unplaying the move that appears
* immediately prior to the RAV. Because the RAV is a recursive construct,
* it may be nested."
* Each position have a RAVdepth and a RAVnum that allows to follow a
* variation from any given position:
* - skip all the next positions with a bigger RAVdepth
* - the variation ends with:
*   - a lower RAVdepth or
*   - an equal RAVdepth but different RAVnum or
*   - the end of @dest
*
* Return OK if successful.
*/
errorT scidBaseT::getGame(const IndexEntry* ie, std::vector<GamePos>& dest) {
	ASSERT(ie != 0);

	// Create the Game object
	ByteBuffer buf(BBUF_SIZE);
	if (getGame(ie, &buf) != OK) {
		return ERROR_Decode;
	}
	Game game;
	if (game.Decode(&buf, GAME_DECODE_ALL) != OK) {
		return ERROR_Decode;
	}
	std::vector<int> endPos = game.GetCurrentLocation();
	game.MoveToPly(0);

	// Add start FEN
	dest.push_back(makeGamePos(game, 0));

	// Iterate all the positions of the game
	std::vector< std::pair<uint, uint> > rav;
	rav.push_back(std::make_pair(0, 0));
	errorT err = OK;
	while (err == OK) {
		uint nVariations = game.GetNumVariations();
		err = game.MoveForward();
		if (err == OK) {
			dest.push_back(makeGamePos(game, rav.back().first));
		}

		if (nVariations != 0) {
			if (err == OK) {
				// Go back in order to process variations
				err = game.MoveBackup();
				if (err != OK) break;
			}
			// Enter the first variation
			err = game.MoveIntoVariation(0);
			rav.push_back(std::make_pair(0, nVariations));
		} else {
			if (err == ERROR_EndOfMoveList) {
				// Leave the current variation
				err = game.MoveExitVariation();
				if (err != OK) break;

				if (++rav.back().first < rav.back().second) {
					// Enter the next variation
					err = game.MoveIntoVariation(rav.back().first);
				} else {
					// All the sub-variation has been processed
					rav.pop_back();
					// Skip the main move of the parent variation
					err = game.MoveForward();
				}
			}
		}
	}
	if (rav.size() == 1 && game.GetCurrentLocation() == endPos) return OK;
	return err;
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

	errorT errSave = saveGameHelper(&iE, bbuf, gnum);
	if (errSave == OK && clearCache) {
		if (gnum >= numGames()) {
			ASSERT(numGames() > 0);
			gnum = numGames() -1;
		}
		return clearCaches(gnum);
	}
	return errSave;
}

errorT scidBaseT::importGame(scidBaseT* sourceBase, uint gNum) {
	if (sourceBase == this) return ERROR_BadArg;
	if (fileMode == FMODE_ReadOnly) return ERROR_FileReadOnly;

	errorT err = addGameHelper(sourceBase, gNum);
	if (err != OK) return err;
	ASSERT(numGames() > 0);
	return clearCaches(numGames() -1);
}

errorT scidBaseT::importGames(scidBaseT* sourceBase, const HFilter& filter, const Progress& progress) {
	ASSERT(*filter);
	if (sourceBase == this) return ERROR_BadArg;
	if (fileMode == FMODE_ReadOnly) return ERROR_FileReadOnly;

	errorT err = OK;
	uint iProgress = 0;
	uint totGames = filter.count();
	Filter* f; int i_filters=0;
	while ( (f = fetchFilter(i_filters++)) ) f->SetCapacity(numGames() + totGames);
	for (gamenumT gNum = 0, n = sourceBase->numGames(); gNum < n; gNum++) {
		if (filter.get(gNum) == 0) continue;
		err = addGameHelper(sourceBase, gNum);
		if (err != OK) break;
		if (iProgress++ % 10000 == 0) {
			if (!progress.report(iProgress, totGames)) break;
		}
	}
	errorT errClear = clearCaches();
	return (err == OK) ? errClear : err;
}

errorT scidBaseT::addGameHelper(scidBaseT* sourceBase, uint gNum) {
	// Importing a game from the same base works, but it's too dangerous
	ASSERT(sourceBase != this);

	const IndexEntry* srcIe = sourceBase->getIndexEntry(gNum);
	errorT err = sourceBase->gfile->ReadGame(sourceBase->bbuf, srcIe->GetOffset(), srcIe->GetLength());
	if (err != OK) return err;

	IndexEntry iE = *srcIe;
	if ((err = iE.SetWhiteName(nb, srcIe->GetWhiteName(sourceBase->nb))) != OK) return err;
	if ((err = iE.SetBlackName(nb, srcIe->GetBlackName(sourceBase->nb))) != OK) return err;
	if ((err = iE.SetEventName(nb, srcIe->GetEventName(sourceBase->nb))) != OK) return err;
	if ((err = iE.SetSiteName (nb, srcIe->GetSiteName(sourceBase->nb) )) != OK) return err;
	if ((err = iE.SetRoundName(nb, srcIe->GetRoundName(sourceBase->nb))) != OK) return err;

	return saveGameHelper(&iE, sourceBase->bbuf);
}

errorT scidBaseT::saveGameHelper(IndexEntry* iE, ByteBuffer* bytebuf, gamenumT oldIdx) {
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
		errorT err = idx->WriteEntry (iE, oldIdx);
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

HFilter scidBaseT::getFilter (const char* filterName) const {
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

const scidBaseT::Stats& scidBaseT::getStats() const {
	if (stats_ == NULL) stats_ = new scidBaseT::Stats(this);
	return *stats_;
}

scidBaseT::Stats::Eco::Eco()
: count(0) {
	std::fill_n(results, NUM_RESULT_TYPES, 0);
}

scidBaseT::Stats::Stats(const scidBaseT* dbase) {
	std::fill(flagCount, flagCount + IDX_NUM_FLAGS, 0);
	minDate = ZERO_DATE;
	maxDate = ZERO_DATE;
	nYears = 0;
	sumYears = 0;
	std::fill_n(nResults, NUM_RESULT_TYPES, 0);
	nRatings = 0;
	sumRatings = 0;
	minRating = 0;
	maxRating = 0;

	// Read stats from index entry of each game:
	for (gamenumT gnum=0, n = dbase->numGames(); gnum < n; gnum++) {
		const IndexEntry* ie = dbase->getIndexEntry(gnum);
		nResults[ie->GetResult()]++;
		eloT elo = ie->GetWhiteElo();
		if (elo > 0) {
			nRatings++;
			sumRatings += elo;
			if (minRating == 0) { minRating = elo; }
			if (elo < minRating) { minRating = elo; }
			if (elo > maxRating) { maxRating = elo; }
		}
		elo = ie->GetBlackElo();
		if (elo > 0) {
			nRatings++;
			sumRatings += elo;
			if (minRating == 0) { minRating = elo; }
			if (elo < minRating) { minRating = elo; }
			if (elo > maxRating) { maxRating = elo; }
		}
		dateT date = ie->GetDate();
		if (gnum == 0) {
			maxDate = minDate = date;
		}
		if (date_GetYear(date) > 0) {
			if (date < minDate) { minDate = date; }
			if (date > maxDate) { maxDate = date; }
			nYears++;
			sumYears += date_GetYear (date);
		}

		for (uint flag = 0; flag < IDX_NUM_FLAGS; flag++) {
			bool value = ie->GetFlag (1 << flag);
			if (value) {
				flagCount[flag]++;
			}
		}

		resultT result = ie->GetResult();
		ecoT eco = ie->GetEcoCode();
		if (eco == 0) {
			ecoEmpty_.count++;
			ecoEmpty_.results[result]++;
		} else {
			ecoValid_.count++;
			ecoValid_.results[result]++;
			eco = eco_Reduce(eco);
			ecoStats_[eco].count++;
			ecoStats_[eco].results[result]++;
			eco /= 27;
			ecoGroup3_[eco].count++;
			ecoGroup3_[eco].results[result]++;
			eco /= 10;
			ecoGroup2_[eco].count++;
			ecoGroup2_[eco].results[result]++;
			eco /= 10;
			ecoGroup1_[eco].count++;
			ecoGroup1_[eco].results[result]++;
		}
	}
}

const scidBaseT::Stats::Eco* scidBaseT::Stats::getEcoStats(const char* ecoStr) const {
	ASSERT(ecoStr != 0);

	if (*ecoStr == 0) return &ecoValid_;

	ecoT eco = eco_FromString(ecoStr);
	if (eco == 0) return 0;
	eco = eco_Reduce(eco);

	switch(strlen(ecoStr)) {
	case 0:
		return &ecoValid_;
	case 1:
		return &(ecoGroup1_[eco / 2700]);
	case 2:
		return &(ecoGroup2_[eco / 270]);
	case 3:
		return &(ecoGroup3_[eco / 27]);
	case 4:
	case 5:
		return &(ecoStats_[eco]);
	}

	return 0;
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

	std::vector<scidBaseT::TreeStat> res;
	std::vector<FullMove> v;
	for (gamenumT gnum = 0, n = numGames(); gnum < n; gnum++) {
		uint ply = filter.get(gnum);
		if (ply == 0) continue;
		else ply--;

		const IndexEntry* ie = getIndexEntry(gnum);
		FullMove move = StoredLine::getMove(ie->GetStoredLineCode(), ply);
		if (move.isNull()) {
			move = gfile->ReadGame(ie->GetOffset(), ie->GetLength()).getMove(ply);
		}

		size_t i = 0;
		while (i < v.size() && v[i] != move) i++;
		if (i == v.size()) {
			v.push_back(move);
			res.push_back(scidBaseT::TreeStat());
		}
		res[i].add(ie->GetResult(), ie->GetWhiteElo(nb), ie->GetBlackElo(nb));
	}

	for (size_t i = 0, n = v.size(); i < n; i++) {
		res[i].SAN = (v[i].isNull()) ? "[end]" : v[i].getSAN(&(res[i].toMove));
	}

	std::sort(res.begin(), res.end());
	return res;
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

errorT scidBaseT::compact(const Progress& progress) {
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
	std::sort(sort.begin(), sort.end());

	//2) Create a new temporary database
	std::string filename = fileName_;
	std::string tmpfile = filename + "__COMPACT__";
	scidBaseT tmp;
	errorT err_Create = tmp.Open(FMODE_Both, tmpfile.c_str());
	if (err_Create != OK) return err_Create;

	//3) Copy the Index Header
	idx->FreeSortCache(0);
	tmp.idx->SetType (idx->GetType());
	tmp.idx->SetDescription (idx->GetDescription());
	gamenumT oldAutoload = idx->GetAutoLoad();
	for (byte b = IDX_FLAG_CUSTOM1; b < IDX_FLAG_CUSTOM1 + CUSTOM_FLAG_MAX ; b++ ) {
		const char* flagDesc = idx->GetCustomFlagDesc(b);
		tmp.idx->SetCustomFlagDesc(b, flagDesc);
	}

	//4) Copy the games
	uint iProgress = 0;
	bool err_UserCancel = false;
	errorT err_AddGame = OK;
	for (sort_t::iterator it = sort.begin(); it != sort.end(); it++) {
		err_AddGame = tmp.addGameHelper(this, (*it).second);
		if (err_AddGame != OK) break;

		if ((it->second + 1) == oldAutoload) {
			tmp.idx->SetAutoLoad(tmp.numGames());
		}
		//TODO:
		//- update bookmarks game number
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

	const char* NAMEBASE_SUFFIX = NameBase::Suffix();
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
	if (std::remove((filename + INDEX_SUFFIX).c_str())    != 0) return ERROR_CompactRemoveIdx;
	if (std::remove((filename + NAMEBASE_SUFFIX).c_str()) != 0) return ERROR_CompactRemoveName;
	if (std::remove((filename + GFILE_SUFFIX).c_str())    != 0) return ERROR_CompactRemoveGame;

	//8) Success: rename the files and open the new database
	renameFile (tmpfile.c_str(), filename.c_str(), INDEX_SUFFIX);
	renameFile (tmpfile.c_str(), filename.c_str(), NAMEBASE_SUFFIX);
	renameFile (tmpfile.c_str(), filename.c_str(), GFILE_SUFFIX);
	errorT res = Open(FMODE_Both, filename.c_str(), false);
	for (size_t i = 0; i <filters.size(); i++) {
		filters_.push_back(std::make_pair(filters[i], new Filter(numGames())));
	}
	return res;
}
