#include "eval.h"
#include "position.h"
#include "search.h"

#define  MAT_WEIGHT  (256)
#define  KSF_WEIGHT  (256)
#define  PAS_WEIGHT  (256)
#define  PSQ_WEIGHT  (256)
#define  MOB_WEIGHT  (256)
#define  PWN_WEIGHT  (256)

#define LAZY_MARGIN                 (VAL_BISHOP)

#define KING_LOST_O_O               (20)
#define KING_LOST_O_O_O             (10)

#define QUEEN_K_TROPISM             (5)
#define ROOK_K_TROPISM              (5)
#define BISHOP_K_TROPISM            (3)
#define KNIGHT_K_TROPISM            (3)

#define QUEEN_ON_7TH                (5)
#define QUEEN_EARLY_MOVE            (10)

#define ROOK_ON_7TH                 (20)
#define ROOK_ON_OPEN                (15)
#define ROOK_ON_SEMIOPEN            (10)
#define ROOK_H_MOBILITY             (1)
#define ROOK_V_MOBILITY             (2)
#define ROOK_TRAPPED                (25)

#define BISHOP_MOBILITY             (3)

#define BISHOP_ON_STRONG            (4)
#define BISHOP_BLOCKING_WEAK_PAWN   (8)
#define BISHOP_TRAPPED              (75)

#define KNIGHT_ON_STRONG            (5)
#define KNIGHT_BLOCKING_WEAK_PAWN   (10)

#define PAWN_SHIELD_OWN_3RD         (10)
#define PAWN_SHIELD_OWN_4TH         (20)
#define PAWN_SHIELD_OWN_NOPAWN      (25)

#define PAWN_SHIELD_OPP_NOPAWN      (15)
#define PAWN_SHIELD_OPP_3RD         (10)
#define PAWN_SHIELD_OPP_4TH         (5)

#define PAWN_SHIELD_OPEN_CENTER     (15)
#define PAWN_SHIELD_SEMIOPEN_CENTER (10)

#define PAWN_PASSED_UNCATCHABLE     (50)
#define PAWN_PASSED_KING_DISTANCE   (10)
#define PAWN_PASSED_STOPPED_BY_KING (20)
#define PAWN_PASSED_FAR_PAIR        (150)
#define PAWN_PASSED_SUPPORTED_KING  (12)

#define PAWN_DOUBLED                (12)
#define PAWN_BLOCKED_BY_OWN_PIECE   (10)
#define PAWN_WEAK                   (5)
#define PAWN_FREE_IN_CENTER         (5)
#define PAWN_DUO_IN_CENTER          (5)

static const FLD FLIP[64] =
{
	A1, B1, C1, D1, E1, F1, G1, H1,
	A2, B2, C2, D2, E2, F2, G2, H2,
	A3, B3, C3, D3, E3, F3, G3, H3,
	A4, B4, C4, D4, E4, F4, G4, H4,
	A5, B5, C5, D5, E5, F5, G5, H5,
	A6, B6, C6, D6, E6, F6, G6, H6,
	A7, B7, C7, D7, E7, F7, G7, H7,
	A8, B8, C8, D8, E8, F8, G8, H8
};

EVAL PSQ_KING[64] =
{
	-40, -40, -40, -40, -40, -40, -40, -40,
	-40, -40, -40, -40, -40, -40, -40, -40,
	-40, -40, -40, -40, -40, -40, -40, -40,
	-40, -40, -40, -40, -40, -40, -40, -40,
	-40, -40, -40, -40, -40, -40, -40, -40,
	-40, -40, -40, -40, -40, -40, -40, -40,
	-20, -20, -20, -20, -20, -20, -20, -20,
	 10,  30,  30, -20, -20, -20,  30,  10
};

EVAL PSQ_KING_ENDGAME[64] =
{
	-30, -20, -10,   0,   0, -10, -20, -30,
	-20, -10,   0,  10,  10,   0, -10, -20,
	-10,   0,  10,  20,  20,  10,   0, -10,
	  0,  10,  20,  30,  30,  20,  10,   0,
	  0,  10,  20,  30,  30,  20,  10,   0,
	-10,   0,  10,  20,  20,  10,   0, -10,
	-20, -10,   0,  10,  10,   0, -10, -20,
	-30, -20, -10,   0,   0, -10, -20, -30
};

