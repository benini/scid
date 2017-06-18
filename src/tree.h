/*
* Copyright (C) 1999 Shane Hudson
* Copyright (C) 2015 Fulvio Benini

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

#include "common.h"
#include "filter.h"
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
    static bool cmpTime(const cachedTreeT& a, const cachedTreeT& b) {
        return a.time_ < b.time_;
    }
};



// A TreeCache object stores a fixed number of positions and their
// tree data. The idea is that the common positions (the starting
// position, the basic opening positions like 1.e4, 1.d4, etc) will
// be have their tree information stored in a cache to save doing a
// position search.


class TreeCache {
    size_t NumInUse;
    cachedTreeT* Cache;
    size_t CacheSize;
    uint32_t counter_;

public:
    TreeCache()
    : NumInUse(0),
      Cache(NULL),
      CacheSize(0),
      counter_(0) {
    }
    ~TreeCache() {
        if (Cache) delete [] Cache;
    }

    void Clear() {
        NumInUse = 0;
        counter_ = 0;
    }
    size_t Size() {
        return CacheSize;
    }
    size_t UsedSize() {
        return NumInUse;
    }
    void CacheResize(size_t max_size) {
        if (max_size != CacheSize) {
            CacheSize = max_size;
            if (Cache) delete [] Cache;
            if (max_size == 0) Cache = NULL;
            else Cache = new cachedTreeT[max_size];
        }
        Clear();
    }

    const cachedTreeT* Lookup(Position* pos) {
        int idx = LookupIndex(pos);
        if (idx == -1) return NULL;
        return &(Cache[idx]);
    }
    bool Add(Position* pos, treeT* tree, Filter* filter);

private:
    TreeCache(const TreeCache&);
    void operator=(const TreeCache&);

    int LookupIndex(Position* pos);
};




//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// TreeCache::LookupIndex():
//      Lookup a position in the tree cache, and return its index or -1
//      if it is not in the cache.
//
inline int
TreeCache::LookupIndex (Position * pos)
{
    for (uint i=0; i < NumInUse; i++) {
        if (Cache[i].toMove_ != pos->GetToMove()) { continue; }

        const pieceT* board = pos->GetBoard();
        const pieceT* board2 = Cache[i].board_;
        bool found = true;
        for (squareT sq=A1; sq <= H8; sq++, board++, board2++) {
            if (*board != *board2) { found = false; break; }
        }
        if (found) {
            Cache[i].time_ = counter_++;
            return static_cast<int>(i);
        }
    }
    // Ended the search, no match:
    return -1;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// TreeCache::Add():
//      Add a position to the cache if applicable..
//
inline bool
TreeCache::Add (Position * pos, treeT * pTree, Filter * filter)
{
    ASSERT(LookupIndex(pos) == -1);

    if (NumInUse < CacheSize) {
        // Cache is not yet full. Add the position to the cache:
        Cache[NumInUse++].set(pos, pTree, filter, counter_++);
    } else {
        // Cache is full!
        // Replace the oldest node:
        cachedTreeT* end = Cache + CacheSize;
        cachedTreeT* replace = std::min_element(Cache, end, cachedTreeT::cmpTime);
        if (replace == end) return false;

        ASSERT(replace->time_ <= counter_);
        replace->set(pos, pTree, filter, counter_++);
    }
    return true;
}


#endif

//////////////////////////////////////////////////////////////////////
//  EOF: tree.h
//////////////////////////////////////////////////////////////////////

