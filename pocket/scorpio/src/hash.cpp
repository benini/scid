#include "scorpio.h"

static PHASH white_hash_tab = NULL;
static PHASH black_hash_tab = NULL;
static PPAWNHASH pawn_hash_tab = NULL;
static PEVALHASH eval_hash_tab = NULL;
static UBMP32 hash_tab_mask;
static UBMP32 pawn_hash_tab_mask;
static UBMP32 eval_hash_tab_mask;
static VOLATILE UBMP32 mh_probes,mh_hits;
static VOLATILE UBMP32 ph_probes,ph_hits;
static VOLATILE UBMP32 eh_probes,eh_hits;

void init_hash_tables() {
	reset_hash_tab(1 << 8);
    reset_eval_hash_tab(1 << 8);
	reset_pawn_hash_tab(1 << 8);
}

void reset_hash_tab(UBMP32 size) {
	hash_tab_mask = size - 1;
	if(white_hash_tab) delete[] white_hash_tab;
	if(black_hash_tab) delete[] black_hash_tab;
    white_hash_tab = new HASH[size];
	black_hash_tab = new HASH[size];
	memset(white_hash_tab,0,size * sizeof(HASH));
	memset(black_hash_tab,0,size * sizeof(HASH));
}

void reset_pawn_hash_tab(UBMP32 size) {
	pawn_hash_tab_mask = size - 1;
	if(pawn_hash_tab) delete[] pawn_hash_tab;
    pawn_hash_tab = new PAWNHASH[size];
	memset(pawn_hash_tab,0,size * sizeof(PAWNHASH));
}

void reset_eval_hash_tab(UBMP32 size) {
	eval_hash_tab_mask = size - 1;
	if(eval_hash_tab) delete[] eval_hash_tab;
    eval_hash_tab = new EVALHASH[size];
	memset(eval_hash_tab,0,size * sizeof(EVALHASH));
}

void clear_hash_tables() {
	memset(white_hash_tab,0,(hash_tab_mask + 1) * sizeof(HASH));
	memset(black_hash_tab,0,(hash_tab_mask + 1) * sizeof(HASH));
	memset(pawn_hash_tab,0,(pawn_hash_tab_mask + 1) * sizeof(PAWNHASH));
	memset(eval_hash_tab,0,(eval_hash_tab_mask + 1) * sizeof(EVALHASH));
}

void record_hash(int col,HASHKEY hash_key,int depth,int ply,
				 int flags,int score,MOVE move,int mate_threat
				 ) {
	
	register UBMP32 key = UBMP32(hash_key & hash_tab_mask);
	register PHASHREC hash_repd,hash_repa;
	
	if(score > WIN_SCORE) 
		score += WIN_PLY * (ply + 1);
	else if(score < -WIN_SCORE) 
		score -= WIN_PLY * (ply + 1);
	
	if(col == white) {
		hash_repd = PHASHREC(white_hash_tab + key);
		hash_repa = hash_repd + 1;
	} else {
		hash_repd = PHASHREC(black_hash_tab + key);
		hash_repa = hash_repd + 1;
	}

	if(depth >= hash_repd->depth
		|| age != ((hash_repd->flags >> 3) & AGE_MASK)
		) {
		if(hash_repd->depth >= hash_repa->depth) {
			*hash_repa = *hash_repd;
		}
		hash_repd->move = BMP32(move);
		hash_repd->score = BMP16(score);
		hash_repd->depth = BMP8(depth);
		hash_repd->flags = BMP8((flags - EXACT) | (mate_threat << 2) | (age << 3));
		hash_repd->hash_key = hash_key;
	} else {
		hash_repa->move = BMP32(move);
		hash_repa->score = BMP16(score);
		hash_repa->depth = BMP8(depth);
		hash_repa->flags = BMP8((flags - EXACT) | (mate_threat << 2) | (age << 3));
		hash_repa->hash_key = hash_key;
	}
	
}

