/*
 * Copyright (C) 2017 Fulvio Benini
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

#include "bytebuf.h"
#include "fastgame.h"
#include "movelist.h"
#include <gtest/gtest.h>

namespace testdecode_legacy {

inline errorT decodeKing(byte val, simpleMoveT* sm) {
	static const int sqdiff[] = {0, -9, -8, -7, -1, 1, 7, 8, 9, -2, 2};

	if (val == 0) {
		sm->to = sm->from; // Null move
		return OK;
	}

	if (val < 1 || val > 10) {
		return ERROR_Decode;
	}
	sm->to = sm->from + sqdiff[val];
	return OK;
}

inline errorT decodeKnight(byte val, simpleMoveT* sm) {
	static const int sqdiff[] = {0, -17, -15, -10, -6, 6, 10, 15, 17};
	if (val < 1 || val > 8) {
		return ERROR_Decode;
	}
	sm->to = sm->from + sqdiff[val];
	return OK;
}

inline errorT decodeRook(byte val, simpleMoveT* sm) {
	if (val >= 8) {
		// This is a move along a Fyle, to a different rank:
		sm->to = square_Make(square_Fyle(sm->from), (val - 8));
	} else {
		sm->to = square_Make(val, square_Rank(sm->from));
	}
	return OK;
}

inline errorT decodeBishop(byte val, simpleMoveT* sm) {
	byte fyle = (val & 7);
	int fylediff = (int)fyle - (int)square_Fyle(sm->from);
	if (val >= 8) {
		// It is an up-left/down-right direction move.
		sm->to = sm->from - 7 * fylediff;
	} else {
		sm->to = sm->from + 9 * fylediff;
	}
	if (sm->to > H8) {
		return ERROR_Decode;
	}
	return OK;
}

inline errorT decodeQueen(ByteBuffer* buf, byte val, simpleMoveT* sm) {
	if (val >= 8) {
		// Rook-vertical move:
		sm->to = square_Make(square_Fyle(sm->from), (val - 8));

	} else if (val != square_Fyle(sm->from)) {
		// Rook-horizontal move:
		sm->to = square_Make(val, square_Rank(sm->from));

	} else {
		// Diagonal move: coded in TWO bytes.
		val = buf->GetByte();
		if (val < 64 || val > 127) {
			return ERROR_Decode;
		}
		sm->to = val - 64;
	}
	return OK;
}

inline errorT decodePawn(byte val, simpleMoveT* sm, colorT toMove) {
	static const int toSquareDiff[16] = {7, 8, 9, 7, 8, 9, 7, 8,
	                                     9, 7, 8, 9, 7, 8, 9, 16};

	static const pieceT promoPieceFromVal[16] = {
	    EMPTY, EMPTY,  EMPTY,  QUEEN,  QUEEN,  QUEEN,  ROOK,   ROOK,
	    ROOK,  BISHOP, BISHOP, BISHOP, KNIGHT, KNIGHT, KNIGHT, EMPTY};

	if (toMove == WHITE) {
		sm->to = sm->from + toSquareDiff[val];
	} else {
		sm->to = sm->from - toSquareDiff[val];
	}

	sm->promote = promoPieceFromVal[val];

	return OK;
}

} // namespace testdecode_legacy

namespace testdecode_generic {

inline int decodePieceIdx(byte v) { return v >> 4; }

/**
 * Decode a SCID4's move
 * @from: start square of the moving piece
 * @val: index of the target square
 *
 * Excluding queens, the other chess pieces cannot reach more than 16 target
 * squares from any given position. This allow to store the target square of
 * a move into 4 bits, as an index of all the possible target squares.
 * Return:
 * - the target square
 * Error handling:
 * - Debug code will check if the decoded value is a valid [0-63] square.
 * - Release code will force the returned valid to be a valid [0-63] square
 *   but, for performance reasons, do not report invalid encoded moves.
 */
template <typename TOpSimple, typename TOp2Bytes, typename TOpPawn,
          typename TOpCastle, typename TOpNull>
