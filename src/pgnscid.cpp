//////////////////////////////////////////////////////////////////////
//
//  FILE:       pgnscid.cpp
//              PGN Scanner for Scid
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    2.0
//
//  Notice:     Copyright (c) 1999  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////

#include "common.h"
#include "date.h"
#include "index.h"
#include "namebase.h"
#include "position.h"
#include "game.h"
#include "gfile.h"
#include "progbar.h"
#include "pgnparse.h"

#include <ctype.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <string.h>


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// fatalNameError():
//      Called if there are too many names of a certain type
//      in the namebase. Reports the error and exits.
void
fatalNameError (nameT nt)
{
    fprintf (stderr, "\nERROR: Too many %s names!",
             NAME_TYPE_STRING [nt]);
    fprintf (stderr, "  The maximum allowable number is %u.\n",
             NAME_MAX_ID[nt]);
    fprintf (stderr, "Aborting pgnscid; try using a smaller PGN file.\n");
    exit(1);
}


static void
usage (char * pname)
{
    fprintf (stderr, "%s: create a Scid database from a PGN file.\n", pname);
    fprintf (stderr, "  Usage: %s [-f] [-x] filename.pgn [database]\n", pname);
    fprintf (stderr, "      -f: Force overwrite of existing database.\n");
    fprintf (stderr, "      -x: Ignore comments before games.\n");
    fprintf (stderr, "      Database name defaults to the PGN filename ");
    fprintf (stderr, "without the \".pgn\" suffix.\n");
#ifndef NO_ZLIB
    fprintf (stderr, "  Note: A Gzip compressed file (e.g. filename.pgn.gz) can be used.\n");
#endif
    exit(1);
}


