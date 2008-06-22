#include <stdio.h>
#include <stdlib.h>
#include "chess.h"
#include "data.h"

/* last modified 09/10/07 */
/*
 *******************************************************************************
 *                                                                             *
 *   HashProbe() is used to retrieve entries from the transposition table so   *
 *   this sub-tree won't have to be searched again if we reach a position that *
 *   has been searched previously.  a transposition table position contains the*
 *   following data packed into 128 bits with each item taking the number of   *
 *   bits given in the table below:                                            *
 *                                                                             *
 *     bits     name  SL  description                                          *
 *       3       age  61  search id to identify old trans/ref entries.         *
 *       2      type  59  0->value is worthless; 1-> value represents a fail-  *
 *                        low bound; 2-> value represents a fail-high bound;   *
 *                        3-> value is an exact score.                         *
 *       1    threat  58  threat extension flag, 1 -> extend this position.    *
 *       5    unused  53  unused at present time.                              *
 *      21      move  32  best move from the current position, according to the*
 *                        search at the time this position was stored.         *
 *      15     draft  17  the depth of the search below this position, which is*
 *                        used to see if we can use this entry at the current  *
 *                        position.  note that this is in units of 1/4th of a  *
 *                        ply.                                                 *
 *      17     value   0  unsigned integer value of this position + 65536.     *
 *                        this might be a good score or search bound.          *
 *                                                                             *
 *      64       key   0  64 bit hash signature, used to verify that this entry*
 *                        goes with the current board position.                *
 *                                                                             *
 *******************************************************************************
 */
