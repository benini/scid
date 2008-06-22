#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <termios.h>
#include <stdlib.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/time.h>

/* command codes from pc to board: */
#define DGT_SEND_RESET       0x40       /* reset */
#define DGT_SEND_CLK         0x41       /* query clock */
#define DGT_SEND_BRD         0x42       /* dump entire board */
#define DGT_SEND_UPDATE      0x43       /* update when moved */
#define DGT_SEND_UPDATE_BRD  0x44       /* update board only when moved */
#define DGT_SEND_SERIALNR    0x45       /* send serial number */
#define DGT_SEND_TRADEMARK   0x47       /* send trademark notice */
#define DGT_SEND_EE_MOVES    0x49       /* send EE prom contents */
#define DGT_SEND_VERSION     0x4d       /* send version identification */
#define DGT_SEND_UPDATE_NICE 0x4b       /* update board & time as it changes */

/* command codes from board to pc: */
#define DGT_NONE            0x00
#define DGT_BOARD_DUMP      0x06
#define DGT_BWTIME          0x0d
#define DGT_FIELD_UPDATE    0x0e
#define DGT_EE_MOVES        0x0f
#define DGT_BUSADRES        0x10
#define DGT_SERIALNR        0x11
#define DGT_TRADEMARK       0x12
#define DGT_VERSION         0x13

#define Rank(x)             ((x)>>3)
#define File(x)             ((x)&7)

typedef enum { FILEA, FILEB, FILEC, FILED, FILEE, FILEF, FILEG, FILEH } files;

typedef enum { RANK1, RANK2, RANK3, RANK4, RANK5, RANK6, RANK7, RANK8 } ranks;

typedef enum { empty = 0, pawn = 1, knight = 2, king = 3,
  bishop = 5, rook = 6, queen = 7
} PIECE;

typedef enum { A1, B1, C1, D1, E1, F1, G1, H1,
  A2, B2, C2, D2, E2, F2, G2, H2,
  A3, B3, C3, D3, E3, F3, G3, H3,
  A4, B4, C4, D4, E4, F4, G4, H4,
  A5, B5, C5, D5, E5, F5, G5, H5,
  A6, B6, C6, D6, E6, F6, G6, H6,
  A7, B7, C7, D7, E7, F7, G7, H7,
  A8, B8, C8, D8, E8, F8, G8, H8,
  BAD_SQUARE
} squares;

int delay = 500000;
int rotated = 0;
int wtm = 1;
int send_white = 1, wtime;
int send_black = 1, btime;
char w_piece_names[8] = { ' ', 'P', 'N', 'K', ' ', 'B', 'R', 'Q' };
char b_piece_names[8] = { ' ', 'p', 'n', 'k', ' ', 'b', 'r', 'q' };
int board[64], current_board[64];

/* last modified 11/19/98 */
/*
 *******************************************************************************
 *                                                                             *
 *   main() sets things up by initializing the DGT board and then goes into an *
 *   infinite loop processing input from stdin/dgt board.                      *
 *                                                                             *
 *******************************************************************************
 */
int main(int argc, char *argv[])
{
  int CheckForMove(int *, int *);
  int DGTInit(int, char **);
  void CMDRead(int);
  int DGTRead(int);
  fd_set readfds;
  struct timeval tv;
  int tty, result, i;

  tty = DGTInit(argc, argv);
  if (!tty) {
    printf("error tty could not be initialized\n");
    fflush(stdout);
    exit(0);
  }
  while (1) {
    FD_ZERO(&readfds);
    FD_SET(tty, &readfds);
    FD_SET(fileno(stdin), &readfds);
    tv.tv_sec = 0;
    tv.tv_usec = delay;
    result = select(32, &readfds, 0, 0, &tv);
    if (result == 0) {
      result = CheckForMove(board, current_board);
      if (result)
        for (i = 0; i < 64; i++)
          board[i] = current_board[i];
    } else {
      if (FD_ISSET(tty, &readfds))
        DGTRead(tty);
      if (FD_ISSET(fileno(stdin), &readfds))
        CMDRead(tty);
    }
  }
  return (0);
}

unsigned int ReadClock()
{
  struct timeval timeval;
  struct timezone timezone;

  gettimeofday(&timeval, &timezone);
  return (timeval.tv_sec * 100 + (timeval.tv_usec / 10000));
}

void DelayTime(int ms)
{
  int old, new;

  old = ReadClock();
  do {
    new = ReadClock();
  } while (new - ms / 10 < old);
}

