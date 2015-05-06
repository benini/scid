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
#include <limits>
namespace UI_impl { class ObjMaker; }


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


//////////////////////////////////////////////////////////////////////
// UI_ interface: provide a way for c++ code to communicate with UI

/**
 * UI_Main() - Init the UI
 * @exit:      clean up function to be called when closing UI
 */
int UI_Main (int argc, char* argv[], void (*exit) (void*));


/**
 * UI_CreateProgress() - create a Progress object
 *
 * Progress objects are used for operation that make take a long time.
 * c++ code call Progress::report to tell the UI the percentage of work done
 * and an estimated time to complete the operation.
 * Progress::report will return false if the UI wants to interrupt the operation
 */
Progress UI_CreateProgress(UI_type2);


/**
 * UI_Result() - pass the result of an operation from c++ to UI
 * @res:   OK for success or an error code (error.h)
 * @value: a value (or a list of values, see UI_List) to pass to UI
 *
 * Typical usage:
 * UI_Result(ti, OK);
 * UI_Result(ti, OK, "string value");
 * UI_Result(ti, OK, 5);
 */
UI_typeRes UI_Result(UI_type2 ti, errorT res);
UI_typeRes UI_Result(UI_type2 ti, errorT res, const UI_impl::ObjMaker& value);


/**
 * class UI_List - create a list of values to be sent to UI
 * @max_size:   currently there is no automatic reallocation in push_back()
 *              so the constructor must know the max number of values that
 *              will be stored in the list
 *
 * An heterogeneous container used to pass values from c++ to UI
 * Typical usage:
 * UI_List uiList(2);
 * uiList.push_back("string value");
 * uiList.push_back(5);
 * UI_Result(ti, OK, uiList)
 */
class UI_List {
	Tcl_Obj** list_;
	int i_;
	Tcl_Obj* small_buffer_[6];

public:
	explicit UI_List(size_t max_size);
	~UI_List();

	friend class UI_impl::ObjMaker;
	void push_back(const UI_impl::ObjMaker& v);
	void clear();
};
//////////////////////////////////////////////////////////////////////


