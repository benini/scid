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

#include "ui.h"
#include "common.h"
#include "misc.h"
#include "scidbase.h"
#include "pgnparse.h"
#include <string>
#include <cstring>

scidBaseT*       DBasePool_find(const char* filename);
scidBaseT*       DBasePool_findEmpty();
scidBaseT*       DBasePool_getBase(int baseId);
std::vector<int> DBasePool_getBasesId();
int switchCurrentBase(scidBaseT* dbase);


//TODO: delete this
extern int currentBase;

/*
* This "sc_base" functions are used by the UI to access the databases.
* To encapsulate database internal complexity this functions should only
* parse arguments and call other functions/objects.
*
* Command names are case sensitive
* Optional parameter are indicated using [value_opt]
* Alternative values are indicated using <value_a|value_b|value_c>
* BaseId is the handle used to select the database to work on
* "dbfilter" is the name of the default filter of database
* Games are numbered starting from "1"
* Example:
*     sc_base open "filename" -> on success returns a baseId handle to the opened database
*     sc_base gameslist baseId "1" "10" "dbfilter" "N+"
*     -> returns the list of the first 10 games of the database
*/


/**
 * sc_base_close() - close a database
 */
UI_res_t sc_base_close(scidBaseT* dbase, UI_handle_t ti, int argc, const char** argv)
{
	if (dbase->getFileName() == "<clipbase>") {
		return UI_Result(ti, ERROR_BadArg, "Cannot close clipbase.");
	}
	return UI_Result(ti, dbase->Close());
}


/**
 * sc_base_compact() - compact a database
 * @stats: if used do not compact the database but calculate stats
 *
 * Compacting a database:
 * - remove all the games marked as "deleted"
 * - remove unused names
 * - makes search operations faster
 * - replace bad names with "???"
 */
UI_res_t sc_base_compact(scidBaseT* dbase, UI_handle_t ti, int argc, const char** argv)
{
	const char* usage = "Usage: sc_base compact baseId [stats]";

	if (argc == 3) {
		errorT res = dbase->compact(UI_CreateProgress(ti));
		return UI_Result(ti, res);
	} else if (argc == 4 && std::strcmp("stats", argv[3]) == 0) {
		uint n_deleted, n_unused, n_sparse, n_badNameId;
		errorT res = dbase->getCompactStat(&n_deleted, &n_unused, &n_sparse, &n_badNameId);
		UI_List val(4);
		val.push_back(n_deleted);
		val.push_back(n_unused);
		val.push_back(n_sparse);
		val.push_back(n_badNameId);
		return UI_Result(ti, res, val);
	}

	return UI_Result(ti, ERROR_BadArg, usage);
}


/**
 * sc_base_copygames() - copy games from a database to another
 */
UI_res_t sc_base_copygames(scidBaseT* dbase, UI_handle_t ti, int argc, const char** argv)
{
	const char* usage = "Usage: sc_base copygames baseId <gameNum|filterName> targetBaseId";
	if (argc != 5) return UI_Result(ti, ERROR_BadArg, usage);

	scidBaseT* targetBase = DBasePool_getBase(strGetUnsigned(argv[4]));
	if (targetBase == 0) return UI_Result(ti, ERROR_BadArg, "sc_base copygames error: wrong targetBaseId");
	if (targetBase->isReadOnly()) return UI_Result(ti, ERROR_FileReadOnly);
	errorT err = OK;
	const HFilter filter = dbase->getFilter(argv[3]);
	if (*filter) {
		err = targetBase->importGames(dbase, filter, UI_CreateProgress(ti));
	} else {
		uint gNum = strGetUnsigned (argv[3]);
		if (gNum == 0) return UI_Result(ti, ERROR_BadArg, "sc_base copygames error: wrong <gameNum|filterName>");
		err = targetBase->importGame(dbase, gNum -1);
	}
	return UI_Result(ti, err);
}


/**
 * sc_base_extra() - get/set a database extra tag (i.e. "description" or "type")
 */
UI_res_t sc_base_extra(scidBaseT* dbase, UI_handle_t ti, int argc, const char** argv)
{
	const char* usage = "Usage: sc_base extra baseId tagname [new_value]";
  
	if (argc == 4) {
		std::string res;
		errorT err = dbase->getExtraInfo(argv[3], &res);
		return UI_Result(ti, err, res);
	} else if (argc == 5) {
		return UI_Result(ti, dbase->setExtraInfo(argv[3], argv[4]));
	}

	return UI_Result(ti, ERROR_BadArg, usage);
}


