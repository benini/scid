/*
RobboLito is a UCI chess playing engine by
Yakov Petrovich Golyadkin, Igor Igorovich Igoronov, Roberto Pescatore
copyright: (C) 2009 Yakov Petrovich Golyadkin
date: 92th and 93rd year from Revolution
owners: PUBLICDOMAIN (workers)
dedication: To Vladimir Ilyich

RobboLito is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published
by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.

RobboLito is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see http://www.gnu.org/licenses/.
*/

#define bitboard_two(x, y) (((uint64) 1) << (x))|(((uint64) 1) << (y))
#define F1H1 bitboard_two(F1, H1)
#define F1H1_left90 bitboard_two(left90[F1], left90[H1])
#define F1H1_left45 bitboard_two(left45[F1], left45[H1])
#define F1H1_straight45 bitboard_two(straight45[F1], straight45[H1])
#define A1D1 bitboard_two(A1, D1)
#define A1D1_left90 bitboard_two(left90[A1], left90[D1])
#define A1D1_left45 bitboard_two(left45[A1], left45[D1])
#define A1D1_straight45 bitboard_two(straight45[A1], straight45[D1])
#define F8H8 bitboard_two(F8, H8)
#define F8H8_left90 bitboard_two(left90[F8], left90[H8])
#define F8H8_left45 bitboard_two(left45[F8], left45[H8])
#define F8H8_straight45 bitboard_two(straight45[F8], straight45[H8])
#define A8D8 bitboard_two(A8, D8)
#define A8D8_left90 bitboard_two(left90[A8], left90[D8])
#define A8D8_left45 bitboard_two(left45[A8], left45[D8])
#define A8D8_straight45 bitboard_two(straight45[A8], straight45[D8])

#define occupied_free(M, x)                    \
  { POSITION.occupied_black_white &= M;        \
  POSITION.occupied_left90 &= left90_reset[x]; \
  POSITION.occupied_left45 &= left45_reset[x]; \
  POSITION.occupied_straight45 &= straight45_reset[x]; }
#define occupied_fixed(M, x)                   \
  { POSITION.occupied_black_white |= M;        \
  POSITION.occupied_left90 |= left90_fixed[x]; \
  POSITION.occupied_left45 |= left45_fixed[x]; \
  POSITION.occupied_straight45 |= straight45_fixed[x]; }