EVAL PSQ_BISHOP[64] =
{
	 -9,  -6,  -3,   0,   0,  -3,  -6,  -9,
	 -6,  -3,   0,   3,   3,   0,  -3,  -6,
	 -3,   0,   3,   6,   6,   3,   0,  -3,
	  0,   3,   6,   9,   9,   6,   3,   0,
	  0,   3,   6,   9,   9,   6,   3,   0,
	 -3,   0,   3,   6,   6,   3,   0,  -3,
	 -6,  -3,   0,   3,   3,   0,  -3,  -6,
	 -9,  -6,  -3,   0,   0,  -3,  -6,  -9,
};

EVAL PSQ_KNIGHT[64] =
{
	-12,  -8,  -4,   0,   0,  -4,  -8, -12,
	 -8,  -4,   0,   4,   4,   0,  -4,  -8,
	 -4,   0,   4,   8,   8,   4,   0,  -4,
	  0,   4,   8,  12,  12,   8,   4,   0,
	  0,   4,   8,  12,  12,   8,   4,   0,
	 -4,   0,   4,   8,   8,   4,   0,  -4,
	 -8,  -4,   0,   4,   4,   0,  -4,  -8,
	-12,  -8,  -4,   0,   0,  -4,  -8, -12
};

EVAL PSQ_PAWN[64] =
{
	  0,   0,   0,   0,   0,   0,   0,   0,
	  0,   0,   0,   0,   0,   0,   0,   0,
	  0,   0,   2,   2,   2,   2,   0,   0,
	  0,   2,   4,   6,   6,   4,   2,   0,
	  0,   2,   6,   8,   8,   6,   2,   0,
	  0,   2,   6,   6,   6,   6,   2,   0,
	  0,   2,   2,   2,   2,   2,   2,   0,
	  0,   0,   0,   0,   0,   0,   0,   0
};


EVAL PAWN_PASSED_MIDGAME[64] =
{
	  0,   0,   0,   0,   0,   0,   0,   0,
	 60,  60,  60,  60,  60,  60,  60,  60,
	 50,  50,  50,  50,  50,  50,  50,  50,
	 40,  40,  40,  40,  40,  40,  40,  40,
	 30,  30,  30,  30,  30,  30,  30,  30,
	 20,  20,  20,  20,  20,  20,  20,  20,
	 10,  10,  10,  10,  10,  10,  10,  10,
	  0,   0,   0,   0,   0,   0,   0,   0
};

EVAL PAWN_PASSED_ENDGAME[64] =
{
	  0,   0,   0,   0,   0,   0,   0,   0,
	120, 120, 120, 120, 120, 120, 120, 120,
	100, 100, 100, 100, 100, 100, 100, 100,
	 80,  80,  80,  80,  80,  80,  80,  80,
	 60,  60,  60,  60,  60,  60,  60,  60,
	 40,  40,  40,  40,  40,  40,  40,  40,
	 20,  20,  20,  20,  20,  20,  20,  20,
	  0,   0,   0,   0,   0,   0,   0,   0
};

EVAL eval_pawn_shield_w(const PawnHashEntry* pentry, FLD  K);
EVAL eval_pawn_shield_b(const PawnHashEntry* pentry, FLD  K);
void read_pawn_structure(const Position& pos, PawnHashEntry* pentry);

