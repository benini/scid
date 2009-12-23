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

#define RANKS78 0xffff000000000000ull
#define RANKS678 0xffffff0000000000ull
#define RANKS12 0x000000000000ffffull
#define RANKS123 0x00000000000ffffffull

#include "robbolito.h"
#include "tables.h"
#include "value.h"

void mobility ()
{
	uint64 U, A, T, AA, AT;
	int b;
	DYNAMIC->white_xray = 0;
	DYNAMIC->black_xray = 0;
	A = attack_king[POSITION.white_king_square];
	DYNAMIC->attak_white = A;
	if (A & bitboard_black_king)
		DYNAMIC->black_king_check = square_fixed[POSITION.white_king_square];
	else
		DYNAMIC->black_king_check = 0;
	A = attack_king[POSITION.black_king_square];
	DYNAMIC->attak_black = A;
	if (A & bitboard_white_king)
		DYNAMIC->white_king_check = square_fixed[POSITION.black_king_square];
	else
		DYNAMIC->white_king_check = 0;
	for (U = bitboard_white_knight; U; bit_FREE (b, U))
	{
		b = BSF (U);
		A = attack_knight[b];
		DYNAMIC->attak_white |= A;
		if (A & bitboard_black_king)
			DYNAMIC->black_king_check |= square_fixed[b];
	}
	for (U = bitboard_white_bishop; U; bit_FREE (b, U))
	{
		b = BSF (U);
		A = attack_bishop (b);
		DYNAMIC->attak_white |= A;
		if (A & bitboard_black_king)
			DYNAMIC->black_king_check |= square_fixed[b];
		else if (bitboard_black_king & diagonal[b])
		{
			T = attack_bishop (POSITION.black_king_square) & A;
			DYNAMIC->white_xray |= T;
			if (T)
				xray_white_list[BSF (T)] = b;
		}
	}
	for (U = bitboard_white_rook; U; bit_FREE (b, U))
	{
		b = BSF (U);
		A = attack_rook (b);
		DYNAMIC->attak_white |= A;
		if (A & bitboard_black_king)
			DYNAMIC->black_king_check |= square_fixed[b];
		else if (bitboard_black_king & perpendicular[b])
		{
			T = attack_rook (POSITION.black_king_square) & A;
			DYNAMIC->white_xray |= T;
			if (T)
				xray_white_list[BSF (T)] = b;
		}
	}
	for (U = bitboard_white_queen; U; bit_FREE (b, U))
	{
		b = BSF (U);
		AT = attack_rook (b);
		AA = attack_bishop (b);
		A = AA | AT;
		DYNAMIC->attak_white |= A;
		if (A & bitboard_black_king)
			DYNAMIC->black_king_check |= square_fixed[b];
		else if (bitboard_black_king & diagonal[b])
		{
			T = attack_bishop (POSITION.black_king_square) & AA;
			DYNAMIC->white_xray |= T;
			if (T)
				xray_white_list[BSF (T)] = b;
		}
		else if (bitboard_black_king & perpendicular[b])
		{
			T = attack_rook (POSITION.black_king_square) & AT;
			DYNAMIC->white_xray |= T;
			if (T)
				xray_white_list[BSF (T)] = b;
		}
	}
	for (U = bitboard_black_knight; U; bit_FREE (b, U))
	{
		b = BSF (U);
		A = attack_knight[b];
		DYNAMIC->attak_black |= A;
		if (A & bitboard_white_king)
			DYNAMIC->white_king_check |= square_fixed[b];
	}
	for (U = bitboard_black_bishop; U; bit_FREE (b, U))
	{
		b = BSF (U);
		A = attack_bishop (b);
		DYNAMIC->attak_black |= A;
		if (A & bitboard_white_king)
			DYNAMIC->white_king_check |= square_fixed[b];
		else if (bitboard_white_king & diagonal[b])
		{
			T = attack_bishop (POSITION.white_king_square) & A;
			DYNAMIC->black_xray |= T;
			if (T)
				xray_black_list[BSF (T)] = b;
		}
	}
	for (U = bitboard_black_rook; U; bit_FREE (b, U))
	{
		b = BSF (U);
		A = attack_rook (b);
		DYNAMIC->attak_black |= A;
		if (A & bitboard_white_king)
			DYNAMIC->white_king_check |= square_fixed[b];
		else if (bitboard_white_king & perpendicular[b])
		{
			T = attack_rook (POSITION.white_king_square) & A;
			DYNAMIC->black_xray |= T;
			if (T)
				xray_black_list[BSF (T)] = b;
		}
	}
	for (U = bitboard_black_queen; U; bit_FREE (b, U))
	{
		b = BSF (U);
		AA = attack_bishop (b);
		AT = attack_rook (b);
		A = AA | AT;
		DYNAMIC->attak_black |= A;
		if (A & bitboard_white_king)
			DYNAMIC->white_king_check |= square_fixed[b];
		else if (bitboard_white_king & diagonal[b])
		{
			T = attack_bishop (POSITION.white_king_square) & AA;
			DYNAMIC->black_xray |= T;
			if (T)
				xray_black_list[BSF (T)] = b;
		}
		else if (bitboard_white_king & perpendicular[b])
		{
			T = attack_rook (POSITION.white_king_square) & AT;
			DYNAMIC->black_xray |= T;
			if (T)
				xray_black_list[BSF (T)] = b;
		}
	}
	A = (bitboard_white_pawn & (~FILEa)) << 7;
	T = A & bitboard_black_king;
	DYNAMIC->black_king_check |= (T >> 7);
	DYNAMIC->attak_white |= A;
	A = (bitboard_white_pawn & (~FILEh)) << 9;
	T = A & bitboard_black_king;
	DYNAMIC->black_king_check |= (T >> 9);
	DYNAMIC->attak_white |= A;
	A = (bitboard_black_pawn & (~FILEh)) >> 7;
	T = A & bitboard_white_king;
	DYNAMIC->white_king_check |= (T << 7);
	DYNAMIC->attak_black |= A;
	A = (bitboard_black_pawn & (~FILEa)) >> 9;
	T = A & bitboard_white_king;
	DYNAMIC->white_king_check |= (T << 9);
	DYNAMIC->attak_black |= A;
}

static void trick_black (int move)
{
	int v, p, m;
	if (DYNAMIC->capture)
		return;
	if (DYNAMIC->capture && QU[AI (move)] != count_pawn_white)
		return;
	p = QU[AI (move)];
	m = move & 07777;
	v = DYNAMIC->value_positional - ((DYNAMIC - 1)->value_positional);
	if (maximum_positional_gain[p][m] < v)
		maximum_positional_gain[p][m] = v;
	else if (maximum_positional_gain[p][m] > v)
		maximum_positional_gain[p][m]--;
}

static void trick_white (int move)
{
	int v, p, m;
	if (DYNAMIC->capture)
		return;
	if (DYNAMIC->capture && QU[AI (move)] != count_pawn_black)
		return;
	p = QU[AI (move)];
	m = move & 07777;
	v = ((DYNAMIC - 1)->value_positional) - DYNAMIC->value_positional;
	if (maximum_positional_gain[p][m] < v)
		maximum_positional_gain[p][m] = v;
	else if (maximum_positional_gain[p][m] > v)
		maximum_positional_gain[p][m]--;
}

#define value_zobrist_dimension ( 0x8000 )
#define value_zobrist_hide ( value_zobrist_dimension - 1 )

uint64 value_zobrist[value_zobrist_dimension];
extern type_pawn_value *pawn_zobrist;

void value_zobrist_free ()
{
	int c;
	for (c = 0; c < value_zobrist_dimension; c++)
		value_zobrist[c] = 0;
}

