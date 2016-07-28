//////////////////////////////////////////////////////////////////////
//
//  FILE:       pgnparse.cpp
//              PgnParser class methods
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    3.5
//
//  Notice:     Copyright (c) 2001-2003  Shane Hudson.  All rights reserved.
//              Copyright (C) 2015 Fulvio Benini
//
//////////////////////////////////////////////////////////////////////


#include "pgnparse.h"
#include "game.h"
#include <stdio.h>

#if defined(_MSC_VER) && _MSC_VER <= 1800
    #define snprintf _snprintf
#endif


const uint MAX_COMMENT_SIZE = 16000;

// ADDCHAR() macro: Adds one character to a buffer and increments the
//     buffer pointer.
//
#define ADDCHAR(buf,ch)  *(buf) = (ch); (buf)++; *(buf) = 0

/**
 * charIsSpace() - Checks whether @c is a white-space character.
 *
 * Return false for non-breaking spaces (ASCII-160 or A0 hex) because
 * they can be part of a multi-byte utf-8 character.
 */
bool charIsSpace (unsigned char c) {
    return (c == ' '    ||
            c == '\t'   ||
            c == '\n'   ||
            c == '\v'   ||
            c == '\f'   ||
            c == '\r');
}

/**
 * pgnLatin1_to_utf8() - convert a char to utf-8 enconding
 * @c: pointer to a null terminated string
 *
 * The PGN standard use a subset of ISO 8859/1 (Latin 1):
 * Code value from 0 to 126 are the standard ASCII character set
 * Code value from 127 to 191 are not used for PGN data representation.
 * Code value from 192 to 255 are mostly alphabetic printing characters with
 * various diacritical marks; their use is encouraged for those languages
 * that require such characters.
 */
std::string pgnLatin1_to_utf8 (const char* c) {
    std::string res;
    res = *c;
    uint8_t v = *c;
    if (v >= 192) {
        // Because @c is required to be a null terminated string, it is safe
        // to access the next char (if @c is the last char, next will be 0)
        uint8_t next = *(c+1);
        if ((next >> 6) != 0x02) {
            //Not a valid utf-8 sequence
            //Assume it's Latin1 and convert it to utf-8
            res = static_cast<uint8_t>(0xC3);
            res += static_cast<uint8_t>(v & 0xBF);
        }
    }
    return res;
}


errorT CodecPgn::open(const char* filename) {
    errorT res = file_.Open(filename, FMODE_ReadOnly);
    if (res == OK) {
        parser_.Reset(&file_);
        fileSize_ = fileSize (filename, "");
        if (fileSize_ < 1) { fileSize_ = 1; }
        parser_.IgnorePreGameText();
    }
    return res;
}


void
PgnParser::Reset()
{
    UnGetCount = 0;
    NumErrors = 0;
    BytesSeen = 0;
    LineCounter = 0;
    GameCounter = 0;
    StorePreGameText = true;
    EndOfInputWarnings = true;
    ResultWarnings = true;
    NumIgnoredTags = 0;
}

void
PgnParser::Reset (MFile * infile)
{
    Reset();
    InFile = infile;
    InBuffer = InCurrent = NULL;
    EndChar = EOF;
}

void
PgnParser::Init (const char * inbuffer)
{
    Reset();
    InFile = NULL;
    InBuffer = InCurrent = inbuffer;
    EndChar = 0;
}

void
PgnParser::Reset (const char * inbuffer)
{
    Reset();
    InFile = NULL;
    InBuffer = InCurrent = inbuffer;
    EndChar = 0;
}

int
PgnParser::GetChar ()
{
    int ch = 0;
    BytesSeen++;
    if (UnGetCount > 0) {
        UnGetCount--;
        ch = UnGetCh[UnGetCount];
    } else if (InFile != NULL) {
        ch =  InFile->ReadOneByte();
    } else {
        ch = *InCurrent;
        if (ch != 0) { InCurrent++; }
    }
    if (ch == '\n') { LineCounter++; }
    return ch;
}

void
PgnParser::UnGetChar (int ch)
{
    if (UnGetCount == MAX_UNGETCHARS) { return; }
    UnGetCh[UnGetCount] = ch;
    UnGetCount++;
    BytesSeen--;
    if (ch == '\n') { LineCounter--; }
}

void
PgnParser::AddIgnoredTag (const char * tag)
{
    if (NumIgnoredTags >= MAX_IGNORED_TAGS) { return; }
    if (tag == NULL  ||  tag[0] == 0) { return; }
    IgnoredTags [NumIgnoredTags] = strDuplicate (tag);
    NumIgnoredTags++;
}

void
PgnParser::ClearIgnoredTags ()
{
    for (uint i = 0; i < NumIgnoredTags; i++) {
        delete[] IgnoredTags[i];
    }
    NumIgnoredTags = 0;
}

bool
PgnParser::IsIgnoredTag (const char * tag)
{
    for (uint i = 0; i < NumIgnoredTags; i++) {
        if (strEqual (tag, IgnoredTags[i])) { return true; }
    }
    return false;
}

void
PgnParser::LogError (const char * errMessage, const char * text)
{
    NumErrors++;
    ErrorBuffer += "(game " + to_string(GameCounter);
    ErrorBuffer += ", line " + to_string(LineCounter) + ") ";
    ErrorBuffer += errMessage;
    ErrorBuffer += text;;
    ErrorBuffer += "\n";
}

