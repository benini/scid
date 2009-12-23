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

#define outpost_white 0x00007e7e7e000000ull
#define outpost_black 0x0000007e7e7e0000ull

#define bitboard_two(x, y) (((uint64) 1) << (x))|(((uint64) 1) << (y))
static const uint64 trap_rook[64] =
    {
	0, bitboard_two (A1, A2), bitboard_two (A1, A2) | bitboard_two (B1, B2), 0,
	0, bitboard_two (H1, H2) | bitboard_two (G1, G2), bitboard_two (H1, H2), 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0,
	0, bitboard_two (A8, A7), bitboard_two (A8, A7) | bitboard_two (B8, B7), 0,
	0, bitboard_two (H8, H7) | bitboard_two (G8, G7), bitboard_two (H8, H7), 0
    };

#define points(x,y) (( (x) << 16) + (y))

#define pawn_mobility_non points(3, 10)
#define mobility_queen(Y) points(2, 2) * POPCNT(Y)
#define mobility_bishop(Y, Z) points (5, 5) * POPCNT( Y & Z)
#define mobility_rook(Y) points(2, 3) * POPCNT(Y)
#define mobility_knight(Y, Z) points (6, 8) * POPCNT(Y & Z)

#define xray_bishop0 points(0, 0)
#define xray_bishop_my_pawn points(3, 5)
#define xray_bishop_my_knight points(3, 5)
#define xray_bishop_my_king points(3, 5)
#define xray_bishop_my_bishop points(0, 0)
#define xray_bishop_my_rook points(3, 5)
#define xray_bishop_my_queen points(0, 0)

#define xray_bishop_your_pawn points(2, 5)
#define xray_bishop_your_knight points(2, 5)
#define xray_bishop_your_king points(0, 0)
#define xray_bishop_your_bishop points(0, 0)
#define xray_bishop_your_rook points(15, 25)
#define xray_bishop_your_queen points(10, 20)

#define xray_rook0 points(0, 0)
#define xray_rook_my_pawn points(0, 0)
#define xray_rook_my_knight points(3, 5)
#define xray_rook_my_king points(3, 5)
#define xray_rook_my_bishop points(3, 5)
#define xray_rook_my_rook points(0, 0)
#define xray_rook_my_queen points(0, 0)

#define xray_rook_your_pawn points(2, 5)
#define xray_rook_your_knight points(2, 5)
#define xray_rook_your_king points(0, 0)
#define xray_rook_your_bishop points(2, 5)
#define xray_rook_your_rook points(0, 0)
#define xray_rook_your_queen points(10, 20)

static const uint32 white_bishop_xray[16] =
    {
    xray_bishop0, xray_bishop_my_pawn, xray_bishop_my_knight, xray_bishop_my_king, xray_bishop_my_bishop,
        xray_bishop_my_bishop, xray_bishop_my_rook, xray_bishop_my_queen, xray_bishop0, xray_bishop_your_pawn,
        xray_bishop_your_knight, xray_bishop_your_king, xray_bishop_your_bishop, xray_bishop_your_bishop,
        xray_bishop_your_rook, xray_bishop_your_queen
    };
static const uint32 black_bishop_xray[16] =
    {
    xray_bishop0, xray_bishop_your_pawn, xray_bishop_your_knight, xray_bishop_your_king, xray_bishop_your_bishop,
        xray_bishop_your_bishop, xray_bishop_your_rook, xray_bishop_your_queen, xray_bishop0, xray_bishop_my_pawn,
        xray_bishop_my_knight, xray_bishop_my_king, xray_bishop_my_bishop, xray_bishop_my_bishop, xray_bishop_my_rook,
        xray_bishop_my_queen
    };
static const uint32 white_rook_xray[16] =
    {
    xray_rook0, xray_rook_my_pawn, xray_rook_my_knight, xray_rook_my_king, xray_rook_my_bishop, xray_rook_my_bishop,
        xray_rook_my_rook, xray_rook_my_queen, xray_rook0, xray_rook_your_pawn, xray_rook_your_knight,
        xray_rook_your_king, xray_rook_your_bishop, xray_rook_your_bishop, xray_rook_your_rook, xray_rook_your_queen
    };
static const uint32 black_rook_xray[16] =
    {
    xray_rook0, xray_rook_your_pawn, xray_rook_your_knight, xray_rook_your_king, xray_rook_your_bishop,
        xray_rook_your_bishop, xray_rook_your_rook, xray_rook_your_queen, xray_rook0, xray_rook_my_pawn,
        xray_rook_my_knight, xray_rook_my_king, xray_rook_my_bishop, xray_rook_my_bishop, xray_rook_my_rook,
        xray_rook_my_queen
    };

