int LegalMove(TREE * tree, int move, int wtm)
{
  int ksq = KingSquare(pos, side);
  int from = FROM(m);
  attack_data_t *a = AttackData - ksq;

  if (pos->check)
    return true;
  if (PIECE(m) == KING)
    return !is_attacked(pos, TO(m), xside);

  if (a[from].may_attack & Q_MASK) {
    int step = a[from].step, sq;

    if (step == a[TO(m)].step)
      return true;
    if (EP(m) && abs(step) == 1)
      return ep_is_legal(pos, m);
    for (sq = from + step; pos->board[sq] == EMPTY; sq += step);
    if (sq == ksq) {
      for (sq = from - step; pos->board[sq] == EMPTY; sq -= step);
      if (ColourOfPiece(pos->board[sq]) == xside && SLIDER(pos->board[sq]) &&
          (a[sq].may_attack & PieceMask[pos->board[sq]]))
        return false;
    }
  }
  return true;
}
