###
### analysis.tcl: part of Scid.
### Copyright (C) 1999-2002  Shane Hudson.
###

######################################################################
### Analysis window: uses a chess engine to analyze the board.

# analysis(logMax):
#   The maximum number of log message lines to be saved in a log file.
set analysis(logMax) 500

# analysis(log_stdout):
#   Set this to 1 if you want Scid-Engine communication log messages
#   to be echoed to stdout.
#
set analysis(log_stdout) 0


# resetEngine:
#   Resets all engine-specific data.
#
proc resetEngine {n} {
  global analysis
  set analysis(pipe$n) ""             ;# Communication pipe file channel
  set analysis(seen$n) 0              ;# Seen any output from engine yet?
  set analysis(seenEval$n) 0          ;# Seen evaluation line yet?
  set analysis(score$n) 0             ;# Current score in centipawns
  set analysis(nodes$n) 0             ;# Number of nodes searched
  set analysis(depth$n) 0             ;# Depth in ply
  set analysis(prev_depth$n) 0        ;# Previous depth
  set analysis(time$n) 0              ;# Time in centisec (or sec; see below)
  set analysis(moves$n) ""            ;# PV (best line) output from engine
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
}

resetEngine 1
resetEngine 2

set annotateMode 0
set annotateMoves all

# resetAnalysis:
#   Resets the analysis statistics: score, depth, etc.
#
proc resetAnalysis {{n 1}} {
  global analysis
  set analysis(score$n) 0
  set analysis(nodes$n) 0
  set analysis(prev_depth$n) 0
  set analysis(depth$n) 0
  set analysis(time$n) 0
  set analysis(moves$n) ""
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
  lappend engines(list) [list $newEngine(Name) $newEngine(Cmd) \
                           $newEngine(Args) $newEngine(Dir) \
                           $newEngine(Elo) $newEngine(Time) \
                           $newEngine(URL)]
  return 1
}

# ::enginelist::read
#   Reads the user Engine list file.
#
proc ::enginelist::read {} {
  catch {source $::engines(file)}
}

