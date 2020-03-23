/*
* Copyright (C) 1999 Shane Hudson
* Copyright (C) 2015-2020 Fulvio Benini

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

#ifndef SCID_TREE_H
#define SCID_TREE_H

#include "board_def.h"
#include "fullmove.h"
#include "hfilter.h"
#include "position.h"
#include <cmath>
#include <vector>
#include <algorithm>


//
// Our tree structures:
//

// MAX_TREE_NODES: Fixed maximum number of moves a treeT can store.
//    The number of played legal moves in a position rarely is over
//    20, so 60 is a sane limit.
//

#define MAX_TREE_NODES 60


struct TreeNode {
	FullMove move;
	gamenumT freq[NUM_RESULT_TYPES] = {}; // freq[0] is the total count.
	gamenumT eloCount = 0;          // Count of games with an Elo.
	gamenumT yearCount = 0;         // Count of games with year != 0.
	gamenumT expectedPerfCount = 0;
	unsigned long long eloSum = 0;  // Sum of Elos.
	unsigned long long yearSum = 0; // Sum of years.
	double expectedPerf = 0;

public:
	explicit TreeNode(FullMove m) : move(m) {
		if (expVect_[0] == 0) {
			for (int i = -800; i < 800; i++)
				expVect_[i + 800] = 1 / (1 + std::pow(10, i / 400.0));
		}
	}

	void add(resultT result, int eloW, int eloB, unsigned year) {
		static_assert(RESULT_None == 0);
		freq[0]++; // total count of games
		if (result != RESULT_None) {
			freq[result]++;
			double r = RESULT_SCORE[result] / 2.0;
			int eloDiff = eloB - eloW;
			if (eloDiff < 800 && eloDiff >= -800) {
				expectedPerf += r - expVect_[eloDiff + 800];
				expectedPerfCount++;
			}
		}
		auto elo = (move.getColor() == WHITE) ? eloW : eloB;
		if (elo > 0) {
			eloSum += elo;
			++eloCount;
		}
		if (year > 0) {
			yearSum += year;
			++yearCount;
		}
	}

	static auto cmp_ngames_desc() {
		return
		    [](auto const& a, auto const& b) { return a.freq[0] > b.freq[0]; };
	}

private:
	static double expVect_[1600];
};



// treeNodeT:
//    Stores the move data, frequency, score, results by result type,
//    and eco code of a single move played from a position.
//
struct treeNodeT {
    simpleMoveT sm;
    char        san[8];
    uint        freq [NUM_RESULT_TYPES];
    uint        total;      // Total count
    uint        score;      // Score for white, in points per 1000 games, so
                            // 55.1% would be a score of 551.
    ecoT        ecoCode;
    uint        eloCount;   // Count of games with an Elo.
    uint        eloSum;     // Sum of Elos.
    uint        perfCount;  // Count of games with an opponent Elo.
    uint        perfSum;    // Sum of opponent Elos.
    uint64_t    yearCount;  // Count of games with year != 0.
    uint64_t    yearSum;    // Sum of years.
};

inline void initTreeNode (treeNodeT * tnode) {
    tnode->freq[RESULT_White] = tnode->freq[RESULT_Black]
        = tnode->freq[RESULT_Draw] = tnode->freq[RESULT_None] = 0;
    for (uint i=0; i < 8; i++) { tnode->san[i] = 0; }
    tnode->total = 0;
    tnode->score = 0;
    tnode->ecoCode = 0;
    tnode->eloCount = 0;
    tnode->eloSum = 0;
    tnode->perfCount = 0;
    tnode->perfSum = 0;
    tnode->yearCount = 0;
    tnode->yearSum = 0;
}



// treeT:
//    Stores an array of tree nodes (each has a move, its frequency,
//    score and ECO code) for a certain position.
//
struct treeT {
    treeNodeT node [MAX_TREE_NODES];
    uint      moveCount;
    uint      totalCount;
};

//////////////////////////////////////////////////////////////////////
// CompressedFilter class:
//    Holds the same data as a filter, in compressed format.
//    Random access to individual values is not possible.
//    A CompressedFilter is created from, or restored to, a regular
//    filter with the methods CompressFrom() and UncompressTo().
class CompressedFilter {
	gamenumT CFilterSize = 0;
	gamenumT CFilterCount = 0;
	gamenumT CompressedLength = 0;
	byte* CompressedData = nullptr;

public:
	CompressedFilter() = default;
	CompressedFilter(CompressedFilter&&) = default;
	~CompressedFilter(void) { delete[] CompressedData; }

	void CompressFrom(Filter* filter);
	errorT UncompressTo(Filter* filter) const;

private:
	errorT Verify(Filter* filter);
};

// cachedTreeT:
//    Stores a board position and its associated tree of all moves
//    played at that position.
//
class cachedTreeT {
    pieceT board_[64];
    colorT toMove_;
    treeT tree_;
    CompressedFilter cfilter_;
    uint32_t time_;

    friend class TreeCache;

public:
    void set(Position* pos, treeT* tree, Filter* filter, uint32_t time) {
        std::copy(pos->GetBoard(), pos->GetBoard() + 64, board_);
        toMove_ = pos->GetToMove();
        tree_ = *tree;
        cfilter_.CompressFrom(filter);
        time_ = time;
    }
    errorT restoreFilter(Filter* filter) const {
        return cfilter_.UncompressTo(filter);
    }
    const treeT& getTree() const {
        return tree_;
    }
};



// A TreeCache object stores a fixed number of positions and their
// tree data. The idea is that the common positions (the starting
// position, the basic opening positions like 1.e4, 1.d4, etc) will
// be have their tree information stored in a cache to save doing a
// position search.
class TreeCache {
	std::vector<cachedTreeT> cache_;
	uint32_t counter_ = 0;

public:
	void Clear() { cache_.clear(); }
	size_t Size() { return cache_.capacity(); }
	size_t UsedSize() { return cache_.size(); }
	void CacheResize(size_t max_size) {
		cache_.clear();
		cache_.reserve(max_size);
	}

	const cachedTreeT* Lookup(Position* pos) {
		auto it = std::find_if(
		    cache_.begin(), cache_.end(), [pos](auto const& e) {
			    return pos->GetToMove() == e.toMove_ &&
			           std::equal(e.board_, e.board_ + 64, pos->GetBoard());
		    });
		if (it == cache_.end())
			return nullptr;

		it->time_ = counter_++;
		return &(*it);
	}

	void Add(Position* pos, treeT* pTree, Filter* filter) {
		ASSERT(!Lookup(pos));

		if (UsedSize() < Size()) {
			// Cache is not yet full. Add the position to the cache:
			cache_.emplace_back().set(pos, pTree, filter, counter_++);
		} else {
			// Cache is full!
			// Replace the oldest node:
			auto replace = std::min_element(
			    cache_.begin(), cache_.end(),
			    [](auto const& a, auto const& b) { return a.time_ < b.time_; });

			if (replace != cache_.end())
				replace->set(pos, pTree, filter, counter_++);
		}
	}
};


#endif

//////////////////////////////////////////////////////////////////////
//  EOF: tree.h
//////////////////////////////////////////////////////////////////////