/**
 * sc_base_filename() - get the filename of a database
 *
 * Return:
 *   the full path filename for non native databases (like pgn)
 *   the full path filename without the .si4 extension for native Scid databases
 *   <clipbase> for the clipbase
 */
UI_res_t sc_base_filename(scidBaseT* dbase, UI_handle_t ti, int argc, const char** argv)
{
	const char* usage = "Usage: sc_base filename baseId";
	if (argc != 3) return UI_Result(ti, ERROR_BadArg, usage);

	return UI_Result(ti, OK, dbase->getFileName());
}


/**
 * sc_base_gameflag() - get/set a game flag (i.e. "D" for deleted)
 *
 * Return: a boolean value if the requested operation is "get"
 */
UI_res_t sc_base_gameflag(scidBaseT* dbase, UI_handle_t ti, int argc, const char** argv)
{
	const char* usage = "Usage: sc_base gameflag baseId <gameNum|filterName|all> <get|set|unset|invert> flagType";
	if (argc != 6) return UI_Result(ti, ERROR_BadArg, usage);

	int cmd = 0;
	if      (std::strcmp("get",    argv[4]) == 0) cmd = 1;
	else if (std::strcmp("set",    argv[4]) == 0) cmd = 2;
	else if (std::strcmp("unset",  argv[4]) == 0) cmd = 3;
	else if (std::strcmp("invert", argv[4]) == 0) cmd = 4;
	uint flagType = IndexEntry::CharToFlagMask(argv[5][0]);
	if (flagType != 0 && cmd != 0) {
		bool value = (cmd == 2);

		const HFilter filter = dbase->getFilter(argv[3]);
		if (*filter || (std::strcmp("all", argv[3]) == 0)) {
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

	return UI_Result(ti, ERROR_BadArg, usage);
}


/**
 * sc_base_gamelocation() - find the position of a game
 * @sortCrit:      the order for the list of games to search
 * @gnumber:       the number of the game to search for
 * @text:          if (@gnumber == 0) search the first game that contains @text in
 *                 white name or black name or event name or site name
 * @start_pos:     used only with @text, start searching from a certain position
 * @forward_dir:   <true|false>, used only with @start_pos, search after|before that position
 *
 * Return: the position (0 == first) of the first match or "none" if not found
 */
UI_res_t sc_base_gamelocation(scidBaseT* dbase, UI_handle_t ti, int argc, const char** argv)
{
	const char* usage = "Usage: sc_base gamelocation baseId filterName sortCrit <gnumber | 0 text start_pos forward_dir>";
	if (argc < 6) return UI_Result(ti, ERROR_BadArg, usage);

	const HFilter filter = dbase->getFilter(argv[3]);
	const char* sort = argv[4];
	uint gnumber = strGetUnsigned (argv[5]);
	uint location = 0;
	if (gnumber == 0) {
		if (argc != 9) return UI_Result(ti, ERROR_BadArg, usage);
		const char* txt = argv[6];
		uint st = strGetUnsigned (argv[7]);
		bool fw = strGetBoolean (argv[8]);
		location = dbase->GetRangeLocation (sort, filter, txt, st, fw);
	} else {
		location = dbase->GetRangeLocation (sort, filter, gnumber);
	}
	if (location == IDX_NOT_FOUND) return UI_Result(ti, OK, "none"); //Not found
	return UI_Result(ti, OK, location);
}


/**
 * sc_base_gameslist() - returns the sorted list of games of a database
 * @start:    0 for the first game
 */
UI_res_t sc_base_gameslist(scidBaseT* dbase, UI_handle_t ti, int argc, const char** argv)
{
	const char* usage = "Usage: sc_base gameslist baseId start count filterName sortCrit";
	if (argc != 7) return UI_Result(ti, ERROR_BadArg, usage);

	uint start = strGetUnsigned (argv[3]);
	uint count = strGetUnsigned (argv[4]);
	const HFilter filter = dbase->getFilter(argv[5]);
	const char* sort = argv[6];
	uint* idxList = new uint[count];
	errorT err = dbase->GetRange(sort, start, count, filter, idxList);
	if (err != OK) {
		delete [] idxList;
		return UI_Result(ti, err);
	}

	UI_List res (count * 3);
	UI_List ginfo(24);
	const NameBase* nb = dbase->getNameBase();
	for (uint i = 0; i < count; ++i) {
		uint idx = idxList[i];
		if (idx == IDX_NOT_FOUND) break;

		uint ply = 0;
		if (*filter) ply = filter.get(idx) -1;

		const IndexEntry* ie = dbase->getIndexEntry(idx);

		ginfo.clear();
		ginfo.push_back(idx +1);
		ginfo.push_back(RESULT_STR[ie->GetResult()]);
		ginfo.push_back((ie->GetNumHalfMoves() + 1) / 2);
		ginfo.push_back(ie->GetWhiteName(nb));
		std::string eloStr;
		eloT welo = ie->GetWhiteElo();
		if (welo != 0) {
			eloStr = to_string(welo);
		} else {
			welo = ie->GetWhiteElo(nb);
			eloStr = to_string(welo);
			if (welo != 0) {
				eloStr.insert(eloStr.begin(), '(');
				eloStr.insert(eloStr.end(), ')');
			}
		}
		ginfo.push_back(eloStr);
		ginfo.push_back(ie->GetBlackName(nb));
		eloT belo = ie->GetBlackElo();
		if (belo != 0) {
			eloStr = to_string(belo);
		} else {
			belo = ie->GetBlackElo(nb);
			eloStr = to_string(belo);
			if (belo != 0) {
				eloStr.insert(eloStr.begin(), '(');
				eloStr.insert(eloStr.end(), ')');
			}
		}
		ginfo.push_back(eloStr);
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
		FastGame game = dbase->getGame(ie);
		ginfo.push_back(game.getMoveSAN(ply, 10));

		res.push_back(to_string(idx+1) + "_" + to_string(ply));
		res.push_back(ginfo);
		res.push_back(deleted);
	}

	delete [] idxList;
	return UI_Result(ti, OK, res);
}


/**
 * sc_base_import() - import games from non-native database
 *
 * Return:
 *   On success, returns a list of two elements: the number of
 *   games imported, and a string containing import errors
 *   or warnings.
 */
UI_res_t sc_base_import(scidBaseT* dbase, UI_handle_t ti, int argc, const char** argv)
{
	const char* usage = "Usage: sc_base import baseId filename";
	if (argc != 4) return UI_Result(ti, ERROR_BadArg, usage);

	if (dbase->isReadOnly()) return UI_Result(ti, ERROR_FileReadOnly);

	const char* filename = argv[3];
	uint gamesSeen = 0;
	errorT err = ERROR_BadArg;
	std::string errorMsg;
	Progress progress = UI_CreateProgress(ti);

	// if (pgn) {
		CodecPgn codec;
		err = codec.open(filename);
		if (err == OK) {
			err = dbase->importGames(codec, progress, gamesSeen, errorMsg);
		}
	// }

	if (err != OK) return UI_Result(ti, err);

	UI_List res(2);
	res.push_back(gamesSeen);
	res.push_back(errorMsg);
	return UI_Result(ti, OK, res);
}


/**
 * sc_base_list() - return the list of opened databases
 */
UI_res_t sc_base_list(UI_handle_t ti, int argc, const char** argv)
{
	const char* usage = "Usage: sc_base list";
	if (argc != 2) return UI_Result(ti, ERROR_BadArg, usage);

	std::vector<int> l = DBasePool_getBasesId();
	UI_List res(l.size());
	for (size_t i=0, n=l.size(); i < n; i++) res.push_back(l[i]);
	return UI_Result(ti, OK, res);
}


/**
 * sc_base_numGames() - return the number of games in the database
 */
UI_res_t sc_base_numGames(scidBaseT* dbase, UI_handle_t ti, int argc, const char** argv)
{
	const char* usage = "Usage: sc_base numGames baseId";
	if (argc != 3) return UI_Result(ti, ERROR_BadArg, usage);

	return UI_Result(ti, OK, dbase->numGames());
}


/**
 * sc_base_open() - open/create a Scid database
 * @filename:    the filename of the database to open/create
 * @create:      if true create a new database
 * @fMode:       open the database read-only|read-write|in_memory
 *
 * Only database in native Scid format che be opened directly with this function.
 * Other formats (like pgn for example) call sc_base_open with @fMode == FMODE_MEMORY
 * and @create == true and then import the games into the memory database.
 * If @create == false and the file cannot be opened for writing, the database will
 * be opened read-only.
 */
UI_res_t sc_base_open (UI_handle_t ti, const char* filename, bool create = false, fileModeT fMode = FMODE_Both)
{
	if (DBasePool_find(filename) != 0) return UI_Result(ti, ERROR_FileInUse);

	scidBaseT* dbase = DBasePool_findEmpty();
	if (dbase == 0) return UI_Result(ti, ERROR_Full);

	Progress progress = UI_CreateProgress(ti);
	errorT err = dbase->Open(fMode, filename, create, progress);

	if (err != OK && err != ERROR_NameDataLoss && !create) {
		err = dbase->Open(FMODE_ReadOnly, filename, false, progress);
	}
	progress.report(1,1);

	if (err != OK && err != ERROR_NameDataLoss) return UI_Result(ti, err);

	int res = switchCurrentBase(dbase);
	return UI_Result(ti, err, res);
}


/**
 * sc_base_sortcache() - create/release a sortcache
 *
 * A sortchace is used to speed up the other sc_base functions with the same "sortCrit"
 */
UI_res_t sc_base_sortcache(scidBaseT* dbase, UI_handle_t ti, int argc, const char** argv)
{
	const char* usage = "Usage: sc_base sortcache baseId <create|release> sortCrit";
	if (argc != 5) return UI_Result(ti, ERROR_BadArg, usage);

	if (std::strcmp("create", argv[3]) == 0) {
		dbase->CreateSortCache(argv[4]);
	} else {
		dbase->FreeSortCache(argv[4]);
	}
	return UI_Result(ti, OK);
}


/**
 * sc_base_switch() - change the current database and the current game
 *
 * DEPRECATED
 * Unfortunately Scid used to have only one database, one game, one filter, etc...
 * This function changes the current database and consequently the current game 
 * (sc_game functions works on the current game)
 *
 * Return: the current database ID after the switch
 */
UI_res_t sc_base_switch (scidBaseT* dbase, UI_handle_t ti)
{
	int res = switchCurrentBase(dbase);
	return UI_Result(ti, OK, res);
}


//TODO: move this function here from tkscid.cpp
UI_res_t sc_base_inUse       (UI_extra_t, UI_handle_t, int argc, const char ** argv);
UI_res_t sc_base_export      (UI_extra_t, UI_handle_t, int argc, const char ** argv);
UI_res_t sc_base_slot        (UI_extra_t, UI_handle_t, int argc, const char ** argv);
UI_res_t sc_base_stats       (UI_extra_t, UI_handle_t, int argc, const char ** argv);
UI_res_t sc_base_ecoStats    (UI_extra_t, UI_handle_t, int argc, const char ** argv);
UI_res_t sc_base_piecetrack  (UI_extra_t, UI_handle_t, int argc, const char ** argv);
UI_res_t sc_base_tag         (UI_extra_t, UI_handle_t, int argc, const char ** argv);
UI_res_t sc_base_tournaments (UI_extra_t, UI_handle_t, int argc, const char ** argv);
uint sc_base_duplicates (scidBaseT* dbase, UI_handle_t, int argc, const char ** argv);


UI_res_t sc_base (UI_extra_t cd, UI_handle_t ti, int argc, const char ** argv)
{
    static const char * options [] = {
        "close",           "compact",         "copygames",
        "create",          "creatememory",    "current",         "duplicates",
        "ecoStats",        "export",          "extra",           "filename",
        "gameflag",        "gamelocation",    "gameslist",       "import",
        "inUse",           "isReadOnly",      "list",            "numGames",        "open",
        "piecetrack",      "slot",            "sortcache",       "stats",
        "switch",          "tag",             "tournaments",     "type",
        NULL
    };
    enum {
        BASE_CLOSE,        BASE_COMPACT,      BASE_COPYGAMES,
        BASE_CREATE,       BASE_CREATEMEMORY, BASE_CURRENT,      BASE_DUPLICATES,
        BASE_ECOSTATS,     BASE_EXPORT,       BASE_EXTRA,        BASE_FILENAME,
        BASE_GAMEFLAG,     BASE_GAMELOCATION, BASE_GAMESLIST,    BASE_IMPORT,
        BASE_INUSE,        BASE_ISREADONLY,   BASE_LIST,         BASE_NUMGAMES,     BASE_OPEN,
        BASE_PTRACK,       BASE_SLOT,         BASE_SORTCACHE,    BASE_STATS,
        BASE_SWITCH,       BASE_TAG,          BASE_TOURNAMENTS,  BASE_TYPE
    };

	if (argc <= 1) return UI_Result(ti, ERROR_BadArg, "Usage: sc_base <cmd>");

	int index = strUniqueMatch (argv[1], options);
	switch (index) {
	case BASE_CREATE:
		if (argc != 3) return UI_Result(ti, ERROR_BadArg, "Usage: sc_base create filename");
		return sc_base_open(ti, argv[2], true, FMODE_Both);

	case BASE_CREATEMEMORY:
		if (argc != 3) return UI_Result(ti, ERROR_BadArg, "Usage: sc_base creatememory filename");
		return sc_base_open(ti, argv[2], true, FMODE_Memory);

	case BASE_CURRENT:
		return UI_Result(ti, OK, currentBase + 1);

	case BASE_ECOSTATS:
		return sc_base_ecoStats (cd, ti, argc, argv);

	case BASE_EXPORT:
		return sc_base_export (cd, ti, argc, argv);

	case BASE_INUSE:
		return sc_base_inUse (cd, ti, argc, argv);

	case BASE_LIST:
		return sc_base_list(ti, argc, argv);

	case BASE_OPEN:
		if (argc != 3) return UI_Result(ti, ERROR_BadArg, "Usage: sc_base open filename");
		return sc_base_open (ti, argv[2]);

	case BASE_PTRACK:
		return sc_base_piecetrack (cd, ti, argc, argv);

	case BASE_SLOT:
		return sc_base_slot (cd, ti, argc, argv);

	case BASE_STATS:
		return sc_base_stats (cd, ti, argc, argv);

	case BASE_TAG:
		return sc_base_tag (cd, ti, argc, argv);

	case BASE_TOURNAMENTS:
		return sc_base_tournaments (cd, ti, argc, argv);

	}

	//New multi-base functions
	if (argc < 3) return UI_Result(ti, ERROR_BadArg, "Usage: sc_base <cmd> baseId [args]");
	scidBaseT* dbase = DBasePool_getBase(strGetUnsigned(argv[2]));
	if (dbase == 0) return UI_Result(ti, ERROR_FileNotOpen);

	switch (index) {
	case BASE_CLOSE:
		return sc_base_close(dbase, ti, argc, argv);

	case BASE_COMPACT:
		return sc_base_compact(dbase, ti, argc, argv);

	case BASE_COPYGAMES:
		return sc_base_copygames(dbase, ti, argc, argv);

	case BASE_DUPLICATES:
		if (dbase->isReadOnly()) return UI_Result(ti, ERROR_FileReadOnly);
		return UI_Result(ti, OK, sc_base_duplicates (dbase, ti, argc, argv));

	case BASE_EXTRA:
		return sc_base_extra(dbase, ti, argc, argv);

	case BASE_FILENAME:
		return sc_base_filename(dbase, ti, argc, argv);

	case BASE_GAMEFLAG:
		return sc_base_gameflag(dbase, ti, argc, argv);

	case BASE_GAMELOCATION:
		return sc_base_gamelocation(dbase, ti, argc, argv);

	case BASE_GAMESLIST:
		return sc_base_gameslist(dbase, ti, argc, argv);

	case BASE_IMPORT:
		return sc_base_import (dbase, ti, argc, argv);

	case BASE_NUMGAMES:
		return sc_base_numGames (dbase, ti, argc, argv);

	case BASE_ISREADONLY:
		return UI_Result(ti, OK, dbase->isReadOnly());

	case BASE_SORTCACHE:
		return sc_base_sortcache(dbase, ti, argc, argv);

	case BASE_SWITCH:
		return sc_base_switch (dbase, ti);

	}

	std::string res = "sc_base\nInvalid minor command: ";
	res.append(argv[1]);
	return UI_Result(ti, ERROR_BadArg, res);
}
