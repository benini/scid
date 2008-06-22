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

// Include header file for memcpy():
#ifdef WIN32
#  include <memory.h>
#else
#  include <string.h>
#endif


// TREEFILE_MAGIC:
//    The four-byte identifier at the start of a tree-cache file.
//    This value is updated whenever a non-backward-compatible
//    change is made to the tree file format.
//    Last change: version 2.4.
const uint TREEFILE_MAGIC = ('s' << 24) | ('t' << 16) | ('c' << 8) | 24;


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
    // Clear all the filters and nodes so they dont contain garbage:
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
    // Clear all the filters and nodes so they dont contain garbage:
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

errorT
TreeCache::WriteFile (const char * fname)
{
#ifdef WINCE
    /*FILE **/Tcl_Channel  fp;
    fileNameT fullname;
    strCopy (fullname, fname);
    strAppend (fullname, TREEFILE_SUFFIX);

//    fp = fopen (fullname, "wb");
    fp = my_Tcl_OpenFileChannel(NULL, fullname, "w", 0666);
    if (fp == NULL) { return ERROR_FileOpen; }
 my_Tcl_SetChannelOption(NULL, fp, "-encoding", "binary");
 my_Tcl_SetChannelOption(NULL, fp, "-translation", "binary");

#else
    FILE * fp;
    fileNameT fullname;
    strCopy (fullname, fname);
    strAppend (fullname, TREEFILE_SUFFIX);

    fp = fopen (fullname, "wb");
    if (fp == NULL) { return ERROR_FileOpen; }
#endif
    writeFourBytes (fp, TREEFILE_MAGIC);
    writeTwoBytes (fp, SCID_VERSION);
    writeFourBytes (fp, CacheSize);
    writeFourBytes (fp, NumInUse);
    writeFourBytes (fp, LowestTotal);
    writeFourBytes (fp, LowestTotalIndex);

    for (uint count = 0; count < NumInUse; count++) {
        // Write this cached position:
        cachedTreeT * ctree = &(Cache[count]);
        writeOneByte (fp, ctree->toMove);
        for (squareT sq=0; sq < 64; sq++) {
            writeOneByte (fp, ctree->board[sq]);
        }
        // Write the moves:
        writeFourBytes (fp, ctree->tree.moveCount);
        writeFourBytes (fp, ctree->tree.totalCount);
        uint numMoves = ctree->tree.moveCount;
        for (uint i=0; i < numMoves; i++) {
            // Write this move node:
            treeNodeT * tnode = &(ctree->tree.node[i]);
            writeSimpleMove (fp, &(tnode->sm));
            writeString (fp, tnode->san, 8);
            for (uint res = 0; res < 4; res++) {
                writeFourBytes (fp, tnode->freq[res]);
            }
            writeFourBytes (fp, tnode->total);
            writeFourBytes (fp, tnode->score);
            writeTwoBytes (fp, tnode->ecoCode);
            writeFourBytes (fp, tnode->eloCount);
            writeFourBytes (fp, tnode->eloSum);
            writeFourBytes (fp, tnode->perfCount);
            writeFourBytes (fp, tnode->perfSum);
            writeFourBytes (fp, tnode->yearCount);
            writeFourBytes (fp, tnode->yearSum);
        }
        // Write the compressed filter:
        ctree->cfilter->WriteToFile (fp);
    }
#ifdef WINCE
    my_Tcl_Close(NULL, fp);
#else
    fclose (fp);
#endif
    return OK;
}

errorT
TreeCache::ReadFile (const char * fname)
{
    // Only read the file if the cache is empty:
    if (NumInUse > 0) { return OK; }
#ifdef WINCE
    /*FILE * */Tcl_Channel fp;
    fileNameT fullname;
    strCopy (fullname, fname);
    strAppend (fullname, TREEFILE_SUFFIX);

    //fp = fopen (fullname, "rb");
    fp = mySilent_Tcl_OpenFileChannel(NULL, fullname, "r", 0666);
    if (fp == NULL) {
        return ERROR_FileOpen;
    }
 my_Tcl_SetChannelOption(NULL, fp, "-encoding", "binary");
 my_Tcl_SetChannelOption(NULL, fp, "-translation", "binary");

    uint magic = readFourBytes (fp);
    if (magic != TREEFILE_MAGIC) {
        //fclose (fp);
        my_Tcl_Close(NULL, fp);

#else
    FILE * fp;
    fileNameT fullname;
    strCopy (fullname, fname);
    strAppend (fullname, TREEFILE_SUFFIX);

    fp = fopen (fullname, "rb");
    if (fp == NULL) {
        return ERROR_FileOpen;
    }

    uint magic = readFourBytes (fp);
    if (magic != TREEFILE_MAGIC) {
        fclose (fp);
#endif
        return ERROR_Corrupt;
    }
    readTwoBytes (fp);  // Scid Version; unused
    uint cacheSize = readFourBytes (fp);
    SetCacheSize (cacheSize);
    NumInUse = readFourBytes (fp);
    LowestTotal = readFourBytes (fp);
    LowestTotalIndex = readFourBytes(fp);

    for (uint count=0; count < NumInUse; count++) {
        cachedTreeT * ctree = &(Cache[count]);
        ctree->toMove = readOneByte (fp);
        for (squareT sq=0; sq < 64; sq++) {
            ctree->board[sq] = readOneByte (fp);
        }

        // Read the moves:
        ctree->tree.moveCount = readFourBytes (fp);
        ctree->tree.totalCount = readFourBytes (fp);

        uint numMoves = ctree->tree.moveCount;
        for (uint i=0; i < numMoves; i++) {
            // Read this move node:

            treeNodeT * tnode = &(ctree->tree.node[i]);
            readSimpleMove (fp, &(tnode->sm));
            readString (fp, tnode->san, 8);
            for (uint res = 0; res < 4; res++) {
                tnode->freq[res] = readFourBytes (fp);
            }
            tnode->total = readFourBytes (fp);
            tnode->score = readFourBytes (fp);
            tnode->ecoCode = readTwoBytes (fp);
            tnode->eloCount = readFourBytes (fp);
            tnode->eloSum = readFourBytes (fp);
            tnode->perfCount = readFourBytes (fp);
            tnode->perfSum = readFourBytes (fp);
            tnode->yearCount = readFourBytes (fp);
            tnode->yearSum = readFourBytes (fp);
        }

        // Read the compressed filter:
        ctree->cfilter = new CompressedFilter;
        ctree->cfilter->ReadFromFile (fp);
    }
#ifdef WINCE
     my_Tcl_Close(NULL, fp);
#else
    fclose (fp);
#endif
    return OK;
}

//////////////////////////////////////////////////////////////////////
//  EOF: tree.cpp
//////////////////////////////////////////////////////////////////////
