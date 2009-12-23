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
#include "monitor.h"
#include "move_null.h"
#include <time.h>

#define LEGAL (POSITION.white_en_move ? !black_in_check : !white_in_check)
#define CHECK (POSITION.white_en_move ? white_in_check: black_in_check)

jmp_buf J;

void output_best_move()
    {
    if( !root_move )
        {
        send_msg("bestmove NULL\n");
        //fflush(stdout);
        return;
        }
    make(root_move);
    call_value_full(0);
    cancel(root_move);
    send_msg("bestmove %s ponder %s\n", move_notation(root_move, STRING1), move_notation(ponder_move, STRING2));
//     fflush(stdout);

    }
static char *modifier( int ALPHA, int value, int BETA, char *s )
    {
    s[0] = 0;
	if( value <= ALPHA )
		strcpy(s, "upperbound");
    else if( value >= BETA )
        strcpy(s, "lowerbound");
    else
		strcpy(s, "");
    return s;
    }

static char *cp_mate( int value, char *s )
    {
    if( value > VALUE_MATE - hole_maximum )
        sprintf(s, "mate %d", (VALUE_MATE + 1 - value) / 2);

    else if( value < -VALUE_MATE + hole_maximum )
        sprintf(s, "mate %d", (-VALUE_MATE - value) / 2);

    else
        sprintf(s, "cp %d", value);
    return s;
    }

void information( sint64 x, int ALPHA, int value, int BETA )
    {
    sint64 t, nps, NODES = move_white_number + move_black_number + move_null_number;
    int sd, i, k, move, trans_hole;
    type_dynamic *p;
    char pv[256 * 6], *q;
    type_zobrist_pv *tr;
    uint64 zobrist_stack[256];
    int cnt = 0;
    int pv_move = 0;
    bool B;

    for ( p = dynamic_initial + 1; p->Zobrist; p++ );
    sd = p - (dynamic_initial + 1);
    memset(zobrist_stack, 0, 256 * sizeof(uint64));
    t = x / 1000;

    if( t == 0 )
        nps = 0;
    else
        nps = NODES / t;
    q = pv;
    zobrist_stack[cnt++] = DYNAMIC->Zobrist;
    move_notation(root_move, STRING1);
    strcpy(q, STRING1);
    q += strlen(STRING1);
    strcpy(q, " ");
    q++;
    move = root_move;

    while( move )
        {
        make(move);
		pv_move++;
		if (pv_move == 2)
			ponder_move = move;

        call_value_full(0);
        B = FALSE;

        for ( i = 0; i < cnt; i++ )
            if( zobrist_stack[i] == DYNAMIC->Zobrist )
                B = TRUE;

        if( B )
            break;
        zobrist_stack[cnt++] = DYNAMIC->Zobrist;
        move = 0;
        k = DYNAMIC->Zobrist & list_hide_pv;
        trans_hole = 0;

        for ( i = 0; i < 4; i++ )
            {
            tr = list_zobrist_pv + (k + i);

            if( tr->zobrist == DYNAMIC->Zobrist )
                {
                move = tr->move;
                break;
                }
            }

        if( !move || (POSITION.white_en_move ? !ensure_white(move) : !ensure_black(move)) )
            break;

        if( cnt > 250 )
            break;

		move_notation(move, STRING1);
        strcpy(q, STRING1);
        q += strlen(STRING1);
        strcpy(q, " ");
        q++;
        }
    q--;
    *q = 0;

    while( DYNAMIC != (dynamic_initial + 1) )
        {
        if( !DYNAMIC->move )
            null_cancel();
        else
            cancel(DYNAMIC->move);
        }
    send_msg("info depth %d seldepth %d score %s %s time %lld nodes %lld nps %lld pv %s", root_hole / 2, sd,
        cp_mate(value, STRING2), modifier(ALPHA, value, BETA, STRING3), t, NODES, nps * 1000, pv);
    if( FIRST_TIME && x > 200000)
    {
        send_msg(" cpuload %u", (unsigned)((double)(process_clock() - MOMENT) / (double)(x * numCPU) * 1000));
        FIRST_TIME = FALSE;
    }
    send_msg("\n");
    //fflush(stdout);
    }

void search()
    {
    int z;
    type_dynamic *p, *q;
    GAME_NEW = FALSE;
    CLOCK = CLOCK_UCI = clock_();
    MOMENT = process_clock();
    stack_height = -1;
    root_move = ponder_move = root_hole = root_value = 0;
    move_white_number = move_black_number = move_null_number = 0;

    for ( p = dynamic_initial; p <= DYNAMIC; p++ )
        STACK[++stack_height] = p->Zobrist;

    if( ANALYSIS )
        {
        bool REPETITION;

        for ( p = dynamic_initial; p < DYNAMIC; p++ )
            {
            REPETITION = FALSE;

            for ( q = p + 2; q < DYNAMIC; q += 2 )
                if( p->Zobrist == q->Zobrist )
                    {
                    REPETITION = TRUE;
                    break;
                    }

            if( !REPETITION )
                STACK[p - dynamic_initial] = 0;
            (p + 1)->move = 0;
            }
        }
    memcpy(dynamic_initial + 1, DYNAMIC, sizeof(type_dynamic));
    memset(dynamic_initial + 2, 0, 254 * sizeof(type_dynamic));
    memset(dynamic_initial, 0, sizeof(type_dynamic));
    DYNAMIC = dynamic_initial + 1;
    year_increase();
    root_previous = -VALUE_MATE;
    EASY = FALSE;
    jump_ok = TRUE;
    z = setjmp(J);

    if( !z )
        {
        if( POSITION.white_en_move )
            search_high_white();
        else
            search_high_black();
        }
    jump_ok = FALSE;
    hole_previous = root_hole;

    while( DYNAMIC != (dynamic_initial + 1) )
        {
        if( !DYNAMIC->move )
            null_cancel();
        else
            cancel(DYNAMIC->move);
        }
    information(clock_() - CLOCK_UCI, -32767, root_value, 32767);
    output_best_move();
    }
