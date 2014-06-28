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

#ifndef WINCE

#include "spellchk.h"
#include "namebase.h"
#include "date.h"
#include "mfile.h"
#include <ctype.h>

inline uint
spellHash (const char * str)
{
    uint hash = (byte) *str;
    if (*str == 0) { return hash; }
    str++;
    hash = (hash << 8 | hash) + (byte)*str;
    if (*str == 0) { return hash; }
    str++;
    hash = (hash << 8 | hash) + (byte)*str;
    if (*str == 0) { return hash; }
    str++;
    hash = (hash << 8 | hash) + (byte)*str;
    return hash;
}


void
SpellChecker::Init (void)
{
    ExcludeChars = strDuplicate ("");
    StrAlloc = new StrAllocator;
    EloDataSeen = false;
    CorrectNameCount = 0;
    IncorrectNameCount = 0;
    for (uint i=0; i < 256; i++) { Names[i] = NULL; }
    for (uint h=0; h < SPELL_HASH_SIZE; h++) { HashNames[h] = NULL; }
    Prefixes = NULL;
    Suffixes = NULL;
    Infixes = NULL;
}

void
SpellChecker::Clear (void)
{
    Destroy();
    Init();
}

void
SpellChecker::Destroy (void)
{
#ifdef WINCE
    my_Tcl_Free( ExcludeChars );
#else
    delete[] ExcludeChars;
#endif
    delete StrAlloc;
    StrAlloc = NULL;
    for (uint i=0; i < 256; i++) {
        spellCheckNodeT * node = Names[i];
        while (node != NULL) {
            spellCheckNodeT * next = node->next;
            if (node->eloData != NULL) {
#ifdef WINCE
                my_Tcl_Free((char*) node->eloData);
            }
            if (node->renderName != NULL) { my_Tcl_Free((char*) node->renderName); }
#else
                delete[] node->eloData;
            }
            if (node->renderName != NULL) { delete[] node->renderName; }
#endif
            while (node->bioData != NULL) {
                bioNoteT * next = node->bioData->next;
#ifdef WINCE
                my_Tcl_Free((char*)  node->bioData->text);
                my_Tcl_Free((char*) node->bioData);
#else
                delete[] node->bioData->text;
                delete[] node->bioData;
#endif

                node->bioData = next;
            }
#ifdef WINCE
                my_Tcl_Free((char*)  node);
#else
            delete node;
#endif
            node = next;
        }
    }
    while (Prefixes != NULL) {
        presuffixNodeT * next = Prefixes->next;
#ifdef WINCE
        my_Tcl_Free((char*)  Prefixes->name);
        my_Tcl_Free((char*)  Prefixes->correctName);
        my_Tcl_Free((char*)  Prefixes);
#else
        delete[] Prefixes->name;
        delete[] Prefixes->correctName;
        delete Prefixes;
#endif
        Prefixes = next;
    }
    while (Suffixes != NULL) {
        presuffixNodeT * next = Suffixes->next;
#ifdef WINCE
        my_Tcl_Free((char*)  Suffixes->name);
        my_Tcl_Free((char*)  Suffixes->correctName);
        my_Tcl_Free((char*)  Suffixes);
#else
        delete[] Suffixes->name;
        delete[] Suffixes->correctName;
        delete Suffixes;
#endif
        Suffixes = next;
    }
    while (Infixes != NULL) {
        presuffixNodeT * next = Infixes->next;
#ifdef WINCE
        my_Tcl_Free((char*) Infixes->name);
        my_Tcl_Free((char*)  Infixes->correctName);
        my_Tcl_Free((char*)  Infixes);
#else
        delete[] Infixes->name;
        delete[] Infixes->correctName;
        delete Infixes;
#endif
        Infixes = next;
    }
}

void
SpellChecker::SetExcludeChars (const char * str)
{
#ifdef WINCE
    my_Tcl_Free((char*) ExcludeChars);
#else
    delete[] ExcludeChars;
#endif
    ExcludeChars = strDuplicate (str);
}

void
SpellChecker::SetRenderName (spellCheckNodeT * node, const char * name)
{
    ASSERT (node != NULL  &&  name != NULL);
    // Skip over any initial spaces:
    while (*name == ' ') { name++; }
#ifdef WINCE
    if (node->renderName != NULL) { my_Tcl_Free((char*) node->renderName); }
#else
    if (node->renderName != NULL) { delete[] node->renderName; }
#endif
    node->renderName = strDuplicate (name);
}

