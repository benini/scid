#include "scorpio.h"

void SEARCHER::do_move(const MOVE& move) {
	int from = m_from(move),to = m_to(move),sq;

	/*save state*/
	PHIST_STACK phstack = hstack + hply;
	phstack->move = move;
	phstack->epsquare = epsquare;
	phstack->castle = castle;
	phstack->fifty = fifty;
	phstack->hash_key = hash_key;
    phstack->pawn_hash_key = pawn_hash_key;
	phstack->checks = checks(move,phstack->rev_check);

	/*remove captured piece*/
	if(m_capture(move)) {
		if(is_ep(move)) {
			sq = to - pawn_dir[player];
			hash_key ^= PC_HKEY(m_capture(move),sq);
			pawn_hash_key ^= PC_HKEY(m_capture(move),sq);
			pcsq_score[opponent] -= pcsq[COMBINE(opponent,pawn)][sq];
		} else {
			sq = to;
			hash_key ^= PC_HKEY(m_capture(move),sq);
			if(PIECE(m_capture(move)) == pawn)
			    pawn_hash_key ^= PC_HKEY(m_capture(move),sq);
			pcsq_score[opponent] -= pcsq[m_capture(move)][sq];
		}
		pcRemove(m_capture(move),sq);
		board[sq] = empty;

		if(PIECE(m_capture(move)) == pawn) {
			pawn_c[opponent]--;
		} else {
			piece_c[opponent] -= piece_cv[m_capture(move)];
		}
		man_c[m_capture(move)]--;
		all_man_c--;
	}

	/*move piece*/
	if(m_promote(move)) {
		board[to] = m_promote(move);
		board[from] = empty;
		pcAdd(m_promote(move),to);
		pcRemove(COMBINE(player,pawn),from);
		hash_key ^= PC_HKEY(COMBINE(player,pawn),from);
		pawn_hash_key ^= PC_HKEY(COMBINE(player,pawn),from);
	    hash_key ^= PC_HKEY(m_promote(move),to);
		pawn_c[player]--;
		piece_c[player] += piece_cv[m_promote(move)];

		pcsq_score[player] -= pcsq[COMBINE(player,pawn)][from];
        pcsq_score[player] += pcsq[m_promote(move)][to];
		man_c[COMBINE(player,pawn)]--;
		man_c[m_promote(move)]++;

	} else {
		board[to] = board[from];
		board[from] = empty;
		pcSwap(from,to);
		hash_key ^= PC_HKEY(m_piece(move),to);
		hash_key ^= PC_HKEY(m_piece(move),from);
		if(PIECE(m_piece(move)) == pawn) {
			pawn_hash_key ^= PC_HKEY(m_piece(move),to);
			pawn_hash_key ^= PC_HKEY(m_piece(move),from);
		}
		pcsq_score[player] += pcsq[m_piece(move)][to] - pcsq[m_piece(move)][from];
	}

	/*move castle*/
	if(is_castle(move)) {
        int fromc,toc;
		if(to > from) {
           fromc = to + RR;
		   toc = to + LL;
		} else {
           fromc = to + 2*LL;
		   toc = to + RR;
		}
		board[toc] = board[fromc];
		board[fromc] = empty;
		pcSwap(fromc,toc);
		hash_key ^= PC_HKEY(COMBINE(player,rook),toc);
		hash_key ^= PC_HKEY(COMBINE(player,rook),fromc);
		pcsq_score[player] += pcsq[COMBINE(player,rook)][toc] - pcsq[COMBINE(player,rook)][fromc];
	} 

	/*update current state*/
	if(epsquare)
	    hash_key ^= EP_HKEY(epsquare);
	epsquare = 0;
	fifty++;
	if(DECOMB(player,m_piece(move)) == pawn) {
		fifty = 0;
	    if(to - from == (2 * pawn_dir[player])) {
            epsquare = ((to + from) >> 1);
			hash_key ^= EP_HKEY(epsquare);
		}
	}else if(m_capture(move)) {
		fifty = 0;
	}
	int p_castle = castle;
	if(from == E1 || to == A1 || from == A1) castle &= ~WLC_FLAG;
	if(from == E1 || to == H1 || from == H1) castle &= ~WSC_FLAG;
	if(from == E8 || to == A8 || from == A8) castle &= ~BLC_FLAG;
	if(from == E8 || to == H8 || from == H8) castle &= ~BSC_FLAG;
	if(p_castle != castle) {
	   hash_key ^= CAST_HKEY(p_castle);
       hash_key ^= CAST_HKEY(castle);
	}

	player = invert(player);
	opponent = invert(opponent);

    hply++;
}

void SEARCHER::undo_move() {
	MOVE move;
	int to,from,sq;

	hply--;

	player = invert(player);
	opponent = invert(opponent);

	/*retrieve state*/
	PHIST_STACK phstack = &hstack[hply];
	epsquare = phstack->epsquare;
	castle = phstack->castle;
	fifty = phstack->fifty;
	move = phstack->move; 
	hash_key = phstack->hash_key;
    pawn_hash_key = phstack->pawn_hash_key;

	to = m_to(move);
	from = m_from(move);

	/*unmove castle*/
	if(is_castle(move)) {
        int fromc,toc;
		if(to > from) {
           fromc = to + LL;
		   toc = to + RR;
		} else {
           fromc = to + RR;
		   toc = to + 2*LL;
		}
		board[toc] = board[fromc];
		board[fromc] = empty;
		pcSwap(fromc,toc);
		pcsq_score[player] += pcsq[COMBINE(player,rook)][toc] - pcsq[COMBINE(player,rook)][fromc];
	} 

	/*unmove piece*/
	if(m_promote(move)) {
		board[from] = COMBINE(player,pawn);
		board[to] = empty;
		pcAdd(COMBINE(player,pawn),from);
		pcRemove(m_promote(move),to);

		pcsq_score[player] += pcsq[COMBINE(player,pawn)][from];
        pcsq_score[player] -= pcsq[m_promote(move)][to];
        pawn_c[player]++;
		piece_c[player] -= piece_cv[m_promote(move)];
		man_c[COMBINE(player,pawn)]++;
		man_c[m_promote(move)]--;
	} else {
		board[from] = board[to];
		board[to] = empty;
		pcSwap(to,from);
		pcsq_score[player] += pcsq[m_piece(move)][from] - pcsq[m_piece(move)][to];
	}

	/*insert captured piece*/
	if(m_capture(move)) {
		if(is_ep(move)) {
			sq = to - pawn_dir[player];
			pcsq_score[opponent] += pcsq[COMBINE(opponent,pawn)][sq];
		} else {
			sq = to;
			pcsq_score[opponent] += pcsq[m_capture(move)][sq];
		}
		board[sq] = m_capture(move);
		pcAdd(m_capture(move),sq);

		if(PIECE(m_capture(move)) == pawn) {
			pawn_c[opponent]++;
		} else {
			piece_c[opponent] += piece_cv[m_capture(move)];
		}
		man_c[m_capture(move)]++;
		all_man_c++;
	}
}

