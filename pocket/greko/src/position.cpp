#ifdef _MSC_VER
#pragma warning(disable: 4996)
#endif

#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include "eval.h"
#include "moves.h"
#include "position.h"
#include "utils.h"

U64 s_Zobrist0 = 0;
U64 s_Zobrist[64][14];

const char* FIELD_NAMES[65] =
{
	"a8", "b8", "c8", "d8", "e8", "f8", "g8", "h8",
	"a7", "b7", "c7", "d7", "e7", "f7", "g7", "h7",
	"a6", "b6", "c6", "d6", "e6", "f6", "g6", "h6",
	"a5", "b5", "c5", "d5", "e5", "f5", "g5", "h5",
	"a4", "b4", "c4", "d4", "e4", "f4", "g4", "h4",
	"a3", "b3", "c3", "d3", "e3", "f3", "g3", "h3",
	"a2", "b2", "c2", "d2", "e2", "f2", "g2", "h2",
	"a1", "b1", "c1", "d1", "e1", "f1", "g1", "h1",
	"NF"
};

static const FLD FLIP[64] =
{
	A1, B1, C1, D1, E1, F1, G1, H1,
	A2, B2, C2, D2, E2, F2, G2, H2,
	A3, B3, C3, D3, E3, F3, G3, H3,
	A4, B4, C4, D4, E4, F4, G4, H4,
	A5, B5, C5, D5, E5, F5, G5, H5,
	A6, B6, C6, D6, E6, F6, G6, H6,
	A7, B7, C7, D7, E7, F7, G7, H7,
	A8, B8, C8, D8, E8, F8, G8, H8
};

void Position::Clear()
{
	m_castlings = 0;
	m_ep = NF;
	m_fifty = 0;
	m_hash = 0;
	m_Kings[WHITE] = m_Kings[BLACK] = 0;
	m_material[WHITE] = m_material[BLACK] = 0;
	m_ply = 0;
	m_side = WHITE;
	m_undoCnt = 0;

	for (int f = 0; f < 64; f++)
	{
		m_board[f] = NOPIECE;
	}

	for (int p = 0; p < 14; p++)
	{
		m_bits[p] = 0;
		m_count[p] = 0;
	}

	m_bitsAll[WHITE] = m_bitsAll[BLACK] = 0;
}
////////////////////////////////////////////////////////////////////////////////

const char* fld_to_str(FLD f)
{
	return FIELD_NAMES[f];
}
////////////////////////////////////////////////////////////////////////////////

U64 Position::GetAttacks(FLD to, COLOR side, U64 occupied) const
{
	U64 x = 0, att = 0;
	FLD from = 0;

	att |= BB_PAWN_ATTACKS[to][side ^ 1] & Bits(PAWNW | side);
	att |= BB_KNIGHT_ATTACKS[to] & Bits(KNIGHTW | side);
	att |= BB_KING_ATTACKS[to] & Bits(KINGW | side);

	x = BB_BISHOP_ATTACKS[to] & 
	    (Bits(QUEENW | side) | Bits(BISHOPW | side));

	while (x)
	{
		from = PopLSB(x);
		if ((BB_BETWEEN[from][to] & occupied) == 0)
			set_bit(att, from);
	}

	x = BB_ROOK_ATTACKS[to] & 
	    (Bits(QUEENW | side) | Bits(ROOKW | side));

	while (x)
	{
		from = PopLSB(x);
		if ((BB_BETWEEN[from][to] & occupied) == 0)
			set_bit(att, from);
	}

	return att;
}
////////////////////////////////////////////////////////////////////////////////

