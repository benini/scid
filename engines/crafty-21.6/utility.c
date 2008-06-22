#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <errno.h>
#include <ctype.h>
#include "chess.h"
#include "data.h"
#if !defined(AMIGA)
#  include <limits.h>
#endif
#if defined(OS2)
#  include <sys/select.h>
#endif
#if defined(NT_i386)
#  include <windows.h>
#  include <winbase.h>
#  include <wincon.h>
#  include <io.h>
#  include <time.h>
#else
#  include <sys/times.h>
#  include <sys/time.h>
#endif
#if defined(UNIX)
#  include <unistd.h>
#  include <sys/types.h>
#  if !defined(LINUX) && !defined(ALPHA) && !defined(HP) && !defined(CRAY1) && \
   !defined(FreeBSD) && !defined(NetBSD) && !defined(__EMX__)
#    if defined(AIX)
#      include <sys/termio.h>
#      include <sys/select.h>
#    else
#      if defined(NEXT)
#        include <bsd/termios.h>
#        include <sys/ioctl.h>
#      else
#        include <sys/filio.h>
#      endif
#    endif
#    if !defined(NEXT)
#      include <stropts.h>
#    endif
#    include <sys/conf.h>
#  else
#    include <sys/ioctl.h>
#  endif
#  include <signal.h>
#  include <sys/wait.h>
#endif
#if defined(UNIX)
#  include <sys/ipc.h>
#  include <sys/shm.h>
#endif

#if defined(__EMX__)
#  define INCL_DOS
#  define INCL_KBD
#  include <os2.h>
#endif

/*
 *******************************************************************************
 *                                                                             *
 *   BookClusterIn() is used to read a cluster in as characters, then stuff    *
 *   the data into a normal array of structures that can be used within Crafty *
 *   without any endian issues.                                                *
 *                                                                             *
 *******************************************************************************
 */
void BookClusterIn(FILE * file, int positions, BOOK_POSITION * buffer)
{
  char file_buffer[BOOK_CLUSTER_SIZE * BOOK_POSITION_SIZE];
  int i;

  fread(file_buffer, positions, BOOK_POSITION_SIZE, file);
  for (i = 0; i < positions; i++) {
    buffer[i].position =
        BookIn64((unsigned char *) (file_buffer + i * BOOK_POSITION_SIZE));
    buffer[i].status_played =
        BookIn32((unsigned char *) (file_buffer + i * BOOK_POSITION_SIZE + 8));
    buffer[i].learn =
        BookIn32f((unsigned char *) (file_buffer + i * BOOK_POSITION_SIZE +
            12));
  }
}

/*
 *******************************************************************************
 *                                                                             *
 *   BookClusterOut() is used to write a cluster out as characters, after      *
 *   converting the normal array of structures into character data that is     *
 *   Endian-independent.                                                       *
 *                                                                             *
 *******************************************************************************
 */
void BookClusterOut(FILE * file, int positions, BOOK_POSITION * buffer)
{
  char file_buffer[BOOK_CLUSTER_SIZE * BOOK_POSITION_SIZE];
  int i;

  for (i = 0; i < positions; i++) {
    memcpy(file_buffer + i * BOOK_POSITION_SIZE, BookOut64(buffer[i].position),
        8);
    memcpy(file_buffer + i * BOOK_POSITION_SIZE + 8,
        BookOut32(buffer[i].status_played), 4);
    memcpy(file_buffer + i * BOOK_POSITION_SIZE + 12,
        BookOut32f(buffer[i].learn), 4);
  }
  fwrite(file_buffer, positions, BOOK_POSITION_SIZE, file);
}

/*
 *******************************************************************************
 *                                                                             *
 *   BookIn32f() is used to convert 4 bytes from the book file into a valid 32 *
 *   bit binary value.  this eliminates endian worries that make the  binary   *
 *   book non-portable across many architectures.                              *
 *                                                                             *
 *******************************************************************************
 */
float BookIn32f(unsigned char *ch)
{
  union {
    float fv;
    int iv;
  } temp;

  temp.iv = (ch[3] << 24) | (ch[2] << 16) | (ch[1] << 8) | ch[0];
  return (temp.fv);
}

/*
 *******************************************************************************
 *                                                                             *
 *   BookIn32() is used to convert 4 bytes from the book file into a valid 32  *
 *   bit binary value.  this eliminates endian worries that make the  binary   *
 *   book non-portable across many architectures.                              *
 *                                                                             *
 *******************************************************************************
 */
int BookIn32(unsigned char *ch)
{

  return ((ch[3] << 24) | (ch[2] << 16) | (ch[1] << 8) | ch[0]);
}

/*
 *******************************************************************************
 *                                                                             *
 *   BookIn64() is used to convert 8 bytes from the book file into a valid 64  *
 *   bit binary value.  this eliminates endian worries that make the  binary   *
 *   book non-portable across many architectures.                              *
 *                                                                             *
 *******************************************************************************
 */
BITBOARD BookIn64(unsigned char *ch)
{

  return ((((BITBOARD) ch[7]) << 56) | (((BITBOARD) ch[6]) << 48) | (((BITBOARD)
              ch[5]) << 40) | (((BITBOARD) ch[4]) << 32) | (((BITBOARD) ch[3])
          << 24) | (((BITBOARD) ch[2]) << 16) | (((BITBOARD) ch[1]) << 8) |
      ((BITBOARD) ch[0]));
}

/*
 *******************************************************************************
 *                                                                             *
 *   BookOut32() is used to convert 4 bytes from a valid 32 bit binary value   *
 *   to a book value.  this eliminates endian worries that make the  binary    *
 *   book non-portable across many architectures.                              *
 *                                                                             *
 *******************************************************************************
 */
unsigned char *BookOut32(int val)
{
  convert_buff[3] = (val >> 24) & 0xff;
  convert_buff[2] = (val >> 16) & 0xff;
  convert_buff[1] = (val >> 8) & 0xff;
  convert_buff[0] = val & 0xff;
  return (convert_buff);
}

/*
 *******************************************************************************
 *                                                                             *
 *   BookOut32f() is used to convert 4 bytes from a valid 32 bit binary value  *
 *   to a book value.  this eliminates endian worries that make the  binary    *
 *   book non-portable across many architectures.                              *
 *                                                                             *
 *******************************************************************************
 */
unsigned char *BookOut32f(float val)
{
  union {
    float fv;
    int iv;
  } temp;

  temp.fv = val;
  convert_buff[3] = (temp.iv >> 24) & 0xff;
  convert_buff[2] = (temp.iv >> 16) & 0xff;
  convert_buff[1] = (temp.iv >> 8) & 0xff;
  convert_buff[0] = temp.iv & 0xff;
  return (convert_buff);
}

/*
 *******************************************************************************
 *                                                                             *
 *   BookOut64() is used to convert 8 bytes from a valid 64 bit binary value   *
 *   to a book value.  this eliminates endian worries that make the  binary    *
 *   book non-portable across many architectures.                              *
 *                                                                             *
 *******************************************************************************
 */
unsigned char *BookOut64(BITBOARD val)
{
  convert_buff[7] = (val >> 56) & 0xff;
  convert_buff[6] = (val >> 48) & 0xff;
  convert_buff[5] = (val >> 40) & 0xff;
  convert_buff[4] = (val >> 32) & 0xff;
  convert_buff[3] = (val >> 24) & 0xff;
  convert_buff[2] = (val >> 16) & 0xff;
  convert_buff[1] = (val >> 8) & 0xff;
  convert_buff[0] = val & 0xff;
  return (convert_buff);
}

#if defined(AMIGA)
#  include <proto/dos.h>
#  define tv_sec tv_secs
#  define tv_usec tv_micro
#  include <exec/types.h>
#  define RAW 1
#  define CON 0
#  include <limits.h>

int _kbhit(void)
{
  BPTR inp;
  BOOLEAN ret;

  inp = Input();
  if (!IsInteractive(inp))
    return FALSE;
  Flush(inp);
  (void) SetMode(inp, RAW);
  ret = WaitForChar(inp, 1);
  (void) SetMode(inp, CON);
  return ret;
}
#endif                          /* if defined(AMIGA)  */

#if defined(NT_i386)
#  include <windows.h>
#  include <conio.h>
int CheckInput(void)
{
  int i;
  static int init = 0, pipe;
  static HANDLE inh;
  DWORD dw;

  if (!xboard && !ics && !isatty(fileno(stdin)))
    return (0);
  if (batch_mode)
    return (0);
  if (strchr(cmd_buffer, '\n'))
    return (1);
  if (xboard) {
#  if defined(FILE_CNT)
    if (stdin->_cnt > 0)
      return stdin->_cnt;
#  endif
    if (!init) {
      init = 1;
      inh = GetStdHandle(STD_INPUT_HANDLE);
      pipe = !GetConsoleMode(inh, &dw);
      if (!pipe) {
        SetConsoleMode(inh, dw & ~(ENABLE_MOUSE_INPUT | ENABLE_WINDOW_INPUT));
        FlushConsoleInputBuffer(inh);
      }
    }
    if (pipe) {
      if (!PeekNamedPipe(inh, NULL, 0, NULL, &dw, NULL)) {
        return 1;
      }
      return dw;
    } else {
      GetNumberOfConsoleInputEvents(inh, &dw);
      return dw <= 1 ? 0 : dw;
    }
  } else {
    i = _kbhit();
  }
  return (i);
}
#endif

#if defined(UNIX)
#  ifdef __EMX__
int CheckInput(void)
{
  static KBDKEYINFO keyinfo;
  int i;

  if (!xboard && !ics && !isatty(fileno(stdin)))
    return (0);
  if (strchr(cmd_buffer, '\n'))
    return (1);
  KbdPeek(&keyinfo, 0);
  if (keyinfo.fbStatus & KBDTRF_FINAL_CHAR_IN)
    i = 1;
  else
    i = 0;
  return (i);
}
#  else
int CheckInput(void)
{
  fd_set readfds;
  struct timeval tv;
  int data;

  if (!xboard && !ics && !isatty(fileno(stdin)))
    return (0);
  if (batch_mode)
    return (0);
  if (strchr(cmd_buffer, '\n'))
    return (1);
  FD_ZERO(&readfds);
  FD_SET(fileno(stdin), &readfds);
#    if defined(DGT)
  if (DGT_active)
    FD_SET(from_dgt, &readfds);
#    endif
  tv.tv_sec = 0;
  tv.tv_usec = 0;
  select(16, &readfds, 0, 0, &tv);
  data = FD_ISSET(fileno(stdin), &readfds);
#    if defined(DGT)
  if (DGT_active)
    data |= FD_ISSET(from_dgt, &readfds);
#    endif
  return (data);
}
#  endif
#endif

void ClearHashTableScores(int dopawnstoo)
{
  int i;

  if (trans_ref) {
    for (i = 0; i < hash_table_size; i++) {
      (trans_ref + i)->prefer.word1 =
          ((trans_ref + i)->prefer.word1 & mask_clear_entry) | (BITBOARD) 65536;
      (trans_ref + i)->always[0].word1 =
          ((trans_ref +
              i)->always[0].word1 & mask_clear_entry) | (BITBOARD) 65536;
      (trans_ref + i)->always[1].word1 =
          ((trans_ref +
              i)->always[1].word1 & mask_clear_entry) | (BITBOARD) 65536;
    }
    if (dopawnstoo) {
      for (i = 0; i < pawn_hash_table_size; i++) {
        (pawn_hash_table + i)->key = 0;
        (pawn_hash_table + i)->p_score = 0;
        (pawn_hash_table + i)->protected = 0;
        (pawn_hash_table + i)->black_defects_k = 0;
        (pawn_hash_table + i)->black_defects_q = 0;
        (pawn_hash_table + i)->white_defects_k = 0;
        (pawn_hash_table + i)->white_defects_q = 0;
        (pawn_hash_table + i)->passed_w = 0;
        (pawn_hash_table + i)->passed_w = 0;
        (pawn_hash_table + i)->outside = 0;
        (pawn_hash_table + i)->candidates_w = 0;
        (pawn_hash_table + i)->candidates_b = 0;
      }
    }
  }
  shared->local[0]->pawn_score.key = 0;
}

