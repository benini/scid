//////////////////////////////////////////////////////////////////////
//
//  FILE:       scidt.cpp
//              Scidt utility program.
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    2.7
//
//  Notice:     Copyright (c) 1999-2001  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (shane@cosc.canterbury.ac.nz)
//
//////////////////////////////////////////////////////////////////////

#include "common.h"
#include "index.h"
#include "namebase.h"
#include "misc.h"
#include "date.h"
#include "game.h"
#include "gfile.h"
#include "bytebuf.h"
#include "textbuf.h"
#include "tree.h"
#include "progbar.h"

#include <ctype.h>
#include <stdio.h>
#include <string.h>

#ifndef WIN32
#include <strings.h>
#endif


// GLOBALS:

char * progname;
char * filename = NULL;
errorT err;
char displayStr[] = "g6: w13 W4  b13 B4  r3:m2 y4 s11 o4";

ProgBar * global_ProgBar = new ProgBar (stdout);

// updateProgress: Update the global progress bar
void
updateProgress (void * pdata, uint count, uint total)
{
    global_ProgBar->Update (count * 100 / total);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// usage():
//      Print usage information and exit the program.
//
void
usage (void)
{
    fprintf (stderr, "usage: %s -<option> <database> \n", progname);
    fprintf (stderr, " -i: General database information \n");
    fprintf (stderr, " -d: Change description of database \n");
    fprintf (stderr, " -l: List all games \n");
    fprintf (stderr, " -c: Show compactness of database \n");
    fprintf (stderr, " -C: Compact the database \n");
    fprintf (stderr, " -n: Name information \n");
    fprintf (stderr, " -N: Remove unused names from the namebase file \n");
    fprintf (stderr, " -p[prefix]: list all players starting with prefix \n");
    fprintf (stderr, " -e[prefix]: list all events starting with prefix \n");
    fprintf (stderr, " -s[prefix]: list all sites starting with prefix \n");
    fprintf (stderr, " -r[prefix]: list all rounds starting with prefix \n");
    fprintf (stderr, " -S[sort-fields]: Sort the database \n");
    fprintf (stderr, "  Sort fields: date, year, event, site, round, white, black\n");
    fprintf (stderr, "      eco, result, length, rating, country\n");
    fprintf (stderr, "  Example: scidt -Syear,event,round,date myfile.si\n\n");
    exit (1);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// fileErr():
//      Report error opening a file and exit.
//
void
fileErr (const char * fname, const char * suffix, errorT err)
{
    if (err == ERROR_FileOpen) {
        fprintf (stderr, "%s: ERROR: could not open file \"%s%s\"\n", 
                 progname, fname, suffix);
        fprintf (stderr, "    The file may not exist, or may be read-only.\n");
    } else if (err == ERROR_Corrupt) {
        fprintf (stderr, "%s: ERROR: corrupt data reading \"%s%s\"\n",
                 progname, fname, suffix);
        
    } else {
        fprintf (stderr, "%s: ERROR reading file \"%s%s\"\n",
                 progname, fname, suffix);
    }
    exit(1);
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// PrintGameList():
//      Print a game listing, one line per game.
//
void
PrintGameList (Index * i, NameBase * nb, gameNumberT first,
               gameNumberT last, char * fields, FILE * outf)
{
    char temp [1024];
    gameNumberT gn;
    IndexEntry iE;
    for (gn = first; gn <= last; gn++) {
        if (gn <= i->GetNumGames()) {
            i->ReadEntries (&iE, gn-1, 1);
            iE.PrintGameInfo (temp, gn, gn, nb, fields);
            fputs (temp, outf);
            putc ('\n', outf);
        }
    }
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// printDebugInfo():
//
void
printDebugInfo () {
    printf ("Sizes of classes and structs, in bytes:\n");
    printf ("\nByteBuffer class: %u\n", sizeof(ByteBuffer));

    printf ("\nIndex class: %u\n", sizeof(Index));
    printf ("   indexHeaderT struct: %u\n", sizeof(indexHeaderT));
    printf ("   IndexEntry class: %u\n", sizeof(IndexEntry));

    printf ("\nGame class: %u\n", sizeof(Game));
    printf ("   patternT struct: %u\n", sizeof(patternT));
    printf ("   moveT struct: %u\n", sizeof(moveT));
    printf ("   moveChunkT struct: %u\n", sizeof(moveChunkT));
    printf ("   tagT struct: %u\n", sizeof(tagT));

    printf ("\nGFile class: %u\n", sizeof(GFile));
    printf ("   gfBlockT struct: %u\n", sizeof(gfBlockT));

    printf ("\nNameBase class: %u\n", sizeof(NameBase));
    printf ("   nameBaseHeaderT struct: %u\n", sizeof(nameBaseHeaderT));
    printf ("   nameNodeT struct: %u\n", sizeof(nameNodeT));

    printf ("\nPosition class: %u\n", sizeof(Position));
    printf ("   simpleMoveT struct: %u\n", sizeof(simpleMoveT));
    printf ("   legalMoveListT struct: %u\n", sizeof(legalMoveListT));
    printf ("   sanListT struct: %u\n", sizeof(sanListT));
    printf ("   pseudoLegalListT struct: %u\n", sizeof(pseudoLegalListT));

    printf ("\nTextBuffer class: %u\n", sizeof(TextBuffer));
    
    printf ("\nTreeCache class: %u\n", sizeof(TreeCache));
    printf ("   cachedTreeT struct: %u\n", sizeof(cachedTreeT));
    printf ("   treeT struct: %u\n", sizeof(treeT));
    printf ("   treeNodeT struct: %u\n", sizeof(treeNodeT));
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// recalcNameFrequencies():
//      Resets all name frequencies in the namebase to zero, then
//      reads all index entries to obtain the correct frequency
//      for each name.
//      Takes a namebase and an open index file, and updates
//      the namebase frequencies.
//
void
recalcNameFrequencies (NameBase * nb, Index * idx)
{
    for (nameT nt = NAME_FIRST; nt <= NAME_LAST; nt++) {
        nb->ZeroAllFrequencies (nt);
    }
    IndexEntry iE;
    for (uint i=0; i < idx->GetNumGames(); i++) {
        idx->ReadEntries (&iE, i, 1);
        iE.Verify (nb);
        nb->IncFrequency (NAME_PLAYER, iE.GetWhite(), 1);
        nb->IncFrequency (NAME_PLAYER, iE.GetBlack(), 1);
        nb->IncFrequency (NAME_EVENT, iE.GetEvent(), 1);
        nb->IncFrequency (NAME_SITE, iE.GetSite(), 1);
        nb->IncFrequency (NAME_ROUND, iE.GetRound(), 1);
    }
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// compactNameBase():
//      Compacts a namebase file by removing any names that are no
//      longer referred to by any game. This also requires rewriting
//      the index file since the name ID values may change.
void
compactNameBase (NameBase * nb)
{
    errorT err = nb->ReadNameFile();
    if (err != OK) {
        fileErr (filename, NAMEBASE_SUFFIX, err);
    }
    Index * idxTemp = new Index;
    idxTemp->SetFileName (filename);
    err = idxTemp->OpenIndexFile (FMODE_ReadOnly);
    if (err != OK) {
        fileErr (filename, INDEX_SUFFIX, err);
    }
    recalcNameFrequencies (nb, idxTemp);
    idxTemp->CloseIndexFile();

    // Now, add only the names with nonzero frequencies to a new namebase:

    NameBase * nbNew = new NameBase;

    idNumberT * idMapping [NUM_NAME_TYPES];
    for (nameT nt = NAME_FIRST; nt <= NAME_LAST; nt++) {
        idMapping [nt] = new idNumberT [nb->GetNumNames(nt)];
        idNumberT numNames = nb->GetNumNames (nt);
        for (idNumberT oldID = 0; oldID < numNames; oldID++) {
            char * name = nb->GetName (nt, oldID);
            uint frequency = nb->GetFrequency (nt, oldID);
            if (frequency > 0) {
                uint newID;
                err = nbNew->AddName (nt, name, &newID);
                if (err != OK) {
                    printf ("Error compacting namebase! Aborting...\n");
                    exit(1);
                }
                nbNew->IncFrequency (nt, newID, frequency);
                idMapping[nt][oldID] = newID;
            } else {
                idMapping[nt][oldID] = 0;
            }
        }
    }
    printf ("New: %u players, %u events, %u sites, %u rounds\n",
            nbNew->GetNumNames(NAME_PLAYER), nbNew->GetNumNames(NAME_EVENT),
            nbNew->GetNumNames(NAME_SITE), nbNew->GetNumNames(NAME_ROUND));
    Index * idxOld = new Index;
    Index * idxNew = new Index;
    char tempName[1024];
    strCopy (tempName, filename);
    strAppend (tempName, "_OLD");
    idxOld->SetFileName (tempName);
    idxNew->SetFileName (filename);
    
    printf ("Renaming %s%s to %s%s in case of error...\n",
            filename, INDEX_SUFFIX, tempName, INDEX_SUFFIX);
    if (renameFile (filename, tempName, INDEX_SUFFIX) != OK) {
        fprintf (stderr, "Unable to rename the index file!\n");
        exit(1);
    }
    printf ("Renaming %s%s to %s%s in case of error...\n",
            filename, NAMEBASE_SUFFIX, tempName, NAMEBASE_SUFFIX);
    if (renameFile (filename, tempName, NAMEBASE_SUFFIX) != OK) {
        fprintf (stderr, "Unable to rename the namebase file!\n");
        exit(1);
    }
    err = idxOld->OpenIndexFile (FMODE_ReadOnly);
    if (err != OK) {
        renameFile (tempName, filename, INDEX_SUFFIX);
        fileErr (tempName, INDEX_SUFFIX, err);
    }
    err = idxNew->CreateIndexFile (FMODE_WriteOnly);
    if (err != OK) {
        renameFile (tempName, filename, INDEX_SUFFIX);
        fileErr (filename, INDEX_SUFFIX, err);
    }
    idxNew->SetType (idxOld->GetType());

    printf ("Writing new name and index files...\n");

    // For each entry in old index: read it, alter its name ID
    // values to match the new namebase, and write the entry to
    // the new index.

    gameNumberT newNumGames = 0;
    for (uint i=0; i < idxOld->GetNumGames(); i++) {
        IndexEntry ieOld, ieNew;
        idxOld->ReadEntries (&ieOld, i, 1);
        if (ieOld.Verify (nb) != OK) {
            fprintf (stderr, "Warning: game %u: ", i+1);
            fprintf (stderr, "names were corrupt, they may be incorrect.\n");
        }
        err = idxNew->AddGame (&newNumGames, &ieNew);
        if (err != OK)  { break; }
        ieNew = ieOld;
        ieNew.SetWhite (idMapping [NAME_PLAYER] [ieOld.GetWhite()]);
        ieNew.SetBlack (idMapping [NAME_PLAYER] [ieOld.GetBlack()]);
        ieNew.SetEvent (idMapping [NAME_EVENT] [ieOld.GetEvent()]);
        ieNew.SetSite  (idMapping [NAME_SITE] [ieOld.GetSite()]);
        ieNew.SetRound (idMapping [NAME_ROUND] [ieOld.GetRound()]);
        err = idxNew->WriteEntries (&ieNew, newNumGames, 1);
        if (err != OK)  { break; }
    }

    idxOld->CloseIndexFile();
    idxNew->CloseIndexFile();
    nbNew->SetFileName (filename);

    if (err == OK) {
        err = nbNew->WriteNameFile();
    }

    if (err != OK) {
        fprintf (stderr, "ERROR: I/O error!\n");
        fprintf (stderr, "Restoring original file and aborting.\n");
        removeFile (filename, INDEX_SUFFIX);
        renameFile (tempName, filename, INDEX_SUFFIX);
        exit(1);
    }

    printf ("New index file sucessfully created; old index removed.\n");
    removeFile (tempName, INDEX_SUFFIX);
    removeFile (tempName, NAMEBASE_SUFFIX);
    return;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// printNameInfo():
//
void
printNameInfo (NameBase * nb, Index * idx)
{
    errorT err;
    nameT nt;
    char *ntStr[4] = {"PLAYER", "EVENT", "SITE", "ROUND"};

    err= nb->ReadNameFile();
    if (err != OK) { fileErr (filename, NAMEBASE_SUFFIX, err); }
    err = idx->OpenIndexFile (FMODE_ReadOnly);
    if (err != OK) {
        fileErr (filename, INDEX_SUFFIX, err);
    }

    recalcNameFrequencies (nb, idx);

    printf ("Database %s: %d players, %d events, %d sites, %d rounds.\n",
            filename,
            nb->GetNumNames(NAME_PLAYER),
            nb->GetNumNames(NAME_EVENT),
            nb->GetNumNames(NAME_SITE),
            nb->GetNumNames(NAME_ROUND));

    for (nt = NAME_PLAYER; nt < NUM_NAME_TYPES; nt++) {
        uint numNames = nb->GetNumNames(nt);
        uint prefix = 0;
        uint length = 0;
        uint longest = 0;
        idNumberT longestID = 0;
        idNumberT mostFrequentID = nb->GetMostFrequent(nt);
        uint mostFrequent = nb->GetFrequency(nt, mostFrequentID);
        idNumberT currentID = 0, prevID = 0;
        uint numUnused = 0;

        nb->IterateStart (nt);
        for (uint i=0; i < nb->GetNumNames(nt); i++) {
            prevID = currentID;
            nb->Iterate (nt, &currentID);
            if (nb->GetFrequency (nt, currentID) == 0) { numUnused++; }
            uint len = strLength(nb->GetName (nt, i)); 
            length += len;
            if (len > longest) {
                longest = len;
                longestID = i;
            }
            if (i > 0) {
                char *s1 = nb->GetName (nt, currentID);
                char *s2 = nb->GetName (nt, prevID);
                prefix += strPrefix (s1,s2);
            }
        }
        printf ("\n%s section:    %d names, %d unused, %d disk bytes\n",
                ntStr[nt],
                nb->GetNumNames(nt),
                numUnused,
                nb->GetNumBytes(nt));
        printf ("Avg length = %.2f bytes, avg prefix = %.2f bytes\n",
                (float) length / (float) numNames,
                (float) prefix / (float) numNames);
        printf ("Longest name: \"%s\" (%u bytes)\n",
                nb->GetName(nt, longestID),
                longest);
        printf ("Most frequent name: \"%s\" (%u times)\n",
                nb->GetName(nt, mostFrequentID),
                mostFrequent);
    }
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// printCompactInfo():
//      Compute and report the amount of wasted space in the game
//      file that could be reduced, but do not actually compact the
//      database.
//
void
printCompactInfo (Index * idx)
{
    IndexEntry iE;
    errorT err;

    err = idx->OpenIndexFile (FMODE_ReadOnly);
    if (err != OK) {
        fileErr (filename, INDEX_SUFFIX, err);
    }
    uint nFullBlocks = 0;
    uint lastBlockBytes = 0;
    uint gameCount = 0;

    for (uint i=0; i <idx->GetNumGames(); i++) {
        idx->ReadEntries (&iE, i, 1);
        if (! iE.GetDeleteFlag()) {
            gameCount++;
            // Can this game fit in the current block?
            if (lastBlockBytes + iE.GetLength() <= GF_BLOCKSIZE) {
                lastBlockBytes += iE.GetLength();
            } else {
                nFullBlocks++;
                lastBlockBytes = iE.GetLength();
            }
        }
    }

    uint oldBytes = 0;
    {
        char temp [1024];
        FILE * pfGfile;
        sprintf (temp, "%s%s", filename, GFILE_SUFFIX);
        pfGfile = fopen (temp, "rb");
        if (pfGfile) {
            fseek (pfGfile, 0, SEEK_END);
            oldBytes = ftell (pfGfile);
            fclose (pfGfile);
        }
    }
    uint newBytes = nFullBlocks * GF_BLOCKSIZE + lastBlockBytes;

    printf("Current size:   %7u games, %8u bytes = %5u Kb\n",
           idx->GetNumGames(), oldBytes, (oldBytes + 512) / 1024);
    printf("Compacted size: %7u games, %8u bytes = %5u Kb\n",
           gameCount, newBytes, (newBytes + 512) / 1024);
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// compactGameFile():
//      Compact the game file of a database to its minimum possible size,
//      by ensuring that the games are in numerical order and that there
//      are no slack bytes between each game except for block boundaries.
//      The gamedata and index files must both be rewritten, so they are
//      renamed first in case of a failure.
//
void
compactGameFile ()
{
    Index * idxOld, * idxNew;
    GFile * gfOld, * gfNew;
    idxOld = new Index;  idxNew = new Index;
    gfOld = new GFile;   gfNew = new GFile;
    char tempName[1024];
    errorT err;

    // Open all files:
    
    strCopy (tempName, filename);
    strAppend (tempName, "_OLD");
    if (renameFile (filename, tempName, INDEX_SUFFIX) != OK) {
        fprintf (stderr, "Unable to rename the index file!\n");
        exit(1);
    }
    if (renameFile (filename, tempName, GFILE_SUFFIX) != OK) {
        renameFile (tempName, filename, INDEX_SUFFIX);
        fprintf (stderr, "Unable to rename the game file!\n");
        exit(1);
    }
    idxOld->SetFileName (tempName);
    idxNew->SetFileName (filename);

    err = idxOld->OpenIndexFile (FMODE_ReadOnly);
    if (err != OK) {
        renameFile (tempName, filename, INDEX_SUFFIX);
        renameFile (tempName, filename, GFILE_SUFFIX);
        fileErr (tempName, INDEX_SUFFIX, err);
    }
    err = idxNew->CreateIndexFile (FMODE_WriteOnly);
    if (err != OK) {
        renameFile (tempName, filename, INDEX_SUFFIX);
        renameFile (tempName, filename, GFILE_SUFFIX);
        fileErr (filename, INDEX_SUFFIX, err);
    }
    err = gfOld->Open (tempName, FMODE_ReadOnly);
    if (err != OK) {
        renameFile (tempName, filename, INDEX_SUFFIX);
        renameFile (tempName, filename, GFILE_SUFFIX);
        fileErr (tempName, GFILE_SUFFIX, err);
    }
    err = gfNew->Create (filename, FMODE_WriteOnly);
    if (err != OK) {
        renameFile (tempName, filename, INDEX_SUFFIX);
        renameFile (tempName, filename, GFILE_SUFFIX);
        fileErr (filename, GFILE_SUFFIX, err);
    }

    idxNew->SetType (idxOld->GetType());
    // Copy each necessary game to the new game file:

    printf ("Compacting the database...\n");
    ProgBar progBar(stdout);
    progBar.Start();

    bool treefileOutOfDate = false;
    ByteBuffer * bbuf = new ByteBuffer;
    bbuf->SetBufferSize (32000);
    gameNumberT newNumGames = 0;
    uint oldNumGames = idxOld->GetNumGames();
    err = OK;
    uint i = 0;
    for (i=0; i < oldNumGames; i++) {
        progBar.Update (i * 100 / oldNumGames);
        IndexEntry ieOld, ieNew;
        idxOld->ReadEntries (&ieOld, i, 1);
        if (ieOld.GetDeleteFlag()) {
            // Game is deleted, do not copy to new file:
            treefileOutOfDate = true;
            continue;
        }
        err = idxNew->AddGame (&newNumGames, &ieNew);
        if (err != OK)  { break; }
        ieNew = ieOld;
        bbuf->Empty();
        err = gfOld->ReadGame (bbuf, ieOld.GetOffset(), ieOld.GetLength());
        if (err != OK)  { break; }
        bbuf->BackToStart();
        uint offset = 0;
        err = gfNew->AddGame (bbuf, &offset);
        ieNew.SetOffset (offset);
        if (err != OK)  { break; }
        err = idxNew->WriteEntries (&ieNew, newNumGames, 1);
        if (err != OK)  { break; }
    }

    idxOld->CloseIndexFile();
    idxNew->CloseIndexFile();
    gfOld->Close();
    gfNew->Close();
    if (err != OK) {
        fprintf (stderr, "ERROR: I/O error!");
        fprintf(stderr, "Restoring original files and aborting.\n");
        removeFile (filename, INDEX_SUFFIX);
        removeFile (filename, GFILE_SUFFIX);
        renameFile (tempName, filename, INDEX_SUFFIX);
        renameFile (tempName, filename, GFILE_SUFFIX);
        exit(1);
    } else {
        if (treefileOutOfDate) { removeFile (filename, TREEFILE_SUFFIX); }
        progBar.Finish();
        printf ("Database was successfully compacted.\n");
        removeFile (tempName, INDEX_SUFFIX);
        removeFile (tempName, GFILE_SUFFIX);
    }
}



//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// main():
//
int
main (int argc, char *argv[])
{
    errorT err;
    progname = argv[0];

    scid_Init();
    
    if (argc != 3) { usage(); }
    
    char *option = argv[1];
    filename = argv[2];
    if (option[0] != '-') { usage(); }

    // Strip the suffix (e.g. ".si", ".sg") of filename if it has one:
    char * lastdot = strrchr (filename, '.');
    if (lastdot) {
        if (!strCompare (lastdot, ".si")  ||  !strCompare (lastdot, ".sg")  ||
            !strCompare (lastdot, ".sn")  ||  !strCompare (lastdot, ".s"))
        {
            *lastdot = 0;
        }
    }
    
    Index * idx = new Index;
    NameBase * nb = new NameBase;
    idx->SetFileName (filename);
    nb->SetFileName (filename);

    ////////////////////////////////////
    if (option[1] == 'p'  ||  option[1] == 'e'  ||
        option[1] == 's'  ||  option[1] == 'r') { 
        // List all player/site names:
        const char *prefixStr = &(option[2]);
        nameT nt = NAME_PLAYER;
        const char * ntStr = "players";
        if (option[1] == 'e') {
            nt = NAME_EVENT;
            ntStr = "events";
        }
        if (option[1] == 's') {
            nt = NAME_SITE;
            ntStr = "sites";
        }
        if (option[1] == 'r') {
            nt = NAME_ROUND;
            ntStr = "rounds";
        }
        err = idx->OpenIndexFile (FMODE_ReadOnly);
        if (err != OK) {
            fileErr (filename, INDEX_SUFFIX, err);
        }
        err = nb->ReadNameFile();
        if (err != OK) {
            fileErr (filename, NAMEBASE_SUFFIX, err);
        }
        uint numNames = nb->GetNumNames(nt);
        uint prefix = 0;
        uint length = 0;
        idNumberT current = 0;
        idNumberT prev = 0;

//        recalcNameFrequencies (nb, idx);
        
        nb->IterateStart (nt);
        for (uint i=0; i < nb->GetNumNames(nt); i++) {
            prev = current;
            nb->Iterate (nt, &current);
            length += strLength (nb->GetName (nt, current));
            if (i > 0) {
                char * s1 = nb->GetName (nt, prev);
                char * s2 = nb->GetName (nt, current);
                prefix += strPrefix (s1,s2);
            }
        }

        printf("Database \"%s\": %d %s.\nAverage length = %.2f bytes, "
               "Average prefix = %.2f bytes\n",
               filename, numNames, ntStr, (float) length / (float) numNames,
               (float) prefix / (float) numNames);
        uint matches = nb->DumpAllNames (nt, prefixStr, stdout);
        printf("[%d names matched the supplied prefix string]\n", matches);

    ////////////////////////////////////
    } else if (option[1] == 'D') {
        printDebugInfo();
        
    ////////////////////////////////////
    } else if (option[1] == 'n') { // list all name information
        printNameInfo (nb, idx);

    ////////////////////////////////////
    } else if (option[1] == 'N') { // compact namebase
        compactNameBase (nb);

    ////////////////////////////////////
    } else if (option[1] == 'd') { // change description for database
        err = idx->OpenIndexFile (FMODE_Both);
        if (err != OK) {
            fileErr (filename, INDEX_SUFFIX, err);
        }
        printf ("Database \"%s\": %s\n", filename, idx->GetDescription());
        char newDesc[1024];
        newDesc[0] = 0;
        printf ("\nEnter a new description: ");
        fgets (newDesc, 1024, stdin);
        // Remove trailling newline chacter:
        newDesc[strlen(newDesc) - 1] = 0;
        idx->SetDescription (newDesc);
        idx->WriteHeader();
        idx->CloseIndexFile();
        printf ("Description changed to: %s\n", idx->GetDescription());

    ////////////////////////////////////
    } else if (option[1] == 'i') { // general information
        err = idx->OpenIndexFile (FMODE_ReadOnly);
        if (err != OK  &&  err != ERROR_FileVersion) {
            fileErr (filename, INDEX_SUFFIX, err);
        }
        printf ("Database \"%s\": %s\n%d games\n",
                filename, idx->GetDescription(), idx->GetNumGames());
        printf ("Version: %u.%u",
                idx->GetVersion() / 100, idx->GetVersion() % 100);
        if (err == ERROR_FileVersion) {
            printf (" (warning: version too old! This is Scid %u.%u).",
                    SCID_VERSION / 100, SCID_VERSION % 100);
        }

        err = nb->OpenNameFile();
        if (err != OK) {
            fileErr (filename, NAMEBASE_SUFFIX, err);
        }
        nb->CloseNameFile();
        printf ("\nNamebase: %d players, %d events, %d sites, %d rounds.\n",
                nb->GetNumNames(NAME_PLAYER), nb->GetNumNames(NAME_EVENT),
                nb->GetNumNames(NAME_SITE), nb->GetNumNames(NAME_ROUND));

    ////////////////////////////////////
    } else if (option[1] == 'l') { // list all vital game information
        err = idx->OpenIndexFile (FMODE_ReadOnly);
        if (err != OK) { fileErr (filename, INDEX_SUFFIX, err); }
        err = nb->ReadNameFile();
        if (err != OK) { fileErr (filename, NAMEBASE_SUFFIX, err); }

        char * displayFormat = displayStr;
        if (option[2] != 0) { displayFormat = &(option[2]); }
        PrintGameList (idx, nb, 1, idx->GetNumGames(),
                       displayFormat, stdout);

    ////////////////////////////////////
    } else if (option[1] == 'c') {  // Compaction statistics
        printCompactInfo (idx);

    ////////////////////////////////////
    } else if (option[1] == 'C') {  // Compact and reorder the database
        compactGameFile ();

    ////////////////////////////////////
    } else if (option[1] == 'S') {  // Sort the database
        err = idx->OpenIndexFile(FMODE_Both);
        if (err != OK) { fileErr (filename, INDEX_SUFFIX, err); }
        err = nb->ReadNameFile();
        if (err != OK) { fileErr (filename, NAMEBASE_SUFFIX, err); }

        if (idx->ParseSortCriteria (&(option[2])) != OK) {            
            printf ("%s\n", idx->ErrorMessage());
            exit(1);
        }

        printf ("Sorting the database...\n");
        idx->ReadEntireFile();
        global_ProgBar->Start();
        // Sort, updating the progress bar every 1000 games:
        idx->Sort (nb, 1000, &(updateProgress), NULL);
        global_ProgBar->Finish();

        printf ("Writing the index file...\n");
        idx->WriteSorted();
        idx->CloseIndexFile();
        
        // A tree file for this database would now be out of date:
        removeFile (filename, TREEFILE_SUFFIX);

        printf ("Database was successfully sorted.\n\n");
        printf ("  Please note: only the index file was changed, so games\n");
        printf ("  are now stored in a scrambled order in the game file.\n");
        printf ("  This makes some database searches MUCH slower, so you ");
        printf ("should type:\n        scidt -C %s\n  to re-compact the ",
                filename);
        printf ("database if you will be using it in searches.\n\n");

    ////////////////////////////////////
    } else { // Not a valid option!
        usage();
    }

    return 0;
}

//////////////////////////////////////////////////////////////////////
//  EOF: scidt.cc
//////////////////////////////////////////////////////////////////////
