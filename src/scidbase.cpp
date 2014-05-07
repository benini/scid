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

#include "common.h"
#include "scidbase.h"
#include "fastgame.h"
#include "stored.h"
#include <algorithm>
#include <time.h>


const char* scidBaseT::Open (const char* filename, fileModeT mode,
                             void (progressFn)(void*, unsigned int, unsigned int), void* progressData) {
    const char* res = 0;
    idx->SetFileName (filename);
    nb->SetFileName (filename);

    memoryOnly = false;
    fileMode = mode;
    errorT err = idx->OpenIndexFile (fileMode);
    if (err != OK) {
        res = "Error opening index file";
        if (err == ERROR_FileVersion) {
            res = "Old format Scid file, now out of date.";
        } else if (err == ERROR_OldScidVersion) {
            res = "Database version newer than Scid; please upgrade Scid.";
        }
    }
    if (err == OK) {
        err = nb->ReadNameFile();
        if (err != OK) res = "Error opening name file.";
    }
    if (err == OK) {
        gfile->Open (filename, fileMode);
        if (err != OK) res = "Error opening game file.";
    }
    if (err == OK) {
        err = idx->ReadEntireFile (progressFn, progressData);
        if (err != OK) res = "Error reading index file";
    }
    if (err == OK) {
        err = idx->VerifyFile (nb, mode == FMODE_ReadOnly);
        if (err != OK) res = "Error: name corruption in index file.\n";
    }
    if (err != OK) {
        idx->Clear();
        nb->Clear();
        gfile->Close();
        return res;
    }

    numGames = idx->GetNumGames();
    strCopy (fileName, filename);
    strCopy (realFileName, filename);
    strAppend (realFileName, INDEX_SUFFIX);
    inUse = true;
    gameNumber = -1;

    // Initialise the filters: all games match at move 1 by default.
    Filter* f; int i_filters=0;
    while ( (f = getFilter(i_filters++)) ) f->Init(numGames);

    if (treeCache == NULL) {
        treeCache = new TreeCache;
        treeCache->SetCacheSize (SCID_TreeCacheSize);
        backupCache = new TreeCache;
        backupCache->SetCacheSize (SCID_BackupCacheSize);
        backupCache->SetPolicy (TREECACHE_Oldest);
    }

    treeCache->Clear();
    backupCache->Clear();

    clearStats();

    return res;
}

void scidBaseT::Close (const char* description) {
    undoMax = -1;
    undoIndex = -1;
    undoCurrent = -1;
    undoFull = false;
    for (int u = 0; u < UNDO_MAX; u++) {
        if ( undoGame[u] != NULL ) {
            delete undoGame[u];
            undoGame[u] = NULL;
        }
    }
    if (duplicates != NULL) { delete[] duplicates; duplicates = NULL; }

    game->Clear();
    idx->CloseIndexFile();
    nb->Clear();
    gfile->Close();
    if (strcmp(fileName, "_clipbase_") == 0) {
        // If the database is the clipbase, re-open it empty
        gfile->CreateMemoryOnly();
        idx->CreateMemoryOnly();
        idx->SetType (2);
    } else {
        idx->Clear();
        idx->SetDescription (description);
        inUse = false;
        strCopy (fileName, "<empty>");
        Filter* f;
        while ( (f = getFilter(2)) ) deleteFilter(f);
    }

    Filter* f; int i_filters=0;
    while ( (f = getFilter(i_filters++)) ) f->Init(0);

    gameNumber = -1;
    numGames = 0;
    clearStats();
    treeCache->Clear();
    backupCache->Clear();
}

