#include "glaurung.h"

#define PAWN_MASK 1
#define KNIGHT_MASK 2
#define BISHOP_MASK 4
#define ROOK_MASK 8
#define QUEEN_MASK 16

static uint8 AttackDirections[BK+1][256];

struct step_info_t {
  int next_step;
  int next_bf;
};

static step_info_t StepInfo[BK][256];

static uint8 AttackDeltaMask[2][256];

static const uint8 AttackPatternBonus[256] = {
  0, 2, 6, 9, 10, 11, 11, 11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 4, 4, 4, 4, 4, 0,
  0, 0, 0, 0, 0, 0, 0, 0, 0, 2, 4, 4, 4, 4, 4, 0, 0, 0, 0, 0, 0, 0, 0, 2, 2, 2,
  4, 4, 4, 4, 4, 3, 3, 3, 3, 3, 3, 3, 3, 0, 0, 5, 5, 6, 7, 7, 7, 2, 2, 2, 2, 2,
  2, 2, 2, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 
  5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 2, 
  2, 6, 9, 10, 11, 11, 11, 3, 3, 3, 3, 3, 3, 3, 3, 5, 5, 5, 8, 10, 10, 10, 10, 
  7, 7, 7, 7, 7, 7, 7, 7, 5, 5, 5, 8, 10, 10, 10, 10, 7, 7, 7, 7, 7, 7, 7, 7, 8,
  8, 8, 8, 10, 10, 10, 10, 8, 8, 8, 8, 8, 8, 8, 8, 6, 6, 6, 9, 10, 11, 11, 11, 7,
  7, 7, 7, 7, 7, 7, 7, 9, 9, 9, 9, 10, 11, 11, 11, 9, 9, 9, 9, 9, 9, 9, 9, 9, 9,
  9, 9, 10, 11, 11, 11, 9, 9, 9, 9, 9, 9, 9, 9, 10, 10, 10, 10, 10, 11, 11, 11, 
  10, 10, 10, 10, 10, 10, 10, 10
};

static const uint8 InitKingDanger[128] = {
  2, 0, 2, 5, 5, 2, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0,
  2, 2, 4, 8, 8, 4, 2, 2, 0, 0, 0, 0, 0, 0, 0, 0,
  7, 10, 12, 12, 12, 12, 10, 7, 0, 0, 0, 0, 0, 0, 0, 0,
  15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 0, 0, 0, 0, 0, 0,
  15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 0, 0, 0, 0, 0, 0,
  15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 0, 0, 0, 0, 0, 0,
  15, 15, 15, 15, 15, 15, 15, 15, 0, 0, 0, 0, 0, 0, 0, 0
};

static const int SafetyTable[100] = {
  0, 0, 0, 1, 1, 2, 3, 4, 5, 6, 8, 10, 13, 16, 20, 25, 30, 36, 42, 48, 55,
  62, 70, 80, 90, 100, 110, 120, 130, 140, 150, 160, 170, 180, 190, 200,
  210, 220, 230, 240, 250, 260, 270, 280, 290, 300, 310, 320, 330, 340, 350,
  360, 370, 380, 390, 400, 410, 420, 430, 440, 450, 460, 470, 480, 490, 500,
  510, 520, 530, 540, 550, 560, 570, 580, 590, 600, 610, 620, 630, 640, 650,
  650, 650, 650, 650, 650, 650, 650, 650, 650, 650, 650, 650, 650, 650, 650,
  650, 650, 650, 650
};

void init_safety(void) {
  int i, j, k, l, s, sign;
  int sq_[256];
  int *sq = sq_ + 64;
  int table[11] = {-17, -16, -15, -1, 1, 15, 16, 17, 31, 32, 33};
  const int *ptr;
  uint8 first1[256];

  for(i = 0; i < 256; i++) AttackDeltaMask[0][i] = AttackDeltaMask[1][i] = 0;
  for(i = 0; i < 11; i++) 
    AttackDeltaMask[0][table[i]+128] = AttackDeltaMask[1][-table[i]+128] = 1;
  for(i = 1; i < 256; i++) 
    for(j = 0; j < 8; j++)
      if(i & (1<<j)) {
        first1[i] = j; break;
      }
  memset(AttackDirections, 0, (BK+1)*256*sizeof(uint8));

  for(i = WP; i <= BQ; i++)
    for(j = 0; j < 256; j++) {
      StepInfo[i][j].next_step = Directions[i][first1[j]];
      StepInfo[i][j].next_bf = (j ^ (1 << first1[j]));
    }

  for(i = A1; i <= H8; i = i + 9 & ~8) 
    for(s = WHITE, sign = 1; s <= BLACK; s++, sign *= -1) {
      for(j = 0; j < 256; j++) sq_[j] = 0;
      for(j = 0; j < 11; j++) sq[i-sign*table[j]] = 1;  
      for(j = A1; j <= H8; j = j + 9 & ~8) {
        if(i == j) continue;
        for(k = PawnOfColour(s); k <= QueenOfColour(s); k++) 
          for(ptr = Directions[k]; *ptr; ptr++) 
            for(l = j + *ptr; !(l & 0x88); l += *ptr) {
              AttackDirections[k][j-i+128] |= sq[l]*(1<<(ptr-Directions[k]));
              if(!SLIDER(k)) break;
            }
      }
    }
}

