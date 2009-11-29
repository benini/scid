/////////////////////////////////////////////////////////////////////
//
//  FILE:       tkscid.h
//              Scid extensions to Tcl/Tk interpreter
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    3.6.4
//
//  Notice:     Copyright (c) 1999-2004 Shane Hudson.  All rights reserved.
//              Copyright (c) 2006-2007 Pascal Georges
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

#include "tclmy.h"

#include <unistd.h>

// Include header files for finding directory of executable program
// in Windows if necessary.
// Note: I have no idea what the WIN32_LEAN_AND_MEAN definition when
// including windows.h does, but lots of other source code I have seen
// does it -- although "lean Windows" sure is an oxymoron!
#ifdef WIN32
#  define WIN32_LEAN_AND_MEAN 1
#  include <windows.h>
#  undef WIN32_LEAN_AND_MEAN
#  include <winbase.h>
#else
#  include <sys/resource.h>   // For getpriority() and setpriority().
#endif

#include <stdio.h>
#include <ctype.h>
#include <sys/stat.h>

#include <tcl.h>
#ifndef TCL_ONLY
#  include <tk.h>
#endif

// Some character pointer arguments (like "char ***" to Tcl_SplitList)
// changed const-ness from Tcl/Tk 8.3 to 8.4 and g++ cannot handle
// implicit (char ***) <-> (const char ***) conversions, so CONST84
// is "const" if set from tcl.h, otherwise it is nothing:
#ifndef CONST84
#  define CONST84
#endif

#ifdef WINCE
#include "tclmy.h"
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

#ifdef WINCE
const uint SCID_TreeCacheSize = 50;
const uint SCID_BackupCacheSize = 20;
#else
// TreeCache size for each open database:
const uint SCID_TreeCacheSize = 1000; //250

// Secondary (memory only) TreeCache size:
const uint SCID_BackupCacheSize = 100;
#endif

// Number of undo levels
#define UNDO_MAX 10

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


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Scid database stats structure:
//    This is maintained and recalculated each time a game in the
//    database is modified to save time updating the file stats window.
//

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
#ifndef WINCE
    ecoStatsT ecoCount0 [1];
    ecoStatsT ecoCount1 [5];
    ecoStatsT ecoCount2 [50];
    ecoStatsT ecoCount3 [500];
    ecoStatsT ecoCount4 [500*26];
#endif
};


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Scid database structure:
//
struct scidBaseT {
    Index *      idx;           // the Index file in memory for this base.
    NameBase *   nb;            // the NameBase file in memory.
    Game *       game;          // the active game for this base.
    Game *       undoGame[UNDO_MAX]; // array of games kept for undos
    int          undoIndex;
    int          gameNumber;    // game number of active game.
    bool         gameAltered;   // true if game is modified
    bool         inUse;         // true if the database is open (in use).
    uint         numGames;
    bool         memoryOnly;

    scidStatsT   stats;         // Counts of flags, average rating, etc.

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
    Filter *     filter;
    uint *       duplicates;  // For each game: idx of duplicate game + 1,
                              // or 0 if there is no duplicate.
};


//////////////////////////////////////////////////////////////////////
//
// Inline routines for setting Tcl result strings:
//


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// setResult():
//    Inline function to set the Tcl interpreter result to a
//    constant string.
inline int
setResult (Tcl_Interp * ti, const char * str)
{
    Tcl_SetResult (ti, (char *) str, TCL_STATIC);
    return TCL_OK;
}

