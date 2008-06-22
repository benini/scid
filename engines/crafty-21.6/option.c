#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <signal.h>
#include "chess.h"
#include "data.h"
#if defined(UNIX) || defined(AMIGA)
#  include <unistd.h>
#  include <signal.h>
#endif
#include "epdglue.h"

/* last modified 01/03/07 */
/*
 *******************************************************************************
 *                                                                             *
 *   Option() is used to handle user input necessary to control/customize the  *
 *   program.  it performs all functions excepting chess move input which is   *
 *   handled by main().                                                        *
 *                                                                             *
 *******************************************************************************
 */
int Option(TREE * RESTRICT tree)
{

/*
 ************************************************************
 *                                                          *
 *   parse the input.  if it looks like a FEN string, don't *
 *   parse using "/" as a separator, otherwise do.          *
 *                                                          *
 ************************************************************
 */
  if (StrCnt(buffer, '/') >= 7)
    nargs = ReadParse(buffer, args, " 	;=");
  else
    nargs = ReadParse(buffer, args, " 	;=/");
  if (!nargs)
    return (1);
  if (args[0][0] == '#')
    return (1);
/*
 ************************************************************
 *                                                          *
 *   EPD implementation interface code.  EPD commands can   *
 *   not be handled if the program is actually searching in *
 *   a real game, and if Crafty is "pondering" this has to  *
 *   be stopped.                                            *
 *                                                          *
 ************************************************************
 */
#if defined(EPD)
  if (initialized) {
    if (EGCommandCheck(buffer)) {
      if (shared->thinking || shared->pondering)
        return (2);
      else {
        (void) EGCommand(buffer);
        return (1);
      }
    }
  }
#endif
/*
 ************************************************************
 *                                                          *
 *   "!" character is a 'shell escape' that passes the rest *
 *   of the command to a shell for execution.               *
 *                                                          *
 ************************************************************
 */
  if (buffer[0] == '!') {
    if (!xboard)
      system(strchr(buffer, '!') + 1);
  }
/*
 ************************************************************
 *                                                          *
 *   "." ignores "." if it happens to get to this point, if *
 *   xboard is running.                                     *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch(".", *args)) {
    if (xboard) {
      printf("stat01: 0 0 0 0 0\n");
      fflush(stdout);
      return (1);
    } else
      return (0);
  }
/*
 ************************************************************
 *                                                          *
 *   "accepted" handles the new xboard protocol version 2   *
 *   accepted command.                                      *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("accepted", *args)) {
  }
/*
 ************************************************************
 *                                                          *
 *   "adaptive" sets the new adaptive hash algorithm        *
 *    parameters.  it requires five parameters.  the first  *
 *    is an estimated NPS, the second is the minimum hash   *
 *    size, and the third is the maximum hash size.  the    *
 *    adaptive algorithm will look at the time control, and *
 *    try to adjust the hash sizes to an optimal value      *
 *    without dropping below the minimum or exceeding the   *
 *    maximum memory size given.  the min/max sizes can be  *
 *    given using the same syntax as the hash= command, ie  *
 *    xxx, xxxK or xxxM will all work. the fourth and fifth *
 *    parameters are used to limit hashp in the same way.   *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("adaptive", *args)) {
    if (nargs != 6) {
      printf("usage:  adaptive NPS min max\n");
      return (1);
    }
    if (nargs > 1) {
      float ah = atof(args[1]);

      if (strchr(args[1], 'K') || strchr(args[1], 'k'))
        ah *= 1000;
      if (strchr(args[1], 'M') || strchr(args[1], 'm'))
        ah *= 1000000;
      adaptive_hash = (int) ah;
      adaptive_hash_min = atoi(args[2]);
      if (strchr(args[2], 'K') || strchr(args[2], 'k'))
        adaptive_hash_min *= 1 << 10;
      if (strchr(args[2], 'M') || strchr(args[2], 'm'))
        adaptive_hash_min *= 1 << 20;
      adaptive_hash_max = atoi(args[3]);
      if (strchr(args[3], 'K') || strchr(args[3], 'k'))
        adaptive_hash_max *= 1 << 10;
      if (strchr(args[3], 'M') || strchr(args[3], 'm'))
        adaptive_hash_max *= 1 << 20;
      adaptive_hashp_min = atoi(args[4]);
      if (strchr(args[4], 'K') || strchr(args[4], 'k'))
        adaptive_hashp_min *= 1 << 10;
      if (strchr(args[4], 'M') || strchr(args[4], 'm'))
        adaptive_hashp_min *= 1 << 20;
      adaptive_hashp_max = atoi(args[5]);
      if (strchr(args[5], 'K') || strchr(args[5], 'k'))
        adaptive_hashp_max *= 1 << 10;
      if (strchr(args[5], 'M') || strchr(args[5], 'm'))
        adaptive_hashp_max *= 1 << 20;
    }
    Print(128, "adaptive estimated NPS =  %s\n", PrintKM(adaptive_hash, 0));
    Print(128, "adaptive minimum hsize =  %s\n", PrintKM(adaptive_hash_min, 1));
    Print(128, "adaptive maximum hsize =  %s\n", PrintKM(adaptive_hash_max, 1));
    Print(128, "adaptive minimum psize =  %s\n", PrintKM(adaptive_hashp_min,
            1));
    Print(128, "adaptive maximum psize =  %s\n", PrintKM(adaptive_hashp_max,
            1));
  }
/*
 ************************************************************
 *                                                          *
 *   "alarm" command turns audible move warning on/off.     *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("alarm", *args)) {
    if (!strcmp(args[1], "on"))
      audible_alarm = 0x07;
    else if (!strcmp(args[1], "off"))
      audible_alarm = 0x00;
    else
      printf("usage:  alarm on|off\n");
  }
/*
 ************************************************************
 *                                                          *
 *   "analyze" puts crafty in analyze mode, where it reads  *
 *   moves in and between moves, computes as though it is   *
 *   trying to find the best move to make.  when another    *
 *   move is entered, it switches sides and continues.  it  *
 *   will never make a move on its own, rather, it will     *
 *   continue to analyze until an "exit" command is given.  *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("analyze", *args)) {
    if (shared->thinking || shared->pondering)
      return (2);
    Analyze();
  }
/*
 ************************************************************
 *                                                          *
 *   "annotate" command is used to read a series of moves   *
 *   and analyze the resulting game, producing comments as  *
 *   requested by the user.  this also handles the          *
 *   annotateh (html) and annotatet (LaTex) output forms    *
 *   of the command.                                        *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("annotate", *args) || OptionMatch("annotateh", *args) ||
      OptionMatch("annotatet", *args)) {
    if (shared->thinking || shared->pondering)
      return (2);
    Annotate();
  }
/*
 ************************************************************
 *                                                          *
 *   "ansi" command turns video highlight on/off.           *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("ansi", *args)) {
    if (nargs < 2)
      printf("usage:  ansi on|off\n");
    if (!strcmp(args[1], "on"))
      ansi = 1;
    else if (!strcmp(args[1], "off"))
      ansi = 0;
  }
/*
 ************************************************************
 *                                                          *
 *   "batch" command disables asynchronous I/O so that a    *
 *   stream of commands can be put into a file and they are *
 *   not executed instantly.                                *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("batch", *args)) {
    if (!strcmp(args[1], "on"))
      batch_mode = 1;
    else if (!strcmp(args[1], "off"))
      batch_mode = 0;
    else
      printf("usage:  batch on|off\n");
  }
/*
 ************************************************************
 *                                                          *
 *  "beep" command is ignored. [xboard compatibility]       *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("beep", *args)) {
    return (xboard);
  }
/*
 ************************************************************
 *                                                          *
 *  "bench" runs internal performance benchmark             *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("bench", *args)) {
    Bench();
  }
/*
 ************************************************************
 *                                                          *
 *  "bk"  book command from xboard sends the suggested book *
 *  moves.                                                  *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("bk", *args)) {
    printf("\t%s\n\n", book_hint);
    fflush(stdout);
    return (xboard);
  }
/*
 ************************************************************
 *                                                          *
 *   "black" command sets black to move (Flip(wtm)).        *
 *                                                          *
 ************************************************************
 */
  else if (!strcmp("white", *args)) {
    if (shared->thinking || shared->pondering)
      return (2);
    ponder_move = 0;
    last_pv.pathd = 0;
    last_pv.pathl = 0;
    if (!wtm)
      Pass();
    force = 0;
  } else if (!strcmp("black", *args)) {
    if (shared->thinking || shared->pondering)
      return (2);
    ponder_move = 0;
    last_pv.pathd = 0;
    last_pv.pathl = 0;
    if (wtm)
      Pass();
    force = 0;
  }
/*
 ************************************************************
 *                                                          *
 *  "bogus" command is ignored. [xboard compatibility]      *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("bogus", *args)) {
    return (xboard);
  }
/*
 ************************************************************
 *                                                          *
 *   "bookw" command updates the book selection weights.    *
 *                                                          *
 ************************************************************
 */
  else if (!strcmp("bookw", *args)) {
    if (nargs > 1) {
      if (!strcmp("freq", args[1]))
        book_weight_freq = atof(args[2]);
      else if (!strcmp("eval", args[1]))
        book_weight_eval = atof(args[2]);
      else if (!strcmp("learn", args[1]))
        book_weight_learn = atof(args[2]);
    } else {
      Print(128, "frequency (freq)..............%4.2f\n", book_weight_freq);
      Print(128, "static evaluation (eval)......%4.2f\n", book_weight_eval);
      Print(128, "learning (learn)..............%4.2f\n", book_weight_learn);
    }
  }
/*
 ************************************************************
 *                                                          *
 *   "book" command updates/creates the opening book file.  *
 *                                                          *
 ************************************************************
 */
  else if (!strcmp("book", *args)) {
    nargs = ReadParse(buffer, args, " 	;");
    BookUp(tree, nargs, args);
  } else if (!strcmp("create", *(args + 1))) {
    nargs = ReadParse(buffer, args, " 	;");
    BookUp(tree, nargs, args);
  }
/*
 ************************************************************
 *                                                          *
 *   "channel" command behaves just like the whisper        *
 *   command, but sends the output to "channel n" instead.  *
 *   there is an optional second parameter that will be     *
 *   added to the channel tell to indicate what the tell is *
 *   connected to, such as when multiple GM games are going *
 *   on, so that the comment can be directed to a game.     *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("channel", *args)) {
    int tchannel;

    nargs = ReadParse(buffer, args, " 	;");
    if (nargs < 2) {
      printf("usage:  channel <n> [title]\n");
      return (1);
    }
    tchannel = atoi(args[1]);
    if (tchannel)
      channel = tchannel;
    if (nargs > 1) {
      char *from = args[2];
      char *to = channel_title;

      while (*from) {
        if (*from != '*')
          *to++ = *from;
        from++;
      }
      *to = 0;
    }
  }
/*
 ************************************************************
 *                                                          *
 *   "cache" is used to set the EGTB cache size.  as always *
 *   bigger is better.  the default is 1mb.  sizes can be   *
 *   specified in bytes, Kbytes or Mbytes as with the hash  *
 *   commands.                                              *
 *                                                          *
 ************************************************************
 */
#if !defined(NOEGTB)
  else if (OptionMatch("cache", *args)) {
    EGTB_cache_size = atoi(args[1]);
    if (strchr(args[1], 'K') || strchr(args[1], 'k'))
      EGTB_cache_size *= 1 << 10;
    if (strchr(args[1], 'M') || strchr(args[1], 'm'))
      EGTB_cache_size *= 1 << 20;
    if (EGTB_cache)
      free(EGTB_cache);
    EGTB_cache = malloc(EGTB_cache_size);
    if (!EGTB_cache) {
      Print(2095,
          "ERROR:  unable to malloc specified cache size, using default\n");
      EGTB_cache = malloc(EGTB_CACHE_DEFAULT);
    }
    Print(128, "EGTB cache memory = %s bytes.\n", PrintKM(EGTB_cache_size, 1));
    FTbSetCacheSize(EGTB_cache, EGTB_cache_size);
  }
#endif
/*
 ************************************************************
 *                                                          *
 *   "clock" command displays chess clock.                  *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("clock", *args)) {
    if (nargs > 1)
      shared->tc_time_remaining = ParseTime(args[1]) * 6000;
    if (shared->tc_time_remaining <= shared->tc_operator_time) {
      Print(4095, "ERROR:  remaining time less than operator time\n");
      Print(4095, "ERROR:  resetting operator time to 0:00.\n");
      Print(4095, "ERROR:  use \"operator n\" command to correct.\n");
      shared->tc_operator_time = 0;
    }

    if (nargs > 2)
      shared->tc_time_remaining_opponent = ParseTime(args[2]) * 6000;
    Print(128, "time remaining %s (Crafty)",
        DisplayHHMM(shared->tc_time_remaining));
    Print(128, "  %s (opponent).\n",
        DisplayHHMM(shared->tc_time_remaining_opponent));
    if (shared->tc_sudden_death != 1)
      Print(128, "%d moves to next time control (Crafty)\n",
          shared->tc_moves_remaining);
    else
      Print(128, "Sudden-death time control in effect\n");
  }
/*
 ************************************************************
 *                                                          *
 *   "computer" lets crafty know it is playing a computer.  *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("computer", *args)) {
    Print(128, "playing a computer!\n");
    shared->computer_opponent = 1;
    accept_draws = 1;
    resign = 5;
    resign_counter = 4;
    book_selection_width = 1;
    usage_level = 0;
    books_file = (computer_bs_file) ? computer_bs_file : normal_bs_file;
  }
/*
 ************************************************************
 *                                                          *
 *   "dgt" command activates the DGT board interface.       *
 *                                                          *
 ************************************************************
 */
#if defined(DGT)
  else if (!strcmp("dgt", *args)) {
    nargs = ReadParse(buffer, args, " 	;");
    if (to_dgt == 0)
      DGTInit(nargs, args);
    else {
      write(to_dgt, args[1], strlen(args[1]));
    }
  }
#endif
/*
 ************************************************************
 *                                                          *
 *   "display" command displays the chess board.            *
 *                                                          *
 *   "display" command sets specific display options which  *
 *   control how "chatty" the program is.  in the variable  *
 *   display_options, the following bits are set/cleared    *
 *   based on the option chosen.                            *
 *                                                          *
 *     1 -> display time for moves.                         *
 *     2 -> display variation when it changes.              *
 *     4 -> display variation at end of iteration.          *
 *     8 -> display basic search statistics.                *
 *    16 -> display extended search statistics.             *
 *    32 -> display root moves as they are searched.        *
 *    64 -> display move numbers in the PV output.          *
 *   128 -> display general informational messages.         *
 *   256 -> display ply-1 move node counts after each       *
 *          iteration.                                      *
 *   512 -> display ply-1 moves and positional evaluations  *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("display", *args)) {
    if (nargs > 1)
      do {
        if (OptionMatch("time", args[1])) {
          shared->display_options |= 1;
          Print(128, "display time for moves played in game.\n");
        } else if (OptionMatch("notime", args[1])) {
          shared->display_options &= 4095 - 1;
          Print(128, "don't display time for moves played in game.\n");
        } else if (OptionMatch("changes", args[1])) {
          shared->display_options |= 2;
          Print(128, "display PV each time it changes.\n");
        } else if (OptionMatch("nochanges", args[1])) {
          shared->display_options &= 4095 - 2;
          Print(128, "don't display PV each time it changes.\n");
        } else if (OptionMatch("variation", args[1])) {
          shared->display_options |= 4;
          Print(128, "display PV at end of each iteration.\n");
        } else if (OptionMatch("novariation", args[1])) {
          shared->display_options &= 4095 - 4;
          Print(128, "don't display PV at end of each iteration.\n");
        } else if (OptionMatch("stats", args[1])) {
          shared->display_options |= 8;
          Print(128, "display statistics at end of each search.\n");
        } else if (OptionMatch("nostats", args[1])) {
          shared->display_options &= 4095 - 8;
          Print(128, "don't.display statistics at end of each search.\n");
        } else if (OptionMatch("extstats", args[1])) {
          shared->display_options |= 16;
          Print(128, "display extended statistics at end of each search.\n");
        } else if (OptionMatch("noextstats", args[1])) {
          shared->display_options &= 4095 - 16;
          Print(128,
              "don't display extended statistics at end of each search.\n");
        } else if (OptionMatch("movenum", args[1])) {
          shared->display_options |= 64;
          Print(128, "display move numbers in variations.\n");
        } else if (OptionMatch("nomovenum", args[1])) {
          shared->display_options &= 4095 - 64;
          Print(128, "don't display move numbers in variations.\n");
        } else if (OptionMatch("moves", args[1])) {
          shared->display_options |= 32;
          Print(128, "display ply-1 moves as they are searched.\n");
        } else if (OptionMatch("nomoves", args[1])) {
          shared->display_options &= 4095 - 32;
          Print(128, "don't display ply-1 moves as they are searched.\n");
        } else if (OptionMatch("general", args[1])) {
          shared->display_options |= 128;
          Print(128, "display informational messages.\n");
        } else if (OptionMatch("nogeneral", args[1])) {
          shared->display_options &= 4095 - 128;
          Print(128, "don't display informational messages.\n");
        } else if (OptionMatch("nodes", args[1])) {
          shared->display_options |= 256;
          Print(128, "display ply-1 node counts after each iteration.\n");
        } else if (OptionMatch("nonodes", args[1])) {
          shared->display_options &= 4095 - 256;
          Print(128, "don't display ply-1 node counts after each iteration.\n");
        } else if (OptionMatch("ply1", args[1])) {
          shared->display_options |= 512;
          Print(128, "display ply-1 moves/evaluations.\n");
        } else if (OptionMatch("noply1", args[1])) {
          shared->display_options &= 4095 - 512;
          Print(128, "don't display ply-1 moves/evaluations.\n");
        } else if (OptionMatch("*", args[1])) {
          if (shared->display_options & 1)
            printf("display time for moves\n");
          if (shared->display_options & 2)
            printf("display variation when it changes.\n");
          if (shared->display_options & 4)
            printf("display variation at end of iteration.\n");
          if (shared->display_options & 8)
            printf("display basic search stats.\n");
          if (shared->display_options & 16)
            printf("display extended search stats.\n");
          if (shared->display_options & 32)
            printf("display ply-1 moves as they are searched.\n");
          if (shared->display_options & 64)
            printf("display move numbers in variations.\n");
          if (shared->display_options & 128)
            printf("display general messages.\n");
          if (shared->display_options & 256)
            printf("display ply-1 node counts every iteration.\n");
          if (shared->display_options & 512)
            printf("display ply-1 moves and evaluations.\n");
        } else
          break;
        return (1);
      } while (0);
    else
      DisplayChessBoard(stdout, display);
  }
/*
 ************************************************************
 *                                                          *
 *   "depth" command sets a specific search depth to        *
 *   control the tree search depth. [xboard compatibility]. *
 *                                                          *
 ************************************************************
 */
  else if (!strcmp("depth", *args)) {
    if (nargs < 2) {
      printf("usage:  depth <n>\n");
      return (1);
    }
    search_depth = atoi(args[1]);
    Print(128, "search depth set to %d.\n", search_depth);
  }
/*
 ************************************************************
 *                                                          *
 *   "draw" is used to offer Crafty a draw, or to control   *
 *   whether crafty will offer and/or accept draw offers.   *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("draw", *args)) {
    if (nargs == 1) {
      draw_offer_pending = 1;
      if (draw_offered) {
        Print(4095, "1/2-1/2 {Draw agreed}\n");
        strcpy(pgn_result, "1/2-1/2");
      }
    } else {
      if (!strcmp(args[1], "accept")) {
        accept_draws = 1;
        Print(128, "accept draw offers\n");
      } else if (!strcmp(args[1], "decline")) {
        accept_draws = 0;
        Print(128, "decline draw offers\n");
      } else if (!strcmp(args[1], "offer")) {
        offer_draws = 1;
        Print(128, "offer draws\n");
      } else if (!strcmp(args[1], "nooffer")) {
        offer_draws = 0;
        Print(128, "do not offer draws\n");
      } else
        Print(128, "usage: draw accept|decline|offer|nooffer\n");
    }
  }
/*
 ************************************************************
 *                                                          *
 *   "drawscore" sets the default draw score (which is      *
 *    forced to zero when the endgame is reached.)          *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("drawscore", *args)) {
    if (nargs > 2) {
      printf("usage:  drawscore <n>\n");
      return (1);
    }
    if (nargs == 2)
      abs_draw_score = atoi(args[1]);
    printf("draw score set to %7.2f pawns.\n",
        ((float) abs_draw_score) / 100.0);
  }
/*
 ************************************************************
 *                                                          *
 *  "easy" command disables thinking on opponent's time.    *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("easy", *args)) {
    if (shared->thinking || shared->pondering)
      return (2);
    ponder = 0;
    Print(128, "pondering disabled.\n");
  }
/*
 ************************************************************
 *                                                          *
 *   "echo" command displays messages from command file.    *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("echo", *args) || OptionMatch("title", *args)) {
  }
/*
 ************************************************************
 *                                                          *
 *   "edit" command modifies the board position.            *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("edit", *args) && strcmp(*args, "ed")) {
    if (shared->thinking || shared->pondering)
      return (2);
    Edit();
    shared->move_number = 1;    /* discard history */
    if (!wtm) {
      wtm = 1;
      Pass();
    }
    ponder_move = 0;
    last_pv.pathd = 0;
    last_pv.pathl = 0;
    strcpy(buffer, "savepos *");
    (void) Option(tree);
  }
