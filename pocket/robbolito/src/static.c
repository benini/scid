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

static void black_white()
    {
    int qu;

    for ( qu = A1; qu <= H8; qu++ )
        {
        static_value[count_pawn_black][qu] = -static_value[count_pawn_white][H8 - qu];
        static_value[count_knight_black][qu] = -static_value[count_knight_white][H8 - qu];
        static_value[count_clear_black][qu] = -static_value[count_clear_white][H8 - qu];
        static_value[count_dark_black][qu] = -static_value[count_dark_white][H8 - qu];
        static_value[count_rook_black][qu] = -static_value[count_rook_white][H8 - qu];
        static_value[count_queen_black][qu] = -static_value[count_queen_white][H8 - qu];
        static_value[count_king_black][qu] = -static_value[count_king_white][H8 - qu];
        }
    }
static int opening_pawn( int qu )
    {
    int C[8] =
        {
        -20, -8, -2, 5, 5, -2, -8, -20
        };

    int T[8] =
        {
        0, -3, -2, -1, 1, 2, 3, 0
        };

    int co = FILE(qu), tr = RANK(qu);

    if( tr == T1 || tr == T8 )
        return 0;
    return C[co] + T[tr];
    }
static int endgame_pawn( int qu )
    {
    int C[8] =
        {
        -4, -6, -8, -10, -10, -8, -6, -4
        };

    int T[8] =
        {
        0, -3, -3, -2, -1, 0, 2, 0
        };

    int co = FILE(qu), tr = RANK(qu);

    if( tr == T1 || tr == T8 )
        return 0;
    return C[co] + T[tr];
    }
static int opening_knight( int qu )
    {
    int T[8] =
        {
        -32, -10, 6, 15, 21, 19, 10, -11
        };

    int C[8] =
        {
        -26, -10, 1, 5, 5, 1, -10, -26
        };

    int tr = RANK(qu), co = FILE(qu);
    return (qu == A8 || qu == H8) ? (-120) : (T[tr] + C[co]);
    }
static int endgame_knight( int qu )
    {
    int V[8] =
        {
        2, 1, 0, -1, -2, -4, -7, -10
        };

    int T[8] =
        {
        -10, -5, -2, 1, 3, 5, 2, -3
        };

    int C[8] =
        {
        -4, -1, 2, 4, 4, 2, -1, -4
        };

    int tr = RANK(qu), co = FILE(qu);
    int d = ABSOLUTE_(co - tr), e = ABSOLUTE_(co + tr - 7);
    return V[d] + V[e] + T[tr] + C[co];
    }
static int opening_bishop( int qu )
    {
    int V[8] =
        {
        10, 5, 1, -3, -5, -7, -8, -12
        };

    int W[8] =
        {
        -5, 0, 0, 0, 0, 0, 0, 0
        };

    int tr = RANK(qu), co = FILE(qu);
    int d = ABSOLUTE_(co - tr), e = ABSOLUTE_(co + tr - 7);
    return V[d] + V[e] + W[tr];
    }
static int endgame_bishop( int qu )
    {
    int V[8] =
        {
        3, 2, 0, 0, -2, -2, -3, -3
        };

    int tr = RANK(qu), co = FILE(qu);
    int d = ABSOLUTE_(co - tr), e = ABSOLUTE_(co + tr - 7);
    return V[d] + V[e];
    }
static int opening_rook( int qu )
    {
    int C[8] =
        {
        -4, 0, 4, 8, 8, 4, 0, -4
        };

    return C[FILE(qu)];
    }
static int endgame_rook( int qu )
    {
    int T[8] =
        {
        0, 0, 0, 0, 1, 1, 1, -2
        };

    return T[RANK(qu)];
    }
static int opening_queen( int qu )
    {
    int V[8] =
        {
        3, 2, 1, 0, -2, -4, -7, -10
        };

    int W[8] =
        {
        -2, 0, 1, 2, 2, 1, 0, -2
        };

    int tr = RANK(qu), co = FILE(qu);
    int d = ABSOLUTE_(co - tr), e = ABSOLUTE_(co + tr - 7);
    return V[d] + V[e] + W[tr] + W[co] - 5 * (tr == T1);
    }
static int endgame_queen( int qu )
    {
    int V[8] =
        {
        1, 0, -1, -3, -4, -6, -8, -12
        };

    int W[8] =
        {
        -2, 0, 1, 2, 2, 1, 0, -2
        };

    int tr = RANK(qu), co = FILE(qu);
    int d = ABSOLUTE_(co - tr), e = ABSOLUTE_(co + tr - 7);
    return V[d] + V[e] + W[tr] + W[co];
    }
static int opening_king( int qu )
    {
    int T[8] =
        {
        4, 1, -2, -5, -10, -15, -25, -35
        };

    int C[8] =
        {
        40, 45, 15, -5, -5, 15, 45, 40
        };

    int tr = RANK(qu), co = FILE(qu);
    return T[tr] + C[co];
    }
static int endgame_king( int qu )
    {
    int V[8] =
        {
        2, 0, -2, -5, -8, -12, -20, -30
        };

    int T[8] =
        {
        -30, -5, 0, 5, 10, 5, 0, -10
        };

    int C[8] =
        {
        -15, 0, 10, 15, 15, 10, 0, -15
        };

    int tr = RANK(qu), co = FILE(qu);
    int d = ABSOLUTE_(co - tr), e = ABSOLUTE_(co + tr - 7);
    return V[d] + V[e] + T[tr] + C[co];
    }

#define absorb(x,y) ( ( ( x ) << 16 ) + ( y ) )

void static_initialization()
    {
    int qu;

    for ( qu = A1; qu <= H8; qu++ )
        static_value[count_pawn_white][qu] = absorb(opening_pawn(qu), endgame_pawn(qu));

    for ( qu = A1; qu <= H8; qu++ )
        static_value[count_knight_white][qu] = absorb(opening_knight(qu), endgame_knight(qu));

    for ( qu = A1; qu <= H8; qu++ )
        static_value[count_clear_white][qu] = absorb(opening_bishop(qu), endgame_bishop(qu));

    for ( qu = A1; qu <= H8; qu++ )
        static_value[count_dark_white][qu] = absorb(opening_bishop(qu), endgame_bishop(qu));

    for ( qu = A1; qu <= H8; qu++ )
        static_value[count_rook_white][qu] = absorb(opening_rook(qu), endgame_rook(qu));

    for ( qu = A1; qu <= H8; qu++ )
        static_value[count_queen_white][qu] = absorb(opening_queen(qu), endgame_queen(qu));

    for ( qu = A1; qu <= H8; qu++ )
        static_value[count_king_white][qu] = absorb(opening_king(qu), endgame_king(qu));
    black_white();
    }
