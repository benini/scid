#ifndef __SCORPIO__
#define __SCORPIO__

#ifdef _MSC_VER
#    define _CRT_SECURE_NO_DEPRECATE
#    define _SCL_SECURE_NO_DEPRECATE
#endif

#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <ctype.h>
#include <time.h>
#include <math.h>
#include <sys/timeb.h>

#include "ipc.h"

/*
Support for different data models
*/
#define DATA_MODEL 1

#if DATA_MODEL > 1
#    define ARC_64BIT
#endif

#define BMP16 short
#define BMP8  char

#if DATA_MODEL == 0
#    define BMP32 long
#    define BMP64 long long
#elif DATA_MODEL == 1
#    define BMP32 int
#    define BMP64 long long
#elif DATA_MODEL == 2
#    define BMP32 __int32
#    define BMP64 long
#elif DATA_MODEL == 3
#    define BMP32 int
#    define BMP64 long long
#elif DATA_MODEL == 4
#    define BMP32 int
#    define BMP64 long
#else
#error Define Data model number (0 - 4)
#endif

#if _MSC_VER
#    undef  BMP64
#    define BMP64 __int64
#endif
/*
define unsigned types
*/
typedef unsigned  BMP64  UBMP64;
typedef unsigned  BMP32  UBMP32;
typedef unsigned  BMP16  UBMP16;
typedef unsigned  BMP8   UBMP8;

typedef UBMP64  HASHKEY;
typedef UBMP64  BITBOARD;
typedef UBMP32  MOVE;

/*
Os stuff
*/
#ifdef WIN32
#    include <unistd.h>
#    include <windows.h>
// #    define CDECL
#    define UINT64(x) (x##ULL)
#    define FMT64     "%016llx"
// #    define FORCEINLINE __inline
#else

#ifdef _MSC_VER
#    include <windows.h>
// #    include <io.h>
// #    include <conio.h>
#    undef CDECL
#    define CDECL __cdecl
#    define UINT64(x) (x##ui64)
#    define FMT64     "%016I64x"
#    define FORCEINLINE __forceinline
#else
#    include <unistd.h>
#    include <dlfcn.h>
#    define CDECL
#    define UINT64(x) (x##ULL)
#    define FMT64     "%016llx"
#    define FORCEINLINE __inline
#endif

#endif
/*
Define PARALLEL to enable multi threading
*/
// #define PARALLEL
#define USESPINLOCK

#ifdef PARALLEL
#    define VOLATILE volatile
/*threads*/
#    ifdef _MSC_VER
#        include <process.h>
#        define pthread_t HANDLE
#        define t_create(f,p,t) t = (pthread_t) _beginthread(f,0,(void*)p)
#        define t_sleep(x)    Sleep(x)
#    else
#        include <pthread.h>
#        define t_create(f,p,t) pthread_create(&t,0,(void*(*)(void*))&f,(void*)p)
#        define t_sleep(x)    usleep((x) * 1000)
#    endif
/*lock*/
#    ifdef _MSC_VER
#        ifdef USESPINLOCK
#             define LOCK VOLATILE int
#             define l_create(x)   ((x) = 0)
#             define l_lock(x)     while(InterlockedExchange((LPLONG)&(x),1) != 0)
#             define l_unlock(x)   ((x) = 0)
#        else
#             define LOCK CRITICAL_SECTION
#             define l_create(x)   InitializeCriticalSection(&x)
#             define l_lock(x)     EnterCriticalSection(&x)
#             define l_unlock(x)   LeaveCriticalSection(&x)
#        endif   
#    else
#        define LOCK pthread_mutex_t
#        define l_create(x)   pthread_mutex_init(&(x),0)
#        define l_lock(x)     pthread_mutex_lock(&(x))
#        define l_unlock(x)   pthread_mutex_unlock(&(x))
#    endif
#else
#    define VOLATILE
#    define l_lock(x)
#    define l_unlock(x)
#endif
/*
Scorpio board representation
*/
#define VERSION "2.0"

