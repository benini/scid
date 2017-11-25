//////////////////////////////////////////////////////////////////////
//
//  Notice:     Copyright (c) 2001-2003  Shane Hudson.  All rights reserved.
//              Copyright (C) 2015-2017  Fulvio Benini
//
//  This file is part of Scid (Shane's Chess Information Database).
//
//  Scid is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation.
//
//  Scid is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with Scid.  If not, see <http://www.gnu.org/licenses/>.
//
//////////////////////////////////////////////////////////////////////


#include "pgnparse.h"
#include "game.h"
#include "misc.h"

#if defined(_MSC_VER) && _MSC_VER <= 1800
    #define snprintf _snprintf
#endif

namespace {
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
bool charIsSpace (int c) {
    return (c == ' '    ||
            c == '\t'   ||
            c == '\n'   ||
            c == '\v'   ||
            c == '\f'   ||
            c == '\r');
}

/**
 * The PGN standard use a subset of ISO 8859/1 (Latin 1):
 * Code value from 0 to 126 are the standard ASCII character set
 * Code value from 127 to 191 are not used for PGN data representation.
 * Code value from 192 to 255 are mostly alphabetic printing characters with
 * various diacritical marks; their use is encouraged for those languages
 * that require such characters.
 * Latin1 chars must be converted because the Tcl/tk framework uses UTF-8.
 */

/**
 * Test if two chars are not a valid UTF-8 sequence.
 * @param ch1: the first char of the sequence
 * @param ch2: the next char of the sequence
 * @returns
 * - TRUE if the sequence is not valid
 * - FALSE if the sequence *may be* valid
 */
bool invalidUTF8(int ch1, int ch2) {
	if (static_cast<unsigned char>(ch1) <= 0xBF)
		return false;

	unsigned char c = static_cast<unsigned char>(ch2);
	return c < 0x80 || c > 0xBF;
}

/**
 * Converts a Latin1 char in the range [0xC0, 0xFF] to UTF-8.
 * @param ch:   the char to convert
 * @param dest: pointer to the output buffer
 * @returns the pointer to the output buffer, one past the last element.
 */
char* pgnLatin1_to_UTF8(int ch, char* dest) {
	ASSERT(static_cast<unsigned char>(ch) > 0xBF);
	*dest++ = static_cast<unsigned char>(0xC3);
	*dest++ = static_cast<unsigned char>(ch) & 0XBF;
	return dest;
}

/**
 * Converts a string of mixed Latin1/UTF-8 chars to UTF-8.
 * If the source range do not include any Latin1 char, and it is not necessary
 * to covert it, nothing is written to @e dest.
 * @param [begin,end): the range of chars to be converted.
 *                     It is necessary to include the '\0' char if the converted
 *                     string should be null terminated.
 * @param dest: pointer to the output buffer
 * @returns the pointer to the output buffer, one past the last element.
 */
char* pgnLatin1_to_UTF8(const char* begin, const char* end, char* dest) {
	auto it = std::adjacent_find(begin, end, invalidUTF8);
	if (it == end)
		return dest;

	dest = std::copy(begin, it, dest);
	for (auto it_next = it + 1; it_next != end; ++it, ++it_next) {
		if (invalidUTF8(*it, *it_next))
			dest = pgnLatin1_to_UTF8(*it, dest);
		else
			*dest++ = *it;
	}
	*dest = *it;
	return dest;
}

} // end of anonymous namespace.


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
    strTrimRight (source, " \t", 2);

    // Now standardise the capital letters of Dutch/etc prefix names:
    standardDutchName(source);
    return;
}

errorT
PgnParser::ExtractPgnTag (const char * buffer, Game * game)
{
    const uint maxTagLength = 255;
    char tag [255];
    char bufValue[512];
    char bufUTF8[sizeof(bufValue) * 2];
    char* value = bufValue;

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

    char* one_past_the_null_char = value + lastQuoteIndex + 1;
    if (pgnLatin1_to_UTF8(value, one_past_the_null_char, bufUTF8) != bufUTF8)
        value = bufUTF8;

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

        if (! isRatingType) {
            game->AddPgnTag (tag, value);
        }
    }
    return OK;
}

