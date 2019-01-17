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
#include "containers.h"
#include "fastgame.h"
#include "game.h"
#include "index.h"
#include "namebase.h"
#include "tree.h"
#include <array>
#include <vector>
#include <memory>

class SortCache;


const gamenumT INVALID_GAMEID = 0xffffffff;

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

	scidBaseT();
	~scidBaseT();

	errorT Open(ICodecDatabase::Codec dbtype,
	            fileModeT mode,
	            const char* filename = 0,
	            const Progress& progress = Progress());

	errorT Close ();

	const std::string& getFileName() const { return fileName_; }
	bool isReadOnly() const { return fileMode_ == FMODE_ReadOnly; }
	gamenumT numGames() const { return idx->GetNumGames(); }

	/// Returns a vector of tag pairs containing extra information about the
	/// database (type, description, autoload, etc..)
	std::vector<std::pair<const char*, std::string> > getExtraInfo() const {
		return codec_->getExtraInfo();
	}

	/// Store an extra information about the database (type, description, etc..)
	errorT setExtraInfo(const char* tagname, const char* new_value) {
		// TODO: move the code to CodecMemory and CodecSCID4
		if (std::strcmp(tagname, "type") == 0)
			return idx->SetType(strGetUnsigned(new_value));

		if (codec_->getType() == ICodecDatabase::SCID4) {
			if (std::strcmp(tagname, "description") == 0)
				return idx->SetDescription(new_value);

			if (std::strcmp(tagname, "autoload") == 0)
				return idx->SetAutoLoad(strGetUnsigned(new_value));

			auto len = std::strlen(tagname);
			if (len == 5 && std::equal(tagname, tagname + 4, "flag")) {
				uint flagType = IndexEntry::CharToFlag(tagname[4]);
				if (flagType != 0 &&
				    idx->GetCustomFlagDesc(flagType) != nullptr)
					return idx->SetCustomFlagDesc(flagType, new_value);
			}
		}
		return ERROR_CodecUnsupFeat;
	}

	const IndexEntry* getIndexEntry(gamenumT g) const {
		return idx->GetEntry(g);
	}
	const IndexEntry* getIndexEntry_bounds(gamenumT g) const {
		if (g < numGames()) return getIndexEntry(g);
		return 0;
	}
	const NameBase* getNameBase() const {
		return nb_;
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
	errorT getGame(const IndexEntry& ie, Game& dest) const {
		ByteBuffer buf(0);
		auto res = getGame(&ie, &buf);
		return (res != OK) ? res : dest.Decode(&buf, GAME_DECODE_ALL);
	}

	errorT importGame(const scidBaseT* srcBase, uint gNum);
	errorT importGames(const scidBaseT* srcBase, const HFilter& filter,
	                   const Progress& progress);
	errorT importGames(ICodecDatabase::Codec dbtype, const char* filename,
	                   const Progress& progress, std::string& errorMsg);

	/**
	 * Add or replace a game into the database.
	 * @param game: valid pointer to a Game object with the data of the game.
	 * @param replacedGameId: id of the game to replace.
	 *                        If >= numGames(), a new game will be added.
	 * @returns OK if successful or an error code.
	 */
	errorT saveGame(Game* game, gamenumT replacedGameId = INVALID_GAMEID);
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
	 * A Filter is a selection of games, usually obtained searching the
	 * database. A new Filter is created calling the function newFilter()
	 * and must be released calling the function deleteFilter().
	 * A composed Filter is a special construct created combining two Filters
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
		if (nameFreq_[nt].size() == 0)
			nameFreq_ = idx->calcNameFreq(*getNameBase());
		return nameFreq_[nt][id];
	}

	errorT getCompactStat(unsigned long long* n_deleted,
	                      unsigned long long* n_unused,
	                      unsigned long long* n_sparse,
	                      unsigned long long* n_badNameId);
	errorT compact(const Progress& progress);


	/**
	 * Increment the reference count of a SortCache object matching @e criteria.
	 * @param criteria: the list of fields by which games will be ordered.
	 *                  Each field should be followed by '+' to indicate an
	 *                  ascending order or by '-' for a descending order.
	 * @returns a pointer to a SortCache object in case of success, NULL
	 * otherwise.
	 */
	SortCache* createSortCache(const char* criteria);

	/**
	 * Decrement the reference count of the SortCache object matching @e
	 * criteria. Cached objects with refCount <= 0 are destroyed independently
	 * from the value of @e criteria.
	 * @param criteria: the list of fields by which games will be ordered.
	 *                  Each field should be followed by '+' to indicate an
	 *                  ascending order or by '-' for a descending order.
	 */
	void releaseSortCache(const char* criteria);

	/**
	 * Retrieve a list of ordered game indexes sorted by @e criteria.
	 * This function will be much faster if a SortCache object matching @e
	 * criteria already exists (previously created with @e createSortCache).
	 * @param criteria: the list of fields by which games will be ordered.
	 *                  Each field should be followed by '+' to indicate an
	 *                  ascending order or by '-' for a descending order.
	 * @param start:    the offset of the first row to return.
	 *                  The offset of the initial row is 0.
	 * @param count:    maximum number of rows to return.
	 * @param filter:   a reference to a valid (!= NULL) HFilter object.
	 *                  Games not included into the filter will be ignored.
	 * @param[out] destCont: valid pointer to an array where the sorted list of
	 *                       games will be stored (should be able to contain at
	 *                       least @e count elements).
	 * @returns the number of games' ids stored into @e destCont.
	 */
	size_t listGames(const char* criteria, size_t start, size_t count,
	                 const HFilter& filter, gamenumT* destCont);

	/**
	 * Get the sorted position of a game.
	 * This function will be much faster if a SortCache object matching @e
	 * criteria already exists (previously created with @e createSortCache).
	 * @param criteria: the list of fields by which games will be ordered.
	 *                  Each field should be followed by '+' to indicate an
	 *                  ascending order or by '-' for a descending order.
	 * @param filter:   a reference to a valid (!= NULL) HFilter object.
	 *                  Games not included into the filter will be ignored.
	 * @param gameId:   the id of the game.
	 * @returns the sorted position of @e gameId.
	 */
	size_t sortedPosition(const char* criteria, const HFilter& filter,
	                      gamenumT gameId);

	void setDuplicates(uint* duplicates) {
		if (duplicates_ != NULL) { delete[] duplicates_; duplicates_ = NULL; }
		duplicates_ = duplicates;
	}
	uint getDuplicates(gamenumT gNum) {
		return (duplicates_ == NULL) ? 0 : duplicates_[gNum];
	}

	/**
	 * Transform the IndexEntries of the games included in @e hfilter.
	 * The @e entry_op must accept a IndexEntry& parameter and return true when
	 * the IndexEntry was modified.
	 * @param hfilter:  HFilter containing the games to be transformed.
	 * @param progress: a Progress object used for GUI communications.
	 * @param entry_op: operator that will be applied to games' IndexEntry.
	 * @returns a std::pair containing OK (or an error code) and the number of
	 * games modified.
	 */
	template <typename TOper>
	std::pair<errorT, size_t>
	transformIndex(HFilter hfilter, const Progress& progress, TOper entry_op) {
		beginTransaction();
		auto res = transformIndex_(hfilter, progress, entry_op);
		auto err = endTransaction();
		res.first = (res.first == OK) ? err : res.first;
		return res;
	}

	/**
	 * Transform the names of the games included in @e hfilter.
	 * The function @e getID maps all the old idNumberT to the new idNumberT.
	 * It's invoked for each game and must accept as parameters a idNumberT and
	 * a const IndexEntry&; must return the (eventually different) idNumberT.
	 * @param nt:       type of the names to be modified.
	 * @param hfilter:  HFilter containing the games to be transformed.
	 * @param progress: a Progress object used for GUI communications.
	 * @param newNames: optional vector of names to be added to the database.
	 * @param fnInit:   function that is invoked before beginning the
	 *                  transformation; must accept a vector that contains the
	 *                  idNumberTs of the names in @e newNames.
	 * @param getID:    function that maps the old idNumberTs to the new ones.
	 * @returns a std::pair containing OK (or an error code) and the number of
	 * games modified.
	 */
	template <typename TInitFunc, typename TMapFunc>
	std::pair<errorT, size_t>
	transformNames(nameT nt, HFilter hfilter, const Progress& progress,
	               const std::vector<std::string>& newNames, TInitFunc fnInit,
	               TMapFunc getID);

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
	 *                INVALID_GAMEID to update all games.
	 * @returns OK if successful or an error code.
	 */
	errorT endTransaction(gamenumT gameId = INVALID_GAMEID);