//~~~~~~~~~~~~~~~~~~
// errorResult():
//    Same as setResult, but returns TCL_ERROR so callers can simply:
//        return errorResult (ti, "error message");
//    instead of:
//        Tcl_SetResult (ti, "error message");
//        return TCL_ERROR;
inline int
errorResult (Tcl_Interp * ti, const char * str)
{
    Tcl_SetResult (ti, (char *) str, TCL_STATIC);
    return TCL_ERROR;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// setBoolResult():
//    Inline function to set the Tcl interpreter result to a
//    boolean value.
inline int
setBoolResult (Tcl_Interp * ti, bool b)
{
    Tcl_SetResult (ti, b ? (char *) "1" : (char *) "0", TCL_STATIC);
    return TCL_OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// setIntResult():
//    Inline function to set the Tcl interpreter result to a
//    signed integer value.
inline int
setIntResult (Tcl_Interp * ti, int i)
{
    char temp [20];
    sprintf (temp, "%d", i);
    Tcl_SetResult (ti, temp, TCL_VOLATILE);
    return TCL_OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// setUintResult():
//    Inline function to set the Tcl interpreter result to an
//    unsigned integer value.
inline int
setUintResult (Tcl_Interp * ti, uint i)
{
    char temp [20];
    sprintf (temp, "%u", i);
    Tcl_SetResult (ti, temp, TCL_VOLATILE);
    return TCL_OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// appendIntResult:
//    Inline function to append the specified signed value to the
//    Tcl interpreter result.
inline int
appendIntResult (Tcl_Interp * ti, int i)
{
    char temp [20];
    sprintf (temp, "%d", i);
    Tcl_AppendResult (ti, temp, NULL);
    return TCL_OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// appendUintResult:
//    Inline function to append the specified unsigned value to the
//    Tcl interpreter result.
inline int
appendUintResult (Tcl_Interp * ti, uint i)
{
    char temp [20];
    sprintf (temp, "%u", i);
    Tcl_AppendResult (ti, temp, NULL);
    return TCL_OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// appendUintElement:
//    Inline function to append the specified unsigned value to the
//    Tcl interpreter list result.
inline uint
appendUintElement (Tcl_Interp * ti, uint i)
{
    char temp[20];
    sprintf (temp, "%u", i);
    Tcl_AppendElement (ti, temp);
    return TCL_OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// setUintWidthResult():
//    Inline function to set the Tcl interpreter result to an
//    unsigned integer value, with zeroes to pad to the desired width.
inline int
setUintWidthResult (Tcl_Interp * ti, uint i, uint width)
{
    char temp [20];
    sprintf (temp, "%0*u", width, i);
    Tcl_SetResult (ti, temp, TCL_VOLATILE);
    return TCL_OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// setCharResult():
//    Inline function to set the Tcl interpreter result to a character value.
inline int
setCharResult (Tcl_Interp * ti, char ch)
{
    char tempStr [4];
    tempStr[0] = ch;
    tempStr[1] = 0;
    Tcl_SetResult (ti, tempStr, TCL_VOLATILE);
    return TCL_OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// appendCharResult:
//    Inline function to append the specified character value to the
//    Tcl interpreter result.
inline int
appendCharResult (Tcl_Interp * ti, char ch)
{
    char tempStr [4];
    tempStr[0] = ch;
    tempStr[1] = 0;
    Tcl_AppendResult (ti, tempStr, NULL);
    return TCL_OK;
}

void transPieces(char *s);

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// translate:
//    Return the translation for a phrase.
//
inline const char *
translate (Tcl_Interp * ti, const char * name, const char * defaultText)
{
#ifdef WINCE
    return name;
#else
    const char * str = Tcl_GetVar2 (ti, "tr", (char *) name, TCL_GLOBAL_ONLY);
    if (str == NULL) { str = defaultText; }
    return str;
#endif
}

inline const char *
translate (Tcl_Interp * ti, const char * name)
{
#ifdef WINCE
    return name;
#else
    return translate (ti, name, name);
#endif
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// manage undo functions
//
void sc_game_save_for_undo ();
void sc_game_undo_reset();

//////////////////////////////////////////////////////////////////////
// Declarations for Scid application-specific Tcl commands
//

// Macro TCL_ARGS expands to the argument-type list that any
// Tcl command function takes.

#define TCL_ARGS  ClientData cd, Tcl_Interp * ti, int argc, const char ** argv

int str_is_prefix  (TCL_ARGS);
int str_prefix_len (TCL_ARGS);
#ifdef POCKET
int sc_msg            (TCL_ARGS);
int sc_msg_init       (TCL_ARGS);
int sc_msg_close      (TCL_ARGS);
int sc_msg_send       (TCL_ARGS);
int sc_msg_recv       (TCL_ARGS);
int sc_msg_info       (TCL_ARGS);
#endif
int sc_base           (TCL_ARGS);
int sc_base_autoload  (TCL_ARGS);
int sc_base_filename  (TCL_ARGS);
int sc_base_inUse     (TCL_ARGS);
int sc_base_duplicates (TCL_ARGS);
int sc_base_open      (TCL_ARGS);
int sc_createbase     (Tcl_Interp * ti, const char * filename,
                       scidBaseT * base, bool memoryOnly);
int sc_base_create    (TCL_ARGS);
int sc_base_close     (TCL_ARGS);
int sc_base_count     (TCL_ARGS);
int sc_base_description (TCL_ARGS);
int sc_base_export    (TCL_ARGS);
int sc_base_import    (TCL_ARGS);
int sc_base_numGames  (TCL_ARGS);
int sc_base_slot      (TCL_ARGS);
int sc_base_stats     (TCL_ARGS);
int sc_base_ecoStats  (TCL_ARGS);
int sc_base_piecetrack (TCL_ARGS);
int sc_base_sort      (TCL_ARGS);
int sc_base_switch    (TCL_ARGS);
int sc_base_tag       (TCL_ARGS);
int sc_base_tournaments (TCL_ARGS);
int sc_base_type      (TCL_ARGS);
int sc_base_upgrade   (TCL_ARGS);
int sc_base_fix_corrupted   (TCL_ARGS);

int sc_epd            (TCL_ARGS);
int sc_epd_deepest    (Tcl_Interp * ti, int epdID);
int sc_epd_moves      (Tcl_Interp * ti, int epdID);
int sc_epd_next       (Tcl_Interp * ti, int epdID, bool forwards);
int sc_epd_open       (Tcl_Interp * ti, int argc, const char ** argv, bool create);
int sc_epd_set        (Tcl_Interp * ti, int epdID, const char * text);
int sc_epd_write      (Tcl_Interp * ti, int epdID);
// int sc_epd_load      	(Tcl_Interp * ti, int epdID, int from, int to);

int sc_clipbase       (TCL_ARGS);
int sc_clipbase_clear (Tcl_Interp * ti);
int sc_clipbase_copy  (TCL_ARGS);
int sc_clipbase_paste (TCL_ARGS);

int sc_compact        (TCL_ARGS);
int sc_compact_games  (TCL_ARGS);
int sc_compact_names  (TCL_ARGS);
int sc_compact_stats  (TCL_ARGS);

int sc_eco            (TCL_ARGS);
int sc_eco_base       (TCL_ARGS);
int sc_eco_game       (TCL_ARGS);
int sc_eco_read       (TCL_ARGS);
int sc_eco_summary    (TCL_ARGS);
int sc_eco_translate  (TCL_ARGS);

int sc_filter         (TCL_ARGS);
int sc_filter_count   (TCL_ARGS);
int sc_filter_copy    (TCL_ARGS);
int sc_filter_first   (TCL_ARGS);
int sc_filter_freq    (TCL_ARGS);
int sc_filter_index   (TCL_ARGS);
int sc_filter_last    (TCL_ARGS);
int sc_filter_locate  (TCL_ARGS);
int sc_filter_negate  (TCL_ARGS);
int sc_filter_next    (TCL_ARGS);
int sc_filter_prev    (TCL_ARGS);
int sc_filter_remove  (TCL_ARGS);
int sc_filter_reset   (TCL_ARGS);
int sc_filter_stats   (TCL_ARGS);
int sc_filter_textfind (TCL_ARGS);
int sc_filter_value   (TCL_ARGS);

int sc_game           (TCL_ARGS);
int sc_game_crosstable (TCL_ARGS);
int sc_game_find      (TCL_ARGS);
int sc_game_firstMoves (TCL_ARGS);
int sc_game_flag      (TCL_ARGS);
int sc_game_import    (TCL_ARGS);
int sc_game_info      (TCL_ARGS);
int sc_game_list      (TCL_ARGS);
int sc_game_load      (TCL_ARGS);
int sc_game_merge     (TCL_ARGS);
int sc_game_moves     (TCL_ARGS);
int sc_game_novelty   (TCL_ARGS);
int sc_game_new       (TCL_ARGS);
int sc_game_pgn       (TCL_ARGS);
int sc_game_pop       (TCL_ARGS);
int sc_game_push      (TCL_ARGS);
int sc_savegame       (Tcl_Interp *, Game * game, gameNumberT, scidBaseT *);
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
int sc_info_priority  (TCL_ARGS);
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
int sc_tree_best      (TCL_ARGS);
int sc_tree_move      (TCL_ARGS);
int sc_tree_search    (TCL_ARGS);
int sc_tree_time      (TCL_ARGS);
int sc_tree_write     (TCL_ARGS);
int sc_tree_free      (TCL_ARGS);
int sc_tree_cachesize (TCL_ARGS);
int sc_tree_cacheinfo (TCL_ARGS);

int sc_var            (TCL_ARGS);
int sc_var_delete     (TCL_ARGS);
int sc_var_delete_free(TCL_ARGS);
int sc_var_enter      (TCL_ARGS);
int sc_var_first      (TCL_ARGS);
int sc_var_list       (TCL_ARGS);
int sc_var_promote    (TCL_ARGS);

int sc_search         (TCL_ARGS);
int sc_search_board   (TCL_ARGS);
int sc_search_material (TCL_ARGS);
int sc_search_header  (TCL_ARGS);
int sc_search_repertoire (TCL_ARGS);
int sc_search_rep_add (TCL_ARGS);
int sc_search_rep_go  (TCL_ARGS);

int sc_book  					(TCL_ARGS);
int sc_book_load  		(TCL_ARGS);
int sc_book_close  		(TCL_ARGS);
int sc_book_moves  		(TCL_ARGS);
int sc_book_positions  		(TCL_ARGS);
int sc_book_update		(TCL_ARGS);
int sc_book_movesupdate	(TCL_ARGS);
//////////////////////////////////////////////////////////////////////
/// END of tkscid.h
//////////////////////////////////////////////////////////////////////
