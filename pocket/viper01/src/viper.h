#if !defined(VIPER_H_INCLUDED)
#define VIPER_H_INCLUDED

////
//// Includes
////

#ifndef _MSC_VER
#  include <unistd.h>
#  include <sys/time.h>
#  include <signal.h>
#else
#  include <windows.h>
#  define inline __inline
int             strncasecmp(const char *, const char *, size_t);
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include <assert.h>
#include <ctype.h>
#include <stdarg.h>
#include <sys/types.h>
#include <sys/stat.h>

#include "ipc.h"

////
//// More Windows compatibility magic.  Thanks to Dann Corbit!  :-)
////

#undef CDECL
#ifdef _MSC_VER
#define llu_format  "%I64u"
extern int      gettimeofday(struct timeval * , struct timezone * );
#define CDECL __cdecl
#else
#define llu_format  "%llu"
#define CDECL
#endif

////
//// Constants and macros                           
////

#define ENGINE_NAME "Viper"
#define ENGINE_VERSION "0.1"

#define STARTPOS "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w AHah - 0 0"

#define MAX_DEPTH 64
#define MAX_GAME_LENGTH 1024
#define MOVE_STACK_SIZE 2048

#define PLY 60

enum {WHITE, BLACK};

enum {PAWN=1, KNIGHT=2, BISHOP=3, ROOK=4, QUEEN=5, KING=6};
enum {WP=1, WN=2, WB=3, WR=4, WQ=5, WK=6, 
      BP=9, BN=10, BB=11, BR=12, BQ=13, BK=14,
      EMPTY=16, OUTSIDE=32};

#define P_VALUE 0x100
#define N_VALUE 0x340
#define B_VALUE 0x340
#define R_VALUE 0x50C
#define Q_VALUE 0x9F0
#define K_VALUE 0x1000

#define MATE_VALUE 30000
#define DRAW_VALUE 0
#define KNOWN_WIN (2*Q_VALUE)

#define MIDGAME_MATERIAL (2*Q_VALUE + 2*R_VALUE + 4*B_VALUE)
#define ENDGAME_MATERIAL (4*R_VALUE + 2*B_VALUE)

enum {FILE_A, FILE_B, FILE_C, FILE_D, FILE_E, FILE_F, FILE_G, FILE_H};
enum {RANK_1, RANK_2, RANK_3, RANK_4, RANK_5, RANK_6, RANK_7, RANK_8};

#define ColourOfPiece(piece) ((piece) >> 3)
#define PieceHasColour(piece, colour) (((piece) & 24) == ((colour) << 3))
#define PieceIsWhite(piece) (PieceHasColour(piece, WHITE))
#define PieceIsBlack(piece) (PieceHasColour(piece, BLACK))

#define TypeOfPiece(piece) ((piece) & 7)
#define PieceHasType(piece, type) (TypeOfPiece(piece) == type)
#define PieceIsPawn(piece) (PieceHasType(piece, PAWN))
#define PieceIsKnight(piece) (PieceHasType(piece, KNIGHT))
#define PieceIsBishop(piece) (PieceHasType(piece, BISHOP))
#define PieceIsRook(piece) (PieceHasType(piece, ROOK))
#define PieceIsQueen(piece) (PieceHasType(piece, QUEEN))
#define PieceIsKing(piece) (PieceHasType(piece, KING))

#define PieceOfColourAndType(colour, type) (((colour) << 3) | (type))
#define PieceHasColourAndType(piece, colour, type) \
  ((piece) == PieceOfColourAndType(colour, type))

#define PawnOfColour(colour) (PieceOfColourAndType(colour, PAWN))
#define KnightOfColour(colour) (PieceOfColourAndType(colour, KNIGHT))
#define BishopOfColour(colour) (PieceOfColourAndType(colour, BISHOP))
#define RookOfColour(colour) (PieceOfColourAndType(colour, ROOK))
#define QueenOfColour(colour) (PieceOfColourAndType(colour, QUEEN))
#define KingOfColour(colour) (PieceOfColourAndType(colour, KING))

#define PiecesHaveSameColour(piece1, piece2) (((piece1)&24) == ((piece2)&24))
#define PiecesHaveOppositeColour(piece1, piece2) \
  (((piece1)&24) == ((piece2)&16))

#define PieceIsSlider(piece) (SlidingArray[piece])

#define PawnCount(pos, side) ((pos)->piece_count[side][PAWN])
#define KnightCount(pos, side) ((pos)->piece_count[side][KNIGHT])
#define BishopCount(pos, side) ((pos)->piece_count[side][BISHOP])
#define RookCount(pos, side) ((pos)->piece_count[side][ROOK])
#define QueenCount(pos, side) ((pos)->piece_count[side][QUEEN])

