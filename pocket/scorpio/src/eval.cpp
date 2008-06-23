#include "scorpio.h"

#define PAW_BITS   192
#define MIN_BITS    48
#define ROO_BITS    12
#define QUE_BITS     2
#define KIN_BITS     1
#define PM_BITS    240
#define PMR_BITS   252
#define RM_BITS     60
#define XQUE_BITS  253
#define XKIN_BITS  254 

#define PAW_INC  64
#define MIN_INC  16
#define ROO_INC   4 
#define QUE_INC   2
#define KIN_INC   1
/*
GENERATE ATTACK
*/
#define WN_GEN_ATTACK(dir) { \
	sq = c_sq + dir; \
    if(board[sq] == empty) {\
        mob++;\
        if(!(BB[sq] & PAW_BITS)) smob++;\
	}\
	WB[sq] += MIN_INC;\
};
#define BN_GEN_ATTACK(dir) { \
	sq = c_sq + dir; \
	if(board[sq] == empty) {\
	    mob++;\
		if(!(WB[sq] & PAW_BITS)) smob++;\
	}\
	BB[sq] += MIN_INC;\
};
#define WB_GEN_ATTACK(dir)  { \
	sq = c_sq + dir; \
    while(board[sq] == empty) {\
	   mob++;\
	   if(!(BB[sq] & PAW_BITS)) smob++;\
	   WB[sq] += MIN_INC;\
	   sq += dir;\
	} \
    if(!(sq & 0x88)) {\
	   WB[sq] += MIN_INC;\
	   switch(board[sq]) {\
		  case wqueen:\
		    sq += dir;\
			while(board[sq] == empty) {\
	           WB[sq] += MIN_INC;\
	           sq += dir;\
			} \
	        break;\
          case bknight:\
		  case brook:\
		  case bqueen:\
		    sq += dir;\
			while(board[sq] == empty) sq += dir;\
            if((temp = board[sq]) == bking || temp == bqueen || temp == brook)\
			    b_score -= PINNED_PIECE;\
            break;\
       }\
	}\
};
#define BB_GEN_ATTACK(dir)  { \
    sq = c_sq + dir; \
    while(board[sq] == empty) {\
	   mob++;\
	   if(!(WB[sq] & PAW_BITS)) smob++;\
	   BB[sq] += MIN_INC;\
	   sq += dir;\
	} \
	if(!(sq & 0x88)) {\
	   BB[sq] += MIN_INC;\
	   switch(board[sq]) {\
		 case bqueen:\
		    sq += dir;\
			while(board[sq] == empty) {\
	           BB[sq] += MIN_INC;\
	           sq += dir;\
			} \
			break;\
         case wknight:\
		 case wrook:\
		 case wqueen:\
		    sq += dir;\
			while(board[sq] == empty) sq += dir;\
            if((temp = board[sq]) == wking || temp == wqueen || temp == wrook)\
			    w_score -= PINNED_PIECE;\
            break;\
	   }\
	}\
};
#define WR_GEN_ATTACK(dir)  { \
    sq = c_sq + dir; \
    while(board[sq] == empty) {\
	   mob++;\
	   if(!(BB[sq] & PM_BITS)) smob++;\
	   WB[sq] += ROO_INC;\
	   sq += dir;\
    } \
	if(!(sq & 0x88)) {\
	   WB[sq] += ROO_INC;\
       switch(board[sq]) {\
		  case wrook:\
		  case wqueen:\
		    sq += dir;\
			while(board[sq] == empty) {\
	           WB[sq] += ROO_INC;\
	           sq += dir;\
			} \
			break;\
          case bknight:\
		  case bbishop:\
		  case bqueen:\
		    sq += dir;\
			while(board[sq] == empty) sq += dir;\
            if((temp = board[sq]) == bking || temp == bqueen)\
			    b_score -= PINNED_PIECE;\
            break;\
       }\
    }\
};
#define BR_GEN_ATTACK(dir)  { \
    sq = c_sq + dir; \
    while(board[sq] == empty) {\
	   mob++;\
	   if(!(WB[sq] & PM_BITS)) smob++;\
	   BB[sq] += ROO_INC;\
	   sq += dir;\
	} \
	if(!(sq & 0x88)) {\
	   BB[sq] += ROO_INC;\
	   switch(board[sq]) {\
		  case brook:\
		  case bqueen:\
		    sq += dir;\
			while(board[sq] == empty) {\
	           BB[sq] += ROO_INC;\
	           sq += dir;\
			}\
		    break;\
          case wknight:\
		  case wbishop:\
		  case wqueen:\
		    sq += dir;\
			while(board[sq] == empty) sq += dir;\
            if((temp = board[sq]) == wking || temp == wqueen)\
			    w_score -= PINNED_PIECE;\
            break;\
       }\
	}\
};
/*queen attack through rook/bishops is weak!?
=>assume it is a rook attack
*/
#define WQR_GEN_ATTACK(dir)  { \
    sq = c_sq + dir; \
    while(board[sq] == empty) {\
	   mob++;\
	   if(!(BB[sq] & PMR_BITS)) smob++;\
	   WB[sq] += QUE_INC;\
	   sq += dir;\
	} \
	if(!(sq & 0x88)) {\
	   WB[sq] += QUE_INC;\
	   switch(board[sq]) {\
		  case wrook:\
		  case wqueen:\
		    sq += dir;\
			while(board[sq] == empty) {\
	           WB[sq] += ROO_INC;\
	           sq += dir;\
			} \
			break;\
          case bknight:\
		  case bbishop:\
		    sq += dir;\
			while(board[sq] == empty) sq += dir;\
            if((temp = board[sq]) == bking)\
			    b_score -= PINNED_PIECE;\
            break;\
       }\
	}\
};
#define BQR_GEN_ATTACK(dir)  { \
    sq = c_sq + dir; \
    while(board[sq] == empty) {\
	   mob++;\
	   if(!(WB[sq] & PMR_BITS)) smob++;\
	   BB[sq] += QUE_INC;\
	   sq += dir;\
	} \
	if(!(sq & 0x88)) {\
	   BB[sq] += QUE_INC;\
	   switch(board[sq]) {\
		  case brook:\
		  case bqueen:\
		    sq += dir;\
			while(board[sq] == empty) {\
	           BB[sq] += ROO_INC;\
	           sq += dir;\
			} \
		    break;\
          case wknight:\
		  case wbishop:\
		    sq += dir;\
			while(board[sq] == empty) sq += dir;\
            if((temp = board[sq]) == wking)\
			    w_score -= PINNED_PIECE;\
            break;\
       }\
	}\
};
#define WQB_GEN_ATTACK(dir)  { \
    sq = c_sq + dir; \
    while(board[sq] == empty) {\
	   mob++;\
	   if(!(BB[sq] & PAW_BITS)) smob++;\
	   WB[sq] += QUE_INC;\
	   sq += dir;\
	} \
	if(!(sq & 0x88)) {\
	   WB[sq] += QUE_INC;\
	   switch(board[sq]) {\
		  case wbishop:\
		  case wqueen:\
		    sq += dir;\
			while(board[sq] == empty) {\
	           WB[sq] += ROO_INC;\
	           sq += dir;\
			} \
			break;\
          case bknight:\
		  case brook:\
		    sq += dir;\
			while(board[sq] == empty) sq += dir;\
            if((temp = board[sq]) == bking)\
			    b_score -= PINNED_PIECE;\
            break;\
       }\
	}\
};
#define BQB_GEN_ATTACK(dir)  { \
    sq = c_sq + dir; \
    while(board[sq] == empty) {\
	   mob++;\
	   if(!(WB[sq] & PAW_BITS)) smob++;\
	   BB[sq] += QUE_INC;\
	   sq += dir;\
	} \
	if(!(sq & 0x88)) {\
	   BB[sq] += QUE_INC;\
	   switch(board[sq]) {\
		  case bbishop:\
		  case bqueen:\
		    sq += dir;\
			while(board[sq] == empty) {\
	           BB[sq] += ROO_INC;\
	           sq += dir;\
			} \
		    break;\
          case wknight:\
		  case wrook:\
		    sq += dir;\
			while(board[sq] == empty) sq += dir;\
            if((temp = board[sq]) == wking)\
			    w_score -= PINNED_PIECE;\
            break;\
       }\
	}\
};
/*
KING SQUARE ATTACK
 ->a queen attacking a square ,supported only by king,
   along with any piece gets a score of +5!?
*/
#define W_ATTACK(dir) {\
	sq = b_ksq + dir;\
	if(!(sq & 0x88))  {\
	   wAT = WB[sq];\
       bAT = BB[sq];\
	   if(wAT) {\
           attack++;\
		   attackers |= wAT;\
           if(wAT & QUE_BITS) {\
		      attack++;\
              if(wAT & XQUE_BITS) {\
			      attack++;\
                  if(bAT == KIN_BITS) attack += 2;\
			  } else {\
			      if(bAT == KIN_BITS) attack++;\
			  }\
		   } else {\
              if(bAT == KIN_BITS) attack++;\
		   }\
       }\
	}\
};
#define B_ATTACK(dir) {\
	sq = w_ksq + dir;\
	if(!(sq & 0x88))  {\
	   wAT = WB[sq];\
       bAT = BB[sq];\
	   if(bAT) {\
           attack++;\
		   attackers |= bAT;\
		   if(bAT & QUE_BITS) {\
		      attack++;\
              if(bAT & XQUE_BITS) {\
			      attack++;\
                  if(wAT == KIN_BITS) attack += 2;\
			  } else {\
			      if(wAT == KIN_BITS) attack++;\
			  }\
		   } else {\
              if(wAT == KIN_BITS) attack++;\
		   }\
	   }\
	}\
};