const char *
SpellChecker::RenderName (const char * name) {
    char searchName [512];
    strCopyExclude (searchName, name, ExcludeChars);
    spellCheckNodeT * node = Names[(byte) *searchName];

    while (node != NULL) {
        if (strEqual (name, node->correctName)) {
            if (node->renderName != NULL) { return node->renderName; }
            break;
        }
        node = node->next;
    }

    // Render spelling not found, so just return the original name:
    return name;
}


// This data has been imported from spelling.ssp comment fields by S.A.
// use: grep '^#   [[:upper:]][[:upper:]][[:upper:]]  ' spelling.ssp

spellingT titleTable[] = {
{"gm","Grandmaster"},
{"im","International Master"},
{"fm","FIDE Master"},
{"wgm","Woman Grandmaster"},
{"wim","Woman International Master"},
{"wfm","Woman FIDE Master"},
{"cgm","Correspondence GM"},
{"cim","Correspondence IM"},
{"hgm","Honorary Grandmaster"},
{"comp","Computer"},
{"",""}
};

spellingT countryTable[] = {
{"AHO","Netherlands Antilles"},
{"AND","Andorra"},
{"ARG","Argentina"},
{"ARM","Armenia"},
{"AUS","Australia"},
{"AUT","Austria"},
{"AZE","Azerbaijan"},
{"BAN","Bangladesh"},
{"BAR","Barbados"},
{"BEL","Belgium"},
{"BER","Bermuda"},
{"BIH","Bosnia & Herzogovina"},
{"BLR","Belarus"},
{"BOL","Bolivia"},
{"BRA","Brazil"},
{"BUL","Bulgaria"},
{"CAN","Canada"},
{"CHI","Chile"},
{"CHN","China"},
{"COL","Columbia"},
{"CRC","Costa Rica"},
{"CRO","Croatia"},
{"CUB","Cuba"},
{"CZE","Czechoslovakia"},
{"DEN","Denmark"},
{"DOM","Dominican Republic"},
{"ECU","Ecuador"},
{"EGY","Egypt"},
{"ENG","England"},
{"ESA","El Salvador"},
{"ESP","Spain"},
{"EST","Estonia"},
{"FAI","Faroe Islands"},
{"FIN","Finland"},
{"FRA","France"},
{"GCI","Guernsey"},
{"GEO","Georgia"},
{"GER","Germany"},
{"GRE","Greece"},
{"GRL","Greenland"},
{"GUA","Guatemala"},
{"HUN","Hungary"},
{"HKG","Hong Kong"},
{"INA","Indonesia"},
{"IND","India"},
{"INT","Internet"},
{"IOM","Isle of Man"},
{"IRI","Iran"},
{"IRL","Ireland"},
{"IRQ","Iraq"},
{"ISL","Iceland"},
{"ISR","Israel"},
{"ITA","Italy"},
{"JAM","Jamaica"},
{"JCI","Jersey"},
{"JPN","Japan"},
{"KAZ","Kazakhstan"},
{"KGZ","Kyrgyzstan"},
{"LAT","Latvia"},
{"LIB","Lebanon"},
{"LIE","Liechtenstein"},
{"LTU","Lithuania"},
{"LUX","Luxembourg"},
{"MAR","Morocco"},
{"MAS","Malaysia"},
{"MDA","Moldova"},
{"MEX","Mexico"},
{"MGL","Mongolia"},
{"MKD","Macedonia"},
{"MLT","Malta"},
{"MNC","Monaco"},
{"MYA","Myanmar"},
{"NCA","Nicaragua"},
{"NCL","New Caledonia"},
{"NED","Netherlands"},
{"NGR","Nigeria"},
{"NOR","Norway"},
{"NZL","New Zealand"},
{"PAN","Panama"},
{"PAR","Paraguay"},
{"PER","Peru"},
{"PHI","Philippines"},
{"PNG","Papua New Guinea"},
{"POL","Poland"},
{"POR","Portugal"},
{"PUR","Puerto Rico"},
{"QAT","Qatar"},
{"ROM","Romania"},
{"RSA","South Africa"},
{"RUS","Russia"},
{"SCG","Serbia & Montenegro"},
{"SCO","Scotland"},
{"SIN","Singapore"},
{"SLO","Slovenia"},
{"SUI","Switzerland"},
{"SVK","Slovakia"},
{"SWE","Sweden"},
{"SYR","Syria"},
{"TJK","Tajikistan"},
{"TKM","Turkmenistan"},
{"TUN","Tunisia"},
{"TUR","Turkey"},
{"UAE","United Arab Emirates"},
{"UKR","Ukraine"},
{"URU","Uruguay"},
{"USA","United States of America"},
{"UZB","Uzbekistan"},
{"VEN","Venezuela"},
{"VIE","Vietnam"},
{"WLS","Wales"},
{"YEM","Yemen"},
{"SCG","Yugoslavia - most are now SCG (Serbia and Montenegro)"},
{"FIJ","Fiji"},
{"YUG","Yugoslavia"},
{"",""}
};

