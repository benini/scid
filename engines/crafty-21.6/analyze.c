#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "chess.h"
#include "data.h"

/* last modified 08/07/05 */
/*
 *******************************************************************************
 *                                                                             *
 *   Analyze() is used to handle the "analyze" command.  this mode basically   *
 *   puts Crafty into a "permanent pondering" state, where it reads a move from*
 *   the input stream, and then "ponders" for the opposite side.  whenever a   *
 *   move is entered, Crafty reads this move, updates the game board, and then *
 *   starts "pondering" for the other side.                                    *
 *                                                                             *
 *******************************************************************************
 */
void Analyze()
{
  int i, move, back_number, readstat = 1;
  TREE *const tree = shared->local[0];

/*
 ************************************************************
 *                                                          *
 *  initialize.                                             *
 *                                                          *
 ************************************************************
 */
  int save_swindle_mode = swindle_mode;

  swindle_mode = 0;
  ponder_move = 0;
  analyze_mode = 1;
  if (!xboard)
    shared->display_options |= 1 + 2 + 4;
  printf("Analyze Mode: type \"exit\" to terminate.\n");
/*
 ************************************************************
 *                                                          *
 *  now loop waiting on input, searching the current        *
 *  position continually until a move comes in.             *
 *                                                          *
 ************************************************************
 */
  do {
    do {
      last_pv.pathd = 0;
      last_pv.pathl = 0;
      input_status = 0;
      shared->pondering = 1;
      tree->position[1] = tree->position[0];
      (void) Iterate(wtm, think, 0);
      shared->pondering = 0;
      if (book_move)
        shared->moves_out_of_book = 0;
      if (!xboard) {
        if (wtm)
          printf("analyze.White(%d): ", shared->move_number);
        else
          printf("analyze.Black(%d): ", shared->move_number);
        fflush(stdout);
      }
/*
 ************************************************************
 *                                                          *
 *  if we get back to here, something has been typed in and *
 *  is in the command buffer normally, unless the search    *
 *  terminated naturally due to finding a mate or reaching  *
 *  the max depth allowable.                                *
 *                                                          *
 ************************************************************
 */
      if (!input_status)
        do {
          readstat = Read(1, buffer);
          if (readstat < 0)
            break;
          nargs = ReadParse(buffer, args, " 	;");
          Print(128, "%s\n", buffer);
          if (strstr(args[0], "timeleft") && !xboard) {
            if (wtm)
              printf("analyze.White(%d): ", shared->move_number);
            else
              printf("analyze.Black(%d): ", shared->move_number);
            fflush(stdout);
          }
        } while (strstr(args[0], "timeleft"));
      else
        nargs = ReadParse(buffer, args, " 	;");
      if (readstat < 0)
        break;
      move = 0;
      if (!strcmp(args[0], "exit"))
        break;
/*
 ************************************************************
 *                                                          *
 *  First, check for the special analyze command "back n"   *
 *  and handle it if present, otherwise try Option() to see *
 *  if it recognizes the input as a command.                *
 *                                                          *
 ************************************************************
 */
      if (OptionMatch("back", args[0])) {
        if (nargs > 1)
          back_number = atoi(args[1]);
        else
          back_number = 1;
        for (i = 0; i < back_number; i++) {
          wtm = Flip(wtm);
          if (Flip(wtm))
            shared->move_number--;
        }
        if (shared->move_number == 0) {
          shared->move_number = 1;
          wtm = 1;
        }
        sprintf(buffer, "reset %d", shared->move_number);
        (void) Option(tree);
        display = tree->pos;
      } else if (Option(tree)) {
        display = tree->pos;
      }
/*
 ************************************************************
 *                                                          *
 *  if InputMove() can recognize this as a move, make it,   *
 *  swap sides, and return to the top of the loop to call   *
 *  search from this new position.                          *
 *                                                          *
 ************************************************************
 */
      else if ((move = InputMove(tree, buffer, 0, wtm, 1, 0))) {
        char *outmove = OutputMove(tree, move, 0, wtm);

        fseek(history_file, ((shared->move_number - 1) * 2 + 1 - wtm) * 10,
            SEEK_SET);
        fprintf(history_file, "%9s\n", outmove);
        if (wtm)
          Print(128, "White(%d): ", shared->move_number);
        else
          Print(128, "Black(%d): ", shared->move_number);
        Print(128, "%s\n", outmove);
        if (speech) {
          char announce[64];

          strcpy(announce, SPEAK);
          strcat(announce, outmove);
          system(announce);
        }
        MakeMoveRoot(tree, move, wtm);
        display = tree->pos;
        last_mate_score = 0;
        if (log_file)
          DisplayChessBoard(log_file, tree->pos);
      }
/*
 ************************************************************
 *                                                          *
 *  If Option() didn't handle the input, then it might be   *
 *  something from the DGT driver, and something from there *
 *  means to retract a move.                                *
 *                                                          *
 ************************************************************
 */
      else {
        if (!DGT_active) {
          shared->pondering = 0;
          if (Option(tree) == 0)
            printf("illegal move: %s\n", buffer);
          shared->pondering = 1;
        } else {
          wtm = Flip(wtm);
          if (Flip(wtm))
            shared->move_number--;
          if (shared->move_number == 0) {
            shared->move_number = 1;
            wtm = 1;
          }
          sprintf(buffer, "reset %d", shared->move_number);
          (void) Option(tree);
        }
        display = tree->pos;
      }
    } while (!move);
    if (readstat < 0 || !strcmp(args[0], "exit"))
      break;
    wtm = Flip(wtm);
    if (wtm)
      shared->move_number++;
  } while (1);
  analyze_mode = 0;
  printf("analyze complete.\n");
  shared->pondering = 0;
  swindle_mode = save_swindle_mode;
}
