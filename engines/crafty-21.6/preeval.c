#include <stdio.h>
#include <stdlib.h>
#include "chess.h"
#include "data.h"

/* last modified 08/07/05 */
/*
 *******************************************************************************
 *                                                                             *
 *   PreEvaluate() is used to recognize positions where the "Trojan horse  -   *
 *   attack" is threatened, and it enables the specific code to handle that    *
 *   case.                                                                     *
 *                                                                             *
 *******************************************************************************
 */
void PreEvaluate(TREE * RESTRICT tree)
{
  static int last_trojan_check = 0;
  static int last_clear = 0;

/*
 ************************************************************
 *                                                          *
 *   now check to see if the "trojan check" code should be  *
 *   turned on.  basically if the king is in the corner,    *
 *   the opponent has placed a piece on g4/g5, and both     *
 *   sides have pawns attacking that piece, and queens are  *
 *   still on the board, then it is a threat that must be   *
 *   handled.                                               *
 *                                                          *
 *   this is handled as 4 separate cases for each corner of *
 *   the board, for simplicity.                             *
 *                                                          *
 ************************************************************
 */
  shared->trojan_check = 0;
  if (BlackQueens && BlackRooks) {
    if (WhiteKingSQ == G1 || WhiteKingSQ == H1) {
      if (SetMask(G4) & BlackKnights || SetMask(G4) & BlackBishops) {
        if (SetMask(H3) & WhitePawns && SetMask(H5) & BlackPawns)
          shared->trojan_check = 1;
      }
    }
    if (WhiteKingSQ == B1 || WhiteKingSQ == A1) {
      if (SetMask(B4) & BlackKnights || SetMask(B4) & BlackBishops) {
        if (SetMask(A3) & WhitePawns && SetMask(A5) & BlackPawns)
          shared->trojan_check = 1;
      }
    }
  }
  if (WhiteQueens && WhiteRooks) {
    if (BlackKingSQ == G8 || BlackKingSQ == H8) {
      if (SetMask(G5) & WhiteKnights || SetMask(G5) & WhiteBishops) {
        if (SetMask(H6) & BlackPawns && SetMask(H4) & WhitePawns)
          shared->trojan_check = 1;
      }
    }
    if (BlackKingSQ == B8 || BlackKingSQ == A8) {
      if (SetMask(B5) & WhiteKnights || SetMask(B5) & WhiteBishops) {
        if (SetMask(A6) & BlackPawns && SetMask(A4) & BlackPawns)
          shared->trojan_check = 1;
      }
    }
  }
/*
 ************************************************************
 *                                                          *
 *   now, if any of the values above were changed, we must  *
 *   clear the appropriate hash tables so that the new      *
 *   values will be used to compute scores.                 *
 *                                                          *
 ************************************************************
 */
  if (last_trojan_check != shared->trojan_check) {
/*
 **************************************************
 *                                                *
 *   if the trojan check flag changed, we have to *
 *   clear hash scores.                           *
 *                                                *
 **************************************************
 */
    if (shared->trojan_check)
      Print(128, "              trojan check enabled\n");
    Print(128, "              clearing hash tables\n");
    ClearHashTableScores(1);
    last_clear = shared->move_number;
  }
/*
 ************************************************************
 *                                                          *
 *   now for a kludge.  If we are beyond the halfway point  *
 *   with respect to a 50 move draw, then clear the hash    *
 *   scores every move to avoid hiding the 50 move scores   *
 *   from the search by getting hash table hits.            *
 *                                                          *
 ************************************************************
 */
  if (Rule50Moves(0) > 80) {
    ClearHashTableScores(0);
    Print(128, "              clearing hash tables (50 moves fix)\n");
  }
  last_trojan_check = shared->trojan_check;
}
