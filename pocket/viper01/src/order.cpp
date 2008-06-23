#include "viper.h"

void order_moves(const position_t *pos, search_stack_t *ss, 
		 int ply, move_t pvmove) {
  move_stack_t *ms;
  move_t m;
  int cap, pc, from, to;

  for(ms=ss[ply].ms_ptr; ms<ss[ply+1].ms_ptr; ms++) {
    m = ms->move;
    if((ms->move&0x1FFFF) == (pvmove&0x1FFFF)) {
      ms->score = 100000000; continue;
    }
    cap = CAPTURE(m); pc = PIECE(m); from = FROM(m); to = TO(m);
    if(PROMOTION(m) == QUEEN && see(pos, from, to) >= 0) {
      ms->score = 10000000 + cap; continue;
    }
    if(cap) {
      int s = see(pos, from, to);
      if(ply > 0 && s > 0 && to == TO(ss[ply-1].move)) {
        ms->score = 10000000 + s; 
      }
      else if(s >= 0) ms->score = 9000000 + s;
      else ms->score = s;
    }
    else if(ms->move==ss[ply].killer) ms->score = 9000000;
    else if(ms->move==ss[ply].killer2) ms->score = 8999999;
    else if(ply >= 2 && ms->move==ss[ply-2].killer) ms->score = 8999998;
    else if(ply >= 2 && ms->move==ss[ply-2].killer2) ms->score = 8999997;
    else ms->score = HISTORY(pos->side, m);
  }
}

void order_qmoves(const position_t *pos, search_stack_t *ss, 
		  int ply, move_t pvmove) {
  move_stack_t *ms;
  move_t m;
  int cap, pc, from, to;

  if(ss[ply].check) order_moves(pos, ss, ply, pvmove);
  else {
    for(ms=ss[ply].ms_ptr; ms<ss[ply+1].ms_ptr; ms++) {
      m = ms->move;
      if(ms->move == pvmove) {
        ms->score = 100000000; continue;
      }
      cap = CAPTURE(m); pc = PIECE(m); from = FROM(m); to = TO(m);
      if(PROMOTION(m) == QUEEN && see(pos, from, to) >= 0) {
        ms->score = 10000000 + cap; continue;
      }
      if(cap) {
        if(ply > 0 && to == TO(ss[ply-1].move)) ms->score = 10000000 - pc;
        else ms->score = 9000000 + PieceValues[cap] - pc;
      }
      else ms->score = 0;
    }
  }
}

move_t pick_move(move_stack_t **start, move_stack_t *end, bool look_for_best) {
  move_stack_t *ms, tmp, *best = NULL;
  int best_score = -10000000;
  if(*start == end) return 0; 
  if(!look_for_best) return ((*start)++)->move;
  for(ms = *start; ms < end; ms++)
    if(ms->score > best_score) {
      best = ms; best_score = best->score;
    }
  if(best != NULL) {
    tmp = **start; **start = *best; *best = tmp;
    return ((*start)++)->move;
  }
  else return 0; 
}