EVAL evaluate(const Position& pos, EVAL alpha, EVAL beta)
{
	U64 x = 0, y = 0;
	FLD f = NF, to = NF;

	if (pos.IsDraw())
		return DRAW_SCORE;

	EVAL mat_score = pos.Material(WHITE) - pos.Material(BLACK);
	if (pos.Count(BISHOPW) == 2)
		mat_score += BISHOP_PAIR;
	if (pos.Count(BISHOPB) == 2)
		mat_score -= BISHOP_PAIR;

	EVAL ksf_score = 0;
	EVAL pas_score = 0;
	EVAL psq_score = 0;
	EVAL mob_score = 0;
	EVAL pwn_score = 0;

	//
	//   LAZY EVAL
	//

	EVAL e = mat_score * MAT_WEIGHT / 256;
	if (pos.Side() == BLACK)
		e = - e;

	if (e > beta + LAZY_MARGIN)
		return beta;

	if (e < alpha - LAZY_MARGIN)
		return alpha;

	//
	//   MATERIAL COEFFICIENTS
	//

	int mat_coeff[2] = 
	{
		10 * pos.Count(QUEENW) + 
		 5 * pos.Count(ROOKW) + 
		 3 * (pos.Count(BISHOPW) + pos.Count(KNIGHTW)),

		10 * pos.Count(QUEENB) + 
		 5 * pos.Count(ROOKB) + 
		 3 * (pos.Count(BISHOPB) + pos.Count(KNIGHTB))
	};

	if (mat_coeff[WHITE] > 32)
		mat_coeff[WHITE] = 32;

	if (mat_coeff[BLACK] > 32)
		mat_coeff[BLACK] = 32;

	EVAL king_safety[2] = {0, 0};

	U32 ph = pos.PawnHash();
	long index = ph % g_pawn_hash_size;
	PawnHashEntry* pentry = & (g_pawn_hash[index]);

	if (pentry->pawn_hash != ph)
		read_pawn_structure(pos, pentry);

	//
	//   KING SAFETY AND CENTRALIZATION IN ENDGAME
	//

	if (mat_coeff[BLACK] >= 10)
	{
		king_safety[WHITE] += PSQ_KING[pos.King(WHITE)];
		king_safety[WHITE] += eval_pawn_shield_w(pentry, pos.King(WHITE));

		if ((pos.Castlings() & (WHITE_DID_O_O | WHITE_DID_O_O_O)) == 0)
		{
			if ((pos.Castlings() & WHITE_CAN_O_O) == 0)
				king_safety[WHITE] -= KING_LOST_O_O;
			if ((pos.Castlings() & WHITE_CAN_O_O_O) == 0)
				king_safety[WHITE] -= KING_LOST_O_O_O;
		}
	}
	else
		psq_score += PSQ_KING_ENDGAME[pos.King(WHITE)];

	if (mat_coeff[WHITE] >= 10)
	{
		king_safety[BLACK] += PSQ_KING[FLIP[pos.King(BLACK)]];
		king_safety[BLACK] += eval_pawn_shield_b(pentry, pos.King(BLACK));

		if ((pos.Castlings() & (BLACK_DID_O_O | BLACK_DID_O_O_O)) == 0)
		{
			if ((pos.Castlings() & BLACK_CAN_O_O) == 0)
				king_safety[BLACK] -= KING_LOST_O_O;
			if ((pos.Castlings() & BLACK_CAN_O_O_O) == 0)
				king_safety[BLACK] -= KING_LOST_O_O_O;
		}
	}
	else
		psq_score -= PSQ_KING_ENDGAME[FLIP[pos.King(BLACK)]];

	//
	//   PAWNS
	//

	pwn_score = pentry->score;

	// blocked

	y = bb_up(pos.Bits(PAWNW)) & (pos.Bits(KNIGHTW) | pos.Bits(BISHOPW) | pos.Bits(ROOKW) | pos.Bits(QUEENW));
	pwn_score -= PAWN_BLOCKED_BY_OWN_PIECE * CountBits(y);

	y = bb_down(pos.Bits(PAWNB)) & (pos.Bits(KNIGHTB) | pos.Bits(BISHOPB) | pos.Bits(ROOKB) | pos.Bits(QUEENB));
	pwn_score += PAWN_BLOCKED_BY_OWN_PIECE * CountBits(y);

	// free

	U64 free = ~pos.BitsAll();

	y = BB_CENTER_W & pos.Bits(PAWNW) & bb_down(free);
	pwn_score += PAWN_FREE_IN_CENTER * CountBits(y);

	y = BB_CENTER_B & pos.Bits(PAWNB) & bb_up(free);
	pwn_score -= PAWN_FREE_IN_CENTER * CountBits(y);

	// duo

	y = BB_CENTER_W & pos.Bits(PAWNW);
	y &= bb_right(y);
	pwn_score += PAWN_DUO_IN_CENTER * CountBits(y);

	y = BB_CENTER_B & pos.Bits(PAWNB);
	y &= bb_right(y);
	pwn_score -= PAWN_DUO_IN_CENTER * CountBits(y);

	// passed pawns

	x = pentry->passed & pos.Bits(PAWNW);
	while (x)
	{
		f = PopLSB(x);
		EVAL bonus = PAWN_PASSED_MIDGAME[f] * mat_coeff[BLACK] +
						 PAWN_PASSED_ENDGAME[f] * (32 - mat_coeff[BLACK]);
		bonus /= 32;
		pas_score += bonus;

		if (mat_coeff[BLACK] == 0)
		{
			if (pos.Side() == BLACK)
				f = FLD(f + 8);

			if ((BB_PAWNW_SQUARE[f] & pos.Bits(KINGB)) == 0)
				pas_score += PAWN_PASSED_UNCATCHABLE * (7 - Row(f));
		}
		else if (mat_coeff[BLACK] < 10)
		{
			FLD K = pos.King(BLACK);
			if (Col(K) == Col(f) && K < f)
				pas_score -= PAWN_PASSED_STOPPED_BY_KING;
			else
			{
				int dist = g_dist[f][K];
				pas_score += PAWN_PASSED_KING_DISTANCE * dist;
			}

			FLD frK = pos.King(WHITE);
			if (Col(frK) == Col(f) - 1 || Col(frK) == Col(f) + 1)
			{
				if (Row(frK) == Row(f) || Row(frK) == Row(f) - 1)
					pas_score += PAWN_PASSED_SUPPORTED_KING;
			}
		}
	}

	x = (pentry->passed & pos.Bits(PAWNW)) & (BB_A7H7 | BB_A6H6);
	x = (x | bb_up(x)) & BB_A7H7;
	x = x & bb_right(x);
	pas_score += PAWN_PASSED_FAR_PAIR * CountBits(x);

	x = pentry->passed & pos.Bits(PAWNB);
	while (x)
	{
		f = PopLSB(x);
		EVAL bonus = PAWN_PASSED_MIDGAME[FLIP[f]] * mat_coeff[WHITE] +
						 PAWN_PASSED_ENDGAME[FLIP[f]] * (32 - mat_coeff[WHITE]);
		bonus /= 32;
		pas_score -= bonus;

		if (mat_coeff[WHITE] == 0)
		{
			if (pos.Side() == WHITE)
				f = FLD(f - 8);

			if ((BB_PAWNB_SQUARE[f] & pos.Bits(KINGW)) == 0)
				pas_score -= PAWN_PASSED_UNCATCHABLE * Row(f);
		}
		else if (mat_coeff[WHITE] < 10)
		{
			FLD K = pos.King(WHITE);
			if (Col(K) == Col(f) && K > f)
				pas_score += PAWN_PASSED_STOPPED_BY_KING;
			else
			{
				int dist = g_dist[f][K];
				pas_score -= PAWN_PASSED_KING_DISTANCE * dist;
			}

			FLD frK = pos.King(BLACK);
			if (Col(frK) == Col(f) - 1 || Col(frK) == Col(f) + 1)
			{
				if (Row(frK) == Row(f) || Row(frK) == Row(f) + 1)
					pas_score -= PAWN_PASSED_SUPPORTED_KING;
			}
		}
	}

	x = (pentry->passed & pos.Bits(PAWNB)) & (BB_A2H2 | BB_A3H3);
	x = (x | bb_down(x)) & BB_A2H2;
	x = x & bb_right(x);
	pas_score -= PAWN_PASSED_FAR_PAIR * CountBits(x);

	U64 strong_fields[2] =
	{
		pentry->weak_fields[BLACK] & pentry->attacked_by[WHITE] & BB_WEDGE_W,
		pentry->weak_fields[WHITE] & pentry->attacked_by[BLACK] & BB_WEDGE_B
	};

	//
	//   KNIGHTS
	//

	x = pos.Bits(KNIGHTW);
	while (x)
	{
		f = PopLSB(x);
		psq_score += PSQ_KNIGHT[f];
		int dist = g_dist[f][pos.King(BLACK)];
		king_safety[BLACK] -= KNIGHT_K_TROPISM * (7 - dist);
	}

	x = pos.Bits(KNIGHTW) & strong_fields[WHITE];
	psq_score += KNIGHT_ON_STRONG * CountBits(x);
	
	x = pos.Bits(KNIGHTW) & bb_down(pentry->weak[BLACK]) & BB_WEDGE_W;
	psq_score += KNIGHT_BLOCKING_WEAK_PAWN * CountBits(x);

	x = pos.Bits(KNIGHTB);
	while (x)
	{
		f = PopLSB(x);
		psq_score -= PSQ_KNIGHT[FLIP[f]];
		int dist = g_dist[f][pos.King(WHITE)];
		king_safety[WHITE] -= KNIGHT_K_TROPISM * (7 - dist);
	}

	x = pos.Bits(KNIGHTB) & strong_fields[BLACK];
	psq_score -= KNIGHT_ON_STRONG * CountBits(x);

	x = pos.Bits(KNIGHTB) & bb_up(pentry->weak[WHITE]) & BB_WEDGE_B;
	psq_score -= KNIGHT_BLOCKING_WEAK_PAWN * CountBits(x);

	//
	//   BISHOPS
	//

#define TRACE_BISHOP_MOB(array) \
   to = array[f];               \
   while (to != NF)             \
   {                            \
      mob++;                    \
      if (pos[to])              \
         break;                 \
      to = array[to];           \
   }

	x = pos.Bits(BISHOPW);
	while (x)
	{
		f = PopLSB(x);
		psq_score += PSQ_BISHOP[f];

		int mob = 0;
		TRACE_BISHOP_MOB(steps[1]);
		TRACE_BISHOP_MOB(steps[3]);
		TRACE_BISHOP_MOB(steps[5]);
		TRACE_BISHOP_MOB(steps[7]);

		mob_score += BISHOP_MOBILITY * mob;

		int dist = g_dist[f][pos.King(BLACK)];
		king_safety[BLACK] -= BISHOP_K_TROPISM * (7 - dist);

		if (f == A7 && pos[B6] == PAWNB)
			mob_score -= BISHOP_TRAPPED;

		if (f == H7 && pos[G6] == PAWNB)
			mob_score -= BISHOP_TRAPPED;
	}

	x = pos.Bits(BISHOPW) & strong_fields[WHITE];
	psq_score += BISHOP_ON_STRONG * CountBits(x);

	x = pos.Bits(BISHOPW) & bb_down(pentry->weak[BLACK]) & BB_WEDGE_W;
	psq_score += BISHOP_BLOCKING_WEAK_PAWN * CountBits(x);

	x = pos.Bits(BISHOPB);
	while (x)
	{
		f = PopLSB(x);
		psq_score -= PSQ_BISHOP[FLIP[f]];

		int mob = 0;
		TRACE_BISHOP_MOB(steps[1]);
		TRACE_BISHOP_MOB(steps[3]);
		TRACE_BISHOP_MOB(steps[5]);
		TRACE_BISHOP_MOB(steps[7]);

		mob_score -= BISHOP_MOBILITY * mob;

		int dist = g_dist[f][pos.King(WHITE)];
		king_safety[WHITE] -= BISHOP_K_TROPISM * (7 - dist);

		if (f == A2 && pos[B3] == PAWNW)
			psq_score += BISHOP_TRAPPED;

		if (f == H2 && pos[G3] == PAWNW)
			psq_score += BISHOP_TRAPPED;
	}

	x = pos.Bits(BISHOPB) & strong_fields[BLACK];
	psq_score -= BISHOP_ON_STRONG * CountBits(x);

	x = pos.Bits(BISHOPB) & bb_up(pentry->weak[WHITE]) & BB_WEDGE_B;
	psq_score -= BISHOP_BLOCKING_WEAK_PAWN * CountBits(x);

	//
	//   ROOKS
	//

#define TRACE_ROOK_MOB(array, fr)                 \
   to = array[f];                                 \
   while (to != NF)                               \
   {                                              \
      mob++;                                      \
      if (pos[to] && pos[to] != fr)               \
         break;                                   \
      to = array[to];                             \
   }

	x = pos.Bits(ROOKW);
	while (x)
	{
		f = PopLSB(x);
		int file = Col(f) + 1;

		if (Row(f) == 1 && Row(pos.King(BLACK)) <= 1)
			psq_score += ROOK_ON_7TH;
		
		if (pentry->rank[WHITE][file] == 0)
		{
			if (pentry->rank[BLACK][file] == 7)
				psq_score += ROOK_ON_OPEN;
			else
				psq_score += ROOK_ON_SEMIOPEN;

			int dist = Col(f) - Col(pos.King(BLACK));
			if (dist < 0)
				dist = - dist;
			king_safety[BLACK] -= ROOK_K_TROPISM * (7 - dist);
		}

		int mob = 0;
		TRACE_ROOK_MOB(steps[0], ROOKW);
		TRACE_ROOK_MOB(steps[4], ROOKW);
		mob_score += mob * ROOK_H_MOBILITY;
		if (mob == 0)
			mob_score -= ROOK_TRAPPED;
		mob = 0;
		TRACE_ROOK_MOB(steps[2], ROOKW);
		TRACE_ROOK_MOB(steps[6], ROOKW);
		mob_score += mob * ROOK_V_MOBILITY;
	}

	x = pos.Bits(ROOKB);
	while (x)
	{
		f = PopLSB(x);
		int file = Col(f) + 1;

		if (Row(f) == 6 && Row(pos.King(WHITE)) >= 6)
			psq_score -= ROOK_ON_7TH;

		if (pentry->rank[BLACK][file] == 7)
		{
			if (pentry->rank[WHITE][file] == 0)
				psq_score -= ROOK_ON_OPEN;
			else
				psq_score -= ROOK_ON_SEMIOPEN;

			int dist = Col(f) - Col(pos.King(WHITE));
			if (dist < 0)
				dist = - dist;
			king_safety[WHITE] -= ROOK_K_TROPISM * (7 - dist);
		}

		int mob = 0;
		TRACE_ROOK_MOB(steps[0], ROOKB);
		TRACE_ROOK_MOB(steps[4], ROOKB);
		mob_score -= mob * ROOK_H_MOBILITY;
		if (mob == 0)
			mob_score += ROOK_TRAPPED;
		mob = 0;
		TRACE_ROOK_MOB(steps[2], ROOKB);
		TRACE_ROOK_MOB(steps[6], ROOKB);
		mob_score -= mob * ROOK_V_MOBILITY;
	}

	//
	//   QUEENS
	//

	if (pos.Ply() >= 16 || (pos.Castlings() & (WHITE_DID_O_O | WHITE_DID_O_O_O)))
	{
		x = pos.Bits(QUEENW);
		while (x)
		{
			f = PopLSB(x);
			if (Row(f) == 1 && Row(pos.King(BLACK)) <= 1)
				psq_score += QUEEN_ON_7TH;

			int dist = g_dist[f][pos.King(BLACK)];
			king_safety[BLACK] -= QUEEN_K_TROPISM * (7 - dist);
		}
	}
	else
	{
		if (pos[D1] != QUEENW && pos.Count(QUEENW))
			psq_score -= QUEEN_EARLY_MOVE;
	}

	if (pos.Ply() >= 16 || (pos.Castlings() & (BLACK_DID_O_O | BLACK_DID_O_O_O)))
	{
		x = pos.Bits(QUEENB);
		while (x)
		{
			f = PopLSB(x);
			if (Row(f) == 6 && Row(pos.King(WHITE)) >= 6)
				psq_score -= QUEEN_ON_7TH;

			int dist = g_dist[f][pos.King(WHITE)];
			king_safety[WHITE] -= QUEEN_K_TROPISM * (7 - dist);
		}
	}
	else
	{
		if (pos[D8] != QUEENB && pos.Count(QUEENB))
			psq_score += QUEEN_EARLY_MOVE;
	}


	//
	//   SCALING
	//

	ksf_score = king_safety[WHITE] * mat_coeff[BLACK] 
	          - king_safety[BLACK] * mat_coeff[WHITE];

	ksf_score /= 32;

	mat_score = mat_score * MAT_WEIGHT / 256;
	ksf_score = ksf_score * KSF_WEIGHT / 256;
	pas_score = pas_score * PAS_WEIGHT / 256;
	psq_score = psq_score * PSQ_WEIGHT / 256;
	mob_score = mob_score * MOB_WEIGHT / 256;
	pwn_score = pwn_score * PWN_WEIGHT / 256;

	EVAL score = mat_score + 
	             ksf_score +
	             pas_score +
	             psq_score +
	             mob_score +
	             pwn_score;

	//
	//   NO-WIN MATERIAL
	//

	if (pos.Count(PAWNW) == 0 && 
	   (pos.Material(WHITE) == VAL_KNIGHT || pos.Material(WHITE) == VAL_BISHOP))
	{
		if (score > DRAW_SCORE)
			score = DRAW_SCORE;
	}

	if (pos.Count(PAWNB) == 0 &&
	   (pos.Material(BLACK) == VAL_KNIGHT || pos.Material(BLACK) == VAL_BISHOP))
	{
		if (score < DRAW_SCORE)
			score = DRAW_SCORE;
	}

	return (pos.Side() == WHITE)? score : - score;	
}
////////////////////////////////////////////////////////////////////////////////

