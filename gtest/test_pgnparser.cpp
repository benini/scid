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