int
main (int argc, char * argv[])
{
    setbuf(stdout, NULL);   // Make stdout unbuffered.

    gameNumberT gNumber;

    bool option_ForceReplace = false;
    bool option_PreGameComments = true;

    uint pgnFileSize = 0;
    char *progname = argv[0];
    fileNameT fname;
    fileNameT baseName;
    uint argsleft = argc - 1;
    char ** nextArg = argv + 1;

    // Parse command-line argments:
    while (argsleft > 0  &&  nextArg[0][0] == '-') {
        if (! strCompare (*nextArg, "-f")) {
            option_ForceReplace = true;
        } else if (! strCompare (*nextArg, "-x")) {
            option_PreGameComments = false;
        } else {
            usage (progname);
        }
        argsleft--;
        nextArg++;
    }
    if (argsleft != 1  &&  argsleft != 2) { usage (progname); }

    char * pgnName = *nextArg;
    MFile * pgnFile = new MFile;

    pgnFileSize = fileSize (pgnName, "");

    // Ensure positive file size counter to avoid division by zero:
    if (pgnFileSize < 1) { pgnFileSize = 1; }

    // Make baseName from pgnName if baseName is not provided:
    if (argsleft == 1) {
        strCopy (baseName, pgnName);
        // If a gzip file, remove two suffixes, the first being ".gz":
        const char * lastSuffix = strFileSuffix (baseName);
        if (lastSuffix != NULL  &&  strEqual (lastSuffix, GZIP_SUFFIX)) {
            strTrimFileSuffix (baseName);
        }
        // Trim the ".pgn" suffix:
        strTrimFileSuffix (baseName);
    } else {
        strCopy (baseName, nextArg[1]);
    }

    // Check for existing database, avoid overwriting it:
    if (! option_ForceReplace) {
        if (fileSize (baseName, INDEX_SUFFIX) > 0) {
            // Scid index file already exists:
            fprintf (stderr, "%s: database already exists: %s\n", progname,
                     baseName);
            fprintf (stderr, "You can use:  %s -f %s   to overwrite"
                     " the existing database.\n", progname, pgnName);
            exit(1);
        }
    }

    if (pgnFile->Open (pgnName, FMODE_ReadOnly) != OK) {
        fprintf (stderr, "%s: could not open file %s\n", progname, pgnName);
        exit(1);
    }

    // Try opening the log file:
    strCopy (fname, baseName);
    strAppend (fname, ".err");
    FILE * logFile = fopen (fname, "w");
    if (logFile == NULL) {
        fprintf (stderr, "%s: could not open log file: %s\n", progname, fname);
        exit(1);
    }
    
    printf ("Converting file %s to Scid database %s:\n", pgnName, baseName);
    printf ("Errors/warnings will be written to %s.\n\n", fname);

    scid_Init();

    GFile * gameFile = new GFile;
    if ((gameFile->Create (baseName, FMODE_WriteOnly)) != OK) {
        fprintf (stderr, "%s: could not create the file %s%s\n",
                 progname, baseName, GFILE_SUFFIX);
        fprintf (stderr, "The file may already exist and be read-only, or\n");
        fprintf (stderr, "you may not have permission to create this file.\n");
        pgnFile->Close();
        exit(1);
    }

    NameBase * nb = new NameBase;
    Index * idx = new Index;
    IndexEntry * ie = new IndexEntry;
    idx->SetFileName (baseName);
    idx->CreateIndexFile (FMODE_WriteOnly);

    Game * game = new Game;
    ProgBar progBar(stdout);
    progBar.Start();

    ByteBuffer *bbuf = new ByteBuffer;
    bbuf->SetBufferSize (BBUF_SIZE); // 32768

    PgnParser pgnParser (pgnFile);
    pgnParser.SetErrorFile (logFile);
    pgnParser.SetPreGameText (option_PreGameComments);
    
    // TODO: Add command line option for ignored tags, rather than
    //       just hardcoding PlyCount as the only ignored tag.
    pgnParser.AddIgnoredTag ("PlyCount");

    // Add each game found to the database:
    while (pgnParser.ParseGame(game) != ERROR_NotFound) {
        ie->Init();

        if (idx->AddGame (&gNumber, ie) != OK) {
            fprintf (stderr, "\nLimit of %d games reached!\n", MAX_GAMES);
            exit(1);
        }

        // Add the names to the namebase:
        idNumberT id = 0;

        if (nb->AddName (NAME_PLAYER, game->GetWhiteStr(), &id) != OK) {
            fatalNameError (NAME_PLAYER);
        }
        nb->IncFrequency (NAME_PLAYER, id, 1);
        ie->SetWhite (id);

        if (nb->AddName (NAME_PLAYER, game->GetBlackStr(), &id) != OK) {
            fatalNameError (NAME_PLAYER);
        }
        nb->IncFrequency (NAME_PLAYER, id, 1);
        ie->SetBlack (id);

        if (nb->AddName (NAME_EVENT, game->GetEventStr(), &id) != OK) {
            fatalNameError (NAME_EVENT);
        }
        nb->IncFrequency (NAME_EVENT, id, 1);
        ie->SetEvent (id);

        if (nb->AddName (NAME_SITE, game->GetSiteStr(), &id) != OK) {
            fatalNameError (NAME_SITE);
        }
        nb->IncFrequency (NAME_SITE, id, 1);
        ie->SetSite (id);

        if (nb->AddName (NAME_ROUND, game->GetRoundStr(), &id) != OK) {
            fatalNameError (NAME_ROUND);
        }
        nb->IncFrequency (NAME_ROUND, id, 1);
        ie->SetRound (id);

        bbuf->Empty();
        if (game->Encode (bbuf, ie) != OK) {
            fprintf (stderr, "Fatal error encoding game!\n");
            abort();
        }
        uint offset = 0;
        if (gameFile->AddGame (bbuf, &offset) != OK) {
            fprintf (stderr, "Fatal error writing game file!\n");
            abort();
        }
        ie->SetOffset (offset);
        ie->SetLength (bbuf->GetByteCount());
        idx->WriteEntries (ie, gNumber, 1);

        // Update the progress bar:
        if (! (gNumber % 100)) {
            int bytesSeen = pgnParser.BytesUsed();
            int percentDone = 1 + ((bytesSeen) * 100 / pgnFileSize);
            progBar.Update (percentDone);
        }

    }

    uint t = 0;   // = time(0);
    nb->SetTimeStamp(t);
    nb->SetFileName (baseName);
    if (nb->WriteNameFile() != OK) {
        fprintf (stderr, "Fatal error writing name file!\n");
        exit(1);
    }
    progBar.Finish();

    printf ("\nDatabase `%s': %d games, %d players, %d events, %d sites.\n",
            baseName, idx->GetNumGames(), nb->GetNumNames (NAME_PLAYER),
            nb->GetNumNames (NAME_EVENT), nb->GetNumNames (NAME_SITE));
    fclose (logFile);
    if (pgnParser.ErrorCount() > 0) {
        printf ("There were %u errors or warnings; ", pgnParser.ErrorCount());
        printf ("examine the file \"%s.err\"\n", baseName);
    } else {
        printf ("There were no warnings or errors.\n");
        removeFile (baseName, ".err");
    }
    gameFile->Close();
    idx->CloseIndexFile();

    // If there is a tree cache file for this database, it is out of date:
    removeFile (baseName, TREEFILE_SUFFIX);
#ifdef ASSERTIONS
    printf("%d asserts were tested\n", numAsserts);
#endif
    pgnFile->Close();
    return 0;
}

//////////////////////////////////////////////////////////////////////
//  EOF: pgnscid.cpp
//////////////////////////////////////////////////////////////////////

