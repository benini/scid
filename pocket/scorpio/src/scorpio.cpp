#include "scorpio.h"

/*
all external variables declared here
*/
const int pawn_dir[2] = {UU,DD};
const int col_tab[14] = {neutral,white,white,white,white,white,white,
black,black,black,black,black,black,neutral};
const int pic_tab[14] = {empty,king,queen,rook,bishop,knight,pawn,
king,queen,rook,bishop,knight,pawn,elephant};
const int piece_cv[14] = {0,0,9,5,3,3,1,0,9,5,3,3,1,0};
const int piece_mask[14] = {0,KM,QM,RM,BM,NM,WPM,KM,QM,RM,BM,NM,BPM,0};
SQATTACK  temp_sqatt[0x101];
PSQATTACK const sqatt = &temp_sqatt[0x80];
int dummy;
int pcsq[14][0x80];
int age;
bool book_loaded = false;
bool log_on = true;
/*
parallel search
*/
#ifdef PARALLEL

LOCK  lock_smp;
LOCK  lock_io;
PROCESSOR processors[MAX_CPUS];
SEARCHER searchers[MAX_SEARCHERS];
int n_processors;
int n_searchers;

#endif
/*
static global variables of SEARCHER
*/
UBMP32 SEARCHER::history[2][4096];
CHESS_CLOCK SEARCHER::chess_clock;
int SEARCHER::search_depth;
int SEARCHER::start_time;
int SEARCHER::scorpio;
int SEARCHER::pv_print_style;
int SEARCHER::root_score;
int SEARCHER::prev_root_score;
int SEARCHER::root_failed_low;
int SEARCHER::last_book_move;
int SEARCHER::first_search;
int SEARCHER::probe_depth;
PERSONALITY SEARCHER::phase_personality[3];
int SEARCHER::abort_search;
UBMP32 SEARCHER::poll_nodes;
/*
static global variables/functions
*/
static SEARCHER searcher;
static SEARCHER searcher1;
static PSEARCHER main_searcher;
static int ponder = false;
static int analysis_mode = false;
static int result = R_UNKNOWN;
static int resign_value;
static int resign_count;
static char egbb_path[MAX_STR] = "/tmp/egbb/"; //"./egbb/";
static int  egbb_cache_size = 4;

