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

/* last modified 03/01/06 */
/*
 *******************************************************************************
 *                                                                             *
 *   Search() is the recursive routine used to implement the alpha/beta        *
 *   negamax search (similar to minimax but simpler to code.)  Search() is     *
 *   called whenever there is "depth" remaining so that all moves are subject  *
 *   to searching, or when the side to move is in check, to make sure that this*
 *   side isn't mated.  Search() recursively calls itself until depth is ex-   *
 *   hausted, at which time it calls Quiesce() instead.                        *
 *                                                                             *
 *******************************************************************************
 */
int Search(TREE * RESTRICT tree, int alpha, int beta, int wtm, int depth,
    int ply, int do_null)
{
  register int moves_searched = 0;
  register int o_alpha, value = 0;
  register int extensions, extended, pieces;
  int mate_threat = 0;

/*
 ************************************************************
 *                                                          *
 *   check to see if we have searched enough nodes that it  *
 *   is time to peek at how much time has been used, or if  *
 *   is time to check for operator keyboard input.  this is *
 *   usually enough nodes to force a time/input check about *
 *   once per second, except when the target time per move  *
 *   is very small, in which case we try to check the time  *
 *   at least 10 times during the search.                   *
 *                                                          *
 ************************************************************
 */
  tree->nodes_searched++;
#if defined(NODES)
  temp_search_nodes--;
  if (temp_search_nodes <= 0) {
    shared->time_abort++;
    shared->abort_search = 1;
    return (0);
  }
#endif
  if (tree->thread_id == 0) {
    if (--shared->next_time_check <= 0) {
      shared->next_time_check = shared->nodes_between_time_checks;
      if (CheckInput())
        Interrupt(ply);
      if (TimeCheck(tree, 0)) {
        shared->time_abort++;
        shared->abort_search = 1;
        return (0);
      }
    }
  }
  if (ply >= MAXPLY - 1)
    return (beta);
/*
 ************************************************************
 *                                                          *
 *   check for draw by repetition.                          *
 *                                                          *
 ************************************************************
 */
  if (RepetitionCheck(tree, ply)) {
    value = DrawScore(wtm);
    if (value < beta)
      SavePV(tree, ply, 0);
#if defined(TRACE)
    if (ply <= trace_level)
      printf("draw by repetition detected, ply=%d.\n", ply);
#endif
    return (value);
  }
/*
 ************************************************************
 *                                                          *
 *   now call HashProbe() to see if this position has been  *
 *   searched before.  if so, we may get a real score,      *
 *   produce a cutoff, or get nothing more than a good move *
 *   to try first.  there are four cases to handle:         *
 *                                                          *
 *   1. HashProbe() returned "EXACT" if this score is       *
 *   greater than beta, return beta.  otherwise, return the *
 *   score.  In either case, no further searching is needed *
 *   from this position.  note that lookup verified that    *
 *   the table position has sufficient "draft" to meet the  *
 *   requirements of the current search depth remaining.    *
 *                                                          *
 *   2. HashProbe() returned "UPPER" which means that       *
 *   when this position was searched previously, every move *
 *   was "refuted" by one of its descendents.  as a result, *
 *   when the search was completed, we returned alpha at    *
 *   that point.  we simply return alpha here as well.      *
 *                                                          *
 *   3. HashProbe() returned "LOWER" which means that       *
 *   when we encountered this position before, we searched  *
 *   one branch (probably) which promptly refuted the move  *
 *   at the previous ply.                                   *
 *                                                          *
 *   4. HashProbe() returned "AVOID_NULL_MOVE" which means  *
 *   the hashed score/bound was no good, but it indicated   *
 *   that trying a null-move in this position would be a    *
 *   waste of time.                                         *
 *                                                          *
 ************************************************************
 */
  switch (HashProbe(tree, ply, depth, wtm, &alpha, beta, &mate_threat)) {
  case EXACT:
    if (alpha < beta)
      SavePV(tree, ply, 1);
    return (alpha);
  case EXACTEGTB:
    if (alpha < beta)
      SavePV(tree, ply, 2);
    return (alpha);
  case LOWER:
    return (beta);
  case UPPER:
    return (alpha);
  case AVOID_NULL_MOVE:
    do_null = 0;
  }
/*
 ************************************************************
 *                                                          *
 *   now it's time to try a probe into the endgame table-   *
 *   base files.  this is done if we notice that there are  *
 *   6 or fewer pieces left on the board.  EGTB_use tells   *
 *   us how many pieces to probe on.  note that this can be *
 *   zero when trying to swindle the opponent, so that no   *
 *   probes are done since we know it is a draw.            *
 *                                                          *
 ************************************************************
 */
#if !defined(NOEGTB)
  if (ply <= shared->iteration_depth && TotalPieces <= EGTB_use &&
      WhiteCastle(ply) + BlackCastle(ply) == 0 &&
      (CaptureOrPromote(tree->current_move[ply - 1]) || ply < 3)) {
    int egtb_value;

    tree->egtb_probes++;
    if (EGTBProbe(tree, ply, wtm, &egtb_value)) {
      tree->egtb_probes_successful++;
      alpha = egtb_value;
      if (abs(alpha) > MATE - 300)
        alpha += (alpha > 0) ? -ply + 1 : ply;
      else if (alpha == 0) {
        alpha = DrawScore(wtm);
        if (Material > 0)
          alpha += (wtm) ? 1 : -1;
        else if (Material < 0)
          alpha -= (wtm) ? 1 : -1;
      }
      if (alpha < beta)
        SavePV(tree, ply, 2);
      tree->pv[ply].pathl = 0;
      HashStore(tree, ply, MAX_DRAFT, wtm, EXACT, alpha, mate_threat);
      return (alpha);
    }
  }
#endif
/*
 ************************************************************
 *                                                          *
 *   initialize for a full search.                          *
 *                                                          *
 ************************************************************
 */
  tree->in_check[ply + 1] = 0;
  o_alpha = alpha;
  tree->last[ply] = tree->last[ply - 1];
/*
 ************************************************************
 *                                                          *
 *  first, we try a null move to see if we can get a quick  *
 *  cutoff with only a little work.  this operates as       *
 *  follows.  instead of making a legal move, the side on   *
 *  move 'passes' and does nothing.  the resulting position *
 *  is searched to a shallower depth than normal (usually   *
 *  one ply less but settable by the operator) this should  *
 *  result in a cutoff or at least should set the lower     *
 *  bound better since anything should be better than not   *
 *  doing anything.                                         *
 *                                                          *
 *  this is skipped for any of the following reasons:       *
 *                                                          *
 *  1.  the side on move is in check.  the null move        *
 *      results in an illegal position.                     *
 *  2.  no more than one null move can appear in succession *
 *      or else the search will degenerate into nothing.    *
 *  3.  the side on move has little material left making    *
 *      zugzwang positions more likely.                     *
 *                                                          *
 *  the null-move search is also used to detect certain     *
 *  types of threats.  the original idea of using the value *
 *  returned by the null-move search was reported by C.     *
 *  Donninger, but was modified by Bruce Moreland (Ferret)  *
 *  in the following way:  if the null-move search returns  *
 *  a score that says "mated in N" then this position is a  *
 *  dangerous one, because not moving gets the side to move *
 *  mated.  we extend the search in this case, although as  *
 *  always, no more than one ply of extensions is allowed   *
 *  at any one level in the tree.  note also that this      *
 *  "threat" condition is hashed so that later, if the hash *
 *  table says "don't try the null move because it likely   *
 *  will fail low, we still know that this is a threat      *
 *  position and that it should be extended.                *
 *                                                          *
 ************************************************************
 */
  pieces = (wtm) ? TotalWhitePieces : TotalBlackPieces;
  if (do_null && !tree->in_check[ply] && pieces && (pieces > 9 ||
          depth < 7 * PLY)) {
    register BITBOARD save_hash_key;
    int null_depth;

    tree->current_move[ply] = 0;
    tree->phase[ply] = NULL_MOVE;
#if defined(TRACE)
    if (ply <= trace_level)
      SearchTrace(tree, ply, depth, wtm, beta - 1, beta, "Search", 0);
#endif
    null_depth = (depth > 6 * PLY && pieces > 9) ? null_max : null_min;
    if (null_depth) {
      tree->position[ply + 1] = tree->position[ply];
      Rule50Moves(ply + 1)++;
      save_hash_key = HashKey;
      if (EnPassant(ply)) {
        HashEP(EnPassant(ply + 1), HashKey);
        EnPassant(ply + 1) = 0;
      }
      if (depth - null_depth >= PLY)
        value =
            -Search(tree, -beta, 1 - beta, Flip(wtm), depth - null_depth,
            ply + 1, NO_NULL);
      else
        value = -Quiesce(tree, -beta, 1 - beta, Flip(wtm), ply + 1);
      HashKey = save_hash_key;
      if (shared->abort_search || tree->stop)
        return (0);
      if (value >= beta) {
        HashStore(tree, ply, depth, wtm, LOWER, value, mate_threat);
        return (value);
      }
      if (value == -MATE + ply + 2)
        mate_threat = 1;
    }
  }
/*
 ************************************************************
 *                                                          *
 *   if there is no best move from the hash table, and this *
 *   is a PV node, then we need a good move to search       *
 *   first.  while killers and history moves are good, they *
 *   are not "good enough".  the simplest action is to try  *
 *   a shallow search (depth-2) to get a move.  note that   *
 *   when we call Search() with depth-2, it, too, will      *
 *   not have a hash move, and will therefore recursively   *
 *   continue this process, hence the name "internal        *
 *   iterative deepening."                                  *
 *                                                          *
 ************************************************************
 */
  tree->next_status[ply].phase = HASH_MOVE;
  if (tree->hash_move[ply] == 0 && do_null && depth >= 3 * PLY)
    do {
      if (ply & 1) {
        if (alpha != shared->root_alpha || beta != shared->root_beta)
          break;
      } else {
        if (alpha != -shared->root_beta || beta != -shared->root_alpha)
          break;
      }
      tree->current_move[ply] = 0;
      if (depth - 2 * PLY >= PLY)
        value = Search(tree, alpha, beta, wtm, depth - 2 * PLY, ply, DO_NULL);
      else
        value = Quiesce(tree, alpha, beta, wtm, ply);
      if (shared->abort_search || tree->stop)
        return (0);
      if (value <= alpha) {
        if (depth - 2 * PLY >= PLY)
          value = Search(tree, -MATE, beta, wtm, depth - 2 * PLY, ply, DO_NULL);
        else
          value = Quiesce(tree, -MATE, beta, wtm, ply);
        if (shared->abort_search || tree->stop)
          return (0);
        if (value < beta) {
          if ((int) tree->pv[ply - 1].pathl >= ply)
            tree->hash_move[ply] = tree->pv[ply - 1].path[ply];
        } else
          tree->hash_move[ply] = tree->current_move[ply];
      } else if (value < beta) {
        if ((int) tree->pv[ply - 1].pathl >= ply)
          tree->hash_move[ply] = tree->pv[ply - 1].path[ply];
      } else
        tree->hash_move[ply] = tree->current_move[ply];
      tree->last[ply] = tree->last[ply - 1];
      tree->next_status[ply].phase = HASH_MOVE;
    } while (0);
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
  while ((tree->phase[ply] =
          (tree->in_check[ply]) ? NextEvasion(tree, ply, wtm) : NextMove(tree,
              ply, wtm))) {
#if defined(TRACE)
    if (ply <= trace_level)
      SearchTrace(tree, ply, depth, wtm, alpha, beta, "Search",
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
#if !defined(NOFUTILITY)
      tree->fprune = 0;
#endif
      extensions = extended - PLY;
      if (!moves_searched) {
        if (depth + extensions >= PLY) {
          value =
              -Search(tree, -beta, -alpha, Flip(wtm), depth + extensions,
              ply + 1, DO_NULL);
          if (value > alpha && extended < 0)
            value =
                -Search(tree, -beta, -alpha, Flip(wtm), depth - PLY, ply + 1,
                DO_NULL);
        } else
          value = -Quiesce(tree, -beta, -alpha, Flip(wtm), ply + 1);
        if (shared->abort_search || tree->stop) {
          UnmakeMove(tree, ply, tree->current_move[ply], wtm);
          return (0);
        }
      } else {

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
          if (value > alpha && extended < 0)
            value =
                -Search(tree, -alpha - 1, -alpha, Flip(wtm), depth - PLY,
                ply + 1, DO_NULL);
        } else
          value = -Quiesce(tree, -alpha - 1, -alpha, Flip(wtm), ply + 1);
        if (shared->abort_search || tree->stop) {
          UnmakeMove(tree, ply, tree->current_move[ply], wtm);
          return (0);
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
            return (0);
          }
        }
      }
      if (value > alpha) {
        if (value >= beta) {
          Killer(tree, ply, tree->current_move[ply]);
          UnmakeMove(tree, ply, tree->current_move[ply], wtm);
          HashStore(tree, ply, depth, wtm, LOWER, value, mate_threat);
          tree->fail_high++;
          if (!moves_searched)
            tree->fail_high_first++;
          return (value);
        }
        alpha = value;
      }
      moves_searched++;
    } else
      tree->nodes_searched++;
    UnmakeMove(tree, ply, tree->current_move[ply], wtm);
    if (shared->smp_idle && moves_searched &&
        depth >= shared->min_thread_depth * (PLY * ply + depth) / 100) {
      tree->alpha = alpha;
      tree->beta = beta;
      tree->value = alpha;
      tree->wtm = wtm;
      tree->ply = ply;
      tree->depth = depth;
      tree->mate_threat = mate_threat;
      if (Thread(tree)) {
        if (shared->abort_search || tree->stop)
          return (0);
        if (tree->thread_id == 0 && CheckInput())
          Interrupt(ply);
        value = tree->search_value;
        if (value > alpha) {
          if (value >= beta) {
            Killer(tree, ply, tree->current_move[ply]);
            HashStore(tree, ply, depth, wtm, LOWER, value, mate_threat);
            tree->fail_high++;
            return (value);
          }
          alpha = value;
          break;
        }
      }
    }
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
  if (moves_searched == 0) {
    value = (Check(wtm)) ? -(MATE - ply) : DrawScore(wtm);
    if (value >= alpha && value < beta) {
      SavePV(tree, ply, 0);
#if defined(TRACE)
      if (ply <= trace_level)
        printf("Search() no moves!  ply=%d\n", ply);
#endif
    }
    return (value);
  } else {
    if (alpha != o_alpha) {
      memcpy(&tree->pv[ply - 1].path[ply], &tree->pv[ply].path[ply],
          (tree->pv[ply].pathl - ply + 1) * sizeof(int));
      memcpy(&tree->pv[ply - 1].pathh, &tree->pv[ply].pathh, 3);
      tree->pv[ply - 1].path[ply - 1] = tree->current_move[ply - 1];
      Killer(tree, ply, tree->pv[ply].path[ply]);
    }
    HashStore(tree, ply, depth, wtm, (alpha == o_alpha) ? UPPER : EXACT, alpha,
        mate_threat);
    return (alpha);
  }
}

