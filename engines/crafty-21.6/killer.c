#include <stdio.h>
#include <stdlib.h>
#include "chess.h"
#include "data.h"

/* last modified 03/01/06 */
/*
 *******************************************************************************
 *                                                                             *
 *   Killer() is used to maintain the two killer moves for each ply.  the most *
 *   recently used killer is always first in the list.                         *
 *                                                                             *
 *******************************************************************************
 */
void Killer(TREE * RESTRICT tree, int ply, int move)
{

/*
 ************************************************************
 *                                                          *
 *   if the best move so far is a capture or a promotion,   *
 *   return, since we try good captures and promotions      *
 *   before searching killer heuristic moves anyway.        *
 *                                                          *
 ************************************************************
 */
  if (CaptureOrPromote(move))
    return;
/*
 ************************************************************
 *                                                          *
 *   now, add the same move to the current killer moves if  *
 *   it is not already there.                               *
 *                                                          *
 ************************************************************
 */
  if (tree->killers[ply].move1 != move) {
    tree->killers[ply].move2 = tree->killers[ply].move1;
    tree->killers[ply].move1 = move;
  }
}
