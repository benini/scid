//////////////////////////////////////////////////////////////////////
//
//  FILE:       index.h
//              Index File Class
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    3.2
//
//  Notice:     Copyright (c) 1999-2002  Shane Hudson.  all rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////


#ifndef SCID_INDEX_H
#define SCID_INDEX_H

#include "common.h"
#include "error.h"
#include "matsig.h"
#include "namebase.h"
#include "date.h"
#include "mfile.h"

//////////////////////////////////////////////////////////////////////
//  Index:  Constants

const char         INDEX_SUFFIX[]     = ".si3";
const char         OLD_INDEX_SUFFIX[] = ".si";
const gameNumberT  MAX_GAMES         = 4000000;  // max. no. of games in file
const char         INDEX_MAGIC[8]    = "Scid.si";

// Descriptions can be up to 107 bytes long.
const uint  SCID_DESC_LENGTH = 107;

const uint  MAX_ELO = 4000;   // Since we store Elo Ratings in 12 bits
                              // each in the index file.

// Struct indexHeader: one at the start of the index file.
//
struct indexHeaderT {
    char        magic[9];    // 8-byte identifier for Scid index files.
    versionT    version;     // version number. 2 bytes.
    uint        baseType;    // Type, e.g. tournament, theory, etc.
    gameNumberT numGames;    // number of games in file.
    gameNumberT autoLoad;    // game number to autoload: 0=1st, 1=none, 2=1st,
                             //   3=2nd, 4=3rd, etc. Note that 0=1st for
                             //   backwards compatibility: bases with this
                             //   unset will load game 1.
    // description is a fixed-length string describing the database.
    char        description [SCID_DESC_LENGTH + 1];
};

// Header on-disk size: magic=8, version=2, numGames=3, baseType=4, autoLoad=3
// Description length = 111 bytes including trailing '\0'.
// So total is 128 bytes for the whole header.
const uint  INDEX_HEADER_SIZE = 8 + 2 + 3 + 4 + 3 + SCID_DESC_LENGTH + 1;
const uint  OLD_INDEX_HEADER_SIZE = INDEX_HEADER_SIZE;

// INDEX_MaxSortCriteria is the maximum number of fields allowed in
// a sorting criteria list.
const uint  INDEX_MaxSortCriteria = 16;

// HPSIG_SIZE = size of HomePawnData array in an IndexEntry.
// It is nine bytes: the first byte contains the number of valid entries
// in the array, and the next 8 bytes contain up to 16 half-byte entries.

const uint HPSIG_SIZE = 9;


// IndexEntry Flag types:

#define  IDX_NUM_FLAGS 16

#define  IDX_FLAG_START         0   // Game has own start position.
#define  IDX_FLAG_PROMO         1   // Game contains promotion(s).
#define  IDX_FLAG_UPROMO        2   // Game contains promotion(s).
#define  IDX_FLAG_DELETE        3   // Game marked for deletion.
#define  IDX_FLAG_WHITE_OP      4   // White openings flag.
#define  IDX_FLAG_BLACK_OP      5   // Black openings flag.
#define  IDX_FLAG_MIDDLEGAME    6   // Middlegames flag.
#define  IDX_FLAG_ENDGAME       7   // Endgames flag.
#define  IDX_FLAG_NOVELTY       8   // Novelty flag.
#define  IDX_FLAG_PAWN          9   // Pawn structure flag.
#define  IDX_FLAG_TACTICS      10   // Tactics flag.
#define  IDX_FLAG_KSIDE        11   // Kingside play flag.
#define  IDX_FLAG_QSIDE        12   // Queenside play flag.
#define  IDX_FLAG_BRILLIANCY   13   // Brilliancy or good play.
#define  IDX_FLAG_BLUNDER      14   // Blunder or bad play.
#define  IDX_FLAG_USER         15   // User-defined flag.

