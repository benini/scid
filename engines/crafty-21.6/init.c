#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "chess.h"
#include "data.h"
#if defined(UNIX) || defined(AMIGA)
#  include <unistd.h>
#  include <sys/types.h>
#endif
#if defined(UNIX)
#  include <sys/stat.h>
#endif
#include "epdglue.h"
#if defined(NT_i386)
#  include <fcntl.h>    /* needed for definition of "_O_BINARY" */
#endif

int init_r90[64] = {
  7, 15, 23, 31, 39, 47, 55, 63,
  6, 14, 22, 30, 38, 46, 54, 62,
  5, 13, 21, 29, 37, 45, 53, 61,
  4, 12, 20, 28, 36, 44, 52, 60,
  3, 11, 19, 27, 35, 43, 51, 59,
  2, 10, 18, 26, 34, 42, 50, 58,
  1, 9, 17, 25, 33, 41, 49, 57,
  0, 8, 16, 24, 32, 40, 48, 56
};

int init_ur90[64] = {
  56, 48, 40, 32, 24, 16, 8, 0,
  57, 49, 41, 33, 25, 17, 9, 1,
  58, 50, 42, 34, 26, 18, 10, 2,
  59, 51, 43, 35, 27, 19, 11, 3,
  60, 52, 44, 36, 28, 20, 12, 4,
  61, 53, 45, 37, 29, 21, 13, 5,
  62, 54, 46, 38, 30, 22, 14, 6,
  63, 55, 47, 39, 31, 23, 15, 7
};

int init_r45[64] = {
  0, 2, 5, 9, 14, 20, 27, 35,
  1, 4, 8, 13, 19, 26, 34, 42,
  3, 7, 12, 18, 25, 33, 41, 48,
  6, 11, 17, 24, 32, 40, 47, 53,
  10, 16, 23, 31, 39, 46, 52, 57,
  15, 22, 30, 38, 45, 51, 56, 60,
  21, 29, 37, 44, 50, 55, 59, 62,
  28, 36, 43, 49, 54, 58, 61, 63
};

int init_ur45[64] = {
  0, 8, 1, 16, 9, 2, 24, 17,
  10, 3, 32, 25, 18, 11, 4, 40,
  33, 26, 19, 12, 5, 48, 41, 34,
  27, 20, 13, 6, 56, 49, 42, 35,
  28, 21, 14, 7, 57, 50, 43, 36,
  29, 22, 15, 58, 51, 44, 37, 30,
  23, 59, 52, 45, 38, 31, 60, 53,
  46, 39, 61, 54, 47, 62, 55, 63
};

int init_l45[64] = {
  28, 21, 15, 10, 6, 3, 1, 0,
  36, 29, 22, 16, 11, 7, 4, 2,
  43, 37, 30, 23, 17, 12, 8, 5,
  49, 44, 38, 31, 24, 18, 13, 9,
  54, 50, 45, 39, 32, 25, 19, 14,
  58, 55, 51, 46, 40, 33, 26, 20,
  61, 59, 56, 52, 47, 41, 34, 27,
  63, 62, 60, 57, 53, 48, 42, 35
};

int init_ul45[64] = {
  7, 6, 15, 5, 14, 23, 4, 13,
  22, 31, 3, 12, 21, 30, 39, 2,
  11, 20, 29, 38, 47, 1, 10, 19,
  28, 37, 46, 55, 0, 9, 18, 27,
  36, 45, 54, 63, 8, 17, 26, 35,
  44, 53, 62, 16, 25, 34, 43, 52,
  61, 24, 33, 42, 51, 60, 32, 41,
  50, 59, 40, 49, 58, 48, 57, 56
};

int diagonal_length[64] = {
  1, 2, 2, 3, 3, 3, 4, 4,
  4, 4, 5, 5, 5, 5, 5, 6,
  6, 6, 6, 6, 6, 7, 7, 7,
  7, 7, 7, 7, 8, 8, 8, 8,
  8, 8, 8, 8, 7, 7, 7, 7,
  7, 7, 7, 6, 6, 6, 6, 6,
  6, 5, 5, 5, 5, 5, 4, 4,
  4, 4, 3, 3, 3, 2, 2, 1
};

/*
 *******************************************************************************
 *                                                                             *
 *   Initialize() performs routine initialization before anything else is      *
 *   attempted.                                                                *
 *                                                                             *
 *******************************************************************************
 */
void Initialize()
{
  int i, major, minor, id;
  TREE *tree;
  void *mem;
  int j;

  tree = shared->local[0];
  InitializeSharedData();
  i = 0;
  InitializeZeroMasks();
  InitializeMagic();
  InitializeSMP();
  InitializeMasks();
  InitializeRandomHash();
  InitializeAttackBoards();
  InitializePawnMasks();
  InitializePieceMasks();
  InitializeChessBoard(&tree->position[0]);
  InitializeKillers();
#if defined(NT_i386)
  _fmode = _O_BINARY;   /* set file mode binary to avoid text translation */
#endif

#if defined(EPD)
  EGInit();
#endif
  tree->last[0] = tree->move_list;
  tree->last[1] = tree->move_list;

  sprintf(log_filename, "%s/book.bin", book_path);
  book_file = fopen(log_filename, "rb+");
  if (!book_file) {
    book_file = fopen(log_filename, "rb");
    if (!book_file) {
      Print(128, "unable to open book file [%s/book.bin].\n", book_path);
      Print(128, "book is disabled\n");
    } else {
      Print(128, "unable to open book file [%s/book.bin] for \"write\".\n",
          book_path);
      Print(128, "learning is disabled\n");
    }
  }
  sprintf(log_filename, "%s/books.bin", book_path);
  normal_bs_file = fopen(log_filename, "rb");
  books_file = normal_bs_file;
  if (!normal_bs_file)
    Print(128, "unable to open book file [%s/books.bin].\n", book_path);
  sprintf(log_filename, "%s/bookc.bin", book_path);
  computer_bs_file = fopen(log_filename, "rb");
  if (computer_bs_file)
    Print(128, "found computer opening book file [%s/bookc.bin].\n", book_path);
  if (book_file) {
    int maj_min;

    fseek(book_file, -sizeof(int), SEEK_END);
    fread(&maj_min, 4, 1, book_file);
    major = BookIn32((unsigned char *) &maj_min);
    minor = major & 65535;
    major = major >> 16;
    if (major < 20 || (major == 20 && minor < 17)) {
      Print(4095, "\nERROR!  book.bin not made by version 20.17 or later\n");
      fclose(book_file);
      fclose(books_file);
      book_file = 0;
      books_file = 0;
    }
  }
  id = InitializeGetLogID();
  sprintf(log_filename, "%s/log.%03d", log_path, id);
  sprintf(history_filename, "%s/game.%03d", log_path, id);
  log_file = fopen(log_filename, "w");
  history_file = fopen(history_filename, "w+");
  if (!history_file) {
    printf("ERROR, unable to open game history file, exiting\n");
    CraftyExit(1);
  }
  cb_trans_ref = sizeof(HASH_ENTRY) * hash_table_size + 15;
  trans_ref = (HASH_ENTRY *) SharedMalloc(cb_trans_ref, 0);
  cb_pawn_hash_table = sizeof(PAWN_HASH_ENTRY) * pawn_hash_table_size + 15;
  pawn_hash_table = (PAWN_HASH_ENTRY *) SharedMalloc(cb_pawn_hash_table, 0);
  if (!trans_ref) {
    Print(128, "malloc() failed, not enough memory.\n");
    SharedFree(trans_ref);
    SharedFree(pawn_hash_table);
    hash_table_size = 0;
    pawn_hash_table_size = 0;
    log_hash = 0;
    log_pawn_hash = 0;
    trans_ref = 0;
    pawn_hash_table = 0;
  }
/*
 ************************************************************
 *                                                          *
 *   now for some NUMA work.  we need to allocate the       *
 *   local memory for each processor, but we can't touch it *
 *   here or it will be faulted in and be allocated on the  *
 *   curret CPU, which is not where it should be located    *
 *   for optimal NUMA performance.  ThreadInit() will do    *
 *   the actual initialization after each new process is    *
 *   created, so that the pages of local memory will be     *
 *   faulted in on the correct processor and use local      *
 *   node memory for optimal performance.                   *
 *                                                          *
 ************************************************************
 */
#if defined(_WIN32) || defined(_WIN64)
  ThreadMalloc((int) 0);
#else
  for (i = 0; i < CPUS; i++) {
    mem = SharedMalloc(MAX_BLOCKS_PER_CPU * ((sizeof(TREE) + 2047)) & ~2047, 0);
    for (j = 0; j < MAX_BLOCKS_PER_CPU; j++) {
      shared->local[i * MAX_BLOCKS_PER_CPU + j + 1] =
          (TREE *) ((long) mem + j * ((sizeof(TREE) + 2047) & ~2047));
    }
  }
  for (i = 0; i < MAX_BLOCKS_PER_CPU; i++) {
    memset((void *) shared->local[i + 1], 0, sizeof(TREE));
    shared->local[i + 1]->used = 0;
    shared->local[i + 1]->parent = (TREE *) - 1;
    LockInit(shared->local[i + 1]->lock);
  }
#endif
  shared->initialized_threads++;
  InitializeHashTables();
  hash_mask = (1 << log_hash) - 1;
  pawn_hash_mask = (1 << (log_pawn_hash)) - 1;

  InitializeEvaluation();
}

