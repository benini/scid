/*
* Copyright (c) 2001  Shane Hudson.
* Copyright (C) 2014  Fulvio Benini

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
#include "date.h"
#include "misc.h"
#include <string.h>
#include <vector>
#include <map>

class SpellChecker;


// There are four NameBases, one each for PLAYER, EVENT , SITE and ROUND tags.
const nameT
    NAME_PLAYER = 0,  NAME_EVENT = 1,  NAME_SITE = 2, NAME_ROUND = 3,
    NAME_FIRST = 0, NAME_LAST = 3, NAME_INVALID = 99;

const uint NUM_NAME_TYPES = 4;

const char NAME_TYPE_STRING [NUM_NAME_TYPES][8] = {
    "player",
    "event",
    "site",
    "round"
};


// The NAME_MAX_ID[] array stores the maximum number of names allowed
// in a database for each name type.
const uint NAME_MAX_ID [NUM_NAME_TYPES] = { 
    1048575,    /* Player names: Maximum of 2^20 -1 = 1,048,575 */
     524287,    /* Event names:  Maximum of 2^19 -1 =   524,287 */
     524287,    /* Site names:   Maximum of 2^19 -1 =   524,287 */
     262143     /* Round names:  Maximum of 2^18 -1 =   262,143 */
};

const char NAMEBASE_SUFFIX[] = ".sn4";

//////////////////////////////////////////////////////////////////////
//  NameBase:  Class definition
class NameBase
{
    fileNameT Fname_;
    std::vector<const char*> names_[NUM_NAME_TYPES];
    std::vector<eloT> eloV_;
    std::vector<dateT> firstDateV_;
    std::vector<dateT> lastDateV_;
    struct idxCmp {
        bool operator() (const char* str1, const char* str2) const {
            // Compatibility: strCompare_INLINE is not consistent with strcmp
            return strCompare_INLINE(str1, str2) < 0;
        }
    };
    std::map<const char*, idNumberT, idxCmp> idx_[NUM_NAME_TYPES];

    NameBase(const NameBase&);
    NameBase& operator=(const NameBase&);
    void Init();
    void SetFileName (const char *s) { strcpy(Fname_,s); strcat(Fname_, NAMEBASE_SUFFIX); }

public:
    static bool IsValidNameType (nameT nt) { return (nt < NUM_NAME_TYPES); }
    static nameT NameTypeFromString (const char * str);

    NameBase()  { Init(); }
    ~NameBase();
    void Clear() { Init(); }
    void recalcEstimatedRatings (SpellChecker* nb);

    errorT    Create (const char* filename);
    errorT    ReadEntireFile (const char* filename);
    errorT    WriteNameFile (const std::vector<int>* freq);

    const char* GetName (nameT nt, idNumberT id) const { return names_[nt][id]; }
    eloT GetElo (idNumberT id) const { return eloV_[id]; }
    dateT GetFirstDate (idNumberT id) const { return firstDateV_[id]; }
    dateT GetLastDate (idNumberT id) const { return lastDateV_[id]; }

    errorT AddName (nameT nt, const char * str, idNumberT * idPtr);
    void AddElo (idNumberT id, eloT elo) { if (elo > eloV_[id]) eloV_[id] = elo; }
    void AddDate (idNumberT id, dateT date) {
        dateT fDate = firstDateV_[id];
        if (fDate == ZERO_DATE || date < fDate) firstDateV_[id] = date;
        if (date > lastDateV_[id]) lastDateV_[id] = date;
    }

    errorT    FindExactName   (nameT nt, const char * str, idNumberT * idPtr);
    uint      GetFirstMatches (nameT nt, const char * str, uint maxMatches,
                               idNumberT * array);

    idNumberT GetNumNames (nameT n)  { return names_[n].size(); }

    typedef std::map<const char*, idNumberT, idxCmp>::const_iterator iterator;
    iterator begin(nameT nt) { return idx_[nt].begin(); }
    iterator end(nameT nt) { return idx_[nt].end(); }
};

#endif  // #ifdef SCID_NAMEBASE_H

//////////////////////////////////////////////////////////////////////
//  EOF: namebase.h
//////////////////////////////////////////////////////////////////////

