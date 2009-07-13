//////////////////////////////////////////////////////////////////////
//
//  FILE:       bytebuf.cpp
//              ByteBuffer class for Scid.
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    0.3
//
//  Notice:     Copyright (c) 1999  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////


#include "error.h"
#include "bytebuf.h"
#include <stdio.h>
#include <string.h>

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ByteBuffer::Init():
//      Initialises the ByteBuffer.
//
void
ByteBuffer::Init()
{
    BufferSize = ReadPos = ByteCount = 0;
    Buffer = Current = NULL;
    AllocatedBuffer = NULL;
    ExternalBuffer = NULL;
    Err = OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ByteBuffer::Empty():
//      Empties the ByteBuffer.
//
void
ByteBuffer::Empty()
{
    ReadPos = ByteCount = 0;
    ExternalBuffer = NULL;
    Buffer = AllocatedBuffer;
    Current = Buffer;
    Err = OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ByteBuffer::SetBufferSize():
//      Sets the ByteBuffer's allocated buffer size.
//
void
ByteBuffer::SetBufferSize (uint length)
{
#ifdef WINCE
    if (AllocatedBuffer) { my_Tcl_Free((char*) AllocatedBuffer); }
    AllocatedBuffer = (byte*)my_Tcl_Alloc(sizeof( byte[length]));
#else
    if (AllocatedBuffer) { delete[] AllocatedBuffer; }
    AllocatedBuffer = new byte[length];
#endif
    Buffer = AllocatedBuffer;
    Current = Buffer;
    ReadPos = ByteCount = 0;
    BufferSize = length;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ByteBuffer::BackToStart():
//      Sets the ByteBuffer's read position back to the buffer start.
//
void
ByteBuffer::BackToStart()
{
    ReadPos = 0;
    Current = Buffer;
    Err = OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ByteBuffer::ProvideExternal():
//      Provides an external buffer to use instead of the allocated
//      buffer. This is used when the buffer is only going to be read
//      and it would waste time (and degrade performance) to copy the
//      data to the buffer's allocated space first.
//
void
ByteBuffer::ProvideExternal (byte * data, uint length)
{
    ExternalBuffer = data;
    ByteCount = length;
    ReadPos = 0;
    Current = Buffer = ExternalBuffer;
    Err = OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ByteBuffer::RemoveExternal():
//      Removes the external buffer previously provided.
//
void
ByteBuffer::RemoveExternal ()
{
    Empty();
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ByteBuffer::Get2Bytes(), Put2Bytes(),
//      Get3Bytes(), Put3Bytes(), Get4Bytes(), Put4Bytes():

uint
ByteBuffer::Get2Bytes ()
{

    ASSERT(Current != NULL);
    if (ReadPos + 2 > ByteCount) { Err = ERROR_BufferRead; return 0; }
    uint val;
    val = *Current;  Current++;
    val = val << 8;
    val += *Current;  Current++;
    ReadPos += 2;
    return val;
}

void
ByteBuffer::Put2Bytes (uint value)
{
    ASSERT(Current != NULL);
    *Current = ((value >> 8) & 255);  Current++;
    *Current = (value & 255);  Current++;
    ByteCount += 2;
}

void
ByteBuffer::Put3Bytes (uint value)
{
    ASSERT(Current != NULL);
    *Current = (value & 255); Current++;
    *Current = ((value >> 8) & 255); Current++;
    *Current = ((value >> 16) & 255); Current++;
    ByteCount += 3;
}

void
ByteBuffer::Put4Bytes (uint value)
{
    ASSERT(Current != NULL);
    *Current = (value & 255); Current++;
    *Current = ((value >> 8) & 255); Current++;
    *Current = ((value >> 16) & 255); Current++;
    *Current = ((value >> 24) & 255); Current++;
    ByteCount += 4;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ByteBuffer::Skip():
//      Skips over a specified number of bytes.
void
ByteBuffer::Skip (uint length)
{
    ASSERT (Current != NULL);

    if (ReadPos + length > ByteCount) { Err = ERROR_BufferRead; return; }
    ReadPos += length;
    Current += length;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ByteBuffer::GetFixedString():
//      Reads a fixed-length string from the buffer. A terminating
//      null character is not added.
void
ByteBuffer::GetFixedString (char * str, uint length)
{
    ASSERT(Current != NULL  &&  str != NULL);

    if (Err != OK) { return; }
    if (ReadPos + length > ByteCount) { Err = ERROR_BufferRead; return; }
    ReadPos += length;
    while (length > 0) {
        *str = *Current; Current++; str++;
        length--;
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ByteBuffer::PutFixedString():
//      Writes a fixed-length string to the buffer. A terminating null
//      character is not written, unless it was part of the string.
void
ByteBuffer::PutFixedString (const char * str, uint length)
{
    ASSERT(Current != NULL  &&  str != NULL);
    if (ByteCount + length > BufferSize) { Err = ERROR_BufferFull; return; }
    ByteCount += length;
    while (length > 0) {
        *Current = *str; Current++; str++;
        length--;
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ByteBuffer::GetTerminatedString():
//    Get a null-terminated string.
//    Just sets str to point to current, and then moves current
//    to the end of the string, so the calling function can to
//    duplicate the string itself if it needs to.
//    The length returned does not include the trailing '\0'.
uint
ByteBuffer::GetTerminatedString (char ** str)
{
    ASSERT(Current != NULL  &&  str != NULL);

    uint length = 0;
    *str = (char *) Current;
    while (*Current) {
        Current++;
        length++;
        ReadPos++;
    }
    Current++;
    length++;
    ReadPos++;
    if (ReadPos > ByteCount) { Err = ERROR_BufferRead; }
    return length;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ByteBuffer::PutTerminatedString():
//      Writes a null-terminated string to the buffer, including
//      the null character.
void
ByteBuffer::PutTerminatedString (const char * str)
{
    ASSERT(Current != NULL  &&  str != NULL);
    while (*str) {
        if (ByteCount >= BufferSize) { Err = ERROR_BufferFull; return; }
        *Current = *str; Current++; str++;
        ByteCount++;
    }
    *Current = 0; Current++; ByteCount++;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ByteBuffer::CopyTo():
//      Write the buffer to an area of memory.
void
ByteBuffer::CopyTo (byte * target)
{
    ASSERT (Current != NULL  &&  target != NULL);
//     register byte * from, * to;
//     register uint i = ByteCount;
//     from = Buffer;
//     to = target;
    memcpy( target , Buffer, ByteCount);
    
//     while (i) {
//         *to++ = *from++;
//         i--;
//     }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ByteBuffer::CopyFrom():
//      Read the buffer from an area of memory.
void
ByteBuffer::CopyFrom (byte * source, uint length)
{
    ASSERT (Current != NULL  &&  source != NULL);
    ASSERT (BufferSize >= length);
    Current = Buffer;
    ReadPos = 0;
//     register byte * from, * to;
//     register uint i = length;
//     from = source; to = Buffer;
    
    memcpy( Buffer , source, ByteCount);
//     while (i) {
//         *to++ = *from++;
//         i--;
//     }
    ByteCount = length;
    Err = OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ByteBuffer::CopyFrom():
//      Read the buffer from an area of memory.
// offset is the place where to start copying data
void
ByteBuffer::CopyFrom (byte * source, uint length, uint offset)
{
    ASSERT (Current != NULL  &&  source != NULL);
    ASSERT (BufferSize >= length+offset);
    Current = Buffer;
    ReadPos = 0;
    register byte * from, * to;
    register uint i = length;
    from = source; to = Buffer+offset;
    while (i) {
        *to++ = *from++;
        i--;
    }
    ByteCount = length+offset;
    Err = OK;
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ByteBuffer::DumpToFile():
//      Writes the buffer to an open file.
//
#ifdef WINCE
void
ByteBuffer::DumpToFile (/*FILE * */Tcl_Channel fp)
{
    ASSERT (Current != NULL  &&  fp != NULL);
    byte *b = Buffer;
    my_Tcl_Write(fp, (char *)b, ByteCount);
    /*for (uint count = 0; count < ByteCount; count++) {
        putc (*b, fp);
        b++;
    }*/
}
#else
void
ByteBuffer::DumpToFile (FILE * fp)
{
    ASSERT (Current != NULL  &&  fp != NULL);
    byte *b = Buffer;
    for (uint count = 0; count < ByteCount; count++) {
        putc (*b, fp);
        b++;
    }
}
#endif

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// ByteBuffer::ReadFromFile():
//      Reads the buffer from an open file, overwriting the existing
//      contents of the buffer.
//
#ifdef WINCE
void
ByteBuffer::ReadFromFile (/*FILE * */Tcl_Channel fp, uint length)
{
    ASSERT (Current != NULL  &&  fp != NULL);
    Err = OK;
    Current = Buffer;
    //byte * b = Current;
    ReadPos = 0; ByteCount = 0;
    my_Tcl_Read(fp, (char * )Buffer, length);
    /*for (uint count = 0; count < length; count++) {
        *b = getc (fp);
        b++; ByteCount++;
    }*/
}
#else
void
ByteBuffer::ReadFromFile (FILE * fp, uint length)
{
    ASSERT (Current != NULL  &&  fp != NULL);
    Err = OK;
    Current = Buffer;
    byte * b = Current;
    ReadPos = 0; ByteCount = 0;
    for (uint count = 0; count < length; count++) {
        *b = getc (fp);
        b++; ByteCount++;
    }
}
#endif
//////////////////////////////////////////////////////////////////////
//  EOF: bytebuf.cpp
//////////////////////////////////////////////////////////////////////
