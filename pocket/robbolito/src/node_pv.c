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

#ifndef BUILD_NODE_PV
#define BUILD_NODE_PV
#include "robbolito.h"
#include "history.h"
#include "monitor.h"
#include "node_pv.c"
#include "white.h"
#else
#include "black.h"
#endif

#define RETURN(x) return(x)

int my_node_pv( int ALPHA, int BETA, int DEPTH, int sca )
    {
    type_next NEXT[1];
    type_zobrist *tr;
    int move_good, v, value, k, i, trans_hole, move, move_hole = 0, move_trans = 0, zob_hole;
    type_list_move *list, *p, *q;
    int EXTENSION, value_better, hole_new, check_move, ai, di;
    type_dynamic *POSITION_0 = DYNAMIC;
    int SINGULAR = 0;

    if( BETA < -VALUE_MATE )
        RETURN(-VALUE_MATE);

    if( ALPHA > VALUE_MATE )
        RETURN(VALUE_MATE);

    if( DEPTH <= 1 )
        {
        if( sca )
            return my_pv_search_fine_check(ALPHA, BETA, 1);
        else
            return my_pv_search_fine(ALPHA, BETA, 1);
        }
    repetition_check;
    NEXT->move_trans = 0;
    zob_hole = 0;
    NEXT->move = 0;
    NEXT->cb = 0;

    k = DYNAMIC->Zobrist & list_hide;
    (POSITION_0 + 1)->move = 0;

    for ( i = 0; i < 4; i++ )
        {
        tr = list_zobrist + (k + i);

        if( (tr->zobrist ^ (DYNAMIC->Zobrist >> 32)) == 0 )
            {
            trans_hole = tr->hole_low;
            move = tr->move;

            if( move && trans_hole > move_hole )
                {
                move_hole = trans_hole;
                (POSITION_0 + 1)->move = move_trans = move;
                }

            if( tr->hole_low > tr->hole_high )
                {
                trans_hole = tr->hole_low;
                value = zobrist_value_low(tr);
                }
            else
                {
                trans_hole = tr->hole_high;
                value = zobrist_value_high(tr);
                }

            if( trans_hole > zob_hole )
                zob_hole = trans_hole;

            if( zobrist_accurate(tr) && trans_hole >= DEPTH )
                {
                tr->years = YEARS;

                if( !ANALYSIS )
                    RETURN(value);
                }
            }
        }

    if( !move_trans && DEPTH >= 6 )
        {
        v = ALPHA;

        if( DEPTH >= 10 )
            {
            v = my_node_pv(ALPHA - DEPTH, BETA + DEPTH, DEPTH - 8, sca);

            if( v > ALPHA - DEPTH )
                move_trans = (POSITION_0 + 1)->move;
            }

        if( v > ALPHA - DEPTH )
            v = my_node_pv(ALPHA - DEPTH, BETA + DEPTH, DEPTH - 4, sca);

        if( v > ALPHA - DEPTH )
            move_trans = (POSITION_0 + 1)->move;
        }
    else if( DEPTH >= 10 && DEPTH > zob_hole + 8 )
        {
        v = my_node_pv(ALPHA - DEPTH, BETA + DEPTH, DEPTH - 8, sca);

        if( v > ALPHA - DEPTH )
            move_trans = (POSITION_0 + 1)->move;

        if( v > ALPHA - DEPTH )
            {
            v = my_node_pv(ALPHA - DEPTH, BETA + DEPTH, DEPTH - 4, sca);

            if( v > ALPHA - DEPTH )
                move_trans = (POSITION_0 + 1)->move;
            }
        }

    NEXT->move_trans = move_trans;
    NEXT->phase = TRAS;
    EXTENSION = 0;
    NEXT->tag = your_occupied;

    if( sca )
        {
        list = my_evasion(NEXT->LIST, 0xffffffffffffffffull);
        NEXT->phase = elusione;

        for ( p = list - 1; p >= NEXT->LIST; p-- )
            {
            if( (p->move & 0x7fff) == move_trans )
                p->move |= 0xffff0000;
            else if( p->move <= (0x80 << 24) )
                {
                if( (p->move & 0x7fff) == POSITION_0->killer_one )
                    p->move |= 0x7fff8000;

                else if( (p->move & 0x7fff) == POSITION_0->killer_two )
                    p->move |= 0x7fff0000;

                else
                    p->move |= (p->move & 0x7fff) | (history_value[QU[DI(p->move)]][AI(p->move)] << 15);
                }
            move = p->move;

            for ( q = p + 1; q < list; q++ )
                {
                if( move < q->move )
                    (q - 1)->move = q->move;
                else
                    break;
                }
            q--;
            q->move = move;
            }

        if( (list - NEXT->LIST) <= 1 )
            SINGULAR = 2;

        if( (list - NEXT->LIST) == 2 )
            SINGULAR = 1;

        if( (list - NEXT->LIST) > 2 )
            SINGULAR = 0;
        }

    if( DEPTH >= 16 && NEXT->move_trans && SINGULAR < 2 && my_ensure(NEXT->move_trans) )
        {
        move = NEXT->move_trans;
        ai = AI(move);
        di = DI(move);
        DO(move);
        call_value_full(move);

        if( move_illegal )
            {
            CANCEL(move);
            goto IGNORE_;
            }
        value = -your_node_pv(-BETA, -ALPHA, DEPTH - 10, (move_check) != 0);
        CANCEL(move);

        if( sca )
            v = my_exclude_check(value - DEPTH / 2, DEPTH - MINIMUM(12, DEPTH / 2), move & 0x7fff);
        else
            v = my_exclude(value - DEPTH / 2, DEPTH - MINIMUM(12, DEPTH / 2), move & 0x7fff);

        if( v < value - DEPTH / 2 )
            {
            SINGULAR = 1;

            if( sca )
                v = my_exclude_check(value - DEPTH, DEPTH - MINIMUM(12, DEPTH / 2), move & 0x7fff);
            else
                v = my_exclude(value - DEPTH, DEPTH - MINIMUM(12, DEPTH / 2), move & 0x7fff);

            if( v < value - DEPTH )
                SINGULAR = 2;
            }
        }
    IGNORE_:
    value_better = -VALUE_INFINITE;
    NEXT->move = 0;
    NEXT->cb = 0;
    move_good = 0;

    while( (move = my_next(NEXT)) )
        {
        ai = AI(move);
        di = DI(move);

        if( ALPHA > 0 && POSITION_0->move50 >= 2 && ((AI(move) << 6) | DI(move)) == (POSITION_0 - 1)->move
            && QU[AI(move)] == 0 )
            {
            value_better = MAXIMUM(0, value_better);
            continue;
            }
        move &= 0x7fff;
        DO(move);
        call_value_full(move);

        if( move_illegal )
            {
            CANCEL(move);
            continue;
            }
        check_move = (move_check != 0);
        EXTENSION = 0;

        if( EXTENSION < 2 )
            {
            if( pawn_free_move(ai, RANK_SIX(ai)) )
                EXTENSION = 2;
            }

        if( EXTENSION < 2 )
            {
            if( POSITION_1->capture != 0 || check_move || (sca && game_before) )
                EXTENSION = 1;

            else if( pawn_free_move(ai, RANK_FOUR(ai)) )
                EXTENSION = 1;
            }

        if( NEXT->move_trans != move )
            SINGULAR = 0;
        hole_new = DEPTH - 2 + MAXIMUM(EXTENSION, SINGULAR);

        if( NEXT->move_trans != move && hole_new > 1 )
            {
            if( hole_new <= 7 )
                {
                if( check_move )
                    v = -your_search_half_check(-ALPHA, hole_new);
                else
                    v = -your_search_half(-ALPHA, hole_new);
                }
            else
                {
                if( check_move )
                    v = -your_node_cut_check(-ALPHA, hole_new);
                else
                    v = -your_node_cut(-ALPHA, hole_new);
                }

            if( v > ALPHA )
                v = -your_node_pv(-BETA, -ALPHA, hole_new, check_move);
            }
        else
            v = -your_node_pv(-BETA, -ALPHA, hole_new, check_move);
        CANCEL(move);

        if( v <= ALPHA && QU[AI(move)] == 0 && move_history(move) )
            HISTORY_BAD_pv(move, DEPTH);

        if( v <= value_better )
            continue;
        value_better = v;

        if( v <= ALPHA )
            continue;
        ALPHA = v;
        move_good = move;
        Zobrist_low(DYNAMIC->Zobrist, move, DEPTH, v);

        if( v >= BETA )
            {
            if( QU[AI(move)] == 0 && move_history(move) )
                HISTORY_GOOD(move, DEPTH);
            RETURN(v);
            }
        }

    move = move_good;
    (POSITION_0 + 1)->move = move_good & 0x7fff;

    if( value_better == -VALUE_INFINITE )
        {
        if( !sca )
            RETURN(0);
        RETURN((POSITION_0 - (dynamic_initial + 1)) - VALUE_MATE);
        }

    if( move )
        {
        if( QU[AI(move)] == 0 && move_history(move) )
            HISTORY_GOOD(move, DEPTH);
        Zobrist_accurate(move, DEPTH, value_better, flag_precise);
        RETURN(value_better);
        }
    Zobrist_high(DYNAMIC->Zobrist, DEPTH, value_better);
    RETURN(value_better);
    }
