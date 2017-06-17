/*
# Copyright (C) 2014-2016 Fulvio Benini

* This file is part of Scid (Shane's Chess Information Database).
*
* Scid is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation.
*
* Scid is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Scid. If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef SCIDBASE_H
#define SCIDBASE_H

#include "bytebuf.h"
#include "codec.h"
#include "fastgame.h"
#include "game.h"
#include "index.h"
#include "namebase.h"
#include "tree.h"
#include "undoredo.h"
#include <vector>

struct scidBaseT {
	struct Stats {
		uint flagCount[IndexEntry::IDX_NUM_FLAGS]; // Num of games with each flag set.
		dateT minDate;
		dateT maxDate;
		uint64_t nYears;
		uint64_t sumYears;
		uint nResults [NUM_RESULT_TYPES];
		uint nRatings;
		uint64_t sumRatings;
		uint minRating;
		uint maxRating;

		Stats(const scidBaseT* dbase);

		struct Eco {
			uint count;
			uint results [NUM_RESULT_TYPES];

			Eco();
		};
		const Eco* getEcoStats(const char* ecoStr) const;

	private:
		Eco ecoEmpty_;
		Eco ecoValid_;
		Eco ecoStats_ [(1 + (1<<16)/131)*27];
		Eco ecoGroup1_[(1 + (1<<16)/131)/100];
		Eco ecoGroup2_[(1 + (1<<16)/131)/10];
		Eco ecoGroup3_[(1 + (1<<16)/131)];
	};

	struct TreeStat {
		colorT toMove;
		std::string SAN;
		int resultW, resultD, resultB;
		double exp;
		int ngames, nexp;

	public:
		TreeStat();
		void add(int result, int eloW, int eloB);
		bool operator<(const TreeStat& cmp) const { return ngames > cmp.ngames; }

	private:
		static double expVect_[1600];
	};

	scidBaseT() { Init(); }
	~scidBaseT();

	errorT Open(ICodecDatabase::Codec dbtype,
	            fileModeT mode,
	            const char* filename = 0,
	            const Progress& progress = Progress());

	errorT Close ();

	const std::string& getFileName() const { return fileName_; }
	bool isReadOnly() const { return fileMode_ == FMODE_ReadOnly; }
	gamenumT numGames() const { return idx->GetNumGames(); }
	errorT getExtraInfo(const std::string& tagname, std::string* res) const;
	errorT setExtraInfo(const std::string& tagname, const char* new_value);

	const IndexEntry* getIndexEntry(gamenumT g) const {
		return idx->GetEntry(g);
	}
	const IndexEntry* getIndexEntry_bounds(gamenumT g) const {
		if (g < numGames()) return getIndexEntry(g);
		return 0;
	}
	const NameBase* getNameBase() const {
		return nb;
	}
	FastGame getGame(const IndexEntry* ie) const {
		uint length = ie->GetLength();
		const byte* b = codec_->getGameData(ie->GetOffset(), length);
		if (b == 0) length = 0; // Error
		return FastGame::Create(b, b + length);
	}
	errorT getGame(const IndexEntry* ie, ByteBuffer* destBuf) const {
		uint length = ie->GetLength();
		const byte* b = codec_->getGameData(ie->GetOffset(), length);
		if (b == 0) return ERROR_FileRead;
		// The data for the game is not actually copied into the bytebuffer, which would
		// be slower and a waste of time if the bytebuffer is not going to be modified.
		destBuf->ProvideExternal(const_cast<byte*>(b), length);
		return OK;
	}

	struct GamePos {
		unsigned int RAVdepth;
		unsigned int RAVnum;
		std::string FEN;
		std::vector<int> NAGs;
		std::string comment;
		std::string lastMoveSAN;
	};
	errorT getGame(const IndexEntry* ie, std::vector<GamePos>& dest);

	errorT importGame(const scidBaseT* srcBase, uint gNum);
	errorT importGames(const scidBaseT* srcBase, const HFilter& filter, const Progress& progress);
	template <class T, class P>
	errorT importGames(T& codec, const P& progress, uint& nImported, std::string& errorMsg);

	/**
	 * Add or replace a game into the database.
	 * @param game: valid pointer to a Game object with the data of the game.
	 * @param replacedgameId: id of the game to replace.
	 *                        If >= numGames(), a new game will be added.
	 * @returns OK if successful or an error code.
	 */
	errorT saveGame(Game* game, gamenumT replacedGameId = IDX_NOT_FOUND);
	// TODO: private:
	errorT saveGameHelper(Game* game, gamenumT gameId);


	bool getFlag(uint flag, uint gNum) const {
		return idx->GetEntry(gNum)->GetFlag (flag);
	}
	errorT setFlag(bool value, uint flag, uint gNum);
	errorT setFlag(bool value, uint flag, const HFilter& filter);
	errorT invertFlag(uint flag, uint gNum);
	errorT invertFlag(uint flag, const HFilter& filter);

	/**
	 * Filters
	 * @filterId: unique identifier of a Filter
	 *
	 * A Filter is a selection of games, usually obtained searching the
	 * database. A new Filter is created calling the function newFilter()
	 * and must be released calling the function deleteFilter().
	 * A composed Filter is a special contruct created combining two Filters
	 * and includes only the games contained in both Filters.
	 * A composed Filter should NOT be released.
	 */
	std::string newFilter();
	std::string composeFilter(const std::string& mainFilter,
	                          const std::string& maskFilter) const;
	void deleteFilter(const char* filterId);
	HFilter getFilter(const std::string& filterId) const {
		return getFilterHelper(filterId, false);
	}
	HFilter getMainFilter(const std::string& filterId) const {
		return getFilterHelper(filterId, true);
	}

	const Stats& getStats() const;
	std::vector<scidBaseT::TreeStat> getTreeStat(const HFilter& filter);
	uint getNameFreq (nameT nt, idNumberT id) {
		if (nameFreq_[nt].size() == 0) idx->calcNameFreq(*nb, nameFreq_);
		return nameFreq_[nt][id];
	}

	errorT getCompactStat(uint* n_deleted,
	                      uint* n_unused,
	                      uint* n_sparse,
	                      uint* n_badNameId);
	errorT compact(const Progress& progress);

	SortCache* CreateSortCache(const char* criteria) const {
		return idx->CreateSortCache(nb, criteria);
	}
	void FreeSortCache(const char* criteria) const {
		return idx->FreeSortCache(criteria);
	}
	errorT GetRange(const char* criteria, uint idx, uint count,
	                const HFilter& filter, uint* result) const {
		return this->idx->GetRange(nb, criteria, idx, count, filter, result);
	}
	uint GetRangeLocation(const char* criteria, const HFilter& filter,
	                      uint gnumber) const {
		return idx->GetRangeLocation(nb, criteria, filter, gnumber);
	}
	uint GetRangeLocation(const char* criteria, const HFilter& filter,
	                      const char* text, uint start, bool forward) const {
		return idx->GetRangeLocation(nb, criteria, filter, text, start, forward);
	}

	void setDuplicates(uint* duplicates) {
		if (duplicates_ != NULL) { delete[] duplicates_; duplicates_ = NULL; }
		duplicates_ = duplicates;
	}
	uint getDuplicates(gamenumT gNum) {
		return (duplicates_ == NULL) ? 0 : duplicates_[gNum];
	}

	// TODO: private:
	/**
	 * This function must be called before modifying the games of the database.
	 * Currently this function do not guarantees that the database is not altered
	 * in case of errors.
	 */
	void beginTransaction();

	// TODO: private:
	/**
	 * Update caches and flush the database's files.
	 * This function must be called after changing one or more games.
	 * @param gameId: id of the modified game
	 *                IDX_NOT_FOUND to update all games.
	 * @returns OK if successful or an error code.
	 */
	errorT endTransaction(gamenumT gameId = IDX_NOT_FOUND);

