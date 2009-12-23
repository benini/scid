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

#ifndef BUILD_NODE_TOTAL
#define BUILD_NODE_TOTAL
#include "robbolito.h"
#include "history.h"
#include "move_null.h"
#include "node_total.c"
#include "white.h"
#else
#include "black.h"
#endif

#define RETURN(x) return(x)

int my_node_total( int VALUE, int DEPTH )
    {
    int move, i;
    int k;
    type_zobrist *tr;
    int trans_hole, move_hole = 0, move_trans = 0, value, cnt;
    int v, EXTENSION, hole_new, check_move;
    type_next NEXT[1];
    type_dynamic *POSITION_0 = DYNAMIC;
    uint64 zob = DYNAMIC->Zobrist;
    int ai, di;

    if( VALUE < -VALUE_MATE + 1 )
        RETURN(-VALUE_MATE + 1);

    if( VALUE > VALUE_MATE - 1 )
        RETURN(VALUE_MATE - 1);
    (POSITION_0 + 1)->move = 0;
    repetition_check;
    k = zob & list_hide;

    for ( i = 0; i < 4; i++ )
        {
        tr = list_zobrist + (k + i);

        if( (tr->zobrist ^ (zob >> 32)) == 0 )
            {
            trans_hole = tr->hole_low;
            move = tr->move;

            if( move && trans_hole > move_hole )
                {
                move_hole = trans_hole;
                (POSITION_0 + 1)->move = move_trans = move;
                }
            trans_hole = MAXIMUM(tr->hole_low, tr->hole_high);

            if( tr->hole_low >= DEPTH )
                {
                value = zobrist_value_low(tr);

                if( value >= VALUE )
                    {
                    if( my_null || move )
                        {
                        tr->years = YEARS;
                        RETURN(value);
                        }
                    }
                }

            if( tr->hole_high >= DEPTH )
                {
                value = zobrist_value_high(tr);

                if( value < VALUE )
                    {
                    if( !((tr->flags &flag_cut) == flag_cut) )
                        {
                        tr->years = YEARS;
                        RETURN(value);
                        }
                    }
                }
            }
        }
    NEXT->move_trans = move_trans;

    if( POSITION_0->value >= VALUE && my_null )
        {
        null_do();
        hole_new = DEPTH - null_riduzione;
        hole_new -= ((uint32)(MINIMUM(POSITION_0->value - VALUE, 96))) / 32;

        if( hole_new <= 1 )
            v = -your_search_fine(1 - VALUE, 0);

        else if( hole_new <= 7 )
            v = -your_search_half(1 - VALUE, hole_new);

        else
            v = -your_node_cut(1 - VALUE, hole_new);
        null_cancel();

        if( v >= VALUE )
            {
            if( move_trans == 0 )
                Zobrist_low_total(0, DEPTH, v);
            RETURN(v);
            }
        }

    cnt = 0;
    NEXT->move_trans = move_trans;
    NEXT->phase = TRAS;
    NEXT->tag = your_occupied;

    if( DEPTH < 20 && VALUE - POSITION_0->value >= 48 * (DEPTH - 4) )
        {
        NEXT->phase = TRAS2;
        cnt = 1;

        if( VALUE - POSITION_0->value >= 48 * (DEPTH - 2) )
            NEXT->tag ^= bitboard_your_pawn;
        }
    NEXT->move = 0;
    NEXT->cb = 0;
    v = VALUE;

    while( (move = my_next(NEXT)) )
        {
        ai = AI(move);
        di = DI(move);

        if( repetition_question(0) )
            {
            cnt++;
            continue;
            }

        if( cnt > 5 && NEXT->phase == move_ordinary && (move & 0xe000) == 0 && square_fixed[di] & ~my_xray
            && DEPTH < 20 )
            {
            if( (5 << (DEPTH - 6)) + MAXIMUM_POSITIONAL (move) +
            (POSITION_0->value) < VALUE + 35 + 2 * cnt )
                {
                cnt++;
                continue;
                }
            }

        if( DEPTH < 20 && (2 << (DEPTH - 6)) + (POSITION_0->value) < VALUE
            + 125 && NEXT->phase == move_ordinary && my_square_king != di && square_fixed[di] & ~my_xray
            && (move & 0x8000) == 0 && !my_see(move) )
            {
            cnt++;
            continue;
            }
        move &= 0x7fff;
        DO(move);
        call_value_lazy(VALUE, VALUE, value_lazy2, move);

        if( move_illegal )
            {
            CANCEL(move);
            continue;
            }

        if( move_check )
            check_move = 1;
        else
            check_move = 0;
        EXTENSION = 0;

        if( pawn_free_move(ai, RANK_SIX(ai)) )
            EXTENSION = 1;

        if( check_move )
            v = -your_node_cut_check(1 - VALUE, DEPTH - 1);
        else
            {
            if( cnt > 5 && DEPTH < 20 && POSITION_1->capture == 0 && (2 << (DEPTH - 6)) - POSITION_1->value < VALUE
                + cnt - 15 )
                {
                CANCEL(move);
                cnt++;
                continue;
                }

            if( NEXT->phase == move_ordinary && cnt >= 3 )
                {
                hole_new = DEPTH - 2 + EXTENSION - BSR(1 + cnt);

                if( hole_new <= 1 )
                    v = -your_search_fine(1 - VALUE, 0);

                else if( hole_new <= 7 )
                    v = -your_search_half(1 - VALUE, hole_new);

                else
                    v = -your_node_cut(1 - VALUE, hole_new);

                if( v < VALUE )
                    goto FATTO;
                }
            hole_new = DEPTH - 2 + EXTENSION;

            if( hole_new <= 7 )
                v = -your_search_half(1 - VALUE, hole_new);
            else
                v = -your_node_cut(1 - VALUE, hole_new);
            }
        FATTO:
        CANCEL(move);
        cnt++;

        if( v >= VALUE )
            {
            if( (POSITION_0 + 1)->capture == 0 && move_history(move) )
                HISTORY_GOOD(move, DEPTH);
            Zobrist_low_total(move, DEPTH, v);
            RETURN(v);
            }

        if( (POSITION_0 + 1)->capture == 0 && move_history(move) )
            HISTORY_BAD(move, DEPTH);
        }

    if( !cnt && NEXT->phase <= TRAS2 )
        RETURN(0);
    v = VALUE - 1;
    Zobrist_high(DYNAMIC->Zobrist, DEPTH, v);
    RETURN(v);
    }

