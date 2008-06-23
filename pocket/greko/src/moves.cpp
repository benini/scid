
#include <string.h>
#include "moves.h"
#include "position.h"
#include "utils.h"

SMove* g_moves[MAX_PLY + 2];
int g_moves_cnt[MAX_PLY + 2];

inline void insert_move(FLD from, FLD to, PIECE piece, PIECE captured, PIECE promotion, int ply)
{
	g_moves[ply][g_moves_cnt[ply]++].mv = mv_compose(from, to, piece, captured, promotion);
}
////////////////////////////////////////////////////////////////////////////////

void gen_captures_and_promotions(const Position* pos, int ply)
{
	int from = NF, to = NF;
	PIECE piece = NOPIECE, captured = NOPIECE;
	U64 x = 0, y = 0;
	U64 free = pos->bits[NOPIECE];

	U64 blockers = ~pos->bits[NOPIECE];
	U64 targets = pos->bits_all[pos->opp];

	g_moves_cnt[ply] = 0;

	if (pos->side == WHITE)
	{
		piece = PAWNW;
		U64 pawns = pos->bits[PAWNW];
		
		//
		//   non-promotions
		//

		x = pawns & bb_down(bb_left(targets)) & ~BB_A7H7;
		while ((from = pop_lsb(x)) != NF)
		{
			to = from - 7;
			captured = pos->board[to];
			insert_move(from, to, piece, captured, NOPIECE, ply);
		}

		x = pawns & bb_down(bb_right(targets)) & ~BB_A7H7;
		while ((from = pop_lsb(x)) != NF)
		{
			to = from - 9;
			captured = pos->board[to];
			insert_move(from, to, piece, captured, NOPIECE, ply);
		}

		//
		//   promotions
		//

		x = pawns & bb_down(free) & BB_A7H7;
		while ((from = pop_lsb(x)) != NF)
		{
			to = from - 8;
			insert_move(from, to, piece, NOPIECE, QUEENW, ply);
			insert_move(from, to, piece, NOPIECE, ROOKW, ply);
			insert_move(from, to, piece, NOPIECE, BISHOPW, ply);
			insert_move(from, to, piece, NOPIECE, KNIGHTW, ply);
		}

		x = pawns & bb_down(bb_left(targets)) & BB_A7H7;
		while ((from = pop_lsb(x)) != NF)
		{
			to = from - 7;
			captured = pos->board[to];
			insert_move(from, to, piece, captured, QUEENW, ply);
			insert_move(from, to, piece, captured, ROOKW, ply);
			insert_move(from, to, piece, captured, BISHOPW, ply);
			insert_move(from, to, piece, captured, KNIGHTW, ply);
		}

		x = pawns & bb_down(bb_right(targets)) & BB_A7H7;
		while ((from = pop_lsb(x)) != NF)
		{
			to = from - 9;
			captured = pos->board[to];
			insert_move(from, to, piece, captured, QUEENW, ply);
			insert_move(from, to, piece, captured, ROOKW, ply);
			insert_move(from, to, piece, captured, BISHOPW, ply);
			insert_move(from, to, piece, captured, KNIGHTW, ply);
		}

		//
		//   en-passant
		//

		to = pos->ep;
		if (to != NF)
		{
			from = steps[5][to];
			if (from != NF && pos->board[from] == PAWNW)
				insert_move(from, to, PAWNW, PAWNB, NOPIECE, ply);

			from = steps[7][to];
			if (from != NF && pos->board[from] == PAWNW)
				insert_move(from, to, PAWNW, PAWNB, NOPIECE, ply);
		}
	}
	else
	{
		piece = PAWNB;
		U64 pawns = pos->bits[PAWNB];
		
		//
		//   non-promotions
		//

		x = pawns & bb_up(bb_left(targets)) & ~BB_A2H2;
		while ((from = pop_lsb(x)) != NF)
		{
			to = from + 9;
			captured = pos->board[to];
			insert_move(from, to, piece, captured, NOPIECE, ply);
		}

		x = pawns & bb_up(bb_right(targets)) & ~BB_A2H2;
		while ((from = pop_lsb(x)) != NF)
		{
			to = from + 7;
			captured = pos->board[to];
			insert_move(from, to, piece, captured, NOPIECE, ply);
		}

		//
		//   promotions
		//

		x = pawns & bb_up(free) & BB_A2H2;
		while ((from = pop_lsb(x)) != NF)
		{
			to = from + 8;
			insert_move(from, to, piece, NOPIECE, QUEENB, ply);
			insert_move(from, to, piece, NOPIECE, ROOKB, ply);
			insert_move(from, to, piece, NOPIECE, BISHOPB, ply);
			insert_move(from, to, piece, NOPIECE, KNIGHTB, ply);
		}

		x = pawns & bb_up(bb_left(targets)) & BB_A2H2;
		while ((from = pop_lsb(x)) != NF)
		{
			to = from + 9;
			captured = pos->board[to];
			insert_move(from, to, piece, captured, QUEENB, ply);
			insert_move(from, to, piece, captured, ROOKB, ply);
			insert_move(from, to, piece, captured, BISHOPB, ply);
			insert_move(from, to, piece, captured, KNIGHTB, ply);
		}

		x = pawns & bb_up(bb_right(targets)) & BB_A2H2;
		while ((from = pop_lsb(x)) != NF)
		{
			to = from + 7;
			captured = pos->board[to];
			insert_move(from, to, piece, captured, QUEENB, ply);
			insert_move(from, to, piece, captured, ROOKB, ply);
			insert_move(from, to, piece, captured, BISHOPB, ply);
			insert_move(from, to, piece, captured, KNIGHTB, ply);
		}

		//
		//   en-passant
		//

		to = pos->ep;
		if (to != NF)
		{
			from = steps[1][to];
			if (from != NF && pos->board[from] == PAWNB)
				insert_move(from, to, PAWNB, PAWNW, NOPIECE, ply);

			from = steps[3][to];
			if (from != NF && pos->board[from] == PAWNB)
				insert_move(from, to, PAWNB, PAWNW, NOPIECE, ply);
		}
	}

	piece = KNIGHTW | pos->side;
	x = pos->bits[piece];
	while ((from = pop_lsb(x)) != NF)
	{
		y = BB_KNIGHT_ATTACKS[from] & targets;
		while ((to = pop_lsb(y)) != NF)
		{
			captured = pos->board[to];
			insert_move(from, to, piece, captured, NOPIECE, ply);
		}
	}

	piece = BISHOPW | pos->side;
	x = pos->bits[piece];
	while ((from = pop_lsb(x)) != NF)
	{
		y = BB_BISHOP_ATTACKS[from] & targets;
		while ((to = pop_lsb(y)) != NF)
		{
			if ((blockers & BB_BETWEEN[from][to]) == 0)
			{
				captured = pos->board[to];
				insert_move(from, to, piece, captured, NOPIECE, ply);
			}
		}
	}

	piece = ROOKW | pos->side;
	x = pos->bits[piece];
	while ((from = pop_lsb(x)) != NF)
	{
		y = BB_ROOK_ATTACKS[from] & targets;
		while ((to = pop_lsb(y)) != NF)
		{
			if ((blockers & BB_BETWEEN[from][to]) == 0)
			{
				captured = pos->board[to];
				insert_move(from, to, piece, captured, NOPIECE, ply);
			}
		}
	}

	piece = QUEENW | pos->side;
	x = pos->bits[piece];
	while ((from = pop_lsb(x)) != NF)
	{
		y = BB_QUEEN_ATTACKS[from] & targets;
		while ((to = pop_lsb(y)) != NF)
		{
			if ((blockers & BB_BETWEEN[from][to]) == 0)
			{
				captured = pos->board[to];
				insert_move(from, to, piece, captured, NOPIECE, ply);
			}
		}
	}

	piece = KINGW | pos->side;
	from = pos->King[pos->side];
	y = BB_KING_ATTACKS[from] & targets;
	while ((to = pop_lsb(y)) != NF)
	{
		captured = pos->board[to];
		insert_move(from, to, piece, captured, NOPIECE, ply);
	}
}
////////////////////////////////////////////////////////////////////////////////