/*
 ************************************************************
 *                                                          *
 *   "egtb" command enables/disables tablebases and sets    *
 *   the number of pieces available for probing.            *
 *                                                          *
 ************************************************************
 */
#if !defined(NOEGTB)
  else if (OptionMatch("egtb", *args)) {
    if (!EGTB_setup) {
      Print(128, "EGTB access enabled\n");
      Print(128, "using tbpath=%s\n", tb_path);
      EGTBlimit = IInitializeTb(tb_path);
      Print(128, "%d piece tablebase files found\n", EGTBlimit);
      if (0 != cbEGTBCompBytes)
        Print(128, "%dkb of RAM used for TB indices and decompression tables\n",
            (cbEGTBCompBytes + 1023) / 1024);
      if (EGTBlimit) {
        if (!EGTB_cache)
          EGTB_cache = malloc(EGTB_cache_size);
        if (!EGTB_cache) {
          Print(128, "ERROR  EGTB cache malloc failed\n");
          EGTB_cache = malloc(EGTB_CACHE_DEFAULT);
        } else
          FTbSetCacheSize(EGTB_cache, EGTB_cache_size);
        EGTB_setup = 1;
      }
    } else {
      if (nargs == 1)
        EGTBPV(tree, wtm);
      else if (nargs == 2)
        EGTBlimit = Min(atoi(args[1]), 5);
    }
  }
#endif
/*
 ************************************************************
 *                                                          *
 *   "end" (or "quit") command terminates the program.      *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("end", *args) || OptionMatch("quit", *args)) {
    shared->abort_search = 1;
    shared->quit = 1;
    last_search_value =
        (shared->crafty_is_white) ? last_search_value : -last_search_value;
    if (shared->moves_out_of_book)
      LearnBook(tree, wtm, last_search_value, 0, 0, 1);
    if (book_file)
      fclose(book_file);
    if (books_file)
      fclose(books_file);
    if (position_file)
      fclose(position_file);
    if (history_file)
      fclose(history_file);
    if (log_file)
      fclose(log_file);
#if defined(DGT)
    if (DGT_active)
      write(to_dgt, "exit\n", 5);
#endif
    CraftyExit(0);
  }
/*
 ************************************************************
 *                                                          *
 *  "eot" command is a no-operation that is used to keep    *
 *  Crafty and the ICS interface in sync.                   *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("eot", *args)) {
  }
/*
 ************************************************************
 *                                                          *
 *   "evaluation" command is used to adjust the eval terms  *
 *   to modify the way Crafty behaves.                      *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("evaluation", *args)) {
    int i, j, k, param, index, value;

/*
 **************************************************
 *                                                *
 *   handle "eval list" and dump everything that  *
 *   can be modified.                             *
 *                                                *
 **************************************************
 */
    if (nargs == 2 && !strcmp(args[1], "list")) {
      for (i = 0; i < 256; i++) {
        if (!eval_packet[i].description)
          continue;
        if (eval_packet[i].value) {
          if (eval_packet[i].size == 0)
            printf("%3d  %s %7d\n", i, eval_packet[i].description,
                *eval_packet[i].value);
          else {
            printf("%3d  %s\n", i, eval_packet[i].description);
            DisplayArray(eval_packet[i].value, eval_packet[i].size);
          }
        } else
          printf("------------%s\n", eval_packet[i].description);
      }
      printf("\n");
      return (1);
    }
/*
 **************************************************
 *                                                *
 *   handle "eval save" and dump everything that  *
 *   can be modified to a file                    *
 *                                                *
 **************************************************
 */
    if (nargs == 3 && !strcmp(args[1], "save")) {
      char filename[256];
      FILE *file;

      strcpy(filename, args[2]);
      strcat(filename, ".cpf");
      file = fopen(filename, "w");
      if (!file) {
        printf("ERROR.  Unable to open %s for writing\n", args[2]);
        return (1);
      }
      printf("saving to file \"%s\"\n", filename);
      for (i = 0; i < 256; i++) {
        if (!eval_packet[i].description)
          continue;
        if (eval_packet[i].value) {
          if (eval_packet[i].size == 0)
            fprintf(file, "evaluation %3d %7d\n", i, *eval_packet[i].value);
          else if (eval_packet[i].size > 0) {
            fprintf(file, "evaluation %3d ", i);
            for (j = 0; j < eval_packet[i].size; j++)
              fprintf(file, "%d ", eval_packet[i].value[j]);
            fprintf(file, "\n");
          } else {
            fprintf(file, "evaluation %3d ", i);
            for (j = 0; j < 8; j++)
              for (k = 0; k < 8; k++)
                fprintf(file, "%d ", eval_packet[i].value[(7 - j) * 8 + k]);
            fprintf(file, "\n");
          }
        }
      }
      fprintf(file, "exit");
      fclose(file);
      return (1);
    }
/*
 **************************************************
 *                                                *
 *   handle "eval index val" command that changes *
 *   only those terms that are scalars.           *
 *                                                *
 **************************************************
 */
    param = atoi(args[1]);
    value = atoi(args[2]);
    if (!eval_packet[param].value) {
      Print(4095, "ERROR.  evaluation term %d is not defined\n", param);
      return (1);
    }
    if (eval_packet[param].size == 0) {
      if (nargs > 3) {
        printf("this eval term requires exactly 1 value.\n");
        return (1);
      }
      if (!silent)
        Print(128, "%s old:%d  new:%d\n", eval_packet[param].description,
            *eval_packet[param].value, value);
      *eval_packet[param].value = value;
    }
/*
 **************************************************
 *                                                *
 *   handle "eval index v1 v2 .. vn" command that *
 *   changes eval terms that are vectors.         *
 *                                                *
 **************************************************
 */
    else {
      index = nargs - 2;
      if (index != abs(eval_packet[param].size)) {
        printf("this eval term (%s [%d]) requires exactly %d values.\n",
            eval_packet[param].description, param,
            abs(eval_packet[param].size));
        return (1);
      }
      if (!silent)
        printf("%2d  %s\n", param, eval_packet[param].description);
      if (!silent) {
        printf("old:\n");
        DisplayArray(eval_packet[param].value, eval_packet[param].size);
      }
      if (eval_packet[param].size > 0)
        for (i = 0; i < index; i++) {
          eval_packet[param].value[i] = atoi(args[i + 2]);
      } else
        for (i = 0; i < 8; i++)
          for (j = 0; j < 8; j++)
            eval_packet[param].value[(7 - i) * 8 + j] =
                atoi(args[i * 8 + j + 2]);
      if (!silent) {
        printf("new:\n");
        DisplayArray(eval_packet[param].value, eval_packet[param].size);
      }
    }
    InitializeEvaluation();
  }
/*
 ************************************************************
 *                                                          *
 *   "evtest" command runs a test suite of problems and     *
 *   prints evaluations only.                               *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("evtest", *args)) {
    if (shared->thinking || shared->pondering)
      return (2);
    if (nargs < 2) {
      printf("usage:  evtest <filename> [exitcnt]\n");
      return (1);
    }
    EVTest(args[1]);
    ponder_move = 0;
    last_pv.pathd = 0;
    last_pv.pathl = 0;
  }
/*
 ************************************************************
 *                                                          *
 *   "exit" command resets input device to STDIN.           *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("exit", *args)) {
    if (analyze_mode)
      return (0);
    if (input_stream != stdin)
      fclose(input_stream);
    input_stream = stdin;
    ReadClear();
    Print(128, "\n");
  }
/*
 ************************************************************
 *                                                          *
 *   "extension" command allows setting the various search  *
 *   extension depths to any reasonable value between 0 and *
 *   1.0                                                    *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("extensions", *args)) {
    if (nargs > 1) {
      if (OptionMatch("check", args[1])) {
        float ext = atof(args[2]);
        incheck_depth = (float) PLY *ext;

        if (incheck_depth < 0)
          incheck_depth = 0;
        if (incheck_depth > PLY)
          incheck_depth = PLY;
      }
      if (OptionMatch("onerep", args[1])) {
        float ext = atof(args[2]);
        onerep_depth = (float) PLY *ext;

        if (onerep_depth < 0)
          onerep_depth = 0;
        if (onerep_depth > PLY)
          onerep_depth = PLY;
      }
      if (OptionMatch("mate", args[1])) {
        float ext = atof(args[2]);
        mate_depth = (float) PLY *ext;

        if (mate_depth < 0)
          mate_depth = 0;
        if (mate_depth > PLY)
          mate_depth = PLY;
      }
    }
    if (!silent) {
      Print(1, "one-reply extension..................%4.2f\n",
          (float) onerep_depth / PLY);
      Print(1, "in-check extension...................%4.2f\n",
          (float) incheck_depth / PLY);
      Print(1, "mate thrt extension..................%4.2f\n",
          (float) mate_depth / PLY);
    }
  }
/*
 ************************************************************
 *                                                          *
 *   "flag" command controls whether Crafty will call the   *
 *   flag in xboard/winboard games (to end the game.)       *
 *                                                          *
 ************************************************************
 */
  else if (!strcmp("flag", *args)) {
    if (nargs < 2) {
      printf("usage:  flag on|off\n");
      return (1);
    }
    if (!strcmp(args[1], "on"))
      call_flag = 1;
    else if (!strcmp(args[1], "off"))
      call_flag = 0;
    if (call_flag)
      Print(128, "end game on time forfeits\n");
    else
      Print(128, "ignore time forfeits\n");
  }
