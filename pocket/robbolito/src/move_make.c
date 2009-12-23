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
#include "mfa.h"
#include "value.h"

typedef enum
    {
    ooK = 1,
    ooQ = 2,
    ook = 4,
    ooq = 8
    } pile_oo;
typedef enum
    {
    KQkq = ooK | ooQ | ook | ooq,
    Qkq = ooQ | ook | ooq,
    Kkq = ooK | ook | ooq,
    kq = ook | ooq,
    KQk = ooK | ooQ | ook,
    KQ = ooK | ooQ,
    KQq = ooK | ooQ | ooq
    } pile_KQkq;

static const uint64 oo_castling[64] =
    {
     Kkq, KQkq, KQkq, KQkq,   kq, KQkq, KQkq,  Qkq,
	KQkq, KQkq, KQkq, KQkq, KQkq, KQkq, KQkq, KQkq,
	KQkq, KQkq, KQkq, KQkq, KQkq, KQkq, KQkq, KQkq,
	KQkq, KQkq, KQkq, KQkq, KQkq, KQkq, KQkq, KQkq,
	KQkq, KQkq, KQkq, KQkq, KQkq, KQkq, KQkq, KQkq,
	KQkq, KQkq, KQkq, KQkq, KQkq, KQkq, KQkq, KQkq,
	KQkq, KQkq, KQkq, KQkq, KQkq, KQkq, KQkq, KQkq,
	 KQk, KQkq, KQkq, KQkq,   KQ, KQkq, KQkq,  KQq
    };
const static uint64 en_passant_white[8] =
    {
    bitboard_two(B4, B4), bitboard_two(A4, C4), bitboard_two(B4, D4), bitboard_two(C4, E4), bitboard_two(D4, F4),
        bitboard_two(E4, G4), bitboard_two(F4, H4), bitboard_two(G4, G4)
    };
const static uint64 en_passant_black[8] =
    {
    bitboard_two(B5, B5), bitboard_two(A5, C5), bitboard_two(B5, D5), bitboard_two(C5, E5), bitboard_two(D5, F5),
        bitboard_two(E5, G5), bitboard_two(F5, H5), bitboard_two(G5, G5)
    };
static __inline void do_white_castling( int ai )
    {
    if( ai == G1 )
        {
        bitboard_occupied_white ^= F1H1;
        bitboard_white_rook ^= F1H1;
        POSITION.occupied_black_white ^= F1H1;
        POSITION.occupied_left90 ^= F1H1_left90;
        POSITION.occupied_left45 ^= F1H1_left45;
        POSITION.occupied_straight45 ^= F1H1_straight45;
        DYNAMIC->statik += static_value[count_rook_white][F1] - static_value[count_rook_white][H1];
        DYNAMIC->Zobrist ^= ZOBRIST[count_rook_white][F1] ^ ZOBRIST[count_rook_white][H1];
        QU[H1] = 0;
        QU[F1] = count_rook_white;
        }
    else if( ai == C1 )
        {
        bitboard_occupied_white ^= A1D1;
        bitboard_white_rook ^= A1D1;
        POSITION.occupied_black_white ^= A1D1;
        POSITION.occupied_left90 ^= A1D1_left90;
        POSITION.occupied_left45 ^= A1D1_left45;
        POSITION.occupied_straight45 ^= A1D1_straight45;
        DYNAMIC->statik += static_value[count_rook_white][D1] - static_value[count_rook_white][A1];
        DYNAMIC->Zobrist ^= ZOBRIST[count_rook_white][A1] ^ ZOBRIST[count_rook_white][D1];
        QU[A1] = 0;
        QU[D1] = count_rook_white;
        }
    }
static __inline void do_black_castling( int ai )
    {
    if( ai == G8 )
        {
        bitboard_occupied_black ^= F8H8;
        bitboard_black_rook ^= F8H8;
        POSITION.occupied_black_white ^= F8H8;
        POSITION.occupied_left90 ^= F8H8_left90;
        POSITION.occupied_left45 ^= F8H8_left45;
        POSITION.occupied_straight45 ^= F8H8_straight45;
        DYNAMIC->statik += static_value[count_rook_black][F8] - static_value[count_rook_black][H8];
        DYNAMIC->Zobrist ^= ZOBRIST[count_rook_black][F8] ^ ZOBRIST[count_rook_black][H8];
        QU[H8] = 0;
        QU[F8] = count_rook_black;
        }
    else if( ai == C8 )
        {
        bitboard_occupied_black ^= A8D8;
        bitboard_black_rook ^= A8D8;
        POSITION.occupied_black_white ^= A8D8;
        POSITION.occupied_left90 ^= A8D8_left90;
        POSITION.occupied_left45 ^= A8D8_left45;
        POSITION.occupied_straight45 ^= A8D8_straight45;
        DYNAMIC->statik += static_value[count_rook_black][D8] - static_value[count_rook_black][A8];
        DYNAMIC->Zobrist ^= ZOBRIST[count_rook_black][A8] ^ ZOBRIST[count_rook_black][D8];
        QU[A8] = 0;
        QU[D8] = count_rook_black;
        }
    }