int probe_hash(int col,HASHKEY hash_key,int depth,int ply,int& score,
			   MOVE& move,int alpha,int beta,int& mate_threat,int& h_depth
			   ) {
    
	register UBMP32 key = UBMP32(hash_key & hash_tab_mask);
    register int flags, avd_null = 0, hash_hit = 0;
	register PHASHREC hash_record;
	
	if(col == white) {
		hash_record = PHASHREC(white_hash_tab + key);
	} else {
		hash_record = PHASHREC(black_hash_tab + key);
	}
	
	mh_probes++;
	mh_hits++;
	
	for(int i = 0; i < 2; i++) {
		
		if(hash_record->hash_key == hash_key) {
			
			score = hash_record->score;
			if(score > WIN_SCORE) 
				score -= WIN_PLY * (ply + 1);
			else if(score < -WIN_SCORE) 
				score += WIN_PLY * (ply + 1);
			
			move = hash_record->move;
			mate_threat |= ((hash_record->flags >> 2) & 1);
			flags = (hash_record->flags & 3) + EXACT;
			h_depth = hash_record->depth;
			
			if(hash_record->depth >= depth) {
				if(flags == EXACT)
					return EXACT;
				else if(flags == LOWER) {
					if(score >= beta)
						return LOWER;
				}
				else if(flags == UPPER) {
					if(score <= alpha)
						return UPPER;
				}
			} 
			
			if(depth - 3 - 1 <= h_depth 
				&& score < beta 
				&& flags == UPPER)
				avd_null = 1;
			hash_hit = 1;
		}
		
		hash_record++;
	}
	
	if(avd_null)
		return AVOID_NULL;
	else if(hash_hit)
		return HASH_HIT;
	else {
		mh_hits--;
		return UNKNOWN;
	}
}

void record_pawn_hash(HASHKEY hash_key,int score,const PAWNREC& pawnrec) {
	register UBMP32 key = UBMP32(hash_key & pawn_hash_tab_mask);
	register PPAWNHASH pawn_hash = pawn_hash_tab + key; 
	
	pawn_hash->checksum = hash_key;
	pawn_hash->score = score;
	pawn_hash->pawnrec = pawnrec;
}
int probe_pawn_hash(HASHKEY hash_key,int& score,PAWNREC& pawnrec) {
	register UBMP32 key = UBMP32(hash_key & pawn_hash_tab_mask);
	register PPAWNHASH pawn_hash = pawn_hash_tab + key; 
	
	ph_probes++;
	if(pawn_hash->checksum == hash_key) {
		ph_hits++;
		score = pawn_hash->score;
		pawnrec = pawn_hash->pawnrec;
		return 1;
	}
	return 0;
}
void record_eval_hash(HASHKEY hash_key,int score,int lazy_score,const EVALREC& evalrec) {
	register UBMP32 key = UBMP32(hash_key & eval_hash_tab_mask);
	register PEVALHASH eval_hash = eval_hash_tab + key; 
	
	eval_hash->checksum = hash_key;
	eval_hash->score = score;
    eval_hash->lazy_score = lazy_score;
	eval_hash->evalrec = evalrec;
}
int probe_eval_hash(HASHKEY hash_key,int& score,int& lazy_score,EVALREC& evalrec) {
	register UBMP32 key = UBMP32(hash_key & eval_hash_tab_mask);
	register PEVALHASH eval_hash = eval_hash_tab + key; 
	
	eh_probes++;
	if(eval_hash->checksum == hash_key) {
		eh_hits++;
		score = eval_hash->score;
		lazy_score = eval_hash->lazy_score;
		evalrec = eval_hash->evalrec;
		return 1;
	}
	return 0;
}
void clear_hash_stat() {
	mh_probes = mh_hits = 0;
    ph_probes = ph_hits = 0;
	eh_probes = eh_hits = 0;
}
void print_hash_stat() {
	send_msg("hit rate for tables: mht = %d pht = %d eht = %d\n",
		(mh_hits * 100) / (mh_probes + 1),
		(ph_hits * 100) / (ph_probes + 1),
		(eh_hits * 100) / (eh_probes + 1));
}
