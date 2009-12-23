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

#ifndef BUILD_MOVE_GEN
#define BUILD_MOVE_GEN
#include "robbolito.h"

#define ADD(L, x, y) { (L++)->move = (x) | (y);}
#define ANNEX_AI(T, w)                  \
  { while (T)                           \
      { ai = BSF(T);                    \
      c = QU[ai];                       \
      ADD (LIST, (qu << 6) | ai, w); \
      bit_FREE (ai, T); } }
#include "init_gen.h"

#define pawn_queen ( 0xd8 << 24 )
#define pawn_knight ( 0xc2 << 24 )
#define flag_check 0x8000

#define move_ANNEX(L, x, piece, ai, sca)                      \
  { (L++)->move = (x)                                         \
  | ( (square_fixed[ai] & (sca) ) ? flag_check : 0)          \
  | ( history_value[piece][ai] << 16); }
#define ANNEX_AI_ORD(T, piece, sca)                           \
 { while (T)                                                  \
     { ai = BSF(T);                                           \
     move_ANNEX (LIST, (qu << 6) | ai, piece, ai, sca);       \
     bit_FREE (ai, T); } }
#define under_promotion_white()                               \
  { if ( (attack_knight[ai] & bitboard_black_king) == 0)      \
  move_ANNEX ( LIST, flag_promotion_knight | (qu << 6) | ai, \
  count_pawn_white, ai, 0);                                   \
  move_ANNEX (LIST, flag_promotion_rook | (qu << 6) | ai,    \
  count_pawn_white, ai, 0);                                   \
  move_ANNEX (LIST, flag_promotion_bishop | (qu << 6) | ai,  \
  count_pawn_white, ai, 0); }
#define under_promotion_black()                               \
  { if ( (attack_knight[ai] & bitboard_white_king) == 0)      \
  move_ANNEX (LIST, flag_promotion_knight | (qu << 6) | ai,  \
  count_pawn_black, ai, 0);                                   \
  move_ANNEX (LIST, flag_promotion_rook | (qu << 6) | ai,    \
  count_pawn_black, ai, 0);                                   \
  move_ANNEX (LIST, flag_promotion_bishop | (qu << 6) | ai,  \
  count_pawn_black, ai, 0); }
#define OK(x)                                                 \
    ( ((x & 0x7fff) != s1) && ((x & 0x7fff) != s2) && ((x & 0x7fff) != s3) )

void sort_ordinary( type_list_move *m1, type_list_move *m2, uint32 s1, uint32 s2, uint32 s3 )
    {
    type_list_move *p, *q;
    int move;

    if( m1 == m2 )
        return;

    for ( p = m2 - 1; p >= m1; p-- )
        {
        if( OK(p->move) )
            break;
        p->move = 0;
        }

    while( p > m1 )
        {
        p--;
        move = p->move;

        if( OK(move) )
            {
            for ( q = p + 1; q < m2; q++ )
                {
                if( move < q->move )
                    (q - 1)->move = q->move;
                else
                    break;
                }
            q--;
            q->move = move;
            }
        else
            {
            m2--;

            for ( q = p; q < m2; q++ )
                q->move = (q + 1)->move;
            m2->move = 0;
            }
        }
    }

#define gain_ANNEX(L, x, piece, ai)                             \
{ int v = ( (int) maximum_positional_gain[piece][(x) & 07777]); \
    if (v >= av) (L++)->move = (x) | (v << 16); }
#define gain_ANNEX_AI(T, piece)                                 \
{ while (T)                                                     \
{ ai = BSF(T);                                                  \
    gain_ANNEX (LIST, (qu << 6) | ai, piece, ai);               \
    bit_FREE(ai, T); } }
#define SORT                                                   \
    for (p = LIST - 1; p >= sm; p--)                            \
{ move = p->move;                                               \
    for (q = p + 1; q < LIST; q++)                              \
{ if ( move<q->move ) (q - 1)->move = q->move;                  \
      else break;                                               \
}                                                               \
    q--;                                                        \
    q->move = move; }

