#include "viper.h"

char *move2str(move_t move, char *str) {
  char letters[BK+2] = " pnbrqk  pnbrqk";
  if(move == NULLMOVE) sprintf(str, "0000");
  else if(move == NOMOVE) sprintf(str, "(none)");
  else if(PROMOTION(move))
    sprintf(str, "%c%c%c%c%c", 
            (char)file(FROM(move))+'a', (char)rank(FROM(move))+'1',
            (char)file(TO(move))+'a', (char)rank(TO(move))+'1',
            (char)letters[PROMOTION(move)]);
  else sprintf(str, "%c%c%c%c", 
               (char)file(FROM(move))+'a', (char)rank(FROM(move))+'1',
               (char)file(TO(move))+'a', (char)rank(TO(move))+'1');
  return str;
}

void print_move(move_t move) {
  char str[10];
  send_msg("%s ", move2str(move, str));
}

void print_pv(move_t pv[], int depth, int score, int num) {
  int i, t;
  static int last_score;

  if(depth > 60) return;

  if(RSI->thinking_status == ABORTED)
    score = last_score; 
  else
    last_score = score;

  t = get_time()-RSI->start_time;
  if(abs(score) < MATE_VALUE - 300)
    send_msg("info multipv %d depth %d score cp %d time %d nodes " llu_format " " ,
           num, depth, (score*100)/P_VALUE, t, RSI->nodes);
  else 
    send_msg("info multipv %d depth %d score mate %d time %d nodes " llu_format " ",
           num, depth, (score>0)? (MATE_VALUE-score+1)/2 : -(MATE_VALUE+score)/2,
           t, RSI->nodes);
  if(t > 0) send_msg("nps " llu_format " ",
		   (RSI->nodes*1000ULL)/((uint64) t));
  send_msg("pv ");
    
  for(i = 0; pv[i] != NOMOVE && pv[i] != NULLMOVE; i++) print_move(pv[i]);
  send_msg("\n");
}

void print_multipv(void) {
  int i, k;
  k = min(RSI->root_moves.num, Options->multipv);
  for(i = 0; i < k; i++) 
    print_pv(RSI->root_moves.moves[i].pv,
             RSI->root_moves.moves[i].depth,
             RSI->root_moves.moves[i].score,
             i + 1);
}

void set_position(position_t *pos, char *fen) {
  int sq;
  init_position(pos);
  for(sq = A8; sq >= A1; fen++) {
    if(*fen == '\0') {send_msg("ERROR!\n"); return; }
    if(isdigit(*fen)) {sq += (*fen) - '1' + 1; continue;}
    switch(*fen) {
    case 'K': pos->board[sq] = WK; break;
    case 'k': pos->board[sq] = BK; break;
    case 'Q': pos->board[sq] = WQ; break;
    case 'q': pos->board[sq] = BQ; break;
    case 'R': pos->board[sq] = WR; break;
    case 'r': pos->board[sq] = BR; break;
    case 'B': pos->board[sq] = WB; break;
    case 'b': pos->board[sq] = BB; break;
    case 'N': pos->board[sq] = WN; break;
    case 'n': pos->board[sq] = BN; break;
    case 'P': pos->board[sq] = WP; break;
    case 'p': pos->board[sq] = BP; break;
    case '/': sq -= file(sq) + 16; break;
    case ' ': sq = A1 - 1; break;
    default: send_msg("ERROR!\n"); return;
    }
    if(strchr(" /", *fen) == NULL) sq++;
  }
  switch(tolower(*fen)) {
  case 'w': pos->side = WHITE; pos->xside = BLACK; break;
  case 'b': pos->side = BLACK; pos->xside = WHITE; break;
  default: send_msg("Error!\n"); return;
  }
  do {fen++;} while(isspace(*fen));

  init_piece_lists(pos);

  pos->castle_flags = W_OO_MASK | W_OOO_MASK | B_OO_MASK | B_OOO_MASK;
  while(*fen != '\0' && !isspace(*fen)) {
    if(*fen == 'K') {
      pos->castle_flags ^= W_OO_MASK; InitialKSQ = E1; InitialKRSQ = H1;
    }
    else if(*fen == 'Q') {
      pos->castle_flags ^= W_OOO_MASK; InitialKSQ = E1; InitialQRSQ = A1;
    }
    else if(*fen == 'k') {
      pos->castle_flags ^= B_OO_MASK; InitialKSQ = E1; InitialKRSQ = H1;
    }
    else if(*fen == 'q') {
      pos->castle_flags ^= B_OOO_MASK; InitialKSQ = E1; InitialQRSQ = A1;
    }
    else if(*fen >= 'A' && *fen <= 'H') {
      InitialKSQ = KingSquare(pos, WHITE);
      sq = (int) (*fen) - (int) 'A';
      if(sq > KingSquare(pos, WHITE)) {
        pos->castle_flags ^= W_OO_MASK; InitialKRSQ = sq;
      }
      else {
        pos->castle_flags ^= W_OOO_MASK; InitialQRSQ = sq;
      }
    }
    else if(*fen >= 'a' && *fen <= 'h') {
      InitialKSQ = KingSquare(pos, WHITE);
      sq = (int) (*fen) - (int) 'a';
      if(sq > file(KingSquare(pos, BLACK))) {
        pos->castle_flags ^= B_OO_MASK; InitialKRSQ = sq;
      }
      else {
        pos->castle_flags ^= B_OOO_MASK; InitialQRSQ = sq;
      }
    }
    fen++;
  }
  while(isspace(*fen)) fen++;
  
  if(*fen=='\0') {
    pos->rule50 = 0; pos->ep_square = 0;
  }
  else {
    if(*fen=='-') pos->ep_square = 0;
    else {
      pos->ep_square = parse_square(fen);
      if(pos->ep_square < 0) pos->ep_square = 0;
      do{fen++;} while(!isspace(*fen));
    }
    do{fen++;} while(isspace(*fen));
    if(isdigit(*fen)) sscanf(fen, "%d", &pos->rule50);
    else pos->rule50 = 0;
  }

  pos->last_move = NOMOVE;
  pos->material[WHITE] = compute_material(pos, WHITE);
  pos->material[BLACK] = compute_material(pos, BLACK);
  pos->psq[WHITE] = compute_psq(pos, WHITE);
  pos->psq[BLACK] = compute_psq(pos, BLACK);
  pos->check = find_checkers(pos, pos->check_sqs);
  init_piece_counts(pos);
  pos->key = compute_hash_key(pos);
  pos->pkey = compute_phash_key(pos);
  pos->gply = 0;
}

