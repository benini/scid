//////////////////////////////////////////////////////////////////////
//
//  FILE:       stored.cpp
//              StoredLine class methods
//
//  Part of:    Scid (Shane's Chess Information Database)
//  Version:    3.0
//
//  Notice:     Copyright (c) 2001  Shane Hudson.  All rights reserved.
//
//  Author:     Shane Hudson (sgh@users.sourceforge.net)
//
//////////////////////////////////////////////////////////////////////

#include "stored.h"
#include "pgnparse.h"
#include "timer.h"


// Stored line codes: used to speed up tree searches.

// The basic idea is: keep a fixed dictionary of popular opening lines where
// move order is significant (e.g. 1.d4 e6 2.e4 is NOT equal to 1.e4 e6 2.d4).
// For each game, the longest sequence of initial moves found in the
// dictionary is stored in the index file, as an integer value.

// When tree-searching for a position, each stored line is searched
// first and if an exact match is found for one (and it has a further
// move), all games with that stored line code can be found as matches
// without decoding.
// Furthermore, if we detect that a line cannot possibly lead to a match
// because of its end material value or pawn configuration, all games with
// that stored line code can be excluded and skipped without decoding.


static const uint nStoredLines = 254;
static Game ** storedLineGames = NULL;

static const char * storedLineText [nStoredLines + 1] = {
    "",  // index zero is unused
    "1.b3",
    "1.c4",
    "1.c4 c5",
    "1.c4 c5 2.Nf3",
    "1.c4 e5",
    "1.c4 e5 2.Nc3",
    "1.c4 e5 2.Nc3 Nf6",
    "1.c4 e6",
    "1.c4 e6 2.Nf3",
    "1.c4 g6",
    "1.c4 Nf6",
    "1.c4 Nf6 2.Nc3",
    "1.c4 Nf6 2.Nc3 e6",
    "1.c4 Nf6 2.Nc3 g6",
    "1.d4",
    "1.d4 d5",
    "1.d4 d5 2.c4",
    "1.d4 d5 2.c4 c6",
    "1.d4 d5 2.c4 c6 3.Nc3",
    "1.d4 d5 2.c4 c6 3.Nc3 Nf6",
    "1.d4 d5 2.c4 c6 3.Nc3 Nf6 4.Nf3",
    "1.d4 d5 2.c4 c6 3.Nf3",
    "1.d4 d5 2.c4 c6 3.Nf3 Nf6",
    "1.d4 d5 2.c4 c6 3.Nf3 Nf6 4.Nc3",
    "1.d4 d5 2.c4 c6 3.Nf3 Nf6 4.Nc3 e6",
    "1.d4 d5 2.c4 dxc4",
    "1.d4 d5 2.c4 dxc4 3.Nf3",
    "1.d4 d5 2.c4 dxc4 3.Nf3 Nf6",
    "1.d4 d5 2.c4 e6",
    "1.d4 d5 2.c4 e6 3.Nc3",
    "1.d4 d5 2.c4 e6 3.Nc3 c6",
    "1.d4 d5 2.c4 e6 3.Nc3 Nf6",
    "1.d4 d5 2.c4 e6 3.Nf3",
    "1.d4 d5 2.Nf3",
    "1.d4 d5 2.Nf3 Nf6",
    "1.d4 d5 2.Nf3 Nf6 3.c4",
    "1.d4 d5 2.Nf3 Nf6 3.c4 c6",
    "1.d4 d5 2.Nf3 Nf6 3.c4 e6",
    "1.d4 d6",
    "1.d4 d6 2.Nf3",
    "1.d4 e6",
    "1.d4 e6 2.c4",
    "1.d4 e6 2.c4 Nf6",
    "1.d4 f5",
    "1.d4 f5 2.g3 Nf6 3.Bg2",
    "1.d4 g6",
    "1.d4 g6 2.c4 Bg7",
    "1.d4 Nf6",
    "1.d4 Nf6 2.Bg5",
    "1.d4 Nf6 2.Bg5 Ne4",
    "1.d4 Nf6 2.c4",
    "1.d4 Nf6 2.c4 c5",
    "1.d4 Nf6 2.c4 c5 3.d5",
    "1.d4 Nf6 2.c4 c5 3.d5 b5",
    "1.d4 Nf6 2.c4 c5 3.d5 b5 4.cxb5 a6",
    "1.d4 Nf6 2.c4 e6 3.g3",
    "1.d4 Nf6 2.c4 e6 3.g3 d5",
    "1.d4 Nf6 2.c4 e6 3.Nc3",
    "1.d4 Nf6 2.c4 e6 3.Nc3 Bb4",
    "1.d4 Nf6 2.c4 e6 3.Nc3 Bb4 4.e3",
    "1.d4 Nf6 2.c4 e6 3.Nc3 Bb4 4.e3 O-O",
    "1.d4 Nf6 2.c4 e6 3.Nc3 Bb4 4.Qc2",
    "1.d4 Nf6 2.c4 e6 3.Nc3 Bb4 4.Qc2 O-O",
    "1.d4 Nf6 2.c4 e6 3.Nc3 Bb4 4.Qc2 O-O 5.a3 Bxc3+ 6.Qxc3",
    "1.d4 Nf6 2.c4 e6 3.Nc3 d5",
    "1.d4 Nf6 2.c4 e6 3.Nf3",
    "1.d4 Nf6 2.c4 e6 3.Nf3 b6",
    "1.d4 Nf6 2.c4 e6 3.Nf3 b6 4.a3",
    "1.d4 Nf6 2.c4 e6 3.Nf3 b6 4.g3",
    "1.d4 Nf6 2.c4 e6 3.Nf3 b6 4.g3 Ba6",
    "1.d4 Nf6 2.c4 e6 3.Nf3 Bb4+",
    "1.d4 Nf6 2.c4 e6 3.Nf3 d5",
    "1.d4 Nf6 2.c4 e6 3.Nf3 d5 4.Nc3",
    "1.d4 Nf6 2.c4 g6",
    "1.d4 Nf6 2.c4 g6 3.Nc3 Bg7",
    "1.d4 Nf6 2.c4 g6 3.Nc3 Bg7 4.e4",
    "1.d4 Nf6 2.c4 g6 3.Nc3 Bg7 4.e4 d6",
    "1.d4 Nf6 2.c4 g6 3.Nc3 Bg7 4.e4 d6 5.Be2 O-O",
    "1.d4 Nf6 2.c4 g6 3.Nc3 Bg7 4.e4 d6 5.Be2 O-O 6.Nf3",
    "1.d4 Nf6 2.c4 g6 3.Nc3 Bg7 4.e4 d6 5.f3",
    "1.d4 Nf6 2.c4 g6 3.Nc3 Bg7 4.e4 d6 5.f3 O-O",
    "1.d4 Nf6 2.c4 g6 3.Nc3 Bg7 4.e4 d6 5.f3 O-O 6.Be3",
    "1.d4 Nf6 2.c4 g6 3.Nc3 Bg7 4.e4 d6 5.Nf3 O-O",
    "1.d4 Nf6 2.c4 g6 3.Nc3 Bg7 4.e4 d6 5.Nf3 O-O 6.Be2",
    "1.d4 Nf6 2.c4 g6 3.Nc3 Bg7 4.e4 d6 5.Nf3 O-O 6.Be2 e5",
    "1.d4 Nf6 2.c4 g6 3.Nc3 Bg7 4.e4 d6 5.Nf3 O-O 6.Be2 e5 7.O-O",
    "1.d4 Nf6 2.c4 g6 3.Nc3 Bg7 4.e4 d6 5.Nf3 O-O 6.Be2 e5 7.O-O Nc6 8.d5 Ne7",
    "1.d4 Nf6 2.c4 g6 3.Nc3 d5",
    "1.d4 Nf6 2.c4 g6 3.Nc3 d5 4.Nf3",
    "1.d4 Nf6 2.c4 g6 3.Nc3 d5 4.cxd5 Nxd5",
    "1.d4 Nf6 2.c4 g6 3.Nc3 d5 4.cxd5 Nxd5 5.e4 Nxc3 6.bxc3 Bg7",
    "1.d4 Nf6 2.Nf3",
    "1.d4 Nf6 2.Nf3 c5",
    "1.d4 Nf6 2.Nf3 d5",
    "1.d4 Nf6 2.Nf3 e6",
    "1.d4 Nf6 2.Nf3 e6 3.Bg5",
    "1.d4 Nf6 2.Nf3 e6 3.c4",
    "1.d4 Nf6 2.Nf3 g6",
    "1.d4 Nf6 2.Nf3 g6 3.Bg5",
    "1.d4 Nf6 2.Nf3 g6 3.c4",
    "1.d4 Nf6 2.Nf3 g6 3.c4 Bg7",
    "1.d4 Nf6 2.Nf3 g6 3.c4 Bg7 4.Nc3",
    "1.d4 Nf6 2.Nf3 g6 3.c4 Bg7 4.Nc3 O-O",
    "1.d4 Nf6 2.Nf3 g6 3.g3",
    "1.d4 Nf6 2.Nf3 g6 3.g3 Bg7 4.Bg2",
    "1.e4",
    "1.e4 c5",
    "1.e4 c5 2.c3",
    "1.e4 c5 2.c3 d5 3.exd5 Qxd5 4.d4",
    "1.e4 c5 2.c3 d5 3.exd5 Qxd5 4.d4 Nf6",
    "1.e4 c5 2.c3 Nf6 3.e5 Nd5",
    "1.e4 c5 2.c3 Nf6 3.e5 Nd5 4.d4 cxd4",
    "1.e4 c5 2.d4 cxd4",
    "1.e4 c5 2.Nc3",
    "1.e4 c5 2.Nc3 Nc6",
    "1.e4 c5 2.Nc3 Nc6 3.g3",
    "1.e4 c5 2.Nc3 Nc6 3.g3 g6",
    "1.e4 c5 2.Nc3 Nc6 3.g3 g6 4.Bg2 Bg7",
    "1.e4 c5 2.Nc3 Nc6 3.g3 g6 4.Bg2 Bg7 5.d3",
    "1.e4 c5 2.Nf3",
    "1.e4 c5 2.Nf3 d6",
    "1.e4 c5 2.Nf3 d6 3.Bb5+",
    "1.e4 c5 2.Nf3 d6 3.d4",
    "1.e4 c5 2.Nf3 d6 3.d4 cxd4",
    "1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4",
    "1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6",
    "1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3",
    "1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 a6",
    "1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 a6 6.Bc4",
    "1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 a6 6.Be2",
    "1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 a6 6.Be3",
    "1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 a6 6.Bg5",
    "1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 a6 6.Bg5 e6",
    "1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 g6",
    "1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 g6 6.Be3 Bg7 7.f3",
    "1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 g6 6.Be3 Bg7 7.f3 O-O",
    "1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 Nc6",
    "1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 Nc6 6.Bg5",
    "1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 Nc6 6.Bg5 e6 7.Qd2",
    "1.e4 c5 2.Nf3 e6",
    "1.e4 c5 2.Nf3 e6 3.d3",
    "1.e4 c5 2.Nf3 e6 3.d4 cxd4 4.Nxd4",
    "1.e4 c5 2.Nf3 e6 3.d4 cxd4 4.Nxd4 a6",
    "1.e4 c5 2.Nf3 e6 3.d4 cxd4 4.Nxd4 a6 5.Bd3",
    "1.e4 c5 2.Nf3 e6 3.d4 cxd4 4.Nxd4 Nc6",
    "1.e4 c5 2.Nf3 e6 3.d4 cxd4 4.Nxd4 Nc6 5.Nc3",
    "1.e4 c5 2.Nf3 e6 3.d4 cxd4 4.Nxd4 Nc6 5.Nc3 Qc7",
    "1.e4 c5 2.Nf3 e6 3.d4 cxd4 4.Nxd4 Nf6",
    "1.e4 c5 2.Nf3 e6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3",
    "1.e4 c5 2.Nf3 e6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 d6",
    "1.e4 c5 2.Nf3 Nc6",
    "1.e4 c5 2.Nf3 Nc6 3.Bb5",
    "1.e4 c5 2.Nf3 Nc6 3.Bb5 g6",
    "1.e4 c5 2.Nf3 Nc6 3.d4 cxd4 4.Nxd4",
    "1.e4 c5 2.Nf3 Nc6 3.d4 cxd4 4.Nxd4 e5",
    "1.e4 c5 2.Nf3 Nc6 3.d4 cxd4 4.Nxd4 g6",
    "1.e4 c5 2.Nf3 Nc6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3",
    "1.e4 c5 2.Nf3 Nc6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 d6",
    "1.e4 c5 2.Nf3 Nc6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 d6 6.Bg5",
    "1.e4 c5 2.Nf3 Nc6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 e5",
    "1.e4 c5 2.Nf3 Nc6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 e5 6.Ndb5 d6",
    "1.e4 c5 2.Nf3 Nc6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 e5 6.Ndb5 d6 7.Bg5 a6",
    "1.e4 c5 2.Nf3 Nc6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 e5 6.Ndb5 d6 7.Bg5 a6 8.Na3 b5",
    "1.e4 c6",
    "1.e4 c6 2.d4 d5",
    "1.e4 c6 2.d4 d5 3.e5",
    "1.e4 c6 2.d4 d5 3.e5 Bf5",
    "1.e4 c6 2.d4 d5 3.exd5 cxd5",
    "1.e4 c6 2.d4 d5 3.exd5 cxd5 4.c4 Nf6 5.Nc3",
    "1.e4 c6 2.d4 d5 3.Nc3",
    "1.e4 c6 2.d4 d5 3.Nc3 dxe4 4.Nxe4",
    "1.e4 c6 2.d4 d5 3.Nd2 dxe4 4.Nxe4",
    "1.e4 d5 2.exd5 Nf6",
    "1.e4 d5 2.exd5 Qxd5",
    "1.e4 d5 2.exd5 Qxd5 3.Nc3",
    "1.e4 d5 2.exd5 Qxd5 3.Nc3 Qa5",
    "1.e4 d6",
    "1.e4 d6 2.d4",
    "1.e4 d6 2.d4 Nf6",
    "1.e4 d6 2.d4 Nf6 3.Nc3",
    "1.e4 d6 2.d4 Nf6 3.Nc3 g6",
    "1.e4 d6 2.d4 Nf6 3.Nc3 g6 4.f4 Bg7 5.Nf3",
    "1.e4 d6 2.d4 Nf6 3.Nc3 g6 4.Nf3 Bg7",
    "1.e4 e5",
    "1.e4 e5 2.f4",
    "1.e4 e5 2.Nc3",
    "1.e4 e5 2.Nf3",
    "1.e4 e5 2.Nf3 Nc6",
    "1.e4 e5 2.Nf3 Nc6 3.Bb5",
    "1.e4 e5 2.Nf3 Nc6 3.Bb5 a6",
    "1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4",
    "1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4 Nf6",
    "1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4 Nf6 5.O-O",
    "1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4 Nf6 5.O-O b5 6.Bb3",
    "1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4 Nf6 5.O-O Be7",
    "1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4 Nf6 5.O-O Be7 6.Re1 b5 7.Bb3 d6",
    "1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4 Nf6 5.O-O Be7 6.Re1 b5 7.Bb3 d6 8.c3 O-O",
    "1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4 Nf6 5.O-O Be7 6.Re1 b5 7.Bb3 d6 8.c3 O-O 9.h3",
    "1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4 Nf6 5.O-O Be7 6.Re1 b5 7.Bb3 d6 8.c3 O-O 9.h3 Na5 10.Bc2 c5 11.d4",
    "1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4 Nf6 5.O-O Be7 6.Re1 b5 7.Bb3 O-O",
    "1.e4 e5 2.Nf3 Nc6 3.Bb5 Nf6",
    "1.e4 e5 2.Nf3 Nc6 3.Bc4",
    "1.e4 e5 2.Nf3 Nc6 3.Bc4 Nf6",
    "1.e4 e5 2.Nf3 Nc6 3.d4 exd4",
    "1.e4 e5 2.Nf3 Nc6 3.d4 exd4 4.Nxd4",
    "1.e4 e5 2.Nf3 Nc6 3.Nc3",
    "1.e4 e5 2.Nf3 Nc6 3.Nc3 Nf6",
    "1.e4 e5 2.Nf3 Nf6",
    "1.e4 e5 2.Nf3 Nf6 3.Nxe5 d6",
    "1.e4 e6",
    "1.e4 e6 2.d3",
    "1.e4 e6 2.d4",
    "1.e4 e6 2.d4 d5",
    "1.e4 e6 2.d4 d5 3.e5 c5",
    "1.e4 e6 2.d4 d5 3.e5 c5 4.c3",
    "1.e4 e6 2.d4 d5 3.Nc3",
    "1.e4 e6 2.d4 d5 3.Nc3 Bb4",
    "1.e4 e6 2.d4 d5 3.Nc3 Bb4 4.e5",
    "1.e4 e6 2.d4 d5 3.Nc3 Bb4 4.e5 c5",
    "1.e4 e6 2.d4 d5 3.Nc3 Bb4 4.e5 c5 5.a3 Bxc3+ 6.bxc3",
    "1.e4 e6 2.d4 d5 3.Nc3 Nf6",
    "1.e4 e6 2.d4 d5 3.Nc3 Nf6 4.Bg5",
    "1.e4 e6 2.d4 d5 3.Nd2",
    "1.e4 e6 2.d4 d5 3.Nd2 c5",
    "1.e4 e6 2.d4 d5 3.Nd2 Nf6",
    "1.e4 e6 2.d4 d5 3.Nd2 Nf6 4.e5 Nfd7",
    "1.e4 e6 2.d4 d5 3.Nd2 Nf6 4.e5 Nfd7 5.Bd3 c5 6.c3 Nc6 7.Ne2",
    "1.e4 g6",
    "1.e4 g6 2.d4",
    "1.e4 g6 2.d4 Bg7",
    "1.e4 g6 2.d4 Bg7 3.Nc3",
    "1.e4 g6 2.d4 Bg7 3.Nc3 d6",
    "1.e4 Nf6",
    "1.e4 Nf6 2.e5 Nd5",
    "1.e4 Nf6 2.e5 Nd5 3.d4 d6",
    "1.e4 Nf6 2.e5 Nd5 3.d4 d6 4.Nf3",
    "1.f4",
    "1.g3",
    "1.Nf3",
    "1.Nf3 c5",
    "1.Nf3 c5 2.c4",
    "1.Nf3 d5",
    "1.Nf3 d5 2.c4",
    "1.Nf3 d5 2.d4",
    "1.Nf3 d5 2.g3",
    "1.Nf3 g6",
    "1.Nf3 Nf6",
    "1.Nf3 Nf6 2.c4",
    "1.Nf3 Nf6 2.c4 c5",
    "1.Nf3 Nf6 2.c4 e6",
    "1.Nf3 Nf6 2.c4 g6",
    "1.Nf3 Nf6 2.c4 g6 3.Nc3",
    "1.Nf3 Nf6 2.g3",
    "1.Nf3 Nf6 2.g3 g6"
};

