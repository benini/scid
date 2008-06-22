#include <stdio.h>
#include <stdlib.h>
#include "chess.h"
#include "data.h"

/* last modified 11/15/06 */
/*
 *******************************************************************************
 *                                                                             *
 *   Swap() is used to analyze capture moves to see whether or not they appear *
 *   to be profitable.  the basic algorithm is extremely fast since it uses the*
 *   bitmaps to determine which squares are attacking the [target] square.     *
 *                                                                             *
 *   the algorithm is quite simple.  using the attack bitmaps, we enumerate all*
 *   the pieces that are attacking [target] for either side.  then we simply   *
 *   use the lowest piece (value) for the correct side to capture on [target]. *
 *   we continually "flip" sides taking the lowest piece each time.            *
 *                                                                             *
 *   as a piece is used, if it is a sliding piece (pawn, bishop, rook or queen)*
 *   we remove the piece, then generate moves of bishop/queen or rook/queen    *
 *   and then add those in to the attackers, removing any attacks that have    *
 *   already been used.                                                        *
 *                                                                             *
 *******************************************************************************
 */
int Swap(TREE * RESTRICT tree, int source, int target, int wtm)
{
  register BITBOARD attacks, temp = 0, occupied;
  register int attacked_piece;
  register int piece;
  register int color, nc = 1;
  int swap_list[32];
  const int pval[8] = { 0, 100, 300, 9900, 0, 300, 500, 900 };

/*
 ************************************************************
 *                                                          *
 *   determine which squares attack <target> for each side. *
 *   initialize by placing the piece on <target> first in   *
 *   the list as it is being captured to start things off.  *
 *                                                          *
 ************************************************************
 */
  occupied = Occupied;
  attacks = AttacksTo(tree, target);
  attacked_piece = p_values[PcOnSq(target) + 7];
/*
 ************************************************************
 *                                                          *
 *   the first piece to capture on <target> is the piece    *
 *   standing on <source>.                                  *
 *                                                          *
 ************************************************************
 */
  color = Flip(wtm);
  swap_list[0] = attacked_piece;
  piece = Abs(PcOnSq(source));
  attacked_piece = pval[piece];
  Clear(source, occupied);
  if (piece & 4 || piece == 1) {
    if (Abs(directions[source][target]) == 7 ||
        Abs(directions[source][target]) == 9)
      attacks |= AttacksBishopSpecial(target, occupied) & BishopsQueens;
    if (Abs(directions[source][target]) == 1 ||
        Abs(directions[source][target]) == 8)
      attacks |= AttacksRookSpecial(target, occupied) & RooksQueens;
  }
  attacks &= occupied;
/*
 ************************************************************
 *                                                          *
 *   now pick out the least valuable piece for the correct  *
 *   side that is bearing on <target>.  as we find one, we  *
 *   call SwapXray() to add the piece behind this piece     *
 *   that is indirectly bearing on <target> (if any).       *
 *                                                          *
 ************************************************************
 */
  while (attacks) {
    if (color) {
      if ((temp = WhitePawns & attacks))
        piece = pawn;
      else if ((temp = WhiteKnights & attacks))
        piece = knight;
      else if ((temp = WhiteBishops & attacks))
        piece = bishop;
      else if ((temp = WhiteRooks & attacks))
        piece = rook;
      else if ((temp = WhiteQueens & attacks))
        piece = queen;
      else if ((temp = WhiteKing & attacks))
        piece = king;
      else
        break;
    } else {
      if ((temp = BlackPawns & attacks))
        piece = pawn;
      else if ((temp = BlackKnights & attacks))
        piece = knight;
      else if ((temp = BlackBishops & attacks))
        piece = bishop;
      else if ((temp = BlackRooks & attacks))
        piece = rook;
      else if ((temp = BlackQueens & attacks))
        piece = queen;
      else if ((temp = BlackKing & attacks))
        piece = king;
      else
        break;
    }
    temp &= -temp;
    occupied ^= temp;
    if (piece & 4 || piece == 1) {
      if (piece & 1)
        attacks |= AttacksBishopSpecial(target, occupied) & BishopsQueens;
      if (piece & 2)
        attacks |= AttacksRookSpecial(target, occupied) & RooksQueens;
    }
    attacks &= occupied;
/*
 ************************************************************
 *                                                          *
 *   now we know there is a piece attacking the last        *
 *   capturing piece.  add it to the swap list and repeat   *
 *   until one side has no more captures.                   *
 *                                                          *
 ************************************************************
 */
    swap_list[nc] = -swap_list[nc - 1] + attacked_piece;
    attacked_piece = pval[piece];
    nc++;
    color = Flip(color);
  }
/*
 ************************************************************
 *                                                          *
 *   starting at the end of the sequence of values, use a   *
 *   "minimax" like procedure to decide where the captures  *
 *   will stop.                                             *
 *                                                          *
 ************************************************************
 */
  while (--nc)
    if (swap_list[nc] > -swap_list[nc - 1])
      swap_list[nc - 1] = -swap_list[nc];
  return (swap_list[0]);
}