type_list_move *evasion_move( type_list_move *list, uint64 cel )
    {
    if( POSITION.white_en_move )
        return evasion_white(list, cel);
    return evasion_black(list, cel);
    }
type_list_move *ordinary_move( type_list_move *list )
    {
    if( POSITION.white_en_move )
        return ordinary_white(list);
    return ordinary_black(list);
    }
type_list_move *capture_move( type_list_move *list, uint64 cel )
    {
    if( POSITION.white_en_move )
        return capture_white(list, cel & bitboard_occupied_black);
    return capture_black(list, cel & bitboard_occupied_white);
    }
#include "move_gen.c"
#include "white.h"
#else
#include "black.h"
#endif

type_list_move *my_evasion( type_list_move *LIST, uint64 c2 )
    {
    uint64 U, T, attack, cel;
    int qu, ai, di, c, re, piece;
    re = my_square_king;
    attack = my_king_check;
    qu = BSF(attack);
    piece = QU[qu];
    cel = ( ~your_attack) &(((piece == count_your_pawn) ? attack_king[re] : 0) | EVASION[re][qu]) & ( ~my_occupied) &c2;
    bit_FREE(qu, attack);

    if( attack )
        {
        qu = BSF(attack);
        piece = QU[qu];
        cel = cel &(your_pawn(piece) | EVASION[re][qu]);
        qu = re;
        ANNEX_AI(cel, capture_value[count_my_king][c]);
        LIST->move = 0;
        return LIST;
        }
    c2 &= INTERPOSITION[re][qu];
    qu = re;
    ANNEX_AI(cel, capture_value[count_my_king][c]);

    if( !c2 )
        {
        LIST->move = 0;
        return LIST;
        }

    if( capture_straight &(c2 & your_occupied) )
        {
        ai = BSF(c2 & your_occupied);
        c = QU[ai];

        if( RANK_EIGHT(ai) )
            {
            ADD(LIST, flag_promotion_queen | di_left(ai) | ai, (0x20 << 24) + capture_value[count_my_pawn][c]);
            ADD(LIST, flag_promotion_knight | di_left(ai) | ai, 0);
            ADD(LIST, flag_promotion_rook | di_left(ai) | ai, 0);
            ADD(LIST, flag_promotion_bishop | di_left(ai) | ai, 0);
            }
        else
            ADD(LIST, di_left(ai) | ai, capture_value[count_my_pawn][c]);
        }

    if( capture_left &(c2 & your_occupied) )
        {
        ai = BSF(c2 & your_occupied);
        c = QU[ai];

        if( RANK_EIGHT(ai) )
            {
            ADD(LIST, flag_promotion_queen | di_straight(ai) | ai, (0x20 << 24) + capture_value[count_my_pawn][c]);
            ADD(LIST, flag_promotion_knight | di_straight(ai) | ai, 0);
            ADD(LIST, flag_promotion_rook | di_straight(ai) | ai, 0);
            ADD(LIST, flag_promotion_bishop | di_straight(ai) | ai, 0);
            }
        else
            ADD(LIST, di_straight(ai) | ai, capture_value[count_my_pawn][c]);
        }
    ai = ep_plate;

    if( ai )
        {
        if( capture_straight & square_fixed[ai] && square_fixed[back(ai)] & c2 )
            ADD(LIST, flag_en_passant | di_left(ai) | ai, capture_value[count_my_pawn][count_your_pawn]);

        if( capture_left & square_fixed[ai] && square_fixed[back(ai)] & c2 )
            ADD(LIST, flag_en_passant | di_straight(ai) | ai, capture_value[count_my_pawn][count_your_pawn]);
        }
    T = bitboard_my_pawn & back_turn((c2 &your_occupied) ^ c2);

    while( T )
        {
        di = BSF(T);
        bit_FREE(di, T);

        if( RANK_SEVEN(di) )
            {
            ADD(LIST, flag_promotion_queen | (di << 6) | forward(di), capture_value[count_my_pawn][0]);
            ADD(LIST, flag_promotion_knight | (di << 6) | forward(di), 0);
            ADD(LIST, flag_promotion_rook | (di << 6) | forward(di), 0);
            ADD(LIST, flag_promotion_bishop | (di << 6) | forward(di), 0);
            }
        else
            ADD(LIST, (di << 6) | forward(di), capture_value[count_my_pawn][0]);
        }

    T =
        bitboard_my_pawn & back_turn_two((c2 &your_occupied)
            ^ c2) & RANK_SECOND & back_turn( ~POSITION.occupied_black_white);

    while( T )
        {
        di = BSF(T);
        bit_FREE(di, T);
        ADD(LIST, (di << 6) | forward_two(di), capture_value[count_my_pawn][0]);
        }

    for ( U = bitboard_my_knight; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        T = attack_knight[qu] & c2;
        ANNEX_AI(T, capture_value[count_my_knight][c]);
        }

    for ( U = bitboard_my_bishop; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        T = attack_bishop(qu) & c2;
        ANNEX_AI(T, capture_value[count_my_clear][c]);
        }

    for ( U = bitboard_my_rook; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        T = attack_rook(qu) & c2;
        ANNEX_AI(T, capture_value[count_my_rook][c]);
        }

    for ( U = bitboard_my_queen; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        T = attack_queen(qu) & c2;
        ANNEX_AI(T, capture_value[count_my_queen][c]);
        }
    LIST->move = 0;
    return LIST;
    }