# ::enginelist::write:
#   Writes the user Engine list file.
#
proc ::enginelist::write {} {
  global engines
  # Try to rename old list to backup file and open new file:
  catch {file rename -force $engines(file) $engines(backup)}
  if {[catch {open $engines(file) w} f]} {
    catch {file rename $engines(backup) $engines(file)}
    return 0
  }

  puts $f "\# Analysis engines list file for Scid [sc_info version]"
  puts $f ""
  foreach e $engines(list) {
    set name [lindex $e 0]
    set cmd [lindex $e 1]
    set args [lindex $e 2]
    set dir [lindex $e 3]
    set elo [lindex $e 4]
    set time [lindex $e 5]
    set url [lindex $e 6]
    puts $f "engine {"
    puts $f "  Name [list $name]"
    puts $f "  Cmd  [list $cmd]"
    puts $f "  Args [list $args]"
    puts $f "  Dir  [list $dir]"
    puts $f "  Elo  [list $elo]"
    puts $f "  Time [list $time]"
    puts $f "  URL  [list $url]"
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
  # No engines, so set up a default engine list with Scidlet and Crafty:
  set cmd scidlet
  if {$::windowsOS} { set cmd scidlet.exe }
  engine [list \
    Name Scidlet \
    Cmd  $cmd \
    Dir  . \
  ]
  set cmd crafty
  if {$::windowsOS} { set cmd wcrafty.exe }
  engine [list \
    Name Crafty \
    Cmd  $cmd \
    Dir  . \
    URL  ftp://ftp.cis.uab.edu/pub/hyatt/ \
  ]
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

# ::enginelist::choose
#   Select an engine from the Engine List.
#   Returns an integer index into the engines(list) list variable.
#   If no engine is selected, returns the empty string.
#
proc ::enginelist::choose {} {
  global engines
  set w .enginelist
  toplevel $w
  wm title $w "Scid: [tr ToolsAnalysis]"
   label $w.flabel -text $::tr(EngineList:) -font font_Bold
  pack $w.flabel -side top

  pack [frame $w.buttons] -side bottom -pady 6 -fill x
  frame $w.rule -height 2 -borderwidth 2 -relief sunken -background white
  pack $w.rule -side bottom -fill x -pady 5

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
  pack [frame $f] -side top -expand yes -fill both
  listbox $f.list -height 10 -width 55  -selectmode browse \
    -selectbackground lightBlue -background white -setgrid 1 \
    -yscrollcommand "$f.ybar set" -font font_Fixed -exportselection 0
  bind $f.list <Double-ButtonRelease-1> "$w.buttons.ok invoke; break"
  scrollbar $f.ybar -command "$f.list yview"
  pack $f.ybar -side right -fill y
  pack $f.list -side top -fill both -expand yes
  $f.list selection set 0

  set f $w.buttons
  button $f.add -text $::tr(EngineNew...) -command {::enginelist::edit -1}
  button $f.edit -text $::tr(EngineEdit...) -command {
    ::enginelist::edit [lindex [.enginelist.list.list curselection] 0]
  }
  button $f.delete -text $::tr(Delete...) -command {
    ::enginelist::delete [lindex [.enginelist.list.list curselection] 0]
  }
  label $f.sep -text "   "
  button $f.ok -text "OK" -command {
    set engines(selection) [lindex [.enginelist.list.list curselection] 0]
    destroy .enginelist
  }
  button $f.cancel -text $::tr(Cancel) -command {
    set engines(selection) ""
    destroy .enginelist
  }
  pack $f.cancel $f.ok -side right -padx 1
  pack $f.add $f.edit $f.delete -side left -padx 1

  ::enginelist::sort
  centreWin $w
  focus $w.list.list
  wm protocol $w WM_DELETE_WINDOW "destroy $w"
  bind $w <F1> { helpWindow Analysis List }
  bind $w <Escape> "destroy $w"
  bind $w.list.list <Return> "$w.buttons.ok invoke; break"
  set engines(selection) ""
  grab $w
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

trace variable engines(newElo) w [list forceInt [sc_info limit elo] 0]

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
    set e [list "" "" "" . 0 0 ""]
  }

  set engines(newIndex) $index
  set engines(newName) [lindex $e 0]
  set engines(newCmd) [lindex $e 1]
  set engines(newArgs) [lindex $e 2]
  set engines(newDir) [lindex $e 3]
  set engines(newElo) [lindex $e 4]
  set engines(newTime) [lindex $e 5]
  set engines(newURL) [lindex $e 6]
  set engines(newDate) $::tr(None)
  if {$engines(newTime) > 0 } {
    set engines(newDate) [::enginelist::date $engines(newTime)]
  }

  set w .engineEdit
  toplevel $w
  wm title $w Scid

  set f [frame $w.f]
  pack $f -side top -fill x -expand yes
  set row 0
  foreach i {Name Cmd Args Dir URL} {
    label $f.l$i -text $i
    if {[info exists ::tr(Engine$i)]} {
      $f.l$i configure -text $::tr(Engine$i)
    }
    entry $f.e$i -textvariable engines(new$i) -width 40
    bindFocusColors $f.e$i
    grid $f.l$i -row $row -column 0 -sticky w
    grid $f.e$i -row $row -column 1 -sticky we

    # Browse button for choosing an executable file:
    if {$i == "Cmd"} {
      button $f.b$i -text "..." -command {
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
                              -title "Scid: [tr ToolsAnalysis]" \
                    -filetypes $scid_temp(filetype)]
        if {$scid_temp(cmd) != ""} {
          set engines(newCmd) $scid_temp(cmd)
          if {[string first " " $scid_temp(cmd)] >= 0} {
            # The command contains spaces, so put it in quotes:
            set engines(newCmd) "\"$scid_temp(cmd)\""
          }
          # Set the directory from the executable path if possible:
          set engines(newDir) [file dirname $scid_temp(cmd)]
          if {$engines(newDir) == ""} [ set engines(newDir) .]
        }
      }
      grid $f.b$i -row $row -column 2 -sticky we
    }

    if {$i == "Dir"} {
      button $f.current -text " . " -command {
         set engines(newDir) .
      }
      button $f.user -text "~/.scid" -command {
        set engines(newDir) $scidUserDir
      }
      if {$::windowsOS} {
        $f.user configure -text "scid.exe dir"
      }
      grid $f.current -row $row -column 2 -sticky we
      grid $f.user -row $row -column 3 -sticky we
    }

    if {$i == "URL"} {
      button $f.bURL -text [tr FileOpen] -command {
        if {$engines(newURL) != ""} { openURL $engines(newURL) }
      }
      grid $f.bURL -row $row -column 2 -sticky we
    }

    incr row
  }

  grid columnconfigure $f 1 -weight 1

  # Mark required fields:
  $f.lName configure -font font_Bold
  $f.lCmd configure -font font_Bold
  $f.lDir configure -font font_Bold

  label $f.lElo -text $::tr(EngineElo)
  entry $f.eElo -textvariable engines(newElo) -justify right -width 5
  bindFocusColors $f.eElo
  grid $f.lElo -row $row -column 0 -sticky w
  grid $f.eElo -row $row -column 1 -sticky w
  incr row

  label $f.lTime -text $::tr(EngineTime)
  label $f.eTime -textvariable engines(newDate) -anchor w -width 1
  grid $f.lTime -row $row -column 0 -sticky w
  grid $f.eTime -row $row -column 1 -sticky we
  button $f.clearTime -text $::tr(Clear) -command {
    set engines(newTime) 0
    set engines(newDate) $::tr(None)
  }
  button $f.nowTime -text $::tr(Update) -command {
    set engines(newTime) [clock seconds]
    set engines(newDate) [::enginelist::date $engines(newTime)]
  }
  grid $f.clearTime -row $row -column 2 -sticky we
  grid $f.nowTime -row $row -column 3 -sticky we

  addHorizontalRule $w
  set f [frame $w.buttons]
  button $f.ok -text OK -command {
    if {[string trim $engines(newName)] == ""  ||
        [string trim $engines(newCmd)] == ""  ||
        [string trim $engines(newDir)] == ""} {
      tk_messageBox -title Scid -icon info \
        -message "The Name, Command and Directory fields must not be empty."
    } else {
      set newEntry [list $engines(newName) $engines(newCmd) \
                      $engines(newArgs) $engines(newDir) \
                      $engines(newElo) $engines(newTime) \
                      $engines(newURL)]
      if {$engines(newIndex) < 0} {
        lappend engines(list) $newEntry
      } else {
        set engines(list) [lreplace $engines(list) \
                             $engines(newIndex) $engines(newIndex) $newEntry]
      }
      destroy .engineEdit
      ::enginelist::sort
      ::enginelist::write
    }
  }
  button $f.cancel -text $::tr(Cancel) -command "destroy $w"
  pack $f -side bottom -fill x
  pack $f.cancel $f.ok -side right -padx 2 -pady 2
  label $f.required -font font_Small -text $::tr(EngineRequired)
  pack $f.required -side left
  
  bind $w <Return> "$f.ok invoke"
  bind $w <Escape> "destroy $w"
  bind $w <F1> { helpWindow Analysis List }
  focus $w.f.eName
  wm resizable $w 1 0
  grab $w
}