char* get_fen(const Position* pos, char* buf)
{
	int cnt_empty = 0;
	char empty[9][2] = {"0", "1", "2", "3", "4", "5", "6", "7", "8"};

	strcpy(buf, "");
	for (int f = 0; f < 64; f++)
	{
		PIECE piece = (*pos)[f];

		if (piece != NOPIECE && cnt_empty != 0)
		{
			strcat(buf, empty[cnt_empty]);
			cnt_empty = 0;
		}

		switch (piece)
		{
		case PAWNW:	 strcat(buf, "P"); break;
		case PAWNB:	 strcat(buf, "p"); break;
		case KNIGHTW:  strcat(buf, "N"); break;
		case KNIGHTB:  strcat(buf, "n"); break;
		case BISHOPW:  strcat(buf, "B"); break;
		case BISHOPB:  strcat(buf, "b"); break;
		case ROOKW:	 strcat(buf, "R"); break;
		case ROOKB:	 strcat(buf, "r"); break;
		case QUEENW:	strcat(buf, "Q"); break;
		case QUEENB:	strcat(buf, "q"); break;
		case KINGW:	 strcat(buf, "K"); break;
		case KINGB:	 strcat(buf, "k"); break;
		case NOPIECE:  cnt_empty++; break;
		default:
			break;
		}

		if (Col(f) == 7)
		{
			if (cnt_empty)
				strcat(buf, empty[cnt_empty]);

			if (f != H1)
				strcat(buf, "/");

			cnt_empty = 0;
		}

	}

	if (pos->Side() == WHITE)
		strcat(buf, " w");
	else
		strcat(buf, " b");

	strcat(buf, " ");
	int no_castlings = 1;

	if (pos->Castlings() & WHITE_CAN_O_O)
	{
		strcat(buf, "K");
		no_castlings = 0;
	}

	if (pos->Castlings() & WHITE_CAN_O_O_O)
	{
		strcat(buf, "Q");
		no_castlings = 0;
	}

	if (pos->Castlings() & BLACK_CAN_O_O)
	{
		strcat(buf, "k");
		no_castlings = 0;
	}

	if (pos->Castlings() & BLACK_CAN_O_O_O)
	{
		strcat(buf, "q");
		no_castlings = 0;
	}

	if (no_castlings)
		strcat(buf, "-");

	strcat(buf, " ");
	if (pos->EP() != NF)
		strcat(buf, fld_to_str(pos->EP()));
	else
		strcat(buf, "-");

	char cnt[16];
	sprintf(cnt, " %d %d", pos->Fifty(), pos->Ply() / 2 + 1);
	strcat(buf, cnt);

	return buf;
}
////////////////////////////////////////////////////////////////////////////////

int Position::GetRepetitions() const
{ 
	int total = 1;

	for (int i = m_undoCnt - 1; i >= 0; --i)
	{
		if (m_undos[i].m_hash == m_hash) 
		{
			++total;
		}

		if (m_undos[i].m_mv == 0)
			return 0;

		if (m_undos[i].m_mv.Captured())
			break;

		if (m_undos[i].m_mv.Piece() == PAWNW)
			break;

		if (m_undos[i].m_mv.Piece() == PAWNB)
			break;
	 }

	return total;
}
////////////////////////////////////////////////////////////////////////////////

void init_hash_coeffs()
{
	rnd32_seed(42);

	for (int f = 0; f < 64; f++)
	{
		for (int p = 0; p < 14; p++)
		{
			U64 x = rnd64();

			if (p != PAWNW && p != PAWNB)
				x &= LL(0x00000000ffffffff);

			s_Zobrist[f][p] = x;
		}
	}

	s_Zobrist0 = rnd64() & LL(0x00000000ffffffff);
}
////////////////////////////////////////////////////////////////////////////////

bool Position::IsAttacked(FLD to, COLOR side) const
{
	U64 x;
	FLD from;

	if (BB_PAWN_ATTACKS[to][side ^ 1] & Bits(PAWNW | side))
		return true;

	if (BB_KNIGHT_ATTACKS[to] & Bits(KNIGHTW | side))
		return true;

	if (BB_KING_ATTACKS[to] & Bits(KINGW | side))
		return true;

	U64 occupied = m_bitsAll[WHITE] | m_bitsAll[BLACK];

	x = BB_BISHOP_ATTACKS[to] & 
	    (Bits(QUEENW | side) | Bits(BISHOPW | side));

	while (x)
	{
		from = PopLSB(x);
		if ((BB_BETWEEN[from][to] & occupied) == 0)
			return true;
	}

	x = BB_ROOK_ATTACKS[to] & 
	    (Bits(QUEENW | side) | Bits(ROOKW | side));

	while (x)
	{
		from = PopLSB(x);
		if ((BB_BETWEEN[from][to] & occupied) == 0)
			return true;
	}

	return false;
}
////////////////////////////////////////////////////////////////////////////////

bool Position::IsDraw() const
{
	if (Material(WHITE) == 0 && Material(BLACK) == 0)
		return 1;

	if (Count(PAWNW) || Count(PAWNB))
		return 0;

	if (Material(WHITE) == 0)                            
	{
		if (Material(BLACK) < VAL_ROOK)
			return 1;
	}

	if (Material(BLACK) == 0)
	{
		if (Material(WHITE) < VAL_ROOK)
			return 1;
	}

	return 0;
}
////////////////////////////////////////////////////////////////////////////////

static unsigned char castling_effect[64] =
{
	0xf7, 0xff, 0xff, 0xff, 0xf3, 0xff, 0xff, 0xfb,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
	0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff,
	0xfd, 0xff, 0xff, 0xff, 0xfc, 0xff, 0xff, 0xfe
};

