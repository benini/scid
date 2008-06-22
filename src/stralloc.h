//////////////////////////////////////////////////////////////////////
//
//  FILE:       stralloc.h
//              String Allocator class
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    0.3
//
//  Notice:     Copyright (c) 1999  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////

#ifndef SCID_STRALLOC_H
#define SCID_STRALLOC_H

#include "common.h"

// StrAllocator: a fast, space-efficient string allocation class.
//   Designed for allocating mostly short strings, but in large quantity,
//   where the usual deletion strategy is to delete all strings at once.
//   In Scid, this is most useful for the NameBase class, since the space
//   wasted by allocating many thousands of short strings can be huge,
//   especially in environments where new[] or malloc() rounds the
//   requested size to a multiple of 4 or 8 bytes and allocates an extra
//   8 or so bytes for its own information, which is common.

//   In a StrAllocator object, no individual string is ever deleted, unless
//   it was the last one allocated. The space used is only freed when the
//   whole StrAlloc is cleared.
//
//   The StrAllocator allocates memory in large chunks called buckets. The
//   default bucket size is 32000 bytes. To allow strings of any size, a
//   list is kept of all super-large strings (that exceed the bucket size)
//   which are allocated in the usual way.


#define MIN_BUCKET_SIZE        100  // A sensible minimum bucket size.
#define DEFAULT_BUCKET_SIZE  32000
#define DEFAULT_ALIGNMENT        1

struct largeStrT
{
    uint        size;
    char *      data;
    largeStrT * next;
};

struct bucketT
{
    uint      bytesFree;
    char *    data;
    bucketT * next;
};

class StrAllocator
{
  private:    
    uint        BucketSize;
    bucketT *   FirstBucket;
    largeStrT * LargeList;

    // We note last alloc details to avoid wasting space when the last
    // thing allocated is deleted and re-allocated (as happens often).
    char *      LastAllocAddress;
    uint        LastAllocSize;
    
    void  NewBucket();
    char *  NewLarge (uint size);     // When size is too big for a bucket.

  public:
#ifdef WINCE
  void* operator new(size_t sz) {
    void* m = my_Tcl_Alloc(sz);
    return m;
  }
  void operator delete(void* m) {
    my_Tcl_Free((char*)m);
  }
  void* operator new [] (size_t sz) {
    void* m = my_Tcl_AttemptAlloc(sz);
    return m;
  }

  void operator delete [] (void* m) {
    my_Tcl_Free((char*)m);
  }

#endif  
    StrAllocator () {
        BucketSize = DEFAULT_BUCKET_SIZE;
        FirstBucket = NULL;
        LargeList = NULL;
        LastAllocAddress = NULL;
    };
    
    StrAllocator (uint bucketSize) {
        ASSERT (bucketSize >= MIN_BUCKET_SIZE);
        BucketSize = bucketSize;
        FirstBucket = NULL;
        LargeList = NULL;
        LastAllocAddress = NULL;
    }
    
    ~StrAllocator() { DeleteAll(); }
    
    inline void SetBucketSize (uint size);
    
    void DeleteAll();       // Deletes all strings.
    inline void   Delete (const char * str);  // Deletes one string.

    inline char * New (uint numBytes);  // Allocates a new string.
    char *  Duplicate (const char * original);  // Duplicates a string.

    uint   MemoryUsed ();    // Returns total allocated memory.
};

inline void
StrAllocator::SetBucketSize (uint size)
{
    ASSERT (size >= MIN_BUCKET_SIZE);   // Assert a sensible bucket size.
    // We can ONLY change the bucket size when nothing has been allocated.
    if (FirstBucket  ||  LargeList) { return; }
    BucketSize = size;
}

// Deleting an individual string: its space only becomes immediately free
// if it was the most recent string allocated.
inline void
StrAllocator::Delete (const char * str)
{
    ASSERT (str != NULL);
    if (str == LastAllocAddress) {
        ASSERT (FirstBucket != NULL);
        FirstBucket->bytesFree += LastAllocSize;
        LastAllocAddress = NULL; LastAllocSize = 0;
    }
}

inline char *
StrAllocator::New (uint size)
{
    if (size > BucketSize) { return NewLarge (size); }
    if (FirstBucket == NULL  ||  FirstBucket->bytesFree < size) {
        NewBucket();
    }
    LastAllocAddress = &(FirstBucket->data[BucketSize - FirstBucket->bytesFree]);
    LastAllocSize = size;
    FirstBucket->bytesFree -= size;
    return LastAllocAddress;    
}

#endif  // #ifndef SCID_STRALLOC_H

//////////////////////////////////////////////////////////////////////
//  EOF: stralloc.h
//////////////////////////////////////////////////////////////////////