void InitializeAttackBoards(void)
{

  int i, j, frank, ffile, trank, tfile;
  int sq, lastsq;
  static const int knightsq[8] = { -17, -15, -10, -6, 6, 10, 15, 17 };
  static const int bishopsq[4] = { -9, -7, 7, 9 };
  static const int rooksq[4] = { -8, -1, 1, 8 };
  BITBOARD sqs;

/*
 initialize pawn attack boards
 */
  for (i = 0; i < 64; i++) {
    w_pawn_attacks[i] = 0;
    if (i < 56)
      for (j = 2; j < 4; j++) {
        sq = i + bishopsq[j];
        if ((abs(Rank(sq) - Rank(i)) == 1) && (abs(File(sq) - File(i)) == 1) &&
            (sq < 64) && (sq > -1))
          w_pawn_attacks[i] = w_pawn_attacks[i] | (BITBOARD) 1 << sq;
      }
    b_pawn_attacks[i] = 0;
    if (i > 7)
      for (j = 0; j < 2; j++) {
        sq = i + bishopsq[j];
        if ((abs(Rank(sq) - Rank(i)) == 1) && (abs(File(sq) - File(i)) == 1) &&
            (sq < 64) && (sq > -1))
          b_pawn_attacks[i] = b_pawn_attacks[i] | (BITBOARD) 1 << sq;
      }
  }
/*
 initialize knight attack board
 */
  for (i = 0; i < 64; i++) {
    knight_attacks[i] = 0;
    frank = Rank(i);
    ffile = File(i);
    for (j = 0; j < 8; j++) {
      sq = i + knightsq[j];
      if ((sq < 0) || (sq > 63))
        continue;
      trank = Rank(sq);
      tfile = File(sq);
      if ((abs(frank - trank) > 2) || (abs(ffile - tfile) > 2))
        continue;
      knight_attacks[i] = knight_attacks[i] | (BITBOARD) 1 << sq;
    }
  }
/*
 initialize bishop/queen attack boards and masks
 */
  for (i = 0; i < 64; i++) {
    for (j = 0; j < 4; j++) {
      sq = i;
      lastsq = sq;
      sq = sq + bishopsq[j];
      while ((abs(Rank(sq) - Rank(lastsq)) == 1) &&
          (abs(File(sq) - File(lastsq)) == 1) && (sq < 64) && (sq > -1)) {
        if (bishopsq[j] == 7)
          plus7dir[i] = plus7dir[i] | (BITBOARD) 1 << sq;
        else if (bishopsq[j] == 9)
          plus9dir[i] = plus9dir[i] | (BITBOARD) 1 << sq;
        else if (bishopsq[j] == -7)
          minus7dir[i] = minus7dir[i] | (BITBOARD) 1 << sq;
        else
          minus9dir[i] = minus9dir[i] | (BITBOARD) 1 << sq;
        lastsq = sq;
        sq = sq + bishopsq[j];
      }
    }
  }
  plus1dir[64] = 0;
  plus7dir[64] = 0;
  plus8dir[64] = 0;
  plus9dir[64] = 0;
  minus1dir[64] = 0;
  minus7dir[64] = 0;
  minus8dir[64] = 0;
  minus9dir[64] = 0;
/*
 initialize rook/queen attack boards
 */
  for (i = 0; i < 64; i++) {
    for (j = 0; j < 4; j++) {
      sq = i;
      lastsq = sq;
      sq = sq + rooksq[j];
      while ((((abs(Rank(sq) - Rank(lastsq)) == 1) &&
                  (abs(File(sq) - File(lastsq)) == 0)) ||
              ((abs(Rank(sq) - Rank(lastsq)) == 0) &&
                  (abs(File(sq) - File(lastsq)) == 1))) && (sq < 64) &&
          (sq > -1)) {
        if (rooksq[j] == 1)
          plus1dir[i] = plus1dir[i] | (BITBOARD) 1 << sq;
        else if (rooksq[j] == 8)
          plus8dir[i] = plus8dir[i] | (BITBOARD) 1 << sq;
        else if (rooksq[j] == -1)
          minus1dir[i] = minus1dir[i] | (BITBOARD) 1 << sq;
        else
          minus8dir[i] = minus8dir[i] | (BITBOARD) 1 << sq;
        lastsq = sq;
        sq = sq + rooksq[j];
      }
    }
  }
/*
 initialize king attack board
 */
  for (i = 0; i < 64; i++) {
    king_attacks[i] = 0;
    for (j = 0; j < 64; j++) {
      if (Distance(i, j) == 1)
        king_attacks[i] = king_attacks[i] | SetMask(j);
    }
  }
/*
 direction[sq1][sq2] gives the "move direction" to move from
 sq1 to sq2.  obstructed[sq1][sq2] gives a bit vector that indicates
 which squares must be unoccupied in order for <sq1> to attack <sq2>,
 assuming a sliding piece is involved.  to use this, you simply have
 to Or(obstructed[sq1][sq2],occupied_squares) and if the result is
 "0" then a sliding piece on sq1 would attack sq2 and vice-versa.
 */
  for (i = 0; i < 64; i++) {
    for (j = 0; j < 64; j++)
      obstructed[i][j] = (BITBOARD) - 1;
    sqs = plus1dir[i];
    while (sqs) {
      j = LSB(sqs);
      directions[i][j] = 1;
      obstructed[i][j] = plus1dir[i] ^ plus1dir[j - 1];
      sqs &= sqs - 1;
    }
    sqs = plus7dir[i];
    while (sqs) {
      j = LSB(sqs);
      directions[i][j] = 7;
      obstructed[i][j] = plus7dir[i] ^ plus7dir[j - 7];
      sqs &= sqs - 1;
    }
    sqs = plus8dir[i];
    while (sqs) {
      j = LSB(sqs);
      directions[i][j] = 8;
      obstructed[i][j] = plus8dir[i] ^ plus8dir[j - 8];
      sqs &= sqs - 1;
    }
    sqs = plus9dir[i];
    while (sqs) {
      j = LSB(sqs);
      directions[i][j] = 9;
      obstructed[i][j] = plus9dir[i] ^ plus9dir[j - 9];
      sqs &= sqs - 1;
    }
    sqs = minus1dir[i];
    while (sqs) {
      j = LSB(sqs);
      directions[i][j] = -1;
      obstructed[i][j] = minus1dir[i] ^ minus1dir[j + 1];
      sqs &= sqs - 1;
    }
    sqs = minus7dir[i];
    while (sqs) {
      j = LSB(sqs);
      directions[i][j] = -7;
      obstructed[i][j] = minus7dir[i] ^ minus7dir[j + 7];
      sqs &= sqs - 1;
    }
    sqs = minus8dir[i];
    while (sqs) {
      j = LSB(sqs);
      directions[i][j] = -8;
      obstructed[i][j] = minus8dir[i] ^ minus8dir[j + 8];
      sqs &= sqs - 1;
    }
    sqs = minus9dir[i];
    while (sqs) {
      j = LSB(sqs);
      directions[i][j] = -9;
      obstructed[i][j] = minus9dir[i] ^ minus9dir[j + 9];
      sqs &= sqs - 1;
    }
  }
}

