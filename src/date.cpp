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

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// date_DecodeToString(): convert date to PGN tag string.
void
date_DecodeToString (dateT date, char * str)
{
    ASSERT(str != NULL);
    uint year, month, day;

    year = date_GetYear (date);
    month = date_GetMonth (date);
    day = date_GetDay (date);

    if (year == 0) {
        *str++ = '?'; *str++ = '?'; *str++ = '?'; *str++ = '?';
    } else {
        *str++ = '0' + (year / 1000);
        *str++ = '0' + (year % 1000) / 100;
        *str++ = '0' + (year % 100) / 10;
        *str++ = '0' + (year % 10);
    }
    *str++ = '.';

    if (month == 0) {
        *str++ = '?'; *str++ = '?';
    } else {
        *str++ = '0' + (month / 10);
        *str++ = '0' + (month % 10);
    }
    *str++ = '.';

    if (day == 0) {
        *str++ = '?'; *str++ = '?';
    } else {
        *str++ = '0' + (day / 10);
        *str++ = '0' + (day % 10);
    }
    *str = 0;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// date_EncodeFromString(): convert PGN tag string to date.
//      The date string format is: "yyyy.mm.dd".
dateT
date_EncodeFromString (const char * str)
{
    // Do checks on str's validity as a date string:
    ASSERT(str != NULL);

    dateT date;
    uint year, month, day;

    // convert year:
    year = strGetUnsigned (str);
    if (year > YEAR_MAX) { year = 0; }
    date = year << YEAR_SHIFT;
    while (*str != 0  &&  *str != '.') { str++; }
    if (*str == '.') { str++; }

    // convert month:
    month = strGetUnsigned (str);
    if (month > 12) { return date; }
    date |= (month << MONTH_SHIFT);
    while (*str != 0  &&  *str != '.') { str++; }
    if (*str == '.') { str++; }

    // convert day:
    day = strGetUnsigned (str);
    if (day > 31) { return date; }
    date |= (day << DAY_SHIFT);

    return date;
}

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

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// date_AddMonths:
//      Returns the date incremented by the specified number of months.
//
dateT
date_AddMonths (dateT date, int numMonths)
{
    uint year = date_GetYear (date);
    uint month = date_GetMonth (date);
    uint day = date_GetDay (date);

    while (numMonths < 0) {
        if (month == 0  ||  month == 1) {
            year--;
            month = 12;
        } else {
            month--;
        }
        numMonths++;
    }
    while (numMonths > 0) {
        month++;
        if (month > 12) {
            year++;
            month = 1;
        }
        numMonths--;
    }
    return ((year << YEAR_SHIFT) | (month << MONTH_SHIFT) | day);
}

//////////////////////////////////////////////////////////////////////
//  EOF: date.cpp
//////////////////////////////////////////////////////////////////////