#define  IDX_MASK_START         (1 << IDX_FLAG_START)
#define  IDX_MASK_PROMO         (1 << IDX_FLAG_PROMO)
#define  IDX_MASK_UPROMO        (1 << IDX_FLAG_UPROMO)
#define  IDX_MASK_DELETE        (1 << IDX_FLAG_DELETE)
#define  IDX_MASK_WHITE_OP      (1 << IDX_FLAG_WHITE_OP)
#define  IDX_MASK_BLACK_OP      (1 << IDX_FLAG_BLACK_OP)
#define  IDX_MASK_MIDDLEGAME    (1 << IDX_FLAG_MIDDLEGAME)
#define  IDX_MASK_ENDGAME       (1 << IDX_FLAG_ENDGAME)
#define  IDX_MASK_NOVELTY       (1 << IDX_FLAG_NOVELTY)
#define  IDX_MASK_PAWN          (1 << IDX_FLAG_PAWN)
#define  IDX_MASK_TACTICS       (1 << IDX_FLAG_TACTICS)
#define  IDX_MASK_KSIDE         (1 << IDX_FLAG_KSIDE)
#define  IDX_MASK_QSIDE         (1 << IDX_FLAG_QSIDE)
#define  IDX_MASK_BRILLIANCY    (1 << IDX_FLAG_BRILLIANCY)
#define  IDX_MASK_BLUNDER       (1 << IDX_FLAG_BLUNDER)
#define  IDX_MASK_USER          (1 << IDX_FLAG_USER)

// Bitmask functions for index entry decoding:
inline byte   u32_high_8 (uint x)   { return (byte)(x >> 24); }
inline uint   u32_low_24 (uint x)   { return (x & ((1 << 24) - 1)); }
inline uint   u32_high_12 (uint x)  { return (x >> 20); }
inline uint   u32_low_20 (uint x)   { return (x & 0xFFFFF); }
inline byte   u16_high_4 (ushort x) { return (byte)(x >> 12); }
inline ushort u16_low_12 (ushort x) { return (x & ((1 << 12) - 1)); }
inline byte   u8_high_4 (byte x)    { return (x >> 4); }
inline byte   u8_low_4 (byte x)     { return (x & 0x0F); }
inline byte   u8_high_3 (byte x) { return (x >> 5); }
inline byte   u8_low_5 (byte x)     { return (x & 31); }

inline uint u32_set_high_8 (uint u, byte x)
    { return (u32_low_24(u) | (((uint)x) << 24)); }
inline uint u32_set_low_24 (uint u, uint x)
    { return ((u & 0xFF000000) | x); }
inline uint u32_set_high_12 (uint u, uint x)
    { return (u32_low_20(u) | (x << 20)); }
inline uint u32_set_low_20 (uint u, uint x)
    { return ((u & 0xFFF00000U) | (x & 0xFFFFF)); }
inline ushort u16_set_high_4 (ushort u, byte x)
    { return (u16_low_12(u) | (((ushort)x) << 12)); }
inline ushort u16_set_low_12 (ushort u, ushort x)
    { return ((u & 0xF000U) | x); }


//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Class IndexEntry: one of these per game in the index file.
//
//    It contains more than just the location of the game data in the main
//    data file.  For fast searching, it also store some other important
//    values: players, event, site, date, result, eco, gamelength.
//
//    It takes 48 bytes, assuming sizeof(uint) == 4 and sizeof(ushort) == 2.

class IndexEntry
{
  private:

    uint           Offset;     // Start of gamefile record for this game.
    ushort         Length;     // Size of gamefile record for this game.

    // Name ID values are packed into 12 bytes, saving 8 bytes over the
    // simpler method of just storing each as a 4-byte idNumberT.

    ushort       WhiteID_Low;       // Lower 16 bits of White ID.
    ushort       BlackID_Low;       // Lower 16 bits of Black ID.
    ushort       EventID_Low;       // Lower 16 bits of Site.
    ushort       SiteID_Low;        // Lower 16 bits of Site ID.
    ushort       RoundID_Low;       // Lower 16 bits of Round ID.
    byte         WhiteBlack_High;   // High bits of White, Black.
    byte         EventSiteRnd_High; // High bits of Event, Site, Round.
    ecoT         EcoCode;     // ECO code
    dateT        Dates;       // Date and EventDate fields.
    eloT         WhiteElo;
    eloT         BlackElo;
    matSigT      FinalMatSig; // material of the final position in the game,
                              // and the StoredLineCode in the top 8 bits.
    ushort       Flags;
    ushort       VarCounts;   // Counters for comments, variations, etc.
                              // VarCounts also stores the result.
    ushort       NumHalfMoves;
    byte         HomePawnData [HPSIG_SIZE];  // homePawnSig data.
    byte         Padding;     // Padding out to 48 bytes.

