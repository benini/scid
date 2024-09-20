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

#include "gameview.h"
#include "pgnparse.h"
#include "position.h"
#include "searchpos.h"
#include <cstring>
#include <gtest/gtest.h>
#include <unordered_set>

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

	auto isOccupied = [&](auto square) { return board[square] != empty; };
	EXPECT_TRUE(movegen::attack(31, 29, WHITE, QUEEN, isOccupied));
	EXPECT_FALSE(movegen::attack(31, 27, WHITE, QUEEN, isOccupied));
	EXPECT_TRUE(movegen::attack(52, 28, BLACK, ROOK, isOccupied));
	EXPECT_FALSE(movegen::attack(52, 20, BLACK, ROOK, isOccupied));
	EXPECT_TRUE(movegen::attack(1, 11, WHITE, KNIGHT, isOccupied));
	EXPECT_FALSE(movegen::attack(1, 6, WHITE, KNIGHT, isOccupied));
	EXPECT_TRUE(movegen::attack(33, 19, BLACK, BISHOP, isOccupied));
	EXPECT_FALSE(movegen::attack(33, 12, BLACK, BISHOP, isOccupied));
	EXPECT_TRUE(movegen::attack(12, 19, WHITE, PAWN, isOccupied));
	EXPECT_FALSE(movegen::attack(12, 20, WHITE, PAWN, isOccupied));
	EXPECT_TRUE(movegen::attack(19, 12, BLACK, PAWN, isOccupied));
	EXPECT_FALSE(movegen::attack(12, 19, BLACK, PAWN, isOccupied));
	EXPECT_TRUE(movegen::attack(12, 3, WHITE, KING, isOccupied));
	EXPECT_FALSE(movegen::attack(12, 14, WHITE, KING, isOccupied));
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

	auto isOccupied = [&](auto square) { return board[square] != empty; };
	auto test = movegen::opens_ray(19, 27, 12, isOccupied);
	EXPECT_TRUE(test.first == BISHOP && test.second == 33);

	test = movegen::opens_ray(21, 29, 12, isOccupied);
	EXPECT_TRUE(test.first == INVALID_PIECE);

	test = movegen::opens_ray(28, 20, 12, isOccupied);
	EXPECT_TRUE(test.first == INVALID_PIECE);

	test = movegen::opens_ray(28, 27, 12, isOccupied);
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

		pos.DoSimpleMove(sm);
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
				fullmove = FullMove(WHITE, E1, (castle > 0) ? H1 : A1);
			else
				fullmove = FullMove(BLACK, E8, (castle > 0) ? H8 : A8);
		}
		FastBoard fastboard(pos);
		pos.UndoSimpleMove(sm);
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

TEST(Test_ReadFromFen, invalid_FEN) {
	Position pos;
	EXPECT_EQ(OK, pos.ReadFromFEN("rnb1k2Q/1p5p/p7/4p3/4q3/8/PPP2R1P/2K5 b"));
	EXPECT_NE(OK, pos.ReadFromFEN("rnb1k2/Q1p5p/p7/4p3/4q3/8/PPP2R1P/2K5 b"));
	EXPECT_NE(OK, pos.ReadFromFEN("rnb1k2Q/1p5p/p7/4p4/4q3/8/PPP2R1P/2K5 b"));
	EXPECT_NE(OK, pos.ReadFromFEN("rnb1k2Q/1p5p/p7/4a3/4q3/8/PPP2R1P/2K5 b"));
	EXPECT_NE(OK, pos.ReadFromFEN("rnb1k2Q/1p5p/p7/4 3/4q3/8/PPP2R1P/2K5 b"));
	EXPECT_NE(OK, pos.ReadFromFEN("rnb1k2Q/1p5p/p7/4p3/4q3/8/PPP2R1P/2K5"));
	EXPECT_NE(OK, pos.ReadFromFEN("rnb1k2Q/1p5p/p7/4p3/4q3/8/PKP2R1P/2K5 b"));
	EXPECT_NE(OK, pos.ReadFromFEN("rnb1k2Q/1k5p/p7/4p3/4q3/8/PPP2R1P/2K5 b"));
	EXPECT_NE(OK, pos.ReadFromFEN("rnb1q2Q/1p5p/p7/4p3/4q3/8/PPP2R1P/2K5 b"));
	EXPECT_NE(OK, pos.ReadFromFEN("rnb1k2Q/1p5p/p7/4p3/4q3/8/PPP2R1P/2K5 a"));
	EXPECT_NE(OK, pos.ReadFromFEN("rnb1k2Q/1p5p/p7/4p3/4q3/8/PPP2R1P/2K5 b z"));
	EXPECT_NE(OK, // extra piece on rank
	          pos.ReadFromFEN(
	              "rnbqkbn1/ppppppppr/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"));
	EXPECT_NE(OK, // white 18 pieces
	          pos.ReadFromFEN(
	              "nbqkbnr/ppppNNpp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"));
	EXPECT_NE(OK, // black 17 pieces
	          pos.ReadFromFEN(
	              "nbqkbnr/pppppppp/8/8/8/8/PPPPPnPP/RNBQKBNR w KQkq - 0 1"));
	EXPECT_NE(OK, // colour
	          pos.ReadFromFEN(
	              "nbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR K KQkq - 0 1"));
	EXPECT_NE(OK, // king in check
	          pos.ReadFromFEN(
	              "1B6/prpb2p1/2KPp3/qp1p4/Q1k5/nRP3p1/BRPP2Pp/BN6 w - -"));
}

