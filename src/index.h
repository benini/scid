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
#include "indexentry.h"
#include <string>
#include <vector>


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
    int nInvalidNameId_;

    friend class CodecSCID4;

public:
    Index()  { Init(); }

    void Close() { Init(); }

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
     * Header getter functions
     */
    gamenumT GetNumGames() const {
        return static_cast<gamenumT>(entries_.size());
    }

    void addEntry(const IndexEntry& ie) {
        entries_.push_back(ie);
    }

    void replaceEntry(const IndexEntry& ie, gamenumT replaced) {
        ASSERT(replaced < this->GetNumGames());

        entries_[replaced] = ie;
    }

private:
    void Init() {
        nInvalidNameId_ = 0;
        entries_.resize(0);
    }
};


#endif  // #ifdef SCID_INDEX_H

//////////////////////////////////////////////////////////////////////
//  EOF: index.h
//////////////////////////////////////////////////////////////////////

