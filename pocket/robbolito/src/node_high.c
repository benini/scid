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

#ifndef BUILD_node_high
#define BUILD_node_high
#include "robbolito.h"
#include "monitor.h"

#define check                                       \
    ( POSITION.white_en_move ?                       \
    (bitboard_white_king & DYNAMIC->attak_black) : \
    (bitboard_black_king & DYNAMIC->attak_white) )

type_list_move ROOT_LIST_MOVE[256];
#include "node_high.c"
#include "white.h"
#else
#include "black.h"
#endif

void my_high()
    {
    int i, k, DEPTH, A, L, U, v, value = 0, trans_hole;
    int move_hole = 0, precise_hole = 0;
    uint32 move, zob_move = 0, precise_move = 0, ai, di;
    type_list_move *p, *q, *list;
    type_zobrist *tr;
    type_dynamic *POSITION_0 = DYNAMIC;
    int piece_value[16] =
        {
        0, 1, 3, 0, 3, 3, 5, 9, 0, 1, 3, 0, 3, 3, 5, 9
        };

    call_value_full(0);

    if( check )
        list = my_evasion(ROOT_LIST_MOVE, 0xffffffffffffffffull);
    else
        {
        q = my_capture(ROOT_LIST_MOVE, your_occupied);
        list = my_ordinary(q);
        sort_ordinary(list, q, 0, 0, 0);
        }

    k = DYNAMIC->Zobrist & list_hide;

    for ( i = 0; i < 4; i++ )
        {
        tr = list_zobrist + (k + i);

        if( (tr->zobrist ^ (DYNAMIC->Zobrist >> 32)) == 0 )
            {
            trans_hole = tr->hole_low;
            move = tr->move;

            if( zobrist_accurate(tr) )
                {
                precise_hole = trans_hole;
                precise_move = move;
                value = zobrist_value_high(tr);
                }

            if( move && trans_hole > move_hole )
                {
                move_hole = trans_hole;
                zob_move = move;
                }
            }
        }

    if( precise_hole >= hole_previous - 6 && precise_move == zob_move && precise_move && root_rapid
    	&& hole_previous >= 18 && my_ensure(precise_move) && value < 25000 && value > -25000 && !ANALYSIS && !PONDERING )
        {
        root_value = value;
        root_move = precise_move;
        root_hole = precise_hole;
        root_rapid = FALSE;

        if( !check )
            v = my_exclude(value - 50, hole_previous - 6, precise_move);
        else
            v = my_exclude_check(value - 50, hole_previous - 6, precise_move);

        if( v < value - 50 && time_factor < 1.05 )
			{
            return;
			}
        }

    root_rapid = TRUE;
    q = ROOT_LIST_MOVE;

    for ( p = ROOT_LIST_MOVE; p < list; p++ )
        {
        move = p->move & 0x7fff;
        DO(move);
        call_value_full(0);

        if( !move_illegal )
            (q++)->move = move & 0x7fff;
        CANCEL(move);
        }
    q->move = 0;
    list = q;

    for ( p = ROOT_LIST_MOVE; p < list; p++ )
        {
        if( QU[AI(p->move)] )
            {
            ai = QU[AI(p->move)];
            di = QU[DI(p->move)];
            p->move |= 0xff000000 + ((16 * piece_value[ai] - piece_value[di]) << 16);
            }
        }

    for ( p = ROOT_LIST_MOVE; p < list; p++ )
        if( p->move == zob_move )
            p->move |= 0xffff0000;

    for ( p = list - 1; p >= ROOT_LIST_MOVE; p-- )
        {
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

    L = -VALUE_MATE;
    U = VALUE_MATE;

    if( !ROOT_LIST_MOVE[0].move )
        {
        if( check )
            {
            root_value = L;
            }
        else
            {
            root_value = 0;
            }
        root_move = 0;
        root_hole = 0;
        return;
        }

    for ( DEPTH = 2; DEPTH <= 250; DEPTH += 2 )
        {
        MOVE_BAD = FALSE;
        MOVE_BATTLE = FALSE;

        if( DEPTH >= 14 && root_value <= 25000 && -25000 <= root_value )
            {
            A = 8;
            L = root_value - A;
            U = root_value + A;

            if( L < -25000 )
                L = -VALUE_MATE;

            if( U > 25000 )
                U = VALUE_MATE;
            MORE:
            v = my_node_top(L, U, DEPTH);

            if( v > L && v < U )
                goto END;

            if( v <= L )
                {
                L -= A;
                A += A / 2;
                root_value = L;
                goto MORE;
                }
            else
                {
                U += A;
                A += A / 2;
                root_value = U;
                goto MORE;
                }
            }
        else
            v = my_node_top(-VALUE_MATE, VALUE_MATE, DEPTH);
        END:
        if( DEPTH == 2 )
            {
            if( !ROOT_LIST_MOVE[1].move || (ROOT_LIST_MOVE[0].move - ROOT_LIST_MOVE[1].move >= (200 << 16)) )
                EASY = TRUE;
            }
        root_previous = root_value;
		resolve_term(DEPTH / 2);
        }
    }