void read_pawn_structure(const Position& pos, PawnHashEntry* pentry)
{
	pentry->pawn_hash = pos.PawnHash();
	pentry->passed = 0;
	pentry->weak[WHITE] = pentry->weak[BLACK] = 0;
	pentry->weak_fields[WHITE] = pentry->weak_fields[BLACK] = BB_ALL;
	pentry->score = 0;

	U64 x = 0, y = 0;
	FLD f = NF;

	for (int file = 0; file < 10; file++)
	{
		pentry->rank[WHITE][file] = 0;
		pentry->rank[BLACK][file] = 7;
	}

	x = pos.Bits(PAWNW);
	y = bb_up(x);
	pentry->attacked_by[WHITE] = bb_left(y) | bb_right(y);

	while (x)
	{
		f = PopLSB(x);
		pentry->score += PSQ_PAWN[f];

		int file = Col(f) + 1;
		int rank = Row(f);

		if (rank > pentry->rank[WHITE][file])
			pentry->rank[WHITE][file] = rank;

		y = BB_UPPER[f];
		y |= bb_left(y);
		y |= bb_right(y);

		if ((y & pos.Bits(PAWNB)) == 0)
			set_bit(pentry->passed, f);

		if (BB_UPPER[f] & pos.Bits(PAWNW))
			pentry->score -= PAWN_DOUBLED;

		y = bb_left(BB_SINGLE[f]) | bb_right(BB_SINGLE[f]);
		y = y | bb_down(y);
		if ((y & pos.Bits(PAWNW)) == 0)
		{
			pentry->score -= PAWN_WEAK;
			set_bit(pentry->weak[WHITE], f);
		}

		y = BB_UPPER[f];
		y = bb_left(y) | bb_right(y);
		pentry->weak_fields[WHITE] &= ~y;
	}

	x = pos.Bits(PAWNB);
	y = bb_down(x);
	pentry->attacked_by[BLACK] = bb_left(y) | bb_right(y);

	while (x)
	{
		f = PopLSB(x);
		pentry->score -= PSQ_PAWN[FLIP[f]];

		int file = Col(f) + 1;
		int rank = Row(f);

		if (rank < pentry->rank[BLACK][file])
			pentry->rank[BLACK][file] = rank;

		y = BB_LOWER[f];
		y |= bb_left(y);
		y |= bb_right(y);

		if ((y & pos.Bits(PAWNW)) == 0)
			set_bit(pentry->passed, f);

		if (BB_LOWER[f] & pos.Bits(PAWNB))
			pentry->score += PAWN_DOUBLED;

		y = bb_left(BB_SINGLE[f]) | bb_right(BB_SINGLE[f]);
		y = y | bb_up(y);
		if ((y & pos.Bits(PAWNB)) == 0)
		{
			pentry->score += PAWN_WEAK;
			set_bit(pentry->weak[BLACK], f);
		}

		y = BB_LOWER[f];
		y = bb_left(y) | bb_right(y);
		pentry->weak_fields[BLACK] &= ~y;
	}
}
////////////////////////////////////////////////////////////////////////////////

