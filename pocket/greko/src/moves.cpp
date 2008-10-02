#ifdef _MSC_VER
#pragma warning(disable: 4996)
#endif

#include <string.h>

#include "eval.h"
#include "moves.h"
#include "position.h"
#include "search.h"
#include "utils.h"

extern int g_history[14][64];

U64 GetPinMask(const Position& pos, FLD from, FLD K, const U64& occupied, 
		COLOR opp)
{
	U64 mask = LL(0xffffffffffffffff);

	if (DIRS[from][K] == DIR_NO)
		return mask;
	
	if (BB_BETWEEN[K][from] & occupied)
		return mask;

	U64 x = BB_BISHOP_ATTACKS[K] & 
		(pos.Bits(BISHOPW | opp) | pos.Bits(QUEENW | opp));

	while (x)
	{
		FLD f = PopLSB(x);
		if ((BB_BETWEEN[from][f] & occupied) == 0)
		{
			if (BB_BETWEEN[K][f] & BB_SINGLE[from])
				mask &= (BB_BETWEEN[K][f] | BB_SINGLE[f]);
		}
	}

	x = BB_ROOK_ATTACKS[K] & 
		(pos.Bits(ROOKW | opp) | pos.Bits(QUEENW | opp));

	while (x)
	{
		FLD f = PopLSB(x);
		if ((BB_BETWEEN[from][f] & occupied) == 0)
		{
			if (BB_BETWEEN[K][f] & BB_SINGLE[from])
				mask &= (BB_BETWEEN[K][f] | BB_SINGLE[f]);
		}
	}

	return mask;
}
////////////////////////////////////////////////////////////////////////////////


void MoveList::AddSimpleChecks(const Position& pos)
{
	COLOR side = pos.Side();
	COLOR opp = Opp(side);

	U64 x, y, pin;
	FLD from, to;
	PIECE piece;
	FLD K = pos.King(side);
	FLD Kopp = pos.King(opp);
	U64 occupied = pos.BitsAll();
	U64 free = ~occupied;

	U64 knightZone = BB_KNIGHT_ATTACKS[Kopp] & free;
	U64 bishopZone = BishopAttacks(Kopp, occupied) & free;
	U64 rookZone = RookAttacks(Kopp, occupied) & free;

	piece = KNIGHTW | side;
	x = pos.Bits(piece);
	while (x)
	{
		from = PopLSB(x);
		pin = GetPinMask(pos, from, K, occupied, opp);
		y = BB_KNIGHT_ATTACKS[from] & pin & knightZone;

		while (y)
		{
			to = PopLSB(y);
			Add(from, to, piece);
		}
	}

	piece = BISHOPW | side;
	x = pos.Bits(piece);
	while (x)
	{
		from = PopLSB(x);
		pin = GetPinMask(pos, from, K, occupied, opp);
		y = BishopAttacks(from, occupied) & pin & bishopZone;

		while (y)
		{
			to = PopLSB(y);
			Add(from, to, piece);
		}
	}

	piece = ROOKW | side;
	x = pos.Bits(piece);
	while (x)
	{
		from = PopLSB(x);
		pin = GetPinMask(pos, from, K, occupied, opp);
		y = RookAttacks(from, occupied) & pin & rookZone;

		while (y)
		{
			to = PopLSB(y);
			Add(from, to, piece);
		}
	}

	piece = QUEENW | side;
	x = pos.Bits(piece);
	while (x)
	{
		from = PopLSB(x);
		pin = GetPinMask(pos, from, K, occupied, opp);
		y = QueenAttacks(from, occupied) & pin & (rookZone | bishopZone);

		while (y)
		{
			to = PopLSB(y);
			Add(from, to, piece);
		}
	}
}
////////////////////////////////////////////////////////////////////////////////

Move MoveList::GetNthBest(int n)
{
	for (int i = n + 1; i < m_size; ++i)
	{
		if (m_data[i].m_value > m_data[n].m_value)
		{
	   	MoveEntry tmp = m_data[n];
			m_data[n] = m_data[i];
			m_data[i] = tmp;
		}  	
	}

	return m_data[n].m_mv;
}
////////////////////////////////////////////////////////////////////////////////

