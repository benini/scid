//////////////////////////////////////////////////////////////////////
//
//  FILE:       bytebuf.h
//              ByteBuffer class.
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    0.2
//
//  Notice:     Copyright (c) 1999  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////

// The ByteBuffer class is used to read and write binary buffers.
// It is primarily used in Scid for storing in-memory the contents of
// a game as it is represented on-disk in the gamedata file (gfile).


#ifndef SCID_BYTEBUF_H
#define SCID_BYTEBUF_H

#include "error.h"
#include "common.h"

class ByteBuffer
{
 private:
    //----------------------------------
    //  TextBuffer:  Data Structures
    //----------------------------------

    uint   ReadPos;
    uint   ByteCount;
    uint   BufferSize;
    byte * Buffer;
    byte * Current;
    byte * AllocatedBuffer;
    byte * ExternalBuffer;

    byte  ReadOnly;  // True if Buffer set to an existing byte array.
    errorT Err;
    
    //----------------------------------
    //  TextBuffer:  Public Functions
    //----------------------------------
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
    ByteBuffer()    { Init(); }
    ~ByteBuffer()   {
#ifdef WINCE
if (AllocatedBuffer) { my_Tcl_Free((char*) AllocatedBuffer); }
#else
if (AllocatedBuffer) { delete[] AllocatedBuffer; }
#endif
}
    
    void        Init ();
    void        Free ();
    void        Empty ();
    void        BackToStart ();

    errorT      Status ()   { return Err; }
    void        ResetStatus() { Err = OK; }
    
    void        SetBufferSize (uint length);
    uint        GetBufferSize()     { return BufferSize; }
    uint        GetByteCount()      { return ByteCount; }
    byte *      GetBuffer ()        { return Buffer; }

    void        ProvideExternal (byte * data, uint length);
    void        RemoveExternal ();

    byte
    GetByte () {
        ASSERT(Current != NULL);
        if (ReadPos >= ByteCount) { Err = ERROR_BufferRead; return 0; }
        byte b = *Current;
        Current++; ReadPos++;
        return b;
    }

    void
    PutByte (byte value) {
        ASSERT(Current != NULL);
        if (Buffer == AllocatedBuffer  && ByteCount >= BufferSize) {
            Err = ERROR_BufferFull; return;
        }
        *Current = value;
        Current++; ByteCount++;
    }

    uint        Get2Bytes ();
    void        Put2Bytes (uint value);
    void        Put3Bytes (uint value);
    void        Put4Bytes (uint value);
    void        Skip (uint value);

    void        GetFixedString (char *str, uint length);
    void        PutFixedString (const char *str, uint length);
    uint        GetTerminatedString (char **str);
    void        PutTerminatedString (const char *str);

    void        CopyTo (byte * target);
    void        CopyFrom (byte * source, uint length);
    void        CopyFrom (byte * source, uint length, uint offset);
#ifdef WINCE
    void        DumpToFile (/*FILE * */Tcl_Channel fp);
    void        ReadFromFile (/*FILE * */Tcl_Channel fp, uint length);
#else
    void        DumpToFile (FILE * fp);
    void        ReadFromFile (FILE * fp, uint length);
#endif
};

#endif  // #ifndef SCID_BYTEBUF_H

//////////////////////////////////////////////////////////////////////
//  EOF: bytebuf.h
//////////////////////////////////////////////////////////////////////
