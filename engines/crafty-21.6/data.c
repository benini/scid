#include <stdio.h>
#include <stdlib.h>
#include "chess.h"
SHARED *shared;
FILE *input_stream;
FILE *dbout;
FILE *book_file;
FILE *books_file;
FILE *normal_bs_file;
FILE *computer_bs_file;
FILE *history_file;
FILE *log_file;
FILE *auto_file;
FILE *position_file;
int done = 0;
BITBOARD total_moves;
int last_mate_score;
char log_filename[64];
char history_filename[64];
int number_of_solutions;
int solutions[10];
int solution_type;
char cmd_buffer[4096];
char *args[256];
char buffer[512];
unsigned char convert_buff[8];
int nargs;
int ponder_value;
int move_actually_played;
int ponder_move;
int ponder_moves[220];
int num_ponder_moves;
int book_move;
int book_learn_eval[LEARN_INTERVAL];
int book_learn_depth[LEARN_INTERVAL];
int learn_positions_count = 0;
int learn_seekto[64];
BITBOARD learn_key[64];
int learn_nmoves[64];
int book_learn_nmoves;
int book_learn_seekto;
BITBOARD book_learn_key;
int hash_mask;
unsigned int pawn_hash_mask;
HASH_ENTRY *trans_ref;
PAWN_HASH_ENTRY *pawn_hash_table;
size_t cb_trans_ref;
size_t cb_pawn_hash_table;
PATH last_pv;
int last_value;
int pval_b[64];
int kval_bn[64];
int kval_bk[64];
int kval_bq[64];
int king_safety[16][16];
int black_outpost[64];
signed char directions[64][64];
BITBOARD w_pawn_attacks[64];
BITBOARD b_pawn_attacks[64];
BITBOARD knight_attacks[64];
POSITION display;
BITBOARD king_attacks[64];
BITBOARD obstructed[64][64];
BITBOARD w_pawn_random[64];
BITBOARD b_pawn_random[64];
BITBOARD w_knight_random[64];
BITBOARD b_knight_random[64];
BITBOARD w_bishop_random[64];
BITBOARD b_bishop_random[64];
BITBOARD w_rook_random[64];
BITBOARD b_rook_random[64];
BITBOARD w_queen_random[64];
BITBOARD b_queen_random[64];
BITBOARD w_king_random[64];
BITBOARD b_king_random[64];
BITBOARD stalemate_sqs[64];
BITBOARD edge_moves[64];
BITBOARD enpassant_random[65];
BITBOARD castle_random_w[2];
BITBOARD castle_random_b[2];
BITBOARD wtm_random[2];
BITBOARD clear_mask[65];
BITBOARD set_mask[65];
BITBOARD file_mask[8];
BITBOARD rank_mask[8];
BITBOARD virgin_center_pawns;
BITBOARD mask_efgh, mask_fgh, mask_abc, mask_abcd;
BITBOARD mask_advance_2_w;
BITBOARD mask_advance_2_b;
BITBOARD mask_left_edge;
BITBOARD mask_right_edge;
BITBOARD mask_not_edge;
BITBOARD mask_A3B3;
BITBOARD mask_B3C3;
BITBOARD mask_F3G3;
BITBOARD mask_G3H3;
BITBOARD mask_A6B6;
BITBOARD mask_B6C6;
BITBOARD mask_F6G6;
BITBOARD mask_G6H6;
BITBOARD mask_white_OO;
BITBOARD mask_white_OOO;
BITBOARD mask_black_OO;
BITBOARD mask_black_OOO;
BITBOARD mask_kr_trapped_w[3];
BITBOARD mask_qr_trapped_w[3];
BITBOARD mask_kr_trapped_b[3];
BITBOARD mask_qr_trapped_b[3];
BITBOARD mask_corner_a1, mask_corner_h1;
BITBOARD mask_corner_a8, mask_corner_h8;
BITBOARD mask_center_files;
BITBOARD mask_d3d4d5d6;
BITBOARD mask_e3e4e5e6;
BITBOARD light_squares;
BITBOARD dark_squares;
BITBOARD not_rook_pawns;
BITBOARD plus1dir[65];
BITBOARD plus7dir[65];
BITBOARD plus8dir[65];
BITBOARD plus9dir[65];
BITBOARD minus1dir[65];
BITBOARD minus7dir[65];
BITBOARD minus8dir[65];
BITBOARD minus9dir[65];
BITBOARD mask_eptest[64];
BITBOARD mask_clear_entry;

#if (!defined(_M_AMD64) && !defined (_M_IA64) && !defined(INLINE32)) || defined(VC_INLINE32)
unsigned char msb[65536];
unsigned char lsb[65536];
#endif
unsigned char msb_8bit[256];
unsigned char lsb_8bit[256];
unsigned char islands[256];
unsigned char pop_cnt_8bit[256];
unsigned char connected_passed[256];
unsigned char file_spread[256];
signed char is_outside[256][256];
signed char is_outside_c[256][256];
BITBOARD mask_pawn_protected_b[64];
BITBOARD mask_pawn_protected_w[64];
BITBOARD mask_pawn_duo[64];
BITBOARD mask_pawn_isolated[64];
BITBOARD mask_pawn_passed_w[64];
BITBOARD mask_pawn_passed_b[64];
BITBOARD mask_no_pattacks_w[64];
BITBOARD mask_no_pattacks_b[64];
BITBOARD white_pawn_race_wtm[64];
BITBOARD white_pawn_race_btm[64];
BITBOARD black_pawn_race_wtm[64];
BITBOARD black_pawn_race_btm[64];
BOOK_POSITION book_buffer[BOOK_CLUSTER_SIZE];
BOOK_POSITION book_buffer_char[BOOK_CLUSTER_SIZE];