void MoveList::GenAllMovesInCheck(const Position& pos)
{
	Clear();

	COLOR side = pos.Side();
	COLOR opp = side ^ 1;
	U64 freeOrOpp = ~pos.BitsAll(side);
	U64 occupied = pos.BitsAll();

	U64 x, y, pin;
	FLD from, to, f;
	PIECE piece, captured, p;
	FLD K = pos.King(side);

	U64 mask1 = LL(0xffffffffffffffff);
	U64 mask2 = LL(0xffffffffffffffff);
	y = pos.CheckInfo();
	while (y)
	{
		f = PopLSB(y);
		p = pos[f] & 0x0e;
		if (p == PAWNW || p == KNIGHTW || p == KINGW)
			mask1 &= BB_SINGLE[f];
		else
		{
			mask1 &= (BB_SINGLE[f] | BB_BETWEEN[f][K]);
			mask2 &= ~BB_BETWEEN[f][K];
			U8 dir = DIRS[f][K];
			mask2 &= ~BB_DIR[K][dir];
		}
	}

	int fwd = -8 + 16 * side;
	int second = 6 - 5 * side;
	int seventh = 1 + 5 * side;

	piece = PAWNW | side;
	x = pos.Bits(piece);
	while (x)
	{
		from = PopLSB(x);
		pin = GetPinMask(pos, from, K, occupied, opp) & mask1;
		int row = Row(from);

		to = from + fwd;
		if (!pos[to])
		{
			if (row == second)
			{
				if (BB_SINGLE[to] & pin)
					Add(from, to, piece);

				to += fwd;
				if (!pos[to] && (BB_SINGLE[to] & pin))
					Add(from, to, piece);
			}
			else if (row == seventh)
			{
				if (BB_SINGLE[to] & pin)
				{
					Add(from, to, piece, NOPIECE, QUEENW | side);
					Add(from, to, piece, NOPIECE, ROOKW | side);
					Add(from, to, piece, NOPIECE, BISHOPW | side);
					Add(from, to, piece, NOPIECE, KNIGHTW | side);
				}
			}
			else if (BB_SINGLE[to] & pin)
				Add(from, to, piece);
		}

		y = BB_PAWN_ATTACKS[from][side] & pos.BitsAll(opp) & pin;
		while (y)
		{
			to = PopLSB(y);
			captured = pos[to];

			if (row == seventh)
			{
				Add(from, to, piece, captured, QUEENW | side);
				Add(from, to, piece, captured, ROOKW | side);
				Add(from, to, piece, captured, BISHOPW | side);
				Add(from, to, piece, captured, KNIGHTW | side);				
			}
			else
				Add(from, to, piece, captured);
		}
	}

	to = pos.EP();
	if (to != NF)
	{
		FLD f1 = to + 8 - 16 * side;
		y = BB_PAWN_ATTACKS[to][opp] & pos.Bits(PAWNW | side);
		while (y)
		{
			from = PopLSB(y);
			if (pos.CheckInfo() == BB_SINGLE[f1])
			{
				pin = GetPinMask(pos, from, K, occupied ^ BB_SINGLE[f1], opp);
				if (BB_SINGLE[to] & pin)
					Add(from, to, piece, PAWNW | opp);
			}
		}
	}

	piece = KNIGHTW | side;
	x = pos.Bits(piece);
	while (x)
	{
		from = PopLSB(x);
		pin = GetPinMask(pos, from, K, occupied, opp) & mask1;
		y = BB_KNIGHT_ATTACKS[from] & freeOrOpp & pin;
		while (y)
		{
			to = PopLSB(y);
			captured = pos[to];
			Add(from, to, piece, captured);
		}
	}

	piece = BISHOPW | side;
	x = pos.Bits(piece);
	while (x)
	{
		from = PopLSB(x);
		pin = GetPinMask(pos, from, K, occupied, opp) & mask1;
		y = BishopAttacks(from, occupied) & freeOrOpp & pin;
		while (y)
		{
			to = PopLSB(y);
			captured = pos[to];
			Add(from, to, piece, captured);
		}
	}

	piece = ROOKW | side;
	x = pos.Bits(piece);
	while (x)
	{
		from = PopLSB(x);
		pin = GetPinMask(pos, from, K, occupied, opp) & mask1;
		y = RookAttacks(from, occupied) & freeOrOpp & pin;
		while (y)
		{
			to = PopLSB(y);
			captured = pos[to];
			Add(from, to, piece, captured);
		}
	}

	piece = QUEENW | side;
	x = pos.Bits(piece);
	while (x)
	{
		from = PopLSB(x);
		pin = GetPinMask(pos, from, K, occupied, opp) & mask1;
		y = QueenAttacks(from, occupied) & freeOrOpp & pin;
		while (y)
		{
			to = PopLSB(y);
			captured = pos[to];
			Add(from, to, piece, captured);
		}
	}

	piece = KINGW | side;
	x = pos.Bits(piece);
	while (x)
	{
		from = PopLSB(x);
		y = BB_KING_ATTACKS[from] & freeOrOpp & mask2;
		while (y)
		{
			to = PopLSB(y);
			if (!pos.IsAttacked(to, opp))
			{
				captured = pos[to];
				Add(from, to, piece, captured);
			}
		}
	}
}
////////////////////////////////////////////////////////////////////////////////

