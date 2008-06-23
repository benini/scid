#include "glaurung.h"

#define HINDEX2(pos, x) (COMPRESS(TO(x))|((pos->board[FROM(x)]-1)<<6))
#define HINDEX3(pos, x) (COMPRESS(TO(x))|((pos->board[TO(x)]-1)<<6))

struct move_stats_t {
  int success, failure;
};

static move_stats_t MoveStats[64*BK];

void init_move_stats(void) {
  memset(MoveStats, 0, 64*BK*sizeof(move_stats_t));
}

static void success(const position_t *pos, move_t m) {
  MoveStats[HINDEX2(pos, m)].success++;
}

static void failure(const position_t *pos, move_t m) {
  MoveStats[HINDEX2(pos, m)].failure++;
}

static int success_count(const position_t *pos, move_t m) {
  return MoveStats[HINDEX3(pos, m)].success;
}

static int failure_count(const position_t *pos, move_t m) {
  return MoveStats[HINDEX3(pos, m)].failure;
}

static void inc_history(search_stack_t *ss, int ply, move_t m, int side, 
                        int depth, int value) {
  if(!CAPTURE(m) && !PROMOTION(m)) {
    HISTORY(side, m) += depth;
    if(HISTORY(side, m) >= 89999997) {
      int i, j;
      for(i = 0; i < 2; i++)
        for(j = 0; j < 4096; j++)
          History[i][j] /= 2;
    }
    if(m != ss[ply].killer) {
      ss[ply].killer2 = ss[ply].killer; ss[ply].killer = m;
    }
  }
  if(value == MATE_VALUE-ply-1) ss[ply].mate_killer = m;
}

static void check_for_timeout(void) {
  int t;
  static int last_info_time;

  t = get_time() - RSI->start_time;
  if(t < 1000) last_info_time = 0;
  else if(t - last_info_time >= 1000) {
    mutex_lock(IOLock);
    send_msg("info nodes " llu_format " nps " llu_format " time %d hashfull %d\n",
           RSI->nodes, (RSI->nodes*1000ULL)/((uint64) t), t, hashfull());
    mutex_unlock(IOLock);
    last_info_time = t;
    if(Options->currline) Threads[0].print_currline = true;
  }
  if(RSI->thinking_status != PONDERING && RSI->iteration >= 2 &&
     ((!RSI->infinite && 
       (t > RSI->absolute_max_time
        || (RSI->root_moves.current == 1 && t > RSI->max_time+RSI->extra_time) 
        || (!RSI->fail_high && t > 6 * (RSI->max_time+RSI->extra_time)))) ||
      (RSI->node_limit && RSI->nodes >= RSI->node_limit) ||
      (RSI->exact_time && t >= RSI->exact_time)))
    RSI->thinking_status = ABORTED;
}
    
void init_node(const position_t *pos, search_stack_t *sstack, int ply,
               int thread_id) {
  search_stack_t *ss = sstack+ply;
  RSI->nodes++; RSI->nodes_since_poll++;
  Threads[thread_id].nodes++;
  if(Threads[thread_id].print_currline) print_currline(sstack, ply, thread_id);
  if(RSI->nodes_since_poll >= RSI->nodes_between_polls && thread_id == 0) {
    check_for_input();
    check_for_timeout();
    RSI->nodes_since_poll = 0;
  }

  ss->last_moved_piece_hanging = 0;
  ss->pv[ply] = ss->move = NOMOVE;
  if(!ss->evaluated) {
    ss->eval_vector.king_safety[0] = ss->eval_vector.king_safety[1] = 0;
    ss->eval_vector.passed_pawns[0] = ss->eval_vector.passed_pawns[1] = 0;
  }
  ss->reduction = 0;
  (ss+1)->pv[ply+1] = NOMOVE;
  (ss+2)->killer = (ss+2)->killer2 = (ss+2)->mate_killer = NOMOVE;
  ss->check = pos->check;
}

