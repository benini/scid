#include "glaurung.h"

static const uint8 MateTable[128] = {
  100, 90, 80, 70, 70, 80, 90, 100, 0, 0, 0, 0, 0, 0, 0, 0,
  90, 70, 60, 50, 50, 60, 70, 90, 0, 0, 0, 0, 0, 0, 0, 0,
  80, 60, 40, 30, 30, 40, 60, 80, 0, 0, 0, 0, 0, 0, 0, 0,
  70, 50, 30, 20, 20, 30, 50, 70, 0, 0, 0, 0, 0, 0, 0, 0,
  70, 50, 30, 20, 20, 30, 50, 70, 0, 0, 0, 0, 0, 0, 0, 0,
  80, 60, 40, 30, 30, 40, 60, 80, 0, 0, 0, 0, 0, 0, 0, 0,
  90, 70, 60, 50, 50, 60, 70, 90, 0, 0, 0, 0, 0, 0, 0, 0,
  100, 90, 80, 70, 70, 80, 90, 100, 0, 0, 0, 0, 0, 0, 0, 0
};

static const int DistanceBonus[8] = {0, 0, 100, 80, 60, 40, 20, 10};

bool pawn_endgame(const position_t *pos) {
  return ((pos->material[WHITE] == PawnCount(pos, WHITE) * P_VALUE) &&
          (pos->material[BLACK] == PawnCount(pos, BLACK) * P_VALUE));
}         

