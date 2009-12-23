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

void pile_initialization();
void search_halt( int );
void resolve_term( int );
void search_initialization( char * );
void notify( sint64 );
void valuation( int, int, int );
void mobility();
void value_zobrist_free();

type_list_move *capture_move( type_list_move *, uint64 );
type_list_move *ordinary_move( type_list_move * );
type_list_move *evasion_move( type_list_move *, uint64 );
void initialization_capture();

type_list_move *capture_white( type_list_move *, uint64 );
type_list_move *capture_black( type_list_move *, uint64 );
type_list_move *ordinary_white( type_list_move * );
type_list_move *ordinary_black( type_list_move * );
void sort_ordinary( type_list_move *, type_list_move *, uint32, uint32, uint32 );

type_list_move *check_quiet_white( type_list_move *, uint64 );
type_list_move *check_quiet_black( type_list_move *, uint64 );

type_list_move *gain_white( type_list_move *, int );
type_list_move *gain_black( type_list_move *, int );
type_list_move *evasion_black( type_list_move *, uint64 );
type_list_move *evasion_white( type_list_move *, uint64 );

void year_increase();
void zobrist_free();
int initialization_zobrist( int );

void Zobrist_low_total( int, int, int );
void Zobrist_high_cut( int, int );
void Zobrist_low( uint64, int, int, int );
void Zobrist_high( uint64, int, int );
void Zobrist_accurate( int, int, int, int );

bool input_console();

void history_reset();
void gain_reset();

void make( uint32 );
void cancel( uint32 );
void do_white( uint32 );
void cancel_white( uint32 );
void do_black( uint32 );
void cancel_black( uint32 );

void initialization_value();
typedef struct
    {
    int phase, celare, cb;
    uint32 move_trans, move;
    uint64 tag;
    type_list_move LIST[256];
    uint32 capture_bad[64];
    } type_next;
uint32 next_white( type_next * );
uint32 next_black( type_next * );

bool ensure_white( uint32 );
bool ensure_black( uint32 );

void pawn_initialization();
void valuation_pawn( type_pawn_value * );

int pv_search_fine_white( int, int, int );
int pv_search_fine_check_white( int, int, int );
int pv_search_fine_black( int, int, int );
int pv_search_fine_check_black( int, int, int );

void search_high_white();
void search_high_black();
int node_top_white( int, int, int );
int node_top_black( int, int, int );

int node_pv_white( int, int, int, int );
int node_pv_black( int, int, int, int );

int exclude_white( int, int, uint32 );
int exclude_check_white( int, int, uint32 );
int exclude_black( int, int, uint32 );
int exclude_check_black( int, int, uint32 );

int node_cut_white( int VALUE, int DEPTH );
int node_cut_black( int VALUE, int DEPTH );
int node_cut_check_white( int VALUE, int DEPTH );
int node_cut_check_black( int VALUE, int DEPTH );

int node_total_white( int VALUE, int DEPTH );
int node_total_black( int VALUE, int DEPTH );
int node_total_check_white( int VALUE, int DEPTH );
int node_total_check_black( int VALUE, int DEPTH );

int search_half_white( int VALUE, int DEPTH );
int search_half_black( int VALUE, int DEPTH );
int search_half_check_white( int VALUE, int DEPTH );
int search_half_check_black( int VALUE, int DEPTH );

int search_fine_white( int VALUE, int DEPTH );
int search_fine_black( int VALUE, int DEPTH );
int search_fine_check_white( int VALUE, int DEPTH );
int search_fine_check_black( int VALUE, int DEPTH );

void output_best_move();
void search();
void information( sint64, int, int, int );

bool see_white( uint32 move );
bool see_black( uint32 move );

char *law_fen( char * );
void positional_initialization( char * );

void static_initialization();

void ERROR_( char *, ... );
void ERROR_fen( char *, ... );

char *move_notation( uint32, char * );
uint64 clock_();
uint64 process_clock();
void bitboard_initialization();
void game_new( bool );
bool question_input();
void show_version();
int check_num_CPU();

void options_initialization(); // fix
