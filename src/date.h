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

#include <algorithm>
#include <cstddef>
#include <cstdlib>
#include <stdint.h>

// DATE STORAGE FORMAT:
// In memory, dates are stored in a 32-bit (4-byte) uint, of which only
// the lowest 3 bytes need be used, with the lowest 5 bits for the
// day, the next highest 4 bits for the month and the highest bits for
// the year. This makes date comparisons easy: a bigger date value is
// a more recent date.  If a field is unknown, its value is set to zero.
// On disk, the date is stored in 3 bytes.


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  CONSTANTS and MACROS:

typedef uint32_t    dateT;

const dateT ZERO_DATE = 0;

const uint32_t  YEAR_SHIFT  = 9;
const uint32_t  MONTH_SHIFT = 5;
const uint32_t  DAY_SHIFT   = 0;

// DAY (31 days) 5 bits (32) , MONTH (12 months) 4 bits (16)

const uint32_t YEAR_MAX = 2047;  // 2^11 - 1

#define DATE_MAKE(y,m,d) (((y) << YEAR_SHIFT) | ((m) << MONTH_SHIFT) | (d))


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// date_GetYear():
//      Get the year from a date.
inline uint32_t
date_GetYear (dateT date)
{
    return (uint32_t) (date >> YEAR_SHIFT);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// date_GetMonth():
//      Get the month from a date.
inline uint32_t
date_GetMonth (dateT date)
{
    return (uint32_t) ((date >> MONTH_SHIFT) & 15);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//### date_GetDay():
//      Get the day of the month from a date.
inline uint32_t
date_GetDay (dateT date)
{
    return (uint32_t) (date & 31);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//### date_GetMonthDay():
//      Get the month and day; used to check for year-only dates. S.A
inline uint32_t
date_GetMonthDay (dateT date)
{
    return (uint32_t) (date & 511);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// date_DecodeToString(): convert date to PGN tag string.
inline void
date_DecodeToString (dateT date, char * str)
{
    ASSERT(str != NULL);
    uint32_t year, month, day;

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
inline dateT
date_EncodeFromString (const char * str)
{
    // Do checks on str's validity as a date string:
    ASSERT(str != NULL);

    dateT date;
    uint32_t year, month, day;

    // convert year:
    year = std::strtoul(str, NULL, 10);
    if (year > YEAR_MAX) { year = 0; }
    date = year << YEAR_SHIFT;
    while (*str != 0  &&  *str != '.') { str++; }
    if (*str == '.') { str++; }

    // convert month:
    month = std::strtoul(str, NULL, 10);
    if (month > 12) { return date; }
    date |= (month << MONTH_SHIFT);
    while (*str != 0  &&  *str != '.') { str++; }
    if (*str == '.') { str++; }

    // convert day:
    day = std::strtoul(str, NULL, 10);
    if (day > 31) { return date; }
    date |= (day << DAY_SHIFT);

    return date;
}

/**
 * Creates a dateT object from a PGN tag value string.
 * "The Date tag value field always uses a standard ten character format:
 * "YYYY.MM.DD". If the any of the digit fields are not known, then question
 * marks are used in place of the digits."
 * @param str: pointer to the memory containing the tag value.
 * @param len: length of the tag value.
 * @returns the dateT object corresponding to @e str.
 */
inline dateT date_parsePGNTag(const char* str, size_t len) {
	auto is_digit = [](auto v) { return v >= 0 && v <= 9; };

	if (len < 4 || len > 10)
		return {};

	int tmp[10];
	std::transform(str, str + len, tmp, [](unsigned char ch) {
		return ch - static_cast<unsigned char>('0');
	});
	std::fill(tmp + len, tmp + 10, -1);

	uint32_t year = tmp[0] * 1000 + tmp[1] * 100 + tmp[2] * 10 + tmp[3];
	if (!std::all_of(tmp, tmp + 4, is_digit) || year > YEAR_MAX)
		return {};

	uint32_t month = 0;
	if (!is_digit(tmp[4]) && is_digit(tmp[5])) {
		if (!is_digit(tmp[6])) {
			// Accept the format YYYY.M.DD or YYYY.M.D
			std::rotate(tmp + 5, tmp + 9, tmp + 10);
			tmp[5] = 0;
		}
		month = tmp[5] * 10 + tmp[6];
		if (month > 12)
			month = 0;
	}

	uint32_t day = 0;
	if (!is_digit(tmp[7]) && is_digit(tmp[8])) {
		day = is_digit(tmp[9]) ? tmp[8] * 10 + tmp[9] : tmp[8];
		if (day > 31)
			day = 0;
	}

	return (year << YEAR_SHIFT) | (month << MONTH_SHIFT) | (day << DAY_SHIFT);
}

inline dateT date_parsePGNTag(std::pair<const char*, const char*> str) {
	return date_parsePGNTag(str.first, std::distance(str.first, str.second));
}

#endif   // #ifndef SCID_DATE_H

//////////////////////////////////////////////////////////////////////
//  EOF: date.h
//////////////////////////////////////////////////////////////////////

