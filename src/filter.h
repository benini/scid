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
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////


#ifndef SCID_FILTER_H
#define SCID_FILTER_H

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
    const Filter* posMask_;
    void Allocate();
    void Free();
    uint Size() { return FilterSize; }
    friend class CompressedFilter;
    
  public:
    Filter (uint size) :Data(NULL), posMask_(NULL)  { Init (size); }
    ~Filter ()          { Free(); }

    void    Init (uint size);
    uint    Count ();
    void    Set (uint index, byte value);   // Sets the value at index.
    byte    Get (uint index) const;         // Gets the value at index.
    byte    GetNoPosMask (uint index) const { return (Data == NULL) ? 1 : Data[index]; }
    void    Fill (byte value);              // Sets all values.
    void    Append (byte value);            // Appends one value.
    void    Negate ();
    void    SetCapacity (uint size);
    // TODO: void Filter::PositionMask (const char* FEN);
    void    PositionMask (const Filter* f) { posMask_ = f; }
};


inline void
Filter::Set (uint index, byte value)
{
    ASSERT (index < FilterSize);
    if (GetNoPosMask(index) != 0) { FilterCount--; }
    if (value != 0) { FilterCount++; }
	if (Data == NULL){
        if (value == 1)
	        return;
		Allocate();
	}
    Data[index] = value;
}

inline byte
Filter::Get (uint index) const
{
    ASSERT (index < FilterSize);
    byte res = (Data == NULL) ? 1 : Data[index];
    if (res !=0 && posMask_ != NULL) return posMask_->Get(index);
    return res;
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
