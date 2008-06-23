#include "viper.h"

bool irreversible(move_t m) {
  return CAPTURE(m) || PIECE(m)==PAWN;
}

bool ep_is_legal(position_t *pos, move_t m) {
  bool legal;
  undo_info_t u[1];
  make_move(pos, m, u);
  legal = !is_attacked(pos, KingSquare(pos, (pos->side)^1), pos->side);
  unmake_move(pos, m, u);
  return legal;
}

bool move_is_legal(position_t *pos, move_t m) {
  int side = pos->side, xside = side^1;
  int ksq = KingSquare(pos, side);
  int from = FROM(m);
  attack_data_t *a = AttackData-ksq;

  if(pos->check) return true;
  if(PIECE(m) == KING) return !is_attacked(pos, TO(m), xside);
    
  if(a[from].may_attack&Q_MASK) {
    int step = a[from].step, sq;
    if(step == a[TO(m)].step) return true;
    if(EP(m) && abs(step) == 1) return ep_is_legal(pos, m);
    for(sq = from + step; pos->board[sq] == EMPTY; sq += step);
    if(sq == ksq) {
      for(sq = from-step; pos->board[sq]==EMPTY; sq -= step);
      if(ColourOfPiece(pos->board[sq]) == xside && SLIDER(pos->board[sq]) &&
         (a[sq].may_attack & PieceMask[pos->board[sq]]))
        return false;
    }
  }
  return true;
}

//// move_is_check() is a simple function for determining whether a move
//// checks the opponent.  It does not work for promotions, castling or 
//// en passant moves.
bool move_is_check(const position_t *pos, move_t m) {
  int piece;
  int from = FROM(m);
  int to = TO(m);
  int side = pos->side, xside = side^1;
  int ksq = KingSquare(pos, xside);
  int sq, step;
  attack_data_t *a = AttackData-ksq;

  piece = PieceOfColourAndType(side, PIECE(m));
  if(a[to].may_attack & PieceMask[piece]) {
    if(SLIDER(piece)) {
      step = a[to].step;
      for(sq = to + step; pos->board[sq] == EMPTY; sq += step);
      if(sq == ksq) return true;
    }
    else return true;
  }
  if((a[from].may_attack & Q_MASK) && a[from].step != a[to].step) {
    step = a[from].step;
    for(sq = from+step; pos->board[sq] == EMPTY; sq += step);
    if(sq == ksq) {
      for(sq = from - step; pos->board[sq]==EMPTY; sq -= step);
      if(ColourOfPiece(pos->board[sq]) == side && 
	 (a[sq].may_attack&PieceMask[pos->board[sq]]))
        return true;
    }
  }
  return false;
}

