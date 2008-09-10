#ifndef EVAL_H
#define EVAL_H

#include "position.h"

const EVAL VAL_PAWN   = 100;
const EVAL VAL_KNIGHT = 400;
const EVAL VAL_BISHOP = 400;
const EVAL VAL_ROOK   = 600;
const EVAL VAL_QUEEN  = 1200;

static const EVAL VALUE[14] =
{
	0, 0,
	VAL_PAWN, VAL_PAWN,
	VAL_KNIGHT, VAL_KNIGHT,
	VAL_BISHOP, VAL_BISHOP,
	VAL_ROOK, VAL_ROOK,
	VAL_QUEEN, VAL_QUEEN,
	0, 0
};

#define INFINITY_SCORE  (50000)
#define DRAW_SCORE		(0)

struct PawnHashEntry
{
	U32 pawn_hash;
	U64 passed;
	U64 weak[2];
	U64 attacked_by[2];
	U64 weak_fields[2];

	int rank[2][10];
	int pawnw_on_fld[2];
	int pawnb_on_fld[2];

	EVAL score;
};
typedef struct PawnHashEntry PawnHashEntry;

extern PawnHashEntry* g_pawn_hash;
extern long g_pawn_hash_size;

struct Attacks
{
	U64 by[14];
};
typedef struct Attacks Attacks;

EVAL evaluate(const Position& pos, EVAL alpha, EVAL beta);

#endif

