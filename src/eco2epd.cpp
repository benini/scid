//////////////////////////////////////////////////////////////////////
//
//  FILE:       eco2book.cpp
//              eco2book: Converts Scid Eco file from Text to Book format.
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    2.0
//
//  Notice:     Copyright (c) 1999  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (shane@cosc.canterbury.ac.nz) 
//
//////////////////////////////////////////////////////////////////////

#include "common.h"
#include "error.h"
#include "position.h"
#include "pbook.h"
#include "misc.h"

#include <stdio.h>
#include <ctype.h>
#include <string.h>

#ifndef WIN32
#include <strings.h>
#endif

// Globals for input file line count and program name:

static int lineCount = 1;
static char * progname;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// corrupt():
//      Report corrupt data error at the current line and exit.
//
void
corrupt ()
{
    fprintf (stderr, "ERROR: Corrupt data at line %d\n", lineCount);
    exit (1);
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// getC():
//      Get a character from the file "fp". Increments lineCount if
//      a newline is seen. This function expects to return a valid
//      character, so reaching the end of the file here indicates
//      corrupt data.
//
int
getC (FILE * fp)
{
    int c = getc(fp);
    if (c == '\n') { lineCount++; }
    if (c == EOF) { corrupt(); }
    return c;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// usage():
//   Prints the usage message and exits the program.
//
void
usage ()
{
    fprintf (stderr,
             "%s converts a Scid ECO code file from text to Book (%s) format.\n",
             progname, PBOOK_SUFFIX);
    fprintf (stderr, "Usage: %s [options] eco-file [scid-book-file]\n", progname);
    fprintf (stderr, "Example:  %s scid.eco\n", progname);
    fprintf (stderr, "    will convert scid.eco to a file named scid%s\n",
             PBOOK_SUFFIX);
    fprintf (stderr, "Options:  -b: basic ECO codes (no extensions).\n");
    fprintf (stderr, "          -n: ECO codes only (no opening names).\n");
    fprintf (stderr, "          -v: verbose summary (default).\n");
    fprintf (stderr, "          -q: quiet, no summary.\n");
    exit (1);
}


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// main():
//    Program function for eco2book. Parses the text file, adds all chess
//    opening lines found, and writes the Book-format file.
//
int
main (int argc, char * argv[])
{
    char textStr [1000];
    char tempStr [1000];
    int c, done = 0;
    errorT err;
    Position * pos;
    FILE * in;
    PBook * book;

    // Command line options:

    int basicCodes = 0;
    int omitNames = 0;
    int verbose = 1;

    progname = argv[0];
    
    scid_Init();
    book = new PBook;
    pos = new Position;
    if (argc < 2) { usage(); }

    // Parse options:
    int argsLeft = argc - 1;
    char ** nextArg = argv + 1;

    while (argsLeft > 0  &&  nextArg[0][0] == '-') {
        char * s = *nextArg;
        s++;
        while (*s) {
            switch (*s) {
                case 'b':    // option "-b": Basic ECO codes only
                    basicCodes = 1; break;
                case 'n':    // option "-n": No Names, only ECO codes
                    omitNames = 1; break;
                case 'v':    // verbose output
                    verbose = 1; break;
                case 'q':    // quiet output
                    verbose = 0; break;
                default: usage();
            }
            s++;
        }
        argsLeft--;
        nextArg++;
    }
    if (argsLeft != 1  &&  argsLeft != 2) { usage(); }

    char * textFileName = nextArg[0];
    fileNameT bookFileName;

    // Make book file name from textFileName if it is not provided:
    if (argsLeft == 1) {
        strCopy (bookFileName, textFileName);
        strTrimSuffix (bookFileName, '.');
    } else {
        strCopy (bookFileName, nextArg[1]);
        strTrimSuffix (bookFileName, '.');
    }
    strAppend (bookFileName, PBOOK_SUFFIX);

    in = fopen (textFileName, "r");
    if (!in) {
        fprintf (stderr, "Error opening file: %s\n", textFileName);
        fprintf (stderr, "Check that the file exists and is readable.\n");
        exit (1);
    }

    // Loop to read in and add all positions:

    while (!done) {
        // Find the next ECO code:

        while (1) {
            c = getc (in);
            if (c == EOF) { done = 1; break; }
            if (c == '\n') { lineCount++; }
            if (c >= 'A'  &&  c <= 'E') { break; }
            // Skip over comment lines:
            if (c == '#') { fgets (tempStr, 1000, in); lineCount++; }
        }
        if (done) { break; }

        // Read in the rest of the ECO code:

        tempStr[0] = c;
        c = getC (in); if (!isdigit(c)) { corrupt(); }
        tempStr[1] = c;
        c = getC (in); if (!isdigit(c)) { corrupt(); }
        tempStr[2] = c; tempStr[3] = 0;

        // Check for optional extra part of code, e.g. "A00a1":

        c=getc(in);
        if (c >= 'a'  &&  c <= 'z') {
            tempStr[3] = c; tempStr[4] = 0;
            c = getc(in);
            if (c >= '1'  &&  c <= '4') {
                tempStr[4] = c; tempStr[5] = 0;
            }
        }

        // Convert to a basic code if -b option is set:

        if (basicCodes) {
            tempStr[3] = 0;
        }

        // Now put the ecoCode in the textStr and read the text in quotes:

        ecoT ecoCode = eco_FromString (tempStr);
        ecoStringT ecoStr;
        eco_ToExtendedString (ecoCode, ecoStr);
        sprintf (textStr, "eco %s", ecoStr);
        if (!omitNames) { strcat (textStr, "  "); }
        
        char * s = textStr;  // Set s to end of text string:
        while (*s) { s++; }

        // Find the start of the text:
        while ((c = getC(in)) != '"') {}

        // Read the text:
        while ((c = getC(in)) != '"') {
            // Only add the text to the string if omitNames is not set:
            if (!omitNames) { *s++ = (char) c; }
        }
        *s++ = '\n';
        *s = 0;  // add end-of-string to the text string

        // Now read in the position:
        s = tempStr;
        while ((c = getC(in)) != '*') {
            *s++ = (char) c;
        }
        *s = 0;
        pos->StdStart();
        err = pos->ReadLine (tempStr);
        if (err != OK) {
            pos->DumpBoard(stdout);
            corrupt();
        }
        const char * oldStr;
        if (book->Find (pos, &oldStr) == OK) {
            fprintf (stderr, "Previous ECO: %s\n", oldStr);
        }
        if (book->Insert (pos, textStr) != OK) {
            fprintf (stderr, "ERROR: position already exists!\n");
            pos->DumpBoard(stderr);
            corrupt();
        }
    }

    book->SetFileName (bookFileName);
    if (book->WriteFile() != OK) {
        fprintf (stderr, "Error writing Scid book file: %s\n", bookFileName);
        fprintf (stderr, "Check that you have write access for this file.\n");
        exit(1);
    }
    if (verbose) {
        fprintf (stderr, "Successfully wrote %u positions to %s\n",
                 book->Size(), bookFileName);
        fprintf (stderr, "Bytes in book file for positions: %7u ",
                 book->NumPositionBytes());
        fprintf (stderr, " (%.2f per position)\n",
                 (float) book->NumPositionBytes() / (float) book->Size());
        fprintf (stderr, "Bytes in book file for comments:  %7u ",
                 book->NumCommentBytes());
        fprintf (stderr, " (%.2f per position)\n",
                 (float) book->NumCommentBytes() / (float) book->Size());
        //book->DumpStats (stderr);
    }
    return 0;
}

//////////////////////////////////////////////////////////////////////
//  EOF: eco2book.cpp
//////////////////////////////////////////////////////////////////////

