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

static void fen_positional( char *I )
    {
    int tr = 7, co = 0, c = 0, i, p;

    for ( i = A1; i <= H8; i++ )
        QU[i] = 0;

    while( 1 )
        {
        if( tr < 0 || co > 8 )
            ERROR_fen("FEN %s col: %d tra: %d\n", I, co, tr);
        p = I[c++];

        if( p == 0 )
            return;

        if( co == 8 && p != '/' )
            ERROR_fen("FEN %s col: %d tra: %d pez: %d\n", I, co, tr, p);

        switch( p )
            {
            case '/':
                tr--;
                co = 0;
                break;

            case 'p':
                QU[co + 8 * tr] = count_pawn_black;
                co++;
                break;

            case 'b':
                if( square_fixed[co + 8 * tr] & DARK )
                    QU[co + 8 * tr] = count_dark_black;
                else
                    QU[co + 8 * tr] = count_clear_black;
                co++;
                break;

            case 'n':
                QU[co + 8 * tr] = count_knight_black;
                co++;
                break;

            case 'r':
                QU[co + 8 * tr] = count_rook_black;
                co++;
                break;

            case 'q':
                QU[co + 8 * tr] = count_queen_black;
                co++;
                break;

            case 'k':
                QU[co + 8 * tr] = count_king_black;
                co++;
                break;

            case 'P':
                QU[co + 8 * tr] = count_pawn_white;
                co++;
                break;

            case 'B':
                if( square_fixed[co + 8 * tr] & DARK )
                    QU[co + 8 * tr] = count_dark_white;
                else
                    QU[co + 8 * tr] = count_clear_white;
                co++;
                break;

            case 'N':
                QU[co + 8 * tr] = count_knight_white;
                co++;
                break;

            case 'R':
                QU[co + 8 * tr] = count_rook_white;
                co++;
                break;

            case 'Q':
                QU[co + 8 * tr] = count_queen_white;
                co++;
                break;

            case 'K':
                QU[co + 8 * tr] = count_king_white;
                co++;
                break;

            case '1':
                co += 1;
                break;

            case '2':
                co += 2;
                break;

            case '3':
                co += 3;
                break;

            case '4':
                co += 4;
                break;

            case '5':
                co += 5;
                break;

            case '6':
                co += 6;
                break;

            case '7':
                co += 7;
                break;

            case '8':
                co += 8;
                break;

            default:
                ERROR_fen("FEN %s col:%d tra:%d pez:%d\n", I, co, tr, p);
            }

        if( (tr == 0) && (co >= 8) )
            break;
        }
    }

#include <string.h>

char *law_fen( char *I )
    {
    char i[1024];
    bool ok;
    int en_passant;
    sscanf(I, "%s", i);
    fen_positional(i);
    memset(dynamic_initial, 0, 256 * sizeof(type_dynamic));
    DYNAMIC = dynamic_initial;
    I += strlen(i) + 1;
    sscanf(I, "%s", i);

    if( i[0] == 'w' )
        POSITION.white_en_move = TRUE;

    else if( i[0] == 'b' )
        POSITION.white_en_move = FALSE;

    else
        ERROR_fen("FEN wb %s\n", i);
    I += strlen(i) + 1;
    sscanf(I, "%s", i);
    DYNAMIC->castle = 16;

    if( !strcmp(i, "KQkq") )
        DYNAMIC->castle = 15;

    if( !strcmp(i, "Qkq") )
        DYNAMIC->castle = 14;

    if( !strcmp(i, "Kkq") )
        DYNAMIC->castle = 13;

    if( !strcmp(i, "kq") )
        DYNAMIC->castle = 12;

    if( !strcmp(i, "KQq") )
        DYNAMIC->castle = 11;

    if( !strcmp(i, "Qq") )
        DYNAMIC->castle = 10;

    if( !strcmp(i, "Kq") )
        DYNAMIC->castle = 9;

    if( !strcmp(i, "q") )
        DYNAMIC->castle = 8;

    if( !strcmp(i, "KQk") )
        DYNAMIC->castle = 7;

    if( !strcmp(i, "Qk") )
        DYNAMIC->castle = 6;

    if( !strcmp(i, "Kk") )
        DYNAMIC->castle = 5;

    if( !strcmp(i, "k") )
        DYNAMIC->castle = 4;

    if( !strcmp(i, "KQ") )
        DYNAMIC->castle = 3;

    if( !strcmp(i, "Q") )
        DYNAMIC->castle = 2;

    if( !strcmp(i, "K") )
        DYNAMIC->castle = 1;

    if( !strcmp(i, "-") )
        DYNAMIC->castle = 0;

    if( DYNAMIC->castle == 16 )
        ERROR_fen("FEN oo %s\n", i);
    I += strlen(i) + 1;
    sscanf(I, "%s", i);
    DYNAMIC->en_passant = 0;

    if( !strcmp(i, "-") )
        en_passant = 0;
    else
        {
        en_passant = (i[0] - 'a') + 8 * (i[1] - '1');

        if( en_passant > H8 )
            ERROR_fen("FEN ep %s\n", i);
        ok = 0;
        }

    if( en_passant )
        {
        if( POSITION.white_en_move )
            {
            if( FILE(en_passant) != CA && (QU[en_passant - 9] == count_pawn_white) )
                ok = TRUE;

            if( FILE(en_passant) != CH && (QU[en_passant - 7] == count_pawn_white) )
                ok = TRUE;
            }
        else
            {
            if( FILE(en_passant) != CA && (QU[en_passant + 7] == count_pawn_black) )
                ok = TRUE;

            if( FILE(en_passant) != CH && (QU[en_passant + 9] == count_pawn_black) )
                ok = TRUE;
            }

        if( ok )
            DYNAMIC->en_passant = en_passant;
        }
    I += strlen(i) + 1;
    sscanf(I, "%s", i);
    DYNAMIC->move50 = (uint8)_atoi64(i);
    I += strlen(i) + 1;
    sscanf(I, "%s", i);
    I += strlen(i) + 1;
    bitboard_initialization();
    return I;
    }