#define    VERSION                             "21.6"
char version[8] = { VERSION };
PLAYING_MODE mode = normal_mode;
int batch_mode = 0;             /* no asynch reads */
int swindle_mode = 1;           /* try to swindle */
int call_flag = 0;
int crafty_rating = 2500;
int opponent_rating = 2500;
int last_search_value = 0;
int lazy_eval_cutoff = 350;
int DGT_active = 0;
int to_dgt = 0;
int from_dgt = 0;
int pgn_suggested_percent = 0;
char pgn_event[128] = { "?" };
char pgn_site[128] = { "?" };
char pgn_date[128] = { "????.??.??" };
char pgn_round[128] = { "?" };
char pgn_white[128] = { "unknown" };
char pgn_white_elo[128] = { "" };
char pgn_black[128] = { "Crafty " VERSION };
char pgn_black_elo[128] = { "" };
char pgn_result[128] = { "*" };
char *B_list[128];
char *AK_list[128];
char *C_list[128];
char *GM_list[128];
char *IM_list[128];
char *SP_list[128];
char *SP_opening_filename[128];
char *SP_personality_filename[128];
int ics = 0;
int output_format = 0;

#if !defined(NOEGTB)
int EGTBlimit = 0;
int EGTB_use = 0;
int EGTB_draw = 0;
int EGTB_search = 0;
size_t EGTB_cache_size = EGTB_CACHE_DEFAULT;
void *EGTB_cache = (void *) 0;
int EGTB_setup = 0;
#endif
int xboard = 0;
int pong = 0;
int channel = 0;
int early_exit = 99;
int new_game = 0;
char channel_title[32] = { "" };
char book_path[128] = { BOOKDIR };
char personality_path[128] = { PERSDIR };
char log_path[128] = { LOGDIR };
char tb_path[128] = { TBDIR };
char rc_path[128] = { RCDIR };
int initialized = 0;
int kibitz = 0;
int post = 0;
int log_id = 0;
int wtm = 1;
int last_opponent_move = 0;
int incheck_depth = 4;
int onerep_depth = 3;
int mate_depth = 3;
int pushpp_depth = 3;
int null_min = 3 * PLY;         /* R=2 */
int null_max = 4 * PLY;         /* R=3 */
int reduce_min_depth = PLY;     /* leave 1 good ply after reductions */
int reduce_value = PLY;         /* reduce 1 ply */
int search_depth = 0;
unsigned int search_nodes = 0;
unsigned int temp_search_nodes = 0;
int search_move = 0;
int predicted = 0;
int time_used = 0;
int time_used_opponent = 0;
int analyze_mode = 0;
int annotate_mode = 0;
int input_status = 0;
int resign = 9;
int resign_counter = 0;
int resign_count = 5;
int draw_counter = 0;
int draw_count = 5;
int draw_offer_pending = 0;
int draw_offered = 0;
int offer_draws = 1;
int adaptive_hash = 0;
size_t adaptive_hash_min = 0;
size_t adaptive_hash_max = 0;
size_t adaptive_hashp_min = 0;
size_t adaptive_hashp_max = 0;
int time_limit = 100;
int force = 0;
char initial_position[80] = { "" };
char hint[512] = { "" };
char book_hint[512] = { "" };
int over = 0;
int silent = 0;
int usage_level = 0;
char audible_alarm = 0x07;
char speech = 0;
int ansi = 1;
int book_accept_mask = ~03;
int book_reject_mask = 3;
int book_random = 1;
float book_weight_learn = 1.0;
float book_weight_freq = 1.0;
float book_weight_eval = 0.1;
int book_search_trigger = 20;
int learning = 7;
int learning_cutoff = -2 * PAWN_VALUE;
int learning_trigger = PAWN_VALUE / 3;
int show_book = 0;
int book_selection_width = 5;
int ponder = 1;
int trace_level = 0;
size_t hash_table_size = 65536;
int log_hash = 16;
size_t pawn_hash_table_size = 32768;
int log_pawn_hash = 15;
int abs_draw_score = 1;
int accept_draws = 1;
const char xlate[15] =
    { 'q', 'r', 'b', 0, 'k', 'n', 'p', 0, 'P', 'N', 'K', 0, 'B', 'R', 'Q' };
