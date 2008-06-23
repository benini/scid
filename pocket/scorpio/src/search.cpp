#include "scorpio.h"

#define UNITDEPTH         8
#define NULL_RED         32
#define CHECK_DEPTH       8
#define DEPTH(x) (((x) / UNITDEPTH) + (((x) % UNITDEPTH) >= (UNITDEPTH >> 1)))

#define WINDOW    50
#define ZERO_WND   1
#define FULL_WND   2
#define IID_SRH    4
#define IID_ZERO   5  //iid | zero
#define IID_FULL   6  //iid | full
#define NULL_MOVE  8
#define WND_MASK   0xfffffffc  //search window mask

FORCEINLINE void SEARCHER::UPDATE_PV(MOVE move)  {
	pstack->pv[ply] = move; 
	memcpy(&pstack->pv[ply + 1] , &(pstack + 1)->pv[ply + 1] , ((pstack + 1)->pv_length - ply) * sizeof(MOVE));
	pstack->pv_length = (pstack + 1)->pv_length;
}; 

bool SEARCHER::hash_cutoff() {
	/*
    hashtable lookup
    */
	register int score;
	pstack->hash_flags = probe_hash(player,hash_key,DEPTH(pstack->depth),ply,score,
		pstack->hash_move,pstack->alpha,pstack->beta,pstack->mate_threat,dummy);
	if(pstack->hash_move && !is_legal_fast(pstack->hash_move))
		pstack->hash_move = 0;
	if(pstack->hash_flags >= EXACT) {
		if(pstack->hash_move) {
			pstack->pv_length = ply + 1;
			pstack->pv[ply] = pstack->hash_move;
		}
		pstack->best_move = pstack->hash_move;
		pstack->best_score = score;
		return true;
	}
	return false;
}

bool SEARCHER::bitbase_cutoff() {
	/*
	Cutoff tree only if we 'think' progress is being made
	   . after captures
	   . after pawn moves
	   . or just after a certain ply (probe_depth) 
	*/
	if( egbb_is_loaded
		&& all_man_c <= 5
		&& (ply >= probe_depth
		    || is_cap_prom((pstack - 1)->current_move)
			|| PIECE(m_piece((pstack - 1)->current_move)) == pawn)
		) {

		/*first check hashtable*/
		if(hash_cutoff())
			return true;

		/*
		Probe bitbases at leafs only if they are loaded in RAM
		*/
		register int score;
		if((ply <= probe_depth 
			|| (egbb_load_type >= 1 && all_man_c <= 4)
			|| egbb_load_type == 3)
			&& probe_bitbases(score)
			) {

            egbb_probes++;

			/*prefer wins near root*/
			if(score > 0)
				score -= WIN_PLY * (ply + 1);
			else if(score < 0)
				score += WIN_PLY * (ply + 1);

			pstack->best_score = score;

			/*record the score in hash tables now*/
			record_hash(player,hash_key,MAX_PLY,
				ply,EXACT,pstack->best_score,0,0);
            
			return true;
		}
	}
    /*
	no cutoff
	*/
	return false;
}

FORCEINLINE int SEARCHER::on_node_entry() {

    /*decide search checks depth & whether to use lazy eval*/
	if(pstack->depth <= 0) {
		if((pstack - 1)->search_state == NULL_MOVE) {
			pstack->qcheck_depth = 2 * CHECK_DEPTH;	
			pstack->use_lazy = true;
		} else {
			pstack->qcheck_depth = CHECK_DEPTH;	
			pstack->use_lazy = false;
		}
		qsearch();
		return true;
	}

	/*initialize node*/
	nodes++;

	pstack->gen_status = GEN_START;
	pstack->flag = UPPER;
	pstack->pv_length = ply;
	pstack->legal_moves = 0;
	pstack->hash_move = 0;
	pstack->best_score = -MAX_SCORE;
	pstack->best_move = 0;
	pstack->mate_threat = 0;
	pstack->evalrec.indicator = AVOID_LAZY;

	if(pstack->node_type == PV_NODE) {
		pstack->next_node_type = PV_NODE;
	} else if(pstack->node_type == ALL_NODE) {
		pstack->next_node_type = CUT_NODE;
	} else {
		pstack->next_node_type = ALL_NODE;
	}

    if(pstack->alpha > MATE_SCORE - WIN_PLY * (ply)) {
		pstack->best_score = pstack->alpha;
		return true; 
	}

	if(draw()) {
        pstack->best_score = 0;
		return true;
	}

	if(ply >= MAX_PLY - 1) {
		pstack->best_score = eval();
		return true;
	}

	/*check input and time*/
	if(processor_id == 0) {
		if(nodes > time_check) {
			time_check += poll_nodes;
			if(!abort_search)
				check_quit();
			if(abort_search) {
				return true;
			}
		}
	}

	/*bitbase cutoff*/
	if(bitbase_cutoff())
		return true;

	/*probe hash table*/
	if(!(egbb_is_loaded && all_man_c <= 5) && hash_cutoff())
		return true;

	return false;
}

