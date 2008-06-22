#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "chess.h"
#include "data.h"
#include "epdglue.h"

#if !defined(NOFUTILITY)
#  define RAZOR_MARGIN ((queen_value+1)/2)
#  define F_MARGIN ((bishop_value+1)/2)
#endif

/* modified 08/07/05 */
/*
 *******************************************************************************
 *                                                                             *
 *   SearchSMP() is the recursive routine used to implement the alpha/beta     *
 *   negamax search using parallel threads.  when this code is called, the     *
 *   first move has already been searched, so all that is left is to search the*
 *   remainder of the moves and then return.  note that the hash table and such*
 *   can't be modified here since this only represents a part of the search at *
 *   this ply.                                                                 *
 *                                                                             *
 *******************************************************************************
 */
int SearchSMP(TREE * RESTRICT tree, int alpha, int beta, int value, int wtm,
    int depth, int ply, int mate_threat)
{
  register int extensions, extended;
  BITBOARD begin_root_nodes;

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
  while (1) {
    Lock(tree->parent->lock);
    if (ply == 1) {
      tree->phase[ply] = NextRootMove(tree->parent, tree, wtm);
      tree->root_move = tree->parent->root_move;
    } else
      tree->phase[ply] =
          (tree->in_check[ply]) ? NextEvasion((TREE *) tree->parent, ply,
          wtm) : NextMove((TREE *) tree->parent, ply, wtm);
    tree->current_move[ply] = tree->parent->current_move[ply];
    Unlock(tree->parent->lock);
    if (!tree->phase[ply])
      break;
#if defined(TRACE)
    if (ply <= trace_level)
      SearchTrace(tree, ply, depth, wtm, alpha, beta, "SearchSMP",
          tree->phase[ply]);
#endif
/*
 ************************************************************
 *                                                          *
 *   now make the move and search the resulting position.   *
 *   if we are in check, the current move must be legal     *
 *   since NextEvasion ensures this, otherwise we have to   *
 *   make sure the side-on-move is not in check after the   *
 *   move to weed out illegal moves and save time.          *
 *                                                          *
 ************************************************************
 */
    MakeMove(tree, ply, tree->current_move[ply], wtm);
    if (tree->in_check[ply] || !Check(wtm)) {
/*
 ************************************************************
 *                                                          *
 *   now it is time to call SearchControl() to adjust the   *
 *   search depth for this move.                            *
 *                                                          *
 ************************************************************
 */
      extended = SearchControl(tree, wtm, ply, depth, mate_threat);
/*
 ************************************************************
 *                                                          *
 *   now it is time to call Search()/Quiesce to find out if *
 *   this move is reasonable or not.                        *
 *                                                          *
 ************************************************************
 */
      begin_root_nodes = tree->nodes_searched;
#if !defined(NOFUTILITY)
      tree->fprune = 0;
#endif
      extensions = extended - PLY;
#if !defined(NOFUTILITY)
      if (!tree->in_check[ply] && !tree->in_check[ply + 1]) {
        if (abs(alpha) < (MATE - 500) && ply > 4 && !tree->in_check[ply]) {
          if (wtm) {
            if (depth < 3 * PLY && (Material + F_MARGIN) <= alpha)
              tree->fprune = 1;
            else if (depth >= 3 * PLY && depth < 5 * PLY &&
                (Material + RAZOR_MARGIN) <= alpha)
              extensions -= 4;
          } else {
            if (depth < 3 * PLY && (-Material + F_MARGIN) <= alpha)
              tree->fprune = 1;
            else if (depth >= 3 * PLY && depth < 5 * PLY &&
                (-Material + RAZOR_MARGIN) <= alpha)
              extensions -= 4;
          }
        }
      }
#endif
      if (depth + extensions >= PLY
#if !defined(NOFUTILITY)
          && !tree->fprune
#endif
          ) {
        value =
            -Search(tree, -alpha - 1, -alpha, Flip(wtm), depth + extensions,
            ply + 1, DO_NULL);
        if (value > alpha && extensions < -PLY)
          value =
              -Search(tree, -alpha - 1, -alpha, Flip(wtm), depth - PLY, ply + 1,
              DO_NULL);
      } else
        value = -Quiesce(tree, -alpha - 1, -alpha, Flip(wtm), ply + 1);
      if (shared->abort_search || tree->stop) {
        UnmakeMove(tree, ply, tree->current_move[ply], wtm);
        break;
      }
      if (value > alpha && value < beta) {
        extensions = Max(extensions, -PLY);
        if (depth + extensions >= PLY)
          value =
              -Search(tree, -beta, -alpha, Flip(wtm), depth + extensions,
              ply + 1, DO_NULL);
        else
          value = -Quiesce(tree, -beta, -alpha, Flip(wtm), ply + 1);
        if (shared->abort_search || tree->stop) {
          UnmakeMove(tree, ply, tree->current_move[ply], wtm);
          break;
        }
      }
/*
 ************************************************************
 *                                                          *
 *   now we check for an undesirable case, that of failing  *
 *   high while doing a parallel (threaded) search.  this   *
 *   means our 'helpers' are doing stuff that is not needed *
 *   so we 'stop' them now.                                 *
 *                                                          *
 ************************************************************
 */
      if (ply == 1)
        shared->root_moves[tree->root_move].nodes =
            tree->nodes_searched - begin_root_nodes;
      if (value > alpha) {
        alpha = value;
        if (ply == 1) {
          Lock(shared->lock_root);
          if (value > shared->root_value) {
            SearchOutput(tree, value, beta);
            shared->root_value = value;
          }
          Unlock(shared->lock_root);
        }
        if (value >= beta) {
          register int proc;

          shared->parallel_aborts++;
          UnmakeMove(tree, ply, tree->current_move[ply], wtm);
          Lock(shared->lock_smp);
          Lock(tree->parent->lock);
          if (!tree->stop) {
            for (proc = 0; proc < shared->max_threads; proc++)
              if (tree->parent->siblings[proc] && proc != tree->thread_id)
                ThreadStop(tree->parent->siblings[proc]);
          }
          Unlock(tree->parent->lock);
          Unlock(shared->lock_smp);
          break;
        }
      }
    }
    UnmakeMove(tree, ply, tree->current_move[ply], wtm);
  }
  if (tree->stop && ply == 1)
    shared->root_moves[tree->root_move].status &= 255 - 128;
  return (alpha);
}