const char *
SpellChecker::GetComment (const char * name)
{
    const char * returnStr = NULL;
    char searchName [1024];
    strCopyExclude (searchName, name, ExcludeChars);
    spellCheckNodeT * node = Names[(byte) *searchName];
    while (node != NULL) {
        if (strIsPrefix (searchName, node->name)) {
            returnStr = node->comment;
        }
        // If the match is exact, return immediately:
        if (strEqual (searchName, node->name)) { break; }
        node = node->next;
    }
    return returnStr;
}

const char *
SpellChecker::GetCommentExact (const char * name)
{
    uint hash = spellHash(name) % SPELL_HASH_SIZE;
    spellCheckNodeT * node = HashNames[hash];
    while (node != NULL) {
        if (strEqual (name, node->correctName)) { return node->comment; }
        node = node->nextHash;
    }
    return NULL;
}

const char *
SpellChecker::CorrectPrefix (const char * name, int * offset)
{
    int len = strLength (name);
    presuffixNodeT * node = Prefixes;
    while (node != NULL) {
        if (len >= node->length) {
            if (strIsPrefix (node->name, name)) {
                *offset = node->length;
                return node->correctName;
            }
        }
        node = node->next;
    }
    return NULL;
}

const char *
SpellChecker::CorrectSuffix (const char * name, int * offset)
{
    int len = strLength (name);
    presuffixNodeT * node = Suffixes;
    while (node != NULL) {
        int preLength = len - node->length;
        if (preLength >= 0) {
            const char * s = &(name[preLength]);
            if (strEqual (s, node->name)) {
                *offset = preLength;
                return node->correctName;
            }
        }
        node = node->next;
    }
    return NULL;
}

const char *
SpellChecker::CorrectInfix (const char * name, int * offset, int * replacedLength)
{
    presuffixNodeT * node = Infixes;
    while (node != NULL) {
        int index = strContainsIndex (name, node->name);
        if (index >= 0) {
            *offset = index;
            *replacedLength = strLength (node->name);
            return node->correctName;
        }
        node = node->next;
    }
    return NULL;
}

const char *
SpellChecker::Correct (const char * name)
{
    const char * returnStr = NULL;
    char searchName [1024];
    strCopyExclude (searchName, name, ExcludeChars);
    spellCheckNodeT * node = Names[(byte) *searchName];
    while (node != NULL) {
        if (strIsPrefix (searchName, node->name)) {
            // Found a correction:
            returnStr = node->correctName;
            // If the correction is exact, return immediately:
            if (strEqual (searchName, node->name)) { break; }
        }
        node = node->next;
    }
    return returnStr;
}

uint
SpellChecker::Corrections (const char * name, const char ** corrections,
                           uint maxCorrections)
{
    ASSERT (maxCorrections > 0);
    char searchName [1024];
    const char * prevCorrection = "";
    uint correctionCount = 0;
    strCopyExclude (searchName, name, ExcludeChars);
    spellCheckNodeT * node = Names[(byte) *searchName];
    while (node != NULL) {
        if (strIsPrefix (searchName, node->name)) {
            // Found a correction:
            if (! strEqual (prevCorrection, node->correctName)) {
                if (correctionCount < maxCorrections) {
                    corrections[correctionCount] = node->correctName;
                    correctionCount++;
                }
                prevCorrection = node->correctName;
            }
            // If the correction is exact, return *only* this correction:
            if (strEqual (searchName, node->name)) {
                corrections[0] = node->correctName;
                return 1;
            }
        }
        node = node->next;
    }
    return correctionCount;
}

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

    // Strip leading spaces and trailling newline, tab and space chars:
    s = line;
    s = (char *) strTrimLeft(s);
    strTrimRight (s);
    strTrimRight (*comment);
    *name = s;
}

