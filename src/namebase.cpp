//////////////////////////////////////////////////////////////////////
//
//  FILE:       namebase.cpp
//              NameBase class methods
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    2.3
//
//  Notice:     Copyright (c) 2001  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////

#include "common.h"
#include "error.h"
#include "namebase.h"
#include "misc.h"
#include "spellchk.h"

#include <stdio.h>
#include <string.h>


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NameBase::Init(): initialise the namebase.
//
void
NameBase::Init ()
{
    Fname[0] = 0;
    FilePtr = NULL;
    SortOrder = 0;
    strcpy (Header.magic, NAMEBASE_MAGIC);
    Header.timeStamp = 0;
    for (nameT n = NAME_PLAYER; n < NUM_NAME_TYPES; n++) {
        Header.numNames[n] = 0;
        Header.numBytes[n] = 0;
        Header.maxFrequency[n] = 0;
        NameByID[n] = NULL;
        Tree[n] = new StrTree<nameDataT>;
        ArraySize[n] = 0;
    }
    // Set the string allocator:
    StrAlloc = new StrAllocator();
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NameBase::Clear():
//      Clear the namebase and free up memory.
//
void
NameBase::Clear ()
{
    if (FilePtr != NULL) { CloseNameFile(); }
    Fname[0] = 0;
    Header.timeStamp = 0;

    // Delete all dynamically allocated space for this namebase:
    delete StrAlloc;
    for (nameT n = NAME_PLAYER; n < NUM_NAME_TYPES; n++) {
#ifdef WINCE
        my_Tcl_Free((char*) NameByID[n]);
#else
        delete[] NameByID[n];
#endif
        delete Tree[n];
    }
    Init();
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NameBase::WriteHeader():
//      Write the header to the open namebase file.
//
errorT
NameBase::WriteHeader ()
{
    ASSERT (FilePtr != NULL);

    // Ensure we are at the start of the file:
#ifdef WINCE
    my_Tcl_Seek(FilePtr, 0, SEEK_SET);
#else
    fseek (FilePtr, 0, SEEK_SET);
#endif
    writeString (FilePtr, Header.magic, 8);
    writeFourBytes (FilePtr, Header.timeStamp);
    writeThreeBytes (FilePtr, Header.numNames[NAME_PLAYER]);
    writeThreeBytes (FilePtr, Header.numNames[NAME_EVENT]);
    writeThreeBytes (FilePtr, Header.numNames[NAME_SITE]);
    writeThreeBytes (FilePtr, Header.numNames[NAME_ROUND]);
    writeThreeBytes (FilePtr, Header.maxFrequency[NAME_PLAYER]);
    writeThreeBytes (FilePtr, Header.maxFrequency[NAME_EVENT]);
    writeThreeBytes (FilePtr, Header.maxFrequency[NAME_SITE]);
    writeThreeBytes (FilePtr, Header.maxFrequency[NAME_ROUND]);
    return OK;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NameBase::OpenNameFile():
//      Opens namebase file for reading and reads the header.
//
errorT
NameBase::OpenNameFile (const char * suffix)
{
    ASSERT (FilePtr == NULL); // Shouldn't already point to an open file.

    fileNameT fname;
    strcpy (fname, Fname);
    strcat (fname, suffix);
#ifdef WINCE
    //if ((FilePtr = fopen (fname, "rb")) == NULL) {
    if ((FilePtr = my_Tcl_OpenFileChannel(NULL, fname, "r", 0666)) == 0) {
        //Handle = Tcl_OpenFileChannel(NULL, name, modeStr, 0666);//fopen (name, modeStr);
        return ERROR_FileOpen;
    }
 my_Tcl_SetChannelOption(NULL, FilePtr, "-encoding", "binary");
 my_Tcl_SetChannelOption(NULL, FilePtr, "-translation", "binary");

    readString(FilePtr, Header.magic, 8);
    if (strcmp (Header.magic, NAMEBASE_MAGIC) != 0) {
        my_Tcl_Close(NULL, FilePtr);//fclose (FilePtr);
        FilePtr = NULL;
        return ERROR_BadMagic;
    }

#else

    if ((FilePtr = fopen (fname, "rb")) == NULL) {
        return ERROR_FileOpen;
    }

    readString (FilePtr, Header.magic, 8);
    if (strcmp (Header.magic, NAMEBASE_MAGIC) != 0) {
        fclose (FilePtr);
        FilePtr = NULL;
        return ERROR_BadMagic;
    }
#endif
    Header.timeStamp = readFourBytes (FilePtr);
    Header.numNames[NAME_PLAYER] = readThreeBytes (FilePtr);
    Header.numNames[NAME_EVENT] = readThreeBytes (FilePtr);
    Header.numNames[NAME_SITE] = readThreeBytes (FilePtr);
    Header.numNames[NAME_ROUND] = readThreeBytes (FilePtr);
    Header.maxFrequency[NAME_PLAYER] = readThreeBytes (FilePtr);
    Header.maxFrequency[NAME_EVENT] = readThreeBytes (FilePtr);
    Header.maxFrequency[NAME_SITE] = readThreeBytes (FilePtr);
    Header.maxFrequency[NAME_ROUND] = readThreeBytes (FilePtr);
    return OK;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NameBase::CloseNameFile():
//      Closes an open namebase file.
//
errorT
NameBase::CloseNameFile ()
{
    ASSERT (FilePtr != NULL);   // check FilePtr points to an open file
#ifdef WINCE
    my_Tcl_Close(NULL, FilePtr);
#else
    fclose (FilePtr);
#endif
    FilePtr = NULL;
    return OK;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NameBase::ReadNameFile():
//      Reads the entire name file into memory.
//
errorT
NameBase::ReadNameFile (const char * suffix)
{
    // The arrays should be clear when ReadNameFile() is called.
    ASSERT (ArraySize[NAME_PLAYER] == 0  &&  ArraySize[NAME_EVENT] == 0
        &&  ArraySize[NAME_SITE] == 0    &&  ArraySize[NAME_ROUND] == 0);

    const idNumberT incr = 10;  // extra entries at end of each array
    errorT err = OpenNameFile (suffix);
    if (err != OK) {
        return err;
    }

    // Allocate array space. We add space for INCR empty entries at the
    // end of each array for possible added names, for efficiency.
    //
    err = IncArraySize(NAME_PLAYER, Header.numNames[NAME_PLAYER] + incr);
    if (err != OK)  { return err; }
    err = IncArraySize(NAME_EVENT, Header.numNames[NAME_EVENT] + incr);
    if (err != OK)  { return err; }
    err = IncArraySize(NAME_SITE, Header.numNames[NAME_SITE] + incr);
    if (err != OK)  { return err; }
    err = IncArraySize(NAME_ROUND, Header.numNames[NAME_ROUND] + incr);
    if (err != OK)  { return err; }

    for (nameT nt = NAME_PLAYER; nt < NUM_NAME_TYPES; nt++) {
        idNumberT id;
        uint frequency;
        Header.numBytes[nt] = 0;
        nameNodeT * node = NULL;
        nameNodeT * prevNode = NULL;

        for (idNumberT i = 0; i < Header.numNames[nt]; i++) {
            if (Header.numNames[nt] >= 65536) {
                id = readThreeBytes(FilePtr);
                Header.numBytes[nt] += 3;
            } else {
                id = readTwoBytes(FilePtr);
                Header.numBytes[nt] += 2;
            }

            // Frequencies can be stored in 1, 2 or 3 bytes:
            if (Header.maxFrequency[nt] >= 65536) {
                frequency = readThreeBytes(FilePtr);
                Header.numBytes[nt] += 3;
            } else if (Header.maxFrequency[nt] >= 256) {
                frequency = readTwoBytes(FilePtr);
                Header.numBytes[nt] += 2;
            } else {  // Frequencies all <= 255: fit in one byte
                frequency = (uint) readOneByte(FilePtr);
                Header.numBytes[nt] += 1;
            }

            // Read the name string. All strings EXCEPT the first are
            // front-coded.
            uint length = (uint) readOneByte(FilePtr);
            Header.numBytes[nt]++;
            uint prefix = 0;
            char name [256];
            char * nameStr = name;
            if (i > 0) {
                prefix = (uint) readOneByte(FilePtr);
                Header.numBytes[nt]++;
                char * prevNameStr = prevNode->name;
                for (uint temp=0; temp < prefix; temp++) {
                    // Copy the prefix from the previous string;
                    *nameStr++ = *prevNameStr++;
                }
            }
            readString (FilePtr, nameStr, (length - prefix));
            nameStr += length - prefix;
            Header.numBytes[nt] += length - prefix;
            *nameStr = 0;  // Add trailing '\0'.
            // Now add to the StrTree:
            if (Tree[nt]->AddLast (name, &node) != OK) {
                //fprintf (stderr, "CORRUPT name: %s\n", name);
#ifdef WINCE
                my_Tcl_Close(NULL, FilePtr);
#else
                fclose (FilePtr);
#endif
                return ERROR_Corrupt;
            }
            node->data.id = id;
            node->data.frequency = frequency;
            node->data.maxElo = 0;
            node->data.firstDate = ZERO_DATE;
            node->data.lastDate = ZERO_DATE;
            node->data.country[0] = 0;
            node->data.hasPhoto = false;
            if (frequency == Header.maxFrequency[nt]) {
                MostFrequent[nt] = node;
            }
            prevNode = node;
            NameByID[nt][id] = node;
        }

        ASSERT (Header.numNames[nt] == Tree[nt]->Size());
        Tree[nt]->Rebalance();
    }

#ifdef WINCE
    my_Tcl_Close(NULL, FilePtr);
#else
    fclose (FilePtr);
#endif
    FilePtr = NULL;
    return OK;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NameBase::WriteNameFile(): Write the entire in-memory index to disk.
//      For each nametype, names are written in alphabetical order and
//      the strings are front-coded to save space.
//
errorT
NameBase::WriteNameFile ()
{
    ASSERT (FilePtr == NULL);  // Should not already have an open file.

    fileNameT fname;
    strcpy (fname, Fname);
    strcat (fname, NAMEBASE_SUFFIX);
#ifdef WINCE
//    if ((FilePtr = fopen (fname, "wb")) == NULL) {
    if ((FilePtr = my_Tcl_OpenFileChannel(NULL, fname, "w", 0666)) == 0) {
        return ERROR_FileOpen;
    }
 my_Tcl_SetChannelOption(NULL, FilePtr, "-encoding", "binary");
 my_Tcl_SetChannelOption(NULL, FilePtr, "-translation", "binary");

#else
    if ((FilePtr = fopen (fname, "wb")) == NULL) {
        return ERROR_FileOpen;
    }
#endif
    WriteHeader ();

    for (nameT nt = NAME_PLAYER; nt < NUM_NAME_TYPES; nt++) {
        nameNodeT * node = NULL;
        nameNodeT * prevNode = NULL;
        Tree[nt]->IterateStart();

        for (idNumberT i = 0; i < Header.numNames[nt]; i++) {
            prevNode = node;
            node = Tree[nt]->Iterate();
            ASSERT (node != NULL);

            // write idNumber in 2 bytes if possible, otherwise 3.
            if (Header.numNames[nt] >= 65536) {
                writeThreeBytes (FilePtr, node->data.id);
            } else {
                writeTwoBytes (FilePtr, node->data.id);
            }

            // write frequency in 1 or 2 bytes if possible, otherwise 3.
            if (Header.maxFrequency[nt] >= 65536) {
                writeThreeBytes (FilePtr, node->data.frequency);
            } else if (Header.maxFrequency[nt] >= 256) {
                writeTwoBytes (FilePtr, node->data.frequency);
            } else {
                writeOneByte (FilePtr, (byte) node->data.frequency);
            }
            byte length = (byte) strLength(node->name);
            byte prefix = 0;
            writeOneByte (FilePtr, length);
            if (i > 0) {
                prefix = (byte) strPrefix (node->name, prevNode->name);
                writeOneByte (FilePtr, prefix);
            }
            writeString (FilePtr, &(node->name[prefix]), (length - prefix));
        }
    }
#ifdef WINCE
    my_Tcl_Close(NULL, FilePtr);
#else
    fclose (FilePtr);
#endif
    FilePtr = NULL;
    return OK;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NameBase::IncArraySize():
//      Increment the size of a NameByID array.
//
errorT
NameBase::IncArraySize (nameT nt, idNumberT increment)
{
    ASSERT (IsValidNameType(nt));
    idNumberT newSize = ArraySize[nt] + increment;
#ifdef WINCE
    nameNodeT ** newID = (nameNodeT **)my_Tcl_Alloc( sizeof(nameNodePtrT [newSize]));
#else
    nameNodeT ** newID = new nameNodePtrT [newSize];
#endif
    if (ArraySize[nt] > 0) {  // copy old arrays into new then delete old
        for (uint i = 0; i < ArraySize[nt]; i++) {
            newID[i] = NameByID[nt][i];
        }
#ifdef WINCE
        my_Tcl_Free((char *)NameByID[nt]);
#else
        delete[] NameByID[nt];
#endif
    }
    NameByID[nt] = newID;
    ArraySize[nt] = newSize;
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NameBase::FindExactName():
//      Finds an exact full, case-sensitive name.
//      Returns OK or ERROR_NotFound.
//
errorT
NameBase::FindExactName (nameT nt, const char * str, idNumberT * idPtr)
{
    ASSERT (IsValidNameType(nt)  &&  str != NULL  &&  idPtr != NULL);
    nameNodeT * node = Tree[nt]->Lookup (str);
    if (node == NULL) {
        return ERROR_NameNotFound;
    } else {
        *idPtr = node->data.id;
        return OK;
    }
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NameBase::AddName(): Add a name to a namebase. If it already
//      exists, OK is returned.
//
errorT
NameBase::AddName (nameT nt, const char * str, idNumberT * idPtr)
{
    ASSERT (IsValidNameType(nt)  &&  str != NULL  &&  idPtr != NULL);
    errorT err;
    if (Header.numNames[nt] >= NAME_MAX_ID[nt]) {
        return ERROR_NameBaseFull;   // Too many names already.
    }
    const idNumberT NAMEBASE_INC = 1000;

    if (Header.numNames[nt] == ArraySize[nt]) {
        // We have to increment our arrays for this nametype.
        if ((err = IncArraySize(nt, NAMEBASE_INC)) != OK) {
            return err;  // allocation error increasing array size.
        }
    }

    nameNodeT * node = NULL;
    err = Tree[nt]->Insert (str, &node);
    if (err != ERROR_Exists) {
        // Set data for the new node:
        node->data.id = Header.numNames[nt];
        node->data.frequency = 0;
        node->data.maxElo = 0;
        node->data.firstDate = ZERO_DATE;
        node->data.lastDate = ZERO_DATE;
        node->data.country[0] = 0;
        node->data.hasPhoto = false;
        NameByID[nt][node->data.id] = node;
        Header.numNames[nt]++;
    }
    *idPtr = node->data.id;

    // Rebalance tree if it is too far out of balance:
    if (Tree[nt]->Height() > 30) {
        Tree[nt]->Rebalance();
    }
    return OK;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NameBase::GetMatches(): Get the first few matches of a name prefix.
//      The parameter maxMatches indicates the size of the idNumber array.
//      The first maxMatches matching IDs are placed in the array.
//      Returns: the number found, up which will be <= maxMatches.
//
uint
NameBase::GetFirstMatches (nameT nt, const char * str, uint maxMatches,
                           idNumberT * array)
{
    ASSERT (IsValidNameType(nt)  &&  str != NULL);
    uint matches = 0;
    if (maxMatches > 0) {
#ifdef WINCE
        nameNodePtrT * nodeArray = (nameNodePtrT *)my_Tcl_Alloc(sizeof( nameNodePtrT [maxMatches]));
#else
        nameNodePtrT * nodeArray = new nameNodePtrT [maxMatches];
#endif
        matches = Tree[nt]->GetFirstMatches (str, maxMatches, nodeArray);
        for (uint i=0; i < matches; i++) {
            array[i] = nodeArray[i]->data.id;
        }
#ifdef WINCE
        my_Tcl_Free((char*) nodeArray);
#else
        delete[] nodeArray;
#endif
    }
    return matches;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NameBase::DumpAllNames(): dump all names to open file
//
uint
#ifdef WINCE
NameBase::DumpAllNames (nameT nt, const char * prefixStr, /*FILE **/Tcl_Channel f)
#else
NameBase::DumpAllNames (nameT nt, const char * prefixStr, FILE * f)
#endif
{
    ASSERT (IsValidNameType(nt)  &&  f != NULL  &&  prefixStr != NULL);

    uint numMatches = 0;
    int prefixLen = strlen (prefixStr);
    nameNodeT * node;
    Tree[nt]->IterateStart();
#ifdef WINCE
    char buf[1024];
    while ((node = Tree[nt]->Iterate()) != NULL) {
        if (!strncmp (prefixStr, node->name, prefixLen)) {
            sprintf (buf, "%6d\t%s\n", node->data.frequency, node->name);
            my_Tcl_Write(f, buf, strlen(buf));
#else
    while ((node = Tree[nt]->Iterate()) != NULL) {
        if (!strncmp (prefixStr, node->name, prefixLen)) {
            fprintf (f, "%6d\t%s\n", node->data.frequency, node->name);
#endif
            numMatches++;
        }
    }
    return numMatches;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NameBase::TreeHeight(): Return the height of a name tree.
//
uint
NameBase::TreeHeight (nameT nt)
{
    ASSERT (IsValidNameType(nt));
    return Tree[nt]->Height();
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NameBase::NameTypeFromString
//    Returns a valid nameT given a string, or NAME_INVALID.
//    To match, the string should be a prefix of "player", "event",
//    "site" or "round", or be a superstring of it, e.g. "player ...."
nameT
NameBase::NameTypeFromString (const char * str)
{
    if (*str == '\0') { return NAME_INVALID; }
    if (strIsAlphaPrefix (str, "player")) { return NAME_PLAYER; }
    if (strIsAlphaPrefix (str, "event"))  { return NAME_EVENT;  }
    if (strIsAlphaPrefix (str, "site"))   { return NAME_SITE;   }
    if (strIsAlphaPrefix (str, "round"))  { return NAME_ROUND;  }
    if (strIsAlphaPrefix ("player", str)) { return NAME_PLAYER; }
    if (strIsAlphaPrefix ("event", str))  { return NAME_EVENT;  }
    if (strIsAlphaPrefix ("site", str))   { return NAME_SITE;   }
    if (strIsAlphaPrefix ("round", str))  { return NAME_ROUND;  }
    return NAME_INVALID;
}

// Update estimated ratings from spellcheck file if available:
void NameBase::recalcEstimatedRatings (SpellChecker* spellChecker)
{
    if (spellChecker == 0) { return; }
    for (idNumberT id=0; id < GetNumNames(NAME_PLAYER); id++) {
        if (GetElo(id) == 0  &&  GetFrequency(NAME_PLAYER, id) > 0) {
            const char * name = GetName (NAME_PLAYER, id);
            if (! strIsSurnameOnly (name)) {
                const char * text = spellChecker->GetCommentExact (name);
                if (text != NULL) {
                    SetElo (id, SpellChecker::GetPeakRating (text));
                }
            }
        }
    }
}


//////////////////////////////////////////////////////////////////////
//  EOF: namebase.cpp
//////////////////////////////////////////////////////////////////////