void scidBaseT::computeStats()
{
    uint i;
    // Zero out all stats:
    for (i = 0; i < IDX_NUM_FLAGS; i++) { stats.flagCount[i] = 0; }
    stats.nRatings = 0;
    stats.sumRatings = 0;
    stats.minRating = 0;
    stats.maxRating = 0;
    stats.minDate = ZERO_DATE;
    stats.maxDate = ZERO_DATE;
    stats.nYears = 0;
    stats.sumYears = 0;
    for (i=0; i < NUM_RESULT_TYPES; i++) {
        stats.nResults[i] = 0;
    }
    for (i=0; i < 1; i++) {
        stats.ecoCount0[i].count = 0;
        stats.ecoCount0[i].results[RESULT_White] = 0;
        stats.ecoCount0[i].results[RESULT_Black] = 0;
        stats.ecoCount0[i].results[RESULT_Draw] = 0;
        stats.ecoCount0[i].results[RESULT_None] = 0;
    }
    for (i=0; i < 5; i++) {
        stats.ecoCount1[i].count = 0;
        stats.ecoCount1[i].results[RESULT_White] = 0;
        stats.ecoCount1[i].results[RESULT_Black] = 0;
        stats.ecoCount1[i].results[RESULT_Draw] = 0;
        stats.ecoCount1[i].results[RESULT_None] = 0;
    }
    for (i=0; i < 50; i++) {
        stats.ecoCount2[i].count = 0;
        stats.ecoCount2[i].results[RESULT_White] = 0;
        stats.ecoCount2[i].results[RESULT_Black] = 0;
        stats.ecoCount2[i].results[RESULT_Draw] = 0;
        stats.ecoCount2[i].results[RESULT_None] = 0;
    }
    for (i=0; i < 500; i++) {
        stats.ecoCount3[i].count = 0;
        stats.ecoCount3[i].results[RESULT_White] = 0;
        stats.ecoCount3[i].results[RESULT_Black] = 0;
        stats.ecoCount3[i].results[RESULT_Draw] = 0;
        stats.ecoCount3[i].results[RESULT_None] = 0;
    }
    for (i=0; i < 500*26; i++) {
        stats.ecoCount4[i].count = 0;
        stats.ecoCount4[i].results[RESULT_White] = 0;
        stats.ecoCount4[i].results[RESULT_Black] = 0;
        stats.ecoCount4[i].results[RESULT_Draw] = 0;
        stats.ecoCount4[i].results[RESULT_None] = 0;
    }
    // Read stats from index entry of each game:
    for (uint gnum=0; gnum < numGames; gnum++) {
        IndexEntry * ie = idx->FetchEntry (gnum);
        stats.nResults[ie->GetResult()]++;
        eloT elo = ie->GetWhiteElo();
        if (elo > 0) {
            stats.nRatings++;
            stats.sumRatings += elo;
            if (stats.minRating == 0) { stats.minRating = elo; }
            if (elo < stats.minRating) { stats.minRating = elo; }
            if (elo > stats.maxRating) { stats.maxRating = elo; }
            nb->AddElo (ie->GetWhite(), elo);
        }
        elo = ie->GetBlackElo();
        if (elo > 0) {
            stats.nRatings++;
            stats.sumRatings += elo;
            if (stats.minRating == 0) { stats.minRating = elo; }
            if (elo < stats.minRating) { stats.minRating = elo; }
            if (elo > stats.maxRating) { stats.maxRating = elo; }
            nb->AddElo (ie->GetBlack(), elo);
        }
        dateT date = ie->GetDate();
        if (gnum == 0) {
            stats.maxDate = stats.minDate = date;
        }
        if (date_GetYear(date) > 0) {
            if (date < stats.minDate) { stats.minDate = date; }
            if (date > stats.maxDate) { stats.maxDate = date; }
            stats.nYears++;
            stats.sumYears += date_GetYear (date);
            nb->AddDate (ie->GetWhite(), date);
            nb->AddDate (ie->GetBlack(), date);
        }

        for (uint flag = 0; flag < IDX_NUM_FLAGS; flag++) {
            bool value = ie->GetFlag (1 << flag);
            if (value) {
                stats.flagCount[flag]++;
            }
        }

        ecoT eco = ie->GetEcoCode();
        ecoStringT ecoStr;
        eco_ToExtendedString (eco, ecoStr);
        uint length = strLength (ecoStr);
        resultT result = ie->GetResult();
        if (length >= 3) {
            uint code = 0;
            stats.ecoCount0[code].count++;
            stats.ecoCount0[code].results[result]++;
            code = ecoStr[0] - 'A';
            stats.ecoCount1[code].count++;
            stats.ecoCount1[code].results[result]++;
            code = (code * 10) + (ecoStr[1] - '0');
            stats.ecoCount2[code].count++;
            stats.ecoCount2[code].results[result]++;
            code = (code * 10) + (ecoStr[2] - '0');
            stats.ecoCount3[code].count++;
            stats.ecoCount3[code].results[result]++;
            if (length >= 4) {
                code = (code * 26) + (ecoStr[3] - 'a');
                stats.ecoCount4[code].count++;
                stats.ecoCount4[code].results[result]++;
            }
        }
    }

    validStats = true;
}

