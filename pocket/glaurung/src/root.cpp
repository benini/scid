#include "glaurung.h"

static void add_root_move(position_t *pos, search_stack_t *sstack,
                          move_t move, root_move_list_t *list) {
  undo_info_t u[1];
  if(move_is_legal(pos, move)) {
    list->moves[list->num].move = move;
    list->moves[list->num].nodes = 0;
    list->moves[list->num].cumulative_nodes = 0;
    sstack[0].move = move;
    sstack[1].evaluated = 0;
    make_move(pos, move, u);
    list->moves[list->num].depth_1_score = 
      -qsearch(pos, sstack, 1, -MATE_VALUE-1, MATE_VALUE+1, 0, 0, 0, 0);
    list->moves[list->num].score = -MATE_VALUE-1;
    unmake_move(pos, move, u);
    list->num++;
  }
}

static move_t scan_for_easy_move(root_move_list_t *list) {
  int best_move_score = list->moves[0].depth_1_score, i;
  for(i = 1; i < list->num; i++)
    if(list->moves[i].depth_1_score >= best_move_score - P_VALUE) return 0;
  return list->moves[0].move;
}

static int CDECL key1(const void *a, const void *b) {
  if(((root_move_t*)a)->move == RSI->pv[0]) return -1;
  else if(((root_move_t*)b)->move == RSI->pv[0]) return 1;
  else if(((root_move_t*)a)->depth_1_score > ((root_move_t*)b)->depth_1_score)
    return -1; 
  else return 1;
}

static int CDECL key2(const void *a, const void *b) {
  if(((root_move_t*)a)->move == RSI->pv[0]) return -1;
  else if(((root_move_t*)b)->move == RSI->pv[0]) return 1;
  else if(((root_move_t*)a)->nodes > ((root_move_t*)b)->nodes)
    return -1; 
  else return 1;
}

static int CDECL key3(const void *a, const void *b) {
  if(((root_move_t*)a)->depth > ((root_move_t*)b)->depth &&
     ((root_move_t*)a)->score_type == EXACT) return -1;
  else if(((root_move_t*)b)->depth > ((root_move_t*)a)->depth &&
          ((root_move_t*)b)->score_type == EXACT) return 1;
  else if(((root_move_t*)a)->score > ((root_move_t*)b)->score) return -1;
  else if(((root_move_t*)b)->score > ((root_move_t*)a)->score) return 1;
  else if(((root_move_t*)a)->nodes > ((root_move_t*)b)->nodes) return -1; 
  else return 1;
}

static void sort_root_moves(root_move_list_t *list, int iteration) {
  if(iteration <= 2) 
    qsort(list->moves, list->num, sizeof(root_move_t), key1);
  else if(Options->multipv == 1 || list->num == 1)
    qsort(list->moves, list->num, sizeof(root_move_t), key2);
  else 
    qsort(list->moves, list->num, sizeof(root_move_t), key3);
  list->current = 0;
  RSI->pv[0] = list->moves[0].move; RSI->pv[1] = NOMOVE;
}

static move_t pick_root_move(root_move_list_t *list) {
  if(list->current == list->num) return 0;
  return list->moves[list->current++].move;
}

static void remember_node_count(uint64 nodes, root_move_list_t *list) {
  list->moves[list->current - 1].nodes = nodes;  
  list->moves[list->current - 1].cumulative_nodes += nodes;
}

static void update_root_pv(const move_t pv[]) {
  int i;
  for(i=0; pv[i] != NOMOVE; i++) RSI->pv[i] = pv[i];
  RSI->pv[i] = NOMOVE;
  RSI->bestmove = RSI->pv[0];
  RSI->pondermove = RSI->pv[1];
}

void init_root_search_info(void) {
  RSI->start_time = get_time();
  RSI->iteration = 1;
  RSI->easymove = 0;
  RSI->bestmove = 0;
  RSI->pondermove = 0;
  RSI->problem = 0;
  RSI->mate_found = 0;
  RSI->nodes = 0ULL;
  RSI->nodes_since_poll = 0;
  RSI->pv[0] = NOMOVE; RSI->pv[1] = NOMOVE;
  RSI->root_moves.num = 0;
}

static char Command[4096];

static void wait_for_stop_or_ponderhit(void) {
  if(fgets(Command, 4096, stdin) == NULL) strcpy(Command, "quit\n");
  if(strncasecmp(Command, "quit", 4) == 0) {
    RSI->thinking_status = ABORTED;
    EngineShouldQuit = true;
  }
}

int ValuesByIteration[MAX_DEPTH];

extern void init_move_stats(void);

