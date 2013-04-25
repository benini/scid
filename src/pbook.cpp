//////////////////////////////////////////////////////////////////////
//
//  FILE:       pbook.cpp
//              PBook class methods
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    2.3
//
//  Notice:     Copyright (c) 1999-2000  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////


// A PBook is a collection of chess positions, each with a textual
// comment or description.


#include "common.h"
#include "error.h"
#include "pbook.h"
#include "misc.h"
#include "mfile.h"

#include <stdio.h>
#include <string.h>


// PBOOK_HASH_BITS: Size of array of hash value counts.
static const uint PBOOK_HASH_BITS = 65536;
static const uint PBOOK_HASH_BYTES = (PBOOK_HASH_BITS >> 3);
#define PBOOK_HASH(pos) ((pos)->HashValue() & (PBOOK_HASH_BITS - 1))

typedef char compactBoardStr [36];


void
PBook::SetHashFlag (Position * pos) {
    uint hash = PBOOK_HASH(pos);
    uint index = hash >> 3;
    uint mask = 1 << (hash & 7);
    if (HashFlags == NULL) {
#ifdef WINCE
        HashFlags = (byte *)my_Tcl_Alloc(sizeof( byte [PBOOK_HASH_BYTES]));
#else
        HashFlags = new byte [PBOOK_HASH_BYTES];
#endif
        for (uint i=0; i < PBOOK_HASH_BYTES >> 3; i++) { HashFlags[i] = 0; }
    }
    HashFlags[index] |= mask;
}

bool
PBook::GetHashFlag (Position * pos)
{
    uint hash = PBOOK_HASH(pos);
    uint index = hash >> 3;
    uint mask = 1 << (hash & 7);
    if (HashFlags == NULL) { return true; }
    return ((HashFlags[index] & mask) != 0);
}


void
PBook::AddNodeToList (bookNodeT * node)
{
    ASSERT (NodeListCount <= NodeListCapacity);
    if (NodeListCount >= NodeListCapacity) {
        NodeListCapacity += NodeListCapacity;
#ifdef WINCE
        bookNodePtrT * newlist = (bookNodePtrT *)my_Tcl_Alloc(sizeof( bookNodePtrT [NodeListCapacity]));
#else
        bookNodePtrT * newlist = new bookNodePtrT [NodeListCapacity];
#endif
        for (uint i=0; i < NodeListCount; i++) {
            newlist[i] = NodeList[i];
        }
#ifdef WINCE
        my_Tcl_Free((char*) NodeList);
#else
        delete[] NodeList;
#endif
        NodeList = newlist;
    }
    NodeList[NodeListCount] = node;
    node->data.id = NodeListCount;
    NodeListCount++;
}

void
PBook::Init ()
{
    Altered = false;
    ReadOnly = false;
    LeastMaterial = PBOOK_MAX_MATERIAL;
    SkipCount = 0;
    FileName = NULL;
    for (uint t=0; t <= PBOOK_MAX_MATERIAL; t++) {
        Tree[t] = new StrTree<bookDataT>;
    }
    NextIndex = 0;
    Stats_PositionBytes = 0;
    Stats_CommentBytes = 0;
    for (uint i=0; i <= PBOOK_MAX_MATERIAL; i++) {
        Stats_Lookups[i] = Stats_Inserts[i] = 0;
    }
    Stats_TotalLookups = 0;
    Stats_TotalInserts = 0;
    NodeListCapacity = 1000;
#ifdef WINCE
    NodeList = (bookNodeT**)my_Tcl_Alloc(sizeof(bookNodePtrT [NodeListCapacity]));
#else
    NodeList = new bookNodePtrT [NodeListCapacity];
#endif
    NodeListCount = 0;
    HashFlags = NULL;
}

