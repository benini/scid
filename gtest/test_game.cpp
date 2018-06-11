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

#include "game.h"
#include "scidbase.h"
#include <algorithm>
#include <bytebuf.h>
#include <cstring>
#include <gtest/gtest.h>
#include <memory>
#include <random>

namespace {

const char* gameUTF8 = SCID_TESTDIR "res_gameUTF8.pgn";
const char* gameLatin1 = SCID_TESTDIR "res_gameLatin1.pgn";
const char* gameLatin1Conv = SCID_TESTDIR "res_gameLatin1expected.pgn";

} // namespace

TEST(Test_Game, clone) {
	for (auto filename : {gameUTF8, gameLatin1, gameLatin1Conv}) {

		scidBaseT dbase;
		ASSERT_EQ(OK, dbase.Open(ICodecDatabase::PGN, FMODE_Both, filename));
		ASSERT_NE(nullptr, dbase.getIndexEntry_bounds(0));

		Game game;
		ByteBuffer bufGame(BBUF_SIZE);
		ASSERT_EQ(OK, dbase.getGame(dbase.getIndexEntry(0), &bufGame));
		ASSERT_EQ(OK, game.Decode(&bufGame, GAME_DECODE_ALL));

		std::mt19937 re(std::random_device{}());
		game.MoveToLocationInPGN(std::uniform_int_distribution<>{0, 500}(re));

		std::unique_ptr<Game> clone{game.clone()};

		ASSERT_EQ(clone->GetPgnOffset(), game.GetPgnOffset());

		auto board = game.currentPos()->GetBoard();
		ASSERT_TRUE(
		    std::equal(board, board + 66, clone->currentPos()->GetBoard()));

		char sanGame[12] = {};
		game.GetSAN(sanGame);
		char sanClone[12] = {};
		clone->GetSAN(sanClone);
		ASSERT_STREQ(sanGame, sanClone);

		game.SetPgnFormat(PGN_FORMAT_Plain);
		game.ResetPgnStyle(PGN_STYLE_TAGS | PGN_STYLE_VARS |
		                   PGN_STYLE_COMMENTS | PGN_STYLE_SCIDFLAGS);
		auto pgnGame = game.WriteToPGN(75, true);

		clone->SetPgnFormat(PGN_FORMAT_Plain);
		clone->ResetPgnStyle(PGN_STYLE_TAGS | PGN_STYLE_VARS |
		                     PGN_STYLE_COMMENTS | PGN_STYLE_SCIDFLAGS);
		auto pgnClone = clone->WriteToPGN(75, true);

		ASSERT_TRUE(std::equal(pgnClone.first, pgnClone.first + pgnClone.second,
		                       pgnGame.first, pgnGame.first + pgnGame.second));

		ByteBuffer bufClone(BBUF_SIZE);
		clone->Encode(&bufClone, NULL);

		ASSERT_TRUE(std::equal(
		    bufClone.getData(), bufClone.getData() + bufClone.GetByteCount(),
		    bufGame.getData(), bufGame.getData() + bufGame.GetByteCount()));
	}
}

TEST(Test_Game, locationInPGN) {
	for (auto filename : {gameUTF8, gameLatin1, gameLatin1Conv}) {

		scidBaseT dbase;
		ASSERT_EQ(OK, dbase.Open(ICodecDatabase::PGN, FMODE_Both, filename));
		ASSERT_NE(nullptr, dbase.getIndexEntry_bounds(0));

		Game game;
		ByteBuffer bufGame(BBUF_SIZE);
		ASSERT_EQ(OK, dbase.getGame(dbase.getIndexEntry(0), &bufGame));
		ASSERT_EQ(OK, game.Decode(&bufGame, GAME_DECODE_ALL));

		unsigned location = 1;
		game.MoveToStart();
		while (true) {
			++location;
			errorT errForward = game.MoveForwardInPGN();
			if (errForward != OK) {
				ASSERT_EQ(errForward, game.MoveToLocationInPGN(location));
				break;
			}

			ASSERT_EQ(location, game.GetLocationInPGN());
			if (!game.AtVarStart()) {
				ASSERT_EQ(location, game.GetPgnOffset());
			}

			std::string san = game.GetNextSAN();
			auto ply1 = game.GetCurrentPly();
			game.MoveToLocationInPGN(location);
			auto ply2 = game.GetCurrentPly();
			ASSERT_EQ(ply1, ply2);
			ASSERT_EQ(location, game.GetLocationInPGN());
			ASSERT_TRUE(san == game.GetNextSAN());
		}
	}
}