void update_pv(search_stack_t *sstack, int ply) {
  search_stack_t *ss = sstack+ply;
  int i;
  ss->pv[ply] = ss->move;
  for(i=ply+1; (ss+1)->pv[i] != NOMOVE; i++) ss->pv[i] = (ss+1)->pv[i];
  ss->pv[i] = NOMOVE;
}

static bool ok_to_reduce(const position_t *pos, const search_stack_t *ss, 
                         bool pvnode, move_t m) {
  if(Options->lmr == DISABLED) return false;
  if(Options->lmr == NON_PV_NODES && pvnode) return false;
  if(PROMOTION(m) || CAPTURE(m)) return false;
  if(PIECE(m) == PAWN && pawn_is_passed(pos, TO(m), pos->xside)) return false;
  switch(Options->lmr_criterion) {
  case LMR_HISTORY:
    if(success_count(pos, m) > 2*failure_count(pos, m)) return false;
    else return true;
  case LMR_KNOWLEDGE_AND_HISTORY:
    if(success_count(pos, m) > 4*failure_count(pos, m)) return false;
    else return true;
  default: return true;
  }
}

static bool ok_to_cut(const position_t *pos, const search_stack_t *ss, 
                      move_t m) {
  if(Options->lmr == DISABLED) return false;
  if(PROMOTION(m) || CAPTURE(m)) return false;
  if(PIECE(m) == PAWN && pawn_is_passed(pos, TO(m), pos->side)) return false;
  if(4*MoveStats[HINDEX2(pos, m)].success>=MoveStats[HINDEX2(pos, m)].failure)
    return false;
  return true;
}

static int static_nullmove_test(const position_t *pos, const search_stack_t *ss,
                                int ply, int depth, int beta, int ks_delta) {
  int margin;
  if(!Options->static_pruning) return 0;
  if(depth <= PLY) margin = 40;
  else margin = 40 + depth; 
  if(ss[ply].eval - beta - margin <= 0) return 0;
  if(depth <= Options->pruning_depth && ply >= 5 &&
     ks_delta > -50 && !ss[ply-1].extension && !ss[ply-2].extension &&
     !global_see(pos, pos->xside, ss[ply].eval - beta - margin))
    return 1;
  else return 0;
}

static int choose_R(const position_t *pos) {
  if(pos->material[WHITE] + pos->material[BLACK] - 
     (PawnCount(pos, WHITE) + PawnCount(pos, BLACK)) * P_VALUE 
     <= 4*R_VALUE)
    return Options->eg_r;
  else return Options->mg_r;
}

static bool connected_moves(const position_t *pos, move_t m1, move_t m2) {
  int f1, t1, f2, t2, p1;
  attack_data_t *a;

  if(m2 == NOMOVE) return false;

  // Case 1: Same piece
  f2 = FROM(m2); t1 = TO(m1);
  if(f2 == t1) return true;

  // Case 2: Destination square for m2 was vacated by m1:
  t2 = TO(m2); f1 = FROM(m1);
  if(t2 == f1) return true;

  // Case 3: Moving through the vacated square:
  if(PieceIsSlider(PIECE(m2))) {
    if(abs(AttackData[f1 - t2].step) == abs(AttackData[f2 - t2].step) &&
       (f1 - t2) * (f1 - f2) < 0) 
      return true;
  }

  // Case 4: Destination square for m2 attacked by moving piece in m1:
  p1 = pos->board[t1];
  a = AttackData - t2;
  if(a[t1].may_attack & PieceMask[p1]) {
    if(!PieceIsSlider(p1)) return true;
    else {
      int sq, step = a[t1].step, tmp = pos->board[f2];
      pos->board[f2] = EMPTY;
      for(sq = t1 + step; pos->board[sq] == EMPTY && sq != t2; sq += step);
      pos->board[f2] = tmp;
      if(sq == t2) return true;
    }
  }

  // Case 5: Discovered check, checking piece is the piece moved in m1:
  if(PieceIsSlider(p1)) {
    a = AttackData - KingSquare(pos, pos->side);
    if((a[t1].may_attack & PieceMask[p1]) &&
       a[f2].step == a[t1].step && a[t2].step != a[t1].step) {
      int sq, step = a[t1].step;
      for(sq = f2 + step; pos->board[sq] == EMPTY; sq += step);
      if(sq == KingSquare(pos, pos->side)) {
        for(sq = f2 - step; pos->board[sq] == EMPTY; sq -= step);
        if(sq == t1) return true;
      }
    }
  }
  return false;
}
    