void gen_moves(const Position* pos, int ply)
{
	FLD from = NF, to = NF;
	PIECE piece = NOPIECE, captured = NOPIECE;
	U64 x = 0, y = 0;
	U64 free = pos->bits[NOPIECE];

	g_moves_cnt[ply] = 0;

	if (pos->side == WHITE)
	{
		piece = PAWNW;
		U64 pawns = pos->bits[PAWNW];
		U64 targets = pos->bits_all[BLACK];

		x = pawns & bb_down(free) & bb_down(bb_down(free)) & BB_A2H2;
		while ((from = pop_lsb(x)) != NF)
		{
			to = from - 16;
			insert_move(from, to, PAWNW, NOPIECE, NOPIECE, ply);
		}

		//
		//   non-promotions
		//

		x = pawns & bb_down(free) & ~BB_A7H7;
		while ((from = pop_lsb(x)) != NF)
		{
			to = from - 8;
			insert_move(from, to, piece, NOPIECE, NOPIECE, ply);
		}

		x = pawns & bb_down(bb_left(targets)) & ~BB_A7H7;
		while ((from = pop_lsb(x)) != NF)
		{
			to = from - 7;
			captured = pos->board[to];
			insert_move(from, to, piece, captured, NOPIECE, ply);
		}

		x = pawns & bb_down(bb_right(targets)) & ~BB_A7H7;
		while ((from = pop_lsb(x)) != NF)
		{
			to = from - 9;
			captured = pos->board[to];
			insert_move(from, to, piece, captured, NOPIECE, ply);
		}

		//
		//   promotions
		//

		x = pawns & bb_down(free) & BB_A7H7;
		while ((from = pop_lsb(x)) != NF)
		{
			to = from - 8;
			insert_move(from, to, piece, NOPIECE, QUEENW, ply);
			insert_move(from, to, piece, NOPIECE, ROOKW, ply);
			insert_move(from, to, piece, NOPIECE, BISHOPW, ply);
			insert_move(from, to, piece, NOPIECE, KNIGHTW, ply);
		}

		x = pawns & bb_down(bb_left(targets)) & BB_A7H7;
		while ((from = pop_lsb(x)) != NF)
		{
			to = from - 7;
			captured = pos->board[to];
			insert_move(from, to, piece, captured, QUEENW, ply);
			insert_move(from, to, piece, captured, ROOKW, ply);
			insert_move(from, to, piece, captured, BISHOPW, ply);
			insert_move(from, to, piece, captured, KNIGHTW, ply);
		}

		x = pawns & bb_down(bb_right(targets)) & BB_A7H7;
		while ((from = pop_lsb(x)) != NF)
		{
			to = from - 9;
			captured = pos->board[to];
			insert_move(from, to, piece, captured, QUEENW, ply);
			insert_move(from, to, piece, captured, ROOKW, ply);
			insert_move(from, to, piece, captured, BISHOPW, ply);
			insert_move(from, to, piece, captured, KNIGHTW, ply);
		}

		//
		//   en-passant
		//

		to = pos->ep;
		if (to != NF)
		{
			from = steps[5][to];
			if (from != NF && pos->board[from] == PAWNW)
				insert_move(from, to, PAWNW, PAWNB, NOPIECE, ply);

			from = steps[7][to];
			if (from != NF && pos->board[from] == PAWNW)
				insert_move(from, to, PAWNW, PAWNB, NOPIECE, ply);
		}
	}
	else
	{
		piece = PAWNB;
		U64 pawns = pos->bits[PAWNB];
		U64 targets = pos->bits_all[WHITE];
		
		x = pawns & bb_up(free) & bb_up(bb_up(free)) & BB_A7H7;
		while ((from = pop_lsb(x)) != NF)
		{
			to = from + 16;
			insert_move(from, to, piece, NOPIECE, NOPIECE, ply);
		}

		//
		//   non-promotions
		//

		x = pawns & bb_up(free) & ~BB_A2H2;
		while ((from = pop_lsb(x)) != NF)
		{
			to = from + 8;
			insert_move(from, to, piece, NOPIECE, NOPIECE, ply);
		}

		x = pawns & bb_up(bb_left(targets)) & ~BB_A2H2;
		while ((from = pop_lsb(x)) != NF)
		{
			to = from + 9;
			captured = pos->board[to];
			insert_move(from, to, piece, captured, NOPIECE, ply);
		}

		x = pawns & bb_up(bb_right(targets)) & ~BB_A2H2;
		while ((from = pop_lsb(x)) != NF)
		{
			to = from + 7;
			captured = pos->board[to];
			insert_move(from, to, piece, captured, NOPIECE, ply);
		}

		//
		//   promotions
		//

		x = pawns & bb_up(free) & BB_A2H2;
		while ((from = pop_lsb(x)) != NF)
		{
			to = from + 8;
			insert_move(from, to, piece, NOPIECE, QUEENB, ply);
			insert_move(from, to, piece, NOPIECE, ROOKB, ply);
			insert_move(from, to, piece, NOPIECE, BISHOPB, ply);
			insert_move(from, to, piece, NOPIECE, KNIGHTB, ply);
		}

		x = pawns & bb_up(bb_left(targets)) & BB_A2H2;
		while ((from = pop_lsb(x)) != NF)
		{
			to = from + 9;
			captured = pos->board[to];
			insert_move(from, to, piece, captured, QUEENB, ply);
			insert_move(from, to, piece, captured, ROOKB, ply);
			insert_move(from, to, piece, captured, BISHOPB, ply);
			insert_move(from, to, piece, captured, KNIGHTB, ply);
		}

		x = pawns & bb_up(bb_right(targets)) & BB_A2H2;
		while ((from = pop_lsb(x)) != NF)
		{
			to = from + 7;
			captured = pos->board[to];
			insert_move(from, to, piece, captured, QUEENB, ply);
			insert_move(from, to, piece, captured, ROOKB, ply);
			insert_move(from, to, piece, captured, BISHOPB, ply);
			insert_move(from, to, piece, captured, KNIGHTB, ply);
		}

		//
		//   en-passant
		//

		to = pos->ep;
		if (to != NF)
		{
			from = steps[1][to];
			if (from != NF && pos->board[from] == PAWNB)
				insert_move(from, to, PAWNB, PAWNW, NOPIECE, ply);

			from = steps[3][to];
			if (from != NF && pos->board[from] == PAWNB)
				insert_move(from, to, PAWNB, PAWNW, NOPIECE, ply);
		}
	}

	piece = KNIGHTW | pos->side;
	x = pos->bits[piece];
	while ((from = pop_lsb(x)) != NF)
	{
		y = BB_KNIGHT_ATTACKS[from] & ~pos->bits_all[pos->side];
		while ((to = pop_lsb(y)) != NF)
		{
			captured = pos->board[to];
			if (!captured || getcolor(captured) == pos->opp)
				insert_move(from, to, piece, captured, NOPIECE, ply);
		}
	}

#define TRACE_RAY(step_array)                               \
   to = step_array[from];                                   \
   while (to != NF)                                         \
   {                                                        \
      captured = pos->board[to];                            \
      if (captured && getcolor(captured) == pos->side)      \
         break;                                             \
      insert_move(from, to, piece, captured, NOPIECE, ply); \
      if (captured)                                         \
         break;                                             \
      to = step_array[to];                                  \
   }

	piece = BISHOPW | pos->side;
	x = pos->bits[piece];
	while ((from = pop_lsb(x)) != NF)
	{
		TRACE_RAY(steps[1]);
		TRACE_RAY(steps[3]);
		TRACE_RAY(steps[5]);
		TRACE_RAY(steps[7]);
	}

	piece = ROOKW | pos->side;
	x = pos->bits[piece];
	while ((from = pop_lsb(x)) != NF)
	{
		TRACE_RAY(steps[0]);
		TRACE_RAY(steps[2]);
		TRACE_RAY(steps[4]);
		TRACE_RAY(steps[6]);
	}

	piece = QUEENW | pos->side;
	x = pos->bits[piece];
	while ((from = pop_lsb(x)) != NF)
	{
		TRACE_RAY(steps[0]);
		TRACE_RAY(steps[2]);
		TRACE_RAY(steps[4]);
		TRACE_RAY(steps[6]);

		TRACE_RAY(steps[1]);
		TRACE_RAY(steps[3]);
		TRACE_RAY(steps[5]);
		TRACE_RAY(steps[7]);
	}

	piece = KINGW | pos->side;
	from = pos->King[pos->side];
	y = BB_KING_ATTACKS[from] & ~pos->bits_all[pos->side];
	while ((to = pop_lsb(y)) != NF)
	{
		captured = pos->board[to];
		if (!captured || getcolor(captured) == pos->opp)
			insert_move(from, to, piece, captured, NOPIECE, ply);
	}

	//
	//   castlings
	//

	if (pos->side == WHITE)
	{
		if ((pos->castlings & WHITE_CAN_O_O) &&
		    !pos->board[F1] && !pos->board[G1])
		{
			insert_move(E1, G1, KINGW, NOPIECE, NOPIECE, ply);
		}

		if ((pos->castlings & WHITE_CAN_O_O_O) &&
		    !pos->board[D1] && !pos->board[C1] && !pos->board[B1])
		{
			insert_move(E1, C1, KINGW, NOPIECE, NOPIECE, ply);
		}
	}
	else
	{
		if ((pos->castlings & BLACK_CAN_O_O) &&
		    !pos->board[F8] && !pos->board[G8])
		{
			insert_move(E8, G8, KINGB, NOPIECE, NOPIECE, ply);
		}

		if ((pos->castlings & BLACK_CAN_O_O_O) &&
		    !pos->board[D8] && !pos->board[C8] && !pos->board[B8])
		{
			insert_move(E8, C8, KINGB, NOPIECE, NOPIECE, ply);
		}
	}
}
////////////////////////////////////////////////////////////////////////////////

