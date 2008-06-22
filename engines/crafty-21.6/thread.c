#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "chess.h"
#include "data.h"
#include "epdglue.h"

/* modified 08/07/05 */
/*
 *******************************************************************************
 *                                                                             *
 *   Thread() is the driver for the threaded parallel search in Crafty.  the   *
 *   basic idea is that whenever we notice that one (or more) threads are      *
 *   in their idle loop, we drop into thread, from Search(), and begin a new   *
 *   parallel search from this node.  this is simply a problem of copying the  *
 *   search state space for each thread working at this node, then sending     *
 *   everyone off to SearchSMP() to search this node in parallel.              *
 *                                                                             *
 *******************************************************************************
 */
int Thread(TREE * RESTRICT tree)
{
  TREE *block;
  int proc;
  int nblocks = 0;

/*
 ************************************************************
 *                                                          *
 *   first, we make sure that there are idle threads. it    *
 *   is possible that we get here after they have all been  *
 *   claimed by another thread.  in that case we return.    *
 *                                                          *
 ************************************************************
 */
  Lock(shared->lock_smp);
  for (proc = 0; proc < shared->max_threads && shared->thread[proc]; proc++);
  if (proc == shared->max_threads || tree->stop) {
    Unlock(shared->lock_smp);
    return (0);
  }
#if defined(DEBUGSMP)
  Lock(shared->lock_io);
  Print(128, "thread %d  block %d  ply %d  parallel split\n", tree->thread_id,
      FindBlockID(tree), tree->ply);
  Print(128, "thread %d  threads(s) idle:", tree->thread_id);
  for (proc = 0; proc < shared->max_threads; proc++)
    if (!shared->thread[proc])
      Print(128, " %d", proc);
  Print(128, "\n");
  Unlock(shared->lock_io);
#endif
/*
 ************************************************************
 *                                                          *
 *   now we start copying the current "state" from this     *
 *   thread into new thread blocks so that the threads can  *
 *   search this position without interfering with each     *
 *   other.  as we copy, we link those blocks as siblings   *
 *   of the parent node, and point each sibling back to the *
 *   parent so we can unwind this confusion as the threads  *
 *   complete their work.                                   *
 *                                                          *
 ************************************************************
 */
  shared->splitting = 1;
  shared->parallel_splits++;
  shared->thread[tree->thread_id] = 0;
  tree->nprocs = 0;
  for (proc = 0;
      proc < shared->max_threads && nblocks < shared->max_thread_group;
      proc++) {
    tree->siblings[proc] = 0;
    if (shared->thread[proc] == 0) {
      block = CopyToSMP(tree, proc);
      if (!block)
        continue;
      nblocks++;
      tree->siblings[proc] = block;
      block->thread_id = proc;
      block->parent = tree;
      tree->nprocs++;
#if defined(DEBUGSMP)
      Print(128, "thread %d  block %d  allocated at ply=%d\n", proc,
          FindBlockID(block), tree->ply);
#endif
    } else
      tree->siblings[proc] = 0;
  }
  tree->search_value = tree->value;
  if (!nblocks) {
    Unlock(shared->lock_smp);
    shared->thread[tree->thread_id] = tree;
    shared->splitting = 0;
    return (0);
  }
/*
 ************************************************************
 *                                                          *
 *   everything is set.  now we can stuff the address of    *
 *   the thread blocks into thread[i] so that those idle    *
 *   threads can begin the parallel search.                 *
 *                                                          *
 ************************************************************
 */
  for (proc = 0; proc < shared->max_threads; proc++)
    if (tree->siblings[proc])
      shared->thread[proc] = tree->siblings[proc];
  shared->splitting = 0;
/*
 ************************************************************
 *                                                          *
 *   after the threads are kicked off to start the parallel *
 *   search using the idle threads, this thread has to be   *
 *   inserted as well.  however, since it is possible that  *
 *   this thread may finish before any or all of the other  *
 *   parallel threads, this thread is sent to ThreadWait()  *
 *   which will immediately send it to SearchSMP() just     *
 *   like the other threads.  going to ThreadWait() allows  *
 *   this thread to join others if it runs out of work to   *
 *   do.  we do pass ThreadWait() the address of the parent *
 *   thread block, so that if this thread becomes idle, and *
 *   this thread block shows no threads are still busy,     *
 *   then this thread can return to here and then back up   *
 *   into the previous ply as it should.  note that no      *
 *   other thread can back up to the previous ply since     *
 *   their recursive call stacks are not set for that.      *
 *                                                          *
 ************************************************************
 */
  Unlock(shared->lock_smp);
  ThreadWait(tree->thread_id, tree);
#if defined(DEBUGSMP)
  Print(128, "thread %d  block %d  ply %d  parallel join\n", tree->thread_id,
      FindBlockID(tree), tree->ply);
#endif
  return (1);
}