#define W_ATTACK2(dir) {\
	sq = b_ksq + dir;\
	if(!(sq & 0x88) && (wAT = WB[sq]))  {\
        attackers |= wAT;\
	}\
};
#define B_ATTACK2(dir) {\
	sq = w_ksq + dir;\
	if(!(sq & 0x88) && (bAT = BB[sq]))  {\
	    attackers |= bAT;\
	}\
};
/*
first and last bits of a byte
*/
static unsigned char first_bit[0x100] = {
	8, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0,
	4, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0,
	5, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0,
	4, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0,
	6, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0,
	4, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0,
	5, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0,
	4, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0,
	7, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0,
	4, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0,
	5, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0,
	4, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0,
	6, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0,
	4, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0,
	5, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0,
	4, 0, 1, 0, 2, 0, 1, 0, 3, 0, 1, 0, 2, 0, 1, 0
};
static unsigned char last_bit[0x100] = {
	8, 0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3,
	4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4,
	5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
	5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
	6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
	6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
	6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
	6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
	7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
	7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
	7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
	7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
	7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
	7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
	7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
	7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7
};
static unsigned char center_bit[0x100] = {
	0, 1, 2, 1, 3, 2, 2, 2, 4, 2, 3, 2, 3, 2, 3, 2,
	5, 3, 3, 2, 4, 3, 3, 2, 4, 3, 3, 3, 4, 3, 3, 3,
	6, 3, 4, 3, 4, 3, 3, 3, 5, 3, 4, 3, 4, 3, 3, 3,
	5, 4, 4, 3, 4, 3, 4, 3, 5, 4, 4, 3, 4, 3, 4, 3,
	7, 4, 4, 3, 5, 3, 4, 3, 5, 4, 4, 3, 4, 3, 4, 3,
	6, 4, 4, 3, 5, 4, 4, 3, 5, 4, 4, 3, 4, 4, 4, 3,
	6, 4, 5, 4, 5, 4, 4, 3, 5, 4, 4, 4, 5, 4, 4, 3,
	6, 4, 5, 4, 5, 4, 4, 4, 5, 4, 4, 4, 5, 4, 4, 4,
	8, 4, 5, 3, 5, 4, 4, 3, 6, 4, 4, 3, 5, 4, 4, 3,
	6, 4, 5, 4, 5, 4, 4, 3, 5, 4, 4, 4, 5, 4, 4, 3,
	7, 5, 5, 4, 5, 4, 4, 4, 6, 4, 5, 4, 5, 4, 4, 4,
	6, 5, 5, 4, 5, 4, 4, 4, 5, 4, 5, 4, 5, 4, 4, 4,
	7, 5, 5, 4, 6, 4, 5, 4, 6, 5, 5, 4, 5, 4, 4, 4,
	6, 5, 5, 4, 5, 4, 5, 4, 6, 5, 5, 4, 5, 4, 4, 4,
	7, 5, 5, 4, 6, 5, 5, 4, 6, 5, 5, 4, 5, 4, 5, 4,
	6, 5, 5, 4, 5, 5, 5, 4, 6, 5, 5, 4, 5, 4, 5, 4
};
static const int outpost[] = { 
	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,
	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,
	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,
	0,	0, 10, 15, 15, 10,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,
	0,	0, 10, 15, 15, 10,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,
	0,	0, 10, 15, 15, 10,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,
	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,
	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0
}; 
static const int qr_on_7thrank[] = {
	0,  0,  30, 20, 70, 100, 200, 200, 200,
	200, 200, 200, 200, 200, 200, 200, 200, 200
};
static const int rook_on_hopen[] = {
	0,  10,  20,  30,  50, 60, 70, 90, 100, 110,
	130, 140, 150
};
static const int king_to_pawns[] = {
	0,  20,  60,  100, 140, 140, 140, 140
};
static int  king_pcsq_mid[0x80] = {
	-10,  0,-10,-20,-20,-10,  0,-10,  0,  0,  0,  0,  0,  0,  0,  0,
	-20,-20,-25,-30,-30,-25,-20,-20,  0,  0,  0,  0,  0,  0,  0,  0,
	-40,-40,-40,-40,-40,-40,-40,-40,  0,  0,  0,  0,  0,  0,  0,  0,
	-60,-60,-60,-60,-60,-60,-60,-60,  0,  0,  0,  0,  0,  0,  0,  0,
	-80,-80,-80,-80,-80,-80,-80,-80,  0,  0,  0,  0,  0,  0,  0,  0,
	-80,-80,-80,-80,-80,-80,-80,-80,  0,  0,  0,  0,  0,  0,  0,  0,
	-80,-80,-80,-80,-80,-80,-80,-80,  0,  0,  0,  0,  0,  0,  0,  0,
	-80,-80,-80,-80,-80,-80,-80,-80,  0,  0,  0,  0,  0,  0,  0,  0
};
static const int  king_pcsq_end[0x80] = {
	-30,-20,-10,  0,  0,-10,-20,-30,  0,  0,  0,  0,  0,  0,  0,  0,  
	-20,-10,  0, 10, 10,  0,-10,-20,  0,  0,  0,  0,  0,  0,  0,  0,  
	-10,  0, 10, 20, 20, 10,  0,-10,  0,  0,  0,  0,  0,  0,  0,  0,  
	0, 10, 20, 30, 30, 20, 10,  0,  0,  0,  0,  0,  0,  0,  0,  0,  
	0, 10, 20, 30, 30, 20, 10,  0,  0,  0,  0,  0,  0,  0,  0,  0,  
	-10,  0, 10, 20, 20, 10,  0,-10,  0,  0,  0,  0,  0,  0,  0,  0,  
	-20,-10,  0, 10, 10,  0,-10,-20,  0,  0,  0,  0,  0,  0,  0,  0,  
	-30,-20,-10,  0,  0,-10,-20,-30,  0,  0,  0,  0,  0,  0,  0,  0
};
static const int  kbnk_pcsq[0x80] = {
	70, 60, 50, 40, 30, 20, 10,  0,  0,  0,  0,  0,  0,  0,  0,  0,
	60, 70, 60, 50, 40, 30, 20, 10,  0,  0,  0,  0,  0,  0,  0,  0,  
	50, 60, 70, 60, 50, 40, 30, 20,  0,  0,  0,  0,  0,  0,  0,  0,  
	40, 50, 60, 70, 60, 50, 40, 30,  0,  0,  0,  0,  0,  0,  0,  0,  
	30, 40, 50, 60, 70, 60, 50, 40,  0,  0,  0,  0,  0,  0,  0,  0,  
	20, 30, 40, 50, 60, 70, 60, 50,  0,  0,  0,  0,  0,  0,  0,  0,  
	10, 20, 30, 40, 50, 60, 70, 60,  0,  0,  0,  0,  0,  0,  0,  0,  
	0, 10, 20, 30, 40, 50, 60, 70,  0,  0,  0,  0,  0,  0,  0,  0 
};
static const int king_attack[] = {
	0,   1,   4,   9,  16,  25,  36,  49,
	64,  81, 100, 121, 144, 169, 196, 225,
	256, 289, 324, 354, 384, 414, 444, 474,
	504, 534, 564, 594, 624, 624, 624, 624,
	624, 624, 624, 624, 624, 624, 624, 624,
	624, 624, 624, 624, 624, 624, 624, 624,
	624, 624, 624, 624, 624, 624, 624, 624,
	624, 624, 624, 624, 624, 624, 624, 624,
	624, 624, 624, 624, 624, 624, 624, 624,
	624, 624, 624, 624, 624, 624, 624, 624
};
static const int king_on_hopen[] = {
	0,  1,  3,  5,  2,  5,  5,  6
};
static const int king_on_file[] = {
	1,  0,  2,  3,  3,  2,  0,  1
};
static const int king_on_rank[] = {
	0,  1,  2,  3,  3,  3,  3,  3
};

static int  piece_tropism[8] = {0,  10, 10, 10,  5,  0,  0,  0};
static int  file_tropism[8] =  {20, 15, 10,  5,  0,  0,  0,  0};

#define   W_TRAPPED_PIECE  ((r + 1) * 5)
#define   B_TRAPPED_PIECE  ((7 - r + 1) * 5)
#define   PINNED_PIECE     20
#define   FORK             80
#define   TEMPO_BONUS      10

static const UBMP8  mask[8] = {1,  2,  4,  8, 16, 32, 64,128};
static const UBMP8  up_mask[8] = {254,252,248,240,224,192,128,  0};
static const UBMP8  down_mask[8] = {0,  1,  3,  7, 15, 31, 63,127};
static const UBMP8  updown_mask[8] = {254, 253, 251, 247, 239, 223, 191, 127};