proc addAnalysisVariation {{n 1}} {
  global analysis annotateMoves annotateMode
  if {! [winfo exists .analysisWin$n]} { return }
  # Cannot add a variation to an empty variation:
  if {[sc_pos isAt vstart]  &&  [sc_pos isAt vend]} { return }
  # Cannot (yet) add a variation at the end of the game or a variation:
  if {[sc_pos isAt vend]} { return }

  set tomove [sc_pos side]
  if {$annotateMode} {
    if {$annotateMoves == "white"  &&  $tomove == "black"} { return }
    if {$annotateMoves == "black"  &&  $tomove == "white"} { return }
  }
  set text [format "%d:%+.2f" $analysis(depth$n) $analysis(score$n)]
  set moves $analysis(moves$n)
  # Temporarily clear the pre-move command since we want to add a
  # whole line without Scid updating stuff:
  sc_info preMoveCmd {}
  # Add the variation:
  sc_var create
  # Add the comment at the start of the variation:
  sc_pos setComment $text
  # Add as many moves as possible from the engine analysis:
  catch {sc_move addSan $moves}
  sc_var exit
  # Remove the variation if necessary:
  if {$annotateMode  &&  $annotateMoves == "notbest"} {
    set lastvar [expr {[sc_var count] - 1} ]
    set firstMove [lindex [sc_var list] $lastvar]
    if {$firstMove == [sc_game info next]} {
      sc_var delete $lastvar
    }
  }
  # Restore the pre-move command:
  sc_info preMoveCmd preMoveCommand
  updateBoard -pgn
  # Update score graph if it is open:
  if {[winfo exists .sgraph]} { updateScoreGraph }
}

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
  if {$analysis(invertScore$n)  && (! [string compare [sc_pos side] "black"])} {
    set score [expr {0.0 - $score} ]
  }

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
  updatePgnWin 1
}

