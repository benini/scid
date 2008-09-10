#ifdef _MSC_VER
#pragma warning(disable: 4996)
#endif

#include <stdio.h>
#include <string.h>

#include "commands.h"
#include "eval.h"
#include "moves.h"
#include "position.h"
#include "moves.h"
#include "search.h"
#include "utils.h"
#include "version.h"
#include "ipc.h"

// extern FILE* g_log;
extern Limits g_limits;

int g_force = 0;
int g_xboard = 0;
int g_uci = 0;

int CalcTimePerMove(int rest, int inc)
{
	// all values in milliseconds

	int t = rest / 40;
	if (rest > 5 * inc)
		t += inc;

// 	if (g_log)
// 	{
// 		fprintf(g_log, "CalcTimePErMove: rest = %d, inc = %d ==> time = %d\n", rest, inc, t);
// 		fflush(g_log);
// 	}

	return t;
}

int is_command(const char *s, const char *pattern, size_t min_length)
{
	//
	//   Check if string is command (may be abbreviated)
	//

	char buf[BUFSIZE];
	strncpy(buf, s, BUFSIZE);
	char* p = buf;
	while (*p)
	{
		if (*p == ' ')
		{
			*p = 0;
			break;
		}
		p++;
	}

	if (strstr(pattern, buf) == pattern)
	{
		if (strlen(buf) >= min_length)
			return 1;
	}
	return 0;
}
////////////////////////////////////////////////////////////////////////////////

void load_pos(Position* pos, const char* s)
{
	//
	//   Load position with given number from file
	//

	char buf[BUFSIZE];
	strncpy(buf, s, BUFSIZE);

	char* ptoken = strtok(buf, " ");
	ptoken = strtok(NULL, " ");

	FILE* psrc = fopen(ptoken, "rt");
	if (psrc == NULL)
	{
		OUT1("Can't open file: %s\n", ptoken);
		return;
	}

	int line_req = 1;
	int line_read = 0;

	ptoken = strtok(NULL, " ");
	if (ptoken)
		line_req = atoi(ptoken);

	while (fgets(buf, BUFSIZE, psrc))
	{
		line_read++;
		if (line_read == line_req)
			break;
	}

	if (line_read == line_req)
	{
		if (buf[strlen(buf) - 1] == '\n' || buf[strlen(buf) - 1] == '\r')
			buf[strlen(buf) - 1] = 0;

		OUT1("%s\n", buf);
		g_pos.SetFEN(buf);
	}
	else
	{
		out("Incorrect line number\n");
	}

	fclose(psrc);
}
////////////////////////////////////////////////////////////////////////////////

void prompt()
{
	//
	//   Print prompt with side to move and move number in console mode
	//

	if (g_xboard || g_uci)
		return;

	if (g_pos.Side() == WHITE)
		out("White(");
	else
		out("Black(");

	char buf[256];
	sprintf(buf, "%d): ", g_pos.Ply() / 2 + 1);
	out(buf);
}
////////////////////////////////////////////////////////////////////////////////

