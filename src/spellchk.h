//////////////////////////////////////////////////////////////////////
//
//  FILE:       spellchk.h
//              SpellChecker class
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    3.5
//
//  Notice:     Copyright (c) 2001-2003  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////

#ifndef WINCE

#ifndef SCID_SPELLCHK_H
#define SCID_SPELLCHK_H

#include "misc.h"
#include "stralloc.h"
#include "namebase.h"

const uint SPELL_HASH_SIZE = 4096;

struct bioNoteT {
    char * text;
    bioNoteT * next;
};

struct spellingT {
    const char *id;
    const char *data;
};

struct spellCheckNodeT
{
    char * name;        // The possibly incorrect spelling of this name.
    char * correctName; // The correct spelling of this name.
    char * renderName;  // The real (with umlauts, etc) spelling.
    char * comment;     // Extra info, e.g. title/country/elo/date of birth
    spellCheckNodeT * next;
    spellCheckNodeT * alias;
    eloT * eloData;     // History of FIDE Elo ratings for player.
    bioNoteT * bioData; // Biography data.
    bool correction;    // Indicates whether this node is a correction.
    spellCheckNodeT * nextHash;
};

struct presuffixNodeT
{
    char * name;
    char * correctName;
    int    length;
    presuffixNodeT * next;
};

class SpellChecker
{

  private:
    uint CorrectNameCount;
    uint IncorrectNameCount;
    nameT NameType;
    char * ExcludeChars;
    bool EloDataSeen;

    StrAllocator * StrAlloc;

    spellCheckNodeT * Names [256];
    spellCheckNodeT * HashNames [SPELL_HASH_SIZE];
           // HashNames[] gives fast access to correct names only.
    presuffixNodeT * Prefixes;  // Prefix substitutions
    presuffixNodeT * Suffixes;  // Suffix substitutions
    presuffixNodeT * Infixes;   // Infix substitutions

    void Init (void);
    void Destroy (void);

  public:
#ifdef WINCE
  void* operator new(size_t sz) {
    void* m = my_Tcl_Alloc(sz);
    return m;
  }
  void operator delete(void* m) {
    my_Tcl_Free((char*)m);
  }
  void* operator new [] (size_t sz) {
    void* m = my_Tcl_AttemptAlloc(sz);
    return m;
  }

  void operator delete [] (void* m) {
    my_Tcl_Free((char*)m);
  }

#endif  

    SpellChecker ()  { Init(); }
    ~SpellChecker () { Destroy(); }
    void Clear (void);

    void SetExcludeChars (const char * str);
    const char * GetExcludeChars (void) { return ExcludeChars; }

    uint NumCorrectNames (void) { return CorrectNameCount; }
    uint NumIncorrectNames (void) { return IncorrectNameCount; }
    void SetNameType (nameT nt) { NameType = nt; }
    nameT GetNameType (void) { return NameType; }
    bool HasEloData (void) { return EloDataSeen; }

    const char * CorrectPrefix (const char * name, int * offset);
    const char * CorrectSuffix (const char * name, int * offset);
    const char * CorrectInfix (const char * name, int * offset, int * replacedLength);
    const char * Correct (const char * name);
    uint Corrections (const char * name, const char ** corrections,
                      uint maxCorrections);
    void SetRenderName (spellCheckNodeT * node, const char * name);
    const char * RenderName (const char * name);
    const char * GetComment (const char * name);
    const char * GetCommentExact (const char * name);
    errorT ReadSpellCheckFile (const char * filename, bool checkPlayerOrder);
    errorT AddPrefixSuffix (char * str);
    void AddBioData (spellCheckNodeT * node, const char * str);
    const bioNoteT * GetBioData (const char * name);
    void AddEloData (spellCheckNodeT * node, const char * str);
    void SetElo (spellCheckNodeT * node, uint year, uint quarter, eloT elo);
    eloT GetElo (const char * name, dateT date, bool exact);

    static const char * GetTitle (const char * comment);
    static const char * GetLastCountry (const char * comment);
    static eloT GetPeakRating (const char * comment);
    static dateT GetBirthdate (const char * comment);
    static dateT GetDeathdate (const char * comment);

    void Dump (FILE * fp);
};

#endif  // SCID_SPELLCHK_H

#endif // WINCE
//////////////////////////////////////////////////////////////////////
//  EOF: spellchk.h
//////////////////////////////////////////////////////////////////////
