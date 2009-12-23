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

#include <string.h>

#define value_tempo 5
#define value_tempo2 5
#define pawn_plum 160
#define minor_plum 500
#define rook_plum 800
#define check_plum 10
#define value_lazy 150
#define value_lazy2 300
#define game_before ((DYNAMIC->material_ & 0xff) >= 18)

#define MAXIMUM_POSITIONAL(x)                              \
    ((int) maximum_positional_gain[QU[DI(x)]][x & 07777])
#define repetition_question(x)                             \
    (VALUE > x && POSITION_0->move50 >= 2 &&               \
    ((AI(move) << 6) | DI(move)) == (POSITION_0 -1 )->move \
    && QU[AI(move)] == 0)
#define INTERROGATIVE_INTERPOSITION(x) (x & (1 << 15))
#define see_easy(x) (x & 0x300000)

#define pawn_free_move(ai, x)        \
    (QU[ai] == count_my_pawn && x && \
    (bitboard_your_pawn & pawn_free[ai]) == 0)
#define PIECE_WHITE(piece) (piece <= 7)
#define PIECE_BLACK(piece) (piece >= 8)