FORCEINLINE int SEARCHER::on_qnode_entry() {
    int score;

	/*initialize node*/
	pstack->gen_status = GEN_START;
	pstack->pv_length = ply;
	pstack->best_score = -MAX_SCORE;
	pstack->best_move = 0;
	pstack->legal_moves = 0;
	pstack->evalrec.indicator = AVOID_LAZY;

	nodes++;
	qnodes++;

	if(pstack->alpha > MATE_SCORE - WIN_PLY * ply) {
		pstack->best_score = pstack->alpha;
		return true; 
	}

	if(draw()) {
		pstack->best_score = 0;
		return true;
	}

	if(ply >= MAX_PLY - 1) {
		pstack->best_score = eval();
		return true;
	}

	/*bitbase cutoff*/
	if(bitbase_cutoff())
		return true;
	
	/*stand pat*/
	if(!hstack[hply - 1].checks) {
		if(pstack->use_lazy)
			score = eval(DO_LAZY);
		else
			score = eval(TRY_LAZY);
		
		pstack->best_score = score;
		if(score > pstack->alpha) {
			if(score >= pstack->beta)
				return true;
			pstack->alpha = score;
		}

		/*check depth extension*/
		if(ply <= 2 * search_depth
			&& pstack->alpha <= 300
			&& pstack->qcheck_depth <= 0
			) {
			if(player == white) {
				if(pstack->evalrec.indicator & BAD_BKING) {
					pstack->qcheck_depth += UNITDEPTH;
				}
			} else {
				if(pstack->evalrec.indicator & BAD_WKING) {
					pstack->qcheck_depth += UNITDEPTH;
				}
			}
		}
		
	}

	return false;
}

/*passed pawn moves*/
int SEARCHER::is_passed(MOVE move) {
	int to = m_to(move),f = file(to),r = rank(to),sq;
	if(opponent == white) {
		if(r <= RANK4) return 0;
		if(r == RANK8) return 0;
		if(r == RANK7) return 2;
		for(sq = to + UU;sq < A8 + f;sq += UU) {
			if(board[sq] == bpawn || board[sq + RR] == bpawn || board[sq + LL] == bpawn)
				return 0;
		}
	} else {
		if(r >= RANK5) return 0;
		if(r == RANK1) return 0;
		if(r == RANK2) return 2;
		for(sq = to + DD;sq > A1 + f;sq += DD) {
			if(board[sq] == wpawn || board[sq + RR] == wpawn || board[sq + LL] == wpawn)
				return 0;
		}
	}
	return 1;
}

/*selective search*/
FORCEINLINE int SEARCHER::be_selective() {

	register MOVE move = (pstack - 1)->current_move; 
	register int extension = 0 , score;
	register int node_t = (pstack - 1)->node_type;

	pstack->extension = 0;
	pstack->reduction = 0;

	if(piece_c[white] + piece_c[black] <= 28) {
		personality = &phase_personality[2];
	} else if(castle) {
        personality = &phase_personality[0];
	} else {
        personality = &phase_personality[1];
	}

#define extend(ext) {									\
    if(pstack->depth <= 0)								\
		extension += max(personality->horizon_ext,ext); \
	else												\
		extension += ext;								\
	pstack->extension = 1;								\
};

	/*extend*/
	if(hstack[hply - 1].checks) {
		extend(personality->check_ext);
	}	
	
	if((pstack - 1)->count == 1 && hstack[hply - 2].checks) {
		extend(personality->one_reply_ext);
	}

	if(PIECE(m_piece(move)) == pawn 
		&& (score = is_passed(move))
		) {     
		if(score == 2 || node_t == PV_NODE) {
			extend(personality->pawn_push7_ext);
		} else {
			extend(0);
		}
	}

	if((pstack - 1)->mate_threat) {
		if(plist[COMBINE(player,queen)] || PIECE(m_capture(move)) == queen) {
			if(node_t == PV_NODE || pstack->depth <= NULL_RED) {
				extend(personality->mate_threat_ext);
			} else if(pstack->depth <= 7 * UNITDEPTH) {
				extend(personality->mate_threat_ext * 2 / 3);
			} else {
				extend(personality->mate_threat_ext / 3);
			}
		} else {
			extend(0);
		}
	}

	if(m_capture(move)
		&& m_to(move) == m_to(hstack[hply - 2].move)
		&& (node_t == PV_NODE || (piece_cv[m_capture(move)] == piece_cv[m_capture(hstack[hply - 2].move)]
		&& (pstack - 1)->score_st[(pstack - 1)->current_index - 1] > 0))) {
		if(node_t == PV_NODE) {
			extend(personality->re_capture_ext);
		} else if(pstack->depth <= (search_depth * UNITDEPTH) / 2) {
			extend(personality->re_capture_ext * 2 / 3);
		} else {
			extend(personality->re_capture_ext / 3);
		}
	}
		
	if(extension > UNITDEPTH)
		extension = UNITDEPTH;
	
	pstack->depth += extension; 

	/*reduce*/
	if(pstack->depth > UNITDEPTH 
		&& node_t != PV_NODE
		&& !pstack->extension
		&& (pstack - 1)->gen_status - 1 == GEN_NONCAPS
		&& (pstack - 1)->legal_moves > 3
		&& all_man_c > 5
		) {
	
		pstack->depth -= UNITDEPTH;
		pstack->reduction = 1;
		
		if(pstack->depth > 3 * UNITDEPTH
			&& !(pstack - 1)->reduction
			&& !(pstack - 1)->extension
			&& (pstack - 1)->legal_moves > 10
			) {
			pstack->depth -= UNITDEPTH;
			pstack->reduction = 2;
		}
	}
	
	/*futility pruning*/
	if(pstack->depth <= UNITDEPTH
		&& pstack->depth > 0
		&& !hstack[hply - 2].checks
		&& !is_cap_prom(move)
		&& !pstack->extension
		&& all_man_c > 5
		) {

		score = -eval(TRY_LAZY);

		if(score + personality->futl_margin  < (pstack - 1)->alpha ) {
			if(score > (pstack - 1)->best_score) {
				(pstack - 1)->best_score = score;
				(pstack - 1)->best_move = move;
			}
			return true;
		}
	}
    
	return false;
}