  public:

    IndexEntry() {}
    ~IndexEntry() {}
    void Init();

    errorT Verify (NameBase * nb);

    // Get() methods:

    inline uint GetLength ()  { return Length; }
    inline uint GetOffset ()  { return Offset; }

    inline idNumberT GetWhite ();
    inline idNumberT GetBlack ();
    inline idNumberT GetEvent ();
    inline idNumberT GetSite ();
    inline idNumberT GetRound ();

    inline char * GetWhiteName (NameBase * nb);
    inline char * GetBlackName (NameBase * nb);
    inline char * GetEventName (NameBase * nb);
    inline char * GetSiteName (NameBase * nb);
    inline char * GetRoundName (NameBase * nb);

    inline dateT   GetDate ()     { return u32_low_20(Dates); }
    inline uint    GetYear ()     { return date_GetYear (GetDate()); }
    inline uint    GetMonth ()    { return date_GetMonth (GetDate()); }
    inline uint    GetDay ()      { return date_GetDay (GetDate()); }
    dateT          GetEventDate ();
    inline resultT GetResult ()   { return (VarCounts >> 12); }
    inline eloT    GetWhiteElo () { return u16_low_12(WhiteElo); }
    inline eloT    GetBlackElo () { return u16_low_12(BlackElo); }
    inline byte    GetWhiteRatingType () { return u16_high_4 (WhiteElo); }
    inline byte    GetBlackRatingType () { return u16_high_4 (BlackElo); }
    inline ecoT    GetEcoCode ()  { return EcoCode; }
    inline ushort  GetNumHalfMoves () { return NumHalfMoves; }

    inline uint GetFlags ()          { return Flags; }
    inline bool GetFlag (uint mask)  { return Flags & mask; }
    inline bool GetStartFlag ()      { return Flags & IDX_MASK_START; }
    inline bool GetPromotionsFlag () { return Flags & IDX_MASK_PROMO; }
    inline bool GetUnderPromoFlag()  { return Flags & IDX_MASK_UPROMO; }
    inline bool GetCommentsFlag ()   { return (GetCommentCount() > 0); }
    inline bool GetVariationsFlag () { return (GetVariationCount() > 0); }
    inline bool GetNagsFlag ()       { return (GetNagCount() > 0); }
    inline bool GetDeleteFlag ()     { return Flags & IDX_MASK_DELETE; }
    inline bool GetWhiteOpFlag ()    { return Flags & IDX_MASK_WHITE_OP; }
    inline bool GetBlackOpFlag ()    { return Flags & IDX_MASK_BLACK_OP; }
    inline bool GetMiddlegameFlag () { return Flags & IDX_MASK_MIDDLEGAME; }
    inline bool GetEndgameFlag ()    { return Flags & IDX_MASK_ENDGAME; }
    inline bool GetNoveltyFlag ()    { return Flags & IDX_MASK_NOVELTY; }
    inline bool GetPawnStructFlag () { return Flags & IDX_MASK_PAWN; }
    inline bool GetTacticsFlag ()    { return Flags & IDX_MASK_TACTICS; }
    inline bool GetKingsideFlag ()   { return Flags & IDX_MASK_KSIDE; }
    inline bool GetQueensideFlag ()  { return Flags & IDX_MASK_QSIDE; }
    inline bool GetBrilliancyFlag () { return Flags & IDX_MASK_BRILLIANCY; }
    inline bool GetBlunderFlag ()    { return Flags & IDX_MASK_BLUNDER; }
    inline bool GetUserFlag ()       { return Flags & IDX_MASK_USER; }

