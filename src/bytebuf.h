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

#include "common.h"
#include <algorithm>
#include <string_view>

class ByteBuffer {
    size_t ReadPos = 0;
    size_t ByteCount = 0;
    byte * Buffer = nullptr;
    byte * Current = nullptr;
    errorT Err = OK;

 public:
    ByteBuffer(size_t) {}

    /// The ByteBuffer will act like a std::string_view to the supplied data.
    /// The caller should ensure that @e data remain valid while using the
    /// related ByteBuffer.
    void ProvideExternal(byte* data, size_t length) {
        Current = Buffer = data;
        ByteCount = length;
        ReadPos = 0;
        Err = OK;
    }

    errorT Status ()      { return Err; }
    size_t GetByteCount() { return ByteCount; }

    /// Sets the ByteBuffer's read position back to the buffer start.
    void   BackToStart () {
        ReadPos = 0;
        Current = Buffer;
        Err = OK;
    }

    byte   GetByte () {
        ASSERT(Current != NULL);
        if (ReadPos >= ByteCount) { Err = ERROR_BufferRead; return 0; }
        byte b = *Current;
        Current++; ReadPos++;
        return b;
    }

    /// Reads a fixed-length string from the buffer.
    /// @param length: the number of requested bytes. It is adjusted if it
    ///                exceeds the available bytes in the buffer.
    std::string_view GetFixedString(size_t length) {
        assert(Current != NULL);

        if (Err != OK) {
            length = 0;
        } else if (ReadPos + length > ByteCount) {
            Err = ERROR_BufferRead;
            length = ByteCount - ReadPos;
        }
        auto res = std::string_view(reinterpret_cast<char*>(Current), length);
        Current += length;
        ReadPos += length;
        return res;
    }

    /// Reads a null-terminated string from the buffer.
    const char* GetTerminatedString() {
        assert(Current != NULL);

        const auto begin = Current;
        const auto end = Buffer + ByteCount;
        auto it = std::find(Current, end, 0);
        if (it == end) {
            Err = ERROR_BufferRead;
            return nullptr;
        }
        Current = ++it;
        ReadPos += std::distance(begin, Current);
        return reinterpret_cast<char*>(begin);
    }
};

#endif  // #ifndef SCID_BYTEBUF_H

//////////////////////////////////////////////////////////////////////
//  EOF: bytebuf.h
//////////////////////////////////////////////////////////////////////