/* last modified 11/19/98 */
/*
 *******************************************************************************
 *                                                                             *
 *   DGTInit() sets up the local data for the DGT electronic chessboard and    *
 *   initializes the communication port connected to it.                       *
 *                                                                             *
 *******************************************************************************
 */
int DGTInit(int argc, char *argv[])
{
  int DGTSetPort(char *);
  int tty;

  tty = DGTSetPort(argv[1]);
  if (!tty)
    return (0);
  if (argv[2][1] == 'a') {
    send_white = 1;
    send_black = 1;
  } else if (argv[2][1] == 'w') {
    send_white = 1;
    send_black = 0;
  } else if (argv[2][1] == 'b') {
    send_white = 0;
    send_black = 1;
  }
  if (argv[2][0] == 'l') {
    printf("info board initialized, clock to white's left.\n");
    rotated = 0;
  } else {
    printf("info board initialized, clock to white's right.\n");
    rotated = 1;
  }
  if (send_white && send_black)
    printf("info board in analysis mode\n");
  else if (send_white)
    printf("info board sending white moves.\n");
  else if (send_black)
    printf("info board sending black moves.\n");
  if (argc > 3) {
    delay = atoi(argv[3]);
    printf("info delay set to %d microseconds\n", delay);
  }
  fflush(stdout);
  return (tty);
}

/* last modified 11/19/98 */
/*
 *******************************************************************************
 *                                                                             *
 *   CMDRead() reads data from stdin (connected to Crafty) and handles the     *
 *   various requests that Crafty sends.                                       *
 *                                                                             *
 *******************************************************************************
 */
void CMDRead(int tty)
{
  char *nl, buffer[128], *cmd, command;
  int bytes;

  bytes = read(fileno(stdin), buffer, 128);
  buffer[bytes] = 0;
  printf("buffer=%s\n", buffer);
  buffer[bytes] = 0;
  cmd = buffer;
  while (cmd < buffer + bytes) {
    nl = strchr(cmd, '\n');
    if (nl)
      *nl = 0;
    else
      nl = buffer + 999;
    if (strstr(cmd, "time")) {
      if (send_white) {
        printf("command time %d\n", btime * 100);
        printf("command otim %d\n", wtime * 100);
      } else {
        printf("command time %d\n", wtime * 100);
        printf("command otim %d\n", btime * 100);
      }
    } else if (strstr(cmd, "trade")) {
      command = DGT_SEND_TRADEMARK;
      write(tty, &command, 1);
    } else if (strstr(cmd, "reset")) {
      command = DGT_SEND_RESET;
      write(tty, &command, 1);
    } else if (strstr(cmd, "update")) {
      command = DGT_SEND_UPDATE_NICE;
      write(tty, &command, 1);
    } else if (strstr(cmd, "set")) {
      command = DGT_SEND_BRD;
      write(tty, &command, 1);
    } else if (strstr(cmd, "exit")) {
      exit(0);
    }
    cmd = nl + 1;
  }
}

/* last modified 11/19/98 */
/*
 *******************************************************************************
 *                                                                             *
 *   DGTRead() reads data from the tty port connected to the DGT electronic    *
 *   chess board and handles all data from that device.                        *
 *                                                                             *
 *******************************************************************************
 */
