/*
# Copyright (C) 1999-2004 Shane Hudson
# Copyright (C) 2006-2009 Pascal Georges
# Copyright (C) 2008-2011 Alexander Wagner
# Copyright (C) 2013-2014 Fulvio Benini

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

#ifndef SCIDBASE_H
#define SCIDBASE_H

#include "index.h"
#include "namebase.h"
#include "game.h"
#include "gfile.h"
#include "tree.h"
#include <vector>
#include <math.h>

class SpellChecker;

// Number of undo levels
#define UNDO_MAX 20

// TreeCache size for each open database:
const uint SCID_TreeCacheSize = 1000; //250

// Secondary (memory only) TreeCache size:
const uint SCID_BackupCacheSize = 100;

struct ecoStatsT {
    uint  count;
    uint  results [NUM_RESULT_TYPES];
};

struct scidStatsT {
    uint  flagCount [IDX_NUM_FLAGS];  // Num of games with each flag set.
    dateT minDate;
    dateT maxDate;
    unsigned long long  nYears;
    unsigned long long  sumYears;
    uint  nResults [NUM_RESULT_TYPES];
    uint  nRatings;
    unsigned long long  sumRatings;
    uint  minRating;
    uint  maxRating;
    ecoStatsT ecoCount0 [1];
    ecoStatsT ecoCount1 [5];
    ecoStatsT ecoCount2 [50];
    ecoStatsT ecoCount3 [500];
    ecoStatsT ecoCount4 [500*26];
};

struct scidBaseT {
    Index *      idx;           // the Index file in memory for this base.
    NameBase *   nb;            // the NameBase file in memory.
    Game *       game;          // the active game for this base.
    Game *       undoGame[UNDO_MAX]; // array of games kept for undos
    int          undoIndex;
    int          undoMax;
    int          undoCurrent;   // which undo buffer has the currently saved game
    bool         undoFull;      // if buffer gets filled, we cant unset gameAltered
    int          gameNumber;    // game number of active game.
    bool         gameAltered;   // true if game is modified
    bool         inUse;         // true if the database is open (in use).
    uint         numGames;
    bool         memoryOnly;

    treeT        tree;
    TreeCache *  treeCache;
    TreeCache *  backupCache;
    uint         treeSearchTime;

    fileNameT    fileName;      // File name without ".si" suffix
    fileNameT    realFileName;  // File name including ".si" suffix
    fileModeT    fileMode;      // Read-only, write-only, or both.
    GFile *      gfile;
    ByteBuffer * bbuf;
    TextBuffer * tbuf;
    Filter *     dbFilter;
    Filter *     treeFilter;
    uint *       duplicates;  // For each game: idx of duplicate game + 1,
                              // or 0 if there is no duplicate.

    struct TreeStat {
        colorT toMove;
        std::string SAN;
        int resultW, resultD, resultB;
        double exp;
        int ngames, nexp;

        TreeStat() : toMove(NOCOLOR), resultW(0), resultD(0), resultB(0), exp(0), ngames(0), nexp(0)
        {
            if (expVect_[0] == 0) {
                for (int i=-800; i < 800; i++) expVect_[i+800] = 1/(1 + pow(10, i/400.0));
            }
        }
        void add(int result, int eloW, int eloB) {
            ngames++;
            double r = 0;
            switch (result) {
                case RESULT_White: resultW++; r = 1; break;
                case RESULT_Draw: resultD++; r = 0.5; break;
                case RESULT_Black: resultB++; break;
                default: return;
            }
            if (eloW == 0 || eloB == 0) return;
            int eloDiff = eloB - eloW;
            if (eloDiff < 800 && eloDiff >= -800) {
                exp += r - expVect_[eloDiff+800];
                nexp++;
            }
        }
        bool operator<(const TreeStat& cmp) const { return ngames > cmp.ngames; }

        private:
        static double expVect_[1600];
    };

    scidBaseT() { validStats = false; }
    const char* Open (const char* filename, fileModeT mode,
                      void (progressFn)(void*, unsigned int, unsigned int), void* progressData);
    void Close (const char* description);
    std::string newFilter();
    void deleteFilter(Filter* filter);
    Filter* getFilter(const char* filterName);
    Filter* getFilter(uint idx) {
        if (idx == 0) return dbFilter;
        if (idx == 1) return treeFilter;
        idx -= 2;
        if (idx >= filters_.size()) return 0;
        return filters_[idx].second;
    }
    scidStatsT* getStats() {
        if (! validStats) computeStats();
        return &stats;
    }
    const char* clearCaches();
    void clearStats() { validStats = false; };
    const char* addGames(scidBaseT* sourceBase, Filter* filter,
                         bool (progressFn)(void*, unsigned int, unsigned int), void* progressData);
    const char* addGame(scidBaseT* sourceBase, uint gNum);
    const char* addGame(Game* game);

    std::vector<scidBaseT::TreeStat> getTreeStat(Filter* filter);
    void recalcEstimatedRatings(SpellChecker* spellChecker) {
        // In games with elo == 0 we'll use an estimated ratings from a spellcheck file or from other games
        nb->recalcEstimatedRatings (spellChecker);
        for (uint gnum=0; gnum < numGames; gnum++) {
            IndexEntry * ie = idx->FetchEntry (gnum);
            eloT elo = ie->GetWhiteElo();
            if (elo > 0) nb->AddElo (ie->GetWhite(), elo);
            elo = ie->GetBlackElo();
            if (elo > 0) nb->AddElo (ie->GetBlack(), elo);
        }
    }

private:
    std::vector< std::pair<std::string, Filter*> > filters_;
    bool validStats;
    scidStatsT stats;         // Counts of flags, average rating, etc.
    const char* addGame_(scidBaseT* sourceBase, uint gNum);
    const char* addGame_(IndexEntry* iE, ByteBuffer* bbuf);
    void computeStats();
};

#endif