const static uint8 promotion_white[8] =
    {
    0, 0, 0, 0, count_knight_white, count_clear_white, count_rook_white, count_queen_white
    };
void do_white( uint32 move )
    {
    int di, ai, piece, pietra, capture, z;
    uint64 cel;
    move_white_number++;

    if( (move_white_number & 4095) == 0 )
        resolve_term(0);
    memcpy(DYNAMIC + 1, DYNAMIC, 32);
    di = DI(move);
    ai = AI(move);
    piece = QU[di];
    DYNAMIC++;
    DYNAMIC->move50++;
    DYNAMIC->move = move;
    pietra = oo_castling[di] & oo_castling[ai] & DYNAMIC->castle;
    DYNAMIC->Zobrist ^= zobrist_oo[DYNAMIC->castle ^ pietra];
    DYNAMIC->ZobristPawn ^= zobrist_oo[DYNAMIC->castle ^ pietra];
    DYNAMIC->castle = pietra;

    if( DYNAMIC->en_passant )
        {
        DYNAMIC->Zobrist ^= zobrist_ep[DYNAMIC->en_passant & 7];
        DYNAMIC->en_passant = 0;
        }
    QU[di] = 0;
    cel = square_free[di];
    bitboard_occupied_white &= cel;
    POSITION.bitboard[piece] &= cel;
    occupied_free(cel, di);
    DYNAMIC->statik += static_value[piece][ai] - static_value[piece][di];
    cel = ZOBRIST[piece][di] ^ ZOBRIST[piece][ai];
    capture = QU[ai];
    DYNAMIC->capture = capture;
    DYNAMIC->Zobrist ^= cel;

    if( piece == count_pawn_white )
        DYNAMIC->ZobristPawn ^= cel;
    POSITION.white_en_move ^= 1;
    DYNAMIC->Zobrist ^= zobrist_move_white;

    if( piece == count_king_white )
        {
        DYNAMIC->ZobristPawn ^= cel;
        POSITION.white_king_square = ai;
        }

    if( capture )
        {
        cel = square_free[ai];
        bitboard_occupied_black &= cel;
        POSITION.bitboard[capture] &= cel;
        DYNAMIC->material_ -= value_material_[capture];
        DYNAMIC->statik -= static_value[capture][ai];

        if( capture == count_pawn_black )
            DYNAMIC->ZobristPawn ^= ZOBRIST[capture][ai];
        DYNAMIC->Zobrist ^= ZOBRIST[capture][ai];
        DYNAMIC->move50 = 0;
        }
    else
        {
        cel = square_fixed[ai];
        occupied_fixed(cel, ai);

        if( move_castling(move) )
            {
            DYNAMIC->move50 = 0;
            do_white_castling(ai);
            }
        }
    QU[ai] = piece;
    bitboard_occupied_white |= square_fixed[ai];
    POSITION.bitboard[piece] |= square_fixed[ai];

    if( piece == count_pawn_white )
        {
        DYNAMIC->move50 = 0;

        if( move_en_passant(move) )
            {
            z = ai ^ 8;
            cel = square_free[z];
            bitboard_occupied_black &= cel;
            bitboard_black_pawn &= cel;
            occupied_free(cel, z);
            DYNAMIC->material_ -= value_material_[count_pawn_black];
            DYNAMIC->statik -= static_value[count_pawn_black][z];
            DYNAMIC->Zobrist ^= ZOBRIST[count_pawn_black][z];
            DYNAMIC->ZobristPawn ^= ZOBRIST[count_pawn_black][z];
            QU[z] = 0;
            }
        else if( move_promotion(move) )
            {
            piece = promotion_white[(move &flag_hide) >> 12];

            if( piece == count_clear_white && square_fixed[ai] & DARK )
                piece = count_dark_white;
            QU[ai] = piece;

            if( POSITION.bitboard[piece] )
                DYNAMIC->material_ |= 0x80000000;
            bitboard_white_pawn &= square_free[ai];
            POSITION.bitboard[piece] |= square_fixed[ai];
            DYNAMIC->material_ += value_material_[piece] - value_material_[count_pawn_white];
            DYNAMIC->statik += static_value[piece][ai] - static_value[count_pawn_white][ai];
            DYNAMIC->Zobrist ^= ZOBRIST[piece][ai] ^ ZOBRIST[count_pawn_white][ai];
            DYNAMIC->ZobristPawn ^= ZOBRIST[count_pawn_white][ai];
            }
        else if( (ai ^ di) == 16 )
            {
            if( en_passant_white[ai & 7] & bitboard_black_pawn )
                {
                z = (di + ai) >> 1;
                DYNAMIC->en_passant = z;
                DYNAMIC->Zobrist ^= zobrist_ep[z & 7];
                }
            }
        }
    STACK[++stack_height] = DYNAMIC->Zobrist;
    }

