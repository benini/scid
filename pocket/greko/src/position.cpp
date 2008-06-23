
#include <assert.h>
#include <stdlib.h>
#include <string.h>
#include "eval.h"
#include "moves.h"
#include "position.h"
#include "utils.h"

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

U64 s_Zobrist0 = 0;
U64 s_Zobrist[64][14];

void clear_pos(Position *pos)
{
	assert (pos != NULL);

	pos->castlings = 0;
	pos->ep = NF;
	pos->fifty = 0;
	pos->hash = 0;
	pos->King[WHITE] = pos->King[BLACK] = 0;
	pos->last_move = 0;
	pos->material[WHITE] = pos->material[BLACK] = 0;
	pos->opp = BLACK;
	pos->ply = 0;
	pos->side = WHITE;
	pos->undo_cnt = 0;

	for (int f = 0; f < 64; f++)
	{
		pos->board[f] = NOPIECE;
	}

	for (int p = 0; p < 14; p++)
	{
		pos->bits[p] = 0;
		pos->count[p] = 0;
	}

	pos->bits[NOPIECE] = BB_ALL;
	pos->bits_all[WHITE] = pos->bits_all[BLACK] = 0;
}
////////////////////////////////////////////////////////////////////////////////

void copy_pos(Position* dest, const Position* src)
{
	*dest = *src;
}
////////////////////////////////////////////////////////////////////////////////

const char* fld_to_str(FLD f)
{
	return FIELD_NAMES[f];
}
////////////////////////////////////////////////////////////////////////////////

void free_pos(Position* pos)
{
	free(pos);
}
////////////////////////////////////////////////////////////////////////////////

U64 get_attacks(const Position* pos, FLD f0, COLOR side)
{
	U64 x = 0, att = 0;
	FLD from = 0;

	if (side == WHITE)
		att |= BB_PAWNB_ATTACKS[f0] & pos->bits[PAWNW];
	else
		att |= BB_PAWNW_ATTACKS[f0] & pos->bits[PAWNB];

	att |= BB_KNIGHT_ATTACKS[f0] & pos->bits[KNIGHTW | side];
	att |= BB_KING_ATTACKS[f0] & pos->bits[KINGW | side];

	U64 blockers = ~pos->bits[NOPIECE];

	x = BB_BISHOP_ATTACKS[f0] & 
	    (pos->bits[QUEENW | side] | pos->bits[BISHOPW | side]);

	while ((from = pop_lsb(x)) != NF)
	{
		if ((BB_BETWEEN[from][f0] & blockers) == 0)
			set_bit(att, from);
	}

	x = BB_ROOK_ATTACKS[f0] & 
	    (pos->bits[QUEENW | side] | pos->bits[ROOKW | side]);

	while ((from = pop_lsb(x)) != NF)
	{
		if ((BB_BETWEEN[from][f0] & blockers) == 0)
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
		PIECE piece = pos->board[f];

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

		if (getcol(f) == 7)
		{
			if (cnt_empty)
				strcat(buf, empty[cnt_empty]);

			if (f != H1)
				strcat(buf, "/");

			cnt_empty = 0;
		}

	}

	if (pos->side == WHITE)
		strcat(buf, " w");
	else
		strcat(buf, " b");

	strcat(buf, " ");
	int no_castlings = 1;

	if (pos->castlings & WHITE_CAN_O_O)
	{
		strcat(buf, "K");
		no_castlings = 0;
	}

	if (pos->castlings & WHITE_CAN_O_O_O)
	{
		strcat(buf, "Q");
		no_castlings = 0;
	}

	if (pos->castlings & BLACK_CAN_O_O)
	{
		strcat(buf, "k");
		no_castlings = 0;
	}

	if (pos->castlings & BLACK_CAN_O_O_O)
	{
		strcat(buf, "q");
		no_castlings = 0;
	}

	if (no_castlings)
		strcat(buf, "-");

	strcat(buf, " ");
	if (pos->ep != NF)
		strcat(buf, fld_to_str(pos->ep));
	else
		strcat(buf, "-");

	char cnt[16];
	sprintf(cnt, " %d %d", pos->fifty, pos->ply / 2 + 1);
	strcat(buf, cnt);

	return buf;
}
////////////////////////////////////////////////////////////////////////////////