bool Position::MakeMove(Move mv)
{
	Undo& undo = m_undos[m_undoCnt++];
	undo.m_castlings = m_castlings;
	undo.m_check = m_check;
	undo.m_ep = m_ep;
	undo.m_fifty = m_fifty;
	undo.m_hash = m_hash;
	undo.m_mv = mv;

	FLD from = mv.From();
	FLD to = mv.To();
	PIECE piece = mv.Piece();
	PIECE captured = mv.Captured();
	PIECE promotion = mv.Promotion();

	assert(piece != NOPIECE);

	COLOR side = ColorOf(piece);
	COLOR opp = 1 - side;
	assert(side == m_side);

	if (captured)
	{
		m_material[opp] -= VALUE[captured];
		--m_count[captured];
	}

	switch (piece)
	{
	case PAWNW:

		m_fifty = 0;
		RemovePiece(from);

		if (to == m_ep)
		{
			RemovePiece(to + 8);
			PutPiece(to, PAWNW);
		}
		else
		{
			if (captured)
				RemovePiece(to);

			if (promotion == NOPIECE)
				PutPiece(to, PAWNW);
			else
			{
				PutPiece(to, promotion);
				m_material[side] += VALUE[promotion] - VALUE[piece];
				m_count[promotion]++;
				m_count[piece]--;
			}
		}

		// Set enpassant field:
		if (to - from == - 16)			 // long pawn move
			m_ep = (FLD) (from - 8);
		else
			m_ep = NF;

		break;

	case PAWNB:

		m_fifty = 0;
		RemovePiece(from);

		if (to == m_ep)
		{
			RemovePiece(to - 8);
			PutPiece(to, PAWNB);
		}
		else
		{
			if (captured)
				RemovePiece(to);

			if (promotion == NOPIECE)
				PutPiece(to, PAWNB);
			else
			{
				PutPiece(to, promotion);
				m_material[side] += VALUE[promotion] - VALUE[piece];
				++m_count[promotion];
				--m_count[piece];
			}
		}

		// Set enpassant field:
		if (to - from == 16)			 // long pawn move
			m_ep = (FLD) (from + 8);
		else
			m_ep = NF;

		break;

	case KNIGHTW:
	case KNIGHTB:
	case BISHOPW:
	case BISHOPB:                               
	case ROOKW:
	case ROOKB:
	case QUEENW:
	case QUEENB:

		++m_fifty;
		m_ep = NF;

		RemovePiece(from);

		if (captured)
		{
			m_fifty = 0;
			RemovePiece(to);
		}

		PutPiece(to, piece);

		break;

	case KINGW:

		++m_fifty;
		m_ep = NF;

		RemovePiece(from);

		if (captured)
		{
			m_fifty = 0;
			RemovePiece(to);
		}
		else if (from == E1)
		{
			if (to == G1)
			{
				RemovePiece(H1);
				PutPiece(F1, ROOKW);
				m_castlings |= WHITE_DID_O_O; // 0001 0000
			}
			else if (to == C1)
			{
				RemovePiece(A1);
				PutPiece(D1, ROOKW);
				m_castlings |= WHITE_DID_O_O_O; // 0010 0000
			}
		}

		PutPiece(to, piece);
		m_Kings[WHITE] = to;
		break;

	case KINGB:

		++m_fifty;
		m_ep = NF;

		RemovePiece(from);

		if (captured)
		{
			m_fifty = 0;
			RemovePiece(to);
		}
		else if (from == E8)
		{
			if (to == G8)
			{
				RemovePiece(H8);
				PutPiece(F8, ROOKB);
				m_castlings |= BLACK_DID_O_O; // 0100 0000
			}
			else if (to == C8)
			{
				RemovePiece(A8);
				PutPiece(D8, ROOKB);
				m_castlings |= BLACK_DID_O_O_O; // 1000 0000
			}
		}

		PutPiece(to, piece);
		m_Kings[BLACK] = to;

		break;
	default:
		assert(0);
	}

	m_castlings &= castling_effect[from];
	m_castlings &= castling_effect[to];

	FLD K = King(opp);
	U8 dirTo = DIRS[K][to];
	U8 dirFrom = DIRS[K][from];

	m_check = 0;
	switch (m_board[to])
	{
	case PAWNW: case PAWNB:
		m_check |= BB_PAWN_ATTACKS[K][opp] & BB_SINGLE[to];
		break;
	case KNIGHTW: case KNIGHTB:
		m_check |= BB_KNIGHT_ATTACKS[K] & BB_SINGLE[to];
		break;
	case BISHOPW: case BISHOPB:
		if (dirTo != DIR_NO && (dirTo % 2 == 1))
			m_check |= BishopAttacks(K, BitsAll()) & BB_SINGLE[to];
		break;
	case ROOKW: case ROOKB:
		if (dirTo != DIR_NO && (dirTo % 2 == 0))
			m_check |= RookAttacks(K, BitsAll()) & BB_SINGLE[to];
		break;
	case QUEENW: case QUEENB:
		if (dirTo != DIR_NO)
			m_check |= QueenAttacks(K, BitsAll()) & BB_SINGLE[to];
		break;
//	case KINGW: case KINGB:
//		m_check |= BB_KING_ATTACKS[K] & BB_SINGLE[to];
//		break;
	default:
		break;
	}

	if (dirFrom != DIR_NO)
	{
		if (dirFrom % 2 == 1)
			m_check |= GetBishopAttacks(K, side, BitsAll());
		else
			m_check |= GetRookAttacks(K, side, BitsAll());
	}

	++m_ply;
	m_side ^= 1;
	m_hash ^= s_Zobrist0;
	
//	if (IsAttacked(m_Kings[side], opp))
//	{
//		Print();
//		getchar();
//		UnmakeMove();
//		return false;
//	}

	return true;
}
////////////////////////////////////////////////////////////////////////////////

