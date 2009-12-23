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

#define TURN 8
#define HISTORY_GOOD(move, abyss)                      \
 { int sv = history_value[QU[DI (move)]][AI (move)];    \
   history_value[QU[DI (move)]][AI (move)] =            \
              sv + (( (0xff00 - sv) * abyss) >> TURN); \
   if (move != DYNAMIC->killer_one)                     \
   { DYNAMIC->killer_two = DYNAMIC->killer_one;         \
     DYNAMIC->killer_one = move; } }
#define HISTORY_BAD(move, abyss)                       \
 { int sv = history_value[QU[DI (move)]][AI (move)];    \
   if (POSITION_0->value > VALUE - 50)                  \
     history_value[QU[DI (move)]][AI (move)] = sv - ((sv * abyss) >> TURN); }
#define HISTORY_BAD_pv(move, abyss)                    \
 { int sv = history_value[QU[DI (move)]][AI (move)];    \
   if (POSITION_0->value > ALPHA - 50)                  \
     history_value[QU[DI (move)]][AI (move)] = sv - ((sv * abyss) >> TURN); }
