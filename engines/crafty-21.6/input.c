#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "chess.h"
#include "data.h"

/* last modified 04/07/05 */
/*
 *******************************************************************************
 *                                                                             *
 *   InputMove() is responsible for converting a move from a text string to    *
 *   the internal move format.  it allows the so-called "reduced algebraic     *
 *   move format" which makes the origin square optional unless required for   *
 *   clarity.  it also accepts as little as required to remove ambiguity from  *
 *   the move, by using GenerateMoves() to produce a set of legal moves        *
 *   that the text can be applied against to eliminate those moves not         *
 *   intended.  hopefully, only one move will remain after the elimination     *
 *   and legality checks.                                                      *
 *                                                                             *
 *******************************************************************************
 */
int InputMove(TREE * RESTRICT tree, char *text, int ply, int wtm, int silent,
    int ponder_list)
{
  int moves[220], *mv, *mvp, *goodmove = 0;
  int piece = -1, capture, promote, give_check;
  int ffile, frank, tfile, trank;
  int current, i, nleft;
  char *goodchar, *tc;
  char movetext[128];
  static const char pieces[17] =
      { ' ', ' ', 'P', 'p', 'N', 'n', 'K', 'k', ' ', ' ',
    'B', 'B', 'R', 'r', 'Q', 'q', '\0'
  };
  static const char pro_pieces[17] =
      { ' ', ' ', ' ', ' ', 'N', 'n', ' ', ' ', ' ', ' ',
    'B', 'b', 'R', 'r', 'Q', 'q', '\0'
  };

/*
 first strip off things like !!/??/!? and so forth, to avoid
 confusing the parsing.
 */
  if ((tc = strchr(text, '!')))
    *tc = 0;
  if ((tc = strchr(text, '?')))
    *tc = 0;
/*
 check for fully-qualified input (f1e1) and handle if needed.
 */
  if (strlen(text) == 0)
    return (0);
  if ((text[0] >= 'a') && (text[0] <= 'h') && (text[1] >= '1') &&
      (text[1] <= '8') && (text[2] >= 'a') && (text[2] <= 'h') &&
      (text[3] >= '1') && (text[3] <= '8'))
    return (InputMoveICS(tree, text, ply, wtm, silent, ponder_list));
/*
 initialize move structure in case an error is found
 */
  tree->position[MAXPLY] = tree->position[ply];
  strcpy(movetext, text);
  moves[0] = 0;
  piece = 0;
  capture = 0;
  promote = 0;
  give_check = 0;
  frank = -1;
  ffile = -1;
  trank = -1;
  tfile = -1;
  goodchar = strchr(movetext, '#');
  if (goodchar)
    *goodchar = 0;
/*
 first, figure out what each character means.  the first thing to
 do is eliminate castling moves
 */
  if (!strcmp(movetext, "o-o") || !strcmp(movetext, "o-o+") ||
      !strcmp(movetext, "O-O") || !strcmp(movetext, "O-O+") ||
      !strcmp(movetext, "0-0") || !strcmp(movetext, "0-0+")) {
    piece = king;
    if (wtm) {
      ffile = 4;
      frank = 0;
      tfile = 6;
      trank = 0;
    } else {
      ffile = 4;
      frank = 7;
      tfile = 6;
      trank = 7;
    }
  } else if (!strcmp(movetext, "o-o-o") || !strcmp(movetext, "o-o-o+") ||
      !strcmp(movetext, "O-O-O") || !strcmp(movetext, "O-O-O+") ||
      !strcmp(movetext, "0-0-0") || !strcmp(movetext, "0-0-0+")) {
    piece = king;
    if (wtm) {
      ffile = 4;
      frank = 0;
      tfile = 2;
      trank = 0;
    } else {
      ffile = 4;
      frank = 7;
      tfile = 2;
      trank = 7;
    }
  } else {
/*
 ok, it's not a castling.  check for the first two characters of "bb" which
 indicates that the first "b" really means "B" since pawn advances don't
 require a source file.
 */
    if ((movetext[0] == 'b') && (movetext[1] == 'b'))
      movetext[0] = 'B';
/*
 now, start by picking off the check indicator (+) if one is present.
 */
    if (strchr(movetext, '+')) {
      *strchr(movetext, '+') = 0;
      give_check = 1;
    }
/*
 now, continue by picking off the promotion piece if one is present.  this
 is indicated by something like =q on the end of the move string.
 */
    if (strchr(movetext, '=')) {
      goodchar = strchr(movetext, '=');
      goodchar++;
      promote = (strchr(pro_pieces, *goodchar) - pro_pieces) >> 1;
      *strchr(movetext, '=') = 0;
    }
/*
 now, for a kludge.  ChessBase can't follow the PGN standard and likes to
 export pawn promotions as axb8Q, omitting the required '=' character.  this
 fix handles that particular ChessBase error.
 */
    else {
      char *prom = strchr(pro_pieces, movetext[strlen(movetext) - 1]);

      if (prom) {
        promote = (prom - pro_pieces) >> 1;
        movetext[strlen(movetext) - 1] = 0;
      }
    }
/*
 the next thing to do is extract the last rank/file designators since
 the destination is required.  note that we can have either or both.
 */
    current = strlen(movetext) - 1;
    trank = movetext[current] - '1';
    if ((trank >= 0) && (trank <= 7))
      movetext[current] = 0;
    else
      trank = -1;
    current = strlen(movetext) - 1;
    tfile = movetext[current] - 'a';
    if ((tfile >= 0) && (tfile <= 7))
      movetext[current] = 0;
    else
      tfile = -1;
    if (strlen(movetext)) {
/*
 now check the first character to see if it's a piece indicator
 (PpNnBbRrQqKk).  if so, strip it off.
 */
      if (strchr("  PpNnBBRrQqKk", *movetext)) {
        piece = (strchr(pieces, movetext[0]) - pieces) >> 1;
        for (i = 0; i < (int) strlen(movetext); i++)
          movetext[i] = movetext[i + 1];
      }
/*
 now that we have the destination and the moving piece (if any)
 the next step is to see if the last character is now an "x"
 indicating a capture   if so, set the capture flag, remove the
 trailing "x" and continue.
 */
      if ((strlen(movetext)) && (movetext[strlen(movetext) - 1] == 'x')) {
        capture = 1;
        movetext[strlen(movetext) - 1] = 0;
      } else
        capture = 0;
/*
 now, all that can be left is a rank designator, a file designator
 or both.  if the last character a number, then the first (if present)
 has to be a letter.
 */
      if (strlen(movetext)) {
        ffile = movetext[0] - 'a';
        if ((ffile < 0) || (ffile > 7)) {
          ffile = -1;
          frank = movetext[0] - '1';
          if ((frank < 0) || (frank > 7))
            piece = -1;
        } else {
          if (strlen(movetext) == 2) {
            frank = movetext[1] - '1';
            if ((frank < 0) || (frank > 7))
              piece = -1;
          }
        }
      }
    }
  }
  if (!piece)
    piece = 1;
  if (!ponder_list) {
    mvp = GenerateCaptures(tree, MAXPLY, wtm, moves);
    mvp = GenerateNonCaptures(tree, MAXPLY, wtm, mvp);
  } else {
    for (i = 0; i < num_ponder_moves; i++)
      moves[i] = ponder_moves[i];
    mvp = moves + num_ponder_moves;
  }
  for (mv = &moves[0]; mv < mvp; mv++) {
    if (piece && (Piece(*mv) != piece))
      *mv = 0;
    if ((ffile >= 0) && (File(From(*mv)) != ffile))
      *mv = 0;
    if (capture && (!Captured(*mv)))
      *mv = 0;
    if (promote && (Promote(*mv) != promote))
      *mv = 0;
    if ((frank >= 0) && (Rank(From(*mv)) != frank))
      *mv = 0;
    if ((tfile >= 0) && (File(To(*mv)) != tfile))
      *mv = 0;
    if ((trank >= 0) && (Rank(To(*mv)) != trank))
      *mv = 0;
    if (!ponder_list && *mv) {
      MakeMove(tree, MAXPLY, *mv, wtm);
      if (Check(wtm) || (give_check && !Check(Flip(wtm)))) {
        UnmakeMove(tree, MAXPLY, *mv, wtm);
        *mv = 0;
      } else
        UnmakeMove(tree, MAXPLY, *mv, wtm);
    }
  }
  nleft = 0;
  for (mv = &moves[0]; mv < mvp; mv++) {
    if (*mv) {
      nleft++;
      goodmove = mv;
    }
  }
  if (nleft == 1)
    return (*goodmove);
  if (!silent) {
    if (nleft == 0)
      Print(4095, "Illegal move: %s\n", text);
    else if (piece < 0)
      Print(4095, "Illegal move (unrecognizable): %s\n", text);
    else
      Print(4095, "Illegal move (ambiguous): %s\n", text);
  }
  return (0);
}

