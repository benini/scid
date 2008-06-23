#include "glaurung.h"
/*
#define NUM_OF_LEARN_ENTRIES 16384

struct learn_entry_t {
  hashkey_t key;
  move_t move, pondermove;
  int timestamp, time;
  uint16 depth;
  int16 score;
  uint8 pad[4];
};

static learn_entry_t LearnTable[NUM_OF_LEARN_ENTRIES];

void clear_learning(void) {
  memset(LearnTable, 0, NUM_OF_LEARN_ENTRIES * sizeof(learn_entry_t));
}

void init_learning(void) {
  FILE *f = fopen("learn.bin", "rb");
  uint8 *c = (uint8 *)LearnTable;
  unsigned i;
  clear_learning();
  if(f != NULL) {
    for(i = 0; i < NUM_OF_LEARN_ENTRIES * sizeof(learn_entry_t); i++) {
      *c = fgetc(f); c++;
    }
    fclose(f);
  }
}

void save_learning(void) {
  FILE *f = fopen("learn.bin", "w");
  uint8 *c = (uint8 *)LearnTable;
  unsigned i;
  if(f != NULL) {
    for(i = 0; i < NUM_OF_LEARN_ENTRIES * sizeof(learn_entry_t); i++) {
      fputc(*c, f); c++;
    }
    fclose(f);
  }
}

void store_learning_data(hashkey_t key, move_t move, move_t pmove,
                         int time, int depth, int score) {
  int index = (key & (NUM_OF_LEARN_ENTRIES - 1));
  LearnTable[index].key = key;
  LearnTable[index].move = move;
  LearnTable[index].pondermove = pmove;
  LearnTable[index].timestamp = get_time();
  LearnTable[index].time = time;
  LearnTable[index].depth = depth;
  LearnTable[index].score = score;
}

static int eval_is_symmetric(void) {
  return (Options->ks_weight[WHITE] == Options->ks_weight[BLACK]);
}

int get_learning_data(hashkey_t key, int depth, int ply,
                      move_t *move, move_t *pmove, int *score) {
  int index = (key & (NUM_OF_LEARN_ENTRIES - 1));
  if(LearnTable[index].key == key && 
     (ply % 2 == 0 || eval_is_symmetric()) &&
     depth <= (LearnTable[index].depth - 1) * PLY) {
    *move = LearnTable[index].move; *pmove = LearnTable[index].pondermove;
    *score = LearnTable[index].score;
    return 1;
  }
  else return 0;
}
    
int get_learning_data_at_root(hashkey_t key, int time, 
                              move_t *move, move_t *pmove) {
  int index = (key & (NUM_OF_LEARN_ENTRIES - 1));
  if(LearnTable[index].key == key && time <= LearnTable[index].time) {
    *move = LearnTable[index].move; *pmove = LearnTable[index].pondermove;
    return 1;
  }
  else return 0;
}
*/