/*
 *******************************************************************************
 *                                                                             *
 *   WaitForAllThreadsInitialized() waits till all max_threads are initialized.*
 *   Otherwise we can try to use not yet initialized local[] data.             *
 *                                                                             *
 *******************************************************************************
 */

void WaitForAllThreadsInitialized(void)
{
  while (shared->initialized_threads < shared->max_threads);    /* Do nothing */
}

/* modified 08/07/05 */
/*
 *******************************************************************************
 *                                                                             *
 *   ThreadInit() is called after a process is created.  its main task is to   *
 *   initialize the process local memory so that it will fault in and be       *
 *   allocated on the local node rather than the node where the original       *
 *   (first) process was running.  all threads will hang here via a custom     *
 *   WaitForALlThreadsInitialized() procedure so that all the local thread     *
 *   blocks are usable before the search actually begins.                      *
 *                                                                             *
 *******************************************************************************
 */

void *STDCALL ThreadInit(void *tid)
{
  int i;
  long j;

#if defined(_WIN32) || defined(_WIN64)
  ThreadMalloc((int) tid);
#endif
  j = (long) tid;
  for (i = 0; i < MAX_BLOCKS_PER_CPU; i++) {
    memset((void *) shared->local[j * MAX_BLOCKS_PER_CPU + i + 1], 0,
        sizeof(TREE));
    shared->local[j * MAX_BLOCKS_PER_CPU + i + 1]->used = 0;
    shared->local[j * MAX_BLOCKS_PER_CPU + i + 1]->parent = (TREE *) - 1;
    LockInit(shared->local[j * MAX_BLOCKS_PER_CPU + i + 1]->lock);
  }
  Lock(shared->lock_smp);
  shared->initialized_threads++;
  Unlock(shared->lock_smp);
  WaitForAllThreadsInitialized();
  ThreadWait((long) tid, (TREE *) 0);
  return (0);
}

#if defined (_WIN32) || defined (_WIN64)
/* modified 10/21/03 */
/*
 *******************************************************************************
 *                                                                             *
 *   ThreadMalloc() is called from the ThreadInit() function.  it malloc's the *
 *   split blocks in the local memory for the processor associated with the    *
 *   specific thread that is calling this code.                                *
 *                                                                             *
 *******************************************************************************
 */
extern void *WinMalloc(size_t, int);

void ThreadMalloc(int tid)
{
  int i, n = MAX_BLOCKS_PER_CPU;

  for (i = MAX_BLOCKS_PER_CPU * ((int) tid) + 1; n; i++, n--) {
    shared->local[i] =
        (TREE *) ((~(size_t) 127) & (127 + (size_t) WinMalloc(sizeof(TREE) +
                127, tid)));
    shared->local[i]->used = 0;
    shared->local[i]->parent = (TREE *) - 1;
    LockInit(shared->local[i]->lock);
  }
}
#endif

/* modified 08/07/05 */
/*
 *******************************************************************************
 *                                                                             *
 *   ThreadStop() is called from SearchSMP() when it detects a beta cutoff (or *
 *   fail high) at a node that is being searched in parallel.  we need to stop *
 *   all threads here, and since this threading algorithm is "recursive" it may*
 *   be necessary to stop other threads that are helping search this branch    *
 *   further down into the tree.  this function simply sets tree->stop to 1,   *
 *   which will stop that particular thread instantly and return it to the idle*
 *   loop in ThreadWait().                                                     *
 *                                                                             *
 *******************************************************************************
 */
void ThreadStop(TREE * RESTRICT tree)
{
  int proc;

  Lock(tree->lock);
  tree->stop = 1;
  for (proc = 0; proc < shared->max_threads; proc++)
    if (tree->siblings[proc])
      ThreadStop(tree->siblings[proc]);
  Unlock(tree->lock);
#if defined(DEBUGSMP)
  Lock(shared->lock_io);
  Print(128, "thread %d (block %d) being stopped by beta cutoff.\n",
      tree->thread_id, FindBlockID(tree));
  Unlock(shared->lock_io);
#endif
}

/* modified 08/07/05 */
/*
 *******************************************************************************
 *                                                                             *
 *   ThreadWait() is the idle loop for the N threads that are created at the   *
 *   beginning when Crafty searches.  threads are "parked" here waiting on a   *
 *   pointer to something they should search (a parameter block built in the   *
 *   function Thread() in this case.  when this pointer becomes non-zero, each *
 *   thread "parked" here will immediately call SearchSMP() and begin the      *
 *   parallel search as directed.                                              *
 *                                                                             *
 *******************************************************************************
 */
