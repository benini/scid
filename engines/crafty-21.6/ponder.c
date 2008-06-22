#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "chess.h"
#include "data.h"

/* last modified 08/07/05 */
/*
 *******************************************************************************
 *                                                                             *
 *   Ponder() is the driver for "pondering" (thinking on the opponent's time.) *
 *   its operation is simple:  find a predicted move by (a) taking the second  *
 *   move from the principal variation, or (b) call lookup to see if it finds  *
 *   a suggested move from the transposition table.  then, make this move and  *
 *   do a search from the resulting position.  while pondering, one of three   *
 *   things can happen:  (1) a move is entered, and it matches the predicted   *
 *   move.  we then switch from pondering to thinking and search as normal;    *
 *   (2) a move is entered, but it does not match the predicted move.  we then *
 *   abort the search, unmake the pondered move, and then restart with the move*
 *   entered.  (3) a command is entered.  if it is a simple command, it can be *
 *   done without aborting the search or losing time.  if not, we abort the    *
 *   search, execute the command, and then attempt to restart pondering if the *
 *   command didn't make that impossible.                                      *
 *                                                                             *
 *******************************************************************************
 */
int Ponder(int wtm)
{
  int dalpha = -999999, dbeta = 999999, dthreat = 0, i, *n_ponder_moves, *mv;
  int save_move_number, tlom;
  TREE *const tree = shared->local[0];

/*
 ************************************************************
 *                                                          *
 *   first, let's check to see if pondering is allowed, or  *
 *   if we should avoid pondering on this move since it is  *
 *   the first move of a game, or if the game is over, or   *
 *   "force" mode is active, or there is input in the queue *
 *   that needs to be read and processed.                   *
 *                                                          *
 ************************************************************
 */
  if (!ponder || force || over || CheckInput())
    return (0);
  save_move_number = shared->move_number;
/*
 ************************************************************
 *                                                          *
 *   if we don't have a predicted move to ponder, try two   *
 *   sources:  (1) look up the current position in the      *
 *   transposition table and see if it has a suggested best *
 *   move;  (2) do a short tree search to calculate a move  *
 *   that we should ponder.                                 *
 *                                                          *
 ************************************************************
 */
  strcpy(hint, "none");
  if (ponder_move) {
    if (!ValidMove(tree, 1, wtm, ponder_move)) {
      ponder_move = 0;
      Print(4095, "ERROR.  ponder_move is illegal (1).\n");
      Print(4095, "ERROR.  PV pathl=%d\n", last_pv.pathl);
      Print(4095, "ERROR.  move=%d  %x\n", ponder_move, ponder_move);
    }
  }
  if (!ponder_move) {
    (void) HashProbe(tree, 0, 0, wtm, &dalpha, dbeta, &dthreat);
    if (tree->hash_move[0])
      ponder_move = tree->hash_move[0];
    if (ponder_move) {
      if (!ValidMove(tree, 1, wtm, ponder_move)) {
        ponder_move = 0;
        Print(4095, "ERROR.  ponder_move is illegal (2).\n");
        Print(4095, "ERROR.  PV pathl=%d\n", last_pv.pathl);
        Print(4095, "ERROR.  move=%d  %x\n", ponder_move, ponder_move);
      }
    }
  }
  if (!ponder_move) {
    TimeSet(puzzle);
    if (shared->time_limit < 20)
      return (0);
    shared->puzzling = 1;
    tree->position[1] = tree->position[0];
    Print(128, "              puzzling over a move to ponder.\n");
    last_pv.pathl = 0;
    last_pv.pathd = 0;
    for (i = 0; i < MAXPLY; i++) {
      tree->killers[i].move1 = 0;
      tree->killers[i].move2 = 0;
    }
    (void) Iterate(wtm, puzzle, 0);
    for (i = 0; i < MAXPLY; i++) {
      tree->killers[i].move1 = 0;
      tree->killers[i].move2 = 0;
    }
    shared->puzzling = 0;
    if (tree->pv[0].pathl)
      ponder_move = tree->pv[0].path[1];
    if (!ponder_move)
      return (0);
    for (i = 1; i < (int) tree->pv[0].pathl; i++)
      last_pv.path[i] = tree->pv[0].path[i + 1];
    last_pv.pathl = tree->pv[0].pathl - 1;
    last_pv.pathd = 0;
    if (!ValidMove(tree, 1, wtm, ponder_move)) {
      ponder_move = 0;
      Print(4095, "ERROR.  ponder_move is illegal (3).\n");
      Print(4095, "ERROR.  PV pathl=%d\n", last_pv.pathl);
      return (0);
    }
  }
/*
 ************************************************************
 *                                                          *
 *   display the move we are going to "ponder".             *
 *                                                          *
 ************************************************************
 */
  if (wtm)
    Print(128, "White(%d): %s [pondering]\n", shared->move_number,
        OutputMove(tree, ponder_move, 0, wtm));
  else
    Print(128, "Black(%d): %s [pondering]\n", shared->move_number,
        OutputMove(tree, ponder_move, 0, wtm));
  sprintf(hint, "%s", OutputMove(tree, ponder_move, 0, wtm));
  if (post)
    printf("Hint: %s\n", hint);
/*
 ************************************************************
 *                                                          *
 *   set the ponder move list and eliminate illegal moves.  *
 *                                                          *
 ************************************************************
 */
  n_ponder_moves = GenerateCaptures(tree, 0, wtm, ponder_moves);
  num_ponder_moves =
      GenerateNonCaptures(tree, 0, wtm, n_ponder_moves) - ponder_moves;
  for (mv = ponder_moves; mv < ponder_moves + num_ponder_moves; mv++) {
    MakeMove(tree, 0, *mv, wtm);
    if (Check(wtm)) {
      UnmakeMove(tree, 0, *mv, wtm);
      *mv = 0;
    } else
      UnmakeMove(tree, 0, *mv, wtm);
  }
/*
 ************************************************************
 *                                                          *
 *   now, perform an iterated search, but with the special  *
 *   "pondering" flag set which changes the time controls   *
 *   since there is no need to stop searching until the     *
 *   opponent makes a move.                                 *
 *                                                          *
 ************************************************************
 */
  MakeMove(tree, 0, ponder_move, wtm);
  tlom = last_opponent_move;
  last_opponent_move = ponder_move;
  tree->rep_list[++tree->rep_game] = HashKey;
  if (kibitz)
    strcpy(shared->kibitz_text, "n/a");
  shared->thinking = 0;
  shared->pondering = 1;
  if (!wtm)
    shared->move_number++;
  ponder_value = Iterate(Flip(wtm), think, 0);
  shared->move_number = save_move_number;
  shared->pondering = 0;
  shared->thinking = 0;
  tree->rep_game--;
  last_opponent_move = tlom;
  UnmakeMove(tree, 0, ponder_move, wtm);
/*
 ************************************************************
 *                                                          *
 *   search completed. the possible return values are:      *
 *                                                          *
 *   (0) no pondering was done, period.                     *
 *                                                          *
 *   (1) pondering was done, opponent made the predicted    *
 *       move, and we searched until time ran out in a      *
 *       normal manner.                                     *
 *                                                          *
 *   (2) pondering was done, but the ponder search          *
 *       terminated due to either finding a mate, or the    *
 *       maximum search depth was reached.  the result of   *
 *       this ponder search are valid, but only if the      *
 *       opponent makes the correct (predicted) move.       *
 *                                                          *
 *   (3) pondering was done, but the opponent either made   *
 *       a different move, or entered a command that has to *
 *       interrupt the pondering search before the command  *
 *       (or move) can be processed.  this forces Main() to *
 *       avoid reading in a move/command since one has been *
 *       read into the command buffer already.              *
 *                                                          *
 ************************************************************
 */
  if (input_status == 1)
    return (1);
  if (input_status == 2)
    return (3);
  return (2);
}
