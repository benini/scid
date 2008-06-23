#include "glaurung.h"

move_stack_t *generate_moves(const position_t *pos, move_stack_t *ms) {
  int from, to, piece, type, tmp, step, rank, prom;
  int side = pos->side, xside = side^1;
  const int *ptr;

  for(from = KingSquare(pos, side); from != PieceListEnd; 
      from = NextPiece(pos, from)) {
    if(from > H8) continue;
    piece = pos->board[from]; type = TypeOfPiece(piece);
    tmp = (from<<7)|(type<<17);
    if(type == PAWN) {
      step = PawnPush[side];
      rank = PawnRank[side][from];
      if(rank < RANK_7) {
        if(pos->board[from+step] == EMPTY) {
          (ms++)->move = tmp|(from+step);
          if(rank == RANK_2 && pos->board[from+2*step] == EMPTY)
            (ms++)->move = tmp|(from+2*step);
        }
        for(ptr = Directions[piece]; *ptr; ptr++) {
          to = from + (*ptr);
          if(ColourOfPiece(pos->board[to]) == xside)
            (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
        }
      } 
      else {
        if(pos->board[from+step] == EMPTY) 
          for(prom = QUEEN; prom >= KNIGHT; prom--)
            (ms++)->move = tmp|(from+step)|(prom<<14);
        for(ptr = Directions[piece]; *ptr; ptr++) {
          to = from + (*ptr);
          if(ColourOfPiece(pos->board[to]) == xside) {
            if(PawnRank[side][to] == RANK_8) {
              for(prom = QUEEN; prom >= KNIGHT; prom--)
                (ms++)->move = 
                  tmp|to|(TypeOfPiece(pos->board[to])<<20)|(prom<<14);
            }
            else (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
          }
        }
      }
    }
    else {
      for(ptr = Directions[piece]; *ptr; ptr++) {
        if(SLIDER(piece)) {
          to = from;
          do {
            to += (*ptr);
            if(pos->board[to]==EMPTY || ColourOfPiece(pos->board[to])==xside)
              (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
          } while(pos->board[to]==EMPTY);
        }
        else {
          to = from + (*ptr);
          if(pos->board[to]==EMPTY || ColourOfPiece(pos->board[to])==xside) 
            (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
        }
      }
    }
  }

  // Finally, we have the ugly special cases of en passant captures and
  // castling moves:
  if(pos->ep_square) 
    for(ptr = Directions[PawnOfColour(xside)]; *ptr; ptr++) {
      from = pos->ep_square + (*ptr);
      if(pos->board[from] == PawnOfColour(side))
        (ms++)->move = 
          (pos->ep_square)|(from<<7)|(PAWN<<17)|(PAWN<<20)|EP_FLAG;
    }

  if(!pos->check) {
    if(CanCastleKingside(pos, side)) {
      int initialKSQ = InitialKSQ+side*A8, initialKRSQ = InitialKRSQ+side*A8;
      int g1 = G1 + side*A8, f1 = F1 + side*A8;
      int illegal = 0, sq;
      for(sq = Min(initialKSQ, g1); sq <= Max(initialKSQ, g1); sq++) 
        if((sq != initialKSQ && sq != initialKRSQ && pos->board[sq] != EMPTY)
           || is_attacked(pos, sq, xside)) 
          illegal = 1; 
      for(sq = Min(initialKRSQ, f1); sq <= Max(initialKRSQ, f1); sq++)
        if(sq != initialKSQ && sq != initialKRSQ && pos->board[sq] != EMPTY)
          illegal = 1;
      if(!illegal) (ms++)-> move = (KING<<17)|(initialKSQ<<7)|g1|CASTLE_FLAG;
    }
    if(CanCastleQueenside(pos, side)) {
      int initialKSQ = InitialKSQ+side*A8, initialQRSQ = InitialQRSQ+side*A8;
      int c1 = C1 + side*A8, d1 = D1 + side*A8;
      int illegal = 0, sq;
      for(sq = Min(initialKSQ, c1); sq <= Max(initialKSQ, c1); sq++) 
        if((sq != initialKSQ && sq != initialQRSQ && pos->board[sq] != EMPTY) 
           || is_attacked(pos, sq, xside)) 
          illegal = 1; 
      for(sq = Min(initialQRSQ, d1); sq <= Max(initialQRSQ, d1); sq++)
        if(sq != initialKSQ && sq != initialQRSQ && pos->board[sq] != EMPTY)
          illegal = 1;
      if(InitialQRSQ == B1 && (pos->board[A1+side*A8] == RookOfColour(xside) ||
                               pos->board[A1+side*A8] == QueenOfColour(xside)))
        illegal = 1;
      if(!illegal) (ms++)-> move = (KING<<17)|(initialKSQ<<7)|c1|CASTLE_FLAG;
    }
  }
  return ms;
}

move_stack_t *generate_captures(const position_t *pos, move_stack_t *ms) {
  int from, to, piece, tmp, step, rank;
  int side = pos->side, xside = side^1;
  const int *ptr;

  piece = PawnOfColour(side);
  step = PawnPush[side];
  for(from=PieceListStart(pos, piece); from<=H8; from=NextPiece(pos, from)) {
    tmp = (from<<7)|(PAWN<<17);
    rank = PawnRank[side][from];
    if(rank < RANK_7) 
      for(to = from + step - 1; to <= from + step + 1; to += 2) {
        if(ColourOfPiece(pos->board[to]) == xside)
          (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
      }
    else {
      if(pos->board[from+step] == EMPTY)
        (ms++)->move = tmp|(from+step)|(QUEEN<<14);
      for(to = from + step - 1; to <= from + step + 1; to += 2) {
        if(ColourOfPiece(pos->board[to]) == xside)
          (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20)|(QUEEN<<14);
      }
    }
  }
  piece++;
  for(from=PieceListStart(pos, piece); from<=H8; from=NextPiece(pos, from)) {
    tmp = (from<<7)|(KNIGHT<<17);
    to = from + 33;
    if(ColourOfPiece(pos->board[to]) == xside)
      (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
    to = from + 31;
    if(ColourOfPiece(pos->board[to]) == xside)
      (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
    to = from + 18;
    if(ColourOfPiece(pos->board[to]) == xside)
      (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
    to = from + 14;
    if(ColourOfPiece(pos->board[to]) == xside)
      (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
    to = from - 14;
    if(ColourOfPiece(pos->board[to]) == xside)
      (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
    to = from - 18;
    if(ColourOfPiece(pos->board[to]) == xside)
      (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
    to = from - 31;
    if(ColourOfPiece(pos->board[to]) == xside)
      (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
    to = from - 33;
    if(ColourOfPiece(pos->board[to]) == xside)
      (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
  }
  piece++;
  for(from=PieceListStart(pos, piece); from<=H8; from=NextPiece(pos, from)) {
    tmp = (from<<7)|(BISHOP<<17);
    for(to = from + 17; pos->board[to] == EMPTY; to += 17);
    if(ColourOfPiece(pos->board[to]) == xside)
      (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
    for(to = from + 15; pos->board[to] == EMPTY; to += 15);
    if(ColourOfPiece(pos->board[to]) == xside)
      (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
    for(to = from - 15; pos->board[to] == EMPTY; to -= 15);
    if(ColourOfPiece(pos->board[to]) == xside)
      (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
    for(to = from - 17; pos->board[to] == EMPTY; to -= 17);
    if(ColourOfPiece(pos->board[to]) == xside)
      (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
  }
  piece++;
  for(from=PieceListStart(pos, piece); from<=H8; from=NextPiece(pos, from)) {
    tmp = (from<<7)|(ROOK<<17);
    for(to = from + 16; pos->board[to] == EMPTY; to += 16);
    if(ColourOfPiece(pos->board[to]) == xside)
      (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
    for(to = from + 1; pos->board[to] == EMPTY; to += 1);
    if(ColourOfPiece(pos->board[to]) == xside)
      (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
    for(to = from - 1; pos->board[to] == EMPTY; to -= 1);
    if(ColourOfPiece(pos->board[to]) == xside)
      (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
    for(to = from - 16; pos->board[to] == EMPTY; to -= 16);
    if(ColourOfPiece(pos->board[to]) == xside)
      (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
  }
  piece++;
  for(from=PieceListStart(pos, piece); from<=H8; from=NextPiece(pos, from)) {
    tmp = (from<<7)|(QUEEN<<17);
    for(to = from + 17; pos->board[to] == EMPTY; to += 17);
    if(ColourOfPiece(pos->board[to]) == xside)
      (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
    for(to = from + 15; pos->board[to] == EMPTY; to += 15);
    if(ColourOfPiece(pos->board[to]) == xside)
      (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
    for(to = from - 15; pos->board[to] == EMPTY; to -= 15);
    if(ColourOfPiece(pos->board[to]) == xside)
      (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
    for(to = from - 17; pos->board[to] == EMPTY; to -= 17);
    if(ColourOfPiece(pos->board[to]) == xside)
      (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
    for(to = from + 16; pos->board[to] == EMPTY; to += 16);
    if(ColourOfPiece(pos->board[to]) == xside)
      (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
    for(to = from + 1; pos->board[to] == EMPTY; to += 1);
    if(ColourOfPiece(pos->board[to]) == xside)
      (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
    for(to = from - 1; pos->board[to] == EMPTY; to -= 1);
    if(ColourOfPiece(pos->board[to]) == xside)
      (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
    for(to = from - 16; pos->board[to] == EMPTY; to -= 16);
    if(ColourOfPiece(pos->board[to]) == xside)
      (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
  }
  piece++;
  from = PieceListStart(pos, piece);
  tmp = (from<<7)|(KING<<17);
  to = from + 17;
  if(ColourOfPiece(pos->board[to]) == xside)
    (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
  to = from + 16;
  if(ColourOfPiece(pos->board[to]) == xside)
    (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
  to = from + 15;
  if(ColourOfPiece(pos->board[to]) == xside)
    (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
  to = from + 1;
  if(ColourOfPiece(pos->board[to]) == xside)
    (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
  to = from - 1;
  if(ColourOfPiece(pos->board[to]) == xside)
    (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
  to = from - 15;
  if(ColourOfPiece(pos->board[to]) == xside)
    (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
  to = from - 16;
  if(ColourOfPiece(pos->board[to]) == xside)
    (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
  to = from - 17;
  if(ColourOfPiece(pos->board[to]) == xside)
    (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);

  // Finally, we have the ugly special case of en passant captures:
  if(pos->ep_square) 
    for(ptr = Directions[PawnOfColour(xside)]; *ptr; ptr++) {
      from = pos->ep_square + (*ptr);
      if(pos->board[from] == PawnOfColour(side))
        (ms++)->move = 
          (pos->ep_square)|(from<<7)|(PAWN<<17)|(PAWN<<20)|EP_FLAG;
    }
  return ms;
}
      
move_stack_t *generate_check_evasions(position_t *pos, move_stack_t *ms) {
  int ksq, from, to, piece, type, tmp, step, rank, prom, pin, checks;
  int side = pos->side, xside = side^1;
  const int *ptr;

  checks = pos->check;
  ksq = KingSquare(pos, side);
  
  // King moves:
  tmp = (ksq<<7)|(KING<<17);
  pos->board[ksq] = EMPTY;
  for(ptr = Directions[KING]; *ptr; ptr++) {
    to = ksq + (*ptr);
    if((pos->board[to]==EMPTY || ColourOfPiece(pos->board[to]) == xside) && 
       (!is_attacked(pos, to, xside)))
      (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
  }
  pos->board[ksq] = KingOfColour(side);

  // Moves by other pieces are only possible if it is not a double check:
  if(checks == 1) {
    attack_data_t *a = AttackData-ksq;
    int chsq = pos->check_sqs[0];
    
    if(SLIDER(pos->board[chsq])) {
      int blockstep = a[chsq].step;
      for(from = NextPiece(pos, ksq); from != PieceListEnd; 
          from = NextPiece(pos, from)) {
        if(from > H8) continue;
        pin = is_pinned(pos, from);
        piece = pos->board[from]; type = TypeOfPiece(piece);
        tmp = (from<<7)|(type<<17);
        if(type == PAWN) {
          step = PawnPush[side];
          rank = PawnRank[side][from];
          if(rank < RANK_7) {
            if(!pin || abs(pin)==abs(step)) {
              to = from+step;
              if(pos->board[to]==EMPTY) {
                if(a[to].step==blockstep && (to-ksq)*(to-chsq) < 0)
                  (ms++)->move = tmp|to;
                to += step;
                if(rank==RANK_2 && pos->board[to]==EMPTY && 
                   a[to].step==blockstep
                   && (to-ksq)*(to-chsq) < 0)
                  (ms++)->move = tmp|to;
              }
            }
            for(ptr = Directions[piece]; *ptr; ptr++) {
              if(!pin || abs(pin)==abs(*ptr)) {
                to = from + (*ptr);
                if(ColourOfPiece(pos->board[to]) == xside 
                   && (to==chsq || (a[to].step==blockstep && 
                                    (to-ksq)*(to-chsq) < 0)))
                  (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
              }
            }
          }
          else {
            to = from+step;
            if(!pin || abs(pin)==abs(step)) 
              if(pos->board[to]==EMPTY) 
                if(a[to].step==blockstep && (to-ksq)*(to-chsq) < 0)
                  for(prom = QUEEN; prom >= KNIGHT; prom--) 
                    (ms++)->move=tmp|to|(prom<<14);
            for(ptr = Directions[piece]; *ptr; ptr++) {
              if(!pin || abs(pin)==abs(*ptr)) {
                to = from + (*ptr);
                if(ColourOfPiece(pos->board[to]) == xside 
                   && (to==chsq || (a[to].step==blockstep && 
                                    (to-ksq)*(to-chsq) < 0))) {
                  if(PawnRank[side][to]==RANK_8) {
                    for(prom = QUEEN; prom >= KNIGHT; prom--) 
                      (ms++)->move=tmp|to|(TypeOfPiece(pos->board[to])<<20)|(prom<<14);
                  }
                  else
                    (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
                }
              }
            }
          }
        } 
        else { // Not a pawn
          for(ptr = Directions[piece]; *ptr; ptr++) {
            if(pin && abs(pin) != abs(*ptr)) continue;
            if(SLIDER(piece)) {
              to = from;
              do {
                to += (*ptr);
                if((pos->board[to]==EMPTY || 
                    ColourOfPiece(pos->board[to]) == xside)
                   && (to==chsq ||
                       (a[to].step==blockstep && (to-ksq)*(to-chsq) < 0)))
                  (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
              } while(pos->board[to] == EMPTY);
            }
            else {
              to = from + (*ptr);
              if((pos->board[to]==EMPTY||ColourOfPiece(pos->board[to])==xside)
                 && (to==chsq ||
                     (a[to].step==blockstep && (to-ksq)*(to-chsq) < 0)))
                (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
            }
          }
        }
      }
    }
    else { // Checking piece is not a slider.  Blocking moves impossible.
      for(from = NextPiece(pos, ksq); from != PieceListEnd; 
          from = NextPiece(pos, from)) {
        if(from > H8) continue;
        pin = is_pinned(pos, from);
        piece = pos->board[from]; type = TypeOfPiece(piece);
        tmp = (from<<7)|(type<<17);
        if(type == PAWN) {
          for(ptr = Directions[piece]; *ptr; ptr++) {
            if(!pin || abs(pin)==abs(*ptr)) {
              to = from + (*ptr);
              if(to==chsq) {
                if(PawnRank[side][to]==RANK_8) {
                  for(prom = QUEEN; prom >= KNIGHT; prom--) 
                    (ms++)->move=tmp|to|(TypeOfPiece(pos->board[to])<<20)|(prom<<14);
                }
                else (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
              }
            }
          }
        }
        else {
          for(ptr = Directions[piece]; *ptr; ptr++) {
            if(pin && abs(pin) != abs(*ptr)) continue;
            if(SLIDER(piece)) {
              to = from;
              do {
                to += (*ptr);
                if(to==chsq)
                  (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
              } while(pos->board[to]==EMPTY);
            }
            else {
              to = from + (*ptr);
              if(to==chsq)
                (ms++)->move = tmp|to|(TypeOfPiece(pos->board[to])<<20);
            }
          }
        }
      }
    }

    // Finally, we have the ugly special case of en passant captures:
    if(pos->ep_square) 
      for(ptr = Directions[PawnOfColour(xside)]; *ptr; ptr++) {
        from = pos->ep_square + (*ptr);
        if(pos->board[from] == PawnOfColour(side)) {
          int legal;
          undo_info_t u[1];
          ms->move = (pos->ep_square)|(from<<7)|(PAWN<<17)|(PAWN<<20)|EP_FLAG;
          make_move(pos, ms->move, u);
          legal = !is_attacked(pos, KingSquare(pos, (pos->side)^1), pos->side);
          unmake_move(pos, ms->move, u);
          if(legal) ms++;
        }
      }
  }
  return ms;
}

//// generate_checks() generates all pseudo-legal non-capturing, 
//// non-promoting checks.
move_stack_t *generate_checks(const position_t *pos, move_stack_t *ms) {
  int from, to, to2, piece, type, tmp, step, step2, rank, ksq, mask, dc;
  int side = pos->side, xside = side^1;
  attack_data_t *a;
  const int *ptr;
  
  ksq = KingSquare(pos, xside);
  a = AttackData - ksq;
  for(from = KingSquare(pos, side); from != PieceListEnd; 
      from = NextPiece(pos, from)) {
    if(from > H8) continue;
    piece = pos->board[from]; type = TypeOfPiece(piece);
    mask = PieceMask[piece];
    tmp = (from<<7)|(type<<17);
    dc = is_disc_check_candidate(pos, from);
    if(type == PAWN) {
      rank = PawnRank[side][from];
      if(rank < RANK_7) {
        step = PawnPush[side];
        dc = (dc && abs(dc)!=abs(step));
        to = from + step;
        if(pos->board[to] == EMPTY) {
          if((a[to].may_attack&mask)|dc) (ms++)->move = tmp|to;
          to += step;
          if(rank==RANK_2 && pos->board[to]==EMPTY && 
             ((a[to].may_attack&mask)||dc))
            (ms++)->move = tmp|to;
        }
      }
    }
    else {
      for(ptr = Directions[piece]; *ptr; ptr++) {
        int dc2 = (dc && abs(dc)!=abs(*ptr));
        if(SLIDER(piece)) {
          to = from;
          do {
            to += (*ptr);
            if(pos->board[to] == EMPTY) {
              if(dc2) (ms++)->move = tmp|to;
              else if(a[to].may_attack&mask) {
                step2 = a[to].step;
                for(to2=to+step2; pos->board[to2]==EMPTY; to2+=step2);
                if(to2==ksq) (ms++)->move = tmp|to;
              }
            }
          } while(pos->board[to]==EMPTY);
        }
        else {
          to = from + (*ptr);
          if(pos->board[to]==EMPTY && ((a[to].may_attack&mask)||dc2))
            (ms++)->move = tmp|to;
        }
      }
    }
  }
  return ms;
}
