###
### analysis.tcl: part of Scid.
### Copyright (C) 1999-2003  Shane Hudson.
### Copyright (C) 2007  Pascal Georges

######################################################################
### Analysis window: uses a chess engine to analyze the board.

# analysis(logMax):
#   The maximum number of log message lines to be saved in a log file.
set analysis(logMax) 5000

# analysis(log_stdout):
#   Set this to 1 if you want Scid-Engine communication log messages
#   to be echoed to stdout.
#
set analysis(log_stdout) 0

set useAnalysisBook 1
set analysisBookSlot 1
set useAnalysisBookName ""
set wentOutOfBook 0

set isBatch 0
set batchEnd 1
set isBatchOpening 0
set isBatchOpeningMoves 12
set stack ""

set markTacticalExercises 1

set isAnnotateVar 0
set isShortAnnotation 0
set addScoreToShortAnnotations 0
set addAnnotatorTag 0

################################################################################
#
################################################################################
# resetEngine:
#   Resets all engine-specific data.
#
proc resetEngine {n} {
    global analysis
    set analysis(pipe$n) ""             ;# Communication pipe file channel
    set analysis(seen$n) 0              ;# Seen any output from engine yet?
    set analysis(seenEval$n) 0          ;# Seen evaluation line yet?
    set analysis(score$n) 0             ;# Current score in centipawns
    set analysis(prevscore$n) 0         ;# Immediately previous score in centipawns
    set analysis(prevmoves$n) ""        ;# Immediately previous best line out from engine
    set analysis(nodes$n) 0             ;# Number of (kilo)nodes searched
    set analysis(depth$n) 0             ;# Depth in ply
    set analysis(prev_depth$n) 0        ;# Previous depth
    set analysis(time$n) 0              ;# Time in centisec (or sec; see below)
    set analysis(moves$n) ""            ;# PV (best line) output from engine
    set analysis(seldepth$n) 0
    set analysis(currmove$n) ""         ;# current move output from engine
    set analysis(currmovenumber$n) 0    ;# current move number output from engine
    set analysis(hashfull$n) 0
    set analysis(nps$n) 0
    set analysis(tbhits$n) 0
    set analysis(sbhits$n) 0
    set analysis(cpuload$n) 0
    set analysis(movelist$n) {}         ;# Moves to reach current position
    set analysis(nonStdStart$n) 0       ;# Game has non-standard start
    set analysis(has_analyze$n) 0       ;# Engine has analyze command
    set analysis(has_setboard$n) 0      ;# Engine has setboard command
    set analysis(send_sigint$n) 0       ;# Engine wants INT signal
    set analysis(wants_usermove$n) 0    ;# Engine wants "usermove" before moves
    set analysis(isCrafty$n) 0          ;# Engine appears to be Crafty
    set analysis(wholeSeconds$n) 0      ;# Engine times in seconds not centisec
    set analysis(analyzeMode$n) 0       ;# Scid has started analyze mode
    set analysis(invertScore$n) 1       ;# Score is for side to move, not white
    set analysis(automove$n) 0
    set analysis(automoveThinking$n) 0
    set analysis(automoveTime$n) 4000
    set analysis(lastClicks$n) 0
    set analysis(after$n) ""
    set analysis(log$n) ""              ;# Log file channel
    set analysis(logCount$n) 0          ;# Number of lines sent to log file
    set analysis(wbEngineDetected$n) 0  ;# Is this a special Winboard engine?
    set analysis(priority$n) normal     ;# CPU priority: idle/normal
    set analysis(multiPV$n) {}          ;# multiPV list sorted : depth score moves
    set analysis(multiPVraw$n) {}       ;# same thing but with raw UCI moves
    set analysis(uci$n) 0               ;# UCI engine
    # UCI engine options in format ( name min max ). This is not engine config but its capabilities
    set analysis(uciOptions$n) {}
    # the number of lines in multiPV. If =1 then act the traditional way
    set analysis(multiPVCount$n) 4      ;# number of N-best lines
    set analysis(index$n) 0             ;# the index of engine in engine list
    set analysis(uciok$n) 0             ;# uciok sent by engine in response to uci command
    set analysis(name$n) ""             ;# engine name
    set analysis(processInput$n) 0      ;# the time of the last processed event
    set analysis(waitForBestMove$n) 0
    set analysis(waitForReadyOk$n) 0
    set analysis(waitForUciOk$n) 0
    set analysis(movesDisplay$n) 1      ;# if false, hide engine lines, only display scores
    set analysis(lastHistory$n) {}      ;# last best line
    set analysis(maxmovenumber$n) 0     ;# the number of moves in this position
    set analysis(lockEngine$n) 0        ;# the engine is locked to current position
    set analysis(fen$n) {}              ;# the position that engine is analyzing
}

resetEngine 1
resetEngine 2

set annotateMode 0
set annotateModeButtonValue 0 ; # feedback of annotate mode

set annotateMoves all
set annotateBlunders blundersonly

################################################################################
# calculateNodes:
#   Divides string-represented node count by 1000
################################################################################
proc calculateNodes {{n}} {
    set len [string length $n]
    if { $len < 4 } {
        return 0
    } else {
        set shortn [string range $n 0 [expr {$len - 4}]]
        scan $shortn "%d" nd
        return $nd
    }
}


# resetAnalysis:
#   Resets the analysis statistics: score, depth, etc.
#
proc resetAnalysis {{n 1}} {
    global analysis
    set analysis(score$n) 0
    set analysis(scoremate$n) 0
    set analysis(nodes$n) 0
    set analysis(prev_depth$n) 0
    set analysis(depth$n) 0
    set analysis(time$n) 0
    set analysis(moves$n) ""
    set analysis(multiPV$n) {}
    set analysis(multiPVraw$n) {}
    set analysis(lastHistory$n) {}
    set analysis(maxmovenumber$n) 0
}

namespace eval enginelist {}

set engines(list) {}

# engine:
#   Adds an engine to the engine list.
#   Calls to this function will be found in the user engines.lis
#   file, which is sourced below.
#
proc engine {arglist} {
    global engines
    array set newEngine {}
    foreach {attr value} $arglist {
        set newEngine($attr) $value
    }
    # Check that required attributes exist:
    if {! [info exists newEngine(Name)]} { return  0 }
    if {! [info exists newEngine(Cmd)]} { return  0 }
    if {! [info exists newEngine(Dir)]} { return  0 }
    # Fill in optional attributes:
    if {! [info exists newEngine(Args)]} { set newEngine(Args) "" }
    if {! [info exists newEngine(Elo)]} { set newEngine(Elo) 0 }
    if {! [info exists newEngine(Time)]} { set newEngine(Time) 0 }
    if {! [info exists newEngine(URL)]} { set newEngine(URL) "" }
    # puts this option here for compatibility with previous file format (?!)
    if {! [info exists newEngine(UCI)]} { set newEngine(UCI) 0 }
    if {! [info exists newEngine(UCIoptions)]} { set newEngine(UCIoptions) "" }
    
    lappend engines(list) [list $newEngine(Name) $newEngine(Cmd) \
            $newEngine(Args) $newEngine(Dir) \
            $newEngine(Elo) $newEngine(Time) \
            $newEngine(URL) $newEngine(UCI) $newEngine(UCIoptions)]
    return 1
}

# ::enginelist::read
#   Reads the user Engine list file.
#
proc ::enginelist::read {} {
    catch {source [scidConfigFile engines]}
}

# ::enginelist::write:
#   Writes the user Engine list file.
#
proc ::enginelist::write {} {
    global engines ::uci::newOptions
    
    set enginesFile [scidConfigFile engines]
    set enginesBackupFile [scidConfigFile engines.bak]
    # Try to rename old file to backup file and open new file:
    catch {file rename -force $enginesFile $enginesBackupFile}
    if {[catch {open $enginesFile w} f]} {
        catch {file rename $enginesBackupFile $enginesFile}
        return 0
    }
    
    puts $f "\# Analysis engines list file for Scid [sc_info version] with UCI support"
    puts $f ""
    foreach e $engines(list) {
        set name [lindex $e 0]
        set cmd [lindex $e 1]
        set args [lindex $e 2]
        set dir [lindex $e 3]
        set elo [lindex $e 4]
        set time [lindex $e 5]
        set url [lindex $e 6]
        set uci [lindex $e 7]
        set opt [lindex $e 8]
        puts $f "engine {"
            puts $f "  Name [list $name]"
            puts $f "  Cmd  [list $cmd]"
            puts $f "  Args [list $args]"
            puts $f "  Dir  [list $dir]"
            puts $f "  Elo  [list $elo]"
            puts $f "  Time [list $time]"
            puts $f "  URL  [list $url]"
            puts $f "  UCI [list $uci]"
            puts $f "  UCIoptions [list $opt]"
            puts $f "}"
        puts $f ""
    }
    close $f
    return 1
}

# Read the user Engine List file now:
#
catch { ::enginelist::read }
if {[llength $engines(list)] == 0} {
    # No engines, so set up a default engine list:
    set scidlet "scidlet"
    set phalanx "phalanx-scid"
    set togaII "togaII"
    if { $::windowsOS } {
        set scidlet "scidlet.exe"
        set phalanx "phalanx-scid.exe"
        set togaII "TogaII.exe"
    }
    set scidEngPaths [list $::scidExeDir [file join $::scidExeDir "engines" ] [file join $::scidShareDir "engines" ] \
            [ file join $::scidUserDir "engines" ]  [ file join usr local share scid engines ] \
            [ file join usr local bin ] [ file join  usr bin ] [ file join usr local games ] [ file join usr games ] \
            [file join $::scidExeDir "engines" "phalanx-scid" ] [file join $::scidExeDir "engines" "togaII1.2.1a" "src" ] ]
    
    # The next four lists should have the same length!
    set scidEngCmds [list $phalanx $togaII $scidlet ]
    set scidEngNames [list "Phalanx-Scid" "Toga II" "Scidlet" ]
    array set parentDirs "
    $phalanx { phalanx-scid Phalanx-XXII }
    $togaII  { togaII1.2.1a toga togaII [ file join togaII1.2.1a src ] }
    $scidlet { . }
    "
    
    set isUCI [list 0 1 0 ]
    
    # Let's search the engines:
    foreach cmd $scidEngCmds name $scidEngNames uci $isUCI {
        set leave 0
        foreach path $scidEngPaths {
            set c [ file join $path $cmd]
            if { [file executable $c ] && ! [ file isdirectory $c ] } {
                engine [list \
                        Name $name \
                        Cmd  $c \
                        Dir  . \
                        UCI  $uci \
                        UCIoptions {} \
                        ]
                set leave 1
            } else {
                foreach parent $parentDirs($cmd) {
                    set c [ file join $path $parent $cmd ]
                    if { [file executable $c] && ! [ file isdirectory $c ] } {
                        engine [list \
                                Name $name \
                                Cmd  $c \
                                Dir  . \
                                UCI  $uci \
                                UCIoptions {} \
                                ]
                        set leave 1
                        break
                    }
                }
            }
            if { $leave } { break }
        }
    }
}

# ::enginelist::date
#   Given a time in seconds since 1970, returns a
#   formatted date string.
proc ::enginelist::date {time} {
    return [clock format $time -format "%a %b %d %Y %H:%M"]
}

# ::enginelist::sort
#   Sort the engine list.
#   If the engine-open dialog is open, its list is updated.
#   The type defaults to the current engines(sort) value.
#
proc ::enginelist::sort {{type ""}} {
    global engines
    
    if {$type == ""} {
        set type $engines(sort)
    } else {
        set engines(sort) $type
    }
    switch $type {
        Name {
            set engines(list) [lsort -dictionary -index 0 $engines(list)]
        }
        Elo {
            set engines(list) [lsort -integer -decreasing -index 4 $engines(list)]
        }
        Time {
            set engines(list) [lsort -integer -decreasing -index 5 $engines(list)]
        }
    }
    
    # If the Engine-open dialog is open, update it:
    #
    set w .enginelist
    if {! [winfo exists $w]} { return }
    set f $w.list.list
    $f delete 0 end
    set count 0
    foreach engine $engines(list) {
        incr count
        set name [lindex $engine 0]
        set elo [lindex $engine 4]
        set time [lindex $engine 5]
        set uci [lindex $engine 7]
        set date [::enginelist::date $time]
        set text [format "%2u. %-21s " $count $name]
        set eloText "    "
        if {$elo > 0} { set eloText [format "%4u" $elo] }
        append text $eloText
        set timeText "  "
        if {$time > 0} { set timeText "   $date" }
        append text $timeText
        $f insert end $text
    }
    $f selection set 0
    
    # Show the sorted column heading in red text:
    $w.title configure -state normal
    foreach i {Name Elo Time} {
        $w.title tag configure $i -foreground {}
    }
    $w.title tag configure $engines(sort) -foreground red
    $w.title configure -state disabled
}
################################################################################
# ::enginelist::choose
#   Select an engine from the Engine List.
#   Returns an integer index into the engines(list) list variable.
#   If no engine is selected, returns the empty string.
################################################################################
proc ::enginelist::choose {} {
    global engines
    set w .enginelist
    if {[winfo exists $w]} {
        raise .enginelist
        return }
    toplevel $w
    ::setTitle $w "Scid: [tr ToolsAnalysis]"
    ttk::label $w.flabel -text $::tr(EngineList:) -font font_Bold -anchor center
    pack $w.flabel -side top -expand 1 -fill both
    
    pack [ttk::frame $w.buttons] -side bottom -fill x
    ttk::frame $w.rule -height 2 -borderwidth 2 -relief sunken
    pack $w.rule -side bottom -fill x
    
    # Set up title frame for sorting the list:
    text $w.title -width 55 -height 1 -font font_Fixed -relief flat \
            -cursor top_left_arrow
    $w.title insert end "    "
    $w.title insert end $::tr(EngineName) Name
    for {set i [string length $::tr(EngineName)]} {$i < 21} { incr i } {
        $w.title insert end " "
    }
    $w.title insert end "  "
    $w.title insert end $::tr(EngineElo) Elo
    for {set i [string length $::tr(EngineElo)]} {$i < 4} { incr i } {
        $w.title insert end " "
    }
    $w.title insert end "  "
    $w.title insert end $::tr(EngineTime) Time
    foreach i {Name Elo Time} {
        $w.title tag bind $i <Any-Enter> \
                "$w.title tag configure $i -background yellow"
        $w.title tag bind $i <Any-Leave> \
                "$w.title tag configure $i -background {}"
        $w.title tag bind $i <1> [list ::enginelist::sort $i]
    }
    $w.title configure -state disabled
    pack $w.title -side top -fill x
    
    # The list of choices:
    set f $w.list
    pack [ttk::frame $f] -side top -expand yes -fill both
    listbox $f.list -height 10 -width 55  -selectmode browse \
            -background white -setgrid 1 \
            -yscrollcommand "$f.ybar set" -font font_Fixed -exportselection 0
    bind $f.list <Double-ButtonRelease-1> "$w.buttons.ok invoke; break"
    ttk::scrollbar $f.ybar -command "$f.list yview"
    pack $f.ybar -side right -fill y
    pack $f.list -side top -fill both -expand yes
    $f.list selection set 0
    
    set f $w.buttons
    dialogbutton $f.add -text $::tr(EngineNew...) -command {::enginelist::edit -1}
    dialogbutton $f.edit -text $::tr(EngineEdit...) -command {
        ::enginelist::edit [lindex [.enginelist.list.list curselection] 0]
    }
    dialogbutton $f.delete -text $::tr(Delete...) -command {
        ::enginelist::delete [lindex [.enginelist.list.list curselection] 0]
    }
    ttk::label $f.sep -text "   "
    dialogbutton $f.ok -text "OK" -command {
        set engines(selection) [lindex [.enginelist.list.list curselection] 0]
        destroy .enginelist
    }
    dialogbutton $f.cancel -text $::tr(Cancel) -command {
        set engines(selection) ""
        destroy .enginelist
    }
    packbuttons right $f.cancel $f.ok
    pack $f.add $f.edit $f.delete -side left -padx 1
    
    ::enginelist::sort
    ::utils::win::Centre $w
    focus $w.list.list
    wm protocol $w WM_DELETE_WINDOW "destroy $w"
    bind $w <F1> { helpWindow Analysis List }
    bind $w <Escape> "destroy $w"
    bind $w.list.list <Return> "$w.buttons.ok invoke; break"
    set engines(selection) ""
    catch {grab $w}
    tkwait window $w
    return $engines(selection)
}

