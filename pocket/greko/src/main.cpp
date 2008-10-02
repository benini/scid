#ifdef _MSC_VER
#pragma warning(disable: 4996)
#endif

#include <stdio.h>
#include <string.h>
#include <time.h>

#include "commands.h"
#include "moves.h"
#include "search.h"
#include "utils.h"
#include "version.h"
#include "ipc.h"

//FILE *g_log = NULL;
Position g_pos;

int main(int argc, char *argv[])
{
	int hash_sz = 0;
//	for (int a = 1; a < argc; a++)
//	{
//		if (!strcmp(argv[a], "-log") && !g_log)
//			g_log = fopen("greko.log", "at");

//		if (!strcmp(argv[a-1], "-hash"))
//		{
//			hash_sz = atoi(argv[a]);
//		}
   if (init_socket()) {
      exit(1);
	}

//	set_highlight(1);
	out("\n");
	out(PROGRAM_NAME);
	out(" (");
	out(PROGRAM_DATE);
	out(")\n\n");
//    set_highlight(0);

//    init_input();
	init_bitboards();
	init_hash_coeffs();

	init_hash();
  
	if (hash_sz)
	{
		out("resize hash:\n");
		resize_hash(hash_sz);
	}

	out("\n");

	g_pos.SetInitial();

	run_command_loop();

//    if (g_log)
//       fclose(g_log);

	return 0;
}
////////////////////////////////////////////////////////////////////////////////