errorT
SpellChecker::ReadSpellCheckFile (const char * filename, bool checkPlayerOrder)
{
    char line [1024];
    char strippedName [1024];
    spellCheckNodeT * lastCorrectNode = NULL;
    char * prevCorrectName = NULL;
    char * lastCorrectName = NULL;
    char * lastRenderName = NULL;
    char * lastComment = NULL;
    nameT nameType = NAME_INVALID;

    MFile fp;
    if (fp.Open (filename, FMODE_ReadOnly) != OK) { return ERROR_FileOpen; }

    while (1) {
        fp.ReadLine (line, 1024);
        if (fp.EndOfFile()) { break; }

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
            if (lastCorrectNode != NULL  &&  strIsPrefix ("%Elo ", name)) {
                EloDataSeen = true;
                AddEloData (lastCorrectNode, name);
            }
            if (lastCorrectNode != NULL  &&  strIsPrefix ("%Bio ", name)) {
                AddBioData (lastCorrectNode, name+5);
            }
            if (lastCorrectNode != NULL  &&  strIsPrefix ("%Render ", name)) {
                SetRenderName (lastCorrectNode, name+8);
            }
            // Prefix or Suffix correction:
            if (nameType == NameType) {
                if (strIsPrefix ("%Prefix ", name)) { AddPrefixSuffix (name); }
                if (strIsPrefix ("%Suffix ", name)) { AddPrefixSuffix (name); }
                if (strIsPrefix ("%Infix ", name))  { AddPrefixSuffix (name); }
            }
        } else if (*name == '@') {
            // Name type line: "@PLAYER", "@SITE", "@EVENT" or "@ROUND"
            // Hmmm... maybe add a COUNTRY parsing round S.A &&&
            nameType = NameBase::NameTypeFromString (name+1);
            if (! NameBase::IsValidNameType(NameType)) {
                return ERROR_Corrupt;
            }
            if (nameType == NameType) {
                // Now check if there is a list of characters to exclude from
                // comparisons, e.g:   @PLAYER ", .-"
                // would indicate to exclude dots, commas, spaces and dashes.
                char * start = strchr (name, '"');
                if (start != NULL) {
                    char * end = strchr (start + 1, '"');
                    if (end != NULL) {
                        *end = 0;
                        SetExcludeChars (start + 1);
                    } else {
                        return ERROR_Corrupt;
                    }
                }
            }
        } else if (*name == '='  &&  nameType == NameType) {
            // Incorrect spelling of name. Skip over "=" and spaces:
            name++;
            while (*name == ' ') { name++; }
            if (lastCorrectName != NULL) {
#ifdef WINCE
                spellCheckNodeT * node = (spellCheckNodeT *)my_Tcl_Alloc(sizeof( spellCheckNodeT));
#else
                spellCheckNodeT * node = new spellCheckNodeT;
#endif
                strCopyExclude (strippedName, name, ExcludeChars);
                node->name = StrAlloc->Duplicate (strippedName);
                node->correctName = lastCorrectName;
                node->comment = lastComment;
                node->correction = true;
                node->nextHash = NULL;
                node->eloData = NULL;
                node->bioData = NULL;
                node->renderName = lastRenderName;
                byte b = (byte) *strippedName;
                node->next = Names[b];
                node->alias = lastCorrectNode;
                Names[b] = node;
                IncorrectNameCount++;
            }
        } else if (nameType == NameType) {
            // Correctly spelt name; add to the list:
#ifdef WINCE
                spellCheckNodeT * node = (spellCheckNodeT *)my_Tcl_Alloc(sizeof( spellCheckNodeT));
#else
            spellCheckNodeT * node = new spellCheckNodeT;
#endif

            strCopyExclude (strippedName, name, ExcludeChars);
            node->correctName = StrAlloc->Duplicate (name);
            node->name = StrAlloc->Duplicate (strippedName);
            node->comment = StrAlloc->Duplicate (comment);
            node->renderName = NULL;
            node->correction = false;
            uint hash = spellHash(name) % SPELL_HASH_SIZE;
            node->nextHash = HashNames[hash];
            HashNames[hash] = node;
            prevCorrectName = lastCorrectName;
            lastCorrectName = node->correctName;
            lastRenderName = node->renderName;
            lastCorrectNode = node;
            lastComment = node->comment;
            node->eloData = NULL;
            node->bioData = NULL;
            byte b = (byte) *strippedName;
            node->next = Names[b];
            node->alias = NULL; // node ??
            Names[b] = node;
            CorrectNameCount++;

            // If requested, verify that player names are in correct order:
            if (NameType == NAME_PLAYER  &&  checkPlayerOrder  &&
                prevCorrectName != NULL  &&
                strCompare (prevCorrectName, lastCorrectName) > 0) {
                printf ("\"%s\" is out of place.\n", lastCorrectName);
            }
        }
    }
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// SpellChecker::AddPrefixSuffix:
//    Adds a general prefix or suffix correction given a spellcheck file
//    line in the form:
//    %Suffix "wrong suffix" "correct suffix"
errorT
SpellChecker::AddPrefixSuffix (char * str)
{
    char *q1, *q2, *q3, *q4;
    q1 = q2 = q3 = q4 = NULL;

    // Find first 4 quote characters:
    q1 = (char *) strFirstChar (str, '"');
    if (q1 == NULL) { return ERROR; }
    q1++;
    q2 = (char *) strFirstChar (q1 + 1, '"');
    if (q2 == NULL) { return ERROR; }
    q3 = (char *) strFirstChar (q2 + 1, '"');
    if (q3 == NULL) { return ERROR; }
    q3++;
    q4 = (char *) strFirstChar (q3 + 1, '"');
    if (q4 == NULL) { return ERROR; }
    *q2 = 0;
    *q4 = 0;
#ifdef WINCE
    presuffixNodeT * node = (presuffixNodeT *) my_Tcl_Alloc(sizeof( presuffixNodeT));
#else
    presuffixNodeT * node = new presuffixNodeT;
#endif
    if (strIsPrefix ("%Suffix", str)) {
        node->next = Suffixes;
        Suffixes = node;
    } else if (strIsPrefix ("%Prefix", str)) {
        node->next = Prefixes;
        Prefixes = node;
    } else if (strIsPrefix ("%Infix", str)) {
        node->next = Infixes;
        Infixes = node;
    } else {
        return ERROR;
    }
    node->name = strDuplicate (q1);
    node->length = strLength (q1);
    node->correctName = strDuplicate (q3);
    return OK;
}

