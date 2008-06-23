#include "bitboards.h"
#include "position.h"
#include "utils.h"

int g_dist[64][64];
U64 BB_SINGLE[64];
U64 BB_SINGLE_ZERO[64];

U64 BB_PAWNW_ATTACKS[64];
U64 BB_PAWNB_ATTACKS[64];
U64 BB_KNIGHT_ATTACKS[64];
U64 BB_BISHOP_ATTACKS[64];
U64 BB_ROOK_ATTACKS[64];
U64 BB_QUEEN_ATTACKS[64];
U64 BB_KING_ATTACKS[64];

U64 BB_BETWEEN[64][64];
U64 BB_UPPER[64];
U64 BB_LOWER[64];

U64 BB_PAWNW_SQUARE[64];
U64 BB_PAWNB_SQUARE[64];

U64 BB_VERTICAL[8] =
{
	LL(0x8080808080808080),
	LL(0x4040404040404040),
	LL(0x2020202020202020),
	LL(0x1010101010101010),
	LL(0x0808080808080808),
	LL(0x0404040404040404),
	LL(0x0202020202020202),
	LL(0x0101010101010101)
};

void init_bitboards()
{
	int i = 0, j = 0;

	U64 x = ((U64) 1) << 63;
	for (i = 0; i < 64; i++)
	{
		BB_SINGLE[i] = x;
		BB_SINGLE_ZERO[i] = ~x;
		x >>= 1;
	}

	for (i = 0; i < 64; i++)
	{
		BB_UPPER[i] = 0;
		U64 upper = bb_up(BB_SINGLE[i]);
		for (j = 0; j < 8; j++)
		{
			BB_UPPER[i] |= upper;
			upper = bb_up(upper);
		}

		BB_LOWER[i] = 0;
		U64 lower = bb_down(BB_SINGLE[i]);
		for (j = 0; j < 8; j++)
		{
			BB_LOWER[i] |= lower;
			lower = bb_down(lower);
		}

		BB_BETWEEN[i][j] = 0;
	}

	int from = NF, to = NF;
	int dir = 0;

	for (from = 0; from < 64; from++)
	{
		BB_PAWNW_ATTACKS[from] = 0;
		BB_PAWNB_ATTACKS[from] = 0;
		BB_KNIGHT_ATTACKS[from] = 0;
		BB_BISHOP_ATTACKS[from] = 0;
		BB_ROOK_ATTACKS[from] = 0;
		BB_QUEEN_ATTACKS[from] = 0;
		BB_KING_ATTACKS[from] = 0;

		to = steps[1][from];
		if (to != NF)
			set_bit(BB_PAWNW_ATTACKS[from], to);

		to = steps[3][from];
		if (to != NF)
			set_bit(BB_PAWNW_ATTACKS[from], to);

		to = steps[5][from];
		if (to != NF)
			set_bit(BB_PAWNB_ATTACKS[from], to);

		to = steps[7][from];
		if (to != NF)
			set_bit(BB_PAWNB_ATTACKS[from], to);

		for (dir = 0; dir < 8; dir++)
		{
			to = knight_steps[dir][from];
			if (to != NF)
				set_bit(BB_KNIGHT_ATTACKS[from], to);

			to = steps[dir][from];
			if (to != NF)
				set_bit(BB_KING_ATTACKS[from], to);
		}

		for (dir = 1; dir < 8; dir += 2)
		{
			to = steps[dir][from];
			U64 between = 0;
			while (to != NF)
			{
				set_bit(BB_BISHOP_ATTACKS[from], to);

				BB_BETWEEN[from][to] = between;
				set_bit(between, to);

				to = steps[dir][to];
			}
		}

		for (dir = 0; dir < 8; dir += 2)
		{
			to = steps[dir][from];
			U64 between = 0;
			while (to != NF)
			{
				set_bit(BB_ROOK_ATTACKS[from], to);

				BB_BETWEEN[from][to] = between;
				set_bit(between, to);

				to = steps[dir][to];
			}
		}

		BB_QUEEN_ATTACKS[from] = BB_ROOK_ATTACKS[from] | BB_BISHOP_ATTACKS[from];
	}

	// table of distances

	for (int f1 = 0; f1 < 64; f1++)
	{
		for (int f2 = 0; f2 < 64; f2++)
		{
			int drow = getrow(f1) - getrow(f2);
			int dcol = getcol(f1) - getcol(f2);

			if (drow < 0)
				drow *= -1;
			if (dcol < 0)
				dcol *= -1;

			g_dist[f1][f2] = (drow > dcol)? drow : dcol;
		}
	}

	// pawn squares

	for (int f = 0; f < 64; f++)
	{
		x = BB_UPPER[f] | BB_SINGLE[f];
		for (j = 0; j < getrow(f); j++)
		{
			x |= bb_right(x);
			x |= bb_left(x);
		}

		BB_PAWNW_SQUARE[f] = x;

		x = BB_LOWER[f] | BB_SINGLE[f];
		for (j = 0; j < 7 - getrow(f); j++)
		{
			x |= bb_right(x);
			x |= bb_left(x);
		}

		BB_PAWNB_SQUARE[f] = x;
	}
}
////////////////////////////////////////////////////////////////////////////////

void print_bitboard(U64 b)
{
	out("\n");
	for (int f = 0; f < 64; f++)
	{
		if (b & BB_SINGLE[f])
			out(" 1");
		else
			out(" -");

		if (getcol(f) == 7)
			out("\n");
	}
	out("\n");
}
////////////////////////////////////////////////////////////////////////////////