enum {white,black,neutral};
enum {king = 1,queen,rook,bishop,knight,pawn};
enum {empty,wking,wqueen,wrook,wbishop,wknight,wpawn,
bking,bqueen,brook,bbishop,bknight,bpawn,elephant};
enum {RANK1,RANK2,RANK3,RANK4,RANK5,RANK6,RANK7,RANK8};
enum {FILEA,FILEB,FILEC,FILED,FILEE,FILEF,FILEG,FILEH};
enum {UNKNOWN,AVOID_NULL,HASH_HIT,EXACT,UPPER,LOWER};
enum {R_UNKNOWN,R_WWIN,R_BWIN,R_DRAW};
enum {PV_NODE,CUT_NODE,ALL_NODE};
enum {NO_LAZY,TRY_LAZY,DO_LAZY};
enum {A1 = 0,B1,C1,D1,E1,F1,G1,H1,
A2 = 16,B2,C2,D2,E2,F2,G2,H2,
A3 = 32,B3,C3,D3,E3,F3,G3,H3,
A4 = 48,B4,C4,D4,E4,F4,G4,H4,
A5 = 64,B5,C5,D5,E5,F5,G5,H5,
A6 = 80,B6,C6,D6,E6,F6,G6,H6,
A7 = 96,B7,C7,D7,E7,F7,G7,H7,
A8 = 112,B8,C8,D8,E8,F8,G8,H8};

#define RR    0x01
#define LL   -0x01
#define RU    0x11
#define LD   -0x11
#define UU    0x10
#define DD   -0x10
#define LU    0x0f
#define RD   -0x0f

#define RRU   0x12
#define LLD  -0x12
#define LLU   0x0e
#define RRD  -0x0e
#define RUU   0x21
#define LDD  -0x21
#define LUU   0x1f
#define RDD  -0x1f

#define UUU   0x20
#define DDD  -0x20
#define RRR   0x02
#define LLL  -0x02

#define KM       1
#define QM       2
#define RM       4
#define BM       8
#define NM      16
#define WPM     32
#define BPM     64
#define QRBM    14
#define KNM     17

#define AGE_MASK 0x1f

#define MAX_CPUS             8
#define MAX_SEARCHERS      (MAX_CPUS * 16)
#define MAX_STR            256
#define MAX_FILE_STR      2048
#define MAX_MOVES          256
#define MAX_PLY             70
#define MAX_HIST          1000
#define MATE_SCORE       20000
#define MAX_SCORE        30000
#define WIN_SCORE         3000
#define WIN_PLY             40
#define MAX_NUMB      21474836
  

#define GEN_START           0
#define GEN_HASHM           1
#define GEN_CAPS            2
#define GEN_QNONCAPS        3
#define GEN_KILLERS         3
#define GEN_NONCAPS         4
#define GEN_LOSCAPS         5
#define GEN_END             6

#define WSC_FLAG       1
#define WLC_FLAG       2
#define BSC_FLAG       4
#define BLC_FLAG       8
#define WSLC_FLAG      3
#define BSLC_FLAG     12
#define WBC_FLAG      15
/*
Scorpio moves are 32bit long
*/
#define FROM_FLAG        0x000000ff
#define TO_FLAG          0x0000ff00
#define PIECE_FLAG       0x000f0000
#define CAPTURE_FLAG     0x00f00000
#define PROMOTION_FLAG   0x0f000000
#define CAP_PROM         0x0ff00000
#define FROM_TO_PROM     0x0f00ffff
#define EP_FLAG          0x10000000
#define CASTLE_FLAG      0x20000000
#define m_from(x)        (int)((x) & FROM_FLAG)
#define m_to(x)          (int)(((x) & TO_FLAG) >> 8)
#define m_piece(x)       (int)(((x) & PIECE_FLAG) >> 16)
#define m_capture(x)     (int)(((x) & CAPTURE_FLAG) >> 20)
#define m_promote(x)     (int)(((x) & PROMOTION_FLAG) >> 24)
#define is_cap_prom(x)   (int)((x) & CAP_PROM)
#define is_ep(x)         (int)((x) & EP_FLAG)
#define is_castle(x)     (int)((x) & CASTLE_FLAG)
/*square*/
#define file(x)          ((x) &  7)
#define rank(x)          ((x) >> 4)
#define rank64(x)        ((x) >> 3)
#define SQ(x,y)          (((x) << 4) | (y))
#define SQ64(x,y)        (((x) << 3) | (y))
#define MIRRORF(sq)      ((sq) ^ 0x07)
#define MIRRORR(sq)      ((sq) ^ 0x70)
#define MIRRORD(sq)      SQ(file(sq),rank(sq))
#define SQ8864(x)        SQ64(rank(x),file(x))
#define SQ6488(x)        SQ(rank64(x),file(x))
#define MV8866(x)        (SQ8864(m_from(x)) | (SQ8864(m_to(x)) << 6))
/*piece and color*/
#define COLOR(x)         (col_tab[x])
#define PIECE(x)         (pic_tab[x])
#define DECOMB(c,x)      ((x) - (6 * (c)))
#define COMBINE(c,x)     ((x) + (6 * (c)))
#define invert(x)        (!(x))
/*others*/
#undef max
#undef min
#define max(a, b)        (((a) > (b)) ? (a) : (b))
#define min(a, b)        (((a) < (b)) ? (a) : (b))
#define PC_HKEY(p,sq)    (piece_hkey[p][SQ8864(sq)])
#define EP_HKEY(ep)      (ep_hkey[file(ep)])
#define CAST_HKEY(c)     (cast_hkey[c])
#define f_distance(x,y)  abs(file(x)-file(y))
#define r_distance(x,y)  abs(rank(x)-rank(y))
#define distance(x,y)    max(f_distance(x,y),r_distance(x,y))
#define is_light(x)      ((file(x)+rank(x)) & 1)
/*
type definitions
*/
typedef struct CHESS_CLOCK {
	int mps;
	int inc;
	int p_time;
	int o_time;
	int max_st;
	int max_sd;
	int search_time;
	int maximum_time;
	int infinite_mode;
	CHESS_CLOCK();
	void set_stime(int);
}*PCHESS_CLOCK;