/*
static evaluator
*/
int SEARCHER::eval(int lazy) {
	register int w_score;
	register int b_score;
	int w_mobility;
	int b_mobility;
	int w_tropism;
	int b_tropism;
	int w_win_chance = 8;
	int b_win_chance = 8;
	int w_on7th;
	int b_on7th;
	int wr_onhopen;
	int br_onhopen;
	int attack;
	int defence;
	int slowattack;
	register UBMP8 wAT,bAT,attackers;
	register int w_ksq = plist[wking]->sq;
    register int b_ksq = plist[bking]->sq;
	int end_game = (piece_c[white] + piece_c[black] <= 28);
	int f,r,sq,c_sq,mob,smob,temp,temp1;
	UBMP8 hopen;
	PLIST current;

	memset(&pstack->evalrec,0,sizeof(pstack->evalrec));

	/*
	. check_eval hash table
	. check endgame knowledge
	*/
	if(probe_eval_hash(hash_key,temp,temp1,pstack->evalrec)
		|| eval_win_chance(temp,temp1,w_win_chance,b_win_chance)
		) {

	    full_evals++;
		pstack->actual_score = (player == white) ? temp:-temp;
        pstack->lazy_score = (player == white) ? temp1:-temp1;

		/*tempo*/
	    eval_tempo();

		return pstack->actual_score;
	}
	
    /*material score*/
    w_score = temp;
	b_score = 0;

	/*trapped bishop*/
	if((board[A7] == wbishop || (board[B8] == wbishop && board[C7] == bpawn))
		&& board[B6] == bpawn
		) {
		w_score -= 80;
		if(board[C7] == bpawn)
			w_score -= 40;
	}
    if((board[H7] == wbishop || (board[G8] == wbishop && board[F7] == bpawn))
		&& board[G6] == bpawn
		) {
		w_score -= 80;
		if(board[F7] == bpawn) 
			w_score -= 40;
	}
	if((board[A2] == bbishop || (board[B1] == bbishop && board[C2] == wpawn))
		&& board[B3] == wpawn
		) {
		b_score -= 80;
		if(board[C2] == wpawn) 
			b_score -= 40;
	}
    if((board[H2] == bbishop || (board[G1] == bbishop && board[F2] == wpawn))
		&& board[G3] == wpawn
		) {
		b_score -= 80;
		if(board[F2] == wpawn) 
			b_score -= 40;
	}

	/*trapped knight*/
	if(board[A7] == wknight && board[B7] == bpawn && board[C6] == bpawn)
		w_score -= 120;
    if(board[H7] == wknight && board[G7] == bpawn && board[F6] == bpawn) 
		w_score -= 120;
	if(board[A2] == bknight && board[B2] == wpawn && board[C3] == wpawn) 
		b_score -= 120;
    if(board[H2] == bknight && board[G2] == wpawn && board[F3] == wpawn) 
		b_score -= 120;

	/*trapped rook*/
	if((board[F1] == wking || board[G1] == wking) && 
		(board[H1] == wrook || board[H2] == wrook || board[G1] == wrook || board[G2] == wrook ))
		w_score -= 70;
	if((board[C1] == wking || board[B1] == wking) && 
		(board[A1] == wrook || board[A2] == wrook || board[B1] == wrook || board[B2] == wrook ))
		w_score -= 70;
	
	if((board[F8] == bking || board[G8] == bking) && 
		(board[H8] == brook || board[H7] == brook || board[G8] == brook || board[G7] == brook ))
		b_score -= 70;
	if((board[C8] == bking || board[B8] == bking) && 
		(board[A8] == brook || board[A7] == brook || board[B8] == brook || board[B7] == brook ))
		b_score -= 70;

	/*trapped bishop at A6/H6/A3/H3*/
	if(board[A6] == wbishop && board[B5] == bpawn)
		w_score -= 50;
	if(board[H6] == wbishop && board[G5] == bpawn)
		w_score -= 50;
	if(board[A3] == bbishop && board[B4] == wpawn)
		b_score -= 50;
	if(board[H3] == bbishop && board[G4] == wpawn)
		b_score -= 50;

	/*trapped knight at A8/H8/A1/H1*/
	if(board[A8] == wknight && (board[A7] == bpawn || board[C7] == bpawn))
		w_score -= 50;
	if(board[H8] == wknight && (board[H7] == bpawn || board[G7] == bpawn))
		w_score -= 50;
	if(board[A1] == bknight && (board[A2] == wpawn || board[C2] == wpawn))
		b_score -= 50;
	if(board[H1] == bknight && (board[H2] == wpawn || board[G2] == wpawn))
		b_score -= 50;

	/*blocked center pawn*/
	if(board[D2] == wpawn && board[D3] != empty)
		w_score -= 20;
	if(board[E2] == wpawn && board[E3] != empty)
		w_score -= 20;
	if(board[D7] == bpawn && board[D6] != empty)
		b_score -= 20;
	if(board[E7] == bpawn && board[E6] != empty)
		b_score -= 20;

	/*development*/
	if(castle & WSLC_FLAG) {
		if(plist[wqueen] && !plist[wqueen]->next && rank(plist[wqueen]->sq) > RANK2) {
			w_score -= 20;
		}
		if(castle & WSC_FLAG) {
			if(board[F1] == empty && board[G1] == empty)
				w_score += 20;
		} else if(castle & WLC_FLAG) {
			if(board[B1] == empty && board[C1] == empty && board[D1] == empty)
				w_score += 10;
		}
	}

	if(castle & BSLC_FLAG) {
		if(plist[bqueen] && !plist[bqueen]->next && rank(plist[bqueen]->sq) < RANK7) {
			b_score -= 20;
		}
		if(castle & BSC_FLAG) {
			if(board[F8] == empty && board[G8] == empty) {
				b_score += 20;
			}
		} else if(castle & BLC_FLAG) {
			if(board[B8] == empty && board[C8] == empty && board[D8] == empty)
				b_score += 10;
		}
	}

	/*king pst*/
	if(man_c[bqueen] && piece_c[black] > 14) {
		w_score += king_pcsq_mid[w_ksq];
	} else if(end_game) {
		w_score += king_pcsq_end[w_ksq];
	}
	if(man_c[wqueen] && piece_c[white] > 14) {
		b_score += king_pcsq_mid[MIRRORR(b_ksq)];
	} else if(end_game) {
		b_score += king_pcsq_end[MIRRORR(b_ksq)];
	}
	
	/*adjust lazy score*/
	if(player == white) {
		pstack->lazy_score = (w_score - b_score);
		if(w_score > b_score) 
			pstack->lazy_score = (pstack->lazy_score * w_win_chance) / 8;
		else
            pstack->lazy_score = (pstack->lazy_score * b_win_chance) / 8;
	} else {
		pstack->lazy_score = (b_score - w_score);
		if(b_score > w_score) 
			pstack->lazy_score = (pstack->lazy_score * b_win_chance) / 8;
		else
            pstack->lazy_score = (pstack->lazy_score * w_win_chance) / 8;
	}

	/*return lazy score*/
	if(lazy == DO_LAZY) {
		lazy_evals++;
		pstack->evalrec.indicator |= AVOID_LAZY;

		int positional_delta = (pstack - 1)->lazy_score - (pstack - 1)->actual_score;
		pstack->actual_score = pstack->lazy_score + positional_delta;

		/*tempo*/
	    eval_tempo();
       
		return pstack->actual_score;
	}

    /*lazy eval*/
	if(lazy == TRY_LAZY) {
		if( !hstack[hply - 2].checks
			&& !hstack[hply - 1].checks
			&& !((pstack - 1)->evalrec.indicator & AVOID_LAZY)
			) {
			MOVE move;
			int positional_delta,LAZY_MARGIN;

			move = hstack[hply - 1].move;
			
			if(PIECE(m_capture(move)) == queen)
				LAZY_MARGIN = 300;
			else if(PIECE(m_capture(move)) == pawn
				&& ((opponent == white && rank(m_to(move)) == RANK2) ||
				(opponent == black && rank(m_to(move)) == RANK7)) )
				LAZY_MARGIN = 300;
			else if(PIECE(m_piece(move)) == pawn &&                        
				(rank(m_to(move)) == RANK7 || rank(m_to(move)) == RANK2))
				LAZY_MARGIN = 300;
			else
				LAZY_MARGIN = personality->lazy_margin;

			if(personality->lazy_margin > LAZY_MARGIN)
				LAZY_MARGIN = personality->lazy_margin;

			positional_delta = (pstack - 1)->lazy_score - (pstack - 1)->actual_score;
			pstack->actual_score = pstack->lazy_score + positional_delta;
			
			if(pstack->actual_score - LAZY_MARGIN > pstack->beta ||
				pstack->actual_score + LAZY_MARGIN < pstack->alpha) {

				lazy_evals++;
				pstack->evalrec.indicator |= AVOID_LAZY;
                
				/*tempo*/
	            eval_tempo();
				
				return pstack->actual_score;
			}
		}
	}
	/*
	Attack tables
	*/
#ifndef ARC_64BIT
// PG : alignment problem
//  BMP32* const PWB = (BMP32 *) WB;           
//   BMP32* const PBB = (BMP32 *) BB;
//  BMP32* plong;

//  PWB[0] = PWB[1] = PWB[4] = PWB[5] = PWB[8] = PWB[9] = PWB[12] = PWB[13] = PWB[16] = PWB[17] = PWB[20] = PWB[21] = PWB[24] = PWB[25] = PWB[28] = PWB[29] = 0; 
//  PBB[0] = PBB[1] = PBB[4] = PBB[5] = PBB[8] = PBB[9] = PBB[12] = PBB[13] = PBB[16] = PBB[17] = PBB[20] = PBB[21] = PBB[24] = PBB[25] = PBB[28] = PBB[29] = 0; 

for (int i = 0; i<120; i++) {
  WB[i] = BB [i] = 0;
}
//  plong = (BMP32*) wp_onf;
//  plong[0] = plong[1] = *((BMP16*) (&plong[2])) = 0;
//  plong = (BMP32*) bp_onf;
//  plong[0] = plong[1] = *((BMP16*) (&plong[2])) = 0;

for (int i = 0; i<10; i++) {
  wp_onf[i] = bp_onf[i] = 0;
}

#else
    BMP64* const PWB = (BMP64 *) WB;           
    BMP64* const PBB = (BMP64 *) BB;
	BMP64* plong;

	PWB[0] = PWB[2] = PWB[4] = PWB[6] = PWB[8] = PWB[10] = PWB[12] = PWB[14] = 0; 
	PBB[0] = PBB[2] = PBB[4] = PBB[6] = PBB[8] = PBB[10] = PBB[12] = PBB[14] = 0; 

	plong = (BMP64*) wp_onf;
	plong[0] = *((BMP16*) (&plong[1])) = 0;
	plong = (BMP64*) bp_onf;
	plong[0] = *((BMP16*) (&plong[1])) = 0;
#endif

	w_pawn_f = 0;
	b_pawn_f = 0;
	w_pawn_r = 0;
	b_pawn_r = 0;
	w_mobility = 0;
	b_mobility = 0;
	w_tropism = 0;
	b_tropism = 0;
	w_on7th = 0;
	b_on7th = 0;
	wr_onhopen = 0;
    br_onhopen = 0;
	
	/*pawns*/
	current = plist[wpawn];
	while(current) {
		c_sq = current->sq; 
		WB[c_sq + RU] += PAW_INC;
		WB[c_sq + LU] += PAW_INC;
		wf_pawns[file(c_sq)] |= mask[rank(c_sq)];
		w_pawn_f |= mask[file(c_sq)];
		w_pawn_r |= mask[rank(c_sq)];
        
		current = current->next;
	}
	current = plist[bpawn];
	while(current) {
		c_sq = current->sq; 
		BB[c_sq + RD] += PAW_INC;
		BB[c_sq + LD] += PAW_INC;
		bf_pawns[file(c_sq)] |= mask[rank(c_sq)];
		b_pawn_f |= mask[file(c_sq)];
		b_pawn_r |= mask[rank(c_sq)];
        
		current = current->next;
	}
	
	all_pawn_f = (w_pawn_f | b_pawn_f);

	w_score += eval_pawns();
	
	/*pieces*/
	current = plist[wknight];
	while(current) {
		c_sq = current->sq; 
		f = file(c_sq);
		r = rank(c_sq);

		mob = 0;
		smob = 0;
		WN_GEN_ATTACK(RRU);
		WN_GEN_ATTACK(LLD);
		WN_GEN_ATTACK(LLU);
		WN_GEN_ATTACK(RRD);
		WN_GEN_ATTACK(RUU);
		WN_GEN_ATTACK(LDD);
		WN_GEN_ATTACK(LUU);
		WN_GEN_ATTACK(RDD);
        
		/*mobility*/
		w_mobility += (2 * smob + mob);

		if(smob == 0)
			w_mobility -= W_TRAPPED_PIECE;
		else if(smob == 1)
			w_mobility -= (W_TRAPPED_PIECE >> 1);

		/*knight outpost*/
		if(temp = outpost[c_sq]) {
			w_score += temp;
			if(!(up_mask[r] & (bf_pawns[f - 1] | bf_pawns[f + 1]))) {
				w_score += temp;
				if(!(up_mask[r] & bf_pawns[f])) {
					if(board[c_sq + LD] == wpawn) w_score += temp;
					if(board[c_sq + RD] == wpawn) w_score += temp;
				} else {
					if(WB[c_sq] & PAW_BITS) w_score += temp;
				}
			}
		}

		/*knight tropism*/
		w_tropism += piece_tropism[distance(c_sq, b_ksq)];

		current = current->next;
	}

	current = plist[bknight];
	while(current) {
		c_sq = current->sq; 
		f = file(c_sq);
		r = rank(c_sq);

		mob = 0;
		smob = 0;
		BN_GEN_ATTACK(RRU);
		BN_GEN_ATTACK(LLD);
		BN_GEN_ATTACK(LLU);
		BN_GEN_ATTACK(RRD);
		BN_GEN_ATTACK(RUU);
		BN_GEN_ATTACK(LDD);
		BN_GEN_ATTACK(LUU);
		BN_GEN_ATTACK(RDD);

        /*mobility*/ 
		b_mobility += (2 * smob + mob);

		if(smob == 0)
			b_mobility -= B_TRAPPED_PIECE;
		else if(smob == 1)
		    b_mobility -= (B_TRAPPED_PIECE >> 1);

		/*knight outpost*/
		if(temp = outpost[MIRRORR(c_sq)]) {
			b_score += temp;
			if(!(down_mask[r] & (wf_pawns[f - 1] | wf_pawns[f + 1]))) {
				b_score += temp;
				if(!(down_mask[r] & wf_pawns[f])) {
					if(board[c_sq + LU] == bpawn) b_score += temp;
					if(board[c_sq + RU] == bpawn) b_score += temp;
				} else {
					if(BB[c_sq] & PAW_BITS) b_score += temp;
				}
			}
		}

		/*knight tropism*/
		b_tropism += piece_tropism[distance(c_sq, w_ksq)];

		current = current->next;
	}
	current = plist[wbishop];
	while(current) {
		c_sq = current->sq;
		f = file(c_sq);
		r = rank(c_sq);

		mob = 0;
		smob = 0;
		WB_GEN_ATTACK(RU);
		WB_GEN_ATTACK(LD);
		WB_GEN_ATTACK(LU);
		WB_GEN_ATTACK(RD);

		/*mobility*/
		w_mobility += (3 * smob + 2 * mob);

		if(smob == 0)
			w_mobility -= W_TRAPPED_PIECE;
		else if(smob == 1)
		    w_mobility -= (W_TRAPPED_PIECE >> 1);

		/*bishop outpost*/
		if(temp = (outpost[c_sq] / 2)) {
			w_score += temp;
			if(!(up_mask[r] & (bf_pawns[f - 1] | bf_pawns[f + 1]))) {
				w_score += temp;
				if(!(up_mask[r] & bf_pawns[f])) {
					if(board[c_sq + LD] == wpawn) w_score += temp;
					if(board[c_sq + RD] == wpawn) w_score += temp;
				} else {
					if(WB[c_sq] & PAW_BITS) w_score += temp;
				}
			}
		}

		/*bishop tropism*/
		w_tropism += piece_tropism[distance(c_sq, b_ksq)];

		current = current->next;
	}
	current = plist[bbishop];
	while(current) {
		c_sq = current->sq;
		f = file(c_sq);
		r = rank(c_sq);

		mob = 0;
		smob = 0;
		BB_GEN_ATTACK(RU);
		BB_GEN_ATTACK(LD);
		BB_GEN_ATTACK(LU);
		BB_GEN_ATTACK(RD);

		/*mobility*/
		b_mobility += (3 * smob + 2 * mob);

		if(smob == 0)
			b_mobility -= B_TRAPPED_PIECE;
		else if(smob == 1)
		    b_mobility -= (B_TRAPPED_PIECE >> 1);

		/*bishop outpost*/
		if(temp = (outpost[MIRRORR(c_sq)] / 2)) {
			b_score += temp;
			if(!(down_mask[r] & (wf_pawns[f - 1] | wf_pawns[f + 1]))) {
				b_score += temp;
				if(!(down_mask[r] & wf_pawns[f])) {
					if(board[c_sq + LU] == bpawn) b_score += temp;
					if(board[c_sq + RU] == bpawn) b_score += temp;
				} else {
					if(BB[c_sq] & PAW_BITS) b_score += temp;
				}
			}
		}

		/*bishop tropism*/
		b_tropism += piece_tropism[distance(c_sq, w_ksq)];

		current = current->next;
	}
	
    current = plist[wrook];
	while(current) {
		c_sq = current->sq;
		f = file(c_sq);
		r = rank(c_sq);

		mob = 0;
		smob = 0;
		WR_GEN_ATTACK(UU);
		WR_GEN_ATTACK(DD);
		WR_GEN_ATTACK(RR);
		WR_GEN_ATTACK(LL);

		/*mobility*/
		w_mobility += (2 * smob + mob);

		if(smob == 0)
			w_mobility -= W_TRAPPED_PIECE;
		else if(smob == 1)
		    w_mobility -= (W_TRAPPED_PIECE >> 1);

		/*rook on 7th*/
		if(r >= RANK7 && (rank(b_ksq) >= r || (b_pawn_r & mask[RANK7]))) {
			w_on7th += 2;
		} else if(end_game) {
			if(r == last_bit[b_pawn_r])
				w_score += 20;
		}

		/*sitting on open/half open file?*/
		if(!(mask[file(c_sq)] & all_pawn_f)) {
			wr_onhopen += 2;
			w_tropism += file_tropism[f_distance(c_sq, b_ksq)];
			w_tropism += piece_tropism[distance(c_sq, b_ksq)];
		} else if(!(mask[file(c_sq)] & w_pawn_f)) {
			wr_onhopen++;
			w_tropism += file_tropism[f_distance(c_sq, b_ksq)];
			w_tropism += piece_tropism[distance(c_sq, b_ksq)];
		} else {
			w_tropism += piece_tropism[distance(c_sq, b_ksq)];
		}

		/*support passed pawn*/
		if(pawnrec.w_passed & mask[f]) {
			if(r < last_bit[wf_pawns[f]])
				w_score += 20;
		}
		if(pawnrec.b_passed & mask[f]) {
			if(r > first_bit[bf_pawns[f]])
				w_score += 20;
		}
        
		current = current->next;
	}
	current = plist[brook];
	while(current) {
		c_sq = current->sq;
		f = file(c_sq);
		r = rank(c_sq);

		mob = 0;
		smob = 0;
		BR_GEN_ATTACK(UU);
		BR_GEN_ATTACK(DD);
		BR_GEN_ATTACK(RR);
		BR_GEN_ATTACK(LL);

		/*mobility*/
		b_mobility += (2 * smob + mob);

		if(smob == 0)
			b_mobility -= B_TRAPPED_PIECE;
		else if(smob == 1)
		    b_mobility -= (B_TRAPPED_PIECE >> 1);

		/*rook on 7th*/
		if(rank(c_sq) <= RANK2 && (rank(w_ksq) <= r || (w_pawn_r & mask[RANK2]))) {
			b_on7th += 2;
		} else if(end_game) {
			if(r == first_bit[w_pawn_r])
				b_score += 20;
		}

		/*sitting on open/half open file?*/
		if(!(mask[file(c_sq)] & all_pawn_f)) {
			br_onhopen += 2;
			b_tropism += piece_tropism[distance(c_sq, w_ksq)];
			b_tropism += file_tropism[f_distance(c_sq, w_ksq)];
		} else if(!(mask[file(c_sq)] & b_pawn_f)) {
			br_onhopen++;
			b_tropism += file_tropism[f_distance(c_sq, w_ksq)];
			b_tropism += piece_tropism[distance(c_sq, w_ksq)];
		} else {
			b_tropism += piece_tropism[distance(c_sq, w_ksq)];
		}

		/*support passed pawn*/
		if(pawnrec.b_passed & mask[f]) {
			if(r > first_bit[bf_pawns[f]])
				b_score += 20;
		}
		if(pawnrec.w_passed & mask[f]) {
			if(r < last_bit[wf_pawns[f]])
				b_score += 20;
		}

		current = current->next;
	}
	current = plist[wqueen];
	while(current) {
        c_sq = current->sq;
		f = file(c_sq);
		r = rank(c_sq);

		mob = 0;
		smob = 0;
		WQR_GEN_ATTACK(UU);
		WQR_GEN_ATTACK(DD);
		WQR_GEN_ATTACK(RR);
		WQR_GEN_ATTACK(LL);
		WQB_GEN_ATTACK(RU);
		WQB_GEN_ATTACK(LD);
		WQB_GEN_ATTACK(RD);
		WQB_GEN_ATTACK(LU);

		/*mobility*/
		w_mobility += (smob + mob / 2);

		if(smob == 0)
			w_mobility -= (W_TRAPPED_PIECE << 1);
		else if(smob == 1)
		    w_mobility -= (W_TRAPPED_PIECE);
		else if(smob == 2)
		    w_mobility -= (W_TRAPPED_PIECE >> 1);

		/*queen on 7th*/
		if(rank(c_sq) >= RANK7 && (rank(b_ksq) >= rank(c_sq) || (b_pawn_r & mask[RANK7])))
			w_on7th += 3;

		/*queen tropism*/
		w_tropism += piece_tropism[distance(c_sq, b_ksq)];

		current = current->next;
	}
	current = plist[bqueen];
	while(current) {
		c_sq = current->sq;
		f = file(c_sq);
		r = rank(c_sq);

		mob = 0;
		smob = 0;
		BQR_GEN_ATTACK(UU);
		BQR_GEN_ATTACK(DD);
		BQR_GEN_ATTACK(RR);
		BQR_GEN_ATTACK(LL);
		BQB_GEN_ATTACK(RU);
		BQB_GEN_ATTACK(LD);
		BQB_GEN_ATTACK(RD);
		BQB_GEN_ATTACK(LU);

		/*mobility*/
		if(smob == 0)
			b_mobility -= (B_TRAPPED_PIECE << 1);
		else if(smob == 1)
		    b_mobility -= (B_TRAPPED_PIECE);
        else if(smob == 2)
		    b_mobility -= (B_TRAPPED_PIECE >> 1);

		b_mobility += (smob + mob / 2);

		/*queen on 7th*/
		if(rank(c_sq) <= RANK2 && (rank(w_ksq) <= rank(c_sq) || (w_pawn_r & mask[RANK2])))
			b_on7th += 3;

        /*queen tropism*/
		b_tropism += piece_tropism[distance(c_sq, w_ksq)]; 

		current = current->next;
	}
	
	WB[w_ksq + RR] += KIN_INC;
	WB[w_ksq + LL] += KIN_INC;
	WB[w_ksq + UU] += KIN_INC;
	WB[w_ksq + DD] += KIN_INC;
	WB[w_ksq + RU] += KIN_INC;
	WB[w_ksq + LU] += KIN_INC;
	WB[w_ksq + RD] += KIN_INC;
	WB[w_ksq + LD] += KIN_INC;

	BB[b_ksq + RR] += KIN_INC;
	BB[b_ksq + LL] += KIN_INC;
	BB[b_ksq + UU] += KIN_INC;
	BB[b_ksq + DD] += KIN_INC;
	BB[b_ksq + RU] += KIN_INC;
	BB[b_ksq + LU] += KIN_INC;
	BB[b_ksq + RD] += KIN_INC;
	BB[b_ksq + LD] += KIN_INC;

	

	w_score += (personality->mobility_scale * w_mobility) / 100;
    b_score += (personality->mobility_scale * b_mobility) / 100;
	w_score += (personality->rook_on_7th_scale * qr_on_7thrank[w_on7th]) / 100;
    b_score += (personality->rook_on_7th_scale * qr_on_7thrank[b_on7th]) / 100;
	w_score += rook_on_hopen[wr_onhopen];
    b_score += rook_on_hopen[br_onhopen];

	/*eval passed pawns*/
	w_score += eval_passed_pawns();

	/*hung pieces*/
	int w_hung = 0,b_hung = 0;

#define EVAL_WHUNG(pic,bits) {\
    current = plist[pic];\
	while(current) {\
		c_sq = current->sq;\
		if((BB[c_sq] && !WB[c_sq]) || (BB[c_sq] & bits)) w_hung++;\
		current = current->next;\
	}\
};
#define EVAL_BHUNG(pic,bits) {\
    current = plist[pic];\
	while(current) {\
		c_sq = current->sq;\
		if((WB[c_sq] && !BB[c_sq]) || (WB[c_sq] & bits)) b_hung++;\
		current = current->next;\
	}\
};

    EVAL_WHUNG(wknight,PAW_BITS);
	EVAL_WHUNG(wbishop,PAW_BITS);
	EVAL_WHUNG(wrook,PM_BITS);
	EVAL_WHUNG(wqueen,PMR_BITS);
	EVAL_BHUNG(bknight,PAW_BITS);
	EVAL_BHUNG(bbishop,PAW_BITS);
	EVAL_BHUNG(brook,PM_BITS);
	EVAL_BHUNG(bqueen,PMR_BITS);

	pstack->evalrec.hung = b_hung;
	pstack->evalrec.hung = (pstack->evalrec.hung << 4) | w_hung;
	/*
	king safety
	*/
	if(man_c[bqueen] && piece_c[black] > 9) {
		
		attack = 0;
		attackers = 0;
		defence = 0;
		hopen = 0;
		slowattack = 0;
		f = file(w_ksq);
		r = rank(w_ksq);
		
		/*examine squares around king*/	
		B_ATTACK(RR);
		B_ATTACK(LL);
		B_ATTACK(UU);
		B_ATTACK(RU);
		B_ATTACK(LU);
		B_ATTACK(DD);
		B_ATTACK(RD);
		B_ATTACK(LD);

		B_ATTACK2(UUU);
		B_ATTACK2(RUU);
		B_ATTACK2(LUU);

		if(piece_c[black] > 14) {

            /*pawn cover*/
		    if(f < FILED) {
				if(board[C2] == wpawn) defence += 2;
				else if(board[C3] == wpawn) defence += 1;
				else if(board[C4] == wpawn) defence += 1;
				else hopen |= 1;
				
				if(board[B2] == wpawn) defence += 4;
				else if(board[B3] == wpawn) defence += 2;
				else if(board[B4] == wpawn) defence += 1;
				else hopen |= 2;
				
				if(board[A2] == wpawn) defence += 3;
				else if(board[A3] == wpawn) defence += 2;
				else if(board[A4] == wpawn) defence += 1;
				else hopen |= 4;
								
				if(board[B2] != wpawn) {
					//open line for diagonal attack
					if(board[C2] != wpawn)
						defence--;
					if(board[C3] != wpawn)
						defence -= 2;
					//piece attack
					if(COLOR(board[A3]) == black ||
                       COLOR(board[C3]) == black
						) {
						defence -= 2;
					}
					//bishop defence
					if(board[B2] == wbishop)
						defence++;
				}
			} else if(f > FILEE) {
				if(board[F2] == wpawn) defence += 2;
				else if(board[F3] == wpawn) defence += 1;
				else if(board[F4] == wpawn) defence += 1;
				else hopen |= 1;
				
				if(board[G2] == wpawn) defence += 4;
				else if(board[G3] == wpawn) defence += 2;
				else if(board[G4] == wpawn) defence += 1;
				else hopen |= 2;
				
				if(board[H2] == wpawn) defence += 3;
				else if(board[H3] == wpawn) defence += 2;
				else if(board[H4] == wpawn) defence += 1;
				else hopen |= 4;

				
				if(board[G2] != wpawn) {
					//open line for diagonal attack
					if(board[F2] != wpawn)
						defence--;
					if(board[F3] != wpawn)
						defence-=2;
					//piece attack
					if(COLOR(board[H3]) == black ||
                       COLOR(board[F3]) == black
						) {
						defence -= 2;
					}
					//bishop defence
					if(board[G2] == wbishop)
						defence++;
				}
			}
			slowattack -= (7 * defence); 

			/*pawn storm on white king*/
			if(abs(file(w_ksq) - file(b_ksq)) > 2)  {
				register int r1,r2,r3;
				if(((r1 = first_bit[bf_pawns[f]]) == 8) || (r1 <= r + 1)) r1 = RANK8;
				if(((r2 = first_bit[bf_pawns[f - 1]]) == 8) || (r2 <= r + 1)) r2 = RANK8;
				if(((r3 = first_bit[bf_pawns[f + 1]]) == 8) || (r3 <= r + 1)) r3 = RANK8;
				slowattack += (21 - (r1 + r2 + r3)) * 5;
			}

			/*open files around king*/
            if(!(all_pawn_f & mask[f])) slowattack += 20;
			if(f > FILEA && !(all_pawn_f & mask[f - 1])) slowattack += 10;
			if(f < FILEH && !(all_pawn_f & mask[f + 1])) slowattack += 10;
			
			/*penalize king sitting on half open files,and centre squares*/
			temp = king_on_file[f] +
				   king_on_rank[r] +
				   king_on_hopen[hopen];
			attack += temp;
		}
        
        if(attackers == QUE_BITS) {
			attack = (attack) / 2;
			b_tropism = (b_tropism) / 2;
		} else if(piece_c[black] <= 14) {
            attack = (attack) / 2;
			b_tropism = (b_tropism) / 2;
		} else if(!(attackers & RM_BITS)) {
			attack = (3 * attack) / 4;
			b_tropism = (3 * b_tropism) / 4;
		} else if(piece_c[black] <= 19) {
            attack = (4 * attack) / 5;
			b_tropism = (4 * b_tropism) / 5;
		}

		if(attack >= 9)
			pstack->evalrec.indicator |= BAD_WKING;

		b_score += (personality->king_safety_scale * king_attack[attack]) / 100;
		b_score += (personality->king_safety_scale * b_tropism) / 100;
		b_score += (personality->king_safety_scale * slowattack) / 100;
	}
    // 
	//for black
    //	
	if(man_c[wqueen] && piece_c[white] > 9) {
		
		attack = 0;
		attackers = 0;
		defence = 0;
		hopen = 0;
		slowattack = 0;
		f = file(b_ksq);
		r = rank(b_ksq);
		
		/*examine squares around king*/	
		W_ATTACK(RR);
		W_ATTACK(LL);
		W_ATTACK(DD);
		W_ATTACK(RD);
		W_ATTACK(LD);
		W_ATTACK(UU);
		W_ATTACK(RU);
		W_ATTACK(LU);

		W_ATTACK2(DDD);
		W_ATTACK2(RDD);
		W_ATTACK2(LDD);

  		if(piece_c[white] > 14) {

			/*pawn cover*/
			if(f < FILED) {
				if(board[C7] == bpawn) defence += 2;
				else if(board[C6] == bpawn) defence += 1;
				else if(board[C5] == bpawn) defence += 1;
				else hopen |= 1;
				
				if(board[B7] == bpawn) defence += 4;
				else if(board[B6] == bpawn) defence += 2;
				else if(board[B5] == bpawn) defence += 1;
				else hopen |= 2;
				
				if(board[A7] == bpawn) defence += 3;
				else if(board[A6] == bpawn) defence += 2;
				else if(board[A5] == bpawn) defence += 1;
				else hopen |= 4;
				
				if(board[B7] != bpawn) {
					//open line for diagonal attack
					if(board[C7] != bpawn)
						defence--;
					if(board[C6] != bpawn)
						defence-=2;
					//piece attack
					if(COLOR(board[A6]) == white ||
						COLOR(board[C6]) == white
						) {
						defence -= 2;
					}
					//bishop defence
					if(board[B7] == bbishop)
						defence++;
				}
				
			} else if(f > FILEE) {
				if(board[F7] == bpawn) defence += 2;
				else if(board[F6] == bpawn) defence += 1;
				else if(board[F5] == bpawn) defence += 1;
				else hopen |= 1;
				
				if(board[G7] == bpawn) defence += 4;
				else if(board[G6] == bpawn) defence += 2;
				else if(board[G5] == bpawn) defence += 1;
				else hopen |= 2;
				
				if(board[H7] == bpawn) defence += 3;
				else if(board[H6] == bpawn) defence += 2;
				else if(board[H5] == bpawn) defence += 1;
				else hopen |= 4;

				if(board[G7] != bpawn) {
					//open line for diagonal attack
					if(board[F7] != bpawn)
						defence--;
					if(board[F6] != bpawn)
						defence-=2;
					//pawn attack
					if(COLOR(board[H6]) == white ||
						COLOR(board[F6]) == white
						) {
						defence -= 2;
					}
					//bishop defence
					if(board[G7] == bbishop)
						defence++;
				}
			}
			slowattack -= (7 * defence);

			/*pawn storm on black king*/
			if(abs(file(w_ksq) - file(b_ksq)) > 2)  {
				register int r1,r2,r3;
				if(((r1 = last_bit[wf_pawns[f]]) == 8) || (r1 >= r - 1)) r1 = RANK1;
				if(((r2 = last_bit[wf_pawns[f - 1]]) == 8) || (r2 >= r - 1)) r2 = RANK1;
				if(((r3 = last_bit[wf_pawns[f + 1]]) == 8) || (r3 >= r - 1)) r3 = RANK1;
				slowattack += (r1 + r2 + r3) * 5;
			}

			/*open files around king*/
			if(!(all_pawn_f & mask[f])) slowattack += 20;
			if(f > FILEA && !(all_pawn_f & mask[f - 1])) slowattack += 10;
			if(f < FILEH && !(all_pawn_f & mask[f + 1])) slowattack += 10;
			
			/*penalize king sitting on half open files and centre squares*/
			temp = king_on_file[f] +
				   king_on_rank[RANK8 - r] +
				   king_on_hopen[hopen];
			attack += temp;
		}
        
        if(attackers == QUE_BITS) {
			attack = (attack) / 2;
			w_tropism = (w_tropism) / 2;
		} else if(piece_c[white] <= 14) {
            attack = (attack) / 2;
			w_tropism = (w_tropism) / 2;
        } else if(!(attackers & RM_BITS)) {
			attack = (3 * attack) / 4;
			w_tropism = (3 * w_tropism) / 4;
		} else if(piece_c[white] <= 19) {
            attack = (4 * attack) / 5;
			w_tropism = (4 * w_tropism) / 5;
		}

		if(attack >= 9)
			pstack->evalrec.indicator |= BAD_BKING;

		w_score += (personality->king_safety_scale * king_attack[attack]) / 100;
		w_score += (personality->king_safety_scale * w_tropism) / 100;
		w_score += (personality->king_safety_scale * slowattack) / 100;
	}
    
	full_evals++;

	/*save in hash table*/
	if(player == white) {
		pstack->actual_score = (w_score - b_score);
		if(w_score > b_score) {
			pstack->actual_score = (pstack->actual_score * w_win_chance) / 8;
		} else {
			pstack->actual_score = (pstack->actual_score * b_win_chance) / 8;
		}
	    record_eval_hash(hash_key,pstack->actual_score, pstack->lazy_score ,pstack->evalrec);
	} else {
		pstack->actual_score = (b_score - w_score);
		if(b_score > w_score) {
			pstack->actual_score = (pstack->actual_score * b_win_chance) / 8;
		} else {
			pstack->actual_score = (pstack->actual_score * w_win_chance) / 8;
		}
        record_eval_hash(hash_key,-pstack->actual_score,-pstack->lazy_score ,pstack->evalrec);
	}
	/*tempo*/
	eval_tempo();

	return pstack->actual_score;
}
/*
Evaluate tempo
*/
void SEARCHER::eval_tempo() {

	int w_hung = (pstack->evalrec.hung & 0x0f);
	int b_hung = ((pstack->evalrec.hung >> 4) & 0x0f);

	if(player == white) {
		if(piece_c[white] >= 3)
		    pstack->actual_score += TEMPO_BONUS;

		if(pstack->evalrec.indicator & BAD_BKING)
			pstack->actual_score += TEMPO_BONUS;

		if(w_hung == 2) pstack->actual_score -= FORK;
		else if(w_hung > 2) pstack->actual_score -= 2 * FORK;

	} else {

		if(piece_c[black] >= 3)
		    pstack->actual_score += TEMPO_BONUS;

		if(pstack->evalrec.indicator & BAD_WKING)
			pstack->actual_score += TEMPO_BONUS;

		if(b_hung == 2) pstack->actual_score -= FORK;
		else if(b_hung > 2) pstack->actual_score -= 2 * FORK;
	}
	
}
/*
pawn evaluation
*/
#define ROOKS_PAWN_PENALTY    15
#define DUO_PAWNS              2

