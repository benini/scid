#ifndef POSITION_H
#define POSITION_H

#include "bitboards.h"

static inline int getcol(FLD f) { return (f % 8); }
static inline int getrow(FLD f) { return (f / 8); }

typedef U8 COLOR;
enum COLOR_TAG 
{
	WHITE = 0,
	BLACK = 1
};

static inline COLOR getopp(COLOR side) { return (COLOR) (side ^ 1); }

typedef U8 PIECE;
enum PIECE_TAG
{
	NOPIECE =  0,
	PAWNW   =  2,
	PAWNB   =  3,
	KNIGHTW =  4,
	KNIGHTB =  5,
	BISHOPW =  6,
	BISHOPB =  7,
	ROOKW   =  8,
	ROOKB   =  9,
	QUEENW  = 10,
	QUEENB  = 11,
	KINGW   = 12,
	KINGB   = 13
};

static inline COLOR getcolor(PIECE piece) { return (COLOR) (piece & 1); }

typedef U32 Move;
typedef int EVAL;

// Fields in Move:
//
// from      6  18-23
// to        6  12-17
// piece     4   8-11
// captured  4   4-7
// promotion 4   0-4

#define mv_compose(from, to, piece, captured, promotion) \
(                                                        \
(((Move)(from)) << 18) |                                 \
(((Move)(to)) << 12) |                                   \
(((Move)(piece)) << 8) |                                 \
(((Move)(captured)) << 4) |                              \
(((Move)(promotion)) << 0)                               \
)

#define mv_from(mv)      (((mv) >> 18) & 0x3F) 
#define mv_to(mv)        (((mv) >> 12) & 0x3F)
#define mv_piece(mv)     (((mv) >> 8) & 0x0F)
#define mv_captured(mv)  (((mv) >> 4) & 0x0F)
#define mv_promotion(mv) (((mv) >> 0) & 0x0F)

struct Undo
{
	U8 castlings;
	FLD ep;
	int fifty;
	U64 hash;
	Move mv;
};
typedef struct Undo Undo;

#define WHITE_CAN_O_O   (0x01)
#define WHITE_CAN_O_O_O (0x02)
#define BLACK_CAN_O_O   (0x04)
#define BLACK_CAN_O_O_O (0x08)

#define WHITE_DID_O_O   (0x10)
#define WHITE_DID_O_O_O (0x20)
#define BLACK_DID_O_O   (0x40)
#define BLACK_DID_O_O_O (0x80)

#define UNDO_SIZE        (600)

struct Position
{
	U64   bits[14];
	U64   bits_all[2];
	PIECE board[64];
	U8    castlings;
	int   count[14];
	FLD   ep;
	int   fifty;
	U64   hash;
	FLD   King[2];
	Move  last_move;
	EVAL  material[2];
	COLOR opp;
	int   ply;
	COLOR side;
	Undo  undos[UNDO_SIZE + 2];
	int   undo_cnt;
};
typedef struct Position Position;

void        clear_pos(Position* pos);
void        copy_pos(Position* dest, const Position* src);
const char* fld_to_str(FLD f);
void        free_pos(Position* pos);
U64         get_attacks(const Position* pos, FLD f0, COLOR side);
char*       get_fen(const Position* pos, char* buf);
int         get_repetitions(const Position* pos);
void        init_hash_coeffs();
int         is_attacked(const Position* pos, FLD f, COLOR side);
int         is_draw(const Position* pos);
int         is_in_check(const Position* pos);
void        mirror(Position* pos);
U32         pawn_hash(const Position* pos);
void        print_attacks(const Position* pos);
void        print_pos(const Position* pos);
void        put_piece(Position* pos, FLD f, PIECE p);
int         make_move(Position* pos, Move mv);
void        make_null_move(Position* pos);
Position*   new_pos();
void        remove_piece(Position* pos, FLD f);
void        set_initial(Position* pos);
int         set_fen(Position* pos, const char* fen);
FLD         str_to_fld(const char* s);
Move        str_to_move(const Position* pos, const char* s);
void        unmake_move(Position* pos);
void        unmake_null_move(Position* pos);

extern FLD steps[8][64];
extern FLD knight_steps[8][64];

#endif

