/*
* Copyright (C) 2013-2015  Fulvio Benini

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

#ifndef FASTGAME_H
#define FASTGAME_H

#include "common.h"
#include "fullmove.h"
#include "movegen.h"
#include "position.h"
#include <algorithm>
#include <cstdlib>
#include <cstring>
#include <sstream>
#include <string>

/// Store the number of pieces for each type and color.
class MaterialCount {
	int8_t n_[2][8] = {};

public:
	/// Add one piece.
	void incr(colorT color, pieceT piece_type) {
		ASSERT(color == 0 || color == 1);
		ASSERT(piece_type > 0 && piece_type < 8);

		++n_[color][0];
		++n_[color][piece_type];
	}

	/// Subtract one piece.
	void decr(colorT color, pieceT piece_type) {
		ASSERT(color == 0 || color == 1);
		ASSERT(piece_type > 0 && piece_type < 8);

		--n_[color][0];
		--n_[color][piece_type];
	}

	/// Return the total number of pieces of the specified color.
	int8_t count(colorT color) const {
		ASSERT(color == 0 || color == 1);

		return n_[color][0];
	}

	/// Return the number of pieces of the specified color and type.
	int8_t count(colorT color, pieceT piece_type) const {
		ASSERT(color == 0 || color == 1);
		ASSERT(piece_type > 0 && piece_type < 8);

		return n_[color][piece_type];
	}

	bool operator==(const MaterialCount& b) const {
		const int8_t* a = n_[0];
		const int8_t* b_ptr = b.n_[0];
		return std::equal(a, a + 16, b_ptr);
	}

	bool operator!=(const MaterialCount& b) const {
		return !operator==(b);
	}
};

/// Store the type and position of the pieces compatibly with the SCID4 coding.
class PieceList {
	struct {
		squareT sq;
		pieceT piece_type;
	} pieces_[2][16];

public:
	/// SCID4 encoded games must use index 0 for kings.
	int8_t getKingIdx() const { return 0; }

	/// Return the type of the piece with index @e idx
	pieceT getPieceType(colorT color, int idx) const {
		ASSERT(color == 0 || color == 1);
		ASSERT(idx >= 0 && idx < 16);

		return pieces_[color][idx].piece_type;
	}

	/// Return the square position of the piece with index @e idx
	squareT getSquare(colorT color, int idx) const {
		ASSERT(color == 0 || color == 1);
		ASSERT(idx >= 0 && idx < 16);

		return pieces_[color][idx].sq;
	}

	/// Change the square position of the piece with index @e idx
	void move(colorT color, int idx, squareT to) {
		ASSERT(color == 0 || color == 1);
		ASSERT(idx >= 0 && idx < 16);

		pieces_[color][idx].sq = to;
	}

	/// Change the type of the piece with index @e idx
	void promote(colorT color, int idx, pieceT piece_type) {
		ASSERT(color == 0 || color == 1);
		ASSERT(idx >= 0 && idx < 16);

		pieces_[color][idx].piece_type = piece_type;
	}

	/// Remove the piece with index @e removed_idx.
	/// Piece's indexes are important for decoding SCID4 moves:  when a piece is
	/// removed it's index is used by the last valid index @e lastvalid_idx.
	/// Return the square of the new piece with index @e removed_idx.
	squareT remove(colorT color, int removed_idx, int lastvalid_idx) {
		ASSERT(color == 0 || color == 1);
		ASSERT(removed_idx >= 0 && removed_idx < 16);
		ASSERT(lastvalid_idx >= 0 && lastvalid_idx < 16);

		pieces_[color][removed_idx] = pieces_[color][lastvalid_idx];
		return pieces_[color][lastvalid_idx].sq;
	}

	/// Set the type and square of the piece with index @e idx
	void set(colorT color, int idx, squareT sq, pieceT piece_type) {
		ASSERT(color == 0 || color == 1);
		ASSERT(idx >= 0 && idx < 16);
		ASSERT(piece_type != KING || idx == getKingIdx());

		pieces_[color][idx].sq = sq;
		pieces_[color][idx].piece_type = piece_type;
	}
};

class FastBoard {
	uint8_t board_[64];
	MaterialCount mt_;
	PieceList pieces_;

	enum { EMPTY_SQ_ = 0xFF };

public:
	FastBoard() {}
	FastBoard(Position& pos) { Init(pos); }

	void Init() {
		static Position StdStartPos(Position::getStdStart());
		static FastBoard StdStart(StdStartPos);
		*this = StdStart;
	}

	void Init(Position& pos) {
		std::fill_n(board_, 64, EMPTY_SQ_);

		for (auto color : {WHITE, BLACK}) {
			const auto pos_count = pos.GetCount(color);
			const auto pos_list = pos.GetList(color);
			for (uint8_t idx = 0; idx < 16; ++idx) {
				if (idx < pos_count) {
					const squareT sq = pos_list[idx];
					const pieceT piece_type = piece_Type(pos.GetPiece(sq));
					pieces_.set(color, idx, sq, piece_type);
					board_[sq] = idx;
					mt_.incr(color, piece_type);
				} else {
					pieces_.set(color, idx, 0, INVALID_PIECE);
				}
			}
		}
	}

	bool isEqual(const pieceT* board, const MaterialCount& mt_count) const {
		if (mt_ != mt_count)
			return false;

		for (int idx = 0, n = mt_.count(WHITE); idx < n; ++idx) {
			const auto sq = pieces_.getSquare(WHITE, idx);
			const auto pt = pieces_.getPieceType(WHITE, idx);
			if (board[sq] != piece_Make(WHITE, pt))
				return false;
		}
		for (int idx = 0, n = mt_.count(BLACK); idx < n; ++idx) {
			const auto sq = pieces_.getSquare(BLACK, idx);
			const auto pt = pieces_.getPieceType(BLACK, idx);
			if (board[sq] != piece_Make(BLACK, pt))
				return false;
		}
		return true;
	}

	const MaterialCount& materialCount() const {
		return mt_;
	}

	squareT getSquare(colorT color, int idx) const {
		return pieces_.getSquare(color, idx);
	}

	pieceT getPiece(colorT color, int idx) const {
		return pieces_.getPieceType(color, idx);
	}

	// TODO: error detection
	template <colorT color> squareT castle(bool king_side) {
		const squareT black = (color == WHITE) ? 0 : 56;
		squareT king_to, rook_from, rook_to;
		if (king_side) { // King Side
			king_to = black + G1;
			rook_from = black + H1;
			rook_to = black + F1;
		} else { // Queen Side
			king_to = black + C1;
			rook_from = black + A1;
			rook_to = black + D1;
		}
		const uint8_t rook_idx = board_[rook_from];
		const auto king_idx = pieces_.getKingIdx();
		const squareT king_from = pieces_.getSquare(color, king_idx);
		pieces_.move(color, rook_idx, rook_to);
		pieces_.move(color, king_idx, king_to);
		board_[rook_to] = rook_idx;
		board_[king_to] = king_idx;
		board_[rook_from] = EMPTY_SQ_;
		board_[king_from] = EMPTY_SQ_;
		return rook_from;
	}

	template <colorT color>
	pieceT move(uint8_t idx, squareT to, pieceT promo) {
		if (promo != INVALID_PIECE) {
			pieces_.promote(color, idx, promo);
			mt_.incr(color, promo);
			mt_.decr(color, PAWN);
		}
		const auto from = pieces_.getSquare(color, idx);
		board_[from] = EMPTY_SQ_;
		pieces_.move(color, idx, to);
		return remove<1 - color>(to, idx);
	}

	template <colorT color>
	pieceT remove(squareT sq, uint8_t newIdx = EMPTY_SQ_) {
		const uint8_t oldIdx = board_[sq];
		board_[sq] = newIdx;
		if (oldIdx == EMPTY_SQ_)
			return INVALID_PIECE;

		pieceT removed_pt =  pieces_.getPieceType(color, oldIdx);
		mt_.decr(color, removed_pt);
		int lastvalid_idx = mt_.count(color);
		if (oldIdx != lastvalid_idx) {
			squareT moved_sq = pieces_.remove(color, oldIdx, lastvalid_idx);
			board_[moved_sq] = oldIdx;
		}
		return removed_pt;
	}

	/**
	 * Given the actual board position, find if the last move needs to be made
	 * unambiguous and if it gives check (or TODO mate), and then sets the
	 * appropriate bits in @e lastmove.
	 * @param lastmove: the last move played.
	 */
	void fillSANInfo(FullMove& lastmove) {
		squareT lastFrom = lastmove.getFrom();
		squareT lastTo = lastmove.getTo();
		colorT lastCol = lastmove.getColor();
		pieceT lastPt = lastmove.getPiece();

		if (lastPt == PAWN) {
			if (lastmove.isPromo())
				lastPt = lastmove.getPromo();
		} else if (mt_.count(lastCol, lastPt) > 1) {
			int ambiguity = ambiguousMove(lastFrom, lastTo, lastCol, lastPt);
			if (ambiguity)
				lastmove.setAmbiguity(ambiguity != 5, ambiguity >= 5);
		}

		// Look for checks
		ASSERT(mt_.count(WHITE) >= 1 && mt_.count(BLACK) >= 1);

		const squareT enemyKingSq = getKingSquare(color_Flip(lastCol));
		bool direct_check = lastPt != KING && movegen::attack<uint8_t>(
		                                          lastTo, enemyKingSq, lastCol,
		                                          lastPt, board_, EMPTY_SQ_);
		if (direct_check || // Look for a discovered check
		    find_attacker_slider(enemyKingSq, lastCol) >= 0) {
			lastmove.setCheck();

			// TODO: Find if it's mate:
			// - it's not mate if the king can move to a safe square
			// - it's mate if it's double check or the attacker cannot be
			//   captured or blocked.
		}
	}

