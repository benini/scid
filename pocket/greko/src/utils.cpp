#include <assert.h>
#include <malloc.h>
#include <stdio.h>
#include <string.h>

#include "utils.h"
#include "ipc.h"

// extern FILE *g_log;

static U32 g_rnd32 = 42;

////////////////////////////////////////////////////////////////////////////////

void out(const char* s)
{
	//
	// Print engine's output both to stdin and logfile.
	// This is _the_only_ function which is used for output anywhere.
	//

//    printf("%s", s);

  if (s!=NULL)
    send_msg("%s", s);

//    if (g_log)
//    {
//       fprintf(g_log, "%s", s);
//       fflush(g_log);
//    }
}
////////////////////////////////////////////////////////////////////////////////

char *read_input(char *buf, int sz)
{
//    buf = fgets(buf, sz, stdin);
get_msg(buf, sz);
//    if (g_log)
//    {
//       fprintf(g_log, "%s", buf);
//       fflush(g_log);
//    }

	while (buf[strlen(buf) - 1] == '\n' || buf[strlen(buf) - 1] == '\r')
		buf[strlen(buf) - 1] = 0;

	return buf;
}
////////////////////////////////////////////////////////////////////////////////

char* tail(char* buf)
{
	char* p = buf;
	while (*p)
	{
		if (*p == ' ')
		{
			return p + 1;
		}
		p++;
	}

	return p;
}
////////////////////////////////////////////////////////////////////////////////

//
// Pseudorandom generator - D.Knuth, H.W.Lewis
//

void rnd32_seed(U32 seed)
{
	g_rnd32 = seed;
}
////////////////////////////////////////////////////////////////////////////////

U32 rnd32()
{
	g_rnd32 = 1664525L * g_rnd32 + 1013904223L;
	return g_rnd32;
}
////////////////////////////////////////////////////////////////////////////////

U64 rnd64()
{
	U64 r = rnd32();
	r <<= 16;
	r ^= rnd32();
	r <<= 16;
	r ^= rnd32();
	r <<= 16;
	r ^= rnd32();
	r <<= 16;
	r ^= rnd32();

	return r;
}
////////////////////////////////////////////////////////////////////////////////
// returns time in milliseconds
int get_time() {
  struct timeb timebuffer;
  ftime(&timebuffer);
  return (timebuffer.time * 1000) + timebuffer.millitm;
}
