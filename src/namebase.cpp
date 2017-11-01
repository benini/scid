/*
* Copyright (c) 2001  Shane Hudson.
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

#include "common.h"
#include "namebase.h"
#include "misc.h"
#include "filebuf.h"
#include "index.h"


/**
* NameBase::clear() - clears file associations and frees memory
*
* Clears file associations and frees memory, leaving the object empty.
*/
void NameBase::Clear()
{
    for (nameT n = NAME_PLAYER; n < NUM_NAME_TYPES; n++) {
        for (size_t i=0; i < names_[n].size(); i++) delete [] names_[n][i];
        names_[n].resize(0);
        idx_[n].clear();
    }
    eloV_.resize(0);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NameBase::FindExactName():
//      Finds an exact full, case-sensitive name.
//      Returns OK or ERROR_NotFound.
//
errorT
NameBase::FindExactName (nameT nt, const char* str, idNumberT* idPtr) const
{
    ASSERT (IsValidNameType(nt)  &&  str != NULL  &&  idPtr != NULL);

    auto it = idx_[nt].find(str);
    if (it != idx_[nt].end()) {
        *idPtr = (*it).second;
        return OK;
    }
    return ERROR_NameNotFound;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// NameBase::GetMatches(): Get the first few matches of a name prefix.
//      The parameter maxMatches indicates the size of the idNumber array.
//      The first maxMatches matching IDs are placed in the array.
//      Returns: the number found, up which will be <= maxMatches.
//
uint
NameBase::GetFirstMatches (nameT nt, const char * str, uint maxMatches,
                           idNumberT * array) const
{
    ASSERT (IsValidNameType(nt)  &&  str != NULL);

    size_t len = strlen(str);
    uint matches = 0;
    auto it = idx_[nt].lower_bound(str);
    for (; matches < maxMatches && it != idx_[nt].end(); matches++) {
        const char* s = (*it).first;
        if (strlen(s) < len || strncmp(s, str, len) != 0) break;
        array[matches] = (*it++).second;
    }

    return matches;
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

//////////////////////////////////////////////////////////////////////
//  EOF: namebase.cpp
//////////////////////////////////////////////////////////////////////