static int QNodes[MaxNumOfThreads];

int search(position_t *pos, search_stack_t *sstack, int ply, 
           int alpha, int beta, int depth, int follow_pv, int nullmove,
           int thread_id) {
  int bestvalue, value, nullvalue, legal_moves=0, mate_threat=0, ext;
  int old_alpha = alpha, old_beta = beta;
  bool pvnode = (beta - alpha > 1);
  int king_safety_delta, pp_delta, king_safety_delta2, pp_delta2;
  bool use_futility;
  int futility_value;
  int futility_margin_1 = 2*P_VALUE, futility_margin_2 = 6*P_VALUE;
  int side = pos->side, xside = side^1;
  move_t move, pvmove, hashmove;
  move_t searched_moves[256];
  move_stack_t *ms;
  undo_info_t u[1];
  search_stack_t *ss = sstack+ply;

  ss->pv[ply] = NOMOVE;

  // Stop search if we have reached maximum depth, if this thread has been
  // asked to stop, or if alpha is a mate score big enough that we cannot
  // possibly achieve it:
  if(RSI->thinking_status == ABORTED || Threads[thread_id].stop) return 0;
  if(alpha > MATE_VALUE - ply - 1) return alpha;
  if(ply >= 60) return evaluate(pos, &(ss->eval_vector), thread_id);

  // If the remaining depth is less than one ply, call the quiescence search:
  if(depth < PLY) {
    QNodes[thread_id] = 0;
    return qsearch(pos, sstack, ply, alpha, beta, depth, follow_pv, ply,
                   thread_id);
  }
  if(draw(pos)) return DRAW_VALUE;

  // Probe the hash table:
  retrieve_tt(pos, &alpha, &beta, depth, &hashmove, &mate_threat, &nullmove);
  if(pvnode || ((ss-1)->reduction && alpha > old_alpha)) {
    alpha = old_alpha; beta = old_beta;
  }
  if(alpha >= beta) {
    ss->move = hashmove; return alpha;
  }
  if(follow_pv) pvmove = sstack[0].pv[ply]; else pvmove = NOMOVE;
  if(hashmove && pvmove == NOMOVE) pvmove = hashmove;

  init_node(pos, sstack, ply, thread_id);

  if(!ss->evaluated) {
    ss->eval = evaluate(pos, &(ss->eval_vector), thread_id); 
    ss->evaluated = true;
  }

  // Compare the king safety and passed pawn components of the static eval
  // to those of the parent node.  If the last move was reduced, but improved
  // one of these components sigificantly, we return alpha.  This will cause
  // the reduced move to be re-searched with full depth:
  king_safety_delta = 
    ss->eval_vector.king_safety[side] - (ss-1)->eval_vector.king_safety[side];
  king_safety_delta2 = 
    ss->eval_vector.king_safety[xside] - (ss-1)->eval_vector.king_safety[xside];
  pp_delta =
    ss->eval_vector.passed_pawns[xside] - 
    (ss-1)->eval_vector.passed_pawns[xside];
  pp_delta2 =
    ss->eval_vector.passed_pawns[side] - 
    (ss-1)->eval_vector.passed_pawns[side];

  if((ss-1)->reduction && (Options->lmr_criterion & LMR_KNOWLEDGE) &&
     (king_safety_delta <= -128 || pp_delta >= 64 ||
      king_safety_delta2 >= 128 || pp_delta2 <= -64))
    return alpha;

  // Look up the current position in the learning file:
//   if(Options->learning) {
//     move_t lmove, lpmove;
//     int lscore;
//     if(get_learning_data(pos->key, depth, ply, &lmove, &lpmove, &lscore)) {
//       ss->move = ss->pv[ply] = lmove; 
//       ss->pv[ply+1] = lpmove; ss->pv[ply+2] = NOMOVE;
//       return lscore;
//     }
//   }

  // Null move search:
  if(nullmove && !pos->check && !mate_threat && ss->eval >= beta &&
     pos->material[WHITE] > 0 && pos->material[BLACK] > 0 
     && !pawn_endgame(pos) && !(pos->piece_count[side][PAWN] == 0 &&
                                pos->material[side] <= R_VALUE)) {
    // Static null move pruning:
    if(!pvnode && 
       static_nullmove_test(pos, sstack, ply, depth, beta, king_safety_delta)) 
      return beta;
    else { // Dynamic null move pruning:
      int R = choose_R(pos);
      make_nullmove(pos, u); 
      ss->move = NULLMOVE;
      (ss+1)->ms_ptr = ss->ms_ptr; (ss+1)->evaluated = false;
      nullvalue = -search(pos, sstack, ply+1, -beta, -beta+1, 
                          depth-(R+1)*PLY, 0, 0, thread_id);
      unmake_nullmove(pos, u);
      if(nullvalue >= beta) {
        if(depth >= 7*PLY && pos->material[side] <= Q_VALUE + N_VALUE) {
          // Zugzwang verification search:
          int v = search(pos, sstack, ply, alpha, beta, depth - 6*PLY, 0, 0,
                         thread_id);
          if(v >= beta) return nullvalue;
        }
        else return nullvalue;
      }
      else {
        if(nullvalue <= -MATE_VALUE+ply+2) mate_threat = 1;
        ss->threat_move = (ss+1)->move;
        if((ss-1)->reduction && depth <= Options->threat_depth &&
           connected_moves(pos, (ss-1)->move, ss->threat_move))
          // The reduced move seem to contain some sort of serious threat.
          // We return alpha, which will cause the move to be re-searched
          // with full depth:
          return alpha;
      }
    }
  }

  // Internal iterative deepening:
  if(pvmove == NOMOVE && ((pvnode && depth > 3*PLY) ||
                          (depth > 6*PLY && ss->eval > alpha - 2*P_VALUE))) {
    value = search(pos, sstack, ply, alpha, beta, depth-2*PLY, 0, 0, thread_id);
    if(value >= Max(beta, MATE_VALUE-100)) return value;
    if(value < Min(alpha, -MATE_VALUE+100)) return value;
    pvmove = sstack[ply].pv[ply];
  }

  // Generate and order moves:
  if(pos->check) {
    (ss+1)->ms_ptr = generate_check_evasions(pos, ss->ms_ptr);
    ss->num_of_evasions = (ss+1)->ms_ptr - ss->ms_ptr;
    if(ss->num_of_evasions == 0) return -MATE_VALUE+ply;
  }
  else (ss+1)->ms_ptr = generate_moves(pos, ss->ms_ptr);
  order_moves(pos, sstack, ply, pvmove); ms = ss->ms_ptr;

  // If the last move was reduced, the moved piece is not hanging, and the
  // move improved the static eval to a value, return alpha.  This will cause
  // the move to be re-searched with full depth:
  if((Options->lmr_criterion & LMR_KNOWLEDGE) &&
     (ss-1)->reduction && !ss->last_moved_piece_hanging &&
     ss->eval <= alpha + P_VALUE && (ss->eval < -(ss-1)->eval))
    return alpha; 

  bestvalue = -MATE_VALUE-1;

  // Decide whether futility pruning should be used at this node, and choose
  // futility margins:
  if(depth <= 3*PLY && (Options->fpruning == ALL_NODES ||
                        (Options->fpruning == NON_PV_NODES && !pvnode)) &&
     !pos->check && ss->eval > -KNOWN_WIN && !PROMOTION(pos->last_move) &&
     !mate_threat) {
    use_futility = true;
    if(pos->material[WHITE] + pos->material[BLACK] > 2*Q_VALUE+2*N_VALUE) {
      futility_margin_1 = Options->fmargin_1; 
      futility_margin_2 = Options->fmargin_2; 
    } 
    else {
      futility_margin_1 = Options->fmargin_1 * 2;
      futility_margin_2 = Options->fmargin_2 * 2; 
    } 
  }
  else use_futility = false;

  // Loop through the move list and search each move:
  while(alpha < beta && !Threads[thread_id].stop &&
        (move = pick_move(&ms, (ss+1)->ms_ptr, legal_moves < 16))) {
    if(move_is_legal(pos, move)) {
      searched_moves[legal_moves] = move;
      legal_moves++;
      (ss+1)->threat_move = NOMOVE;
      
      // Futility pruning:
      if(use_futility && !move_is_check(pos, move) && 
         !(PIECE(move) == PAWN && PawnRank[pos->side][TO(move)] >= RANK_6)) {
        futility_value = ss->eval + approx_eval_delta(pos, move);
        if(depth < 3*PLY && futility_value < alpha - futility_margin_2)
          continue;
        if(depth < 2*PLY && futility_value < alpha - futility_margin_1) 
          continue;
        if(depth <= 3*PLY && legal_moves >= 2 && ok_to_cut(pos, sstack, move))
          continue;
      }

      ss->move = move;
      make_move(pos, move, u);
      (ss+1)->evaluated = false;
      ext = extend(pos, ss, mate_threat);

      if(legal_moves == 1) 
        value = -search(pos, sstack, ply+1, -beta, -alpha, depth-PLY+ext, 
                        follow_pv, 1, thread_id);
      else {
        if(!ext && legal_moves >= 4 && depth >= 2*PLY && 
           ok_to_reduce(pos, sstack, pvnode, move)) {
          // Search move with reduced depth:
          ss->reduction = 1;
          value = -search(pos, sstack, ply+1, -alpha-1, -alpha, depth-2*PLY, 
                          0, 1, thread_id);
          ss->reduction = 0;
        }
        else value = alpha+1; // HACK
        if(value > alpha) {
          // Search move with full depth:
          value = -search(pos, sstack, ply+1, -alpha-1, -alpha, depth-PLY+ext,
                          0, 1, thread_id);
          if(value > alpha && value < beta) 
            value = -search(pos, sstack, ply+1, -beta, -alpha, depth-PLY+ext,
                            0, 1, thread_id);
        }
      }
      unmake_move(pos, move, u);
      if(value > bestvalue) {
        bestvalue = value;
        if(value > alpha) {
          alpha = value; update_pv(sstack, ply);
          if(value >= beta) inc_history(sstack, ply, move, side, depth, value);
        }
      }
    }
    
#if defined(SMP)
    // SMP: Use the "Young Brothers Wait" algorithm. If the first move has 
    // been searched and some other thread is idle, search the remaining
    // moves in parallel:
    if(Options->threads > 1 && legal_moves >= 1 && alpha < beta &&
       depth >= Options->split_depth*PLY && !mate_threat && 
       RSI->iteration <= 60 && idle_thread_exists(thread_id) &&
       split(pos, sstack, ply, &alpha, &beta, pvnode, &bestvalue, depth, 
             &legal_moves, ms, (ss+1)->ms_ptr, thread_id))
      break;
#endif
  }
  if(legal_moves == 0) return DRAW_VALUE;  // Stalemate.

  if(RSI->thinking_status == ABORTED || Threads[thread_id].stop) return 0;

  // Store search information to the transposition table, and update search
  // statistics for the moves searched:
  if(bestvalue >= beta) {
    store_tt(pos, bestvalue, depth, ss->pv[ply], LOWER_BOUND, mate_threat);
    if(!CAPTURE(ss->pv[ply]) && !PROMOTION(ss->pv[ply])) {
      // Update move statistics for all searched moves:
      int i;
      success(pos, ss->pv[ply]);
      for(i = 0; i < legal_moves - 1; i++)
        if(!CAPTURE(searched_moves[i]) && !PROMOTION(searched_moves[i]))
          failure(pos, searched_moves[i]);
    }
  }
  else if(alpha == old_alpha) 
    store_tt(pos, bestvalue, depth, 0, UPPER_BOUND, mate_threat);
  else 
    store_tt(pos, bestvalue, depth, ss->pv[ply], EXACT, mate_threat);

  return alpha;
}