void
SpellChecker::AddBioData (spellCheckNodeT * node, const char * str)
{
    ASSERT (node != NULL  &&  str != NULL);
#ifdef WINCE
    bioNoteT * note = (bioNoteT *) my_Tcl_Alloc(sizeof(bioNoteT));
#else
    bioNoteT * note = new bioNoteT;
#endif
    note->text = strDuplicate (str);
    note->next = NULL;
    if (node->bioData == NULL) {
        node->bioData = note;
        return;
    }

    bioNoteT * last = node->bioData;
    while (last->next != NULL) { last = last->next; }
    last->next = note;
}

const bioNoteT *
SpellChecker::GetBioData (const char * name)
{
    const bioNoteT * note = NULL;
    char searchName [1024];
    strCopyExclude (searchName, name, ExcludeChars);
    spellCheckNodeT * node = Names[(byte) *searchName];
    while (node != NULL) {
        if (strIsPrefix (searchName, node->name)) {
            note = node->bioData;
        }
        // If the match is exact, return immediately:
        if (strEqual (searchName, node->name)) { break; }
        node = node->next;
    }
    if (node && node->alias && node->alias->bioData)
        return node->alias->bioData;
    else
        return note;
}


static const uint ELO_YEAR_LAST  = 2015; // end of current ELO scheme, could be increased in case the rating period does not change
static const uint ELO_YEAR_FIRST = 1970;

static const uint ELO_YEAR_RANGE = ELO_YEAR_LAST + 1 - ELO_YEAR_FIRST;

static const uint ELO_RATINGS_PER_YEAR = 6;

