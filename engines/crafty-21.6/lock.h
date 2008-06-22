#if (CPUS > 1)

/*
 *******************************************************************************
 *                                                                             *
 *  this is a Microsoft windows-based operating system.                        *
 *                                                                             *
 *******************************************************************************
 */
#  if defined(_WIN32) || defined(_WIN64)

#    define pthread_attr_t  HANDLE
#    define pthread_t       HANDLE
#    define thread_t        HANDLE

extern pthread_t NumaStartThread(void *func, void *args);

#    if ((defined (_M_IA64) || defined (_M_AMD64)) && !defined(NT_INTEREX))

#      include <windows.h>

#      pragma intrinsic (_InterlockedExchange)

typedef volatile LONG lock_t[1];

#      define LockInit(v)      ((v)[0] = 0)
#      define LockFree(v)      ((v)[0] = 0)
#      define Unlock(v)        ((v)[0] = 0)

__forceinline void Lock(volatile LONG * hPtr)
{
  int iValue;

  for (;;) {
    iValue = _InterlockedExchange((LPLONG) hPtr, 1);
    if (0 == iValue)
      return;
    while (*hPtr);
  }
}

#    else                       /* NT non-Alpha/Intel, without assembler Lock() */

#      define lock_t           volatile int
#      define LockInit(v)      ((v) = 0)
#      define LockFree(v)      ((v) = 0)
#      define Lock(v)          do {                                         \
                             while(InterlockedExchange((LPLONG)&(v),1) != 0);  \
                           } while (0)
#      define Unlock(v)        ((v) = 0)

#    endif                      /* architecture check */

#  else
/*
 *******************************************************************************
 *                                                                             *
 *  this is a Unix-based operating system.  define the spinlock code as needed *
 *  for SMP synchronization.                                                   *
 *                                                                             *
 *******************************************************************************
 */

#    if defined(ALPHA)

#      include <machine/builtins.h>

#      define lock_t           volatile long
#      define LockInit(v)      ((v) = 0)
#      define LockFree(v)      ((v) = 0)
#      define Lock(v)          __LOCK_LONG(&(v))
#      define Unlock(v)        __UNLOCK_LONG(&(v))

#    elif defined(POWERPC)
                        /* OS X */

#      include <libkern/OSAtomic.h>

#      define lock_t				OSSpinLock
#      define LockInit(v)		((v) = 0)
#      define LockFree(v)		((v) = 0)
#      define Lock(v)			OSSpinLockLock(&(v))
#      define Unlock(v)			OSSpinLockUnlock(&(v))

#    else                       /* X86 */

static void __inline__ LockX86(volatile int *lock)
{
  int dummy;
  asm __volatile__("1:          movl    $1, %0" "\n\t"
      "            xchgl   (%1), %0" "\n\t" "            testl   %0, %0" "\n\t"
      "            jz      3f" "\n\t" "2:          pause" "\n\t"
      "            movl    (%1), %0" "\n\t" "            testl   %0, %0" "\n\t"
      "            jnz     2b" "\n\t" "            jmp     1b" "\n\t" "3:"
      "\n\t":"=&q"(dummy)
      :"q"(lock)
      :"cc", "memory");
}

static void __inline__ UnlockX86(volatile int *lock)
{
  int dummy;
  asm __volatile__("movl    $0, (%1)":"=&q"(dummy)
      :"q"(lock));
}

#      define LockInit(p)           (p=0)
#      define LockFree(p)           (p=0)
#      define Unlock(p)             (UnlockX86(&p))
#      define Lock(p)               (LockX86(&p))
#      define lock_t                volatile int

#    endif

#  endif                        /* windows or unix */

#else
#  define LockInit(p)
#  define LockFree(p)
#  define Lock(p)
#  define Unlock(p)
#endif                          /*  SMP code */