/*
 *******************************************************************************
 *                                                                             *
 *   CraftyExit() is used to terminate the program.  the main functionality    *
 *   is to make sure the "quit" flag is set so that any spinning threads will  *
 *   also exit() rather than spinning forever which can cause GUIs to hang     *
 *   since all processes have not terminated.                                  *
 *                                                                             *
 *******************************************************************************
 */
void CraftyExit(int exit_type)
{
  shared->abort_search = 1;
  shared->quit = 1;
  exit(exit_type);
}

/*
 *******************************************************************************
 *                                                                             *
 *   DisplayArray() prints array data either 8 or 16 values per line, and also *
 *   reverses the output for arrays that overlay the chess board so that the   *
 *   'white side" is at the bottom rather than the top.  this is mainly used   *
 *   from inside Option() to display the many evaluation terms.                *
 *                                                                             *
 *******************************************************************************
 */
void DisplayArray(int *array, int size)
{
  int i, j, len = 16;

  if (abs(size) % 10 == 0)
    len = 10;
  else if (abs(size) % 8 == 0)
    len = 8;
  if (size > 0 && size % 16 == 0 && len == 8)
    len = 16;
  if (size > 0) {
    printf("    ");
    for (i = 0; i < size; i++) {
      printf("%3d ", array[i]);
      if ((i + 1) % len == 0) {
        printf("\n");
        if (i < size - 1)
          printf("    ");
      }
    }
    if (i % len != 0)
      printf("\n");
  }
  if (size < 0) {
    for (i = 0; i < 8; i++) {
      printf("    ");
      for (j = 0; j < 8; j++) {
        printf("%3d ", array[(7 - i) * 8 + j]);
      }
      printf(" | %d\n", 8 - i);
    }
    printf("    ---------------------------------\n");
    printf("      a   b   c   d   e   f   g   h\n");
  }
}

void DisplayBitBoard(BITBOARD board)
{
  int i, j, x;

  for (i = 56; i >= 0; i -= 8) {
    x = (board >> i) & 255;
    for (j = 1; j < 256; j = j << 1)
      if (x & j)
        printf("X ");
      else
        printf("- ");
    printf("\n");
  }
}

/*
 *******************************************************************************
 *                                                                             *
 *   DisplayChessBoard() is used to display the board since it is kept in      *
 *   both the bit-board and array formats, here we use the array format which  *
 *   is nearly ready for display as is.                                        *
 *                                                                             *
 *******************************************************************************
 */
void DisplayChessBoard(FILE * display_file, POSITION pos)
{
  int display_board[64];
  static const char display_string[16][4] =
      { "<Q>", "<R>", "<B>", "   ", "<K>", "<N>", "<P>", "   ",
    "-P-", "-N-", "-K-", "   ", "-B-", "-R-", "-Q-", " . "
  };
  int i, j;

/*
 ************************************************************
 *                                                          *
 *   first, convert square values to indices to the proper  *
 *   text string.                                           *
 *                                                          *
 ************************************************************
 */
  for (i = 0; i < 64; i++) {
    display_board[i] = pos.board[i] + 7;
    if (pos.board[i] == 0) {
      if (((i / 8) & 1) == ((i % 8) & 1))
        display_board[i] = 15;
    }
  }
/*
 ************************************************************
 *                                                          *
 *   now that that's done, simply display using 8 squares   *
 *   per line.                                              *
 *                                                          *
 ************************************************************
 */
  fprintf(display_file, "\n       +---+---+---+---+---+---+---+---+\n");
  for (i = 7; i >= 0; i--) {
    fprintf(display_file, "   %2d  ", i + 1);
    for (j = 0; j < 8; j++)
      fprintf(display_file, "|%s", display_string[display_board[i * 8 + j]]);
    fprintf(display_file, "|\n");
    fprintf(display_file, "       +---+---+---+---+---+---+---+---+\n");
  }
  fprintf(display_file, "         a   b   c   d   e   f   g   h\n\n");
}

char *DisplayEvaluation(int value, int wtm)
{
  static char out[10];
  int tvalue;

  tvalue = (wtm) ? value : -value;
  if (abs(value) < MATE - 300)
    sprintf(out, "%7.2f", ((float) tvalue) / 100.0);
  else if (abs(value) > MATE) {
    if (tvalue < 0)
      sprintf(out, " -infnty");
    else
      sprintf(out, " +infnty");
  } else if (value == MATE - 2 && wtm)
    sprintf(out, "   Mate");
  else if (value == MATE - 2 && !wtm)
    sprintf(out, "  -Mate");
  else if (value == -(MATE - 1) && wtm)
    sprintf(out, "  -Mate");
  else if (value == -(MATE - 1) && !wtm)
    sprintf(out, "   Mate");
  else if (value > 0 && wtm)
    sprintf(out, "  Mat%.2d", (MATE - value) / 2);
  else if (value > 0 && !wtm)
    sprintf(out, " -Mat%.2d", (MATE - value) / 2);
  else if (wtm)
    sprintf(out, " -Mat%.2d", (MATE - abs(value)) / 2);
  else
    sprintf(out, "  Mat%.2d", (MATE - abs(value)) / 2);
  return (out);
}

char *DisplayEvaluationKibitz(int value, int wtm)
{
  static char out[10];
  int tvalue;

  tvalue = (wtm) ? value : -value;
  if (abs(value) < MATE - 300)
    sprintf(out, "%+.2f", ((float) tvalue) / 100.0);
  else if (abs(value) > MATE) {
    if (tvalue < 0)
      sprintf(out, "-infnty");
    else
      sprintf(out, "+infnty");
  } else if (value == MATE - 2 && wtm)
    sprintf(out, "Mate");
  else if (value == MATE - 2 && !wtm)
    sprintf(out, "-Mate");
  else if (value == -(MATE - 1) && wtm)
    sprintf(out, "-Mate");
  else if (value == -(MATE - 1) && !wtm)
    sprintf(out, "Mate");
  else if (value > 0 && wtm)
    sprintf(out, "Mat%.2d", (MATE - value) / 2);
  else if (value > 0 && !wtm)
    sprintf(out, "-Mat%.2d", (MATE - value) / 2);
  else if (wtm)
    sprintf(out, "-Mat%.2d", (MATE - abs(value)) / 2);
  else
    sprintf(out, "Mat%.2d", (MATE - abs(value)) / 2);
  return (out);
}

void DisplayPieceBoards(int *white, int *black)
{
  int i, j;

  printf("                 white                      ");
  printf("                 black\n");
  for (i = 7; i >= 0; i--) {
    for (j = i * 8; j < i * 8 + 8; j++)
      printf("%4d ", white[j]);
    printf("    ");
    for (j = i * 8; j < i * 8 + 8; j++)
      printf("%4d ", black[j]);
    printf("\n");
  }
}

/* last modified 08/07/05 */
/*
 *******************************************************************************
 *                                                                             *
 *   DisplayPV() is used to display a PV during the search.  it will also note *
 *   when the PV was terminated by a hash table hit and will check the hash    *
 *   entries to see if the PV can be extended by using moves from hits.        *
 *                                                                             *
 *******************************************************************************
 */
void DisplayPV(TREE * RESTRICT tree, int level, int wtm, int time, int value,
    PATH * pv)
{
  char buffer[512], *buffp, *bufftemp;
  int i, t_move_number, type, j, dummy = 0;
  int nskip = 0, twtm = wtm;

  shared->root_print_ok = shared->root_print_ok ||
      tree->nodes_searched > shared->noise_level;
/*
 ************************************************************
 *                                                          *
 *   initialize.                                            *
 *                                                          *
 ************************************************************
 */
  for (i = 0; i < shared->n_root_moves; i++)
    if (!(shared->root_moves[i].status & 128) &&
        shared->root_moves[i].status & 64)
      nskip++;
  if (level == 5)
    type = 4;
  else
    type = 2;
  t_move_number = shared->move_number;
  if (shared->display_options & 64)
    sprintf(buffer, " %d.", shared->move_number);
  else
    buffer[0] = 0;
  if ((shared->display_options & 64) && !wtm)
    sprintf(buffer + strlen(buffer), " ...");
  for (i = 1; i <= (int) pv->pathl; i++) {
    if ((shared->display_options & 64) && i > 1 && wtm)
      sprintf(buffer + strlen(buffer), " %d.", t_move_number);
    sprintf(buffer + strlen(buffer), " %s", OutputMove(tree, pv->path[i], i,
            wtm));
    MakeMove(tree, i, pv->path[i], wtm);
    wtm = Flip(wtm);
    if (wtm)
      t_move_number++;
  }
/*
 ************************************************************
 *                                                          *
 *   if the pv was terminated prematurely by a trans/ref    *
 *   hit, see if any more moves are in the trans/ref table  *
 *   and if so, add 'em to the end of the PV so we will     *
 *   have better move ordering next iteration.              *
 *                                                          *
 ************************************************************
 */
  if (pv->pathh == 1) {
    for (i = pv->pathl + 1; i < MAXPLY; i++) {
      HashProbe(tree, i, 0, wtm, &dummy, dummy, &dummy);
      if (tree->hash_move[i] && ValidMove(tree, i, wtm, tree->hash_move[i])) {
        pv->path[i] = tree->hash_move[i];
        for (j = 1; j < i; j++)
          if (pv->path[i] == pv->path[j])
            break;
        if (j < i)
          break;
        pv->pathl++;
        if ((shared->display_options & 64) && wtm)
          sprintf(buffer + strlen(buffer), " %d.", t_move_number);
        sprintf(buffer + strlen(buffer), " %s", OutputMove(tree, pv->path[i], i,
                wtm));
        MakeMove(tree, i, pv->path[i], wtm);
      } else
        break;
      wtm = Flip(wtm);
      if (wtm)
        t_move_number++;
    }
    sprintf(buffer + strlen(buffer), " <HT>");
  } else if (pv->pathh == 2)
    sprintf(buffer + strlen(buffer), " <EGTB>");
  strcpy(shared->kibitz_text, buffer);
  if (nskip > 1 && shared->max_threads > 1)
    sprintf(buffer + strlen(buffer), " (s=%d)", nskip);
  if (shared->root_print_ok) {
    Lock(shared->lock_io);
    Print(type, "               ");
    if (level == 6)
      Print(type, "%2i   %s%s   ", shared->iteration_depth, DisplayTime(time),
          DisplayEvaluation(value, twtm));
    else
      Print(type, "%2i-> %s%s   ", shared->iteration_depth, DisplayTime(time),
          DisplayEvaluation(value, twtm));
    buffp = buffer + 1;
    do {
      if ((int) strlen(buffp) > 34)
        bufftemp = strchr(buffp + 34, ' ');
      else
        bufftemp = 0;
      if (bufftemp)
        *bufftemp = 0;
      Print(type, "%s\n", buffp);
      buffp = bufftemp + 1;
      if (bufftemp)
        Print(type, "                                    ");
    } while (bufftemp);
    Kibitz(level, twtm, shared->iteration_depth,
        shared->end_time - shared->start_time, value, tree->nodes_searched,
        tree->egtb_probes_successful, shared->kibitz_text);
    Unlock(shared->lock_io);
  }
  for (i = pv->pathl; i > 0; i--) {
    wtm = Flip(wtm);
    UnmakeMove(tree, i, pv->path[i], wtm);
  }
}