static const uint ELO_ARRAY_SIZE = ELO_YEAR_RANGE * ELO_RATINGS_PER_YEAR;

// Half-year lists
static const uint ELO_MONTH_TO_SEMESTER[13] = {
    0,
    0, 0, 0, 0, 0, 0, // Jan - Jun
    1, 1, 1, 1, 1, 1  // Jul - Dec
};


// Start of years with quarterly lists
static const uint ELO_FIRST_QUARTERLY_YEAR = 2001;

// Quarterly lists
static const uint ELO_MONTH_TO_QUARTER[13] = {
    0,         // Unknown month
    0, 0, 0,   // Jan, Feb, Mar
    1, 1, 1,   // Apr, May, Jun
    2, 2, 2,   // Jul, Aug, Sep
    3, 3, 3    // Oct, Nov, Dec
};


// Year of 3 quarters and 2 bi-monthlies 
static const uint ELO_TRANSITIONAL_YEAR    = 2009;

// Transitional period
static const uint ELO_MONTH_TO_TRANSITIONAL[13] = {
    0,         // Unknown month
    0, 0, 0,   // Jan, Feb, Mar
    1, 1, 1,   // Apr, May, Jun
    2, 2,      // Jul, Aug
    3, 3,      // Sep, Oct
    4, 4       // Nov, Dec
};


// Start of years with bi-monthly lists
static const uint ELO_FIRST_BIMONTHLY_YEAR = 2010;

// Bi-monthly lists
static const uint ELO_MONTH_TO_BIMONTHLY[13] = {
    0,         // Unknown month
    0, 0,      // Jan, Feb
    1, 1,      // Mar, Apr
    2, 2,      // May, Jun
    3, 3,      // Jul, Aug
    4, 4,      // Sep, Oct
    5, 5       // Nov, Dec
};


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
void
SpellChecker::AddEloData (spellCheckNodeT * node, const char * str)
{
    ASSERT (node != NULL  &&  str != NULL);
    if (node->eloData == NULL) {
#ifdef WINCE
        node->eloData = (eloT*)my_Tcl_Alloc(sizeof( eloT [ELO_ARRAY_SIZE]));
#else
        node->eloData = new eloT [ELO_ARRAY_SIZE];
#endif
        for (uint i=0; i < ELO_ARRAY_SIZE; i++) {
            node->eloData[i] = 0;
        }
    }

    // Skip the %Elo prefix. TODO: Apparently it may or may not be there....
    //
    if (strIsPrefix ("%Elo ", str)) { str += 4; }
    
    
    while (1) {
        // Get the year in which the rating figures to follow were published
        //
        str = strTrimLeft (str);
        if (! isdigit (*str)) { break; }
        uint year = strGetUnsigned (str);
        str += 4;
        if (*str != ':') { break; }
        str++;

        // Now read all the ratings for this year:
        //
        uint yIndex = 0;
        uint elo = 0;
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

            SetElo (node, year, yIndex, elo);
            yIndex++;

            if (*str == ',') { str++; }
        }
    }
}



void
SpellChecker::SetElo (spellCheckNodeT * node,
                      uint year, uint yIndex, eloT elo)
{
    // Monitor array bounds
    //
    if ( year < ELO_YEAR_FIRST  ||  year > ELO_YEAR_LAST ) { return; }
    if ( yIndex >= ELO_RATINGS_PER_YEAR ) { return; }
    uint index = (year - ELO_YEAR_FIRST) * ELO_RATINGS_PER_YEAR;
    index += yIndex;
    ASSERT (index < ELO_ARRAY_SIZE);
    node->eloData[index] = elo;
}


