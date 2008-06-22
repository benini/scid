#include <stdio.h>
#include <stdlib.h>
#include "chess.h"
#include "data.h"

/* modified 07/18/06 */
/*
 *******************************************************************************
 *                                                                             *
 *   GenerateCaptures() is used to generate capture and pawn promotion moves   *
 *   from the current position.                                                *
 *                                                                             *
 *   the destination square set is the set of squares occupied by opponent     *
 *   pieces, plus the set of squares on the 8th rank that pawns can advance to *
 *   and promote.                                                              *
 *                                                                             *
 *******************************************************************************
 */
int *GenerateCaptures(TREE * RESTRICT tree, int ply, int wtm, int *move)
{
  register BITBOARD target, piecebd, moves;
  register BITBOARD promotions, pcapturesl, pcapturesr;
  register int from, to, temp;

/*
 ************************************************************
 *                                                          *
 *   now, produce knight moves by cycling through the       *
 *   *_knight board to locate a [from] square and then      *
 *   cycling through knight_attacks[] to locate to squares  *
 *   that a knight on [from] attacks.                       *
 *                                                          *
 ************************************************************
 */
  if (wtm) {
    piecebd = WhiteKnights;
    while (piecebd) {
      from = MSB(piecebd);
      moves = knight_attacks[from] & BlackPieces;
      temp = from + (knight << 12);
      while (moves) {
        to = MSB(moves);
        *move++ = temp | (to << 6) | ((-PcOnSq(to)) << 15);
        Clear(to, moves);
      }
      Clear(from, piecebd);
    }
/*
 ************************************************************
 *                                                          *
 *   now, produce bishop moves by cycling through the       *
 *   *_bishop board to locate a [from] square and then      *
 *   generate the AttacksFrom() bitmap which supplies the   *
 *   list of valid <to> squares.                            *
 *                                                          *
 ************************************************************
 */
    piecebd = WhiteBishops;
    while (piecebd) {
      from = MSB(piecebd);
      moves = AttacksBishop(from) & BlackPieces;
      temp = from + (bishop << 12);
      while (moves) {
        to = MSB(moves);
        *move++ = temp | (to << 6) | ((-PcOnSq(to)) << 15);
        Clear(to, moves);
      }
      Clear(from, piecebd);
    }
/*
 ************************************************************
 *                                                          *
 *   now, produce rook moves by cycling through the         *
 *   *_rook board to locate a [from] square and then        *
 *   generate the AttacksFrom() bitmap which supplies the   *
 *   list of valid <to> squares.                            *
 *                                                          *
 ************************************************************
 */
    piecebd = WhiteRooks;
    while (piecebd) {
      from = MSB(piecebd);
      moves = AttacksRook(from) & BlackPieces;
      temp = from + (rook << 12);
      while (moves) {
        to = MSB(moves);
        *move++ = temp | (to << 6) | ((-PcOnSq(to)) << 15);
        Clear(to, moves);
      }
      Clear(from, piecebd);
    }
/*
 ************************************************************
 *                                                          *
 *   now, produce queen moves by cycling through the        *
 *   *_queen board to locate a [from] square and then       *
 *   generate the AttacksFrom() bitmap which supplies the   *
 *   list of valid <to> squares.                            *
 *                                                          *
 ************************************************************
 */
    piecebd = WhiteQueens;
    while (piecebd) {
      from = MSB(piecebd);
      moves = AttacksQueen(from) & BlackPieces;
      temp = from + (queen << 12);
      while (moves) {
        to = MSB(moves);
        *move++ = temp | (to << 6) | ((-PcOnSq(to)) << 15);
        Clear(to, moves);
      }
      Clear(from, piecebd);
    }
/*
 ************************************************************
 *                                                          *
 *   now, produce king moves by cycling through the         *
 *   *_king board to locate a [from] square and then        *
 *   cycling through king_attacks[] to locate to squares    *
 *   that a king on [from] attacks.                         *
 *                                                          *
 ************************************************************
 */
    from = WhiteKingSQ;
    moves = king_attacks[from] & BlackPieces;
    temp = from + (king << 12);
    while (moves) {
      to = MSB(moves);
      *move++ = temp | (to << 6) | ((-PcOnSq(to)) << 15);
      Clear(to, moves);
    }
/*
 ************************************************************
 *                                                          *
 *   now, produce pawn moves.  this is done differently due *
 *   to inconsistencies in the way a pawn moves when it     *
 *   captures as opposed to normal non-capturing moves.     *
 *   another exception is capturing enpassant.  the first   *
 *   step is to generate all possible pawn promotions.  we  *
 *   do this by masking  all pawns but those on the 7th     *
 *   rank and then advancing them ahead if the square in    *
 *   front is empty.                                        *
 *                                                          *
 ************************************************************
 */
    promotions = (WhitePawns & rank_mask[RANK7]) << 8 & ~Occupied;
    while (promotions) {
      to = MSB(promotions);
      *move++ = (to - 8) | (to << 6) | (pawn << 12) | (queen << 18);
      Clear(to, promotions);
    }

    target = BlackPieces | EnPassantTarget(ply);
    pcapturesl = (WhitePawns & mask_left_edge) << 7 & target;
    while (pcapturesl) {
      to = MSB(pcapturesl);
      if (to < 56) {
        register int cap = (PcOnSq(to)) ? -PcOnSq(to) : pawn;

        *move++ = (to - 7) | (to << 6) | (pawn << 12) | (cap << 15);
      } else
        *move++ =
            (to -
            7) | (to << 6) | (pawn << 12) | ((-PcOnSq(to)) << 15) | (queen <<
            18);
      Clear(to, pcapturesl);
    }

    pcapturesr = (WhitePawns & mask_right_edge) << 9 & target;
    while (pcapturesr) {
      to = MSB(pcapturesr);
      if (to < 56) {
        register int cap = (PcOnSq(to)) ? -PcOnSq(to) : pawn;

        *move++ = (to - 9) | (to << 6) | (pawn << 12) | (cap << 15);
      } else
        *move++ =
            (to -
            9) | (to << 6) | (pawn << 12) | ((-PcOnSq(to)) << 15) | (queen <<
            18);
      Clear(to, pcapturesr);
    }
  }
/*
 ************************************************************
 *                                                          *
 *   now, produce knight moves by cycling through the       *
 *   *_knight board to locate a [from] square and then      *
 *   cycling through knight_attacks[] to locate to squares  *
 *   that a knight on [from] attacks.                       *
 *                                                          *
 ************************************************************
 */
  else {
    piecebd = BlackKnights;
    while (piecebd) {
      from = LSB(piecebd);
      moves = knight_attacks[from] & WhitePieces;
      temp = from + (knight << 12);
      while (moves) {
        to = LSB(moves);
        *move++ = temp | (to << 6) | (PcOnSq(to) << 15);
        Clear(to, moves);
      }
      Clear(from, piecebd);
    }
/*
 ************************************************************
 *                                                          *
 *   now, produce bishop moves by cycling through the       *
 *   *_bishop board to locate a [from] square and then      *
 *   generate the AttacksFrom() bitmap which supplies the   *
 *   list of valid <to> squares.                            *
 *                                                          *
 ************************************************************
 */
    piecebd = BlackBishops;
    while (piecebd) {
      from = LSB(piecebd);
      moves = AttacksBishop(from) & WhitePieces;
      temp = from + (bishop << 12);
      while (moves) {
        to = LSB(moves);
        *move++ = temp | (to << 6) | (PcOnSq(to) << 15);
        Clear(to, moves);
      }
      Clear(from, piecebd);
    }
/*
 ************************************************************
 *                                                          *
 *   now, produce rook moves by cycling through the         *
 *   *_rook board to locate a [from] square and then        *
 *   generate the AttacksFrom() bitmap which supplies the   *
 *   list of valid <to> squares.                            *
 *                                                          *
 ************************************************************
 */
    piecebd = BlackRooks;
    while (piecebd) {
      from = LSB(piecebd);
      moves = AttacksRook(from) & WhitePieces;
      temp = from + (rook << 12);
      while (moves) {
        to = LSB(moves);
        *move++ = temp | (to << 6) | (PcOnSq(to) << 15);
        Clear(to, moves);
      }
      Clear(from, piecebd);
    }
/*
 ************************************************************
 *                                                          *
 *   now, produce queen moves by cycling through the        *
 *   *_queen board to locate a [from] square and then       *
 *   generate the AttacksFrom() bitmap which supplies the   *
 *   list of valid <to> squares.                            *
 *                                                          *
 ************************************************************
 */
    piecebd = BlackQueens;
    while (piecebd) {
      from = LSB(piecebd);
      moves = AttacksQueen(from) & WhitePieces;
      temp = from + (queen << 12);
      while (moves) {
        to = LSB(moves);
        *move++ = temp | (to << 6) | (PcOnSq(to) << 15);
        Clear(to, moves);
      }
      Clear(from, piecebd);
    }
/*
 ************************************************************
 *                                                          *
 *   now, produce king moves by cycling through the         *
 *   *_king board to locate a [from] square and then        *
 *   cycling through king_attacks[] to locate to squares    *
 *   that a king on [from] attacks.                         *
 *                                                          *
 ************************************************************
 */
    from = BlackKingSQ;
    moves = king_attacks[from] & WhitePieces;
    temp = from + (king << 12);
    while (moves) {
      to = LSB(moves);
      *move++ = temp | (to << 6) | (PcOnSq(to) << 15);
      Clear(to, moves);
    }
/*
 ************************************************************
 *                                                          *
 *   now, produce pawn moves.  this is done differently due *
 *   to inconsistencies in the way a pawn moves when it     *
 *   captures as opposed to normal non-capturing moves.     *
 *   another exception is capturing enpassant.  the first   *
 *   step is to generate all possible pawn promotions.  we  *
 *   do this by masking  all pawns but those on the 7th     *
 *   rank and then advancing them ahead if the square in    *
 *   front is empty.                                        *
 *                                                          *
 ************************************************************
 */
    promotions = (BlackPawns & rank_mask[RANK2]) >> 8 & ~Occupied;
    while (promotions) {
      to = LSB(promotions);
      *move++ = (to + 8) | (to << 6) | (pawn << 12) | (queen << 18);
      Clear(to, promotions);
    }

    target = WhitePieces | EnPassantTarget(ply);
    pcapturesl = (BlackPawns & mask_left_edge) >> 9 & target;
    while (pcapturesl) {
      to = LSB(pcapturesl);
      if (to > 7) {
        register int cap = (PcOnSq(to)) ? PcOnSq(to) : pawn;

        *move++ = (to + 9) | (to << 6) | (pawn << 12) | (cap << 15);
      } else
        *move++ =
            (to +
            9) | (to << 6) | (pawn << 12) | (PcOnSq(to) << 15) | (queen << 18);
      Clear(to, pcapturesl);
    }

    pcapturesr = (BlackPawns & mask_right_edge) >> 7 & target;
    while (pcapturesr) {
      to = LSB(pcapturesr);
      if (to > 7) {
        register int cap = (PcOnSq(to)) ? PcOnSq(to) : pawn;

        *move++ = (to + 7) | (to << 6) | (pawn << 12) | (cap << 15);
      } else
        *move++ =
            (to +
            7) | (to << 6) | (pawn << 12) | (PcOnSq(to) << 15) | (queen << 18);
      Clear(to, pcapturesr);
    }
  }
  return (move);
}

