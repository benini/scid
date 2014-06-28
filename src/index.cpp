/*
* Copyright (c) 1999-2002  Shane Hudson
* Copyright (c) 2006-2009  Pascal Georges
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

#include "index.h"
#include "namebase.h"
#include "sortcache.h"
#include <string.h>

void Index::Init ()
{
    strCopy (Header.magic, INDEX_MAGIC);
    Header.numGames  = 0;
    Header.version   = SCID_VERSION;
    Header.baseType = 0;
    Header.autoLoad = 2;
    Header.description[0] = 0;
    memset(Header.customFlagDesc, 0, sizeof(Header.customFlagDesc));
    Dirty = false;
    FilePtr = NULL;
    FileMode = FMODE_Memory;
    for(uint i=0; i < SORTING_CACHE_MAX; i++) sortingCaches[i] = NULL;
    filter_changed_ = true;
    badNameIdCount_ = 0;
    sequentialWrite_ = 0;
    entries_.resize(0);
}

void Index::Clear ()
{
    if (Dirty && FileMode == FMODE_Both) WriteHeader();
    if (FilePtr != NULL)  delete FilePtr;
    for(uint i=0; i<SORTING_CACHE_MAX; i++) {
        if (sortingCaches[i]) delete sortingCaches[i];
    }
    Init();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Index::CreateIndexFile():
//      Creates and opens a new empty index file.
//
errorT
Index::Create(const char* filename)
{
    Clear();
    if (filename != 0) {
        fileNameT fname;
        strCopy (fname, filename);
        strAppend (fname, INDEX_SUFFIX);
        FilePtr = new Filebuf;
        //Check that the file does not exists
        if (FilePtr->Open(fname, FMODE_ReadOnly) != OK && 
            FilePtr->Open(fname, FMODE_Create) == OK) {
            FileMode = FMODE_Both;
            return WriteHeader();
        } else {
            delete FilePtr;
            FilePtr = NULL;
            return ERROR_FileWrite;
        }
    }
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Index::Open():
//      Open an index file and read the header.
//
errorT
Index::Open (const char* filename, fileModeT fmode, bool old)
{
    Clear();
    fileNameT fname;
    strCopy (fname, filename);
    strAppend (fname, old ? OLD_INDEX_SUFFIX : INDEX_SUFFIX);
    FileMode = fmode;
    FilePtr = new Filebuf;

    if (FilePtr->Open (fname, fmode) != OK) {
        delete FilePtr;
        FilePtr = NULL;
        return ERROR_FileOpen;
    }

    FilePtr->ReadNBytes (Header.magic, 8);
    if (strCompare (Header.magic, INDEX_MAGIC) != 0) {
        delete FilePtr;
        FilePtr = NULL;
        return ERROR_BadMagic;
    }

    Header.version = FilePtr->ReadTwoBytes ();
    Header.baseType = FilePtr->ReadFourBytes ();
    Header.numGames = FilePtr->ReadThreeBytes ();
    Header.autoLoad = FilePtr->ReadThreeBytes ();
    FilePtr->ReadNBytes (Header.description, SCID_DESC_LENGTH + 1);
    for (uint i = 0 ; i < CUSTOM_FLAG_MAX ; i++ ) {
      FilePtr->ReadNBytes (Header.customFlagDesc[i], CUSTOM_FLAG_DESC_LENGTH + 1);
    }

    // Check that the version of the file is valid: it must be
    // SCID_OLDEST_VERSION or higher, but not higher than the
    // current Scid version number.
    errorT result = OK;
    if (!old) {
        if (Header.version > SCID_VERSION) { result = ERROR_OldScidVersion; }
        if (Header.version < SCID_OLDEST_VERSION) { 
            result = ERROR_FileVersion; 
        }
        if (result != OK) {
            delete FilePtr;
            FilePtr = NULL;
        }
    }

    return result;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Index::ReadEntireFile():
//      Reads in the entire index into memory.
//
errorT
Index::ReadEntireFile (NameBase* nb,
                       void (*progressFn)(void*, uint, uint),
                       void * progressData)
{
    ASSERT (FilePtr != NULL);
    if (FileMode == FMODE_WriteOnly) { return ERROR_FileMode; }
    entries_.resize(Header.numGames);

    idNumberT maxIdx[NUM_NAME_TYPES];
    for (nameT nt = NAME_FIRST; nt <= NAME_LAST; nt++) {
        maxIdx[nt] = nb->GetNumNames(nt);
    }

    uint n = 0;
    for (gameNumberT i=0; i < Header.numGames; i++) {
        if (progressFn && (i % 10000) == 0) {
            (*progressFn) (progressData, i, Header.numGames);
        }

        IndexEntry* ie = FetchEntry(i);
        errorT err = ie->Read(FilePtr, Header.version);
        if (err != OK) return err;

        if (ie->GetWhite() >= maxIdx[NAME_PLAYER]) {
            ie->SetWhiteName(nb, "?"); n++;
        }
        if (ie->GetBlack() >= maxIdx[NAME_PLAYER]) {
            ie->SetBlackName(nb, "?"); n++;
        }
        if (ie->GetEvent() >= maxIdx[NAME_EVENT] ) {
            ie->SetEventName(nb, "?"); n++;
        }
        if (ie->GetSite()  >= maxIdx[NAME_SITE]  ) {
            ie->SetSiteName(nb, "?"); n++;
        }
        if (ie->GetRound() >= maxIdx[NAME_ROUND] ) {
            ie->SetRoundName(nb, "?"); n++;
        }

        eloT eloW = ie->GetWhiteElo();
        if (eloW > 0) nb->AddElo (ie->GetWhite(), eloW);
        eloT eloB = ie->GetBlackElo();
        if (eloB > 0) nb->AddElo (ie->GetBlack(), eloB);
    }
    if (progressFn) (*progressFn) (progressData, 1, 1);
    badNameIdCount_ = n;
    return (n == 0) ? OK : ERROR_NameDataLoss;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Index::WriteHeader():
//      Write the header to the open index file.
//
errorT
Index::WriteHeader ()
{
    if (FilePtr == NULL) return OK;
    if (FilePtr->Seek (0) != OK) return ERROR_FileWrite;

    sequentialWrite_ = 0;
    int n = 0;
    n += FilePtr->WriteNBytes (Header.magic, 8);
    n += FilePtr->WriteTwoBytes (Header.version);
    n += FilePtr->WriteFourBytes (Header.baseType);
    n += FilePtr->WriteThreeBytes (Header.numGames);
    n += FilePtr->WriteThreeBytes (Header.autoLoad);
    n += FilePtr->WriteNBytes (Header.description, SCID_DESC_LENGTH + 1);
    for (uint i = 0 ; i < CUSTOM_FLAG_MAX ; i++ ) {
        n += FilePtr->WriteNBytes (Header.customFlagDesc[i], CUSTOM_FLAG_DESC_LENGTH + 1);
    }
    if (n != 182 || FilePtr->pubsync() == -1) return ERROR_FileWrite;
    Dirty = false;
    return OK;
}

errorT Index::write (IndexEntry* ie, uint idx)
{
    IndexEntry* ieTemp = FetchEntry(idx);
    *ieTemp = *ie;
    if (FilePtr == NULL) return OK;

    if (FileMode == FMODE_ReadOnly) { return ERROR_FileMode; }
    if ((sequentialWrite_ == 0) || (idx != sequentialWrite_ + 1)) {
        FilePtr->Seek(getIndexEntrySize() * idx + INDEX_HEADER_SIZE);
    }
    errorT res = ie->Write (FilePtr, Header.version);
    sequentialWrite_ = (res == OK) ? idx : 0;
    return res;
}


/************* Interface to SortCache *******************/
SortCache* Index::CreateSortingCache (NameBase *nbase, const char *criteria)
{
    // If there is another client using a matching cache, use that one
    for(uint i=0; i < SORTING_CACHE_MAX; i++) {
        if (sortingCaches[i] == NULL) continue;
        if (sortingCaches[i]->MatchCriteria(criteria) ) {
            sortingCaches[i]->AddCount();
            return sortingCaches[i];
        }
    }

    for (uint idx =0; idx < SORTING_CACHE_MAX; idx++) {
        if (sortingCaches[idx] == NULL) {
            sortingCaches[idx] = SortCache::Create (this, nbase, criteria);
            return sortingCaches[idx];
        }
    }
    return 0;
}