#ifdef HAS_PREFETCH
#define PREFETCH_PAWN_ZOBRIST __builtin_prefetch(&PAWN_VALUE, 1, 2);
#else
#define PREFETCH_PAWN_ZOBRIST
#endif

static int value_material ()
{
	int value =
		975 * (POPCNT (bitboard_white_queen) - POPCNT (bitboard_black_queen));
	value +=
		500 * (POPCNT (bitboard_white_rook) - POPCNT (bitboard_black_rook));
	value +=
		325 * (POPCNT (bitboard_white_bishop) - POPCNT (bitboard_black_bishop));
	value +=
		325 * (POPCNT (bitboard_white_knight) - POPCNT (bitboard_black_knight));
	value +=
		100 * (POPCNT (bitboard_white_pawn) - POPCNT (bitboard_black_pawn));
	if (bitboard_white_clear && bitboard_white_dark)
		value += 50;
	if (bitboard_black_clear && bitboard_black_dark)
		value -= 50;
	return value;
}

static void king_pawn_white (int Material_value, uint8 SIGN,
				  type_pawn_value * PAWN_VALUE)
{
	int value, white_first, black_first, qu, tr;
	uint8 C;
	uint64 A, T;
	if (PAWN_VALUE->ZobristPawn != DYNAMIC->ZobristPawn)
		valuation_pawn (PAWN_VALUE);
	DYNAMIC->white_xray = DYNAMIC->black_xray = 0;
	value = ((DYNAMIC->statik) + (PAWN_VALUE->points));
	value = (sint16) (value & 0xffff);
	white_first = 0;
	C = PAWN_VALUE->white_pawn_free_line;
	while (C)
	{
		qu = BSR (pile_file[BSF (C)] & bitboard_white_pawn);
		tr = RANK (qu);
		bit_FREE (0, C);
		if ((white_guide[qu] & bitboard_white_king) == 0)
		{
			if (bitboard_occupied_white & file_open_white[qu]
			|| (bitboard_black_king & quadrant_black_move_white[qu]) == 0)
				continue;
			if (white_first <= tr)
				white_first = tr;
		}
		else if (white_first <= tr)
			white_first = tr;
	}
	black_first = 0;
	C = PAWN_VALUE->black_pawn_free_line;
	while (C)
	{
		qu = BSF (pile_file[BSF (C)] & bitboard_black_pawn);
		tr = T8 - RANK (qu);
		bit_FREE (0, C);
		if ((black_guide[qu] & bitboard_black_king) == 0)
		{
			if (bitboard_occupied_black & file_open_black[qu]
			|| (bitboard_white_king & quadrant_white_move_white[qu]) ==
				0)
				continue;
			if (black_first <= tr)
				black_first = tr;
		}
		else if (black_first <= tr)
			black_first = tr;
	}
	DYNAMIC->value = (SIGN * (value + Material_value)) / 128;
	DYNAMIC->black_king_check = DYNAMIC->white_king_check = 0;
	if (white_first > black_first
		&& (bitboard_black_pawn & infront_black[T8 - white_first + 1]) == 0)
		DYNAMIC->value += 150 + 50 * white_first;
	if (black_first > white_first + 1
		&& (bitboard_white_pawn & infront_white[black_first - 2]) == 0)
		DYNAMIC->value -= 150 + 50 * black_first;

	A = (bitboard_white_pawn & (~FILEa)) << 7;
	T = A & bitboard_black_king;
	DYNAMIC->black_king_check |= (T >> 7);
	DYNAMIC->attak_white = A;
	A = (bitboard_white_pawn & (~FILEh)) << 9;
	T = A & bitboard_black_king;
	DYNAMIC->black_king_check |= (T >> 9);
	DYNAMIC->attak_white |= A | attack_king[POSITION.white_king_square];
	A = (bitboard_black_pawn & (~FILEh)) >> 7;
	T = A & bitboard_white_king;
	DYNAMIC->white_king_check |= (T << 7);
	DYNAMIC->attak_black = A;
	A = (bitboard_black_pawn & (~FILEa)) >> 9;
	T = A & bitboard_white_king;
	DYNAMIC->white_king_check |= (T << 9);
	DYNAMIC->attak_black |= A | attack_king[POSITION.black_king_square];
	if (bitboard_black_king & attack_king[POSITION.white_king_square])
	{
		DYNAMIC->black_king_check |=
			square_fixed[POSITION.white_king_square];
		DYNAMIC->white_king_check |=
			square_fixed[POSITION.black_king_square];
	}
	if (DYNAMIC->value > 0 && !bitboard_white_pawn)
		DYNAMIC->value = 0;
	if (DYNAMIC->value < 0 && !bitboard_black_pawn)
		DYNAMIC->value = 0;
	if (DYNAMIC->value > 0)
	{
		if ((bitboard_white_pawn & ~FILEh) == 0
			&& (bitboard_black_king | attack_king[POSITION.black_king_square]) &
			square_fixed[H8])
			DYNAMIC->value = 0;
		if ((bitboard_white_pawn & ~FILEa) == 0
			&& (bitboard_black_king | attack_king[POSITION.black_king_square]) &
			square_fixed[A8])
			DYNAMIC->value = 0;
		if ((DYNAMIC->flags & 28) == 28)
		{
			qu = BSF (bitboard_white_pawn);
			tr = RANK (qu);
			value =
				Yakov_white[384 * POSITION.white_king_square +
				6 * POSITION.black_king_square + tr - 1] &
				(1 << FILE (qu));
			if (!value)
				DYNAMIC->value = 0;
			else
				DYNAMIC->value =
				((sint16) (DYNAMIC->statik & 0xffff)) + 75 * tr + 250;
		}
	}
	if (DYNAMIC->value < 0)
	{
		if ((bitboard_black_pawn & ~FILEh) == 0
			&& (bitboard_white_king | attack_king[POSITION.white_king_square]) &
			square_fixed[H1])
			DYNAMIC->value = 0;
		if ((bitboard_black_pawn & ~FILEa) == 0
			&& (bitboard_white_king | attack_king[POSITION.white_king_square]) &
			square_fixed[A1])
			DYNAMIC->value = 0;
		if ((DYNAMIC->flags & 28) == 28)
		{
			qu = H8 - BSR (bitboard_black_pawn);
			tr = RANK (qu);
			value =
				Yakov_black[384 * (H8 - POSITION.black_king_square) +
				6 * (H8 - POSITION.white_king_square) + tr - 1] &
				(1 << FILE (qu));
			if (!value)
				DYNAMIC->value = 0;
			else
				DYNAMIC->value =
				((sint16) (DYNAMIC->statik & 0xffff)) - 75 * tr - 250;
		}
	}
}