#define GOBACK(save) {\
    if(save) {\
       record_hash(player,hash_key,DEPTH(pstack->depth),ply,pstack->flag,\
            pstack->best_score,pstack->best_move,pstack->mate_threat);\
	}\
    if((pstack->search_state & WND_MASK) == IID_SRH) {\
	    pstack->search_state = IID_SRH;\
	    goto FINISH;\
	}\
    goto POP;\
};

void SEARCHER::search() {

	register MOVE move;
    register int score,stop_ply = ply,iid_depth;

	goto NEW_NODE;

	/*
	iterative DFS
	*/
	while(true) {
	    /*
	    GO forward pushing moves until tip of tree is reached
		*/
		while(true) {
            /*
			decide what to do according to search state
			*/
			switch(pstack->search_state) {
			case NULL_MOVE:
				if(	!hstack[hply - 1].checks
					&& !pstack->mate_threat
					&& piece_c[player]
					&& pstack->hash_flags != AVOID_NULL
					&& all_man_c > 5
					) {

                    /*do eval here*/
					if(pstack->depth <= NULL_RED) {
						eval(TRY_LAZY);
					}

					PUSH_NULL();
					
					pstack->extension = 0;
					pstack->reduction = 0;
					pstack->depth = (pstack - 1)->depth - NULL_RED;
					pstack->alpha = -(pstack - 1)->beta;
					pstack->beta = -(pstack - 1)->beta + 1;
					pstack->node_type = (pstack - 1)->next_node_type;
					pstack->search_state = FULL_WND;//on next ply,don't try NULL_MOVE or IID
					goto NEW_NODE;
				}
				pstack->search_state = IID_SRH;//try IID next
				continue;
			case IID_SRH:
                iid_depth = 2 * UNITDEPTH;
				if(!pstack->hash_move 
					&& pstack->depth > iid_depth
					) {
					pstack->o_alpha = pstack->alpha;
					pstack->o_beta = pstack->beta;
					pstack->o_depth = pstack->depth;
					pstack->depth -= iid_depth;
					pstack->search_state |= FULL_WND;//IID_FULL 
					continue;
				}
				pstack->search_state = FULL_WND;//FULL_WND
				continue;
			case IID_ZERO:
			case ZERO_WND:
			case IID_FULL:
			case FULL_WND:
                /*
				get a move and do search
				*/
				while(true) {

					/*get a move*/
					if(!get_move()) {
						if(!pstack->legal_moves) {
							if(hstack[hply - 1].checks) {
								pstack->best_score = -MATE_SCORE + WIN_PLY * (ply + 1);
							} else {
								pstack->best_score = 0;
							}
							pstack->flag = EXACT;
						}
						GOBACK(true);
					}

					pstack->legal_moves++;

					/*now make the move*/
					PUSH_MOVE(pstack->current_move);

		            /*set next ply's depth and be selective*/			
					pstack->depth = (pstack - 1)->depth - UNITDEPTH;
					if(be_selective()) {
						POP_MOVE();
						continue;
					}

                    /*next ply's window*/ 
					if((pstack - 1)->legal_moves == 1) {
						pstack->alpha = -(pstack-1)->beta;
						pstack->beta = -(pstack-1)->alpha;
						pstack->node_type = (pstack - 1)->next_node_type;
						(pstack-1)->search_state = ((pstack-1)->search_state & WND_MASK) | FULL_WND;
					} else {
						pstack->alpha = -(pstack-1)->alpha - 1;
						pstack->beta = -(pstack-1)->alpha;
						pstack->node_type = CUT_NODE;
						(pstack-1)->search_state = ((pstack-1)->search_state & WND_MASK) | ZERO_WND;
					}
					pstack->search_state = NULL_MOVE;
					goto NEW_NODE;
				}
				break;//switch
			}
			/*
			NEW node entrance point
			*/
NEW_NODE:
			if(on_node_entry())
				goto POP;//II
		}

		/*
		GO Back One Step: triggered by the following cases
		     I  - all moves are searched
			 II - node is in hash table , is a reptition draw etc..
			 III - fail high at node
			 IV - null move pruning

        In case of I and III , IID_SRH flag may be on
		*/

POP:

		if(stop_ply == ply)
			return;
		if(stop_searcher || abort_search)
			return;

		/*decide to go back one step OR research
		with a different window/depth*/

		score = -pstack->best_score;

        switch((pstack-1)->search_state) {
		case NULL_MOVE:
			POP_NULL();
			break;
		case IID_ZERO:
		case ZERO_WND:
			/*research with full window*/
			if(score > (pstack - 1)->alpha
				&& score < (pstack - 1)->beta
				) {
				pstack->alpha = -(pstack-1)->beta;
				pstack->beta = -(pstack-1)->alpha;
				pstack->node_type = (pstack - 1)->next_node_type;
				(pstack - 1)->search_state = ((pstack - 1)->search_state & WND_MASK) | FULL_WND;
				pstack->search_state = NULL_MOVE;
				goto NEW_NODE;
			}
		case IID_FULL:
		case FULL_WND:
			/*research with full depth*/
			if( pstack->reduction
				&& score >= (pstack - 1)->beta 
				) {
				pstack->alpha = -(pstack - 1)->beta;
				pstack->beta = -(pstack - 1)->alpha;
				pstack->node_type = (pstack - 1)->next_node_type;
				(pstack - 1)->search_state = ((pstack - 1)->search_state & WND_MASK) | FULL_WND;
                pstack->search_state = NULL_MOVE;
				pstack->depth += pstack->reduction * UNITDEPTH;
				pstack->reduction = 0;
				goto NEW_NODE;
			}
			
			POP_MOVE();
			break;
       	case IID_SRH:
        default:
			break;
		}

FINISH:

		/*
		@ this point move is taken back after researches,if any,are done.
		So we can update alpha now
		*/

		switch(pstack->search_state) {
		case NULL_MOVE:
			if(score >= pstack->beta) {
				pstack->best_score = score;
				pstack->best_move = 0;
				pstack->flag = LOWER;

				GOBACK(pstack->depth > NULL_RED);
			} else {
				if(score == -MATE_SCORE + WIN_PLY * (ply + 3))
					pstack->mate_threat = 1;
			}
			pstack->search_state = IID_SRH; //next is IID
			break;
        case IID_SRH:
			pstack->hash_move  = pstack->best_move;
			pstack->alpha = pstack->o_alpha;
			pstack->beta = pstack->o_beta;
			pstack->depth = pstack->o_depth;
			pstack->gen_status = GEN_START;
			pstack->flag = UPPER;
			pstack->legal_moves = 0;
			pstack->best_score = -MAX_SCORE;
			pstack->best_move = 0;
			pstack->pv_length = ply;
			pstack->search_state = FULL_WND;//next is FULL_WND
			break;
		case IID_ZERO:
		case ZERO_WND:
		case IID_FULL:
		case FULL_WND:
			move = pstack->current_move;
			if(score > pstack->best_score) {
				pstack->best_score = score;
				pstack->best_move = move;
			}
			if(score > pstack->alpha) {
				if(score >= pstack->beta) {
					
					pstack->flag = LOWER;

					if(!is_cap_prom(move)) {
						history[player][MV8866(move)]++;
						if(move != pstack->killer[0]) {
							pstack->killer[1] = pstack->killer[0];
							pstack->killer[0] = move;
						}
					}

					GOBACK(true);
				}
				pstack->alpha = score;
				pstack->flag = EXACT;
				UPDATE_PV(move);
			}
			/*
			PARALLEL search=> YBWC
			*/
#ifdef PARALLEL
				if(n_processors > 1
					&& pstack->depth > 2 * UNITDEPTH 
					) {
					
					register int i;
					
					/*
					attach idle processors to current processor
					*/
					l_lock(lock_smp);
					
					for(i = 0;i < n_processors;i++) {
						if(processors[i].state == WAIT) {
							attach_processor(i);
						}
					}
					
					if(n_workers) {
						
						attach_processor(processor_id);
						
						for(i = 0; i < n_processors; i++) {
							if(workers[i])
								processors[i].state = GO;
						}
					}
					
					l_unlock(lock_smp);
					
					/*
					send this processor to help workers
					*/
					if(workers[processor_id]) {

						splits++;

						processors[processor_id].process(this);
						
						GOBACK(true);
					}
				}
#endif
			break;
		}//switch
		
	}//while(1st)
}