int DGTRead(int tty)
{
  unsigned int cmd, len, bytes;
  int i, j, retval = 0;
  unsigned char buffer[512], buf[512];
  char *ToFEN(int *);
  int sq_nor[64] = { 56, 57, 58, 59, 60, 61, 62, 63,
    48, 49, 50, 51, 52, 53, 54, 55,
    40, 41, 42, 43, 44, 45, 46, 47,
    32, 33, 34, 35, 36, 37, 38, 39,
    24, 25, 26, 27, 28, 29, 30, 31,
    16, 17, 18, 19, 20, 21, 22, 23,
    8, 9, 10, 11, 12, 13, 14, 15,
    0, 1, 2, 3, 4, 5, 6, 7
  };
  int sq_rot[64] = { 7, 6, 5, 4, 3, 2, 1, 0,
    15, 14, 13, 12, 11, 10, 9, 8,
    23, 22, 21, 20, 19, 18, 17, 16,
    31, 30, 29, 28, 27, 26, 25, 24,
    39, 38, 37, 36, 35, 34, 33, 32,
    47, 46, 45, 44, 43, 42, 41, 40,
    55, 54, 53, 52, 51, 50, 49, 48,
    63, 62, 61, 60, 59, 58, 57, 56
  };
  int *sq;
  int pc[15] = { empty, pawn, rook, knight, bishop, king, queen,
    -pawn, -rook, -knight, -bishop, -king, -queen
  };
/*
 ***************************************************
 *                                                 *
 *  first, clear the buffer and then read in what- *
 *  ever data has arrived.                         *
 *                                                 *
 ***************************************************
 */
  sq = (rotated) ? sq_rot : sq_nor;
  for (i = 0; i < 512; i++)
    buffer[i] = 0;
  bytes = read(tty, buffer, 1);
  buffer[1] = 0;
  printf("read %s\n", buffer);
  if (!(buffer[0] & 128)) {
    printf("info skipping non-command character %x\n", buffer[0]);
    fflush(stdout);
    return (0);
  }
  bytes = 1;
  while (bytes < 3)
    bytes += read(tty, buffer + bytes, 512 - bytes);
  len = (buffer[1] << 7) + buffer[2];
  while (bytes < len)
    bytes += read(tty, buffer + bytes, 512 - bytes);
  for (i = 0; i < bytes;) {
    cmd = buffer[i] & 127;
    len = (buffer[i + 1] << 7) + buffer[i + 2];
    i += 3;
    if (i >= bytes) {
      printf("error incomplete DGT message read\n");
      fflush(stdout);
      break;
    }
    switch (cmd) {
/*
 ***************************************************
 *                                                 *
 *  no response (noop) from board.  ignore this as *
 *  it means nothing.                              *
 *                                                 *
 ***************************************************
 */
    case DGT_NONE:
      break;
/*
 ***************************************************
 *                                                 *
 *  this handles a complete 64 square board dump   *
 *  and sets the appropriate position on the       *
 *  engine's internal board representation.        *
 *                                                 *
 ***************************************************
 */
    case DGT_BOARD_DUMP:
      for (j = 0; j < 64; j++) {
        board[sq[j]] = pc[buffer[i + j]];
        current_board[sq[j]] = pc[buffer[i + j]];
      }
      printf("command setboard %s\n", ToFEN(board));
      fflush(stdout);
      i += len - 3;
      break;
/*
 ***************************************************
 *                                                 *
 *  this handles a time update, which pops in one  *
 *  per second.  or whenever the button on top is  *
 *  pressed after a move.                          *
 *                                                 *
 ***************************************************
 */
    case DGT_BWTIME:
      for (j = 0; j < 6; j++)
        buffer[i + j] = (buffer[i + j] >> 4) * 10 + (buffer[i + j] & 15);
      btime = (buffer[i] & 15) * 3600 + buffer[i + 1] * 60 + buffer[i + 2];
      wtime = (buffer[i + 3] & 15) * 3600 + buffer[i + 4] * 60 + buffer[i + 5];
      if (!(buffer[i + 6] & 1))
        printf("info clock stopped\n");
      if (buffer[i + 6] & 2)
        wtm = 1;
      else
        wtm = 0;
      fflush(stdout);
      i += len - 3;
      break;
/*
 ***************************************************
 *                                                 *
 *  this handles a square (field) change.  when a  *
 *  piece is picked up or set down, the square     *
 *  that was changed is sent along with the type   *
 *  of piece (or empty) that is now on it.         *
 *                                                 *
 ***************************************************
 */
    case DGT_FIELD_UPDATE:
      current_board[sq[buffer[i]]] = pc[buffer[i + 1]];
      i += len - 3;
      break;
/*
 ***************************************************
 *                                                 *
 *  this handles the EE prom dump.  currently not  *
 *  used in Crafty.                                *
 *                                                 *
 ***************************************************
 */
    case DGT_EE_MOVES:
      break;
/*
 ***************************************************
 *                                                 *
 *  this handles the serial number message from    *
 *  the board.                                     *
 *                                                 *
 ***************************************************
 */
    case DGT_SERIALNR:
      printf("info DGT nserial number: ");
      for (j = 0; j < len - 3; j++)
        printf("%c", buffer[i + j]);
      printf("\n");
      fflush(stdout);
      i += len - 3;
      break;
/*
 ***************************************************
 *                                                 *
 *  this handles the trademark message from the    *
 *  board.                                         *
 *                                                 *
 ***************************************************
 */
    case DGT_TRADEMARK:
      printf("info ");
      buf[0] = 0;
      for (j = 0; j < len - 3; j++) {
        sprintf(buf + strlen(buf), "%c", buffer[i + j]);
        if (buffer[i + j] == '\n')
          sprintf(buf + strlen(buf), "info ");
      }
      sprintf(buf + strlen(buf), "\n");
      printf("%s", buf);
      fflush(stdout);
      i += len - 3;
      break;
/*
 ***************************************************
 *                                                 *
 *  this handles the version id message from the   *
 *  board.                                         *
 *                                                 *
 ***************************************************
 */
    case DGT_VERSION:
      printf("info version:%2d.%02d\n", buffer[i], buffer[i + 1]);
      fflush(stdout);
      i += len - 3;
      break;
    default:
      printf("error unknown response from DGT sensory board (%x)\n", cmd);
      fflush(stdout);
    }
  }
  return (retval);
}

