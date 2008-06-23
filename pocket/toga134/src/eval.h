
// eval.h

#ifndef EVAL_H
#define EVAL_H

// includes

#include "board.h"
#include "util.h"

extern bool egbb_is_loaded;

// functions

extern void eval_init ();
extern void eval_parameter ();

extern int  eval      (board_t * board, int alpha, int beta, bool in_pv);

#endif // !defined EVAL_H

// end of eval.h

