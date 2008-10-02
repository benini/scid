#ifndef BITBOARDS_H
#define BITBOARDS_H

#define MAGIC

#include <cassert>
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

enum DIRECTION_T
{
	DIR_R  = 0,
	DIR_UR = 1,
	DIR_U  = 2,
	DIR_UL = 3,
	DIR_L  = 4,
	DIR_DL = 5,
	DIR_D  = 6,
	DIR_DR = 7,
	DIR_NO = 8
};

void init_bitboards();
void print_bitboard(U64 b);

extern int g_dist[64][64];

extern U64 BB_SINGLE[64];
extern U64 BB_SINGLE_ZERO[64];
extern U64 BB_DIR[64][8];
extern U64 BB_PAWN_ATTACKS[64][2];
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
extern U8  DIRS[64][64];

extern U8 FIRST_IN_16[65536];


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

inline U64 Up(const U64& b) { return b << 8; }
inline U64 Down(const U64& b) { return b >> 8; }
inline U64 Right(const U64& b) { return (b & LL(0xfefefefefefefefe)) >> 1; }
inline U64 Left(const U64& b) { return (b & LL(0x7f7f7f7f7f7f7f7f)) << 1; }
inline U64 UpRight(const U64& b) { return (b & LL(0x00fefefefefefefe)) << 7; }
inline U64 UpLeft(const U64& b) { return (b & LL(0x007f7f7f7f7f7f7f)) << 9; }
inline U64 DownRight(const U64& b) { return (b & LL(0xfefefefefefefe00)) >> 9; }
inline U64 DownLeft(const U64& b) { return (b & LL(0x7f7f7f7f7f7f7f00)) >> 7; }

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

static inline int CountBits(const U64& bb) 
{
	if (bb == 0)
		return 0;

	U64 x = (( bb & mask_1 ) >> 1 ) + ( bb & (mask_1 >> 1) );
	x = (( x & mask_2 ) >> 2 ) + ( x & (mask_2 >> 2) );

	int y = (int) ((( x & mask_32 ) >> 32 ) + x );
	y = (( y & 0xF0F0F0F0 ) >> 4 ) + ( y & (0xF0F0F0F0 >> 4) );

	y += ( y & 0xFF00FF00 ) >> 8;
	y += ( y & 0xFFFF0000 ) >> 16;

	return ( y & 0xFF );
}
////////////////////////////////////////////////////////////////////////////////

static inline FLD LSB(const U64& bb)
{
	assert(bb != 0);

	U64 lsb = bb ^ (bb - 1);
	unsigned int foldedLSB = ((int) lsb) ^ ((int)(lsb>>32));
	int ind = (foldedLSB * 0x78291ACF) >> (32-6); // range is 0..63
	return LSB_Magic[ind];
}
////////////////////////////////////////////////////////////////////////////////

static inline FLD PopLSB(U64& bb)
{
	assert(bb != 0);

	U64 lsb = bb ^ (bb - 1);
	unsigned int foldedLSB = ((int) lsb) ^ ((int)(lsb>>32));
	int ind = (foldedLSB * 0x78291ACF) >> (32-6); // range is 0..63

	bb &= ~lsb;
	return LSB_Magic[ind];
}
////////////////////////////////////////////////////////////////////////////////

inline int MSB(const U64& b)
{
	assert (b != 0);

	U32 high = b >> 32;
	if (high)
	{
		if (high >> 16)
			return FIRST_IN_16[high >> 16];
		else
			return 16 + FIRST_IN_16[high];
	}
	else
	{
		U32 low = U32(b);
		if (low >> 16)
			return 32 + FIRST_IN_16[low >> 16];
		else
			return 48 + FIRST_IN_16[low];
	}
}
////////////////////////////////////////////////////////////////////////////////

inline int PopMSB(U64& b)
{
	assert (b != 0);

	int f = MSB(b);
	b ^= BB_SINGLE[f];
	return f;
}
////////////////////////////////////////////////////////////////////////////////

#ifdef MAGIC