char *DisplaySQ(unsigned int sq)
{
  static char out[3];

  out[0] = File(From(sq)) + 'a';
  out[1] = Rank(From(sq)) + '1';
  out[2] = 0;
  return (out);
}

char *DisplayHHMM(unsigned int time)
{
  static char out[10];

  time = time / 6000;
  sprintf(out, "%3u:%02u", time / 60, time % 60);
  return (out);
}

char *DisplayKM(unsigned int val)
{
  static char out[10];

  if (val < 1000)
    sprintf(out, "%d", val);
  else if (val < 1000000)
    sprintf(out, "%dK", val / 1000);
  else
    sprintf(out, "%.1fM", (float) val / 1000000);
  return (out);
}

char *DisplayTime(unsigned int time)
{
  static char out[10];

  if (time < 6000)
    sprintf(out, "%6.2f", (float) time / 100.0);
  else {
    time = time / 100;
    sprintf(out, "%3u:%02u", time / 60, time % 60);
  }
  return (out);
}

char *DisplayTimeKibitz(unsigned int time)
{
  static char out[10];

  if (time < 6000)
    sprintf(out, "%.2f", (float) time / 100.0);
  else {
    time = time / 100;
    sprintf(out, "%u:%02u", time / 60, time % 60);
  }
  return (out);
}

void DisplayTreeState(TREE * RESTRICT tree, int sply, int spos, int maxply)
{
  int left, i, *mvp, parallel = 0;
  char buf[1024];

  buf[0] = 0;
  if (sply == 1) {
    left = 0;
    for (i = 0; i < shared->n_root_moves; i++)
      if (!(shared->root_moves[i].status & 128))
        left++;
    sprintf(buf, "%d:%d/%d  ", 1, left, shared->n_root_moves);
  } else {
    for (i = 0; i < spos - 6; i++)
      sprintf(buf + strlen(buf), " ");
    sprintf(buf + strlen(buf), "[p%2d] ", tree->thread_id);
  }
  for (i = Max(sply, 2); i <= maxply; i++) {
    left = 0;
    for (mvp = tree->last[i - 1]; mvp < tree->last[i]; mvp++)
      if (*mvp)
        left++;
    sprintf(buf + strlen(buf), "%d:%d/%d  ", i, left,
        (int) (tree->last[i] - tree->last[i - 1]));
    if (!(i % 8))
      sprintf(buf + strlen(buf), "\n");
    if (tree->nprocs > 1 && tree->ply == i) {
      parallel = strlen(buf);
      break;
    }
    if (sply > 1)
      break;
  }
  printf("%s\n", buf);
  if (sply == 1 && tree->nprocs) {
    for (i = 0; i < shared->max_threads; i++)
      if (tree->siblings[i])
        DisplayTreeState(tree->siblings[i], tree->ply + 1, parallel, maxply);
  }
}

void Display2BitBoards(BITBOARD board1, BITBOARD board2)
{
  int i, j, x, y;

  for (i = 56; i >= 0; i -= 8) {
    x = (board1 >> i) & 255;
    for (j = 128; j > 0; j = j >> 1)
      if (x & j)
        printf("X ");
      else
        printf("- ");
    printf("    ");
    y = (board2 >> i) & 255;
    for (j = 128; j > 0; j = j >> 1)
      if (y & j)
        printf("X ");
      else
        printf("- ");
    printf("\n");
  }
}

#if !defined(NOEGTB)
/* last modified 08/07/05 */
/*
 *******************************************************************************
 *                                                                             *
 *   EGTBPV() is used to display the full PV (path) for a mate/mated in N EGTB *
 *   position.                                                                 *
 *                                                                             *
 *******************************************************************************
 */
void EGTBPV(TREE * RESTRICT tree, int wtm)
{
  int moves[1024], current[256];
  BITBOARD hk[1024], phk[1024];
  char buffer[16384], *next;
  BITBOARD pos[1024];
  int value;
  register int ply, i, j, nmoves, *last, t_move_number;
  register int best = 0, bestmv = 0, optimal_mv = 0;
  register int legal;

/*
 ************************************************************
 *                                                          *
 *   first, see if this is a known EGTB position.  if not,  *
 *   we can bug out right now.                              *
 *                                                          *
 ************************************************************
 */
  if (!EGTB_setup)
    return;
  tree->position[1] = tree->position[0];
  if (WhiteCastle(1) + BlackCastle(1))
    return;
  if (!EGTBProbe(tree, 1, wtm, &value))
    return;
  t_move_number = shared->move_number;
  if (shared->display_options & 64)
    sprintf(buffer, "%d.", shared->move_number);
  else
    buffer[0] = 0;
  if ((shared->display_options & 64) && !wtm)
    sprintf(buffer + strlen(buffer), " ...");
/*
 ************************************************************
 *                                                          *
 *   the rest is simple, but messy.  generate all moves,    *
 *   then find the move with the best egtb score and make   *
 *   it (note that if there is only one that is optimal, it *
 *   is flagged as such).  we then repeat this over and     *
 *   over until we reach the end, or until we repeat a move *
 *   and can call it a repetition.                          *
 *                                                          *
 ************************************************************
 */
  for (ply = 1; ply < 1024; ply++) {
    pos[ply] = HashKey;
    last = GenerateCaptures(tree, 1, wtm, current);
    last = GenerateNonCaptures(tree, 1, wtm, last);
    nmoves = last - current;
    best = -MATE - 1;
    legal = 0;
    for (i = 0; i < nmoves; i++) {
      MakeMove(tree, 1, current[i], wtm);
      if (!Check(wtm)) {
        legal++;
        if (TotalPieces == 2 || EGTBProbe(tree, 2, Flip(wtm), &value)) {
          if (TotalPieces > 2)
            value = -value;
          else
            value = DrawScore(wtm);
          if (value > best) {
            best = value;
            bestmv = current[i];
            optimal_mv = 1;
          } else if (value == best)
            optimal_mv = 0;
        }
      }
      UnmakeMove(tree, 1, current[i], wtm);
    }
    if (best > -MATE - 1) {
      moves[ply] = bestmv;
      if ((shared->display_options & 64) && ply > 1 && wtm)
        sprintf(buffer + strlen(buffer), " %d.", t_move_number);
      sprintf(buffer + strlen(buffer), " %s", OutputMove(tree, bestmv, 1, wtm));
      if (!strchr(buffer, '#') && legal > 1 && optimal_mv)
        sprintf(buffer + strlen(buffer), "!");
      hk[ply] = HashKey;
      phk[ply] = PawnHashKey;
      MakeMove(tree, 1, bestmv, wtm);
      tree->position[1] = tree->position[2];
      wtm = Flip(wtm);
      for (j = 2 - (ply & 1); j < ply; j += 2)
        if (pos[ply] == pos[j])
          break;
      if (j < ply)
        break;
      if (wtm)
        t_move_number++;
      if (strchr(buffer, '#'))
        break;
    } else {
      ply--;
      break;
    }
  }
  nmoves = ply;
  for (; ply > 0; ply--) {
    wtm = Flip(wtm);
    tree->save_hash_key[1] = hk[ply];
    tree->save_pawn_hash_key[1] = phk[ply];
    UnmakeMove(tree, 1, moves[ply], wtm);
    tree->position[2] = tree->position[1];
  }
  next = buffer;
  while (nmoves) {
    if (strlen(next) > 72) {
      int i;

      for (i = 0; i < 16; i++)
        if (*(next + 64 + i) == ' ')
          break;
      *(next + 64 + i) = 0;
      printf("%s\n", next);
      next += 64 + i + 1;
    } else {
      printf("%s\n", next);
      break;
    }
  }
}
#endif

void DisplayChessMove(char *title, int move)
{
  Print(4095, "%s  piece=%d, from=%d, to=%d, captured=%d, promote=%d\n", title,
      Piece(move), From(move), To(move), Captured(move), Promote(move));
}

/* last modified 08/07/05 */
/*
 *******************************************************************************
 *                                                                             *
 *   FormatPV() is used to display a PV during the search.  it will also note  *
 *   when the PV was terminated by a hash table hit.                           *
 *                                                                             *
 *******************************************************************************
 */
char *FormatPV(TREE * RESTRICT tree, int wtm, PATH pv)
{
  static char buffer[512];
  int i, t_move_number;

/*
 ************************************************************
 *                                                          *
 *   initialize.                                            *
 *                                                          *
 ************************************************************
 */
  t_move_number = shared->move_number;
  if (shared->display_options & 64)
    sprintf(buffer, " %d.", shared->move_number);
  else
    buffer[0] = 0;
  if ((shared->display_options & 64) && !wtm)
    sprintf(buffer + strlen(buffer), " ...");
  for (i = 1; i <= (int) pv.pathl; i++) {
    if ((shared->display_options & 64) && i > 1 && wtm)
      sprintf(buffer + strlen(buffer), " %d.", t_move_number);
    sprintf(buffer + strlen(buffer), " %s", OutputMove(tree, pv.path[i], i,
            wtm));
    MakeMove(tree, i, pv.path[i], wtm);
    wtm = Flip(wtm);
    if (wtm)
      t_move_number++;
  }
  for (i = pv.pathl; i > 0; i--) {
    wtm = Flip(wtm);
    UnmakeMove(tree, i, pv.path[i], wtm);
  }
  return (buffer);
}

unsigned int ReadClock(void)
{
#if defined(UNIX) || defined(AMIGA)
  struct timeval timeval;
  struct timezone timezone;
#endif
#if defined(NT_i386)
  HANDLE hThread;
  FILETIME ftCreate, ftExit, ftKernel, ftUser;
  BITBOARD tUser64;
#endif

#if defined(UNIX) || defined(AMIGA)
  gettimeofday(&timeval, &timezone);
  return (timeval.tv_sec * 100 + (timeval.tv_usec / 10000));
#endif
#if defined(NT_i386)
  return ((unsigned int) GetTickCount() / 10);
#endif
}

/*
 *******************************************************************************
 *                                                                             *
 *   FindBlockID() converts a thread block pointer into an ID that is easier to*
 *   understand when debugging.                                                *
 *                                                                             *
 *******************************************************************************
 */
int FindBlockID(TREE * RESTRICT block)
{
  int i;

  for (i = 0; i < MAX_BLOCKS + 1; i++)
    if (block == shared->local[i])
      return (i);
  return (-1);
}

/*
 *******************************************************************************
 *                                                                             *
 *   HasOpposition() is used to determine if one king stands in "opposition"   *
 *   to the other.  if the kings are opposed on the same file or else are      *
 *   opposed on the same diagonal, then the side not-to-move has the opposition*
 *   and the side-to-move must give way.                                       *
 *                                                                             *
 *******************************************************************************
 */
int HasOpposition(int on_move, int white_king, int black_king)
{
  register int file_distance, rank_distance;

  file_distance = FileDistance(white_king, black_king);
  rank_distance = RankDistance(white_king, black_king);
  if (rank_distance < 2)
    return (1);
  if (on_move) {
    if (rank_distance & 1) {
      rank_distance--;
      if (file_distance & 1)
        file_distance--;
    } else if (file_distance & 1) {
      file_distance--;
      if (rank_distance & 1)
        rank_distance--;
    }
  }
  if (!(file_distance & 1) && !(rank_distance & 1))
    return (1);
  return (0);
}

