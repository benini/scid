//////////////////////////////////////////////////////////////////////
//
//  FILE:       position.h
//              Position class
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    3.3
//
//  Notice:     Copyright (c) 1999-2002 Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (shane@cosc.canterbury.ac.nz)
//
//////////////////////////////////////////////////////////////////////


#ifndef SCID_POSITION_H
#define SCID_POSITION_H

#include "common.h"
#include "tokens.h"
#include "misc.h"
#include "dstring.h"

//////////////////////////////////////////////////////////////////////
//  Position:  Constants

const uint  MAX_LEGAL_MOVES = 256;  // max. length of the legal moves list

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


///////////////////////////////////////////////////////////////////////////
//  Position:  Data Structures

// *** SimpleMove: less expensive to store than a full move as defined
//      in game.h, but still fully undoable.
//
struct simpleMoveT
{
    byte     pieceNum;
    pieceT   movingPiece;
    squareT  from;
    squareT  to;
    byte     capturedNum;
    pieceT   capturedPiece;
    pieceT   promote;
    byte     epMove;         // 1 if this is an epMove  -- NOT YET USED
    squareT  capturedSquare; // ONLY different to "to" field if this capture
                            //    is an en passent capture.
    byte     castleFlags;    // pre-move information
    squareT  epSquare;       // pre-move information
    ushort   oldHalfMoveClock;
};

errorT writeSimpleMove (FILE * fp, simpleMoveT * sm);
errorT readSimpleMove (FILE * fp, simpleMoveT * sm);


// *** LegalMoveList: list of legal moves.
//
struct legalMoveListT
{
    bool         current;                // list up to date?
    ushort       num;                    // size of list
    simpleMoveT  list [MAX_LEGAL_MOVES];
};


// *** SANList: list of legal move strings in SAN.
//
struct sanListT
{
    bool        current;
    ushort      num;
    sanStringT  list [MAX_LEGAL_MOVES];
};


// *** PseudoLegalList: for a piece on the side to move, store
//      the squares it can move to. Does not include en passent
//      or castling or pawn moves, or moves for the king.
//      (Queens, Rooks, Bishops, Knights only)
//      The moves are legal except for the fact that they may leave
//      the king in check.
//
struct pseudoLegalListT
{
    byte        num;
    squareT     list[27];   // Queens can have up to 27 moves.
};