void SEARCHER::do_null() {
	PHIST_STACK phstack = hstack + hply;
	phstack->move = 0;
	phstack->epsquare = epsquare;
	phstack->fifty = fifty;
	phstack->hash_key = hash_key;
	phstack->checks = 0;

	if(epsquare)
	    hash_key ^= EP_HKEY(epsquare);
	epsquare = 0;
	fifty++;

	player = invert(player);
	opponent = invert(opponent);

    hply++;
}

void SEARCHER::undo_null() {
	hply--;

	player = invert(player);
	opponent = invert(opponent);

	PHIST_STACK phstack = &hstack[hply];
	epsquare = phstack->epsquare;
	fifty = phstack->fifty;
	hash_key = phstack->hash_key;
}

#define NK_CAP(dir) {\
	    to = from + dir;\
       	if(COLOR(board[to]) == opponent) \
			*pmove++ = tmove | (to<<8) | (board[to]<<20);\
};
#define BRQ_CAP(dir) {\
	    to = from + dir; \
		while(board[to] == empty) to += dir;\
		if(COLOR(board[to]) == opponent) \
			*pmove++ = tmove | (to<<8) | (board[to]<<20);\
};

void SEARCHER::gen_caps() {
	MOVE* pmove = &pstack->move_st[pstack->count],*spmove = pmove,tmove;
	int  from,to;
	PLIST current;
	
	if(player == white) {
		/*pawns*/
		current = plist[wpawn];
		while(current) {
			from = current->sq;
			to = from + RU;
			if(COLOR(board[to]) == black) {
				if(rank(to) == RANK8) {
					tmove = from | (to<<8) | (wpawn<<16) | (board[to]<<20);
					*pmove++ = tmove | (wqueen<<24);
					*pmove++ = tmove | (wknight<<24);
					*pmove++ = tmove | (wrook<<24);
					*pmove++ = tmove | (wbishop<<24);
				} else 
					*pmove++ = from | (to<<8) | (wpawn<<16) | (board[to]<<20);
			}
			to = from + LU;
			if(COLOR(board[to]) == black) {
				if(rank(to) == RANK8) {
					tmove = from | (to<<8) | (wpawn<<16) | (board[to]<<20);
					*pmove++ = tmove | (wqueen<<24);
					*pmove++ = tmove | (wknight<<24);
					*pmove++ = tmove | (wrook<<24);
					*pmove++ = tmove | (wbishop<<24);
				} else 
					*pmove++ = from | (to<<8) | (wpawn<<16) | (board[to]<<20);
			}

			to = from + UU;
			if(rank(to) == RANK8) {
				if(board[to] == empty)
					*pmove++ = from | (to<<8) | (wpawn<<16) | (wqueen<<24);
			}	
			current = current->next;
		}
		if(epsquare) {
			from = epsquare + LD;
			if(board[from] == wpawn)
				*pmove++ = from | (epsquare<<8) | (wpawn<<16) | (bpawn<<20) | EP_FLAG;
			
			from = epsquare + RD;
			if(board[from] == wpawn)
				*pmove++ = from | (epsquare<<8) | (wpawn<<16) | (bpawn<<20) | EP_FLAG;
		}
		/*knight*/
		current = plist[wknight];
		while(current) {
			from = current->sq;
			tmove = from | (wknight<<16);
			NK_CAP(RRU);
			NK_CAP(LLD);
			NK_CAP(RUU);
			NK_CAP(LDD);
			NK_CAP(LLU);
			NK_CAP(RRD);
			NK_CAP(RDD);
			NK_CAP(LUU);
			current = current->next;
		}
		/*bishop*/
		current = plist[wbishop];
		while(current) {
			from = current->sq;
			tmove = from | (wbishop<<16);
			BRQ_CAP(RU);
			BRQ_CAP(LD);
			BRQ_CAP(LU);
			BRQ_CAP(RD);
			current = current->next;
		}
		/*rook*/
		current = plist[wrook];
		while(current) {
			from = current->sq;
			tmove = from | (wrook<<16);
			BRQ_CAP(UU);
			BRQ_CAP(DD);
			BRQ_CAP(RR);
			BRQ_CAP(LL);
			current = current->next;
		}
		/*queen*/
		current = plist[wqueen];
		while(current) {
			from = current->sq;
			tmove = from | (wqueen<<16);
			BRQ_CAP(RU);
			BRQ_CAP(LD);
			BRQ_CAP(LU);
			BRQ_CAP(RD);
			BRQ_CAP(UU);
			BRQ_CAP(DD);
			BRQ_CAP(RR);
			BRQ_CAP(LL);
			current = current->next;
		}
		/*king*/
		from = plist[wking]->sq;
		tmove = from | (wking<<16);
		NK_CAP(RU);
		NK_CAP(LD);
		NK_CAP(LU);
		NK_CAP(RD);
		NK_CAP(UU);
		NK_CAP(DD);
		NK_CAP(RR);
		NK_CAP(LL);
	} else {
		/*pawns*/
		current = plist[bpawn];
		while(current) {
			from = current->sq;
			to = from + LD;
			if(COLOR(board[to]) == white) {
				if(rank(to) == RANK1) {
					tmove = from | (to<<8) | (bpawn<<16) | (board[to]<<20);
					*pmove++ = tmove | (bqueen<<24);
					*pmove++ = tmove | (bknight<<24);
					*pmove++ = tmove | (brook<<24);
					*pmove++ = tmove | (bbishop<<24);
				} else 
					*pmove++ = from | (to<<8) | (bpawn<<16) | (board[to]<<20);
			}
			to = from + RD;
			if(COLOR(board[to]) == white) {
				if(rank(to) == RANK1) {
					tmove = from | (to<<8) | (bpawn<<16) | (board[to]<<20);
					*pmove++ = tmove | (bqueen<<24);
					*pmove++ = tmove | (bknight<<24);
					*pmove++ = tmove | (brook<<24);
					*pmove++ = tmove | (bbishop<<24);
				} else 
					*pmove++ = from | (to<<8) | (bpawn<<16) | (board[to]<<20);
			}
			
			to = from + DD;
			if(rank(to) == RANK1) {
				if(board[to] == empty)
					*pmove++ = from | (to<<8) | (bpawn<<16) | (bqueen<<24);
			}	
			current = current->next;
		}
		if(epsquare) {
			from = epsquare + RU;
			if(board[from] == bpawn)
				*pmove++ = from | (epsquare<<8) | (bpawn<<16) | (wpawn<<20) | EP_FLAG;
			
			from = epsquare + LU;
			if(board[from] == bpawn)
				*pmove++ = from | (epsquare<<8) | (bpawn<<16) | (wpawn<<20) | EP_FLAG;
		}
		/*knight*/
		current = plist[bknight];
		while(current) {
			from = current->sq;
			tmove = from | (bknight<<16);
			NK_CAP(RRU);
			NK_CAP(LLD);
			NK_CAP(RUU);
			NK_CAP(LDD);
			NK_CAP(LLU);
			NK_CAP(RRD);
			NK_CAP(RDD);
			NK_CAP(LUU);
			current = current->next;
		}
		/*bishop*/
		current = plist[bbishop];
		while(current) {
			from = current->sq;
			tmove = from | (bbishop<<16);
			BRQ_CAP(RU);
			BRQ_CAP(LD);
			BRQ_CAP(LU);
			BRQ_CAP(RD);
			current = current->next;
		}
		/*rook*/
		current = plist[brook];
		while(current) {
			from = current->sq;
			tmove = from | (brook<<16);
			BRQ_CAP(UU);
			BRQ_CAP(DD);
			BRQ_CAP(RR);
			BRQ_CAP(LL);
			current = current->next;
		}
		/*queen*/
		current = plist[bqueen];
		while(current) {
			from = current->sq;
			tmove = from | (bqueen<<16);
			BRQ_CAP(RU);
			BRQ_CAP(LD);
			BRQ_CAP(LU);
			BRQ_CAP(RD);
			BRQ_CAP(UU);
			BRQ_CAP(DD);
			BRQ_CAP(RR);
			BRQ_CAP(LL);
			current = current->next;
		}
		/*king*/
		from = plist[bking]->sq;
		tmove = from | (bking<<16);
		NK_CAP(RU);
		NK_CAP(LD);
		NK_CAP(LU);
		NK_CAP(RD);
		NK_CAP(UU);
		NK_CAP(DD);
		NK_CAP(RR);
		NK_CAP(LL);
	}
	/*count*/
	pstack->count += int(pmove - spmove);
}