typedef struct SQATTACK {
	int   step;
	int   pieces;
}*PSQATTACK;

typedef struct LIST{
	int   sq;
	LIST* prev;
	LIST* next;
}*PLIST;
/*
hash tables
*/
typedef struct tagHASHREC {
	HASHKEY hash_key;
	BMP32   move;
	BMP16   score;
	UBMP8   depth;
	UBMP8   flags;
}HASHREC,*PHASHREC;

typedef struct tagHASH {
	HASHREC record[2];
}HASH,*PHASH;

typedef struct tagPAWNREC {
	UBMP8   w_passed;
	UBMP8   b_passed;
}PAWNREC,*PPAWNREC;

typedef struct tagPAWNHASH {
	HASHKEY checksum;
	BMP16   score;
	PAWNREC pawnrec;
}PAWNHASH,*PPAWNHASH;

typedef struct tagEVALREC {
	UBMP8   indicator;
	/*
	indicator:
	bit 1 = avoid lazy eval
	bit 2 = bad white king safety
	bit 3 = bad black king safety
	*/
	UBMP8   hung;
	/*
	low - white number of hung pieces
	high - black number of hung pieces
	*/
}EVALREC,*PEVALREC;

#define AVOID_LAZY         1
#define BAD_WKING          2
#define BAD_BKING          4

typedef struct tagEVALHASH {
	HASHKEY checksum;
	BMP16   score;
	BMP16   lazy_score;
	EVALREC evalrec;
}EVALHASH,*PEVALHASH;

/*personality parameters*/
typedef struct PERSONALITY {
    int check_ext;
	int re_capture_ext;
	int pawn_push7_ext;
	int one_reply_ext;
	int mate_threat_ext;
	int horizon_ext;
	int futl_margin1;
    int futl_margin;
	int lazy_margin;
	int exchange_scale;
	int bishop_pair_scale;
	int king_safety_scale;
	int mobility_scale;
	int pawn_structure_scale;
	int passed_pawn_scale;
	int rook_on_7th_scale;
} *PPERSONALITY;

/*stacks*/
typedef struct HIST_STACK{
	MOVE move;
	int castle;
	int epsquare;
	int fifty;
	int checks;
	int rev_check;
	HASHKEY hash_key;
	HASHKEY pawn_hash_key;
}*PHIST_STACK;

typedef struct STACK{
	MOVE move_st[MAX_MOVES];
	int score_st[MAX_MOVES];
	MOVE pv[MAX_PLY];
	int pv_length;
	MOVE current_move;
	int count;
	int current_index;
	int gen_status;
	int sortm;
	int losing_start;
	int losing_end;
	int best_score;
	MOVE best_move;
	MOVE hash_move;
	int extension;
	int reduction;
	int hash_flags;
	int mate_threat;
	int legal_moves;
	int alpha;
	int beta;
	int node_type;
	int next_node_type;
	int o_alpha;
	int o_beta;
	int o_depth;
	int depth;
	int flag;
	int search_state;
	MOVE killer[2];
	int qcheck_depth;
	int use_lazy;
	int actual_score;
	int lazy_score;
	EVALREC evalrec;
	void sort(const int,const int);
}*PSTACK;

