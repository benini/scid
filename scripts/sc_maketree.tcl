#!/bin/sh

# sc_maketree:
#   This program takes a database name as its parameter and executes
#   tree searches for many common positions, then saves the contents
#   of the tree cache to the appropriate file (with a .stc suffix).
#
#   This can take a long time, but saves time when searching for any
#   of the standard positions searched for here. This script is
#   probably most useful as part of a batch job that automatically
#   rebuilds a large database of games periodically.

# The "\" at the end of the comment line below is necessary! It means
#   that the "exec" line is a comment to Tcl but not to /bin/sh.
# The next line restarts using tcscid, the Scid Tcl interpreter: \
exec tcscid "$0" "$@"

# Here is the list of standard positions searched for:

set standardLines {
    {}
    {1.c4}
    {1.c4 c5}
    {1.c4 c5 2.Nf3}
    {1.c4 e5}
    {1.c4 Nf6}
    {1.c4 Nf6 2.Nc3}
    {1.d4}
    {1.d4 d5}
    {1.d4 d5 2.c4}
    {1.d4 d5 2.c4 c6}
    {1.d4 d5 2.c4 c6 3.Nf3}
    {1.d4 d5 2.c4 c6 3.Nf3 Nf6}
    {1.d4 d5 2.c4 c6 3.Nf3 Nf6 4.Nc3}
    {1.d4 d5 2.c4 c6 3.Nf3 Nf6 4.Nc3 dxc4}
    {1.d4 d5 2.c4 c6 3.Nf3 Nf6 4.Nc3 e6}
    {1.d4 d5 2.c4 c6 3.Nf3 Nf6 4.Nc3 e6 5.e3}
    {1.d4 d5 2.c4 e6}
    {1.d4 d5 2.c4 e6 3.Nc3}
    {1.d4 d5 2.c4 e6 3.Nc3 Nf6}
    {1.d4 d5 2.c4 e6 3.Nf3}
    {1.d4 d5 2.c4 dxc4}
    {1.d4 d5 2.c4 dxc4 3.Nf3}
    {1.d4 d5 2.c4 dxc4 3.Nf3 Nf6}
    {1.d4 d5 2.Nf3}
    {1.d4 d5 2.Nf3 Nf6}
    {1.d4 d5 2.Nf3 Nf6 3.c4}
    {1.d4 d6}
    {1.d4 d6 2.c4}
    {1.d4 Nf6}
    {1.d4 Nf6 2.c4}
    {1.d4 Nf6 2.c4 c5}
    {1.d4 Nf6 2.c4 d6}
    {1.d4 Nf6 2.c4 e6}
    {1.d4 Nf6 2.c4 e6 3.Nc3}
    {1.d4 Nf6 2.c4 e6 3.Nc3 Bb4}
    {1.d4 Nf6 2.c4 e6 3.Nf3}
    {1.d4 Nf6 2.c4 g6}
    {1.d4 Nf6 2.c4 g6 3.Nc3}
    {1.d4 Nf6 2.c4 g6 3.Nc3 Bg7}
    {1.d4 Nf6 2.c4 g6 3.Nc3 Bg7 4.e4}
    {1.d4 Nf6 2.c4 g6 3.Nc3 Bg7 4.e4 d6}
    {1.d4 Nf6 2.c4 g6 3.Nc3 Bg7 4.e4 d6 5.Nf3}
    {1.d4 Nf6 2.c4 g6 3.Nc3 Bg7 4.e4 d6 5.Nf3 O-O}
    {1.d4 Nf6 2.c4 g6 3.Nc3 Bg7 4.e4 d6 5.Nf3 O-O 6.Be2}
    {1.d4 Nf6 2.c4 g6 3.Nf3}
    {1.d4 Nf6 2.Bg5}
    {1.d4 Nf6 2.Bg5 Ne4}
    {1.d4 Nf6 2.Nf3}
    {1.d4 Nf6 2.Nf3 e6}
    {1.d4 Nf6 2.Nf3 g6}
    {1.e4}
    {1.e4 c5}
    {1.e4 c5 2.c3}
    {1.e4 c5 2.Nc3}
    {1.e4 c5 2.Nc3 Nc6}
    {1.e4 c5 2.Nf3}
    {1.e4 c5 2.Nf3 d6}
    {1.e4 c5 2.Nf3 d6 3.d4}
    {1.e4 c5 2.Nf3 d6 3.d4 cxd4}
    {1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4}
    {1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6}
    {1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3}
    {1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 a6}
    {1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 e6}
    {1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 g6}
    {1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 Nc6}
    {1.e4 c5 2.Nf3 d6 3.Bb5+}
    {1.e4 c5 2.Nf3 e6}
    {1.e4 c5 2.Nf3 Nc6}
    {1.e4 c5 2.Nf3 Nc6 3.d4}
    {1.e4 c5 2.Nf3 Nc6 3.Bb5}
    {1.e4 c6}
    {1.e4 c6 2.d4}
    {1.e4 c6 2.d4 d5}
    {1.e4 c6 2.d4 d5 3.e5}
    {1.e4 c6 2.d4 d5 3.Nc3}
    {1.e4 c6 2.d4 d5 3.Nd2}
    {1.e4 d5}
    {1.e4 d6}
    {1.e4 d6 2.d4}
    {1.e4 d6 2.d4 Nf6}
    {1.e4 d6 2.d4 Nf6 3.Nc3}
    {1.e4 e5}
    {1.e4 e5 2.Nf3}
    {1.e4 e5 2.Nf3 Nc6}
    {1.e4 e5 2.Nf3 Nc6 3.d4}
    {1.e4 e5 2.Nf3 Nc6 3.Bb5}
    {1.e4 e5 2.Nf3 Nc6 3.Bb5 a6}
    {1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4}
    {1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4 Nf6}
    {1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4 Nf6 5.O-O}
    {1.e4 e5 2.Nf3 Nc6 3.Bc4}
    {1.e4 e5 2.Nf3 Nf6}
    {1.e4 e6}
    {1.e4 e6 2.d4}
    {1.e4 e6 2.d4 d5}
    {1.e4 e6 2.d4 d5 3.Nc3}
    {1.e4 e6 2.d4 d5 3.Nc3 Bb4}
    {1.e4 e6 2.d4 d5 3.Nc3 Nf6}
    {1.e4 e6 2.d4 d5 3.Nd2}
    {1.e4 e6 2.d4 d5 3.Nd2 c5}
    {1.e4 e6 2.d4 d5 3.Nd2 Nf6}
    {1.e4 Nf6}
    {1.e4 Nf6 2.e5}
    {1.e4 Nf6 2.e5 Nd5}
    {1.Nf3}
    {1.Nf3 Nf6}
}


if {$argc < 1} { 
    puts "Usage: sc_maketree database"
    puts "Example: sc_maketree  mybase"
    exit
}

set baseName [ lindex $argv 0 ]
if [catch {set baseNum [sc_base open -readonly $baseName]}] {
    puts "Error: could not open database"
    exit
}

# file delete -- "${baseName}.stc"

puts "Adding common positions to the tree cache:"
puts ""

foreach line $standardLines {
    sc_game new
    if {[llength $line] > 0}  {
        foreach move $line {sc_move addSan $move}
        puts -nonewline "$line: "
    } else {
        puts -nonewline "(Starting position): "
    }
    sc_tree search
    puts "[sc_filter count] games"
}

if {[catch {sc_tree write} result]} {
    puts "Error writing cache file: $result"
} else {
    puts -nonewline "$baseName.stc: [sc_tree positions] positions, "
    puts -nonewline "$result bytes: "
    set pergame [expr double($result) / double([sc_base numGames])]
    puts -nonewline [format "%.2f" $pergame]
    puts " bytes per game"
}

sc_base close $baseNum

