#!/usr/bin/env tclsh
# conv_marker.tcl:
#     convert scid marker to lichess/chessbase marker
#     [%draw arrow,e3,d5,yellow] -> [%cal Ye3d5]
#     [%draw circle,d5,yellow] -> [%csl Yd5]
#
# Usage: convert_marker.tcl source destinaton
# Example: convert_marker.tcl in.pgn out.pgn
# Copyright (C) 2025 Uwe Klimmek

package require Tcl 8.6

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
    set of [expr {$destination eq "" ? "stdout" : [open $destination w] }]
    while { [gets $fd line] >= 0 } {
        switch $section {
            start {
                if {[string match {\[*} $line]} {
                    set section tag
                }
                puts $of $line
            }
            tag {
                if { $line eq "" } {
                    set section moves
                    set moves ""
                } elseif { ![string match {\[*} $line] } {
                    puts "Not a pgn tag: $line"
                }
                puts $of $line
            }
            moves {
                append moves "$line\n"
                if {[regexp {(^|\s)(1-0|0-1|1/2-1/2|\*)$} $line] && ([string last "{" $line] <= [string last "}" $line] )} {
                    set arrows [regexp -all -inline {(\[\%draw[ \n]*arrow),([a-h][1-8]),([a-h][1-8]),([A-z]*)\]} $moves]
                    set circles [regexp -all -inline {(\[\%draw[ \n]*[\!-z]*),([a-h][1-8]),([A-z]*)\]} $moves]
                    foreach { arrow nop from to color } $arrows {
                        set color [mapColor $color]
                        set ws [string index $arrow 6]
                        # keep whitespace (blank or newline) to avoid long lines
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
                }
            }
        }
    }
    if {$of ne "stdout"} {close $of}
}

set input [lindex $argv 0]
if {[llength $argv] < 1 || $input in {-h --help}} {
    puts "Usage: conv_marker.tcl inputfile [outputfile]"
} else {
    convertMarker $input [lindex $argv 1]
}
exit
