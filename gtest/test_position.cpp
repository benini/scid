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

#include "fastgame.h"
#include "position.h"
#include "searchpos.h"
#include <cstring>
#include <gtest/gtest.h>

TEST(Test_movegen, attack) {
	const int empty = 1234;
	int board[64];
	std::fill_n(board, 64, empty);

	board[12] = !empty;
	board[19] = !empty;
	board[21] = !empty;
	board[28] = !empty;
	board[33] = !empty;
	board[52] = !empty;

	EXPECT_TRUE(movegen::attack(31, 29, WHITE, QUEEN, board, empty));
	EXPECT_FALSE(movegen::attack(31, 27, WHITE, QUEEN, board, empty));
	EXPECT_TRUE(movegen::attack(52, 28, BLACK, ROOK, board, empty));
	EXPECT_FALSE(movegen::attack(52, 20, BLACK, ROOK, board, empty));
	EXPECT_TRUE(movegen::attack(1, 11, WHITE, KNIGHT, board, empty));
	EXPECT_FALSE(movegen::attack(1, 6, WHITE, KNIGHT, board, empty));
	EXPECT_TRUE(movegen::attack(33, 19, BLACK, BISHOP, board, empty));
	EXPECT_FALSE(movegen::attack(33, 12, BLACK, BISHOP, board, empty));
	EXPECT_TRUE(movegen::attack(12, 19, WHITE, PAWN, board, empty));
	EXPECT_FALSE(movegen::attack(12, 20, WHITE, PAWN, board, empty));
	EXPECT_TRUE(movegen::attack(19, 12, BLACK, PAWN, board, empty));
	EXPECT_FALSE(movegen::attack(12, 19, BLACK, PAWN, board, empty));
	EXPECT_TRUE(movegen::attack(12, 3, WHITE, KING, board, empty));
	EXPECT_FALSE(movegen::attack(12, 14, WHITE, KING, board, empty));
}

TEST(Test_movegen, opens_ray) {
	const int empty = 7777;
	int board[64];
	std::fill_n(board, 64, empty);

	board[12] = !empty;
	board[19] = !empty;
	board[21] = !empty;
	board[28] = !empty;
	board[33] = !empty;
	board[52] = !empty;

	auto test = movegen::opens_ray(19, 27, 12, board, empty);
	EXPECT_TRUE(test.first == BISHOP && test.second == 33);

	test = movegen::opens_ray(21, 29, 12, board, empty);
	EXPECT_TRUE(test.first == INVALID_PIECE);

	test = movegen::opens_ray(28, 20, 12, board, empty);
	EXPECT_TRUE(test.first == INVALID_PIECE);

	test = movegen::opens_ray(28, 27, 12, board, empty);
	EXPECT_TRUE(test.first == ROOK && test.second == 52);
}

