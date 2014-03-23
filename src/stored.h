/*
* Copyright (C) 2000  Shane Hudson
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

#ifndef SCID_STORED_H
#define SCID_STORED_H

#include "game.h"
#include "fastgame.h"

const uint MAX_STORED_LINES = 256;

class StoredLine {
public:
	StoredLine(Position* pos);
	~StoredLine();
	bool CanMatch(uint ln, uint* ply, simpleMoveT* sm){
		if (ln == 0 || ln >= nStoredLines_) return true;
		if (storedLineMatches_[ln] < 0 ) return false;
		*ply = storedLineMatches_[ln];
		if (storedLineMatches_[ln] > 0) *sm = storedLineMoves_[ln];
		return true;
	}

	static uint Count (void) { return nStoredLines_; }
	static const char* GetText (uint code) {
		if (code < 1  ||  code >= nStoredLines_) { return NULL; }
		return StoredLine::storedLineText [code];
	}
	static Game* GetGame (uint code) {
		if (code < 1  ||  code >= nStoredLines_) { return NULL; }
		return storedLineGames [code];
	}
	static FastMove GetFirstMove (uint code) {
		if (code < 1  ||  code >= nStoredLines_) { return 0; }
		return FirstMove_[code];
	}

private:
	StoredLine() : freeStoredLines_(true) { Init(); }
	bool freeStoredLines_;
	int storedLineMatches_ [MAX_STORED_LINES];
	simpleMoveT storedLineMoves_ [MAX_STORED_LINES];

	static void Init (void);
	static StoredLine singleton_;
	static const char* storedLineText[];
	static uint nStoredLines_;
	static Game* storedLineGames[MAX_STORED_LINES];
	static FastMove FirstMove_ [MAX_STORED_LINES];
};

#endif  // #ifndef SCID_STORED_H

//////////////////////////////////////////////////////////////////////
//  EOF:    stored.h
//////////////////////////////////////////////////////////////////////
