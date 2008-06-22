#include <stdio.h>
#include <stdlib.h>
#include "chess.h"
#include "data.h"

/* last modified 07/18/06 */
/*
 *******************************************************************************
 *                                                                             *
 *   UnmakeMove() is responsible for updating the position database whenever a *
 *   move is retracted.  it is the exact inverse of MakeMove().                *
 *                                                                             *
 *******************************************************************************
 */
void UnmakeMove(TREE * RESTRICT tree, int ply, int move, int wtm)
{
  register int piece, from, to, captured, promote;
  register int i;
  BITBOARD bit_move;

/*
 ************************************************************
 *                                                          *
 *   first, take care of the hash key if there's a possible *
 *   enpassant pawn capture.                                *
 *                                                          *
 ************************************************************
 */
  HashKey = tree->save_hash_key[ply];
  PawnHashKey = tree->save_pawn_hash_key[ply];
/*
 ************************************************************
 *                                                          *
 *   now do the piece-specific things by calling the        *
 *   appropriate routine.                                   *
 *                                                          *
 ************************************************************
 */
  piece = Piece(move);
  from = From(move);
  to = To(move);
  captured = Captured(move);
  promote = Promote(move);
UnmakePieceMove:
  bit_move = SetMask(from) | SetMask(to);
  PcOnSq(to) = 0;
  switch (piece) {
/*
 *******************************************************************************
 *                                                                             *
 *   unmake pawn moves.                                                        *
 *                                                                             *
 *******************************************************************************
 */
  case pawn:
    if (wtm) {
      ClearSet(bit_move, WhitePawns);
      ClearSet(bit_move, WhitePieces);
      PcOnSq(from) = pawn;
      if (captured == 1) {
        if (EnPassant(ply) == to) {
          TotalPieces++;
          Set(to - 8, BlackPawns);
          Set(to - 8, BlackPieces);
          PcOnSq(to - 8) = -pawn;
          Material -= pawn_value;
          TotalBlackPawns++;
          captured = 0;
        }
      }
/*
 **********************************************************************
 *                                                                    *
 *  if this is a pawn promotion, remove the pawn from the counts      *
 *  then update the correct piece board to reflect the piece just     *
 *  created.                                                          *
 *                                                                    *
 **********************************************************************
 */
      if (promote) {
        TotalWhitePawns++;
        Material += pawn_value;
        Clear(to, WhitePawns);
        Clear(to, WhitePieces);
        switch (promote) {
        case knight:
          Clear(to, WhiteKnights);
          TotalWhitePieces -= knight_v;
          TotalWhiteKnights--;
          Material -= knight_value;
          break;
        case bishop:
          Clear(to, WhiteBishops);
          Clear(to, BishopsQueens);
          TotalWhitePieces -= bishop_v;
          TotalWhiteBishops--;
          Material -= bishop_value;
          break;
        case rook:
          Clear(to, WhiteRooks);
          Clear(to, RooksQueens);
          TotalWhitePieces -= rook_v;
          TotalWhiteRooks--;
          Material -= rook_value;
          break;
        case queen:
          Clear(to, WhiteQueens);
          Clear(to, BishopsQueens);
          Clear(to, RooksQueens);
          TotalWhitePieces -= queen_v;
          TotalWhiteQueens--;
          Material -= queen_value;
          break;
        }
      }
    } else {
      ClearSet(bit_move, BlackPawns);
      ClearSet(bit_move, BlackPieces);
      PcOnSq(from) = -pawn;
      if (captured == 1) {
        if (EnPassant(ply) == to) {
          TotalPieces++;
          Set(to + 8, WhitePawns);
          Set(to + 8, WhitePieces);
          PcOnSq(to + 8) = pawn;
          Material += pawn_value;
          TotalWhitePawns++;
          captured = 0;
        }
      }
/*
 **********************************************************************
 *                                                                    *
 *  if this is a pawn promotion, remove the pawn from the counts      *
 *  then update the correct piece board to reflect the piece just     *
 *  created.                                                          *
 *                                                                    *
 **********************************************************************
 */
      if (promote) {
        TotalBlackPawns++;
        Material -= pawn_value;
        Clear(to, BlackPawns);
        Clear(to, BlackPieces);
        switch (promote) {
        case knight:
          Clear(to, BlackKnights);
          TotalBlackPieces -= knight_v;
          TotalBlackKnights--;
          Material += knight_value;
          break;
        case bishop:
          Clear(to, BlackBishops);
          Clear(to, BishopsQueens);
          TotalBlackPieces -= bishop_v;
          TotalBlackBishops--;
          Material += bishop_value;
          break;
        case rook:
          Clear(to, BlackRooks);
          Clear(to, RooksQueens);
          TotalBlackPieces -= rook_v;
          TotalBlackRooks--;
          Material += rook_value;
          break;
        case queen:
          Clear(to, BlackQueens);
          Clear(to, BishopsQueens);
          Clear(to, RooksQueens);
          TotalBlackPieces -= queen_v;
          TotalBlackQueens--;
          Material += queen_value;
          break;
        }
      }
    }
    break;
/*
 *******************************************************************************
 *                                                                             *
 *   unmake knight moves.                                                      *
 *                                                                             *
 *******************************************************************************
 */
  case knight:
    if (wtm) {
      ClearSet(bit_move, WhiteKnights);
      ClearSet(bit_move, WhitePieces);
      PcOnSq(from) = knight;
    } else {
      ClearSet(bit_move, BlackKnights);
      ClearSet(bit_move, BlackPieces);
      PcOnSq(from) = -knight;
    }
    break;
/*
 *******************************************************************************
 *                                                                             *
 *   unmake bishop moves.                                                      *
 *                                                                             *
 *******************************************************************************
 */
  case bishop:
    ClearSet(bit_move, BishopsQueens);
    if (wtm) {
      ClearSet(bit_move, WhiteBishops);
      ClearSet(bit_move, WhitePieces);
      PcOnSq(from) = bishop;
    } else {
      ClearSet(bit_move, BlackBishops);
      ClearSet(bit_move, BlackPieces);
      PcOnSq(from) = -bishop;
    }
    break;
/*
 *******************************************************************************
 *                                                                             *
 *   unmake rook moves.                                                        *
 *                                                                             *
 *******************************************************************************
 */
  case rook:
    ClearSet(bit_move, RooksQueens);
    if (wtm) {
      ClearSet(bit_move, WhiteRooks);
      ClearSet(bit_move, WhitePieces);
      PcOnSq(from) = rook;
    } else {
      ClearSet(bit_move, BlackRooks);
      ClearSet(bit_move, BlackPieces);
      PcOnSq(from) = -rook;
    }
    break;
/*
 *******************************************************************************
 *                                                                             *
 *   unmake queen moves.                                                       *
 *                                                                             *
 *******************************************************************************
 */
  case queen:
    ClearSet(bit_move, BishopsQueens);
    ClearSet(bit_move, RooksQueens);
    if (wtm) {
      ClearSet(bit_move, WhiteQueens);
      ClearSet(bit_move, WhitePieces);
      PcOnSq(from) = queen;
    } else {
      ClearSet(bit_move, BlackQueens);
      ClearSet(bit_move, BlackPieces);
      PcOnSq(from) = -queen;
    }
    break;
/*
 *******************************************************************************
 *                                                                             *
 *   unmake king moves.                                                        *
 *                                                                             *
 *******************************************************************************
 */
  case king:
    if (wtm) {
      ClearSet(bit_move, WhitePieces);
      PcOnSq(from) = king;
      WhiteKingSQ = from;
      if (abs(to - from) == 2) {
        if (to == G1) {
          from = H1;
          to = F1;
          piece = rook;
          goto UnmakePieceMove;
        } else {
          from = A1;
          to = D1;
          piece = rook;
          goto UnmakePieceMove;
        }
      }
    } else {
      ClearSet(bit_move, BlackPieces);
      PcOnSq(from) = -king;
      BlackKingSQ = from;
      if (abs(to - from) == 2) {
        if (to == G8) {
          from = H8;
          to = F8;
          piece = rook;
          goto UnmakePieceMove;
        } else {
          from = A8;
          to = D8;
          piece = rook;
          goto UnmakePieceMove;
        }
      }
    }
    break;
  }
/*
 *******************************************************************************
 *                                                                             *
 *   now it is time to restore a piece that was captured.                      *
 *                                                                             *
 *******************************************************************************
 */
  if (captured) {
    TotalPieces++;
    switch (captured) {
/*
 ************************************************************
 *                                                          *
 *   restore a captured pawn.                               *
 *                                                          *
 ************************************************************
 */
    case pawn:
      if (wtm) {
        Set(to, BlackPawns);
        Set(to, BlackPieces);
        PcOnSq(to) = -pawn;
        Material -= pawn_value;
        TotalBlackPawns++;
      } else {
        Set(to, WhitePawns);
        Set(to, WhitePieces);
        PcOnSq(to) = pawn;
        Material += pawn_value;
        TotalWhitePawns++;
      }
      break;
/*
 ************************************************************
 *                                                          *
 *   restore a captured knight.                             *
 *                                                          *
 ************************************************************
 */
    case knight:
      if (wtm) {
        Set(to, BlackKnights);
        Set(to, BlackPieces);
        PcOnSq(to) = -knight;
        TotalBlackPieces += knight_v;
        TotalBlackKnights++;
        Material -= knight_value;
      } else {
        Set(to, WhiteKnights);
        Set(to, WhitePieces);
        PcOnSq(to) = knight;
        TotalWhitePieces += knight_v;
        TotalWhiteKnights++;
        Material += knight_value;
      }
      break;
/*
 ************************************************************
 *                                                          *
 *   restore a captured bishop.                             *
 *                                                          *
 ************************************************************
 */
    case bishop:
      Set(to, BishopsQueens);
      if (wtm) {
        Set(to, BlackBishops);
        Set(to, BlackPieces);
        PcOnSq(to) = -bishop;
        TotalBlackPieces += bishop_v;
        TotalBlackBishops++;
        Material -= bishop_value;
      } else {
        Set(to, WhiteBishops);
        Set(to, WhitePieces);
        PcOnSq(to) = bishop;
        TotalWhitePieces += bishop_v;
        TotalWhiteBishops++;
        Material += bishop_value;
      }
      break;
/*
 ************************************************************
 *                                                          *
 *   restore a captured rook.                               *
 *                                                          *
 ************************************************************
 */
    case rook:
      Set(to, RooksQueens);
      if (wtm) {
        Set(to, BlackRooks);
        Set(to, BlackPieces);
        PcOnSq(to) = -rook;
        TotalBlackPieces += rook_v;
        TotalBlackRooks++;
        Material -= rook_value;
      } else {
        Set(to, WhiteRooks);
        Set(to, WhitePieces);
        PcOnSq(to) = rook;
        TotalWhitePieces += rook_v;
        TotalWhiteRooks++;
        Material += rook_value;
      }
      break;
/*
 ************************************************************
 *                                                          *
 *   restore a captured queen.                              *
 *                                                          *
 ************************************************************
 */
    case queen:
      Set(to, BishopsQueens);
      Set(to, RooksQueens);
      if (wtm) {
        Set(to, BlackQueens);
        Set(to, BlackPieces);
        PcOnSq(to) = -queen;
        TotalBlackPieces += queen_v;
        TotalBlackQueens++;
        Material -= queen_value;
      } else {
        Set(to, WhiteQueens);
        Set(to, WhitePieces);
        PcOnSq(to) = queen;
        TotalWhitePieces += queen_v;
        TotalWhiteQueens++;
        Material += queen_value;
      }
      break;
/*
 ************************************************************
 *                                                          *
 *   restore a captured king. [this is an error condition]  *
 *                                                          *
 ************************************************************
 */
    case king:
#if defined(DEBUG)
      Print(128, "captured a king (Unmake)\n");
      for (i = 1; i <= ply; i++)
        Print(128, "ply=%2d, piece=%2d,from=%2d,to=%2d,captured=%2d\n", i,
            Piece(tree->current_move[i]), From(tree->current_move[i]),
            To(tree->current_move[i]), Captured(tree->current_move[i]));
      Print(128, "ply=%2d, piece=%2d,from=%2d,to=%2d,captured=%2d\n", i, piece,
          from, to, captured);
      if (log_file)
        DisplayChessBoard(log_file, tree->pos);
#endif
      break;
    }
  }
#if defined(DEBUG)
  ValidatePosition(tree, ply, move, "UnmakeMove(1)");
#endif
  return;
}
