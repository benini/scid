#ifdef _MSC_VER
#pragma warning(disable: 4996)
#endif

#include <assert.h>
#include <malloc.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "commands.h"
#include "eval.h"
#include "moves.h"
#include "position.h"
#include "search.h"
#include "utils.h"

#define CHECK_QUANT (0x3ff)
#define  ROOT_WINDOW (VAL_PAWN)

#define  HASH_SINGLE_MOVE  (0x01)
#define  HASH_MATE_THREAT  (0x02)

#define  HASH_ALPHA    (0x10)
#define  HASH_BETA     (0x20)
#define  HASH_EXACT    (0x40)
#define  HASH_NOT_EVAL (0x80)

#define  max(x, y) (((x) < (y))? (y) : (x))

const EVAL CHECKMATE_SCORE = 32767;

const double DEFAULT_HASH_MB = 64.0;

static Position pos;
static MoveList moves[MAX_PLY];

int g_iter = 0;

vector<Move> g_PV[MAX_PLY + 2];
vector<Move> g_rootPV;

int g_multipv_size = 1;
MultiPVEntry g_multipv_storage[MAX_BRANCH];

HashEntry* g_hash = NULL;
long g_hash_size = 0;
U8 g_hash_age = 0;

#define MAX_HISTORY  (8192)
int g_history[14][64];
void update_history(Move mv, int depth);
Move g_killers[MAX_PLY + 2];

PawnHashEntry* g_pawn_hash = NULL;
long g_pawn_hash_size = 0;

NODES g_nodes = 0;
NODES g_qnodes = 0;
clock_t g_start_time = 0;

Limits g_limits = {2000, 2000, MAX_PLY, 0};

#define TERMINATE_SEARCH (1)
#define FINALIZE_SEARCH  (2)
int g_flag = 0;

#define MODE_ANALYZE (1)
#define MODE_THINKING_ON_MOVE (2)
#define MODE_EPDTEST (3)
int g_mode = 0;

extern int g_uci;

EVAL alpha_beta_root(Position& pos0, EVAL alpha, EVAL beta, const int depth);
EVAL alpha_beta(EVAL alpha, EVAL beta, const int depth, int ply, int null_search);
EVAL alpha_beta_q(EVAL alpha, EVAL beta, int ply, int qply);
void check_user_input_and_time();
Move get_nth_move(int n0, int ply);
void update_move_scores(int ply, Move hash_mv);

EVAL alpha_beta_root(Position& pos0, EVAL alpha, EVAL beta, const int depth)
{
	pos = pos0;

	int ply = 0;
	bool in_check = pos.InCheck();

	g_hash_age++;
	g_PV[ply].clear();
	g_nodes++;

	int J = 0;
	for (J = 0; J < MAX_BRANCH; J++)
	{
		g_multipv_storage[J].m_score = - INFINITY_SCORE;
		g_multipv_storage[J].m_pv.clear();
	}

	Move hash_mv = 0;
	U8 hash_flags = 0;
	U8 hash_type = HASH_ALPHA;
	HashEntry* pentry = probe_hash(&pos);
	if (pentry)
	{
		hash_mv = pentry->mv;
		hash_flags = pentry->flags;
	}

	MoveList& mvlist = moves[ply];
	mvlist.GenAllMoves(pos);
	mvlist.UpdateScores(pos, hash_mv, g_killers[ply]);

	//
	//   CYCLE BY ALL MOVES
	//

	EVAL e = 0;
	int legal_moves = 0;
	Move best_mv = 0;

	for (int i = 0; i < mvlist.Size(); ++i)
	{
		Move mv = mvlist.GetNthBest(i);

		if (pos.MakeMove(mv))
		{
			legal_moves++;

			long tm = (int) (1000 * (clock() - g_start_time) / CLOCKS_PER_SEC);
			if (g_uci && tm > 1000)
			{
				char mvbuf[16];
				OUT1("info currmove %s", move_to_str(mv, mvbuf));
				OUT1(" currmovenumber %d\n", legal_moves);
			}

			int new_depth = depth - 1;

			bool gives_check = pos.InCheck();
			if (gives_check)
				++new_depth;
			else if (mv.Piece() == PAWNW && (mv.To() / 8) == 1)
				++new_depth;
			else if (mv.Piece() == PAWNB && (mv.To() / 8) == 6)
				++new_depth;

			if (g_multipv_size > 1)
				e = - alpha_beta(-beta - VAL_QUEEN, -alpha + VAL_QUEEN, new_depth, ply + 1, 0);
			else
			{
				if (legal_moves == 1)
					e = - alpha_beta(-beta, -alpha, new_depth, ply + 1, 0);
				else
				{
					e = - alpha_beta(- alpha - 1, -alpha, new_depth, ply + 1, 0);
					if (e > alpha && e < beta)
						e = - alpha_beta(-beta, -alpha, new_depth, ply + 1, 0);
				}
			}

			pos.UnmakeMove();

			if (g_flag)
				return alpha;

			if (legal_moves == 1)
			{
				best_mv = mv;
				g_PV[ply].clear();
				g_PV[ply].push_back(mv);
				g_PV[ply].insert(g_PV[ply].end(), g_PV[ply + 1].begin(), g_PV[ply + 1].end());
			}

			//
			//   Update multipv
			//

			if (legal_moves < MAX_BRANCH)
			{
				MultiPVEntry *mpv = &(g_multipv_storage[legal_moves - 1]);
				
				mpv->m_pv.clear();
				mpv->m_score = e;
				mpv->m_pv.push_back(mv);
				mpv->m_pv.insert(mpv->m_pv.end(), g_PV[ply + 1].begin(), g_PV[ply + 1].end());
			}

			if (e > alpha)
			{
				best_mv = mv;
				update_history(mv, depth);
				hash_type = HASH_EXACT;

				g_PV[ply].clear();
				g_PV[ply].push_back(mv);
				g_PV[ply].insert(g_PV[ply].end(), g_PV[ply + 1].begin(), g_PV[ply + 1].end());

				alpha = e;

				if (alpha >= beta)
				{
					hash_type = HASH_BETA;
					if (!mv.Captured() && !mv.Promotion())
						g_killers[ply] = mv;

					break;
				}
			}
		}
	}

	if (legal_moves == 0)
	{
		if (in_check)
			alpha = - CHECKMATE_SCORE + ply;
		else
			alpha = DRAW_SCORE;
	}

	record_hash(&pos, best_mv, depth, alpha, hash_type, hash_flags, ply);

	return alpha;
}
////////////////////////////////////////////////////////////////////////////////

