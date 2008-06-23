#include "glaurung.h"

static void init_tables(void) {
  int i;
  for(i=0; i<128; i++) PawnRank[WHITE][i] = PawnRank[BLACK][i^0x70] = rank(i);
}

static void init_bit_count(void) {
  int i, j, k;
  for(i = 0; i < 256; i++) {
    j = i;
    for(k = 0; j; k++, j &= j - 1);
    BitCount[i] = k;
  }
}

static void init_attack_data(void) {
  int sq, piece, tosq;
  const int *ptr;
  for(sq = 0; sq < 256; sq++) 
    AttackData_[sq].may_attack = AttackData_[sq].step = 0;
  for(sq = A1; sq <= H8; sq++) 
    for(piece = WP; piece <= BK; piece++) 
      for(ptr = Directions[piece]; *ptr; ptr++) 
        for(tosq=sq+(*ptr); !(tosq & 0x88); tosq+=(*ptr)) {
          AttackData[sq-tosq].step = *ptr;
          AttackData[sq-tosq].may_attack |= PieceMask[piece];
          if(!SLIDER(piece)) break;
        }
}

static void init_distance(void) {
  int sq1, sq2;
  for(sq1 = 0; sq1 < 128; sq1 = sq1 + 9 & ~8) 
    for(sq2 = 0; sq2 < 128; sq2 = sq2 + 9 & ~8) 
      Distance[sq1-sq2] = 
        Max(abs(file(sq1)-file(sq2)), abs(rank(sq1)-rank(sq2)));
}
                                  
static void init_psq_tables(void) {
  int i, j;
  for(j = BP; j <= BK; j++) 
    for(i = 0; i < 128; i = i + 9 & ~8) 
      PSqTables[j][i ^ 0x70] = PSqTables[j-8][i];
}

void init(void) {
#if defined(SMP)
  init_split_point_stack();
  init_threads(MaxNumOfThreads);
#else
  init_pawn_hash_table(1);
#endif
  init_bit_count();
  init_tables();
  init_mersenne();
  init_zobrist();
  init_psq_tables();
  init_attack_data();
  init_distance();
  init_tt(32);
  init_safety();
  define_uci_options();
  init_kpk();
  init_book(Book, "book.bin");
//   init_learning();
}