/*
 *******************************************************************************
 *                                                                             *
 *   InterposeSquares() is used to compute the set of squares that block an    *
 *   attack on the king by a sliding piece, by interposing any piece between   *
 *   the attacking piece and the king on the same ray.                         *
 *                                                                             *
 *******************************************************************************
 */
BITBOARD InterposeSquares(int check_direction, int king_square,
    int checking_square)
{
  register BITBOARD target;

/*
 ************************************************************
 *                                                          *
 *   if this is a check from a single sliding piece, then   *
 *   we can interpose along the checking rank/file/diagonal *
 *   and block the check.  otherwise, interposing is not a  *
 *   possibility.                                           *
 *                                                          *
 ************************************************************
 */
  switch (check_direction) {
  case +1:
    target = plus1dir[king_square - 1] ^ plus1dir[checking_square];
    break;
  case +7:
    target = plus7dir[king_square - 7] ^ plus7dir[checking_square];
    break;
  case +8:
    target = plus8dir[king_square - 8] ^ plus8dir[checking_square];
    break;
  case +9:
    target = plus9dir[king_square - 9] ^ plus9dir[checking_square];
    break;
  case -1:
    target = minus1dir[king_square + 1] ^ minus1dir[checking_square];
    break;
  case -7:
    target = minus7dir[king_square + 7] ^ minus7dir[checking_square];
    break;
  case -8:
    target = minus8dir[king_square + 8] ^ minus8dir[checking_square];
    break;
  case -9:
    target = minus9dir[king_square + 9] ^ minus9dir[checking_square];
    break;
  default:
    target = 0;
    break;
  }
  return (target);
}

/* last modified 06/13/05 */
/*
 *******************************************************************************
 *                                                                             *
 *   InvalidPosition() is used to determine if the position just entered via a *
 *   FEN-string or the "edit" command is legal.  This includes the expected    *
 *   tests for too many pawns or pieces for one side, pawns on impossible      *
 *   squares, and the like.                                                    *
 *                                                                             *
 *******************************************************************************
 */
int InvalidPosition(TREE * RESTRICT tree)
{
  int error = 0;
  int wp, wn, wb, wr, wq, bp, bn, bb, br, bq;

  wp = PopCnt(WhitePawns);
  wn = PopCnt(WhiteKnights);
  wb = PopCnt(WhiteBishops);
  wr = PopCnt(WhiteRooks);
  wq = PopCnt(WhiteQueens);
  bp = PopCnt(BlackPawns);
  bn = PopCnt(BlackKnights);
  bb = PopCnt(BlackBishops);
  br = PopCnt(BlackRooks);
  bq = PopCnt(BlackQueens);
  if (wp > 8) {
    Print(4095, "illegal position, too many white pawns\n");
    error = 1;
  }
  if (wp + wn > 10) {
    Print(4095, "illegal position, too many white knights\n");
    error = 1;
  }
  if (wp + wb > 10) {
    Print(4095, "illegal position, too many white bishops\n");
    error = 1;
  }
  if (wp + wr > 10) {
    Print(4095, "illegal position, too many white rooks\n");
    error = 1;
  }
  if (wp + wq > 10) {
    Print(4095, "illegal position, too many white queens\n");
    error = 1;
  }
  if (WhiteKingSQ < 0) {
    Print(4095, "illegal position, no white king\n");
    error = 1;
  }
  if (wp + wn + wb + wr + wq > 15) {
    Print(4095, "illegal position, too many white pieces\n");
    error = 1;
  }
  if (WhitePawns & (rank_mask[RANK1] | rank_mask[RANK8])) {
    Print(4095, "illegal position, white pawns on first/eighth rank(s)\n");
    error = 1;
  }
  if (bp > 8) {
    Print(4095, "illegal position, too many black pawns\n");
    error = 1;
  }
  if (bp + bn > 10) {
    Print(4095, "illegal position, too many black knights\n");
    error = 1;
  }
  if (bp + bb > 10) {
    Print(4095, "illegal position, too many black bishops\n");
    error = 1;
  }
  if (bp + br > 10) {
    Print(4095, "illegal position, too many black rooks\n");
    error = 1;
  }
  if (bp + bq > 10) {
    Print(4095, "illegal position, too many black queens\n");
    error = 1;
  }
  if (BlackKingSQ < 0) {
    Print(4095, "illegal position, no black king\n");
    error = 1;
  }
  if (bp + bn + bb + br + bq > 15) {
    Print(4095, "illegal position, too many black pieces\n");
    error = 1;
  }
  if (BlackPawns & (rank_mask[RANK1] | rank_mask[RANK8])) {
    Print(4095, "illegal position, black pawns on first/eighth rank(s)\n");
    error = 1;
  }
  if (error == 0 && Check(!wtm)) {
    Print(4095, "ERROR side not on move is in check!\n");
    error = 1;
  }
  return (error);
}

int KingPawnSquare(int pawn, int king, int queen, int ptm)
{
  register int pdist, kdist;

  pdist = abs(Rank(pawn) - Rank(queen));
  kdist =
      (abs(Rank(king) - Rank(queen)) >
      abs(File(king) - File(queen))) ? abs(Rank(king) -
      Rank(queen)) : abs(File(king) - File(queen));
  if (!ptm)
    pdist++;
  if (pdist < kdist)
    return (0);
  else
    return (1);
}

/* last modified 08/07/05 */
/*
 *******************************************************************************
 *                                                                             *
 *   NewGame() is used to initialize the chess position and timing controls to *
 *   the setup needed to start a new game.                                     *
 *                                                                             *
 *******************************************************************************
 */
void NewGame(int save)
{
  static int save_book_selection_width = 5;
  static int save_kibitz = 0, save_channel = 0;
  static int save_resign = 0, save_resign_count = 0, save_draw_count = 0;
  static int save_learning = 0;
  static int save_accept_draws = 0;
  int id;
  TREE *const tree = shared->local[0];

  new_game = 0;
  if (save) {
    save_book_selection_width = book_selection_width;
    save_kibitz = kibitz;
    save_channel = channel;
    save_resign = resign;
    save_resign_count = resign_count;
    save_draw_count = draw_count;
    save_learning = learning;
    save_accept_draws = accept_draws;
  } else {
    if (learning & book_learning && shared->moves_out_of_book) {
      int val =
          (shared->crafty_is_white) ? last_search_value : -last_search_value;

      LearnBook(tree, shared->crafty_is_white, val, 0, 0, 1);
    }
    if (ics)
      printf("*whisper Hello from Crafty v%s !\n", version);
    if (xboard) {
      printf("tellicsnoalias set 1 Crafty v%s (%d cpus)\n", version, Max(1,
              shared->max_threads));
    }
    over = 0;
    shared->moves_out_of_book = 0;
    learn_positions_count = 0;
    ponder_move = 0;
    last_search_value = 0;
    last_pv.pathd = 0;
    last_pv.pathl = 0;
    strcpy(initial_position, "");
    InitializeChessBoard(&tree->position[0]);
    InitializeHashTables();
    force = 0;
    shared->trojan_check = 0;
    shared->computer_opponent = 0;
    books_file = normal_bs_file;
    shared->draw_score[0] = 0;
    shared->draw_score[1] = 0;
    wtm = 1;
    shared->move_number = 1;
    shared->tc_time_remaining = shared->tc_time;
    shared->tc_time_remaining_opponent = shared->tc_time;
    shared->tc_moves_remaining = shared->tc_moves;
    if (move_actually_played) {
      if (log_file)
        fclose(log_file);
      if (history_file)
        fclose(history_file);
      id = InitializeGetLogID();
      sprintf(log_filename, "%s/log.%03d", log_path, id);
      sprintf(history_filename, "%s/game.%03d", log_path, id);
      log_file = fopen(log_filename, "w");
      history_file = fopen(history_filename, "w+");
      if (!history_file) {
        printf("ERROR, unable to open game history file, exiting\n");
        CraftyExit(1);
      }
    }
    move_actually_played = 0;
    book_selection_width = save_book_selection_width;
    kibitz = save_kibitz;
    channel = save_channel;
    resign = save_resign;
    resign_count = save_resign_count;
    resign_counter = 0;
    draw_count = save_draw_count;
    accept_draws = save_accept_draws;
    draw_counter = 0;
    usage_level = 0;
    learning = save_learning;
    predicted = 0;
    shared->kibitz_depth = 0;
    tree->nodes_searched = 0;
    tree->fail_high = 0;
    tree->fail_high_first = 0;
    shared->kibitz_text[0] = 0;
  }
}

char *Normal(void)
{
#if defined(NT_i386)
  HANDLE std_console;

  std_console = GetStdHandle(STD_OUTPUT_HANDLE);
#endif

  if (ansi) {
#if defined(UNIX) || defined(AMIGA)
    return ("\033[0m");
#elif defined(NT_i386)
    SetConsoleTextAttribute(std_console,
        FOREGROUND_RED | FOREGROUND_GREEN | FOREGROUND_BLUE);
    return ("");
#else
    return ("\033[1;44;37m");
#endif
  }
  return ("");
}

int ParseTime(char *string)
{
  int time = 0;
  int minutes = 0;

  while (*string) {
    switch (*string) {
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
    case '8':
    case '9':
      minutes = minutes * 10 + (*string) - '0';
      break;
    case ':':
      time = time * 60 + minutes;
      minutes = 0;
      break;
    default:
      Print(4095, "illegal character in time, please re-enter\n");
      break;
    }
    string++;
  }
  return (time * 60 + minutes);
}

void Pass(void)
{
  char buffer[128];
  const int halfmoves_done = 2 * (shared->move_number - 1) + (1 - wtm);
  int prev_pass = 0;

/* Was previous move a pass? */
  if (halfmoves_done > 0) {
    fseek(history_file, (halfmoves_done - 1) * 10, SEEK_SET);
    if (fscanf(history_file, "%s", buffer) == 0 || strcmp(buffer, "pass") == 0)
      prev_pass = 1;
  }
  if (prev_pass) {
    if (wtm)
      shared->move_number--;
  } else {
    fseek(history_file, halfmoves_done * 10, SEEK_SET);
    fprintf(history_file, "%9s\n", "pass");
    if (!wtm)
      shared->move_number++;
  }
  wtm = Flip(wtm);
}

/*
 *******************************************************************************
 *                                                                             *
 *   PinnedOnKing() is used to determine if the piece on <square> is pinned    *
 *   against the king, so that it's illegal to move it.  this is used to screen*
 *   potential moves by GenerateCheckEvasions() so that illegal moves are not  *
 *   produced.                                                                 *
 *                                                                             *
 *******************************************************************************
 */
