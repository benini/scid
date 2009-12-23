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

#ifndef BUILD_SEARCH_FINE_PV
#define BUILD_SEARCH_FINE_PV
#include "robbolito.h"
#include "search_fine_pv.c"
#include "white.h"
#else
#include "black.h"
#endif

#define RETURN(x) return(x)

int my_pv_search_fine( int ALPHA, int BETA, int DEPTH )
    {
    int i;
    uint32 move_good = 0, move_trans = 0, move, capture_bad[64], trans_hole, move_hole = 0;
    int value_better, value;
    uint64 tag;
    type_list_move LIST[256], *list, *p, *q;
    int TEMP, v;
    type_dynamic *POSITION_0 = DYNAMIC;
    int k = DYNAMIC->Zobrist & list_hide;
    int cb = 0;
    type_zobrist *tr;

    repetition_check;

    if( BETA < -VALUE_MATE )
        RETURN(-VALUE_MATE);

    if( ALPHA > VALUE_MATE )
        RETURN(VALUE_MATE);

    for ( i = 0; i < 4; i++ )
        {
        tr = list_zobrist + (k + i);

        if( (tr->zobrist ^ (DYNAMIC->Zobrist >> 32)) == 0 )
            {
            if( zobrist_accurate(tr) )
                {
                value = zobrist_value_high(tr);
                RETURN(value);
                }

            if( tr->hole_low )
                {
                value = zobrist_value_low(tr);

                if( value >= BETA )
                    RETURN(value);
                }

            if( tr->hole_high )
                {
                value = zobrist_value_high(tr);

                if( value <= ALPHA )
                    RETURN(value);
                }
            trans_hole = tr->hole_low;
            move = tr->move;

            if( move && trans_hole > move_hole )
                {
                move_hole = trans_hole;
                move_trans = move;
                }
            }
        }
    value_better = POSITION_0->value + value_tempo2;
    tag = your_occupied;

    if( value_better >= BETA )
        {
        RETURN(value_better);
        }

    else if( value_better > ALPHA )
        ALPHA = value_better;

    else
        {
        if( value_better < ALPHA - pawn_plum )
            {
            tag ^= bitboard_your_pawn;

            if( value_better < ALPHA - minor_plum )
                {
                tag ^= (bitboard_your_knight | bitboard_your_bishop);

                if( value_better < ALPHA - rook_plum )
                    tag ^= bitboard_your_rook;
                }
            value_better += pawn_plum;
            }
        }

    list = my_capture(LIST, tag);
    p = LIST;

    while( p->move )
        {
        if( (p->move & 0x7fff) == move_trans )
            p->move |= 0xffff0000;
        p++;
        }
    p = LIST;

    while( p->move )
        {
        move = p->move;
        q = ++p;

        while( q->move )
            {
            if( move < q->move )
                {
                TEMP = q->move;
                q->move = move;
                move = TEMP;
                }
            q++;
            }

        if( see_easy(move) || (move & 0x7fff) == move_trans || my_see(move) )
            {
            move &= 0x7fff;
            DO(move);
            call_value_full(move);

            if( move_illegal )
                {
                CANCEL(move);
                continue;
                }

            if( move_check )
                v = -your_pv_search_fine_check(-BETA, -ALPHA, DEPTH - 1);
            else
                v = -your_pv_search_fine(-BETA, -ALPHA, DEPTH - 1);
            CANCEL(move);

            if( v <= value_better )
                continue;
            value_better = v;

            if( v <= ALPHA )
                continue;
            ALPHA = v;
            move_good = move;

            if( v >= BETA )
                {
                Zobrist_low(DYNAMIC->Zobrist, move, 1, v);
                RETURN(v);
                }
            }
        else
            capture_bad[cb++] = move;
        }

    if( DEPTH > 0 )
        for ( i = 0; i < cb; i++ )
            {
            move = capture_bad[i] & 0x7fff;
            DO(move);
            call_value_full(move);

            if( move_illegal )
                {
                CANCEL(move);
                continue;
                }

            if( move_check )
                v = -your_pv_search_fine_check(-BETA, -ALPHA, DEPTH - 1);
            else
                v = -your_pv_search_fine(-BETA, -ALPHA, DEPTH - 1);
            CANCEL(move);

            if( v <= value_better )
                continue;
            value_better = v;

            if( v <= ALPHA )
                continue;
            ALPHA = v;
            move_good = move;

            if( v >= BETA )
                {
                Zobrist_low(DYNAMIC->Zobrist, move, 1, v);
                RETURN(v);
                }
            }

    if( DEPTH >= -2 && POSITION_0->value >= ALPHA - (100 + (12 << (DEPTH + 5))) )
        {
        list = my_check_quiet(LIST, tag);

        for ( i = 0; i < list - LIST; i++ )
            {
            move = LIST[i].move & 0x7fff;
            DO(move);
            call_value_full(move);

            if( move_illegal )
                {
                CANCEL(move);
                continue;
                }
            v = -your_pv_search_fine_check(-BETA, -ALPHA, DEPTH - 1);
            CANCEL(move);

            if( v <= value_better )
                continue;
            value_better = v;

            if( v <= ALPHA )
                continue;
            ALPHA = v;
            move_good = move;

            if( v >= BETA )
                {
                Zobrist_low(DYNAMIC->Zobrist, move, 1, v);
                RETURN(v);
                }
            }

        if( DEPTH >= 0 && ALPHA <= POSITION_0->value + 150 )
            {
            list = my_gain(LIST, ALPHA - POSITION_0->value);

            for ( i = 0; i < list - LIST; i++ )
                {
                move = LIST[i].move & 0x7fff;
                DO(move);
                call_value_full(move);

                if( -POSITION_1->value < ALPHA )
                    {
                    CANCEL(move);
                    continue;
                    }

                if( move_illegal || move_check )
                    {
                    CANCEL(move);
                    continue;
                    }
                v = -your_pv_search_fine(-BETA, -ALPHA, 0);
                CANCEL(move);

                if( v <= value_better )
                    continue;
                value_better = v;

                if( v <= ALPHA )
                    continue;
                ALPHA = v;
                move_good = move;
                Zobrist_low(DYNAMIC->Zobrist, move, 1, v);

                if( v >= BETA )
                    RETURN(v);
                }
            }
        }

    if( move_good )
        {
        Zobrist_accurate(move_good, 1, value_better, flag_precise);
        RETURN(value_better);
        }
    Zobrist_high(DYNAMIC->Zobrist, 1, value_better);
    RETURN(value_better);
    }

