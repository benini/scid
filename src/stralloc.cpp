//////////////////////////////////////////////////////////////////////
//
//  FILE:       stralloc.cpp
//              String Allocator class methods
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    1.0
//
//  Notice:     Copyright (c) 1999  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////


#include "stralloc.h"
#include "misc.h"

void
StrAllocator::NewBucket ()
{
#ifdef WINCE
    bucketT * newBucket = (bucketT *) my_Tcl_Alloc( sizeof(bucketT) );
    newBucket->data = my_Tcl_Alloc(sizeof(char [BucketSize]));
#else
    bucketT * newBucket = new bucketT;
    newBucket->data = new char [BucketSize];
#endif
    newBucket->next = FirstBucket;
    newBucket->bytesFree = BucketSize;
    FirstBucket = newBucket;
}

char *
StrAllocator::NewLarge (uint size)
{
    // Called when the requested size exceeds bucket size.
    // So this should be rare.
#ifdef WINCE
    largeStrT * temp = (largeStrT *)my_Tcl_Alloc(sizeof( largeStrT));
    temp->next = LargeList;
    temp->size = size;
    temp->data = my_Tcl_Alloc(sizeof( char [size]));
#else
    largeStrT * temp = new largeStrT;
    temp->next = LargeList;
    temp->size = size;
    temp->data = new char [size];
#endif
    LargeList = temp;
    return temp->data;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// StrAllocator::Duplicate():
//      Duplicates an existing string.
//
char *
StrAllocator::Duplicate (const char * original)
{
    ASSERT (original != NULL);
    uint length = strLength (original);
    char * newStr = New (length + 1);
    char * s = newStr;
    while (*original) {
        *s = *original;  s++;  original++;
    }
    *s = 0;
    return newStr;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// StrAllocator::MemoryUsed():
//      Return the amount of memory used in bytes.
uint
StrAllocator::MemoryUsed ()
{
    uint memUsed = 0;
    bucketT * bucket = FirstBucket;
    while (bucket != NULL) {
        memUsed += sizeof(bucketT) + BucketSize;
        bucket = bucket->next;
    }
    largeStrT * large = LargeList;
    while (large != NULL) {
        memUsed += sizeof(largeStrT) + large->size;
        large = large->next;
    }
    return memUsed;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// StrAllocator::DeleteAll():
//      Delete all strings.
//
void
StrAllocator::DeleteAll ()
{
    // First, delete every super-large string:
    while (LargeList != NULL) {
        largeStrT * temp = LargeList->next;
#ifdef WINCE
        my_Tcl_Free((char*) LargeList->data);
        my_Tcl_Free((char*) LargeList);
#else
        delete[] LargeList->data;
        delete LargeList;
#endif
        LargeList = temp;
    }

    // Now delete every bucket:
    while (FirstBucket != NULL) {
        bucketT * temp = FirstBucket->next;
#ifdef WINCE
        my_Tcl_Free((char*) FirstBucket->data);
        my_Tcl_Free((char*) FirstBucket);
#else
        delete[] FirstBucket->data;
        delete FirstBucket;
#endif
        FirstBucket = temp;
    }
    LastAllocAddress = NULL;
    LastAllocSize = 0;
}

//////////////////////////////////////////////////////////////////////
// EOF: stralloc.cpp
//////////////////////////////////////////////////////////////////////

