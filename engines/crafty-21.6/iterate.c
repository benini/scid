#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "chess.h"
#include "data.h"
#include "epdglue.h"
#if defined(UNIX) || defined(AMIGA)
#  include <unistd.h>
#  include <sys/types.h>
#endif

/* last modified 08/07/05 */
/*
 *******************************************************************************
 *                                                                             *
 *   Iterate() is the routine used to drive the iterated search.  it repeatedly*
 *   calls search, incrementing the search depth after each call, until either *
 *   time is exhausted or the maximum set search depth is reached.             *
 *                                                                             *
 *******************************************************************************
 */
int Iterate(int wtm, int search_type, int root_list_done)
{
  ROOT_MOVE temp;
  int wpawn, bpawn, TB_use_ok;
  int i, value = 0, time_used;
  int twtm, used;
  int correct, correct_count, material = 0, sorted;
  TREE *const tree = shared->local[0];
  char *fh_indicator, *fl_indicator;

/*
 ************************************************************
 *                                                          *
 *  initialize.                                             *
 *                                                          *
 *  produce the root move list, which is ordered and kept   *
 *  for the duration of this search (the order may change   *
 *  as new best moves are backed up to the root of course.) *
 *                                                          *
 ************************************************************
 */
  tree->current_move[0] = 0;
  if (shared->average_nps == 0)
    shared->average_nps = 150000 * shared->max_threads;
  if (wtm) {
    shared->draw_score[0] = -abs_draw_score;
    shared->draw_score[1] = abs_draw_score;
  } else {
    shared->draw_score[0] = abs_draw_score;
    shared->draw_score[1] = -abs_draw_score;
  }
#if defined(NODES)
  temp_search_nodes = search_nodes;
#endif
  shared->time_abort = 0;
  shared->abort_search = 0;
  book_move = 0;
  shared->program_start_time = ReadClock();
  shared->start_time = ReadClock();
  shared->elapsed_start = ReadClock();
  shared->root_wtm = wtm;
  PreEvaluate(tree);
  shared->kibitz_depth = 0;
  tree->nodes_searched = 0;
  tree->fail_high = 0;
  tree->fail_high_first = 0;
  shared->parallel_splits = 0;
  shared->parallel_aborts = 0;
  shared->max_split_blocks = 0;
  TB_use_ok = 1;
  if (TotalWhitePawns && TotalBlackPawns) {
    wpawn = MSB(WhitePawns);
    bpawn = MSB(BlackPawns);
    if (FileDistance(wpawn, bpawn) == 1) {
      if (((Rank(wpawn) == RANK2) && (Rank(bpawn) > RANK3)) ||
          ((Rank(bpawn) == RANK7) && (Rank(wpawn) < RANK6)) || EnPassant(1))
        TB_use_ok = 0;
    }
  }
  if (shared->booking || !Book(tree, wtm, root_list_done))
    do {
      if (shared->abort_search)
        break;
      if (!root_list_done)
        RootMoveList(wtm);
#if !defined(NOEGTB)
      if (EGTB_draw && !shared->puzzling && swindle_mode)
        EGTB_use = 0;
      else
        EGTB_use = EGTBlimit;
      if (EGTBlimit && !EGTB_use)
        Print(128, "Drawn at root, trying for swindle.\n");
#endif
      correct_count = 0;
      shared->burp = 15 * 100;
      shared->transposition_id = (shared->transposition_id + 1) & 7;
      if (!shared->transposition_id)
        shared->transposition_id++;
      shared->program_start_time = ReadClock();
      shared->start_time = ReadClock();
      shared->elapsed_start = ReadClock();
      shared->next_time_check = shared->nodes_between_time_checks;
      tree->evaluations = 0;
#if defined(HASHSTATS)
      tree->transposition_hits = 0;
      tree->transposition_good_hits = 0;
      tree->transposition_uppers = 0;
      tree->transposition_lowers = 0;
      tree->transposition_exacts = 0;
      tree->transposition_probes = 0;
#endif
      tree->egtb_probes = 0;
      tree->egtb_probes_successful = 0;
      tree->check_extensions_done = 0;
      tree->mate_extensions_done = 0;
      tree->one_reply_extensions_done = 0;
      tree->passed_pawn_extensions_done = 0;
      tree->reductions_attempted = 0;
      tree->reductions_done = 0;
      shared->root_wtm = wtm;
/*
 ************************************************************
 *                                                          *
 *  if there are no legal moves, it is either mate or draw  *
 *  depending on whether the side to move is in check or    *
 *  not (mate or stalemate.)                                *
 *                                                          *
 ************************************************************
 */
      if (shared->n_root_moves == 0) {
        shared->program_end_time = ReadClock();
        tree->pv[0].pathl = 0;
        tree->pv[0].pathd = 0;
        if (Check(wtm)) {
          shared->root_value = -(MATE - 1);
        } else {
          shared->root_value = DrawScore(wtm);
        }
        Print(6, "              depth   time  score   variation\n");
        Print(6, "                                    (no moves)\n");
        tree->nodes_searched = 1;
        if (!shared->puzzling)
          shared->last_root_value = shared->root_value;
        return (shared->root_value);
      }
/*
 ************************************************************
 *                                                          *
 *   now set the search time and iteratively call Search()  *
 *   to analyze the position deeper and deeper.  note that  *
 *   Search() is called with an alpha/beta window roughly   *
 *   1/3 of a pawn on either side of the score last         *
 *   returned by search.  also, after the first root move   *
 *   is searched, this window is collapsed to n and n+1     *
 *   (where n is the value for the first root move.)  often *
 *   a better move is found, which causes search to return  *
 *   <beta> as the score.  we then relax beta depending on  *
 *   its value:  if beta = alpha+1, set beta to alpha+1/3   *
 *   of a pawn;  if beta = alpha+1/3 pawn, then set beta to *
 *   + infinity.                                            *
 *                                                          *
 ************************************************************
 */
      TimeSet(search_type);
      shared->iteration_depth = 1;
      if (last_pv.pathd > 1)
        shared->iteration_depth = last_pv.pathd + 1;
      Print(6, "              depth   time  score   variation (%d)\n",
          shared->iteration_depth);
      shared->time_abort = 0;
      shared->abort_search = 0;
      shared->program_start_time = ReadClock();
      shared->start_time = ReadClock();
      shared->elapsed_start = ReadClock();
/*
 ************************************************************
 *                                                          *
 *   set the initial search bounds based on the last search *
 *   or default values.                                     *
 *                                                          *
 ************************************************************
 */
      tree->pv[0] = last_pv;
      if (shared->iteration_depth > 1) {
        shared->root_alpha = last_value - 40;
        shared->root_value = last_value - 40;
        shared->root_beta = last_value + 40;
      } else {
        shared->root_alpha = -MATE - 1;
        shared->root_value = -MATE - 1;
        shared->root_beta = MATE + 1;
      }
/*
 ************************************************************
 *                                                          *
 *   if we are using multiple threads, and they have not    *
 *   been started yet, then start them now as the search    *
 *   is ready to begin.                                     *
 *                                                          *
 ************************************************************
 */
      if (shared->max_threads > shared->smp_idle + 1) {
        long proc;

        for (proc = shared->smp_threads + 1; proc < shared->max_threads; proc++) {
          Print(128, "starting thread %d\n", proc);
          shared->thread[proc] = 0;
#if defined(_WIN32) || defined(_WIN64)
          NumaStartThread(ThreadInit, (void *) proc);
#else
          if (fork() == 0) {
            ThreadInit((void *) proc);
            exit(0);
          }
#endif
          shared->smp_threads++;
        }
      }
      WaitForAllThreadsInitialized();
      shared->root_print_ok = 0;
      if (search_nodes)
        shared->nodes_between_time_checks = search_nodes;
      for (; shared->iteration_depth <= MAXPLY - 5; shared->iteration_depth++) {
/*
 ************************************************************
 *                                                          *
 *   now install the old PV into the hash table so that     *
 *   these moves will be followed first.                    *
 *                                                          *
 ************************************************************
 */
        twtm = wtm;
        for (i = 1; i <= (int) tree->pv[0].pathl; i++) {
          tree->pv[i] = tree->pv[i - 1];
          if (!VerifyMove(tree, i, twtm, tree->pv[i].path[i])) {
            Print(4095, "ERROR, not installing bogus move at ply=%d\n", i);
            Print(4095, "not installing from=%d  to=%d  piece=%d\n",
                From(tree->pv[i].path[i]), To(tree->pv[i].path[i]),
                Piece(tree->pv[i].path[i]));
            break;
          }
          HashStorePV(tree, i, twtm);
          MakeMove(tree, i, tree->pv[0].path[i], twtm);
          twtm = Flip(twtm);
        }
        for (i--; i > 0; i--) {
          twtm = Flip(twtm);
          UnmakeMove(tree, i, tree->pv[0].path[i], twtm);
        }
        if (trace_level) {
          printf("==================================\n");
          printf("=      search iteration %2d       =\n",
              shared->iteration_depth);
          printf("==================================\n");
        }
        if (tree->nodes_searched) {
          shared->nodes_between_time_checks =
              shared->nodes_per_second / Max(1, shared->max_threads);
          shared->nodes_between_time_checks =
              Max(shared->nodes_between_time_checks, 50000);
          if (!analyze_mode) {
            if (shared->time_limit > 300);
            else if (shared->time_limit > 100)
              shared->nodes_between_time_checks /= 10;
            else if (shared->time_limit > 50)
              shared->nodes_between_time_checks /= 20;
            else
              shared->nodes_between_time_checks /= 100;
          } else
            shared->nodes_between_time_checks =
                Min(shared->nodes_per_second / Max(1, shared->max_threads),
                50000);
        }
        if (search_nodes)
          shared->nodes_between_time_checks =
              search_nodes - tree->nodes_searched;
        shared->nodes_between_time_checks =
            Min(shared->nodes_between_time_checks, MAX_TC_NODES);
        while (1) {
          shared->thread[0] = shared->local[0];
          value =
              SearchRoot(tree, shared->root_alpha, shared->root_beta, wtm,
              shared->iteration_depth * PLY + PLY / 2);
          shared->root_print_ok = tree->nodes_searched > shared->noise_level;
          if (shared->abort_search || shared->time_abort)
            break;
          if (value >= shared->root_beta) {
            if (!(shared->root_moves[0].status & 8)) {
              shared->root_moves[0].status |= 8;
            } else if (!(shared->root_moves[0].status & 16)) {
              shared->root_moves[0].status |= 16;
            } else {
              shared->root_moves[0].status |= 32;
            }
            shared->root_alpha =
                SetRootAlpha(shared->root_moves[0].status, shared->root_alpha);
            shared->root_value = shared->root_alpha;
            shared->root_beta =
                SetRootBeta(shared->root_moves[0].status, shared->root_beta);
            shared->root_moves[0].status &= 255 - 128;
            shared->root_moves[0].nodes = 0;
            if (shared->root_print_ok) {
              if (wtm) {
                fh_indicator = "+1";
                if (shared->root_moves[0].status & 16)
                  fh_indicator = "+3";
                if (shared->root_moves[0].status & 32)
                  fh_indicator = "+M";
              } else {
                fh_indicator = "-1";
                if (shared->root_moves[0].status & 16)
                  fh_indicator = "-3";
                if (shared->root_moves[0].status & 32)
                  fh_indicator = "-M";
              }
              Print(2, "               %2i   %s     %2s   ",
                  shared->iteration_depth,
                  DisplayTime(shared->end_time - shared->start_time),
                  fh_indicator);
              if (shared->display_options & 64)
                Print(2, "%d. ", shared->move_number);
              if ((shared->display_options & 64) && !wtm)
                Print(2, "... ");
              Print(2, "%s!!\n", OutputMove(tree, tree->pv[1].path[1], 1, wtm));
              shared->kibitz_text[0] = 0;
              if (shared->display_options & 64)
                sprintf(shared->kibitz_text, " %d.", shared->move_number);
              if ((shared->display_options & 64) && !wtm)
                sprintf(shared->kibitz_text + strlen(shared->kibitz_text),
                    " ...");
              sprintf(shared->kibitz_text + strlen(shared->kibitz_text),
                  " %s!!", OutputMove(tree, tree->pv[1].path[1], 1, wtm));
              Kibitz(6, wtm, shared->iteration_depth,
                  shared->end_time - shared->start_time, value,
                  tree->nodes_searched, tree->egtb_probes_successful,
                  shared->kibitz_text);
            }
          } else if (value <= shared->root_alpha) {
            if (!(shared->root_moves[0].status & 0x38)) {
              if (!(shared->root_moves[0].status & 1)) {
                shared->root_moves[0].status |= 1;
              } else if (!(shared->root_moves[0].status & 2)) {
                shared->root_moves[0].status |= 2;
              } else {
                shared->root_moves[0].status |= 4;
              }
              shared->root_alpha =
                  SetRootAlpha(shared->root_moves[0].status,
                  shared->root_alpha);
              shared->root_value = shared->root_alpha;
              shared->root_beta =
                  SetRootBeta(shared->root_moves[0].status, shared->root_beta);
              shared->root_moves[0].status &= 255 - 128;
              shared->root_moves[0].nodes = 0;
              shared->root_value = shared->root_alpha;
              shared->easy_move = 0;
              if (shared->root_print_ok && !shared->time_abort &&
                  !shared->abort_search) {
                if (wtm) {
                  fl_indicator = "-1";
                  if (shared->root_moves[0].status & 2)
                    fl_indicator = "-3";
                  if (shared->root_moves[0].status & 4)
                    fl_indicator = "-M";
                } else {
                  fl_indicator = "+1";
                  if (shared->root_moves[0].status & 2)
                    fl_indicator = "+3";
                  if (shared->root_moves[0].status & 4)
                    fl_indicator = "+M";
                }
                Print(4, "               %2i   %s     %2s   ",
                    shared->iteration_depth,
                    DisplayTime(ReadClock() - shared->start_time),
                    fl_indicator);
                if (shared->display_options & 64)
                  Print(4, "%d. ", shared->move_number);
                if ((shared->display_options & 64) && !wtm)
                  Print(4, "... ");
                Print(4, "%s\n", OutputMove(tree, shared->root_moves[0].move, 1,
                        wtm));
              }
            } else
              break;
          } else
            break;
        }
        if (shared->root_value > shared->root_alpha &&
            shared->root_value < shared->root_beta)
          shared->last_root_value = shared->root_value;
/*
 ************************************************************
 *                                                          *
 *   if we are running a test suite, check to see if we can *
 *   exit the search.  this happens when N successive       *
 *   iterations produce the correct solution.  N is set by  *
 *   the test command in Option().                          *
 *                                                          *
 ************************************************************
 */
        correct = solution_type;
        for (i = 0; i < number_of_solutions; i++) {
          if (!solution_type) {
            if (solutions[i] == tree->pv[0].path[1])
              correct = 1;
          } else if (solutions[i] == tree->pv[0].path[1])
            correct = 0;
        }
        if (correct)
          correct_count++;
        else
          correct_count = 0;
/*
 ************************************************************
 *                                                          *
 *   if the search terminated normally, then dump the PV    *
 *   and search statistics (we don't do this if the search  *
 *   aborts because the opponent doesn't make the predicted *
 *   move...)                                               *
 *                                                          *
 ************************************************************
 */
        twtm = wtm;
        shared->end_time = ReadClock();
        do {
          sorted = 1;
          for (i = 1; i < shared->n_root_moves - 1; i++) {
            if (shared->root_moves[i].nodes < shared->root_moves[i + 1].nodes) {
              temp = shared->root_moves[i];
              shared->root_moves[i] = shared->root_moves[i + 1];
              shared->root_moves[i + 1] = temp;
              sorted = 0;
            }
          }
        } while (!sorted);
/*
 ************************************************************
 *                                                          *
 *   notice if there are multiple moves that are producing  *
 *   large trees.  if so, don't search those in parallel by *
 *   setting the flag to avoid this.                        *
 *                                                          *
 ************************************************************
 */
        for (i = 0; i < shared->n_root_moves; i++)
          shared->root_moves[i].status = 0;
        if (shared->root_moves[0].nodes > 1000)
          for (i = 0; i < Min(shared->n_root_moves, 16); i++) {
            if (shared->root_moves[i].nodes > shared->root_moves[0].nodes / 3)
              shared->root_moves[i].status |= 64;
          }
/*
 ************************************************************
 *                                                          *
 *   if requested, print the ply=1 move list along with the *
 *   node counts for the tree each move produced.           *
 *                                                          *
 ************************************************************
 */
        if (shared->display_options & 256) {
          BITBOARD total_nodes = 0;

          Print(128, "       move       nodes      hi/low\n");
          for (i = 0; i < shared->n_root_moves; i++) {
            total_nodes += shared->root_moves[i].nodes;
            Print(128, " %10s  " BMF10 "       %d   %d\n", OutputMove(tree,
                    shared->root_moves[i].move, 1, wtm),
                shared->root_moves[i].nodes,
                (shared->root_moves[i].status & 0x38) > 0,
                (shared->root_moves[i].status & 7) > 0);
          }
          Print(256, "      total  " BMF10 "\n", total_nodes);
        }
        for (i = 0; i < shared->n_root_moves; i++)
          shared->root_moves[i].nodes = 0;
        if (shared->end_time - shared->start_time > 10)
          shared->nodes_per_second =
              tree->nodes_searched * 100 / (BITBOARD) (shared->end_time -
              shared->start_time);
        else
          shared->nodes_per_second = 1000000;
        if (!shared->time_abort && !shared->abort_search &&
            (shared->root_print_ok || correct_count >= early_exit ||
                value > MATE - 300 || tree->pv[0].pathh == 2)) {
          if (value != -(MATE - 1))
            DisplayPV(tree, 5, wtm, shared->end_time - shared->start_time,
                value, &tree->pv[0]);
        }
        shared->root_alpha = value - 40;
        shared->root_value = shared->root_alpha;
        shared->root_beta = value + 40;
        if (shared->iteration_depth > 3 && value > MATE - 300 &&
            value >= (MATE - shared->iteration_depth - 1) &&
            value > last_mate_score)
          break;
        if ((shared->iteration_depth >= search_depth) && search_depth)
          break;
        if (shared->time_abort || shared->abort_search)
          break;
        shared->end_time = ReadClock() - shared->start_time;
        if (shared->thinking && (int) shared->end_time >= shared->time_limit)
          break;
        if (correct_count >= early_exit)
          break;
#if !defined(NOEGTB)
        if (shared->iteration_depth > 3 && TotalPieces <= EGTBlimit && TB_use_ok
            && EGTB_use && !EGTB_search && EGTBProbe(tree, 1, wtm, &i))
          break;
#endif
        if (search_nodes && tree->nodes_searched >= search_nodes)
          break;
      }
/*
 ************************************************************
 *                                                          *
 *   search done, now display statistics, depending on the  *
 *   verbosity level set.                                   *
 *                                                          *
 ************************************************************
 */
      used = 0;
#if defined(HASHSTATS)
      for (i = 0; i < hash_table_size; i++) {
        if ((trans_ref + i)->prefer.word1 >> 61 == shared->transposition_id)
          used++;
        if ((trans_ref + i)->always[0].word1 >> 61 == shared->transposition_id)
          used++;
        if ((trans_ref + i)->always[1].word1 >> 61 == shared->transposition_id)
          used++;
      }
#endif
      shared->end_time = ReadClock();
      time_used = (shared->end_time - shared->start_time);
      if (time_used < 10)
        time_used = 10;
      shared->elapsed_end = ReadClock() - shared->elapsed_start;
      if (shared->elapsed_end > 10)
        shared->nodes_per_second =
            (BITBOARD) tree->nodes_searched * 100 /
            (BITBOARD) shared->elapsed_end;
      if (!tree->egtb_probes) {
        if (shared->average_nps)
          shared->average_nps =
              (9 * shared->average_nps + shared->nodes_per_second) / 10;
        else
          shared->average_nps = shared->nodes_per_second;
      }
      tree->evaluations = (tree->evaluations) ? tree->evaluations : 1;
      if ((!shared->abort_search || shared->time_abort) && !shared->puzzling) {
        tree->fail_high++;
        tree->fail_high_first++;
        material = Material / pawn_value;
        Print(8, "              time=%s  mat=%d",
            DisplayTimeKibitz(shared->end_time - shared->start_time), material);
        Print(8, "  n=" BMF, tree->nodes_searched);
        Print(8, "  fh=%u%%",
            (int) ((BITBOARD) tree->fail_high_first * 100 /
                (BITBOARD) tree->fail_high));

        Print(8, "  nps=%s\n", DisplayKM(shared->nodes_per_second));
        Print(16, "              ext-> check=%s ",
            DisplayKM(tree->check_extensions_done));
        Print(16, "1rep=%s ", DisplayKM(tree->one_reply_extensions_done));
        Print(16, "mate=%s ", DisplayKM(tree->mate_extensions_done));
        Print(16, "pp=%s ", DisplayKM(tree->passed_pawn_extensions_done));
        Print(16, "reduce=%s", DisplayKM(tree->reductions_attempted));

        Print(16, "/%s\n", DisplayKM(tree->reductions_done));
        Print(16, "              predicted=%d  evals=%s  50move=%d", predicted,
            DisplayKM(tree->evaluations), Rule50Moves(0));
        Print(16, "  EGTBprobes=%s  hits=%s\n", DisplayKM(tree->egtb_probes),
            DisplayKM(tree->egtb_probes_successful));
#if defined(HASHSTATS)
        Print(16,
            "              hashing-> %d%%(raw) %d%%(draftOK) "
            " %d%%(saturation)\n",
            (int) (100 * (BITBOARD) tree->transposition_hits /
                (BITBOARD) (tree->transposition_probes + 1)),
            (int) (100 * (BITBOARD) tree->transposition_good_hits /
                (BITBOARD) (tree->transposition_probes + 1)),
            used * 100 / (3 * hash_table_size + 1));
        Print(16,
            "              hashing-> %d%%(exact)  %d%%(lower)  %d%%(upper)\n",
            (int) (100 * (BITBOARD) tree->transposition_exacts /
                (BITBOARD) (tree->transposition_probes + 1)),
            (int) (100 * (BITBOARD) tree->transposition_lowers /
                (BITBOARD) (tree->transposition_probes + 1)),
            (int) (100 * (BITBOARD) tree->transposition_uppers /
                (BITBOARD) (tree->transposition_probes + 1)));
#endif
        Print(16, "              SMP->  splits=%d  aborts=%d  data=%d/%d  ",
            shared->parallel_splits, shared->parallel_aborts,
            shared->max_split_blocks, MAX_BLOCKS);
        Print(16, "elap=%s\n", DisplayTimeKibitz(shared->elapsed_end));
      }
    } while (0);
  else {
    shared->last_root_value = 0;
    shared->root_value = 0;
    book_move = 1;
    tree->pv[0] = tree->pv[1];
    if (analyze_mode)
      Kibitz(4, wtm, 0, 0, 0, 0, 0, shared->kibitz_text);
  }
  shared->program_end_time = ReadClock();
  search_move = 0;
  return (shared->last_root_value);
}

