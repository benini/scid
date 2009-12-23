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

#define points(x,y) (((x)<<16)+(y))

#define distance_king_pawn_white(pe, re)                                \
  MAXIMUM ( ( ( re > pe) ? 3 : 6) * ABSOLUTE_ (RANK (pe) - RANK (re) ), \
            6 * ABSOLUTE_ (FILE (pe) - FILE (re) ) )
#define distance_king_pawn_black(pe,re)                                 \
  MAXIMUM ( ( ( re < pe) ? 3 : 6) * ABSOLUTE_ (RANK (pe) - RANK (re) ), \
            6 * ABSOLUTE_ ( FILE(pe) - FILE (re) ) )

static uint8 opposite_multiplier[9] =
    {
    6, 5, 4, 3, 2, 1, 0, 0, 0
    };
static uint8 count_multiplier[9] =
    {
    6, 5, 4, 3, 2, 1, 0, 0, 0
    };
static const uint8 pawn_stuck_value[64] =
	{
	0, 0, 0, 0, 0, 0, 0, 0,
	1, 1, 2, 2, 2, 2, 1, 1,
	1, 2, 3, 3, 3, 3, 2, 1,
	1, 2, 3, 5, 5, 3, 2, 1,
	1, 2, 3, 5, 5, 3, 2, 1,
	1, 2, 3, 3, 3, 3, 2, 1,
	1, 1, 2, 2, 2, 2, 1, 1,
	0, 0, 0, 0, 0, 0, 0, 0
	};
static const sint32 my_king_pawn_distance[8] =
    {
    0, 0, 0, 1, 2, 3, 5, 0
    };
static const sint32 mitu_king_pawn_distance[8] =
    {
    0, 0, 0, 2, 4, 6, 10, 0
    };
static const sint32 pawn_free_value[8] =
    {
    points(0, 0), points(0, 0), points(0, 0), points(10, 10), points(20, 25), points(40, 50), points(60, 75),
        points(0, 0)
    };
static const sint32 pawn_free_value_ampio[8] =
    {
    points(0, 0), points(0, 0), points(0, 0), points(0, 0), points(2, 5), points(5, 10), points(10, 20), points(0, 0)
    };
static const sint32 pawn_free_value_protected[8] =
    {
    points(0, 0), points(0, 0), points(0, 0), points(0, 0), points(5, 10), points(10, 15), points(15, 25), points(0, 0)
    };
static const sint32 pawn_free_value_connected[8] =
    {
    points(0, 0), points(0, 0), points(0, 0), points(0, 0), points(5, 10), points(10, 15), points(20, 30), points(0, 0)
    };

static const sint32 pawn_candidate_value[8] =
    {
    points(0, 0), points(0, 0), points(0, 0), points(5, 5), points(10, 12), points(20, 25), points(0, 0), points(0, 0)
    };
#define island points(0, 3)
#define hole points(1, 2)
#define double_off points(2, 4)
#define double_open points(4, 8)
#define double_off_isolated points(2, 4)
#define double_open_isolated points(6, 10)
#define isolated_off points(5, 8)
#define isolated_open points(15, 20)
#define delayed_off points(5, 5)
#define delayed_open points(10, 15)

#define king_attack_pawn points(0, 5)
#define king_oo points(5, 0)
#define king_ooo points(5, 0)