const static uint8 promotion_black[8] =
    {
    0, 0, 0, 0, count_knight_black, count_clear_black, count_rook_black, count_queen_black
    };
void do_black( uint32 move )
    {
    int di, ai, piece, pietra, capture, z;
    uint64 cel;
    move_black_number++;
    memcpy(DYNAMIC + 1, DYNAMIC, 32);
    di = DI(move);
    ai = AI(move);
    piece = QU[di];
    DYNAMIC++;
    DYNAMIC->move50++;
    DYNAMIC->move = move;
    pietra = oo_castling[di] & oo_castling[ai] & DYNAMIC->castle;
    DYNAMIC->Zobrist ^= zobrist_oo[DYNAMIC->castle ^ pietra];
    DYNAMIC->ZobristPawn ^= zobrist_oo[DYNAMIC->castle ^ pietra];
    DYNAMIC->castle = pietra;

    if( DYNAMIC->en_passant )
        {
        DYNAMIC->Zobrist ^= zobrist_ep[DYNAMIC->en_passant & 7];
        DYNAMIC->en_passant = 0;
        }
    QU[di] = 0;
    cel = square_free[di];
    bitboard_occupied_black &= cel;
    POSITION.bitboard[piece] &= cel;
    occupied_free(cel, di);
    DYNAMIC->statik += static_value[piece][ai] - static_value[piece][di];
    cel = ZOBRIST[piece][di] ^ ZOBRIST[piece][ai];
    capture = QU[ai];
    DYNAMIC->capture = capture;
    DYNAMIC->Zobrist ^= cel;

    if( piece == count_pawn_black )
        DYNAMIC->ZobristPawn ^= cel;
    POSITION.white_en_move ^= 1;
    DYNAMIC->Zobrist ^= zobrist_move_white;

    if( piece == count_king_black )
        {
        DYNAMIC->ZobristPawn ^= cel;
        POSITION.black_king_square = ai;
        }

    if( capture )
        {
        cel = square_free[ai];
        bitboard_occupied_white &= cel;
        POSITION.bitboard[capture] &= cel;
        DYNAMIC->material_ -= value_material_[capture];
        DYNAMIC->statik -= static_value[capture][ai];

        if( capture == count_pawn_white )
            DYNAMIC->ZobristPawn ^= ZOBRIST[capture][ai];
        DYNAMIC->Zobrist ^= ZOBRIST[capture][ai];
        DYNAMIC->move50 = 0;
        }
    else
        {
        cel = square_fixed[ai];
        occupied_fixed(cel, ai);

        if( move_castling(move) )
            {
            DYNAMIC->move50 = 0;
            do_black_castling(ai);
            }
        }
    QU[ai] = piece;
    bitboard_occupied_black |= square_fixed[ai];
    POSITION.bitboard[piece] |= square_fixed[ai];

    if( piece == count_pawn_black )
        {
        DYNAMIC->move50 = 0;

        if( move_en_passant(move) )
            {
            z = ai ^ 8;
            cel = square_free[z];
            bitboard_occupied_white &= cel;
            bitboard_white_pawn &= cel;
            occupied_free(cel, z);
            DYNAMIC->material_ -= value_material_[count_pawn_white];
            DYNAMIC->statik -= static_value[count_pawn_white][z];
            DYNAMIC->Zobrist ^= ZOBRIST[count_pawn_white][z];
            DYNAMIC->ZobristPawn ^= ZOBRIST[count_pawn_white][z];
            QU[z] = 0;
            }
        else if( move_promotion(move) )
            {
            piece = promotion_black[(move &flag_hide) >> 12];

            if( piece == count_clear_black && square_fixed[ai] & DARK )
                piece = count_dark_black;
            QU[ai] = piece;

            if( POSITION.bitboard[piece] )
                DYNAMIC->material_ |= 0x80000000;
            POSITION.bitboard[count_pawn_black] &= square_free[ai];
            POSITION.bitboard[piece] |= square_fixed[ai];
            DYNAMIC->material_ += value_material_[piece] - value_material_[count_pawn_black];
            DYNAMIC->statik += static_value[piece][ai] - static_value[count_pawn_black][ai];
            DYNAMIC->Zobrist ^= ZOBRIST[piece][ai] ^ ZOBRIST[count_pawn_black][ai];
            DYNAMIC->ZobristPawn ^= ZOBRIST[count_pawn_black][ai];
            }
        else if( (ai ^ di) == 16 )
            {
            if( en_passant_black[ai & 7] & bitboard_white_pawn )
                {
                z = (di + ai) >> 1;
                DYNAMIC->en_passant = z;
                DYNAMIC->Zobrist ^= zobrist_ep[z & 7];
                }
            }
        }
    STACK[++stack_height] = DYNAMIC->Zobrist;
    }

void make( uint32 move )
    {
    if( POSITION.white_en_move )
        {
        if( move_white_number & 4095 )
            move_white_number--;
        do_white(move);
        }
    else
        {
        move_black_number--;
        do_black(move);
        }
    }
