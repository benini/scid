#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <signal.h>
#include <string.h>
#include <sys/types.h>
#include <sys/time.h>
#include "chess.h"
#include "data.h"

/* last modified 11/19/98 */
/*
 *******************************************************************************
 *                                                                             *
 *   DGTInit() fork()'s a process to handle the DGT chessboard, and then sets  *
 *   up a pipe to communicate with it.                                         *
 *                                                                             *
 *******************************************************************************
 */
#if defined(DGT)

void DGTDelayTime(int ms)
{
  int oldt, newt;

  oldt = ReadClock();
  do {
    newt = ReadClock();
  } while (newt - ms / 10 < oldt);
}
void DGTInit(int nargs, char *args[])
{
/*
 ************************************************************
 *                                                          *
 *  fork() to spawn a new process, then execve() to execute *
 *  dgt instead of the cloned copy of crafty created by the *
 *  fork() call.                                            *
 *                                                          *
 ************************************************************
 */
  char dgt[] = { "dgt" };
  char *argv[5] = { 0, 0, 0, 0, 0 }, *env[2];
  int tp[2], fp[2];
  char device[] = { "/dev/ttyS0" }, setup[] = {
  "lw"};

  printf("Executing DGT driver.\n");
  argv[0] = dgt;
  if (nargs > 1)
    argv[1] = args[1];
  else
    argv[1] = device;
  if (nargs > 2)
    argv[2] = args[2];
  else
    argv[2] = setup;
  if (nargs > 3)
    argv[3] = args[3];
  env[0] = dgt;
  env[1] = 0;
  signal(SIGPIPE, SIG_IGN);
  pipe(tp);
  pipe(fp);
  to_dgt = tp[1];
  from_dgt = fp[0];
/*
 **************************************************
 *                                                *
 *  child process has to force stdin, stdout and  *
 *  stderr to use the two pipes we just created.  *
 *                                                *
 **************************************************
 */
  if (fork() == 0) {
    dup2(tp[0], 0);
    dup2(fp[1], 1);
    close(tp[0]);
    close(tp[1]);
    close(fp[0]);
    close(fp[1]);
    dup2(1, fileno(stderr));
    execve("dgt", argv, env);
    printf("ERROR: unable to execute dgt driver!\n");
    CraftyExit(1);
  }
  close(tp[0]);
  close(fp[1]);
  write(to_dgt, "reset\n", 6);
  DGTDelayTime(200);
  write(to_dgt, "set\n", 4);
  DGTDelayTime(300);
  write(to_dgt, "update\n", 7);
  DGT_active = 1;
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
void DGTRead()
{
  static char buffer[512];
  char temp[512];
  static int bytes = 0;
  char *last;

  bytes = read(from_dgt, buffer + bytes, 256);
  buffer[bytes] = 0;
  last = strchr(buffer, '\n');
  while (last) {
    if (last)
      *last = 0;
    bytes -= strlen(buffer) + 1;
    if (!strncmp(buffer, "move", 4)) {
      strcpy(cmd_buffer + strlen(cmd_buffer), buffer + 5);
      strcpy(cmd_buffer + strlen(cmd_buffer), "\n");
    }
    if (!strncmp(buffer, "command", 7)) {
      strcpy(cmd_buffer + strlen(cmd_buffer), buffer + 8);
      strcpy(cmd_buffer + strlen(cmd_buffer), "\n");
    } else if (!strncmp(buffer, "info", 4))
      Print(128, "DGT: %s\n", buffer + 4);
    strcpy(temp, last + 1);
    strcpy(buffer, temp);
    last = strchr(buffer, '\n');
  }
}

/* last modified 11/20/98 */
/*
 *******************************************************************************
 *                                                                             *
 *   DGTCheckInput() checks to determine if input from the DGT board arrived.  *
 *                                                                             *
 *******************************************************************************
 */
int DGTCheckInput(void)
{
  fd_set readfds;
  struct timeval tv;
  int data;

  FD_ZERO(&readfds);
  FD_SET(from_dgt, &readfds);
  tv.tv_sec = 0;
  tv.tv_usec = 0;
  (void) select(32, &readfds, 0, 0, &tv);
  data = FD_ISSET(from_dgt, &readfds);
  return (data);
}
#endif
