#!/bin/sh

# sc_upgrade:
# Upgrades all the Scid databases specified on the command line
# from version 2 to version 3.

# The "\" at the end of the comment line below is necessary! It means
# that the "exec" line is a comment to Tcl but not to /bin/sh.
# The next line restarts using tcscid, the Scid Tcl interpreter: \
exec tcscid "$0" "$@"

set arg 0
set argc [llength $argv]

while {$arg < $argc} {
  set baseName [file rootname [ lindex $argv $arg ] ]
  puts "Upgrading: $baseName..."
  set err [catch {sc_base upgrade $baseName} result]
  if {$err} {
    puts "Unable to upgrade $baseName: $result"
  } else {
    puts "$baseName was upgraded."
  }
  incr arg
}
