//////////////////////////////////////////////////////////////////////
//
//  FILE:       pgnparse.h
//              PgnParser class
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    3.0
//
//  Notice:     Copyright (c) 2001  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (shane@cosc.canterbury.ac.nz)
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
#include "game.h"
#include "dstring.h"

#define MAX_UNGETCHARS 16

class PgnParser
{
  private:

    MFile * InFile;
    const char * InBuffer;
    const char * InCurrent;
    uint   LineCounter;
    int    EndChar;
    uint   BytesSeen;

    FILE * ErrorFile;
    DString * ErrorBuffer;
    uint   NumErrors;

    enum { PARSE_Searching, PARSE_Header, PARSE_Game } ParseMode;

    bool   StorePreGameText;
    bool   EndOfInputWarnings;
    bool   ResultWarnings;

    uint   UnGetCount;
    int    UnGetCh[MAX_UNGETCHARS];

    inline int    GetChar();
    inline void   UnGetChar (int ch);

    void   Init();
    void   Reset();
    void   LogError (const char * errMessage, const char * text);
    void   GetLine (char * buffer, uint bufSize);
    void   GetComment (char * buffer, uint bufSize);
    void   GetRestOfSuffix (char * buffer, char firstChar);
    void   GetRestOfWord_NoDots (char * buffer);
    void   GetRestOfWord_WithDots (char * buffer);
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
    PgnParser (MFile * infile) { Init (infile); }
    PgnParser (const char * inbuffer) { Init (inbuffer); }
    ~PgnParser() { delete ErrorBuffer; }

    void   Init (MFile * infile);
    void   Init (const char * inbuffer);

    void   Reset (MFile * infile);
    void   Reset (const char * inbuffer);

    uint   BytesUsed (void) { return BytesSeen; }
    uint   ErrorCount() { return NumErrors; }
    const char * ErrorMessages() { return ErrorBuffer->Data(); }
    void   ClearErrors();
    void   SetErrorFile (FILE * fp) { ErrorFile = fp; }

    void   KeepPreGameText() { StorePreGameText = true; }
    void   IgnorePreGameText() { StorePreGameText = false; }
    void   SetPreGameText (bool b) { StorePreGameText = b; }
    void   SetEndOfInputWarnings (bool b) { EndOfInputWarnings = b; }
    void   SetResultWarnings (bool b) { ResultWarnings = b; }

    tokenT GetNextToken (char * buffer, uint bufSize);

    errorT ParseGame (Game * game);
    errorT ParseMoves (Game * game, char * buffer, int bufSize);

};



inline int
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

inline void
PgnParser::UnGetChar (int ch)
{
    if (UnGetCount == MAX_UNGETCHARS) { return; }
    UnGetCh[UnGetCount] = ch;
    UnGetCount++;
    BytesSeen--;
    if (ch == '\n') { LineCounter--; }
}


inline void
PgnParser::ClearErrors (void)
{
    ErrorBuffer->Clear();
    NumErrors = 0;
}


#endif // idndef SCID_PGNPARSE_H

//////////////////////////////////////////////////////////////////////
//  EOF: pgnparse.h
//////////////////////////////////////////////////////////////////////

