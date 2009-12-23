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

static __inline void null_do()
    {
    move_null_number++;
    DYNAMIC->flags_saves = DYNAMIC->flags;
    memcpy(DYNAMIC + 1, DYNAMIC, 64);
    DYNAMIC++;
    DYNAMIC->Zobrist ^= zobrist_move_white;
    POSITION.white_en_move ^= 1;
    DYNAMIC->move50++;

    if( DYNAMIC->en_passant )
        {
        DYNAMIC->Zobrist ^= zobrist_ep[DYNAMIC->en_passant & 7];
        DYNAMIC->en_passant = 0;
        }
    DYNAMIC->value = -((DYNAMIC - 1)->value + value_tempo);
    DYNAMIC->value_positional = (DYNAMIC - 1)->value_positional;
    DYNAMIC->lazy = (DYNAMIC - 1)->lazy;
    DYNAMIC->flags &= ~3;
    DYNAMIC->move = 0;
    STACK[++stack_height] = DYNAMIC->Zobrist;
    }

static __inline void null_cancel()
    {
    DYNAMIC--;
    stack_height--;
    POSITION.white_en_move ^= 1;
    DYNAMIC->flags = DYNAMIC->flags_saves;
    }

#define null_riduzione 8
