#include "glaurung.h"

//#define P_HASH_SIZE 65536 // 41 bytes * 65536 = 2624 kB
#define P_HASH_SIZE 1024

// Isolated, double and backward pawn penalties by file:
const int IpPenalty[8] = {7, 10, 14, 20, 20, 14, 10, 7};
const int DpPenalty[8] = {7, 10, 14, 20, 20, 14, 10, 7};
const int BpPenalty[8] = {7, 10, 14, 20, 20, 14, 10, 7};

// Bonus for being member of a pawn chain:
const int ChainBonus = 10;

// Penalty for multiple pawn structure defects:
const int MdpPenalty[9] = {0, 0, 3, 10, 25, 50, 60, 60, 60};

// Pawn storm tables for positions with opposite castling: */
const int8 QStormTable[128] = {
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  -15, -15, -15, -9, -3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  -3, -6, -6, -6, -3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  6, 12, 15, 12, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  15, 21, 21, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  21, 27, 27, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  21, 27, 27, 21, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};

const int8 KStormTable[128] = {
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, -3, -9, -15, -18, -18, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, -3, -6, -9, -12, -12, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 6, 6, 6, 6, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 6, 12, 18, 18, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 6, 18, 27, 24, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 21, 27, 21, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};

const uint8 SpaceBonus[128] = {
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 2, 4, 4, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 2, 4, 4, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
};

// Candidate passed pawn bonus by rank: 
const int CandidateBonus[8] = {0, 10, 10, 20, 33, 53, 0, 0};

static p_hashentry_t *PawnHashTable[MaxNumOfThreads]; 

void init_pawn_hash_table(int num_of_threads) {
  int i;
  free_pawn_hash_table();
  for(i = 0; i < num_of_threads; i++) {
    PawnHashTable[i]=(p_hashentry_t *)malloc(P_HASH_SIZE*sizeof(p_hashentry_t));
    memset(PawnHashTable[i], 0, P_HASH_SIZE * sizeof(p_hashentry_t));
  }
}

void free_pawn_hash_table(void) {
  for(int i = 0; i < MaxNumOfThreads; i++) 
    if(PawnHashTable[i] != NULL) {
      free(PawnHashTable[i]); PawnHashTable[i] = NULL;
    }
}

bool pawn_is_passed(const position_t *pos, int square, int side) {
  int file = file(square), xside = side^1;
  bitfile_t f1 = InFrontBF[side][rank(square)];
  bitfile_t f2 = 
    pos->pawn_files[xside][file-1] | pos->pawn_files[xside][file] |
    pos->pawn_files[xside][file+1];
  return !(f1 & f2);
}

// Note: pawn_is_candidate() assumes that the pawn is not passed!
bool pawn_is_candidate(const position_t *pos, int square, int side) {
  int rank = rank(square), file = file(square);
  bitfile_t bf = InFrontBF[side][rank];
  if(bf & (pos->pawn_files[side][file] | pos->pawn_files[side^1][file]))
    return false;
  if(BitCount[bf & pos->pawn_files[side^1][file-1]] +
     BitCount[bf & pos->pawn_files[side^1][file+1]] >= 2)
    return false;
  bf = BehindBF[side][rank] | SetMaskBF(square);
  bf &= (pos->pawn_files[side][file-1] | pos->pawn_files[side][file+1]);
  return bf;
}

bool pawn_is_isolated(const position_t *pos, int square, int side) {
  int file = file(square);
  return !(pos->pawn_files[side][file-1] | pos->pawn_files[side][file+1]);
}

bool pawn_is_doubled(const position_t *pos, int square, int side) {
  bitfile_t bf = pos->pawn_files[side][file(square)];
  bf &= BehindBF[side][rank(square)];
  return (bf & -bf);
}