int PinnedOnKing(TREE * RESTRICT tree, int wtm, int square)
{
  register int ray;

  if (wtm) {
/*
 ************************************************************
 *                                                          *
 *   first, determine if the piece being moved is on the    *
 *   same diagonal, rank or file as the king.               *
 *                                                          *
 ************************************************************
 */
    ray = directions[square][WhiteKingSQ];
    if (!ray)
      return (0);
/*
 ************************************************************
 *                                                          *
 *   if they are on the same ray, then determine if the     *
 *   king blocks a bishop attack in one direction from this *
 *   square and a bishop or queen blocks a bishop attack    *
 *   on the same diagonal in the opposite direction.        *
 *                                                          *
 ************************************************************
 */
    switch (abs(ray)) {
    case 1:
      if (AttacksRank(square) & WhiteKing)
        return ((AttacksRank(square) & RooksQueens & BlackPieces) != 0);
      else
        return (0);
    case 7:
      if (AttacksDiagh1(square) & WhiteKing)
        return ((AttacksDiagh1(square) & BishopsQueens & BlackPieces) != 0);
      else
        return (0);
    case 8:
      if (AttacksFile(square) & WhiteKing)
        return ((AttacksFile(square) & RooksQueens & BlackPieces) != 0);
      else
        return (0);
    case 9:
      if (AttacksDiaga1(square) & WhiteKing)
        return ((AttacksDiaga1(square) & BishopsQueens & BlackPieces) != 0);
      else
        return (0);
    }
  } else {
/*
 ************************************************************
 *                                                          *
 *   first, determine if the piece being moved is on the    *
 *   same diagonal, rank or file as the king.               *
 *                                                          *
 ************************************************************
 */
    ray = directions[BlackKingSQ][square];
    if (!ray)
      return (0);
/*
 ************************************************************
 *                                                          *
 *   if they are on the same ray, then determine if the     *
 *   king blocks a bishop attack in one direction from this *
 *   square and a bishop or queen blocks a bishop attack    *
 *   on the same diagonal in the opposite direction.        *
 *                                                          *
 ************************************************************
 */
    switch (abs(ray)) {
    case 1:
      if (AttacksRank(square) & BlackKing)
        return ((AttacksRank(square) & RooksQueens & WhitePieces) != 0);
      else
        return (0);
    case 7:
      if (AttacksDiagh1(square) & BlackKing)
        return ((AttacksDiagh1(square) & BishopsQueens & WhitePieces) != 0);
      else
        return (0);
    case 8:
      if (AttacksFile(square) & BlackKing)
        return ((AttacksFile(square) & RooksQueens & WhitePieces) != 0);
      else
        return (0);
    case 9:
      if (AttacksDiaga1(square) & BlackKing)
        return ((AttacksDiaga1(square) & BishopsQueens & WhitePieces) != 0);
      else
        return (0);
    }
  }
  return (0);
}

void Print(int vb, char *fmt, ...)
{
  va_list ap;

  va_start(ap, fmt);
  if (vb & shared->display_options)
    vprintf(fmt, ap);
  fflush(stdout);
  if (shared->time_limit > 99 || shared->tc_time_remaining > 6000 || vb == 4095) {
    va_start(ap, fmt);
    if (log_file)
      vfprintf(log_file, fmt, ap);
    if (log_file)
      fflush(log_file);
  }
  va_end(ap);
}

char *PrintKM(size_t val, int realK)
{
  static char buf[32];

  if (realK) {
    if (val >= 1 << 20 && !(val & ((1 << 20) - 1)))
      sprintf(buf, "%4dM", (int) (val / (1 << 20)));
    else if (val >= 1 << 10)
      sprintf(buf, "%4dK", (int) (val / (1 << 10)));
    else
      sprintf(buf, "%5d", (int) val);
    return (buf);
  } else {
    if (val >= 1000000 && !(val % 1000000))
      sprintf(buf, "%4dM", (int) (val / 1000000));
    else if (val >= 1000)
      sprintf(buf, "%4dK", (int) (val / 1000));
    else
      sprintf(buf, "%5d", (int) val);
    return (buf);
  }
}

/*
 A 32 bit random number generator. An implementation in C of the algorithm
 given by Knuth, the art of computer programming, vol. 2, pp. 26-27. We use
 e=32, so we have to evaluate y(n) = y(n - 24) + y(n - 55) mod 2^32, which
 is implicitly done by unsigned arithmetic.
 */

unsigned int Random32(void)
{
/*
 random numbers from Mathematica 2.0.
 SeedRandom = 1;
 Table[Random[Integer, {0, 2^32 - 1}]
 */
  static const unsigned long x[55] = {
    1410651636UL, 3012776752UL, 3497475623UL, 2892145026UL, 1571949714UL,
    3253082284UL, 3489895018UL, 387949491UL, 2597396737UL, 1981903553UL,
    3160251843UL, 129444464UL, 1851443344UL, 4156445905UL, 224604922UL,
    1455067070UL, 3953493484UL, 1460937157UL, 2528362617UL, 317430674UL,
    3229354360UL, 117491133UL, 832845075UL, 1961600170UL, 1321557429UL,
    747750121UL, 545747446UL, 810476036UL, 503334515UL, 4088144633UL,
    2824216555UL, 3738252341UL, 3493754131UL, 3672533954UL, 29494241UL,
    1180928407UL, 4213624418UL, 33062851UL, 3221315737UL, 1145213552UL,
    2957984897UL, 4078668503UL, 2262661702UL, 65478801UL, 2527208841UL,
    1960622036UL, 315685891UL, 1196037864UL, 804614524UL, 1421733266UL,
    2017105031UL, 3882325900UL, 810735053UL, 384606609UL, 2393861397UL
  };
  static int init = 1;
  static unsigned long y[55];
  static int j, k;
  unsigned long ul;

  if (init) {
    int i;

    init = 0;
    for (i = 0; i < 55; i++)
      y[i] = x[i];
    j = 24 - 1;
    k = 55 - 1;
  }

  ul = (y[k] += y[j]);
  if (--j < 0)
    j = 55 - 1;
  if (--k < 0)
    k = 55 - 1;
  return ((unsigned int) ul);
}

BITBOARD Random64(void)
{
  BITBOARD result;
  unsigned int r1, r2;

  r1 = Random32();
  r2 = Random32();
  result = r1 | (BITBOARD) r2 << 32;
  return (result);
}

/* last modified 05/06/97 */
/*
 *******************************************************************************
 *                                                                             *
 *   Read() copies data from the command_buffer into a local buffer, and then  *
 *   uses ReadParse to break this command up into tokens for processing.       *
 *                                                                             *
 *******************************************************************************
 */
int Read(int wait, char *buffer)
{
  char *eol, *ret, readdata;

  *buffer = 0;
#if defined(DGT)
  if (DGT_active && DGTCheckInput())
    DGTRead();
#endif
/*
 case 1:  we have a complete command line, with terminating
 N/L character in the buffer.  we can simply extract it from
 the I/O buffer, parse it and return.
 */
  if (strchr(cmd_buffer, '\n'));
/*
 case 2:  the buffer does not contain a complete line.  If we
 were asked to not wait for a complete command, then we first
 see if I/O is possible, and if so, read in what is available.
 If that includes a N/L, then we are ready to parse and return.
 If not, we return indicating no input available just yet.
 */
  else if (!wait) {
    if (CheckInput()) {
      readdata = ReadInput();
      if (!strchr(cmd_buffer, '\n'))
        return (0);
      if (!readdata)
        return (-1);
    } else
      return (0);
  }
/*
 case 3:  the buffer does not contain a complete line, but we
 were asked to wait until a complete command is entered.  So we
 hang by doing a ReadInput() and continue doing so until we get
 a N/L character in the buffer.  Then we parse and return.
 */
  else
    while (!strchr(cmd_buffer, '\n')) {
#if defined(DGT)
      if (DGT_active) {
        fd_set readfds;
        struct timeval tv;

        FD_ZERO(&readfds);
        FD_SET(from_dgt, &readfds);
        FD_SET(fileno(stdin), &readfds);
        tv.tv_sec = 999999;
        tv.tv_usec = 0;
        (void) select(32, &readfds, 0, 0, &tv);
        if (FD_ISSET(from_dgt, &readfds))
          DGTRead();
        if (FD_ISSET(fileno(stdin), &readfds))
          readdata = ReadInput();
      } else {
#endif
        readdata = ReadInput();
        if (!readdata)
          return (-1);
#if defined(DGT)
      }
#endif
    }

  eol = strchr(cmd_buffer, '\n');
  *eol = 0;
  ret = strchr(cmd_buffer, '\r');
  if (ret)
    *ret = ' ';
  strcpy(buffer, cmd_buffer);
  memmove(cmd_buffer, eol + 1, strlen(eol + 1) + 1);
  return (1);
}

/* last modified 04/23/97 */
/*
 *******************************************************************************
 *                                                                             *
 *   ReadClear() clears the input buffer when input_stream is being switched to*
 *   a file, since we have info buffered up from a different input stream.     *
 *                                                                             *
 *******************************************************************************
 */
void ReadClear()
{
  cmd_buffer[0] = 0;
}

/* last modified 05/06/97 */
/*
 *******************************************************************************
 *                                                                             *
 *   ReadParse() takes one complete command-line, and breaks it up into tokens.*
 *   common delimiters are used, such as " ", ",", "/" and ";", any of which   *
 *   delimit fields.                                                           *
 *                                                                             *
 *******************************************************************************
 */
int ReadParse(char *buffer, char *args[], char *delims)
{
  char *next, tbuffer[512];
  int nargs;

  strcpy(tbuffer, buffer);
  for (nargs = 0; nargs < 255; nargs++)
    *(args[nargs]) = 0;
  next = strtok(tbuffer, delims);
  if (!next)
    return (0);
  strcpy(args[0], next);
  for (nargs = 1; nargs < 255; nargs++) {
    next = strtok(0, delims);
    if (!next)
      break;
    strcpy(args[nargs], next);
  }
  return (nargs);
}

/* last modified 04/23/97 */
/*
 *******************************************************************************
 *                                                                             *
 *   ReadInput() reads data from the input_stream, and buffers this into the   *
 *   command_buffer for later processing.                                      *
 *                                                                             *
 *******************************************************************************
 */
int ReadInput(void)
{
  char buffer[512], *end;
  int bytes;

  do
    bytes = read(fileno(input_stream), buffer, 512);
  while (bytes < 0 && errno == EINTR);
  if (bytes == 0) {
    if (input_stream != stdin)
      fclose(input_stream);
    input_stream = stdin;
    return (0);
  } else if (bytes < 0) {
    Print(4095, "ERROR!  input I/O stream is unreadable, exiting.\n");
    CraftyExit(1);
  }
  end = cmd_buffer + strlen(cmd_buffer);
  memcpy(end, buffer, bytes);
  *(end + bytes) = 0;
  return (1);
}

/* last modified 10/11/96 */
/*
 *******************************************************************************
 *                                                                             *
 *   ReadChessMove() is used to read a move from an input file.  the main issue*
 *   is to skip over "trash" like move numbers, times, comments, and so forth, *
 *   and find the next actual move.                                            *
 *                                                                             *
 *******************************************************************************
 */
int ReadChessMove(TREE * RESTRICT tree, FILE * input, int wtm, int one_move)
{

  static char text[128];
  char *tmove;
  int move = 0, status;

  while (move == 0) {
    status = fscanf(input, "%s", text);
    if (status <= 0)
      return (-1);
    if (strcmp(text, "0-0") && strcmp(text, "0-0-0"))
      tmove = text + strspn(text, "0123456789.");
    else
      tmove = text;
    if (((tmove[0] >= 'a' && tmove[0] <= 'z') || (tmove[0] >= 'A' &&
                tmove[0] <= 'Z')) || !strcmp(tmove, "0-0") ||
        !strcmp(tmove, "0-0-0")) {
      if (!strcmp(tmove, "exit"))
        return (-1);
      move = InputMove(tree, tmove, 0, wtm, 1, 0);
    }
    if (one_move)
      break;
  }
  return (move);
}

/* last modified 05/13/97 */
/*
 *******************************************************************************
 *                                                                             *
 *   ReadNextMove() is used to take a text chess move from a file, and see if  *
 *   if is legal, skipping a sometimes embedded move number (1.e4 for example) *
 *   to make PGN import easier.                                                *
 *                                                                             *
 *******************************************************************************
 */
int ReadNextMove(TREE * RESTRICT tree, char *text, int ply, int wtm)
{

  char *tmove;
  int move = 0;

  if (strcmp(text, "0-0") && strcmp(text, "0-0-0"))
    tmove = text + strspn(text, "0123456789./-");
  else
    tmove = text;
  if (((tmove[0] >= 'a' && tmove[0] <= 'z') || (tmove[0] >= 'A' &&
              tmove[0] <= 'Z')) || !strcmp(tmove, "0-0") ||
      !strcmp(tmove, "0-0-0")) {
    if (!strcmp(tmove, "exit"))
      return (-1);
    move = InputMove(tree, tmove, ply, wtm, 1, 0);
  }
  return (move);
}