auto decodeMove(pieceT piece_type, squareT from, byte move,
                TOpSimple move_simple, TOp2Bytes move_2bytes, TOpPawn move_pawn,
                TOpCastle move_castle, TOpNull move_null) {
	move &= 0x0F;
	switch (piece_type) {
	case BISHOP: {
		auto offset = square_Fyle(move) - square_Fyle(from);
		offset *= (move >= 8) ? -7 : 9;
		return move_simple(from + offset);
	}
	case KING: {
		if (move == 0) { // null move
			return move_null();
		}
		if (move == 9) { // castle queen side
			return move_castle(false);
		}
		if (move == 10) { // castle king side
			return move_castle(true);
		}
		static constexpr int8_t king_mask[] = {0, -9, -8, -7, -1, 1, 7, 8,
		                                       9, 0,  0,  0,  0,  0, 0, 0};
		return move_simple(from + king_mask[move]);
	}
	case KNIGHT: {
		static constexpr int8_t knight_mask[] = {
		    0, -17, -15, -10, -6, 6, 10, 15, 17, 0, 0, 0, 0, 0, 0, 0};
		return move_simple(from + knight_mask[move]);
	}
	case QUEEN:
		if (move == square_Fyle(from)) {
			return move_2bytes();
		}
		/* FALLTHRU */
	case ROOK:
		if (move >= 8) { // This is a move along a Fyle, to a different rank:
			return move_simple(square_Make(square_Fyle(from), (move - 8)));
		} else {
			return move_simple(square_Make(move, square_Rank(from)));
		}
	};

	ASSERT(piece_type == PAWN);
	static const int8_t pawn_mask[] = {7, 8, 9, 7, 8, 9, 7, 8,
	                                   9, 7, 8, 9, 7, 8, 9, 16};
	static const pieceT pawn_promo[] = {
	    INVALID_PIECE, INVALID_PIECE, INVALID_PIECE, QUEEN,
	    QUEEN,         QUEEN,         ROOK,          ROOK,
	    ROOK,          BISHOP,        BISHOP,        BISHOP,
	    KNIGHT,        KNIGHT,        KNIGHT,        INVALID_PIECE};
	bool maybe_enpassant = (move == 0 || move == 2);
	return move_pawn(pawn_mask[move], pawn_promo[move], maybe_enpassant);
}

inline int decode2ndByte(byte val) { return val - 64; }

} // namespace testdecode_generic

namespace testdecode_fastgame {

static inline int decodeKing(squareT from, byte val) {
	ASSERT(val <= 8);
	static const int8_t sqdiff[] = {0, -9, -8, -7, -1, 1, 7, 8, 9};
	return from + sqdiff[val];
}
static inline int decodeQueen2byte(byte val) { return val - 64; }
static inline int decodeBishop(squareT from, byte val) {
	int fylediff = square_Fyle(val) - square_Fyle(from);
	return (val >= 8) ? from - 7 * fylediff //
	                  : from + 9 * fylediff;
}
static inline int decodeKnight(squareT from, byte val) {
	ASSERT(val <= 16);
	static const int8_t sqdiff[] = {0,  -17, -15, -10, -6, 6, 10, 15,
	                                17, 0,   0,   0,   0,  0, 0,  0};
	return from + sqdiff[val];
}
static inline int decodeRook(squareT from, byte val) {
	ASSERT(val <= 16);
	if (val >= 8) // vertical move
		return square_Make(square_Fyle(from), (val - 8));
	else // horizontal move
		return square_Make(val, square_Rank(from));
}
static inline int decodePawn(colorT color, squareT from, byte val,
                             pieceT& promo, bool& enPassant) {
	ASSERT(val <= 16);
	static const int8_t sqdiff[] = {7, 8, 9, 7, 8, 9, 7, 8,
	                                9, 7, 8, 9, 7, 8, 9, 16};
	static const pieceT promoPieceFromVal[] = {
	    0,    0,      0,      QUEEN,  QUEEN,  QUEEN,  ROOK,   ROOK,
	    ROOK, BISHOP, BISHOP, BISHOP, KNIGHT, KNIGHT, KNIGHT, 0};
	promo = promoPieceFromVal[val];
	enPassant = (val == 0 || val == 2);
	return (color == WHITE) ? from + sqdiff[val] //
	                        : from - sqdiff[val];
}

class make_simpleMoveT {
	simpleMoveT sm_;

public:
	make_simpleMoveT() { sm_.clear(); }

