#!/bin/sh
# \
exec tcscid "$0" "$@"

proc usage {} {
  puts stderr {Usage: sc_tree [-eco <eco-file>] [-pgn <output-file>] <database> [moves...]}
  puts stderr {Example: sc_tree -pgn out.pgn mygames 1.e4 e6}
  exit 1
}

set ecoFile ""
set pgnFile ""

if {[llength $argv] == 0} { usage }
while {[lindex $argv 0] == "-eco"  ||  [lindex $argv 0] == "-pgn"} {
  if {[llength $argv] < 3} { usage }
  if {[lindex $argv 0] == "-eco"} {
    set ecoFile [lindex $argv 1]
  } else {
    set pgnFile [lindex $argv 1]
  }
  set argv [lrange $argv 2 end]
}

set base [lindex $argv 0]
set argv [lrange $argv 1 end]
if {[llength $argv] > 0  && [catch {eval sc_move addSan $argv} err]} {
  puts stderr "Error in move list: $err"
  exit 1
}

if {$ecoFile != ""} {
  if {[catch {sc_eco read $ecoFile} err]} {
    puts stderr "Unable to read ECO file: $ecoFile"
    exit 1
  }
}

if {[catch {sc_base open -fast -readonly $base} err]} {
  puts stderr "Error opening database \"$base\": $err"
  exit 1
}

puts [sc_tree search]

if {$pgnFile != ""} {
  puts ""
  if {[file exists $pgnFile]} {
    puts "Output file \"[file tail $pgnFile]\" already exists! It was not altered."
  } else {
    sc_base export filter PGN $pgnFile -comments 1 -variations 1
    puts "Wrote [sc_filter count] games to $pgnFile"
  }
}

sc_base close