EVAL alpha_beta(EVAL alpha, EVAL beta, const int depth, int ply, int null_search)
{
	g_PV[ply].clear();
	g_nodes++;

	if (((g_nodes + g_qnodes) & CHECK_QUANT) == 0)
		check_user_input_and_time();

	//
	//   DRAW DETECTION
	//

	if (ply >= MAX_PLY)
		return DRAW_SCORE;

	if (pos.IsDraw())
		return DRAW_SCORE;

	if (!null_search)
	{
		int rep_total = pos.GetRepetitions();
		if (rep_total >= 2)
			return DRAW_SCORE;
	}

	//
	//   PROBING HASH
	//

	Move hash_mv = 0;
	U8 hash_flags = 0;
	U8 hash_type = HASH_ALPHA;
	HashEntry* pentry = probe_hash(&pos);

	if (pentry)
	{
		hash_mv = pentry->mv;
		hash_flags = pentry->flags;

		if (pentry->depth >= depth && pentry->age == g_hash_age)
		{
			EVAL hash_eval = pentry->eval;
			if (hash_eval > CHECKMATE_SCORE - 50)
				hash_eval -= ply;
			else if (hash_eval < - CHECKMATE_SCORE + 50)
				hash_eval += ply;

			if (pentry->type == HASH_EXACT)
				return hash_eval;
			else if (pentry->type == HASH_ALPHA && hash_eval <= alpha)
				return alpha;
			else if (pentry->type == HASH_BETA && hash_eval >= beta)
				return beta;
		}
	}

	//
	//   QSEARCH
	//

	bool in_check = pos.InCheck();
	if (!in_check)
	{
		if (depth <= 0)
		{
			g_nodes--;
			return alpha_beta_q(alpha, beta, ply, 0);
		}
	}

	//
	//   NULLMOVE
	//

	const int R = 4;
	do
	{
		if (null_search || in_check || depth <= 1) break;
		if (!pos.Count(ROOKW | pos.Side()) && !pos.Count(QUEENW | pos.Side())) break;

		pos.MakeNullMove();
		EVAL null_eval = - alpha_beta(- beta, - beta + 1, depth - R, ply + 1, 1);
		pos.UnmakeNullMove();

		if (null_eval >= beta)
		{
			return beta;
		}

		if (null_eval <= - CHECKMATE_SCORE + ply + 2)
			hash_flags |= HASH_MATE_THREAT;
	}
	while (0);

	MoveList& mvlist = moves[ply];
	mvlist.GenAllMoves(pos);
	mvlist.UpdateScores(pos, hash_mv, g_killers[ply]);

	//
	//   CYCLE BY ALL MOVES
	//

	int legal_moves = 0;
	EVAL e = 0;
	Move best_mv = 0;

	for (int i = 0; i < mvlist.Size(); ++i)
	{
		Move mv = mvlist.GetNthBest(i);

		if (pos.MakeMove(mv))
		{
			legal_moves++;
			int new_depth = depth - 1;

			bool gives_check = pos.InCheck();
			if (gives_check)
				++new_depth;
			else if (mv.Piece() == PAWNW && (mv.To() / 8) == 1)
				++new_depth;
			else if (mv.Piece() == PAWNB && (mv.To() / 8) == 6)
				++new_depth;

			do
			{
				if (depth <= 2) break;
				if (in_check || gives_check) break;
				if (mv.Captured() || mv.Promotion()) break;
				if (legal_moves < 3) break;
				if (mv == g_killers[ply]) break;

				--new_depth;
			}
			while (0);

			if (legal_moves == 1)
				e = - alpha_beta(- beta, - alpha, new_depth, ply + 1, 0);
			else
			{
				e = - alpha_beta(- alpha - 1, - alpha, new_depth, ply + 1, 0);
				if (e > alpha && e < beta)
					e = - alpha_beta(- beta, - alpha, new_depth, ply + 1, 0);
			}

			if (new_depth < depth - 1 && e > alpha)
				e = - alpha_beta(- beta, - alpha, new_depth + 1, ply + 1, 0);

			pos.UnmakeMove();

			if (g_flag)
				return alpha;

			if (e > alpha)
			{
				best_mv = mv;
				update_history(mv, depth);
				hash_type = HASH_EXACT;

				g_PV[ply].clear();
				g_PV[ply].push_back(mv);
				g_PV[ply].insert(g_PV[ply].end(), g_PV[ply + 1].begin(), g_PV[ply + 1].end());

				alpha = e;
				if (alpha >= beta)
				{
					hash_type = HASH_BETA;
					if (!mv.Captured() && !mv.Promotion())
						g_killers[ply] = mv;

					break;
				}
			}
		}
	}

	if (in_check && legal_moves == 1 && alpha < beta)
		hash_flags |= HASH_SINGLE_MOVE;

	if (legal_moves == 0)
	{
		if (in_check)
			alpha = - CHECKMATE_SCORE + ply;
		else
			alpha = DRAW_SCORE;
	}
	else if (pos.Fifty() >= 100)
		alpha = DRAW_SCORE;

	record_hash(&pos, best_mv, depth, alpha, hash_type, hash_flags, ply);

	return alpha;
}
////////////////////////////////////////////////////////////////////////////////

