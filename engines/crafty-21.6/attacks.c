#include <stdio.h>
#include <stdlib.h>
#include "chess.h"
#include "data.h"

/* last modified 06/26/99 */
/*
 *******************************************************************************
 *                                                                             *
 *   AttacksTo() is used to produce a BITBOARD which is a map of all squares   *
 *   that directly attack this <square>.  the non-sliding pieces are trivial   *
 *   to detect, but for sliding pieces, we use a bitboard trick.  the idea is  *
 *   to compute the squares a queen would attack, if it was standing on        *
 *   <square> and then look at the last square attacked in each direction to   *
 *   determine if it is a sliding piece that moves in the right direction.  to *
 *   finish up, we simply need to Or() all these attackers together.           *
 *                                                                             *
 *******************************************************************************
 */
BITBOARD AttacksTo(TREE * RESTRICT tree, int square)
{

  return ((w_pawn_attacks[square] & BlackPawns) | (b_pawn_attacks[square] &
          WhitePawns) | (knight_attacks[square] & (BlackKnights | WhiteKnights))
      | (AttacksBishop(square) & BishopsQueens) | (AttacksRook(square) &
          RooksQueens) | (king_attacks[square] & (BlackKing | WhiteKing)));
}

/* last modified 06/26/99 */
/*
 *******************************************************************************
 *                                                                             *
 *   Attacked() is used to determine if <square> is attacked by "wtm".  the    *
 *   algorithm is simple, and is based on the AttacksTo() algorithm, but,      *
 *   rather than returning a bitmap of squares attacking <square> it returns a *
 *   "1" as soon as it finds anything that attacks <square>.                   *
 *                                                                             *
 *******************************************************************************
 */

int Attacked(TREE * RESTRICT tree, int square, int wtm)
{

  if (wtm) {
    if (b_pawn_attacks[square] & WhitePawns)
      return (1);
    if (knight_attacks[square] & WhiteKnights)
      return (1);
    if (AttacksBishop(square) & BishopsQueens & WhitePieces)
      return (1);
    if (AttacksRook(square) & RooksQueens & WhitePieces)
      return (1);
    if (king_attacks[square] & WhiteKing)
      return (1);
  } else {
    if (w_pawn_attacks[square] & BlackPawns)
      return (1);
    if (knight_attacks[square] & BlackKnights)
      return (1);
    if (AttacksBishop(square) & BishopsQueens & BlackPieces)
      return (1);
    if (AttacksRook(square) & RooksQueens & BlackPieces)
      return (1);
    if (king_attacks[square] & BlackKing)
      return (1);
  }
  return (0);
}
