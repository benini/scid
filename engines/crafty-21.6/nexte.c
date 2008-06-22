#include <stdio.h>
#include <stdlib.h>
#include "chess.h"
#include "data.h"

/* last modified 01/22/04 */
/*
 *******************************************************************************
 *                                                                             *
 *   NextEvasion() is used to select the next move from the current move list  *
 *   when the king is in check.  it tries the following things to get out of   *
 *   check:                                                                    *
 *                                                                             *
 *     1.  if one piece is attacking the king (aren't bitboard attack vectors  *
 *         wonderful?) try to capture the checking piece first.  we use the    *
 *         normal capture logic that tries winning or even captures first, and *
 *         postpones losing captures until other safe moves have been tried.   *
 *                                                                             *
 *     2.  try moving the king to a safe square (one that is not already under *
 *         attack, otherwise this would do nothing...)                         *
 *                                                                             *
 *     3.  If more than one piece is attacking the king, we can give up as we  *
 *         can't do anything but move the king, which we've already tried.     *
 *         therefore, assuming one attacker, if it's a knight, again we are    *
 *         done as we can't interpose anything.  if it's a bishop, rook, or    *
 *         queen, try interposing.  we simply have to find the attacker (easy) *
 *         the attackee (the king's square, also easy) and use the precomputed *
 *         mask to produce a bit vector of the squares between these two       *
 *         squares.  then pass this to GenerateCheckEvasions() as targets      *
 *         and we have all interposing moves.  of course, we still try them    *
 *         in "sane" order of safe followed by any.                            *
 *                                                                             *
 *******************************************************************************
 */
int NextEvasion(TREE * RESTRICT tree, int ply, int wtm)
{
  register int *movep, *sortv;

  switch (tree->next_status[ply].phase) {
/*
 ************************************************************
 *                                                          *
 *   first generate all legal moves by using the special    *
 *   GenerateCheckEvasions() function, so we can determine  *
 *   if this is a one-legal-reply-to-check position.        *
 *                                                          *
 ************************************************************
 */
  case HASH_MOVE:
    tree->last[ply] =
        GenerateCheckEvasions(tree, ply, wtm, tree->last[ply - 1]);
/*
 ************************************************************
 *                                                          *
 *   now try the transposition table move (which might be   *
 *   the principal variation move as we first move down the *
 *   tree).                                                 *
 *                                                          *
 ************************************************************
 */
    if (tree->hash_move[ply]) {
      tree->next_status[ply].phase = SORT_ALL_MOVES;
      tree->current_move[ply] = tree->hash_move[ply];
      if (ValidMove(tree, ply, wtm, tree->current_move[ply]))
        return (HASH_MOVE);
#if defined(DEBUG)
      else
        Print(128, "bad move from hash table, ply=%d\n", ply);
#endif
    }
/*
 ************************************************************
 *                                                          *
 *   now sort the moves based on the expected gain or loss. *
 *   this is deferred until now to see if the hash move is  *
 *   good enough to produce a cutoff and avoid this work.   *
 *                                                          *
 ************************************************************
 */
  case SORT_ALL_MOVES:
    tree->next_status[ply].phase = REMAINING_MOVES;
    if (tree->hash_move[ply]) {
      for (movep = tree->last[ply - 1], sortv = tree->sort_value;
          movep < tree->last[ply]; movep++, sortv++)
        if (*movep == tree->hash_move[ply]) {
          *sortv = -999999;
          *movep = 0;
        } else {
          if (p_values[Piece(*movep) + 7] < p_values[Captured(*movep) + 7])
            *sortv =
                p_values[Captured(*movep) + 7] - p_values[Piece(*movep) + 7];
          else
            *sortv = Swap(tree, From(*movep), To(*movep), wtm);
        }
    } else {
      for (movep = tree->last[ply - 1], sortv = tree->sort_value;
          movep < tree->last[ply]; movep++, sortv++)
        if (p_values[Piece(*movep) + 7] < p_values[Captured(*movep) + 7])
          *sortv = p_values[Captured(*movep) + 7] - p_values[Piece(*movep) + 7];
        else
          *sortv = Swap(tree, From(*movep), To(*movep), wtm);
    }
/*
 ************************************************************
 *                                                          *
 *   this is a simple insertion sort algorithm.  it seems   *
 *   be no faster than a normal bubble sort, but using this *
 *   eliminated a lot of explaining about "why?". :)        *
 *                                                          *
 ************************************************************
 */
    if (tree->last[ply] > tree->last[ply - 1] + 1) {
      int temp1, temp2, *tmovep, *tsortv;
      int *end;

      sortv = tree->sort_value + 1;
      end = tree->last[ply];
      for (movep = tree->last[ply - 1] + 1; movep < end; movep++, sortv++) {
        temp1 = *movep;
        temp2 = *sortv;
        tmovep = movep - 1;
        tsortv = sortv - 1;
        while (tmovep >= tree->last[ply - 1] && *tsortv < temp2) {
          *(tsortv + 1) = *tsortv;
          *(tmovep + 1) = *tmovep;
          tmovep--;
          tsortv--;
        }
        *(tmovep + 1) = temp1;
        *(tsortv + 1) = temp2;
      }
    }
    tree->next_status[ply].last = tree->last[ply - 1];
/*
 ************************************************************
 *                                                          *
 *   now try the rest of the set of moves.                  *
 *                                                          *
 ************************************************************
 */
  case REMAINING_MOVES:
    for (; tree->next_status[ply].last < tree->last[ply];
        tree->next_status[ply].last++)
      if ((*tree->next_status[ply].last)) {
        tree->current_move[ply] = *tree->next_status[ply].last++;
        return (REMAINING_MOVES);
      }
    return (NONE);

  default:
    printf("oops!  next_status.phase is bad! [evasion %d]\n",
        tree->next_status[ply].phase);
    return (NONE);
  }
}