/*
quiescent search
*/
void SEARCHER::qsearch() {

	register int score;
	register int stop_ply = ply;

	goto NEW_NODE_Q;

	while(true) {
		while(true) {

			/*get legal move*/
			if(!get_qmove()) {
				if(hstack[hply - 1].checks && pstack->legal_moves == 0) {
					pstack->best_score = -MATE_SCORE + WIN_PLY * (ply + 1);
				}
				goto POP_Q;
			}
			
			PUSH_MOVE(pstack->current_move);
								
            (pstack - 1)->legal_moves++;

            /*next ply's window and depth*/ 
			pstack->alpha = -(pstack - 1)->beta;
			pstack->beta = -(pstack - 1)->alpha;
			pstack->qcheck_depth = (pstack - 1)->qcheck_depth - UNITDEPTH;
			pstack->use_lazy = (pstack - 1)->use_lazy;
			
			/*check depth extension*/
			if(hstack[hply - 2].checks) {
				if((pstack - 1)->count == 1)
					pstack->qcheck_depth += 2 * UNITDEPTH;
				else if((pstack - 1)->count == 2)
					pstack->qcheck_depth += UNITDEPTH;
			}

NEW_NODE_Q:		
			/*
			NEW node entry point
			*/
			if(on_qnode_entry())
				goto POP_Q;

		}
POP_Q:
		if(stop_ply == ply)
			return;
		
		POP_MOVE();
		score = -(pstack + 1)->best_score;

		if(score > pstack->best_score) {
             pstack->best_score = score;
			 pstack->best_move = pstack->current_move;
		}
		if(score > pstack->alpha) {
			if(score >= pstack->beta)
				goto POP_Q;
			pstack->alpha = score;
			UPDATE_PV(pstack->current_move);
		}
	}
}