    static uint   CharToFlag (char ch);
    uint   GetFlagStr (char * str, const char * flags);
    void   SetFlagStr (const char * flags);

    inline static uint EncodeCount (uint x) {
        if (x <= 10) { return x; }
        if (x <= 12) { return 10; }
        if (x <= 17) { return 11; }  // 11 indicates 15 (13-17)
        if (x <= 24) { return 12; }  // 12 indicates 20 (18-24)
        if (x <= 34) { return 13; }  // 13 indicates 30 (25-34)
        if (x <= 44) { return 14; }  // 14 indicates 40 (35-44)
        return 15;                   // 15 indicates 50 or more
    }
    inline static uint DecodeCount (uint x) {
        static uint countCodes[16] = {0,1,2,3,4,5,6,7,8,9,10,15,20,30,40,50};
        return countCodes[x & 15]; 
    }
    inline uint GetVariationCount () { return DecodeCount(VarCounts & 15); }
    inline uint GetCommentCount ()   { return DecodeCount((VarCounts >> 4) & 15); }
    inline uint GetNagCount ()       { return DecodeCount((VarCounts >> 8) & 15); }

    inline matSigT GetFinalMatSig ()   { return u32_low_24 (FinalMatSig); }
    inline byte    GetStoredLineCode () { return u32_high_8 (FinalMatSig); }
    inline byte *  GetHomePawnData ()  { return HomePawnData; }

    // Set() Methods:

    inline void SetOffset (uint offset) { Offset = offset; }
    inline void SetLength (uint length) { Length = length; }

    inline void SetWhite (idNumberT id);
    inline void SetBlack (idNumberT id);
    inline void SetEvent (idNumberT id);
    inline void SetSite  (idNumberT id);
    inline void SetRound (idNumberT id);

    inline void SetDate  (dateT date)   {
        Dates = u32_set_low_20 (Dates, date);
    }
    void   SetEventDate (dateT date);
    bool   ValidEventDate (dateT date);

    inline void SetResult (resultT res) {
        VarCounts = (VarCounts & 0x0FFF) | (((ushort)res) << 12);
    }
    inline void SetWhiteElo (eloT elo)  {
        WhiteElo = u16_set_low_12(WhiteElo, elo);
    }
    inline void SetBlackElo (eloT elo)  {
        BlackElo = u16_set_low_12 (BlackElo, elo);
    }
    inline void SetWhiteRatingType (byte b) {
        WhiteElo = u16_set_high_4 (WhiteElo, b);
    }
    inline void SetBlackRatingType (byte b) {
        BlackElo = u16_set_high_4 (BlackElo, b);
    }
    inline void SetEcoCode (ecoT eco)   { EcoCode = eco; }
    inline void SetNumHalfMoves (ushort b)  { NumHalfMoves = b; }

    inline void SetFlags (uint flags) { Flags = flags; }
    inline void SetFlag (uint flagMask, bool b) {
        if (b) { Flags |= flagMask; } else { Flags &= ~flagMask; }
    }

    inline void SetStartFlag (bool b)      { SetFlag (IDX_MASK_START, b); }
    inline void SetPromotionsFlag (bool b) { SetFlag (IDX_MASK_PROMO, b); }
    inline void SetUnderPromoFlag (bool b) { SetFlag (IDX_MASK_UPROMO, b); }
    inline void SetDeleteFlag (bool b)     { SetFlag (IDX_MASK_DELETE, b); }
    inline void SetUserFlag (bool b)       { SetFlag (IDX_MASK_USER, b); }
    inline void SetBlackOpFlag (bool b)    { SetFlag (IDX_MASK_BLACK_OP, b); }
    inline void SetMiddlegameFlag (bool b) { SetFlag (IDX_MASK_MIDDLEGAME, b); }
    inline void SetEndgameFlag (bool b)    { SetFlag (IDX_MASK_ENDGAME, b); }
    inline void SetNoveltyFlag (bool b)    { SetFlag (IDX_MASK_NOVELTY, b); }
    inline void SetPawnStructFlag (bool b) { SetFlag (IDX_MASK_PAWN, b); }
    inline void SetTacticsFlag (bool b)    { SetFlag (IDX_MASK_TACTICS, b); }
    inline void SetKingsideFlag (bool b)   { SetFlag (IDX_MASK_KSIDE, b); }
    inline void SetQueensideFlag (bool b)  { SetFlag (IDX_MASK_QSIDE, b); }
    inline void SetBrilliancyFlag (bool b) { SetFlag (IDX_MASK_BRILLIANCY, b); }
    inline void SetBlunderFlag (bool b)    { SetFlag (IDX_MASK_BLUNDER, b); }
    inline void SetWhiteOpFlag (bool b)    { SetFlag (IDX_MASK_WHITE_OP, b); }