int my_pv_search_fine_check( int ALPHA, int BETA, int DEPTH )
    {
    int i;
    uint32 move_trans = 0, move_good = 0, move, TEMP;
    int value_better, value;
    uint64 tag;
    type_list_move LIST[256], *list, *p, *q;
    int k = DYNAMIC->Zobrist & list_hide;
    int v, trans_hole, move_hole = 0;
    type_dynamic *POSITION_0 = DYNAMIC;
    type_zobrist *tr;
    repetition_check;

    if( BETA < -VALUE_MATE )
        RETURN(-VALUE_MATE);

    if( ALPHA > VALUE_MATE )
        RETURN(VALUE_MATE);

    for ( i = 0; i < 4; i++ )
        {
        tr = list_zobrist + (k + i);

        if( (tr->zobrist ^ (DYNAMIC->Zobrist >> 32)) == 0 )
            {
            if( zobrist_accurate(tr) )
                {
                value = zobrist_value_high(tr);
                RETURN(value);
                }

            if( tr->hole_low )
                {
                value = zobrist_value_low(tr);

                if( value >= BETA )
                    RETURN(value);
                }

            if( tr->hole_high )
                {
                value = zobrist_value_high(tr);

                if( value <= ALPHA )
                    RETURN(value);
                }
            trans_hole = tr->hole_low;
            move = tr->move;

            if( move && trans_hole > move_hole )
                {
                move_hole = trans_hole;
                move_trans = move;
                }
            }
        }
    value_better = (POSITION_0 - (dynamic_initial + 1)) - VALUE_MATE;
    tag = 0xffffffffffffffffull;

    if( POSITION_0->value + check_plum < ALPHA )
        {
        value_better = POSITION_0->value + check_plum;
        v = ALPHA - 200;
        tag = your_occupied;

        if( v > value_better )
            {
            tag ^= bitboard_your_pawn;
            v = ALPHA - 500;
            value_better += 200;

            if( v > value_better )
                tag ^= (bitboard_your_knight | bitboard_your_bishop);
            }
        }
    list = my_evasion(LIST, tag);

    if( (list - LIST) != 1 )
        DEPTH--;
    p = LIST;

    while( p->move )
        {
        if( (p->move & 0x7fff) == move_trans )
            p->move |= 0xfff00000;
        p++;
        }
    p = LIST;

    while( p->move )
        {
        move = p->move;
        q = ++p;

        while( q->move )
            {
            if( move < q->move )
                {
                TEMP = q->move;
                q->move = move;
                move = TEMP;
                }
            q++;
            }
        move &= 0x7fff;
        DO(move);
        call_value_full(move);

        if( move_illegal )
            {
            CANCEL(move);
            continue;
            }

        if( move_check )
            v = -your_pv_search_fine_check(-BETA, -ALPHA, DEPTH);
        else
            v = -your_pv_search_fine(-BETA, -ALPHA, DEPTH);
        CANCEL(move);

        if( v <= value_better )
            continue;
        value_better = v;

        if( v <= ALPHA )
            continue;
        ALPHA = v;
        move_good = move;
        Zobrist_low(DYNAMIC->Zobrist, move, 1, v);

        if( v >= BETA )
            RETURN(v);
        }

    if( move_good )
        {
        Zobrist_accurate(move_good, 1, value_better, flag_precise);
        RETURN(value_better);
        }
    Zobrist_high(DYNAMIC->Zobrist, 1, value_better);
    RETURN(value_better);
    }
