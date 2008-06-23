#include "glaurung.h"

int compute_material(const position_t *pos, int side) {
  int sq, result=0;
  for(sq=QueenListStart(pos, side); sq!=PieceListEnd; sq=NextPiece(pos, sq))
    if(sq <= H8) result += PieceValues[pos->board[sq]];
  return result;
}

int compute_psq(const position_t *pos, int side) {
  int sq, result=0;
  for(sq=KingSquare(pos, side); sq!=PieceListEnd; sq=NextPiece(pos, sq))
    if(sq <= H8) result += PSQ(pos->board[sq], sq);
  return result;
}

#define KEY_MASK ((1ULL<<48)-1)

struct eval_hashentry_t {
  uint64 key_and_score;
  int16 safety[2];
  int16 ppawns[2];
};

static eval_hashentry_t *EvalCache = NULL;
static int EvalCacheSize = 0;

void free_eval_cache(void) {
  EvalCacheSize = 0;
  free(EvalCache);
  EvalCache = NULL;
}

void init_eval_cache(void) {
  int s, new_size;

  if(Options->use_eval_cache) {
    s = Options->eval_cache_size << 16;
    for(new_size=(1<<17); new_size <= s; new_size*=2);
    new_size /= 2;
    if(new_size != EvalCacheSize) {
      free_eval_cache();
      EvalCacheSize = new_size;
      EvalCache = 
        (eval_hashentry_t *)malloc(EvalCacheSize * sizeof(eval_hashentry_t));
// malloc de 4194304 !!
//printf("init_eval_cache malloc %d\n", EvalCacheSize * sizeof(eval_hashentry_t));
      memset(EvalCache, 0, EvalCacheSize * sizeof(eval_hashentry_t));
    }
  }
  else free_eval_cache();
}

static inline int retrieve_eval(const position_t *pos, int *score, 
                                int safety[2], int pp[2]) {
  int index = (pos->key & (EvalCacheSize - 1));
  if((EvalCache[index].key_and_score & KEY_MASK) == (pos->key & KEY_MASK)) {
    *score = (int16) (EvalCache[index].key_and_score >> 48);
    safety[WHITE] = EvalCache[index].safety[WHITE];
    safety[BLACK] = EvalCache[index].safety[BLACK];
    pp[WHITE] = EvalCache[index].ppawns[WHITE];
    pp[BLACK] = EvalCache[index].ppawns[BLACK];
    return 1;
  }
  return 0;
}

static inline void store_eval(const position_t *pos,
                              int score, int safety[2], int pp[2]) {
  int index = (pos->key & (EvalCacheSize - 1));
  EvalCache[index].key_and_score = 
    (pos->key & KEY_MASK) | ((uint64)score << 48);
  EvalCache[index].safety[WHITE] = safety[WHITE];
  EvalCache[index].safety[BLACK] = safety[BLACK];
  EvalCache[index].ppawns[WHITE] = pp[WHITE];
  EvalCache[index].ppawns[BLACK] = pp[BLACK];
}


#define GRAIN_SIZE 4 // Must be a power of 2 

#define ROOK_OPEN_FILE_BONUS 30
#define TRAPPED_ROOK 180
#define BISHOP_TRAPPED_A7H7 300
#define BISHOP_TRAPPED_A6H6 120
#define BISHOP_TRAPPED_A1H1 100
#define BLOCKING_CENTRAL_PAWN 45

#define KNIGHT_PINNED_BY_BISHOP 25
#define KNIGHT_PINNED_BY_ROOK 20
#define BISHOP_PINNED_BY_ROOK 20
#define ROOK_PINNED_BY_BISHOP 35
#define QUEEN_PINNED_BY_BISHOP 60
#define QUEEN_PINNED_BY_ROOK 50

#define TEMPO_BONUS_MIDGAME 40
#define TEMPO_BONUS_ENDGAME 10

static const int NMobBonus[9] = {-10, -4, 2, 8, 14, 18, 22, 24, 25};
static const int BMobBonus[16] = {
  -20, -10, 0, 10, 20, 30, 38, 44, 48, 52, 54, 57, 58, 59, 60, 60
};
static const int RMobBonus[16] = {
  -12, -8, -4, 0, 4, 8, 11, 14, 16, 18, 19, 20, 21, 22, 23, 24
};
static const int RMobBonusEndgame[16] = {
  -20, -12, -4, 4, 12, 20, 28, 36, 44, 50, 54, 56, 57, 58, 59, 60
};
static const int QMobBonus[32] = {
  -10, -8, -6, -4, -2, 0, 2, 4, 6, 8, 10, 12, 13, 14, 15, 16,
  16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16, 16
};
static const int QMobBonusEndgame[32] = {
  -20, -15, -10, -5, 0, 5, 10, 15, 19, 23, 27, 29, 30, 30, 30, 30,
  30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30, 30
};
static const int DevelopmentPenalty[13] = {
  0, -4, -12, -20, -30, -40, -50, -60, -70, -80, -90, -100, -110
};

