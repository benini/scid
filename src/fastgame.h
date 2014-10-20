/*
* Copyright (C) 2013-2014  Fulvio Benini

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
#include "game.h" //TODO: remove this dependency
#include <string.h>
#include <sstream>
#include <vector>


class FastGame {
public:
	static FastGame Create(const byte* v_begin, const byte* v_end) {
		const byte* v_it = v_begin;
		while (v_it < v_end) {
			byte b = *v_it++;
			if (b == 0) {
				if (v_it >= v_end) break; // Error
				byte haveFEN = *v_it++ & 1;
				if (haveFEN == 0) {
					// Position::ReadFromFEN doesn't create a valid Position for
					// standard starting board FEN (White pawns have wrong list IDX)
					// static FastGame std_start("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");
					static FastGame std_start;
					FastGame res(std_start);
					res.v_it_ = v_it;
					res.v_end_ = v_end;
					return res;
				} else {
					const char* FENstring = (char*) v_it;
					while (v_it < v_end) {
						if (*v_it++ == 0) return FastGame (FENstring, v_it, v_end);
					}
					break; // FEN error
				}
			} else if (b == 255) { // Skip special 3-byte binary encoding of EventDate
				v_it += 3;
			} else { // Skip tags
				if (b <= MAX_TAG_LEN) v_it += b;
				if (v_it < v_end) v_it += *v_it +1;
			}
		}

		return FastGame(""); // Error default to empty buffer and board
	}

	FullMove getMove(int startPly) {
		FullMove move;
		for (int ply=0; ply <= startPly; ply++, cToMove_ = 1 - cToMove_) {
			if (cToMove_ == WHITE) {
				if (! DecodeNextMove <WHITE>(&move)) break;
			} else {
				if (! DecodeNextMove <BLACK>(&move)) break;
			}

			if (ply == startPly) {
				fillSANInfo(move);
				cToMove_ = 1 - cToMove_;
				return move;
			}
		}
		return FullMove();
	}

	std::string getMoveSAN(int startPly, int count) {
		std::stringstream res;
		for (int ply=0; ply < startPly + count; ply++, cToMove_ = 1 - cToMove_) {
			FullMove move;
			if (cToMove_ == WHITE) {
				if (! DecodeNextMove <WHITE>(&move)) break;
				if (ply < startPly) continue;
				if (ply > startPly) res << "  ";
				res << (1 + ply/2) << ".";
			} else {
				if (! DecodeNextMove <BLACK>(&move)) break;
				if (ply < startPly) continue;
				if (ply == startPly) res << (1 + ply/2) << "...";
				else res << " ";
			}
			fillSANInfo(move);
			res << move.getSAN();
		}
		return res.str();
	}

	template <colorT toMove, class NP>
	int search(const byte* board, NP nPieces) {
		int ply = 1;
		memcpy(min_pieces_, nPieces, 16);

		if (cToMove_ != toMove) {
			if (! DecodeNextMove < (1 - toMove) > ()) return 0;
			ply += 1;
		}
		for (;;) {
			// Seem to be faster than memcmp
			const uint64_t* w = reinterpret_cast<uint64_t*>(nPieces_[WHITE]);
			const uint64_t* b = reinterpret_cast<uint64_t*>(nPieces_[BLACK]);
			const uint64_t* Sw = reinterpret_cast<uint64_t*>(nPieces[WHITE]);
			const uint64_t* Sb = reinterpret_cast<uint64_t*>(nPieces[BLACK]);
			if (*w == *Sw && *b == *Sb) {
				bool match = true;
				for (int i=0; i<nPieces_[WHITE][0]; ++i) {
					P_LIST* p = & list[WHITE][i];
					if (board[p->sq] != piece_Make(WHITE, p->piece)) { match = false; break; }
				}
				if (match) {
					for (int i=0; i<nPieces_[BLACK][0]; ++i) {
						P_LIST* p = & list[BLACK][i];
						if (board[p->sq] != piece_Make(BLACK, p->piece)) { match = false; break; }
					}
				}
				if (match) return ply; //Exact board found
			}
			if (! DecodeNextMove < (toMove) > ()) return 0;
			if (! DecodeNextMove < (1 - toMove) > ()) return 0;
			ply += 2;
		}
		return 0;
	}

private:
	uint8_t nPieces_[2][8];
	byte board_[64];
	struct P_LIST {
		squareT sq;
		pieceT piece;
	} list[2][16];
	const byte* v_it_;
	const byte* v_end_;
	uint8_t min_pieces_[2][8];
	colorT cToMove_;


	FastGame(const char* FEN, const byte* v_it = 0, const byte* v_end = 0)
	: v_it_ (v_it), v_end_(v_end) {
		memset(nPieces_, 0, sizeof(nPieces_));
		for (byte i=A1; i <= H8; i++) board_[i] = 0;

		Position StartPos;
		errorT err = StartPos.ReadFromFEN (FEN);
		if (err == OK) {
			for (byte c=0; c<2; c++) {
				nPieces_[c][0] = StartPos.GetCount(c);
				for (uint i=0; i< StartPos.GetCount(c); ++i) {
					squareT sq = StartPos.GetList(c)[i];
					pieceT piece = piece_Type(StartPos.GetBoard()[sq]);
					list[c][i].sq = sq;
					list[c][i].piece = piece;
					board_[sq] = i;
					nPieces_[c][piece] += 1;
				}
			}
			cToMove_ = StartPos.GetToMove();
		} else {
			v_it_ = v_end_ = 0;
			cToMove_ = WHITE;
			list[WHITE][0].sq = list[BLACK][0].sq = 0;
		}
		memset(min_pieces_, 0, sizeof(min_pieces_));
	}

	FastGame()
	: v_it_ (0), v_end_(0) {
		for (byte i=0; i < 8; i++) {
			const byte stdpos_count[] = {16, 1, 1, 2, 2, 2, 8, 0};
			const byte stdpos_sq[] = {E1, A1, B1, C1, D1, F1, G1, H1};
			const byte stdpos[] = {KING, ROOK, KNIGHT, BISHOP, QUEEN, BISHOP, KNIGHT, ROOK};

			nPieces_[WHITE][i] = nPieces_[BLACK][i] = stdpos_count[i];
			list[WHITE][i].sq = stdpos_sq[i];
			list[BLACK][i].sq = stdpos_sq[i] + 56;
			list[WHITE][i].piece = list[BLACK][i].piece = stdpos[i];
			board_[list[WHITE][i].sq] = board_[list[BLACK][i].sq] = i;

			list[WHITE][i+8].piece = list[BLACK][i+8].piece = PAWN;
			board_[A2+i] = board_[A7+i] = i+8;
			list[WHITE][i+8].sq = A2+i;
			list[BLACK][i+8].sq = A7+i;
		}
		for (byte i=A3; i <= H6; i++) board_[i] = 0;
		cToMove_ = WHITE;
		memset(min_pieces_, 0, sizeof(min_pieces_));
	};

	template <colorT toMove>
	inline bool doPly(byte v, FullMove* lastMove = 0) {
		const colorT enemy = 1 - toMove;
		byte idx_piece_moving = v >> 4;
		byte move = v & 0x0F;
		P_LIST* moving_piece = & list[toMove][idx_piece_moving];
		squareT from = moving_piece->sq;
		squareT to;
		pieceT promo = 0;
		if (lastMove) lastMove->clear();
		switch (moving_piece->piece) {
			case BISHOP: to = 0x3F & decodeBishop(from, move); break;
			case KNIGHT: to = 0x3F & decodeKnight(from, move); break;
			case ROOK: to = decodeRook(from, move); break;
			case QUEEN:
				if (move != square_Fyle(from)) to = decodeRook(from, move);
				else if (v_it_ < v_end_) to = 0x3F & (*v_it_++ - 64); //2 byte move
				else return false;
				break;
			case KING:
				if (move > 8) { // Castle
					return handleCastle<toMove> (move == 10, lastMove);
				} else if (move != 0) { // Normal move
					static const int sqdiff[] = { 0, -9, -8, -7, -1, 1, 7, 8, 9};
					to = 0x3F & (from + sqdiff[move]);
				} else { // NULL MOVE
					return true;
				}
				break;
			default: {// Default to PAWN
				static const int toSquareDiff [16] = { 7,8,9, 7,8,9, 7,8,9, 7,8,9, 7,8,9, 16 };
				to = 0x3F;
				to &= (toMove == WHITE) ? from + toSquareDiff[move] : from - toSquareDiff[move];
				switch (move) {
					case 15:
					case 1:
						break;
					case 0:
					case 2:
						if (board_[to] == 0) { //en passant
							squareT captured = 0x3F;
							captured &= (toMove == WHITE) ? to - 8 : to + 8;
							board_[to] = board_[captured];
							board_[captured] = 0;
						}
						break;
					default: { //Promotion
						static const pieceT promoPieceFromVal [16] = {
							EMPTY,EMPTY,EMPTY,QUEEN,QUEEN,QUEEN, ROOK,ROOK,ROOK,
							BISHOP,BISHOP,BISHOP,KNIGHT,KNIGHT,KNIGHT,EMPTY
						};
						promo = promoPieceFromVal[move];
					}
				}
			}
		}
		if (lastMove) lastMove->set(toMove, moving_piece->piece, from, to, promo);

		byte capt_idx = board_[to];
		board_[to] = idx_piece_moving;
		board_[from] = 0;
		moving_piece->sq = to;
		if (promo != 0) {
			moving_piece->piece = promo;
			nPieces_[toMove][PAWN]--;
			nPieces_[toMove][moving_piece->piece]++;
		}
		if (capt_idx != 0) {
			if (lastMove) {
				squareT capt_sq = list[enemy][capt_idx].sq;
				lastMove->setCapture(list[enemy][capt_idx].piece, capt_sq != to);
			}
			if (--nPieces_[enemy][0] < min_pieces_[enemy][0]) return false;
			--nPieces_[enemy][list[enemy][capt_idx].piece];
			if (nPieces_[enemy][PAWN] < min_pieces_[enemy][PAWN]) return false;
			if (capt_idx != nPieces_[enemy][0]) {
				list[enemy][capt_idx] = list[enemy][nPieces_[enemy][0]];
				board_[list[enemy][capt_idx].sq] = capt_idx;
			}
		}
		return true;
	}
	template <colorT toMove>
	inline bool handleCastle(bool king_side, FullMove* lastMove) {
		squareT black = (toMove == WHITE) ? 0 : 56;
		const uint king_idx = 0;
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
		if (lastMove) {
			lastMove->setCastle(toMove, list[toMove][king_idx].sq, rook_from);
		}
		list[toMove][king_idx].sq = king_to;
		byte rook_idx = board_[rook_from];
		list[toMove][rook_idx].sq = rook_to;
		board_[rook_to] = rook_idx;
		board_[rook_from] = 0;
		board_[king_to] = king_idx;
		// board_[king_from] = 0; //Is not necessary because King_idx == 0
		// ClearCastlingRights;
		return true;
	}
	static inline squareT decodeBishop (squareT from, byte val) {
		byte fyle = (val & 7);
		int fylediff = (int)fyle - (int)square_Fyle(from);
		if (val >= 8) return from - 7 * fylediff;
		else return from + 9 * fylediff;
	}
	static inline squareT decodeKnight (squareT from, byte val) {
		static const int sqdiff[] = { 0, -17, -15, -10, -6, 6, 10, 15, 17, 0, 0, 0, 0, 0, 0, 0 };
		ASSERT((from + sqdiff[val]) > 0);
		return from + sqdiff[val];
	}
	static inline squareT decodeRook (squareT from, byte val) {
		if (val >= 8) return square_Make (square_Fyle(from), (val - 8));
		else return square_Make (val, square_Rank(from));
	}

	enum { ENCODE_NAG = 11, ENCODE_COMMENT, ENCODE_START_MARKER, ENCODE_END_MARKER, ENCODE_END_GAME };
	enum { ENCODE_FIRST = 11, ENCODE_LAST = 15 };

	template <colorT toMove>
	inline bool DecodeNextMove(FullMove* lastMove = 0) {
		while (v_it_ < v_end_) {
			byte b = *v_it_++;
			if (b < ENCODE_FIRST || b > ENCODE_LAST) return doPly<toMove>(b, lastMove);
			if (b == ENCODE_END_GAME || b == ENCODE_END_MARKER) return false;
			if (b == ENCODE_NAG) {v_it_++; continue; }
			if (b == ENCODE_START_MARKER) {
				uint nestCount = 1;
				do {
					if (v_it_ >= v_end_) return false;
					switch (*v_it_++) {
					case ENCODE_NAG: v_it_++; break;
					case ENCODE_START_MARKER: nestCount++; break;
					case ENCODE_END_MARKER: nestCount--; break;
					case ENCODE_END_GAME: return false;
					}
				} while (nestCount > 0);
			}
		}
		return false;
	}

//TODO: improve this functions
	bool isCheck(colorT enemy, std::vector<squareT>* pinned =0) const {
		std::vector<squareT> checkers;
		colorT allies = 1 - enemy;
		int kingSq = list[allies][0].sq;

		static int pawn[] = { +7, +9, -7, -9 };
		for (uint i=0; i < 2; i++) {
			int sq = kingSq + pawn[i + (allies == WHITE ? 0: 2)];
			if (sq < 0 || sq > 63 || board_[sq] == 0) continue;
			byte idx = board_[sq];
			if (idx < nPieces_[enemy][0] && list[enemy][idx].sq == sq && list[enemy][idx].piece == PAWN) {
				checkers.push_back(sq);
			}
		}

		static int knight[] = { -17, -15, -10, -6, 6, 10, 15, 17 };
		for (uint i=0; i < sizeof(knight)/sizeof(int); i++) {
			int sq = kingSq + knight[i];
			if (sq < 0 || sq > 63 || board_[sq] == 0) continue;
			byte idx = board_[sq];
			if (idx < nPieces_[enemy][0] && list[enemy][idx].sq == sq && list[enemy][idx].piece == KNIGHT) {
				checkers.push_back(sq);
			}
		}

		static int walk[] = { +1, +1, +8, -8, -7, -9, +7, +9 };
		for (uint i=0; i < sizeof(walk)/sizeof(int); i++) {
			if (kingSq % 8 == 0 && walk[i] % 8 < 0) continue;
			if (kingSq % 8 == 7 && walk[i] % 8 > 0) continue;
			int pin = -1;
			for (int sq = kingSq + walk[i]; sq >= 0 && sq < 64; sq += walk[i]) {
				if (board_[sq] == 0) {
					if (sq % 8 == 0 || sq % 8 == 7) break;
					continue;
				}
				byte idx = board_[sq];
				if (idx < nPieces_[allies][0] && list[allies][idx].sq == sq) {
					if (sq % 8 == 0 || sq % 8 == 7) break;
					if (pin != -1) break;
					pin = sq;
					continue;
				}

				pieceT enemyP = list[enemy][idx].piece;
				if (enemyP == QUEEN || (enemyP == BISHOP && i > 3) || (enemyP == ROOK && i < 4)) {
					if (pin != -1) {
						if (pinned) pinned->push_back(pin);
					} else {
						checkers.push_back(sq);
					}
				}
				break;
			}
		}
		return checkers.size() != 0;
	}	

	void fillSANInfo(FullMove& move) const {
		pieceT piece = move.getPiece();
		colorT allies = move.getColor();
		std::vector<squareT> pinned;
		if (isCheck(allies, &pinned)) move.setCheck();
		if (piece == PAWN || piece == KING || piece == BISHOP || nPieces_[allies][piece] <= 1) return;
		for (uint8_t i=1; i < nPieces_[allies][0]; i++) { //i=1 because King_idx == 0
			if (list[allies][i].piece == piece && list[allies][i].sq != move.getFrom()) {
				bool moveable = true;
				for (uint j=0; j < pinned.size(); j++) {
					if (list[allies][i].sq == pinned[j]) moveable = false;
				}
				if (!moveable) continue;
				//Build the current board
				pieceT board[64];
				for (int j=0; j < nPieces_[WHITE][0]; j++) board[list[WHITE][j].sq] = list[WHITE][j].piece;
				for (int j=0; j < nPieces_[BLACK][0]; j++) board[list[BLACK][j].sq] = list[BLACK][j].piece | (1 << 3);
				//Undo the last move
				board[move.getFrom()] = move.getPiece() | (allies << 3);
				board[move.getTo()] = 0;
				pieceT captured = move.getCaptured();
				if (captured) board[move.getCaptSq()] = captured | (allies << 3);
				//Generate the moves and check for ambiguity
				std::vector<FullMove> m = generateMoves(board, list[allies][i].sq);
				for (uint j=0; j < m.size(); j++) move.setAmbiguous(m[j]);
			}
		}
	}

	std::vector<FullMove> generateMoves(const pieceT* board, squareT from) const {
		std::vector<FullMove> res;
		pieceT piece = piece_Type(board[from]);
		colorT enemy = 1 - piece_Color(board[from]);
		switch (piece) {
			case KNIGHT: {
				static int knight[] = { -17, -15, -10, -6, 6, 10, 15, 17 };
				for (uint i=0; i < sizeof(knight)/sizeof(int); i++) {
					int sq = from + knight[i];
					if (sq < 0 || sq > 63) continue;
					if (board[sq] != 0 && piece_Color(board[sq]) != enemy) continue;
					FullMove tmp;
					tmp.set(1 - enemy, piece, from, sq);
					if (board[sq] != 0) tmp.setCapture(piece_Type(board[sq]), false);
					res.push_back(tmp);
				}
				break;
			}
			case ROOK: { //TODO
				break;
			}

		}
		return res;
	}
};


#endif
