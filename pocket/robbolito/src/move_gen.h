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

#define ADD(LIST, x) (LIST++)->move = (x)
#define ANNEX_AI(T)              \
 {                               \
 while (T)                       \
   {                             \
   ai = BSF(T);                  \
   ADD(LIST, (qu << 6) | ai); \
   bit_FREE(ai, T);              \
   }                             \
}
#define RANK1 0x00000000000000ffull
#define RANK2 0x000000000000ff00ull
#define RANK7 0x00ff000000000000ull
#define RANK8 0xff00000000000000ull

type_list_move *capture_white( type_list_move *LIST, uint64 cel )
    {
    uint64 U, T;
    int qu, ai;

    if( (cel &DYNAMIC->attak_white) == 0 )
        goto TAG_NOT;
    T = ((bitboard_white_pawn & ~FILEa) << 7) & ( ~RANK8) &cel;

    while( T )
        {
        ai = BSF(T);
        ADD(LIST, ((ai - 7) << 6) | ai);
        bit_FREE(ai, T);
        }
    T = ((bitboard_white_pawn & ~FILEh) << 9) & ( ~RANK8) &cel;

    while( T )
        {
        ai = BSF(T);
        ADD(LIST, ((ai - 9) << 6) | ai);
        bit_FREE(ai, T);
        }

    for ( U = bitboard_white_knight; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        T = attack_knight[qu] & cel;
        ANNEX_AI(T);
        }

    for ( U = bitboard_white_bishop; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        T = attack_bishop(qu) & cel;
        ANNEX_AI(T);
        }

    for ( U = bitboard_white_rook; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        T = attack_rook(qu) & cel;
        ANNEX_AI(T);
        }

    for ( U = bitboard_white_queen; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        T = attack_queen(qu) & cel;
        ANNEX_AI(T);
        }
    qu = BSF(bitboard_white_king);
    T = attack_king[qu] & cel & ~DYNAMIC->attak_black;
    ANNEX_AI(T);
    TAG_NOT:
    for ( U = bitboard_white_pawn & RANK7; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        ai = qu + 8;

        if( QU[ai] == 0 )
            ADD(LIST, flag_promotion_queen | (qu << 6) | ai);
        ai = qu + 7;

        if( qu != A7 && square_fixed[ai] & cel )
            ADD(LIST, flag_promotion_queen | (qu << 6) | ai);
        ai = qu + 9;

        if( qu != H7 && square_fixed[ai] & cel )
            ADD(LIST, flag_promotion_queen | (qu << 6) | ai);
        }
    LIST->move = 0;
    return LIST;
    }
type_list_move *capture_black( type_list_move *LIST, uint64 cel )
    {
    uint64 U, T;
    int qu, ai;

    if( (cel &DYNAMIC->attak_black) == 0 )
        goto TAG_NOT;
    T = ((bitboard_black_pawn & ~FILEa) >> 9) & ( ~RANK1) &cel;

    while( T )
        {
        ai = BSF(T);
        ADD(LIST, ((ai + 9) << 6) | ai);
        bit_FREE(ai, T);
        }
    T = ((bitboard_black_pawn & ~FILEh) >> 7) & ( ~RANK1) &cel;

    while( T )
        {
        ai = BSF(T);
        ADD(LIST, ((ai + 7) << 6) | ai);
        bit_FREE(ai, T);
        }

    for ( U = bitboard_black_knight; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        T = attack_knight[qu] & cel;
        ANNEX_AI(T);
        }

    for ( U = bitboard_black_bishop; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        T = attack_bishop(qu) & cel;
        ANNEX_AI(T);
        }

    for ( U = bitboard_black_rook; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        T = attack_rook(qu) & cel;
        ANNEX_AI(T);
        }

    for ( U = bitboard_black_queen; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        T = attack_queen(qu) & cel;
        ANNEX_AI(T);
        }
    qu = BSF(bitboard_black_king);
    T = attack_king[qu] & cel & ~DYNAMIC->attak_white;
    ANNEX_AI(T);
    TAG_NOT:
    for ( U = bitboard_black_pawn & RANK2; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        ai = qu - 8;

        if( QU[ai] == 0 )
            ADD(LIST, flag_promotion_queen | (qu << 6) | ai);
        ai = qu - 9;

        if( qu != A2 && square_fixed[ai] & cel )
            ADD(LIST, flag_promotion_queen | (qu << 6) | ai);
        ai = qu - 7;

        if( qu != H2 && square_fixed[ai] & cel )
            ADD(LIST, flag_promotion_queen | (qu << 6) | ai);
        }
    LIST->move = 0;
    return LIST;
    }

type_list_move *capture_gen_total( type_list_move *LIST )
    {
    if( POSITION.white_en_move )
        return capture_white(LIST, bitboard_occupied_black);
    return capture_black(LIST, bitboard_occupied_white);
    }