BITBOARD magic_bishop[64] = {
  0x0002020202020200ULL, 0x0002020202020000ULL, 0x0004010202000000ULL,
  0x0004040080000000ULL, 0x0001104000000000ULL, 0x0000821040000000ULL,
  0x0000410410400000ULL, 0x0000104104104000ULL, 0x0000040404040400ULL,
  0x0000020202020200ULL, 0x0000040102020000ULL, 0x0000040400800000ULL,
  0x0000011040000000ULL, 0x0000008210400000ULL, 0x0000004104104000ULL,
  0x0000002082082000ULL, 0x0004000808080800ULL, 0x0002000404040400ULL,
  0x0001000202020200ULL, 0x0000800802004000ULL, 0x0000800400A00000ULL,
  0x0000200100884000ULL, 0x0000400082082000ULL, 0x0000200041041000ULL,
  0x0002080010101000ULL, 0x0001040008080800ULL, 0x0000208004010400ULL,
  0x0000404004010200ULL, 0x0000840000802000ULL, 0x0000404002011000ULL,
  0x0000808001041000ULL, 0x0000404000820800ULL, 0x0001041000202000ULL,
  0x0000820800101000ULL, 0x0000104400080800ULL, 0x0000020080080080ULL,
  0x0000404040040100ULL, 0x0000808100020100ULL, 0x0001010100020800ULL,
  0x0000808080010400ULL, 0x0000820820004000ULL, 0x0000410410002000ULL,
  0x0000082088001000ULL, 0x0000002011000800ULL, 0x0000080100400400ULL,
  0x0001010101000200ULL, 0x0002020202000400ULL, 0x0001010101000200ULL,
  0x0000410410400000ULL, 0x0000208208200000ULL, 0x0000002084100000ULL,
  0x0000000020880000ULL, 0x0000001002020000ULL, 0x0000040408020000ULL,
  0x0004040404040000ULL, 0x0002020202020000ULL, 0x0000104104104000ULL,
  0x0000002082082000ULL, 0x0000000020841000ULL, 0x0000000000208800ULL,
  0x0000000010020200ULL, 0x0000000404080200ULL, 0x0000040404040400ULL,
  0x0002020202020200ULL
};
BITBOARD magic_bishop_mask[64] = {
  0x0040201008040200ULL, 0x0000402010080400ULL, 0x0000004020100A00ULL,
  0x0000000040221400ULL, 0x0000000002442800ULL, 0x0000000204085000ULL,
  0x0000020408102000ULL, 0x0002040810204000ULL, 0x0020100804020000ULL,
  0x0040201008040000ULL, 0x00004020100A0000ULL, 0x0000004022140000ULL,
  0x0000000244280000ULL, 0x0000020408500000ULL, 0x0002040810200000ULL,
  0x0004081020400000ULL, 0x0010080402000200ULL, 0x0020100804000400ULL,
  0x004020100A000A00ULL, 0x0000402214001400ULL, 0x0000024428002800ULL,
  0x0002040850005000ULL, 0x0004081020002000ULL, 0x0008102040004000ULL,
  0x0008040200020400ULL, 0x0010080400040800ULL, 0x0020100A000A1000ULL,
  0x0040221400142200ULL, 0x0002442800284400ULL, 0x0004085000500800ULL,
  0x0008102000201000ULL, 0x0010204000402000ULL, 0x0004020002040800ULL,
  0x0008040004081000ULL, 0x00100A000A102000ULL, 0x0022140014224000ULL,
  0x0044280028440200ULL, 0x0008500050080400ULL, 0x0010200020100800ULL,
  0x0020400040201000ULL, 0x0002000204081000ULL, 0x0004000408102000ULL,
  0x000A000A10204000ULL, 0x0014001422400000ULL, 0x0028002844020000ULL,
  0x0050005008040200ULL, 0x0020002010080400ULL, 0x0040004020100800ULL,
  0x0000020408102000ULL, 0x0000040810204000ULL, 0x00000A1020400000ULL,
  0x0000142240000000ULL, 0x0000284402000000ULL, 0x0000500804020000ULL,
  0x0000201008040200ULL, 0x0000402010080400ULL, 0x0002040810204000ULL,
  0x0004081020400000ULL, 0x000A102040000000ULL, 0x0014224000000000ULL,
  0x0028440200000000ULL, 0x0050080402000000ULL, 0x0020100804020000ULL,
  0x0040201008040200ULL
};
unsigned int magic_bishop_shift[64] = {
  58, 59, 59, 59, 59, 59, 59, 58,
  59, 59, 59, 59, 59, 59, 59, 59,
  59, 59, 57, 57, 57, 57, 59, 59,
  59, 59, 57, 55, 55, 57, 59, 59,
  59, 59, 57, 55, 55, 57, 59, 59,
  59, 59, 57, 57, 57, 57, 59, 59,
  59, 59, 59, 59, 59, 59, 59, 59,
  58, 59, 59, 59, 59, 59, 59, 58
};

