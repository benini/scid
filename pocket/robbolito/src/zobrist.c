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

#define MAXIMUM_YEAR 256
#define MAXIMUM_DEPTH 256

#define NUMBER(x,y)                                        \
    ((( (x) - YEARS) & (MAXIMUM_YEAR - 1)) * MAXIMUM_DEPTH \
    + (MAXIMUM_DEPTH - (y) ))

void year_increase()
    {
    YEARS += 1;

    if( YEARS == MAXIMUM_YEAR )
        YEARS = 0;
    }

static uint64 zobrist_dimension = 0x1600000;
static bool zobrist_initialization_flag = FALSE;
void zobrist_free()
    {
    memset(list_zobrist, 0, zobrist_dimension * sizeof(type_zobrist));
    memset(list_zobrist_pv, 0, 0x10000 * sizeof(type_zobrist_pv));
    YEARS = 0;
    }
int initialization_zobrist( int mb )
    {
    YEARS = 0;
    zobrist_dimension = ((1 << BSR(mb)) << 10) / sizeof(type_zobrist);

    if( zobrist_dimension > 0x100000000ull )
        zobrist_dimension = 0x100000000ull;
    mb = (zobrist_dimension * sizeof(type_zobrist)) >> 10;
    list_hide = zobrist_dimension - 4;
    if( zobrist_initialization_flag == TRUE)
        free(list_zobrist);
    else
    	zobrist_initialization_flag = TRUE;
    list_zobrist = malloc(zobrist_dimension * sizeof(type_zobrist));
    zobrist_free();
    return mb;
    }
void Zobrist_low_total( int move, int depth, int value )
    {
    int DEPTH, i, k = DYNAMIC->Zobrist & list_hide;
    type_zobrist *tr;
    int maximum = 0, w = 0;
    move &= 0x7fff;

    for ( i = 0; i < 4; i++ )
        {
        tr = list_zobrist + (k + i);

        if( (tr->zobrist ^ (DYNAMIC->Zobrist >> 32)) == 0 && (!tr->hole_low || zobrist_total(tr))
            && tr->hole_low <= depth )
            {
            tr->hole_low = depth;
            tr->move = move;
            tr->value_low = value;
            tr->years = YEARS;
            tr->flags |= flag_low | flag_total;
            return;
            }
        DEPTH = MAXIMUM(tr->hole_low, tr->hole_high);

        if( NUMBER(tr->years, DEPTH) > maximum )
            {
            maximum = NUMBER(tr->years, DEPTH);
            w = i;
            }
        }
    tr = list_zobrist + (k + w);
    tr->zobrist = (DYNAMIC->Zobrist >> 32);
    tr->hole_high = 0;
    tr->value_high = 0;
    tr->hole_low = depth;
    tr->move = move;
    tr->value_low = value;
    tr->years = YEARS;
    tr->flags = flag_low | flag_total;
    return;
    }
void Zobrist_high_cut( int depth, int value )
    {
    int DEPTH, i, k = DYNAMIC->Zobrist & list_hide;
    type_zobrist *tr;
    int maximum = 0, w = 0;

    for ( i = 0; i < 4; i++ )
        {
        tr = list_zobrist + (k + i);

        if( !(tr->zobrist ^ (DYNAMIC->Zobrist >> 32)) && (!tr->hole_high || zobrist_cut(tr)) && tr->hole_high <= depth )
            {
            tr->hole_high = depth;
            tr->value_high = value;
            tr->years = YEARS;
            tr->flags |= flag_high | flag_cut;
            return;
            }
        DEPTH = MAXIMUM(tr->hole_low, tr->hole_high);

        if( NUMBER(tr->years, DEPTH) > maximum )
            {
            maximum = NUMBER(tr->years, DEPTH);
            w = i;
            }
        }
    tr = list_zobrist + (k + w);
    tr->zobrist = (DYNAMIC->Zobrist >> 32);
    tr->hole_low = 0;
    tr->move = 0;
    tr->value_low = 0;
    tr->hole_high = depth;
    tr->value_high = value;
    tr->years = YEARS;
    tr->flags = flag_high | flag_cut;
    return;
    }
