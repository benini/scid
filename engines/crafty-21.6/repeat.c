#include <stdio.h>
#include <stdlib.h>
#include "chess.h"
#include "data.h"

/* last modified 01/23/03 */
/*
 *******************************************************************************
 *                                                                             *
 *   RepetitionCheck() is used to detect a draw by repetition.  it saves the   *
 *   current position in the repetition list each time it is called.  the list *
 *   contains all positions encountered since the last irreversible move       *
 *   (capture or pawn push).                                                   *
 *                                                                             *
 *   RepetitionCheck() then scans the list to determine if this position has   *
 *   occurred before.  if so, the position will be treated as a draw by        *
 *   Search().   note that for a repetition to happen in the first two plies   *
 *   of the tree, the position has to be repeated three times, while for plies *
 *   beyond two, two repetitions trigger a draw score.                         *
 *                                                                             *
 *   RepetitionCheck() also handles 50-move draws.  the position[] structure   *
 *   countains the count of moves since the last capture or pawn push.  when   *
 *   this value reaches 100 (plies, which is 50 moves) the score is set to     *
 *   DRAW.                                                                     *
 *                                                                             *
 *******************************************************************************
 */
int RepetitionCheck(TREE * RESTRICT tree, int ply)
{
  register int where, thispos;

/*
 ************************************************************
 *                                                          *
 *   if the 50-move rule has been reached, then adjust the  *
 *   score to reflect the impending draw.                   *
 *                                                          *
 ************************************************************
 */
  if (Rule50Moves(ply) > 99)
    return (1);
/*
 ************************************************************
 *                                                          *
 *   insert the board into the next slot in the repetition  *
 *   list.  then scan the list.  we look for the case where *
 *   the position has been seen one time before, unless we  *
 *   are at ply 1 or 2, where we must have seen the same    *
 *   position twice prior to this.                          *
 *                                                          *
 ************************************************************
 */
  thispos = tree->rep_game + ply - 1;
  tree->rep_list[thispos] = HashKey;
  if (ply > 3) {
    int limit = thispos - Rule50Moves(ply);

    for (where = thispos - 2; where >= limit; where -= 2)
      if (HashKey == tree->rep_list[where])
        return (1);
  } else {
    int count = 0;

    for (where = thispos - 2; where >= 0; where -= 2)
      if (HashKey == tree->rep_list[where])
        count++;
    if (count > 1)
      return (1);
  }
  return (0);
}

/* last modified 01/23/03 */
/*
 *******************************************************************************
 *                                                                             *
 *   RepetitionCheckBook() is used to detect a draw by repetition while still  *
 *   in book.  It simply counts two repeats as a draw as there is little sense *
 *   in repeating a position at all in the opening.                            *
 *                                                                             *
 *******************************************************************************
 */
int RepetitionCheckBook(TREE * RESTRICT tree, int ply)
{
  register int where, thispos;

/*
 ************************************************************
 *                                                          *
 *   if the 50-move rule has been reached, then adjust the  *
 *   score to reflect the impending draw.                   *
 *                                                          *
 ************************************************************
 */
  if (Rule50Moves(ply) > 99)
    return (1);
/*
 ************************************************************
 *                                                          *
 *   scan the list.  we look for the case where the         *
 *   position has been seen one time before.                *
 *                                                          *
 ************************************************************
 */
  thispos = tree->rep_game + ply - 1;
  for (where = thispos - 2; where >= 0; where -= 2)
    if (HashKey == tree->rep_list[where])
      return (1);
  return (0);
}

/* last modified 02/15/05 */
/*
 *******************************************************************************
 *                                                                             *
 *   RepetitionDraw() is used to detect a draw by repetition.  this routine is *
 *   only called from Main() and simply scans the complete list searching for  *
 *   exactly three repetitions (two additional repetitions of the current      *
 *   position.)                                                                *
 *                                                                             *
 *******************************************************************************
 */
int RepetitionDraw(TREE * RESTRICT tree, int ply)
{
  register int reps;
  int where;

/*
 ************************************************************
 *                                                          *
 *   if the 50-move rule has been reached, then adjust the  *
 *   score to reflect the impending draw.                   *
 *                                                          *
 ************************************************************
 */
  if (Rule50Moves(ply) > 99)
    return (2);
/*
 ************************************************************
 *                                                          *
 *   scan the repetition list to determine if this position *
 *   has occurred before.                                   *
 *                                                          *
 ************************************************************
 */
  reps = 0;
  for (where = tree->rep_game; where >= 0; where -= 2)
    if (HashKey == tree->rep_list[where])
      reps++;
  return (reps == 3);
}
