#ifndef BITBOARDS_H
#define BITBOARDS_H

typedef unsigned char U8;
typedef unsigned short U16;
typedef unsigned int U32;

#ifdef _MSC_VER
	typedef unsigned __int64  U64;
	#define LL(x) x##L
#else
	typedef unsigned long long U64;
	#define LL(x) x##LL
#endif


void init_bitboards();
void print_bitboard(U64 b);

extern int g_dist[64][64];

extern U64 BB_SINGLE[64];
extern U64 BB_SINGLE_ZERO[64];

extern U64 BB_PAWNW_ATTACKS[64];
extern U64 BB_PAWNB_ATTACKS[64];
extern U64 BB_KNIGHT_ATTACKS[64];
extern U64 BB_BISHOP_ATTACKS[64];
extern U64 BB_ROOK_ATTACKS[64];
extern U64 BB_QUEEN_ATTACKS[64];
extern U64 BB_KING_ATTACKS[64];

extern U64 BB_BETWEEN[64][64];
extern U64 BB_UPPER[64];
extern U64 BB_LOWER[64];

extern U64 BB_PAWNW_SQUARE[64];
extern U64 BB_PAWNB_SQUARE[64];

extern U64 BB_VERTICAL[8];

#define BB_ALL  (LL(0xffffffffffffffff))
#define BB_A7H7 (LL(0x00ff000000000000))
#define BB_A6H6 (LL(0x0000ff0000000000))
#define BB_A3H3 (LL(0x0000000000ff0000))
#define BB_A2H2 (LL(0x000000000000ff00))

#define BB_CENTER_W (LL(0x00003c3c3c000000))
#define BB_CENTER_B (LL(0x0000003c3c3c0000))
#define BB_WEDGE_W  (LL(0x00183c7e3c000000))
#define BB_WEDGE_B  (LL(0x0000003c7e3c1800))

#define bb_up(x)        ((x) << 8)
#define bb_down(x)      ((x) >> 8)
#define bb_right(x)     (((x) & LL(0xfefefefefefefefe)) >> 1)
#define bb_left(x)      (((x) & LL(0x7f7f7f7f7f7f7f7f)) << 1)
#define set_bit(x, n)   (x) |= BB_SINGLE[n]
#define clear_bit(x, n) (x) &= BB_SINGLE_ZERO[n]

typedef U8 FLD;
enum FLD_TAG
{
	A8 =  0, B8 =  1, C8 =  2, D8 =  3, E8 =  4, F8 =  5, G8 =  6, H8 =  7,
	A7 =  8, B7 =  9, C7 = 10, D7 = 11, E7 = 12, F7 = 13, G7 = 14, H7 = 15,
	A6 = 16, B6 = 17, C6 = 18, D6 = 19, E6 = 20, F6 = 21, G6 = 22, H6 = 23,
	A5 = 24, B5 = 25, C5 = 26, D5 = 27, E5 = 28, F5 = 29, G5 = 30, H5 = 31,
	A4 = 32, B4 = 33, C4 = 34, D4 = 35, E4 = 36, F4 = 37, G4 = 38, H4 = 39,
	A3 = 40, B3 = 41, C3 = 42, D3 = 43, E3 = 44, F3 = 45, G3 = 46, H3 = 47,
	A2 = 48, B2 = 49, C2 = 50, D2 = 51, E2 = 52, F2 = 53, G2 = 54, H2 = 55,
	A1 = 56, B1 = 57, C1 = 58, D1 = 59, E1 = 60, F1 = 61, G1 = 62, H1 = 63,
	NF = 64
};

static const FLD LSB_Magic[64] = 
{
	A8, B4, E1, H5, E8, B2, E2, G5,
	D8, H4, F7, G2, A7, E3, C3, F5,
	C8, C4, F1, C7, E7, A3, G6, F3,
	H8, D4, G1, E6, B6, E4, H1, E5,
	B8, A4, F8, D1, C1, G7, B7, B1,
	A2, D7, D2, H6, A1, F6, C6, H3,
	G4, G8, H7, C2, F2, A5, H2, D6,
	D3, A6, B5, B3, G3, C5, D5, F4
};

static const U64 mask_1 = LL(0xAAAAAAAAAAAAAAAA);
static const U64 mask_2 = LL(0xCCCCCCCCCCCCCCCC);
static const U64 mask_4 = LL(0xF0F0F0F0F0F0F0F0);
static const U64 mask_8 = LL(0xFF00FF00FF00FF00);
static const U64 mask_16 = LL(0xFFFF0000FFFF0000);
static const U64 mask_32 = LL(0xFFFFFFFF00000000);

#define count_bits(x) count_bits_inner(&x)
static inline unsigned int count_bits_inner(U64* pb) 
{
	if (*pb == 0)
		return 0;

	U64 x = (( *pb & mask_1 ) >> 1 ) + ( *pb & (mask_1 >> 1) );
	x = (( x & mask_2 ) >> 2 ) + ( x & (mask_2 >> 2) );

	int y = (int) ((( x & mask_32 ) >> 32 ) + x );
	y = (( y & 0xF0F0F0F0 ) >> 4 ) + ( y & (0xF0F0F0F0 >> 4) );

	y += ( y & 0xFF00FF00 ) >> 8;
	y += ( y & 0xFFFF0000 ) >> 16;

	return ( y & 0xFF );
}
////////////////////////////////////////////////////////////////////////////////

#define pop_lsb(x)  pop_lsb_inner(&x)
static inline FLD pop_lsb_inner(U64* pb)
{
	if (*pb == 0)
		return NF;

	U64 lsb = *pb ^ (*pb - 1);
	unsigned int foldedLSB = ((int) lsb) ^ ((int)(lsb>>32));
	int ind = (foldedLSB * 0x78291ACF) >> (32-6); // range is 0..63

	*pb &= ~lsb;
	return LSB_Magic[ind];
}
////////////////////////////////////////////////////////////////////////////////

#endif
