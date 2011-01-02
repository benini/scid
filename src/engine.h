//////////////////////////////////////////////////////////////////////
//
//  FILE:       engine.h
//              Engine class
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    3.5
//
//  Notice:     Copyright (c) 2002-2003 Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////

// The Engine class provides a simple chess position evaluator
// based on negamax with quiescent search and alpha/beta pruning.
// It is used in Scid for doing small quick searches to determine
// which of the possible legal moves to or from a particular square
// to suggest as the best move for faster mouse input.

#ifndef SCID_ENGINE_H
#define SCID_ENGINE_H

#include <stdarg.h>

#include "position.h"
#include "timer.h"

const uint ENGINE_MAX_PLY =           40;  // Maximum search ply.
const int  ENGINE_MAX_HISTORY =   100000;  // Max accumulated history value.
const int  ENGINE_HASH_SCORE = 100000000;  // To order hash moves first.
const uint ENGINE_HASH_KB =           32;  // Default hash table size in KB.
const uint ENGINE_PAWN_KB =            1;  // Default pawn table size in KB.

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// principalVarT
//   Stores the principal variation at one search Ply depth.
//
struct principalVarT {
    uint length;
    simpleMoveT move [ENGINE_MAX_PLY];
};

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// scoreFlagT
//  Types of transposition table score and endgame recognition score.
//
typedef byte scoreFlagT;
const scoreFlagT
    SCORE_NONE  = 0,    // Not a useful score.
    SCORE_EXACT = 1,    // Exact score.
    SCORE_LOWER = 2,    // Lower bound, real score could be higher.
    SCORE_UPPER = 3;    // Upper bound, real score could be lower.

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// transTableEntryT
//   Transposition table entry.
//   Apart from the type flag, depth and score, it also stores the
//   hash codes and other position values for safety checks to avoid
//   a false hit.
//   The best move is also stored, in a compact format to save space.
//
struct transTableEntryT {
    uint    hash;              // Hash value.
    uint    pawnhash;          // Pawn hash value, for extra safety check.
    short   score;             // Evaluation score.
    ushort  bestMove;          // Best move from/to/promote values.
    byte    depth;             // Depth of evaulation.
    byte    flags;             // Score type, side to move and castling flags.
    byte    sequence;          // Sequence number, for detecting old entries.
    squareT enpassant;         // En passant target square.
};

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// pawnTableEntryT
//   Pawn structure score hash table entry.
//
struct pawnTableEntryT {
    uint  pawnhash;           // Pawn hash value for this pawn structure.
    uint  sig;                // Safety check value, to avoid false hits.
    short score;              // Positional score for pawn structure.
    short wLongbShortScore;   // Pawn storm score for wk on abc, bk on abc.
    short wShortbLongScore;   // Pawn storm score for wk on fgh, bk on fgh.
    byte  fyleHasPassers[2];  // One bit per file, indicating passed pawns.
};

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// repeatT
//   Repetition-detection stack entry.
//   An entry is pushed onto the stack when a move is made, and
//   popped off when the move is unmade.
//
struct repeatT {
    uint   hash;         // Position hash code.
    uint   pawnhash;     // Position pawn-structure hash code.
    uint   npieces;      // Total number of pieces in position.
    colorT stm;          // Side to move.
};


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Engine
//   Class representing a chess engine.
//
class Engine {
private:
    Position RootPos;       // Position at start of search.
    Position Pos;           // Current position in search.
    uint     MaxDepth;      // Search depth limit.
    int      SearchTime;    // Search time limit in milliseconds.
    int      MinSearchTime; // Minimum search time in milliseconds.
    int      MaxSearchTime; // Maximum search time in milliseconds.
    uint     MinDepthCheckTime; // will not check time before this depth is reached
    bool     PostInfo;      // If true, print post info to stdout.
    bool     Pruning;       // If true, do futility pruning.
#ifndef WINCE
    FILE *   LogFile;       // Output is to stdout and to this file.
#endif
    uint     QNodeCount;    // Nodes examined in quiescent search.
    uint     NodeCount;     // Nodes examined in total.
    Timer    Elapsed;       // Timer for interrupting search.
    bool     IsOutOfTime;   // Becomes true when search is out of time.
    uint     Ply;           // Current ply being examined.
    bool     EasyMove;      // True if the search indicates one move is
                            //    far better than the others.
    bool     HardMove;      // True if failed low at root on current depth.
    uint     InNullMove;    // If > 0, in null move search so no PV updates.
    uint     RepStackSize;         // Repetition stack size.
    repeatT  RepStack [1024];      // Repetition stack.
    bool     InCheck [ENGINE_MAX_PLY];   // In-check at each ply.
    principalVarT PV [ENGINE_MAX_PLY];   // Principal variation at each ply.
    simpleMoveT KillerMove [ENGINE_MAX_PLY][2];  // Two killer moves per ply.
    int History[16][64];    // Success history of piece-to-square moves.
    byte     TranTableSequence;       // Transposition table sequence number.
    static const uint TranTableSize = 2048;  // Number of Transposition table entries.
    transTableEntryT TranTable[2048]; // Transposition table.
    static const uint PawnTableSize = 64;    // Number of Pawn structure table entries.
    pawnTableEntryT PawnTable[64];    // Pawn structure score hash table.
    void *   CallbackData;