/*
 ************************************************************
 *                                                          *
 *   "flip" command flips the board, interchanging each     *
 *   rank with the corresponding rank on the other half of  *
 *   the board, and also reverses the color of all pieces.  *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("flip", *args)) {
    int file, rank, piece, temp;

    if (shared->thinking || shared->pondering)
      return (2);
    for (rank = 0; rank < 4; rank++) {
      for (file = 0; file < 8; file++) {
        piece = -PcOnSq((rank << 3) + file);
        PcOnSq((rank << 3) + file) = -PcOnSq(((7 - rank) << 3) + file);
        PcOnSq(((7 - rank) << 3) + file) = piece;
      }
    }
    wtm = Flip(wtm);
    temp = WhiteCastle(0);
    WhiteCastle(0) = BlackCastle(0);
    BlackCastle(0) = temp;
    SetChessBitBoards(&tree->position[0]);
#if defined(DEBUG)
    ValidatePosition(tree, 0, wtm, "Option().flip");
#endif
  }
/*
 ************************************************************
 *                                                          *
 *   "flop" command flops the board, interchanging each     *
 *   file with the corresponding file on the other half of  *
 *   the board.                                             *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("flop", *args)) {
    int file, rank, piece;

    if (shared->thinking || shared->pondering)
      return (2);
    for (rank = 0; rank < 8; rank++) {
      for (file = 0; file < 4; file++) {
        piece = PcOnSq((rank << 3) + file);
        PcOnSq((rank << 3) + file) = PcOnSq((rank << 3) + 7 - file);
        PcOnSq((rank << 3) + 7 - file) = piece;
      }
    }
    SetChessBitBoards(&tree->position[0]);
#if defined(DEBUG)
    ValidatePosition(tree, 0, wtm, "Option().flop");
#endif
  }
/*
 ************************************************************
 *                                                          *
 *   "force" command forces the program to make a specific  *
 *   move instead of its last chosen move.                  *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("force", *args)) {
    int move, movenum, save_move_number;
    char text[16];

    if (shared->thinking || shared->pondering)
      return (3);
    if (xboard) {
      force = 1;
      return (3);
    }
    if (nargs < 2) {
      printf("usage:  force <move>\n");
      return (1);
    }
    ponder_move = 0;
    last_pv.pathd = 0;
    last_pv.pathl = 0;
    save_move_number = shared->move_number;
    movenum = shared->move_number;
    if (wtm)
      movenum--;
    strcpy(text, args[1]);
    sprintf(buffer, "reset %d", movenum);
    wtm = Flip(wtm);
    (void) Option(tree);
    move = InputMove(tree, text, 0, wtm, 0, 0);
    if (move) {
      if (input_stream != stdin)
        printf("%s\n", OutputMove(tree, move, 0, wtm));
      fseek(history_file, ((movenum - 1) * 2 + 1 - wtm) * 10, SEEK_SET);
      fprintf(history_file, "%9s\n", OutputMove(tree, move, 0, wtm));
      MakeMoveRoot(tree, move, wtm);
      last_pv.pathd = 0;
      last_pv.pathl = 0;
    } else if (input_stream == stdin)
      printf("illegal move.\n");
    wtm = Flip(wtm);
    shared->move_number = save_move_number;
  }
/*
 ************************************************************
 *                                                          *
 *   "go" command does nothing, except force main() to      *
 *   start a search.  ("move" is an alias for go).          *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("go", *args) || OptionMatch("move", *args)) {
    char temp[64];

    if (shared->thinking || shared->pondering)
      return (2);
    if (wtm) {
      if (strncmp(pgn_white, "Crafty", 6)) {
        strcpy(temp, pgn_white);
        strcpy(pgn_white, pgn_black);
        strcpy(pgn_black, temp);
      }
    } else {
      if (strncmp(pgn_black, "Crafty", 6)) {
        strcpy(temp, pgn_white);
        strcpy(pgn_white, pgn_black);
        strcpy(pgn_black, temp);
      }
    }
    force = 0;
    return (-1);
  }
/*
 ************************************************************
 *                                                          *
 *   "history" command displays game history (moves).       *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("history", *args)) {
    int i;
    char buffer[128];

    printf("    white       black\n");
    for (i = 0; i < (shared->move_number - 1) * 2 - wtm + 1; i++) {
      fseek(history_file, i * 10, SEEK_SET);
      fscanf(history_file, "%s", buffer);
      if (!(i % 2))
        printf("%3d", i / 2 + 1);
      printf("  %-10s", buffer);
      if (i % 2 == 1)
        printf("\n");
    }
    if (Flip(wtm))
      printf("  ...\n");
  }
/*
 ************************************************************
 *                                                          *
 *  "hard" command enables thinking on opponent's time.     *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("hard", *args)) {
    ponder = 1;
    Print(128, "pondering enabled.\n");
  }
/*
 ************************************************************
 *                                                          *
 *   "hash" command controls the transposition table size.  *
 *   the size can be entered in one of three ways:          *
 *                                                          *
 *      hash=nnn  where nnn is in bytes.                    *
 *      hash=nnnK where nnn is in K bytes.                  *
 *      hash=nnnM where nnn is in M bytes.                  *
 *                                                          *
 *   the only restriction is that the hash table is com-    *
 *   puted as follows:  one entry is 16 bytes long.  there  *
 *   are 4 tables, two for black, two for white, with one   *
 *   of each being twice the size of the other for the same *
 *   side.  this means that one entry in one of the small   *
 *   tables corresponds to two in the other, so one entry   *
 *   really translates to six entries.  Therefore, the size *
 *   that is entered is divided by 6*16, and then rounded   *
 *   down to the nearest power of two which is a restric-   *
 *   tion on the size of a single table.                    *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("hash", *args)) {
    size_t new_hash_size;

    if (shared->thinking || shared->pondering)
      return (2);
    if (nargs > 1) {
      new_hash_size = atoi(args[1]);
      if (strchr(args[1], 'K') || strchr(args[1], 'k'))
        new_hash_size *= 1 << 10;
      if (strchr(args[1], 'M') || strchr(args[1], 'm'))
        new_hash_size *= 1 << 20;
      if (new_hash_size < 48 * 1024) {
        printf("ERROR.  Minimum hash table size is 48K bytes.\n");
        return (1);
      }
      if (new_hash_size > 0) {
        if (hash_table_size) {
          SharedFree(trans_ref);
        }
        new_hash_size /= 16 * 3;
        for (log_hash = 0; log_hash < (int) (8 * sizeof(int)); log_hash++)
          if ((1 << (log_hash + 1)) > new_hash_size)
            break;
        if (log_hash) {
          hash_table_size = 1 << log_hash;
          cb_trans_ref = sizeof(HASH_ENTRY) * hash_table_size + 15;
          trans_ref = (HASH_ENTRY *) SharedMalloc(cb_trans_ref, 0);
          if (!trans_ref) {
            printf("malloc() failed, not enough memory.\n");
            SharedFree(trans_ref);
            hash_table_size = 0;
            log_hash = 0;
            trans_ref = 0;
          }
          hash_mask = (1 << log_hash) - 1;
          ClearHashTableScores(1);
        } else {
          trans_ref = 0;
          hash_table_size = 0;
          log_hash = 0;
        }
      } else
        Print(4095, "ERROR:  hash table size must be > 0\n");
    }
    Print(128, "hash table memory = %s bytes.\n",
        PrintKM(hash_table_size * sizeof(HASH_ENTRY), 1));
  }
/*
 ************************************************************
 *                                                          *
 *   "hashp" command controls the pawn hash table size.     *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("hashp", *args)) {
    int i;
    size_t new_hash_size;

    if (shared->thinking || shared->pondering)
      return (2);
    if (nargs > 1) {
      new_hash_size = atoi(args[1]);
      if (strchr(args[1], 'K') || strchr(args[1], 'k'))
        new_hash_size *= 1 << 10;
      if (strchr(args[1], 'M') || strchr(args[1], 'm'))
        new_hash_size *= 1 << 20;
      if (new_hash_size < 16 * 1024) {
        printf("ERROR.  Minimum pawn hash table size is 16K bytes.\n");
        return (1);
      }
      if (pawn_hash_table) {
        SharedFree(pawn_hash_table);
        pawn_hash_table_size = 0;
        log_pawn_hash = 0;
        pawn_hash_table = 0;
      }
      new_hash_size /= sizeof(PAWN_HASH_ENTRY);
      for (log_pawn_hash = 0; log_pawn_hash < (int) (8 * sizeof(int));
          log_pawn_hash++)
        if ((1 << (log_pawn_hash + 1)) > new_hash_size)
          break;
      pawn_hash_table_size = 1 << log_pawn_hash;
      cb_pawn_hash_table = sizeof(PAWN_HASH_ENTRY) * pawn_hash_table_size + 15;
      pawn_hash_table = (PAWN_HASH_ENTRY *) SharedMalloc(cb_pawn_hash_table, 0);
      if (!pawn_hash_table) {
        printf("malloc() failed, not enough memory.\n");
        SharedFree(pawn_hash_table);
        pawn_hash_table_size = 0;
        log_pawn_hash = 0;
        pawn_hash_table = 0;
      }
      pawn_hash_mask = (1 << log_pawn_hash) - 1;
      for (i = 0; i < pawn_hash_table_size; i++) {
        (pawn_hash_table + i)->key = 0;
        (pawn_hash_table + i)->p_score = 0;
        (pawn_hash_table + i)->protected = 0;
        (pawn_hash_table + i)->black_defects_k = 0;
        (pawn_hash_table + i)->black_defects_q = 0;
        (pawn_hash_table + i)->white_defects_k = 0;
        (pawn_hash_table + i)->white_defects_q = 0;
        (pawn_hash_table + i)->passed_w = 0;
        (pawn_hash_table + i)->passed_b = 0;
        (pawn_hash_table + i)->outside = 0;
        (pawn_hash_table + i)->candidates_w = 0;
        (pawn_hash_table + i)->candidates_b = 0;
      }
    }
    Print(128, "pawn hash table memory = %s bytes.\n",
        PrintKM(pawn_hash_table_size * sizeof(PAWN_HASH_ENTRY), 1));
  }
/*
 ************************************************************
 *                                                          *
 *   "help" command lists commands/options.                 *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("help", *args)) {
    FILE *helpfile;
    char *readstat = (char *) -1;
    int lines = 0;

    helpfile = fopen("crafty.hlp", "r");
    if (!helpfile) {
      printf("ERROR.  Unable to open \"crafty.hlp\" -- help unavailable\n");
      return (1);
    }
    if (nargs > 1) {
      while (1) {
        readstat = fgets(buffer, 128, helpfile);
        if (!readstat) {
          printf("Sorry, no help available for \"%s\"\n", args[1]);
          fclose(helpfile);
          return (1);
        }
        if (buffer[0] == '<') {
          if (strstr(buffer, args[1]))
            break;
        }
      }
    }
    while (1) {
      readstat = fgets(buffer, 128, helpfile);
      if (!readstat)
        break;
      if (strchr(buffer, '\n'))
        *strchr(buffer, '\n') = 0;
      if (!strcmp(buffer, "<end>"))
        break;
      printf("%s\n", buffer);
      lines++;
      if (lines > 22) {
        lines = 0;
        printf("<return> for more...");
        fflush(stdout);
        (void) Read(1, buffer);
      }
    }
    fclose(helpfile);
  }
/*
 ************************************************************
 *                                                          *
 *   "hint" displays the expected move based on the last    *
 *   search done. [xboard compatibility]                    *
 *                                                          *
 ************************************************************
 */
  else if (!strcmp("hint", *args)) {
    if (strlen(hint)) {
      printf("Hint: %s\n", hint);
      fflush(stdout);
    }
  }