namespace UI_impl {


inline int initTclTk (Tcl_Interp * ti)
{
	if (Tcl_Init (ti) == TCL_ERROR) { return TCL_ERROR; }

	Tcl_CreateCommand(ti, "strIsPrefix" , str_is_prefix , 0, NULL);
	Tcl_CreateCommand(ti, "strPrefixLen", str_prefix_len, 0, NULL);
	Tcl_CreateCommand(ti, "sc_base"     , sc_base       , 0, NULL);
	Tcl_CreateCommand(ti, "sc_book"     , sc_book       , 0, NULL);
	Tcl_CreateCommand(ti, "sc_clipbase" , sc_clipbase   , 0, NULL);
	Tcl_CreateCommand(ti, "sc_eco"      , sc_eco        , 0, NULL);
	Tcl_CreateCommand(ti, "sc_filter"   , sc_filter     , 0, NULL);
	Tcl_CreateCommand(ti, "sc_game"     , sc_game       , 0, NULL);
	Tcl_CreateCommand(ti, "sc_info"     , sc_info       , 0, NULL);
	Tcl_CreateCommand(ti, "sc_move"     , sc_move       , 0, NULL);
	Tcl_CreateCommand(ti, "sc_name"     , sc_name       , 0, NULL);
	Tcl_CreateCommand(ti, "sc_report"   , sc_report     , 0, NULL);
	Tcl_CreateCommand(ti, "sc_pos"      , sc_pos        , 0, NULL);
	Tcl_CreateCommand(ti, "sc_search"   , sc_search     , 0, NULL);
	Tcl_CreateCommand(ti, "sc_tree"     , sc_tree       , 0, NULL);
	Tcl_CreateCommand(ti, "sc_var"      , sc_var        , 0, NULL);

	return TCL_OK;
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


class ObjMaker {
	Tcl_Obj* obj_;

public:
	// This class is not intended to be used directly, i.e. ObjMaker a("bad");
	// ASSERTs are placed to catch Tcl_Obj leaking

	ObjMaker(bool v)   { obj_ = Tcl_NewBooleanObj(v); }
	ObjMaker(int v)    { obj_ = Tcl_NewIntObj(v); }
	ObjMaker(uint v)   {
		ASSERT(v < static_cast<uint>(std::numeric_limits<int>::max()));
		obj_ = Tcl_NewIntObj(static_cast<int>(v));
	}
	ObjMaker(double v) { obj_ = Tcl_NewDoubleObj(v); }
	ObjMaker(const char* s) { obj_ = Tcl_NewStringObj(s, -1); }
	ObjMaker(const std::string& s) { obj_ = Tcl_NewStringObj(s.c_str(), s.length()); }
	ObjMaker(const UI_List& l) {
		obj_ = Tcl_NewListObj(l.i_, l.list_);
		ASSERT((const_cast<UI_List&>(l).i_ = 0) == 0);
	}

	Tcl_Obj* get() const {
		ASSERT(obj_ != 0);
		Tcl_Obj* res = obj_;
		ASSERT((const_cast<ObjMaker*>(this)->obj_ = 0) == 0);
		return res;
	}

	~ObjMaker() { ASSERT(obj_ == 0); }
};


} //End of UI_impl namespace

inline int UI_Main (int argc, char* argv[], void (*exit) (void*)) {
	Tcl_FindExecutable(argv[0]);
	Tcl_CreateExitHandler(exit, 0);
	bool search_tcl = (argc == 1) ? true : false;
	if (argc > 1 && argc < 10) {
		char* ext = strrchr (argv[1], '.');
		if (ext != 0 && strlen(ext) == 4 && std::string(".tcl") != ext) {
			search_tcl = true;
		}
	}
	if (search_tcl) {
		char sourceFileName [1024] = {0};
		strncpy(sourceFileName, Tcl_GetNameOfExecutable(), 1000);
		char* dirname = strrchr(sourceFileName, '/');
		if (dirname == 0) dirname = sourceFileName;
		else dirname += 1;
		strcpy (dirname, "tcl/start.tcl");
		if (0 != Tcl_Access(sourceFileName, 4)) {
			strcpy (dirname, "../tcl/start.tcl");
		}
		char* newArgv[10] = { argv[0], sourceFileName };
		std::copy(argv + 1, argv + argc, newArgv + 2);
		Tcl_Main(argc + 1, newArgv, UI_impl::initTclTk);
	} else {
		Tcl_Main (argc, argv, UI_impl::initTclTk);
	}

	return 0;
}


inline Progress UI_CreateProgress(UI_type2 data) {
	int err = Tcl_EvalEx(data, "::progressCallBack init", -1, 0);
	if (err != TCL_OK) return Progress();
	return Progress(new UI_impl::tcl_Progress(data));
}

inline Progress UI_CreateProgressPosMask(UI_type2 data) {
	return Progress(new UI_impl::tcl_ProgressPosMask(data));
}


inline UI_typeRes UI_Result(UI_type2 ti, errorT res) {
	if (res == OK) return TCL_OK;
	Tcl_SetObjErrorCode(ti, Tcl_NewIntObj(res));
	return TCL_ERROR;
}

inline UI_typeRes UI_Result(UI_type2 ti, errorT res, const UI_impl::ObjMaker& value) {
	Tcl_SetObjResult(ti, value.get());
	return UI_Result(ti, res);
}


inline UI_List::UI_List(size_t max_size)
: list_(small_buffer_), i_(0) {
	if (max_size > (sizeof(small_buffer_)/sizeof(small_buffer_[0]))) {
		list_ = new Tcl_Obj*[max_size];
	}
}

inline UI_List::~UI_List() {
	ASSERT (i_ == 0);
	if (list_ != small_buffer_) delete [] list_;
}

inline void UI_List::push_back(const UI_impl::ObjMaker& v) {
	list_[i_++] = v.get();
}

inline void UI_List::clear() {
	ASSERT (i_ == 0);
	i_ = 0;
}


#endif