	make_simpleMoveT(colorT c, squareT from, squareT to, pieceT pt) {
		sm_.clear();
		sm_.movingPiece = piece_Make(c, pt);
		sm_.from = from;
		sm_.to = to;
		sm_.promote = EMPTY;
	}

	void setPromo(pieceT promo) { sm_.promote = promo; }

	operator bool() const { return sm_.promote != INVALID_PIECE; }
	const simpleMoveT& data() const { return sm_; }
};

template <typename TResult, typename TBuf>
TResult decodeMove(colorT toMove, pieceT moving_piece, squareT from, byte move,
                   TBuf& buf) {
	move &= 0x0F;

	int to;
	pieceT promo = INVALID_PIECE;
	bool enPassant = false;
	switch (moving_piece) {
	case PAWN:
		to = decodePawn(toMove, from, move, promo, enPassant);
		break;
	case BISHOP:
		to = decodeBishop(from, move);
		break;
	case KNIGHT:
		to = decodeKnight(from, move);
		if (from == to)
			return {}; // decode error

		break;
	case QUEEN:
		if (move == square_Fyle(from)) { // 2 BYTES MOVE
			to = decodeQueen2byte(buf.GetByte());
			break;
		}
		/* FALLTHRU */
	case ROOK:
		to = decodeRook(from, move);
		break;
	case KING:
		if (move == 0) { // NULL MOVE
			to = from;
			break;
		}
		if (move <= 8) {
			to = decodeKing(from, move);
			break;
		}
		if (move <= 10) { // CASTLE
			to = from + (move == 9 ? -2 : 2);
			break;
		}
		return {}; // decode error

	default:
		return {}; // decode error
	}

	if (to < 0 || to > 63)
		return {}; // decode error

	TResult res(toMove, from, to, moving_piece);
	if (promo != INVALID_PIECE)
		res.setPromo(promo);
	return res;
}

} // namespace testdecode_fastgame