private:
	squareT getKingSquare(colorT color) {
		return pieces_.getSquare(color, pieces_.getKingIdx());
	}

	int ambiguousMove(squareT lastFrom, squareT lastTo, colorT lastCol,
	                  pieceT lastPt) {
		int ambiguity = 0;

		const squareT kingSq = getKingSquare(lastCol);
		const colorT enemyCol = color_Flip(lastCol);
		for (int i = 1, n = mt_.count(lastCol); i < n; i++) {
			if (getPiece(lastCol, i) != lastPt)
				continue; // Skip: different type

			const squareT sq = getSquare(lastCol, i);
			if (sq == lastTo)
				continue; // Skip: this is the analyzed piece

			board_[lastFrom] = board_[sq];
			board_[sq] = EMPTY_SQ_;

			bool pseudoLegal = movegen::pseudo<uint8_t>(
			    sq, lastTo, lastCol, lastPt, board_, EMPTY_SQ_);

			std::pair<pieceT, squareT> pin;
			if (pseudoLegal)
				pin = movegen::opens_ray<uint8_t>(sq, lastTo, kingSq, board_,
				                                  EMPTY_SQ_);
			board_[sq] = board_[lastFrom];
			board_[lastFrom] = EMPTY_SQ_;

			if (!pseudoLegal)
				continue; // Skip: illegal move

			if (pin.first != INVALID_PIECE) {
				uint8_t idx = board_[pin.second];
				if (idx != EMPTY_SQ_ && idx < mt_.count(enemyCol) &&
				    getSquare(enemyCol, idx) == pin.second) {
					const pieceT pt = getPiece(enemyCol, idx);
					if (pt == QUEEN || pt == pin.first)
						continue; // Skip: pinned piece
				}
			}

			// Ambiguity:
			// 1 (0001) --> need from-file (preferred) or from-rank
			// 3 (0011) --> need from-file
			// 5 (0101) --> need from-rank
			// 7 (0111) --> need both from-file and from-rank
			ambiguity |= 1;
			if (square_Rank(lastFrom) == square_Rank(sq)) {
				ambiguity |= 2; // 0b0010
			} else if (square_Fyle(lastFrom) == square_Fyle(sq)) {
				ambiguity |= 4; // 0b0100
			}
		}

		return ambiguity;
	}

	int find_attacker_slider(squareT destSq, colorT color) {
		for (int idx = 0, n = mt_.count(color); idx < n; ++idx) {
			const pieceT pt = getPiece(color, idx);
			if (pt != QUEEN && pt != ROOK && pt != BISHOP)
				continue;

			const squareT sq = getSquare(color, idx);
			if (movegen::attack_slider<uint8_t>(sq, destSq, pt, board_,
			                                    EMPTY_SQ_)) {
				return idx;
			}
		}
		return -1;
	}
};

