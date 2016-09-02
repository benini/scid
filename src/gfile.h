/*
* Copyright (c) 1999  Shane Hudson
* Copyright (C) 2014-2016  Fulvio Benini

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

public:
    GFile()  { Init(); }
    ~GFile();

    errorT   Create (const char * filename);
    errorT   Open (const char * filename, fileModeT fmode);
    errorT   Close ();
    errorT   flush();

    errorT addGame(const byte* src, size_t length, uint& resOffset);

    const byte* getGame(uint offset, uint length) {
        int blockNum = (offset / GF_BLOCKSIZE);
        int endBlockNum = (offset + length - 1) / GF_BLOCKSIZE;
        if (endBlockNum != blockNum  || blockNum >= NumBlocks) return 0;
        if (CurrentBlock.blockNum != blockNum) {
            if (Fetch (blockNum) != OK) return 0;
        }

        return CurrentBlock.data + (offset % GF_BLOCKSIZE);
    }

private:
    GFile(const GFile&);
    GFile& operator=(const GFile&);
    void Init ();
    errorT Fetch(int blockNum);
};

#endif // SCID_GFLE_H

//////////////////////////////////////////////////////////////////////
//  EOF: gfile.h
//////////////////////////////////////////////////////////////////////

