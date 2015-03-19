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

#include "ui_tcltk.h"
#include "common.h"
#include "misc.h"
#include "scidbase.h"
#include "searchpos.h"
#include <string>

int base_opened (const char * filename);
scidBaseT* getBase(int baseId);
int InvalidCommand (Tcl_Interp * ti, const char * majorCmd, const char ** minorCmds);

//TODO: avoid using global vars
extern scidBaseT* clipbase;
extern int currentBase;
extern SpellChecker* spellChecker[NUM_NAME_TYPES];

//TODO: move this function here from tkscid.cpp
int sc_base_filename    (ClientData cd, Tcl_Interp * ti, int argc, const char ** argv);
int sc_base_inUse       (ClientData cd, Tcl_Interp * ti, int argc, const char ** argv);
uint sc_base_duplicates (scidBaseT* dbase, ClientData cd, Tcl_Interp * ti, int argc, const char ** argv);
int sc_base_open        (Tcl_Interp* ti, const char * filename);
int sc_createbase       (Tcl_Interp* ti, const char * filename, scidBaseT * base, bool memoryOnly);
int sc_base_create      (ClientData cd, Tcl_Interp * ti, int argc, const char ** argv);
int sc_base_count       (ClientData cd, Tcl_Interp * ti, int argc, const char ** argv);
int sc_base_export      (ClientData cd, Tcl_Interp * ti, int argc, const char ** argv);
int sc_base_import      (Tcl_Interp* ti, scidBaseT* cdb, const char * filename);
int sc_base_numGames    (ClientData cd, Tcl_Interp * ti, int argc, const char ** argv);
int sc_base_slot        (ClientData cd, Tcl_Interp * ti, int argc, const char ** argv);
int sc_base_stats       (ClientData cd, Tcl_Interp * ti, int argc, const char ** argv);
int sc_base_ecoStats    (ClientData cd, Tcl_Interp * ti, int argc, const char ** argv);
int sc_base_piecetrack  (ClientData cd, Tcl_Interp * ti, int argc, const char ** argv);
int sc_base_switch      (ClientData cd, Tcl_Interp * ti, int argc, const char ** argv);
int sc_base_tag         (ClientData cd, Tcl_Interp * ti, int argc, const char ** argv);
int sc_base_tournaments (ClientData cd, Tcl_Interp * ti, int argc, const char ** argv);

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// sc_base_gamelocation:
// For all game numbers parameter 1 represent the first game
// If gnumber = 0 and <text> <start_gnum> <forward_dir> are provided perform a text search
int
sc_base_gamelocation (scidBaseT* cdb, Tcl_Interp * ti, int argc, const char ** argv)
{
	const char* usage = "Usage: sc_base gamelocation baseId filterName sort gnumber [text start_gnum forward_dir]";
	if (argc != 6 && argc != 9) return UI_Result(ti, ERROR_BadArg, usage);

	const HFilter filter = cdb->getFilter(argv[3]);
	const char* sort = argv[4];
	uint gnumber = strGetUnsigned (argv[5]);
	uint location = 0;
	if (gnumber == 0) {
		if (argc != 9) return UI_Result(ti, ERROR_BadArg, usage);
		const char* txt = argv[6];
		uint st = strGetUnsigned (argv[7]);
		bool fw = strGetBoolean (argv[8]);
		location = cdb->GetRangeLocation (sort, filter, txt, st, fw);
	} else {
		location = cdb->GetRangeLocation (sort, filter, gnumber);
	}
	if (location == 0) return UI_Result(ti, OK); //Not found
	return UI_Result(ti, OK, location);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// sc_base_gameslist:
int
sc_base_gameslist (scidBaseT* cdb, Tcl_Interp * ti, int argc, const char ** argv)
{
	if (argc != 6  &&  argc != 7) {
		return UI_Result(ti, ERROR_BadArg, "Usage: sc_base gameslist baseId start count filterName [sort]");
	}
	uint start = strGetUnsigned (argv[3]);
	uint count = strGetUnsigned (argv[4]);
	const HFilter filter = cdb->getFilter(argv[5]);
	const char* sort = "N+";
	if (argc == 7) sort = argv[6];
	uint* idxList = new uint[count];
	cdb->GetRange(sort, start, count, filter, idxList);

	UI_List res (count * 3);
	UI_List ginfo(24);
	const NameBase* nb = cdb->getNameBase();
	for (uint i = 0; i < count; ++i) {
		uint idx = idxList[i];
		if (idx == IDX_NOT_FOUND) break;

		uint ply = 0;
		if (*filter) ply = filter.get(idx) -1;

		const IndexEntry* ie = cdb->getIndexEntry(idx);

		ginfo.clear();
		ginfo.push_back(idx +1);
		ginfo.push_back(RESULT_STR[ie->GetResult()]);
		ginfo.push_back((ie->GetNumHalfMoves() + 1) / 2);
		ginfo.push_back(ie->GetWhiteName(nb));
		eloT welo = ie->GetWhiteElo(nb);
		ginfo.push_back(welo);
		ginfo.push_back(ie->GetBlackName(nb));
		eloT belo = ie->GetBlackElo(nb);
		ginfo.push_back(belo);
		char buf_date[16];
		date_DecodeToString (ie->GetDate(), buf_date);
		ginfo.push_back(buf_date);
		ginfo.push_back(ie->GetEventName(nb));
		ginfo.push_back(ie->GetRoundName(nb));
		ginfo.push_back(ie->GetSiteName(nb));
		ginfo.push_back(ie->GetNagCount());
		ginfo.push_back(ie->GetCommentCount());
		ginfo.push_back(ie->GetVariationCount());
		char deleted[2] = {0};
		deleted[0] = (ie->GetDeleteFlag()) ? 'D' : ' ';
		ginfo.push_back(deleted);
		char flags[16];
		ie->GetFlagStr (flags, "WBMENPTKQ!?U123456");
		ginfo.push_back(flags);
		ecoStringT ecoStr;
		eco_ToExtendedString (ie->GetEcoCode(), ecoStr);
		ginfo.push_back(ecoStr);
		std::string endMaterial = matsig_makeString(ie->GetFinalMatSig());
		ginfo.push_back(endMaterial);
		char startpos[2] = {0};
		startpos[0] = (ie->GetStartFlag()) ? 'S' : ' ';
		ginfo.push_back(startpos);
		char buf_eventdate[16];
		date_DecodeToString (ie->GetEventDate(), buf_eventdate);
		ginfo.push_back(buf_eventdate);
		ginfo.push_back(ie->GetYear());
		ginfo.push_back((welo + belo)/2);
		ginfo.push_back(ie->GetRating(nb));
		FastGame game = cdb->getGame(ie);
		ginfo.push_back(game.getMoveSAN(ply, 10));

		res.push_back(to_string(idx+1) + "_" + to_string(ply));
		res.push_back(ginfo);
		res.push_back(deleted);
	}

	delete [] idxList;
    return UI_Result(ti, OK, res);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// sc_base: database commands.
UI_typeRes sc_base (UI_typeExtra cd, UI_type2 ti, int argc, const char ** argv)
{
    static const char * options [] = {
		"close",        "count",
		"create",       "current",      "duplicates",
		"ecoStats",     "export",       "filename",     "import",
		"inUse",        "isReadOnly",   "numGames",     "open",
		"piecetrack",   "slot",         "stats",
		"switch",       "tag",          "tournaments",  "type",
		"gameslist",    "sortcache",    "gamelocation",
		"compact",      "gameflag",     "copygames",    "newFilter",
		"extra",
		NULL
    };
    enum {
		BASE_CLOSE,       BASE_COUNT,
		BASE_CREATE,      BASE_CURRENT,     BASE_DUPLICATES,
		BASE_ECOSTATS,    BASE_EXPORT,      BASE_FILENAME,    BASE_IMPORT,
		BASE_INUSE,       BASE_ISREADONLY,  BASE_NUMGAMES,    BASE_OPEN,
		BASE_PTRACK,      BASE_SLOT,        BASE_STATS,
		BASE_SWITCH,      BASE_TAG,         BASE_TOURNAMENTS, BASE_TYPE,
		BASE_GAMESLIST,   BASE_SORTCACHE,   BASE_GAMELOCATION,
		BASE_COMPACT,     BASE_GAMEFLAG,    BASE_COPYGAMES,   BASE_NEWFILTER,
		BASE_EXTRA
    };
    int index = -1;

    if (argc > 1) { index = strUniqueMatch (argv[1], options); }
    if (index == -1) return InvalidCommand (ti, "sc_base", options);

    switch (index) {
    case BASE_COUNT:
        return sc_base_count (cd, ti, argc, argv);

    case BASE_CREATE:
        return sc_base_create (cd, ti, argc, argv);

    case BASE_CURRENT:
        return UI_Result(ti, OK, currentBase + 1);

    case BASE_ECOSTATS:
        return sc_base_ecoStats (cd, ti, argc, argv);

    case BASE_EXPORT:
        return sc_base_export (cd, ti, argc, argv);

    case BASE_FILENAME:
        return sc_base_filename (cd, ti, argc, argv);

    case BASE_INUSE:
        return sc_base_inUse (cd, ti, argc, argv);

    case BASE_NUMGAMES:
        return sc_base_numGames (cd, ti, argc, argv);

    case BASE_OPEN:
        if (argc != 3) return UI_Result(ti, ERROR_BadArg, "Usage: sc_base open filename");
        return sc_base_open (ti, argv[2]);

    case BASE_PTRACK:
        return sc_base_piecetrack (cd, ti, argc, argv);

    case BASE_SLOT:
        return sc_base_slot (cd, ti, argc, argv);

    case BASE_STATS:
        return sc_base_stats (cd, ti, argc, argv);

    case BASE_SWITCH:
        return sc_base_switch (cd, ti, argc, argv);

    case BASE_TAG:
        return sc_base_tag (cd, ti, argc, argv);

    case BASE_TOURNAMENTS:
        return sc_base_tournaments (cd, ti, argc, argv);

    }

    //New multi-base functions
    if (argc < 3) return UI_Result(ti, ERROR_BadArg, "Usage: sc_base <cmd> baseId [args]");
    scidBaseT* dbase = getBase(strGetUnsigned(argv[2]));
    if (dbase == 0) return UI_Result(ti, ERROR_BadArg, "Invalid database number.");

    switch (index) {
    case BASE_CLOSE:
        if (dbase == clipbase) return UI_Result(ti, ERROR_BadArg, "Cannot close clipbase.");
        return UI_Result(ti, dbase->Close());

    case BASE_EXTRA:
        if (argc == 4) {
            std::string res;
            errorT err = dbase->getExtraInfo(argv[3], &res);
            return UI_Result(ti, err, res);
        } else if (argc == 5) {
            return UI_Result(ti, dbase->setExtraInfo(argv[3], argv[4]));
        }
        return UI_Result(ti, ERROR_BadArg, "Usage: sc_base extra baseId tagname [new_value]");

    case BASE_COMPACT:
        if (argc == 3) {
            errorT res = dbase->compact(spellChecker[NAME_PLAYER], UI_CreateProgress(ti));
            return UI_Result(ti, res);
        } else if (argc == 4 && strCompare("stats", argv[3]) == 0) {
            uint n_deleted, n_unused, n_sparse, n_badNameId;
            errorT res = dbase->getCompactStat(&n_deleted, &n_unused, &n_sparse, &n_badNameId);
            UI_List val(4);
            val.push_back(n_deleted);
            val.push_back(n_unused);
            val.push_back(n_sparse);
            val.push_back(n_badNameId);
            return UI_Result(ti, res, val);
        }
        return UI_Result(ti, ERROR_BadArg, "Usage: sc_base compact baseId [stats] <games|names>");

    case BASE_COPYGAMES:
        if (argc == 5) {
            scidBaseT* targetBase = getBase(strGetUnsigned(argv[4]));
            if (targetBase == 0) return UI_Result(ti, ERROR_BadArg, "sc_base copygames error: wrong targetBaseId");
            if (targetBase->isReadOnly()) return UI_Result(ti, ERROR_FileReadOnly);
            errorT err = OK;
            const HFilter filter = dbase->getFilter(argv[3]);
            if (*filter) {
                err = targetBase->addGames(dbase, filter, UI_CreateProgress(ti));
            } else {
                uint gNum = strGetUnsigned (argv[3]);
                if (gNum == 0) return UI_Result(ti, ERROR_BadArg, "sc_base copygames error: wrong <gameNum|filterName>");
                err = targetBase->addGame(dbase, gNum -1);
            }
            return UI_Result(ti, err);
        }
        return UI_Result(ti, ERROR_BadArg, "Usage: sc_base copygames baseId <gameNum|filterName> targetBaseId");

    case BASE_GAMEFLAG:
        if (argc == 6) {
            int cmd = 0;
            if (strCompare("get", argv[4]) == 0) cmd = 1;
            else if (strCompare("set", argv[4]) == 0) cmd = 2;
            else if (strCompare("unset", argv[4]) == 0) cmd = 3;
            else if (strCompare("invert", argv[4]) == 0) cmd = 4;
            uint flagType = IndexEntry::CharToFlag (argv[5][0]);
            if (flagType != 0 && cmd != 0) {
                flagType = 1 << flagType;
                bool value = (cmd == 2);

                const HFilter filter = dbase->getFilter(argv[3]);
                if (*filter || (std::string("all") == argv[3])) {
                    switch (cmd) {
                    case 2:
                    case 3: return UI_Result(ti, dbase->setFlag(value, flagType, filter));
                    case 4: return UI_Result(ti, dbase->invertFlag(flagType, filter));
                    }
                } else {
                    gamenumT gNum = strGetUnsigned(argv[3]);
                    if (gNum > 0 && gNum <= dbase->numGames()) {
                        gNum--;
                        switch (cmd) {
                        case 1: return UI_Result(ti, OK, dbase->getFlag(flagType, gNum));
                        case 2:
                        case 3: return UI_Result(ti, dbase->setFlag(value, flagType, gNum));
                        case 4: return UI_Result(ti, dbase->invertFlag(flagType, gNum));
                        }
                    }
                }
            }
        }
        return UI_Result(ti, ERROR_BadArg, "Usage: sc_base gameflag baseId <gameNum|filterName|all> <get|set|unset|invert> flagType");

    case BASE_GAMESLIST:
        return sc_base_gameslist (dbase, ti, argc, argv);

    case BASE_GAMELOCATION:
        return sc_base_gamelocation (dbase, ti, argc, argv);

    case BASE_ISREADONLY:
        return UI_Result(ti, OK, dbase->isReadOnly());

    case BASE_NEWFILTER:
        if (argc == 3) {
            UI_Result(ti, OK, dbase->newFilter());
        } else if (argc == 4) {
            //TODO: Use argv[4] (FEN) instead of current Position
            SearchPos fp(getBase(currentBase)->game->GetCurrentPos());
            //TODO: use a dedicated filter instead of treeFilter
            HFilter maskfilter = HFilter(dbase->treeFilter);
            std::string val;
            if (fp.setFilter(dbase, maskfilter, UI_CreateProgressPosMask(ti))) {
                val = "tree";
            }
            return UI_Result(ti, OK, val);
        }
        return UI_Result(ti, ERROR_BadArg, "Usage: sc_base newFilter baseId [FEN]");

    case BASE_SORTCACHE:
        if (argc != 5) return UI_Result(ti, ERROR_BadArg, "Usage: sc_base sortcache <db> <create|release> <sort>");
        if (strCompare("create", argv[3]) == 0) {
            if (argv[4][0] != 'N') dbase->CreateSortCache(argv[4]);
        } else {
            dbase->FreeSortCache(argv[4]);
        }
        return UI_Result(ti, OK);

    }

    //TODO: Group all the functions that modifies the database
    if (dbase->isReadOnly()) {
        return UI_Result(ti, ERROR_FileReadOnly);
    }

    switch (index) {
    case BASE_DUPLICATES:
        return UI_Result(ti, OK, sc_base_duplicates (dbase, cd, ti, argc, argv));

    case BASE_IMPORT:
        if (argc != 4) return UI_Result(ti, ERROR_BadArg, "Usage: sc_base import baseId filename");
        return sc_base_import (ti, dbase, argv[3]);

    }

    return InvalidCommand (ti, "sc_base", options);
}