BITBOARD magic_bishop_table[5248];
BITBOARD *magic_bishop_indices[64] = {
  magic_bishop_table + 4992, magic_bishop_table + 2624,
  magic_bishop_table + 256, magic_bishop_table + 896,
  magic_bishop_table + 1280, magic_bishop_table + 1664,
  magic_bishop_table + 4800, magic_bishop_table + 5120,
  magic_bishop_table + 2560, magic_bishop_table + 2656,
  magic_bishop_table + 288, magic_bishop_table + 928,
  magic_bishop_table + 1312, magic_bishop_table + 1696,
  magic_bishop_table + 4832, magic_bishop_table + 4928,
  magic_bishop_table + 0, magic_bishop_table + 128, magic_bishop_table + 320,
  magic_bishop_table + 960,
  magic_bishop_table + 1344, magic_bishop_table + 1728,
  magic_bishop_table + 2304, magic_bishop_table + 2432,
  magic_bishop_table + 32, magic_bishop_table + 160, magic_bishop_table + 448,
  magic_bishop_table + 2752,
  magic_bishop_table + 3776, magic_bishop_table + 1856,
  magic_bishop_table + 2336, magic_bishop_table + 2464,
  magic_bishop_table + 64, magic_bishop_table + 192, magic_bishop_table + 576,
  magic_bishop_table + 3264,
  magic_bishop_table + 4288, magic_bishop_table + 1984,
  magic_bishop_table + 2368, magic_bishop_table + 2496,
  magic_bishop_table + 96, magic_bishop_table + 224, magic_bishop_table + 704,
  magic_bishop_table + 1088,
  magic_bishop_table + 1472, magic_bishop_table + 2112,
  magic_bishop_table + 2400, magic_bishop_table + 2528,
  magic_bishop_table + 2592, magic_bishop_table + 2688,
  magic_bishop_table + 832, magic_bishop_table + 1216,
  magic_bishop_table + 1600, magic_bishop_table + 2240,
  magic_bishop_table + 4864, magic_bishop_table + 4960,
  magic_bishop_table + 5056, magic_bishop_table + 2720,
  magic_bishop_table + 864, magic_bishop_table + 1248,
  magic_bishop_table + 1632, magic_bishop_table + 2272,
  magic_bishop_table + 4896, magic_bishop_table + 5184
};

