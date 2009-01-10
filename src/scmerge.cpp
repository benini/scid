//////////////////////////////////////////////////////////////////////
//
//  FILE:       scmerge.cpp
//              Merge utility for Scid databases
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    3.1
//
//  Notice:     Copyright (c) 1999-2001 Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////


// scmerge: Scid database merge tool
// Usage: scmerge newfile oldfile1 [oldfile2 ....]
// Or:    scmerge newfile -
//              (and the list of old files to be given on stdin line per line)


#include "common.h"
#include "index.h"
#include "namebase.h"
#include "gfile.h"
#include "misc.h"

#include <stdio.h>


//
// Globals
//
char * progName;


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Usage()
//
void
usage (void) {
    fprintf(stderr, "Usage: %s newfile oldfile1 [oldfile2 ...]\n", progName);
    fprintf(stderr, "   Or: %s newfile - (will take file names on stdin separated by newlines)\n", progName);
    fprintf(stderr, "   For example : find . -name '*.si3' | sed s/\\.si3// | scmerge newbase -\n");
    exit(1);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// fileError()
//
inline void
fileError (const char * operation, const char * name, const char * suffix)
{
    fprintf(stderr, "ERROR %s file: %s%s\n", operation, name, suffix);
    exit(1);
}

uint gamesCount = 0;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// mergeFile
inline uint
mergeFile(Index * targetIndex, NameBase * targetNameBase, GFile * targetGFile, const char * targetFileName,
          Index * sourceIndex, NameBase * sourceNameBase, GFile * sourceGFile, const char * sourceFileName,
          ByteBuffer * bbuf)
{
    errorT err = 0;
//     uint gamesCount = 0;

    sourceIndex->SetFileName (sourceFileName);
    sourceNameBase->SetFileName (sourceFileName);
    if (sourceIndex->OpenIndexFile(FMODE_ReadOnly) != OK) {
        fileError ("opening", sourceFileName, INDEX_SUFFIX);
    }
    if (sourceNameBase->ReadNameFile() != OK) {
        fileError ("opening/reading", sourceFileName, NAMEBASE_SUFFIX);
    }
    if (sourceGFile->Open (sourceFileName, FMODE_ReadOnly) != OK) {
        fileError ("opening", sourceFileName, GFILE_SUFFIX);
    }
    for (uint gCount = 0; gCount < sourceIndex->GetNumGames(); gCount++) {
        IndexEntry iE;
        err = sourceIndex->ReadEntries (&iE, gCount, 1);
        if (err != OK) { fileError ("reading", sourceFileName, INDEX_SUFFIX); }
        // Now, the following fields may change: offset, whiteID, blackID,
        //     eventID, siteID, roundID. All others will be unchanged.

        // We add each name to the new namebase and update the IDs:
        uint newID;
        err = targetNameBase->AddName (NAME_PLAYER,
                                       iE.GetWhiteName (sourceNameBase), &newID);
        targetNameBase->IncFrequency (NAME_PLAYER, newID, 1);
        iE.SetWhite (newID);

        err = targetNameBase->AddName (NAME_PLAYER,
                                       iE.GetBlackName (sourceNameBase), &newID);
        targetNameBase->IncFrequency (NAME_PLAYER, newID, 1);
        iE.SetBlack (newID);

        err = targetNameBase->AddName (NAME_EVENT,
                                       iE.GetEventName (sourceNameBase), &newID);
        targetNameBase->IncFrequency (NAME_EVENT, newID, 1);
        iE.SetEvent (newID);

        err = targetNameBase->AddName (NAME_SITE,
                                       iE.GetSiteName (sourceNameBase), &newID);
        targetNameBase->IncFrequency (NAME_SITE, newID, 1);
        iE.SetSite (newID);

        err = targetNameBase->AddName (NAME_ROUND,
                                       iE.GetRoundName (sourceNameBase), &newID);
        targetNameBase->IncFrequency (NAME_ROUND, newID, 1);
        iE.SetRound (newID);

        // Now, we add the game record to the gfile:
        bbuf->Empty();
        err = sourceGFile->ReadGame (bbuf, iE.GetOffset(), iE.GetLength());
        if (err != OK) { fileError ("reading", sourceFileName, GFILE_SUFFIX); }
        uint newOffset = 0;
        err = targetGFile->AddGame (bbuf, &newOffset);
        if (err != OK) { fileError ("writing", targetFileName, GFILE_SUFFIX); }
        iE.SetOffset (newOffset);

        // Last of all, we write the new index record:
        err = targetIndex->WriteEntries (&iE, gamesCount, 1);
        gamesCount++;
        if (err != OK) { fileError ("writing", targetFileName, INDEX_SUFFIX); }
    }

    // Now we must close and clear the old files:
    sourceIndex->CloseIndexFile();
    sourceNameBase->Clear();
    sourceGFile->Close();

    return gamesCount;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// main()
//
int
main (int argc, char ** argv)
{
    progName = argv[0];
    if (argc < 3)  { usage(); }
    char * targetFileName = argv[1];

    Index * targetIndex = new Index;
    NameBase * targetNameBase = new NameBase;
    GFile * targetGFile = new GFile;

    Index * sourceIndex = new Index;
    NameBase * sourceNameBase = new NameBase;
    GFile * sourceGFile = new GFile;

    ByteBuffer * bbuf = new ByteBuffer;
    bbuf->SetBufferSize (32000);

    targetIndex->SetFileName (targetFileName);
    targetNameBase->SetFileName (targetFileName);

    // Check that the target database does not already exist:
    Index * tempIndex = new Index;
    tempIndex->SetFileName (targetFileName);
    if (tempIndex->OpenIndexFile(FMODE_ReadOnly) == OK) {
        tempIndex->CloseIndexFile();
        fprintf (stderr, "Error: the database %s already exists.\n", targetFileName);
        usage();
    }

    // Open the target files:
    if (targetIndex->CreateIndexFile(FMODE_WriteOnly) != OK) {
        fileError ("creating", targetFileName, INDEX_SUFFIX);
    }
    if (targetGFile->Create (targetFileName, FMODE_WriteOnly) != OK) {
        fileError ("creating", targetFileName, GFILE_SUFFIX);
    }

    uint totalCount = 0;
    uint totalFilesCount = 0;

    // Now execute the merge process once for each existing file:
    for (int i=2; i < argc; i++) {
        char * sourceFileName = argv[i];
        if (strlen(sourceFileName) == 1 && sourceFileName[0] == '-')
        {
            char thisFile[1024] = "";
            while( fgets(thisFile, sizeof(thisFile), stdin) ) {
                int l = strlen(thisFile);
                if( l <= 1)
                    continue;
                if( thisFile[l-1] != '\n') {
                  fprintf(stderr, "File name too long (max: %lu chars)\n", (unsigned long) sizeof(thisFile));
                    exit(1);
                }
                thisFile[l-1] = 0; // throw away \n
                if( l > 2 && thisFile[l-2] == '\r') {
                    thisFile[l-2] = 0; // throw away \r (if happened)
                }
                totalCount += mergeFile(targetIndex, targetNameBase, targetGFile, targetFileName,
                                        sourceIndex, sourceNameBase, sourceGFile, thisFile,
                                        bbuf);
                ++ totalFilesCount;
            }
        }
        else
        {
            totalCount += mergeFile(targetIndex, targetNameBase, targetGFile, targetFileName,
                                    sourceIndex, sourceNameBase, sourceGFile, sourceFileName,
                                    bbuf);
            ++ totalFilesCount;
        }
    }

    // Now all files have been read. All we need do is close the new base:
    targetIndex->CloseIndexFile();
    if (targetNameBase->WriteNameFile() != OK) {
        fileError ("writing", targetFileName, NAMEBASE_SUFFIX);
    }
    if (targetGFile->Close() != OK) {
        fileError ("closing", targetFileName, GFILE_SUFFIX);
    }

    // Remove any treefile for this database:
    removeFile (targetFileName, TREEFILE_SUFFIX);

    // All done!!
    fprintf (stderr, "Successfully merged %u files, of %u games.\n",
             totalFilesCount, targetIndex->GetNumGames());
    return 0;
}

//////////////////////////////////////////////////////////////////////
//  EOF:  scmerge.cpp
//////////////////////////////////////////////////////////////////////