#define NK_NONCAP(dir) {\
		to = from + dir;\
		if(board[to] == empty)\
			*pmove++ = tmove | (to<<8); \
};
#define BRQ_NONCAP(dir) {\
	    to = from + dir; \
		while(board[to] == empty) {\
			*pmove++ = tmove | (to<<8); \
			to += dir;\
		}\
};


void SEARCHER::gen_noncaps() {
	MOVE* pmove = &pstack->move_st[pstack->count],*spmove = pmove,tmove;
	int  from,to;
	PLIST current;
	
	if(player == white) {

		/*castling*/
		if(!attacks(black,E1)) {
			if(castle & WSC_FLAG &&
				board[F1] == empty &&
				board[G1] == empty &&
				!attacks(black,F1) &&
				!attacks(black,G1))
				*pmove++ = E1 | (G1<<8) | (wking<<16) | CASTLE_FLAG;
			if(castle & WLC_FLAG &&
				board[B1] == empty &&
				board[C1] == empty &&
				board[D1] == empty &&
				!attacks(black,C1) &&
				!attacks(black,D1)) {
				*pmove++ = E1 | (C1<<8) | (wking<<16) | CASTLE_FLAG;
			}
		}
		/*knight*/
		current = plist[wknight];
		while(current) {
			from = current->sq;
			tmove = from | (wknight<<16);
			NK_NONCAP(RRU);
			NK_NONCAP(LLD);
			NK_NONCAP(RUU);
			NK_NONCAP(LDD);
			NK_NONCAP(LLU);
			NK_NONCAP(RRD);
			NK_NONCAP(RDD);
			NK_NONCAP(LUU);
			current = current->next;
		}
		/*bishop*/
		current = plist[wbishop];
		while(current) {
			from = current->sq;
			tmove = from | (wbishop<<16);
			BRQ_NONCAP(RU);
			BRQ_NONCAP(LD);
			BRQ_NONCAP(LU);
			BRQ_NONCAP(RD);
			current = current->next;
		}
		/*rook*/
		current = plist[wrook];
		while(current) {
			from = current->sq;
			tmove = from | (wrook<<16);
			BRQ_NONCAP(UU);
			BRQ_NONCAP(DD);
			BRQ_NONCAP(RR);
			BRQ_NONCAP(LL);
			current = current->next;
		}
		/*queen*/
		current = plist[wqueen];
		while(current) {
			from = current->sq;
			tmove = from | (wqueen<<16);
			BRQ_NONCAP(RU);
			BRQ_NONCAP(LD);
			BRQ_NONCAP(LU);
			BRQ_NONCAP(RD);
			BRQ_NONCAP(UU);
			BRQ_NONCAP(DD);
			BRQ_NONCAP(RR);
			BRQ_NONCAP(LL);
			current = current->next;
		}
		/*king*/
		from = plist[wking]->sq;
		tmove = from | (wking<<16);
		NK_NONCAP(RU);
		NK_NONCAP(LD);
		NK_NONCAP(LU);
		NK_NONCAP(RD);
		NK_NONCAP(UU);
		NK_NONCAP(DD);
		NK_NONCAP(RR);
		NK_NONCAP(LL);
		
		/*pawn*/
		current = plist[wpawn];
		while(current) {
			from = current->sq;
			to = from + UU;
			if(board[to] == empty) {
				if(rank(to) == RANK8) {
					tmove = from | (to<<8) | (wpawn<<16);
					*pmove++ = tmove | (wknight<<24);
					*pmove++ = tmove | (wrook<<24);
					*pmove++ = tmove | (wbishop<<24);
				} else {
					*pmove++ = from | (to<<8) | (wpawn<<16);
					
					if(rank(from) == RANK2) {
						to += UU;
						if(board[to] == empty)
							*pmove++ = from | (to<<8) | (wpawn<<16);
					}
				}
			}	
			current = current->next;
		}
	} else {

		/*castling*/
		if(!attacks(white,E8)) {
			if(castle & BSC_FLAG &&
				board[F8] == empty &&
				board[G8] == empty &&
				!attacks(white,F8) &&
				!attacks(white,G8))
				*pmove++ = E8 | (G8<<8) | (bking<<16) | CASTLE_FLAG;
			if(castle & BLC_FLAG &&
				board[B8] == empty &&
				board[C8] == empty &&
				board[D8] == empty &&
				!attacks(white,C8) &&
				!attacks(white,D8)) {
				*pmove++ = E8 | (C8<<8) | (bking<<16) | CASTLE_FLAG;
			}
		}

		/*knight*/
		current = plist[bknight];
		while(current) {
			from = current->sq;
			tmove = from | (bknight<<16);
			NK_NONCAP(RRU);
			NK_NONCAP(LLD);
			NK_NONCAP(RUU);
			NK_NONCAP(LDD);
			NK_NONCAP(LLU);
			NK_NONCAP(RRD);
			NK_NONCAP(RDD);
			NK_NONCAP(LUU);
			current = current->next;
		}
		/*bishop*/
		current = plist[bbishop];
		while(current) {
			from = current->sq;
			tmove = from | (bbishop<<16);
			BRQ_NONCAP(RU);
			BRQ_NONCAP(LD);
			BRQ_NONCAP(LU);
			BRQ_NONCAP(RD);
			current = current->next;
		}
		/*rook*/
		current = plist[brook];
		while(current) {
			from = current->sq;
			tmove = from | (brook<<16);
			BRQ_NONCAP(UU);
			BRQ_NONCAP(DD);
			BRQ_NONCAP(RR);
			BRQ_NONCAP(LL);
			current = current->next;
		}
		/*queen*/
		current = plist[bqueen];
		while(current) {
			from = current->sq;
			tmove = from | (bqueen<<16);
			BRQ_NONCAP(RU);
			BRQ_NONCAP(LD);
			BRQ_NONCAP(LU);
			BRQ_NONCAP(RD);
			BRQ_NONCAP(UU);
			BRQ_NONCAP(DD);
			BRQ_NONCAP(RR);
			BRQ_NONCAP(LL);
			current = current->next;
		}
		
		/*king*/
		from = plist[bking]->sq;
		tmove = from | (bking<<16);
		NK_NONCAP(RU);
		NK_NONCAP(LD);
		NK_NONCAP(LU);
		NK_NONCAP(RD);
		NK_NONCAP(UU);
		NK_NONCAP(DD);
		NK_NONCAP(RR);
		NK_NONCAP(LL);
		
		/*pawn*/
		current = plist[bpawn];
		while(current) {
			from = current->sq;
			to = from + DD;
			if(board[to] == empty) {
				if(rank(to) == RANK1) {
					tmove = from | (to<<8) | (bpawn<<16);
					*pmove++ = tmove | (bknight<<24);
					*pmove++ = tmove | (brook<<24);
					*pmove++ = tmove | (bbishop<<24);
				} else {
					*pmove++ = from | (to<<8) | (bpawn<<16);
					
					if(rank(from) == RANK7) {
						to += DD;
						if(board[to] == empty)
							*pmove++ = from | (to<<8) | (bpawn<<16);
					}
				}
			}	
			current = current->next;
		}
	}
	/*count*/
	pstack->count += int(pmove - spmove);
}

