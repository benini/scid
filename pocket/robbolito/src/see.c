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

#ifndef BUILD_see
#define BUILD_see
#include "robbolito.h"

typedef enum
    {
    value_pawn = 100,
    value_knight = 325,
    value_bishop = 325,
    value_rook = 500,
    value_queen = 975,
    value_king = 12345
    } enum_value;

static const int value[16] =
    {
    0, value_pawn, value_knight, 12345678, value_bishop, value_bishop, value_rook, value_queen,
	0, value_pawn, value_knight, 12345678, value_bishop, value_bishop, value_rook, value_queen
    };

#include "see.c"
#include "white.h"
#else
#include "black.h"
#endif

bool my_see( uint32 move )
    {
    int di, ai, value_piece, value_capture, d, dir;
    uint64 bit, cbf, cel, index_pile[4], gcm = 0, T;
    int index_turn[4], b, w;
    T = my_xray & your_occupied;
    di = DI(move);
    ai = AI(move);

    while( T )
        {
        b = BSF(T);
        w = my_xray_list[b];
        bit_FREE(b, T);

        if( di != w && index_line[ai][b] != index_line[b][your_square_king] )
            gcm |= square_fixed[b];
        }
    gcm = ~gcm;
    value_piece = value[QU[di]];
    value_capture = value[QU[ai]];

    if( value_piece - value_capture > value_pawn && your_attack_pawn[ai] & bitboard_your_pawn & gcm )
        return FALSE;
    bit = (bitboard_my_knight | (bitboard_your_knight &gcm)) & attack_knight[ai];
    d = value_piece - value_capture;

    if( d > value_knight && bitboard_your_knight & bit )
        return FALSE;
    index_turn[direction_h1a8] = (POSITION.occupied_left45 >> lineturn[direction_h1a8][ai]) & 077;
    index_turn[direction_a1h8] = (POSITION.occupied_straight45 >> lineturn[direction_a1h8][ai]) & 077;
    cel = bitboard_my_queen | bitboard_my_bishop | ((bitboard_your_queen | bitboard_your_bishop) & gcm);
    index_pile[direction_h1a8] = index_pile[direction_a1h8] = cel;
    bit |=
        (line_obscured[direction_h1a8][ai][index_turn[direction_h1a8]]
            | line_obscured[direction_a1h8][ai][index_turn[direction_a1h8]]) & cel;

    if( d > value_bishop && (bitboard_your_bishop &bit) )
        return FALSE;
    index_turn[direction_horizontal] = (POSITION.occupied_black_white >> lineturn[direction_horizontal][ai]) & 077;
    index_turn[direction_vertical] = (POSITION.occupied_left90 >> lineturn[direction_vertical][ai]) & 077;
    cel = bitboard_my_queen | bitboard_my_rook | ((bitboard_your_queen | bitboard_your_rook) & gcm);
    index_pile[direction_horizontal] = index_pile[direction_vertical] = cel;
    bit |=
        (line_obscured[direction_horizontal][ai][index_turn[direction_horizontal]]
            | line_obscured[direction_vertical][ai][index_turn[direction_vertical]]) & cel;
    bit |= (bitboard_my_king | bitboard_your_king) & attack_king[ai];
    bit |= bitboard_your_pawn & your_attack_pawn[ai] & gcm;
    bit |= bitboard_my_pawn & my_attack_pawn[ai];
    cbf = ~(square_fixed[di] | square_fixed[ai]);
    bit &= cbf;
    dir = index_line[di][ai];

    if( dir != direction_sick )
        bit |= line_obscured[dir][di][index_turn[dir]] & index_pile[dir] & cbf;
    value_capture -= value_piece;

    do
        {
        cbf &= ~bit;
        cel = bitboard_your_pawn & bit;

        if( cel )
            {
            bit ^= (~(cel - 1)) & cel;
            value_piece = value_pawn;
            }
        else
            {
            cel = bitboard_your_knight & bit;

            if( cel )
                {
                bit ^= (~(cel - 1)) & cel;
                value_piece = value_knight;
                }
            else
                {
                cel = bitboard_your_bishop & bit;

                if( cel )
                    {
                    value_piece = value_bishop;
                    di = BSF(cel);
                    dir = index_line[di][ai];
                    cel = line_obscured[dir][di][index_turn[dir]] & cbf & index_pile[direction_a1h8];
                    bit = cel | (square_free[di]&bit);
                    }
                else
                    {
                    cel = bitboard_your_rook & bit;

                    if( cel )
                        {
                        value_piece = value_rook;
                        di = BSF(cel);
                        dir = index_line[di][ai];
                        cel = line_obscured[dir][di][index_turn[dir]] & cbf & index_pile[direction_horizontal];
                        bit = cel | (square_free[di]&bit);
                        }
                    else
                        {
                        cel = bitboard_your_queen & bit;

                        if( cel )
                            {
                            value_piece = value_queen;
                            di = BSF(cel);
                            dir = index_line[di][ai];
                            cel = line_obscured[dir][di][index_turn[dir]] & cbf & index_pile[dir];
                            bit = cel | (square_free[di]&bit);
                            }
                        else
                            {
                            if( !(bitboard_your_king &bit) )
                                return TRUE;
                            value_piece = 12345;
                            }
                        }
                    }
                }
            }
        value_capture += value_piece;

        if( value_capture < -60 )
            return FALSE;
        cel = bitboard_my_pawn & bit;

        if( cel )
            {
            bit ^= (~(cel - 1)) & cel;
            value_piece = value_pawn;
            }
        else
            {
            cel = bitboard_my_knight & bit;

            if( cel )
                {
                bit ^= (~(cel - 1)) & cel;
                value_piece = value_knight;
                }
            else
                {
                cel = bitboard_my_bishop & bit;

                if( cel )
                    {
                    value_piece = value_bishop;
                    di = BSF(cel);
                    dir = index_line[di][ai];
                    cel = line_obscured[dir][di][index_turn[dir]] & cbf & index_pile[direction_a1h8];
                    bit = cel | (square_free[di]&bit);
                    }
                else
                    {
                    cel = bitboard_my_rook & bit;

                    if( cel )
                        {
                        value_piece = value_rook;
                        di = BSF(cel);
                        dir = index_line[di][ai];
                        cel = line_obscured[dir][di][index_turn[dir]] & cbf & index_pile[direction_horizontal];
                        bit = cel | (square_free[di]&bit);
                        }
                    else
                        {
                        cel = bitboard_my_queen & bit;

                        if( cel )
                            {
                            value_piece = value_queen;
                            di = BSF(cel);
                            dir = index_line[di][ai];
                            cel = line_obscured[dir][di][index_turn[dir]] & cbf & index_pile[dir];
                            bit = cel | (square_free[di]&bit);
                            }
                        else
                            {
                            if( !(bitboard_my_king &bit) )
                                return FALSE;

                            if( value_capture > 6174 )
                                return TRUE;
                            value_piece = 23456;
                            }
                        }
                    }
                }
            }
        value_capture -= value_piece;
        } while ( value_capture < -60 );
    return TRUE;
    }