// Modifies the parameter string in-place, trimming all
// whitespace at the start and end of the string, and reducing
// all other sequences of whitespace to a single space.
//
// Example: "\t\n   A  \t\n   B   C  "  (where \t and \n are tabs
// and newlines) becomes "A B C".
char* PgnParser::GetComment(char* d_begin, char* d_end) {
	int chPrev = '\0';
	for (int ch = GetChar(); ch != '}'; ch = GetChar()) {
		if (ch == EndChar) {
			LogError("Error: Open Comment at end of input", "");
			break;
		}

		if (d_begin == d_end)
			continue; // Ignore the remaining part of the comment

		if (charIsSpace(ch)) {
			if (chPrev == ' ' || chPrev == '\0')
				continue; // Trim the whitespace
			ch = ' ';
		}

		if (invalidUTF8(chPrev, ch)) {
			d_begin = pgnLatin1_to_UTF8(chPrev, --d_begin);
			if (d_begin == d_end)
				continue;
		}

		*d_begin++ = static_cast<char>(ch);
		chPrev = ch;
	}
	if (chPrev == ' ') {
		--d_begin; // Remove whitespace at the end
	} else if (invalidUTF8(chPrev, '\0')) {
		if (d_begin != d_end)
			d_begin = pgnLatin1_to_UTF8(chPrev, --d_begin);
	}

	return d_begin;
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
                int nextCh = GetChar ();
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
        int nextc = GetChar();
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
            ASSERT(buf >= buffer && size_t(buf - buffer) <= size_t(bufSize));
            GetLine(buf, bufSize - static_cast<uint>(buf - buffer));
            return TOKEN_LineComment;
        }

        if (ch == '[') {
            ASSERT(buf >= buffer && size_t(buf - buffer) <= size_t(bufSize));
            GetLine(buf, bufSize - static_cast<uint>(buf - buffer));
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

errorT PgnParser::ParseMoves(Game* game) {
    if (buffer_ == NULL)
        buffer_ = new char[MAX_COMMENT_SIZE * 2];

    return ParseMoves(game, buffer_, MAX_COMMENT_SIZE);
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
            err = game->GetCurrentPos()->ParseMove(&sm, buffer);

            // If king castling failed, maybe it's OO meaning castle queen-side
            if (err != OK  &&  token == TOKEN_Move_Castle_King) {
                err = game->GetCurrentPos()->ParseMove(&sm, buffer);
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
                err = game->GetCurrentPos()->ParseMove(&sm, buffer);
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
                err = game->AddMove(&sm);
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

        case TOKEN_Comment:
            game->SetMoveComment(buffer,
                                 GetComment(buffer, buffer + MAX_COMMENT_SIZE));
            break;

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

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// strIsAllWhitespace():
//    Returns true if the string contains only whitespace characters.
static bool strIsAllWhitespace(const char* str) {
    while (*str != 0) {
        if (!isspace(static_cast<unsigned char>(*str))) {
            return false;
        }
        str++;
    }
    return true;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// PgnParser::ParseGame():
//      Parses the next game from the input source.
//      Returns: OK if a game was found and free of fatal errors;
//               ERROR_NotFound if no game was found;
//               or some other appropriate error code upon error.
//
errorT
PgnParser::ParseGame(Game* game, bool StorePreGameText)
{
    if (buffer_ == NULL)
        buffer_ = new char[MAX_COMMENT_SIZE * 2];

    char* buffer = buffer_;
    char* preGameTextBuffer = buffer_ + MAX_COMMENT_SIZE;
    uint preGameTextLength = 0;

    incrGameCounter();
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
            GetComment(NULL, NULL);

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