#define xray_queen_diag0 points(0, 0)
#define xray_queen_diag_my_pawn points(1, 2)
#define xray_queen_diag_my_knight points(2, 4)
#define xray_queen_diag_my_king points(2, 4)
#define xray_queen_diag_my_bishop points(0, 0)
#define xray_queen_diag_my_rook points(2, 4)
#define xray_queen_diag_my_queen points(0, 0)

#define xray_queen_diag_your_pawn points(0, 0)
#define xray_queen_diag_your_knight points(2, 5)
#define xray_queen_diag_your_king points(0, 0)
#define xray_queen_diag_your_bishop points(0, 0)
#define xray_queen_diag_your_rook points(2, 5)
#define xray_queen_diag_your_queen points(0, 0)

#define xray_queen_orto0 points(0, 0)
#define xray_queen_orto_my_pawn points(0, 0)
#define xray_queen_orto_my_knight points(2, 4)
#define xray_queen_orto_my_king points(2, 4)
#define xray_queen_orto_my_bishop points(2, 4)
#define xray_queen_orto_my_rook points(0, 0)
#define xray_queen_orto_my_queen points(0, 0)

#define xray_queen_orto_your_pawn points(0, 0)
#define xray_queen_orto_your_knight points(2, 5)
#define xray_queen_orto_your_king points(0, 0)
#define xray_queen_orto_your_bishop points(2, 5)
#define xray_queen_orto_your_rook points(0, 0)
#define xray_queen_orto_your_queen points(0, 0)

static const uint32 white_queen_diag_xray[16] =
    {
    xray_queen_diag0, xray_queen_diag_my_pawn, xray_queen_diag_my_knight, xray_queen_diag_my_king,
        xray_queen_diag_my_bishop, xray_queen_diag_my_bishop, xray_queen_diag_my_rook, xray_queen_diag_my_queen,
        xray_queen_diag0, xray_queen_diag_your_pawn, xray_queen_diag_your_knight, xray_queen_diag_your_king,
        xray_queen_diag_your_bishop, xray_queen_diag_your_bishop, xray_queen_diag_your_rook, xray_queen_diag_your_queen
    };
static const uint32 black_queen_diag_xray[16] =
    {
    xray_queen_diag0, xray_queen_diag_your_pawn, xray_queen_diag_your_knight, xray_queen_diag_your_king,
        xray_queen_diag_your_bishop, xray_queen_diag_your_bishop, xray_queen_diag_your_rook, xray_queen_diag_your_queen,
        xray_queen_diag0, xray_queen_diag_my_pawn, xray_queen_diag_my_knight, xray_queen_diag_my_king,
        xray_queen_diag_my_bishop, xray_queen_diag_my_bishop, xray_queen_diag_my_rook, xray_queen_diag_my_queen
    };
static const uint32 white_queen_orto_xray[16] =
    {
    xray_queen_orto0, xray_queen_orto_my_pawn, xray_queen_orto_my_knight, xray_queen_orto_my_king,
        xray_queen_orto_my_bishop, xray_queen_orto_my_bishop, xray_queen_orto_my_rook, xray_queen_orto_my_queen,
        xray_queen_orto0, xray_queen_orto_your_pawn, xray_queen_orto_your_knight, xray_queen_orto_your_king,
        xray_queen_orto_your_bishop, xray_queen_orto_your_bishop, xray_queen_orto_your_rook, xray_queen_orto_your_queen
    };
static const uint32 black_queen_orto_xray[16] =
    {
    xray_queen_orto0, xray_queen_orto_your_pawn, xray_queen_orto_your_knight, xray_queen_orto_your_king,
        xray_queen_orto_your_bishop, xray_queen_orto_your_bishop, xray_queen_orto_your_rook, xray_queen_orto_your_queen,
        xray_queen_orto0, xray_queen_orto_my_pawn, xray_queen_orto_my_knight, xray_queen_orto_my_king,
        xray_queen_orto_my_bishop, xray_queen_orto_my_bishop, xray_queen_orto_my_rook, xray_queen_orto_my_queen
    };
static const uint8 bishop_trap_square[64] =
    {
    0x00, C2, 0x00, 0x00, 0x00, 0x00, F2, 0x00,
	B3, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, G3,
	B4, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, G4,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	B5, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, G5,
	B6, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, G6,
	0x00, C7, 0x00, 0x00, 0x00, 0x00, F7, 0x00
    };