static const int dobled_penalty[] = {
	0, 0, 0, 0, 0, 0, 0, 0,
		8, 8, 8,10,10, 8, 8, 8,
		8, 8, 8,10,10, 8, 8, 8,
		8, 8, 8,10,10, 8, 8, 8,
		8, 8, 8,10,10, 8, 8, 8,
		8, 8, 8,10,10, 8, 8, 8,
		8, 8, 8,10,10, 8, 8, 8,
		0, 0, 0, 0, 0, 0, 0, 0
};
static const int isolated_penalty[] = {
	0, 0, 0, 0, 0, 0, 0, 0,
		16,16,16,20,20,16,16,16,
		16,16,16,20,20,16,16,16,
		16,16,16,20,20,16,16,16,
		16,16,16,20,20,16,16,16,
		16,16,16,20,20,16,16,16,
		16,16,16,20,20,16,16,16,
		0, 0, 0, 0, 0, 0, 0, 0
};

static const int weak_penalty[] = {
	0, 0, 0, 0, 0, 0, 0, 0,
		10,10,12,16,16,12,10,10,
		10,10,12,16,16,12,10,10,
		10,10,12,16,16,12,10,10,
		10,10,12,16,16,12,10,10,
		10,10,12,16,16,12,10,10,
		10,10,12,16,16,12,10,10,
		0, 0, 0, 0, 0, 0, 0, 0
};
static const int passed_bonus[] = {
	0,  0,  0,  0,  0,  0,  0,  0,
		10, 10, 10, 10, 10, 10, 10, 10,
		18, 18, 18, 18, 18, 18, 18, 18,
		30, 30, 30, 30, 30, 30, 30, 30,
		60, 60, 60, 60, 60, 60, 60, 60,
		110,110,110,110,110,110,110,110,
		150,150,150,150,150,150,150,150,
		0,  0,  0,  0,  0,  0,  0,  0
};