void
PgnParser::GetLine (char * buffer, uint bufSize)
{
    ASSERT (bufSize > 0);
    while (true) {
        int ch = GetChar();
        if (ch == EndChar  ||  ch == 10) {
            break;
        }
        if (ch == 13) {
            // Handle ascii-13 followed by ascii-10 as a single newline:
            ch = GetChar();
            if (ch != 10) {
                UnGetChar (ch);
            }
            break;
        }
        bufSize--;
        if (bufSize == 0) {
            break;
        }
        *buffer++ = ch;
    }
    *buffer = 0;
    return;
}



// If STANDARD_PLAYER_NAMES is defined, then player names are
// processed with a simple algorithm before adding to the name base,
// to reduce multiple instances of the same player. First, the
// number of spaces after a comma is made consistent (the default
// is one space; see NUM_SPACES_AFTER_COMMA). Second, a dot (".") at
// the END of the name string is removed.

#define STANDARD_PLAYER_NAMES


// NUM_SPACES_AFTER_COMMA: number of spaces to follow every comma in
// a player name, when standardising. Commom values are 0 and 1.

#define NUM_SPACES_AFTER_COMMA 1

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// standardDutchName(): standardises various combinations of upper
//       and lower case "v" and "d" in the common Dutch name
//       prefixes "van der", "van de" and "van den" to a capital
//       V and small d, for consistency to avoid multiple names.
//
static void
standardDutchName (char * s)
{
    if (*s != 'v'  &&  *s != 'V') { return; }
    if (strIsPrefix ("van ", s)) { s[0] = 'V'; }
    if (strIsPrefix ("Van Der ", s) ||
        strIsPrefix ("Van Den ", s) ||
        strIsPrefix ("Van De ", s))
    {
        s[4] = 'd';
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// standardPlayerName(): standardises player names to reduce the number
//      of different names referring to the same player. Algorithm:
//      (1) The number of spaces after a comma is standardised, to
//          NUM_SPACES_AFTER_COMMA spaces.
//      (2) Spaces and dots are removed from the END of the name.
//      So "Anand,V" "Anand, V" and "Anand, V." would all become "Anand, V"
//
static void
standardPlayerName (char * source)
{
    char tempName [1024];
    strCopy (tempName, source);
    char * from = tempName;
    char * to = source;
    int afterComma = 0;
    bool startSpaces = true;

    while (*from) {
        if (*from == ',') {
            *to++ = ',';
            afterComma = 1;
            startSpaces = false;
        } else if (*from == ' ') {
            if (!afterComma  &&  !startSpaces) {
                // Not after a ',' or at start of name, so add the space:
                *to++ = ' ';
            }
        } else { // any other character:
            startSpaces = false;
            if (afterComma) {
                // First, insert spaces after the comma:
                uint x = NUM_SPACES_AFTER_COMMA;
                while (x > 0) { *to++ = ' '; x--; }
            }
            *to = *from;
            to++;
            afterComma = 0;
        }
        from++;
    }
    *to = 0;

    // Now trim any trailing spaces, tabs :
    strTrimRight (source, " \t");

    // Now standardise the capital letters of Dutch/etc prefix names:
    standardDutchName(source);
    return;
}

errorT
PgnParser::ExtractPgnTag (const char * buffer, Game * game)
{
    const uint maxTagLength = 255;
    char tag [255];
    char value [255];

    // Skip any initial whitespace:
    while (charIsSpace(*buffer)  &&  *buffer != 0) { buffer++; }
    // Skip the '[' character and any whitespace:
    ASSERT (*buffer == '[');
    buffer++;
    while (charIsSpace(*buffer) && *buffer != 0) { buffer++; }

    // Now at the start of the tag name:
    uint length = 0;
    while (!charIsSpace(*buffer)  &&  *buffer != 0) {
        tag[length] = *buffer++;
        length++;
        if (length == maxTagLength) { return ERROR_PGNTag; }
    }
    if (*buffer == 0) { return ERROR_PGNTag; }
    tag[length] = 0;

    // Find the start of the tag value:
    while (*buffer != '"'  &&  *buffer != 0) { buffer++; }
    if (*buffer != '"') { return ERROR_PGNTag; }
    buffer++;
    // Find the end of the tag value: it is the last double-quote (")
    // on this line.
    length = 0;
    uint lastQuoteIndex = 0;
    bool seenEndQuote = false;
    while (*buffer != 0) {
        if (*buffer == '"') {
            lastQuoteIndex = length;
            seenEndQuote = true;
        }
        value[length] = *buffer;
        buffer++;
        length++;
        if (length == maxTagLength) { return ERROR_PGNTag; }
    }
    if (! seenEndQuote) { return ERROR_PGNTag; }
    value[lastQuoteIndex] = 0;

    std::string tmpUft8;
    for (const char* i = value; i != value + lastQuoteIndex; i++) {
        tmpUft8 += pgnLatin1_to_utf8(i);
    }
    std::copy(tmpUft8.c_str(), tmpUft8.c_str() + tmpUft8.length() + 1, value);

    // Now decide what to add to the game based on this tag:
    if (strEqual (tag, "White")) {
#ifdef STANDARD_PLAYER_NAMES
        standardPlayerName (value);
#endif
        // Check for a rating in parentheses at the end of the player name:
        uint len = strLength (value);
        if (len > 7  &&  value[len-1] == ')'
            &&  isdigit(static_cast<unsigned char>(value[len-2]))
            &&  isdigit(static_cast<unsigned char>(value[len-3]))
            &&  isdigit(static_cast<unsigned char>(value[len-4]))
            &&  isdigit(static_cast<unsigned char>(value[len-5]))
            &&  value[len-6] == '('  &&  value[len-7] == ' ') {
            uint elo = strGetUnsigned (&(value[len-5]));
            if (elo <= MAX_ELO) {
                value[len - 7] = 0;
                game->SetWhiteElo(elo);
                game->SetWhiteRatingType(RATING_Elo);
            }
        }
        game->SetWhiteStr (value);

    } else if (strEqual (tag, "Black")) {
#ifdef STANDARD_PLAYER_NAMES
        standardPlayerName (value);
#endif
        // Check for a rating in parentheses at the end of the player name:
        uint len = strLength (value);
        if (len > 7  &&  value[len-1] == ')'
            &&  isdigit(static_cast<unsigned char>(value[len-2]))
            &&  isdigit(static_cast<unsigned char>(value[len-3]))
            &&  isdigit(static_cast<unsigned char>(value[len-4]))
            &&  isdigit(static_cast<unsigned char>(value[len-5]))
            &&  value[len-6] == '('  &&  value[len-7] == ' ') {
            uint elo = strGetUnsigned (&(value[len-5]));
            if (elo <= MAX_ELO) {
                value[len - 7] = 0;
                game->SetBlackElo(elo);
                game->SetBlackRatingType(RATING_Elo);
            }
        }
        game->SetBlackStr (value);

    } else if (strEqual (tag, "Event")) {
        game->SetEventStr (value);

    } else if (strEqual (tag, "Site")) {
        game->SetSiteStr (value);

    } else if (strEqual (tag, "Round")) {
        game->SetRoundStr (value);

    } else if (strEqual (tag, "Result")) {
        if (strIsPrefix ("0-1", value)) {
            game->SetResult (RESULT_Black);
        } else if (strIsPrefix ("1-0", value)) {
                game->SetResult (RESULT_White);
        } else if (strIsPrefix ("1/2", value)) {
                game->SetResult (RESULT_Draw);
        } else {
            game->SetResult (RESULT_None);
        }

    } else if (strEqual (tag, "Date")) {
        game->SetDate (date_EncodeFromString (value));

    } else if (strEqual (tag, "EventDate")) {
        game->SetEventDate (date_EncodeFromString (value));

    } else if (strEqual (tag, "ECO")) {
        game->SetEco (eco_FromString (value));

    } else if (strEqual (tag, "ScidFlags")) {
        game->SetScidFlags (value);

    } else if (strEqual (tag, "FEN")) {
        if (game->SetStartFen (value) != OK) {
            LogError ("Error: Invalid FEN: ", value);
            return ERROR_InvalidFEN;
        }

    } else {
        // Look for Rating Types: only the first Rating type found for
        // each player is added as the rating. Any extra ratings are
        // just added as normal tags.

        bool isRatingType = false;

        if (strIsPrefix ("White", tag)  &&  game->GetWhiteElo() == 0) {
            char * tagSuffix = tag + 5;
            uint i = 0;
            while (ratingTypeNames[i] != NULL) {
                if (strEqual (tagSuffix, ratingTypeNames[i])) {
                    uint elo = strGetUnsigned (value);
                    if (elo > MAX_ELO) {
                        LogError ("Warning: rating too large: ", value);
                        elo = MAX_ELO;
                    }
                    game->SetWhiteElo (elo);
                    game->SetWhiteRatingType (i);
                    isRatingType = true;
                    break;
                }
                i++;
            }
        }
        if (strIsPrefix ("Black", tag)  &&  game->GetBlackElo() == 0) {
            char * tagSuffix = tag + 5;
            uint i = 0;
            while (ratingTypeNames[i] != NULL) {
                if (strEqual (tagSuffix, ratingTypeNames[i])) {
                    uint elo = strGetUnsigned (value);
                    if (elo > MAX_ELO) {
                        LogError ("Warning: rating too large: ", value);
                        elo = MAX_ELO;
                    }
                    game->SetBlackElo (elo);
                    game->SetBlackRatingType (i);
                    isRatingType = true;
                    break;
                }
                i++;
            }
        }

        if (! isRatingType  &&  ! IsIgnoredTag (tag)) {
            game->AddPgnTag (tag, value);
        }
    }
    return OK;
}

bool
PgnParser::EndOfInput()
{
    if (InFile != NULL) { return InFile->EndOfFile(); }
    int ch = GetChar();
    if (ch == EndChar) { return true; }
    UnGetChar (ch);
    return false;
}

// Modifies the parameter string in-place, trimming all
// whitespace at the start and end of the string, and reducing
// all other sequences of whitespace to a single space.
//
// Example: "\t\n   A  \t\n   B   C  "  (where \t and \n are tabs
// and newlines) becomes "A B C".
std::string PgnParser::GetComment()
{
    std::string res;

    int ch = GetChar();
    for (; ch != EndChar  &&  ch != '}'; ch = GetChar()) {
        if (charIsSpace(ch)) {
            if (res.length() == 0) continue;
            if (*(res.rbegin()) == ' ') continue;
            ch = ' ';
        }
        res += ch;
    }
    if (res.length() != 0 && *(res.rbegin()) == ' ') {
        res.resize(res.length() -1);
    }

    if (ch == EndChar) {
        char tempStr[80];
        sprintf (tempStr, "started on line %u\n", LineCounter);
        LogError ("Error: Open Comment at end of input", tempStr);
    }

    return res;
}

void
PgnParser::GetRestOfSuffix (char * buffer, char firstChar)
{
    if (firstChar == '!'  ||  firstChar == '?') {
        int ch = GetChar();
        // Only get successive ! or ? characters, so a complex
        // annotation like "!!+-" can be parsed as two separate
        // entities, "!!" and "+-":
        while (ch == '!'  ||  ch == '?') {
            *buffer++ = ch;
            ch = GetChar();
        }
        UnGetChar (ch);
        *buffer = 0;
    } else {
        // Some other Suffix like "+/-" so just get rest of word:
        GetRestOfWord_NoDots (buffer);
    }
}

void
PgnParser::GetRestOfWord_NoDots (char * buffer)
{
    int ch = GetChar();
    while (!charIsSpace (ch) && ch != '.' && ch != ')' && ch != EndChar) {
        *buffer++ = ch;
        ch = GetChar();
    }
    UnGetChar (ch);
    *buffer = 0;
}

void
PgnParser::GetRestOfWord_WithDots (char * buffer)
{
    int ch = GetChar();
    while (!charIsSpace (ch)  &&  ch != ')'  &&  ch != EndChar) {
        *buffer++ = ch;
        ch = GetChar();
    }
    UnGetChar (ch);
    *buffer = 0;
}

void
PgnParser::GetRestOfWord_Letters (char * buffer)
{
    int ch = GetChar();
    while (isalpha(ch)) {
        *buffer++ = ch;
        ch = GetChar();
    }
    UnGetChar (ch);
    *buffer = 0;
}

tokenT
PgnParser::GetRestOfCastling (char * buffer)
{
    int ch;
    int numOhsSeen = 1;
    while (true) {
        ch = GetChar();
        if (ch == 'O'  ||  ch == 'o'  ||  ch == '0') {
            numOhsSeen++;
            ADDCHAR (buffer, ch);
            continue;
        }
        if (ch == '-') {
            // Check for "-+" or "-/+" after the move:
            int nextCh = GetChar();
            UnGetChar (nextCh);
            if (nextCh == '+'  ||  nextCh == '/') {
                // Seen "-+" or "-/+", e.g. "O-O-+"
                UnGetChar (ch);
                break;
            }
            ADDCHAR (buffer, ch);
            continue;
        }
        if (charIsSpace(ch)  ||  ch == '+'  ||  ch == '#'  ||  ch == '='  ||
              ch == '!'  ||  ch == '?'  ||  ch == ')'  ||  ch == EndChar) {
            UnGetChar (ch);
            switch (numOhsSeen) {
            case 2:  return TOKEN_Move_Castle_King;
            case 3:  return TOKEN_Move_Castle_Queen;
            default: return  TOKEN_Invalid;
            }
        }
        break;
    }
    // If we reach here, it is not a valid castling move:
    GetRestOfWord_WithDots (buffer);
    return TOKEN_Invalid;
}

tokenT
PgnParser::GetRestOfMove (char * buffer)
{
    int moveLength = 1;
    int ch;
    while (true) {
        ch = GetChar();
        if (charIsSpace(ch)) {
            UnGetChar (ch);
            return (moveLength == 1 ? TOKEN_Suffix : TOKEN_Move_Piece);
        }
        if ((ch >= '1'  &&  ch <= '8')  ||  (ch >= 'a'  &&  ch <= 'h')) {
            ADDCHAR (buffer, ch);
            moveLength++;
            continue;
        }
        if (ch == '-') {
            // Check for "-+" or "-/+" after the move:
            int nextCh = GetChar();
            UnGetChar (nextCh);
            if (nextCh == '+'  ||  nextCh == '/') {
                // Seen "-+" or "-/+", e.g. "Bb5-+"
                UnGetChar (ch);
                break;
            }
            // Otherwise, just ignore "-" in a move:
            moveLength++;
            continue;
        }
        if (ch == 'x'  ||  ch == ':') {
            // We allow ":" as a capture as well as "x".
            moveLength++;
            continue;
        }
        if (ch == ')'  ||  ch == '+'  ||  ch == '!'  ||  ch == '='  ||
              ch == '?'  ||  ch == '#'  ||  ch == EndChar) {
            // Put c back into the infile buffer for next token.
            UnGetChar (ch);
            return (moveLength == 1 ? TOKEN_Suffix : TOKEN_Move_Piece);
        }
        break;
    }

    // If we get here, it is an invalid Move character:
    return TOKEN_Invalid;
}


tokenT
PgnParser::GetRestOfPawnMove (char * buffer)
{
    int ch;
    bool seenDigit = false;

    // allows for using lowercase 'b' for bishop promotion
    // eg. OliThink uses a7b8b for FEN "1q6/P6k/8/5N1K/8/8/8/8 w - - 0 1"
    bool pawn2seen = false;

    // First, check for "ep" or "e.p." on its own, not a move at all:
    if (*(buffer-1) == 'e') {
        ch = GetChar ();
        UnGetChar (ch);
        if (ch == 'p'  ||  ch == '.') {
            GetRestOfWord_WithDots (buffer);
            return TOKEN_Ignore;
        }
    }

    while (true) {
        ch = GetChar ();
        if (charIsSpace (ch)) {
            UnGetChar (ch);
            return TOKEN_Move_Pawn;
        }
        // Check for "ep" or "e.p." after a digit:
        if (seenDigit) {
            if (ch == 'e') {
                char nextCh = GetChar ();
                UnGetChar (nextCh);
                if (nextCh == 'p'  ||  nextCh == 'p') { continue; }
            }
            if (ch == 'p'  ||  ch == '.') { continue; }
        }
        if (ch >= '1'  &&  ch <= '8') {
            seenDigit = true;
            ADDCHAR (buffer, ch);
            continue;
        }
        if (ch >= 'a'  &&  ch <= 'h' && !pawn2seen) {
            pawn2seen = true;
            ADDCHAR (buffer, ch);
            continue;
        }

        if (ch == '-') {
            // Check for "-+" or "-/+" after the move:
            int nextCh = GetChar();
            UnGetChar (nextCh);
            if (nextCh == '+'  ||  nextCh == '/') {
                // Seen "-+" or "-/+", e.g. "e4-+"
                UnGetChar (ch);
                return TOKEN_Move_Pawn;
            }
            // Otherwise, just ignore "-" in a move:
            continue;
        }
        if (ch == 'x'  ||  ch == ':') {
            // Omit capture symbols, etc:
            continue;
        }
        if (ch == '=') {   // A promotion!
            ch = GetChar();
            // Convert "K" for promoted piece from King to Knight:
            //if (ch == 'K') { ch = 'N'; }
            if (ch == 'Q' || ch == 'R' || ch == 'B'  ||  ch == 'N') {
                ADDCHAR (buffer, '=');
                ADDCHAR (buffer, ch);
                return TOKEN_Move_Promote;
            } else {
                // OK, the "=" is NOT a promotion, but may be part of
                // a symbol like "e4=" or "e4=+" so put it back:
                UnGetChar (ch);
                UnGetChar ('=');
                return TOKEN_Move_Pawn;
            }
        }
        // Convert "K" for promoted piece from King to Knight:
        //if (ch == 'K') { ch = 'N'; }
        if (ch == 'q' || ch == 'r' || ch == 'b'  ||  ch == 'n') {
            // Promotion with the "=" sign missing.
            // Faile and Spike use lower case letters.. Will this break anything else ? S.A.
            ADDCHAR (buffer, '=');
            ADDCHAR (buffer, toupper(ch));
            return TOKEN_Move_Promote;
        }
        if (ch == 'Q' || ch == 'R' || ch == 'B'  ||  ch == 'N') {
            // Promotion with the "=" sign missing. We insert it.
            ADDCHAR (buffer, '=');
            ADDCHAR (buffer, ch);
            return TOKEN_Move_Promote;
        }
        if (ch == ')'  ||  ch == '+'  ||  ch == '!'  ||
            ch == '?'  ||  ch == '#'  ||  ch == EndChar) {
            UnGetChar (ch);
            return TOKEN_Move_Pawn;
        }
        break;
    }
    // If we reach here, it is an invalid move:
    return TOKEN_Invalid;
}

tokenT
PgnParser::GetGameToken (char * buffer, uint bufSize)
{
    char * buf = buffer;
    int ch = GetChar();
    if (ch == EndChar) { return TOKEN_EndOfInput; }

    // Read past any whitespace, dots and newlines.
    while ((charIsSpace(ch)  ||  (ch == '.'))) {
        ch = GetChar();
        if (ch == EndChar) { return TOKEN_EndOfInput; }
    }
    ADDCHAR (buf, ch);

    // Now try to figure out what sort of token we have...

    if (isdigit(ch)) {   // MoveNumber, or result, or invalid
        int allDigits = 1; // Set to zero when a non-digit is found.
        GetRestOfWord_NoDots (buf);
        char *temp = buffer;
        // Verify if token is all digits, or could be a result:
        while (*temp) {
            if (! isdigit(static_cast<unsigned char>(*temp))) {
                allDigits = 0;
                break;
            }
            temp++;
        }
        if (allDigits) { // Token was all digits.
            // We should just return TOKEN_MoveNum now, unless we
            // want to check for the ugly "00" and "000" (with zeroes) for
            // castling. PGN input that bad doesn't deserve to get accepted!
            return TOKEN_MoveNum;
        }

        // Now we check each acceptable result string.
        // Note that we also check for the awful "0-0" (castling with zeroes
        // instead of big-Ohs) although it is BAD PGN input.

        if (*buffer == '0') {   // token starts with '0'
            if (strEqual (buffer, "0-1")) { return TOKEN_Result_Black; }
            if (strEqual (buffer, "0:1")) { return TOKEN_Result_Black; }
            if (strIsPrefix ("0-0-0", buffer)) { return TOKEN_Move_Castle_Queen; }
            if (strIsPrefix ("000", buffer)) { return TOKEN_Move_Castle_Queen; }
            if (strIsPrefix ("0-0", buffer)) { return TOKEN_Move_Castle_King; }
            if (strIsPrefix ("00", buffer)) { return TOKEN_Move_Castle_King; }
        } else if (*buffer == '1') {   // token starts with '1'
            if (strEqual (buffer, "1-0")) { return TOKEN_Result_White; }
            if (strEqual (buffer, "1:0")) { return TOKEN_Result_White; }
            if (strEqual (buffer, "1/2")) { return TOKEN_Result_Draw; }
            if (strEqual (buffer, "1/2-1/2")) { return TOKEN_Result_Draw; }
            if (strEqual (buffer, "1/2:1/2")) { return TOKEN_Result_Draw; }
        }

        // If we get here, it must be invalid (Not a move number or a result)
        return TOKEN_Invalid;
    }

    // Now we check for Moves.

    if (ch >= 'a'  &&  ch <= 'h') {   // Pawn move.
        return GetRestOfPawnMove (buf);
    }
    if (ch == 'P') {
        // Treat "P..." as a pawn move, ignoring the initial "P":
        buf = buffer;
        ADDCHAR (buf, GetChar());
        return GetRestOfPawnMove (buf);
    }
    if (ch == 'N'  ||  ch == 'B'  ||  ch == 'R'  ||  ch == 'Q'  ||  ch == 'K') {
        return GetRestOfMove (buf);
    }
    if (ch == 'O'  ||  ch == 'o') { //letter "O": must be Castling or invalid
        return GetRestOfCastling (buf);
    }

    // Check for null move:
    if (ch == 'n') {
        GetRestOfWord_Letters (buf);
        if (strEqual (buffer, "null")) {
            return TOKEN_Move_Null;
        }
        return TOKEN_Invalid;
    }

    // Now we check for other tokens.......
    if (ch == ';'  ||  ch == '%') { // LineComment.
        // "%" should only mark a comment if at the start of the line, but we allow it anywhere on a line.
        // S.A - There's a bug here with the parser, but not sure if it's fixable:
        //       stray ';' before variations and/or comments SPLIT OVER MULTIPLE LINES cause chaos
        GetLine (buf, bufSize-1);
        return TOKEN_LineComment;
    }
    if (ch == '{') {   // regular comment. We let caller read until a "}".
        return TOKEN_Comment;
    }

    if (ch == '}') {   // Close-brace outside a comment. Should not happen.
        return TOKEN_CommentEnd;
    }

    if (ch == '(') {   // variation. We let caller parse it out.
        return TOKEN_VarStart;
    }
    if (ch == ')') { return TOKEN_VarEnd; }

    if (ch == '!'  ||  ch == '?'  ||  ch == '='  ||  ch == '-') {   // Suffix
        GetRestOfSuffix (buf, ch);
        // Treat the sequence "--" as a null move:
        if (strEqual (buffer, "--")) {
            return TOKEN_Move_Null;
        }
        return TOKEN_Suffix;
    }
    if (ch == '$') {   // NAG
        GetRestOfWord_NoDots (buf);
        return TOKEN_Nag;
    }

    if (ch == '+'  ||  ch == '#') {   // Check or mate or invalid
        tokenT t = (ch == '+' ? TOKEN_Check : TOKEN_Mate);
        // Can be followed by: space, !, ? or $.  So peek at next input char
        char nextc = GetChar();
        // If "+" is followed by another "+", treat it as a double-check:
        if (ch == '+'  &&  nextc == '+') { return t; }
        UnGetChar (nextc);
        if (charIsSpace(nextc)  ||  nextc == '!'  ||  nextc == '?' ||
                nextc == '$'  ||  nextc == ')'  ||  nextc == EndChar) {
            return t;   // Token was a valid "+" or "#".
        }
        // If we get here, token looks invalid.
        // It could be a suffix, e.g. "+=", so return as that:
        GetRestOfSuffix (buf, ch);
        return TOKEN_Suffix;
    }

    if (ch == '*') {   // "*" (Result).  Must be followed by whitespace.
        GetRestOfWord_NoDots (buf);
        if (buf[0] != '\0') { // We have a word with more than just "*"
            return TOKEN_Invalid;
        }
        return TOKEN_Result_Star;
    }

    if (ch == '[') {   // Tag! This shouldn't happen! But return TOKEN_Tag.
        // Put the '[' back so it can be read as a tag of the next game:
        UnGetChar (ch);
        return TOKEN_Tag;
    }

    if (ch == 'D') {  // Diagram symbol:
        GetRestOfWord_NoDots (buf);
        return TOKEN_Nag;
    }

    if (ch == '~') {  // "Unclear" annotation symbol:
        GetRestOfSuffix (buf, ch);
        return TOKEN_Suffix;
    }

    // Convert Z0 to Null Move (thanks to Marcin Kasperski)
    if (ch == 'Z') {   // Z0 - nullmove in CA notation
        int nextCh = GetChar();
        if (nextCh == '0')
            return TOKEN_Move_Null;
        UnGetChar(nextCh);
    }

    // If we get down this far, the first character of our token is invalid.
    // Probably a letter like C or z, or punctuation or nonprintable.

    GetRestOfWord_WithDots (buf);
    // Any other null-move notations to be checked for here?
    return TOKEN_Invalid;
}


static inline char *
firstNonBlank (char * s)
{
    char *x = s;
    while (*x) {
        if (! charIsSpace(*x))  { return x; }
        x++;
    }
    return x;
}

tokenT
PgnParser::GetNextToken (char * buffer, uint bufSize)
{
    if (ParseMode == PARSE_Header) {
        if (EndOfInput()) { return TOKEN_EndOfInput; }

        // We want to read a while line, but first we need to
        // peek at the first character of the line to see if
        // we are past the tags and already at the moves.
        // If this happens, it means there was no blank line
        // between the tags and the moves which is not good PGN,
        // but it is very common we need to accept it.

        char * buf = buffer;
        int ch = GetChar();
        ADDCHAR (buf,ch);
        if (ch == EndChar) { return TOKEN_EndOfInput; }

        // Read past any whitespace, dots and newlines.
        // but preserve them in buffer.
        while ((charIsSpace(ch)  ||  (ch == '.'))) {
            ch = GetChar();
            ADDCHAR (buf, ch);
            if (ch == EndChar) { return TOKEN_EndOfInput; }
        }

        if ((ch == '%')||(ch ==';')) {
            GetLine (buf, bufSize-(buf-buffer));
            return TOKEN_LineComment;
        }

        if (ch == '[') {
            GetLine (buf, bufSize-(buf-buffer));
            return TOKEN_Tag;
        }

        if (ch == '\0') {
            return TOKEN_TagEnd;
        }

        // We've got the start of the moves.
        UnGetChar (ch);
        return TOKEN_TagEnd;
    }  // End of Header Mode

    if (ParseMode == PARSE_Searching) {
        // Looking for first Header Tag of game.  In this mode, nothing is
        // invalid. Lines without a PGN Header Tag are treated as a Line
        // Comment, even if they don't start with "%" or ";".
        if (EndOfInput())  { return TOKEN_EndOfInput; }
        GetLine (buffer, bufSize);
        char * s = firstNonBlank (buffer);
        if (*s == '[') { return TOKEN_Tag; }
        return TOKEN_LineComment;
    }   // End of Searching mode.

   // If we reach here, we are in Game mode, the most complex.
    return GetGameToken (buffer, bufSize);
}


errorT
PgnParser::ParseMoves (Game * game)
{
    char * buffer = new char [MAX_COMMENT_SIZE];
    errorT err = ParseMoves (game, buffer, MAX_COMMENT_SIZE);
    delete[] buffer;
    return err;
}
   

errorT
PgnParser::ParseMoves (Game * game, char * buffer, uint bufSize)
{
    errorT err = OK;
    uint moveErrorCount  = 0;
    const uint maxMoveErrorsPerGame = 1;
    uint commentErrorCount = 0;
    const uint maxCommentErrorsPerGame = 1;
    simpleMoveT sm;
    byte nag;

    // Uncomment next line to allow castling after King or Rook have moved:
    // game->GetCurrentPos()->SetStrictCastling (false);
    ParseMode = PARSE_Game;
    tokenT token = GetNextToken (buffer, bufSize);
    while (! TOKEN_isResult(token)) {   
        switch (token) {
        case TOKEN_Move_Pawn:
        case TOKEN_Move_Promote:
        case TOKEN_Move_Piece:
        case TOKEN_Move_Castle_King:
        case TOKEN_Move_Castle_Queen:
        case TOKEN_Move_Null:
            err = game->GetCurrentPos()->ReadMove (&sm, buffer, token);

            // If king castling failed, maybe it's OO meaning castle queen-side
            if (err != OK  &&  token == TOKEN_Move_Castle_King) {
                err = game->GetCurrentPos()->ReadMove (&sm, buffer, TOKEN_Move_Castle_Queen);
            }

            // The most common type of "illegal" move in standard
            // chess is castling when the king or rook have already
            // moved. So if a castling move failed, turn off
            // strict checking of castling rights and try again,
            // but still print a warning if that succeeded:

            if (err != OK  &&  (token == TOKEN_Move_Castle_King  ||
                                token == TOKEN_Move_Castle_Queen)) {
                bool prevFlag = game->GetCurrentPos()->GetStrictCastling();
                game->GetCurrentPos()->SetStrictCastling (false);
                err = game->GetCurrentPos()->ReadMove (&sm, buffer, token);
                game->GetCurrentPos()->SetStrictCastling (prevFlag);

                // If no longer an error, castling without strict checking
                // worked, but still print a warning about it:
                if (err == OK) {
                    char tempStr[500];
                    snprintf (tempStr, sizeof(tempStr), "(%s) in game %s - %s, %u",
                             buffer, game->GetWhiteStr(), game->GetBlackStr(),
                             date_GetYear (game->GetDate()));
                    LogError ("Warning: illegal castling ", tempStr);
                }
            }

            if (err == OK  &&  moveErrorCount == 0) {
                err = game->AddMove (&sm, NULL);
            }

             // Report an error if the move could not be added:
            if (err != OK) {
                moveErrorCount++;
                if (moveErrorCount <= maxMoveErrorsPerGame) {
                    char tempStr [500];
                    // Add an error comment to the game:
                    snprintf (tempStr, sizeof(tempStr), "Error reading move: %s", buffer);
                    game->SetMoveComment (tempStr);
                    snprintf (tempStr, sizeof(tempStr), "Error reading move in game %s - %s, %u: ",
                             game->GetWhiteStr(), game->GetBlackStr(),
                             date_GetYear (game->GetDate()));
                    LogError (tempStr, buffer);
                }
            }
            break;

        case TOKEN_Ignore:
        case TOKEN_MoveNum:
        case TOKEN_Check:
        case TOKEN_Mate:
            break;  // Move numbers, check and made symbols: just ignore.

        case TOKEN_Nag:
            nag = game_parseNag (buffer);
            if (moveErrorCount == 0) { game->AddNag (nag); }
            break;

        case TOKEN_Suffix:
            nag = game_parseNag (buffer);
            if (nag == 0) {
                LogError ("Warning: Invalid annotation symbol: ", buffer);
            } else {
                if (moveErrorCount == 0) {
                    game->AddNag (nag);
                }
            }
            break;

        case TOKEN_VarStart:
            if (game->AddVariation() != OK) {
                LogError ("Error: Unable to add variation", "");
                return ERROR_Game;
            }
            break;

        case TOKEN_VarEnd:
            game->MoveExitVariation();
            game->MoveForward();
            break;

        case TOKEN_Comment: {
            std::string comment = GetComment();

            std::string tmpUft8;
            const char* end = comment.c_str() + comment.length();
            for (const char* i = comment.c_str(); i != end; i++) {
                tmpUft8 += pgnLatin1_to_utf8(i);
            }

            game->SetMoveComment(tmpUft8.c_str());

            } break;

        case TOKEN_LineComment:
            break;  // Line comments inside a game are just ignored.

        case TOKEN_CommentEnd:
            if (commentErrorCount < maxCommentErrorsPerGame) {
                char tempStr [500];
                snprintf (tempStr, sizeof(tempStr), " in game %s - %s, %u: ",
                    game->GetWhiteStr(), game->GetBlackStr(),
                    date_GetYear (game->GetDate()));
                LogError ("Warning: \"}\" seen outside a comment", tempStr);
                commentErrorCount++;
            }
            break;

        case TOKEN_Tag:
            // This is often seen when missing TOKEN_Result
            LogError ("PGN header '[' seen inside game (result missing ?)", "");
            return ERROR_Game;

        case TOKEN_EndOfInput:
            if (EndOfInputWarnings) {
                LogError ("End of input reached in game (result missing ?)", "");
                return ERROR_Game;
            } else {
                return OK;
            }

        default:
            LogError ("Error: Unexpected symbol: ", buffer);
        }

        token = GetNextToken (buffer, bufSize);
    }

    // Now the token value is the game result:
    resultT r = RESULT_None;
    switch (token) {
    case TOKEN_Result_White: r = RESULT_White; break;
    case TOKEN_Result_Black: r = RESULT_Black; break;
    case TOKEN_Result_Draw:  r = RESULT_Draw;  break;
    default:
        r = RESULT_None;
    }

    // Verify the result matches that from the header:
    if (r != game->GetResult()) {
        // Use the end-of-game result instead of the header tag result:
        game->SetResult (r);
        if (ResultWarnings) {
            LogError ("Result did not match the header result", "");
        }
    }
    return OK;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// PgnParser::ParseGame():
//      Parses the next game from the input source.
//      Returns: OK if a game was found and free of fatal errors;
//               ERROR_NotFound if no game was found;
//               or some other appropriate error code upon error.
//
errorT
PgnParser::ParseGame (Game * game)
{
    char * buffer = new char [MAX_COMMENT_SIZE];
    uint preGameTextLength = 0;

    char * preGameTextBuffer = new char [MAX_COMMENT_SIZE];

    GameCounter++;
    errorT err = ERROR_NotFound;
    ParseMode = PARSE_Searching;
    tokenT token = GetNextToken (buffer, MAX_COMMENT_SIZE);
    while (token != TOKEN_EndOfInput) {
        if (TOKEN_isTag (token)) {
            // Found a PGN Header tag, e.g. [Event "..."]
            if (ParseMode == PARSE_Searching) {
                // This is the first tag of a new game:
                game->Clear();
                if (StorePreGameText  &&  preGameTextLength > 0
                    &&  ! strIsAllWhitespace (preGameTextBuffer)) {
                    // Remove last newline and store pre-game comment:
                    preGameTextBuffer[preGameTextLength-1] = 0;
                    game->SetMoveComment (preGameTextBuffer);
                }
                ParseMode = PARSE_Header;
            }
            if (ExtractPgnTag (buffer, game) != OK) {
                LogError ("Error reading tag: ", buffer);
            }

        } else if (token == TOKEN_LineComment) {
            static Position epd;
            if (epd.ReadFromFEN(buffer) == OK) {
                //EPD line
                game->Clear();
                game->SetStartFen(buffer);
                uint spaces = 0;
                const char* buffer_end = buffer + MAX_COMMENT_SIZE;
                for (const char* i = buffer; *i != 0 && i != buffer_end; i++) {
                    if (*i == ' ') {
                        spaces++;
                        continue;
                    }
                    if (spaces >= 4) {
                        game->SetMoveComment(i);
                        break;
                    }
                }
                ParseMode = PARSE_Game;
                err = OK;
                break;
            }
            // Add the line to the pre-game text if necessary:
            if (preGameTextLength > 0  ||  buffer[0] != 0) {
                uint len = strLength (buffer);
                if (preGameTextLength + len < MAX_COMMENT_SIZE) {
                    strCopy (&(preGameTextBuffer[preGameTextLength]), buffer);
                    preGameTextLength += len;
                    preGameTextBuffer[preGameTextLength] = '\n';
                    preGameTextLength++;
                }
            }

        } else if (token == TOKEN_Comment) {
            // Get, but ignore, this comment:
            GetComment();

        } else if (token == TOKEN_TagEnd) {
            // A blank line after the PGN header tags:
            ParseMode = PARSE_Game;
            err = ParseMoves (game, buffer, MAX_COMMENT_SIZE);
            break;
        } else {
            // Any other token is invalid here:
            LogError ("Warning: Invalid text in PGN game header: ", buffer);
        }

        token = GetNextToken (buffer, MAX_COMMENT_SIZE);
    }
    delete[] buffer;
    delete[] preGameTextBuffer;

    if (ParseMode == PARSE_Header) {
        if (EndOfInputWarnings) {
            LogError ("Warning: End of input in PGN header tags section", "");
            err = ERROR_Game;
        } else {
            err = OK;
        }
    }
    return err;
}


//////////////////////////////////////////////////////////////////////
//  EOF: pgnparse.cpp
//////////////////////////////////////////////////////////////////////
