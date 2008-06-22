#include <stdio.h>
#include <stdlib.h>
#include "chess.h"
#include "data.h"

/* last modified 06/05/98 */
/*
 *******************************************************************************
 *                                                                             *
 *   Drawn() is used to answer the question "is this position a hopeless draw?"*
 *   several considerations are included in making this decision, but the most *
 *   basic one is simple the remaining material for each side.  if either side *
 *   has pawns, it's not a draw.  with no pawns, equal material is a draw.     *
 *   otherwise, the superior side must have enough material to be able to force*
 *   a mate.                                                                   *
 *                                                                             *
 *******************************************************************************
 */
int Drawn(TREE * RESTRICT tree, int value)
{
/*
 ************************************************************
 *                                                          *
 *   if either side has pawns, the game is not a draw for   *
 *   lack of material.                                      *
 *                                                          *
 ************************************************************
 */
  if (TotalWhitePawns || TotalBlackPawns)
    return (0);
/*
 ************************************************************
 *                                                          *
 *   the search result must indicate a draw also, otherwise *
 *   it could be a tactical win or loss.                    *
 *                                                          *
 ************************************************************
 */
  if (value != DrawScore(wtm))
    return (0);
/*
 ************************************************************
 *                                                          *
 *   if neither side has pawns, and one side has some sort  *
 *   of material superiority, then determine if the winning *
 *   side has enough material to win.                       *
 *                                                          *
 ************************************************************
 */
  if (TotalWhitePieces < 5 && TotalBlackPieces < 5)
    return (2);
  if (TotalWhitePieces == 5 || TotalWhitePieces > 6)
    return (0);
  if (TotalBlackPieces == 5 || TotalBlackPieces > 6)
    return (0);
  if ((TotalWhitePieces == 6 && !WhiteBishops && Material > 0) ||
      (TotalBlackPieces == 6 && !BlackBishops && Material < 0))
    return (2);
/*
 ************************************************************
 *                                                          *
 *   if neither side has pawns, then one side must have     *
 *   some sort of material superiority, otherwise it is a   *
 *   draw.                                                  *
 *                                                          *
 ************************************************************
 */
  if (TotalWhitePieces == TotalBlackPieces)
    return (1);
  return (0);
}
