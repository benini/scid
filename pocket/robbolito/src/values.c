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

#define queen_endgame 1
#define rook_endgame 2
#define bishop_opposite_endgame 3
#define bishop_endgame 4
#define knight_endgame 5
#define bishop_knight_endgame 6
#define pawn_endgame 7
#define white_minor_flag 8
#define black_minor_flag 16
#define bishop_knight_mate 32

static int flags_initialization( int white_pawn, int white_knight, int white_bishop, int white_clear, int white_dark,
    int white_rook, int white_queen, int black_pawn, int black_knight, int black_bishop, int black_clear,
    int black_dark, int black_rook, int black_queen )
    {
    uint8 FLAGS =
        ((white_knight || white_bishop || white_queen || white_rook) << 1)
            | ((black_knight || black_bishop || black_queen || black_rook) << 0);

    if( !white_queen && !white_rook && white_bishop + white_knight == 1 && white_pawn <= 4 && black_pawn <= 4 )
        FLAGS &= 1;

    if( !black_queen && !black_rook && black_bishop + black_knight == 1 && white_pawn <= 4 && black_pawn <= 4 )
        FLAGS &= 2;

    if( white_queen == 1 && black_queen == 1 && !white_rook && !black_rook && !white_bishop && !black_bishop
        && !white_knight && !black_knight )
        FLAGS |= queen_endgame << 2;

    if( white_rook == 1 && black_rook == 1 && !white_queen && !black_queen && !white_bishop && !black_bishop
        && !white_knight && !black_knight )
        FLAGS |= rook_endgame << 2;

    if( white_bishop == 1 && black_bishop == 1 && !white_queen && !black_queen && !white_rook && !black_rook
        && !white_knight && !black_knight )
        {
        if( (white_clear == 1 && black_dark == 1) || (white_dark == 1 && black_clear == 1) )
            FLAGS |= bishop_endgame << 2;
        else
            FLAGS |= bishop_opposite_endgame << 2;
        FLAGS |= (white_minor_flag | black_minor_flag) << 2;
        }

    if( white_knight == 1 && black_knight == 1 && !white_queen && !black_queen && !white_rook && !black_rook
        && !white_bishop && !black_bishop )
        FLAGS |= knight_endgame << 2;

    if( white_knight == 1 && black_bishop == 1 && !white_queen && !black_queen && !white_rook && !black_rook
        && !white_bishop && !black_knight )
        FLAGS |= bishop_knight_endgame << 2;

    if( white_bishop == 1 && black_knight == 1 && !white_queen && !black_queen && !white_rook && !black_rook
        && !black_bishop && !white_knight )
        FLAGS |= bishop_knight_endgame << 2;

    if( white_bishop == 1 && !white_queen && !white_rook && !white_knight )
        FLAGS |= white_minor_flag << 2;

    if( black_bishop == 1 && !black_queen && !black_rook && !black_knight )
        FLAGS |= black_minor_flag << 2;

    if( white_knight == 1 && !white_queen && !white_rook && !white_bishop )
        FLAGS |= white_minor_flag << 2;

    if( black_knight == 1 && !black_queen && !black_rook && !black_bishop )
        FLAGS |= black_minor_flag << 2;

    if( !white_knight && !white_bishop && !white_rook && !white_queen && !black_knight && !black_bishop && !black_queen
        && !black_queen && white_pawn
        + black_pawn == 1 )
        FLAGS |= pawn_endgame << 2;

    if( white_knight == 1 && white_bishop == 1 && !white_rook && !white_queen && !white_pawn && !black_queen
        && !black_rook && !black_bishop && !black_knight && !black_pawn )
        FLAGS |= bishop_knight_mate << 2;

    if( black_knight == 1 && black_bishop == 1 && !black_rook && !black_queen && !black_pawn && !white_queen
        && !white_rook && !white_bishop && !white_knight && !white_pawn )
        FLAGS |= bishop_knight_mate << 2;
    return FLAGS;
    }