p_hashentry_t *analyse_pawn_structure(const position_t *pos, int thread_id) {
  p_hashentry_t *ph = PawnHashTable[thread_id]+(pos->pkey&(P_HASH_SIZE-1));
  int side, sq;

  if(ph->key == pos->pkey) return ph;

  ph->key = pos->pkey;
  ph->score[WHITE] = ph->score[BLACK] = 0; 
  ph->e_score[WHITE] = ph->e_score[BLACK] = 0;
  ph->open_files[WHITE] = ph->open_files[BLACK] = 0xFF;
  ph->k_storm[WHITE] = ph->k_storm[BLACK] = 0;
  ph->q_storm[WHITE] = ph->q_storm[BLACK] = 0;
  ph->space[WHITE] = ph->space[BLACK] = 0;

  for(side=WHITE; side<=BLACK; side++) {
    int enemy_pawn = PawnOfColour(side^1), friendly_pawn = PawnOfColour(side);
    int num_of_passed_pawns = 0, num_of_defects = 0;
    for(sq = PawnListStart(pos, side); sq <= H8; sq = NextPiece(pos, sq)) {
      bool passed, candidate, chain, doubled, isolated, backward;
      int step = PawnPush[side], tosq;
      int file = file(sq), rank;
      int bonus;

      // The file occupied by this pawn is not open:
      ph->open_files[side] &= ~FileMask[file];

      // Pawn stroms:
      bonus = KStormTable[sq^(side*0x70)];
      if(bonus) {
        switch(file) {
        case FILE_H: 
          for(tosq = sq + step - 1; pos->board[tosq] != OUTSIDE; tosq += step)
            if(pos->board[tosq] == enemy_pawn) {
              if(pos->board[tosq-1] == enemy_pawn || 
                 pos->board[tosq+1] == enemy_pawn)
                bonus += bonus/2;
              else bonus *= 2;
              break;
            }
          break;
        case FILE_G:
          for(tosq = sq + step + 1; pos->board[tosq] != OUTSIDE; tosq += step)
            if(pos->board[tosq] == enemy_pawn) {
              if(pos->board[tosq-1] == enemy_pawn || 
                 pos->board[tosq+1] == enemy_pawn)
                bonus += bonus/2 + bonus/4;
              else bonus += bonus + bonus/2;
              break;
            }
          break;
        case FILE_F:
          for(tosq = sq + step + 1; pos->board[tosq] != OUTSIDE; tosq += step)
            if(pos->board[tosq] == enemy_pawn) {
              if(pos->board[tosq-1] == enemy_pawn || 
                 pos->board[tosq+1] == enemy_pawn)
                bonus += bonus/4;
              else bonus += bonus/2;
              break;
            }
          break;
        }
        ph->k_storm[side] += bonus;
      }

      bonus = QStormTable[sq^(side*0x70)];
      if(bonus) {
        switch(file) {
        case FILE_A: 
          for(tosq = sq + step + 1; pos->board[tosq] != OUTSIDE; tosq += step)
            if(pos->board[tosq] == enemy_pawn) {
              if(pos->board[tosq-1] == enemy_pawn || 
                 pos->board[tosq+1] == enemy_pawn)
                bonus += bonus/2;
              else bonus *= 2;
              break;
            }
          break;
        case FILE_B:
          for(tosq = sq + step - 1; pos->board[tosq] != OUTSIDE; tosq += step)
            if(pos->board[tosq] == enemy_pawn) {
              if(pos->board[tosq-1] == enemy_pawn || 
                 pos->board[tosq+1] == enemy_pawn)
                bonus += bonus/2 + bonus/4;
              else bonus += bonus + bonus/2;
              break;
            }
          break;
        case FILE_C:
          for(tosq = sq + step - 1; pos->board[tosq] != OUTSIDE; tosq += step)
            if(pos->board[tosq] == enemy_pawn) {
              if(pos->board[tosq-1] == enemy_pawn || 
                 pos->board[tosq+1] == enemy_pawn)
                bonus += bonus/4;
              else bonus += bonus/2;
              break;
            }
          break;
        }
        ph->q_storm[side] += bonus;
      }

      // Space:
      bonus = SpaceBonus[sq^(side*0x70)];
      if(bonus) {
        ph->space[side] += bonus;
        if(pos->board[sq-1] == friendly_pawn || 
           pos->board[sq+1] == friendly_pawn)
          ph->space[side] += bonus;
        else if(pos->board[sq-step-1]==friendly_pawn ||
                pos->board[sq-step+1]==friendly_pawn)
          ph->space[side] += bonus/2;
      }

      // Passed pawn?
      passed = pawn_is_passed(pos, sq, side);
      if(passed) 
        ph->passed_pawn_squares[side][num_of_passed_pawns++] = sq;

      // Isolated pawn?
      isolated = pawn_is_isolated(pos, sq, side);

      // Candidate passed pawn?
      if(passed || isolated) candidate = false;
      else candidate = pawn_is_candidate(pos, sq, side);

      // Doubled pawn?  Only the frontmost double pawn counts!
      doubled = pawn_is_doubled(pos, sq, side);

      // Member of a pawn chain or phalanx?
      chain = false;
      if(pos->board[sq-1]==friendly_pawn || pos->board[sq+1]==friendly_pawn)
        chain = true;
      else if(pos->board[sq-step-1] == friendly_pawn || 
              pos->board[sq-step+1] == friendly_pawn)
        chain = true;
      
      // Backward pawn?
      backward = false;
      if(!isolated && !passed && !chain) {
        backward = true;
        for(tosq=sq; pos->board[tosq]!=OUTSIDE; tosq-=step) {
          if(pos->board[tosq-1]==friendly_pawn || 
             pos->board[tosq+1]==friendly_pawn) {
            backward = false; break;
          }
        }
        if(pos->board[sq+step-1] == enemy_pawn || 
           pos->board[sq+step+1] == enemy_pawn)
          backward = false;
        if(backward) {
          for(tosq=sq+step; pos->board[tosq]!=OUTSIDE; tosq+=step) {
            if(pos->board[tosq+step-1]==enemy_pawn ||
               pos->board[tosq+step+1]==enemy_pawn) 
              break;
            if(pos->board[tosq-1]==friendly_pawn || 
               pos->board[tosq+1]==friendly_pawn) {
              backward = false; break;
            }
          }
        }
      }

      // Compute score for this pawn:
      file = file(sq), rank = PawnRank[side][sq];

      if(doubled) {
        ph->score[side] -= DpPenalty[file]; 
        ph->e_score[side] -= DpPenalty[file];
        num_of_defects++;
      }
      if(isolated) {
        ph->score[side] -= IpPenalty[file]; 
        ph->e_score[side] -= IpPenalty[file];
        num_of_defects++;
      }
      if(backward) {
        ph->score[side] -= BpPenalty[file];
        ph->e_score[side] -= BpPenalty[file];
        num_of_defects++;
      }
      if(chain) {
        ph->score[side] += ChainBonus; 
        ph->e_score[side] += ChainBonus;
      }
      if(candidate) {
        ph->score[side] += CandidateBonus[rank] / 2;
        ph->e_score[side] += CandidateBonus[rank];
      }
    }
    if(num_of_passed_pawns < 8)
      ph->passed_pawn_squares[side][num_of_passed_pawns] = 0;

    // Include open file information in pawn storm eval:
    if(ph->open_files[side] & FileMask[FILE_H])
      ph->k_storm[side] += 30;
    if(ph->open_files[side] & FileMask[FILE_G])
      ph->k_storm[side] += 30;
    if(ph->open_files[side] & FileMask[FILE_F])
      ph->k_storm[side] += 20;
    if(ph->open_files[side] & FileMask[FILE_A])
      ph->q_storm[side] += 20;
    if(ph->open_files[side] & FileMask[FILE_B])
      ph->q_storm[side] += 30;
    if(ph->open_files[side] & FileMask[FILE_C])
      ph->q_storm[side] += 20;

    // Add progressive penalty for multiple pawn structure defects:
    ph->score[side] -= MdpPenalty[num_of_defects];
    ph->e_score[side] -= MdpPenalty[num_of_defects];
  }
  if(ph->space[WHITE] > 24) ph->space[WHITE] = 24;
  if(ph->space[BLACK] > 24) ph->space[BLACK] = 24;

  // Analyse the central pawn structure.  The following types of central
  // structures are defined:
  //
  //     OPEN:         At most one pawn on the e and d files.
  //     HALF-OPEN:    Two or three pawns on the e and d files, and no pawn
  //                   is blocked.
  //     HALF-CLOSED:  Two, three or four pawns on the e and d files, and 
  //                   there is a pawn ram.
  //     TENSION:      A central pawn capture is possible.
  //     UNRESLOVED:   Four central pawns, still not in direct contact.
  //     CLOSED:       Four central pawns, none of which can move.
  {
    int central_pawns[2] = {0,0};
    for(side = WHITE; side <= BLACK; side++) {
      if(~ph->open_files[side] & FileMask[FILE_D]) central_pawns[side]++;
      if(~ph->open_files[side] & FileMask[FILE_E]) central_pawns[side]++;
    }
    if(central_pawns[WHITE] + central_pawns[BLACK] <= 1) ph->centre = OPEN;
    else {
      ph->centre = UNKNOWN;
      // Is a central pawn capture available?
      for(sq = D2; sq <= D6; sq += 16) {
        if(pos->board[sq] == WP && pos->board[sq+17] == BP) {
          ph->centre = TENSION; break;
        }
      }
      if(ph->centre == UNKNOWN) {
        for(sq = E2; sq <= E6; sq += 16) {
          if(pos->board[sq] == WP && pos->board[sq+15] == BP) {
            ph->centre = TENSION; break;
          }
        }
      }
      if(ph->centre == UNKNOWN) {
        if(central_pawns[WHITE] + central_pawns[BLACK] <= 3) {
          // Is there a pawn ram?
          for(sq = D2; sq <= D7; sq += 16) {
            if(pos->board[sq] == WP && pos->board[sq+16] == BP) {
              ph->centre = HALF_CLOSED; break;
            }
          }
          if(ph->centre == UNKNOWN) {
            for(sq = E2; sq <= E7; sq += 16) {
              if(pos->board[sq] == WP && pos->board[sq+16] == BP) {
                ph->centre = HALF_CLOSED; break;
              }
            }
          }
          if(ph->centre == UNKNOWN) ph->centre = HALF_OPEN;
        }
        else { // Four central pawns
          ph->centre = UNRESOLVED;
          for(sq = D2; sq <= D6; sq += 16) {
            if(pos->board[sq] == WP && pos->board[sq+16] == BP)
              ph->centre = HALF_CLOSED;
          }
          for(sq = E2; sq <= E6; sq += 16) {
            if(pos->board[sq] == WP && pos->board[sq+16] == BP) {
              if(ph->centre == UNRESOLVED) ph->centre = HALF_CLOSED;
              else ph->centre = CLOSED;
            }
          }
        }
      }
    }
  }
  return ph;
}
