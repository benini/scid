//////////////////////////////////////////////////////////////////////
//
//  FILE:       namebase.h
//              Namebase class
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    3.4
//
//  Notice:     Copyright (c) 2001  Shane Hudson.  all rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////

#ifndef SCID_NAMEBASE_H
#define SCID_NAMEBASE_H

#include "common.h"
#include "date.h"
#include "misc.h"
#include "stralloc.h"
#include "strtree.h"

//////////////////////////////////////////////////////////////////////
//  NameBase:  Constants

// There are three NameBases, one each for player, event and site tags.
//
const nameT
    NAME_PLAYER = 0,  NAME_EVENT = 1,  NAME_SITE = 2, NAME_ROUND = 3,
    NAME_FIRST = 0, NAME_LAST = 3, NAME_INVALID = 99;

const uint NUM_NAME_TYPES = 4;

const char NAME_TYPE_STRING [NUM_NAME_TYPES][8] = {
    "player",
    "event",
    "site",
    "round"
};


// The NAME_MAX_ID[] array stores the maximum number of names allowed
// in a database for each name type.
//
const uint NAME_MAX_ID [NUM_NAME_TYPES] = { 
    1048575,    /* Player names: Maximum of 2^20 -1 = 1,048,575 */
     524287,    /* Event names:  Maximum of 2^19 -1 =   524,287 */
     524287,    /* Site names:   Maximum of 2^19 -1 =   524,287 */
     262143     /* Round names:  Maximum of 2^18 -1 =   262,143 */
};


typedef uint caseFlagT;
const caseFlagT
    CASE_SENSITIVE = 0,  CASE_INSENSITIVE = 1;

const char OLD_NAMEBASE_SUFFIX[] = ".sn";
const char NAMEBASE_SUFFIX[] = ".sn3";

const char NAMEBASE_MAGIC[8] = "Scid.sn";



//////////////////////////////////////////////////////////////////////
//  NameBase:  Data Structures


// Struct nameBaseHeader: one at the start of the nametree file.
//
struct nameBaseHeaderT {
    char        magic[8];    // magic identifier "Scid.sn"
    versionT    version;     // version number. 2 bytes.
    uint        timeStamp;   // 4-byte timestamp.
    idNumberT   numNames [NUM_NAME_TYPES];    // count of names per type;
    // numBytes is a count of the total bytes in all strings for a nametype,
    // including the byte at the start of each string storing its length.
    uint        numBytes [NUM_NAME_TYPES]; 
    uint        maxFrequency [NUM_NAME_TYPES];
};



// Struct nameNode
//
// We extend the nodeT of strtree.h:
struct nameDataT
{
    idNumberT      id;         // a unique ID for this node.
    uint           frequency;  // How many times this string is used.

    // The following fields are not stored in the name file; they are
    // generated as needed and are currently only used for player names.

    eloT           maxElo;     // For estimating a player rating.
    dateT          firstDate;  // Date of oldest occurrence.
    dateT          lastDate;   // Date of most recent occurrence.
    char           country [4]; // Three-letter country code.
    bool           hasPhoto;   // True if this player has a photo.
};

typedef nodeT<nameDataT>  nameNodeT;
typedef nameNodeT * nameNodePtrT;


//////////////////////////////////////////////////////////////////////
//  NameBase:  Class definition

class NameBase
{
  private:
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // NameBase:  Data structures
    fileNameT        Fname;
    nameBaseHeaderT  Header;

    FILE           * FilePtr;

    // NameByID[n] is an array of pointers to the nodes for n.
    nameNodeT **     NameByID [NUM_NAME_TYPES];
    uint             ArraySize [NUM_NAME_TYPES]; // size of NameByID arrays

    StrTree<nameDataT> * Tree [NUM_NAME_TYPES];

    nameNodeT *      MostFrequent [NUM_NAME_TYPES];

    // String Allocator for fast, space-efficient name storage:
    StrAllocator *   StrAlloc;

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //  NameBase:  Private methods