TEST(Test_ReadFromFen, castling_flags) {
	const char* valid_fens[] = {
	    "rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w KQkq",
	    "rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR    w    KQkq",
	    "rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w KQk",
	    "rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w KQ",
	    "rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w K",
	    "rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w Q",
	    "rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w Qk",
	    "rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w -",
	    "rnbbnqkr/pppppppp/8/8/8/8/PPPPPPPP/RNBBNQKR w HAha - 0 1",
	    "nbqnrkbr/pppppppp/8/8/8/8/PPPPPPPP/NBQNRKBR w HEhe - 0 1"};
	const char* invalid_fens[] = {
	    "rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w z",
	    "rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w 1",
	    "rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w T",
	    "rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w Ki"};
	Position pos;
	for (auto fen : valid_fens) {
		EXPECT_EQ(OK, pos.ReadFromFEN(fen));
	}
	for (auto fen : invalid_fens) {
		EXPECT_NE(OK, pos.ReadFromFEN(fen));
	}
}

TEST(Test_ReadFromFen, EP_target) {
	Position pos;
	EXPECT_EQ(OK, pos.ReadFromFEN("8/K7/8/8/7k/8/8/8 w - - 1 1"));
	EXPECT_EQ(NULL_SQUARE, pos.GetEPTarget());
	EXPECT_EQ(OK, pos.ReadFromFEN("8/K7/8/8/7k/8/8/8 w - a3 1 1"));
	EXPECT_EQ(A3, pos.GetEPTarget());
	EXPECT_EQ(OK, pos.ReadFromFEN("8/K7/8/8/7k/8/8/8 w - b6 1 1"));
	EXPECT_EQ(B6, pos.GetEPTarget());
	EXPECT_EQ(OK, pos.ReadFromFEN("8/K7/8/8/7k/8/8/8 w - f3 1 1"));
	EXPECT_EQ(F3, pos.GetEPTarget());
	EXPECT_EQ(OK, pos.ReadFromFEN("8/K7/8/8/7k/8/8/8 w - h6 1 1"));
	EXPECT_EQ(H6, pos.GetEPTarget());

	EXPECT_NE(OK, pos.ReadFromFEN("8/K7/8/8/7k/8/8/8 w - i6 1 1"));
	EXPECT_NE(OK, pos.ReadFromFEN("8/K7/8/8/7k/8/8/8 w - a2 1 1"));
	EXPECT_NE(OK, pos.ReadFromFEN("8/K7/8/8/7k/8/8/8 w - z3 1 1"));
	EXPECT_NE(OK, pos.ReadFromFEN("8/K7/8/8/7k/8/8/8 w - a7 1 1"));
	EXPECT_NE(OK, pos.ReadFromFEN("8/K7/8/8/7k/8/8/8 w - a 3 1 1"));
}

TEST(Test_ReadFromFen, halfmove_clock) {
	const char* valid_fens[] = {"8/K7/8/8/7k/8/8/8 w - - 0 1",
	                            "8/K7/8/8/7k/8/8/8 w - - 5 1",
	                            "8/K7/8/8/7k/8/8/8 w - - 45 1"};
	const char* invalid_fens[] = {
	    "8/K7/8/8/7k/8/8/8 w - - -1 1", "8/K7/8/8/7k/8/8/8 w - - - 1 1",
	    "8/K7/8/8/7k/8/8/8 w - - - 1",  "8/K7/8/8/7k/8/8/8 w - - a 1",
	    "8/K7/8/8/7k/8/8/8 w - - a5 1", "8/K7/8/8/7k/8/8/8 w - - 0x5 1"};
	char buf[1024];
	Position pos;
	for (auto fen : valid_fens) {
		EXPECT_EQ(OK, pos.ReadFromFEN(fen));
		pos.PrintFEN(buf);
		EXPECT_STREQ(buf, fen);
	}
	for (auto fen : invalid_fens) {
		EXPECT_EQ(OK, pos.ReadFromFEN(fen));
		pos.PrintFEN(buf);
		EXPECT_STREQ(buf, "8/K7/8/8/7k/8/8/8 w - - 0 1");
	}
}