type_list_move *my_gain( type_list_move *LIST, int av )
    {
    uint64 empty = ~POSITION.occupied_black_white, U, T;
    int ai, qu;
    type_list_move *sm, *p, *q;
    int move;
    sm = LIST;

    for ( U = forward_turn(bitboard_my_pawn & RANK_SECOND_SIX) & empty; U; bit_FREE(qu, U) )
        {
        ai = BSF(U);

        if( en_rank_third(ai) && QU[forward(ai)] == 0 )
            gain_ANNEX(LIST, (back(ai) << 6) | forward(ai), count_my_pawn, forward(ai));
        gain_ANNEX(LIST, (back(ai) << 6) | ai, count_my_pawn, ai);
        }

    for ( U = bitboard_my_knight; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        T = attack_knight[qu] & empty;
        gain_ANNEX_AI(T, count_my_knight);
        }

    for ( U = bitboard_my_clear; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        T = attack_bishop(qu) & empty;
        gain_ANNEX_AI(T, count_my_clear);
        }

    for ( U = bitboard_my_dark; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        T = attack_bishop(qu) & empty;
        gain_ANNEX_AI(T, count_my_dark);
        }

    for ( U = bitboard_my_rook; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        T = attack_rook(qu) & empty;
        gain_ANNEX_AI(T, count_my_rook);
        }

    for ( U = bitboard_my_queen; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        T = attack_queen(qu) & empty;
        gain_ANNEX_AI(T, count_my_queen);
        }
    qu = my_square_king;
    T = attack_king[qu] & empty &( ~your_attack);
    gain_ANNEX_AI(T, count_my_king);
    LIST->move = 0;
    SORT;
    return LIST;
    }