void make_move(position_t *pos, move_t m, undo_info_t *u) {
  int from, to, piece, capture, promotion, prom_or_piece, ep;
  int side = pos->side, xside = side^1;

  u->ep_square = pos->ep_square;
  u->castle_flags = pos->castle_flags;
  u->rule50 = pos->rule50;
  u->key = pos->previous_keys[pos->gply] = pos->key;
  u->pkey = pos->pkey;
  u->last_move = pos->last_move;
  u->check = pos->check;
  u->check_sqs[0] = pos->check_sqs[0];
  u->check_sqs[1] = pos->check_sqs[1];

  if(irreversible(m)) pos->rule50 = 0; else pos->rule50++;

  from=FROM(m); to=TO(m); capture=CAPTURE(m); promotion=PROMOTION(m);
  ep = (m&EP_FLAG);
  piece = pos->board[from];

  if(capture) capture |= (xside<<3); 
  if(promotion) promotion |= (side<<3);
  prom_or_piece = promotion? promotion : piece;
  pos->material[side] += PieceValues[prom_or_piece]-PieceValues[piece];
  pos->psq[side] += PSQ(prom_or_piece, to)-PSQ(piece, from);

  pos->key ^= ZOBRIST(piece, from); 
  pos->key ^= ZOBRIST(prom_or_piece, to);
  pos->key ^= ZobColour; pos->key ^= ZOB_EP(pos->ep_square);

  if(TypeOfPiece(piece) == PAWN) {
    pos->pkey ^= ZOBRIST(piece, from);
    if(!promotion) pos->pkey ^= ZOBRIST(piece, to);
  }

  if(capture) {
    int capsq = ep? to-PawnPush[side] : to;
    int count;
    RemovePiece(pos, capsq);
    pos->board[capsq] = EMPTY;
    pos->key ^= ZOBRIST(capture, capsq);
    if(TypeOfPiece(capture) == PAWN) pos->pkey ^= ZOBRIST(capture, capsq);
    count = pos->piece_count[xside][TypeOfPiece(capture)];
    pos->piece_count[xside][TypeOfPiece(capture)]--;
    pos->material[xside] -= PieceValues[capture];
    pos->psq[xside] -= PSQ(capture, capsq);
  }
  if(promotion) {
    RemovePiece(pos, from); InsertPiece(pos, promotion, to);
    pos->piece_count[side][PAWN]--;
    pos->piece_count[side][TypeOfPiece(promotion)]++;
  }
  else MovePiece(pos, from, to);

  pos->board[to] = prom_or_piece; pos->board[from] = EMPTY;

  if(PieceIsPawn(piece) && to-from == 2*PawnPush[side] &&
     (pos->board[to+1] == PawnOfColour(xside) || 
      pos->board[to-1] == PawnOfColour(xside))) {
    pos->ep_square = (to+from)/2;
    pos->key ^= ZOB_EP(pos->ep_square);
  }
  else pos->ep_square = 0;

  if(SHORT_CASTLING(m)) {
    int initialKRSQ = InitialKRSQ+side*A8;
    int rook = RookOfColour(side);
    int g1 = G1 + side*A8, f1 = F1 + side*A8;

    pos->board[initialKRSQ] = EMPTY; pos->board[f1] = rook;
    pos->board[g1] = KingOfColour(side);
    pos->psq[side] -= PSQ(rook, initialKRSQ); pos->psq[side] += PSQ(rook, f1);
    pos->key ^= ZOBRIST(rook, initialKRSQ); pos->key ^= ZOBRIST(rook, f1);
    init_piece_lists(pos); 
  }
  else if(LONG_CASTLING(m)) {
    int initialQRSQ = InitialQRSQ+side*A8;
    int rook = RookOfColour(side);
    int c1 = C1 + side*A8, d1 = D1 + side*A8;

    pos->board[initialQRSQ] = EMPTY; pos->board[d1] = rook; 
    pos->board[c1] = KingOfColour(side);
    pos->psq[side] -= PSQ(rook, initialQRSQ); pos->psq[side] += PSQ(rook, c1);
    pos->key ^= ZOBRIST(rook, initialQRSQ); pos->key ^= ZOBRIST(rook, c1);
    init_piece_lists(pos); 
  }
  pos->key^=ZOB_CASTLE(pos->castle_flags);
  if(from==InitialKSQ || from==InitialKRSQ || to==InitialKRSQ)
    ProhibitOO(pos, WHITE);
  if(from==InitialKSQ || from==InitialQRSQ || to==InitialQRSQ)
    ProhibitOOO(pos, WHITE);
  if(from==InitialKSQ+A8 || from==InitialKRSQ+A8 || to==InitialKRSQ+A8)
    ProhibitOO(pos, BLACK);
  if(from==InitialKSQ+A8 || from==InitialQRSQ+A8 || to==InitialQRSQ+A8)
    ProhibitOOO(pos, BLACK);
  pos->key^=ZOB_CASTLE(pos->castle_flags);

  pos->last_move = m;
  pos->gply++; pos->side ^= 1; pos->xside ^= 1;
  pos->check = find_checkers(pos, pos->check_sqs);
}