#define HasPieceOfType(pos, side, type) ((pos)->piece_count[side][type] > 0)
#define HasPawns(pos, side) HasPieceOfType(pos, side, PAWN)
#define HasKnights(pos, side) HasPieceOfType(pos, side, KNIGHT)
#define HasBishops(pos, side) HasPieceOfType(pos, side, BISHOP)
#define HasRooks(pos, side) HasPieceOfType(pos, side, ROOK)
#define HasQueens(pos, side) HasPieceOfType(pos, side, QUEEN)
#define HasSliders(pos, side) \
  (HasBishops(pos,side)||HasRooks(pos,side)||HasQueens(pos,side))
#define HasHorizontalSliders(pos,side) \
  (HasRooks(pos,side)||HasQueens(pos,side))
#define HasDiagonalSliders(pos,side) \
  (HasBishops(pos,side)||HasQueens(pos,side))

#define KingSquare(pos,side) ((pos)->piece_list[KingOfColour(side)+128].n)
#define PieceList(pos,sq) ((pos)->piece_list[sq])
#define PieceListStart(pos,piece) ((pos)->piece_list[(piece)+128].n)
#define NextPiece(pos,square) ((pos)->piece_list[square].n)
#define PrevPiece(pos,square) ((pos)->piece_list[square].p)

#define RemovePiece(pos,square) do {                                \
    NextPiece(pos,PrevPiece(pos,square)) = NextPiece(pos,square); \
    PrevPiece(pos,NextPiece(pos,square)) = PrevPiece(pos,square); \
  } while(0)

#define InsertPiece(pos,piece,square) do {             \
    NextPiece(pos,square) = PieceListStart(pos,piece); \
    PrevPiece(pos,NextPiece(pos,square)) = square; \
    PrevPiece(pos,square) = piece+128;                 \
    PieceListStart(pos,piece) = square;                    \
  } while(0)

#define MovePiece(pos,from,to) do {                 \
    PieceList(pos,to) = PieceList(pos,from);            \
    PrevPiece(pos,NextPiece(pos,to)) = to;      \
    NextPiece(pos,PrevPiece(pos,to)) = to;      \
  } while(0)

#define PieceListEnd (BK + 128 + 1)

#define PawnListStart(pos,side) PieceListStart(pos,PawnOfColour(side))
#define KnightListStart(pos,side) PieceListStart(pos,KnightOfColour(side))
#define BishopListStart(pos,side) PieceListStart(pos,BishopOfColour(side))
#define RookListStart(pos,side) PieceListStart(pos,RookOfColour(side))
#define QueenListStart(pos,side) PieceListStart(pos,QueenOfColour(side))

const int Queenside = 0, Kingside = 1;
const int WhiteOOMask = 1, WhiteOOOMask = 2, BlackOOMask = 4, BlackOOOMask = 8;

#define CanCastleQueenside(pos,side) (((pos)->castle_flags&(1<<(1+((side)*2))))==0)
#define CanCastleKingside(pos,side) (((pos)->castle_flags&(1<<((side)*2)))==0)
#define CanCastle(pos, side) \
  (CanCastleQueenside(pos,side)||CanCastleKingside(pos, side))

#define ProhibitOO(pos, side) ((pos)->castle_flags |= (1 << ((side)*2)))
#define ProhibitOOO(pos, side) ((pos)->castle_flags |= (1 << ((side)*2 + 1)))

#define NULLMOVE 0
#define NOMOVE 1
#define FROM(x) (((x)>>7)&127)
#define TO(x) ((x)&127)
#define PROMOTION(x) (((x)>>14)&7)
#define PIECE(x) (((x)>>17)&7)
#define CAPTURE(x) (((x)>>20)&7)
#define EP_FLAG (1<<23)
#define EP(x) ((x)&EP_FLAG)
#define CASTLE_FLAG (1<<24)

#define SLIDER(x) (SlidingArray[x])

#define WP_MASK 1
#define BP_MASK 2
#define N_MASK 4
#define K_MASK 8
#define B_MASK 16
#define R_MASK 32
#define Q_MASK 64

#define EXPAND(x) ((x)+((x)&~7))
#define COMPRESS(x) (((x)+((x)&7))>>1)

#define ZOBRIST(x,y) Zobrist[(x)-1][COMPRESS(y)]
#define ZOB_EP(y) ZobEP[COMPRESS(y)]
#define ZOB_CASTLE(y) ZobCastle[y]