type_list_move *my_capture( type_list_move *LIST, uint64 cel )
    {
    uint64 U, T, AT, AA;
    int qu, ai, c;
    ai = ep_plate;

    if( ai )
        {
        if( capture_left & square_fixed[ai] )
            ADD(LIST, flag_en_passant | di_straight(ai) | ai, capture_en_passant);

        if( capture_straight & square_fixed[ai] )
            ADD(LIST, flag_en_passant | di_left(ai) | ai, capture_en_passant);
        }

    if( (cel &my_attack) == 0 )
        goto TAG_NOT;

    T = capture_left &( ~bitboard_rank_eighth) & cel;

    while( T )
        {
        ai = BSF(T);
        c = QU[ai];
        ADD(LIST, di_straight(ai) | ai, capture_value[count_my_pawn][c]);
        bit_FREE(ai, T);
        }
    T = capture_straight &( ~bitboard_rank_eighth) & cel;

    while( T )
        {
        ai = BSF(T);
        c = QU[ai];
        ADD(LIST, di_left(ai) | ai, capture_value[count_my_pawn][c]);
        bit_FREE(ai, T);
        }

    for ( U = bitboard_my_knight; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        T = attack_knight[qu] & cel;
        ANNEX_AI(T, capture_value[count_my_knight][c]);
        }

    for ( U = bitboard_my_bishop; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        AA = attack_bishop(qu);
        T = AA & cel;
        ANNEX_AI(T, capture_value[count_my_clear][c]);
        }

    for ( U = bitboard_my_rook; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        AT = attack_rook(qu);
        T = AT & cel;
        ANNEX_AI(T, capture_value[count_my_rook][c]);
        }

    for ( U = bitboard_my_queen; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        AT = attack_rook(qu);
        AA = attack_bishop(qu);
        T = (AA | AT) & cel;
        ANNEX_AI(T, capture_value[count_my_queen][c]);
        }
    qu = BSF(bitboard_my_king);
    T = attack_king[qu] & cel;
    ANNEX_AI(T, capture_value[count_my_king][c]);
    TAG_NOT:
    for ( U = bitboard_my_pawn & bitboard_rank_seventh; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        ai = forward(qu);

        if( QU[ai] == 0 )
            {
            ADD(LIST, flag_promotion_queen | (qu << 6) | ai, pawn_queen);

            if( attack_knight[ai] & bitboard_your_king )
                ADD(LIST, flag_promotion_knight | (qu << 6) | ai, pawn_knight);
            }
        ai = forward_left(qu);

        if( qu != WHITE_A7 && square_fixed[ai] & cel )
            {
            c = QU[ai];
            ADD(LIST, flag_promotion_queen | (qu << 6) | ai, promotion_queen_capture);

            if( attack_knight[ai] & bitboard_your_king )
                ADD(LIST, flag_promotion_knight | (qu << 6) | ai, promotion_knight_capture);
            }
        ai = forward_straight(qu);

        if( qu != WHITE_H7 && square_fixed[ai] & cel )
            {
            c = QU[ai];
            ADD(LIST, flag_promotion_queen | (qu << 6) | ai, promotion_queen_capture);

            if( attack_knight[ai] & bitboard_your_king )
                ADD(LIST, flag_promotion_knight | (qu << 6) | ai, promotion_knight_capture);
            }
        }
    LIST->move = 0;
    return LIST;
    }
