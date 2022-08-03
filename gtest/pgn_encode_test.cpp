/*
 * Copyright (C) 2022  Fulvio Benini.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH
 * THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#include "game.h"
#include "pgn_encode.h"
#include "pgnparse.h"
#include <gtest/gtest.h>
#include <string>
#include <string_view>

TEST(Test_PgnEncode, break_lines) {
	using namespace std::literals;
	{
		auto pgn =
		    "1. e4\0e5\0{ very long comment, with space at the beginning should remain unaltered, even if it is longer than 80 chars}\0"sv
		    "2. Nf3\0Nf6"sv;

		auto expected =
		    "1. e4 e5\n{ very long comment, with space at the beginning should remain unaltered, even if it is longer than 80 chars}\n"sv
		    "2. Nf3 Nf6"sv;
		auto text = std::string(pgn);
		pgn::break_lines(text.begin(), text.end());
		EXPECT_EQ(text, expected);

		auto expected_hard_len =
		    "1. e4 e5\n{ very long comment, with space at the beginning should remain unaltered, even\n"sv
		    "if it is longer than 80 chars} 2. Nf3 Nf6"sv;
		auto hard = std::string(pgn);
		pgn::break_lines<80, '\0', 80>(hard.begin(), hard.end());
		EXPECT_EQ(hard, expected_hard_len);
	}
	{
		auto pgn =
		    "1. e4\0e5\0{normal comment, not very long, should be inline}\0"sv
		    "2. Nf3\0Nf6\0(2... Nc6)\0"sv
		    "3. Bb5\0Nxe4"sv;

		auto expected =
		    "1. e4 e5 {normal comment, not very long, should be inline} 2. Nf3 Nf6 (2... Nc6)\n3. Bb5 Nxe4"sv;
		auto text = std::string(pgn);
		pgn::break_lines(text.begin(), text.end());
		EXPECT_EQ(text, expected);

		auto expected79 =
		    "1. e4 e5 {normal comment, not very long, should be inline} 2. Nf3 Nf6\n(2... Nc6) 3. Bb5 Nxe4"sv;
		text = std::string(pgn);
		pgn::break_lines<79>(text.begin(), text.end());
		EXPECT_EQ(text, expected79);

		auto expected58 =
		    "1. e4 e5 {normal comment, not very long, should be inline}\n2. Nf3 Nf6 (2... Nc6) 3. Bb5 Nxe4"sv;
		text = std::string(pgn);
		pgn::break_lines<58>(text.begin(), text.end());
		EXPECT_EQ(text, expected58);
	}
}

TEST(Test_PgnEncode, escape_string) {
	using namespace std::literals;
	{
		auto text = std::string(R"(escape \ test \\ "White "Sen\pai"")");
		auto expected = R"(escape \\ test \\\\ \"White \"Sen\\pai\"\")"sv;
		pgn::escape_string(text, 0);
		EXPECT_EQ(text, expected);
	}
	{
		auto text = std::string(R"(escape \ test \\ "White "Sen\pai"")");
		auto expected = R"(escape \ test \\\\ \"White \"Sen\\pai\"\")"sv;
		pgn::escape_string(text, 8);
		EXPECT_EQ(text, expected);
	}
}

TEST(Test_PgnEncode, encode_tag_pair) {
	using namespace std::literals;
	{
		std::string text;
		pgn::encode_tag_pair("White", "Senpai e kohai", text);
		EXPECT_EQ("[White\0\"Senpai e kohai\"]\n"sv, text);
		pgn::break_lines(text.begin(), text.end());
		EXPECT_STREQ("[White \"Senpai e kohai\"]\n", text.c_str());
	}
	{
		std::string text;
		pgn::encode_tag_pair("Event", "", text);
		EXPECT_EQ("[Event\0\"?\"]\n"sv, text);
		pgn::break_lines(text.begin(), text.end());
		EXPECT_STREQ("[Event \"?\"]\n", text.c_str());
	}
	{
		std::string text;
		pgn::encode_tag_pair("empty", "", text);
		EXPECT_EQ("[empty\0\"\"]\n"sv, text);
		pgn::break_lines(text.begin(), text.end());
		EXPECT_STREQ("[empty \"\"]\n", text.c_str());
	}
}

TEST(Test_PgnEncode, encode_comment_rest_of_line) {
	{
		std::string text;
		EXPECT_TRUE(
		    pgn::encode_comment_rest_of_line("rest of line comment", text));
		EXPECT_STREQ(text.c_str(), ";rest of line comment\n");
	}
	{
		std::string text = "1.e4";
		EXPECT_TRUE(
		    pgn::encode_comment_rest_of_line("rest of line comment", text));
		EXPECT_STREQ(text.c_str(), "1.e4\0;rest of line comment\n");
	}
	{
		std::string text = "1.e4\0";
		EXPECT_TRUE(
		    pgn::encode_comment_rest_of_line("rest of line comment", text));
		EXPECT_STREQ(text.c_str(), "1.e4\0;rest of line comment\n");
	}
	{
		std::string text;
		EXPECT_FALSE(pgn::encode_comment_rest_of_line("no\nnewline", text));
		EXPECT_EQ(0, text.size());
	}
}

TEST(Test_PgnEncode, encode_comment) {
	using namespace std::literals;
	{
		std::string text;
		pgn::encode_comment("normal comment", text);
		EXPECT_EQ(text, "{normal comment}\0"sv);
	}
	{
		std::string text;
		pgn::encode_comment("comment with curly } brace", text);
		EXPECT_STREQ(text.c_str(), ";comment with curly } brace\n");
	}
	{
		std::string text;
		pgn::encode_comment("comment with\nnewline", text);
		EXPECT_EQ(text, "{comment with\nnewline}\0"sv);
	}
	{
		std::string text;
		pgn::encode_comment("both curly { and newline\n", text);
		EXPECT_EQ(text, "{both curly \xEF\xBD\x9B and newline\n}\0"sv);
	}
}

static void SAN_hack(Game& game) {
	// TODO: we need this to fill in all the moveT->san
	// It would be better to do this when the game is decoded.
	game.MoveToStart();
	do {
		game.GetNextSAN();
	} while (game.MoveForwardInPGN() == OK);
};

TEST(Test_PgnEncode, encode_game) {
	using namespace std::literals;
	{
		Game empty;
		auto expected = "[Event\0\"?\"]\n"sv
		                "[Site\0\"?\"]\n"sv
		                "[Date\0\"????.??.??\"]\n"sv
		                "[Round\0\"?\"]\n"sv
		                "[White\0\"?\"]\n"sv
		                "[Black\0\"?\"]\n"sv
		                "[Result\0\"*\"]\n"sv
		                "\n*\n"sv;
		std::string pgn;
		pgn::encode_game(empty, pgn);
		EXPECT_EQ(pgn, expected);
	}
	{
		Game game;
		game.SetMoveComment("before the move");
		simpleMoveT sm;
		game.currentPos()->makeMove(E2, E4, EMPTY, sm);
		game.AddMove(sm);
		game.SetMoveComment("after the move");
		SAN_hack(game);
		auto expected = "[Event\0\"?\"]\n"sv
		                "[Site\0\"?\"]\n"sv
		                "[Date\0\"????.??.??\"]\n"sv
		                "[Round\0\"?\"]\n"sv
		                "[White\0\"?\"]\n"sv
		                "[Black\0\"?\"]\n"sv
		                "[Result\0\"*\"]\n"sv
		                "\n"sv
		                "{before the move}\0"sv
		                "1.e4\0{after the move}\n"sv
		                "*\n"sv;
		std::string pgn;
		pgn::encode_game(game, pgn);
		EXPECT_EQ(pgn, expected);
	}
}

TEST(Test_PgnEncode, encode) {
	{
		Game empty;
		auto expected = "[Event \"?\"]\n"
		                "[Site \"?\"]\n"
		                "[Date \"????.??.??\"]\n"
		                "[Round \"?\"]\n"
		                "[White \"?\"]\n"
		                "[Black \"?\"]\n"
		                "[Result \"*\"]\n"
		                "\n*\n";
		std::string pgn;
		pgn::encode(empty, pgn);
		EXPECT_STREQ(pgn.c_str(), expected);
	}
	{
		Game game;
		game.SetMoveComment("before the move");
		simpleMoveT sm;
		game.currentPos()->makeMove(E2, E4, EMPTY, sm);
		game.AddMove(sm);
		game.SetMoveComment("after the move");
		SAN_hack(game);
		auto expected = "[Event \"?\"]\n"
		                "[Site \"?\"]\n"
		                "[Date \"????.??.??\"]\n"
		                "[Round \"?\"]\n"
		                "[White \"?\"]\n"
		                "[Black \"?\"]\n"
		                "[Result \"*\"]\n"
		                "\n"
		                "{before the move} 1.e4 {after the move}\n"
		                "*\n";
		std::string pgn;
		pgn::encode(game, pgn);
		EXPECT_STREQ(pgn.c_str(), expected);
	}
	{
		std::string_view src =
		    "{pre} 1. e4 {comm} ({pre var} 1. d4 d5 {end var with comm}) 1... "
		    "e5 $1 {nag} (1... c5 $2) 2. Nf3 {last}";
		Game game;
		pgn::parse_game({src.data(), src.data() + src.size()},
		                PgnVisitor{game});
		SAN_hack(game);
		auto expected =
		    "[Event \"?\"]\n"
		    "[Site \"?\"]\n"
		    "[Date \"????.??.??\"]\n"
		    "[Round \"?\"]\n"
		    "[White \"?\"]\n"
		    "[Black \"?\"]\n"
		    "[Result \"*\"]\n"
		    "\n"
		    "{pre} 1.e4 {comm} ({pre var} 1.d4 d5 {end var with comm}) 1...e5 "
		    "$1 {nag}\n(1...c5 $2) 2.Nf3 {last}\n"
		    "*\n";
		std::string pgn;
		pgn::encode(game, pgn);
		EXPECT_STREQ(pgn.c_str(), expected);
	}
}
