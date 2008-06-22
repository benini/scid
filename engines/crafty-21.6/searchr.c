#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "chess.h"
#include "data.h"
#include "epdglue.h"

/* modified 08/07/05 */
/*
 *******************************************************************************
 *                                                                             *
 *   SearchRoot() is the recursive routine used to implement the alpha/beta    *
 *   negamax search (similar to minimax but simpler to code.)  SearchRoot() is *
 *   only called when ply=1.  it is somewhat different from Search() in that   *
 *   some things (null move search, hash lookup, etc.) are not useful at the   *
 *   root of the tree.  SearchRoot() calls Search() to search any positions    *
 *   that are below ply=1.                                                     *
 *                                                                             *
 *******************************************************************************
 */
int SearchRoot(TREE * RESTRICT tree, int alpha, int beta, int wtm, int depth)
{
  register int first_move = 1;
  register int value;
  register int extensions, extended;
  BITBOARD begin_root_nodes;

/*
 ************************************************************
 *                                                          *
 *   initialize.  set NextMove() status to 0 so it will     *
 *   know what has to be done.                              *
 *                                                          *
 ************************************************************
 */
  tree->in_check[2] = 0;
  tree->in_check[1] = Check(wtm);
  tree->next_status[1].phase = HASH_MOVE;
/*
 ************************************************************
 *                                                          *
 *   now iterate through the move list and search the       *
 *   resulting positions.  note that Search() culls any     *
 *   move that is not legal by using Check().  the special  *
 *   case is that we must find one legal move to search to  *
 *   confirm that it's not a mate or draw.                  *
 *                                                          *
 ************************************************************
 */
  while ((tree->phase[1] = NextRootMove(tree, tree, wtm))) {
#if defined(TRACE)
    if (1 <= trace_level)
      SearchTrace(tree, 1, depth, wtm, alpha, beta, "SearchRoot",
          tree->phase[1]);
#endif
/*
 ************************************************************
 *                                                          *
 *   now make the move and search the resulting position.   *
 *                                                          *
 ************************************************************
 */
    MakeMove(tree, 1, tree->current_move[1], wtm);
/*
 ************************************************************
 *                                                          *
 *   now it is time to call SearchControl() to adjust the   *
 *   search depth for this move.                            *
 *                                                          *
 ************************************************************
 */
    extended = SearchControl(tree, wtm, 1, depth, 0);
/*
 ************************************************************
 *                                                          *
 *   now call Search to produce a value for this move.      *
 *                                                          *
 ************************************************************
 */
    begin_root_nodes = tree->nodes_searched;
    extensions = extended - PLY;
    if (first_move) {
      if (depth + extensions >= PLY)
        value =
            -Search(tree, -beta, -alpha, Flip(wtm), depth + extensions, 2,
            DO_NULL);
      else
        value = -Quiesce(tree, -beta, -alpha, Flip(wtm), 2);
      if (shared->abort_search) {
        UnmakeMove(tree, 1, tree->current_move[1], wtm);
        return (alpha);
      }
      first_move = 0;
    } else {
      if (depth + extensions >= PLY)
        value =
            -Search(tree, -alpha - 1, -alpha, Flip(wtm), depth + extensions, 2,
            DO_NULL);
      else
        value = -Quiesce(tree, -alpha - 1, -alpha, Flip(wtm), 2);
      if (shared->abort_search) {
        UnmakeMove(tree, 1, tree->current_move[1], wtm);
        return (alpha);
      }
      if ((value > alpha) && (value < beta)) {
        if (depth + extensions >= PLY)
          value =
              -Search(tree, -beta, -alpha, Flip(wtm), depth + extensions, 2,
              DO_NULL);
        else
          value = -Quiesce(tree, -beta, -alpha, Flip(wtm), 2);
        if (shared->abort_search) {
          UnmakeMove(tree, 1, tree->current_move[1], wtm);
          return (alpha);
        }
      }
    }
    shared->root_moves[tree->root_move].nodes =
        tree->nodes_searched - begin_root_nodes;
    if (value > alpha) {
      SearchOutput(tree, value, beta);
      shared->root_value = alpha;
      if (value >= beta) {
        Killer(tree, 1, tree->current_move[1]);
        UnmakeMove(tree, 1, tree->current_move[1], wtm);
        return (value);
      }
      alpha = value;
    }
    shared->root_value = alpha;
    UnmakeMove(tree, 1, tree->current_move[1], wtm);
#if defined(SMP)
    if (shared->split_at_root && shared->smp_idle && NextRootMoveParallel()) {
      tree->alpha = alpha;
      tree->beta = beta;
      tree->value = alpha;
      tree->wtm = wtm;
      tree->ply = 1;
      tree->depth = depth;
      tree->mate_threat = 0;
      if (Thread(tree)) {
        if (shared->abort_search || tree->stop)
          return (0);
        if (tree->thread_id == 0 && CheckInput())
          Interrupt(1);
        value = tree->search_value;
        if (value > alpha) {
          if (value >= beta) {
            Killer(tree, 1, tree->current_move[1]);
            tree->fail_high++;
            return (value);
          }
          alpha = value;
          break;
        }
      }
    }
#endif
  }
/*
 ************************************************************
 *                                                          *
 *   all moves have been searched.  if none were legal,     *
 *   return either MATE or DRAW depending on whether the    *
 *   side to move is in check or not.                       *
 *                                                          *
 ************************************************************
 */
  if (shared->abort_search || shared->time_abort)
    return (0);
  if (first_move == 1) {
    value = (Check(wtm)) ? -(MATE - 1) : DrawScore(wtm);
    if (value >= alpha && value < beta) {
      tree->pv[0].pathl = 0;
      tree->pv[0].pathh = 0;
      tree->pv[0].pathd = shared->iteration_depth;
      SearchOutput(tree, value, beta);
#if defined(TRACE)
      if (1 <= trace_level)
        printf("Search() no moves!  ply=1\n");
#endif
    }
    return (value);
  } else {
    Killer(tree, 1, tree->pv[1].path[1]);
    return (alpha);
  }
}

