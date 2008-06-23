#include "viper.h"

uint8 MateTable[128] = {
  100, 90, 80, 70, 70, 80, 90, 100, 0, 0, 0, 0, 0, 0, 0, 0,
  90, 70, 60, 50, 50, 60, 70, 90, 0, 0, 0, 0, 0, 0, 0, 0,
  80, 60, 40, 30, 30, 40, 60, 80, 0, 0, 0, 0, 0, 0, 0, 0,
  70, 50, 30, 20, 20, 30, 50, 70, 0, 0, 0, 0, 0, 0, 0, 0,
  70, 50, 30, 20, 20, 30, 50, 70, 0, 0, 0, 0, 0, 0, 0, 0,
  80, 60, 40, 30, 30, 40, 60, 80, 0, 0, 0, 0, 0, 0, 0, 0,
  90, 70, 60, 50, 50, 60, 70, 90, 0, 0, 0, 0, 0, 0, 0, 0,
  100, 90, 80, 70, 70, 80, 90, 100, 0, 0, 0, 0, 0, 0, 0, 0
};

int DistanceBonus[8] = {0, 0, 100, 80, 60, 40, 20, 10};

int pawn_endgame(const position_t *pos) {
  return ((pos->material[WHITE] == 
           pos->piece_count[WHITE][PAWN] * P_VALUE) &&
          (pos->material[BLACK] == 
           pos->piece_count[BLACK][PAWN] * P_VALUE));
}         

int scale_endgame_eval(const position_t *pos, int scale[], p_hashentry_t *ph) {
  int winner, loser;

  if(pos->material[WHITE] == 0) scale[WHITE] = 0;
  if(pos->material[BLACK] == 0) scale[BLACK] = 0;

  if(pos->material[WHITE] >= pos->material[BLACK]) {
    winner = WHITE; loser = BLACK;
  }
  else {
    winner = BLACK; loser = WHITE;
  }
  
  // Easy mates of a lone king: 
  if(pos->material[loser] == 0 && pos->material[winner] >= R_VALUE) {
    if(pos->material[winner] == 2*N_VALUE) {
      if(KnightCount(pos, winner) == 2) { // KNNK, draw.
        scale[winner] = 0; return 0;
      }
    }
    // Use a a generic KXK eval:
    return KXK;
  }

  // A minor piece alone cannot win: 
  if(PawnCount(pos, WHITE) == 0 && pos->material[WHITE] == N_VALUE)
    scale[WHITE] = 0;
  if(PawnCount(pos, BLACK) == 0 && pos->material[BLACK] == N_VALUE)
    scale[BLACK] = 0;

  // KQKR 
  if(pos->material[winner] == Q_VALUE && pos->material[loser] == R_VALUE)
    return KQKR;

  // KRKP 
  if(pos->material[winner] == R_VALUE && pos->material[loser] == P_VALUE)
    return KRKP;

  // KRKN and KRKB 
  if(pos->material[winner] == R_VALUE && pos->material[loser] == N_VALUE) {
    if(HasKnights(pos, loser)) return KRKN;
    else return KRKB;
  }

  // Without pawns, it is hard to win with only a minor piece up: 
  if(!HasPawns(pos, winner) && scale[winner] > 0 &&
     pos->material[winner]-pos->material[loser] <= B_VALUE) {
    if(pos->material[winner] == pos->material[loser]) {
      scale[winner] = 0;
      if(!HasPawns(pos, loser)) scale[loser] = 0;
      return 0;
    }
    if(pos->material[winner] == R_VALUE + B_VALUE && HasRooks(pos, loser)) {
      if(HasBishops(pos, winner)) { // KRBKR
        scale[winner] = 32; scale[loser] = 0; 
        return 0;
      }
      else { // KRNKR 
        scale[winner] = 8; scale[loser] = 0;
        return 0;
      }
    }
    scale[winner] = 64; 
    if(!HasPawns(pos, loser)) scale[loser] = 0; 
    return 0;
  }

  return 0;
}
  
int krkb_eval(const position_t *pos) {
  int defender = (pos->material[WHITE] == R_VALUE)? BLACK : WHITE;

  if(defender == pos->side) return -MateTable[KingSquare(pos, defender)];
  else return MateTable[KingSquare(pos, defender)];
}

int KNDistancePenalty[8] = {0, 0, 4, 10, 20, 32, 48, 70};

int krkn_eval(const position_t *pos) {
  int defender = (pos->material[WHITE] == R_VALUE)? BLACK : WHITE;
  int attacker = defender^1;
  int defending_ksq = KingSquare(pos, defender);
  int nsq = KnightListStart(pos, defender);
  int result;

  result = 10 + MateTable[defending_ksq] 
    + KNDistancePenalty[Distance[defending_ksq - nsq]];

  return(attacker == pos->side)? result : -result;
}

#define KRKP_WIN (R_VALUE-Distance[wksq-bpsq])
  
int krkp_eval(const position_t *pos) {
  int winner = (pos->piece_count[BLACK][PAWN] > 0)? WHITE : BLACK;
  int loser = winner^1;
  int wksq, wrsq, bksq, bpsq, qsq, tempo, sign;

  wksq = KingSquare(pos, winner); wrsq = RookListStart(pos, winner);
  bksq = KingSquare(pos, loser); bpsq = PawnListStart(pos, loser);
  if(winner == BLACK) {
    wksq ^= 0x70; wrsq ^= 0x70; bksq ^= 0x70; bpsq ^= 0x70;
  }
  qsq = file(bpsq);  // Queening square 
  tempo = (pos->side == winner)? 1 : 0;
  sign = tempo? 1 : -1;
  
  if(wksq<bpsq && file(wksq)==file(bpsq))
    return sign * KRKP_WIN;
  if(Distance[wksq-qsq] + 1 - tempo < Distance[bksq-qsq])
    return sign * KRKP_WIN;
  if(Distance[bksq-bpsq]-(tempo^1) >= 3 && Distance[bksq-wrsq] >= 3)
    return sign * KRKP_WIN;
  if(rank(bpsq) <= RANK_3 && Distance[bksq-bpsq] == 1 && rank(wksq) >= RANK_4
     && Distance[wksq-bpsq] - tempo > 2)
    return sign * (80-Distance[wksq-bpsq]*8);

  return sign * (200 
                 + KingActivityBonus[bpsq-wksq+128]
                 - KingActivityBonus[bpsq-bksq+128]
                 + Distance[bpsq-qsq]*8);
}
  
int kxk_eval(const position_t *pos) {
  int winner = pos->material[WHITE]? WHITE : BLACK;
  int loser = winner^1;
  int result;

  result = (pos->material[winner] 
            + MateTable[KingSquare(pos, loser)]
            + DistanceBonus[DISTANCE(KingSquare(pos, winner), 
				     KingSquare(pos, loser))]);

  if(HasQueens(pos, winner) || HasRooks(pos, winner) ||
     pos->material[winner] >= 8*P_VALUE)
    result += KNOWN_WIN;

  return (winner == pos->side)? result : -result;
}

int kqkr_eval(const position_t *pos) {
  int winner = HasQueens(pos, WHITE)? WHITE : BLACK;
  return (Q_VALUE - R_VALUE + MateTable[KingSquare(pos, winner^1)] 
          + DistanceBonus[DISTANCE(KingSquare(pos, winner), 
				   KingSquare(pos, winner^1))]);
}
