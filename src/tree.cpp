//////////////////////////////////////////////////////////////////////
//
//  FILE:       tree.cpp
//              TreeCache class methods
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    2.4
//
//  Notice:     Copyright (c) 2000  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////


#include "common.h"
#include "position.h"
#include "tree.h"
#include <string.h>

void
initTreeNode (treeNodeT * tnode)
{
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


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// TreeCache::Init():
//
void
TreeCache::Init ()
{
    CacheSize = 0;
    NumInUse = 0;
    Cache = NULL;
    MostRecentIndex = 0;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// TreeCache::Delete():
//
void
TreeCache::Delete ()
{
    if (CacheSize > 0) {
        ASSERT (Cache != NULL);
        for (uint i=0; i < NumInUse; i++) {
            if (Cache[i].cfilter != NULL) { delete Cache[i].cfilter; }
        }
#ifdef WINCE
        my_Tcl_Free((char*) Cache);
#else
        delete[] Cache;
#endif
    }
    CacheSize = 0;
    NumInUse = 0;
    Cache = NULL;
    MostRecentIndex = 0;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// TreeCache::SetCacheSize():
//
void
TreeCache::SetCacheSize (uint size)
{
    if (CacheSize > 0) { Delete(); }
#ifdef WINCE
    Cache = (cachedTreeT*) my_Tcl_Alloc( sizeof(cachedTreeT [size]));
#else
    Cache = new cachedTreeT [size];
#endif

    CacheSize = size;
    NumInUse = 0;
    MostRecentIndex = 0;
    // Clear all the filters and nodes so they don't contain garbage:
    for (uint i=0; i < size; i++) {
        cachedTreeT * ctree = &(Cache[i]);
        ctree->cfilter = NULL;
        for (uint count = 0; count < MAX_TREE_NODES; count++) {
            initTreeNode (&(ctree->tree.node[count]));
        }
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// TreeCache::CacheResize():
//
void
TreeCache::CacheResize (uint size)
{
    // If cache size decreases, simply reset it
    if (CacheSize > size) {
      SetCacheSize(size);
      return;
    }

    cachedTreeT* oldCache = Cache;
    uint oldSize = CacheSize;

#ifdef WINCE
    Cache = (cachedTreeT*) my_Tcl_Alloc( sizeof(cachedTreeT [size]));
#else
    Cache = new cachedTreeT [size];
#endif

    CacheSize = size;
    // Clear all the filters and nodes so they don't contain garbage:
    for (uint i=0; i < size; i++) {
        cachedTreeT * ctree = &(Cache[i]);
        ctree->cfilter = NULL;
        for (uint count = 0; count < MAX_TREE_NODES; count++) {
            initTreeNode (&(ctree->tree.node[count]));
        }
    }

    // copy old data to new Cache
    for (uint i=0; i < oldSize; i++) {
        cachedTreeT * ctree = &(oldCache[i]);
        Cache[i] = *ctree;
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// TreeCache::Clear():
//
void
TreeCache::Clear ()
{
    for (uint i=0; i < NumInUse; i++) {
        if (Cache[i].cfilter != NULL) { delete Cache[i].cfilter; }
    }
    NumInUse = 0;
    MostRecentIndex = 0;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// TreeCache::Lookup():
//      Lookup a position in the tree cache.
//
cachedTreeT *
TreeCache::Lookup (Position * pos)
{
    for (uint i=0; i < NumInUse; i++) {
        if (Cache[i].toMove != pos->GetToMove()) { continue; }
        pieceT * board = pos->GetBoard();
        pieceT * board2 = Cache[i].board;
        bool found = true;
        for (squareT sq=A1; sq <= H8; sq++, board++, board2++) {
            if (*board != *board2) { found = false; break; }
        }
        if (found) { return &(Cache[i]); }
    }
    // Ended the search, no match:
    return NULL;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// TreeCache::LookupIndex():
//      Lookup a position in the tree cache, and return its index or -1
//      if it is not in the cache.
//
int
TreeCache::LookupIndex (Position * pos)
{
    for (uint i=0; i < NumInUse; i++) {
        if (Cache[i].toMove != pos->GetToMove()) { continue; }
        pieceT * board = pos->GetBoard();
        pieceT * board2 = Cache[i].board;
        bool found = true;
        for (squareT sq=A1; sq <= H8; sq++, board++, board2++) {
            if (*board != *board2) { found = false; break; }
        }
        if (found) { return (int)i; }
    }
    // Ended the search, no match:
    return -1;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// TreeCache::AddTree(): Add a positions tree data to the cache.
//
void
TreeCache::AddTree (uint index, Position * pos, treeT * pTree, Filter * filter)
{
    ASSERT (index < CacheSize);
    cachedTreeT * pct = &(Cache[index]);
    if (index < NumInUse) {
        ASSERT (pct->cfilter != NULL);
        delete pct->cfilter;
    }
    // Copy the tree structure:
    pct->tree = *pTree;
    // Copy the filter and board info:
    pct->cfilter = new CompressedFilter;
    pct->cfilter->CompressFrom (filter);
    pct->toMove = pos->GetToMove();
    memcpy (pct->board, pos->GetBoard(), 64);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// TreeCache::Add():
//      Add a position to the cache if applicable..
//
bool
TreeCache::Add (Position * pos, treeT * pTree, Filter * filter)
{
    // Is this tree in the cache already?
    int index = LookupIndex (pos);
    if (index >= 0) {
        // It is! Set the MostRecentIndex:
        MostRecentIndex = index;
        return true;
    }

    // Quick test for the common condition of the cache being full and
    // this tree having a count too low to be added:
    if (Policy == TREECACHE_Smallest  &&  NumInUse == CacheSize
        &&  pTree->totalCount < LowestTotal) {
        return false;
    }

    // Now, we add this tree to the end of the cache it is not full, or
    // if it is full, check if its count is high enough to be added.

    if (NumInUse == CacheSize) {
        // Cache is full!
        // If replacing the smallest, we know its total is high enough
        // to be added, from the test above.

        if (Policy == TREECACHE_Oldest) {
            // Replace the oldest node:
            MostRecentIndex = (MostRecentIndex+1) % CacheSize;
            AddTree (MostRecentIndex, pos, pTree, filter);
        } else {
            // Replace the smallest node:
            AddTree (LowestTotalIndex, pos, pTree, filter);

            // Find the NEW lowest total, the next tree to be evicted:
            LowestTotal = pTree->totalCount;
            for (uint i=0; i < CacheSize; i++) {
                if (Cache[i].tree.totalCount < LowestTotal) {
                    LowestTotal = Cache[i].tree.totalCount;
                    LowestTotalIndex = i;
                }
            }
        }

    } else {
        // Cache is not yet full. Add the position to the cache:
        AddTree (NumInUse, pos, pTree, filter);

        // Update LowestTotal if necessary:
        if (NumInUse == 0  ||  pTree->totalCount < LowestTotal) {
            LowestTotal = pTree->totalCount;
            LowestTotalIndex = NumInUse;
        }
        NumInUse++;
    }
    return true;
}

//////////////////////////////////////////////////////////////////////
//  EOF: tree.cpp
//////////////////////////////////////////////////////////////////////