/*
parallel search
*/

#ifdef PARALLEL

void CDECL thread_proc(void* processor) {
	((PPROCESSOR)processor)->process();
}

void PROCESSOR::create() {
	pthread_t thread = 0;
	state = CREATE;
	searcher = NULL;
	t_create(thread_proc,this,thread);
	while(state == CREATE);
}

void PROCESSOR::process(PSEARCHER master) {
	while(true) {
		switch(state) {
		case CREATE:
            state = PARK;
		case PARK:
            while(state == PARK) t_sleep(1);
			break;
		case WAIT:
			if(!master) {
				while(state == WAIT);
			} else {
				while(state == WAIT) {
					if(!master->n_workers) {
						l_lock(lock_smp);
						if(state == WAIT) {
							searcher = master;
							state = GO;
							l_unlock(lock_smp);
							return;
						}
						l_unlock(lock_smp);
					}
				}
			}
			break;
		case GO: 
			searcher->search_parallel();
			searcher = NULL;
			state = WAIT;
			break;
		case DEAD:
			return;
		}
	}
}

#define SEARCH() {\
	(pstack - 1)->search_state = ((pstack - 1)->search_state & WND_MASK) | FULL_WND;\
	pstack->search_state = NULL_MOVE;\
	search();\
	if(stop_searcher || abort_search) break;\
    score = -pstack->best_score;\
};

#define UPDATE_BOUND(ps1,ps2) {\
	ps1->best_score = ps2->best_score;\
	ps1->best_move  = ps2->best_move;\
	ps1->flag       = ps2->flag;\
	ps1->alpha      = ps2->alpha;\
	ps1->beta       = ps2->beta;\
};

