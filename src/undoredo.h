/*
# Copyright (C) 2014 Fulvio Benini

* This file is part of Scid (Shane's Chess Information Database).
*
* Scid is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation.
*
* Scid is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Scid. If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef UNDOREDO_H
#define UNDOREDO_H

#include <vector>

template <class T, unsigned int undomax>
class UndoRedo {
	typedef std::vector<T*> contT;
	contT undo_, redo_;

	void doUndoRedo(contT& cont1, contT& cont2, T*& current) {
		if (! cont1.empty()) {
			if (cont2.empty() || cont2.back() != current) {
				cont2.push_back(current);
			}
			current = cont1.back();
			cont1.pop_back();
		}
	}
	void clear(contT& cont) {
		typename contT::iterator it = cont.begin();
		for (; it != cont.end(); it++) delete *it;
		cont.clear();
	}

public:
	~UndoRedo() { clear(); }

	void clear() { clear(undo_); clear(redo_); }
	void undo(T*& current) { return doUndoRedo(undo_, redo_, current); }
	void redo(T*& current) { return doUndoRedo(redo_, undo_, current); }
	uint undoSize() { return undo_.size(); }
	uint redoSize() { return redo_.size(); }
	void store (T* current) {
		undo_.push_back(current->clone());
		clear(redo_);
		if (undo_.size() > undomax) {
			delete undo_.front();
			undo_.erase(undo_.begin());
		}
	}
};

#endif
