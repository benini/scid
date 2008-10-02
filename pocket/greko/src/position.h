#ifndef POSITION_H
#define POSITION_H

#include <vector>
using namespace std;

#include <assert.h>
#include "bitboards.h"

extern U64 s_Zobrist0;
extern U64 s_Zobrist[64][14];

static inline int Col(FLD f) { return (f % 8); }
static inline int Row(FLD f) { return (f / 8); }

typedef U8 COLOR;
enum COLOR_TAG 
{
	WHITE = 0,
	BLACK = 1
};

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

inline COLOR ColorOf(PIECE p) { return (p & 1); }
inline COLOR Opp(COLOR side) { return (side ^ 1); }

typedef int EVAL;

class Move
{
public:

	Move() : m_data(0) {}
	Move(U32 x) : m_data(x) {}
	Move(FLD from, FLD to, PIECE piece) : 
		m_data(U32(from) | 
		(U32(to) << 6) | 
		(U32(piece) << 12)) {}
	Move(FLD from, FLD to, PIECE piece, PIECE captured) : 
		m_data(U32(from) | 
		(U32(to) << 6) | 
		(U32(piece) << 12) |
		(U32(captured) << 16)) {}
	Move(FLD from, FLD to, PIECE piece, PIECE captured, PIECE promotion) : 
		m_data(U32(from) | 
		(U32(to) << 6) | 
		(U32(piece) << 12) |
		(U32(captured) << 16) |
		(U32(promotion) << 20)) {}

	FLD From() const { return m_data & 0x3f; }
	FLD To() const { return (m_data >> 6) & 0x3f; }
	FLD Piece() const { return (m_data >> 12) & 0x0f; }
	FLD Captured() const { return (m_data >> 16) & 0x0f; }
	FLD Promotion() const { return (m_data >> 20) & 0x0f; }

	operator U32() const { return m_data; }

private:

	U32 m_data;
};
////////////////////////////////////////////////////////////////////////////////

struct Undo
{
	U8   m_castlings;
	U64  m_check;
	FLD  m_ep;
	int  m_fifty;
	U64  m_hash;
	Move m_mv;
};

#define WHITE_CAN_O_O   (0x01)
#define WHITE_CAN_O_O_O (0x02)
#define BLACK_CAN_O_O   (0x04)
#define BLACK_CAN_O_O_O (0x08)

#define WHITE_DID_O_O   (0x10)
#define WHITE_DID_O_O_O (0x20)
#define BLACK_DID_O_O   (0x40)
#define BLACK_DID_O_O_O (0x80)

#define UNDO_SIZE        (600)

enum GAME_RESULT
{
	IN_PROGRESS = 0,
	WHITE_MATES = 1,
	BLACK_MATES = 2,
	DRAW_STALEMATE = 3,
	DRAW_MATERIAL = 4
};

class Position
{
public:

	PIECE operator[] (FLD f) const { return m_board[f]; }

	U64   Bits(PIECE p) const { return m_bits[p]; }
	U64   BitsAll(COLOR side) const { return m_bitsAll[side]; }
	U64   BitsAll() const { return m_bitsAll[WHITE] | m_bitsAll[BLACK]; }
	U8    Castlings() const { return m_castlings; }
	U64   CheckInfo() const { return m_check; }
	int   Count(PIECE p) const { return m_count[p]; }
	FLD   EP() const { return m_ep; }
	int   Fifty() const { return m_fifty; }
	GAME_RESULT GameResult() const;
	U64   GetAttacks(FLD to, COLOR side, U64 occupied) const;
	U64   GetBishopAttacks(FLD to, COLOR side, const U64& occupied) const;
	U64   GetRookAttacks(FLD to, COLOR side, const U64& occupied) const;
	int   GetRepetitions() const;
	U64   Hash() const { return m_hash ^ m_castlings ^ m_ep; }
	bool  InCheck() const { return (m_check != 0); }
//	bool  InCheck() const { return IsAttacked(m_Kings[m_side], m_side ^ 1); }
	bool  IsAttacked(FLD to, COLOR side) const;
	bool  IsDraw() const;
	FLD   King(COLOR side) const { return m_Kings[side]; }
	EVAL  Material(COLOR side) const { return m_material[side]; }
	U32   PawnHash() const { return U32(m_hash >> 32); }
	int   Ply() const { return m_ply; }
	void  Print() const;
	void  PrintAttacks() const;
	bool  SetFEN(const char* fen);
	void  SetInitial() { SetFEN("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"); }
	COLOR Side() const { return m_side; }

