#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "chess.h"
#include "data.h"

/* last modified 08/07/05 */
/*
 *******************************************************************************
 *                                                                             *
 *  "annotate" command is used to search through the game in the "history" file*
 *  (often set by the "read" command which reads moves in, skipping non-move   *
 *  information such as move numbers, times, etc.)                             *
 *                                                                             *
 *  the normal output of this command is a file, in PGN format, that contains  *
 *  the moves of the game, along with analysis when Crafty does not think that *
 *  move was the best choice.  the definition of "best choice" is somewhat     *
 *  vague, because if the move played is "close" to the best move available,   *
 *  Crafty will not comment on the move.  "close" is defined by the <margin>   *
 *  option explained below.  this basic type of annotation works by first      *
 *  using the normal tree search algorithm to find the best move.  if this     *
 *  move was the move played, no output is produced.  if a different move is   *
 *  considered best, then the actual move played is searched to the same depth *
 *  and if the best move and actual move scores are within <margin> of each    *
 *  other, no comment is produced, otherwise crafty inserts the evaluation for *
 *  the move played, followed by the eval and PV for the best continuation it  *
 *  found.  you can enter suggested moves for Crafty to analyze at any point   *
 *  by simply entering a move as an analysis-type comment using (move) or      *
 *  {move}.  Crafty will search that move in addition to the move actually     *
 *  played and the move it thinks is best.                                     *
 *                                                                             *
 *  the format of the command is as follows:                                   *
 *                                                                             *
 *      annotate filename b*w*bw*name moves margin time [n]                    *
 *                                                                             *
 *  filename is the input file where Crafty will obtain the moves to annotate, *
 *  and output will be written to file "filename.can".                         *
 *                                                                             *
 *      annotateh filename b*w*bw*name moves margin time [n]                   *
 *                                                                             *
 *  can be used to produce an HTML-compatible file that includes bitmapped     *
 *  diagrams of the positions where Crafty provides analysis.  this file can be*
 *  opened by a browser to provide much easier 'reading'.                      *
 *                                                                             *
 *      annotatet filename b*w*bw*name moves margin time [n]                   *
 *                                                                             *
 *  can be used to produce a LaTeX-compatible file that includes LaTeX chess   *
 *  fonts.  this file can be read/printed by any program that can handle LaTeX *
 *  input.                                                                     *
 *                                                                             *
 *  where b/w/bw indicates whether to annotate only the white side (w), the    *
 *  black side (b) or both (bw).  you can also specify a name (or part of a    *
 *  name, just be sure it is unique in the name tags for clarity in who you    *
 *  mean).                                                                     *
 *                                                                             *
 *  moves indicates the move or moves to annotate.  it can be a single move,   *
 *  which indicates the starting move number to annotate, or it can be a range,*
 *  which indicates a range of move (1-999 gets the whole game.)               *
 *                                                                             *
 *  margin is the difference between Crafty's evaluation for the move actually *
 *  played and for the move Crafty thinks is best, before crafty will generate *
 *  a comment in the annotation file.  1.0 is a pawn, and will only generate   *
 *  comments if the move played is 1.000 (1 pawn) worse than the best move     *
 *  found by doing a complete search.                                          *
 *                                                                             *
 *  time is time per move to search, in seconds.                               *
 *                                                                             *
 *  [n] is optional and tells Crafty to produce the PV/score for the "n" best  *
 *  moves.  Crafty stops when the best move reaches the move played in the game*
 *  or after displaying n moves, whichever comes first.  if you use -n, then it*
 *  will display n moves regardless of where the game move ranks.              *
 *                                                                             *
 *******************************************************************************
 */

#define MIN_DECISIVE_ADV 150
#define MIN_MODERATE_ADV  70
#define MIN_SLIGHT_ADV    30