int ThreadWait(int tid, TREE * RESTRICT waiting)
{
  int value;

/*
 ************************************************************
 *                                                          *
 *   the N initial threads enter here and are kept penned   *
 *   here forever.  however, once a thread leaves here it   *
 *   may well re-enter ThreadWait() from the top while it   *
 *   waits for a parallel search to complete.  while it     *
 *   waits here it can also join in to help other busy      *
 *   threads search their subtrees as well.                 *
 *                                                          *
 ************************************************************
 */
  while (1) {
    Lock(shared->lock_smp);
    shared->smp_idle++;
    Unlock(shared->lock_smp);
#if defined(DEBUGSMP)
    Lock(shared->lock_io);
    Print(128, "thread %d now idle (%d procs, %d idle).\n", tid,
        shared->max_threads, shared->smp_idle);
    if (FindBlockID(waiting) >= 0)
      Print(128,
          "thread %d  waiting on block %d, still %d threads busy there\n", tid,
          FindBlockID(waiting), waiting->nprocs);
    Unlock(shared->lock_io);
#endif
/*
 ************************************************************
 *                                                          *
 *   we can exit if our thread[i] is non-zero, or if we are *
 *   waiting on others to finish a block that *we* have to  *
 *   return through.  when the busy count on such a block   *
 *   hits zero, we return immediately which unwinds the     *
 *   search as it should be.                                *
 *                                                          *
 ************************************************************
 */
    while (!shared->thread[tid] && !shared->quit && (!waiting ||
            waiting->nprocs));
    if (shared->quit)
      return (0);
    Lock(shared->lock_smp);
    if (!shared->thread[tid])
      shared->thread[tid] = waiting;
/*
 ************************************************************
 *                                                          *
 *   we either have work to do, or threads we were waiting  *
 *   on have finished their work.                           *
 *                                                          *
 ************************************************************
 */
#if defined(DEBUGSMP)
    Lock(shared->lock_io);
    Print(128, "thread %d now has work at block %d.\n", tid,
        FindBlockID(shared->thread[tid]));
    Unlock(shared->lock_io);
#endif
    shared->smp_idle--;
/*
 ************************************************************
 *                                                          *
 *   if we are waiting on a block and the busy count is now *
 *   zero, we simply return to finish up the bookkeeping at *
 *   that point.                                            *
 *                                                          *
 ************************************************************
 */
    Unlock(shared->lock_smp);
    if (shared->thread[tid] == waiting)
      return (0);
    if (shared->quit || shared->thread[tid] == (TREE *) - 1) {
      Lock(shared->lock_io);
      Print(128, "thread %d exiting\n", tid);
      Unlock(shared->lock_io);
      return (0);
    }
/*
 ************************************************************
 *                                                          *
 *   else our thread[i] pointer is non-zero, meaning we     *
 *   have been assigned something to search.  off we go,    *
 *   into the wild, blue yonder, up and away...  :)         *
 *                                                          *
 ************************************************************
 */
    value =
        SearchSMP(shared->thread[tid], shared->thread[tid]->alpha,
        shared->thread[tid]->beta, shared->thread[tid]->value,
        shared->thread[tid]->wtm, shared->thread[tid]->depth,
        shared->thread[tid]->ply, shared->thread[tid]->mate_threat);
    Lock(shared->lock_smp);
    Lock(shared->thread[tid]->parent->lock);
#if defined(DEBUGSMP)
    Lock(shared->lock_io);
    Print(128, "thread %d  block %d marked free at ply %d\n", tid,
        FindBlockID(shared->thread[tid]), shared->thread[tid]->ply);
    Unlock(shared->lock_io);
#endif
    CopyFromSMP((TREE *) shared->thread[tid]->parent, shared->thread[tid],
        value);
    shared->thread[tid]->parent->nprocs--;
#if defined(DEBUGSMP)
    Lock(shared->lock_io);
    Print(128, "thread %d decremented block %d  nprocs=%d\n", tid,
        FindBlockID(shared->thread[tid]->parent),
        shared->thread[tid]->parent->nprocs);
    Unlock(shared->lock_io);
#endif
    shared->thread[tid]->parent->siblings[tid] = 0;
    Unlock(shared->thread[tid]->parent->lock);
#if defined(DEBUGSMP)
    Lock(shared->lock_io);
    Print(128, "thread %d  block %d  parent %d  nprocs %d exit at ply %d\n",
        tid, FindBlockID(shared->thread[tid]),
        FindBlockID(shared->thread[tid]->parent),
        shared->thread[tid]->parent->nprocs, shared->thread[tid]->ply);
    Unlock(shared->lock_io);
#endif
    shared->thread[tid] = 0;
    Unlock(shared->lock_smp);
  }
}
