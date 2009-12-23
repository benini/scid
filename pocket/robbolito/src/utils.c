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

#include "robbolito.h"

const int lsb_64_table[64] = {
   63, 30,  3, 32, 59, 14, 11, 33,
   60, 24, 50,  9, 55, 19, 21, 34,
   61, 29,  2, 53, 51, 23, 41, 18,
   56, 28,  1, 43, 46, 27,  0, 35,
   62, 31, 58,  4,  5, 49, 54,  6,
   15, 52, 12, 40,  7, 42, 45, 16,
   25, 57, 48, 13, 10, 39,  8, 44,
   20, 47, 38, 22, 17, 37, 36, 26
};

const char msb_256_table[256] = {
  0, 0, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3,
  4, 4, 4, 4, 4, 4, 4, 4,4, 4, 4, 4,4, 4, 4, 4,
  5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5,
  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
  6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6, 6,
  7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,
  7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 
  7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 
  7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7, 7,   
};

char *move_notation( uint32 move, char *M )
    {
    int di, ai, pr;
    char c[8] = "0123nbrq";
    di = DI(move);
    ai = AI(move);

    if( move == MOVE_NONE )
        {
        M[0] = 'N';
        M[1] = 'U';
        M[2] = M[3] = 'L';
        M[4] = 0;
        return M;
        }
    sprintf(M, "%c%c%c%c", 'a' + (di & 7), '1' + ((di >> 3) & 7), 'a' + (ai & 7), '1' + ((ai >> 3) & 7));

    if( move_promotion(move) )
        {
        pr = (move &flag_hide) >> 12;
        sprintf(M + 4, "%c", c[pr]);
        }
    return M;
    }
static void ERROR_pos( char *x )
    {
    send_msg("error positional: %s\n", x);
//     fflush(stdout);
    }

#include "value.h"

#define PINCH (0x74d3c012a8bf965eull)

void bitboard_initialization()
    {
    int i, b, piece;
    uint64 O;
    border_legitimate = FALSE;

    for ( i = 0; i < 16; i++ )
        POSITION.bitboard[i] = 0;
    DYNAMIC->Zobrist = DYNAMIC->ZobristPawn = 0;
    DYNAMIC->material_ = 0;
    DYNAMIC->statik = 0;

    for ( i = A1; i <= H8; i++ )
        {
        if( (piece = QU[i]) )
            {
            DYNAMIC->statik += static_value[piece][i];
            DYNAMIC->Zobrist ^= ZOBRIST[piece][i];

            if( piece == count_pawn_white || piece == count_pawn_black )
                DYNAMIC->ZobristPawn ^= ZOBRIST[piece][i];
            DYNAMIC->material_ += value_material_[piece];
            bitFIXED(i, POSITION.bitboard[QU[i]]);
            }
        }
    bitboard_occupied_white =
        bitboard_white_king | bitboard_white_queen | bitboard_white_rook | bitboard_white_bishop | bitboard_white_knight
            | bitboard_white_pawn;
    bitboard_occupied_black =
        bitboard_black_king | bitboard_black_queen | bitboard_black_rook | bitboard_black_bishop | bitboard_black_knight
            | bitboard_black_pawn;
    POSITION.occupied_black_white = bitboard_occupied_white | bitboard_occupied_black;
    POSITION.occupied_left90 = POSITION.occupied_left45 = POSITION.occupied_straight45 = 0;
    O = POSITION.occupied_black_white;

    if( POPCNT(bitboard_white_queen) > 1 || POPCNT(bitboard_black_queen) > 1 || POPCNT(bitboard_white_rook) > 2
        || POPCNT(bitboard_black_rook) > 2 || POPCNT(bitboard_white_clear) > 1 || POPCNT(bitboard_black_clear) > 1
        || POPCNT(bitboard_white_knight) > 2 || POPCNT(bitboard_black_knight) > 2 || POPCNT(bitboard_white_dark) > 1
        || POPCNT(bitboard_black_dark) > 1 )
        DYNAMIC->material_ |= 0x80000000;

    if( POPCNT(bitboard_white_king) != 1 )
        ERROR_pos("king white != 1");

    if( POPCNT(bitboard_black_king) != 1 )
        ERROR_pos("king black != 1");

    if( POPCNT(bitboard_white_queen) > 9 )
        ERROR_pos("queen white > 9");

    if( POPCNT(bitboard_black_queen) > 9 )
        ERROR_pos("queen black > 9");

    if( POPCNT(bitboard_white_rook) > 10 )
        ERROR_pos("rook white > 10");

    if( POPCNT(bitboard_black_rook) > 10 )
        ERROR_pos("rook black > 10");

    if( POPCNT(bitboard_white_clear) > 9 )
        ERROR_pos("chiaro white > 9");

    if( POPCNT(bitboard_black_clear) > 9 )
        ERROR_pos("chiaro black > 9");

    if( POPCNT(bitboard_white_dark) > 9 )
        ERROR_pos("dark white > 9");

    if( POPCNT(bitboard_black_dark) > 9 )
        ERROR_pos("dark black > 9");

    if( POPCNT(bitboard_white_clear | bitboard_white_dark) > 10 )
        ERROR_pos("bishop white > 10");

    if( POPCNT(bitboard_black_clear | bitboard_black_dark) > 10 )
        ERROR_pos("bishop black > 10");

    if( POPCNT(bitboard_white_knight) > 10 )
        ERROR_pos("knight white > 10");

    if( POPCNT(bitboard_black_knight) > 10 )
        ERROR_pos("knight black > 10");

    if( POPCNT(bitboard_white_pawn) > 8 )
        ERROR_pos("pawn white > 8");

    if( POPCNT(bitboard_black_pawn) > 8 )
        ERROR_pos("pawn black > 8");

    if( POPCNT(bitboard_occupied_white) > 16 )
        ERROR_pos("piece white > 16");

    if( POPCNT(bitboard_occupied_black) > 16 )
        ERROR_pos("piece black > 16");

    if( (bitboard_white_pawn | bitboard_black_pawn) & (RANK1 | RANK8) )
        ERROR_pos("pawn rank one or eight");

    while( O )
        {
        b = BSF(O);
        bit_FREE(b, O);
        bitFIXED(left90[b], POSITION.occupied_left90);
        bitFIXED(left45[b], POSITION.occupied_left45);
        bitFIXED(straight45[b], POSITION.occupied_straight45);
        }
    POSITION.white_king_square = BSF(bitboard_white_king);
    POSITION.black_king_square = BSF(bitboard_black_king);

    if( (castling_white_oo && (POSITION.white_king_square != E1 || !(bitboard_white_rook &square_fixed[H1])))
        || (castling_white_ooo && (POSITION.white_king_square != E1 || !(bitboard_white_rook &square_fixed[A1])))
            || (castling_black_oo && (POSITION.black_king_square != E8 || !(bitboard_black_rook &square_fixed[H8])))
            || (castling_black_ooo && (POSITION.black_king_square != E8 || !(bitboard_black_rook &square_fixed[A8]))) )
        ERROR_pos("castle illegale");
    DYNAMIC->Zobrist ^= zobrist_oo[DYNAMIC->castle];

    if( DYNAMIC->en_passant )
        DYNAMIC->Zobrist ^= zobrist_ep[DYNAMIC->en_passant & 7];
    DYNAMIC->ZobristPawn ^=
        zobrist_oo[DYNAMIC->castle] ^ PINCH ^ ZOBRIST[count_king_white][POSITION.white_king_square]
            ^ ZOBRIST[count_king_black][POSITION.black_king_square];

    if( POSITION.white_en_move )
        DYNAMIC->Zobrist ^= zobrist_move_white;
    call_value_full(0);

    if( POSITION.white_en_move && DYNAMIC->attak_white & bitboard_black_king )
        ERROR_pos("white capture re");

    if( !POSITION.white_en_move && DYNAMIC->attak_black & bitboard_white_king )
        ERROR_pos("black catture re");
    border_legitimate = TRUE;
    }