class FastGame {
	FastBoard board_;
	const byte* v_it_;
	const byte* v_end_;
	colorT cToMove_;

public:
	static FastGame Create(const byte* v_begin, const byte* v_end) {
		const byte* v_it = v_begin;
		while (v_it < v_end) {
			byte b = *v_it++;
			if (b == 0) {
				if (v_it >= v_end) break; // Error
				byte haveFEN = *v_it++ & 1;
				if (haveFEN == 0) {
					return FastGame(v_it, v_end);
				} else {
					const char* FENstring = (char*) v_it;
					while (v_it < v_end) {
						if (*v_it++ == 0) return FastGame(FENstring, v_it, v_end);
					}
					break; // FEN error
				}
			} else if (b == 255) { // Skip special 3-byte binary encoding of EventDate
				v_it += 3;
			} else { // Skip tags
				enum { MAX_TAG_LEN = 240 };
				if (b <= MAX_TAG_LEN) v_it += b;
				if (v_it < v_end) v_it += *v_it +1;
			}
		}

		return FastGame(0,0); // Error default to StdStart and empty buffer
	}

	FullMove getMove(int ply_to_skip) {
		for (int ply=0; ply <= ply_to_skip; ply++, cToMove_ = 1 - cToMove_) {
			auto move = (cToMove_ == WHITE)
			                ? DecodeNextMove<FullMove, WHITE>()
			                : DecodeNextMove<FullMove, BLACK>();
			if (!move)
				break;

			if (ply == ply_to_skip) {
				board_.fillSANInfo(move);
				cToMove_ = 1 - cToMove_;
				return move;
			}
		}
		return {};
	}

