#include <stdio.h>
#include <stdlib.h>
#include "chess.h"
#include "data.h"

/* last modified 07/18/06 */
/*
 *******************************************************************************
 *                                                                             *
 *   MakeMove() is responsible for updating the position database whenever a   *
 *   piece is moved.  it performs the following operations:  (1) update the    *
 *   board structure itself by moving the piece and removing any captured      *
 *   piece.  (2) update the hash keys.  (3) update material counts.  (4) update*
 *   castling status.  (5) update number of moves since last reversible move.  *
 *                                                                             *
 *******************************************************************************
 */
void MakeMove(TREE * RESTRICT tree, int ply, int move, int wtm)
{
  register int piece, from, to, captured, promote;
  register int i;
  BITBOARD bit_move;

/*
 ************************************************************
 *                                                          *
 *   first, clear the EnPassant_Target bit-mask.  moving a  *
 *   pawn two ranks will set it later in MakeMove().        *
 *                                                          *
 ************************************************************
 */
#if defined(DEBUG)
  ValidatePosition(tree, ply, move, "MakeMove(1)");
#endif
  tree->position[ply + 1] = tree->position[ply];
  tree->save_hash_key[ply] = HashKey;
  tree->save_pawn_hash_key[ply] = PawnHashKey;
  if (EnPassant(ply + 1)) {
    HashEP(EnPassant(ply + 1), HashKey);
    EnPassant(ply + 1) = 0;
  }
  Rule50Moves(ply + 1)++;
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
MakePieceMove:
  bit_move = SetMask(from) | SetMask(to);
  PcOnSq(from) = 0;
  switch (piece) {
/*
 *******************************************************************************
 *                                                                             *
 *   make pawn moves.  there are two special cases:  (a) en passant captures   *
 *   where the captured pawn is not on the "to" square and must be removed in  *
 *   a different way, and (2) pawn promotions (where the "Promote" variable    *
 *   is non-zero) requires updating the appropriate bit boards since we are    *
 *   creating a new piece.                                                     *
 *                                                                             *
 *******************************************************************************
 */
  case pawn:
    if (wtm) {
      ClearSet(bit_move, WhitePawns);
      ClearSet(bit_move, WhitePieces);
      HashPW(from, HashKey);
      HashPW(from, PawnHashKey);
      HashPW(to, HashKey);
      HashPW(to, PawnHashKey);
      if (captured == 1) {
        if (!PcOnSq(to)) {
          Clear(to - 8, BlackPawns);
          Clear(to - 8, BlackPieces);
          HashPB(to - 8, HashKey);
          HashPB(to - 8, PawnHashKey);
          PcOnSq(to - 8) = 0;
          Material += pawn_value;
          TotalBlackPawns--;
          TotalPieces--;
          captured = 0;
        }
      }
      PcOnSq(to) = pawn;
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
        TotalWhitePawns--;
        Material -= pawn_value;
        Clear(to, WhitePawns);
        HashPW(to, HashKey);
        HashPW(to, PawnHashKey);
        switch (promote) {
        case knight:
          Set(to, WhiteKnights);
          HashNW(to, HashKey);
          PcOnSq(to) = knight;
          TotalWhitePieces += knight_v;
          TotalWhiteKnights++;
          Material += knight_value;
          break;
        case bishop:
          Set(to, WhiteBishops);
          Set(to, BishopsQueens);
          HashBW(to, HashKey);
          PcOnSq(to) = bishop;
          TotalWhitePieces += bishop_v;
          TotalWhiteBishops++;
          Material += bishop_value;
          break;
        case rook:
          Set(to, WhiteRooks);
          Set(to, RooksQueens);
          HashRW(to, HashKey);
          PcOnSq(to) = rook;
          TotalWhitePieces += rook_v;
          TotalWhiteRooks++;
          Material += rook_value;
          break;
        case queen:
          Set(to, WhiteQueens);
          Set(to, BishopsQueens);
          Set(to, RooksQueens);
          HashQW(to, HashKey);
          PcOnSq(to) = queen;
          TotalWhitePieces += queen_v;
          TotalWhiteQueens++;
          Material += queen_value;
          break;
        }
      } else if (((to - from) == 16) && (mask_eptest[to] & BlackPawns)) {
        EnPassant(ply + 1) = to - 8;
        HashEP(to - 8, HashKey);
      }
    } else {
      ClearSet(bit_move, BlackPawns);
      ClearSet(bit_move, BlackPieces);
      HashPB(from, HashKey);
      HashPB(from, PawnHashKey);
      HashPB(to, HashKey);
      HashPB(to, PawnHashKey);
      if (captured == 1) {
        if (!PcOnSq(to)) {
          Clear(to + 8, WhitePawns);
          Clear(to + 8, WhitePieces);
          HashPW(to + 8, HashKey);
          HashPW(to + 8, PawnHashKey);
          PcOnSq(to + 8) = 0;
          Material -= pawn_value;
          TotalWhitePawns--;
          TotalPieces--;
          captured = 0;
        }
      }
      PcOnSq(to) = -pawn;
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
        TotalBlackPawns--;
        Material += pawn_value;
        Clear(to, BlackPawns);
        HashPB(to, HashKey);
        HashPB(to, PawnHashKey);
        switch (promote) {
        case knight:
          Set(to, BlackKnights);
          HashNB(to, HashKey);
          PcOnSq(to) = -knight;
          TotalBlackPieces += knight_v;
          TotalBlackKnights++;
          Material -= knight_value;
          break;
        case bishop:
          Set(to, BlackBishops);
          Set(to, BishopsQueens);
          HashBB(to, HashKey);
          PcOnSq(to) = -bishop;
          TotalBlackPieces += bishop_v;
          TotalBlackBishops++;
          Material -= bishop_value;
          break;
        case rook:
          Set(to, BlackRooks);
          Set(to, RooksQueens);
          HashRB(to, HashKey);
          PcOnSq(to) = -rook;
          TotalBlackPieces += rook_v;
          TotalBlackRooks++;
          Material -= rook_value;
          break;
        case queen:
          Set(to, BlackQueens);
          Set(to, BishopsQueens);
          Set(to, RooksQueens);
          HashQB(to, HashKey);
          PcOnSq(to) = -queen;
          TotalBlackPieces += queen_v;
          TotalBlackQueens++;
          Material -= queen_value;
          break;
        }
      } else if (((from - to) == 16) && (mask_eptest[to] & WhitePawns)) {
        EnPassant(ply + 1) = to + 8;
        HashEP(to + 8, HashKey);
      }
    }
    Rule50Moves(ply + 1) = 0;
    break;