#include <unistd.h>
// #include <sys/select.h>
// #include <bits/time.h>
/*
bool question_input()
    {
	int v;
	fd_set s[1];
	struct timeval tv[1];
	FD_ZERO (s);
	FD_SET (STDIN_FILENO, s);
	tv->tv_sec = 0;
	tv->tv_usec = 0;
	v = select (STDIN_FILENO + 1, s, NULL, NULL, tv);
	return (v > 0);
    }
*/
#include <sys/time.h>
uint64 clock_()
    {
	uint64 x;
	struct timeval tv;
	gettimeofday (&tv, NULL);
	x = tv.tv_sec;
	x *= 1000000;
	x += tv.tv_usec;
	return x;
    }

#include <time.h>
inline uint64 process_clock()
    {
	return clock()/CLOCKS_PER_SEC*1000000;
    }

void ERROR_( char *fmt, ... )
	{
	}
void ERROR_fen( char *fmt, ... )
	{
	}

int hole_previous, root_rapid;

void game_new( bool total )
    {
    int i;

    for ( i = A1; i <= H8; i++ )
        QU[i] = 0;
    memset(dynamic_initial, 0, 256 * sizeof(type_dynamic));
    DYNAMIC = dynamic_initial;
    POSITION.white_en_move = TRUE;
    DYNAMIC->castle = 0x0f;
    DYNAMIC->en_passant = 0;
    DYNAMIC->move50 = 0;

    for ( i = A2; i <= H2; i++ )
        QU[i] = count_pawn_white;

    for ( i = A7; i <= H7; i++ )
        QU[i] = count_pawn_black;
    QU[D1] = count_queen_white;
    QU[D8] = count_queen_black;
    QU[E1] = count_king_white;
    QU[E8] = count_king_black;
    QU[A1] = QU[H1] = count_rook_white;
    QU[A8] = QU[H8] = count_rook_black;
    QU[B1] = QU[G1] = count_knight_white;
    QU[B8] = QU[G8] = count_knight_black;
    QU[C1] = count_dark_white;
    QU[F1] = count_clear_white;
    QU[C8] = count_clear_black;
    QU[F8] = count_dark_black;
    hole_previous = 1000;
    root_rapid = FALSE;
    GAME_NEW = TRUE;
    stack_height = 0;
    bitboard_initialization();

    if( !total )
        return;
    zobrist_free();
    value_zobrist_free();
    history_reset();
    gain_reset();
    }

void show_version()
    {
//     char *startup_banner =
//         "" NAME "\n"
//         "" __DATE__ " " __TIME__ "\n"
//         "linux port by unisky\n"
//         "based on a windows version by kranium and sentinel\n\n";
// 
//     printf(startup_banner);
// 	fflush(stdout);
    }
