#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "chess.h"
#include "data.h"

/* last modified 08/07/05 */
/*
 *******************************************************************************
 *                                                                             *
 *   TimeAdjust() is called to adjust timing variables after each program move *
 *   is made.  it simply increments the number of moves made, decrements the   *
 *   amount of time used, and then makes any necessary adjustments based on the*
 *   time controls.                                                            *
 *   next search.                                                              *
 *                                                                             *
 *******************************************************************************
 */
void TimeAdjust(int time_used, PLAYER player)
{
/*
 ************************************************************
 *                                                          *
 *   decrement the number of moves remaining to the next    *
 *   time control.  then subtract the time the program took *
 *   to choose its move from the time remaining.            *
 *                                                          *
 ************************************************************
 */
  if (player == crafty) {
    shared->tc_moves_remaining--;
    shared->tc_time_remaining -=
        (shared->tc_time_remaining >
        time_used) ? time_used : shared->tc_time_remaining;
    if (!shared->tc_moves_remaining) {
      if (shared->tc_sudden_death == 2)
        shared->tc_sudden_death = 1;
      shared->tc_moves_remaining += shared->tc_secondary_moves;
      shared->tc_time_remaining += shared->tc_secondary_time;
      shared->tc_time_remaining_opponent += shared->tc_secondary_time;
      Print(4095, "time control reached\n");
    }
    if (shared->tc_increment)
      shared->tc_time_remaining += shared->tc_increment;
  } else {
    shared->tc_time_remaining_opponent -=
        (shared->tc_time_remaining_opponent >
        time_used) ? time_used : shared->tc_time_remaining_opponent;
    if (shared->tc_increment)
      shared->tc_time_remaining_opponent += shared->tc_increment;
  }
}

/* last modified 08/07/05 */
/*
 *******************************************************************************
 *                                                                             *
 *   TimeCheck() is used to determine when the search should stop.  it uses    *
 *   several conditions to make this determination:  (1) the search time has   *
 *   exceeded the time per move limit;  (2) the value at the root of the tree  *
 *   has not dropped to low.  (3) if the root move was flagged as "easy" and   *
 *   no move has replaced it as best, the search can actually be stopped early *
 *   to save some time on the clock.  if (2) is true, then the time is extended*
 *   based on how far the root value has dropped in an effort to avoid whatever*
 *   is being lost.                                                            *
 *                                                                             *
 *******************************************************************************
 */
int TimeCheck(TREE * RESTRICT tree, int abort)
{
  int time_used;
  int value, last_value;
  int i, ndone;

/*
 ************************************************************
 *                                                          *
 *   first, check to see if we are searching the first move *
 *   at this depth.  if so, and we run out of time, we can  *
 *   abort the search rather than waiting to complete this  *
 *   ply=1 move to see if it's better.                      *
 *                                                          *
 ************************************************************
 */
  if (search_nodes && tree->nodes_searched >= search_nodes)
    return (1);
  if (shared->n_root_moves == 1 && !shared->booking && !annotate_mode &&
      !shared->pondering && shared->iteration_depth > 4)
    return (1);
  ndone = 0;
  for (i = 0; i < shared->n_root_moves; i++)
    if (shared->root_moves[i].status & 128)
      ndone++;
  if (ndone == 1)
    abort = 1;
  if (shared->iteration_depth <= 2)
    return (0);
/*
 ************************************************************
 *                                                          *
 *   now, check to see if we need to "burp" the time to     *
 *   let the operator know the search is progressing and    *
 *   how much time has been used so far.                    *
 *                                                          *
 ************************************************************
 */
  time_used = (ReadClock() - shared->start_time);
  if (tree->nodes_searched > shared->noise_level && shared->display_options & 32
      && time_used > shared->burp) {
    Lock(shared->lock_io);
    if (shared->pondering)
      printf("               %2i   %s%7s?  ", shared->iteration_depth,
          DisplayTime(time_used), tree->remaining_moves_text);
    else
      printf("               %2i   %s%7s*  ", shared->iteration_depth,
          DisplayTime(time_used), tree->remaining_moves_text);
    if (shared->display_options & 32 && shared->display_options & 64)
      printf("%d. ", shared->move_number);
    if ((shared->display_options & 32) && (shared->display_options & 64) &&
        Flip(shared->root_wtm))
      printf("... ");
    printf("%s(%snps)             \r", tree->root_move_text,
        DisplayKM(shared->nodes_per_second));
    shared->burp = (time_used / 1500) * 1500 + 1500;
    fflush(stdout);
    Unlock(shared->lock_io);
  }
  if (shared->pondering || analyze_mode)
    return (0);
  if (time_used > shared->absolute_time_limit)
    return (1);
  if (shared->easy_move && !shared->search_time_limit) {
    if (shared->time_limit > 100 && time_used >= shared->time_limit / 3)
      return (1);
  }
  if (time_used < shared->time_limit)
    return (0);
  if (shared->search_time_limit)
    return (1);
/*
 ************************************************************
 *                                                          *
 *   ok.  we have used "time_limit" at this point.  now the *
 *   question is, can we stop the search?                   *
 *                                                          *
 *   first, make sure that we have actually found a score   *
 *   at the root of the tree.  if not, we can safely stop   *
 *   searching without wasting any more time.               *
 *                                                          *
 ************************************************************
 */
  if (shared->root_value == shared->root_alpha &&
      !(shared->root_moves[0].status & 7) && ndone == 1)
    return (1);
/*
 ************************************************************
 *                                                          *
 *   we have a score at the root of the tree, if the        *
 *   evaluation is not significantly worse than the last    *
 *   evaluation (from the previous iteration...) then we    *
 *   safely stop the search.  note also that if the current *
 *   evaluation is quite a bit worse, but we are still way  *
 *   ahead, we can still avoid using extra time.            *
 *                                                          *
 ************************************************************
 */
  value = shared->root_value;
  last_value = shared->last_root_value;
  if ((value >= last_value - 24 && !(shared->root_moves[0].status & 7)) ||
      (value > 350 && value >= last_value - 50)) {
    if (time_used > shared->time_limit * 2)
      return (1);
    else
      return (abort);
  }
/*
 ************************************************************
 *                                                          *
 *   we are in trouble at the root.  depending on how much  *
 *   the score has dropped, increase the search time limit  *
 *   to try and correct the problem.  for a positional drop *
 *   we can double the search time (this is for a serious   *
 *   drop, of course).                                      *
 *                                                          *
 ************************************************************
 */
  if (time_used < shared->time_limit * 2.5 &&
      time_used + 500 < shared->tc_time_remaining)
    return (0);
  if ((value >= last_value - 67 && !(shared->root_moves[0].status & 7)) ||
      value > 550)
    return (abort);
/*
 ************************************************************
 *                                                          *
 *   we are in really serious trouble at the root, losing   *
 *   material.  increase the time limit to 6X the original  *
 *   target, as losing material is tantamount to losing the *
 *   game anyway.                                           *
 *                                                          *
 ************************************************************
 */
  if (time_used < shared->time_limit * 7 &&
      time_used + 500 < shared->tc_time_remaining)
    return (0);
  return (1);
}

