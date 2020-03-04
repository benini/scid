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
    fileMode_ = FMODE_None;
    nInvalidNameId_ = 0;
    seqWrite_ = 0;
    entries_.resize(0);
}

//////////////////////////////////////////////////////////////////////
//  EOF: index.cpp
//////////////////////////////////////////////////////////////////////

