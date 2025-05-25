#!/usr/bin/wish
# conv_marker.tcl:
#     convert scid marker to lichess/chessbase marker
#     [%draw arrow,e3,d5,yellow] -> [%cal Ye3d5]
#     [%draw circle,d5,yellow] -> [%csl Yd5]
#
# Usage: convert_marker.tcl source destinaton
# Example: convert_marker.tcl in.pgn out.pgn
# Copyright (C) 2025 Uwe Klimmek

package require Tcl 8.5
package require Tk  8.5

proc mapColor { color } {
    set col [string toupper [string index $color 0 ]]
    # map unsupported lichess colors to green
    if { ! ($col in [list R B Y G O C]) } { set col G }
    return $col
}

proc convertMarker { source destination } {
    set section start
    set fd [open $source r]
    fconfigure $fd -translation lf
    if { $destination ne "" } {
        set of [open $destination w]
    } else {
        set of stdout
    }
    while { [gets $fd line] >= 0 } {
        switch $section {
            start {
                if { [string index $line 0] eq "\[" } {
                    set section tag
                }
                puts $of $line
            }
            tag {
                if { $line eq "" } {
                    set section moves
                    set moves ""
                } elseif { [string index $line 0] ne "\[" } {
                    puts "Not a pgn tag: $line"
                }
                puts $of $line
            }
            moves {
                append moves "$line\n"
                set result [string range $moves end-8 end]
                foreach i { "1-0" "0-1" "1/2-1/2" "*" } {
                    if { [string first $i $result] >= 0 } {
                        set arrows [regexp -all -inline {(\[\%draw[ \n]*arrow),([a-h][1-8]),([a-h][1-8]),([A-z]*)\]} $moves]
                        set circles [regexp -all -inline {(\[\%draw[ \n]*[\!-z]*),([a-h][1-8]),([A-z]*)\]} $moves]
                        foreach { arrow nop from to color } $arrows {
                            set color [mapColor $color]
                            set ws [string index $arrow 6]
                            set cal "\[%cal$ws$color$from$to]"
                            set moves [string map [list "$arrow" "$cal"] $moves]
                        }
                        foreach { circle nop square color } $circles {
                            set color [mapColor $color]
                            set ws [string index $circle 6]
                            set csl "\[%csl$ws$color$square]"
                            set moves [string map [list "$circle" "$csl"] $moves]
                        }
                        puts $of [string range $moves 0 end-1]
                        set section tag
                        break
                    }
                }
            }
        }
    }
}

set in [lindex $argv 0]
set out [lindex $argv 1]
if { $in eq "" } {
    puts "Usage: conv_marker.tcl inputfile [outputfile]"
    exit
}
convertMarker $in $out
exit
