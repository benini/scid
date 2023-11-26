//////////////////////////////////////////////////////////////////////
//
//  FILE:       position.cpp
//              Position class methods
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    3.5
//
//  Notice:     Copyright (c) 1999-2003 Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////

#include "position.h"
#include "attacks.h"
#include "common.h"
#include "dstring.h"
#include "hash.h"
#include "misc.h"
#include "movegen.h"
#include "sqmove.h"
#include <algorithm>
#include <array>
#include <vector>

namespace {
bool valid_sqlist(pieceT* begin, size_t n, pieceT* board) {
	auto unique_sq = std::vector<pieceT>(begin, begin + n);
	std::sort(unique_sq.begin(), unique_sq.end());
	unique_sq.erase(std::unique(unique_sq.begin(), unique_sq.end()),
	                unique_sq.end());
	auto unique_col = std::vector<pieceT>(n);
	std::transform(begin, begin + n, unique_col.begin(),
	               [&](auto sq) { return piece_Color(board[sq]); });
	std::sort(unique_col.begin(), unique_col.end());
	unique_col.erase(std::unique(unique_col.begin(), unique_col.end()),
	                 unique_col.end());
	auto kings = std::vector<pieceT>(n);
	std::transform(begin, begin + n, kings.begin(),
	               [&](auto sq) { return piece_Type(board[sq]); });
	return unique_sq.size() == n     // no duplicates
	       && unique_col.size() == 1 // not EMPTY and all of same side
	       && kings[0] == KING       // only 1 king with idx == 0;
	       && std::count(kings.begin(), kings.end(), KING) == 1;
}
} // namespace

inline void
Position::AddHash (pieceT p, squareT sq)
{
    HASH (Hash, p, sq);
    if (piece_Type(p) == PAWN) {
        HASH (PawnHash, p, sq);
    }
}

inline void
Position::UnHash (pieceT p, squareT sq)
{
    UNHASH (Hash, p, sq);
    if (piece_Type(p) == PAWN) {
        UNHASH (PawnHash, p, sq);
    }
}

inline void
Position::AddToBoard (pieceT p, squareT sq)
{
    ASSERT (Board[sq] == EMPTY);
    Board[sq] = p;
    NumOnRank[p][square_Rank(sq)]++;
    NumOnFyle[p][square_Fyle(sq)]++;
    NumOnLeftDiag[p][square_LeftDiag(sq)]++;
    NumOnRightDiag[p][square_RightDiag(sq)]++;
    NumOnSquareColor[p][square_Color(sq)]++;
    AddHash (p, sq);
}

inline void
Position::RemoveFromBoard (pieceT p, squareT sq)
{
    ASSERT (Board[sq] == p);
    Board[sq] = EMPTY;
    NumOnRank[p][square_Rank(sq)]--;
    NumOnFyle[p][square_Fyle(sq)]--;
    NumOnLeftDiag[p][square_LeftDiag(sq)]--;
    NumOnRightDiag[p][square_RightDiag(sq)]--;
    NumOnSquareColor[p][square_Color(sq)]--;
    UnHash (p, sq);
}

///////////////////////////////////////////////////////////////////////////
// sqDir[][]: Array listing the direction between any two squares.
//    For example, sqDir[A1][B2] == UP_RIGHT, and sqDir[A1][C2] == NULL_DIR.
directionT sqDir[66][66];
struct sqDir_Init
{
    sqDir_Init() {
        // Initialise the sqDir[][] array of directions between every pair
        // of squares.
        squareT i, j;
        directionT dirArray[] = { UP, DOWN, LEFT, RIGHT, UP_LEFT, UP_RIGHT,
                                  DOWN_LEFT, DOWN_RIGHT, NULL_DIR };
        // First, set everything to NULL_DIR:
        for (i=A1; i <= NS; i++) {
            for (j=A1; j <= NS; j++) {
                sqDir[i][j] = NULL_DIR;
            }
        }
        // Now fill in the valid directions:
        for (i=A1; i <= H8; i++) {
            directionT * dirptr = dirArray;
            while (*dirptr != NULL_DIR) {
                j = square_Move (i, *dirptr);
                while (j != NS) {
                    sqDir[i][j] = *dirptr;
                    j = square_Move (j, *dirptr);
                }
                dirptr++;
            }
        }
    }
} sqDir_Init_singleton;