/* last modified 11/19/98 */
/*
 *******************************************************************************
 *                                                                             *
 *   DGTSetPort() sets the tty port to the proper baud rate, parity, start/stop*
 *   bits and character size.                                                  *
 *                                                                             *
 *******************************************************************************
 */
int DGTSetPort(char *ttyname)
{
  struct termios trm;
  int set, retval, tty;

  printf("info initializing device %s\n", ttyname);
  fflush(stdout);
  tty = open(ttyname, O_RDWR | O_NOCTTY);
  if (tty < 0) {
    printf("error unable to open %s\n", ttyname);
    fflush(stdout);
    return (-1);
  }
  ioctl(tty, TIOCMGET, &set);
  set |= TIOCM_DTR;     /* DTR high */
  ioctl(tty, TIOCMSET, &set);
  tcflush(tty, TCIOFLUSH);      /* flush buffers */
  retval = tcgetattr(tty, &trm);
  cfsetispeed(&trm, B9600);     /* input speed 9600 */
  cfsetospeed(&trm, B9600);     /* output speed 9600 */
  cfmakeraw(&trm);      /* raw input/output mode */
  retval = tcsetattr(tty, TCSANOW, &trm);
  if (retval < 0) {
    printf("error unable to set up I/O port\n");
    fflush(stdout);
    return (0);
  }
  return (tty);
}

/* last modified 11/19/98 */
/*
 *******************************************************************************
 *                                                                             *
 *   ToFEN() converts the current position to a FEN string for Crafty.         *
 *                                                                             *
 *******************************************************************************
 */
char *ToFEN(int board[64])
{
  char xlate[15] =
      { 'q', 'r', 'b', 0, 'k', 'n', 'p', 0, 'P', 'N', 'K', 0, 'B', 'R', 'Q' };
  char empty[9] = { ' ', '1', '2', '3', '4', '5', '6', '7', '8' };
  int rank, file, nempty;
  static char fen_string[128];

  fen_string[0] = 0;
  for (rank = RANK8; rank >= RANK1; rank--) {
    nempty = 0;
    for (file = FILEA; file <= FILEH; file++) {
      if (board[(rank << 3) + file]) {
        if (nempty) {
          sprintf(fen_string + strlen(fen_string), "%c", empty[nempty]);
          nempty = 0;
        }
        sprintf(fen_string + strlen(fen_string), "%c",
            xlate[board[(rank << 3) + file] + 7]);
      } else
        nempty++;
    }
    sprintf(fen_string + strlen(fen_string), "%c", '/');
  }
  if (wtm)
    sprintf(fen_string + strlen(fen_string), " w ");
  else
    sprintf(fen_string + strlen(fen_string), " b ");
  if (board[E1] == king) {
    if (board[H1] == rook)
      sprintf(fen_string + strlen(fen_string), "K");
    if (board[A1] == rook)
      sprintf(fen_string + strlen(fen_string), "Q");
  }
  if (board[E8] == -king) {
    if (board[H8] == -rook)
      sprintf(fen_string + strlen(fen_string), "k");
    if (board[A8] == -rook)
      sprintf(fen_string + strlen(fen_string), "q");
  }
  return (fen_string);
}

/* last modified 11/19/98 */
/*
 *******************************************************************************
 *                                                                             *
 *   CheckForMove() compares the current board to the original board position  *
 *   to determine if a move has been completed.                                *
 *                                                                             *
 *******************************************************************************
 */
