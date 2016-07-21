/*
* Copyright (c) 2001  Shane Hudson.
* Copyright (C) 2014-2016 Fulvio Benini

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

#ifndef SCID_NAMEBASE_H
#define SCID_NAMEBASE_H

#include "common.h"
#include "misc.h"
#include <vector>
#include <map>

// There are four NameBases, one each for PLAYER, EVENT , SITE and ROUND tags.
typedef uint nameT;
enum {
    NAME_PLAYER, NAME_EVENT, NAME_SITE, NAME_ROUND,
    NUM_NAME_TYPES,
    NAME_INVALID = 99
};

typedef uint idNumberT;

const char NAME_TYPE_STRING [NUM_NAME_TYPES][8] = {
    "player",
    "event",
    "site",
    "round"
};


class NameBase
{
    static const char* NAMEBASE_MAGIC;
    static const char* NAMEBASE_SUFFIX;

    std::string filename_;
    std::vector<const char*> names_[NUM_NAME_TYPES];
    std::vector<eloT> eloV_;
    struct idxCmp {
        bool operator() (const char* str1, const char* str2) const {
            // Compatibility: strCompare_INLINE is not consistent with strcmp
            return strCompare_INLINE(str1, str2) < 0;
        }
    };
    std::map<const char*, idNumberT, idxCmp> idx_[NUM_NAME_TYPES];

public:
    static bool IsValidNameType (nameT nt) { return (nt < NUM_NAME_TYPES); }
    static nameT NameTypeFromString (const char * str);
    static const char* Suffix() { return NAMEBASE_SUFFIX; }

    NameBase() {}
    ~NameBase() { Clear(); }
    void Clear();

    errorT    Create (const char* filename);
    errorT    ReadEntireFile (const char* filename);
    errorT    WriteNameFile (const std::vector<int>* freq);

    const char* GetName (nameT nt, idNumberT id) const { return names_[nt][id]; }
    eloT GetElo (idNumberT id) const { return eloV_[id]; }

    errorT AddName (nameT nt, const char * str, idNumberT * idPtr);
    void AddElo (idNumberT id, eloT elo) { if (elo > eloV_[id]) eloV_[id] = elo; }

    errorT    FindExactName   (nameT nt, const char * str, idNumberT * idPtr) const;
    uint      GetFirstMatches (nameT nt, const char * str, uint maxMatches,
                               idNumberT * array) const;

    idNumberT GetNumNames (nameT n) const  { return names_[n].size(); }

private:
    typedef std::map<const char*, idNumberT, idxCmp>::const_iterator iterator;

    NameBase(const NameBase&);
    NameBase& operator=(const NameBase&);
    bool setFileName(const char* filename);
};

#endif  // #ifdef SCID_NAMEBASE_H

//////////////////////////////////////////////////////////////////////
//  EOF: namebase.h
//////////////////////////////////////////////////////////////////////

