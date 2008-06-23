
// protocol.h

#ifndef PROTOCOL_H
#define PROTOCOL_H

// includes

#ifdef WIN32
#include <windows.h>
#endif

#include "util.h"
#include "ipc.h"

#include <stdio.h>

#include <sys/types.h>

#include <string.h>
#include <stdarg.h>
#include <unistd.h>
#include <fcntl.h>

#include <sys/time.h>

// functions
extern void loop  ();
extern void event ();
extern void book_parameter();

#endif // !defined PROTOCOL_H

// end of protocol.h

