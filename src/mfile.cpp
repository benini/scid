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

// GZ_BUFFER_SIZE: number of bytes read from a Gzip file at a time.
const uint GZ_BUFFER_SIZE = 1024;

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
    Data = NULL;
    CurrentPtr = NULL;
    FileBuffer = NULL;
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
#ifdef WINCE
    Data = (byte*)my_Tcl_Alloc(sizeof( byte [Capacity]));
#else
    Data = new byte [Capacity];
#endif

    // Copy data to new array:
    for (uint i=0; i < oldCapacity; i++) { Data[i] = oldData[i]; }

#ifdef WINCE
    if (oldCapacity > 0) { my_Tcl_Free((char*)oldData); }
#else
    if (oldCapacity > 0) { delete[] oldData; }
#endif
    CurrentPtr = &(Data[Location]);
}

void
MFile::SetBufferSize (uint bufsize)
{
    if (Type != MFILE_REGULAR) { return; }
    if (FileBuffer != NULL) { return; }
#ifdef WINCE
    FileBuffer = my_Tcl_Alloc(sizeof( char [bufsize]));
#else
    FileBuffer = new char [bufsize];
#endif

#ifdef WINCE
    my_Tcl_SetChannelOption(NULL, Handle, "-buffering", "full");
    char str[32];
    sprintf(str, "%u", bufsize);
    my_Tcl_SetChannelOption(NULL, Handle, "-buffersize", (const char *) str);
#else
    setvbuf (Handle, FileBuffer, _IOFBF, bufsize);
#endif
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

    // We do not need to seek if FileMode is not FMODE_Both and we are
    // already at the position:
    if (FileMode != FMODE_Both  &&  Location == position) { return OK; }

    int result;
    if (Type == MFILE_GZIP) {
        result = gzseek (GzHandle, position, 0);
        GzBuffer_Avail = 0;
    } else {
#ifdef WINCE
        result = my_Tcl_Seek(Handle, position, 0);
    }
    if (result == -1) { return ERROR_FileSeek; }
#else
        // handle position > 2GB
    result = fseek (Handle, position, 0);
    }
    if (result != 0) { return ERROR_FileSeek; }
#endif
    Location = position;
    return OK;
}

errorT
MFile::Flush ()
{
    if (Type != MFILE_REGULAR  ||  FileMode == FMODE_ReadOnly) { return OK; }
#ifdef WINCE
    if (my_Tcl_Flush(Handle) == TCL_OK)
      return OK;
    else
      return ERROR_FileWrite;
#else
    return (fflush (Handle) == 0 ? OK : ERROR_FileWrite);
#endif
}

errorT
MFile::Open (const char * name, fileModeT fmode)
{
    ASSERT (Handle == NULL  &&  GzHandle == NULL);
    char * modeStr = NULL;
    switch (fmode) {
#ifdef WINCE
        case FMODE_ReadOnly:   modeStr = (char *) "r"/*"rb"*/;  break;
        case FMODE_WriteOnly:  modeStr = (char *) "w"/*"wb"*/;  break;
        case FMODE_Both:       modeStr = (char *) "r+"/*"r+b"*/; break;
#else
        case FMODE_ReadOnly:   modeStr = (char *) "rb";  break;
        case FMODE_WriteOnly:  modeStr = (char *) "wb";  break;
        case FMODE_Both:       modeStr = (char *) "r+b"; break;
#endif
        default:               return ERROR_FileMode;
    }

    const char * suffix = strFileSuffix (name);
    if (suffix != NULL  &&  strEqual (suffix, GZIP_SUFFIX)) {
        // We can only open GZip files read-only for now:
        if (fmode != FMODE_ReadOnly) {
            return ERROR_FileOpen;
        }
#ifdef WINCE
        GzHandle = gzopen (name, "r");
#else
        GzHandle = gzopen (name, "rb");
#endif

        if (GzHandle == NULL) { return ERROR_FileOpen; }
        Type = MFILE_GZIP;
#ifdef WINCE
        GzBuffer = (byte *) my_Tcl_Alloc(sizeof(byte [GZ_BUFFER_SIZE]));
#else
        GzBuffer = new byte [GZ_BUFFER_SIZE];
#endif

        GzBuffer_Current = GzBuffer;
        GzBuffer_Avail = 0;
    } else {
#ifdef WINCE
        Handle = mySilent_Tcl_OpenFileChannel(NULL, name, modeStr, 0666);//fopen (name, modeStr);
        if (Handle == NULL) { return ERROR_FileOpen; }
        my_Tcl_SetChannelOption(NULL, Handle, "-encoding", "binary");
        my_Tcl_SetChannelOption(NULL, Handle, "-translation", "binary");
#else
        Handle = fopen (name, modeStr);
        if (Handle == NULL) { return ERROR_FileOpen; }
#endif
        Type = MFILE_REGULAR;
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
    char * modeStr = NULL;
    switch (fmode) {
#ifdef WINCE
        case FMODE_WriteOnly: modeStr = "w"/*"wb"*/;  break;
        case FMODE_Both:      modeStr = "w+"/*"w+b"*/; break;
        default:              return ERROR_FileMode;
    }
    if ((Handle = my_Tcl_OpenFileChannel(NULL, name, modeStr, 0666)/*fopen (name, modeStr)*/) == NULL) {
      return ERROR_FileOpen;
    }
 my_Tcl_SetChannelOption(NULL, Handle, "-encoding", "binary");
 my_Tcl_SetChannelOption(NULL, Handle, "-translation", "binary");
#else
        case FMODE_WriteOnly: modeStr = (char *) "wb";  break;
        case FMODE_Both:      modeStr = (char *) "w+b"; break;
        default:              return ERROR_FileMode;
    }

    if ((Handle = fopen (name, modeStr)) == NULL) { return ERROR_FileOpen; }
    FileMode = fmode;
#endif
    FileName = strDuplicate (name);
    Location = 0;
    Type = MFILE_REGULAR;
    return OK;
}

