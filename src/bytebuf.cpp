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


#include "bytebuf.h"

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
ByteBuffer::ProvideExternal (byte * data, size_t length)
{
    ExternalBuffer = data;
    ByteCount = length;
    ReadPos = 0;
    Current = Buffer = ExternalBuffer;
    Err = OK;
}

//////////////////////////////////////////////////////////////////////
//  EOF: bytebuf.cpp
//////////////////////////////////////////////////////////////////////
