#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "chess.h"
#include "data.h"

/* last modified 08/07/05 */
/*
 *******************************************************************************
 *                                                                             *
 *   EVTest() is used to test the program against a suite of test positions to *
 *   measure its performance on a particular machine, or to evaluate its skill *
 *   after modifying it in some way.                                           *
 *                                                                             *
 *   the test is initiated by using the "evtest <filename>" command to read in *
 *   the suite of problems from file <filename>.  the format of this file is   *
 *   as follows:                                                               *
 *                                                                             *
 *   setboard <forsythe-string>:  this sets the board position using the usual *
 *   forsythe notation (see module SetBoard() in setc for a full explanation   *
 *   planation of the syntax).                                                 *
 *                                                                             *
 *   after reading this position, the program then calls Evaluate() to produce *
 *   a positional evaluation, along with any debug output from Evaluate(), and *
 *   then goes on to the next position.                                        *
 *                                                                             *
 *******************************************************************************
 */
void EVTest(char *filename)
{
  FILE *test_input;
  char *eof;
  TREE *const tree = shared->local[0];

/*
 ************************************************************
 *                                                          *
 *   read in the position and then the solutions.  then do  *
 *   a call to Evaluate() which will normally display the   *
 *   debugging stuff that is enabled.                       *
 *                                                          *
 ************************************************************
 */
  if (!(test_input = fopen(filename, "r"))) {
    printf("file %s does not exist.\n", filename);
    return;
  }
  while (1) {
    eof = fgets(buffer, 512, test_input);
    if (eof) {
      char *delim;

      delim = strchr(buffer, '\n');
      if (delim)
        *delim = 0;
      delim = strchr(buffer, '\r');
      if (delim)
        *delim = ' ';
    } else
      break;
    nargs = ReadParse(buffer, args, " ;");
    if (!strcmp(args[0], "end"))
      break;
    else {
      int s1, s2, s3, s4, id;
      char buff[256];

      for (id = 2; id < nargs; id++)
        if (!strcmp(args[id], "id"))
          break;
      if (id >= nargs)
        id = 0;
      SetBoard(&tree->position[0], nargs, args, 0);
      strcpy(buff, args[0]);

      WhiteCastle(0) = 0;
      WhiteCastle(1) = 0;
      BlackCastle(0) = 0;
      BlackCastle(1) = 0;
      shared->root_wtm = wtm;
      PreEvaluate(tree);
      tree->pawn_score.key = 0;
      printf("Mobility = %d\n", EvaluateMobility(tree));
/*
      s1 = Evaluate(tree, 0, wtm, -99999, 99999);
      printf("===============================================\n");
      DisplayChessBoard(stdout, tree->pos);
      DisplayBitBoard(tree->pawn_score.weak_pawns);

      strcpy(buffer, "flop");
      (void) Option(tree);
      PreEvaluate(tree);
      tree->pawn_score.key = 0;
      s2 = Evaluate(tree, 0, wtm, -99999, 99999);

      strcpy(buffer, "flip");
      (void) Option(tree);
      PreEvaluate(tree);
      tree->pawn_score.key = 0;
      s3 = Evaluate(tree, 0, wtm, -99999, 99999);

      strcpy(buffer, "flop");
      (void) Option(tree);
      PreEvaluate(tree);
      tree->pawn_score.key = 0;
      s4 = Evaluate(tree, 0, wtm, -99999, 99999);

      if (s1 != s2 || s1 != s3 || s1 != s4 || s2 != s3 || s2 != s4 || s3 != s4) {
        strcpy(buffer, "flip");
        (void) Option(tree);
        printf("FEN = %s\n", buff);
        DisplayChessBoard(stdout, tree->pos);
        if (id)
          Print(4095, "id=%s  ", args[id + 1]);
        Print(4095, "wtm=%d  score=%d  %d (flop)  %d (flip)  %d (flop)\n", wtm,
            s1, s2, s3, s4);
      }
*/
    }
  }
  input_stream = stdin;
}
