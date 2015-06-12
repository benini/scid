//////////////////////////////////////////////////////////////////////
//
//  FILE:       spellchk.cpp
//              SpellChecker class methods
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    3.5
//
//  Notice:     Copyright (c) 2001-2003  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////

#include "spellchk.h"
#include "date.h"
#include "filebuf.h"
#include <ctype.h>

static void
getNameAndComment (char * line, char ** name, char ** comment)
{
    char * s = line;
    // Find the first comment char (#) and make it the end-of-string,
    while (*s != 0) {
        if (*s == '#') {
            *comment = s+1;
            *s = 0;
            break;
        } else {
            s++;
            *comment = s;
        }
    }

    // Strip leading spaces and trailing newline, tab and space chars:
    s = line;
    s = (char *) strTrimLeft(s);
    strTrimRight (s);
    strTrimRight (*comment);
    *name = s;
}

errorT SpellChecker::read(const char* filename, const Progress& progress)
{
    char line [1024];
    nameT nt = NAME_INVALID;

    Filebuf fp;
    if (fp.Open (filename, FMODE_ReadOnly) != OK) { return ERROR_FileOpen; }

    SpellChkValidate validate(filename, *this);

    uint report_i = 0;
    size_t report_done = 0;
    size_t lineLen = 0;
    size_t fileSize = fp.pubseekoff(0, std::ios_base::end);
    fp.pubseekoff(0, std::ios_base::beg);
    while ((lineLen = fp.ReadLine (line, 1024)) != 0) {
        report_done += lineLen;
        if ((report_i++ % 10000) == 0) progress.report(report_done, fileSize);

        char * name = NULL;
        char * comment = NULL;
        getNameAndComment (line, &name, &comment);

        // Now s contains just the name, no extra space or comment.
        if (*name == 0) {
            // Empty or comment-only line; do nothing.
        } else if (*name == '>') {
            // Old biography line: do nothing with it.
        } else if (*name == '%') {
            // Elo data, biography or other unknown info line:
            if (nt >= NUM_NAME_TYPES) return ERROR_Corrupt;

            if (strIsPrefix ("%Elo ", name)) {
                if (names_[nt].size() == 0) return ERROR_Corrupt;
                pElo_.resize(names_[NAME_PLAYER].size());
                pElo_.back().AddEloData(name);
                continue;
            }
            if (strIsPrefix ("%Bio ", name)) {
                if (names_[nt].size() == 0) return ERROR_Corrupt;
                pInfo_.back().addBioData(name+5);
                continue;
            }
            if (strIsPrefix ("%Prefix ", name)) {
                if (general_[nt].addPrefix(name)) continue;
            }
            if (strIsPrefix ("%Infix ", name)) {
                if (general_[nt].addInfix(name)) continue;
            }
            if (strIsPrefix ("%Suffix ", name)) {
                if (general_[nt].addSuffix(name)) continue;
            }
            validate.ignoredLine(name);
        } else if (*name == '@') {
            // Name type line: "@PLAYER", "@SITE", "@EVENT" or "@ROUND"
            nt = NameBase::NameTypeFromString (name+1);
            if (nt >= NUM_NAME_TYPES) return ERROR_Corrupt;

                // Now check if there is a list of characters to exclude from
                // comparisons, e.g:   @PLAYER ", .-"
                // would indicate to exclude dots, commas, spaces and dashes.
                char * start = strchr (name, '"');
                if (start != NULL) {
                    char * end = strchr (start + 1, '"');
                    if (end != NULL) {
                        *end = 0;
                        excludeChars_[nt] = start + 1;
                    } else {
                        return ERROR_Corrupt;
                    }
                }
        } else {
            if (*name == '=') {
                if (nt >= NUM_NAME_TYPES || names_[nt].size() == 0) {
                    return ERROR_Corrupt;
                }

                // Incorrect spelling of name. Skip over "=" and spaces:
                name++;
                while (*name == ' ') { name++; }
            } else {
                // Correctly spelt name; add to the list:
                names_[nt].push_back(name);
                pInfo_.push_back(PlayerInfo(comment));
            }
            Idx tmp;
            tmp.alias = normalizeAndTransform(nt, name);
            tmp.idx = names_[nt].size() -1;
            idx_[nt].push_back(tmp);
        }
    }

    for (nameT i=0; i < NUM_NAME_TYPES; i++) {
        std::sort(idx_[i].begin(), idx_[i].end());
        validate.idxDuplicates(i);
    }
    if (pElo_.size() > 0) {
        pElo_.resize(names_[NAME_PLAYER].size());
        validate.checkEloData();
    }
    return OK;
}