int my_node_total_check( int VALUE, int DEPTH )
    {
    int move, k, cnt, EXTENSION;
    int trans_hole, move_hole = 0, move_trans = 0, value, hole_new, v, i;
    type_zobrist *tr;
    type_list_move LIST[256], *list, *p, *q;
    uint64 zob = DYNAMIC->Zobrist;
    int value_better;
    type_dynamic *POSITION_0 = DYNAMIC;
    bool GEN;

    if( VALUE < -VALUE_MATE + 1 )
        RETURN(-VALUE_MATE + 1);

    if( VALUE > VALUE_MATE - 1 )
        RETURN(VALUE_MATE - 1);
    (POSITION_0 + 1)->move = 0;
    repetition_check;
    k = zob & list_hide;

    for ( i = 0; i < 4; i++ )
        {
        tr = list_zobrist + (k + i);

        if( (tr->zobrist ^ (zob >> 32)) == 0 )
            {
            trans_hole = tr->hole_low;
            move = tr->move;

            if( move && trans_hole > move_hole )
                {
                move_hole = trans_hole;
                (POSITION_0 + 1)->move = move_trans = move;
                }
            trans_hole = MAXIMUM(tr->hole_low, tr->hole_high);

            if( tr->hole_low >= DEPTH )
                {
                value = zobrist_value_low(tr);

                if( value >= VALUE )
                    {
                    tr->years = YEARS;
                    RETURN(value);
                    }
                }

            if( tr->hole_high >= DEPTH )
                {
                value = zobrist_value_high(tr);

                if( value < VALUE )
                    {
                    if( !((tr->flags &flag_cut) == flag_cut) )
                        {
                        tr->years = YEARS;
                        RETURN(value);
                        }
                    }
                }
            }
        }

    if( move_trans && !my_ensure(move_trans) )
        move_trans = 0;

    value_better = (POSITION_0 - (dynamic_initial + 1)) - VALUE_MATE;
    p = LIST;
    LIST[0].move = move_trans;
    cnt = 0;
    GEN = FALSE;
    LIST[1].move = 0;

    while( p->move || !GEN )
        {
        if( !p->move )
            {
            list = my_evasion(LIST + 1, 0xffffffffffffffffull);
            GEN = TRUE;

            for ( p = list - 1; p >= LIST + 1; p-- )
                {
                if( (p->move & 0x7fff) == move_trans )
                    p->move = 0;
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
            p = LIST + 1;
            continue;
            }
        move = p->move & 0x7fff;
        p++;

        if( repetition_question(0) )
            {
            value_better = MAXIMUM(0, value_better);
            cnt++;
            continue;
            }
        DO(move);
        call_value_lazy(VALUE, VALUE, value_lazy2, move);

        if( move_illegal )
            {
            CANCEL(move);
            continue;
            }

        if( move_check )
            {
            hole_new = DEPTH - 1;

            if( hole_new <= 7 )
                v = -your_search_half_check(1 - VALUE, hole_new);
            else
                v = -your_node_cut_check(1 - VALUE, hole_new);
            }
        else
            {
            if( cnt >= 1 )
                {
                if( game_before )
                    EXTENSION = 1;
                else
                    EXTENSION = 0;
                hole_new = DEPTH - 2 - MINIMUM(2, cnt) + EXTENSION;

                if( hole_new <= 1 )
                    v = -your_search_fine(1 - VALUE, 0);

                else if( hole_new <= 7 )
                    v = -your_search_half(1 - VALUE, hole_new);

                else
                    v = -your_node_cut(1 - VALUE, hole_new);

                if( v < VALUE )
                    goto LACE;
                }

            if( game_before )
                EXTENSION = 1;
            else
                EXTENSION = 0;
            hole_new = DEPTH - 2 + EXTENSION;

            if( hole_new <= 7 )
                v = -your_search_half(1 - VALUE, hole_new);
            else
                v = -your_node_cut(1 - VALUE, hole_new);
            }
        LACE:
        CANCEL(move);

        if( v > value_better )
            value_better = v;

        if( v < VALUE )
            {
            cnt++;
            continue;
            }
        Zobrist_low_total(move, MAXIMUM(1, DEPTH), v);
        RETURN(v);
        }
    Zobrist_high(DYNAMIC->Zobrist, MAXIMUM(1, DEPTH), value_better);
    RETURN(value_better);
    }