bool attacked_by_non_king(const position_t *pos, int square, int side) {
  int sq, tosq, piece, step;
  attack_data_t *a = AttackData-square;

  piece = PawnOfColour(side);
  if(pos->board[square-Directions[piece][0]] == piece ||
     pos->board[square-Directions[piece][1]] == piece)
    return true;
  piece++;
  if(HasKnights(pos, side))
    for(sq = PieceListStart(pos, piece); sq <= H8; sq = NextPiece(pos, sq))
      if(PieceMask[KNIGHT] & a[sq].may_attack) return true;
  piece++;
  if(HasBishops(pos, side)) 
    for(sq = PieceListStart(pos, piece); sq <= H8; sq = NextPiece(pos, sq))
      if(PieceMask[BISHOP] & a[sq].may_attack) {
        step = a[sq].step;
        for(tosq = sq + step; pos->board[tosq] == EMPTY && tosq != square;
            tosq += step);
        if(tosq == square) return true;
      }
  piece++;
  if(HasRooks(pos, side)) 
    for(sq = PieceListStart(pos, piece); sq <= H8; sq = NextPiece(pos, sq))
      if(PieceMask[ROOK] & a[sq].may_attack) {
        step = a[sq].step;
        for(tosq = sq + step; pos->board[tosq] == EMPTY && tosq != square;
            tosq += step);
        if(tosq == square) return true;
      }
  piece++;
  if(HasQueens(pos, side)) 
    for(sq = PieceListStart(pos, piece); sq <= H8; sq = NextPiece(pos, sq))
      if(PieceMask[QUEEN] & a[sq].may_attack) {
        step = a[sq].step;
        for(tosq = sq + step; pos->board[tosq] == EMPTY && tosq != square;
            tosq += step);
        if(tosq == square) return true;
      }
  return false;
}

