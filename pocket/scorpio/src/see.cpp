#include "scorpio.h"

#define AddSlider(strt,stp,wrb,brb) {\
	sq = strt + stp;\
	while(board[sq] == empty) sq += stp;\
    if(sq != from) {\
       switch(board[sq]) {\
         case wqueen:\
         case wrb:\
		     w_atkers[w_atks++] = sq;\
		     break;\
         case bqueen:\
         case brb:\
		     b_atkers[b_atks++] = sq;\
		     break;\
	   }\
	}\
}

#define AddHiddenAttacker(strt) {\
    step = sqatt[strt - to].step;\
    switch(step) {\
       case UU:\
       case DD:\
       case RR:\
       case LL:\
	      AddSlider(strt,step,wrook,brook);\
	      break;\
       case RU:\
       case RD:\
       case LU:\
       case LD:\
	      AddSlider(strt,step,wbishop,bbishop);\
	      break;\
	}\
}

static const int piece_see_v[15] = {0,99, 9, 5, 3, 3, 1,99, 9, 5, 3, 3, 1,0};

int SEARCHER::see(MOVE move) {
	int list[32],n;
	int from = m_from(move),to = m_to(move),sq,score;
	int w_atkers[16],b_atkers[16];
	int w_atks = 0,b_atks = 0;
	int w_count , b_count;
	int col,atkd_val;
	int i,bi,bv,v,step,temp;

    PLIST current;
    /*collect attackers*/
	if (board[to - RU] == wpawn && from != (to - RU)) {
		w_atkers[w_atks++] = to - RU;
	}
	if (board[to - LU] == wpawn && from != (to - LU)) {
		w_atkers[w_atks++] = to - LU;
	}
	if (board[to - RD] == bpawn && from != (to - RD)) {
		b_atkers[b_atks++] = to - RD;
	}
	if (board[to - LD] == bpawn && from != (to - LD)) {
		b_atkers[b_atks++] = to - LD;
	}
	current = plist[wknight];
	while (current) {
		sq = current->sq;
		if (sqatt[to - sq].pieces & NM) {
			if(sq != from)
				w_atkers[w_atks++] = sq;
		}
		current = current->next;
	}

	current = plist[bknight];
	while (current) {
		sq = current->sq;
		if (sqatt[to - sq].pieces & NM) {
			if(sq != from)
				b_atkers[b_atks++] = sq;
		}
		current = current->next;
	}
	AddSlider(to,UU,wrook,brook);
	AddSlider(to,DD,wrook,brook);
	AddSlider(to,RR,wrook,brook);
	AddSlider(to,LL,wrook,brook);
	AddSlider(to,RU,wbishop,bbishop);
	AddSlider(to,LU,wbishop,bbishop);
	AddSlider(to,RD,wbishop,bbishop);
	AddSlider(to,LD,wbishop,bbishop);

	sq = plist[wking]->sq;
	if (sq != from && (sqatt[to - sq].pieces & KM)) {
		w_atkers[w_atks++] = sq;
	}
	sq = plist[bking]->sq;
	if (sq != from && (sqatt[to - sq].pieces & KM)) {
		b_atkers[b_atks++] = sq;
	}

	/*we start by capturing*/
	score = piece_see_v[m_capture(move)];
	atkd_val = piece_see_v[m_piece(move)];
	col = invert(COLOR(m_piece(move)));
	if(col == opponent)
		AddHiddenAttacker(from);

	list[0] = score;
	n = 1;
	w_count  = 0;
    b_count  = 0;
	
	while(1) {
		if((col == white && w_count == w_atks) || 
		   (col == black && b_count == b_atks) )
			break;
		
		list[n] = -list[n-1] + atkd_val; 
		n++;
		
		if(col == white) {
			/*get smallest attacker to the front*/
			bi = w_count;
			bv = piece_see_v[board[w_atkers[bi]]];
			
			for(i = w_count + 1;i < w_atks;i++) {
				v = piece_see_v[board[w_atkers[i]]]; 
				if(v < bv) {
					bi = i;
					bv = v;
				}
			}
			if(bi != w_count) {
				temp = w_atkers[bi];
				w_atkers[bi] = w_atkers[w_count];
				w_atkers[w_count] = temp;
			}
			/*add hidden attacker*/
			sq = w_atkers[w_count];
			AddHiddenAttacker(sq);

			atkd_val = bv;
			col = black;
			w_count++;
		} else {
			/*get smallest attacker to the front*/
			bi = b_count;
			bv = piece_see_v[board[b_atkers[bi]]];
			
			for(i = b_count + 1;i < b_atks;i++) {
				v = piece_see_v[board[b_atkers[i]]]; 
				if(v < bv) {
					bi = i;
					bv = v;
				}
			}
			if(bi != b_count) {
				temp = b_atkers[bi];
				b_atkers[bi] = b_atkers[b_count];
				b_atkers[b_count] = temp;
			}
			/*add hidden attacker*/
			sq = b_atkers[b_count];
			AddHiddenAttacker(sq);


			atkd_val = bv;
			col = white;
			b_count++;
		}
	}

	while(--n)
        list[n-1] = min(-list[n], list[n-1]);

	score = list[0];

	return (100 * score);
}