void Position::MakeNullMove()
{
	Undo& undo = m_undos[m_undoCnt++];
	undo.m_castlings = m_castlings;
	undo.m_check = m_check;
	undo.m_ep = m_ep;
	undo.m_fifty = m_fifty;
//	undo.m_hash = m_hash;
	undo.m_mv = 0;

	m_ep = NF;
	m_side ^= 1;
	m_hash ^= s_Zobrist0;
	++m_ply;
}
////////////////////////////////////////////////////////////////////////////////

void Position::Mirror()
{
	Position old = *this;

	Clear();
	for (int f = 0; f < 64; f++)
	{
		PIECE p = old[f];
		if (p == NOPIECE)
			continue;

		PutPiece(FLIP[f], p ^ 1);

		if (p == KINGW)
			m_Kings[BLACK] = FLIP[f];
		else if (p == KINGB)
			m_Kings[WHITE] = FLIP[f];
	}

	m_side = old.Side() ^ 1;
	m_fifty = old.Fifty();
	if (old.EP() != NF)
		m_ep = FLIP[old.EP()];

	m_ply = old.Ply();

	for (int f1 = 0; f1 < 64; f1++)
	{
		PIECE p1 = m_board[f1];
		COLOR c1 = ColorOf(p1);
		if (p1)
		{
			m_material[c1] += VALUE[p1];
			m_count[p1]++;
		}
	}

	int bit0 = old.m_castlings & 0x01;
	int bit1 = (old.m_castlings & 0x02) >> 1;
	int bit2 = (old.m_castlings & 0x04) >> 2;
	int bit3 = (old.m_castlings & 0x08) >> 3;
	int bit4 = (old.m_castlings & 0x10) >> 4;
	int bit5 = (old.m_castlings & 0x20) >> 5;
	int bit6 = (old.m_castlings & 0x40) >> 6;
	int bit7 = (old.m_castlings & 0x80) >> 7;

	m_castlings = (bit5 << 7) |
	                 (bit4 << 6) |
	                 (bit7 << 5) |
	                 (bit6 << 4) |
	                 (bit1 << 3) |
	                 (bit0 << 2) |
	                 (bit3 << 1) |
	                 (bit2 << 0);
}
////////////////////////////////////////////////////////////////////////////////

void Position::PrintAttacks() const
{
	int row = 0, col = 0;

	out("\n");
	for (row = 0; row < 8; row++)
	{
		for (col = 0; col < 8; col++)
		{
			U64 att = GetAttacks(8 * row + col, WHITE, BitsAll());
			int n = CountBits(att);

			if (n > 0)
			{
				OUT1(" %d", n);
			}
			else
			{
				out(" -");
			}
		}

		out("	");
		for (col = 0; col < 8; col++)
		{
			U64 att = GetAttacks(8 * row + col, BLACK, BitsAll());
			int n = CountBits(att);

			if (n > 0)
			{
				OUT1(" %d", n);
			}
			else
			{
				out(" -");
			}
		}

		out("\n");
	}
	out("\n");
}
////////////////////////////////////////////////////////////////////////////////

