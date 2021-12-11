//////////////////////////////////////////////////////////////////////
//
//  FILE:       position.h
//              Position class
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    3.5
//
//  Notice:     Copyright (c) 1999-2003 Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////


#ifndef SCID_POSITION_H
#define SCID_POSITION_H

#include "common.h"
#include "movelist.h"
#include <stdio.h>
#include <string>
#include <string_view>

class DString;
class SquareSet;
class SquareList;


//////////////////////////////////////////////////////////////////////
//  Position:  Constants

const byte  WQ_CASTLE = 1,    WK_CASTLE = 2,
            BQ_CASTLE = 4,    BK_CASTLE = 8;

// SANFlag: since checking if a move is check (to add the "+" to its
//      SAN string) takes time, and checking for mate takes even
//      longer, we specify whether we want this done with a flag.
typedef byte      sanFlagT;
const sanFlagT    SAN_NO_CHECKTEST   = 0,
                  SAN_CHECKTEST      = 1,
                  SAN_MATETEST       = 2;


// Flags that Position::PrintFEN() recognises:
//
const uint
    FEN_COMPACT = 0,
    FEN_BOARD = 1,
    FEN_CASTLING_EP = 2,
    FEN_ALL_FIELDS = 3;


// Flags that Position::GenerateMoves() recognises:
//
typedef uint genMovesT;
const genMovesT
    GEN_CAPTURES = 1,
    GEN_NON_CAPS = 2,
    GEN_ALL_MOVES = (GEN_CAPTURES | GEN_NON_CAPS);


// SANList: list of legal move strings in SAN.
//
struct sanListT
{
    bool        current;
    ushort      num;
    sanStringT  list [MAX_LEGAL_MOVES];
};


///////////////////////////////////////////////////////////////////////////
//  Position:  Class definition

class Position
{

private:
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //  Position:  Data structures

    pieceT          Board[66];      // the actual board + a color square
                                    // and a NULL square.
    uint            Count[2];       // count of pieces & pawns each
    byte            Material[16];   // count of each type of piece
    byte            ListPos[64];    // ListPos stores the position in
                                        // List[][] for the piece on
                                        // square x.
    squareT         List[2][16];    // list of piece squares for each side
    byte            NumOnRank[16][8];
    byte            NumOnFyle[16][8];
    byte            NumOnLeftDiag[16][16];  // Num Queens/Bishops
    byte            NumOnRightDiag[16][16];
    byte            NumOnSquareColor[16][2];

    directionT      Pinned[16];     // For each List[ToMove][x], stores
                                        // whether piece is pinned to its
                                        // own king and dir from king.

    squareT         EPTarget;       // square pawns can EP capture to
    colorT          ToMove;
    ushort          HalfMoveClock;  // Count of halfmoves since last capture
                                    // or pawn move.
    ushort          PlyCounter;
    byte            Castling;       // castling flags
    byte            variant_;       // 0 -> normal; 1 -> chess960
    squareT         castleRookSq_[4];  // start rook squares

    uint            Hash;           // Hash value.
    uint            PawnHash;       // Pawn structure hash value.

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //  Position:  Private Functions

    inline void AddHash (pieceT p, squareT sq);
    inline void UnHash (pieceT p, squareT sq);

    inline void AddToBoard (pieceT p, squareT sq);
    inline void RemoveFromBoard (pieceT p, squareT sq);

    void  CalcPinsDir (directionT dir, pieceT attacker);

    void  GenSliderMoves (MoveList * mlist, colorT c, squareT sq,
                          directionT dir, SquareSet * sqset,
                          bool capturesOnly);
    void  GenKnightMoves (MoveList * mlist, colorT c, squareT sq,
                          SquareSet * sqset, bool capturesOnly);

    void  AddLegalMove (MoveList * mlist, squareT from, squareT to, pieceT promo);
    void  GenCastling (MoveList * mlist);
    void  GenKingMoves (MoveList * mlist, genMovesT genType, bool castling);
    void  AddPromotions (MoveList * mlist, squareT from, squareT dest);
    bool  IsValidEnPassant (squareT from, squareT to);
    void  GenPawnMoves (MoveList * mlist, squareT from, directionT dir,
                        SquareSet * sqset, genMovesT genType);