uint
StoredLine::Count (void)
{
    return nStoredLines;
}

const char *
StoredLine::GetText (uint code)
{
    if (code > nStoredLines) { return ""; }
    return storedLineText [code];
}


void
StoredLine::Init (void)
{
    ASSERT (storedLineGames == NULL);
    Timer t;
    storedLineGames = new Game * [nStoredLines + 1];
    PgnParser parser;
    char buf [256];

    for (uint i = 1; i <= nStoredLines; i++) {
        // Compile with the following loop to test that every stored
        // line is unique:
#if 0
        for (uint j=i+1; j <= nStoredLines; j++) {
            if (strEqual (storedLineText[i], storedLineText[j])) {
                fprintf (stderr, "Error: stored lines equal: %u, %u\n", i, j);
                exit (1);
            }
        }
#endif
        storedLineGames[i] = new Game;
        parser.Reset (storedLineText[i]);
        parser.SetEndOfInputWarnings (false);
        parser.SetResultWarnings (false);
        if (parser.ParseMoves (storedLineGames[i], buf, 256) != OK) {
            // This should never happen:
            fprintf (stderr, "Fatal error reading stored line %u: %s\n",
                     i, storedLineText[i]);
            exit (1);
        }
    }

#if 0
    printf ("Init: %u stored lines, %u ms\n", nStoredLines, t.MilliSecs());
#endif
}

Game *
StoredLine::GetGame (uint code)
{
    if (storedLineGames == NULL) { Init(); }
    if (code < 1  ||  code > nStoredLines) { return NULL; }

    return storedLineGames [code];
}

//////////////////////////////////////////////////////////////////////
//  EOF:    stored.cpp
//////////////////////////////////////////////////////////////////////
