//////////////////////////////////////////////////////////////////////
//
//  FILE:       tree.h
//              Tree and Tree Cache management.
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    2.4
//
//  Notice:     Copyright (c) 1999  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////


#ifndef SCID_TREE_H
#define SCID_TREE_H

#include "common.h"
#include "filter.h"
#include <stdio.h>


//
// Our tree structures:
//

// MAX_TREE_NODES: Fixed maximum number of moves a treeT can store.
//    The number of played legal moves in a position rarely is over
//    20, so 60 is a sane limit.
//

#ifdef WINCE
#define MAX_TREE_NODES 20
#else
#define MAX_TREE_NODES 60
#endif

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
    unsigned long long        yearCount;  // Count of games with year != 0.
    unsigned long long        yearSum;    // Sum of years.
};

void initTreeNode (treeNodeT * tnode);


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
struct cachedTreeT {
    squareT board[64];
    colorT  toMove;
    treeT   tree;
    CompressedFilter * cfilter;
};


// treeCachePolicyT:
//    Cache replacement policy. Smallest (the node with the lowest
//    observed frequency) is used for a main disk-file cache, while
//    Oldest is used for a backup memory-only cache.
//
enum treeCachePolicyT {
    TREECACHE_Smallest, TREECACHE_Oldest
};


// A TreeCache object stores a fixed number of positions and their
// tree data. The idea is that the common positions (the starting
// position, the basic opening positions like 1.e4, 1.d4, etc) will
// be have their tree information stored in a cache to save doing a
// position search.


class TreeCache {

  private:
    uint           CacheSize;
    cachedTreeT *  Cache;
    uint           NumInUse;

    treeCachePolicyT Policy;

    uint   MostRecentIndex;   // Index of most recently added item.
    uint   LowestTotal;       // The lowest total of all cached trees.
    uint   LowestTotalIndex;  // Index of the tree with the lowest totalCount.
                              // It will be the next tree evicted.

    void   AddTree (uint index, Position * pos, treeT * tree, Filter * filter);
  public:
#ifdef WINCE
  void* operator new(size_t sz) {
    void* m = my_Tcl_Alloc(sz);
    return m;
  }
  void operator delete(void* m) {
    my_Tcl_Free((char*)m);
  }
  void* operator new [] (size_t sz) {
    void* m = my_Tcl_AttemptAlloc(sz);
    return m;
  }

  void operator delete [] (void* m) {
    my_Tcl_Free((char*)m);
  }

#endif  
    TreeCache() { Init(); }
    ~TreeCache() { Delete(); }

    void Init();
    void Delete();
    void SetCacheSize (uint size);
    void CacheResize (uint size);
    uint Size() { return CacheSize; }
    uint UsedSize() { return NumInUse; }
    void Clear();

    void SetPolicy (treeCachePolicyT policy) { Policy = policy; }
    treeCachePolicyT GetPolicy() { return Policy; }

    cachedTreeT * Lookup (Position * pos);
    int  LookupIndex (Position * pos);
    bool Add (Position * pos, treeT * tree, Filter * filter);

    errorT WriteFile (const char * fname);
    errorT ReadFile (const char * fname);
};

#endif

//////////////////////////////////////////////////////////////////////
//  EOF: tree.h
//////////////////////////////////////////////////////////////////////