void InitializeMagic(void)
{
  int i;

  int initmagicmoves_bitpos64_database[64] = {
    63, 0, 58, 1, 59, 47, 53, 2,
    60, 39, 48, 27, 54, 33, 42, 3,
    61, 51, 37, 40, 49, 18, 28, 20,
    55, 30, 34, 11, 43, 14, 22, 4,
    62, 57, 46, 52, 38, 26, 32, 41,
    50, 36, 17, 19, 29, 10, 13, 21,
    56, 45, 25, 31, 35, 16, 9, 12,
    44, 24, 15, 8, 23, 7, 6, 5
  };

  for (i = 0; i < 64; i++) {
    int squares[64];
    int numsquares = 0;
    BITBOARD temp = magic_bishop_mask[i];

    while (temp) {
      BITBOARD abit = temp & -temp;

      squares[numsquares++] =
          initmagicmoves_bitpos64_database[(abit *
              0x07EDD5E59A4E28C2ULL) >> 58];
      temp ^= abit;
    }
    for (temp = 0; temp < (((BITBOARD) (1)) << numsquares); temp++) {
      BITBOARD tempoccupied =
          InitializeMagicOccupied(squares, numsquares, temp);

      AttacksBishopNOMASK(i, tempoccupied) =
          InitializeMagicBishop(i, tempoccupied);
    }
  }
  for (i = 0; i < 64; i++) {
    int squares[64];
    int numsquares = 0;
    BITBOARD temp = magic_rook_mask[i];

    while (temp) {
      BITBOARD abit = temp & -temp;

      squares[numsquares++] =
          initmagicmoves_bitpos64_database[(abit *
              0x07EDD5E59A4E28C2ULL) >> 58];
      temp ^= abit;
    }
    for (temp = 0; temp < (((BITBOARD) (1)) << numsquares); temp++) {
      BITBOARD tempoccupied =
          InitializeMagicOccupied(squares, numsquares, temp);

      AttacksRookNOMASK(i, tempoccupied) = InitializeMagicRook(i, tempoccupied);
    }
  }
}

BITBOARD InitializeMagicBishop(int square, BITBOARD occupied)
{
  BITBOARD ret = 0;
  BITBOARD abit;
  BITBOARD abit2;
  BITBOARD rowbits = (((BITBOARD) 0xFF) << (8 * (square / 8)));

  abit = (((BITBOARD) (1)) << square);
  abit2 = abit;
  do {
    abit <<= 8 - 1;
    abit2 >>= 1;
    if (abit2 & rowbits)
      ret |= abit;
    else
      break;
  } while (abit && !(abit & occupied));
  abit = (((BITBOARD) (1)) << square);
  abit2 = abit;
  do {
    abit <<= 8 + 1;
    abit2 <<= 1;
    if (abit2 & rowbits)
      ret |= abit;
    else
      break;
  } while (abit && !(abit & occupied));
  abit = (((BITBOARD) (1)) << square);
  abit2 = abit;
  do {
    abit >>= 8 - 1;
    abit2 <<= 1;
    if (abit2 & rowbits)
      ret |= abit;
    else
      break;
  } while (abit && !(abit & occupied));
  abit = (((BITBOARD) (1)) << square);
  abit2 = abit;
  do {
    abit >>= 8 + 1;
    abit2 >>= 1;
    if (abit2 & rowbits)
      ret |= abit;
    else
      break;
  } while (abit && !(abit & occupied));
  return (ret);
}

BITBOARD InitializeMagicOccupied(int *squares, int numSquares,
    BITBOARD linoccupied)
{
  int i;
  BITBOARD ret = 0;

  for (i = 0; i < numSquares; i++)
    if (linoccupied & (((BITBOARD) (1)) << i))
      ret |= (((BITBOARD) (1)) << squares[i]);
  return (ret);
}

BITBOARD InitializeMagicRook(int square, BITBOARD occupied)
{
  BITBOARD ret = 0;
  BITBOARD abit;
  BITBOARD rowbits = (((BITBOARD) 0xFF) << (8 * (square / 8)));

  abit = (((BITBOARD) (1)) << square);
  do {
    abit <<= 8;
    ret |= abit;
  } while (abit && !(abit & occupied));
  abit = (((BITBOARD) (1)) << square);
  do {
    abit >>= 8;
    ret |= abit;
  } while (abit && !(abit & occupied));
  abit = (((BITBOARD) (1)) << square);
  do {
    abit <<= 1;
    if (abit & rowbits)
      ret |= abit;
    else
      break;
  } while (!(abit & occupied));
  abit = (((BITBOARD) (1)) << square);
  do {
    abit >>= 1;
    if (abit & rowbits)
      ret |= abit;
    else
      break;
  } while (!(abit & occupied));
  return (ret);
}

void InitializeChessBoard(SEARCH_POSITION * new_pos)
{
  int i;
  TREE *const tree = shared->local[0];

  if (strlen(initial_position)) {
    static char a1[80], a2[16], a3[16], a4[16], a5[16];
    static char *args[256] =
        { a1, a2, a3, a4, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5,
      a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5,
      a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5,
      a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5,
      a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5,
      a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5,
      a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5,
      a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5,
      a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5,
      a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5,
      a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5,
      a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5,
      a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5,
      a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5,
      a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5,
      a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5, a5
    };
    int nargs;

    nargs = ReadParse(initial_position, args, " ;");
    SetBoard(new_pos, nargs, args, 1);
  } else {
    for (i = 0; i < 64; i++)
      tree->pos.board[i] = none;
    new_pos->rule_50_moves = 0;
    wtm = 1;
/*
 place pawns
 */
    for (i = 0; i < 8; i++) {
      tree->pos.board[i + 8] = pawn;
      tree->pos.board[i + 48] = -pawn;
    }
/*
 place knights
 */
    tree->pos.board[B1] = knight;
    tree->pos.board[G1] = knight;
    tree->pos.board[B8] = -knight;
    tree->pos.board[G8] = -knight;
/*
 place bishops
 */
    tree->pos.board[C1] = bishop;
    tree->pos.board[F1] = bishop;
    tree->pos.board[C8] = -bishop;
    tree->pos.board[F8] = -bishop;
/*
 place rooks
 */
    tree->pos.board[A1] = rook;
    tree->pos.board[H1] = rook;
    tree->pos.board[A8] = -rook;
    tree->pos.board[H8] = -rook;
/*
 place queens
 */
    tree->pos.board[D1] = queen;
    tree->pos.board[D8] = -queen;
/*
 place kings
 */
    tree->pos.board[E1] = king;
    tree->pos.board[E8] = -king;
/*
 initialize castling status so all castling is legal.
 */
    new_pos->w_castle = 3;
    new_pos->b_castle = 3;
/*
 initialize 50 move counter.
 */
    new_pos->rule_50_moves = 0;
/*
 initialize enpassant status.
 */
    new_pos->enpassant_target = 0;
/*
 now, set the bit-boards.
 */
    SetChessBitBoards(new_pos);
  }
}

