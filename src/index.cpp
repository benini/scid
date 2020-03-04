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
    fileMode_ = FMODE_None;
    nInvalidNameId_ = 0;
    seqWrite_ = 0;
    entries_.resize(0);
}

errorT Index::Clear ()
{
    delete FilePtr;
    Init();
    return OK;
}

errorT Index::WriteEntry(const IndexEntry* ie, gamenumT idx)
{
    if (idx > Header.numGames) return ERROR_BadArg;
    if (fileMode_ == FMODE_ReadOnly) { return ERROR_FileMode; }

    if (idx == Header.numGames) {
        this->addEntry(*ie);
        Header.dirty_ = true;
    } else {
        this->replaceEntry(*ie, idx);
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