BITBOARD magic_rook_table[102400];
BITBOARD *magic_rook_indices[64] = {
  magic_rook_table + 86016, magic_rook_table + 73728, magic_rook_table + 36864,
  magic_rook_table + 43008,
  magic_rook_table + 47104, magic_rook_table + 51200, magic_rook_table + 77824,
  magic_rook_table + 94208,
  magic_rook_table + 69632, magic_rook_table + 32768, magic_rook_table + 38912,
  magic_rook_table + 10240,
  magic_rook_table + 14336, magic_rook_table + 53248, magic_rook_table + 57344,
  magic_rook_table + 81920,
  magic_rook_table + 24576, magic_rook_table + 33792, magic_rook_table + 6144,
  magic_rook_table + 11264,
  magic_rook_table + 15360, magic_rook_table + 18432, magic_rook_table + 58368,
  magic_rook_table + 61440,
  magic_rook_table + 26624, magic_rook_table + 4096, magic_rook_table + 7168,
  magic_rook_table + 0,
  magic_rook_table + 2048, magic_rook_table + 19456, magic_rook_table + 22528,
  magic_rook_table + 63488,
  magic_rook_table + 28672, magic_rook_table + 5120, magic_rook_table + 8192,
  magic_rook_table + 1024,
  magic_rook_table + 3072, magic_rook_table + 20480, magic_rook_table + 23552,
  magic_rook_table + 65536,
  magic_rook_table + 30720, magic_rook_table + 34816, magic_rook_table + 9216,
  magic_rook_table + 12288,
  magic_rook_table + 16384, magic_rook_table + 21504, magic_rook_table + 59392,
  magic_rook_table + 67584,
  magic_rook_table + 71680, magic_rook_table + 35840, magic_rook_table + 39936,
  magic_rook_table + 13312,
  magic_rook_table + 17408, magic_rook_table + 54272, magic_rook_table + 60416,
  magic_rook_table + 83968,
  magic_rook_table + 90112, magic_rook_table + 75776, magic_rook_table + 40960,
  magic_rook_table + 45056,
  magic_rook_table + 49152, magic_rook_table + 55296, magic_rook_table + 79872,
  magic_rook_table + 98304
};
BITBOARD magic_rook[64] = {
  0x0080001020400080ULL, 0x0040001000200040ULL, 0x0080081000200080ULL,
  0x0080040800100080ULL, 0x0080020400080080ULL, 0x0080010200040080ULL,
  0x0080008001000200ULL, 0x0080002040800100ULL, 0x0000800020400080ULL,
  0x0000400020005000ULL, 0x0000801000200080ULL, 0x0000800800100080ULL,
  0x0000800400080080ULL, 0x0000800200040080ULL, 0x0000800100020080ULL,
  0x0000800040800100ULL, 0x0000208000400080ULL, 0x0000404000201000ULL,
  0x0000808010002000ULL, 0x0000808008001000ULL, 0x0000808004000800ULL,
  0x0000808002000400ULL, 0x0000010100020004ULL, 0x0000020000408104ULL,
  0x0000208080004000ULL, 0x0000200040005000ULL, 0x0000100080200080ULL,
  0x0000080080100080ULL, 0x0000040080080080ULL, 0x0000020080040080ULL,
  0x0000010080800200ULL, 0x0000800080004100ULL, 0x0000204000800080ULL,
  0x0000200040401000ULL, 0x0000100080802000ULL, 0x0000080080801000ULL,
  0x0000040080800800ULL, 0x0000020080800400ULL, 0x0000020001010004ULL,
  0x0000800040800100ULL, 0x0000204000808000ULL, 0x0000200040008080ULL,
  0x0000100020008080ULL, 0x0000080010008080ULL, 0x0000040008008080ULL,
  0x0000020004008080ULL, 0x0000010002008080ULL, 0x0000004081020004ULL,
  0x0000204000800080ULL, 0x0000200040008080ULL, 0x0000100020008080ULL,
  0x0000080010008080ULL, 0x0000040008008080ULL, 0x0000020004008080ULL,
  0x0000800100020080ULL, 0x0000800041000080ULL, 0x00FFFCDDFCED714AULL,
  0x007FFCDDFCED714AULL, 0x003FFFCDFFD88096ULL, 0x0000040810002101ULL,
  0x0001000204080011ULL, 0x0001000204000801ULL, 0x0001000082000401ULL,
  0x0001FFFAABFAD1A2ULL
};
BITBOARD magic_rook_mask[64] = {
  0x000101010101017EULL, 0x000202020202027CULL, 0x000404040404047AULL,
  0x0008080808080876ULL, 0x001010101010106EULL, 0x002020202020205EULL,
  0x004040404040403EULL, 0x008080808080807EULL, 0x0001010101017E00ULL,
  0x0002020202027C00ULL, 0x0004040404047A00ULL, 0x0008080808087600ULL,
  0x0010101010106E00ULL, 0x0020202020205E00ULL, 0x0040404040403E00ULL,
  0x0080808080807E00ULL, 0x00010101017E0100ULL, 0x00020202027C0200ULL,
  0x00040404047A0400ULL, 0x0008080808760800ULL, 0x00101010106E1000ULL,
  0x00202020205E2000ULL, 0x00404040403E4000ULL, 0x00808080807E8000ULL,
  0x000101017E010100ULL, 0x000202027C020200ULL, 0x000404047A040400ULL,
  0x0008080876080800ULL, 0x001010106E101000ULL, 0x002020205E202000ULL,
  0x004040403E404000ULL, 0x008080807E808000ULL, 0x0001017E01010100ULL,
  0x0002027C02020200ULL, 0x0004047A04040400ULL, 0x0008087608080800ULL,
  0x0010106E10101000ULL, 0x0020205E20202000ULL, 0x0040403E40404000ULL,
  0x0080807E80808000ULL, 0x00017E0101010100ULL, 0x00027C0202020200ULL,
  0x00047A0404040400ULL, 0x0008760808080800ULL, 0x00106E1010101000ULL,
  0x00205E2020202000ULL, 0x00403E4040404000ULL, 0x00807E8080808000ULL,
  0x007E010101010100ULL, 0x007C020202020200ULL, 0x007A040404040400ULL,
  0x0076080808080800ULL, 0x006E101010101000ULL, 0x005E202020202000ULL,
  0x003E404040404000ULL, 0x007E808080808000ULL, 0x7E01010101010100ULL,
  0x7C02020202020200ULL, 0x7A04040404040400ULL, 0x7608080808080800ULL,
  0x6E10101010101000ULL, 0x5E20202020202000ULL, 0x3E40404040404000ULL,
  0x7E80808080808000ULL
};
unsigned int magic_rook_shift[64] = {
  52, 53, 53, 53, 53, 53, 53, 52,
  53, 54, 54, 54, 54, 54, 54, 53,
  53, 54, 54, 54, 54, 54, 54, 53,
  53, 54, 54, 54, 54, 54, 54, 53,
  53, 54, 54, 54, 54, 54, 54, 53,
  53, 54, 54, 54, 54, 54, 54, 53,
  53, 54, 54, 54, 54, 54, 54, 53,
  53, 54, 54, 53, 53, 53, 53, 53
};
BITBOARD mobility_mask_b[4] = { 0xFF818181818181FFULL,
                                0x007E424242427E00ULL,
                                0x00003C24243C0000ULL,
                                0x0000001818000000ULL };
BITBOARD mobility_mask_r[4] = { 0x8181818181818181ULL,
                                0x4242424242424242ULL,
                                0x2424242424242424ULL,
                                0x1818181818181818ULL };