/* modified 07/20/06 */
/*
 *******************************************************************************
 *                                                                             *
 *   GenerateCheckEvasions() is used to generate moves when the king is in     *
 *   check.                                                                    *
 *                                                                             *
 *   three types of check-evasion moves are generated:                         *
 *                                                                             *
 *   (1) generate king moves to squares that are not attacked by the opponent's*
 *   pieces.  this includes capture and non-capture moves.                     *
 *                                                                             *
 *   (2) generate interpositions along the rank/file that the checking attack  *
 *   is coming along (assuming (a) only one piece is checking the king, and    *
 *   (b) the checking piece is a sliding piece [bishop, rook, queen]).         *
 *                                                                             *
 *   (3) generate capture moves, but only to the square(s) that are giving     *
 *   check.  captures are a special case.  if there is one checking piece, then*
 *   capturing it by any piece is tried.  if there are two pieces checking the *
 *   king, then the only legal capture to try is for the king to capture one of*
 *   the checking pieces that is on an un-attacked square.                     *
 *                                                                             *
 *******************************************************************************
 */
int *GenerateCheckEvasions(TREE * RESTRICT tree, int ply, int wtm, int *move)
{
  register BITBOARD target, targetc, targetp, piecebd, moves;
  register BITBOARD padvances1, padvances2, pcapturesl, pcapturesr;
  register BITBOARD padvances1_all, empty, checksqs;
  register int from, to, temp, common;
  register int king_square, checkers, checking_square;
  register int check_direction1 = 0, check_direction2 = 0;

/*
 ************************************************************
 *                                                          *
 *   first, determine how many pieces are attacking the     *
 *   king and where they are, so we can figure out how to   *
 *   legally get out of check.                              *
 *                                                          *
 ************************************************************
 */
  if (wtm) {
    king_square = WhiteKingSQ;
    checksqs = AttacksTo(tree, king_square) & BlackPieces;
    checkers = PopCnt(checksqs);
    if (checkers == 1) {
      checking_square = LSB(AttacksTo(tree, king_square) & BlackPieces);
      if (PcOnSq(checking_square) != -pawn)
        check_direction1 = directions[checking_square][king_square];
      target = InterposeSquares(check_direction1, king_square, checking_square);
      target = target | (AttacksTo(tree, king_square) & BlackPieces);
      target = target | BlackKing;
    } else {
      target = BlackKing;
      checking_square = LSB(checksqs);
      if (PcOnSq(checking_square) != -pawn)
        check_direction1 = directions[checking_square][king_square];
      Clear(checking_square, checksqs);
      checking_square = LSB(checksqs);
      if (PcOnSq(checking_square) != -pawn)
        check_direction2 = directions[checking_square][king_square];
    }
/*
 ************************************************************
 *                                                          *
 *   the next step is to produce the set of valid           *
 *   destination squares.  for king moves, this is simply   *
 *   the set of squares that are not attacked by enemy      *
 *   pieces (if there are any such squares.)                *
 *                                                          *
 *   then, if the checking piece is not a knight, we need   *
 *   to know the checking direction so that we can either   *
 *   move the king "off" of that direction, or else "block" *
 *   that direction.                                        *
 *                                                          *
 *   first produce king moves by cycling through the        *
 *   *_king board to locate a [from] square and then        *
 *   cycling through attacks_to[] to locate to squares      *
 *   that the king on [from] attacks.                       *
 *                                                          *
 ************************************************************
 */
    from = king_square;
    moves = king_attacks[from] & ~WhitePieces;
    temp = from + (king << 12);
    while (moves) {
      to = MSB(moves);
      if (!Attacked(tree, to, 0)
          && (directions[from][to] != check_direction1)
          && (directions[from][to] != check_direction2))
        *move++ = temp | (to << 6) | ((-PcOnSq(to)) << 15);
      Clear(to, moves);
    }
/*
 ************************************************************
 *                                                          *
 *   now, produce knight moves by cycling through the       *
 *   *_knight board to locate a [from] square and then      *
 *   cycling through knight_attacks[] to locate to squares  *
 *   that a knight on [from] attacks.                       *
 *                                                          *
 ************************************************************
 */
    if (checkers == 1) {
      piecebd = WhiteKnights;
      while (piecebd) {
        from = MSB(piecebd);
        if (!PinnedOnKing(tree, wtm, from)) {
          moves = knight_attacks[from] & target;
          temp = from + (knight << 12);
          while (moves) {
            to = MSB(moves);
            *move++ = temp | (to << 6) | ((-PcOnSq(to)) << 15);
            Clear(to, moves);
          }
        }
        Clear(from, piecebd);
      }
/*
 ************************************************************
 *                                                          *
 *   now, produce bishop moves by cycling through the       *
 *   *_bishop board to locate a [from] square and then      *
 *   generate the AttacksFrom() bitmap which supplies the   *
 *   list of valid <to> squares.                            *
 *                                                          *
 ************************************************************
 */
      piecebd = WhiteBishops;
      while (piecebd) {
        from = MSB(piecebd);
        if (!PinnedOnKing(tree, wtm, from)) {
          moves = AttacksBishop(from) & target;
          temp = from + (bishop << 12);
          while (moves) {
            to = MSB(moves);
            *move++ = temp | (to << 6) | ((-PcOnSq(to)) << 15);
            Clear(to, moves);
          }
        }
        Clear(from, piecebd);
      }
/*
 ************************************************************
 *                                                          *
 *   now, produce rook moves by cycling through the         *
 *   *_rook board to locate a [from] square and then        *
 *   generate the AttacksFrom() bitmap which supplies the   *
 *   list of valid <to> squares.                            *
 *                                                          *
 ************************************************************
 */
      piecebd = WhiteRooks;
      while (piecebd) {
        from = MSB(piecebd);
        if (!PinnedOnKing(tree, wtm, from)) {
          moves = AttacksRook(from) & target;
          temp = from + (rook << 12);
          while (moves) {
            to = MSB(moves);
            *move++ = temp | (to << 6) | ((-PcOnSq(to)) << 15);
            Clear(to, moves);
          }
        }
        Clear(from, piecebd);
      }
/*
 ************************************************************
 *                                                          *
 *   now, produce queen moves by cycling through the        *
 *   *_queen board to locate a [from] square and then       *
 *   generate the AttacksFrom() bitmap which supplies the   *
 *   list of valid <to> squares.                            *
 *                                                          *
 ************************************************************
 */
      piecebd = WhiteQueens;
      while (piecebd) {
        from = MSB(piecebd);
        if (!PinnedOnKing(tree, wtm, from)) {
          moves = AttacksQueen(from) & target;
          temp = from + (queen << 12);
          while (moves) {
            to = MSB(moves);
            *move++ = temp | (to << 6) | ((-PcOnSq(to)) << 15);
            Clear(to, moves);
          }
        }
        Clear(from, piecebd);
      }
/*
 ************************************************************
 *                                                          *
 *   now, produce pawn moves.  this is done differently due *
 *   to inconsistencies in the way a pawn moves when it     *
 *   captures as opposed to normal non-capturing moves.     *
 *   another exception is capturing enpassant.  the first   *
 *   step is to generate all possible pawn moves.  we do    *
 *   this in 2 operations:  (1) shift the pawns forward one *
 *   rank then and with empty squares;  (2) shift the pawns *
 *   forward two ranks and then and with empty squares.     *
 *                                                          *
 ************************************************************
 */
      empty = ~Occupied;
      targetp = target & empty;
      padvances1 = WhitePawns << 8 & targetp;
      padvances1_all = WhitePawns << 8 & empty;
      padvances2 = ((padvances1_all & ((BITBOARD) 255 << 16)) << 8) & targetp;
/*
 ************************************************************
 *                                                          *
 *   now that we got 'em, we simply enumerate the to        *
 *   squares as before, but in four steps since we have     *
 *   four sets of potential moves.                          *
 *                                                          *
 ************************************************************
 */
      while (padvances2) {
        to = MSB(padvances2);
        if (!PinnedOnKing(tree, wtm, to - 16))
          *move++ = (to - 16) | (to << 6) | (pawn << 12);
        Clear(to, padvances2);
      }
      while (padvances1) {
        to = MSB(padvances1);
        if (!PinnedOnKing(tree, wtm, to - 8)) {
          common = (to - 8) | (to << 6) | (pawn << 12);
          if (to < 56)
            *move++ = common;
          else {
            *move++ = common | (queen << 18);
            *move++ = common | (rook << 18);
            *move++ = common | (bishop << 18);
            *move++ = common | (knight << 18);
          }
        }
        Clear(to, padvances1);
      }

      targetc = BlackPieces | EnPassantTarget(ply);
      targetc = targetc & target;
      if (BlackPawns & target & EnPassantTarget(ply) >> 8)
        targetc = targetc | EnPassantTarget(ply);
      pcapturesl = (WhitePawns & mask_left_edge) << 7 & targetc;
      pcapturesr = (WhitePawns & mask_right_edge) << 9 & targetc;
      while (pcapturesl) {
        to = MSB(pcapturesl);
        if (!PinnedOnKing(tree, wtm, to - 7)) {
          common = (to - 7) | (to << 6) | (pawn << 12);
          if (to < 56) {
            register int cap = (PcOnSq(to)) ? -PcOnSq(to) : pawn;

            *move++ = common | (cap << 15);
          } else {
            *move++ = common | ((-PcOnSq(to)) << 15) | (queen << 18);
            *move++ = common | ((-PcOnSq(to)) << 15) | (rook << 18);
            *move++ = common | ((-PcOnSq(to)) << 15) | (bishop << 18);
            *move++ = common | ((-PcOnSq(to)) << 15) | (knight << 18);
          }
        }
        Clear(to, pcapturesl);
      }
      while (pcapturesr) {
        to = MSB(pcapturesr);
        if (!PinnedOnKing(tree, wtm, to - 9)) {
          common = (to - 9) | (to << 6) | (pawn << 12);
          if (to < 56) {
            register int cap = (PcOnSq(to)) ? -PcOnSq(to) : pawn;

            *move++ = common | (cap << 15);
          } else {
            *move++ = common | ((-PcOnSq(to)) << 15) | (queen << 18);
            *move++ = common | ((-PcOnSq(to)) << 15) | (rook << 18);
            *move++ = common | ((-PcOnSq(to)) << 15) | (bishop << 18);
            *move++ = common | ((-PcOnSq(to)) << 15) | (knight << 18);
          }
        }
        Clear(to, pcapturesr);
      }
    }
  }
/*
 ************************************************************
 *                                                          *
 *   first, determine how many pieces are attacking the     *
 *   king and where they are, so we can figure out how to   *
 *   legally get out of check.                              *
 *                                                          *
 ************************************************************
 */
  else {
    king_square = BlackKingSQ;
    checksqs = AttacksTo(tree, king_square) & WhitePieces;
    checkers = PopCnt(checksqs);
    if (checkers == 1) {
      checking_square = LSB(AttacksTo(tree, king_square) & WhitePieces);
      if (PcOnSq(checking_square) != pawn)
        check_direction1 = directions[checking_square][king_square];
      target = InterposeSquares(check_direction1, king_square, checking_square);
      target = target | (AttacksTo(tree, king_square) & WhitePieces);
      target = target | WhiteKing;
    } else {
      target = WhiteKing;
      checking_square = LSB(checksqs);
      if (PcOnSq(checking_square) != pawn)
        check_direction1 = directions[checking_square][king_square];
      Clear(checking_square, checksqs);
      checking_square = LSB(checksqs);
      if (PcOnSq(checking_square) != pawn)
        check_direction2 = directions[checking_square][king_square];
    }
/*
 ************************************************************
 *                                                          *
 *   the first step is to produce the set of valid          *
 *   destination squares.  for king moves, this is simply   *
 *   the set of squares that are not attacked by enemy      *
 *   pieces (if there are any such squares.)                *
 *                                                          *
 *   then, if the checking piece is not a knight, we need   *
 *   to know the checking direction so that we can either   *
 *   move the king "off" of that direction, or else "block" *
 *   that direction.                                        *
 *                                                          *
 *   first produce king moves by cycling through the        *
 *   *_king board to locate a [from] square and then        *
 *   cycling through attacks_to[] to locate to squares      *
 *   that the king on [from] attacks.                       *
 *                                                          *
 ************************************************************
 */
    from = king_square;
    moves = king_attacks[from] & ~BlackPieces;
    temp = from + (king << 12);
    while (moves) {
      to = LSB(moves);
      if (!Attacked(tree, to, 1)
          && (directions[from][to] != check_direction1)
          && (directions[from][to] != check_direction2))
        *move++ = temp | (to << 6) | (PcOnSq(to) << 15);
      Clear(to, moves);
    }
/*
 ************************************************************
 *                                                          *
 *   now, produce knight moves by cycling through the       *
 *   *_knight board to locate a [from] square and then      *
 *   cycling through knight_attacks[] to locate to squares  *
 *   that a knight on [from] attacks.                       *
 *                                                          *
 ************************************************************
 */
    if (checkers == 1) {
      piecebd = BlackKnights;
      while (piecebd) {
        from = LSB(piecebd);
        if (!PinnedOnKing(tree, wtm, from)) {
          moves = knight_attacks[from] & target;
          temp = from + (knight << 12);
          while (moves) {
            to = LSB(moves);
            *move++ = temp | (to << 6) | (PcOnSq(to) << 15);
            Clear(to, moves);
          }
        }
        Clear(from, piecebd);
      }
/*
 ************************************************************
 *                                                          *
 *   now, produce bishop moves by cycling through the       *
 *   *_bishop board to locate a [from] square and then      *
 *   generate the AttacksFrom() bitmap which supplies the   *
 *   list of valid <to> squares.                            *
 *                                                          *
 ************************************************************
 */
      piecebd = BlackBishops;
      while (piecebd) {
        from = LSB(piecebd);
        if (!PinnedOnKing(tree, wtm, from)) {
          moves = AttacksBishop(from) & target;
          temp = from + (bishop << 12);
          while (moves) {
            to = LSB(moves);
            *move++ = temp | (to << 6) | (PcOnSq(to) << 15);
            Clear(to, moves);
          }
        }
        Clear(from, piecebd);
      }
/*
 ************************************************************
 *                                                          *
 *   now, produce rook moves by cycling through the         *
 *   *_rook board to locate a [from] square and then        *
 *   generate the AttacksFrom() bitmap which supplies the   *
 *   list of valid <to> squares.                            *
 *                                                          *
 ************************************************************
 */
      piecebd = BlackRooks;
      while (piecebd) {
        from = LSB(piecebd);
        if (!PinnedOnKing(tree, wtm, from)) {
          moves = AttacksRook(from) & target;
          temp = from + (rook << 12);
          while (moves) {
            to = LSB(moves);
            *move++ = temp | (to << 6) | (PcOnSq(to) << 15);
            Clear(to, moves);
          }
        }
        Clear(from, piecebd);
      }
/*
 ************************************************************
 *                                                          *
 *   now, produce queen moves by cycling through the        *
 *   *_queen board to locate a [from] square and then       *
 *                                                          *
 ************************************************************
 */
      piecebd = BlackQueens;
      while (piecebd) {
        from = LSB(piecebd);
        if (!PinnedOnKing(tree, wtm, from)) {
          moves = AttacksQueen(from) & target;
          temp = from + (queen << 12);
          while (moves) {
            to = LSB(moves);
            *move++ = temp | (to << 6) | (PcOnSq(to) << 15);
            Clear(to, moves);
          }
        }
        Clear(from, piecebd);
      }
/*
 ************************************************************
 *                                                          *
 *   now, produce pawn moves.  this is done differently due *
 *   to inconsistencies in the way a pawn moves when it     *
 *   captures as opposed to normal non-capturing moves.     *
 *   another exception is capturing enpassant.  the first   *
 *   step is to generate all possible pawn moves.  we do    *
 *   this in 4 operations:  (1) shift the pawns forward one *
 *   rank then and with empty squares;  (2) shift the pawns *
 *   forward two ranks and then and with empty squares;     *
 *   (3) remove the a-pawn(s) then shift the pawns          *
 *   diagonally left then and with enemy occupied squares;  *
 *   (4) remove the h-pawn(s) then shift the pawns          *
 *   diagonally right then and with enemy occupied squares; *
 *   note that enemy occupied squares includes the special  *
 *   case of the enpassant target square also.              *
 *                                                          *
 ************************************************************
 */
      empty = ~Occupied;
      targetp = target & empty;
      padvances1 = BlackPawns >> 8 & targetp;
      padvances1_all = BlackPawns >> 8 & empty;
      padvances2 = ((padvances1_all & ((BITBOARD) 255 << 40)) >> 8) & targetp;
/*
 ************************************************************
 *                                                          *
 *   now that we got 'em, we simply enumerate the to        *
 *   squares as before, but in four steps since we have     *
 *   four sets of potential moves.                          *
 *                                                          *
 ************************************************************
 */
      while (padvances2) {
        to = LSB(padvances2);
        if (!PinnedOnKing(tree, wtm, to + 16))
          *move++ = (to + 16) | (to << 6) | (pawn << 12);
        Clear(to, padvances2);
      }
      while (padvances1) {
        to = LSB(padvances1);
        if (!PinnedOnKing(tree, wtm, to + 8)) {
          common = (to + 8) | (to << 6) | (pawn << 12);
          if (to > 7)
            *move++ = common;
          else {
            *move++ = common | (queen << 18);
            *move++ = common | (rook << 18);
            *move++ = common | (bishop << 18);
            *move++ = common | (knight << 18);
          }
        }
        Clear(to, padvances1);
      }

      targetc = WhitePieces | EnPassantTarget(ply);
      targetc = targetc & target;
      if (WhitePawns & target & EnPassantTarget(ply) << 8)
        targetc = targetc | EnPassantTarget(ply);
      pcapturesl = (BlackPawns & mask_left_edge) >> 9 & targetc;
      pcapturesr = (BlackPawns & mask_right_edge) >> 7 & targetc;
      while (pcapturesl) {
        to = LSB(pcapturesl);
        if (!PinnedOnKing(tree, wtm, to + 9)) {
          common = (to + 9) | (to << 6) | (pawn << 12);
          if (to > 7) {
            register int cap = (PcOnSq(to)) ? PcOnSq(to) : pawn;

            *move++ = common | (cap << 15);
          } else {
            *move++ = common | (PcOnSq(to) << 15) | (queen << 18);
            *move++ = common | (PcOnSq(to) << 15) | (rook << 18);
            *move++ = common | (PcOnSq(to) << 15) | (bishop << 18);
            *move++ = common | (PcOnSq(to) << 15) | (knight << 18);
          }
        }
        Clear(to, pcapturesl);
      }
      while (pcapturesr) {
        to = LSB(pcapturesr);
        if (!PinnedOnKing(tree, wtm, to + 7)) {
          common = (to + 7) | (to << 6) | (pawn << 12);
          if (to > 7) {
            register int cap = (PcOnSq(to)) ? PcOnSq(to) : pawn;

            *move++ = common | (cap << 15);
          } else {
            *move++ = common | (PcOnSq(to) << 15) | (queen << 18);
            *move++ = common | (PcOnSq(to) << 15) | (rook << 18);
            *move++ = common | (PcOnSq(to) << 15) | (bishop << 18);
            *move++ = common | (PcOnSq(to) << 15) | (knight << 18);
          }
        }
        Clear(to, pcapturesr);
      }
    }
  }
  return (move);
}

