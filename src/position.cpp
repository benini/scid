//////////////////////////////////////////////////////////////////////
//
//  FILE:       position.cpp
//              Position class methods
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    3.3
//
//  Notice:     Copyright (c) 1999-2002 Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (shane@cosc.canterbury.ac.nz)
//
//////////////////////////////////////////////////////////////////////

#include "common.h"
#include "position.h"
#include "attacks.h"
#include "misc.h"
#include <stdio.h>

#include <ctype.h>

static uint hashVal [16][64];
static uint stdStartHash = 0;

// HASH and UNHASH are identical: XOR the hash value for a (piece,square).
#define HASH(h,p,sq)    (h) ^= hashVal[(p)][(sq)]
#define UNHASH(h,p,sq)  (h) ^= hashVal[(p)][(sq)]


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// random32:
// A 32 bit random number generator.
// An implementation in C of the algorithm given by Knuth, the art of
// computer programming, vol. 2, pp. 26-27. We use e=32, so 
// we have to evaluate y(n) = y(n - 24) + y(n - 55) mod 2^32, which is
// implicitly done by unsigned arithmetic.
//
// Adapted from Random32() in Bob Hyatt's Crafty version 17.6.
//
uint
random32(void) {
    /*
     * random numbers from Mathematica 2.0.
     * SeedRandom = 1;
     * Table[Random[Integer, {0, 2^32 - 1}]
     */
    static const ulong x[55] = {
        1410651636UL, 3012776752UL, 3497475623UL, 2892145026UL, 1571949714UL,
        3253082284UL, 3489895018UL,  387949491UL, 2597396737UL, 1981903553UL,
        3160251843UL,  129444464UL, 1851443344UL, 4156445905UL,  224604922UL,
        1455067070UL, 3953493484UL, 1460937157UL, 2528362617UL,  317430674UL, 
        3229354360UL,  117491133UL,  832845075UL, 1961600170UL, 1321557429UL,
         747750121UL,  545747446UL,  810476036UL,  503334515UL, 4088144633UL,
        2824216555UL, 3738252341UL, 3493754131UL, 3672533954UL,   29494241UL,
        1180928407UL, 4213624418UL,   33062851UL, 3221315737UL, 1145213552UL,
        2957984897UL, 4078668503UL, 2262661702UL,   65478801UL, 2527208841UL,
        1960622036UL,  315685891UL, 1196037864UL,  804614524UL, 1421733266UL,
        2017105031UL, 3882325900UL,  810735053UL,  384606609UL, 2393861397UL
    };
    static int firstCall = 1;
    static ulong y[55];
    static int j, k;
    ulong ul;

    if (firstCall) {
        firstCall = 0;
        for (int i = 0; i < 55; i++) { y[i] = x[i]; }
        j = 24 - 1;
        k = 55 - 1;
    }
  
    ul = (y[k] += y[j]);
    j--;
    k--;
    if (j < 0) { j = 55 - 1; }
    if (k < 0) { k = 55 - 1; }
    return (uint) ul;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// initHashValues:
//    Initialises the table of Zobrist hash values.
void
initHashValues (void)
{
    // Ensure we set up the hash values only once:
    static int firstCall = 1;
    if (! firstCall) { return; }
    firstCall = 0;

    int p, sq;

    // First, set all values to 0:
    for (p = 0; p < 16; p++) {
        for (sq = 0; sq < 64; sq++) { hashVal[p][sq] = 0; }
    }

    // Now generate a random value for each valid [piece][square] index:
    for (sq=0; sq < 64; sq++) { hashVal[WK][sq] = random32(); }
    for (sq=0; sq < 64; sq++) { hashVal[WQ][sq] = random32(); }
    for (sq=0; sq < 64; sq++) { hashVal[WR][sq] = random32(); }
    for (sq=0; sq < 64; sq++) { hashVal[WB][sq] = random32(); }
    for (sq=0; sq < 64; sq++) { hashVal[WN][sq] = random32(); }
    for (sq=0; sq < 64; sq++) { hashVal[WP][sq] = random32(); }
    for (sq=0; sq < 64; sq++) { hashVal[BK][sq] = random32(); }
    for (sq=0; sq < 64; sq++) { hashVal[BQ][sq] = random32(); }
    for (sq=0; sq < 64; sq++) { hashVal[BR][sq] = random32(); }
    for (sq=0; sq < 64; sq++) { hashVal[BB][sq] = random32(); }
    for (sq=0; sq < 64; sq++) { hashVal[BN][sq] = random32(); }
    for (sq=0; sq < 64; sq++) { hashVal[BP][sq] = random32(); }

    // Now compute the hash value for the standard starting position:
    uint h = 0;
    HASH (h,WR,A1);  HASH (h,WN,B1);  HASH (h,WB,C1);  HASH (h,WQ,D1);
    HASH (h,WK,E1);  HASH (h,WB,F1);  HASH (h,WN,G1);  HASH (h,WR,H1);
    HASH (h,WP,A2);  HASH (h,WP,B2);  HASH (h,WP,C2);  HASH (h,WP,D2);
    HASH (h,WP,E2);  HASH (h,WP,F2);  HASH (h,WP,G2);  HASH (h,WP,H2);
    HASH (h,BP,A7);  HASH (h,BP,B7);  HASH (h,BP,C7);  HASH (h,BP,D7);
    HASH (h,BP,E7);  HASH (h,BP,F7);  HASH (h,BP,G7);  HASH (h,BP,H7);
    HASH (h,BR,A8);  HASH (h,BN,B8);  HASH (h,BB,C8);  HASH (h,BQ,D8);
    HASH (h,BK,E8);  HASH (h,BB,F8);  HASH (h,BN,G8);  HASH (h,BR,H8);
    stdStartHash = h;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// writeSimpleMove, readSimpleMove:
//    I/O for simpleMoveT structs.
//
errorT
writeSimpleMove (FILE * fp, simpleMoveT * sm)
{
    errorT err;
    writeOneByte (fp, sm->pieceNum);
    writeOneByte (fp, sm->movingPiece);

    writeOneByte (fp, sm->from);
    writeOneByte (fp, sm->to);

    writeOneByte (fp, sm->capturedNum);
    writeOneByte (fp, sm->capturedPiece);

    writeOneByte (fp, sm->promote);
    writeOneByte (fp, sm->epMove);

    writeOneByte (fp, sm->capturedSquare);
    writeOneByte (fp, sm->castleFlags);

    writeOneByte (fp, sm->epSquare);
    err = writeTwoBytes (fp, sm->oldHalfMoveClock);
    return err;
}

errorT
readSimpleMove (FILE * fp, simpleMoveT * sm)
{
    sm->pieceNum = readOneByte (fp);
    sm->movingPiece = readOneByte (fp);

    sm->from = readOneByte (fp);
    sm->to = readOneByte (fp);

    sm->capturedNum = readOneByte (fp);
    sm->capturedPiece = readOneByte (fp);

    sm->promote = readOneByte (fp);
    sm->epMove = readOneByte (fp);

    sm->capturedSquare = readOneByte (fp);
    sm->castleFlags = readOneByte (fp);

    sm->epSquare = readOneByte (fp);
    sm->oldHalfMoveClock = readTwoBytes (fp);
    return OK;
}


///////////////////////////////////////////////////////////////////////////
//  PRIVATE FUNCTIONS -- small ones are inline for speed

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::AssertPos():
//      Does a slow, thorough check of the integrity of the
//      data structures, ensuring everything is valid.
//
void
Position::AssertPos ()
{
    byte mat[16] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
    for (colorT c = WHITE; c <= BLACK; c++) {
        for (uint i=0; i < Count[c]; i++) {
            if (ListPos[List[c][i]] != i) {
                DumpLists (stderr);
                abort();
            }
            if (piece_Color(Board[List[c][i]]) != c) { abort(); }
            mat[Board[List[c][i]]]++;
        }
    }
    for (uint i=0; i < 15; i++) {
        if (mat[i] != Material[i]) { abort(); }
    }
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::CalcPinsDir():
//      Look for a pinned piece in the direction 'dir' relative to
//      the position of the king to move.
//
inline void
Position::CalcPinsDir (squareDirT dir, pieceT attacker)
{
    // Two pieces can pin along any path. A queen is always one,
    // the other is a bishop or rook. To save calculating it here, the
    // appropriate piece (BISHOP) or (ROOK) is passed along with the
    // direction.

    register squareT x, friendly;
    squareT king = GetKingPos (ToMove);
    register pieceT p;

    x = sqMove [king][dir];
    friendly = NULL_SQUARE;
    while (x != NULL_SQUARE) {
        p = Board[x];
        if (p == EMPTY) {
            // nothing; keep searching
        }
        else if (piece_Color(p) == ToMove) {       // FRIENDLY
            if (friendly == NULL_SQUARE)
                friendly = x;       // first friendly found
            else
                return;             // two friendlies: end search
        }
        else {           // (Piece_Color(p) != tomove) : ENEMY
            if (friendly != NULL_SQUARE)    // potential pin
            {
                if ((piece_Type(p)==QUEEN) || (piece_Type(p)==attacker))
                    Pinned[ListPos[friendly]] = dir;
            }
            else        // enemy piece, nothing in between: ignore
            {
                /* do nothing */
            }
            return;     // found an enemy piece, so end search
        }
        x = sqMove [x][dir];
    }
    return;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::AddPseudoLegal():
//      Add a square to a piece's pseudo-legal moves list
//
inline void
Position::AddPseudoLegal (byte pnum, squareT sq)
{
    PseudoLegals[pnum].list[PseudoLegals[pnum].num++] = sq;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::GenLinePseudos():
//      Generate attacks along a direction, and update the pseudo-legal
//      moves list for that piece. The piece should be a Queen, Rook or
//      Bishop.
//
inline void
Position::GenLinePseudos (colorT c, byte pnum, squareT sq, squareDirT dir)
{
    register squareT dest;
    register colorT target;

    dest = sqMove[sq][dir];
    while (dest != NULL_SQUARE) {
        target = piece_Color (Board[dest]);
        if (target == NOCOLOR) {
            AddPseudoLegal (pnum, dest);
        } else if (target == c) {
            // ran into friendly piece, hence NOT a pseudolegal move
            return;
        } else {   // reached an enemy piece, so a capture is possible
            AddPseudoLegal (pnum, dest);
            return;
        }
        dest = sqMove [dest][dir];
    }
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::GenKnightPseudos():
//      Generate Knight attacks and update the pseudo-legal moves list
//      for that piece.  Uses the table of attackable squares,
//      knightAttacks[] in attacks.h
//
void
Position::GenKnightPseudos (colorT c, byte pnum, squareT sq)
{
    register const squareT * dest = knightAttacks[sq];
    while (*dest != NULL_SQUARE) {
        if (piece_Color (Board[*dest]) != c) {
            AddPseudoLegal (pnum, *dest);
        }
        dest++;
    }
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::AddLegalMove():
//      Add a legal move to the move list.
//
inline void
Position::AddLegalMove (byte pnum, squareT to, pieceT promo)
{
    ASSERT (LegalMoves != NULL);
    ASSERT (LegalMoves->num < MAX_LEGAL_MOVES);

    simpleMoveT * sm = &(LegalMoves->list[LegalMoves->num]);
    sm->pieceNum = pnum;
    sm->to = to;
    sm->promote = promo;
    sm->from = List[ToMove][pnum];
    sm->movingPiece = Board[sm->from];
    sm->capturedPiece = Board[sm->to];

    // We DON'T set the pre-move castling/ep flags, or the captured
    // piece info, here since that is ONLY needed if the move is
    // going to be executed with DoSimpleMove() and then undone.
    // So those fields are set in DoSimpleMove().

    LegalMoves->num++;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::GenCastling():
//      Generate the legal castling moves.
//
void
Position::GenCastling (void)
{
    if (NumChecks != 0) { return; }
    if (GetKingPos (ToMove) != (ToMove == WHITE ? E1 : E8))  { return; }

    squareT enemyKingSq = GetKingPos (1 - ToMove);
    register squareT target, skip, rookSq;
    register pieceT rookPiece;

    // Queenside Castling:
    if (!StrictCastling  ||  GetCastling (ToMove, QSIDE)) {
        if (ToMove == WHITE) {
            target = C1; skip = D1; rookSq = A1; rookPiece = WR;
        } else {
            target = C8; skip = D8; rookSq = A8; rookPiece = BR;
        }
        if (Board[target] == EMPTY  &&  Board[skip] == EMPTY
                &&  Board[rookSq] == rookPiece
                &&  Board[target - 1] == EMPTY // B1 or B8 must be empty too!
                &&  CalcNumChecks (target) == 0
                &&  CalcNumChecks (skip) == 0
                &&  ! square_Adjacent (target, enemyKingSq)) {
            AddLegalMove (0, target, EMPTY);
        }
    }

    // Kingside Castling:
    if (!StrictCastling  ||  GetCastling (ToMove, KSIDE)) {
        if (ToMove == WHITE) {
            target = G1; skip = F1; rookSq = H1; rookPiece = WR;
        } else {
            target = G8; skip = F8; rookSq = H8; rookPiece = BR;
        }
        if (Board[target] == EMPTY  &&  Board[skip] == EMPTY
                &&  Board[rookSq] == rookPiece
                &&  CalcNumChecks (target) == 0
                &&  CalcNumChecks (skip) == 0
                &&  ! square_Adjacent (target, enemyKingSq)) {
            AddLegalMove (0, target, EMPTY);
        }
    }
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::GenKingMoves():
//      Generate the legal King moves. Castling is generated as well.
//
void
Position::GenKingMoves (void)
{
    register squareT kingSq = GetKingPos(ToMove);
    register squareT enemyKingSq = GetKingPos(1-ToMove);
    register const squareT * dest;
    pieceT king = piece_Make(ToMove, KING);

    ASSERT (Board[kingSq] == king);

    dest = kingAttacks[kingSq];
    while (*dest != NULL_SQUARE) {
        // Try this move and see if it legal:

        uint legalMove = 0;
        if (piece_Color (Board[*dest]) != ToMove) {
            // Not a friendly piece there, so try the move:
            pieceT captured = Board[*dest];
            Board[*dest] = king;
            Board[kingSq] = EMPTY;

            if (CalcNumChecks (*dest) == 0) {
                // The king wont be in check. Are the two Kings adjacent?
                if (! square_Adjacent (*dest, enemyKingSq)) {
                    legalMove = 1;
                }
            }
            Board[kingSq] = king;
            Board[*dest] = captured;
        }
        if (legalMove) { AddLegalMove (0, *dest, EMPTY); }
        dest++;
    }
    // Now generate castling moves, if possible:
    GenCastling ();
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::AddPromotions():
//      Add promotion moves.
//      Called by GenPawnMoves() when a pawn can be promoted.
//
void
Position::AddPromotions (byte pnum, squareT dest, colorT c)
{
    ASSERT (piece_Type (Board[List[c][pnum]]) == PAWN);
    ASSERT (square_Rank (dest) == RANK_1  ||  square_Rank (dest) == RANK_8);

    AddLegalMove (pnum, dest, QUEEN);
    AddLegalMove (pnum, dest, ROOK);
    AddLegalMove (pnum, dest, BISHOP);
    AddLegalMove (pnum, dest, KNIGHT);
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::GenPawnMoves():
//      Generate legal pawn moves.
//      If dir != NULL_DIR, pawn MUST move in direction dir or its opposite.
//      If sq != NULL_SQUARE, pawn MUST move to sq.
//
//      These dir and sq parameters are so this function can handle
//      pinned pawns and attempts to stop a check.
//
void
Position::GenPawnMoves (byte pnum, squareDirT dir, squareT sq)
{
    register squareDirT forward = (ToMove == WHITE ? UP : DOWN);
    rankT promoRank = (ToMove == WHITE ? RANK_8 : RANK_1);
    rankT secondRank = (ToMove == WHITE ? RANK_2 : RANK_7);
    register squareT start = List[ToMove][pnum];
    register squareT dest;

    ASSERT (piece_Type (Board[start]) == PAWN);

    if (dir == NULL_DIR  ||  dir == forward ||
        sdOpposite[dir] == forward)
    {
        dest = sqMove [start][forward];
        if (Board[dest]==EMPTY && (sq==NULL_SQUARE || sq==dest)) {
            if (square_Rank(dest) == promoRank) {
                AddPromotions (pnum, dest, ToMove);
            } else {
                AddLegalMove (pnum, dest, EMPTY);
            }
        }
        if (square_Rank(start) == secondRank  &&  Board[dest] == EMPTY) {
            dest = sqMove [dest][forward];
            if (Board[dest]==EMPTY  &&  (sq==NULL_SQUARE || sq==dest)) {
                AddLegalMove (pnum, dest, EMPTY);
            }
        }
    }
    // Now do captures: left, then right
    // To be a possible capture, dest square must be EPTarget or hold
    // an enemy piece.
#define POSSIBLE_CAPTURE(d) ((d != NULL_SQUARE)   \
        &&  ((piece_Color (Board[d]) == (1-ToMove))  ||  (d == EPTarget)))

    forward = (ToMove == WHITE ? UP_LEFT : DOWN_LEFT);
    if (dir == NULL_DIR  ||  dir == forward  ||  sdOpposite[dir] == forward)
    {
        dest = sqMove [start][forward];

        // dest must have an enemy piece OR be the EPTarget square.

        if (POSSIBLE_CAPTURE(dest)  &&  (sq == NULL_SQUARE || sq == dest)) {
            if (square_Rank(dest) == promoRank) {
                AddPromotions (pnum, dest, ToMove);
            } else {
                AddLegalMove (pnum, dest, EMPTY);
            }
        }
    }
    forward = (ToMove == WHITE ? UP_RIGHT : DOWN_RIGHT);
    if (dir == NULL_DIR  ||  dir == forward  ||  sdOpposite[dir] == forward) {
        dest = sqMove [start][forward];
        if (POSSIBLE_CAPTURE(dest)  &&  (sq == NULL_SQUARE || sq == dest)) {
            if (square_Rank(dest) == promoRank) {
                AddPromotions (pnum, dest, ToMove);
            } else {
                AddLegalMove (pnum, dest, EMPTY);
            }
        }
    }
    return;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::IsKingInCheckDir():
//      Is the king in check from a queen or rook or bishop along the
//      specified diagonal 'dir'.
//      The piece argument 'attacker' is either BISHOP or ROOK.
//
squareT
Position::CalcCheckDir (squareT king, squareDirT dir, pieceT attacker)
{
    register squareT dest = sqMove [king][dir];
    register pieceT p;

    while (dest != NULL_SQUARE)
    {
        p = Board[dest];
        if (p == EMPTY) {           // empty square: keep searching
        } else if (piece_Color(p) == ToMove) {
            return NULL_SQUARE;           // friendly piece found
        } else {                    // enemy piece found
            if ((piece_Type(p)==QUEEN) || (piece_Type(p)==attacker)) {
                return dest;
            } else {
                return NULL_SQUARE;
            }
        }
        dest = sqMove [dest][dir];
    }
    return NULL_SQUARE;   // edge of board found
}



//////////////////////////////////////////////////////////////////////
//  PUBLIC FUNCTIONS


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::GetHPSig():
//      Return the position's home pawn signature.
//
uint
Position::GetHPSig (void)
{
    uint hpSig = 0;
    register pieceT * b = &(Board[A2]);
    if (*b == WP) { hpSig |= 0x8000; }  b++;  /* a2 */
    if (*b == WP) { hpSig |= 0x4000; }  b++;  /* b2 */
    if (*b == WP) { hpSig |= 0x2000; }  b++;  /* c2 */
    if (*b == WP) { hpSig |= 0x1000; }  b++;  /* d2 */
    if (*b == WP) { hpSig |= 0x0800; }  b++;  /* e2 */
    if (*b == WP) { hpSig |= 0x0400; }  b++;  /* f2 */
    if (*b == WP) { hpSig |= 0x0200; }  b++;  /* g2 */
    if (*b == WP) { hpSig |= 0x0100; }        /* h2 */
    b = &(Board[A7]);
    if (*b == BP) { hpSig |= 0x0080; }  b++;  /* a7 */
    if (*b == BP) { hpSig |= 0x0040; }  b++;  /* b7 */
    if (*b == BP) { hpSig |= 0x0020; }  b++;  /* c7 */
    if (*b == BP) { hpSig |= 0x0010; }  b++;  /* d7 */
    if (*b == BP) { hpSig |= 0x0008; }  b++;  /* e7 */
    if (*b == BP) { hpSig |= 0x0004; }  b++;  /* f7 */
    if (*b == BP) { hpSig |= 0x0002; }  b++;  /* g7 */
    if (*b == BP) { hpSig |= 0x0001; }        /* h7 */
    return hpSig;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::Init():
//      Initialise the position after it is constructed.
//
void
Position::Init (void)
{
    // Setting up a valid board is left to StdStart() or Clear().
    Board [COLOR_SQUARE] = EMPTY;
    Board [NULL_SQUARE] = END_OF_BOARD;
    LegalMoves = NULL;
    SANStrings = NULL;
    StrictCastling = true;

    // Call scid_Init() to make sure all tables used for move generation,
    // square tests, etc have been computed:
    scid_Init();
    initHashValues();
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::Clear():
//      Clear the board and associated structures.
//
void
Position::Clear (void)
{
    register int i;
    for (i=A1; i <= H8; i++) { Board[i] = EMPTY; }
    for (i=WK; i <= BP; i++) { Material[i] = 0; }
    Count[WHITE] = Count[BLACK] = 0;
    EPTarget = NULL_SQUARE;
    Castling = 0;
    Board [NULL_SQUARE] = END_OF_BOARD;
    PlyCounter = 0;
    HalfMoveClock = 0;
    Hash = 0;
    return;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::StdStart():
//      Set up the standard chess starting position.
//
void
Position::StdStart (void)
{
    uint i;
    for (i=A3; i <= H6; i++) { Board[i] = EMPTY; }
    Material[WK] = Material[BK] = 1;
    Material[WQ] = Material[BQ] = 1;
    Material[WR] = Material[BR] = 2;
    Material[WB] = Material[BB] = 2;
    Material[WN] = Material[BN] = 2;
    Material[WP] = Material[BP] = 8;
    Count[WHITE] = Count[BLACK] = 16;

    Board[E1] = WK;  List[WHITE][0] = E1;  ListPos[E1] = 0;
    Board[E8] = BK;  List[BLACK][0] = E8;  ListPos[E8] = 0;
    Board[A1] = WR;  List[WHITE][1] = A1;  ListPos[A1] = 1;
    Board[A8] = BR;  List[BLACK][1] = A8;  ListPos[A8] = 1;
    Board[B1] = WN;  List[WHITE][2] = B1;  ListPos[B1] = 2;
    Board[B8] = BN;  List[BLACK][2] = B8;  ListPos[B8] = 2;
    Board[C1] = WB;  List[WHITE][3] = C1;  ListPos[C1] = 3;
    Board[C8] = BB;  List[BLACK][3] = C8;  ListPos[C8] = 3;
    Board[D1] = WQ;  List[WHITE][4] = D1;  ListPos[D1] = 4;
    Board[D8] = BQ;  List[BLACK][4] = D8;  ListPos[D8] = 4;
    Board[F1] = WB;  List[WHITE][5] = F1;  ListPos[F1] = 5;
    Board[F8] = BB;  List[BLACK][5] = F8;  ListPos[F8] = 5;
    Board[G1] = WN;  List[WHITE][6] = G1;  ListPos[G1] = 6;
    Board[G8] = BN;  List[BLACK][6] = G8;  ListPos[G8] = 6;
    Board[H1] = WR;  List[WHITE][7] = H1;  ListPos[H1] = 7;
    Board[H8] = BR;  List[BLACK][7] = H8;  ListPos[H8] = 7;

    // Unroll this loop for speed? StdStart gets called a lot in searches!
    for (i=0; i < 8; i++) {
        Board[A2+i] = WP; List[WHITE][i+8] = A2+i; ListPos[A2+i] = i+8;
        Board[A7+i] = BP; List[BLACK][i+8] = A7+i; ListPos[A7+i] = i+8;
    }
    Castling = 0;
    SetCastling (WHITE, QSIDE, true);  SetCastling (WHITE, KSIDE, true);
    SetCastling (BLACK, QSIDE, true);  SetCastling (BLACK, KSIDE, true);
    EPTarget = NULL_SQUARE;
    ToMove = WHITE;
    PlyCounter = 0;  HalfMoveClock = 0;
    Board [NULL_SQUARE] = END_OF_BOARD;
    Hash = stdStartHash;
    return;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::AddPiece():
//      Add a piece to the board and piecelist.
//      Checks that a side cannot have more than 16 pieces or more
//      than one king.
//
errorT
Position::AddPiece (pieceT p, squareT sq)
{
    colorT c = piece_Color(p);

    if (Count[c] == 16) { return ERROR_PieceCount; }
    ASSERT(Count[c] <= 15);
    Board[sq] = p;
    if (piece_Type(p) == KING) {
        // Check there is not already a King:
        if (Material[p] > 0) { return ERROR_PieceCount; }

        // King is always at the start of the piecelist, so move the piece
        // already at location 0 if there is one:
        if (Count[c] > 0) {
            squareT oldsq = List[c][0];
            List[c][Count[c]] = oldsq;
            ListPos[oldsq] = Count[c];
        }
        List[c][0] = sq;
        ListPos[sq] = 0;
    } else {
        ListPos[sq] = Count[c];
        List[c][Count[c]] = sq;
    }
    Count[c] += 1;
    Material[p] += 1;
    HASH (Hash, p, sq);
    return OK;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::CalcPins():
//      Calculate the pieces for the side to move that are
//      pinned to their king. The array Pinned[] stores, for
//      each piece, the direction in which it is pinned.
//
//      For example WK on e1, WQ on e2, BQ on e7 on the e-fyle
//      means the WQ is Pinned in the direction UP.
//
void
Position::CalcPins (void)
{
    Pinned[ 0] = Pinned[ 1] = Pinned[ 2] = Pinned[ 3] = Pinned[ 4] =
    Pinned[ 5] = Pinned[ 6] = Pinned[ 7] = Pinned[ 8] = Pinned[ 9] =
    Pinned[10] = Pinned[11] = Pinned[12] = Pinned[13] = Pinned[14] =
    Pinned[15] = NULL_DIR;

    // Pins and checks from Bishops/Queens/Rooks:
    CalcPinsDir (UP, ROOK);
    CalcPinsDir (DOWN, ROOK);
    CalcPinsDir (LEFT, ROOK);
    CalcPinsDir (RIGHT, ROOK);
    CalcPinsDir (UP_LEFT, BISHOP);
    CalcPinsDir (DOWN_LEFT, BISHOP);
    CalcPinsDir (UP_RIGHT, BISHOP);
    CalcPinsDir (DOWN_RIGHT, BISHOP);
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::GeneratePseudos():
//      Updates the PseudoLegals array of moves for a piece
//      of the side to move (except pawns and the King, which
//      are handled seperately).
//
void
Position::GeneratePseudos (uint x)
{
    register colorT c = ToMove;

    ASSERT(x < Count[c]);    // x, the piece number, must be valid

    PseudoLegals[x].num = 0;

    squareT sq = List[c][x];
    pieceT p = Board[sq];

    switch (piece_Type(p)) {
    case PAWN:  // Redundant; we dont calculate pawn pseudos.
        break;

    case QUEEN:
        GenLinePseudos (c, x, sq, UP);
        GenLinePseudos (c, x, sq, DOWN);
        GenLinePseudos (c, x, sq, LEFT);
        GenLinePseudos (c, x, sq, RIGHT);
        // INTENTIONALLY no break here since Queens move like a Rook
        // or a Bishop, so we drop into the Bishop case below.

    case BISHOP:
        GenLinePseudos (c, x, sq, UP_LEFT);
        GenLinePseudos (c, x, sq, UP_RIGHT);
        GenLinePseudos (c, x, sq, DOWN_LEFT);
        GenLinePseudos (c, x, sq, DOWN_RIGHT);
        break;

    case ROOK:
        GenLinePseudos (c, x, sq, UP);
        GenLinePseudos (c, x, sq, DOWN);
        GenLinePseudos (c, x, sq, LEFT);
        GenLinePseudos (c, x, sq, RIGHT);
        break;

    case KNIGHT:
        GenKnightPseudos (c, x, sq);
        break;

    case KING:  // Nothing to do; there are no king pseudos.
        break;

    default:  // should never happen!
        fprintf (stderr, "BAD PIECE: %d, %d\n", p, sq);
        DumpBoard (stderr);
        DumpLists (stderr);
        ASSERT (0);
    }
    return;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::IsPseudoLegal():
//      Returns true if the numbered piece "attacks" the target square.
//
inline bool
Position::IsPseudoLegal (uint pnum, squareT target)
{
    register squareT i;
    for (i=0; i < PseudoLegals[pnum].num; i++) {
        if (PseudoLegals[pnum].list[i] == target)  { return true; }
    }
    return false;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::CalcLegalMoves():
//      Recalculate the legal moves list.
//      If mask is a piece (not EMPTY), then ONLY legal moves for that
//      type of piece are created.
//
void
Position::CalcLegalMoves (pieceT mask)
{
    register uint i, x;
    if (LegalMoves == NULL) { AllocLegalMoves(); }
    //if (LegalMoves->current) { return; }

    LegalMoves->num = 0;
    // for (x=0; x < 16; x++) { PseudoLegals[x].num = 0; }

    CalcPins();

    NumChecks = CalcNumChecks (GetKingPos(ToMove), CheckSquares);
    if (NumChecks > 0) {    // side to move IS in check
        CalcCheckEvasions (mask);
        //LegalMoves->current = true;
        return;
    } else {                    // side to move is NOT in check
        for (x=1; x < Count[ToMove]; x++) {
            squareT sq = List[ToMove][x];
            pieceT p = Board[sq];

            // if (Pinned[x] == dir (not NULL_DIR), x can ONLY move along
            // that direction. Pinned knights cannot move at all.

            if (Pinned[x] != NULL_DIR) {  // piece x is pinned to king
                if (piece_IsPawn(p)  &&  (mask == EMPTY  ||  mask == PAWN)) {
                    GenPawnMoves (x, Pinned[x], NULL_SQUARE);

                } else if (piece_IsKnight(p)) {
                    // do nothing -- pinned knights cannot move

                } else {
                    // piece is a pinned Queen/Rook/Bishop

                    if (mask == EMPTY  ||  mask == piece_Type(p)) {
                        GeneratePseudos (x);
                        for (i=0; i < PseudoLegals[x].num; i++) {

                            // pseudolegal move is legal only if it is along
                            // the direction of Pinned[x] OR its opposite!

                            squareT dest = PseudoLegals[x].list[i];
                            squareDirT dir = sqDir[sq][dest];
                            squareDirT oppdir = sdOpposite[dir];
                            if (Pinned[x] == dir  || Pinned[x] == oppdir) {
                                AddLegalMove (x, dest, EMPTY);
                            }
                        }
                    }
                }
            } else {
                // piece x is free to move anywhere

                if (piece_IsPawn(p)  &&  (mask == EMPTY  ||  mask == PAWN)) {
                    GenPawnMoves(x, NULL_DIR, NULL_SQUARE);

                } else {
                    // Knight/Queen/Bishop/Rook:
                    if (mask == EMPTY  ||  mask == piece_Type(p)) {
                        GeneratePseudos(x);
                        for (i=0; i < PseudoLegals[x].num; i++) {
                            squareT dest = PseudoLegals[x].list[i];
                            AddLegalMove (x, dest, EMPTY);
                        }
                    }
                }
            }
        }
        if (mask == EMPTY  || mask == KING) {
            GenKingMoves();     // lastly, king moves...
        }
    }
    //LegalMoves->current = true;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::MatchLegalMove():
//      Sets the LegalMoves list to contain all the moves of pieces
//      of type "mask" that move to the square "target".
//      The type must be QUEEN, ROOK, BISHOP, or KNIGHT.
//      Pawn and King moves are handled in separate functions,
//      MatchKingMove() and MatchPawnMove().
//
void
Position::MatchLegalMove (pieceT mask, squareT target)
{
    register uint x;
    if (LegalMoves == NULL) { AllocLegalMoves(); }
    LegalMoves->num = 0;

    // This function isn't for Pawn or King moves!
    ASSERT (mask != PAWN  &&  mask != KING);

    register uint count = 0;
    uint total = Material[piece_Make(ToMove, mask)];

    register pieceT p, pt, captured;
    register squareT kingSq = GetKingPos(ToMove);
    squareDirT dir;

    uint tryMove = 0;

    // First, verify that the target square is empty or contains
    // an enemy piece:

    p = Board[target];
    if (p != EMPTY  &&  piece_Color(p) == ToMove) {
        return;
    }

    // Loop through looking for pieces of type "mask". We start at 1
    // since the King is always the piece at position 0 in the list.

    register squareT * sqPtr = &(List[ToMove][1]);
    for (x=1;  x < Count[ToMove]  &&  count < total;  x++, sqPtr++) {
        p = Board[*sqPtr];
        pt = piece_Type(p);
        if (pt == mask) {

            // Increment count so we stop when we've seen all the
            // Material[p] pieces of this type.

            tryMove = 0;
            count++;
            squareT sq;

            switch (pt) {
            case KNIGHT: {
                    const squareT * knightSq = knightAttacks[*sqPtr];
                    while (*knightSq != NS  &&  *knightSq != target) {
                        knightSq++;
                    }
                    if (*knightSq == target) { tryMove = 1; }
                }
                break;

            case ROOK:
                dir = sqDir[*sqPtr][target];
                if (dir != NULL_DIR  &&  !sdIsDiagonal[dir]) {
                    sq = sqMove[*sqPtr][dir];
                    tryMove = 1;
                    while (sq != target) {
                        if (Board[sq] != EMPTY) { // oops, piece in the way
                            tryMove = 0;
                            break;
                        }
                        sq = sqMove[sq][dir];
                    }
                }
                break;

            case BISHOP:
                dir = sqDir[*sqPtr][target];
                if (sdIsDiagonal[dir]) {
                    sq = sqMove[*sqPtr][dir];
                    tryMove = 1;
                    while (sq != target) {
                        if (Board[sq] != EMPTY) { // oops, piece in the way
                            tryMove = 0;
                            break;
                        }
                        sq = sqMove[sq][dir];
                    }
                }
                break;

            case QUEEN:
                dir = sqDir[*sqPtr][target];
                if (dir != NULL_DIR) {  // Try the move!
                    sq = sqMove[*sqPtr][dir];
                    tryMove = 1;
                    while (sq != target) {
                        if (Board[sq] != EMPTY) { // oops, piece in the way
                            tryMove = 0;
                            break;
                        }
                        sq = sqMove[sq][dir];
                    }
                }
                break;

            default:  // Should never happen
                ASSERT(0);
            }

            // Now, if tryMove is 1, the piece can get to target. We need
            // to see if the move is legal or leaves the king in check.

            if (tryMove == 1) {
                captured = Board[target];
                Board[target] = p;
                Board[*sqPtr] = EMPTY;
                if (CalcNumChecks (kingSq) > 0)  { tryMove = 0; }
                Board[*sqPtr] = p;
                Board[target] = captured;
                if (tryMove == 1)  { AddLegalMove (x, target, EMPTY); }
            }
        }
    }
    // Ok, we've searched all the pieces.
    return;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::MatchPawnMove():
//      Sets the LegalMoves list to contain the matching pawn move,
//      if there is one.
//
errorT
Position::MatchPawnMove (fyleT fromFyle, squareT to, pieceT promote)
{
    if (LegalMoves == NULL) { AllocLegalMoves(); }
    LegalMoves->num = 0;
    sint diff = (int)square_Fyle(to) - (int)fromFyle;
    if (diff < -1  ||  diff > 1) { return ERROR_InvalidMove; }
    pieceT pawn;
    rankT toRank = square_Rank(to);
    fyleT toFyle = square_Fyle(to);
    rankT promoteRank = (ToMove == WHITE ? RANK_8 : RANK_1);

    // from is the from square; backup is the alternative from square
    // for a pawn move two squares forward.

    squareT from, backup = NS;

    if (ToMove == WHITE) {
        pawn = WP;
        promoteRank = RANK_8;
        if (toRank < RANK_3) { return ERROR_InvalidMove; }
        from = square_Make(fromFyle, toRank - 1);
        if (toRank == RANK_4  &&  fromFyle == toFyle) { backup = to - 16; }
    } else {
        pawn = BP;
        promoteRank = RANK_1;
        if (toRank > RANK_6) { return ERROR_InvalidMove; }
        from = square_Make(fromFyle, toRank + 1);
        if (toRank == RANK_5  &&  fromFyle == toFyle) { backup = to + 16; }
    }

    // See if the promotion piece is valid:

    if (toRank == promoteRank) {
        if (promote == EMPTY)  { return ERROR_InvalidMove; }
    } else {
        if (promote != EMPTY)  { return ERROR_InvalidMove; }
    }

    if (Board[from] != pawn) {
        // No match; but it could be a foward-two-squares move:
        if (backup == NS || Board[from] != EMPTY || Board[backup] != pawn) {
            // A forward-two-squares move is impossible.
            return ERROR_InvalidMove;
        }
        from = backup;
    }

    // OK, now 'from' is the only possible from-square. Is the move legal?
    // We make the move on the board and see if the King is in check.

    uint legal = 0;
    if (fromFyle == toFyle) {
        // Not a capture:

        if (Board[to] != EMPTY) { return ERROR_InvalidMove; }
        Board[to] = pawn;  Board[from] = EMPTY;
        if (CalcNumChecks (GetKingPos(ToMove)) == 0) {
            legal = 1;
        }
       Board[to] = EMPTY; Board[from] = pawn;

    } else {
        // It is a capture -- is it legal?

        pieceT captured = Board[to];
        if (captured == EMPTY) {
            // Must be an en passent or illegal move.
            if (to != EPTarget) { return ERROR_InvalidMove; }
            squareT epSquare = square_Make(toFyle, square_Rank(from));

            // If following assert fails, eptarget was corrupt
            ASSERT (Board[epSquare] == piece_Make(1 - ToMove, PAWN));

            Board[to] = pawn; Board[from] = EMPTY;
            Board[epSquare] = EMPTY;
            Material[piece_Make(1 - ToMove, PAWN)] --;
            if (CalcNumChecks (GetKingPos(ToMove)) == 0) { legal = 1; }
            Board[epSquare] = piece_Make(1 - ToMove, PAWN);
            Board[to] = EMPTY;
            Board[from] = pawn;
            Material[piece_Make(1 - ToMove, PAWN)] ++;

        } else {
            if (piece_Color(captured) == ToMove) {
                // Capturing a friendly!
                return ERROR_InvalidMove;
            } else {
                // A regular capture. See if it leaves King in check:
                Board[to] = pawn;  Board[from] = EMPTY;
                Material[captured]--;
                if (CalcNumChecks (GetKingPos(ToMove)) == 0) {
                    legal = 1;
                }
                Material[captured]++;
                Board[to] = captured; Board[from] = pawn;
            }
        }
    }

    if (legal == 1) {
        AddLegalMove (ListPos[from], to, promote);
        return OK;
    }
    return ERROR_InvalidMove;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::MatchKingMove():
//      Sets the LegalMoves list to contain the matching king move,
//      if there is one.
//
errorT
Position::MatchKingMove (squareT target)
{
    if (LegalMoves == NULL) { AllocLegalMoves(); }
    LegalMoves->num = 0;
    squareT kingSq = GetKingPos(ToMove);
    sint diff = (int)target - (int) kingSq;

    // Valid diffs are: -9, -8, -7, -2, -1, 1, 2, 7, 8, 9. (-2,2: Castling)

    if (diff < -9  ||  diff > 9) { return ERROR_InvalidMove; }
    if (diff > -7  &&  diff < -2) { return ERROR_InvalidMove; }
    if (diff > 2  &&  diff < 7) { return ERROR_InvalidMove; }
    if (diff == 0) { return ERROR_InvalidMove; }

    if (diff == 2) { // KingSide Castling
        if (kingSq != (ToMove == WHITE ? E1 : E8)) {
            return ERROR_InvalidMove;
        }
        if (StrictCastling  &&  ! GetCastling (ToMove, KSIDE)) {
            return ERROR_InvalidMove;
        }

        // XXX We also need to verify that the target square does not
        //     lie adjacent to the location of the enemy king!

        if (Board[kingSq + 1] != EMPTY  ||  Board[kingSq + 2] != EMPTY
            ||  CalcNumChecks(kingSq) > 0
            ||  CalcNumChecks(kingSq + 1) > 0
            ||  CalcNumChecks(kingSq + 2) > 0) {
            return ERROR_InvalidMove;
        }
        AddLegalMove (0, target, EMPTY);
        return OK;
    }

    if (diff == -2) { // Queenside Castling
        if (kingSq != (ToMove == WHITE ? E1 : E8)) {
            return ERROR_InvalidMove;
        }
        if (StrictCastling  &&  ! GetCastling (ToMove, QSIDE)) {
            return ERROR_InvalidMove;
        }
        if (Board[kingSq - 1] != EMPTY  ||  Board[kingSq - 2] != EMPTY
            ||  Board[kingSq - 3] != EMPTY
            ||  CalcNumChecks(kingSq) > 0
            ||  CalcNumChecks(kingSq - 1) > 0
            ||  CalcNumChecks(kingSq - 2) > 0) {
            return ERROR_InvalidMove;
        }
        AddLegalMove (0, target, EMPTY);
        return OK;
    }
    pieceT captured = Board[target];
    if (piece_Color(captured) == ToMove) {
        // Capturing a friendly piece!
        return ERROR_InvalidMove;
    }

    // Now make the move on the Board and Material lists, and see if it
    // leaves the King in check:
    // XXX We should also check for adjacency to enemy King!!

    Board[target] = piece_Make(ToMove, KING);
    Board[kingSq] = EMPTY;
    //if (captured != EMPTY) { Material[captured]--; }
    uint legal = 0;
    if (CalcNumChecks(target) == 0) { legal = 1; }
    //if (captured != EMPTY) { Material[captured]++; }
    Board[target] = captured;
    Board[kingSq] = piece_Make(ToMove, KING);
    if (legal == 1) {
        AddLegalMove (0, target, EMPTY);
        return OK;
    }
    return ERROR_InvalidMove;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::CalcCheckEvasions():
//      Make the legal moves list for the side to move when the
//      King is in check.
//
void
Position::CalcCheckEvasions (pieceT mask)
{
    // Assert that king IS actually in check:
    ASSERT (NumChecks > 0);

    if (LegalMoves == NULL) { AllocLegalMoves(); }
    LegalMoves->num = 0;

    squareT king = GetKingPos (ToMove);

    // if it's double check, we can ONLY move the king
    if (NumChecks == 1) {
        // OK, it is NOT a double check
        // Try to block piece/capture piece. Remember en passent!
        // First, generate a list of targets: squares between the king
        // and attacker to block, and the attacker's square.

        squareT              attackSq    = CheckSquares[0];
        pieceT               attackP     = Board[attackSq];
        register squareDirT  dir         = sqDir[king][attackSq];
        register byte        numTargets  = 1;
        squareT              targets[10];

        targets[0] = attackSq;      // add attacker square to target list.

        // Now add squares we can might be able to block on.
        // If the piece is a knight, we cannot block.

        register squareT sq = sqMove [king][dir];
        if (piece_Type(attackP) != KNIGHT) {
            while (sq != attackSq) {
                if (Board[sq] == EMPTY) {
                    targets[numTargets++] = sq;
                }
                sq = sqMove [sq][dir];
            }
        }

        // Try each non-King piece in turn. If a piece is pinned to
        // the king, don't bother since it cannot possibly block or
        // capture the piece that is giving check!

        register uint   numPieces = Count[ToMove];
        for (register uint p2 = 1; p2 < numPieces; p2++) {
            pieceT p2piece = Board[List[ToMove][p2]];
            if (Pinned[p2] == NULL_DIR) {
                if (mask == EMPTY  ||  mask == piece_Type(p2piece)) {
                    if (piece_Type(p2piece) == PAWN) {
                        // Add the EP target square if last move was
                        // a pawn push two squares to give check.
                        if (EPTarget != NULL_SQUARE) {
                            targets[numTargets++] = EPTarget;
                        }
                        for (register int i = 0; i < numTargets; i++) {
                            GenPawnMoves (p2, NULL_DIR, targets[i]);
                        }
                        if (EPTarget != NULL_SQUARE) {
                            numTargets--;
                        }
                    } else {
                        GeneratePseudos(p2);
                        for (register uint i = 0; i < numTargets; i++) {
                            if (IsPseudoLegal (p2, targets[i])) {
                                AddLegalMove (p2, targets[i], EMPTY);
                            }
                        }
                    }
                }
            }
        }  // end of search for captures/blocks
    }

    // Now king moves -- just compute them normally:
    if (mask == EMPTY  ||  mask == KING) {  GenKingMoves();  }

    LegalMoves->current = true;
    return;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::CalcNumChecks():
//      Calculate the number of checks. This function also puts a list
//      of the checking squares in checkSqs if it is non-NULL.
//
//      It ONLY uses the Board[] and Material[] lists of the Position, and
//      ASSUMES they are correct with respect to each other, but it does
//      NOT use the List[] or ListPos[] information.
//      This allows us to move pieces quickly (altering only Board[] and
//      Material[]) and detect checks without having to update other
//      information.
//
uint
Position::CalcNumChecks (colorT toMove, squareT kingSq, squareT * checkSqs)
{
    // If checkSqs is NULL, caller doesn't want a list of the squares of
    // checking pieces. To avoid comparing checkSqs with NULL every time
    // we find a check, we set up a local array to use instead if checkSqs
    // is NULL.
    squareT checkSquares[16];
    if (checkSqs == NULL) { checkSqs = checkSquares; }

    register uint nChecks = 0;
    register squareT sq;

    // Bishop/Queen/Rook checks: look at each of the 8 directions
    uint enemyQueensRooks, enemyQueensBishops;
    if (toMove == WHITE) {
        enemyQueensRooks = Material[BQ] + Material[BR];
        enemyQueensBishops = Material[BQ] + Material[BB];
    } else {
        enemyQueensRooks = Material[WQ] + Material[WR];
        enemyQueensBishops = Material[WQ] + Material[WB];
    }

    // We only bother if there are any enemy sliding pieces of each type:
    if (enemyQueensRooks > 0) {
        squareDirT dirs[] = { UP, DOWN, LEFT, RIGHT, NULL_DIR };
        register squareDirT * dirPtr = dirs;
        while (*dirPtr != NULL_DIR) {
            register squareT dest = sqMove [kingSq][*dirPtr];
            register pieceT p;
            while (dest != NULL_SQUARE) {
                p = Board[dest];
                if (p == EMPTY) {           // empty square: keep searching
                } else if (piece_Color(p) == toMove) {
                    break;           // friendly piece found
                } else if ((piece_Type(p) == QUEEN)  ||
                           (piece_Type(p) == ROOK)) {
                    checkSqs[nChecks++] = dest;
                    break;
                } else { // enemy, but not a checking piece
                    break;
                }
                dest = sqMove[dest][*dirPtr];
            }
            dirPtr++;
        }
    }

    // Now diagonal sliders: Queen/Bishops:
    if (enemyQueensBishops > 0) {
        squareDirT dirs[] = { UP_LEFT, UP_RIGHT, DOWN_LEFT, DOWN_RIGHT,
                             NULL_DIR };
        register squareDirT * dirPtr = dirs;
        while (*dirPtr != NULL_DIR) {
            register squareT dest = sqMove [kingSq][*dirPtr];
            register pieceT p;
            while (dest != NULL_SQUARE) {
                p = Board[dest];
                if (p == EMPTY) {           // empty square: keep searching
                } else if (piece_Color(p) == toMove) {
                    break;           // friendly piece found
                } else if ((piece_Type(p) == QUEEN)  ||
                           (piece_Type(p) == BISHOP)) {
                    checkSqs[nChecks++] = dest;
                    break;
                } else {
                    break;
                }
                dest = sqMove[dest][*dirPtr];
            }
            dirPtr++;
        }
    }

    // Now pawn checks:
    if (toMove == BLACK) {
        if (Material[WP] > 0) {
            sq = sqMove [kingSq][DOWN_LEFT];
            if (Board[sq] == WP)  {
                checkSqs[nChecks++] = sq;
            }
            sq = sqMove [kingSq][DOWN_RIGHT];
            if (Board[sq] == WP)  {
                checkSqs[nChecks++] = sq;
            }
        }
    } else {
        if (Material[BP] > 0) {
            sq = sqMove [kingSq][UP_LEFT];
            if (Board[sq] == BP)  {
                checkSqs[nChecks++] = sq;
            }
            sq = sqMove [kingSq][UP_RIGHT];
            if (Board[sq] == BP)  {
                checkSqs[nChecks++] = sq;
            }
        }
    }

    // Now knight checks: we use the knightAttacks[] array for moves.
    if (Material[piece_Make(1-toMove, KNIGHT)] > 0) {
        register pieceT enemyKnight = piece_Make(1-toMove, KNIGHT);
        register const squareT * dest = knightAttacks[kingSq];
        while (*dest != NS) {
            if (Board[*dest] == enemyKnight) {
                checkSqs[nChecks++] = *dest;
            }
            dest++;
        }
    }
    return nChecks;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::IsKingInMate():
//      Quick check if king is in mate.
//
bool
Position::IsKingInMate (void)
{
    NumChecks = CalcNumChecks (GetKingPos(ToMove));
    if (NumChecks == 0) { return false; }
    CalcPins ();
    CalcCheckEvasions (EMPTY);
    if (LegalMoves->num == 0) { return true; }
    return false;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::IsLegal()
//   Verifies the position as being legal.
//   Returns false if the two kings are adjacent or the
//   side to move is checking the enemy king.
bool
Position::IsLegal (void)
{
    squareT stmKing = GetKingPos(ToMove);
    squareT stmOpponent = GetKingPos(1-ToMove);
    if (square_Adjacent (stmKing, stmOpponent)) { return false; }
    if (CalcNumChecks (1-ToMove, stmOpponent, NULL) > 0) { return false; }
    return true;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::IsPromoMove():
//      Returns 1 if the move is a promotion move.
//      NOTE that the move may not actually be legal!
//      The arguments 'from' and 'to' can be in either order.
//
int
Position::IsPromoMove (squareT from, squareT to)
{
    rankT seventh, eighth;
    pieceT pawn;
    if (ToMove == WHITE) { seventh = RANK_7; eighth = RANK_8; pawn = WP; }
    else { seventh = RANK_2; eighth = RANK_1; pawn = BP; }
    rankT fromR, toR;
    fromR = square_Rank(from);
    toR = square_Rank(to);
    if ( (fromR == seventh  &&  toR == eighth  &&  Board[from] == pawn)  ||
         (toR == seventh  &&  fromR == eighth  &&  Board[to] == pawn) ) {
        return 1;
    }
    return 0;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::DoSimpleMove():
//      Make the move on the board and update all the necessary
//      fields in the simpleMove structure so it can be undone.
//
void
Position::DoSimpleMove (simpleMoveT * sm)
{
    ASSERT (sm != NULL);
    register pieceT p = Board[sm->from];
    register pieceT ptype = piece_Type(p);
    register colorT enemy = 1 - ToMove;

    // update move fields that (maybe) have not yet been set:
    // sm->pieceNum will have been set but may be inaccurate, e.g. if
    // the move is from an identical position but with a different order
    // of pieces.

    sm->pieceNum = ListPos[sm->from];
    sm->capturedPiece = Board[sm->to];
    sm->capturedSquare = sm->to;
    sm->castleFlags = Castling;
    sm->epSquare = EPTarget;
    sm->oldHalfMoveClock = HalfMoveClock;

    HalfMoveClock++;
    PlyCounter++;

    // Handle en passent capture:

    if (ptype == PAWN  &&  sm->capturedPiece == EMPTY
            && square_Fyle(sm->from) != square_Fyle(sm->to)) {

        // This was an EP capture. We do not need to check it was a capture
        // since if a pawn lands on EPTarget it must capture to get there.

        sm->capturedSquare = (ToMove == WHITE ? (sm->to) - 8 : (sm->to) + 8);
        sm->capturedPiece = Board[sm->capturedSquare];
    }

    // handle captures:

    if (sm->capturedPiece != EMPTY) {
        sm->capturedNum = ListPos[sm->capturedSquare];
        // update opponents List of pieces
        Count[enemy]--;
        ListPos[List[enemy][Count[enemy]]] = sm->capturedNum;
        List[enemy][sm->capturedNum] = List[1-ToMove][Count[enemy]];
        Material[sm->capturedPiece]--;
        HalfMoveClock = 0;
        UNHASH (Hash, sm->capturedPiece, sm->capturedSquare);
    }

    // handle promotion:

    if (sm->promote != EMPTY) {
        Material[p]--;
        UNHASH (Hash, p, sm->from);
        p = piece_Make(ToMove, sm->promote);
        Material[p]++;
        HASH (Hash, p, sm->from);
    }

    // now make the move:

    Board[sm->from] = EMPTY;
    Board[sm->capturedSquare] = EMPTY;
    Board[sm->to] = p;
    List[ToMove][sm->pieceNum] = sm->to;
    ListPos[sm->to] = sm->pieceNum;
    UNHASH (Hash, p, sm->from);
    HASH (Hash, p, sm->to);

    // handle Castling:

    if (ptype == KING  &&  square_Fyle(sm->from) == E_FYLE  &&
            (square_Fyle(sm->to)==C_FYLE  ||  square_Fyle(sm->to)==G_FYLE)) {
        squareT rookfrom, rookto;
        pieceT rook = piece_Make (ToMove, ROOK);
        if (square_Fyle(sm->to) == C_FYLE) {
            rookfrom = (sm->to) - 2;
            rookto = (sm->to) + 1;
        } else {
            rookfrom = (sm->to) + 1;
            rookto = (sm->to) - 1;
        }
        Board[rookto] = rook;
        Board[rookfrom] = EMPTY;
        ListPos[rookto] = ListPos[rookfrom];
        List[ToMove][ListPos[rookto]] = rookto;
        UNHASH (Hash, rook, rookfrom);
        HASH (Hash, rook, rookto);
    }

    // Handle clearing of castling flags:

    if (Castling) {
        if (ptype == KING) {   // The king moved.
            SetCastling (ToMove, QSIDE, false);
            SetCastling (ToMove, KSIDE, false);
        }
        // See if a rook moved or was captured:
        if (ToMove == WHITE) {
            if (sm->from == A1)  { SetCastling (WHITE, QSIDE, false); }
            if (sm->from == H1)  { SetCastling (WHITE, KSIDE, false); }
            if (sm->to == A8)    { SetCastling (BLACK, QSIDE, false); }
            if (sm->to == H8)    { SetCastling (BLACK, KSIDE, false); }
        } else {
            if (sm->from == A8)  { SetCastling (BLACK, QSIDE, false); }
            if (sm->from == H8)  { SetCastling (BLACK, KSIDE, false); }
            if (sm->to == A1)    { SetCastling (WHITE, QSIDE, false); }
            if (sm->to == H1)    { SetCastling (WHITE, KSIDE, false); }
        }
    }

    // set new value for EPTarget square:

    EPTarget = NULL_SQUARE;
    if (ptype == PAWN) {
        if (square_Rank(sm->from) == RANK_2   &&
            square_Rank(sm->to) == RANK_4) {
            EPTarget = sm->from + 8;  // white pawn advances 2 squares.
        }
        if (square_Rank(sm->from) == RANK_7   &&
            square_Rank(sm->to) == RANK_5) {
            EPTarget = sm->from - 8;  // black pawn advances 2 squares.
        }
        HalfMoveClock = 0; // 50-move clock resets on pawn moves.
    }

    ToMove = 1-ToMove;

    // Make sure the "current" flags are false? NO, rely on caller to
    // do that
    //if (LegalMoves != NULL) { LegalMoves->current = false; }
    //if (SANStrings != NULL) { SANStrings->current = false; }

//#ifdef ASSERTIONS  // Do a SLOW, careful check for corruption:
//    AssertPos();
//#endif

    return;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::UndoSimpleMove():
//      Take back a simple move that has been made with DoSimpleMove().
//
void
Position::UndoSimpleMove (simpleMoveT * m)
{
    ASSERT (m != NULL);

    pieceT p = Board[m->to];

    EPTarget = m->epSquare;
    Castling = m->castleFlags;
    HalfMoveClock = m->oldHalfMoveClock;
    PlyCounter--;
    ToMove = 1-ToMove;

    // Handle a capture: insert piece back into piecelist.
    // This works for EP captures too, since the square of the captured
    // piece is in the "capturedSquare" field rather than assuming the
    // value of the "to" field. The only time these two fields are
    // different is for an en passent move.

    if (m->capturedPiece != EMPTY) {
        ListPos[List[1-ToMove][m->capturedNum]] = Count[1-ToMove];
        ListPos[m->capturedSquare] = m->capturedNum;
        List[1-ToMove][Count[1-ToMove]] = List[1-ToMove][m->capturedNum];
        List[1-ToMove][m->capturedNum] = m->capturedSquare;
        Material[m->capturedPiece]++;
        Count[1-ToMove]++;
        HASH (Hash, m->capturedPiece, m->capturedSquare);
    }

    // handle promotion:

    if (m->promote != EMPTY) {
        Material[p]--;
        UNHASH (Hash, p, m->to);
        p = piece_Make(ToMove, PAWN);
        Material[p]++;
        HASH (Hash, p, m->to);
    }

    // now make the move:

    Board[m->from] = p;
    Board[m->to] = EMPTY;
    Board[m->capturedSquare] = m->capturedPiece;
    List[ToMove][m->pieceNum] = m->from;
    ListPos[m->from] = m->pieceNum;
    UNHASH (Hash, p, m->to);
    HASH (Hash, p, m->from);

    // handle Castling:

    if ((piece_Type(p) == KING) && square_Fyle(m->from)==E_FYLE
        && (square_Fyle(m->to)==C_FYLE || square_Fyle(m->to)==G_FYLE))
    {
        squareT rookfrom, rookto;
        pieceT rook = (ToMove == WHITE? WR : BR);
        if (square_Fyle(m->to) == C_FYLE) {
            rookfrom = (m->to) - 2;   rookto = (m->to) + 1;
        } else {
            rookfrom = (m->to) + 1;   rookto = (m->to) - 1;
        }
        Board[rookto] = EMPTY;
        Board[rookfrom] = rook;
        ListPos[rookfrom] = ListPos[rookto];
        List[ToMove][ListPos[rookto]] = rookfrom;
        UNHASH (Hash, rook, rookto);
        HASH (Hash, rook, rookfrom);
    }

//#ifdef ASSERTIONS
//    AssertPos();
//#endif

    return;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::MaterialValue():
//    Returns the sum value of material for a particular side,
//    where piece values are:
//    King: 0 (since both sides always have one)
//    Queen: 9
//    Rook: 5
//    Bishop, Knight: 3 each
//    Pawn: 1
uint
Position::MaterialValue (colorT c)
{
    ASSERT (c == WHITE  ||  c == BLACK);
    uint value = 0;
    if (c == WHITE) {
        value += 9 * PieceCount(WQ);
        value += 5 * PieceCount(WR);
        value += 3 * PieceCount(WB);
        value += 3 * PieceCount(WN);
        value += 1 * PieceCount(WP);
    } else {
        value += 9 * PieceCount(BQ);
        value += 5 * PieceCount(BR);
        value += 3 * PieceCount(BB);
        value += 3 * PieceCount(BN);
        value += 1 * PieceCount(BP);
    }
    return value;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::MakeSANString():
//      Make the SAN string for a simpleMove.
//      The parameter 'sanFlag' indicates whether '+' and '#' symbols
//      should be added to checking or mating moves.
//
void
Position::MakeSANString (simpleMoveT * m, char * s, sanFlagT flag)
{
    ASSERT (m != NULL  &&  s != NULL);

    // Make sure m->pieceNum is updated:
    m->pieceNum = ListPos[m->from];
    pieceT  p    = piece_Type (Board[List[ToMove][m->pieceNum]]);
    squareT from = List[ToMove][m->pieceNum];
    squareT to   = m->to;
    char * c     = s;

    if (p == PAWN) {
        if (square_Fyle(from) != square_Fyle(to)) {  // pawn capture
            *c++ = square_FyleChar(from);
            *c++ = 'x';
        }
        *c++ = square_FyleChar(to);
        *c++ = square_RankChar(to);
        if ((square_Rank(to)==RANK_1) || (square_Rank(to)==RANK_8)) {
            *c++ = '=';
            *c++ = piece_Char(m->promote);
        }

    } else if (p == KING) {
        if ((square_Fyle(from)==E_FYLE) && (square_Fyle(to)==G_FYLE)) {
            *c++ = 'O'; *c++ = '-'; *c++ = 'O';
        } else
        if ((square_Fyle(from)==E_FYLE) && (square_Fyle(to)==C_FYLE)) {
            *c++ = 'O'; *c++ = '-'; *c++ = 'O'; *c++ = '-'; *c++ = 'O';
        } else {  // regular King move
            *c++ = 'K';
            if (Board[to] != EMPTY)  *c++ = 'x';
            *c++ = square_FyleChar(to);
            *c++ = square_RankChar(to);
        }

    } else {    // Queen/Rook/Bishop/Knight
        *c++ = piece_Char(p);

        // We only need to calculate legal moves to disambiguate if there
        // are more than one of this type of piece.

        if (Material[Board[List[ToMove][m->pieceNum]]] < 2) {
            if (Board[to] != EMPTY)  { *c++ = 'x'; }
            *c++ = square_FyleChar(to);
            *c++ = square_RankChar(to);

        } else {
            // disambiguate moves here:
            // SHOULD handle 3-way ambiguity!  Looks like it does ok.
            bool ambiguous_fyle = false;
            bool ambiguous_rank = false;
            char r, f, r2, f2;
            f = square_FyleChar(from);
            r = square_RankChar(from);
            MatchLegalMove (p, to);

            for (int i=0; i < LegalMoves->num; i++) {
                simpleMoveT *m2 = &(LegalMoves->list[i]);
                squareT from2 = List[ToMove][m2->pieceNum];
                pieceT p2 = piece_Type(Board[from2]);
                if ((to == m2->to) && (from != from2) && (p2 == p)) {
                    /* we have an ambiguity */
                    f2 = square_FyleChar (from2);
                    r2 = square_RankChar (from2);
                    if (f == f2) {  // ambiguous fyle, so print rank
                        ambiguous_fyle = true;
                    } else {        // ambiguous rank, so print fyle
                        ambiguous_rank = true;
                    }
                }
            }
            if (ambiguous_rank) { *c++ = f; }  // print from-fyle
            if (ambiguous_fyle) { *c++ = r; }  // print from-rank

            if (Board[to] != EMPTY) { *c++ = 'x'; }
            *c++ = square_FyleChar (to);
            *c++ = square_RankChar (to);
        }
    }

    // Now do the check or mate symbol:
    if (flag != SAN_NO_CHECKTEST) {
        // Now we make the move to test for check:
        DoSimpleMove (m);
        if (CalcNumChecks (GetKingPos(ToMove)) > 0) {
            char ch = '+';
            if (flag == SAN_MATETEST) {
                Position tempPos;
                tempPos.CopyFrom (this);
                tempPos.CalcLegalMoves (EMPTY);
                if (tempPos.LegalMoves->num == 0) { ch = '#'; }
            }
            *c++ = ch;
        }
        UndoSimpleMove (m);
    }
    *c = 0;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::ReadCoordMove():
//      Given a non-promotion move in coordinate notation, 
//      e.g. "e2e4" or "g1f3", generates the legal move it represents.
//      Returns: OK or ERROR_InvalidMove.
//      If "reverse" is true, coordinates in reverse order are acceptable,
//      e.g. "f3g1" for 1.Nf3.
//
errorT
Position::ReadCoordMove (simpleMoveT * m, const char * str, bool reverse)
{
    ASSERT (m != NULL  &&  str != NULL);
    fyleT fromFyle, toFyle;
    rankT fromRank, toRank;
    squareT from, to;
    pieceT promo = EMPTY;

    uint slen = strLength(str);
    if (slen == 5) {
        promo = piece_FromChar(toupper(str[4]));
    } else if (slen != 4) { return ERROR_InvalidMove; }

    fromFyle = fyle_FromChar (str[0]);
    fromRank = rank_FromChar (str[1]);
    from = square_Make (fromFyle, fromRank);
    if (from == NS) { return ERROR_InvalidMove; }

    toFyle = fyle_FromChar (str[2]);
    toRank = rank_FromChar (str[3]);
    to = square_Make (toFyle, toRank);
    if (to == NS) { return ERROR_InvalidMove; }

    CalcLegalMoves(EMPTY);

    for (uint i=0; i < LegalMoves->num; i++) {
        simpleMoveT * sm = &(LegalMoves->list[i]);
        if (sm->promote == promo) {
            if (sm->from == from  &&  sm->to == to) {
                *m = *sm;
                return OK;
            }
            if (reverse  &&  sm->to == from  &&  sm->from == to) {
                *m = *sm;
                return OK;
            }
        }
    }
    return ERROR_InvalidMove;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::ReadMove():
//      Given a move in (possibly sloppy) PGN notation, 
//      generates the legal move it corresponds to.
//      Returns: OK or ERROR_InvalidMove.
//
errorT
Position::ReadMove (simpleMoveT * m, const char * str, tokenT t)
{
    ASSERT (m != NULL  &&  str != NULL);
    const char * s = str;
    char mStr [255];
    pieceT p;
    squareT from = NS;
    squareT to = NS;
    rankT frRank, toRank;
    fyleT frFyle, toFyle;
    // Clear the legal move list:
    if (LegalMoves == NULL) { AllocLegalMoves(); }
    LegalMoves->num = 0;

    // Strip out 'x', '-', etc leaving just pieces, files and ranks:
    char * s2 = mStr;
    uint slen = 0;
    while (!isspace(*s)  &&  *s != '\0') {
        if ((isalpha(*s)  && (*s != 'x'))  ||  isdigit(*s)  ||  *s == '=') {
            *s2 = *s;  s2++;  slen++;
        }
        s++;
    }
    *s2 = '\0';
    s = mStr;

    if (t == TOKEN_Move_Pawn  ||  t == TOKEN_Move_Promote) {  // Pawn moves
        pieceT promo = EMPTY;
        if (t == TOKEN_Move_Promote) {
            // Last char must be Q/R/B/N.
            // Accept the move even if it is of the form "a8Q" not "a8=Q":
            // if (s[slen-2] != '=') { return ERROR_InvalidMove; }
            promo = piece_FromChar(toupper(s[slen-1]));
            if (promo != QUEEN  &&  promo != ROOK  &&  promo != KNIGHT
                && promo != BISHOP) {
                return ERROR_InvalidMove;
            }
            slen--;
            if (s[slen-1] == '=') { slen--; }
        } else {
            // Check if it is a coordinates-style move, in which case it
            // could be any piece:
            if (slen >= 4  &&
                islower(s[0])  &&  isdigit(s[1])  &&
                islower(s[slen-2])  &&  isdigit(s[slen-1])) {
                return ReadCoordMove (m, str, false);
            }
        }
        // First char MUST be a fyle:
        if (*s < 'a'  ||  *s > 'h')  {  return ERROR_InvalidMove; }
        frFyle = fyle_FromChar (s[0]);

        // Check for the compact form of capture with no rank,
        // e.g. "ed" or "de=Q":
        if (slen == 2  &&  (s[1] >= 'a'  &&  s[1] <= 'h')) {
            toFyle = fyle_FromChar (s[1]);
            // Check each rank in turn, looking for the capture:
            for (rankT r = RANK_1; r <= RANK_8; r++) {
                to = square_Make (toFyle, r);
                if (MatchPawnMove (frFyle, to, promo) == OK) {
                    *m = LegalMoves->list[0];
                    return OK;
                }
            }
            // It is NOT a valid capture with no rank:
            return ERROR_InvalidMove;
        }

        toFyle = fyle_FromChar (s[slen-2]);
        toRank = rank_FromChar (s[slen-1]);
        to = square_Make (toFyle, toRank);
        if (to == NS) { return ERROR_InvalidMove; }

        if (MatchPawnMove (frFyle, to, promo) != OK) {
            return ERROR_InvalidMove;
        } else {
            *m = LegalMoves->list[0];
            return OK;
        }
    }

    // Here we handle piece moves, including castling
    if (t != TOKEN_Move_Piece) {  // Must be castling move
        ASSERT(t == TOKEN_Move_Castle_King  ||  t == TOKEN_Move_Castle_Queen);
        from = (ToMove == WHITE ? E1 : E8);
        if (GetKingPos(ToMove) != from) { return ERROR_InvalidMove; }
        to = (t == TOKEN_Move_Castle_King ? (from + 2) : (from - 2));
        if (MatchKingMove (to) != OK) {
            return ERROR_InvalidMove;
        } else {
            *m = LegalMoves->list[0];
            return OK;
        }
    }

    // If we reach here, it is a (non-castling, non-pawn) piece move.

    p = piece_FromChar(*s);
    if (p == EMPTY) { return ERROR_InvalidMove; }
    if (slen < 3  ||  slen > 5) { return ERROR_InvalidMove; }
    toRank = rank_FromChar(s[slen-1]);
    toFyle = fyle_FromChar(s[slen-2]);
    to = square_Make(toFyle, toRank);
    if (to == NS) { return ERROR_InvalidMove; }
    frRank = NO_RANK;
    frFyle = NO_FYLE;
    if (slen > 3) {
        // There is some ambiguity info in input string.

        for (uint i=1; i < slen-2; i++) {  // For each extra char:
            if (isdigit(s[i])) {
                frRank = rank_FromChar(s[i]);
            } else if (s[i] >= 'a'  &&  s[i] <= 'h') {
                frFyle = fyle_FromChar(s[i]);
            }
        }
    }

    // Calculate the matching legal move(s):
    if (p == KING) {
        if (MatchKingMove(to) != OK) {
            return ERROR_InvalidMove;
        } else {
            *m = LegalMoves->list[0];
            return OK;
        }
    } else {  // A Queen/Rook/Bishop/Knight move
        MatchLegalMove (p, to);
    }

    uint i;
    uint matchCount = 0;
    for (i=0; i < LegalMoves->num; i++) {
        // We need to check: (a) that to-square matches, and
        //    (b), that from-square matches any ambiguity indicator.

        simpleMoveT * thisMove = &(LegalMoves->list[i]);
        if (to == thisMove->to
              && (frFyle==NO_FYLE || frFyle == square_Fyle(thisMove->from))
              && (frRank==NO_RANK || frRank == square_Rank(thisMove->from))) {
            // We have a match!!
            *m = *thisMove;
            matchCount++;
        }
    }
    if (matchCount == 1) { return OK; }
    // No match, or too many (ambiguous) moves match:
    return ERROR_InvalidMove;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::ParseMove():
//      Parse a single move from SAN-style notation.
//
errorT
Position::ParseMove (simpleMoveT * sm, const char * line)
{
    const char * s;
    char * s2;
    char mStr [255];
    uint length = 0;
    tokenT token = TOKEN_Invalid;
    errorT err = OK;

    s = line;
    ASSERT (line != NULL);

    // First, strip the move string down to its raw form with no
    // 'x' (capture symbols), etc:

    while (*s != 0  &&  !isalpha(*s)) { s++; }
    if (*s == '\0') { return ERROR_InvalidMove; }
    s2 = mStr; length = 0;
    while (!isspace(*s)  &&  *s != '\0') {
        if ((isalpha(*s)  && (*s != 'x'))  ||  isdigit(*s)  ||  *s == '=') {
            *s2 = *s;  s2++;  length++;
            if (length >= 10) { return ERROR_InvalidMove; }
        }
        s++;
    }
    if (length == 0 ||  length > 10) { return ERROR_InvalidMove; }
    *s2 = '\0';
    if (mStr[0] == 'O') {
        if (mStr[1] == 'O'  &&  mStr[2] == 'O' && mStr[3] == 0) {
            token = TOKEN_Move_Castle_Queen;
        } else if (mStr[1] == 'O'  &&  mStr[2] == 0) {
            token = TOKEN_Move_Castle_King;
        } else { return ERROR_InvalidMove; }
    } else if (mStr[0] == 'K'  ||  mStr[0] == 'Q'  ||  mStr[0] == 'R'  ||
               mStr[0] == 'B'  ||  mStr[0] == 'N'  ||  mStr[0] == 'r'  ||
               mStr[0] == 'k'  ||  mStr[0] == 'q'  ||  mStr[0] == 'n') {
        mStr[0] = toupper(mStr[0]);
        token = TOKEN_Move_Piece;
    } else if (mStr[0] >= 'a'  &&  mStr[0] <= 'h') {
        token = TOKEN_Move_Pawn;
        if (!isdigit (mStr[length - 1])) {
            token = TOKEN_Move_Promote;
        }
    } else { return ERROR_InvalidMove; }
    err = ReadMove (sm, mStr, token);
    // If not successful, and the move started with a lower case letter,
    // try treating it as a piece move instead. This only affects Bishop
    // moves where a lower-case 'b' is used instead of 'B'.
    if (err != OK  &&  token == TOKEN_Move_Pawn) {
        mStr[0] = toupper(mStr[0]);
        token = TOKEN_Move_Piece;
         err = ReadMove (sm, mStr, token);
    }
    if (err != OK) { return ERROR_InvalidMove; }
    return err;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::ReadLine():
//      Parse a sequence of moves separated by whitespace and
//      move numbers, e.g. "1.e4 e5 2.Nf3" or "e4 e5 Nf3".
//
errorT
Position::ReadLine (const char * line)
{
    const char * s = line;
    char mStr[255];
    char * s2;
    uint length = 0;
    simpleMoveT sm;
    tokenT token = TOKEN_Invalid;
    errorT err;

    while (1) {
        while (*s != 0  &&  !isalpha(*s)) { s++; }
        if (*s == '\0') { return OK; }
        s2 = mStr; length = 0;
        while (!isspace(*s)  &&  *s != '\0') {
            if (isalpha(*s)  ||  isdigit(*s)  ||  *s == '=') {
                *s2 = *s;  s2++;  length++;
            }
            s++;
        }
        *s2 = '\0';
        if (*mStr == 'O') {
            if (mStr[1] == 'O'  &&  mStr[2] == 'O' && mStr[3] == 0) {
                token = TOKEN_Move_Castle_Queen;
            } else if (mStr[1] == 'O'  &&  mStr[2] == 0) {
                token = TOKEN_Move_Castle_King;
            }
        } else if (*mStr == 'K'  ||  *mStr == 'Q'  ||  *mStr == 'R'  ||
                   *mStr == 'B'  ||  *mStr == 'N'  ||  *mStr == 'r'  ||
                   *mStr == 'k'  ||  *mStr == 'q'  ||  *mStr == 'n') {
            *mStr = toupper(*mStr);
            token = TOKEN_Move_Piece;
        } else if (*mStr >= 'a'  &&  *mStr <= 'h') {
            token = TOKEN_Move_Pawn;
            if (!isdigit (mStr[length - 1])) {
                token = TOKEN_Move_Promote;
            }
        } else { return ERROR_InvalidMove; }
        err = ReadMove (&sm, mStr, token);
        if (err != OK) { return err; }
        DoSimpleMove (&sm);
    }
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::CalcSANStrings():
//      Calculate the SAN string for each move in the legal moves list.
//
void
Position::CalcSANStrings (sanFlagT flag)
{
    if (SANStrings == NULL)  AllocSANStrings();
    //if (SANStrings->current) return;

    CalcLegalMoves (EMPTY);   // check that legal move list is current
    legalMoveListT lm = *LegalMoves;
    for (ushort i=0; i < lm.num; i++) {
        MakeSANString (&(lm.list[i]), SANStrings->list[i], flag);
    }
    SANStrings->num = lm.num;
    SANStrings->current = true;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::MakeLine():
//      Make a string representing the board, e.g.:
//      "RNBQKBNRPPPPPPPP................................pppppppprbnqkbnr"
//      for the standard initial position.
//
void
Position::MakeLine (char * str)
{
    ASSERT (str != NULL);
    char * s = str;
    for (squareT sq = A1; sq <= H8; sq++) {
        *s++ = PIECE_CHAR[Board[sq]];
    }
    *s = 0;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::DumpBoard():
//      Dump the board to an open file.
//
void
Position::DumpBoard (FILE * fp)
{
    ASSERT (fp != NULL);
    squareT s;
    for (int i=7; i>=0; i--) {
        fputs ("   ", fp);
        for (int j=0; j<8; j++) {
            s = (i*8) + j;
            putc (PIECE_CHAR[Board[s]], fp);
            putc (' ', fp);
        }
        putc ('\n', fp);
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::DumpLists():
//      Dump the piece lists to an open file.
//
void
Position::DumpLists (FILE * fp)
{
    ASSERT (fp != NULL);
    uint i;
    for (colorT c = WHITE; c <= BLACK; c++) {
        for (i=0; i < Count[c]; i++) {
            pieceT p = Board[List[c][i]];
            fprintf (fp, "%2d:", ListPos[List[c][i]]);
            putc (PIECE_CHAR[p], fp);
            putc (square_FyleChar (List[c][i]), fp);
            putc (square_RankChar (List[c][i]), fp);
            putc (' ', fp);
        }
        putc ('\n', fp);
    }
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::ReadFromCompactStr():
//    Sets the position from the provided Null-terminated 33-byte
//    compact string.
//    The first 32 bytes contain the square valued, 4 bits per value,
//    for the square order A1, B1, ...., G8, H8.
//    The next byte contains the side to move, "W" or "B".
errorT
Position::ReadFromCompactStr (const byte * str)
{
    Clear();
    for (uint i=0; i < 32; i++) {
        pieceT p = str[i] >> 4;
        if (p != EMPTY) {
            if (AddPiece (p, i * 2) != OK) {
                return ERROR_Corrupt;
            }
        }
        p = str[i] & 15;
        if (p != EMPTY) {
            if (AddPiece (p, i * 2 + 1) != OK) {
                return ERROR_Corrupt;
            }
        }
    }
    colorT toMove = str[32] - 1;
    if (toMove != WHITE  &&  toMove != BLACK) {
        return ERROR_Corrupt;
    }
    ToMove = toMove;
    Castling = str[33] - 1;
    EPTarget = NULL_SQUARE;
    if (str[34] != 0) { EPTarget = str[34] - 1; }
    return OK;
}

void
Position::PrintCompactStr (char * cboard, bool epField)
{
    for (uint i=0; i < 32; i++) {
        uint i2 = i << 1;
        cboard[i] = (byte)(Board[i2] << 4) | Board[i2+1];
    }
    cboard[32] = 1 + ToMove;
    cboard[33] = 1 + Castling;
    if (epField) {
        cboard[34] = 1 + EPTarget;
        cboard[35] = 0;
    } else {
        cboard[34] = 0;
    }
}

void
Position::PrintCompactStrFlipped (char * cboard, bool epField)
{
    for (uint i=0; i < 32; i++) {
        uint i2 = i << 1;
        // Flip 1st rank to 8th, etc:
        i2 = ((7 - (i2)/8) * 8 + ((i2) % 8));
        cboard[i] = (byte)(PIECE_FLIP[Board[i2]] << 4) | 
            (byte)(PIECE_FLIP[Board[i2+1]]);
    }
    cboard[32] = 1 + (1 - ToMove);
    cboard[33] = 1 + Castling;
    if (epField) {
        cboard[34] = 1 + EPTarget;
        cboard[35] = 0;
    } else {
        cboard[34] = 0;
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::ReadFromFEN():
//      Setup the position from a FEN string.
//      Note: the slashes usually found in Fen strings to mark the start
//      of a new row do not need to be present, but if they are, they must
//      appear at the actual start of a new row or the string will be
//      considered corrupt.
//
//      For efficiency, ReadFromFEN() does not check complete legality.
//      It returns OK even if the position is illegal because the kings
//      are adcajent or the side to move is already giving check. To
//      verify a legal position, call IsLegal() after ReadFromFEN().
//
//      IMPORTANT: the shortcut of having a two-digit number to represent
//      a number of empty rows (e.g. "/24/" instead of "/8/8/8/") is NOT
//      accepted by this function.
//
//      It is not considered an error for the halfmove clock or fullmove
//      counter to be invalid, so this routine can also read positions
//      from EPD lines (which only share the first four fields with FEN).
errorT
Position::ReadFromFEN (const char * str)
{
    // pieceFromByte[] converts a character to its piece, e.g. 'k' -> BK.
    static pieceT pieceFromByte [256];

    // fenSqToRealSquare[] converts a fen square (0 to 63) to its real
    // square. E.g: [0] -> A8, [1] -> B8, .... [63] -> H1.
    static squareT fenSqToRealSquare [64];

    // Note the first Call to set up the static arrays only once:
    static int firstCall = 1;

    ASSERT (str != NULL);
    const char * s = str;
    int count = 0;

    if (firstCall) {
        firstCall = 0;

        // Set up pieceFromByte[]:
        for (int i=0; i < 256; i++) { pieceFromByte[i] = EMPTY; }
        pieceFromByte ['K'] = WK;  pieceFromByte ['k'] = BK;
        pieceFromByte ['Q'] = WQ;  pieceFromByte ['q'] = BQ;
        pieceFromByte ['R'] = WR;  pieceFromByte ['r'] = BR;
        pieceFromByte ['B'] = WB;  pieceFromByte ['b'] = BB;
        pieceFromByte ['N'] = WN;  pieceFromByte ['n'] = BN;
        pieceFromByte ['P'] = WP;  pieceFromByte ['p'] = BP;

        // Set up fenSqToRealSq[]:
        for (int sq=0; sq < 64; sq++) {
            fenSqToRealSquare [sq] = (squareT)((7 - (sq)/8) * 8 + ((sq) % 8));
        }
    }

    Clear ();
    while (count < 64) {
        if (*s == '/') {
            // A FEN string does not have to contain '/'s but if one
            // appears anywhere except the start of a row, it is an error:

            if (count % 8) { return ERROR_InvalidFEN; }

        } else if (*s > '0'  &&  *s < '9') {
            count += (*s - '0');

        } else {
            pieceT p = pieceFromByte [(byte) *s];
            if (p == EMPTY) { return ERROR_InvalidFEN; }
            if (AddPiece (p, fenSqToRealSquare[count]) != OK) {
                return ERROR_InvalidFEN;
            }
            count++;
        }
        s++;
    }
    if (Material[WK] != 1  ||  Material[BK] != 1) { return ERROR_InvalidFEN; }

    // Now the side to move:
    while (isspace(*s)) { s++; }
    switch (*s) {
    case 'w':
        SetToMove (WHITE);
        break;
    case 'b':
        SetToMove (BLACK);
        break;
    default:
        return ERROR_InvalidFEN;
    }
    s++;

    // Now the castling flags:
    while (isspace(*s)) { s++; }
    if (*s == '-') {
        s++;  // do nothing
    } else {
        while (!isspace(*s)  &&  *s != 0) {
            switch (*s) {
            case 'Q':
                SetCastling (WHITE, QSIDE, true);
                break;
            case 'q':
                SetCastling (BLACK, QSIDE, true);
                break;
            case 'K':
                SetCastling (WHITE, KSIDE, true);
                break;
            case 'k':
                SetCastling (BLACK, KSIDE, true);
                break;
            default:
                return ERROR_InvalidFEN;
            }
            s++;
        }
    }

    // Now the EP target:
    while (isspace(*s)) { s++; }
    if (*s == 0) {
        // do nothing
    } else if (*s == '-') {
        EPTarget = NULL_SQUARE;
        s++;  // No EP target
    } else {
        char fylec = *s; s++;
        if (fylec < 'a'  ||  fylec > 'h') {
            return ERROR_InvalidFEN;
        }
        char rankc = *s; s++;
        if (rankc != '3'  &&  rankc != '6') {
            return ERROR_InvalidFEN;
        }
        EPTarget = square_Make(fyle_FromChar(fylec), rank_FromChar(rankc));
    }

    // Now the capture/pawn halfmove clock:
    while (isspace(*s)) { s++; }
    if (*s) {
        HalfMoveClock = (ushort) atoi(s);
    }
    while (!isspace(*s)  && *s != 0) { s++; }

    // Finally, the fullmove counter:
    while (isspace(*s)) { s++; }
    if (*s) {
        int i = atoi(s);
        if (i >= 1) {
            PlyCounter = (i - 1) * 2;
            if (ToMove == BLACK) { PlyCounter++; }
        }
    }
    return OK;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::PrintFEN():
//      Print the FEN representation of the position.
//      If flags == FEN_COMPACT, only the board and side-to-move fields
//              are printed, in compact form (no slashes between rows).
//      If flags == FEN_BOARD, only the board and side-to-move fields
//              are printed.
//      If flags == FEN_CASTLING_EP, the castling and en passent fields
//              are also printed.
//      If flags == FEN_ALL_FIELDS, all fields are printed including
//              the halfmove clock and ply counter.
//
void
Position::PrintFEN (char * str, uint flags)
{
    ASSERT (str != NULL);
    uint emptyRun, iRank, iFyle;
    pieceT * pBoard = Board;
    for (iRank = 0; iRank < 8; iRank++) {
        pBoard = &(Board[(7 - iRank) * 8]);
        emptyRun = 0;
        if (iRank > 0  &&  flags > FEN_COMPACT) { *str++ = '/'; }
        for (iFyle = 0; iFyle < 8; iFyle++, pBoard++) {
            if (*pBoard != EMPTY) {
                if (emptyRun) { *str++ = (byte) emptyRun + '0'; }
                emptyRun = 0;
                *str++ = PIECE_CHAR[*pBoard];
            } else {
                emptyRun++;
            }
        }
        if (emptyRun) { *str++ = (byte) emptyRun + '0'; }
    }

    if (flags > FEN_COMPACT) { *str++ = ' '; }
    *str++ = (ToMove == WHITE ? 'w' : 'b');
    *str = 0;

    if (flags >= FEN_CASTLING_EP) {
        // Add the castling flags and EP flag as well:
        *str++ = ' ';
        if (Castling == 0)  {
            *str++ = '-';
        } else {                
            if (GetCastling (WHITE, KSIDE))  { *str++ = 'K'; }
            if (GetCastling (WHITE, QSIDE))  { *str++ = 'Q'; }
            if (GetCastling (BLACK, KSIDE))  { *str++ = 'k'; }
            if (GetCastling (BLACK, QSIDE))  { *str++ = 'q'; }
        }
        *str++ = ' ';

        // Now the EP target square:
        if (EPTarget == NULL_SQUARE) {
            *str++ = '-';
        } else {
            *str++ = square_FyleChar (EPTarget);
            *str++ = square_RankChar (EPTarget);
        }
        *str = 0;

        if (flags >= FEN_ALL_FIELDS) {
            // Also print the Halfmove and ply counters:
            *str++ = ' ';
            sprintf (str, "%d %d", HalfMoveClock, (PlyCounter / 2) + 1);
        }
    }
    return;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::DumpHtmlBoard():
//      Prints the board in a format for use in HTML documents.
//      Assumes that the HTML document will be in a directory that
//      has a subdirectory bitmapsDir with files "bwr.gif", etc.
//      The numeric arguments are the pixel width and height for each
//      square -- if zero, then the bitmaps are not scaled.

// The following values define the available HTML styles.
// Style 0 has 40x40 non-transparent images in the "bitmaps" directory.
// Style 1 has 36x35 non-transparent images in the "bitmaps2" directory.

struct htmlStyleT {
    const char * dir;  // directory containing images.
    uint width;        // width value specified in <img> tag.
    uint height;       // height value specified in <img> tag.
    bool transparent;  // True if the style uses transparent images,
                       // with square colors set by "bgcolor".
};

void
Position::DumpHtmlBoard (DString * dstr, uint style, const char * dir, bool flip)
{
    const uint HTML_DIAG_STYLES = 2;
    htmlStyleT hs [HTML_DIAG_STYLES];
    hs[0].dir = "bitmaps"; hs[0].width = 40; hs[0].height = 40;
    hs[1].dir = "bitmaps2"; hs[1].width = 36; hs[1].height = 35;
    if (style >= HTML_DIAG_STYLES) { style = 0; }

    uint width = hs[style].width;
    uint height = hs[style].height;
    uint iRank, iFyle;
    pieceT * pBoard;
    if (dir == NULL) { dir = hs[style].dir; }

    dstr->Append ("<br><br><center>\n");
    dstr->Append ("<table Border=1 CellSpacing=0 CellPadding=0>\n");
    for (iRank = 0; iRank < 8; iRank++) {
        dstr->Append ("<tr>\n");
        pBoard = &(Board[(7 - iRank) * 8]);
        for (iFyle = 0; iFyle < 8; iFyle++, pBoard++) {
            pieceT piece = *pBoard;
            if (flip) { piece = Board[iRank * 8 + (7 - iFyle)]; }
            dstr->Append ("  <td><img border=0 ");
            if (width > 0) {
                char temp[40];
                sprintf (temp, "width=%u ", width);
                dstr->Append (temp);
            }
            if (height > 0) {
                char temp[40];
                sprintf (temp, "height=%u ", height);
                dstr->Append (temp);
            }
            dstr->Append ("src=\"");
            dstr->Append (dir);
            dstr->AddChar ('/');
            bool lightSq = ((iRank % 2) == (iFyle % 2));
            if (lightSq) {
                dstr->AddChar ('w');
            } else {
                dstr->AddChar ('b');
            }
            if (piece == EMPTY) {
                dstr->Append ("sq.gif");
            } else {
                colorT c = piece_Color(piece);
                dstr->AddChar (c == WHITE ? 'w' : 'b');
                dstr->AddChar (tolower (PIECE_CHAR[piece]));
                dstr->Append (".gif");
            }
            dstr->Append ("\" alt=\"");
            if (piece == EMPTY) {
                if (! lightSq) { dstr->Append ("::"); }
            } else {
                colorT c = piece_Color(piece);
                dstr->AddChar (c == WHITE ? 'W' : 'B');
                dstr->AddChar (toupper (PIECE_CHAR[piece]));
            }
            dstr->Append ("\"></td>\n");
        }
        dstr->Append ("</tr>\n");
    }
    dstr->Append ("</table>\n");
    //if (ToMove == WHITE) {
    //    dstr->Append ("<br><b>White to move.</b>\n");
    //} else {
    //    dstr->Append ("<br><b>Black to move.</b>\n");
    //}
    dstr->Append("</center><br>");
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::DumpLatexBoard():
//      Prints the board in a format used by a chess package that is
//      available for the LaTeX  or TeX typesetting language.
void
Position::DumpLatexBoard (DString * dstr, bool flip)
{
    uint iRank, iFyle;
    pieceT * pBoard;
    dstr->Append ("\\board{");
    for (iRank = 0; iRank < 8; iRank++) {
        pBoard = &(Board[(7 - iRank) * 8]);
        for (iFyle = 0; iFyle < 8; iFyle++, pBoard++) {
            pieceT piece = *pBoard;
            if (flip) { piece = Board[iRank * 8 + (7 - iFyle)]; }
            if (piece != EMPTY) {
                dstr->AddChar (PIECE_CHAR[piece]);
            } else { // put a space or a '*':
                dstr->AddChar (((iRank % 2) == (iFyle % 2)) ? ' ' : '*');
            }
        }
        if (iRank < 7) {
            dstr->Append ("}\n {");
        } else { dstr->AddChar ('}'); }
    }
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::Compare():
//      Compare another position with this one.
//
sint
Position::Compare (Position * p)
{
    int i = 32;
    byte *p1, *p2;
    p1 = Board;
    p2 = p->Board;
    while (i   &&  *p1 == *p2) {
        i--;  p1++;  p2++;
    }
    if (p1 < p2) { return -1; }
    if (p1 > p2) { return 1; }
    return (ToMove - p->GetToMove());
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::CopyFrom():
//      Copy another position to this one.
//
void
Position::CopyFrom (Position * src)
{
    for (pieceT p=A1; p <= NS; p++) {
        Board[p] = src->Board[p];
    };
    Count[WHITE] = src->Count[WHITE];
    Count[BLACK] = src->Count[BLACK];
    uint i;
    for (i=0; i < 15; i++) { Material[i] = src->Material[i]; }
    for (i=0; i < 64; i++) { ListPos[i] = src->ListPos[i]; }
    for (i=0; i < 16; i++) {
        List[WHITE][i] = src->List[WHITE][i];
        List[BLACK][i] = src->List[BLACK][i];
    }
    EPTarget = src->EPTarget;
    ToMove = src->ToMove;
    PlyCounter = src->PlyCounter;
    HalfMoveClock = src->HalfMoveClock;
    Castling = src->Castling;
    Hash = src->Hash;
    return;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::GetSquares():
//      Return, for a square, a count of the number of squares matching
//      a legal move, and a list of the squares in the order found in
//      the legal moves list.
//
//      The array sqList should be large enough to hold the number of
//      possible squares; 64 is safe but 30 is sufficient, even for Queen
//      moves on an empty board.
//
uint
Position::GetSquares (squareT sq, squareT * sqList)
{
    bool found[64];
    uint numFound = 0;
    for (squareT s=A1; s <= H8; s++) { found[s] = false; }
    for (uint i = 0; i < LegalMoves->num; i++) {
        if (LegalMoves->list[i].from == sq) {
            squareT toSq = LegalMoves->list[i].to;
            if (! found[toSq]) {
                found[toSq] = true;
                sqList[numFound] = toSq;
                numFound++;
            }
        }
        else if (LegalMoves->list[i].to == sq) {
            squareT fromSq = List[ToMove][LegalMoves->list[i].pieceNum];
            if (! found[fromSq]) {
                found[fromSq] = true;
                sqList[numFound] = fromSq;
                numFound++;
            }
        }
    }
    return numFound;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::BestSquare():
//      Return, for a square, the "best" matching square that forms
//      a legal move. The input square can be the square a piece moves
//      from or the square it moves to.
//      If there are no matching legal moves, NULL_SQUARE is returned.
//
//      The "best" move is subjective, and a full search would be needed
//      to make good guesses. We use a fairly simple algorithm: pieces
//      capture more valuable pieces where possible, avoid moving to a
//      square attacked by an enemy pawn, etc.
//
squareT
Position::BestSquare (squareT startSq)
{
    squareT sqList[64];
    fyleT startFyle = square_Fyle (startSq);
    bool isFromSquare = (piece_Color (Board [startSq]) == ToMove);

    if (isFromSquare) {
        CalcLegalMoves (piece_Type (Board[startSq]));
    } else {
        CalcLegalMoves (EMPTY);
    }

    uint count = GetSquares (startSq, sqList);
    if (count == 0) {   // No legal moves:
        return NULL_SQUARE;
    }
    if (count == 1) {   // Only one legal move:
        return sqList[0];
    }

    // At this point, there is more than one move. Two strategies are
    // used: one for from-moves, one for to-moves.

    // PIECE_VALUE[]: Integer values of the pieces. Used to evaluate
    // captures of more valuable pieces.

    const int KING_VAL = 1000;   // Uncapturable, so a silly large value.
    const int QUEEN_VAL = 9;
    const int ROOK_VAL = 5;
    const int BISHOP_VAL = 3;
    const int KNIGHT_VAL = 3;
    const int PAWN_VAL = 1;
    const int PIECE_VALUE [16] = {
        0,
        /* WK to WP: */ KING_VAL, QUEEN_VAL, ROOK_VAL, KNIGHT_VAL,
        BISHOP_VAL, PAWN_VAL,  0, 0,
        /* BK to BP: */ KING_VAL, QUEEN_VAL, ROOK_VAL, KNIGHT_VAL,
        BISHOP_VAL, PAWN_VAL,  0
    };

    uint best = 0;

    if (piece_Color (Board [startSq]) == ToMove) {
        // The given square has a friendly piece, we must select a
        // TARGET square for it to go to.
        // Strategy: if the piece can capture something of equal or
        // greater value, do it; otherwise, just choose the first move.
        // Addition: if it is a King move, try to castle.

        int bestVal = PIECE_VALUE [Board [sqList [0]]];
        int pieceVal = PIECE_VALUE [Board [startSq]];

        if (piece_Type (Board[startSq]) == KING) {
            // KING move: capture anything possible, or castle
            bestVal = 0;
            for (uint i=0; i < count; i++) {
                int value = PIECE_VALUE [Board[sqList[i]]];
                if (value > bestVal) {
                    bestVal = value;
                    best = i;
                } else if (bestVal == 0) {
                    // No captures yet, is it castling?
                    fyleT toFyle = square_Fyle (sqList[i]);
                    if (startFyle == E_FYLE
                          &&  (toFyle == G_FYLE  ||  toFyle == C_FYLE)) {
                        best = i;
                    }
                }
            } // end: for

        } else {
            // NOT a King move:
            for (uint i=1; i < count; i++) {
                int value = PIECE_VALUE [Board[sqList[i]]];
                if (value >= pieceVal  &&  value > bestVal) {
                    bestVal = value;
                    best = i;
                }
            }
        } // end: else (not king move)

        return sqList[best];
    }

    // If the code reaches here:  The given square is a TARGET square,
    // so we must select a piece to go there.
    // Strategy:
    //   (1): If the given sq has an enemy piece, choose the
    //        friendly piece with the lowest value (e.g. a pawn).
    //   (2): If the given sq is attacked by an enemy pawn, choose
    //        the piece with the lowest value (e.g. a pawn).
    //   (3): Choose the lowest NON-pawn piece, if any is available,
    //        unless there is a castling move.

    // Strategy (1),(2): If we are capturing an enemy piece, OR moving to
    //   a square attacked by a pawn, choose the lowest piece or pawn.

    squareT pawnCap1, pawnCap2;
    pieceT enemyPawn;
    if (ToMove == WHITE) {
        pawnCap1 = sqMove[startSq][UP_LEFT];
        pawnCap2 = sqMove[startSq][UP_RIGHT];
        enemyPawn = BP;
    } else {
        pawnCap1 = sqMove[startSq][DOWN_LEFT];
        pawnCap2 = sqMove[startSq][DOWN_RIGHT];
        enemyPawn = WP;
    }

    if ((Board[startSq] != EMPTY)
          ||  (pawnCap1 != NULL_SQUARE  &&  Board[pawnCap1] == enemyPawn)
          ||  (pawnCap2 != NULL_SQUARE  &&  Board[pawnCap2] == enemyPawn))
    {
        // We choose the lowest pawn/piece:

        int lowestVal = PIECE_VALUE [Board [sqList [0]]];
        for (uint i=1; i < count; i++) {
            int value = PIECE_VALUE [Board [sqList [i]]];
            if (value < lowestVal) {
                lowestVal = value;
                best = i;
            }
        }

    } else {
        // Sub-Stategy (3): it is a move to an empty square.
        // We choose the lowest NON-PAWN move, or castling.

        int lowestVal = KING_VAL;
        for (uint i=0; i < count; i++) {
            int value = PIECE_VALUE [Board [sqList [i] ] ];

            if (value == KING_VAL
                    &&  square_Fyle (sqList[i]) == E_FYLE
                    && (startFyle == G_FYLE || startFyle == C_FYLE)) {
                // Castling move, select it.
                best = i;
                break;
            }
            if (value < lowestVal  &&  value != PAWN_VAL) {
                lowestVal = value;
                best = i;
            }
        }
    } // end: else (Sub-strategy 3)

    return sqList[best];
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::FyleCount():
// Count the number of pieces of a specific type on a specified fyle.
uint
Position::FyleCount (pieceT p, fyleT f)
{
    uint count = 0;
    squareT sq = square_Make (f, RANK_1);
    for (uint i=0; i < 8; i++) {
        if (Board[sq] == p) { count++; }
        sq += 8;
    }
    return count;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::RankCount():
// Count the number of pieces of a specific type on a specified rank.
uint
Position::RankCount (pieceT p, rankT r)
{
    uint count = 0;
    squareT sq = square_Make (A_FYLE, r);
    for (uint i=0; i < 8; i++) {
        if (Board[sq] == p) { count++; }
        sq++;
    }
    return count;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Position::Random
//    Given a string such as "KRPKR" or "KRP-kr", sets up a
//    random position with that material configuration.

inline squareT
randomSquare (void) { return random32() % 64; }

inline squareT
randomPawnSquare (void) { return (random32() % 48) + A2; }

errorT
Position::Random (const char * material)
{
    pieceT pieces [32];         // List of pieces excluding kings
    uint nPieces[2] = {0, 0};   // Number of pieces per side excluding kings.
    uint total = 0;             // Total number of pieces excluding kings.

    colorT side = WHITE;

    // The material string must start with a king:
    if (toupper(*material) != 'K') { return ERROR_Corrupt; }
    material++;

    // Read the material string:
    while (1) {
        char ch = toupper(*material);
        if (ch == 0) { break; }
        switch (ch) {
        case 'K':
            if (side == BLACK) { return ERROR_Corrupt; } // Seen third king!
            side = BLACK;
            break;
        case 'Q':  case 'R':  case 'B':  case 'N':  case 'P':
            if (nPieces[side] >= 15) { return ERROR_Corrupt; }
            nPieces[side]++;
            if (ch == 'P') {
                pieces[total] = piece_Make (side, PAWN);
            } else {
                pieces[total] = piece_Make (side, piece_FromChar(ch));
            }
            total++;
            break;
        case ' ':  case '-':  case '.':  case ',':  case ':':
            // Ignore spaces, commas, etc:
            break;
        default:
            return ERROR_Corrupt;
        }
        material++;
    }
    if (side != BLACK) { return ERROR_Corrupt; }  // Never saw Black king!

    // Generate two non-adjacent king squares:
    squareT wk = randomSquare();
    squareT bk = randomSquare();
    while (wk == bk  ||  square_Adjacent (wk, bk)) { bk = randomSquare(); }

    // Now add all other pieces to empty squares, looping until a legal
    // position is found:
    while (1) {
        Clear();
        ToMove = (random32() % 2) ? WHITE : BLACK;
        AddPiece (WK, wk);
        AddPiece (BK, bk);

        for (uint i=0; i < total; i++) {
            squareT sq;
            pieceT p = pieces[i];
            bool isPawn = (piece_Type(p) == PAWN);
            while (1) {
                sq = isPawn ? randomPawnSquare() : randomSquare();
                if (Board[sq] == EMPTY) { break; }
            }
            // Add this piece on the random empty square:
            AddPiece (p, sq);
        }
        // Generated a random position with kings not adjacent and
        // every piece on its own square. We can stop at this
        // attempt if the enemy king is not in check:
        colorT enemy = 1-ToMove;
        squareT enemyKing = (ToMove == WHITE) ? bk : wk;
        if (CalcNumChecks (enemy, enemyKing, NULL) == 0) { break; }
    }
    return OK;
}

//////////////////////////////////////////////////////////////////////
//  EOF: position.cpp
//////////////////////////////////////////////////////////////////////
