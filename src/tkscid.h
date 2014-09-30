/////////////////////////////////////////////////////////////////////
//
//  FILE:       tkscid.h
//              Scid extensions to Tcl/Tk interpreter
//
//  Part of:    Scid (Shane's Chess Information Database)
//
//  Notice:     Copyright (c) 1999-2004 Shane Hudson.  All rights reserved.
//              Copyright (c) 2006-2007 Pascal Georges
//              Copyright (c) 2013 Benini Fulvio
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////


#include "common.h"
#include "index.h"
#include "position.h"
#include "engine.h"
#include "game.h"
#include "gfile.h"
#include "namebase.h"
#include "tree.h"
#include "pbook.h"
#include "pgnparse.h"
#include "timer.h"
#include "crosstab.h"
#include "spellchk.h"
#include "probe.h"
#include "optable.h"
#include "stored.h"
#include "polyglot.h"
#include "scidbase.h"
#include <stdio.h>
#include <ctype.h>
#include <sys/stat.h>

#include <tcl.h>

// Some character pointer arguments (like "char ***" to Tcl_SplitList)
// changed const-ness from Tcl/Tk 8.3 to 8.4 and g++ cannot handle
// implicit (char ***) <-> (const char ***) conversions, so CONST84
// is "const" if set from tcl.h, otherwise it is nothing:
#ifndef CONST84
#  define CONST84
#endif

// Filter operations:

typedef uint filterOpT;
const filterOpT FILTEROP_AND = 0;
const filterOpT FILTEROP_OR = 1;
const filterOpT FILTEROP_RESET = 2;


// Tablebase probe modes:

#define PROBE_NONE 0
#define PROBE_RESULT 1
#define PROBE_SUMMARY 2
#define PROBE_REPORT 3
#define PROBE_OPTIMAL 4


//////////////////////////////////////////////////////////////////////
//
// Data structures for Scid Tcl/Tk extensions:
//

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Progress Bar struct:
//
struct progressBarT {
    bool state;
    int  height;
    int  width;
    bool interrupt;
    Timer timer;
    char * canvName;
    char * rectName;
    char * timeName;
};


//////////////////////////////////////////////////////////////////////
// Declarations for Scid application-specific Tcl commands
//

// Macro TCL_ARGS expands to the argument-type list that any
// Tcl command function takes.

#define TCL_ARGS  ClientData cd, Tcl_Interp * ti, int argc, const char ** argv

int str_is_prefix  (TCL_ARGS);
int str_prefix_len (TCL_ARGS);
int sc_base           (TCL_ARGS);
int sc_base_filename  (TCL_ARGS);
int sc_base_inUse     (TCL_ARGS);
int sc_base_duplicates (scidBaseT* dbase, TCL_ARGS);
int sc_base_open      (TCL_ARGS);
int sc_base_check     (TCL_ARGS);
int sc_createbase     (Tcl_Interp * ti, const char * filename,
                       scidBaseT * base, bool memoryOnly);
int sc_base_create    (TCL_ARGS);
int sc_base_close     (TCL_ARGS);
int sc_base_count     (TCL_ARGS);
int sc_base_description (TCL_ARGS);
int sc_base_export    (TCL_ARGS);
int sc_base_import    (Tcl_Interp* ti, scidBaseT* cdb, const char * filename);
int sc_base_numGames  (TCL_ARGS);
int sc_base_slot      (TCL_ARGS);
int sc_base_stats     (TCL_ARGS);
int sc_base_ecoStats  (TCL_ARGS);
int sc_base_piecetrack (TCL_ARGS);
int sc_base_switch    (TCL_ARGS);
int sc_base_tag       (TCL_ARGS);
int sc_base_tournaments (TCL_ARGS);
int sc_base_type      (TCL_ARGS);
int sc_base_upgrade   (TCL_ARGS);

int sc_clipbase       (TCL_ARGS);
int sc_clipbase_paste (TCL_ARGS);

int sc_eco            (TCL_ARGS);
int sc_eco_base       (TCL_ARGS);
int sc_eco_game       (TCL_ARGS);
int sc_eco_read       (TCL_ARGS);
int sc_eco_summary    (TCL_ARGS);
int sc_eco_translate  (TCL_ARGS);

int sc_filter         (TCL_ARGS);
int sc_filter_first   (TCL_ARGS);
int sc_filter_freq    (scidBaseT* dbase, Filter* filter, Tcl_Interp * ti, int argc, const char ** argv);
int sc_filter_last    (TCL_ARGS);
int sc_filter_next    (TCL_ARGS);
int sc_filter_prev    (TCL_ARGS);
int sc_filter_stats   (TCL_ARGS);