errorT
MFile::Close ()
{
    if (Type == MFILE_MEMORY) {
#ifdef WINCE
        if (Data != NULL) { my_Tcl_Free( (char*) Data ); }
#else
        if (Data != NULL) { delete[] Data; }
#endif
        Init();
        return OK;
    }
    int result;
    if (Type == MFILE_GZIP) {
        if (GzBuffer != NULL) {
#ifdef WINCE
        my_Tcl_Free( (char *) GzBuffer );
#else
        delete[] GzBuffer;
#endif
            GzBuffer = GzBuffer_Current = NULL;
            GzBuffer_Avail = 0;
        }
        result = gzclose (GzHandle);
    } else {
#ifdef WINCE
        result = my_Tcl_Close(NULL, Handle);//fclose (Handle);
#else
        result = fclose (Handle);
#endif
    }

    if (FileBuffer != NULL) {
#ifdef WINCE
        my_Tcl_Free( FileBuffer );
#else
        delete[] FileBuffer;
#endif
        FileBuffer = NULL;
    }
    if (FileName != NULL) {
#ifdef WINCE
        my_Tcl_Free( FileName );
#else
        delete[] FileName;
#endif
        FileName = NULL;
    }
    Init();
    return (result == 0 ? OK : ERROR);
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

    Location += length;
    
    if (Type == MFILE_GZIP) {
      err = OK;
      while (length-- > 0 && err == OK) {
        err = (gzputc(GzHandle, *str) == EOF) ? ERROR_FileWrite : OK;
        str++;
      }
      return err;
    }

#ifdef WINCE
    return (my_Tcl_Write(Handle, (const char *)str, length) == -1 ) ? ERROR_FileWrite : OK;
#else
    return (fwrite( str, length, 1, Handle) != 1) ? ERROR_FileWrite : OK;
#endif
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
        // Optimization: if FREAD_OPTIMIZE is set,
        // We read the bytes with fread instead of a getc() loop.
        // This makes tree/material/etc searches go faster.

#ifdef WINCE
        Location += my_Tcl_Read (Handle, str, length);
#else

#define FREAD_OPTIMIZE
#ifdef FREAD_OPTIMIZE
        Location += fread (str, 1, length, Handle);
#else
        while (length-- > 0) {
            *str++ = getc(Handle);
        }
        Location++;
#endif
#endif
    }
    return OK;
}

errorT
MFile::ReadLine (char * str, uint maxLength)
{
    ASSERT (FileMode != FMODE_WriteOnly);
    if (Type != MFILE_REGULAR) {
        while (1) {
            if (maxLength == 0) { break; }
            maxLength--;
            char ch = ReadOneByte ();
            *str++ = ch;
            if (ch == '\n') { break; }
        }
        *str = 0;
    } else {
#ifdef WINCE
        while (1) {
            if (maxLength == 0) { break; }
            maxLength--;
            char ch = ReadOneByte ();
            *str++ = ch;
            if (ch == '\n') { break; }
        }
        *str = 0;
        Location = my_Tcl_Tell(Handle);
#else
        fgets (str, (int) maxLength, Handle);
        Location = ftell (Handle);
#endif
    }
    return OK;
}

errorT
MFile::ReadLine (DString * dstr)
{
    int ch = ReadOneByte();
    while (ch != '\n'  &&  ch != EOF) {
        if (ch != '\r') {
            dstr->AddChar (ch);
        }
        ch = ReadOneByte();
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

int
MFile::FillGzBuffer ()
{
    ASSERT (Type == MFILE_GZIP  &&  GzBuffer != NULL  &&  GzBuffer_Avail <= 0);
    int bytesread = gzread (GzHandle, GzBuffer, GZ_BUFFER_SIZE);
    if (bytesread <= 0) { return EOF; }
    GzBuffer_Avail = bytesread - 1;
    GzBuffer_Current = &(GzBuffer[1]);
    return GzBuffer[0];
    
}

//////////////////////////////////////////////////////////////////////
//  End of file: mfile.cpp
//////////////////////////////////////////////////////////////////////
