#!/bin/sh

# sc_addmove:
#   Tcl script to add moves to a game in a Scid chess game database.
#   Usage: sc_addmove database-name game-number moves...

#  This is Tcl code.
# The "\" at the end of the comment line below is necessary! It means
#   that the "exec" line is a comment to Tcl but not to /bin/sh.
# The next line restarts using tcscid, the Scid Tcl interpreter: \
exec tcscid "$0" "$@"

if {$argc < 3} { 
    puts "Usage: sc_addmove database gameNumber move(s)"
    puts "Example: sc_addmove  mybase  1  Nxe4 Bxe4"
    exit
}

set baseName [ lindex $argv 0 ]
set gameNumber [ lindex $argv 1 ]
set moveStr [ join [lrange $argv 2 end ] ]

# Open the database and load the specified game:

if [catch { sc_base open $baseName }] {
    puts "Error: could not open the Scid database: $baseName"
    exit
}
if [catch { sc_game load $gameNumber }] {
    puts "Error: could not load game number $gameNumber"
    exit 1
}

# Try to add each move to the end of the game::

sc_move end

foreach i [lrange $argv 2 end] {
    if [catch { sc_move addSan $i }] {
        puts "Error: could not add the move: $i"
        exit 1
    }
}

# Save the game and close the database:

if [catch { sc_game save $gameNumber }] {
    puts "Error: could not save the game"
    exit 1
}
if [catch {sc_base close}] {
    puts "Error: could not close the game file"
    exit 1
}

puts "Moves successfully added."