/*
 *******************************************************************************
 *                                                                             *
 *   make knight moves.                                                        *
 *                                                                             *
 *******************************************************************************
 */
  case knight:
    if (wtm) {
      ClearSet(bit_move, WhiteKnights);
      ClearSet(bit_move, WhitePieces);
      HashNW(from, HashKey);
      HashNW(to, HashKey);
      PcOnSq(to) = knight;
    } else {
      ClearSet(bit_move, BlackKnights);
      ClearSet(bit_move, BlackPieces);
      HashNB(from, HashKey);
      HashNB(to, HashKey);
      PcOnSq(to) = -knight;
    }
    break;
/*
 *******************************************************************************
 *                                                                             *
 *   make bishop moves.                                                        *
 *                                                                             *
 *******************************************************************************
 */
  case bishop:
    Clear(from, BishopsQueens);
    Set(to, BishopsQueens);
    if (wtm) {
      ClearSet(bit_move, WhiteBishops);
      ClearSet(bit_move, WhitePieces);
      HashBW(from, HashKey);
      HashBW(to, HashKey);
      PcOnSq(to) = bishop;
    } else {
      ClearSet(bit_move, BlackBishops);
      ClearSet(bit_move, BlackPieces);
      HashBB(from, HashKey);
      HashBB(to, HashKey);
      PcOnSq(to) = -bishop;
    }
    break;
/*
 *******************************************************************************
 *                                                                             *
 *   make rook moves.  the only special case handling required is to determine *
 *   if x_castle is non-zero [x=w or b based on side to move].  if it is non-  *
 *   zero, the value must be corrected if either rook is moving from its       *
 *   original square, so that castling with that rook becomes impossible.      *
 *                                                                             *
 *******************************************************************************
 */
  case rook:
    Clear(from, RooksQueens);
    Set(to, RooksQueens);
    if (wtm) {
      ClearSet(bit_move, WhiteRooks);
      ClearSet(bit_move, WhitePieces);
      HashRW(from, HashKey);
      HashRW(to, HashKey);
      PcOnSq(to) = rook;
      if (WhiteCastle(ply + 1) > 0) {
        if ((from == A1) && (WhiteCastle(ply + 1) & 2)) {
          WhiteCastle(ply + 1) &= 1;
          HashCastleW(1, HashKey);
        } else if ((from == H1) && (WhiteCastle(ply + 1) & 1)) {
          WhiteCastle(ply + 1) &= 2;
          HashCastleW(0, HashKey);
        }
      }
    } else {
      ClearSet(bit_move, BlackRooks);
      ClearSet(bit_move, BlackPieces);
      HashRB(from, HashKey);
      HashRB(to, HashKey);
      PcOnSq(to) = -rook;
      if (BlackCastle(ply + 1) > 0) {
        if ((from == A8) && (BlackCastle(ply + 1) & 2)) {
          BlackCastle(ply + 1) &= 1;
          HashCastleB(1, HashKey);
        } else if ((from == H8) && (BlackCastle(ply + 1) & 1)) {
          BlackCastle(ply + 1) &= 2;
          HashCastleB(0, HashKey);
        }
      }
    }
    break;
