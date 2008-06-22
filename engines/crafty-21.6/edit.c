#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "chess.h"
#include "data.h"

/* last modified 08/07/05 */
/*
 *******************************************************************************
 *                                                                             *
 *   Edit() is used to edit (alter) the current board position.  it clears the *
 *   board and then allows the operator to enter a position using one of four  *
 *                                                                             *
 *   white sets the color of pieces added to white.  this color will stay in   *
 *   effect until specifically changed.                                        *
 *                                                                             *
 *   black sets the color of pieces added to black.  this color will stay in   *
 *   effect until specifically changed.                                        *
 *                                                                             *
 *   # clears the chessboard completely.                                       *
 *                                                                             *
 *   c changes (toggles) the color of pieces being placed on the board.        *
 *                                                                             *
 *   end (or . for ICS/Xboard) terminates Edit().                              *
 *                                                                             *
 *   pieces are placed on the board by three character "commands" of the form  *
 *   [piece][square] where piece is a member of the normal set of pieces       *
 *   {P,N,B,R,Q,K} and [square] is algebraic square notation (a1-h8).  ex: Ke8 *
 *   puts a king (of the current "color") on square e8.                        *
 *                                                                             *
 *******************************************************************************
 */
void Edit(void)
{
  int athome = 1, i, piece, readstat, square, tfile, trank, wtm = 1, error = 0;
  static const char pieces[] =
      { 'x', 'X', 'P', 'p', 'N', 'n', 'K', 'k', '*', '*',
    'B', 'b', 'R', 'r', 'Q', 'q', '\0'
  };
  TREE *const tree = shared->local[0];

/*
 ************************************************************
 *                                                          *
 *   next, process the commands to set the board[n] form    *
 *   of the chess position.                                 *
 *                                                          *
 ************************************************************
 */
  while (1) {
    if ((input_stream == stdin) && !xboard) {
      if (wtm)
        printf("edit(white): ");
      else
        printf("edit(black): ");
    }
    fflush(stdout);
    readstat = Read(1, buffer);
    if (readstat < 0)
      return;
    nargs = ReadParse(buffer, args, " 	;");
    if (xboard)
      Print(128, "edit.command:%s\n", args[0]);

    if (!strcmp(args[0], "white"))
      wtm = 1;
    else if (!strcmp(args[0], "black"))
      wtm = 0;
    if (!strcmp(args[0], "#"))
      for (i = 0; i < 64; i++)
        PcOnSq(i) = 0;
    else if (!strcmp(args[0], "c"))
      wtm = Flip(wtm);
    else if (!strcmp(args[0], "end") || (!strcmp(args[0], ".")))
      break;
    else if (!strcmp(args[0], "d"))
      DisplayChessBoard(stdout, tree->pos);
    else if (strlen(args[0]) == 3) {
      if (strchr(pieces, args[0][0])) {
        piece = (strchr(pieces, args[0][0]) - pieces) >> 1;
        tfile = args[0][1] - 'a';
        trank = args[0][2] - '1';
        square = (trank << 3) + tfile;
        if ((square < 0) || (square > 63))
          printf("unrecognized square %s\n", args[0]);
        if (wtm)
          PcOnSq(square) = piece;
        else
          PcOnSq(square) = -piece;
      }
    } else if (strlen(args[0]) == 2) {
      piece = pawn;
      tfile = args[0][0] - 'a';
      trank = args[0][1] - '1';
      square = (trank << 3) + tfile;
      if ((square < 0) || (square > 63))
        printf("unrecognized square %s\n", args[0]);
      if (wtm)
        PcOnSq(square) = piece;
      else
        PcOnSq(square) = -piece;
    } else
      printf("unrecognized piece %s\n", args[0]);
  }

/*
 ************************************************************
 *                                                          *
 *   now, if a king is on its original square, check the    *
 *   rooks to see if they are and set the castle status     *
 *   accordingly.  note that this checks for pieces on the  *
 *   original rank, but not their original squares (ICS     *
 *   "wild" games) and doesn't set castling if true.        *
 *                                                          *
 ************************************************************
 */
  WhiteCastle(0) = 0;
  BlackCastle(0) = 0;
  EnPassant(0) = 0;
  for (i = 0; i < 16; i++)
    if (PcOnSq(i) == 0 || PcOnSq(i + 48) == 0)
      athome = 0;
  if (!athome || (PcOnSq(A1) == rook && PcOnSq(B1) == knight &&
          PcOnSq(C1) == bishop && PcOnSq(D1) == queen && PcOnSq(E1) == king &&
          PcOnSq(F1) == bishop && PcOnSq(G1) == knight && PcOnSq(H1) == rook &&
          PcOnSq(A8) == -rook && PcOnSq(B8) == -knight && PcOnSq(C8) == -bishop
          && PcOnSq(D8) == -queen && PcOnSq(E8) == -king &&
          PcOnSq(F8) == -bishop && PcOnSq(G8) == -knight &&
          PcOnSq(H8) == -rook)) {
    if (PcOnSq(E1) == king) {
      if (PcOnSq(A1) == rook)
        WhiteCastle(0) = WhiteCastle(0) | 2;
      if (PcOnSq(H1) == rook)
        WhiteCastle(0) = WhiteCastle(0) | 1;
    }
    if (PcOnSq(E8) == -king) {
      if (PcOnSq(A8) == -rook)
        BlackCastle(0) = BlackCastle(0) | 2;
      if (PcOnSq(H8) == -rook)
        BlackCastle(0) = BlackCastle(0) | 1;
    }
  }
/*
 ************************************************************
 *                                                          *
 *   basic board is now set.  now it's time to set the bit  *
 *   board representation correctly.                        *
 *                                                          *
 ************************************************************
 */
  SetChessBitBoards(&tree->position[0]);
  error += InvalidPosition(tree);
  if (!error) {
    if (log_file)
      DisplayChessBoard(log_file, tree->pos);
    wtm = 1;
    shared->move_number = 1;
    tree->rep_game = 0;
    tree->rep_list[tree->rep_game] = HashKey;
    tree->position[0].rule_50_moves = 0;
    shared->moves_out_of_book = 0;
  } else {
    InitializeChessBoard(&tree->position[0]);
    Print(4095, "Illegal position, using normal initial chess position\n");
  }
}