# ::enginelist::setTime
#   Sets the last-opened time of the engine specified by its
#   index in the engines(list) list variable.
#   The time should be in standard format (seconds since 1970)
#   and defaults to the current time.
#
proc ::enginelist::setTime {index {time -1}} {
    global engines
    set e [lindex $engines(list) $index]
    if {$time < 0} { set time [clock seconds] }
    set e [lreplace $e 5 5 $time]
    set engines(list) [lreplace $engines(list) $index $index $e]
}

trace variable engines(newElo) w [list ::utils::validate::Integer [sc_info limit elo] 0]

# ::enginelist::delete
#   Removes an engine from the list.
#
proc ::enginelist::delete {index} {
    global engines
    if {$index == ""  ||  $index < 0} { return }
    set e [lindex $engines(list) $index]
    set msg "Name: [lindex $e 0]\n"
    append msg "Command: [lindex $e 1]\n\n"
    append msg "Do you really want to remove this engine from the list?"
    set answer [tk_messageBox -title Scid -icon question -type yesno \
            -message $msg]
    if {$answer == "yes"} {
        set engines(list) [lreplace $engines(list) $index $index]
        ::enginelist::sort
        ::enginelist::write
    }
}

# ::enginelist::edit
#   Opens a dialog for editing an existing engine list entry (if
#   index >= 0), or adding a new entry (if index is -1).
#
proc ::enginelist::edit {index} {
    global engines
    if {$index == ""} { return }
    
    if {$index >= 0  ||  $index >= [llength $engines(list)]} {
        set e [lindex $engines(list) $index]
    } else {
        set e [list "" "" "" . 0 0 "" 1]
    }
    
    set engines(newIndex) $index
    set engines(newName) [lindex $e 0]
    set engines(newCmd) [lindex $e 1]
    set engines(newArgs) [lindex $e 2]
    set engines(newDir) [lindex $e 3]
    set engines(newElo) [lindex $e 4]
    set engines(newTime) [lindex $e 5]
    set engines(newURL) [lindex $e 6]
    set engines(newUCI) [lindex $e 7]
    set engines(newUCIoptions) [lindex $e 8]
    
    set engines(newDate) $::tr(None)
    if {$engines(newTime) > 0 } {
        set engines(newDate) [::enginelist::date $engines(newTime)]
    }
    
    set w .engineEdit
    toplevel $w
    ::setTitle $w Scid
    
    set f [ttk::frame $w.f]
    pack $f -side top -fill x -expand yes
    set row 0
    foreach i {Name Cmd Args Dir URL} {
        ttk::label $f.l$i -text $i
        if {[info exists ::tr(Engine$i)]} {
            $f.l$i configure -text $::tr(Engine$i)
        }
        ttk::entry $f.e$i -textvariable engines(new$i) -width 40
        bindFocusColors $f.e$i
        grid $f.l$i -row $row -column 0 -sticky w
        grid $f.e$i -row $row -column 1 -sticky we
        
        # Browse button for choosing an executable file:
        if {$i == "Cmd"} {
            ttk::button $f.b$i -text "..." -command {
                if {$::windowsOS} {
                    set scid_temp(filetype) {
                        {"Applications" {".bat" ".exe"} }
                        {"All files" {"*"} }
                    }
                } else {
                    set scid_temp(filetype) {
                        {"All files" {"*"} }
                    }
                }
                set scid_temp(cmd) [tk_getOpenFile -initialdir $engines(newDir) \
                        -title "Scid: [tr ToolsAnalysis]" -filetypes $scid_temp(filetype)]
                if {$scid_temp(cmd) != ""} {
                    set engines(newCmd) $scid_temp(cmd)
                    # if {[string first " " $scid_temp(cmd)] >= 0} {
                    # The command contains spaces, so put it in quotes:
                    # set engines(newCmd) "\"$scid_temp(cmd)\""
                    # }
                    # Set the directory from the executable path if possible:
                    set engines(newDir) [file dirname $scid_temp(cmd)]
                    if {$engines(newDir) == ""} [ set engines(newDir) .]
                }
            }
            grid $f.b$i -row $row -column 2 -sticky we
        }
        
        if {$i == "Dir"} {
            ttk::button $f.current -text " . " -command {
                set engines(newDir) .
            }
            ttk::button $f.user -text "~/.scid" -command {
                set engines(newDir) $scidUserDir
            }
            if {$::windowsOS} {
                $f.user configure -text "scid.exe dir"
            }
            grid $f.current -row $row -column 2 -sticky we
            grid $f.user -row $row -column 3 -sticky we
        }
        
        if {$i == "URL"} {
            ttk::button $f.bURL -text [tr FileOpen] -command {
                if {$engines(newURL) != ""} { openURL $engines(newURL) }
            }
            grid $f.bURL -row $row -column 2 -sticky we
        }
        
        incr row
    }
    
    grid columnconfigure $f 1 -weight 1
    
    ttk::checkbutton $f.cbUci -text UCI -variable engines(newUCI) -style Bold.TCheckbutton
    ttk::button $f.bConfigUCI -text $::tr(ConfigureUCIengine) -command {
        ::uci::uciConfig 2 [ toAbsPath $engines(newCmd) ] $engines(newArgs) \
                [ toAbsPath $engines(newDir) ] $engines(newUCIoptions)
    }
    # Mark required fields:
    $f.lName configure -font font_Bold
    $f.lCmd configure -font font_Bold
    $f.lDir configure -font font_Bold
    # $f.cbUci configure -font font_Bold
    
    ttk::label $f.lElo -text $::tr(EngineElo)
    ttk::entry $f.eElo -textvariable engines(newElo) -justify right -width 5
    bindFocusColors $f.eElo
    grid $f.lElo -row $row -column 0 -sticky w
    grid $f.eElo -row $row -column 1 -sticky w
    incr row
    grid $f.cbUci -row $row -column 0 -sticky w
    grid $f.bConfigUCI -row $row -column 1 -sticky w
    incr row
    
    ttk::label $f.lTime -text $::tr(EngineTime)
    ttk::label $f.eTime -textvariable engines(newDate) -anchor w -width 1
    grid $f.lTime -row $row -column 0 -sticky w
    grid $f.eTime -row $row -column 1 -sticky we
    ttk::button $f.clearTime -text $::tr(Clear) -command {
        set engines(newTime) 0
        set engines(newDate) $::tr(None)
    }
    ttk::button $f.nowTime -text $::tr(Update) -command {
        set engines(newTime) [clock seconds]
        set engines(newDate) [::enginelist::date $engines(newTime)]
    }
    grid $f.clearTime -row $row -column 2 -sticky we
    grid $f.nowTime -row $row -column 3 -sticky we
    
    addHorizontalRule $w
    
    set f [ttk::frame $w.buttons]
    ttk::button $f.ok -text OK -command {
        if {[string trim $engines(newName)] == ""  ||
            [string trim $engines(newCmd)] == ""  ||
            [string trim $engines(newDir)] == ""} {
            tk_messageBox -title Scid -icon info \
                    -message "The Name, Command and Directory fields must not be empty."
        } else {
            set newEntry [list $engines(newName) $engines(newCmd) \
                    $engines(newArgs) $engines(newDir) \
                    $engines(newElo) $engines(newTime) \
                    $engines(newURL) $engines(newUCI) $::uci::newOptions ]
            if {$engines(newIndex) < 0} {
                lappend engines(list) $newEntry
            } else {
                set engines(list) [lreplace $engines(list) \
                        $engines(newIndex) $engines(newIndex) $newEntry]
            }
            destroy .engineEdit
            ::enginelist::sort
            ::enginelist::write
            focus .enginelist
        }
    }
    ttk::button $f.cancel -text $::tr(Cancel) -command "destroy $w ; focus .enginelist"
    pack $f -side bottom -fill x
    pack $f.cancel $f.ok -side right -padx 2 -pady 2
    ttk::label $f.required -font font_Small -text $::tr(EngineRequired)
    pack $f.required -side left
    
    bind $w <Return> "$f.ok invoke"
    bind $w <Escape> "destroy $w ; focus .enginelist "
    bind $w <F1> { helpWindow Analysis List }
    focus $w.f.eName
    wm resizable $w 1 0
    catch {grab $w}
}
# ################################################################################
#
################################################################################
proc configAnnotation {} {
    global autoplayDelay tempdelay blunderThreshold annotateModeButtonValue
    
    set w .configAnnotation
    if { [winfo exists $w] } { focus $w ; return }
    if { ! $annotateModeButtonValue } { ; # end annotation
        toggleAutoplay
        return
    }
    
    trace variable blunderThreshold w {::utils::validate::Regexp {^[0-9]*\.?[0-9]*$}}
    
    set tempdelay [expr {$autoplayDelay / 1000.0}]
    toplevel $w
    ::setTitle $w "Scid"
    wm resizable $w 0 0
    set f [ttk::frame $w.f]
    pack $f -expand 1
    ttk::label $f.label -text $::tr(AnnotateTime:)
    pack $f.label -side top
    spinbox $f.spDelay -background white -width 4 -textvariable tempdelay -from 1 -to 300 -increment 1
    pack $f.spDelay -side top -pady 5
    bind $w <Escape> { .configAnnotation.f.buttons.cancel invoke }
    bind $w <Return> { .configAnnotation.f.buttons.ok invoke }
    
    addHorizontalRule $f
    ttk::label $f.avlabel -text $::tr(AnnotateWhich:)
    ttk::radiobutton $f.all -text $::tr(AnnotateAll) -variable annotateMoves -value all
    ttk::radiobutton $f.white -text $::tr(AnnotateWhite) -variable annotateMoves -value white
    ttk::radiobutton $f.black -text $::tr(AnnotateBlack) -variable annotateMoves -value black
    ttk::radiobutton $f.allmoves -text $::tr(AnnotateAllMoves) -variable annotateBlunders -value allmoves
    ttk::radiobutton $f.notbest -text $::tr(AnnotateNotBest) -variable annotateBlunders -value notbest
    ttk::radiobutton $f.blundersonly -text $::tr(AnnotateBlundersOnly) -variable annotateBlunders -value blundersonly
    pack $f.avlabel -side top
    pack $f.all $f.white $f.black $f.allmoves $f.notbest $f.blundersonly -side top -fill x -anchor w
    
    ttk::frame $f.blunderbox
    pack $f.blunderbox -side top -padx 5 -pady 5
    
    ttk::label $f.blunderbox.label -text $::tr(BlundersThreshold:)
    spinbox $f.blunderbox.spBlunder -background white -width 4 -textvariable blunderThreshold \
            -from 0.1 -to 3.0 -increment 0.1
    pack $f.blunderbox.label $f.blunderbox.spBlunder -side left -padx 5 -pady 5
    
    addHorizontalRule $f
    ttk::checkbutton $f.cbAnnotateVar  -text $::tr(AnnotateVariations) -variable ::isAnnotateVar
    ttk::checkbutton $f.cbShortAnnotation  -text $::tr(ShortAnnotations) -variable ::isShortAnnotation
    ttk::checkbutton $f.cbAddScore  -text $::tr(AddScoreToShortAnnotations) -variable ::addScoreToShortAnnotations
    ttk::checkbutton $f.cbAddAnnotatorTag  -text $::tr(addAnnotatorTag) -variable ::addAnnotatorTag
    pack $f.cbAnnotateVar $f.cbShortAnnotation $f.cbAddScore $f.cbAddAnnotatorTag -fill x -anchor w
    
    # choose a book for analysis
    addHorizontalRule $f
    ttk::checkbutton $f.cbBook  -text $::tr(UseBook) -variable ::useAnalysisBook
    # load book names
    set bookPath $::scidBooksDir
    set bookList [  lsort -dictionary [ glob -nocomplain -directory $bookPath *.bin ] ]
    
    # No book found
    if { [llength $bookList] == 0 } {
        set ::useAnalysisBook 0
        $f.cbBook configure -state disabled
    }
    
    set tmp {}
    set idx 0
    set i 0
    foreach file  $bookList {
        lappend tmp [ file tail $file ]
        if {$::book::lastBook == [ file tail $file ] } {
            set idx $i
        }
        incr i
    }
    ttk::combobox $f.comboBooks -width 12 -values $tmp
    catch { $f.comboBooks current $idx }
    pack $f.cbBook $f.comboBooks -side top
    
    addHorizontalRule $f
    
    # batch annotation of consecutive games, and optional opening errors finder
    ttk::frame $f.batch
    pack $f.batch -side top -fill x
    set to [sc_base numGames]
    if {$to <1} { set to 1}
    ttk::checkbutton $f.batch.cbBatch -text $::tr(AnnotateSeveralGames) -variable ::isBatch
    spinbox $f.batch.spBatchEnd -background white -width 8 -textvariable ::batchEnd \
            -from 1 -to $to -increment 1 -validate all -vcmd { regexp {^[0-9]+$} %P }
    ttk::checkbutton $f.batch.cbBatchOpening -text $::tr(FindOpeningErrors) -variable ::isBatchOpening
    spinbox $f.batch.spBatchOpening -background white -width 2 -textvariable ::isBatchOpeningMoves \
            -from 10 -to 20 -increment 1 -validate all -vcmd { regexp {^[0-9]+$} %P }
    ttk::label $f.batch.lBatchOpening -text $::tr(moves)
    # pack $w.batch.cbBatch $w.batch.spBatchEnd -side top -fill x
    # pack $w.batch.cbBatchOpening $w.batch.spBatchOpening $w.batch.lBatchOpening  -side left -fill x
    grid $f.batch.cbBatch -column 0 -row 0 -sticky w
    grid $f.batch.spBatchEnd -column 1 -row 0 -sticky w
    grid $f.batch.cbBatchOpening -column 0 -row 1 -sticky w
    grid $f.batch.spBatchOpening -column 1 -row 1 -sticky e
    grid $f.batch.lBatchOpening -column 2 -row 1 -sticky w
    set ::batchEnd $to
    
    ttk::checkbutton $f.batch.cbMarkTactics -text $::tr(MarkTacticalExercises) -variable ::markTacticalExercises
    grid $f.batch.cbMarkTactics -column 0 -row 2 -sticky w
    if {! $::analysis(uci1)} {
        set ::markTacticalExercises 0
        $f.batch.cbMarkTactics configure -state disabled
    }
    
    addHorizontalRule $f
    ttk::frame $f.buttons
    pack $f.buttons -side top -fill x
    ttk::button $f.buttons.cancel -text $::tr(Cancel) -command {
        destroy .configAnnotation
        set annotateMode 0
        set annotateModeButtonValue 0
    }
    ttk::button $f.buttons.ok -text "OK" -command {
        set ::useAnalysisBookName [.configAnnotation.f.comboBooks get]
        set  ::wentOutOfBook 0
        set ::book::lastBook $::useAnalysisBookName
        
        # tactical positions is selected, must be in multipv mode
        if {$::markTacticalExercises} {
            if { $::analysis(multiPVCount1) < 2} {
                set ::analysis(multiPVCount1) 4
                changePVSize 1
            }
        }
        
        if {$tempdelay < 0.1} { set tempdelay 0.1 }
        set autoplayDelay [expr {int($tempdelay * 1000)}]
        destroy .configAnnotation
        set annotateMode 1
        if {! $analysis(analyzeMode1)} {
            toggleEngineAnalysis 1 1
        }
        if {$::addAnnotatorTag} {
            appendAnnotator "$analysis(name1)"
        }
        if {$autoplayMode == 0} { toggleAutoplay }
    }
    pack $f.buttons.cancel $f.buttons.ok -side right -padx 5 -pady 5
    focus $f.spDelay
    update ; # or grab will fail
    grab $w
    bind $w <Destroy> { focus . }
}
################################################################################
# Part of annotation process : will check the moves if they are in te book, and add a comment
# when going out of it
################################################################################
proc bookAnnotation { {n 1} } {
    global analysis
    
    if {$::annotateMode && $::useAnalysisBook} {
        
        set prevbookmoves ""
        set bn [ file join $::scidBooksDir $::useAnalysisBookName ]
        sc_book load $bn $::analysisBookSlot
        
        set bookmoves [sc_book moves $::analysisBookSlot]
        while {[string length $bookmoves] != 0 && ![sc_pos isAt vend]} {
            # we are in book, so move immediately forward
            ::move::Forward
            set prevbookmoves $bookmoves
            set bookmoves [sc_book moves $::analysisBookSlot]
        }
        sc_book close $::analysisBookSlot
        set ::wentOutOfBook 1
        
        set verboseMoveOutOfBook ""
        set verboseLastBookMove ""
        if {! $::isShortAnnotation } {
            set verboseMoveOutOfBook " $::tr(MoveOutOfBook)"
            set verboseLastBookMove " $::tr(LastBookMove)"
        }
        
        if {  ! $::onlyMarkExercise } {
            if { [ string match -nocase "*[sc_game info previousMoveNT]*" $prevbookmoves ] != 1 } {
                if {$prevbookmoves != ""} {
                    sc_pos setComment "[sc_pos getComment]$verboseMoveOutOfBook [::trans $prevbookmoves]"
                } else  {
                    sc_pos setComment "[sc_pos getComment]$verboseMoveOutOfBook"
                }
            } else  {
                sc_pos setComment "[sc_pos getComment]$verboseLastBookMove"
            }
        }
        
        # last move was out of book or the last move in book : it needs to be analyzed, so take back
        if { ![catch { sc_move back 1 } ] } {
            resetAnalysis
            updateBoard -pgn
            for {set i 0} {$i<100} {incr i} { update ; after [expr $::autoplayDelay / 100] }
            set analysis(prevscore$n) $analysis(score$n)
            set analysis(prevmoves$n) $analysis(moves$n)
            updateBoard -pgn
        }
    }
}
################################################################################
# Will add **** to any position considered as a tactical shot
# returns 1 if an exercise was marked, 0 if for some reason it was not (obvious move for example)
################################################################################
proc markExercise { prevscore score nag} {
    
    if {! $::onlyMarkExercise} {
        sc_pos addNag $nag
    }
    
    if {!$::markTacticalExercises} { return 0 }
    
    # check at which depth the tactical shot is found
    # this assumes analysis by an UCI engine
    if {! $::analysis(uci1)} { return 0 }
    
    set deltamove [expr {$score - $prevscore}]
    # filter tactics so only those with high gains are kept
    if { [expr abs($deltamove)] < $::informant("+/-") } { return 0 }
    # dismiss games where the result is already clear (high score,and we continue in the same way)
    if { [expr $prevscore * $score] >= 0} {
        if { [expr abs($prevscore) ] > $::informant("++-") } { return 0 }
        if { [expr abs($prevscore)] > $::informant("+-") && [expr abs($score) ] < [expr 2 * abs($prevscore)]} { return 0 }
    }
    
    # The best move is much better than others.
    if { [llength $::analysis(multiPV1)] < 2 } {
        puts "error, not enough PV"
        return 0
    }
    set sc2 [lindex [ lindex $::analysis(multiPV1) 1 ] 1]
    if { [expr abs( $score - $sc2 )] < 1.5 } { return 0 }
    
    # There is no other winning moves (the best move may not win, of course, but
    # I reject exercises when there are e.g. moves leading to +9, +7 and +5 scores)
    if { [expr $score * $sc2] > 0.0 && [expr abs($score)] > $::informant("+-") && [expr abs($sc2)] > $::informant("+-") } {
        return 0
    }
    
    # The best move does not lose position.
    if {[sc_pos side] == "white" && $score < [expr 0.0 - $::informant("+/-")] } { return 0 }
    if {[sc_pos side] == "black" && $score > $::informant("+/-") } { return 0}
    
    # Move is not obvious: check that it is not the first move guessed at low depths
    set pv [ lindex [ lindex $::analysis(multiPV1) 0 ] 2 ]
    set bm0 [lindex $pv 0]
    foreach depth {1 2 3} {
        set res [ sc_pos analyze -time 1000 -hashkb 32 -pawnkb 1 -searchdepth $depth ]
        set bm$depth [lindex $res 1]
    }
    if { $bm0 == $bm1 && $bm0 == $bm2 && $bm0 == $bm3 } {
        puts "obvious move"
        return 0
    }
    
    # find what time is needed to get the solution (use internal analyze function)
    set timer {1 2 5 10 50 100 200 1000}
    set movelist {}
    for {set t 0} {$t < [llength $timer]} { incr t} {
        set res [sc_pos analyze -time [lindex $timer $t] -hashkb 1 -pawnkb 1 -mindepth 0]
        set move_analyze [lindex $res 1]
        lappend movelist $move_analyze
    }
    
    # find at what timing the right move was reliably found
    # only the move is checked, not if the score is close to the expected one
    for {set t [expr [llength $timer] -1]} {$t >= 0} { incr t -1} {
        if { [lindex $movelist $t] != $bm0 } {
            break
        }
    }
    
    set difficulty [expr $t +2]
    
    puts "flag T pour [sc_game number] difficulty $difficulty"
    # If the base opened is read only, like a PGN file, avoids an exception
    catch { sc_game flag T [sc_game number] 1 }
    if { $::onlyMarkExercise} {
        sc_pos addNag $nag
    }
    sc_pos setComment "****D${difficulty} [format %.1f $prevscore]->[format %.1f $score] [sc_pos getComment]"
    updateBoard
    
    return 1
}
################################################################################
#
################################################################################
# set ::onlyMarkExercise to 1 to only append exercises (****) when annotating games
set ::onlyMarkExercise 0

