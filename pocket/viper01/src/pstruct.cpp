#include "viper.h"

#define P_HASH_SIZE 1024 //65536

// Isolated, double and backward pawn penalties by file:
const int IpPenalty[8] = {7, 10, 14, 20, 20, 14, 10, 7};
const int DpPenalty[8] = {7, 10, 14, 20, 20, 14, 10, 7};
const int BpPenalty[8] = {7, 10, 14, 20, 20, 14, 10, 7};

// Bonus for being member of a pawn chain:
const int ChainBonus = 10;

// Penalty for multiple pawn structure defects:
const int MdpPenalty[9] = {0, 0, 3, 10, 25, 50, 60, 60, 60};

// Candidate passed pawn bonus by rank: */
const int CandidateBonus[8] = {0, 10, 10, 20, 33, 53, 0, 0};

p_hashentry_t *PawnHashTable; 

void init_pawn_hash_table() {
  free_pawn_hash_table();
  PawnHashTable=(p_hashentry_t *)malloc(P_HASH_SIZE*sizeof(p_hashentry_t));
  memset(PawnHashTable, 0, P_HASH_SIZE * sizeof(p_hashentry_t));
}

void free_pawn_hash_table(void) {
    if(PawnHashTable != NULL) 
      free(PawnHashTable);
    PawnHashTable = NULL;
}

p_hashentry_t *analyse_pawn_structure(const position_t *pos) {
  p_hashentry_t *ph = PawnHashTable + (pos->pkey&(P_HASH_SIZE-1));
  int side, sq;

  if(ph->key == pos->pkey) return ph;

  ph->key = pos->pkey;
  ph->score[WHITE] = ph->score[BLACK] = 0; 
  ph->e_score[WHITE] = ph->e_score[BLACK] = 0;
  ph->open_files[WHITE] = ph->open_files[BLACK] = 0xFF;

  for(side=WHITE; side<=BLACK; side++) {
    int enemy_pawn = PawnOfColour(side^1), friendly_pawn = PawnOfColour(side);
    int num_of_passed_pawns = 0, num_of_defects = 0;
    for(sq = PawnListStart(pos, side); sq <= H8; sq = NextPiece(pos, sq)) {
      bool passed, candidate, chain, doubled, isolated, backward;
      int step = PawnPush[side], tosq;
      int file = file(sq), rank;

      // The file occupied by this pawn is not open:
      ph->open_files[side] &= ~FileMask[file];

      // Passed pawn?
      passed = true;
      for(tosq = sq + step; pos->board[tosq] != OUTSIDE; tosq += step) {
        if(pos->board[tosq-1]==enemy_pawn||pos->board[tosq]==enemy_pawn
           ||pos->board[tosq+1]==enemy_pawn) { // not passed.
          passed = false; break;
        }
      }

      // Candidate passed pawn?
      if(passed) candidate = false;
      else {
        int x = 0;
        candidate = true;
        for(tosq = sq + step; pos->board[tosq] != OUTSIDE; tosq += step) {
          if(TypeOfPiece(pos->board[tosq]) == PAWN) {
            candidate = 0; break;
          }
          if(pos->board[tosq-1] == enemy_pawn) x++;
          if(pos->board[tosq+1] == enemy_pawn) x++;
        }
        if(x >= 2) candidate = false;
        if(candidate) {
          candidate = false;
          for(tosq = sq; pos->board[tosq] != OUTSIDE; tosq -= step) {
            if(pos->board[tosq-1]==friendly_pawn || 
	       pos->board[tosq+1]==friendly_pawn) {
              candidate = true; break;
            }
          }
        }
      }

      // Doubled pawn?  Only the frontmost double pawn counts!
      doubled = false;
      for(tosq=sq-step; pos->board[tosq]!=OUTSIDE; tosq-=step) {
        if(pos->board[tosq]==friendly_pawn) {
          doubled = true; break;
        }
      }

      // Isolated pawn?
      isolated = true;
      for(rank=RANK_2; rank<=RANK_7; rank++) {
        if(pos->board[rank*16+file-1]==friendly_pawn || 
           pos->board[rank*16+file+1]==friendly_pawn) {
          isolated = false; break;
        }
      }

      // Backward pawn?
      backward = false;
      if(!isolated && !passed) {
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
      if(passed) 
        ph->passed_pawn_squares[side][num_of_passed_pawns++] = sq;

      // Member of a pawn chain or phalanx?
      chain = false;
      if(pos->board[sq+1]==friendly_pawn || pos->board[sq+2]==friendly_pawn)
        chain = true;
      else if(pos->board[sq-step-1] == friendly_pawn || 
	      pos->board[sq-step+1] == friendly_pawn)
	chain = true;
      
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

    // Add progressive penalty for multiple pawn structure defects:
    ph->score[side] -= MdpPenalty[num_of_defects];
    ph->e_score[side] -= MdpPenalty[num_of_defects];
  }

  return ph;
}