const U64 B_MASK[64] =
{
	LL(0x0040201008040200), LL(0x0020100804020000), LL(0x0050080402000000), LL(0x0028440200000000),
	LL(0x0014224000000000), LL(0x000a102040000000), LL(0x0004081020400000), LL(0x0002040810204000),
	LL(0x0000402010080400), LL(0x0000201008040200), LL(0x0000500804020000), LL(0x0000284402000000),
	LL(0x0000142240000000), LL(0x00000a1020400000), LL(0x0000040810204000), LL(0x0000020408102000),
	LL(0x0040004020100800), LL(0x0020002010080400), LL(0x0050005008040200), LL(0x0028002844020000),
	LL(0x0014001422400000), LL(0x000a000a10204000), LL(0x0004000408102000), LL(0x0002000204081000),
	LL(0x0020400040201000), LL(0x0010200020100800), LL(0x0008500050080400), LL(0x0044280028440200),
	LL(0x0022140014224000), LL(0x00100a000a102000), LL(0x0008040004081000), LL(0x0004020002040800),
	LL(0x0010204000402000), LL(0x0008102000201000), LL(0x0004085000500800), LL(0x0002442800284400),
	LL(0x0040221400142200), LL(0x0020100a000a1000), LL(0x0010080400040800), LL(0x0008040200020400),
	LL(0x0008102040004000), LL(0x0004081020002000), LL(0x0002040850005000), LL(0x0000024428002800),
	LL(0x0000402214001400), LL(0x004020100a000a00), LL(0x0020100804000400), LL(0x0010080402000200),
	LL(0x0004081020400000), LL(0x0002040810200000), LL(0x0000020408500000), LL(0x0000000244280000),
	LL(0x0000004022140000), LL(0x00004020100a0000), LL(0x0040201008040000), LL(0x0020100804020000),
	LL(0x0002040810204000), LL(0x0000020408102000), LL(0x0000000204085000), LL(0x0000000002442800),
	LL(0x0000000040221400), LL(0x0000004020100a00), LL(0x0000402010080400), LL(0x0040201008040200)
};

const U64 B_MULT[64] =
{
	LL(0x0040080100420440), LL(0x0000201401060400), LL(0x0000802004900180), LL(0x0200000022024400),
	LL(0x0000000400411091), LL(0x1008002100411000), LL(0x0002104202100200), LL(0x0000240100d01000),
	LL(0x0004810802208000), LL(0x00a0021002008000), LL(0x0200040c08020200), LL(0x0000448405040000),
	LL(0x5000000442020002), LL(0x0020402203100000), LL(0x0000888401600000), LL(0x4000410808400080),
	LL(0x2084008400400100), LL(0x0182040104000200), LL(0x2003200080800100), LL(0x0000200208809400),
	LL(0x0000024200802800), LL(0x1001008040410400), LL(0x0008440220000801), LL(0x0201282004001000),
	LL(0x0004040028004100), LL(0x0001010200142200), LL(0x0020080040008240), LL(0x0001020a00040050),
	LL(0x0100020080180480), LL(0x0008109000080044), LL(0x2002021080200100), LL(0x2010043000041000),
	LL(0x0001020401008080), LL(0x0042040000410800), LL(0x0800420001009200), LL(0x01108c0000802000),
	LL(0x0004014024010002), LL(0x0001221010008200), LL(0x0005100005040800), LL(0x0008048020202200),
	LL(0x0001000080829000), LL(0x0002000141042010), LL(0x8000800048200801), LL(0x0001000890400800),
	LL(0x0018040082004000), LL(0x000c200204040008), LL(0x0020000418028100), LL(0x0020001404042800),
	LL(0x00002200c1041000), LL(0x0000040084242100), LL(0x0024009004200020), LL(0x4001040421008000),
	LL(0x0009042408800000), LL(0x0080080094208000), LL(0x0010204400808100), LL(0x000004100a120400),
	LL(0x0001050800840400), LL(0x0000440220102004), LL(0x0082080208000011), LL(0x0482021080004000),
	LL(0x8008048100010040), LL(0x0090208081000040), LL(0x3002080104008000), LL(0x0410101000802040)
};