void Annotate()
{
  FILE *annotate_in, *annotate_out;
  char text[128], tbuffer[512], colors[32] = { "" }, pname[128] = {
  ""};
  int annotate_margin, annotate_score[100], player_score, best_moves,
      annotate_wtm;
  int annotate_search_time_limit, search_player;
  int twtm, path_len, analysis_printed = 0;
  int wtm, move_num, line1, line2, move, suggested, i;
  int searches_done, read_status;
  PATH temp[100], player_pv;
  int temp_search_depth;
  TREE *const tree = shared->local[0];
  char html_br[5] = { "" };
  int save_swindle_mode;
  int html_mode = 0;
  int latex = 0;

/*
 ************************************************************
 *                                                          *
 *   first, quiz the user for the options needed to         *
 *   successfully annotate a game.                          *
 *                                                          *
 ************************************************************
 */
  save_swindle_mode = swindle_mode;
  if (!strcmp(args[0], "annotateh")) {
    html_mode = 1;
    strcpy(html_br, "<br>");
  }
  if (!strcmp(args[0], "annotatet")) {
    latex = 1;
    strcpy(html_br, "\\\\");
  }
  strcpy(tbuffer, buffer);
  nargs = ReadParse(tbuffer, args, " 	;");
  if (nargs < 6) {
    printf("usage: annotate <file> <color> <moves> <margin> <time> [nmoves]\n");
    return;
  }
  annotate_in = fopen(args[1], "r");
  if (annotate_in == NULL) {
    Print(4095, "unable to open %s for input\n", args[1]);
    return;
  }
  nargs = ReadParse(tbuffer, args, " 	;");
  strcpy(text, args[1]);
  if (html_mode == 1)
    strcpy(text + strlen(text), ".html");
  else if (latex == 1)
    strcpy(text + strlen(text), ".tex");
  else
    strcpy(text + strlen(text), ".can");
  annotate_out = fopen(text, "w");
  if (annotate_out == NULL) {
    Print(4095, "unable to open %s for output\n", text);
    return;
  }
  if (html_mode == 1)
    AnnotateHeaderHTML(text, annotate_out);
  if (latex == 1)
    AnnotateHeaderTeX(text, annotate_out);
  if (strlen(args[2]) <= 2)
    strcpy(colors, args[2]);
  else
    strcpy(pname, args[2]);
  line1 = 1;
  line2 = 999;
  if (strchr(args[3], 'b'))
    line2 = -1;
  if (strchr(args[3], '-'))
    sscanf(args[3], "%d-%d", &line1, &line2);
  else {
    sscanf(args[3], "%d", &line1);
    line2 = 999;
  }
  annotate_margin = atof(args[4]) * pawn_value;
  annotate_search_time_limit = atoi(args[5]) * 100;
  if (nargs > 6)
    best_moves = atoi(args[6]);
  else
    best_moves = 1;
/*
 ************************************************************
 *                                                          *
 *   reset the game to "square 0" to start the annotation   *
 *   procedure.  then we read moves from the input file,    *
 *   make them on the game board, and annotate if the move  *
 *   is for the correct side.  if we haven't yet reached    *
 *   the starting move to annotate, we skip the Search()    *
 *   stuff and read another move.                           *
 *                                                          *
 ************************************************************
 */
  annotate_mode = 1;
  swindle_mode = 0;
  ponder = 0;
  temp_search_depth = search_depth;
  read_status = ReadPGN(0, 0);
  read_status = ReadPGN(annotate_in, 0);
  player_pv.path[1] = 0;
  while (read_status != -1) {
    ponder_move = 0;
    last_pv.pathd = 0;
    last_pv.pathl = 0;
    player_pv.pathd = 0;
    player_pv.pathl = 0;
    tree->pv[0].pathl = 0;
    tree->pv[0].pathd = 0;
    analysis_printed = 0;
    InitializeChessBoard(&tree->position[0]);
    tree->position[1] = tree->position[0];
    wtm = 1;
    shared->move_number = 1;
/*
 ************************************************************
 *                                                          *
 *   now grab the PGN tag values so they can be copied to   *
 *   the .can file for reference.                           *
 *                                                          *
 ************************************************************
 */
    do
      read_status = ReadPGN(annotate_in, 0);
    while (read_status == 1);
    if (read_status == -1)
      break;
    if (latex == 0) {
      fprintf(annotate_out, "[Event \"%s\"]%s\n", pgn_event, html_br);
      fprintf(annotate_out, "[Site \"%s\"]%s\n", pgn_site, html_br);
      fprintf(annotate_out, "[Date \"%s\"]%s\n", pgn_date, html_br);
      fprintf(annotate_out, "[Round \"%s\"]%s\n", pgn_round, html_br);
      fprintf(annotate_out, "[White \"%s\"]%s\n", pgn_white, html_br);
      fprintf(annotate_out, "[WhiteElo \"%s\"]%s\n", pgn_white_elo, html_br);
      fprintf(annotate_out, "[Black \"%s\"]%s\n", pgn_black, html_br);
      fprintf(annotate_out, "[BlackElo \"%s\"]%s\n", pgn_black_elo, html_br);
      fprintf(annotate_out, "[Result \"%s\"]%s\n", pgn_result, html_br);
      fprintf(annotate_out, "[Annotator \"Crafty v%s\"]%s\n", version, html_br);
      if (strlen(colors) != 0) {
        if (!strcmp(colors, "bw") || !strcmp(colors, "wb"))
          fprintf(annotate_out, "{annotating both black and white moves.}%s\n",
              html_br);
        else if (strchr(colors, 'b'))
          fprintf(annotate_out, "{annotating only black moves.}%s\n", html_br);
        else if (strchr(colors, 'w'))
          fprintf(annotate_out, "{annotating only white moves.}%s\n", html_br);
      } else
        fprintf(annotate_out, "{annotating for player %s}%s\n", pname, html_br);
      fprintf(annotate_out, "{using a scoring margin of %s pawns.}%s\n",
          DisplayEvaluationKibitz(annotate_margin, wtm), html_br);
      fprintf(annotate_out, "{search time limit is %s}%s\n%s\n",
          DisplayTimeKibitz(annotate_search_time_limit), html_br, html_br);
    } else {
      fprintf(annotate_out, "\\textbf{\\sc %s %s -- %s %s}%s\n", pgn_white,
          pgn_white_elo, pgn_black, pgn_black_elo, html_br);
      fprintf(annotate_out, "{\\em %s, %s}%s\n", pgn_site, pgn_date, html_br);
      fprintf(annotate_out, "{\\small %s, Round: %s}%s\n", pgn_event, pgn_round,
          html_br);
      fprintf(annotate_out, "\\begin{mainline}{%s}{Crafty v%s}\n", pgn_result,
          version);
    }
    if (strlen(colors)) {
      if (!strcmp(colors, "w"))
        annotate_wtm = 1;
      else if (!strcmp(colors, "b"))
        annotate_wtm = 0;
      else if (!strcmp(colors, "wb"))
        annotate_wtm = 2;
      else if (!strcmp(colors, "bw"))
        annotate_wtm = 2;
      else {
        Print(4095, "invalid color specification, retry\n");
        fclose(annotate_out);
        return;
      }
    } else {
      if (strstr(pgn_white, pname))
        annotate_wtm = 1;
      else if (strstr(pgn_black, pname))
        annotate_wtm = 0;
      else {
        Print(4095, "Player name doesn't match any PGN name tag, retry\n");
        fclose(annotate_out);
        return;
      }
    }
    do {
      fflush(annotate_out);
      move = ReadNextMove(tree, buffer, 0, wtm);
      if (move <= 0)
        break;
      strcpy(text, OutputMove(tree, move, 0, wtm));
      fseek(history_file, ((shared->move_number - 1) * 2 + 1 - wtm) * 10,
          SEEK_SET);
      fprintf(history_file, "%9s\n", text);
      if (wtm)
        Print(4095, "White(%d): %s\n", shared->move_number, text);
      else
        Print(4095, "Black(%d): %s\n", shared->move_number, text);
      if (analysis_printed)
        fprintf(annotate_out, "%3d.%s%8s\n", shared->move_number,
            (wtm ? "" : "     ..."), text);
      else {
        if (wtm)
          fprintf(annotate_out, "%3d.%8s", shared->move_number, text);
        else
          fprintf(annotate_out, "%8s\n", text);
      }
      analysis_printed = 0;
      if (shared->move_number >= line1 && shared->move_number <= line2) {
        if (annotate_wtm == 2 || annotate_wtm == wtm) {
          last_pv.pathd = 0;
          last_pv.pathl = 0;
          shared->thinking = 1;
          RootMoveList(wtm);
/*
 ************************************************************
 *                                                          *
 *   now search the position to see if the move played is   *
 *   the best move possible.  if not, then search just the  *
 *   move played to get a score for it as well, so we can   *
 *   determine if annotated output is appropriate.          *
 *                                                          *
 ************************************************************
 */
          shared->search_time_limit = annotate_search_time_limit;
          search_depth = temp_search_depth;
          player_score = -999999;
          search_player = 1;
          for (searches_done = 0; searches_done < abs(best_moves);
              searches_done++) {
            if (searches_done > 0) {
              shared->search_time_limit = 3 * annotate_search_time_limit;
              search_depth = temp[0].pathd;
            }
            Print(4095, "\n              Searching all legal moves.");
            Print(4095, "----------------------------------\n");
            tree->position[1] = tree->position[0];
            InitializeHashTables();
            annotate_score[searches_done] = Iterate(wtm, annotate, 1);
            if (tree->pv[0].path[1] == move) {
              player_score = annotate_score[searches_done];
              player_pv = tree->pv[0];
              search_player = 0;
            }
            temp[searches_done] = tree->pv[0];
            for (i = 0; i < shared->n_root_moves; i++) {
              if (shared->root_moves[i].move == tree->pv[0].path[1]) {
                for (; i < shared->n_root_moves; i++)
                  shared->root_moves[i] = shared->root_moves[i + 1];
                shared->n_root_moves--;
                break;
              }
            }
            if (shared->n_root_moves == 0 || (annotate_margin >= 0 &&
                    player_score + annotate_margin >
                    annotate_score[searches_done]
                    && best_moves > 0)) {
              if (shared->n_root_moves == 0)
                searches_done++;
              break;
            }
          }
          if (search_player) {
            Print(4095,
                "\n              Searching only the move played in game.");
            Print(4095, "--------------------\n");
            tree->position[1] = tree->position[0];
            search_move = move;
            shared->root_moves[0].move = move;
            shared->root_moves[0].nodes = 0;
            shared->root_moves[0].status = 0;
            shared->n_root_moves = 1;
            shared->search_time_limit = 3 * annotate_search_time_limit;
            search_depth = temp[0].pathd;
            if (search_depth == temp_search_depth)
              shared->search_time_limit = annotate_search_time_limit;
            InitializeHashTables();
            player_score = Iterate(wtm, annotate, 1);
            player_pv = tree->pv[0];
            search_depth = temp_search_depth;
            shared->search_time_limit = annotate_search_time_limit;
            search_move = 0;
          }
/*
 ************************************************************
 *                                                          *
 *   output the score/pv for the move played unless it      *
 *   matches what Crafty would have played.  if it doesn't  *
 *   then output the pv for what Crafty thinks is best.     *
 *                                                          *
 ************************************************************
 */
          shared->thinking = 0;
          if (player_pv.pathd > 1 && player_pv.pathl >= 1 &&
              player_score + annotate_margin < annotate_score[0] &&
              (temp[0].path[1] != player_pv.path[1] || annotate_margin < 0.0 ||
                  best_moves != 1)) {
            if (wtm) {
              analysis_printed = 1;
              fprintf(annotate_out, "%s\n", html_br);
            }
            if (html_mode == 1)
              AnnotatePositionHTML(tree, wtm, annotate_out);
            if (latex == 1) {
              AnnotatePositionTeX(tree, wtm, annotate_out);
              fprintf(annotate_out, "   \\begin{variation}\\{%d:%s\\}",
                  player_pv.pathd, DisplayEvaluationKibitz(player_score, wtm));
            } else
              fprintf(annotate_out, "                ({%d:%s}", player_pv.pathd,
                  DisplayEvaluationKibitz(player_score, wtm));
            path_len = player_pv.pathl;
            fprintf(annotate_out, " %s", FormatPV(tree, wtm, player_pv));
            if (latex == 1)
              fprintf(annotate_out, " %s\n   \\end{variation}\n",
                  AnnotateVtoNAG(player_score, wtm, html_mode, latex));
            else
              fprintf(annotate_out, " %s)%s\n", AnnotateVtoNAG(player_score,
                      wtm, html_mode, latex), html_br);
            for (move_num = 0; move_num < searches_done; move_num++) {
              if (move != temp[move_num].path[1]) {
                if (latex == 1)
                  fprintf(annotate_out, "   \\begin{variation}\\{%d:%s\\}",
                      temp[move_num].pathd,
                      DisplayEvaluationKibitz(annotate_score[move_num], wtm));
                else
                  fprintf(annotate_out, "                ({%d:%s}",
                      temp[move_num].pathd,
                      DisplayEvaluationKibitz(annotate_score[move_num], wtm));
                path_len = temp[move_num].pathl;
                fprintf(annotate_out, " %s", FormatPV(tree, wtm,
                        temp[move_num]));
                if (latex == 1)
                  fprintf(annotate_out, " %s\n   \\end{variation}\n",
                      AnnotateVtoNAG(annotate_score[move_num], wtm, html_mode,
                          latex));
                else
                  fprintf(annotate_out, " %s)%s\n",
                      AnnotateVtoNAG(annotate_score[move_num], wtm, html_mode,
                          latex), html_br);
              }
            }
            if (html_mode == 1)
              fprintf(annotate_out, "<br>\n");
            if (line2 < 0)
              line2--;
          }
        }
      }
/*
 ************************************************************
 *                                                          *
 *   before going on to the next move, see if the user has  *
 *   included a set of other moves that require a search.   *
 *   if so, search them one at a time and produce the ana-  *
 *   lysis for each one.                                    *
 *                                                          *
 ************************************************************
 */
      read_status = ReadPGN(annotate_in, 1);
      while (read_status == 2) {
        suggested = InputMove(tree, buffer, 0, wtm, 1, 0);
        if (suggested > 0) {
          shared->thinking = 1;
          Print(4095, "\n              Searching only the move suggested.");
          Print(4095, "--------------------\n");
          tree->position[1] = tree->position[0];
          search_move = suggested;
          shared->search_time_limit = 3 * annotate_search_time_limit;
          search_depth = temp[0].pathd;
          InitializeHashTables();
          annotate_score[0] = Iterate(wtm, annotate, 0);
          search_depth = temp_search_depth;
          shared->search_time_limit = annotate_search_time_limit;
          search_move = 0;
          shared->thinking = 0;
          twtm = wtm;
          path_len = tree->pv[0].pathl;
          if (tree->pv[0].pathd > 1 && path_len >= 1) {
            if (wtm && !analysis_printed) {
              analysis_printed = 1;
              fprintf(annotate_out, "%s\n", html_br);
            }
            fprintf(annotate_out, "                ({suggested %d:%s}",
                tree->pv[0].pathd, DisplayEvaluationKibitz(annotate_score[0],
                    wtm));
            for (i = 1; i <= path_len; i++) {
              fprintf(annotate_out, " %s", OutputMove(tree, tree->pv[0].path[i],
                      i, twtm));
              MakeMove(tree, i, tree->pv[0].path[i], twtm);
              twtm = Flip(twtm);
            }
            for (i = path_len; i > 0; i--) {
              twtm = Flip(twtm);
              UnmakeMove(tree, i, tree->pv[0].path[i], twtm);
            }
            fprintf(annotate_out, " %s)%s\n", AnnotateVtoNAG(annotate_score[0],
                    wtm, html_mode, latex), html_br);
          }
        }
        read_status = ReadPGN(annotate_in, 1);
        if (read_status != 2)
          break;
      }
      if ((analysis_printed) && (latex == 0))
        fprintf(annotate_out, "%s\n", html_br);
      MakeMoveRoot(tree, move, wtm);
      wtm = Flip(wtm);
      if (wtm)
        shared->move_number++;
      if (read_status != 0)
        break;
      if (line2 < -1)
        break;
    } while (1);
    fprintf(annotate_out, "\n       %s %s\n", pgn_result, html_br);
    if (html_mode == 1) {
      fprintf(annotate_out, "%s\n", html_br);
      AnnotateFooterHTML(annotate_out);
    }
    if (latex == 1) {
      AnnotatePositionTeX(tree, wtm, annotate_out);
      fprintf(annotate_out, "\\end{mainline}\n");
      if (strlen(colors) != 0) {
        fprintf(annotate_out, "\\begin{flushright}{\\small ");
        if (!strcmp(colors, "bw") || !strcmp(colors, "wb"))
          fprintf(annotate_out, "annotating both black and white moves.%s\n",
              html_br);
        else if (strchr(colors, 'b'))
          fprintf(annotate_out, "annotating only black moves.%s\n", html_br);
        else if (strchr(colors, 'w'))
          fprintf(annotate_out, "annotating only white moves.%s\n", html_br);
      } else
        fprintf(annotate_out, "annotating for player %s%s\n", pname, html_br);
      fprintf(annotate_out, "using a scoring margin of %s pawns.%s\n",
          DisplayEvaluationKibitz(annotate_margin, wtm), html_br);
      fprintf(annotate_out, "search time limit is %s%s\n",
          DisplayTimeKibitz(annotate_search_time_limit), html_br);
      fprintf(annotate_out, " } \\end{flushright}");
      AnnotateFooterTeX(annotate_out);
    }
  }
  if (annotate_out)
    fclose(annotate_out);
  if (annotate_in)
    fclose(annotate_in);
  shared->search_time_limit = 0;
  annotate_mode = 0;
  swindle_mode = save_swindle_mode;
}