void MoveList::GenAllMoves(const Position& pos)
{
	if (pos.InCheck())
	{
		GenAllMovesInCheck(pos);
		return;
	}

	Clear();

	COLOR side = pos.Side();
	COLOR opp = side ^ 1;
	U64 freeOrOpp = ~pos.BitsAll(side);
	U64 occupied = pos.BitsAll();

	U64 x, y, pin;
	FLD from, to;
	PIECE piece, captured;
	FLD K = pos.King(side);

	int fwd = -8 + 16 * side;
	int second = 6 - 5 * side;
	int seventh = 1 + 5 * side;

	piece = PAWNW | side;
	x = pos.Bits(piece);
	while (x)
	{
		from = PopLSB(x);
		pin = GetPinMask(pos, from, K, occupied, opp);
		int row = Row(from);

		to = from + fwd;
		if (!pos[to])
		{
			if (row == second)
			{
				if (BB_SINGLE[to] & pin)
					Add(from, to, piece);

				to += fwd;
				if (!pos[to] && (BB_SINGLE[to] & pin))
					Add(from, to, piece);
			}
			else if (row == seventh)
			{
				if (BB_SINGLE[to] & pin)
				{
					Add(from, to, piece, NOPIECE, QUEENW | side);
					Add(from, to, piece, NOPIECE, ROOKW | side);
					Add(from, to, piece, NOPIECE, BISHOPW | side);
					Add(from, to, piece, NOPIECE, KNIGHTW | side);
				}
			}
			else if (BB_SINGLE[to] & pin)
				Add(from, to, piece);
		}

		y = BB_PAWN_ATTACKS[from][side] & pos.BitsAll(opp) & pin;
		while (y)
		{
			to = PopLSB(y);
			captured = pos[to];

			if (row == seventh)
			{
				Add(from, to, piece, captured, QUEENW | side);
				Add(from, to, piece, captured, ROOKW | side);
				Add(from, to, piece, captured, BISHOPW | side);
				Add(from, to, piece, captured, KNIGHTW | side);				
			}
			else
				Add(from, to, piece, captured);
		}
	}

	to = pos.EP();
	if (to != NF)
	{
		FLD f1 = to + 8 - 16 * side;
		y = BB_PAWN_ATTACKS[to][opp] & pos.Bits(PAWNW | side);
		while (y)
		{
			from = PopLSB(y);
			pin = GetPinMask(pos, from, K, occupied ^ BB_SINGLE[f1], opp);
			if (BB_SINGLE[to] & pin)
				Add(from, to, piece, PAWNW | opp);
		}
	}

	piece = KNIGHTW | side;
	x = pos.Bits(piece);
	while (x)
	{
		from = PopLSB(x);
		pin = GetPinMask(pos, from, K, occupied, opp);
		y = BB_KNIGHT_ATTACKS[from] & freeOrOpp & pin;
		while (y)
		{
			to = PopLSB(y);
			captured = pos[to];
			Add(from, to, piece, captured);
		}
	}

	piece = BISHOPW | side;
	x = pos.Bits(piece);
	while (x)
	{
		from = PopLSB(x);
		pin = GetPinMask(pos, from, K, occupied, opp);
		y = BishopAttacks(from, occupied) & freeOrOpp & pin;
		while (y)
		{
			to = PopLSB(y);
			captured = pos[to];
			Add(from, to, piece, captured);
		}
	}

	piece = ROOKW | side;
	x = pos.Bits(piece);
	while (x)
	{
		from = PopLSB(x);
		pin = GetPinMask(pos, from, K, occupied, opp);
		y = RookAttacks(from, occupied) & freeOrOpp & pin;
		while (y)
		{
			to = PopLSB(y);
			captured = pos[to];
			Add(from, to, piece, captured);
		}
	}

	piece = QUEENW | side;
	x = pos.Bits(piece);
	while (x)
	{
		from = PopLSB(x);
		pin = GetPinMask(pos, from, K, occupied, opp);
		y = QueenAttacks(from, occupied) & freeOrOpp & pin;
		while (y)
		{
			to = PopLSB(y);
			captured = pos[to];
			Add(from, to, piece, captured);
		}
	}

	piece = KINGW | side;
	x = pos.Bits(piece);
	while (x)
	{
		from = PopLSB(x);
		y = BB_KING_ATTACKS[from] & freeOrOpp;
		while (y)
		{
			to = PopLSB(y);
			if (!pos.IsAttacked(to, opp))
			{
				captured = pos[to];
				Add(from, to, piece, captured);
			}
		}

		if (from == E1 && side == WHITE)
		{
			if (!pos[F1] && !pos[G1] && (pos.Castlings() & WHITE_CAN_O_O))
				if (/* !pos.IsAttacked(E1, BLACK) && */ !pos.IsAttacked(F1, BLACK) && 
					!pos.IsAttacked(G1, BLACK))
					Add(E1, G1, KINGW);

			if (!pos[D1] && !pos[C1] && !pos[B1] 
					&& (pos.Castlings() & WHITE_CAN_O_O_O))
				if (/* !pos.IsAttacked(E1, BLACK) && */ !pos.IsAttacked(D1, BLACK) && 
					!pos.IsAttacked(C1, BLACK))
					Add(E1, C1, KINGW);
		}
		else if (from == E8 && side == BLACK)
		{
			if (!pos[F8] && !pos[G8] && (pos.Castlings() & BLACK_CAN_O_O))
				if (/* !pos.IsAttacked(E8, WHITE) && */ !pos.IsAttacked(F8, WHITE) && 
					!pos.IsAttacked(G8, WHITE))
					Add(E8, G8, KINGB);

			if (!pos[D8] && !pos[C8] && !pos[B8] 
					&& (pos.Castlings() & BLACK_CAN_O_O_O))
				if (/* !pos.IsAttacked(E8, WHITE) && */ !pos.IsAttacked(D8, WHITE) && 
					!pos.IsAttacked(C8, WHITE))
					Add(E8, C8, KINGB);
		}
	}
}
////////////////////////////////////////////////////////////////////////////////

