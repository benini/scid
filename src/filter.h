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
//    is loaded: 1 means the start position, 2 means the position after
//    Whites first move, etc.

class Filter
{
  private:
    gamenumT FilterSize;     // Number of values in filter.
    gamenumT FilterCount;    // Number of nonzero values in filter.
    gamenumT Capacity;       // Number of values allocated for Data[].
    byte *   Data;           // The actual filter data.

    Filter(const Filter&);
    Filter& operator=(const Filter&);
    void Allocate();
    void Free();
    friend class CompressedFilter;
    
  public:
    Filter (gamenumT size) :Data(NULL) { Init (size); }
    ~Filter() { Free(); }

    void    Init (gamenumT size);
    uint    Size() const { return FilterSize; }
    uint    Count () const { return FilterCount; }
    bool    isWhole () const { return FilterCount == FilterSize; }
    void    Set (gamenumT index, byte value); // Sets the value at index.
    byte    Get (gamenumT index) const;       // Gets the value at index.
    void    Fill (byte value);                // Sets all values.
    void    Append (byte value);              // Appends one value.
    void    SetCapacity (gamenumT size);
};

class HFilter {
    Filter* f_;
    const Filter* mask_;

public:
    explicit HFilter(Filter* f = NULL, const Filter* mask = NULL) : f_(f), mask_(mask) {}

    bool operator! () const { return f_ == NULL; }
    bool operator* () const { return f_ != NULL; }
    bool isWhole() const { return f_->isWhole(); }
    uint count() const {
        uint res = f_->Count();
        if (mask_ == NULL) return res;
        if (res == f_->Size()) return mask_->Count();
        for (uint i=0, n = f_->Size(); i < n; i++) {
            if (f_->Get(i) != 0 && mask_->Get(i) == 0) --res;
        }
        return res;
    }
    byte get(gamenumT index) const {
        byte res = f_->Get(index);
        if (res != 0 && mask_ != NULL) return mask_->Get(index);
        return res;
    }

    void set (gamenumT index, byte value) { return f_->Set(index, value); }
    void fill (byte value) { return f_->Fill(value); }
};



inline void
Filter::Set (uint index, byte value)
{
    ASSERT (index < FilterSize);
	if (Data == NULL){
        if (value == 1)
	        return;
		Allocate();
	}
    if (Data[index] != 0) FilterCount--;
    if (value != 0) FilterCount++;
    Data[index] = value;
}

inline byte
Filter::Get (uint index) const
{
    ASSERT (index < FilterSize);
    byte res = (Data == NULL) ? 1 : Data[index];
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