EVAL alpha_beta_q(EVAL alpha, EVAL beta, int ply, int qply)
{
	g_PV[ply].clear();
	g_qnodes++;

	if (((g_nodes + g_qnodes) & CHECK_QUANT) == 0)
		check_user_input_and_time();

	if (ply >= MAX_PLY)
		return DRAW_SCORE;

	bool in_check = pos.InCheck();
	if (!in_check)
	{
		EVAL static_eval = evaluate(pos, alpha, beta);
		if (static_eval > alpha)
		{
			alpha = static_eval;
			if (alpha >= beta)
				return beta;
		}
	 }

	MoveList& mvlist = moves[ply];

	if (in_check)
		mvlist.GenAllMoves(pos);
	else
	{
		mvlist.GenCapturesAndPromotions(pos);
		if (qply <= 2)
			mvlist.AddSimpleChecks(pos);
	}

	mvlist.UpdateScores(pos, 0, g_killers[ply]);


	//
	//   CYCLE BY ALL MOVES
	//

	EVAL e = 0;
	int legal_moves = 0;

	for (int i = 0; i < mvlist.Size(); ++i)
	{
		Move mv = mvlist.GetNthBest(i);

		if (!in_check && qply > 0)
		{
			EVAL see = SEE(pos, mv);
			if (see < 0)
				continue;
		}

		if (pos.MakeMove(mv))
		{
			legal_moves++;
			e = - alpha_beta_q(- beta, - alpha, ply + 1, qply + 1);
			pos.UnmakeMove();

			if (g_flag)
				return alpha;

			if (e > alpha)
			{
				g_PV[ply].clear();
				g_PV[ply].push_back(mv);
				g_PV[ply].insert(g_PV[ply].end(), g_PV[ply + 1].begin(), g_PV[ply + 1].end());

				alpha = e;
				if (alpha >= beta)
					break;
			}
		}
	}

	if (in_check && legal_moves == 0)
		alpha = - CHECKMATE_SCORE + ply;

	return alpha;
}
////////////////////////////////////////////////////////////////////////////////