int get_repetitions(const Position* pos)
{ 
	int total = 1;

	for (int i = pos->undo_cnt - 1; i >= 0; i--) 
	{
		if (pos->undos[i].hash == pos->hash) 
		{
			total++;
		}

		if (pos->undos[i].mv == 0)
			return 0;

		if (mv_captured(pos->undos[i].mv) != NOPIECE)
			break;

		if (mv_piece(pos->undos[i].mv) == PAWNW)
			break;

		if (mv_piece(pos->undos[i].mv) == PAWNB)
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

int is_attacked(const Position* pos, FLD f0, COLOR side)
{
	U64 x = 0;
	FLD from = 0;

	if (side == WHITE)
	{
		x = BB_PAWNB_ATTACKS[f0] & pos->bits[PAWNW];
		if (x)
			return 1;
	}
	else
	{
		x = BB_PAWNW_ATTACKS[f0] & pos->bits[PAWNB];
		if (x)
			return 1;
	}

	if (pos->count[KNIGHTW | side])
	{
		x = BB_KNIGHT_ATTACKS[f0] & pos->bits[KNIGHTW | side];
		if (x)
			return 1;
	}

	x = BB_KING_ATTACKS[f0] & pos->bits[KINGW | side];
	if (x)
		return 1;

//	U64 blockers = ~pos->bits[NOPIECE];

	if (pos->count[BISHOPW | side] + pos->count[QUEENW | side])
	{
		x = BB_BISHOP_ATTACKS[f0] & 
		    (pos->bits[QUEENW | side] | pos->bits[BISHOPW | side]);

		while ((from = pop_lsb(x)) != NF)
		{
			if ((BB_BETWEEN[from][f0] & ~pos->bits[NOPIECE]) == 0)
				return 1;
		}
	}

	if (pos->count[ROOKW | side] + pos->count[QUEENW | side])
	{
		x = BB_ROOK_ATTACKS[f0] & 
		    (pos->bits[QUEENW | side] | pos->bits[ROOKW | side]);

		while ((from = pop_lsb(x)) != NF)
		{
			if ((BB_BETWEEN[from][f0] & ~pos->bits[NOPIECE]) == 0)
				return 1;
		}
	}

	return 0;
}
////////////////////////////////////////////////////////////////////////////////

int is_draw(const Position* pos)
{
	if (pos->material[WHITE] == 0 && pos->material[BLACK] == 0)
		return 1;

	if (pos->count[PAWNW] || pos->count[PAWNB])
		return 0;

	if (pos->material[WHITE] == 0)
	{
		if (pos->material[BLACK] < VAL_ROOK)
			return 1;
	}

	if (pos->material[BLACK] == 0)
	{
		if (pos->material[WHITE] < VAL_ROOK)
			return 1;
	}

	return 0;
}
////////////////////////////////////////////////////////////////////////////////

int is_in_check(const Position* pos)
{
	return is_attacked(pos, pos->King[pos->side], pos->opp);
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

int make_move(Position* pos, Move mv)
{
	Undo* pundo = &(pos->undos[pos->undo_cnt]);
	pundo->castlings = pos->castlings;
	pundo->ep = pos->ep;
	pundo->fifty = pos->fifty;
	pundo->hash = pos->hash;
	pundo->mv = mv;
	pos->undo_cnt++;

	pos->last_move = mv;

	FLD from = mv_from(mv);
	FLD to = mv_to(mv);
	PIECE piece = mv_piece(mv);
	PIECE captured = mv_captured(mv);
	PIECE promotion = mv_promotion(mv);

	int incorrect_castling = 0;

	assert(piece != NOPIECE);

	COLOR side = getcolor(piece);
	COLOR opp = 1 - side;
	assert(side == pos->side);

	if (captured)
	{
		pos->material[opp] -= VALUE[captured];
		pos->count[captured]--;
	}

	switch (piece)
	{
	case PAWNW:

		pos->fifty = 0;
		remove_piece(pos, from);

		if (to == pos->ep)
		{
			remove_piece(pos, to + 8);
			put_piece(pos, to, PAWNW);
		}
		else
		{
			if (captured)
				remove_piece(pos, to);

			if (promotion == NOPIECE)
				put_piece(pos, to, PAWNW);
			else
			{
				put_piece(pos, to, promotion);
				pos->material[side] += VALUE[promotion] - VALUE[piece];
				pos->count[promotion]++;
				pos->count[piece]--;
			}
		}

		// Set enpassant field:
		if (to - from == - 16)			 // long pawn move
			pos->ep = (FLD) (from - 8);
		else
			pos->ep = NF;

		break;

	case PAWNB:

		pos->fifty = 0;
		remove_piece(pos, from);

		if (to == pos->ep)
		{
			remove_piece(pos, to - 8);
			put_piece(pos, to, PAWNB);
		}
		else
		{
			if (captured)
				remove_piece(pos, to);

			if (promotion == NOPIECE)
				put_piece(pos, to, PAWNB);
			else
			{
				put_piece(pos, to, promotion);
				pos->material[side] += VALUE[promotion] - VALUE[piece];
				pos->count[promotion]++;
				pos->count[piece]--;
			}
		}

		// Set enpassant field:
		if (to - from == 16)			 // long pawn move
			pos->ep = (FLD) (from + 8);
		else
			pos->ep = NF;

		break;

	case KNIGHTW:
	case KNIGHTB:
	case BISHOPW:
	case BISHOPB:
	case ROOKW:
	case ROOKB:
	case QUEENW:
	case QUEENB:

		pos->fifty++;
		pos->ep = NF;

		remove_piece(pos, from);

		if (captured)
		{
			pos->fifty = 0;
			remove_piece(pos, to);
		}

		put_piece(pos, to, piece);

		break;

	case KINGW:

		pos->fifty++;
		pos->ep = NF;

		remove_piece(pos, from);

		if (captured)
		{
			pos->fifty = 0;
			remove_piece(pos, to);
		}
		else if (from == E1)
		{
			if (to == G1)
			{
				remove_piece(pos, H1);
				put_piece(pos, F1, ROOKW);
				pos->castlings |= WHITE_DID_O_O; // 0001 0000

				if (is_attacked(pos, E1, BLACK) ||
					 is_attacked(pos, F1, BLACK) ||
					 is_attacked(pos, G1, BLACK))
					incorrect_castling = 1;
			}
			else if (to == C1)
			{
				remove_piece(pos, A1);
				put_piece(pos, D1, ROOKW);
				pos->castlings |= WHITE_DID_O_O_O; // 0010 0000

				if (is_attacked(pos, E1, BLACK) ||
					 is_attacked(pos, D1, BLACK) ||
					 is_attacked(pos, C1, BLACK))
					incorrect_castling = 1;
			}
		}

		put_piece(pos, to, piece);
		pos->King[WHITE] = to;

		break;

	case KINGB:

		pos->fifty++;
		pos->ep = NF;

		remove_piece(pos, from);

		if (captured)
		{
			pos->fifty = 0;
			remove_piece(pos, to);
		}
		else if (from == E8)
		{
			if (to == G8)
			{
				remove_piece(pos, H8);
				put_piece(pos, F8, ROOKB);
				pos->castlings |= BLACK_DID_O_O; // 0100 0000

				if (is_attacked(pos, E8, WHITE) ||
					 is_attacked(pos, F8, WHITE) ||
					 is_attacked(pos, G8, WHITE))
					incorrect_castling = 1;
			}
			else if (to == C8)
			{
				remove_piece(pos, A8);
				put_piece(pos, D8, ROOKB);
				pos->castlings |= BLACK_DID_O_O_O; // 1000 0000

				if (is_attacked(pos, E8, WHITE) ||
					 is_attacked(pos, D8, WHITE) ||
					 is_attacked(pos, C8, WHITE))
					incorrect_castling = 1;
			}
		}

		put_piece(pos, to, piece);
		pos->King[BLACK] = to;

		break;
	default:
		assert(0);
	}

	pos->castlings &= castling_effect[from];
	pos->castlings &= castling_effect[to];

	pos->ply++;
	pos->side = 1 - pos->side;
	pos->opp = 1 - pos->opp;

	pos->hash ^= s_Zobrist0;
	
	if (is_attacked(pos, pos->King[side], opp))
	{
		unmake_move(pos);
		return 0;
	}

	if (incorrect_castling)
	{
		unmake_move(pos);
		return 0;
	}

	return 1;
}
////////////////////////////////////////////////////////////////////////////////

void make_null_move(Position* pos)
{
	Undo* pundo = &(pos->undos[pos->undo_cnt]);
	pundo->castlings = pos->castlings;
	pundo->ep = pos->ep;
	pundo->fifty = pos->fifty;
	pundo->hash = pos->hash;
	pundo->mv = 0;
	pos->undo_cnt++;

	pos->last_move = 0;

	pos->ep = NF;
	pos->side = 1 - pos->side;
	pos->opp = 1 - pos->opp;

	pos->hash ^= s_Zobrist0;
	pos->ply++;
}
////////////////////////////////////////////////////////////////////////////////

void mirror(Position* pos)
{
	Position* old = new_pos();
	copy_pos(old, pos);

	clear_pos(pos);
	for (int f = 0; f < 64; f++)
	{
		PIECE p = old->board[f];
		if (p == NOPIECE)
			continue;

		put_piece(pos, FLIP[f], p ^ 1);

		if (p == KINGW)
			pos->King[BLACK] = FLIP[f];
		else if (p == KINGB)
			pos->King[WHITE] = FLIP[f];
	}

	pos->side = old->opp;
	pos->opp = old->side;
	pos->fifty = old->fifty;
	if (old->ep != NF)
		pos->ep = FLIP[old->ep];

	pos->ply = old->ply;

	for (int f1 = 0; f1 < 64; f1++)
	{
		PIECE p1 = pos->board[f1];
		COLOR c1 = getcolor(p1);
		if (p1)
		{
			pos->material[c1] += VALUE[p1];
			pos->count[p1]++;
		}
	}

	int bit0 = old->castlings & 0x01;
	int bit1 = (old->castlings & 0x02) >> 1;
	int bit2 = (old->castlings & 0x04) >> 2;
	int bit3 = (old->castlings & 0x08) >> 3;
	int bit4 = (old->castlings & 0x10) >> 4;
	int bit5 = (old->castlings & 0x20) >> 5;
	int bit6 = (old->castlings & 0x40) >> 6;
	int bit7 = (old->castlings & 0x80) >> 7;

	pos->castlings = (bit5 << 7) |
	                 (bit4 << 6) |
	                 (bit7 << 5) |
	                 (bit6 << 4) |
	                 (bit1 << 3) |
	                 (bit0 << 2) |
	                 (bit3 << 1) |
	                 (bit2 << 0);

	free(old);
}
////////////////////////////////////////////////////////////////////////////////

U32 pawn_hash(const Position* pos)
{
	return (U32) (pos->hash >> 32);
}
////////////////////////////////////////////////////////////////////////////////

void print_attacks(const Position* pos)
{
	int row = 0, col = 0;

	out("\n");
	for (row = 0; row < 8; row++)
	{
		for (col = 0; col < 8; col++)
		{
			U64 att = get_attacks(pos, 8 * row + col, WHITE);
			int n = count_bits(att);

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
			U64 att = get_attacks(pos, 8 * row + col, BLACK);
			int n = count_bits(att);

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

void print_pos(const Position* pos)
{
	out("\n");
	for (int f = 0; f < 64; f++)
	{
		char sym = '-';
		PIECE piece = pos->board[f];
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

		if (getcol(f) == 7)
			out("\n");
	}

	if (pos->undo_cnt)
	{
		out("\n ");
		for (int m = 0; m < pos->undo_cnt; m++)
		{
			char buf1[16];
			OUT1("%s ", move_to_str(pos->undos[m].mv, buf1));
		}
		out("\n ");
	}
	out("\n");
}
////////////////////////////////////////////////////////////////////////////////

Position *new_pos()
{
	//
	//   Constructor
	//

	Position *pos = new Position();
	clear_pos(pos);

	return pos;
}
////////////////////////////////////////////////////////////////////////////////

void put_piece(Position* pos, FLD f, PIECE p)
{
	assert(f <= H1);
	assert(p != NOPIECE);
	assert(pos->board[f] == NOPIECE);

	pos->board[f] = p;
	set_bit(pos->bits[p], f);
	clear_bit(pos->bits[NOPIECE], f);
	set_bit(pos->bits_all[getcolor(p)], f);

	pos->hash ^= s_Zobrist[f][p];
}
////////////////////////////////////////////////////////////////////////////////

void remove_piece(Position* pos, FLD f)
{
	assert(f <= H1);
	PIECE p = pos->board[f];
	assert(p != NOPIECE);

	pos->board[f] = NOPIECE;
	clear_bit(pos->bits[p], f);
	set_bit(pos->bits[NOPIECE], f);
	clear_bit(pos->bits_all[getcolor(p)], f);

	pos->hash ^= s_Zobrist[f][p];
}
////////////////////////////////////////////////////////////////////////////////

int set_fen(Position* pos, const char* fen)
{
	if (strlen(fen) < 5)
		return 0;

	clear_pos(pos);

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
		case 'K': piece = KINGW; pos->King[WHITE] = f; break;
		case 'k': piece = KINGB; pos->King[BLACK] = f; break;

		case '1': f += 1; break;
		case '2': f += 2; break;
		case '3': f += 3; break;
		case '4': f += 4; break;
		case '5': f += 5; break;
		case '6': f += 6; break;
		case '7': f += 7; break;
		case '8': f += 8; break;

		case '/':
			if (getcol(f) != 0)
				f = 8 * (getrow(f) + 1);
			break;

		default:
			break;
		}

		if (piece)
		{
			put_piece(pos, f, piece);
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
	{
		pos->side = WHITE;
		pos->opp = BLACK;
	}
	else if (token[0] == 'b')
	{
		pos->side = BLACK;
		pos->opp = WHITE;
	}
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

	pos->castlings = 0;

	if (strstr(token, "K") != NULL)	
		pos->castlings |= WHITE_CAN_O_O;

	if (strstr(token, "Q") != NULL)	
		pos->castlings |= WHITE_CAN_O_O_O;
		
	if (strstr(token, "k") != NULL)	
		pos->castlings |= BLACK_CAN_O_O;
		
	if (strstr(token, "q") != NULL)	
		pos->castlings |= BLACK_CAN_O_O_O;

	//
	//   4. En-passant
	//

	token = strtok(NULL, " ");
	if (token == NULL)
		goto FINALIZE_SETFEN;

	pos->ep = str_to_fld(token);

	//
	//   5. Counters
	//

	token = strtok(NULL, " ");
	if (token == NULL)
		goto FINALIZE_SETFEN;

	pos->fifty = atoi(token);
	if (pos->fifty < 0)
		pos->fifty = 0;

	token = strtok(NULL, " ");
	if (token == NULL)
		goto FINALIZE_SETFEN;

	pos->ply = (atoi(token) - 1) * 2;
	if (pos->side == BLACK)
		pos->ply++;

	if (pos->ply < 0)
		pos->ply = 0;

FINALIZE_SETFEN:

	for (int f1 = 0; f1 < 64; f1++)
	{
		PIECE p1 = pos->board[f1];
		COLOR c1 = getcolor(p1);
		if (p1)
		{
			pos->material[c1] += VALUE[p1];
			pos->count[p1]++;
		}
	}

	return 1;
}
////////////////////////////////////////////////////////////////////////////////

void set_initial(Position* pos)
{
	set_fen(pos, "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1");
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

	PIECE piece = pos->board[from];
	if (!piece)
		return 0;

	PIECE captured = pos->board[to];
	if (to == pos->ep)
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
			promotion = QUEENW | getcolor(piece);
			break;
		case 'r' :
			promotion = ROOKW | getcolor(piece);
			break;
		case 'b' :
			promotion = BISHOPW | getcolor(piece);
			break;
		case 'n' :
			promotion = KNIGHTW | getcolor(piece);
			break;
		default:
			return 0;
		}
	}

	return mv_compose(from, to, piece, captured, promotion);
}
////////////////////////////////////////////////////////////////////////////////

void unmake_move(Position* pos)
{
	if (pos->undo_cnt <= 0)
		return;

	pos->undo_cnt--;
	Undo* pundo = &(pos->undos[pos->undo_cnt]);
	Move mv = pundo->mv;

	pos->ep = pundo->ep;
	pos->castlings = pundo->castlings;
	pos->fifty = pundo->fifty;
// pos->hash = pundo->hash; -- will be restored automatically with put_piece(pos, ) and RemovePiece()

	FLD from = mv_from(mv);
	FLD to = mv_to(mv);
	PIECE piece = mv_piece(mv);
	PIECE captured = mv_captured(mv);
	PIECE promotion = mv_promotion(mv);
	
	pos->ply--;
	pos->side = 1 - pos->side;
	pos->opp = 1 - pos->opp;

	pos->hash ^= s_Zobrist0;

	COLOR who_moved = pos->side;
	COLOR who_not_moved = pos->opp;

	if (captured)
	{
		pos->material[who_not_moved] += VALUE[captured];
		pos->count[captured]++;
	}

	if (promotion)
	{
		pos->material[who_moved] -= (VALUE[promotion] - VALUE[piece]);
		pos->count[promotion]--;
		pos->count[piece]++;
	}
	
	if (piece == KINGW)
	{
		pos->King[WHITE] = from;

		if (from == E1 && to == G1)
		{
			remove_piece(pos, G1);
			remove_piece(pos, F1);
			put_piece(pos, E1, KINGW);
			put_piece(pos, H1, ROOKW);
		}
		else if (from == E1 && to == C1)
		{
			remove_piece(pos, C1);
			remove_piece(pos, D1);
			put_piece(pos, E1, KINGW);
			put_piece(pos, A1, ROOKW);
		}
		else
		{
			remove_piece(pos, to);
			put_piece(pos, from, piece);

			if (captured)
				put_piece(pos, to, captured);
		}
	}
	else if (piece == KINGB)
	{
		pos->King[BLACK] = from;

		if (from == E8 && to == G8)
		{
			remove_piece(pos, G8);
			remove_piece(pos, F8);
			put_piece(pos, E8, KINGB);
			put_piece(pos, H8, ROOKB);
		}
		else if (from == E8 && to == C8)
		{
			remove_piece(pos, C8);
			remove_piece(pos, D8);
			put_piece(pos, E8, KINGB);
			put_piece(pos, A8, ROOKB);
		}
		else
		{
			remove_piece(pos, to);
			put_piece(pos, from, piece);

			if (captured)
				put_piece(pos, to, captured);
		}
	}
	else if (piece == PAWNW && to == pos->ep)
	{
		remove_piece(pos, to);
		put_piece(pos, from, PAWNW);
		put_piece(pos, (FLD) (to + 8), PAWNB);
	}
	else if (piece == PAWNB && to == pos->ep)
	{
		remove_piece(pos, to);
		put_piece(pos, from, PAWNB);
		put_piece(pos, (FLD) (to - 8), PAWNW);
	}
	else
	{
		remove_piece(pos, to);
		put_piece(pos, from, piece);

		if (captured)
			put_piece(pos, to, captured);
	}
}
////////////////////////////////////////////////////////////////////////////////

void unmake_null_move(Position* pos)
{
	if (pos->undo_cnt <= 0)
		return;

	pos->undo_cnt--;
	Undo* pundo = &(pos->undos[pos->undo_cnt]);

	pos->ep = pundo->ep;
	pos->castlings = pundo->castlings;
	pos->fifty = pundo->fifty;

	pos->side = 1 - pos->side;
	pos->opp = 1 - pos->opp;
	pos->hash ^= s_Zobrist0;

	pos->ply--;
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

