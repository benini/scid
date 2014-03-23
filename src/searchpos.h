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

#include "common.h"
#include "position.h"
#include "fastgame.h"


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
				if (progressEvery_++ >= 100) {
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