void check_user_input_and_time()
{
   if (/*1000 * (clock() - g_start_time) / CLOCKS_PER_SEC*/ (get_time()-g_start_time) >= g_limits.stHard)
	{
		if (g_mode == MODE_THINKING_ON_MOVE || g_mode == MODE_EPDTEST)
			g_flag = FINALIZE_SEARCH;
	}

		char s[BUFSIZE];
		read_input(s, sizeof(s));

   if (s[0] != '\0')//(input_available())
   {
		if (g_mode == MODE_ANALYZE)
		{
			if (is_command(s, "board", 1))
				g_pos.Print();
			else if (is_command(s, "quit", 1))
				exit(0);
			else if (is_command(s, "isready", 7))
				out("readyok\n");
			else if (is_command(s, "exit", 2))
				g_flag = TERMINATE_SEARCH;
			else if (is_command(s, "stop", 2))
				g_flag = TERMINATE_SEARCH;
			else if (is_command(s, "new", 3))
				g_flag = TERMINATE_SEARCH;
			else if (is_command(s, "setoption", 8))
			{
				char *token = strtok(s, " ");
				token = strtok(NULL, " ");
				token = strtok(NULL, " ");
				if (token && !strcmp(token, "MultiPV"))
				{
					token = strtok(NULL, " ");
					token = strtok(NULL, " ");
					g_multipv_size = atoi(token);
				}
			}
		}

		else if (g_mode == MODE_THINKING_ON_MOVE)
		{
			if (is_command(s, "quit", 1))
				exit(0);
			else if (is_command(s, "isready", 7))
				out("readyok\n");
			else if (is_command(s, "?", 1))
				g_flag = FINALIZE_SEARCH;
			else if (is_command(s, "stop", 4))
				g_flag = FINALIZE_SEARCH;
			else if (is_command(s, "new", 3))
				g_flag = TERMINATE_SEARCH;
			else if (is_command(s, "result", 6))
				g_flag = TERMINATE_SEARCH;
			else if (is_command(s, "setoption", 8))
			{
				char *token = strtok(s, " ");
				token = strtok(NULL, " ");
				token = strtok(NULL, " ");
				if (token && !strcmp(token, "MultiPV"))
				{
					token = strtok(NULL, " ");
					token = strtok(NULL, " ");
					g_multipv_size = atoi(token);
				}
			}
		}

		else if (g_mode == MODE_EPDTEST)
		{
			if (is_command(s, "board", 1))
				g_pos.Print();
			else if (is_command(s, "quit", 1))
				exit(0);
			else if (is_command(s, "exit", 2))
				g_flag = TERMINATE_SEARCH;
			else if (is_command(s, "new", 3))
				g_flag = TERMINATE_SEARCH;
		}
	}
}
////////////////////////////////////////////////////////////////////////////////

void clear_history()
{
	for (int m = 0; m < MAX_PLY; m++)
		g_killers[m] = 0;

	for (int p = 0; p < 14; p++)
		for (int f = 0; f < 64; f++)
			g_history[p][f] = 0;
}
////////////////////////////////////////////////////////////////////////////////

/*void epdtest(FILE* psrc, double time_in_seconds, int reps)
{
	char fen[256];
	Position tmp = g_pos;

	g_limits.stSoft = int(1000 * time_in_seconds);
	g_limits.stHard = int(1000 * time_in_seconds);
	g_limits.sd = MAX_PLY;

	int total = 0, solved = 0;
	double sqtime = 0.0, sec = 0.0;

	while (fgets(fen, 256, psrc))
	{
		int res = g_pos.SetFEN(fen);
		out(fen);
		out("\n");

		if (!res)
		{
			g_pos = tmp;
			return;
		}

		if (!start_epd(g_pos, fen, reps, &total, &solved, &sec))
		{
			g_pos = tmp;
			return;
		}

		sqtime += sec * sec;
		OUT1("\nScore: %d / ", solved);
		OUT1("%d\n", total);
		OUT1("<Sq. time> = %lf\n\n", sqtime / total);

		if (g_flag == TERMINATE_SEARCH)
			break;
	}

	g_pos = tmp;
}*/
////////////////////////////////////////////////////////////////////////////////

