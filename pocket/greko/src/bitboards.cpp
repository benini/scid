#include "bitboards.h"
#include "position.h"
#include "utils.h"

int g_dist[64][64];

U64 BB_SINGLE[64];
U64 BB_SINGLE_ZERO[64];
U64 BB_DIR[64][8];
U64 BB_PAWN_ATTACKS[64][2];
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
U8  DIRS[64][64];

#ifdef MAGIC

int B_OFFSET[64];
U64* B_DATA = 0;

int R_OFFSET[64];
U64* R_DATA = 0;

#endif

U8 FIRST_IN_16[65536];

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

U64 EnumBits(U64 mask, U64 n)
{
	U64 x = 0;
	while (mask != 0 && n != 0)
	{
		int f = PopLSB(mask);
		int digit = n & 1;
		n >>= 1;
		x |= digit * BB_SINGLE[f];		
	}
	return x;	
}
////////////////////////////////////////////////////////////////////////////////

#define TRACE(Shift)        \
   x = Shift(BB_SINGLE[f]); \
   while (x)                \
   {                        \
      att |= x;             \
      if (x & occupied)     \
         break;             \
                            \
      x = Shift(x);         \
   }

U64 BishopAttacksTrace(int f, const U64& occupied)
{
	U64 att = 0;
	U64 x = 0;

	TRACE(UpRight);
	TRACE(UpLeft);
	TRACE(DownLeft);
	TRACE(DownRight);

	return att;
}
////////////////////////////////////////////////////////////////////////////////

U64 RookAttacksTrace(int f, const U64& occupied)
{
	U64 att = 0;
	U64 x = 0;

	TRACE(Right);
	TRACE(Up);
	TRACE(Left);
	TRACE(Down);

	return att;
}
////////////////////////////////////////////////////////////////////////////////

#undef TRACE

void init_bitboards()
{
	int i = 0, j = 0;

	// Bitscan
	for (i = 1; i < 65536; ++i)
	{
		int x = 0x8000;
		for (j = 0; j < 16; ++j)
		{
			if (i & x)
			{
				FIRST_IN_16[i] = j;
				break;
			}
			x >>= 1;
		}
	}

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
		BB_PAWN_ATTACKS[from][WHITE] = 0;
		BB_PAWN_ATTACKS[from][BLACK] = 0;
		BB_KNIGHT_ATTACKS[from] = 0;
		BB_BISHOP_ATTACKS[from] = 0;
		BB_ROOK_ATTACKS[from] = 0;
		BB_QUEEN_ATTACKS[from] = 0;
		BB_KING_ATTACKS[from] = 0;

		to = steps[1][from];
		if (to != NF)
			set_bit(BB_PAWN_ATTACKS[from][WHITE], to);

		to = steps[3][from];
		if (to != NF)
			set_bit(BB_PAWN_ATTACKS[from][WHITE], to);

		to = steps[5][from];
		if (to != NF)
			set_bit(BB_PAWN_ATTACKS[from][BLACK], to);

		to = steps[7][from];
		if (to != NF)
			set_bit(BB_PAWN_ATTACKS[from][BLACK], to);

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

	// Directions
	
#define TRACE_DIR(dir, Funk, delta) \
   x = Funk(BB_SINGLE[from]);       \
   y = 0;                           \
   to = from + (delta);             \
   while (x)                        \
   {                                \
      BB_BETWEEN[from][to] = y;     \
      DIRS[from][to] = dir;         \
      y |= x;                       \
      x = Funk(x);                  \
      to += (delta);                \
   }                                \
   BB_DIR[from][dir] = y;

	U64 y = 0;
	for (from = 0; from < 64; ++from)
	{
		for (to = 0; to < 64; ++to)
	  	{
			BB_BETWEEN[from][to] = 0;
			DIRS[from][to] = DIR_NO;
	  	}
	
		TRACE_DIR (0, Right, 1)
		TRACE_DIR (1, UpRight, -7)
		TRACE_DIR (2, Up, -8)
		TRACE_DIR (3, UpLeft, -9)
		TRACE_DIR (4, Left, -1)
		TRACE_DIR (5, DownLeft, 7)
		TRACE_DIR (6, Down, 8)
		TRACE_DIR (7, DownRight, 9)
	}

	// table of distances

	for (int f1 = 0; f1 < 64; f1++)
	{
		for (int f2 = 0; f2 < 64; f2++)
		{
			int drow = Row(f1) - Row(f2);
			int dcol = Col(f1) - Col(f2);

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
		for (j = 0; j < Row(f); j++)
		{
			x |= bb_right(x);
			x |= bb_left(x);
		}

		BB_PAWNW_SQUARE[f] = x;

		x = BB_LOWER[f] | BB_SINGLE[f];
		for (j = 0; j < 7 - Row(f); j++)
		{
			x |= bb_right(x);
			x |= bb_left(x);
		}

		BB_PAWNB_SQUARE[f] = x;
	}

#ifdef MAGIC

	int offset;

	offset = 0;
	for (int f = 0; f < 64; ++f)
	{
		B_OFFSET[f] = offset;
		offset += (1 << B_BITS[f]);
	}
	B_DATA = new U64[offset];

	for (int f = 0; f < 64; ++f)
	{
		U64 mask = B_MASK[f];
		int bits = B_BITS[f];

		for (int n = 0; n < (1 << bits); ++n)
		{
			U64 occupied = EnumBits(mask, n);
			U64 att = BishopAttacksTrace(f, occupied);
			int index = B_OFFSET[f];
			index += int((occupied * B_MULT[f]) >> (64 - bits));

			B_DATA[index] = att;
		}
	}

	offset = 0;
	for (int f = 0; f < 64; ++f)
	{
		R_OFFSET[f] = offset;
		offset += (1 << R_BITS[f]);
	}
	R_DATA = new U64[offset];

	for (int f = 0; f < 64; ++f)
	{
		U64 mask = R_MASK[f];
		int bits = R_BITS[f];

		for (int n = 0; n < (1 << bits); ++n)
		{
			U64 occupied = EnumBits(mask, n);
			U64 att = RookAttacksTrace(f, occupied);
			int index = R_OFFSET[f];
			index += int((occupied * R_MULT[f]) >> (64 - bits));

			R_DATA[index] = att;
		}
	}

#endif

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

		if (Col(f) == 7)
			out("\n");
	}
	out("\n");
}
////////////////////////////////////////////////////////////////////////////////