static int sengo_initialization( int white_pawn, int white_knight, int white_bishop, int white_clear, int white_dark,
    int white_rook, int white_queen, int black_pawn, int black_knight, int black_bishop, int black_clear,
    int black_dark, int black_rook, int black_queen )
    {
    int sign = 0x80;

    if( white_knight == 0 && black_knight == 0 && white_bishop == 0 && black_bishop == 0 && white_rook == 0
        && black_rook == 0 && white_queen == 1 && black_queen == 1 )
        sign = 0x70 + MAXIMUM(white_pawn, black_pawn);

    if( white_knight == 0 && black_knight == 0 && white_bishop == 0 && black_bishop == 0 && white_queen == 0
        && black_queen == 0 && white_rook == 1 && black_rook == 1 )
        sign = 0x60 + 2 * MAXIMUM(white_pawn, black_pawn);

    if( white_knight == 0 && black_knight == 0 && white_rook == 0 && black_rook == 0 && white_queen == 0
        && black_queen == 0 && white_bishop == 1 && black_bishop == 1 )
        {
        if( (white_clear == 1 && white_dark == 0 && black_clear == 0 && black_dark == 1)
            || (white_clear == 0 && white_dark == 1 && black_clear == 1 && black_dark == 0) )
            sign = 0x30 + 4 * MAXIMUM(white_pawn, black_pawn);
        else
            sign = 0x78 + 2 * MAXIMUM(white_pawn, black_pawn);
        }

    if( white_knight == 1 && black_knight == 1 && white_rook == 0 && black_rook == 0 && white_queen == 0
        && black_queen == 0 && white_bishop == 0 && black_bishop == 0 )
        sign = 0x80 + MAXIMUM(white_pawn, black_pawn);

    if( white_knight == 0 && black_knight == 0 && white_rook == 0 && black_rook == 0 && white_queen == 0
        && black_queen == 0 && white_bishop == 0 && black_bishop == 0 )
        sign = 0xc0 - 8 * MAXIMUM(white_pawn, black_pawn);

    if( white_knight == 0 && black_knight == 0 && white_bishop == 1 && black_bishop == 1 && white_queen == 0
        && black_queen == 0 && white_rook == 1 && black_rook == 1 )
        {
        if( (white_clear == 1 && white_dark == 0 && black_clear == 0 && black_dark == 1)
            || (white_clear == 0 && white_dark == 1 && black_clear == 1 && black_dark == 0) )
            sign = 0x70 + MAXIMUM(white_pawn, black_pawn);
        }
    return sign;
    }

