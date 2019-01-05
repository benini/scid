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

#include "scidbase.h"
#include "codec_memory.h"
#include "codec_pgn.h"
#include "codec_scid4.h"
#include "common.h"
#include "sortcache.h"
#include "stored.h"
#include <algorithm>
#include <math.h>

std::pair<ICodecDatabase*, errorT>
ICodecDatabase::open(Codec codec, fileModeT fMode, const char* filename,
                     const Progress& progress, Index* idx, NameBase* nb) {
	auto createCodec = [](auto codec) -> ICodecDatabase* {
		switch (codec) {
		case ICodecDatabase::MEMORY:
			return new CodecMemory();
		case ICodecDatabase::SCID4:
			return new CodecSCID4();
		case ICodecDatabase::PGN:
			return new CodecPgn();
		}
		ASSERT(0);
		return nullptr;
	};

	auto obj = createCodec(codec);
	auto err = obj->dyn_open(fMode, filename, progress, idx, nb);
	if (err != OK && err != ERROR_NameDataLoss) {
		delete obj;
		obj = nullptr;
	}
	return {obj, err};
}

scidBaseT::scidBaseT() {
	idx = new Index;
	nb_ = new NameBase;
	game = new Game;
	gameNumber = -1;
	gameAltered = false;
	inUse = false;
	tree.moveCount = tree.totalCount = 0;
	fileMode_ = FMODE_None;
	bbuf = new ByteBuffer(BBUF_SIZE);
	dbFilter = new Filter(0);
	treeFilter = new Filter(0);
	duplicates_ = NULL;
	stats_ = NULL;
}

scidBaseT::~scidBaseT() {
	if (inUse)
		Close();

	delete[] duplicates_;
	delete idx;
	delete nb_;
	delete game;
	delete bbuf;
	delete stats_;
	delete dbFilter;
	delete treeFilter;
}

errorT scidBaseT::Open(ICodecDatabase::Codec dbtype, fileModeT fMode,
                       const char* filename, const Progress& progress) {
	if (inUse)
		return ERROR_FileInUse;
	if (filename == 0)
		filename = "";

	auto obj = ICodecDatabase::open(dbtype, fMode, filename, progress, idx, nb_);
	if (obj.first) {
		codec_.reset(obj.first);
		inUse = true;
		fileMode_ = (fMode == FMODE_Create) ? FMODE_Both : fMode;
		fileName_ = filename;
		gameNumber = -1;

		// Initialize the filters: all the games are included by default.
		dbFilter->Init(numGames());
		treeFilter->Init(numGames());
		ASSERT(filters_.empty());

		// Default treeCache size: 250
		treeCache.CacheResize(250);
	} else {
		idx->Close();
		nb_->Clear();
	}

	return obj.second;
}

errorT scidBaseT::Close () {
	ASSERT(inUse);

	for (auto& sortCache : sortCaches_) {
		delete sortCache.second;
	}
	sortCaches_.clear();

	errorT errIdx = idx->Close();
	nb_->Clear();
	codec_ = nullptr;

	clear();
	game->Clear();
	fileMode_ = FMODE_None;
	fileName_ = "<empty>";
	gameNumber = -1;
	gameAltered = false;
	dbFilter->Init(0);
	treeFilter->Init(0);
	for (size_t i=0, n = filters_.size(); i < n; i++) delete filters_[i].second;
	filters_.clear();
	inUse = false;

	return errIdx;
}


void scidBaseT::clear() {
	if (stats_ != NULL) { delete stats_; stats_ = NULL;}
	if (duplicates_ != NULL) { delete[] duplicates_; duplicates_ = NULL; }
	treeCache.Clear();
	for (nameT nt = NAME_PLAYER; nt < NUM_NAME_TYPES; nt++) {
		nameFreq_[nt].resize(0);
	}
}

void scidBaseT::beginTransaction() {
	for (auto& sortCache : sortCaches_) {
		sortCache.second->prepareForChanges();
	}
}

