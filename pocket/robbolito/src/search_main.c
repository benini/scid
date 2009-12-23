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

#ifndef BUILD_search_main
#define BUILD_search_main
#include "robbolito.h"
#include "history.h"
#include "move_null.h"
#include "search_main.c"
#include "white.h"
#else
#include "black.h"
#endif

#define RETURN(x) return(x)

int my_search_half( int VALUE, int DEPTH )
    {
    int cnt, value, value_better, v, k, i, move_trans = 0, move, move_hole = 0, trans_hole, ai, di;
    type_next NEXT[1];
    type_dynamic *POSITION_0 = DYNAMIC;
    type_zobrist *tr;

    if( VALUE < -VALUE_MATE + 1 )
        RETURN(-VALUE_MATE + 1);

    if( VALUE > VALUE_MATE - 1 )
        RETURN(VALUE_MATE - 1);
    (POSITION_0 + 1)->move = 0;
    v = POSITION_0->value + 1125;

    if( v < VALUE )
        RETURN(VALUE - 1);
    repetition_check;
    k = DYNAMIC->Zobrist & list_hide;

    for ( i = 0; i < 4; i++ )
        {
        tr = list_zobrist + (k + i);

        if( (tr->zobrist ^ (DYNAMIC->Zobrist >> 32)) == 0 )
            {
            if( tr->hole_low >= DEPTH )
                {
                value = zobrist_value_low(tr);

                if( value >= VALUE )
                    {
                    (POSITION_0 + 1)->move = tr->move;
                    RETURN(value);
                    }
                }

            if( tr->hole_high >= DEPTH )
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
    v = POSITION_0->value - (70 + 10 * DEPTH);

    if( v >= VALUE )
        RETURN(POSITION_0->value);
    value_better = MINIMUM(POSITION_0->value, VALUE - 1);

    if( POSITION_0->value >= VALUE && my_null )
        {
        null_do();
        v = -your_search_fine(1 - VALUE, 0);
        null_cancel();

        if( v >= VALUE )
            {
            Zobrist_low(DYNAMIC->Zobrist, move_trans, DEPTH, v);
            RETURN(v);
            }
        }
    NEXT->phase = TRAS;
    NEXT->tag = your_occupied;

    if( POSITION_0->value + 50 + 8 * DEPTH < VALUE )
        {
        NEXT->phase = TRAS2;

        if( VALUE >= POSITION_0->value + 75 + 32 * DEPTH )
            {
            NEXT->tag ^= bitboard_your_pawn;

            if( bitboard_your_pawn & my_attack )
                value_better += 125;

            if( DEPTH <= 3 && VALUE >= POSITION_0->value + 400 + 32 * DEPTH )
                {
                NEXT->tag ^= (bitboard_your_knight | bitboard_your_bishop);
                value_better += 300;

                if( VALUE >= POSITION_0->value + 600 + 32 * DEPTH )
                    {
                    NEXT->tag ^= bitboard_your_rook;
                    value_better += 200;
                    }
                }
            }
        }
    else if( DEPTH <= 3 && POSITION_0->value + 4 * DEPTH < VALUE )
        {
        NEXT->phase = TRAS3;
        NEXT->celare = (VALUE - POSITION_0->value) + 4 * DEPTH + 5;
        }
    NEXT->cb = 0;
    NEXT->move = 0;
    NEXT->move_trans = move_trans;
    cnt = 0;

    while( (move = my_next(NEXT)) )
        {
        ai = AI(move);
        di = DI(move);

        if( repetition_question(0) )
            {
            value_better = MAXIMUM(0, value_better);
            cnt++;
            continue;
            }

        if( cnt >= DEPTH && NEXT->phase == move_ordinary && (move & 0xe000) == 0 && square_fixed[di] & ~my_xray
            && my_occupied ^ (bitboard_my_pawn | bitboard_my_king) )
            {
            if( (2 * DEPTH) + MAXIMUM_POSITIONAL (move) + POSITION_0->value <
            VALUE + 40 + 2 * cnt )
                {
                cnt++;
                continue;
                }
            }

        if( (QU[ai] == 0 || (DEPTH <= 5 && !see_easy(move))) && square_fixed[di] & ~my_xray && QU[di] != count_my_king
            && !move_en_passant(move) && move != move_trans && !my_see(move) )
            {
            cnt++;
            continue;
            }

        move &= 0x7fff;
        DO(move);
        call_value_lazy(VALUE, VALUE, value_lazy, move);

        if( move_illegal || (NEXT->phase == guadagno && move_check) )
            {
            CANCEL(move);
            continue;
            }

        if( move_check )
            v = -your_search_half_check(1 - VALUE, DEPTH - 1);
        else
            {
            if( cnt >= DEPTH && (2 * DEPTH) - POSITION_1->value < VALUE + cnt )
                {
                CANCEL(move);
                cnt++;
                continue;
                }

            if( DEPTH <= 3 )
                v = -your_search_fine(1 - VALUE, 0);
            else
                v = -your_search_half(1 - VALUE, DEPTH - 2);
            }
        cnt++;
        CANCEL(move);

        if( v >= VALUE )
            {
            if( (POSITION_0 + 1)->capture == 0 && move_history(move) )
                HISTORY_GOOD(move, DEPTH);
            Zobrist_low(DYNAMIC->Zobrist, move, DEPTH, v);
            RETURN(v);
            }

        if( v >= value_better )
            value_better = v;

        if( (POSITION_0 + 1)->capture == 0 && move_history(move) )
            HISTORY_BAD(move, DEPTH);
        }

    if( !cnt && NEXT->phase <= TRAS2 )
        RETURN(0);
    Zobrist_high(DYNAMIC->Zobrist, DEPTH, value_better);
    RETURN(value_better);
    }

int my_search_half_check( int VALUE, int DEPTH )
    {
    int ignore, k, move_trans = 0, trans_hole, move_hole = 0, value, i, move, value_better, v, hole_new;
    bool GEN;
    type_zobrist *tr;
    type_list_move LIST[256], *list, *p, *q;
    type_dynamic *POSITION_0 = DYNAMIC;
    repetition_check;

    if( VALUE < -VALUE_MATE + 1 )
        RETURN(-VALUE_MATE + 1);

    if( VALUE > VALUE_MATE - 1 )
        RETURN(VALUE_MATE - 1);
    k = DYNAMIC->Zobrist & list_hide;

    for ( i = 0; i < 4; i++ )
        {
        tr = list_zobrist + (k + i);

        if( (tr->zobrist ^ (DYNAMIC->Zobrist >> 32)) == 0 )
            {
            if( tr->hole_low && tr->hole_low >= DEPTH )
                {
                value = zobrist_value_low(tr);

                if( value >= VALUE )
                    RETURN(value);
                }

            if( tr->hole_high && tr->hole_high >= DEPTH )
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

    if( move_trans && !my_ensure(move_trans) )
        move_trans = 0;

    value_better = (POSITION_0 - (dynamic_initial + 1)) - VALUE_MATE;
    p = LIST;
    LIST[0].move = move_trans;
    GEN = FALSE;
    LIST[1].move = 0;
    ignore = 0;

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
                        p->move |= (p->move & 0xffff) | ((history_value[QU[DI(p->move)]][AI(p->move)] >> 1) << 16);
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
        move = p->move;
        p++;

        if( repetition_question(0) )
            {
            value_better = MAXIMUM(0, value_better);
            continue;
            }

        if( INTERROGATIVE_INTERPOSITION(move) && VALUE > -25000 && (move & 0x7fff) != move_trans && !my_see(move) )
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
            v = -your_search_half_check(1 - VALUE, DEPTH - 1 + (game_before));
        else
            {
            hole_new = DEPTH - 2 + game_before;

            if( hole_new <= 1 )
                v = -your_search_fine(1 - VALUE, 0);
            else
                v = -your_search_half(1 - VALUE, hole_new);
            }
        CANCEL(move);

        if( v <= value_better )
            continue;
        value_better = v;

        if( v >= VALUE )
            {
            Zobrist_low(DYNAMIC->Zobrist, move, MAXIMUM(1, DEPTH), v);
            RETURN(v);
            }
        }

    if( ignore && value_better < -25000 )
        value_better = VALUE - 1;
    Zobrist_high(DYNAMIC->Zobrist, MAXIMUM(1, DEPTH), value_better);
    RETURN(value_better);
    }