/* modified 08/07/05 */
/*
 *******************************************************************************
 *                                                                             *
 *   SearchOutput() is used to print the principal variation whenever it       *
 *   changes.  one additional feature is that SearchOutput() will try to do    *
 *   something about variations truncated by the transposition table.  if the  *
 *   variation was cut short by a transposition table hit, then we can make the*
 *   last move, add it to the end of the variation and extend the depth of the *
 *   variation to cover it.                                                    *
 *                                                                             *
 *******************************************************************************
 */
void SearchOutput(TREE * RESTRICT tree, int value, int bound)
{
  register int wtm;
  int i;
  ROOT_MOVE temp_rm;

/*
 ************************************************************
 *                                                          *
 *   first, move the best move to the top of the ply-1 move *
 *   list if it's not already there, so that it will be the *
 *   first move tried in the next iteration.                *
 *                                                          *
 ************************************************************
 */
  shared->root_print_ok = shared->root_print_ok ||
      tree->nodes_searched > shared->noise_level;
  wtm = shared->root_wtm;
  if (!shared->abort_search) {
    shared->kibitz_depth = shared->iteration_depth;
    for (i = 0; i < shared->n_root_moves; i++)
      if (tree->current_move[1] == shared->root_moves[i].move)
        break;
    if (i && i < shared->n_root_moves) {
      temp_rm = shared->root_moves[i];
      for (; i > 0; i--)
        shared->root_moves[i] = shared->root_moves[i - 1];
      shared->root_moves[0] = temp_rm;
      shared->easy_move = 0;
    }
    shared->end_time = ReadClock();
/*
 ************************************************************
 *                                                          *
 *   if this is not a fail-high move, then output the PV    *
 *   by walking down the path being backed up.              *
 *                                                          *
 ************************************************************
 */
    if (value < bound) {
      UnmakeMove(tree, 1, tree->pv[1].path[1], shared->root_wtm);
      DisplayPV(tree, 6, wtm, shared->end_time - shared->start_time, value,
          &tree->pv[1]);
      MakeMove(tree, 1, tree->pv[1].path[1], shared->root_wtm);
    } else {
      if (tree->current_move[1] != tree->pv[1].path[1]) {
        tree->pv[1].path[1] = tree->current_move[1];
        tree->pv[1].pathl = 1;
        tree->pv[1].pathh = 0;
        tree->pv[1].pathd = shared->iteration_depth;
      }
    }
    tree->pv[0] = tree->pv[1];
    shared->local[0]->pv[0] = tree->pv[1];
  }
}

/* modified 08/07/05 */
/*
 *******************************************************************************
 *                                                                             *
 *   SearchTrace() is used to print the search trace output each time a node is*
 *   traversed in the tree.                                                    *
 *                                                                             *
 *******************************************************************************
 */
void SearchTrace(TREE * RESTRICT tree, int ply, int depth, int wtm, int alpha,
    int beta, char *name, int phase)
{
  int i;

  Lock(shared->lock_io);
  for (i = 1; i < ply; i++)
    printf("  ");
  printf("%d  %s d:%5.2f [%s,", ply, OutputMove(tree, tree->current_move[ply],
          ply, wtm), (float) depth / (float) PLY, DisplayEvaluation(alpha, 1));
  printf("%s] n:" BMF " %s(%d)", DisplayEvaluation(beta, 1),
      (tree->nodes_searched), name, phase);
  if (shared->max_threads > 1)
    printf(" (t=%d) ", tree->thread_id);
  printf("\n");
  Unlock(shared->lock_io);
}