proc makeAnalysisMove {{n 1}} {
  set s $::analysis(moves$n)
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
  if {[scan $s "%s" move] != 1} { return 0 }
  set action "replace"
  if {! [sc_pos isAt vend]} {
      set action [confirmReplaceMove]
  }
  if {$action == "cancel"} { return }
  set ::analysis(automoveThinking$n) 0
  if {$action == "var"} { sc_var create }
  if {[catch {sc_move addSan $move}]} { return 0 }
  updateBoard -pgn
  return 1
}

# destroyAnalysisWin:
#   Closes an engine, because its analysis window is being destroyed.
#
proc destroyAnalysisWin {{n 1}} {
  global windowsOS analysis

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
  sendToEngine $n "exit"
  sendToEngine $n "quit"
  flush $analysis(pipe$n)

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
}

# sendToEngine:
#   Send a command to a running analysis engine.
#
proc sendToEngine {n text} {
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
  if {$::analysis(wants_usermove$n)} {
    sendToEngine $n "usermove $move"
  } else {
    sendToEngine $n $move
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

  if {$::analysis(log$n) != ""} {
    puts $::analysis(log$n) $text

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


# makeAnalysisWin:
#   Produces the engine list dialog box for choosing an engine,
#   then opens an analysis window and starts the engine.
#
proc makeAnalysisWin {{n 1}} {
  global analysisWin$n font_Analysis analysisCommand analysis
  set w ".analysisWin$n"
  if {[winfo exists $w]} {
    focus .
    destroy $w
    set analysisWin$n 0
    resetEngine $n
    return
  }

  resetEngine $n
  set index [::enginelist::choose]
  if {$index == ""  ||  $index < 0} {
    set analysisWin$n 0
    return
  }
  ::enginelist::setTime $index
  catch {::enginelist::write}
  set engineData [lindex $::engines(list) $index]
  set analysisName [lindex $engineData 0]
  set analysisCommand [lindex $engineData 1]
  set analysisArgs [lindex $engineData 2]
  set analysisDir [lindex $engineData 3]
  if {$analysisArgs != ""} {
    append analysisCommand " $analysisArgs"
  }

  # If the analysis directory is not current dir, cd to it:
  set oldpwd ""
  if {$analysisDir != "."} {
    set oldpwd [pwd]
    catch {cd $analysisDir}
  }

  # Try to execute the analysis program:
  if {[catch {set analysis(pipe$n) [open "| $analysisCommand" "r+"]} result]} {
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
    if {! [catch {open [file join $::scidUserDir "engine$n.log"] w} log]} {
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

  # Configure pipe for line buffering and non-blocking mode:
  fconfigure $analysis(pipe$n) -buffering line -blocking 0

  #
  # Set up the  analysis window:
  #
  toplevel $w
  if {$n == 1} {
    wm title $w "Scid: Analysis: $analysisName"
  } else {
    wm title $w "Scid: Analysis $n: $analysisName"
  }
  bind $w <F1> { helpWindow Analysis }
  setWinLocation $w

  ::board::new $w.bd 25
  $w.bd configure -relief solid -borderwidth 1
  set analysis(showBoard$n) 0

  frame $w.b1
  frame $w.b2
  pack $w.b2 -side bottom -fill x
  pack $w.b1 -side bottom -fill x
  checkbutton $w.b1.automove -textvar ::tr(Training) \
    -relief raised -pady 5 -padx 4 \
    -command "toggleAutomove $n" -variable analysis(automove$n)
  button $w.b1.line -textvar ::tr(AddVariation) \
    -command "addAnalysisVariation $n"
  button $w.b1.move -textvar ::tr(AddMove) \
    -command "makeAnalysisMove $n"
  button $w.b1.showboard -image tb_coords -command "toggleAnalysisBoard $n"
  if {$n == 1} {
    checkbutton $w.b2.annotate -textvar ::tr(Annotate...) \
      -variable annotateMode -relief raised -pady 5 -padx 4 \
      -command {toggleAutoplay 1}
  }
  checkbutton $w.b2.priority -text $::tr(LowPriority) \
      -variable analysis(priority$n) -onvalue idle -offvalue normal \
      -command "setAnalysisPriority $n"
  button $w.b2.update -textvar ::tr(Update) \
    -command "sendToEngine $n ."
  button $w.b2.help -textvar ::tr(Help) -command { helpWindow Analysis }
  button $w.b2.close -textvar ::tr(Close) -command "focus .; destroy $w"

  pack $w.b1.automove $w.b1.line $w.b1.move -side left -padx 2 -pady 2
  pack $w.b1.showboard -side right -padx 2 -pady 2
  pack $w.b2.close $w.b2.help $w.b2.update -side right -padx 2 -pady 2
  if {$n == 1} {
    pack $w.b2.annotate -side left -padx 2 -pady 2
  }
  pack $w.b2.priority -side left -padx 2 -pady 2

  text $w.text -width 50 -height 5 -fg black -bg white -font font_Fixed \
    -wrap word
  frame $w.hist
  text $w.hist.text -width 50 -height 4 -fg black -bg white -font font_Fixed \
    -wrap word -setgrid 1 -yscrollcommand "$w.hist.ybar set"
  $w.hist.text tag configure indent -lmargin2 \
    [font measure font_Fixed "xxxxxxxxxx"]
  scrollbar $w.hist.ybar -command "$w.hist.text yview" -takefocus 0
  pack $w.text -side top -fill both
  pack $w.hist -side top -expand 1 -fill both
  pack $w.hist.ybar -side right -fill y
  pack $w.hist.text -side left -expand 1 -fill both
  $w.text tag bind score <ButtonPress-1> "
    set analysis(invertScore$n) \[expr 1 - \$analysis(invertScore$n)\]
    updateAnalysisText $n
  "
  $w.text tag configure blue -foreground blue
  $w.text insert end "With some engines, you will not see any analysis \
until the board changes. So if you see this message, try changing the board \
by moving backwards or forwards or making a new move."
  $w.text configure -state disabled
  bind $w <Destroy> "destroyAnalysisWin $n"
  bind $w <Configure> "recordWinSize $w"
  wm minsize $w 45 0
  bindMouseWheel $w $w.hist.text

  fileevent $analysis(pipe$n) readable "processAnalysisInput $n"

  after 1000 "checkAnalysisStarted $n"
}

# setAnalysisPriority
#   Sets the priority class (in Windows) or nice level (in Unix)
#   of a running analysis engine.
#
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

# checkAnalysisStarted
#   Called a short time after an analysis engine was started
#   to send it commands if Scid has not seen any output from
#   it yet.
#
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
  set analysis(seen$n) 1
  sendToEngine $n "xboard"
  sendToEngine $n "protover 2"
  sendToEngine $n "post"
  # Prevent some engines from making an immediate "book"
  # reply move as black when position is sent later:
  sendToEngine $n "force"
}

# processAnalysisInput
#   Called from a fileevent whenever there is a line of input
#   from an analysis engine waiting to be processed.
#
proc processAnalysisInput {{n 1}} {
  global analysis

  # Get one line from the engine:
  set line [gets $analysis(pipe$n)]
  logEngine $n "Engine: $line"

  # Check that the engine did not terminate unexpectedly:
  if {[eof $analysis(pipe$n)]} {
    fileevent $analysis(pipe$n) readable {}
    catch {close $analysis(pipe$n)}
    set analysis(pipe$n) ""
    logEngineNote $n {Engine terminated without warning.}
    catch {destroy .analysisWin$n}
    tk_messageBox -type ok -icon info -parent . -title "Scid" \
      -message "The analysis engine terminated without warning; it probably crashed or had an internal error."
  }

  if {! $analysis(seen$n)} {
    # First line of output from the program, so send initial commands:
    logEngineNote $n {First line from engine seen; sending it initial commands now.}
    set analysis(seen$n) 1
    sendToEngine $n "xboard"
    sendToEngine $n "protover 2"
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
    if {[string match "*myname=*" $line] && \
        [regexp "myname=\"(\[^\"\]*)\"" $line dummy name]} {
      if {$n == 1} {
        catch {wm title .analysisWin$n "Scid: Analysis: $name"}
      } else {
        catch {wm title .analysisWin$n "Scid: Analysis $n: $name"}
      }
    }
    if {$analysis(has_analyze$n)} { startAnalyzeMode $n }
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
    startAnalyzeMode $n
    return
  }

  # Scan the line from the engine for the analysis data:
  #
  set res [scan $line "%d%c %d %d %d %\[^\n\]\n" \
             temp_depth dummy temp_score \
             temp_time temp_nodes temp_moves]
  if {$res == 6} {
    set analysis(depth$n) $temp_depth
    set analysis(score$n) $temp_score
    set analysis(time$n) $temp_time
    set analysis(nodes$n) $temp_nodes
    set analysis(moves$n) [formatAnalysisMoves $temp_moves]
    # Convert score to pawns from centipawns:
    set analysis(score$n) [expr {double($analysis(score$n)) / 100.0} ]
    # Convert time to seconds from centiseconds:
    if {! $analysis(wholeSeconds$n)} {
      set analysis(time$n) [expr {double($analysis(time$n)) / 100.0} ]
    }
    updateAnalysisText $n
    if {! $analysis(seenEval$n)} {
      # This is the first evaluation line seen, so send the current
      # position details to the engine:
      set analysis(seenEval$n) 1
      updateAnalysis $n
    }
    return
  }

  # Check for a "stat01:" line, the reply to the "." command:
  #
  if {! [string compare [string range $line 0 6] "stat01:"]} {
    if {[scan $line "%s %d %d %d" \
           dummy temp_time temp_nodes temp_depth] == 4} {
      set analysis(depth$n) $temp_depth
      set analysis(time$n) $temp_time
      set analysis(nodes$n) $temp_nodes
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

  if { !$analysis(wbEngineDetected$n) } { detectWBEngine $n $line }
  if { $analysis(has_analyze$n) } { startAnalyzeMode $n }

}

# formatAnalysisMoves:
#   Given the text at the end of a line of analysis data from an engine,
#   this proc tries to strip out some extra stuff engines add to make
#   the text more compatible for adding as a variation.
#
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

# startAnalyzeMode:
#   Put the engine in analyze mode for the first time.
#
proc startAnalyzeMode {{n 1}} {
  global analysis
  # Check that the engine has not already had analyze mode started:
  if {$analysis(analyzeMode$n)} { return }
  set analysis(analyzeMode$n) 1
  set analysis(has_analyze$n) 1
  sendToEngine $n "analyze"
}

# updateAnalysisText
#   Update the text in an analysis window.
#
proc updateAnalysisText {{n 1}} {
  global analysis
  set nps 0
  if {$analysis(time$n) > 0.0} {
    set nps [expr {round($analysis(nodes$n) / $analysis(time$n))} ]
  }
  set newStr [format "Depth:   %6u      Nodes: %8u (%u n/s)\n" \
                $analysis(depth$n) $analysis(nodes$n) $nps]
  set score $analysis(score$n)
  if {$analysis(invertScore$n)  && (![string compare [sc_pos side] "black"])} {
    set score [expr {0.0 - $score} ]
  }
  append newStr [format "Score: %+8.2f      Time: %9.2f seconds\n" \
                   $score $analysis(time$n)]
  set t .analysisWin$n.text
  $t configure -state normal
  $t delete 0.0 end
  $t insert 1.0 $newStr
  if {$analysis(automove$n)} {
    if {$analysis(automoveThinking$n)} {
      set moves "   Thinking..... "
    } else {
      set moves "   Your move..... "
    }
    $t insert end $moves blue
    $t configure -state disabled
    updateAnalysisBoard $n ""
    return
  }

  set moves $analysis(moves$n)
  set h .analysisWin$n.hist.text
  $h configure -state normal
  set cleared 0
  if {$analysis(depth$n) < $analysis(prev_depth$n)  || \
      $analysis(prev_depth$n) == 0} {
    $h delete 1.0 end
    set cleared 1
  }
  if {! $cleared} { $h insert end "\n" }
  $h insert end [format "%2d %+5.2f  %s (%.2f)" $analysis(depth$n) \
                   $score $moves $analysis(time$n)] indent
  $h see end-1c
  $h configure -state disabled
  set analysis(prev_depth$n) $analysis(depth$n)

  $t insert end $moves blue
  $t tag add score 2.0 2.13
  $t configure -state disabled

  updateAnalysisBoard $n $moves
}

# toggleAnalysisBoard
#   Toggle whether the small analysis board is shown.
#
proc toggleAnalysisBoard {n} {
  global analysis
  if {$analysis(showBoard$n)} {
    set analysis(showBoard$n) 0
    pack forget .analysisWin$n.bd
  } else {
    set analysis(showBoard$n) 1
    pack .analysisWin$n.bd -side right -before .analysisWin$n.b2 \
      -padx 4 -pady 4 -anchor n
  }
}

# updateAnalysisBoard
#   Update the small analysis board in the analysis window,
#   showing the position after making the specified moves
#   from the current main board position.
#
proc updateAnalysisBoard {n moves} {
  global analysis
  # if {! $analysis(showBoard$n)} { return }

  set bd .analysisWin$n.bd
  # Temporarily wipe the premove command:
  sc_info preMoveCmd {}
  # Push a temporary copy of the current game:
  sc_game push copy

  # Make the engine moves and update the board:
  catch {sc_move addSan $moves}
  ::board::update $bd [sc_pos board]

  # Pop the temporary game:
  sc_game pop
  # Restore pre-move command:
  sc_info preMoveCmd preMoveCommand
}

# updateAnalysis
#   Update an analysis window by sending the current board
#   to the engine.
#
proc updateAnalysis {{n 1}} {
  global analysisWin analysis windowsOS
  if {$analysis(pipe$n) == ""} { return }
  # Just return if no output has been seen from the analysis program yet:
  if {! $analysis(seen$n)} { return }

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

  if {$analysis(has_analyze$n)} {

    #
    # This section is for engines that support "analyze":
    #

    sendToEngine $n "exit"   ;# Get out of analyze mode, to send moves.

    # On Crafty, "force" command has different meaning when not in
    # XBoard mode, and some users have noticed Crafty not being in
    # that mode at this point -- although I cannot reproduce this.
    # So just re-send "xboard" to Crafty to make sure:
    if {$analysis(isCrafty$n)} { sendToEngine $n "xboard" }

    sendToEngine $n "force"  ;# Stop engine replying to moves.

    # Check if the setboard command must be used -- that is, if the
    # previous or current position arose from a non-standard start.

    if {$analysis(has_setboard$n)  &&  ($old_nonStdStart  || $nonStdStart)} {
      sendToEngine $n "setboard [sc_pos fen]"
      # Most engines with setboard do not recognize the crafty "mn"
      # command (it is not in the XBoard/WinBoard protocol), so
      # only send it to crafty:
      if {$analysis(isCrafty$n)} {
        sendToEngine $n "mn [sc_pos moveNumber]"
      }
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

    # Here, the engine has the analyze command but this game does
    # not have a non-standard start position.

    set oldlen [llength $old_movelist]
    set newlen [llength $movelist]

    # Check for optimization to minimize the commands to be sent:
    # Scid sends "undo" to backup wherever possible, and avoid "new" as
    # on many engines this would clear hash tables, causing poor
    # hash table performance.

    # Send just the new move if possible (if the new move list is exactly
    # the same as the previous move list, with one extra move):

    if {($newlen == $oldlen + 1) \
          && ($old_movelist == [lrange $movelist 0 [expr {$oldlen - 1} ]])} {
      sendMoveToEngine $n [lindex $movelist $oldlen]

    } elseif {($newlen + 1 == $oldlen) && \
                ($movelist == [lrange $old_movelist 0 [expr {$newlen - 1} ]])} {

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
    if {$nonStdStart} {
      set analysis(moves$n) "  Sorry, this game has a non-standard start position."
      updateAnalysisText $n
      return
    }
    foreach m $movelist {
      sendMoveToEngine $n $m
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

set temptime 0
trace variable temptime w {forceRegexp {^[0-9]*\.?[0-9]*$}}

proc setAutomoveTime {{n 1}} {
  global analysis temptime dialogResult
  set ::tempn $n
  set temptime [expr {$analysis(automoveTime$n) / 1000.0} ]
  set w .apdialog
  toplevel $w
  #wm transient $w .analysisWin
  wm title $w "Scid: Engine thinking time"
  wm resizable $w 0 0
  label $w.label -text "Set the engine thinking time per move in seconds:"
  pack $w.label -side top -pady 5 -padx 5
  entry $w.entry -background white -width 10 -textvariable temptime
  pack $w.entry -side top -pady 5
  bind $w.entry <Escape> { .apdialog.buttons.cancel invoke }
  bind $w.entry <Return> { .apdialog.buttons.ok invoke }

  addHorizontalRule $w

  set dialogResult ""
  set b [frame $w.buttons]
  pack $b -side top -fill x
  button $b.cancel -text $::tr(Cancel) -command {
    focus .
    grab release .apdialog
    destroy .apdialog
    focus .
    set dialogResult Cancel
  }
  button $b.ok -text "OK" -command {
    grab release .apdialog
    if {$temptime < 0.1} { set temptime 0.1 }
    set analysis(automoveTime$tempn) [expr {int($temptime * 1000)} ]
    focus .
    grab release .apdialog
    destroy .apdialog
    focus .
    set dialogResult OK
  }
  pack $b.cancel $b.ok -side right -padx 5 -pady 5
  focus $w.entry
  update
#  grab $w
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

###
### End of file: analysis.tcl
###
