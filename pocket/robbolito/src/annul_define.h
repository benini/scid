/*
RobboLito is a UCI chess playing engine
authors: Yakov Petrovich Golyadkin, Igor Igorovich Igoronov, Roberto Pescatore
copyright: (C) 2009 Yakov Petrovich Golyadkin
date: 92th and 93rd year from Revolution
owners: PUBLICDOMAIN (workers)
dedication: To Vladimir Ilyich

RobboLito is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

RobboLito is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see http://www.gnu.org/licenses/.
*/

#undef my_pv_search_fine
#undef my_pv_search_fine_check
#undef my_search_fine
#undef my_search_fine_check
#undef my_search_half
#undef my_search_half_check
#undef my_exclude
#undef my_exclude_check
#undef my_node_cut
#undef my_node_cut_check
#undef my_node_total
#undef my_node_total_check
#undef my_node_pv
#undef my_node_top
#undef my_high
#undef my_attack
#undef your_attack
#undef my_attack_pawn
#undef your_attack_pawn
#undef your_pv_search_fine
#undef your_pv_search_fine_check
#undef your_search_fine
#undef your_search_fine_check
#undef your_search_half
#undef your_search_half_check
#undef your_exclude
#undef your_exclude_check
#undef your_node_cut
#undef your_node_cut_check
#undef your_node_total
#undef your_node_total_check
#undef your_node_pv
#undef your_node_top
#undef your_high
#undef your_occupied
#undef bitboard_your_pawn
#undef bitboard_your_knight
#undef bitboard_your_clear
#undef bitboard_your_dark
#undef bitboard_your_rook
#undef bitboard_your_queen
#undef bitboard_your_king
#undef my_occupied
#undef bitboard_my_pawn
#undef bitboard_my_knight
#undef bitboard_my_clear
#undef bitboard_my_dark
#undef bitboard_my_rook
#undef bitboard_my_queen
#undef bitboard_my_king
#undef my_square_king
#undef your_square_king
#undef count_your_pawn
#undef count_your_knight
#undef count_your_clear
#undef count_your_dark
#undef count_your_rook
#undef count_your_queen
#undef count_your_king
#undef count_my_pawn
#undef count_my_knight
#undef count_my_clear
#undef count_my_dark
#undef count_my_rook
#undef count_my_queen
#undef count_my_king
#undef your_king_check
#undef my_capture
#undef my_ordinary
#undef my_gain
#undef my_evasion
#undef my_check_quiet
#undef my_see
#undef DO
#undef CANCEL
#undef move_illegal
#undef move_check
#undef my_ensure
#undef my_next
#undef my_null
#undef RANK_SIX
#undef RANK_FOUR
#undef bitboard_rank_fourth
#undef pawn_free
#undef my_xray
#undef your_xray
#undef my_xray_list
#undef your_xray_list
#undef my_king_check
#undef my_count
#undef my_count_flee
#undef CHECK

#undef RANK_EIGHT
#undef capture_straight
#undef di_left
#undef capture_left
#undef di_straight
#undef forward
#undef forward_left
#undef forward_straight
#undef back
#undef forward_turn
#undef back_turn
#undef RANK_SEVEN
#undef back_turn_two
#undef forward_two
#undef RANK_SECOND
#undef RANK_SECOND_SIX
#undef en_rank_third
#undef RANK_SECOND_SIX
#undef bitboard_rank_seventh
#undef bitboard_rank_eighth
#undef WHITE_A7
#undef WHITE_H7

#undef capture_en_passant
#undef promotion_queen_capture
#undef promotion_knight_capture

#undef castling_oo
#undef castling_ooo
#undef WHITE_F1G1
#undef WHITE_C1D1
#undef WHITE_B1C1D1
#undef WHITE_E1
#undef WHITE_C1
#undef WHITE_G1
#undef under_promotion

#undef en_rank_second
#undef straight_capture
#undef left_capture
#undef pawn_guardian
#undef RANK_FOUR_EIGHT_noH
#undef RANK_FOUR_EIGHT_noA
#undef back_straight
#undef back_straight_two
#undef back_straight_three
#undef back_left
#undef back_left_two
#undef back_left_three
#undef number_rank5

#undef number_rank2
#undef my_piece
#undef your_piece
#undef back_two

#undef your_pawn