// Random function used for hash tables:
uint random32 (void);


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
    byte            Material[15];   // count of each type of piece
                                        // currently (basically) unused.
    //uint            materialSig;    // Material signature
    byte            ListPos[64];    // ListPos stores the position in
                                        // List[][] for the piece on
                                        // square x.
    squareT         List[2][16];    // list of pieces on each side in
                                        // no particular order.
                                        // actually list of squares.
    squareDirT      Pinned[16];     // For each List[ToMove][x], stores
                                        // whether piece is pinned to its
                                        // own king and dir from king.

    pseudoLegalListT PseudoLegals[16];   // Squares a piece can move to

    squareT         EPTarget;       // square pawns can EP capture to
    colorT          ToMove;
    ushort          HalfMoveClock;  // Count of halfmoves since last capture
                                    // or pawn move.
    ushort          PlyCounter;
    byte            Castling;       // castling flags
    bool            StrictCastling; // If false, allow castling after moving
                                        // the King or Rook.

    uint            Hash;           // Hash value.

    uint            NumChecks;
    squareT         CheckSquares[16]; // Stores pieces checking the king.

    legalMoveListT * LegalMoves;     // list of legal moves
    sanListT       * SANStrings;     // SAN list of legal move strs


    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //  Position:  Private Functions


    void        CalcPinsDir (squareDirT dir, pieceT attacker);

    void        AddPseudoLegal (byte pnum, squareT sq);
    void        GenLinePseudos (colorT c, byte pnum, squareT sq,
                                squareDirT dir);
    void        GenKnightPseudos (colorT c, byte pnum, squareT sq);

    void        AddLegalMove (byte pnum, squareT to, pieceT promo);
    void        GenCastling ();
    void        GenKingMoves ();
    void        AddPromotions (byte pnum, squareT dest, colorT c);
    void        GenPawnMoves (byte pnum, squareDirT dir, squareT sq);
    squareT     CalcCheckDir (squareT king, squareDirT dir, pieceT attacker);

    void        AssertPos ();   //  Checks for errors in board etc.

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //  Position:  Public Functions
public:

    Position()   { Init(); }
    ~Position()  {
                     if (LegalMoves != NULL) { delete LegalMoves; }
                     if (SANStrings != NULL) { delete SANStrings; }
                  }

    void        Init();
    void        Clear();        // No pieces on board
    void        StdStart();     // Standard chess starting position
    errorT      AddPiece (pieceT p, squareT sq);

    // Set and Get attributes -- one-liners
    byte        PieceCount (pieceT p)    { return Material[p]; }
    byte *      GetMaterial ()           { return Material; }
    void        SetEPTarget (squareT s)  { EPTarget = s; }
    squareT     GetEPTarget ()           { return EPTarget; }
    bool        GetEPFlag ()             { return (EPTarget != NS); }
    void        SetToMove (colorT c)     { ToMove = c; }
    colorT      GetToMove ()             { return ToMove; }
    void        SetPlyCounter (ushort x) { PlyCounter = x; }
    ushort      GetPlyCounter ()         { return PlyCounter; }
    ushort      GetFullMoveCount ()      { return PlyCounter / 2 + 1; }
    sanListT *  GetSANStrings ()         { return SANStrings; }
    legalMoveListT * GetLegalMoves ()    { return LegalMoves; }

    // Methods to get the Board or piece lists -- used in game.cc to
    // decode moves:
    squareT *   GetList (colorT c)    { return List[c]; }
    uint        GetCount (colorT c)   { return Count[c]; }
    uint        TotalMaterial ()      { return Count[WHITE] + Count[BLACK]; }
    uint        MaterialValue (colorT c);
    uint        FyleCount (pieceT p, fyleT f);
    uint        RankCount (pieceT p, rankT r);

    pieceT *    GetBoard () {
        Board[COLOR_SQUARE] = COLOR_CHAR[ToMove];
        return Board;
    }

    // Other one-line methods
    squareT     GetKingPos (colorT c)   { return List[c][0]; }

    // Castling flags
    inline void SetCastling (colorT c, castleDirT dir, bool flag);
    bool        GetCastling (colorT c, castleDirT dir);
    inline bool CastlingPossible () { return (Castling ? true : false); }
    byte        GetCastlingFlags () { return Castling; }
    void        SetCastlingFlags (byte b) { Castling = b; }

    void        SetStrictCastling (bool b) { StrictCastling = b; }
    bool        GetStrictCastling (void) { return StrictCastling; }

    // Allocating memory  -- maybe these should be private??
    void        AllocLegalMoves ();
    void        AllocSANStrings ();

    // Clearing data structures
    void        ClearLegalMoves ();
    void        ClearSANStrings ();

    // Hashing
    inline uint HashValue (void) { return Hash; }
    uint        GetHPSig ();

    // Move generation and execution
    void        CalcPins();                // pieces pinned to own king

    void        GeneratePseudos (uint x);
    bool        IsPseudoLegal (uint pnum, squareT target);

    void        CalcLegalMoves (pieceT mask); // generate all legal moves
    void        CalcCheckEvasions (pieceT mask); // when king is in check
    void        MatchLegalMove (pieceT mask, squareT target);
    errorT      MatchPawnMove (fyleT fromFyle, squareT to, pieceT promote);
    errorT      MatchKingMove (squareT target);

    uint        CalcNumChecks (colorT toMove, squareT kingSq,
                               squareT * checkSquares);
    uint        CalcNumChecks () {
                    return CalcNumChecks (ToMove, GetKingPos(ToMove), NULL);
                }
    uint        CalcNumChecks (squareT kingSq) {
                    return CalcNumChecks (ToMove, kingSq, NULL);
                }
    uint        CalcNumChecks (squareT kingSq, squareT * checkSquares) {
                    return CalcNumChecks (ToMove, kingSq, checkSquares);
                }
    bool        IsKingInCheck () { return (CalcNumChecks() > 0); }

    bool        IsKingInMate ();

    int         IsPromoMove (squareT from, squareT to);

    void        DoSimpleMove (simpleMoveT * sm);    // move execution ...
    void        UndoSimpleMove (simpleMoveT * sm);  // ... and taking back

    void        MakeSANString (simpleMoveT * sm, char * s, sanFlagT flag);
    void        CalcSANStrings (sanFlagT flag);

    errorT      ReadCoordMove (simpleMoveT * m, const char * s, bool reverse);
    errorT      ReadMove (simpleMoveT * m, const char * s, tokenT t);
    errorT      ParseMove (simpleMoveT * sm, const char * s);
    errorT      ReadLine (const char * s);

    // Board I/O
    void        MakeLine (char * str);
    void        DumpBoard (FILE * fp);
    void        DumpLists (FILE * fp);
    errorT      ReadFromCompactStr (const byte * str);
    errorT      ReadFromFEN (const char * s);
    void        PrintCompactStr (char * cboard, bool epField);
    void        PrintCompactStrFlipped (char * cboard, bool epField);
    byte        CompactStrFirstByte () {
        return (Board[0] << 4) | Board[1];
    }
    void        PrintFEN (char * str, uint flags);
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
    void        CopyFrom (Position * src);

    // Methods to assist in evaluation and move completion
    uint        GetSquares (squareT sq, squareT *sqList);
    squareT     BestSquare (squareT startSq);

    // Set up a random position:
    errorT      Random (const char * material);
};