static bool load_personality(char*,PPERSONALITY);
static bool load_ini();
static bool parse_commands(char**);
/*
only winboard protocol support
*/
int CDECL main(int argc, char* argv[]) {
	char   buffer[MAX_FILE_STR];
	char*  commands[MAX_STR];

  init_socket();

	/*init game*/
	init_game();
	
	/*parse scorpio.ini*/
	if(!load_ini()) 
		;// return 0;

	/*parse command line*/
	strcpy(buffer,"");
	for(int i = 1;i < argc;i++)	{
		strcat(buffer," ");
		strcat(buffer,argv[i]);
	}

	commands[tokenize(buffer,commands)] = NULL;
	if(!parse_commands(commands))
		return 0;

  //PG: load multi-personality
  if(!load_personality("opn",&SEARCHER::phase_personality[0]))
    send_msg("ERROR load_personality erreur\n");
  if(!load_personality("mid",&SEARCHER::phase_personality[1]))
    send_msg("ERROR load_personality erreur\n");
  if(!load_personality("end",&SEARCHER::phase_personality[2]))
    send_msg("ERROR load_personality erreur\n");

	print_log("==============================\n");
	egbb_cache_size = 100 * 1024 ; // PPC(egbb_cache_size * 1024 * 1024);
	SEARCHER::egbb_is_loaded = LoadEgbbLibrary(egbb_path,egbb_cache_size);

	while(true) {

#ifdef WIN32
    uiAlive();
#endif

		/*parse standard input*/
		if(!read_line(buffer)) {
      my_usleep(10000);

// 			return 0;
		}
        commands[tokenize(buffer,commands)] = NULL;
		if(!parse_commands(commands))
			return 0;
	}

	return 0;
}
/*
initialize game
*/
void init_game() {
	init_io();

#ifdef PARALLEL
	n_processors = 1;
	init_smp(1);
	l_create(lock_smp);
	l_create(lock_io);
	main_searcher = &searchers[0];
#else
	main_searcher = &searcher1;
#endif
	
	SEARCHER::egbb_is_loaded = false;

	init_sqatt();
	init_hash_tables();
	load_book();
	searcher.pre_calculate();
	searcher.new_board();
	SEARCHER::scorpio = black;
	SEARCHER::pv_print_style = 0;
	resign_value = 600;
	resign_count = 0;
}
/*
"help" command added by Dann Corbit
*/
static const char *commands_recognized[] = {
    "accepted -- Response to the feature command.",
		"analyze -- Enter analyze mode.",
		"d -- Debugging command to print the current board.",
		"easy -- Turn off pondering.",
		"eht -- Set evaluation hash table size in megabytes.",
		"force -- Set the engine to play neither color ('force mode'). Stop clocks.",
		"go -- Leave force mode and set the engine to play the color that is on move.",
		"hard -- Turn on pondering (thinking on the opponent's time or permanent brain).",
		"help -- Produce this listing of supported commands.",
		"history -- Debugging command to print game history.",
		"ht -- Set hash table size in megabytes.",
		"level -- level <MPS> <BASE> <INC> {Set time controls}.",
		"mirror -- Debugging command to mirror the current board.",
		"moves -- Debugging command to print all possible moves for the current board.",
		"new -- Reset the board to the standard chess starting position.",
		"otim -- otim N {Set a clock that belongs to the opponent in centiseconds.}",
		"perft -- perft <depth> performs a move generation count to <depth>.",
		"pht -- Set pawn hash table size in megabytes.",
		"protover -- protover <N> {Command sent immediately after the 'xboard' command.}",
		"quit -- The chess engine should immediately exit.",
		"runeval -- runeval <epdfile> runs the evalution function on EPD file <epdfile>.",
		"score -- score runs the evaluation function on the current position.",
		"sd -- sd <DEPTH> {The engine should limit its thinking to <DEPTH> ply.}",
		"setboard -- setboard <FEN> is used to set up FEN position <FEN>.",
		"st -- st <TIME> {Set time controls search time in seconds.}",
		"time -- time <N> {Set a clock that belongs to the engine in centiseconds.}",
		"undo -- The user asks to back up one half move.",
        "remove -- The user asks to back up full move.",
		"book <on/off> -- Turns book usage on/off.",
		"personality -- Set personality file.",
		"pvstyle -- syle for pv output.",
		NULL
};
/*
parse_commands
*/
bool parse_commands(char** commands) {

    char*  command;
	int    command_num;
	MOVE   move;
	char   mv_str[10];
	int    do_search;

	command_num = 0;
	
	while(command = commands[command_num++]) {
		/*
		xboard
		*/
		do_search = false;

		if (!strcmp(command, "protover")) {
			send_msg("feature sigint=0 sigterm=0 setboard=1 draw=0 done=1 colors=0 name=1 myname=\"Scorpio %s\"\n",VERSION);
			commands[command_num++];
} else if(!strcmp(command,"setpriority")) {
      int prio = atoi(commands[command_num++]);
      lowPrio(prio);
		} else if (!strcmp(command, "xboard")) {
		} else if (!strcmp(command, "computer")
            || !strcmp(command, "post")
            || !strcmp(command, "nopost")
            || !strcmp(command, "random")
			|| !strcmp(command, "?") 
            || !strcmp(command, ".")  
			) {
		} else if (!strcmp(command, "accepted")
            || !strcmp(command, "rejected")
			) {
			commands[command_num++];
        } else if (!strcmp(command, "name")) {
			send_msg("Hello %s!\n",commands[command_num++]);
			commands[command_num++];
		} else if(!strcmp(command,"st")) {
			SEARCHER::chess_clock.max_sd = MAX_PLY;
			SEARCHER::chess_clock.max_st = 1000 * (atoi(commands[command_num++]));
		} else if(!strcmp(command,"sd")) {
			SEARCHER::chess_clock.max_st = MAX_NUMB;
			SEARCHER::chess_clock.max_sd = atoi(commands[command_num++]);
		} else if(!strcmp(command,"level")) {
			SEARCHER::chess_clock.mps = atoi(commands[command_num++]);
			if(strstr(commands[command_num],":")) {
				int min,sec;
				sscanf(commands[command_num],"%d:%d",&min,&sec);
				SEARCHER::chess_clock.p_time = 60000 * min + 1000 * sec;
				command_num++;
			} else {
				SEARCHER::chess_clock.p_time = 60000 * atoi(commands[command_num++]);
			}
			SEARCHER::chess_clock.inc = 1000 * atoi(commands[command_num++]);
			SEARCHER::chess_clock.o_time = searcher.chess_clock.p_time;
			SEARCHER::chess_clock.max_st = MAX_NUMB;
			SEARCHER::chess_clock.max_sd = MAX_PLY;
		} else if(!strcmp(command,"time")) {
			SEARCHER::chess_clock.p_time = (10 * atoi(commands[command_num++]));
			SEARCHER::chess_clock.max_st = MAX_NUMB;
			SEARCHER::chess_clock.max_sd = MAX_PLY;
		} else if(!strcmp(command,"otim")) {
			SEARCHER::chess_clock.o_time = (10 * atoi(commands[command_num++]));
			SEARCHER::chess_clock.max_st = MAX_NUMB;
			SEARCHER::chess_clock.max_sd = MAX_PLY;
        } else if(!strcmp(command,"hard")) {
			ponder = true;
		} else if(!strcmp(command,"easy")) {
			ponder = false;
		} else if(!strcmp(command,"force")) {
			SEARCHER::scorpio = neutral;
		} else if(!strcmp(command,"exit")) {
			analysis_mode = false;
		} else if(!strcmp(command,"result")) {
			if(!strcmp(commands[command_num],"1-0"))
				result = R_WWIN;
			else if(!strcmp(commands[command_num],"0-1"))
				result = R_BWIN;
			else if(!strcmp(commands[command_num],"1/2-1/2"))
				result = R_DRAW;
			else
				result = R_UNKNOWN;
			while(commands[++command_num]);
        } else if(!strcmp(command,"quit")) {
			send_msg("Bye Bye\n");
			return false; 
        } else if (!strcmp(command, "new")) {
			clear_hash_tables();
			searcher.new_board();
			result = R_UNKNOWN;
			SEARCHER::scorpio = black;
		} else if(!strcmp(command,"setboard")) {
			clear_hash_tables();
			char fen[MAX_STR];
			strcpy(fen,commands[command_num++]);
			strcat(fen," ");
			strcat(fen,commands[command_num++]);
			strcat(fen," ");
			strcat(fen,commands[command_num++]);
			strcat(fen," ");
			strcat(fen,commands[command_num++]);
			strcat(fen," ");
			if(commands[command_num]) {
				strcat(fen,commands[command_num++]);
				strcat(fen," ");

				if(commands[command_num]) {
					strcat(fen,commands[command_num++]);
					strcat(fen," ");
				}
			}
			
			searcher.set_board(fen);
			result = R_UNKNOWN;
        } else if(!strcmp(command,"undo")) {
			if(searcher.hply >= 1) searcher.undo_move();
			if(analysis_mode) do_search = true;
        } else if(!strcmp(command,"remove")) {
			if(searcher.hply >= 1) searcher.undo_move();
            if(searcher.hply >= 1) searcher.undo_move();
			if(analysis_mode) do_search = true;
        } else if(!strcmp(command,"go")) {
			SEARCHER::scorpio = searcher.player;
			do_search = true;
        } else if(!strcmp(command,"analyze")) {
			analysis_mode = true;
			do_search = true;
			/*
			others
			*/
    } else if(!strcmp(command,"ht") || !strcmp(command,"sethash")) {
			UBMP32 size = 1,size_max = (atoi(commands[command_num++]) * 1024 ) / 2;
			while(size < size_max) size *= 2;
			size /= sizeof(HASH);
			reset_hash_tab(size);
			send_msg("ht %d X %d\n",2 * size,sizeof(HASH));
		} else if(!strcmp(command,"pht")) {
			UBMP32 size = 1,size_max = (atoi(commands[command_num++]) * 1024 );
			while(size < size_max) size *= 2;
			size /= sizeof(PAWNHASH);
			reset_pawn_hash_tab(size);
			send_msg("pht %d X %d\n",size,sizeof(PAWNHASH));
        } else if(!strcmp(command,"eht")) {
			UBMP32 size = 1,size_max = (atoi(commands[command_num++]) * 1024 );
			while(size < size_max) size *= 2;
			size /= sizeof(EVALHASH);
			reset_eval_hash_tab(size);
			send_msg("eht %d X %d\n",size,sizeof(EVALHASH));
		} else if(!strcmp(command, "resign")) {
			resign_value = atoi(commands[command_num]);
			command_num++;
			/*
			parallel search
			*/
		} else if(!strcmp(command,"mt")) {
#ifdef PARALLEL
			int mt = atoi(commands[command_num]);
			mt = min(mt, MAX_CPUS);
			init_smp(mt);
			send_msg("processors [%d]\n",n_processors);
#endif
			command_num++;
			/*
			personality
			*/
		} else if(!strcmp(command, "personality")) {
			if(!load_personality(commands[command_num++],&SEARCHER::phase_personality[0])) 
				return false;
			memcpy(&SEARCHER::phase_personality[1],&SEARCHER::phase_personality[0],sizeof(PERSONALITY));
			memcpy(&SEARCHER::phase_personality[2],&SEARCHER::phase_personality[0],sizeof(PERSONALITY));
		} else if(!strcmp(command, "multi_personality")) {
			for(int i = 0; i < 3 ; i++) {
				if(!load_personality(commands[command_num++],&SEARCHER::phase_personality[i])) 
					return false;
			}
			/*
			egbb
			*/
		} else if(!strcmp(command, "egbb_path")) {
			strcpy(egbb_path,commands[command_num]);
			command_num++;
		} else if(!strcmp(command, "egbb_cache_size")) {
			egbb_cache_size = atoi(commands[command_num]);
			command_num++;
        } else if(!strcmp(command, "egbb_load_type")) {
			SEARCHER::egbb_load_type = atoi(commands[command_num]);
			command_num++;
		} else if (!strcmp(command, "book")) {
			if(commands[command_num]) {
				if(!strcmp(commands[command_num],"on"))
					book_loaded = true;
				else if(!strcmp(commands[command_num],"off"))
					book_loaded = false;
				command_num++;
			} else {
				searcher.show_book_moves();
			}
		} else if (!strcmp(command, "log")) {
			if(!strcmp(commands[command_num],"on"))
				log_on = true;
			else if(!strcmp(commands[command_num],"off"))
				log_on = false;
			command_num++;
		} else if(!strcmp(command, "help")) {
			size_t index = 0;
			while (commands_recognized[index]) {
				puts(commands_recognized[index]);
				index++;
			}
			/*
			debugging
			*/
		} else if(!strcmp(command,"d")) {
			searcher.print_board();
		} else if(!strcmp(command,"mirror")) {
			searcher.mirror();
		} else if(!strcmp(command,"history")) {
			searcher.print_history();
		} else if(!strcmp(command,"moves")) {
			searcher.print_allmoves();
		} else if(!strcmp(command,"pvstyle")) {
			SEARCHER::pv_print_style = atoi(commands[command_num]);
			command_num++;
		} else if(!strcmp(command,"perft")) {
			int depth = atoi(commands[command_num++]);
			int nodes = searcher.perft(depth);
			send_msg("\nnodes %d\n",nodes);
		} else if(!strcmp(command,"score")) {
			int score;
			if(searcher.all_man_c <= 5) {
				searcher.probe_bitbases(score);
			    send_msg("bitbase_score = %d\n",score);
			} else {
			    score = searcher.eval();
				send_msg("score = %d\n",score);
			}
		} else if (!strcmp(command, "runeval") || !strcmp(command, "runsearch") ) {
			
			char input[MAX_STR],fen[MAX_STR];
			char* words[100];
			int nwrd,sc = 0,visited = 0;
			bool eval_test = !strcmp(command,"runeval");
			
			FILE *fd;
			
			fd = fopen(commands[command_num++],"r");
			
			if(!fd) {
				send_msg("epd file not found!\n");
				continue;
			}

			if(SEARCHER::pv_print_style != 1) 
				send_msg("******************************************\n");
			else
				send_msg("\n   Nodes     Time    NPS        splits   bad\n   =====     ====    ===        ======   ===\n");


			while(fgets(input,MAX_STR,fd)) {
				input[strlen(input) - 1] = 0;
				nwrd = tokenize(input,words);
				strcpy(fen,words[0]);
				strcat(fen," ");
				strcat(fen,words[1]);
				strcat(fen," ");
				strcat(fen,words[2]);
				strcat(fen," ");
				strcat(fen,words[3]);
				strcat(fen," ");
				visited++;
				searcher.set_board(fen);
				
				if(eval_test) {
					sc = searcher.eval();
					searcher.mirror();
					int sc1 = searcher.eval();
					if(sc == sc1)
						send_msg("*%d* %d\n",visited,sc);
					else {
						send_msg("*****WRONG RESULT*****\n");
					    send_msg("[ %s ] \nsc = %6d sc1 = %6d\n",fen,sc,sc1);
						send_msg("**********************\n");
					}
				} else {
					clear_hash_tables();
					main_searcher->COPY(&searcher);
			        main_searcher->find_best();
					if(SEARCHER::pv_print_style != 1) 
						send_msg("********** %d ************\n",visited);
				}
			}
			
			searcher.new_board();
			fclose(fd);
			/*
			move
			*/
		} else {
			str_mov(move,command);
			if(searcher.is_legal(move)) {
				searcher.do_move(move);
				result = searcher.print_result();
				do_search = true;
			} else {
				send_msg("Error (unknown command): %s\n", command);
			}
		}
		/*
		search if things have changed
		*/
		if(!do_search)
			continue;
		/*
		Analyze mode
		*/
		if(analysis_mode) {
			SEARCHER::chess_clock.infinite_mode = true;
			main_searcher->COPY(&searcher);
			main_searcher->find_best();
			SEARCHER::chess_clock.infinite_mode = false;
		}
		/*
		Play mode
		*/
		else if(SEARCHER::scorpio == searcher.player
			&& result == R_UNKNOWN
			) {
			main_searcher->COPY(&searcher);
			move = main_searcher->find_best();
			
			if(move) {
				mov_str_xboard(move,mv_str);
				send_msg("move %s\n",mv_str);
				searcher.do_move(move);
				result = searcher.print_result();
				
				if((SEARCHER::scorpio == white && SEARCHER::root_score < -resign_value) ||
					(SEARCHER::scorpio == black && SEARCHER::root_score >  resign_value)) {
					resign_count++;
				} else {
					resign_count = 0;
				}

				if(resign_count == 3) {
					send_msg("resign\n");
				}
				/*
				pondering
				*/
				else if(ponder
					&& result == R_UNKNOWN
					) {
					move = 0;
					probe_hash(searcher.player,searcher.hash_key,0,0,dummy,move,
						-MAX_SCORE,MAX_SCORE,dummy,dummy);
					if(move && !searcher.is_legal_fast(move))
						move = 0;
					if(move) {
						mov_str(move,mv_str);
						send_msg("pondering after move [%s]\n",mv_str);
						SEARCHER::chess_clock.infinite_mode = true;
						main_searcher->COPY(&searcher);
						main_searcher->do_move(move);
						main_searcher->find_best();
						SEARCHER::chess_clock.infinite_mode = false;
					} else {
						send_msg("pondering for opponent...\n");
						SEARCHER::chess_clock.infinite_mode = true;
						main_searcher->COPY(&searcher);
						main_searcher->find_best();
						SEARCHER::chess_clock.infinite_mode = false;
					}
				}
			}
		}
	}
	return true;
}