const char empty[9] = { 0, '1', '2', '3', '4', '5', '6', '7', '8' };
int king_tropism_n[8] = { 0, 3, 3, 2, 1, 0, 0, 0 };
int king_tropism_b[8] = { 0, 2, 2, 1, 0, 0, 0, 0 };
int king_tropism_r[8] = { 0, 4, 3, 2, 1, 1, 1, 1 };
int king_tropism_at_r = 1;
int king_tropism_q[8] = { 0, 6, 5, 4, 3, 2, 2, 2 };
int king_tropism_at_q = 2;
int connected_passed_pawn_value[8] = { 0, 0, 20, 40, 80, 140, 200, 0 };
int hidden_passed_pawn_value[8] = { 0, 0, 0, 0, 20, 40, 0, 0 };
int passed_pawn_value[8] = { 0, 12, 20, 48, 72, 120, 150, 0 };
int blockading_passed_pawn_value[8] = { 0, 6, 10, 24, 36, 60, 75, 0 };
int doubled_pawn_value[9] = { 0, 0, 5, 8, 11, 11, 11, 11, 11 }; //{ 0, 0, 4, 7, 10, 10, 10, 10, 10 };
int supported_passer[8] = { 0, 0, 0, 20, 40, 60, 100, 0 };
int outside_passed = 100;
const char square_color[64] = {
  1, 0, 1, 0, 1, 0, 1, 0,
  0, 1, 0, 1, 0, 1, 0, 1,
  1, 0, 1, 0, 1, 0, 1, 0,
  0, 1, 0, 1, 0, 1, 0, 1,
  1, 0, 1, 0, 1, 0, 1, 0,
  0, 1, 0, 1, 0, 1, 0, 1,
  1, 0, 1, 0, 1, 0, 1, 0,
  0, 1, 0, 1, 0, 1, 0, 1
};
const char b_n_mate_dark_squares[64] = {
  99, 90, 80, 70, 60, 50, 40, 30,
  90, 80, 70, 60, 50, 40, 30, 40,
  80, 70, 60, 50, 40, 30, 40, 50,
  70, 60, 50, 40, 30, 40, 50, 60,
  60, 50, 40, 30, 40, 50, 60, 70,
  50, 40, 30, 40, 50, 60, 70, 80,
  40, 30, 40, 50, 60, 70, 80, 90,
  30, 40, 50, 60, 70, 80, 90, 99
};
const char b_n_mate_light_squares[64] = {
  30, 40, 50, 60, 70, 80, 90, 99,
  40, 30, 40, 50, 60, 70, 80, 90,
  50, 40, 30, 40, 50, 60, 70, 80,
  60, 50, 40, 30, 40, 50, 60, 70,
  70, 60, 50, 40, 30, 40, 50, 60,
  80, 70, 60, 50, 40, 30, 40, 50,
  90, 80, 70, 60, 50, 40, 30, 40,
  99, 90, 80, 70, 60, 50, 40, 30
};
const int mate[64] = {
  200, 180, 160, 140, 140, 160, 180, 200,
  180, 160, 140, 120, 120, 140, 160, 180,
  160, 140, 120, 100, 100, 120, 140, 160,
  140, 120, 100, 100, 100, 100, 120, 140,
  140, 120, 100, 100, 100, 100, 120, 140,
  160, 140, 120, 100, 100, 120, 140, 160,
  180, 160, 140, 120, 120, 140, 160, 180,
  200, 180, 160, 140, 140, 160, 180, 200
};
int white_outpost[64] = {
  0, 0,  0,  0,  0,  0, 0, 0,
  0, 0,  0,  0,  0,  0, 0, 0,
  0, 0,  0,  0,  0,  0, 0, 0,
  0, 5, 10, 20, 20, 10, 5, 0,
  0, 5, 10, 24, 24, 10, 5, 0,
  0, 0, 10, 24, 24, 10, 0, 0,
  0, 0,  0,  0,  0,  0, 0, 0,
  0, 0,  0,  0,  0,  0, 0, 0
};
int pval_w[64] = {
  0,   0,  0,   0,   0,  0,  0,  0,
  0,   0,  0, -12, -12,  0,  0,  0,
  1,   1,  1,  10,  10,  1,  1,  1,
  3,   3,  3,  13,  13,  3,  3,  3,
  6,   6,  6,  16,  16,  6,  6,  6,
  10, 10, 10,  30,  30, 10, 10, 10,
  70, 70, 70,  70,  70, 70, 70, 70,
  0,   0,  0,   0,   0,  0,  0,  0
};
int nval[64] = {
  -60, -30, -30, -30, -30, -30, -30, -60,
  -30, -24, -10, -10, -10, -10, -24, -30,
  -30,  -6,  -6,  -6,  -6,  -6,  -6, -30,
  -30,  -6,  -2,   0,   0,  -2,  -6, -30,
  -30,  -6,  -2,   0,   0,  -2,  -6, -30,
  -30,  -6,  -6,  -6,  -6,  -6,  -6, -30,
  -30, -24, -10, -10, -10, -10, -24, -30,
  -60, -30, -30, -30, -30, -30, -30, -60,
};
int qval[64] = {
  -20, -20,  0,  0,  0,  0, -20, -20,
  -20,   0,  8,  8,  8,  8,   0, -20,
    0,   8,  8, 12, 12,  8,   8,   0,
    0,   8, 12, 16, 16, 12,   8,   0,
    0,   8, 12, 16, 16, 12,   8,   0,
    0,   8,  8, 12, 12,  8,   8,   0,
  -20,   0,  8,  8,  8,  8,   0, -20,
  -20, -20,  0,  0,  0,  0, -20, -20,
};
int kval_wn[64] = {
  -40, -40, -40, -40, -40, -40, -40, -40,
  -40, -10, -10, -10, -10, -10, -10, -40,
  -40, -10,  20,  20,  20,  20, -10, -40,
  -40, -10,  40,  40,  40,  40, -10, -40,
  -40, -10,  60,  60,  60,  60, -10, -40,
  -40, -10,  60,  60,  60,  60, -10, -40,
  -40, -10, -10, -10, -10, -10, -10, -40,
  -40, -40, -40, -40, -40, -40, -40, -40
};
int kval_wk[64] = {
  -60, -40, -20, -20, -20, -20, -20, -20,
  -60, -40, -20,   0,   0,   0,   0,   0,
  -60, -40, -20,  20,  20,  20,  20,  20,
  -60, -40, -20,  20,  40,  40,  40,  40,
  -60, -40, -20,  20,  60,  60,  60,  40,
  -60, -40, -20,  20,  60,  60,  60,  40,
  -60, -40, -20,  20,  40,  40,  40,  40,
  -60, -40, -20, -20, -20, -20, -20, -20
};
int kval_wq[64] = {
  -20, -20, -20, -20, -20, -20, -40, -60,
    0,   0,   0,   0,   0, -20, -40, -60,
   20,  20,  20,  20,  20, -20, -40, -60,
   40,  40,  40,  40,  20, -20, -40, -60,
   40,  60,  60,  60,  20, -20, -40, -60,
   40,  60,  60,  60,  20, -20, -40, -60,
   40,  40,  40,  40,  20, -20, -40, -60,
  -20, -20, -20, -20, -20, -20, -40, -60
};
int safety_vector[16] = {
  0, 7, 14, 21, 28, 35, 42, 49,
  56, 63, 70, 77, 84, 91, 98, 105
};
int tropism_vector[16] = {
  0, 1, 2, 3, 4, 5, 11, 20,
  32, 47, 65, 86, 110, 137, 167, 200
};