void init_hash()
{
	g_hash_size = long (0.95 * DEFAULT_HASH_MB * 1024.0 / sizeof(HashEntry));
	g_hash = new HashEntry[g_hash_size];

	if (!g_uci)
	{
		OUT1("main hash: %8ld nodes = ", g_hash_size);
      OUT1("%.2lf MB\n", g_hash_size * sizeof(HashEntry) / 1024.0);
	}

	g_pawn_hash_size = long (0.05 * DEFAULT_HASH_MB * 1024.0 / sizeof(PawnHashEntry));
	g_pawn_hash = new PawnHashEntry[g_pawn_hash_size];

	if (!g_uci)
	{
		OUT1("pawn hash: %8ld nodes = ", g_pawn_hash_size);
      OUT1("%.2lf MB\n", g_pawn_hash_size * sizeof(PawnHashEntry) / 1024.0);
	}

	g_pawn_hash[0].pawn_hash = 1; // hack
}
////////////////////////////////////////////////////////////////////////////////

// NODES perft(Position* pos, int depth)
// {
//    if (depth == 0)
//       return 1;
// 
//    gen_moves(pos, depth);
//    NODES sum = 0, delta = 0;
// 
//    for (int i = 0; i < g_moves_cnt[depth]; i++)
//    {
//       Move mv = g_moves[depth][i].mv;
//       if (make_move(pos, mv))
//       {
//          delta = perft(pos, depth - 1);
//          sum += delta;
//          unmake_move(pos);
//       }
//    }
// 
//    return sum;
// }
////////////////////////////////////////////////////////////////////////////////

void PrintPV(const Position* pos, int iter, EVAL e, const char* comment)
{
	char buf[16];
	Move mv = 0;
   long tm = get_time() - g_start_time;//(int) (1000 * (clock() - g_start_time) / CLOCKS_PER_SEC);
	long nodes = g_nodes + g_qnodes;

	if (g_uci)
	{
		int J = 0;
		for (J = 0; J < MAX_BRANCH; J++)
			g_multipv_storage[J].m_seen = false;

		for (J = 1; J <= g_multipv_size; J++)
		{
			EVAL best_score = - INFINITY_SCORE;
			MultiPVEntry *best_mpv = NULL;	
			MultiPVEntry *mpv = NULL;

			for (int K = 0; K < MAX_BRANCH; K++)
			{
				mpv = &(g_multipv_storage[K]);
				if (mpv->m_seen)
					continue;

				if (mpv->m_pv.empty())
					break;

				if (mpv->m_score > best_score)
				{
					best_score = mpv->m_score;
					best_mpv = mpv;
				}
			}

			if (best_mpv)
			{
				best_mpv->m_seen = true;

				mpv = best_mpv;
				OUT1("info multipv %d ", J);
				OUT1("depth %d ", iter);
				out("score");
				if (mpv->m_score > CHECKMATE_SCORE - 50)
				{
					OUT1(" mate %d", 1 + (CHECKMATE_SCORE - mpv->m_score) / 2);
				}
				else if (mpv->m_score < - CHECKMATE_SCORE + 50)
				{
					OUT1(" mate -%d", (mpv->m_score + CHECKMATE_SCORE) / 2);
				}
				else
					OUT1(" cp %d", mpv->m_score);

				OUT1(" nodes %ld", nodes);
				OUT1(" time %ld", tm);
				if (tm > 0)
				{
					OUT1("info time %ld", tm);
					OUT1(" nodes %ld", nodes);
					long knps = nodes / tm;
					OUT1(" nps %ld", (1000 * knps));
				}
				out(" pv ");
				for (size_t m = 0; m < mpv->m_pv.size(); ++m)
				{
					mv = mpv->m_pv[m];
					OUT1("%s ", move_to_str(mv, buf));
				}
				out("\n");
			}
		}
		if (tm > 0)
		{
			OUT1("info time %ld", tm);
			OUT1(" nodes %ld", nodes);
			long knps = nodes / tm;
			OUT1(" nps %ld\n", (1000 * knps));
		}
		return;
	}
	else
	{
		OUT1(" %2d", iter);
		OUT1(" %9d ", e);
      OUT1(" %7d ", (int)((get_time() - g_start_time)/10) );//(int) (100 * (clock() - g_start_time) / CLOCKS_PER_SEC));
		OUT1(" %12d ", g_nodes + g_qnodes);
		out("	");
	}

	Position tmp = *pos;

	int movenum = tmp.Ply() / 2 + 1;
	for (size_t m = 0; m < g_rootPV.size(); ++m)
	{
		mv = g_rootPV[m];
		if (tmp.Side() == WHITE)
		{
			OUT1("%d. ", movenum++);
		}
		else if (m == 0)
		{
			OUT1("%d. ... ", movenum++);
		}

		OUT1("%s", move_to_str_san(tmp, mv, buf));
		tmp.MakeMove(mv);

		if (tmp.InCheck())
		{
			if (int(e + m + 1) == CHECKMATE_SCORE || int(e - m - 1) == - CHECKMATE_SCORE)
			{
				out("#");

				if (e > 0)
					out(" {+");
				else
					out(" {-");

				OUT1("Mate in %d}", m / 2 + 1);
			}
			else
				out("+");
		}

		if (m == 0)
			out(comment);

		out(" ");
	}

	out("\n");
}
////////////////////////////////////////////////////////////////////////////////