void
PBook::Clear ()
{
    bookNodeT * node;

    Altered = false;
    for (uint i=0; i <= PBOOK_MAX_MATERIAL; i++) {
        Tree[i]->IterateStart();
        while ((node = Tree[i]->Iterate()) != NULL) {
#ifdef WINCE
            my_Tcl_Free((char*) node->data.comment);
#else
            delete[] node->data.comment;
#endif
        }
        delete Tree[i];
        Tree[i] = new StrTree<bookDataT>;
    }
    NodeListCount = 0;
#ifdef WINCE
    if (FileName) { my_Tcl_Free( FileName ); }
#else
    if (FileName) { delete[] FileName; }
#endif
    FileName = NULL;
    NextIndex = 0;
    LeastMaterial = PBOOK_MAX_MATERIAL;
    Stats_PositionBytes = 0;
    Stats_CommentBytes = 0;
#ifdef WINCE
    my_Tcl_Free((char*) HashFlags);
#else
    delete[] HashFlags;
#endif

    HashFlags = NULL;
}

void
PBook::SetFileName (const char * fname)
{
#ifdef WINCE
    if (FileName) { my_Tcl_Free( FileName ); }
#else
    if (FileName) { delete[] FileName; }
#endif
    if (!fname) { FileName = NULL; return; }

    // Allocate space for the filename string:
    FileName = strDuplicate(fname);
}