int qsearch(position_t *pos, search_stack_t *sstack, int ply, 
            int alpha, int beta, int depth, int follow_pv, int check_depth,
            int thread_id) {
  int bestvalue, value, moves=0, mate_threat=0, nullmove;
  int old_alpha = alpha, old_beta = beta;
  bool pvnode = (beta - alpha > 1);
  bool search_checks;
  bool use_futility;
  int futility_margin = 100;
  move_t move, pvmove, hashmove = 0;
  move_stack_t *ms;
  undo_info_t u[1];
  search_stack_t *ss = sstack+ply;

  ss->pv[ply] = NOMOVE;

  // Stop search if we have reached maximum depth, if this thread has been
  // asked to stop, or if alpha is a mate score big enough that we cannot
  // possibly achieve it:
  if(RSI->thinking_status == ABORTED || Threads[thread_id].stop) return 0;
  if(alpha > MATE_VALUE - ply - 1) return alpha;
  if(ply >= 60) return evaluate(pos, &(ss->eval_vector), thread_id);
  if(draw(pos)) return DRAW_VALUE;

  // QNodes[thread_id] is initialised to 0 every time the main search calls
  // the quiescence search, and is incremented once for each qsearch node.
  // The purpose is to avoid qsearch explosions: When QNodes[thread_id] grows
  // too big, we stop searching non-capturing checks.
  QNodes[thread_id]++;

  // Should we search checks at this node?
  if(ply <= check_depth && QNodes[thread_id] < 400 && 
     depth > -Options->qs_checks * PLY && alpha < 2*N_VALUE)
    search_checks = true;
  else
    search_checks = false;

  // If this is a "search checks node", probe the hash table:
  if(search_checks && Options->hash_qsearch) {
    retrieve_tt(pos, &alpha, &beta, 0, &hashmove, &mate_threat, &nullmove);
    if(pvnode) {
      alpha = old_alpha; beta = old_beta;
    }
    if(alpha >= beta) {
      ss->move = hashmove; return alpha;
    }
  }

  if(follow_pv) pvmove = sstack[0].pv[ply]; else pvmove = NOMOVE;
  if(hashmove && pvmove == NOMOVE) pvmove = hashmove;

  init_node(pos, sstack, ply, thread_id);

  if(!ss->evaluated) {
    ss->eval = evaluate(pos, &(ss->eval_vector), thread_id); 
    ss->evaluated = true;
  }

  // Generate and order moves.  Note that we increase check_depth by 2 plies
  // when we are in check and there is only a single legal move.
  if(pos->check) {
    (ss+1)->ms_ptr = generate_check_evasions(pos, ss->ms_ptr);
    ss->num_of_evasions = (ss+1)->ms_ptr - ss->ms_ptr;
    if(ss->num_of_evasions == 0) return -MATE_VALUE+ply; 
    if(ss->num_of_evasions == 1) check_depth += 2;
    bestvalue = -MATE_VALUE-1;  // "Stand pat" score
  }
  else {
    if(ss->eval >= beta) return ss->eval;
    if(ss->eval > alpha) alpha = ss->eval;
    (ss+1)->ms_ptr = generate_captures(pos, ss->ms_ptr);
    bestvalue = ss->eval;  // "Stand pat" score
  }
  order_qmoves(pos, sstack, ply, pvmove); ms = ss->ms_ptr;

  // Decide whether futility pruning should be used at this node, and choose
  // futility margin:
  if((Options->fpruning == ALL_NODES ||
      (Options->fpruning == NON_PV_NODES && !pvnode)) &&
     ss->eval > -KNOWN_WIN && !PROMOTION(pos->last_move) && 
     pos->material[pos->side]) {
    use_futility = true;
    if(pos->material[WHITE] + pos->material[BLACK] > 2*Q_VALUE + 2*N_VALUE)
      futility_margin = Options->fmargin_0; 
    else if(pos->material[WHITE] <= P_VALUE || pos->material[BLACK] <= P_VALUE)
      futility_margin = Q_VALUE;
    else
      futility_margin = Options->fmargin_0 * 2;
  }
  else use_futility = false;

  // Loop through the move list and search each move:
  while(alpha < beta && !Threads[thread_id].stop &&
        (move = pick_move(&ms, (ss+1)->ms_ptr, moves < 4))) {

    // Futility pruning:
    if(use_futility) {
      int futility_value = ss->eval + approx_eval_delta(pos, move);
      if(futility_value < alpha - futility_margin && !PROMOTION(move) &&
         (!search_checks || alpha >= 2*N_VALUE || !move_is_check(pos, move)))
        continue;
    }
    if(move_is_legal(pos, move)) {
      // Prune losing captures:
      if(!pos->check && PieceValues[PIECE(move)] > PieceValues[CAPTURE(move)] 
         && see(pos, FROM(move), TO(move)) < 0) 
        continue;

      // Search the move:
      moves++;
      ss->move = move;
      make_move(pos, move, u);
      (ss+1)->evaluated = false;
      value = -qsearch(pos, sstack, ply+1, -beta, -alpha, depth-PLY, 
                       (moves==1)? follow_pv : 0, check_depth, thread_id);
      unmake_move(pos, move, u);
      if(value > bestvalue) {
        bestvalue = value;
        if(value > alpha) {
          alpha = value; update_pv(sstack, ply);
        }
      }
    }
  }
  // All captures and queen promotions are searched.  Search checks if
  // necessary:
  if(search_checks && alpha < 2*N_VALUE && alpha < beta && !(pos->check)) {
    // Generate and order non-capturing checking moves:
    (ss+1)->ms_ptr = generate_checks(pos, ss->ms_ptr);
    order_moves(pos, sstack, ply, pvmove); ms = ss->ms_ptr;
    moves = 0;

    // Loop through the move list and search each move:
    while(alpha < beta && !Threads[thread_id].stop &&
          (move = pick_move(&ms, (ss+1)->ms_ptr, moves < 4))) {
      if(move_is_legal(pos, move) && see(pos, FROM(move), TO(move)) == 0) {
        moves++;
        ss->move = move;
        make_move(pos, move, u);
        (ss+1)->evaluated = false;
        value = -qsearch(pos, sstack, ply+1, -beta, -alpha, depth-PLY, 
                         (moves==1)? follow_pv : 0, check_depth, thread_id);
        unmake_move(pos, move, u);
        if(value > bestvalue) {
          bestvalue = value;
          if(value > alpha) {
            alpha = value; update_pv(sstack, ply);
          }
        }
      }
    }
  }
 
  if(RSI->thinking_status == ABORTED || Threads[thread_id].stop) return 0;

  // If this is a "search checks node", store information to the transposition
  // table:
  if(search_checks && Options->hash_qsearch) {
    if(bestvalue >= beta) 
      store_tt(pos, bestvalue, 0, ss->pv[ply], LOWER_BOUND, 0);
    else if(alpha == old_alpha) 
      store_tt(pos, bestvalue, 0, 0, UPPER_BOUND, 0);
    else store_tt(pos, bestvalue, 0, ss->pv[ply], EXACT, 0);
  }

  return alpha;
}