    void GenCheckEvasions(MoveList* mlist, pieceT mask, genMovesT genType,
                          SquareList* checkSquares);
    errorT MatchPawnMove(MoveList* mlist, fyleT fromFyle, squareT to,
                         pieceT promote);

    errorT ReadMove(simpleMoveT* sm, const char* str, int slen, pieceT p);
    errorT ReadMoveCastle(simpleMoveT* sm, const char* str, int slen);
    errorT ReadMovePawn(simpleMoveT* sm, const char* str, int slen, fyleT from);
    errorT ReadMoveKing(simpleMoveT* sm, const char* str, int slen);

    template <typename TFunc>
    bool under_attack(squareT target_sq, squareT captured_sq,
                      TFunc not_empty) const;
    bool under_attack(squareT target_sq) const;

    static constexpr unsigned castlingIdx(colorT color, castleDirT side) {
        return 2 * color + side;
    }
    squareT castleRookSq(colorT color, bool king_side) const {
         return square_Relative(color, king_side ? H1 : A1);
    }

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //  Position:  Public Functions
public:
    Position();
    static const Position& getStdStart();

    void        Clear();        // No pieces on board
    void        StdStart() { *this = getStdStart(); }
    bool        IsStdStart() const;
    errorT      AddPiece (pieceT p, squareT sq);

    bool isChess960() const { return variant_ == 1; }

    // Set and Get attributes -- one-liners
    byte        PieceCount (pieceT p)    { return Material[p]; }
    const byte* GetMaterial() const      { return Material; }
    void        SetEPTarget (squareT s)  { EPTarget = s; }
    squareT     GetEPTarget () const     { return EPTarget; }
    void        SetToMove (colorT c)     { ToMove = c; }
    colorT      GetToMove () const       { return ToMove; }
    bool        WhiteToMove () const     { return ToMove == WHITE; }
    void        SetPlyCounter (ushort x) { PlyCounter = x; }
    ushort      GetPlyCounter () const   { return PlyCounter; }
    ushort      GetFullMoveCount() const { return PlyCounter / 2 + 1; }

    // Methods to get the Board or piece lists -- used in game.cpp to
    // decode moves:
    const squareT* GetList(colorT c) const { return List[c]; }
    squareT *   GetList (colorT c)    { return List[c]; }
    uint        GetCount (colorT c) const { return Count[c]; }
    uint        TotalMaterial ()      { return Count[WHITE] + Count[BLACK]; }
    uint        NumNonPawns (colorT c) { 
        return Count[c] - Material[piece_Make(c,PAWN)];
    }
    bool        InPawnEnding () {
        return (NumNonPawns(WHITE) == 1  &&  NumNonPawns(BLACK) == 1);
    }
    uint        MaterialValue (colorT c);
    inline uint FyleCount (pieceT p, fyleT f) const {
        return NumOnFyle[p][f];
    }
    inline uint RankCount (pieceT p, rankT r) const {
        return NumOnRank[p][r];
    }
    inline uint LeftDiagCount (pieceT p, leftDiagT diag) const {
        return NumOnLeftDiag[p][diag];
    }
    inline uint RightDiagCount (pieceT p, rightDiagT diag) const {
        return NumOnRightDiag[p][diag];
    }
    inline uint SquareColorCount (pieceT p, colorT sqColor)  const {
        return NumOnSquareColor[p][sqColor];
    }

    const pieceT* GetBoard() const {
        const_cast<Position*>(this)->Board[COLOR_SQUARE] = COLOR_CHAR[ToMove];
        return Board;
    }

    pieceT GetPiece(squareT sq) const {
        ASSERT(sq < 64);
        return Board[sq];
    }

    // Other one-line methods
    squareT     GetKingSquare (colorT c) const { return List[c][0]; }
    squareT     GetKingSquare () const         { return List[ToMove][0]; }
    squareT     GetEnemyKingSquare () const    { return List[1-ToMove][0]; }

    // Castling flags
    void SetCastling(colorT col, castleDirT dir);
    void ClearCastling(colorT col, castleDirT dir) {
        Castling &= ~(1u << castlingIdx(col, dir));
    }
    void ClearCastlingFlags(colorT c) {
        Castling &= (c == WHITE) ? 0b11111100 : 0b11110011;
    }
    bool GetCastling(colorT c, castleDirT dir) const {
        return Castling & (1u << castlingIdx(c, dir));
    }
    byte GetCastlingFlags() const { return Castling; }