static int load_white( int white_pawn, int white_knight, int white_bishop, int white_clear, int white_dark,
    int white_rook, int white_queen, int black_pawn, int black_knight, int black_bishop, int black_clear,
    int black_dark, int black_rook, int black_queen )
    {
    int white_minor, black_minor, white_phase, black_phase, white_load, white_value, black_value;
    white_minor = white_bishop + white_knight;
    black_minor = black_bishop + black_knight;
    white_phase = white_minor + 2 * white_rook + 4 * white_queen;
    black_phase = black_minor + 2 * black_rook + 4 * black_queen;
    white_value = 3 * (white_bishop + white_knight) + 5 * white_rook + 9 * white_queen;
    black_value = 3 * (black_bishop + black_knight) + 5 * black_rook + 9 * black_queen;
    white_load = 10;

    if( !white_pawn )
        {
        if( white_phase == 1 )
            white_load = 0;

        if( white_phase == 2 )
            {
            if( black_phase == 0 )
                {
                if( white_knight == 2 )
                    {
                    if( black_pawn >= 1 )
                        white_load = 3;
                    else
                        white_load = 0;
                    }
                }

            if( black_phase == 1 )
                {
                white_load = 1;

                if( white_bishop == 2 && black_knight == 1 )
                    white_load = 8;

                if( white_rook == 1 && black_knight == 1 )
                    white_load = 2;
                }

            if( black_phase == 2 )
                white_load = 1;
            }

        if( white_phase == 3 && white_rook == 1 )
            {
            if( black_phase == 2 && black_rook == 1 )
                {
                if( white_knight == 1 )
                    white_load = 1;

                if( white_bishop == 1 )
                    white_load = 1;
                }

            if( black_phase == 2 && black_rook == 0 )
                {
                white_load = 2;

                if( white_bishop == 1 && black_knight == 2 )
                    white_load = 6;

                if( black_knight == 1
                    && ((white_clear == 1 && black_clear == 1) || (white_dark == 1 && black_dark == 1)) )
                    white_load = 2;

                if( black_knight == 1
                    && ((white_dark == 1 && black_clear == 1) || (white_clear == 1 && black_dark == 1)) )
                    white_load = 7;
                }

            if( black_phase == 3 )
                white_load = 2;
            }

        if( white_phase == 3 && white_rook == 0 )
            {
            if( black_phase == 2 && black_rook == 1 )
                {
                if( white_knight == 2 )
                    white_load = 2;

                if( white_bishop == 2 )
                    white_load = 7;
                }

            if( black_phase == 2 && black_rook == 0 )
                {
                white_load = 2;

                if( white_bishop == 2 && black_knight == 2 )
                    white_load = 4;
                }

            if( black_phase == 3 )
                white_load = 2;
            }

        if( white_phase == 4 && white_queen )
            {
            if( black_phase == 2 && black_knight == 2 )
                white_load = 2;

            if( black_phase == 2 && black_knight == 1 )
                white_load = 8;

            if( black_phase == 2 && black_knight == 0 )
                white_load = 7;

            if( black_phase == 3 )
                white_load = 1;

            if( black_phase == 4 )
                white_load = 1;
            }

        if( white_phase == 4 && white_rook == 2 )
            {
            if( black_phase == 2 && black_rook == 0 )
                white_load = 7;

            if( black_phase == 3 )
                white_load = 2;

            if( black_phase == 4 )
                white_load = 1;
            }

        if( white_phase == 4 && white_rook == 1 )
            {
            if( black_phase == 3 && black_rook == 1 )
                white_load = 3;

            if( black_phase == 3 && black_rook == 0 )
                white_load = 2;

            if( black_phase == 4 )
                white_load = 2;
            }

        if( white_phase == 4 && white_rook == 0 && white_queen == 0 )
            {
            if( black_phase == 3 && black_rook == 1 )
                white_load = 4;

            if( black_phase == 3 && black_rook == 0 )
                white_load = 2;

            if( black_phase == 4 && black_queen )
                white_load = 8;

            if( black_phase == 4 && black_queen == 0 )
                white_load = 1;
            }

        if( white_phase == 5 && white_queen )
            {
            if( black_phase == 4 )
                white_load = 2;

            if( black_phase == 5 )
                white_load = 1;

            if( black_phase == 4 && black_rook == 2 )
                {
                if( white_knight )
                    white_load = 3;

                if( white_bishop )
                    white_load = 7;
                }

            if( black_phase == 5 )
                white_load = 1;
            }

        if( white_phase == 5 && white_rook == 1 )
            {
            if( black_phase == 4 && black_queen )
                white_load = 9;

            if( black_phase == 4 && black_rook == 2 )
                white_load = 7;

            if( black_phase == 4 && black_rook == 1 )
                white_load = 3;

            if( black_phase == 4 && black_queen == 0 && black_rook == 0 )
                white_load = 1;

            if( black_phase == 5 )
                white_load = 2;
            }

        if( white_phase == 5 && white_rook == 2 )
            {
            if( black_phase == 4 && black_queen && white_bishop == 1 )
                white_load = 8;

            if( black_phase == 4 && black_queen && white_knight == 1 )
                white_load = 7;

            if( black_phase == 4 && black_rook == 2 )
                white_load = 3;

            if( black_phase == 4 && black_rook == 1 )
                white_load = 2;

            if( black_phase == 4 && black_queen == 0 && black_rook == 0 )
                white_load = 1;

            if( black_phase == 5 )
                white_load = 1;
            }

        if( white_phase == 6 && white_queen && white_rook )
            {
            if( black_phase == 4 && black_queen == 0 && black_rook == 0 )
                white_load = 2;

            if( black_phase == 5 && black_queen )
                white_load = 1;

            if( black_phase == 4 && black_rook == 1 )
                white_load = 6;

            if( black_phase == 4 && black_rook == 2 )
                white_load = 3;

            if( black_phase == 5 && black_rook )
                white_load = 1;

            if( black_phase == 6 )
                white_load = 1;
            }

        if( white_phase == 6 && white_queen && white_rook == 0 )
            {
            if( black_phase == 4 && black_queen == 0 && black_rook == 0 )
                white_load = 5;

            if( black_phase == 5 && black_queen )
                white_load = 2;

            if( black_phase == 5 && black_rook == 2 )
                white_load = 2;

            if( black_phase == 5 && black_rook == 1 )
                white_load = 1;

            if( black_phase == 6 )
                white_load = 1;
            }

        if( white_phase == 6 && white_queen == 0 && white_rook == 2 )
            {
            if( black_phase == 5 && black_queen )
                white_load = 7;

            if( black_phase == 5 && black_rook == 1 )
                white_load = 1;

            if( black_phase == 5 && black_rook == 2 )
                white_load = 2;

            if( black_phase == 6 )
                white_load = 1;
            }

        if( white_phase == 6 && white_queen == 0 && white_rook == 1 )
            {
            if( black_phase == 5 && black_queen )
                white_load = 9;

            if( black_phase == 5 && black_rook == 2 )
                white_load = 3;

            if( black_phase == 5 && black_rook == 1 )
                white_load = 2;

            if( black_phase == 6 )
                white_load = 1;

            if( black_phase == 6 && black_queen )
                white_load = 2;

            if( black_phase == 6 && black_queen && black_rook )
                white_load = 4;
            }

        if( white_phase >= 7 )
            {
            if( white_value > black_value + 4 )
                white_load = 9;

            if( white_value == black_value + 4 )
                white_load = 7;

            if( white_value == black_value + 3 )
                white_load = 4;

            if( white_value == black_value + 2 )
                white_load = 2;

            if( white_value < black_value + 2 )
                white_load = 1;
            }
        }

    if( white_pawn == 1 )
        {
        if( black_phase == 1 )
            {
            if( white_phase == 1 )
                white_load = 3;

            if( white_phase == 2 && white_knight == 2 )
                {
                if( black_pawn == 0 )
                    white_load = 3;
                else
                    white_load = 5;
                }

            if( white_phase == 2 && white_rook == 1 )
                white_load = 7;
            }

        if( black_phase == 2 && black_rook == 1 && white_phase == 2 && white_rook == 1 )
            white_load = 8;

        if( black_phase == 2 && black_rook == 0 && white_phase == 2 )
            white_load = 4;

        if( black_phase >= 3 && black_minor > 0 && white_phase == black_phase )
            white_load = 3;

        if( black_phase >= 3 && black_minor == 0 && white_phase == black_phase )
            white_load = 5;

        if( black_phase == 4 && black_queen == 1 && white_phase == black_phase )
            white_load = 7;
        }
    return white_load;
    }