void AnnotateHeaderHTML(char *title_text, FILE * annotate_out)
{
  fprintf(annotate_out,
      "<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.0 Transitional//EN\"\n");
  fprintf(annotate_out,
      "          \"http://www.w3.org/TR/REC-html40/loose.dtd\">\n");
  fprintf(annotate_out, "<HTML>\n");
  fprintf(annotate_out, "<HEAD><TITLE>%s</TITLE>\n", title_text);
  fprintf(annotate_out,
      "<LINK rev=\"made\" href=\"hyatt@cis.uab.edu\"></HEAD>\n");
  fprintf(annotate_out,
      "<BODY BGColor=\"#ffffff\" text=\"#000000\" link=\"#0000ee\""
      " vlink=\"#551a8b\">\n");
}

void AnnotateFooterHTML(FILE * annotate_out)
{
  fprintf(annotate_out, "</BODY>\n");
  fprintf(annotate_out, "</HTML>\n");
}

void AnnotatePositionHTML(TREE * RESTRICT tree, int wtm, FILE * annotate_out)
{
  char filename[32], html_piece;
  char alt[32];
  char xlate[15] =
      { 'q', 'r', 'b', 0, 'k', 'n', 'p', 0, 'P', 'N', 'K', 0, 'B', 'R', 'Q' };
  int rank, file;

/*  Display the board in HTML using table of images.          */
  fprintf(annotate_out, "<br>\n");
  fprintf(annotate_out, "<TABLE Border=1 CellSpacing=0 CellPadding=0>\n\n");
  for (rank = RANK8; rank >= RANK1; rank--) {
    fprintf(annotate_out, "<TR>\n");
    for (file = FILEA; file <= FILEH; file++) {
      (void) strcpy(filename, "bitmaps/");
      if ((rank + file) % 2)
        (void) strcat(filename, "w");
      else
        (void) strcat(filename, "b");
      html_piece = xlate[PcOnSq((rank << 3) + file) + 7];
      switch (html_piece) {
      case 'p':
        strcat(filename, "bp");
        strcpy(alt, "*P");
        break;
      case 'r':
        strcat(filename, "br");
        strcpy(alt, "*R");
        break;
      case 'n':
        strcat(filename, "bn");
        strcpy(alt, "*N");
        break;
      case 'b':
        strcat(filename, "bb");
        strcpy(alt, "*B");
        break;
      case 'q':
        strcat(filename, "bq");
        strcpy(alt, "*Q");
        break;
      case 'k':
        strcat(filename, "bk");
        strcpy(alt, "*K");
        break;
      case 'P':
        strcat(filename, "wp");
        strcpy(alt, "P");
        break;
      case 'R':
        strcat(filename, "wr");
        strcpy(alt, "R");
        break;
      case 'N':
        strcat(filename, "wn");
        strcpy(alt, "N");
        break;
      case 'B':
        strcat(filename, "wb");
        strcpy(alt, "B");
        break;
      case 'Q':
        strcat(filename, "wq");
        strcpy(alt, "Q");
        break;
      case 'K':
        strcat(filename, "wk");
        strcpy(alt, "K");
        break;
      default:
        strcat(filename, "sq");
        strcpy(alt, " ");
        break;
      }
      strcat(filename, ".gif");
      fprintf(annotate_out, "<TD><IMG ALT=\"%s\" SRC=\"%s\"></TD>\n", alt,
          filename);
    }
    fprintf(annotate_out, "</TR>\n\n");
  }
  fprintf(annotate_out, "</TABLE>\n");
  if (wtm)
    fprintf(annotate_out, "<H2>White to move.</H2>\n");
  else
    fprintf(annotate_out, "<H2>Black to move.</H2>\n");
  fprintf(annotate_out, "<BR>\n");
}

