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
//  Author:     Shane Hudson (shane@cosc.canterbury.ac.nz)
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

enum mfileT {
    MFILE_REGULAR = 0, MFILE_MEMORY, MFILE_GZIP, MFILE_ZIP
};

class MFile
{
  private:

    FILE *      Handle;         // For regular files.
    gzFile      GzHandle;       // For Gzip files.
    fileModeT   FileMode;
    mfileT      Type;
    char *      FileName;

    // The next few fields are used to improve I/O speed on Gzip files, by
    // avoiding doing a gzgetc() every character, since the zlib file gzio.c
    // simply does a (relatively slow) gzread() for each gzgetc().
    byte *      GzBuffer;
    int         GzBuffer_Avail;
    byte *      GzBuffer_Current;

    // The next few fields are used for in-memory files.
    uint        Capacity;
    uint        Location;
    byte *      Data;
    byte *      CurrentPtr;

    char *      FileBuffer;  // Only for files with unusual buffer size.

    void  Extend();
    int   FillGzBuffer();

  public:

    MFile() { Init(); }
    ~MFile() {
        if (Handle != NULL) { Close(); }
        if (Data != NULL) { delete[] Data; }
        if (FileBuffer != NULL) { delete[] FileBuffer; }
        if (FileName != NULL) { delete[] FileName; }
    }

    void Init();

    fileModeT Mode() { return FileMode; }

    errorT Create (const char * name, fileModeT fmode);
    errorT Open  (const char * name, fileModeT fmode);
    void   CreateMemory () { Close(); Init(); }
    errorT Close ();

    void   SetBufferSize (uint bufsize);

    uint   Size ();
    uint   Tell () { return Location; }
    errorT Seek (uint position);
    errorT Flush ();
    inline int EndOfFile();

    errorT        WriteNBytes (const char * str, uint length);
    errorT        ReadNBytes (char * str, uint length);
    errorT        ReadLine (char * str, uint maxLength);
    inline errorT WriteOneByte (byte value);
    errorT        WriteTwoBytes (uint value);
    errorT        WriteThreeBytes (uint value);
    errorT        WriteFourBytes (uint value);
    inline int    ReadOneByte ();
    uint          ReadTwoBytes ();
    uint          ReadThreeBytes ();
    uint          ReadFourBytes ();

    inline char * GetFileName ();
};


inline char *
MFile::GetFileName ()
{
    if (FileName == NULL) {
        return "";
    } else {
        return FileName;
    }
}

inline int
MFile::EndOfFile ()
{
    switch (Type) {
    case MFILE_MEMORY:
        return (Location >= Capacity);
    case MFILE_REGULAR:
        return feof(Handle);
    case MFILE_GZIP:
        if (GzBuffer_Avail > 0) { return 0; }
        return gzeof(GzHandle);
    default:
        return 0;
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
    if (Type == MFILE_MEMORY) {
        if (Location >= Capacity) { return EOF; }
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