public:
	Index* idx;       // the Index file in memory for this base.
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
	std::pair<Game*, bool> deprecated_push_pop;

private:
	std::unique_ptr<ICodecDatabase> codec_;
	NameBase* nb_;
	std::string fileName_; // File name without ".si" suffix
	fileModeT fileMode_; // Read-only, write-only, or both.
	std::vector< std::pair<std::string, Filter*> > filters_;
	mutable Stats* stats_;
	std::array<std::vector<int>, NUM_NAME_TYPES> nameFreq_;
	uint* duplicates_; // For each game: idx of duplicate game + 1 (0 if there is no duplicate).
	std::vector< std::pair<std::string, SortCache*> > sortCaches_;

private:
	void clear();
	errorT importGameHelper(const scidBaseT* sourceBase, uint gNum);

	Filter* fetchFilter(const std::string& filterId) const;
	HFilter getFilterHelper(const std::string& filterId,
	                        bool unmasked = false) const;
	SortCache* getSortCache(const char* criteria);

	/**
	 * Apply a transform operator to games' IndexEntry included in @e hfilter.
	 * The @entry_op should accept a IndexEntry& parameter and return true when
	 * the IndexEntry was modified.
	 * @param hfilter:  HFilter containing the games to be transformed.
	 * @param progress: a Progress object used for GUI communications.
	 * @param entry_op: operator that will be applied to games' IndexEntry.
	 * @returns a std::pair containing OK (or an error code) and the number of
	 * games modified.
	 */
	template <typename TOper>
	std::pair<errorT, size_t>
	transformIndex_(HFilter hfilter, const Progress& progress, TOper entry_op) {
		size_t nCorrections = 0;
		size_t iProg = 0;
		size_t totProg = hfilter->size();
		for (auto& gnum : hfilter) {
			if ((++iProg % 8192 == 0) && !progress.report(iProg, totProg))
				return std::make_pair(ERROR_UserCancel, nCorrections);

			IndexEntry newIE = *getIndexEntry(gnum);
			if (!entry_op(newIE))
				continue;

			auto err = codec_->saveIndexEntry(newIE, gnum);
			if (err != OK)
				return std::make_pair(err, nCorrections);

			++nCorrections;
		}
		return std::make_pair(OK, nCorrections);
	}
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
	errorT res = idx->WriteEntry(ie, gNum);
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


