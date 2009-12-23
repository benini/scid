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
#include "pvalue.h"

typedef struct
    {
    uint64 BORDER, HALF, CENTER;
    uint8 refuge_border[8], refuge_half[8], refuge_center[8];
    uint8 hurricane_border[8], hurricane_half[8], hurricane_center[8], RIFdiag[8], zero, value_zero;
    } type_refuge_hurricane;

type_refuge_hurricane RIF_URA[8];

const uint8 RIFaa[8] =
    {
    30, 0, 5, 15, 20, 25, 25, 25
    };
const uint8 RIFab[8] =
    {
    55, 0, 15, 40, 50, 55, 55, 55
    };
const uint8 RIFac[8] =
    {
    30, 0, 10, 20, 25, 30, 30, 30
    };
const uint8 URAaa[8] =
    {
    5, 0, 35, 15, 5, 0, 0, 0
    };
const uint8 URAab[8] =
    {
    10, 0, 50, 20, 10, 0, 0, 0
    };
const uint8 URAac[8] =
    {
    10, 0, 50, 20, 10, 0, 0, 0
    };
const uint8 RIFba[8] =
    {
    30, 0, 5, 15, 20, 25, 25, 25
    };
const uint8 RIFbb[8] =
    {
    55, 0, 15, 40, 50, 55, 55, 55
    };
const uint8 RIFbc[8] =
    {
    30, 0, 10, 20, 25, 30, 30, 30
    };
const uint8 URAba[8] =
    {
    5, 0, 35, 15, 5, 0, 0, 0
    };
const uint8 URAbb[8] =
    {
    10, 0, 50, 20, 10, 0, 0, 0
    };
const uint8 URAbc[8] =
    {
    10, 0, 50, 20, 10, 0, 0, 0
    };
const uint8 RIFcb[8] =
    {
    30, 0, 5, 15, 20, 25, 25, 25
    };
const uint8 RIFcc[8] =
    {
    55, 0, 15, 40, 50, 55, 55, 55
    };
const uint8 RIFcd[8] =
    {
    30, 0, 10, 20, 25, 30, 30, 30
    };
const uint8 URAcb[8] =
    {
    5, 0, 35, 15, 5, 0, 0, 0
    };
const uint8 URAcc[8] =
    {
    10, 0, 50, 20, 10, 0, 0, 0
    };
const uint8 URAcd[8] =
    {
    10, 0, 50, 20, 10, 0, 0, 0
    };
const uint8 RIFdc[8] =
    {
    30, 0, 5, 15, 20, 25, 25, 25
    };
const uint8 RIFdd[8] =
    {
    55, 0, 15, 40, 50, 55, 55, 55
    };
const uint8 RIFde[8] =
    {
    30, 0, 10, 20, 25, 30, 30, 30
    };
const uint8 URAdc[8] =
    {
    5, 0, 35, 15, 5, 0, 0, 0
    };
const uint8 URAdd[8] =
    {
    10, 0, 50, 20, 10, 0, 0, 0
    };
const uint8 URAde[8] =
    {
    10, 0, 50, 20, 10, 0, 0, 0
    };
const uint8 RIFaDIAG[8] =
    {
    10, 0, 2, 4, 6, 8, 10, 10
    };
const uint8 RIFbDIAG[8] =
    {
    8, 0, 2, 4, 6, 7, 8, 8
    };
const uint8 RIFcDIAG[8] =
    {
    6, 0, 2, 3, 4, 5, 6, 6
    };
const uint8 RIFdDIAG[8] =
    {
    4, 0, 1, 2, 3, 4, 4, 4
    };