/*
 *******************************************************************************
 * Author         : Alexander Wagner                                           *
 *                                      University of Michigan                 *
 * Date           : 03.01.04                                                   *
 * Report bugs to :                                                            *
 *                                                                             *
 * Last Modified  : 03.01.04                                                   *
 *                                                                             *
 * Based upon the HTML-Code above                                              *
 *                                                                             *
 * These functions provide LaTeX output capability to Crafty.                  *
 *                                                                             *
 *******************************************************************************
 */
void AnnotateHeaderTeX(char *title_text, FILE * annotate_out)
{
  fprintf(annotate_out, "\\documentclass[12pt,twocolumn]{article}\n");
  fprintf(annotate_out, "%% This is a LaTeX file generated by Crafty \n");
  fprintf(annotate_out,
      "%% You must have the \"chess12\" package to typeset this file.\n");
  fprintf(annotate_out, "\n");
  fprintf(annotate_out, "\\usepackage{times}\n");
  fprintf(annotate_out, "\\usepackage{a4wide}\n");
  fprintf(annotate_out, "\\usepackage{chess}\n");
  fprintf(annotate_out, "\\usepackage{bdfchess}\n");
  fprintf(annotate_out, "\\usepackage[T1]{fontenc}\n");
  fprintf(annotate_out, "\n");
  fprintf(annotate_out, "\\setlength{\\columnsep}{7mm}\n");
  fprintf(annotate_out, "\\setlength{\\parindent}{0pt}\n");
  fprintf(annotate_out, "\n");
  fprintf(annotate_out, "%% Macros for variations and diagrams:\n");
  fprintf(annotate_out,
      "\\newenvironment{mainline}[2]{\\bf\\newcommand{\\result}{#1}%%\n");
  fprintf(annotate_out, "\\newcommand{\\commentator}{#2}\\begin{chess}}%%\n");
  fprintf(annotate_out, "{\\end{chess}\\finito{\\result}{\\commentator}}\n");
  fprintf(annotate_out,
      "\\newenvironment{variation}{[\\begingroup\\rm\\ignorespaces}%%\n");
  fprintf(annotate_out, "{\\endgroup]\\ignorespaces\\newline}\n");
  fprintf(annotate_out,
      "\\newcommand{\\finito}[2]{{\\bf\\hfill#1\\hfill[#2]\\par}}\n");
  fprintf(annotate_out, "\\setlength{\\parindent}{0pt}\n");
  fprintf(annotate_out,
      "\\newenvironment{diagram}{\\begin{nochess}}"
      "{$$\\showboard$$\\end{nochess}}\n");
  fprintf(annotate_out, "\n\n\\begin{document}\n\n");
}