#define PSQ(x,y) PSqTables[x][y]
#define KING_ENDGAME_PSQ(x) KingEndgamePsq[x]

#define HINDEX(x) ((COMPRESS(FROM(x))<<6)|(COMPRESS(TO(x))))
#define HISTORY(x,y) (History[x][HINDEX(y)])

#define max(x,y) (((x)>(y))?(x):(y))
#define min(x,y) (((x)<(y))?(x):(y))

#define file(x) ((x)&15)
#define rank(x) ((x)>>4)

#define DISTANCE(x, y) (Distance[(x)-(y)])

enum {LOWER_BOUND=1, UPPER_BOUND=2, EXACT=3};

enum {IDLE, THINKING, PONDERING, PONDERHIT, ABORTED};

enum {
  A1=0x00, B1=0x01, C1=0x02, D1=0x03, E1=0x04, F1=0x05, G1=0x06, H1=0x07,
  A2=0x10, B2=0x11, C2=0x12, D2=0x13, E2=0x14, F2=0x15, G2=0x16, H2=0x17,
  A3=0x20, B3=0x21, C3=0x22, D3=0x23, E3=0x24, F3=0x25, G3=0x26, H3=0x27,
  A4=0x30, B4=0x31, C4=0x32, D4=0x33, E4=0x34, F4=0x35, G4=0x36, H4=0x37,
  A5=0x40, B5=0x41, C5=0x42, D5=0x43, E5=0x44, F5=0x45, G5=0x46, H5=0x47,
  A6=0x50, B6=0x51, C6=0x52, D6=0x53, E6=0x54, F6=0x55, G6=0x56, H6=0x57,
  A7=0x60, B7=0x61, C7=0x62, D7=0x63, E7=0x64, F7=0x65, G7=0x66, H7=0x67,
  A8=0x70, B8=0x71, C8=0x72, D8=0x73, E8=0x74, F8=0x75, G8=0x76, H8=0x77
};

// Endgames with special evaluation functions:
enum {KXK=1, KRKB=2, KRKN=3, KRKP=4, KQKR=5};

#define W_OO_MASK 1
#define W_OOO_MASK 2
#define B_OO_MASK 4
#define B_OOO_MASK 8

#define CASTLING(m) ((m)&CASTLE_FLAG)
#define SHORT_CASTLING(m) (CASTLING(m) && file(TO(m))==FILE_G)
#define LONG_CASTLING(m) (CASTLING(m) && file(TO(m))==FILE_C)


////
//// Types
////

typedef signed char int8;
typedef unsigned char uint8;
typedef signed short int16;
typedef unsigned short uint16;
typedef signed long int32;
typedef unsigned long uint32;
typedef signed long long int64;
typedef unsigned long long uint64;

typedef int move_t;

typedef uint64 hashkey_t;

struct list_t {
  uint8 p, n;
};

struct position_t {
  uint8 board_[256];
  uint8 *board;
  list_t piece_list[256];
  move_t last_move;
  int ep_square;
  int castle_flags;
  int rule50;
  int gply;
  int side, xside;
  int piece_count[2][8];
  int material[2];
  int psq[2];
  int check, check_sqs[2];
  hashkey_t key, pkey, previous_keys[MAX_GAME_LENGTH];
};

struct move_stack_t {
  move_t move;
  int score;
};

struct undo_info_t {
  hashkey_t key, pkey;
  int ep_square, rule50, castle_flags, check, check_sqs[2];
  move_t last_move;
};

struct search_stack_t {
  move_stack_t *ms_ptr;
  move_t pv[MAX_DEPTH];
  move_t move;
  move_t killer, killer2;
  int check;
  int num_of_evasions;
};

struct attack_data_t {
  uint8 may_attack;
  int8 step;
};

struct p_hashentry_t {
  hashkey_t key;
  int16 score[2], e_score[2];
  uint8 passed_pawn_squares[2][8];
  uint8 open_files[2];
};

struct engine_options_t {
  int aggressiveness, cowardice, pp_weight, e_pp_weight;
  int ps_weight, mob_weight, e_mob_weight, development_weight;
  int ponder;
  int multipv;
};

#define MAX_ROOT_MOVES 512

struct root_move_t {
  move_t move;
  int depth_1_score, score, score_type, depth;
  move_t pv[MAX_DEPTH];
  uint64 nodes, cumulative_nodes;
};

struct root_move_list_t {
  root_move_t moves[MAX_ROOT_MOVES];
  int num, current;
};