int HashProbe(TREE * RESTRICT tree, int ply, int depth, int wtm, int *alpha,
    int beta, int *threat)
{
  register BITBOARD word1, word2;
  register int type, draft, avoid_null = 0, val, pieces, null_depth, hwhich;
  register unsigned int word1l, word1r;
  BITBOARD temp_hashkey;
  HASH_ENTRY *htable;

#if defined(HASHSTATS)
  int local_hits = 0, local_good_hits = 0;
#endif
/*
 ************************************************************
 *                                                          *
 *   first, compute the initial hash address and choose     *
 *   which hash table (based on color) to probe.            *
 *                                                          *
 ************************************************************
 */
  tree->hash_move[ply] = 0;
#if defined(HASHSTATS)
  tree->transposition_probes++;
#endif
/*
 ************************************************************
 *                                                          *
 *   now, check both "parts" of the hash table to see if    *
 *   this position is in either one.                        *
 *                                                          *
 ************************************************************
 */
  pieces = (wtm) ? TotalWhitePieces : TotalBlackPieces;
  null_depth = (depth > 6 * PLY && pieces > 9) ? null_max : null_min;
  temp_hashkey = (wtm) ? HashKey : ~HashKey;
  htable = trans_ref + ((int) temp_hashkey & hash_mask);
  word1 = htable->prefer.word1;
  word2 = htable->prefer.word2;
  if (word2 == temp_hashkey)
    do {
#if defined(HASHSTATS)
      local_hits++;
#endif
      htable->prefer.word1 =
          (htable->prefer.word1 & 0x1fffffffffffffffULL) | ((BITBOARD) shared->
          transposition_id << 61);
      word1l = word1 >> 32;
      word1r = word1;
      val = (word1r & 0x1ffff) - 65536;
      draft = word1r >> 17;
      tree->hash_move[ply] = word1l & 0x1fffff;
      *threat = (word1l >> 26) & 1;
      type = (word1l >> 27) & 3;
      if ((type & UPPER) && depth - null_depth <= draft && val < beta)
        avoid_null = AVOID_NULL_MOVE;
      if (depth > draft)
        break;
      if (val > MATE - 300)
        val -= ply - 1;
      else if (val < -MATE + 300)
        val += ply - 1;
#if defined(HASHSTATS)
      local_good_hits++;
#endif
      switch (type) {
      case EXACT:
        *alpha = val;
#if defined(HASHSTATS)
        tree->transposition_hits++;
        tree->transposition_good_hits++;
        tree->transposition_exacts++;
#endif
        if (draft != MAX_DRAFT)
          return (EXACT);
        else
          return (EXACTEGTB);
      case UPPER:
        if (val <= *alpha) {
#if defined(HASHSTATS)
          tree->transposition_hits++;
          tree->transposition_good_hits++;
          tree->transposition_uppers++;
#endif
          return (UPPER);
        }
        break;
      case LOWER:
        if (val >= beta) {
#if defined(HASHSTATS)
          tree->transposition_hits++;
          tree->transposition_lowers++;
          tree->transposition_good_hits++;
#endif
          return (LOWER);
        }
        break;
      }
    } while (0);

  hwhich = ((int) temp_hashkey >> log_hash) & 1;
  word1 = htable->always[hwhich].word1;
  word2 = htable->always[hwhich].word2;
  if (word2 == temp_hashkey) {
#if defined(HASHSTATS)
    local_hits++;
#endif
    htable->always[hwhich].word1 =
        (htable->always[hwhich].
        word1 & 0x1fffffffffffffffULL) | ((BITBOARD) shared->
        transposition_id << 61);
    word1l = word1 >> 32;
    word1r = word1;
    val = (word1r & 0x1ffff) - 65536;
    draft = word1r >> 17;
    if (tree->hash_move[ply] == 0)
      tree->hash_move[ply] = word1l & 0x1fffff;
    *threat = (word1l >> 26) & 1;
    type = (word1l >> 27) & 3;
    if ((type & UPPER) && depth - null_depth <= draft && val < beta)
      avoid_null = AVOID_NULL_MOVE;
    if (depth > draft)
      return (avoid_null);
    if (val > MATE - 300)
      val -= ply - 1;
    else if (val < -MATE + 300)
      val += ply - 1;
#if defined(HASHSTATS)
    local_good_hits++;
#endif
    switch (type) {
    case EXACT:
      *alpha = val;
#if defined(HASHSTATS)
      tree->transposition_hits++;
      tree->transposition_good_hits++;
      tree->transposition_exacts++;
#endif
      if (draft != MAX_DRAFT)
        return (EXACT);
      else
        return (EXACTEGTB);
    case UPPER:
      if (val <= *alpha) {
#if defined(HASHSTATS)
        tree->transposition_hits++;
        tree->transposition_good_hits++;
        tree->transposition_uppers++;
#endif
        return (UPPER);
      }
#if defined(HASHSTATS)
      tree->transposition_hits++;
      tree->transposition_good_hits++;
#endif
      return (avoid_null);
    case LOWER:
      if (val >= beta) {
#if defined(HASHSTATS)
        tree->transposition_hits++;
        tree->transposition_good_hits++;
        tree->transposition_lowers++;
#endif
        return (LOWER);
      }
      tree->transposition_hits++;
      tree->transposition_good_hits++;
      return (avoid_null);
    }
  }
#if defined(HASHSTATS)
  if (local_hits)
    tree->transposition_hits++;
  if (local_good_hits)
    tree->transposition_good_hits++;
#endif
  return (avoid_null);
}

/* last modified 09/10/07 */
/*
 *******************************************************************************
 *                                                                             *
 *   HashStore() is used to store entries into the transposition table so that *
 *   this sub-tree won't have to be searched again if the same position is     *
 *   reached.  a transposition/refutation table position contains the following*
 *   data packed into 128 bits, with each item taking the number of bits given *
 *   in the table below.                                                       *
 *                                                                             *
 *     bits     name  SL  description                                          *
 *       3       age  61  search id to identify old trans/ref entried.         *
 *       2      type  59  0->value is worthless; 1-> value represents a fail-  *
 *                        low bound; 2-> value represents a fail-high bound;   *
 *                        3-> value is an exact score.                         *
 *       1    threat  58  threat extension flag, 1 -> extend this position.    *
 *       5    unused  53  unused at present time.                              *
 *      21      move  32  best move from the current position, according to the*
 *                        search at the time this position was stored.         *
 *      15     draft  17  the depth of the search below this position, which is*
 *                        used to see if we can use this entry at the current  *
 *                        position.  note that this is in units of 1/60th of a *
 *                        ply.                                                 *
 *      17     value   0  unsigned integer value of this position + 65536.     *
 *                        this might be a good score or search bound.          *
 *                                                                             *
 *      64       key   0  64 bit hash signature, used to verify that this entry*
 *                        goes with the current board position.                *
 *                                                                             *
 *******************************************************************************
 */
