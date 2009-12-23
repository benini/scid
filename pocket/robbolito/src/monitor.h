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

uint32 root_move;
uint32 ponder_move;
int root_value, root_previous;
int root_hole, hole_previous, root_rapid;
bool jump_ok;
bool EASY, MOVE_BAD, MOVE_BATTLE;
uint64 CLOCK, MOMENT, CLOCK_UCI;
bool ANALYSIS;
bool FIRST_TIME;
sint64 TIME_DESIRED;
float time_factor;
bool PONDER;
bool PONDERING;
int MPH;
int numCPU;
int HASH;
extern jmp_buf J;
