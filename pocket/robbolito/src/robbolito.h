/*
RobboLito is a UCI chess playing engine by
Yakov Petrovich Golyadkin, Igor Igorovich Igoronov, Roberto Pescatore
copyright: (C) 2009 Yakov Petrovich Golyadkin
date: 92th and 93rd year from Revolution
owners: PUBLICDOMAIN (workers)
dedication: To Vladimir Ilyich

RobboLito is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published
by the Free Software Foundation, either version 3 of the License,
or (at your option) any later version.

RobboLito is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see http://www.gnu.org/licenses/.
*/

#define BASENAME "RobboLito 0.085g3l"

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <setjmp.h>
#include <stdint.h>

#define uint8   uint8_t
#define uint16  uint16_t
#define uint32  uint32_t
#define uint64  uint64_t
#define uint64vid "%I64d"
#define sint8   int8_t
#define sint16  int16_t
#define sint32  int32_t
#define sint64  int64_t

#define UINT8   uint8_t
#define UINT16  uint16_t
#define UINT32  uint32_t
#define UINT64  uint64_t
#define UINT64VID "%I64d"
#define SINT8   int8_t
#define SINT16  int16_t
#define SINT32  int32_t
#define SINT64  int64_t

#define _atoi64 atoll

typedef struct
    {
    uint64 ZobristPawn;
    uint8 white_pawn_clear, white_pawn_dark, black_pawn_clear, black_pawn_dark, white_pawn_free_line,
        black_pawn_free_line, white_fly_number, black_fly_number;
    uint32 white_king_periglio, black_king_periglio;
    uint32 points;
    uint8 white_pawn_line_count, black_pawn_line_count, open_file_count, _1;
    } type_pawn_value;

#ifdef x86_64 // x86_64
#define NAME BASENAME " x86_64"
static inline int
BSR (uint64 w)
{
  uint64 x;
asm ("bsrq %1,%0\n": "=&r" (x):"r" (w));
  return x;
}
static inline int
BSF (uint64 w)
{
  uint64 x;
asm ("bsfq %1,%0\n": "=&r" (x):"r" (w));
  return x;
}

#ifdef HAS_POPCNT
static inline int
POPCNT (uint64 w)
{
  uint64 x;
asm ("popcntq %1,%0\n": "=&r" (x):"r" (w));
  return x;
}
#else
static inline int
POPCNT (uint64 w)
{
  w = w - ((w >> 1) & 0x5555555555555555ull);
  w = (w & 0x3333333333333333ull) + ((w >> 2) & 0x3333333333333333ull);
  w = (w + (w >> 4)) & 0x0f0f0f0f0f0f0f0full;
  return (w * 0x0101010101010101ull) >> 56;
}
#endif /* HAS_POPCNT */

#else // x86
#define NAME BASENAME " x86"
#ifndef _ALT
extern const int lsb_64_table[64];
extern const char msb_256_table[256];

static inline int BSR32(uint32 bb) {

#ifdef USE_ARM_ASM
  
  return ( 31 - __builtin_clz(bb) );
      
#else  
  int result = 0;
   
  if (bb > 0xFFFF) {
      bb >>= 16;
      result += 16;
   }
   if (bb > 0xFF) {
      bb >>= 8;
      result += 8;
   }

   return (result + msb_256_table[bb]);
#endif
}

static inline int BSR (uint64 bb) {
#ifdef USE_X86_ASM
    int x1, x2;
asm ("bsr %1,%0\n" "jnz 1f\n" "bsr %0,%0\n" "subl $32,%0\n"
     "1: addl $32,%0\n": "=&q" (x1), "=&q" (x2):"1" ((int) (bb >> 32)),
     "0" ((int) bb));
  return x1;
#else
  const uint32 hb = bb >> 32;
  return hb ? 32 + BSR32((uint32)hb) : BSR32((uint32)bb);
#endif
}

static inline int
BSF (uint64 bb)
{
   unsigned int folded;
   //assert (bb != 0);
   bb ^= bb - 1;
   folded = (int) bb ^ (bb >> 32);
   return lsb_64_table[folded * 0x78291ACF >> 26];

/*
  int x1, x2;
asm ("bsf %0,%0\n" "jnz 1f\n" "bsf %1,%0\n" "jz 1f\n" "addl $32,%0\n"
     "1:": "=&q" (x1), "=&q" (x2):"1" ((int) (w >> 32)),
     "0" ((int) w));
  return x1;*/

}

#endif
static inline int
POPCNT( UINT64 v )
    {
    unsigned int v1, v2;
    v1 = (unsigned int)(v & 0xFFFFFFFF);
    v1 -= (v1 >> 1) & 0x55555555;
    v1 = (v1 & 0x33333333) + ((v1 >> 2) & 0x33333333);
    v1 = (v1 + (v1 >> 4)) & 0x0F0F0F0F;
    v2 = (unsigned int)(v >> 32);
    v2 -= (v2 >> 1) & 0x55555555;
    v2 = (v2 & 0x33333333) + ((v2 >> 2) & 0x33333333);
    v2 = (v2 + (v2 >> 4)) & 0x0F0F0F0F;
    return ((v1 * 0x01010101) >> 24) + ((v2 * 0x01010101) >> 24);
    }