void SEARCHER::search_parallel() {
     
	register MOVE move;
	register int score;
	register int updated = false;

	pstack->pv_length = ply;

	while(true) {
		/*
		lock the master,and then get a legal move to search
		*/
		l_lock(master->lock);

		if(!(move = master->get_move())) {
			l_unlock(master->lock);
			break;
		}
		
		/*update  counts*/
		pstack->count = master->pstack->count;
		pstack->current_index = master->pstack->current_index;
		pstack->current_move = master->pstack->current_move;
		pstack->score_st[pstack->current_index - 1] = master->pstack->score_st[pstack->current_index - 1];
		pstack->gen_status = master->pstack->gen_status;
		pstack->legal_moves = ++master->pstack->legal_moves;

		/*synchronize bounds*/
		if(pstack->best_score > master->pstack->best_score) {
			updated = true;
			UPDATE_BOUND(master->pstack,pstack);
		} else if(pstack->best_score < master->pstack->best_score) {
			UPDATE_BOUND(pstack,master->pstack);
		}

		l_unlock(master->lock);
		/*
		make the move
		*/
		PUSH_MOVE(move);

		pstack->depth = (pstack - 1)->depth - UNITDEPTH;
		if(be_selective()) {
			POP_MOVE();
			continue;
		}
		/*
		search
		*/
		pstack->alpha = -(pstack-1)->alpha - 1;
		pstack->beta = -(pstack-1)->alpha;
		pstack->node_type = CUT_NODE;
		SEARCH();

		/*
		re-search
		*/
		if(score > (pstack - 1)->alpha
			&& score < (pstack - 1)->beta
			) {
			pstack->alpha = -(pstack - 1)->beta;
			pstack->beta = -(pstack - 1)->alpha;
			pstack->node_type = (pstack - 1)->next_node_type;
			SEARCH();
		}

		if(score >= (pstack - 1)->beta 
			&& pstack->reduction
			) {
			pstack->alpha = -(pstack - 1)->beta;
			pstack->beta = -(pstack - 1)->alpha;
			pstack->node_type = (pstack - 1)->next_node_type;
			pstack->depth += pstack->reduction * UNITDEPTH;
			pstack->reduction = 0;
			SEARCH();
		}

		POP_MOVE();
		/*
		update score
		*/
		if(score > pstack->best_score) {

			pstack->best_score = score;
			pstack->best_move = move;
			
			if(score > pstack->alpha) {
				if(score >= pstack->beta) {
					
					pstack->flag = LOWER;
										
					if(!is_cap_prom(move)) {
						history[player][MV8866(move)]++;
						if(move != pstack->killer[0]) {
							pstack->killer[1] = pstack->killer[0];
							pstack->killer[0] = move;
						}
					}

					bad_splits++;

					/*stop workers*/
					l_lock(lock_smp);
					l_lock(master->lock);
					master->stop_workers();
					l_unlock(master->lock);
					l_unlock(lock_smp);
					
					break;
				} 
				
				pstack->alpha = score;
				pstack->flag = EXACT;
				UPDATE_PV(move);
			}
		}
	}
	/*
	remove worker
	*/
	l_lock(master->lock);

	/*update counts*/
	master->nodes += nodes;
	master->qnodes += qnodes;
	master->time_check += time_check;
	master->full_evals += full_evals;
	master->lazy_evals += lazy_evals;
	master->splits += splits;
	master->bad_splits += bad_splits;
	master->egbb_probes += egbb_probes;

	/*update master*/
	ply = master->ply;
	pstack = stack + ply;
	
	if(pstack->best_score > master->pstack->best_score) {
		updated = true;
		UPDATE_BOUND(master->pstack,pstack);
	}

	if(updated
		&& pstack->best_move == master->pstack->best_move) {
		
		if(pstack->flag == EXACT) {
			memcpy(&master->pstack->pv[ply],&pstack->pv[ply],(pstack->pv_length - ply ) * sizeof(MOVE));
			master->pstack->pv_length = pstack->pv_length;
		}

		for(int i = 0;i < MAX_PLY;i++) {
			master->stack[i].killer[0] = stack[i].killer[0];
			master->stack[i].killer[1] = stack[i].killer[1]; 
		}
	}

    /*zero helper*/
	master->workers[processor_id] = NULL;
	master->n_workers--;

	l_unlock(master->lock);
	/*
	end
	*/

	used = false;
}

void SEARCHER::stop_workers() {
	
	for(int i = 0; i < n_processors; i++) {
		if(workers[i]) {
			l_lock(workers[i]->lock);
			workers[i]->stop_searcher = 1;
			workers[i]->stop_workers();
			l_unlock(workers[i]->lock);
		}
	}
	
}

void SEARCHER::attach_processor(int new_proc_id) {

	register int j = 0;
    for(j = 0; j < MAX_SEARCHERS && searchers[j].used; j++);
	if(j < MAX_SEARCHERS) {

		PSEARCHER psearcher = &searchers[j];
		psearcher->COPY(this);
		psearcher->master = this;
		psearcher->stop_searcher = 0;
		psearcher->processor_id = new_proc_id;
		psearcher->used = true;
		
		/*reset counts*/
		psearcher->nodes = 0;
		psearcher->qnodes = 0;
		psearcher->time_check = 0;
		psearcher->full_evals = 0;
		psearcher->lazy_evals = 0;
		psearcher->splits = 0;
		psearcher->bad_splits = 0;
		psearcher->egbb_probes = 0;
		/*end*/

		processors[new_proc_id].searcher = psearcher;
		workers[new_proc_id] = psearcher;
		n_workers++;
	}
}

void init_smp(int mt) {

	for(int i = 1; i < MAX_CPUS;i++) {
		if(n_processors < mt) {
			if(processors[i].state == DEAD) {
				processors[i].create();
				n_processors++;
			}
		} else {
			if(processors[i].state != DEAD) {
				processors[i].state = DEAD;
				n_processors--;
			}
		}
	}
	searchers[0].used = true;
	searchers[0].processor_id = 0;
	processors[0].searcher = &searchers[0];
	processors[0].state = GO;
}

#endif

/*
@ root lots of things are done differently so
lets have a separate search function
*/