/* last modified 08/07/05 */
/*
 *******************************************************************************
 *                                                                             *
 *   this routine reads a move from a PGN file to build an opening book or for *
 *   annotating.  It returns a 1 if a header is read, it returns a 0 if a move *
 *   is read, and returns a -1 on end of file.  It counts lines and this       *
 *   counter can be accessed by calling this function with a non-zero second   *
 *   formal parameter.                                                         *
 *                                                                             *
 *******************************************************************************
 */
int ReadPGN(FILE * input, int option)
{
  static int data = 0, lines_read = 0;
  static char input_buffer[512];
  char temp[512], *eof, analysis_move[64];
  int braces = 0, parens = 0, brackets = 0, analysis = 0, last_good_line;

/*
 ************************************************************
 *                                                          *
 *  if the line counter is being requested, return it with  *
 *  no other changes being made.  if "purge" is true, clear *
 *  the current input buffer.                               *
 *                                                          *
 ************************************************************
 */
  pgn_suggested_percent = 0;
  if (!input) {
    lines_read = 0;
    data = 0;
    return (0);
  }
  if (option == -1)
    data = 0;
  if (option == -2)
    return (lines_read);
/*
 ************************************************************
 *                                                          *
 *  if we don't have any data in the buffer, the first step *
 *  is to read the next line.                               *
 *                                                          *
 ************************************************************
 */
  while (1) {
    if (!data) {
      eof = fgets(input_buffer, 512, input);
      if (!eof)
        return (-1);
      if (strchr(input_buffer, '\n'))
        *strchr(input_buffer, '\n') = 0;
      if (strchr(input_buffer, '\r'))
        *strchr(input_buffer, '\r') = ' ';
      lines_read++;
      buffer[0] = 0;
      sscanf(input_buffer, "%s", buffer);
      if (buffer[0] == '[')
        do {
          char *bracket1, *bracket2, value[128];

          strcpy(buffer, input_buffer);
          bracket1 = strchr(input_buffer, '\"');
          if (bracket1 == 0)
            return (1);
          bracket2 = strchr(bracket1 + 1, '\"');
          if (bracket2 == 0)
            return (1);
          *bracket1 = 0;
          *bracket2 = 0;
          strcpy(value, bracket1 + 1);
          if (strstr(input_buffer, "Event"))
            strcpy(pgn_event, value);
          else if (strstr(input_buffer, "Site"))
            strcpy(pgn_site, value);
          else if (strstr(input_buffer, "Round"))
            strcpy(pgn_round, value);
          else if (strstr(input_buffer, "Date"))
            strcpy(pgn_date, value);
          else if (strstr(input_buffer, "WhiteElo"))
            strcpy(pgn_white_elo, value);
          else if (strstr(input_buffer, "White"))
            strcpy(pgn_white, value);
          else if (strstr(input_buffer, "BlackElo"))
            strcpy(pgn_black_elo, value);
          else if (strstr(input_buffer, "Black"))
            strcpy(pgn_black, value);
          else if (strstr(input_buffer, "Result"))
            strcpy(pgn_result, value);
          else if (strstr(input_buffer, "FEN")) {
            sprintf(buffer, "setboard %s", value);
            (void) Option(shared->local[0]);
            continue;
          }
          return (1);
        } while (0);
      data = 1;
    }
/*
 ************************************************************
 *                                                          *
 *  if we already have data in the buffer, it is just a     *
 *  matter of extracting the next move and returning it to  *
 *  the caller.  if the buffer is empty, another line has   *
 *  to be read in.                                          *
 *                                                          *
 ************************************************************
 */
    else {
      buffer[0] = 0;
      sscanf(input_buffer, "%s", buffer);
      if (strlen(buffer) == 0) {
        data = 0;
        continue;
      } else {
        char *skip;

        strcpy(temp, input_buffer);
        skip = strstr(input_buffer, buffer) + strlen(buffer);
        if (skip)
          strcpy(input_buffer, skip);
      }
/*
 ************************************************************
 *                                                          *
 *  this skips over nested { or ( characters and finds the  *
 *  'mate', before returning any more moves.  it also stops *
 *  if a PGN header is encountered, probably due to an      *
 *  incorrectly bracketed analysis variation.               *
 *                                                          *
 ************************************************************
 */
      last_good_line = lines_read;
      analysis_move[0] = 0;
      if (strchr(buffer, '{') || strchr(buffer, '('))
        while (1) {
          char *skip, *ch;

          analysis = 1;
          while ((ch = strpbrk(buffer, "(){}[]"))) {
            if (*ch == '(') {
              *strchr(buffer, '(') = ' ';
              if (!braces)
                parens++;
            }
            if (*ch == ')') {
              *strchr(buffer, ')') = ' ';
              if (!braces)
                parens--;
            }
            if (*ch == '{') {
              *strchr(buffer, '{') = ' ';
              braces++;
            }
            if (*ch == '}') {
              *strchr(buffer, '}') = ' ';
              braces--;
            }
            if (*ch == '[') {
              *strchr(buffer, '[') = ' ';
              if (!braces)
                brackets++;
            }
            if (*ch == ']') {
              *strchr(buffer, ']') = ' ';
              if (!braces)
                brackets--;
            }
          }
          if (analysis && analysis_move[0] == 0) {
            if (strspn(buffer, " ") != strlen(buffer)) {
              char *tmove = analysis_move;

              sscanf(buffer, "%64s", analysis_move);
              strcpy(buffer, analysis_move);
              if (strcmp(buffer, "0-0") && strcmp(buffer, "0-0-0"))
                tmove = buffer + strspn(buffer, "0123456789.");
              else
                tmove = buffer;
              if ((tmove[0] >= 'a' && tmove[0] <= 'z') || (tmove[0] >= 'A' &&
                      tmove[0] <= 'Z') || !strcmp(tmove, "0-0")
                  || !strcmp(tmove, "0-0-0"))
                strcpy(analysis_move, buffer);
              else
                analysis_move[0] = 0;
            }
          }
          if (parens == 0 && braces == 0 && brackets == 0)
            break;
          buffer[0] = 0;
          sscanf(input_buffer, "%s", buffer);
          if (strlen(buffer) == 0) {
            eof = fgets(input_buffer, 512, input);
            if (!eof) {
              parens = 0;
              braces = 0;
              brackets = 0;
              return (-1);
            }
            if (strchr(input_buffer, '\n'))
              *strchr(input_buffer, '\n') = 0;
            if (strchr(input_buffer, '\r'))
              *strchr(input_buffer, '\r') = ' ';
            lines_read++;
            if (lines_read - last_good_line >= 100) {
              parens = 0;
              braces = 0;
              brackets = 0;
              Print(4095,
                  "ERROR.  comment spans over 100 lines, starting at line %d\n",
                  last_good_line);
              break;
            }
          }
          strcpy(temp, input_buffer);
          skip = strstr(input_buffer, buffer) + strlen(buffer);
          strcpy(input_buffer, skip);
      } else {
        int skip;

        if ((skip = strspn(buffer, "0123456789."))) {
          char temp[512];

          strcpy(temp, buffer + skip);
          strcpy(buffer, temp);
        }
        if (isalpha(buffer[0]) || strchr(buffer, '-')) {
          char *first, *last, *percent;

          first = input_buffer + strspn(input_buffer, " ");
          if (first == 0 || *first != '{')
            return (0);
          last = strchr(input_buffer, '}');
          if (last == 0)
            return (0);
          percent = strstr(first, "play");
          if (percent == 0)
            return (0);
          pgn_suggested_percent = atoi(percent + 4 + strspn(percent + 4, " "));
          return (0);
        }
      }
      if (analysis_move[0] && option == 1) {
        strcpy(buffer, analysis_move);
        return (2);
      }
    }
  }
}

/* last modified 08/07/05 */
/*
 *******************************************************************************
 *                                                                             *
 *   RestoreGame() resets the position to the beginning of the game, and then  *
 *   reads in the game.nnn history file to set the position up so that the game*
 *   position matches the position at the end of the history file.             *
 *                                                                             *
 *******************************************************************************
 */
void RestoreGame(void)
{
  int i, move;
  char cmd[16];

  wtm = 1;
  InitializeChessBoard(&shared->local[0]->position[0]);
  for (i = 0; i < 500; i++) {
    fseek(history_file, i * 10, SEEK_SET);
    strcpy(cmd, "");
    fscanf(history_file, "%s", cmd);
    if (strcmp(cmd, "pass")) {
      move = InputMove(shared->local[0], cmd, 0, wtm, 1, 0);
      if (move)
        MakeMoveRoot(shared->local[0], move, wtm);
      else
        break;
    }
    wtm = Flip(wtm);
  }
}
char *Reverse(void)
{
#if defined(NT_i386)
  HANDLE std_console;

  std_console = GetStdHandle(STD_OUTPUT_HANDLE);
#endif

  if (ansi) {
#if defined(UNIX) || defined(AMIGA)
    return ("\033[7m");
#elif defined(NT_i386)
    SetConsoleTextAttribute(std_console,
        BACKGROUND_RED | BACKGROUND_GREEN | BACKGROUND_BLUE |
        BACKGROUND_INTENSITY);
    return ("");
#else
    return ("\033[7;47;33m");
#endif
  }
  return ("");
}

/*
 *******************************************************************************
 *                                                                             *
 *   CopyFromSMP() is used to copy data from a child thread to a parent thread.*
 *   this only copies the appropriate parts of the TREE structure to avoid     *
 *   burning memory bandwidth by copying everything.                           *
 *                                                                             *
 *******************************************************************************
 */
void CopyFromSMP(TREE * RESTRICT p, TREE * RESTRICT c, int value)
{
  int i;

  if (c->nodes_searched && !c->stop && value > p->search_value) {
    p->pv[p->ply] = c->pv[p->ply];
    p->search_value = value;
    for (i = 1; i < MAXPLY; i++)
      p->killers[i] = c->killers[i];
  }
  p->nodes_searched += c->nodes_searched;
  p->fail_high += c->fail_high;
  p->fail_high_first += c->fail_high_first;
  p->evaluations += c->evaluations;
  p->transposition_probes += c->transposition_probes;
  p->transposition_hits += c->transposition_hits;
  p->transposition_good_hits += c->transposition_good_hits;
  p->transposition_uppers += c->transposition_uppers;
  p->transposition_lowers += c->transposition_lowers;
  p->egtb_probes += c->egtb_probes;
  p->egtb_probes_successful += c->egtb_probes_successful;
  p->check_extensions_done += c->check_extensions_done;
  p->one_reply_extensions_done += c->one_reply_extensions_done;
  p->mate_extensions_done += c->mate_extensions_done;
  p->passed_pawn_extensions_done += c->passed_pawn_extensions_done;
  p->reductions_attempted += c->reductions_attempted;
  p->reductions_done += c->reductions_done;
  strcpy(c->root_move_text, p->root_move_text);
  c->used = 0;
}

/*
 *******************************************************************************
 *                                                                             *
 *   CopyToSMP() is used to copy data from a parent thread to a particular     *
 *   child thread.  this only copies the appropriate parts of the TREE         *
 *   structure to avoid burning memory bandwidth by copying everything.        *
 *                                                                             *
 *******************************************************************************
 */