EVAL eval_wkp(const PawnHashEntry* pentry, int file)
{
	int rank = pentry->rank[WHITE][file];
	EVAL ret = 0;

	if (rank == 6);        // pawn not moved - OK
	else if (rank == 5)    // pawn on 6th
		ret -= PAWN_SHIELD_OWN_3RD;
	else if (rank != 0)    // pawn on 5th or more far
		ret -= PAWN_SHIELD_OWN_4TH;
	else
		ret -= PAWN_SHIELD_OWN_NOPAWN; // no pawn at all

	rank = pentry->rank[BLACK][file];

	if (rank == 7)         // no enemy's pawn at all
		ret -= PAWN_SHIELD_OPP_NOPAWN;
	else if (rank == 5)
		ret -= PAWN_SHIELD_OPP_3RD;
	else if (rank == 4)
		ret -= PAWN_SHIELD_OPP_4TH;

	return ret;
}
////////////////////////////////////////////////////////////////////////////////

EVAL eval_bkp(const PawnHashEntry* pentry, int file)
{
	int rank = pentry->rank[BLACK][file];
	EVAL ret = 0;

	if (rank == 1);        // pawn not moved - OK
	else if (rank == 2)    // pawn on 6th
		ret -= PAWN_SHIELD_OWN_3RD;
	else if (rank != 7)    // pawn on 5th or more far
		ret -= PAWN_SHIELD_OWN_4TH;
	else
		ret -= PAWN_SHIELD_OWN_NOPAWN; // no pawn at all

	rank = pentry->rank[WHITE][file];

	if (rank == 0)         // no enemy's pawn at all
		ret -= PAWN_SHIELD_OPP_NOPAWN;
	else if (rank == 2)
		ret -= PAWN_SHIELD_OPP_3RD;
	else if (rank == 3)
		ret -= PAWN_SHIELD_OPP_4TH;

	return ret;
}
////////////////////////////////////////////////////////////////////////////////