int CheckForMove(int board[64], int current_board[64])
{
  int diff[64], num = 0, sq;

/*
 ***************************************************
 *                                                 *
 *  if no more than one square has changed, this   *
 *  can't be a move.                               *
 *                                                 *
 ***************************************************
 */
  if ((wtm && !send_white) || (!wtm && !send_black))
    return (1);
  for (sq = 0; sq < 64; sq++)
    if (board[sq] != current_board[sq])
      diff[num++] = sq;
  if (num <= 1)
    return (0);
/*
 ***************************************************
 *                                                 *
 *  ok, we might have a move since at least two    *
 *  squares have changed.  we have to handle four  *
 *  special cases:  (1) normal move where only     *
 *  two squares change and move is not a pawn      *
 *  promotion.  (2) pawn promotion.  (3) castle    *
 *  which requires two piece moves to complete.    *
 *  (4) enpassant pawn capture where 3 squares     *
 *  change.                                        *
 *                                                 *
 *  the first/second case is a normal move which   *
 *  include a pawn promotion (ie moves that change *
 *  exactly two squares only).                     *
 *                                                 *
 ***************************************************
 */
  if (num == 2) {
    int from, to, moving, captured;

    if (current_board[diff[0]] == 0 && current_board[diff[1]] == 0)
      return (0);
    if (board[diff[0]] && !current_board[diff[0]]) {
      from = diff[0];
      to = diff[1];
    } else {
      from = diff[1];
      to = diff[0];
    }
    moving = abs(board[from]);
    captured = abs(board[to]);
/* castle move?  */
    if (moving == king && abs(from - to) == 2)
      return (0);
/* en passant move?  */
    if (moving == pawn && abs(to - from) != 8 && abs(to - from) != 16 &&
        (board[to] == 0 || abs(from - to) == 1))
      return (0);
    if (moving == pawn) {
      if (Rank(to) != 0 && Rank(to) != 7)
        printf("move %c%c%c%c\n", 'a' + File(from), '1' + Rank(from),
            'a' + File(to), '1' + Rank(to));
      else
        printf("move %c%c%c%c=%c\n", 'a' + File(from), '1' + Rank(from),
            'a' + File(to), '1' + Rank(to), w_piece_names[current_board[to]]);
    } else
      printf("move %c%c%c%c\n", 'a' + File(from), '1' + Rank(from),
          'a' + File(to), '1' + Rank(to));
    fflush(stdout);
    return (1);
  }
/*
 ***************************************************
 *                                                 *
 *  the third case is enpassant pawn captures      *
 *  which changes three squares.                   *
 *                                                 *
 ***************************************************
 */
  if (num == 3) {
    int i, from = -1, to = -1;

    for (i = 0; i < 3; i++)
      if (current_board[diff[i]])
        to = diff[i];
    if (abs(current_board[to]) != pawn)
      return (0);
    for (i = 0; i < 3; i++)
      if (abs(to - diff[i]) == 7 || abs(to - diff[i]) == 9)
        from = diff[i];
    printf("move %c%c%c%c\n", 'a' + File(from), '1' + Rank(from),
        'a' + File(to), '1' + Rank(to));
    fflush(stdout);
    return (1);
  }
/*
 ***************************************************
 *                                                 *
 *  the third case is enpassant pawn captures      *
 *  which changes three squares.                   *
 *                                                 *
 ***************************************************
 */
  if (num == 3) {
    int i, from, to;

    for (i = 0; i < 3; i++)
      if (current_board[diff[i]])
        to = diff[i];
    if (abs(current_board[to]) != pawn)
      return (0);
    for (i = 0; i < 3; i++)
      if (abs(to - diff[i]) == 7 || abs(to - diff[i]) == 9)
        from = diff[i];
    printf("move %c%c%c%c\n", 'a' + File(from), '1' + Rank(from),
        'a' + File(to), '1' + Rank(to));
    fflush(stdout);
    return (1);
  }
/*
 ***************************************************
 *                                                 *
 *  the fourth case is castling where both a king  *
 *  and rook move.                                 *
 *                                                 *
 ***************************************************
 */
  if (num == 4) {
    int i, kfrom = -1, kto = -1, rfrom = -1, rto = -1;

    for (i = 0; i < num; i++) {
      if (abs(board[diff[i]]) == king && current_board[diff[i]] == empty)
        kfrom = diff[i];
      if (board[diff[i]] == empty && abs(current_board[diff[i]]) == king)
        kto = diff[i];
      if (abs(board[diff[i]]) == rook && current_board[diff[i]] == empty)
        rfrom = diff[i];
      if (board[diff[i]] == empty && abs(current_board[diff[i]]) == rook)
        rto = diff[i];
    }
    if (kfrom < 0 || kto < 0 || rfrom < 0 || rto < 0) {
      printf("error restore position and retry move\n");
      return (-1);
    }
    if (kto == G1 || kto == G8)
      printf("move O-O\n");
    if (kto == C1 || kto == C8)
      printf("move O-O-O\n");
    fflush(stdout);
  }
  return (1);
}