/*
 ************************************************************
 *                                                          *
 *  "ics" command is normally invoked from main() via the   *
 *  ics command-line option.  it sets proper defaults for   *
 *  defaults for the custom crafty/ics interface program.   *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("ics", *args)) {
    ics = 1;
    shared->display_options &= 4095 - 32;
  }
/*
 ************************************************************
 *                                                          *
 *   "input" command directs the program to read input from *
 *   a file until eof is reached or an "exit" command is    *
 *   encountered while reading the file.                    *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("input", *args)) {
    if (shared->thinking || shared->pondering)
      return (2);
    nargs = ReadParse(buffer, args, " 	=");
    if (nargs < 2) {
      printf("usage:  input <filename>\n");
      return (1);
    }
    if (!(input_stream = fopen(args[1], "r"))) {
      printf("file does not exist.\n");
      input_stream = stdin;
    }
  }
/*
 ************************************************************
 *                                                          *
 *  "info" command gives some information about Crafty.     *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("info", *args)) {
    Print(128, "Crafty version %s\n", version);
    Print(128, "hash table memory =      %s bytes.\n",
        PrintKM(hash_table_size * sizeof(HASH_ENTRY), 1));
    Print(128, "pawn hash table memory = %s bytes.\n",
        PrintKM(pawn_hash_table_size * sizeof(PAWN_HASH_ENTRY), 1));
#if !defined(NOEGTB)
    Print(128, "EGTB cache memory =      %s bytes.\n", PrintKM(EGTB_cache_size,
            1));
#endif
    if (!shared->tc_sudden_death) {
      Print(128, "%d moves/%d minutes %d seconds primary time control\n",
          shared->tc_moves, shared->tc_time / 6000,
          (shared->tc_time / 100) % 60);
      Print(128, "%d moves/%d minutes %d seconds secondary time control\n",
          shared->tc_secondary_moves, shared->tc_secondary_time / 6000,
          (shared->tc_secondary_time / 100) % 60);
      if (shared->tc_increment)
        Print(128, "increment %d seconds.\n", shared->tc_increment / 100);
    } else if (shared->tc_sudden_death == 1) {
      Print(128, " game/%d minutes primary time control\n",
          shared->tc_time / 6000);
      if (shared->tc_increment)
        Print(128, "increment %d seconds.\n",
            (shared->tc_increment / 100) % 60);
    } else if (shared->tc_sudden_death == 2) {
      Print(128, "%d moves/%d minutes primary time control\n", shared->tc_moves,
          shared->tc_time / 6000);
      Print(128, "game/%d minutes secondary time control\n",
          shared->tc_secondary_time / 6000);
      if (shared->tc_increment)
        Print(128, "increment %d seconds.\n", shared->tc_increment / 100);
    }
    Print(128, "frequency (freq)..............%4.2f\n", book_weight_freq);
    Print(128, "static evaluation (eval)......%4.2f\n", book_weight_eval);
    Print(128, "learning (learn)..............%4.2f\n", book_weight_learn);
  }
/*
 ************************************************************
 *                                                          *
 *   "kibitz" command sets kibitz mode for ICS.  =1 will    *
 *   kibitz mate announcements, =2 will kibitz scores and   *
 *   other info, =3 will kibitz scores and PV, =4 adds the  *
 *   list of book moves, =5 displays the PV after each      *
 *   iteration completes, and =6 displays the PV each time  *
 *   it changes in an iteration.                            *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("kibitz", *args)) {
    if (nargs < 2) {
      printf("usage:  kibitz <level>\n");
      return (1);
    }
    kibitz = atoi(args[1]);
  }
/*
 ************************************************************
 *                                                          *
 *   "learn" command enables/disables the learning          *
 *   algorithms used in crafty.  these are controlled by    *
 *   a single variable with multiple boolean switches in    *
 *   it as defined below:                                   *
 *                                                          *
 *   000 -> no learning enabled.                            *
 *   001 -> learn which book moves are good and bad.        *
 *   010 -> learn middlegame positions.                     *
 *   100 -> learn from game "results" (win/lose).           *
 *                                                          *
 *   these are entered as an integer, which is formed by    *
 *   adding the integer values 1,2,4 to enable the various  *
 *   forms of learning.                                     *
 *                                                          *
 *   a special-case of this command uses two arguments in-  *
 *   stead of one.  it is used to control position learning *
 *   and lets you specify the "trigger" threshold and the   *
 *   limit that shuts position learning off after a game is *
 *   already lost.  the syntax is:                          *
 *                                                          *
 *   learn trigger-value cutoff-value                       *
 *                                                          *
 *   trigger-value is the amount the score must drop before *
 *   position learning is triggered.  the default is 1/3 of *
 *   a pawn (.33).                                          *
 *                                                          *
 *   cutoff-value is the lower bound on the score before    *
 *   position learning is turned off.  the default is -2.0  *
 *   and says that once the score is -2, do not learn any   *
 *   further positions where the score is -2.0 - trigger_   *
 *   value from above.                                      *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("learn", *args)) {
    if (nargs == 2) {
      if (OptionMatch("clear", *(args + 1))) {
        int index[32768], i, j, cluster;
        unsigned char buf32[4];

        fseek(book_file, 0, SEEK_SET);
        for (i = 0; i < 32768; i++) {
          fread(buf32, 4, 1, book_file);
          index[i] = BookIn32(buf32);
        }
        for (i = 0; i < 32768; i++)
          if (index[i] > 0) {
            fseek(book_file, index[i], SEEK_SET);
            fread(buf32, 4, 1, book_file);
            cluster = BookIn32(buf32);
            BookClusterIn(book_file, cluster, book_buffer);
            for (j = 0; j < cluster; j++)
              book_buffer[j].learn = 0.0;
            fseek(book_file, index[i] + sizeof(int), SEEK_SET);
            BookClusterOut(book_file, cluster, book_buffer);
          }
      } else {
        learning = atoi(args[1]);
        if (learning & book_learning)
          Print(128, "book learning enabled\n");
        else
          Print(128, "book learning disabled\n");
        if (learning & result_learning)
          Print(128, "result learning enabled\n");
        else
          Print(128, "result learning disabled\n");
      }
    } else if (nargs == 3) {
      learning_trigger = atof(args[1]) * 100;
      learning_cutoff = atof(args[2]) * 100;
      Print(128, "learning trigger = %s\n", DisplayEvaluation(learning_trigger,
              1));
      Print(128, "learning cutoff = %s\n", DisplayEvaluation(learning_cutoff,
              1));
    }
  }
/*
 ************************************************************
 *                                                          *
 *   "level" command sets time controls [ics/xboard         *
 *   compatibility.]                                        *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("level", *args)) {
    if (nargs < 4) {
      printf("usage:  level <nmoves> <stime> <inc>\n");
      return (1);
    }
    shared->tc_moves = atoi(args[1]);
    shared->tc_time = atoi(args[2]) * 100;
    shared->tc_increment = atoi(args[3]) * 100;
    shared->tc_time_remaining = shared->tc_time;
    shared->tc_time_remaining_opponent = shared->tc_time;
    if (!shared->tc_moves) {
      shared->tc_sudden_death = 1;
      shared->tc_moves = 1000;
      shared->tc_moves_remaining = 1000;
    } else
      shared->tc_sudden_death = 0;
    if (shared->tc_moves) {
      shared->tc_secondary_moves = shared->tc_moves;
      shared->tc_secondary_time = shared->tc_time;
      shared->tc_moves_remaining = shared->tc_moves;
    }
    if (!shared->tc_sudden_death) {
      Print(128, "%d moves/%d minutes primary time control\n", shared->tc_moves,
          shared->tc_time / 100);
      Print(128, "%d moves/%d minutes secondary time control\n",
          shared->tc_secondary_moves, shared->tc_secondary_time / 100);
      if (shared->tc_increment)
        Print(128, "increment %d seconds.\n", shared->tc_increment / 100);
    } else if (shared->tc_sudden_death == 1) {
      Print(128, " game/%d minutes primary time control\n",
          shared->tc_time / 100);
      if (shared->tc_increment)
        Print(128, "increment %d seconds.\n", shared->tc_increment / 100);
    }
    shared->tc_time *= 60;
    shared->tc_time_remaining = shared->tc_time;
    shared->tc_secondary_time *= 60;
    if (adaptive_hash) {
      float percent;
      int optimal_hash_size;
      BITBOARD positions_per_move;

      TimeSet(think);
      shared->time_limit /= 100;
      positions_per_move = shared->time_limit * adaptive_hash / 16;
      optimal_hash_size = positions_per_move * 16 * 2;
      optimal_hash_size = Max(optimal_hash_size, adaptive_hash_min);
      optimal_hash_size = Min(optimal_hash_size, adaptive_hash_max);
      sprintf(buffer, "hash=%d\n", optimal_hash_size);
      (void) Option(tree);
      percent =
          (float) (hash_table_size * sizeof(HASH_ENTRY) -
          adaptive_hash_min) / (float) (adaptive_hash_max - adaptive_hash_min);
      optimal_hash_size =
          adaptive_hashp_min + percent * (adaptive_hashp_max -
          adaptive_hashp_min);
      optimal_hash_size = Max(optimal_hash_size, adaptive_hashp_min);
      sprintf(buffer, "hashp=%d\n", optimal_hash_size);
      (void) Option(tree);
    }
  }
/*
 ************************************************************
 *                                                          *
 *   "list" command allows the operator to add or remove    *
 *   names from the various lists crafty uses to recognize  *
 *   and adapt to particular opponents.                     *
 *                                                          *
 *   list <listname> <player>                               *
 *                                                          *
 *   <listname> is one of AK, B, C, GM, IM, SP.             *
 *                                                          *
 *   The final parameter is a name to add  or remove.  if   *
 *   you prepend a + to the name, that asks that the name   *
 *   be added to the list.  if you prepend a - to the name, *
 *   that asks that the name be removed from the list.      *
 *   if no name is given, the list is displayed.            *
 *                                                          *
 *   AK is the "auto-kibitz" list.  Crafty will kibitz info *
 *   on a chess server when playing any opponent in this    *
 *   list.  this should only have computer names as humans  *
 *   don't approve of kibitzes while they are playing.      *
 *                                                          *
 *   B identifies "blocker" players, those that try to      *
 *   block the position and go for easy draws.  this makes  *
 *   Crafty try much harder to prevent this from happening, *
 *   even at the expense of positional compensation.        *
 *                                                          *
 *   C identifies a computer opponent name, although on a   *
 *   chess server this is handled by xboard/winboard.       *
 *                                                          *
 *   GM and IM identify titled players.  this affects how   *
 *   and when Crafty resigns or offers/accepts draws.  For  *
 *   GM players it will do so fairly early after the right  *
 *   circumstances have been seen, for IM it delays a bit   *
 *   longer as they are more prone to making a small error  *
 *   that avoids the loss or draw.                          *
 *                                                          *
 *   SP is the "special player" option.  this is an         *
 *   extended version of the "list" command that allows you *
 *   to specify a special "start book" for a particular     *
 *   opponent to make crafty play specific openings against *
 *   that opponent, as well as allowing you to specify a    *
 *   personality file to use against that specific opponent *
 *   when he is identified by the correct "name" command.   *
 *                                                          *
 *   For the SP list, the command is extended to use        *
 *                                                          *
 *   "list SP +player book=filename  personality=filename"  *
 *                                                          *
 *   For the SP list, the files specified must exist in the *
 *   current directory unless the bookpath and perspath     *
 *   commands direct Crafty to look elsewhere.              *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("list", *args)) {
    int i, list, lastent = -1;
    char **targs;
    char listname[6][3] = { "AK", "B", "C", "GM", "IM", "SP" };
    char **listaddr[6] = { AK_list, B_list, C_list, GM_list,
      IM_list, SP_list
    };

    targs = args;
    for (list = 0; list < 7; list++) {
      if (!strcmp(listname[list], args[1]))
        break;
    }
    if (list > 5) {
      printf("usage:  list AK|B|C|GM|IM|P|SP +name1 -name2 etc\n");
      return (1);
    }
    nargs -= 2;
    targs += 2;
    if (nargs) {
      while (nargs) {
        if (targs[0][0] == '-') {
          for (i = 0; i < 128; i++)
            if (listaddr[list][i]) {
              if (!strcmp(listaddr[list][i], targs[0] + 1)) {
                free(listaddr[list][i]);
                listaddr[list][i] = NULL;
                Print(128, "%s removed from %s list.\n", targs[0] + 1,
                    listname[list]);
                break;
              }
            }
        } else if (targs[0][0] == '+') {
          for (i = 0; i < 128; i++)
            if (listaddr[list][i]) {
              if (!strcmp(listaddr[list][i], targs[0] + 1)) {
                Print(128, "Warning: %s is already in %s list.\n", targs[0] + 1,
                    listname[list]);
                break;
              }
            }
          for (i = 0; i < 128; i++)
            if (listaddr[list][i] == NULL)
              break;
          if (i >= 128)
            Print(128, "ERROR!  %s list is full at 128 entries\n",
                listname[list]);
          else {
            listaddr[list][i] = malloc(strlen(targs[0]));
            strcpy(listaddr[list][i], targs[0] + 1);
            Print(128, "%s added to %s list.\n", targs[0] + 1, listname[list]);
            if (list == 5)
              lastent = i;
          }
        } else if (!strcmp(targs[0], "clear")) {
          for (i = 0; i < 128; i++) {
            free(listaddr[list][i]);
            listaddr[list][i] = NULL;
          }
        } else if (!strcmp(targs[0], "book") && lastent != -1) {
          char filename[256];
          FILE *file;

          strcpy(filename, book_path);
          strcat(filename, "/");
          strcat(filename, targs[1]);
          if (!strstr(args[2], ".bin"))
            strcat(filename, ".bin");
          file = fopen(filename, "r");
          if (!file) {
            Print(4095, "ERROR  book file %s can not be opened\n", filename);
            break;
          }
          fclose(file);
          SP_opening_filename[lastent] = malloc(strlen(filename) + 1);
          strcpy(SP_opening_filename[lastent], filename);
          nargs--;
          targs++;
        } else if (!strcmp(targs[0], "personality") && lastent != -1) {
          char filename[256];
          FILE *file;

          strcpy(filename, personality_path);
          strcat(filename, "/");
          strcat(filename, targs[1]);
          if (!strstr(args[2], ".cpf"))
            strcat(filename, ".cpf");
          file = fopen(filename, "r");
          if (!file) {
            Print(4095, "ERROR  personality file %s can not be opened\n",
                filename);
            break;
          }
          fclose(file);
          SP_personality_filename[lastent] = malloc(strlen(filename) + 1);
          strcpy(SP_personality_filename[lastent], filename);
          nargs--;
          targs++;
        } else
          printf("error, name must be preceeded by +/- flag.\n");
        nargs--;
        targs++;
      }
    } else {
      Print(128, "%s List:\n", listname[list]);
      for (i = 0; i < 128; i++) {
        if (listaddr[list][i]) {
          Print(128, "%s", listaddr[list][i]);
          if (list == 5) {
            if (SP_opening_filename[i])
              Print(128, "  book=%s", SP_opening_filename[i]);
            if (SP_personality_filename[i])
              Print(128, "  personality=%s", SP_personality_filename[i]);
          }
          Print(128, "\n");
        }
      }
    }
  }
/*
 ************************************************************
 *                                                          *
 *   "load" command directs the program to read input from  *
 *   a file until a "setboard" command is found  this       *
 *   command is then executed, setting up the position for  *
 *   a search.                                              *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("load", *args)) {
    char title[64];
    char *readstat;
    FILE *prob_file;

    if (shared->thinking || shared->pondering)
      return (2);
    nargs = ReadParse(buffer, args, " 	=");
    if (nargs < 3) {
      printf("usage:  input <filename> title\n");
      return (1);
    }
    if (!(prob_file = fopen(args[1], "r"))) {
      printf("file does not exist.\n");
      return (1);
    }
    strcpy(title, args[2]);
    while (!feof(prob_file)) {
      readstat = fgets(buffer, 128, prob_file);
      if (readstat) {
        char *delim;

        delim = strchr(buffer, '\n');
        if (delim)
          *delim = 0;
        delim = strchr(buffer, '\r');
        if (delim)
          *delim = ' ';
      }
      if (readstat == NULL)
        break;
      nargs = ReadParse(buffer, args, " 	;\n");
      if (!strcmp(args[0], "title") && strstr(buffer, title))
        break;
    }
    while (!feof(prob_file)) {
      readstat = fgets(buffer, 128, prob_file);
      if (readstat) {
        char *delim;

        delim = strchr(buffer, '\n');
        if (delim)
          *delim = 0;
        delim = strchr(buffer, '\r');
        if (delim)
          *delim = ' ';
      }
      if (readstat == NULL)
        break;
      nargs = ReadParse(buffer, args, " 	;\n");
      if (!strcmp(args[0], "setboard")) {
        (void) Option(tree);
        break;
      }
    }
  }
/*
 ************************************************************
 *                                                          *
 *   "log" command turns log on/off, and also lets you view *
 *   the end of the log or copy it to disk as needed.  To   *
 *   view the end, simply type "log <n>" where n is the #   *
 *   of lines you'd like to see (the last <n> lines).  you  *
 *   can add a filename to the end and the output will go   *
 *   to this file instead.                                  *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("log", *args)) {
    FILE *output_file;
    char filename[64], buffer[128];

    if (nargs < 2) {
      printf("usage:  log on|off|n [filename]\n");
      return (1);
    }
    if (!strcmp(args[1], "on")) {
      int id;

      id = InitializeGetLogID();
      sprintf(log_filename, "%s/log.%03d", log_path, id);
      sprintf(history_filename, "%s/game.%03d", log_path, id);
      log_file = fopen(log_filename, "w");
      history_file = fopen(history_filename, "w+");
    } else if (!strcmp(args[1], "off")) {
      if (log_file)
        fclose(log_file);
      log_file = 0;
      sprintf(filename, "%s/log.%03d", log_path, log_id - 1);
      remove(filename);
    } else if (args[1][0] >= '0' && args[1][0] <= '9') {
      if (log_id == 0)
        log_id = atoi(args[1]);
    } else {
      int nrecs, trecs, lrecs;
      char *eof;
      FILE *log;

      nrecs = atoi(args[1]);
      output_file = stdout;
      if (nargs > 2)
        output_file = fopen(args[2], "w");
      log = fopen(log_filename, "r");
      for (trecs = 1; trecs < 99999999; trecs++) {
        eof = fgets(buffer, 128, log);
        if (eof) {
          char *delim;

          delim = strchr(buffer, '\n');
          if (delim)
            *delim = 0;
          delim = strchr(buffer, '\r');
          if (delim)
            *delim = ' ';
        } else
          break;
      }
      fseek(log, 0, SEEK_SET);
      for (lrecs = 1; lrecs < trecs - nrecs; lrecs++) {
        eof = fgets(buffer, 128, log);
        if (eof) {
          char *delim;

          delim = strchr(buffer, '\n');
          if (delim)
            *delim = 0;
          delim = strchr(buffer, '\r');
          if (delim)
            *delim = ' ';
        } else
          break;
      }
      for (; lrecs < trecs; lrecs++) {
        eof = fgets(buffer, 128, log);
        if (eof) {
          char *delim;

          delim = strchr(buffer, '\n');
          if (delim)
            *delim = 0;
          delim = strchr(buffer, '\r');
          if (delim)
            *delim = ' ';
        } else
          break;
        fprintf(output_file, "%s\n", buffer);
      }
      if (output_file != stdout)
        fclose(output_file);
    }
  }
/*
 ************************************************************
 *                                                          *
 *   "smp" command is used to tune the various SMP search   *
 *   parameters.                                            *
 *                                                          *
 *   "smpmin" command is used to set the minimum depth of   *
 *   a tree before a thread can be started.  this is used   *
 *   to prevent the thread creation overhead from becoming  *
 *   larger than the time actually needed to search the     *
 *   tree.                                                  *
 *                                                          *
 *   "smpmt" command is used to set the maximum number of   *
 *   parallel threads to use, assuming that Crafty was      *
 *   compiled with -DSMP.  this value can not be set        *
 *   larger than the compiled-in -DCPUS=n value.            *
 *                                                          *
 *   "smproot" command is used to enable (1) or disable (0) *
 *   splitting the tree at the root (ply=1).  splitting at  *
 *   the root is more efficient, but might slow finding the *
 *   move in some test positions.                           *
 *                                                          *
 *   "smpgroup" command is used to control how many threads *
 *   may work together at any point in the tree.  the       *
 *   usual default is 8, but this might be reduced on a     *
 *   machine with a large number of processors.  it should  *
 *   be tested, of course.                                  *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("smpgroup", *args)) {
    if (nargs < 2) {
      printf("usage:  smpgroup <threads>\n");
      return (1);
    }
    shared->max_thread_group = atoi(args[1]);
    Print(128, "maximum thread group size set to %d\n",
        shared->max_thread_group);
  } else if (OptionMatch("smpmin", *args)) {
    if (nargs < 2) {
      printf("usage:  smpmin <plies>\n");
      return (1);
    }
    shared->min_thread_depth = atoi(args[1]);
    Print(128, "minimum thread depth set to %d%\n", shared->min_thread_depth);
  } else if (OptionMatch("smpmt", *args) || OptionMatch("mt", *args)) {
    int proc;

    if (nargs < 2) {
      printf("usage:  smpmt=<threads>\n");
      return (1);
    }
    if (shared->thinking || shared->pondering)
      return (3);
    shared->max_threads = atoi(args[1]);
    if (shared->max_threads > CPUS) {
      Print(4095, "ERROR - Crafty was compiled with CPUS=%d.", CPUS);
      Print(4095, "  mt can not exceed this value.\n");
      shared->max_threads = CPUS;
    }
    if (shared->max_threads)
      Print(128, "max threads set to %d\n", shared->max_threads);
    else
      Print(128, "parallel threads disabled.\n");
    for (proc = 1; proc < CPUS; proc++)
      if (proc >= shared->max_threads)
        shared->thread[proc] = (TREE *) - 1;
  } else if (OptionMatch("smproot", *args)) {
    if (nargs < 2) {
      printf("usage:  smproot 0|1\n");
      return (1);
    }
    shared->split_at_root = atoi(args[1]);
    if (shared->split_at_root)
      Print(128, "SMP search split at ply >= 1\n");
    else
      Print(128, "SMP search split at ply > 1\n");
  }
/*
 ************************************************************
 *                                                          *
 *   "mn" command is used to set the move number to a       *
 *   specific value...                                      *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("mn", *args)) {
    if (nargs < 2) {
      printf("usage:  mn <number>\n");
      return (1);
    }
    shared->move_number = atoi(args[1]);
    Print(128, "move number set to %d\n", shared->move_number);
  }
/*
 ************************************************************
 *                                                          *
 *   "mode" command sets tournament mode or normal mode.    *
 *   tournament mode is used when crafty is in a "real"     *
 *   tournament.  it forces draw_score to 0, and makes      *
 *   crafty display the chess clock after each move.        *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("mode", *args)) {
    if (nargs > 1) {
      if (!strcmp(args[1], "tournament")) {
        mode = tournament_mode;
        printf("use 'settc' command if a game is restarted after crafty\n");
        printf("has been terminated for any reason.\n");
      } else if (!strcmp(args[1], "normal")) {
        mode = normal_mode;
        book_weight_learn = 1.0;
        book_weight_freq = 1.0;
        book_weight_eval = 0.5;
      } else if (!strcmp(args[1], "match")) {
        mode = normal_mode;
        book_weight_learn = 1.0;
        book_weight_freq = 0.2;
        book_weight_eval = 0.1;
      } else {
        printf("usage:  mode normal|tournament\n");
        mode = normal_mode;
        book_weight_learn = 1.0;
        book_weight_freq = 1.0;
        book_weight_eval = 0.5;
      }
    }
    if (mode == tournament_mode)
      printf("tournament mode.\n");
    else if (mode == normal_mode)
      printf("normal mode.\n");
  }
/*
 ************************************************************
 *                                                          *
 *   "name" command saves opponents name and writes it into *
 *   logfile along with the date/time.  it also scans the   *
 *   list of known computers and adjusts its opening book   *
 *   to play less "risky" if it matches.  if the opponent   *
 *   is in the GM list, it tunes the resignation controls   *
 *   to resign earlier.  ditto for other lists that are     *
 *   used to recognize specific opponents and adjust things *
 *   accordingly.                                           *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("name", *args)) {
    int i;
    char *next;

    if (nargs < 2) {
      printf("usage:  name <name>\n");
      return (1);
    }
    if (wtm) {
      strcpy(pgn_white, args[1]);
      sprintf(pgn_black, "Crafty %s", version);
    } else {
      strcpy(pgn_black, args[1]);
      sprintf(pgn_white, "Crafty %s", version);
    }
    Print(128, "Crafty %s vs %s\n", version, args[1]);
    next = args[1];
    while (*next) {
      *next = tolower(*next);
      next++;
    }
    if (mode != tournament_mode) {
      for (i = 0; i < 128; i++)
        if (AK_list[i] && !strcmp(AK_list[i], args[1])) {
          kibitz = 4;
          break;
        }
      for (i = 0; i < 128; i++)
        if (C_list[i] && !strcmp(C_list[i], args[1])) {
          Print(128, "playing a computer!\n");
          shared->computer_opponent = 1;
          book_selection_width = 1;
          usage_level = 0;
          break;
        }
      for (i = 0; i < 128; i++)
        if (GM_list[i] && !strcmp(GM_list[i], args[1])) {
          Print(128, "playing a GM!\n");
          book_selection_width = 3;
          resign = Min(6, resign);
          resign_count = 4;
          draw_count = 4;
          accept_draws = 1;
          kibitz = 0;
          break;
        }
      for (i = 0; i < 128; i++)
        if (IM_list[i] && !strcmp(IM_list[i], args[1])) {
          Print(128, "playing an IM!\n");
          book_selection_width = 4;
          resign = Min(9, resign);
          resign_count = 5;
          draw_count = 4;
          accept_draws = 1;
          kibitz = 0;
          break;
        }
      for (i = 0; i < 128; i++)
        if (SP_list[i] && !strcmp(SP_list[i], args[1])) {
          FILE *normal_bs_file = books_file;

          Print(128, "playing a special player!\n");
          if (SP_opening_filename[i]) {
            books_file = fopen(SP_opening_filename[i], "rb");
            if (!books_file) {
              Print(4095, "Error!  unable to open %s for player %s.\n",
                  SP_opening_filename[i], SP_list[i]);
              books_file = normal_bs_file;
            }
          }
          if (SP_personality_filename[i]) {
            sprintf(buffer, "personality load %s\n",
                SP_personality_filename[i]);
            (void) Option(tree);
          }
          break;
        }
    }
    printf("tellicsnoalias kibitz Hello from Crafty v%s! (%d cpus)\n", version,
        Max(1, shared->max_threads));
  }
/*
 ************************************************************
 *                                                          *
 *   "new" command initializes for a new game.              *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("new", *args)) {
    new_game = 1;
    if (shared->thinking || shared->pondering)
      return (3);
    if (shared->max_threads) {
      int proc;

      Print(128, "parallel threads terminated.\n");
      for (proc = 1; proc < CPUS; proc++)
        shared->thread[proc] = (TREE *) - 1;
      shared->smp_threads = 0;
    }
    NewGame(0);
    return (3);
  }
/*
 ************************************************************
 *                                                          *
 *   "noise" command sets a minimum limit on nodes searched *
 *   such that until this number of nodes has been searched *
 *   no program output will occur.  this is used to prevent *
 *   simple endgames from swamping the display device since *
 *   30+ ply searches are possible, which can produce 100's *
 *   of lines of output.                                    *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("noise", *args)) {
    if (nargs < 2) {
      printf("usage:  noise <n>\n");
      return (1);
    }
    shared->noise_level = atoi(args[1]);
    Print(128, "noise level set to %d.\n", shared->noise_level);
  }
/*
 ************************************************************
 *                                                          *
 *   "operator" command sets the operator time.  this time  *
 *   is the time per move that the operator needs.  it is   *
 *   multiplied by the number of moves left to time control *
 *   to reserve operator time.                              *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("operator", *args)) {
    if (nargs < 2) {
      printf("usage:  operator <seconds>\n");
      return (1);
    }
    shared->tc_operator_time = ParseTime(args[1]) * 100;
    Print(128, "reserving %d seconds per move for operator overhead.\n",
        shared->tc_operator_time / 100);
  }
/*
 ************************************************************
 *                                                          *
 *   "otime" command sets the opponent's time remaining.    *
 *   this is used to determine if the opponent is in time   *
 *   trouble, and is factored into the draw score if he is. *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("otime", *args)) {
    if (nargs < 2) {
      printf("usage:  otime <time(unit=.01 secs))>\n");
      return (1);
    }
    shared->tc_time_remaining_opponent = atoi(args[1]);
    if (log_file && shared->time_limit > 99)
      fprintf(log_file, "time remaining: %s (opponent).\n",
          DisplayTime(shared->tc_time_remaining_opponent));
    if (call_flag && xboard && shared->tc_time_remaining_opponent <= 1) {
      if (shared->crafty_is_white)
        Print(128, "1-0 {Black ran out of time}\n");
      else
        Print(128, "0-1 {White ran out of time}\n");
    }
  }
/*
 ************************************************************
 *                                                          *
 *   "output" command sets long or short algebraic output.  *
 *   long is Ng1f3, while short is simply Nf3.              *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("output", *args)) {
    if (nargs < 2) {
      printf("usage:  output long|short\n");
      return (1);
    }
    if (!strcmp(args[1], "long"))
      output_format = 1;
    else if (!strcmp(args[1], "short"))
      output_format = 0;
    else
      printf("usage:  output long|short\n");
    if (output_format == 1)
      Print(128, "output moves in long algebraic format\n");
    else if (output_format == 0)
      Print(128, "output moves in short algebraic format\n");
  }
/*
 ************************************************************
 *                                                          *
 *   "bookpath", "perspath", "logpath" and "tbpath" set the *
 *   default paths to locate or save these files.           *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("logpath", *args) || OptionMatch("perspath", *args)
      || OptionMatch("bookpath", *args) || OptionMatch("tbpath", *args)) {
    if (OptionMatch("logpath", *args) || OptionMatch("bookpath", *args)) {
      if (log_file)
        Print(4095, "ERROR -- this must be used on command line only\n");
    }
    nargs = ReadParse(buffer, args, " 	=");
    if (nargs < 2) {
      printf("usage:  bookpath|perspath|logpath|tbpath <path>\n");
      return (1);
    }
    if (!strchr(args[1], '(')) {
      if (strstr(args[0], "bookpath"))
        strcpy(book_path, args[1]);
      else if (strstr(args[0], "perspath"))
        strcpy(personality_path, args[1]);
      else if (strstr(args[0], "logpath"))
        strcpy(log_path, args[1]);
#if !defined(NOEGTB)
      else if (strstr(args[0], "tbpath"))
        strcpy(tb_path, args[1]);
#endif
    } else {
      if (strchr(args[1], ')')) {
        *strchr(args[1], ')') = 0;
        if (strstr(args[0], "bookpath"))
          strcpy(book_path, args[1] + 1);
        else if (strstr(args[0], "logpath"))
          strcpy(log_path, args[1] + 1);
#if !defined(NOEGTB)
        else if (strstr(args[0], "tbpath"))
          strcpy(tb_path, args[1] + 1);
#endif
      } else
        Print(4095, "ERROR multiple paths must be enclosed in ( and )\n");
    }
  }
/*
 ************************************************************
 *                                                          *
 *   "perf" command turns times move generator/make_move.   *
 *                                                          *
 ************************************************************
 */