void SetChessBitBoards(SEARCH_POSITION * new_pos)
{
  int i;
  TREE *const tree = shared->local[0];

  tree->pos.hash_key = 0;
  tree->pos.pawn_hash_key = 0;
/*
 place pawns
 */
  tree->pos.w_pawn = 0;
  tree->pos.b_pawn = 0;
  for (i = 0; i < 64; i++) {
    if (tree->pos.board[i] == pawn) {
      tree->pos.w_pawn = tree->pos.w_pawn | SetMask(i);
      tree->pos.hash_key = tree->pos.hash_key ^ w_pawn_random[i];
      tree->pos.pawn_hash_key = tree->pos.pawn_hash_key ^ w_pawn_random[i];
    }
    if (tree->pos.board[i] == -pawn) {
      tree->pos.b_pawn = tree->pos.b_pawn | SetMask(i);
      tree->pos.hash_key = tree->pos.hash_key ^ b_pawn_random[i];
      tree->pos.pawn_hash_key = tree->pos.pawn_hash_key ^ b_pawn_random[i];
    }
  }
/*
 place knights
 */
  tree->pos.w_knight = 0;
  tree->pos.b_knight = 0;
  for (i = 0; i < 64; i++) {
    if (tree->pos.board[i] == knight) {
      tree->pos.w_knight = tree->pos.w_knight | SetMask(i);
      tree->pos.hash_key = tree->pos.hash_key ^ w_knight_random[i];
    }
    if (tree->pos.board[i] == -knight) {
      tree->pos.b_knight = tree->pos.b_knight | SetMask(i);
      tree->pos.hash_key = tree->pos.hash_key ^ b_knight_random[i];
    }
  }
/*
 place bishops
 */
  tree->pos.w_bishop = 0;
  tree->pos.b_bishop = 0;
  for (i = 0; i < 64; i++) {
    if (tree->pos.board[i] == bishop) {
      tree->pos.w_bishop = tree->pos.w_bishop | SetMask(i);
      tree->pos.hash_key = tree->pos.hash_key ^ w_bishop_random[i];
    }
    if (tree->pos.board[i] == -bishop) {
      tree->pos.b_bishop = tree->pos.b_bishop | SetMask(i);
      tree->pos.hash_key = tree->pos.hash_key ^ b_bishop_random[i];
    }
  }
/*
 place rooks
 */
  tree->pos.w_rook = 0;
  tree->pos.b_rook = 0;
  for (i = 0; i < 64; i++) {
    if (tree->pos.board[i] == rook) {
      tree->pos.w_rook = tree->pos.w_rook | SetMask(i);
      tree->pos.hash_key = tree->pos.hash_key ^ w_rook_random[i];
    }
    if (tree->pos.board[i] == -rook) {
      tree->pos.b_rook = tree->pos.b_rook | SetMask(i);
      tree->pos.hash_key = tree->pos.hash_key ^ b_rook_random[i];
    }
  }
/*
 place queens
 */
  tree->pos.w_queen = 0;
  tree->pos.b_queen = 0;
  for (i = 0; i < 64; i++) {
    if (tree->pos.board[i] == queen) {
      tree->pos.w_queen = tree->pos.w_queen | SetMask(i);
      tree->pos.hash_key = tree->pos.hash_key ^ w_queen_random[i];
    }
    if (tree->pos.board[i] == -queen) {
      tree->pos.b_queen = tree->pos.b_queen | SetMask(i);
      tree->pos.hash_key = tree->pos.hash_key ^ b_queen_random[i];
    }
  }
/*
 place kings
 */
  tree->pos.white_king = -1;
  tree->pos.black_king = -1;
  for (i = 0; i < 64; i++) {
    if (tree->pos.board[i] == king) {
      tree->pos.white_king = i;
      tree->pos.hash_key = tree->pos.hash_key ^ w_king_random[i];
    }
    if (tree->pos.board[i] == -king) {
      tree->pos.black_king = i;
      tree->pos.hash_key = tree->pos.hash_key ^ b_king_random[i];
    }
  }
  if (new_pos->enpassant_target)
    HashEP(new_pos->enpassant_target, tree->pos.hash_key);
  if (!(new_pos->w_castle & 1))
    HashCastleW(0, tree->pos.hash_key);
  if (!(new_pos->w_castle & 2))
    HashCastleW(1, tree->pos.hash_key);
  if (!(new_pos->b_castle & 1))
    HashCastleB(0, tree->pos.hash_key);
  if (!(new_pos->b_castle & 2))
    HashCastleB(1, tree->pos.hash_key);
/*
 initialize combination boards that show multiple pieces.
 */
  tree->pos.bishops_queens =
      tree->pos.w_bishop | tree->pos.w_queen | tree->pos.b_bishop | tree->pos.
      b_queen;
  tree->pos.rooks_queens =
      tree->pos.w_rook | tree->pos.w_queen | tree->pos.b_rook | tree->pos.
      b_queen;
  tree->pos.w_occupied =
      tree->pos.w_pawn | tree->pos.w_knight | tree->pos.w_bishop | tree->pos.
      w_rook | tree->pos.w_queen | SetMask(tree->pos.white_king);
  tree->pos.b_occupied =
      tree->pos.b_pawn | tree->pos.b_knight | tree->pos.b_bishop | tree->pos.
      b_rook | tree->pos.b_queen | SetMask(tree->pos.black_king);
/*
 initialize black/white piece counts.
 */
  tree->pos.white_pieces = 0;
  tree->pos.white_pawns = 0;
  tree->pos.black_pieces = 0;
  tree->pos.black_pawns = 0;

//TLR
//  tree->pos.majors = 0;
//  tree->pos.minors = 0;
  tree->pos.num_w_knights = 0;
  tree->pos.num_b_knights = 0;
  tree->pos.num_w_bishops = 0;
  tree->pos.num_b_bishops = 0;
  tree->pos.num_w_rooks = 0;
  tree->pos.num_b_rooks = 0;
  tree->pos.num_w_queens = 0;
  tree->pos.num_b_queens = 0;

  tree->pos.material_evaluation = 0;
  for (i = 0; i < 64; i++) {
    switch (tree->pos.board[i]) {
    case pawn:
      tree->pos.material_evaluation += pawn_value;
      tree->pos.white_pawns += pawn_v;
      break;
    case knight:
      tree->pos.material_evaluation += knight_value;
      tree->pos.white_pieces += knight_v;
      tree->pos.num_w_knights++;
      break;
    case bishop:
      tree->pos.material_evaluation += bishop_value;
      tree->pos.white_pieces += bishop_v;
      tree->pos.num_w_bishops++;
      break;
    case rook:
      tree->pos.material_evaluation += rook_value;
      tree->pos.white_pieces += rook_v;
      tree->pos.num_w_rooks++;
      break;
    case queen:
      tree->pos.material_evaluation += queen_value;
      tree->pos.white_pieces += queen_v;
      tree->pos.num_w_queens++;
      break;
    case -pawn:
      tree->pos.material_evaluation -= pawn_value;
      tree->pos.black_pawns += pawn_v;
      break;
    case -knight:
      tree->pos.material_evaluation -= knight_value;
      tree->pos.black_pieces += knight_v;
      tree->pos.num_b_knights++;
      break;
    case -bishop:
      tree->pos.material_evaluation -= bishop_value;
      tree->pos.black_pieces += bishop_v;
      tree->pos.num_b_bishops++;
      break;
    case -rook:
      tree->pos.material_evaluation -= rook_value;
      tree->pos.black_pieces += rook_v;
      tree->pos.num_b_rooks++;
      break;
    case -queen:
      tree->pos.material_evaluation -= queen_value;
      tree->pos.black_pieces += queen_v;
      tree->pos.num_b_queens++;
      break;
    default:
      ;
    }
  }
  TotalPieces = PopCnt(Occupied);
  if (new_pos == &tree->position[0]) {
    tree->rep_game = 0;
    tree->rep_list[tree->rep_game] = HashKey;
  }
}