    int PieceValue (pieceT piece);
    int SearchRoot (int depth, int alpha, int beta, MoveList * mlist);
    int Search (int depth, int alpha, int beta, bool tryNullMove);
    int Quiesce (int alpha, int beta);
    int SEE (squareT from, squareT to);
    void ScoreMoves (MoveList * mlist);
    inline void DoMove (simpleMoveT * sm);
    inline void UndoMove (simpleMoveT * sm);
    inline void SetPVLength (void);
    inline void UpdatePV (simpleMoveT * sm);
    void Output (const char * format, ...);
    void PrintPV (uint depth, int score) { PrintPV (depth, score, ""); }
    void PrintPV (uint depth, int score, const char * annotation);
    inline void PushRepeat (Position * pos);
    inline void PopRepeat (void);
    void StoreHash (int depth, scoreFlagT flag, int score,
                    simpleMoveT * bestmove, bool isOnlyMove);
    scoreFlagT ProbeHash (int depth, int * score, simpleMoveT * bestMove, bool * isOnlyMove);

    inline void ClearKillerMoves (void);
    inline void AddKillerMove (simpleMoveT * sm);
    inline bool IsKillerMove (simpleMoveT * sm);

    inline void ClearHistoryValues (void);
    inline void HalveHistoryValues (void);
    inline void IncHistoryValue (simpleMoveT * sm, int increment);
    inline int GetHistoryValue (simpleMoveT * sm);

    int Score (int alpha, int beta);
    inline int ScoreWhiteMaterial (void);
    inline int ScoreBlackMaterial (void);
    void ScorePawnStructure (pawnTableEntryT * pawnEntry);
    bool IsMatingScore (int score);
    bool IsGettingMatedScore (int score);
    uint RepeatedPosition (void);

    bool OutOfTime (void);
    bool NoMatingMaterial (void);
    bool FiftyMoveDraw (void);

public:

	Engine();
	void SetSearchDepth (uint ply);
    void SetSearchTime (uint ms);
    void SetSearchTime (uint min, uint ms, uint max);
#ifndef WINCE
    void SetLogFile (FILE * fp) { LogFile = fp; }
#endif
    void ClearHashTable (void);
    void ClearPawnTable (void);
    void SetPosition (Position * pos);
    int Score (void);
    int ScoreMaterial (void);
    int Think (MoveList * mlist);

	uint PerfTest (uint depth);
};

#endif  // SCID_ENGINE_H

//////////////////////////////////////////////////////////////////////
//  EOF: engine.h
//////////////////////////////////////////////////////////////////////