/*
 *******************************************************************************
 *                                                                             *
 *   SetRootAlpha() is used to set the root alpha value by looking at the move *
 *   status to see how many times this move has failed low.  The first fail    *
 *   drops alpha by -1.0.  The second fail low drops it by another -2.0, and   *
 *   the third fail low drops it to -infinity.                                 *
 *                                                                             *
 *******************************************************************************
 */
int SetRootAlpha(unsigned char status, int old_root_alpha)
{
  if (status & 4)
    return (-MATE - 1);
  if (status & 2)
    return (old_root_alpha - 200);
  if (status & 1)
    return (old_root_alpha - 100);
  return (old_root_alpha);
}

/*
 *******************************************************************************
 *                                                                             *
 *   SetRootBeta() is used to set the root beta value by looking at the move   *
 *   status to see how many times this move has failed high.  The first fail   *
 *   raises alpha by 1.0.  The second fail raises it by another 2.0, and       *
 *   the third fail raises it to +infinity.                                    *
 *                                                                             *
 *******************************************************************************
 */
int SetRootBeta(unsigned char status, int old_root_beta)
{
  if (status & 32)
    return (MATE + 1);
  if (status & 16)
    return (old_root_beta + 200);
  if (status & 8)
    return (old_root_beta + 100);
  return (old_root_beta);
}