static void king_pawn_black (int Material_value, uint8 SIGN,
				type_pawn_value * PAWN_VALUE)
{
	int value, white_first, black_first, qu, tr;
	uint8 C;
	uint64 A, T;

	if (PAWN_VALUE->ZobristPawn != DYNAMIC->ZobristPawn)
		valuation_pawn (PAWN_VALUE);
	DYNAMIC->white_xray = DYNAMIC->black_xray = 0;
	value = ((DYNAMIC->statik) + (PAWN_VALUE->points));
	value = (sint16) (value & 0xffff);
	white_first = 0;
	C = PAWN_VALUE->white_pawn_free_line;
	while (C)
	{
		qu = BSR (pile_file[BSF (C)] & bitboard_white_pawn);
		tr = RANK (qu);
		bit_FREE (0, C);
		if ((white_guide[qu] & bitboard_white_king) == 0)
		{
			if (bitboard_occupied_white & file_open_white[qu]
			|| (bitboard_black_king & quadrant_black_move_black[qu]) == 0)
				continue;
			if (white_first <= tr)
				white_first = tr;
		}
		else if (white_first <= tr)
			white_first = tr;
	}
	black_first = 0;
	C = PAWN_VALUE->black_pawn_free_line;
	while (C)
	{
		qu = BSF (pile_file[BSF (C)] & bitboard_black_pawn);
		tr = T8 - RANK (qu);
		bit_FREE (0, C);
		if ((black_guide[qu] & bitboard_black_king) == 0)
		{
			if (bitboard_occupied_black & file_open_black[qu]
			|| (bitboard_white_king & quadrant_white_move_black[qu]) == 0)
				continue;
			if (black_first <= tr)
				black_first = tr;
		}
		else if (black_first <= tr)
			black_first = tr;
	}
	DYNAMIC->value = -(SIGN * (value + Material_value)) / 128;
	DYNAMIC->black_king_check = DYNAMIC->white_king_check = 0;
	if (white_first > black_first + 1
		&& (bitboard_black_pawn & infront_black[T8 - white_first + 2]) == 0)
		DYNAMIC->value -= 150 + 50 * white_first;
	if (black_first > white_first
		&& (bitboard_white_pawn & infront_white[black_first - 1]) == 0)
		DYNAMIC->value += 150 + 50 * black_first;

	A = (bitboard_white_pawn & (~FILEa)) << 7;
	T = A & bitboard_black_king;
	DYNAMIC->black_king_check |= (T >> 7);
	DYNAMIC->attak_white = A;
	A = (bitboard_white_pawn & (~FILEh)) << 9;
	T = A & bitboard_black_king;
	DYNAMIC->black_king_check |= (T >> 9);
	DYNAMIC->attak_white |= A | attack_king[POSITION.white_king_square];
	A = (bitboard_black_pawn & (~FILEh)) >> 7;
	T = A & bitboard_white_king;
	DYNAMIC->white_king_check |= (T << 7);
	DYNAMIC->attak_black = A;
	A = (bitboard_black_pawn & (~FILEa)) >> 9;
	T = A & bitboard_white_king;
	DYNAMIC->white_king_check |= (T << 9);
	DYNAMIC->attak_black |= A | attack_king[POSITION.black_king_square];
	if (bitboard_black_king & attack_king[POSITION.white_king_square])
	{
		DYNAMIC->black_king_check |=
			square_fixed[POSITION.white_king_square];
		DYNAMIC->white_king_check |=
			square_fixed[POSITION.black_king_square];
	}
	if (DYNAMIC->value < 0 && !bitboard_white_pawn)
		DYNAMIC->value = 0;
	if (DYNAMIC->value > 0 && !bitboard_black_pawn)
		DYNAMIC->value = 0;
	if (DYNAMIC->value < 0)
	{
		if ((bitboard_white_pawn & ~FILEh) == 0
			&& (attack_king[POSITION.black_king_square] | bitboard_black_king) &
			square_fixed[H8])
			DYNAMIC->value = 0;
		if ((bitboard_white_pawn & ~FILEa) == 0
			&& (attack_king[POSITION.black_king_square] | bitboard_black_king) &
			square_fixed[A8])
			DYNAMIC->value = 0;
		if ((DYNAMIC->flags & 28) == 28)
		{
			qu = BSF (bitboard_white_pawn);
			tr = RANK (qu);
			value =
				Yakov_black[384 * POSITION.white_king_square +
				6 * POSITION.black_king_square + tr -
				1] & (1 << FILE (qu));
			if (!value)
				DYNAMIC->value = 0;
			else
				DYNAMIC->value =
				-((sint16) (DYNAMIC->statik & 0xffff)) - 75 * tr - 250;
		}
	}
	if (DYNAMIC->value > 0)
	{
		if ((bitboard_black_pawn & ~FILEh) == 0
			&& (attack_king[POSITION.white_king_square] | bitboard_white_king) &
			square_fixed[H1])
			DYNAMIC->value = 0;
		if ((bitboard_black_pawn & ~FILEa) == 0
			&& (attack_king[POSITION.white_king_square] | bitboard_white_king) &
			square_fixed[A1])
			DYNAMIC->value = 0;
		if ((DYNAMIC->flags & 28) == 28)
		{
			qu = H8 - BSR (bitboard_black_pawn);
			tr = RANK (qu);
			value =
				Yakov_white[384 * (H8 - POSITION.black_king_square) +
				6 * (H8 - POSITION.white_king_square) + tr -
				1] & (1 << FILE (qu));
			if (!value)
				DYNAMIC->value = 0;
			else
				DYNAMIC->value =
				-((sint16) (DYNAMIC->statik & 0xffff)) + 75 * tr + 250;
		}
	}
}