TEST(Test_movegen, UCItoSAN) {
	// clang-format off
	static const char* positions[] = {
		"2k4r/ppprnp1p/5pq1/1P2b3/P1R1P3/Q1N2N2/5PPP/4K1R1 b - - 0 22",
			"h8d8", "Rhd8", "d7d8", "Rdd8",
		"2kr1b1r/pp1qpp1p/2n2p2/1BPp3b/3P4/P1N2P2/1P4PP/R2QK1NR w KQ - 0 12",
			"g1e2", "Nge2",
		"8/1R2r2k/p7/P6p/5PpP/3pP1P1/4r1B1/3K4 b - - 0 53",
			"e2e3", "Rxe3",
		"rnb2r2/pppnq1p1/6k1/2p1PpN1/2Pp4/3Q3P/PP3PP1/R1B2RK1 w - f6 0 15",
			"e5f6", "exf6+",
		"r6r/pppknp1p/6p1/4p3/8/NP2P3/P1P2PPP/R3K2R w KQ - 0 13",
			"e1c1", "O-O-O+",
		"8/6k1/1K1Q4/8/8/8/6pQ/q1q5 b - - 0 23",
			"g2g1q", "g1=Q+", "g2g1b", "g1=B+", "g2g1r", "g1=R", "c1g1", "Qg1+",
		"r4r2/1pq1nkb1/p1pnp1pp/P2p4/NB1P1PP1/3PP1N1/1P2K1Q1/R6R b - - 0 22",
			"f8h8", "Rh8",
		"q3k1q1/8/4q3/8/8/8/3K4/8 b - - 0 1",
			"a8d8", "Qd8+", "a8d5", "Qad5+", "e6d5", "Qed5+", "a8g2", "Qag2+", "g8g2", "Qgg2+",
		"4k3/2n1n3/8/3B4/8/2n5/8/4K3 b - - 0 1",
			"c7d5", "Nc7xd5", "e7d5", "Nexd5", "c3d5", "N3xd5",
		"rnbqk1nr/pppp1ppp/4p3/8/1b1P4/5N2/PPP1PPPP/RNBQKB1R w KQkq - 0 3",
			"b1d2", "Nbd2", "f3d2", "Nfd2", "c1d2", "Bd2",
		"rnbq1rk1/pppp1ppp/4pn2/8/1bPP4/2N1P3/PP3PPP/R1BQKBNR w KQ - 0 5",
			"g1e2", "Ne2",
		"4r3/3P1Pk1/8/3K4/8/8/8/8 w - - 0 5",
			"d7e8q", "dxe8=Q", "f7e8q", "fxe8=Q",
		"7k/8/8/1R3R2/8/3R4/8/K7 w - - 0 1",
			"d3d5", "Rdd5", "b5d5", "Rbd5", "f5d5", "Rfd5",
		"7k/8/2B1B3/8/2B5/8/8/K7 w - - 0 1",
			"c4d5", "B4d5", "c6d5", "Bc6d5", "e6d5", "Bed5",
		"7k/8/2q1q3/8/2q5/8/8/K7 b - - 0 1",
			"c4d5", "Q4d5", "c6d5", "Qc6d5", "e6d5", "Qed5"
	};
	// clang-format on

	Position pos;
	char buf[64];
	auto it = std::begin(positions);
	for (; it != std::end(positions); ++it) {
		auto slen = std::strlen(*it);
		if (slen > 5) {
			ASSERT_EQ(OK, pos.ReadFromFEN(*it));
			continue;
		}
		simpleMoveT sm;
		ASSERT_EQ(OK, pos.ReadCoordMove(&sm, *it++, int(slen), false));
		pos.MakeSANString(&sm, buf, SAN_MATETEST);
		EXPECT_STREQ(*it, buf);

		FullMove fullmove;
		colorT col = piece_Color(sm.movingPiece);
		pieceT pt = piece_Type(sm.movingPiece);
		int castle = (pt == KING) ? sm.isCastle() : 0;
		if (!castle) {
			fullmove = FullMove(col, sm.from, sm.to, pt);
			if (sm.promote != EMPTY) {
				fullmove.setPromo(piece_Type(sm.promote));
			}
			if (sm.capturedPiece != EMPTY) {
				fullmove.setCapture(sm.capturedPiece,
				                    pos.GetBoard()[sm.to] == EMPTY);
			}
		} else {
			if (col == WHITE)
				fullmove = FullMove(WHITE, E1, (castle == 1) ? H1 : A1);
			else
				fullmove = FullMove(BLACK, E8, (castle == 1) ? H8 : A8);
		}
		pos.DoSimpleMove(&sm);
		FastBoard fastboard(pos);
		pos.UndoSimpleMove(&sm);
		fastboard.fillSANInfo(fullmove);
		EXPECT_STREQ(*it, fullmove.getSAN().c_str());
	}
}

