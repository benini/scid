#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "chess.h"
#include "data.h"

/* last modified 05/10/06 */
/*
 *******************************************************************************
 *                                                                             *
 *   Quiesce() is the recursive routine used to implement the alpha/beta       *
 *   negamax search (similar to minimax but simpler to code.)  Quiesce() is    *
 *   called whenever there is no "depth" remaining so that only capture moves  *
 *   are searched deeper.                                                      *
 *                                                                             *
 *******************************************************************************
 */
int Quiesce(TREE * RESTRICT tree, int alpha, int beta, int wtm, int ply)
{
  register int o_alpha, value;
  register int *next_move;
  register int *goodmv, *movep, moves = 0, *sortv, temp;

/*
 ************************************************************
 *                                                          *
 *   initialize.                                            *
 *                                                          *
 ************************************************************
 */
  if (ply >= MAXPLY - 1)
    return (beta);
  tree->nodes_searched++;
#if defined(NODES)
  temp_search_nodes--;
  if (temp_search_nodes <= 0) {
    shared->time_abort++;
    shared->abort_search = 1;
    return (0);
  }
#endif
  if (tree->thread_id == 0)
    shared->next_time_check--;
  tree->last[ply] = tree->last[ply - 1];
  o_alpha = alpha;
/*
 ************************************************************
 *                                                          *
 *   now call Evaluate() to produce the "stand-pat" score   *
 *   that will be returned if no capture is acceptable.     *
 *   if this score is > alpha, then we also have to save    *
 *   the "path" to this node as it is the PV that leads     *
 *   to this score.                                         *
 *                                                          *
 ************************************************************
 */
  value = Evaluate(tree, ply, wtm, alpha, beta);
  if (value > alpha) {
    if (value >= beta)
      return (value);
    alpha = value;
    tree->pv[ply].pathl = ply - 1;
    tree->pv[ply].pathh = 0;
    tree->pv[ply].pathd = shared->iteration_depth;
  }
/*
 ************************************************************
 *                                                          *
 *   generate captures and sort them based on (a) the value *
 *   of the captured piece - the value of the capturing     *
 *   piece if this is > 0; or, (b) the value returned by    *
 *   Swap().  if the capture leaves the opponent with one   *
 *   minor piece or less, then we search that capture       *
 *   always since the endgame might be won or lost.         *
 *                                                          *
 ************************************************************
 */
  tree->last[ply] = GenerateCaptures(tree, ply, wtm, tree->last[ply - 1]);
  goodmv = tree->last[ply - 1];
  sortv = tree->sort_value;
  for (movep = tree->last[ply - 1]; movep < tree->last[ply]; movep++) {
    if (Captured(*movep) == king)
      return (beta);
    if (p_values[Piece(*movep) + 7] < p_values[Captured(*movep) + 7] ||
        ((wtm) ? TotalBlackPieces : TotalWhitePieces) -
        p_vals[Captured(*movep)] < bishop_v) {
      *goodmv++ = *movep;
      *sortv++ = p_values[Captured(*movep) + 7];
      moves++;
    } else {
      temp = Swap(tree, From(*movep), To(*movep), wtm);
      if (temp >= 0) {
        *sortv++ = temp;
        *goodmv++ = *movep;
        moves++;
      }
    }
  }
/*
 ************************************************************
 *                                                          *
 *   don't disdain the lowly bubble sort here.  the list of *
 *   captures is always short, and experiments with other   *
 *   algorithms are always slightly slower.                 *
 *                                                          *
 ************************************************************
 */
  if (moves > 1) {
    register int done;
    register int *end = tree->last[ply - 1] + moves - 1;

    do {
      done = 1;
      sortv = tree->sort_value;
      for (movep = tree->last[ply - 1]; movep < end; movep++, sortv++)
        if (*sortv < *(sortv + 1)) {
          temp = *sortv;
          *sortv = *(sortv + 1);
          *(sortv + 1) = temp;
          temp = *movep;
          *movep = *(movep + 1);
          *(movep + 1) = temp;
          done = 0;
        }
    } while (!done);
  }
  next_move = tree->last[ply - 1];
/*
 ************************************************************
 *                                                          *
 *   now iterate through the move list and search the       *
 *   resulting positions.                                   *
 *                                                          *
 ************************************************************
 */
  while (moves--) {
    tree->current_move[ply] = *(next_move++);
#if defined(TRACE)
    if (ply <= trace_level)
      SearchTrace(tree, ply, 0, wtm, alpha, beta, "quiesce", CAPTURE_MOVES);
#endif
    MakeMove(tree, ply, tree->current_move[ply], wtm);
    value = -Quiesce(tree, -beta, -alpha, Flip(wtm), ply + 1);
    UnmakeMove(tree, ply, tree->current_move[ply], wtm);
    if (value > alpha) {
      if (value >= beta)
        return (value);
      alpha = value;
    }
    if (tree->stop)
      return (0);
  }
/*
 ************************************************************
 *                                                          *
 *   all moves have been searched.  return the search       *
 *   result that was found.  if the result is not the       *
 *   original alpha score, then we need to return the PV    *
 *   that is associated with this score.                    *
 *                                                          *
 ************************************************************
 */
  if (alpha != o_alpha) {
    memcpy(&tree->pv[ply - 1].path[ply], &tree->pv[ply].path[ply],
        (tree->pv[ply].pathl - ply + 1) * sizeof(int));
    memcpy(&tree->pv[ply - 1].pathh, &tree->pv[ply].pathh, 3);
    tree->pv[ply - 1].path[ply - 1] = tree->current_move[ply - 1];
  }
  return (alpha);
}