    inline void SetVariationCount (uint x) {
        VarCounts = (VarCounts & 0xFFF0U) | EncodeCount(x);
    }
    inline void SetCommentCount (uint x) {
        VarCounts = (VarCounts & 0xFF0FU) | (EncodeCount(x) << 4);
    }
    inline void SetNagCount (uint x) {
        VarCounts = (VarCounts & 0xF0FFU) | (EncodeCount(x) << 8);
    }

    inline void SetFinalMatSig (matSigT ms) {
        FinalMatSig = u32_set_low_24 (FinalMatSig, ms);
    }
    inline void SetStoredLineCode (byte b)    {
        FinalMatSig = u32_set_high_8 (FinalMatSig, b);
    }
    inline void SetHomePawnData (byte * hpData) {
        for (uint i=0; i < HPSIG_SIZE; i++) { HomePawnData[i] = hpData[i]; }
    }

    // Other IndexEntry methods:

    errorT Read (MFile * fp, versionT version);
    errorT Write (MFile * fp, versionT version);
    errorT ReadOld (MFile * fp);
    errorT WriteOld (MFile * fp);

    void PrintGameInfo (char * outStr,
                        gameNumberT gnFiltered, gameNumberT gnReal,
                        NameBase * nb, const char * format);

    int Compare (IndexEntry * ie, int * fields, NameBase * nb);
};

inline char *
IndexEntry::GetWhiteName (NameBase * nb)
{ return nb->GetName (NAME_PLAYER, GetWhite()); }

inline char *
IndexEntry::GetBlackName (NameBase * nb)
{ return nb->GetName (NAME_PLAYER, GetBlack()); }

inline char *
IndexEntry::GetEventName (NameBase * nb)
{ return nb->GetName (NAME_EVENT, GetEvent()); }

inline char *
IndexEntry::GetSiteName (NameBase * nb)
{ return nb->GetName (NAME_SITE, GetSite()); }

inline char *
IndexEntry::GetRoundName (NameBase * nb)
{ return nb->GetName (NAME_ROUND, GetRound()); }


// Name Get and Set routines:
//
//   WhiteID and BlackID are 20-bit values, EventID and SiteID are
//   19-bit values, and RoundID is an 18-bit value.
//
//   WhiteID high 4 bits = bits 4-7 of WhiteBlack_High.
//   BlackID high 4 bits = bits 0-3 of WhiteBlack_High.
//   EventID high 3 bits = bits 5-7 of EventSiteRnd_high.
//   SiteID  high 3 bits = bits 2-4 of EventSiteRnd_high.
//   RoundID high 2 bits = bits 0-1 of EventSiteRnd_high.

inline idNumberT
IndexEntry::GetWhite ()
{
    idNumberT id = (idNumberT) WhiteBlack_High;
    id = id >> 4;  // High 4 bits = bits 4-7 of WhiteBlack_High.
    id <<= 16;
    id |= (idNumberT) WhiteID_Low;
    return id;
}

inline void
IndexEntry::SetWhite (idNumberT id)
{
    WhiteID_Low = id & 0xFFFF;
    WhiteBlack_High = WhiteBlack_High & 0x0F;   // Clear bits 4-7.
    WhiteBlack_High |= ((id >> 16) << 4);       // Set bits 4-7.
}

inline idNumberT
IndexEntry::GetBlack ()
{
    idNumberT id = (idNumberT) WhiteBlack_High;
    id = id & 0xF;   // High 4 bits = bits 0-3 of WhiteBlack_High.
    id <<= 16;
    id |= (idNumberT) BlackID_Low;
    return id;
}

