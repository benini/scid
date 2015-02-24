/*
# Copyright (C) 2014 Fulvio Benini

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

#include "index.h"
#include "namebase.h"
#include "gfile.h"
#include "undoredo.h"
#include "game.h"
#include "tree.h"
#include <vector>

class SpellChecker;

struct scidBaseT {
	struct Stats {
		uint flagCount [IDX_NUM_FLAGS]; // Num of games with each flag set.
		dateT minDate;
		dateT maxDate;
		uint64_t nYears;
		uint64_t sumYears;
		uint nResults [NUM_RESULT_TYPES];
		uint nRatings;
		uint64_t sumRatings;
		uint minRating;
		uint maxRating;
		struct Eco {
			uint count;
			uint results [NUM_RESULT_TYPES];
		};
		Eco ecoCount0 [1];
		Eco ecoCount1 [5];
		Eco ecoCount2 [50];
		Eco ecoCount3 [500];
		Eco ecoCount4 [500*26];
	};

	struct TreeStat {
		colorT toMove;
		std::string SAN;
		int resultW, resultD, resultB;
		double exp;
		int ngames, nexp;

		TreeStat();
		void add(int result, int eloW, int eloB) {
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
		bool operator<(const TreeStat& cmp) const { return ngames > cmp.ngames; }

		private:
		static double expVect_[1600];
	};

	scidBaseT() { Init(); }
	~scidBaseT();

	errorT Open (fileModeT mode = FMODE_Memory,
	             const char* filename = "",
	             bool create = true,
	             SpellChecker* spell = 0,
	             void (progressFn)(void*, unsigned int, unsigned int) = 0,
	             void* progressData = 0);
	errorT Close ();

	std::string newFilter();
	void deleteFilter(Filter* filter);
	Filter* getFilter(const char* filterName);
	Filter* getFilter(uint idx) {
		if (idx == 0) return dbFilter;
		if (idx == 1) return treeFilter;
		idx -= 2;
		if (idx >= filters_.size()) return 0;
		return filters_[idx].second;
	}

	const char* getFileName() const { return fileName; }
	bool isReadOnly() const { return (fileMode==FMODE_ReadOnly); }
	uint numGames() const { return idx->GetNumGames(); }

	const IndexEntry* getIndexEntry(gameNumberT g) const {
		return idx->GetEntry(g);
	}
	const NameBase* getNameBase() const {
		return nb;
	}
	FastGame getGame(const IndexEntry* ie) const {
		return gfile->ReadGame(ie->GetOffset(), ie->GetLength());
	}
	errorT getGame(const IndexEntry* ie, ByteBuffer* bb) const {
		return gfile->ReadGame(bb, ie->GetOffset(), ie->GetLength());
	}

	errorT addGames(scidBaseT* sourceBase,
	                Filter* filter,
	                bool (progressFn)(void*, unsigned int, unsigned int),
	                void* progressData);
	errorT addGame(scidBaseT* sourceBase, uint gNum);
	errorT saveGame(Game* game, bool clearCache, int idx = -1);

	bool getFlag(uint flag, uint gNum) const {
		return idx->GetEntry(gNum)->GetFlag (flag);
	}
	errorT setFlag(bool value, uint flag, uint gNum){
		ASSERT(gNum < idx->GetNumGames());
		IndexEntry* ie = idx->FetchEntry (gNum);
		ie->SetFlag (flag, value);
		errorT res = idx->WriteEntries (ie, gNum, false);
		validStats_ = false;
		// TODO: necessary only for sortcaches with SORTING_deleted (and SORTING_flags when implemented)
		// idx->IndexUpdated(gNum);
		return res;
	}
	errorT setFlag(bool value, uint flag, Filter* filter = 0) {
		errorT res = OK;
		for (uint gNum = 0, n = numGames(); gNum < n; gNum++) {
			if (filter && filter->Get(gNum) == 0) continue;
			res = setFlag(value, flag, gNum);
			if (res != OK) return res;
		}
		return res;
	}
	errorT invertFlag(uint flag, uint gNum) {
		return setFlag(! getFlag(flag, gNum), flag, gNum);
	}
	errorT invertFlag(uint flag, Filter* filter = 0) {
		errorT res = OK;
		for (uint gNum = 0, n = numGames(); gNum < n; gNum++) {
			if (filter && filter->Get(gNum) == 0) continue;
			res = invertFlag(flag, gNum);
			if (res != OK) return res;
		}
		return res;
	}

	const Stats* getStats() const;
	std::vector<scidBaseT::TreeStat> getTreeStat(Filter* filter);
	uint getNameFreq (nameT nt, idNumberT id) {
		if (nameFreq_[nt].size() == 0) calcNameFreq();
		if (id >= nameFreq_[nt].size()) return 0;
		return nameFreq_[nt][id];
	}

	errorT getCompactStat(uint* n_deleted,
	                      uint* n_unused,
	                      uint* n_sparse,
	                      uint* n_badNameId);
	errorT compact(SpellChecker* spellChk,
	               bool (progressFn)(void*, unsigned int, unsigned int),
	               void* progressData);

	SortCache* CreateSortCache(const char* criteria) const {
		return idx->CreateSortCache(nb, criteria);
	}
	void FreeSortCache(const char* criteria) const {
		return idx->FreeSortCache(criteria);
	}
	errorT GetRange(const char *criteria, uint idx, uint count, Filter *filter, uint *result) const {
		return this->idx->GetRange(nb, criteria, idx, count, filter, result);
	}
	uint GetRangeLocation(const char *criteria, Filter *filter, uint gnumber) const {
		return idx->GetRangeLocation(nb, criteria, filter, gnumber);
	}
	uint GetRangeLocation(const char *criteria, Filter *filter,	const char* text, uint start, bool forward) const {
		return idx->GetRangeLocation(nb, criteria, filter, text, start, forward);
	}

	//TODO: private:
	/* clearCaches:
	    After changing one or more games this function MUST be called
	    (to update all the caches and write the namebase file and index header)
	    - gNum: id of the game changed (IDX_NOT_FOUND update all the games)
	*/
	errorT clearCaches(uint gNum = IDX_NOT_FOUND, bool writeFiles = true);
	void clearStats() { validStats_ = false; };

	Index* idx;       // the Index file in memory for this base.
	NameBase* nb;      // the NameBase file in memory.
	bool inUse;       // true if the database is open (in use).
	treeT tree;
	TreeCache* treeCache;
	TreeCache* backupCache;
	ByteBuffer* bbuf;
	TextBuffer* tbuf;
	Filter* dbFilter;
	Filter* treeFilter;
	uint* duplicates; // For each game: idx of duplicate game + 1 (0 if there is no duplicate).

	//TODO: this vars do not belong to scidBaseT class
	Game* game;       // the active game for this base.
	int gameNumber;   // game number of active game.
	bool gameAltered; // true if game is modified
	UndoRedo<Game, 30> gameAlterations;

private:
	GFile* gfile;
	fileModeT fileMode; // Read-only, write-only, or both.
	std::vector< std::pair<std::string, Filter*> > filters_;
	fileNameT fileName; // File name without ".si" suffix
	mutable bool validStats_;
	mutable Stats* stats_;
	std::vector <int> nameFreq_ [NUM_NAME_TYPES];

	scidBaseT(const scidBaseT&);
	scidBaseT& operator=(const scidBaseT&);
	void Init();
	void clear();
	errorT addGame_ (scidBaseT* sourceBase, uint gNum);
	errorT saveGame_(IndexEntry* iE, ByteBuffer* bbuf,  int oldIdx = -1);
	void calcNameFreq ();
};

#endif

