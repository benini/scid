//////////////////////////////////////////////////////////////////////
//
//  FILE:       filter.h
//              Filter and CompressedFilter Classes
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    1.4
//
//  Notice:     Copyright (c) 2000  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (shane@cosc.canterbury.ac.nz)
//
//////////////////////////////////////////////////////////////////////


#ifndef SCID_FILTER_H
#define SCID_TREE_H

#include "common.h"
#include "misc.h"

//////////////////////////////////////////////////////////////////////
//
// Filter class:
//
//    Holds the results of a database search: one byte per game,
//    indicating whether that game is included in the filter or not.
//    A value of 0 indicates the game is excluded, or 1-255 indicates
//    the game is included, and what position to show when the game
//    is loaded: 1 means ths start position, 2 means the position after
//    Whites first move, etc.

class Filter
{
  private:

    uint    FilterSize;     // Number of values in filter.
    uint    FilterCount;    // Number of nonzero values in filter.
    uint    Capacity;       // Number of bytes allocated for Data[].
    byte *  Data;           // The actual filter data.

    uint    CachedFilteredCount;  // These members cache the most recent
    uint    CachedIndex;          // filteteredCount to index translation.
    
  public:

    Filter ()           { Init (0); }
    Filter (uint size)  { Init (size); }
    ~Filter ()          { if (Data != NULL) { delete[] Data; } }

    void    Init (uint size);
    uint    Size (void)     { return FilterSize; }
    uint    Count (void)    { return FilterCount; }

    void    Set (uint index, byte value);   // Sets the value at index.
    byte    Get (uint index);               // Gets the value at index.
    void    Fill (byte value);              // Sets all values.
    void    Append (byte value);            // Appends one value.
    uint    IndexToFilteredCount (uint index);
    uint    FilteredCountToIndex (uint filteredCount);
    const byte *  GetData () {
        return (const byte *) Data; }    // Used by CompressedFilter class.
};


inline void
Filter::Set (uint index, byte value)
{
    ASSERT (index < FilterSize);
    CachedFilteredCount = 0;

    // Update the value and count of nonzero values:
    if (Data[index] != 0) { FilterCount--; }
    if (value != 0) { FilterCount++; }
    Data[index] = value;
}

inline byte
Filter::Get (uint index)
{
    ASSERT (index < FilterSize);
    return (Data[index]);
}


//////////////////////////////////////////////////////////////////////
//
// CompressedFilter class:
//    Holds the same data as a filter, in compressed format.
//    Random access to individual values is not possible.
//    A CompressedFilter is created from, or restored to, a regular
//    filter with the methods CompressFrom() and UncompressTo().


class CompressedFilter
{
  private:

    uint    CFilterSize;
    uint    CFilterCount;
    uint    CompressedLength;
    byte *  CompressedData;

  public:

    CompressedFilter (void)     { Init(); }
    ~CompressedFilter (void)    { Clear(); }

    inline void Init();
    inline void Clear();

    uint Size() { return CFilterSize; }
    uint Count() { return CFilterCount; }

    errorT Verify (Filter * filter);

    void CompressFrom (Filter * filter);
    errorT UncompressTo (Filter * filter);

    errorT WriteToFile (FILE * fp);
    errorT ReadFromFile (FILE * fp);
};

inline void
CompressedFilter::Init ()
{
    CFilterSize = 0;
    CFilterCount = 0;
    CompressedLength = 0;
    CompressedData = NULL;
}

inline void
CompressedFilter::Clear ()
{
    if (CompressedData != NULL) { delete[] CompressedData; }
    Init();
}


#endif  // #ifndef SCID_FILTER_H

//////////////////////////////////////////////////////////////////////
//  EOF: filter.h
//////////////////////////////////////////////////////////////////////
