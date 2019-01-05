/*
* Copyright (c) 1999-2002  Shane Hudson
* Copyright (c) 2006-2009  Pascal Georges
* Copyright (C) 2014-2016  Fulvio Benini

* This file is part of Scid (Shane's Chess Information Database).
*
* Scid is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation.
*
* Scid is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Scid.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "index.h"
#include "namebase.h"
#include <cstring>

static constexpr char INDEX_MAGIC[8] = "Scid.si";

void Index::Init ()
{
    Header.numGames  = 0;
    Header.version   = SCID_VERSION;
    Header.baseType = 0;
    Header.autoLoad = 1;
    Header.description[0] = 0;
    std::memset(Header.customFlagDesc, 0, sizeof(Header.customFlagDesc));
    Header.dirty_ = false;
    FilePtr = NULL;
    fileMode_ = FMODE_Memory;
    nInvalidNameId_ = 0;
    seqWrite_ = 0;
    entries_.resize(0);
}

errorT Index::Clear ()
{
    errorT res = flush();
    delete FilePtr;
    Init();
    return res;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Index::CreateIndexFile():
//      Creates and opens a new empty index file.
//
errorT
Index::Create(const char* filename)
{
    ASSERT(filename != 0);

    Clear();
    FilePtr = new Filebuf;
    std::string fname = filename;
    fname += INDEX_SUFFIX;
    //Check that the file does not exists and then create it
    if (FilePtr->Open(fname.c_str(), FMODE_ReadOnly) == OK ||
        FilePtr->Open(fname.c_str(), FMODE_Create) != OK) {
        delete FilePtr;
        FilePtr = NULL;
        return ERROR_FileOpen;
    }
    fileMode_ = FMODE_Both;
    return WriteHeader();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Index::Open():
//      Open an index file and read the header.
//
errorT
Index::Open (const char* filename, fileModeT fmode)
{
    ASSERT(filename != 0);

    Clear();
    if (fmode == FMODE_WriteOnly) return ERROR_FileMode;
    FilePtr = new Filebuf;
    std::string fname = filename;
    fname += INDEX_SUFFIX;

    if (FilePtr->Open (fname.c_str(), fmode) != OK) {
        delete FilePtr;
        FilePtr = NULL;
        return ERROR_FileOpen;
    }

    char magic[8];
    FilePtr->sgetn(magic, 8);
    if (!std::equal(std::begin(magic), std::end(magic), std::begin(INDEX_MAGIC),
                    std::end(INDEX_MAGIC))) {
        delete FilePtr;
        FilePtr = NULL;
        return ERROR_BadMagic;
    }

    Header.version = FilePtr->ReadTwoBytes ();
    if (Header.version < SCID_OLDEST_VERSION || Header.version > SCID_VERSION) {
        delete FilePtr;
        FilePtr = NULL;
        return ERROR_FileVersion;
    }
    if (Header.version != SCID_VERSION && fmode != FMODE_ReadOnly) {
        //Old versions must be opened readonly
        delete FilePtr;
        FilePtr = NULL;
        return ERROR_FileMode;
    }

    Header.baseType = FilePtr->ReadFourBytes ();
    Header.numGames = FilePtr->ReadThreeBytes ();
    Header.autoLoad = FilePtr->ReadThreeBytes ();
    FilePtr->sgetn(Header.description, SCID_DESC_LENGTH + 1);
    Header.description[SCID_DESC_LENGTH] = 0;
    if (Header.version >= 400) {
        for (uint i = 0 ; i < CUSTOM_FLAG_MAX ; i++ ) {
            FilePtr->sgetn(Header.customFlagDesc[i], CUSTOM_FLAG_DESC_LENGTH + 1);
            Header.customFlagDesc[i][CUSTOM_FLAG_DESC_LENGTH] = 0;
        }
    } 

    fileMode_ = fmode;
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Index::WriteHeader():
//      Write the header to the open index file.
//
errorT
Index::WriteHeader ()
{
    ASSERT(FilePtr != NULL);
    if (FilePtr->pubseekpos(0) != std::streampos(0)) return ERROR_FileWrite;

    seqWrite_ = 0;
    std::streamsize n = 0;
    n += FilePtr->sputn(INDEX_MAGIC, 8);
    n += FilePtr->WriteTwoBytes (Header.version);
    n += FilePtr->WriteFourBytes (Header.baseType);
    n += FilePtr->WriteThreeBytes (Header.numGames);
    n += FilePtr->WriteThreeBytes (Header.autoLoad);
    n += FilePtr->sputn(Header.description, SCID_DESC_LENGTH + 1);
    for (size_t i = 0 ; i < CUSTOM_FLAG_MAX ; i++ ) {
        n += FilePtr->sputn(Header.customFlagDesc[i], CUSTOM_FLAG_DESC_LENGTH + 1);
    }
    if (n != INDEX_HEADER_SIZE || FilePtr->pubsync() == -1) return ERROR_FileWrite;
    Header.dirty_ = false;
    return OK;
}

errorT Index::WriteEntry(const IndexEntry* ie, gamenumT idx)
{
    if (idx > Header.numGames) return ERROR_BadArg;
    if (fileMode_ == FMODE_ReadOnly) { return ERROR_FileMode; }

    if (idx == Header.numGames) {
        entries_.push_back(*ie);
        Header.numGames++;
        Header.dirty_ = true;
    } else {
        IndexEntry* copyToMemory = &(entries_[idx]);
        *copyToMemory = *ie;
    }
    if (FilePtr == NULL) return OK;

    if ((seqWrite_ == 0) || (idx != seqWrite_ + 1)) {
        std::streampos pos = INDEX_ENTRY_SIZE * idx + INDEX_HEADER_SIZE;
        if (FilePtr->pubseekpos(pos) != pos) {
            seqWrite_ = 0;
            return ERROR_FileWrite;
        }
    }
    errorT res = ie->Write (FilePtr, Header.version);
    seqWrite_ = (res == OK) ? idx : 0;
    return res;
}

//////////////////////////////////////////////////////////////////////
//  EOF: index.cpp
//////////////////////////////////////////////////////////////////////

