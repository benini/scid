/*
# Copyright (C) 2015 Fulvio Benini

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

#include "dbasepool.h"
#include "ui.h"
#include "scidbase.h"


scidBaseT * dbList = NULL;      // array of database slots.

//Current database
int currentBase = 0;
scidBaseT* db = NULL;

//Clipbase database
scidBaseT* clipbase = NULL;

// MAX_BASES is the maximum number of databases that can be open,
// including the clipbase database.
const int MAX_BASES = 9;
const int CLIPBASE_NUM = MAX_BASES - 1;

void DBasePool::init() {
	dbList = new scidBaseT[MAX_BASES];
	currentBase = 0;
	db = &(dbList[currentBase]);

	clipbase = &(dbList[CLIPBASE_NUM]);
	clipbase->Open(FMODE_Memory, "<clipbase>");
	clipbase->idx->SetType(2);
}

void DBasePool::closeAll() {
	ASSERT(dbList != NULL);
	delete[] dbList;
}

scidBaseT* DBasePool::find(const char* filename) {
	for (int i = 0, n = MAX_BASES; i < n; i++) {
		if (dbList[i].inUse && dbList[i].getFileName() == filename)
			return &(dbList[i]);
	}
	return 0;
}

scidBaseT* DBasePool::getBase(int baseHandle) {
	if (baseHandle < 1 || baseHandle > MAX_BASES) return 0;
	scidBaseT* res = &(dbList[baseHandle - 1]);
	return res->inUse ? res : 0;
}

scidBaseT* DBasePool::getFreeSlot() {
	for (int i = 0, n = MAX_BASES; i < n; i++) {
		if (!dbList[i].inUse) { return &(dbList[i]); }
	}
	return 0;
}

std::vector<int> DBasePool::getHandles() {
	std::vector<int> res;
	for (int i = 0, n = MAX_BASES; i < n; i++) {
		if (dbList[i].inUse) res.push_back(i + 1);
	}
	return res;
}

int DBasePool::switchCurrent(scidBaseT* dbase) {
	if (dbase != 0) {
		for (int i = 0; i < MAX_BASES; i++) {
			if ((dbList + i) == dbase) {
				currentBase = i;
				db = dbase;
				break;
			}
		}
	}
	return currentBase + 1;
}

