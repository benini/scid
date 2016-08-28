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

#ifndef SEARCHPOS_H
#define SEARCHPOS_H

#include "common.h"
#include "position.h"
#include "stored.h"
#include "fastgame.h"


class SearchPos {
public:
	SearchPos(Position* pos) {
		for (int i=0; i<8; ++i) {
			nPieces_[WHITE][i] = 0;
			nPieces_[BLACK][i] = 0;
		}
		pieceT* board = pos->GetBoard();
		squareT wkSq = 0;
		squareT bkSq = 0;
		for (squareT i = 0; i < 64; ++i) {
			board_[i] = board[i];
			if (board[i] != EMPTY) {
				++nPieces_[piece_Color(board[i])][0];
				++nPieces_[piece_Color(board[i])][piece_Type(board[i])];
				if (board[i] == WK) wkSq = i;
				else if (board[i] == BK) bkSq = i;
			}
		}
		toMove_ = pos->GetToMove();
		isStdStard_ = pos->IsStdStart();

		if (wkSq != E1 && wkSq != G1 && bkSq != E8 && bkSq != G8) {
			unusualKingPos_ = true;
			storedLine_ = 0;
		} else {
			unusualKingPos_ = false;
			storedLine_ = new StoredLine(board, toMove_);
		}

		//Home Pawn Signature
		uint16_t hps = ~static_cast<uint16_t>(pos->GetHPSig());
		hpSig_ = hps;
		for (ply_count_ = 0; hps != 0; ply_count_++) hps &= hps -1; //popcnt

		//MatSig
		msig_ = matsig_Make (pos->GetMaterial());
	}

	~SearchPos() {
		if (storedLine_) delete storedLine_;
	}

	bool setFilter(scidBaseT* base, HFilter& filter, const Progress& progress) {
		if (! isStdStard_) {
			int i=0;
			if (unusualKingPos_) i += 1;
			if (toMove_ == BLACK) i += 2;
			switch (i) {
				case 0: return SetFilter<WHITE, true> (base, filter, progress);
				case 1: return SetFilter<WHITE, false>(base, filter, progress);
				case 2: return SetFilter<BLACK, true> (base, filter, progress);
				case 3: return SetFilter<BLACK, false>(base, filter, progress);
			}
		}
		for (uint i = 0, n = base->numGames(); i < n; i++) {
			const IndexEntry* ie = base->getIndexEntry (i);
			if (! ie->GetStartFlag()) filter.set (i, 1);
			else {
				FastGame game = base->getGame(ie);
				int ply = game.search<WHITE>(board_, nPieces_);
				filter.set (i, (ply > 255) ? 255 : ply);
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
	matSigT msig_;
	colorT toMove_;

	SearchPos(const SearchPos&);
	SearchPos& operator=(const SearchPos&);
	template <colorT TOMOVE, bool STOREDLINE>
	bool SetFilter (scidBaseT* base, HFilter& filter, const Progress& prg) {
		filter->clear();
		long progress = 0;
		for (uint i = 0, n = base->numGames(); i < n; i++) {
			const IndexEntry* ie = base->getIndexEntry(i);
			if (! ie->GetStartFlag()) {
				if (STOREDLINE) {
					int ply = storedLine_->match(ie->GetStoredLineCode());
					if (ply >= 0) {
						filter.set (i, static_cast<byte> (ply +1));
						continue;
					}
					if (ply < -1) continue;
				}
				if (! HPSigCanMatch(ie->GetHomePawnData())) continue;
			}
			if (!matsig_isReachable (msig_, ie->GetFinalMatSig(), ie->GetPromotionsFlag(), ie->GetUnderPromoFlag())) continue;

			int ply = base->getGame(ie).search<TOMOVE>(board_, nPieces_);
			if (ply != 0) filter.set(i, (ply > 255) ? 255 : ply);

			if ((progress++ % 200) == 0) {
				if (!prg.report(i, n)) return false;
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