TREE *CopyToSMP(TREE * RESTRICT p, int thread)
{
  int i, j, max;
  TREE *c;
  static int warnings = 0;
  int first = thread * MAX_BLOCKS_PER_CPU + 1;
  int last = first + MAX_BLOCKS_PER_CPU;
  int maxb = shared->max_threads * MAX_BLOCKS_PER_CPU + 1;

  for (i = first; i < last && shared->local[i]->used; i++);
  if (i >= last) {
    if (++warnings < 6)
      Print(128, "WARNING.  optimal SMP block cannot be allocated, thread %d\n",
          thread);
    for (i = 1; i < maxb && shared->local[i]->used; i++);
    if (i >= maxb) {
      if (warnings < 6)
        Print(128, "ERROR.  no SMP block can be allocated\n");
      return (0);
    }
  }
  max = 0;
  for (j = 1; j < maxb; j++)
    if (shared->local[j]->used)
      max++;
  shared->max_split_blocks = Max(shared->max_split_blocks, max);
  c = shared->local[i];
  c->used = 1;
  c->stop = 0;
  for (i = 0; i < shared->max_threads; i++)
    c->siblings[i] = 0;
  c->pos = p->pos;
  c->pv[p->ply - 1] = p->pv[p->ply - 1];
  c->pv[p->ply] = p->pv[p->ply];
  c->next_status[p->ply] = p->next_status[p->ply];
  c->save_hash_key[p->ply] = p->save_hash_key[p->ply];
  c->save_pawn_hash_key[p->ply] = p->save_pawn_hash_key[p->ply];
  c->rep_game = p->rep_game;
  for (i = 0; i < 256; i++)
    c->rep_list[i] = p->rep_list[i];
  c->last[p->ply] = c->move_list;
  c->hash_move[p->ply] = p->hash_move[p->ply];
  for (i = 1; i <= p->ply + 1; i++) {
    c->position[i] = p->position[i];
    c->current_move[i] = p->current_move[i];
    c->in_check[i] = p->in_check[i];
    c->phase[i] = p->phase[i];
  }
  for (i = 1; i < MAXPLY; i++)
    c->killers[i] = p->killers[i];
  c->nodes_searched = 0;
  c->fail_high = 0;
  c->fail_high_first = 0;
  c->evaluations = 0;
  c->transposition_probes = 0;
  c->transposition_hits = 0;
  c->transposition_good_hits = 0;
  c->transposition_uppers = 0;
  c->transposition_lowers = 0;
  c->transposition_exacts = 0;
  c->egtb_probes = 0;
  c->egtb_probes_successful = 0;
  c->check_extensions_done = 0;
  c->mate_extensions_done = 0;
  c->one_reply_extensions_done = 0;
  c->passed_pawn_extensions_done = 0;
  c->reductions_attempted = 0;
  c->reductions_done = 0;
  c->alpha = p->alpha;
  c->beta = p->beta;
  c->value = p->value;
  c->wtm = p->wtm;
  c->ply = p->ply;
  c->depth = p->depth;
  c->mate_threat = p->mate_threat;
  c->search_value = 0;
  strcpy(c->root_move_text, p->root_move_text);
  strcpy(c->remaining_moves_text, p->remaining_moves_text);
  return (c);
}

/*
 *******************************************************************************
 *                                                                             *
 *   Kibitz() is used to whisper/kibitz information to a chess server.  it has *
 *   to handle the xboard whisper/kibitz interface as well as the custom ics   *
 *   interface for Crafty.  there are two main issues:  (a) presenting only the*
 *   information specified by the current value of whisper or kibitz variables;*
 *   (a) if using the custom ICS interface, preceeding the commands with a "*" *
 *   so the interface will direct them to the server rather than the operator. *
 *                                                                             *
 *******************************************************************************
 */
void Kibitz(int level, int wtm, int depth, int time, int value, BITBOARD nodes,
    int tb_hits, char *pv)
{
  int nps;

  nps = (int) ((time) ? 100 * nodes / (BITBOARD) time : nodes);
  if (!shared->puzzling) {
    char prefix[128];

    if (strlen(channel_title) && channel)
      sprintf(prefix, "tell %d (%s) ", channel, channel_title);
    else if (channel)
      sprintf(prefix, "tell %d", channel);
    else if (!(kibitz & 16))
      sprintf(prefix, "kibitz");
    else
      sprintf(prefix, "whisper");
    switch (level) {
    case 1:
      if ((kibitz & 15) >= 1) {
        if (value > 0) {
          if (ics)
            printf("*");
          printf("%s mate in %d moves.\n\n", prefix, value);
        }
        if (value < 0) {
          if (ics)
            printf("*");
          printf("%s mated in %d moves.\n\n", prefix, -value);
        }
      }
      break;
    case 2:
      if ((kibitz & 15) >= 2) {
        if (ics)
          printf("*");
        printf("%s ply=%d; eval=%s; nps=%s; time=%s; egtb=%d\n", prefix, depth,
            DisplayEvaluationKibitz(value, wtm), DisplayKM(nps),
            DisplayTimeKibitz(time), tb_hits);
      }
    case 3:
      if ((kibitz & 15) >= 3 && (nodes > 5000 || level == 2)) {
        if (ics)
          printf("*");
        printf("%s %s\n", prefix, pv);
      }
      break;
    case 4:
      if ((kibitz & 15) >= 4) {
        if (ics)
          printf("*");
        printf("%s %s\n", prefix, pv);
      }
      break;
    case 5:
      if ((kibitz & 15) >= 5 && nodes > 5000) {
        if (ics)
          printf("*");
        printf("%s d%d-> %s/s %s %s %s ", prefix, depth, DisplayKM(nps),
            DisplayTimeKibitz(time), DisplayEvaluationKibitz(value, wtm), pv);
        if (tb_hits)
          printf("egtb=%d", tb_hits);
        printf("\n");
      }
      break;
    case 6:
      if ((kibitz & 15) >= 6 && nodes > 5000) {
        if (ics)
          printf("*");
        if (wtm)
          printf("%s d%d+ %s/s %s >(%s) %s <re-searching>\n", prefix, depth,
              DisplayKM(nps), DisplayTimeKibitz(time),
              DisplayEvaluationKibitz(value, wtm), pv);
        else
          printf("%s d%d+ %s/s %s <(%s) %s <re-searching>\n", prefix, depth,
              DisplayKM(nps), DisplayTimeKibitz(time),
              DisplayEvaluationKibitz(value, wtm), pv);
      }
      break;
    }
    value = (wtm) ? value : -value;
    if (post && level > 1) {
      if (strstr(pv, "book"))
        printf("	%2d  %5d %7d " BMF6 " %s\n", depth, value, time, nodes,
            pv + 10);
      else
        printf("	%2d  %5d %7d " BMF6 " %s\n", depth, value, time, nodes,
            pv);
    }
    fflush(stdout);
  }
}

/* last modified 07/07/98 */
/*
 *******************************************************************************
 *                                                                             *
 *   StrCnt() counts the number of times a character occurs in a string.       *
 *                                                                             *
 *******************************************************************************
 */
int StrCnt(char *string, char testchar)
{
  int count = 0, i;

  for (i = 0; i < strlen(string); i++)
    if (string[i] == testchar)
      count++;
  return (count);
}

/* last modified 03/22/01 */
/*
 *******************************************************************************
 *                                                                             *
 *   ValidMove() is used to verify that a move is playable.  it is mainly      *
 *   used to confirm that a move retrieved from the transposition/refutation   *
 *   and/or killer move is valid in the current position by checking the move  *
 *   against the current chess board, castling status, en passant status, etc. *
 *                                                                             *
 *******************************************************************************
 */
int ValidMove(TREE * RESTRICT tree, int ply, int wtm, int move)
{
/*
 ************************************************************
 *                                                          *
 *   make sure that the piece on <from> is the right color. *
 *                                                          *
 ************************************************************
 */
  if (wtm) {
    if (PcOnSq(From(move)) != Piece(move))
      return (0);
  } else {
    if (PcOnSq(From(move)) != -Piece(move))
      return (0);
  }
  switch (Piece(move)) {
/*
 ************************************************************
 *                                                          *
 *   null-moves are caught as it is possible for a killer   *
 *   move entry to be zero at certain times.                *
 *                                                          *
 ************************************************************
 */
  case none:
    return (0);
/*
 ************************************************************
 *                                                          *
 *   king moves are validated here if the king is moving    *
 *   two squares at one time (castling moves).  otherwise   *
 *   fall into the normal piece validation routine below.   *
 *   for castling moves, we need to verify that the         *
 *   castling status is correct to avoid "creating" a new   *
 *   rook or king.                                          *
 *                                                          *
 ************************************************************
 */
  case king:
    if (abs(From(move) - To(move)) == 2) {
      if (wtm) {
        if (WhiteCastle(ply) > 0) {
          if (To(move) == C1) {
            if ((!(WhiteCastle(ply) & 2)) || (Occupied & mask_white_OOO) ||
                (AttacksTo(tree, C1) & BlackPieces) ||
                (AttacksTo(tree, D1) & BlackPieces) ||
                (AttacksTo(tree, E1) & BlackPieces))
              return (0);
          } else if (To(move) == G1) {
            if ((!(WhiteCastle(ply) & 1)) || (Occupied & mask_white_OO) ||
                (AttacksTo(tree, E1) & BlackPieces) ||
                (AttacksTo(tree, F1) & BlackPieces) ||
                (AttacksTo(tree, G1) & BlackPieces))
              return (0);
          }
        } else
          return (0);
      } else {
        if (BlackCastle(ply) > 0) {
          if (To(move) == C8) {
            if ((!(BlackCastle(ply) & 2)) || (Occupied & mask_black_OOO) ||
                (AttacksTo(tree, C8) & WhitePieces) ||
                (AttacksTo(tree, D8) & WhitePieces) ||
                (AttacksTo(tree, E8) & WhitePieces))
              return (0);
          }
          if (To(move) == 62) {
            if ((!(BlackCastle(ply) & 1)) || (Occupied & mask_black_OO) ||
                (AttacksTo(tree, E8) & WhitePieces) ||
                (AttacksTo(tree, F8) & WhitePieces) ||
                (AttacksTo(tree, G8) & WhitePieces))
              return (0);
          }
        } else
          return (0);
      }
      return (1);
    }
    break;
/*
 ************************************************************
 *                                                          *
 *   check for a normal pawn advance.                       *
 *                                                          *
 ************************************************************
 */
  case pawn:
    if (abs(From(move) - To(move)) == 8) {
      if (wtm) {
        if ((From(move) < To(move)) && !PcOnSq(To(move)))
          return (1);
      } else {
        if ((From(move) > To(move)) && !PcOnSq(To(move)))
          return (1);
      }
      return (0);
    } else if (abs(From(move) - To(move)) == 16) {
      if (wtm) {
        if (!PcOnSq(To(move) - 8) && !PcOnSq(To(move)))
          return (1);
      } else {
        if (!PcOnSq(To(move) + 8) && !PcOnSq(To(move)))
          return (1);
      }
      return (0);
    }
    if (!Captured(move))
      return (0);

/*
 ************************************************************
 *                                                          *
 *   check for an en passant capture which is somewhat      *
 *   unusual in that the [to] square does not contain the   *
 *   pawn being captured.  make sure that the pawn being    *
 *   captured advanced two ranks the previous move.         *
 *                                                          *
 ************************************************************
 */
    if (wtm) {
      if ((PcOnSq(To(move)) == 0) && (PcOnSq(To(move) - 8) == -pawn) &&
          (EnPassantTarget(ply) & SetMask(To(move))))
        return (1);
    } else {
      if ((PcOnSq(To(move)) == 0) && (PcOnSq(To(move) + 8) == pawn) &&
          (EnPassantTarget(ply) & SetMask(To(move))))
        return (1);
    }
/*
 ************************************************************
 *                                                          *
 *   normal moves are all checked the same way.             *
 *                                                          *
 ************************************************************
 */
  case queen:
  case rook:
  case bishop:
    if (Attack(From(move), To(move)))
      break;
    return (0);
  case knight:
    break;
  }
/*
 ************************************************************
 *                                                          *
 *   all normal moves are validated in the same manner, by  *
 *   checking the from and to squares and also the attack   *
 *   status for completeness.                               *
 *                                                          *
 ************************************************************
 */
  if (wtm) {
    if (Captured(move) == -PcOnSq(To(move)) && Captured(move) != king)
      return (1);
  } else {
    if (Captured(move) == PcOnSq(To(move)) && Captured(move) != king)
      return (1);
  }
  return (0);
}

