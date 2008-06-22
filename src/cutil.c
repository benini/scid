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

int logMemory = 0;

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

#ifdef WINCE
#include <tcl.h>
Tcl_Interp * currentTclInterp;

// =======================================================
char * my_Tcl_Alloc(int size) {

  char * buf = Tcl_AttemptAlloc(size);
#ifndef POCKET
  if (logMemory)
    printf("Alloc %u %d\n", (unsigned int) buf, size );
#endif
  if (buf == NULL) {
    Tcl_Eval(currentTclInterp, "tk_messageBox -type ok -icon error -parent . -title \"Scid\" -message \"Out of memory\nScid should crash rather quickly\"");
  }
  return buf;
}
// =======================================================
char *  my_Tcl_AttemptAlloc(int size){

  char * buf = Tcl_AttemptAlloc(size);
#ifndef POCKET
  if (logMemory)
    printf("Alloc %u %d\n", (unsigned int) buf, size );
#endif
  return buf;
}
// =======================================================
char * my_Tcl_Realloc(char * ptr, int size) {
  char * buf = Tcl_AttemptRealloc(ptr, size);
#ifndef POCKET
  if (logMemory)
    printf("Realloc %u -> %u %d\n", (unsigned int) ptr, (unsigned int) buf, size );
#endif
  if (buf == NULL) {
    Tcl_Eval(currentTclInterp, "tk_messageBox -type ok -icon error -parent . -title \"Scid\" -message \"Out of memory\nScid could crash rather quickly\"");
  }
  return buf;
}
// =======================================================
void my_Tcl_Free(char * ptr) {
#ifndef POCKET
  if (logMemory)
    printf("Free %u\n", (unsigned int) ptr );
#endif

  Tcl_Free(ptr);
}
// =======================================================
Tcl_Channel  my_Tcl_OpenFileChannel (Tcl_Interp * interp, CONST char * fileName, CONST char * modeString, int permissions){
  Tcl_Channel chan = Tcl_OpenFileChannel (currentTclInterp, fileName, modeString, permissions);
  if (chan == NULL) {
    char buf[200];
    sprintf(buf, "tk_messageBox -type ok -icon error -parent . -title \"Error\" -message \"Tcl_OpenFileChannel error %s\"", Tcl_ErrnoMsg(Tcl_GetErrno()));
    Tcl_Eval(currentTclInterp, buf);
  }
  return chan;
}
// =======================================================
// interpreter is set to NULL, so in case of any error, it is not appended to current result
Tcl_Channel  mySilent_Tcl_OpenFileChannel (Tcl_Interp * interp, CONST char * fileName, CONST char * modeString, int permissions){
  Tcl_Channel chan = Tcl_OpenFileChannel (NULL, fileName, modeString, permissions);
  return chan;
}
// =======================================================
int my_Tcl_Close (Tcl_Interp * interp, Tcl_Channel chan) {
  int res = Tcl_Close (currentTclInterp, chan);
  if (res != TCL_OK) {
      char buf[200];
    sprintf(buf, "tk_messageBox -type ok -icon error -parent . -title \"Error\" -message \"Tcl_Close error %s\"", Tcl_ErrnoMsg(Tcl_GetErrno()));
    Tcl_Eval(currentTclInterp, buf);
  }
  return res;
}
// =======================================================
int my_Tcl_Read (Tcl_Channel chan, char * bufPtr, int toRead) {
  int res = Tcl_Read (chan, bufPtr, toRead);
  if (res == -1) {
    char buf[200];
    sprintf(buf, "tk_messageBox -type ok -icon error -parent . -title \"Error\" -message \"Tcl_Read error %s\"", Tcl_ErrnoMsg(Tcl_GetErrno()));
    Tcl_Eval(currentTclInterp, buf);
  }
  return res;
}
// =======================================================
int my_Tcl_Write (Tcl_Channel chan, CONST char * s, int slen){
  int res;
  res = Tcl_Write ( chan, s, slen);
  if (res == -1) {
    char buf[200];
    sprintf(buf, "tk_messageBox -type ok -icon error -parent . -title \"Error\" -message \"Tcl_Write error %s\"", Tcl_ErrnoMsg(Tcl_GetErrno()));
    Tcl_Eval(currentTclInterp, buf);
  }
  return res;
}
// =======================================================
int my_Tcl_Flush (Tcl_Channel chan){
  int res = Tcl_Flush (chan);
  if (res != TCL_OK) {
    char buf[200];
    sprintf(buf, "tk_messageBox -type ok -icon error -parent . -title \"Error\" -message \"Tcl_Flush error %s\"", Tcl_ErrnoMsg(Tcl_GetErrno()));
    Tcl_Eval(currentTclInterp, buf);
  }
  return res;
}
// =======================================================
Tcl_WideInt my_Tcl_Seek (Tcl_Channel chan, Tcl_WideInt offset, int mode){
  Tcl_WideInt res = Tcl_Seek ( chan, offset, mode);
  if (res == -1) {
    char buf[200];
    sprintf(buf, "tk_messageBox -type ok -icon error -parent . -title \"Error\" -message \"Tcl_Seek error %s\"", Tcl_ErrnoMsg(Tcl_GetErrno()));
    Tcl_Eval(currentTclInterp, buf);
  }
  return res;
}
// =======================================================
Tcl_WideInt my_Tcl_Tell (Tcl_Channel chan){
  Tcl_WideInt res = Tcl_Tell (chan);
  if (res == -1) {
    Tcl_Eval(currentTclInterp, "tk_messageBox -type ok -icon error -parent . -title \"Error\" -message \"Tcl_Tell error\"");
  }
  return res;
}
// =======================================================
int my_Tcl_SetChannelOption ( Tcl_Interp * interp, Tcl_Channel chan, CONST char * optionName, CONST char * newValue){
  int res = Tcl_SetChannelOption ( currentTclInterp, chan, optionName, newValue);
  if (res == TCL_ERROR) {
    char buf[200];
    sprintf(buf, "tk_messageBox -type ok -icon error -parent . -title \"Error\" -message \"Tcl_SetChannelOption %s %s error\"", optionName, newValue);
    Tcl_Eval(currentTclInterp, buf);

  }
  return res;
}
// =======================================================
int my_Tcl_Eof (Tcl_Channel chan) {
  return Tcl_Eof (chan);
}

#endif