template <typename TInitFunc, typename TMapFunc>
std::pair<errorT, size_t>
scidBaseT::transformNames(nameT nt, HFilter hfilter, const Progress& progress,
                          const std::vector<std::string>& newNames,
                          TInitFunc initFunc, TMapFunc getID) {
	beginTransaction();

	std::vector<idNumberT> nameIDs(newNames.size());
	auto it = nameIDs.begin();
	for (auto& name : newNames) {
		auto id = codec_->addName(nt, name.c_str());
		if (id.first != OK) {
			endTransaction();
			return std::make_pair(id.first, size_t(0));
		}
		*it++ = id.second;
	}

	initFunc(nameIDs);

	auto fnGet = [](nameT nt, const IndexEntry& ie) {
		switch (nt) { // clang-format off
		case NAME_PLAYER: return ie.GetWhite();
		case NAME_EVENT:  return ie.GetEvent();
		case NAME_SITE:   return ie.GetSite();
		} // clang-format on
		ASSERT(nt == NAME_ROUND);
		return ie.GetRound();
	};
	auto fnSet = [](nameT nt, IndexEntry& ie, idNumberT newID) {
		switch (nt) { // clang-format off
		case NAME_PLAYER: return ie.SetWhite(newID);
		case NAME_EVENT:  return ie.SetEvent(newID);
		case NAME_SITE:   return ie.SetSite(newID);
		} // clang-format on
		ASSERT(nt == NAME_ROUND);
		return ie.SetRound(newID);
	};
	auto res = transformIndex_(hfilter, progress, [&](IndexEntry& ie) {
		const IndexEntry& ie_const = ie;
		auto oldID = fnGet(nt, ie);
		auto newID = getID(oldID, ie_const);
		bool b1 = (oldID != newID);
		idNumberT newBlack = 0;
		bool b2 = (nt == NAME_PLAYER);
		if (b2) {
			auto oldBlack = ie.GetBlack();
			newBlack = getID(oldBlack, ie_const);
			b2 = (oldBlack != newBlack);
		}
		if (!b1 && !b2)
			return false;

		if (b1)
			fnSet(nt, ie, newID);
		if (b2)
			ie.SetBlack(newBlack);
		return true;
	});

	auto err = endTransaction();
	res.first = (res.first == OK) ? err : res.first;
	return res;
}

#endif
