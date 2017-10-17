//////////////////////////////////////////////////////////////////////
//
//  Notice:     Copyright (c) 2001-2003  Shane Hudson.  All rights reserved.
//              Copyright (C) 2015-2017  Fulvio Benini
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
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

/** @file
 *    Implements a PGN-format Parser which can read PGN text
 *    from an open file or from a zero-terminated string, and convert
 *    it into a Scid Game object.
 */

#ifndef SCID_PGNPARSE_H
#define SCID_PGNPARSE_H

#include "common.h"
#include "tokens.h"
#include <streambuf>
#include <string>

class Game;

/**
 * A simple alternative to the deprecated std::strstreambuf.
 */
class PgnParserBuffer {
	std::streambuf* stlBuf_;
	const char* charBuf_;
	const char* charPos_;

public:
	explicit PgnParserBuffer(std::streambuf* inbuffer)
	    : stlBuf_(inbuffer), charBuf_(NULL), charPos_(NULL) {
		ASSERT(inbuffer != NULL);
	}
	explicit PgnParserBuffer(const char* inbuffer)
	    : stlBuf_(NULL), charBuf_(inbuffer), charPos_(inbuffer) {
		ASSERT(inbuffer != NULL);
	}

	int sbumpc() {
		if (stlBuf_ != NULL)
			return stlBuf_->sbumpc();

		return (*charPos_ != '\0') ? static_cast<unsigned char>(*charPos_++)
		                           : EOF;
	}

	int sgetc() {
		if (stlBuf_ != NULL)
			return stlBuf_->sgetc();

		return (*charPos_ != '\0') ? static_cast<unsigned char>(*charPos_)
		                           : EOF;
	}

	void sungetc() {
		if (stlBuf_ != NULL)
			stlBuf_->sungetc();
		else if (charPos_ != charBuf_)
			--charPos_;
	}
};

/**
 * This class connects a PgnParser object to a input buffer and a output logger.
 */
class PgnParserProxy {
	PgnParserBuffer inBuf_;
	std::string ErrorBuffer;
	size_t BytesSeen;
	uint NumErrors;
	uint LineCounter;
	uint GameCounter;

public:
	template <typename T>
	explicit PgnParserProxy(T* inbuffer)
	    : inBuf_(inbuffer), BytesSeen(0), NumErrors(0), LineCounter(0),
	      GameCounter(0) {}

	void Reset(const char* inbuffer) {
		inBuf_ = PgnParserBuffer(inbuffer);
		ErrorBuffer.clear();
		BytesSeen = 0;
		NumErrors = 0;
		LineCounter = 0;
		GameCounter = 0;
	}

	size_t BytesUsed() { return BytesSeen; }

	uint ErrorCount() { return NumErrors; }

	const char* ErrorMessages() { return ErrorBuffer.c_str(); }

protected:
	enum { EndChar = EOF };

	int GetChar() {
		BytesSeen++;
		int ch = inBuf_.sbumpc();
		if (ch == '\n') {
			LineCounter++;
		}
		return ch;
	}

	void UnGetChar(int ch) {
		BytesSeen--;
		if (ch != EndChar) {
			inBuf_.sungetc();
			if (ch == '\n')
				LineCounter--;
		}
		ASSERT(inBuf_.sgetc() == ch);
	}

	bool EndOfInput() { return inBuf_.sgetc() == EndChar; }

	void LogError(const char* errMessage, const char* text) {
		NumErrors++;
		ErrorBuffer += "(game ";
		ErrorBuffer += std::to_string(GameCounter);
		ErrorBuffer += ", line ";
		ErrorBuffer += std::to_string(LineCounter);
		ErrorBuffer += ") ";
		ErrorBuffer += errMessage;
		ErrorBuffer += text;
		ErrorBuffer += "\n";
	}

	void incrGameCounter() { ++GameCounter; }
};

/**
 * This class implements a PGN-format Parser which reads PGN text and convert it
 * into a Scid Game object.
 */
class PgnParser : public PgnParserProxy
{
    enum { PARSE_Searching, PARSE_Header, PARSE_Game } ParseMode;

    char* buffer_;

    bool   EndOfInputWarnings;
    bool   ResultWarnings;

private:
    void   GetLine (char * buffer, uint bufSize);
    char*  GetComment(char* d_begin, char* d_end);
    void   GetRestOfSuffix (char * buffer, char firstChar);
    void   GetRestOfWord_NoDots (char * buffer);
    void   GetRestOfWord_WithDots (char * buffer);
    void   GetRestOfWord_Letters (char * buffer);
    errorT ExtractPgnTag (const char * buffer, Game * game);

    tokenT GetRestOfCastling (char * buffer);
    tokenT GetRestOfMove (char * buffer);
    tokenT GetRestOfPawnMove (char * buffer);
    tokenT GetGameToken (char * buffer, uint bufSize);
    tokenT GetNextToken (char * buffer, uint bufSize);

public:
    template <typename T>
    explicit PgnParser(T* inbuffer)
        : PgnParserProxy(inbuffer), buffer_(NULL), EndOfInputWarnings(true),
          ResultWarnings(true) {}
    ~PgnParser() { delete[] buffer_; }

    void   SetEndOfInputWarnings (bool b) { EndOfInputWarnings = b; }
    void   SetResultWarnings (bool b) { ResultWarnings = b; }

    errorT ParseGame(Game* game, bool StorePreGameText = true);
    errorT ParseMoves (Game * game);
    errorT ParseMoves (Game * game, char * buffer, uint bufSize);
};

#endif // idndef SCID_PGNPARSE_H

//////////////////////////////////////////////////////////////////////
//  EOF: pgnparse.h
//////////////////////////////////////////////////////////////////////

