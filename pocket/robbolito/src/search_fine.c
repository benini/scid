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

#ifndef BUILD_SEARCH_FINE
#define BUILD_SEARCH_FINE
#include "robbolito.h"
#include "search_fine.c"
#include "white.h"
#else
#include "black.h"
#endif

#define RETURN(x) return(x)

int my_search_fine( int VALUE, int DEPTH )
    {
    int value, i, k = DYNAMIC->Zobrist & list_hide, v, value_better;
    uint32 TEMP, move, move_trans = 0, trans_hole, move_hole = 0;
    uint64 tag;
    type_list_move LIST[256], *list, *p, *q;
    type_dynamic *POSITION_0 = DYNAMIC;
    type_zobrist *tr;

    repetition_check;

    if( VALUE < -VALUE_MATE + 1 )
        RETURN(-VALUE_MATE + 1);

    if( VALUE > VALUE_MATE - 1 )
        RETURN(VALUE_MATE - 1);

    for ( i = 0; i < 4; i++ )
        {
        tr = list_zobrist + (k + i);

        if( (tr->zobrist ^ (DYNAMIC->Zobrist >> 32)) == 0 )
            {
            if( tr->hole_low )
                {
                value = zobrist_value_low(tr);

                if( value >= VALUE )
                    RETURN(value);
                }

            if( tr->hole_high )
                {
                value = zobrist_value_high(tr);

                if( value < VALUE )
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

    if( value_better >= VALUE )
        RETURN(value_better);
    v = VALUE - pawn_plum;
    tag = your_occupied;

    if( v > value_better )
        {
        v = VALUE - minor_plum;
        tag ^= bitboard_your_pawn;

        if( v > value_better )
            {
            tag ^= (bitboard_your_knight | bitboard_your_bishop);
            v = VALUE - rook_plum;

            if( v > value_better )
                tag ^= bitboard_your_rook;
            }

        if( bitboard_your_pawn & my_attack )
            value_better += pawn_plum;
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

        if( !see_easy(move) && (move & 0x7fff) != move_trans && square_fixed[DI(move)] & ~my_xray && !my_see(move) )
            continue;
        move &= 0x7fff;
        DO(move);
        call_value_lazy(VALUE, VALUE, value_lazy, move);

        if( move_illegal )
            {
            CANCEL(move);
            continue;
            }

        if( move_check )
            v = -your_search_fine_check(1 - VALUE, DEPTH - 1);
        else
            v = -your_search_fine(1 - VALUE, DEPTH - 1);
        CANCEL(move);

        if( v <= value_better )
            continue;
        value_better = v;

        if( v >= VALUE )
            {
            Zobrist_low(DYNAMIC->Zobrist, move, 1, v);
            RETURN(v);
            }
        }

    if( DEPTH >= -1 && POSITION_0->value >= VALUE - (100 + (12 << (DEPTH + 4))) )
        {
        list = my_check_quiet(LIST, tag);

        for ( i = 0; i < list - LIST; i++ )
            {
            move = LIST[i].move;
            move &= 0x7fff;
            DO(move);
            call_value_lazy(VALUE, VALUE, value_lazy, move);

            if( move_illegal )
                {
                CANCEL(move);
                continue;
                }
            v = -your_search_fine_check(1 - VALUE, DEPTH - 1);
            CANCEL(move);

            if( v <= value_better )
                continue;
            value_better = v;

            if( v >= VALUE )
                {
                Zobrist_low(DYNAMIC->Zobrist, move, 1, v);
                RETURN(v);
                }
            }
        }
    Zobrist_high(DYNAMIC->Zobrist, 1, value_better);
    RETURN(value_better);
    }

int my_search_fine_check( int VALUE, int DEPTH )
    {
    int ignore, value, i, k = DYNAMIC->Zobrist & list_hide, v, value_better, trans_hole, move_hole = 0;
    type_zobrist *tr;
    uint64 tag;
    type_list_move LIST[256], *list, *p, *q;
    type_dynamic *POSITION_0;
    uint32 move, TEMP, move_trans = 0;

    repetition_check;
    POSITION_0 = DYNAMIC;

    if( VALUE < -VALUE_MATE + 1 )
        RETURN(-VALUE_MATE + 1);

    if( VALUE > VALUE_MATE - 1 )
        RETURN(VALUE_MATE - 1);

    for ( i = 0; i < 4; i++ )
        {
        tr = list_zobrist + (k + i);

        if( (tr->zobrist ^ (DYNAMIC->Zobrist >> 32)) == 0 )
            {
            if( tr->hole_low )
                {
                value = zobrist_value_low(tr);

                if( value >= VALUE )
                    RETURN(value);
                }

            if( tr->hole_high )
                {
                value = zobrist_value_high(tr);

                if( value < VALUE )
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

    if( POSITION_0->value + check_plum < VALUE )
        {
        value_better = POSITION_0->value + check_plum;
        v = VALUE - 200;
        tag = your_occupied;

        if( v > value_better )
            {
            tag ^= bitboard_your_pawn;
            v = VALUE - 500;
            value_better += 200;

            if( v > value_better )
                tag ^= (bitboard_your_knight | bitboard_your_bishop);
            }
        }

    list = my_evasion(LIST, tag);

    if( (list - LIST) > 1 )
        DEPTH--;
    p = LIST;

    while( p->move )
        {
        if( (p->move & 0x7fff) == move_trans )
            p->move |= 0xfff00000;
        p++;
        }
    p = LIST;
    ignore = 0;

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

        if( INTERROGATIVE_INTERPOSITION(move) && VALUE > -25000 && (move & 0x7fff) != move_trans && !my_see(move) )
            {
            ignore++;
            continue;
            }

        if( QU[AI(move)] == 0 && (move & 0x6000) == 0 && (move & 0x7fff)
            != move_trans && my_null && MAXIMUM_POSITIONAL(move)
            + POSITION_0->value < VALUE + 25 && VALUE > -25000 )
            {
            ignore++;
            continue;
            }
        move &= 0x7fff;
        DO(move);
        call_value_lazy(VALUE, VALUE, value_lazy, move);

        if( move_illegal )
            {
            CANCEL(move);
            continue;
            }

        if( move_check )
            v = -your_search_fine_check(1 - VALUE, DEPTH);
        else
            v = -your_search_fine(1 - VALUE, DEPTH);
        CANCEL(move);

        if( v <= value_better )
            continue;
        value_better = v;

        if( v >= VALUE )
            {
            Zobrist_low(DYNAMIC->Zobrist, move, 1, v);
            RETURN(v);
            }
        }

    if( ignore && value_better < -25000 )
        value_better = VALUE - 1;
    Zobrist_high(DYNAMIC->Zobrist, 1, value_better);
    RETURN(value_better);
    }
