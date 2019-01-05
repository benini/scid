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

#include "timer.h"
#include <tcl.h>
#include <sstream>
#include <limits>

namespace UI_impl {


typedef int         UI_res_t;
typedef ClientData  UI_extra_t;
typedef Tcl_Interp* UI_handle_t;

inline int initTclTk (UI_handle_t ti);

inline int Main (int argc, char* argv[], void (*exit) (void*)) {
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
		char sourceFileName [4096] = {0};
		#ifndef WIN32
		// Expand symbolic links
		char* exec_name = realpath(Tcl_GetNameOfExecutable(), 0);
		strncpy(sourceFileName, exec_name, 4000);
		free(exec_name);
		#else
		strncpy(sourceFileName, Tcl_GetNameOfExecutable(), 4000);
		#endif

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


class tcl_Progress : public Progress::Impl {
	UI_handle_t ti_;
	Timer timer_;

public:
	tcl_Progress(UI_handle_t ti) : ti_(ti) {}
	virtual ~tcl_Progress() {}

	virtual bool report(size_t done, size_t total, const char* msg) {
		ASSERT(done <= static_cast<size_t>(std::numeric_limits<int>::max()));
		ASSERT(total <= static_cast<size_t>(std::numeric_limits<int>::max()));

		uint64_t elapsed = timer_.MilliSecs();
		uint64_t estimated = (done == 0) ? 0 : elapsed * total / done;
		Tcl_Obj* tmp[5];
		tmp[0] = Tcl_NewStringObj("::progressCallBack", -1);
		tmp[1] = Tcl_NewIntObj(static_cast<int>(done));
		tmp[2] = Tcl_NewIntObj(static_cast<int>(total));
		tmp[3] = Tcl_NewIntObj(static_cast<int>(elapsed / 1000));
		tmp[4] = Tcl_NewIntObj(static_cast<int>(estimated / 1000));
		Tcl_Obj* cmd = Tcl_NewListObj(5, tmp);
		if (msg != NULL)
			Tcl_ListObjAppendElement(ti_, cmd, Tcl_NewStringObj(msg, -1));
		Tcl_IncrRefCount(cmd);
		int res = Tcl_EvalObjEx(ti_, cmd, TCL_EVAL_GLOBAL);
		Tcl_DecrRefCount(cmd);
		return res == TCL_OK;
	}
};

class tcl_ProgressPosMask : public Progress::Impl {
	UI_handle_t ti_;

public:
	tcl_ProgressPosMask(UI_handle_t ti) : ti_(ti) {}
	virtual ~tcl_ProgressPosMask() {}

	virtual bool report(size_t, size_t, const char*) {
		return TCL_OK == Tcl_EvalEx(ti_, "::windows::gamelist::PosMaskProgress", -1, 0);
	}
};

inline Progress CreateProgress(UI_handle_t data) {
	int err = Tcl_EvalEx(data, "::progressCallBack init", -1, 0);
	if (err != TCL_OK) return Progress();
	return Progress(new UI_impl::tcl_Progress(data));
}

inline Progress CreateProgressPosMask(UI_handle_t data) {
	return Progress(new UI_impl::tcl_ProgressPosMask(data));
}


class List {
	Tcl_Obj** list_;
	mutable int i_;
	Tcl_Obj* stackBuf_[6];

	friend Tcl_Obj* ObjMaker(const List&);

public:
	explicit List(size_t max_size)
	: list_(stackBuf_), i_(0) {
		const size_t stackBuf_size = sizeof(stackBuf_)/sizeof(stackBuf_[0]);
		if (max_size > stackBuf_size) {
			list_ = new Tcl_Obj*[max_size];
		}
	}

	~List() {
		clear();
		if (list_ != stackBuf_) delete [] list_;
	}

	void clear() {
		for (int i=0; i < i_; i++) Tcl_DecrRefCount(list_[i]);
		i_ = 0;
	}

	void push_back(Tcl_Obj* value) {
		ASSERT(value != 0);
		list_[i_++] = value;
	}
	template <typename T>
	void push_back(const T& value);
};

inline Tcl_Obj* ObjMaker(bool v) {
	return Tcl_NewBooleanObj(v);
}
inline Tcl_Obj* ObjMaker(int v) {
	return Tcl_NewIntObj(v);
}
inline Tcl_Obj* ObjMaker(unsigned int v) {
	ASSERT(v <= static_cast<unsigned int>(std::numeric_limits<int>::max()));
	return Tcl_NewIntObj(static_cast<int>(v));
}
inline Tcl_Obj* ObjMaker(unsigned long v) {
	ASSERT(v <= static_cast<unsigned long>(std::numeric_limits<int>::max()));
	return Tcl_NewIntObj(static_cast<int>(v));
}
inline Tcl_Obj* ObjMaker(unsigned long long v) {
	ASSERT(v <= static_cast<unsigned long long>(std::numeric_limits<int>::max()));
	return Tcl_NewIntObj(static_cast<int>(v));
}
inline Tcl_Obj* ObjMaker(double v) {
	return Tcl_NewDoubleObj(v);
}
inline Tcl_Obj* ObjMaker(const char* s) {
	return Tcl_NewStringObj(s, -1);
}
inline Tcl_Obj* ObjMaker(const std::string& s) {
	ASSERT(s.size() <= static_cast<size_t>(std::numeric_limits<int>::max()));
	return Tcl_NewStringObj(s.c_str(), static_cast<int>(s.size()));
}
inline Tcl_Obj* ObjMaker(const List& v) {
	Tcl_Obj* res = Tcl_NewListObj(v.i_, v.list_);
	v.i_ = 0;
	return res;
}

template <typename T>
inline void List::push_back(const T& value) {
	push_back(ObjMaker(value));
}


inline UI_res_t ResultHelper(UI_handle_t ti, errorT res) {
	if (res == OK) return TCL_OK;
	Tcl_SetObjErrorCode(ti, Tcl_NewIntObj(res));
	return TCL_ERROR;
}

inline UI_res_t Result(UI_handle_t ti, errorT res) {
	Tcl_ResetResult(ti);
	return UI_impl::ResultHelper(ti, res);
}

template <typename T>
inline UI_res_t Result(UI_handle_t ti, errorT res, const T& value) {
	Tcl_SetObjResult(ti, UI_impl::ObjMaker(value));
	return UI_impl::ResultHelper(ti, res);
}

} //End of UI_impl namespace


//TODO:
//Duplicate declarations (already in ui.h)
UI_impl::UI_res_t str_is_prefix  (UI_impl::UI_extra_t, UI_impl::UI_handle_t, int argc, const char ** argv);
UI_impl::UI_res_t str_prefix_len (UI_impl::UI_extra_t, UI_impl::UI_handle_t, int argc, const char ** argv);
UI_impl::UI_res_t sc_base        (UI_impl::UI_extra_t, UI_impl::UI_handle_t, int argc, const char ** argv);
UI_impl::UI_res_t sc_book        (UI_impl::UI_extra_t, UI_impl::UI_handle_t, int argc, const char ** argv);
UI_impl::UI_res_t sc_clipbase    (UI_impl::UI_extra_t, UI_impl::UI_handle_t, int argc, const char ** argv);
UI_impl::UI_res_t sc_eco         (UI_impl::UI_extra_t, UI_impl::UI_handle_t, int argc, const char ** argv);
UI_impl::UI_res_t sc_filter      (UI_impl::UI_extra_t, UI_impl::UI_handle_t, int argc, const char ** argv);
UI_impl::UI_res_t sc_game        (UI_impl::UI_extra_t, UI_impl::UI_handle_t, int argc, const char ** argv);
UI_impl::UI_res_t sc_info        (UI_impl::UI_extra_t, UI_impl::UI_handle_t, int argc, const char ** argv);
UI_impl::UI_res_t sc_move        (UI_impl::UI_extra_t, UI_impl::UI_handle_t, int argc, const char ** argv);
UI_impl::UI_res_t sc_name        (UI_impl::UI_extra_t, UI_impl::UI_handle_t, int argc, const char ** argv);
UI_impl::UI_res_t sc_report      (UI_impl::UI_extra_t, UI_impl::UI_handle_t, int argc, const char ** argv);
UI_impl::UI_res_t sc_pos         (UI_impl::UI_extra_t, UI_impl::UI_handle_t, int argc, const char ** argv);
UI_impl::UI_res_t sc_search      (UI_impl::UI_extra_t, UI_impl::UI_handle_t, int argc, const char ** argv);
UI_impl::UI_res_t sc_tree        (UI_impl::UI_extra_t, UI_impl::UI_handle_t, int argc, const char ** argv);
UI_impl::UI_res_t sc_var         (UI_impl::UI_extra_t, UI_impl::UI_handle_t, int argc, const char ** argv);

inline int UI_impl::initTclTk (UI_handle_t ti)
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


#endif