void SEARCHER::root_search() {

	MOVE move;
	int score;

	pstack->best_score = -MAX_SCORE;
	pstack->best_move = 0;
	pstack->flag = UPPER;
	pstack->pv_length = ply;
	pstack->hash_move = 0;
	pstack->mate_threat = 0;
	pstack->legal_moves = 0;
	pstack->node_type = PV_NODE;
    pstack->next_node_type = PV_NODE;
	pstack->evalrec.indicator = AVOID_LAZY;
	pstack->extension = 0;
	pstack->reduction = 0;

	/*probe hash table*/
	if(on_node_entry()) {
		if(pstack->best_move) {
			root_score = ((player == white) ? pstack->best_score : -pstack->best_score);
			print_pv(pstack->best_score);
			return;
		}
	}

	/*search root moves*/
	UBMP32 start_nodes;
	int& i = pstack->current_index;

    for(i = 0; i < pstack->count;i++) {

		pstack->current_move = move = pstack->move_st[i];
		pstack->legal_moves++;

	    PUSH_MOVE(move);
        
		start_nodes = nodes;
		pstack->extension = 0;
		pstack->reduction = 0;

		pstack->depth = (pstack - 1)->depth - UNITDEPTH;

		if(i == 0) {
			pstack->alpha = -(pstack - 1)->beta;
			pstack->beta = -(pstack - 1)->alpha;
			pstack->node_type = PV_NODE;
		    pstack->search_state = NULL_MOVE;
			search();
			if(abort_search) return;
			score = -pstack->best_score;

		} else {
			pstack->alpha = -(pstack - 1)->alpha - 1;
			pstack->beta = -(pstack - 1)->alpha;
			pstack->node_type = CUT_NODE;
			pstack->search_state = NULL_MOVE;
			search();
			if(abort_search) return;
			score = -pstack->best_score;

			if(score > (pstack - 1)->alpha 
				&& score < (pstack - 1)->beta
				) {
				pstack->alpha = -(pstack - 1)->beta;
				pstack->beta = -(pstack - 1)->alpha;
				pstack->node_type = PV_NODE;
				pstack->search_state = NULL_MOVE;
				search();
				if(abort_search) return;
				score = -pstack->best_score;
			}
		}
	
		POP_MOVE();

		pstack->score_st[i] = nodes - start_nodes;
		
		if(i == 0 || score > pstack->alpha) {

			/*root score*/
            root_score = ((player == white) ? score : -score);
			register int r_score,pr_score;
			if(scorpio == white) {
				r_score = root_score;
				pr_score = prev_root_score;
			} else {
				r_score = -root_score;
				pr_score = -prev_root_score; 
			}
			if(r_score <= 2000 
				&& (score <= pstack->alpha || r_score <= pr_score - 25)
				) {
				root_failed_low = true;
			} else {
				root_failed_low = false;
			}
			pstack->best_score = score;
			pstack->best_move = move;

			/*update pv*/
			if(score < pstack->beta) {
				UPDATE_PV(move);
			} else {
				pstack->pv[0] = move;
				pstack->pv_length = 1;
				pstack->flag = LOWER;
			}
			print_pv(pstack->best_score);
		}

		if(score > pstack->alpha) {
			if(score >= pstack->beta) {
				record_hash(player,hash_key,DEPTH(pstack->depth),ply,LOWER,score,move,0);
				return;
			}
			pstack->alpha = score;
			pstack->flag = EXACT;
		}
	}
	record_hash(player,hash_key,DEPTH(pstack->depth),ply,pstack->flag,
		pstack->best_score,pstack->best_move,0);
	if(pstack->flag == EXACT) {
        print_pv(pstack->best_score);
	}
}