void InitializeEvaluation(void)
{
  int i, j;

  for (i = 0; i < 8; i++)
    for (j = 0; j < 8; j++) {
      pval_b[i * 8 + j] = pval_w[(7 - i) * 8 + j];
      kval_bn[i * 8 + j] = kval_wn[(7 - i) * 8 + j];
      kval_bk[i * 8 + j] = kval_wk[(7 - i) * 8 + j];
      kval_bq[i * 8 + j] = kval_wq[(7 - i) * 8 + j];
      black_outpost[i * 8 + j] = white_outpost[(7 - i) * 8 + j];
    }
  InitializeKingSafety();
}

/*
 *******************************************************************************
 *                                                                             *
 *   InitlializeFindAttacks() is used to find the attacks from <square> that   *
 *   exist on the 8-bit vector supplied as <pieces>.  <pieces> represents a    *
 *   rank, file or diagonal, based on the rotated bit-boards.                  *
 *                                                                             *
 *******************************************************************************
 */
int InitializeFindAttacks(int square, int pieces, int length)
{
  int result, start;

  result = 0;
/*
 ************************************************************
 *                                                          *
 *   find attacks to left of <square>.                      *
 *                                                          *
 ************************************************************
 */
  if (square < 7) {
    start = 1 << (square + 1);
    while (start < 256) {
      result = result | start;
      if (pieces & start)
        break;
      start = start << 1;
    }
  }
/*
 ************************************************************
 *                                                          *
 *   find attacks to right of <square>.                     *
 *                                                          *
 ************************************************************
 */
  if (square > 0) {
    start = 1 << (square - 1);
    while (start > 0) {
      result = result | start;
      if (pieces & start)
        break;
      start = start >> 1;
    }
  }
  return (result & ((1 << length) - 1));
}

int InitializeGetLogID(void)
{
#if defined(UNIX)
  struct stat *fileinfo = malloc(sizeof(struct stat));
#endif
  int t;

  if (!log_id) {
    for (log_id = 1; log_id < 300; log_id++) {
      sprintf(log_filename, "%s/log.%03d", log_path, log_id);
      sprintf(history_filename, "%s/game.%03d", log_path, log_id);
      log_file = fopen(log_filename, "r");
      if (!log_file)
        break;
      fclose(log_file);
    }
#if defined(UNIX)
/*  a kludge to work around an xboard 4.2.3 problem.  It sends two "quit"
   commands, which causes every other log.nnn file to be empty.  this code
   looks for a very small log.nnn file as the last one, and if it is small,
   then we simply overwrite it to solve this problem temporarily.  this will
   be removed when the nexto xboard version comes out to fix this extra quit
   problem.                                                               */
    {
      char tfn[128];
      FILE *tlog;
      int i;

      sprintf(tfn, "%s/log.%03d", log_path, log_id - 1);
      tlog = fopen(tfn, "r+");
      if (tlog) {
        i = fstat(fileno(tlog), fileinfo);
        if (fileinfo->st_size < 1300)
          log_id--;
      }
    }
#endif
  }
  t = log_id++;
  return (t);
}

void InitializeHashTables(void)
{
  int i;

  shared->transposition_id = 0;
  if (!trans_ref)
    return;
  for (i = 0; i < hash_table_size; i++) {
    (trans_ref + i)->prefer.word1 = (BITBOARD) 7 << 61;
    (trans_ref + i)->prefer.word2 = 0;
    (trans_ref + i)->always[0].word1 = (BITBOARD) 7 << 61;
    (trans_ref + i)->always[0].word2 = 0;
    (trans_ref + i)->always[1].word1 = (BITBOARD) 7 << 61;
    (trans_ref + i)->always[1].word2 = 0;
  }
  if (!pawn_hash_table)
    return;
  for (i = 0; i < pawn_hash_table_size; i++) {
    (pawn_hash_table + i)->key = 0;
    (pawn_hash_table + i)->p_score = 0;
    (pawn_hash_table + i)->protected = 0;
    (pawn_hash_table + i)->black_defects_k = 0;
    (pawn_hash_table + i)->black_defects_q = 0;
    (pawn_hash_table + i)->white_defects_k = 0;
    (pawn_hash_table + i)->white_defects_q = 0;
    (pawn_hash_table + i)->passed_w = 0;
    (pawn_hash_table + i)->passed_b = 0;
    (pawn_hash_table + i)->outside = 0;
    (pawn_hash_table + i)->candidates_w = 0;
    (pawn_hash_table + i)->candidates_b = 0;
  }
}

void InitializeKillers(void)
{
  int i;

  for (i = 0; i < MAXPLY; i++) {
    shared->local[0]->killers[i].move1 = 0;
    shared->local[0]->killers[i].move2 = 0;
  }
  for (i = 0; i < 256; i++)
    shared->local[0]->rep_list[i] = 0;
}

/*
 *******************************************************************************
 *                                                                             *
 *   InitlializeKingSafety() is used to initialize the king safety matrix.     *
 *   this is set so that the matrix, indexed by king safety pawn structure     *
 *   index and by king safety piece tropism, combines the two indices to       *
 *   produce a single score.  as either index rises, the king safety score     *
 *   tracks along, but as both rise, the king safety score rises much more     *
 *   quickly.                                                                  *
 *                                                                             *
 *******************************************************************************
 */
void InitializeKingSafety()
{
  int safety, tropism;

  for (safety = 0; safety < 16; safety++) {
    for (tropism = 0; tropism < 16; tropism++) {
      king_safety[safety][tropism] =
          (safety_vector[safety] + 100) * (tropism_vector[tropism] +
          100) / 100 - 100;
    }
  }
/*
  printf("   ");
  for (tropism = 0; tropism < 16; tropism++)
    printf("%4d", tropism);
  printf("\n");
  for (safety = 0; safety < 16; safety++) {
    printf("%2d  ", safety);
    for (tropism = 0; tropism < 16; tropism++) {
      printf("%3d,", king_safety[safety][tropism]);
      if ((tropism + 1) % 16 == 0)
        printf("\n");
    }
  }
*/
}

