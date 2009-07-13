//////////////////////////////////////////////////////////////////////
//
//  FILE:       gfile.cpp
//              GFile class methods
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    2.3
//
//  Notice:     Copyright (c) 2001  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////

#include <stdio.h>
#include <string.h>

#include "common.h"
#include "error.h"
#include "gfile.h"
#include "misc.h"

typedef gfBlockT *  gfBlockPtrT;


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// clearBlockData(): inline routine to clear a block.
//
inline void
clearBlockData (gfBlockT * blk)
{
    blk->length = 0;
    register byte * b = blk->data;
    memset( b, 0, GF_BLOCKSIZE );
//     for (register uint i = GF_BLOCKSIZE; i > 0; i--, b++) { *b = 0; } 
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// GFile::Init(): Initialise the GFile.
//
void
GFile::Init ()
{
    Handle = NULL;
#ifdef WINCE
    Cache = (gfBlockPtrT*) my_Tcl_Alloc(sizeof( gfBlockPtrT[1] ));
#else
    Cache = new gfBlockPtrT [1];
#endif
    CacheSize = 1;
    Offset = 0;
    NumBlocks = 0;

#ifdef WINCE
    Cache[0] = (gfBlockPtrT) my_Tcl_Alloc(sizeof( gfBlockT ));
#else
    Cache[0] = new gfBlockT;
#endif

    Cache[0]->blockNum = -1;
    Cache[0]->dirty = 0;
    Cache[0]->length = 0;
    CurrentBlock = Cache[0];    
    FileMode = FMODE_None;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// GFile::GetFileSize(): returns the current file size in bytes.
uint
GFile::GetFileSize() {
    if (NumBlocks == 0) { return 0; }
    return (NumBlocks - 1) * GF_BLOCKSIZE  + LastBlockSize;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// GFile::Close(): close the GFile.
errorT
GFile::Close ()
{
    if (Handle == NULL) { return ERROR_FileNotOpen; }
    if (CurrentBlock->dirty  &&  FileMode != FMODE_ReadOnly) {
        if (Flush (CurrentBlock) != OK) { return ERROR_FileWrite; }
    }

    errorT result = Handle->Close ();
    delete Handle;
    Handle = NULL;
    FileMode = FMODE_None;
    for (uint i=0; i < CacheSize; i++) {
#ifdef WINCE
        my_Tcl_Free( (char*)Cache[i]);
    }
    my_Tcl_Free( (char*) Cache);
#else
        delete Cache[i];
    }
    delete[] Cache;
#endif

    Init();
    return result;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// GFile::Create():
//      Create a new gfile. The parameter "fmode" can be writeonly or
//      both, but it makes no sense for it to be readonly.
//
errorT
GFile::Create (const char * filename, fileModeT fmode)
{
    if (Handle != NULL) { return ERROR_FileInUse; }
    sprintf (FileName, "%s%s", filename, GFILE_SUFFIX);
    FileMode = fmode;
    Handle = new MFile;
    if (Handle->Create (FileName, fmode) != OK) {
        delete Handle;
        Handle = NULL;
        return ERROR_FileOpen;
    }
    CurrentBlock->blockNum = -1;
    Offset = 0;
    NumBlocks = 0;
    LastBlockSize = 0;
    return OK;
}

errorT
GFile::CreateMemoryOnly ()
{
    if (Handle != NULL) { return ERROR_FileInUse; }
    FileMode = FMODE_Both;
    Handle = new MFile;
    CurrentBlock->blockNum = -1;
    Offset = 0;
    NumBlocks = 0;
    LastBlockSize = 0;
    return OK;
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// GFile::Open():
//      Open a gfile for reading, writing, or both.
//
errorT
GFile::Open (const char * filename, fileModeT fmode, const char * suffix)
{
    if (Handle != NULL) { return ERROR_FileInUse; }
    FileMode = fmode;
    sprintf (FileName, "%s%s", filename, suffix);
    Handle = new MFile;
    if (Handle->Open (FileName, fmode) != OK) {
        delete Handle;
        Handle = NULL;
        return ERROR_FileOpen;
    }

    // Set the buffer size for buffered I/O on this file to be
    // GF_BLOCKSIZE for efficiency.
    // This seems to make tree or position searches on large databases
    // a little faster (maybe up to 10%) from my observations.

    Handle->SetBufferSize (GF_BLOCKSIZE);

    CurrentBlock->blockNum = -1;
    Offset = 0;
    uint fsize = fileSize (filename, suffix);
    NumBlocks = (fsize + GF_BLOCKSIZE - 1) / GF_BLOCKSIZE;
    if (NumBlocks > 0) {
        LastBlockSize = (fsize % GF_BLOCKSIZE);
        if (LastBlockSize == 0) { LastBlockSize = GF_BLOCKSIZE; }
    }
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// GFile::Flush():
//      Flush any blocks that have been modified to the disk.
//
errorT
GFile::Flush (gfBlockT * blk)
{
    if (Handle == NULL) { return ERROR_FileNotOpen; }
    if (FileMode == FMODE_ReadOnly) { return ERROR_FileMode; }
    if (blk->dirty == 0) {
        // File is clean, no need to write anything.
        return OK;
    }
    if (blk->blockNum == -1) {
        // No blocks in the file yet.
        return OK;
    }
    uint filePos = blk->blockNum * GF_BLOCKSIZE;
    if (FileMode == FMODE_Both  ||  Offset != filePos) {
        if (Handle->Seek(filePos) != OK) { return ERROR_FileSeek; }
        Offset = filePos;
    }
    uint numBytes = GF_BLOCKSIZE;
    if (blk->blockNum == (int)NumBlocks - 1) {
        // Last block, so only write "length" bytes.
        numBytes = blk->length;
    }
    if (Handle->WriteNBytes ((const char *)blk->data, numBytes) != OK) {
        return ERROR_FileWrite; 
    }
    if (FileMode == FMODE_Both) { Handle->Flush(); }
    Writes++;
    Offset += numBytes;
    blk->dirty = 0;
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// GFile::Fetch():
//      Fetch a single block from the file.
//
errorT
GFile::Fetch (gfBlockT * blk, uint blkNum)
{
    if (Handle == NULL) { return ERROR_FileNotOpen; }
    if (blk->dirty  &&  FileMode != FMODE_ReadOnly) { Flush(blk); }
    uint filePos = blkNum * GF_BLOCKSIZE;
    if (Offset != filePos) {
        if (Handle->Seek(filePos) != OK) { return ERROR_FileSeek; }
        Offset = filePos;
    }
    uint numBytes = GF_BLOCKSIZE;
    if (blkNum == (NumBlocks - 1)) { 
        // Last block, so its size is LastBlockSize
        numBytes = LastBlockSize;
    }
    if (Handle->ReadNBytes ((char *)blk->data, numBytes) != OK) {
        return ERROR_FileRead; 
    }
    Reads++;
    Offset += numBytes;
    blk->dirty = 0;
    blk->blockNum = blkNum;
    blk->length = numBytes;
    return OK;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// GFile::ReadGame():
//      Fetches the appropriate block to read a specified game from
//      the file, and sets the ByteBuffer bb's pointer to the start
//      of the data for that game. So the data for the game is not
//      actually copied into the bytebuffer, which would be slower
//      and a waste of time if the bytebuffer is not going to be
//      modified.
errorT
    GFile::ReadGame (ByteBuffer * bb, uint offset, uint length)
{
  ASSERT (bb != NULL);
  if (Handle == NULL) { return ERROR_FileNotOpen; }
  int blockNum = (offset / GF_BLOCKSIZE);
  int endBlockNum = (offset + length - 1) / GF_BLOCKSIZE;
  if (endBlockNum != blockNum  ||  (uint)blockNum >= NumBlocks) {
    return ERROR_CorruptData;
  }
  if (CurrentBlock->blockNum != blockNum) {
    if (Fetch (CurrentBlock, blockNum) != OK) {
      return ERROR_FileRead;
    }
  }
  bb->ProvideExternal (&(CurrentBlock->data[offset % GF_BLOCKSIZE]),
                         length);
  return OK;
}
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// GFile::AddGame():
//      Add a game record to the file. It is added to the end of the
//      last block, or a new block is added if the record will not
//      fit in the last block.
//
errorT
GFile::AddGame (ByteBuffer * bb, uint * offset)
{
    *offset = 0;
    if (Handle == NULL) { return ERROR_FileNotOpen; }
    if (FileMode == FMODE_ReadOnly) { return ERROR_FileMode; }
    if (NumBlocks == 0) { // First block for this file
        CurrentBlock->blockNum = 0;
        NumBlocks++;
        clearBlockData (CurrentBlock);
    } else {
        // Either add to the last block, or make a new block:
        
        if (LastBlockSize + bb->GetByteCount() > GF_BLOCKSIZE) {
            // Need a new block!
            
            if (Flush(CurrentBlock) != OK) { return ERROR_FileWrite; }
            NumBlocks++;
            CurrentBlock->blockNum = NumBlocks - 1;
            clearBlockData (CurrentBlock);
        } else {
            // It will fit in the last block. Fetch it:
            
            if (CurrentBlock->blockNum != (int) NumBlocks - 1) {
                Fetch (CurrentBlock, NumBlocks - 1);
            }
        }
    }
    
    // Now, CurrentBlock contains the block the game will be added to.
    ASSERT (CurrentBlock->length + bb->GetByteCount() <= GF_BLOCKSIZE);

    bb->CopyTo (&(CurrentBlock->data[CurrentBlock->length]));
    *offset = CurrentBlock->blockNum * GF_BLOCKSIZE + CurrentBlock->length;
    CurrentBlock->length += bb->GetByteCount();
    LastBlockSize = CurrentBlock->length;
    CurrentBlock->dirty = 1;
    return OK;
}

//////////////////////////////////////////////////////////////////////
//  EOF: gfile.cpp
//////////////////////////////////////////////////////////////////////