#define K_EVADE(dir) {\
	    to = from + dir; \
        if(!(to & 0x88) && (check_dir1 != dir) && (check_dir2 != dir) && !attacks(opponent,to)) {\
			if(board[to] == empty)\
			    *pmove++ = tmove | (to<<8);\
		 	else if(COLOR(board[to]) == opponent)\
				*pmove++ = tmove | (to<<8) | (board[to]<<20);\
		}\
};

void SEARCHER::gen_evasions() {
	MOVE* pmove = &pstack->move_st[pstack->count],*spmove = pmove,tmove;
	int  from,to;
	PLIST current;
	int  sq,king_sq,att_sq,n_attackers,check_dir1,check_dir2;
	n_attackers = 0;
    check_dir1 = -2;
    check_dir2 = -2;
	king_sq = plist[COMBINE(player,king)]->sq;

	/*
	extract attack info
	1) Direct check
	2) Indirect check
	3) Direct + indirect check
	4) Indirect + indirect
	*/
	if(hstack[hply - 1].checks == 1) { 
		n_attackers = 1;
		att_sq = m_to(hstack[hply - 1].move);
		if(piece_mask[board[att_sq]] & QRBM)
			check_dir1 = sqatt[king_sq - att_sq].step;
	} else if(hstack[hply - 1].checks == 2) {
		n_attackers = 1;
		att_sq = hstack[hply - 1].rev_check;
		check_dir1 = sqatt[king_sq - att_sq].step;
	} else {
		n_attackers = 2;
		if(hstack[hply - 1].checks == 3) {
			att_sq = m_to(hstack[hply - 1].move);
			if(piece_mask[board[att_sq]] & QRBM)
				check_dir1 = sqatt[king_sq - att_sq].step;
			check_dir2 = sqatt[king_sq - hstack[hply - 1].rev_check].step;
		} else {
			att_sq = m_from(hstack[hply - 1].move);
			check_dir1 = sqatt[king_sq - att_sq].step;
			check_dir2 = sqatt[king_sq - hstack[hply - 1].rev_check].step;
		}
	}

	if(player == white) {
		//king moves
		from = king_sq;
		tmove = from | (wking<<16);
		K_EVADE(RU);
		K_EVADE(LD);
		K_EVADE(LU);
		K_EVADE(RD);
		K_EVADE(UU);
		K_EVADE(DD);
		K_EVADE(RR);
		K_EVADE(LL);
		
		if(n_attackers > 1) {
			pstack->count += int(pmove - spmove);
			return;
		}
		
		//pawn blocked
		
		if(check_dir1!=-2) {
			for(to = king_sq - check_dir1;to != att_sq;to -= check_dir1) {
				from = to - UU;
				if(board[from] == wpawn &&  !pinned_on_king(from,white)) {
					if(rank(to) == RANK8) {
						tmove = from | (to<<8) | (wpawn<<16);
						*pmove++ = tmove | (wqueen<<24);
						*pmove++ = tmove | (wknight<<24);
						*pmove++ = tmove | (wrook<<24);
						*pmove++ = tmove | (wbishop<<24);
					}
					else
						*pmove++ = from | (to<<8) | (wpawn<<16);
				} else if(board[from] == empty && rank(from) == RANK3) {
					from += DD;
					if(board[from] == wpawn && !pinned_on_king(from,white))
						*pmove++ = from | (to<<8) | (wpawn<<16);
				}
			}
		}
		
		//normal captures
		to = att_sq;
		
		from = to - RU;
		if(board[from] == wpawn && !pinned_on_king(from,white)) {
			if(rank(to) == RANK8) {
				tmove = from | (to<<8) | (wpawn<<16) | (board[to]<<20);
				*pmove++ = tmove | (wqueen<<24);
				*pmove++ = tmove | (wknight<<24);
				*pmove++ = tmove | (wrook<<24);
				*pmove++ = tmove | (wbishop<<24);
			}
			else 
				*pmove++ = from | (to<<8) | (wpawn<<16) | (board[to]<<20);
		}
		from = to - LU;
		if(board[from] == wpawn && !pinned_on_king(from,white)) {
			if(rank(to) == RANK8) {
				tmove = from | (to<<8) | (wpawn<<16) | (board[to]<<20);
				*pmove++ = tmove | (wqueen<<24);
				*pmove++ = tmove | (wknight<<24);
				*pmove++ = tmove | (wrook<<24);
				*pmove++ = tmove | (wbishop<<24);
			}
			else 
				*pmove++ = from | (to<<8) | (wpawn<<16) | (board[to]<<20);
		}
		
		
		//ep captures
		if(epsquare){
			from = epsquare - RU;
			sq = epsquare + ((epsquare > from)? DD:UU );
			if(board[from] == wpawn &&
				(sq == att_sq || (sqatt[epsquare - king_sq].step != 0 && sqatt[epsquare - king_sq].step == -sqatt[epsquare-att_sq].step)) &&
				!pinned_on_king(sq,white) && !pinned_on_king(from,white))
				  *pmove++ = from | (epsquare<<8) | (wpawn<<16) | (bpawn<<20) | EP_FLAG;
			
			from = epsquare - LU;
			sq = epsquare + ((epsquare > from)? DD:UU );
			if(board[from] == wpawn &&
				(sq == att_sq || (sqatt[epsquare - king_sq].step != 0 && sqatt[epsquare - king_sq].step == -sqatt[epsquare-att_sq].step)) &&
				!pinned_on_king(sq,white) && !pinned_on_king(from,white))
				  *pmove++ = from | (epsquare<<8) | (wpawn<<16) | (bpawn<<20) | EP_FLAG;
		}
		
		//knight
		
		current = plist[wknight];
		while(current) {
			from = current->sq;
			if(!pinned_on_king(from,white)){
				if(check_dir1!=-2) {
					for(to = king_sq - check_dir1;to != att_sq;to -= check_dir1) {
						if(sqatt[from - to].pieces & NM)
							*pmove++ = from | (to<<8) | (wknight<<16);
					}
				}
				
				if(sqatt[from - att_sq].pieces & NM)
					*pmove++ = from | (to<<8) | (wknight<<16) | (board[to]<<20);
			}
			current = current->next;
		}
		
		//bishop
		current = plist[wbishop];
		while(current) {
			from = current->sq;
			if(!pinned_on_king(from,white)){
				if(check_dir1!=-2) {
					for(to = king_sq - check_dir1;to != att_sq;to -= check_dir1) {
						if(sqatt[from - to].pieces & BM)
							if(blocked(from,to)==0)
								*pmove++ = from | (to<<8) | (wbishop<<16);
					}
				}
				
				if(sqatt[from - att_sq].pieces & BM)
					if(blocked(from,att_sq)==0)
						*pmove++ = from | (to<<8) | (wbishop<<16) | (board[to]<<20);
			}
			current = current->next;
		}
		
		//rook
		current = plist[wrook];
		while(current) {
			from = current->sq;
			if(!pinned_on_king(from,white)){
				if(check_dir1!=-2) {
					for(to = king_sq - check_dir1;to != att_sq;to -= check_dir1) {
						if(sqatt[from - to].pieces & RM)
							if(blocked(from,to)==0)
								*pmove++ = from | (to<<8) | (wrook<<16);
					}
				}
				
				if(sqatt[from - att_sq].pieces & RM)
					if(blocked(from,att_sq)==0)
						*pmove++ = from | (to<<8) | (wrook<<16) | (board[to]<<20);
			}
			current = current->next;
		}
		
		//queen
		current = plist[wqueen];
		while(current) {
			from = current->sq;
			if(!pinned_on_king(from,white)){
				if(check_dir1!=-2) {
					for(to = king_sq - check_dir1;to != att_sq;to -= check_dir1) {
						if(sqatt[from - to].pieces & QM)
							if(blocked(from,to)==0)
								*pmove++ = from | (to<<8) | (wqueen<<16);
					}
				}
				
				if(sqatt[from - att_sq].pieces & QM)
					if(blocked(from,att_sq)==0)
						*pmove++ = from | (to<<8) | (wqueen<<16) | (board[to]<<20);
			}
			current = current->next;
		}
	} else {
		//king moves
		from = king_sq;
		tmove = from | (bking<<16);
		K_EVADE(RU);
		K_EVADE(LD);
		K_EVADE(LU);
		K_EVADE(RD);
		K_EVADE(UU);
		K_EVADE(DD);
		K_EVADE(RR);
		K_EVADE(LL);
		
		if(n_attackers > 1) {
			pstack->count += int(pmove - spmove);
			return;
		}
		
		//pawn blocked
		
		if(check_dir1!=-2) {
			for(to = king_sq - check_dir1;to != att_sq;to -= check_dir1) {
				from = to - DD;
				if(board[from] == bpawn &&  !pinned_on_king(from,black)) {
					if(rank(to) == RANK1) {
						tmove = from | (to<<8) | (bpawn<<16);
						*pmove++ = tmove | (bqueen<<24);
						*pmove++ = tmove | (bknight<<24);
						*pmove++ = tmove | (brook<<24);
						*pmove++ = tmove | (bbishop<<24);
					}
					else
						*pmove++ = from | (to<<8) | (bpawn<<16);
				} else if(board[from] == empty && rank(from) == RANK6) {
					from += UU;
					if(board[from] == bpawn && !pinned_on_king(from,black))
						*pmove++ = from | (to<<8) | (bpawn<<16);
				}
			}
		}
		
		//normal captures
		to = att_sq;
		
		from = to - LD;
		if(board[from] == bpawn && !pinned_on_king(from,black)) {
			if(rank(to) == RANK1) {
				tmove = from | (to<<8) | (bpawn<<16) | (board[to]<<20);
				*pmove++ = tmove | (bqueen<<24);
				*pmove++ = tmove | (bknight<<24);
				*pmove++ = tmove | (brook<<24);
				*pmove++ = tmove | (bbishop<<24);
			}
			else 
				*pmove++ = from | (to<<8) | (bpawn<<16) | (board[to]<<20);
		}
		from = to - RD;
		if(board[from] == bpawn && !pinned_on_king(from,black)) {
			if(rank(to) == RANK1) {
				tmove = from | (to<<8) | (bpawn<<16) | (board[to]<<20);
				*pmove++ = tmove | (bqueen<<24);
				*pmove++ = tmove | (bknight<<24);
				*pmove++ = tmove | (brook<<24);
				*pmove++ = tmove | (bbishop<<24);
			}
			else 
				*pmove++ = from | (to<<8) | (bpawn<<16) | (board[to]<<20);
		}
		
		
		//ep captures
		if(epsquare){
			from = epsquare - LD;
			sq = epsquare + ((epsquare > from)? DD:UU );
			if(board[from] == bpawn &&
				(sq == att_sq || (sqatt[epsquare - king_sq].step != 0 && sqatt[epsquare - king_sq].step == -sqatt[epsquare - att_sq].step)) &&
				!pinned_on_king(sq,black) && !pinned_on_king(from,black))
				*pmove++ = from | (epsquare<<8) | (bpawn<<16) | (wpawn<<20) | EP_FLAG;
			
			from = epsquare - RD;
			sq = epsquare + ((epsquare > from)? DD:UU );
			if(board[from] == bpawn &&
				(sq == att_sq || (sqatt[epsquare - king_sq].step != 0 && sqatt[epsquare - king_sq].step == -sqatt[epsquare - att_sq].step)) &&
				!pinned_on_king(sq,black) && !pinned_on_king(from,black))
				*pmove++ = from | (epsquare<<8) | (bpawn<<16) | (wpawn<<20) | EP_FLAG;
		}
		
		//knight
		current = plist[bknight];
		while(current) {
			from = current->sq;
			if(!pinned_on_king(from,black)){
				if(check_dir1!=-2) {
					for(to = king_sq - check_dir1;to != att_sq;to -= check_dir1) {
						if(sqatt[from - to].pieces & NM)
							*pmove++ = from | (to<<8) | (bknight<<16);
					}
				}
				
				if(sqatt[from - att_sq].pieces & NM)
					*pmove++ = from | (to<<8) | (bknight<<16) | (board[to]<<20);
			}
			current = current->next;
		}
		
		//bishop
		current = plist[bbishop];
		while(current) {
			from = current->sq;
			if(!pinned_on_king(from,black)){
				if(check_dir1!=-2) {
					for(to = king_sq - check_dir1;to != att_sq;to -= check_dir1) {
						if(sqatt[from - to].pieces & BM)
							if(blocked(from,to) == 0)
								*pmove++ = from | (to<<8) | (bbishop<<16);
					}
				}
				
				if(sqatt[from - att_sq].pieces & BM)
					if(blocked(from,att_sq) == 0)
						*pmove++ = from | (to<<8) | (bbishop<<16) | (board[to]<<20);
			}
			current = current->next;
		}
		
		//rook
		current = plist[brook];
		while(current) {
			from = current->sq;
			if(!pinned_on_king(from,black)){
				if(check_dir1!=-2) {
					for(to = king_sq - check_dir1;to != att_sq;to -= check_dir1) {
						if(sqatt[from - to].pieces & RM)
							if(blocked(from,to) == 0)
								*pmove++ = from | (to<<8) | (brook<<16);
					}
				}
				
				if(sqatt[from - att_sq].pieces & RM)
					if(blocked(from,att_sq) == 0)
						*pmove++ = from | (to<<8) | (brook<<16) | (board[to]<<20);
			}
			current = current->next;
		}
		
		//queen
		current = plist[bqueen];
		while(current) {
			from = current->sq;
			if(!pinned_on_king(from,black)){
				if(check_dir1!=-2) {
					for(to = king_sq - check_dir1;to != att_sq;to -= check_dir1) {
						if(sqatt[from - to].pieces & QM)
							if(blocked(from,to) == 0)
								*pmove++ = from | (to<<8) | (bqueen<<16);
					}
				}
				
				if(sqatt[from - att_sq].pieces & QM)
					if(blocked(from,att_sq) == 0)
						*pmove++ = from | (to<<8) | (bqueen<<16) | (board[to]<<20);
			}
			current = current->next;
		}
	}
	/*count*/
	pstack->count += int(pmove - spmove);
}

