#include "glaurung.h"

#define BOOK_KEY_MASK 0xFFFFFFFFFFFF0000ULL
#define BOOK_MOVE_MASK 0xFFFFULL

book_t Book[1];

static uint64 read_uint64(FILE *f) {
  int i;
  unsigned char c;
  uint64 result = 0;

  for(i = 7; i >= 0; i--) {
    c = fgetc(f);
    result += (uint64)(((uint64)c) << ((uint64)i*8ULL));
  }
  return result;
}
  
int init_book(book_t *b, const char filename[]) {
  struct stat fs;
  unsigned i, j;
  
  b->file = fopen(filename, "rb");
  if(b->file == NULL) {
    b->found = 0; b->is_active = 0; return 0;
  }
  b->found = 1; b->is_active = 1;
  stat(filename, &fs); b->size = fs.st_size;

  b->first_key = read_uint64(b->file) & BOOK_KEY_MASK;
  fseek(b->file, b->size - 16, SEEK_SET);
  b->last_key = read_uint64(b->file) & BOOK_KEY_MASK;

  // Seed random move generator for book moves:
  i = abs(get_time()) % 10000;
  for(j = 0; j < i; j++) genrand_int32();

  return 1;
}

void activate_book(book_t *b) {
  if(b->found) b->is_active = 1;
}

void deactivate_book(book_t *b) {
  b->is_active = 0;
}
  
void close_book(book_t *b) {
  if(b->file != NULL) fclose(b->file);
}

static int search_for_key(book_t *b, hashkey_t key) {
  int start, middle, end;
  hashkey_t k;

  start = 0;
  end = b->size/16 - 1;

  while(start < end) {
    middle = (start + end) / 2;
    fseek(b->file, 16 * middle, SEEK_SET);
    k = read_uint64(b->file) & BOOK_KEY_MASK;
    if(key <= k) end = middle; else start = middle + 1;
  }

  fseek(b->file, 16 * start, SEEK_SET);
  k = read_uint64(b->file) & BOOK_KEY_MASK;
  return (k == key)? start : -1;
}

static int find_book_moves(book_t *b, hashkey_t key, bookentry_t moves[]) {
  int i, n = 0;
  hashkey_t book_data, book_key;

  if(!b->found || !b->is_active) return 0;

  key &= BOOK_KEY_MASK;
  i = search_for_key(b, key);
  if(i == -1) return 0;
  fseek(b->file, i*16, SEEK_SET);

  do {
    book_data = read_uint64(b->file);
    book_key = book_data & BOOK_KEY_MASK;

    if(book_key == key) {
      moves[n].move = book_data & BOOK_MOVE_MASK;
      book_data = read_uint64(b->file);
      moves[n].score = (unsigned)(book_data & 0xFFFFFFFF);
      moves[n].factor = (unsigned)(book_data >> 32);
      n++; i++;
    }
  } while(book_key == key && i < b->size);
  return n;
}

static int CDECL compare(const void *a, const void *b) {
  bookentry_t *b1, *b2;
  b1 = (bookentry_t *)a; b2 = (bookentry_t *)b;
  if(b1->factor * b1->score < b2->factor * b2->score) return 1;
  else return -1;
}
  
static void sort_book_moves(bookentry_t moves[], int n) {
  qsort(moves, n, sizeof(bookentry_t), compare);
}

move_t pick_book_move(book_t *b, hashkey_t key) {
  bookentry_t moves[64];
  int n, i, r, s, sum;

  n = find_book_moves(b, key, moves);
  if(n == 0) return 0;
  sort_book_moves(moves, n);

  sum = 0;
  for(i = 0; i < n; i++) sum += moves[i].factor * moves[i].score;
  r = genrand_int32() % sum;
  s = 0;
  for(i = 0; i < n; i++) {
    s += moves[i].factor * moves[i].score;
    if(s > r) break;
  }

  // Ugly hack to handle promotions correctly: 
  if(PROMOTION(moves[i].move) == PAWN) moves[i].move |= (QUEEN << 14);

  return moves[i].move;
}
