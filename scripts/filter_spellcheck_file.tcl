#!/usr/bin/wish
# filterssp.tcl:
#     Filter players from a spellcheck file (ssp)
#     Filter parameters: ELO Range and Nationality
#
# Usage:  filter_spellcheck_file.tcl source destinaton
# Example: filter_spellcheck_file.tcl ratings.ssp filterdata.ssp

package require Tcl 8.5
package require Tk  8.5
package require fileutil

proc initProgress { size {msg ""} } {
    global progCount vProgress tProgress
    set progCount 0
    set vProgress 0
    .progress configure -value 0 -maximum $size
    set tProgress $msg
    update
}

proc updateProgress { ist { msg "" }} {
    global progCount vProgress tProgress
    incr progCount
    if { $progCount > 10000 } {
        set progCount 0
        set vProgress $ist
        if { $msg != "" } { set tProgress $msg }
        update
    }
}
proc OpenFile { filename {type "" } mode } {
    global workFile
    set ftype { { "Scid Spellcheck files" {".ssp"} } }
    if { $mode == "r" } {
        set fullname [tk_getOpenFile -initialdir [pwd] -filetypes $ftype -title "Open file for read"]
    } else {
        set fullname [tk_getSaveFile -initialdir [pwd] -filetypes $ftype -title "Open file for write"]
    }
    if {![string compare $fullname ""]} { return  }
    set workFile($filename) $fullname
}

## Filter aus einer ssp datei alle Spieler mit einer ELO von bis und der Nationalität
## Nationalität leer : alle Nationalitäten
proc dofilterData { source destination fromElo toElo Countries } {
    if { $fromElo == "" } { set fromElo 0 }
    if { $toElo == "" } { set toElo 4000 }
    set nat [split $Countries ";"]
    set lnat [llength $nat]

    set fd [open $source r]
    initProgress [file size $source] "Read $source ..."
    fconfigure $fd -translation lf
    set of [open $destination w]
    set state 0
    set anz_player 0
    while { [gets $fd line] >= 0 } {
        set fc [string index $line 0]
        if { $state && ($fc == " " || [string length $line] < 2) } {
            continue;
        }
        if { ! $state && ($fc == "#" || $fc == "@" || $fc == " " || [string length $line] < 2) } {
            if { [string first "#    (1) Player information:" $line ] >= 0} {
                puts $of "#    (1) Player information: --x-- players."
                set tostring ""
                if { $toElo != 4000 } { set tostring " and <= $toElo" }
                set line "#        This file contains only data from [file tail $source] with players\n#        ELO value >= $fromElo$tostring"
                if { $Countries ne "" } {
                    puts $of $line
                    set line "#        and players from $Countries"
                }
            }
            puts $of $line
            continue;
        }
        set state 0
        set f [string first "#" $line]
        if { $f > 0 } {
            if { [scan [string range $line $f end] "%s %s %s" gm pnat pelo] == 3 } {
                set pelo [string range $pelo 1 4]
                if { ![string is digit $pelo] } { set pelo 0 }
                if { $pelo >= $fromElo && $pelo <= $toElo } {
                    if { $lnat } {
                        set state 1
                        foreach n $nat {
                            if { $n eq $pnat } { set state 0 }
                        }
                    }
                    if { ! $state } { incr anz_player }
                } else {
                    set state 1
                }
            }
        }
        if { $state == 0 } { puts $of $line }
        updateProgress [tell $fd]
     }
    close $of
    close $fd
    set replacementCmd [list string map [list "Player information: --x--" "Player information: $anz_player"]]
    fileutil::updateInPlace $destination $replacementCmd
    initProgress [file size $source] "Finished. $anz_player Player found. File $destination was created."
}

proc filterData { source destination } {
    global workFile fromElo toElo Countries

    set w ""
    wm title . "Filter Spellcheck File"
    foreach i { source destination } k { "r" "w" } t {"Source" "Destination" } {
        pack [ttk::frame $w.$i] -side top -fill x
        ttk::label $w.$i.title -text $t
        ttk::entry $w.$i.e -width 60 -textvariable workFile($i)
        ttk::button $w.$i.b -text "..." -command [list OpenFile $i "ssp" $k]
        pack $w.$i.title -side top -padx 2 -anchor w
        pack $w.$i.b -side right -padx 2
        pack $w.$i.e -side bottom -padx 2 -fill x
    }
    ttk::frame $w.b
    ttk::frame $w.elo
    ttk::button $w.b.cancel -text "Close" -command "exit 0"
    ttk::button $w.b.ok -text "Filter" -command { dofilterData $workFile(source) $workFile(destination) $fromElo $toElo $Countries }
    ttk::entry $w.elo.fromelo -width 5 -textvariable fromElo
    ttk::entry $w.elo.toelo -width 5 -textvariable toElo
    ttk::entry $w.elo.countries -width 20 -textvariable Countries
    ttk::label $w.elo.from -text "Elo from:"
    ttk::label $w.elo.to -text "to:"
    ttk::label $w.elo.country -text "Nationality:\ne.q.: GER;ITA"
    ttk::progressbar $w.progress  -orient horizontal -length 120  -mode determinate -variable vProgress
    ttk::label $w.progresstext -textvar tProgress

    pack $w.elo.from $w.elo.fromelo $w.elo.to $w.elo.toelo $w.elo.country $w.elo.countries -padx 5 -fill x -side left
    pack $w.progress $w.progresstext -side bottom -fill x -pady "10 0"
    pack $w.b.cancel $w.b.ok -side right -padx 5 -pady "5 0" -fill both
    pack $w.elo $w.b -side top -anchor e -pady 5

    wm resizable . 1 1
    grab .
}

set progCount 0
set vProgress 0
set tProgress ""
set fromElo ""
set toElo ""
set Countries ""
set fTypes { "txt" "ssp" "ssp" "ssp" "ssp" "txt"  }
set fMode {  "r" "r" "w" "w" "r" "w"}
set wFiles { source destination }
set fText { "source file" "output file" }
set workFile(source) [lindex $argv 0]
set workFile(destination) [lindex $argv 1]

filterData $workFile(source) $workFile(destination)