int evaluate_king_safety(const position_t *pos, int side, int shield, 
                         int open_files) {
  int ksq;
  int xside = side^1;
  int piece, sq, sq2, dirs, step;
  int number = 0;     // Number of attackers, not including pawns
  int types = 0;      // Types of attackers, including pawns
  int attacked = 0;   // Number of attacked squares adjacent to the king
  int undefended = 0; // Number of undefended attacked squares
  int attacking_material;
  int inc;
  uint8 *adm, *dist;
  step_info_t *si;

  if(!HasQueens(pos, xside)) return 0;

  ksq = KingSquare(pos, side);
  adm = AttackDeltaMask[side]+128-ksq; dist = Distance-ksq;

  piece = QueenOfColour(xside);
  si = StepInfo[piece];
  for(sq = PieceListStart(pos, piece); sq <= H8; sq = NextPiece(pos, sq)) {
    inc = 0;
    dirs = AttackDirections[piece][sq-ksq+128];
    while(dirs) {
      step = si[dirs].next_step; dirs = si[dirs].next_bf;
      for(sq2 = sq + step; pos->board[sq2] != OUTSIDE; sq2 += step) {
        inc |= adm[sq2];
        if(dist[sq2] == 1) {
          attacked++;
          if(!attacked_by_non_king(pos, sq2, side)) undefended++;
        }
        if(pos->board[sq2] != EMPTY) break;
      }
    }
    if(!inc && (open_files & FileMask[file(sq)]) && 
       abs(file(sq)-file(ksq)) <= 1) inc = 1;
    if(inc) {
      number += inc; types |= QUEEN_MASK;
    }
  }

  piece--;
  si = StepInfo[piece];
  for(sq = PieceListStart(pos, piece); sq <= H8; sq = NextPiece(pos, sq)) {
    inc = 0;
    dirs = AttackDirections[piece][sq-ksq+128];
    while(dirs) {
      step = si[dirs].next_step; dirs = si[dirs].next_bf;
      for(sq2 = sq + step; pos->board[sq2] != OUTSIDE; sq2 += step) {
        inc |= adm[sq2];
        if(dist[sq2] == 1) {
          attacked++;
          if(!attacked_by_non_king(pos, sq2, side)) undefended++;
        }
        if(pos->board[sq2] != EMPTY) break;
      }
    }
    if(!inc && (open_files & FileMask[file(sq)]) && 
       abs(file(sq)-file(ksq)) <= 1) inc = 1;
    if(inc) {
      number += inc; types |= ROOK_MASK;
    }
  }

  piece--;
  si = StepInfo[piece];
  for(sq = PieceListStart(pos, piece); sq <= H8; sq = NextPiece(pos, sq)) {
    inc = 0;
    dirs = AttackDirections[piece][sq-ksq+128];
    while(dirs) {
      step = si[dirs].next_step; dirs = si[dirs].next_bf;
      for(sq2 = sq + step; pos->board[sq2] != OUTSIDE; sq2 += step) {
        inc |= adm[sq2];
        if(dist[sq2] == 1) {
          attacked++;
          if(!attacked_by_non_king(pos, sq2, side)) undefended++;
        }
        if(pos->board[sq2] != EMPTY) break;
      }
    }
    if(inc) {
      number += inc; types |= BISHOP_MASK;
    }
  }

  piece--;
  si = StepInfo[piece];
  for(sq = PieceListStart(pos, piece); sq <= H8; sq = NextPiece(pos, sq)) {
    inc = 0;
    dirs = AttackDirections[piece][sq-ksq+128];
    while(dirs) {
      step = si[dirs].next_step; dirs = si[dirs].next_bf;
      sq2 = sq + step;
      if(pos->board[sq2] != OUTSIDE) {
        inc |= adm[sq2];
        if(dist[sq2] == 1) {
          attacked++;
          if(!attacked_by_non_king(pos, sq2, side)) undefended++;
        }
      }
    }
    if(inc) {
      number += inc; types |= KNIGHT_MASK;
    }
  }

  if(side == WHITE && attacked > 0) {
    if(pos->board[ksq+16] == BP) {
      attacked += 2;
      if(!attacked_by_non_king(pos, ksq+1, side)) undefended++;
      if(!attacked_by_non_king(pos, ksq-1, side)) undefended++;
      types |= PAWN_MASK;
    }
    if(pos->board[ksq+32] == BP) {
      attacked += 2;
      if(!attacked_by_non_king(pos, ksq+17, side)) undefended++;
      if(!attacked_by_non_king(pos, ksq+15, side)) undefended++;
      types |= PAWN_MASK;
    }
    if(pos->board[ksq+31] == BP) {
      attacked += 1;
      if(!attacked_by_non_king(pos, ksq+16, side)) undefended++;
      types |= PAWN_MASK;
    }
    if(pos->board[ksq+33] == BP) {
      attacked += 1;
      if(!attacked_by_non_king(pos, ksq+16, side)) undefended++;
      types |= PAWN_MASK;
    }
    if(pos->board[ksq+30] == BP) {
      attacked += 1;
      if(!attacked_by_non_king(pos, ksq+15, side)) undefended++;
      types |= PAWN_MASK;
    }
    if(pos->board[ksq+34] == BP) {
      attacked += 1;
      if(!attacked_by_non_king(pos, ksq+17, side)) undefended++;
      types |= PAWN_MASK;
    }
  }
  else if(attacked > 0) {
    if(pos->board[ksq-16] == WP) {
      attacked += 2;
      if(!attacked_by_non_king(pos, ksq+1, side)) undefended++;
      if(!attacked_by_non_king(pos, ksq-1, side)) undefended++;
      types |= PAWN_MASK;
    }
    if(pos->board[ksq-32] == WP) {
      attacked += 2;
      if(!attacked_by_non_king(pos, ksq-17, side)) undefended++;
      if(!attacked_by_non_king(pos, ksq-15, side)) undefended++;
      types |= PAWN_MASK;
    }
    if(pos->board[ksq-31] == WP) {
      attacked += 1;
      if(!attacked_by_non_king(pos, ksq-16, side)) undefended++;
      types |= PAWN_MASK;
    }
    if(pos->board[ksq-33] == WP) {
      attacked += 1;
      if(!attacked_by_non_king(pos, ksq-16, side)) undefended++;
      types |= PAWN_MASK;
    }
    if(pos->board[ksq-30] == WP) {
      attacked += 1;
      if(!attacked_by_non_king(pos, ksq-15, side)) undefended++;
      types |= PAWN_MASK;
    }
    if(pos->board[ksq-34] == WP) {
      attacked += 1;
      if(!attacked_by_non_king(pos, ksq-17, side)) undefended++;
      types |= PAWN_MASK;
    }
  }

  if(number > 7) number = 7;

  inc = AttackPatternBonus[number+types*8] * 2 + (attacked+undefended) * 3 +
    InitKingDanger[ksq^(side*0x70)] - shield / 2;
  if(inc<0) inc = 0;

  attacking_material = pos->material[xside] - PawnCount(pos, xside)*P_VALUE;
    
  return -(SafetyTable[inc]*attacking_material) / 4096;
}