void pawn_initialization()
    {
    int co, tr;
    int tag[8] =
        {
        CB, CB, CC, CD, CE, CF, CG, CG
        };

    int change[8] =
        {
        1, 1, 1, 1, -1, -1, -1, -1
        };

    for ( co = CA; co <= CH; co++ )
        {
        RIF_URA[co].BORDER = pile_file[tag[co] - change[co]];
        RIF_URA[co].HALF = pile_file[tag[co]];
        RIF_URA[co].CENTER = pile_file[tag[co] + change[co]];
        }

    for ( tr = T1; tr <= T8; tr++ )
        {
        RIF_URA[CA].refuge_border[tr] = RIFaa[tr];
        RIF_URA[CA].hurricane_border[tr] = URAaa[tr];
        RIF_URA[CA].refuge_half[tr] = RIFab[tr];
        RIF_URA[CA].hurricane_half[tr] = URAab[tr];
        RIF_URA[CA].refuge_center[tr] = RIFac[tr];
        RIF_URA[CA].hurricane_center[tr] = URAac[tr];
        RIF_URA[CH].refuge_border[tr] = RIFaa[tr];
        RIF_URA[CH].hurricane_border[tr] = URAaa[tr];
        RIF_URA[CH].refuge_half[tr] = RIFab[tr];
        RIF_URA[CH].hurricane_half[tr] = URAab[tr];
        RIF_URA[CH].refuge_center[tr] = RIFac[tr];
        RIF_URA[CH].hurricane_center[tr] = URAac[tr];
        RIF_URA[CA].RIFdiag[tr] = RIFaDIAG[tr];
        RIF_URA[CH].RIFdiag[tr] = RIFaDIAG[tr];
        }

    for ( tr = T1; tr <= T8; tr++ )
        {
        RIF_URA[CB].refuge_border[tr] = RIFba[tr];
        RIF_URA[CB].hurricane_border[tr] = URAba[tr];
        RIF_URA[CB].refuge_half[tr] = RIFbb[tr];
        RIF_URA[CB].hurricane_half[tr] = URAbb[tr];
        RIF_URA[CB].refuge_center[tr] = RIFbc[tr];
        RIF_URA[CB].hurricane_center[tr] = URAbc[tr];
        RIF_URA[CG].refuge_border[tr] = RIFba[tr];
        RIF_URA[CG].hurricane_border[tr] = URAba[tr];
        RIF_URA[CG].refuge_half[tr] = RIFbb[tr];
        RIF_URA[CG].hurricane_half[tr] = URAbb[tr];
        RIF_URA[CG].refuge_center[tr] = RIFbc[tr];
        RIF_URA[CG].hurricane_center[tr] = URAbc[tr];
        RIF_URA[CB].RIFdiag[tr] = RIFbDIAG[tr];
        RIF_URA[CG].RIFdiag[tr] = RIFbDIAG[tr];
        }

    for ( tr = T1; tr <= T8; tr++ )
        {
        RIF_URA[CC].refuge_border[tr] = RIFcb[tr];
        RIF_URA[CC].hurricane_border[tr] = URAcb[tr];
        RIF_URA[CC].refuge_half[tr] = RIFcc[tr];
        RIF_URA[CC].hurricane_half[tr] = URAcc[tr];
        RIF_URA[CC].refuge_center[tr] = RIFcd[tr];
        RIF_URA[CC].hurricane_center[tr] = URAcd[tr];
        RIF_URA[CF].refuge_border[tr] = RIFcb[tr];
        RIF_URA[CF].hurricane_border[tr] = URAcb[tr];
        RIF_URA[CF].refuge_half[tr] = RIFcc[tr];
        RIF_URA[CF].hurricane_half[tr] = URAcc[tr];
        RIF_URA[CF].refuge_center[tr] = RIFcd[tr];
        RIF_URA[CF].hurricane_center[tr] = URAcd[tr];
        RIF_URA[CC].RIFdiag[tr] = RIFcDIAG[tr];
        RIF_URA[CF].RIFdiag[tr] = RIFcDIAG[tr];
        }

    for ( tr = T1; tr <= T8; tr++ )
        {
        RIF_URA[CD].refuge_border[tr] = RIFdc[tr];
        RIF_URA[CD].hurricane_border[tr] = URAdc[tr];
        RIF_URA[CD].refuge_half[tr] = RIFdd[tr];
        RIF_URA[CD].hurricane_half[tr] = URAdd[tr];
        RIF_URA[CD].refuge_center[tr] = RIFde[tr];
        RIF_URA[CD].hurricane_center[tr] = URAde[tr];
        RIF_URA[CE].refuge_border[tr] = RIFdc[tr];
        RIF_URA[CE].hurricane_border[tr] = URAdc[tr];
        RIF_URA[CE].refuge_half[tr] = RIFdd[tr];
        RIF_URA[CE].hurricane_half[tr] = URAdd[tr];
        RIF_URA[CE].refuge_center[tr] = RIFde[tr];
        RIF_URA[CE].hurricane_center[tr] = URAde[tr];
        RIF_URA[CD].RIFdiag[tr] = RIFdDIAG[tr];
        RIF_URA[CE].RIFdiag[tr] = RIFdDIAG[tr];
        }

    for ( co = CA; co <= CH; co++ )
        {
        RIF_URA[co].zero = RIF_URA[co].refuge_border[T2] + RIF_URA[co].refuge_half[T2] + RIF_URA[co].refuge_center[T2];
        RIF_URA[co].value_zero = 10;
        }
    }