errorT scidBaseT::endTransaction(gamenumT gNum) {
	clear();
	errorT res = codec_->flush();

	auto n_games = numGames();
	if (dbFilter->Size() != n_games) {
		dbFilter->Resize(n_games);
		treeFilter->Resize(n_games);
		for (auto& filter : filters_) {
			filter.second->Resize(n_games);
		}
	}

	for (auto& sortCache : sortCaches_) {
		sortCache.second->checkForChanges(gNum);
	}

	return res;
}

errorT scidBaseT::saveGame(Game* game, gamenumT replacedGameId) {
	beginTransaction();
	errorT err1 = saveGameHelper(game, replacedGameId);
	errorT err2 = endTransaction(replacedGameId);
	return (err1 != OK) ? err1 : err2;
}

errorT scidBaseT::saveGameHelper(Game* game, gamenumT gameId) {
	if (isReadOnly())
		return ERROR_FileReadOnly;

	if (gameId < numGames())
		return codec_->saveGame(game, gameId);

	return codec_->addGame(game);
}

errorT scidBaseT::importGame(const scidBaseT* srcBase, uint gNum) {
	if (srcBase == this) return ERROR_BadArg;
	if (isReadOnly()) return ERROR_FileReadOnly;
	if (gNum >= srcBase->numGames()) return ERROR_BadArg;

	beginTransaction();
	errorT err = importGameHelper(srcBase, gNum);
	errorT errClear = endTransaction();
	return (err == OK) ? errClear : err;
}

errorT scidBaseT::importGames(const scidBaseT* srcBase, const HFilter& filter, const Progress& progress) {
	ASSERT(srcBase != 0);
	ASSERT(filter != 0);
	if (srcBase == this) return ERROR_BadArg;
	if (isReadOnly()) return ERROR_FileReadOnly;

	beginTransaction();
	errorT err = OK;
	size_t iProgress = 0;
	size_t totGames = filter->size();
	for (gamenumT gNum = 0, n = srcBase->numGames(); gNum < n; gNum++) {
		if (filter.get(gNum) == 0) continue;
		err = importGameHelper(srcBase, gNum);
		if (err != OK) break;
		if (++iProgress % 8192 == 0) {
			if (!progress.report(iProgress, totGames)) break;
		}
	}
	errorT errClear = endTransaction();
	return (err == OK) ? errClear : err;
}

errorT scidBaseT::importGameHelper(const scidBaseT* srcBase, gamenumT gNum) {
	auto srcIe = srcBase->getIndexEntry(gNum);
	auto dataSz = srcIe->GetLength();
	auto data = srcBase->codec_->getGameData(srcIe->GetOffset(), dataSz);
	if (data == nullptr)
		return ERROR_FileRead;

	return codec_->addGame(srcIe, srcBase->getNameBase(), data, dataSz);
}

errorT scidBaseT::importGames(ICodecDatabase::Codec dbtype,
                              const char* filename, const Progress& progress,
                              std::string& errorMsg) {
	ASSERT(dbtype == ICodecDatabase::PGN);

	if (isReadOnly())
		return ERROR_FileReadOnly;

	beginTransaction();

	CodecPgn pgn;
	auto res = pgn.open(filename, FMODE_ReadOnly);
	if (res == OK) {
		res = CodecPgn::parseGames(
		    progress, pgn, [&](Game& game) { return codec_->addGame(&game); });
		errorMsg = pgn.parseErrors();
	}

	auto res_endTrans = endTransaction();
	return (res != OK) ? res : res_endTrans;
}

/**
 * Filters
 */
std::string scidBaseT::newFilter() {
	std::string newname = (filters_.size() == 0)
		? "a_"
		: filters_.back().first;
	if (newname[0] == 'z') {
		newname = 'a' + newname;
	} else {
		newname = ++(newname[0]) + newname.substr(1);
	}
	filters_.push_back(std::make_pair(newname, new Filter(numGames())));
	return newname;
}

