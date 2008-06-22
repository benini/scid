#ifndef _MSGQUEUE_H_
#define _MSGQUEUE_H_

// #include <windows.h>
// #include <windef.h>

// typedef long DWORD;
// typedef int BOOL;
// typedef int HANDLE;
// typedef short WORD;
// typedef unsigned short wchar_t;
// typedef unsigned short WCHAR;
// # define WINAPI
// typedef const WCHAR* LPCWSTR;
// typedef WCHAR* LPWSTR;
// typedef void * LPVOID;
// typedef void * PVOID;
// typedef int * LPDWORD;
// typedef unsigned long ULONG;

#define MSGQUEUE_NOPRECOMMIT    0x00000001
#define MSGQUEUE_ALLOW_BROKEN   0x00000002
#define MSGQUEUE_MSGALERT       0x00000001

typedef struct MSGQUEUEOPTIONS_OS {
    DWORD dwSize;                           
    DWORD dwFlags;                         
    DWORD dwMaxMessages;                  
    DWORD cbMaxMessage;               
    BOOL  bReadAccess;                    
} MSGQUEUEOPTIONS, /*FAR*/ *LPMSGQUEUEOPTIONS, *PMSGQUEUEOPTIONS;

typedef struct MSGQUEUEINFO {
    DWORD dwSize;                       
    DWORD dwFlags;                      
    DWORD dwMaxMessages;                   
    DWORD cbMaxMessage;              
    DWORD dwCurrentMessages;               
    DWORD dwMaxQueueMessages;          
    WORD  wNumReaders;                 
    WORD  wNumWriters;              
} MSGQUEUEINFO, *PMSGQUEUEINFO, /*FAR*/ *LPMSGQUEUEINFO;


#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

HANDLE WINAPI CreateMsgQueue(LPCWSTR lpName, LPMSGQUEUEOPTIONS lpOptions);
HANDLE WINAPI OpenMsgQueue(HANDLE hSrcProc, HANDLE hMsgQ, LPMSGQUEUEOPTIONS lpOptions);
BOOL WINAPI ReadMsgQueue(HANDLE hMsgQ, LPVOID lpBuffer, DWORD cbBufferSize, LPDWORD lpNumberOfBytesRead, DWORD dwTimeout, DWORD *pdwFlags);
BOOL WINAPI WriteMsgQueue(HANDLE hMsgQ, LPVOID lpBuffer, DWORD cbDataSize, DWORD dwTimeout, DWORD dwFlags);
BOOL WINAPI GetMsgQueueInfo(HANDLE hMsgQ, LPMSGQUEUEINFO lpInfo);
BOOL WINAPI CloseMsgQueue(HANDLE hMsgQ);

#ifdef __cplusplus
}
#endif

#endif // _MSGQUEUE_H_

