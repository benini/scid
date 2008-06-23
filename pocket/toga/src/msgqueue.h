
#ifndef __MSGQUEUE_H__
#define __MSGQUEUE_H__

#define MSGQUEUE_NOPRECOMMIT            0x00000001
#define MSGQUEUE_ALLOW_BROKEN           0x00000002

#define MSGQUEUE_MSGALERT               0x00000001

typedef struct MSGQUEUEOPTIONS_OS {
    DWORD dwSize;                           // size of the structure
    DWORD dwFlags;                          // behavior of message queue
    DWORD dwMaxMessages;                    // max # of msgs in queue
    DWORD cbMaxMessage;                     // max size of msg
    BOOL  bReadAccess;                      // read access requested
} MSGQUEUEOPTIONS, FAR *LPMSGQUEUEOPTIONS, *PMSGQUEUEOPTIONS;

typedef struct MSGQUEUEINFO {
    DWORD dwSize;                           // size of structure
    DWORD dwFlags;                          // behavior of message queue
    DWORD dwMaxMessages;                    // max # of msgs in queue
    DWORD cbMaxMessage;                     // max size of msg
    DWORD dwCurrentMessages;                // # of message in queue currently
    DWORD dwMaxQueueMessages;               // high water mark of queue
    WORD  wNumReaders;                      // # of readers
    WORD  wNumWriters;                      // # of writes
} MSGQUEUEINFO, *PMSGQUEUEINFO, FAR *LPMSGQUEUEINFO;


#ifdef __cplusplus
extern "C" {
#endif /* __cplusplus */

//
// prototypes
//
HANDLE WINAPI CreateMsgQueue(LPCWSTR lpName, LPMSGQUEUEOPTIONS lpOptions);
HANDLE WINAPI OpenMsgQueue(HANDLE hSrcProc, HANDLE hMsgQ, LPMSGQUEUEOPTIONS lpOptions);
BOOL WINAPI ReadMsgQueue(HANDLE hMsgQ, LPVOID lpBuffer, DWORD cbBufferSize,
                LPDWORD lpNumberOfBytesRead, DWORD dwTimeout, DWORD *pdwFlags);
BOOL WINAPI WriteMsgQueue(HANDLE hMsgQ, LPVOID lpBuffer, DWORD cbDataSize,
                DWORD dwTimeout, DWORD dwFlags);
BOOL WINAPI GetMsgQueueInfo(HANDLE hMsgQ, LPMSGQUEUEINFO lpInfo);

BOOL WINAPI CloseMsgQueue(HANDLE hMsgQ);

#ifdef __cplusplus
}
#endif

#endif // __MSGQUEUE_H__