// Search and free a matching cache
void Index::FreeCache(const char* criteria)
{
    for (uint i=0; i < SORTING_CACHE_MAX; ++i) {
        if (sortingCaches[i] != NULL && sortingCaches[i]->MatchCriteria(criteria)) {
            if (0 == sortingCaches[i]->ReleaseCount()) {
                delete sortingCaches[i];
                sortingCaches[i] = NULL;
                break;
            }
        }
    }
}

errorT Index::GetRange (NameBase *nbase, const char *criteria, uint idx, uint count, Filter *filter, uint *result)
{
    ASSERT(result != 0);
    ASSERT(criteria != 0 && strlen(criteria) > 1);
    if (criteria[0] == 'N') {
        uint i=0;
        if (criteria[1] == '+') {
            for(uint gnum=0; gnum < GetNumGames() && i < count; gnum++) {
                if (filter && filter->Get(gnum) == 0) continue;
                if (idx == 0) result[i++] = gnum;
                else idx--;
            }
        } else {
            for(uint gnum=GetNumGames(); gnum > 0 && i < count; gnum--) {
                if (filter && filter->Get(gnum -1) == 0) continue;
                if (idx == 0) result[i++] = gnum -1;
                else idx--;
            }
        }
        if (i != count) result[i] = IDX_NOT_FOUND;
        return OK;
    }

    // Use existing caches if possible
    for(uint i=0; i < SORTING_CACHE_MAX; i++) {
        if (sortingCaches[i] == NULL) continue;
        if (sortingCaches[i]->MatchCriteria(criteria) ) {
            sortingCaches[i]->GetRange(idx, count, filter, result);
            return OK;
        }
    }

    SortCache* sc = SortCache::Create (this, nbase, criteria, false);
    sc->GetRange(idx, count, filter, result);
    delete sc;
    return OK;
}