static int load_black( int white_pawn, int white_knight, int white_bishop, int white_clear, int white_dark,
    int white_rook, int white_queen, int black_pawn, int black_knight, int black_bishop, int black_clear,
    int black_dark, int black_rook, int black_queen )
    {
    int white_minor, black_minor, white_phase, black_phase, black_load, white_value, black_value;
    white_minor = white_bishop + white_knight;
    black_minor = black_bishop + black_knight;
    white_phase = white_minor + 2 * white_rook + 4 * white_queen;
    black_phase = black_minor + 2 * black_rook + 4 * black_queen;
    white_value = 3 * (white_bishop + white_knight) + 5 * white_rook + 9 * white_queen;
    black_value = 3 * (black_bishop + black_knight) + 5 * black_rook + 9 * black_queen;
    black_load = 10;

    if( !black_pawn )
        {
        if( black_phase == 1 )
            black_load = 0;

        if( black_phase == 2 )
            {
            if( white_phase == 0 )
                {
                if( black_knight == 2 )
                    {
                    if( black_pawn >= 1 )
                        black_load = 3;
                    else
                        black_load = 0;
                    }
                }

            if( white_phase == 1 )
                {
                black_load = 1;

                if( black_bishop == 2 && white_knight == 1 )
                    black_load = 8;

                if( black_rook == 1 && white_knight == 1 )
                    black_load = 2;
                }

            if( white_phase == 2 )
                black_load = 1;
            }

        if( black_phase == 3 && black_rook == 1 )
            {
            if( white_phase == 2 && white_rook == 1 )
                {
                if( black_knight == 1 )
                    black_load = 1;

                if( black_bishop == 1 )
                    black_load = 1;
                }

            if( white_phase == 2 && white_rook == 0 )
                {
                black_load = 2;

                if( black_bishop == 1 && white_knight == 2 )
                    black_load = 6;

                if( white_knight == 1
                    && ((black_clear == 1 && white_clear == 1) || (black_dark == 1 && white_dark == 1)) )
                    black_load = 2;

                if( white_knight == 1
                    && ((black_dark == 1 && white_clear == 1) || (black_clear == 1 && white_dark == 1)) )
                    black_load = 7;
                }

            if( white_phase == 3 )
                black_load = 2;
            }

        if( black_phase == 3 && black_rook == 0 )
            {
            if( white_phase == 2 && white_rook == 1 )
                {
                if( black_knight == 2 )
                    black_load = 2;

                if( black_bishop == 2 )
                    black_load = 7;
                }

            if( white_phase == 2 && white_rook == 0 )
                {
                black_load = 2;

                if( black_bishop == 2 && white_knight == 2 )
                    black_load = 4;
                }

            if( white_phase == 3 )
                black_load = 2;
            }

        if( black_phase == 4 && black_queen )
            {
            if( white_phase == 2 && white_knight == 2 )
                black_load = 2;

            if( white_phase == 2 && white_knight == 1 )
                black_load = 8;

            if( white_phase == 2 && white_knight == 0 )
                black_load = 7;

            if( white_phase == 3 )
                black_load = 1;

            if( white_phase == 4 )
                black_load = 1;
            }

        if( black_phase == 4 && black_rook == 2 )
            {
            if( white_phase == 2 && white_rook == 0 )
                black_load = 7;

            if( white_phase == 3 )
                black_load = 2;

            if( white_phase == 4 )
                black_load = 1;
            }

        if( black_phase == 4 && black_rook == 1 )
            {
            if( white_phase == 3 && white_rook == 1 )
                black_load = 3;

            if( white_phase == 3 && white_rook == 0 )
                black_load = 2;

            if( white_phase == 4 )
                black_load = 2;
            }

        if( black_phase == 4 && black_rook == 0 && black_queen == 0 )
            {
            if( white_phase == 3 && white_rook == 1 )
                black_load = 4;

            if( white_phase == 3 && white_rook == 0 )
                black_load = 2;

            if( white_phase == 4 && white_queen )
                black_load = 8;

            if( white_phase == 4 && white_queen == 0 )
                black_load = 1;
            }

        if( black_phase == 5 && black_queen )
            {
            if( white_phase == 4 )
                black_load = 2;

            if( white_phase == 5 )
                black_load = 1;

            if( white_phase == 4 && white_rook == 2 )
                {
                if( black_knight )
                    black_load = 3;

                if( black_bishop )
                    black_load = 7;
                }

            if( white_phase == 5 )
                black_load = 1;
            }

        if( black_phase == 5 && black_rook == 1 )
            {
            if( white_phase == 4 && white_queen )
                black_load = 9;

            if( white_phase == 4 && white_rook == 2 )
                black_load = 7;

            if( white_phase == 4 && white_rook == 1 )
                black_load = 3;

            if( white_phase == 4 && white_queen == 0 && white_rook == 0 )
                black_load = 1;

            if( white_phase == 5 )
                black_load = 2;
            }

        if( black_phase == 5 && black_rook == 2 )
            {
            if( white_phase == 4 && white_queen && black_bishop == 1 )
                black_load = 8;

            if( white_phase == 4 && white_queen && black_knight == 1 )
                black_load = 7;

            if( white_phase == 4 && white_rook == 2 )
                black_load = 3;

            if( white_phase == 4 && white_rook == 1 )
                black_load = 2;

            if( white_phase == 4 && white_queen == 0 && white_rook == 0 )
                black_load = 1;

            if( white_phase == 5 )
                black_load = 1;
            }

        if( black_phase == 6 && black_queen && black_rook )
            {
            if( white_phase == 4 && white_queen == 0 && white_rook == 0 )
                black_load = 2;

            if( white_phase == 5 && white_queen )
                black_load = 1;

            if( white_phase == 4 && white_rook == 1 )
                black_load = 6;

            if( white_phase == 4 && white_rook == 2 )
                black_load = 3;

            if( white_phase == 5 && white_rook )
                black_load = 1;

            if( white_phase == 6 )
                black_load = 1;
            }

        if( black_phase == 6 && black_queen && black_rook == 0 )
            {
            if( white_phase == 4 && white_queen == 0 && white_rook == 0 )
                black_load = 5;

            if( white_phase == 5 && white_queen )
                black_load = 2;

            if( white_phase == 5 && white_rook == 2 )
                black_load = 2;

            if( white_phase == 5 && white_rook == 1 )
                black_load = 1;

            if( white_phase == 6 )
                black_load = 1;
            }

        if( black_phase == 6 && black_queen == 0 && black_rook == 2 )
            {
            if( white_phase == 5 && white_queen )
                black_load = 7;

            if( white_phase == 5 && white_rook == 1 )
                black_load = 1;

            if( white_phase == 5 && white_rook == 2 )
                black_load = 2;

            if( white_phase == 6 )
                black_load = 1;
            }

        if( black_phase == 6 && black_queen == 0 && black_rook == 1 )
            {
            if( white_phase == 5 && white_queen )
                black_load = 9;

            if( white_phase == 5 && white_rook == 2 )
                black_load = 3;

            if( white_phase == 5 && white_rook == 1 )
                black_load = 2;

            if( white_phase == 6 )
                black_load = 1;

            if( white_phase == 6 && white_queen )
                black_load = 2;

            if( white_phase == 6 && white_queen && white_rook )
                black_load = 4;
            }

        if( black_phase >= 7 )
            {
            if( black_value > white_value + 4 )
                black_load = 9;

            if( black_value == white_value + 4 )
                black_load = 7;

            if( black_value == white_value + 3 )
                black_load = 4;

            if( black_value == white_value + 2 )
                black_load = 2;

            if( black_value < white_value + 2 )
                black_load = 1;
            }
        }

    if( black_pawn == 1 )
        {
        if( white_phase == 1 )
            {
            if( black_phase == 1 )
                black_load = 3;

            if( black_phase == 2 && black_knight == 2 )
                {
                if( white_pawn == 0 )
                    black_load = 3;
                else
                    black_load = 5;
                }

            if( black_phase == 2 && black_rook == 1 )
                black_load = 7;
            }

        if( white_phase == 2 && white_rook == 1 && black_phase == 2 && black_rook == 1 )
            black_load = 8;

        if( white_phase == 2 && white_rook == 0 && black_phase == 2 )
            black_load = 4;

        if( white_phase >= 3 && white_minor > 0 && black_phase == white_phase )
            black_load = 3;

        if( white_phase >= 3 && white_minor == 0 && black_phase == white_phase )
            black_load = 5;

        if( white_phase == 4 && white_queen == 1 && black_phase == white_phase )
            black_load = 7;
        }
    return black_load;
    }

