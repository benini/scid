#include "glaurung.h"

int extend(const position_t *pos, search_stack_t *ss, int mate_threat) {
  move_t m = ss->move;
  ss->extension = 0;
  if(pos->check) ss->extension += Options->check_ext;
  if(ss->check && ss->num_of_evasions==1) 
    ss->extension += Options->one_reply_ext;
  if(ss->check && ss->num_of_evasions==2) 
    ss->extension += Options->two_replies_ext;
  if(mate_threat) ss->extension += Options->mate_threat_ext;
  if(PIECE(m)==PAWN && PawnRank[pos->xside][TO(m)] == RANK_7) 
    ss->extension += Options->p7th_ext;
  if(CAPTURE(m) > PAWN && pawn_endgame(pos)) {
    switch(CAPTURE(m)) {
    case QUEEN: ss->extension = 150; return ss->extension;
    case ROOK: ss->extension = 90; return ss->extension;
    default: ss->extension = 60; return ss->extension;
    }
  }
  if(ss->extension > PLY) ss->extension = PLY;
  return ss->extension;
}