HashEntry* probe_hash(const Position* pos)
{
	long index = long(pos->Hash() % g_hash_size);
	if (g_hash[index].hashLock == U32(pos->Hash() & LL(0xffffffff)))
		return g_hash + index;
	else
		return NULL;
}
////////////////////////////////////////////////////////////////////////////////

void record_hash(const Position* pos, Move best_mv,
                 U16 depth, EVAL eval, U8 type,
                 U8 flags, int ply)
{
	long index = long(pos->Hash() % g_hash_size);
	HashEntry* pentry = g_hash + index;

	if (pentry->age == g_hash_age && pentry->depth > depth)
		return;

	if (eval > CHECKMATE_SCORE - 50)
		eval += ply;

	else if (eval < - CHECKMATE_SCORE + 50)
		eval -= ply;

	pentry->age = g_hash_age;
	pentry->depth = depth;
	pentry->eval = eval;
	pentry->flags = flags;
	pentry->hashLock = U32(pos->Hash() & LL(0xffffffff));
	pentry->mv = best_mv;
	pentry->type = type;
}
////////////////////////////////////////////////////////////////////////////////

void resize_hash(int size_in_mb)
{
	delete[] g_hash;
	delete[] g_pawn_hash;

	g_hash_size = long (0.95 * size_in_mb * 1024.0 / sizeof(HashEntry));
	g_hash = new HashEntry[g_hash_size];

	if (!g_uci)
	{
		OUT1("main hash: %8ld nodes = ", g_hash_size);
      OUT1("%.2lf MB\n", g_hash_size * sizeof(HashEntry) / 1024.0);
	}

	g_pawn_hash_size = long (0.05 * size_in_mb * 1024.0 / sizeof(PawnHashEntry));
	g_pawn_hash = new PawnHashEntry[g_pawn_hash_size];

	if (!g_uci)
	{
		OUT1("pawn hash: %8ld nodes = ", g_pawn_hash_size);
      OUT1("%.2lf MB\n", g_pawn_hash_size * sizeof(PawnHashEntry) / 1024.0);
	}

	g_pawn_hash[0].pawn_hash = 1; // hack
}
////////////////////////////////////////////////////////////////////////////////

void start_analyze(const Position& pos0)
{
	g_mode = MODE_ANALYZE;
	g_flag = 0;

	g_nodes = 0;
	g_qnodes = 0;
   g_start_time = get_time(); //clock();

	Position pos = pos0;
	clear_history();

	if (!g_uci)
	{
		char fen[BUFSIZE];
		get_fen(&pos0, fen);
		out("\n");
		out(fen);
		out("\n\n");
	}

	EVAL alpha = - INFINITY_SCORE;
	EVAL beta = INFINITY_SCORE;

	for (g_iter = 1; g_iter < MAX_PLY; g_iter++)
	{
		int print_iter = g_iter;

		EVAL e = alpha_beta_root(pos, alpha, beta, g_iter);

		if (g_flag)
			break;

		if (e > alpha)
		{
			g_rootPV = g_PV[0];
		}

		if (e > alpha && e < beta)
		{
			PrintPV(&pos, print_iter, e, "");

			alpha = e - ROOT_WINDOW / 2;
			beta = e + ROOT_WINDOW / 2;
		}
		else
		{
			PrintPV(&pos, print_iter, e, (e <= alpha)? "?" : "!");

			alpha = - INFINITY_SCORE;
			beta = INFINITY_SCORE;
			g_iter--;
		}
	}
}
////////////////////////////////////////////////////////////////////////////////