/* last modified 04/18/07 */
/*
 *******************************************************************************
 *                                                                             *
 *   SearchControl() is used to adjust the search depth for the sub-tree below *
 *   this node.  some moves need to be searched deeper to understand the       *
 *   tactical results of playing them.  tactical moves such as checks          *
 *   need to be searched deeper.  in addition, if there is only one legal move *
 *   at this ply, or if a null-move search leads to an instant mate, then      *
 *   is some threat that needs a deeper search to understand fully.            *
 *                                                                             *
 *   additionally, the opposite is also true.  some moves do not deserve as    *
 *   much effort as others, and we try to recognize that here and rather than  *
 *   extending the search depth (and effort) we actually reduce the search     *
 *   depth to save time that can be better spent on other moves.  any move     *
 *   is tactical in nature (captures, checks, passed pawn pushes, and so       *
 *   forth) are not reduced.  normal moves that appear to be "good" are also   *
 *   not reduced, including the hash table "best move", killer moves, and      *
 *   other such moves.  that leaves moves that have not been identified as     *
 *   "good" to be searched with reduced depth.  the final criterion here is    *
 *   that the "history value" must lie below some threshold indicating that    *
 *   this move has never been very good in the current search.                 *
 *                                                                             *
 *******************************************************************************
 */
int SearchControl(TREE * RESTRICT tree, int wtm, int ply, int depth,
    int mate_threat)
{
  register int adjustment = 0, move, square;

/*
 ************************************************************
 *                                                          *
 *   if the null move found that the side on move gets      *
 *   mated by not moving, then there must be some strong    *
 *   threat at this position.  extend the search to make    *
 *   sure it is analyzed carefully.                         *
 *                                                          *
 ************************************************************
 */
  if (mate_threat) {
    adjustment += mate_depth;
    tree->mate_extensions_done++;
  }
/*
 ************************************************************
 *                                                          *
 *   if the move to be made checks the opponent, then we    *
 *   need to remember that he's in check and also extend    *
 *   the depth by one ply for him to get out.               *
 *                                                          *
 ************************************************************
 */
  if (Check(Flip(wtm))) {
    tree->in_check[ply + 1] = 1;
    tree->check_extensions_done++;
    adjustment += incheck_depth;
  } else
    tree->in_check[ply + 1] = 0;
/*
 ************************************************************
 *                                                          *
 *   if there's only one legal move, extend the search one  *
 *   additional ply since this node is very easy to search. *
 *                                                          *
 ************************************************************
 */
#if !defined(LIMITEXT)
  tree->no_limit = 0;
#endif
  if (tree->in_check[ply] && tree->last[ply] - tree->last[ply - 1] == 1) {
    tree->one_reply_extensions_done++;
    adjustment += onerep_depth;
#if !defined(LIMITEXT)
    tree->no_limit = 1;
#endif
  }
  if (adjustment) {
    LimitExtensions(adjustment, ply);
    return (adjustment);
  }
/*
 ************************************************************
 *                                                          *
 *   no extensions were triggered, or we would have exited. *
 *                                                          *
 *   now it's time to try to reduce the search depth if the *
 *   move appears to be "weak".  to reduce the search, the  *
 *   following requirements must be met:                    *
 *                                                          *
 *   (1) we must be in the "REMAINING_MOVES part of the     *
 *       move ordering, so that we have nearly given up on  *
 *       failing high on any move.                          *
 *                                                          *
 *   (2) the remaining search depth left must satisfy the   *
 *       following inequality:                              *
 *                                                          *
 *         depth - PLY - reduce_value < reduce_min_depth    *
 *                                                          *
 *       simply stated, for default settings, there must    *
 *       be at least 3 plies of depth left or we won't      *
 *       reduce since we are too close to the frontier and  *
 *       that leads to tactical mistakes.                   *
 *                                                          *
 *   (3) the current move must not trigger any type of      *
 *       search extension.                                  *
 *                                                          *
 *   (4) the side to move can not be in check;              *
 *                                                          *
 *   (5) the moving piece is not a passed pawn;             *
 *                                                          *
 *   (6) the current move can not affect the material       *
 *       balance, that is it can not be a capture or pawn   *
 *       promotion;                                         *
 *                                                          *
 ************************************************************
 */
  if (tree->phase[ply] != REMAINING_MOVES)
    return (0);
  tree->reductions_attempted++;
  move = tree->current_move[ply];
  square = To(move);
  if (depth - PLY - reduce_value < reduce_min_depth || tree->in_check[ply] ||
      CaptureOrPromote(move))
    return (0);
/*
 ************************************************************
 *                                                          *
 *   check the move to see if a passed pawn is being        *
 *   advanced.                                              *
 *                                                          *
 ************************************************************
 */
  if (Piece(move) == pawn) {
    if (wtm) {
      if (!(mask_pawn_passed_w[square] & BlackPawns))
        return (0);
    } else {
      if (!(mask_pawn_passed_b[square] & WhitePawns))
        return (0);
    }
  }
/*
 ************************************************************
 *                                                          *
 *   move is safe to reduce.                                *
 *                                                          *
 ************************************************************
 */
  tree->reductions_done++;
  return (-reduce_value);
}