void valuation (int minimum, int maximum, int move)
{
	int ch;
	type_pawn_value *PAWN_VALUE;
	int index, Material_value, value;
	int b, tr, anti_phase, phase;
	int ai, capture, king_white_qu, king_black_qu;
	uint64 U, attak_king_white, attak_king_black, A, AA, AT;
	sint32 colpo_king_white, colpo_king_black;
	uint64 white_buono_minor, black_buono_minor, white_mobility_save,
		black_mobility_save, white_ok_xray, black_ok_xray;
	uint64 T, attak_pawn_black, attak_pawn_white;
	int opening, endgame;
	uint8 attak_buono_black, attak_buono_white;
	uint8 SIGN;
	int v, positional;

	PAWN_VALUE =
		pawn_zobrist + (DYNAMIC->ZobristPawn & (list_pawn_number - 1));
	PREFETCH_PAWN_ZOBRIST;
	index = (DYNAMIC->material_ >> 8) & 0x7ffff;
	SIGN = MATERIAL[index].sign;
	DYNAMIC->flags = MATERIAL[index].flags;
	if (!(DYNAMIC->material_ & 0x80000000))
		Material_value = MATERIAL[index].value;
	else
	{
		if (POPCNT (bitboard_white_queen) > 1
			|| POPCNT (bitboard_black_queen) > 1
			|| POPCNT (bitboard_white_rook) > 2
			|| POPCNT (bitboard_black_rook) > 2
			|| POPCNT (bitboard_white_clear) > 1
			|| POPCNT (bitboard_black_clear) > 1
			|| POPCNT (bitboard_white_dark) > 1
			|| POPCNT (bitboard_black_dark) > 1
			|| POPCNT (bitboard_white_knight) > 2
			|| POPCNT (bitboard_black_knight) > 2)
		{
			SIGN = 0x80;
			Material_value = value_material ();
			DYNAMIC->flags = 0;
			if (bitboard_white_queen | bitboard_white_rook |
				bitboard_white_bishop | bitboard_white_knight)
				DYNAMIC->flags |= 2;
			if (bitboard_black_queen | bitboard_black_rook |
				bitboard_black_bishop | bitboard_black_knight)
				DYNAMIC->flags |= 1;
		}
		else
		{
			Material_value = MATERIAL[index].value;
			DYNAMIC->material_ &= 0x7fffffff;
		}
	}

	if (((DYNAMIC->Zobrist ^
		value_zobrist[DYNAMIC->Zobrist & value_zobrist_hide]) & 0xffffffffffff0000ull) == 0)
	{
		value = (int) ((sint16)(value_zobrist[DYNAMIC->Zobrist & value_zobrist_hide] & 0xffff));
		DYNAMIC->lazy = 0;
		mobility ();
		DYNAMIC->value_positional = ((POSITION.white_en_move) ? value : -value) - Material_value;
		DYNAMIC->value = value;
		if (move && !(DYNAMIC - 1)->lazy)
			POSITION.white_en_move ? trick_white (move) :
			trick_black (move);
		return;
	}

	if ((DYNAMIC->material_ & 0xff) == 0)
		return POSITION.white_en_move ? king_pawn_white (Material_value, SIGN, PAWN_VALUE) : king_pawn_black (Material_value, SIGN, PAWN_VALUE);

#define white_minor_flag (8<<2)
#define black_minor_flag (16<<2)

	if ((DYNAMIC->flags & white_minor_flag || DYNAMIC->flags & black_minor_flag) && PAWN_VALUE->ZobristPawn != DYNAMIC->ZobristPawn)
		valuation_pawn (PAWN_VALUE);

	if ((DYNAMIC->flags & white_minor_flag
		&& PAWN_VALUE->white_pawn_line_count <= 1)
		|| (DYNAMIC->flags & black_minor_flag
		&& PAWN_VALUE->black_pawn_line_count <= 1)
		|| (DYNAMIC->flags & 128));
	else
	{
		if (POSITION.white_en_move)
		{
			positional = (DYNAMIC - 1)->value_positional;
			capture = DYNAMIC->capture;
			ai = AI (move);
			value = static_value[QU[ai]][ai] - static_value[QU[ai]][DI (move)];
			if (capture)
				value -= static_value[capture][ai];
			phase = DYNAMIC->material_ & 0xff;
			endgame = (sint16) (value & 0xffff);
			opening = (endgame < 0) + (sint16) ((value >> 16) & 0xffff);
			anti_phase = 32 - phase;
			value = (endgame * anti_phase + opening * phase) / 32;
			positional += value;
			v = positional + Material_value;
			if (v < -maximum - 16 * (int) (DYNAMIC - 1)->lazy
				|| v > -minimum + 16 * (int) (DYNAMIC - 1)->lazy)
			{
				DYNAMIC->lazy = (DYNAMIC - 1)->lazy + 1;
				DYNAMIC->value = v;
				DYNAMIC->value_positional = positional;
				mobility ();
				return;
			}
		}
		else
		{
			positional = (DYNAMIC - 1)->value_positional;
			capture = DYNAMIC->capture;
			ai = AI (move);
			value = static_value[QU[ai]][ai] - static_value[QU[ai]][DI (move)];
			if (capture)
				value -= static_value[capture][ai];
			phase = DYNAMIC->material_ & 0xff;
			endgame = (sint16) (value & 0xffff);
			opening = (endgame < 0) + (sint16) ((value >> 16) & 0xffff);
			anti_phase = 32 - phase;
			value = (endgame * anti_phase + opening * phase) / 32;
			positional += value;
			v = positional + Material_value;
			if (v < minimum - 16 * (int) (DYNAMIC - 1)->lazy
				|| v > maximum + 16 * (int) (DYNAMIC - 1)->lazy)
			{
				DYNAMIC->lazy = (DYNAMIC - 1)->lazy + 1;
				DYNAMIC->value = -v;
				DYNAMIC->value_positional = positional;
				mobility ();
				return;
			}
		}
	}

	king_white_qu = POSITION.white_king_square;
	king_black_qu = POSITION.black_king_square;
	attak_king_white = attack_king[king_white_qu];
	attak_king_black = attack_king[king_black_qu];
	attak_buono_black = attak_buono_white = 0;
	if (PAWN_VALUE->ZobristPawn != DYNAMIC->ZobristPawn)
		valuation_pawn (PAWN_VALUE);
	value = (DYNAMIC->statik) + (PAWN_VALUE->points);

	DYNAMIC->white_xray = 0;

	A = (bitboard_white_pawn & (~FILEa)) << 7;
	T = A & bitboard_black_king;
	DYNAMIC->black_king_check = (T >> 7);
	attak_pawn_white = A;
	A = (bitboard_white_pawn & (~FILEh)) << 9;
	T = A & bitboard_black_king;
	DYNAMIC->black_king_check |= (T >> 9);
	attak_pawn_white |= A;
	DYNAMIC->attak_white = attak_pawn_white;
	A = (bitboard_black_pawn & (~FILEh)) >> 7;
	T = A & bitboard_white_king;
	DYNAMIC->white_king_check = (T << 7);
	attak_pawn_black = A;
	A = (bitboard_black_pawn & (~FILEa)) >> 9;
	T = A & bitboard_white_king;
	DYNAMIC->white_king_check |= (T << 9);
	attak_pawn_black |= A;
	DYNAMIC->attak_black = attak_pawn_black;

	black_ok_xray = (~bitboard_black_pawn) & ~attak_pawn_white;
	white_ok_xray = (~bitboard_white_pawn) & ~attak_pawn_black;
	white_buono_minor =
		(bitboard_white_knight | bitboard_white_bishop) &
		attak_pawn_white;
	black_buono_minor =
		(bitboard_black_knight | bitboard_black_bishop) & attak_pawn_black;

	if (attak_pawn_white & attak_king_black)
		colpo_king_black = BLOW_pawn;
	else
		colpo_king_black = 0;
	U = (POSITION.occupied_black_white >> 8) & bitboard_white_pawn;
	while (U)
	{
		b = BSF (U);
		value -= pawn_mobility_non;
		bit_FREE (b, U);
	}
	white_mobility_save = ~(attak_pawn_black | bitboard_occupied_white);

	U = bitboard_white_queen;
	while (U)
	{
		b = BSF (U);
		bit_FREE (b, U);
		AA = attack_bishop (b);
		AT = attack_rook (b);
		if (bitboard_black_king & diagonal[b])
		{
			T = attack_bishop (king_black_qu) & AA;
			if (T)
			{
				value += white_queen_diag_xray[QU[BSF (T)]];
				DYNAMIC->white_xray |= T;
				xray_white_list[BSF (T)] = b;
			}
		}
		else if (bitboard_black_king & perpendicular[b])
		{
			T = attack_rook (king_black_qu) & AT;
			if (T)
			{
				value += white_queen_orto_xray[QU[BSF (T)]];
				DYNAMIC->white_xray |= T;
				xray_white_list[BSF (T)] = b;
			}
		}
		A = AA | AT;
		T = A & white_mobility_save;
		DYNAMIC->attak_white |= A;
		if (A & attak_king_black)
			colpo_king_black += BLOW_queen;
		if (A & bitboard_black_king)
			DYNAMIC->black_king_check |= square_fixed[b];
		if (A & attak_king_white)
		{
			value += queen_look;
		}
		value += mobility_queen (T);
		if (A & (~attak_pawn_black) & bitboard_occupied_black)
		{
			value += queen_attak;
		}
		if (bitboard_black_pawn & attack_pawn_black[b])
		{
			value -= pawn_attak_queen;
			attak_buono_black += 1;
		}
		if (RANK (b) == T7)
		{
			if ((bitboard_black_pawn | bitboard_black_king) & RANKS78)
			{
				value += queen_seventh;
				if (bitboard_white_rook & RANK7 & AT
					&& bitboard_black_king & RANK8)
				{
					value += queen_seventh_doppia;
				}
			}
		}
	}

	U = bitboard_white_rook;
	while (U)
	{
		b = BSF (U);
		bit_FREE (b, U);
		A = attack_rook (b);
		DYNAMIC->attak_white |= A;
		if (bitboard_black_king & perpendicular[b])
		{
			T = attack_rook (king_black_qu) & A;
			if (T)
			{
				value += white_rook_xray[QU[BSF (T)]];
				DYNAMIC->white_xray |= T;
				xray_white_list[BSF (T)] = b;
			}
		}
		if (A & attak_king_black)
			colpo_king_black += BLOW_rook;
		if (A & bitboard_black_king)
			DYNAMIC->black_king_check |= square_fixed[b];
		if (A & attak_king_white)
		{
			value += rook_look;
		}
		value += mobility_rook (A & white_ok_xray);

		if (A & (~attak_pawn_black) & bitboard_black_pawn)
		{
			value += rook_attak_pawn;
		}
		if (A &
			((bitboard_black_knight | bitboard_black_bishop) &
			~attak_pawn_black))
		{
			value += rook_attak_minor;
		}
		if (A & bitboard_black_queen)
		{
			value += rook_attak_queen;
			attak_buono_white += 1;
		}
		if (bitboard_black_pawn & attack_pawn_black[b])
		{
			value -= pawn_attak_rook;
			attak_buono_black += 1;
		}

		if ((bitboard_white_pawn & file_open_white[b]) == 0)
		{
			value += rook_open_half;
			if ((bitboard_black_pawn & file_open_white[b]) == 0)
			{
				T = black_buono_minor & file_open_white[b];
				if (!T)
				{
					value += rook_open;
				}
				else
				{
					int t = BSF (T);
					if ((file_isolated[FILE (t)] &
						infront_black[RANK (t)] & bitboard_white_pawn)
						== 0)
					{
						value += rook_open_minor_fixed;
					}
					else
					{
						value += rook_open_minor;
					}
				}
			}
			else
			{
				T = file_open_white[b] & bitboard_black_pawn;
				if (T)
				{
					int t = BSF (T);
					if ((file_isolated[FILE (t)] &
						infront_white[RANK (t)] & bitboard_black_pawn)
						== 0)
					{
						value += rook_half_pawn;
					}
				}
			}
			if (bitboard_black_king & file_open_white[b])
			{
				value += rook_half_king;
			}
		}

		if (square_fixed[b] & outpost_white
			&& (file_isolated[FILE (b)] & infront_white[RANK (b)] &
			bitboard_black_pawn) == 0)
		{
			if (bitboard_white_pawn & attack_pawn_white[b])
			{
				value += outpost_rook;
				if (A &
					(attak_king_black |
					(bitboard_occupied_black & ~attak_pawn_black)) &
					pile_rank[RANK (b)])
					value += outpost_rook_look;
			}
		}

		if (RANK (b) == T8)
		{
			if (bitboard_black_king & RANK8)
			{
				value += rook_eighth_king;
			}
		}
		if (RANK (b) == T7)
		{
			if ((bitboard_black_pawn | bitboard_black_king) & RANKS78)
			{
				value += rook_seventh_king_pawn;
				if (bitboard_black_king & RANK8
					&& (bitboard_white_queen | bitboard_white_rook) &
					RANK7 & A)
				{
					value += rook_seventh_king_pawn_doppia;
				}
			}
		}
		if (RANK (b) == T6
			&& (bitboard_black_pawn | bitboard_black_king) & RANKS678)
		{
			value += rook_sixth_king_pawn;
		}
	}

	white_mobility_save |= bitboard_occupied_black ^ bitboard_black_pawn;

	U = bitboard_white_bishop;
	while (U)
	{
		b = BSF (U);
		bit_FREE (b, U);
		A = attack_bishop (b);
		DYNAMIC->attak_white |= A;
		if (bitboard_black_king & diagonal[b])
		{
			T = attack_bishop (king_black_qu) & A;
			if (T)
			{
				value += white_bishop_xray[QU[BSF (T)]];
				DYNAMIC->white_xray |= T;
				xray_white_list[BSF (T)] = b;
			}
		}
		if (A & attak_king_black)
			colpo_king_black += BLOW_bishop;
		if (A & bitboard_black_king)
			DYNAMIC->black_king_check |= square_fixed[b];
		if (A & attak_king_white)
		{
			value += bishop_look;
		}
		value +=
			mobility_bishop (A & white_mobility_save,
			infront_white[RANK (b)]);

		if (A & (~attak_pawn_black) & bitboard_black_pawn)
		{
			value += bishop_attak_pawn;
		}
		if (A & (~attak_pawn_black) & bitboard_black_knight)
		{
			value += bishop_attak_knight;
		}
		if (A & (bitboard_black_rook | bitboard_black_queen))
		{
			value += bishop_attak_queen_rook;
			attak_buono_white += 1;
		}
		if (bitboard_black_pawn & attack_pawn_black[b])
		{
			value -= pawn_attak_bishop;
			attak_buono_black += 1;
		}

		if (square_fixed[b] & CLEAR)
		{
			value -=
				(PAWN_VALUE->white_pawn_clear +
				PAWN_VALUE->black_pawn_clear / 2) * points (1, 1);
			value +=
				POPCNT (bitboard_black_pawn & CLEAR &
				infront_black[RANK (b)] & ~attak_pawn_black) *
				points (0, 2);
		}
		else
		{
			value -=
				(PAWN_VALUE->white_pawn_dark +
				PAWN_VALUE->black_pawn_dark / 2) * points (1, 1);
			value +=
				POPCNT (bitboard_black_pawn & DARK &
				infront_black[RANK (b)] & ~attak_pawn_black) *
				points (0, 2);
		}

		if (square_fixed[b] & outpost_white
			&& (file_isolated[FILE (b)] & infront_white[RANK (b)] &
			bitboard_black_pawn) == 0)
		{
			if (bitboard_white_pawn & attack_pawn_white[b])
			{
				value += outpost_bishop;
				if (A &
					(attak_king_black |
					(bitboard_occupied_black & ~attak_pawn_black)))
					value += outpost_bishop_look;
			}
		}
		if (QU[bishop_trap_square[b]] == count_pawn_black)
		{
			value -= bishop_trap_value;
			if (QU[buono_trap_bishop_square[b]] == count_pawn_black)
			{
				value -= bishop_trap_look_value;
			}
		}
	}

	U = bitboard_white_knight;
	while (U)
	{
		b = BSF (U);
		bit_FREE (b, U);
		A = attack_knight[b];
		DYNAMIC->attak_white |= A;
		if (A & (attak_king_black | bitboard_black_king))
			colpo_king_black += BLOW_knight;
		if (A & bitboard_black_king)
			DYNAMIC->black_king_check |= square_fixed[b];
		if (A & (attak_king_white | bitboard_white_king))
		{
			value += knight_look;
		}
		value +=
			mobility_knight (A & white_mobility_save,
			infront_white[RANK (b)]);

		if (A & (~attak_pawn_black) & bitboard_black_pawn)
		{
			value += knight_attak_pawn;
		}
		if (A & (~attak_pawn_black) & bitboard_black_bishop)
		{
			value += knight_attak_bishop;
		}
		if (A & (bitboard_black_rook | bitboard_black_queen))
		{
			value += knight_attak_queen_rook;
			attak_buono_white += 1;
		}
		if (bitboard_black_pawn & attack_pawn_black[b])
		{
			value -= pawn_attak_knight;
			attak_buono_black += 1;
		}

		if (square_fixed[b] & outpost_white
			&& (file_isolated[FILE (b)] & infront_white[RANK (b)] &
			bitboard_black_pawn) == 0)
		{
			value += outpost_knight;
			if (bitboard_white_pawn & attack_pawn_white[b])
			{
				value += outpost_knight_pawn;
				if (A &
					(attak_king_black |
					(bitboard_occupied_black & ~attak_pawn_black)))
				{
					value += outpost_knight_look;
					if (RANK (b) == T5)
						value += outpost_knight_quinto;
					if (FILE (b) == CD || FILE (b) == CE)
						value += outpost_knight_DE;
				}
			}
		}
	}

	if (attak_pawn_black & attak_king_white)
		colpo_king_white = BLOW_pawn;
	else
		colpo_king_white = 0;
	U = (POSITION.occupied_black_white << 8) & bitboard_black_pawn;
	DYNAMIC->black_xray = 0;
	while (U)
	{
		b = BSF (U);
		value += pawn_mobility_non;
		bit_FREE (b, U);
	}
	black_mobility_save = ~(attak_pawn_white | bitboard_occupied_black);

	U = bitboard_black_queen;
	while (U)
	{
		b = BSF (U);
		bit_FREE (b, U);
		AA = attack_bishop (b);
		AT = attack_rook (b);
		if (bitboard_white_king & diagonal[b])
		{
			T = attack_bishop (king_white_qu) & AA;
			if (T)
			{
				value -= black_queen_diag_xray[QU[BSF (T)]];
				DYNAMIC->black_xray |= T;
				xray_black_list[BSF (T)] = b;
			}
		}
		else if (bitboard_white_king & perpendicular[b])
		{
			T = attack_rook (king_white_qu) & AT;
			if (T)
			{
				value -= black_queen_orto_xray[QU[BSF (T)]];
				DYNAMIC->black_xray |= T;
				xray_black_list[BSF (T)] = b;
			}
		}
		A = AA | AT;
		T = A & black_mobility_save;
		DYNAMIC->attak_black |= A;
		if (A & attak_king_white)
			colpo_king_white += BLOW_queen;
		if (A & bitboard_white_king)
			DYNAMIC->white_king_check |= square_fixed[b];
		if (A & attak_king_black)
		{
			value -= queen_look;
		}
		value -= mobility_queen (T);

		if (A & (~attak_pawn_white) & bitboard_occupied_white)
		{
			value -= queen_attak;
		}
		if (bitboard_white_pawn & attack_pawn_white[b])
		{
			value += pawn_attak_queen;
			attak_buono_white += 1;
		}

		if (RANK (b) == T2)
		{
			if ((bitboard_white_pawn | bitboard_white_king) & RANKS12)
			{
				value -= queen_seventh;
				if (bitboard_black_rook & RANK2 & AT
					&& bitboard_white_king & RANK1)
				{
					value -= queen_seventh_doppia;
				}
			}
		}
	}

	U = bitboard_black_rook;
	while (U)
	{
		b = BSF (U);
		bit_FREE (b, U);
		A = attack_rook (b);
		DYNAMIC->attak_black |= A;
		if (bitboard_white_king & perpendicular[b])
		{
			T = A & attack_rook (king_white_qu);
			if (T)
			{
				value -= black_rook_xray[QU[BSF (T)]];
				DYNAMIC->black_xray |= T;
				xray_black_list[BSF (T)] = b;
			}
		}
		if (A & attak_king_white)
			colpo_king_white += BLOW_rook;
		if (A & bitboard_white_king)
			DYNAMIC->white_king_check |= square_fixed[b];
		if (A & attak_king_black)
		{
			value -= rook_look;
		}
		value -= mobility_rook (A & black_ok_xray);

		if (A & (~attak_pawn_white) & bitboard_white_pawn)
		{
			value -= rook_attak_pawn;
		}
		if (A & (bitboard_white_knight | bitboard_white_bishop) &
			~attak_pawn_white)
		{
			value -= rook_attak_minor;
		}
		if (A & bitboard_white_queen)
		{
			value -= rook_attak_queen;
			attak_buono_black += 1;
		}
		if (bitboard_white_pawn & attack_pawn_white[b])
		{
			value += pawn_attak_rook;
			attak_buono_white += 1;
		}

		if ((bitboard_black_pawn & file_open_black[b]) == 0)
		{
			value -= rook_open_half;
			if ((bitboard_white_pawn & file_open_black[b]) == 0)
			{
				T = white_buono_minor & file_open_black[b];
				if (!T)
				{
					value -= rook_open;
				}
				else
				{
					int t = BSR (T);
					if ((file_isolated[FILE (t)] &
						infront_white[RANK (t)] & bitboard_black_pawn)
						== 0)
					{
						value -= rook_open_minor_fixed;
					}
					else
					{
						value -= rook_open_minor;
					}
				}
			}
			else
			{
				T = file_open_black[b] & bitboard_white_pawn;
				if (T)
				{
					int t = BSR (T);
					if ((file_isolated[FILE (t)] &
						infront_black[RANK (t)] & bitboard_white_pawn)
						== 0)
					{
						value -= rook_half_pawn;
					}
				}
			}
			if (bitboard_white_king & file_open_black[b])
			{
				value -= rook_half_king;
			}
		}

		if (square_fixed[b] & outpost_black
			&& (file_isolated[FILE (b)] & infront_black[RANK (b)] &
			bitboard_white_pawn) == 0)
		{
			if (bitboard_black_pawn & attack_pawn_black[b])
			{
				value -= outpost_rook;
				if (A &
					(attak_king_white |
					(bitboard_occupied_white & ~attak_pawn_white)) &
					pile_rank[RANK (b)])
					value -= outpost_rook_look;
			}
		}

		if (RANK (b) == T1)
		{
			if (bitboard_white_king & RANK1)
			{
				value -= rook_eighth_king;
			}
		}
		if (RANK (b) == T2)
		{
			if ((bitboard_white_pawn | bitboard_white_king) & RANKS12)
			{
				value -= rook_seventh_king_pawn;
				if (bitboard_white_king & RANK1
					&& (bitboard_black_queen | bitboard_black_rook) & RANK2 &
					A)
				{
					value -= rook_seventh_king_pawn_doppia;
				}
			}
		}
		if (RANK (b) == T3
			&& (bitboard_white_pawn | bitboard_white_king) & RANKS123)
		{
			value -= rook_sixth_king_pawn;
		}
	}

	black_mobility_save |= bitboard_occupied_white ^ bitboard_white_pawn;

	U = bitboard_black_bishop;
	while (U)
	{
		b = BSF (U);
		bit_FREE (b, U);
		A = attack_bishop (b);
		DYNAMIC->attak_black |= A;
		if (bitboard_white_king & diagonal[b])
		{
			T = A & attack_bishop (king_white_qu);
			if (T)
			{
				value -= black_bishop_xray[QU[BSF (T)]];
				DYNAMIC->black_xray |= T;
				xray_black_list[BSF (T)] = b;
			}
		}
		if (A & attak_king_white)
			colpo_king_white += BLOW_bishop;
		if (A & bitboard_white_king)
			DYNAMIC->white_king_check |= square_fixed[b];
		if (A & attak_king_black)
		{
			value -= bishop_look;
		}
		value -=
			mobility_bishop (A & black_mobility_save,
			infront_black[RANK (b)]);

		if (A & (~attak_pawn_white) & bitboard_white_pawn)
		{
			value -= bishop_attak_pawn;
		}
		if (A & (~attak_pawn_white) & bitboard_white_knight)
		{
			value -= bishop_attak_knight;
		}
		if (A & (bitboard_white_rook | bitboard_white_queen))
		{
			value -= bishop_attak_queen_rook;
			attak_buono_black += 1;
		}
		if (bitboard_white_pawn & attack_pawn_white[b])
		{
			value += pawn_attak_bishop;
			attak_buono_white += 1;
		}

		if (square_fixed[b] & CLEAR)
		{
			value +=
				(PAWN_VALUE->black_pawn_clear +
				PAWN_VALUE->white_pawn_clear / 2) * points (1, 1);
			value -=
				POPCNT (bitboard_white_pawn & CLEAR &
				infront_white[RANK (b)] & ~attak_pawn_white) *
				points (0, 2);
		}
		else
		{
			value +=
				(PAWN_VALUE->black_pawn_dark +
				PAWN_VALUE->white_pawn_dark / 2) * points (1, 1);
			value -=
				POPCNT (bitboard_white_pawn & DARK &
				infront_white[RANK (b)] & ~attak_pawn_white) *
				points (0, 2);
		}

		if (square_fixed[b] & outpost_black
			&& (file_isolated[FILE (b)] & infront_black[RANK (b)] &
			bitboard_white_pawn) == 0)
		{
			if (bitboard_black_pawn & attack_pawn_black[b])
			{
				value -= outpost_bishop;
				if (A &
					(attak_king_white |
					(bitboard_occupied_white & ~attak_pawn_white)))
					value -= outpost_bishop_look;
			}
		}

		if (QU[bishop_trap_square[b]] == count_pawn_white)
		{
			value += bishop_trap_value;
			if (QU[buono_trap_bishop_square[b]] == count_pawn_white)
			{
				value += bishop_trap_look_value;
			}
		}
	}

	U = bitboard_black_knight;
	while (U)
	{
		b = BSF (U);
		bit_FREE (b, U);
		A = attack_knight[b];
		DYNAMIC->attak_black |= A;
		if (A & (attak_king_white | bitboard_white_king))
			colpo_king_white += BLOW_knight;
		if (A & bitboard_white_king)
			DYNAMIC->white_king_check |= square_fixed[b];
		if (A & (attak_king_black | bitboard_black_king))
		{
			value -= knight_look;
		}
		value -=
			mobility_knight (A & black_mobility_save,
			infront_black[RANK (b)]);

		if (A & (~attak_pawn_white) & bitboard_white_pawn)
		{
			value -= knight_attak_pawn;
		}
		if (A & (~attak_pawn_white) & bitboard_white_bishop)
		{
			value -= knight_attak_bishop;
		}
		if (A & (bitboard_white_rook | bitboard_white_queen))
		{
			value -= knight_attak_queen_rook;
			attak_buono_black += 1;
		}
		if (bitboard_white_pawn & attack_pawn_white[b])
		{
			value += pawn_attak_knight;
			attak_buono_white += 1;
		}

		if (square_fixed[b] & outpost_black
			&& (file_isolated[FILE (b)] & infront_black[RANK (b)] &
			bitboard_white_pawn) == 0)
		{
			value -= outpost_knight;
			if (bitboard_black_pawn & attack_pawn_black[b])
			{
				value -= outpost_knight_pawn;
				if (A &
					(attak_king_white |
					(bitboard_occupied_white & ~attak_pawn_white)))
				{
					value -= outpost_knight_look;
					if (RANK (b) == T4)
						value -= outpost_knight_quinto;
					if (FILE (b) == CD || FILE (b) == CE)
						value -= outpost_knight_DE;
				}
			}
		}
	}

	DYNAMIC->attak_white |= attak_king_white;
	DYNAMIC->attak_black |= attak_king_black;
	if (attak_king_black & bitboard_white_king)
	{
		DYNAMIC->white_king_check |=
			square_fixed[POSITION.black_king_square];
		DYNAMIC->black_king_check |=
			square_fixed[POSITION.white_king_square];
	}

	if ((~DYNAMIC->attak_black) & attak_king_white & bitboard_black_pawn)
	{
		value += king_attack_nonlook_pawn;
	}

	T = trap_rook[king_white_qu] & bitboard_white_rook;
	if (T)
	{
		int t = BSF (T);
		T = file_open_white[t] & bitboard_white_pawn;
		if (T)
		{
			t = BSF (T);
			t >>= 3;
			value -= points (10 * (6 - t), 0);
		}
	}

	if (attak_king_white & attak_king_black)
		colpo_king_white += BLOW_king;
	ch = (((king_safety_multiplier[colpo_king_white >> 16] *
		(colpo_king_white & 0xffff)) / king_safety_bonus) << 16) +
		PAWN_VALUE->white_king_periglio;
	if (!bitboard_black_queen)
	{
		ch >>= 16;
		ch *=
			POPCNT (bitboard_black_rook | bitboard_black_knight |
			bitboard_black_bishop);
		ch >>= 3;
		ch <<= 16;
	}
	value -= ch;

	if ((~DYNAMIC->attak_white) & attak_king_black & bitboard_white_pawn)
	{
		value -= king_attack_nonlook_pawn;
	}

	T = trap_rook[king_black_qu] & bitboard_black_rook;
	if (T)
	{
		int t = BSR (T);
		T = file_open_black[t] & bitboard_black_pawn;
		if (T)
		{
			t = BSR (T);
			t >>= 3;
			value += points (10 * (t - 1), 0);
		}
	}

	if (attak_king_white & attak_king_black)
		colpo_king_black += BLOW_king;
	ch =
		(((king_safety_multiplier[colpo_king_black >> 16] *
		(colpo_king_black & 0xffff)) / king_safety_bonus) << 16) +
		PAWN_VALUE->black_king_periglio;
	if (!bitboard_white_queen)
	{
		ch >>= 16;
		ch *=
			POPCNT (bitboard_white_rook | bitboard_white_knight |
			bitboard_white_bishop);
		ch >>= 3;
		ch <<= 16;
	}
	value += ch;

	if (attak_buono_white >= 2)
	{
		value += attak_multiple;
	}
	if (attak_buono_black >= 2)
	{
		value -= attak_multiple;
	}

#define END_queen ( (DYNAMIC->flags & 28) == 4)
#define FINAL_rook ( (DYNAMIC->flags & 28) == 8)

	if ((bitboard_white_rook | bitboard_white_queen) &
		cramp_file[FILE (king_black_qu)])
	{
		value += points (0, 5);
		if ((cramp_file[FILE (king_black_qu)] &
			(bitboard_white_pawn | bitboard_black_pawn)) == 0)
			value += points (5, 15);
	}
	if ((bitboard_black_rook | bitboard_black_queen) &
		cramp_file[FILE (king_white_qu)])
	{
		value -= points (0, 5);
		if ((cramp_file[FILE (king_white_qu)] &
			(bitboard_black_pawn | bitboard_white_pawn)) == 0)
			value -= points (5, 15);
	}

	U = PAWN_VALUE->white_pawn_free_line;
	while (U)
	{
		b = BSR (pile_file[BSF (U)] & bitboard_white_pawn);
		bit_FREE (0, U);
		tr = RANK (b);
		if (tr <= T3)
			continue;
		if (FINAL_rook)
		{
			if (bitboard_white_rook & file_open_white[b])
			{
				if (tr == T7)
				{
					value -= endgame_rook_seventh;
				}
				else if (tr == T6)
				{
					value -= endgame_rook_sixth;
				}
			}
			if (file_open_white[b] & bitboard_white_king
				&& cramp_file[FILE (king_white_qu)] & bitboard_black_rook)
				value -= points (0, 1 << (tr - T2));
		}
		if (QU[b + 8] == 0)
		{
			value += pawn_free_mobility[tr];
		}
		if ((file_open_white[b] & bitboard_occupied_white) == 0)
		{
			value += pawn_free_my_ok[tr];
		}
		if ((file_open_white[b] & bitboard_occupied_black) == 0)
		{
			value += pawn_free_your_ok[tr];
		}
		if ((file_open_white[b] & (~DYNAMIC->attak_white) &
			DYNAMIC->attak_black) == 0)
		{
			value += pawn_free_free[tr];
		}
		if (END_queen)
		{
			if (tr == T7 && bitboard_white_queen & file_open_white[b])
			{
				value -= endgame_queen_seventh;
			}
			value += rank_endgame_queen[tr];
		}
	}

	U = PAWN_VALUE->black_pawn_free_line;
	while (U)
		while (U)
		{
			b = BSF (pile_file[BSF (U)] & bitboard_black_pawn);
			bit_FREE (0, U);
			tr = RANK (b);
			if (tr >= T6)
				continue;
			if (FINAL_rook)
			{
				if (bitboard_black_rook & file_open_black[b])
				{
					if (tr == T2)
					{
						value += endgame_rook_seventh;
					}
					else if (tr == T3)
					{
						value += endgame_rook_sixth;
					}
				}
				if (file_open_black[b] & bitboard_black_king
					&& cramp_file[FILE (king_black_qu)] &
					bitboard_white_rook)
					value += points (0, 1 << (T7 - tr));
			}
			if (QU[b - 8] == 0)
			{
				value -= pawn_free_mobility[7 - tr];
			}
			if ((file_open_black[b] & bitboard_occupied_black) == 0)
			{
				value -= pawn_free_my_ok[7 - tr];
			}
			if ((file_open_black[b] & bitboard_occupied_white) == 0)
			{
				value -= pawn_free_your_ok[7 - tr];
			}
			if ((file_open_black[b] & DYNAMIC->
				attak_white & ~DYNAMIC->attak_black) == 0)
			{
				value -= pawn_free_free[7 - tr];
			}
			if (END_queen)
			{
				if (tr == T2 && bitboard_black_queen & file_open_black[b])
				{
					value += endgame_queen_seventh;
				}
				value -= rank_endgame_queen[7 - tr];
			}
		}

		phase = DYNAMIC->material_ & 0xff;
		endgame = (sint16) (value & 0xffff);
		opening = (endgame < 0) + (sint16) ((value >> 16) & 0xffff);
		anti_phase = 32 - phase;
		value = endgame * anti_phase + opening * phase;
		value = value / 32 + Material_value;
		value = (value * SIGN) / 128;

		if (value > 0)
			value -= (PAWN_VALUE->white_fly_number * MINIMUM (value, 100)) / 64;
		else
			value += (PAWN_VALUE->black_fly_number * MINIMUM (-value, 100)) / 64;

#define mate_bishop_knight (DYNAMIC->flags & 128)
#define FAR_(i,j)\
	( MAXIMUM (file_detach (i, j), rank_detach (i, j) ) )
#define NEAR_(i,j)\
	( MINIMUM ( file_detach (i, j), rank_detach (i, j) ) )

		if (mate_bishop_knight)
		{
			if (value > 0)
			{
				if (bitboard_white_clear)
					value -=
					20 * MINIMUM (FAR_ (A8, POSITION.black_king_square),
					FAR_ (H1,
					POSITION.black_king_square)) +
					10 * MINIMUM (NEAR_ (A8, POSITION.black_king_square),
					NEAR_ (H1, POSITION.black_king_square));
				else
					value -=
					20 * MINIMUM (FAR_ (A1, POSITION.black_king_square),
					FAR_ (H8,
					POSITION.black_king_square)) +
					10 * MINIMUM (NEAR_ (A1, POSITION.black_king_square),
					NEAR_ (H8, POSITION.black_king_square));
			}
			else
			{
				if (bitboard_black_clear)
					value +=
					20 * MINIMUM (FAR_ (A8, POSITION.white_king_square),
					FAR_ (H1,
					POSITION.white_king_square)) +
					10 * MINIMUM (NEAR_ (A8, POSITION.white_king_square),
					NEAR_ (H1, POSITION.white_king_square));
				else
					value +=
					20 * MINIMUM (FAR_ (A1, POSITION.white_king_square),
					FAR_ (H8,
					POSITION.white_king_square)) +
					10 * MINIMUM (NEAR_ (A1, POSITION.white_king_square),
					NEAR_ (H8, POSITION.white_king_square));
			}
		}

		if (DYNAMIC->move50 > 50)
		{
			value *= (114 - DYNAMIC->move50);
			value /= 64;
		}

#define WHITE_MINOR (DYNAMIC->flags & 32)
#define WHITE_PIECE (DYNAMIC->flags & 2)
#define BLACK_MINOR (DYNAMIC->flags & 64)
#define BLACK_PIECE (DYNAMIC->flags & 1)

		if (value > 0)
		{
			if (WHITE_MINOR)
			{
				if (bitboard_white_knight)
				{
					if (bitboard_white_pawn == square_fixed[A7]
					&& (bitboard_black_king |
						attack_king[POSITION.black_king_square]) &
						square_fixed[A8])
						value = 0;
					if (bitboard_white_pawn == square_fixed[H7]
					&& (bitboard_black_king |
						attack_king[POSITION.black_king_square]) &
						square_fixed[H8])
						value = 0;
				}
				else if (bitboard_white_clear && !(bitboard_white_pawn & nonH)
					&& (bitboard_black_king |
					attack_king[POSITION.black_king_square]) &
					square_fixed[H8])
				{
					if (bitboard_white_pawn & square_fixed[H5]
					&& bitboard_black_pawn ==
						(square_fixed[G7] | square_fixed[H6]));
					else
						value = 0;
				}
				else if (bitboard_white_dark && !(bitboard_white_pawn & nonA)
					&& (bitboard_black_king |
					attack_king[POSITION.black_king_square]) &
					square_fixed[A8])
				{
					if (bitboard_white_pawn & square_fixed[A5]
					&& bitboard_black_pawn ==
						(square_fixed[B7] | square_fixed[A6]));
					else
						value = 0;
				}
				if (!bitboard_white_pawn)
					value = 0;
			}
		}

		else
		{
			if (BLACK_MINOR)
			{
				if (bitboard_black_knight)
				{
					if (bitboard_black_pawn == square_fixed[A2]
					&& (bitboard_white_king |
						attack_king[POSITION.white_king_square]) &
						square_fixed[A1])
						value = 0;
					if (bitboard_black_pawn == square_fixed[H2]
					&& (bitboard_white_king |
						attack_king[POSITION.white_king_square]) &
						square_fixed[H1])
						value = 0;
				}
				else if (bitboard_black_dark && !(bitboard_black_pawn & nonH)
					&& (bitboard_white_king |
					attack_king[POSITION.white_king_square]) &
					square_fixed[H1])
				{
					if (bitboard_black_pawn & square_fixed[H4]
					&& bitboard_white_pawn ==
						(square_fixed[G2] | square_fixed[H3]));
					else
						value = 0;
				}
				else if (bitboard_black_clear && !(bitboard_black_pawn & nonA)
					&& (bitboard_white_king |
					attack_king[POSITION.white_king_square]) &
					square_fixed[A1])
				{
					if (bitboard_black_pawn & square_fixed[A4]
					&& bitboard_white_pawn ==
						(square_fixed[B2] | square_fixed[A3]));
					else
						value = 0;
				}
				if (!bitboard_black_pawn)
					value = 0;
			}
		}

		DYNAMIC->value = POSITION.white_en_move ? value : -value;
		DYNAMIC->value_positional = value - Material_value;
		DYNAMIC->lazy = 0;
		value_zobrist[DYNAMIC->Zobrist & value_zobrist_hide] =
			(DYNAMIC->Zobrist & 0xffffffffffff0000ull) | (DYNAMIC->value & 0xffff);
		if (move && !(DYNAMIC - 1)->lazy)
			POSITION.white_en_move ? trick_white (move) : trick_black (move);

}