int SEARCHER::eval_pawns() {

    register int w_score,b_score,sq,sq64,tsq,f,r;
	PLIST pawnl;
	
	w_score = 0;
	b_score = 0;
	pawnrec.w_passed = 0;
    pawnrec.b_passed = 0;
	/*
	pawn structure
	*/
	if(probe_pawn_hash(pawn_hash_key,w_score,pawnrec)) {
	} else {
		
		/*white*/
		pawnl = plist[wpawn];
		while(pawnl) {
			sq = pawnl->sq;
			f = file(sq);
			r = rank(sq);
			sq64 = SQ64(r,f);
			
			/*penalize rook_pawns*/
			if(f == FILEA || f == FILEH)
				w_score -= ROOKS_PAWN_PENALTY;

			/*doubled pawns*/
			if(updown_mask[r] & wf_pawns[f]) {
				w_score -= dobled_penalty[sq64];
			}

			/*duo/weak/isolated pawns*/
			if(WB[sq + UU]) {
				w_score += DUO_PAWNS;
			} else if(!(wf_pawns[f - 1] | wf_pawns[f + 1])) {
				w_score -= isolated_penalty[sq64];
			} else if(WB[sq] <= BB[sq]) { 

				bool is_weak = true;
				/*can it be supported by pushing a pawn from left?*/
				if(r >= RANK4
					&& board[sq + LDD] == wpawn
					&& PIECE(board[sq + LD]) != pawn
					&& WB[sq + LD] >= BB[sq + LD]) 
					   is_weak = false;
				/*...from right?*/
				else if(r >= RANK4
					&& board[sq + RDD] == wpawn
					&& PIECE(board[sq + RD]) != pawn
					&& WB[sq + RD] >= BB[sq + RD]) 
					   is_weak = false;
				/*can it advace and be supported?*/
				else if(PIECE(board[sq + UU]) != pawn
					&& (WB[sq + UU] > BB[sq + UU] ||
					    (WB[sq + UU] == BB[sq + UU] && WB[sq] < BB[sq])))
  				       is_weak = false;

				/*on open file?*/
				if(is_weak) {
					if(!(up_mask[r] & (bf_pawns[f] | wf_pawns[f])))
						w_score -= weak_penalty[sq64];
					else
						w_score -= weak_penalty[sq64] / 2;
                }
			}
			
			/*passed/candidate pawns*/
			if(!(up_mask[r] & bf_pawns[f-1]) &&
				!(up_mask[r] & bf_pawns[f]) &&
				!(up_mask[r] & bf_pawns[f+1])) {

				pawnrec.w_passed |= mask[f]; 
			} else if(!(up_mask[r] & (wf_pawns[f] | bf_pawns[f]))) {

				bool is_candidate = true;
				for(tsq = sq + UU;tsq < A8 + f;tsq += UU) {
					if(WB[tsq] < BB[tsq]) {
						is_candidate = false;
						break;
					}
				}
				if(is_candidate)
					w_score += (passed_bonus[sq64] / 2);
			}
			
			pawnl = pawnl->next;
		}

		/*black*/
		pawnl = plist[bpawn];
		while(pawnl) {
			sq = pawnl->sq;
			f = file(sq);
			r = rank(sq);
			sq64 = SQ64(7 - r,f);

			/*penalize rook_pawns*/
			if(f == FILEA || f == FILEH)
				b_score -= ROOKS_PAWN_PENALTY;

			/*doubled pawns*/
			if(updown_mask[r] & bf_pawns[f]) {
				b_score -= dobled_penalty[sq64];
			}
			/*duo/weak/isolated pawns*/
			if(BB[sq + DD]) {
				b_score += DUO_PAWNS;
			} else if(!(bf_pawns[f-1] | bf_pawns[f+1])) {
				b_score -= isolated_penalty[sq64];
			} else if(BB[sq] <= WB[sq]) {

				bool is_weak = true;
				/*can it be supported by pushing a pawn from left?*/
				if(r <= RANK5
				   && board[sq + LUU] == bpawn
				   && PIECE(board[sq + LU]) != pawn
				   && BB[sq + LU] >= WB[sq + LU])  
					is_weak = false;
				/*...from right?*/
				else if(r <= RANK5
				   && board[sq + RUU] == bpawn
				   && PIECE(board[sq + RU]) != pawn
				   && BB[sq + RU] >= WB[sq + RU])  
					is_weak = false;
				/*can it advace and be supported?*/
				else if(PIECE(board[sq + DD]) != pawn
					&& (BB[sq + DD] > WB[sq + DD] ||
					    (BB[sq + DD] == WB[sq + DD] && BB[sq] < WB[sq])))
					is_weak = false;

				/*on open file?*/
				if(is_weak) {
					if(!(down_mask[r] & (bf_pawns[f] | wf_pawns[f])))
						b_score -= weak_penalty[sq64];
					else
						b_score -= weak_penalty[sq64] / 2;
				}
			}
            
			/*passed/candidate pawns*/
			if(!(down_mask[r] & wf_pawns[f-1]) &&
				!(down_mask[r] & wf_pawns[f]) &&
				!(down_mask[r] & wf_pawns[f+1])) {

				pawnrec.b_passed |= mask[f];
			} else if(!(down_mask[r] & (wf_pawns[f] | bf_pawns[f]))) {

				bool is_candidate = true;
				for(tsq = sq + DD;tsq > A1 + f;tsq += DD) {
					if(BB[tsq] < WB[tsq]) {
						is_candidate = false;
						break;
					}
				}
				if(is_candidate) 
					b_score += (passed_bonus[sq64] / 2);
			}
			
			pawnl = pawnl->next;
		}

        /*store in hash table*/
		record_pawn_hash(pawn_hash_key,w_score - b_score,pawnrec);
	}

	w_score = (w_score * personality->pawn_structure_scale) / 100;
    b_score = (b_score * personality->pawn_structure_scale) / 100;

	return (w_score - b_score);
}