static const int MultiplePassivePenalty[8] = {0, 2, 6, 20, 50, 80, 120, 120};

static const int ShieldValue[2][32] = {
  {4, 1, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {0, 0, 0, 0, 0, 0, 0, 0, 4, 1, 2, 0, 0, 0, 0, 0,
   0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
};

// Passed pawn bonus by rank:
static const int PpBonus[8] = {0, 30, 30, 60, 100, 160, 256, 0};

static const int RooksOn7thBonus[32] = {
  0, 16, 32, 64, 110, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150, 150,
  150, 150, 150, 150, 150, 150, 150, 150,
  150, 150, 150, 150, 150, 150, 150, 150
};

static const int BishopPairBonus[7] = {
  60,  // UNKNOWN 
  100, // OPEN 
  80,  // HALF_OPEN 
  0,   // CLOSED 
  30,  // HALF_CLOSED 
  70,  // TENSION 
  60   // UNRESOLVED 
};

static const int ShieldFactor[7] = {
  12,  // UNKNOWN 
  16,  // OPEN 
  12,  // HALF_OPEN 
  6,   // CLOSED 
  10,   // HALF_CLOSED 
  12,  // TENSION 
  12   // UNRESOLVED 
};

static const int KnightInHoleBonus[128] = {
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 2, 8, 8, 8, 8, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 8, 15, 20, 20, 15, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 12, 22, 25, 25, 22, 12, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 4, 12, 15, 15, 12, 4, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};

static const int BishopInHoleBonus[128] = {
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  4, 6, 6, 6, 6, 6, 6, 4, 0, 0, 0, 0, 0, 0, 0, 0,
  8, 10, 12, 14, 14, 12, 10, 8, 0, 0, 0, 0, 0, 0, 0, 0,
  10, 12, 14, 16, 16, 14, 12, 10, 0, 0, 0, 0, 0, 0, 0, 0,
  4, 6, 8, 8, 8, 8, 6, 4, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};

static const int RookInHoleBonus[128] = {
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  6, 6, 2, 2, 2, 2, 6, 6, 0, 0, 0, 0, 0, 0, 0, 0,
  10, 10, 4, 2, 2, 4, 10, 10, 0, 0, 0, 0, 0, 0, 0, 0,
  6, 6, 4, 4, 4, 4, 6, 6, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
};

static const int MobilityIncrement[2][64] = {
  {1, -1, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 1, 0,
   1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0},
  {1, 1, 1, 1, 1, 1, 1, 0, 0, -1, 0, 0, 0, 0, 0, 0,
   1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
};

int (*EndgameEvalFunction[KQKR])(const position_t *) = {
  kxk_eval, kpk_eval, krkb_eval, krkn_eval, krkp_eval, kbnk_eval, krpkr_eval,
  kqkr_eval
};

static inline int evaluate_pawn_shield(const position_t *pos, 
                                       int side, int square) {
  int result = 0, x = PawnPush[side];
  result += ShieldValue[side][pos->board[square+x]-1];
  result += ShieldValue[side][pos->board[square+x-1]-1];
  result += ShieldValue[side][pos->board[square+x+1]-1];
  result += ShieldValue[side][pos->board[square+2*x]-1]/2;
  result += ShieldValue[side][pos->board[square+2*x-1]-1]/2;
  result += ShieldValue[side][pos->board[square+2*x+1]-1]/2;
  return result;
}

static inline bool square_is_hole(const position_t *pos, int sq, int side) {
  int file = file(sq), xside = side^1;
  return !(InFrontBF[side][rank(sq)] & (pos->pawn_files[xside][file-1] |
                                        pos->pawn_files[xside][file+1]));
}

static int evaluate_knight_in_hole(const position_t *pos, int sq, int side) {
  int b = KnightInHoleBonus[sq ^ side*0x70], bonus, sq2;
  int friendly_pawn = PawnOfColour(side), push = PawnPush[side];
  bool defended_by_pawn = false;

  if(b == 0) return 0;
  bonus = b;
  if(pos->board[sq - push - 1] == friendly_pawn ||
     pos->board[sq - push + 1] == friendly_pawn)
    defended_by_pawn = true;
  if(defended_by_pawn) bonus += b/4;
  if(!HasMinors(pos, side^1)) {
    bonus += b/2;
    if(defended_by_pawn) bonus += b;
  }
  else if(!HasKnights(pos, side^1) && BishopCount(pos, side^1) == 1) {
    sq2 = BishopListStart(pos, side^1);
    if(SquareColour(sq2) != SquareColour(sq)) {
      bonus += b/2;
      if(defended_by_pawn) bonus += b;
    }
  }
  return bonus;
}

static int evaluate_bishop_in_hole(const position_t *pos, int sq, int side) {
  int b = BishopInHoleBonus[sq ^ side*0x70], bonus, sq2;
  int friendly_pawn = PawnOfColour(side), push = PawnPush[side];
  bool defended_by_pawn = false;
  bool rook_file = false;

  if(b == 0) return 0;
  if(file(sq) == FILE_A || file(sq) == FILE_H) rook_file = true;
  bonus = b;
  if(!rook_file && (pos->board[sq - push - 1] == friendly_pawn ||
                    pos->board[sq - push + 1] == friendly_pawn))
    defended_by_pawn = true;
  if(defended_by_pawn) bonus += b/4;
  if(!HasMinors(pos, side^1)) {
    bonus += b/2;
    if(defended_by_pawn) bonus += b;
  }
  else if(!HasKnights(pos, side^1) && BishopCount(pos, side^1) == 1) {
    sq2 = BishopListStart(pos, side^1);
    if(SquareColour(sq2) != SquareColour(sq)) {
      bonus += b/2;
      if(defended_by_pawn) bonus += b;
    }
  }
  return bonus;
}
 
static int evaluate_rook_in_hole(const position_t *pos, int sq, int side) {
  int b = RookInHoleBonus[sq ^ side*0x70], bonus;
  int friendly_pawn = PawnOfColour(side), push = PawnPush[side];
  bool defended_by_pawn = false;

  if(b == 0) return 0;
  bonus = b;
  if(pos->board[sq - push - 1] == friendly_pawn ||
     pos->board[sq - push + 1] == friendly_pawn)
    defended_by_pawn = true;
  if(defended_by_pawn) bonus += b/4;
  if(!HasMinors(pos, side^1)) {
    if(!HasRooks(pos, side^1)) {
      bonus += b/2;
      if(defended_by_pawn) bonus += b;
    }
    else {
      bonus += b/4;
      if(defended_by_pawn) bonus += b/2;
    }
  }
  return bonus;
}

int evaluate(const position_t *pos, eval_vector_t *ev, int thread_id) {
  p_hashentry_t *ph;
  int result, e_result;
  int us = pos->side, them = us^1;
  int ksq = KingSquare(pos, us), xksq = KingSquare(pos, them);
  int pawn_structure[2], e_pawn_structure[2];
  int passed_pawns[2] = {0, 0};
  int mobility[2] = {0, 0}, e_mobility[2] = {0, 0};
  int development[2];
  int passive_pieces[2] = {0, 0};
  int shield[2], ks_shield[2], qs_shield[2];
  int king_safety[2] = {0, 0};
  int king_activity[2] = {0, 0};
  int piece_placement[2] = {0, 0};
  int misc[2] = {0, 0};
  int e_misc[2] = {0, 0};
  int pawns[2], knights[2], bishops[2], rooks[2], queens[2];
  int np_material[2];
  int bishop_colour[2] = {0, 0};
  int rooks_on_7th[2] = {0, 0};
  int storm[2] = {0, 0};
  int space[2] = {0, 0};
  int scale[2] = {128, 128};
  int has_unstoppable[2] = {0, 0};
  int moves_to_go[2] = {9, 9};
  int side, x, d, sq, tosq;
  const int *ptr;

  if(Options->use_eval_cache &&
     retrieve_eval(pos, &result, ev->king_safety, ev->passed_pawns))
    return result;

  result = e_result = 
    pos->material[us] - pos->material[them] + pos->psq[us] - pos->psq[them];

  ph = analyse_pawn_structure(pos, thread_id);

  pawns[WHITE] = PawnCount(pos, WHITE);
  pawns[BLACK] = PawnCount(pos, BLACK);
  np_material[WHITE] = pos->material[WHITE]-pawns[WHITE]*P_VALUE;
  np_material[BLACK] = pos->material[BLACK]-pawns[BLACK]*P_VALUE;

  // Scale the score in some basic endgames:
  if(pos->material[us] + pos->material[them] <= Q_VALUE+R_VALUE+B_VALUE) {
    x = scale_endgame_eval(pos, scale, ph);
    if(x) {
      result = (EndgameEvalFunction[x-1])(pos);
      goto end_of_evaluate;
    }
  }
  else {
    if(pawns[WHITE] == 0 && pos->material[WHITE] <= 2*R_VALUE+B_VALUE &&
       np_material[WHITE] - np_material[BLACK] <= N_VALUE)
      scale[WHITE] = 48;
    if(pawns[BLACK] == 0 && pos->material[BLACK] <= 2*R_VALUE+B_VALUE &&
       np_material[BLACK] - np_material[WHITE] <= N_VALUE)
      scale[BLACK] = 48;
  }
  if(scale[WHITE] == 0 && scale[BLACK] == 0) {
    result = 0;
    goto end_of_evaluate;
  }

  // Adjust piece square table score for king in the endgame: 
  e_result -= PSQ(KingOfColour(pos->side), ksq);
  e_result += KING_ENDGAME_PSQ(ksq);
  e_result += PSQ(KingOfColour(pos->xside), xksq);
  e_result -= KING_ENDGAME_PSQ(xksq);

  // Pawn structure: 
  pawn_structure[WHITE] = ph->score[WHITE]; 
  pawn_structure[BLACK] = ph->score[BLACK];
  e_pawn_structure[WHITE] = ph->e_score[WHITE];
  e_pawn_structure[BLACK] = ph->e_score[BLACK];

  // Initialise king shield and king activity:
  for(side = WHITE; side <= BLACK; side++) {
    ksq = KingSquare(pos, side);
    shield[side] = evaluate_pawn_shield(pos, side, ksq);
    ks_shield[side] = CanCastleKingside(pos, side)?
      evaluate_pawn_shield(pos, side, G1 + side*A8) : shield[side];
    qs_shield[side] = CanCastleQueenside(pos, side)?
      evaluate_pawn_shield(pos, side, C1 + side*A8) : shield[side];

    if(np_material[WHITE] + np_material[BLACK] < MIDGAME_MATERIAL) {
      for(sq = PawnListStart(pos, WHITE); sq <= H8; sq = NextPiece(pos, sq))
        king_activity[side] += KingActivityBonus[ksq - sq + 128];
      for(sq = PawnListStart(pos, BLACK); sq <= H8; sq = NextPiece(pos, sq))
        king_activity[side] += KingActivityBonus[sq - ksq + 128];
      king_activity[side] /= 2;
    }
  }

  for(side = WHITE; side <= BLACK; side++) {
    int flipmask = side*0x70;
    knights[side] = KnightCount(pos, side);
    bishops[side] = BishopCount(pos, side);
    rooks[side] = RookCount(pos, side);
    queens[side] = QueenCount(pos, side);
    ksq = KingSquare(pos, side); xksq = KingSquare(pos, side^1);
    d = 0;

    // Evaluate knights:
    for(sq = KnightListStart(pos, side); sq <= H8; sq = NextPiece(pos, sq)) {

      // Penalize undeveloped knights:
      if(PawnRank[side][sq] == RANK_1) d += 2;

      // Don't block central pawns:
      if((sq == (D3 ^ flipmask)) || (sq == (E3 ^ flipmask))) 
        if(pos->board[sq-PawnPush[side]] == PawnOfColour(side))
          misc[side] -= BLOCKING_CENTRAL_PAWN;

      // Compute mobility 
      x = 0;
      ptr = MobilityIncrement[side];
      x += ptr[pos->board[sq + 33]]; x += ptr[pos->board[sq + 31]]; 
      x += ptr[pos->board[sq + 18]]; x += ptr[pos->board[sq + 14]];
      x += ptr[pos->board[sq - 14]]; x += ptr[pos->board[sq - 18]];
      x += ptr[pos->board[sq - 31]]; x += ptr[pos->board[sq - 33]];
      x = Max(x, 0);
      mobility[side] += NMobBonus[x]; e_mobility[side] += NMobBonus[x];
      if(x <= 2 && PSQ(KnightOfColour(side), sq) < 10) passive_pieces[side]++;

      // Knights in holes:
      if(square_is_hole(pos, sq, side)) {
        x = evaluate_knight_in_hole(pos, sq, side);
        misc[side] += x; e_misc[side] += x;
      }
    }

    // Evaluate bishops: 
    for(sq = BishopListStart(pos, side); sq <= H8; sq = NextPiece(pos, sq)) {
      bishop_colour[side] |= SquareColour(sq);

      // Don't block central pawns:
      if((sq == (D3 ^ flipmask)) || (sq == (E3 ^ flipmask))) 
        if(pos->board[sq-PawnPush[side]] == PawnOfColour(side))
          misc[side] -= BLOCKING_CENTRAL_PAWN;

      // Compute mobility 
      x = 0;
      ptr = MobilityIncrement[side];
      for(tosq = sq + 15; pos->board[tosq] == EMPTY; tosq += 15) x++;
      x += ptr[pos->board[tosq]];
      for(tosq = sq - 15; pos->board[tosq] == EMPTY; tosq -= 15) x++;
      x += ptr[pos->board[tosq]];
      for(tosq = sq + 17; pos->board[tosq] == EMPTY; tosq += 17) x++;
      x += ptr[pos->board[tosq]];
      for(tosq = sq - 17; pos->board[tosq] == EMPTY; tosq -= 17) x++;
      x += ptr[pos->board[tosq]];
      x = Max(x, 0);
      mobility[side] += BMobBonus[x]; e_mobility[side] += BMobBonus[x];
      if(x <= 2) passive_pieces[side]++;

      if(PawnRank[side][sq]==RANK_1) {
        d++;
        if(x <= 2) d++;
      }

      if(x <= 3) {
        // Trapped bishops on A7/H7/A2/H2:
        if(side == WHITE) {
          if(sq == A7 && pos->board[B6] == BP && 
             (pos->board[C7]==BP || (see(pos, A7, B6)<0 && see(pos, A7, B8)<0)))
            piece_placement[WHITE] -= BISHOP_TRAPPED_A7H7;
          else if(sq == H7 && pos->board[G6] == BP && 
                  (pos->board[F7]==BP || (see(pos, H7, G6)<0 && 
                                          see(pos, H7, G8)<0)))
            piece_placement[WHITE] -= BISHOP_TRAPPED_A7H7;
        }
        else {
          if(sq==A2 && pos->board[B3]==WP && 
             (pos->board[C2]==WP || (see(pos, A2, B3)<0 && see(pos, A2, B1)<0)))
            piece_placement[BLACK] -= BISHOP_TRAPPED_A7H7;
          else if(sq==H2 && pos->board[G3]==WP && 
                  (pos->board[F2]==WP || (see(pos, H2, G3)<0 && 
                                          see(pos, H2, G1)<0)))
            piece_placement[BLACK] -= BISHOP_TRAPPED_A7H7;
        }
        
        // Trapped bishops on A6/H6/A3/H3:
        if(side == WHITE) {
          if(sq == A6 && pos->board[B5] == BP && see(pos, A6, B5) < 0)
            piece_placement[WHITE] -= BISHOP_TRAPPED_A6H6;
          else if(sq == H6 && pos->board[G5] == BP && see(pos, H6, G5) < 0)
            piece_placement[WHITE] -= BISHOP_TRAPPED_A6H6;
        }
        else {
          if(sq == A3 && pos->board[B4] == WP && see(pos, A3, B4) < 0)
            piece_placement[BLACK] -= BISHOP_TRAPPED_A6H6;
          else if(sq == H3 && pos->board[G4] == WP && see(pos, H3, G4) < 0)
            piece_placement[BLACK] -= BISHOP_TRAPPED_A6H6;
        }
        
        // An FRC pattern: A bishop on a1/h1/a8/h8 blocked by a pawn is bad.
        if(Options->frc) {
          if(side==WHITE) {
            if(sq==A1 && pos->board[B2]==WP) {
              if(pos->board[B3] != EMPTY) 
                piece_placement[WHITE] -= 2*BISHOP_TRAPPED_A1H1;
              else if(pos->board[C3] == WP)
                piece_placement[WHITE] -= BISHOP_TRAPPED_A1H1;
              else
                piece_placement[WHITE] -= BISHOP_TRAPPED_A1H1/2;
            }
            else if(sq==H1 && pos->board[G2]==WP) {
              if(pos->board[G3] != EMPTY)
                piece_placement[WHITE] -= 2*BISHOP_TRAPPED_A1H1;
              else if(pos->board[F3] == WP)
                piece_placement[WHITE] -= BISHOP_TRAPPED_A1H1;
              else
                piece_placement[WHITE] -= BISHOP_TRAPPED_A1H1/2;
            }
          }
          else {
            if(sq==A8 && pos->board[B7]==BP) {
              if(pos->board[B6] != EMPTY)
                piece_placement[BLACK] -= 2*BISHOP_TRAPPED_A1H1;
              else if(pos->board[C6] == BP)
                piece_placement[BLACK] -= BISHOP_TRAPPED_A1H1;
              else
                piece_placement[BLACK] -= BISHOP_TRAPPED_A1H1/2;
            }
            else if(sq==H8 && pos->board[G7]==BP) {
              if(pos->board[G6] != EMPTY)
                piece_placement[BLACK] -= 2*BISHOP_TRAPPED_A1H1;
              else if(pos->board[F6] == BP)
                piece_placement[BLACK] -= BISHOP_TRAPPED_A1H1;
              else
                piece_placement[BLACK] -= BISHOP_TRAPPED_A1H1/2;
            }
          }
        }
      }
      // Bishops in holes:
      if(square_is_hole(pos, sq, side)) {
        x = evaluate_bishop_in_hole(pos, sq, side);
        misc[side] += x; e_misc[side] += x;
      }
    }

    // Evaluate rooks:
    for(sq = RookListStart(pos, side); sq <= H8; sq = NextPiece(pos, sq)) {

      // Compute mobility
      x = 0;
      ptr = MobilityIncrement[side];
      for(tosq = sq + 1; pos->board[tosq] == EMPTY; tosq++) x++;
      x += ptr[pos->board[tosq]];
      for(tosq = sq - 1; pos->board[tosq] == EMPTY; tosq--) x++;
      x += ptr[pos->board[tosq]];
      for(tosq = sq + 16; pos->board[tosq] == EMPTY; tosq += 16) x++;
      x += ptr[pos->board[tosq]];
      for(tosq = sq - 16; pos->board[tosq] == EMPTY; tosq -= 16) x++;
      x += ptr[pos->board[tosq]];
      x = Max(x, 0);
      mobility[side] += RMobBonus[x]; e_mobility[side] += RMobBonusEndgame[x];
      if(x <= 3 && !(ph->open_files[side] & FileMask[file(sq)]))
        passive_pieces[side]++;
      // Rooks on 7th and 8th rank:
      if(PawnRank[side][sq] >= RANK_7) rooks_on_7th[side] += 2;

      // Bonus for open files:
      if(ph->open_files[side] & FileMask[file(sq)]) {
        piece_placement[side] += ROOK_OPEN_FILE_BONUS;
      }
      else if(x <= 4) { // Not open file, and poor mobility 
        // Is the rook trapped inside a king which has lost the right to
        // castle? 
        ksq = KingSquare(pos, side); 
        if(file(ksq) >= FILE_E && file(sq) > file(ksq) && 
           (PawnRank[side][ksq] == RANK_1 || rank(ksq) == rank(sq))) {
          for(tosq = file(ksq) + 1; tosq <= FILE_H; tosq++)
            if(ph->open_files[side] & FileMask[tosq]) break;
          if(tosq > FILE_H) {
            d++;
            piece_placement[side] -= CanCastle(pos, side) ?
              (TRAPPED_ROOK - x * 16) / 2 : (TRAPPED_ROOK - x * 16);
          }
        }
        if(file(ksq) <= FILE_D && file(sq) < file(ksq) && 
           (PawnRank[side][ksq] == RANK_1 || rank(ksq) == rank(sq))) {
          for(tosq = file(ksq) - 1; tosq >= FILE_A; tosq--)
            if(ph->open_files[side] & FileMask[tosq]) break;
          if(tosq < FILE_A) {
            d++;
            piece_placement[side] -= CanCastle(pos, side) ?
              (TRAPPED_ROOK - x * 16) / 2 : (TRAPPED_ROOK - x * 16);
          }
        }
      }
      // Rooks in holes:
      if(square_is_hole(pos, sq, side)) {
        x = evaluate_rook_in_hole(pos, sq, side);
        misc[side] += x; e_misc[side] += x;
      }
    }

    // Evaluate queens:
    for(sq = QueenListStart(pos, side); sq <= H8; sq = NextPiece(pos, sq)) {

      // Queens on 7th and 8th rank: 
      if(PawnRank[side][sq] >= RANK_7) rooks_on_7th[side]++;

      // Penalize early queen activity:
      if(PawnRank[side][sq] != RANK_1) misc[side] -= d*8;

      // Compute mobility 
      x = 0;
      ptr = MobilityIncrement[side];
      for(tosq = sq + 15; pos->board[tosq] == EMPTY; tosq += 15) x++;
      x += ptr[pos->board[tosq]];
      for(tosq = sq - 15; pos->board[tosq] == EMPTY; tosq -= 15) x++;
      x += ptr[pos->board[tosq]];
      for(tosq = sq + 17; pos->board[tosq] == EMPTY; tosq += 17) x++;
      x += ptr[pos->board[tosq]];
      for(tosq = sq - 17; pos->board[tosq] == EMPTY; tosq -= 17) x++;
      x += ptr[pos->board[tosq]];
      for(tosq = sq + 1; pos->board[tosq] == EMPTY; tosq++) x++;
      x += ptr[pos->board[tosq]];
      for(tosq = sq - 1; pos->board[tosq] == EMPTY; tosq--) x++;
      x += ptr[pos->board[tosq]];
      for(tosq = sq + 16; pos->board[tosq] == EMPTY; tosq += 16) x++;
      x += ptr[pos->board[tosq]];
      for(tosq = sq - 16; pos->board[tosq] == EMPTY; tosq -= 16) x++;
      x += ptr[pos->board[tosq]];
      x = Max(x, 0);
      mobility[side] += QMobBonus[x]; e_mobility[side] += QMobBonusEndgame[x];
    }

    // Development eval: 
    development[side] = DevelopmentPenalty[d];
  }

  for(side = WHITE; side <= BLACK; side++) {
    // Bonus for queens/rooks on 7th rank: 
    misc[side] += RooksOn7thBonus[rooks_on_7th[side]];
    if(PawnRank[side^1][KingSquare(pos, side^1)] == RANK_1)
      e_misc[side] += RooksOn7thBonus[rooks_on_7th[side]];

    // Penalty for multiple passive pieces:
    misc[side] -= MultiplePassivePenalty[passive_pieces[side]];

    // Bishop pair:
    if(bishop_colour[side] == 3) {
      misc[side] += BishopPairBonus[ph->centre];
      e_misc[side] += BishopPairBonus[ph->centre];
      if(bishops[side^1] + knights[side^1] == 0) {
        misc[side] += 30; e_misc[side] += 30;
      }
    }

    // Adjust knight and rook material values by number of pawns, using
    // Larry Kaufmann's formulas: 
    misc[side] += rooks[side]*(5-pawns[side])*32;
    e_misc[side] += rooks[side]*(5-pawns[side])*32;
    misc[side] += knights[side]*(pawns[side]-6)*16;
    e_misc[side] += knights[side]*(pawns[side]-6)*16;

    // Redundancy of major pieces, again based on Kaufmann's paper:
    if(rooks[side]) {
      misc[side] -= (rooks[side]-1)*32 + queens[side]*16;
      e_misc[side] -= (rooks[side]-1)*32 + queens[side]*16;
    }
    if(np_material[WHITE]+np_material[BLACK] > ENDGAME_MATERIAL) {
      // King safety:
      king_safety[side] = evaluate_king_safety(pos, side, shield[side], 
                                               ph->open_files[side^1]);

      // Pawn storms at positions with opposite castling: 
      if(file(KingSquare(pos, side)) >= FILE_F && 
         file(KingSquare(pos, side^1)) <= FILE_D)
        storm[side] = ph->q_storm[side];
      else if(file(KingSquare(pos, side)) <= FILE_D && 
              file(KingSquare(pos, side^1)) >= FILE_F)
        storm[side] = ph->k_storm[side];

      // Space:
      space[side] = 
        (ph->space[side] * (np_material[side]-Q_VALUE-R_VALUE-B_VALUE)) / 256;
      if(space[side] < 0) space[side] = 0;
    }

    // Passed pawns:
    for(x = 0; x < 8 && ph->passed_pawn_squares[side][x] != 0; x++) {
      int sq = ph->passed_pawn_squares[side][x];
      int rank = PawnRank[side][sq];
      int step = PawnPush[side];
      int bonus = PpBonus[rank];
      int pawn = PawnOfColour(side);
      int xknight = KnightOfColour(side^1), xbishop = BishopOfColour(side^1);
      int xking = KingOfColour(side^1);
      int rook = RookOfColour(side), xrook = RookOfColour(side^1);

      if(ColourOfPiece(pos->board[sq+step]) == (side^1)) bonus /= 2;
      else if(rank >= RANK_6 && pos->board[sq+step] == EMPTY && 
              queens[side^1] == 0 && see(pos, sq, sq+step) == 0) {
        // Pawn can safely advance, increase bonus: 
        if(rank == RANK_7) bonus += (side == us)? 200 : 100;
        else bonus += (side == us)? 40 : 16;
      }

      // Is there a friendly pawn beside or diagonally behind?
      if(pos->board[sq-1] == pawn || pos->board[sq+1] == pawn)
        bonus += PpBonus[rank];
      else for(d = sq - step - 1; d <= sq - step + 1; d += 2) {
        if(pos->board[d] == pawn) {
          // This is a protected pawn, and the bonus should be increased.
          // We increase by a smaller amount if an enemy king, bishop or
          // knight hinders the advance of the pawn duo.
          if(pos->board[sq+step] == xking || pos->board[sq+step] == xbishop ||
             pos->board[sq+step] == xknight || 
             pos->board[d+step] == xking || pos->board[d+step] == xbishop ||
             pos->board[d+step] == xknight)
            bonus += PpBonus[rank]/2;
          else
            bonus += PpBonus[rank];
        }
      }

      // Is the enemy king somewhere in the pawn's path?
      d = file(KingSquare(pos, side^1)) - file(sq);
      if(abs(d) <= 1 && (rank(KingSquare(pos, side^1)) - rank(sq)) * step >= 0)
        bonus -= PpBonus[rank] / 4;

      // Is there a friendly or enemy rook behind the pawn?
      for(tosq = sq - step; pos->board[tosq] == EMPTY; tosq -= step);
      if(pos->board[tosq] == rook) bonus += PpBonus[rank] / 4;
      else if(pos->board[tosq] == xrook) bonus -= PpBonus[rank] / 4;

      // A passed rook pawn is very strong against a knight.
      if(!queens[side^1] && !rooks[side^1] && !bishops[side^1] &&
         knights[side^1] == 1 && (file(sq) == FILE_A || file(sq) == FILE_H))
        bonus += bonus/2;

      passed_pawns[side] += bonus;

      // If the other side has only a king, check whether the pawn is
      // unstoppable: 
      if(np_material[side^1] == 0) {
        int qsq, tempo, mtg;
        if((side^1) == us) tempo = 1; else tempo = 0;
        qsq = file(sq) + (side^1)*A8;
        d = DISTANCE(sq, qsq) - DISTANCE(KingSquare(pos, side^1), qsq) + tempo;
        if(d < 0) {
          mtg = RANK_8-PawnRank[side][sq];
          for(tosq = sq + step; pos->board[tosq] != OUTSIDE; tosq += step)
            if(pos->board[tosq] != EMPTY) {mtg++; d++;}
          if(d < 0) {
            has_unstoppable[side]++;
            moves_to_go[side] = Min(moves_to_go[side], mtg);
          }
        }
      }

      // Give king activity bonus for king close to the passed pawn:
      if(side == WHITE) {
        king_activity[WHITE] += 
          KingActivityBonus[KingSquare(pos, WHITE)-sq+128] * 2;
        king_activity[BLACK] += 
          KingActivityBonus[KingSquare(pos, BLACK)-sq+128] * 2;
      }
      else {
        king_activity[WHITE] += 
          KingActivityBonus[sq-KingSquare(pos, WHITE)+128] * 2;
        king_activity[BLACK] += 
          KingActivityBonus[sq-KingSquare(pos, BLACK)+128] * 2;
      }
    }
  }
  if(has_unstoppable[WHITE] && !has_unstoppable[BLACK])
    passed_pawns[WHITE] += R_VALUE - 64*moves_to_go[WHITE];
  else if(has_unstoppable[BLACK] && !has_unstoppable[WHITE])
    passed_pawns[BLACK] += R_VALUE - 64*moves_to_go[BLACK];

  for(side = WHITE; side <= BLACK; side++) {
    ev->king_safety[side] = king_safety[side];
    ev->passed_pawns[side] = passed_pawns[side];
  }
 
  result += ((pawn_structure[us] - pawn_structure[them])
             * Options->ps_weight) / 128;
  e_result += ((e_pawn_structure[us] - e_pawn_structure[them])
             * Options->e_ps_weight) / 128;
  result += ((mobility[us] - mobility[them]) * Options->mob_weight) / 128;
  e_result += 
    ((e_mobility[us] - e_mobility[them]) * Options->e_mob_weight) / 128;

  result += ((space[us] - space[them]) * Options->space_weight) / 128;

  result += piece_placement[us] - piece_placement[them];
  e_result += piece_placement[us] - piece_placement[them];

  result += ((passed_pawns[us] - passed_pawns[them]) 
             * Options->pp_weight) / 128;
  e_result += ((passed_pawns[us] - passed_pawns[them])
               * Options->e_pp_weight) / 128;

  king_activity[WHITE] -= king_activity[WHITE]/4;
  king_activity[BLACK] -= king_activity[BLACK]/4;
  e_result += king_activity[us] - king_activity[them];

  result += misc[us] - misc[them];
  e_result += e_misc[us] - e_misc[them];
  result += ((development[us] - development[them])
             * Options->development_weight) / 128;
  
  shield[us] = (shield[us] + Max(ks_shield[us], qs_shield[us])) / 2;
  shield[them] = (shield[them] + Max(ks_shield[them], qs_shield[them])) / 2;
  result += (shield[us] - shield[them]) * ShieldFactor[ph->centre];
  
  result += ((king_safety[us] * Options->ks_weight[us]) -
             (king_safety[them] * Options->ks_weight[them])) / 128;

  result += storm[us] - storm[them];

  // Reduce endgame score in the case of opposite-coloured bishops: 
  if(bishops[WHITE]==1 && bishops[BLACK]==1 && 
     bishop_colour[WHITE] != bishop_colour[BLACK] &&
     scale[WHITE] == 128 && scale[BLACK] == 128) {
    if(np_material[WHITE]+np_material[BLACK]==2*B_VALUE)
      scale[WHITE] = scale[BLACK] = 64;
    else 
      scale[WHITE] = scale[BLACK] = 96;
  }

  result += TEMPO_BONUS_MIDGAME; e_result += TEMPO_BONUS_ENDGAME;

  if(e_result > 0) e_result = (e_result*scale[us]) / 128;
  else e_result = (e_result*scale[them]) / 128;

  if(np_material[WHITE]+np_material[BLACK] >= MIDGAME_MATERIAL) 
    result = (result & ~(GRAIN_SIZE-1));
  else if(np_material[WHITE]+np_material[BLACK] <= ENDGAME_MATERIAL) 
    result = (e_result & ~(GRAIN_SIZE-1));
  else result = 
    ((((np_material[WHITE]+np_material[BLACK]-ENDGAME_MATERIAL) * result) /
      (MIDGAME_MATERIAL-ENDGAME_MATERIAL) +
      ((MIDGAME_MATERIAL-np_material[WHITE]-np_material[BLACK]) * e_result) /
      (MIDGAME_MATERIAL-ENDGAME_MATERIAL)) & ~(GRAIN_SIZE-1));

 end_of_evaluate:
  if(Options->use_eval_cache)
    store_eval(pos, result, ev->king_safety, ev->passed_pawns);
  return result;
}

int approx_eval_delta(const position_t *pos, move_t m) {
  int c = PieceOfColourAndType(pos->xside, CAPTURE(m));
  int p = PieceOfColourAndType(pos->side, PIECE(m));
  int pr = PROMOTION(m);

  if(pr) {
    pr = PieceOfColourAndType(pos->side, pr);
    return (PieceValues[c] + PieceValues[pr] - PieceValues[PAWN] 
            - PSQ(p, FROM(m)) + PSQ(pr, TO(m)) + PSQ(c, TO(m)));
  }
  return (PieceValues[c] - PSQ(p, FROM(m)) + PSQ(p, TO(m)) + PSQ(c, TO(m)));
}  

bool draw(const position_t *pos) {
  int i;
  if(pos->rule50 > 100) return true;
  if(pos->rule50 == 100 && !position_is_check(pos)) return true;
  if(pos->material[WHITE] == 0 && pos->material[BLACK] == 0) return true;
  if(PawnCount(pos, WHITE) == 0 && PawnCount(pos, BLACK) == 0 &&
     pos->material[WHITE] + pos->material[BLACK] < R_VALUE)
    return true;
  for(i = 2; i < Min(pos->gply, pos->rule50); i += 2)
    if(pos->previous_keys[pos->gply - i] == pos->key) return true;
  return false;
}