#if defined(SMP)

//// smp_update_pv() is used to update the PV at split points.  This is
//// slightly different from the normal update_pv() function, because we
//// also need to update the PV in the search stack of the parent node.
static void smp_update_pv(search_stack_t *psstack, search_stack_t *sstack,
                          int ply) {
  search_stack_t *ss = sstack+ply, *pss = psstack+ply;
  int i;
  ss->pv[ply] = pss->pv[ply] = ss->move;
  for(i=ply+1; (ss+1)->pv[i] != NOMOVE; i++) 
    ss->pv[i] = pss->pv[i] = (ss+1)->pv[i];
  ss->pv[i] = pss->pv[i] = NOMOVE;
}

//// smp_pick_move() replaces the normal pick_move() at split points.  It
//// uses a MUTEX lock to ensure that two threads do not pick the same move. 
static move_t smp_pick_move(split_point_t *sp) {
  move_t m;
  mutex_lock(sp->lock);
  m = pick_move(&(sp->current), sp->end, sp->moves < 16);
  mutex_unlock(sp->lock);
  return m;
}

//// smp_search() is used to start a search from a split point.  This function 
//// is called by each thread working at the split point.  It is similar to 
//// the normal search() function, but simpler.  Because we have already probed
//// the hash table, done a null move search, and searched the first move before
//// splitting, we don't have to repeat all this work in smp_search().  We also
//// don't need to store anything to the hash table here; this is take care of
//// after we return from the split point.  
void smp_search(split_point_t *sp, int thread_id) {
  position_t *pos = sp->pos + thread_id;
  search_stack_t *sstack = sp->sstack[thread_id];
  int ply = sp->ply, depth = sp->depth, value, ext, side = pos->side, moves, i;
  search_stack_t *ss = sstack + ply;
  move_t move;
  undo_info_t u[1];
  move_stack_t *mstack = sp->mstack[thread_id];

  (ss+1)->ms_ptr = mstack;
  while(sp->alpha < sp->beta && !Threads[thread_id].stop &&
        (move = smp_pick_move(sp))) {
    if(move_is_legal(pos, move)) {
      mutex_lock(sp->lock);
      sp->moves++; moves = sp->moves;
      mutex_unlock(sp->lock);
      ss->move = move;
      make_move(pos, move, u);
      (ss+1)->evaluated = false;
      ext = extend(pos, ss, false);
      if(ext == 0 && moves >= 4 && 
         ok_to_reduce(pos, sstack, sp->pvnode, move)) {
        ss->reduction = 1;
        value = -search(pos, sstack, ply+1, -(sp->alpha + 1), -sp->alpha,
                        depth - 2*PLY, 0, 1, thread_id);
        ss->reduction = 0;
      }
      else value = sp->alpha + 1;
      if(value > sp->alpha) {
        value = -search(pos, sstack, ply+1, -(sp->alpha + 1), -sp->alpha, 
                        depth-PLY+ext, 0, 1, thread_id);
        if(value > sp->alpha && value < sp->beta) 
          value = -search(pos, sstack, ply+1, -sp->beta, -sp->alpha, 
                          depth-PLY+ext, 0, 1, thread_id);
      }
      unmake_move(pos, move, u);

      if(Threads[thread_id].stop) break;
      mutex_lock(sp->lock);
      if(value > sp->bestvalue && !Threads[thread_id].stop) {
        sp->bestvalue = value;
        if(value > sp->alpha) {
          sp->alpha = value; smp_update_pv(sp->parent_sstack, sstack, ply);
          if(value >= sp->beta) {
            inc_history(sp->parent_sstack, ply, move, side, depth, value);
            for(i = 0; i < Options->threads; i++)
              if(i != thread_id && (i == sp->master || sp->slaves[i]))
                Threads[i].stop = true;
          }
        }
      }
      mutex_unlock(sp->lock);
    }
  }
  mutex_lock(sp->lock);

  // If this is the master thread and we have been asked to stop because of
  // a beta cutoff higher up in the tree, stop all slave threads:
  if(sp->master == thread_id && Threads[thread_id].stop)
    for(i = 0; i < Options->threads; i++)
      if(sp->slaves[i]) Threads[i].stop = true;

  sp->cpus--;
  sp->slaves[thread_id] = 0;

  mutex_unlock(sp->lock);
}

#endif // defined(SMP)
