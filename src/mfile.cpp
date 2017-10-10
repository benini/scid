//////////////////////////////////////////////////////////////////////
//
//  FILE:       mfile.cpp
//              MFile class methods
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    2.0
//
//  Notice:     Copyright (c) 2000  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////

#include "common.h"
#include "mfile.h"
#include "misc.h"

void
MFile::Init ()
{
    Handle = NULL;
    GzHandle = NULL;
    GzBuffer = NULL;
    FileMode = FMODE_Both;
    Type = MFILE_MEMORY;
    Capacity = 0;
    Location = 0;
    SeqReadLocation = 0;
    Data = NULL;
    CurrentPtr = NULL;
    FileName = NULL;
}

void
MFile::Extend ()
{
    ASSERT (Type == MFILE_MEMORY);
    // Double Capacity, starting with at least 8 Kb:
    uint oldCapacity = Capacity;
    Capacity += Capacity;
    if (Capacity < 8192) { Capacity = 8192; }
    byte * oldData = Data;
    Data = new byte [Capacity];
    CurrentPtr = &(Data[Location]);
    if (oldData != NULL) {
        // Copy data to new array:
        for (uint i=0; i < oldCapacity; i++) { Data[i] = oldData[i]; }
        delete[] oldData;
    }
}

errorT
MFile::Seek (uint position)
{
    if (Type == MFILE_MEMORY) {
        while (position >= Capacity) { Extend(); }
        CurrentPtr = &(Data[position]);
        Location = position;
        return OK;
    }

    if (Type == MFILE_SEQREAD) {
        Type = MFILE_REGULAR;
        if (Data != NULL) delete[] Data;
        Data = CurrentPtr = NULL;
        Capacity = 0;
    } else {
        if (FileMode != FMODE_Both  &&  Location == position) { return OK; }
    }

    int result;
    if (Type == MFILE_GZIP) {
        result = gzseek (GzHandle, position, 0);
        GzBuffer_Avail = 0;
    } else {
        result = fseek (Handle, position, 0);
    }
    if (result != 0) { return ERROR_FileSeek; }
    Location = position;
    return OK;
}

errorT
MFile::Flush ()
{
    if (Type != MFILE_REGULAR  ||  FileMode == FMODE_ReadOnly) { return OK; }
    return (fflush (Handle) == 0 ? OK : ERROR_FileWrite);
}

errorT
MFile::Open (const char * name, fileModeT fmode)
{
    ASSERT (Handle == NULL  &&  GzHandle == NULL);
    const char * modeStr = NULL;
    switch (fmode) {
        case FMODE_ReadOnly:   modeStr = "rb";  break;
        case FMODE_WriteOnly:  modeStr = "wb";  break;
        case FMODE_Both:       modeStr = "r+b"; break;
        default:               return ERROR_FileMode;
    }

    {
        Handle = fopen (name, modeStr);
        if (Handle == NULL) { return ERROR_FileOpen; }
        Type = MFILE_SEQREAD;
        Data = new byte [SEQREADBUFSIZE];
        CurrentPtr = Data;
        SeqReadLocation = 0;
        fseek(Handle, 0L, SEEK_END);
        Capacity = ftell(Handle);
        fseek(Handle, 0L, SEEK_SET);
    }

    FileMode = fmode;
    FileName = strDuplicate (name);
    Location = 0;
    return OK;
}

errorT
MFile::Create (const char * name, fileModeT fmode)
{
    ASSERT (Handle == NULL  &&  GzHandle == NULL);
    const char * modeStr = NULL;
    switch (fmode) {
        case FMODE_WriteOnly: modeStr = "wb";  break;
        case FMODE_Both:      modeStr = "w+b"; break;
        default:              return ERROR_FileMode;
    }
    if ((Handle = fopen (name, modeStr)) == NULL) { return ERROR_FileOpen; }
    FileMode = fmode;
    FileName = strDuplicate (name);
    Location = 0;
    Type = MFILE_REGULAR;
    return OK;
}

errorT
MFile::WriteNBytes (const char * str, uint length)
{
    ASSERT (FileMode != FMODE_ReadOnly);

    errorT err = OK;
//     while (length-- > 0) {
//         err = WriteOneByte (*str);
//         str++;
//     }
//     return err;
    
    if (Type == MFILE_MEMORY) {
      while (length-- > 0) {
        if (Location >= Capacity) { Extend(); }
        *CurrentPtr++ = *str;
        Location++;
        str++;
      }
      return OK;
    }
    if (Type == MFILE_SEQREAD) Seek(Location);
    Location += length;
    
    if (Type == MFILE_GZIP) {
      err = OK;
      while (length-- > 0 && err == OK) {
        err = (gzputc(GzHandle, *str) == EOF) ? ERROR_FileWrite : OK;
        str++;
      }
      return err;
    }
    return (fwrite( str, length, 1, Handle) != 1) ? ERROR_FileWrite : OK;
}

errorT
MFile::ReadNBytes (char * str, uint length)
{
    ASSERT (FileMode != FMODE_WriteOnly);
    if (Type != MFILE_REGULAR) {
        while (length-- > 0) {
            *str++ = ReadOneByte ();
        }
    } else {
        Location += fread (str, 1, length, Handle);
    }
    return OK;
}

errorT
MFile::WriteTwoBytes (uint value)
{
    ASSERT (FileMode != FMODE_ReadOnly);
    WriteOneByte ((value >> 8) & 255);
    return WriteOneByte (value & 255);
}

uint
MFile::ReadTwoBytes ()
{
    uint result = 0;
    ASSERT (FileMode != FMODE_WriteOnly);
    result = ReadOneByte();
    result <<= 8;
    result += ReadOneByte();
    return result;
}

errorT
MFile::WriteThreeBytes (uint value)
{
    ASSERT (FileMode != FMODE_ReadOnly);
    WriteOneByte ((value >> 16) & 255);
    WriteOneByte ((value >> 8) & 255);
    return WriteOneByte (value & 255);
}

uint
MFile::ReadThreeBytes ()
{
    uint result = 0;
    ASSERT (FileMode != FMODE_WriteOnly);
    result = ReadOneByte();
    result <<= 8;
    result += ReadOneByte();
    result <<= 8;
    result += ReadOneByte();
    return result;
}

errorT
MFile::WriteFourBytes (uint value)
{
    ASSERT (FileMode != FMODE_ReadOnly);
    WriteOneByte ((value >> 24) & 255);
    WriteOneByte ((value >> 16) & 255);
    WriteOneByte ((value >> 8) & 255);
    return WriteOneByte (value & 255);
}


uint
MFile::ReadFourBytes ()
{
    uint result = 0;
    ASSERT (FileMode != FMODE_WriteOnly);
    result = ReadOneByte();
    result <<= 8;
    result += ReadOneByte();
    result <<= 8;
    result += ReadOneByte();
    result <<= 8;
    result += ReadOneByte();
    return result;
}

//////////////////////////////////////////////////////////////////////
//  End of file: mfile.cpp
//////////////////////////////////////////////////////////////////////