int SEARCHER::eval_passed_pawns() {
	register UBMP8 passed;
    register int sq,f,r;
	int w_score,b_score,passed_score,rank_score;
	int qdist,w_best_qdist = RANK8,b_best_qdist = RANK8;
	int w_ksq = plist[wking]->sq;
    int b_ksq = plist[bking]->sq;

	w_score = 0;
	b_score = 0;

	passed = pawnrec.w_passed;
	while(passed) {
		f = first_bit[passed];
		r = last_bit[wf_pawns[f]];
		sq = SQ(r,f);

		passed_score = rank_score = passed_bonus[SQ64(r,f)];

		/*Support/Attack*/
		if(WB[sq + UU] & PAW_BITS)
			passed_score += rank_score;

		if(board[sq + UU] != empty)
			passed_score -= rank_score / 2;
		else if(WB[sq + UU] < BB[sq + UU])
            passed_score -= rank_score / 4;

		if(WB[sq] & PAW_BITS)
			passed_score += rank_score / 4;
		else if(WB[sq] < BB[sq])
			passed_score -= rank_score / 6;
        
		if(piece_c[black] < 9) {
			passed_score += (rank_score * f_distance(b_ksq,sq)) / 8;
		    passed_score += (rank_score * (9 - distance(w_ksq,sq))) / 12;
		} else {
			passed_score += (rank_score * f_distance(b_ksq,sq)) / 12;
            passed_score += (rank_score * (9 - distance(w_ksq,sq))) / 16;
		}
		
		/*opponent has no pieces*/
        if(piece_c[black] == 0) {
		    qdist = RANK8 - r;
            if(player == black) qdist++;
			for(int tsq = sq + UU;tsq <= A8 + f;tsq += UU) {
				if(board[tsq] != empty) qdist++;
			}
			if(r == RANK2 && board[sq + UU] == empty && board[sq + UUU] == empty) 
				qdist--;
			if(qdist < distance(b_ksq,A8 + f)) {
				w_best_qdist = min(qdist,w_best_qdist);
			}
			pstack->evalrec.indicator |= AVOID_LAZY;
		}

		w_score += (passed_score * personality->passed_pawn_scale) / 100;

		passed ^= mask[f];
	}
	passed = pawnrec.b_passed;
	while(passed) {
        f = first_bit[passed];
		r = first_bit[bf_pawns[f]];
		sq = SQ(r,f);

        passed_score = rank_score = passed_bonus[SQ64(7 - r,f)];

		/*Support/Attack*/
		if(BB[sq + DD] & PAW_BITS)
			passed_score += rank_score;
		
		if(board[sq + DD] != empty)
			passed_score -= rank_score / 2;
		else if(BB[sq + DD] < WB[sq + DD])
            passed_score -= rank_score / 4;

		if(BB[sq] & PAW_BITS)
			passed_score += rank_score / 4;
		else if(BB[sq] < WB[sq])
			passed_score -= rank_score / 6;
        
		if(piece_c[white] < 9) {
			passed_score += (rank_score * f_distance(w_ksq,sq)) / 8;
		    passed_score += (rank_score * (9 - distance(b_ksq,sq))) / 12;
		} else {
			passed_score += (rank_score * f_distance(w_ksq,sq)) / 12;
            passed_score += (rank_score * (9 - distance(b_ksq,sq))) / 16;
		}
			
		/*opponent has no pieces*/
        if(piece_c[white] == 0) {
		    qdist = r;
            if(player == white) qdist++;
			for(int tsq = sq + DD;tsq >= A1 + f;tsq += DD) {
				if(board[tsq] != empty) qdist++;
			}
			if(r == RANK7 && board[sq + DD] == empty && board[sq + DDD] == empty) 
				qdist--;
			if(qdist < distance(w_ksq,A1 + f)) {
				b_best_qdist = min(qdist,b_best_qdist);
			}
			pstack->evalrec.indicator |= AVOID_LAZY;
		}
		
	 	b_score += (passed_score * personality->passed_pawn_scale) / 100;

		passed ^= mask[f];
    }

    /*unstoppable passer*/
	if(w_best_qdist < b_best_qdist) {
		w_score += 600;
	} else if(b_best_qdist < w_best_qdist) {
		b_score += 600;
	}

	/*pawn endgames: try to avoid going in to lost pawn endgames*/
	if(!piece_c[white] && !piece_c[black]) {
		/* I - pseudo majority*/
		if(pawn_c[white] > pawn_c[black])
			w_score += 100;
		else if(pawn_c[black] > pawn_c[white])
			b_score += 100;
	}
	if(!piece_c[white] || !piece_c[black]) {
		/* II - king close to pawn center*/
		int wclos = (7 - abs(center_bit[all_pawn_f] - file(w_ksq)));
		int bclos = (7 - abs(center_bit[all_pawn_f] - file(b_ksq)));

		if(wclos > bclos) w_score += king_to_pawns[wclos - bclos];
		else b_score += king_to_pawns[bclos - wclos];
		
	}

	return (w_score - b_score);
}
/*
piece square tables
*/
static int  pawn_pcsq[0x80] = { 
	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,
		1,	2,	3,	-5,	-5,	3,	2,	1,	0,	0,	0,	0,	0,	0,	0,	0,
		3,	5,	8,  12, 12, 8,	5,	3,	0,	0,	0,	0,	0,	0,	0,	0,
		5,	8,	13,	26,	26,	13,	8,	5,	0,	0,	0,	0,	0,	0,	0,	0,
		7,	11,	18,	30,	30,	18,	11,	7,	0,	0,	0,	0,	0,	0,	0,	0,
		9,	14,	23,	34,	34,	23,	14,	9,	0,	0,	0,	0,	0,	0,	0,	0,
		9,	14,	23,	34,	34,	23,	14,	9,	0,	0,	0,	0,	0,	0,	0,	0,
		0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0,	0 
};
static int  knight_pcsq[0x80] = { 
	-20, -20, -20, -20, -20, -20, -20, -20,  0,  0,  0,  0,  0,  0,  0,  0,  
		-10, -5, -5, -5, -5, -5, -5, -10,  0,  0,  0,  0,  0,  0,  0,  0,
		-10, -5,  0,  0,  0,  0, -5, -10,  0,  0,  0,  0,  0,  0,  0,  0,
		-10, -5,  0,  5,  5,  0, -5, -10,  0,  0,  0,  0,  0,  0,  0,  0,
		-15, -5,  0,  5,  5,  0, -5, -15,  0,  0,  0,  0,  0,  0,  0,  0,
		-15, -5,  0,  0,  0,  0, -5, -15,  0,  0,  0,  0,  0,  0,  0,  0,
		-20, -10, -10, -10, -10, -10, -10, -20,  0,  0,  0,  0,  0,  0,  0,  0,
		-30, -20, -20, -20, -20, -20, -20, -30,  0,  0,  0,  0,  0,  0,  0,  0
};
static int  bishop_pcsq[0x80] = {
	-20, -20, -20, -20, -20, -20, -20, -20,  0,  0,  0,  0,  0,  0,  0,  0,  
		-10, -5, -5, -5, -5, -5, -5, -10,  0,  0,  0,  0,  0,  0,  0,  0,
		-10, -5,  0,  0,  0,  0, -5, -10,  0,  0,  0,  0,  0,  0,  0,  0,
		-10, -5,  0,  5,  5,  0, -5, -10,  0,  0,  0,  0,  0,  0,  0,  0,
		-15, -5,  0,  5,  5,  0, -5, -15,  0,  0,  0,  0,  0,  0,  0,  0,
		-20, -5,  0,  0,  0,  0, -5, -20,  0,  0,  0,  0,  0,  0,  0,  0,
		-20, -10, -10, -10, -10, -10, -10, -20,  0,  0,  0,  0,  0,  0,  0,  0,
		-20, -20, -20, -20, -20, -20, -20, -20,  0,  0,  0,  0,  0,  0,  0,  0
};
static int  rook_pcsq[0x80] = { 
	-6,  -3,  0,  3,  3,  0,  -3, -6,  0,  0,  0,  0,  0,  0,  0,  0,  
		-6,  -3,  0,  3,  3,  0,  -3, -6,  0,  0,  0,  0,  0,  0,  0,  0,  
		-6,  -3,  0,  3,  3,  0,  -3, -6,  0,  0,  0,  0,  0,  0,  0,  0,  
		-6,  -3,  0,  3,  3,  0,  -3, -6,  0,  0,  0,  0,  0,  0,  0,  0,  
		-6,  -3,  0,  3,  3,  0,  -3, -6,  0,  0,  0,  0,  0,  0,  0,  0,  
		-6,  -3,  0,  3,  3,  0,  -3, -6,  0,  0,  0,  0,  0,  0,  0,  0,  
		-6,  -3,  0,  3,  3,  0,  -3, -6,  0,  0,  0,  0,  0,  0,  0,  0,  
		-6,  -3,  0,  3,  3,  0,  -3, -6,  0,  0,  0,  0,  0,  0,  0,  0
};
static int  queen_pcsq[0x80] = {
	-5, -5, -5, -5, -5, -5, -5, -5,  0,  0,  0,  0,  0,  0,  0,  0,  
		 -5,  0,  0,  0,  0,  0,  0,  -5,  0,  0,  0,  0,  0,  0,  0,  0,
		 -5,  0,  4,  4,  4,  4,  0,  -5,  0,  0,  0,  0,  0,  0,  0,  0,
		 -5,  0,  4,  5,  5,  4,  0,  -5,  0,  0,  0,  0,  0,  0,  0,  0,
		-10,  0,  4,  5,  5,  4,  0, -10,  0,  0,  0,  0,  0,  0,  0,  0,
		-20,  0,  4,  4,  4,  4,  0, -20,  0,  0,  0,  0,  0,  0,  0,  0,
		-20, -5, -5, -5, -5, -5, -5, -20,  0,  0,  0,  0,  0,  0,  0,  0,
		-20, -20, -10, -10, -10, -10, -20, -20,  0,  0,  0,  0,  0,  0,  0,  0
};