#endif

#define bit_FREE(b, B) B &= (B - 1)
#define bitFIXED(b, B) B |= ((uint64) 1) << (b)

#define bool uint8
#define TRUE 1
#define FALSE 0

#define flag_cut 4
#define flag_total 8
#define flag_low 1
#define flag_high 2
#define flag_precise 16

#define zobrist_cut(tr) ((tr->flags) & flag_cut)
#define zobrist_total(tr) ((tr->flags) & flag_total)
#define zobrist_accurate(tr) ((tr)->flags & flag_precise)
#define zobrist_value_high(tr) (tr->value_high)
#define zobrist_value_low(tr) (tr->value_low)

#define FILE(s) ((s) & 7)
#define RANK(s) ((s) >> 3)
#define DI(s) (((s) >> 6) & 077)
#define AI(s) ((s) & 077)

uint64 move_white_number, move_black_number, move_null_number;

#define call_value_full(m) valuation(-0x7fff0000, 0x7fff0000, m)
#define call_value_lazy(B, A, p, m) valuation((B) - (p), (A) + (p), m)

#define white_in_check (DYNAMIC->attak_black & bitboard_white_king)
#define black_in_check (DYNAMIC->attak_white & bitboard_black_king)
#define POSITION_1 (POSITION_0 + 1)
#define move_white_in_check (POSITION_1->white_king_check)
#define move_black_in_check (POSITION_1->black_king_check)
#define QU POSITION.qu

sint16 maximum_positional_gain[0x10][07777];
bool border_legitimate, GAME_NEW;

uint64 STACK[1024];
int stack_height;

#define repetition_check                                           \
    if (DYNAMIC->move50 >= 100) RETURN(0);                         \
    for (i = 4; i <= DYNAMIC->move50 && i <= stack_height; i += 2) \
    if (STACK[stack_height - i] == DYNAMIC->Zobrist) RETURN(0);

typedef struct
    {
    uint32 zobrist;
    uint8 flags;
    uint8 years;
    uint8 hole_high, hole_low;
    uint16 move;
    sint16 value_low;
    uint16 _2;
    sint16 value_high;
    } type_zobrist;

type_zobrist *list_zobrist;
uint64 list_hide, YEARS;

typedef struct
    {
    uint64 zobrist;
    sint32 value;
    uint16 move;
    uint8 depth, years;
    } type_zobrist_pv;
type_zobrist_pv list_zobrist_pv[0x10000];

#define list_hide_pv 0xfffc
#define list_pawn_number (1 << 16)

typedef struct
    {
    uint32 move;
    } type_list_move;

typedef struct
    {
    uint8 qu[64];
    uint64 bitboard[16], occupied_black_white, occupied_left90, occupied_left45, occupied_straight45;
    uint8 white_en_move, white_king_square, black_king_square, castle;
    } type_position;

type_position POSITION;

typedef struct
    {
    uint64 Zobrist, ZobristPawn;
    uint32 material_, statik, _7;
    uint8 castle, move50, en_passant, capture;
    uint64 attak_white, attak_black, white_xray, black_xray;
    sint32 value, value_positional;
    uint16 _5, _6, killer_one, killer_two, move;
    uint8 _0, _3, _4, lazy, flags_saves, flags;
    uint64 white_king_check, black_king_check, _1, _2, _8;
    } type_dynamic;

#define hole_maximum 1024

type_dynamic dynamic_initial[hole_maximum];
type_dynamic *DYNAMIC;

#define ep_plate (DYNAMIC->en_passant)
#define castling_white_oo (DYNAMIC->castle & 0x1)
#define castling_white_ooo (DYNAMIC->castle & 0x2)
#define castling_black_oo (DYNAMIC->castle & 0x4)
#define castling_black_ooo (DYNAMIC->castle & 0x8)

typedef struct
    {
    sint16 value;
    uint8 sign;
    uint8 flags;
    } type_material;
type_material MATERIAL[419904];

typedef enum
    {
    count_occupied_white,
    count_pawn_white,
    count_knight_white,
    count_king_white,
    count_clear_white,
    count_dark_white,
    count_rook_white,
    count_queen_white,
    count_occupied_black,
    count_pawn_black,
    count_knight_black,
    count_king_black,
    count_clear_black,
    count_dark_black,
    count_rook_black,
    count_queen_black
    } count_pieces;

typedef enum
    {
    TRAS,
    capture_gen,
    move_capture,
    KILLER_ONE,
    KILLER_TWO,
    move_ordinary,
    capture_bad,
    TRAS2,
    capture_gen2,
    move_capture2,
    check_quiet,
    elusione,
    TRAS3,
    capture_gen3,
    move_capture3,
    check_quiet3,
    guadagno
    } count_phases;