proc addAnnotation { {n 1} } {
    global analysis annotateMoves annotateBlunders annotateMode blunderThreshold
    
    set exerciseMarked 0
    
    # First look in the book selected
    if { ! $::wentOutOfBook && $::useAnalysisBook } {
        bookAnnotation
        return
    }
    
    # Cannot add a variation to an empty variation:
    if {[sc_pos isAt vstart]  &&  [sc_pos isAt vend]} { return }
    
    # Cannot (yet) add a variation at the end of the game or a variation:
    if {[sc_pos isAt vend]} { return }
    
    set tomove [sc_pos side]
    if {$annotateMoves == "white"  &&  $tomove == "white" ||
        $annotateMoves == "black"  &&  $tomove == "black" } {
        set analysis(prevscore$n) $analysis(score$n)
        set analysis(prevmoves$n) $analysis(moves$n)
        return
    }
    
    # to parse scores if the engine's name contains - or + chars (see sc_game_scores)
    set engine_name  [string map {"-" " " "+" " "} $analysis(name1)]
    
    set text [format "%d:%+.2f" $analysis(depth$n) $analysis(score$n)]
    set moves $analysis(moves$n)
    
    # if next move is what engine guessed, do nothing (except if annotate mode is for all moves)
    if { $analysis(prevmoves$n) != "" && ![sc_pos isAt vend] && $annotateBlunders != "allmoves"} {
        set move2 [sc_game info previousMoveNT]
        
        sc_info preMoveCmd {}
        sc_game push copyfast
        set move1 [lindex $analysis(prevmoves$n) 0]
        sc_move back 1
        sc_move_add $move1 $n
        set move1 [sc_game info previousMoveNT]
        sc_game pop
        sc_info preMoveCmd preMoveCommand
        
        if {$move1 == $move2} {
            set analysis(prevscore$n) $analysis(score$n)
            set analysis(prevmoves$n) $analysis(moves$n)
            return
        }
    }
    
    # Temporarily clear the pre-move command since we want to add a
    # whole line without Scid updating stuff:
    sc_info preMoveCmd {}
    
    set score $analysis(score$n)
    set prevscore $analysis(prevscore$n)
    
    set deltamove [expr {$score - $prevscore}]
    set isBlunder 0
    if {$annotateBlunders == "blundersonly"} {
        if { $deltamove < [expr 0.0 - $blunderThreshold] && $tomove == "black" || \
                    $deltamove > $blunderThreshold && $tomove == "white" } {
            set isBlunder 1
        }
        # if the game is dead, and the score continues to go down, don't add any comment
        if { $prevscore > $::informant("++-") && $tomove == "white" || \
                    $prevscore < [expr 0.0 - $::informant("++-") ] && $tomove == "black" } {
            set isBlunder 0
        }
    } elseif {$annotateBlunders == "notbest"} { ; # not best move option
        if { $deltamove < 0.0 && $tomove == "black" || \
                    $deltamove > 0.0 && $tomove == "white" } {
            set isBlunder 1
        }
    }
    
    set text [format "%+.2f" $score]
    if {$annotateBlunders == "allmoves"} {
        set absdeltamove [expr { abs($deltamove) } ]
        if { $deltamove < [expr 0.0 - $blunderThreshold] && $tomove == "black" || \
                    $deltamove > $blunderThreshold && $tomove == "white" } {
            if {$absdeltamove > $::informant("?!") && $absdeltamove <= $::informant("?")} {
                if { ! $::onlyMarkExercise } {
                    sc_pos addNag "?!"
                }
            } elseif {$absdeltamove > $::informant("?") && $absdeltamove <= $::informant("??")} {
                set exerciseMarked [ markExercise $prevscore $score "?" ]
            } elseif {$absdeltamove > $::informant("??") } {
                set exerciseMarked [ markExercise $prevscore $score "??" ]
            }
        }
        
        if { ! $::onlyMarkExercise } {
            if {! $::isShortAnnotation } {
                sc_pos setComment "[sc_pos getComment] $engine_name: $text"
            } else {
                if {$::addScoreToShortAnnotations} {
                    sc_pos setComment "[sc_pos getComment] $text"
                }
            }
        }
        
        if {$::isBatchOpening} {
            if { [sc_pos moveNumber] < $::isBatchOpeningMoves} {
                appendAnnotator "opBlunder [sc_pos moveNumber] ([sc_pos side])"
                updateBoard -pgn
            }
        }
        
        set nag [ scoreToNag $score ]
        if {$nag != "" && ! $::onlyMarkExercise } {
            sc_pos addNag $nag
        }
        
        sc_move back
        if { $analysis(prevmoves$n) != ""} {
            sc_var create
            set moves $analysis(prevmoves$n)
            sc_move_add $moves $n
            set nag [ scoreToNag $prevscore ]
            if { $nag != "" && ! $::onlyMarkExercise } {
                sc_pos addNag $nag
            }
            sc_var exit
            sc_move forward
        }
    } elseif { $isBlunder } {
        # Add the comment to highlight the blunder
        set absdeltamove [expr { abs($deltamove) } ]
        
        # if the game was won and the score remains high, don't add comment
        if { $score > $::informant("++-") && $tomove == "black" || \
                    $score < [expr 0.0 - $::informant("++-") ] && $tomove == "white" } {
            if {! $::onlyMarkExercise} {
                set text [format "%+.2f (%+.2f)" $prevscore $score]
                if {! $::isShortAnnotation } {
                    sc_pos setComment "[sc_pos getComment] $engine_name: $text"
                }  else {
                    if {$::addScoreToShortAnnotations} {
                        sc_pos setComment "[sc_pos getComment] $text"
                    }
                }
            }
        } else  {
            if {$absdeltamove > $::informant("?!") && $absdeltamove <= $::informant("?")} {
                if { ! $::onlyMarkExercise } {
                    sc_pos addNag "?!"
                }
            } elseif {$absdeltamove > $::informant("?") && $absdeltamove <= $::informant("??")} {
                set exerciseMarked [ markExercise $prevscore $score "?" ]
            } elseif {$absdeltamove > $::informant("??") } {
                set exerciseMarked [ markExercise $prevscore $score "??" ]
            }
            
            if { ! $::onlyMarkExercise || $exerciseMarked } {
                set text [format "%s %+.2f / %+.2f" $::tr(AnnotateBlundersOnlyScoreChange) $prevscore $score]
                if {! $::isShortAnnotation } {
                    sc_pos setComment "[sc_pos getComment] $engine_name: $text"
                } else {
                    if {$::addScoreToShortAnnotations} {
                        sc_pos setComment "[sc_pos getComment] [format %+.2f $score]"
                    }
                }
            }
            
        }
        
        if {$::isBatchOpening} {
            if { [sc_pos moveNumber] < $::isBatchOpeningMoves} {
                appendAnnotator "opBlunder [sc_pos moveNumber] ([sc_pos side])"
                updateBoard -pgn
            }
        }
        
        if { ! $::onlyMarkExercise || $exerciseMarked } {
            
            set nag [ scoreToNag $score ]
            if {$nag != "" && ! $::onlyMarkExercise} {
                sc_pos addNag $nag
            }
            # Rewind, request a diagram
            sc_move back
            sc_pos addNag "D"
            
            # Add the variation:
            if { $analysis(prevmoves$n) != ""} {
                sc_var create
                set moves $analysis(prevmoves$n)
                # Add as many moves as possible from the engine analysis:
                sc_move_add $moves $n
                set nag [ scoreToNag $prevscore ]
                if {$nag != "" } {
                    sc_pos addNag $nag
                }
                sc_var exit
                sc_move forward
            }
        }
    }
    
    set analysis(prevscore$n) $analysis(score$n)
    set analysis(prevmoves$n) $analysis(moves$n)
    
    # Restore the pre-move command:
    sc_info preMoveCmd preMoveCommand
    
    #If an exercise was marked go directly to end of game
    if { $::onlyMarkExercise && $exerciseMarked } {
        ::move::End
    } else  {
        updateBoard -pgn
    }
    
    # Update score graph if it is open:
    if {[winfo exists .sgraph]} { ::tools::graphs::score::Refresh }
}
################################################################################
#
################################################################################
proc scoreToNag {score} {
    if {$score >= $::informant("+-")} {
        return "+-"
    }
    if {$score >= $::informant("+/-")} {
        return "+/-"
    }
    if {$score >= $::informant("+=")} {
        return "+="
    }
    if { $score >= [expr 0.0 - $::informant("+=") ]} {
        return "="
    }
    if {$score <= [expr 0.0 - $::informant("+-") ]} {
        return "-+"
    }
    if {$score <= [expr 0.0 - $::informant("+/-") ]} {
        return "-/+"
    }
    if {$score <= [expr 0.0 - $::informant("+=") ]} {
        return "=+"
    }
    puts "ERROR scoreToNag returned no NAG code"
    return ""
}
################################################################################
# will append arg to current game Annotator tag
################################################################################
proc appendAnnotator { s } {
    set extra [sc_game tags get "Extra"]
    # find Annotator tag
    set oldAnn ""
    set found 0
    foreach line $extra {
        if {$found} {
            set oldAnn $line
            break
        }
        if {[string match "Annotator" $line]} {
            set found 1
            continue
        }
    }
    
    if {$oldAnn != ""} {
        set ann "Annotator \"$oldAnn $s\"\n"
    } else  {
        set ann "Annotator \"$s\"\n"
    }
    sc_game tags set -extra [ list $ann ]
}
################################################################################
#
################################################################################
proc pushAnalysisData { { lastVar } { n 1 } } {
    global analysis
    lappend ::stack [list $analysis(prevscore$n) $analysis(score$n) \
            $analysis(prevmoves$n) $analysis(moves$n) $lastVar ]
}
################################################################################
#
################################################################################
proc popAnalysisData { { n 1 } } {
    global analysis
    # the start of analysis is in the middle of a variation
    if {[llength $::stack] == 0} {
        set analysis(prevscore$n) 0
        set analysis(score$n) 0
        set analysis(prevmoves$n) ""
        set analysis(moves$n) ""
        set lastVar 0
        return
    }
    set tmp [lindex $::stack end]
    set analysis(prevscore$n) [lindex $tmp 0]
    set analysis(score$n) [lindex $tmp 1]
    set analysis(prevmoves$n) [lindex $tmp 2]
    set analysis(moves$n) [lindex $tmp 3]
    set lastVar [lindex $tmp 4]
    set ::stack [lreplace $::stack end end]
    return $lastVar
}