type_list_move *my_ordinary( type_list_move *LIST )
    {
    uint64 empty = ~POSITION.occupied_black_white, U, T, TOR, ALF, RE;
    int ai, qu, requ = your_square_king;

    if( castling_oo && ((POSITION.occupied_black_white | your_attack) & WHITE_F1G1) == 0 )
        move_ANNEX(LIST, flag_castling | (WHITE_E1 << 6) | WHITE_G1, count_my_king, WHITE_G1, 0);

    if( castling_ooo && (POSITION.occupied_black_white &WHITE_B1C1D1) == 0 && (your_attack &WHITE_C1D1) == 0 )
        move_ANNEX(LIST, flag_castling | (WHITE_E1 << 6) | WHITE_C1, count_my_king, WHITE_C1, 0);

    RE = my_attack_pawn[requ];

    if( bitboard_my_queen | bitboard_my_rook )
        TOR = attack_rook(requ);

    if( bitboard_my_queen | bitboard_my_bishop )
        ALF = attack_bishop(requ);

    for ( U = forward_turn(bitboard_my_pawn & RANK_SECOND_SIX) & empty; U; bit_FREE(qu, U) )
        {
        ai = BSF(U);

        if( en_rank_third(ai) && QU[forward(ai)] == 0 )
            move_ANNEX(LIST, (back(ai) << 6) | forward(ai), count_my_pawn, forward(ai), RE);
        move_ANNEX(LIST, (back(ai) << 6) | ai, count_my_pawn, ai, RE);
        }

    for ( U = bitboard_my_queen; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        T = attack_queen(qu) & empty;
        ANNEX_AI_ORD(T, count_my_queen, TOR | ALF);
        }

    for ( U = bitboard_my_rook; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        T = attack_rook(qu) & empty;
        ANNEX_AI_ORD(T, count_my_rook, TOR);
        }

    for ( U = bitboard_my_bishop; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        T = attack_bishop(qu) & empty;
        ANNEX_AI_ORD(T, ((square_fixed[qu]&DARK) ? count_my_dark : count_my_clear), ALF);
        }
    qu = BSF(bitboard_my_king);
    T = attack_king[qu] & empty &( ~your_attack);
    ANNEX_AI_ORD(T, count_my_king, 0);

    for ( U = bitboard_my_knight; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        T = attack_knight[qu] & empty;
        ANNEX_AI_ORD(T, count_my_knight, attack_knight[requ]);
        }

    for ( U = bitboard_my_pawn & bitboard_rank_seventh; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        ai = forward(qu);

        if( POSITION.qu[ai] == 0 )
            under_promotion();
        ai = forward_left(qu);

        if( qu != WHITE_A7 && square_fixed[ai] & your_occupied )
            under_promotion();
        ai = forward_straight(qu);

        if( qu != WHITE_H7 && square_fixed[ai] & your_occupied )
            under_promotion();
        }
    LIST->move = 0;
    return LIST;
    }

