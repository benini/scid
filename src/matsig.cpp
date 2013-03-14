//////////////////////////////////////////////////////////////////////
//
//  FILE:       matsig.cpp
//              Material signature routines
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    3.3
//
//  Notice:     Copyright (c) 1999-2002  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////


// A matsig (material signature) is a count of material by piece type,
// compacted into three bytes. Because it is compacted, there are limits
// that a game with an unusual number of promotions might break.
// The maximum count for a non-pawn piece is three.

#include "matsig.h"


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// matsig_makeString(): Make a string representation of a matsig.
//      Example: "12228.12228" for the starting position.
void
matsig_makeString (char * s, matSigT m)
{
    *s++ = (char) MATSIG_Count_WQ(m) + '0';
    *s++ = (char) MATSIG_Count_WR(m) + '0';
    *s++ = (char) MATSIG_Count_WB(m) + '0';
    *s++ = (char) MATSIG_Count_WN(m) + '0';
    *s++ = (char) MATSIG_Count_WP(m) + '0';
    *s++ = '.';
    *s++ = (char) MATSIG_Count_BQ(m) + '0';
    *s++ = (char) MATSIG_Count_BR(m) + '0';
    *s++ = (char) MATSIG_Count_BB(m) + '0';
    *s++ = (char) MATSIG_Count_BN(m) + '0';
    *s++ = (char) MATSIG_Count_BP(m) + '0';
    *s = 0;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// matsig_isReachable(): 
//      Return 1 if start could transform into target with
//      captures and (maybe) promotions. This is used to exclude games
//      from a material or position search without needing to decode
//      them, by checking each game's final position matsig.
//
bool
matsig_isReachable (matSigT mStart, matSigT mTarget, bool promos, bool upromo)
{
    if (MATSIG_Count_WP(mStart) < MATSIG_Count_WP(mTarget))  { return false; }
    if (MATSIG_Count_BP(mStart) < MATSIG_Count_BP(mTarget))  { return false; }

    // If there are underpromotions, we can only check pawn counts:
    if (upromo) { return true; }

    // No underpromotions, so check non-queen piece counts:
    if (MATSIG_Count_WR(mStart) < MATSIG_Count_WR(mTarget))  { return false; }
    if (MATSIG_Count_BR(mStart) < MATSIG_Count_BR(mTarget))  { return false; }
    if (MATSIG_Count_WB(mStart) < MATSIG_Count_WB(mTarget))  { return false; }
    if (MATSIG_Count_BB(mStart) < MATSIG_Count_BB(mTarget))  { return false; }
    if (MATSIG_Count_WN(mStart) < MATSIG_Count_WN(mTarget))  { return false; }
    if (MATSIG_Count_BN(mStart) < MATSIG_Count_BN(mTarget))  { return false; }

    // If there were promotions we cannot check queen counts:
    if (promos) { return true; }

    // Check queen counts:
    if (MATSIG_Count_WQ(mStart) < MATSIG_Count_WQ(mTarget))  { return false; }
    if (MATSIG_Count_BQ(mStart) < MATSIG_Count_BQ(mTarget))  { return false; }

    return true;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// matsig_Make():
//      Make a material sig, given an array of material counts as
//      stored in a Position.
//
inline static uint min(uint a, uint b) { return a < b ? a : b; }

matSigT
matsig_Make (byte * materialCounts)
{
    register matSigT m = 0;
    m |= ::min(3, static_cast<uint>(materialCounts[WQ])) << SHIFT_WQ;
    m |= ::min(3, static_cast<uint>(materialCounts[WR])) << SHIFT_WR;
    m |= ::min(3, static_cast<uint>(materialCounts[WB])) << SHIFT_WB;
    m |= ::min(3, static_cast<uint>(materialCounts[WN])) << SHIFT_WN;
    m |= static_cast<uint>(materialCounts[WP]) << SHIFT_WP;
    m |= ::min(3, static_cast<uint>(materialCounts[BQ])) << SHIFT_BQ;
    m |= ::min(3, static_cast<uint>(materialCounts[BR])) << SHIFT_BR;
    m |= ::min(3, static_cast<uint>(materialCounts[BB])) << SHIFT_BB;
    m |= ::min(3, static_cast<uint>(materialCounts[BN])) << SHIFT_BN;
    m |= static_cast<uint>(materialCounts[BP]) << SHIFT_BP;
    return m;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// hpSig_PossibleMatch():
//      Returns 1 if a game could match the home pawn signature in hpSig.
//      The argument changeList is the ordered list of pawns that leave
//      their home rank (by moving or being captured).
//
//      Used to exclude games in exact position searches. For example,
//      If we are looking for the position after "1.d4 d5 2.c4", the
//      target hpSig looks like "1100111111101111" (the c2, d2 and d7
//      pawns are gone from the home ranks).
//
//      The first byte of a changeList is the length (in halfbytes) of the
//      list, which can be any value from 0 to 16 inclusive.
//
bool
hpSig_PossibleMatch (uint hpSig, const byte * changeList)
{
    // First, the starting sig (all pawns home) can match any game:
    if (hpSig == HPSIG_StdStart)  { return true; }

    uint hpCurrent = HPSIG_StdStart;
    uint count = (uint) changeList[0];
    changeList++;
    uint halfByte = 0;
    byte change;

    for (uint i=0; i < count; i++) {
        if (halfByte == 0) {
            change = (*changeList) >> 4;
            halfByte = 1;
        } else {
            change = (*changeList) & 15;
            halfByte = 0;
            changeList++;
        }
        hpCurrent &= ~(1 << change);
        if (hpCurrent == hpSig)  { return true; }

        // Here is an optimisation: If the target HP sig contains a home
        // pawn not in the current HP sig, it could never match since pawns
        // cannot reappear on their home rank! This test is easy and fast:

        if ((hpCurrent & hpSig) != hpSig)  { return false; }
    }

    // Loop finished, no match was found.
    return false;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// hpSig_Prefix():
//      Returns true if one of the changeLists provided is a prefix
//      of the other or if they are the same.
//      Used to quickly test if one game is possibly a truncated version
//      of another game.
//
bool
hpSig_Prefix (const byte * changeListA, const byte * changeListB)
{
    uint countA = changeListA[0];
    uint countB = changeListB[0];
    changeListA++;
    changeListB++;
    bool halfByte = false;
    byte changeA;
    byte changeB;

    // Use the shorter changeList length:
    uint count = (countA < countB ? countA : countB);

    // Check each corresponding value in the lists:
    for (uint i=0; i < count; i++) {
        if (halfByte) {
            changeA = *changeListA & 15;
            changeB = *changeListB & 15;
            changeListA++;
            changeListB++; 
            halfByte = false;
        } else {
            changeA = *changeListA >> 4;
            changeB = *changeListB >> 4;
            halfByte = true;
        }
        if (changeA != changeB) { return false; }
    }
    return true;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// hpSig_Final():
//      Returns the final home pawn signature value of a changeList.
//
uint
hpSig_Final (const byte * changeList)
{
    uint hpSig = HPSIG_StdStart;
    uint count = (uint) changeList[0];
    changeList++;
    bool halfByte = false;
    byte change;
    for (uint i=0; i < count; i++) {
        if (halfByte == false) {
            change = (*changeList) >> 4;
            halfByte = true;
        } else {
            change = (*changeList) & 15;
            halfByte = false;
            changeList++;
        }
        hpSig -= (1 << change);
    }
    return hpSig;
}

//////////////////////////////////////////////////////////////////////
//  EOF: matsig.cpp
//////////////////////////////////////////////////////////////////////