typedef enum
    {
    A1,
    B1,
    C1,
    D1,
    E1,
    F1,
    G1,
    H1,
    A2,
    B2,
    C2,
    D2,
    E2,
    F2,
    G2,
    H2,
    A3,
    B3,
    C3,
    D3,
    E3,
    F3,
    G3,
    H3,
    A4,
    B4,
    C4,
    D4,
    E4,
    F4,
    G4,
    H4,
    A5,
    B5,
    C5,
    D5,
    E5,
    F5,
    G5,
    H5,
    A6,
    B6,
    C6,
    D6,
    E6,
    F6,
    G6,
    H6,
    A7,
    B7,
    C7,
    D7,
    E7,
    F7,
    G7,
    H7,
    A8,
    B8,
    C8,
    D8,
    E8,
    F8,
    G8,
    H8
    } count_squares;

typedef enum
    {
    T1,
    T2,
    T3,
    T4,
    T5,
    T6,
    T7,
    T8
    } count_ranks;

typedef enum
    {
    CA,
    CB,
    CC,
    CD,
    CE,
    CF,
    CG,
    CH
    } count_files;

sint32 static_value[16][64];
uint16 history_value[16][64];
uint64 node_count, node_frequency;
char STRING1[64], STRING2[64], STRING3[64], STRING4[64];

#define bitboard_white_king POSITION.bitboard[count_king_white]
#define bitboard_white_queen POSITION.bitboard[count_queen_white]
#define bitboard_white_rook POSITION.bitboard[count_rook_white]
#define bitboard_white_clear POSITION.bitboard[count_clear_white]
#define bitboard_white_dark POSITION.bitboard[count_dark_white]
#define bitboard_white_bishop (bitboard_white_clear|bitboard_white_dark)
#define bitboard_white_knight POSITION.bitboard[count_knight_white]
#define bitboard_white_pawn POSITION.bitboard[count_pawn_white]
#define bitboard_occupied_white POSITION.bitboard[count_occupied_white]
#define bitboard_black_king POSITION.bitboard[count_king_black]
#define bitboard_black_queen POSITION.bitboard[count_queen_black]
#define bitboard_black_rook POSITION.bitboard[count_rook_black]
#define bitboard_black_clear POSITION.bitboard[count_clear_black]
#define bitboard_black_dark POSITION.bitboard[count_dark_black]
#define bitboard_black_bishop (bitboard_black_clear|bitboard_black_dark)
#define bitboard_black_knight POSITION.bitboard[count_knight_black]
#define bitboard_black_pawn POSITION.bitboard[count_pawn_black]
#define bitboard_occupied_black POSITION.bitboard[count_occupied_black]

#define turn_left45 lineturn[direction_h1a8]
#define turn_straight45 lineturn[direction_a1h8]
#define turn_normal lineturn[direction_horizontal]
#define turn_left90 lineturn[direction_vertical]
#define attack_left45 line_obscured[direction_h1a8]
#define attack_straight45 line_obscured[direction_a1h8]
#define attack_normal line_obscured[direction_horizontal]
#define attack_left90 line_obscured[direction_vertical]

#define ATTACK_h1a8(di) \
    attack_left45       \
    [di][(POSITION.occupied_left45 >> turn_left45[di]) & 077]
#define ATTACK_a1h8(di) \
    attack_straight45   \
    [di][(POSITION.occupied_straight45 >> turn_straight45[di]) & 077]
#define ATTACK_rank(di) \
    attack_normal       \
    [di][(POSITION.occupied_black_white >> turn_normal[di]) & 077]
#define ATTACK_file(di) \
    attack_left90       \
    [di][(POSITION.occupied_left90 >> turn_left90[di]) & 077]

#define MAXIMUM(x, y) (( (x) >= (y)) ? (x) : (y))
#define MINIMUM(x, y) (( (x) <= (y)) ? (x) : (y))
#define ABSOLUTE_(x) (( (x) >= 0) ? (x) : -(x))
#define file_detach(x, y) (ABSOLUTE_(FILE(x) - FILE(y)))
#define rank_detach(x, y) (ABSOLUTE_(RANK(x) - RANK(y)))

#define attack_bishop(di) (ATTACK_a1h8(di) | ATTACK_h1a8(di))
#define attack_rook(di) (ATTACK_rank(di) | ATTACK_file(di))
#define attack_queen(di) (attack_rook(di) | attack_bishop(di))

#define flag_en_passant 030000
#define flag_castling 010000
#define flag_hide 070000
#define flag_promotion_queen 070000
#define flag_promotion_rook 060000
#define flag_promotion_bishop 050000
#define flag_promotion_knight 040000
#define move_en_passant(x) (((x) & flag_hide) == flag_en_passant)
#define move_promotion(x) (((x) & flag_hide) >= flag_promotion_knight)
#define move_castling(x) (((x) & flag_hide) == flag_castling)
#define move_history(x) (((x) & 060000) == 0)

#define direction_horizontal 2
#define direction_vertical 3
#define direction_a1h8 1
#define direction_h1a8 0
#define direction_sick 37
#define VALUE_MATE 30000
#define VALUE_INFINITE 32750
#define MOVE_NONE 0

#include "stack.h"
#include "function.h"
#include "common.h"
