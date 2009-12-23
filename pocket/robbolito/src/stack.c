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

static int left54[64], straight54[64], left09[64];
static int TURN[64] =
    {
     1,  2,  2,  4,  4,  4,  7,  7,
	 7,  7, 11, 11, 11, 11, 11, 16,
	16, 16, 16, 16, 16, 22, 22, 22,
	22, 22, 22, 22, 29, 29, 29, 29,
	29, 29, 29, 29, 37, 37, 37, 37,
	37, 37, 37, 44, 44, 44, 44, 44,
	44, 50, 50, 50, 50, 50, 55, 55,
	55, 55, 59, 59, 59, 62, 62, 64
    };
static int LENGTH[64], WHERE[64];
static int JUMP[8] =
    {
    6, 10, 15, 17, -6, -10, -15, -17
    };
static uint64 rand0 = 1;
uint16 random16bits()
    {
    rand0 = rand0 * 8765432181103515245ull + 1234567891;
    return ((rand0 >> 32) % 65536);
    }
static uint64 RAND64()
    {
    return (((uint64)random16bits()) << 48) | (((uint64)random16bits()) << 32) | (((uint64)random16bits()) << 16)
        | (((uint64)random16bits()) << 0);
    }
void zobrist_init()
    {
    int i, j;
    zobrist_move_white = RAND64();
    zobrist_oo[0] = 0;
    zobrist_oo[1] = RAND64();
    zobrist_oo[2] = RAND64();
    zobrist_oo[4] = RAND64();
    zobrist_oo[8] = RAND64();

    for ( i = 0; i < 16; i++ )
        {
        if( POPCNT(i) < 2 )
            continue;
        zobrist_oo[i] = 0;

        for ( j = 1; j < 16; j <<= 1 )
            if( i & j )
                zobrist_oo[i] ^= zobrist_oo[j];
        }

    for ( i = 0; i < 16; i++ )
        for ( j = A1; j <= H8; j++ )
            ZOBRIST[i][j] = RAND64();

    for ( i = CA; i <= CH; i++ )
        zobrist_ep[i] = RAND64();
    }