void MoveList::GenCapturesAndPromotions(const Position& pos)
{
	if (pos.InCheck())
	{
		GenAllMovesInCheck(pos);
		return;
	}

	Clear();

	COLOR side = pos.Side();
	COLOR opp = side ^ 1;
	U64 targets = pos.BitsAll(opp);
	U64 occupied = pos.BitsAll();

	U64 x, y, pin;
	FLD from, to;
	PIECE piece, captured;
	FLD K = pos.King(side);

	int fwd = -8 + 16 * side;
	int seventh = 1 + 5 * side;

	piece = PAWNW | side;
	x = pos.Bits(piece);
	while (x)
	{
		from = PopLSB(x);
		pin = GetPinMask(pos, from, K, occupied, opp);
		int row = Row(from);

		to = from + fwd;
		if (!pos[to])
		{
			if (row == seventh)
			{
				if (BB_SINGLE[to] & pin)
				{
					Add(from, to, piece, NOPIECE, QUEENW | side);
					Add(from, to, piece, NOPIECE, ROOKW | side);
					Add(from, to, piece, NOPIECE, BISHOPW | side);
					Add(from, to, piece, NOPIECE, KNIGHTW | side);
				}
			}
		}

		y = BB_PAWN_ATTACKS[from][side] & pos.BitsAll(opp) & pin;
		while (y)
		{
			to = PopLSB(y);
			captured = pos[to];

			if (row == seventh)
			{
				Add(from, to, piece, captured, QUEENW | side);
				Add(from, to, piece, captured, ROOKW | side);
				Add(from, to, piece, captured, BISHOPW | side);
				Add(from, to, piece, captured, KNIGHTW | side);				
			}
			else
				Add(from, to, piece, captured);
		}
	}

	to = pos.EP();
	if (to != NF)
	{
		FLD f1 = to + 8 - 16 * side;
		y = BB_PAWN_ATTACKS[to][opp] & pos.Bits(PAWNW | side);
		while (y)
		{
			from = PopLSB(y);
			pin = GetPinMask(pos, from, K, occupied ^ BB_SINGLE[f1], opp);
			if (BB_SINGLE[to] & pin)
				Add(from, to, piece, PAWNW | opp);
		}
	}

	piece = KNIGHTW | side;
	x = pos.Bits(piece);
	while (x)
	{
		from = PopLSB(x);
		pin = GetPinMask(pos, from, K, occupied, opp);
		y = BB_KNIGHT_ATTACKS[from] & targets & pin;
		while (y)
		{
			to = PopLSB(y);
			captured = pos[to];
			Add(from, to, piece, captured);
		}
	}

	piece = BISHOPW | side;
	x = pos.Bits(piece);
	while (x)
	{
		from = PopLSB(x);
		pin = GetPinMask(pos, from, K, occupied, opp);
		y = BishopAttacks(from, occupied) & targets & pin;
		while (y)
		{
			to = PopLSB(y);
			captured = pos[to];
			Add(from, to, piece, captured);
		}
	}

	piece = ROOKW | side;
	x = pos.Bits(piece);
	while (x)
	{
		from = PopLSB(x);
		pin = GetPinMask(pos, from, K, occupied, opp);
		y = RookAttacks(from, occupied) & targets & pin;
		while (y)
		{
			to = PopLSB(y);
			captured = pos[to];
			Add(from, to, piece, captured);
		}
	}

	piece = QUEENW | side;
	x = pos.Bits(piece);
	while (x)
	{
		from = PopLSB(x);
		pin = GetPinMask(pos, from, K, occupied, opp);
		y = QueenAttacks(from, occupied) & targets & pin;
		while (y)
		{
			to = PopLSB(y);
			captured = pos[to];
			Add(from, to, piece, captured);
		}
	}

	piece = KINGW | side;
	x = pos.Bits(piece);
	while (x)
	{
		from = PopLSB(x);
		y = BB_KING_ATTACKS[from] & targets;
		while (y)
		{
			to = PopLSB(y);
			if (!pos.IsAttacked(to, opp))
			{
				captured = pos[to];
				Add(from, to, piece, captured);
			}
		}
	}
}
////////////////////////////////////////////////////////////////////////////////

void MoveList::UpdateScores(const Position& pos, Move hashmv, Move killermv)
{
	for (int i = 0; i < m_size; ++i)
	{
		Move mv = m_data[i].m_mv;
		if (mv == hashmv)
		{
			m_data[i].m_value = 50000;
			continue;
		}

		PIECE piece = mv.Piece();
		PIECE captured = mv.Captured();
		PIECE promotion = mv.Promotion();
		FLD to = mv.To();

		m_data[i].m_value = 0;

		if (captured || promotion)
		{
			m_data[i].m_value = 40000 + SEE(pos, mv);

//			m_data[i].m_value = 40000 + 20 * VALUE[captured] - VALUE[piece];
//			if (promotion)
//				m_data[i].m_value += VALUE[promotion];
		}
		else
		{
			if (mv == killermv)
				m_data[i].m_value = 20000;
			else
				m_data[i].m_value += g_history[piece][to];
		}
	}
}
////////////////////////////////////////////////////////////////////////////////

