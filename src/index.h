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

#ifndef SCID_INDEX_H
#define SCID_INDEX_H

#include "common.h"
#include "containers.h"
#include "date.h"
#include "indexentry.h"
#include "filebuf.h"
#include "hfilter.h"
#include <array>
#include <string>
#include <vector>
#include <cstring>

class NameBase;

//////////////////////////////////////////////////////////////////////
//  Index:  Constants

const char         INDEX_SUFFIX[]     = ".si4";
const char         OLD_INDEX_SUFFIX[] = ".si3";

// Descriptions can be up to 107 bytes long.
const uint  SCID_DESC_LENGTH = 107;
const uint  CUSTOM_FLAG_DESC_LENGTH = 8;
const uint  CUSTOM_FLAG_MAX = 6;

// Header on-disk size: magic=8, version=2, numGames=3, baseType=4, autoLoad=3
// Description length = 111 bytes including trailing '\0'.
// Custom flag desc length = 9 bytes including trailing '\0'.
// So total is 128 bytes + 9*6 = 182 bytes for the whole header.
const uint  INDEX_HEADER_SIZE = 8 + 2 + 3 + 4 + 3 + SCID_DESC_LENGTH + 1 + (CUSTOM_FLAG_DESC_LENGTH+1) * CUSTOM_FLAG_MAX;
const uint  OLD_INDEX_HEADER_SIZE = INDEX_HEADER_SIZE - (CUSTOM_FLAG_DESC_LENGTH+1) * CUSTOM_FLAG_MAX;

//////////////////////////////////////////////////////////////////////
//  Index:  Class Definition

class Index
{
private:
    // The complete index will be loaded in memory and can be pretty huge.
    // To avoid the slow reallocation when adding games we split the data in chunks.
    // CHUNKSHIFT is the base-2 logarithm of the number of index entries allocated as one chunk.
    // i.e 16 = 2^16 = 65536 (total size of one chunk: 65536*48 = 3MB)
    VectorChunked<IndexEntry, 16> entries_; // A two-level array of the entire index.
    Filebuf*     FilePtr;       // filehandle for opened index file.
    fileModeT    fileMode_;     // Mode: e.g. FILE_WRITEONLY
    int nInvalidNameId_;
    gamenumT seqWrite_;

    struct { // one at the start of the index file.
        versionT    version;     // version number. 2 bytes.
        uint        baseType;    // Type, e.g. tournament, theory, etc.
        gamenumT    numGames;    // number of games in file.
        gamenumT    autoLoad;    // game number to autoload: 0=none, 1=1st, >numGames=last
        // description is a fixed-length string describing the database.
        char        description [SCID_DESC_LENGTH + 1];
        // short description (8 chars) for the CUSTOM_FLAG_MAX bits for CUSTOM flags
        char        customFlagDesc [CUSTOM_FLAG_MAX][CUSTOM_FLAG_DESC_LENGTH+1] ;
        bool        dirty_;      // If true, Header needs rewriting to disk.
    } Header;

    friend class CodecSCID4;
    friend class CodecMemory;

public:
    Index()  { Init(); }
    Index(const Index&);
    Index& operator=(const Index&);
    ~Index() { Clear(); }

    errorT Open(const char* filename, fileModeT fmode);
    errorT Create(const char* filename);
    errorT Close() { return Clear(); }

    const IndexEntry* GetEntry (gamenumT g) const {
        ASSERT(g < GetNumGames());
        return &(entries_[g]);
    }

    /**
     * GetBadNameIdCount() - return the number of invalid name handles.
     *
     * To save space, avoiding duplicates, the index keep handles
     * to strings stored in the namebase file.
     * If one of the two files is corrupted, the index may have
     * handles to strings that do not exists.
     * This functions returns the number of invalid name handles.
     */
    int GetBadNameIdCount() const { return nInvalidNameId_; }

    /**
     * Counts how many times every names contained in @e nb is used.
     * @param nb: the NameBase linked to this Index
     * @returns an array of std::vectors containing the count of each name.
     */
    std::array<std::vector<int>, NUM_NAME_TYPES>
    calcNameFreq(const NameBase& nb) const {
        std::array<std::vector<int>, NUM_NAME_TYPES> resVec;
        for (nameT n = NAME_PLAYER; n < NUM_NAME_TYPES; n++) {
            resVec[n].resize(nb.GetNumNames(n), 0);
        }
        for (gamenumT i = 0, n = GetNumGames(); i < n; i++) {
            const IndexEntry* ie = GetEntry(i);
            resVec[NAME_PLAYER][ie->GetWhite()] += 1;
            resVec[NAME_PLAYER][ie->GetBlack()] += 1;
            resVec[NAME_EVENT][ie->GetEvent()] += 1;
            resVec[NAME_SITE][ie->GetSite()] += 1;
            resVec[NAME_ROUND][ie->GetRound()] += 1;
        }
        return resVec;
    }

    /**
     * Header getter functions
     */
    gamenumT    GetNumGames ()    const { return Header.numGames; }
    versionT    GetVersion ()     const { return Header.version; }

    /**
     * WriteEntry() - modify a game in the Index
     */
    errorT WriteEntry(const IndexEntry* ie, gamenumT idx);

    /**
     * flush() - writes all cached data to the file
     */
    errorT flush() {
        if (FilePtr == 0) return OK;
        errorT errHeader = (Header.dirty_) ? WriteHeader() : OK;
        errorT errSync = (FilePtr->pubsync() != 0) ? ERROR_FileWrite : OK;
        return (errHeader == OK) ? errSync : errHeader;
    }

private:
    void Init ();
    errorT Clear ();
    errorT WriteHeader ();
};


#endif  // #ifdef SCID_INDEX_H

//////////////////////////////////////////////////////////////////////
//  EOF: index.h
//////////////////////////////////////////////////////////////////////