TEST(Test_Game, gamevisit) {
	Game game;

	// Expect to visit the STR even for an empty game
	std::vector<std::pair<std::string, std::string> > expected_STR = {
	    {"Event", ""}, {"Site", ""},  {"Date", "????.??.??"}, {"Round", ""},
	    {"White", ""}, {"Black", ""}, {"Result", "*"}};
	std::vector<std::pair<std::string, std::string> > result_STR;
	gamevisit::tags_STR(game, [&](const char* tag, const char* value) {
		result_STR.emplace_back(tag, value);
	});
	EXPECT_TRUE(std::equal(expected_STR.begin(), expected_STR.end(),
	                       result_STR.begin(), result_STR.end()));

	// Expect no extra tags for an empty game
	std::vector<std::pair<std::string, std::string> > expected_extra;
	std::vector<std::pair<std::string, std::string> > result_extra;
	gamevisit::tags_extra(game, [&](const char* tag, const char* value) {
		result_extra.emplace_back(tag, value);
	});
	EXPECT_TRUE(result_extra.size() == 0);

	// Set all possible tag-pair types and expect to visit them all
	expected_STR[4].second = "white player";
	game.SetWhiteStr(expected_STR[4].second.c_str());
	expected_STR[5].second = "black \\player\"";
	game.SetBlackStr(expected_STR[5].second.c_str());
	expected_STR[2].second = "2018.06.11";
	game.SetDate(date_parsePGNTag("2018.06.11", 10));
	const char* white_elo = "2800";
	expected_extra.emplace_back("WhiteRapid", white_elo);
	game.setRating(WHITE, "Rapid", 5, {white_elo, white_elo + 4});
	expected_extra.emplace_back("BlackElo", "2650");
	game.SetBlackElo(2650);
	expected_extra.emplace_back("ECO", "A01");
	game.SetEco(eco_FromString("A01"));
	expected_extra.emplace_back("EventDate", "2018.06.01");
	game.SetEventDate(date_parsePGNTag("2018.06.01", 10));
	expected_extra.emplace_back("UTCDate", "2018.06.10");
	game.AddPgnTag("UTCDate", "2018.06.10");
	expected_extra.emplace_back("UTF-8", u8"Hell\u00F6");
	game.AddPgnTag(expected_extra.back().first.c_str(),
	               expected_extra.back().second.c_str());
	expected_extra.emplace_back("special chars", R"(Escape\\\" and \n {}\")");
	game.AddPgnTag(expected_extra.back().first.c_str(),
	               expected_extra.back().second.c_str());
	expected_STR[6].second = "0-1";
	game.SetResult(RESULT_Black);
	expected_extra.emplace_back(
	    "FEN", "8/N2P1pk1/2n2q2/1P2pp2/5PN1/QKPp1P2/8/8 w - - 0 1");
	game.SetStartFen(expected_extra.back().second.c_str());
	expected_STR[0].second = "event nAme";
	game.SetEventStr("event nAme");
	expected_STR[3].second = "round 4";
	game.SetRoundStr("round 4");
	expected_STR[1].second = "a long site maybe in a long country";
	game.SetSiteStr("a long site maybe in a long country");

	// Expect to visit the STR (in order)
	result_STR.clear();
	gamevisit::tags_STR(game, [&](const char* tag, const char* value) {
		result_STR.emplace_back(tag, value);
	});
	auto it = result_STR.begin();
	for (auto& exp : expected_STR) {
		EXPECT_EQ(exp, *it++);
	}

	// Expect to visit all the extra tags
	result_extra.clear();
	gamevisit::tags_extra(game, [&](const char* tag, const char* value) {
		result_extra.emplace_back(tag, value);
	});
	it = result_extra.begin();
	for (auto& exp : expected_extra) {
		EXPECT_EQ(exp, *it++);
	}
}