///////////////////////////////////////////////////////////////////////////
//  PRIVATE FUNCTIONS -- small ones are inline for speed

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::CalcPinsDir():
//      Look for a pinned piece in the direction 'dir' relative to
//      the position of the king to move.
//
inline void
Position::CalcPinsDir (directionT dir, pieceT attacker)
{
    // Two pieces can pin along any path. A queen is always one,
    // the other is a bishop or rook. To save calculating it here, the
    // appropriate piece (BISHOP) or (ROOK) is passed along with the
    // direction.

    squareT king = GetKingSquare (ToMove);
    squareT friendly = NULL_SQUARE;
    squareT x = king;
    squareT last = square_Last (king, dir);
    int delta = direction_Delta (dir);

    while (x != last) {
        x += delta;
        pieceT p = Board[x];
        if (p == EMPTY) {
            // Empty square, so keep searching.
        } else if (piece_Color_NotEmpty(p) == ToMove) {
            // Found a friendly piece.
            if (friendly == NULL_SQUARE) {
                // Found first friendly in this direction
                friendly = x;
            } else {
                // Found second friendly in this direction, so stop.
                return;
            }
        } else {
            // Found an enemy piece
            if (friendly != NULL_SQUARE) {
                // Potential pin:
                pieceT ptype = piece_Type(p);
                if (ptype == QUEEN  ||  ptype == attacker) {
                    Pinned[ListPos[friendly]] = dir;
                }
            }
            return;     // found an enemy piece, so end search
        }
    }
    return;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::AddLegalMove():
//      Add a legal move to the move list.
//
inline void
Position::AddLegalMove (MoveList * mlist, squareT from, squareT to, pieceT promo)
{
    ASSERT (mlist != NULL);
    auto& sm = mlist->emplace_back();
    makeMove(from, to, promo, sm);
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::GenSliderMoves():
//      Generate slider moves along a direction, for a sliding
//      piece of the specified color from the specified square.
//      If sqset != NULL, moves must be to a square in sqset.
inline void
Position::GenSliderMoves (MoveList * mlist, colorT color, squareT fromSq,
                          directionT dir, SquareSet * sqset, bool capturesOnly)
{
    squareT dest = fromSq;
    squareT last = square_Last (fromSq, dir);
    int delta = direction_Delta (dir);

    while (dest != last) {
        dest += delta;
        pieceT p = Board[dest];
        if (p == EMPTY) {
            if (! capturesOnly) {
                if (sqset == NULL  ||  sqset->Contains(dest)) {
                    AddLegalMove (mlist, fromSq, dest, EMPTY);
                }
            }
            continue;
        }
        // We have reached a piece. Add the capture if it is an enemy.
        if (piece_Color_NotEmpty(p) != color) {
            if (sqset == NULL  ||  sqset->Contains(dest)) {
                AddLegalMove (mlist, fromSq, dest, EMPTY);
            }
        }
        break;
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::GenKnightMoves():
//      Generate knight moves.
//      If sqset != NULL, moves must be to a square in sqset.
inline void
Position::GenKnightMoves (MoveList * mlist, colorT c, squareT fromSq,
                          SquareSet * sqset, bool capturesOnly)
{
    const squareT * destPtr = knightAttacks[fromSq];
    while (true) {
        squareT dest = *destPtr;
        if (dest == NULL_SQUARE) { break; }
        destPtr++;
        pieceT p = Board[dest];
        if (capturesOnly  &&  p == EMPTY) { continue; }
        if (piece_Color(p) != c) {
            if (sqset == NULL  ||  sqset->Contains(dest)) {
                AddLegalMove (mlist, fromSq, dest, EMPTY);
            }
        }
    }
}

template <typename TFunc>
bool Position::under_attack(squareT target_sq, squareT captured_sq,
                            TFunc not_empty) const {
	const auto enemy = color_Flip(GetToMove());
	const auto lpawn_atk = square_Move(target_sq,
	                                   enemy == WHITE ? DOWN_LEFT : UP_LEFT);
	const auto rpawn_atk = square_Move(target_sq,
	                                   enemy == WHITE ? DOWN_RIGHT : UP_RIGHT);
	const auto enemy_pieces = GetList(enemy);
	for (size_t i = 1, n = GetCount(enemy); i < n; ++i) {
		const auto piece_sq = enemy_pieces[i];
		if (piece_sq == captured_sq)
			continue;

		const auto piece_type = piece_Type(GetPiece(piece_sq));
		if (piece_type == KNIGHT) {
			if (movegen::valid_knight(piece_sq, target_sq))
				return true; // Knight check

		} else if (piece_type == PAWN) {
			if (piece_sq == lpawn_atk || piece_sq == rpawn_atk)
				return true; // Pawn check

		} else {
			if (movegen::attack_slider(piece_sq, target_sq, piece_type,
			                           not_empty))
				return true; // Slider check
		}
	}
	assert(GetCount(enemy) >= 1);
	return movegen::valid_king(enemy_pieces[0], target_sq);
}

bool Position::under_attack(squareT target_sq) const {
	return under_attack(target_sq, target_sq,
	                    [&](auto sq) { return GetPiece(sq) != EMPTY; });
}

// Sanity checks for castling flags.
// Return true if the corresponding castling flag is set, there is a rook in the
// expected square, and the king is in the same first rank of the rook.
bool Position::validCastlingFlag(colorT color, bool king_side) const {
	if (!GetCastling(color, king_side ? KSIDE : QSIDE))
		return false;

	const auto kingFrom = GetKingSquare(color);
	const auto rookFrom = castleRookSq(color, king_side);
	return Board[rookFrom] == piece_Make(color, ROOK) &&
	       square_Rank(kingFrom) == square_Rank(rookFrom) &&
	       square_Rank(kingFrom) == rank_Relative(color, RANK_1);
}

template <bool check_legal> bool Position::canCastle(bool king_side) const {
	if (check_legal && !GetCastling(ToMove, king_side ? KSIDE : QSIDE))
		return false;

	const squareT kingFrom = GetKingSquare();
	const squareT rookFrom = castleRookSq(ToMove, king_side);
	const squareT rookTo = king_side ? square_Relative(ToMove, F1)
	                                 : square_Relative(ToMove, D1);
	const squareT kingTo = king_side ? square_Relative(ToMove, G1)
	                                 : square_Relative(ToMove, C1);
	if (Board[rookFrom] != piece_Make(ToMove, ROOK))
		return false;

	const int stepRook = rookFrom < rookTo ? -1 : 1;
	for (int sq = rookTo; sq != rookFrom; sq += stepRook) {
		if (Board[sq] != EMPTY && sq != kingFrom)
			return false;

		if (!check_legal)
			break;
	}

	const int stepKing = kingFrom < kingTo ? -1 : 1;
	for (int sq = kingTo; sq != kingFrom; sq += stepKing) {
		if (Board[sq] != EMPTY && sq != rookFrom)
			return false;

		if (!check_legal)
			break;

		if (under_attack(sq))
			return false;
	}
	return true;
}
template bool Position::canCastle<false>(bool king_side) const;


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::GenCastling():
//    Generate the legal castling moves.
//    Assumes the side to move is NOT in check, so the caller
//    should verify this first.
//
void Position::GenCastling(MoveList* mlist) {
	const squareT from = GetKingSquare();

	if (canCastle(true))
		makeMove(from, from, KING, mlist->emplace_back());

	if (canCastle(false))
		makeMove(from, from, QUEEN, mlist->emplace_back());
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::GenKingMoves():
//      Generate the legal King moves. Castling is generated as well, if
//      the specified flag is true.
//
void
Position::GenKingMoves (MoveList * mlist, genMovesT genType)
{
    squareT kingSq = GetKingSquare();
    squareT enemyKingSq = GetEnemyKingSquare();
    colorT enemy = color_Flip(ToMove);
    const squareT * destPtr;
    pieceT king = piece_Make (ToMove, KING);
    bool genNonCaptures = (genType & GEN_NON_CAPS);

    ASSERT (Board[kingSq] == king);

    destPtr = kingAttacks[kingSq];
    while (*destPtr != NULL_SQUARE) {
        // Try this move and see if it legal:

        squareT destSq = *destPtr;
        bool addThisMove = false;

        // Only try this move if the target square has an enemy piece,
        // or if it is empty and noncaptures are to be generated:
        if ( (genNonCaptures  &&  Board[destSq] == EMPTY)
             ||  piece_Color (Board[destSq]) == enemy) {

            // Empty or enemy piece there, so try the move:
            pieceT captured = Board[destSq];
            Board[destSq] = king;
            Board[kingSq] = EMPTY;

            // It is legal if the two kings will not be adjacent and the
            // moving king will not be in check on its new square:
            if (! square_Adjacent (destSq, enemyKingSq)) {
                if (CalcNumChecks (destSq) == 0) {
                    addThisMove = true;
                }
            }
            Board[kingSq] = king;
            Board[destSq] = captured;
        }
        if (addThisMove) { AddLegalMove (mlist, kingSq, destSq, EMPTY); }
        destPtr++;
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::AddPromotions():
//      Add promotion moves.
//      Called by GenPawnMoves() when a pawn can be promoted.
//
inline void
Position::AddPromotions (MoveList * mlist, squareT from, squareT dest)
{
    ASSERT (piece_Type (Board[from]) == PAWN);
    ASSERT (square_Rank (dest) == RANK_1  ||  square_Rank (dest) == RANK_8);

    AddLegalMove (mlist, from, dest, QUEEN);
    AddLegalMove (mlist, from, dest, ROOK);
    AddLegalMove (mlist, from, dest, BISHOP);
    AddLegalMove (mlist, from, dest, KNIGHT);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::IsValidEnPassant
//   Used to verify that an en passant  pawn capture is valid.
//   This is needed because illegal en passant captures can appear
//   legal according to calculations of pinned pieces. For example,
//   consider WK d5, WP e5, BP f5 (just moved there), BR h5 and
//   the en passant capture exf6 would be illegal.
inline bool
Position::IsValidEnPassant (squareT from, squareT to)
{
    ASSERT (from <= H8  &&  to <= H8);
    ASSERT (to == EPTarget);

    // Check that this en passant capture is legal:
    pieceT ownPawn = piece_Make(ToMove, PAWN);
    pieceT enemyPawn = piece_Make (color_Flip(ToMove), PAWN);
    squareT enemyPawnSq = (ToMove == WHITE) ? to - 8 : to + 8;
    ASSERT (Board[from] == ownPawn);
    ASSERT (Board[enemyPawnSq] == enemyPawn);
    Board[from] = EMPTY;

    // PG
    Board[to] = ownPawn;

    Board[enemyPawnSq] = EMPTY;
    bool isValid = ! IsKingInCheck();

    //PG
    Board[to] = EMPTY;

    Board[from] = ownPawn;
    Board[enemyPawnSq] = enemyPawn;
    return isValid;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::GenPawnMoves():
//      Generate legal pawn moves.
//      If dir != NULL_DIR, pawn MUST move in direction dir or its opposite.
//      If sqset != NULL, pawn MUST move to a square in sqset.
//      The dir and sq parameters are for pinned pawns and check evasions.
void
Position::GenPawnMoves (MoveList * mlist, squareT from,
                        directionT dir, SquareSet * sqset, genMovesT genType)
{
    bool genNonCaptures = (genType & GEN_NON_CAPS);
    directionT oppdir = direction_Opposite(dir);
    directionT forward;
    rankT promoRank;
    rankT secondRank;
    if (ToMove == WHITE) {
        forward = UP;    promoRank = RANK_8;  secondRank = RANK_2;
    } else  {
        forward = DOWN;  promoRank = RANK_1;  secondRank = RANK_7;
    }
    squareT dest;

    ASSERT (Board[from] == piece_Make (ToMove, PAWN));

    if (genNonCaptures
          &&  (dir == NULL_DIR  ||  dir == forward  ||  oppdir == forward)) {
        dest = square_Move (from, forward);
        if (Board[dest]==EMPTY && (sqset==NULL || sqset->Contains(dest))) {
            if (square_Rank(dest) == promoRank) {
                AddPromotions (mlist, from, dest);
            } else {
                AddLegalMove (mlist, from, dest, EMPTY);
            }
        }
        if (square_Rank(from) == secondRank  &&  Board[dest] == EMPTY) {
            dest = square_Move (dest, forward);
            if (Board[dest]==EMPTY  &&  (sqset==NULL || sqset->Contains(dest))) {
                AddLegalMove (mlist, from, dest, EMPTY);
            }
        }
    }

    // Now do captures: left, then right
    // To be a possible capture, dest square must be EPTarget or hold
    // an enemy piece.
#define POSSIBLE_CAPTURE(d) ((d != NULL_SQUARE)   \
            &&  ((piece_Color (Board[d]) == (color_Flip(ToMove)))  \
                    ||  (d == EPTarget  &&  IsValidEnPassant(from,d))))

    directionT capdir = forward | LEFT;
    if (dir == NULL_DIR  ||  dir == capdir  ||  oppdir == capdir) {
        dest = square_Move (from, capdir);
        if (POSSIBLE_CAPTURE(dest)  &&  (sqset==NULL || sqset->Contains(dest))) {
            if (square_Rank(dest) == promoRank) {
                AddPromotions (mlist, from, dest);
            } else {
                AddLegalMove (mlist, from, dest, EMPTY);
            }
        }
    }
    capdir = forward | RIGHT;
    if (dir == NULL_DIR  ||  dir == capdir  ||  oppdir == capdir) {
        dest = square_Move (from, capdir);
        if (POSSIBLE_CAPTURE(dest)  &&  (sqset==NULL || sqset->Contains(dest))) {
            if (square_Rank(dest) == promoRank) {
                AddPromotions (mlist, from, dest);
            } else {
                AddLegalMove (mlist, from, dest, EMPTY);
            }
        }
    }
    return;
}


//////////////////////////////////////////////////////////////////////
//  PUBLIC FUNCTIONS


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::GetHPSig():
//      Return the position's home pawn signature.
//
uint
Position::GetHPSig (void)
{
    uint hpSig = 0;
    pieceT * b = &(Board[A2]);
    if (*b == WP) { hpSig |= 0x8000; }  b++;  /* a2 */
    if (*b == WP) { hpSig |= 0x4000; }  b++;  /* b2 */
    if (*b == WP) { hpSig |= 0x2000; }  b++;  /* c2 */
    if (*b == WP) { hpSig |= 0x1000; }  b++;  /* d2 */
    if (*b == WP) { hpSig |= 0x0800; }  b++;  /* e2 */
    if (*b == WP) { hpSig |= 0x0400; }  b++;  /* f2 */
    if (*b == WP) { hpSig |= 0x0200; }  b++;  /* g2 */
    if (*b == WP) { hpSig |= 0x0100; }        /* h2 */
    b = &(Board[A7]);
    if (*b == BP) { hpSig |= 0x0080; }  b++;  /* a7 */
    if (*b == BP) { hpSig |= 0x0040; }  b++;  /* b7 */
    if (*b == BP) { hpSig |= 0x0020; }  b++;  /* c7 */
    if (*b == BP) { hpSig |= 0x0010; }  b++;  /* d7 */
    if (*b == BP) { hpSig |= 0x0008; }  b++;  /* e7 */
    if (*b == BP) { hpSig |= 0x0004; }  b++;  /* f7 */
    if (*b == BP) { hpSig |= 0x0002; }  b++;  /* g7 */
    if (*b == BP) { hpSig |= 0x0001; }        /* h7 */
    return hpSig;
}

Position::Position() {
    // Setting up a valid board is left to StdStart() or Clear().
    Board [COLOR_SQUARE] = EMPTY;
    Board [NULL_SQUARE] = END_OF_BOARD;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::Clear():
//      Clear the board and associated structures.
//
void
Position::Clear (void)
{
    int i;
    for (i=A1; i <= H8; i++) { Board[i] = EMPTY; }
    for (i=WK; i <= BP; i++) {
        Material[i] = 0;
        for (uint j=0; j < 8; j++) {
            NumOnRank[i][j] = NumOnFyle[i][j] = 0;
        }
        for (uint d=0; d < 15; d++) {
            NumOnLeftDiag[i][d] = NumOnRightDiag[i][d] = 0;
        }
        NumOnSquareColor[i][WHITE] = NumOnSquareColor[i][BLACK] = 0;
    }
    Count[WHITE] = Count[BLACK] = 0;
    EPTarget = NULL_SQUARE;
    Castling = 0;
    variant_ = 0;
    std::fill_n(castleRookSq_, 4, 0);
    Board [NULL_SQUARE] = END_OF_BOARD;
    PlyCounter = 0;
    HalfMoveClock = 0;
    Hash = 0;
    PawnHash = 0;
    return;
}

squareT Position::find_castle_rook(colorT col, squareT rsq) const {
	const auto ksq = GetKingSquare(col);
	if (square_Rank(ksq) == square_Rank(rsq)) {
		const auto rook = piece_Make(col, ROOK);
		while (Board[rsq] != rook && rsq != ksq) {
			if (rsq < ksq)
				++rsq;
			else
				--rsq;
		}
	}
	return rsq;
}

void Position::setCastling(colorT col, squareT rsq) {
	static_assert(1 << castlingIdx(WHITE, QSIDE) == 1);
	static_assert(1 << castlingIdx(WHITE, KSIDE) == 2);
	static_assert(1 << castlingIdx(BLACK, QSIDE) == 4);
	static_assert(1 << castlingIdx(BLACK, KSIDE) == 8);

	const auto ksq = GetKingSquare(col);
	rsq = find_castle_rook(col, rsq);
	const auto dir = square_Fyle(ksq) < square_Fyle(rsq) ? KSIDE : QSIDE;
	const auto idx = castlingIdx(col, dir);
	castleRookSq_[idx] = rsq;
	Castling |= 1u << idx;
	const auto std_rsq = (dir == QSIDE) ? square_Relative(col, A1)
	                                    : square_Relative(col, H1);
	if (ksq != square_Relative(col, E1) || rsq != std_rsq)
		variant_ = 1;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::StdStart():
//      Set up the standard chess starting position. For performance the data is copied from a 
//      template.
//
const Position& Position::getStdStart()
{
    static Position startPositionTemplate;
    static bool init = true;

    if (init){
        init = false;
        Position* p = &startPositionTemplate;
        p->Clear();
        p->Material[WK] = p->Material[BK] = 1;
        p->Material[WQ] = p->Material[BQ] = 1;
        p->Material[WR] = p->Material[BR] = 2;
        p->Material[WB] = p->Material[BB] = 2;
        p->Material[WN] = p->Material[BN] = 2;
        p->Material[WP] = p->Material[BP] = 8;
        p->Count[WHITE] = p->Count[BLACK] = 16;

        p->AddToBoard(WK, E1);  p->List[WHITE][0] = E1;  p->ListPos[E1] = 0;
        p->AddToBoard(BK, E8);  p->List[BLACK][0] = E8;  p->ListPos[E8] = 0;
        p->AddToBoard(WR, A1);  p->List[WHITE][1] = A1;  p->ListPos[A1] = 1;
        p->AddToBoard(BR, A8);  p->List[BLACK][1] = A8;  p->ListPos[A8] = 1;
        p->AddToBoard(WN, B1);  p->List[WHITE][2] = B1;  p->ListPos[B1] = 2;
        p->AddToBoard(BN, B8);  p->List[BLACK][2] = B8;  p->ListPos[B8] = 2;
        p->AddToBoard(WB, C1);  p->List[WHITE][3] = C1;  p->ListPos[C1] = 3;
        p->AddToBoard(BB, C8);  p->List[BLACK][3] = C8;  p->ListPos[C8] = 3;
        p->AddToBoard(WQ, D1);  p->List[WHITE][4] = D1;  p->ListPos[D1] = 4;
        p->AddToBoard(BQ, D8);  p->List[BLACK][4] = D8;  p->ListPos[D8] = 4;
        p->AddToBoard(WB, F1);  p->List[WHITE][5] = F1;  p->ListPos[F1] = 5;
        p->AddToBoard(BB, F8);  p->List[BLACK][5] = F8;  p->ListPos[F8] = 5;
        p->AddToBoard(WN, G1);  p->List[WHITE][6] = G1;  p->ListPos[G1] = 6;
        p->AddToBoard(BN, G8);  p->List[BLACK][6] = G8;  p->ListPos[G8] = 6;
        p->AddToBoard(WR, H1);  p->List[WHITE][7] = H1;  p->ListPos[H1] = 7;
        p->AddToBoard(BR, H8);  p->List[BLACK][7] = H8;  p->ListPos[H8] = 7;

        for (uint i=0; i < 8; i++) {
            p->AddToBoard(WP, A2+i); p->List[WHITE][i+8] = A2+i; p->ListPos[A2+i] = i+8;
            p->AddToBoard(BP, A7+i); p->List[BLACK][i+8] = A7+i; p->ListPos[A7+i] = i+8;
        }

        p->setCastling(WHITE, A1);
        p->setCastling(WHITE, H1);
        p->setCastling(BLACK, A8);
        p->setCastling(BLACK, H8);
        p->EPTarget = NULL_SQUARE;
        p->ToMove = WHITE;
        p->PlyCounter = 0;
        p->HalfMoveClock = 0;
        p->Board [NULL_SQUARE] = END_OF_BOARD;
        p->Hash = stdStartHash;
        p->PawnHash = stdStartPawnHash;
    }
    return startPositionTemplate;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::IsStdStart
//   Returns true if the position is the standard starting position.
bool Position::IsStdStart() const {
    if (ToMove != WHITE
          ||  Hash != stdStartHash  ||  PawnHash != stdStartPawnHash
          ||  GetCount(WHITE) != 16  ||  GetCount(BLACK) != 16
          ||  RankCount(WP,RANK_2) != 8  ||  RankCount(BP,RANK_7) != 8
          ||  RankCount(WN,RANK_1) != 2  ||  RankCount(BN,RANK_8) != 2
          ||  !GetCastling(WHITE,KSIDE)  ||  !GetCastling(WHITE,QSIDE)
          ||  !GetCastling(BLACK,KSIDE)  ||  !GetCastling(BLACK,QSIDE)) {
        return false;
    }
    return true;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::AddPiece():
//      Add a piece to the board and piecelist.
//      Checks that a side cannot have more than 16 pieces or more
//      than one king.
//
errorT
Position::AddPiece (pieceT p, squareT sq)
{
    ASSERT (p != EMPTY);
    colorT c = piece_Color(p);
    if ((c != WHITE && c != BLACK) || Count[c] > 15)
        return ERROR_PieceCount;

    if (piece_Type(p) == KING) {
        // Check there is not already a King:
        if (Material[p] > 0) { return ERROR_PieceCount; }

        // King is always at the start of the piecelist, so move the piece
        // already at location 0 if there is one:
        if (Count[c] > 0) {
            squareT oldsq = List[c][0];
            List[c][Count[c]] = oldsq;
            ListPos[oldsq] = Count[c];
        }
        List[c][0] = sq;
        ListPos[sq] = 0;
    } else {
        ListPos[sq] = Count[c];
        List[c][Count[c]] = sq;
    }
    Count[c]++;
    Material[p]++;
    AddToBoard (p, sq);
    return OK;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::CalcPins():
//      Calculate the pieces for the side to move that are
//      pinned to their king. The array Pinned[] stores, for
//      each piece, the direction in which it is pinned.
//
//      For example WK on e1, WQ on e2, BQ on e7 on the e-fyle
//      means the WQ is Pinned in the direction UP.
//
void
Position::CalcPins (void)
{
    Pinned[ 0] = Pinned[ 1] = Pinned[ 2] = Pinned[ 3] = Pinned[ 4] =
    Pinned[ 5] = Pinned[ 6] = Pinned[ 7] = Pinned[ 8] = Pinned[ 9] =
    Pinned[10] = Pinned[11] = Pinned[12] = Pinned[13] = Pinned[14] =
    Pinned[15] = NULL_DIR;

    squareT kingSq = GetKingSquare (ToMove);
    colorT enemy = color_Flip (ToMove);
    pieceT enemyQueen  = piece_Make (enemy, QUEEN);
    pieceT enemyRook   = piece_Make (enemy, ROOK);
    pieceT enemyBishop = piece_Make (enemy, BISHOP);

    // Pins and checks from Bishops/Queens/Rooks:
    fyleT fyle = square_Fyle (kingSq);
    if (FyleCount(enemyQueen,fyle) + FyleCount(enemyRook,fyle) > 0) {
        CalcPinsDir (UP, ROOK);
        CalcPinsDir (DOWN, ROOK);
    }
    rankT rank = square_Rank (kingSq);
    if (RankCount(enemyQueen,rank) + RankCount(enemyRook,rank) > 0) {
        CalcPinsDir (LEFT, ROOK);
        CalcPinsDir (RIGHT, ROOK);
    }
    leftDiagT ld = square_LeftDiag (kingSq);
    if (LeftDiagCount(enemyQueen,ld) + LeftDiagCount(enemyBishop,ld) > 0) {
        CalcPinsDir (UP_LEFT, BISHOP);
        CalcPinsDir (DOWN_RIGHT, BISHOP);
    }
    rightDiagT rd = square_RightDiag (kingSq);
    if (RightDiagCount(enemyQueen,rd) + RightDiagCount(enemyBishop,rd) > 0) {
        CalcPinsDir (UP_RIGHT, BISHOP);
        CalcPinsDir (DOWN_LEFT, BISHOP);
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::GenPieceMoves():
//      Generates moves for a nonpawn, nonking piece.
//      If sqset != NULL, moves must be to a square in sqset.<
void
Position::GenPieceMoves (MoveList * mlist, squareT fromSq,
                         SquareSet * sqset, bool capturesOnly)
{
    colorT c = ToMove;
    pieceT p = Board[fromSq];
    pieceT ptype = piece_Type(p);
    ASSERT (p != EMPTY  &&  ptype != KING  &&  ptype != PAWN);

    if (ptype == KNIGHT) {
        GenKnightMoves (mlist, c, fromSq, sqset, capturesOnly);
        return;
    }
    if (ptype != BISHOP) {
        GenSliderMoves (mlist, c, fromSq, UP, sqset, capturesOnly);
        GenSliderMoves (mlist, c, fromSq, DOWN, sqset, capturesOnly);
        GenSliderMoves (mlist, c, fromSq, LEFT, sqset, capturesOnly);
        GenSliderMoves (mlist, c, fromSq, RIGHT, sqset, capturesOnly);
    }
    if (ptype != ROOK) {
        GenSliderMoves (mlist, c, fromSq, UP_LEFT, sqset, capturesOnly);
        GenSliderMoves (mlist, c, fromSq, DOWN_LEFT, sqset, capturesOnly);
        GenSliderMoves (mlist, c, fromSq, UP_RIGHT, sqset, capturesOnly);
        GenSliderMoves (mlist, c, fromSq, DOWN_RIGHT, sqset, capturesOnly);
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::GenerateMoves
//    Generate the legal moves list.
//    If the specified pieceType is not EMPTY, then only legal
//    moves for that type of piece are generated.
void
Position::GenerateMoves (MoveList* mlist, pieceT pieceType,
                         genMovesT genType, bool maybeInCheck)
{
    ASSERT(mlist != NULL);

    bool genNonCaptures = (genType & GEN_NON_CAPS);
    bool capturesOnly = !genNonCaptures;

    uint mask = 0;
    if (pieceType != EMPTY) {
        mask = 1 << pieceType;
    } else {
        mask = (1 << KING) | (1 << QUEEN) | (1 << ROOK)
             | (1 << BISHOP) | (1 << KNIGHT) | (1 << PAWN);
    }

    // Use the objects own move list if none was provided:
    mlist->Clear();

    // Compute which pieces of the side to move are pinned to the king:
    CalcPins();

    // Determine if the side to move is in check and find where the
    // checking pieces are, unless the caller has passed maybeInCheck=false
    // indicating it is CERTAIN the side to move is not in check here.

    uint numChecks = 0;
    if (maybeInCheck) {
        SquareList checkSquares;
        numChecks = CalcNumChecks (GetKingSquare(ToMove), &checkSquares);
        if (numChecks > 0) {
            // The side to move IS in check:
            GenCheckEvasions (mlist, pieceType, genType, &checkSquares);
            return;
        }
    }

    // The side to move is NOT in check. Iterate over each non-king
    // piece, and then generate King moves last of all:

    uint npieces = Count[ToMove];
    for (uint x = 1; x < npieces; x++) {
        squareT sq = List[ToMove][x];
        pieceT p = Board[sq];
        pieceT ptype = piece_Type(p);
        if (! (mask & (1 << ptype))) { continue; }
        directionT pinned = Pinned[x];

        // If Pinned[x] == dir (not NULL_DIR), x can ONLY move along
        // that direction or its opposite.

        if (pinned != NULL_DIR) {  // piece x is pinned to king
            if (ptype == PAWN) {
                GenPawnMoves (mlist, sq, pinned, NULL, genType);
            } else if (ptype == KNIGHT) {
                // do nothing -- pinned knights cannot move
            } else {
                // Piece is a pinned Queen/Rook/Bishop. Only generate
                // moves along the pinned direction and its opposite:
                if (ptype == QUEEN
                      || (ptype == ROOK && !direction_IsDiagonal(pinned))
                      || (ptype == BISHOP && direction_IsDiagonal(pinned))) {
                    GenSliderMoves (mlist, ToMove, sq, pinned, NULL, capturesOnly);
                    GenSliderMoves (mlist, ToMove, sq, dirOpposite[pinned],
                                    NULL, capturesOnly);
                }
            }
        } else {
            // This piece is free to move anywhere
            if (ptype == PAWN) {
                GenPawnMoves (mlist, sq, NULL_DIR, NULL, genType);
            } else {
                // Knight/Queen/Bishop/Rook:
                GenPieceMoves (mlist, sq, NULL, capturesOnly);
            }
        }
    }

    // Lastly, king moves...
    if (mask & (1 << KING)) {
        GenKingMoves (mlist, genType);
        if (!numChecks && genNonCaptures) {
            GenCastling(mlist);
        }
    }
}

// Return true if moving the piece from square @e from to square @e dest
// (NULL_SQUARE if the piece is captured) would leave the king in check.
// It can also be used to check if the last move created a discovered check.
static bool xray_check(Position const& pos, squareT from, squareT to) {
	const auto [atk_piece, atk_sq] = movegen::opens_ray(
	    from, to, pos.GetKingSquare(),
	    [&](auto sq) { return pos.GetPiece(sq) != EMPTY; });

	if (atk_piece == INVALID_PIECE)
		return false;

	const auto piece = pos.GetPiece(atk_sq);
	const auto pt = piece_Type(piece);
	const auto col = piece_Color_NotEmpty(piece);
	return col != pos.GetToMove() && (pt == QUEEN || pt == atk_piece);
}

/// Check that the move is contained within the board, that a piece of the wrong
/// color is not moved, that a king or piece of the same color is not captured,
/// and that only pawns are promoted.
static bool invalid_move(Position const& pos, squareT from, squareT to,
                         pieceT promo) {
	if (from > H8 || to > H8)
		return true; // Invalid square

	const auto toMove = pos.GetToMove();
	const auto mover = pos.GetPiece(from);
	const auto captured = pos.GetPiece(to);
	const auto pt = piece_Type(mover);
	return piece_Color(mover) != toMove || // Wrong side to move
	       piece_Type(captured) == KING || // Capturing the king
	       (promo != EMPTY && pt != PAWN); // Only pawn can promote
}

/// Return NULL_SQUARE (if the move is not pseudo legal) or the captured square
/// (which is different from @e to for en passant moves).
static squareT pseudo_legal(Position const& pos, squareT from, squareT to,
                            pieceT promo) {
	const auto toMove = pos.GetToMove();
	const auto captured = pos.GetPiece(to);
	const auto pt = piece_Type(pos.GetPiece(from));
	if (!movegen::pseudo(from, to, toMove, pt,
	                     [&](auto sq) { return pos.GetPiece(sq) != EMPTY; }))
		return NULL_SQUARE; // Invalid move

	auto captured_sq = to;
	if (pt == PAWN) {
		if (captured == EMPTY && square_Fyle(from) != square_Fyle(to)) {
			captured_sq = (toMove == WHITE) ? to - 8 : to + 8;
			const auto enemy = color_Flip(toMove);
			if (to != pos.GetEPTarget() ||
			    pos.GetPiece(captured_sq) != piece_Make(enemy, PAWN))
				return NULL_SQUARE; // Invalid en passant
		}
		if (RANK_8 != square_Rank(square_Relative(toMove, to))) {
			if (promo != EMPTY)
				return NULL_SQUARE; // Wrong promotion rank
		} else {
			if (promo != QUEEN && promo != ROOK && promo != BISHOP &&
			    promo != KNIGHT)
				return NULL_SQUARE; // Wrong promotion piece type
		}
	}
	return captured_sq;
}

/// Return the captured square (which is different from @e to for en passant
/// moves) if the move is pseudo legal and the moving piece is not pinned.
/// Return NULL_SQUARE otherwise.
/// The move is also legal if the king is not in check or if there is only one
/// attacker and it is captured or blocked.
static squareT pseudo_not_pinned(Position const& pos, squareT from, squareT to,
                                 pieceT promo) {
	const auto captured_sq = pseudo_legal(pos, from, to, promo);
	if (captured_sq == NULL_SQUARE)
		return NULL_SQUARE; // Invalid move

	if (captured_sq != to && xray_check(pos, captured_sq, NULL_SQUARE))
		return NULL_SQUARE; // Capturing en passant leaves our king in check

	return xray_check(pos, from, to) ? NULL_SQUARE : captured_sq;
}

/// Returns:
///  0 -> invalid move
///  1 -> valid normal move
///  2 -> valid castle king side
/// -2 -> valid castle queen side
int Position::IsLegalMove(squareT from, squareT to, pieceT promo) const {
	if (invalid_move(*this, from, to, promo))
		return 0;

	const auto king_sq = GetKingSquare();
	const auto captured_sq = piece_Color(GetPiece(to)) == ToMove
	                             ? NULL_SQUARE // Capturing its own piece
	                             : pseudo_legal(*this, from, to, promo);
	if (captured_sq == NULL_SQUARE) {
		if (promo != EMPTY || from != king_sq)
			return 0; // Invalid move

		const bool king_side = to > from;
		const auto castleStd = square_Relative(ToMove, king_side ? G1 : C1);
		const auto castle960 = castleRookSq(ToMove, king_side);
		if ((to == castleStd || to == castle960) && canCastle(king_side) &&
		    !under_attack(king_sq))
			return king_side ? 2 : -2;

		return 0; // Invalid move
	}

	const auto target_sq = (from == king_sq) ? to : king_sq;
	auto not_empty = [&](auto sq) {
		return sq == to ||
		       (sq != from && sq != captured_sq && GetPiece(sq) != EMPTY);
	};
	return under_attack(target_sq, captured_sq, not_empty) ? 0 : 1;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::GenCheckEvasions():
//      Generate legal moves for the side to move when the
//      King is in check.
//
void
Position::GenCheckEvasions (MoveList * mlist, pieceT mask, genMovesT genType,
                            SquareList * checkSquares)
{
    ASSERT(mlist != NULL);
    uint numChecks = checkSquares->Size();
    
    // Assert that king IS actually in check:    
    ASSERT (numChecks > 0);

    bool genNonCaptures = (genType & GEN_NON_CAPS);
    bool capturesOnly = !genNonCaptures;
    mlist->Clear();

    squareT king = GetKingSquare (ToMove);

    // if it's double check, we can ONLY move the king
    if (numChecks == 1) {
        // OK, it is NOT a double check
        // Try to block piece/capture piece. Remember en passant!
        // First, generate a list of targets: squares between the king
        // and attacker to block, and the attacker's square.

        squareT attackSq = checkSquares->Get(0);
        directionT dir = sqDir[king][attackSq];
        SquareSet targets;  // Set of blocking/capturing squares.
        targets.Add(attackSq);

        // Now add squares we can might be able to block on.
        if (dir != NULL_DIR) {
            squareT sq = square_Move (king, dir);
            while (sq != attackSq) {
                if (Board[sq] == EMPTY) { targets.Add(sq); }
                sq = square_Move (sq, dir);
            }
        }

        // Try each non-King piece in turn. If a piece is pinned to
        // the king, don't bother since it cannot possibly block or
        // capture the piece that is giving check!

        uint numPieces = Count[ToMove];
        for (uint p2 = 1; p2 < numPieces; p2++) {
            squareT from = List[ToMove][p2];
            pieceT p2piece = Board[from];
            if (Pinned[p2] != NULL_DIR) { continue; }
            if (mask == EMPTY  ||  mask == piece_Type(p2piece)) {
                if (piece_Type(p2piece) == PAWN) {
                    GenPawnMoves (mlist, from, NULL_DIR, &targets, genType);
                    // Capturing a pawn en passant will only get out
                    // of check if the pawn that moved two squares
                    // is doing the checking. If it is not, that means
                    // a discovered check with the last pawn move so
                    // taking en passant cannot get out of check.
                    if (EPTarget != NULL_SQUARE) {
                        squareT pawnSq = (ToMove == WHITE ? EPTarget - 8 : EPTarget + 8);
                        if (pawnSq == attackSq) {
                            SquareSet epset;
                            epset.Add(EPTarget);
                            GenPawnMoves (mlist, from, NULL_DIR, &epset, genType);
                        }
                    }
                } else {
                    GenPieceMoves (mlist, from, &targets, capturesOnly);
                }
            }
        }  // end of search for captures/blocks
    }

    // Now king moves -- just compute them normally:
    if (mask == EMPTY  ||  mask == KING) { GenKingMoves(mlist, genType); }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::TreeCalcAttacks():
//      Calculate attack score for a side on a square,
//      using a recursive tree search.
int Position::TreeCalcAttacks(squareT target) {
	MoveList moves;
	GenerateCaptures(&moves);
	auto it = std::partition(moves.begin(), moves.end(),
	                         [&](auto const& sm) { return sm.to == target; });
	moves.resize(std::distance(moves.begin(), it));

	if (moves.Size() == 0)
		return 0;

	if (piece_IsKing(Board[target]))
		return -1;

	int maxScore = -2;
	int zeroCount = 0;
	for (auto const& sm : moves) {
		DoSimpleMove(sm);
		int score = TreeCalcAttacks(target);
		UndoSimpleMove(sm);
		if (score == 0 && ++zeroCount > 1)
			return -2;
		if (score > maxScore)
			maxScore = score;
	}

	return (maxScore == 0) ? -1 : -maxScore;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::CalcAttacks():
//      Calculate the number of attacks by a side on a square.
//      This function also puts a list of the attacking piece squares
//      in the fromSqs parameter if it is non-NULL.
//
//      It ONLY uses the Board[] and Material[] lists of the Position, and
//      ASSUMES they are correct with respect to each other, but it does
//      NOT use the List[] or ListPos[] information.
//      This allows us to move pieces quickly (altering only Board[] and
//      Material[]) and detect whether they leave the king in check,
//      without having to update other information.
uint
Position::CalcAttacks (colorT side, squareT target, SquareList * fromSquares) const
{
    // If squares is NULL, caller doesn't want a list of the squares of
    // attacking pieces. To avoid comparing fromSquares with NULL every time
    // we find a check, we set up a local array to use instead if fromSquares
    // is NULL.
    SquareList fromSqs;
    if (fromSquares == NULL) { fromSquares = &fromSqs; }

    fromSquares->Clear();
    squareT sq;

    // Bishop/Queen/Rook attacks: look at each of the 8 directions
    pieceT king, queen, rook, bishop, knight;
    if (side == WHITE) {
        king = WK; queen = WQ; rook = WR; bishop = WB; knight = WN;
    } else {
        king = BK; queen = BQ; rook = BR; bishop = BB; knight = BN;
    }

    uint numQueensRooks = Material[queen] + Material[rook];
    uint numQueensBishops = Material[queen] + Material[bishop];

    // We only bother if there are any sliding pieces of each type:
    if (numQueensRooks > 0) {
        fyleT fyle = square_Fyle (target);
        rankT rank = square_Rank (target);
        directionT dirs[4];
        uint ndirs = 0;
        if (FyleCount(queen,fyle) + FyleCount(rook,fyle) > 0) {
            dirs[ndirs++] = UP;  dirs[ndirs++] = DOWN;
        }
        if (RankCount(queen,rank) + RankCount(rook,rank) > 0) {
            dirs[ndirs++] = LEFT; dirs[ndirs++] = RIGHT;
        }
        for (uint i = 0; i < ndirs; i++) {
            directionT dir = dirs[i];
            int delta = direction_Delta (dir);
            squareT dest = target;
            squareT last = square_Last (target, dir);

            while (dest != last) {
                dest += delta;
                pieceT p = Board[dest];
                if (p == EMPTY) {
                    // empty square: keep searching
                } else if (p == queen  ||  p == rook) {
                    // Found an attacking piece
                    fromSquares->Add(dest);
                    break;
                } else {
                    // Found a piece, but not a queen or rook
                    break;
                }
            }
        }
    }

    // Now diagonal sliders: Queens/Bishops:
    if (numQueensBishops > 0) {
        leftDiagT left = square_LeftDiag (target);
        rightDiagT right = square_RightDiag (target);
        directionT dirs[4];
        uint ndirs = 0;
        if (LeftDiagCount(queen,left) + LeftDiagCount(bishop,left) > 0) {
            dirs[ndirs++] = UP_LEFT;  dirs[ndirs++] = DOWN_RIGHT;
        }
        if (RightDiagCount(queen,right) + RightDiagCount(bishop,right) > 0) {
            dirs[ndirs++] = UP_RIGHT;  dirs[ndirs++] = DOWN_LEFT;
        }
        for (uint i = 0; i < ndirs; i++) {
            directionT dir = dirs[i];
            int delta = direction_Delta (dir);
            squareT dest = target;
            squareT last = square_Last (target, dir);

            while (dest != last) {
                dest += delta;
                pieceT p = Board[dest];
                if (p == EMPTY) {
                    // empty square: keep searching
                } else if (p == queen  ||  p == bishop) {
                    // Found an attacking piece
                    fromSquares->Add(dest);
                    break;
                } else {
                    // Found a piece, but not an enemy queen or bishop
                    break;
                }
            }
        }
    }

    // Now knight checks: we only bother if there is a knight on the
    // opposite square color of the target square color.
    if (Material[knight] > 0
         &&  SquareColorCount(knight, color_Flip(square_Color(target))) > 0) {
        const squareT * destPtr = knightAttacks[target];
        while (true) {
            squareT dest = *destPtr;
            if (dest == NULL_SQUARE) { break; }
            if (Board[dest] == knight) {
                fromSquares->Add(dest);
            }
            destPtr++;
        }
    }

    // Now pawn attacks:
    if (side == WHITE) {
        if (square_Rank(target) != RANK_1) {  //if (Material[WP] > 0) {
            sq = square_Move (target, DOWN_LEFT);
            if (Board[sq] == WP)  {
                fromSquares->Add(sq);
            }
            sq = square_Move (target, DOWN_RIGHT);
            if (Board[sq] == WP)  {
                fromSquares->Add(sq);
            }
        }
    } else {
        if (square_Rank(target) != RANK_8) {  //if (Material[BP] > 0) {
            sq = square_Move (target, UP_LEFT);
            if (Board[sq] == BP)  {
                fromSquares->Add(sq);
            }
            sq = square_Move (target, UP_RIGHT);
            if (Board[sq] == BP)  {
                fromSquares->Add(sq);
            }
        }
    }

    // King attacks:
    const squareT *destPtr = kingAttacks[target];
    do if (Board[*destPtr] == king) fromSquares->Add(*destPtr);
    while (*++destPtr != NULL_SQUARE);

    return fromSquares->Size();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::IsKingInCheck
//   Returns true if the king of the side to move is in check.
//   If the specified move is not NULL, it must be the legal move
//   that the opponent played to reach this position. This will
//   be used as a speed optimization, by skipping cases where the
//   move could not have left the king in check.
//
bool
Position::IsKingInCheck (simpleMoveT const& sm)
{
    pieceT p = (sm.promote == EMPTY) ? piece_Type(sm.movingPiece) : sm.promote;

    // No optimization of the last move was castling:
    if (sm.isCastle()) {
        return IsKingInCheck();
    }
    // No optimization for en passant capture:
    if (p == PAWN && piece_Type(sm.capturedPiece) == PAWN) {
        rankT fromRank = square_Rank(sm.from);
        rankT capturedRank = square_Rank(sm.capturedSquare);
        if (fromRank == capturedRank) {
            return IsKingInCheck();
        }
    }

    if (movegen::attack(sm.to, GetKingSquare(), color_Flip(ToMove), p,
                        [&](auto sq) { return GetPiece(sq) != EMPTY; }))
        return true;

    // Now look for a discovered check from a sliding piece:
    return xray_check(*this, sm.from, sm.to);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::Mobility
//    Returns the number of squares a rook or bishop of the specified
//    color would attack from the specified square.
uint
Position::Mobility (pieceT p, colorT color, squareT from)
{
    ASSERT (p == ROOK  ||  p == BISHOP);
    uint mobility = 0;
    directionT rookDirs[4] = { UP, DOWN, LEFT, RIGHT };
    directionT bishopDirs[4]
        = { UP_LEFT, UP_RIGHT, DOWN_LEFT, DOWN_RIGHT };
    directionT * dirPtr = (p == ROOK ? rookDirs : bishopDirs);

    for (uint i=0; i < 4; i++) {
        directionT dir = dirPtr[i];
        int delta = direction_Delta (dir);
        squareT dest = from;
        squareT last = square_Last (from, dir);

        while (dest != last) {
            dest += delta;
            pieceT p = Board[dest];
            if (p == EMPTY) {  // Empty square
                mobility++;
            } else if (piece_Color(p) == color) {  // Friendly piece
                break;  // Finished with this direction.
            } else {  // Enemy piece
                mobility++;
                break;  // Finished with this direction.
            }
        }
    }
    return mobility;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::IsKingInMate():
//      Quick check if king is in mate.
//
bool
Position::IsKingInMate (void)
{
    SquareList checkSquares;
    uint numChecks = CalcNumChecks (GetKingSquare(ToMove), &checkSquares);
    if (numChecks == 0) { return false; }
    CalcPins ();
    MoveList mlist;
    GenCheckEvasions (&mlist, EMPTY, GEN_ALL_MOVES, &checkSquares);
    if (mlist.Size() == 0) { return true; }
    return false;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::IsLegal()
//   Verifies the position as being legal.
//   Returns false for any of the following:
//     - if the two kings are adjacent;
//     - if there are any pawns on the 1st/8th rank;
//     - if the side to move is already checking the enemy king.
bool
Position::IsLegal (void)
{
    squareT stmKing = GetKingSquare();
    squareT enemyKing = GetEnemyKingSquare();
    if (square_Adjacent (stmKing, enemyKing)) { return false; }
    if (RankCount (WP, RANK_1) != 0) { return false; }
    if (RankCount (WP, RANK_8) != 0) { return false; }
    if (RankCount (BP, RANK_1) != 0) { return false; }
    if (RankCount (BP, RANK_8) != 0) { return false; }
    if (CalcAttacks (ToMove, enemyKing, NULL) > 0) {
         return false;
    }
    return true;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::IsPromoMove():
//      Returns true if the move is a promotion move.
//      NOTE that the move may not actually be legal!
//      The arguments 'from' and 'to' can be in either order.
bool
Position::IsPromoMove (squareT from, squareT to)
{
    rankT seventh, eighth;
    pieceT pawn;
    if (ToMove == WHITE) { seventh = RANK_7; eighth = RANK_8; pawn = WP; }
    else { seventh = RANK_2; eighth = RANK_1; pawn = BP; }
    rankT fromR, toR;
    fromR = square_Rank(from);
    toR = square_Rank(to);
    if ( (fromR == seventh  &&  toR == eighth  &&  Board[from] == pawn)  ||
         (toR == seventh  &&  fromR == eighth  &&  Board[to] == pawn) ) {
        return 1;
    }
    return 0;
}

/// Make a simpleMoveT.
/// If @e promo != INVALID_PIECE it is a special move:
/// promo == PAWN -> null move
/// from != to -> promotion
/// from == to && PAWN == KING -> castle kingside
/// from == to && PAWN != KING -> castle queenside
void Position::makeMove(squareT from, squareT to, pieceT promo,
                        simpleMoveT& res) const {
	res.castling = 0;
	if (promo == EMPTY || promo == INVALID_PIECE) { // NORMAL MOVE
		res.from = from;
		res.to = to;
		res.promote = EMPTY;
	} else if (promo == PAWN) { // NULL MOVE
		res.from = GetKingSquare(ToMove);
		res.to = res.from;
		res.promote = EMPTY;
		res.movingPiece = KING;
	} else if (from != to) { // PROMOTION
		res.from = from;
		res.to = to;
		res.promote = promo;
	} else { // CASTLING
		res.from = GetKingSquare(ToMove);
		if (isChess960()) {
			res.to = castleRookSq(ToMove, promo == KING);
		} else {
			res.to = res.from;
			res.to += promo == KING ? 2 : -2;
		}
		res.promote = EMPTY;
		res.castling = 1;
	}
	fillMove(res);
}

/// Use the current position to retrieve all the information needed to create a
/// SimpleMove which can also be used in UndoSimpleMove.
void Position::fillMove(simpleMoveT& sm) const {
	const auto from = sm.from;
	const auto to = sm.to;
	sm.movingPiece = GetPiece(sm.from);
	sm.pieceNum = ListPos[from];
	sm.castleFlags = Castling;
	sm.epSquare = EPTarget;
	sm.oldHalfMoveClock = HalfMoveClock;
	sm.capturedSquare = to;
	if (sm.isNullMove() || sm.isCastle()) {
		sm.capturedPiece = EMPTY;
	} else {
		sm.capturedPiece = GetPiece(to);
	}

	// Handle en passant capture:
	if (piece_Type(sm.movingPiece) == PAWN && sm.capturedPiece == EMPTY &&
	    square_Fyle(from) != square_Fyle(to)) {
		// This was an EP capture. We do not need to check it was a capture
		// since if a pawn lands on EPTarget it must capture to get there.
		sm.capturedSquare = WhiteToMove() ? to - 8 : to + 8;
		sm.capturedPiece = GetPiece(sm.capturedSquare);
		ASSERT(sm.capturedPiece == piece_Make(color_Flip(GetToMove()), PAWN));
	}

	if (sm.capturedPiece != EMPTY) {
		sm.capturedNum = ListPos[sm.capturedSquare];
	}
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::DoSimpleMove():
//      Make the move on the board and update all the necessary
//      fields in the simpleMove structure so it can be undone.
//
void
Position::DoSimpleMove (simpleMoveT * sm)
{
    ASSERT (sm != NULL);
    // update move fields that (maybe) have not yet been set:
	fillMove(*sm);
	DoSimpleMove(*sm);
}

void Position::DoSimpleMove(simpleMoveT const& sm) {
    const auto from = sm.from;
    const auto to = sm.to;
    const auto promo = sm.promote;
    const auto movingPiece = GetPiece(from);
    const auto ptype = piece_Type(movingPiece);
    const auto pieceNum = ListPos[from];
    const auto color = ToMove;
    const auto enemy = color_Flip(color);

    HalfMoveClock++;
    PlyCounter++;
    EPTarget = NULL_SQUARE;
    ToMove = enemy;

	auto addPiece = [&](auto idx, auto pieceType, squareT destSq) {
		List[color][idx] = destSq;
		ListPos[destSq] = idx;
		AddToBoard(piece_Make(color, pieceType), destSq);
	};

	if (sm.isNullMove())
		return;

	if (ptype == KING) {
		ClearCastlingFlags(color);
		if (auto castleSide = sm.isCastle()) {
			squareT rookfrom, rookto, kingTo;
			if (castleSide > 0) {
				kingTo = square_Relative(color, G1);
				rookfrom = castleRookSq(color, true);
				rookto = kingTo - 1;
			} else {
				kingTo = square_Relative(color, C1);
				rookfrom = castleRookSq(color, false);
				rookto = kingTo + 1;
			}
			const int kingIdx = 0;
			const int rookIdx = ListPos[rookfrom];
			RemoveFromBoard(piece_Make(color, ROOK), rookfrom);
			RemoveFromBoard(piece_Make(color, KING), GetKingSquare(color));
			addPiece(kingIdx, KING, kingTo);
			addPiece(rookIdx, ROOK, rookto);

			ASSERT(valid_sqlist(List[WHITE], Count[WHITE], Board));
			ASSERT(valid_sqlist(List[BLACK], Count[BLACK], Board));
			return;
		}
	}

    // handle captures:
    if (sm.capturedPiece != EMPTY) {
        ASSERT(piece_Type(sm.capturedPiece) != KING);
        ASSERT(piece_Color(sm.capturedPiece) == enemy);
        // update opponents List of pieces
        Count[enemy]--;
        ListPos[List[enemy][Count[enemy]]] = sm.capturedNum;
        List[enemy][sm.capturedNum] = List[enemy][Count[enemy]];
        Material[sm.capturedPiece]--;
        HalfMoveClock = 0;
        RemoveFromBoard (sm.capturedPiece, sm.capturedSquare);
    }

    // now make the move:
    RemoveFromBoard(movingPiece, from);
    if (promo != EMPTY) {
        ASSERT(movingPiece == piece_Make(color, PAWN));
        Material[movingPiece]--;
        Material[piece_Make(color, promo)]++;
        addPiece(pieceNum, promo, to);
    } else {
        addPiece(pieceNum, ptype, to);
    }

    // Handle clearing of castling flags:
    if (Castling) {
        // See if a rook moved or was captured:
		if (from == castleRookSq(color, false))
			ClearCastling(color, QSIDE);
		if (from == castleRookSq(color, true))
			ClearCastling(color, KSIDE);
		if (to == castleRookSq(enemy, false))
			ClearCastling(enemy, QSIDE);
		if (to == castleRookSq(enemy, true))
			ClearCastling(enemy, KSIDE);
    }

    // Set the EPTarget square, if a pawn advanced two squares and an
    // enemy pawn is on a square where en passant may be possible.
    if (ptype == PAWN) {
        rankT fromRank = square_Rank(from);
        rankT toRank = square_Rank(to);
        if (fromRank == RANK_2  &&  toRank == RANK_4
              &&  (Board[square_Move(to,LEFT)] == BP
                     ||  Board[square_Move(to,RIGHT)] == BP)) {
            EPTarget = square_Move(from, UP);
        }
        if (fromRank == RANK_7  &&  toRank == RANK_5
              &&  (Board[square_Move(to,LEFT)] == WP
                     ||  Board[square_Move(to,RIGHT)] == WP)) {
            EPTarget = square_Move(from, DOWN);
        }
        HalfMoveClock = 0; // 50-move clock resets on pawn moves.
	}

	ASSERT(valid_sqlist(List[WHITE], Count[WHITE], Board));
	ASSERT(valid_sqlist(List[BLACK], Count[BLACK], Board));
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::UndoSimpleMove():
//      Take back a simple move that has been made with DoSimpleMove().
//
void Position::UndoSimpleMove(simpleMoveT const& sm) {
    const squareT from = sm.from;
    const squareT to = sm.to;
    const auto pieceNum = ListPos[to];
    pieceT p = Board[to];
    EPTarget = sm.epSquare;
    Castling = sm.castleFlags;
    HalfMoveClock = sm.oldHalfMoveClock;
    PlyCounter--;
    ToMove = color_Flip(ToMove);

    // Check for a null move:
    if (sm.isNullMove()) {
        return;
    }

	auto addPiece = [&](auto idx, auto pieceType, squareT destSq) {
		List[ToMove][idx] = destSq;
		ListPos[destSq] = idx;
		AddToBoard(piece_Make(ToMove, pieceType), destSq);
	};

	// handle Castling:
		if (auto castleSide = sm.isCastle()) {
			const auto kingSq = GetKingSquare(ToMove);
			squareT rookfrom, rookto;
			if (castleSide > 0) {
				rookfrom = kingSq - 1;
				rookto = castleRookSq(ToMove, true);
			} else {
				rookfrom = kingSq + 1;
				rookto = castleRookSq(ToMove, false);
			}
			const int kingIdx = 0;
			const int rookIdx = ListPos[rookfrom];
			RemoveFromBoard(piece_Make(ToMove, KING), kingSq);
			RemoveFromBoard(piece_Make(ToMove, ROOK), rookfrom);
			addPiece(rookIdx, ROOK, rookto);
			addPiece(kingIdx, KING, from);

		    ASSERT(valid_sqlist(List[WHITE], Count[WHITE], Board));
		    ASSERT(valid_sqlist(List[BLACK], Count[BLACK], Board));
		    return;
		}

    // Handle a capture: insert piece back into piecelist.
    // This works for EP captures too, since the square of the captured
    // piece is in the "capturedSquare" field rather than assuming the
    // value of the "to" field. The only time these two fields are
    // different is for an en passant move.
    if (sm.capturedPiece != EMPTY) {
        colorT c = color_Flip(ToMove);
        ListPos[List[c][sm.capturedNum]] = Count[c];
        ListPos[sm.capturedSquare] = sm.capturedNum;
        List[c][Count[c]] = List[c][sm.capturedNum];
        List[c][sm.capturedNum] = sm.capturedSquare;
        Material[sm.capturedPiece]++;
        Count[c]++;
    }

    // handle promotion:
    if (sm.promote != EMPTY) {
        Material[p]--;
        RemoveFromBoard (p, to);
        p = piece_Make(ToMove, PAWN);
        Material[p]++;
        AddToBoard (p, to);
    }

    // now make the move:
    List[ToMove][pieceNum] = from;
    ListPos[from] = pieceNum;
    RemoveFromBoard (p, to);
    AddToBoard (p, from);
    if (sm.capturedPiece != EMPTY) {
        AddToBoard (sm.capturedPiece, sm.capturedSquare);
    }

    ASSERT(valid_sqlist(List[WHITE], Count[WHITE], Board));
    ASSERT(valid_sqlist(List[BLACK], Count[BLACK], Board));
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::MaterialValue():
//    Returns the sum value of material for a particular side,
//    where piece values are:
//    King: 0 (since both sides always have one)
//    Queen: 9
//    Rook: 5
//    Bishop, Knight: 3 each
//    Pawn: 1
uint
Position::MaterialValue (colorT c)
{
    ASSERT (c == WHITE  ||  c == BLACK);
    uint value = 0;
    if (c == WHITE) {
        value += 9 * PieceCount(WQ);
        value += 5 * PieceCount(WR);
        value += 3 * PieceCount(WB);
        value += 3 * PieceCount(WN);
        value += 1 * PieceCount(WP);
    } else {
        value += 9 * PieceCount(BQ);
        value += 5 * PieceCount(BR);
        value += 3 * PieceCount(BB);
        value += 3 * PieceCount(BN);
        value += 1 * PieceCount(BP);
    }
    return value;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::MakeSANString():
//      Make the SAN string for a simpleMove.
//      The parameter 'sanFlag' indicates whether '+' and '#' symbols
//      should be added to checking or mating moves.
//
void
Position::MakeSANString (simpleMoveT * m, char * s, sanFlagT flag)
{
    ASSERT (m != NULL  &&  s != NULL);
    ASSERT(m->from == List[ToMove][ListPos[m->from]]);
    const squareT from = m->from;
    const squareT to   = m->to;
    char * c     = s;
    pieceT piece = Board[from];
    pieceT p = piece_Type(piece);

    if (p == PAWN) {
        if (square_Fyle(from) != square_Fyle(to)) {  // pawn capture
            *c++ = square_FyleChar(from);
            *c++ = 'x';
        }
        *c++ = square_FyleChar(to);
        *c++ = square_RankChar(to);
        if ((square_Rank(to)==RANK_1) || (square_Rank(to)==RANK_8)) {
            *c++ = '=';
            *c++ = piece_Char(m->promote);
            p = piece_Type(m->promote);
        }

    } else if (p == KING) {
        if (m->isNullMove()) {
            //*c++ = 'n'; *c++ = 'u'; *c++ = 'l'; *c++ = 'l';
            *c++ = '-'; *c++ = '-';
        } else if (auto castle = m->isCastle()) {
            *c++ = 'O';
            *c++ = '-';
            *c++ = 'O';
            if (castle < 0) {
                *c++ = '-';
                *c++ = 'O';
            }
        } else {
            *c++ = 'K';
            if (Board[to] != EMPTY)
                *c++ = 'x';
            *c++ = square_FyleChar(to);
            *c++ = square_RankChar(to);
        }

    } else {    // Queen/Rook/Bishop/Knight
        *c++ = piece_Char(p);

        // We only need to calculate legal moves to disambiguate if there
        // are more than one of this type of piece.
        if (Material[piece] > 1) {
            int ambiguity = 0;
            for (uint i = 1, n = Count[ToMove]; i < n; i++) {
                squareT sq = List[ToMove][i];
                if (sq == from || Board[sq] != piece)
                    continue;

                if (pseudo_not_pinned(*this, sq, to, EMPTY) == NULL_SQUARE)
                    continue; // Skip illegal move

                // Ambiguity:
                // 1 (0001) --> need from-file (preferred) or from-rank
                // 3 (0011) --> need from-file
                // 5 (0101) --> need from-rank
                // 7 (0111) --> need both from-file and from-rank
                ambiguity |= 1;
                if (square_Rank(from) == square_Rank(sq)) {
                    ambiguity |= 2; // 0b0010
                } else if (square_Fyle(from) == square_Fyle(sq)) {
                    ambiguity |= 4; // 0b0100
                }
            }
            if (ambiguity) {
                if (ambiguity != 5)
                    *c++ = square_FyleChar(from); // print from-fyle
                if (ambiguity >= 5)
                    *c++ = square_RankChar(from); // print from-rank
            }
        }
        if (Board[to] != EMPTY)
            *c++ = 'x';
        *c++ = square_FyleChar(to);
        *c++ = square_RankChar(to);
    }

    // Now do the check or mate symbol:
    if (flag != SAN_NO_CHECKTEST) {
        // Now we make the move to test for check:
        DoSimpleMove (m);
        if (IsKingInCheck(*m)) {
            char ch = '+';
            if (flag == SAN_MATETEST) {
                MoveList mlist;
                GenerateMoves (&mlist);
                if (mlist.Size() == 0) { ch = '#'; }
            }
            *c++ = ch;
        }
        UndoSimpleMove (*m);
    }
    *c = 0;
}

// Make on the board a sequence of moves in coordinate notation.
// Convert and store the moves in SAN notation if @e toSAN is not nullptr.
errorT Position::MakeCoordMoves(const char* moves, size_t moveslen,
                                std::string* toSAN) {
    auto is_space = [](char ch) {
        return isspace(static_cast<unsigned char>(ch));
    };

    while (moveslen > 0 && is_space(moves[moveslen - 1])) {
        --moveslen; // Trim right
    }
    const char* end = moves + moveslen;
    moves = std::find_if_not(moves, end, is_space);

    while (auto len = std::find_if(moves, end, is_space) - moves) {
        simpleMoveT sm;
        if (auto err = ReadCoordMove(&sm, moves, len, false))
            return err;

        moves = std::find_if_not(moves + len, end, is_space);

        if (toSAN) {
            char san[8];
            MakeSANString(&sm, san,
                          moves != end ? SAN_CHECKTEST : SAN_MATETEST);
            if (WhiteToMove()) {
                toSAN->append(std::to_string(GetFullMoveCount()));
                toSAN->push_back('.');
            } else if (toSAN->empty()) {
                toSAN->append(std::to_string(GetFullMoveCount()));
                toSAN->append("...");
            }
            toSAN->append(san);
            if (moves != end)
                toSAN->push_back(' ');
        }

        DoSimpleMove(sm);
    }
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::ReadCoordMove():
//      Given a move in coordinate notation,
//      e.g. "e2e4" or "g1f3", generates the legal move it represents.
//      Returns: OK or ERROR_InvalidMove.
//      If "reverse" is true, coordinates in reverse order are acceptable,
//      e.g. "f3g1" for 1.Nf3.
//
errorT Position::ReadCoordMove(simpleMoveT* m, const char* str, size_t slen,
                               bool reverse) {
    ASSERT(m != NULL && str != NULL);

    auto promote = EMPTY;
    if (slen == 5) {
        promote = piece_FromChar(toupper(str[4]));
    } else if (slen != 4) {
        return ERROR_InvalidMove;
    }

    const auto fromFyle = fyle_FromChar(str[0]);
    const auto fromRank = rank_FromChar(str[1]);
    const auto toFyle = fyle_FromChar(str[2]);
    const auto toRank = rank_FromChar(str[3]);
    auto from = square_Make(fromFyle, fromRank);
    auto to = square_Make(toFyle, toRank);

    auto legal = IsLegalMove(from, to, promote);
    if (!legal && reverse) {
        std::swap(from, to);
        legal = IsLegalMove(from, to, promote);
    }
    if (!legal)
        return ERROR_InvalidMove;

    if (legal == 1) {
        makeMove(from, to, promote, *m);
    } else {
        makeMove(from, from, legal == 2 ? KING : QUEEN, *m);
    }
    return OK;
}

static size_t trimCheck(const char* str, size_t slen) {
	while (slen > 0) { // trim mate '#' or check '+'
		--slen;
		if (str[slen] != '#' && str[slen] != '+') {
			++slen;
			break;
		}
	}
	return slen;
}

errorT Position::ReadMovePawn(simpleMoveT* sm, const char* str, size_t slen,
                              fyleT frFyle) {
	ASSERT(sm != NULL && str != NULL && frFyle <= H_FYLE);

	if (slen < 2)
		return ERROR_InvalidMove;

	auto is_digit = [](char ch) {
		return isdigit(static_cast<unsigned char>(ch));
	};
	auto is_lower = [](char ch) {
		return islower(static_cast<unsigned char>(ch));
	};

	if (slen >= 4 && // Check if it is a coordinates-style move ("e2e4")
	    is_digit(str[1]) && is_lower(str[2]) && is_digit(str[3])) {
		return ReadCoordMove(sm, str, slen, true);
	}

	MoveList mlist;
	pieceT promo = EMPTY;
	auto last_ch = static_cast<unsigned char>(str[slen - 1]);
	if (!is_digit(last_ch)) {
		// Promotion, last char must be Q/R/B/N.
		promo = piece_FromChar(toupper(last_ch));
		if (promo != QUEEN && promo != ROOK && promo != KNIGHT &&
		    promo != BISHOP) {
			return ERROR_InvalidMove;
		}
		slen--;
		// Accept the move even if it is of the form "a8Q" not "a8=Q":
		if (str[slen - 1] == '=') {
			slen--;
		}
	}
	if (slen < 2)
		return ERROR_InvalidMove;

	auto isLegal = [&](fyleT toFyle, rankT toRank) {
		static_assert(NO_RANK > 8 && (NO_RANK - 1) > 8 && (NO_RANK + 1) > 8);
		const auto fromRank = (ToMove == WHITE) ? toRank - 1 : toRank + 1;
		if (toFyle > 8 || fromRank <= 0 || fromRank >= 8)
			return false;

		auto from = square_Make(frFyle, fromRank);
		const auto to = square_Make(toFyle, toRank);
		const auto pawn = piece_Make(ToMove, PAWN);
		if (GetPiece(from) == pawn && IsLegalMove(from, to, promo)) {
			makeMove(from, to, promo, *sm);
			return true;
		}
		if (frFyle == toFyle) {
			from += (ToMove == WHITE) ? -8 : +8;
			if (GetPiece(from) == pawn && IsLegalMove(from, to, promo)) {
				makeMove(from, to, promo, *sm);
				return true;
			}
		}
		return false;
	};

	const auto toFile = fyle_FromChar(str[slen - 2]);
	const auto toRank = rank_FromChar(str[slen - 1]);
	if (isLegal(toFile, toRank))
		return OK;

	// Check for the compact form of capture with no rank,
	// e.g. "ed" or "de=Q":
	if (slen == 2 && (str[1] >= 'a' && str[1] <= 'h')) {
		const auto compact_toFyle = fyle_FromChar(str[1]);
		for (rankT r = RANK_1; r <= RANK_8; r++) {
			if (isLegal(compact_toFyle, r))
				return OK;
		}
	}
	return ERROR_InvalidMove;
}

errorT Position::ReadMoveKing(simpleMoveT* sm, const char* str,
                              size_t slen) const {
	ASSERT(sm != NULL && str != NULL);

	if (slen < 3 || slen > 6)
		return ERROR_InvalidMove;

	auto toRank = rank_FromChar(str[slen - 1]);
	auto toFyle = fyle_FromChar(str[slen - 2]);
	if (toRank == NO_RANK || toFyle == NO_FYLE)
		return ERROR_InvalidMove;

	const auto from = GetKingSquare(ToMove);
	const auto to = square_Make(toFyle, toRank);
	const auto captured = GetPiece(to);
	if (!movegen::valid_king(from, to) || piece_Color(captured) == ToMove ||
	    piece_Type(captured) == KING)
		return ERROR_InvalidMove;

	// leaves the King in check:
	auto not_empty = [&](auto sq) {
		return sq != from && GetPiece(sq) != EMPTY;
	};
	if (under_attack(to, to, not_empty))
		return ERROR_InvalidMove;

	makeMove(from, to, INVALID_PIECE, *sm);
	return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::ReadMove():
//      Given a move in (possibly sloppy) PGN notation,
//      generates the legal move it corresponds to.
//      Returns: OK or ERROR_InvalidMove.
//
errorT Position::ReadMove(simpleMoveT* sm, const char* str, size_t slen,
                          pieceT piece) const {
	ASSERT(sm != NULL && str != NULL);
	ASSERT(piece == QUEEN || piece == ROOK || piece == BISHOP ||
	       piece == KNIGHT);

	if (slen < 3 || slen > 6)
		return ERROR_InvalidMove;

	auto toRank = rank_FromChar(str[slen - 1]);
	auto toFyle = fyle_FromChar(str[slen - 2]);
	if (toRank == NO_RANK || toFyle == NO_FYLE)
		return ERROR_InvalidMove;
	auto to = square_Make(toFyle, toRank);

	auto frFyle = NO_FYLE;
	auto frRank = NO_RANK;
	if (slen > 3) { // There is some ambiguity information in the input string.
		frFyle = fyle_FromChar(str[1]);
		frRank = rank_FromChar(str[1]);
		if (frRank == NO_RANK && slen > 4) {
			frRank = rank_FromChar(str[2]);
		}
	}

	// Loop through looking for pieces of the corresponding type. We start at 1
	// since the King is always the piece at position 0 in the list.
	int matchCount = 0;
	auto movingPiece = piece_Make(ToMove, piece);
	int nPieces = Material[movingPiece];
	for (unsigned i = 1, n = Count[ToMove]; i < n && nPieces; i++) {
		auto from = List[ToMove][i];
		if (Board[from] != movingPiece)
			continue;

		--nPieces;
		if ((frFyle != NO_FYLE && frFyle != square_Fyle(from)) ||
		    (frRank != NO_RANK && frRank != square_Rank(from)))
			continue;

		if (!IsLegalMove(from, to, EMPTY))
			continue;

		++matchCount;
		makeMove(from, to, INVALID_PIECE, *sm);
	}
	return (matchCount == 1) ? OK                 // ok.
	                         : ERROR_InvalidMove; // No match, or too many
	                                              // (ambiguous) moves match.
}

errorT Position::ReadMoveCastle(simpleMoveT* sm, std::string_view str) const {
	bool king_side = true;
	if (str == "O-O" || str == "OO") {
		// side = KSIDE;
	} else if (str == "O-O-O" || str == "OOO") {
		king_side = false; // QSIDE
	} else
		return ERROR_InvalidMove;

	const auto king_sq = GetKingSquare();
	makeMove(king_sq, king_sq, king_side ? KING : QUEEN, *sm);
	if (!under_attack(king_sq) && canCastle(king_side))
		return OK;

	return ERROR_InvalidMove;
}

errorT Position::ParseMove(simpleMoveT* sm, const char* str) {
	while (!isalpha(static_cast<unsigned char>(*str)) && *str != '\0') {
		str++; // trim left
	}
	const char* begin = str;
	while (!isspace(static_cast<unsigned char>(*str)) && *str != '\0') {
		str++; // trim right
	}
	return ParseMove(sm, begin, str);
}

// Parse a single move from SAN-style (Nf3) or UCI (g1f3) notation.
// If the move is legal, it stores the result in @e sm.
errorT Position::ParseMove(simpleMoveT* sm, const char* str,
                           const char* strEnd) {
	ASSERT(str != NULL);

	const auto length = trimCheck(str, std::distance(str, strEnd));
	if (length < 2 || length > 9)
		return ERROR_InvalidMove;

	static const auto piece_map = [] {
		auto res = std::array<uint8_t, 256>();
		std::fill(res.begin(), res.end(), INVALID_PIECE);
		res['a'] = res['A'] = PAWN | (A_FYLE << 4);
		res['b'] = PAWN | (B_FYLE << 4);
		res['c'] = res['C'] = PAWN | (C_FYLE << 4);
		res['d'] = res['D'] = PAWN | (D_FYLE << 4);
		res['e'] = res['E'] = PAWN | (E_FYLE << 4);
		res['f'] = res['F'] = PAWN | (F_FYLE << 4);
		res['g'] = res['G'] = PAWN | (G_FYLE << 4);
		res['h'] = res['H'] = PAWN | (H_FYLE << 4);
		res['k'] = res['K'] = KING;
		res['q'] = res['Q'] = QUEEN;
		res['r'] = res['R'] = ROOK;
		res['B'] = BISHOP;
		res['N'] = KNIGHT;
		res['o'] = res['O'] = 7; // CASTLE
		res['P'] = 8;            // explicit PAWN move
		return res;
	}();
	const auto ptype = piece_map[static_cast<unsigned char>(*str)];
	switch (ptype & 0x0F) {
	case INVALID_PIECE:
		// Check for a null move:
		if ((length == 2 && std::equal(str, str + 2, "--")) ||
		    (length == 2 && std::equal(str, str + 2, "Z0")) ||
		    (length == 4 && std::equal(str, str + 4, "null"))) {
			const auto king_sq = GetKingSquare(ToMove);
			makeMove(king_sq, king_sq, PAWN, *sm);
			return under_attack(king_sq) ? ERROR_InvalidMove : OK;
		}
		return ERROR_InvalidMove;
	case PAWN:
		return ReadMovePawn(sm, str, length, ptype >> 4);
	case KING:
		return ReadMoveKing(sm, str, length);
	case 7:
		return ReadMoveCastle(sm, {str, length});
	case 8:
		return ParseMove(sm, str + 1, strEnd);
	default:
		return ReadMove(sm, str, length, ptype);
	};
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::CalcSANStrings():
//      Calculate the SAN string for each move in the legal moves list.
//
void
Position::CalcSANStrings (sanListT *sanList, sanFlagT flag)
{
    MoveList mlist;
    GenerateMoves(&mlist);
    for (size_t i = 0, n = mlist.Size(); i < n; i++) {
        MakeSANString(mlist.Get(i), sanList->list[i], flag);
    }
    sanList->num = mlist.Size();
    sanList->current = true;
}

errorT
Position::ReadFromLongStr (const char * str)
{
    Clear();
    for (squareT sq=A1; sq <= H8; sq++) {
        if (str[sq] == '.') { continue; }
        pieceT p = pieceFromByte [(byte) str[sq]];
        if (p == EMPTY) { return ERROR_Corrupt; }
        if (AddPiece (p,sq) != OK) { return ERROR_Corrupt; }
    }
    switch (str[65]) {
    case 'w':
        SetToMove (WHITE);
        break;
    case 'b':
        SetToMove (BLACK);
        break;
    default:
        return ERROR_Corrupt;
    }
    ASSERT(valid_sqlist(List[WHITE], Count[WHITE], Board));
    ASSERT(valid_sqlist(List[BLACK], Count[BLACK], Board));
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::MakeLongStr():
//      Make a string representing the board. It will be 66 characters
//      long, encoding the 64 squares (in the order a1,b1,...,g8,h8
//      with white pieces in upper case, black pieces in lower case,
//      and empty squares as dots) then a space, and finally "w" or "b"
//      indicating the side to move. Example for the starting position:
//      "RNBQKBNRPPPPPPPP................................pppppppprbnqkbnr w"
//
void Position::MakeLongStr(char* str) const {
	ASSERT(str != NULL);
	char* s = str;
	for (squareT sq = A1; sq <= H8; sq++) {
		*s++ = PIECE_CHAR[Board[sq]];
	}
	*s++ = ' ';
	*s++ = (ToMove == WHITE ? 'w' : 'b');
	*s = 0;
}

//    Sets the position from the provided Null-terminated 33-byte
//    compact string.
//    The first 32 bytes contain the square valued, 4 bits per value,
//    for the square order A1, B1, ...., G8, H8.
//    The next byte contains the side to move, 1 for White or 2 for Black.
//    The final two bytes contain castling and en passant rights.
//    To ensure no bytes within the staring are zero-valued (so it
//    can be used as a regular null-terminated string), the value 1
//    is added to the color, castling and en passant fields.
void
Position::PrintCompactStr (char * cboard)
{
    for (uint i=0; i < 32; i++) {
        uint i2 = i << 1;
        cboard[i] = (byte)(Board[i2] << 4) | Board[i2+1];
    }
    cboard[32] = 1 + ToMove;
    cboard[33] = 1 + Castling;

    // Check that there really is an enemy pawn that might
    // be able to capture to the en passant square. For example,
    // if the EP square is c6 but there is no white pawn on
    // b5 or d5, then en passant should be ignored.

    squareT ep = EPTarget;
    if (ToMove == WHITE) {
        if (Board[square_Move (ep, DOWN_LEFT)] != WP  &&
            Board[square_Move (ep, DOWN_RIGHT)] != WP) { ep = NULL_SQUARE; }

    } else {
        if (Board[square_Move (ep, UP_LEFT)] != BP  &&
            Board[square_Move (ep, UP_RIGHT)] != BP) { ep = NULL_SQUARE; }

    }
    cboard[34] = 1 + ep;
    cboard[35] = 0;
}

template <typename AddPiece>
const char* FEN_parsePieces(const char* str, AddPiece add) {
    ASSERT(str);

    for (int row = 7; row >= 0; --row) {
        for (int col = 0; col < 8;) {
            const auto ch = *str++;
            if (ch == '/') {
                // A FEN string does not have to contain '/'s but if one
                // appears anywhere except the start of a row, it is an error:
                if (col != 0)
                    return nullptr;

            } else if (ch > '0' && ch < '9') {
                col += (ch - '0');
                if (col > 8)
                    return nullptr;

            } else {
                auto piece = pieceFromByte[static_cast<unsigned char>(ch)];
                if (piece == EMPTY)
                    return nullptr;

                if (!add(piece, static_cast<squareT>(row * 8 + col)))
                    return nullptr;

                col++;
            }
        }
    }
    return str;
}

/// Setup the position from a FEN string.
/// Note: the slashes usually found in Fen strings to mark the start
/// of a new row do not need to be present, but if they are, they must
/// appear at the actual start of a new row or the string will be
/// considered corrupt.
///
/// IMPORTANT: the shortcut of having a two-digit number to represent
/// a number of empty rows (e.g. "/24/" instead of "/8/8/8/") is NOT
/// accepted by this function.
///
/// It is not considered an error for the halfmove clock or fullmove
/// counter to be invalid, so this routine can also read positions
/// from EPD lines (which only share the first four fields with FEN).
errorT Position::ReadFromFEN(const char* str) {
    ASSERT (str != NULL);

    auto is_space = [](char ch) {
        return isspace(static_cast<unsigned char>(ch));
    };
    auto skip_spaces = [&]() {
        while (isspace(*str)) {
            str++;
        }
    };

    Clear();

    // Piece placement
    skip_spaces();
    str = FEN_parsePieces(str, [&](auto piece, auto sq){
        return this->AddPiece(piece, sq) == OK;
    });
    if (!str)
        return ERROR_InvalidFEN;

    // Allow an extra '/' char at the end (just ignore it).
    if (*str == '/') {
        ++str;
    }

    // Now the side to move:
    skip_spaces();
    switch (*str++) {
    case 'w':
        SetToMove (WHITE);
        break;
    case 'b':
        SetToMove (BLACK);
        break;
    default:
        return ERROR_InvalidFEN;
    }

    if (Material[WK] != 1 || Material[BK] != 1 || !IsLegal())
        return ERROR_InvalidFEN;

    // Now the castling flags:
    skip_spaces();
    if (*str == '-') {
        str++;  // do nothing
    } else if (*str == 0) {
        // The FEN has no castling field, so just guess that
        // castling is possible whenever a king and rook are
        // still on their starting squares:
        if (Board[E1] == WK) {
            if (Board[A1] == WR) { setCastling(WHITE, A1); }
            if (Board[H1] == WR) { setCastling(WHITE, H1); }
        }
        if (Board[E8] == BK) {
            if (Board[A8] == BR) { setCastling(BLACK, A8); }
            if (Board[H8] == BR) { setCastling(BLACK, H8); }
        }
    } else {
        while (!is_space(*str)  &&  *str != 0) {
            switch (*str++) {
            case 'Q':
                setCastling(WHITE, A1);
                break;
            case 'q':
                setCastling(BLACK, A8);
                break;
            case 'K':
                setCastling(WHITE, H1);
                break;
            case 'k':
                setCastling(BLACK, H8);
                break;
            case 'A':
                setCastling(WHITE, A1);
                break;
            case 'B':
                setCastling(WHITE, B1);
                break;
            case 'C':
                setCastling(WHITE, C1);
                break;
            case 'D':
                setCastling(WHITE, D1);
                break;
            case 'E':
                setCastling(WHITE, E1);
                break;
            case 'F':
                setCastling(WHITE, F1);
                break;
            case 'G':
                setCastling(WHITE, G1);
                break;
            case 'H':
                setCastling(WHITE, H1);
                break;
            case 'a':
                setCastling(BLACK, A8);
                break;
            case 'b':
                setCastling(BLACK, B8);
                break;
            case 'c':
                setCastling(BLACK, C8);
                break;
            case 'd':
                setCastling(BLACK, D8);
                break;
            case 'e':
                setCastling(BLACK, E8);
                break;
            case 'f':
                setCastling(BLACK, F8);
                break;
            case 'g':
                setCastling(BLACK, G8);
                break;
            case 'h':
                setCastling(BLACK, H8);
                break;
            default:
                return ERROR_InvalidFEN;
            }
        }
    }

    // Now the EP target:
    skip_spaces();
    if (*str == '-') {
        EPTarget = NULL_SQUARE;
        str++;  // No EP target
    } else if (*str) {
        char fylec = *str++;
        if (fylec < 'a'  ||  fylec > 'h') {
            return ERROR_InvalidFEN;
        }
        char rankc = *str++;
        if (rankc != '3'  &&  rankc != '6') {
            return ERROR_InvalidFEN;
        }
        EPTarget = square_Make(fyle_FromChar(fylec), rank_FromChar(rankc));
    }

    // Now the capture/pawn halfmove clock:
    skip_spaces();
    if (*str) {
        char* end;
        HalfMoveClock = (ushort)std::max(0l, strtol(str, &end, 10));
        str = end;
    }

    // Finally, the fullmove counter:
    skip_spaces();
    if (*str) {
        int i = atoi(str);
        if (i >= 1) {
            PlyCounter = (i - 1) * 2;
        }
    }
    if (ToMove == BLACK) { PlyCounter++; }
    ASSERT(valid_sqlist(List[WHITE], Count[WHITE], Board));
    ASSERT(valid_sqlist(List[BLACK], Count[BLACK], Board));
    return OK;
}

/// Setup the position from a FEN string or UCI "position".
/// Accept strings like "position startpos", "position startpos moves e2e4",
/// "FENSTRING", "FENSTRING moves e2e4", "position fen FENSTRING moves e2e4".
errorT Position::ReadFromFENorUCI(std::string_view str) {
    auto trimLeft = std::find_if_not(
        str.begin(), str.end(),
        [](char ch) { return isspace(static_cast<unsigned char>(ch)); });
    str.remove_prefix(trimLeft - str.begin());

    auto fen = str.substr(0, str.find("moves"));
    str.remove_prefix(fen.size());
    if (str.substr(0, 5) == "moves") {
        str.remove_prefix(5);
    }

    if (fen.substr(0, 17) == "position startpos") {
        *this = Position::getStdStart();
    } else {
        if (fen.substr(0, 12) == "position fen") {
            fen.remove_prefix(12);
        }
        if (auto err = ReadFromFEN(std::string(fen).c_str()))
            return err;
    }

    return MakeCoordMoves(str.data(), str.size());
}

void Position::PrintFEN(char* str) const {
    ASSERT(str != NULL);
    uint emptyRun, iRank, iFyle;
    for (iRank = 0; iRank < 8; iRank++) {
        const pieceT* pBoard = &(Board[(7 - iRank) * 8]);
        emptyRun = 0;
        if (iRank > 0) {
            *str++ = '/';
        }
        for (iFyle = 0; iFyle < 8; iFyle++, pBoard++) {
            if (*pBoard != EMPTY) {
                if (emptyRun) {
                    *str++ = (byte)emptyRun + '0';
                }
                emptyRun = 0;
                *str++ = PIECE_CHAR[*pBoard];
            } else {
                emptyRun++;
            }
        }
        if (emptyRun) {
            *str++ = (byte)emptyRun + '0';
        }
    }

    *str++ = ' ';
    *str++ = (ToMove == WHITE ? 'w' : 'b');

    // Add the castling flags and EP flag as well:
    *str++ = ' ';
    const auto no_flags = str;
    if (validCastlingFlag(WHITE, true)) {
        auto rook_sq = castleRookSq(WHITE, true);
        *str++ = isChess960() && rook_sq != find_castle_rook(WHITE, H1)
                     ? toupper(square_FyleChar(rook_sq))
                     : 'K';
    }
    if (validCastlingFlag(WHITE, false)) {
        auto rook_sq = castleRookSq(WHITE, false);
        *str++ = isChess960() && rook_sq != find_castle_rook(WHITE, A1)
                     ? toupper(square_FyleChar(rook_sq))
                     : 'Q';
    }
    if (validCastlingFlag(BLACK, true)) {
        auto rook_sq = castleRookSq(BLACK, true);
        *str++ = isChess960() && rook_sq != find_castle_rook(BLACK, H8)
                     ? square_FyleChar(rook_sq)
                     : 'k';
    }
    if (validCastlingFlag(BLACK, false)) {
        auto rook_sq = castleRookSq(BLACK, false);
        *str++ = isChess960() && rook_sq != find_castle_rook(BLACK, A8)
                     ? square_FyleChar(rook_sq)
                     : 'q';
    }
    if (str == no_flags) {
        *str++ = '-';
    }
    *str++ = ' ';

    // Now the EP target square:
    if (EPTarget == NULL_SQUARE) {
        *str++ = '-';
    } else {
        *str++ = square_FyleChar(EPTarget);
        *str++ = square_RankChar(EPTarget);
    }

    // Also print the Halfmove and ply counters:
    *str++ = ' ';
    sprintf(str, "%d %d", HalfMoveClock, (PlyCounter / 2) + 1);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::DumpHtmlBoard():
//      Prints the board in a format for use in HTML documents.
//      Assumes that the HTML document will be in a directory that
//      has a subdirectory bitmapsDir with files "bwr.gif", etc.
//      The numeric arguments are the pixel width and height for each
//      square -- if zero, then the bitmaps are not scaled.

// The following values define the available HTML styles.
// Style 0 has 40x40 non-transparent images in the "bitmaps" directory.
// Style 1 has 36x35 non-transparent images in the "bitmaps2" directory.

struct htmlStyleT {
    const char * dir;  // directory containing images.
    uint width;        // width value specified in <img> tag.
    uint height;       // height value specified in <img> tag.
    bool transparent;  // True if the style uses transparent images,
                       // with square colors set by "bgcolor".
};

void
Position::DumpHtmlBoard (DString * dstr, uint style, const char * dir, bool flip)
{
    const uint HTML_DIAG_STYLES = 2;
    htmlStyleT hs [HTML_DIAG_STYLES];
    hs[0].dir = "bitmaps"; hs[0].width = 40; hs[0].height = 40;
    hs[1].dir = "bitmaps2"; hs[1].width = 36; hs[1].height = 35;
    if (style >= HTML_DIAG_STYLES) { style = 0; }

    uint width = hs[style].width;
    uint height = hs[style].height;
    uint iRank, iFyle;
    pieceT * pBoard;
    if (dir == NULL) { dir = hs[style].dir; }

    dstr->Append ("<br><br><center>\n");
    dstr->Append ("<table Border=1 CellSpacing=0 CellPadding=0>\n");
    for (iRank = 0; iRank < 8; iRank++) {
        dstr->Append ("<tr>\n");
        pBoard = &(Board[(7 - iRank) * 8]);
        for (iFyle = 0; iFyle < 8; iFyle++, pBoard++) {
            pieceT piece = *pBoard;
            if (flip) { piece = Board[iRank * 8 + (7 - iFyle)]; }
            dstr->Append ("  <td><img border=0 ");
            if (width > 0) {
                char temp[40];
                sprintf (temp, "width=%u ", width);
                dstr->Append (temp);
            }
            if (height > 0) {
                char temp[40];
                sprintf (temp, "height=%u ", height);
                dstr->Append (temp);
            }
            dstr->Append ("src=\"");
            dstr->Append (dir);
            dstr->AddChar ('/');
            bool lightSq = ((iRank % 2) == (iFyle % 2));
            if (lightSq) {
                dstr->AddChar ('w');
            } else {
                dstr->AddChar ('b');
            }
            if (piece == EMPTY) {
                dstr->Append ("sq.gif");
            } else {
                colorT c = piece_Color(piece);
                dstr->AddChar (c == WHITE ? 'w' : 'b');
                dstr->AddChar (tolower (PIECE_CHAR[piece]));
                dstr->Append (".gif");
            }
            dstr->Append ("\" alt=\"");
            if (piece == EMPTY) {
                if (! lightSq) { dstr->Append ("::"); }
            } else {
                colorT c = piece_Color(piece);
                dstr->AddChar (c == WHITE ? 'W' : 'B');
                dstr->AddChar (toupper (PIECE_CHAR[piece]));
            }
            dstr->Append ("\"></td>\n");
        }
        dstr->Append ("</tr>\n");
    }
    dstr->Append ("</table>\n");
    //if (ToMove == WHITE) {
    //    dstr->Append ("<br><b>White to move.</b>\n");
    //} else {
    //    dstr->Append ("<br><b>Black to move.</b>\n");
    //}
    dstr->Append("</center><br>");
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::DumpLatexBoard():
//      Prints the board in a format used by a chess package that is
//      available for the LaTeX  or TeX typesetting language.
void
Position::DumpLatexBoard (DString * dstr, bool flip)
{
    uint iRank, iFyle;
    pieceT * pBoard;
    dstr->Append ("\\board{");
    for (iRank = 0; iRank < 8; iRank++) {
        pBoard = &(Board[(7 - iRank) * 8]);
        for (iFyle = 0; iFyle < 8; iFyle++, pBoard++) {
            pieceT piece = *pBoard;
            if (flip) { piece = Board[iRank * 8 + (7 - iFyle)]; }
            if (piece != EMPTY) {
                dstr->AddChar (PIECE_CHAR[piece]);
            } else { // put a space or a '*':
                dstr->AddChar (((iRank % 2) == (iFyle % 2)) ? ' ' : '*');
            }
        }
        if (iRank < 7) {
            dstr->Append ("}\n {");
        } else { dstr->AddChar ('}'); }
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::Compare():
//      Compare another position with this one.
//
sint
Position::Compare (Position * p)
{
    int i = 32;
    byte *p1, *p2;
    p1 = Board;
    p2 = p->Board;
    while (i   &&  *p1 == *p2) {
        i--;  p1++;  p2++;
    }
    if (p1 < p2) { return -1; }
    if (p1 > p2) { return 1; }
    return (ToMove - p->GetToMove());
}