void Position::Print() const
{
	out("\n");
	for (int f = 0; f < 64; f++)
	{
		char sym = '-';
		PIECE piece = m_board[f];
		switch (piece)
		{
		case PAWNW:   sym = 'P'; break;
		case PAWNB:   sym = 'p'; break;
		case KNIGHTW: sym = 'N'; break;
		case KNIGHTB: sym = 'n'; break;
		case BISHOPW: sym = 'B'; break;
		case BISHOPB: sym = 'b'; break;
		case ROOKW:   sym = 'R'; break;
		case ROOKB:   sym = 'r'; break;
		case QUEENW:  sym = 'Q'; break;
		case QUEENB:  sym = 'q'; break;
		case KINGW:   sym = 'K'; break;
		case KINGB:   sym = 'k'; break;
		default:      sym = '-'; break;
		}

//       if (piece != NOPIECE && getcolor(piece) == WHITE)
//          set_highlight(1);

		OUT1(" %c", sym);
//       set_highlight(0);

		if (Col(f) == 7)
			out("\n");
	}

	if (m_undoCnt)
	{
		out("\n ");
		for (int m = 0; m < m_undoCnt; m++)
		{
			char buf1[16];
			OUT1("%s ", move_to_str(m_undos[m].m_mv, buf1));
		}
		out("\n ");
	}
	out("\n");
}
////////////////////////////////////////////////////////////////////////////////

bool Position::SetFEN(const char* fen)
{
	if (strlen(fen) < 5)
		return 0;

	Clear();

	char buf[BUFSIZE];
	strncpy(buf, fen, BUFSIZE);

	char* token = strtok(buf, " ");
	char* p = token;
	int incorrect_fen = 0;

	FLD f = A8;

	//
	//   1. Pieces
	//

	while (*p)
	{
		if (f > H1)
			break;

		PIECE piece = NOPIECE;

		switch (*p)
		{
		case 'P': piece = PAWNW;   break;
		case 'p': piece = PAWNB;   break;
		case 'N': piece = KNIGHTW; break;
		case 'n': piece = KNIGHTB; break;
		case 'B': piece = BISHOPW; break;
		case 'b': piece = BISHOPB; break;
		case 'R': piece = ROOKW;   break;
		case 'r': piece = ROOKB;   break;
		case 'Q': piece = QUEENW;  break;
		case 'q': piece = QUEENB;  break;
		case 'K': piece = KINGW; m_Kings[WHITE] = f; break;
		case 'k': piece = KINGB; m_Kings[BLACK] = f; break;

		case '1': f += 1; break;
		case '2': f += 2; break;
		case '3': f += 3; break;
		case '4': f += 4; break;
		case '5': f += 5; break;
		case '6': f += 6; break;
		case '7': f += 7; break;
		case '8': f += 8; break;

		case '/':
			if (Col(f) != 0)
				f = 8 * (Row(f) + 1);
			break;

		default:
			break;
		}

		if (piece)
		{
			PutPiece(f, piece);
			f++;
		}

		p++;
	}

	//
	//   2. Side to move
	//

	token = strtok(NULL, " ");
	if (token == NULL)
		goto FINALIZE_SETFEN;

	if (token[0] == 'w')
		m_side = WHITE;
	else if (token[0] == 'b')
		m_side = BLACK;
	else
	{
		incorrect_fen = 1;
		goto FINALIZE_SETFEN;
	}

	//
	//   3. Castling rights
	//

	token = strtok(NULL, " ");
	if (token == NULL)
		goto FINALIZE_SETFEN;

	m_castlings = 0;

	if (strstr(token, "K") != NULL)	
		m_castlings |= WHITE_CAN_O_O;

	if (strstr(token, "Q") != NULL)	
		m_castlings |= WHITE_CAN_O_O_O;
		
	if (strstr(token, "k") != NULL)	
		m_castlings |= BLACK_CAN_O_O;
		
	if (strstr(token, "q") != NULL)	
		m_castlings |= BLACK_CAN_O_O_O;

	//
	//   4. En-passant
	//

	token = strtok(NULL, " ");
	if (token == NULL)
		goto FINALIZE_SETFEN;

	m_ep = str_to_fld(token);

	//
	//   5. Counters
	//

	token = strtok(NULL, " ");
	if (token == NULL)
		goto FINALIZE_SETFEN;

	m_fifty = atoi(token);
	if (m_fifty < 0)
		m_fifty = 0;

	token = strtok(NULL, " ");
	if (token == NULL)
		goto FINALIZE_SETFEN;

	m_ply = (atoi(token) - 1) * 2;
	if (m_side == BLACK)
		++m_ply;

	if (m_ply < 0)
		m_ply = 0;

FINALIZE_SETFEN:

	for (int f1 = 0; f1 < 64; f1++)
	{
		PIECE p1 = m_board[f1];
		COLOR c1 = ColorOf(p1);
		if (p1)
		{
			m_material[c1] += VALUE[p1];
			++m_count[p1];
		}
	}

	m_check = GetAttacks(King(Side()), Opp(m_side), BitsAll());

	return true;
}
////////////////////////////////////////////////////////////////////////////////

