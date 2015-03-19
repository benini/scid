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
#include "timer.h"
#include <tcl.h>
#include <sstream>
class TclObjMaker;


typedef int         UI_typeRes;
typedef ClientData  UI_typeExtra;
typedef Tcl_Interp* UI_type2;

// From UI to c++
UI_typeRes str_is_prefix  (UI_typeExtra, UI_type2, int argc, const char ** argv);
UI_typeRes str_prefix_len (UI_typeExtra, UI_type2, int argc, const char ** argv);
UI_typeRes sc_base        (UI_typeExtra, UI_type2, int argc, const char ** argv);
UI_typeRes sc_book        (UI_typeExtra, UI_type2, int argc, const char ** argv);
UI_typeRes sc_clipbase    (UI_typeExtra, UI_type2, int argc, const char ** argv);
UI_typeRes sc_eco         (UI_typeExtra, UI_type2, int argc, const char ** argv);
UI_typeRes sc_filter      (UI_typeExtra, UI_type2, int argc, const char ** argv);
UI_typeRes sc_game        (UI_typeExtra, UI_type2, int argc, const char ** argv);
UI_typeRes sc_info        (UI_typeExtra, UI_type2, int argc, const char ** argv);
UI_typeRes sc_move        (UI_typeExtra, UI_type2, int argc, const char ** argv);
UI_typeRes sc_name        (UI_typeExtra, UI_type2, int argc, const char ** argv);
UI_typeRes sc_report      (UI_typeExtra, UI_type2, int argc, const char ** argv);
UI_typeRes sc_pos         (UI_typeExtra, UI_type2, int argc, const char ** argv);
UI_typeRes sc_search      (UI_typeExtra, UI_type2, int argc, const char ** argv);
UI_typeRes sc_tree        (UI_typeExtra, UI_type2, int argc, const char ** argv);
UI_typeRes sc_var         (UI_typeExtra, UI_type2, int argc, const char ** argv);
//////////////////////////////////////////////////////////////////////

// From c++ to UI
int UI_Main (int argc, char* argv[], void (*exit) (void*));
Progress UI_CreateProgress(UI_type2);

class UI_List {
	Tcl_Obj** list_;
	int i_;
	Tcl_Obj* small_buffer_[6];

public:
	explicit UI_List(int max_size);
	~UI_List();

	friend class TclObjMaker;
	void push_back(const TclObjMaker& v);
	void clear();
};

UI_typeRes UI_Result(UI_type2 ti, errorT res);
UI_typeRes UI_Result(UI_type2 ti, errorT res, const TclObjMaker& value);
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



class tcl_Progress : public ProgressImp {
	Tcl_Interp* ti_;
	Timer timer_;

public:
	tcl_Progress(Tcl_Interp* ti) : ti_(ti) {}
	virtual ~tcl_Progress() {}

	virtual bool report(uint done, uint total) {
		uint64_t elapsed = timer_.MilliSecs();
		uint64_t estimated = (done == 0) ? 0 : elapsed * total / done;
		std::ostringstream tmp;
		tmp << "::progressCallBack";
		tmp << " " << done << " " << total << " " << elapsed / 1000 << " " << estimated / 1000;
		return TCL_OK == Tcl_EvalEx(ti_, tmp.str().c_str(), -1, 0);
	}
};

class tcl_ProgressPosMask : public ProgressImp {
	Tcl_Interp* ti_;
public:
	tcl_ProgressPosMask(Tcl_Interp* ti) : ti_(ti) {}
	virtual ~tcl_ProgressPosMask() {}

	virtual bool report(uint done, uint total) {
		return TCL_OK == Tcl_EvalEx(ti_, "::windows::gamelist::PosMaskProgress", -1, 0);
	}
};

inline Progress UI_CreateProgress(UI_type2 data) {
	int err = Tcl_EvalEx(data, "::progressCallBack init", -1, 0);
	if (err != TCL_OK) return Progress();
	return Progress(new tcl_Progress(data));
}

Progress UI_CreateProgressPosMask(UI_type2 data) {
	return Progress(new tcl_ProgressPosMask(data));
}


// This object is not intended to be used directly, i.e. TclObjMaker a("bad");
// ASSERT are placed to catch Tcl_Obj leaking
class TclObjMaker {
	Tcl_Obj* obj_;

public:
	TclObjMaker(int v) { obj_ = Tcl_NewIntObj(v); }
	TclObjMaker(const char* s) { obj_ = Tcl_NewStringObj(s, -1); }
	TclObjMaker(const std::string& s) { obj_ = Tcl_NewStringObj(s.c_str(), s.length()); }
	TclObjMaker(const UI_List& l) {
		obj_ = Tcl_NewListObj(l.i_, l.list_);
		ASSERT((const_cast<UI_List&>(l).i_ = 0) == 0);
	}

	Tcl_Obj* get() const {
		ASSERT(obj_ != 0);
		Tcl_Obj* res = obj_;
		ASSERT((const_cast<Tcl_Obj*>(obj_) = 0) == 0);
		return res;
	}

	~TclObjMaker() { ASSERT(obj_ == 0); }
};

inline UI_List::UI_List(int max_size)
: i_(0), list_(small_buffer_) {
	if (max_size > (sizeof(small_buffer_)/sizeof(small_buffer_[0]))) {
		list_ = new Tcl_Obj*[max_size];
	}
}
inline UI_List::~UI_List() {
	ASSERT (i_ == 0);
	if (list_ != small_buffer_) delete [] list_;
}
inline void UI_List::push_back(const TclObjMaker& v) {
	list_[i_++] = v.get();
}
inline void UI_List::clear() {
	ASSERT (i_ == 0);
	i_ = 0;
}

inline UI_typeRes UI_Result(UI_type2 ti, errorT res) {
	if (res == OK) return TCL_OK;
	Tcl_SetObjErrorCode(ti, Tcl_NewIntObj(res));
	return TCL_ERROR;
}

inline UI_typeRes UI_Result(UI_type2 ti, errorT res, const TclObjMaker& value) {
	Tcl_SetObjResult(ti, value.get());
	return UI_Result(ti, res);
}

#endif
