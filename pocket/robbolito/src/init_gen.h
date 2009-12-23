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

static sint32 capture_value[16][16];

void initialization_capture()
    {
    capture_value[count_pawn_white][count_queen_black] = (0xd0 << 24) + (0x02 << 20);
    capture_value[count_knight_white][count_queen_black] = (0xcf << 24) + (0x02 << 20);
    capture_value[count_clear_white][count_queen_black] = (0xce << 24) + (0x02 << 20);
    capture_value[count_dark_white][count_queen_black] = (0xce << 24) + (0x02 << 20);
    capture_value[count_rook_white][count_queen_black] = (0xcd << 24) + (0x02 << 20);
    capture_value[count_queen_white][count_queen_black] = (0xcc << 24) + (0x01 << 20);

    capture_value[count_pawn_white][count_rook_black] = (0xc8 << 24) + (0x02 << 20);
    capture_value[count_knight_white][count_rook_black] = (0xc7 << 24) + (0x02 << 20);
    capture_value[count_clear_white][count_rook_black] = (0xc6 << 24) + (0x02 << 20);
    capture_value[count_dark_white][count_rook_black] = (0xc6 << 24) + (0x02 << 20);
    capture_value[count_rook_white][count_rook_black] = (0xc5 << 24) + (0x01 << 20);
    capture_value[count_queen_white][count_rook_black] = (0xc4 << 24) + (0x00 << 20);

    capture_value[count_pawn_white][count_clear_black] = (0xc0 << 24) + (0x02 << 20);
    capture_value[count_knight_white][count_clear_black] = (0xbf << 24) + (0x01 << 20);
    capture_value[count_clear_white][count_clear_black] = (0xbe << 24) + (0x01 << 20);
    capture_value[count_dark_white][count_clear_black] = (0xbe << 24) + (0x01 << 20);
    capture_value[count_rook_white][count_clear_black] = (0xbd << 24) + (0x00 << 20);
    capture_value[count_queen_white][count_clear_black] = (0xbc << 24) + (0x00 << 20);

    capture_value[count_pawn_white][count_dark_black] = (0xc0 << 24) + (0x02 << 20);
    capture_value[count_knight_white][count_dark_black] = (0xbf << 24) + (0x01 << 20);
    capture_value[count_clear_white][count_dark_black] = (0xbe << 24) + (0x01 << 20);
    capture_value[count_dark_white][count_dark_black] = (0xbe << 24) + (0x01 << 20);
    capture_value[count_rook_white][count_dark_black] = (0xbd << 24) + (0x00 << 20);
    capture_value[count_queen_white][count_dark_black] = (0xbc << 24) + (0x00 << 20);

    capture_value[count_pawn_white][count_knight_black] = (0xb8 << 24) + (0x02 << 20);
    capture_value[count_knight_white][count_knight_black] = (0xb7 << 24) + (0x01 << 20);
    capture_value[count_clear_white][count_knight_black] = (0xb6 << 24) + (0x01 << 20);
    capture_value[count_dark_white][count_knight_black] = (0xb6 << 24) + (0x01 << 20);
    capture_value[count_rook_white][count_knight_black] = (0xb5 << 24) + (0x00 << 20);
    capture_value[count_queen_white][count_knight_black] = (0xb4 << 24) + (0x00 << 20);

    capture_value[count_pawn_white][count_pawn_black] = (0xb0 << 24) + (0x01 << 20);
    capture_value[count_knight_white][count_pawn_black] = (0xaf << 24) + (0x00 << 20);
    capture_value[count_clear_white][count_pawn_black] = (0xae << 24) + (0x00 << 20);
    capture_value[count_dark_white][count_pawn_black] = (0xae << 24) + (0x00 << 20);
    capture_value[count_rook_white][count_pawn_black] = (0xad << 24) + (0x00 << 20);
    capture_value[count_queen_white][count_pawn_black] = (0xac << 24) + (0x00 << 20);

    capture_value[count_king_white][count_queen_black] = (0xcb << 24) + (0x00 << 20);
    capture_value[count_king_white][count_rook_black] = (0xc3 << 24) + (0x00 << 20);
    capture_value[count_king_white][count_clear_black] = (0xbb << 24) + (0x00 << 20);
    capture_value[count_king_white][count_dark_black] = (0xbb << 24) + (0x00 << 20);
    capture_value[count_king_white][count_knight_black] = (0xb3 << 24) + (0x00 << 20);
    capture_value[count_king_white][count_pawn_black] = (0xab << 24) + (0x00 << 20);

    capture_value[count_king_white][0] = (0x07 << 24) + (0x00 << 15);
    capture_value[count_pawn_white][0] = (0x06 << 24) + (0x01 << 15);
    capture_value[count_knight_white][0] = (0x05 << 24) + (0x01 << 15);
    capture_value[count_clear_white][0] = (0x04 << 24) + (0x01 << 15);
    capture_value[count_dark_white][0] = (0x04 << 24) + (0x01 << 15);
    capture_value[count_rook_white][0] = (0x03 << 24) + (0x01 << 15);
    capture_value[count_queen_white][0] = (0x02 << 24) + (0x01 << 15);

    capture_value[count_pawn_black][count_queen_white] = (0xd0 << 24) + (0x02 << 20);
    capture_value[count_knight_black][count_queen_white] = (0xcf << 24) + (0x02 << 20);
    capture_value[count_clear_black][count_queen_white] = (0xce << 24) + (0x02 << 20);
    capture_value[count_dark_black][count_queen_white] = (0xce << 24) + (0x02 << 20);
    capture_value[count_rook_black][count_queen_white] = (0xcd << 24) + (0x02 << 20);
    capture_value[count_queen_black][count_queen_white] = (0xcc << 24) + (0x01 << 20);

    capture_value[count_pawn_black][count_rook_white] = (0xc8 << 24) + (0x02 << 20);
    capture_value[count_knight_black][count_rook_white] = (0xc7 << 24) + (0x02 << 20);
    capture_value[count_clear_black][count_rook_white] = (0xc6 << 24) + (0x02 << 20);
    capture_value[count_dark_black][count_rook_white] = (0xc6 << 24) + (0x02 << 20);
    capture_value[count_rook_black][count_rook_white] = (0xc5 << 24) + (0x01 << 20);
    capture_value[count_queen_black][count_rook_white] = (0xc4 << 24) + (0x00 << 20);

    capture_value[count_pawn_black][count_clear_white] = (0xc0 << 24) + (0x02 << 20);
    capture_value[count_knight_black][count_clear_white] = (0xbf << 24) + (0x01 << 20);
    capture_value[count_clear_black][count_clear_white] = (0xbe << 24) + (0x01 << 20);
    capture_value[count_dark_black][count_clear_white] = (0xbe << 24) + (0x01 << 20);
    capture_value[count_rook_black][count_clear_white] = (0xbd << 24) + (0x00 << 20);
    capture_value[count_queen_black][count_clear_white] = (0xbc << 24) + (0x00 << 20);

    capture_value[count_pawn_black][count_dark_white] = (0xc0 << 24) + (0x02 << 20);
    capture_value[count_knight_black][count_dark_white] = (0xbf << 24) + (0x01 << 20);
    capture_value[count_clear_black][count_dark_white] = (0xbe << 24) + (0x01 << 20);
    capture_value[count_dark_black][count_dark_white] = (0xbe << 24) + (0x01 << 20);
    capture_value[count_rook_black][count_dark_white] = (0xbd << 24) + (0x00 << 20);
    capture_value[count_queen_black][count_dark_white] = (0xbc << 24) + (0x00 << 20);

    capture_value[count_pawn_black][count_knight_white] = (0xb8 << 24) + (0x02 << 20);
    capture_value[count_knight_black][count_knight_white] = (0xb7 << 24) + (0x01 << 20);
    capture_value[count_clear_black][count_knight_white] = (0xb6 << 24) + (0x01 << 20);
    capture_value[count_dark_black][count_knight_white] = (0xb6 << 24) + (0x01 << 20);
    capture_value[count_rook_black][count_knight_white] = (0xb5 << 24) + (0x00 << 20);
    capture_value[count_queen_black][count_knight_white] = (0xb4 << 24) + (0x00 << 20);

    capture_value[count_pawn_black][count_pawn_white] = (0xb0 << 24) + (0x01 << 20);
    capture_value[count_knight_black][count_pawn_white] = (0xaf << 24) + (0x00 << 20);
    capture_value[count_clear_black][count_pawn_white] = (0xae << 24) + (0x00 << 20);
    capture_value[count_dark_black][count_pawn_white] = (0xae << 24) + (0x00 << 20);
    capture_value[count_rook_black][count_pawn_white] = (0xad << 24) + (0x00 << 20);
    capture_value[count_queen_black][count_pawn_white] = (0xac << 24) + (0x00 << 20);

    capture_value[count_king_black][count_queen_white] = (0xcb << 24) + (0x00 << 20);
    capture_value[count_king_black][count_rook_white] = (0xc3 << 24) + (0x00 << 20);
    capture_value[count_king_black][count_clear_white] = (0xbb << 24) + (0x00 << 20);
    capture_value[count_king_black][count_dark_white] = (0xbb << 24) + (0x00 << 20);
    capture_value[count_king_black][count_knight_white] = (0xb3 << 24) + (0x00 << 20);
    capture_value[count_king_black][count_pawn_white] = (0xab << 24) + (0x00 << 20);

    capture_value[count_king_black][0] = (0x07 << 24) + (0x00 << 15);
    capture_value[count_pawn_black][0] = (0x06 << 24) + (0x01 << 15);
    capture_value[count_knight_black][0] = (0x05 << 24) + (0x01 << 15);
    capture_value[count_clear_black][0] = (0x04 << 24) + (0x01 << 15);
    capture_value[count_dark_black][0] = (0x04 << 24) + (0x01 << 15);
    capture_value[count_rook_black][0] = (0x03 << 24) + (0x01 << 15);
    capture_value[count_queen_black][0] = (0x02 << 24) + (0x01 << 15);
    }