const int B_BITS[64] =
{
	 6,  5,  5,  5,  5,  5,  5,  6,
	 5,  5,  5,  5,  5,  5,  5,  5,
	 5,  5,  7,  7,  7,  7,  5,  5,
	 5,  5,  7,  9,  9,  7,  5,  5,
	 5,  5,  7,  9,  9,  7,  5,  5,
	 5,  5,  7,  7,  7,  7,  5,  5,
	 5,  5,  5,  5,  5,  5,  5,  5,
	 6,  5,  5,  5,  5,  5,  5,  6
};

extern int B_OFFSET[64];
extern U64* B_DATA;

inline U64 BishopAttacks(int f, const U64& occupied)
{
	int index = B_OFFSET[f];
	index += int(((occupied & B_MASK[f]) * B_MULT[f]) >> (64 - B_BITS[f]));
	return B_DATA[index];
}
////////////////////////////////////////////////////////////////////////////////

const U64 R_MASK[64] =
{
	LL(0x7e80808080808000), LL(0x3e40404040404000), LL(0x5e20202020202000), LL(0x6e10101010101000),
	LL(0x7608080808080800), LL(0x7a04040404040400), LL(0x7c02020202020200), LL(0x7e01010101010100),
	LL(0x007e808080808000), LL(0x003e404040404000), LL(0x005e202020202000), LL(0x006e101010101000),
	LL(0x0076080808080800), LL(0x007a040404040400), LL(0x007c020202020200), LL(0x007e010101010100),
	LL(0x00807e8080808000), LL(0x00403e4040404000), LL(0x00205e2020202000), LL(0x00106e1010101000),
	LL(0x0008760808080800), LL(0x00047a0404040400), LL(0x00027c0202020200), LL(0x00017e0101010100),
	LL(0x0080807e80808000), LL(0x0040403e40404000), LL(0x0020205e20202000), LL(0x0010106e10101000),
	LL(0x0008087608080800), LL(0x0004047a04040400), LL(0x0002027c02020200), LL(0x0001017e01010100),
	LL(0x008080807e808000), LL(0x004040403e404000), LL(0x002020205e202000), LL(0x001010106e101000),
	LL(0x0008080876080800), LL(0x000404047a040400), LL(0x000202027c020200), LL(0x000101017e010100),
	LL(0x00808080807e8000), LL(0x00404040403e4000), LL(0x00202020205e2000), LL(0x00101010106e1000),
	LL(0x0008080808760800), LL(0x00040404047a0400), LL(0x00020202027c0200), LL(0x00010101017e0100),
	LL(0x0080808080807e00), LL(0x0040404040403e00), LL(0x0020202020205e00), LL(0x0010101010106e00),
	LL(0x0008080808087600), LL(0x0004040404047a00), LL(0x0002020202027c00), LL(0x0001010101017e00),
	LL(0x008080808080807e), LL(0x004040404040403e), LL(0x002020202020205e), LL(0x001010101010106e),
	LL(0x0008080808080876), LL(0x000404040404047a), LL(0x000202020202027c), LL(0x000101010101017e)
};

