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
#include <time.h>
#include "monitor.h"
#include "search.h"
#include <math.h>

static sint64 SEND;
static sint64 TIME_MAX, INCREMENT;
static int DEPTH;
static bool HALT;
static bool total_moves;
static sint64 total_time_white, total_time_black;
static int movestogo_old = 0;

void search_halt( int tr )
    {
    HALT = TRUE;

    if( jump_ok )
        longjmp(J, 1);
    }

void notify( sint64 x )
    {
    uint64 t, u, nps, NODES = move_white_number + move_black_number + move_null_number;

    t = x / 1000;

    if( t == 0 )
        nps = 0;
    else
        nps = NODES / t;
    u = process_clock() - MOMENT;
    send_msg("info time %llu nodes %llu nps %llu cpuload %u\n", t, NODES, nps * 1000,
        (unsigned)((double)u / (double)((x - SEND) * numCPU) * 1000));
//     fflush(stdout);

    SEND = x;
    MOMENT += u;
    }

static sint64 TIME_BATTLE, TIME_EASY, TIME_ORDINARY;
void resolve_term( int d )
    {
    sint64 x, y;

    if( !jump_ok )
        return;

    x = clock_() - CLOCK;
    y = clock_() - CLOCK_UCI;
    node_count = node_frequency;

    if( PONDERING )
        x = -1000000;

    if( d == DEPTH )
        search_halt(1);

    if( y - SEND > 1000000 )
        notify(y);

    if( x > TIME_MAX )
        search_halt(1);

    if( d >= 0 && d < 8 )
        goto END;

    if( !MOVE_BAD && x >= TIME_BATTLE )
        search_halt(2);

    if( EASY && x >= TIME_EASY )
        search_halt(3);

    if( !MOVE_BATTLE && x >= TIME_ORDINARY && !MOVE_BAD )
        search_halt(4);
    END:
//     while( question_input() )
//         input_console();
       while (input_console())
        ;  
    }

#define Infinite 0xfffffffffffffffll
#define STRTOK(p) p = strtok (NULL, " ")

void search_initialization( char *str )
    {
    char *p;
    sint64 time_white = Infinite, time_black = Infinite, TIME, TOTAL_TIME;
    int inc_white = 0, inc_black = 0, movestogo = 0;
    int PTF = 0;

    DEPTH = 255;
    TIME_MAX = TIME_DESIRED = Infinite;
    HALT = FALSE;
    FIRST_TIME = TRUE;
    PONDERING = FALSE;
    time_factor = 1.0;
    SEND = 0;
    node_count = node_frequency = 4096;
    p = strtok(str, " ");

    for ( STRTOK(p); p != NULL; STRTOK(p) )
        {
        if( !strcmp(p, "depth") )
            {
            STRTOK(p);
            DEPTH = MAXIMUM(1, atoi(p));
            }
        else if( !strcmp(p, "movetime") )
            {
            STRTOK(p);
            TIME_MAX = MAXIMUM(1, _atoi64(p)) * 1000 - 10000;
            }
        else if( !strcmp(p, "wtime") )
            {
            STRTOK(p);
            time_white = _atoi64(p) * 1000;
            }
        else if( !strcmp(p, "winc") )
            {
            STRTOK(p);
            inc_white = atoi(p) * 1000;
            }
        else if( !strcmp(p, "btime") )
            {
            STRTOK(p);
            time_black = _atoi64(p) * 1000;
            }
        else if( !strcmp(p, "binc") )
            {
            STRTOK(p);
            inc_black = atoi(p) * 1000;
            }
        else if( !strcmp(p, "movestogo") )
            {
            STRTOK(p);
            movestogo = _atoi64(p);
            }
        else if( !strcmp(p, "ponder") && PONDER )
            {
            PONDERING = TRUE;
            continue;
            }

        else if( !strcmp(p, "infinite") )
            continue;

        else
            ERROR_("go string: %s", p);
        }

    if (PONDER)
    	if( MPH == 3 )
    		PTF = 6;
    	else if( MPH == 2 )
    		PTF = 4;

    TIME_BATTLE = Infinite;
    TIME_ORDINARY = Infinite;
    TIME_EASY = Infinite;

    TIME = POSITION.white_en_move ? time_white : time_black;

    if( TIME == Infinite )
        goto END;

    INCREMENT = POSITION.white_en_move ? inc_white : inc_black;
    if (INCREMENT < 0)
    	INCREMENT = 0;

    TIME = MAXIMUM(TIME - 500000, 9 * TIME / 10);
    if (TIME < 0)
    	TIME = 0;

    if( GAME_NEW || movestogo > movestogo_old )
        {
    	total_moves = movestogo;
    	total_time_white = MAXIMUM(time_white - 500000, 95 * time_white / 100);
    	total_time_black = MAXIMUM(time_black - 500000, 95 * time_black / 100);
        }
    TOTAL_TIME = POSITION.white_en_move ? total_time_white : total_time_black;

    if( movestogo )
        {
    	time_factor = (float)(TIME * total_moves) / (float)(TOTAL_TIME * movestogo);
    	movestogo_old = movestogo;

    	if ( time_factor < 1 )
    		TIME_DESIRED = TIME / movestogo + INCREMENT;
    	else
    		TIME_DESIRED = MINIMUM(TIME * time_factor * time_factor / movestogo + INCREMENT, TIME);

    	if( time_factor < 1.2 && movestogo > 2 )
    		TIME_MAX = MINIMUM(TIME * time_factor * (movestogo + 2) / (movestogo * 3), 6 * TIME_DESIRED);
    	else
    		TIME_MAX = TIME * (movestogo + 1) / (movestogo * 2);

    	if( TIME_MAX < 10000 )
    		TIME_MAX = 10000;
        }
    else
    {
    	if( (TIME / 20) > INCREMENT )
    	{
    		TIME_DESIRED = TIME / (((40 - PTF) * TIME / 20 - INCREMENT * 12) / (TIME / 20)) + INCREMENT;
    		TIME_MAX = TIME / ((5 * TIME / 20 - INCREMENT * 3) / (TIME / 20));
    	}
    	else
    	{
    		TIME_DESIRED = (TIME / (28 - PTF)) + INCREMENT;
    		TIME_MAX = TIME / 2;
    	}
    	if (TIME < 500000)
    	{
    		TIME_DESIRED = 5000;
    		TIME_MAX = 10000;
    	}
    	else if (TIME < 1000000 && INCREMENT < 500000)
    	{
    		TIME_DESIRED = TIME / 80;
    		TIME_MAX = TIME / 20;
    	}
    	else if (TIME < 2000000 && INCREMENT < 500000)
    	{
    		TIME_MAX = TIME / 10;
    	}
    }

    if( TIME_DESIRED < 5000 )
    	TIME_DESIRED = 5000;

    TIME_EASY = TIME_DESIRED / 4;
    TIME_BATTLE = TIME_DESIRED;
    TIME_ORDINARY = (3 * TIME_DESIRED) / 4;

    END:
    if( TIME == Infinite )
        ANALYSIS = TRUE;
    else
        ANALYSIS = FALSE;
    }
