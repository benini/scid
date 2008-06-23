
// posix.cpp

// includes

#include <cerrno>
#include <cstdio> // REMOVE ME?
#include <cstdlib>
#include <cstring>
#include <ctime>

//#define _WIN32

#if defined(_WIN32) || defined(_WIN64)
#  include <windows.h>
#else // assume POSIX
#  include <sys/resource.h>
//#  include <sys/select.h>
#  include <sys/time.h>
#  include <sys/types.h>
#  include <unistd.h>
#endif

#include "posix.h"
#include "util.h"

// constants

static const bool UseDebug = false;

// prototypes

#if !defined(_WIN32) && !defined(_WIN64)
static double duration (const struct timeval * tv);
#endif

// functions

// now_real()

double now_real() {

#if defined(_WIN32) || defined(_WIN64)

   return double(GetTickCount()) / 1000.0;

#else // assume POSIX

   struct timeval tv[1];
   struct timezone tz[1];

   tz->tz_minuteswest = 0;
   tz->tz_dsttime = 0; // DST_NONE not declared in linux

   if (gettimeofday(tv,tz) == -1) { // tz needed at all?
      my_fatal("now_real(): gettimeofday(): %s\n",strerror(errno));
   }

   return duration(tv);

#endif
}

// now_cpu()

double now_cpu() {

//#if defined(_WIN32) || defined(_WIN64)

   return double(clock()) / double(CLOCKS_PER_SEC); // OK if CLOCKS_PER_SEC is small enough
/*
#else // assume POSIX

   struct rusage ru[1];

   if (getrusage(RUSAGE_SELF,ru) == -1) {
      my_fatal("now_cpu(): getrusage(): %s\n",strerror(errno));
   }

   return duration(&ru->ru_utime);

#endif
*/
}

// duration()

#if !defined(_WIN32) && !defined(_WIN64)

static double duration(const struct timeval * tv) {

   ASSERT(tv!=NULL);

   return double(tv->tv_sec) + double(tv->tv_usec) * 1E-6;
}

#endif

// end of posix.cpp

