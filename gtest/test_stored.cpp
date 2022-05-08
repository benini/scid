/*
 * Copyright (C) 2021  Fulvio Benini.
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

#include "board_def.h"
#include "position.h"
#include "stored.h"
#include <gtest/gtest.h>

// 1.d4 Nf6 2.c4 e6 3.Nc3 Bb4 4.Qc2 O-O
std::tuple<squareT, squareT, bool> line63[] = {
    {D2, D4, false}, {G8, F6, false}, {C2, C4, false}, {E7, E6, false},
    {B1, C3, false}, {F8, B4, false}, {D1, C2, false}, {NS, NS, true}};
const auto line63_fen =
    "rnbq1rk1/pppp1ppp/4pn2/8/1bPP4/2N5/PPQ1PPPP/R1B1KBNR w KQ - 0 5";

auto cmp_moves = [&](auto move, auto line) {
	if (line.isCastle())
		return std::get<2>(move) && line.getFrom() < line.getTo();

	return std::get<0>(move) == line.getFrom() &&
	       std::get<1>(move) == line.getTo();
};

TEST(Test_StoredLine, classify) {
	auto code = StoredLine::classify([&](auto begin, auto end) {
		return std::equal(std::begin(line63), std::end(line63), begin, end,
		                  cmp_moves);
	});
	EXPECT_EQ(63, code);
}

TEST(Test_StoredLine, getMove) {
	auto it = std::begin(line63);
	unsigned i = 0;
	while (auto move = StoredLine::getMove(63, i++)) {
		EXPECT_TRUE(cmp_moves(*it++, move));
	}
}

TEST(Test_StoredLine, match) {
	Position pos;
	pos.ReadFromFEN(line63_fen);
	const auto stored = StoredLine(pos.GetBoard(), pos.GetToMove());
	EXPECT_EQ(-1, stored.match(62));
	EXPECT_EQ(8, stored.match(63));
	EXPECT_EQ(8, stored.match(64));
	EXPECT_EQ(-2, stored.match(65));
}