void SEARCHER::gen_all() {
	gen_caps();
	gen_noncaps();
}

#define N_CHK(dir) {\
	    to = from + dir; \
		if(pinned || (sqatt[to - oking_sq].pieces & NM)) {\
            if(board[to] == empty)\
			    *pmove++ = tmove | (to<<8); \
		}\
};
#define K_CHK(dir) {\
		if(abs(pinned) != abs(dir)) {\
			to = from + dir; \
            if(board[to] == empty)\
			    *pmove++ = tmove | (to<<8); \
		} \
};
#define BRQ_CHK(moving,dir) {\
	    to = from + dir;\
        while(board[to] == empty) {\
			if(pinned || ((sqatt[to - oking_sq].pieces & piece_mask[moving]) && blocked(to,oking_sq) == 0))\
			   *pmove++ = tmove | (to<<8);\
            to += dir;\
		}\
};

void SEARCHER::gen_checks(){
	MOVE* pmove = &pstack->move_st[pstack->count],*spmove = pmove,tmove;
	int   from,to,pinned;
	PLIST current;
	int oking_sq = plist[COMBINE(opponent,king)]->sq;
	
	if(player == white) {
		//direct pawn checks
		to = oking_sq + RD;
		from = to + DD;
		if(board[to] == empty) {
			if(board[from] == wpawn)
				*pmove++ = from | (to<<8) | (wpawn<<16);
			else if(board[from] == empty && rank(from) == RANK3) {
				from += DD;
				if(board[from] == wpawn)
					*pmove++ = from | (to<<8) | (wpawn<<16);
			}
		}
		to = oking_sq + LD;
		from = to + DD;
		if(board[to] == empty) {
			if(board[from] == wpawn)
				*pmove++ = from | (to<<8) | (wpawn<<16);
			else if(board[from] == empty && rank(from) == RANK3) {
				from += DD;
				if(board[from] == wpawn)
					*pmove++ = from | (to<<8) | (wpawn<<16);
			}
		}
		
		//pawn indirect checks
		current = plist[wpawn];
		while(current) {
			from = current->sq;
			pinned = pinned_on_king(from,black);
			if(pinned && pinned != DD) {
				to = from + UU;
				if(board[to] == empty) {
					if(rank(to) != RANK8 && rank(to) != RANK1) {
						if(pinned || (sqatt[to - oking_sq].pieces & WPM))
							*pmove++ = from | (to<<8) | (wpawn<<16);
						if(rank(from)==RANK2) {
							to += UU;
							if(board[to] == empty)
								*pmove++ = from | (to<<8) | (wpawn<<16);
						}
					}
				}	
			}
			current = current->next;
		}
		//knight
		current = plist[wknight];
		while(current) {
			from = current->sq;
			tmove = from | (wknight<<16);
			pinned = pinned_on_king(from,black);
			N_CHK(RRU);
			N_CHK(LLD);
			N_CHK(RUU);
			N_CHK(LDD);
			N_CHK(LLU);
			N_CHK(RRD);
			N_CHK(RDD);
			N_CHK(LUU);
			current = current->next;
		}
		//bishop
		current = plist[wbishop];
		while(current) {
			from = current->sq;
			tmove = from | (wbishop<<16);
			pinned = pinned_on_king(from,black);
			BRQ_CHK(bishop,RU);
			BRQ_CHK(bishop,LD);
			BRQ_CHK(bishop,LU);
			BRQ_CHK(bishop,RD);
			current = current->next;
		}
		
		//rook
		current = plist[wrook];
		while(current) {
			from = current->sq;
			tmove = from | (wrook<<16);
			pinned = pinned_on_king(from,black);
			BRQ_CHK(rook,UU);
			BRQ_CHK(rook,DD);
			BRQ_CHK(rook,RR);
			BRQ_CHK(rook,LL);
			current = current->next;
		}
		
		//queen
		current = plist[wqueen];
		while(current) {
			from = current->sq;
			tmove = from | (wqueen<<16);
			pinned = pinned_on_king(from,black);
			BRQ_CHK(queen,RU);
			BRQ_CHK(queen,LD);
			BRQ_CHK(queen,LU);
			BRQ_CHK(queen,RD);
			BRQ_CHK(queen,UU);
			BRQ_CHK(queen,DD);
			BRQ_CHK(queen,RR);
			BRQ_CHK(queen,LL);
			current = current->next;
		}
		//king
		from = plist[wking]->sq;
		tmove = from | (wking<<16);
		pinned = pinned_on_king(from,black);
		if(pinned) {
			K_CHK(RU);
			K_CHK(LD);
			K_CHK(LU);
			K_CHK(RD);
			K_CHK(UU);
			K_CHK(DD);
			K_CHK(RR);
			K_CHK(LL);
		}
	} else {
		//direct pawn checks
		to = oking_sq + LU;
		from = to + UU;
		if(board[to] == empty) {
			if(board[from] == bpawn)
				*pmove++ = from | (to<<8) | (bpawn<<16);
			else if(board[from] == empty && rank(from) == RANK6) {
				from += UU;
				if(board[from] == bpawn)
					*pmove++ = from | (to<<8) | (bpawn<<16);
			}
		}
		to = oking_sq + LD;
		from = to + DD;
		if(board[to] == empty) {
			if(board[from] == bpawn)
				*pmove++ = from | (to<<8) | (bpawn<<16);
			else if(board[from] == empty && rank(from) == RANK6) {
				from += UU;
				if(board[from] == bpawn)
					*pmove++ = from | (to<<8) | (bpawn<<16);
			}
		}
		
		//pawn indirect checks
		current = plist[bpawn];
		while(current) {
			from = current->sq;
			pinned = pinned_on_king(from,white);
			if(pinned && pinned != UU) {
				to = from + DD;
				if(board[to] == empty) {
					if(rank(to) != RANK1 && rank(to) != RANK8) {
						if(pinned || (sqatt[to - oking_sq].pieces & BPM))
							*pmove++ = from | (to<<8) | (bpawn<<16);
						if(rank(from) == RANK7) {
							to += DD;
							if(board[to] == empty)
								*pmove++ = from | (to<<8) | (bpawn<<16);
						}
					}
				}	
			}
			current = current->next;
		}
		//knight
		current = plist[bknight];
		while(current) {
			from = current->sq;
			tmove = from | (bknight<<16);
			pinned = pinned_on_king(from,white);
			N_CHK(RRU);
			N_CHK(LLD);
			N_CHK(RUU);
			N_CHK(LDD);
			N_CHK(LLU);
			N_CHK(RRD);
			N_CHK(RDD);
			N_CHK(LUU);
			current = current->next;
		}
		//bishop
		current = plist[bbishop];
		while(current) {
			from = current->sq;
			tmove = from | (bbishop<<16);
			pinned = pinned_on_king(from,white);
			BRQ_CHK(bishop,RU);
			BRQ_CHK(bishop,LD);
			BRQ_CHK(bishop,LU);
			BRQ_CHK(bishop,RD);
			current = current->next;
		}
		
		//rook
		current = plist[brook];
		while(current) {
			from = current->sq;
			tmove = from | (brook<<16);
			pinned = pinned_on_king(from,white);
			BRQ_CHK(rook,UU);
			BRQ_CHK(rook,DD);
			BRQ_CHK(rook,RR);
			BRQ_CHK(rook,LL);
			current = current->next;
		}
		
		//queen
		current = plist[bqueen];
		while(current) {
			from = current->sq;
			tmove = from | (bqueen<<16);
			pinned = pinned_on_king(from,white);
			BRQ_CHK(queen,RU);
			BRQ_CHK(queen,LD);
			BRQ_CHK(queen,LU);
			BRQ_CHK(queen,RD);
			BRQ_CHK(queen,UU);
			BRQ_CHK(queen,DD);
			BRQ_CHK(queen,RR);
			BRQ_CHK(queen,LL);
			current = current->next;
		}
		
		
		//king moves
		from = plist[bking]->sq;
		tmove = from | (bking<<16);
		pinned = pinned_on_king(from,white);
		if(pinned) {
			K_CHK(RU);
			K_CHK(LD);
			K_CHK(LU);
			K_CHK(RD);
			K_CHK(UU);
			K_CHK(DD);
			K_CHK(RR);
			K_CHK(LL);
		}
	}

	/*count*/
	pstack->count += int(pmove - spmove);
}
/*
incremental move generator
*/
MOVE SEARCHER::get_move() {
	register MOVE move;
	register int i,start;
	register int* pscore;
	if(pstack->gen_status == GEN_START) {
		pstack->current_index = 0;
		pstack->count = 0;
		pstack->gen_status = GEN_HASHM;
		pstack->losing_start = -1;
	}
DO_AGAIN:
	while(pstack->current_index >= pstack->count 
		&& pstack->gen_status <= GEN_LOSCAPS) {
        
		if(pstack->gen_status == GEN_HASHM) {
			if(hply >= 1 && hstack[hply - 1].checks) {
				gen_evasions();
				pstack->sortm = 1;
				for(i = 0; i < pstack->count;i++) {
					move = pstack->move_st[i];
					pscore = &pstack->score_st[i];
					
					if(move == pstack->hash_move)
						*pscore = 10000;
					else if(move == pstack->killer[0])
						*pscore = 90;
					else if(ply >= 2 && move == (pstack-2)->killer[0])
						*pscore = 85;
					else if(move == pstack->killer[1])
						*pscore = 80;
					else if(ply >= 2 && move == (pstack-2)->killer[1])
						*pscore = 75;
					else if(is_cap_prom(move)) {
						*pscore = see(move);
						if(*pscore < 0)
							*pscore -= (MAX_NUMB >> 1);
					} else {
						*pscore = (history[player][MV8866(move)] << 6)  + (MAX_MOVES - i) - MAX_NUMB;
					}
				}
				pstack->gen_status = GEN_END;
			} else {
				pstack->sortm = 0;
				if(pstack->hash_move) {
					pstack->score_st[pstack->count] = 10000;
					pstack->move_st[pstack->count++] = pstack->hash_move;
				}
			}
		} else if(pstack->gen_status == GEN_CAPS) {
			start = pstack->count;
			gen_caps();
			pstack->sortm = 0;
			for(i = start; i < pstack->count;i++) {
				move = pstack->move_st[i];
				
				if(move == pstack->hash_move)
					pstack->score_st[i] = -MAX_NUMB;
				else
                    pstack->score_st[i] = see(pstack->move_st[i]);
			}
			for(i = start; i < pstack->count;i++) {
				pstack->sort(i,pstack->count);
				if(pstack->score_st[i] < 0) {
					pstack->losing_start = i;
                    pstack->losing_end   = pstack->count;
				    pstack->count = i;
				    break;
				}
			}
        } else if(pstack->gen_status == GEN_KILLERS) {
			if(pstack->losing_start != -1) {
				pstack->current_index = pstack->losing_end;
				pstack->count = pstack->losing_end;
			}
			pstack->sortm = 0;
			move = pstack->killer[0];
			if(move 
				&& move != pstack->hash_move
				&& is_legal_fast(move)
				) {
				pstack->score_st[pstack->count] = 2000;
				pstack->move_st[pstack->count++] = move;
			}
			move = (pstack - 2)->killer[0];
			if(ply >= 2 
				&& move 
				&& move != pstack->hash_move
				&& is_legal_fast(move)
				) {
				pstack->score_st[pstack->count] = 1500;
				pstack->move_st[pstack->count++] = move;
			}
			move = pstack->killer[1];
			if(move 
				&& move != pstack->hash_move
				&& (ply < 2 || move != (pstack - 2)->killer[0])
				&& is_legal_fast(move)
				) {
				pstack->score_st[pstack->count] = 1000;
				pstack->move_st[pstack->count++] = move;
			}
			move = (pstack - 2)->killer[1];
			if(ply >= 2 
				&& move 
				&& move != pstack->hash_move
				&& move != pstack->killer[0] 
				&& move != (pstack - 2)->killer[0] 
				&& is_legal_fast(move)
				) {
				pstack->score_st[pstack->count] = 500;
				pstack->move_st[pstack->count++] = move;
			}
			
		} else if(pstack->gen_status == GEN_NONCAPS) {
			start = pstack->count;
			gen_noncaps();
			pstack->sortm = 2;
			for(int i = start; i < pstack->count;i++) {
				move = pstack->move_st[i];
				if(move == pstack->hash_move
					|| (move == pstack->killer[0]) 
                    || (move == pstack->killer[1]) 
					|| (ply >= 2 && (move == (pstack - 2)->killer[0] || move == (pstack - 2)->killer[1])) 
					) {
					pstack->score_st[i] = -MAX_NUMB;
				} else
					pstack->score_st[i] = (history[player][MV8866(move)] << 6) + (MAX_MOVES - i);
			}
		} else if(pstack->gen_status == GEN_LOSCAPS) {
			if(pstack->losing_start != -1) { 
				pstack->current_index = pstack->losing_start;
				pstack->count = pstack->losing_end;
				pstack->sortm = 1;
			}
		}
		pstack->gen_status++;
	}
	
	if(pstack->current_index >= pstack->count)
		return 0;
	
	if(pstack->sortm)
		pstack->sort(pstack->current_index,pstack->count);

	if(pstack->score_st[pstack->current_index] == -MAX_NUMB) {
		pstack->current_index = pstack->count;
		goto DO_AGAIN;
	}

	if(!(hply >= 1 && hstack[hply - 1].checks) 
	     && in_check(pstack->move_st[pstack->current_index])) {
		pstack->current_index++;
		goto DO_AGAIN;
	}

	pstack->current_move = pstack->move_st[pstack->current_index];
	pstack->current_index++;
	return pstack->current_move;
}
/*
qsearch move generator
*/
MOVE SEARCHER::get_qmove() {
    MOVE* pmove;
	int *pscore,lcount;
	if(pstack->gen_status == GEN_START) {
		pstack->current_index = 0;
		pstack->count = 0;
		pstack->gen_status = GEN_CAPS;
	}
DO_AGAIN:
	while(pstack->current_index >= pstack->count 
		&& pstack->gen_status <= GEN_QNONCAPS) {
		
		if(pstack->gen_status == GEN_CAPS) {
			if(hply >= 1 && hstack[hply - 1].checks) {
				gen_evasions();
			    pstack->sortm = 1;
				for(int i = 0; i < pstack->count;i++) {
					pmove = &pstack->move_st[i];
					pscore = &pstack->score_st[i];
					
				    if(is_cap_prom(*pmove)) {
						*pscore = see(*pmove);
						if(*pscore < 0)
							*pscore -= (MAX_NUMB >> 1);
					} else {
						*pscore = (history[player][MV8866(*pmove)] << 6)  + (MAX_MOVES - i) - MAX_NUMB;
					}
				}
				pstack->gen_status = GEN_END;
			} else {
				lcount = 0;
			    gen_caps();
				pstack->sortm = 1;
				for(int i = 0; i < pstack->count;i++) {
					pmove = &pstack->move_st[i];
					pscore = &pstack->score_st[i];
					*pscore = see(*pmove);
					if(*pscore >= 0) {
						pstack->move_st[lcount] = *pmove;
						pstack->score_st[lcount] = *pscore;
						lcount++;
					}
				}
				pstack->count = lcount;
			}
		} else if(pstack->gen_status == GEN_QNONCAPS) {
			
            if(pstack->qcheck_depth > 0) {
				lcount = pstack->count;
				gen_checks();
				pstack->sortm = 0;
				for(int i = lcount; i < pstack->count;i++) {
					pmove = &pstack->move_st[i];
					pscore = &pstack->score_st[i];
					if((*pscore = see(*pmove)) == 0) {
						pstack->move_st[lcount] = *pmove;
						pstack->score_st[lcount] = *pscore;
						lcount++;
					}
				}
				pstack->count = lcount;
			}
       
		}
		pstack->gen_status++;
	}
	
	if(pstack->current_index >= pstack->count)
		return 0;

	if(pstack->sortm)
		pstack->sort(pstack->current_index,pstack->count);

	if(!(hply >= 1 && hstack[hply - 1].checks) 
	     && in_check(pstack->move_st[pstack->current_index])) {
		 pstack->current_index++;
		 goto DO_AGAIN;
	}

	pstack->current_move = pstack->move_st[pstack->current_index];
	pstack->current_index++;
	return pstack->current_move;
}