void init_mg()
{
	//
	//   Initialize move generator pool
	//

	for (int i = 0; i < MAX_PLY + 2; i++)
	{
		g_moves[i] = (SMove*) safe_malloc(MAX_BRANCH * sizeof(SMove));
		g_moves_cnt[i] = 0;
	}
}
////////////////////////////////////////////////////////////////////////////////

char* move_to_str(Move mv, char* buf)
{
	//
	//   Convert move data to algebraic notation
	//

	strcpy(buf, fld_to_str(mv_from(mv)));
	strcat(buf, fld_to_str(mv_to(mv)));

	switch (mv_promotion(mv))
	{
	case QUEENW:
	case QUEENB:
		strcat(buf, "q");
		break;

	case ROOKW:
	case ROOKB:
		strcat(buf, "r");
		break;

	case BISHOPW:
	case BISHOPB:
		strcat(buf, "b");
		break;

	case KNIGHTW:
	case KNIGHTB:
		strcat(buf, "n");
		break;

	default:
		break;
	}

	return buf;
}
////////////////////////////////////////////////////////////////////////////////

char* move_to_str_san(const Position* pos, Move mv, char* buf)
{
	PIECE piece = mv_piece(mv);
	FLD from = mv_from(mv);
	FLD to = mv_to(mv);
	PIECE captured = mv_captured(mv);
	PIECE promotion = mv_promotion(mv);

	strcpy(buf, "");

	if ((piece == PAWNW || piece == PAWNB))
	{
		if (captured)
		{
			strcpy(buf, fld_to_str(from));
			buf[1] = 'x';
			buf[2] = 0;
		}

		strcat(buf, fld_to_str(to));

		switch	(promotion)
		{
		case QUEENW:
		case QUEENB:
			strcat(buf, "=Q");
			break;
		case ROOKW:
		case ROOKB:
			strcat(buf, "=R");
			break;
		case BISHOPW:
		case BISHOPB:
			strcat(buf, "=B");
			break;
		case KNIGHTW:
		case KNIGHTB:
			strcat(buf, "=N");
			break;
		default:
			break;
		}

		return buf;
	}
	else if (piece == KINGW && from == E1 && to == G1)
	{
		strcpy(buf, "O-O");
		return buf;
	}
	else if (piece == KINGB && from == E8 && to == G8)
	{
		strcpy(buf, "O-O");
		return buf;
	}
	else if (piece == KINGW && from == E1 && to == C1)
	{
		strcpy(buf, "O-O-O");
		return buf;
	}
	else if (piece == KINGB && from == E8 && to == C8)
	{
		strcpy(buf, "O-O-O");
		return buf;
	}

	switch (piece)
	{
	case KNIGHTW:
	case KNIGHTB:
		strcat(buf, "N");
		break;
	case BISHOPW:
	case BISHOPB:
		strcat(buf, "B");
		break;
	case ROOKW:
	case ROOKB:
		strcat(buf, "R");
		break;
	case QUEENW:
	case QUEENB:
		strcat(buf, "Q");
		break;
	case KINGW:
	case KINGB:
		strcat(buf, "K");
		break;
	default:
		return move_to_str(mv, buf);
	}

	U64 x = get_attacks(pos, to, getcolor(piece)) & ~BB_SINGLE[from];
	if (x)
	{
		// resolve ambiguity

		Position* tmp = new_pos();
		copy_pos(tmp, pos);

		gen_moves(tmp, MAX_PLY + 1);
		
		int uniq_col = 1;
		int uniq_row = 1;
		int ambiguity = 0;

		int row0 = getrow(from);
		int col0 = getcol(from);

		for (int i = 0; i < g_moves_cnt[MAX_PLY + 1]; i++)
		{
			Move mvi = g_moves[MAX_PLY + 1][i].mv;

			if (!make_move(tmp, (mvi)))
				continue;

			unmake_move(tmp);

			if (mv_to(mvi) != to)
				continue;

			if (pos->board[mv_from(mvi)] != piece)
				continue;

			if (mv_from(mvi) == from)
				continue;

			ambiguity = 1; // two or more pieces of the same type can move to field

			int row1 = getrow(mv_from(mvi));
			int col1 = getcol(mv_from(mvi));

			if (row0 == row1)
				uniq_row = 0;

			if (col0 == col1)
				uniq_col = 0;
		}

		if (ambiguity)
		{
			char from_info[16];
			strcpy(from_info, fld_to_str(from));

			if (uniq_col)
				from_info[1] = 0;
			else if(uniq_row)
			{
				from_info[0] = from_info[1];
				from_info[1] = 0;
			}

			strcat(buf, from_info);
		}

		free_pos(tmp);
	}

	if (captured)
		strcat(buf, "x");

	strcat(buf, fld_to_str(to));
	return buf;
}
////////////////////////////////////////////////////////////////////////////////