#define PERF_CYCLES 4000000
  else if (OptionMatch("perf", *args)) {
    int i, *mv, clock_before, clock_after;
    float time_used;

    if (shared->thinking || shared->pondering)
      return (2);
    clock_before = clock();
    while (clock() == clock_before);
    clock_before = clock();
    for (i = 0; i < PERF_CYCLES; i++) {
      tree->last[1] = GenerateCaptures(tree, 0, wtm, tree->last[0]);
      tree->last[1] = GenerateNonCaptures(tree, 0, wtm, tree->last[1]);
    }
    clock_after = clock();
    time_used =
        ((float) clock_after - (float) clock_before) / (float) CLOCKS_PER_SEC;
    printf("generated %d moves, time=%.2f seconds\n",
        (int) (tree->last[1] - tree->last[0]) * PERF_CYCLES, time_used);
    printf("generated %d moves per second\n",
        (int) (((float) (PERF_CYCLES * (tree->last[1] -
                        tree->last[0]))) / time_used));
    clock_before = clock();
    while (clock() == clock_before);
    clock_before = clock();
    for (i = 0; i < PERF_CYCLES; i++) {
      tree->last[1] = GenerateCaptures(tree, 0, wtm, tree->last[0]);
      tree->last[1] = GenerateNonCaptures(tree, 0, wtm, tree->last[1]);
      for (mv = tree->last[0]; mv < tree->last[1]; mv++) {
        MakeMove(tree, 0, *mv, wtm);
        UnmakeMove(tree, 0, *mv, wtm);
      }
    }
    clock_after = clock();
    time_used =
        ((float) clock_after - (float) clock_before) / (float) CLOCKS_PER_SEC;
    printf("generated/made/unmade %d moves, time=%.2f seconds\n",
        (int) (tree->last[1] - tree->last[0]) * PERF_CYCLES, time_used);
    printf("generated/made/unmade %d moves per second\n",
        (int) (((float) (PERF_CYCLES * (tree->last[1] -
                        tree->last[0]))) / time_used));
  }
/*
 ************************************************************
 *                                                          *
 *   "perft" command turns tests move generator/make_move.  *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("perft", *args)) {
    int i, clock_before, clock_after;
    float time_used;

    if (shared->thinking || shared->pondering)
      return (2);
    clock_before = clock();
    while (clock() == clock_before);
    clock_before = clock();
    if (nargs < 2) {
      printf("usage:  perftest <depth>\n");
      return (1);
    }
    tree->position[1] = tree->position[0];
    tree->last[0] = tree->move_list;
    i = atoi(args[1]);
    if (i <= 0) {
      Print(128, "usage:  perft <maxply>\n");
      return (1);
    }
    total_moves = 0;
    OptionPerft(tree, 1, i, wtm);
    clock_after = clock();
    time_used =
        ((float) clock_after - (float) clock_before) / (float) CLOCKS_PER_SEC;
    printf("total moves=" BMF "  time=%.2f\n", total_moves, time_used);
  }
/*
 ************************************************************
 *                                                          *
 *   "personality" command is used to save or load a .cpf   *
 *   (crafty personality file).  the save option writes all *
 *   current evaluation paramenters, search extension       *
 *   paramenters, selective search parameters, etc., into a *
 *   file that can later be restored.  if you write to a    *
 *   file named "crafty.cpf" that will be the default       *
 *   settings everytime you start Crafty.                   *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("personality", *args)) {
    int i, j, k;

    nargs = ReadParse(buffer, args, " 	;=");
    if (!strcmp(args[1], "save")) {
      char filename[256];
      FILE *file;

      if (strchr(args[2], '/') == NULL) {
        strcpy(filename, personality_path);
        strcat(filename, "/");
        strcat(filename, args[2]);
      } else
        strcpy(filename, args[2]);
      if (!strstr(args[2], ".cpf"))
        strcat(filename, ".cpf");
      file = fopen(filename, "w");
      if (!file) {
        printf("ERROR.  Unable to open personality file %s for writing\n",
            args[2]);
        return (1);
      }
      printf("saving personality to file \"%s\"\n", filename);
      fprintf(file, "# Crafty v%s personality file\n", version);
      fprintf(file, "extension/onerep      %4.2f\n",
          (float) onerep_depth / PLY);
      fprintf(file, "extension/check       %4.2f\n",
          (float) incheck_depth / PLY);
      fprintf(file, "extension/mate        %4.2f\n", (float) mate_depth / PLY);
      fprintf(file, "selective             %d %d\n", null_min / PLY - 1,
          null_max / PLY - 1);
      for (i = 0; i < 256; i++) {
        if (!eval_packet[i].description)
          continue;
        if (eval_packet[i].value) {
          if (eval_packet[i].size == 0)
            fprintf(file, "evaluation %3d %7d", i, *eval_packet[i].value);
          else if (eval_packet[i].size > 0) {
            fprintf(file, "evaluation %3d ", i);
            for (j = 0; j < eval_packet[i].size; j++)
              fprintf(file, "%d ", eval_packet[i].value[j]);
          } else {
            fprintf(file, "evaluation %3d ", i);
            for (j = 0; j < 8; j++)
              for (k = 0; k < 8; k++)
                fprintf(file, "%d ", eval_packet[i].value[(7 - j) * 8 + k]);
          }
          fprintf(file, "  -> %s\n", eval_packet[i].description);
        }
      }
      fclose(file);
      return (1);
    }
    if (!strcmp(args[1], "load")) {
      FILE *file;
      char filename[256];
      char *readstat;

      if (strchr(args[2], '/') == NULL) {
        strcpy(filename, personality_path);
        strcat(filename, "/");
        strcat(filename, args[2]);
      } else
        strcpy(filename, args[2]);
      Print(128, "Loading personality file %s\n", filename);
      if ((file = fopen(filename, "rw"))) {
        silent = 1;
        while ((readstat = fgets(buffer, 512, file))) {
          char *delim;

          delim = strchr(buffer, '\n');
          if (delim)
            *delim = 0;
          delim = strstr(buffer, "->");
          if (delim)
            *delim = 0;
          delim = strchr(buffer, '\r');
          if (delim)
            *delim = ' ';
          (void) Option(tree);
        }
        silent = 0;;
        fclose(file);
      }
      return (1);
    }
  }
/*
 ************************************************************
 *                                                          *
 *   "pgn" command sets the various PGN header files.       *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("pgn", *args)) {
    int i;

    if (nargs < 3) {
      printf("usage:  pgn <tag> <value>\n");
      return (1);
    }
    if (!strcmp(args[1], "Event")) {
      pgn_event[0] = 0;
      for (i = 2; i < nargs; i++) {
        strcpy(pgn_event + strlen(pgn_event), args[i]);
        strcpy(pgn_event + strlen(pgn_event), " ");
      }
    } else if (!strcmp(args[1], "Site")) {
      pgn_site[0] = 0;
      for (i = 2; i < nargs; i++) {
        strcpy(pgn_site + strlen(pgn_site), args[i]);
        strcpy(pgn_site + strlen(pgn_site), " ");
      }
    } else if (!strcmp(args[1], "Round")) {
      pgn_round[0] = 0;
      strcpy(pgn_round, args[2]);
    } else if (!strcmp(args[1], "White")) {
      pgn_white[0] = 0;
      for (i = 2; i < nargs; i++) {
        strcpy(pgn_white + strlen(pgn_white), args[i]);
        strcpy(pgn_white + strlen(pgn_white), " ");
      }
    } else if (!strcmp(args[1], "WhiteElo")) {
      pgn_white_elo[0] = 0;
      strcpy(pgn_white_elo, args[2]);
    } else if (!strcmp(args[1], "Black")) {
      pgn_black[0] = 0;
      for (i = 2; i < nargs; i++) {
        strcpy(pgn_black + strlen(pgn_black), args[i]);
        strcpy(pgn_black + strlen(pgn_black), " ");
      }
    } else if (!strcmp(args[1], "BlackElo")) {
      pgn_black_elo[0] = 0;
      strcpy(pgn_black_elo, args[2]);
    }
  }
/*
 ************************************************************
 *                                                          *
 *   "ping" command simply echos the argument back to       *
 *   xboard to let it know all previous commands have been  *
 *   executed.                                              *
 *                                                          *
 ************************************************************
 */
  else if (!strcmp("ping", *args)) {
    if (shared->pondering) {
      Print(4095, "pong %s\n", args[1]);
    } else {
      pong = atoi(args[1]);
    }
  }
