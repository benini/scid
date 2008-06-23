#include "glaurung.h"

struct hashentry_t {
  hashkey_t key;
  uint32 data;
  int16 score, depth;
};

inline static int score(hashentry_t *h) {
  return h->score;
}

inline static int depth(hashentry_t *h) {
  return h->depth;
}

inline static move_t move(hashentry_t *h) {
  return (h->data)&0x1FFFF;
}

inline static int type(hashentry_t *h) {
  return ((h->data)>>19)&0x3;
}

inline static int mate_threat(hashentry_t *h) {
  return ((h->data)>>21)&0x1;
}

inline static int generation(hashentry_t *h) {
  return ((h->data)>>22);
}

static unsigned TT_size = 0;
static hashentry_t *TT;
static uint8 Generation = 0;
static unsigned HashWrites = 0;

void free_tt(void) {
  free(TT);
}

void clear_tt(void) {
  memset(TT, 0, TT_size * 4 * sizeof(hashentry_t));
}

void init_tt(unsigned size) {
  unsigned new_size;
//  for(new_size=1024; new_size*4*(sizeof(hashentry_t))<=(size<<20); new_size*=2);
// Pocket PC : Hash defined in kB, not MB
  for(new_size=1024; new_size*4*(sizeof(hashentry_t))<=(size<<10); new_size*=2);
  new_size /= 2;
  if(new_size != TT_size) {
    TT_size = new_size;
    free(TT);
    TT = (hashentry_t *)malloc(TT_size * 4 * sizeof(hashentry_t));
    clear_tt();
  }
}

void store_tt(const position_t *pos, int value, int depth, move_t mv,
              int type, int mthreat) {
  hashentry_t *h, *replace = NULL;
  int i;
  if(mv == NOMOVE) mv = 0;
  h = replace = TT + (pos->key & (TT_size - 1)) * 4;
  for(i = 0; i < 4; i++) {
    if((h+i)->key == pos->key) {
      if(!mv) mv = move(h+i);
      (h+i)->data = (mv&0x1FFFF)|(type<<19)|(mthreat<<21)|(Generation<<22);
      (h+i)->score = value; (h+i)->depth = depth;
      return;
    }
    if(generation(replace) == Generation) {
      if(generation(h+i) != Generation) replace = h+i;
      else if((h+i)->depth < replace->depth) replace = h+i;
    }
    else if(generation(h+i) != Generation && (h+i)->depth < replace->depth)
      replace = h+i;
  }
  replace->key = pos->key;
  replace->data = (mv&0x1FFFF)|(type<<19)|(mthreat<<21)|(Generation<<22);
  replace->score = value; replace->depth = depth;
  HashWrites++;
}
              
int retrieve_tt(const position_t *pos, int *alpha, int *beta, int d, move_t *m,
                int *mthreat, int *nullmove) {
  hashentry_t *h = TT + (pos->key&(TT_size-1)) * 4;
  int t, v, found = 0;
  for(t = 0; t < 4; t++)
    if((h+t)->key == pos->key) {
      h = h + t; found = 1; break;
    }
  if(!found) {
    *mthreat = 0; *m = 0; return 0;
  }
  t = type(h);
  v = score(h);
  if((t&UPPER_BOUND) && v < *beta) *nullmove = 0;
  if(depth(h) >= d) {
    if((t&LOWER_BOUND) && v > *alpha) *alpha = v;
    if((t&UPPER_BOUND) && v < *beta) *beta = v;
  }
  *m = move(h); 
  *mthreat = mate_threat(h);
  return 1;
}

void tt_new_search(void) {
  Generation++; HashWrites = 0;
}

int hashfull(void) {
  double N = (double)TT_size * 4.0;
  return (int)(1000 * (1 - exp(HashWrites * log(1.0 - 1.0/N))));
}
