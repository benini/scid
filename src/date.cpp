//////////////////////////////////////////////////////////////////////
//
//  FILE:       date.cpp
//              Date functions.
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    1.9
//
//  Notice:     Copyright (c) 1999  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////


#include "common.h"
#include "date.h"
#include "misc.h"

bool
date_ValidString (const char * str)
{
    uint maxValues[3] = { YEAR_MAX, 12, 31 };

    // Check year, then month, then day:
    for (uint i=0; i < 3; i++) {
        uint maxValue = maxValues[i];
        bool seenQuestion, seenDigit, seenOther;
        seenQuestion = seenDigit = seenOther = false;
        const char * start = str;
        while (*str != 0  &&  *str != '.') {
            char ch = *str;
            if (ch >= '0'  &&  ch <= '9') {
                seenDigit = true;
            } else if (ch == '?') {
                seenQuestion = true;
            } else {
                seenOther = true;
            }
            str++;
        }
        // Here, we should have seen question marks or digits, not both:
        if (seenOther) { return false; }
        if (seenQuestion  &&  seenDigit) { return false; }
        if (seenDigit) {
            // Check that the value is not too large:
            uint value = strGetUnsigned (start);
            if (value > maxValue) { return false; }
        }
        if (*str == 0) { return true; } else { str++; }
    }
    return false;
}

//////////////////////////////////////////////////////////////////////
//  EOF: date.cpp
//////////////////////////////////////////////////////////////////////