/*
 ************************************************************
 *                                                          *
 *   "playother" command says "position is set up, we are   *
 *   waiting on the opponent to move, ponder if you want to *
 *   do so.                                                 *
 *                                                          *
 ************************************************************
 */
  else if (!strcmp("playother", *args)) {
    force = 0;
  }
/*
 ************************************************************
 *                                                          *
 *   "ponder" command toggles pondering off/on or sets a    *
 *   move to ponder.                                        *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("ponder", *args)) {
    if (shared->thinking || shared->pondering)
      return (2);
    if (nargs < 2) {
      printf("usage:  ponder off|on|<move>\n");
      return (1);
    }
    if (!strcmp(args[1], "on")) {
      ponder = 1;
      Print(128, "pondering enabled.\n");
    } else if (!strcmp(args[1], "off")) {
      ponder = 0;
      Print(128, "pondering disabled.\n");
    } else {
      ponder_move = InputMove(tree, args[1], 0, wtm, 0, 0);
      last_pv.pathd = 0;
      last_pv.pathl = 0;
    }
  }
/*
 ************************************************************
 *                                                          *
 *   "post/nopost" command sets/resets "show thinking" mode *
 *   for xboard compatibility.                              *
 *                                                          *
 ************************************************************
 */
  else if (!strcmp("post", *args)) {
    post = 1;
  } else if (!strcmp("nopost", *args)) {
    post = 0;
  }
/*
 ************************************************************
 *                                                          *
 *   "protover" command is sent by xboard to identify the   *
 *   xboard protocol version and discover what the engine   *
 *   can handle.                                            *
 *                                                          *
 ************************************************************
 */
  else if (!strcmp("protover", *args)) {
    int pversion = atoi(args[1]);

    if (pversion >= 1 && pversion <= 3) {
      if (pversion >= 2) {
        Print(4095, "feature ping=1 setboard=1 san=1 time=1 draw=1\n");
        Print(4095, "feature sigint=0 sigterm=0 reuse=1 analyze=1\n");
        Print(4095, "feature myname=\"Crafty-%s\" name=1\n", version);
        Print(4095, "feature playother=1 colors=0\n");
        Print(4095, "feature variants=\"normal,nocastle\"\n");
        Print(4095, "feature done=1\n");
        done = 1;
      }
    } else
      Print(4095, "ERROR, bogus xboard protocol version received.\n");
  }
/*
 ************************************************************
 *                                                          *
 *  "random" command is ignored. [xboard compatibility]     *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("random", *args)) {
    return (xboard);
  }
/*
 ************************************************************
 *                                                          *
 *   "rating" is used by xboard to set crafty's rating and  *
 *   the opponent's rating, which is used by the learning   *
 *   functions.                                             *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("rating", *args)) {
    if (nargs < 3) {
      printf("usage:  rating <crafty> <opponent>\n");
      return (1);
    }
    crafty_rating = atoi(args[1]);
    opponent_rating = atoi(args[2]);
    if (crafty_rating == 0 && opponent_rating == 0) {
      crafty_rating = 2500;
      opponent_rating = 2300;
    }
    if (shared->computer_opponent)
      abs_draw_score = 1;
    else if (crafty_rating - opponent_rating < 0)
      abs_draw_score = +20;
    else if (crafty_rating - opponent_rating < 100)
      abs_draw_score = 1;
    else if (crafty_rating - opponent_rating < 300)
      abs_draw_score = -20;
    else if (crafty_rating - opponent_rating < 500)
      abs_draw_score = -30;
    else
      abs_draw_score = -50;
    if (log_file) {
      fprintf(log_file, "Crafty's rating: %d.\n", crafty_rating);
      fprintf(log_file, "opponent's rating: %d.\n", opponent_rating);
    }
  }
/*
 ************************************************************
 *                                                          *
 *   "reduce" command is used to set the various search     *
 *   reduction parameters.                                  *
 *                                                          *
 *   "mindepth" sub-option sets the min depth remaining     *
 *   required before a search depth reduction can be used.  *
 *                                                          *
 *   "value" sets the actual reduction depth, which is the  *
 *   amount the search depth will be decreased by, if the   *
 *   various reduction criteria are met.  this should be    *
 *   entered in units of 1/4th of a ply, which means that   *
 *   "fractional values" are allowed (value=2 is .5 plies,  *
 *   for example.)                                          *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("reduce", *args)) {
    if (nargs < 3) {
      printf("usage:  reduce option value\n");
      printf("current values are:\n");
      printf("reduce mindepth %3.1f\n", (float) reduce_min_depth / PLY);
      printf("reduce value    %3.1f\n", (float) reduce_value / PLY);
      return (1);
    }
    if (OptionMatch("mindepth", args[1]))
      reduce_min_depth = (int) atof(args[2]) * PLY + .1;
    else if (OptionMatch("value", args[1]))
      reduce_value = atoi(args[2]);
    Print(128, "current values are:\n");
    Print(128, "reduce mindepth %3.1f\n", (float) reduce_min_depth / PLY);
    Print(128, "reduce value    %3.1f\n", (float) reduce_value / PLY);
  }
/*
 ************************************************************
 *                                                          *
 *   "remove" command backs up the game one whole move,     *
 *   leaving the opponent still on move.  it's intended for *
 *   xboard compatibility, but works in any mode.           *
 *                                                          *
 ************************************************************
 */
  else if (!strcmp("remove", *args)) {
    if (shared->thinking || shared->pondering)
      return (2);
    shared->move_number--;
    sprintf(buffer, "reset %d", shared->move_number);
    (void) Option(tree);
  }
/*
 ************************************************************
 *                                                          *
 *   "reset" restores (backs up) a game to a prior position *
 *   with the same side on move.  reset 17 would reset the  *
 *   position to what it was at move 17.                    *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("reset", *args)) {
    int i, move, nmoves;

    if (shared->thinking || shared->pondering)
      return (2);
    if (nargs < 2) {
      printf("usage:  reset <movenumber>\n");
      return (1);
    }
    ponder_move = 0;
    last_mate_score = 0;
    last_pv.pathd = 0;
    last_pv.pathl = 0;
    if (shared->thinking || shared->pondering)
      return (2);
    over = 0;
    shared->move_number = atoi(args[1]);
    if (!shared->move_number) {
      shared->move_number = 1;
      return (1);
    }
    nmoves = (shared->move_number - 1) * 2 + 1 - wtm;
    shared->root_wtm = Flip(wtm);
    InitializeChessBoard(&tree->position[0]);
    wtm = 1;
    shared->move_number = 1;
    for (i = 0; i < nmoves; i++) {
      fseek(history_file, i * 10, SEEK_SET);
      fscanf(history_file, "%s", buffer);
/*
 If the move is "pass", that means that the side on move passed.
 This includes the case where the game started from a black-to-move
 position; then white's first move is recorded as a pass.
 */
      if (strcmp(buffer, "pass") == 0) {
        wtm = Flip(wtm);
        if (wtm)
          shared->move_number++;
        continue;
      }
      move = InputMove(tree, buffer, 0, wtm, 0, 0);
      if (move) {
        MakeMoveRoot(tree, move, wtm);
      } else {
        printf("ERROR!  move %s is illegal\n", buffer);
        break;
      }
      wtm = Flip(wtm);
      if (wtm)
        shared->move_number++;
    }
    shared->moves_out_of_book = 0;
    shared->tc_moves_remaining = shared->tc_moves - shared->move_number + 1;
    while (shared->tc_moves_remaining <= 0 && shared->tc_secondary_moves)
      shared->tc_moves_remaining += shared->tc_secondary_moves;
    printf("NOTICE: %d moves to next time control\n",
        shared->tc_moves_remaining);
  }
/*
 ************************************************************
 *                                                          *
 *   "read" reads game moves in and makes them.  this can   *
 *   be used in two ways:  (1) type "read" and then start   *
 *   entering moves;  type "exit" when done;  (2) type      *
 *   "read <filename>" to read moves in from <filename>.    *
 *   note that read will attempt to skip over "non-move"    *
 *   text and try to extract moves if it can.               *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("read", *args) || OptionMatch("reada", *args)) {
    int append, move, readstat;
    FILE *read_input = 0;

    if (shared->thinking || shared->pondering)
      return (2);
    nargs = ReadParse(buffer, args, " 	=");
    if (!strcmp("reada", *args))
      append = 1;
    else
      append = 0;
    ponder_move = 0;
    last_pv.pathd = 0;
    last_pv.pathl = 0;
    if (nargs > 1) {
      if (!(read_input = fopen(args[1], "r"))) {
        printf("file %s does not exist.\n", args[1]);
        return (1);
      }
    } else {
      printf("type \"exit\" to terminate.\n");
      read_input = stdin;
    }
    if (!append) {
      InitializeChessBoard(&tree->position[0]);
      wtm = 1;
      shared->move_number = 1;
    }
/*
 step 1:  read in the PGN tags.
 */
    readstat = ReadPGN(0, 0);
    do {
      if (read_input == stdin) {
        if (wtm)
          printf("read.White(%d): ", shared->move_number);
        else
          printf("read.Black(%d): ", shared->move_number);
        fflush(stdout);
      }
      readstat = ReadPGN(read_input, 0);
    } while (readstat == 1);
    if (readstat < 0)
      return (1);
/*
 step 2:  read in the moves.
 */
    do {
      move = 0;
      move = ReadNextMove(tree, buffer, 0, wtm);
      if (move) {
        if (read_input != stdin) {
          printf("%s ", OutputMove(tree, move, 0, wtm));
          if (!(shared->move_number % 8) && Flip(wtm))
            printf("\n");
        }
        fseek(history_file, ((shared->move_number - 1) * 2 + 1 - wtm) * 10,
            SEEK_SET);
        fprintf(history_file, "%9s\n", OutputMove(tree, move, 0, wtm));
        MakeMoveRoot(tree, move, wtm);
#if defined(DEBUG)
        ValidatePosition(tree, 1, move, "Option()");
#endif
      } else if (!read_input)
        printf("illegal move.\n");
      if (move) {
        wtm = Flip(wtm);
        if (wtm)
          shared->move_number++;
      }
      if (read_input == stdin) {
        if (wtm)
          printf("read.White(%d): ", shared->move_number);
        else
          printf("read.Black(%d): ", shared->move_number);
        fflush(stdout);
      }
      readstat = ReadPGN(read_input, 0);
      if (readstat < 0)
        break;
      if (!strcmp(buffer, "exit"))
        break;
    } while (1);
    shared->moves_out_of_book = 0;
    shared->tc_moves_remaining = shared->tc_moves - shared->move_number + 1;
    while (shared->tc_moves_remaining <= 0 && shared->tc_secondary_moves)
      shared->tc_moves_remaining += shared->tc_secondary_moves;
    printf("NOTICE: %d moves to next time control\n",
        shared->tc_moves_remaining);
    shared->root_wtm = !wtm;
    if (read_input != stdin) {
      printf("\n");
      fclose(read_input);
    }
  }
/*
 ************************************************************
 *                                                          *
 *   "rejected" handles the new xboard protocol version 2   *
 *   accepted command.                                      *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("rejected", *args)) {
    Print(4095, "ERROR.  feature %s rejected by xboard\n", args[1]);
  }
/*
 ************************************************************
 *                                                          *
 *   "resign" command sets the resignation threshold to     *
 *   the number of pawns the program must be behind before  *
 *   resigning (0 -> disable resignations).  resign with no *
 *   arguments will mark the pgn result as lost by the      *
 *   opponent.                                              *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("resign", *args)) {
    if (nargs < 2) {
      if (shared->crafty_is_white) {
        Print(4095, "result 1-0\n");
        strcpy(pgn_result, "1-0");
      } else {
        Print(4095, "result 0-1\n");
        strcpy(pgn_result, "0-1");
      }
      return (1);
    }
    resign = atoi(args[1]);
    if (nargs == 3)
      resign_count = atoi(args[2]);
    if (resign)
      Print(128, "resign after %d consecutive moves with score < %d.\n",
          resign_count, -resign);
    else
      Print(128, "disabled resignations.\n");
  }
/*
 ************************************************************
 *                                                          *
 *   "result" command comes from xboard/winboard and gives  *
 *   the result of the current game.  if learning routines  *
 *   have not yet been activated, this will do it.          *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("result", *args)) {
    if (nargs > 1) {
      if (!strcmp(args[1], "1-0")) {
        strcpy(pgn_result, "1-0");
        if (!shared->crafty_is_white)
          LearnBook(tree, wtm, 300, 0, 1, 2);
        else
          LearnBook(tree, wtm, -300, 0, 1, 2);
      } else if (!strcmp(args[1], "0-1")) {
        strcpy(pgn_result, "0-1");
        if (shared->crafty_is_white)
          LearnBook(tree, wtm, -300, 0, 1, 2);
        else
          LearnBook(tree, wtm, 300, 0, 1, 2);
      } else if (!strcmp(args[1], "1/2-1/2")) {
        strcpy(pgn_result, "1/2-1/2");
        LearnBook(tree, wtm, 0, 0, 1, 2);
      }
      return (1);
    }
  }
/*
 ************************************************************
 *                                                          *
 *   "savegame" command saves the game in a file in PGN     *
 *   format.  command has an optional filename.             *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("savegame", *args)) {
    struct tm *timestruct;
    int i, more, swtm;
    time_t secs;
    FILE *output_file;
    char input[128], text[128], *next;

    output_file = stdout;
    secs = time(0);
    timestruct = localtime((time_t *) & secs);
    if (nargs > 1) {
      if (!(output_file = fopen(args[1], "w"))) {
        printf("unable to open %s for write.\n", args[1]);
        return (1);
      }
    }
    fprintf(output_file, "[Event \"%s\"]\n", pgn_event);
    fprintf(output_file, "[Site \"%s\"]\n", pgn_site);
    fprintf(output_file, "[Date \"%4d.%02d.%02d\"]\n",
        timestruct->tm_year + 1900, timestruct->tm_mon + 1,
        timestruct->tm_mday);
    fprintf(output_file, "[Round \"%s\"]\n", pgn_round);
    fprintf(output_file, "[White \"%s\"]\n", pgn_white);
    fprintf(output_file, "[WhiteElo \"%s\"]\n", pgn_white_elo);
    fprintf(output_file, "[Black \"%s\"]\n", pgn_black);
    fprintf(output_file, "[BlackElo \"%s\"]\n", pgn_black_elo);
    fprintf(output_file, "[Result \"%s\"]\n", pgn_result);
/* Handle setup positions and initial pass by white */
    swtm = 1;
    if (shared->move_number > 1 || !wtm) {
      fseek(history_file, 0, SEEK_SET);
      if (fscanf(history_file, "%s", input) == 1 && strcmp(input, "pass") == 0)
        swtm = 0;
    }
    if (initial_position[0])
      fprintf(output_file, "[FEN \"%s\"]\n[SetUp \"1\"]\n", initial_position);
    else if (!swtm) {
      fprintf(output_file,
          "[FEN \"rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR b KQkq - 0 1\"\n"
          "[SetUp \"1\"]\n");
    }
    fprintf(output_file, "\n");
    next = text;
    if (!swtm) {
      strcpy(next, "1... ");
      next = text + strlen(text);
    }
