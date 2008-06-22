#include <stdio.h>
#include <stdlib.h>
#include "chess.h"
#include "data.h"

/* last modified 03/22/01 */
/*
 *******************************************************************************
 *                                                                             *
 *   ValidMove() is used to verify that a move is valid.  it is primarily used *
 *   to confirm that a move retrieved from the transposition/refutation table  *
 *   is valid in the current position by checking the move against the current *
 *   chess board, castling status, en passant status, etc.                     *
 *                                                                             *
 *******************************************************************************
 */
int ValidMove(TREE * RESTRICT tree, int ply, int wtm, int move)
{
/*
 ************************************************************
 *                                                          *
 *   make sure that the piece on <from> is the right color. *
 *                                                          *
 ************************************************************
 */
  if (wtm) {
    if (PcOnSq(From(move)) != Piece(move))
      return (0);
  } else {
    if (PcOnSq(From(move)) != -Piece(move))
      return (0);
  }
  switch (Piece(move)) {
/*
 ************************************************************
 *                                                          *
 *   null-moves are caught as it is possible for a killer   *
 *   move entry to be zero at certain times.                *
 *                                                          *
 ************************************************************
 */
  case none:
    return (0);
/*
 ************************************************************
 *                                                          *
 *   king moves are validated here if the king is moving    *
 *   two squares at one time (castling moves).  otherwise   *
 *   fall into the normal piece validation routine below.   *
 *   for castling moves, we need to verify that the         *
 *   castling status is correct to avoid "creating" a new   *
 *   rook or king.                                          *
 *                                                          *
 ************************************************************
 */
  case king:
    if (abs(From(move) - To(move)) == 2) {
      if (wtm) {
        if (WhiteCastle(ply) > 0) {
          if (To(move) == C1) {
            if ((!(WhiteCastle(ply) & 2)) || (Occupied & mask_white_OOO) ||
                (AttacksTo(tree, C1) & BlackPieces) ||
                (AttacksTo(tree, D1) & BlackPieces) ||
                (AttacksTo(tree, E1) & BlackPieces))
              return (0);
          } else if (To(move) == G1) {
            if ((!(WhiteCastle(ply) & 1)) || (Occupied & mask_white_OO) ||
                (AttacksTo(tree, E1) & BlackPieces) ||
                (AttacksTo(tree, F1) & BlackPieces) ||
                (AttacksTo(tree, G1) & BlackPieces))
              return (0);
          }
        } else
          return (0);
      } else {
        if (BlackCastle(ply) > 0) {
          if (To(move) == C8) {
            if ((!(BlackCastle(ply) & 2)) || (Occupied & mask_black_OOO) ||
                (AttacksTo(tree, C8) & WhitePieces) ||
                (AttacksTo(tree, D8) & WhitePieces) ||
                (AttacksTo(tree, E8) & WhitePieces))
              return (0);
          }
          if (To(move) == 62) {
            if ((!(BlackCastle(ply) & 1)) || (Occupied & mask_black_OO) ||
                (AttacksTo(tree, E8) & WhitePieces) ||
                (AttacksTo(tree, F8) & WhitePieces) ||
                (AttacksTo(tree, G8) & WhitePieces))
              return (0);
          }
        } else
          return (0);
      }
      return (1);
    }
    break;
/*
 ************************************************************
 *                                                          *
 *   check for a normal pawn advance.                       *
 *                                                          *
 ************************************************************
 */
  case pawn:
    if (abs(From(move) - To(move)) == 8) {
      if (wtm) {
        if ((From(move) < To(move)) && !PcOnSq(To(move)))
          return (1);
      } else {
        if ((From(move) > To(move)) && !PcOnSq(To(move)))
          return (1);
      }
      return (0);
    } else if (abs(From(move) - To(move)) == 16) {
      if (wtm) {
        if (!PcOnSq(To(move) - 8) && !PcOnSq(To(move)))
          return (1);
      } else {
        if (!PcOnSq(To(move) + 8) && !PcOnSq(To(move)))
          return (1);
      }
      return (0);
    }
    if (!Captured(move))
      return (0);

/*
 ************************************************************
 *                                                          *
 *   check for an en passant capture which is somewhat      *
 *   unusual in that the [to] square does not contain the   *
 *   pawn being captured.  make sure that the pawn being    *
 *   captured advanced two ranks the previous move.         *
 *                                                          *
 ************************************************************
 */
    if (wtm) {
      if ((PcOnSq(To(move)) == 0) && (PcOnSq(To(move) - 8) == -pawn) &&
          (EnPassantTarget(ply) & SetMask(To(move))))
        return (1);
    } else {
      if ((PcOnSq(To(move)) == 0) && (PcOnSq(To(move) + 8) == pawn) &&
          (EnPassantTarget(ply) & SetMask(To(move))))
        return (1);
    }
/*
 ************************************************************
 *                                                          *
 *   normal moves are all checked the same way.             *
 *                                                          *
 ************************************************************
 */
  case queen:
  case rook:
  case bishop:
    if (Attack(From(move), To(move)))
      break;
    return (0);
  case knight:
    break;
  }
/*
 ************************************************************
 *                                                          *
 *   all normal moves are validated in the same manner, by  *
 *   checking the from and to squares and also the attack   *
 *   status for completeness.                               *
 *                                                          *
 ************************************************************
 */
  if (wtm) {
    if (Captured(move) == -PcOnSq(To(move)) && Captured(move) != king)
      return (1);
  } else {
    if (Captured(move) == PcOnSq(To(move)) && Captured(move) != king)
      return (1);
  }
  return (0);
}
