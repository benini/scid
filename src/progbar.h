//////////////////////////////////////////////////////////////////////
//
//  FILE:       progbar.h
//              Text-based progress bar for Scid utilities
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    3.2
//
//  Notice:     Copyright (c) 2001-2002 Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////

#include <stdio.h>

const uint PROGBAR_WIDTH = 50;

class ProgBar
{
  private:

    uint PercentShown;
    uint PercentDone;
    FILE * FilePtr;
    char ProgressChar;

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
    ProgBar (FILE * fp) {
        FilePtr = fp;
        setbuf (FilePtr, NULL);  // Make the file unbuffered.
        PercentDone = PercentShown = 0;
        ProgressChar = '.';
    }

    ~ProgBar() {}

    inline void Start (void);
    inline void Update (uint percent);
    inline void Finish (void);
};

inline void
ProgBar::Start (void)
{
    fputs ("  [0% 10   20   30   40   50   60   70   80   90  100]\n  [",
           FilePtr);
    PercentDone = PercentShown = 0;
}

inline void
ProgBar::Update (uint percent)
{
    // Internally, PercentDone is in range 0..50 since the progress
    // bar is 50 characters wide.
    PercentDone = percent * PROGBAR_WIDTH / 100;
    if (PercentDone > PROGBAR_WIDTH) { PercentDone = PROGBAR_WIDTH; }
    while (PercentDone > PercentShown) {
        putc ('.', FilePtr);
        PercentShown++;
    }
}

inline void
ProgBar::Finish (void)
{
    PercentDone = PROGBAR_WIDTH;
    while (PercentShown < PROGBAR_WIDTH) {
        putc (ProgressChar, FilePtr);
        PercentShown++;
    }
    fputs ("]\n", FilePtr);
}

//////////////////////////////////////////////////////////////////////
//  EOF: progbar.h
//////////////////////////////////////////////////////////////////////