void HashStore(TREE * RESTRICT tree, int ply, int depth, int wtm, int type,
    int value, int threat)
{
  register BITBOARD word1, word2;
  register HASH_ENTRY *htable;
  register int draft, age, hwhich;
  register unsigned int word1l, word1r;

/*
 ************************************************************
 *                                                          *
 *   "fill in the blank" and build a table entry from       *
 *   current search information.                            *
 *                                                          *
 ************************************************************
 */
  word1l = ((((shared->transposition_id << 2) + type) << 1) + threat) << 26;
  if (value > MATE - 300)
    value += ply - 1;
  else if (value < -MATE + 300)
    value -= ply - 1;
  if (type == EXACT) {
    if ((int) tree->pv[ply].pathl >= ply)
      word1l |= tree->pv[ply].path[ply];
  } else if (type == LOWER) {
    word1l |= tree->current_move[ply];
  }
  word1r = (depth << 17) + value + 65536;
  word1 = word1r + ((BITBOARD) word1l << 32);
  word2 = (wtm) ? HashKey : ~HashKey;
/*
 ************************************************************
 *                                                          *
 *   if the draft of this entry is greater than the draft   *
 *   of the entry in the "depth-priority" table, or if the  *
 *   entry in the depth-priority table is from an old       *
 *   search, move that entry to the always-store table and  *
 *   then replace the depth-priority table entry by the new *
 *   hash result.                                           *
 *                                                          *
 ************************************************************
 */
  htable = trans_ref + ((int) word2 & hash_mask);
  draft = (unsigned int) htable->prefer.word1 >> 17;
  age = htable->prefer.word1 >> 61;
  age = age && (age != shared->transposition_id);
  if (age || (depth >= draft)) {
    if (word2 != htable->prefer.word2) {
      hwhich = ((int) htable->prefer.word2 >> log_hash) & 1;
      htable->always[hwhich].word1 = htable->prefer.word1;
      htable->always[hwhich].word2 = htable->prefer.word2;
    }
    htable->prefer.word1 = word1;
    htable->prefer.word2 = word2;
  } else {
    hwhich = ((int) word2 >> log_hash) & 1;
    htable->always[hwhich].word1 = word1;
    htable->always[hwhich].word2 = word2;
  }
}

/* last modified 09/10/07 */
/*
 *******************************************************************************
 *                                                                             *
 *   HashStorePV() is called by Iterate() to insert the PV moves so they will  *
 *   be searched before any other moves.                                       *
 *                                                                             *
 *******************************************************************************
 */
void HashStorePV(TREE * RESTRICT tree, int ply, int wtm)
{
  register int hwhich;
  register HASH_ENTRY *htable;
  register BITBOARD temp_hashkey;

/*
 ************************************************************
 *                                                          *
 *   first, compute the initial hash address and choose     *
 *   which hash table (based on color) to probe.            *
 *                                                          *
 ************************************************************
 */
  temp_hashkey = (wtm) ? HashKey : ~HashKey;
  htable = trans_ref + ((int) temp_hashkey & hash_mask);
  hwhich = ((int) temp_hashkey >> log_hash) & 1;
/*
 ************************************************************
 *                                                          *
 *   now "fill in the blank" and build a table entry from   *
 *   current search information.                            *
 *                                                          *
 ************************************************************
 */
  if (htable->prefer.word2 == temp_hashkey && (htable->prefer.word1 >> 61)) {
    htable->prefer.word1 &= ~((BITBOARD) 0x1fffff << 32);
    htable->prefer.word1 |= (BITBOARD) tree->pv[ply].path[ply] << 32;
  } else if (htable->always[hwhich].word2 == temp_hashkey) {
    htable->always[hwhich].word1 &= ~((BITBOARD) 0x1fffff << 32);
    htable->always[hwhich].word1 |= (BITBOARD) tree->pv[ply].path[ply] << 32;
  } else {
    htable->always[hwhich].word1 = (BITBOARD) 65536;
    htable->always[hwhich].word1 |=
        ((BITBOARD) ((shared->transposition_id << 2) + WORTHLESS)) << 59;
    htable->always[hwhich].word1 |= (BITBOARD) tree->pv[ply].path[ply] << 32;
    htable->always[hwhich].word2 = temp_hashkey;
  }
}
