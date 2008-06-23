
// posix.h

#ifndef POSIX_H
#define POSIX_H

extern int sockfd;

// includes

#include "util.h"

// functions

extern "C" int input_available ();
extern "C" void my_usleep (int usleep);
extern "C" int lowPrio(int prio);

extern double now_real        ();
extern double now_cpu         ();

#endif // !defined POSIX_H

// end of posix.h