/* last modified 07/07/98 */
/*
 *******************************************************************************
 *                                                                             *
 *   VerifyMove() tests a move to confirm it is absolutely legal. it shouldn't *
 *   be used inside the search, but can be used to check a 21-bit (compressed) *
 *   move to be sure it is safe to make it on the permanent game board.        *
 *                                                                             *
 *******************************************************************************
 */
int VerifyMove(TREE * RESTRICT tree, int ply, int wtm, int move)
{
  int moves[220], *mv, *mvp;

/*
 generate moves, then eliminate any that are illegal.
 */
  if (move == 0)
    return (0);
  tree->position[MAXPLY] = tree->position[ply];
  mvp = GenerateCaptures(tree, MAXPLY, wtm, moves);
  mvp = GenerateNonCaptures(tree, MAXPLY, wtm, mvp);
  for (mv = &moves[0]; mv < mvp; mv++) {
    MakeMove(tree, MAXPLY, *mv, wtm);
    if (!Check(wtm) && move == *mv) {
      UnmakeMove(tree, MAXPLY, *mv, wtm);
      return (1);
    }
    UnmakeMove(tree, MAXPLY, *mv, wtm);
  }
  return (0);
}

/*
 *******************************************************************************
 *                                                                             *
 *   Windows NUMA support                                                      *
 *                                                                             *
 *******************************************************************************
 */

#if defined(_WIN32) || defined(_WIN64)

lock_t ThreadsLock;

static BOOL(WINAPI * pGetNumaHighestNodeNumber) (PULONG);
static BOOL(WINAPI * pGetNumaNodeProcessorMask) (UCHAR, PULONGLONG);
static DWORD(WINAPI * pSetThreadIdealProcessor) (HANDLE, DWORD);

static volatile BOOL fThreadsInitialized = FALSE;
static BOOL fSystemIsNUMA = FALSE;
static ULONGLONG ullProcessorMask[256];
static ULONG ulNumaNodes;
static ULONG ulNumaNode = 0;

// Get NUMA-related information from Windows

static void WinNumaInit(void)
{
  DWORD_PTR dwMask;
  HMODULE hModule;
  ULONG ulCPU, ulNode;
  ULONGLONG ullMask;
  DWORD dwCPU;

  if (!fThreadsInitialized) {
    Lock(ThreadsLock);
    if (!fThreadsInitialized) {
      printf("\nInitializing multiple threads.\n");
      fThreadsInitialized = TRUE;
      hModule = GetModuleHandle("kernel32");
      pGetNumaHighestNodeNumber =
          (void *) GetProcAddress(hModule, "GetNumaHighestNodeNumber");
      pGetNumaNodeProcessorMask =
          (void *) GetProcAddress(hModule, "GetNumaNodeProcessorMask");
      pSetThreadIdealProcessor =
          (void *) GetProcAddress(hModule, "SetThreadIdealProcessor");
      if (pGetNumaHighestNodeNumber && pGetNumaNodeProcessorMask &&
          pGetNumaHighestNodeNumber(&ulNumaNodes) && (ulNumaNodes > 0)) {
        fSystemIsNUMA = TRUE;
        if (ulNumaNodes > 255)
          ulNumaNodes = 255;
        printf("System is NUMA. %d nodes reported by Windows\n",
            ulNumaNodes + 1);
        for (ulNode = 0; ulNode <= ulNumaNodes; ulNode++) {
          pGetNumaNodeProcessorMask((UCHAR) ulNode, &ullProcessorMask[ulNode]);
          printf("Node %d CPUs: ", ulNode);
          ullMask = ullProcessorMask[ulNode];
          if (0 == ullMask)
            fSystemIsNUMA = FALSE;
          else {
            ulCPU = 0;
            do {
              if (ullMask & 1)
                printf("%d ", ulCPU);
              ulCPU++;
              ullMask >>= 1;
            } while (ullMask);
          }
          printf("\n");
        }
// Thread 0 was already started on some CPU. To simplify things further,
// exchange ullProcessorMask[0] and ullProcessorMask[node for that CPU],
// so ullProcessorMask[0] would always be node for thread 0
        dwCPU =
            pSetThreadIdealProcessor(GetCurrentThread(), MAXIMUM_PROCESSORS);
        printf("Current ideal CPU is %u\n", dwCPU);
        pSetThreadIdealProcessor(GetCurrentThread(), dwCPU);
        if ((((DWORD) - 1) != dwCPU) && (MAXIMUM_PROCESSORS != dwCPU) &&
            !(ullProcessorMask[0] & (1u << dwCPU))) {
          for (ulNode = 1; ulNode <= ulNumaNodes; ulNode++) {
            if (ullProcessorMask[ulNode] & (1u << dwCPU)) {
              printf("Exchanging nodes 0 and %d\n", ulNode);
              ullMask = ullProcessorMask[ulNode];
              ullProcessorMask[ulNode] = ullProcessorMask[0];
              ullProcessorMask[0] = ullMask;
              break;
            }
          }
        }
      } else
        printf("System is SMP, not NUMA.\n");
    }
    Unlock(ThreadsLock);
  }
}

// Start thread. For NUMA system set it affinity.

pthread_t NumaStartThread(void *func, void *args)
{
  HANDLE hThread;
  ULONGLONG ullMask;

  WinNumaInit();
  if (fSystemIsNUMA) {
    ulNumaNode++;
    if (ulNumaNode > ulNumaNodes)
      ulNumaNode = 0;
    ullMask = ullProcessorMask[ulNumaNode];
    printf("Starting thread on node %d CPU mask %I64d\n", ulNumaNode, ullMask);
    SetThreadAffinityMask(GetCurrentThread(), (DWORD_PTR) ullMask);
    hThread = (HANDLE) _beginthreadex(0, 0, func, args, CREATE_SUSPENDED, 0);
    SetThreadAffinityMask(hThread, (DWORD_PTR) ullMask);
    ResumeThread(hThread);
    SetThreadAffinityMask(GetCurrentThread(), ullProcessorMask[0]);
  } else
    hThread = (HANDLE) _beginthreadex(0, 0, func, args, 0, 0);
  return hThread;
}

// Allocate memory for thread #N

void *WinMalloc(size_t cbBytes, int iThread)
{
  HANDLE hThread;
  DWORD_PTR dwAffinityMask;
  void *pBytes;
  ULONG ulNode;

  WinNumaInit();
  if (fSystemIsNUMA) {
    ulNode = iThread % (ulNumaNodes + 1);
    hThread = GetCurrentThread();
    dwAffinityMask = SetThreadAffinityMask(hThread, ullProcessorMask[ulNode]);
    pBytes = VirtualAlloc(NULL, cbBytes, MEM_COMMIT, PAGE_READWRITE);
    if (pBytes == NULL)
      ExitProcess(GetLastError());
    memset(pBytes, 0, cbBytes);
    SetThreadAffinityMask(hThread, dwAffinityMask);
  } else {
    pBytes = VirtualAlloc(NULL, cbBytes, MEM_COMMIT, PAGE_READWRITE);
    if (pBytes == NULL)
      ExitProcess(GetLastError());
    memset(pBytes, 0, cbBytes);
  }
  return pBytes;
}

// Allocate interleaved memory

void *WinMallocInterleaved(size_t cbBytes, int cThreads)
{
  char *pBase;
  char *pEnd;
  char *pch;
  HANDLE hThread;
  DWORD_PTR dwAffinityMask;
  ULONG ulNode;
  SYSTEM_INFO sSysInfo;
  size_t dwStep;
  int iThread;
  DWORD dwPageSize;             // the page size on this computer
  LPVOID lpvResult;

  WinNumaInit();
  if (fSystemIsNUMA && (cThreads > 1)) {
    GetSystemInfo(&sSysInfo);   // populate the system information structure
    dwPageSize = sSysInfo.dwPageSize;

// Reserve pages in the process's virtual address space.
    pBase = (char *) VirtualAlloc(NULL, cbBytes, MEM_RESERVE, PAGE_NOACCESS);
    if (pBase == NULL) {
      printf("VirtualAlloc() reserve failed\n");
      CraftyExit(0);
    }
// Now walk through memory, committing each page
    hThread = GetCurrentThread();
    dwStep = dwPageSize * cThreads;
    pEnd = pBase + cbBytes;
    for (iThread = 0; iThread < cThreads; iThread++) {
      ulNode = iThread % (ulNumaNodes + 1);
      dwAffinityMask = SetThreadAffinityMask(hThread, ullProcessorMask[ulNode]);
      for (pch = pBase + iThread * dwPageSize; pch < pEnd; pch += dwStep) {
        lpvResult = VirtualAlloc(pch,   // next page to commit
            dwPageSize, // page size, in bytes
            MEM_COMMIT, // allocate a committed page
            PAGE_READWRITE);    // read/write access
        if (lpvResult == NULL)
          ExitProcess(GetLastError());
        memset(lpvResult, 0, dwPageSize);
      }
      SetThreadAffinityMask(hThread, dwAffinityMask);
    }
  } else {
    pBase = VirtualAlloc(NULL, cbBytes, MEM_COMMIT, PAGE_READWRITE);
    if (pBase == NULL)
      ExitProcess(GetLastError());
    memset(pBase, 0, cbBytes);
  }
  return (void *) pBase;
}

// Free interleaved memory

void WinFreeInterleaved(void *pMemory, size_t cBytes)
{
  VirtualFree(pMemory, 0, MEM_RELEASE);
}
#endif

void *SharedMalloc(size_t size, int tid)
{
#if defined(UNIX)
  int shmid;
  void *shared;

  shmid = shmget(IPC_PRIVATE, size, (IPC_CREAT | 0600));
  if (shmid < 0) {
    Print(4095,
        "ERROR.  shmget() failed, unable to allocate a shared memory segment.\n");
    Print(4095,
        "        Please verify that your /proc/sys/kernel/shmmax value is\n");
    Print(4095,
        "        large enough to allow allocating the amount of memory you\n");
    Print(4095,
        "        are requesting.  \"echo 1000000000 > /proc/sys/kernel/shmmax\"\n");
    Print(4095, "        will allow a segment up to one billion bytes.\n");
    CraftyExit(1);
  }
  shared = shmat(shmid, 0, 0);
  shmctl(shmid, IPC_RMID, 0);
  return (shared);
#else
  return WinMalloc(size, tid);
#endif
}

void SharedFree(void *address)
{
#if defined(UNIX)
  shmdt(address);
#else
  VirtualFree(address, 0, MEM_RELEASE);
#endif
}

#if defined(UNIX)
void SignalInterrupt(int sigtype)
{
  signal(SIGCHLD, SignalInterrupt);
  while (1) {
    int status, r;

    r = waitpid(-1, &status, WNOHANG);
    if (r <= 0)
      return;
  }
}
#endif