void pile_initialization()
    {
    int qu2, l, w, i, qu = 0, j, u, co, tr, re, dir;
    uint64 T, b, s;

    for ( i = A1; i <= H8; i++ )
        {
        turn_left45[i] = TURN[left45[i]];
        turn_straight45[i] = TURN[straight45[i]];
        }

    for ( i = A1; i <= H8; i++ )
        {
        turn_normal[i] = 1 + (i & 56);
        turn_left90[i] = 1 + (left90[i] & 56);
        }

    for ( i = 1; i <= 8; i++ )
        for ( j = 1; j <= i; j++ )
            {
            LENGTH[qu] = i;
            WHERE[qu++] = j - 1;
            }

    for ( i = 7; i >= 1; i-- )
        for ( j = 1; j <= i; j++ )
            {
            LENGTH[qu] = i;
            WHERE[qu++] = j - 1;
            }

    for ( i = A1; i <= H8; i++ )
        {
        left54[left45[i]] = i;
        left09[left90[i]] = i;
        straight54[straight45[i]] = i;
        }

    for ( i = A1; i <= H8; i++ )
        {
        square_fixed[i] = 0;
        bitFIXED(i, square_fixed[i]);
        square_free[i] = ~square_fixed[i];
        }

    for ( i = A1; i <= H8; i++ )
        {
        left90_fixed[i] = 0;
        bitFIXED(left90[i], left90_fixed[i]);
        left90_reset[i] = ~left90_fixed[i];
        left45_fixed[i] = 0;
        bitFIXED(left45[i], left45_fixed[i]);
        left45_reset[i] = ~left45_fixed[i];
        straight45_fixed[i] = 0;
        bitFIXED(straight45[i], straight45_fixed[i]);
        straight45_reset[i] = ~straight45_fixed[i];
        }

    for ( i = A1; i <= H8; i++ )
        {
        attack_knight[i] = 0;

        for ( j = 0; j < 8; j++ )
            {
            qu = i + JUMP[j];

            if( (qu < A1) || (qu > H8) )
                continue;

            if( (file_detach(i, qu) > 2) || (rank_detach(i, qu) > 2) )
                continue;

            bitFIXED(qu, attack_knight[i]);
            }
        }

    for ( i = A1; i <= H8; i++ )
        {
        attack_king[i] = 0;

        for ( j = A1; j <= H8; j++ )
            {
            if( MAXIMUM(file_detach(i, j), rank_detach(i, j)) == 1 )
                bitFIXED(j, attack_king[i]);
            }
        }

    for ( i = A1; i <= H1; i++ )
        {
        attack_pawn_white[i] = 0;
        attack_pawn_black[i] = square_fixed[i + 7] | square_fixed[i + 9];
        }

    for ( i = A2; i <= H7; i++ )
        {
        attack_pawn_white[i] = square_fixed[i - 7] | square_fixed[i - 9];
        attack_pawn_black[i] = square_fixed[i + 7] | square_fixed[i + 9];
        }

    for ( i = A8; i <= H8; i++ )
        {
        attack_pawn_black[i] = 0;
        attack_pawn_white[i] = square_fixed[i - 7] | square_fixed[i - 9];
        }

    for ( i = A1; i <= A8; i += 8 )
        {
        attack_pawn_white[i] = square_fixed[i - 7];
        attack_pawn_black[i] = square_fixed[i + 9];
        }

    for ( i = H1; i <= H8; i += 8 )
        {
        attack_pawn_white[i] = square_fixed[i - 9];
        attack_pawn_black[i] = square_fixed[i + 7];
        }
    attack_pawn_white[A1] = 0;
    attack_pawn_white[A2] = square_fixed[B1];
    attack_pawn_black[A7] = square_fixed[B8];
    attack_pawn_black[A8] = 0;
    attack_pawn_white[H1] = 0;
    attack_pawn_white[H2] = square_fixed[G1];
    attack_pawn_black[H7] = square_fixed[G8];
    attack_pawn_black[H8] = 0;

    file_isolated[CA] = FILEb;
    file_isolated[CH] = FILEg;

    for ( co = CB; co <= CG; co++ )
        file_isolated[co] = pile_file[co - 1] | pile_file[co + 1];

    for ( qu = A1; qu <= H8; qu++ )
        {
        pile_isolated_white[qu] = 0;
        pile_isolated_black[qu] = 0;
        co = FILE(qu);
        tr = RANK(qu);

        if( tr < T8 )
            pile_isolated_white[qu] |= file_isolated[co] & pile_rank[tr + 1];

        if( tr < T7 )
            pile_isolated_white[qu] |= file_isolated[co] & pile_rank[tr + 2];

        if( tr > T1 )
            pile_isolated_black[qu] |= file_isolated[co] & pile_rank[tr - 1];

        if( tr > T2 )
            pile_isolated_black[qu] |= file_isolated[co] & pile_rank[tr - 2];
        pawn_connected[qu] = pile_isolated_white[qu] | pile_isolated_black[qu] | (pile_rank[tr]&file_isolated[co]);
        }

    for ( tr = T1; tr <= T8; tr++ )
        {
        infront_white[tr] = 0;

        for ( j = tr + 1; j <= T8; j++ )
            infront_white[tr] |= pile_rank[j];
        not_infront_white[tr] = ~infront_white[tr];
        }

    for ( tr = T8; tr >= T1; tr-- )
        {
        infront_black[tr] = 0;

        for ( j = tr - 1; j >= T1; j-- )
            infront_black[tr] |= pile_rank[j];
        not_infront_black[tr] = ~infront_black[tr];
        }

    for ( u = 0; u < 128; u += 2 )
        for ( co = CA; co <= CH; co++ )
            {
            T = 0;

            if( co < 7 )
                {
                s = 1 << (co + 1);

                while( s < 256 )
                    {
                    T |= s;

                    if( u & s )
                        break;

                    s <<= 1;
                    }
                }

            if( co > 0 )
                {
                s = 1 << (co - 1);

                while( s > 0 )
                    {
                    T |= s;

                    if( u & s )
                        break;

                    s >>= 1;
                    }
                }

            for ( i = 0; i < 8; i++ )
                attack_normal[co + 8 * i][u >> 1] = T << (8 * i);
            }

    for ( qu = A1; qu <= H8; qu++ )
        {
        pawn_free_white[qu] = (file_isolated[FILE(qu)] | pile_file[FILE(qu)]) & infront_white[RANK(qu)];
        pawn_free_black[qu] = (file_isolated[FILE(qu)] | pile_file[FILE(qu)]) & infront_black[RANK(qu)];
        }

    for ( qu = A1; qu <= H8; qu++ )
        {
        if( FILE(qu) >= CC )
            west_2[qu] = square_fixed[qu - 2];
        else
            west_2[qu] = 0;

        if( FILE(qu) <= CF )
            east_2[qu] = square_fixed[qu + 2];
        else
            east_2[qu] = 0;

        if( FILE(qu) >= CB )
            west_1[qu] = square_fixed[qu - 1];
        else
            west_1[qu] = 0;

        if( FILE(qu) <= CG )
            east_1[qu] = square_fixed[qu + 1];
        else
            east_1[qu] = 0;
        adjacent[qu] = west_1[qu] | east_1[qu];
        }

    for ( qu = A1; qu <= H8; qu++ )
        {
        pawn_protected_white[qu] = (file_isolated[FILE(qu)]) &not_infront_white[RANK(qu)];
        pawn_protected_black[qu] = (file_isolated[FILE(qu)]) &not_infront_black[RANK(qu)];
        }

    for ( qu = A1; qu <= H8; qu++ )
        {
        co = FILE(qu);
        tr = RANK(qu);
        diagonal_length[qu] = 0;

        if( co <= CD )
            {
            while( co < CH && tr < T8 )
                {
                co++;
                tr++;
                diagonal_length[qu] |= square_fixed[8 * tr + co];
                }
            co = FILE(qu);
            tr = RANK(qu);

            while( co < CH && tr > T1 )
                {
                co++;
                tr--;
                diagonal_length[qu] |= square_fixed[8 * tr + co];
                }
            }
        else
            {
            while( co > CA && tr < T8 )
                {
                co--;
                tr++;
                diagonal_length[qu] |= square_fixed[8 * tr + co];
                }
            co = FILE(qu);
            tr = RANK(qu);

            while( co > CA && tr > T1 )
                {
                co--;
                tr--;
                diagonal_length[qu] |= square_fixed[8 * tr + co];
                }
            }
        }

    for ( qu = A1; qu <= H8; qu++ )
        file_open_white[qu] = pile_file[FILE(qu)] & infront_white[RANK(qu)];

    for ( qu = A1; qu <= H8; qu++ )
        file_open_black[qu] = pile_file[FILE(qu)] & infront_black[RANK(qu)];

    for ( qu = A1; qu <= H8; qu++ )
        DOUBLE_[qu] = pile_file[FILE(qu)] ^ (((uint64)1) << qu);

    for ( qu = A1; qu <= H8; qu++ )
        for ( i = 0; i < 64; i++ )
            {
            T = attack_normal[left90[qu]][i];
            attack_left90[qu][i] = 0;

            while( T )
                {
                b = BSF(T);
                attack_left90[qu][i] |= square_fixed[left09[b]];
                bit_FREE(b, T);
                }
            }

    for ( u = 0; u < 128; u += 2 )
        for ( qu = A1; qu <= H8; qu++ )
            {
            T = 0;
            l = LENGTH[qu];
            w = WHERE[qu];
            attack_straight45[straight54[qu]][u >> 1] = 0;

            if( w < l )
                {
                s = 1 << (w + 1);

                while( s < (1 << l) )
                    {
                    T |= s;

                    if( u & s )
                        break;

                    s <<= 1;
                    }
                }

            if( w > 0 )
                {
                s = 1 << (w - 1);

                while( s > 0 )
                    {
                    T |= s;

                    if( u & s )
                        break;

                    s >>= 1;
                    }
                }
            T <<= (qu - w);

            while( T )
                {
                b = BSF(T);
                attack_straight45[straight54[qu]][u >> 1] |= square_fixed[straight54[b]];
                bit_FREE(b, T);
                }
            }

    for ( u = 0; u < 128; u += 2 )
        for ( qu = A1; qu <= H8; qu++ )
            {
            T = 0;
            l = LENGTH[qu];
            w = WHERE[qu];
            attack_left45[left54[qu]][u >> 1] = 0;

            if( w < l )
                {
                s = 1 << (w + 1);

                while( s < (1 << l) )
                    {
                    T |= s;

                    if( u & s )
                        break;

                    s <<= 1;
                    }
                }

            if( w > 0 )
                {
                s = 1 << (w - 1);

                while( s > 0 )
                    {
                    T |= s;

                    if( u & s )
                        break;

                    s >>= 1;
                    }
                }
            T <<= (qu - w);

            while( T )
                {
                b = BSF(T);
                attack_left45[left54[qu]][u >> 1] |= square_fixed[left54[b]];
                bit_FREE(b, T);
                }
            }

#define DISTANCE(i, j) \
    ( MAXIMUM (file_detach (i, j), rank_detach (i, j)) )

    for ( qu = A1; qu <= H8; qu++ )
        {
        quadrant_black_move_white[qu] = quadrant_black_move_black[qu] = 0;
        j = (qu & 7) + 56;

        if( RANK(qu) == T2 )
            qu2 = qu + 8;
        else
            qu2 = qu;

        for ( i = A1; i <= H8; i++ )
            {
            if( DISTANCE(qu2, j) < DISTANCE(j, i) - 1 )
                bitFIXED(i, quadrant_black_move_black[qu]);

            if( DISTANCE(qu2, j) < DISTANCE(j, i) )
                bitFIXED(i, quadrant_black_move_white[qu]);
            }
        }

    for ( qu = A1; qu <= H8; qu++ )
        {
        quadrant_white_move_white[qu] = quadrant_white_move_black[qu] = 0;
        j = (qu & 7);

        if( RANK(qu) == T7 )
            qu2 = qu - 8;
        else
            qu2 = qu;

        for ( i = A1; i <= H8; i++ )
            {
            if( DISTANCE(qu2, j) < DISTANCE(j, i) - 1 )
                bitFIXED(i, quadrant_white_move_white[qu]);

            if( DISTANCE(qu2, j) < DISTANCE(j, i) )
                bitFIXED(i, quadrant_white_move_black[qu]);
            }
        }

    for ( qu = A1; qu <= H8; qu++ )
        {
        white_guide[qu] = black_guide[qu] = 0;
        co = FILE(qu);

        if( co == CA || co == CH )
            T = file_isolated[co];
        else
            T = file_isolated[co] | pile_file[co];

        if( RANK(qu) >= T6 )
            white_guide[qu] |= (T &RANK8);

        if( RANK(qu) >= T5 )
            white_guide[qu] |= (T &RANK7);

        if( RANK(qu) <= T3 )
            black_guide[qu] |= (T &RANK1);

        if( RANK(qu) <= T4 )
            black_guide[qu] |= (T &RANK2);
        }

    for ( qu = A1; qu <= H8; qu++ )
        {
        north_west[qu] = (RANK(qu) != T8 && FILE(qu) != CA) ? square_fixed[qu + 7] : 0;
        north_east[qu] = (RANK(qu) != T8 && FILE(qu) != CH) ? square_fixed[qu + 9] : 0;
        south_west[qu] = (RANK(qu) != T1 && FILE(qu) != CA) ? square_fixed[qu - 9] : 0;
        south_east[qu] = (RANK(qu) != T1 && FILE(qu) != CH) ? square_fixed[qu - 7] : 0;
        }

    for ( qu = A1; qu <= H8; qu++ )
        for ( re = A1; re <= H8; re++ )
            {
            EVASION[re][qu] = attack_king[re];

            if( RANK(re) == RANK(qu) )
                {
                if( FILE(re) != CA )
                    EVASION[re][qu] ^= square_fixed[re - 1];

                if( FILE(re) != CH )
                    EVASION[re][qu] ^= square_fixed[re + 1];
                }

            if( FILE(re) == FILE(qu) )
                {
                if( RANK(re) != T1 )
                    EVASION[re][qu] ^= square_fixed[re - 8];

                if( RANK(re) != T8 )
                    EVASION[re][qu] ^= square_fixed[re + 8];
                }

            if( (RANK(re) - RANK(qu)) == (FILE(re) - FILE(qu)) )
                {
                if( RANK(re) != T8 && FILE(re) != CH )
                    EVASION[re][qu] ^= square_fixed[re + 9];

                if( RANK(re) != T1 && FILE(re) != CA )
                    EVASION[re][qu] ^= square_fixed[re - 9];
                }

            if( (RANK(re) - RANK(qu)) == (FILE(qu) - FILE(re)) )
                {
                if( RANK(re) != T8 && FILE(re) != CA )
                    EVASION[re][qu] ^= square_fixed[re + 7];

                if( RANK(re) != T1 && FILE(re) != CH )
                    EVASION[re][qu] ^= square_fixed[re - 7];
                }

            if( attack_king[re] & square_fixed[qu] )
                EVASION[re][qu] |= square_fixed[qu];
            }

    for ( co = CA; co <= CH; co++ )
        {
        files_lefts[co] = files_straights[co] = 0;

        for ( i = CA; i < co; i++ )
            files_lefts[co] |= pile_file[i];

        for ( i = co + 1; i <= CH; i++ )
            files_straights[co] |= pile_file[i];
        }

    for ( qu = A1; qu <= H8; qu++ )
        for ( re = A1; re <= H8; re++ )
            {
            INTERPOSITION[re][qu] = square_fixed[qu];
            dir = 0;

            if( RANK(re) == RANK(qu) )
                {
                if( re > qu )
                    dir = 1;
                else
                    dir = -1;
                }

            if( FILE(re) == FILE(qu) )
                {
                if( re > qu )
                    dir = 8;
                else
                    dir = -8;
                }

            if( (RANK(re) - RANK(qu)) == (FILE(re) - FILE(qu)) )
                {
                if( re > qu )
                    dir = 9;
                else
                    dir = -9;
                }

            if( (RANK(re) - RANK(qu)) == (FILE(qu) - FILE(re)) )
                {
                if( re > qu )
                    dir = 7;
                else
                    dir = -7;
                }

            if( dir )
                for ( i = qu; i != re; i += dir )
                    bitFIXED(i, INTERPOSITION[re][qu]);
            }

    for ( qu = A1; qu <= H8; qu++ )
        {
        perpendicular[qu] = pile_rank[RANK(qu)] | pile_file[FILE(qu)];
        diagonal[qu] = 0;

        for ( co = FILE(qu), tr = RANK(qu); co <= CH && tr <= T8; co++, tr++ )
            bitFIXED(8 * tr + co, diagonal[qu]);

        for ( co = FILE(qu), tr = RANK(qu); co <= CH && tr >= T1; co++, tr-- )
            bitFIXED(8 * tr + co, diagonal[qu]);

        for ( co = FILE(qu), tr = RANK(qu); co >= CA && tr <= T8; co--, tr++ )
            bitFIXED(8 * tr + co, diagonal[qu]);

        for ( co = FILE(qu), tr = RANK(qu); co >= CA && tr >= T1; co--, tr-- )
            bitFIXED(8 * tr + co, diagonal[qu]);
        perpendicular[qu] &= square_free[qu];
        diagonal[qu] &= square_free[qu];
        not_perpendicular[qu] = ~perpendicular[qu];
        not_diagonal[qu] = ~diagonal[qu];
        ortodiagonal[qu] = perpendicular[qu] | diagonal[qu];
        }

    for ( j = A1; j <= H8; j++ )
        for ( i = A1; i <= H8; i++ )
            {
            index_line[i][j] = direction_sick;

            if( i == j )
                continue;

            if( RANK(j) == RANK(i) )
                index_line[i][j] = direction_horizontal;

            if( FILE(j) == FILE(i) )
                index_line[i][j] = direction_vertical;

            if( (FILE(i) - FILE(j)) == (RANK(i) - RANK(j)) )
                index_line[i][j] = direction_a1h8;

            if( (FILE(j) - FILE(i)) == (RANK(i) - RANK(j)) )
                index_line[i][j] = direction_h1a8;
            }

    zobrist_init();
    }
