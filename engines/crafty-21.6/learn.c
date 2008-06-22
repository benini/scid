#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>
#include <string.h>
#include "chess.h"
#include "data.h"
#if defined(UNIX)
#  include <unistd.h>
#endif

/* last modified 07/06/06 */
/*
 *******************************************************************************
 *                                                                             *
 *   LearnBook() is used to accumulate the evaluations for the first N moves   *
 *   out of book.  after these moves have been played, the evaluations are then*
 *   used to decide whether the last book move played was a reasonable choice  *
 *   or not.  (N is set by the #define LEARN_INTERVAL definition.)             *
 *                                                                             *
 *   there are three cases to be handled.  (1) if the evaluation is bad right  *
 *   out of book, or it drops enough to be considered a bad line, then the book*
 *   move will have its "learn" value reduced to discourage playing this move  *
 *   again.  (2) if the evaluation is even after N moves, then the learn       *
 *   value will be increased, but by a relatively modest amount, so that a few *
 *   even results will offset one bad result.  (3) if the evaluation is very   *
 *   good after N moves, the learn value will be increased by a large amount   *
 *   so that this move will be favored the next time the game is played.       *
 *                                                                             *
 *******************************************************************************
 */
void LearnBook(TREE * RESTRICT tree, int wtm, int search_value,
    int search_depth, int lv, int force)
{
  int nplies = 0, thisply = 0;
  unsigned char buf32[4];

/*
 ************************************************************
 *                                                          *
 *   if we have not been "out of book" for N moves, all     *
 *   we need to do is take the search evaluation for the    *
 *   search just completed and tuck it away in the book     *
 *   learning array (book_learn_eval[]) for use later.      *
 *                                                          *
 ************************************************************
 */
  if (!book_file)
    return;
  if (!(learning & book_learning) && force != 2)
    return;
  if (!(learning & result_learning) && force == 2)
    return;
  if (shared->moves_out_of_book <= LEARN_INTERVAL && !force) {
    if (shared->moves_out_of_book) {
      book_learn_eval[shared->moves_out_of_book - 1] = search_value;
      book_learn_depth[shared->moves_out_of_book - 1] = search_depth;
    }
  }
/*
 ************************************************************
 *                                                          *
 *   check the evaluations we've seen so far.  if they are  *
 *   within reason (+/- 1/3 of a pawn or so) we simply keep *
 *   playing and leave the book alone.  if the eval is much *
 *   better or worse, we need to update the learning count. *
 *                                                          *
 ************************************************************
 */
  else if (shared->moves_out_of_book == LEARN_INTERVAL + 1 || force) {
    int i, j, learn_value, cluster;
    int interval;
    int best_eval = -999999, best_eval_p = 0;
    int worst_eval = 999999, worst_eval_p = 0;
    int best_after_worst_eval = -999999, worst_after_best_eval = 999999;
    float book_learn[64], t_learn_value;

    if (shared->moves_out_of_book < 1)
      return;
    Print(128, "LearnBook() executed\n");
    if (force != 2)
      learning &= ~book_learning;
    else
      learning &= ~result_learning;
    interval = Min(LEARN_INTERVAL, shared->moves_out_of_book);
    if (interval < 2)
      return;

    for (i = 0; i < interval; i++) {
      if (book_learn_eval[i] > best_eval) {
        best_eval = book_learn_eval[i];
        best_eval_p = i;
      }
      if (book_learn_eval[i] < worst_eval) {
        worst_eval = book_learn_eval[i];
        worst_eval_p = i;
      }
    }
    if (best_eval_p < interval - 1) {
      for (i = best_eval_p; i < interval; i++)
        if (book_learn_eval[i] < worst_after_best_eval)
          worst_after_best_eval = book_learn_eval[i];
    } else
      worst_after_best_eval = book_learn_eval[interval - 1];

    if (worst_eval_p < interval - 1) {
      for (i = worst_eval_p; i < interval; i++)
        if (book_learn_eval[i] > best_after_worst_eval)
          best_after_worst_eval = book_learn_eval[i];
    } else
      best_after_worst_eval = book_learn_eval[interval - 1];

#if defined(DEBUG)
    Print(128, "Learning analysis ...\n");
    Print(128, "worst=%d  best=%d  baw=%d  wab=%d\n", worst_eval, best_eval,
        best_after_worst_eval, worst_after_best_eval);
    for (i = 0; i < interval; i++)
      Print(128, "%d(%d) ", book_learn_eval[i], book_learn_depth[i]);
    Print(128, "\n");
#endif

/*
 ************************************************************
 *                                                          *
 *   we now have the best eval for the first N moves out    *
 *   of book, the worst eval for the first N moves out of   *
 *   book, and the worst eval that follows the best eval.   *
 *   this will be used to recognize the following cases of  *
 *   results that follow a book move:                       *
 *                                                          *
 ************************************************************
 */
/*
 ************************************************************
 *                                                          *
 *   (1) the best score is very good, and it doesn't drop   *
 *   after following the game further.  this case detects   *
 *   those moves in book that are "good" and should be      *
 *   played whenever possible.                              *
 *                                                          *
 ************************************************************
 */
    if (best_eval == best_after_worst_eval) {
      learn_value = best_eval;
      for (i = 0; i < interval; i++)
        if (learn_value == book_learn_eval[i])
          search_depth = Max(search_depth, book_learn_depth[i]);
    }
/*
 ************************************************************
 *                                                          *
 *   (2) the worst score is bad, and doesn't improve any    *
 *   after the worst point, indicating that the book move   *
 *   chosen was "bad" and should be avoided in the future.  *
 *                                                          *
 ************************************************************
 */
    else if (worst_eval == worst_after_best_eval) {
      learn_value = worst_eval;
      for (i = 0; i < interval; i++)
        if (learn_value == book_learn_eval[i])
          search_depth = Max(search_depth, book_learn_depth[i]);
    }
/*
 ************************************************************
 *                                                          *
 *   (3) things seem even out of book and remain that way   *
 *   for N moves.  we will just average the 10 scores and   *
 *   use that as an approximation.                          *
 *                                                          *
 ************************************************************
 */
    else {
      learn_value = 0;
      search_depth = 0;
      for (i = 0; i < interval; i++) {
        learn_value += book_learn_eval[i];
        search_depth += book_learn_depth[i];
      }
      learn_value /= interval;
      search_depth /= interval;
    }
    if (!lv) {
      learn_value =
          LearnFunction(learn_value, search_depth,
          crafty_rating - opponent_rating, learn_value < 0);
      learn_value *= (shared->crafty_is_white) ? 1 : -1;
    } else
      learn_value = search_value;
/*
 ************************************************************
 *                                                          *
 *   now we build a vector of book learning results.  we    *
 *   give every book move below the last point where there  *
 *   were alternatives 100% of the learned score.  We give  *
 *   the book move played at that point 100% of the learned *
 *   score as well.  then we divide the learned score by    *
 *   the number of alternatives, and propagate this score   *
 *   back until there was another alternative, where we do  *
 *   this again and again until we reach the top of the     *
 *   book tree.                                             *
 ************************************************************
 */
    t_learn_value = ((float) learn_value) / 100.0;
    for (i = 0; i < 64; i++)
      if (learn_nmoves[i] > 1)
        nplies++;
    for (i = 0; i < 64; i++) {
      if (learn_nmoves[i] > 1)
        thisply++;
      book_learn[i] = t_learn_value * (float) thisply / (float) nplies;
    }
/*
 ************************************************************
 *                                                          *
 *   now find the appropriate cluster, find the key we were *
 *   passed, and update the resulting learn value.          *
 *                                                          *
 ************************************************************
 */
    for (i = 0; i < 64 && learn_seekto[i]; i++) {
      if (learn_seekto[i] > 0) {
        fseek(book_file, learn_seekto[i], SEEK_SET);
        fread(buf32, 4, 1, book_file);
        cluster = BookIn32(buf32);
        BookClusterIn(book_file, cluster, book_buffer);
        for (j = 0; j < cluster; j++)
          if (!(learn_key[i] ^ book_buffer[j].position))
            break;
        if (j >= cluster)
          return;
        if (fabs(book_buffer[j].learn) < 0.0001)
          book_buffer[j].learn = book_learn[i];
        else
          book_buffer[j].learn = (book_buffer[j].learn + book_learn[i]) / 2.0;
        fseek(book_file, learn_seekto[i] + 4, SEEK_SET);
        BookClusterOut(book_file, cluster, book_buffer);
        fflush(book_file);
      }
    }
  }
}

