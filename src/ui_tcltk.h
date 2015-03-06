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

#ifndef SCID_UI_TCLTK_H
#define SCID_UI_TCLTK_H

#include "misc.h"
#include <tcl.h>


typedef ClientData  UI_type1;
typedef Tcl_Interp* UI_type2;

// From UI to c++
int str_is_prefix  (UI_type1, UI_type2, int argc, const char ** argv);
int str_prefix_len (UI_type1, UI_type2, int argc, const char ** argv);
int sc_base        (UI_type1, UI_type2, int argc, const char ** argv);
int sc_book        (UI_type1, UI_type2, int argc, const char ** argv);
int sc_clipbase    (UI_type1, UI_type2, int argc, const char ** argv);
int sc_eco         (UI_type1, UI_type2, int argc, const char ** argv);
int sc_filter      (UI_type1, UI_type2, int argc, const char ** argv);
int sc_game        (UI_type1, UI_type2, int argc, const char ** argv);
int sc_info        (UI_type1, UI_type2, int argc, const char ** argv);
int sc_move        (UI_type1, UI_type2, int argc, const char ** argv);
int sc_name        (UI_type1, UI_type2, int argc, const char ** argv);
int sc_report      (UI_type1, UI_type2, int argc, const char ** argv);
int sc_pos         (UI_type1, UI_type2, int argc, const char ** argv);
int sc_progressBar (UI_type1, UI_type2, int argc, const char ** argv);
int sc_search      (UI_type1, UI_type2, int argc, const char ** argv);
int sc_tree        (UI_type1, UI_type2, int argc, const char ** argv);
int sc_var         (UI_type1, UI_type2, int argc, const char ** argv);
//////////////////////////////////////////////////////////////////////

// From c++ to UI
int UI_Main (int argc, char* argv[], void (*exit) (void*));
//Progress UI_CreateProgress(UI_type1, UI_type2);
//////////////////////////////////////////////////////////////////////


int scid_InitTclTk (Tcl_Interp * ti)
{
	if (Tcl_Init (ti) == TCL_ERROR) { return TCL_ERROR; }

#define CREATE_CMD(ip,name,cmd) \
 Tcl_CreateCommand ((ip), (name), (Tcl_CmdProc *)(cmd), \
 (ClientData) NULL, (Tcl_CmdDeleteProc *) NULL)

	////////////////////
	/// Scid-specific Tcl/Tk commands:
	CREATE_CMD (ti, "strIsPrefix", str_is_prefix);
	CREATE_CMD (ti, "strPrefixLen", str_prefix_len);
	CREATE_CMD (ti, "sc_base", sc_base);
	CREATE_CMD (ti, "sc_book", sc_book);
	CREATE_CMD (ti, "sc_clipbase", sc_clipbase);
	CREATE_CMD (ti, "sc_eco", sc_eco);
	CREATE_CMD (ti, "sc_filter", sc_filter);
	CREATE_CMD (ti, "sc_game", sc_game);
	CREATE_CMD (ti, "sc_info", sc_info);
	CREATE_CMD (ti, "sc_move", sc_move);
	CREATE_CMD (ti, "sc_name", sc_name);
	CREATE_CMD (ti, "sc_report", sc_report);
	CREATE_CMD (ti, "sc_pos", sc_pos);
	CREATE_CMD (ti, "sc_progressBar", sc_progressBar);
	CREATE_CMD (ti, "sc_search", sc_search);
	CREATE_CMD (ti, "sc_tree", sc_tree);
	CREATE_CMD (ti, "sc_var", sc_var);

	return TCL_OK;
}

inline int UI_Main (int argc, char* argv[], void (*exit) (void*)) {
	Tcl_FindExecutable(argv[0]);
	Tcl_CreateExitHandler(exit, 0);
	if (argc == 1) {
		char sourceFileName [1024];
		char* newArgv[] = { argv[0], sourceFileName };
		ASSERT(strlen(Tcl_GetNameOfExecutable()) < 1000);
		strcpy(sourceFileName, Tcl_GetNameOfExecutable());
		char* end = strrchr (sourceFileName, '/');
		strcpy (end + 1, "tcl/start.tcl");
		if (0 != Tcl_Access(sourceFileName, 4)) {
			strcpy (end + 1, "../tcl/start.tcl");
		}
		Tcl_Main(sizeof newArgv/sizeof newArgv[0], newArgv, scid_InitTclTk);
	} else {
		Tcl_Main (argc, argv, scid_InitTclTk);
	}

	return 0;
}

#endif