// int start_epd(const Position* pos0, const char* fen,
//               int reps, int* ptotal, int* psolved, double* psec)
// {
//    g_mode = MODE_EPDTEST;
//    g_flag = 0;
// 
//    g_nodes = 0;
//    g_qnodes = 0;
//    g_start_time = clock();
// 
//    Position* pos = new_pos();
//    copy_pos(pos, pos0);
//    clear_history();
// 
//    int good_iters = 0;
//    int sufficient_iters = reps;
//    int prev_iter = 0;
// 
//    EVAL alpha = - INFINITY_SCORE;
//    EVAL beta = INFINITY_SCORE;
// 
//    *psec = g_limits.st / 1000.;
// 
//    for (g_iter = 1; g_iter < MAX_PLY; g_iter++)
//    {
//       int print_iter = g_iter;
// 
//       int move_found = 0;
//       EVAL score = alpha_beta_root(pos, alpha, beta, PLY * g_iter);
// 
//       if (g_flag)
//          break;
// 
//       if (score > alpha)
//       {
//          g_root_pv_length = g_pv_length[0];
//          for (int m = 0; m < g_pv_length[0]; m++)
//             g_root_pv[m] = g_pv[0][m];
//       }
// 
//       if (g_root_pv_length)
//       {
//          Move mv = g_root_pv[0];
//          char mvstr[16];
//          move_to_str_san(pos, mv, mvstr);
// 
//          if (strstr(fen, mvstr) != NULL)
//             move_found = 1;
//          else
//          {
//             move_to_str(mv, mvstr);
//             if (strstr(fen, mvstr) != NULL)
//                move_found = 1;
//          }
// 
//          if (strstr(fen, "am") && !strstr(fen, "bm"))
//             move_found = 1 - move_found;
//       }
// 
//       char comment[3] = "";
// 
//       if (score > alpha && score < beta)
//       {
//          strcpy(comment, "");
//          alpha = score - ROOT_WINDOW / 2;
//          beta = score + ROOT_WINDOW / 2;
//       }
//       else
//       {
//          strcpy(comment, (score <= alpha)? "?" : "!");
//          alpha = - INFINITY_SCORE;
//          beta = INFINITY_SCORE;
//          g_iter--;
//       }
// 
//       if (!move_found)
//       {
//          good_iters = 0;
//       }
//       else if (g_iter > prev_iter)
//       {
//          good_iters++;
//          prev_iter = g_iter;
//       }
// 
//       if (move_found)
//       {
// //          set_highlight(1);
//          out(" yes ");
// //          set_highlight(0);
// 
//          if (good_iters == 1)
//             *psec = ((double) (clock() - g_start_time)) / CLOCKS_PER_SEC;
//       }
//       else
//       {
//          out("  no ");
//          *psec = g_limits.st / 1000.;
//       }
// 
//       int complete_iter = (score > alpha && score < beta);
// 
//       if (good_iters >= sufficient_iters && complete_iter)
// //          set_highlight(1);
// 
//       print_pv(pos, print_iter, score, g_pv[0], g_pv_length[0], comment);
// //       set_highlight(0);
// 
//       if (good_iters >= sufficient_iters && complete_iter)
//          break;
//    }
//    free_pos(pos);
// 
//    (*ptotal)++;
//    if (good_iters > 0)
//       (*psolved)++;
// 
//    return 1;
// }
////////////////////////////////////////////////////////////////////////////////

void start_thinking_on_move(Position& pos0)
{
	g_mode = MODE_THINKING_ON_MOVE;
	g_flag = 0;

	g_nodes = 0;
	g_qnodes = 0;
   g_start_time = get_time();//clock();

	Position pos = pos0;

	clear_history();

	if (!g_uci)
	{
		char fen[BUFSIZE];
		get_fen(&pos0, fen);
		out("\n");
		out(fen);
		out("\n\n");
	}

	EVAL alpha = - INFINITY_SCORE;
	EVAL beta = INFINITY_SCORE;

	Move best_move = 0;
	for (g_iter = 1; g_iter < MAX_PLY; g_iter++)
	{
		int print_iter = g_iter;
		EVAL e = alpha_beta_root(pos, alpha, beta, g_iter);

		if (g_flag)
			break;

		char comment[3] = "";

		if (e > alpha)
		{
			g_rootPV = g_PV[0];
		}

		if (e > alpha && e < beta)
		{
			strcpy(comment, "");
			alpha = e - ROOT_WINDOW / 2;
			beta = e + ROOT_WINDOW / 2;

         if ( /*1000 * (clock() - g_start_time) / CLOCKS_PER_SEC*/get_time() - g_start_time >= g_limits.stSoft)
			{
				g_flag = FINALIZE_SEARCH;
			}
		}
		else
		{
			strcpy(comment, (e <= alpha)? "?" : "!");
			alpha = - INFINITY_SCORE;
			beta = INFINITY_SCORE;
			g_iter--;
		}

		PrintPV(&pos, print_iter, e, comment);
		best_move = g_rootPV[0];

		if (e > CHECKMATE_SCORE - 50)
			g_flag = FINALIZE_SEARCH;
	}

	if (!g_flag && g_iter == MAX_PLY && best_move)
		g_flag = FINALIZE_SEARCH;

	if (g_flag == FINALIZE_SEARCH)
	{
		char buf[16];
		if (g_uci)
		{
         out("\n");
         OUT1("bestmove %s\n", move_to_str(best_move, buf));
		}
		else
		{
//          set_highlight(1);
         out("\n");
         OUT1("move %s\n", move_to_str(best_move, buf));
//          set_highlight(0);
		}

		pos0.MakeMove(best_move);
	}
}
////////////////////////////////////////////////////////////////////////////////