struct root_search_info_t {
  root_move_list_t root_moves;
  unsigned node_limit;
  int depth_limit;
  int exact_time;
  int max_time, absolute_max_time;
  int infinite;
  int thinking_status;
  int start_time;
  move_t pv[MAX_DEPTH];
  move_t bestmove, pondermove, easymove;
  int iteration;
  int bestvalues[MAX_DEPTH];
  int problem;
  int fail_high;
  int mate_found;
  uint64 nodes;
  int nodes_between_polls;
  int nodes_since_poll;
  move_t search_moves[MAX_ROOT_MOVES];
};

////
//// Global variables
////

const int Directions[16][16] = {
  {0},
  {15, 17, 0},  // WP
  {33, 31, 18, 14, -14, -18, -31, -33, 0},  // WN 
  {17, 15, -15, -17, 0},  // WB 
  {16, 1, -1, -16, 0},  // WR 
  {17, 16, 15, 1, -1, -15, -16, -17, 0},  // WQ 
  {17, 16, 15, 1, -1, -15, -16, -17, 0},  // WK 
  {0},
  {0},
  {-15, -17, 0},  // BP 
  {-33, -31, -18, -14, 14, 18, 31, 33, 0},  // BN 
  {-17, -15, 15, 17, 0},  // BB 
  {-16, -1, 1, 16, 0},  // BR 
  {-17, -16, -15, -1, 1, 15, 16, 17, 0},  // BQ 
  {-17, -16, -15, -1, 1, 15, 16, 17, 0},  // BK
  {0}
};
const uint32 FileMask[8] = {1, 2, 4, 8, 16, 32, 64, 128};
const int SlidingArray[16] = {0,0,0,1,2,3,0,0,0,0,0,1,2,3,0};
const int PawnPush[2] = {16, -16};
const int PieceValues[EMPTY+1] = {
  0, P_VALUE, N_VALUE, B_VALUE, R_VALUE, Q_VALUE, K_VALUE, 0,
  0, P_VALUE, N_VALUE, B_VALUE, R_VALUE, Q_VALUE, K_VALUE, 0, 0
};
const uint8 SquareColour[128] = {
  1, 2, 1, 2, 1, 2, 1, 2, 0, 0, 0, 0, 0, 0, 0, 0,
  2, 1, 2, 1, 2, 1, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0,
  1, 2, 1, 2, 1, 2, 1, 2, 0, 0, 0, 0, 0, 0, 0, 0,
  2, 1, 2, 1, 2, 1, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0,
  1, 2, 1, 2, 1, 2, 1, 2, 0, 0, 0, 0, 0, 0, 0, 0,
  2, 1, 2, 1, 2, 1, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0,
  1, 2, 1, 2, 1, 2, 1, 2, 0, 0, 0, 0, 0, 0, 0, 0,
  2, 1, 2, 1, 2, 1, 2, 1, 0, 0, 0, 0, 0, 0, 0, 0
};

extern uint8 PawnRank[2][128];
extern attack_data_t AttackData_[256];
extern attack_data_t *AttackData;
const int PieceMask[OUTSIDE+1] = {
  0,WP_MASK,N_MASK,B_MASK,R_MASK,Q_MASK,K_MASK,0,
  0,BP_MASK,N_MASK,B_MASK,R_MASK,Q_MASK,K_MASK,0,
  0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
};
extern uint8 Distance_[256];
extern uint8 *Distance;

// King activity bonus, indexed by (square of king) - (square of pawn): 
const int KingActivityBonus[256] = {
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5,
  8, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 10,
  15, 10, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 5, 13, 22,
  25, 22, 13, 5, 0, 0, 0, 0, 0, 0, 0, 0, 0, 8, 20, 30, 
  0, 30, 20, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 25, 40, 
  40, 40, 25, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 10, 22, 33,
  35, 33, 22, 10, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 14, 22,
  22, 22, 14, 7, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 7, 10,
  10, 10, 7, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 
};

extern int8 PSqTables[BK+1][128];
extern int8 KingEndgamePsq[128];
extern uint32 History[2][4096];
extern hashkey_t Zobrist[BK][64], ZobColour, ZobEP[64], ZobCastle[16];
extern root_search_info_t RSI[1];
extern engine_options_t Options[1];
extern int InitialKSQ, InitialKRSQ, InitialQRSQ;

extern bool EngineShouldQuit;


////
//// Functions
////

extern void init(void);

extern char *move2str(move_t move, char *str);
extern void print_move(move_t move);
extern void print_pv(move_t pv[], int depth, int score, int num);
extern void print_multipv(void);
extern void print_currline(const search_stack_t *ss, int ply);
extern void set_position(position_t *pos, char *fen);
extern void quit(void);
extern move_t parse_move(const position_t *pos, const char movestr[]);
extern int parse_square(const char str[]);
extern void check_for_input(void);
extern int get_time(void);