/* Output the moves */
    more = 0;
    for (i = (swtm ? 0 : 1); i < (shared->move_number - 1) * 2 - wtm + 1; i++) {
      fseek(history_file, i * 10, SEEK_SET);
      fscanf(history_file, "%s", input);
      if (!(i % 2)) {
        sprintf(next, "%d. ", i / 2 + 1);
        next = text + strlen(text);
      }
      sprintf(next, "%s ", input);
      next = text + strlen(text);
      more = 1;
      if (next - text >= 60) {
        fprintf(output_file, "%s\n", text);
        more = 0;
        next = text;
      }
    }
    if (more)
      fprintf(output_file, "%s", text);
    fprintf(output_file, "%s\n", pgn_result);
    if (output_file != stdout)
      fclose(output_file);
    printf("PGN save complete.\n");
  }
/*
 ************************************************************
 *                                                          *
 *   "savepos" command saves the current position in a FEN  *
 *   (Forsythe notation) string that can be later used to   *
 *   recreate this exact position.                          *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("savepos", *args)) {
    int rank, file, nempty;
    FILE *output_file;

    output_file = stdout;
    if (nargs > 1) {
      if (!strcmp(args[1], "*")) {
        output_file = 0;
        strcpy(initial_position, "");
      } else if (!(output_file = fopen(args[1], "w"))) {
        printf("unable to open %s for write.\n", args[1]);
        return (1);
      }
    }
    if (output_file)
      fprintf(output_file, "setboard ");
    for (rank = RANK8; rank >= RANK1; rank--) {
      nempty = 0;
      for (file = FILEA; file <= FILEH; file++) {
        if (PcOnSq((rank << 3) + file)) {
          if (nempty) {
            if (output_file)
              fprintf(output_file, "%c", empty[nempty]);
            else
              sprintf(initial_position + strlen(initial_position), "%c",
                  empty[nempty]);
            nempty = 0;
          }
          if (output_file)
            fprintf(output_file, "%c", xlate[PcOnSq((rank << 3) + file) + 7]);
          else
            sprintf(initial_position + strlen(initial_position), "%c",
                xlate[PcOnSq((rank << 3) + file) + 7]);
        } else
          nempty++;
      }
      if (empty[nempty]) {
        if (output_file)
          fprintf(output_file, "%c", empty[nempty]);
        else
          sprintf(initial_position + strlen(initial_position), "%c",
              empty[nempty]);
      }
      if (rank != RANK1) {
        if (output_file)
          fprintf(output_file, "/");
        else
          sprintf(initial_position + strlen(initial_position), "/");
      }
    }
    if (output_file)
      fprintf(output_file, " %c ", (wtm) ? 'w' : 'b');
    else
      sprintf(initial_position + strlen(initial_position), " %c ",
          (wtm) ? 'w' : 'b');
    if (WhiteCastle(0) & 1) {
      if (output_file)
        fprintf(output_file, "K");
      else
        sprintf(initial_position + strlen(initial_position), "K");
    }
    if (WhiteCastle(0) & 2) {
      if (output_file)
        fprintf(output_file, "Q");
      else
        sprintf(initial_position + strlen(initial_position), "Q");
    }
    if (BlackCastle(0) & 1) {
      if (output_file)
        fprintf(output_file, "k");
      else
        sprintf(initial_position + strlen(initial_position), "k");
    }
    if (BlackCastle(0) & 2) {
      if (output_file)
        fprintf(output_file, "q");
      else
        sprintf(initial_position + strlen(initial_position), "q");
    }
    if (!WhiteCastle(0) && !BlackCastle(0)) {
      if (output_file)
        fprintf(output_file, " -");
      else
        sprintf(initial_position + strlen(initial_position), " -");
    }
    if (EnPassant(0)) {
      if (output_file)
        fprintf(output_file, " %c%c", File(EnPassant(0)) + 'a',
            Rank(EnPassant(0)) + '1');
      else
        sprintf(initial_position + strlen(initial_position), " %c%c",
            File(EnPassant(0)) + 'a', Rank(EnPassant(0)) + '1');
    }
    if (output_file)
      fprintf(output_file, "\n");
    if (output_file && output_file != stdout) {
      fprintf(output_file, "exit\n");
      fclose(output_file);
    }
    if (output_file)
      printf("FEN save complete.\n");
  }
/*
 ************************************************************
 *                                                          *
 *   "search" command sets a specific move for the search   *
 *   to analyze, ignoring all others completely.            *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("search", *args)) {
    if (shared->thinking || shared->pondering)
      return (2);
    if (nargs < 2) {
      printf("usage:  search <move>\n");
      return (1);
    }
    search_move = InputMove(tree, args[1], 0, wtm, 0, 0);
    if (!search_move)
      search_move = InputMove(tree, args[1], 0, Flip(wtm), 0, 0);
    if (!search_move)
      printf("illegal move.\n");
  }
/*
 ************************************************************
 *                                                          *
 *   "selective" command sets the mininum and maximum null- *
 *   move search depths (default=2 and 3 respectively).     *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("selective", *args)) {
    if (nargs < 3) {
      Print(128, "usage: selective min max\n");
    } else {
      null_min = (atoi(args[1]) + 1) * PLY;
      null_max = (atoi(args[2]) + 1) * PLY;
      if (null_min == PLY)
        null_min = 0;
      if (null_max == PLY)
        null_max = 0;
    }
    if (!silent) {
      if (null_min + null_max)
        Print(128, "null depth set to %d/%d (min/max)\n", null_min / PLY - 1,
            null_max / PLY - 1);
      else
        Print(128, "null move disabled.\n");
    }
  }
/*
 ************************************************************
 *                                                          *
 *   "settc" command is used to reset the time controls     *
 *   after a complete restart.                              *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("settc", *args)) {
    if (shared->thinking || shared->pondering)
      return (2);
    if (nargs < 4) {
      printf("usage:  settc <moves> <ctime> <otime>\n");
      return (1);
    }
    shared->tc_moves_remaining = atoi(args[1]);
    shared->tc_time_remaining = ParseTime(args[2]) * 6000;
    shared->tc_time_remaining_opponent = ParseTime(args[3]) * 6000;
    Print(128, "time remaining: %s (crafty).\n",
        DisplayTime(shared->tc_time_remaining));
    Print(128, "time remaining: %s (opponent).\n",
        DisplayTime(shared->tc_time_remaining_opponent));
    if (shared->tc_sudden_death != 1)
      Print(128, "%d moves to next time control (Crafty)\n",
          shared->tc_moves_remaining);
    else
      Print(128, "Sudden-death time control in effect\n");
  }
/*
 ************************************************************
 *                                                          *
 *   "setboard" command sets the board to a specific        *
 *   position for analysis by the program.                  *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("setboard", *args)) {
    if (shared->thinking || shared->pondering)
      return (2);
    nargs = ReadParse(buffer, args, " 	;=");
    SetBoard(&tree->position[0], nargs - 1, args + 1, 0);
    shared->move_number = 1;
    if (!wtm) {
      wtm = 1;
      Pass();
    }
    ponder_move = 0;
    last_pv.pathd = 0;
    last_pv.pathl = 0;
    over = 0;
    strcpy(buffer, "savepos *");
    (void) Option(tree);
  } else if (StrCnt(*args, '/') > 3) {
    if (shared->thinking || shared->pondering)
      return (2);
    nargs = ReadParse(buffer, args, " 	;=");
    SetBoard(&tree->position[0], nargs, args, 0);
    shared->move_number = 1;
    if (!wtm) {
      wtm = 1;
      Pass();
    }
    ponder_move = 0;
    last_pv.pathd = 0;
    last_pv.pathl = 0;
    over = 0;
    strcpy(buffer, "savepos *");
    (void) Option(tree);
  }
/*
 ************************************************************
 *                                                          *
 *   "score" command displays static evaluation of the      *
 *   current board position.                                *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("score", *args)) {
    int s1, s2 = 0, s3 = 0, s4 = 0, s5 = 0, s6 = 0, s7 = 0;
    int a, n, b, r, q, k;

    if (shared->thinking || shared->pondering)
      return (2);
    shared->root_wtm = Flip(wtm);
    tree->position[1] = tree->position[0];
    PreEvaluate(tree);
    s7 = Evaluate(tree, 1, wtm, -99999, 99999);
    if (!wtm)
      s7 = -s7;
    s1 = EvaluateMaterial(tree);
    if (BlackCastle(1))
      s2 = EvaluateDevelopmentB(tree, 1);
    if (WhiteCastle(1))
      s2 += EvaluateDevelopmentW(tree, 1);
    if (TotalWhitePawns + TotalBlackPawns) {
      s3 = EvaluatePawns(tree);
      if (tree->pawn_score.passed_b || tree->pawn_score.passed_w ||
          tree->pawn_score.candidates_b || tree->pawn_score.candidates_w) {
        s4 = EvaluatePassedPawns(tree, wtm);
        s5 = EvaluatePassedPawnRaces(tree, wtm);
      }
    }
    s6 = EvaluateMobility(tree);
    tree->w_tropism = 0;
    tree->b_tropism = 0;
    a = EvaluateAll(tree);
    n = EvaluateKnights(tree);
    b = EvaluateBishops(tree);
    r = EvaluateRooks(tree);
    q = EvaluateQueens(tree);
    k = EvaluateKings(tree, wtm, 1);
    Print(128, "note: scores are for the white side\n");
    Print(128, "material evaluation.................%s\n", DisplayEvaluation(s1,
            1));
    Print(128, "development.........................%s\n", DisplayEvaluation(s2,
            1));
    Print(128, "pawn evaluation.....................%s\n", DisplayEvaluation(s3,
            1));
    Print(128, "passed pawn evaluation..............%s",
        DisplayEvaluation(ScaleEG(s4), 1));
    Print(128, " (%.2f)\n", (float) s4 / 100.0);
    Print(128, "passed pawn race evaluation.........%s\n", DisplayEvaluation(s5,
            1));
    Print(128, "knight evaluation...................%s\n", DisplayEvaluation(n,
            1));
    Print(128, "bishop evaluation...................%s\n", DisplayEvaluation(b,
            1));
    Print(128, "rook evaluation.....................%s\n", DisplayEvaluation(r,
            1));
    Print(128, "queen evaluation....................%s\n", DisplayEvaluation(q,
            1));
    Print(128, "king evaluation.....................%s\n", DisplayEvaluation(k,
            1));
    Print(128, "mobility evaluation.................%s\n", DisplayEvaluation(s6,
            1));
    Print(128, "combined evaluation.................%s\n", DisplayEvaluation(a,
            1));
    Print(128, "total evaluation....................%s\n", DisplayEvaluation(s7,
            1));
  }
/*
 ************************************************************
 *                                                          *
 *   "sd" command sets a specific search depth to control   *
 *   the tree search depth.                                 *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("sd", *args)) {
    if (nargs < 2) {
      printf("usage:  sd <depth>\n");
      return (1);
    }
    search_depth = atoi(args[1]);
    Print(128, "search depth set to %d.\n", search_depth);
  }
/*
 ************************************************************
 *                                                          *
 *   "show" command enables/disables various display        *
 *   such as "show extensions" which adds a character to    *
 *   each pv move showing if/why it was extended.           *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("show", *args)) {
    if (nargs < 2) {
      printf("usage:  show book\n");
      return (1);
    }
    if (OptionMatch("book", args[1])) {
      show_book = !show_book;
      if (show_book)
        Print(128, "show book statistics\n");
      else
        Print(128, "don't show book statistics\n");
    }
  }
/*
 ************************************************************
 *                                                          *
 *   "sn" command sets a specific number of nodes to search *
 *   before stopping.                                       *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("sn", *args)) {
    if (nargs < 2) {
      printf("usage:  sn <nodes>\n");
      return (1);
    }
    search_nodes = atoi(args[1]);
    Print(128, "search nodes set to %d.\n", search_nodes);
    ponder = 0;
  }
/*
 ************************************************************
 *                                                          *
 *   "speech" command turns speech on/off.                  *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("speech", *args)) {
    if (nargs < 2) {
      printf("usage:  speech on|off\n");
      return (1);
    }
    if (!strcmp(args[1], "on"))
      speech = 1;
    else if (!strcmp(args[1], "off"))
      speech = 0;
    if (speech)
      Print(4095, "Audio output enabled\n");
    else
      Print(4095, "Audio output disabled\n");
  }
/*
 ************************************************************
 *                                                          *
 *   "st" command sets a specific search time to control    *
 *   the tree search time.                                  *
 *                                                          *
 ************************************************************
 */
  else if (!strcmp("st", *args)) {
    if (nargs < 2) {
      printf("usage:  st <time>\n");
      return (1);
    }
    shared->search_time_limit = atof(args[1]) * 100;
    Print(128, "search time set to %.2f.\n",
        (float) shared->search_time_limit / 100.0);
  }