void InitializeMasks(void)
{
  int i, j;

  mask_clear_entry = (BITBOARD) 0xe7fffffffffe0000ull;
/*
 masks to set/clear a bit on a specific square
 */
  for (i = 0; i < 64; i++) {
    ClearMask(i) = ~((BITBOARD) 1 << i);
    SetMask(i) = (BITBOARD) 1 << i;
  }
  ClearMask(BAD_SQUARE) = 0;
  SetMask(BAD_SQUARE) = 0;
/*
 masks to select bits on a specific rank or file
 */
  rank_mask[0] = (BITBOARD) 255;
  for (i = 1; i < 8; i++)
    rank_mask[i] = rank_mask[i - 1] << 8;
  file_mask[FILEA] = (BITBOARD) 1;
  for (i = 1; i < 8; i++)
    file_mask[FILEA] = file_mask[FILEA] | file_mask[FILEA] << 8;
  for (i = 1; i < 8; i++)
    file_mask[i] = file_mask[i - 1] << 1;
/*
 masks to determine if a pawn is protected by another pawn or not.
 also masks to detect "duos" (pawns side-by-side only).
 */
  for (i = 8; i < 56; i++) {
    if (File(i) > 0 && File(i) < 7) {
      mask_pawn_duo[i] = SetMask(i - 1) | SetMask(i + 1);
      mask_pawn_protected_w[i] = SetMask(i - 1) | SetMask(i + 1);
      if (i > 15)
        mask_pawn_protected_w[i] |= SetMask(i - 7) | SetMask(i - 9);
      mask_pawn_protected_b[i] = SetMask(i - 1) | SetMask(i + 1);
      if (i < 48)
        mask_pawn_protected_b[i] |= SetMask(i + 7) | SetMask(i + 9);
    } else if (File(i) == 0) {
      mask_pawn_duo[i] = SetMask(i + 1);
      mask_pawn_protected_w[i] = SetMask(i + 1);
      if (i > 15)
        mask_pawn_protected_w[i] |= SetMask(i - 7);
      mask_pawn_protected_b[i] = SetMask(i + 1);
      if (i < 48)
        mask_pawn_protected_b[i] |= SetMask(i + 9);
    } else if (File(i) == 7) {
      mask_pawn_duo[i] = SetMask(i - 1);
      mask_pawn_protected_w[i] = SetMask(i - 1);
      if (i > 15)
        mask_pawn_protected_w[i] |= SetMask(i - 9);
      mask_pawn_protected_b[i] = SetMask(i - 1);
      if (i < 48)
        mask_pawn_protected_b[i] |= SetMask(i + 7);
    }
  }
  mask_fgh = file_mask[FILEF] | file_mask[FILEG] | file_mask[FILEH];
  mask_efgh =
      file_mask[FILEE] | file_mask[FILEF] | file_mask[FILEG] | file_mask[FILEH];
  mask_abc = file_mask[FILEA] | file_mask[FILEB] | file_mask[FILEC];
  mask_abcd =
      file_mask[FILEA] | file_mask[FILEB] | file_mask[FILEC] | file_mask[FILED];
  virgin_center_pawns = SetMask(D2) | SetMask(E2) | SetMask(D7) | SetMask(E7);
  mask_kr_trapped_w[0] = SetMask(H2);
  mask_kr_trapped_w[1] = SetMask(H1) | SetMask(H2);
  mask_kr_trapped_w[2] = SetMask(G1) | SetMask(H1) | SetMask(H2);
  mask_qr_trapped_w[0] = SetMask(A2);
  mask_qr_trapped_w[1] = SetMask(A1) | SetMask(A2);
  mask_qr_trapped_w[2] = SetMask(A1) | SetMask(B1) | SetMask(A2);
  mask_kr_trapped_b[0] = SetMask(H7);
  mask_kr_trapped_b[1] = SetMask(H8) | SetMask(H7);
  mask_kr_trapped_b[2] = SetMask(H8) | SetMask(G8) | SetMask(H7);
  mask_qr_trapped_b[0] = SetMask(A7);
  mask_qr_trapped_b[1] = SetMask(A8) | SetMask(A7);
  mask_qr_trapped_b[2] = SetMask(A8) | SetMask(B8) | SetMask(A7);

  mask_A3B3 = SetMask(A3) | SetMask(B3);
  mask_B3C3 = SetMask(B3) | SetMask(C3);
  mask_F3G3 = SetMask(F3) | SetMask(G3);
  mask_G3H3 = SetMask(G3) | SetMask(H3);
  mask_A6B6 = SetMask(A6) | SetMask(B6);
  mask_B6C6 = SetMask(B6) | SetMask(C6);
  mask_F6G6 = SetMask(F6) | SetMask(G6);
  mask_G6H6 = SetMask(G6) | SetMask(H6);
  mask_white_OO = SetMask(F1) | SetMask(G1);
  mask_white_OOO = SetMask(B1) | SetMask(C1) | SetMask(D1);
  mask_black_OO = SetMask(F8) | SetMask(G8);
  mask_black_OOO = SetMask(B8) | SetMask(C8) | SetMask(D8);
  mask_corner_a1 =
      SetMask(A1) | SetMask(A2) | SetMask(A3) | SetMask(B1) | SetMask(B2) |
      SetMask(B3) | SetMask(C1) | SetMask(C2) | SetMask(C3);
  mask_corner_h1 =
      SetMask(F1) | SetMask(F2) | SetMask(F3) | SetMask(G1) | SetMask(G2) |
      SetMask(G3) | SetMask(H1) | SetMask(H2) | SetMask(H3);
  mask_corner_a8 =
      SetMask(A8) | SetMask(A7) | SetMask(A6) | SetMask(B8) | SetMask(B7) |
      SetMask(B6) | SetMask(C8) | SetMask(C7) | SetMask(C6);
  mask_corner_h8 =
      SetMask(F8) | SetMask(F7) | SetMask(F6) | SetMask(G8) | SetMask(G7) |
      SetMask(G6) | SetMask(H8) | SetMask(H7) | SetMask(H6);
  mask_center_files = file_mask[FILED] | file_mask[FILEE];
  mask_d3d4d5d6 = SetMask(D3) | SetMask(D4) | SetMask(D5) | SetMask(D6);
  mask_e3e4e5e6 = SetMask(E3) | SetMask(E4) | SetMask(E5) | SetMask(E6);

  for (i = 0; i < 64; i++) {
    stalemate_sqs[i] = 0;
    edge_moves[i] = 0;
  }
  for (i = 0; i < 8; i++) {
    stalemate_sqs[i] |= SetMask(i + 16);
    if (File(i) == 0)
      stalemate_sqs[i] |= SetMask(i + 17);
    if (File(i) == 7)
      stalemate_sqs[i] |= SetMask(i + 15);
    stalemate_sqs[i + 56] |= SetMask(i + 40);
    if (File(i) == 0)
      stalemate_sqs[i + 56] |= SetMask(i + 41);
    if (File(i) == 7)
      stalemate_sqs[i + 56] |= SetMask(i + 39);
  }
  for (i = 0; i < 64; i += 8) {
    stalemate_sqs[i] |= SetMask(i + 2);
    if (Rank(i) == 0)
      stalemate_sqs[i] |= SetMask(i + 10);
    if (Rank(i) == 7)
      stalemate_sqs[i] |= SetMask(i - 6);
    stalemate_sqs[i + 7] |= SetMask(i + 5);
    if (Rank(i) == 0)
      stalemate_sqs[i + 7] |= SetMask(i + 13);
    if (Rank(i) == 7)
      stalemate_sqs[i + 7] |= SetMask(i - 3);
  }
  for (i = 0; i < 63; i++) {
    for (j = 0; j < 63; j++) {
      if (stalemate_sqs[i] & SetMask(j)) {
        if (Rank(i) == 0 || Rank(i) == 7) {
          if (File(i) > 0)
            edge_moves[i] |= SetMask(i - 1);
          if (File(i) < 7)
            edge_moves[i] |= SetMask(i + 1);
        }
        if (File(i) == 0 || File(i) == 7) {
          if (Rank(i) > 0)
            edge_moves[i] |= SetMask(i - 8);
          if (Rank(i) < 7)
            edge_moves[i] |= SetMask(i + 8);
        }
      }
    }
  }
}

