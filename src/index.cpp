//////////////////////////////////////////////////////////////////////
//
//  File:       index.cpp
//              Index File Class
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    4.0
//
//  Notice:     Copyright (c) 1999-2002  Shane Hudson.  all rights reserved.
//  Notice:     Copyright (c) 2006-2009  Pascal Georges.  all rights reserved.
//
//  Authors:     Shane Hudson (sgh@users.sourceforge.net)
//               Pascal Georges
//////////////////////////////////////////////////////////////////////

#include "common.h"
#include "error.h"
#include "filter.h"
#include "index.h"
#include "misc.h"
#include "date.h"
#include "game.h"
#include "stored.h"


//////////////////////////////////////////////////////////////////////
//
//   IndexEntry Class Methods
//


// Array of sorting criteria names: This must match the ordering of
// the enum { SORT_date, ..., SORT_sentinel }; declared below.

static const char * sortCriteriaNames[] = {
    "Date", "Year", "Event", "Site", "Round",
    "White", "Black", "Eco", "Result", "Length",
    "Rating", "Country", "Month", "Deleted", "Eventdate", NULL
};

enum {
    SORT_date, SORT_year, SORT_event, SORT_site, SORT_round,
    SORT_white, SORT_black, SORT_eco, SORT_result, SORT_moveCount,
    SORT_avgElo, SORT_country, SORT_month,
    SORT_deleted, SORT_eventdate, SORT_sentinel
};


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// IndexEntry::Init():
//        Initialise a single index entry.
//
void
IndexEntry::Init ()
{
    SetOffset (0);
    //SetLength (0);
    Length_Low = 0;
    Length_High = 0;
    SetWhite (0);
    SetBlack (0);
    SetEvent (0);
    SetSite (0);
    SetRound (0);
    SetDate (ZERO_DATE);
    SetEventDate (ZERO_DATE);
    SetResult (RESULT_None);
    SetEcoCode (ECO_None);
    SetNumHalfMoves (0);
    Flags = 0;
    VarCounts = 0;
    SetFinalMatSig (MATSIG_Empty);
    SetStoredLineCode (0);
    SetWhiteElo (0);
    SetBlackElo (0);
    SetWhiteRatingType (0);
    SetBlackRatingType (0);
    for (uint i=0; i < HPSIG_SIZE; i++) {
        HomePawnData[i] = 0;
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// IndexEntry::Verify():
//      Checks the fields of the IndexEntry to make sure that
//      name ID values are valid for the specified NameBase, etc.
//
//      Returns: OK if all is OK, or ERROR_Corrupt if there is an error.
//
errorT
IndexEntry::Verify (NameBase * nb)
{
    bool corrupt = false;
    if (GetWhite() >= nb->GetNumNames (NAME_PLAYER)) {
        SetWhite (0);  corrupt = true;
    }
    if (GetBlack() >= nb->GetNumNames (NAME_PLAYER)) {
        SetBlack (0);  corrupt = true;
    }
    if (GetEvent() >= nb->GetNumNames (NAME_EVENT)) {
        SetEvent (0);  corrupt = true;
    }
    if (GetSite() >= nb->GetNumNames (NAME_SITE)) {
        SetSite (0);  corrupt = true;
    }
    if (GetRound() >= nb->GetNumNames (NAME_ROUND)) {
        SetRound (0);  corrupt = true;
    }
    return (corrupt ? ERROR_Corrupt : OK);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// IndexEntry::GetEventDate ():
//    Returns the EventDate for this game.
dateT
IndexEntry::GetEventDate (void)
{
    uint dyear = date_GetYear (GetDate());
    dateT edate = u32_high_12 (Dates);
    uint month = date_GetMonth (edate);
    uint day = date_GetDay (edate);
    uint year = date_GetYear(edate) & 7;
    if (year == 0) { return ZERO_DATE; }
    year = dyear + year - 4;
    return DATE_MAKE (year, month, day);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// IndexEntry::SetEventDate():
//    Sets the EventDate for this game.
void
IndexEntry::SetEventDate (dateT edate)
{
    uint codedDate = date_GetMonth(edate) << 5;
    codedDate |= date_GetDay (edate);
    uint eyear = date_GetYear (edate);
    uint dyear = date_GetYear (GetDate());
    if (eyear < (dyear - 3)  ||  eyear > (dyear + 3)) { eyear = 0; }

    if (eyear == 0) {
        codedDate = 0; 
    } else {
        codedDate |= (((eyear + 4 - dyear) & 7) << 9);
    }
    Dates = u32_set_high_12 (Dates, codedDate);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// IndexEntry::ValidEventDate():
//    Given an event date, checks if it is close enough to the
//    date to be encoded. Due to a compact encoding format,
//    the EventDate must be within a few years of the Date.
//    Returns true if the event date is encodable.
bool
IndexEntry::ValidEventDate (dateT edate)
{
    uint eyear = date_GetYear (edate);
    uint dyear = date_GetYear (GetDate());
    if (eyear < (dyear - 3)  ||  eyear > (dyear + 3)) { return false; }
    return true;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// IndexEntry::Read():
//      Reads a single entrys values from an open index file.
//
errorT
IndexEntry::Read (MFile * fp, versionT version)
{
    ASSERT (fp != NULL);

    version = 0; // We dont have any other version-specific code.

    // Length of each gamefile record and its offset.
    Offset = fp->ReadFourBytes ();
    Length_Low = fp->ReadTwoBytes ();
    Length_High = fp->ReadOneByte();
    Flags = fp->ReadTwoBytes (); 

    // White and Black player names:
    WhiteBlack_High = fp->ReadOneByte ();
    WhiteID_Low = fp->ReadTwoBytes ();
    BlackID_Low = fp->ReadTwoBytes ();

    // Event, Site and Round names:
    EventSiteRnd_High = fp->ReadOneByte ();
    EventID_Low = fp->ReadTwoBytes ();
    SiteID_Low = fp->ReadTwoBytes ();
    RoundID_Low = fp->ReadTwoBytes ();

    VarCounts = fp->ReadTwoBytes();
    EcoCode = fp->ReadTwoBytes ();

    // Date and EventDate are stored in four bytes.
    Dates = fp->ReadFourBytes();

    // The two ELO ratings and rating types take 2 bytes each.
    WhiteElo = fp->ReadTwoBytes ();
    BlackElo = fp->ReadTwoBytes ();
    if (GetWhiteElo() > MAX_ELO) { SetWhiteElo(MAX_ELO); }
    if (GetBlackElo() > MAX_ELO) { SetBlackElo(MAX_ELO); }

    FinalMatSig = fp->ReadFourBytes ();
    NumHalfMoves = fp->ReadOneByte ();

    // Read the 9-byte homePawnData array:
    byte * pb = HomePawnData;
    // The first byte of HomePawnData has high bits of the NumHalfMoves
    // counter in its top two bits:
    uint pb0 = fp->ReadOneByte();
    *pb = (pb0 & 63);
    pb++;
    NumHalfMoves = NumHalfMoves | ((pb0 >> 6) << 8);
    for (uint i2 = 1; i2 < HPSIG_SIZE; i2++) {
        *pb = fp->ReadOneByte ();
        pb++;
    }

    // Top 2 bits of HomePawnData[0] are for NumHalfMoves:
    uint numMoves_High = HomePawnData[0];
    HomePawnData[0] = HomePawnData[0] & 63;
    numMoves_High >>= 6;
    numMoves_High <<= 8;
    NumHalfMoves = NumHalfMoves | numMoves_High;

    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// IndexEntry::Write():
//      Writes a single index entry to an open index file.
//      INDEX_ENTRY_SIZE must be updated
errorT
IndexEntry::Write (MFile * fp, versionT version)
{
    ASSERT (fp != NULL);

    // Cannot write old-version index files:
    if (version < 400) { return ERROR_FileVersion; }

    version = 0;  // We dont have any version-specific code.
    
    fp->WriteFourBytes (Offset);
    
    fp->WriteTwoBytes (Length_Low);
    fp->WriteOneByte (Length_High);
    fp->WriteTwoBytes (Flags);

    fp->WriteOneByte (WhiteBlack_High);
    fp->WriteTwoBytes (WhiteID_Low);
    fp->WriteTwoBytes (BlackID_Low);

    fp->WriteOneByte (EventSiteRnd_High);
    fp->WriteTwoBytes (EventID_Low);
    fp->WriteTwoBytes (SiteID_Low);
    fp->WriteTwoBytes (RoundID_Low);

    fp->WriteTwoBytes (VarCounts);
    fp->WriteTwoBytes (EcoCode);
    fp->WriteFourBytes (Dates);

    // Elo ratings and rating types: 2 bytes each.
    fp->WriteTwoBytes (WhiteElo);
    fp->WriteTwoBytes (BlackElo);

    fp->WriteFourBytes (FinalMatSig);
    fp->WriteOneByte (NumHalfMoves & 255); 

    // Write the 9-byte homePawnData array:
    byte * pb = HomePawnData;
    // The first byte of HomePawnData has high bits of the NumHalfMoves
    // counter in its top two bits:
    byte pb0 = *pb;
    pb0 = pb0 | ((NumHalfMoves >> 8) << 6);
    fp->WriteOneByte (pb0);
    pb++;
    // write 8 bytes
    for (uint i2 = 1; i2 < HPSIG_SIZE; i2++) {
        fp->WriteOneByte (*pb);
        pb++;
    }

    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// IndexEntry::CharToFlag():
//    Returns the flag number corresponding to the given character.
uint
IndexEntry::CharToFlag (char ch)
{
    uint flag = 0;
    switch (toupper(ch)) {
        case 'D': flag = IDX_FLAG_DELETE;     break;
        case 'W': flag = IDX_FLAG_WHITE_OP;   break;
        case 'B': flag = IDX_FLAG_BLACK_OP;   break;
        case 'M': flag = IDX_FLAG_MIDDLEGAME; break;
        case 'E': flag = IDX_FLAG_ENDGAME;    break;
        case 'N': flag = IDX_FLAG_NOVELTY;    break;
        case 'P': flag = IDX_FLAG_PAWN;       break;
        case 'T': flag = IDX_FLAG_TACTICS;    break;
        case 'K': flag = IDX_FLAG_KSIDE;      break;
        case 'Q': flag = IDX_FLAG_QSIDE;      break;
        case '!': flag = IDX_FLAG_BRILLIANCY; break;
        case '?': flag = IDX_FLAG_BLUNDER;    break;
        case 'U': flag = IDX_FLAG_USER;       break;
        case '1': flag = IDX_FLAG_CUSTOM1;    break;
        case '2': flag = IDX_FLAG_CUSTOM2;    break;
        case '3': flag = IDX_FLAG_CUSTOM3;    break;
        case '4': flag = IDX_FLAG_CUSTOM4;    break;
        case '5': flag = IDX_FLAG_CUSTOM5;    break;
        case '6': flag = IDX_FLAG_CUSTOM6;    break;
    }
    return flag;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// IndexEntry::SetFlagStr():
//    Sets user-settable flags by passing a string containing the
//    letters of each flag that should be set.
void
IndexEntry::SetFlagStr (const char * flags)
{
    // First, unset all user-settable flags:
    const char * uflags = "DWBMENPTKQ!?U123456";
    while (*uflags != 0) {
        SetFlag (1 << CharToFlag (*uflags), false);
        uflags++;
    }

    // Now set flags according to flags string:
    while (*flags != 0) {
        SetFlag (1 << CharToFlag(*flags), true);
        flags++;
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// IndexEntry::GetFlagStr():
//    Fills in the provided flag string with information on the
//    user-settable flags set for this game.
//    Returns the number of specified flags that are turned on.
uint
IndexEntry::GetFlagStr (char * str, const char * flags)
{
    if (flags == NULL) { flags = "DWBMENPTKQ!?U123456"; }
    uint count = 0;
    while (*flags != 0) {
        bool flag = false;
        flag = GetFlag (1 << CharToFlag (*flags));
        if (flag) { *str++ = *flags; count++; }
        flags++;
    }
    *str = 0;
    return count;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// IndexEntry::PrintGameInfo():
//
//      Prints the info for a single game to a string, according to the
//      format string provided. Called by by sc_game_list() in tkscid.cpp
//      and from scidt.cpp for its game listing (-l) option.
//
//      The format string indicates what information to print. Non-letters
//      in the string are printed as-is, while a letter (which should be
//      followed by a numeric width) indicates a particular type of data.
//      For example, "b12" indicates the Black player name in a width of 12.
//      Some data types ignore the width field, or only accept certain values.
//      Valid letter codes and their data:
//          b:  Black player name.
//          B:  Black Elo. Prints in width of 4, ignoring specified width.
//          e:  Event name.
//          f:  Game number, filtered (e.g. 1 = first game in filter).
//          g:  Game number, actual (ignoring filter).
//          m:  Number of moves. Prints "##" if width < 3 and numMoves > 99.
//          M:  Final position material, e.g. "r1:r" for Rook+Pawn vs Rook.
//          n:  Round name.
//          o:  ECO code.
//          r:  Result. Prints as 1 byte (1/0/=*) or as 3 bytes (1-0, etc).
//          s:  Site name.
//          S:  Start position flag. Prints "S" or " " (1 byte) ignoring width.
//          w:  White player name.
//          W:  White Elo. Prints in width of 4, ignoring specified width.
//          y:  Year. Prints in width of 4, ignoring specified width.
//
void
IndexEntry::PrintGameInfo (char * outStr,
                           gameNumberT gnFiltered, gameNumberT gnReal,
                           NameBase * nb, const char * format)
{
    ASSERT (outStr != NULL  &&  nb != NULL  &&  format != NULL);

    const char * s = format;
    char * out = outStr;
    *out = 0;
    char temp [256];

    while (*s) {
        if (!isalpha(*s)) {
            *out++ = *s++;
            *out = 0;
        } else {  // Saw a letter, so it is a field type:
            char c = *s++;
            int width = 0;
            // A width of "*" means variable width:
            if (*s == '*') {
                width = -1;
                s++;
            }
            while (*s >= '0' && *s <= '9') {
                width = width * 10 + (*s - '0');
                s++;
            }
            if (width == 0) { width = 1; }  // Minimum fixed width = 1.

            switch (c) {
            case 'f':   // Game number, filtered
                sprintf (temp, "%*d", width, gnFiltered);
                out = strAppend (out, temp);
                break;

            case 'g':   // Game Number
                sprintf (temp, "%*d", width, gnReal);
                out = strAppend (out, temp);
                break;

            case 'G':   // Game file offset
                sprintf (temp, "%*d", width, Offset);
                out = strAppend (out, temp);
                break;

            case 'L':   // Game file record length
              sprintf (temp, "%*d", width, GetLength() );
                out = strAppend (out, temp);
                break;

            case 'm':   // Move count
                {
                    uint m = (NumHalfMoves + 1) / 2;
                    if (width == 2  &&  m > 99) {
                        strCopy (temp, "##");
                    } else if (width == 1  &&  m > 9) {
                        strCopy (temp, "#");
                    } else {
                        sprintf (temp, "%*d", width, m);
                    }
                }
                out = strAppend (out, temp);
                break;

            case 'O':   // Opening moves
                out += strPad (out, StoredLine::GetText(GetStoredLineCode()),
                               width, ' ');
                break;

            case 'F':   // Final position material
                {
                    char *s = temp;
                    uint i, max;
                    max = MATSIG_Count_WQ (FinalMatSig);
                    for (i=0; i+1 < max; i += 2) { *s++ = 'Q'; }
                    for (; i < max; i++) { *s++ = 'q'; }
                    max = MATSIG_Count_WR (FinalMatSig);
                    for (i=0; i+1 < max; i += 2) { *s++ = 'R'; }
                    for (; i < max; i++) { *s++ = 'r'; }
                    max = MATSIG_Count_WB (FinalMatSig);
                    for (i=0; i+1 < max; i += 2) { *s++ = 'B'; }
                    for (; i < max; i++) { *s++ = 'b'; }
                    max = MATSIG_Count_WN (FinalMatSig);
                    for (i=0; i+1 < max; i += 2) { *s++ = 'N'; }
                    for (; i < max; i++) { *s++ = 'n'; }
                    max = MATSIG_Count_WP (FinalMatSig);
                    if (max > 0) { *s++ = (max + '0'); }
                    *s++ = ':';
                    max = MATSIG_Count_BQ (FinalMatSig);
                    for (i=0; i+1 < max; i += 2) { *s++ = 'Q'; }
                    for (; i < max; i++) { *s++ = 'q'; }
                    max = MATSIG_Count_BR (FinalMatSig);
                    for (i=0; i+1 < max; i += 2) { *s++ = 'R'; }
                    for (; i < max; i++) { *s++ = 'r'; }
                    max = MATSIG_Count_BB (FinalMatSig);
                    for (i=0; i+1 < max; i += 2) { *s++ = 'B'; }
                    for (; i < max; i++) { *s++ = 'b'; }
                    max = MATSIG_Count_BN (FinalMatSig);
                    for (i=0; i+1 < max; i += 2) { *s++ = 'N'; }
                    for (; i < max; i++) { *s++ = 'n'; }
                    max = MATSIG_Count_BP (FinalMatSig);
                    if (max > 0) { *s++ = (max + '0'); }
                    *s = 0;
                    out = strAppend (out, temp);
                }
                break;

            case 'r':   // Result
                if (width == 0) {    // do nothing
                } else if (width == 1) {
                    *out++ = RESULT_CHAR [GetResult()];
                } else {  // Assume a width of 3:
                    char * res = (char *) RESULT_STR [GetResult()];
                    sprintf (temp, "%-3s", res);
                    // Uncomment next line to convert "1-0" to "1:0", etc:
                    // if (temp[1] == '-') { temp[1] = ':'; }
                    out = strAppend (out, temp);
                }
                break;

            case 'y':   // Year
                sprintf (temp, "%4d", date_GetYear (GetDate()));
                out = strAppend (out, temp);
                break;

            case 'd':   // Date
                date_DecodeToString (GetDate(), temp);
                strTrimDate (temp);
                out += strPad (out, temp, width, ' ');
                break;

            case 'E':   // EventDate
                date_DecodeToString (GetEventDate(), temp);
                strTrimDate (temp);
                out += strPad (out, temp, width, ' ');
                break;

            case 'n':   // Round
                out += strPad (out, GetRoundName (nb), width, ' ');
                break;

            case 'w':   // White
                out += strPad (out, GetWhiteName (nb), width, ' ');
                break;

            case 'b':   // Black
                out += strPad (out, GetBlackName (nb), width, ' ');
                break;

            case 'W':   // White elo
                if (width < 0) {
                    if (WhiteElo == 0) {
                        eloT elo = nb->GetElo (GetWhite());
                        if (elo == 0) {
                            strCopy (temp, "     ");
                        } else {
                            sprintf (temp, "(%4d)", elo);
                        }
                    } else {
                        sprintf (temp, "%4d ", GetWhiteElo());
                    }
                } else {
                    sprintf (temp, "%4d", GetWhiteElo());
                }
                out = strAppend (out, temp);
                break;

            case 'B':   // Black elo
                if (width < 0) {
                    if (BlackElo == 0) {
                        eloT elo = nb->GetElo (GetBlack());
                        if (elo == 0) {
                            strCopy (temp, "     ");
                        } else {
                            sprintf (temp, "(%4d)", elo);
                        }
                    } else {
                        sprintf (temp, "%4d ", GetBlackElo());
                    }
                } else {
                    sprintf (temp, "%4d", GetBlackElo());
                }
                out = strAppend (out, temp);
                break;

            case 's':   // Site
                out += strPad (out, GetSiteName (nb), width, ' ');
                break;

            case 'e':   // Event
                out += strPad (out, GetEventName (nb), width, ' ');
                break;

            case 'c':   // Country
                {
                    const char * country = GetSiteName (nb);
                    uint len = strLength (country);
                    if (len > 3) { country = country + len - 3; }
                    out += strPad (out, country, width, ' ');
                }
                break;

            case 'o':   // ECO
                {
                    ecoStringT ecoStr;
                    eco_ToExtendedString (EcoCode, ecoStr);
                    out += strPad (out, ecoStr, width, ' ');
                    break;
                }

            case 'S':   // Start position is nonstandard:
                *out++ = (Flags & IDX_MASK_START) ? 'S' : ' ';
                break;

            case 'D':   // Game deleted flag
                *out++ = (Flags & IDX_MASK_DELETE) ? 'D' : ' ';
                break;

            case 'U':
            case 'M':   // Marked user-settable flags
                {
                    char flags [16];
                    char * s = flags;
                    GetFlagStr (s, NULL);
                    if (*s == 'D') { s++; }   // Skip Delete flag.
                    out += strPad (out, s, width, ' ');
                }
                break;

            case 'C':   // Comments count
                if (width == 1) {
                    *out++ = (GetCommentCount() > 0) ? 'C' : ' ';
                } else {
                    temp[0] = 0;
                    uint count = GetCommentCount();
                    if (count > 0) { sprintf (temp, "%2u", count); }
                    out = strAppend (out, temp);
                }
                break;

            case 'V':   // Variations count
                if (width == 1) {
                    *out++ = (GetVariationCount() > 0) ? 'V' : ' ';
                } else {
                    temp[0] = 0;
                    uint count = GetVariationCount();
                    if (count > 0) { sprintf (temp, "%2u", count); }
                    out = strAppend (out, temp);
                }
                break;

            case 'A':   // Annotation (NAG) count
                if (width == 1) {
                    *out++ = (GetNagCount() > 0) ? 'A' : ' ';
                } else {
                    temp[0] = 0;
                    uint count = GetNagCount();
                    if (count > 0) { sprintf (temp, "%2u", count); }
                    out = strAppend (out, temp);
                }
                break;

            case 'T':   // StoredLine code
                sprintf (temp, "%3d %s", GetStoredLineCode(),
                         StoredLine::GetText (GetStoredLineCode()));
                out = strAppend (out, temp);
                break;

            default: {}
                // Invalid letter (unknown field type), so ignore it.
            }
        }
    } // END: while (*s)
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// IndexEntry::Compare():
//      Compare two index entries according to sort criteria.
//      The parameter criteria is an array of integers denoting
//      sorting criteria (SORT_date, SORT_white, etc), terminated by
//      the value SORT_sentinel.
//
int
IndexEntry::Compare (IndexEntry * ie, int * fields, NameBase * nb)
{
    int res, rOne, rTwo;

    while (1) {
        switch (*fields) {
        case SORT_sentinel:  // End of sort criteria array reached.
            return 0;
            break;

        case SORT_date:
            res = (int)GetDate() - (int)ie->GetDate();
            break;

        case SORT_year:
            res = (int)GetYear() - (int)ie->GetYear();
            break;

        case SORT_eco:
            res = (int)EcoCode - (int)ie->EcoCode;
            break;

        case SORT_moveCount:
            res = (int)NumHalfMoves - (int)ie->NumHalfMoves;
            break;

        case SORT_white:
            res = strCompare (GetWhiteName (nb), ie->GetWhiteName (nb));
            break;

        case SORT_black:
            res = strCompare (GetBlackName (nb), ie->GetBlackName (nb));
            break;

        case SORT_event:
            res = strCompare (GetEventName (nb), ie->GetEventName (nb));
            break;

        case SORT_site:
            res = strCompare (GetSiteName (nb), ie->GetSiteName (nb));
            break;

        case SORT_round:
            res = strCompareRound (GetRoundName (nb), ie->GetRoundName (nb));
            break;

        case SORT_result:
            res = (int)GetResult() - (int)ie->GetResult();
            break;

        case SORT_avgElo:  // Average Elo rating:
            rOne = (WhiteElo + BlackElo) / 2;
            rTwo = (ie->WhiteElo + ie->BlackElo) / 2;
            res = rTwo - rOne;
            break;

        case SORT_country:  // Last 3 characters of site field:
            {
                const char * sOne = GetSiteName (nb);
                const char * sTwo = ie->GetSiteName (nb);
                uint slenOne = strLength (sOne);
                uint slenTwo = strLength (sTwo);
                if (slenOne > 3) { sOne += slenOne - 3; }
                if (slenTwo > 3) { sTwo += slenTwo - 3; }
                res = strCompare (sOne, sTwo);
            }
            break;

        case SORT_month:
            res = (int)GetMonth() - (int)ie->GetMonth();
            break;

        case SORT_deleted:
            res = (int)GetDeleteFlag() - (int)ie->GetDeleteFlag();
            break;

        case SORT_eventdate:
            {
                dateT d = GetEventDate();
                dateT d2 = ie->GetEventDate();
                if (d == ZERO_DATE) { d = GetDate(); }
                if (d2 == ZERO_DATE) { d2 = ie->GetDate(); }
                res = (int)d - (int)d2;
            }
            break;

        default:    // Should never happen:
            ASSERT(0);
            return 0;
        }

        if (res != 0) { return res; }
        fields++;
    }

    // Unreachable:
    ASSERT (0);
    return 0;
}



//////////////////////////////////////////////////////////////////////
//
//   Index Class Methods
//

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

// Index::Init(): Initialise the index.
//
void
Index::Init ()
{
    Fname[0] = 0;
    FilePtr = NULL;
    FilePos = 0;
    FileMode = FMODE_None;
    InMemory = false;
    Entries = NULL;
    EntriesHeap = NULL;
    ErrorMsg = NULL;
    strCopy (Header.magic, INDEX_MAGIC);
    Header.numGames  = 0;
    Header.version   = SCID_VERSION;
    Header.baseType = 0;
    Header.autoLoad = 2;
    Header.description[0] = 0;
    for (uint i=0; i<CUSTOM_FLAG_MAX; i++) {
      strcpy(Header.customFlagDesc[i], "");
    }
    CalcIndexEntrySize();
    for(uint i=0; i<SORTING_CACHE_MAX; i++)
        sortingCaches[i] = NULL;
    filter_changed_ = true;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Index::InitEntries():
//      Initialise an array of IndexEntry objects.
//
void
Index::InitEntries (IndexEntry * ie, uint count)
{
    while (count > 0) {
        ie->Init();
        count--;
        ie++;
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Index::FreeEntries(): frees all memory in Entries array.
//
void
Index::FreeEntries ()
{
    if (! InMemory) { return; }

    ASSERT (Entries != NULL);
    uint numChunks = 1 + (GetNumGames() >> INDEX_ENTRY_CHUNKSHIFT);
    for (uint i = 0; i < numChunks; i++) {
        ASSERT (Entries[i] != NULL);
        delete[] Entries[i];
    }
#ifdef WINCE
    my_Tcl_Free((char*)Entries);
#else
    delete[] Entries;
#endif
    Entries = NULL;
    InMemory = false;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Index::Clear(): clear the index of all games.
//
void
Index::Clear ()
{
    if (FilePtr != NULL)  { delete FilePtr; FilePtr = NULL; }
    FileMode = FMODE_Both;
    if (InMemory) { FreeEntries(); }
    Header.numGames  = 0;
    Header.baseType = 0;
    Header.version = SCID_VERSION;
    Header.autoLoad = 2;
    CalcIndexEntrySize();
    for(uint i=0; i<SORTING_CACHE_MAX; i++)
        if( sortingCaches[i]) {
            delete sortingCaches[i];
            sortingCaches[i] = NULL;
        }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Index::SetReadOnly():
//   Changes a read-writable opened index to be read-only.
errorT
Index::SetReadOnly ()
{
    ASSERT (FilePtr != NULL);
    if (FileMode != FMODE_Both) { return ERROR; }
    FileMode = FMODE_ReadOnly;
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Index::WriteHeader():
//      Write the header to the open index file.
//
errorT
Index::WriteHeader ()
{
    ASSERT (FilePtr != NULL);
    if (FilePos != 0  ||  FileMode == FMODE_Both) {
        FilePos = 0;
        FilePtr->Seek (0); // Get to the start of the file.
    }
    FilePtr->WriteNBytes (Header.magic, 8);
    FilePtr->WriteTwoBytes (Header.version);
    FilePtr->WriteFourBytes (Header.baseType);
    FilePtr->WriteThreeBytes (Header.numGames);
    FilePtr->WriteThreeBytes (Header.autoLoad);
    FilePtr->WriteNBytes (Header.description, SCID_DESC_LENGTH + 1);
    for (uint i = 0 ; i < CUSTOM_FLAG_MAX ; i++ ) {
      FilePtr->WriteNBytes (Header.customFlagDesc[i], CUSTOM_FLAG_DESC_LENGTH + 1);
    }
    FilePos = INDEX_HEADER_SIZE;
    if (FileMode == FMODE_Both) { FilePtr->Flush(); }
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Index::Open():
//      Open an index file and read the header.
//
errorT
Index::Open (fileModeT fmode, bool old)
{
    // Should not already have an open file;  must have a filename set.
    ASSERT (FilePtr == NULL  &&  Fname[0] != 0);

    fileNameT fname;
    strCopy (fname, Fname);
    strAppend (fname, old ? OLD_INDEX_SUFFIX : INDEX_SUFFIX);
    FileMode = fmode;
    FilePtr = new MFile;

    if (FilePtr->Open (fname, fmode) != OK) {
        delete FilePtr;
        FilePtr = NULL;
        return ERROR_FileOpen;
    }

    FilePtr->ReadNBytes (Header.magic, 8);
    if (strCompare (Header.magic, INDEX_MAGIC) != 0) {
        delete FilePtr;
        FilePtr = NULL;
        return ERROR_BadMagic;
    }

    Header.version = FilePtr->ReadTwoBytes ();
    Header.baseType = FilePtr->ReadFourBytes ();
    Header.numGames = FilePtr->ReadThreeBytes ();
    Header.autoLoad = FilePtr->ReadThreeBytes ();
    FilePtr->ReadNBytes (Header.description, SCID_DESC_LENGTH + 1);
    for (uint i = 0 ; i < CUSTOM_FLAG_MAX ; i++ ) {
      FilePtr->ReadNBytes (Header.customFlagDesc[i], CUSTOM_FLAG_DESC_LENGTH + 1);
    }
    FilePos = INDEX_HEADER_SIZE;
    Dirty = 0;

    // Check that the version of the file is valid: it must be
    // SCID_OLDEST_VERSION or higher, but not higher than the
    // current Scid version number.
    errorT result = OK;
    if (!old) {
        if (Header.version > SCID_VERSION) { result = ERROR_OldScidVersion; }
        if (Header.version < SCID_OLDEST_VERSION) { 
            result = ERROR_FileVersion; 
        }
        if (result != OK) {
            delete FilePtr;
            FilePtr = NULL;
        }
    }

    CalcIndexEntrySize();

    return result;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Index::CreateIndexFile():
//      Creates and opens a new empty index file.
//
errorT
Index::CreateIndexFile (fileModeT fmode)
{
    // Should not already have an open file;  must have a filename set.
    ASSERT (FilePtr == NULL  &&  Fname[0] != 0);
    Clear();

    fileNameT fname;
    strCopy (fname, Fname);
    strAppend (fname, INDEX_SUFFIX);
    FileMode = fmode;
    FilePtr = new MFile;
    if (FilePtr->Create (fname, fmode) != OK) {
        delete FilePtr;
        FilePtr = NULL;
        return ERROR_FileOpen;
    }
    FilePos = 0;
    Dirty = 1;
    return OK;
}

errorT
Index::CreateMemoryOnly ()
{
    ASSERT (FilePtr == NULL);
    Clear();
    FileMode = FMODE_Both;
    FilePtr = new MFile;
    FilePos = 0;
    Dirty = 1;
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Index::CloseIndexFile():
//      Writes the header and closes an index file.
//      If param NoHeader is true then don't write it (in case the index was copied
//      during a migration for example).
//
errorT
Index::CloseIndexFile ( bool NoHeader )
{
    ASSERT (FilePtr != NULL);   // check FilePtr points to an open file

    for(uint i=0; i<SORTING_CACHE_MAX; i++) {
        if( sortingCaches[i]) {
            delete sortingCaches[i];
            sortingCaches[i] = NULL;
        }
    }

    if (Dirty  &&  FileMode != FMODE_ReadOnly && !NoHeader) {
        WriteHeader();
    }
    if (InMemory) { FreeEntries(); }

    if (EntriesHeap != NULL) {
        delete[] EntriesHeap;
        EntriesHeap = NULL;
    }

    delete FilePtr;
    FilePtr = NULL;
    return OK;
}


// NUM_EXTRA_ENTRIES: extra space in in-memory index for efficiency to
//      avoid reallocating the array when a game is added.
#define NUM_EXTRA_ENTRIES 10


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Index::ReadEntireFile():
//      Reads in the entire index into memory.
//
errorT
Index::ReadEntireFile (void (*progressFn)(void * data,
                                          uint progress,
                                          uint total),
                       void * progressData)
{
    ASSERT (FilePtr != NULL);
    if (InMemory) return OK;
    if (FileMode == FMODE_WriteOnly) { return ERROR_FileMode; }
    errorT err;
    ASSERT (Entries == NULL);
    uint numChunks = NumChunksRequired();
    Entries = new IndexEntryPtr [numChunks];
    uint readCount = 0;
    for (uint chunkCount = 0; chunkCount < numChunks; chunkCount++) {
        if (progressFn && chunkCount % 50 == 0) (*progressFn) (progressData, chunkCount, numChunks);

        Entries[chunkCount] = new IndexEntry [INDEX_ENTRY_CHUNKSIZE];

        uint gamesToRead = GetNumGames() - readCount;
        if (gamesToRead > INDEX_ENTRY_CHUNKSIZE) {
            gamesToRead = INDEX_ENTRY_CHUNKSIZE;
        }
        err = ReadEntries (Entries[chunkCount], readCount, gamesToRead);
        if (err != OK) {
            for (uint i = 0; i <= chunkCount; i++) {
                delete[] Entries[i];
            }
            delete[] Entries;

            Entries = NULL;
            InMemory = false;
            return err;
        }
        readCount += gamesToRead;
    }
    if (progressFn) (*progressFn) (progressData, 1, 1);
    InMemory = true;
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Index::VerifyFile():
//      If the index is all in memory, this checks each entry for
//      possible corrupt values.
//      Returns the number of games found with a corrupt value.
//
uint
Index::VerifyFile (NameBase * nb)
{
    ASSERT (FilePtr != NULL);
    if (!InMemory) { return OK; }
    ASSERT (Entries != NULL);
    uint count = 0;

    for (uint i=0; i < Header.numGames; i++) {
        IndexEntry * ie = FetchEntry (i);
        if (ie->Verify(nb) != OK) {
            count++;
        }
    }
    return count;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Index::ReadEntries():
//      Reads some index records from an open index file.
//
errorT
Index::ReadEntries (IndexEntry * ie, gameNumberT start, uint count)
{
    ASSERT (FilePtr != NULL
            &&  (start + count) <= Header.numGames);

    if (FileMode == FMODE_WriteOnly) { return ERROR_FileMode; }

    uint fpos = IndexEntrySize * start + INDEX_HEADER_SIZE;
    if (!InMemory) { // We may need to seek:
        if (FilePos != fpos) {
            FilePtr->Seek (fpos);
            FilePos = fpos;
        }
    }

    for (uint i=start; i < start + count; i++) {
        if (InMemory) {
            // It is already in memory, so fetch the entry:
            ASSERT (Entries != NULL);
            IndexEntry * ieTemp = FetchEntry(i);
            // Copy the entry to the provided array:
            *ie = *ieTemp;
            ie++;
            continue;
        }
        ie->Read (FilePtr, Header.version);
        ie++;
        FilePos += IndexEntrySize;
    }
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Index::WriteEntries():
//      Writes some index records to an open index file.
//
errorT
Index::WriteEntries (IndexEntry * ie, uint start, uint count)
{
    // Must have an open file;
    // start must be at most one more than current # games.
    ASSERT (FilePtr != NULL  &&  start <= Header.numGames);

    if (FileMode == FMODE_ReadOnly) { return ERROR_FileMode; }

    // Is the number of games increasing? If so, update the Header.
    if (start + count > Header.numGames) {
        Header.numGames = start + count;
    }

    uint fpos = IndexEntrySize * start + INDEX_HEADER_SIZE;
    if (FileMode == FMODE_Both  ||  FilePos != fpos) {
       FilePos = fpos;
       FilePtr->Seek (fpos);
    }
    for (uint i=start; i < start + count; i++) {
        // Is File in memory? If so, update the Cached entry as well!

        if (InMemory) {
            // Copy to the cached entry array:
            ASSERT (Entries != NULL);
            IndexEntry * ieTemp = FetchEntry (i);
            *ieTemp = *ie;
        }

        ie->Write (FilePtr, Header.version);
        ie++;
        FilePos += IndexEntrySize;
    }
    if (FileMode == FMODE_Both) { FilePtr->Flush(); }
    Dirty = 1;
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Index::SetDescription():
//      Sets the database description string.
//
void
Index::SetDescription (const char * str)
{
    ASSERT (str != NULL);
    uint i;
    const char *s = str;

    // First erase the old description:

    for (i = 0; i < SCID_DESC_LENGTH; i++) {
        Header.description[i] = 0;
    }

    for (i = 0; (i < SCID_DESC_LENGTH) && (*s != 0); i++) {
        Header.description[i] = *s;
        // Stop at the first newline character in the string, if any:
        if (*s == '\n') { break; }
        s++;
    }
    Header.description[i] = 0;
    Dirty = 1;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Index::AddGame():
//      Adds a new Game to this index if possible.
//      if initIE is false, don't reset index, as it has already been reseted before
//      and eventually filled by encoding
errorT
Index::AddGame (gameNumberT * g, IndexEntry * ie, bool initIE)
{
    // Have we reached the maximum number of games?
    if (Header.numGames >= MAX_GAMES) {  return ERROR_IndexFull; }

    uint oldNumChunks = NumChunksRequired();
    *g = Header.numGames;
    Header.numGames++;

    if (initIE)
      ie->Init();

    if (InMemory) {
        uint newNumChunks = NumChunksRequired();
        if (oldNumChunks != newNumChunks) {
            //printf ("Increasing to %u chunks\n", newNumChunks);
            ASSERT (oldNumChunks + 1 == newNumChunks);
            // We need to enlarge the in-memory array:
            IndexEntryPtr * newEntries = new IndexEntryPtr [newNumChunks];
            for (uint i=0; i < oldNumChunks; i++) {
                newEntries[i] = Entries[i];
            }
            newEntries[oldNumChunks] = new IndexEntry [INDEX_ENTRY_CHUNKSIZE];
            if (Entries != NULL) delete[] Entries;
            Entries = newEntries;
        }
        IndexEntry * ieTemp = FetchEntry (*g);
        ieTemp->Init();
    }

    // Invalidate the EntriesHeap array of sorted entry indexes:
    if (EntriesHeap != NULL) {
        delete[] EntriesHeap;
        EntriesHeap = NULL;
    }

    Dirty = 1;
    return OK;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  Index sorting routines:
//  We sort the array of pointers to IndexEntries, which is kept
//  as an implicit heap, with valid pointers in positions 1 to N.
//  Note that entry 0 of the heap is unused.
//  Since the heap occupies positions 1 .. N of an array,
//  x's parent is  (x/2), and x's children are (2x) and (2x)+1.

static inline int
heapParent (int hnode)
{
    return hnode >> 1;
}

static inline int
heapNthParent (int hnode, int levels)
{
    return hnode >> levels;
}

static inline int
heapLeftChild (int hnode)
{
    return hnode << 1;
}

static inline int
heapRightChild (int hnode)
{
    return (hnode << 1) + 1;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Index::Sort_AdjustHeap():
//      Rearranges the Heap so that the entry at root is sifted down
//      to an appropriate location, leaving a correctly formed Heap.
//      Note that we do a "bottom-up" Heapsort which does fewer
//      comparisons than Heapsort implementations with traditional
//      sift-down heap adjustments.
//      We traverse down the heap finding the path of largest children,
//      and then backtrack back up the Heap towards the root to find
//      the place on this path where the old root will be moved to.
//
void
Index::Sort_AdjustHeap (int heapSize, int root, NameBase * nb)
{
    uint oldRoot = EntriesHeap[root];
    int current;
    int level;  // A level value of 0 represents the root level.

    // Traverse the path of largest children:
    // At each step, current points to the left child of the current
    // node being considered.

    current = heapLeftChild (root);
    level = 1;
    while (current < heapSize) {
        if (FetchEntry(EntriesHeap[current])->Compare (
              FetchEntry(EntriesHeap[current + 1]),
              SortCriteria, nb) < 0) {
            // Right child is in the largest-children path:
            current = heapLeftChild (current+1);
        } else {
            // Left child is in the largest-childern path:
            current = heapLeftChild (current);
        }
        level++;
    }
    if (current > heapSize) {
        current = heapParent (current);
        level--;
    }

    // Current is now the leaf node on the special path of larger children.
    // Next, search up though the path for the place to insert the old
    // root:

    while (root < current  &&
           FetchEntry(oldRoot)->Compare (FetchEntry (EntriesHeap[current]),
                             SortCriteria, nb) > 0) {
        current = heapParent (current);
        level--;
    }

    // Insert the root node at the correct location by shifting each
    // node on the special path from current up, towards the root:

     for (int parentLevel = level-1; parentLevel >= 0; parentLevel--) {
        EntriesHeap [heapNthParent (current, parentLevel+1)] =
            EntriesHeap [heapNthParent (current, parentLevel)];
    }

    EntriesHeap [current] = oldRoot;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
errorT
Index::Sort (NameBase * nb, int reportFrequency,
             void (*progressFn)(void * data, uint progress, uint total),
             void * progressData)
{
    // The index file must be all in memory to be sorted:
    if (InMemory == false  ||  Entries == NULL) {
        return ERROR;
    }

    uint count;
    uint heapSize = Header.numGames;

    // Allocate and initialise the array of pointers to IndexEntries:

    if (EntriesHeap != NULL) {
#ifdef WINCE
            my_Tcl_Free((char*) EntriesHeap);
#else
            delete[] EntriesHeap;
#endif
    }
#ifdef WINCE
    EntriesHeap = (uint*)my_Tcl_Alloc(sizeof(new uint [heapSize + 1]));
#else
    EntriesHeap = new uint [heapSize + 1];
#endif

    for (count=0; count < heapSize; count++) {
        EntriesHeap [count+1] = count;
    }

    // Phase 1 (fast, linear time):
    // Construct the initial Heap:

    for (count = heapSize / 2; count >= 1; count--) {
        Sort_AdjustHeap (heapSize, count, nb);
    }

    // Phase 2 (slower, O (n log n) time):
    // Extract each largest value in turn, swapping it with the final
    // element in the heap and adjusting to reform a proper heap:

    int reportAfter = reportFrequency;
    uint progressCounter = 0;

    for (count = heapSize; count > 1; count--) {
        uint temp = EntriesHeap [1];
        EntriesHeap [1] = EntriesHeap [count];
        EntriesHeap [count] = temp;
        Sort_AdjustHeap (count - 1, 1, nb);

        // Report progress back to the caller, if requested:
        progressCounter++;
        reportAfter--;
        if (reportAfter == 0) {
            if (progressFn != NULL) {
                (*progressFn) (progressData, progressCounter, heapSize);
            }
            reportAfter = reportFrequency;
        }
    }
    if (progressFn != NULL) {
        (*progressFn) (progressData, 1, 1);
    }

    // Now EntriesHeap[] contains the index for the sorted order.
    // Entries[] is not actually changed, so the results of the
    // sort are lost unless a subsequent call to Index::WriteSorted()
    // is done to write the entire sorted index back to disk.

    // Do a full verification that every index entry is in the sorted
    // list somewhere, if we are doing assertions:
    ASSERT (VerifySort() == OK);

    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Index::VerifySort():
//    Checks that every game number (from 0 to Header.numGames - 1)
//    occurs somewhere in the EntriesHeap[] sorted array.
//    If not, there is a fatal error in our sorting algorithm!
errorT
Index::VerifySort (void)
{
    ASSERT (EntriesHeap != NULL);
#ifdef WINCE
    bool * found = (bool *) my_Tcl_Alloc(sizeof(bool [Header.numGames]));
#else
    bool * found = new bool [Header.numGames];
#endif

    uint count;

    for (count=0; count < Header.numGames; count++) {
        found[count] = false;
    }
    for (count = 1; count <= Header.numGames; count++) {
        found[EntriesHeap[count]] = true;
    }
    for (count=0; count < Header.numGames; count++) {
        if (! found[count]) {
            fprintf (stderr, "FATAL ERROR in sorting algorithm: ");
            fprintf (stderr, "Game %u was not in sorted array!\n", count+1);
#ifdef WINCE
            my_Tcl_Free((char*) found);
#else
            delete[] found;
#endif

            return ERROR_Corrupt;
        }
    }
#ifdef WINCE
            my_Tcl_Free((char*) found);
#else
            delete[] found;
#endif
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Index::WriteSorted();
//      Writes the entire index back to disk, in the order produced
//      by an earlier call to Index::Sort().
errorT
Index::WriteSorted (int reportFrequency,
                    void (*progressFn)(void * data,
                                       uint progress,
                                       uint total),
                    void * progressData)
{
    // If EntriesHeap is NULL, no sort has been performed yet:

    if (EntriesHeap == NULL) { return ERROR; }

    ASSERT (InMemory  &&  Entries != NULL);

    // We need to do an in-place permutation to reorder the entries,
    // without requiring excessive temporary space.
    // The in-place permutation comes from D. Knuth, "The Art of
    // Computer Programming, Vol 3: Sorting and Searching, 1998 edition,
    // pages 616--617. Note that it modifies EntriesHeap[], which is
    // fine since we will not need it afterwards anyway.

    uint * order = &(EntriesHeap[1]);
    uint count;

    for (count=0; count < Header.numGames; count++) {
        if (order[count] == count) {
            // This entry is already in its proper place.
            continue;
        }
        IndexEntry ieTemp = *(FetchEntry(count));
        uint j = count;
        bool done = false;
        while (! done) {
            uint k = order[j];
            *(FetchEntry(j)) = *(FetchEntry(k));
            order[j] = j;
            j = k;
            if (order[j] == count) { done = true; }
        }
        *(FetchEntry(j)) = ieTemp;
        order[j] = j;
    }

    // Now the index is in the correct order. Write it to the
    // disk if necessary:

    if (FileMode != FMODE_ReadOnly) {

        uint fpos = 0;
        if (FileMode == FMODE_Both  ||  FilePos != fpos) {
            FilePos = fpos;
            FilePtr->Seek (fpos);
        }
        WriteHeader();

        IndexEntry * ie;
        int reportAfter = reportFrequency;
        for (uint count=1; count <= Header.numGames; count++) {
            ie = FetchEntry(EntriesHeap[count]);
            ie->Write (FilePtr, Header.version);
            FilePos += IndexEntrySize;
            reportAfter--;
            if (reportAfter <= 0) {
                if (progressFn != NULL) {
                    (*progressFn) (progressData, count, GetNumGames());
                }
                reportAfter = reportFrequency;
            }
        }
        if (FileMode == FMODE_Both) { FilePtr->Flush(); }
    }
    if (progressFn != NULL) {
        (*progressFn) (progressData, 1, 1);
    }
    Dirty = 1;
#ifdef WINCE
            my_Tcl_Free((char*) EntriesHeap);
#else
            delete[] EntriesHeap;
#endif

    EntriesHeap = NULL;
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Index::ParseSortCriteria():
//      Parses a list of names into a corresponding array of
//      integers denoting sorting criteria.
//      Used for parsing sort criteria, e.g.:
//      "-Sdate,event,white" --> { SORT_date, SORT_event, SORT_white }
//      The final element is set to SORT_sentinel.
//
//      If an error occurs, ERROR is returned and ErrorMsg is set to
//      an appropriate error message.
//
errorT
Index::ParseSortCriteria (const char * inputStr)
{
    // Code to extract sorting criteria from a comma (or dot) separated
    // list:

    const char * s = inputStr;
    char name [256];
    uint length = 0;
    uint criListLen = 0;

    while (1) {
        // Parse the criteria name list:

        if (isalpha (*s)) {  // Add this letter to the name:
            name [length] = tolower (*s);
            length++;
            if (length >= 255) {
                SortCriteria[0] = SORT_sentinel;
#ifdef WINCE
                if (ErrorMsg) { my_Tcl_Free( ErrorMsg); }
#else
                if (ErrorMsg) { delete[] ErrorMsg; }
#endif
                ErrorMsg = strDuplicate ("Error: sort field too long!");
                return ERROR;
            }

        } else if (*s == ','  ||  *s == '.'  ||  *s == ' '  || *s == 0) {

            // Try to add this criteria name to the list:

            if (length > 0) {
                if (criListLen >= (INDEX_MaxSortCriteria - 1)) {
                    SortCriteria[0] = SORT_sentinel;
#ifdef WINCE
                    if (ErrorMsg != NULL) { my_Tcl_Free( ErrorMsg ); }
#else
                    if (ErrorMsg != NULL) { delete[] ErrorMsg; }
#endif

                    ErrorMsg = strDuplicate (
                        "Error: Too many fields in sort criteria!");
                    return ERROR_Full;
                }
                name [length] = 0;
                name[0] = toupper (name[0]);
                int index = strUniqueMatch (name, sortCriteriaNames);
                if (index == -1) {
                    // Invalid criteria name:
                    SortCriteria[0] = SORT_sentinel;
#ifdef WINCE
                    if (ErrorMsg != NULL) { my_Tcl_Free( ErrorMsg); }
                    ErrorMsg = my_Tcl_Alloc(sizeof( char [512]));
#else
                    if (ErrorMsg != NULL) { delete[] ErrorMsg; }
                    ErrorMsg = new char [512];
#endif
                    sprintf (ErrorMsg, "Error: invalid sort field: %s", name);
                    return ERROR;
                }
                SortCriteria [criListLen] = index;
                criListLen++;
                length = 0;
            }
            // Stop when end of list is seen:

            if (*s == 0) { break; }

        } else {  // Invalid character in list:
            SortCriteria[0] = SORT_sentinel;

#ifdef WINCE
                    if (ErrorMsg != NULL) { my_Tcl_Free( ErrorMsg); }
                    ErrorMsg = my_Tcl_Alloc(sizeof( char [80]));
#else
            if (ErrorMsg != NULL) { delete[] ErrorMsg; }
            ErrorMsg = new char [80];
#endif

            sprintf (ErrorMsg,
                     "Error: invalid character in sort field list: \"%c\"",
                     *s);
            return ERROR;
        }
        s++;
    }

    SortCriteria [criListLen] = SORT_sentinel;
    return OK;
}


//Interface to SortCache
SortCache* Index::CreateSortingCache (NameBase *nbase, const char *criteria)
{
	// If there is another client using a matching cache, use that one
	for(uint i=0; i < SORTING_CACHE_MAX; i++) {
		if (sortingCaches[i] == NULL) continue;
		if (sortingCaches[i]->MatchCriteria(criteria) ) {
			sortingCaches[i]->AddCount();
			return sortingCaches[i];
		}
	}

	for (uint idx =0; idx < SORTING_CACHE_MAX; idx++) {
		if (sortingCaches[idx] == NULL) {
			sortingCaches[idx] = SortCache::Create (this, nbase, criteria);
			return sortingCaches[idx];
		}
	}
	return 0;
}

// Search and free a matching cache
void Index::FreeCache(const char* criteria)
{
	for (uint i=0; i < SORTING_CACHE_MAX; ++i) {
	    if (sortingCaches[i] != NULL && sortingCaches[i]->MatchCriteria(criteria)) {
			if (0 == sortingCaches[i]->ReleaseCount()) {
				delete sortingCaches[i];
				sortingCaches[i] = NULL;
				break;
			}
		}
	}
}

errorT Index::GetRange (NameBase *nbase, const char *criteria, uint idx, uint count, Filter *filter, uint *result)
{
	ASSERT(result != 0);
	ASSERT(criteria != 0 && strlen(criteria) > 1);
	if (criteria[0] == 'N') {
		uint i=0;
		if (criteria[1] == '+') {
			for(uint gnum=0; gnum < GetNumGames() && i < count; gnum++) {
				if (filter && filter->Get(gnum) == 0) continue;
				if (idx == 0) result[i++] = gnum;
				else idx--;
			}
		} else {
			for(uint gnum=GetNumGames(); gnum > 0 && i < count; gnum--) {
				if (filter && filter->Get(gnum -1) == 0) continue;
				if (idx == 0) result[i++] = gnum -1;
				else idx--;
			}
		}
		if (i != count) result[i] = IDX_NOT_FOUND;
		return OK;
	}

	// Use existing caches if possible
	for(uint i=0; i < SORTING_CACHE_MAX; i++) {
		if (sortingCaches[i] == NULL) continue;
		if (sortingCaches[i]->MatchCriteria(criteria) ) {
			sortingCaches[i]->GetRange(idx, count, filter, result);
			return OK;
		}
	}

	SortCache* sc = SortCache::Create (this, nbase, criteria, false);
	sc->GetRange(idx, count, filter, result);
	delete sc;
	return OK;
}

uint Index::GetRangeLocation (NameBase *nbase, const char *criteria, Filter *filter, uint gnumber)
{
	for(uint i=0; i < SORTING_CACHE_MAX; i++) {
		if (sortingCaches[i] == NULL) continue;
		if (sortingCaches[i]->MatchCriteria(criteria) ) {
			return sortingCaches[i]->IndexToFilteredCount (gnumber, filter);
		}
	}

	SortCache* sc = SortCache::Create (this, nbase, criteria, false);
	uint r = sc->IndexToFilteredCount (gnumber, filter);
	delete sc;
	return r;
}

uint Index::GetRangeLocation (NameBase *nbase, const char *criteria, Filter *filter,
                              const char* text, uint start, bool forward)
{
	uint i = 0;
	for(; i < SORTING_CACHE_MAX; i++) {
		if (sortingCaches[i] == NULL) continue;
		if (sortingCaches[i]->MatchCriteria(criteria) ) break;
	}
	SortCache* sc = 0;
	if (i != SORTING_CACHE_MAX) sc = sortingCaches[i];
	else sc = SortCache::Create (this, nbase, criteria, false);

	uint res = start;
	uint result [100] = {0};
	for (;;) {
		if (!forward) { //TODO: Speed up this search, maybe using std::vector.rbegin()
			if (res == 0) break;
			else res--;
			sc->GetRange(res, 1, filter, result);
			IndexEntry * ie = FetchEntry (result[0]);
			if ((strAlphaContains (ie->GetWhiteName (nbase), text))  ||
			    (strAlphaContains (ie->GetBlackName (nbase), text))  ||
			    (strAlphaContains (ie->GetEventName (nbase), text))  ||
			    (strAlphaContains (ie->GetSiteName (nbase), text))) {
				++res;
				break;
			}
		} else {
			sc->GetRange(res, 100, filter, result);
			bool stop = false;
			for (int j =0; j < 100; ++j, ++res) {
				if (result[j] == IDX_NOT_FOUND) {
					res = 0;
					stop = true;
					break;
				}
				IndexEntry * ie = FetchEntry (result[j]);
				if ((strAlphaContains (ie->GetWhiteName (nbase), text))  ||
				    (strAlphaContains (ie->GetBlackName (nbase), text))  ||
				    (strAlphaContains (ie->GetEventName (nbase), text))  ||
				    (strAlphaContains (ie->GetSiteName (nbase), text))) {
					stop = true;
					++res;
					break;
				}
			}
			if (stop) break;
		}
	}

	if (i == SORTING_CACHE_MAX) delete sc;
	return res;
}

errorT Index::IndexUpdated( uint gnum)
{
	for(uint i=0; i<SORTING_CACHE_MAX; i++)
		if( sortingCaches[i] != NULL)
			sortingCaches[i]->CheckForChanges(gnum);
	return OK;
}

//////////////////////////////////////////////////////////////////////
//  EOF: index.cpp
//////////////////////////////////////////////////////////////////////

