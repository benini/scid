#ifndef SEARCH_H
#define SEARCH_H

#include <stdio.h>

#include "consts.h"
#include "position.h"

typedef U32 NODES;

struct MultiPVEntry
{
	vector<Move> m_pv;
	EVAL m_score;
	bool m_seen;
};
typedef struct MultiPVEntry MultiPVEntry;

struct HashEntry
{
	U8   age;
	U16  depth;
	EVAL eval;
	U8   flags;
	U32  hashLock;
	Move mv;
	U8   type;
};
typedef struct HashEntry HashEntry;

#define DEFAULT_HASH_SIZE (0x7ffff)
#define DEFAULT_PAWN_HASH_SIZE (0x3fff)

enum MODE_T
{
	IDLE = 0, ANALYZE = 1, THINKING = 2, EPDTEST = 3
};
extern MODE_T g_mode;
extern int g_multipv_size;
extern vector<Move> g_rootPV;

struct Limits
{
	// all values in milliseconds

	int stSoft;
	int stHard;
	int sd;
	int inc;
};
typedef struct Limits Limits;

// void        epdtest(FILE* psrc, double time_in_seconds, int reps);
void        init_hash();
HashEntry*  probe_hash(const Position* pos);
void        record_hash(const Position* pos, Move best_mv, U16 depth, EVAL eval, U8 type, U8 flags, int ply);
void        resize_hash(int size_in_mb);
EVAL        SEE(const Position& pos, Move mv);
void        start_analyze(const Position& pos0);
// int         start_epd(const Position& pos, const char* fen, int reps, int* ptotal, int* psolved, double* psec);
void        start_thinking_on_move(Position& pos0);
void        start_perft(const Position& pos0, int depth);

#endif