void scidBaseT::calcNameFreq (nameT nt) {
    ASSERT(nameFreq_[nt].size() == 0)
    nameFreq_[nt].resize(nb->GetNumNames(nt), 0);

    typedef idNumberT (IndexEntry::*getFunc)(void);
    getFunc v_get[] = { &IndexEntry::GetWhite, &IndexEntry::GetBlack, &IndexEntry::GetEvent, &IndexEntry::GetSite, &IndexEntry::GetRound};
    nameT v_nameT [] = { NAME_PLAYER, NAME_PLAYER, NAME_EVENT, NAME_SITE, NAME_ROUND };
    for (uint i=0; i < idx->GetNumGames(); i++) {
        IndexEntry* ie = idx->FetchEntry (i);
        for (uint f = 0; f < sizeof(v_nameT) / sizeof(nameT); f++) {
            if (v_nameT[f] != nt) continue;
            idNumberT id = (ie->*v_get[f])();
            if (id >= nameFreq_[nt].size()) continue;
            nameFreq_[nt][id]++;
        }
    }
}


double scidBaseT::TreeStat::expVect_[1600];

std::vector<scidBaseT::TreeStat> scidBaseT::getTreeStat(Filter* filter) {
	time_t t_start = clock();

	std::vector<FastMove> v1;
	v1.reserve(50);
	std::vector<scidBaseT::TreeStat> v2;
	v2.reserve(50);

	for(uint gnum=0; gnum < numGames; gnum++) {
		if(filter->Get(gnum) == 0) continue;
		uint ply = filter->Get(gnum) - 1;
		IndexEntry* ie = idx->FetchEntry (gnum);
		FastMove move = 0;
		if (ply == 0) {
			move = StoredLine::GetFirstMove(ie->GetStoredLineCode());
		}
		if (move == 0) {
			bbuf->Empty();
			gfile->ReadGame (bbuf, ie->GetOffset(), ie->GetLength() );
			move = FastGame::Create(bbuf->GetBuffer(), bbuf->GetBuffer() + bbuf->GetByteCount()).getMove(ply);
		}
		uint i=0;
		while (i < v1.size() && v1[i] != move) i++;
		if (i == v1.size()) {
			v1.push_back(move);
			v2.push_back(scidBaseT::TreeStat());
		}
		v2[i].add(ie->GetResult(), ie->GetWhiteElo(nb), ie->GetBlackElo(nb));
	}

	for (uint i=0; i < v1.size(); i++) {
		v2[i].SAN = (v1[i] == 0) ? "[end]" : FastMoveToSAN(v1[i], &(v2[i].toMove));
	}

	std::sort(v2.begin(), v2.end());

	printf("Tree stat: %g\n", 1.0*(clock() - t_start)/CLOCKS_PER_SEC);
	return v2;
}

const char* scidBaseT::clearCaches(bool writeFiles)
{
    if (duplicates != NULL) { delete[] duplicates; duplicates = NULL; }
    clearStats();
    for (nameT nt = NAME_FIRST; nt <= NAME_LAST; nt++) nameFreq_[nt].resize(0);
    // The target base treecache is out of date:
    treeCache->Clear();
    backupCache->Clear();
    if (! memoryOnly) removeFile (fileName, TREEFILE_SUFFIX);
    if (! memoryOnly && writeFiles) {
        gfile->FlushAll();
        // Now write the Index file header and the name file:
        if (idx->WriteHeader() != OK) {
            return  "Error writing index file.";
        }
        if (nb->WriteNameFile() != OK) {
            return "Error writing name file.";
        }
        // Ensure that the Index is still all in memory:
        idx->ReadEntireFile();
    }
    return 0;
}

const char* scidBaseT::addGame(Game* game, bool clearCache) {
    IndexEntry iE;
    iE.Init();
    if (game->Encode (bbuf, &iE) != OK)
        return "Error encoding game.";

    if (iE.SetWhiteName(nb, game->GetWhiteStr()) != OK)
        return "Too many player names.";
    if (iE.SetBlackName(nb, game->GetBlackStr()) != OK)
        return "Too many player names.";
    if (iE.SetEventName(nb, game->GetEventStr()) != OK)
        return "Too many event names.";
    if (iE.SetSiteName(nb, game->GetSiteStr()) != OK)
        return "Too many site names.";
    if (iE.SetRoundName(nb, game->GetRoundStr()) != OK)
        return "Too many round names.";

    const char* err = addGame_(&iE, bbuf);
    if (!err && clearCache) {
        err = clearCaches();
        idx->IndexUpdated(numGames -1);
	}
    return err;
}

const char* scidBaseT::addGame(scidBaseT* sourceBase, uint gNum)
{
    const char* err = addGame_(sourceBase, gNum);
    if (!err) {
        err = clearCaches();
        idx->IndexUpdated(numGames -1);
    }
    return err;
}