/*
 ************************************************************
 *                                                          *
 *   "surplus" command sets a specific time surplus target  *
 *   for normal tournament games.                           *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("surplus", *args)) {
    if (nargs == 2)
      shared->tc_safety_margin = atoi(args[1]) * 6000;
    Print(128, "time surplus set to %s.\n",
        DisplayTime(shared->tc_safety_margin));
  }
/*
 ************************************************************
 *                                                          *
 *   "swindle" command turns swindle mode off/on.           *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("swindle", *args)) {
    if (!strcmp(args[1], "on"))
      swindle_mode = 1;
    else if (!strcmp(args[1], "off"))
      swindle_mode = 0;
    else
      printf("usage:  swindle on|off\n");
  }
/*
 ************************************************************
 *                                                          *
 *   "tags" command lists the current PGN header tags.      *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("tags", *args)) {
    struct tm *timestruct;
    long secs;

    secs = time(0);
    timestruct = localtime((time_t *) & secs);
    printf("[Event \"%s\"]\n", pgn_event);
    printf("[Site \"%s\"]\n", pgn_site);
    printf("[Date \"%4d.%02d.%02d\"]\n", timestruct->tm_year + 1900,
        timestruct->tm_mon + 1, timestruct->tm_mday);
    printf("[Round \"%s\"]\n", pgn_round);
    printf("[White \"%s\"]\n", pgn_white);
    printf("[WhiteElo \"%s\"]\n", pgn_white_elo);
    printf("[Black \"%s\"]\n", pgn_black);
    printf("[BlackElo \"%s\"]\n", pgn_black_elo);
    printf("[Result \"%s\"]\n", pgn_result);
  }
/*
 ************************************************************
 *                                                          *
 *   "test" command runs a test suite of problems and       *
 *   prints results.                                        *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("test", *args)) {
    nargs = ReadParse(buffer, args, "	 ;=");
    if (shared->thinking || shared->pondering)
      return (2);
    if (nargs < 2) {
      printf("usage:  test <filename> [exitcnt]\n");
      return (1);
    }
    if (nargs > 2)
      early_exit = atoi(args[2]);
    Test(args[1]);
    ponder_move = 0;
    last_pv.pathd = 0;
    last_pv.pathl = 0;
  }
/*
 ************************************************************
 *                                                          *
 *   "time" controls whether the program uses cpu time or   *
 *   wall-clock time for timing.  for tournament play,      *
 *   it is safer to use wall-clock timing, for testing it   *
 *   may be more consistent to use cpu timing if the        *
 *   machine is used for other things concurrently with the *
 *   tests being run.                                       *
 *                                                          *
 *   "time" is also used to set the basic search timing     *
 *   controls.  the general form of the command is as       *
 *   follows:                                               *
 *                                                          *
 *     time nmoves/ntime/[nmoves/ntime]/[increment]         *
 *                                                          *
 *   nmoves/ntime represents a traditional first time       *
 *   control when nmoves is an integer representing the     *
 *   number of moves and ntime is the total time allowed    *
 *   for these moves.  the [optional] nmoves/ntime is a     *
 *   traditional secondary time control.  increment is a    *
 *   feature related to ics play and emulates the fischer   *
 *   clock where "increment" is added to the time left      *
 *   after each move is made.                               *
 *                                                          *
 *   as an alternative, nmoves can be "sd" which represents *
 *   a "sudden death" time control of the remainder of the  *
 *   game played in ntime.  the optional secondary time     *
 *   control can be a sudden-death time control, as in the  *
 *   following example:                                     *
 *                                                          *
 *     time 60/30/sd/30                                     *
 *                                                          *
 *   this sets 60 moves in 30 minutes, then game in 30      *
 *   additional minutes.  an increment can be added if      *
 *   desired.                                               *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("time", *args)) {
    if (ics || xboard) {
      shared->tc_time_remaining = atoi(args[1]);
      if (log_file && shared->time_limit > 99)
        fprintf(log_file, "time remaining: %s (crafty).\n",
            DisplayTime(shared->tc_time_remaining));
    } else {
      if (shared->thinking || shared->pondering)
        return (2);
      shared->tc_moves = 60;
      shared->tc_time = 180000;
      shared->tc_moves_remaining = 60;
      shared->tc_time_remaining = 180000;
      shared->tc_time_remaining_opponent = 180000;
      shared->tc_secondary_moves = 60;
      shared->tc_secondary_time = 180000;
      shared->tc_increment = 0;
      shared->tc_sudden_death = 0;
/*
 first let's pick off the basic time control (moves/minutes)
 */
      if (nargs > 1)
        if (!strcmp(args[1], "sd")) {
          shared->tc_sudden_death = 1;
          shared->tc_moves = 1000;
        }
      if (nargs > 2) {
        shared->tc_moves = atoi(args[1]);
        shared->tc_time = atoi(args[2]) * 100;
      }
/*
 now let's pick off the secondary time control (moves/minutes)
 */
      shared->tc_secondary_time = shared->tc_time;
      shared->tc_secondary_moves = shared->tc_moves;
      if (nargs > 4) {
        if (!strcmp(args[3], "sd")) {
          shared->tc_sudden_death = 2;
          shared->tc_secondary_moves = 1000;
        } else
          shared->tc_secondary_moves = atoi(args[3]);
        shared->tc_secondary_time = atoi(args[4]) * 100;
      }
      if (nargs > 5)
        shared->tc_increment = atoi(args[5]) * 100;
      shared->tc_time_remaining = shared->tc_time;
      shared->tc_time_remaining_opponent = shared->tc_time;
      shared->tc_moves_remaining = shared->tc_moves;
      if (!shared->tc_sudden_death) {
        Print(128, "%d moves/%d minutes primary time control\n",
            shared->tc_moves, shared->tc_time / 100);
        Print(128, "%d moves/%d minutes secondary time control\n",
            shared->tc_secondary_moves, shared->tc_secondary_time / 100);
        if (shared->tc_increment)
          Print(128, "increment %d seconds.\n", shared->tc_increment / 100);
      } else if (shared->tc_sudden_death == 1) {
        Print(128, " game/%d minutes primary time control\n",
            shared->tc_time / 100);
        if (shared->tc_increment)
          Print(128, "increment %d seconds.\n", shared->tc_increment / 100);
      } else if (shared->tc_sudden_death == 2) {
        Print(128, "%d moves/%d minutes primary time control\n",
            shared->tc_moves, shared->tc_time / 100);
        Print(128, "game/%d minutes secondary time control\n",
            shared->tc_secondary_time / 100);
        if (shared->tc_increment)
          Print(128, "increment %d seconds.\n", shared->tc_increment / 100);
      }
      shared->tc_time *= 60;
      shared->tc_time_remaining *= 60;
      shared->tc_time_remaining_opponent *= 60;
      shared->tc_secondary_time *= 60;
      shared->tc_safety_margin = shared->tc_time / 6;
    }
  }
/*
 ************************************************************
 *                                                          *
 *   "timebook" command is used to adjust Crafty's time     *
 *   usage after it leaves the opening book.  the first     *
 *   value specifies the multiplier for the time added to   *
 *   the first move out of book expressed as a percentage   *
 *   (100 is 100% for example).  the second value specifies *
 *   the "span" (number of moves) that this multiplier      *
 *   decays over.  for example, "timebook 100 10" says to   *
 *   add 100% of the normal search time for the first move  *
 *   out of book, then 90% for the next, until after 10     *
 *   non-book moves have been played, the percentage has    *
 *   dropped back to 0 where it will stay for the rest of   *
 *   the game.                                              *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("timebook", *args)) {
    if (nargs < 3) {
      printf("usage:  timebook <percentage> <move span>\n");
      return (1);
    }
    shared->first_nonbook_factor = atoi(args[1]);
    shared->first_nonbook_span = atoi(args[2]);
    if (shared->first_nonbook_factor < 0 || shared->first_nonbook_factor > 500) {
      Print(4095, "ERROR, factor must be >= 0 and <= 500\n");
      shared->first_nonbook_factor = 0;
    }
    if (shared->first_nonbook_span < 0 || shared->first_nonbook_span > 30) {
      Print(4095, "ERROR, span must be >= 0 and <= 30\n");
      shared->first_nonbook_span = 0;
    }
  }
/*
 ************************************************************
 *                                                          *
 *   "timeleft" command comes from the custom ICS interface *
 *   and indicates how much time is left for white and for  *
 *   black.                                                 *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("timeleft", *args)) {
    if (nargs < 3) {
      printf("usage:  timeleft <wtime> <btime>\n");
      return (1);
    }
    if (shared->crafty_is_white) {
      shared->tc_time_remaining = atoi(args[1]) * 100;
      shared->tc_time_remaining_opponent = atoi(args[2]) * 100;
    } else {
      shared->tc_time_remaining_opponent = atoi(args[1]) * 100;
      shared->tc_time_remaining = atoi(args[2]) * 100;
    }
    if (log_file) {
      fprintf(log_file, "time remaining: %s (crafty).\n",
          DisplayTime(shared->tc_time_remaining));
      fprintf(log_file, "time remaining: %s (opponent).\n",
          DisplayTime(shared->tc_time_remaining_opponent));
    }
  }
/*
 ************************************************************
 *                                                          *
 *   "trace" command sets the search trace level which will *
 *   dump the tree as it is searched.                       *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("trace", *args)) {
#if !defined(TRACE)
    printf("Sorry, but I can't display traces unless compiled with -DTRACE\n");
#endif
    if (nargs < 2) {
      printf("usage:  trace <depth>\n");
      return (1);
    }
    trace_level = atoi(args[1]);
    printf("trace=%d\n", trace_level);
  }
/*
 ************************************************************
 *                                                          *
 *   "tt" command is used to test time control logic.       *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("tt", *args)) {
    int time_used;

    do {
      TimeSet(think);
      printf("time used? ");
      fflush(stdout);
      fgets(buffer, 128, stdin);
      time_used = atoi(buffer);
      if (time_used == 0)
        time_used = shared->time_limit;
      TimeAdjust(time_used, opponent);
      TimeAdjust(time_used, crafty);
      sprintf(buffer, "clock");
      (void) Option(tree);
      shared->move_number++;
    } while (time_used >= 0);
  }
/*
 ************************************************************
 *                                                          *
 *   "undo" command backs up 1/2 move, which leaves the     *
 *   opposite side on move. [xboard compatibility]          *
 *                                                          *
 ************************************************************
 */
  else if (!strcmp("undo", *args)) {
    if (shared->thinking || shared->pondering)
      return (2);
    if (!wtm || shared->move_number != 1) {
      wtm = Flip(wtm);
      if (Flip(wtm))
        shared->move_number--;
      sprintf(buffer, "reset %d", shared->move_number);
      (void) Option(tree);
    }
  }
/*
 *****************************************************************
 *                                                               *
 *   "usage" command controls the time usage multiple factors    *
 *  used in the game  - percntage increase or decrease in time   *
 *  used up front.  Enter a number between 1 to 100 for the      *
 *  % decrease to increase - although other time limitations     !
 * controls may kick in.  negatives work as well, may be used    *
 * in crafty.rc                                                  *
 *                                                               *
 *****************************************************************
 */
  else if (OptionMatch("usage", *args)) {
    if (nargs < 2) {
      printf("usage:  usage <percentage>\n");
      return (1);
    }
    usage_level = atoi(args[1]);
    if (usage_level > 50)
      usage_level = 50;
    else if (usage_level < -50)
      usage_level = -50;
    Print(128, "time usage up front set to %d percent increase/(-)decrease.\n",
        usage_level);
  }
/*
 ************************************************************
 *                                                          *
 *   "variant" command sets the wild variant being played   *
 *   on a chess server.  [xboard compatibility].            *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("variant", *args)) {
    if (shared->thinking || shared->pondering)
      return (2);
    printf("command=[%s]\n", buffer);
    return (-1);
  }
/*
 ************************************************************
 *                                                          *
 *   "whisper" command sets whisper mode for ICS.  =1 will  *
 *   whisper mate announcements, =2 will whisper scores and *
 *   other info, =3 will whisper scores and PV, =4 adds the *
 *   list of book moves, =5 displays the PV after each      *
 *   iteration completes, and =6 displays the PV each time  *
 *   it changes in an iteration.                            *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("whisper", *args)) {
    if (nargs < 2) {
      printf("usage:  whisper <level>\n");
      return (1);
    }
    kibitz = 16 + atoi(args[1]);
  }
/*
 ************************************************************
 *                                                          *
 *   "wild" command sets up an ICS wild position (only 7 at *
 *   present, but any can be added easily, except for those *
 *   that Crafty simply can't play (two kings, invisible    *
 *   pieces, etc.)                                          *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("wild", *args)) {
    int i;

    if (nargs < 2) {
      printf("usage:  wild <value>\n");
      return (1);
    }
    i = atoi(args[1]);
    switch (i) {
    case 7:
      strcpy(buffer, "setboard 4k/5ppp/////PPP/3K/ w");
      (void) Option(tree);
      break;
    default:
      printf("sorry, only wild7 implemented at present\n");
      break;
    }
  }
/*
 ************************************************************
 *                                                          *
 *   "white" command sets white to move (wtm).              *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("white", *args)) {
    if (shared->thinking || shared->pondering)
      return (2);
    ponder_move = 0;
    last_pv.pathd = 0;
    last_pv.pathl = 0;
    if (!wtm)
      Pass();
    force = 0;
  }
/*
 ************************************************************
 *                                                          *
 *  "xboard" command is normally invoked from main() via    *
 *  the xboard command-line option.  it sets proper         *
 *  defaults for ics/Xboard interface requirements.         *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("xboard", *args) || OptionMatch("winboard", *args)) {
    if (!xboard) {
      signal(SIGINT, SIG_IGN);
      xboard = 1;
      shared->display_options &= 4095 - 1 - 2 - 4 - 8 - 16 - 32 - 128;
      ansi = 0;
      printf("\n");
      printf("tellicsnoalias set 1 Crafty v%s (%d cpus)\n", version, Max(1,
              shared->max_threads));
      printf("tellicsnoalias kibitz Hello from Crafty v%s! (%d cpus)\n",
          version, Max(1, shared->max_threads));
      fflush(stdout);
    }
  }
/*
 ************************************************************
 *                                                          *
 *  "?" command does nothing, but since this is the "move   *
 *  now" keystroke, if crafty is not searching, this will   *
 *  simply "wave it off" rather than produce an error.      *
 *                                                          *
 ************************************************************
 */
  else if (OptionMatch("?", *args)) {
  }
/*
 ************************************************************
 *                                                          *
 *   unknown command, it must be a move.                    *
 *                                                          *
 ************************************************************
 */
  else
    return (0);
/*
 ************************************************************
 *                                                          *
 *   command executed, return for another.                  *
 *                                                          *
 ************************************************************
 */
  return (1);
}

/*
 *******************************************************************************
 *                                                                             *
 *   OptionMatch() is used to recognize user commands.  it requires that the   *
 *   command (text input which is the *2nd parameter* conform to the following *
 *   simple rules:                                                             *
 *                                                                             *
 *     1.  the input must match the command, starting at the left-most         *
 *         character.                                                          *
 *     2.  if the command starts with a sequence of characters that could      *
 *         be interpreted as a chess move as well (re for reset and/or rook    *
 *         to the e-file) then the input must match enough of the command      *
 *         to get past the ambiguity (res would be minimum we will accept      *
 *         for the reset command.)                                             *
 *                                                                             *
 *******************************************************************************
 */
int OptionMatch(char *command, char *input)
{
/*
 ************************************************************
 *                                                          *
 *   check for the obvious exact match first.               *
 *                                                          *
 ************************************************************
 */
  if (!strcmp(command, input))
    return (1);
/*
 ************************************************************
 *                                                          *
 *   now use strstr() to see if "input" is in "command."    *
 *   the first requirement is that input matches command    *
 *   starting at the very left-most character;              *
 *                                                          *
 ************************************************************
 */
  if (strstr(command, input) == command)
    return (1);
  return (0);
}

void OptionPerft(TREE * RESTRICT tree, int ply, int depth, int wtm)
{
  int *mv;
  static char line[256], *p[64];

#if defined(TRACE)
  static char move[16];
#endif

  tree->last[ply] = GenerateCaptures(tree, ply, wtm, tree->last[ply - 1]);
  for (mv = tree->last[ply - 1]; mv < tree->last[ply]; mv++)
    if (Captured(*mv) == king)
      return;
  tree->last[ply] = GenerateNonCaptures(tree, ply, wtm, tree->last[ply]);
  p[1] = line;
  for (mv = tree->last[ply - 1]; mv < tree->last[ply]; mv++) {
#if defined(TRACE)
    strcpy(move, OutputMove(tree, *mv, ply, wtm));
#endif
    MakeMove(tree, ply, *mv, wtm);
#if defined(TRACE)
    if (ply <= trace_level) {
      strcpy(p[ply], move);
      strcpy(line + strlen(line), " ");
      p[ply + 1] = line + strlen(line);
      if (ply == trace_level)
        printf("%s\n", line);
    }
#endif
    if (depth - 1)
      OptionPerft(tree, ply + 1, depth - 1, Flip(wtm));
    else if (!Check(wtm))
      total_moves++;
    UnmakeMove(tree, ply, *mv, wtm);
  }
}