TEST(Test_ReadFromFen, fullmove_number) {
	Position pos;
	EXPECT_EQ(OK, pos.ReadFromFEN("8/K7/8/8/7k/8/8/8 w - - 0 0"));
	EXPECT_EQ(pos.GetPlyCounter(), 0);
	EXPECT_EQ(pos.GetPlyCounter() / 2 + 1, 1);
	EXPECT_EQ(OK, pos.ReadFromFEN("8/K7/8/8/7k/8/8/8 w - - 0 -1"));
	EXPECT_EQ(pos.GetPlyCounter(), 0);
	EXPECT_EQ(pos.GetPlyCounter() / 2 + 1, 1);
	EXPECT_EQ(OK, pos.ReadFromFEN("8/K7/8/8/7k/8/8/8 w - - 0 a"));
	EXPECT_EQ(pos.GetPlyCounter(), 0);
	EXPECT_EQ(pos.GetPlyCounter() / 2 + 1, 1);
	EXPECT_EQ(OK, pos.ReadFromFEN("8/K7/8/8/7k/8/8/8 w - - 0 1"));
	EXPECT_EQ(pos.GetPlyCounter() / 2 + 1, 1);
	EXPECT_EQ(OK, pos.ReadFromFEN("8/K7/8/8/7k/8/8/8 w - - 0 25"));
	EXPECT_EQ(pos.GetPlyCounter() / 2 + 1, 25);
	EXPECT_EQ(OK, pos.ReadFromFEN("8/K7/8/8/7k/8/8/8 w - - 0 115"));
	EXPECT_EQ(pos.GetPlyCounter() / 2 + 1, 115);
}

TEST(Test_ReadFromFen, GetList) {
	Position pos;
	auto getPiece = [&](auto sq) { return std::pair(sq, pos.GetPiece(sq)); };

	ASSERT_EQ(OK, pos.ReadFromFEN("rnb1k2Q/1p5p/p7/4p3/4q3/8/PPP2R1P/2K5 b"));
	const auto wh_list = pos.GetList(WHITE);
	ASSERT_TRUE(7 == pos.GetCount(WHITE));
	EXPECT_EQ(std::pair(C1, WK), getPiece(wh_list[0]));
	EXPECT_EQ(std::pair(A2, WP), getPiece(wh_list[1]));
	EXPECT_EQ(std::pair(B2, WP), getPiece(wh_list[2]));
	EXPECT_EQ(std::pair(C2, WP), getPiece(wh_list[3]));
	EXPECT_EQ(std::pair(F2, WR), getPiece(wh_list[4]));
	EXPECT_EQ(std::pair(H2, WP), getPiece(wh_list[5]));
	EXPECT_EQ(std::pair(H8, WQ), getPiece(wh_list[6]));
	const auto bl_list = pos.GetList(BLACK);
	ASSERT_TRUE(9 == pos.GetCount(BLACK));
	EXPECT_EQ(std::pair(E8, BK), getPiece(bl_list[0]));
	EXPECT_EQ(std::pair(B8, BN), getPiece(bl_list[1]));
	EXPECT_EQ(std::pair(C8, BB), getPiece(bl_list[2]));
	EXPECT_EQ(std::pair(A8, BR), getPiece(bl_list[3]));
	EXPECT_EQ(std::pair(B7, BP), getPiece(bl_list[4]));
	EXPECT_EQ(std::pair(H7, BP), getPiece(bl_list[5]));
	EXPECT_EQ(std::pair(A6, BP), getPiece(bl_list[6]));
	EXPECT_EQ(std::pair(E5, BP), getPiece(bl_list[7]));
	EXPECT_EQ(std::pair(E4, BQ), getPiece(bl_list[8]));
}

TEST(Test_PositionReadCoordMoves, ReadFromFENorUCI) {
	char buf[1024];
	Position pos;
	EXPECT_EQ(OK, pos.ReadFromFENorUCI("position startpos"));
	EXPECT_TRUE(pos.IsStdStart());

	EXPECT_EQ(OK, pos.ReadFromFENorUCI("   position startpos    "));
	EXPECT_TRUE(pos.IsStdStart());

	EXPECT_EQ(OK, pos.ReadFromFENorUCI("position startpos moves"));
	EXPECT_TRUE(pos.IsStdStart());

	EXPECT_EQ(OK, pos.ReadFromFENorUCI("   position startpos moves   "));
	EXPECT_TRUE(pos.IsStdStart());

	EXPECT_NE(OK, pos.ReadFromFENorUCI(""));

	EXPECT_EQ(OK,
	          pos.ReadFromFENorUCI("   position startpos moves e2e4 c7c5 "));
	pos.PrintFEN(buf);
	EXPECT_STREQ(
	    buf, "rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 0 2");

	EXPECT_EQ(OK, pos.ReadFromFENorUCI("rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/"
	                                   "RNBQKBNR w KQkq - 0 2 moves g1f3 "));
	pos.PrintFEN(buf);
	EXPECT_STREQ(
	    buf, "rnbqkbnr/pp1ppppp/8/2p5/4P3/5N2/PPPP1PPP/RNBQKB1R b KQkq - 1 2");
}