const char* scidBaseT::addGames(scidBaseT* sourceBase, Filter* filter,
                                bool (progressFn)(void*, unsigned int, unsigned int), void* progressData)
{
    ASSERT(filter != 0);
    const char* err = 0;
    uint iProgress = 0;
    uint totGames = filter->Count();
    Filter* f; int i_filters=0;
    while ( (f = getFilter(i_filters++)) ) f->SetCapacity(numGames + totGames);
    for (uint gNum = 0;gNum < sourceBase->numGames; gNum++) {
        if (filter->Get(gNum) == 0) continue;
        err = addGame_(sourceBase, gNum);
        if (err) break;
        if (iProgress++ % 100 == 0) {
            bool interrupt = progressFn(progressData, iProgress, totGames);
            if (interrupt) break;
        }
    }
    if (err == 0) err = clearCaches();
    else clearCaches();
    idx->IndexUpdated(IDX_NOT_FOUND);

    return err;
}

const char* scidBaseT::addGame_(scidBaseT* sourceBase, uint gNum)
{
    IndexEntry* srcIe = sourceBase->idx->FetchEntry (gNum);
    if (sourceBase->gfile->ReadGame (sourceBase->bbuf, srcIe->GetOffset(), srcIe->GetLength()) != OK) {
        return "Error reading game file.";
    }

    IndexEntry iE;
    memcpy( (void *) &iE, (void *) srcIe, sizeof(IndexEntry));

    if (iE.SetWhiteName(nb, srcIe->GetWhiteName(sourceBase->nb)) != OK)
        return "Too many player names.";
    if (iE.SetBlackName(nb, srcIe->GetBlackName(sourceBase->nb)) != OK)
        return "Too many player names.";
    if (iE.SetEventName(nb, srcIe->GetEventName(sourceBase->nb)) != OK)
        return "Too many event names.";
    if (iE.SetSiteName(nb, srcIe->GetSiteName(sourceBase->nb)) != OK)
        return "Too many site names.";
    if (iE.SetRoundName(nb, srcIe->GetRoundName(sourceBase->nb)) != OK)
        return "Too many round names.";

    return addGame_(&iE, sourceBase->bbuf);
}

const char* scidBaseT::addGame_(IndexEntry* iE, ByteBuffer* bytebuf)
{
    gameNumberT gNumber = 0;
    if (idx->AddGame (&gNumber, 0, false) != OK) return "Too many games in this database.";
    numGames = idx->GetNumGames();
    // Now try writing the game to the gfile:
    uint offset = 0;
    if (gfile->AddGame (bytebuf, &offset) != OK) return "Error writing game file.";
    iE->SetOffset (offset);
    iE->SetLength (bytebuf->GetByteCount());

    // Last of all, we write the new idxEntry, but NOT the index header
    // or the name file, since there might be more games saved yet and
    // writing them now would then be a waste of time.
    if (idx->WriteEntries (iE, gNumber, 1) != OK) {
        return "Error writing index file.";
    }

    // Add the new game to filters
    Filter* f; int i_filters=0;
    while ( (f = getFilter(i_filters++)) ) f->Append(f->isWhole() ? 1 : 0);

    return 0;
}

std::string scidBaseT::newFilter()
{
    std::string newname = filters_.size() ? filters_.back().first : "a";
    if (newname[0] == 'z') newname = 'a' + newname;
    else newname = ++(newname[0]) + newname.substr(1);
    filters_.push_back(std::make_pair(newname, new Filter(numGames)));
    return newname;
}

void scidBaseT::deleteFilter(Filter* filter)
{
    for (uint i=0; i < filters_.size(); i++) {
        if (filters_[i].second == filter) {
            delete filters_[i].second;
            filters_.erase(filters_.begin() + i);
            break;
        }
    }
}

Filter* scidBaseT::getFilter (const char* filterName)
{
    Filter* res = 0;
    Filter* mask = 0;
    std::string name = filterName;
    int split = 0;
    if (filterName[split++] == '+') {
        while (filterName[split] != '+') {
            if (filterName[split++] == 0) return 0; // Malformed filterName
        }
        name = name.substr(1, split -1);
        mask = getFilter(filterName + split + 1);
    }

    if (name == "dbfilter") res = dbFilter;
    else if (name == "tree") res = treeFilter;
    else {
        for (uint i=0; i < filters_.size(); i++) {
            if (filters_[i].first == name) {
                res = filters_[i].second;
                break;
            }
        }
    }
    if (res) res->PositionMask(mask);
    return res;
}