uint Index::GetRangeLocation (NameBase *nbase, const char *criteria, Filter *filter, uint gnumber)
{
    for(uint i=0; i < SORTING_CACHE_MAX; i++) {
        if (sortingCaches[i] == NULL) continue;
        if (sortingCaches[i]->MatchCriteria(criteria) ) {
            return sortingCaches[i]->IndexToFilteredCount (gnumber, filter);
        }
    }

    SortCache* sc = SortCache::Create (this, nbase, criteria, false);
    uint r = sc->IndexToFilteredCount (gnumber, filter);
    delete sc;
    return r;
}

uint Index::GetRangeLocation (NameBase *nbase, const char *criteria, Filter *filter,
                              const char* text, uint start, bool forward)
{
    uint i = 0;
    for(; i < SORTING_CACHE_MAX; i++) {
        if (sortingCaches[i] == NULL) continue;
        if (sortingCaches[i]->MatchCriteria(criteria) ) break;
    }
    SortCache* sc = 0;
    if (i != SORTING_CACHE_MAX) sc = sortingCaches[i];
    else sc = SortCache::Create (this, nbase, criteria, false);

    uint res = start;
    uint result [100] = {0};
    for (;;) {
        if (!forward) { //TODO: Speed up this search, maybe using std::vector.rbegin()
            if (res == 0) break;
            else res--;
            sc->GetRange(res, 1, filter, result);
            IndexEntry * ie = FetchEntry (result[0]);
            if ((strAlphaContains (ie->GetWhiteName (nbase), text))  ||
                (strAlphaContains (ie->GetBlackName (nbase), text))  ||
                (strAlphaContains (ie->GetEventName (nbase), text))  ||
                (strAlphaContains (ie->GetSiteName (nbase), text))) {
                ++res;
                break;
            }
        } else {
            sc->GetRange(res, 100, filter, result);
            bool stop = false;
            for (int j =0; j < 100; ++j, ++res) {
                if (result[j] == IDX_NOT_FOUND) {
                    res = 0;
                    stop = true;
                    break;
                }
                IndexEntry * ie = FetchEntry (result[j]);
                if ((strAlphaContains (ie->GetWhiteName (nbase), text))  ||
                    (strAlphaContains (ie->GetBlackName (nbase), text))  ||
                    (strAlphaContains (ie->GetEventName (nbase), text))  ||
                    (strAlphaContains (ie->GetSiteName (nbase), text))) {
                    stop = true;
                    ++res;
                    break;
                }
            }
            if (stop) break;
        }
    }

    if (i == SORTING_CACHE_MAX) delete sc;
    return res;
}

errorT Index::IndexUpdated( uint gnum)
{
    for(uint i=0; i<SORTING_CACHE_MAX; i++)
        if( sortingCaches[i] != NULL)
            sortingCaches[i]->CheckForChanges(gnum);
    return OK;
}

//////////////////////////////////////////////////////////////////////
//  EOF: index.cpp
//////////////////////////////////////////////////////////////////////