TEST(Test_PositionReadCoordMoves, ReadCoordMoves) {
	std::tuple<const char*, const char*, const char*, const char*> expectOK[] =
	    {{"position startpos", "1.e4 c5",
	      "rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 0 2",
	      "e2e4 c7c5"},
	     {"position startpos", "1.e4 c5",
	      "rnbqkbnr/pp1ppppp/8/2p5/4P3/8/PPPP1PPP/RNBQKBNR w KQkq - 0 2",
	      " e2e4 c7c5 "}};

	for (auto [startpos, sanMoves, endpos, coordMoves] : expectOK) {
		Position pos;
		EXPECT_EQ(OK, pos.ReadFromFENorUCI(startpos));
		std::string san;
		EXPECT_EQ(
		    OK, pos.MakeCoordMoves(coordMoves, std::strlen(coordMoves), &san));
		char buf[1024];
		pos.PrintFEN(buf);
		EXPECT_STREQ(endpos, buf);
		EXPECT_STREQ(sanMoves, san.c_str());
	}
}

TEST(Test_MoveGeneration, GetCastling) {
	{
		Position pos;
		ASSERT_EQ(OK, pos.ReadFromFEN("8/8/8/8/8/5k2/8/4K2R w K -"));
		EXPECT_TRUE(pos.IsLegalMove(E1, G1, EMPTY));
	}
	{ // Adjacent enemy king
		Position pos;
		ASSERT_EQ(OK, pos.ReadFromFEN("8/8/8/8/8/8/6k1/4K2R w K -"));
		EXPECT_FALSE(pos.IsLegalMove(E1, G1, EMPTY));
	}
	{ // King in check
		Position pos;
		ASSERT_EQ(
		    OK, pos.ReadFromFEN(
		            "r3k2r/pppp1ppp/5n1b/4p3/4P3/5N2/PP3PPP/r3KB1R w KQkq -"));
		EXPECT_FALSE(pos.IsLegalMove(E1, G1, EMPTY));
		EXPECT_FALSE(pos.IsLegalMove(E1, C1, EMPTY));
	}
	{ // Obstacles
		Position pos;
		ASSERT_EQ(OK,
		          pos.ReadFromFEN(
		              "rn2k2r/pppp1ppp/5n2/4p3/4P3/5N2/PP3PPP/R3KB1R b KQkq"));
		EXPECT_TRUE(pos.IsLegalMove(E8, G8, EMPTY));
		EXPECT_FALSE(pos.IsLegalMove(E8, C8, EMPTY));

		pos.SetToMove(WHITE);
		EXPECT_FALSE(pos.IsLegalMove(E1, G1, EMPTY));
		EXPECT_TRUE(pos.IsLegalMove(E1, C1, EMPTY));
	}
	{ // Destination in check
		Position pos;
		ASSERT_EQ(
		    OK, pos.ReadFromFEN(
		            "r3k2r/pppp1ppp/5n1b/4p2r/4P3/5N2/PP3PP1/R3K2R b KQkq -"));
		EXPECT_TRUE(pos.IsLegalMove(E8, G8, EMPTY));
		EXPECT_TRUE(pos.IsLegalMove(E8, C8, EMPTY));

		pos.SetToMove(WHITE);
		EXPECT_TRUE(pos.IsLegalMove(E1, G1, EMPTY));
		EXPECT_FALSE(pos.IsLegalMove(E1, C1, EMPTY));
	}
	{ // Wrong rank
		Position pos;
		ASSERT_EQ(OK, pos.ReadFromFEN("8/8/1k6/8/8/8/8/4K2R w K - 0 1"));
		EXPECT_TRUE(pos.IsLegalMove(E1, G1, EMPTY));
		EXPECT_FALSE(pos.IsLegalMove(E1, G2, EMPTY));
	}
}

template <typename PosT, typename MoveT>
auto parse_move(PosT& pos, MoveT dest, std::string_view move) {
	return pos.ParseMove(dest, move.data(), move.data() + move.size());
}

