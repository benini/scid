//////////////////////////////////////////////////////////////////////
//
//  FILE:       game.h
//              Game class for Scid.
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    3.4
//
//  Notice:     Copyright (c) 2000-2002 Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////


#ifndef SCID_GAME_H
#define SCID_GAME_H

#include "common.h"
#include "date.h"
#include "index.h"
#include "position.h"
#include "namebase.h"
#include "textbuf.h"
#include "bytebuf.h"
#include "matsig.h"


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//  Game: Constants



// Common NAG Annotation symbol values:
const byte
    NAG_GoodMove = 1,
    NAG_PoorMove = 2,
    NAG_ExcellentMove = 3,
    NAG_Blunder = 4,
    NAG_InterestingMove = 5,
    NAG_DubiousMove = 6,
    NAG_Equal = 10,
    NAG_Unclear = 13,
    NAG_WhiteSlight = 14,
    NAG_BlackSlight = 15,
    NAG_WhiteClear = 16,
    NAG_BlackClear = 17,
    NAG_WhiteDecisive = 18,
    NAG_BlackDecisive = 19,
    NAG_WhiteCrushing = 20,
    NAG_BlackCrushing = 21,
    NAG_Compensation = 44,
    NAG_Novelty = 146,
    NAG_Diagram = 201;  // Scid-specific NAGs start at 201.


// MAX_TAGS: Maximum number of additional non-standard tags.
const uint MAX_TAGS =  40;

const uint MAX_TAG_LEN = 240;

typedef byte markerT;
const markerT
    NO_MARKER = 0,
    START_MARKER = 1,
    END_MARKER = 2,
    END_GAME = 3;


// patternT structure: a pattern filter for material searches.
//    It can specify, for example, a white Pawn on the f-fyle, or
//    a black Bishop on f2 and white King on e1.
struct patternT
{
    pieceT     pieceMatch;  // EMPTY, WK, BK, etc...
    rankT      rankMatch;   // RANK_1 .. RANK_8 or NO_RANK
    fyleT      fyleMatch;   // A_FYLE .. H_FYLE or NO_FYLE
    byte       flag;        // 0 means this pattern must NOT occur.
    patternT * next;
};

// MAX_NAGS is the maximum number of NAGs (annotation symbols) a single
// move can have:

#define MAX_NAGS 8


// The moveT structure stores all necessary information for one move:
//
struct moveT
{
    simpleMoveT  moveData;      // piece moving, target square etc
    char         san[10];           // SAN representation of move
    char       * comment;
    moveT      * prev;
    moveT      * next;
    moveT      * varChild;
    moveT      * varParent;
    markerT      marker;  // can be NO_MARKER, START_MARKER or END_MARKER
    byte         numVariations;
    byte         nagCount;
    byte         nags[MAX_NAGS];
};

inline bool
isNullMove (moveT * m)
{
    return isNullMove(&(m->moveData));
}


// Since we want allocation and freeing of moves to be FAST, we allocate
// in chunks, and keep a linked list of the chunks allocated.
// Freed moves can be added to the FreeList, but it is not essential to
// do so, since all space for moves is deleted when the game is cleared.

#define MOVE_CHUNKSIZE 100    // Allocate space for 100 moves at a time.

struct moveChunkT {
    moveT moves [MOVE_CHUNKSIZE];
    uint numFree;
    moveChunkT * next;
};


struct tagT
{
    char * tag;
    char * value;
};


#define GAME_DECODE_NONE 0
#define GAME_DECODE_TAGS 1
#define GAME_DECODE_COMMENTS 2
#define GAME_DECODE_ALL 3

enum gameExactMatchT {
    GAME_EXACT_MATCH_Exact = 0,
    GAME_EXACT_MATCH_Pawns,
    GAME_EXACT_MATCH_Fyles,
    GAME_EXACT_MATCH_Material
};