static int king_white_periglio( int king_white_qu )
    {
    int e, rank_white_A, rank_white_B, rank_white_C, rank_black_A, rank_black_B, rank_black_C, v,
        tr = RANK(king_white_qu);
    uint64 T, A = bitboard_white_pawn & not_infront_black[tr];
    type_refuge_hurricane Z = RIF_URA[FILE(king_white_qu)];
    T = A & Z.BORDER;
    rank_white_A = BSF(T);

    if( !T )
        rank_white_A = 0;
    rank_white_A >>= 3;
    T = A & Z.HALF;
    rank_white_B = BSF(T);

    if( !T )
        rank_white_B = 0;
    rank_white_B >>= 3;
    T = A & Z.CENTER;
    rank_white_C = BSF(T);

    if( !T )
        rank_white_C = 0;
    rank_white_C >>= 3;
    T = bitboard_black_pawn & Z.BORDER;
    rank_black_A = BSF(T);

    if( !T )
        rank_black_A = 0;
    rank_black_A >>= 3;
    T = bitboard_black_pawn & Z.HALF;
    rank_black_B = BSF(T);

    if( !T )
        rank_black_B = 0;
    rank_black_B >>= 3;
    T = bitboard_black_pawn & Z.CENTER;
    rank_black_C = BSF(T);

    if( !T )
        rank_black_C = 0;
    rank_black_C >>= 3;
    v = (Z.refuge_border)[rank_white_A]+(Z.refuge_half)[rank_white_B]+(Z.refuge_center)[rank_white_C];

    if( v == Z.zero )
        v = Z.value_zero;
    T = A & diagonal_length[king_white_qu];
    e = BSF(T);

    if( !T )
        e = 0;
    e >>= 3;
    v += (Z.RIFdiag)[e];
    e = (Z.hurricane_border)[rank_black_A];

    if( rank_black_A == (rank_white_A + 1) )
        e >>= 1;
    v += e;
    e = (Z.hurricane_half)[rank_black_B];

    if( rank_black_B == (rank_white_B + 1) )
        e >>= 1;
    v += e;
    e = (Z.hurricane_center)[rank_black_C];

    if( rank_black_C == (rank_white_C + 1) )
        e >>= 1;
    v += e;
    return v;
    }