static uint32 move_completa( uint32 x )
    {
    int piece, ai = AI(x), di = DI(x);

    if( !x )
        return x;

    piece = QU[di];

    if( piece == count_king_white || piece == count_king_black )
        {
        if( ai - di == 2 || di - ai == 2 )
            x |= flag_castling;
        }

    if( AI(x) != 0 && AI(x) == DYNAMIC->en_passant && (piece == count_pawn_white || piece == count_pawn_black) )
        x |= flag_en_passant;
    return x;
    }

#define CHECK                                         \
    ( POSITION.white_en_move ?                        \
    ( DYNAMIC->attak_black & bitboard_white_king) : \
    ( DYNAMIC->attak_white & bitboard_black_king ) )

static void legal_moves( char *I )
    {
    type_list_move LIST[256], *list;
    char T[256];
    int i;
    uint32 total;

    while( I[0] )
        {
        mobility();

        if( CHECK )
            {
            list = evasion_move(LIST, 0xffffffffffffffffull);
            list++;
            }
        else
            {
            list = capture_move(LIST, POSITION.occupied_black_white);
            list = ordinary_move(list);
            }
        total = move_completa((I[2] - 'a') + ((I[3] - '1') << 3) + ((I[0] - 'a') << 6) + ((I[1] - '1') << 9));
        sscanf(I, "%s", T);

        if( strlen(T) == 5 )
            {
            if( I[4] == 'b' )
                total |= flag_promotion_bishop;

            if( I[4] == 'n' )
                total |= flag_promotion_knight;

            if( I[4] == 'r' )
                total |= flag_promotion_rook;

            if( I[4] == 'q' )
                total |= flag_promotion_queen;
            }

        for ( i = 0; i < list - LIST; i++ )
            {
            if( total == (LIST[i].move & 0x7fff) )
                {
                make(total);
                break;
                }
            }

        if( i == list - LIST )
            {
            ERROR_("moves? %s\n", T);
            }
        I += strlen(T) + 1;

        while( I[0] == ' ' )
            I++;
        }
    }

static char position_original[80] = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1";

void positional_initialization( char *I )
    {
    char i[1024];
    move_white_number = move_black_number = move_null_number = 0;
    sscanf(I, "%s", i);

    if( !strcmp(i, "startpos") )
        {
        law_fen(position_original);
        I += strlen("startpos") + 1;
        }

    if( !strcmp(i, "fen") )
        {
        I += strlen("fen") + 1;
        I = law_fen(I);
        }

    if( I[0] )
        {
        sscanf(I, "%s", i);

        if( !strcmp(i, "moves") )
            {
            I += strlen("moves") + 1;
            legal_moves(I);
            }
        }

    if( GAME_NEW )
        gain_reset();
    }
