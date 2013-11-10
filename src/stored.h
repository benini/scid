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
public:
	StoredLine(Position* pos);
	bool CanMatch(uint ln, uint* ply, simpleMoveT* sm){
		if (ln == 0 || ln > StoredLine::Count()) return true;
		if (storedLineMatches_[ln] < 0 ) return false;
		*ply = storedLineMatches_[ln];
		if (storedLineMatches_[ln] > 0) *sm = storedLineMoves_[ln];
		return true;
	}

	static void FreeStoredLine ();
	static uint Count (void);
	static const char * GetText (uint code);
	static Game * GetGame (uint code);

private:
	int storedLineMatches_ [MAX_STORED_LINES];
	simpleMoveT storedLineMoves_ [MAX_STORED_LINES];
	static void Init (void);
};

#endif  // #ifndef SCID_STORED_H

//////////////////////////////////////////////////////////////////////
//  EOF:    stored.h
//////////////////////////////////////////////////////////////////////