    // Hashing
    inline uint HashValue (void) { return Hash; }
    inline uint PawnHashValue (void) { return PawnHash; }
    uint        GetHPSig ();

    // Move generation and execution
    void        CalcPins();
    void        GenPieceMoves (MoveList * mlist, squareT sq,
                               SquareSet * sqset, bool capturesOnly);

    // Generate all legal moves:
    void  GenerateMoves (MoveList* mlist, pieceT mask, genMovesT genType, bool maybeInCheck);
    void  GenerateMoves (MoveList * mlist) { GenerateMoves (mlist, EMPTY, GEN_ALL_MOVES, true); }
    void  GenerateMoves (MoveList * mlist, genMovesT genType) { GenerateMoves (mlist, EMPTY, genType, true); }
    void  GenerateCaptures (MoveList * mlist) { GenerateMoves (mlist, EMPTY, GEN_CAPTURES, true); }
    int IsLegalMove(squareT from, squareT to, pieceT promo) const;
    int isLegalMoveCastle(squareT from, squareT to) const;

    /// Check that the minimum requirements for castling are satisfied:
    /// - both the king and the rook exists in the position
    /// - the final squares of the king and the rook are empty
    /// @param check_legal: also test for checks or blocking pieces.
    /// Ignore the castling flags and if the king is already in check.
    template <bool check_legal = true> bool canCastle(bool king_side) const;

    uint        CalcAttacks (colorT toMove, squareT kingSq, SquareList * squares) const;
    int         TreeCalcAttacks (colorT toMove, squareT target);
    uint        CalcNumChecks () const {
                    return CalcAttacks (1-ToMove, GetKingSquare(), NULL);
                }
    uint        CalcNumChecks (squareT kingSq) const {
                    return CalcAttacks (1-ToMove, kingSq, NULL);
                }
    uint        CalcNumChecks (squareT kingSq, SquareList * checkSquares) const {
                    return CalcAttacks (1-ToMove, kingSq, checkSquares);
                }

    uint        Mobility (pieceT p, colorT color, squareT from);
    bool        IsKingInCheck () { return (CalcNumChecks() > 0); }
    bool        IsKingInCheck (simpleMoveT const& sm);
    bool        IsKingInMate ();
    bool        IsLegal ();

    bool        IsPromoMove (squareT from, squareT to);

    void        fillMove(simpleMoveT& sm) const;
    void        DoSimpleMove(simpleMoveT const& sm);
    void        DoSimpleMove (simpleMoveT * sm);    // move execution ...
    void        UndoSimpleMove (simpleMoveT const* sm);  // ... and taking back

    errorT      RelocatePiece (squareT fromSq, squareT toSq);

    void        MakeSANString (simpleMoveT * sm, char * s, sanFlagT flag);
	void        CalcSANStrings (sanListT *sanList, sanFlagT flag);

    errorT      MakeCoordMoves(const char* moves, size_t movesLen, std::string* toSAN = nullptr);
    errorT      ReadCoordMove(simpleMoveT* m, const char* s, size_t slen, bool reverse);
    errorT      ParseMove(simpleMoveT* sm, const char* str);
    errorT      ParseMove(simpleMoveT* sm, const char* begin, const char* end);

    // Board I/O
    void        MakeLongStr (char * str);
    errorT      ReadFromLongStr (const char * str);
    errorT      ReadFromFEN (const char * s);
    errorT      ReadFromFENorUCI (std::string_view str);
    void        PrintCompactStr (char * cboard);
    void        PrintFEN(char* str, uint flags) const;
    void        DumpLatexBoard (DString * dstr, bool flip);
    void        DumpLatexBoard (DString * dstr) {
        DumpLatexBoard (dstr, false);
    }
    void        DumpHtmlBoard (DString * dstr, uint style, const char * dir,
                               bool flip);
    void        DumpHtmlBoard (DString * dstr, uint style, const char * dir) {
        DumpHtmlBoard (dstr, style, dir, false);
    }

    // Copy, compare positions
    int         Compare (Position * p);
    void        CopyFrom (Position * src) { *this = *src; }

    // Set up a random position:
    errorT      Random (const char * material);
};

#endif  // SCID_POSITION_H

//////////////////////////////////////////////////////////////////////
//  EOF: position.h
//////////////////////////////////////////////////////////////////////