typedef struct SEARCHER{
	/*data that needs to be copied
	by COPY fn below*/
	int player;
	int opponent;
	int castle;
	int epsquare;
	int fifty;
	int temp_board[224];
	int* const board;
	PLIST list[128];
	PLIST plist[15];
	int hply;
	int ply;
	int pcsq_score[2];
	int pawn_c[2];
	int piece_c[2];
	int man_c[15];
	int all_man_c;
	HASHKEY hash_key;
	HASHKEY pawn_hash_key;
	PSTACK pstack;
	HIST_STACK hstack[MAX_HIST];
	STACK stack[MAX_PLY];
	/*eval data*/
	UBMP8 tWB[224],tBB[224];
	UBMP8  wp_onf[10];
    UBMP8  bp_onf[10];
	UBMP8* const WB;
    UBMP8* const BB;
	UBMP8* const wf_pawns;
    UBMP8* const bf_pawns;
	UBMP8  w_pawn_f;
	UBMP8  b_pawn_f;
	UBMP8  w_pawn_r;
	UBMP8  b_pawn_r;
	UBMP8  all_pawn_f;
	PAWNREC pawnrec;
	PPERSONALITY personality;
	/*functions*/
	SEARCHER();
	void  COPY(SEARCHER*);
	void  set_board(const char* fen_str);
	void  new_board();
	void  mirror();
	void  init_data();
	void  pcAdd(int,int);
	void  pcRemove(int,int);
	void  pcSwap(int,int);
	void  do_move(const MOVE&);
	void  do_null();
	void  undo_move();
	void  undo_null();
	void  PUSH_MOVE(MOVE);
    void  PUSH_NULL();
	void  POP_MOVE();
    void  POP_NULL();
	void  UPDATE_PV(MOVE);
	int   blocked(int,int);
	int   attacks(int,int);
	int   checks(MOVE,int&);
	int   in_check(MOVE);
	int   is_legal(MOVE&);
	int   is_legal_fast(MOVE);
	int   is_passed(MOVE);
	int   pinned_on_king(int,int);
	void  print_board();
	void  print_history();
	void  print_allmoves();
	int   see(MOVE);
	void  gen_caps();
	void  gen_noncaps();
	void  gen_checks();
	void  gen_evasions();
	void  gen_all();
	MOVE  get_move();
	MOVE  get_qmove();
	int   draw();
	MOVE  find_best();
	int   be_selective();
	int   on_node_entry();
	int   on_qnode_entry();
	void  search();
	void  search_parallel();
	void  qsearch();
	void  root_search();
	bool  hash_cutoff();
	int   perft(int);
	MOVE  get_book_move();
	void  show_book_moves();
	void  print_pv(int);
	int   print_result();
	void  check_quit();
	int   eval(int = NO_LAZY);
	int   eval_pawns();
	int   eval_passed_pawns();
	int   eval_win_chance(int&,int&,int&,int&);
	void  eval_tempo();
	void  pre_calculate();
	/*counts*/
	VOLATILE int stop_searcher;
	UBMP32 nodes;
	UBMP32 qnodes;
	UBMP32 time_check;
	UBMP32 full_evals;
    UBMP32 lazy_evals;
	UBMP32 splits;
	UBMP32 bad_splits;
	UBMP32 egbb_probes;
	/*
	Parallel search
	*/
	int  processor_id;
#ifdef PARALLEL
	SEARCHER* master;
	SEARCHER* VOLATILE workers[MAX_CPUS];
	VOLATILE int n_workers;
	LOCK lock;
	bool used;
	
	void attach_processor(int);
	void stop_workers();
#endif

	/*things that are shared among
	multiple searchers.*/
	static UBMP32 history[2][4096];
	static CHESS_CLOCK chess_clock;
	static int search_depth;
	static int start_time;
	static int scorpio;
	static int pv_print_style;
	static int root_score;
	static int prev_root_score;
	static int root_failed_low;
	static int last_book_move;
	static int first_search;
	static PERSONALITY phase_personality[3];
	static int abort_search;
	static UBMP32 poll_nodes;
	
	/*
	Bitbases
	*/
	int probe_bitbases(int&);
	bool bitbase_cutoff();
	static int egbb_is_loaded;
	static int egbb_load_type;
	static int probe_depth;
	/*
	End
	*/
} *PSEARCHER;