void root_search(const position_t *pos, move_t searchmoves[]) {
  int value=0, lastvalue = -MATE_VALUE-1, bestvalue, alpha, beta;
  int depth, ext, i, index;
  uint64 nodes;
  position_t p[1];
  search_stack_t sstack[MAX_DEPTH];
  move_stack_t mstack[MOVE_STACK_SIZE];
  move_t move;
  int best_move_change_count[MAX_DEPTH];
  undo_info_t u[1];

#if defined(SMP)
  // SMP: Wake up sleeping threads:
  if(Options->threads > 1) {
#ifndef _MSC_VER
    pthread_mutex_lock(WaitLock);
    pthread_cond_broadcast(WaitCond);
    pthread_mutex_unlock(WaitLock);
#else
    for(i = 1; i < MaxNumOfThreads; i++) SetEvent(SitIdleEvent[i]);
#endif
  }
#endif // defined(SMP)

  tt_new_search();
  copy_position(p, pos);
  sstack[0].ms_ptr = mstack;
  for(i = 0; i < 4096; i++) History[0][i] = History[1][i] = 0;
  sstack[0].check = p->check;
  for(i = 0; i < MaxNumOfThreads; i++) Threads[i].stop = false;

  if(sstack->check) 
    (sstack+1)->ms_ptr = generate_check_evasions(p, sstack->ms_ptr); 
  else (sstack+1)->ms_ptr = generate_moves(p, sstack->ms_ptr);

  if(searchmoves[0] == 0) {
    move_stack_t *ms;
    for(ms = sstack[0].ms_ptr; ms < sstack[1].ms_ptr; ms++)
      add_root_move(p, sstack, ms->move, &(RSI->root_moves));
  }
  else 
    for(i = 0; searchmoves[i] != 0; i++) 
      add_root_move(p, sstack, searchmoves[i], &(RSI->root_moves));

  sstack[0].eval = evaluate(p, &(sstack[0].eval_vector), 0);
  init_move_stats();
  do {
    RSI->problem = 0;
    RSI->iteration++;
    if(RSI->iteration <= 60) best_move_change_count[RSI->iteration] = 0;
    if(RSI->iteration <= 5) RSI->extra_time = 0;
    if(RSI->iteration <= 60) send_msg("info depth %d\n", RSI->iteration);
    alpha = -MATE_VALUE-1; beta = MATE_VALUE+1;

    depth = RSI->iteration * PLY;
    init_node(p, sstack, 0, 0);

    bestvalue = -MATE_VALUE-1;
    sort_root_moves(&(RSI->root_moves), RSI->iteration);
    if(RSI->iteration == 2)
      RSI->easymove = scan_for_easy_move(&(RSI->root_moves));

    while((move = pick_root_move(&(RSI->root_moves)))) {
      if(RSI->iteration > 1 && RSI->iteration <= 60 &&
         get_time()-RSI->start_time > 1000) {
        send_msg("info currmove "); print_move(move);
        send_msg("currmovenumber %d\n", RSI->root_moves.current);
      }
      
      nodes = RSI->nodes;
      
      sstack[0].move = move; sstack[1].evaluated = 0;
      make_move(p, move, u);
      ext = extend(p, sstack, 0);
      
      if(RSI->root_moves.current <= Options->multipv) {
        RSI->fail_high = 0;
        alpha = -MATE_VALUE - 1;
        if(RSI->root_moves.current == 1) 
          value = -search(p, sstack, 1, -beta, -alpha, depth-PLY+ext, 1, 1, 0);
        else
          value = -search(p, sstack, 1, -beta, -alpha, depth-PLY+ext, 0, 1, 0);
        RSI->problem = (value <= lastvalue - 40);
      }
      else {
        RSI->fail_high = 0;
        value = -search(p, sstack, 1, -alpha-1, -alpha, depth-PLY+ext, 0, 1, 0);
        if(value > alpha && value < beta && 
           RSI->thinking_status != ABORTED) {
          RSI->fail_high = 1;
          value = -search(p, sstack, 1, -beta, -alpha, depth-PLY+ext, 0, 1, 0);
        }
      }
      unmake_move(p, move, u);
      if(RSI->iteration >= 5) check_for_input(); 
      remember_node_count(RSI->nodes-nodes, &(RSI->root_moves));
      
      if(RSI->thinking_status == ABORTED) break;
      index = RSI->root_moves.current - 1;
      
      RSI->root_moves.moves[index].pv[0] = move;
      for(i = 1; sstack[1].pv[i] != NOMOVE; i++)
        RSI->root_moves.moves[index].pv[i] = sstack[1].pv[i];
      RSI->root_moves.moves[index].pv[i] = NOMOVE;
      
      if(value <= alpha) {
        RSI->root_moves.moves[index].score = -MATE_VALUE - 1;
        RSI->root_moves.moves[index].score_type = UPPER_BOUND;
        RSI->root_moves.moves[index].depth = RSI->iteration;
      }
      else {
        RSI->root_moves.moves[index].score = value;
        RSI->root_moves.moves[index].score_type = EXACT;
        RSI->root_moves.moves[index].depth = RSI->iteration;
        alpha = value;
        
        if(value > bestvalue) {
          bestvalue = value;
          update_pv(sstack, 0); update_root_pv(sstack[0].pv);
          if(bestvalue > lastvalue - 20) RSI->problem = 0;
          if(RSI->root_moves.current > 1 && RSI->iteration <= 60)
            best_move_change_count[RSI->iteration]++;
        }
        if(Options->multipv == 1)
          print_pv(RSI->pv, RSI->iteration, value, 1);
        else {
          qsort(RSI->root_moves.moves, RSI->root_moves.num,
                sizeof(root_move_t), key3);
          print_multipv();
        }
      }
    }
    if(RSI->thinking_status == ABORTED) break;
    if(abs(bestvalue) >= MATE_VALUE - 200) RSI->mate_found++;

    // Stop searching when there is only a single legal move:
    if(RSI->iteration >= 5 && RSI->root_moves.num == 1 &&
       !RSI->infinite && RSI->thinking_status != PONDERING)
      break;

    // Stop searching when the last two iterations returned a mate score:
    if(RSI->iteration >= 3 && RSI->mate_found >= 2 && 
       !RSI->infinite && RSI->thinking_status != PONDERING)
        break;

    if(RSI->pv[0] != RSI->easymove) RSI->easymove = 0;

    // Stop search early if one move seems much better than the rest:
    if(RSI->iteration >= 5 && RSI->easymove &&
       ((RSI->root_moves.moves[0].cumulative_nodes > (RSI->nodes*85)/100 &&
         get_time() - RSI->start_time > RSI->max_time/16) ||
        (RSI->root_moves.moves[0].cumulative_nodes > (RSI->nodes*99)/100 && 
         get_time()-RSI->start_time > RSI->max_time/32)) &&
       !RSI->infinite && RSI->thinking_status!=PONDERING) {
      break;
    }

    // Add some extra time if the best move has changed during the last two
    // iterations:
    if(RSI->iteration > 5 && RSI->iteration <= 60)
      RSI->extra_time = 
        best_move_change_count[RSI->iteration] * (RSI->max_time / 3) +
        best_move_change_count[RSI->iteration-1] * (RSI->max_time / 6);
    else RSI->extra_time = 0;

    // Stop search if most of RSI->max_time is consumed at the end
    // of the iteration.  We probably don't have enough time to search the
    // first move at the next iteration anyway.
    if(get_time() - RSI->start_time > 
       ((RSI->max_time + RSI->extra_time) * 80)/128 &&
       !RSI->infinite && RSI->thinking_status!=PONDERING) {
      break;
    }

    // Stop searching if we have reached 60 plies:
    if(RSI->iteration == 60 && !RSI->infinite) {
      if(RSI->thinking_status == THINKING || RSI->thinking_status == PONDERHIT)
	break;
      else if(RSI->thinking_status == PONDERING) {
	wait_for_stop_or_ponderhit();
	break;
      }
    }
    
    lastvalue = bestvalue;
    if(RSI->iteration < MAX_DEPTH)
      ValuesByIteration[RSI->iteration] = bestvalue;
    if(RSI->iteration < MAX_DEPTH) RSI->bestvalues[RSI->iteration] = bestvalue;
    if(RSI->depth_limit && RSI->iteration >= RSI->depth_limit) break;
//     if(Options->learning)
//       store_learning_data(pos->key, RSI->bestmove, RSI->pondermove, 
//                           get_time() - RSI->start_time, RSI->iteration,
//                           bestvalue);
  } while(RSI->thinking_status != ABORTED);
}

void ponderhit(void) {
  int t;
  if(!RSI->infinite) {
    t = get_time() - RSI->start_time;
    if((RSI->iteration >= 2 && RSI->root_moves.num == 1) ||
       (RSI->mate_found >= 2) ||
       (t > RSI->absolute_max_time) ||
       (t > RSI->max_time + RSI->extra_time && 
        (RSI->root_moves.current == 1 || !RSI->problem)) ||
       (t > RSI->max_time/16 && RSI->iteration >= 5 &&
        RSI->easymove && 
        RSI->root_moves.moves[0].cumulative_nodes > (RSI->nodes*85)/100) ||
       (t > RSI->max_time/32 && RSI->iteration >= 5 &&
        RSI->easymove && 
        RSI->root_moves.moves[0].cumulative_nodes > (RSI->nodes*99)/100))
      RSI->thinking_status = ABORTED;
    else
      RSI->thinking_status = PONDERHIT;
  }
}