void run_command_loop()
{
	//
	//   Read user input and process commands
	//

	char s[BUFSIZE];

	while (1)
	{
#ifdef WIN32
    uiAlive();
#endif 

		prompt();
		read_input(s, sizeof(s));

      if (s[0] == '\0') {
         my_usleep(10000);
         continue;
      }

		Move mv0 = str_to_move(&g_pos, s);
		if (mv0)
		{
			MoveList mvlist;
			mvlist.GenAllMoves(g_pos);

			int move_found = 0;
			for (int i = 0; i < mvlist.Size(); ++i)
			{
				Move mv = mvlist[i];
				if (mv == mv0)
				{
					move_found = 1;
					break;
				}
			}

			if (move_found && g_pos.MakeMove(mv0))
			{
				if (!g_force)
					start_thinking_on_move(g_pos);

				continue;
			}
			else
				out("Incorrect move\n");

			continue;
		}

		else if (is_command(s, "?", 1))
		{

		}
		else if (is_command(s, "accepted", 8))
		{

		}
		else if (is_command(s, "analyze", 2))
			start_analyze(g_pos);
		else if (is_command(s, "attacks", 1))
			g_pos.PrintAttacks();
		else if (is_command(s, "board", 1))
			g_pos.Print();
		else if (is_command(s, "computer", 4))
		{

		}
		else if (is_command(s, "easy", 4))
		{

		}
/*      else if (is_command(s, "epdtest", 3))
		{
			// load fen from file and setup position

			char* token = strtok(s, " ");
			token = strtok(NULL, " ");
			if (token == NULL)
			{
				out("usage: epdtest <file.epd> <seconds>\n");
			}
			else
			{
				FILE *psrc = fopen(token, "rt");
				if (!psrc)
				{
					OUT1("Unable to open file: %s\n", token);
				}
				else
				{
					double tm = 1.0;
					token = strtok(NULL, " ");
					if (token)
						tm = atof(token);

					int reps = 3;
					token = strtok(NULL, " ");
					if (token)
						reps = atoi(token);

					epdtest(psrc, tm, reps);
					fclose(psrc);
				}
			}
      }*/
		else if (is_command(s, "eval", 1))
		{
			EVAL e = evaluate(g_pos, - INFINITY_SCORE, INFINITY_SCORE);
			OUT1("eval = %d\n", e);
		}
		else if (is_command(s, "fen", 3))
		{
			char buf[BUFSIZE];
			out(get_fen(&g_pos, buf));
			out("\n");
		}
		else if (is_command(s, "force", 5))
			g_force = 1;

		else if (is_command(s, "go", 2))
		{
			char *token = strtok(s, " ");
			while (token)
			{
				if (!strcmp(token, "infinite"))
				{
					g_limits.stSoft = 86400000;
					g_limits.stHard = 86400000;
					g_limits.sd = MAX_PLY;
					break;
				}
				else if(!strcmp(token, "wtime") && g_pos.Side() == WHITE)
				{
					token = strtok(NULL, " ");
					if (token)
					{
						// in UCI time comes in milliseconds
						int t = CalcTimePerMove(atoi(token), g_limits.inc);
						g_limits.stSoft = t;
						g_limits.stHard = 3 * t;
						g_limits.sd = MAX_PLY;
					}
				}
				else if(!strcmp(token, "btime") && g_pos.Side() == BLACK)
				{
					token = strtok(NULL, " ");
					if (token)
					{
						// in UCI time comes in milliseconds
						int t = CalcTimePerMove(atoi(token), g_limits.inc);
						g_limits.stSoft = t;
						g_limits.stHard = 3 * t;
						g_limits.sd = MAX_PLY;
					}
				}
				else if(!strcmp(token, "winc") && g_pos.Side() == WHITE)
				{
					// in UCI time comes in milliseconds
					token = strtok(NULL, " ");
					if (token)
						g_limits.inc = atoi(token);
				}
				else if(!strcmp(token, "binc") && g_pos.Side() == BLACK)
				{
					// in UCI time comes in milliseconds
					token = strtok(NULL, " ");
					if (token)
						g_limits.inc = atoi(token);
				}

				token = strtok(NULL, " ");
			}

			g_force = 0;
			start_thinking_on_move(g_pos);
		}

		else if (!strcmp(s, "go infinite"))
		{
			g_force = 0;
			start_thinking_on_move(g_pos);
		}
		else if (!strcmp(s, "go"))
		{
			g_force = 0;
			start_thinking_on_move(g_pos);
		}
		else if (is_command(s, "hard", 4))
		{

		}
		else if (is_command(s, "isready", 7))
		{
			out("readyok\n");
		}
		else if (is_command(s, "list", 1))
		{
			MoveList mvlist;
			mvlist.GenAllMoves(g_pos);

			int legal = 0;
			for (int i = 0; i < mvlist.Size(); ++i)
			{
				char buf[16];
				Move mv = mvlist[i];
				if (g_pos.MakeMove(mv))
				{
					legal++;
					g_pos.UnmakeMove();
					OUT1("%s ", move_to_str(mv, buf));
				}
			}
			OUT1(" -- total %d moves\n", legal);
		}
		else if (is_command(s, "level", 5))
		{
			char* token = strtok(s, " "); // "level"
			token = strtok(NULL, " "); // mps
			token = strtok(NULL, " "); // base
			token = strtok(NULL, " "); // inc
			if (token)
			{
				// in WB increment comes in seconds
				g_limits.inc = 1000 * atoi(token);
			}
		}
		else if (is_command(s, "load", 2))
			load_pos(&g_pos, s);
		else if (is_command(s, "mirror", 2))
			g_pos.Mirror();
		else if (is_command(s, "mt", 2))
		{
			char* token = strtok(s, " ");
			token = strtok(NULL, " ");
			if (token == NULL)
				continue;

			FILE* psrc = fopen(token, "rt");
			if (psrc == NULL)
			{
				OUT1("Can't open file: %s\n", token);
				continue;
			}

			char buf[BUFSIZE];
			while (fgets(buf, BUFSIZE, psrc))
			{
				if (buf[strlen(buf) - 1] == '\n' || buf[strlen(buf) - 1] == '\r')
					buf[strlen(buf) - 1] = 0;

				OUT1("%s\n", buf);
				g_pos.SetFEN(buf);

				EVAL e1 = evaluate(g_pos, - INFINITY_SCORE, INFINITY_SCORE);
				g_pos.Mirror();
				EVAL e2 = evaluate(g_pos, - INFINITY_SCORE, INFINITY_SCORE);

				if (e1 != e2)
				{
					out("Incorrect evaluation:\n");
					OUT1("e1 = %d\n", e1);
					OUT1("e2 = %d\n", e2);
					break;
				}
			}

			fclose(psrc);
		}
		else if (is_command(s, "name", 4))
		{

		}
		else if (is_command(s, "new", 3))
		{
			g_force = 0;
			g_pos.SetInitial();
		}
// 		else if (is_command(s, "perft", 2))
// 		{
// 			int depth = 1;
// 			char *token = strtok(s, " ");
// 			token = strtok(NULL, " ");
// 			if (token)
// 			{
// 				depth = atoi(token);
// 				if (depth <= 0)
// 					depth = 1;
// 			}
// 			start_perft(g_pos, depth);
// 		}
		else if (is_command(s, "ping", 4))
		{
			s[1] = 'o';
			out(s);
			out("\n");
		}
		else if (is_command(s, "position", 8))
		{
			char uci_buf[8192];
			strcpy(uci_buf, s);

			char *token = strtok(s, " ");
			token = strtok(NULL, " ");
			if (!strcmp(token, "startpos"))
			{
				g_pos.SetInitial();

				token = strtok(uci_buf, " "); // "position"
				token = strtok(NULL, " ");    // "startpos"
				token = strtok(NULL, " ");    // "moves"
				token = strtok(NULL, " ");    // first move

				while (token)
				{
					Move mv = str_to_move(&g_pos, token);
					g_pos.MakeMove(mv);
					token = strtok(NULL, " ");
				}
			}
			else if (!strcmp(token, "fen"))
			{
				g_pos.SetFEN(s + 13);

				char *p = strstr(uci_buf, "moves");
				if (p)
				{
					token = strtok(p, " ");    // "moves"
					token = strtok(NULL, " "); // first move

					while (token)
					{
						Move mv = str_to_move(&g_pos, token);
						g_pos.MakeMove(mv);
						token = strtok(NULL, " ");
					}
				}
			}
		}
		else if (is_command(s, "post", 4))
		{

		}
		else if (is_command(s, "protover", 8))
		{

		}
		else if (is_command(s, "quit", 1))
			break;
		else if (is_command(s, "random", 6))
		{

		}
		else if (is_command(s, "remove", 3))
		{
			g_pos.UnmakeMove();
			g_pos.UnmakeMove();
		}
		else if (is_command(s, "rep", 3))
		{
			int total = g_pos.GetRepetitions();
			OUT1("total = %d\n", total);
		}
		else if (is_command(s, "result", 6))
		{
			g_force = 0;
			g_pos.SetInitial();
		}
		else if (is_command(s, "setboard", 8))
		{      
			g_pos.SetFEN(s + 9);
		}

      else if (is_command(s, "setpriority", 11 ))
      {
         char *token = strtok(s, " ");
         token = strtok(NULL, " ");
         if (token)
         {
            int prio = 252;
            prio = atoi (token);
            lowPrio(prio);
		}
      }

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
         else if (token && ( !strcmp(token, "Hash") || !strcmp(token, "sethash") ) )
			{
				token = strtok(NULL, " ");
				token = strtok(NULL, " ");
				resize_hash(atoi(token));
			}
		}
		else if (is_command(s, "st", 2))
		{
			char *token = strtok(s, " ");
			token = strtok(NULL, " ");
			if (token)
			{
				g_limits.stSoft = (long) (1000 * atof(token));
				g_limits.stHard = (long) (1000 * atof(token));
				g_limits.sd = MAX_PLY;
			}
		}
		else if (is_command(s, "stop", 4))
		{
		}
		else if (is_command(s, "test", 1))
		{
		}
		else if (is_command(s, "time", 2))
		{
			char *token = strtok(s, " ");
			token = strtok(NULL, " ");
			if (token)
			{
				// in WB time comes in centiseconds
				int t = CalcTimePerMove(10 * atoi(token), g_limits.inc);
				g_limits.stSoft = t;
				g_limits.stHard = 3 * t;
				g_limits.sd = MAX_PLY;
			}
		}
		else if (is_command(s, "uci", 3))
		{
			g_uci = 1;
			g_xboard = 0;
			out("id name ");
			out(PROGRAM_NAME);
			out("\n");
			out("id author Vladimir Medvedev\n");
			out("option name Hash type spin default 1 min 1 max 1024\n");
			OUT1("option name MultiPV type spin default 1 min 1 max %d\n", MAX_BRANCH);
			out("uciok\n");
		}
		else if (is_command(s, "undo", 1))
			g_pos.UnmakeMove();

		else if (is_command(s, "xboard", 6))
		{
			g_uci = 0;
			g_xboard = 1;
			out("\nfeature myname=\"");
			out(PROGRAM_NAME);
			out("\" setboard=1 analyze=1 colors=0 san=0 ping=1 name=1 done=1\n\n");
		}
		else
			OUT1("Unknown command: %s\n", s);
	}
}
////////////////////////////////////////////////////////////////////////////////