#define VALUE4(w,x,y,z)                                 \
    ( ( ( (uint64) z) << 48) + ( ( (uint64) y) << 32) + \
    ( ( (uint64) x) << 16) + ( ( (uint64) w) << 0))
#define bishop_two VALUE4(35, 40, 50, 55)
#define value_pawn VALUE4(80, 90, 110, 125)
#define value_knight VALUE4(265, 280, 320, 355)
#define value_rook VALUE4(405, 450, 550, 610)
#define value_queen VALUE4(800, 875, 1025, 1150)
#define value_bishop VALUE4(280, 295, 325, 360)
#define mix_knight_pawn VALUE4(0, 2, 4, 5)
#define mix_rook_pawn VALUE4(5, 4, 2, 0)

static uint64 value_value( int white_pawn, int white_knight, int white_bishop, int white_clear, int white_dark,
    int white_rook, int white_queen, int black_pawn, int black_knight, int black_bishop, int black_clear,
    int black_dark, int black_rook, int black_queen )
    {
    uint64 va = 0;
    int white_minor;
    int black_minor;

    va += (white_bishop / 2 - black_bishop / 2) * bishop_two;
    va += (white_pawn - black_pawn) * value_pawn;
    va += (white_knight - black_knight) * value_knight;
    va += (white_rook - black_rook) * value_rook;
    va += (white_queen - black_queen) * value_queen;
    va += (white_bishop - black_bishop) * value_bishop;

    if( white_rook == 2 )
        va -= VALUE4(16, 20, 28, 32);

    if( black_rook == 2 )
        va += VALUE4(16, 20, 28, 32);

    if( white_queen + white_rook >= 2 )
        va -= VALUE4(8, 10, 14, 16);

    if( black_queen + black_rook >= 2 )
        va += VALUE4(8, 10, 14, 16);
    white_minor = white_knight + white_bishop;
    black_minor = black_knight + black_bishop;

    if( white_minor > black_minor )
        va += VALUE4(20, 15, 10, 5);

    if( black_minor > white_minor )
        va -= VALUE4(20, 15, 10, 5);
    va -= (white_pawn - 5) * white_rook * mix_rook_pawn;
    va += (white_pawn - 5) * white_knight * mix_knight_pawn;
    va += (black_pawn - 5) * black_rook * mix_rook_pawn;
    va -= (black_pawn - 5) * black_knight * mix_knight_pawn;
    return va;
    }

