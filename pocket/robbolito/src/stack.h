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

const static uint8 left90[64] =
{ 7, 15, 23, 31, 39, 47, 55, 63,
6, 14, 22, 30, 38, 46, 54, 62,
5, 13, 21, 29, 37, 45, 53, 61,
4, 12, 20, 28, 36, 44, 52, 60,
3, 11, 19, 27, 35, 43, 51, 59,
2, 10, 18, 26, 34, 42, 50, 58,
1, 9, 17, 25, 33, 41, 49, 57,
0, 8, 16, 24, 32, 40, 48, 56
};

const static uint8 left45[64] =
{ 0, 2, 5, 9, 14, 20, 27, 35,
1, 4, 8, 13, 19, 26, 34, 42,
3, 7, 12, 18, 25, 33, 41, 48,
6, 11, 17, 24, 32, 40, 47, 53,
10, 16, 23, 31, 39, 46, 52, 57,
15, 22, 30, 38, 45, 51, 56, 60,
21, 29, 37, 44, 50, 55, 59, 62,
28, 36, 43, 49, 54, 58, 61, 63
};
const static uint8 straight45[64] =
{ 28, 21, 15, 10, 6, 3, 1, 0,
36, 29, 22, 16, 11, 7, 4, 2,
43, 37, 30, 23, 17, 12, 8, 5,
49, 44, 38, 31, 24, 18, 13, 9,
54, 50, 45, 39, 32, 25, 19, 14,
58, 55, 51, 46, 40, 33, 26, 20,
61, 59, 56, 52, 47, 41, 34, 27,
63, 62, 60, 57, 53, 48, 42, 35
};
uint64 attack_knight[64], attack_king[64], attack_pawn_white[64], attack_pawn_black[64], line_obscured[4][64][64];
int lineturn[4][64];

uint8 xray_white_list[64], xray_black_list[64];
static const uint64 pile_rank[8] =
    {
    0x00000000000000ffull, 0x000000000000ff00ull, 0x0000000000ff0000ull, 0x00000000ff000000ull, 0x000000ff00000000ull,
        0x0000ff0000000000ull, 0x00ff000000000000ull, 0xff00000000000000ull
    };

#define RANK1 0x00000000000000ffull
#define RANK2 0x000000000000ff00ull
#define RANK3 0x0000000000ff0000ull
#define RANK4 0x00000000ff000000ull
#define RANK5 0x000000ff00000000ull
#define RANK6 0x0000ff0000000000ull
#define RANK7 0x00ff000000000000ull
#define RANK8 0xff00000000000000ull

static const uint64 pile_file[8] =
    {
    0x0101010101010101ull, 0x0202020202020202ull, 0x0404040404040404ull, 0x0808080808080808ull, 0x1010101010101010ull,
        0x2020202020202020ull, 0x4040404040404040ull, 0x8080808080808080ull
    };

#define FILEa 0x0101010101010101ull
#define FILEb 0x0202020202020202ull
#define FILEc 0x0404040404040404ull
#define FILEd 0x0808080808080808ull
#define FILEe 0x1010101010101010ull
#define FILEf 0x2020202020202020ull
#define FILEg 0x4040404040404040ull
#define FILEh 0x8080808080808080ull

uint64 square_fixed[64], square_free[64], not_diagonal[64], not_perpendicular[64];
uint64 perpendicular[64], diagonal[64], ortodiagonal[64];

static const uint64 traversa26nonA = 0x0000fefefefefe00ull;
static const uint64 traversa26nonAB = 0x0000fcfcfcfcfc00ull;
static const uint64 traversa26 = 0x0000ffffffffff00ull;
static const uint64 traversa26nonH = 0x00007f7f7f7f7f00ull;
static const uint64 traversa26nonGH = 0x00003f3f3f3f3f00ull;
static const uint64 traversa37nonA = 0x00fefefefefe0000ull;
static const uint64 traversa37nonAB = 0x00fcfcfcfcfc0000ull;
static const uint64 traversa37 = 0x00ffffffffffff0000ull;
static const uint64 traversa37nonGH = 0x003f3f3f3f3f0000ull;
static const uint64 traversa37nonH = 0x007f7f7f7f7f0000ull;
static const uint64 CLEAR = 0x55aa55aa55aa55aaull;
static const uint64 DARK = 0xaa55aa55aa55aa55ull;
static const uint64 traversa2nonA = 0x000000000000fe00ull;
static const uint64 traversa2nonH = 0x0000000000007f00ull;
static const uint64 traversa7nonA = 0x00fe000000000000ull;
static const uint64 traversa7nonH = 0x007f000000000000ull;
static const uint64 nonA = 0xfefefefefefefefeull;
static const uint64 nonH = 0x7f7f7f7f7f7f7f7full;

uint64 file_open_white[64], file_open_black[64], pawn_free_white[64], pawn_free_black[64];
uint64 pawn_protected_white[64], pawn_protected_black[64];
uint64 pile_isolated_black[64], pile_isolated_white[64], pawn_connected[64];
uint64 infront_white[8], not_infront_white[8], infront_black[8], not_infront_black[8], file_isolated[8];
uint64 files_lefts[8], files_straights[8];

static const uint64 F1G1 = 0x0000000000000060ull;
static const uint64 C1D1 = 0x000000000000000cull;
static const uint64 B1C1D1 = 0x000000000000000eull;
static const uint64 F8G8 = 0x6000000000000000ull;
static const uint64 C8D8 = 0x0c00000000000000ull;
static const uint64 B8C8D8 = 0x0e00000000000000ull;

uint64 DOUBLE_[64];

uint64 west_1[64], east_1[64], west_2[64], east_2[64], adjacent[64], diagonal_length[64];

uint64 quadrant_white_move_white[64], quadrant_black_move_white[64];
uint64 quadrant_white_move_black[64], quadrant_black_move_black[64];
uint64 white_guide[64], black_guide[64];

uint64 INTERPOSITION[64][64], EVASION[64][64];
uint64 north_west[64], south_west[64], north_east[64], south_east[64];
uint64 left90_reset[64], left45_reset[64], straight45_reset[64], left90_fixed[64], left45_fixed[64],
    straight45_fixed[64];
sint8 index_line[64][64];
uint64 zobrist_oo[16], ZOBRIST[16][64], zobrist_ep[8], zobrist_move_white;
