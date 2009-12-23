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

#ifndef BUILD_MOVE_LEGAL
#define BUILD_MOVE_LEGAL
#include "robbolito.h"
#include "move_legal.c"
#include "white.h"
#else
#include "black.h"
#endif

bool my_ensure( uint32 move )
    {
    int di, ai, piece, capture;
    uint64 cel;
    ai = AI(move);
    cel = square_fixed[ai];
    di = DI(move);
    piece = QU[di];

    if( piece == 0 )
        return FALSE;

    if( your_piece(piece) )
        return FALSE;
    capture = QU[ai];

    if( capture && my_piece(capture) )
        return FALSE;

    if( capture == count_your_king )
        return FALSE;

    if( piece == count_my_pawn )
        {
        if( RANK_EIGHT(ai) && !move_promotion(move) )
            return FALSE;

        if( move_en_passant(move) && ai == DYNAMIC->en_passant && (di == back_left(ai) || di == back_straight(ai)) )
            return TRUE;

        if( di == back_left(ai) || di == back_straight(ai) )
            {
            if( square_fixed[ai] & your_occupied )
                return TRUE;
            return FALSE;
            }

        if( di == back(ai) )
            {
            if( (square_fixed[ai]&POSITION.occupied_black_white) == 0 )
                return TRUE;
            return FALSE;
            }

        if( di != back_two(ai) || RANK(di) != number_rank2 )
            return FALSE;

        if( POSITION.occupied_black_white & square_fixed[forward(di)] )
            return FALSE;
        return TRUE;
        }

    if( piece == count_my_knight )
        {
        if( attack_knight[di] & cel )
            return TRUE;
        return FALSE;
        }

    if( piece == count_my_clear || piece == count_my_dark )
        {
        if( attack_bishop(di) & cel )
            return TRUE;
        return FALSE;
        }

    if( move_castling(move) )
        {
        if( ai == WHITE_G1 )
            {
            if( !castling_oo || POSITION.occupied_black_white & WHITE_F1G1 || your_attack & WHITE_F1G1 )
                return FALSE;
            return TRUE;
            }

        if( ai == WHITE_C1 )
            {
            if( !castling_ooo || POSITION.occupied_black_white & WHITE_B1C1D1 || your_attack & WHITE_C1D1 )
                return FALSE;
            return TRUE;
            }
        }

    if( piece == count_my_rook )
        {
        if( attack_rook(di) & cel )
            return TRUE;
        return FALSE;
        }

    if( piece == count_my_queen )
        {
        if( attack_queen(di) & cel )
            return TRUE;
        return FALSE;
        }

    if( piece == count_my_king )
        {
        if( attack_king[di] & cel && (square_fixed[ai]&your_attack) == 0 )
            return TRUE;
        return FALSE;
        }
    return FALSE;
    }
