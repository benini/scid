//////////////////////////////////////////////////////////////////////
//
//  FILE:       pgnparse.h
//              PgnParser class
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    3.5
//
//  Notice:     Copyright (c) 2001-2003  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////

//
// PgnParser:
//    This class implements a PGN-format Parser which can read PGN text
//    from an open file or from a zero-terminated string, and convert
//    it into a Scid Game object.
//

#ifndef SCID_PGNPARSE_H
#define SCID_PGNPARSE_H

#include "common.h"
#include "tokens.h"
#include "mfile.h"
#include <string>

class Game;

#define MAX_UNGETCHARS 16
static const uint MAX_IGNORED_TAGS = 16;

class PgnParser
{
  private:

    MFile * InFile;
    const char * InBuffer;
    const char * InCurrent;
    uint   LineCounter;
    uint   GameCounter;
    int    EndChar;
    uint   BytesSeen;
    std::string ErrorBuffer;
    uint   NumErrors;

    enum { PARSE_Searching, PARSE_Header, PARSE_Game } ParseMode;

    bool   StorePreGameText;
    bool   EndOfInputWarnings;
    bool   ResultWarnings;

    uint   NumIgnoredTags;
    char * IgnoredTags [MAX_IGNORED_TAGS];

    uint   UnGetCount;
    int    UnGetCh [MAX_UNGETCHARS];

    inline int    GetChar();
    inline void   UnGetChar (int ch);

    void   Init (const char * inbuffer);
    void   Reset();
    void   LogError (const char * errMessage, const char * text);
    void   GetLine (char * buffer, uint bufSize);
    std::string GetComment();
    void   GetRestOfSuffix (char * buffer, char firstChar);
    void   GetRestOfWord_NoDots (char * buffer);
    void   GetRestOfWord_WithDots (char * buffer);
    void   GetRestOfWord_Letters (char * buffer);
    errorT ExtractPgnTag (const char * buffer, Game * game);

    bool   EndOfInput();
    tokenT GetRestOfCastling (char * buffer);
    tokenT GetRestOfMove (char * buffer);
    tokenT GetRestOfPawnMove (char * buffer);
    tokenT GetGameToken (char * buffer, uint bufSize);

  public:
    // Constructors: PgnParser is initialised with a file pointer or
    //    a pointer to a buffer, or it defaults to an empty buffer.
    PgnParser (void) { Init ((const char *) ""); }
    PgnParser (const char * inbuffer) { Init (inbuffer); }
    ~PgnParser() { ClearIgnoredTags(); }

    void   Reset (MFile * infile);
    void   Reset (const char * inbuffer);

    uint   BytesUsed (void) { return BytesSeen; }
    uint   ErrorCount() { return NumErrors; }
    const char* ErrorMessages() { return ErrorBuffer.c_str(); }
    void   KeepPreGameText() { StorePreGameText = true; }
    void   IgnorePreGameText() { StorePreGameText = false; }
    void   SetPreGameText (bool b) { StorePreGameText = b; }
    void   SetEndOfInputWarnings (bool b) { EndOfInputWarnings = b; }
    void   SetResultWarnings (bool b) { ResultWarnings = b; }

    void   AddIgnoredTag (const char * tag);
    void   ClearIgnoredTags ();
    bool   IsIgnoredTag (const char * tag);

    tokenT GetNextToken (char * buffer, uint bufSize);

    errorT ParseGame (Game * game);
    errorT ParseMoves (Game * game);
    errorT ParseMoves (Game * game, char * buffer, uint bufSize);

};

#endif // idndef SCID_PGNPARSE_H

//////////////////////////////////////////////////////////////////////
//  EOF: pgnparse.h
//////////////////////////////////////////////////////////////////////