inline const char *
epd_findOpcode (const char * epdStr, const char * opcode)
{
    const char * s = epdStr;
    while (*s != 0) {
        while (*s == ' '  ||  *s == '\n') { s++; }
        if (strIsPrefix (opcode, s)) {
            const char *codeEnd = s + strLength(opcode);
            if (*codeEnd == ' ') {
                return codeEnd + 1;
            }
        }
        while (*s != '\n'  &&  *s != 0) { s++; }
    }
    return NULL;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// PBook::Find(): Find a position and get its comment.
errorT
PBook::Find (Position * pos, const char ** ptrComment)
{
    // First, check the optimisation of material count:
    uint material = pos->GetCount(WHITE) + pos->GetCount(BLACK);
    ASSERT (material <= PBOOK_MAX_MATERIAL);
    if (Tree[material]->Size() == 0) {
        SkipCount++;
        return ERROR_NotFound;
    }

    Stats_Lookups[material]++;
    Stats_TotalLookups++;

    // Quick check if any boards in the tree start with the first byte
    // of this board, to save time:
    byte firstByte = pos->CompactStrFirstByte();
    if (Tree[material]->FirstByteSize (firstByte) == 0) {
        SkipCount++;
        return ERROR_NotFound;
    }

    // Quick check if the hash value of the search position is
    // not the hash value of any positions in the tree:
    if (! GetHashFlag (pos)) {
        SkipCount++;
        return ERROR_NotFound;
    }

    // Generate the compact board string for this position, and lookup:
    compactBoardStr cboard;
    pos->PrintCompactStr (cboard);
    bookNodeT * node = Tree[material]->Lookup (cboard);
    if (!node) { return ERROR_NotFound; }
    if (ptrComment) { *ptrComment = node->data.comment; }
    return OK;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// PBook::FindOpcode():
//    Finds a positition and extracts the requested opcode.
errorT
PBook::FindOpcode (Position * pos, const char * opcode, DString * target)
{
    const char * comment = NULL;
    errorT err = Find (pos, &comment);
    if (err != OK) { return ERROR_NotFound; }

    const char * s = epd_findOpcode (comment, opcode);
    if (s == NULL) { return ERROR_NotFound; }
    while (*s != 0  &&  *s != '\n') {
        target->AddChar (*s);
        s++;
    }
    return OK;
}

errorT
PBook::FindSummary (Position * pos, DString * target)
{
    const char * comment = NULL;
    errorT err = Find (pos, &comment);
    if (err != OK) { return ERROR_NotFound; }

    const char * s = epd_findOpcode (comment, "ce");
    if (s != NULL) {
        int ce = strGetInteger (s);
        if (pos->GetToMove() == BLACK) { ce = -ce; }
        char temp[20];
        sprintf (temp, "%+.2f", ((double) ce) / 100.0);
        target->Append (temp);
        return OK;
    }
    static const char * opcodes[] = {
        "eco", "nic", "pv", "pm", "bm", "id", NULL
    };
    for (const char ** opcode = opcodes; *opcode != NULL; opcode++) {
        s = epd_findOpcode (comment, *opcode);
        if (s != NULL) {
            while (*s != 0  &&  *s != '\n') {
                target->AddChar (*s);
                s++;
            }
            return OK;
        }
    }
    return ERROR_NotFound;    
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// PBook::FindNext():
//    Finds the next position in order after the current one, and
//    sets it.
//    If the flag <forwards> is false, the previous position is found
//    instead.
errorT
PBook::FindNext (Position * pos, bool forwards)
{
    ASSERT (pos != NULL);
    uint totalSize = Size();
    if (totalSize == 0) { return ERROR_NotFound; }
    if (forwards) {
        do {
            NextIndex++;
            if (NextIndex >= NodeListCount) { NextIndex = 0; }
        } while (NodeList[NextIndex] == NULL);
    } else {
        do {
            if (NextIndex == 0) {
                NextIndex = NodeListCount - 1;
            } else {
                NextIndex--;
            }
        } while (NodeList[NextIndex] == NULL);
    }


    bookNodeT * node = NodeList[NextIndex];
    ASSERT (node != NULL);
    errorT err = pos->ReadFromCompactStr ((const byte *) node->name);
    if (err != OK) { return err; }
    pos->SetEPTarget (node->data.enpassant);

    // Now print to FEN and re-read, to ensure the piece lists are in
    // the order produced by a FEN specification -- this is necessary
    // since a game with a specified start position has the piece lists
    // in the FEN-generated order:

    char temp[200];
    pos->PrintFEN (temp, FEN_CASTLING_EP);
    err = pos->ReadFromFEN (temp);
    return err;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// PBook::Insert(): Insert a position. Returns OK if a new position
//      was inserted, or updates the comment and returns ERROR_Exists if
//      the position was already in the PBook.
errorT
PBook::Insert (Position * pos, const char * comment)
{
    ASSERT (pos && comment);
    bookNodeT * node;
    errorT err;
    
    uint material = pos->GetCount(WHITE) + pos->GetCount(BLACK);
    compactBoardStr cboard;
    pos->PrintCompactStr (cboard);
    err = Tree[material]->Insert (cboard, &node);
    if (err != OK) {  // Already exists; we overwrite the old data.
#ifdef WINCE
        my_Tcl_Free((char*) node->data.comment);
#else
        delete[] node->data.comment;
#endif

    } else {
        SetHashFlag (pos);
        AddNodeToList (node);
    }
    node->data.comment = strDuplicate (comment);
    node->data.enpassant = pos->GetEPTarget();
    Altered = true;

    if (material < LeastMaterial) {
        LeastMaterial = material;
    }
    Stats_Inserts[material]++;
    Stats_TotalInserts++;
    return err;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// PBook::Delete():
//    Delete a position from the PBook.
errorT
PBook::Delete (Position * pos)
{
    uint material = pos->GetCount(WHITE) + pos->GetCount(BLACK);
    compactBoardStr cboard;
    pos->PrintCompactStr (cboard);
    bookNodeT * node = Tree[material]->Delete (cboard);
    if (!node) { return ERROR_NotFound; }

    NodeList[node->data.id] = NULL;
    // Delete the comment string:
#ifdef WINCE
        my_Tcl_Free((char*) node->data.comment);
        my_Tcl_Free((char*) node);
#else
        delete[] node->data.comment;
        delete node;
#endif

    Altered = true;
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// PBook::EcoSummary():
//    Produce a summary from the PBook for the specified ECO code prefix.
void
PBook::EcoSummary (const char * ecoPrefix, DString * dstr)
{
    uint depth = strLength (ecoPrefix);
    const char * prevEcoStr = "";
    for (uint i=0; i < NodeListCount; i++) {
        bookNodeT * node = NodeList[i];
        if (node == NULL) { continue; }
        const char * comment = node->data.comment;
        const char * ecoStr = epd_findOpcode (comment, "eco");
        const char * movesStr = epd_findOpcode (comment, "moves");
        if (ecoStr != NULL  &&  strIsPrefix (ecoPrefix, ecoStr)) {
            if (depth < 3  &&  strPrefix (ecoStr, prevEcoStr) >= depth+1) {
                continue;
            }
            prevEcoStr = ecoStr;
            while (*ecoStr != '\n'  &&  *ecoStr != 0) {
                dstr->AddChar (*ecoStr);
                ecoStr++;
            }
            dstr->Append ("  ");
            while (*movesStr != '\n'  &&  *movesStr != 0) {
                dstr->AddChar (*movesStr);
                movesStr++;
            }
            dstr->AddChar ('\n');
        }
    }    
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// PBook::StripOpcode:
//    Strips the specified opcode from every position in the book.
//    Only the first occurrence of an opcode is removed for any position,
//    but opcodes are not supposed to occur more than once anyway.
//    Returns the number of positions where an opcode was removed.
uint
PBook::StripOpcode (const char * opcode)
{
#ifdef WINCE
    char * searchCode = my_Tcl_Alloc(sizeof( char [strLength(opcode) + 2]));
#else
    char * searchCode = new char [strLength(opcode) + 2];
#endif
    strCopy (searchCode, opcode);
    strAppend (searchCode, " ");
    DString dstr;
    uint countFound = 0;

    for (uint i=0; i < NodeListCount; i++) {
        bookNodeT * node = NodeList[i];
        if (node == NULL) { continue; }
        const char * s = node->data.comment;
        int startIndex = -1;
        int index = 0;
        // Look for a line with a matching opcode:
        while (*s != 0) {
            while (*s == '\n'  ||  *s == ' ') { s++; index++; }
            if (strIsPrefix (searchCode, s)) {
                startIndex = index;
                countFound++;
                break;
            }
            while (*s != 0  &&  *s != '\n') { s++; index++; }
        }
        if (startIndex > -1) {
            s = node->data.comment;
            index = 0;
            // Add all characters before the line to be stripped:
            dstr.Clear();
            while (index < startIndex) {
                dstr.AddChar (s[index]);
                index++;
            }
            // Now find the end of this line:
            s = &(s[startIndex + 1]);
            while (*s != 0  &&  *s != '\n') { s++; }
            if (*s == '\n') { s++; }
            while (*s != 0) { dstr.AddChar (*s);  s++; }
#ifdef WINCE
        my_Tcl_Free((char*) node->data.comment);
#else
        delete[] node->data.comment;
#endif
            node->data.comment = strDuplicate (dstr.Data());
        }
    }
#ifdef WINCE
        my_Tcl_Free((char*)searchCode);
#else
    delete[] searchCode;
#endif
    return countFound;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// PBook::ReadEcoFile():
//    Read an ECO (not EPD) format file.
errorT
PBook::ReadEcoFile ()
{
    MFile fp;
    if (fp.Open (FileName, FMODE_ReadOnly) != OK) {
        return ERROR_FileOpen;
    }

    ReadOnly = true;
    LineCount = 1;
    Position std_start;
    std_start.StdStart();
    DString text;
    DString moves;
    ecoStringT ecoStr;
    ecoT ecoCode;
    int ch;
    errorT err = OK;
    bool done = false;

    // Loop to read in and add all positions:

    while (!done) {
        // Find the next ECO code:
        while (true) {
            ch = fp.ReadOneByte();
            if (ch == EOF) { done = true; break; }
            if (ch == '\n') { LineCount++; }
            if (ch >= 'A'  &&  ch <= 'E') { break; }
            if (ch == '#') {
                while (ch != '\n'  &&  ch != EOF) {
                    ch = fp.ReadOneByte();
                }
                if (ch == EOF) { done = true; }
                LineCount++;
            }
        }
        if (done) { break; }

        // Read in the rest of the ECO code:
        ecoStr[0] = ch;
        ch = fp.ReadOneByte();
        if (ch < '0'  ||  ch > '9') { goto corrupt; }
        ecoStr[1] = ch;
        ch = fp.ReadOneByte();
        if (ch < '0'  ||  ch > '9') { goto corrupt; }
        ecoStr[2] = ch;
        ecoStr[3] = 0;

        // Now check for optional extra part of code, e.g. "A00a1":
        ch = fp.ReadOneByte();
        if (ch >= 'a'  &&  ch <= 'z') {
            ecoStr[3] = ch; ecoStr[4] = 0;
            ch = fp.ReadOneByte();
            if (ch >= '1'  &&  ch <= '4') {
                ecoStr[4] = ch; ecoStr[5] = 0;
            }
        }

        // Now put ecoCode in the text string and read the text in quotes:
        ecoCode = eco_FromString (ecoStr);
        eco_ToExtendedString (ecoCode, ecoStr);
        text.Clear();
        text.Append ("eco ", ecoStr, " [");

        // Find the start of the text:
        while ((ch = fp.ReadOneByte()) != '"') {
            if (ch == EOF) { goto corrupt; }
        }
        while ((ch = fp.ReadOneByte()) != '"') {
            if (ch == EOF) { goto corrupt; }
            text.AddChar ((char) ch);
        }
        text.Append ("]\n");

        // Now read the position:
        moves.Clear();
        char prev = 0;
        while ((ch = fp.ReadOneByte()) != '*') {
            if (ch == EOF) { goto corrupt; }
            if (ch == '\n') {
                ch = ' ';
                LineCount++;
            }
            if (ch != ' '  ||  prev != ' ') {
                moves.AddChar ((char) ch);
            }
            prev = ch;
        }
        Position pos (std_start);
        err = pos.ReadLine (moves.Data());
        if (err != OK) { goto corrupt; }
        text.Append ("moves ", strTrimLeft (moves.Data()), "\n");
        if (Insert (&pos, text.Data()) != OK) {
            // Position already exists: just ignore it.
        }
    }
    return OK;
corrupt:
    return ERROR_Corrupt;
}

void ReadLine (DString* s, MFile * fp)
{
    int ch = fp->ReadOneByte();
    while (ch != '\n'  &&  ch != EOF) {
        if (ch != '\r') s->AddChar (ch);
        ch = fp->ReadOneByte();
    }
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// PBook::ReadFile(): read in a file.
errorT
PBook::ReadFile ()
{
    ASSERT (FileName != NULL);

    ReadOnly = false;
    MFile fp;
    if (fp.Open (FileName, FMODE_Both) != OK) {
        ReadOnly = true;
        if (fp.Open (FileName, FMODE_ReadOnly) != OK) {
            return ERROR_FileOpen;
        }
    }

    LineCount = 1;
    Position * pos = new Position;
    DString * line = new DString;
    ReadLine(line, &fp);
    DString dstr;
    
    while (! fp.EndOfFile()) {

        if (pos->ReadFromFEN (line->Data()) != OK) {
            fprintf (stderr, "Error reading line: %u\n", LineCount);
            LineCount++;
            line->Clear();
            ReadLine(line, &fp);
            continue;
            //exit (1);
        }

        char * s = (char *) line->Data();
        // Skip over first four fields, which were the position:
        while (*s == ' ') { s++; }
        for (uint i=0; i < 4; i++) {
            while (*s != ' '  &&  *s != 0) { s++; }
            while (*s == ' ') { s++; }
        }
        // Now process each field in turn:
        while (*s == ';'  ||  *s == ' ') { s++; }
        dstr.Clear();
        while (*s != 0) {
            while (*s == ';'  ||  *s == ' ') { s++; }
            bool seenCode = false;
            while (*s != ';'  &&  *s != 0) {
                seenCode = true;
                char ch = *s;
                // Check for backslash (escape) character:
                if (ch == '\\') {
                    s++;
                    ch = *s;
                    // "\s" -> semicolon within a field:
                    if (ch == 's') { ch = ';'; }
                }
                dstr.AddChar (ch);
                s++;
            }
            if (seenCode) { dstr.AddChar ('\n'); }
        }

        if (Insert (pos, dstr.Data()) != OK) {
            //fprintf (stderr, "Warning: position already exists! Line %u\n",
            //         LineCount);
        }
        LineCount++;
        line->Clear();
        ReadLine(line, &fp);
    }
    delete pos;
    delete line;
    Altered = false;
    NextIndex = NodeListCount - 1;
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// PBook::WriteFile(): writes the entire PBook to a file.
errorT
PBook::WriteFile ()
{
    ASSERT (FileName != NULL);
    bookNodeT * node;
    FILE * fp = fopen (FileName, "w");
    if (!fp) { return ERROR_FileOpen; }

    Stats_PositionBytes = 0;
    Stats_CommentBytes = 0;

    Position * pos = new Position;
    char tempStr [200];
    for (uint i=0; i < NodeListCount; i++) {
        node = NodeList[i];
        if (node == NULL) { continue; }
        if (pos->ReadFromCompactStr ((const byte *) node->name) != OK) {
            fclose (fp);
            delete pos;
            return ERROR_Corrupt;
        }
        pos->SetEPTarget (node->data.enpassant);
        pos->PrintFEN (tempStr, FEN_CASTLING_EP);
        fprintf (fp, "%s", tempStr);
        Stats_PositionBytes += strLength (tempStr);
        bool atCodeStart = true;
        char * s = node->data.comment;
        while (*s != 0) {
            if (*s == '\n') {
                if (! atCodeStart) { fputc (';', fp); Stats_CommentBytes++; }
                atCodeStart = true;
                s++;
                while (*s == ' ') { s++; }
            } else {
                if (atCodeStart) { fputc (' ', fp); Stats_CommentBytes++; }
                atCodeStart = false;
                // Encode "\" as "\\" and ";" as "\s":
                char ch = *s;
                switch (ch) {
                case '\\':
                    fputc ('\\', fp);
                    fputc ('\\', fp);
                    Stats_CommentBytes += 2;
                    break;
                case ';':
                    fputc ('\\', fp);
                    fputc ('s', fp);
                    Stats_CommentBytes += 2;
                    break;
                default:
                    fputc (ch, fp);
                    Stats_CommentBytes++;
                }
                s++;
            }
        }
        fputc ('\n', fp);
        Stats_CommentBytes++;
    }
    fclose(fp);
    delete pos;
    Altered = false;
    return OK;
}

void
PBook::DumpStats (FILE * fp)
{
    fprintf (fp, "%d\n", LeastMaterial);
    for (uint i=LeastMaterial; i <= PBOOK_MAX_MATERIAL; i++) {
        fprintf (fp, "%4d %8d (%5.2f%%)   ", i, Stats_Lookups[i],
                 (float)Stats_Lookups[i] * 100.0 / Stats_TotalLookups);
        fprintf (fp, "%8d (%5.2f%%)\n", Stats_Inserts[i],
                 (float)Stats_Inserts[i] * 100.0 / Stats_TotalInserts);
    }
}

//////////////////////////////////////////////////////////////////////
//  EOF: pbook.cpp
//////////////////////////////////////////////////////////////////////
