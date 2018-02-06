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
    ~CompressedFilter (void) {
        if (CompressedData != NULL) delete[] CompressedData;
    }

    inline void Clear();

    uint Size() const { return CFilterSize; }
    uint Count() { return CFilterCount; }

    errorT Verify (Filter * filter);

    void CompressFrom (Filter * filter);
    errorT UncompressTo(Filter * filter) const;

  private:
    CompressedFilter(const CompressedFilter&);
    void operator=(const CompressedFilter&);

    inline void Init();
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