TEST(Test_PositionDoSimpleMove, castling_flags) {
	std::vector<simpleMoveT> sm;
	char buf[1024];
	Position pos;
	ASSERT_EQ(OK, pos.ReadFromFEN("r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1"));

	parse_move(pos, &sm.emplace_back(), "e1g1");
	pos.DoSimpleMove(sm.back());
	pos.PrintFEN(buf);
	EXPECT_STREQ(buf, "r3k2r/8/8/8/8/8/8/R4RK1 b kq - 1 1");

	parse_move(pos, &sm.emplace_back(), "h8g8");
	pos.DoSimpleMove(sm.back());
	pos.PrintFEN(buf);
	EXPECT_STREQ(buf, "r3k1r1/8/8/8/8/8/8/R4RK1 w q - 2 2");

	parse_move(pos, &sm.emplace_back(), "g1h2");
	pos.DoSimpleMove(sm.back());
	pos.PrintFEN(buf);
	EXPECT_STREQ(buf, "r3k1r1/8/8/8/8/8/7K/R4R2 b q - 3 2");

	parse_move(pos, &sm.emplace_back(), "e8c8");
	pos.DoSimpleMove(sm.back());
	pos.PrintFEN(buf);
	EXPECT_STREQ(buf, "2kr2r1/8/8/8/8/8/7K/R4R2 w - - 4 3");

	// UndoSimpleMove
	auto it = sm.crbegin();
	pos.UndoSimpleMove(*it++);
	pos.PrintFEN(buf);
	EXPECT_STREQ(buf, "r3k1r1/8/8/8/8/8/7K/R4R2 b q - 3 2");

	pos.UndoSimpleMove(*it++);
	pos.PrintFEN(buf);
	EXPECT_STREQ(buf, "r3k1r1/8/8/8/8/8/8/R4RK1 w q - 2 2");

	pos.UndoSimpleMove(*it++);
	pos.PrintFEN(buf);
	EXPECT_STREQ(buf, "r3k2r/8/8/8/8/8/8/R4RK1 b kq - 1 1");

	pos.UndoSimpleMove(*it++);
	pos.PrintFEN(buf);
	EXPECT_STREQ(buf, "r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1");
}

TEST(Test_PositionDoSimpleMove, castling_flags_capture) {
	char buf[1024];
	simpleMoveT sm;
	Position pos;
	{
		ASSERT_EQ(OK, pos.ReadFromFEN("r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1"));
		parse_move(pos, &sm, "h1h8");
		pos.DoSimpleMove(sm);
		pos.PrintFEN(buf);
		EXPECT_STREQ(buf, "r3k2R/8/8/8/8/8/8/R3K3 b Qq - 0 1");
	}
	{
		ASSERT_EQ(OK, pos.ReadFromFEN("r3k2r/8/8/8/8/8/8/R3K2R w KQkq - 0 1"));
		parse_move(pos, &sm, "a1a8");
		pos.DoSimpleMove(sm);
		pos.PrintFEN(buf);
		EXPECT_STREQ(buf, "R3k2r/8/8/8/8/8/8/4K2R b Kk - 0 1");
	}
	{
		ASSERT_EQ(OK, pos.ReadFromFEN("r3k2r/8/8/8/8/8/8/R3K2R b KQkq - 0 1"));
		parse_move(pos, &sm, "h8h1");
		pos.DoSimpleMove(sm);
		pos.PrintFEN(buf);
		EXPECT_STREQ(buf, "r3k3/8/8/8/8/8/8/R3K2r w Qq - 0 2");
	}
	{
		ASSERT_EQ(OK, pos.ReadFromFEN("r3k2r/8/8/8/8/8/8/R3K2R b KQkq - 0 1"));
		parse_move(pos, &sm, "a8a1");
		pos.DoSimpleMove(sm);
		pos.PrintFEN(buf);
		EXPECT_STREQ(buf, "4k2r/8/8/8/8/8/8/r3K2R w Kk - 0 2");
	}
}

TEST(Test_PositionIsLegalMove, normal) {
	{
		Position pos = Position::getStdStart();
		EXPECT_TRUE(pos.IsLegalMove(B1, C3, EMPTY));
		EXPECT_TRUE(pos.IsLegalMove(E2, E4, EMPTY));
		EXPECT_FALSE(pos.IsLegalMove(E2, E4, QUEEN));
		EXPECT_FALSE(pos.IsLegalMove(E3, E4, EMPTY));
		EXPECT_FALSE(pos.IsLegalMove(C1, F4, EMPTY));
	}
}

