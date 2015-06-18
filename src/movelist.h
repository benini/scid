//////////////////////////////////////////////////////////////////////
//
//  FILE:       movelist.h
//              MoveList class
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    3.4
//
//  Notice:     Copyright (c) 1999-2002 Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////


#ifndef SCID_MOVELIST_H
#define SCID_MOVELIST_H

#include "common.h"
#include <algorithm>

//////////////////////////////////////////////////////////////////////
//  MoveList:  Constants

const uint  MAX_LEGAL_MOVES = 256;  // max. length of the moves list


///////////////////////////////////////////////////////////////////////////
//  MoveList:  Data Structures

// *** SimpleMove: less expensive to store than a full move as defined
//      in game.h, but still fully undoable.
//
struct simpleMoveT
{
    byte     pieceNum;
    pieceT   movingPiece;
    squareT  from;
    squareT  to;
    byte     capturedNum;
    pieceT   capturedPiece;
    pieceT   promote;
    squareT  capturedSquare; // ONLY different to "to" field if this capture
                            //    is an en passant capture.
    byte     castleFlags;    // pre-move information
    squareT  epSquare;       // pre-move information
    ushort   oldHalfMoveClock;
    int      score;          // used for alpha/beta ordering.
};

inline bool isNullMove (const simpleMoveT* sm)
{
    return (sm->from == sm->to  &&  sm->from != NULL_SQUARE
              &&  piece_Type(sm->movingPiece) == KING);
}

inline bool cmpSimpleMoveScore(const simpleMoveT& a, const simpleMoveT& b) {
    return a.score < b.score;
}


class MoveList
{
private:
    uint ListSize;
    simpleMoveT Moves [MAX_LEGAL_MOVES];

public:
    MoveList() { ListSize = 0; }
    ~MoveList() {}

    simpleMoveT* begin() { return Moves; };
    simpleMoveT* end() { return Moves + ListSize; }
    inline uint Size() { return ListSize; }
    inline void Clear() { ListSize = 0; }
    inline void Add (simpleMoveT * sm);
    inline simpleMoveT * Add ();
    inline simpleMoveT * Get (uint index);
    inline void Remove (uint index);

    void MoveToFront(uint index) {
        // Promotes a move to the front of the list, pushing
        // all moves that were ahead of it down one place.
        ASSERT(index < Size());
        std::rotate(begin(), begin() + index, begin() + index + 1);
    }
    void SwapWithFirst(uint index) {
        ASSERT(index < Size());
        std::iter_swap(begin(), begin() + index);
    }
    int  Find (simpleMoveT * sm);
    void FindBest(uint index) {
        ASSERT(index < Size());
        // Searches the move list from the specified index to the end of
        // the list to find the move in that range of the list with the
        // highest score, and swaps the best move found with the move at
        // the specified index if it is not already there.
        // The moves earlier in the list (at indices 0 to index-1) are
        // ignored and are not moved.
        std::iter_swap(begin() + index,
            std::max_element(begin() + index, end(), cmpSimpleMoveScore)
        );
    }
    void Sort() {
        // Sort the move list by the score field in descending order,
        // with highest scores first.
        std::sort(begin(), end(), cmpSimpleMoveScore);
        std::reverse(begin(), end());
    }

    uint SelectBySquare (squareT sq);
};

inline void
MoveList::Add (simpleMoveT * sm)
{
    ASSERT (sm != NULL);
    ASSERT (ListSize < MAX_LEGAL_MOVES);
    Moves[ListSize++] = *sm;
}

inline simpleMoveT *
MoveList::Add (void)
{
    ASSERT (ListSize < MAX_LEGAL_MOVES);
    simpleMoveT * sm = &(Moves[ListSize]);
    ListSize++;
    return sm;
}

inline simpleMoveT *
MoveList::Get (uint index)
{
    ASSERT (index < ListSize);
    return &(Moves[index]);
}

inline void
MoveList::Remove (uint index)
{
    ASSERT (index < ListSize);
    ListSize--;
    if (index != ListSize) {
        Moves[index] = Moves[ListSize];
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// MoveList::Find
//   Searches for a move in the list.
//   Returns the index of the move with the same from-square,
//   to-square and promotion-piece values as the specified
//   move, if it is in the list. If the move is not found,
//   the value -1 is returned.
inline int
MoveList::Find (simpleMoveT * sm)
{
    for (uint i=0; i < ListSize; i++) {
        simpleMoveT * lsm = &(Moves[i]);
        if (sm->from == lsm->from  &&  sm->to == lsm->to
                &&  sm->promote == lsm->promote) {
            return (int) i;
        }
    }
    return -1;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// MoveList::SelectBySquare
//   Restricts the list to only contain moves which
//   move a piece to or from the specified square.
//   Returns the new size of the list.
inline uint
MoveList::SelectBySquare (squareT sq)
{
    uint index = 0;
    for (uint i=0; i < ListSize; i++) {
        simpleMoveT * sm = &(Moves[i]);
        if (sm->from != sq  &&  sm->to != sq) {
            // Skip this move, it does not match.
            continue;
        }
        // Copy this move to an earlier index if necessary:
        if (i != index) {
            Moves[index] = *sm;
        }
        index++;
    }
    ListSize = index;
    return ListSize;
}


#endif  // SCID_MOVELIST_H

//////////////////////////////////////////////////////////////////////
//  EOF: movelist.h
//////////////////////////////////////////////////////////////////////
