/*
* Copyright (C) 2013  Fulvio Benini

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

#ifndef SEARCHPOS_H
#define SEARCHPOS_H

#include <stdint.h>
#include "common.h"
#include "position.h"

class FastGame {
public:
	static
	FastGame Create(byte* v_begin, byte* v_end) {
		byte* v_it = v_begin;
		while (v_it < v_end) {
			byte b = *v_it++;
			if (b == 0) {
				if (v_it >= v_end) break; // Error
				byte haveFEN = *v_it++ & 1;
				if (haveFEN == 0) {
					// Position::ReadFromFEN doesn't create a valid Position for
					// standard starting board FEN (White pawns have wrong list IDX)
					// static FastGame std_start("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");
					static FastGame std_start(true);
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
				if (v_it < v_end) v_it += *v_it++;
			}
		}
		return FastGame(""); // Error default to empty buffer and board
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
				if (match)
				for (int i=0; i<nPieces_[BLACK][0]; ++i) {
					P_LIST* p = & list[BLACK][i];
					if (board[p->sq] != piece_Make(BLACK, p->piece)) { match = false; break; }
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
	byte board[64];
	struct P_LIST {
		squareT sq;
		pieceT piece;
	} list[2][16];
	byte* v_it_;
	byte* v_end_;
	uint8_t min_pieces_[2][8];
	colorT cToMove_;


	FastGame(const char* FEN, byte* v_it = 0, byte* v_end = 0)
	: v_it_ (v_it), v_end_(v_end) {
		for (int i=1; i<8; ++i) nPieces_[WHITE][i] = nPieces_[BLACK][i] = 0;
		for (byte i=A1; i <= H8; i++) board[i] = 0;

		Position StartPos;
		errorT err = StartPos.ReadFromFEN (FEN);
		if (err == OK) {
			for (int c=0; c<2; c++) {
				nPieces_[c][0] = StartPos.GetCount(c);
				for (uint i=0; i< StartPos.GetCount(c); ++i) {
					squareT sq = StartPos.GetList(c)[i];
					pieceT piece = piece_Type(StartPos.GetBoard()[sq]);
					list[c][i].sq = sq;
					list[c][i].piece = piece;
					board[sq] = i;
					nPieces_[c][piece] += 1;
				}
			}
			cToMove_ = StartPos.GetToMove();
		} else {
			cToMove_ = WHITE;
			list[WHITE][0].sq = list[BLACK][0].sq = 0;
		}
		memset(min_pieces_, 0, 16);
	}

	FastGame(bool stdstart_dummy)
	: v_it_ (0), v_end_(0) {
		for (uint i=0; i < 8; i++) {
			const byte stdpos_count[] = {16, 1, 1, 2, 2, 2, 8, 0};
			const byte stdpos_sq[] = {E1, A1, B1, C1, D1, F1, G1, H1};
			const byte stdpos[] = {KING, ROOK, KNIGHT, BISHOP, QUEEN, BISHOP, KNIGHT, ROOK};

			nPieces_[WHITE][i] = nPieces_[BLACK][i] = stdpos_count[i];
			list[WHITE][i].sq = stdpos_sq[i];
			list[BLACK][i].sq = stdpos_sq[i] + 56;
			list[WHITE][i].piece = list[BLACK][i].piece = stdpos[i];
			board[list[WHITE][i].sq] = board[list[BLACK][i].sq] = i;

			list[WHITE][i+8].piece = list[BLACK][i+8].piece = PAWN;
			board[A2+i] = board[A7+i] = i+8;
			list[WHITE][i+8].sq = A2+i;
			list[BLACK][i+8].sq = A7+i;
		}
		for (byte i=A3; i <= H6; i++) board[i] = 0;
		cToMove_ = WHITE;
		memset(min_pieces_, 0, 16);
	};

	template <colorT toMove>
	inline bool doPly(byte v) {
		const colorT enemy = 1 - toMove;
		uint idx_piece_moving = v >> 4;
		uint move = v & 0x0F;
		P_LIST* moving_piece = & list[toMove][idx_piece_moving];
		squareT from = moving_piece->sq;
		squareT to;
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
					return handleCastle<toMove> (move == 10);
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
						if (board[to] == 0) { //en passant
							squareT captured = 0x3F;
							captured &= (toMove == WHITE) ? to - 8 : to + 8;
							board[to] = board[captured];
							board[captured] = 0;
						}
						break;
					default: { //Promotion
						static const pieceT promoPieceFromVal [16] = { EMPTY,EMPTY,EMPTY,QUEEN,QUEEN,QUEEN,
						                    ROOK,ROOK,ROOK,BISHOP,BISHOP,BISHOP,KNIGHT,KNIGHT,KNIGHT,EMPTY};
						moving_piece->piece = promoPieceFromVal[move];
						nPieces_[toMove][PAWN]--;
						nPieces_[toMove][moving_piece->piece]++;
					}
				}
			}
		}
		uint capt_idx = board[to];
		board[to] = idx_piece_moving;
		board[from] = 0;
		moving_piece->sq = to;
		if (capt_idx != 0) {
			if (--nPieces_[enemy][0] < min_pieces_[enemy][0]) return false;
			--nPieces_[enemy][list[enemy][capt_idx].piece];
			if (nPieces_[enemy][PAWN] < min_pieces_[enemy][PAWN]) return false;
			if (capt_idx != nPieces_[enemy][0]) {
				list[enemy][capt_idx] = list[enemy][nPieces_[enemy][0]];
				board[list[enemy][capt_idx].sq] = capt_idx;
			}
		}
		return true;
	}
	template <colorT toMove>
	inline bool handleCastle(bool king_side) {
		uint black = (toMove == WHITE) ? 0 : 56;
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
		byte rook_idx = board[rook_from];
		list[toMove][rook_idx].sq = rook_to;
		board[rook_to] = rook_idx;
		board[rook_from] = 0;
		list[toMove][king_idx].sq = king_to;
		board[king_to] = king_idx;
//		board[king_from] = 0; //Is not necessary because King_idx == 0
//		ClearCastlingRights;
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
		return from + sqdiff[val];
	}
	static inline squareT decodeRook (squareT from, byte val) {
		if (val >= 8) return square_Make (square_Fyle(from), (val - 8));
		else return square_Make (val, square_Rank(from));
	}

	enum { ENCODE_NAG = 11, ENCODE_COMMENT, ENCODE_START_MARKER, ENCODE_END_MARKER, ENCODE_END_GAME };
	enum { ENCODE_FIRST = 11, ENCODE_LAST = 15 };

	template <colorT toMove>
	inline bool DecodeNextMove() {
		while (v_it_ < v_end_) {
			byte b = *v_it_++;
			if (b < ENCODE_FIRST || b > ENCODE_LAST) return doPly<toMove>(b);
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
};



template <const bool progress = false>
class SearchPos {
public:
	SearchPos(Position* pos, bool  (*progressFn)(double) = 0) {
		for (int i=0; i<8; ++i) {
			nPieces_[WHITE][i] = 0;
			nPieces_[BLACK][i] = 0;
		}
		pieceT* board = pos->GetBoard();
		for (int i = 0; i < 64; ++i) {
			board_[i] = board[i];
			if (board[i] != EMPTY) {
				++nPieces_[piece_Color(board[i])][0];
				++nPieces_[piece_Color(board[i])][piece_Type(board[i])];
				if (board[i] == WK) wk_pos_ = i;
				else if (board[i] == BK) bk_pos_ = i;
			}
		}
		toMove_ = pos->GetToMove();
		isStdStard_ = pos->IsStdStart();

		if (wk_pos_ != E1 && wk_pos_ != G1 && wk_pos_ != C1 &&
			bk_pos_ != E8 && bk_pos_ != G8 && bk_pos_ != C1) {
			unusualKingPos_ = true;
			storedLine_ = 0;
		} else {
			unusualKingPos_ = false;
			storedLine_ = new StoredLine(pos);
		}

		//Home Pawn Signature
		uint16_t i = ~static_cast<uint16_t>(pos->GetHPSig());
		hpSig_ = i;
		for (ply_count_ = 0; i; ply_count_++) i &= i -1; //popcnt

		//MatSig
		msig_ = matsig_Make (pos->GetMaterial());

		progressFn_ = progressFn;
		progressEvery_ = 0;
	}

	~SearchPos() {
		if (storedLine_) delete storedLine_;
	}

	bool setFilter(scidBaseT* base, Filter* filter) {
		if (! isStdStard_) {
			if (toMove_ == WHITE) return SetFilter<WHITE>(base, filter);
			return SetFilter<BLACK>(base, filter);
		}
		for (uint i=0; i < base->numGames; i++) {
			IndexEntry* ie = base->idx->FetchEntry (i);
			if (! ie->GetStartFlag()) filter->Set (i, 1);
			else {
				base->gfile->ReadGame (base->bbuf, ie->GetOffset(),	ie->GetLength());
				FastGame game = FastGame::Create(base->bbuf->GetBuffer(), base->bbuf->GetBuffer() + base->bbuf->GetByteCount());
				int ply = game.search<WHITE>(board_, nPieces_);
				filter->Set (i, (ply > 255) ? 255 : ply);
			}
		}
		return true;
	}

private:
	uint8_t nPieces_[2][8];
	byte board_[64];
	StoredLine* storedLine_;
	uint hpSig_;
	uint ply_count_;
	bool isStdStard_;
	bool unusualKingPos_;
	squareT wk_pos_, bk_pos_;
	matSigT msig_;
	colorT toMove_;
	bool  (*progressFn_)(double);
	long progressEvery_;

	template <colorT TOMOVE>
	bool SetFilter (scidBaseT* base, Filter* filter) {
		if (!unusualKingPos_) return SetFilter<TOMOVE, false>(base, filter);
		return SetFilter<TOMOVE, true>(base, filter);
	}
	template <colorT TOMOVE, bool KINGPOS>
	bool SetFilter (scidBaseT* base, Filter* filter) {
		filter->Fill(0);
		for (uint i=0; i < base->numGames; i++) {
			IndexEntry* ie = base->idx->FetchEntry (i);
			if (! ie->GetStartFlag()) {
				if (! HPSigCanMatch(ie->GetHomePawnData())) continue;
				if (! KINGPOS) {
					uint ply = 0;
					simpleMoveT sm;
					if (! storedLine_->CanMatch(ie->GetStoredLineCode(), &ply, &sm)) continue;
					if (ply != 0) {
						filter->Set (i, (byte) ply);
						continue;
					}
				}
			}
			if (!matsig_isReachable (msig_, ie->GetFinalMatSig(), ie->GetPromotionsFlag(), ie->GetUnderPromoFlag())) continue;

			base->gfile->ReadGame (base->bbuf, ie->GetOffset(),	ie->GetLength());
			FastGame game = FastGame::Create(base->bbuf->GetBuffer(), base->bbuf->GetBuffer() + base->bbuf->GetByteCount());
			int ply = game.search<TOMOVE>(board_, nPieces_);
			if (ply != 0) filter->Set(i, (ply > 255) ? 255 : ply);

			if (progress) {
				if (progressEvery_++ >= 500) {
					if (!progressFn_ (static_cast<double> (i) / base->numGames)) return false;
					progressEvery_ = 0;
				}
			}
		}
		return true;
	}

	bool HPSigCanMatch(const byte* v) {
		if (ply_count_ == 16) return *v == ply_count_;
//		if (ply_count_ == 0 || *v == 0) return true; //*v == 0 if !ie->GetStartFlag()
		if (*v++ < ply_count_) return false;
		uint res = 0;
		for (uint i = 0; i < ply_count_/2; ++i) {
			res |= 1 << (*v >> 4);
			res |= 1 << (*v++ & 0x0F);
		}
		if (ply_count_ & 1) res |= 1 << (*v >> 4);
		return res == hpSig_;
	}
};


#endif
