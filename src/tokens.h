///////////////////////////////////////////////////////////////////////////
//
//  FILE:       tokens.h
//              Tokens used for scanning PGN.
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    2.7
//
//  Notice:     Copyright (c) 1999-2001  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (shane@cosc.canterbury.ac.nz)
//
///////////////////////////////////////////////////////////////////////////


#ifndef SCID_TOKENS_H
#define SCID_TOKENS_H

//
// TOKENS used by PGN scanner
//

typedef uint tokenT;

#define MAX_TOKEN 56;

const tokenT
    TOKEN_EndOfInput = 0,  // No more characters to read from input source
    TOKEN_Invalid    = 1,  // Unknown token
    TOKEN_MoveNum    = 3,  // Move Number. e.g.  "1." or "2..."
    TOKEN_Ignore     = 4;  // Anything ignored, like "e.p."

const tokenT
    TOKEN_Move_Pawn         = 5,  // Excludes Promotions
    TOKEN_Move_Promote      = 6,  // Promotions
    TOKEN_Move_Piece        = 7,  // Includes ambiguous moves and captures
    TOKEN_Move_Castle_King  = 8,
    TOKEN_Move_Castle_Queen = 9;
#define TOKEN_isMove(x) (((x) >= 5)  &&  ((x) <= 9))
#define TOKEN_isPawnMove(x) (((x) >= 5)  &&  ((x) <= 6))

// Tags: currently only TOKEN_Tag. Maybe eventually have TOKEN_Tag_Event, etc.
const tokenT
    TOKEN_Tag = 10,
    TOKEN_TagEnd = 11;
#define TOKEN_isTag(x)  ((x) == 10)

// Results
const tokenT
    TOKEN_Result_White = 41,    // White wins
    TOKEN_Result_Black = 42,    // Black wins
    TOKEN_Result_Draw  = 43,    // Draw
    TOKEN_Result_Star  = 44;    // Incomplete/unknown ("*")
#define TOKEN_isResult(x)  (((x) >= 41)  &&  ((x) <= 44))

// Comments, Variations
const tokenT
    TOKEN_Nag =         51,  // $xxx   example: $12
    TOKEN_Suffix =      52,  // !, ?, !!, ??, !?, ?!
    TOKEN_Check =       53,  // "+"
    TOKEN_Mate =        54,  // "#"
    TOKEN_Comment =     55,  // { .... }
    TOKEN_LineComment = 56,  // "%" or ";" until end of line
    TOKEN_VarStart =    57,  // "(" ....
    TOKEN_VarEnd =      58;  //  .... ")"

#endif  // SCID_TOKENS_H

///////////////////////////////////////////////////////////////////////////
//  EOF: tokens.h
///////////////////////////////////////////////////////////////////////////