/* modified 07/18/06 */
/*
 *******************************************************************************
 *                                                                             *
 *   GenerateNonCaptures() is used to generate non-capture moves from the      *
 *   current position.                                                         *
 *                                                                             *
 *   once the valid destination squares are known, we have to locate a friendly*
 *   piece to get a attacks_to[] entry.  we then produce the moves for this    *
 *   piece by using the source square as [from] and enumerating each square it *
 *   attacks into [to].                                                        *
 *                                                                             *
 *   pawns are handled differently.  regular pawn moves are produced by        *
 *   shifting the pawn bitmap 8 bits "forward" and anding this with the        *
 *   complement of the occupied squares bitmap  double advances are then       *
 *   produced by anding the pawn bitmap with a mask containing 1's on the      *
 *   second rank, shifting this 16 bits "forward" and then anding this with    *
 *   the complement of the occupied squares bitmap as before.  if [to]         *
 *   reaches the 8th rank, we produce a set of four moves, promoting the pawn  *
 *   to knight, bishop, rook and queen.                                        *
 *                                                                             *
 *******************************************************************************
 */
int *GenerateNonCaptures(TREE * RESTRICT tree, int ply, int wtm, int *move)
{
  register BITBOARD target, piecebd, moves;
  register BITBOARD padvances1, padvances2, pcapturesl, pcapturesr;
  register int from, to, temp, common;

  if (wtm) {
/*
 ************************************************************
 *                                                          *
 *   first, produce castling moves if it is legal.          *
 *                                                          *
 ************************************************************
 */
    if (WhiteCastle(ply) > 0) {
      if ((WhiteCastle(ply) & 1) && !(Occupied & mask_white_OO)
          && !Attacked(tree, E1, 0) && !Attacked(tree, F1, 0)
          && !Attacked(tree, G1, 0)) {
        *move++ = 12676;
      }
      if ((WhiteCastle(ply) & 2) && !(Occupied & mask_white_OOO)
          && !Attacked(tree, C1, 0) && !Attacked(tree, D1, 0)
          && !Attacked(tree, E1, 0)) {
        *move++ = 12420;
      }
    }
/*
 ************************************************************
 *                                                          *
 *   now, produce knight moves by cycling through the       *
 *   *_knight board to locate a [from] square and then      *
 *   cycling through knight_attacks[] to locate to squares  *
 *   that a knight on [from] attacks.                       *
 *                                                          *
 ************************************************************
 */
    target = ~Occupied;
    piecebd = WhiteKnights;
    while (piecebd) {
      from = MSB(piecebd);
      moves = knight_attacks[from] & target;
      temp = from + (knight << 12);
      while (moves) {
        to = MSB(moves);
        *move++ = temp | (to << 6);
        Clear(to, moves);
      }
      Clear(from, piecebd);
    }
/*
 ************************************************************
 *                                                          *
 *   now, produce bishop moves by cycling through the       *
 *   *_bishop board to locate a [from] square and then      *
 *   generate the AttacksFrom() bitmap which supplies the   *
 *   list of valid <to> squares.                            *
 *                                                          *
 ************************************************************
 */
    piecebd = WhiteBishops;
    while (piecebd) {
      from = MSB(piecebd);
      moves = AttacksBishop(from) & target;
      temp = from + (bishop << 12);
      while (moves) {
        to = MSB(moves);
        *move++ = temp | (to << 6);
        Clear(to, moves);
      }
      Clear(from, piecebd);
    }
/*
 ************************************************************
 *                                                          *
 *   now, produce rook moves by cycling through the         *
 *   *_rook board to locate a [from] square and then        *
 *   generate the AttacksFrom() bitmap which supplies the   *
 *   list of valid <to> squares.                            *
 *                                                          *
 ************************************************************
 */
    piecebd = WhiteRooks;
    while (piecebd) {
      from = MSB(piecebd);
      moves = AttacksRook(from) & target;
      temp = from + (rook << 12);
      while (moves) {
        to = MSB(moves);
        *move++ = temp | (to << 6);
        Clear(to, moves);
      }
      Clear(from, piecebd);
    }
/*
 ************************************************************
 *                                                          *
 *   now, produce queen moves by cycling through the        *
 *   *_queen board to locate a [from] square and then       *
 *   generate the AttacksFrom() bitmap which supplies the   *
 *   list of valid <to> squares.                            *
 *                                                          *
 ************************************************************
 */
    piecebd = WhiteQueens;
    while (piecebd) {
      from = MSB(piecebd);
      moves = AttacksQueen(from) & target;
      temp = from + (queen << 12);
      while (moves) {
        to = MSB(moves);
        *move++ = temp | (to << 6);
        Clear(to, moves);
      }
      Clear(from, piecebd);
    }
/*
 ************************************************************
 *                                                          *
 *   now, produce king moves by cycling through the         *
 *   *_king board to locate a [from] square and then        *
 *   cycling through king_attacks[] to locate to squares    *
 *   that a king on [from] attacks.                         *
 *                                                          *
 ************************************************************
 */
    from = WhiteKingSQ;
    moves = king_attacks[from] & target;
    temp = from + (king << 12);
    while (moves) {
      to = MSB(moves);
      *move++ = temp | (to << 6);
      Clear(to, moves);
    }
/*
 ************************************************************
 *                                                          *
 *   now, produce pawn moves.  this is done differently due *
 *   to inconsistencies in the way a pawn moves when it     *
 *   captures as opposed to normal non-capturing moves.     *
 *   first we generate all possible pawn moves.  we do      *
 *   this in 4 operations:  (1) shift the pawns forward one *
 *   rank then and with empty squares;  (2) shift the pawns *
 *   forward two ranks and then and with empty squares;     *
 *   (3) remove the a-pawn(s) then shift the pawns          *
 *   diagonally left then and with enemy occupied squares;  *
 *   (4) remove the h-pawn(s) then shift the pawns          *
 *   diagonally right then and with enemy occupied squares. *
 *   note that the only captures produced are under-        *
 *   promotions, because the rest were done in GenCap.      *
 *                                                          *
 ************************************************************
 */
    padvances1 = WhitePawns << 8 & target;
    padvances2 = (padvances1 & mask_advance_2_w) << 8 & target;
/*
 ************************************************************
 *                                                          *
 *   now that we got 'em, we simply enumerate the to        *
 *   squares as before, but in four steps since we have     *
 *   four sets of potential moves.                          *
 *                                                          *
 ************************************************************
 */
    while (padvances2) {
      to = MSB(padvances2);
      *move++ = (to - 16) | (to << 6) | (pawn << 12);
      Clear(to, padvances2);
    }

    while (padvances1) {
      to = MSB(padvances1);
      if (to < 56)
        *move++ = (to - 8) | (to << 6) | (pawn << 12);
      else {
        *move++ = (to - 8) | (to << 6) | (pawn << 12) | (rook << 18);
        *move++ = (to - 8) | (to << 6) | (pawn << 12) | (bishop << 18);
        *move++ = (to - 8) | (to << 6) | (pawn << 12) | (knight << 18);
      }
      Clear(to, padvances1);
    }
/*
 ************************************************************
 *                                                          *
 *   generate the rest of the capture/promotions here since *
 *   GenerateCaptures() only generates captures that are    *
 *   promotions to a queen.                                 *
 *                                                          *
 ************************************************************
 */
    target = BlackPieces & rank_mask[RANK8];
    pcapturesl = (WhitePawns & mask_left_edge) << 7 & target;
    pcapturesr = (WhitePawns & mask_right_edge) << 9 & target;
    while (pcapturesl) {
      to = MSB(pcapturesl);
      common = (to - 7) | (to << 6) | (pawn << 12);
      *move++ = common | ((-PcOnSq(to)) << 15) | (rook << 18);
      *move++ = common | ((-PcOnSq(to)) << 15) | (bishop << 18);
      *move++ = common | ((-PcOnSq(to)) << 15) | (knight << 18);
      Clear(to, pcapturesl);
    }
    while (pcapturesr) {
      to = MSB(pcapturesr);
      common = (to - 9) | (to << 6) | (pawn << 12);
      *move++ = common | ((-PcOnSq(to)) << 15) | (rook << 18);
      *move++ = common | ((-PcOnSq(to)) << 15) | (bishop << 18);
      *move++ = common | ((-PcOnSq(to)) << 15) | (knight << 18);
      Clear(to, pcapturesr);
    }
  }
/*
 ************************************************************
 *                                                          *
 *   first, produce castling moves if it is legal.          *
 *                                                          *
 ************************************************************
 */
  else {
    if (BlackCastle(ply) > 0) {
      if ((BlackCastle(ply) & 1) && !(Occupied & mask_black_OO)
          && !Attacked(tree, E8, 1) && !Attacked(tree, F8, 1)
          && !Attacked(tree, G8, 1)) {
        *move++ = 16316;
      }
      if ((BlackCastle(ply) & 2) && !(Occupied & mask_black_OOO)
          && !Attacked(tree, C8, 1) && !Attacked(tree, D8, 1)
          && !Attacked(tree, E8, 1)) {
        *move++ = 16060;
      }
    }
/*
 ************************************************************
 *                                                          *
 *   now, produce knight moves by cycling through the       *
 *   *_knight board to locate a [from] square and then      *
 *   cycling through knight_attacks[] to locate to squares  *
 *   that a knight on [from] attacks.                       *
 *                                                          *
 ************************************************************
 */
    target = ~Occupied;
    piecebd = BlackKnights;
    while (piecebd) {
      from = LSB(piecebd);
      moves = knight_attacks[from] & target;
      temp = from + (knight << 12);
      while (moves) {
        to = LSB(moves);
        *move++ = temp | (to << 6);
        Clear(to, moves);
      }
      Clear(from, piecebd);
    }
/*
 ************************************************************
 *                                                          *
 *   now, produce bishop moves by cycling through the       *
 *   *_bishop board to locate a [from] square and then      *
 *   generate the AttacksFrom() bitmap which supplies the   *
 *   list of valid <to> squares.                            *
 *                                                          *
 ************************************************************
 */
    piecebd = BlackBishops;
    while (piecebd) {
      from = LSB(piecebd);
      moves = AttacksBishop(from) & target;
      temp = from + (bishop << 12);
      while (moves) {
        to = LSB(moves);
        *move++ = temp | (to << 6);
        Clear(to, moves);
      }
      Clear(from, piecebd);
    }
/*
 ************************************************************
 *                                                          *
 *   now, produce rook moves by cycling through the         *
 *   *_rook board to locate a [from] square and then        *
 *   generate the AttacksFrom() bitmap which supplies the   *
 *   list of valid <to> squares.                            *
 *                                                          *
 ************************************************************
 */
    piecebd = BlackRooks;
    while (piecebd) {
      from = LSB(piecebd);
      moves = AttacksRook(from) & target;
      temp = from + (rook << 12);
      while (moves) {
        to = LSB(moves);
        *move++ = temp | (to << 6);
        Clear(to, moves);
      }
      Clear(from, piecebd);
    }
/*
 ************************************************************
 *                                                          *
 *   now, produce queen moves by cycling through the        *
 *   *_queen board to locate a [from] square and then       *
 *   generate the AttacksFrom() bitmap which supplies the   *
 *   list of valid <to> squares.                            *
 *                                                          *
 ************************************************************
 */
    piecebd = BlackQueens;
    while (piecebd) {
      from = LSB(piecebd);
      moves = AttacksQueen(from) & target;
      temp = from + (queen << 12);
      while (moves) {
        to = LSB(moves);
        *move++ = temp | (to << 6);
        Clear(to, moves);
      }
      Clear(from, piecebd);
    }
/*
 ************************************************************
 *                                                          *
 *   now, produce king moves by cycling through the         *
 *   *_king board to locate a [from] square and then        *
 *   cycling through king_attacks[] to locate to squares    *
 *   that a king on [from] attacks.                         *
 *                                                          *
 ************************************************************
 */
    from = BlackKingSQ;
    moves = king_attacks[from] & target;
    temp = from + (king << 12);
    while (moves) {
      to = LSB(moves);
      *move++ = temp | (to << 6);
      Clear(to, moves);
    }
/*
 ************************************************************
 *                                                          *
 *   now, produce pawn moves.  this is done differently due *
 *   to inconsistencies in the way a pawn moves when it     *
 *   captures as opposed to normal non-capturing moves.     *
 *   first we generate all possible pawn moves.  we do      *
 *   this in 4 operations:  (1) shift the pawns forward one *
 *   rank then and with empty squares;  (2) shift the pawns *
 *   forward two ranks and then and with empty squares;     *
 *   (3) remove the a-pawn(s) then shift the pawns          *
 *   diagonally left then and with enemy occupied squares;  *
 *   (4) remove the h-pawn(s) then shift the pawns          *
 *   diagonally right then and with enemy occupied squares. *
 *   note that the only captures produced are under-        *
 *   promotions, because the rest were done in GenCap.      *
 *                                                          *
 ************************************************************
 */
    padvances1 = BlackPawns >> 8 & target;
    padvances2 = (padvances1 & mask_advance_2_b) >> 8 & target;
/*
 ************************************************************
 *                                                          *
 *   now that we got 'em, we simply enumerate the to        *
 *   squares as before, but in four steps since we have     *
 *   four sets of potential moves.                          *
 *                                                          *
 ************************************************************
 */
    while (padvances2) {
      to = LSB(padvances2);
      *move++ = (to + 16) | (to << 6) | (pawn << 12);
      Clear(to, padvances2);
    }
    while (padvances1) {
      to = LSB(padvances1);
      common = (to + 8) | (to << 6) | (pawn << 12);
      if (to > 7)
        *move++ = common;
      else {
        *move++ = common | (rook << 18);
        *move++ = common | (bishop << 18);
        *move++ = common | (knight << 18);
      }
      Clear(to, padvances1);
    }
/*
 ************************************************************
 *                                                          *
 *   generate the rest of the capture/promotions here since *
 *   GenerateCaptures() only generates captures that are    *
 *   promotions to a queen.                                 *
 *                                                          *
 ************************************************************
 */
    target = WhitePieces & rank_mask[RANK1];
    pcapturesl = (BlackPawns & mask_left_edge) >> 9 & target;
    pcapturesr = (BlackPawns & mask_right_edge) >> 7 & target;
    while (pcapturesl) {
      to = LSB(pcapturesl);
      common = (to + 9) | (to << 6) | (pawn << 12);
      *move++ = common | (PcOnSq(to) << 15) | (rook << 18);
      *move++ = common | (PcOnSq(to) << 15) | (bishop << 18);
      *move++ = common | (PcOnSq(to) << 15) | (knight << 18);
      Clear(to, pcapturesl);
    }
    while (pcapturesr) {
      to = LSB(pcapturesr);
      common = (to + 7) | (to << 6) | (pawn << 12);
      *move++ = common | (PcOnSq(to) << 15) | (rook << 18);
      *move++ = common | (PcOnSq(to) << 15) | (bishop << 18);
      *move++ = common | (PcOnSq(to) << 15) | (knight << 18);
      Clear(to, pcapturesr);
    }
  }
  return (move);
}
