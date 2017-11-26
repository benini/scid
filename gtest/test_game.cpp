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