#define PHASE_MINOR (1)
#define PHASE_ROOK (3)
#define PHASE_QUEEN (6)

static void Material_calculation( int c )
    {
    int white_queen, black_queen, white_rook, black_rook, white_clear, black_clear, white_dark, black_dark,
        white_knight, black_knight, white_pawn, black_pawn, n, value, white_bishop, black_bishop;
    int ca, white_load, black_load, phase, va1, va2, va3, va4;
    uint64 va;
    n = c;
    white_queen = n % 2;
    n /= 2;
    black_queen = n % 2;
    n /= 2;
    white_rook = n % 3;
    n /= 3;
    black_rook = n % 3;
    n /= 3;
    white_clear = n % 2;
    n /= 2;
    white_dark = n % 2;
    n /= 2;
    black_clear = n % 2;
    n /= 2;
    black_dark = n % 2;
    n /= 2;
    white_knight = n % 3;
    n /= 3;
    black_knight = n % 3;
    n /= 3;
    white_pawn = n % 9;
    n /= 9;
    black_pawn = n % 9;
    white_bishop = white_clear + white_dark;
    black_bishop = black_clear + black_dark;
    va =
        value_value(white_pawn, white_knight, white_bishop, white_clear, white_dark, white_rook, white_queen,
            black_pawn, black_knight, black_bishop, black_clear, black_dark, black_rook, black_queen);
    phase =
        PHASE_MINOR * (white_knight + white_bishop + black_knight + black_bishop)
            + PHASE_ROOK * (white_rook + black_rook) + PHASE_QUEEN * (white_queen + black_queen);
    va1 = va & 0xffff;
    va2 = ((va >> 16) & 0xffff) + (va1 > 0x8000);
    va1 = (sint16)va1;
    va3 = ((va >> 32) & 0xffff) + (va2 > 0x8000);
    va2 = (sint16)va2;
    va4 = ((va >> 48) & 0xffff) + (va3 > 0x8000);
    va3 = (sint16)va3;
    va4 = (sint16)va4;

    if( phase < 8 )
        {
        va4 *= 8 - phase;
        va3 *= phase;
        va = va3 + va4;
        value = ((int)va) / 8;
        }
    else if( phase < 24 )
        {
        va3 *= 24 - phase;
        va2 *= phase - 8;
        va = va2 + va3;
        value = ((int)va) / 16;
        }
    else
        {
        va2 *= 32 - phase;
        va1 *= phase - 24;
        va = va1 + va2;
        value = ((int)va) / 8;
        }
    white_load =
        load_white(white_pawn, white_knight, white_bishop, white_clear, white_dark, white_rook, white_queen, black_pawn,
            black_knight, black_bishop, black_clear, black_dark, black_rook, black_queen);
    black_load =
        load_black(white_pawn, white_knight, white_bishop, white_clear, white_dark, white_rook, white_queen, black_pawn,
            black_knight, black_bishop, black_clear, black_dark, black_rook, black_queen);

    if( value > 0 )
        ca = white_load;
    else
        ca = black_load;
    value *= ca;
    value /= 10;
    MATERIAL[c].value = value;
    MATERIAL[c].sign =
        sengo_initialization(white_pawn, white_knight, white_bishop, white_clear, white_dark, white_rook, white_queen,
            black_pawn, black_knight, black_bishop, black_clear, black_dark, black_rook, black_queen);
    MATERIAL[c].flags =
        flags_initialization(white_pawn, white_knight, white_bishop, white_clear, white_dark, white_rook, white_queen,
            black_pawn, black_knight, black_bishop, black_clear, black_dark, black_rook, black_queen);
    }

void initialization_value()
    {
    int c;

    for ( c = 0; c < 419904; c++ )
        Material_calculation(c);
    }
