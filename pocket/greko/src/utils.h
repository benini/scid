#ifndef UTILS_H
#define UTILS_H

#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>

#include "bitboards.h"
#include <sys/timeb.h>

void  init_input();
// int      input_available();
void  out(const char* s);
char* read_input(char* buf, int sz);
void  rnd32_seed(U32 seed);
U32   rnd32();
U64   rnd64();
void  set_highlight(int on);
char* tail(char* buf);
int      get_time() ;

#define BUFSIZE 4096

#define OUT1(format, var1)        \
{                                 \
	char out_buf[256];              \
	sprintf(out_buf, format, var1); \
	out(out_buf);                   \
}

#define OUT2(format, var1, var2 )        \
{                                        \
	char out_buf[256];                     \
	sprintf(out_buf, format, var1, var2);  \
	out(out_buf);                          \
}
#endif