int sc_game           (TCL_ARGS);
int sc_game_crosstable (TCL_ARGS);
int sc_game_find      (TCL_ARGS);
int sc_game_firstMoves (TCL_ARGS);
int sc_game_flag      (TCL_ARGS);
int sc_game_import    (TCL_ARGS);
int sc_game_info      (TCL_ARGS);
int sc_game_load      (TCL_ARGS);
int sc_game_merge     (TCL_ARGS);
int sc_game_moves     (TCL_ARGS);
int sc_game_novelty   (TCL_ARGS);
int sc_game_new       (TCL_ARGS);
int sc_game_pgn       (TCL_ARGS);
int sc_game_pop       (TCL_ARGS);
int sc_game_push      (TCL_ARGS);
int sc_game_save      (TCL_ARGS);
int sc_game_scores    (TCL_ARGS);
int sc_game_startBoard (TCL_ARGS);
int sc_game_strip     (TCL_ARGS);
int sc_game_summary   (TCL_ARGS);
int sc_game_tags      (TCL_ARGS);
int sc_game_tags_get  (TCL_ARGS);
int sc_game_tags_set  (TCL_ARGS);
int sc_game_tags_reload (TCL_ARGS);
int sc_game_tags_share (TCL_ARGS);

int sc_info           (TCL_ARGS);
int sc_info_fsize     (TCL_ARGS);
int sc_info_limit     (TCL_ARGS);
int sc_info_suffix    (TCL_ARGS);
int sc_info_tb        (TCL_ARGS);

int sc_move           (TCL_ARGS);
int sc_move_add       (TCL_ARGS);
int sc_move_addSan    (TCL_ARGS);
int sc_move_addUCI    (TCL_ARGS);
int sc_move_back      (TCL_ARGS);
int sc_move_forward   (TCL_ARGS);
int sc_move_pgn       (TCL_ARGS);

int sc_name           (TCL_ARGS);
int sc_name_correct   (TCL_ARGS);
int sc_name_edit      (TCL_ARGS);
int sc_name_info      (TCL_ARGS);
int sc_name_match     (TCL_ARGS);
int sc_name_plist     (TCL_ARGS);
int sc_name_ratings   (TCL_ARGS);
int sc_name_read      (TCL_ARGS);
int sc_name_spellcheck (TCL_ARGS);
int sc_name_retrievename   (TCL_ARGS);

int sc_report         (TCL_ARGS);
int sc_report_create  (TCL_ARGS);
int sc_report_select  (TCL_ARGS);

int sc_pos            (TCL_ARGS);
int sc_pos_addNag     (TCL_ARGS);
int sc_pos_analyze    (TCL_ARGS);
int sc_pos_bestSquare (TCL_ARGS);
int sc_pos_getNags    (TCL_ARGS);
int sc_pos_hash       (TCL_ARGS);
int sc_pos_html       (TCL_ARGS);
int sc_pos_isAt       (TCL_ARGS);
int sc_pos_isLegal    (TCL_ARGS);
int sc_pos_isPromo    (TCL_ARGS);
int sc_pos_matchMoves (TCL_ARGS);
int sc_pos_moves      (TCL_ARGS);
int sc_pos_pgnBoard   (TCL_ARGS);
int sc_pos_probe      (TCL_ARGS);
int sc_pos_probe_board (TCL_ARGS);
int sc_pos_setComment (TCL_ARGS);

int sc_progressBar    (TCL_ARGS);

int sc_tree           (TCL_ARGS);
int sc_tree_move      (TCL_ARGS);
int sc_tree_search    (TCL_ARGS);
int sc_tree_write     (TCL_ARGS);
int sc_tree_cachesize (TCL_ARGS);
int sc_tree_cacheinfo (TCL_ARGS);
int sc_tree_clean     (TCL_ARGS);

int sc_var            (TCL_ARGS);
int sc_var_delete     (TCL_ARGS);
int sc_var_delete_free(TCL_ARGS);
int sc_var_enter      (TCL_ARGS);
int sc_var_first      (TCL_ARGS);
int sc_var_list       (TCL_ARGS);

int sc_search         (TCL_ARGS);
int sc_search_board   (TCL_ARGS);
int sc_search_material (TCL_ARGS);
int sc_search_header  (ClientData cd, Tcl_Interp * ti, scidBaseT* base, Filter* filter, int argc, const char ** argv);
int sc_search_rep_add (TCL_ARGS);
int sc_search_rep_go  (TCL_ARGS);

int sc_book           (TCL_ARGS);
int sc_book_load      (TCL_ARGS);
int sc_book_close     (TCL_ARGS);
int sc_book_moves     (TCL_ARGS);
int sc_book_positions (TCL_ARGS);
int sc_book_update    (TCL_ARGS);
int sc_book_movesupdate (TCL_ARGS);
//////////////////////////////////////////////////////////////////////
/// END of tkscid.h
//////////////////////////////////////////////////////////////////////
