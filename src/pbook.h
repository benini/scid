//////////////////////////////////////////////////////////////////////
//
//  FILE:       pbook.h
//              PBook (Position Book) class
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    2.3
//
//  Notice:     Copyright (c) 1999-2000  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (shane@cosc.canterbury.ac.nz) 
//
//////////////////////////////////////////////////////////////////////

#ifndef SCID_PBOOK_H
#define SCID_PBOOK_H

#include "common.h"
#include "error.h"
#include "position.h"
#include "stralloc.h"
#include "strtree.h"
#include "dstring.h"

#include <stdio.h>

#define PBOOK_SUFFIX ".epd"
#define PBOOK_MAX_MATERIAL 32

struct bookDataT {
    uint    id;
    char *  comment;
};

typedef nodeT<bookDataT>  bookNodeT;

typedef bookNodeT * bookNodePtrT;

class PBook
{
  private:

    // We store 33 Trees, one for each possible total material count.
    // This way, the average number of position comparisons is greatly
    // reduced.
    StrTree<bookDataT> * Tree [PBOOK_MAX_MATERIAL + 1];

    bool    Altered;   // True if book is altered since loading or saving.
    bool    ReadOnly;
    char *  FileName;
    uint    LineCount;
    bookNodeT ** NodeList;
    uint    NodeListCapacity;
    uint    NodeListCount;
    uint    NextIndex;   // For jumping to next pbook position.
    StrAllocator * StrAlloc;
    bool    UseEnPassentField;
    uint SkipCount;      // Number of searches saved by LeastMaterial
                         // comparison.
    uint LeastMaterial;  // The smallest amount of material in any
                         // position in the book. In the range 0..32.
                         // It is a lower bound, and may be lower than
                         // the actual value if nodes are deleted.

    byte * HashFlags;

    uint Stats_PositionBytes;  // Bytes in .epd file used for positions.
    uint Stats_CommentBytes;   // Bytes in .epd file used for comments.

    uint Stats_Lookups [PBOOK_MAX_MATERIAL + 1];
    uint Stats_TotalLookups;
    uint Stats_Inserts [PBOOK_MAX_MATERIAL + 1];
    uint Stats_TotalInserts;

    void SetHashFlag (Position * pos);
    bool GetHashFlag (Position * pos);

    void AddNodeToList (bookNodeT * node);

  public:

    void    Init();
    void    Clear();

    PBook()   { Init(); }
    ~PBook()  { Clear(); delete NodeList; }

    const char *  GetFileName () { return (FileName == NULL ? "" : FileName); }
    void    SetFileName (char * filename);
    bool    IsAltered() { return Altered; }
    bool    IsReadOnly() { return ReadOnly; }
    void    UseEnPassent (bool b) { UseEnPassentField = b; }
    bool    UsesEnPassent (void) { return UseEnPassentField; }

    uint    GetLineNumber (void) { return LineCount; }

    uint    Size () {
        uint total = 0;
        for (uint i=0; i <= PBOOK_MAX_MATERIAL; i++) {
            total += Tree[i]->Size();
        }
        return total;
    }
    uint    FewestPieces () { return LeastMaterial; }
    uint    NumSkippedSearches() { return SkipCount; }

    errorT  ReadFile();
    errorT  WriteFile();
    errorT  ReadEcoFile ();

    errorT  Find (Position * pos, const char ** ptrComment);
    errorT  FindNext (Position * pos, bool forwards);
    errorT  Insert (Position * pos, const char * comment);
    errorT  Delete (Position * pos);
    errorT  FindOpcode (Position * pos, const char * opcode, DString * target);
    errorT  FindSummary (Position * pos, DString * target);
    uint    StripOpcode (const char * opcode);
    void    EcoSummary (const char * ecoPrefix, DString * dstr);
    void    DumpStats (FILE * fp);

    uint    NumPositionBytes () { return Stats_PositionBytes; }
    uint    NumCommentBytes ()  { return Stats_CommentBytes; }

};

#endif // SCID_PBOOK_H

//////////////////////////////////////////////////////////////////////
//  EOF: pbook.h
//////////////////////////////////////////////////////////////////////