type_list_move *my_check_quiet( type_list_move *LIST, uint64 cel )
    {
    int requ, re, qu, ai, di, piece;
    uint64 U, T, V;
    type_list_move *list;
    uint32 move;
    uint64 gcm;
    gcm = ~my_xray;
    cel = ( ~cel) &~my_occupied;
    ;
    list = LIST;
    re = your_square_king;
    list = LIST;

    for ( U = my_xray & my_occupied; U; bit_FREE(di, U) )
        {
        di = BSF(U);
        piece = QU[di];

        if( piece == count_my_pawn )
            {
            if( FILE(di) != FILE(re) && !RANK_SEVEN(di) && QU[forward(di)] == 0 )
                {
                (LIST++)->move = (di << 6) | forward(di);

                if( en_rank_second(di) && QU[forward_two(di)] == 0 )
                    (LIST++)->move = (di << 6) | forward_two(di);
                }

            if( straight_capture )
                (LIST++)->move = (di << 6) | forward_straight(di);

            if( left_capture )
                (LIST++)->move = (di << 6) | forward_left(di);
            }
        else if( piece == count_my_knight )
            {
            V = attack_knight[di] & cel;

            while( V )
                {
                ai = BSF(V);
                (LIST++)->move = (di << 6) | ai;
                bit_FREE(ai, V);
                }
            }
        else if( piece == count_my_clear || piece == count_my_dark )
            {
            V = attack_bishop(di) & cel;

            while( V )
                {
                ai = BSF(V);
                (LIST++)->move = (di << 6) | ai;
                bit_FREE(ai, V);
                }
            }
        else if( piece == count_my_rook )
            {
            V = attack_rook(di) & cel;

            while( V )
                {
                ai = BSF(V);
                (LIST++)->move = (di << 6) | ai;
                bit_FREE(ai, V);
                }
            }
        else if( piece == count_my_king )
            {
            if( FILE(di) == FILE(re) || RANK(di) == RANK(re) )
                V = attack_king[di] & not_perpendicular[re] & cel &( ~your_attack);
            else
                V = attack_king[di] & not_diagonal[re] & cel &( ~your_attack);

            while( V )
                {
                ai = BSF(V);
                (LIST++)->move = (di << 6) | ai;
                bit_FREE(ai, V);
                }
            }
        }

    requ = your_square_king;
    T = capture_left &( ~bitboard_rank_eighth) & cel & your_occupied & my_attack_pawn[requ];

    while( T )
        {
        ai = BSF(T);
        (LIST++)->move = di_straight(ai) | ai;
        bit_FREE(ai, T);
        }
    T = capture_straight &( ~bitboard_rank_eighth) & cel & your_occupied & my_attack_pawn[requ];

    while( T )
        {
        ai = BSF(T);
        (LIST++)->move = di_left(ai) | ai;
        bit_FREE(ai, T);
        }

    for ( U = bitboard_my_queen; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        T = attack_queen(qu) & attack_queen(re) & cel;

        while( T )
            {
            ai = BSF(T);
            bit_FREE(ai, T);

            if( (your_attack_pawn[ai]&bitboard_your_pawn &gcm) == 0
                && (attack_knight[ai]&bitboard_your_knight &gcm) == 0 )
                {
                move = (qu << 6) | ai;

                if( my_see(move) )
                    (LIST++)->move = (qu << 6) | ai;
                }
            }
        }

    for ( U = bitboard_my_rook; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        T = attack_rook(qu) & attack_rook(re) & cel;

        while( T )
            {
            ai = BSF(T);
            bit_FREE(ai, T);

            if( (your_attack_pawn[ai]&bitboard_your_pawn &gcm) == 0
                && (attack_knight[ai]&bitboard_your_knight &gcm) == 0 )
                {
                move = (qu << 6) | ai;

                if( my_see(move) )
                    (LIST++)->move = (qu << 6) | ai;
                }
            }
        }

    for ( U = bitboard_my_bishop; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        T = attack_bishop(qu) & attack_bishop(re) & cel;

        while( T )
            {
            ai = BSF(T);
            bit_FREE(ai, T);

            if( (your_attack_pawn[ai]&bitboard_your_pawn &gcm) == 0 )
                {
                move = (qu << 6) | ai;

                if( my_see(move) )
                    (LIST++)->move = (qu << 6) | ai;
                }
            }
        }

    for ( U = bitboard_my_knight; U; bit_FREE(qu, U) )
        {
        qu = BSF(U);
        T = attack_knight[qu] & attack_knight[re] & cel;

        while( T )
            {
            ai = BSF(T);
            bit_FREE(ai, T);

            if( (your_attack_pawn[ai]&bitboard_your_pawn &gcm) == 0 )
                {
                move = (qu << 6) | ai;

                if( my_see(move) )
                    (LIST++)->move = (qu << 6) | ai;
                }
            }
        }

    if( bitboard_your_king & RANK_FOUR_EIGHT_noH && QU[back_straight(requ)] == 0 )
        {
        if( QU[back_straight_two(requ)] == count_my_pawn )
            {
            di = back_straight_two(requ);
            ai = back_straight(requ);
            move = (di << 6) | ai;

            if( pawn_guardian(ai, di) && my_see(move) )
                (LIST++)->move = move;
            }

        if( RANK(requ) == number_rank5 && QU[back_straight_two(requ)] == 0
            && QU[back_straight_three(requ)] == count_my_pawn )
            {
            ai = back_straight(requ);
            di = back_straight_three(requ);
            move = (di << 6) | ai;

            if( pawn_guardian(ai, di) && my_see(move) )
                (LIST++)->move = move;
            }
        }

    if( bitboard_your_king & RANK_FOUR_EIGHT_noA && QU[back_left(requ)] == 0 )
        {
        if( QU[back_left_two(requ)] == count_my_pawn )
            {
            di = back_left_two(requ);
            ai = back_left(requ);
            move = (di << 6) | ai;

            if( pawn_guardian(ai, di) && my_see(move) )
                (LIST++)->move = move;
            }

        if( RANK(requ) == number_rank5 && QU[back_left_two(requ)] == 0 && QU[back_left_three(requ)] == count_my_pawn )
            {
            ai = back_left(requ);
            di = back_left_three(requ);
            move = (di << 6) | ai;

            if( pawn_guardian(ai, di) && my_see(move) )
                (LIST++)->move = move;
            }
        }
    LIST->move = MOVE_NONE;
    return LIST;
    }