FLD str_to_fld(const char* s)
{
	if (strlen(s) != 2)
		return NF;

	int col = s[0] - 'a';
	int row = 7 - (s[1] - '1');

	if (col < 0 || col > 7 || row < 0 || row > 7)
		return NF;

	return (FLD) (8 * row + col);
}
////////////////////////////////////////////////////////////////////////////////

Move str_to_move(const Position* pos, const char* s)
{
	if (strlen(s) < 4 || strlen(s) > 5)
		return 0;

	char buf[3];
	buf[0] = s[0];
	buf[1] = s[1];
	buf[2] = 0;
	FLD from = str_to_fld(buf);
	if (from == NF)
		return 0;

	buf[0] = s[2];
	buf[1] = s[3];
	buf[2] = 0;
	FLD to = str_to_fld(buf);
	if (to == NF)
		return 0;

	PIECE piece = (*pos)[from];
	if (!piece)
		return 0;

	PIECE captured = (*pos)[to];
	if (to == pos->EP())
	{
		if (piece == PAWNW)
			captured = PAWNB;
		else if (piece == PAWNB)
			captured = PAWNW;
	}

	PIECE promotion = NOPIECE;
	if (strlen(s) == 5)
	{
		switch(s[4])
		{
		case 'q' :
			promotion = QUEENW | ColorOf(piece);
			break;
		case 'r' :
			promotion = ROOKW | ColorOf(piece);
			break;
		case 'b' :
			promotion = BISHOPW | ColorOf(piece);
			break;
		case 'n' :
			promotion = KNIGHTW | ColorOf(piece);
			break;
		default:
			return 0;
		}
	}

	return Move(from, to, piece, captured, promotion);
}
////////////////////////////////////////////////////////////////////////////////

void Position::UnmakeMove()
{
	if (m_undoCnt <= 0)
		return;

	Undo& undo = m_undos[--m_undoCnt];
	Move mv = undo.m_mv;
	m_check = undo.m_check;
	m_ep = undo.m_ep;
	m_castlings = undo.m_castlings;
	m_fifty = undo.m_fifty;

	FLD from = mv.From();
	FLD to = mv.To();
	PIECE piece = mv.Piece();
	PIECE captured = mv.Captured();
	PIECE promotion = mv.Promotion();
	
	--m_ply;
	m_side ^= 1;
	m_hash ^= s_Zobrist0;

	COLOR side = m_side;
	COLOR opp = side ^ 1;

	if (captured)
	{
		m_material[opp] += VALUE[captured];
		++m_count[captured];
	}

	if (promotion)
	{
		m_material[side] -= (VALUE[promotion] - VALUE[piece]);
		--m_count[promotion];
		++m_count[piece];
	}
	
	if (piece == KINGW)
	{
		m_Kings[WHITE] = from;

		if (from == E1 && to == G1)
		{
			RemovePiece(G1);
			RemovePiece(F1);
			PutPiece(E1, KINGW);
			PutPiece(H1, ROOKW);
		}
		else if (from == E1 && to == C1)
		{
			RemovePiece(C1);
			RemovePiece(D1);
			PutPiece(E1, KINGW);
			PutPiece(A1, ROOKW);
		}
		else
		{
			RemovePiece(to);
			PutPiece(from, piece);

			if (captured)
				PutPiece(to, captured);
		}
	}
	else if (piece == KINGB)
	{
		m_Kings[BLACK] = from;

		if (from == E8 && to == G8)
		{
			RemovePiece(G8);
			RemovePiece(F8);
			PutPiece(E8, KINGB);
			PutPiece(H8, ROOKB);
		}
		else if (from == E8 && to == C8)
		{
			RemovePiece(C8);
			RemovePiece(D8);
			PutPiece(E8, KINGB);
			PutPiece(A8, ROOKB);
		}
		else
		{
			RemovePiece(to);
			PutPiece(from, piece);

			if (captured)
				PutPiece(to, captured);
		}
	}
	else if (piece == PAWNW && to == m_ep)
	{
		RemovePiece(to);
		PutPiece(from, PAWNW);
		PutPiece((FLD) (to + 8), PAWNB);
	}
	else if (piece == PAWNB && to == m_ep)
	{
		RemovePiece(to);
		PutPiece(from, PAWNB);
		PutPiece((FLD) (to - 8), PAWNW);
	}
	else
	{
		RemovePiece(to);
		PutPiece(from, piece);

		if (captured)
			PutPiece(to, captured);
	}
}
////////////////////////////////////////////////////////////////////////////////

