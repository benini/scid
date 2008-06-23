
// probe.h

// includes

// constants

// macros

// types

typedef int (*PPROBE_EGBB) (int player, int w_king, int b_king,
							int piece1, int square1,
							int piece2, int square2,
							int piece3, int square3);

typedef void (*PLOAD_EGBB) (char* path,int cache_size,int load_options);
static PPROBE_EGBB probe_egbb;


// "constants"

#define _NOTFOUND 99999
#define WIN_SCORE 3000
#define WIN_PLY   40 

// variables

extern bool egbb_is_loaded;

// functions

extern int LoadEgbbLibrary(char* main_path,uint32 egbb_cache_size);
extern int probe_bitbases(board_t * board, int& score);
// end of probe.h

