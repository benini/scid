/*
* Copyright (c) 1999  Shane Hudson
* Copyright (C) 2014  Fulvio Benini

* This file is part of Scid (Shane's Chess Information Database).
*
* Scid is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation.
*
* Scid is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with Scid.  If not, see <http://www.gnu.org/licenses/>.
*/


#ifndef SCID_GFILE_H
#define SCID_GFILE_H

#include "common.h"
#include "bytebuf.h"
#include "fastgame.h"

class MFile;

// The GFile max block size is 128 kilobytes because IndexEntry::Length is a 17 bits uint
#define GF_BLOCKSIZE  131072
const char GFILE_SUFFIX [] = ".sg4";


class GFile
{
private:
    fileNameT FileName;
    MFile *   Handle;
    fileModeT FileMode;
    uint      Offset;
    int NumBlocks;
    int LastBlockSize;
    struct gfBlockT
    {
        int   blockNum;
        bool  dirty;
        uint  length;
        byte  data [GF_BLOCKSIZE];
    }  CurrentBlock;

    GFile(const GFile&);
    GFile& operator=(const GFile&);
    void Init ();
    errorT Fetch (gfBlockT * blk, int blockNum);
    errorT Flush (gfBlockT * blk);
    const byte* read_ (uint offset, uint length)
    {
        int blockNum = (offset / GF_BLOCKSIZE);
        int endBlockNum = (offset + length - 1) / GF_BLOCKSIZE;
        if (endBlockNum != blockNum  || blockNum >= NumBlocks) return 0;
        if (CurrentBlock.blockNum != blockNum) {
            if (Fetch (&CurrentBlock, blockNum) != OK) return 0;
        }

        return CurrentBlock.data + (offset % GF_BLOCKSIZE);
    }

public:
    GFile()  { Init(); }
    ~GFile();

    errorT   Create (const char * filename);
    errorT   CreateMemoryOnly ();
    errorT   Open (const char * filename, fileModeT fmode);
    errorT   Close ();
    void     FlushAll ()  { Flush (&CurrentBlock); }
    
    errorT   AddGame (ByteBuffer * bb, uint * offset);
    const byte* getGame(uint offset, uint length) {
        return read_(offset, length);
    }
    errorT   ReadGame (ByteBuffer * bb, uint offset, uint length) {
        const byte* b = read_(offset, length);
        if (b == 0) return ERROR_FileRead;
        // The data for the game is not actually copied into the bytebuffer, which would
        // be slower and a waste of time if the bytebuffer is not going to be modified.
        bb->ProvideExternal ((byte*) b, length);
        return OK;
    }
};

#endif // SCID_GFLE_H

//////////////////////////////////////////////////////////////////////
//  EOF: gfile.h
//////////////////////////////////////////////////////////////////////

