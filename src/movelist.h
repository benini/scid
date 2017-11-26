//////////////////////////////////////////////////////////////////////
//
//  FILE:       movelist.h
//              MoveList class
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    3.4
//
//  Notice:     Copyright (c) 1999-2002 Shane Hudson.  All rights reserved.
//              Copyright (c) 2016 Fulvio Benini.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////


#ifndef SCID_MOVELIST_H
#define SCID_MOVELIST_H

#include "common.h"
#include <cstring>
#include <iterator>

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
    squareT  from;
    squareT  to;
    pieceT   promote;
    pieceT   movingPiece;
    byte     pieceNum;
    byte     capturedNum;
    pieceT   capturedPiece;
    squareT  capturedSquare; // ONLY different to "to" field if this capture
                            //    is an en passant capture.
    byte     castleFlags;    // pre-move information
    squareT  epSquare;       // pre-move information
    ushort   oldHalfMoveClock;
    int32_t  score;          // used for alpha/beta ordering.

	bool isNullMove() const {
		return from == to && from != NULL_SQUARE &&
		       piece_Type(movingPiece) == KING;
	}

	int isCastle() const {
		ASSERT(piece_Type(movingPiece) == KING);
		if (square_Fyle(from) == E_FYLE) {
			squareT toFyle = square_Fyle(to);
			if (toFyle == G_FYLE)
				return 1;
			if (toFyle == C_FYLE)
				return 2;
		}
		return 0;
	}

	bool operator<(const simpleMoveT& b) const {
		// Highest score first
		return score > b.score;
	}

	void clear() {
		std::memset(this, 0, sizeof *this);
	}
};

struct cmpMove {
	const simpleMoveT& m;
	explicit cmpMove(const simpleMoveT& sm) : m(sm) {}
};
inline bool operator==(const simpleMoveT& a, const cmpMove& b) {
	return a.from == b.m.from && a.to == b.m.to && a.promote == b.m.promote;
}

// typedef std::vector<simpleMoveT> MoveList;
class MoveList {
	uint ListSize = 0;
	simpleMoveT Moves[MAX_LEGAL_MOVES];

public:
	typedef simpleMoveT* iterator;
	iterator begin() { return Moves; };
	iterator end() { return Moves + ListSize; }
	uint Size() { return ListSize; }
	void Clear() { ListSize = 0; }
	void emplace_back(squareT from, squareT to, pieceT promote,
	                  pieceT movingPiece, pieceT capturedPiece) {
		ASSERT(ListSize < MAX_LEGAL_MOVES);
		simpleMoveT& sm = Moves[ListSize++];
		sm.from = from;
		sm.to = to;
		sm.promote = promote;
		sm.movingPiece = movingPiece;
		sm.capturedPiece = capturedPiece;
	}
	void resize(size_t count) {
		ASSERT(count <= MAX_LEGAL_MOVES);
		ListSize = static_cast<uint>(count);
	}
	void push_back(const simpleMoveT& sm) {
		ASSERT(ListSize < MAX_LEGAL_MOVES);
		Moves[ListSize++] = sm;
	}
	simpleMoveT* Get(size_t index) {
		ASSERT(index < ListSize);
		return &(Moves[index]);
	}
};

#endif // SCID_MOVELIST_H
