#include "glaurung.h"

void init_position(position_t *pos) {
  int i;
  for(i = 0; i < 256; i++) pos->board_[i] = ((i-64)&0x88)? OUTSIDE : EMPTY;
  pos->board = pos->board_ + 64;
}

void init_piece_lists(position_t *pos) {
  int sq, piece;

  for(piece = KING; piece >= KNIGHT; piece--) {
    PieceListStart(pos, piece) = piece-1+128;
    PieceListStart(pos, piece+8) = piece+7+128;
    PrevPiece(pos, piece-1+128) = piece+128; 
    PrevPiece(pos, piece+7+128) = piece+8+128;
  }
  PieceListStart(pos, WP) = PieceListStart(pos, BP) = PieceListEnd;

  for(sq = A1; sq <= H8; sq++) 
    if(pos->board[sq] != OUTSIDE && pos->board[sq] != EMPTY) 
      InsertPiece(pos, pos->board[sq], sq);
}

void init_pawn_bitfiles(position_t *pos) {
  int sq;
  memset(pos->_pawn_files, 0, 2*16*sizeof(bitfile_t));
  pos->pawn_files[WHITE] = pos->_pawn_files[WHITE] + 4;
  pos->pawn_files[BLACK] = pos->_pawn_files[BLACK] + 4;
  for(sq = A1; sq <= H8; sq++)
    if(TypeOfPiece(pos->board[sq]) == PAWN)
      pos->pawn_files[ColourOfPiece(pos->board[sq])][file(sq)] |= SetMaskBF(sq);
}

void copy_position(position_t *dst, const position_t *src) {
  memcpy(dst, src, sizeof(position_t));
  dst->board = dst->board_ + 64;
  dst->pawn_files[WHITE] = dst->_pawn_files[WHITE] + 4;
  dst->pawn_files[BLACK] = dst->_pawn_files[BLACK] + 4;
}

bool is_attacked(const position_t *pos, int square, int side) {
  int sq, tosq, piece, step;
  attack_data_t *a = AttackData-square;

  for(sq = KingSquare(pos, side); sq != PieceListEnd; sq = NextPiece(pos, sq))
    if(sq <= H8) {
      piece = pos->board[sq];
      if(PieceMask[piece] & a[sq].may_attack) {
        if(!SLIDER(piece)) return true;
        step = a[sq].step;
        for(tosq=sq+step; pos->board[tosq]==EMPTY&&tosq!=square; tosq+=step);
        if(tosq == square) return true;
      }
    }
  return false;
}

bool position_is_check(const position_t *pos) {
  int us, them;
  move_t move;

  us = pos->side; them = us^1;
  move = pos->last_move;

  if(move == NULLMOVE) return false;
  else if(move == NOMOVE || CASTLING(move) || EP(move))
    return is_attacked(pos, KingSquare(pos, us), them);
  else {
    int ksq = KingSquare(pos, us);
    int from = FROM(move), to = PIECE(move);
    int piece = pos->board[to];
    attack_data_t *a = AttackData - ksq;
    if(a[to].may_attack & PieceMask[piece]) {
      if(!PieceIsSlider(piece)) return true;
      int step = a[to].step, sq;
      for(sq = to + step; pos->board[sq] == EMPTY; sq += step);
      if(sq == ksq) return true;
    }
    if(a[from].may_attack & Q_MASK) {
      int step = a[from].step, sq;
      for(sq = from + step; pos->board[sq] == EMPTY; sq += step);
      if(sq == ksq) {
        for(sq = from - step; pos->board[sq] == EMPTY; sq -= step);
        if(ColourOfPiece(pos->board[sq]) == them &&
           (a[sq].may_attack & PieceMask[pos->board[sq]]))
          return true;
      }
    }
  }
  return false;
}