static int king_black_periglio( int king_black_qu )
    {
    int e, rank_white_A, rank_white_B, rank_white_C, rank_black_A, rank_black_B, rank_black_C, v,
        tr = RANK(king_black_qu);
    uint64 T, A = bitboard_black_pawn & not_infront_white[tr];
    type_refuge_hurricane Z = RIF_URA[FILE(king_black_qu)];
    T = A & Z.BORDER;
    rank_black_A = BSR(T);

    if( !T )
        rank_black_A = 56;
    rank_black_A >>= 3;
    rank_black_A = 7 - rank_black_A;
    T = A & Z.HALF;
    rank_black_B = BSR(T);

    if( !T )
        rank_black_B = 56;
    rank_black_B >>= 3;
    rank_black_B = 7 - rank_black_B;
    T = A & Z.CENTER;
    rank_black_C = BSR(T);

    if( !T )
        rank_black_C = 56;
    rank_black_C >>= 3;
    rank_black_C = 7 - rank_black_C;
    T = bitboard_white_pawn & Z.BORDER;
    rank_white_A = BSR(T);

    if( !T )
        rank_white_A = 56;
    rank_white_A >>= 3;
    rank_white_A = 7 - rank_white_A;
    T = bitboard_white_pawn & Z.HALF;
    rank_white_B = BSR(T);

    if( !T )
        rank_white_B = 56;
    rank_white_B >>= 3;
    rank_white_B = 7 - rank_white_B;
    T = bitboard_white_pawn & Z.CENTER;
    rank_white_C = BSR(T);

    if( !T )
        rank_white_C = 56;
    rank_white_C >>= 3;
    rank_white_C = 7 - rank_white_C;
    v = (Z.refuge_border)[rank_black_A]+(Z.refuge_half)[rank_black_B]+(Z.refuge_center)[rank_black_C];

    if( v == Z.zero )
        v = Z.value_zero;
    T = A & diagonal_length[king_black_qu];
    e = BSR(T);

    if( !T )
        e = 56;
    e >>= 3;
    e = 7 - e;
    v += (Z.RIFdiag)[e];
    e = (Z.hurricane_border)[rank_white_A];

    if( rank_white_A == (rank_black_A + 1) )
        e >>= 1;
    v += e;
    e = (Z.hurricane_half)[rank_white_B];

    if( rank_white_B == (rank_black_B + 1) )
        e >>= 1;
    v += e;
    e = (Z.hurricane_center)[rank_white_C];

    if( rank_white_C == (rank_black_C + 1) )
        e >>= 1;
    v += e;
    return v;
    }

