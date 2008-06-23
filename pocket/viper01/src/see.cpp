#include "viper.h"

int see(const position_t *pos, int from, int to) {
  int piece, capture, side, piece_val, val, step, sq, sq2, c;
  int attackers[2][16], num_of_attackers[2], swaplist[32], n, i;
  attack_data_t *a = AttackData - to;

  // Find attackers for both sides.  The capturing piece is not added 
  // to the attack list.  Instead, we scan for X-ray attacks behind the
  // capturing piece.

  num_of_attackers[WHITE] = num_of_attackers[BLACK] = 0;
  // X-ray attacks through the moving piece:
  if(a[from].may_attack & Q_MASK) {
    step = a[from].step;
    for(sq = from - step; pos->board[sq] == EMPTY; sq -= step);
    if(PieceMask[pos->board[sq]] & a[sq].may_attack) {
      c = ColourOfPiece(pos->board[sq]);
      attackers[c][num_of_attackers[c]++] = sq;
    }
  }

  // Pawns:
  if(pos->board[to - 17] == WP && to - 17 != from)
    attackers[WHITE][num_of_attackers[WHITE]++] = to - 17;
  if(pos->board[to - 15] == WP && to - 15 != from)
    attackers[WHITE][num_of_attackers[WHITE]++] = to - 15;
  if(pos->board[to + 17] == BP && to + 17 != from)
    attackers[BLACK][num_of_attackers[BLACK]++] = to + 17;
  if(pos->board[to + 15] == BP && to + 15 != from)
    attackers[BLACK][num_of_attackers[BLACK]++] = to + 15;

  // Knights: 
  for(sq = PieceListStart(pos, WN); sq <= H8; sq = NextPiece(pos, sq))
    if(sq != from && (a[sq].may_attack & N_MASK))
      attackers[WHITE][num_of_attackers[WHITE]++] = sq;
  for(sq = PieceListStart(pos, BN); sq <= H8; sq = NextPiece(pos, sq))
    if(sq!=from && (a[sq].may_attack & N_MASK))
      attackers[BLACK][num_of_attackers[BLACK]++] = sq;

  // Bishops:
  for(sq = PieceListStart(pos, WB); sq <= H8; sq = NextPiece(pos, sq))
    if(sq!=from && (a[sq].may_attack & B_MASK)) {
      step = a[sq].step;
      for(sq2 = sq + step; pos->board[sq2] == EMPTY && sq2 != to; sq2 += step);
      if(sq2 == to) attackers[WHITE][num_of_attackers[WHITE]++] = sq;
    }
  for(sq = PieceListStart(pos, BB); sq <= H8; sq = NextPiece(pos, sq))
    if(sq!=from && (a[sq].may_attack & B_MASK)) {
      step = a[sq].step;
      for(sq2 = sq + step; pos->board[sq2] == EMPTY && sq2 != to; sq2 += step);
      if(sq2 == to) attackers[BLACK][num_of_attackers[BLACK]++] = sq;
    }

  // Rooks: 
  for(sq = PieceListStart(pos, WR); sq <= H8; sq = NextPiece(pos, sq))
    if(sq!=from && (a[sq].may_attack & R_MASK)) {
      step = a[sq].step;
      for(sq2 = sq + step; pos->board[sq2] == EMPTY && sq2 != to; sq2 += step);
      if(sq2 == to) attackers[WHITE][num_of_attackers[WHITE]++] = sq;
    }
  for(sq = PieceListStart(pos, BR); sq <= H8; sq = NextPiece(pos, sq))
    if(sq!=from && (a[sq].may_attack & R_MASK)) {
      step = a[sq].step;
      for(sq2 = sq + step; pos->board[sq2] == EMPTY && sq2 != to; sq2 += step);
      if(sq2 == to) attackers[BLACK][num_of_attackers[BLACK]++] = sq;
    }

  // Queens: 
  for(sq = PieceListStart(pos, WQ); sq <= H8; sq = NextPiece(pos, sq))
    if(sq!=from && (a[sq].may_attack & Q_MASK)) {
      step = a[sq].step;
      for(sq2 = sq + step; pos->board[sq2] == EMPTY && sq2 != to; sq2 += step);
      if(sq2 == to) attackers[WHITE][num_of_attackers[WHITE]++] = sq;
    }
  for(sq = PieceListStart(pos, BQ); sq <= H8; sq = NextPiece(pos, sq))
    if(sq!=from && (a[sq].may_attack & Q_MASK)) {
      step = a[sq].step;
      for(sq2 = sq + step; pos->board[sq2] == EMPTY && sq2 != to; sq2 += step);
      if(sq2 == to) attackers[BLACK][num_of_attackers[BLACK]++] = sq;
    }

  // Kings:
  sq = KingSquare(pos, WHITE);
  if(sq != from && (a[sq].may_attack & K_MASK))
    attackers[WHITE][num_of_attackers[WHITE]++] = sq;
  sq = KingSquare(pos, BLACK);
  if(sq != from && (a[sq].may_attack & K_MASK))
    attackers[BLACK][num_of_attackers[BLACK]++] = sq;

  // Compute swap list.
  piece = pos->board[from]; capture = pos->board[to]; 
  side = ColourOfPiece(piece) ^ 1;
  piece_val = PieceValues[piece]; val = PieceValues[capture];
  swaplist[0] = val; n = 1;
  while(num_of_attackers[side] > 0) {
    // Locate smallest attacker for side to move.
    int smallest_value = K_VALUE+1;
    int index = 0;
    for(i = 0; i < num_of_attackers[side]; i++) {
      val = PieceValues[pos->board[attackers[side][i]]];
      if(val < smallest_value) {
	smallest_value = val; index = i;
      }
    }
    sq = attackers[side][index];
    attackers[side][index] = attackers[side][--num_of_attackers[side]];

    // sq now contains the square of the smallest attacker, and 
    // smallest_value contains its value.  Now, scan for new X-ray 
    // attacks, and add them to the attackers list:
    if(a[sq].step & Q_MASK) {
      step = a[sq].step;
      for(sq2 = sq - step; pos->board[sq2] == EMPTY; sq2 -= step);
      if(PieceMask[pos->board[sq2]] & a[sq2].may_attack) {
	c = ColourOfPiece(pos->board[sq2]);
	attackers[c][num_of_attackers[c]++] = sq2;
      }
    }

    // Stop after a king capture:
    if(piece_val == 100) { swaplist[n] = 100; n++; break; }

    // Add the new entry to swaplist:
    swaplist[n] = -swaplist[n - 1] + piece_val; n++;
    piece_val = smallest_value;

    side ^= 1;
  }

  while(--n) swaplist[n - 1] = min(-swaplist[n], swaplist[n - 1]);

  return swaplist[0];
}