public:
	Index* idx;       // the Index file in memory for this base.
	NameBase* nb;      // the NameBase file in memory.
	bool inUse;       // true if the database is open (in use).
	treeT tree;
	TreeCache treeCache;
	ByteBuffer* bbuf;
	Filter* dbFilter;
	Filter* treeFilter;


	//TODO: this vars do not belong to scidBaseT class
	Game* game;       // the active game for this base.
	int gameNumber;   // game number of active game.
	bool gameAltered; // true if game is modified
	UndoRedo<Game, 100> gameAlterations;

private:
	ICodecDatabase* codec_;
	std::string fileName_; // File name without ".si" suffix
	fileModeT fileMode_; // Read-only, write-only, or both.
	std::vector< std::pair<std::string, Filter*> > filters_;
	mutable Stats* stats_;
	std::vector <int> nameFreq_ [NUM_NAME_TYPES];
	uint* duplicates_; // For each game: idx of duplicate game + 1 (0 if there is no duplicate).

	scidBaseT(const scidBaseT&);
	scidBaseT& operator=(const scidBaseT&);
	void Init();
	void clear();
	GamePos makeGamePos(Game& game, unsigned int ravNum);
	errorT importGameHelper(const scidBaseT* sourceBase, uint gNum);

	void extendFilters();
	Filter* fetchFilter(const std::string& filterId) const;
	HFilter getFilterHelper(const std::string& filterId,
	                        bool unmasked = false) const;
};