inline void
IndexEntry::SetBlack (idNumberT id)
{
    BlackID_Low = id & 0xFFFF;
    WhiteBlack_High = WhiteBlack_High & 0xF0;   // Clear bits 0-3.
    WhiteBlack_High |= (id >> 16);              // Set bits 0-3.
}

inline idNumberT
IndexEntry::GetEvent ()
{
    uint id = (idNumberT) EventSiteRnd_High;
    id >>= 5;  // High 3 bits = bits 5-7 of EventSiteRnd_High.
    id <<= 16;
    id |= (idNumberT) EventID_Low;
    return id;
}

inline void
IndexEntry::SetEvent (idNumberT id)
{
    EventID_Low = id & 0xFFFF;
    // Clear bits 2-4 of EventSiteRnd_high: 31 = 00011111 binary.
    EventSiteRnd_High = EventSiteRnd_High & 31;
    EventSiteRnd_High |= ((id >> 16) << 5);
}

inline idNumberT
IndexEntry::GetSite ()
{
    uint id = (idNumberT) EventSiteRnd_High;
    id = (id >> 2) & 7;  // High 3 bits = bits 2-5 of EventSiteRnd_High.
    id <<= 16;
    id |= (idNumberT) SiteID_Low;
    return id;
}

inline void
IndexEntry::SetSite (idNumberT id)
{
    SiteID_Low = id & 0xFFFF;
    // Clear bits 2-4 of EventSiteRnd_high: 227 = 11100011 binary.
    EventSiteRnd_High = EventSiteRnd_High & 227;
    EventSiteRnd_High |= ((id >> 16) << 2);
}

inline idNumberT
IndexEntry::GetRound ()
{
    uint id = (idNumberT) EventSiteRnd_High;
    id &= 3;   // High 2 bits = bits 0-1 of EventSiteRnd_High.
    id <<= 16;
    id |= (idNumberT) RoundID_Low;
    return id;
}

inline void
IndexEntry::SetRound (idNumberT id)
{
    RoundID_Low = id & 0xFFFF;
    // Clear bits 0-1 of EventSiteRnd_high: 252 = 11111100 binary.
    EventSiteRnd_High = EventSiteRnd_High & 252;
    EventSiteRnd_High |= (id >> 16);
}



// Total on-disk size per index entry: currently 46 bytes.
const uint  INDEX_ENTRY_SIZE = 46;
const uint  OLD_INDEX_ENTRY_SIZE = 41;

typedef IndexEntry * IndexEntryPtr;


// INDEX_ENTRY_CHUNKSIZE is the number of index entries allocated as
// one chunk. INDEX_ENTRY_CHUNKSHIFT is the base-2 logarithm of this.
// The SHIFT and MASK constants are used to avoid mods and divs.
//
const uint INDEX_ENTRY_CHUNKSHIFT = 10;   // 2^10 => chunks of 1024 entries.
const uint INDEX_ENTRY_CHUNKSIZE  = (1 << INDEX_ENTRY_CHUNKSHIFT);
const uint INDEX_ENTRY_CHUNKMASK = (INDEX_ENTRY_CHUNKSIZE - 1);



//////////////////////////////////////////////////////////////////////
//  Index:  Class Definition

class Index
{
 private:
    //----------------------------------
    //  Index:  Data structures
    //----------------------------------

    fileNameT    Fname;
    indexHeaderT Header;        // Num games in file, baseType etc.

    MFile      * FilePtr;       // filehandle for opened index file.
    uint         FilePos;       // current byte position in index file.
    fileModeT    FileMode;      // Mode: e.g. FILE_WRITEONLY

    bool          InMemory;     // If nonzero, whole file is in memory
    IndexEntry ** Entries;      // A two-level array of the entire index.

    int          Dirty;         // If true, Header needs rewriting to disk.

    char *       ErrorMsg;

    uint         IndexEntrySize;

    // Used for sorting:
    uint *        EntriesHeap;
    int           SortCriteria [INDEX_MaxSortCriteria];