TEST(Test_MaterialCount, material_count) {
	MaterialCount mt;
	MaterialCount mt_ref;

	EXPECT_TRUE(mt == mt_ref);
	EXPECT_FALSE(mt != mt_ref);
	EXPECT_EQ(0, mt.count(WHITE));
	EXPECT_EQ(0, mt.count(BLACK));
	EXPECT_EQ(0, mt.count(WHITE, BISHOP));
	EXPECT_EQ(0, mt.count(BLACK, BISHOP));
	EXPECT_EQ(0, mt.count(WHITE, KING));
	EXPECT_EQ(0, mt.count(BLACK, KING));
	EXPECT_EQ(0, mt.count(WHITE, KNIGHT));
	EXPECT_EQ(0, mt.count(BLACK, KNIGHT));
	EXPECT_EQ(0, mt.count(WHITE, PAWN));
	EXPECT_EQ(0, mt.count(BLACK, PAWN));
	EXPECT_EQ(0, mt.count(WHITE, QUEEN));
	EXPECT_EQ(0, mt.count(BLACK, QUEEN));
	EXPECT_EQ(0, mt.count(WHITE, ROOK));
	EXPECT_EQ(0, mt.count(BLACK, ROOK));

	auto change_count = [](auto& obj) {
		obj.incr(BLACK, ROOK);
		obj.incr(BLACK, ROOK);

		obj.incr(WHITE, QUEEN);
		obj.incr(WHITE, QUEEN);
		obj.decr(WHITE, QUEEN);
		obj.incr(WHITE, QUEEN);
		obj.incr(WHITE, QUEEN);

		obj.incr(WHITE, PAWN);

		obj.incr(BLACK, BISHOP);
		obj.decr(BLACK, BISHOP);
	};

	change_count(mt);
	EXPECT_FALSE(mt == mt_ref);
	EXPECT_TRUE(mt != mt_ref);
	EXPECT_EQ(4, mt.count(WHITE));
	EXPECT_EQ(2, mt.count(BLACK));
	EXPECT_EQ(0, mt.count(WHITE, BISHOP));
	EXPECT_EQ(0, mt.count(BLACK, BISHOP));
	EXPECT_EQ(0, mt.count(WHITE, KING));
	EXPECT_EQ(0, mt.count(BLACK, KING));
	EXPECT_EQ(0, mt.count(WHITE, KNIGHT));
	EXPECT_EQ(0, mt.count(BLACK, KNIGHT));
	EXPECT_EQ(1, mt.count(WHITE, PAWN));
	EXPECT_EQ(0, mt.count(BLACK, PAWN));
	EXPECT_EQ(3, mt.count(WHITE, QUEEN));
	EXPECT_EQ(0, mt.count(BLACK, QUEEN));
	EXPECT_EQ(0, mt.count(WHITE, ROOK));
	EXPECT_EQ(2, mt.count(BLACK, ROOK));

	change_count(mt_ref);
	EXPECT_TRUE(mt == mt_ref);
	EXPECT_FALSE(mt != mt_ref);
	EXPECT_EQ(mt_ref.count(WHITE), mt.count(WHITE));
	EXPECT_EQ(mt_ref.count(BLACK), mt.count(BLACK));
	EXPECT_EQ(mt_ref.count(WHITE, BISHOP), mt.count(WHITE, BISHOP));
	EXPECT_EQ(mt_ref.count(BLACK, BISHOP), mt.count(BLACK, BISHOP));
	EXPECT_EQ(mt_ref.count(WHITE, KING), mt.count(WHITE, KING));
	EXPECT_EQ(mt_ref.count(BLACK, KING), mt.count(BLACK, KING));
	EXPECT_EQ(mt_ref.count(WHITE, KNIGHT), mt.count(WHITE, KNIGHT));
	EXPECT_EQ(mt_ref.count(BLACK, KNIGHT), mt.count(BLACK, KNIGHT));
	EXPECT_EQ(mt_ref.count(WHITE, PAWN), mt.count(WHITE, PAWN));
	EXPECT_EQ(mt_ref.count(BLACK, PAWN), mt.count(BLACK, PAWN));
	EXPECT_EQ(mt_ref.count(WHITE, QUEEN), mt.count(WHITE, QUEEN));
	EXPECT_EQ(mt_ref.count(BLACK, QUEEN), mt.count(BLACK, QUEEN));
	EXPECT_EQ(mt_ref.count(WHITE, ROOK), mt.count(WHITE, ROOK));
	EXPECT_EQ(mt_ref.count(BLACK, ROOK), mt.count(BLACK, ROOK));
}

TEST(Test_MaterialCount, less_mat) {
	auto count_pieces = [](const pieceT* board) {
		MaterialCount mt_count;
		for (int i = 0; i < 64; ++i) {
			if (board[i] != EMPTY) {
				mt_count.incr(piece_Color(board[i]), piece_Type(board[i]));
			}
		}
		return mt_count;
	};

	Position pos;
	ASSERT_EQ(OK, pos.ReadFromFEN(
	                  "2k4r/ppprnp1p/5pq1/1P2b3/P1R1P3/Q1N2N2/5PPP/4K1R1 b"));
	auto mt_count = count_pieces(pos.GetBoard());
	auto matSig = matsig_Make(pos.GetMaterial());
	EXPECT_FALSE(less_mat(mt_count, matSig, true, true));
	EXPECT_FALSE(less_mat(mt_count, matSig, true, false));
	EXPECT_FALSE(less_mat(mt_count, matSig, false, true));
	EXPECT_FALSE(less_mat(mt_count, matSig, false, false));

	mt_count.decr(WHITE, QUEEN);
	EXPECT_TRUE(less_mat(mt_count, matSig, true, true));
	EXPECT_TRUE(less_mat(mt_count, matSig, true, false));
	EXPECT_TRUE(less_mat(mt_count, matSig, false, true));
	EXPECT_TRUE(less_mat(mt_count, matSig, false, false));

	mt_count.incr(WHITE, PAWN);
	EXPECT_FALSE(less_mat(mt_count, matSig, true, true));
	EXPECT_FALSE(less_mat(mt_count, matSig, true, false));
	EXPECT_TRUE(less_mat(mt_count, matSig, false, true));
	EXPECT_TRUE(less_mat(mt_count, matSig, false, false));

	mt_count.incr(BLACK, PAWN);
	mt_count.decr(BLACK, KNIGHT);
	EXPECT_FALSE(less_mat(mt_count, matSig, true, true));
	EXPECT_TRUE(less_mat(mt_count, matSig, true, false));
	EXPECT_TRUE(less_mat(mt_count, matSig, false, true));
	EXPECT_TRUE(less_mat(mt_count, matSig, false, false));
}
