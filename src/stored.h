//////////////////////////////////////////////////////////////////////
//
//  FILE:       stored.h
//              StoredLine class for Scid.
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    3.0
//
//  Notice:     Copyright (c) 2000  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////

#ifndef SCID_STORED_H
#define SCID_STORED_H

#include "game.h"

const uint MAX_STORED_LINES = 256;

class StoredLine {

  private:

    static void Init (void);

  public:

    static uint Count (void);
    static const char * GetText (uint code);
    static Game * GetGame (uint code);

};

#endif  // #ifndef SCID_STORED_H

//////////////////////////////////////////////////////////////////////
//  EOF:    stored.h
//////////////////////////////////////////////////////////////////////