//////////////////////////////////////////////////////////////////////
//  Position:  Public Inline Functions


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::SetCastling():
//      Set a castling flag.
//
inline void
Position::SetCastling (colorT c, castleDirT dir, bool flag)
{
    register byte b = (c==WHITE ? 1 : 4);
    if (dir == KSIDE) b += b;
    // Now b = 1 or 2 (white flags), or 4 or 8 (black flags)
    if (flag) { Castling |= b; } else { Castling &= (255-b); }
    return;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::GetCastling():
//      Get a castling flag.
//
inline bool
Position::GetCastling (colorT c, castleDirT dir)
{
    register byte b = (c==WHITE ? 1 : 4);
    if (dir == KSIDE) b += b;
    // Now b == 1 or 2 (white flags), or 4 or 8 (black flags)
    if (Castling & b) { return true; } else { return false; }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::AllocLegalMoves():
//      Allocate the legal moves list.
//
inline void
Position::AllocLegalMoves ()
{
    ASSERT (LegalMoves == NULL);
    LegalMoves = new legalMoveListT;
    LegalMoves->current = false;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::AllocSANStrings():
//      Allocate the SAN strings list.
//
inline void
Position::AllocSANStrings ()
{
    ASSERT (SANStrings == NULL);
    SANStrings = new sanListT;
    SANStrings->current = false;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::ClearLegalMoves():
//      Reset the legal moves list.
//
inline void
Position::ClearLegalMoves ()
{
    if (LegalMoves) { LegalMoves->current = false; }
    else            { AllocLegalMoves(); }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::ClearSANStrings():
//      Reset the SAN moves list.
//
inline void
Position::ClearSANStrings ()
{
    if (SANStrings) { SANStrings->current = false; }
    else            { AllocSANStrings(); }
}

#endif  // SCID_POSITION_H

//////////////////////////////////////////////////////////////////////
//  EOF: position.h
//////////////////////////////////////////////////////////////////////

