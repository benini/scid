/*
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

#include "fullmove.h"
const uint STORED_LINES = 255;

class StoredLine {
public:
	StoredLine(const pieceT* board, colorT toMove);
	//Result:
	//-2 : the game cannot reach the searched position
	//-1 : the game can reach the searched position
	//>=0: the game reach the searched position at the returned ply
	int match(uint code) const {
		if ((code > 0) && (code < STORED_LINES)) return matches_[code];
		return -1;
	}

	static uint count () { return STORED_LINES; }
	static FullMove getMove (uint code, uint ply = 0) {
		if ((code < STORED_LINES) && (Moves_[code] + ply) < Moves_[code +1]) {
			return Moves_[code][ply];
		}
		return FullMove();
	}

private:
	int matches_ [STORED_LINES];
	static const FullMove* Moves_ [STORED_LINES +1];
};

#endif  // #ifndef SCID_STORED_H

//////////////////////////////////////////////////////////////////////
//  EOF:    stored.h
//////////////////////////////////////////////////////////////////////