	bool MakeMove(Move mv);
	void MakeNullMove();
	void Mirror();
	void UnmakeMove();
	void UnmakeNullMove();

private:

	void Clear();
	void PutPiece(FLD f, PIECE p);
	void RemovePiece(FLD f);

	U64   m_bits[14];
	U64   m_bitsAll[2];
	PIECE m_board[64];
	U8    m_castlings;
	U64   m_check;
	int   m_count[14];
	FLD   m_ep;
	int   m_fifty;
	U64   m_hash;
	FLD   m_Kings[2];
	EVAL  m_material[2];
	int   m_ply;
	COLOR m_side;

	enum { MAX_UNDO = 500 };
	Undo m_undos[MAX_UNDO];
	int  m_undoCnt;	
};
////////////////////////////////////////////////////////////////////////////////

const char* fld_to_str(FLD f);
char*       get_fen(const Position* pos, char* buf);
void        init_hash_coeffs();

inline void Position::PutPiece(FLD f, PIECE p)
{
	assert(f <= H1);
	assert(p != NOPIECE);
	assert(m_board[f] == NOPIECE);

	m_board[f] = p;

	m_bits[p] ^= BB_SINGLE[f];
	m_bitsAll[ColorOf(p)] ^= BB_SINGLE[f];

	m_hash ^= s_Zobrist[f][p];
}
////////////////////////////////////////////////////////////////////////////////

extern Position g_pos;

inline void Position::RemovePiece(FLD f)
{
	assert(f <= H1);
	PIECE p = m_board[f];
	assert(p != NOPIECE);

	m_board[f] = NOPIECE;

	m_bits[p] ^= BB_SINGLE[f];
	m_bitsAll[ColorOf(p)] ^= BB_SINGLE[f];

	m_hash ^= s_Zobrist[f][p];
}
////////////////////////////////////////////////////////////////////////////////

inline U64 Position::GetBishopAttacks(FLD to, COLOR side, const U64& occupied) const
{
	U64 att = 0;

	// att |= BishopAttacks(to, occupied) & (Bits(BISHOPW | side) | Bits(QUEENW | side));
	
	U64 y = BB_BISHOP_ATTACKS[to] & (Bits(BISHOPW | side) | Bits(QUEENW | side));
	while (y)
	{
		FLD from = PopLSB(y);
		if ((BB_BETWEEN[from][to] & occupied) == 0)
			att |= BB_SINGLE[from];
	}
	return att;
}
////////////////////////////////////////////////////////////////////////////////

inline U64 Position::GetRookAttacks(FLD to, COLOR side, const U64& occupied) const
{
	U64 att = 0;

	// att |= RookAttacks(to, occupied) & (Bits(ROOKW | side) | Bits(QUEENW | side));
	
	U64 y = BB_ROOK_ATTACKS[to] & (Bits(ROOKW | side) | Bits(QUEENW | side));
	while (y)
	{
		FLD from = PopLSB(y);
		if ((BB_BETWEEN[from][to] & occupied) == 0)
			att |= BB_SINGLE[from];
	}
	return att;
}
////////////////////////////////////////////////////////////////////////////////

extern FLD steps[8][64];
extern FLD knight_steps[8][64];

#endif
