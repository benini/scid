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

#ifndef BUILD_NODE_SUPERIOR
#define BUILD_NODE_SUPERIOR
#include "robbolito.h"
#include "monitor.h"
type_list_move ROOT_LIST_MOVE[256];
#include "node_superior.c"
#include "white.h"
#else
#include "black.h"
#endif

int my_node_top( int ALPHA, int BETA, int DEPTH )
    {
    int CNT, low_orig, value_better, cnt, check_move, hole_new, v, TEMPvalue;
    type_list_move *p, *q;
    type_dynamic *POSITION_0 = DYNAMIC;
    uint32 move;

    if( BETA > VALUE_MATE )
        BETA = VALUE_MATE;

    if( ALPHA < -VALUE_MATE )
        ALPHA = -VALUE_MATE;
	if( DEPTH > 8 && DEPTH <= 70 && TIME_DESIRED > 500000 )
        {
		send_msg("info depth %d\n", DEPTH / 2);
		//fflush(stdout);
        }
	CNT = 0;

    for ( p = ROOT_LIST_MOVE; p->move; p++ )
        {
        CNT++;
        p->move &= 0x7fff;
        }
    low_orig = ALPHA;
    p = ROOT_LIST_MOVE;
    v = value_better = -VALUE_INFINITE;
    cnt = 0;

    while( (move = p->move) )
        {
        DO(move);
        call_value_full(move);
        check_move = (move_check != 0);
        hole_new = DEPTH - (2 - check_move);

		if((DEPTH > 18) && ((clock_() - CLOCK_UCI) > 4000000))
            {
            send_msg("info currmove %s currmovenumber %d\n", move_notation(move, STRING1), (p - ROOT_LIST_MOVE) + 1);
//             fflush(stdout);
            }

        if( value_better == -VALUE_INFINITE || DEPTH <= 2 )
            v = -your_node_pv(-BETA, -ALPHA, hole_new, check_move);
        else
            {
            if( check_move )
                {
                if( hole_new <= 7 )
                    v = -your_search_half_check(-ALPHA, hole_new);
                else
                    v = -your_node_cut_check(-ALPHA, hole_new);
                }
            else
                {
                if( hole_new <= 7 )
                    v = -your_search_half(-ALPHA, hole_new);
                else
                    v = -your_node_cut(-ALPHA, hole_new);
                }

            if( v > ALPHA )
                {
                MOVE_BATTLE = 1;
                EASY = 0;
                }

            if( v > ALPHA )
                v = -your_node_pv(-ALPHA - 1, -ALPHA, hole_new, check_move);

            if( v > ALPHA )
                v = -your_node_pv(-BETA, -ALPHA, hole_new, check_move);

            if( v <= ALPHA )
                v = ALPHA;
            }
        CANCEL(move);

        if( v <= ALPHA )
            TEMPvalue = low_orig;
        else
            TEMPvalue = v;
        p->move |= (TEMPvalue + 0x8000) << 16;

        if( v > value_better )
            {
            value_better = v;

            if( value_better == -VALUE_INFINITE || v > ALPHA )
                {
                root_move = move;
                root_value = v;
                root_hole = DEPTH;

				if ( (DEPTH > 10 && DEPTH <= 70 && TIME_DESIRED > 500000)
						|| (DEPTH > 18 && DEPTH <= 70 && TIME_DESIRED > 50000)
						|| (DEPTH > 70 && TIME_DESIRED > 30000000) || ANALYSIS )
					{
					if( v > ALPHA && v < BETA )
						information(clock_() - CLOCK_UCI, low_orig, v, BETA);
					else if( v < BETA )
						information(clock_() - CLOCK_UCI, low_orig, ALPHA, BETA);
					else if( v > ALPHA )
						information(clock_() - CLOCK_UCI, low_orig, BETA, BETA);
					}
                if( v >= root_previous - 25 )
                    MOVE_BAD = 0;
                else
                    {
                    MOVE_BAD = 1;
                    EASY = 0;
                    }
                }
            }

        if( v <= ALPHA )
            {
            if( cnt == 0 )
                {
                MOVE_BAD = 1;
                EASY = 0;
                }
            }
        else
            ALPHA = v;
        cnt++;

        if( v < BETA )
            {
            p++;
            continue;
            }
        break;
        }

    for ( p = ROOT_LIST_MOVE + (CNT - 1); p >= ROOT_LIST_MOVE; p-- )
        {
        move = p->move;

        for ( q = p + 1; q < ROOT_LIST_MOVE + CNT; q++ )
            {
            if( (move & 0xffff0000) < (q->move & 0xffff0000) )
                (q - 1)->move = q->move;
            else
                break;
            }
        q--;
        q->move = move;
        }

    root_hole = DEPTH;
    return value_better;
    }
