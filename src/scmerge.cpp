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
//  Author:     Shane Hudson (shane@cosc.canterbury.ac.nz)
//
//////////////////////////////////////////////////////////////////////


// scmerge: Scid database merge tool
// Usage: scmerge newfile oldfile1 [oldfile2 ....]


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


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// main()
//
int
main (int argc, char ** argv)
{
    errorT err;
    progName = argv[0];
    if (argc < 3)  { usage(); }
    char * mergeName = argv[1];

    Index * targetIndex = new Index;
    NameBase * targetNameBase = new NameBase;
    GFile * targetGFile = new GFile;

    Index * sourceIndex = new Index;
    NameBase * sourceNameBase = new NameBase;
    GFile * sourceGFile = new GFile;

    ByteBuffer * bbuf = new ByteBuffer;
    bbuf->SetBufferSize (32000);

    targetIndex->SetFileName (mergeName);
    targetNameBase->SetFileName (mergeName);

    // Check that the target database does not already exist:
    Index * tempIndex = new Index;
    tempIndex->SetFileName (mergeName);
    if (tempIndex->OpenIndexFile(FMODE_ReadOnly) == OK) {
        tempIndex->CloseIndexFile();
        fprintf (stderr, "Error: the database %s already exists.\n", mergeName);
        usage();
    }

    // Open the target files:
    if (targetIndex->CreateIndexFile(FMODE_WriteOnly) != OK) {
        fileError ("creating", mergeName, INDEX_SUFFIX);
    }
    if (targetGFile->Create (mergeName, FMODE_WriteOnly) != OK) {
        fileError ("creating", mergeName, GFILE_SUFFIX);
    }

    uint totalCount = 0;

    // Now execute the merge process once for each existing file:
    for (int i=2; i < argc; i++) {
        char * fileName = argv[i];
        sourceIndex->SetFileName (fileName);
        sourceNameBase->SetFileName (fileName);
        if (sourceIndex->OpenIndexFile(FMODE_ReadOnly) != OK) {
            fileError ("opening", fileName, INDEX_SUFFIX);
        }
        if (sourceNameBase->ReadNameFile() != OK) {
            fileError ("opening/reading", fileName, NAMEBASE_SUFFIX);
        }
        if (sourceGFile->Open (fileName, FMODE_ReadOnly) != OK) {
            fileError ("opening", fileName, GFILE_SUFFIX);
        }
        for (uint gCount = 0; gCount < sourceIndex->GetNumGames(); gCount++) {
            IndexEntry iE;
            err = sourceIndex->ReadEntries (&iE, gCount, 1);
            if (err != OK) { fileError ("reading", fileName, INDEX_SUFFIX); }
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
            if (err != OK) { fileError ("reading", fileName, GFILE_SUFFIX); }
            uint newOffset = 0;
            err = targetGFile->AddGame (bbuf, &newOffset);
            if (err != OK) { fileError ("writing", mergeName, GFILE_SUFFIX); }
            iE.SetOffset (newOffset);

            // Last of all, we write the new index record:
            err = targetIndex->WriteEntries (&iE, totalCount, 1);
            totalCount++;
            if (err != OK) { fileError ("writing", mergeName, INDEX_SUFFIX); }
        }

        // Now we must close and clear the old files:
        sourceIndex->CloseIndexFile();
        sourceNameBase->Clear();
        sourceGFile->Close();
    }

    // Now all files have been read. All we need do is close the new base:
    targetIndex->CloseIndexFile();
    if (targetNameBase->WriteNameFile() != OK) {
        fileError ("writing", mergeName, NAMEBASE_SUFFIX);
    }
    if (targetGFile->Close() != OK) {
        fileError ("closing", mergeName, GFILE_SUFFIX);
    }

    // Remove any treefile for this database:
    removeFile (mergeName, TREEFILE_SUFFIX);

    // All done!!
    fprintf (stderr, "Successfully merged %u files, of %u games.\n",
             argc - 2, targetIndex->GetNumGames());
    return 0;
}

//////////////////////////////////////////////////////////////////////
//  EOF:  scmerge.cpp
//////////////////////////////////////////////////////////////////////