EVAL eval_pawn_shield_w(const PawnHashEntry* pentry, FLD  K)
{
	int file = Col(K) + 1;
	EVAL ret = 0;

	if (file < 4)
	{
		ret += eval_wkp(pentry, 1);
		ret += eval_wkp(pentry, 2);
		ret += eval_wkp(pentry, 3);
	}
	else if (file > 5)
	{
		ret += eval_wkp(pentry, 6);
		ret += eval_wkp(pentry, 7);
		ret += eval_wkp(pentry, 8);
	}
	else
	{
		for (int j = file - 1; j <= file + 1; j++)
		{
			if (pentry->rank[WHITE][j] == 0)
			{
				if (pentry->rank[BLACK][j] == 7)
					ret -= PAWN_SHIELD_OPEN_CENTER;
				else
					ret -= PAWN_SHIELD_SEMIOPEN_CENTER;
			}
		}
	}

	return ret;
}
////////////////////////////////////////////////////////////////////////////////

EVAL eval_pawn_shield_b(const PawnHashEntry* pentry, FLD  K)
{
	int file = Col(K) + 1;
	EVAL ret = 0;

	if (file < 4)
	{
		ret += eval_bkp(pentry, 1);
		ret += eval_bkp(pentry, 2);
		ret += eval_bkp(pentry, 3);
	}
	else if (file > 5)
	{
		ret += eval_bkp(pentry, 6);
		ret += eval_bkp(pentry, 7);
		ret += eval_bkp(pentry, 8);
	}
	else
	{
		for (int j = file - 1; j <= file + 1; j++)
		{
			if (pentry->rank[BLACK][j] == 7)
			{
				if (pentry->rank[WHITE][j] == 0)
					ret -= PAWN_SHIELD_OPEN_CENTER;
				else
					ret -= PAWN_SHIELD_SEMIOPEN_CENTER;
			}
		}
	}

	return ret;
}
////////////////////////////////////////////////////////////////////////////////

