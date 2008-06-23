#ifndef SEARCH_H
#define SEARCH_H

#include <stdio.h>

#include "consts.h"
#include "position.h"

typedef U32 NODES;

struct MultiPVEntry
{
	Move pv[MAX_PLY + 2];
	int pv_length; 
	EVAL score;
	int seen;
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

#define MODE_ANALYZE (1)
#define MODE_THINKING_ON_MOVE (2)
#define MODE_EPDTEST (3)
extern int g_mode;

extern int g_multipv_size;

struct Limits
{
	// all values in milliseconds

	int stSoft;
	int stHard;
	int sd;
	int inc;
};
typedef struct Limits Limits;

void        epdtest(FILE* psrc, double time_in_seconds, int reps);
void        init_hash();
HashEntry*  probe_hash(const Position* pos);
void        record_hash(const Position* pos, Move best_mv, U16 depth, EVAL eval, U8 type, U8 flags, int ply);
void        resize_hash(int size_in_mb);
void        start_analyze(const Position* pos0);
int         start_epd(const Position* pos, const char* fen, int reps, int* ptotal, int* psolved, double* psec);
void        start_thinking_on_move(Position* pos0);
void        start_perft(const Position* pos0, int depth);

#endif

