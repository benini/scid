/*
* Copyright (c) 2001  Shane Hudson.
* Copyright (C) 2014-2017 Fulvio Benini

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
#include <algorithm>

class Index;

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
            // *** Compatibility ***
            // Older code used a custom StrTree class with a peculiar sorting:
            // - the first char was interpreted as an unsigned char;
            // - the remaining part was compared with the function strComapare(),
            //   which converts the chars to ints, and is not consistent with
            //   the standard function strcmp().
            // The old StrTree class did also have unpredictable behaviors when
            // fed with names not sorted according to that criteria, for example
            // it could create Namebase objects with duplicate entries.
            // ***
            if (*str1 == *str2)
                return strCompare(str1, str2) < 0;

            return static_cast<uint>(*str1) < static_cast<uint>(*str2);
        }
    };
    std::map<const char*, idNumberT, idxCmp> idx_[NUM_NAME_TYPES];
    bool modified_;

public:
    static bool IsValidNameType (nameT nt) { return (nt < NUM_NAME_TYPES); }
    static nameT NameTypeFromString (const char * str);
    static const char* Suffix() { return NAMEBASE_SUFFIX; }

    NameBase() : modified_(false) {}
    ~NameBase() { Clear(); }
    void Clear();

    errorT    Create (const char* filename);
    errorT    ReadEntireFile (const char* filename);
    errorT flush(const Index* idx) {
        errorT err = OK;
        if (modified_ && !filename_.empty()) err = WriteNameFile(idx);
        if (err == OK) modified_ = false;
        return err;
    }
    void hackedNameFreq() { modified_ = true; }

    const char* GetName (nameT nt, idNumberT id) const { return names_[nt][id]; }
    eloT GetElo (idNumberT id) const { return eloV_[id]; }

    errorT AddName (nameT nt, const char * str, idNumberT * idPtr);
    void AddElo (idNumberT id, eloT elo) { if (elo > eloV_[id]) eloV_[id] = elo; }

    errorT    FindExactName   (nameT nt, const char * str, idNumberT * idPtr) const;
    uint      GetFirstMatches (nameT nt, const char * str, uint maxMatches,
                               idNumberT * array) const;

    idNumberT GetNumNames (nameT n) const  { return names_[n].size(); }

    std::vector<uint32_t> generateHashMap(nameT nt) const {
        std::vector<uint32_t> res(names_[nt].size());
        std::transform(names_[nt].begin(), names_[nt].end(), res.begin(),
                       strStartHash);
        return res;
    }

private:
    typedef std::map<const char*, idNumberT, idxCmp>::const_iterator iterator;

    NameBase(const NameBase&);
    NameBase& operator=(const NameBase&);
    bool setFileName(const char* filename);
    errorT WriteNameFile(const Index* idx);
};

#endif  // #ifdef SCID_NAMEBASE_H

//////////////////////////////////////////////////////////////////////
//  EOF: namebase.h
//////////////////////////////////////////////////////////////////////

