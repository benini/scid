//////////////////////////////////////////////////////////////////////
//
//  FILE:       optable.h
//              OpTable class (for opening reports and theory tables)
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    3.1
//
//  Notice:     Copyright (c) 2001  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (shane@cosc.canterbury.ac.nz)
//
//////////////////////////////////////////////////////////////////////

#ifndef SCID_OPTABLE_H
#define SCID_OPTABLE_H

#include "common.h"
#include "namebase.h"
#include "index.h"
#include "game.h"
#include "pbook.h"

const uint OPTABLE_COLUMNS = 8;
const uint OPTABLE_MIN_ROWS = 5;
const uint OPTABLE_MAX_ROWS = 20;
const uint OPTABLE_DEFAULT_ROWS = 10;
const uint OPTABLE_MAX_EXTRA_MOVES = 10;
const uint OPLINE_MOVES = (OPTABLE_COLUMNS + OPTABLE_MAX_EXTRA_MOVES) * 2;
const uint OPTABLE_MAX_LINES = 2000;
const uint OPTABLE_MAX_TABLE_LINES = 500;
const uint OPTABLE_MAX_STARTLINE = 100;

const uint OPTABLE_Text  = 0;
const uint OPTABLE_HTML  = 1;
const uint OPTABLE_LaTeX = 2;
const uint OPTABLE_CText = 3;    // Color hypertext.
const uint OPTABLE_Compact = 4;  // For more compact moves in table.

const uint NUM_OPTHEMES = 10;
const uint OPTHEME_CastSame = 0;
const uint OPTHEME_CastOpp = 1;
const uint OPTHEME_CastNone = 2;
const uint OPTHEME_Kstorm = 3;
const uint OPTHEME_QueenSwap = 4;
const uint OPTHEME_IQP = 5;
const uint OPTHEME_WAdvPawn = 6;
const uint OPTHEME_BAdvPawn = 7;
const uint OPTHEME_OpenFyle = 8;
const uint OPTHEME_BPair = 9;

const uint NUM_EGTHEMES = 8;
const uint EGTHEME_P = 0;
const uint EGTHEME_M = 1;
const uint EGTHEME_R = 2;
const uint EGTHEME_RM = 3;
const uint EGTHEME_Q = 4;
const uint EGTHEME_QM = 5;
const uint EGTHEME_QR = 6;
const uint EGTHEME_QRM = 7;

const uint OPTABLE_Line = 0;
const uint OPTABLE_All = 1;


struct moveOrderT {
    uint id;       // Move Order id number
    uint count;    // Number of times this order has occured
    char * moves;  // String containing the moves in SAN notation
};

class OpLine
{
  friend class OpTable;
  private:
    char *      White;
    char *      Black;
    char *      Site;
    gameNumberT GameNumber;
    idNumberT   WhiteID;
    idNumberT   BlackID;
    eloT        WhiteElo;   // Actual White rating (no estimate)
    eloT        BlackElo;   // Actual Black rating
    eloT        AvgElo;     // Average Elo (using actual or estimates)
    dateT       Date;
    resultT     Result;
    uint        Length;
    uint        NumMoves;
    bool        ShortGame;     // True if all game ends early enough that
                               // this line contains all its moves.
    uint        MoveOrderID;
    sanStringT  Move [OPLINE_MOVES];
    uint        NoteMoveNum;  // If a note, at what move does it start?
    uint        NoteNumber;   // If a note, this stores its footnote number.
    OpLine *    Next;         // Linked list used for sorting and footnotes.
    bool        Selected;     // For selecting lines by some criteria.
    uint        StartPly;

    bool        Theme [NUM_OPTHEMES];
    uint        EgTheme;

    void Init (void);
    void Init (Game * g, IndexEntry * ie, gameNumberT gameNum,
               uint maxExtraMoves);
    void Destroy (void);

  public:

    OpLine () { Init(); }
    OpLine (Game * g, IndexEntry * ie, gameNumberT gnum, uint max) {
        Init (g, ie, gnum, max);
    }
    ~OpLine() { }
    void Insert (OpLine * subline);
    void SetMoveOrderID (uint id) { MoveOrderID = id; }
    uint CommonLength (OpLine * line);
    static void PrintMove (DString * dstr, const char * move, uint format);
    void PrintNote (DString * dstr, uint movenum, uint start, uint format);
    void PrintSummary (DString * dstr, uint format, bool fullDate, bool nmoves);

    const char * GetMove (uint depth) { return Move[depth]; }
};