TEST(Test_decodemove, legacy_generic) {
	ByteBuffer buf(1024);
	ByteBuffer buf2(1024);
	for (unsigned i = 0; i < 1024; ++i) {
		buf.PutByte(static_cast<byte>(i));
		buf2.PutByte(static_cast<byte>(i));
	}
	buf.BackToStart();
	buf2.BackToStart();

	for (const auto piece : {WP, BP, WN, WR, WB, WK, WQ}) {
		const colorT toMove = piece_Color(piece);
		for (squareT from = A1; from <= H8; ++from) {
			for (byte val = 0; val <= 16; ++val) {
				simpleMoveT sm_old{};
				sm_old.movingPiece = piece;
				sm_old.from = from;
				sm_old.promote = EMPTY;
				errorT err = ERROR_Decode;
				switch (piece_Type(sm_old.movingPiece)) {
				case PAWN:
					err = testdecode_legacy::decodePawn(val & 15, &sm_old,
					                                    toMove);
					break;
				case KNIGHT:
					err = testdecode_legacy::decodeKnight(val & 15, &sm_old);
					break;
				case ROOK:
					err = testdecode_legacy::decodeRook(val & 15, &sm_old);
					break;
				case BISHOP:
					err = testdecode_legacy::decodeBishop(val & 15, &sm_old);
					break;
				case KING:
					err = testdecode_legacy::decodeKing(val & 15, &sm_old);
					break;
				case QUEEN:
					err = testdecode_legacy::decodeQueen(&buf2, val & 15,
					                                     &sm_old);
				}

				simpleMoveT sm{};
				sm.movingPiece = piece;
				sm.from = from;
				sm.promote = EMPTY;
				auto res = testdecode_generic::decodeMove( //
				    piece_Type(sm.movingPiece), sm.from, val,
				    [&](int dest_sq) {
					    if (dest_sq == sm.from) {
						    if (sm.movingPiece == BISHOP ||
						        sm.movingPiece == QUEEN ||
						        sm.movingPiece == ROOK) {
							    // The legacy code allows equal "from" and
							    // "to" squares for BISHOPs, QUEEN and ROOKs.
						    } else {
							    return ERROR_Decode;
						    }
					    }

					    sm.to = dest_sq;

					    if (dest_sq < 0 || dest_sq > 63) {
						    if (sm.movingPiece == KING ||
						        sm.movingPiece == KNIGHT) {
							    // The legacy code allows invalid squares for
							    // KINGs and KNIGHTs
						    } else {
							    return ERROR_Decode;
						    }
					    }

					    return OK;
				    },
				    [&]() { // 2 BYTES
					    int dest_sq = buf.GetByte() - 64;
					    if (dest_sq < 0 || dest_sq > 63)
						    return ERROR_Decode;

					    sm.to = dest_sq;
					    return OK;
				    },
				    [&](int offset, pieceT promo, bool) { // PAWN
					    if (toMove == WHITE) {
						    sm.to = sm.from + offset;
					    } else {
						    sm.to = sm.from - offset;
					    }
					    if (promo != INVALID_PIECE) {
						    sm.promote = promo;
					    }
					    return OK;
				    },
				    [&](bool king_side) { // CASTLE
					    sm.to = sm.from + (king_side ? 2 : -2);
					    return OK;
				    },
				    [&]() { // NULL MOVE
					    sm.to = sm.from;
					    return OK;
				    });

				EXPECT_EQ(res, err);
				EXPECT_EQ(std::memcmp(&sm, &sm_old, sizeof sm), 0);
			}
		}
	}
}

TEST(Test_decodemove, legacy_fastgame) {
	ByteBuffer buf(1024);
	ByteBuffer buf2(1024);
	for (unsigned i = 0; i < 1024; ++i) {
		buf.PutByte(static_cast<byte>(i));
		buf2.PutByte(static_cast<byte>(i));
	}
	buf.BackToStart();
	buf2.BackToStart();

	for (const auto piece : {WP, BP, WN, WR, WB, WK, WQ}) {
		const colorT toMove = piece_Color(piece);
		for (squareT from = A1; from <= H8; ++from) {
			for (byte val = 0; val <= 16; ++val) {
				simpleMoveT sm_old{};
				sm_old.movingPiece = piece;
				sm_old.from = from;
				sm_old.promote = EMPTY;
				errorT err = ERROR_Decode;
				switch (piece_Type(sm_old.movingPiece)) {
				case PAWN:
					err = testdecode_legacy::decodePawn(val & 15, &sm_old,
					                                    toMove);
					break;
				case KNIGHT:
					err = testdecode_legacy::decodeKnight(val & 15, &sm_old);
					break;
				case ROOK:
					err = testdecode_legacy::decodeRook(val & 15, &sm_old);
					break;
				case BISHOP:
					err = testdecode_legacy::decodeBishop(val & 15, &sm_old);
					break;
				case KING:
					err = testdecode_legacy::decodeKing(val & 15, &sm_old);
					break;
				case QUEEN:
					err = testdecode_legacy::decodeQueen(&buf2, val & 15,
					                                     &sm_old);
				}
				if (sm_old.to > 63)
					err = ERROR_Decode;

				auto sm = testdecode_fastgame::decodeMove<
				    testdecode_fastgame::make_simpleMoveT>(
				    toMove, piece_Type(piece), from, val, buf);
				errorT res = sm ? OK : ERROR_Decode;

				ASSERT_EQ(res, err);
				ASSERT_TRUE(res != OK || std::memcmp(&sm.data(), &sm_old,
				                                     sizeof sm_old) == 0);
			}
		}
	}
}
