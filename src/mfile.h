//////////////////////////////////////////////////////////////////////
//
//  FILE:       mfile.h
//              MFile class
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    2.0
//
//  Notice:     Copyright (c) 2000  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////


// An MFile is a file that can be a regular file, or memory-only with
// no actual file on any device.
// In addition, an MFile can decode its contents from a GZip (.gz) file
// and will hopefully in future also be able to extract the contents of
// all files in a Zip file, as if they were in one large plain file.


#ifndef SCID_MFILE_H
#define SCID_MFILE_H

#include "common.h"
#include "error.h"
#include <stdio.h>

enum mfileT {
    MFILE_REGULAR = 0, MFILE_MEMORY, MFILE_GZIP, MFILE_ZIP, MFILE_SEQREAD
};

class MFile
{
  private:
    static const int SEQREADBUFSIZE = 64 * 1024;
    FILE *      Handle;         // For regular files.
    gzFile      GzHandle;       // For Gzip files.
    fileModeT   FileMode;
    mfileT      Type;
    char *      FileName;
    uint        Capacity;
    uint        Location;
    uint        SeqReadLocation;
    byte *      Data;
    byte *      CurrentPtr;
    // The next few fields are used to improve I/O speed on Gzip files, by
    // avoiding doing a gzgetc() every character, since the zlib file gzio.c
    // simply does a (relatively slow) gzread() for each gzgetc().
    byte *      GzBuffer;
    int         GzBuffer_Avail;
    byte *      GzBuffer_Current;

    void Init();
    void Extend();
    int  FillGzBuffer();

  public:
    MFile() { Init(); }
    ~MFile() {
        if (Handle != NULL) fclose (Handle);
        if (GzHandle != NULL) gzclose (GzHandle);
        if (Data != NULL) delete[] Data;
        if (GzBuffer != NULL) delete[] GzBuffer;
        if (FileName != NULL) delete[] FileName;
    }

    errorT Create (const char * name, fileModeT fmode);
    errorT Open  (const char * name, fileModeT fmode);
    errorT Seek (uint position);
    errorT Flush ();
    inline bool EndOfFile();

    errorT        WriteNBytes (const char * str, uint length);
    errorT        ReadNBytes (char * str, uint length);
    inline errorT WriteOneByte (byte value);
    errorT        WriteTwoBytes (uint value);
    errorT        WriteThreeBytes (uint value);
    errorT        WriteFourBytes (uint value);
    inline int    ReadOneByte ();
    uint          ReadTwoBytes ();
    uint          ReadThreeBytes ();
    uint          ReadFourBytes ();

    const char * GetFileName () { return (FileName == NULL ? "" : FileName); }
};

inline bool
MFile::EndOfFile ()
{
    switch (Type) {
    case MFILE_MEMORY:
    case MFILE_SEQREAD:
        return (Location >= Capacity);
    case MFILE_REGULAR:
        return feof(Handle);
    case MFILE_GZIP:
        if (GzBuffer_Avail > 0) { return 0; }
        return gzeof(GzHandle);
    default:
        return false;
    }
}

inline errorT
MFile::WriteOneByte (byte value)
{
    ASSERT (FileMode != FMODE_ReadOnly);
    if (Type == MFILE_MEMORY) {
        if (Location >= Capacity) { Extend(); }
        *CurrentPtr++ = value;
        Location++;
        return OK;
    }
    if (Type == MFILE_SEQREAD) Seek(Location);
    Location++;
    if (Type == MFILE_GZIP) {
        return (gzputc(GzHandle, value) == EOF) ? ERROR_FileWrite : OK;
    }
    return (putc(value, Handle) == EOF) ? ERROR_FileWrite : OK;
}

inline int
MFile::ReadOneByte ()
{
    ASSERT (FileMode != FMODE_WriteOnly);
    if (Type == MFILE_MEMORY || Type == MFILE_SEQREAD) {
        if (Location >= Capacity) { return EOF; }
        if (Location == SeqReadLocation && Type == MFILE_SEQREAD) {
            SeqReadLocation += fread(Data, 1, SEQREADBUFSIZE, Handle);
            CurrentPtr = Data;
        }
        byte value = *CurrentPtr;
        Location++;
        CurrentPtr++;
        return (int) value;
    }
    Location++;
    if (Type == MFILE_GZIP) {
        if (GzBuffer_Avail <= 0) {
            return FillGzBuffer();
        }
        GzBuffer_Avail--;
        int retval = *GzBuffer_Current;
        GzBuffer_Current++;
        return retval;
    }
    return  getc(Handle);
}

#endif  // SCID_MFILE_H

