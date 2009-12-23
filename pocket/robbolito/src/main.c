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

type_pawn_value *pawn_zobrist;
static void pawn_zobrist_initialization()
    {
    pawn_zobrist = malloc(list_pawn_number * sizeof(type_pawn_value));
    memset(pawn_zobrist, 0, list_pawn_number * sizeof(type_pawn_value));
    }
void gain_reset()
    {
    int i, j;

    for ( j = 0; j < 0x10; j++ )
        for ( i = 0; i < 07777; i++ )
            maximum_positional_gain[j][i] = 0;
    }
void history_reset()
    {
    int piece, qu;

    for ( piece = 0; piece < 16; piece++ )
        for ( qu = A1; qu <= H8; qu++ )
            history_value[piece][qu] = 0x800;
    }

int main()
    {
    if (init_socket() != 0) {
      return 1;
    }
    show_version();
    pawn_zobrist_initialization();
    options_initialization();
    initialization_zobrist(HASH);
    history_reset();
    initialization_capture();
    pile_initialization();
    pawn_initialization();
    initialization_value();
    static_initialization();
    game_new(TRUE);

    while( 1 ) {
        while (input_console())
          ;
        my_usleep(10000);
    }
    return 0;
    }

