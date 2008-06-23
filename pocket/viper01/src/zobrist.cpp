#include "viper.h"

hashkey_t Zobrist[BK][64], ZobColour, ZobEP[64], ZobCastle[16];

void init_zobrist(void) {
  int i, j;

  for(i=0; i<BK; i++)
    for(j=0; j<64; j++)
      Zobrist[i][j] = genrand_int64();
  ZobEP[0] = 0ULL;
  for(i=1; i<64; i++) ZobEP[i] = genrand_int64();
  for(i=0; i<16; i++) ZobCastle[i] = genrand_int64();
  ZobColour = genrand_int64();
}

hashkey_t compute_hash_key(const position_t *pos) {
  hashkey_t result = 0ULL;
  int side, sq;
  for(side = WHITE; side <= BLACK; side++) 
    for(sq=KingSquare(pos, side); sq!=PieceListEnd; sq=NextPiece(pos, sq)) 
      if(sq <= H8) result ^= ZOBRIST(pos->board[sq], sq);
  result ^= ZOB_EP(pos->ep_square);
  result ^= ZOB_CASTLE(pos->castle_flags);
  if(pos->side == BLACK) result ^= ZobColour;
  return result;
}

hashkey_t compute_phash_key(const position_t *pos) {
  hashkey_t result = 0ULL;
  int side, sq;
  for(side = WHITE; side <= BLACK; side++) 
    for(sq = PawnListStart(pos, side); sq <= H8; sq = NextPiece(pos, sq))
      result ^= ZOBRIST(pos->board[sq], sq);
  return result;
}