void InitializePawnMasks(void)
{
  int i, file;
  BITBOARD m1, m2;

/*
 initialize isolated pawn masks, which are nothing more than 1's on
 the files adjacent to the pawn file.
 */
  for (i = 0; i < 64; i++) {
    if (!File(i))
      mask_pawn_isolated[i] = file_mask[File(i) + 1];
    else if (File(i) == 7)
      mask_pawn_isolated[i] = file_mask[File(i) - 1];
    else
      mask_pawn_isolated[i] = file_mask[File(i) - 1] | file_mask[File(i) + 1];
  }
/*
 initialize passed pawn masks, which are nothing more than 1's on
 the pawn's file and the adjacent files, but only on ranks that are
 in "front" of the pawn.
 */
  for (i = 0; i < 64; i++) {
    if (!File(i)) {
      mask_pawn_passed_w[i] = plus8dir[i] | plus8dir[i + 1];
      mask_pawn_passed_b[i] = minus8dir[i] | minus8dir[i + 1];
    } else if (File(i) == 7) {
      mask_pawn_passed_w[i] = plus8dir[i - 1] | plus8dir[i];
      mask_pawn_passed_b[i] = minus8dir[i - 1] | minus8dir[i];
    } else {
      mask_pawn_passed_w[i] = plus8dir[i - 1] | plus8dir[i] | plus8dir[i + 1];
      mask_pawn_passed_b[i] =
          minus8dir[i - 1] | minus8dir[i] | minus8dir[i + 1];
    }
  }
/*
 these masks are used to determine if the other side has any pawns
 that can attack [square].
 */
  for (i = 8; i < 56; i++) {
    if (!File(i)) {
      mask_no_pattacks_w[i] = minus8dir[i + 1];
      mask_no_pattacks_b[i] = plus8dir[i + 1];
    } else if (File(i) == 7) {
      mask_no_pattacks_w[i] = minus8dir[i - 1];
      mask_no_pattacks_b[i] = plus8dir[i - 1];
    } else {
      mask_no_pattacks_w[i] = minus8dir[i - 1] | minus8dir[i + 1];
      mask_no_pattacks_b[i] = plus8dir[i + 1] | plus8dir[i - 1];
    }
  }
/*
 enpassant pawns are on either file adjacent to the current file, and
 on the same rank.
 */
  for (i = 0; i < 64; i++)
    mask_eptest[i] = 0;
  for (i = 25; i < 31; i++)
    mask_eptest[i] = SetMask(i - 1) | SetMask(i + 1);
  for (i = 33; i < 39; i++)
    mask_eptest[i] = SetMask(i - 1) | SetMask(i + 1);
  mask_eptest[A4] = SetMask(B4);
  mask_eptest[H4] = SetMask(G4);
  mask_eptest[A5] = SetMask(B5);
  mask_eptest[H5] = SetMask(G5);
/*
   these two masks have 1's on dark squares and light squares
   to test to see if pawns/bishops are on them.
 */
  m1 = (BITBOARD) 1 << 63;
  m2 = m1 >> 1;
  for (i = 1; i < 4; i++) {
    m1 = m1 | m1 >> 2;
    m2 = m2 | m2 >> 2;
  }
  for (i = 0; i < 64; i += 8) {
    if ((Rank(i)) & 1) {
      dark_squares = dark_squares | m2 >> i;
      light_squares = light_squares | m1 >> i;
    } else {
      dark_squares = dark_squares | m1 >> i;
      light_squares = light_squares | m2 >> i;
    }
  }
/*
   this mask is used to detect that one side has pawns, but all
   are rook pawns.
 */
  not_rook_pawns =
      file_mask[FILEB] | file_mask[FILEC] | file_mask[FILED] | file_mask[FILEE]
      | file_mask[FILEF] | file_mask[FILEG];
/*
   these two masks have 1's on everywhere but the left or right
   files, used to prevent pawns from capturing off the edge of
   the board and wrapping around.rom capturing off the edge of
 */
  mask_left_edge = ~file_mask[FILEA];
  mask_right_edge = ~file_mask[FILEH];
  mask_advance_2_w = rank_mask[RANK3];
  mask_advance_2_b = rank_mask[RANK6];
/*
   this mask has 1's everywhere except the a/h file and
   the first/last rank.
 */
  mask_not_edge =
      ~(rank_mask[RANK1] | rank_mask[RANK8] | file_mask[FILEA] |
      file_mask[FILEH]);
/*
   this array is indexed by an 8-bit value that has a one for
   each file with a pawn of a specific color.  it returns the
   number of "pawn islands" based on that file status.
 */
  for (i = 0; i < 256; i++) {
    islands[i] = 0;
    file = 1;
    while (file <= 128) {
      while (!(i & file)) {
        file <<= 1;
        if (file > 128)
          break;
      }
      if (file <= 128) {
        islands[i]++;
        while (i & file) {
          file <<= 1;
          if (file > 128)
            break;
        }
      }
    }
  }
}

void InitializePieceMasks(void)
{
  int i, j;

/*
 initialize masks used to evaluate pawn races.  these masks are
 used to determine if the opposing king is in a position to stop a
 passed pawn from racing down and queening.
 */
  for (i = 0; i < 64; i++) {
    white_pawn_race_wtm[i] = 0;
    white_pawn_race_btm[i] = 0;
    black_pawn_race_wtm[i] = 0;
    black_pawn_race_btm[i] = 0;
  }
  for (j = 8; j < 56; j++) {
    for (i = 0; i < 64; i++) {
/* white pawn, wtm */
      if (j < 16) {
        if (KingPawnSquare(j + 8, i, File(j) + 56, 1))
          white_pawn_race_wtm[j] = white_pawn_race_wtm[j] | SetMask(i);
      } else {
        if (KingPawnSquare(j, i, File(j) + 56, 1))
          white_pawn_race_wtm[j] = white_pawn_race_wtm[j] | SetMask(i);
      }
/* white pawn, Flip(wtm) */
      if (j < 16) {
        if (KingPawnSquare(j + 8, i, File(j) + 56, 0))
          white_pawn_race_btm[j] = white_pawn_race_btm[j] | SetMask(i);
      } else {
        if (KingPawnSquare(j, i, File(j) + 56, 0))
          white_pawn_race_btm[j] = white_pawn_race_btm[j] | SetMask(i);
      }
/* black pawn, wtm */
      if (j > 47) {
        if (KingPawnSquare(j - 8, i, File(j), 0))
          black_pawn_race_wtm[j] = black_pawn_race_wtm[j] | SetMask(i);
      } else {
        if (KingPawnSquare(j, i, File(j), 0))
          black_pawn_race_wtm[j] = black_pawn_race_wtm[j] | SetMask(i);
      }
/* black pawn, Flip(wtm) */
      if (j > 47) {
        if (KingPawnSquare(j - 8, i, File(j), 1))
          black_pawn_race_btm[j] = black_pawn_race_btm[j] | SetMask(i);
      } else {
        if (KingPawnSquare(j, i, File(j), 1))
          black_pawn_race_btm[j] = black_pawn_race_btm[j] | SetMask(i);
      }
    }
  }
}