int find_checkers(const position_t *pos, int chsqs[]) {
  int us = pos->side, them = us^1;
  int ksq = KingSquare(pos, us), from, to, step, piece, result = 0;
  move_t move = pos->last_move;
  attack_data_t *a = AttackData - ksq;

  if(move == NULLMOVE) return 0;
  chsqs[0] = chsqs[1] = 0;
  if(move == NOMOVE || CASTLING(move) || EP(move) || PROMOTION(move)) {
    for(from = KingSquare(pos, pos->side^1); from != PieceListEnd && result<2; 
        from = NextPiece(pos, from)) {
      if(from > H8) continue;
      piece = pos->board[from];
      if(PieceMask[piece] & a[from].may_attack) {
        if(SLIDER(piece)) {
          step = a[from].step;
          for(to = from + step; pos->board[to] == EMPTY; to += step);
          if(to == ksq) chsqs[result++] = from;
        }
        else chsqs[result++] = from;
      }
    }
  }
  else {
    from = FROM(move); to = TO(move);
    piece = pos->board[to];
    if(PieceMask[piece] & a[to].may_attack) {
      if(SLIDER(piece)) {
        int sq;
        step = a[to].step;
        for(sq = to + step; pos->board[sq]==EMPTY; sq += step);
        if(sq == ksq) chsqs[result++] = to;
      }
      else chsqs[result++] = to;
    }
    if(a[from].may_attack & Q_MASK) { // Discovered check possible.
      int sq;
      step = a[from].step;
      for(sq = from + step; pos->board[sq] == EMPTY; sq += step);
      if(sq == ksq) {
        for(sq = from - step; pos->board[sq] == EMPTY; sq -= step);
        if(ColourOfPiece(pos->board[sq]) == them && 
           (a[sq].may_attack & PieceMask[pos->board[sq]]))
          chsqs[result++] = sq;
      }
    }
  }
  return result;
}

int is_pinned(const position_t *pos, int square) {
  int side, ksq, p1, p2, step, sq;
  attack_data_t *a;

  side = ColourOfPiece(pos->board[square]);
  ksq = KingSquare(pos, side);

  a = AttackData - ksq + square;
  if(!(a->may_attack & Q_MASK)) return 0;

  if(a->may_attack & R_MASK) p1 = RookOfColour(side^1);
  else p1 = BishopOfColour(side^1);
  p2 = QueenOfColour(side^1);

  step = a->step;
  for(sq = square + step; pos->board[sq] == EMPTY; sq += step);
  if(sq == ksq) {
    for(sq = square - step; pos->board[sq] == EMPTY; sq -= step);
    if(pos->board[sq] == p1 || pos->board[sq] == p2) return step;
  }
  return 0;
}
  
int is_disc_check_candidate(const position_t *pos, int square) {
  int side, ksq, p1, p2, step, sq;
  attack_data_t *a;

  side = ColourOfPiece(pos->board[square]);
  ksq = KingSquare(pos, side^1);

  a = AttackData - ksq + square;
  if(!(a->may_attack & Q_MASK)) return 0;

  if(a->may_attack & R_MASK) p1 = RookOfColour(side);
  else p1 = BishopOfColour(side);
  p2 = QueenOfColour(side);

  step = a->step;
  for(sq = square + step; pos->board[sq] == EMPTY; sq += step);
  if(sq == ksq) {
    for(sq = square - step; pos->board[sq] == EMPTY; sq -= step);
    if(pos->board[sq] == p1 || pos->board[sq] == p2) return step;
  }
  return 0;
}

int count_pieces(const position_t *pos, int colour, int type) {
  int piece, square, count = 0;
  piece = PieceOfColourAndType(colour, type);
  for(square = PieceListStart(pos, piece), count = 0; square <= H8; 
      square = NextPiece(pos, square), count++);
  return count;
}

void init_piece_counts(position_t *pos) {
  int colour, type;
  for(colour = WHITE; colour <= BLACK; colour++)
    for(type = PAWN; type <= QUEEN; type++)
      pos->piece_count[colour][type] = count_pieces(pos, colour, type);
}