void unmake_move(position_t *pos, move_t m, undo_info_t *u) {
  int from, to, piece, capture, promotion, prom_or_piece, ep;
  int side, xside;

  pos->gply--; pos->xside ^= 1; pos->side ^= 1;
  side = pos->side; xside = side^1;
  pos->ep_square = u->ep_square;
  pos->castle_flags = u->castle_flags;
  pos->rule50 = u->rule50;
  pos->key = u->key; pos->pkey = u->pkey;
  pos->last_move = u->last_move;
  pos->check = u->check;
  pos->check_sqs[0] = u->check_sqs[0];
  pos->check_sqs[1] = u->check_sqs[1];

  from = FROM(m); to = TO(m); capture = CAPTURE(m); promotion = PROMOTION(m);
  piece = PIECE(m); ep = (m&EP_FLAG);

  piece |= (side<<3);
  if(capture) capture |= (xside<<3); 
  if(promotion) promotion |= (side<<3);
  prom_or_piece = promotion? promotion : piece;

  if(promotion) {
    RemovePiece(pos, to); InsertPiece(pos, piece, from);
    pos->piece_count[side][PAWN]++;
    pos->piece_count[side][TypeOfPiece(promotion)]--;
    pos->material[side] -= PieceValues[promotion];
    pos->material[side] += P_VALUE;
    pos->psq[side] -= PSQ(promotion, to);
    pos->psq[side] += PSQ(piece, from);
  }
  else {
    MovePiece(pos, to, from);
    pos->psq[side] -= PSQ(piece, to); pos->psq[side] += PSQ(piece, from);
  }
  pos->board[from] = piece; pos->board[to] = EMPTY;

  if(capture) {
    int capsq = ep? to-PawnPush[side] : to;
    pos->board[capsq] = capture;
    InsertPiece(pos, capture, capsq);
    pos->piece_count[xside][TypeOfPiece(capture)]++;
    pos->material[xside] += PieceValues[capture];
    pos->psq[xside] += PSQ(capture, capsq);
  }

  if(SHORT_CASTLING(m)) {
    int initialKRSQ = InitialKRSQ+side*A8, initialKSQ = InitialKSQ+side*A8;
    int rook = RookOfColour(side), king = KingOfColour(side);
    int g1 = G1 + side*A8, f1 = F1 + side*A8;

    pos->board[f1] = pos->board[g1] = EMPTY;
    pos->board[initialKRSQ] = rook; pos->board[initialKSQ] = king;
    init_piece_lists(pos);
    pos->psq[side] = compute_psq(pos, side);
  }
  if(LONG_CASTLING(m)) {
    int initialQRSQ = InitialQRSQ+side*A8, initialKSQ = InitialKSQ+side*A8;
    int rook = RookOfColour(side), king = KingOfColour(side);
    int c1 = C1 + side*A8, d1 = D1 + side*A8;

    pos->board[d1] = pos->board[c1] = EMPTY;
    pos->board[initialQRSQ] = rook; pos->board[initialKSQ] = king;
    init_piece_lists(pos);
    pos->psq[side] = compute_psq(pos, side);
  }
}

void make_nullmove(position_t *pos, undo_info_t *u) {
  u->ep_square = pos->ep_square;
  u->castle_flags = pos->castle_flags;
  u->rule50 = pos->rule50;
  u->key = pos->previous_keys[pos->gply] = pos->key;
  u->last_move = pos->last_move;
  pos->key^=ZobColour; pos->key^=ZOB_EP(pos->ep_square);
  pos->rule50++; 
  pos->ep_square = 0;
  pos->last_move = NULLMOVE;
  pos->gply++; pos->side ^= 1; pos->xside ^= 1;
}

void unmake_nullmove(position_t *pos, undo_info_t *u) {
  pos->gply--; pos->xside ^= 1; pos->side ^= 1;
  pos->ep_square = u->ep_square;
  pos->castle_flags = u->castle_flags;
  pos->rule50 = u->rule50;
  pos->key = u->key;
  pos->last_move = u->last_move;
}
    