void AnnotateFooterTeX(FILE * annotate_out)
{
  fprintf(annotate_out, "\n\n\\end{document}\n");
}

void AnnotatePositionTeX(TREE * tree, int wtm, FILE * annotate_out)
{
  char filename[32], html_piece;
  char xlate[15] =
      { 'q', 'r', 'b', 0, 'k', 'n', 'p', 0, 'P', 'N', 'K', 0, 'B', 'R', 'Q' };
  int rank, file;

/*  Display the board in LaTeX using picture notation, similar to html */
  fprintf(annotate_out, "\\begin{diagram}\n\\board\n");
  for (rank = RANK8; rank >= RANK1; rank--) {
    fprintf(annotate_out, "   {");
    for (file = FILEA; file <= FILEH; file++) {
      if ((rank + file) % 2)
        (void) strcpy(filename, " ");
      else
        (void) strcpy(filename, "*");
      html_piece = xlate[PcOnSq((rank << 3) + file) + 7];
      switch (html_piece) {
      case 'p':
        strcpy(filename, "p");
        break;
      case 'r':
        strcpy(filename, "r");
        break;
      case 'n':
        strcpy(filename, "n");
        break;
      case 'b':
        strcpy(filename, "b");
        break;
      case 'q':
        strcpy(filename, "q");
        break;
      case 'k':
        strcpy(filename, "k");
        break;
      case 'P':
        strcpy(filename, "P");
        break;
      case 'R':
        strcpy(filename, "R");
        break;
      case 'N':
        strcpy(filename, "N");
        break;
      case 'B':
        strcpy(filename, "B");
        break;
      case 'Q':
        strcpy(filename, "Q");
        break;
      case 'K':
        strcpy(filename, "K");
        break;
      default:
        break;
      }
      fprintf(annotate_out, "%s", filename);
    }
    fprintf(annotate_out, "}\n");
  }
  fprintf(annotate_out, "\\end{diagram}\n");
  fprintf(annotate_out, "\\begin{center} \\begin{nochess}\n  {\\small ");
  if (wtm)
    fprintf(annotate_out, "White to move.\n");
  else
    fprintf(annotate_out, "Black to move.\n");
  fprintf(annotate_out, "}\n \\end{nochess}\\end{center} \n\n");
  fprintf(annotate_out, "\n");
}

