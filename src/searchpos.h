/*
* Copyright (C) 2013-2018  Fulvio Benini

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

/** @file
 * Defines the classes used to search for positions.
 */

#ifndef SEARCHPOS_H
#define SEARCHPOS_H

#include "common.h"
#include "fastgame.h"
#include "matsig.h"
#include "position.h"
#include "stored.h"
#include <algorithm>
#include <memory>

/// Store the number of pieces for each type and color.
class MaterialCount {
	uint8_t nPieces_[2][8];

public:
	MaterialCount() {
		std::fill_n(nPieces_[WHITE], 8, 0);
		std::fill_n(nPieces_[BLACK], 8, 0);
	}

	const auto& data() const {
		return nPieces_;
	}

	/// Add one piece.
	void incr(pieceT piece) {
		++nPieces_[piece_Color(piece)][0];
		++nPieces_[piece_Color(piece)][piece_Type(piece)];
	}

	/// Return true if there is a piece's count which is greater than its
	/// counterpart in @e end_material.
	/// @param promo: pawns' difference is considered when comparing queen.
	/// @param upromo: minor pieces' count is not compared.
	bool extraMaterial(matSigT end_material, bool promo, bool upromo) const {
		auto extra_wpawn = static_cast<int>(MATSIG_Count_WP(end_material)) -
		                   nPieces_[WHITE][PAWN];
		auto extra_bpawn = static_cast<int>(MATSIG_Count_BP(end_material)) -
		                   nPieces_[BLACK][PAWN];
		if (extra_wpawn > 0 || extra_bpawn > 0)
			return true;

		auto extra_wqueen = static_cast<int>(MATSIG_Count_WQ(end_material)) -
		                    nPieces_[WHITE][QUEEN];
		auto extra_bqueen = static_cast<int>(MATSIG_Count_BQ(end_material)) -
		                    nPieces_[BLACK][QUEEN];
		if (promo) {
			extra_wqueen += extra_wpawn;
			extra_bqueen += extra_bpawn;
		}
		if (extra_wqueen > 0 || extra_bqueen > 0)
			return true;

		return !upromo &&
		       (MATSIG_Count_WR(end_material) > nPieces_[WHITE][ROOK] ||
		        MATSIG_Count_WB(end_material) > nPieces_[WHITE][BISHOP] ||
		        MATSIG_Count_WN(end_material) > nPieces_[WHITE][KNIGHT] ||
		        MATSIG_Count_BR(end_material) > nPieces_[BLACK][ROOK] ||
		        MATSIG_Count_BB(end_material) > nPieces_[BLACK][BISHOP] ||
		        MATSIG_Count_BN(end_material) > nPieces_[BLACK][KNIGHT]);
	}
};

/// Search for an exact position (same material in the same squares).
class SearchPos {
	MaterialCount nPieces_;
	pieceT board_[64];
	std::unique_ptr<StoredLine> storedLine_;
	std::pair<uint16_t, uint16_t> hpSig_;
	colorT toMove_;
	bool isStdStard_;

public:
	SearchPos(const Position* pos) {
		std::copy_n(pos->GetBoard(), 64, board_);

		for (auto piece : board_) {
			if (piece != EMPTY) {
				nPieces_.incr(piece);
			}
		}

		hpSig_ = hpSig_make(board_);
		toMove_ = pos->GetToMove();
		isStdStard_ = pos->IsStdStart();

		if ((board_[E1] == WK || board_[G1] == WK) &&
		    (board_[E8] == BK || board_[G8] == BK)) {
			storedLine_ = std::make_unique<StoredLine>(board_, toMove_);
		}
	}

	/// Disable the stored lines optimization
	void disableOptStoredLine() { storedLine_ = nullptr; }

	/// Disable the home pawn optimization
	void disableOptHpSig() { hpSig_ = {0, 0}; }

	/// Search for the position using the optimizations in a game's index.
	/// @returns
	/// -2 : the game cannot reach the searched position
	/// -1 : the game can reach the searched position
	/// >=0: the game reach the searched position at the returned ply
	int index_match(const IndexEntry& ie) const {
		if (!ie.GetStartFlag()) {
			if (storedLine_) {
				int ply = storedLine_->match(ie.GetStoredLineCode());
				if (ply != -1)
					return ply;
			}
			if (!hpSig_match(hpSig_.first, hpSig_.second, ie.GetHomePawnData()))
				return -2;
		}
		if (nPieces_.extraMaterial(ie.GetFinalMatSig(), ie.GetPromotionsFlag(),
		                           ie.GetUnderPromoFlag())) {
			return -2;
		}
		return -1;
	}

	/// Reset @e filter to include only the games that reached the searched
	/// position in their main line.
	bool setFilter(scidBaseT* base, HFilter& filter, const Progress& progress) {
		if (toMove_ == BLACK)
			return SetFilter<BLACK>(base, filter, progress);

		if (!isStdStard_)
			return SetFilter<WHITE>(base, filter, progress);

		return setFilterStdStart(base, filter);
	}

private:
	bool setFilterStdStart(scidBaseT* base, HFilter& filter) {
		filter->includeAll();
		for (gamenumT i = 0, n = base->numGames(); i < n; i++) {
			const IndexEntry* ie = base->getIndexEntry(i);
			if (ie->GetStartFlag()) {
				int ply = base->getGame(ie).search<WHITE>(board_, nPieces_.data());
				filter.set(i, (ply > 255) ? 255 : ply);
			}
		}
		return true;
	}

	template <colorT TOMOVE>
	bool SetFilter(scidBaseT* base, HFilter& filter, const Progress& prg) {
		filter->clear();
		long long progress = 0;
		for (gamenumT i = 0, n = base->numGames(); i < n; i++) {
			const IndexEntry* ie = base->getIndexEntry(i);
			int ply = index_match(*ie);
			if (ply >= 0) {
				filter.set(i, static_cast<byte>(ply + 1));
			} else if (ply == -1) {
				ply = base->getGame(ie).search<TOMOVE>(board_, nPieces_.data());
				if (ply != 0)
					filter.set(i, (ply > 255) ? 255 : ply);

				if ((progress++ % 256) == 0 && !prg.report(i, n))
					return false;
			}
		}
		return true;
	}
};

#endif
