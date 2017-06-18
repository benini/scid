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
#include "sortcache.h"
#include <cstring>

void Index::Init ()
{
    strCopy (Header.magic, INDEX_MAGIC);
    Header.numGames  = 0;
    Header.version   = SCID_VERSION;
    Header.baseType = 0;
    Header.autoLoad = 1;
    Header.description[0] = 0;
    std::memset(Header.customFlagDesc, 0, sizeof(Header.customFlagDesc));
    Header.dirty_ = false;
    FilePtr = NULL;
    fileMode_ = FMODE_Memory;
    for(uint i=0; i < SORTING_CACHE_MAX; i++) sortingCaches[i] = NULL;
    nInvalidNameId_ = 0;
    seqWrite_ = 0;
    entries_.resize(0);
}

errorT Index::Clear ()
{
    errorT res = flush();
    delete FilePtr;
    for(uint i=0; i<SORTING_CACHE_MAX; i++) delete sortingCaches[i];
    Init();
    return res;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Index::CreateIndexFile():
//      Creates and opens a new empty index file.
//
errorT
Index::Create(const char* filename)
{
    ASSERT(filename != 0);

    Clear();
    FilePtr = new Filebuf;
    std::string fname = filename;
    fname += INDEX_SUFFIX;
    //Check that the file does not exists and then create it
    if (FilePtr->Open(fname.c_str(), FMODE_ReadOnly) == OK ||
        FilePtr->Open(fname.c_str(), FMODE_Create) != OK) {
        delete FilePtr;
        FilePtr = NULL;
        return ERROR_FileOpen;
    }
    fileMode_ = FMODE_Both;
    return WriteHeader();
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Index::Open():
//      Open an index file and read the header.
//
errorT
Index::Open (const char* filename, fileModeT fmode)
{
    ASSERT(filename != 0);

    Clear();
    if (fmode == FMODE_WriteOnly) return ERROR_FileMode;
    FilePtr = new Filebuf;
    std::string fname = filename;
    fname += INDEX_SUFFIX;

    if (FilePtr->Open (fname.c_str(), fmode) != OK) {
        delete FilePtr;
        FilePtr = NULL;
        return ERROR_FileOpen;
    }

    FilePtr->sgetn(Header.magic, 8);
    Header.magic[8] = 0;
    if (strCompare (Header.magic, INDEX_MAGIC) != 0) {
        delete FilePtr;
        FilePtr = NULL;
        return ERROR_BadMagic;
    }

    Header.version = FilePtr->ReadTwoBytes ();
    if (Header.version < SCID_OLDEST_VERSION || Header.version > SCID_VERSION) {
        delete FilePtr;
        FilePtr = NULL;
        return ERROR_FileVersion;
    }
    if (Header.version != SCID_VERSION && fmode != FMODE_ReadOnly) {
        //Old versions must be opened readonly
        delete FilePtr;
        FilePtr = NULL;
        return ERROR_FileMode;
    }

    Header.baseType = FilePtr->ReadFourBytes ();
    Header.numGames = FilePtr->ReadThreeBytes ();
    Header.autoLoad = FilePtr->ReadThreeBytes ();
    FilePtr->sgetn(Header.description, SCID_DESC_LENGTH + 1);
    Header.description[SCID_DESC_LENGTH] = 0;
    if (Header.version >= 400) {
        for (uint i = 0 ; i < CUSTOM_FLAG_MAX ; i++ ) {
            FilePtr->sgetn(Header.customFlagDesc[i], CUSTOM_FLAG_DESC_LENGTH + 1);
            Header.customFlagDesc[i][CUSTOM_FLAG_DESC_LENGTH] = 0;
        }
    } 

    fileMode_ = fmode;
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Index::ReadEntireFile():
//      Reads in the entire index into memory.
//
errorT
Index::ReadEntireFile (NameBase* nb, const Progress& progress)
{
    ASSERT (FilePtr != NULL);
    ASSERT (entries_.size() == 0);

    if (fileMode_ == FMODE_WriteOnly) { return ERROR_FileMode; }
    entries_.resize(Header.numGames);

    idNumberT maxIdx[NUM_NAME_TYPES];
    for (nameT nt = NAME_PLAYER; nt < NUM_NAME_TYPES; nt++) {
        maxIdx[nt] = nb->GetNumNames(nt);
    }

    gamenumT gNum = 0;
    for (; FilePtr->sgetc() != EOF; gNum++) {
        if (gNum == Header.numGames) return ERROR_CorruptData;

        if ((gNum % 10000) == 0) {
            if (!progress.report(gNum, Header.numGames)) return ERROR_UserCancel;
        }

        IndexEntry* ie = &(entries_[gNum]);
        errorT err = ie->Read(FilePtr, Header.version);
        if (err != OK) return err;

        if (ie->GetWhite() >= maxIdx[NAME_PLAYER]) {
            ie->SetWhiteName(nb, "?");
            nInvalidNameId_++;
        }
        if (ie->GetBlack() >= maxIdx[NAME_PLAYER]) {
            ie->SetBlackName(nb, "?");
            nInvalidNameId_++;
        }
        if (ie->GetEvent() >= maxIdx[NAME_EVENT] ) {
            ie->SetEventName(nb, "?");
            nInvalidNameId_++;
        }
        if (ie->GetSite()  >= maxIdx[NAME_SITE]  ) {
            ie->SetSiteName(nb, "?");
            nInvalidNameId_++;
        }
        if (ie->GetRound() >= maxIdx[NAME_ROUND] ) {
            ie->SetRoundName(nb, "?");
            nInvalidNameId_++;
        }

        eloT eloW = ie->GetWhiteElo();
        if (eloW > 0) nb->AddElo (ie->GetWhite(), eloW);
        eloT eloB = ie->GetBlackElo();
        if (eloB > 0) nb->AddElo (ie->GetBlack(), eloB);
    }
    progress.report(1,1);

    if (gNum != Header.numGames) return ERROR_FileRead;
    if (nInvalidNameId_ != 0) return ERROR_NameDataLoss;
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Index::WriteHeader():
//      Write the header to the open index file.
//
errorT
Index::WriteHeader ()
{
    ASSERT(FilePtr != NULL);
    if (FilePtr->pubseekpos(0) != std::streampos(0)) return ERROR_FileWrite;

    seqWrite_ = 0;
    size_t n = 0;
    n += FilePtr->sputn(Header.magic, 8);
    n += FilePtr->WriteTwoBytes (Header.version);
    n += FilePtr->WriteFourBytes (Header.baseType);
    n += FilePtr->WriteThreeBytes (Header.numGames);
    n += FilePtr->WriteThreeBytes (Header.autoLoad);
    n += FilePtr->sputn(Header.description, SCID_DESC_LENGTH + 1);
    for (size_t i = 0 ; i < CUSTOM_FLAG_MAX ; i++ ) {
        n += FilePtr->sputn(Header.customFlagDesc[i], CUSTOM_FLAG_DESC_LENGTH + 1);
    }
    if (n != INDEX_HEADER_SIZE || FilePtr->pubsync() == -1) return ERROR_FileWrite;
    Header.dirty_ = false;
    return OK;
}

errorT Index::write (const IndexEntry* ie, gamenumT idx)
{
    if (idx > Header.numGames) return ERROR_BadArg;
    if (idx >= MAX_GAMES) return ERROR_IndexFull;
    if (fileMode_ == FMODE_ReadOnly) { return ERROR_FileMode; }

    for (uint i=0; i<SORTING_CACHE_MAX; i++) {
        if (sortingCaches[i] != NULL) sortingCaches[i]->PrepareForChanges(idx);
    }

    if (idx == Header.numGames) {
        entries_.push_back(*ie);
        Header.numGames++;
        Header.dirty_ = true;
    } else {
        IndexEntry* copyToMemory = &(entries_[idx]);
        *copyToMemory = *ie;
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


/************* Interface to SortCache *******************/
SortCache* Index::CreateSortCache (const NameBase *nbase, const char *criteria) const
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
void Index::FreeSortCache(const char* criteria) const
{
    for (uint i=0; i < SORTING_CACHE_MAX; ++i) {
        if (criteria == 0) {
            delete sortingCaches[i];
            sortingCaches[i] = NULL;
            continue;
        }
        if (sortingCaches[i] != NULL && sortingCaches[i]->MatchCriteria(criteria)) {
            if (0 == sortingCaches[i]->ReleaseCount()) {
                delete sortingCaches[i];
                sortingCaches[i] = NULL;
                break;
            }
        }
    }
}

errorT Index::GetRange(const NameBase* nbase, const char* criteria, uint idx,
                       uint count, const HFilter& filter, uint* result) const {
    ASSERT(criteria != 0 && *criteria != 0);
    ASSERT(filter != 0);
    ASSERT(result != 0);
    if (criteria[0] == 'N') {
        uint i=0;
        if (criteria[1] == '+') {
            for(gamenumT gnum=0; gnum < GetNumGames() && i < count; gnum++) {
                if (filter->get(gnum) == 0) continue;
                if (idx == 0) result[i++] = gnum;
                else idx--;
            }
        } else {
            for(gamenumT gnum=GetNumGames(); gnum > 0 && i < count; gnum--) {
                if (filter->get(gnum -1) == 0) continue;
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
    if (sc == 0) return ERROR;
    sc->GetRange(idx, count, filter, result);
    delete sc;
    return OK;
}

uint Index::GetRangeLocation(const NameBase* nbase, const char* criteria,
                             const HFilter& filter, uint gnumber) const {
    ASSERT(nbase != 0);
    ASSERT(criteria != 0 && *criteria != 0);
    ASSERT(filter != 0);
    for (uint i = 0; i < SORTING_CACHE_MAX; i++) {
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

uint Index::GetRangeLocation (const NameBase *nbase, const char *criteria, const HFilter& filter,
                              const char* text, uint start, bool forward) const
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
    uint result [100];
    for (;;) {
        if (!forward) {
            if (res == 0) {
                res = IDX_NOT_FOUND;
                break;
            }
            sc->GetRange(--res, 1, filter, result);
            ASSERT (result[0] != IDX_NOT_FOUND);
            const IndexEntry* ie = GetEntry (result[0]);
            if ((strAlphaContains (ie->GetWhiteName (nbase), text))  ||
                (strAlphaContains (ie->GetBlackName (nbase), text))  ||
                (strAlphaContains (ie->GetEventName (nbase), text))  ||
                (strAlphaContains (ie->GetSiteName (nbase), text))) {
                break;
            }
        } else {
            sc->GetRange(res, 100, filter, result);
            bool stop = false;
            for (int j =0; j < 100; ++j, ++res) {
                if (result[j] == IDX_NOT_FOUND) {
                    res = IDX_NOT_FOUND;
                    stop = true;
                    break;
                }
                const IndexEntry* ie = GetEntry (result[j]);
                if ((strAlphaContains (ie->GetWhiteName (nbase), text))  ||
                    (strAlphaContains (ie->GetBlackName (nbase), text))  ||
                    (strAlphaContains (ie->GetEventName (nbase), text))  ||
                    (strAlphaContains (ie->GetSiteName (nbase), text))) {
                    stop = true;
                    break;
                }
            }
            if (stop) break;
        }
    }

    if (i == SORTING_CACHE_MAX) delete sc;
    return res;
}

errorT Index::IndexUpdated( uint gnum) const
{
    for(uint i=0; i<SORTING_CACHE_MAX; i++)
        if( sortingCaches[i] != NULL)
            sortingCaches[i]->CheckForChanges(gnum);
    return OK;
}

//////////////////////////////////////////////////////////////////////
//  EOF: index.cpp
//////////////////////////////////////////////////////////////////////