/*
inline piece list functions
*/
FORCEINLINE void SEARCHER::pcAdd(int pic,int sq) {
	PLIST* pHead;
	PLIST pPc;
	pHead = &plist[pic];
	pPc = list[sq];
	if(!(*pHead)) {
		(*pHead) = pPc;
		(*pHead)->next = 0;
		(*pHead)->prev = 0;
	} else {
		pPc->next = (*pHead)->next;
		if((*pHead)->next) (*pHead)->next->prev = pPc;
		(*pHead)->next = pPc;
		pPc->prev = (*pHead);
    }
};
FORCEINLINE void SEARCHER::pcRemove(int pic,int sq) {
	PLIST* pHead;
	PLIST pPc;
	pHead = &plist[pic];
	pPc = list[sq];
	if(pPc->next) pPc->next->prev = pPc->prev;
	if(pPc->prev) pPc->prev->next = pPc->next;
    if((*pHead) == pPc) (*pHead) = (*pHead)->next;
};
FORCEINLINE void SEARCHER::pcSwap(int from,int to) {
	PLIST pPc;
	PLIST& pTo = list[to];
    PLIST& pFrom = list[from];
    pPc = pTo;
    pTo = pFrom;
    pFrom = pPc;
    pTo->sq = to;
    pFrom->sq = from;
}
FORCEINLINE void SEARCHER::PUSH_MOVE(MOVE move) {
	do_move(move);
    ply++;
	pstack++;
}
FORCEINLINE void SEARCHER::PUSH_NULL() {
	do_null();
    ply++;
	pstack++;
}
FORCEINLINE void SEARCHER::POP_MOVE() {
	ply--;
	pstack--;
    undo_move();
}
FORCEINLINE void SEARCHER::POP_NULL() {
	ply--;
	pstack--;
    undo_null();
}
/*
parallel search
*/
#ifdef PARALLEL

enum {CREATE,PARK,WAIT,GO,DEAD};

typedef struct PROCESSOR {
   PSEARCHER searcher;
   VOLATILE int state;
   PROCESSOR() {
	   state = DEAD;
	   searcher = 0;
   }
   void create();
   void process(PSEARCHER master = NULL);
} *PPROCESSOR;


extern LOCK  lock_smp;
extern LOCK  lock_io;
extern PROCESSOR processors[MAX_CPUS];
extern SEARCHER searchers[MAX_SEARCHERS];
extern int n_processors;

void init_smp(int);

#endif

/*global data*/
extern HASHKEY piece_hkey[14][64];
extern HASHKEY ep_hkey[8];
extern HASHKEY cast_hkey[16];
extern const int piece_cv[14];
extern const int col_tab[14];
extern const int pic_tab[14];
extern const int pawn_dir[2];
extern SQATTACK  temp_sqatt[0x101];
extern PSQATTACK const sqatt;
extern const int piece_mask[14];
extern int dummy;
extern int pcsq[14][0x80];
extern int age;
extern bool book_loaded;
extern bool log_on;

/*utility functions*/
int   get_time();
int   get_cpu_time();
void  init_game();
void  init_sqatt();
void  init_io();
// void  print(char* format,...);
void  print_log(char* format,...);
void  print_std(char* format,...);
void  print_move(const MOVE&);
void  print_sq(const int&);
void  print_pc(const int&);
void  sq_str(const int& ,char*);
void  mov_str(MOVE& ,char*);
void  mov_str_xboard(MOVE& ,char*);
void  str_mov(MOVE& ,char*);
int   tokenize(char* , char** , const char* str2 = " \n\r\t");
bool  read_line(char*);
void  init_hash_tables();
void  record_hash(int,HASHKEY,int,int,int,int,MOVE,int);
int   probe_hash(int,HASHKEY,int,int,int&,MOVE&,int,int,int&,int&);
void  record_pawn_hash(HASHKEY,int,const PAWNREC&);
int   probe_pawn_hash(HASHKEY,int&,PAWNREC&);
void  record_eval_hash(HASHKEY,int,int,const EVALREC&);
int   probe_eval_hash(HASHKEY,int&,int&,EVALREC&);
void  reset_hash_tab(UBMP32);
void  reset_pawn_hash_tab(UBMP32);
void  reset_eval_hash_tab(UBMP32);
void  clear_hash_tables();
void  init_hash_tables();
void  clear_hash_stat();
void  print_hash_stat();
void  load_book();
/*
Bitbases
*/
extern int LoadEgbbLibrary(char* path,int);
/*
End
*/
#endif