char *AnnotateVtoNAG(int value, int wtm, int html_mode, int latex)
{
  static char buf[64];

  if (!wtm)
    value = -value;
  if (value > MIN_DECISIVE_ADV)
    strcpy(buf, html_mode ? "+-" : "$18");
  else if (value > MIN_MODERATE_ADV)
    strcpy(buf, html_mode ? "+/-" : "$16");
  else if (value > MIN_SLIGHT_ADV)
    strcpy(buf, html_mode ? "+=" : "$14");
  else if (value < -MIN_DECISIVE_ADV)
    strcpy(buf, html_mode ? "-+" : "$19");
  else if (value < -MIN_MODERATE_ADV)
    strcpy(buf, html_mode ? "-/+" : "$17");
  else if (value < -MIN_SLIGHT_ADV)
    strcpy(buf, html_mode ? "=+" : "$15");
  else
    strcpy(buf, html_mode ? "=" : "$10");
  if (latex == 1) {
    if (value > MIN_DECISIVE_ADV)
      strcpy(buf, "\\wdecisive");
    else if (value > MIN_MODERATE_ADV)
      strcpy(buf, "\\wupperhand");
    else if (value > MIN_SLIGHT_ADV)
      strcpy(buf, "\\wbetter");
    else if (value < -MIN_DECISIVE_ADV)
      strcpy(buf, "\\bdecisive");
    else if (value < -MIN_MODERATE_ADV)
      strcpy(buf, "\\bupperhand");
    else if (value < -MIN_SLIGHT_ADV)
      strcpy(buf, "\\bbetter");
    else
      strcpy(buf, "\\equal");
  }
  return buf;
}
