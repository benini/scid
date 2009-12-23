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

static __inline void cancel_white_castling( int ai )
    {
    if( ai == G1 )
        {
        bitboard_occupied_white ^= F1H1;
        bitboard_white_rook ^= F1H1;
        QU[F1] = 0;
        QU[H1] = count_rook_white;
        POSITION.occupied_black_white ^= F1H1;
        POSITION.occupied_left90 ^= F1H1_left90;
        POSITION.occupied_left45 ^= F1H1_left45;
        POSITION.occupied_straight45 ^= F1H1_straight45;
        }
    else if( ai == C1 )
        {
        bitboard_occupied_white ^= A1D1;
        bitboard_white_rook ^= A1D1;
        QU[D1] = 0;
        QU[A1] = count_rook_white;
        POSITION.occupied_black_white ^= A1D1;
        POSITION.occupied_left90 ^= A1D1_left90;
        POSITION.occupied_left45 ^= A1D1_left45;
        POSITION.occupied_straight45 ^= A1D1_straight45;
        }
    }
static __inline void cancel_black_castling( int ai )
    {
    if( ai == G8 )
        {
        bitboard_occupied_black ^= F8H8;
        bitboard_black_rook ^= F8H8;
        QU[F8] = 0;
        QU[H8] = count_rook_black;
        POSITION.occupied_black_white ^= F8H8;
        POSITION.occupied_left90 ^= F8H8_left90;
        POSITION.occupied_left45 ^= F8H8_left45;
        POSITION.occupied_straight45 ^= F8H8_straight45;
        }
    else if( ai == C8 )
        {
        bitboard_occupied_black ^= A8D8;
        bitboard_black_rook ^= A8D8;
        QU[D8] = 0;
        QU[A8] = count_rook_black;
        POSITION.occupied_black_white ^= A8D8;
        POSITION.occupied_left90 ^= A8D8_left90;
        POSITION.occupied_left45 ^= A8D8_left45;
        POSITION.occupied_straight45 ^= A8D8_straight45;
        }
    }
void cancel_white( uint32 move )
    {
    int di, ai, piece, capture, z;
    uint64 cel;
    di = DI(move);
    ai = AI(move);
    piece = QU[ai];
    POSITION.white_en_move ^= 1;

    if( move_promotion(move) )
        {
        POSITION.bitboard[piece] &= square_free[ai];
        piece = count_pawn_white;
        }
    QU[di] = piece;
    QU[ai] = DYNAMIC->capture;

    if( piece == count_king_white )
        POSITION.white_king_square = di;
    cel = square_fixed[di];
    bitboard_occupied_white |= cel;
    POSITION.bitboard[piece] |= cel;
    occupied_fixed(cel, di);
    cel = square_free[ai];
    bitboard_occupied_white &= cel;
    POSITION.bitboard[piece] &= cel;
    capture = DYNAMIC->capture;

    if( capture )
        {
        cel = ~cel;
        bitboard_occupied_black |= cel;
        POSITION.bitboard[capture] |= cel;
        }
    else
        {
        occupied_free(cel, ai);

        if( move_castling(move) )
            cancel_white_castling(ai);
        else if( move_en_passant(move) )
            {
            z = ai ^ 8;
            QU[z] = count_pawn_black;
            cel = square_fixed[z];
            bitboard_occupied_black |= cel;
            bitboard_black_pawn |= cel;
            occupied_fixed(cel, z);
            }
        }
    DYNAMIC--;
    stack_height--;
    }
void cancel_black( uint32 move )
    {
    int di, ai, piece, capture, z;
    uint64 cel;
    di = DI(move);
    ai = AI(move);
    piece = QU[ai];
    POSITION.white_en_move ^= 1;

    if( move_promotion(move) )
        {
        POSITION.bitboard[piece] &= square_free[ai];
        piece = count_pawn_black;
        }
    QU[di] = piece;
    QU[ai] = DYNAMIC->capture;

    if( piece == count_king_black )
        POSITION.black_king_square = di;
    cel = square_fixed[di];
    bitboard_occupied_black |= cel;
    POSITION.bitboard[piece] |= cel;
    occupied_fixed(cel, di);
    cel = square_free[ai];
    bitboard_occupied_black &= cel;
    POSITION.bitboard[piece] &= cel;
    capture = DYNAMIC->capture;

    if( capture )
        {
        cel = ~cel;
        bitboard_occupied_white |= cel;
        POSITION.bitboard[capture] |= cel;
        }
    else
        {
        occupied_free(cel, ai);

        if( move_castling(move) )
            cancel_black_castling(ai);
        else if( move_en_passant(move) )
            {
            z = ai ^ 8;
            QU[z] = count_pawn_white;
            cel = square_fixed[z];
            bitboard_occupied_white |= cel;
            bitboard_white_pawn |= cel;
            occupied_fixed(cel, z);
            }
        }
    DYNAMIC--;
    stack_height--;
    }

void cancel( uint32 move )
    {
    if( !POSITION.white_en_move )
        cancel_white(move);
    else
        cancel_black(move);
    }