enum gameFormatT {
    PGN_FORMAT_Plain = 0,   // Plain regular PGN output
    PGN_FORMAT_HTML = 1,    // HTML format
    PGN_FORMAT_LaTeX = 2,   // LaTeX (with chess12 package) format
    PGN_FORMAT_Color = 3    // PGN, with color tags <red> etc
};

#define PGN_STYLE_TAGS             1
#define PGN_STYLE_COMMENTS         2
#define PGN_STYLE_VARS             4
#define PGN_STYLE_INDENT_COMMENTS  8
#define PGN_STYLE_INDENT_VARS     16
#define PGN_STYLE_SYMBOLS         32   // e.g. "! +-" instead of "$2 $14"
#define PGN_STYLE_SHORT_HEADER    64
#define PGN_STYLE_MOVENUM_SPACE  128   // Space after move numbers.
#define PGN_STYLE_COLUMN         256   // Column style: one move per line.
#define PGN_STYLE_SCIDFLAGS      512
#define PGN_STYLE_STRIP_MARKS   1024   // Strip [%mark] and [%arrow] codes.
#define PGN_STYLE_NO_NULL_MOVES 2048   // Convert null moves to comments.


void  game_printNag (byte nag, char * str, bool asSymbol, gameFormatT format);
byte  game_parseNag (const char * str);

uint strGetRatingType (const char * name);


//////////////////////////////////////////////////////////////////////
//  Game:  Class Definition

class Game
{
private:
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //  Game:  Data structures

    gameNumberT GameNumber;     // first game in file is game 0
    bool        NonStandardStart;      // 1 if non-standard start.
    char *      FenString;      // fen string if non-standard start.
    colorT      ToMove;         // side to move in starting position
    ushort      NumHalfMoves;
    ushort      CurrentPlyCount;
    ushort      StartPlyCount;
    bool        KeepDecodedMoves;

    Game *      NextGame;     // For keeping a linked list of games.
    bool        Altered;

    matSigT     FinalMatSig;

    bool        PromotionsFlag;   // True if game has a promotion.
    bool        UnderPromosFlag;  // True if game has a promotion to R/B/N.
    char        ScidFlags [16];

    moveChunkT * MoveChunk;
    moveT *     FreeList;

    char *      EventStr;
    char *      SiteStr;
    char *      WhiteStr;
    char *      BlackStr;
    char *      RoundStr;
    dateT       Date;
    dateT       EventDate;
    resultT     Result;
    ecoT        EcoCode;
    eloT        WhiteElo;
    eloT        BlackElo;
    byte        WhiteRatingType;
    byte        BlackRatingType;
    eloT        WhiteEstimateElo;
    eloT        BlackEstimateElo;

    Position *  StartPos;
    Position *  CurrentPos;

    moveT *     FirstMove;
    moveT *     CurrentMove;
    uint        VarDepth;     // Current variation depth.

    // For saving and restoring game state:
    Position *  SavedPos;
    moveT *     SavedMove;
    ushort      SavedPlyCount;
    uint        SavedVarDepth;

    StrAllocator * StrAlloc;   // For fast compact allocation of memory
                               // for comments.

    NameBase *  NBase;      // needed for referencing id numbers.

    tagT        TagList [MAX_TAGS];
    uint        NumTags;

    uint        NumMovesPrinted; // Used in recursive WriteMoveList method.
    uint        StopLocation;    // Used in recursive WriteMoveList method.

    uint        PgnStyle;        // see PGN_STYLE macros above.
    gameFormatT PgnFormat;       // see PGN_FORMAT macros above.
    uint        HtmlStyle;       // HTML diagram style, see
                                 //   DumpHtmlBoard method in position.cpp.
    uint        PgnLastMovePos;  // The place of the last move in the
                                 // PGN output, as a byte offset.
    uint        PgnNextMovePos;  // The place of the next move in the
                                 // PGN output, as a byte offset.

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //  Game:  Private Functions

    void       AllocateMoreMoves ();
    inline moveT *    NewMove();
    inline void       FreeMove (moveT * move);