const U64 R_MULT[64] =
{
	LL(0x0000010824004082), LL(0x0001004200008c01), LL(0x0401008400020801), LL(0x0082001020040802),
	LL(0x0000040861001001), LL(0x0000084100600011), LL(0x0001001040820022), LL(0x00008000c1001021),
	LL(0x0010408400410200), LL(0x0100050810020400), LL(0x8400800200840080), LL(0x0200940080080080),
	LL(0x0080082090010100), LL(0x0018802000100880), LL(0x0010114008200040), LL(0x0008248000c00080),
	LL(0x2800008044020001), LL(0x2000020810040001), LL(0x0011000804010042), LL(0x0000842801010010),
	LL(0x2010008100080800), LL(0x0010200100430010), LL(0x3008201000404000), LL(0x0005400060808000),
	LL(0x4000088042000401), LL(0x0000020104001810), LL(0x0802008002804400), LL(0x0101140080800800),
	LL(0x0220801000800800), LL(0x0800881000802001), LL(0x0808601000404000), LL(0x4000804000801120),
	LL(0x0020040200004481), LL(0x0041000100820004), LL(0x8200040080800600), LL(0x0201180080040080),
	LL(0x1000402200120008), LL(0x0a00100080802000), LL(0x0120002180400080), LL(0x4020248080004000),
	LL(0x0080020005008044), LL(0x0820010100020004), LL(0x0040818004002200), LL(0x0400808008000401),
	LL(0x0808008010008008), LL(0x0000410020001504), LL(0x2008808040002001), LL(0x2008808000224000),
	LL(0x0000800048800100), LL(0x0020800100802200), LL(0x2000802200808400), LL(0x0002000600201810),
	LL(0x0908808010000800), LL(0x0101801004200080), LL(0x00204010022000c0), LL(0x0080800120804004),
	LL(0x0080004031000880), LL(0x1280008001004200), LL(0x0200020001440810), LL(0x1001000840208010),
	LL(0x010020100009000c), LL(0x0880100008200080), LL(0x0040084020005002), LL(0x0080002882104000)
};

const int R_BITS[64] =
{
	12, 11, 11, 11, 11, 11, 11, 12,
	11, 10, 10, 10, 10, 10, 10, 11,
	11, 10, 10, 10, 10, 10, 10, 11,
	11, 10, 10, 10, 10, 10, 10, 11,
	11, 10, 10, 10, 10, 10, 10, 11,
	11, 10, 10, 10, 10, 10, 10, 11,
	11, 10, 10, 10, 10, 10, 10, 11,
	12, 11, 11, 11, 11, 11, 11, 12
};

extern int R_OFFSET[64];
extern U64* R_DATA;

inline U64 RookAttacks(int f, const U64& occupied)
{
	int index = R_OFFSET[f];
	index += int(((occupied & R_MASK[f]) * R_MULT[f]) >> (64 - R_BITS[f]));
	return R_DATA[index];
}
////////////////////////////////////////////////////////////////////////////////

#else

inline U64 BishopAttacks(int f, const U64& occupied)
{
	U64 att = BB_BISHOP_ATTACKS[f];
	
	U64 x = BB_DIR[f][DIR_UR] & occupied;
	if (x)
		att ^= BB_DIR[LSB(x)][DIR_UR];

	x = BB_DIR[f][DIR_UL] & occupied;
	if (x)
		att ^= BB_DIR[LSB(x)][DIR_UL];

	x = BB_DIR[f][DIR_DL] & occupied;
	if (x)
		att ^= BB_DIR[MSB(x)][DIR_DL];

	x = BB_DIR[f][DIR_DR] & occupied;
	if (x)
		att ^= BB_DIR[MSB(x)][DIR_DR];

	return att;
}
////////////////////////////////////////////////////////////////////////////////

inline U64 RookAttacks(int f, const U64& occupied)
{
	U64 att = BB_ROOK_ATTACKS[f];
	
	U64 x = BB_DIR[f][DIR_R] & occupied;
	if (x)
		att ^= BB_DIR[MSB(x)][DIR_R];

	x = BB_DIR[f][DIR_U] & occupied;
	if (x)
		att ^= BB_DIR[LSB(x)][DIR_U];

	x = BB_DIR[f][DIR_L] & occupied;
	if (x)
		att ^= BB_DIR[LSB(x)][DIR_L];

	x = BB_DIR[f][DIR_D] & occupied;
	if (x)
		att ^= BB_DIR[MSB(x)][DIR_D];

	return att;
}
////////////////////////////////////////////////////////////////////////////////

#endif

inline U64 QueenAttacks(int f, const U64& occupied)
{
	return BishopAttacks(f, occupied) | RookAttacks(f, occupied);
}
////////////////////////////////////////////////////////////////////////////////

#endif