################################################################################
#
################################################################################
proc addAnalysisVariation {{n 1}} {
    global analysis
    
    if {! [winfo exists .analysisWin$n]} { return }
    
    # Cannot add a variation to an empty variation:
    if {[sc_pos isAt vstart]  &&  [sc_pos isAt vend]} { return }
    
    # if we are at the end of the game, we cannot add variation
    # so we add the analysis one move before and append the last game move at the beginning of the analysis
    set addAtEnd [sc_pos isAt vend]
    
    # Temporarily clear the pre-move command since we want to add a
    # whole line without Scid updating stuff:
    sc_info preMoveCmd {}
    
    set moves $analysis(moves$n)
    if {$analysis(uci$n)} {
        set tmp_moves [ lindex [ lindex $analysis(multiPV$n) 0 ] 2 ]
        set text [format "\[%s\] %d:%s" $analysis(name$n) $analysis(depth$n) [scoreToMate $analysis(score$n) $tmp_moves $n]]
    } else  {
        set text [format "\[%s\] %d:%+.2f" $analysis(name$n) $analysis(depth$n) $analysis(score$n)]
    }
    
    if {$addAtEnd} {
        # get the last move of the game
        set lastMove [sc_game info previousMoveUCI]
        #back one move
        sc_move back
    }
    
    # Add the variation:
    sc_var create
    # Add the comment at the start of the variation:
    sc_pos setComment "[sc_pos getComment] $text"
    if {$addAtEnd} {
        # Add the last move of the game at the beginning of the analysis
        sc_move_add $lastMove $n
    }
    # Add as many moves as possible from the engine analysis:
    sc_move_add $moves $n
    sc_var exit
    
    if {$addAtEnd} {
        #forward to the last move
        sc_move forward
    }
    
    # Restore the pre-move command:
    sc_info preMoveCmd preMoveCommand
    
    if {[winfo exists .pgnWin]} { ::pgn::Refresh 1 }
    
    # Update score graph if it is open:
    if {[winfo exists .sgraph]} { ::tools::graphs::score::Refresh }
}
################################################################################
#
################################################################################
proc addAllVariations {{n 1}} {
    global analysis
    
    if {! [winfo exists .analysisWin$n]} { return }
    
    # Cannot add a variation to an empty variation:
    if {[sc_pos isAt vstart]  &&  [sc_pos isAt vend]} { return }
    
    # if we are at the end of the game, we cannot add variation
    # so we add the analysis one move before and append the last game move at the beginning of the analysis
    set addAtEnd [sc_pos isAt vend]
    
    # Temporarily clear the pre-move command since we want to add a
    # whole line without Scid updating stuff:
    sc_info preMoveCmd {}
    
    foreach i $analysis(multiPVraw$n) j $analysis(multiPV$n) {
        set moves [lindex $i 2]
        
        set tmp_moves [ lindex $j 2 ]
        set text [format "\[%s\] %d:%s" $analysis(name$n) [lindex $i 0] [scoreToMate [lindex $i 1] $tmp_moves $n]]
        
        if {$addAtEnd} {
            # get the last move of the game
            set lastMove [sc_game info previousMoveUCI]
            sc_move back
        }
        
        # Add the variation:
        sc_var create
        # Add the comment at the start of the variation:
        sc_pos setComment "[sc_pos getComment] $text"
        if {$addAtEnd} {
            # Add the last move of the game at the beginning of the analysis
            sc_move_add $lastMove $n
        }
        # Add as many moves as possible from the engine analysis:
        sc_move_add $moves $n
        sc_var exit
        
        if {$addAtEnd} {
            #forward to the last move
            sc_move forward
        }
        
    }
    
    # Restore the pre-move command:
    sc_info preMoveCmd preMoveCommand
    
    if {[winfo exists .pgnWin]} { ::pgn::Refresh 1 }
    # Update score graph if it is open:
    if {[winfo exists .sgraph]} { ::tools::graphs::score::Refresh }
}
################################################################################
#
################################################################################
# TODO fonction obsolète à virer ??
proc addAnalysisToComment {line {n 1}} {
    global analysis
    if {! [winfo exists .analysisWin$n]} { return }
    
    # If comment editor window is open, add the score there, otherwise
    # just add the comment directly:
    if {[winfo exists .commentWin]} {
        set tempStr [.commentWin.cf.text get 1.0 "end-1c"]
    } else {
        set tempStr [sc_pos getComment]
    }
    set score $analysis(score$n)
    
    # If line is true, add the whole line, else just add the score:
    if {$line} {
        set scoretext [format "%+.2f: %s" $score $analysis(moves$n)]
    } else {
        set scoretext [format "%+.2f" $score]
    }
    
    # Strip out old score if it exists at the start of the comment:
    regsub {^\".*\"} $tempStr "" tempStr
    set newText "\"$scoretext\"$tempStr"
    if {[winfo exists .commentWin]} {
        .commentWin.cf.text delete 1.0 end
        .commentWin.cf.text insert 1.0 $newText
    } else {
        sc_pos setComment $newText
    }
    ::pgn::Refresh 1
}
################################################################################
#
################################################################################
proc makeAnalysisMove {{n 1}} {
    set s $::analysis(moves$n)
    set res 1
    while {1} {
        if {[string length $s] == 0} { return 0 }
        set c [string index $s 0]
        switch -- $c {
            a - b - c - d - e - f - g - h -
            K - Q - R - B - N - O {
                break
            }
        }
        set s [string range $s 1 end]
    }
    if {[scan $s "%s" move] != 1} { set res 0 }
    set action "replace"
    if {! [sc_pos isAt vend]} {
        set action [confirmReplaceMove]
    }
    if {$action == "cancel"} { return }
    set ::analysis(automoveThinking$n) 0
    if {$action == "var"} { sc_var create }
    if { [sc_move_add $move $n] } { puts "erreur de sc_move_add" ; set res 0 }
    
    updateBoard -pgn -animate
    ::utils::sound::AnnounceNewMove $move
    return $res
}
################################################################################
#
################################################################################

# destroyAnalysisWin:
#   Closes an engine, because its analysis window is being destroyed.
#
proc destroyAnalysisWin {{n 1}} {
    
    global windowsOS analysis annotateModeButtonValue
    
    if { $annotateModeButtonValue } { ; # end annotation
        set annotateModeButtonValue 0
        toggleAutoplay
    }
    
    # Check the pipe is not already closed:
    if {$analysis(pipe$n) == ""} {
        set ::analysisWin$n 0
        return
    }
    
    # Send interrupt signal if the engine wants it:
    if {(!$windowsOS)  &&  $analysis(send_sigint$n)} {
        catch {exec -- kill -s INT [pid $analysis(pipe$n)]}
    }
    
    # Some engines in analyze mode may not react as expected to "quit"
    # so ensure the engine exits analyze mode first:
    if {$analysis(uci$n)} {
        sendToEngine $n "stop"
        sendToEngine $n "quit"
    } else  {
        sendToEngine $n "exit"
        sendToEngine $n "quit"
    }
    catch { flush $analysis(pipe$n) }
    
    # Uncomment the following line to turn on blocking mode before
    # closing the engine (but probably not a good idea!)
    #   fconfigure $analysis(pipe$n) -blocking 1
    
    # Close the engine, ignoring any errors since nothing can really
    # be done about them anyway -- maybe should alert the user with
    # a message box?
    catch {close $analysis(pipe$n)}
    
    if {$analysis(log$n) != ""} {
        catch {close $analysis(log$n)}
        set analysis(log$n) ""
    }
    set analysis(pipe$n) ""
    set ::analysisWin$n 0
    
    ::docking::cleanup ".analysisWin$n"
}

# sendToEngine:
#   Send a command to a running analysis engine.
#
proc sendToEngine {n text} {
    # puts " -------- Scid>> $text"
    logEngine $n "Scid  : $text"
    catch {puts $::analysis(pipe$n) $text}
}

# sendMoveToEngine:
#   Sends a move to a running analysis engine, using sendToEngine.
#   If the engine has indicated (with "usermove=1" on a "feature" line)
#   that it wants it, send with "usermove " before the move.
#
proc sendMoveToEngine {n move} {
    # Convert "e7e8Q" into "e7e8q" since that is the XBoard/WinBoard
    # standard for sending moves in coordinate notation:
    set move [string tolower $move]
    if {$::analysis(uci$n)} {
        # should be position fen [sc_pos fen] moves ?
        sendToEngine $n "position fen [sc_pos fen] moves $move"
    } else  {
        if {$::analysis(wants_usermove$n)} {
            sendToEngine $n "usermove $move"
        } else {
            sendToEngine $n $move
        }
    }
}

# logEngine:
#   Log Scid-Engine communication.
#
proc logEngine {n text} {
    global analysis
    
    # Print the log message to stdout if applicable:
    if {$::analysis(log_stdout)} {
        puts stdout $text
    }
    
    if { [ info exists ::analysis(log$n)] && $::analysis(log$n) != ""} {
        puts $::analysis(log$n) $text
        catch { flush $::analysis(log$n) }
        
        # Close the log file if the limit is reached:
        incr analysis(logCount$n)
        if {$analysis(logCount$n) >= $analysis(logMax)} {
            puts $::analysis(log$n) \
                    "NOTE  : Log file size limit reached; closing log file."
            catch {close $analysis(log$n)}
            set analysis(log$n) ""
        }
    }
}

# logEngineNote:
#   Add a note to the engine comminucation log file.
#
proc logEngineNote {n text} {
    logEngine $n "NOTE  : $text"
}

################################################################################
#
# makeAnalysisWin:
#   Produces the engine list dialog box for choosing an engine,
#   then opens an analysis window and starts the engine.
################################################################################
proc makeAnalysisWin { {n 1} {index -1} } {
    global analysisWin$n font_Analysis analysisCommand analysis annotateModeButtonValue
    set w ".analysisWin$n"
    if {[winfo exists $w]} {
        focus .
        destroy $w
        set analysisWin$n 0
        resetEngine $n
        return
    }
    
    if {$n == 1} { set annotateModeButtonValue 0 }
    
    resetEngine $n
    
    # if parameter index is a valid engine then start engine. Only update engine's time
    # when it was chosen in the engines dialog box
    if { $index < 0 } {
        set index [::enginelist::choose]
        catch {
            ::enginelist::setTime $index
        }
    } else {
        set index [expr {$n - 1}]
    }
    
    if {$index == ""  ||  $index < 0} {
        set analysisWin$n 0
        return
    }
    
    # ::enginelist::setTime $index
    # catch {::enginelist::write}
    
    set analysis(index$n) $index
    set engineData [lindex $::engines(list) $index]
    set analysisName [lindex $engineData 0]
    set analysisCommand [ toAbsPath [lindex $engineData 1] ]
    set analysisArgs [lindex $engineData 2]
    set analysisDir [ toAbsPath [lindex $engineData 3] ]
    set analysis(uci$n) [ lindex $engineData 7 ]
    
    # If the analysis directory is not current dir, cd to it:
    set oldpwd ""
    if {$analysisDir != "."} {
        set oldpwd [pwd]
        catch {cd $analysisDir}
    }
    
    if {! $analysis(uci$n) } {
        set analysis(multiPVCount$n) 1
    }
    
    # Try to execute the analysis program:
    if {[catch {set analysis(pipe$n) [open "| [list $analysisCommand] $analysisArgs" "r+"]} result]} {
        if {$oldpwd != ""} { catch {cd $oldpwd} }
        tk_messageBox -title "Scid: error starting analysis" \
                -icon warning -type ok \
                -message "Unable to start the program:\n$analysisCommand"
        set analysisWin$n 0
        resetEngine $n
        return
    }
    
    set analysisWin$n 1
    
    # Return to original dir if necessary:
    if {$oldpwd != ""} { catch {cd $oldpwd} }
    
    # Open log file if applicable:
    set analysis(log$n) ""
    if {$analysis(logMax) > 0} {
        if {! [catch {open [file join $::scidLogDir "engine$n.log"] w} log]} {
            set analysis(log$n) $log
            logEngine $n "Scid-Engine communication log file"
            logEngine $n "Engine: $analysisName"
            logEngine $n "Command: $analysisCommand"
            logEngine $n "Date: [clock format [clock seconds]]"
            logEngine $n ""
            logEngine $n "This file was automatically generated by Scid."
            logEngine $n "It is rewritten every time an engine is started in Scid."
            logEngine $n ""
        }
    }
    
    set analysis(name$n) $analysisName
    
    # Configure pipe for line buffering and non-blocking mode:
    fconfigure $analysis(pipe$n) -buffering line -blocking 0
    
    #
    # Set up the  analysis window:
    #
    ::createToplevel $w
    
    if {$n == 1} {
        ::setTitle $w "Analysis: $analysisName"
    } else {
        ::setTitle $w "Analysis $n: $analysisName"
    }
    bind $w <F1> { helpWindow Analysis }
    setWinLocation $w
    setWinSize $w
    standardShortcuts $w
    
    ::board::new $w.bd 25
    $w.bd configure -relief solid -borderwidth 1
    set analysis(showBoard$n) 0
    set analysis(showEngineInfo$n) 0
    
    ttk::frame $w.b1
    pack $w.b1 -side bottom -fill x
    
    checkbutton $w.b1.automove -image tb_training  -indicatoron false -height 24 -relief raised -command "toggleAutomove $n" -variable analysis(automove$n)
    ::utils::tooltip::Set $w.b1.automove $::tr(Training)
    
    checkbutton $w.b1.lockengine -image tb_lockengine -indicatoron false -height 24 -width 24 -variable analysis(lockEngine$n) -command "toggleLockEngine $n"
    ::utils::tooltip::Set $w.b1.lockengine $::tr(LockEngine)
    
    button $w.b1.line -image tb_addvar -height 24 -width 24 -command "addAnalysisVariation $n"
    ::utils::tooltip::Set $w.b1.line $::tr(AddVariation)
    
    button $w.b1.alllines -image tb_addallvars -height 24 -width 24 -command "addAllVariations $n"
    ::utils::tooltip::Set $w.b1.alllines $::tr(AddAllVariations)
    
    button $w.b1.move -image tb_addmove -command "makeAnalysisMove $n"
    ::utils::tooltip::Set $w.b1.move $::tr(AddMove)
    
    if {$analysis(uci$n)} {
        set state readonly
    } else  {
        set state disabled
    }
    
    spinbox $w.b1.multipv -from 1 -to 8 -increment 1 -textvariable analysis(multiPVCount$n) -state $state -width 2 \
            -command "changePVSize $n"
    ::utils::tooltip::Set $w.b1.multipv $::tr(Lines)
    
    # add a button to start/stop engine analysis
    button $w.b1.bStartStop -image tb_pause -command "toggleEngineAnalysis $n"
    ::utils::tooltip::Set $w.b1.bStartStop "$::tr(StopEngine) (F[expr 3 + $n])"
    
    if {$n == 1} {
        set ::finishGameMode 0
        button $w.b1.bFinishGame -image finish_off -command "toggleFinishGame $n" -relief flat
        ::utils::tooltip::Set $w.b1.bFinishGame $::tr(FinishGame)
    }
    button $w.b1.showboard -image tb_coords -height 24 -width 24 -command "toggleAnalysisBoard $n"
    ::utils::tooltip::Set $w.b1.showboard $::tr(ShowAnalysisBoard)
    
    checkbutton $w.b1.showinfo -image tb_engineinfo -indicatoron false -height 24 -width 24 -variable analysis(showEngineInfo$n) -command "toggleEngineInfo $n"
    ::utils::tooltip::Set $w.b1.showinfo $::tr(ShowInfo)
    if {!$analysis(uci$n)} {
        $w.b1.showinfo configure -state disabled
        $w.b1.alllines configure -state disabled
    }
    
    if {$n == 1} {
        checkbutton $w.b1.annotate -image tb_annotate -indicatoron false -height 24 -variable annotateModeButtonValue -relief raised -command { configAnnotation }
        ::utils::tooltip::Set $w.b1.annotate $::tr(Annotate...)
    }
    checkbutton $w.b1.priority -image tb_cpu -indicatoron false -relief raised -variable analysis(priority$n) -onvalue idle -offvalue normal \
            -command "setAnalysisPriority $n"
    ::utils::tooltip::Set $w.b1.priority $::tr(LowPriority)
    
    if {$analysis(uci$n)} {
        set state disabled
    } else  {
        set state normal
    }
    
    button $w.b1.update -image tb_update -state $state -command "if {$analysis(uci$n)} {sendToEngine $n .}" ;# UCI does not support . command
    ::utils::tooltip::Set $w.b1.update $::tr(Update)
    
    button $w.b1.help -image tb_help -height 24 -width 24 -command { helpWindow Analysis }
    ::utils::tooltip::Set $w.b1.help $::tr(Help)
    
    if {$n ==1} {
        pack $w.b1.bStartStop $w.b1.lockengine $w.b1.move $w.b1.line $w.b1.alllines $w.b1.multipv $w.b1.annotate $w.b1.automove $w.b1.bFinishGame -side left
    } else  {
        pack $w.b1.bStartStop $w.b1.lockengine $w.b1.move $w.b1.line $w.b1.alllines $w.b1.multipv $w.b1.automove -side left
    }
    pack $w.b1.help $w.b1.priority $w.b1.update $w.b1.showboard $w.b1.showinfo -side right
    if {$analysis(uci$n)} {
        text $w.text -width 60 -height 1 -fg black -bg white -font font_Bold -wrap word -setgrid 1 ;# -spacing3 2
    } else {
        text $w.text -width 60 -height 4 -fg black -bg white -font font_Fixed -wrap word -setgrid 1
    }
    ttk::frame $w.hist
    text $w.hist.text -width 60 -height 8 -fg black -bg white -font font_Fixed \
            -wrap word -setgrid 1 -yscrollcommand "$w.hist.ybar set"
    $w.hist.text tag configure indent -lmargin2 [font measure font_Fixed "xxxxxxxxxxxx"]
    ttk::scrollbar $w.hist.ybar -command "$w.hist.text yview" -takefocus 0
    pack $w.text -side top -fill both
    pack $w.hist -side top -expand 1 -fill both
    pack $w.hist.ybar -side right -fill y
    pack $w.hist.text -side left -expand 1 -fill both
    
    bind $w.hist.text <ButtonPress-$::MB3> "toggleMovesDisplay $n"
    $w.text tag configure blue -foreground blue
    $w.text tag configure bold -font font_Bold
    $w.text tag configure small -font font_Small
    $w.hist.text tag configure blue -foreground blue -lmargin2 [font measure font_Fixed "xxxxxxxxxxxx"]
    $w.hist.text tag configure gray -foreground gray
    $w.text insert end "Please wait a few seconds for engine initialisation (with some engines, you will not see any analysis \
            until the board changes. So if you see this message, try changing the board \
            by moving backward or forward or making a new move.)" small
    $w.text configure -state disabled
    bind $w <Destroy> "destroyAnalysisWin $n"
    bind $w <Configure> "recordWinSize $w"
    bind $w <Escape> "focus .; destroy $w"
    bind $w <Key-a> "$w.b1.bStartStop invoke"
    wm minsize $w 25 0
    bindMouseWheel $w $w.hist.text
    
    if {$analysis(uci$n)} {
        fileevent $analysis(pipe$n) readable "::uci::processAnalysisInput $n"
    } else  {
        fileevent $analysis(pipe$n) readable "processAnalysisInput $n"
    }
    after 1000 "checkAnalysisStarted $n"
    
    # finish MultiPV spinbox configuration
    if {$analysis(uci$n)} {
        # find UCI engine MultiPV capability
        while { ! $analysis(uciok$n) } { ;# done after uciok
            update
            after 200
        }
        set hasMultiPV 0
        foreach opt $analysis(uciOptions$n) {
            if { [lindex $opt 0] == "MultiPV" } {
                set hasMultiPV 1
                set min [lindex $opt 1]
                set max [lindex $opt 2]
                if {$min == ""} { set min 1}
                if {$max == ""} { set max 8}
                break
            }
        }
        set current -1
        set options  [ lindex $engineData 8 ]
        foreach opt $options {
            if {[lindex $opt 0] == "MultiPV"} { set current [lindex $opt 1] ; break }
        }
        if {$current == -1} { set current 1 }
        set analysis(multiPVCount$n) $current
        #    changePVSize $n
        catch {
            if { $hasMultiPV } {
                $w.b1.multipv configure -from $min -to $max -state readonly
            } else  {
                $w.b1.multipv configure -from 1 -to 1 -state disabled
            }
        }
    } ;# end of MultiPV spinbox configuration
    
    # We hope the engine is correctly started at that point, so we can send the first analyze command
    # this problem only happens with winboard engine, as we don't know when they are ready
    if { !$analysis(uci$n) } {
        initialAnalysisStart $n
    }
    # necessary on windows because the UI sometimes starves, also keep latest priority setting
    if {$::windowsOS || $analysis(priority$n) == "idle"} {
        set analysis(priority$n) idle
        setAnalysisPriority $n
    }
    
    catch {
        ::enginelist::sort
        ::enginelist::write
    }
    
}
################################################################################
#
################################################################################
proc toggleMovesDisplay { {n 1} } {
    set ::analysis(movesDisplay$n) [expr 1 - $::analysis(movesDisplay$n)]
    set h .analysisWin$n.hist.text
    $h configure -state normal
    $h delete 1.0 end
    $h configure -state disabled
    updateAnalysisText $n
}

################################################################################
# will truncate PV list if necessary and tell the engine to send N best lines
################################################################################
proc changePVSize { n } {
    global analysis
    if { $analysis(multiPVCount$n) < [llength $analysis(multiPV$n)] } {
        set analysis(multiPV$n) {}
        set analysis(multiPVraw$n) {}
    }
    if {$analysis(multiPVCount$n) == 1} {
        set h .analysisWin$n.hist.text
        $h configure -state normal
        $h delete 0.0 end
        $h configure -state disabled
        set analysis(lastHistory$n) {}
    }
    if { $analysis(uci$n) } {
        # if the UCI engine was analysing, we have to stop/restart it to take into acount the new multiPV option
        if {$analysis(analyzeMode$n)} {
            sendToEngine $n "stop"
            set analysis(waitForBestMove$n) 1
            vwait analysis(waitForBestMove$n)
            sendToEngine $n "setoption name MultiPV value $analysis(multiPVCount$n)"
            sendToEngine $n "position fen [sc_pos fen]"
            sendToEngine $n "go infinite"
        } else  {
            sendToEngine $n "setoption name MultiPV value $analysis(multiPVCount$n)"
        }
    }
}
################################################################################
# setAnalysisPriority
#   Sets the priority class (in Windows) or nice level (in Unix)
#   of a running analysis engine.
################################################################################
proc setAnalysisPriority {n} {
    global analysis
    
    # Get the process ID of the analysis engine:
    if {$analysis(pipe$n) == ""} { return }
    set pidlist [pid $analysis(pipe$n)]
    if {[llength $pidlist] < 1} { return }
    set pid [lindex $pidlist 0]
    
    # Set the priority class (idle or normal):
    if {$::windowsOS} {
        catch {sc_info priority $pid $analysis(priority$n)}
    } else {
        set priority 0
        if {$analysis(priority$n) == "idle"} { set priority 15 }
        catch {sc_info priority $pid $priority}
    }
    
    # Re-read the priority class for confirmation:
    if {[catch {sc_info priority $pid} newpriority]} { return }
    if {$::windowsOS} {
        if {$newpriority == "idle"  ||  $newpriority == "normal"} {
            set analysis(priority$n) $newpriority
        }
    } else {
        set priority normal
        if {$newpriority > 0} { set priority idle }
        set analysis(priority$n) $priority
    }
}
################################################################################
# checkAnalysisStarted
#   Called a short time after an analysis engine was started
#   to send it commands if Scid has not seen any output from
#   it yet.
################################################################################
proc checkAnalysisStarted {n} {
    global analysis
    if {$analysis(seen$n)} { return }
    # Some Winboard engines do not issue any output when
    # they start up, so the fileevent above is never triggered.
    # Most, but not all, of these engines will respond in some
    # way once they have received input of some type.  This
    # proc will issue the same initialization commands as
    # those in processAnalysisInput below, but without the need
    # for a triggering fileevent to occur.
    
    logEngineNote $n {Quiet engine (still no output); sending it initial commands.}
    
    if {$analysis(uci$n)} {
        # in order to get options
        sendToEngine $n "uci"
        # egine should respond uciok
        sendToEngine $n "isready"
        set analysis(seen$n) 1
    } else  {
        sendToEngine $n "xboard"
        sendToEngine $n "protover 2"
        sendToEngine $n "ponder off"
        sendToEngine $n "post"
        # Prevent some engines from making an immediate "book"
        # reply move as black when position is sent later:
        sendToEngine $n "force"
    }
}
################################################################################
# with wb engines, we don't know when the startup phase is over and when the
# engine is ready : so wait for the end of initial output and take some margin
# to issue an analyze command
################################################################################
proc initialAnalysisStart {n} {
    global analysis
    
    update
    
    if { $analysis(processInput$n) == 0 } {
        after 500 initialAnalysisStart $n
        return
    }
    set cl [clock clicks -milliseconds]
    if {[expr $cl - $analysis(processInput$n)] < 1000} {
        after 200 initialAnalysisStart $n
        return
    }
    after 200 startAnalyzeMode $n 1
}
################################################################################
# processAnalysisInput (only for win/xboard engines)
#   Called from a fileevent whenever there is a line of input
#   from an analysis engine waiting to be processed.
################################################################################
proc processAnalysisInput {{n 1}} {
    global analysis
    
    # Get one line from the engine:
    set line [gets $analysis(pipe$n)]
    
    # this is only useful at startup but costs less than 10 microseconds
    set analysis(processInput$n) [clock clicks -milliseconds]
    
    logEngine $n "Engine: $line"
    
    if { ! [ checkEngineIsAlive $n ] } { return }
    
    if {! $analysis(seen$n)} {
        set analysis(seen$n) 1
        # First line of output from the program, so send initial commands:
        logEngineNote $n {First line from engine seen; sending it initial commands now.}
        sendToEngine $n "xboard"
        sendToEngine $n "protover 2"
        sendToEngine $n "ponder off"
        sendToEngine $n "post"
    }
    
    # Check for "feature" commands so we can determine if the engine
    # has the setboard and analyze commands:
    #
    if {! [string compare [string range $line 0 6] "feature"]} {
        if {[string match "*analyze=1*" $line]} { set analysis(has_analyze$n) 1 }
        if {[string match "*setboard=1*" $line]} { set analysis(has_setboard$n) 1 }
        if {[string match "*usermove=1*" $line]} { set analysis(wants_usermove$n) 1 }
        if {[string match "*sigint=1*" $line]} { set analysis(send_sigint$n) 1 }
        if {[string match "*myname=*" $line] } {
            if { !$analysis(wbEngineDetected$n) } { detectWBEngine $n $line  }
            if { [regexp "myname=\"(\[^\"\]*)\"" $line dummy name]} {
                if {$n == 1} {
                    catch {::setTitle .analysisWin$n "Analysis: $name"}
                } else {
                    catch {::setTitle .analysisWin$n "Analysis $n: $name"}
                }
            }
        }
        return
    }
    
    # Check for a line starting with "Crafty", so Scid can work well
    # with older Crafty versions that do not recognize "protover":
    #
    if {! [string compare [string range $line 0 5] "Crafty"]} {
        logEngineNote $n {Seen "Crafty"; assuming analyze and setboard commands.}
        set major 0
        if {[scan $line "Crafty v%d.%d" major minor] == 2  &&  $major >= 18} {
            logEngineNote $n {Crafty version is >= 18.0; assuming scores are from White perspective.}
            set analysis(invertScore$n) 0
        }
        # Turn off crafty logging, to reduce number of junk files:
        sendToEngine $n "log off"
        # Set a fairly low noise value so Crafty is responsive to board changes,
        # but not so low that we get lots of short-ply search data:
        sendToEngine $n "noise 1000"
        set analysis(isCrafty$n) 1
        set analysis(has_setboard$n) 1
        set analysis(has_analyze$n) 1
        return
    }
    
    # Scan the line from the engine for the analysis data:
    #
    set res [scan $line "%d%c %d %d %s %\[^\n\]\n" \
            temp_depth dummy temp_score \
            temp_time temp_nodes temp_moves]
    if {$res == 6} {
        if {$analysis(invertScore$n)  && (![string compare [sc_pos side] "black"])} {
            set temp_score [expr { 0.0 - $temp_score } ]
        }
        set analysis(depth$n) $temp_depth
        set analysis(score$n) $temp_score
        # Convert score to pawns from centipawns:
        set analysis(score$n) [expr {double($analysis(score$n)) / 100.0} ]
        set analysis(moves$n) [formatAnalysisMoves $temp_moves]
        set analysis(time$n) $temp_time
        set analysis(nodes$n) [calculateNodes $temp_nodes]
        
        # Convert time to seconds from centiseconds:
        if {! $analysis(wholeSeconds$n)} {
            set analysis(time$n) [expr {double($analysis(time$n)) / 100.0} ]
        }
        
        updateAnalysisText $n
        
        if {! $analysis(seenEval$n)} {
            # This is the first evaluation line seen, so send the current
            # position details to the engine:
            set analysis(seenEval$n) 1
        }
        
        return
    }
    
    # Check for a "stat01:" line, the reply to the "." command:
    #
    if {! [string compare [string range $line 0 6] "stat01:"]} {
        if {[scan $line "%s %d %s %d" \
                    dummy temp_time temp_nodes temp_depth] == 4} {
            set analysis(depth$n) $temp_depth
            set analysis(time$n) $temp_time
            set analysis(nodes$n) [calculateNodes $temp_nodes]
            # Convert time to seconds from centiseconds:
            if {! $analysis(wholeSeconds$n)} {
                set analysis(time$n) [expr {double($analysis(time$n)) / 100.0} ]
            }
            updateAnalysisText $n
        }
        return
    }
    
    # Check for other engine-specific lines:
    # The following checks are intended to make Scid work with
    # various WinBoard engines that are not properly configured
    # by the "feature" line checking code above.
    #
    # Many thanks to Allen Lake for testing Scid with many
    # WinBoard engines and providing this code and the detection
    # code in wbdetect.tcl
    if { !$analysis(wbEngineDetected$n) } {
        detectWBEngine $n $line
    }
    
}
################################################################################
# returns 0 if engine died abruptly or 1 otherwise
################################################################################
proc checkEngineIsAlive { {n 1} } {
    global analysis
    
    if {[eof $analysis(pipe$n)]} {
        fileevent $analysis(pipe$n) readable {}
        catch {close $analysis(pipe$n)}
        set analysis(pipe$n) ""
        logEngineNote $n {Engine terminated without warning.}
        catch {destroy .analysisWin$n}
        tk_messageBox -type ok -icon info -parent . -title "Scid" \
                -message "The analysis engine terminated without warning; it probably crashed or had an internal error."
        return 0
    }
    return 1
}
################################################################################
# formatAnalysisMoves:
#   Given the text at the end of a line of analysis data from an engine,
#   this proc tries to strip out some extra stuff engines add to make
#   the text more compatible for adding as a variation.
################################################################################
proc formatAnalysisMoves {text} {
    # Yace puts ".", "t", "t-" or "t+" at the start of its moves text,
    # unless directed not to in its .ini file. Get rid of it:
    if {[strIsPrefix ". " $text]} { set text [string range $text 2 end]}
    if {[strIsPrefix "t " $text]} { set text [string range $text 2 end]}
    if {[strIsPrefix "t- " $text]} { set text [string range $text 3 end]}
    if {[strIsPrefix "t+ " $text]} { set text [string range $text 3 end]}
    
    # Trim any initial or final whitespace:
    set text [string trim $text]
    
    # Yace often adds "H" after a move, e.g. "Bc4H". Remove them:
    regsub -all "H " $text " " text
    
    # Crafty adds "<HT>" for a hash table comment. Change it to "{HT}":
    regsub "<HT>" $text "{HT}" text
    
    return $text
}
################################################################################
# will ask engine to play the game till the end
################################################################################
proc toggleFinishGame { { n 1 } } {
    global analysis
    set b ".analysisWin$n.b1.bFinishGame"
    
    if { $::annotateModeButtonValue || $::autoplayMode || !$analysis(analyzeMode$n) || ! [sc_pos isAt vend] } {
        return
    }
    
    if {!$::finishGameMode} {
        set ::finishGameMode 1
        $b configure -image finish_on -relief flat
        after $::autoplayDelay autoplayFinishGame
    } else  {
        set ::finishGameMode 0
        $b configure -image finish_off -relief flat
        after cancel autoplayFinishGame
    }
}
################################################################################
#
################################################################################
proc autoplayFinishGame { {n 1} } {
    if {!$::finishGameMode || ![winfo exists .analysisWin$n]} {return}
    .analysisWin$n.b1.move invoke
    if { [string index [sc_game info previousMove] end] == "#"} {
        toggleFinishGame $n
        return
    }
    after $::autoplayDelay autoplayFinishGame
}
################################################################################
#
################################################################################
proc toggleEngineAnalysis { { n 1 } { force 0 } } {
    global analysis
    set b ".analysisWin$n.b1.bStartStop"
    
    if { $n == 1} {
        if { ($::annotateModeButtonValue || $::finishGameMode) && ! $force } {
            return
        }
    }
    
    if {$analysis(analyzeMode$n)} {
        stopAnalyzeMode $n
        $b configure -image tb_play
        ::utils::tooltip::Set $b "$::tr(StartEngine)"
        # reset lock mode and disable lock button
        set analysis(lockEngine$n) 0
        toggleLockEngine $n
        .analysisWin$n.b1.lockengine configure -relief raised
        .analysisWin$n.b1.lockengine configure -state disabled
    } else  {
        startAnalyzeMode $n
        $b configure -image tb_pause
        ::utils::tooltip::Set $b "$::tr(StopEngine)(a)"
        # enable lock button
        .analysisWin$n.b1.lockengine configure -state normal
    }
}
################################################################################
# startAnalyzeMode:
#   Put the engine in analyze mode.
################################################################################
proc startAnalyzeMode {{n 1} {force 0}} {
    global analysis
    
    # don't start analysis mode when restoring the default layout in docked mode
    if { $::docking::USE_DOCKING && $::docking::restore_running } {
        set b ".analysisWin$n.b1.bStartStop"
        $b configure -image tb_play
        ::utils::tooltip::Set $b "$::tr(StartEngine)"
        # reset lock mode and disable lock button
        set analysis(lockEngine$n) 0
        toggleLockEngine $n
        .analysisWin$n.b1.lockengine configure -relief raised
        .analysisWin$n.b1.lockengine configure -state disabled
        set t .analysisWin$n.text
        $t configure -state normal
        $t delete 0.0 end
        return
    }
    
    # Check that the engine has not already had analyze mode started:
    if {$analysis(analyzeMode$n) && ! $force } { return }
    set analysis(analyzeMode$n) 1
    if { $analysis(uci$n) } {
        set analysis(waitForReadyOk$n) 1
        sendToEngine $n "isready"
        vwait analysis(waitForReadyOk$n)
        sendToEngine $n "position fen [sc_pos fen]"
        sendToEngine $n "go infinite"
        set analysis(fen$n) [sc_pos fen]
        set analysis(maxmovenumber$n) 0
    } else  {
        if {$analysis(has_setboard$n)} {
            sendToEngine $n "setboard [sc_pos fen]"
        }
        if { $analysis(has_analyze$n) } {
            sendToEngine $n "analyze"
        } else  {
            updateAnalysis $n ;# in order to handle special cases (engines without setboard and analyse commands)
        }
    }
}
################################################################################
# stopAnalyzeMode
################################################################################
proc stopAnalyzeMode { {n 1} } {
    global analysis
    if {! $analysis(analyzeMode$n)} { return }
    set analysis(analyzeMode$n) 0
    if { $analysis(uci$n) } {
        sendToEngine $n "stop"
    } else  {
        sendToEngine $n "exit"
    }
}
################################################################################
# toggleLockEngine
#   Toggle whether engine is locked to current position.
################################################################################
proc toggleLockEngine {n} {
    global analysis
    if { $analysis(lockEngine$n) } {
        set state disabled
    } else {
        # when i unlock the engine, i must restart the analysis if the engine is running
        # (it's possible to be here with the engine stopped, if i press the stop button
        #  with the engine locked)
        if {$analysis(analyzeMode$n)} {
            stopAnalyzeMode $n
            startAnalyzeMode $n
        }
        set state normal
    }
    set w ".analysisWin$n"
    $w.b1.move configure -state $state
    $w.b1.line configure -state $state
    if {$analysis(uci$n)} {
        $w.b1.multipv configure -state $state
    }
    $w.b1.alllines configure -state $state
    $w.b1.automove configure -state $state
    if { $n == 1 } {
        $w.b1.annotate configure -state $state
        $w.b1.bFinishGame configure -state $state
    }
}
################################################################################
# updateAnalysisText
#   Update the text in an analysis window.
################################################################################
proc updateAnalysisText {{n 1}} {
    global analysis
    
    set nps 0
    if {$analysis(currmovenumber$n) > $analysis(maxmovenumber$n) } {
        set analysis(maxmovenumber$n) $analysis(currmovenumber$n)
    }
    if {$analysis(time$n) > 0.0} {
        set nps [expr {round($analysis(nodes$n) / $analysis(time$n))} ]
    }
    set score $analysis(score$n)
    
    set t .analysisWin$n.text
    set h .analysisWin$n.hist.text
    
    $t configure -state normal
    $t delete 0.0 end
    
    if { $analysis(uci$n) } {
        if { [expr abs($score)] == 327.0 } {
            if { [catch { set tmp [format "M%d " $analysis(scoremate$n)]} ] } {
                set tmp [format "%+.1f " $score]
            }
        } else {
            set tmp [format "%+.1f " $score]
        }
        $t insert end $tmp
        
        $t insert end "[tr Depth]: "
        if {$analysis(showEngineInfo$n) && $analysis(seldepth$n) != 0} {
            $t insert end [ format "%2u/%u " $analysis(depth$n) $analysis(seldepth$n)] small
        } else {
            $t insert end [ format "%2u " $analysis(depth$n) ] small
        }
        $t insert end "[tr Nodes]: "
        $t insert end [ format "%6uK (%u kn/s) " $analysis(nodes$n) $nps ] small
        $t insert end "[tr Time]: "
        $t insert end [ format "%6.2f s" $analysis(time$n) ] small
        if {$analysis(showEngineInfo$n)} {
            $t insert end "\n" small
            $t insert end "[tr Current]: "
            $t insert end [ format "%s (%s/%s) " [::trans $analysis(currmove$n)] $analysis(currmovenumber$n) $analysis(maxmovenumber$n)] small
            $t insert end "TB Hits: "
            $t insert end [ format "%u " $analysis(tbhits$n)] small
            $t insert end "Nps: "
            $t insert end [ format "%u n/s " $analysis(nps$n)] small
            $t insert end "Hash Full: "
            set hashfull [expr {round($analysis(hashfull$n) / 10)}]
            $t insert end [ format "%u%% " $hashfull ] small
            $t insert end "CPU Load: "
            set cpuload [expr {round($analysis(cpuload$n) / 10)}]
            $t insert end [ format "%u%% " $cpuload ] small
            
            #$t insert end [ format "\nCurrent: %s (%s) - Hashfull: %u - nps: %u - TBhits: %u - CPUload: %u" $analysis(currmove$n) $analysis(currmovenumber$n) $analysis(hashfull$n) $analysis(nps$n) $analysis(tbhits$n) $analysis(cpuload$n) ]
        }
    } else {
        set newStr [format "Depth:   %6u      Nodes: %6uK (%u kn/s)\n" $analysis(depth$n) $analysis(nodes$n) $nps]
        append newStr [format "Score: %+8.2f      Time: %9.2f seconds\n" $score $analysis(time$n)]
        $t insert 1.0 $newStr small
    }
    
    
    if {$analysis(automove$n)} {
        if {$analysis(automoveThinking$n)} {
            set moves "   Thinking..... "
        } else {
            set moves "   Your move..... "
        }
        
        if { ! $analysis(uci$n) } {
            $t insert end $moves blue
        }
        $t configure -state disabled
        updateAnalysisBoard $n ""
        return
    }
    
    if {! $::analysis(movesDisplay$n)}  {
        $h configure -state normal
        $h delete 0.0 end
        $h insert end "     $::tr(ClickHereToSeeMoves)\n" blue
        updateAnalysisBoard $n ""
        $h configure -state disabled
        return
    }
    
    if { $analysis(uci$n) } {
        set moves [ lindex [ lindex $analysis(multiPV$n) 0 ] 2 ]
    } else  {
        set moves $analysis(moves$n)
    }
    
    $h configure -state normal
    set cleared 0
    if { $analysis(depth$n) < $analysis(prev_depth$n)  || $analysis(prev_depth$n) == 0 } {
        $h delete 1.0 end
        set cleared 1
    }
    
    ################################################################################
    if { $analysis(uci$n) } {
        if {$cleared} { set analysis(multiPV$n) {} ; set analysis(multiPVraw$n) {} }
        if {$analysis(multiPVCount$n) == 1} {
            set newhst [format "%2d %s %s" $analysis(depth$n) [scoreToMate $score $moves $n] [addMoveNumbers [::trans $moves]]]
            if {$newhst != $analysis(lastHistory$n) && $moves != ""} {
                $h insert end [format "%s (%.2f)\n" $newhst $analysis(time$n)] indent
                $h see end-1c
                set analysis(lastHistory$n) $newhst
            }
        } else {
            $h delete 1.0 end
            # First line
            set pv [lindex $analysis(multiPV$n) 0]
            catch { set newStr [format "%2d %s " [lindex $pv 0] [scoreToMate $score [lindex $pv 2] $n] ] }
            
            $h insert end "1 " gray
            append newStr "[addMoveNumbers [::trans [lindex $pv 2]]]\n"
            $h insert end $newStr blue
            
            set lineNumber 1
            foreach pv $analysis(multiPV$n) {
                if {$lineNumber == 1} { incr lineNumber ; continue }
                $h insert end "$lineNumber " gray
                set score [scoreToMate [lindex $pv 1] [lindex $pv 2] $n]
                $h insert end [format "%2d %s %s\n" [lindex $pv 0] $score [addMoveNumbers [::trans [lindex $pv 2]]] ] indent
                incr lineNumber
            }
        }
        ################################################################################
    } else  {
        # original Scid analysis display
        $h insert end [format "%2d %+5.2f %s (%.2f)\n" $analysis(depth$n) $score [::trans $moves] $analysis(time$n)] indent
        $h see end-1c
    }
    
    $h configure -state disabled
    set analysis(prev_depth$n) $analysis(depth$n)
    if { ! $analysis(uci$n) } {
        $t insert end [::trans $moves] blue
    }
    # $t tag add score 2.0 2.13
    $t configure -state disabled
    
    updateAnalysisBoard $n $analysis(moves$n)
}
################################################################################
# args = score, pv
# returns M X if mate detected (# or ++) or original score
################################################################################
proc scoreToMate { score pv n } {
    
    if {$::analysis(lockEngine$n)} {
        return [format "%+5.2f" $score]
    }
    
    if { [string index $pv end] == "#" || [string index $pv end] == "+" && [string index $pv end-1] == "+"} {
        set plies [llength $pv]
        
        set mate [expr $plies / 2 + 1 ]
        
        set sign ""
        if {[expr $plies % 2] == 0 && [sc_pos side] == "white" || [expr $plies % 2] == 1 && [sc_pos side] == "black"} {
            set sign "-"
        }
        if {[sc_pos side] == "white" } {
            if { $sign == "" } {
                set mate [expr $plies / 2 + 1 ]
            } else  {
                set mate [expr $plies / 2 ]
            }
        } else  {
            if { $sign == "" } {
                set mate [expr $plies / 2 ]
            } else  {
                set mate [expr $plies / 2 + 1 ]
            }
        }
        
        set ret "M$sign$mate"
    } else  {
        set ret [format "%+5.2f" $score]
    }
    
    return $ret
}
################################################################################
# returns the pv with move numbers added
# ::pgn::moveNumberSpaces controls space between number and move
################################################################################
proc addMoveNumbers { pv } {
    set spc ""
    if {$::pgn::moveNumberSpaces} { set spc " " }
    set n [sc_pos moveNumber]
    set ret ""
    set start 0
    if {[sc_pos side] == "black"} {
        set ret "$n.$spc... [lindex $pv 0] "
        set start 1
        incr n
    }
    for {set i $start} {$i < [llength $pv]} {incr i} {
        set m [lindex $pv $i]
        if { [expr $i % 2] == 0 && $start == 0 || [expr $i % 2] == 1 && $start == 1 } {
            append ret "$n.$spc$m "
        } else  {
            append ret "$m "
            incr n
        }
    }
    return $ret
}
################################################################################
# toggleAnalysisBoard
#   Toggle whether the small analysis board is shown.
################################################################################
proc toggleAnalysisBoard {n} {
    global analysis
    if { $analysis(showBoard$n) } {
        set analysis(showBoard$n) 0
        pack forget .analysisWin$n.bd
        setWinSize .analysisWin$n
        bind .analysisWin$n <Configure> "recordWinSize .analysisWin$n"
    } else {
        bind .analysisWin$n <Configure> ""
        set analysis(showBoard$n) 1
        pack .analysisWin$n.bd -side right -before .analysisWin$n.b1 -padx 4 -pady 4 -anchor n
        update
        .analysisWin$n.hist.text configure -setgrid 0
        .analysisWin$n.text configure -setgrid 0
        set x [winfo reqwidth .analysisWin$n]
        set y [winfo reqheight .analysisWin$n]
        wm geometry .analysisWin$n ${x}x${y}
        .analysisWin$n.hist.text configure -setgrid 1
        .analysisWin$n.text configure -setgrid 1
    }
}
################################################################################
# toggleEngineInfo
#   Toggle whether engine info are shown.
################################################################################
proc toggleEngineInfo {n} {
    global analysis
    if { $analysis(showEngineInfo$n) } {
        .analysisWin$n.text configure -height 2
    } else {
        .analysisWin$n.text configure -height 1
    }
    updateAnalysisText $n
}
################################################################################
#
################################################################################
# updateAnalysisBoard
#   Update the small analysis board in the analysis window,
#   showing the position after making the specified moves
#   from the current main board position.
#
proc updateAnalysisBoard {n moves} {
    global analysis
    # PG : this should not be commented
    if {! $analysis(showBoard$n)} { return }
    
    set bd .analysisWin$n.bd
    # Temporarily wipe the premove command:
    sc_info preMoveCmd {}
    # Push a temporary copy of the current game:
    sc_game push copyfast
    
    # Make the engine moves and update the board:
    sc_move_add $moves $n
    ::board::update $bd [sc_pos board]
    
    # Pop the temporary game:
    sc_game pop
    # Restore pre-move command:
    sc_info preMoveCmd preMoveCommand
}
################################################################################
# updateAnalysis
#   Update an analysis window by sending the current board
#   to the engine.
################################################################################
proc updateAnalysis {{n 1}} {
    global analysisWin analysis windowsOS
    if {$analysis(pipe$n) == ""} { return }
    
    # Just return if no output has been seen from the analysis program yet:
    if {! $analysis(seen$n)} { return }
    
    # No need to update if no analysis is running
    if { ! $analysis(analyzeMode$n) } { return }
    # If too close to the previous update, and no other future update is
    # pending, reschedule this update to occur in another 0.3 seconds:
    #
    if {[catch {set clicks [clock clicks -milliseconds]}]} {
        set clicks [clock clicks]
    }
    set diff [expr {$clicks - $analysis(lastClicks$n)} ]
    if {$diff < 300  &&  $diff >= 0} {
        if {$analysis(after$n) == ""} {
            set analysis(after$n) [after 300 updateAnalysis $n]
        }
        return
    }
    set analysis(lastClicks$n) $clicks
    set analysis(after$n) ""
    after cancel updateAnalysis $n
    
    set old_movelist $analysis(movelist$n)
    set movelist [sc_game moves coord list]
    set analysis(movelist$n) $movelist
    set nonStdStart [sc_game startBoard]
    set old_nonStdStart $analysis(nonStdStart$n)
    set analysis(nonStdStart$n) $nonStdStart
    
    # No need to send current board if engine is locked
    if { $analysis(lockEngine$n) } { return }
    
    if { $analysis(uci$n) } {
        sendToEngine $n "stop"
        set analysis(waitForBestMove$n) 1
        vwait analysis(waitForBestMove$n)
        sendToEngine $n "position fen [sc_pos fen]"
        sendToEngine $n "go infinite"
        set analysis(fen$n) [sc_pos fen]
        set analysis(maxmovenumber$n) 0
    } else {
        # This section is for engines that support "analyze":
        if {$analysis(has_analyze$n)} {
            sendToEngine $n "exit"   ;# Get out of analyze mode, to send moves.
            
            # On Crafty, "force" command has different meaning when not in
            # XBoard mode, and some users have noticed Crafty not being in
            # that mode at this point -- although I cannot reproduce this.
            # So just re-send "xboard" to Crafty to make sure:
            if {$analysis(isCrafty$n)} { sendToEngine $n "xboard" }
            
            sendToEngine $n "force"  ;# Stop engine replying to moves.
            # Check if the setboard command must be used -- that is, if the
            # previous or current position arose from a non-standard start.
            
            #if {$analysis(has_setboard$n)  &&  ($old_nonStdStart  || $nonStdStart)}
            # We skip all code below if the engine has setboard capability : this is provides less error prone behavior
            if {$analysis(has_setboard$n)} {
                sendToEngine $n "setboard [sc_pos fen]"
                # Most engines with setboard do not recognize the crafty "mn"
                # command (it is not in the XBoard/WinBoard protocol), so only send it to crafty:
                if {$analysis(isCrafty$n)} { sendToEngine $n "mn [sc_pos moveNumber]" }
                sendToEngine $n "analyze"
                return
            }
            
            # If we need a non-standard start and the engine does not have
            # setboard, the user is out of luck:
            if {$nonStdStart} {
                set analysis(moves$n) "  Sorry, this game has a non-standard start position."
                updateAnalysisText $n
                return
            }
            
            # Here, the engine has the analyze command (and no setboard) but this game does
            # not have a non-standard start position.
            
            set oldlen [llength $old_movelist]
            set newlen [llength $movelist]
            
            # Check for optimization to minimize the commands to be sent:
            # Scid sends "undo" to backup wherever possible, and avoid "new" as
            # on many engines this would clear hash tables, causing poor
            # hash table performance.
            
            # Send just the new move if possible (if the new move list is exactly
            # the same as the previous move list, with one extra move):
            if {($newlen == $oldlen + 1) && ($old_movelist == [lrange $movelist 0 [expr {$oldlen - 1} ]])} {
                sendMoveToEngine $n [lindex $movelist $oldlen]
                
            } elseif {($newlen + 1 == $oldlen) && ($movelist == [lrange $old_movelist 0 [expr {$newlen - 1} ]])} {
                # Here the new move list is the same as the old list but with one
                # less move, just send one "undo":
                sendToEngine $n "undo"
                
            } elseif {$newlen == $oldlen  &&  $old_movelist == $movelist} {
                
                # Here the board has not changed, so send nothing
                
            } else {
                
                # Otherwise, undo and re-send all moves:
                for {set i 0} {$i < $oldlen} {incr i} {
                    sendToEngine $n "undo"
                }
                foreach m $movelist {
                    sendMoveToEngine $n $m
                }
                
            }
            
            sendToEngine $n "analyze"
            
        } else {
            
            # This section is for engines without the analyze command:
            # In this case, Scid just sends "new", "force" and a bunch
            # of moves, then sets a very long search time/depth and
            # sends "go". This is not ideal but it works OK for engines
            # without "analyze" that I have tried.
            
            # If Unix OS and engine wants it, send an INT signal:
            if {(!$windowsOS)  &&  $analysis(send_sigint$n)} {
                catch {exec -- kill -s INT [pid $analysis(pipe$n)]}
            }
            sendToEngine $n "new"
            sendToEngine $n "force"
            if { $nonStdStart && ! $analysis(has_setboard$n) } {
                set analysis(moves$n) "  Sorry, this game has a non-standard start position."
                updateAnalysisText $n
                return
            }
            if {$analysis(has_setboard$n)} {
                sendToEngine $n "setboard [sc_pos fen]"
            } else  {
                foreach m $movelist {
                    sendMoveToEngine $n $m
                }
            }
            # Set engine to be white or black:
            sendToEngine $n [sc_pos side]
            # Set search time and depth to something very large and start search:
            sendToEngine $n "st 120000"
            sendToEngine $n "sd 50"
            sendToEngine $n "post"
            sendToEngine $n "go"
        }
    }
}
################################################################################
#
################################################################################

set temptime 0
trace variable temptime w {::utils::validate::Regexp {^[0-9]*\.?[0-9]*$}}

proc setAutomoveTime {{n 1}} {
    global analysis temptime dialogResult
    set ::tempn $n
    set temptime [expr {$analysis(automoveTime$n) / 1000.0} ]
    set w .apdialog
    toplevel $w
    #wm transient $w .analysisWin
    ::setTitle $w "Scid: Engine thinking time"
    wm resizable $w 0 0
    ttk::label $w.label -text "Set the engine thinking time per move in seconds:"
    pack $w.label -side top -pady 5 -padx 5
    ttk::entry $w.entry -background white -width 10 -textvariable temptime
    pack $w.entry -side top -pady 5
    bind $w.entry <Escape> { .apdialog.buttons.cancel invoke }
    bind $w.entry <Return> { .apdialog.buttons.ok invoke }
    
    addHorizontalRule $w
    
    set dialogResult ""
    set b [ttk::frame $w.buttons]
    pack $b -side top -fill x
    ttk::button $b.cancel -text $::tr(Cancel) -command {
        focus .
        catch {grab release .apdialog}
        destroy .apdialog
        focus .
        set dialogResult Cancel
    }
    ttk::button $b.ok -text "OK" -command {
        catch {grab release .apdialog}
        if {$temptime < 0.1} { set temptime 0.1 }
        set analysis(automoveTime$tempn) [expr {int($temptime * 1000)} ]
        focus .
        catch {grab release .apdialog}
        destroy .apdialog
        focus .
        set dialogResult OK
    }
    pack $b.cancel $b.ok -side right -padx 5 -pady 5
    focus $w.entry
    update
    catch {grab .apdialog}
    tkwait window .apdialog
    if {$dialogResult != "OK"} {
        return 0
    }
    return 1
}

proc toggleAutomove {{n 1}} {
    global analysis
    if {! $analysis(automove$n)} {
        cancelAutomove $n
    } else {
        set analysis(automove$n) 0
        if {! [setAutomoveTime $n]} {
            return
        }
        set analysis(automove$n) 1
        automove $n
    }
}

proc cancelAutomove {{n 1}} {
    global analysis
    set analysis(automove$n) 0
    after cancel "automove $n"
    after cancel "automove_go $n"
}

proc automove {{n 1}} {
    global analysis autoplayDelay
    if {! $analysis(automove$n)} { return }
    after cancel "automove $n"
    set analysis(automoveThinking$n) 1
    after $analysis(automoveTime$n) "automove_go $n"
}

proc automove_go {{n 1}} {
    global analysis
    if {$analysis(automove$n)} {
        if {[makeAnalysisMove $n]} {
            set analysis(autoMoveThinking$n) 0
            updateBoard -pgn
            after cancel "automove $n"
            ::tree::doTraining $n
        } else {
            after 1000 "automove $n"
        }
    }
}
################################################################################
# If UCI engine, add move through a dedicated function in uci namespace
# returns the error caught by catch
################################################################################
proc sc_move_add { moves n } {
    if { $::analysis(uci$n) } {
        return [::uci::sc_move_add $moves]
    } else  {
        return [ catch { sc_move addSan $moves } ]
    }
}
################################################################################
# append scid directory if path starts with .
################################################################################
proc toAbsPath { path } {
    set new $path
    if {[string index $new 0] == "." } {
        set scidInstallDir [file dirname [info nameofexecutable] ]
        set new [ string replace $new 0 0  $scidInstallDir ]
    }
    return $new
}
################################################################################
#
################################################################################
image create photo tb_cpu -data {
    R0lGODlhGAAYAOeiAAAAAAABAQECAgICAgIDAwUFBQYGBgYHCAgICDE1JzI1JzI2JzM3KDU5
    Kjg8LTk9Ljk9Lzo+MDs/MTtALDxAMj1AMjxCLTxCLj1BMj5CND9FMEJIMkNKM0VMNE5VPFFX
    P1ZfQlheR11mR15TuWBmUGFqSWJoU2FrSmNtS2RtTGNZvGRuTGVvTWVbvWZwTWdxTmddvmlv
    Wml0UGp0UGthwGx2Umx2U2x3Um50YG1jwW14U255U255VG55VW9lwm96VG96VXB7VXB7VnF8
    V3J8WHN5ZnJ9V3J9WHNpxHN+WXR/WnaAXHeBXXl+bHeCXnp/bXlvx3iDX3qAbXuAbnqEYXyB
    b3txyHuFYn2CcHyGY3yGZH1zyX2HZX6HZYGCgYCFdH92yn+JZ4CKaIF4y4GLaYOId4KMa4WO
    boaQcId+zomSc4qTdYuD0IyVd42Vd4+H0pCZe5WUipWVjJKK05KbfpSM1JaO1ZefhJiR1pqT
    152V2KKhmJ+Y2aGa2qOd26af3Kii3a2to6+p4LGs4bax47iz5L29tr245sDAwMTDusXFvMnI
    wMzLw9jSm9nTnNDQx9rTnN7Xn9bVzuLcouTdpOXepOfgpujhpt7e1+nip+rjqODf2uDf3ODg
    3OHg3O3mqu3mq+3mrP//////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////
    /////////////////////////////////yH5BAEKAP8ALAAAAAAYABgAAAj+AP8JHEiwoMGD
    CBMqRAigoUMABh9K/AdAlMWLoiASBNBD0xFQH4mEoojxosaBAG5UqkHphqUZk0iWzLiRwYIG
    DypEkABhgcySEB0ykFJmyhcpRXDEIEERkdOniIKCytTgyR06a9SYMXNFyU+MQZPocIAFzpks
    YboYCfLjq0mKmjI9qOLGDJdOnjY94uHWYtAhQDBgaSNGCydJjBLpoOilsWMvQT9dotAEjZMo
    mBYp2iPjX4FDhAgVKjRIT9AjQjLgIEMliaFAcuKs+GeAECBAfvTgSRNZrokuSYKw1cHiBO1B
    fvrosWNnS9AlNhiEYLJDRooSIkCAoC2oT546deZwQAnakMEHDx04aLAw4cKGfwi62wH/BsnJ
    8gsS5Few/98BQHiAVwcbNJwkEAAyROICJC84gkIj/wjwR4BzvDFGDgEUBEAQn3Do4Sf/EMAH
    GySCYQUMBlIkkUP/DGAFEj7A0IIKI6S40IoNLaTjjjsGBAA7
}
image create photo tb_training -data {
    R0lGODlhGAAYAOeRAGVlZWpnZWhoaG1pZnZrYm5ubnduZYRtWXxwZ3V1dcRkFnl5eYt3aM5r
    G4GBgZF9bYKCgshwKJd+adBvIdRuHIWFhaF+YoaGhpuBbIiIiNtyHqt/XImJicN6P9J2LNd1
    JoqKiouLi8R+Ro2NjY6OjuR4IeR4IuR5IuV5IsuARJCQkJGRkZKSkq2Lb5SUlKeQfZWVlZaW
    luaCMJeXl8yKVJiYmPGBJpmZmfKCJvOCJ5qampycnNGOWb6Ucp2dnduNTp6enp+fn6CgoKGh
    oaKioqSkpOuSSqWlpaampqenp9+ZYaioqKmpqdidbqqqquyZVqurq7iom6ysrK6urtakfK+v
    r7mtpLCwsLKysrOzs7S0tLa2tre3t7i4uLm5ubq6uru7u9a0mcC8ur6+vsDAwMPDw8TExMfH
    x8jIyMnJycrKyt7GssvLy8zMzM/MyM3Nzc7Ozs/Pz9DQ0NHR0dLS0tTU1NXV1dbW1tfX19jY
    2NzX1NnZ2dra2tvb29zc3N3d3d7e3t/f3+Dg4OHh4eLi4uPj4+Tk5OXl5ebm5ufn5+jo6Onp
    6erq6uvr6+zs7O3t7e7u7v//////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////
    /////////////////////////////////yH5BAEKAP8ALAAAAAAYABgAAAj+AP8JHEjwnwEG
    AQoqXPhvQI8nRpQ8YEjxXwsZOXKg+IGg4kIeJWzYMPEBg0eFNDSUKKFhgoSTBS14oEChQQoC
    MAtuiKBAxIGcBSu4sVIEaNA4X4gYJegAqZClAgWQafPFi46TBRA5esRVESI+bfrkYXTIUCE/
    CxQyIRRI0CFIf97YsWNmiqFEYvFMURjoD6BBkCDRQUOmyxUodRohynOHDwCCMAz5+UOIK6E0
    Y7hcGZOokSI8d/DcIFhGD5UmaxI5Wo2I0KJGjRb9uXOnjpqBCQyFOYGjAx9BiBitZqSIEB/Q
    durgqSCwCKA8UV6I4UO9+p48eZDX2f70HxDQd5Jl16EzZ44cOHDetGGjJg2aM2ZGCNxBBsyX
    Llu0ZMFyZYoUJ0wsgUQRRAwRRBAcCBSDGVVxkR9/VfjnxBJJHEGgEEEIwZxAOviwgw431DBD
    DC6wsIIKJIwQAggZXFABBI9BJaNHAQEAOw==
}
image create photo tb_addmove -data {
    R0lGODlhGAAYAOfwABSDDhOFDhWEDxGIDBOHDRiEEheFERKJDROKDRCMDBOLDRaNEhOQDROQ
    DhKRDRCTCxGTDCOIHhGVDBCWCw+XChCYCw+ZCg6bChCaCw+bCxSYDg6cChWYDxaYEBSaDhaa
    EBOeDhafEBybFhKiDSiTIx2cFxGmDBKmDRGnDDSRLxGqDCOeHhGrDCSfHiSfHyWeIxCuCxCv
    CyegIg+yCw+zCyqiJQ63CjyaNwy7CQ27Cg28Ci+lKgu+CBC8DAy/CUOZPwrBCAzACTSmLjWm
    MArECAzDCQvECAzECAzECTenMj6iOwvHCDmoNAnJBwvICDqoNjupNgjMBgrLBwrMBwjOBkSm
    QQnQB06hSQjUBkOsPlShTzyyNwfYBkqrRkauQTW6Mk2uS0yxSE6ySk+ySl6oWlGyTEO8QlKz
    TVKzTmWqYVe1U0q+SUy+Sk2+TE+9TVC9Tl64Wlu7WW2vamC5XGW7YXSxcUzOSmPBYWq9ZlTM
    Unu1d22/ambEZWzCan+2fGrHaHDEbXDEbnXCcWvLam3KbHPHcXjEdXrEdnDMcHfIdXrKeHvK
    enfOdH3Le4bKg4nLhpDOjZLPkJLQkJDVjZfRlIzaipTVkpHZj5zTmZnVl5bZlJ7Um47fjJ7V
    m6DVnZPekZvZmZfdlaLWn6LWoKPWoZ/ZnpTikqTXopzdmqTZoqbYpJnhmKfYpaHdn6nZp57h
    nKnap6bdpKvaqKvaqZrmmandp6Phoq3bq6zcqqDlnq/crajhprDcrqTlo7Hdr7LdsKzhq7Pd
    saLpoKnlqLTesrbetKbppbbftK7lrKvoqrjgt6jsp7PlsbrgubrhuLrhubDor63srLziu7Xo
    tLHrsL7ivb/iva7vrrrouLbrtbTus8PkwsTkwrvrurnuuLXytL3uvMDsv7rxusLuwb/xvszo
    y7z0vMfuxsTxw8H0wMnxyMb0xc3xzMv0ytD0z9T01P//////////////////////////////
    /////////////////////////////////yH5BAEKAP8ALAAAAAAYABgAAAj+AP8JHDjQzBo2
    bdy8IciwocBB79y1W5fO3CKHGP8hYqcOHTlx3xpldEjo3Dhw3rRdUzSy4Z9w3bJRi7YsUUuG
    fLBNg5bMmLBCNwneYYZsWK9ctAIFHRgH2C5br1aZ6oPxRbBt1ZwV84WrVqxWqEJ94mQHBw8g
    RJpEoZIADDdrz479ugUrVSlQmi5VytPDR5ElUqxg4bKhizRlxHTNYjWqUyZLkxh9mWEjh98l
    UwRfqCL3lqtTnjBRkgRoywkVMGhU9oHESWYLSnTJUjVqEyVDZ1p4ADHChIoYqi0fcU1hwZw9
    eNBAEaGhuYbdvVkArxzEiJMJA5xr1w4dhXTVOqpvP/h3QIF58wgYcA/xoYEDCBIqYMiQkYBz
    ETJ2kFgqMICGDisMkUUYN/D3DwAcuPCEGHDgcYWBAJSQxBh0GOIIGQYKUIMXcxwCiShyGGiA
    EGXs8QgpzehhYAFMqCFIJLyU44eB/0SQwg9apFFHRgEBADs=
}
image create photo tb_update -data {
    R0lGODlhGAAYAOfCAEm5Sly3Sme+Qmi/Q2a9XnG/RHTAPXLARXPBRnHBTXLCTnzAP2vCY3fD
    QXbDSH3BQHTDT3zBR3DBaXnEQnfESX7CQXLEV3jFSnbFUYDDQnTFWILEO2/GZnjDXoHEQ4PF
    PHbEZonDO4LFRITGPX7FU3zFWnrFYIrEPIPGRXvDbH/GVHvGYYbHPovFPYTHRnbHbn7HXIfI
    P4zGPoXIR3fIb3zIYnrIaY/HN4nGTo3HQIPGYoHGaZDIOIfKSYTHY3nKcYDKXpHJOYvIUH3I
    d5LKOn7JeJfIOoHJcZDKQ4jKX5PLPIbKZY3KUoTKbJjJO5XMNIjIcZDLTJTMPYXLbYnJcpjK
    RJzLNJXNPprLPZHNTZ3MNYjLe57NNp/ON4rNfYjNg43Nd6DPOaLQMKXNOI7LgqfOL47OeKbO
    OZHMfajPMKfPOqnQMpPOf6rRM6fQRK3SKazSNJPQh5DTgrHRNbTSK6/VLLLSNrXTLa7VN5XT
    ibTTN53Td7bULrfVL7vTL5rTkbzUMKnTbJbWk7jXMZ3WgL7VMcDWJ7fXO7nYMp/VjZ3Vk7/W
    MsHXKLjYPJ7WlMDXNKTXiMHYNcPZK8XbH7/cLKDYlr7YRsnYLL3YTr/ZR6bXlsPbOKrYkcnZ
    OMvaL6bbk8HbSsfdL63ZjKvZks7cJczbMMvbO83cMcXdQ8feO7Lbh8beRdDfKM7eM7PciK/a
    oM3ePbnaibjdfdXdNdHgNdbeNq/dqtXeQNHhQb7ehbzejNniQ7nfrdvjO9jiTNrjRdvkRuTm
    Sv//////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////
    /////////////////////////////////yH+FUNyZWF0ZWQgd2l0aCBUaGUgR0lNUAAh+QQB
    CgD/ACwAAAAAGAAYAAAI/gD/CRxIsKDBgwSLNGEiRBBChENWRMEELBgoCQ8J/jARJZOvXaYe
    dQLFIKNAEpaC3erkZ5CfQ49MBRj4goQGgzbc3HrUBxGfPn4erQIgkEwjXLd6OCoYB4epTnai
    3rFkioNAGLf4WGo1w6AgLKb8RLVDxxQagVNm+XlDdUXBJqHw2Hn0SK4pMwJfeWhFZ26Ygkge
    tWlTatCsQaWODNRU5dEcO546DLRRx8+cR1WOSCFVSwdBKpTsqOnkYSCNR2fGkCrxT5GKNzsI
    yhEzZ86gGAPNMBrDhVFsgVQUFXxiZ8ygJwO9+MGC5ZLih07aYJmDZCCBOm5u9Lnw8EsbLUro
    mZQeGMRKDixjUiDE4CdHjjmsB0KY02LEmg1sDO4QEySEkTBeEJSCEjlsgEMYOYBAhkBbQBCG
    ERlEEUYEBpXAxQYZZBAEF0GgMAJ6IiwwQRUfQHEQCVZkUIADEUzwgQgqGpBEILIId9ArCRgR
    QgE8FiAACTrsEUssvJjUgQM5nJBBEnuIokssoxRpEoNgQMKJKJzYYsuUXBoUEAA7
}
image create photo tb_annotate -data {
    R0lGODlhGAAYAOfzAAAAAAIAAAMAAAYAAAUFBRIMCw4ODisLBBQUFCUSDiIXFR8fHygoKDg4
    OE9BFVpQLlxQK2FWL2JWN2FXOGVZMGZaMrs3GWxfNGFhYWdjWcBGK8FGKm9rY8NMMd9CHsRU
    O3R0cnV0cs9SNcdXPtxQMN9PLnx4b3p6d9xWOHx7echhSslkS4CAf4GAf4KBfuNdP4OCgN9f
    QYODgYSDgYaFgt9jRsxtWIiIhZCKgeVpTuJrUN9yWNB4ZZOTkJSUkd94X916Y5qVipuVit96
    YpuWipiXlJeXl5iXl52Xi5mYkeh5YJ2XjJmYl56Yjed7Y5uZl5+ZjZ+Zjpqal5qamZual5+a
    jqCajpubmaGbj6GbkJycnKGckOeBa6OdkaOdkp6enp+enKOekueDbaSek5+fnqGfnKGgnaGh
    oKGhodeQfaWjoKSko+qMd+KPfamppqqppquqp6urqqyrqKurq6yrqa2rqa2sqe2kPq+vrrCv
    rbCvrrGwrrOyr+eejbOysfCpP7Ozs7SzsbSzsrS0steudLW0srW0s7W1s7W1tLW1tba1tLe2
    tbi3tPOvQrm3tri4trm4uLm5ubq5t/SyRO+0Tbu7ufe1RPK2Tfe1Rb29vO6rm8C/vMDAwMPC
    vsXEwcnJx8rKyM3LyPbSNs3My83Nzc/OytDOyvjYN9DQz9LRzdHR0dPSzvncONTTz9PT0tPT
    09XTztbU0PnfOdfV0dfW0dbW1tjW0djW0tnX09nX1PrkOtrZ1dvZ1fvnO9za1tza2Nzb2Nzb
    2fzpO9zc2t3c2N3c2t7d2fzrPd/e2uDe2t/f3eDf2+Hf2+Hf3OHg3ODg3+Hg3eLh3ePi4OTj
    4OXj4OXk4eTk5Obl4ufm4+jn5Ofn5+np6evq6Ozr6e3s6u3t6+3t7e/v7vDw7vDw8PHw7vLy
    8vPy8fTz8vT09Pb19Pb29vj39vj49/n5+Pn5+fr6+fv7+/z8+/7+/v//////////////////
    /////////////////////////////////yH5BAEKAP8ALAAAAAAYABgAAAj+AP8JHJhAQIAB
    BwYqXKgQgEMdKEigEOGwogEGGBj+A/BKHQBNfdoAWQGglrt27bRZI7WAIQB18wCI+TFkx4gC
    tea1C4dn2zxADRYCmBeTS40YNToUQMMpU6I14+ahm0OgIVEATkpo3aDAFbx25b5UdGg1phIP
    aC0AIJMpU6QzjmTMIDtwqDwAZ9MCQLWunblnvz4B6HUJQN158RCwecH4AwAtlSAtUmQIwDFL
    EAwLHPoOAJscoFUgGHWutDkAwjBd0Lx5HjvPPADwsIFgyiNEgQDomjSBbut0ANIAiANAAwBQ
    5LwBkNVIAgAOrDfOOzcFAAsjTAC0ODIIACtKFQDYPDERfeg5c8o+DSNXTFIwAKf+UABwxQ6O
    8vPEIUJ0qJAgQX4AIModDwAAAgyeBIHfN9504yA32UgDACERACDFG520EgV+3Oyxhx555EEH
    AA44FIILPZixSxb4YXPNi9VQA4xDRVABRyer4IILFOW5Mw0dctRhhxtg3HBCCjT4UIYaatzS
    RHngQNOMM8tEY0wqjPCxSSix8IKLLbMgUZ4qzCSDjDHLEJNLKaZ0yYsvt9ACixDlJRHGGF50
    4cUWWFRhhRVZQAHFEksQkUF0G42l6KK+aeToowEBADs=
}

image create photo tb_play -data {
    R0lGODlhGAAYAKUjAAAAAGxranJxcHt7en18e39+fYKBgIaFg4mIhoyLiY+OjJCPjZmZlp2c
    mqGfnaGgnqWkoaemo6mopbCvrLSzsbWzsba0srm2tLm3tLq5try6t728ucPCv8XDwMfGw8fG
    xNDOzNLRztjX1f//////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////////yH+FUNyZWF0ZWQg
    d2l0aCBUaGUgR0lNUAAh+QQBCgA/ACwAAAAAGAAYAAAGXsCfcEgsGo/IpHLJbDoBziQAGjUC
    BNTqEDAIZLWAAoPwjQIMjcmi3AQcHhQLhL0EICCYjIYDGJkTEhsdIH1VAAoVHiGFhg0XIoyG
    Dh+RhhGVhpiGflpEnJ2goaKjSEEAOw==
}

image create photo tb_pause -data {
    R0lGODlhGAAYAIQcAAAAAHNzcn5+fYSEg4WEg4iIh5GQjqSko6aloqalpKinpqqpp66tqa+u
    rLKwrbWzsLW0s7u6t7+9usC/vsPBvsrKyNHPzNTT0tfV09nY1t7d2/Pz8///////////////
    /yH+FUNyZWF0ZWQgd2l0aCBUaGUgR0lNUAAh+QQBCgAfACwAAAAAGAAYAAAFeOAnjmRpnmiq
    rmzrviYgy9xMs0AwFECt8xycQHHoAYbF4OqYgBgFzR6OsJgYqValCmBoVIzdrzbF9YLNY1RZ
    vJYuEZGLES5PnwD0edy9ZUgwRn6AdjEOFBlGhoiEJQAPFhpGj5GMJDZGNpUjHJycG52dMKKj
    pKUsIQA7
}

image create photo tb_addallvars -data {
    R0lGODdhFAAUAKEDAAAngc4PNNnZ2f///ywAAAAAFAAUAAACN5SPqcvtjwBQ
    0tV0WT43BOQJWxYe4Th56qpOXMrG11Ya5ezan7nj0LuBSIKPYe4nOiKJyKbz
    VwAAOw==
}

image create photo tb_engineinfo -data {
    R0lGODdhFAAUAMIFAAAAAAAA/7i4uMDAwO7v8v///////////ywAAAAAFAAU
    AAADUEgarP6QsNkipIXaR/t2mPeF2jhl5UY2AtG+rXRqQl27sSx+XMVHgKBw
    SAQ8ikihQ2irDZtGRXK6nCKXUEDWNngIgltbsFsFf5nnIERdPRoTADs=
}

image create photo tb_lockengine -data {
    R0lGODlhGAAYAOfHAAAAAAwFABUJAg8PDxUQDBMTExQUFB0XEBwcHCUdFSEhISkhGjIhEC4kGS8l
    GycnJykpKTkrHTU1NTw8PEo5K0VFRW1CFUxMTFZTUl5aVl9fX2FhYGVjYZdcGpddGpheGppeG2pq
    aptgHqNrL6ZxN7B1MKl3PKt4P7J3M7N4NLR4NLN5NLJ6PLJ7O7Z8NrZ9OLZ9Ord9ObR/Q7SBRbmA
    PbSCQLSBRraCQbmBP7qBPrSDSbeDQrqDP7WETLqEQriFRLmFSLaGTLWITbyGRbeHTrqHSryHRryH
    SLqISbmITruJSayMZbyKS76KTLqLUrqMVLqMVZSUlLuNVbuOVryOVsCNUb2OVryPWL2QWMCRVcCS
    Vr+SWsCTWMSSVsGVXMKVXMKWXMOWX56ensaYVsOYYMaYWMeYWMSZYMSZYcaYYaCgoKGhocabZMac
    ZMibZ8ecZcmdYcidZcidZsqdYcieZsifaMqfY8mfaMqebcqfaMuja8yka8ykbMykbc2kbc6ka8yl
    bc6kbsymbc6mb9ClcM+mcM+ncM+ncs+nfNKndtCpcdGodNOqetOqe7KystKtdtOse9Sud9auf9Kv
    hdSwfNavgLa2tre2ttewgNizf9m0hNW2jtq2hde7ldm+mdq+mcPDw+G9lNzAnd/AluDAmeDBmeLC
    m+PCnMjIyOPDnOTEneTGoM/Pz9DQ0OXQs9XV1efSudbW1tjY2OnVvu7Vt+3WuO7Yuu7Yu+7YvO/Y
    u+3ZwN3d3e/avvDav+/bv97e3uHh4eLi4ubm5ufn5+np6e3t7e/v7///////////////////////
    ////////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////////
    /////////////////////////////////////////////////////yH+uihjKSAyMDAwIEpha3Vi
    ICdKaW1tYWMnIFN0ZWluZXIKClRoaXMgaW1hZ2Ugd2FzIGNyZWF0ZWQgdXNpbmcgR2ltcC4gR2lt
    cCBpcyBmcmVlIHNvZnR3YXJlIAphcyBkZWZpbmVkIGJ5IHRoZSBGcmVlIFNvZnR3YXJlIEZvdW5k
    YXRpb24gYW5kIGlzIGF2YWlsYWJsZQpmb3IgZG93bmxvYWQgYXQgaHR0cDovL3d3dy5naW1wLm9y
    ZwAh+QQBCgD/ACwAAAAAGAAYAAAI/gD/CRxIsKDBgwgTKhwIoGHDhQYBKBAjbBgqNQUgMtRQTFis
    V7tkrZkAQKMEY6wuNDQQopWjChABBJMFoaTAASFQRbGZsAAxUDwFIgAmJujBB78sGQUw7JJRggIa
    JNiQYQEBBwkOJKDAAUMEBgEOAvClaxYsV6I8efrkqdOmSYhAPP0HoNeqSpAI3WHTRs4bMlqGuPgw
    FwCuVJUaFcrThk4dOmi4GIkhV+wtU5LwpNkyxQqWK0lm+FDRoTAvVZg4UVL0x4+gPXbM4EjhoXCu
    UozchKHi5IkUKEFk8FghojCuU5I0RTK0Rw8fPXPG5EAxonCtUIvSYCGio4eQIDZYSsAoQaKwLVKN
    Mj0atKcPID5wytB4caIwrVGJAsU54+ULGDBZMOFDEyYUtsQhXVSBxA413PCDEkcUAUQLFsxFl0MY
    ZviQRhx2mFBAADs=
}

###
### End of file: analysis.tcl
###
###