    void         FreeEntries();
    uint NumChunksRequired() {
        return 1 + (GetNumGames() >> INDEX_ENTRY_CHUNKSHIFT);
    }

    //----------------------------------
    //  Index:  Public Functions
    //----------------------------------
 public:

    Index()     { Init(); }
    ~Index()    { Clear(); }

    void        Init ();
    void        Clear ();
    void        InitEntries (IndexEntry * ie, uint count);

    // CalcIndexEntrySize: useful if the index entry size needs to grow in
    // a future version of Scid. Currently, all versions use same size.
    inline void CalcIndexEntrySize (void) {
        if (Header.version < 300) {
            IndexEntrySize = OLD_INDEX_ENTRY_SIZE;
        } else {
            IndexEntrySize = INDEX_ENTRY_SIZE;
        }
    }

    char *      ErrorMessage() { return ErrorMsg; }
    void        SetFileName (const char *s)   { strCopy (Fname, s); }
    char  *     GetFileName ()          { return Fname; }

    void        SetType (uint t)   { Header.baseType = t; }
    uint        GetType ()         { return Header.baseType; }

    versionT    GetVersion ()             { return Header.version; }
    void        SetVersion (versionT v)   { Header.version = v; }

    void        SetDescription (const char *s);
    const char * GetDescription ()  { return Header.description; }

    void        SetAutoLoad (gameNumberT gnum) { Header.autoLoad = gnum + 1; }
    gameNumberT GetAutoLoad () {
        return ((Header.autoLoad == 0) ? 1 : (Header.autoLoad - 1));
    }
    
    errorT      Open (fileModeT, bool old);
    errorT      OpenIndexFile (fileModeT m) { return Open (m, false); }
    errorT      OpenOldIndexFile (fileModeT m) { return Open (m, true); }
    errorT      CreateIndexFile (fileModeT);
    errorT      CreateMemoryOnly ();
    errorT      WriteHeader ();
    errorT      CloseIndexFile ();
    errorT      SetReadOnly ();

    errorT      ReadEntries (IndexEntry * ie, gameNumberT start, uint count);
    errorT      WriteEntries (IndexEntry * ie, gameNumberT start, uint count);
    errorT      ReadEntireFile (int reportFrequency,
                                void (*progressFn)(void * data,
                                                   uint progress,
                                                   uint total),
                                void * progressData);
    inline errorT ReadEntireFile () {
        return ReadEntireFile (0, NULL, NULL);
    }

    uint        VerifyFile (NameBase * nb);
    bool        AllInMemory() { return InMemory; }

    inline IndexEntry * FetchEntry (gameNumberT g);

    gameNumberT GetNumGames ()     { return Header.numGames; }
    errorT      AddGame (gameNumberT * g, IndexEntry * ie);

    // Sorting-related methods:
  private:
     void       Sort_AdjustHeap (int heapSize, int root, NameBase * nb);
     errorT     VerifySort (void);
  public:
     errorT     Sort (NameBase * nb, int reportFrequency,
                      void (*progressFn)(void * data,
                                         uint progress,
                                         uint total),
                      void * progressData);

     errorT     WriteSorted (int reportFrequency,
                             void (*progressFn)(void * data,
                                                uint progress,
                                                uint total),
                             void * progressData);
     errorT     WriteSorted () { return WriteSorted (0, NULL, NULL); }

     errorT     ParseSortCriteria (const char * inputStr);
};


inline IndexEntry *
Index::FetchEntry (gameNumberT g)
{
    // Returns a ptr to a particular entry, or NULL if file is not
    // all in memory.

    if (g >= Header.numGames) { ASSERT(0); return NULL; }
    if (InMemory == 0) { ReadEntireFile(); }
    IndexEntry * chunk = Entries[g >> INDEX_ENTRY_CHUNKSHIFT];
    return &(chunk[g & INDEX_ENTRY_CHUNKMASK]);
}

#endif  // #ifdef SCID_INDEX_H

//////////////////////////////////////////////////////////////////////
//  EOF: index.h
//////////////////////////////////////////////////////////////////////

