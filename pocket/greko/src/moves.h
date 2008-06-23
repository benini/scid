#ifndef MOVES_H
#define MOVES_H

#include "consts.h"
#include "position.h"

struct SMove
{
	Move mv;
	EVAL value;
};
typedef struct SMove SMove;

extern SMove* g_moves[MAX_PLY + 2];
extern int g_moves_cnt[MAX_PLY + 2];

void  init_mg();
void  gen_captures_and_promotions(const Position* pos, int ply);
void  gen_moves(const Position* pos, int ply);
char* move_to_str(Move mv, char* buf);
char* move_to_str_san(const Position* pos, Move mv, char* buf);

#endif