void quit(void) {
  closeMsgQueues();
  free_tt();
  free_pawn_hash_table();
  exit(0);
}

move_t parse_move(const position_t *pos, const char movestr[]) {
  int from, to, prom;
  move_stack_t moves[256], *end, *ms;

  if(strlen(movestr) < 4) return 0;
  from = parse_square(movestr);
  to = parse_square(movestr+2);
  if(from == -1 || to == -1) return 0;
  if(movestr[4] == 'q' || movestr[4] == 'Q') prom = QUEEN;
  else if(movestr[4] == 'r' || movestr[4] == 'R') prom = ROOK;
  else if(movestr[4] == 'b' || movestr[4] == 'B') prom = BISHOP;
  else if(movestr[4] == 'n' || movestr[4] == 'N') prom = KNIGHT;
  else prom = 0;
  end = generate_moves(pos, moves);
  for(ms = moves; ms < end; ms++) {
    if(FROM(ms->move) == from && TO(ms->move) == to && 
       PROMOTION(ms->move) == prom)
      return ms->move;
    else if(SHORT_CASTLING(ms->move) && FROM(ms->move) == from &&
            to == InitialKRSQ + pos->side * A8)
      return ms->move;
    else if(LONG_CASTLING(ms->move) && FROM(ms->move) == from &&
            to == InitialQRSQ + pos->side * A8)
      return ms->move;
  }
  return 0;
}

int parse_square(const char str[]) {
  if(str[0] >= 'a' && str[0] <= 'h' && str[1] >= '1' && str[1] <= '8')
    return str[0]-'a'+(str[1]-'1')*16;
  else return -1;
}

int get_time(void) {
  struct timeval t;
  gettimeofday(&t, NULL);
  return t.tv_sec*1000 + t.tv_usec/1000; 
}
  
// int Bioskey(void);

void check_for_input(void)
{
//   int             data;
  char            input[1024];
  
//   data = Bioskey();
  get_msg( input , 1024 );
//   if (data) {
  if ( input[0] != '\0' ) {
//     if (fgets(input, 255, stdin) == NULL)
//       strcpy(input, "quit\n");
    if (strncasecmp(input, "quit", 4) == 0) {
      RSI->thinking_status = ABORTED;
      EngineShouldQuit = true;
    }
    else if (strncasecmp(input, "stop", 4) == 0) 
      RSI->thinking_status = ABORTED;
    else if (strncasecmp(input, "ponderhit", 9) == 0) 
      ponderhit();
  }
}

