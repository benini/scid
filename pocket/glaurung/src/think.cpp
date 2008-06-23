#include "glaurung.h"

void init_engine_options(int side) {
  char str[30];
  Options->analyse = get_option_value_bool("UCI_AnalyseMode");
  if(Options->analyse) 
    Options->ks_weight[side] = Options->ks_weight[side^1] =
      (((get_option_value_int("Aggressiveness") * 128) / 100) +
       ((get_option_value_int("Cowardice") * 128) / 100)) / 2;
  else {
    Options->ks_weight[side^1] = 
      (get_option_value_int("Aggressiveness") * 128) / 100;
    Options->ks_weight[side] = (get_option_value_int("Cowardice") * 128) / 100;
  }
  Options->pp_weight = 
    (get_option_value_int("Passed pawns (middle game)") * 128) / 100;
  Options->e_pp_weight = 
    (get_option_value_int("Passed pawns (endgame)") * 128) / 100;
  Options->ps_weight = 
    (get_option_value_int("Pawn structure (middle game)") * 128) / 100;
  Options->e_ps_weight =
    (get_option_value_int("Pawn structure (endgame)") * 128) / 100;
  Options->mob_weight = 
    (get_option_value_int("Mobility (middle game)") * 128) / 100;
  Options->e_mob_weight = 
    (get_option_value_int("Mobility (endgame)") * 128) / 100;
  Options->space_weight = (get_option_value_int("Space") * 128) / 100;
  Options->development_weight = 
    (get_option_value_int("Development") * 128) / 100;
  Options->use_eval_cache = get_option_value_bool("Static evaluation cache");
  Options->eval_cache_size =
    get_option_value_int("Static evaluation cache size");
  Options->static_pruning = get_option_value_bool("Static null move pruning");
  Options->pruning_depth = get_option_value_int("Static pruning depth") * PLY;

  get_option_value_string("Late move reductions", str);
  if(strncmp(str, "All nodes", 9) == 0) Options->lmr = ALL_NODES;
  else if(strncmp(str, "Non-PV nodes", 12) == 0) Options->lmr = NON_PV_NODES;
  else Options->lmr = DISABLED;
  get_option_value_string("Reduce based on", str);
  if(strncmp(str, "Knowledge and history", 21) == 0) 
    Options->lmr_criterion = LMR_KNOWLEDGE_AND_HISTORY;
  else if(strncmp(str, "Knowledge", 9) == 0)
    Options->lmr_criterion = LMR_KNOWLEDGE;
  else Options->lmr_criterion = LMR_HISTORY;

  get_option_value_string("Futility pruning", str);
  if(strncmp(str, "All nodes", 9) == 0) Options->fpruning = ALL_NODES;
  else if(strncmp(str, "Non-PV nodes", 12) == 0) 
    Options->fpruning = NON_PV_NODES;
  else Options->fpruning = DISABLED;
  Options->fmargin_0 = 
    (get_option_value_int("Futility margin 0") * P_VALUE) / 100;
  Options->fmargin_1 = 
    (get_option_value_int("Futility margin 1") * P_VALUE) / 100;
  Options->fmargin_2 = 
    (get_option_value_int("Futility margin 2") * P_VALUE) / 100;

  Options->mg_r = 
    get_option_value_int("Null move reduction factor (middle game)");
  Options->eg_r = 
    get_option_value_int("Null move reduction factor (endgame)");

  Options->check_ext = get_option_value_int("Check extension");
  Options->one_reply_ext = 
    get_option_value_int("One reply to check extension");
  Options->two_replies_ext =
    get_option_value_int("Two replies to check extension");
  Options->mate_threat_ext = get_option_value_int("Mate threat extension");
  Options->p7th_ext = get_option_value_int("Pawn push to 7th rank extension");
    
  Options->threat_depth = get_option_value_int("Threat depth") * PLY;
  Options->qs_checks = get_option_value_int("Checks in quiescence search");
  Options->hash_qsearch = get_option_value_bool("Hash quiescence search");
  Options->learning = get_option_value_bool("Position learning");
//   if(button_was_pushed("Clear position learning")) clear_learning();
  if(MaxNumOfThreads > 1) {
    static int old_num_of_threads = 0;
    Options->threads = get_option_value_int("Number of threads");
    if(Options->threads != old_num_of_threads) {
      init_pawn_hash_table(Options->threads);
      old_num_of_threads = Options->threads;
    }
    Options->split_depth = get_option_value_int("Minimum tree split depth");
  }
  else {
    Options->threads = 1; Options->split_depth = 0;
  }
    
  Options->ponder = get_option_value_bool("Ponder");
  Options->frc = get_option_value_bool("UCI_Chess960");
  Options->currline = get_option_value_bool("UCI_ShowCurrLine");
  Options->own_book = get_option_value_bool("OwnBook");
  Options->multipv = get_option_value_int("MultiPV");
  init_tt(get_option_value_int("Hash"));
  if(button_was_pushed("Clear Hash")) clear_tt();
  init_eval_cache();
}

void think(const position_t *pos, bool inf, int wtime, int btime, int winc, 
           int binc, int movestogo, bool ponder, int depth_limit, 
           int node_limit, int exact_time, move_t moves[]) {
  int time, inc;

  init_root_search_info();
  init_engine_options(pos->side);
  if(!inf && pos->gply < 60 && Options->own_book) {
    move_t book_move = pick_book_move(Book, pos->key);
    if(book_move != 0) {
      if(book_move == 1) book_move |= (1 << 17);  // HACK
      RSI->bestmove = book_move; RSI->pondermove = 0;
      return;
    }
  }
  if(pos->side == WHITE) { time = wtime; inc = winc; }
  else { time = btime; inc = binc; }

  // If a node, depth or time limit is given, but no time, use infinite time: 
  if(time == 0 && inc == 0 && (depth_limit || node_limit || exact_time)) 
    inf = true;

  if(!movestogo) { // Sudden death time control 
    if(inc) {
      RSI->max_time = time / 30 + inc;
      RSI->absolute_max_time = Max(time / 4, inc - 100);
    } else {
      RSI->max_time = time / 40;
      RSI->absolute_max_time = time / 8;
    }
  } else { // x moves/y minutes 
    if(movestogo == 1) {
      RSI->max_time = time / 2;
      RSI->absolute_max_time = Min(time / 2, time - 500);
    } else {
      RSI->max_time = time / Min(movestogo, 20);
      RSI->absolute_max_time = Min((4 * time) / movestogo, time / 3);
    }
  }
  if(Options->ponder) {
    RSI->max_time += RSI->max_time / 4;
    if(RSI->max_time > RSI->absolute_max_time)
      RSI->max_time = RSI->absolute_max_time;
  }
  RSI->infinite = inf;
  RSI->depth_limit = depth_limit;
  RSI->node_limit = node_limit;
  RSI->exact_time = exact_time;
  RSI->thinking_status = ponder? PONDERING : THINKING;
  RSI->nodes_between_polls = RSI->node_limit ?
    Min(RSI->node_limit, 20000) : 20000;

//   if(!inf && !ponder && !node_limit && !depth_limit && !exact_time &&
//      Options->learning) {
//     move_t lmove, lpmove;
//     if(get_learning_data_at_root(pos->key, RSI->absolute_max_time,
//                                  &lmove, &lpmove)) {
//       RSI->bestmove = lmove; RSI->pondermove = lpmove;
//       return;
//     }
//   }
  root_search(pos, moves);
  if(EngineShouldQuit) quit();
}