void Position::UnmakeNullMove()
{
	if (m_undoCnt <= 0)
		return;

	Undo& undo = m_undos[--m_undoCnt];
	m_check = undo.m_check;
	m_ep = undo.m_ep;
	m_castlings = undo.m_castlings;
	m_fifty = undo.m_fifty;

	m_side ^= 1;
	m_hash ^= s_Zobrist0;
	--m_ply;
}
////////////////////////////////////////////////////////////////////////////////

FLD knight_steps[8][64] =
{
{
	NF, NF, NF, NF, NF, NF, NF, NF,
	C8, D8, E8, F8, G8, H8, NF, NF,
	C7, D7, E7, F7, G7, H7, NF, NF,
	C6, D6, E6, F6, G6, H6, NF, NF,
	C5, D5, E5, F5, G5, H5, NF, NF,
	C4, D4, E4, F4, G4, H4, NF, NF,
	C3, D3, E3, F3, G3, H3, NF, NF,
	C2, D2, E2, F2, G2, H2, NF, NF
},

{
	NF, NF, NF, NF, NF, NF, NF, NF,
	NF, NF, NF, NF, NF, NF, NF, NF,
	B8, C8, D8, E8, F8, G8, H8, NF,
	B7, C7, D7, E7, F7, G7, H7, NF,
	B6, C6, D6, E6, F6, G6, H6, NF,
	B5, C5, D5, E5, F5, G5, H5, NF,
	B4, C4, D4, E4, F4, G4, H4, NF,
	B3, C3, D3, E3, F3, G3, H3, NF
},

{
	NF, NF, NF, NF, NF, NF, NF, NF,
	NF, NF, NF, NF, NF, NF, NF, NF,
	NF, A8, B8, C8, D8, E8, F8, G8,
	NF, A7, B7, C7, D7, E7, F7, G7,
	NF, A6, B6, C6, D6, E6, F6, G6,
	NF, A5, B5, C5, D5, E5, F5, G5,
	NF, A4, B4, C4, D4, E4, F4, G4,
	NF, A3, B3, C3, D3, E3, F3, G3,
},

{
	NF, NF, NF, NF, NF, NF, NF, NF,
	NF, NF, A8, B8, C8, D8, E8, F8,
	NF, NF, A7, B7, C7, D7, E7, F7,
	NF, NF, A6, B6, C6, D6, E6, F6,
	NF, NF, A5, B5, C5, D5, E5, F5,
	NF, NF, A4, B4, C4, D4, E4, F4,
	NF, NF, A3, B3, C3, D3, E3, F3,
	NF, NF, A2, B2, C2, D2, E2, F2
},

{
	NF, NF, A7, B7, C7, D7, E7, F7,
	NF, NF, A6, B6, C6, D6, E6, F6,
	NF, NF, A5, B5, C5, D5, E5, F5,
	NF, NF, A4, B4, C4, D4, E4, F4,
	NF, NF, A3, B3, C3, D3, E3, F3,
	NF, NF, A2, B2, C2, D2, E2, F2,
	NF, NF, A1, B1, C1, D1, E1, F1,
	NF, NF, NF, NF, NF, NF, NF, NF
},

{
	NF, A6, B6, C6, D6, E6, F6, G6,
	NF, A5, B5, C5, D5, E5, F5, G5,
	NF, A4, B4, C4, D4, E4, F4, G4,
	NF, A3, B3, C3, D3, E3, F3, G3,
	NF, A2, B2, C2, D2, E2, F2, G2,
	NF, A1, B1, C1, D1, E1, F1, G1,
	NF, NF, NF, NF, NF, NF, NF, NF,
	NF, NF, NF, NF, NF, NF, NF, NF
},

{
	B6, C6, D6, E6, F6, G6, H6, NF,
	B5, C5, D5, E5, F5, G5, H5, NF,
	B4, C4, D4, E4, F4, G4, H4, NF,
	B3, C3, D3, E3, F3, G3, H3, NF,
	B2, C2, D2, E2, F2, G2, H2, NF,
	B1, C1, D1, E1, F1, G1, H1, NF,
	NF, NF, NF, NF, NF, NF, NF, NF,
	NF, NF, NF, NF, NF, NF, NF, NF 
},

{
	C7, D7, E7, F7, G7, H7, NF, NF,
	C6, D6, E6, F6, G6, H6, NF, NF,
	C5, D5, E5, F5, G5, H5, NF, NF,
	C4, D4, E4, F4, G4, H4, NF, NF,
	C3, D3, E3, F3, G3, H3, NF, NF,
	C2, D2, E2, F2, G2, H2, NF, NF,
	C1, D1, E1, F1, G1, H1, NF, NF,
	NF, NF, NF, NF, NF, NF, NF, NF 
}
};

