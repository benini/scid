#include "viper.h"

static void init_engine_options(int side) {
  Options->pp_weight = 
    (get_option_value_int("Passed pawns (middle game)") * 128) / 100;
  Options->e_pp_weight = 
    (get_option_value_int("Passed pawns (endgame)") * 128) / 100;
  Options->ps_weight = (get_option_value_int("Pawn structure") * 128) / 100;
  Options->mob_weight = 
    (get_option_value_int("Mobility (middle game)") * 128) / 100;
  Options->e_mob_weight = 
    (get_option_value_int("Mobility (endgame)") * 128) / 100;
  Options->development_weight = 
    (get_option_value_int("Development") * 128) / 100;
  Options->ponder = get_option_value_bool("Ponder");
  Options->multipv = get_option_value_int("MultiPV");
  init_tt(get_option_value_int("Hash"));
  if(button_was_pushed("Clear Hash")) clear_tt();
}

void think(const position_t *pos, bool inf, int wtime, int btime, int winc, 
	   int binc, int movestogo, bool ponder, int depth_limit, 
	   int node_limit, int exact_time, move_t moves[]) {
  int time, inc;

  init_root_search_info();
  init_engine_options(pos->side);

  if(pos->side == WHITE) { time = wtime; inc = winc; }
  else { time = btime; inc = binc; }

  // If a node, depth or time limit is given, but no time, use infinite time: 
  if(time == 0 && inc == 0 && (depth_limit || node_limit || exact_time)) 
    inf = true;

  if(!movestogo) { // Sudden death time control 
    if(inc) {
      RSI->max_time = time / 30 + inc;
      RSI->absolute_max_time = max(time / 4, inc - 100);
    } else {
      RSI->max_time = time / 40;
      RSI->absolute_max_time = time / 8;
    }
  } else { // x moves/y minutes 
    if(movestogo == 1) {
      RSI->max_time = time / 2;
      RSI->absolute_max_time = min(time / 2, time - 500);
    } else {
      RSI->max_time = time / min(movestogo, 20);
      RSI->absolute_max_time = min((4 * time) / movestogo, time / 3);
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
    min(RSI->node_limit, 20000) : 20000;

  root_search(pos, moves);
  if(EngineShouldQuit) quit();
}