/* last modified 03/11/97 */
/*
 *******************************************************************************
 *                                                                             *
 *   InputMoveICS() is responsible for converting a move from the ics format   *
 *   [from][to][promote] to the program's internal format.                     *
 *                                                                             *
 *******************************************************************************
 */
int InputMoveICS(TREE * RESTRICT tree, char *text, int ply, int wtm, int silent,
    int ponder_list)
{
  int moves[220], *mv, *mvp, *goodmove = 0;
  int piece = -1, promote;
  int ffile, frank, tfile, trank;
  int i, nleft;
  char movetext[128];
  static const char pieces[17] =
      { ' ', ' ', 'P', 'p', 'N', 'n', 'K', 'k', ' ', ' ',
    'B', 'b', 'R', 'r', 'Q', 'q', '\0'
  };
/*
 initialize move structure in case an error is found
 */
  if (strlen(text) == 0)
    return (0);
  tree->position[MAXPLY] = tree->position[ply];
  strcpy(movetext, text);
  moves[0] = 0;
  promote = 0;
/*
 first, figure out what each character means.  the first thing to
 do is eliminate castling moves
 */
  if (!strcmp(movetext, "o-o") || !strcmp(movetext, "O-O") ||
      !strcmp(movetext, "0-0")) {
    piece = king;
    if (wtm) {
      ffile = 4;
      frank = 0;
      tfile = 6;
      trank = 0;
    } else {
      ffile = 4;
      frank = 7;
      tfile = 6;
      trank = 7;
    }
  } else if (!strcmp(movetext, "o-o-o") || !strcmp(movetext, "O-O-O") ||
      !strcmp(movetext, "0-0-0")) {
    piece = king;
    if (wtm) {
      ffile = 4;
      frank = 0;
      tfile = 2;
      trank = 0;
    } else {
      ffile = 4;
      frank = 7;
      tfile = 2;
      trank = 7;
    }
  } else {
/*
 the next thing to do is extract the last rank/file designators since
 the destination is required.  note that we can have either or both.
 */
    ffile = movetext[0] - 'a';
    frank = movetext[1] - '1';
    tfile = movetext[2] - 'a';
    trank = movetext[3] - '1';
/*
 now, continue by picking off the promotion piece if one is present.  this
 is indicated by something like q on the end of the move string.
 */
    if (movetext[4] == '=')
      promote = (strchr(pieces, movetext[5]) - pieces) >> 1;
    else if ((movetext[4] != 0) && (movetext[4] != ' '))
      promote = (strchr(pieces, movetext[4]) - pieces) >> 1;
  }
  if (!ponder_list) {
    mvp = GenerateCaptures(tree, MAXPLY, wtm, moves);
    mvp = GenerateNonCaptures(tree, MAXPLY, wtm, mvp);
  } else {
    for (i = 0; i < num_ponder_moves; i++)
      moves[i] = ponder_moves[i];
    mvp = moves + num_ponder_moves;
  }
  for (mv = &moves[0]; mv < mvp; mv++) {
    if (Promote(*mv) != promote)
      *mv = 0;
    if (Rank(From(*mv)) != frank)
      *mv = 0;
    if (File(From(*mv)) != ffile)
      *mv = 0;
    if (Rank(To(*mv)) != trank)
      *mv = 0;
    if (File(To(*mv)) != tfile)
      *mv = 0;
    if (!ponder_list && *mv) {
      MakeMove(tree, MAXPLY, *mv, wtm);
      if (Check(wtm)) {
        UnmakeMove(tree, MAXPLY, *mv, wtm);
        *mv = 0;
      } else
        UnmakeMove(tree, MAXPLY, *mv, wtm);
    }
  }
  nleft = 0;
  for (mv = &moves[0]; mv < mvp; mv++) {
    if (*mv) {
      nleft++;
      goodmove = mv;
    }
  }
  if (nleft == 1)
    return (*goodmove);
  if (!silent) {
    if (nleft == 0)
      Print(4095, "Illegal move: %s\n", text);
    else if (piece < 0)
      Print(4095, "Illegal move (unrecognizable): %s\n", text);
    else
      Print(4095, "Illegal move (ambiguous): %s\n", text);
  }
  return (0);
}
