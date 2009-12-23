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

#ifndef BUILD_MOVE_NEAR_
#define BUILD_MOVE_NEAR_
#include "robbolito.h"
#include "move_near.c"
#include "white.h"
#else
#include "black.h"
#endif

#define RETURN(x) return(x)

uint32 my_next( type_next *NEXT )
    {
    type_list_move *p, *q, *list;
    uint32 move, TEMP;

    switch( NEXT->phase )
        {
        case TRAS:
            NEXT->phase = capture_gen;
            if( NEXT->move_trans && my_ensure(NEXT->move_trans) )
                RETURN(NEXT->move_trans);

        case capture_gen:
            NEXT->phase = move_capture;
            NEXT->move = 0;
            my_capture(NEXT->LIST, your_occupied);

        case move_capture:
            while( 1 )
                {
                p = NEXT->LIST + NEXT->move;
                move = p->move;

                if( !move )
                    break;
                q = p + 1;
                NEXT->move++;

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

                if( (move & 0x7fff) == NEXT->move_trans )
                    continue;

                if( !see_easy(move) && !my_see(move) )
                    NEXT->capture_bad[NEXT->cb++] = move;
                else
                    break;
                }
            if( move )
                RETURN(move);
            NEXT->phase = KILLER_ONE;
            move = DYNAMIC->killer_one;
            if( move && move != NEXT->move_trans && QU[AI(move)] == 0 && my_ensure(move) )
                RETURN(move);

        case KILLER_ONE:
            NEXT->phase = KILLER_TWO;
            move = DYNAMIC->killer_two;
            if( move && move != NEXT->move_trans && QU[AI(move)] == 0 && my_ensure(move) )
                RETURN(move);

        case KILLER_TWO:
            NEXT->phase = move_ordinary;
            NEXT->move = 0;
            list = my_ordinary(NEXT->LIST);
            sort_ordinary(NEXT->LIST, list, NEXT->move_trans, DYNAMIC->killer_one, DYNAMIC->killer_two);

        case move_ordinary:
            move = (NEXT->LIST + NEXT->move)->move;
            NEXT->move++;
            if( move )
                RETURN(move);
            NEXT->phase = capture_bad;
            NEXT->capture_bad[NEXT->cb] = 0;
            NEXT->move = 0;

        case capture_bad:
            move = NEXT->capture_bad[NEXT->move++];
            RETURN(move);
        /* */
        case TRAS2:
            NEXT->phase = capture_gen2;
            if( NEXT->move_trans && my_ensure(NEXT->move_trans) )
                RETURN(NEXT->move_trans);

        case capture_gen2:
            NEXT->phase = move_capture2;
            NEXT->move = 0;
            my_capture(NEXT->LIST, NEXT->tag);

        case move_capture2:
            while( 1 )
                {
                p = NEXT->LIST + NEXT->move;
                move = p->move;

                if( !move )
                    break;
                q = p + 1;
                NEXT->move++;

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

                if( (move & 0x7fff) == NEXT->move_trans )
                    continue;
                else
                    break;
                }
            if( move )
                RETURN(move);
            NEXT->move = 0;
            NEXT->phase = check_quiet;
            my_check_quiet(NEXT->LIST, NEXT->tag);

        case check_quiet:
            move = (NEXT->LIST + NEXT->move)->move;
            NEXT->move++;
            RETURN(move);
        /* */
        case elusione:
            move = (NEXT->LIST + NEXT->move)->move;
            NEXT->move++;
            RETURN(move);
        /* */
        case TRAS3:
            NEXT->phase = capture_gen3;
            if( NEXT->move_trans && my_ensure(NEXT->move_trans) )
                RETURN(NEXT->move_trans);

        case capture_gen3:
            NEXT->phase = move_capture3;
            NEXT->move = 0;
            my_capture(NEXT->LIST, your_occupied);

        case move_capture3:
            while( 1 )
                {
                p = NEXT->LIST + NEXT->move;
                move = p->move;

                if( !move )
                    break;
                q = p + 1;
                NEXT->move++;

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

                if( (move & 0x7fff) == NEXT->move_trans )
                    continue;
                else
                    break;
                }
            if( move )
                RETURN(move);
            NEXT->move = 0;
            NEXT->phase = check_quiet3;
            my_check_quiet(NEXT->LIST, your_occupied);

        case check_quiet3:
            move = (NEXT->LIST + NEXT->move)->move;
            NEXT->move++;
            if( move )
                RETURN(move);
            NEXT->move = 0;
            NEXT->phase = guadagno;
            my_gain(NEXT->LIST, NEXT->celare);

        case guadagno:
            move = (NEXT->LIST + NEXT->move)->move;
            NEXT->move++;
            RETURN(move);
        }
    return 0;
    }