/*
 *******************************************************************************
 *                                                                             *
 *   make queen moves                                                          *
 *                                                                             *
 *******************************************************************************
 */
  case queen:
    Clear(from, BishopsQueens);
    Set(to, BishopsQueens);
    Clear(from, RooksQueens);
    Set(to, RooksQueens);
    if (wtm) {
      ClearSet(bit_move, WhiteQueens);
      ClearSet(bit_move, WhitePieces);
      HashQW(from, HashKey);
      HashQW(to, HashKey);
      PcOnSq(to) = queen;
    } else {
      ClearSet(bit_move, BlackQueens);
      ClearSet(bit_move, BlackPieces);
      HashQB(from, HashKey);
      HashQB(to, HashKey);
      PcOnSq(to) = -queen;
    }
    break;
/*
 *******************************************************************************
 *                                                                             *
 *   make king moves.  the only special case is castling, which is indicated   *
 *   by from=E1, to=G1 for o-o as an example.  the king is moving from e1-g1   *
 *   which is normally illegal.  in this case, the correct rook is also moved. *
 *                                                                             *
 *   note that moving the king in any direction resets the x_castle [x=w or b] *
 *   flag indicating that castling is not possible in *this* position.         *
 *                                                                             *
 *******************************************************************************
 */
  case king:
    if (wtm) {
      ClearSet(bit_move, WhitePieces);
      HashKW(from, HashKey);
      HashKW(to, HashKey);
      PcOnSq(to) = king;
      WhiteKingSQ = to;
      if (WhiteCastle(ply + 1) > 0) {
        if (WhiteCastle(ply + 1) & 2)
          HashCastleW(1, HashKey);
        if (WhiteCastle(ply + 1) & 1)
          HashCastleW(0, HashKey);
        if (abs(to - from) == 2)
          WhiteCastle(ply + 1) = -ply;
        else
          WhiteCastle(ply + 1) = 0;
        if (abs(to - from) == 2) {
          piece = rook;
          if (to == G1) {
            from = H1;
            to = F1;
            goto MakePieceMove;
          } else {
            from = A1;
            to = D1;
            goto MakePieceMove;
          }
        }
      }
    } else {
      ClearSet(bit_move, BlackPieces);
      HashKB(from, HashKey);
      HashKB(to, HashKey);
      PcOnSq(to) = -king;
      BlackKingSQ = to;
      if (BlackCastle(ply + 1) > 0) {
        if (BlackCastle(ply + 1) & 2)
          HashCastleB(1, HashKey);
        if (BlackCastle(ply + 1) & 1)
          HashCastleB(0, HashKey);
        if (abs(to - from) == 2)
          BlackCastle(ply + 1) = -ply;
        else
          BlackCastle(ply + 1) = 0;
        if (abs(to - from) == 2) {
          piece = rook;
          if (to == G8) {
            from = H8;
            to = F8;
            goto MakePieceMove;
          } else {
            from = A8;
            to = D8;
            goto MakePieceMove;
          }
        }
      }
    }
    break;
  }