TEST(Test_PositionIsLegalMove, king_in_check) {
	Position pos;
	ASSERT_EQ(
	    OK,
	    pos.ReadFromFEN(
	        "r1b1kb1r/ppp2ppp/4p3/3pP3/3q4/1BN5/PPPP2PP/R1BQR1K1 w kq - 0 11"));
	EXPECT_TRUE(pos.IsLegalMove(G1, H1, EMPTY));
	EXPECT_TRUE(pos.IsLegalMove(E1, E3, EMPTY));
	EXPECT_FALSE(pos.IsLegalMove(E1, E4, EMPTY));
	EXPECT_FALSE(pos.IsLegalMove(C3, B5, EMPTY));

	{ // Capture the attacker
		Position pos;
		ASSERT_EQ(OK, pos.ReadFromFEN("8/1kR5/8/8/8/8/4K3/8 b - - 0 1"));
		EXPECT_TRUE(pos.IsLegalMove(B7, C7, EMPTY));
	}
	{ // Capture a defended piece
		Position pos;
		ASSERT_EQ(OK, pos.ReadFromFEN("8/1b6/1k6/8/4p3/4K3/8/8 w - - 0 1"));
		EXPECT_FALSE(pos.IsLegalMove(E3, E4, EMPTY));
	}
	{ // Adjacent enemy king
		Position pos;
		ASSERT_EQ(OK, pos.ReadFromFEN("8/8/8/3k4/2p5/4K3/8/8 w - - 0 1"));
		EXPECT_FALSE(pos.IsLegalMove(E3, E4, EMPTY));
		EXPECT_TRUE(pos.IsLegalMove(E3, E2, EMPTY));
	}
	{ // Evade check
		Position pos;
		ASSERT_EQ(OK, pos.ReadFromFEN("8/8/3k4/8/8/8/1r3K2/8 w - - 0 1"));
		EXPECT_TRUE(pos.IsLegalMove(F2, E3, EMPTY));
		EXPECT_FALSE(pos.IsLegalMove(F2, G2, EMPTY));
	}
}

TEST(Test_PositionIsLegalMove, en_passant) {
	{ // En passant capture
		Position pos;
		ASSERT_EQ(OK, pos.ReadFromFEN("8/8/8/8/4pP2/8/7k/3K4 b - f3 0 1"));
		EXPECT_TRUE(pos.IsLegalMove(E4, F3, EMPTY));
	}
	{ // En passant capture, the pawn checks the king
		Position pos;
		ASSERT_EQ(OK, pos.ReadFromFEN("8/8/8/6k1/4pP2/8/8/3K4 b - f3 0 1"));
		EXPECT_TRUE(pos.IsLegalMove(E4, F3, EMPTY));
	}
	{ // Hidden attacker
		Position pos;
		ASSERT_EQ(OK, pos.ReadFromFEN("8/2B5/8/8/4pP2/8/7k/3K4 b - f3 0 1"));
		EXPECT_FALSE(pos.IsLegalMove(E4, F3, EMPTY));
	}
}

TEST(Test_PositionIsKingInCheck, last_move_optimization) {
	simpleMoveT sm;

	{ // No Check
		Position pos;
		ASSERT_EQ(OK, pos.ReadFromFEN("8/8/8/6k1/5pp1/8/2KR4/2B5 w - -"));
		parse_move(pos, &sm, "d2g2");
		pos.DoSimpleMove(sm);
		EXPECT_FALSE(pos.IsKingInCheck(sm));
	}
	{ // Direct attack
		Position pos;
		ASSERT_EQ(OK, pos.ReadFromFEN("8/8/8/6k1/5p2/8/2KR4/2B5 w - -"));
		parse_move(pos, &sm, "d2g2");
		pos.DoSimpleMove(sm);
		EXPECT_TRUE(pos.IsKingInCheck(sm));
	}
	{ // Discovered check
		Position pos;
		ASSERT_EQ(OK, pos.ReadFromFEN("8/8/8/6k1/6p1/8/2KR4/2B5 w - -"));
		parse_move(pos, &sm, "d2g2");
		pos.DoSimpleMove(sm);
		EXPECT_TRUE(pos.IsKingInCheck(sm));
	}
	{ // Double check
		Position pos;
		ASSERT_EQ(OK, pos.ReadFromFEN("8/8/8/6k1/8/8/2KR4/2B5 w - -"));
		parse_move(pos, &sm, "d2g2");
		pos.DoSimpleMove(sm);
		EXPECT_TRUE(pos.IsKingInCheck(sm));
	}
	{ // Castling
		Position pos;
		ASSERT_EQ(OK, pos.ReadFromFEN("4k2r/6pp/8/8/8/6P1/4P1PP/5K2 b k -"));
		parse_move(pos, &sm, "e8h8");
		pos.DoSimpleMove(sm);
		EXPECT_TRUE(pos.IsKingInCheck(sm));
	}
	{ // En passant capture, the pawn checks the king
		Position pos;
		ASSERT_EQ(OK, pos.ReadFromFEN("8/8/8/6k1/4p3/8/5P2/3K4 w - -"));
		parse_move(pos, &sm, "f2f4");
		pos.DoSimpleMove(sm);
		EXPECT_TRUE(pos.IsKingInCheck(sm));
		parse_move(pos, &sm, "e4f3");
		pos.DoSimpleMove(sm);
		EXPECT_FALSE(pos.IsKingInCheck(sm));
	}
	{ // En passant capture, discovered check
		Position pos;
		ASSERT_EQ(OK, pos.ReadFromFEN("8/4r3/8/6k1/4pP2/8/8/4K3 b - f3 0 1"));
		parse_move(pos, &sm, "e4f3");
		pos.DoSimpleMove(sm);
		EXPECT_TRUE(pos.IsKingInCheck(sm));
	}
}