#define bishop_trap_value points(40, 40)
#define bishop_trap_look_value points(40, 40)

static const uint8 buono_trap_bishop_square[64] =
    {
    0x00, D1, 0x00, 0x00, 0x00, 0x00, E1, 0x00,
	C2, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, F2,
	C3, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, F3,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
	0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00,
    C6, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, F6,
	C7, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, F7,
	0x00, D8, 0x00, 0x00, 0x00, 0x00, E8, 0x00
    };
static const uint32 pawn_free_my_ok[8] =
    {
    0, 0, 0, points(0, 0), points(0, 0), points(3, 5), points(5, 10), 0
    };
static const uint32 pawn_free_your_ok[8] =
    {
    0, 0, 0, points(0, 0), points(5, 10), points(15, 30), points(25, 50)
    };
static const uint32 pawn_free_mobility[8] =
    {
    0, 0, 0, points(1, 2), points(2, 3), points(3, 5), points(5, 10), 0
    };
static const uint32 pawn_free_free[8] =
    {
    0, 0, 0, points(0, 0), points(5, 10), points(10, 20), points(20, 40)
    };

#define queen_look points(5, 2)
#define rook_look points(3, 1)
#define bishop_look points(2, 1)
#define knight_look points(4, 2)

#define queen_seventh_doppia points(10, 15)
#define rook_seventh_king_pawn_doppia points(10, 20)
#define attak_multiple points(15, 25)
#define queen_seventh points(5, 25)
#define king_attack_nonlook_pawn points(0, 5)

#define pawn_attak_queen points(8, 12)
#define rook_attak_queen points(5, 5)
#define bishop_attak_queen_rook points(7, 10)
#define knight_attak_queen_rook points(7, 10)
#define pawn_attak_rook points(7, 10)
#define pawn_attak_knight points(5, 7)
#define pawn_attak_bishop points(5, 7)
#define bishop_attak_knight points(5, 5)
#define knight_attak_bishop points(5, 5)
#define queen_attak points(4, 4)
#define rook_attak_minor points(4, 5)
#define rook_attak_pawn points(2, 3)
#define knight_attak_pawn points(3, 4)
#define bishop_attak_pawn points(3, 4)

#define rook_open_half points(3, 6)
#define rook_open points(20, 10)
#define rook_open_minor_fixed points(10, 0)
#define rook_open_minor points(15, 5)
#define rook_half_pawn points(5, 5)
#define rook_half_king points(15, 0)
#define rook_eighth_king points(5, 10)
#define rook_seventh_king_pawn points(10, 30)
#define rook_sixth_king_pawn points(5, 15)

#define outpost_bishop points(1, 2)
#define outpost_bishop_look points(3, 4)
#define outpost_rook points(1, 2)
#define outpost_rook_look points(3, 4)

#define outpost_knight points(2, 3)
#define outpost_knight_pawn points(2, 3)
#define outpost_knight_look points(5, 5)
#define outpost_knight_quinto points(2, 2)
#define outpost_knight_DE points(3, 3)

static const uint32 king_safety_multiplier[16] =
    {
    0, 1, 4, 9, 16, 25, 36, 49, 50, 50, 50, 50, 50, 50, 50, 50
    };
#define BLOW(x,y) ( (x) << 16) + (y)
#define BLOW_pawn BLOW(1, 0)
#define BLOW_queen BLOW(1, 40)
#define BLOW_rook BLOW(1, 25)
#define BLOW_knight BLOW(1, 15)
#define BLOW_bishop BLOW(1, 15)
#define BLOW_king BLOW(0, 0)
#define king_safety_bonus 8

static const uint32 rank_endgame_queen[8] =
    {
    0, 0, 0, points(5, 5), points(10, 10), points(20, 20), points(40, 40), 0
    };

#define endgame_rook_seventh points(100, 100)
#define endgame_rook_sixth points(25, 25)
#define endgame_queen_seventh points(10, 10)

static const uint64 cramp_file[8] =
    {
    FILEb, 0, 0, 0, 0, 0, 0, FILEg
    };

#define I(a,b,c) ( (a & 0xff) | ( b << 8) )

const static uint32 value_material_[16] =
    {
    0, I(0, 0x1440, 1), I(1, 0x240, 1), 0, I(1, 0x24, 1), I(1, 0x48, 1), I(3, 0x04, 1), I(6, 0x1, 1), 0,
	I(0, 0xb640, 1), I(1, 0x6c0, 1), 0, I(1, 0x90, 1), I(1, 0x120, 1), I(3, 0xc, 1), I(6, 0x2, 1)
    };