    errorT     DecodeTags (ByteBuffer * buf, bool storeTags);
    errorT     DecodeVariation (ByteBuffer * buf, byte flags, uint level);

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //  Game:  Public Functions
public:

    Game()      { Init(); }
    ~Game() {
        // Delete the comment string allocator object:
        delete StrAlloc;
        // Delete the Current position:
        delete CurrentPos;
        // Delete the saved position:
        if (SavedPos) { delete SavedPos; }
        // Delete the start position:
        if (StartPos) { delete StartPos; }
    };

    void        Clear();
    void        ClearMoves();

    void        Init();

    // Set and Get attributes -- one-line (inline) methods
    void         SetNumber (gameNumberT num) { GameNumber = num; }
    gameNumberT  GetNumber ()                { return GameNumber; }
    void        SetNumHalfMoves (ushort x)  { NumHalfMoves = x; }
    ushort      GetNumHalfMoves ()          { return NumHalfMoves; }
    ushort      GetCurrentPly()             { return CurrentPlyCount; }

    void        SetNextGame (Game * g)      { NextGame = g; }
    Game *      GetNextGame ()              { return NextGame; }
    void        SetAltered (bool b)         { Altered = b; }
    bool        GetAltered (void)           { return Altered; }
    
    bool        HasNonStandardStart ()      { return NonStandardStart; }
//    byte        GetNagsFlag ()              { return NagsFlag; }
//    byte        GetVarsFlag ()              { return VarsFlag; }
//    byte        GetCommentsFlag ()          { return CommentsFlag; }
    bool        HasPromotions ()            { return PromotionsFlag; }
    bool        HasUnderPromotions ()       { return UnderPromosFlag; }

    void        SetNameBase (NameBase * nb) { NBase = nb; }
    NameBase *  GetNameBase ()              { return NBase; }

    void        SetStartPos (Position * pos);
    errorT      SetStartFen (const char * fenStr);

    void        SetScidFlags (const char * s) { strCopy (ScidFlags, s); }
    const char * GetScidFlags ()              { return ScidFlags; }

    Position *  GetStartPos ()              { return StartPos; }
    Position *  GetCurrentPos ()            { return CurrentPos; }

    simpleMoveT * GetCurrentMove () {
        moveT * m = CurrentMove;
        if (m->marker == START_MARKER  ||  m->marker == END_MARKER) {
            return NULL;
        }
        return &(m->moveData);
    }

    inline void InitMove (moveT * m);

    void     SaveState ();
    errorT   RestoreState();

    void     SetMoveData (moveT * m, simpleMoveT * sm);
    errorT   AddMove (simpleMoveT * sm, char * san);
    errorT   AddVariation ();
    errorT   DeleteSubVariation (moveT * m);
    errorT   DeleteVariation (uint varNumber);
    errorT   FirstVariation (uint varNumber);
    errorT   MainVariation (uint varNumber);

    void     SetMoveComment (const char * comment);
    char *   GetMoveComment () { return CurrentMove->prev->comment; }

    inline errorT AddNag (byte nag);
    byte *   GetNags () { return CurrentMove->prev->nags; }
    byte *   GetNextNags () { return CurrentMove->nags; }
    void     ClearNags () {
        CurrentMove->prev->nagCount = 0;
        CurrentMove->prev->nags[0] = 0;
    }

    void     MoveToPly (ushort hmNumber);
    errorT   MoveForward ();
    errorT   MoveBackup ();
    errorT   MoveIntoVariation (uint varNumber);
    errorT   MoveExitVariation ();

    int      AtStart ()
                 { return (CurrentMove->prev->marker == START_MARKER  &&
                           VarDepth == 0); }
    int      AtEnd ()
                 { return (CurrentMove->marker == END_MARKER  &&
                           VarDepth == 0); }
    int      AtVarStart ()
                 { return (CurrentMove->prev->marker == START_MARKER); }
    int      AtVarEnd ()
                 { return (CurrentMove->marker == END_MARKER); }
    uint     GetVarLevel () { return VarDepth; }
    uint      GetNumVariations ()
                 { return (uint) CurrentMove->numVariations; }