int scale_endgame_eval(const position_t *pos, int scale[], p_hashentry_t *ph) {
  int winner, loser;
  int np_material[2];

  // KPK 
  if(pos->material[WHITE] + pos->material[BLACK] == P_VALUE)
    return KPK;
  
  if(pos->material[WHITE] == 0) scale[WHITE] = 0;
  if(pos->material[BLACK] == 0) scale[BLACK] = 0;

  if(pos->material[WHITE] >= pos->material[BLACK]) {
    winner = WHITE; loser = BLACK;
  }
  else {
    winner = BLACK; loser = WHITE;
  }

  np_material[WHITE] = pos->material[WHITE] - PawnCount(pos, WHITE) * P_VALUE;
  np_material[BLACK] = pos->material[BLACK] - PawnCount(pos, BLACK) * P_VALUE;
  
  // Easy mates of a lone king: 
  if(pos->material[loser] == 0 && np_material[winner] >= R_VALUE) {
    // KNNK and KBNK 
    if(pos->material[winner] == 2*N_VALUE) {
      if(KnightCount(pos, winner) == 2) { // KNNK, draw.
        scale[winner] = 0; return 0;
      }
      if(KnightCount(pos, winner) == 1) // KBNK 
        return KBNK;
    }
    // Other endgames are handled by a generic KXK eval. 
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

  // KRPKR 
  if(pos->material[winner]==R_VALUE+P_VALUE && pos->material[loser]==R_VALUE)
    return KRPKR;

  // KRKN and KRKB 
  if(pos->material[winner] == R_VALUE && pos->material[loser] == N_VALUE) {
    if(HasKnights(pos, loser)) return KRKN;
    else return KRKB;
  }

  // KBPK draw with rook pawn and wrong bishop: 
  if(np_material[winner] == B_VALUE && HasBishops(pos, winner) &&
     (ph->open_files[winner] == 254 || ph->open_files[winner] == 127)) {
    int bsq = BishopListStart(pos, winner);
    int ksq = KingSquare(pos, loser);
    int queening_sq = H1*(ph->open_files[winner]&1)+loser*A8;
    if(SquareColour(queening_sq) != SquareColour(bsq)) {
      int psq, step = PawnPush[winner];
      for(psq = queening_sq - step; pos->board[psq] != PawnOfColour(winner);
          psq -= step);
      if(PawnRank[winner][psq] < PawnRank[winner][ksq] &&
         abs(file(ksq) - file(psq)) <= 1) {
        scale[winner] = 0; return 0;
      }
      else if(Distance[ksq-queening_sq] <= 1) {
        scale[winner] = 0; return 0;
      }
    }
  }

  // Several pawns against king: Draw if all pawns are on a rook file and the
  // defending king is well placed:
  if(pos->material[loser] == 0 && PawnCount(pos, winner) >= 2 &&
     np_material[winner] == 0 &&
     (ph->open_files[winner] == 127 || ph->open_files[winner] == 254)) {
    int ksq = KingSquare(pos, loser);
    int queening_sq = H1*(ph->open_files[winner]&1)+loser*A8;
    int psq, step = PawnPush[winner];
    for(psq = queening_sq - step; pos->board[psq] != PawnOfColour(winner);
        psq -= step);
    if(PawnRank[winner][psq] < PawnRank[winner][ksq] &&
       abs(file(ksq) - file(psq)) <= 1) {
      scale[winner] = 0; return 0;
    }
    else if(Distance[ksq-queening_sq] <= 1) {
      scale[winner] = 0; return 0;
    }
  }

  // KRPP vs KRP without a passed pawn is usually a draw if the defending 
  // king is in the path of the pawns: 
  if(pos->material[winner] == R_VALUE + P_VALUE + P_VALUE &&
     pos->material[loser] == R_VALUE + P_VALUE &&
     ph->passed_pawn_squares[winner][0] == 0) {
    int psq1 = PawnListStart(pos, winner), psq2 = NextPiece(pos, psq1);
    int rank1 = PawnRank[winner][psq1], rank2 = PawnRank[winner][psq2];
    int ksq = KingSquare(pos, loser);
    if(abs(file(psq1) - file(ksq)) <= 1 && abs(file(psq2) - file(ksq)) <= 1 &&
       PawnRank[winner][ksq] >= Max(rank1, rank2)) {
      switch(Max(rank1, rank2)) {
      case RANK_3: case RANK_2: scale[winner] = 30; break;
      case RANK_4: scale[winner] = 40; break;
      case RANK_5: scale[winner] = 70; break;
      case RANK_6: scale[winner] = 128; break;
      }
      return 0;
    }
  }

  // KQ vs KR and pawns: Fortress draw on back rank.
  if(pos->material[winner] == Q_VALUE && QueenCount(pos, winner) == 1 &&
     HasRooks(pos, loser) && HasPawns(pos, loser)) {
    int ksq = KingSquare(pos, loser), psq;
    int rook = RookOfColour(loser);
    int push = PawnPush[loser];
    if(PawnRank[loser][ksq] <= RANK_2 && 
       PawnRank[loser][KingSquare(pos, winner)] >= RANK_4)
      for(psq=PawnListStart(pos, loser); psq<=H8; psq=NextPiece(pos, psq)) 
        if(PawnRank[loser][psq] == RANK_2 && DISTANCE(psq, ksq) == 1 &&
           file(psq) != FILE_A && file(psq) != FILE_H &&
           (pos->board[psq+push-1] == rook || pos->board[psq+push+1] == rook)) {
          scale[winner] = 0;
          break;
        }
  }

  // KBP vs KN or KB is a draw when the defending king blocks the pawn and 
  // cannot be driven away by the bishop. 
  if(pos->material[winner] == B_VALUE + P_VALUE &&
     pos->material[loser] >= B_VALUE &&
     HasBishops(pos, winner)) {
    int bsq = BishopListStart(pos, winner);
    int psq = PawnListStart(pos, winner);
    int ksq = KingSquare(pos, loser);
    if(file(ksq) == file(psq) && PawnRank[winner][psq] < PawnRank[winner][ksq]
       && (SquareColour(ksq) != SquareColour(bsq) || 
           PawnRank[winner][ksq] <= RANK_6)) {
      scale[winner] = 0; return 0;
    }
  }

  // KBP vs KB with opposite-colored bishops is almost always a draw: 
  if(pos->material[winner] == B_VALUE + P_VALUE &&
     pos->material[loser] == B_VALUE) {
    int bsq1 = BishopListStart(pos, winner), bsq2 = BishopListStart(pos, loser);
    if(bsq1 <= H8 && bsq2 <= H8 && SquareColour(bsq1) != SquareColour(bsq2)) {
      int psq = PawnListStart(pos, winner), prank = PawnRank[winner][psq];
      if(prank <= RANK_5) {
        scale[winner] = 0; return 0;
      }
      else {
        int sq, step = PawnPush[winner];
        for(sq = psq + step; pos->board[sq] != OUTSIDE; sq += step) {
          if(pos->board[sq] == KingOfColour(loser)) {
            scale[winner] = 0; return 0;
          }
          if(attacked_by_non_king(pos, sq, loser) &&
             DISTANCE(bsq2, psq) >= 3) {
            scale[winner] = 0; return 0;
          }
        }
      }
    }
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


static uint8 KPK_bitbase[24576];

void init_kpk(void) {
  char fname[256];
  getcwd( fname, 256 );
#warning copy kpk.bin in install dir
  strcat( fname ,  "/kpk.bin" );
//   FILE *f = fopen("kpk.bin", "rb");
  FILE *f = fopen( fname, "rb" );
  int i;
  if(f == NULL) {
    printf("kpk.bin not found!\n");
    quit();
  }
  for(i = 0; i < 24576; i++) KPK_bitbase[i] = fgetc(f);
  fclose(f);
}

int probe_kpk(int wksq, int wpsq, int bksq, int side) {
  int index;
  wksq = COMPRESS(wksq); bksq = COMPRESS(bksq);
  wpsq = (wpsq & 3) + ((wpsq / 16) - 1) * 4;
  index = side + 2*bksq + 128*wksq + 8192*wpsq;
  return (KPK_bitbase[index/8] & (1<<(index&7)));
}

int kpk_eval(const position_t *pos) {
  int wksq, wpsq, bksq, side, sign;

  sign = PawnCount(pos, pos->side) > 0? 1 : -1;

  if(HasPawns(pos, WHITE)) {
    wksq = KingSquare(pos, WHITE); wpsq = PawnListStart(pos, WHITE);
    bksq = KingSquare(pos, BLACK); side = pos->side;
  }
  else {
    wksq = KingSquare(pos, BLACK)^0x70; wpsq = PawnListStart(pos, BLACK)^0x70;
    bksq = KingSquare(pos, WHITE)^0x70; side = pos->side^1;
  }
  if(file(wpsq) >= FILE_E) {
    wpsq ^= 7; wksq ^=7; bksq ^= 7;
  }
  if(probe_kpk(wksq, wpsq, bksq, side))
    return sign * (KNOWN_WIN + P_VALUE + rank(wpsq));

  return 0;
}
  
int krkb_eval(const position_t *pos) {
  int defender = (pos->material[WHITE] == R_VALUE)? BLACK : WHITE;
  if(defender == pos->side) return -MateTable[KingSquare(pos, defender)];
  else return MateTable[KingSquare(pos, defender)];
}

static const int KNDistancePenalty[8] = {0, 0, 4, 10, 20, 32, 48, 70};

int krkn_eval(const position_t *pos) {
  int defender = (pos->material[WHITE] == R_VALUE)? BLACK : WHITE;
  int attacker = defender^1;
  int defending_ksq = KingSquare(pos, defender);
  int nsq = KnightListStart(pos, defender);
  int result;
  
  result = 10 + MateTable[defending_ksq] + 
    KNDistancePenalty[Distance[defending_ksq - nsq]];
  return(attacker == pos->side)? result : -result;
}

#define KRKP_WIN (R_VALUE-Distance[wksq-bpsq])
  
int krkp_eval(const position_t *pos) {
  int winner = HasRooks(pos, WHITE)? WHITE : BLACK;
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
  
  if(wksq<bpsq && file(wksq)==file(bpsq)) return sign * KRKP_WIN;
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

static const uint8 KBNKtable[128] = {
  200, 190, 180, 170, 160, 150, 140, 130, 0, 0, 0, 0, 0, 0, 0, 0,
  190, 180, 170, 160, 150, 140, 130, 140, 0, 0, 0, 0, 0, 0, 0, 0,
  180, 170, 155, 140, 140, 125, 140, 150, 0, 0, 0, 0, 0, 0, 0, 0,
  170, 160, 140, 120, 110, 140, 150, 160, 0, 0, 0, 0, 0, 0, 0, 0,
  160, 150, 140, 110, 120, 140, 160, 170, 0, 0, 0, 0, 0, 0, 0, 0,
  150, 140, 125, 140, 140, 155, 170, 180, 0, 0, 0, 0, 0, 0, 0, 0,
  140, 130, 140, 150, 160, 170, 180, 190, 0, 0, 0, 0, 0, 0, 0, 0,
  130, 140, 150, 160, 170, 180, 190, 200, 0, 0, 0, 0, 0, 0, 0, 0
};

int kbnk_eval(const position_t *pos) {
  int winner, loser;
  int wksq, bksq, bsq, nsq, sign;
  
  winner = pos->material[WHITE]? WHITE : BLACK;
  loser = winner^1;
  sign = (winner == pos->side)? 1 : -1;
  wksq = KingSquare(pos, winner); bksq = KingSquare(pos, loser);
  bsq = BishopListStart(pos, winner); nsq = KnightListStart(pos, winner);
  if((file(bsq) + rank(bsq)) % 2) {
    wksq ^= 7; bksq ^= 7; bsq ^= 7; nsq ^= 7;
  }
  return sign*(KNOWN_WIN + DistanceBonus[Distance[wksq-bksq]] +
               KBNKtable[bksq]);
}
  
int kxk_eval(const position_t *pos) {
  int winner = pos->material[WHITE]? WHITE : BLACK;
  int loser = winner^1;
  int result = (pos->material[winner] 
                + MateTable[KingSquare(pos, loser)]
                + DistanceBonus[DISTANCE(KingSquare(pos, winner), 
                                         KingSquare(pos, loser))]);
  if(HasQueens(pos, winner) || HasRooks(pos, winner) ||
     pos->material[winner] >= 8*P_VALUE)
    result += KNOWN_WIN;

  return (winner == pos->side)? result : -result;
}

static const int KRPKRkingFileProximityBonus[11] = {
  -168, -144, -120, -96, -72, 0, 48, 128, 96, 24, -17
};

int krpkr_eval(const position_t *pos) {
  int winner = HasPawns(pos, WHITE)? WHITE : BLACK;
  int loser = winner^1;
  int wksq, wrsq, wpsq, bksq, brsq, qsq;
  int file, rank;
  int tempo;
  int result;

  wksq = KingSquare(pos, winner); wrsq = RookListStart(pos, winner);
  wpsq = PawnListStart(pos, winner);
  bksq = KingSquare(pos, loser); brsq = RookListStart(pos, loser);

  if(winner == BLACK) {
    wksq ^= 0x70; wrsq ^= 0x70; wpsq ^= 0x70; bksq ^= 0x70; brsq ^= 0x70;
  }
  if(file(wpsq) > FILE_D) {
    wksq ^= 7; wrsq ^= 7; wpsq ^= 7; bksq ^= 7; brsq ^= 7;
  }
  
  file = file(wpsq); rank = rank(wpsq); qsq = file + A8;
  tempo = (pos->side == winner)? 1 : 0;

  // Some simple special cases first.  If the pawn is not too far advanced
  // and the defending king defends the queening square, use the third-rank
  // defence. 
  if(rank <= RANK_5 && Distance[bksq-qsq] <= 1 && wksq <= H5) {
    if(rank(brsq) == RANK_6) return 0;
    if(rank <= RANK_3 && rank(wrsq) != RANK_6) return 0;
  }

  // The defending side saves a draw by checking from behind in case the
  // pawn has advanced to the 6th rank with the king behind.
  if(rank == RANK_6 && Distance[bksq-qsq] <= 1 && rank(wksq)+tempo <= RANK_6
     && (rank(brsq) == RANK_1 ||
         (!tempo && abs(file(brsq) - file) >= 3)))
    return 0;

  if(rank >= RANK_6 && bksq == qsq && rank(brsq) == RANK_1 && 
     (!tempo || Distance[wksq-wpsq] >= 2))
    return 0;

  // White pawn on a7 and rook on a8 is a draw if black's king is on
  // g7 or h7 and the black rook is behind the pawn 
  if(wpsq==A7 && wrsq==A8 && (bksq==H7 || bksq==G7) && 
     (brsq==A1 || brsq==A2 || brsq==A3 || 
      (file(brsq)==FILE_A && (file(wksq) >= FILE_D
                              || rank(wksq) <= RANK_5))))
    return 0;
  
  // Pawn on the 7th rank supported by the rook from behind wins if
  // the attacking king is closer to the queening square than the 
  // defending king, and the defending king cannot gain tempi by 
  // threatening the attacking rook. 
  if(rank == RANK_7 && file != FILE_A && file(wrsq)==file && wrsq != wpsq+16 &&
     Distance[wksq-qsq] < Distance[bksq-qsq]-2 + tempo &&
     Distance[wksq-qsq] < Distance[bksq-wrsq] + tempo)
    return (R_VALUE-Distance[wksq-qsq]+tempo);

  // Similar to the above, but with pawn further back. 
  if(file != FILE_A && file(wrsq)==file && wrsq < wpsq &&
     Distance[wksq-qsq] < Distance[bksq-qsq]-2 + tempo &&
     Distance[wksq-wpsq-16] < Distance[bksq-wpsq-16]-2 + tempo &&
     (Distance[bksq-wrsq] + tempo >= 3 ||
      (Distance[wksq-qsq] < Distance[bksq-wrsq] + tempo &&
       Distance[wksq-wpsq-16] < Distance[bksq-wrsq] + tempo))) {
  }
  if(file != FILE_A && file(wrsq)==file && wrsq < wpsq &&
     Distance[wksq-qsq] < Distance[bksq-qsq]-1 + tempo &&
     Distance[wksq-wpsq-16] < Distance[bksq-wpsq-16]-1 + tempo &&
     (Distance[bksq-wrsq] + tempo >= 3 ||
      (Distance[wksq-qsq] < Distance[bksq-wrsq] + tempo &&
       Distance[wksq-wpsq-16] < Distance[bksq-wrsq] + tempo))) {
    return (P_VALUE - Distance[wksq-qsq]*4 + rank*64);
  }

  // If the defending king blocks the pawn and the attacking king is too
  // far away, it's a draw. 
  if(rank <= RANK_5 && bksq == wpsq + 16 && Distance[wksq-wpsq]-tempo >= 2 && 
     Distance[wksq-brsq]-tempo >= 2)
    return 0;

  // More special cases should be added.  Some general code follows. 

  // Initial bonus by rank.  Reduce bonus for rook pawn. 
  result = rank*16 + P_VALUE;
  if(file == FILE_A) result -= 60;

  // The defending rook should try to be as far from the pawn as possible. 
  result -= 4*Distance[wpsq-brsq] + 6*abs(file(brsq)-file);

  // The defending king should try to be in front of the pawn.  It is best 
  // to keep it on the "short side" of the pawn.
  if(rank(bksq) >= rank) 
    result -= KRPKRkingFileProximityBonus[file-file(bksq)+7];
  else
    result += 40*(rank-rank(bksq));

  // If the attacking king is behind the pawn, the winning chances are 
  // smaller. 
  if(rank(wksq) < rank) result -= 16*(rank-rank(wksq));

  // The defending rook behind the pawn reduces winning chances.
  if(brsq < wpsq && file(brsq) == file) result -= 40;

  // Stretch big scores.
  if(result > P_VALUE) result += (result-P_VALUE)*4; 

  return tempo? result : -result;
}

int kqkr_eval(const position_t *pos) {
  int winner = HasQueens(pos, WHITE)? WHITE : BLACK;
  return (Q_VALUE - R_VALUE + MateTable[KingSquare(pos, winner^1)] 
          + DistanceBonus[DISTANCE(KingSquare(pos, winner), 
                                   KingSquare(pos, winner^1))]);
}
