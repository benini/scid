/*
* Copyright (C) 2016 Fulvio Benini

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

#include "game.h"
#include "pgnparse.h"
#include <fstream>
#include <gtest/gtest.h>

namespace {

const char* gameUTF8 = SCID_TESTDIR "res_gameUTF8.pgn";
const char* gameLatin1 = SCID_TESTDIR "res_gameLatin1.pgn";
const char* gameLatin1Conv = SCID_TESTDIR "res_gameLatin1expected.pgn";

std::vector<char> readFile(const char* filename) {
	std::vector<char> res;
	std::filebuf file;
	if (!file.open(filename, std::ios::in | std::ios::binary))
		return res;
	size_t fileSz = file.pubseekoff(0, std::ios::end);
	if (fileSz > 0) {
		res.resize(fileSz);
		file.pubseekpos(0);
		file.sgetn(res.data(), fileSz);
	}
	return res;
}

} // end of anonymous namespace

TEST(Test_PgnParser, UTF8_char) {
	auto pgnUTF8 = readFile(gameUTF8);
	ASSERT_TRUE(pgnUTF8.size() > 0);

	pgnUTF8.push_back('\0');
	PgnParser parser(pgnUTF8.data());
	Game game;
	parser.ParseGame(&game);
	game.SetPgnFormat(PGN_FORMAT_Plain);
	game.ResetPgnStyle(PGN_STYLE_TAGS | PGN_STYLE_VARS | PGN_STYLE_COMMENTS |
	                   PGN_STYLE_SCIDFLAGS);
	auto pgnSCID = game.WriteToPGN(75, true);
	pgnUTF8.pop_back(); // Remove trailing null char

	ASSERT_EQ(pgnUTF8.size(), pgnSCID.second);
	for (size_t i = 0, n = pgnUTF8.size(); i < n; ++i) {
		ASSERT_EQ(pgnUTF8[i], pgnSCID.first[i]);
	}
}

TEST(Test_PgnParser, Latin1_char) {
	auto pgnLatin1 = readFile(gameLatin1);
	ASSERT_TRUE(pgnLatin1.size() > 0);

	pgnLatin1.push_back('\0');
	PgnParser parser(pgnLatin1.data());
	Game game;
	parser.ParseGame(&game);
	game.SetPgnFormat(PGN_FORMAT_Plain);
	game.ResetPgnStyle(PGN_STYLE_TAGS | PGN_STYLE_VARS | PGN_STYLE_COMMENTS |
	                   PGN_STYLE_SCIDFLAGS);
	auto pgnSCID = game.WriteToPGN(75, true);

	auto pgnUTF8 = readFile(gameLatin1Conv);
	ASSERT_TRUE(pgnUTF8.size() > 0);

	ASSERT_EQ(pgnUTF8.size(), pgnSCID.second);
	for (size_t i = 0, n = pgnSCID.second; i < n; ++i) {
		ASSERT_EQ(pgnUTF8[i], pgnSCID.first[i]);
	}
}

TEST(Test_PgnParser, UTF8) {
	std::filebuf file;
	ASSERT_TRUE(nullptr !=
	            file.open(gameUTF8, std::ios::in | std::ios::binary));
	PgnParser parser(&file);
	Game game;
	parser.ParseGame(&game);
	game.SetPgnFormat(PGN_FORMAT_Plain);
	game.ResetPgnStyle(PGN_STYLE_TAGS | PGN_STYLE_VARS | PGN_STYLE_COMMENTS |
	                   PGN_STYLE_SCIDFLAGS);
	auto pgnSCID = game.WriteToPGN(75, true);

	auto pgnUTF8 = readFile(gameUTF8);
	ASSERT_TRUE(pgnUTF8.size() > 0);

	ASSERT_EQ(pgnUTF8.size(), pgnSCID.second);
	for (size_t i = 0, n = pgnUTF8.size(); i < n; ++i) {
		ASSERT_EQ(pgnUTF8[i], pgnSCID.first[i]);
	}
}

TEST(Test_PgnParser, Latin1) {
	std::filebuf file;
	ASSERT_TRUE(nullptr !=
	            file.open(gameLatin1, std::ios::in | std::ios::binary));
	PgnParser parser(&file);
	Game game;
	parser.ParseGame(&game);
	game.SetPgnFormat(PGN_FORMAT_Plain);
	game.ResetPgnStyle(PGN_STYLE_TAGS | PGN_STYLE_VARS | PGN_STYLE_COMMENTS |
	                   PGN_STYLE_SCIDFLAGS);
	auto pgnSCID = game.WriteToPGN(75, true);

	auto pgnUTF8 = readFile(gameLatin1Conv);
	ASSERT_TRUE(pgnUTF8.size() > 0);

	ASSERT_EQ(pgnUTF8.size(), pgnSCID.second);
	for (size_t i = 0, n = pgnSCID.second; i < n; ++i) {
		ASSERT_EQ(pgnUTF8[i], pgnSCID.first[i]);
	}
}

TEST(Test_PgnParser, EPD) {
	const char* messy_pgn = // clang-format off
	    "rnbqkb1r/1ppppppp/5n2/p7/2P5/4P3/PP1P1PPP/RNBQKBNR b KQkq - 0 1;\n"
	    "%escape line\n"
	    "rq2r1k1/1bbn1pp1/1pp2n1p/p2p4/N2P3B/P2BP2P/1PQ1NPP1/2R2R1K b - -\n"
	    "1B2K3/4b3/3pk3/5R2/8/7B/8/8 w - - bm Bb8-c7; ce +M3; pv Bb8-c7 Be7-f8 Ke8xf8 d6-d5 Rf5-f7+;\n"
		"1B2K3/4b3/3pk3/5R2/8/7B/8/8 w - - bm Bc7 Rf3+\n"
		";ignored1, warning1\n"
		"ignored2, warning2\n"
	    "[Event \"F/S Return Match\"]\n"
	    "[Site \"Belgrade, Serbia JUG\"]\n"
	    "[Date \"1992.11.04\"]\n"
	    "[Round \"29\"]\n"
	    "[White \"Fischer, Robert J.\"]\r\n"
	    "[Black \"Spassky, Boris V.\"]\n\r"
		"ignored3, warning3\n"
	    ";29th game of the 1992 match\n"
	    "1. e4 e5 2. Nf3 Nc6 3. Bb5 a6 {This opening is called\n"
	    "the; Ruy% Lopez.}\n"
	    "4. Ba4 Nf6 5. O-O\n"
	    "; rnbqkb1r/1ppppppp/5n2/p7/2P5/4P3/PP1P1PPP/RNBQKBNR b KQkq -1; %comm\r\n"
	    "Be7 ;6. Re1 b5 7. Bb3 d6 8. c3 O-O 9. h3 Nb8 10. d4 Nbd7\n"
	    "[Event \"Partial game\"]\n"
	    "[Site \"With few tags\"]\n"
		"1-0";
	const char* expected_game =
	    "[Event \"F/S Return Match\"]\n"
	    "[Site \"Belgrade, Serbia JUG\"]\n"
	    "[Date \"1992.11.04\"]\n"
	    "[Round \"29\"]\n"
	    "[White \"Fischer, Robert J.\"]\n"
	    "[Black \"Spassky, Boris V.\"]\n"
		"[Result \"*\"]\n"
		"\n"
		"{29th game of the 1992 match} \n"
		"1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 {This opening is called the; Ruy% Lopez.} 4.Ba4\n"
		"Nf6 5.O-O {rnbqkb1r/1ppppppp/5n2/p7/2P5/4P3/PP1P1PPP/RNBQKBNR b KQkq -1; \n"
		"%comm} 5...Be7 {6. Re1 b5 7. Bb3 d6 8. c3 O-O 9. h3 Nb8 10. d4 Nbd7}"
		" *\n\n";
	const char* warnings_game =
		"(game 5, line 6) Warning: Invalid text in PGN game header: ;ignored1, warning1\n"
		"(game 5, line 7) Warning: Invalid text in PGN game header: ignored2, warning2\n"
		"(game 5, line 13) Error: Unexpected symbol: ignored3,"
		"\n(game 5, line 13) Error: Unexpected symbol: warning3\n"
		"(game 5, line 20) PGN header '[' seen inside game (result missing ?)\n";
	// clang-format on

	char buf[128];
	Game game;
	game.SetPgnFormat(PGN_FORMAT_Plain);
	game.ResetPgnStyle(PGN_STYLE_TAGS | PGN_STYLE_VARS | PGN_STYLE_COMMENTS);
	PgnParser parser(messy_pgn);

	game.Clear();
	ASSERT_EQ(OK, parser.ParseGame(&game));
	game.GetCurrentPos()->PrintFEN(buf, FEN_CASTLING_EP);
	EXPECT_STREQ("rnbqkb1r/1ppppppp/5n2/p7/2P5/4P3/PP1P1PPP/RNBQKBNR b KQkq -",
	             buf);
	EXPECT_STREQ("0 1;", game.GetMoveComment());

	game.Clear();
	ASSERT_EQ(OK, parser.ParseGame(&game));
	game.GetCurrentPos()->PrintFEN(buf, FEN_CASTLING_EP);
	EXPECT_STREQ(
	    "rq2r1k1/1bbn1pp1/1pp2n1p/p2p4/N2P3B/P2BP2P/1PQ1NPP1/2R2R1K b - -",
	    buf);
	EXPECT_STREQ("", game.GetMoveComment());

	game.Clear();
	ASSERT_EQ(OK, parser.ParseGame(&game));
	game.GetCurrentPos()->PrintFEN(buf, FEN_CASTLING_EP);
	EXPECT_STREQ("1B2K3/4b3/3pk3/5R2/8/7B/8/8 w - -", buf);
	EXPECT_STREQ("bm Bb8-c7; ce +M3; pv Bb8-c7 Be7-f8 Ke8xf8 d6-d5 Rf5-f7+;",
	             game.GetMoveComment());

	game.Clear();
	ASSERT_EQ(OK, parser.ParseGame(&game));
	game.GetCurrentPos()->PrintFEN(buf, FEN_CASTLING_EP);
	EXPECT_STREQ("1B2K3/4b3/3pk3/5R2/8/7B/8/8 w - -", buf);
	EXPECT_STREQ("bm Bc7 Rf3+", game.GetMoveComment());

	return;
	EXPECT_EQ(ERROR_Game, parser.ParseGame(&game));
	EXPECT_STREQ(expected_game, game.WriteToPGN(75, true).first);
	EXPECT_STREQ(warnings_game, parser.ErrorMessages());

	ASSERT_EQ(OK, parser.ParseGame(&game));
	EXPECT_STREQ("Partial game", game.GetEventStr());

	ASSERT_EQ(ERROR_NotFound, parser.ParseGame(&game));
}