/* note that black piece/square values are copied from white, but
   reflected */
const int p_values[15] = { QUEEN_VALUE, ROOK_VALUE, BISHOP_VALUE, 0,
  KING_VALUE, KNIGHT_VALUE, PAWN_VALUE, 0, PAWN_VALUE, KNIGHT_VALUE,
  KING_VALUE, 0, BISHOP_VALUE, ROOK_VALUE, QUEEN_VALUE
};
const int p_vals[8] =
    { 0, pawn_v, knight_v, king_v, 0, bishop_v, rook_v, queen_v
};
int pawn_value = PAWN_VALUE;
int knight_value = KNIGHT_VALUE;
int bishop_value = BISHOP_VALUE;
int rook_value = ROOK_VALUE;
int queen_value = QUEEN_VALUE;
int king_value = KING_VALUE;
int pawn_can_promote = 525;
int bad_trade = 90;
int dented_armor = 6;
int wtm_bonus = 5;
int gen_trop = 2;
int gen_trop_mid = 7;
int max_pair_b = 70;
int pair_b_min = 8;
int lower_b1 = 16;
int lower_b2 = 32;
int lower_r = 16;               //15;
int lower_r_percent = 6;
int supports_slider = 3;
int attacks_enemy = 4;
int mobility_score_b[4] = { 1, 2, 3, 5 };
int mobility_score_r[4] = { 1, 2, 3, 4 };
int undeveloped_piece = 12;
int friendly_queen[8] = { 2, 2, 2, 1, 0, 0, -1, -1 };
int pawns_blocked = 2;
int center_pawn_unmoved = 8;
int pawn_duo = 2;
int pawn_weak[9] = { 0, 10, 20, 30, 40, 50, 60, 70, 80 };
int pawn_islands[5] = { 0, 0, 0, 15, 30 };
int pawn_protected_passer_wins = 50;
int won_kp_ending = 200;
int split_passed = 50;
int king_king_tropism = 10;
int bishop_trapped = 174;
int slider_with_wing_pawns = 36;

/*
    this is indexed by the center status (open, ..., blocked)
    as a bishop pair is more important when the board has opened
    up so that mobility is high.  0 is blocked, 60 is open, middle
    value is in-between.
*/
//int bishop_pair[3] = { 0, 30, 60 };
int rook_on_7th = 24;
int rook_connected_7th_rank = 10;

/*
    each row contains values for a rook occupying a specific open
    file starting with file A and going through file H.  Row 0 is
    not used, row 1 is used when there is only one open file on
    the board, row 2 is used when there are two openfiles on the
    board, etc.  obviously control of a file is more important if
    there is only one or two files available.
*/
int rook_open_file[9][8] = {
  {0, 0, 0, 0, 0, 0, 0, 0},
  {20, 27, 35, 40, 40, 35, 27, 20},
  {13, 18, 23, 26, 26, 23, 18, 13},
  {10, 13, 17, 20, 20, 17, 13, 10},
  {10, 13, 17, 20, 20, 17, 13, 10},
  {10, 13, 17, 20, 20, 17, 13, 10},
  {10, 13, 17, 20, 20, 17, 13, 10},
  {10, 13, 17, 20, 20, 17, 13, 10},
  {10, 13, 17, 20, 20, 17, 13, 10}
};
int rook_reaches_open_file = 16;
int rook_half_open_file = 10;
int rook_behind_passed_pawn = 24;
int rook_trapped = 40;
int queen_rook_on_7th_rank = 50;
int queen_offside = 30;
int open_file[8] = { 6, 5, 4, 4, 4, 4, 5, 6 };
int half_open_file[8] = { 4, 4, 3, 3, 3, 3, 4, 4 };
int king_safety_mate_threat = 600;
int development_thematic = 12;
int blocked_center_pawn = 12;
int development_losing_castle = 20;
int development_not_castled = 20;