TEST(Test_PositionIsKingInCheck, null_move) {
	{ // No Check
		auto pos = Position{};
		auto sm = simpleMoveT{};
		EXPECT_EQ(OK, pos.ReadFromFENorUCI(
		                  "position startpos moves d2d4 e7e6 b1c3 f8b4"));
		EXPECT_EQ(OK, parse_move(pos, &sm, "null"));
	}
	{ // Direct attack
		auto pos = Position{};
		auto sm = simpleMoveT{};
		EXPECT_EQ(OK, pos.ReadFromFENorUCI(
		                  "position startpos moves d2d4 e7e6 e2e4 f8b4"));
		EXPECT_NE(OK, parse_move(pos, &sm, "null"));
	}
}

TEST(Test_PrintFen, castling_flag_kside) {
	// clang-format off
	std::string_view pgn =
		"[FEN \"Brbnk1r1/3pppq1/8/ppp3pp/PPP3PP/8/3PPPQ1/bRBNK1R1 w KQkq - 0 1\"]"
		"1. Rxa1 Rxa8 2. Ra3 Ra6 3. Rh3 Rh6 4. Rhh1 Rhh8 5. O-O O-O";
	// clang-format on
	Game game;
	PgnParseLog parseLog;
	ASSERT_TRUE(pgnParseGame(pgn.data(), pgn.size(), game, parseLog));
	game.MoveToStart();

	const char* fens[] = {
	    "Brbnk1r1/3pppq1/8/ppp3pp/PPP3PP/8/3PPPQ1/bRBNK1R1 w KQkq - 0 1",
	    "Brbnk1r1/3pppq1/8/ppp3pp/PPP3PP/8/3PPPQ1/R1BNK1R1 b Kkq - 0 1",
	    "r1bnk1r1/3pppq1/8/ppp3pp/PPP3PP/8/3PPPQ1/R1BNK1R1 w Kk - 0 2",
	    "r1bnk1r1/3pppq1/8/ppp3pp/PPP3PP/R7/3PPPQ1/2BNK1R1 b Kk - 1 2",
	    "2bnk1r1/3pppq1/r7/ppp3pp/PPP3PP/R7/3PPPQ1/2BNK1R1 w Kk - 2 3",
	    "2bnk1r1/3pppq1/r7/ppp3pp/PPP3PP/7R/3PPPQ1/2BNK1R1 b Kk - 3 3",
	    "2bnk1r1/3pppq1/7r/ppp3pp/PPP3PP/7R/3PPPQ1/2BNK1R1 w Kk - 4 4",
	    "2bnk1r1/3pppq1/7r/ppp3pp/PPP3PP/8/3PPPQ1/2BNK1RR b Gk - 5 4",
	    "2bnk1rr/3pppq1/8/ppp3pp/PPP3PP/8/3PPPQ1/2BNK1RR w Gg - 6 5",
	    "2bnk1rr/3pppq1/8/ppp3pp/PPP3PP/8/3PPPQ1/2BN1RKR b g - 7 5",
	    "2bn1rkr/3pppq1/8/ppp3pp/PPP3PP/8/3PPPQ1/2BN1RKR w - - 8 6"};
	for (auto expected : fens) {
		char buf[1024];
		game.currentPos()->PrintFEN(buf);
		EXPECT_STREQ(buf, expected);
		game.MoveForwardInPGN();
	}
}

