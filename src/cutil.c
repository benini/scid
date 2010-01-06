#include <sys/types.h>
#include <sys/stat.h>
#include <sys/unistd.h>

#ifdef POCKET
#include <windows.h>
#include "msgqueue.h"
#endif

#include <stdio.h>
#include <stdlib.h>
#include "tclmy.h"

#ifndef _CURRENT_TCL_INTERP_
extern Tcl_Interp * currentTclInterp;
#define _CURRENT_TCL_INTERP_
#endif

//HANDLE GetProcessHeap(VOID);
#ifdef POCKET

// ==============================================================
void AnsiToUnicode(LPCSTR pszA, LPWSTR* ppszW) {
    ULONG cCharacters;
    cCharacters =  strlen(pszA)+1;
    *ppszW = (LPWSTR) my_Tcl_Alloc(cCharacters*2);
    MultiByteToWideChar(CP_ACP, 0, pszA, cCharacters, *ppszW, cCharacters);
}
// ==============================================================
int my_sc_msg_init(char * eng , char bread) {
  MSGQUEUEOPTIONS opt;
  char s[50];
  HANDLE h;

  opt.dwSize = sizeof(MSGQUEUEOPTIONS);
  opt.dwFlags = MSGQUEUE_NOPRECOMMIT | MSGQUEUE_ALLOW_BROKEN;
  opt.dwMaxMessages = 0;
  opt.cbMaxMessage = 1024;
  opt.bReadAccess = bread;
  if (bread == 1) {
    sprintf(s, "%s2scid", eng);
  } else {
    sprintf(s, "scid2%s", eng);
  }
  LPWSTR sunicode;
  AnsiToUnicode(s, &sunicode);
  h = CreateMsgQueue( (LPCWSTR) sunicode, &opt );
  my_Tcl_Free(sunicode);
  if ( ! h )
    return 0;

  return (int) h;
}
// ==============================================================
int getPocketAvailPhys() {
        MEMORYSTATUS stat;
        GlobalMemoryStatus (&stat);
  return (int)stat.dwAvailPhys;
}

int getPocketAvailVirtual() {
        MEMORYSTATUS stat;
        GlobalMemoryStatus (&stat);
  return (int)stat.dwAvailVirtual;
}

void getPocketMem(char * buf) {
        MEMORYSTATUS stat;
        GlobalMemoryStatus (&stat);
  sprintf(buf, "load %d %%\navail phys %d kB\ntotal %d kB\navail virt %d kB\n", (int)stat.dwMemoryLoad, (int)(stat.dwAvailPhys/1024), (int)(stat.dwTotalPhys/1024), (int)(stat.dwAvailVirtual/1024));
}


int setPriority(int prio) {
  return (int) CeSetThreadPriority(GetCurrentThread(), prio);
}
// int getPriority() {
//   return CeGetThreadPriority( GetCurrentThread() );
// }
#endif