/*
   First term is a character string explaining what the eval
   term is used for.  Second term is the "size" of the thing.
   0 means scalar value, + numbers mean an array, -64 means an
   array of 64 but displayed as a 8 x 8 chess board, to make it
   easier to understand.  When entering this data, a1 is first
   value, etc, down to h8.  When the data is displayed, however,
   it is displayed as an 8 x 8 matrix with a1 = lower left corner,
   for easier visualization.  Third term is a pointer to the
   data value(s).
*/
struct eval_term eval_packet[256] = {
  {"raw piece values----------------", 0, NULL},        /* 0 */
  {"pawn value                      ", 0, &pawn_value},
  {"knight value                    ", 0, &knight_value},
  {"bishop value                    ", 0, &bishop_value},
  {"rook value                      ", 0, &rook_value},
  {"queen value                     ", 0, &queen_value},
  {"bad trade bonus/penalty         ", 0, &bad_trade},
  {"wtm bonus                       ", 0, &wtm_bonus},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {"pawn evaluation-----------------", 0, NULL},        /* 20 */
  {"center pawn blocked             ", 0, &pawns_blocked},
  {"center pawn unmoved             ", 0, &center_pawn_unmoved},
  {"pawn duo                        ", 0, &pawn_duo},
  {"protected passed pawn wins      ", 0, &pawn_protected_passer_wins},
  {"pawn weak [n]                   ", 9, pawn_weak},
  {"pawn islands [0-4]              ", 5, pawn_islands},
  {"pawn can promote                ", 0, &pawn_can_promote},
  {"won kp ending                   ", 0, &won_kp_ending},
  {"split passed pawn bonus         ", 0, &split_passed},
  {"outside passed pawn             ", 0, &outside_passed},
  {"pawn piece/square table         ", -64, pval_w},
  {"connected passed pawn [rank]    ", 8, connected_passed_pawn_value},
  {"hidden passed pawn [rank]       ", 8, hidden_passed_pawn_value},
  {"passed pawn [rank]              ", 8, passed_pawn_value},
  {"blockading a passed pawn [rank] ", 8, blockading_passed_pawn_value},
  {"doubled pawn [n]                ", 9, doubled_pawn_value},
  {"supported passed pawn [rank]    ", 8, supported_passer},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {"knight scoring------------------", 0, NULL},        /* 50 */
  {"king tropism [distance]         ", 8, king_tropism_n},
  {"knight piece/square table       ", -64, nval},
  {"outpost [square]                ", -64, white_outpost},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {"bishop scoring------------------", 0, NULL},        /* 60 */
  {"bishop over knight endgame      ", 0, &slider_with_wing_pawns},
  {"bishop trapped                  ", 0, &bishop_trapped},
  {"king tropism [distance]         ", 8, king_tropism_b},
  {"bishop mobility/square table    ", 4, mobility_score_b},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {"rook scoring--------------------", 0, NULL},        /* 70 */
  {"rook on 7th                     ", 0, &rook_on_7th},
  {"rook connected 7th rank         ", 0, &rook_connected_7th_rank},
  {"rook trapped                    ", 0, &rook_trapped},
  {"rook behind passed pawn         ", 0, &rook_behind_passed_pawn},
  {"rook half open file             ", 0, &rook_half_open_file},
  {"rook open file [9][8]           ", 72, &rook_open_file[0][0]},
  {"rook reaches open file          ", 0, &rook_reaches_open_file},
  {"king tropism [distance]         ", 8, king_tropism_r},
  {"king file tropism [distance]    ", 0, &king_tropism_at_r},
  {"rook mobility/square table      ", 4, mobility_score_r},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {"queen scoring-------------------", 0, NULL},        /* 90 */
  {"queen rook on 7th rank          ", 0, &queen_rook_on_7th_rank},
  {"queen offside                   ", 0, &queen_offside},
  {"king tropism [distance]         ", 8, king_tropism_q},
  {"king file tropism [distance]    ", 0, &king_tropism_at_q},
  {"queen piece/square table        ", -64, qval},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {"king scoring--------------------", 0, NULL},        /* 100 */
  {"king king tropism (endgame)     ", 0, &king_king_tropism},
  {"king safety trojan horse threat ", 0, &king_safety_mate_threat},
  {"king piece/square normal        ", -64, kval_wn},
  {"king piece/square kside pawns   ", -64, kval_wk},
  {"king piece/square qside pawns   ", -64, kval_wq},
  {"king safe open file [file]      ", 8, open_file},
  {"king safe half-open file [file] ", 8, half_open_file},
  {"king safety pawn-shield vector  ", 16, safety_vector},
  {"king safety tropism vector      ", 16, tropism_vector},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {NULL, 0, NULL},
  {"development scoring-------------", 0, NULL},        /* 120 */
  {"development thematic            ", 0, &development_thematic},
  {"development blocked center pawn ", 0, &blocked_center_pawn},
  {"development losing castle       ", 0, &development_losing_castle},
  {"development not castled         ", 0, &development_not_castled},
};