inline void scidBaseT::TreeStat::add(int result, int eloW, int eloB) {
	ngames++;
	double r = 0;
	switch (result) {
		case RESULT_White: resultW++; r = 1; break;
		case RESULT_Draw: resultD++; r = 0.5; break;
		case RESULT_Black: resultB++; break;
		default: return;
	}
	if (eloW == 0 || eloB == 0) return;
	int eloDiff = eloB - eloW;
	if (eloDiff < 800 && eloDiff >= -800) {
		exp += r - expVect_[eloDiff+800];
		nexp++;
	}
}

template <class T, class P>
inline errorT scidBaseT::importGames(T& codec, const P& progress, uint& nImported, std::string& errorMsg) {
	beginTransaction();
	errorT res;
	Game g;
	nImported = 0;
	while ((res = codec.parseNext(&g)) != ERROR_NotFound) {
		if (res != OK) continue;

		res = saveGameHelper(&g, IDX_NOT_FOUND);
		if (res != OK) break;

		if ((++nImported % 200) == 0) {
			std::pair<size_t, size_t> count = codec.parseProgress();
			if (!progress.report(count.first, count.second)) {
				res = ERROR_UserCancel;
				break;
			}
		}
	}

	errorMsg = codec.parseErrors();
	endTransaction();
	progress.report(1,1);

	if (res == ERROR_NotFound) res = OK;
	return res;
}

inline errorT scidBaseT::invertFlag(uint flag, uint gNum) {
	return setFlag(! getFlag(flag, gNum), flag, gNum);
}

inline errorT scidBaseT::invertFlag(uint flag, const HFilter& filter) {
	errorT res = OK;
	for (gamenumT i = 0, n = numGames(); i < n; i++) {
		if (filter != 0 && filter->get(i) == 0) continue;
		res = invertFlag(flag, i);
		if (res != OK) return res;
	}
	return res;
}

inline errorT scidBaseT::setFlag(bool value, uint flag, uint gNum){
	ASSERT(gNum < idx->GetNumGames());
	IndexEntry* ie = idx->FetchEntry (gNum);
	ie->SetFlag (flag, value);
	errorT res = idx->WriteEntry (ie, gNum, false);
	if (stats_ != NULL) { delete stats_; stats_ = NULL;}
	// TODO: necessary only for sortcaches with SORTING_deleted (and SORTING_flags when implemented)
	// idx->IndexUpdated(gNum);
	return res;
}

inline errorT scidBaseT::setFlag(bool value, uint flag, const HFilter& filter) {
	errorT res = OK;
	for (gamenumT gNum = 0, n = numGames(); gNum < n; gNum++) {
		if (filter != 0 && filter->get(gNum) == 0) continue;
		res = setFlag(value, flag, gNum);
		if (res != OK) return res;
	}
	return res;
}



#endif

