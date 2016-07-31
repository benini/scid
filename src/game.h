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
#include "indexentry.h"
#include "position.h"
#include "namebase.h"
#include "matsig.h"
#include <vector>
#include <string>
class ByteBuffer;
class TextBuffer;

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
class moveT
{
    friend class Game;
    simpleMoveT  moveData;      // piece moving, target square etc
    char         san[10];           // SAN representation of move
    std::string  comment;
    moveT      * prev;
    moveT      * next;
    moveT      * varChild;
    moveT      * varParent;
    markerT      marker;  // can be NO_MARKER, START_MARKER or END_MARKER
    byte         numVariations;
    byte         nagCount;
    byte         nags[MAX_NAGS];

    bool isNull () const { return isNullMove(&moveData); }
};



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
#define PGN_STYLE_UNICODE       4096   // Use U+2654..U+2659 for figurine


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

    bool        NonStandardStart;      // 1 if non-standard start.
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

    std::string EventStr;
    std::string SiteStr;
    std::string WhiteStr;
    std::string BlackStr;
    std::string RoundStr;
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

    const NameBase* NBase;      // needed for referencing id numbers.

    tagT        TagList [	MAX_TAGS];
    uint        NumTags;

    uint        NumMovesPrinted; // Used in recursive WriteMoveList method.
    uint        StopLocation;    // Used in recursive WriteMoveList method.

    uint        PgnStyle;        // see PGN_STYLE macros above.
    gameFormatT PgnFormat;       // see PGN_FORMAT macros above.
    uint        HtmlStyle;       // HTML diagram style, see
                                 //   DumpHtmlBoard method in position.cpp.
    uint        PgnLastMovePos;

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //  Game:  Private Functions
    Game(const Game&);
    Game& operator=(const Game&);

    void       AllocateMoreMoves ();
    inline moveT *    NewMove();
    inline void       FreeMove (moveT * move);

    errorT     DecodeVariation (ByteBuffer * buf, byte flags, uint level);
    bool       calcAbsPlyNumber_ (moveT *m, moveT *s);

    static void encodeMove (ByteBuffer * buf, moveT * m);
    static errorT encodeVariation (ByteBuffer * buf, moveT * m, 
                                   uint * subVarCount, uint * nagCount, uint depth);
    static errorT encodeComments (ByteBuffer * buf, moveT * m, uint * commentCounter);
    static errorT decodeComments (ByteBuffer * buf, moveT * m);