std::string scidBaseT::composeFilter(const std::string& mainFilter,
                                     const std::string& maskFilter) const {
	std::string res;
	if (mainFilter.empty()) return res;

	if (mainFilter[0] != '+') {
		res = mainFilter;
	} else {
		size_t maskName = mainFilter.find('+', 1);
		if (maskName != std::string::npos)
			res = mainFilter.substr(1, maskName - 1);
	}

	if (!maskFilter.empty()) {
		res = '+' + res + "+" + maskFilter;
	}

	if (getFilter(res) == 0) res.clear();
	return res;
}

void scidBaseT::deleteFilter(const char* filterId) {
	for (size_t i = 0, n = filters_.size(); i < n; i++) {
		if (filters_[i].first == filterId) {
			delete filters_[i].second;
			filters_.erase(filters_.begin() + i);
			break;
		}
	}
}

Filter* scidBaseT::fetchFilter(const std::string& filterId) const {
	if (filterId == "dbfilter") return dbFilter;
	if (filterId == "tree") return treeFilter;

	for (size_t i = 0, n = filters_.size(); i < n; i++) {
		if (filterId == filters_[i].first)
			return filters_[i].second;
	}
	return 0;
}

HFilter scidBaseT::getFilterHelper(const std::string& filterId,
                                   bool unmasked) const {
	Filter* main = 0;
	const Filter* mask = 0;
	if (filterId.empty() || filterId[0] != '+') {
		main = fetchFilter(filterId);
	} else {
		size_t maskName = filterId.find('+', 1);
		if (maskName != std::string::npos) {
			main = fetchFilter(filterId.substr(1, maskName - 1));
			if (!unmasked) mask = fetchFilter(filterId.substr(maskName + 1));
		}
	}
	return HFilter(main, mask);
}

/**
 * Statistics
 */
const scidBaseT::Stats& scidBaseT::getStats() const {
	if (stats_ == NULL) stats_ = new scidBaseT::Stats(this);
	return *stats_;
}

scidBaseT::Stats::Eco::Eco()
: count(0) {
	std::fill_n(results, NUM_RESULT_TYPES, 0);
}