// Find the rating for given player name applicable to given date
// Main purpose of the function is to map this date on the (assumed)
// release schedule of the ratings
//
// The release schedule hard-coded implemented here is the schedule
// that FIDE has applied over the years for the ELO rating.
//
eloT
SpellChecker::GetElo (const char * name, dateT date, bool exact)
{
    uint year = date_GetYear (date);
    uint month = date_GetMonth (date);
    
    // Month overflow protection. TODO: Should it be mapped to "no month" (zero)?
    if ( month > 12 ) { month = 1; }
    
    // Year overflow protection
    //
    if ( year < ELO_YEAR_FIRST  ||  year > ELO_YEAR_LAST ) { return 0; }

    // Now find the index for the given year
    // It depends on the year itself
    
    uint yIndex;
    if ( year >= ELO_FIRST_BIMONTHLY_YEAR ) {
        yIndex = ELO_MONTH_TO_BIMONTHLY[month];
    }
    else if ( year >= ELO_TRANSITIONAL_YEAR ) {
        yIndex = ELO_MONTH_TO_TRANSITIONAL[month];
    }
    else if ( year >= ELO_FIRST_QUARTERLY_YEAR ) {
        yIndex = ELO_MONTH_TO_QUARTER[month];
    }
    else {
        yIndex = ELO_MONTH_TO_SEMESTER[month];
    }
    
    uint index = (year - ELO_YEAR_FIRST) * ELO_RATINGS_PER_YEAR;
    uint indexStartOfYear = index;
    index += yIndex;
    ASSERT (index < ELO_ARRAY_SIZE);

    char searchName [512];
    strCopyExclude (searchName, name, ExcludeChars);
    spellCheckNodeT * node = Names[(byte) *searchName];

    while (node != NULL) {
        // If the match is exact, return Elo data:
        if (strEqual (name, node->correctName)) {
            eloT * eloArray = node->eloData;
            if (eloArray != NULL) {
                eloT elo = eloArray[index];
                if (elo == 0) { elo = eloArray[indexStartOfYear]; }
                if (elo == 0  &&  month == 0  &&  !exact) {
                    // The month was not known, so we may as well try all
                    // other quarters of this year to find a nonzero Elo:
                    for (uint i=1; i < ELO_RATINGS_PER_YEAR; i++) {
                        elo = eloArray[indexStartOfYear + i];
                        if (elo != 0) { break; }
                    }
                }
                return elo;
            }
        }
        node = node->next;
    }
    // If we reach here, no exact name match with Elo data was found:
    return 0;
}


void
SpellChecker::Dump (FILE * fp)
{
    for (uint i=0; i < 256; i++) {
        spellCheckNodeT * node = Names[i];
        while (node != NULL) {
            fprintf (fp, "%s: %s (%s)\n",
                     node->name, node->correctName, node->comment);
            node = node->next;
        }
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// SpellChecker::GetTitle:
//    Extract the first title appearing in the player
//    comment, and return it.
const char *
SpellChecker::GetTitle (const char * comment)
{
    static const char * titles[] = {
        "gm", "im", "fm",
        "wgm", "wim", "wfm", "w",
        "cgm", "cim", "hgm",
        NULL
    };
    const char ** titlePtr = titles;

    if (comment == NULL) { return ""; }

    while (*titlePtr != NULL) {
        if (strIsPrefix (*titlePtr, comment)) { return *titlePtr; }
        titlePtr++;
    }
    return "";
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// SpellChecker::GetLastCountry:
//    Scan the player comment string for the country field (which
//    is the second field, after the title), then return the
//    last three letters in the country field, or the empty string
//    if the country field is less than 3 characters long.
const char *
SpellChecker::GetLastCountry (const char * comment)
{
    static char country[4];
    country[0] = 0;

    if (comment == NULL) { return country; }

    const char * start = comment;
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
// SpellChecker::GetPeakRating:
//    Scan the player comment string for the peak rating
//    field (which is contained in brackets), convert it
//    to an unsigned integer, and return it.
eloT
SpellChecker::GetPeakRating (const char * comment)
{
    if (comment == NULL) { return 0; }
    const char * s = comment;
    while (*s != '['  &&  *s != 0) { s++; }
    if (*s != '[') { return 0; }
    s++;
    return strGetUnsigned (s);
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// SpellChecker::GetBirthdate:
//    Scan the player comment string for the birthdate
//    field, convert it to a date, and return it.
dateT
SpellChecker::GetBirthdate (const char * comment)
{
    if (comment == NULL) { return ZERO_DATE; }
    const char * s = comment;
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
// SpellChecker::GetDeathdate:
//    Scan the player comment string for the deathdate
//    field, convert it to a date, and return it.
dateT
SpellChecker::GetDeathdate (const char * comment)
{
    if (comment == NULL) { return ZERO_DATE; }
    const char * s = comment;
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

#endif
//////////////////////////////////////////////////////////////////////
//  EOF: spellchk.cpp
//////////////////////////////////////////////////////////////////////