FLD steps[8][64] =
{
{
	B8, C8, D8, E8, F8, G8, H8, NF,
	B7, C7, D7, E7, F7, G7, H7, NF,
	B6, C6, D6, E6, F6, G6, H6, NF,
	B5, C5, D5, E5, F5, G5, H5, NF,
	B4, C4, D4, E4, F4, G4, H4, NF,
	B3, C3, D3, E3, F3, G3, H3, NF,
	B2, C2, D2, E2, F2, G2, H2, NF,
	B1, C1, D1, E1, F1, G1, H1, NF
},

{
	NF, NF, NF, NF, NF, NF, NF, NF,
	B8, C8, D8, E8, F8, G8, H8, NF,
	B7, C7, D7, E7, F7, G7, H7, NF,
	B6, C6, D6, E6, F6, G6, H6, NF,
	B5, C5, D5, E5, F5, G5, H5, NF,
	B4, C4, D4, E4, F4, G4, H4, NF,
	B3, C3, D3, E3, F3, G3, H3, NF,
	B2, C2, D2, E2, F2, G2, H2, NF
},

{
	NF, NF, NF, NF, NF, NF, NF, NF,
	A8, B8, C8, D8, E8, F8, G8, H8,
	A7, B7, C7, D7, E7, F7, G7, H7,
	A6, B6, C6, D6, E6, F6, G6, H6,
	A5, B5, C5, D5, E5, F5, G5, H5,
	A4, B4, C4, D4, E4, F4, G4, H4,
	A3, B3, C3, D3, E3, F3, G3, H3,
	A2, B2, C2, D2, E2, F2, G2, H2
},

{
	NF, NF, NF, NF, NF, NF, NF, NF,
	NF, A8, B8, C8, D8, E8, F8, G8,
	NF, A7, B7, C7, D7, E7, F7, G7,
	NF, A6, B6, C6, D6, E6, F6, G6,
	NF, A5, B5, C5, D5, E5, F5, G5,
	NF, A4, B4, C4, D4, E4, F4, G4,
	NF, A3, B3, C3, D3, E3, F3, G3,
	NF, A2, B2, C2, D2, E2, F2, G2
},

{
	NF, A8, B8, C8, D8, E8, F8, G8,
	NF, A7, B7, C7, D7, E7, F7, G7,
	NF, A6, B6, C6, D6, E6, F6, G6,
	NF, A5, B5, C5, D5, E5, F5, G5,
	NF, A4, B4, C4, D4, E4, F4, G4,
	NF, A3, B3, C3, D3, E3, F3, G3,
	NF, A2, B2, C2, D2, E2, F2, G2,
	NF, A1, B1, C1, D1, E1, F1, G1
},

{
	NF, A7, B7, C7, D7, E7, F7, G7,
	NF, A6, B6, C6, D6, E6, F6, G6,
	NF, A5, B5, C5, D5, E5, F5, G5,
	NF, A4, B4, C4, D4, E4, F4, G4,
	NF, A3, B3, C3, D3, E3, F3, G3,
	NF, A2, B2, C2, D2, E2, F2, G2,
	NF, A1, B1, C1, D1, E1, F1, G1,
	NF, NF, NF, NF, NF, NF, NF, NF
},

{
	A7, B7, C7, D7, E7, F7, G7, H7,
	A6, B6, C6, D6, E6, F6, G6, H6,
	A5, B5, C5, D5, E5, F5, G5, H5,
	A4, B4, C4, D4, E4, F4, G4, H4,
	A3, B3, C3, D3, E3, F3, G3, H3,
	A2, B2, C2, D2, E2, F2, G2, H2,
	A1, B1, C1, D1, E1, F1, G1, H1,
	NF, NF, NF, NF, NF, NF, NF, NF
},

{
	B7, C7, D7, E7, F7, G7, H7, NF,
	B6, C6, D6, E6, F6, G6, H6, NF,
	B5, C5, D5, E5, F5, G5, H5, NF,
	B4, C4, D4, E4, F4, G4, H4, NF,
	B3, C3, D3, E3, F3, G3, H3, NF,
	B2, C2, D2, E2, F2, G2, H2, NF,
	B1, C1, D1, E1, F1, G1, H1, NF,
	NF, NF, NF, NF, NF, NF, NF, NF
}
};