    errorT     WriteHeader ();

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //  Namebase:  Public methods
  public:

    NameBase()  { Init(); }
    ~NameBase() { Clear(); }

    void Init();
    void Clear();

    static bool IsValidNameType (nameT nt) { return (nt < NUM_NAME_TYPES); }
    static nameT NameTypeFromString (const char * str);
    
    void      SetFileName (const char *s) { strcpy (Fname,s); }
    char  *   GetFileName ()          { return Fname; }
    
    idNumberT GetNumNames (nameT n)  { return Header.numNames[n]; }
    uint      GetNumBytes (nameT n)  { return Header.numBytes[n]; }
    
    void      SetTimeStamp (uint ts)    { Header.timeStamp = ts; }
    uint      GetTimeStamp ()           { return Header.timeStamp; }

    errorT    FindExactName      (nameT nt, const char * str, idNumberT * idPtr);
    errorT    AddName            (nameT nt, const char * str, idNumberT * idPtr);

    char *    GetName            (nameT nt, idNumberT id);
    uint      GetFrequency       (nameT nt, idNumberT id);
    void      IncFrequency       (nameT nt, idNumberT id, int increment);
    void      SetFrequency       (nameT nt, idNumberT id, int increment);
    idNumberT GetMostFrequent    (nameT nt);
    void      ZeroAllFrequencies (nameT nt);
    eloT      GetElo (idNumberT id);
    void      AddElo (idNumberT id, eloT elo);
    void      SetElo (idNumberT id, eloT elo);
    dateT     GetFirstDate (idNumberT id);
    dateT     GetLastDate (idNumberT id);
    void      AddDate (idNumberT id, dateT date);
    bool      HasPhoto (idNumberT id);
    void      SetHasPhoto (idNumberT id, bool hasPhoto);

    void      IterateStart (nameT nt) { Tree[nt]->IterateStart(); }
    errorT    Iterate (nameT nt, idNumberT * idPtr)
    {
        ASSERT (IsValidNameType(nt)  &&  idPtr != NULL);
        nameNodeT * node = Tree[nt]->Iterate();
        if (node == NULL) { return ERROR_NotFound; }
        *idPtr = node->data.id;
        return OK;
    }

    uint      GetFirstMatches (nameT nt, const char * str, uint maxMatches,
                               idNumberT * array);
    uint      TreeHeight (nameT nt);

    errorT    OpenNameFile (const char * suffix);
    errorT    OpenNameFile () { return OpenNameFile (NAMEBASE_SUFFIX); }
    errorT    OpenOldNameFile () { return OpenNameFile (OLD_NAMEBASE_SUFFIX); }
    errorT    CloseNameFile ();
    errorT    ReadNameFile (const char * suffix);
    errorT    ReadNameFile () { return ReadNameFile (NAMEBASE_SUFFIX); }
    errorT    ReadOldNameFile () { return ReadNameFile (OLD_NAMEBASE_SUFFIX); }
    errorT    WriteNameFile ();

    errorT    IncArraySize (nameT nt, idNumberT increment);

    uint      DumpAllNames (nameT nt, const char * prefixStr, FILE * f);
};