	std::string getMoveSAN(int ply_to_skip, int count) {
		std::stringstream res;
		for (int ply=0; ply < ply_to_skip + count; ply++, cToMove_ = 1 - cToMove_) {
			FullMove move;
			if (cToMove_ == WHITE) {
				move = DecodeNextMove <FullMove, WHITE>();
				if (!move)
					break;
				if (ply < ply_to_skip) continue;
				if (ply > ply_to_skip) res << "  ";
				res << (1 + ply/2) << ".";
			} else {
				move = DecodeNextMove <FullMove, BLACK>();
				if (!move)
					break;
				if (ply < ply_to_skip) continue;
				if (ply == ply_to_skip) res << (1 + ply/2) << "...";
				else res << " ";
			}
			board_.fillSANInfo(move);
			res << move.getSAN();
		}
		return res.str();
	}

	template <colorT toMove>
	int search(const byte* board, const MaterialCount& mt_count) {
		int ply = 1;
		auto less_material = [](const MaterialCount& a, const MaterialCount& b,
		                        const colorT color, const auto move) {
			if (!move)
				return true;

			const auto captured_pt = move.getCaptured();
			if (captured_pt == INVALID_PIECE)
				return false;

			if (a.count(color) < b.count(color))
				return true;

			return a.count(color, PAWN) + a.count(color, captured_pt) <
			       b.count(color, PAWN) + b.count(color, captured_pt);
		};

		if (cToMove_ != toMove) {
			const auto move = DecodeNextMove<FullMove, 1 - toMove>();
			if (!move)
				return 0;
			ply += 1;
		}
		for (;;) {
			if (board_.isEqual(board, mt_count))
				return ply;

			{
				const auto move = DecodeNextMove<FullMove, toMove>();
				if (less_material(board_.materialCount(), mt_count, 1 - toMove,
				                  move))
					return 0;
			}
			{
				const auto move = DecodeNextMove<FullMove, 1 - toMove>();
				if (less_material(board_.materialCount(), mt_count, toMove,
				                  move))
					return 0;
			}

			ply += 2;
		}
		return 0;
	}

private:
	FastGame(const byte* v_it, const byte* v_end)
	: v_it_ (v_it), v_end_(v_end), cToMove_(WHITE) {
		board_.Init();
	}

	FastGame(const char* FEN, const byte* v_it, const byte* v_end)
	: v_it_ (v_it), v_end_(v_end) {
		Position StartPos;
		if (FEN == 0 || StartPos.ReadFromFEN(FEN) != OK) StartPos.StdStart();
		board_.Init(StartPos);
		cToMove_ = StartPos.GetToMove();
	}

	template <typename TResult, colorT toMove>
	TResult DecodeNextMove() {
		enum { ENCODE_NAG = 11, ENCODE_COMMENT, ENCODE_START_MARKER, ENCODE_END_MARKER, ENCODE_END_GAME };
		enum { ENCODE_FIRST = 11, ENCODE_LAST = 15 };

		while (v_it_ < v_end_) {
			byte b = *v_it_++;
			if (b < ENCODE_FIRST || b > ENCODE_LAST) return doPly<TResult, toMove>(b);
			if (b == ENCODE_END_GAME || b == ENCODE_END_MARKER) return {};
			if (b == ENCODE_NAG) {v_it_++; continue; }
			if (b == ENCODE_START_MARKER) {
				int nestCount = 1;
				do {
					if (v_it_ >= v_end_) return {};
					switch (*v_it_++) {
					case ENCODE_NAG: v_it_++; break;
					case ENCODE_START_MARKER: nestCount++; break;
					case ENCODE_END_MARKER: nestCount--; break;
					case ENCODE_END_GAME: return {};
					}
				} while (nestCount > 0);
			}
		}
		return {};
	}