scidBaseT::Stats::Stats(const scidBaseT* dbase) {
	std::fill(flagCount, flagCount + IndexEntry::IDX_NUM_FLAGS, 0);
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

		for (uint flag = 0; flag < IndexEntry::IDX_NUM_FLAGS; flag++) {
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
	ASSERT(filter != 0);

	std::vector<scidBaseT::TreeStat> res;
	std::vector<FullMove> v;
	auto nb = getNameBase();
	for (gamenumT gnum = 0, n = numGames(); gnum < n; gnum++) {
		uint ply = filter.get(gnum);
		if (ply == 0) continue;
		else ply--;

		const IndexEntry* ie = getIndexEntry(gnum);
		FullMove move = StoredLine::getMove(ie->GetStoredLineCode(), ply);
		if (!move)
			move = getGame(ie).getMove(ply);

		size_t i = 0;
		while (i < v.size() && v[i] != move) i++;
		if (i == v.size()) {
			v.push_back(move);
			res.push_back(scidBaseT::TreeStat());
		}
		res[i].add(ie->GetResult(), ie->GetWhiteElo(nb), ie->GetBlackElo(nb));
	}

	for (size_t i = 0, n = v.size(); i < n; i++) {
		res[i].SAN = !v[i] ? "[end]" : v[i].getSAN(&(res[i].toMove));
	}

	std::sort(res.begin(), res.end());
	return res;
}

errorT scidBaseT::getCompactStat(unsigned long long* n_deleted,
                                 unsigned long long* n_unused,
                                 unsigned long long* n_sparse,
                                 unsigned long long* n_badNameId) {
	std::vector<uint> nbFreq[NUM_NAME_TYPES];
	for (nameT n = NAME_PLAYER; n < NUM_NAME_TYPES; n++) {
		nbFreq[n].resize(getNameBase()->GetNumNames(n), 0);
	}

	uint64_t last_offset = 0;
	*n_sparse = 0;
	*n_deleted = 0;
	for (gamenumT i=0, n = numGames(); i < n; i++) {
		const IndexEntry* ie = getIndexEntry (i);
		if (ie->GetDeleteFlag()) { *n_deleted += 1; continue; }

		auto offset = ie->GetOffset();
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
	std::vector<std::string> filenames = codec_->getFilenames();
	if (filenames.empty()) return ERROR_CodecUnsupFeat;

	if (fileMode_ != FMODE_Both) {
		//Older scid version to be upgraded are opened read only
		if (idx->GetVersion() == SCID_VERSION) return ERROR_FileMode;
	}

	//1) Create a new temporary database
	std::string filename = fileName_;
	std::string tmpfile = filename + "__COMPACT__";
	ICodecDatabase::Codec dbtype = codec_->getType();
	scidBaseT tmp;
	errorT err_Create = tmp.Open(dbtype, FMODE_Create, tmpfile.c_str());
	if (err_Create != OK) return err_Create;

	//2) Copy the Index Header
	tmp.beginTransaction();
	tmp.idx->copyHeaderInfo(*idx);
	gamenumT autoloadOld = idx->GetAutoLoad();
	gamenumT autoloadNew = 1;

	//3) Create the list of games to be copied
	std::vector< std::pair<uint64_t, gamenumT> > sort;
	uint n_deleted = 0;
	for (gamenumT i = 0, n = numGames(); i < n; i++) {
		const IndexEntry* ie = getIndexEntry(i);
		if (ie->GetDeleteFlag()) {
			n_deleted++;
			continue;
		}
		uint64_t order = static_cast<uint64_t>(ie->GetStoredLineCode()) << 56;
		const byte* hp = ie->GetHomePawnData();
		order |= static_cast<uint64_t>(hp[0]) << 48;
		order |= static_cast<uint64_t>(hp[1]) << 40;
		order |= static_cast<uint64_t>(hp[2]) << 32;
		order |= static_cast<uint64_t>(hp[3]) << 24;
		order |= ie->GetFinalMatSig() & 0xFFFFFF;
		sort.emplace_back(order, i);
	}
	std::stable_sort(sort.begin(), sort.end());

	//4) Copy the games
	uint iProgress = 0;
	bool err_UserCancel = false;
	errorT err_AddGame = OK;
	for (auto it = sort.cbegin(); it != sort.cend(); ++it) {
		err_AddGame = tmp.importGameHelper(this, it->second);
		if (err_AddGame != OK) break;

		gamenumT oldGnum = it->second + 1;
		if (oldGnum == autoloadOld) autoloadNew = tmp.numGames();
		//TODO:
		//- update bookmarks game number
		//  (*it).second   == old game number
		//  tmp.numGames() == new game number
		if (++iProgress % 8192 == 0) {
			if (!progress.report(iProgress, sort.size())) {
				err_UserCancel = true;
				break;
			}
		}
	}

	//5) Finalize the new database
	tmp.idx->SetAutoLoad(autoloadNew);
	std::vector<std::string> tmp_filenames = tmp.codec_->getFilenames();
	errorT err_NbWrite = tmp.endTransaction();
	errorT err_Close = tmp.Close();
	if (err_Close == OK) err_Close = (filenames.size() == tmp_filenames.size()) ? OK : ERROR;

	//6) Error: cleanup and report
	if (err_NbWrite != OK || err_Close != OK || err_UserCancel || err_AddGame != OK) {
		for (size_t i = 0, n = tmp_filenames.size(); i < n; i++) {
			std::remove(tmp_filenames[i].c_str());
		}
		if (err_AddGame != OK)
			return err_AddGame;
		if (err_UserCancel)
			return ERROR_UserCancel;
		if (err_NbWrite != OK)
			return err_NbWrite;
		ASSERT(err_Close != OK);
		return err_Close;
	}

	//7) Remember the active filters and SortCaches
	std::vector<std::string> filters(filters_.size());
	for (size_t i = 0, n = filters_.size(); i < n; i++) {
		filters[i] = filters_[i].first;
	}
	std::vector< std::pair<std::string, int> > oldSC;
	for (auto& sortCache : sortCaches_) {
		int refCount = sortCache.second->incrRef(0);
		if (refCount >= 0)
			oldSC.emplace_back(sortCache.first, refCount);
	}

	//8) Remove the old database
	if (Close() != OK) return ERROR_FileInUse;
	for (size_t i = 0, n = filenames.size(); i < n; i++) {
		if (std::remove(filenames[i].c_str()) != 0) return ERROR_CompactRemove;
	}

	//9) Success: rename the files and open the new database
	for (size_t i = 0, n = filenames.size(); i < n; i++) {
		const char* s1 = tmp_filenames[i].c_str();
		const char* s2 = filenames[i].c_str();
		std::rename(s1, s2);
	}
	errorT res = Open(dbtype, FMODE_Both, filename.c_str());

	//10) Re-create filters and SortCaches
	if (res == OK || res == ERROR_NameDataLoss) {
		for (size_t i = 0, n = filters.size(); i < n; i++) {
			filters_.push_back(
			    std::make_pair(filters[i], new Filter(numGames())));
		}
		for (size_t i = 0, n = oldSC.size(); i < n; i++) {
			const std::string& criteria = oldSC[i].first;
			SortCache* sc = SortCache::create(idx, nb_, criteria.c_str());
			if (sc != NULL) {
				sc->incrRef(oldSC[i].second);
				sortCaches_.emplace_back(criteria, sc);
			}
		}
	}

	return res;
}

/**
 * Retrieve a SortCache object matching the supplied @e criteria.
 * A new SortCache with refCount equal to 0 is created if a suitable object is
 * not found in @e sortCaches_. Objects with refCount <= 0 are destroyed by the
 * @e releaseSortCache function independently from the provided @e criteria
 * argument (implementing a rudimentary garbage collector).
 * @param criteria: the list of fields by which games will be ordered.
 *                  Each field should be followed by '+' to indicate an
 *                  ascending order or by '-' for a descending order.
 * @returns a pointer to a SortCache object in case of success, NULL otherwise.
 */
SortCache* scidBaseT::getSortCache(const char* criteria) {
	ASSERT(criteria != NULL);

	for (auto& sortCache : sortCaches_) {
		if (sortCache.first == criteria)
			return sortCache.second;
	}

	SortCache* sc = SortCache::create(idx, getNameBase(), criteria);
	if (sc != NULL)
		sortCaches_.emplace_back(criteria, sc);

	return sc;
}

void scidBaseT::releaseSortCache(const char* criteria) {
	size_t i = 0;
	while (i < sortCaches_.size()) {
		const char* tmp = sortCaches_[i].first.c_str();
		int decr = std::strcmp(criteria, tmp) ? 0 : -1;
		if (sortCaches_[i].second->incrRef(decr) <= 0) {
			delete sortCaches_[i].second;
			sortCaches_.erase(sortCaches_.begin() + i);
			continue; //do not increment i
		}
		i += 1;
	}
}

SortCache* scidBaseT::createSortCache(const char* criteria) {
	SortCache* sc = getSortCache(criteria);
	if (sc != NULL)
		sc->incrRef(1);

	return sc;
}

size_t scidBaseT::listGames(const char* criteria, size_t start, size_t count,
                            const HFilter& filter, gamenumT* destCont) {
	const SortCache* sc = getSortCache(criteria);
	if (sc == NULL)
		return 0;

	return sc->select(start, count, filter, destCont);
}

size_t scidBaseT::sortedPosition(const char* criteria, const HFilter& filter,
                                 gamenumT gameId) {
	ASSERT(filter != NULL && filter->size() <= numGames());

	if (gameId >= numGames() || filter->get(gameId) == 0)
		return INVALID_GAMEID;

	SortCache* sc = getSortCache(criteria);
	if (sc == NULL)
		return INVALID_GAMEID;

	return sc->sortedPosition(gameId, filter);
}