    void     Truncate ();
    void     TruncateBegin ();

    void     SetEventStr (const char * str);
    void     SetSiteStr (const char * str);
    void     SetWhiteStr (const char * str);
    void     SetBlackStr (const char * str);
    void     SetRoundStr (const char * str);
    void     SetDate (dateT date)    { Date = date; }
    void     SetEventDate (dateT date)  { EventDate = date; }
    void     SetResult (resultT res) { Result = res; }
    void     SetWhiteElo (eloT elo)  { WhiteElo = elo; }
    void     SetBlackElo (eloT elo)  { BlackElo = elo; }
    void     SetWhiteEstimateElo (eloT elo)  { WhiteEstimateElo = elo; }
    void     SetBlackEstimateElo (eloT elo)  { BlackEstimateElo = elo; }
    void     SetWhiteRatingType (byte b) { WhiteRatingType = b; }
    void     SetBlackRatingType (byte b) { BlackRatingType = b; }
    void     SetEco (ecoT eco)       { EcoCode = eco; }
    char *   GetEventStr ()          { return EventStr; }
    char *   GetSiteStr ()           { return SiteStr;  }
    char *   GetWhiteStr ()          { return WhiteStr; }
    char *   GetBlackStr ()          { return BlackStr; }
    char *   GetRoundStr ()          { return RoundStr; }
    dateT    GetDate ()              { return Date; }
    dateT    GetEventDate ()         { return EventDate; }
    resultT  GetResult ()            { return Result; }
    eloT     GetWhiteElo ()          { return WhiteElo; }
    eloT     GetBlackElo ()          { return BlackElo; }
    eloT     GetWhiteEstimateElo()   { return WhiteEstimateElo; }
    eloT     GetBlackEstimateElo()   { return BlackEstimateElo; }
    byte     GetWhiteRatingType ()   { return WhiteRatingType; }
    byte     GetBlackRatingType ()   { return BlackRatingType; }
    ecoT     GetEco ()               { return EcoCode; }
    eloT     GetAverageElo ();

    // Adding/Removing Extra  tags:
    void     AddPgnTag (const char * tag, const char * value);
    bool     RemoveExtraTag (const char * tag);
    const char * FindExtraTag (const char * tag);
    uint     GetNumExtraTags ()      { return NumTags; }
    tagT *   GetExtraTags ()         { return TagList; }
    void     ClearExtraTags ();

    uint     MakeHomePawnList (byte * pbPawnList);

    // Searching
    compareT CompareCurrentPos (Position * p);

    void      CopyStandardTags (Game * fromGame);
    errorT    LoadStandardTags (IndexEntry * ie, NameBase * nb);
    void      ClearStandardTags ();

    // PGN conversion
    void      GetSAN (char * str);
    void      GetPrevSAN (char * str);
    void      WriteComment (TextBuffer * tb, const char * preStr,
                            const char * comment, const char * postStr);
    errorT    WriteMoveList (TextBuffer * tb, uint plyCount,
                             moveT * oldCurrentMove,
                             bool printMoveNum, bool inComment);
    errorT    WritePGN (TextBuffer * tb, uint stopLocation);
    errorT    WriteToPGN (TextBuffer * tb);
    errorT    MoveToLocationInPGN (TextBuffer * tb, uint stopLocation);
    errorT    WriteExtraTags (FILE * fp);

    uint      GetPgnOffset (byte nextMoveFlag) {
        return (nextMoveFlag ? PgnNextMovePos : PgnLastMovePos);
    }

    void      ResetPgnStyle (void) { PgnStyle = 0; }
    void      ResetPgnStyle (uint flag) { PgnStyle = flag; }