extern int extend(const position_t *pos, search_stack_t *sst, int mate_threat);

extern void init_node(const position_t *pos, search_stack_t *sstack, int ply);
extern void update_pv(search_stack_t *sstack, int ply);
extern int search(position_t *pos, search_stack_t *sstack, int ply, 
		  int alpha, int beta, int depth, int follow_pv, int nullmove);
extern int qsearch(position_t *pos, search_stack_t *sstack, int ply, 
		   int alpha, int beta, int depth, int follow_pv);

extern int see(const position_t *pos, int from, int to);

extern void think(const position_t *pos, bool inf, int wtime, int btime, 
		  int winc, int binc, int movestogo, bool ponder, 
		  int depth_limit, int node_limit, int exact_time,
		  move_t moves[]);

extern void init_root_search_info(void);
extern void root_search(const position_t *pos, move_t searchmoves[]);
extern void ponderhit(void);

extern move_stack_t *generate_moves(const position_t *pos, move_stack_t *ms);
extern move_stack_t *generate_captures(const position_t *pos, 
				       move_stack_t *ms);
extern move_stack_t *generate_check_evasions(position_t *pos, 
					     move_stack_t *ms);
extern move_stack_t *generate_checks(const position_t *pos, move_stack_t *ms);

extern bool move_is_legal(position_t *pos, move_t);
extern bool move_is_check(const position_t *pos, move_t m);
extern void make_move(position_t *pos, move_t m, undo_info_t *u);
extern void unmake_move(position_t *pos, move_t m, undo_info_t *u);
extern void make_nullmove(position_t *pos, undo_info_t *);
extern void unmake_nullmove(position_t *pos, undo_info_t *);

extern int compute_material(const position_t *pos, int side);
extern int compute_psq(const position_t *pos, int side);
extern int evaluate(const position_t *pos);
extern bool draw(const position_t *pos);

extern int pawn_endgame(const position_t *pos);
extern int scale_endgame_eval(const position_t *pos, int scale[], 
			      p_hashentry_t *ph);
extern int kxk_eval(const position_t *pos);
extern int krkb_eval(const position_t *pos);
extern int krkn_eval(const position_t *pos);
extern int krkp_eval(const position_t *pos);
extern int kqkr_eval(const position_t *pos);

extern void order_moves(const position_t *pos, search_stack_t *ss, 
			int ply, move_t pvmove);
extern void order_qmoves(const position_t *pos, search_stack_t *ss, 
			 int ply, move_t pvmove);
extern move_t pick_move(move_stack_t **start, move_stack_t *end, 
			bool look_for_best);

extern void init_zobrist(void);
extern hashkey_t compute_hash_key(const position_t *pos);
extern hashkey_t compute_phash_key(const position_t *pos);

extern void free_tt(void);
extern void clear_tt(void);
extern void init_tt(unsigned size);
extern void store_tt(const position_t *pos, int value, int depth, move_t mv,
		     int type, int mthreat);
extern int retrieve_tt(const position_t *pos, int *alpha, int *beta, int d, 
		       move_t *m, int *mthreat, int *nullmove);
extern void tt_new_search(void);

extern void init_pawn_hash_table();
extern void free_pawn_hash_table(void);
extern p_hashentry_t *analyse_pawn_structure(const position_t *pos);

extern void init_mersenne(void);
extern uint32 genrand_int32(void);
extern uint64 genrand_int64(void);

extern void define_uci_options(void);
extern void print_uci_options(void);
extern int get_option_value_bool(const char *option_name);
extern int button_was_pushed(const char *button_name);
extern int get_option_value_int(const char *option_name);
extern char *get_option_value_string(const char *option_name, char *str);
extern void set_option_value(const char *option_name, const char *value);
extern void push_button(char *button_name);

extern void uci_main_loop(void);

extern void init_position(position_t *pos);
extern void init_piece_lists(position_t *pos);
extern void copy_position(position_t *dst, const position_t *src);
extern bool is_attacked(const position_t *pos, int square, int side);
extern bool position_is_check(const position_t *pos);
extern int find_checkers(const position_t *pos, int chsqs[]);
extern int is_pinned(const position_t *pos, int square);
extern int is_disc_check_candidate(const position_t *pos, int square);
extern int count_pieces(const position_t *pos, int colour, int type);
extern void init_piece_counts(position_t *pos);

#endif // !defined(VIPER_H_INCLUDED)