/* last modified 10/10/05 */
/*
 *******************************************************************************
 *                                                                             *
 *   TimeSet() is called to set the two variables "time_limit" and             *
 *   "absolute_time_limit" which controls the amount of time taken by the      *
 *   iterated search.  it simply takes the timing controls as set by the user  *
 *   and uses these values to calculate how much time should be spent on the   *
 *   next search.                                                              *
 *                                                                             *
 *******************************************************************************
 */
void TimeSet(int search_type)
{
  static const float behind[6] = { 32.0, 16.0, 8.0, 4.0, 2.0, 1.5 };
  static const int reduce[6] = { 96, 48, 24, 12, 6, 3 };
  int i, mult = 0, extra = 0;
  int surplus, average;
  int simple_average;

  surplus = 0;
  average = 0;
/*
 ************************************************************
 *                                                          *
 *   check to see if we are in a sudden-death type of time  *
 *   control.  if so, we have a fixed amount of time        *
 *   remaining.  set the search time accordingly and exit.  *
 *                                                          *
 ************************************************************
 */
  if (shared->tc_sudden_death == 1) {
    if (shared->tc_increment) {
      shared->time_limit = (shared->tc_time_remaining -
//TLR        shared->tc_operator_time * shared->tc_moves_remaining) / 35 +
          shared->tc_operator_time * shared->tc_moves_remaining) /
          (ponder ? 23 : 28) + shared->tc_increment;
/*
      if (shared->tc_time_remaining < 3000)
        shared->time_limit = shared->tc_increment;
      if (shared->tc_time_remaining < 1500)
*/
      if (shared->tc_time_remaining < 600)
        shared->time_limit = shared->tc_increment;
      if (shared->tc_time_remaining < 300)
        shared->time_limit /= 2;

      shared->absolute_time_limit = shared->tc_time_remaining / 2;
    } else {
//TLR     shared->time_limit = shared->tc_time_remaining / 40;
      shared->time_limit = shared->tc_time_remaining / (ponder ? 29 : 35);
      shared->absolute_time_limit =
          Min(shared->time_limit * 6, shared->tc_time_remaining / 2);
    }
  }
/*
 ************************************************************
 *                                                          *
 *   we are not in a sudden_death situation.  we now have   *
 *   two choices:  if the program has saved enough time to  *
 *   meet the surplus requirement, then we simply divide    *
 *   the time left evenly among the moves left.  if we      *
 *   haven't yet saved up a cushion so that "fail-lows"     *
 *   have extra time to find a solution, we simply take the *
 *   number of moves divided into the total time less the   *
 *   necessary operator time as the target.                 *
 *                                                          *
 ************************************************************
 */
  else {
    if (shared->move_number <= shared->tc_moves)
      simple_average =
          (shared->tc_time -
          (shared->tc_operator_time * shared->tc_moves_remaining)) /
          shared->tc_moves;
    else
      simple_average =
          (shared->tc_secondary_time -
          (shared->tc_operator_time * shared->tc_moves_remaining)) /
          shared->tc_secondary_moves;
    surplus =
        Max(shared->tc_time_remaining -
        (shared->tc_operator_time * shared->tc_moves_remaining) -
        simple_average * shared->tc_moves_remaining, 0);
    average =
        (shared->tc_time_remaining -
        (shared->tc_operator_time * shared->tc_moves_remaining) +
        shared->tc_moves_remaining * shared->tc_increment)
        / shared->tc_moves_remaining;
    if (surplus < shared->tc_safety_margin)
      shared->time_limit =
          (average < simple_average) ? average : simple_average;
    else
      shared->time_limit =
          (average < 2.0 * simple_average) ? average : 2.0 * simple_average;
  }
  if (surplus < 0)
    surplus = 0;
  if (shared->tc_increment > 200 && shared->moves_out_of_book < 2)
    shared->time_limit *= 1.2;
  if (shared->time_limit <= 0)
    shared->time_limit = 5;
  shared->absolute_time_limit =
      shared->time_limit + surplus / 2 + ((shared->tc_time_remaining -
          shared->tc_operator_time * shared->tc_moves_remaining) / 4);
  if (shared->absolute_time_limit > 7 * shared->time_limit)
    shared->absolute_time_limit = 7 * shared->time_limit;
  if (shared->absolute_time_limit > shared->tc_time_remaining / 2)
    shared->absolute_time_limit = shared->tc_time_remaining / 2;
/*
 ************************************************************
 *                                                          *
 *  the "usage" option can be used to force the time limit  *
 *  higher or lower than normal.  the new "timebook"        *
 *  command can also modify the target time making the      *
 *  program use more time early in the game as it exits the *
 *  book, knowing it will save time later on by ponder hits *
 *  and instant moves.                                      *
 *                                                          *
 ************************************************************
 */
  if (usage_level)
    shared->time_limit *= 1.0 + usage_level / 100.0;
  if (!ponder)
    shared->time_limit = 3 * shared->time_limit / 4;
  if (shared->first_nonbook_factor &&
      shared->moves_out_of_book < shared->first_nonbook_span) {
    mult =
        (shared->first_nonbook_span - shared->moves_out_of_book +
        1) * shared->first_nonbook_factor;
    extra = shared->time_limit * mult / shared->first_nonbook_span / 100;
    shared->time_limit += extra;
  }
/*
 ************************************************************
 *                                                          *
 *  this code is used to handle the case where someone is   *
 *  trying to "blitz" crafty by reaching a position where   *
 *  things are locked up, and then just shuffling pieces    *
 *  back and forth.  when crafty reaches the point where it *
 *  has less than 3/4 of the time the opponent has, it      *
 *  starts decreasing the target time.  at 1/2, it          *
 *  decreases it further.                                   *
 *                                                          *
 ************************************************************
 */
  if (mode != tournament_mode && !shared->computer_opponent) {
    for (i = 0; i < 6; i++) {
      if ((float) shared->tc_time_remaining * behind[i] <
          (float) shared->tc_time_remaining_opponent) {
        shared->time_limit = shared->time_limit / reduce[i];
        Print(128, "crafty is behind %4.1f on time, reducing by 1/%d.\n",
            behind[i], reduce[i]);
        break;
      }
    }
    if (shared->tc_increment == 0 &&
        shared->tc_time_remaining_opponent > shared->tc_time_remaining) {
      if (shared->tc_time_remaining < 3000)
        shared->time_limit /= 2;
      if (shared->tc_time_remaining < 2000)
        shared->time_limit /= 2;
      if (shared->tc_time_remaining < 1000)
        shared->time_limit = 1;
    }
  }
/*
 ************************************************************
 *                                                          *
 *   if the operator has set an absolute search time limit  *
 *   already, then we simply copy this value and return.    *
 *                                                          *
 ************************************************************
 */
  if (shared->search_time_limit) {
    shared->time_limit = shared->search_time_limit;
    shared->absolute_time_limit = shared->time_limit;
  }
  if (search_type == puzzle || shared->booking) {
    shared->time_limit /= 10;
    shared->absolute_time_limit = shared->time_limit * 3;
  }

  if (!shared->tc_sudden_death && !shared->search_time_limit &&
      shared->time_limit > 3 * shared->tc_time / shared->tc_moves)
    shared->time_limit = 3 * shared->tc_time / shared->tc_moves;
  if (search_type != puzzle) {
    if (!shared->tc_sudden_death)
      Print(128, "              time surplus %s  ", DisplayTime(surplus));
    else
      Print(128, "              ");
    Print(128, "time limit %s", DisplayTimeKibitz(shared->time_limit));
    Print(128, " (+%s)", DisplayTimeKibitz(extra));
    Print(128, " (%s)", DisplayTimeKibitz(shared->absolute_time_limit));
    if (fabs(usage_level) > 0.0001) {
      Print(128, "/");
      Print(128, "(%d)", usage_level);
    }
    if (shared->easy_move)
      Print(128, " [easy move]");
    Print(128, "\n");
  }
  if (shared->time_limit <= 1) {
    shared->time_limit = 1;
    usage_level = 0;
  }
}