// Retrieve the list of Rating figures for given player (aka node) from the given (ssp) string
// The string is formatted as:
// [%Elo ]<year>:<<rating>|?>,...,<<rating>|?> [<year>:<<rating>|?>,...,<<rating>|?>...]
//
// The ratings are stored in a rating array for this player, in the order of appearance
// and without any assumption on the period that the rating refers to.
// This is accomplished by assuming that for all years the same number of rating figures
// could be given (see ELO_RATINGS_PER_YEAR above).
//
// The (external) algorithm to map ratings to actual periods must be able to cope with
// the holes that - as a consequence - will appear in the rating graph constructed here!
//
void PlayerElo::AddEloData(const char * str)
{
    // Skip the %Elo prefix. TODO: Apparently it may or may not be there....
    //
    if (strIsPrefix ("%Elo ", str)) { str += 4; }
    
    while (1) {
        // Get the year in which the rating figures to follow were published
        //
        str = strTrimLeft (str);
        if (! isdigit (*str)) { break; }
        uint16_t year = strGetUnsigned (str);
        str += 4;
        if (*str != ':') { break; }
        str++;

        // Now read all the ratings for this year:
        //
        eloT elo = 0;
        while (1) {
            if (isdigit (*str)) {
                elo = strGetUnsigned (str);
                str += 4;
            } else if (*str == '?') {
                elo = 0;
                str++;
            } else if (*str == ' ') {
                break;
            } else {
                // Invalid data seen:
                return;
            }

            elo_.push_back(std::make_pair(year, elo));

            if (*str == ',') { str++; }
        }
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// PlayerInfo::GetTitle:
//    Extract the first title appearing in the player
//    comment, and return it.
const char *
PlayerInfo::getTitle() const
{
    static const char * titles[] = {
        "gm", "im", "fm",
        "wgm", "wim", "wfm", "w",
        "cgm", "cim", "hgm",
        NULL
    };
    const char ** titlePtr = titles;

    if (comment_.empty()) { return ""; }

    while (*titlePtr != NULL) {
        if (strIsPrefix (*titlePtr, comment_.c_str())) { return *titlePtr; }
        titlePtr++;
    }
    return "";
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// PlayerInfo::GetLastCountry:
//    Scan the player comment string for the country field (which
//    is the second field, after the title), then return the
//    last three letters in the country field, or the empty string
//    if the country field is less than 3 characters long.
const char *
PlayerInfo::getLastCountry() const
{
    static char country[4];
    country[0] = 0;

    if (comment_.empty()) { return ""; }

    const char * start = comment_.c_str();
    // Skip over the title field:
    while (*start != ' '  &&  *start != 0) { start++; }
    while (*start == ' ') { start++; }

    const char * end = start;
    int length = 0;
    while (*end != ' '  &&  *end != 0) { end++; length++; }
    // Return the final three characters of the country field:
    if (length >= 3) {
        for (int i=0; i < 3; i++) { country[i] = start[length-3 + i]; }
        country[3] = 0;
    }
    return country;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// PlayerInfo::GetPeakRating:
//    Scan the player comment string for the peak rating
//    field (which is contained in brackets), convert it
//    to an unsigned integer, and return it.
eloT
PlayerInfo::getPeakRating() const
{
    if (comment_.empty()) { return 0; }
    const char * s = comment_.c_str();
    while (*s != '['  &&  *s != 0) { s++; }
    if (*s != '[') { return 0; }
    s++;
    return strGetUnsigned (s);
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// PlayerInfo::GetBirthdate:
//    Scan the player comment string for the birthdate
//    field, convert it to a date, and return it.
dateT
PlayerInfo::getBirthdate() const
{
    if (comment_.empty()) { return ZERO_DATE; }
    const char * s = comment_.c_str();
    // Find the end-bracket character after the rating:
    while (*s != ']'  &&  *s != 0) { s++; }
    if (*s != ']') { return ZERO_DATE; }
    s++;
    // Now skip over any spaces:
    while (*s == ' ') { s++; }
    if (*s == 0) { return ZERO_DATE; }
    return date_EncodeFromString (s);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// PlayerInfo::GetDeathdate:
//    Scan the player comment string for the deathdate
//    field, convert it to a date, and return it.
dateT
PlayerInfo::getDeathdate() const
{
    if (comment_.empty()) { return ZERO_DATE; }
    const char * s = comment_.c_str();
    // Find the end-bracket character after the rating:
    while (*s != ']'  &&  *s != 0) { s++; }
    if (*s != ']') { return ZERO_DATE; }
    s++;
    // Now skip over any spaces:
    while (*s == ' ') { s++; }
    // Now skip over the birthdate and dashes:
    while (*s != 0  &&  *s != '-') { s++; }
    while (*s == '-') { s++; }
    if (*s == 0) { return ZERO_DATE; }
    return date_EncodeFromString (s);
}

//////////////////////////////////////////////////////////////////////
//  EOF: spellchk.cpp
//////////////////////////////////////////////////////////////////////