void valuation_pawn( type_pawn_value *RISU )
    {
    int c, value = 0, B, distance_king_white, distance_king_black, distance_king_white_first, distance_king_black_first;
    int king_white_qu = POSITION.white_king_square, king_black_qu = POSITION.black_king_square;
    int b, tr, co, v, value_pawn_free;
    uint64 T, U, V, CONNECTED;

    RISU->white_pawn_clear = RISU->black_pawn_clear = RISU->white_pawn_dark = RISU->black_pawn_dark = 0;
    RISU->white_king_periglio = RISU->black_king_periglio = 0;
    RISU->white_pawn_free_line = RISU->black_pawn_free_line = 0;
    distance_king_black_first = distance_king_white_first = 30000;
    CONNECTED = 0;

    c = 0;

    for ( co = CA; co <= CH; co++ )
        {
        if( (bitboard_white_pawn &pile_file[co]) == 0 )
            c = 0;
        else
            {
            if( c == 0 )
                {
                value -= island;
                }
            c = 1;
            }
        }

    T = bitboard_white_pawn;

    while( T )
        {
        b = BSF(T);
        bit_FREE(b, T);
        tr = RANK(b);
        co = FILE(b);

        distance_king_white = distance_king_pawn_white(b, king_white_qu);

        if( distance_king_white < distance_king_white_first )
            distance_king_white_first = distance_king_white;
        distance_king_black = distance_king_pawn_white(b, king_black_qu);

        if( distance_king_black < distance_king_black_first )
            distance_king_black_first = distance_king_black;

        if( square_fixed[b] & CLEAR )
            {
            RISU->white_pawn_clear += pawn_stuck_value[b];

            if( QU[b + 8] == count_pawn_black )
                RISU->white_pawn_clear += pawn_stuck_value[b];
            }
        else
            {
            RISU->white_pawn_dark += pawn_stuck_value[b];

            if( QU[b + 8] == count_pawn_black )
                RISU->white_pawn_dark += pawn_stuck_value[b];
            }

        if( bitboard_white_pawn & west_2[b] && (bitboard_white_pawn &infront_white[tr - 1]&
        pile_file[co - 1]) == 0 )
            {
            value -= hole;
            }

        if( (bitboard_white_pawn | bitboard_black_pawn) & file_open_white[b] )
            {
            if( bitboard_white_pawn & DOUBLE_[b] )
                {
                value -= double_off;

                if( (bitboard_white_pawn &file_isolated[co]) == 0 )
                    {
                    value -= double_off_isolated;
                    }
                }

            if( (bitboard_white_pawn &file_isolated[co]) == 0 )
                {
                value -= isolated_off;
                continue;
                }

            if( (bitboard_white_pawn &pawn_protected_white[b]) == 0 )
                {
                B = b + 8;

                if( (bitboard_white_pawn &attack_pawn_black[b]) == 0 )
                    {
                    B += 8;

                    if( (bitboard_white_pawn &attack_pawn_black[b + 8]) == 0 )
                        B += 8;
                    }

                if( bitboard_black_pawn & attack_pawn_black[B] )
                    {
                    value -= delayed_off;
                    }
                }
            continue;
            }

        if( bitboard_white_pawn & DOUBLE_[b] )
            {
            value -= double_open;

            if( (bitboard_white_pawn &file_isolated[co]) == 0 )
                {
                value -= double_open_isolated;
                }
            }

        if( (bitboard_white_pawn &file_isolated[co]) == 0 )
            {
            value -= isolated_open;
            }
        else
            {
            if( (bitboard_white_pawn &pawn_protected_white[b]) == 0 )
                {
                B = b + 8;

                if( (bitboard_white_pawn &attack_pawn_black[b]) == 0 )
                    {
                    B += 8;

                    if( (bitboard_white_pawn &attack_pawn_black[b + 8]) == 0 )
                        B += 8;
                    }

                if( bitboard_black_pawn & attack_pawn_black[B] )
                    {
                    value -= delayed_open;
                    }
                }
            }

        if( (bitboard_black_pawn &pawn_free_white[b]) == 0 )
            goto FREE_WHITE;

        if( bitboard_black_pawn & pawn_free_white[b] & ~attack_pawn_black[b] )
            {
            value += pawn_candidate_value[tr];
            continue;
            }

        if( POPCNT(attack_pawn_black[b] & bitboard_black_pawn) > POPCNT(attack_pawn_white[b] & bitboard_white_pawn) )
            {
            value += pawn_candidate_value[tr];
            continue;
            }
        FREE_WHITE:
        value_pawn_free = pawn_free_value[tr];

        if( bitboard_white_pawn & attack_pawn_white[b] )
            value_pawn_free += pawn_free_value_protected[tr];

        if( (bitboard_black_pawn &files_lefts[co]) == 0 || (bitboard_black_pawn &files_straights[co]) == 0 )
            value_pawn_free += pawn_free_value_ampio[tr];

        V = pawn_connected[b] & CONNECTED;
        CONNECTED |= square_fixed[b];

        if( V )
            {
            value_pawn_free += pawn_free_value_connected[tr] + pawn_free_value_connected[RANK(BSF(V))];
            bit_FREE(0, V);

            if( V )
                value_pawn_free += pawn_free_value_connected[tr] + pawn_free_value_connected[RANK(BSF(V))];
            }
        value += value_pawn_free;
        RISU->white_pawn_free_line |= (uint8)(1 << co);

        if( b <= H3 )
            {
            continue;
            }
        value += (distance_king_pawn_white(b + 8, king_black_qu) * mitu_king_pawn_distance[RANK(b)]);
        value -= (distance_king_pawn_white(b + 8, king_white_qu) * my_king_pawn_distance[RANK(b)]);
        }

    c = 0;

    for ( co = CA; co <= CH; co++ )
        {
        if( (bitboard_black_pawn &pile_file[co]) == 0 )
            c = 0;
        else
            {
            if( c == 0 )
                {
                value += island;
                }
            c = 1;
            }
        }

    CONNECTED = 0;
    T = bitboard_black_pawn;

    while( T )
        {
        b = BSF(T);
        bit_FREE(b, T);
        tr = RANK(b);
        co = FILE(b);

        distance_king_black = distance_king_pawn_black(b, king_black_qu);

        if( distance_king_black < distance_king_black_first )
            distance_king_black_first = distance_king_black;
        distance_king_white = distance_king_pawn_black(b, king_white_qu);

        if( distance_king_white < distance_king_white_first )
            distance_king_white_first = distance_king_white;

        if( square_fixed[b] & CLEAR )
            {
            RISU->black_pawn_clear += pawn_stuck_value[b];

            if( QU[b - 8] == count_pawn_white )
                RISU->black_pawn_clear += pawn_stuck_value[b];
            }
        else
            {
            RISU->black_pawn_dark += pawn_stuck_value[b];

            if( QU[b - 8] == count_pawn_white )
                RISU->black_pawn_dark += pawn_stuck_value[b];
            }

        if( bitboard_black_pawn & west_2[b] && (bitboard_black_pawn &infront_black[tr + 1]&
        pile_file[co - 1]) == 0 )
            {
            value += hole;
            }

        if( (bitboard_white_pawn | bitboard_black_pawn) & file_open_black[b] )
            {
            if( bitboard_black_pawn & DOUBLE_[b] )
                {
                value += double_off;

                if( (bitboard_black_pawn &file_isolated[co]) == 0 )
                    {
                    value += double_off_isolated;
                    }
                }

            if( (bitboard_black_pawn &file_isolated[co]) == 0 )
                {
                value += isolated_off;
                continue;
                }

            if( (bitboard_black_pawn &pawn_protected_black[b]) == 0 )
                {
                B = b - 8;

                if( (bitboard_black_pawn &attack_pawn_white[b]) == 0 )
                    {
                    B -= 8;

                    if( (bitboard_black_pawn &attack_pawn_white[b - 8]) == 0 )
                        B -= 8;
                    }

                if( bitboard_white_pawn & attack_pawn_white[B] )
                    {
                    value += delayed_off;
                    }
                }
            continue;
            }

        if( bitboard_black_pawn & DOUBLE_[b] )
            {
            value += double_open;

            if( (bitboard_black_pawn &file_isolated[co]) == 0 )
                {
                value += double_open_isolated;
                }
            }

        if( (bitboard_black_pawn &file_isolated[co]) == 0 )
            {
            value += isolated_open;
            }
        else
            {
            if( (bitboard_black_pawn &pawn_protected_black[b]) == 0 )
                {
                B = b - 8;

                if( (bitboard_black_pawn &attack_pawn_white[b]) == 0 )
                    {
                    B -= 8;

                    if( (bitboard_black_pawn &attack_pawn_white[b - 8]) == 0 )
                        B -= 8;
                    }

                if( bitboard_white_pawn & attack_pawn_white[B] )
                    {
                    value += delayed_open;
                    }
                }
            }

        if( (bitboard_white_pawn &pawn_free_black[b]) == 0 )
            goto FREE_BLACK;

        if( bitboard_white_pawn & pawn_free_black[b] & ~attack_pawn_white[b] )
            {
            value -= pawn_candidate_value[7 - tr];
            continue;
            }

        if( POPCNT(attack_pawn_white[b] & bitboard_white_pawn) > POPCNT(attack_pawn_black[b] & bitboard_black_pawn) )
            {
            value -= pawn_candidate_value[7 - tr];
            continue;
            }
        FREE_BLACK:
        value_pawn_free = pawn_free_value[7 - tr];

        if( bitboard_black_pawn & attack_pawn_black[b] )
            value_pawn_free += pawn_free_value_protected[7 - tr];

        if( (bitboard_white_pawn &files_lefts[co]) == 0 || (bitboard_white_pawn &files_straights[co]) == 0 )
            value_pawn_free += pawn_free_value_ampio[7 - tr];

        V = pawn_connected[b] & CONNECTED;
        CONNECTED |= square_fixed[b];

        if( V )
            {
            value_pawn_free += pawn_free_value_connected[7 - tr] + pawn_free_value_connected[7 - (BSF(V) >> 3)];
            bit_FREE(0, V);

            if( V )
                value_pawn_free += pawn_free_value_connected[7 - tr] + pawn_free_value_connected[7 - (BSF(V) >> 3)];
            }

        value -= value_pawn_free;
        RISU->black_pawn_free_line |= (uint8)(1 << co);

        if( b >= A6 )
            {
            continue;
            }
        value -= (distance_king_pawn_black(b - 8, king_white_qu) * mitu_king_pawn_distance[T8 - RANK(b)]);
        value += (distance_king_pawn_black(b - 8, king_black_qu) * my_king_pawn_distance[T8 - RANK(b)]);
        }

    T = 0;

    for ( tr = T2; tr <= T7; tr++ )
        T |= ((bitboard_white_pawn >> (8 * tr)) & 0xff);
    U = 0;

    for ( tr = T2; tr <= T7; tr++ )
        U |= ((bitboard_black_pawn >> (8 * tr)) & 0xff);
    RISU->white_pawn_line_count = POPCNT(T);
    RISU->black_pawn_line_count = POPCNT(U);
    RISU->open_file_count = 8 - POPCNT(T | U);
    RISU->white_fly_number = opposite_multiplier[POPCNT(T & ~U)] * count_multiplier[RISU->white_pawn_line_count];
    RISU->black_fly_number = opposite_multiplier[POPCNT(U & ~T)] * count_multiplier[RISU->black_pawn_line_count];

    if( bitboard_white_pawn | bitboard_black_pawn )
        {
        value += distance_king_black_first - distance_king_white_first;
        }

    T = ((bitboard_black_pawn &( ~FILEa)) >> 9) | ((bitboard_black_pawn &( ~FILEh)) >> 7);

    if( ( ~T) &attack_king[king_white_qu] & bitboard_black_pawn )
        {
        value += king_attack_pawn;
        }

    if( DYNAMIC->castle & 1 )
        {
        value += king_oo;
        }

    if( DYNAMIC->castle & 2 )
        {
        value += king_ooo;
        }

    T = ((bitboard_white_pawn &( ~FILEa)) << 7) | ((bitboard_white_pawn &( ~FILEh)) << 9);

    if( ( ~T) &attack_king[king_black_qu] & bitboard_white_pawn )
        {
        value -= king_attack_pawn;
        }

    if( DYNAMIC->castle & 4 )
        {
        value -= king_oo;
        }

    if( DYNAMIC->castle & 8 )
        {
        value -= king_ooo;
        }

    RISU->ZobristPawn = DYNAMIC->ZobristPawn;
    RISU->points = value;

    v = king_white_periglio(king_white_qu);

    if( castling_white_oo )
        v = MINIMUM(v, 5 + king_white_periglio(G1));

    if( castling_white_ooo )
        v = MINIMUM(v, 5 + king_white_periglio(C1));
    RISU->white_king_periglio = points(v, 0);
    v = king_black_periglio(king_black_qu);

    if( castling_black_oo )
        v = MINIMUM(v, 5 + king_black_periglio(G8));

    if( castling_black_ooo )
        v = MINIMUM(v, 5 + king_black_periglio(C8));
    RISU->black_king_periglio = points(v, 0);
    }