static const int piece_v[15] = {0,0,975,500,325,325,100,0,975,500,325,325,100,0};

void SEARCHER::pre_calculate() {
	int pic,sq;
	for(pic = wking; pic <= bpawn; pic++) {
		for(sq = A1; sq <= H8; sq++) {
			pcsq[pic][sq] = piece_v[pic];
		}
	}
	for(sq = A1; sq <= H8; sq++) {
		pcsq[wknight][sq] += knight_pcsq[sq];
		pcsq[bknight][sq] += knight_pcsq[MIRRORR(sq)];
		pcsq[wbishop][sq] += bishop_pcsq[sq];
		pcsq[bbishop][sq] += bishop_pcsq[MIRRORR(sq)];
		pcsq[wrook][sq] += rook_pcsq[sq];
		pcsq[brook][sq] += rook_pcsq[MIRRORR(sq)];
		pcsq[wqueen][sq] += queen_pcsq[sq];
		pcsq[bqueen][sq] += queen_pcsq[MIRRORR(sq)];
		pcsq[wpawn][sq] += pawn_pcsq[sq];
		pcsq[bpawn][sq] += pawn_pcsq[MIRRORR(sq)];
	}
}

int SEARCHER::eval_win_chance(int& score,int& lazy_score,int& w_win_chance,int& b_win_chance) {

	register int w_score,b_score;
	int w_ksq = plist[wking]->sq;
    int b_ksq = plist[bking]->sq;
	int w_pawn_c = man_c[wpawn];
	int b_pawn_c = man_c[bpawn];
	int w_knight_c = man_c[wknight];
	int b_knight_c = man_c[bknight];
	int w_bishop_c = man_c[wbishop];
	int b_bishop_c = man_c[bbishop];
	int w_rook_c = man_c[wrook];
	int b_rook_c = man_c[brook];
	int w_queen_c = man_c[wqueen];
	int b_queen_c = man_c[bqueen];
	int w_majors = w_rook_c + 2 * w_queen_c;
	int b_majors = b_rook_c + 2 * b_queen_c;
    int w_minors = w_knight_c + w_bishop_c;
	int b_minors = b_knight_c + b_bishop_c;
	int w_piece_c = w_minors + w_majors;
	int b_piece_c = b_minors + b_majors;
	int w_piece_value_c = piece_c[white];
    int b_piece_value_c = piece_c[black];
	int all_piece_value_c = piece_c[white] + piece_c[black];
	int temp,temp1;

	//material
	if(piece_c[white] + piece_c[black] <= 28) {
		personality = &phase_personality[2];
	} else if(castle)
        personality = &phase_personality[0];
	else
        personality = &phase_personality[1];
	
	w_score = pcsq_score[white];
	b_score = pcsq_score[black];

	//KBK,KNK,KNNK
	if(w_pawn_c == 0) {
		if(w_piece_value_c <= 3 || (w_piece_value_c == 6 && w_knight_c == 2)) {
			w_win_chance = 0;
		}
	}
	if(b_pawn_c == 0) {
		if(b_piece_value_c <= 3 || (b_piece_value_c == 6 && b_knight_c == 2)) {
			b_win_chance = 0;
		}
	}
	
	//KBP*K draw also K(rook's P)*K draw
	if(w_piece_value_c == 0 || (w_piece_value_c == 3 && w_bishop_c == 1)) { 
		int psq = A1,pfile = 0,bsq = (w_piece_value_c == 0) ? A1 : plist[wbishop]->sq,ksq = plist[bking]->sq;
		PLIST current = plist[wpawn];
		while(current) {
			if(current->sq > psq)
				psq = current->sq;
			pfile |= mask[file(current->sq)];
			if(pfile != mask[FILEA] && pfile != mask[FILEH])
				break;
			current = current->next;
		}
		
		if(pfile == mask[FILEA]
			&& (w_piece_value_c == 0 || !is_light(bsq))) {
			if(distance(ksq,A8) <= 1 ||
				(rank(psq) < rank(ksq) && file(ksq) == FILEB)) {
				bool is_draw = true;
				for(int sq = psq + RR;sq < B8;sq += UU) {
					if(board[sq] == bpawn) {
						is_draw = false;
						break;
					}
				}
				if(is_draw) w_win_chance = 0;
			}
		} else if(pfile == mask[FILEH] 
			&& (w_piece_value_c == 0 || is_light(bsq))) {
			if(distance(ksq,H8) <= 1 ||
				(rank(psq) < rank(ksq) && file(ksq) == FILEG)) {
				bool is_draw = true;
				for(int sq = psq + LL;sq < G8;sq += UU) {
					if(board[sq] == bpawn) {
						is_draw = false;
						break;
					}
				}
				if(is_draw) w_win_chance = 0;
			}
		}
	}
	
	if(b_piece_value_c == 0 || (b_piece_value_c == 3 && b_bishop_c == 1)) { 
		int psq = H8,pfile = 0,bsq = (b_piece_value_c == 0) ? A1 : plist[bbishop]->sq,ksq = plist[wking]->sq;
		PLIST current = plist[bpawn];
		while(current) {
			if(current->sq < psq)
				psq = current->sq;
			pfile |= mask[file(current->sq)];
			if(pfile != mask[FILEA] && pfile != mask[FILEH])
				break;
			current = current->next;
		}
		
		if(pfile == mask[FILEA] 
			&& (b_piece_value_c == 0 || is_light(bsq))) {
			if(distance(ksq,A1) <= 1 ||
				(rank(psq) > rank(ksq) && file(ksq) == FILEB)) {
				bool is_draw = true;
				for(int sq = psq + RR;sq > B1;sq += DD) {
					if(board[sq] == wpawn) {
						is_draw = false;
						break;
					}
				}
				if(is_draw) b_win_chance = 0;
			}
		} else if(pfile == mask[FILEH] 
			&& (b_piece_value_c == 0 || !is_light(bsq))) {
			if(distance(ksq,H1) <= 1 ||
				(rank(psq) > rank(ksq) && file(ksq) == FILEG)) {
				bool is_draw = true;
				for(int sq = psq + RR;sq > B1;sq += DD) {
					if(board[sq] == wpawn) {
						is_draw = false;
						break;
					}
				}
				if(is_draw) b_win_chance = 0;
			}
		}
	}
	
    //no pawns
	if(!w_pawn_c
		&& w_piece_value_c <= 13 
		&& w_piece_value_c >= b_piece_value_c 
		&& w_piece_value_c - b_piece_value_c <= 3
		) {
		if(w_piece_value_c == 6 && w_bishop_c == 2 && b_knight_c == 1)
			w_win_chance /= 2;
		else
		    w_win_chance /= 8;
	}
	if(!b_pawn_c
		&& b_piece_value_c <= 13
		&& b_piece_value_c >= w_piece_value_c
		&& b_piece_value_c - w_piece_value_c <= 3
		) {
		if(b_piece_value_c == 6 && b_bishop_c == 2 && w_knight_c == 1)
			b_win_chance /= 2;
		else
		    b_win_chance /= 8;
	}
	
	//one pawn
	if(w_pawn_c == 1
		&& w_piece_value_c <= 13 
		&& w_piece_value_c <= b_piece_value_c
		) {
		if(w_piece_value_c == 3) {
			w_win_chance /= 8;
		} else if(w_piece_value_c == 6 && w_knight_c == 2) {
			w_win_chance /= 8;
		} else if(b_piece_value_c - w_piece_value_c >= 3) {
			w_win_chance /= 8;
		} else {
			w_win_chance /= 4;
		}
	}
	if(b_pawn_c == 1
		&& b_piece_value_c <= 13 
		&& b_piece_value_c <= w_piece_value_c
		) {
		if(b_piece_value_c == 3) {
			b_win_chance /= 8;
		} else if(b_piece_value_c == 6 && b_knight_c == 2) {
			b_win_chance /= 8;
		} else if(w_piece_value_c - b_piece_value_c >= 3) {
			b_win_chance /= 8;
		} else {
			b_win_chance /= 4;
		}
	}
	
	//opposite colored bishop endings
	if(w_piece_value_c + b_piece_value_c <= 16
		&& w_piece_value_c == b_piece_value_c
		&& w_bishop_c == 1 
		&& b_bishop_c == 1 
		&& is_light(plist[wbishop]->sq) != is_light(plist[bbishop]->sq)
		&& abs(w_pawn_c - b_pawn_c) <= 2
		) {
		if(w_piece_value_c + b_piece_value_c == 6) {
			if(w_pawn_c >= b_pawn_c)
				w_win_chance /= 2;
			if(b_pawn_c >= w_pawn_c)
				b_win_chance /= 2;
		} else {
			if(w_pawn_c >= b_pawn_c)
				w_win_chance = (3 * w_win_chance) / 4;
			if(b_pawn_c >= w_pawn_c)
				b_win_chance = (3 * b_win_chance) / 4; 
		}
	}
	
	//mating lone king
	if(b_piece_c + b_pawn_c == 0 && w_piece_value_c >= 5) {
		score = w_score - b_score + 500 - 10 * distance(w_ksq,b_ksq); 
		if(w_piece_value_c == 6 && w_pawn_c == 0) {
			temp = w_bishop_c;
			if(temp == 2) {//KBBK
				score -= king_pcsq_end[MIRRORR(b_ksq)];
			} else if(temp == 1) {//KBNK
				temp = b_ksq;
				if(is_light(plist[wbishop]->sq)) {
					score -= kbnk_pcsq[temp];
				} else {
					temp = MIRRORF(temp);
                    score -= kbnk_pcsq[temp];
				}
			} else {//KNNK
				score = 0;
			}
		} else {
			score -= king_pcsq_end[MIRRORR(b_ksq)]; 
		}
		lazy_score = score;
		return true;
	}
	if(w_piece_c + w_pawn_c == 0 && b_piece_value_c >= 5) {
		score = b_score - w_score + 500 - 10 * distance(w_ksq,b_ksq); 
		if(b_piece_value_c == 6 && b_pawn_c == 0) {
			temp = b_bishop_c;
			if(temp == 2) {//KBBK
				score -= king_pcsq_end[w_ksq];
			} else if(temp == 1) {//kBNK
				temp = w_ksq;
				if(is_light(plist[bbishop]->sq)) {
					score -= kbnk_pcsq[temp];
				} else {
					temp = MIRRORF(temp);
                    score -= kbnk_pcsq[temp];
				}
			} else {//KNNK
				score = 0;
			}
		} else {
			score -= king_pcsq_end[w_ksq]; 
		}
		score = -score;
		lazy_score = score;
		return true;
	}
	
	//pieces vs pawns
	int EXCHANGE_BONUS = (75 * personality->exchange_scale) / 100;
	
	temp = w_piece_value_c - b_piece_value_c;
	temp1 = w_minors - b_minors;

	if(temp >= 5) w_score += (4 * EXCHANGE_BONUS);                       //[R,Q] vs Ps
	else if(temp <= -5) b_score += (4 * EXCHANGE_BONUS);
	else if(temp >= 3) w_score += (2 * EXCHANGE_BONUS);                  //M vs 3P
	else if(temp <= -3) b_score += (2 * EXCHANGE_BONUS);
	else if(temp1 >= 3) w_score += (3 * EXCHANGE_BONUS) / 2;             //3M vs (2R or Q)
	else if(temp1 <= -3) b_score += (3 * EXCHANGE_BONUS) / 2;
	else if(temp1 == 2) w_score += (3 * EXCHANGE_BONUS) / 2;             //2M vs R
	else if(temp1 == -2) b_score += (3 * EXCHANGE_BONUS) / 2;
	else if(temp == 2) w_score += EXCHANGE_BONUS;                        //R vs M
	else if(temp == -2) b_score += EXCHANGE_BONUS;
    
	if(w_queen_c && !b_queen_c) w_score += (3 * EXCHANGE_BONUS) / 2;     //Q
	else if(b_queen_c && !w_queen_c) b_score += (3 * EXCHANGE_BONUS) / 2;

	//bishop pair
	int BISHOP_PAIR = personality->bishop_pair_scale;
	
	if(w_bishop_c >= 2) {
		if(b_bishop_c + b_knight_c == 0)
			temp = 80;
		else
			temp = 50;
		w_score += (temp * BISHOP_PAIR) / 100;
	}
	if(b_bishop_c >= 2) {
		if(w_bishop_c + w_knight_c == 0)
			temp = 80;
		else
			temp = 50;
		b_score += (temp * BISHOP_PAIR) / 100;
	}

	score = w_score - b_score;
	lazy_score = score;
	return false;
}