// void start_perft(const Position* pos0, int depth)
// {
//    Position* pos = new_pos();
//    copy_pos(pos, pos0);
//    int e1 = 9 * pos->count[QUEENW] +
//             5 * pos->count[ROOKW] +
//             3 * (pos->count[BISHOPW] +
//                 pos->count[KNIGHTW]) + pos->count[PAWNW];
// 
//    clock_t t0 = clock();
// 
//    gen_moves(pos, depth);
//    NODES sum = 0, delta = 0;
//    out("\n");
// 
//    int i = 0;
//    for (i = 0; i < g_moves_cnt[depth]; i++)
//    {
//       Move mv = g_moves[depth][i].mv;
//       if (make_move(pos, mv))
//       {
//          delta = perft(pos, depth - 1);
//          sum += delta;
//          unmake_move(pos);
// 
//          char buf[16];
//          OUT1("%s - ", move_to_str(mv, buf));
//          OUT1("%d\n", delta);
// 
//          char s[BUFSIZE];
//          read_input(s, sizeof(s));
//          if (s[0] != '\0')//(input_available())
//          {
//             if (is_command(s, "exit", 2))
//                break;
//          }
//       }
//    }
// 
//    if (i == g_moves_cnt[depth])
//    {
//       clock_t t1 = clock();
// 
//       OUT1("\nNodes: %d\n", sum);
//       OUT1("Time:  %lf\n", (double) (t1 - t0) / CLOCKS_PER_SEC);
//       OUT1("Knps:  %lf\n\n", 0.001 * (double) sum * CLOCKS_PER_SEC / (t1 - t0));
// 
//       int e2 = 9 * pos->count[QUEENW] +
//                5 * pos->count[ROOKW] +
//                3 * (pos->count[BISHOPW] +
//                    pos->count[KNIGHTW]) + pos->count[PAWNW];
//       if (e1 != e2)
//          out("\n\nSOMETHING WRONG WITH COUNTERS!\n\n");
//    }
// 
//    free_pos(pos);
// }
////////////////////////////////////////////////////////////////////////////////

void update_history(Move mv, int depth)
{
	if (mv.Captured())
		return;

	PIECE piece = mv.Piece();
	FLD to = mv.To();
	g_history[piece][to] += depth * depth;

	if (g_history[piece][to] >= MAX_HISTORY)
	{
		for (piece = 0; piece < 14; piece++)
			for (to = 0; to < 64; to++)
				g_history[piece][to] /= 2;
	}
}
////////////////////////////////////////////////////////////////////////////////

EVAL SEE_Exchange(const Position& pos, FLD to, COLOR side, EVAL currScore, EVAL target, U64 occupied)
{
	U64 att = pos.GetAttacks(to, side, occupied) & occupied;
//	Print(att);
	if (att == 0)
		return currScore;

	FLD from = NF;
	PIECE piece;
	EVAL newTarget = VAL_QUEEN + 1;

	while (att)
	{
		FLD f = PopLSB(att);
		piece = pos[f];
		if (VALUE[piece] < newTarget)	
		{
			from = f;
			newTarget = VALUE[piece];
		}
	}

	occupied ^= BB_SINGLE[from];
	EVAL score = - SEE_Exchange(pos, to, side ^ 1, -(currScore + target), newTarget, occupied);
	return max(score, currScore);
}
////////////////////////////////////////////////////////////////////////////////

EVAL SEE(const Position& pos, Move mv)
{
	FLD from = mv.From();
	FLD to = mv.To();
	PIECE piece = mv.Piece();
	PIECE captured = mv.Captured();
	PIECE promotion = mv.Promotion();
	COLOR side = ColorOf(piece);

	EVAL score0 = VALUE[captured];
	if (promotion)
	{
		score0 += VALUE[promotion] - VALUE[PAWNW];
		piece = promotion;
	}

	U64 occupied = pos.BitsAll() ^ BB_SINGLE[from];
	EVAL score = - SEE_Exchange(pos, to, side ^ 1, -score0, VALUE[piece], occupied);

	return score;
}
////////////////////////////////////////////////////////////////////////////////