    uint      GetPgnStyle () { return PgnStyle; }
    void      SetPgnStyle (uint mask, bool setting) {
        if (setting) { AddPgnStyle (mask); } else { RemovePgnStyle (mask); }
    }
    void      AddPgnStyle (uint mask) { PgnStyle |= mask; }
    void      RemovePgnStyle (uint mask) { PgnStyle &= ~mask; }

    void      SetPgnFormat (gameFormatT gf) { PgnFormat = gf; }
    bool      SetPgnFormatFromString (const char * str);
    static bool PgnFormatFromString (const char * str, gameFormatT * fmt);
    bool      IsPlainFormat () { return (PgnFormat == PGN_FORMAT_Plain); }
    bool      IsHtmlFormat  () { return (PgnFormat == PGN_FORMAT_HTML); }
    bool      IsLatexFormat () { return (PgnFormat == PGN_FORMAT_LaTeX); }
    bool      IsColorFormat () { return (PgnFormat == PGN_FORMAT_Color); }

    void      SetHtmlStyle (uint style) { HtmlStyle = style; }
    uint      GetHtmlStyle () { return HtmlStyle; }

    errorT    GetPartialMoveList (DString * str, uint plyCount);

    errorT    Encode (ByteBuffer * buf, IndexEntry * ie);
    void      EncodeTags (ByteBuffer * buf);

    bool      MaterialMatch (ByteBuffer * buf, byte * min, byte * max,
                             patternT * pattern, int minPly, int maxPly,
                             int matchLength,
                             bool oppBishops, bool sameBishops,
                             int minDiff, int maxDiff);
    bool      ExactMatch (Position * pos, ByteBuffer * buf, simpleMoveT * sm,
                          gameExactMatchT searchType, bool * neverMatch);
    bool      VarExactMatch (Position * searchPos, gameExactMatchT searchType);
    inline bool ExactMatch (Position * pos, ByteBuffer * buf, simpleMoveT * sm)
      { return ExactMatch (pos, buf, sm, GAME_EXACT_MATCH_Exact, NULL); }
    inline bool ExactMatch (Position * pos, ByteBuffer * buf, simpleMoveT * sm,
                            bool * neverMatch)
      { return ExactMatch (pos, buf, sm, GAME_EXACT_MATCH_Exact, neverMatch); }
    inline bool ExactMatch (Position * pos, ByteBuffer * buf, simpleMoveT * sm,
                            gameExactMatchT searchType)
      { return ExactMatch (pos, buf, sm, searchType, NULL); }

    errorT    DecodeStart (ByteBuffer * buf);
    errorT    DecodeNextMove (ByteBuffer * buf, simpleMoveT * sm);
    errorT    Decode (ByteBuffer * buf, byte flags);

    // StoredLine codes:
    static ushort GetStoredLineCount (void);
    static Game * GetStoredLine (ushort i);
    static const char * GetStoredLineText (ushort i);
};


inline void
Game::InitMove (moveT * m)
{
    ASSERT(m != NULL);
    m->prev = m->next = m->varParent = m->varChild = NULL;
    m->numVariations = 0;
    //m->varLevel = 0;
    m->comment = NULL;
    m->nagCount = 0;
    m->nags[0] = 0;
    m->marker = NO_MARKER;
    m->san[0] = 0;
}

inline errorT
Game::AddNag (byte nag)
{
    moveT * m = CurrentMove->prev;
    if (m->nagCount + 1 >= MAX_NAGS) { return ERROR_GameFull; }
    if (nag == 0) { /* Nags cannot be zero! */ return OK; }
    m->nags[m->nagCount] = nag;
    m->nagCount += 1;
    m->nags[m->nagCount] = 0;
    //if (nag > 0) NagsFlag = 1;
    return OK;
}

#endif  // #ifndef SCID_GAME_H

//////////////////////////////////////////////////////////////////////
//  EOF:    game.h
//////////////////////////////////////////////////////////////////////