class OpTable
{
  private:
    uint        NumRows;
    uint        TargetRows;
    uint        NumLines;
    uint        FilterCount;
    uint        NumTableLines;
    uint        MaxTableLines;
    uint        MaxNoteLength;
    uint        NumNotes;
    uint        Format;
    bool        WTM;    // whether White is to move in the start position.
    sanStringT  StartLine [OPTABLE_MAX_STARTLINE];
    uint        StartLength;
    OpLine *    Line [OPTABLE_MAX_LINES];
    uint        Results [NUM_RESULT_TYPES];
    uint        TheoryResults [NUM_RESULT_TYPES];
    uint        TheoryCount;
    char *      EcoStr;
    sanStringT  ExcludeMove;
    char        DecimalChar;

    // Statistics on material of final positions:
    uint        EndgameCount [2][NUM_EGTHEMES];

    // Statistics on move orders to reach the start line:
    uint        NumMoveOrders;
    moveOrderT  MoveOrder [OPTABLE_MAX_LINES];

    // Statistics on themes:
    uint        ThemeCount [NUM_OPTHEMES];

    // Arrays for making rows out of the lines:
    OpLine *    Row [OPTABLE_MAX_TABLE_LINES];
    uint        NLines [OPTABLE_MAX_TABLE_LINES];
    uint        RowScore [OPTABLE_MAX_TABLE_LINES];

    void SelectTableLines (void);
    void SortTableLines (OpLine ** lines, uint nlines, uint depth);
    bool IsRowMergable (uint rownum);
    void MergeRow (uint rownum);
    bool HasNotes (OpLine * line, uint movenum);
    uint NoteCount (uint note);
    uint NoteScore (uint note);
    void PrintNotes (DString * dstr, uint format);
    
  public:

    OpTable (Game * g, PBook * ecoBook) { Init (g, ecoBook); }
    OpTable (Game * g) { Init (g, NULL); }
    ~OpTable() { Clear(); }
    void Init (Game * g, PBook * ecoBook);
    void Clear ();
    void ClearNotes ();
    void SetFormat (const char * str);
    void SetDecimalChar (char c) { DecimalChar = c; }

    uint GetTotalCount() { return FilterCount; }
    uint GetTheoryCount() { return TheoryCount; }

    void   SetExcludeMove (const char * s) {
        strCopy (ExcludeMove, s);
        strStrip (ExcludeMove, '-');
        strStrip (ExcludeMove, '=');
    }
    const char * GetEco (void) { return (EcoStr != NULL ? EcoStr : ""); }
    void   SetNumRows (uint nrows) { TargetRows = nrows; }
    void   GuessNumRows (void);
    void   SetMaxTableLines (uint nlines) {
        if (nlines <= OPTABLE_MAX_TABLE_LINES) {
            MaxTableLines = nlines;
        }
    }
    uint   GetMaxTableLines (void) { return MaxTableLines; }
    void   SetMaxExtraMoves (uint nmoves) {
        MaxNoteLength = (OPTABLE_COLUMNS + nmoves) * 2;
    }
    uint   GetMaxExtraMoves (void) {
        return (MaxNoteLength / 2) - OPTABLE_COLUMNS;
    }
    uint   GetNumLines (void) { return NumLines; }
    bool   Add (OpLine * line);
    uint   PercentScore (void);
    uint   TheoryPercent (void);
    uint   TheoryScore (void);
    uint   PercentFreq (resultT result);
    uint   AvgLength (resultT result);
    uint   AvgElo (colorT color, uint *count, uint *oppScore, uint *oppPerf);
    void   BestGames (DString * dstr, uint count, const char * rtype);
    void   TopPlayers (DString * dstr, colorT c, uint count);
    void   PrintStemLine (DString * dstr, uint format, bool exclude);
    void   PrintStemLine (DString * dstr) { PrintStemLine (dstr, Format, false); }
    void   MakeRows (void);
    void   DumpLines (FILE * fp);
    void   PrintTable (DString * dstr, const char *title, const char *comment);
    void   PrintLaTeX (DString * dstr,const char *title, const char *comment);
    void   PrintHTML (DString * str, const char *title, const char *comment);
    void   PrintText (DString * str, const char *title, const char *comment,
                      bool htext);
    static uint FormatFromStr (const char * str);
    uint   AddMoveOrder (Game * g);
    void   PopularMoveOrders (DString * dstr, uint count);
    void   ThemeReport (DString * dstr, uint argc, const char ** argv);
    void   AddEndMaterial (matSigT ms, bool inFilter);
    void   EndMaterialReport (DString * dstr, const char * repGames,
                              const char * allGames);
    uint * SelectGames (char type, uint number);
};

#endif // SCID_OPTABLE_H

//////////////////////////////////////////////////////////////////////
// optable.h
//////////////////////////////////////////////////////////////////////