//////////////////////////////////////////////////////////////////////
//  NameBase:  Public Inline Functions


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Namebase::GetName():
//      Get a name given the ID number.
//
inline char *
NameBase::GetName (nameT nt, idNumberT id)
{
    ASSERT (IsValidNameType(nt));
    if (id >= GetNumNames(nt)) { return ""; }
    return NameByID[nt][id]->name;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Namebase::GetFrequency():
//      Get a frequency given the ID number.
//
inline uint
NameBase::GetFrequency (nameT nt, idNumberT id)
{
    ASSERT (IsValidNameType(nt));
    if (id >= GetNumNames(nt)) { return 0; }
    return NameByID[nt][id]->data.frequency;
}

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Namebase::IncFrequency():
//      Increase the frequency of a name.
//      The parameter "increment" is signed so a negative value can be
//      passed to decrease the frequency.
//
inline void
NameBase::IncFrequency (nameT nt, idNumberT id, int increment)
{
    ASSERT (IsValidNameType(nt));
    if (id >= GetNumNames(nt)) { return; }
    nameNodePtrT node = NameByID[nt][id];
    node->data.frequency += increment;
    if (node->data.frequency > Header.maxFrequency[nt]) {
        Header.maxFrequency[nt] = node->data.frequency;
        MostFrequent[nt] = node;
    }
}

inline void
NameBase::SetFrequency (nameT nt, idNumberT id, int count)
{
    ASSERT (IsValidNameType(nt));
    if (id >= GetNumNames(nt)) { return; }
    nameNodePtrT node = NameByID[nt][id];
    node->data.frequency = count;
    if (node->data.frequency > Header.maxFrequency[nt]) {
        Header.maxFrequency[nt] = node->data.frequency;
        MostFrequent[nt] = node;
    }
}

inline idNumberT
NameBase::GetMostFrequent (nameT nt)
{
    ASSERT (IsValidNameType(nt));
    if (MostFrequent[nt] == NULL) { return 0; }
    else { return MostFrequent[nt]->data.id; }
}

inline void
NameBase::ZeroAllFrequencies (nameT nt)
{
    ASSERT (IsValidNameType(nt));
    for (idNumberT id = 0; id < GetNumNames(nt); id++) {
        (NameByID[nt][id])->data.frequency = 0;
    }
}

inline eloT
NameBase::GetElo (idNumberT id)
{
    if (id >= GetNumNames(NAME_PLAYER)) { return 0; }
    return NameByID[NAME_PLAYER][id]->data.maxElo;
}

inline void
NameBase::AddElo (idNumberT id, eloT elo)
{
    if (id >= GetNumNames(NAME_PLAYER)) { return; }
    nameNodePtrT node = NameByID[NAME_PLAYER][id];
    if (elo > node->data.maxElo) {
        node->data.maxElo = elo;
    }
}

inline void
NameBase::SetElo (idNumberT id, eloT elo)
{
    if (id >= GetNumNames(NAME_PLAYER)) { return; }    
    nameNodePtrT node = NameByID[NAME_PLAYER][id];
    node->data.maxElo = elo;
}

inline dateT
NameBase::GetFirstDate (idNumberT id)
{
    if (id >= GetNumNames(NAME_PLAYER)) { return 0; }
    return NameByID[NAME_PLAYER][id]->data.firstDate;
}

inline dateT
NameBase::GetLastDate (idNumberT id)
{
    if (id >= GetNumNames(NAME_PLAYER)) { return 0; }
    return NameByID[NAME_PLAYER][id]->data.lastDate;
}

inline void
NameBase::AddDate (idNumberT id, dateT date)
{
    if (id >= GetNumNames(NAME_PLAYER)) { return; }
    nameNodePtrT node = NameByID[NAME_PLAYER][id];
    if (date == ZERO_DATE) { return; }
    if (node->data.firstDate == ZERO_DATE  ||  date < node->data.firstDate) {
        node->data.firstDate = date;
    }
    if (date > node->data.lastDate) {
        node->data.lastDate = date;
    }
}

inline bool
NameBase::HasPhoto (idNumberT id)
{
    if (id >= GetNumNames(NAME_PLAYER)) { return false; }
    return NameByID[NAME_PLAYER][id]->data.hasPhoto;
}

inline void
NameBase::SetHasPhoto (idNumberT id, bool hasPhoto)
{
    if (id >= GetNumNames(NAME_PLAYER)) { return; }
    NameByID[NAME_PLAYER][id]->data.hasPhoto = hasPhoto;
}

#endif  // #ifdef SCID_NAMEBASE_H

//////////////////////////////////////////////////////////////////////
//  EOF: namebase.h
//////////////////////////////////////////////////////////////////////