TEST(Test_PrintFen, castling_flag_qside) {
	// clang-format off
	std::string_view pgn =
	"[FEN \"Br2k1r1/1b1ppn2/8/pppQ1pPp/PPPq1PP1/8/1B1PPN2/bR2K1R1 b KQkq - 0 1\"]"
	"1... Rg6 2. Rg3 Ra6 3. Ra3 Raxa8 4. Raxa1 O-O-O 5. O-O-O";
	// clang-format on
	Game game;
	PgnParseLog parseLog;
	ASSERT_TRUE(pgnParseGame(pgn.data(), pgn.size(), game, parseLog));
	game.MoveToStart();

	const char* fens[] = {
	    "Br2k1r1/1b1ppn2/8/pppQ1pPp/PPPq1PP1/8/1B1PPN2/bR2K1R1 b KQkq - 0 1",
	    "Br2k3/1b1ppn2/6r1/pppQ1pPp/PPPq1PP1/8/1B1PPN2/bR2K1R1 w KQq - 1 2",
	    "Br2k3/1b1ppn2/6r1/pppQ1pPp/PPPq1PP1/6R1/1B1PPN2/bR2K3 b Qq - 2 2",
	    "Br2k3/1b1ppn2/r7/pppQ1pPp/PPPq1PP1/6R1/1B1PPN2/bR2K3 w Qq - 3 3",
	    "Br2k3/1b1ppn2/r7/pppQ1pPp/PPPq1PP1/R7/1B1PPN2/bR2K3 b Qq - 4 3",
	    "rr2k3/1b1ppn2/8/pppQ1pPp/PPPq1PP1/R7/1B1PPN2/bR2K3 w Qb - 0 4",
	    "rr2k3/1b1ppn2/8/pppQ1pPp/PPPq1PP1/8/1B1PPN2/RR2K3 b Bb - 0 4",
	    "r1kr4/1b1ppn2/8/pppQ1pPp/PPPq1PP1/8/1B1PPN2/RR2K3 w B - 1 5",
	    "r1kr4/1b1ppn2/8/pppQ1pPp/PPPq1PP1/8/1B1PPN2/R1KR4 b - - 2 5"};
	for (auto expected : fens) {
		char buf[1024];
		game.currentPos()->PrintFEN(buf);
		EXPECT_STREQ(buf, expected);
		game.MoveForwardInPGN();
	}
}

TEST(Test_PrintFen, illegal_castling_flag) {
	std::unordered_set<std::string> flags;
	flags.insert("KQkq");
	std::string str = "KQkq";
	for (int len = 1; len <= 3; len++) {
		for (int i = 0; i <= str.length() - len; i++) {
			flags.insert(str.substr(i, len));
		}
	}

	// Any flag is valid
	for (auto color : {'w', 'b'}) {
		for (auto const& flag : flags) {
			std::string fen = "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR ";
			fen.append(1, color).append(1, ' ').append(flag).append(" - 0 1");
			Position pos;
			pos.ReadFromFEN(fen.c_str());
			char buf[1024];
			pos.PrintFEN(buf);
			EXPECT_STREQ(buf, fen.c_str());
		}
	}

	// No valid flags
	for (auto color : {'w', 'b'}) {
		for (auto const& flag : flags) {
			std::string fen = "1nbqkbn1/pppppppp/8/8/4P3/8/PPPP1PPP/1NBQKBN1 ";
			fen.append(1, color).append(1, ' ');
			auto expected = fen;
			expected.append("-").append(" - 0 1");
			fen.append(flag).append(" - 0 1");
			Position pos;
			pos.ReadFromFEN(fen.c_str());
			char buf[1024];
			pos.PrintFEN(buf);
			EXPECT_STREQ(buf, expected.c_str());
		}
	}

	// Only white short castle (K) is valid
	for (auto color : {'w', 'b'}) {
		for (auto const& flag : flags) {
			std::string fen = "4k3/8/8/8/8/8/8/4K2R ";
			fen.append(1, color).append(1, ' ');
			auto expected = fen;
			expected.append(flag.find('K') != std::string::npos ? "K" : "-");
			expected.append(" - 0 1");
			fen.append(flag).append(" - 0 1");
			Position pos;
			pos.ReadFromFEN(fen.c_str());
			char buf[1024];
			pos.PrintFEN(buf);
			EXPECT_STREQ(buf, expected.c_str());
		}
	}

	// Only black long castle (q) is valid
	for (auto color : {'w', 'b'}) {
		for (auto const& flag : flags) {
			std::string fen = "rn1qkb1R/pp2pp2/3p1n2/2p5/8/2P1QN2/5KPP/R1B2B2 ";
			fen.append(1, color).append(1, ' ');
			auto expected = fen;
			expected.append(flag.find('q') != std::string::npos ? "q" : "-");
			expected.append(" - 0 1");
			fen.append(flag).append(" - 0 1");
			Position pos;
			pos.ReadFromFEN(fen.c_str());
			char buf[1024];
			pos.PrintFEN(buf);
			EXPECT_STREQ(buf, expected.c_str());
		}
	}
}