	template <typename TResult, colorT toMove> TResult doPly(byte v) {
		byte idx_piece_moving = v >> 4;
		byte move = v & 0x0F;
		pieceT moving_piece = board_.getPiece(toMove, idx_piece_moving);
		squareT from = board_.getSquare(toMove, idx_piece_moving);
		int to;
		pieceT promo = INVALID_PIECE;
		bool enPassant = false;
		switch (moving_piece) {
		case PAWN:
			to = decodePawn<toMove>(from, move, promo, enPassant);
			break;
		case BISHOP:
			to = decodeBishop(from, move);
			break;
		case KNIGHT:
			to = decodeKnight(from, move);
			break;
		case QUEEN:
			if (move == square_Fyle(from)) { // 2 BYTES MOVE
				if (v_it_ >= v_end_)
					return {}; // decode error

				to = decodeQueen2byte(*v_it_++);
				break;
			}
			/* FALLTHRU */
		case ROOK:
			to = decodeRook(from, move);
			break;
		case KING:
			if (move == 0) { // NULL MOVE
				return TResult(toMove, 0, 0, KING);
			}
			if (move <= 8) {
				to = decodeKing(from, move);
				break;
			}
			if (move <= 10) { // CASTLE
				const squareT rook_from = board_.castle<toMove>(move == 10);
				return TResult(toMove, from, rook_from);
			}
			return {}; // decode error

		default:
			return {}; // decode error
		}

		if (to < 0 || to > 63)
			return {}; // decode error

		pieceT captured = board_.move<toMove>(idx_piece_moving, to, promo);
		TResult res(toMove, from, to, moving_piece);
		if (promo != INVALID_PIECE)
			res.setPromo(promo);
		if (captured != INVALID_PIECE) {
			res.setCapture(captured, false);
		} else if (enPassant) {
			squareT sq = (toMove == WHITE) ? to - 8 : to + 8;
			captured = board_.remove<1 - toMove>(0x3F & sq);
			res.setCapture(captured, true);
		}
		return res;
	}

	/**
	 * decode*() - decode a move from Scid format
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
	static inline int decodeKing(squareT from, byte val) {
		ASSERT(val <= 8);
		static const int8_t sqdiff[] = {0, -9, -8, -7, -1, 1, 7, 8, 9};
		return from + sqdiff[val];
	}
	static inline int decodeQueen2byte(byte val) {
		return val - 64;
	}
	static inline int decodeBishop(squareT from, byte val) {
		int fylediff = square_Fyle(val) - square_Fyle(from);
		return (val >= 8) ? from - 7 * fylediff //
		                  : from + 9 * fylediff;
	}
	static inline int decodeKnight(squareT from, byte val) {
		ASSERT(val <= 16);
		static const int8_t sqdiff[] = {0, -17, -15, -10, -6, 6, 10, 15, 17, 0, 0, 0, 0, 0, 0, 0};
		return from + sqdiff[val];
	}
	static inline int decodeRook(squareT from, byte val) {
		ASSERT(val <= 16);
		if (val >= 8) // vertical move
			return square_Make(square_Fyle(from), (val - 8));
		else // horizontal move
			return square_Make(val, square_Rank(from));
	}
	template <colorT color>
	static inline int decodePawn(squareT from, byte val, pieceT& promo,
	                             bool& enPassant) {
		ASSERT(val <= 16);
		static const int8_t sqdiff [] = { 7,8,9, 7,8,9, 7,8,9, 7,8,9, 7,8,9, 16 };
		static const pieceT promoPieceFromVal [] = {
			0,0,0,QUEEN,QUEEN,QUEEN, ROOK,ROOK,ROOK, BISHOP,BISHOP,BISHOP,KNIGHT,KNIGHT,KNIGHT,0
		};
		promo = promoPieceFromVal[val];
		enPassant = (val == 0 || val == 2);
		return (color == WHITE) ? from + sqdiff[val] //
		                        : from - sqdiff[val];
	}
};


#endif
