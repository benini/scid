//////////////////////////////////////////////////////////////////////
//
//  FILE:       date.h
//              Date format and inline date functions.
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    1.9
//
//  Notice:     Copyright (c) 1999  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////


#ifndef SCID_DATE_H
#define SCID_DATE_H

#include "common.h"


// DATE STORAGE FORMAT:
// In memory, dates are stored in a 32-bit (4-byte) uint, of which only
// the lowest 3 bytes need be used, with the lowest 5 bits for the
// day, the next highest 4 bits for the month and the highest bits for
// the year. This makes date comparisons easy: a bigger date value is
// a more recent date.  If a field is unknown, its value is set to zero.
// On disk, the date is stored in 3 bytes.


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  CONSTANTS and MACROS:

const dateT ZERO_DATE = 0;

const uint  YEAR_SHIFT  = 9;
const uint  MONTH_SHIFT = 5;
const uint  DAY_SHIFT   = 0;

// DAY (31 days) 5 bits (32) , MONTH (12 months) 4 bits (16)

const uint YEAR_MAX = 2047;  // 2^11 - 1

#define DATE_MAKE(y,m,d) (((y) << YEAR_SHIFT) | ((m) << MONTH_SHIFT) | (d))


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// PUBLIC FUNCTIONS


void   date_DecodeToString (dateT date, char * str);
dateT  date_EncodeFromString (const char * str);
bool   date_ValidString (const char * str);
dateT  date_AddMonths (dateT date, int numMonths);


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// date_GetYear():
//      Get the year from a date.
inline uint
date_GetYear (dateT date)
{
    return (uint) (date >> YEAR_SHIFT);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// date_GetMonth():
//      Get the month from a date.
inline uint
date_GetMonth (dateT date)
{
    return (uint) ((date >> MONTH_SHIFT) & 15);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//### date_GetDay():
//      Get the day of the month from a date.
inline uint
date_GetDay (dateT date)
{
    return (uint) (date & 31);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//### date_GetMonthDay():
//      Get the month and day; used to check for year-only dates. S.A
inline uint
date_GetMonthDay (dateT date)
{
    return (uint) (date & 511);
}

#endif   // #ifndef SCID_DATE_H

//////////////////////////////////////////////////////////////////////
//  EOF: date.h
//////////////////////////////////////////////////////////////////////