public:
    Game()      { Init(); }
    ~Game();

    void        Clear();
    void        ClearMoves();

    void        Init();

    // Set and Get attributes -- one-line (inline) methods
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
    errorT   MainVariation ();
    uint     GetVarNumber();

    void     SetMoveComment (const char * comment);
    const char* GetMoveComment () { return CurrentMove->prev->comment.c_str(); }
    /**
     * Game::GetPreviousMoveComment()
     * Return the comment on the move previously played by CurrentPos->ToMove
     * If there are no previous moves, return an empty comment.
     */
    const char* GetPreviousMoveComment() {
        ASSERT(CurrentMove != NULL);
        moveT* m = CurrentMove->prev;
        if (m == NULL || m->prev == NULL) return "";
        moveT* mp = m->prev->varParent;
        if (mp != NULL && mp->prev != NULL) m = mp;
        return m->prev->comment.c_str();
    }

    inline errorT AddNag (byte nag);
    inline errorT RemoveNag (bool isMoveNag);
    byte *   GetNags () { return CurrentMove->prev->nags; }
    byte *   GetNextNags () { return CurrentMove->nags; }
    void     ClearNags () {
        CurrentMove->prev->nagCount = 0;
        CurrentMove->prev->nags[0] = 0;
    }

    void     MoveTo (const std::vector<int>& v);
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

    void     SetEventStr (const char * str) { EventStr = str; }
    void     SetSiteStr  (const char * str) { SiteStr  = str; }
    void     SetWhiteStr (const char * str) { WhiteStr = str; }
    void     SetBlackStr (const char * str) { BlackStr = str; }
    void     SetRoundStr (const char * str) { RoundStr = str; }
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
    const char* GetEventStr ()       { return EventStr.c_str(); }
    const char* GetSiteStr ()        { return SiteStr.c_str();  }
    const char* GetWhiteStr ()       { return WhiteStr.c_str(); }
    const char* GetBlackStr ()       { return BlackStr.c_str(); }
    const char* GetRoundStr ()       { return RoundStr.c_str(); }
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

    void     MakeHomePawnList (byte * pbPawnList);

    // Searching
    compareT CompareCurrentPos (Position * p);

    void      CopyStandardTags (Game * fromGame);
    errorT    LoadStandardTags (const IndexEntry* ie, const NameBase* nb);
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
    std::pair<const char*, unsigned> WriteToPGN (uint lineWidth = 0,
                                                 bool NewLineAtEnd = false,
                                                 bool newLineToSpaces = true);
    errorT    MoveToLocationInPGN (uint stopLocation);
    errorT    WriteExtraTags (FILE * fp);

    uint      GetPgnOffset () {
                  PgnLastMovePos = 0;
                  moveT* lastMove = CurrentMove->prev;
                  if (AtVarStart()) {
                      lastMove = lastMove->varParent;
                      if (lastMove != 0) lastMove = lastMove->prev;
                  }
                  if (!calcAbsPlyNumber_(FirstMove, lastMove)) return 1;
                  return PgnLastMovePos;
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
    bool      MoveMatch (int m_argc, char ** m_argv, uint plyCount, bool wToMove, bool bToMove, int checkTest);

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
    errorT    DecodeTags (ByteBuffer * buf, bool storeTags);

    std::vector<int> GetCurrentLocation();
    Game* clone();
};


inline void
Game::InitMove (moveT * m)
{
    ASSERT(m != NULL);
    m->prev = m->next = m->varParent = m->varChild = NULL;
    m->numVariations = 0;
    //m->varLevel = 0;
    m->comment.clear();
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
	// If it is a move nag replace an existing
	if( nag >= 1 && nag <= 6)
		for( int i=0; i<m->nagCount; i++)
			if( m->nags[i] >= 1 && m->nags[i] <= 6)
			{
				m->nags[i] = nag;
				return OK;
			}
	// If it is a position nag replace an existing
	if( nag >= 10 && nag <= 21)
		for( int i=0; i<m->nagCount; i++)
			if( m->nags[i] >= 10 && m->nags[i] <= 21)
			{
				m->nags[i] = nag;
				return OK;
			}
	if( nag >= 1 && nag <= 6)
	{
		// Put Move Nags at the beginning
		for( int i=m->nagCount; i>0; i--)  m->nags[i] =  m->nags[i-1];
		m->nags[0] = nag;
	}
	else
		m->nags[m->nagCount] = nag;
	m->nagCount += 1;
	m->nags[m->nagCount] = 0;
    return OK;
}

inline errorT
Game::RemoveNag (bool isMoveNag)
{
    moveT * m = CurrentMove->prev;
	if( isMoveNag)
	{
		for( int i=0; i<m->nagCount; i++)
			if( m->nags[i] >= 1 && m->nags[i] <= 6)
			{
				m->nagCount -= 1;
				for( int j=i; j<m->nagCount; j++)  m->nags[j] =  m->nags[j+1];
				m->nags[m->nagCount] = 0;
				return OK;
			}
	}
	else
	{
		for( int i=0; i<m->nagCount; i++)
			if( m->nags[i] >= 10 && m->nags[i] <= 21)
			{
				m->nagCount -= 1;
				for( int j=i; j<m->nagCount; j++)  m->nags[j] =  m->nags[j+1];
				m->nags[m->nagCount] = 0;
				return OK;
			}
	}
    return OK;
}

#endif  // #ifndef SCID_GAME_H

//////////////////////////////////////////////////////////////////////
//  EOF:    game.h
//////////////////////////////////////////////////////////////////////
