//////////////////////////////////////////////////////////////////////
//
//  FILE:       game.h
//              Game class for Scid.
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    3.5
//
//  Notice:     Copyright (c) 2000-2003 Shane Hudson.  All rights reserved.
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

void transPieces(char *s);
char transPiecesChar(char c);

// Piece letters translation
extern int language; // default to english
//  0 = en, 1 = fr, 2 = es, 3 = de
extern const char * langPieces[];

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
    NAG_OnlyMove = 8, // new
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
    NAG_ZugZwang = 22, // new
    NAG_BlackZugZwang = 23, // new
    NAG_MoreRoom = 26, // new
    NAG_DevelopmentAdvantage = 35,  // new
    NAG_WithInitiative = 36, //new
    NAG_WithAttack = 40, // new
    NAG_WithBlackAttack = 41, // new
    NAG_Compensation = 44,      // from Whites perspective
    NAG_SlightCentre = 48,      // from Whites perspective
    NAG_Centre = 50,            // new
    NAG_SlightKingSide = 54,    // from Whites perspective
    NAG_ModerateKingSide = 56,  // from Whites perspective
    NAG_KingSide = 58,          // from Whites perspective
    NAG_SlightQueenSide = 60,   // from Whites perspective
    NAG_ModerateQueenSide = 62, // from Whites perspective
    NAG_QueenSide = 64,         // from Whites perspective
    NAG_SlightCounterPlay = 130, // new
    NAG_CounterPlay = 132, // new
    NAG_DecisiveCounterPlay = 134, // new
    NAG_BlackSlightCounterPlay = 131, // new
    NAG_BlackCounterPlay = 133, // new
    NAG_BlackDecisiveCounterPlay = 135, // new
    NAG_TimeLimit = 136, // new
    NAG_WithIdea = 140, // new
    NAG_BetterIs = 142, // new
    NAG_VariousMoves = 144, // new
    NAG_Comment = 145, // new
    NAG_Novelty = 146,
    NAG_WeakPoint = 147, // new
    NAG_Ending = 148, // new
    NAG_File = 149, // new
    NAG_Diagonal = 150, // new
    NAG_BishopPair = 151, // new
    NAG_OppositeBishops = 153, // new
    NAG_SameBishops = 154, // new
    NAG_Etc = 190, // new
    NAG_DoublePawns = 191, // new
    NAG_SeparatedPawns = 192, // new
    NAG_UnitedPawns = 193, // new
    NAG_Diagram = 201,  // Scid-specific NAGs start at 201.
    NAG_See = 210,  // new
    NAG_Mate = 211, // new 
    NAG_PassedPawn = 212, // new
    NAG_MorePawns = 213, //new
    NAG_With = 214, // new
    NAG_Without = 215;

// MAX_NAGS: Maximum id of NAG codes
const byte MAX_NAGS_ARRAY = 215;
    
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

#ifdef WINCE
  #define MOVE_CHUNKSIZE 60    // Save memory (especially for Tree). What is the impact on memory fragmentation ?
#else
  #define MOVE_CHUNKSIZE 100    // Allocate space for 100 moves at a time.
#endif

struct moveChunkT {
    moveT moves [MOVE_CHUNKSIZE];
    uint numFree;
    moveChunkT * next;
};

#ifdef WINCE
#define MOVE_CHUNKSIZE_LOWMEM 25
struct moveChunkLowMemT {
    moveT moves [MOVE_CHUNKSIZE_LOWMEM];
    uint numFree;
    moveChunkLowMemT * next;
};
#endif

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

static Position staticPosition;

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

    tagT        TagList [	MAX_TAGS];
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
#ifdef WINCE
    bool        LowMem; // set to true if the game should use a low memory chuncksize
    moveChunkLowMemT * MoveChunkLowMem;
#endif
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
#ifdef WINCE
  void* operator new(size_t sz) {
    void* m = my_Tcl_Alloc(sz);
    return m;
  }
  void operator delete(void* m) {
    my_Tcl_Free((char*)m);
  }
  void* operator new [] (size_t sz) {
    void* m = my_Tcl_AttemptAlloc(sz);
    return m;
  }

  void operator delete [] (void* m) {
    my_Tcl_Free((char*)m);
  }

#endif

#ifdef WINCE
    Game()      { LowMem = false; Init(); }
// Position costs 1028 bytes : use a global one as this will only be called by sc_tree
// when LowMem is set
    Game(bool b)      { LowMem = true; CurrentPos = &staticPosition; Init(); }
#else
    Game()      { Init(); }
#endif

    ~Game();

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
    errorT   DeleteVariationAndFree (uint varNumber);
    errorT   FirstVariation (uint varNumber);
    errorT   MainVariation (uint varNumber);
		uint 		 GetVarNumber();

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

    bool     AtStart ()
                 { return (CurrentMove->prev->marker == START_MARKER  &&
                           VarDepth == 0); }
    bool     AtEnd ()
                 { return (CurrentMove->marker == END_MARKER  &&
                           VarDepth == 0); }
    bool     AtVarStart ()
                 { return (CurrentMove->prev->marker == START_MARKER); }
    bool     AtVarEnd ()
                 { return (CurrentMove->marker == END_MARKER); }
    uint     GetVarLevel () { return VarDepth; }
    uint      GetNumVariations ()
                 { return (uint) CurrentMove->numVariations; }

    void     Truncate ();
    void     TruncateAndFree ();

    void     TruncateStart ();

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
    void      GetPrevMoveUCI (char * str);
    void      GetNextMoveUCI (char * str);

    bool      CommentEmpty ( const char * comment);
    void      WriteComment (TextBuffer * tb, const char * preStr,
                            const char * comment, const char * postStr);
    errorT    WriteMoveList (TextBuffer * tb, uint plyCount,
                             moveT * oldCurrentMove,
                             bool printMoveNum, bool inComment);
    errorT    WritePGN (TextBuffer * tb, uint stopLocation);
    errorT    WriteToPGN (TextBuffer * tb);
    errorT    MoveToLocationInPGN (TextBuffer * tb, uint stopLocation);
#ifdef WINCE
    errorT    WriteExtraTags (/*FILE **/Tcl_Channel fp);
#else
    errorT    WriteExtraTags (FILE * fp);
#endif
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