/*
 *******************************************************************************
 *                                                                             *
 *   now it is time to "gracefully" remove a piece from the game board since it*
 *   is being captured.  this includes updating the board structure.           *
 *                                                                             *
 *******************************************************************************
 */
  if (captured) {
    Rule50Moves(ply + 1) = 0;
    TotalPieces--;
    if (promote)
      piece = promote;
    switch (captured) {
/*
 ************************************************************
 *                                                          *
 *   remove a captured pawn.                                *
 *                                                          *
 ************************************************************
 */
    case pawn:
      if (wtm) {
        Clear(to, BlackPawns);
        Clear(to, BlackPieces);
        HashPB(to, HashKey);
        HashPB(to, PawnHashKey);
        Material += pawn_value;
        TotalBlackPawns--;
      } else {
        Clear(to, WhitePawns);
        Clear(to, WhitePieces);
        HashPW(to, HashKey);
        HashPW(to, PawnHashKey);
        Material -= pawn_value;
        TotalWhitePawns--;
      }
      break;
/*
 ************************************************************
 *                                                          *
 *   remove a captured knight.                              *
 *                                                          *
 ************************************************************
 */
    case knight:
      if (wtm) {
        Clear(to, BlackKnights);
        Clear(to, BlackPieces);
        HashNB(to, HashKey);
        TotalBlackPieces -= knight_v;
        TotalBlackKnights--;
        Material += knight_value;
      } else {
        Clear(to, WhiteKnights);
        Clear(to, WhitePieces);
        HashNW(to, HashKey);
        TotalWhitePieces -= knight_v;
        TotalWhiteKnights--;
        Material -= knight_value;
      }
      break;
/*
 ************************************************************
 *                                                          *
 *   remove a captured bishop.                              *
 *                                                          *
 ************************************************************
 */
    case bishop:
      if (!SlidingDiag(piece))
        Clear(to, BishopsQueens);
      if (wtm) {
        Clear(to, BlackBishops);
        Clear(to, BlackPieces);
        HashBB(to, HashKey);
        TotalBlackPieces -= bishop_v;
        TotalBlackBishops--;
        Material += bishop_value;
      } else {
        Clear(to, WhiteBishops);
        Clear(to, WhitePieces);
        HashBW(to, HashKey);
        TotalWhitePieces -= bishop_v;
        TotalWhiteBishops--;
        Material -= bishop_value;
      }
      break;
/*
 ************************************************************
 *                                                          *
 *   remove a captured rook.                                *
 *                                                          *
 ************************************************************
 */
    case rook:
      if (!SlidingRow(piece))
        Clear(to, RooksQueens);
      if (wtm) {
        Clear(to, BlackRooks);
        Clear(to, BlackPieces);
        HashRB(to, HashKey);
        if (BlackCastle(ply + 1) > 0) {
          if ((to == A8) && (BlackCastle(ply + 1) & 2)) {
            BlackCastle(ply + 1) &= 1;
            HashCastleB(1, HashKey);
          } else if ((to == H8) && (BlackCastle(ply + 1) & 1)) {
            BlackCastle(ply + 1) &= 2;
            HashCastleB(0, HashKey);
          }
        }
        TotalBlackPieces -= rook_v;
        TotalBlackRooks--;
        Material += rook_value;
      } else {
        Clear(to, WhiteRooks);
        Clear(to, WhitePieces);
        HashRW(to, HashKey);
        if (WhiteCastle(ply + 1) > 0) {
          if ((to == A1) && (WhiteCastle(ply + 1) & 2)) {
            WhiteCastle(ply + 1) &= 1;
            HashCastleW(1, HashKey);
          } else if ((to == H1) && (WhiteCastle(ply + 1) & 1)) {
            WhiteCastle(ply + 1) &= 2;
            HashCastleW(0, HashKey);
          }
        }
        TotalWhitePieces -= rook_v;
        TotalWhiteRooks--;
        Material -= rook_value;
      }
      break;
/*
 ************************************************************
 *                                                          *
 *   remove a captured queen.                               *
 *                                                          *
 ************************************************************
 */
    case queen:
      if (!SlidingDiag(piece))
        Clear(to, BishopsQueens);
      if (!SlidingRow(piece))
        Clear(to, RooksQueens);
      if (wtm) {
        Clear(to, BlackQueens);
        Clear(to, BlackPieces);
        HashQB(to, HashKey);
        TotalBlackPieces -= queen_v;
        TotalBlackQueens--;
        Material += queen_value;
      } else {
        Clear(to, WhiteQueens);
        Clear(to, WhitePieces);
        HashQW(to, HashKey);
        TotalWhitePieces -= queen_v;
        TotalWhiteQueens--;
        Material -= queen_value;
      }
      break;
/*
 ************************************************************
 *                                                          *
 *   remove a captured king. [this is an error condition]   *
 *                                                          *
 ************************************************************
 */
    case king:
#if defined(DEBUG)
      Print(128, "captured a king (Make)\n");
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
  ValidatePosition(tree, ply + 1, move, "MakeMove(2)");
#endif
  return;
}

/*
 *******************************************************************************
 *                                                                             *
 *   MakeMoveRoot() is used to make a move at the root of the game tree,       *
 *   before any searching is done.  it uses MakeMove() to execute the move,    *
 *   but then copies the resulting position back to position[0], the actual    *
 *   board position.  it handles the special-case of the draw-by-repetition    *
 *   rule by maintaining a list of previous positions, which is reset each time*
 *   a non-reversible (pawn move or capture move) is made.                     *
 *                                                                             *
 *******************************************************************************
 */
void MakeMoveRoot(TREE * RESTRICT tree, int move, int wtm)
{
/*
 ************************************************************
 *                                                          *
 *   first, make the move and replace position[0] with the  *
 *   new position.                                          *
 *                                                          *
 ************************************************************
 */
  MakeMove(tree, 0, move, wtm);
/*
 ************************************************************
 *                                                          *
 *   now, if this is a non-reversible move, reset the       *
 *   repetition list pointer to start the count over.       *
 *                                                          *
 ************************************************************
 */
  if (Rule50Moves(1) == 0) {
    tree->rep_game = -1;
  }
  WhiteCastle(1) = Max(0, WhiteCastle(1));
  BlackCastle(1) = Max(0, BlackCastle(1));
  tree->position[0] = tree->position[1];
  tree->rep_list[++tree->rep_game] = HashKey;
}