/* last modified 08/07/05 */
/*
 *******************************************************************************
 *                                                                             *
 *   LearnFunction() is called to compute the adjustment value added to the    *
 *   learn counter in the opening book.  it takes three pieces of information  *
 *   into consideration to do this:  the search value, the search depth that   *
 *   produced this value, and the rating difference (Crafty-opponent) so that  *
 *   + numbers means Crafty is expected to win, - numbers mean Crafty is ex-   *
 *   pected to lose.                                                           *
 *                                                                             *
 *******************************************************************************
 */
int LearnFunction(int sv, int search_depth, int rating_difference,
    int trusted_value)
{
  static const float rating_mult_t[11] = { .00625, .0125, .025, .05, .075, .1,
    0.15, 0.2, 0.25, 0.3, 0.35
  };
  static const float rating_mult_ut[11] = { .25, .2, .15, .1, .05, .025, .012,
    .006, .003, .001
  };
  float multiplier;
  int sd, rd;

  sd = Max(Min(search_depth, 19), 0);
  rd = Max(Min(rating_difference / 200, 5), -5) + 5;
  if (trusted_value)
    multiplier = rating_mult_t[rd] * sd;
  else
    multiplier = rating_mult_ut[rd] * sd;
  sv = Max(Min(sv, 600), -600);
  return ((int) (sv * multiplier));
}