/*
initilization file
*/
static bool load_ini() {
	char   buffer[MAX_FILE_STR];
	char*  commands[MAX_STR];
	char   temp[MAX_STR];
	
	
	FILE* fd = fopen("scorpio.ini","r");
	if(!fd) {
		send_msg("Scorpio.ini not found!\n");
		return false;
	}
	
	strcpy(buffer,"");
	while(fgets(temp,MAX_STR,fd)) {
		if(temp[0] == '#' || temp[0] == '/' || temp[0] == '\n') continue;
		strcat(buffer,temp);
	}
	fclose(fd);

	print_log("========== scorpio.ini =======\n");
	print_log(buffer);
	print_log("==============================\n");

	commands[tokenize(buffer,commands)] = NULL;
	if(!parse_commands(commands))
		return false;

	return true;
}
/*
personality
*/
static bool load_personality(char* person_name,PPERSONALITY personality) {
	char   buffer[MAX_FILE_STR];
	char   temp[MAX_STR];
	char*  commands[MAX_STR];
	char*  command;
	int    command_num;
	
// 	strcpy(temp,"personality/");
#warning copy personality files in install dir/personality

  getcwd( temp, MAX_STR );
  strcat(temp,"/personality/");

	strcat(temp, person_name);
	strcat(temp,".per");
	
	FILE* fd = fopen(temp,"r");
	if(!fd) {
printf("error Personality %s not found!\n",temp);
		send_msg("Personality %s not found!\n",person_name);
		return false;
	}
	
	strcpy(buffer,"");
	while(fgets(temp,MAX_STR,fd)) {
		if(temp[0] == '#' || temp[0] == '/' || temp[0] == '\n') continue;
		strcat(buffer,temp);
	}
	fclose(fd);

	print_log("========== %s ===============\n",person_name);
	print_log(buffer);
	print_log("\n");
	
	commands[tokenize(buffer,commands)] = NULL;
	command_num = 0;
	
	while(command = commands[command_num++]) {
		if(!strcmp(command, "check_ext")) {
			personality->check_ext = atoi(commands[command_num++]);
		} else if(!strcmp(command, "re_capture_ext")) {
			personality->re_capture_ext = atoi(commands[command_num++]);
		} else if(!strcmp(command, "mate_threat_ext")) {
			personality->mate_threat_ext = atoi(commands[command_num++]);
		} else if(!strcmp(command, "pawn_push7_ext")) {
			personality->pawn_push7_ext = atoi(commands[command_num++]);
		} else if(!strcmp(command, "one_reply_ext")) {
			personality->one_reply_ext = atoi(commands[command_num++]);
		} else if(!strcmp(command, "horizon_ext")) {
			personality->horizon_ext = atoi(commands[command_num++]);
		} else if(!strcmp(command, "futl_margin")) {
			personality->futl_margin = atoi(commands[command_num++]);
		} else if(!strcmp(command, "lazy_margin")) {
			personality->lazy_margin = atoi(commands[command_num++]);
		} else if(!strcmp(command, "exchange_scale")) {
			personality->exchange_scale = atoi(commands[command_num++]);
		} else if(!strcmp(command, "bishop_pair_scale")) {
			personality->bishop_pair_scale = atoi(commands[command_num++]);
		} else if(!strcmp(command, "king_safety_scale")) {
			personality->king_safety_scale = atoi(commands[command_num++]);
		} else if(!strcmp(command, "mobility_scale")) {
			personality->mobility_scale = atoi(commands[command_num++]);
		} else if(!strcmp(command, "pawn_structure_scale")) {
			personality->pawn_structure_scale = atoi(commands[command_num++]);
		} else if(!strcmp(command, "passed_pawn_scale")) {
			personality->passed_pawn_scale = atoi(commands[command_num++]);
		} else if(!strcmp(command, "rook_on_7th_scale")) {
			personality->rook_on_7th_scale = atoi(commands[command_num++]);
		} else {
			send_msg("unknown command: %s\n",command);
		}
	}
	return true;
}