/*
gets best move of position
*/
MOVE SEARCHER::find_best() {
    int alpha,beta;
	int legal_moves,i,score,time_used;
	int easy = false,easy_score;
	MOVE easy_move;

	ply = 0;
	pstack = stack + 0;
	nodes = 0;
	qnodes = 0;
	time_check = 0;
	full_evals = 0;
	lazy_evals = 0;
	splits = 0;
	bad_splits = 0;
	stop_searcher = 0;
	abort_search = 0;
	search_depth = 1;
	poll_nodes = 100000; // PPC 1000000;
	egbb_probes = 0;
	start_time = get_time();
	age = (hply & AGE_MASK);
	clear_hash_stat();
	pre_calculate();

	/*clear killers/hisory*/
	for(i = 0;i < MAX_PLY;i++){
		stack[i].killer[0] = stack[i].killer[1] = 0;
		stack[i].hash_move = stack[i].best_move = 0;
	}
	for(i = 0;i < 4096;i++) {
		history[0][i] = 0;
        history[1][i] = 0;
	}
	/*generate root moves here*/
	pstack->count = 0;
	gen_all();
	legal_moves = 0;
	for(i = 0;i < pstack->count; i++) {
		pstack->current_move = pstack->move_st[i];
		PUSH_MOVE(pstack->current_move);
		if(attacks(player,plist[COMBINE(opponent,king)]->sq)) {
			POP_MOVE();
			continue;
		}
		POP_MOVE();
		pstack->move_st[legal_moves] = pstack->current_move;
        pstack->score_st[legal_moves] = 0;
		legal_moves++;
	}
	pstack->count = legal_moves;

	/*no move*/
	if(pstack->count == 0)
		return 0;
	/*only one move*/
	if(pstack->count == 1)
		return pstack->move_st[0];

	/*find book move*/
	if(book_loaded 
		&& hply <= last_book_move + 6 
		&& !chess_clock.infinite_mode
		) {
		MOVE move = get_book_move();
		if(move) {
			last_book_move = hply;
			return move;
		}
	}

	/*set search time*/
	chess_clock.set_stime(hply);

	/*is this first search?*/
	if(first_search) {
		first_search = false;
	}

#ifdef PARALLEL
	/*wakeup processors*/
	for(i = 1;i < n_processors;i++) {
		processors[i].state = WAIT;
	}
#endif

	/*easy move*/
	probe_depth = 0;

	for(i = 0;i < pstack->count; i++) {
		pstack->current_move = pstack->move_st[i];
		PUSH_MOVE(pstack->current_move);
		pstack->alpha = -MAX_SCORE;
		pstack->beta = MAX_SCORE;
		pstack->depth = 0;
		pstack->qcheck_depth = CHECK_DEPTH;	
		pstack->use_lazy = false;
		qsearch();
		POP_MOVE();
        pstack->score_st[i] = -(pstack + 1)->best_score;
	}

	for(i = 0;i < pstack->count; i++) {
		pstack->sort(i,pstack->count);
	}

	if(pstack->score_st[0] > pstack->score_st[1] + 175
		&& !chess_clock.infinite_mode
		) {
		easy = true;
		easy_move = pstack->move_st[0];
		easy_score = pstack->score_st[0];
		chess_clock.search_time /= 4;
		send_msg("looks easy...\n");
	}

	stack[0].pv[0] = pstack->move_st[0];

	/*iterative deepening*/
    alpha = pstack->score_st[0] - 4 * WINDOW;
	beta = pstack->score_st[0] + 4 * WINDOW;
	root_failed_low = false;


	do {

		/*search with the current depth*/
		search_depth++;
		probe_depth = (2 * search_depth) / 3;
		pstack->depth = search_depth * UNITDEPTH;
		pstack->alpha = alpha;
		pstack->beta = beta;
		root_search();

		score = pstack->best_score;

        /*sort moves*/
		for(i = 0;i < pstack->count; i++) {
			if(pstack->pv[0] == pstack->move_st[i]) {
				pstack->score_st[i] = MAX_NUMB;
			} 
		}
		for(i = 0;i < pstack->count; i++) {
			pstack->sort(i,pstack->count);
		}

		/*Is there enough time to search the first move*/
        if(!root_failed_low && !chess_clock.infinite_mode) {
            int time_used = get_time() - start_time;
			if(time_used >= 0.75 * chess_clock.search_time)
				abort_search = 1;
		}

		/*aspiration search*/
		if(abs(score) >= WIN_SCORE) {
			alpha = -MAX_SCORE;
			beta = MAX_SCORE;
		} else if(score <= alpha) {
			alpha = score - 4 * WINDOW;
			search_depth--;
		} else if (score >= beta){
			beta = score + 4 * WINDOW;
			search_depth--;
            root_failed_low = false; 
		} else {
			alpha = score - WINDOW;
			beta = score + WINDOW;
			root_failed_low = false;
		}

		/*check if "easy" move is really easy*/
		if(!abort_search  
			&& easy
			&& (easy_move != stack[0].pv[0] || score <= easy_score - 60)
			) {
			easy = false;
            chess_clock.search_time *= 4;
			send_msg("not easy anymore!\n");
		}

		/*check time*/
		if(!abort_search)
		    check_quit();

		/*poll nodes*/
		time_used = get_time() - start_time;
		if(time_used) {
			poll_nodes = int(100 * (float(nodes) / time_used));
#ifdef PARALLEL
			poll_nodes /= n_processors;
#endif
			poll_nodes = max(poll_nodes, 5000);
			poll_nodes = min(poll_nodes, 100000);
		}

	} while(!abort_search && (search_depth < chess_clock.max_sd));
	
	/*save score*/
	prev_root_score = root_score;

	/*search has ended. display some info*/
	time_used = get_time() - start_time;
	if(pv_print_style == 1) {
		send_msg("%8d %8.2f %8d %8d %8d\n",nodes,float(time_used) / 1000,
			int(1000 * (float(nodes) / time_used)),splits,bad_splits);
	} else {
		send_msg("nodes = %d <%d qnodes> time = %.2fs nps = %d\n",nodes,int(100 * qnodes / float(nodes)),
			float(time_used) / 1000,int(1000 * (float(nodes) / time_used)));
		send_msg("lazy_eval = %d splits = %d badsplits = %d egbb_probes = %d\n",
			int(100 * lazy_evals/float(full_evals + lazy_evals)),splits,bad_splits,egbb_probes);
		print_hash_stat();
	}

#ifdef PARALLEL
	/*freeze processors*/
	for(i = 1;i < n_processors;i++) {
		processors[i].state = PARK;
	}
#endif

	return stack[0].pv[0];
}
/*
perft : search simulator for debuging purpose
*/
int SEARCHER::perft(int depth) {
	int stop_ply = ply;
	nodes = 0;
	pstack->depth = depth;
	pstack->gen_status = GEN_START;

	while(true) {
		while(true) {
			if(!get_move()) {
				break;
			}
			
			PUSH_MOVE(pstack->current_move);
		
			pstack->depth = (pstack - 1)->depth - 1;
			pstack->gen_status = GEN_START;
	
			if(pstack->depth <= 0) {
				nodes++;
				break;
			}
			if(ply >= MAX_PLY - 1) {
				break;
			}
			if(ply == 1)
				send_msg(".");
		}

		if(stop_ply == ply)
			break;
		POP_MOVE();
	}
	return nodes;
}
