//////////////////////////////////////////////////////////////////////
//
//  FILE:       gfile.h
//              GFile class
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    1.9
//
//  Notice:     Copyright (c) 1999  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////


#ifndef SCID_GFILE_H
#define SCID_GFILE_H

#include <stdio.h>

#include "common.h"
#include "bytebuf.h"
#include "mfile.h"

// The GFile block size is 32 kilobytes:
#ifdef WINCE
#define GF_BLOCKSIZE  65536
#else
#define GF_BLOCKSIZE  131072 //524288
#endif
// const char OLD_GFILE_SUFFIX [] = ".sg3";
const char GFILE_SUFFIX [] = ".sg4";


// The block structure type:
//
struct gfBlockT
{
    int   blockNum;
    int   dirty;
    uint  length;
    byte  data [GF_BLOCKSIZE];
};


class GFile
{
  private:
    fileNameT FileName;
    MFile *   Handle;
    fileModeT FileMode;
    uint      Offset;

    uint   Reads, Writes;

    uint   NumBlocks;
    uint   LastBlockSize;
    uint   CacheSize;
    gfBlockT  ** Cache;
    gfBlockT  *  CurrentBlock;

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
    GFile()      { Init(); }

    void      Init ();
    
    uint      GetFileSize();
    uint      GetNumReads ()   { return Reads; }
    uint      GetNumWrites ()  { return Writes; }

    errorT    Create (const char * filename, fileModeT fmode);
    errorT    CreateMemoryOnly ();
    errorT    Open (const char * filename, fileModeT fmode, const char * suffix);
    errorT    Open (const char * filename, fileModeT fmode) {
        return Open (filename, fmode, GFILE_SUFFIX);
    }
//     errorT    OpenOld (const char * filename, fileModeT fmode) {
//         return Open (filename, fmode, OLD_GFILE_SUFFIX);
//     }
    errorT    Close ();
    errorT    Fetch (gfBlockT * blk, uint blockNum);
    errorT    Flush (gfBlockT * blk);

    void      FlushAll ()  { Flush (CurrentBlock); }
    
    errorT    AddGame (ByteBuffer * bb, uint * offset);
    errorT    ReadGame (ByteBuffer * bb, uint offset, uint length);
};

#endif // SCID_GFLE_H

//////////////////////////////////////////////////////////////////////
//  EOF: gfile.h
//////////////////////////////////////////////////////////////////////