/*
 *******************************************************************************
 *                                                                             *
 *   InitializeRandomHash() is called to initialize the tables of random       *
 *   numbers used to produce the incrementally-updated hash keys.  note that   *
 *   this uses a treendom number generator rather than the C library one       *
 *   since there is no uniformity in the number of bits returned by the        *
 *   standard library routines, it varies from 16 bits to 64.                  *
 *                                                                             *
 *******************************************************************************
 */
void InitializeRandomHash(void)
{
  int i;

  for (i = 0; i < 64; i++) {
    w_pawn_random[i] = Random64();
    b_pawn_random[i] = Random64();
    w_knight_random[i] = Random64();
    b_knight_random[i] = Random64();
    w_bishop_random[i] = Random64();
    b_bishop_random[i] = Random64();
    w_rook_random[i] = Random64();
    b_rook_random[i] = Random64();
    w_queen_random[i] = Random64();
    b_queen_random[i] = Random64();
    w_king_random[i] = Random64();
    b_king_random[i] = Random64();
  }
  for (i = 0; i < 2; i++) {
    castle_random_w[i] = Random64();
    castle_random_b[i] = Random64();
  }
  enpassant_random[0] = 0;
  for (i = 1; i < 65; i++) {
    enpassant_random[i] = Random64();
  }
  for (i = 0; i < 2; i++) {
    wtm_random[i] = Random64();
  }
}

/*
 *******************************************************************************
 *                                                                             *
 *   InitlializeSharedData() is used to initialize the shared data that can    *
 *   not be initialized normally since it is in a shared memory (SYSV) memory  *
 *   block.                                                                    *
 *                                                                             *
 *******************************************************************************
 */
void InitializeSharedData(void)
{
  shared->smp_idle = 0;
  shared->smp_threads = 0;
  shared->initialized_threads = 0;
  shared->crafty_is_white = 0;
  shared->average_nps = 0;
  shared->nodes_between_time_checks = 1000000;
  shared->nodes_per_second = 1000000;
  shared->transposition_id = 0;
  shared->thinking = 0;
  shared->pondering = 0;
  shared->puzzling = 0;
  shared->booking = 0;
  shared->time_limit = 100;
  shared->trojan_check = 0;
  shared->computer_opponent = 0;
  shared->max_threads = 0;
  shared->min_thread_depth = 40;
  shared->max_thread_group = 4;
  shared->split_at_root = 1;
  shared->noise_level = 200000;
  shared->quit = 0;
  shared->display_options = 4095 - 256 - 512;
  shared->tc_moves = 60;
  shared->tc_time = 180000;
  shared->tc_time_remaining = 180000;
  shared->tc_time_remaining_opponent = 180000;
  shared->tc_moves_remaining = 60;
  shared->tc_secondary_moves = 30;
  shared->tc_secondary_time = 90000;
  shared->tc_increment = 0;
  shared->tc_sudden_death = 0;
  shared->tc_operator_time = 0;
  shared->tc_safety_margin = 0;
  shared->draw_score[0] = 0;
  shared->draw_score[1] = 0;
  shared->move_number = 1;
  shared->moves_out_of_book = 0;
  shared->first_nonbook_factor = 0;
  shared->first_nonbook_span = 0;
}

/*
 *******************************************************************************
 *                                                                             *
 *   InitlializeSMP() is used to initialize the pthread lock variables.        *
 *                                                                             *
 *******************************************************************************
 */
void InitializeSMP(void)
{
  LockInit(shared->lock_smp);
  LockInit(shared->lock_io);
  LockInit(shared->lock_root);
  LockInit(shared->local[0]->lock);
}

void InitializeZeroMasks(void)
{
  int i, j, k;

#if !defined(CRAY1) && !defined(_M_AMD64) && !defined (_M_IA64) && !defined(INLINE32)

  msb[0] = 16;
  lsb[0] = 16;
  for (i = 1; i < 65536; i++) {
    lsb[i] = 16;
    for (j = 0; j < 16; j++)
      if (i & (1 << j)) {
        msb[i] = j;
        if (lsb[i] == 16)
          lsb[i] = j;
      }
  }
#endif
  msb_8bit[0] = 8;
  lsb_8bit[0] = 8;
  pop_cnt_8bit[0] = 0;
  connected_passed[0] = 0;
  for (i = 1; i < 256; i++) {
    pop_cnt_8bit[i] = 0;
    for (j = 0; j < 8; j++)
      if (i & (1 << j))
        pop_cnt_8bit[i]++;
    lsb_8bit[i] = 8;
    for (j = 0; j < 8; j++) {
      if (i & (1 << j)) {
        msb_8bit[i] = j;
        if (lsb_8bit[i] == 8)
          lsb_8bit[i] = j;
      }
    }
    connected_passed[i] = 0;
    for (j = 0; j < 8; j++)
      if ((i & (3 << j)) == (3 << j)) {
        connected_passed[i] = j + 1;
        break;
      }
    for (j = 0; j < 8; j++)
      if (i & (1 << j))
        break;
    for (k = 7; k >= 0; k--)
      if (i & (1 << k))
        break;
    if (k > j)
      file_spread[i] = k - j - 1;
    else
      file_spread[i] = 0;
  }
/*
 is_outside[p][a] /is_outside_c[p][a] values:
 p=8 bit mask for passed pawns
 a=8 bit mask for all pawns on board
 p must have left-most or right-most bit set when compared to
 mask 'a'.  and this bit must be separated from the next bit
 by at least one file (ie the outside passed pawn is 2 files
 from the rest of the pawns, at least.  for is_outside_c[] the
 candidate passer only has to be outside by 1 file.

 ppsq = square that contains a (potential) passed pawn.
 psql = leftmost pawn, period.
 psqr = rightmost pawn, period.
 0 -> passed pawn is not 'outside'
 1 -> passed pawn is 'outside'
 2 -> passed pawn is 'outside' on both sides of board
 */

  for (i = 0; i < 256; i++) {
    for (j = 0; j < 256; j++) {
      int ppsq1, ppsq2, psql, psqr;

      is_outside[i][j] = 0;
      is_outside_c[i][j] = 0;
      ppsq1 = lsb_8bit[i];
      if (ppsq1 < 8) {
        psql = lsb_8bit[j & (255 - (1 << ppsq1))];
        if (ppsq1 < psql - 1)
          is_outside[i][j] += 1;
        if (ppsq1 <= psql + 1)
          is_outside_c[i][j] += 1;
      }
      ppsq2 = msb_8bit[i];
      if (ppsq2 < 8) {
        psqr = msb_8bit[j & (255 - (1 << ppsq2))];
        if (ppsq2 > psqr + 1)
          is_outside[i][j] += 1;
        if (ppsq2 >= psqr - 1)
          is_outside_c[i][j] += 1;
      }
      if (ppsq1 == ppsq2 && is_outside[i][j] > 0)
        is_outside[i][j] = 1;
      if (ppsq1 == ppsq2 && is_outside_c[i][j] > 0)
        is_outside_c[i][j] = 1;
    }
  }
}
