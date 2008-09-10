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

const int ROOK_BITS = 12;
const int BISHOP_BITS = 9;

extern U64 BB_ROOK_DB[64][1 << ROOK_BITS];
extern U64 BB_BISHOP_DB[64][1 << BISHOP_BITS];

const U64 BB_BISHOP_MASK[64] = 
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

const U64 BB_BISHOP_MAGIC[64] =
{
	LL(0x20860c0021004200), LL(0x4400088504082010), LL(0x0410000810110010), LL(0x0002000248008090),
	LL(0x0000200000120820), LL(0x0000280004149000), LL(0x0000014240980100), LL(0x0048800804100400),
	LL(0x0010040040c02210), LL(0x1020010060081100), LL(0x0012005201078000), LL(0x1011082002140020),
	LL(0x1102000202880000), LL(0x2000002808124000), LL(0x1080410020100100), LL(0x00402304102c0020),
	LL(0x0800803004480040), LL(0x0190001800200010), LL(0x0000640080200200), LL(0x0009041812001010),
	LL(0x10000a0400200110), LL(0x0044820810000200), LL(0x02000400200000d0), LL(0x2002001420000090),
	LL(0x0080084210003010), LL(0x000a201820000800), LL(0x1402008218080210), LL(0x0084040400001010),
	LL(0x0204040402080210), LL(0x0a04008800810010), LL(0x0604084100200010), LL(0x0000200040200510),
	LL(0x0000060800400800), LL(0x0000450000114100), LL(0x41c0104801022000), LL(0x0001001041004000),
	LL(0x0005080001004100), LL(0x2004300020150010), LL(0x4210010010020200), LL(0x0004100028010020),
	LL(0x000a000081042020), LL(0x0010400200262200), LL(0x0001000022201010), LL(0xc00c000049200010),
	LL(0x0000880802002000), LL(0x0401007008108010), LL(0x0001006000210200), LL(0x0004002008401010),
	LL(0x0000001501080110), LL(0x0010003808110410), LL(0x0008105c04040100), LL(0x2000001004000000),
	LL(0x0008120404900010), LL(0x0041004014004040), LL(0x100220042820a100), LL(0x0000301000404040),
	LL(0x0000040886002000), LL(0x0080040138080000), LL(0x0002021001021000), LL(0x0000802000000110),
	LL(0x2080890200000000), LL(0x00010400821c8000), LL(0x1008011043105200), LL(0x2048009000090010)
};

const U64 BB_ROOK_MASK[64] =
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

const U64 BB_ROOK_MAGIC[64] =
{
	LL(0x1122208100c4240a), LL(0x800118028344051a), LL(0x0020860031128a02), LL(0x0012084242200112),
	LL(0x440204d008041102), LL(0x9a22b042018205a2), LL(0x8820410c08838e1a), LL(0xc206010080412052),
	LL(0x8a40102620802040), LL(0x04046316460020f0), LL(0x0a118ea100411010), LL(0x804b580e0095a200),
	LL(0x2a0408400c028a88), LL(0x00a4910840804002), LL(0xb821485010224008), LL(0x0421200084584240),
	LL(0x4100108442022012), LL(0x590e044028048002), LL(0x0c42e2d00810400a), LL(0x0aa0020800202a02),
	LL(0x082842046080080a), LL(0x4090e08140398012), LL(0x40c430a800444000), LL(0x0810f80260815002),
	LL(0x024ac0002004500a), LL(0x19902102400d8408), LL(0xd2404a050842c610), LL(0x832791410e88010a),
	LL(0xa091c10428820318), LL(0x020300643400a018), LL(0x0516000804808848), LL(0x20024040620010d2),
	LL(0x09f2288640021020), LL(0x8849408418240040), LL(0x0202308c20091a20), LL(0x25a2e49620080100),
	LL(0xcc80810408190120), LL(0x03500021004c418a), LL(0x60c286008ce021a2), LL(0x3015820080104020),
	LL(0x2400110013e27442), LL(0x0030190cc0b9025a), LL(0x8400841108031ad2), LL(0x20c8220004100502),
	LL(0x1050101019110520), LL(0x9100418920060012), LL(0x650502402080410a), LL(0x0082020011104082),
	LL(0xa042000c106c4122), LL(0x04082b9c2c9a10d8), LL(0x48220108b9388442), LL(0x8025480020281302),
	LL(0x44ca401004000802), LL(0x4480200124083030), LL(0x0485c00039010818), LL(0x1908400190004662),
	LL(0x550004812205c100), LL(0x04001002c4108102), LL(0xe800400108602450), LL(0x02000406b3157200),
	LL(0xc420042044008042), LL(0x006004c01800601a), LL(0x0208010180985000), LL(0x4480009240068222)
};

inline U64 BishopAttacks(int f, const U64& occupied)
{
	int index = ((occupied & BB_BISHOP_MASK[f]) * BB_BISHOP_MAGIC[f]) >> (64 - BISHOP_BITS);
	return BB_BISHOP_DB[f][index];
}
////////////////////////////////////////////////////////////////////////////////

inline U64 RookAttacks(int f, const U64& occupied)
{
	int index = ((occupied & BB_ROOK_MASK[f]) * BB_ROOK_MAGIC[f]) >> (64 - ROOK_BITS);
	return BB_ROOK_DB[f][index];
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