void Zobrist_low( uint64 Z, int move, int depth, int value )
    {
    int DEPTH, i, k = Z & list_hide;
    type_zobrist *tr;
    int maximum = 0, w = 0;
    move &= 0x7fff;

    for ( i = 0; i < 4; i++ )
        {
        tr = list_zobrist + (k + i);

        if( !(tr->zobrist ^ (Z >> 32)) && !zobrist_accurate(tr) && tr->hole_low <= depth )
            {
            tr->hole_low = depth;
            tr->move = move;
            tr->value_low = value;
            tr->years = YEARS;
            tr->flags |= flag_low;
            tr->flags &= ~flag_total;
            return;
            }
        DEPTH = MAXIMUM(tr->hole_low, tr->hole_high);

        if( NUMBER(tr->years, DEPTH) > maximum )
            {
            maximum = NUMBER(tr->years, DEPTH);
            w = i;
            }
        }
    tr = list_zobrist + (k + w);
    tr->zobrist = (Z >> 32);
    tr->hole_high = 0;
    tr->value_high = 0;
    tr->hole_low = depth;
    tr->move = move;
    tr->value_low = value;
    tr->years = YEARS;
    tr->flags = flag_low;
    return;
    }
void Zobrist_high( uint64 Z, int depth, int value )
    {
    int DEPTH, i, k = Z & list_hide;
    type_zobrist *tr;
    int maximum = 0, w = 0;

    for ( i = 0; i < 4; i++ )
        {
        tr = list_zobrist + (k + i);

        if( !(tr->zobrist ^ (Z >> 32)) && !zobrist_accurate(tr) && tr->hole_high <= depth )
            {
            tr->hole_high = depth;
            tr->value_high = value;
            tr->years = YEARS;
            tr->flags |= flag_high;
            tr->flags &= ~flag_cut;
            return;
            }
        DEPTH = MAXIMUM(tr->hole_low, tr->hole_high);

        if( NUMBER(tr->years, DEPTH) > maximum )
            {
            maximum = NUMBER(tr->years, DEPTH);
            w = i;
            }
        }
    tr = list_zobrist + (k + w);
    tr->zobrist = (Z >> 32);
    tr->hole_low = 0;
    tr->move = 0;
    tr->value_low = 0;
    tr->hole_high = depth;
    tr->value_high = value;
    tr->years = YEARS;
    tr->flags = flag_high;
    return;
    }
static void pv_zobrist( int move, int depth, int value )
    {
    int i, k = DYNAMIC->Zobrist & list_hide_pv;
    type_zobrist_pv *tr;
    int w = 0, maximum = 0;

    for ( i = 0; i < 4; i++ )
        {
        tr = list_zobrist_pv + (k + i);

        if( tr->zobrist == DYNAMIC->Zobrist )
            {
            tr->depth = depth;
            tr->value = value;
            tr->move = move;
            tr->years = YEARS;
            return;
            }

        if( NUMBER(tr->years, tr->depth) > maximum )
            {
            maximum = NUMBER(tr->years, tr->depth);
            w = i;
            }
        }
    tr = list_zobrist_pv + (k + w);
    tr->zobrist = DYNAMIC->Zobrist;
    tr->depth = depth;
    tr->move = move;
    tr->value = value;
    tr->years = YEARS;
    }

void Zobrist_accurate( int move, int depth, int value, int FLAGS )
    {
    int DEPTH, i, j, k = DYNAMIC->Zobrist & list_hide;
    type_zobrist *tr;
    int maximum = 0, w = 0;
    move &= 0x7fff;
    pv_zobrist(move, depth, value);

    for ( i = 0; i < 4; i++ )
        {
        tr = list_zobrist + (k + i);

        if( (tr->zobrist ^ (DYNAMIC->Zobrist >> 32)) == 0 && MAXIMUM(tr->hole_high, tr->hole_low) <= depth )
            {
            tr->hole_high = tr->hole_low = depth;
            tr->move = move;
            tr->value_high = tr->value_low = value;
            tr->years = YEARS;
            tr->flags = FLAGS;

            for ( j = i + 1; j < 4; j++ )
                {
                tr = list_zobrist + (k + j);

                if( (tr->zobrist ^ (DYNAMIC->Zobrist >> 32)) == 0 && MAXIMUM(tr->hole_high, tr->hole_low) <= depth )
                    {
                    memset(tr, 0, 16);
                    tr->years = YEARS ^ (MAXIMUM_YEAR / 2);
                    }
                }
            return;
            }
        DEPTH = MAXIMUM(tr->hole_low, tr->hole_high);

        if( NUMBER(tr->years, DEPTH) > maximum )
            {
            maximum = NUMBER(tr->years, DEPTH);
            w = i;
            }
        }
    tr = list_zobrist + (k + w);
    tr->zobrist = (DYNAMIC->Zobrist >> 32);
    tr->hole_high = tr->hole_low = depth;
    tr->move = move;
    tr->value_high = tr->value_low = value;
    tr->years = YEARS;
    tr->flags = FLAGS;
    return;
    }
