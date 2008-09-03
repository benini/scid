### ScidPocket.
### Copyright (C) 2007  Pascal Georges
#
array set informant {}
set informant("!?") 0.5
set informant("?") 1.5
set informant("??") 3.0
set informant("?!") 0.5
set informant("+=") 0.5
set informant("+/-") 1.5
set informant("+-") 3.0
set informant("++-") 5.5

################################################################################
#                        B A S E
################################################################################
namespace eval base { }
################################################################################
proc ::base::baseClose {} {
  
  if {[sc_base inUse]} {
    if {![::game::ConfirmDiscard]} {
      return
    }
    sc_base close
    sc_base switch clipbase
    ::board::updateBoard -nolastmove
    ::board::updateTitle
    ::ui::updateMenus
  }
}
################################################################################
proc ::base::baseIsCompactable {} {
  # Only a database that is in use, not read-only, and not the
  # clipbase, can be compacted:
  if {! [sc_base inUse]} { return 0 }
  if {[sc_base isReadOnly]} { return 0 }
  if {[sc_base current] == [sc_info clipbase]} { return 0 }
  return 1
}
################################################################################
proc ::base::baseCompact {} {
  makeCompactWin
}

################################################################################
# makeCompactWin:
# Opens the database compaction dialog box.
proc ::base::makeCompactWin {} {
  if {! [baseIsCompactable]} {
    tk_messageBox -title "Scid" -type ok -icon info -message "Base not\ncompactable"
    return
  }
  
  set w .compactWin
  toplevel $w
  wm title $w "Scid: Compact database"
  ::ui::setFullSize $w
  
  pack [ttk::notebook $w.nb] -fill both -expand 1
  
  # --------- Names -----------------
  $w.nb add [ttk::frame $w.nb.fnames] -text "Names" -sticky nsew
  set f1 [ttk::frame $w.nb.fnames.f1]
  set f2 [ttk::frame $w.nb.fnames.f2]
  pack $f1 $f2 -fill x
  
  for {set i 0} {$i < 3} {incr i} { grid columnconfigure $f1 $i -weight 1 }
  
  ttk::label $f1.title -text "Name file"
  grid $f1.title -columnspan 3 -row 0 -column 0 -sticky n
  ttk::label $f1.nt -text "  Names"
  grid $f1.nt -row 1 -column 1 -sticky e
  ttk::label $f1.ut -text "  Unused"
  grid $f1.ut -row 1 -column 2 -sticky e
  ttk::frame $f1.h -height 1 -relief solid
  grid $f1.h -columnspan 3 -row 2 -column 0 -sticky we
  set row 3
  set ndata [sc_compact stats names]
  set idx 0
  foreach n {p e s r} name {Players Events Sites Rounds} {
    ttk::label $f1.t$n -text "$name)  "
    ttk::label $f1.n$n -text "  [::utils::thousands [lindex $ndata $idx]]"
    incr idx
    ttk::label $f1.u$n -text "  [::utils::thousands [lindex $ndata $idx]]"
    incr idx
    grid $f1.t$n -row $row -column 0 -sticky w
    grid $f1.n$n -row $row -column 1 -sticky e
    grid $f1.u$n -row $row -column 2 -sticky e
    incr row
  }
  
  ttk::button $f2.n -text "Compact names" -command ::base::compactNames
  ttk::button $f2.cancel -text "Cancel" -command "focus . ; destroy .compactWin"
  pack $f2.n $f2.cancel -side left -fill x
  
  # --------- Games -----------------
  $w.nb add [ttk::frame $w.nb.fgames] -text "Games" -sticky nsew
  
  set f1 [ttk::frame $w.nb.fgames.f1]
  set f2 [ttk::frame $w.nb.fgames.f2]
  pack $f1 $f2 -fill x
  
  for {set i 0} {$i < 3} {incr i} { grid columnconfigure $f1 $i -weight 1 }
  
  ttk::label $f1.title -text "Game file"
  grid $f1.title -columnspan 3 -row 0 -column 0 -sticky n
  ttk::label $f1.gt -text "  [::utils::string::Capital games]"
  grid $f1.gt -row 1 -column 1 -sticky e
  ttk::label $f1.st -text "  Size (kb)"
  grid $f1.st -row 1 -column 2 -sticky e
  ttk::frame $f1.h -height 1 -relief solid
  grid $f1.h -columnspan 3 -row 2 -column 0 -sticky we
  set row 3
  set ndata [sc_compact stats games]
  set idx 0
  foreach g {current compact} name {CurrentState AfterCompaction} {
    ttk::label $f1.t$g -text "$name  "
    ttk::label $f1.g$g -text "  [::utils::thousands [lindex $ndata $idx]]"
    incr idx
    set kbytes [expr {int(([lindex $ndata $idx] + 512) / 1024)} ]
    ttk::label $f1.s$g -text "  [::utils::thousands $kbytes]"
    incr idx
    grid $f1.t$g -row $row -column 0 -sticky w
    grid $f1.g$g -row $row -column 1 -sticky e
    grid $f1.s$g -row $row -column 2 -sticky e
    incr row
  }
  
  ttk::button $f2.n -text "Compact names" -command ::base::compactGames
  ttk::button $f2.cancel -text "Cancel" -command "focus . ; destroy .compactWin"
  pack $f2.n $f2.cancel -side left -fill x
  
}

################################################################################
proc ::base::compactNames {} {
  set w .compactWin
  set stats [sc_compact stats names]
  if {[lindex $stats 1] == 0  &&  [lindex $stats 3] == 0  && \
        [lindex $stats 5] == 0  &&  [lindex $stats 7] == 0} {
    tk_messageBox -type ok -icon info -parent $w -title "Scid: compaction" \
        -message "There are no unused names,\nso the name file is\nalready fully compacted."
    return
  }
  progressWindow "Scid" "Compacting the name file..."
  busyCursor .compactWin
  set err [catch {sc_compact names} result]
  unbusyCursor .compactWin
  closeProgressWindow
  set w .compactWin
  if {$err} {
    tk_messageBox -type ok -icon warning -parent $w \
        -title "Error compacting file" -message $result
  } else {
    tk_messageBox -type ok -icon info -parent $w \
        -title "Name file compacted" \
        -message "The name file for the database\n \"[file tail [sc_base filename]]\"\nwas compacted."
  }
  grab release $w
  destroy $w
  ::board::updateBoard -nolastmove
  ::board::updateTitle
}

################################################################################
proc ::base::compactGames {} {
  set w .compactWin
  set stats [sc_compact stats games]
  if {[lindex $stats 1] == [lindex $stats 3]  && \
        [lindex $stats 0] == [lindex $stats 2]} {
    tk_messageBox -type ok -icon info -parent $w -title "Scid: compaction" \
        -message "The game file is already fully compacted."
    return
  }
  progressWindow "Scid" "Compacting the game file..." "Cancel" "sc_progressBar"
  busyCursor .
  set err [catch {sc_compact games} result]
  unbusyCursor .
  closeProgressWindow
  if {$err} {
    tk_messageBox -type ok -icon warning -parent $w \
        -title "Scid: Error compacting file" -message $result
  } else {
    tk_messageBox -type ok -icon info -parent $w \
        -title "Scid: Game file compacted" \
        -message "The game file for the database\n \"[file tail [sc_base filename]]\"\nwas compacted."
  }
  grab release $w
  destroy $w
  ::board::updateBoard -nolastmove
  ::board::updateTitle
}

################################################################################
proc ::base::baseNew {{fName ""}} {
  if {[sc_base count free] == 0} {
    tk_messageBox -title "Scid" -type ok -icon info -message "Too many databases open\nclose one first"
    return
  }
  set ftype {}
  
  set fName [tk_getSaveFile -initialdir $::initialDir(base) -filetypes $ftype -title "Create database"]
  if {$fName == ""} {
    # do nothing
  } else {
    set fName [file rootname $fName]
    tk_messageBox -title "Scid" -type ok -icon info -message "Creation of $fName"
    if {[catch {sc_base create $fName} result]} {
      tk_messageBox -icon warning -type ok -parent . -title "Unable to create base" -message $result
    }
  }
  ::board::updateBoard -nolastmove
  ::board::updateTitle
  ::ui::updateMenus
}
################################################################################
proc ::base::importPgnFile {} {
  ::importPgnFile
  ::board::updateBoard -nolastmove
  ::board::updateTitle
}
################################################################################
proc ::base::exportPgnFile {} {
  # Check that we have some games to export:
  if {![sc_base inUse]} {
    tk_messageBox -title "Scid: Empty database" -type ok -icon info \
        -message "This is an empty database,\nthere are no games to export."
    return
  }
  if {[sc_filter count] == 0} {
    tk_messageBox -title "Scid: Filter empty" -type ok -icon info -message "The filter contains no games."
    return
  }
  
  set ftype { { "PGN files" {".pgn"} } { "All files" {"*"} } }
  set fName [tk_getSaveFile -initialdir $::initialDir(base) -filetypes $ftype -defaultextension ".pgn" -title "a PGN file"]
  if {$fName == ""} { return }
  
  progressWindow "Scid" "Exporting games..." "Cancel" "sc_progressBar"
  
  sc_base export filter "PGN" $fName -append 0 -starttext "" -endtext "" -comments 1 -variations 1 \
      -space 1 -symbols 1 -indentC 0 -indentV 0 -column 0 -noMarkCodes 0 -convertNullMoves 1
  
  closeProgressWindow
}

################################################################################
proc ::base::baseOpen {{fName ""}} {
  if {[sc_base count free] == 0} {
    tk_messageBox -type ok -icon info -title "Scid" \
        -message "Too many databases are open; close one first"
    return
  }
  
  if {[sc_info gzip]} {
    set ftype {
      { "All Scid files" {".si3" ".si" ".pgn" ".pgn.gz" ".epd" ".epd.gz"} }
      { "Scid databases, PGN files" {".si3" ".si" ".pgn" ".PGN" ".pgn.gz"} }
      { "Scid databases" {".si3" ".si"} }
      { "PGN files" {".pgn" ".PGN" ".pgn.gz"} }
      { "EPD files" {".epd" ".EPD" ".epd.gz"} }
    }
  } else {
    set ftype {
      { "All Scid files" {".si3" ".si" ".pgn" ".epd"} }
      { "Scid databases, PGN files" {".si3" ".si" ".pgn" ".PGN"} }
      { "Scid databases" {".si3" ".si"} }
      { "PGN files" {".pgn" ".PGN"} }
      { "EPD files" {".epd" ".EPD"} }
    }
  }
  if {$fName == ""} {
    set fName [tk_getOpenFile -initialdir $::initialDir(base) -filetypes $ftype -title "Open a Scid file"]
    if {$fName == ""} { return }
  }
  
  if {[file extension $fName] == ""} {
    set fName "$fName.si3"
  }
  
  set err 0
  if {[file extension $fName] == ".si3"} {
    set fName [file rootname $fName]
    if {[catch {launchOpenBase $fName} result]} {
      set err 1
      tk_messageBox -icon warning -type ok -parent . \
          -title "Scid: Error opening file" -message $result
    } else {
      set ::initialDir(base) [file dirname $fName]
      if {$::WindowsCE} {
        tk_messageBox -icon info -type ok -parent . -title "Scid: base loading" -message "[sc_base numGames] games loaded"
      }
    }
  } elseif {[string match "*.epd" [string tolower $fName]]} {
    # EPD file:
    newEpdWin open $fName
  } else {
    # PGN file:
    set result "This file is not readable."
    if {(![file readable $fName])  || \
          [catch {sc_base create $fName true} result]} {
      set err 1
      tk_messageBox -icon warning -type ok -parent . -title "Scid: Error opening file" -message $result
    } else {
      doPgnFileImport $fName "Opening [file tail $fName] read-only...\n"
      sc_base type [sc_base current] 3
    }
  }
  
  if {$err == 0} {
    catch {sc_game load auto}
    ::board::updateBoard -nolastmove
    ::board::updateTitle
    ::addRecentFile $fName
    ::ui::updateMenus
  }
}
################################################################################
proc ::base::launchOpenBase {name} {
  set bsize 0
  set gfile "[file rootname $name].sg3"
  if {! [catch {file size $gfile} err]} { set bsize $err }
  set showProgress 0
  if {$bsize > 10000} { set showProgress 1 }
  if {$showProgress} {
    progressWindow "Scid" "Opening [file tail $name]"
  }
  set err [catch {sc_base open $name} result]
  if {$showProgress} { closeProgressWindow }
  if {$err} { return -code error $result }
  return $result
}
################################################################################
proc ::base::switch {base} {
  sc_base switch $base
  ::board::updateBoard -nolastmove
  ::board::updateTitle
  ::board::updateMenuStates
}
################################################################################
proc ::base::copyFilter {frombaseNum tobaseNum} {
  # Check status of source and target bases:
  set currentBaseNum [sc_base current]
  sc_base switch $frombaseNum
  set nGamesToCopy [sc_filter count]
  set fromInUse [sc_base inUse]
  set fromName [file tail [sc_base filename]]
  sc_base switch $tobaseNum
  set targetInUse [sc_base inUse]
  set targetName [file tail [sc_base filename]]
  set targetReadOnly [sc_base isReadOnly]
  sc_base switch $currentBaseNum
  set err ""
  if {$nGamesToCopy == 0} {
    set err "[::msgcat::mc [list Copy error source]] [::msgcat::mc [list Copy error no game]]"
  }
  if {$targetReadOnly} {
    set err "[::msgcat::mc [list Copy error target]] ($targetName) [::msgcat::mc [list copy error read only]]."
  }
  if {! $targetInUse} {set err "[::msgcat::mc [list Copy error target]] [::msgcat::mc [list Copy error not open]]."}
  if {! $fromInUse} {set err "[::msgcat::mc [list Copy error source]] [::msgcat::mc [list Copy error not open]]."}
  if {$frombaseNum == $tobaseNum} {
    set err "[::msgcat::mc [list Copy error source]] == [::msgcat::mc [list Copy error target]]."
  }
  
  if {$err != ""} {
    tk_messageBox -type ok -icon info -title "Scid" -message "[::msgcat::mc [list Copy error]] \n\"$fromName\" -> \"$targetName\": \n$err"
    return
  }
  
  # If copying to the clipbase, do not bother asking for confirmation:
  if {$tobaseNum == [sc_info clipbase]} {
    progressWindow "Scid" "[::msgcat::mc [list Copy games]]" [::msgcat::mc Cancel] "sc_progressBar"
    set copyErr [catch {sc_filter copy $frombaseNum $tobaseNum} result]
    closeProgressWindow
    if {$copyErr} {
      tk_messageBox -type ok -icon info -title "Scid" -message $result
    }
    return
  }
  
  set w [toplevel .fcopyWin]
  wm title $w "Scid: [::msgcat::mc [list Copy games]]"
  label $w.text -text "[::msgcat::mc [list Copy confirm]]"
  frame $w.b
  dialogbutton $w.b.go -text [::msgcat::mc [list Copy games]] -command "
  $w.b.cancel configure -command sc_progressBar
  $w.b.cancel configure -text [::msgcat::mc Stop]
  sc_progressBar $w.bar bar 301 21 time
  grab $w.b.cancel
  if {[catch {sc_filter copy $frombaseNum $tobaseNum} result]} {
    tk_messageBox -type ok -icon info -title Scid -message $result
  }
  focus .
  destroy $w
  updateStatusBar
  "
  dialogbutton $w.b.cancel -text [::msgcat::mc Cancel] -command "focus .; destroy $w"
  canvas $w.bar -width 200 -height 20 -bg white -relief solid -border 1
  $w.bar create rectangle 0 0 0 0 -fill blue -outline blue -tags bar
  $w.bar create text 195 10 -anchor e -font font_Regular -tags time -fill black -text "0:00 / 0:00"
  
  pack $w.text $w.b -side top -pady 5
  pack $w.bar -side bottom
  pack $w.b.go $w.b.cancel -side left -padx 10 -pady 10
  grab $w
  focus $w.b.go
}

################################################################################
#                   G A M E
################################################################################
namespace eval game {
  
  set bookSlot 2
  set minElo 1200
  set maxElo 2000
  set isOpening 0
  set openingMovesList {}
  set openingMovesHash {}
  set openingMoves ""
  set outOfOpening 0
  set startFromCurrent 0
  set coachIsWatching 0
  set ponder 0
  set lFen {}
  set materialBalance ""
  set lastMove ""
  set lastPlayerMoveUci ""
}
################################################################################
# like "sc_move add" but replicates to external board
proc ::game::moveAdd { move } {
  ::sound::play move
  # ::novag::checkBoardSync
  
  if { [ llength $move ] == 3 } {
    sc_move add [lindex $move 0] [lindex $move 1] [lindex $move 2]
  } else {
    # beware of promote (should be e2e1=Q instead of e2e1q)
    if { [string length $move] == 5 && [lsearch { "Q" "q" "R" "r" "B" "b" "N" "n" } [string index $move end]] != -1 } {
      set move "[string range $move 0 3]=[string toupper [string range $move end end]]"
    }
    # code pour DEBUG Greko (coup a8a8 après la fin de biblio ?)
    if { [ catch { sc_move addSan $move } err ] } {
      tk_messageBox -type ok -icon error -title "Scid" -message "sc_move addSan $move\nerror $err"
    }
  }
  
  if {$::novag::connected} {
    ::novag::addMove [sc_game info previousMoveUCI]
  }
}
################################################################################
proc ::game::gameLoad { selection } {
  # If an invalid game number, just return:
  if {$selection < 1} { return }
  if {$selection > [sc_base numGames]} { return }
  if {![::game::ConfirmDiscard]} { return }
  if {[catch {sc_game load $selection} result]} {
    tk_messageBox -type ok -icon info -title "Scid" -message $result
  }
  ::board::updateTitle
  ::board::updateBoard -nolastmove
}
################################################################################
#   Loads the next or previous filtered game in the database.
#   The parameter <action> should be "previous" or "next".
proc ::game::gameLoadNextPrev {action} {
  if {![sc_base inUse]} {
    return
  }
  set number [sc_filter $action]
  if {$number == 0} {
    return
  }
  gameLoad $number
}
################################################################################
# ::game::ConfirmDiscard
#   Prompts the user if they want to discard the changes to the
#   current game. Returns 1 if they selected yes, 0 otherwise.
proc ::game::ConfirmDiscard {} {
  if {[sc_base isReadOnly]} { return 1 }
  if {! [sc_game altered]} { return 1 }
  set answer [ tk_dialog .cgDialog  [::msgcat::mc "Game new"] \
      [::msgcat::mc "Game modified,\ncontinue and discard\nthe changes ?"] questhead 0 [::msgcat::mc "Yes"] [::msgcat::mc "No"] ]
  if {$answer == 1} { return  0 }
  return 1
}
################################################################################
proc ::game::new {} {
  if {![::game::ConfirmDiscard]} { return }
  sc_game new
  # if in play mode, rewrite game header
  if {$::playMode} {
    setPlayHeaders
  }
  ::board::updateTitle
  ::board::updateBoard -nolastmove
}
################################################################################
proc ::game::setPlayHeaders {} {
  if { $::options(game_limitElo) && $::options(engine1) == "phalanx" } {
    sc_game tags set -event "Game $::options(engine1) $::options(game_Elo)"
  } else {
    sc_game tags set -event "Game $::options(engine1)"
  }
  
  if { $::board::isFlipped } {
    set engine_color w
    set human_color b
  } else {
    set engine_color b
    set human_color w
  }
  
  set t$human_color ""
  
  if {$::options(game_timeMode) == "timebonus"} {
    set tw "[expr $::engine::data(wtime1) / (1000 * 60)]/[expr $::engine::data(winc1) / 1000]"
    set tb "[expr $::engine::data(btime1) / (1000 * 60)]/[expr $::engine::data(binc1) / 1000]"
  } elseif {$::options(game_timeMode) == "depth"} {
    set t$engine_color "depth $::engine::data(fixeddepth1)"
  } elseif {$::options(game_timeMode) == "movetime"} {
    set t$engine_color "[expr $::engine::data(movetime1) / 1000 ] s"
  } elseif {$::options(game_timeMode) == "nodes"} {
    set t$engine_color "nodes $::engine::data(fixednodes1)"
  }
  
  if { $::board::isFlipped } {
    sc_game tags set -white "$::engine::data(name1) ($tw)"
    sc_game tags set -black "[::msgcat::mc Human] ($tb)"
  } else {
    sc_game tags set -white "[::msgcat::mc Human] ($tw)"
    sc_game tags set -black "$::engine::data(name1) ($tb)"
  }
  
  sc_game tags set -date [::utils::date::today]
}
################################################################################
proc ::game::save {} {
  if { [catch {sc_game save [sc_game number] } result ] } {
    tk_messageBox -type ok -icon error -parent . -title "Scid" -message "Error saving game\n$result"
  }
  ::board::updateTitle
}
################################################################################
proc ::game::delete {} {
  set glNumber [sc_game number]
  set flag delete
  # If an invalid game number, just return:
  if {$glNumber < 1} { return }
  if {$glNumber > [sc_base numGames]} { return }
  catch {sc_game flag $flag $glNumber invert}
  ::board::updateTitle
}
################################################################################
proc ::game::gamePrev {} {
  gameLoadNextPrev previous
}
################################################################################
proc ::game::gameNext {} {
  gameLoadNextPrev next
}
################################################################################
proc ::game::random {} {
  set ngames [sc_filter size]
  if {$ngames == 0} { return }
  set r [expr {(int (rand() * $ngames)) + 1} ]
  set gnumber [sc_filter index $r]
  gameLoad $gnumber
}

trace variable ::game::entryLoadNumber w {::utils::validate::Regexp {^[0-9]*$}}
################################################################################
proc ::game::LoadNumber {} {
  set ::game::entryLoadNumber ""
  if {![sc_base inUse]} { return }
  # if {![::game::ConfirmDiscard]} { return }
  if {[sc_base numGames] < 1} { return }
  set w [toplevel .glnumDialog]
  wm title $w [::msgcat::mc "Game number"]
  grab $w
  
  label $w.label -text [::msgcat::mc "Load game number"]
  pack $w.label -side top -pady 5 -padx 5
  
  entry $w.entry -background white -width 10 -textvariable ::game::entryLoadNumber
  pack $w.entry -side top -pady 5
  
  set b [frame $w.buttons]
  pack $b -side top -fill x
  dialogbutton $b.load -text "OK" -command {
    grab release .glnumDialog
    ::game::gameLoad $::game::entryLoadNumber
    focus .
    destroy .glnumDialog
  }
  dialogbutton $b.cancel -text [::msgcat::mc "Cancel"] -command {
    focus .
    grab release .glnumDialog
    destroy .glnumDialog
    focus .
  }
  packbuttons right $b.cancel $b.load
  
  set x [ expr {[winfo width .] / 4 + [winfo rootx .] }]
  set y [ expr {[winfo height .] / 4 + [winfo rooty .] }]
  wm geometry $w "+$x+$y"
  
  focus $w.entry
}

################################################################################
set ::game::gameListHeight 50
set ::game::glOffset 0
################################################################################
proc ::game::refreshGameList {} {
  global ::game::glOffset ::game::gameListHeight
  set lb .gameList.f1.list
  
  if {$glOffset == 0} {
    set glOffset [sc_filter first]
  }
  if {$glOffset == 0} { return }
  set f .gameList.f1.sf.scrolled
  
  $lb delete 0 end
  
  set l1 [split [sc_game list $glOffset $gameListHeight "g\n"] "\n"]
  set l2 [split [sc_game list $glOffset $gameListHeight "w12\n"] "\n"]
  set l3 [split [sc_game list $glOffset $gameListHeight "b12\n"] "\n"]
  set l4 [split [sc_game list $glOffset $gameListHeight "r*\n"] "\n"]
  set l5 [split [sc_game list $glOffset $gameListHeight "o*\n"] "\n"]
  
  for {set i 0} {$i < [expr [llength $l1] -1 ] } {incr i} {
    set white "[lindex $l2 $i]"
    set black "[lindex $l3 $i]"
    $lb insert end "[lindex $l1 $i]: $white - $black [lindex $l4 $i] \[[lindex $l5 $i]\]"
    if { [lindex $l1 $i] == [sc_game number] } {
      $lb selection set $i
    }
  }
}
################################################################################
proc ::game::GameList {} {
  set w .gameList
  if {[winfo exists $w]} {
    focus $w
    return
  }
  toplevel $w
  ::ui::setFullSize $w 0
  
  ttk::frame $w.f1
  
  listbox $w.f1.list -xscrollcommand {.gameList.f1.hs set} -yscrollcommand {.gameList.f1.vs set}
  ttk::scrollbar $w.f1.vs -command {.gameList.f1.list yview}
  ttk::scrollbar $w.f1.hs -command {.gameList.f1.list xview} -orient horizontal
  grid $w.f1.list -row 0 -column 0 -sticky nsew
  grid $w.f1.vs -row 0 -column 1 -sticky ns
  grid $w.f1.hs -row 1 -column 0 -sticky ew
  grid rowconfigure $w.f1 0 -weight 1
  grid columnconfigure $w.f1 0 -weight 1
  
  set ::game::glOffset [sc_game number]
  
  ttk::frame $w.f2
  ttk::button $w.f2.bPrev -image tb_prev -command { ::game::setglOffset -10 }
  ttk::button $w.f2.bNext -image tb_next -command { ::game::setglOffset 10 }
  ttk::button $w.f2.bStart -image tb_start -command { ::game::setglOffset [expr 0 - $::game::gameListHeight] }
  ttk::button $w.f2.bEnd -image tb_end -command { ::game::setglOffset $::game::gameListHeight }
  
  ttk::button $w.f2.bLoad -text Load -command "::game::GameListLoad ; destroy .gameList"
  ttk::button $w.f2.bClose -text Close -command "destroy .gameList"
  pack $w.f2.bStart $w.f2.bPrev $w.f2.bNext $w.f2.bEnd $w.f2.bLoad $w.f2.bClose -side left -fill x
  pack $w.f1 -fill both -expand 1
  pack $w.f2 -fill x
  
  refreshGameList
}
# ----------------------------------------------------------------------------------
proc ::game::setglOffset {delta} {
  incr ::game::glOffset $delta
  if {$::game::glOffset > [expr [sc_base numGames] - $::game::gameListHeight] } {
    set ::game::glOffset [expr [sc_base numGames] - $::game::gameListHeight +1 ]
  }
  if {$::game::glOffset < 1} {
    set ::game::glOffset 1
  }
  ::game::refreshGameList
}
# ----------------------------------------------------------------------------------
proc ::game::GameListLoad {} {
  set lb .gameList.f1.list
  set g [$lb get [$lb curselection] ]
  set num [lindex [split $g ":"] 0]
  ::game::gameLoad $num
}
################################################################################
proc ::game::BoardSetup {} {
  ::setupBoard
  set ::board::lastMoveList {}
  ::board::resetSquaresColor
}
################################################################################
proc ::game::Annotate {} {
  if {$::analyzeMode} {
    set w .analyze
    toplevel $w
    ::ui::setFullSize $w
    
    ttk::label $w.l2 -text [::msgcat::mc "Time (sec)"]
    spinbox $w.sb2 -textvariable ::options(analyze_time) -width 3 -from 5 -to 120 -increment 5 -validate all -vcmd { regexp {^[0-9]+$} %P }
    ttk::label $w.l1 -text [::msgcat::mc "Error threshold"]
    spinbox $w.sb1 -textvariable ::options(analyze_threshold) -width 3 -from 0.1 -to 3.0 -increment 0.1 -validate all -vcmd { regexp {^[0-9]\.[0-9]$} %P }
    ttk::checkbutton $w.cbBook -text [::msgcat::mc "Use book"] -variable ::options(analyze_usebook)
    ttk::button $w.analyze -text [::msgcat::mc Annotate] -command { destroy .analyze ; ::game::analyzeRun }
    ttk::button $w.cancel -text [::msgcat::mc Cancel] -command { set ::analyzeMode 0 ; destroy .analyze }
    
    grid $w.l2 -column 0 -row 0 -sticky ew
    grid $w.sb2 -column 1 -row 0 -sticky ew
    grid $w.l1 -column 0 -row 1 -sticky ew
    grid $w.sb1 -column 1 -row 1 -sticky ew
    grid $w.cbBook -column 0 -row 2 -columnspan 2 -sticky ew
    grid $w.analyze -column 0 -row 3 -sticky ew
    grid $w.cancel -column 1 -row 3 -sticky ew
  } else {
    after cancel ::game::analyzeMove 1
    if { $::engine::data(running1) } { ::board::toggleAnalyze 1 }
  }
}
################################################################################
proc ::game::analyzeRun {} {
  
  sc_move start
  ::board::updateBoard -nolastmove
  
  # book
  if { $::options(analyze_usebook) } {
    
    global ::book::bookMoves
    ::book::scBookOpen $::options(mainBook) $::book::bookSlot
    
    while { ! [sc_pos isAt end] } {
      set bookMoves [sc_book moves $::book::bookSlot]
      set next [sc_game info nextMoveNT]
      if {[lsearch $bookMoves $next] == -1} {
        sc_pos setComment $bookMoves
        break
      }
      sc_move forward
      ::board::updateBoard -nolastmove -nobook
    }
    ::book::closeMainBook
    ::board::updateBoard -nolastmove
  }
  
  # engine
  set n 1
  set ::engine::data(prevscore$n) 0.0
  # set ::engine::data(score$n) 0.0
  set ::engine::data(prevpv$n) {}
  if {! $::engine::data(running$n) } { ::board::toggleAnalyze $n }
  
  after [expr { $::options(analyze_time) * 1000 } ] ::game::analyzeMove $n
  
}
################################################################################
proc ::game::analyzeMove {n} {
  global ::engine::data ::informant
  set blunder 0
  
  set score [lindex [lindex $data(multipv$n) 0] 1]
  
  # white moved
  if { [sc_pos side] == "black" && [expr { $score - $data(prevscore$n)} ] < [expr { 0.0 - $::options(analyze_threshold) } ]} {
    set blunder 1
  }
  # black moved
  if { [sc_pos side] == "white" && [expr { $score - $data(prevscore$n) } ] > $::options(analyze_threshold)} {
    set blunder 1
  }
  
  # if the game is clearly won or lost, do nothing
  if { $score > $informant("++-") && $data(prevscore$n) > $informant("++-") || \
        $score < [ expr { 0.0 - $informant("++-") } ] && $data(prevscore$n) < [ expr { 0.0 - $informant("++-") } ] } {
    set blunder 0
  }
  
  if { $blunder } {
    set delta [expr { abs( $score - $data(prevscore$n) ) } ]
    set nag ""
    if { $delta > $informant("??") } {
      set nag "??"
    } elseif { $delta > $informant("?") } {
      set nag "?"
    } elseif { $delta > $informant("?!") } {
      set nag "?!"
    }
    if {$nag != ""} {sc_pos addNag $nag}
    
    sc_pos setComment "$score ($data(prevscore$n)) [sc_pos getComment]"
    
    sc_move back
    sc_var create
    sc_move addSan $data(prevpv$n)
    sc_var exit
    sc_move forward
  }
  
  set data(prevscore$n) $score
  set data(prevpv$n) [ ::untrans [ lindex [lindex $data(multipv$n) 0] 2 ] ]
  
  sc_move forward
  ::board::updateBoard -nolastmove
  
  if { ! [sc_pos isAt end] && $::analyzeMode } {
    after [expr { $::options(analyze_time) * 1000 } ] ::game::analyzeMove $n
  } else {
    if { $::engine::data(running$n) } { ::board::toggleAnalyze $n }
    set ::analyzeMode 0
  }
}
################################################################################
proc ::game::Play {} {
  if {$::playMode} {
    if { [::engine::isUci 1] } {
      PlayConfig
    } else {
      PlayConfigXBoard
    }
  } else {
    stopPlay 1
  }
}
################################################################################
proc ::game::stopPlay { n } {
  if { [::engine::isUci $n] } {
    after cancel ::game::engineGo $n
  } else {
    after cancel ::game::engineGoXBoard $n
  }
  
  ::engine::sendToEngine "stop" $n
  set ::engine::data(bestmove$n) ""
  
  set ::options(showAnalysis) $::options(showAnalysisOld)
  set ::options(showBook) $::options(showBookOld)
  set ::options(multipv) $::options(multipvOld)
  ::engine::setMultiPv 1
  
  ::infopanel::updateAnalysis
  ::infopanel::updateBookText
  ::gameclock::delete 1
  ::gameclock::delete 2
  # if the opponent was Phalanx, put it back at full strength
  if {$::options(game_limitElo) && $::options(engine1) == "phalanx"} {
    ::engine::sendToEngine "elevel 0" $n
  }
  wm title . "Scid"
}
################################################################################
proc ::game::PlayConfig {} {
  set w ".configSerGameWin"
  if {[winfo exists $w]} {
    focus $w
    return
  }
  
  toplevel $w
  wm title $w [::msgcat::mc "Configure Game"]
  ::ui::setFullSize $w
  
  set ::options(limitElo) 0
  
  ttk::frame $w.fnb
  ttk::frame $w.fdown
  
  pack [ttk::notebook $w.fnb.nb] -fill both -expand 1
  
  # --------------- Time frame ---------------------
  $w.fnb.nb add [ttk::frame $w.fnb.nb.time] -text [::msgcat::mc "time"]
  set nb1 $w.fnb.nb.time
  
  set row 0
  
  ttk::radiobutton $nb1.rb1 -text [::msgcat::mc "Time bonus"] -value "timebonus" -variable ::options(game_timeMode)
  grid $nb1.rb1 -row $row -column 0 -sticky w
  incr row
  ttk::label $nb1.lb1 -text [::msgcat::mc "White time"]
  grid $nb1.lb1 -row $row -column 0 -sticky w
  incr row
  spinbox $nb1.spW1 -textvar ::options(game_wtime) -background white -width 4 -from 1 -to 120 -increment 1 -validate all -vcmd { regexp {^[0-9]+$} %P }
  spinbox $nb1.spW2 -textvar ::options(game_winc) -background white -width 4 -from 0 -to 60 -increment 1 -validate all -vcmd { regexp {^[0-9]+$} %P }
  grid $nb1.spW1 -row $row -column 0 -sticky w
  grid $nb1.spW2  -row $row -column 1 -sticky w
  incr row
  
  ttk::label $nb1.lb2 -text [::msgcat::mc "Black time"]
  grid $nb1.lb2 -row $row -column 0 -sticky w
  incr row
  spinbox $nb1.spB1 -textvar ::options(game_btime) -background white -width 4 -from 1 -to 120 -increment 1 -validate all -vcmd { regexp {^[0-9]+$} %P }
  spinbox $nb1.spB2 -textvar ::options(game_binc) -background white -width 4 -from 0 -to 60 -increment 1 -validate all -vcmd { regexp {^[0-9]+$} %P }
  grid $nb1.spB1 -row $row -column 0 -sticky w
  grid $nb1.spB2  -row $row -column 1 -sticky w
  incr row
  
  ttk::radiobutton $nb1.rb2 -text [::msgcat::mc "Fixed depth"] -value "depth" -variable ::options(game_timeMode)
  spinbox $nb1.sbDepth -textvar ::options(game_fixeddepth) -background white -width 2 -from 1 -to 20 -increment 1 -validate all -vcmd { regexp {^[0-9]+$} %P }
  
  ttk::radiobutton $nb1.rb3 -text [::msgcat::mc "Nodes (x1000)"] -value "nodes" -variable ::options(game_timeMode)
  spinbox $nb1.sbNodes -textvar ::options(game_fixednodes) -background white -width 5 -from 5 -to 10000 -increment 5 -validate all -vcmd { regexp {^[0-9]+$} %P }
  
  ttk::radiobutton $nb1.rb4 -text [::msgcat::mc "Sec / move"] -value "movetime" -variable ::options(game_timeMode)
  spinbox $nb1.sbMoveTime -textvar ::options(game_movetime) -background white -width 3 -from 1 -to 120 -increment 1 -validate all -vcmd { regexp {^[0-9]+$} %P }
  
  grid $nb1.rb2 -row $row -column 0 -sticky w
  grid $nb1.sbDepth -row $row -column 1 -sticky w
  incr row
  grid $nb1.rb3 -row $row -column 0 -sticky w
  grid $nb1.sbNodes -row $row -column 1 -sticky w
  incr row
  grid $nb1.rb4 -row $row -column 0 -sticky w
  grid $nb1.sbMoveTime -row $row -column 1 -sticky w
  incr row
  
  ttk::checkbutton $nb1.cbEgt -text [::msgcat::mc "Add elapsed game time"] -variable ::options(game_elapsedGameTime)
  grid $nb1.cbEgt -row $row -column 0 -sticky w -columnspan 2
  incr row
  
  # --------------- Other settings frame -----------
  $w.fnb.nb add [ttk::frame $w.fnb.nb.settings] -text [::msgcat::mc "settings"]
  set nb2 $w.fnb.nb.settings
  
  ttk::frame $nb2.fbook -relief groove -borderwidth 1
  ttk::frame $nb2.ftime -relief groove -borderwidth 1
  ttk::frame $nb2.fopening -relief groove -borderwidth 1
  
  pack $nb2.fbook $nb2.ftime -side top -fill x
  pack $nb2.fopening -side top -fill both -expand 1
  
  # load book names
  ttk::checkbutton $nb2.fbook.cbUseBook -text [::msgcat::mc "Use book"] -variable ::options(game_useBook)
  set bookPath [file join $::instalDir "books" ]
  
  set bookList [ lsort -dictionary [ glob -nocomplain -tails -directory $bookPath *.bin ] ]
  set i 0
  set idx 0
  set lbook {}
  foreach file  $bookList {
    set f [file rootname [ file tail $file ] ]
    set lbook [concat $lbook $f]
  }
  
  ttk::combobox $nb2.fbook.combo -state readonly -width 12 -values $lbook
  
  $nb2.fbook.combo set [file rootname $::options(game_bookToUse) ]
  pack $nb2.fbook.cbUseBook $nb2.fbook.combo -expand yes -fill both -side top
  
  set row 0
  # New game or use current position ?
  ttk::checkbutton $nb2.ftime.cbPosition -text [::msgcat::mc "From current position"] -variable ::game::startFromCurrent
  grid $nb2.ftime.cbPosition  -row $row -column 0 -sticky w
  incr row
  
  # Warn if the user makes weak/bad moves
  ttk::checkbutton $nb2.ftime.cbCoach -text [::msgcat::mc "Coach is watching"] -variable ::game::coachIsWatching
  grid $nb2.ftime.cbCoach  -row $row -column 0 -sticky w
  incr row
  
  # Ponder
  ttk::checkbutton $nb2.ftime.cbPonder -text [::msgcat::mc "Permanent thinking"] -variable ::game::ponder
  grid $nb2.ftime.cbPonder  -row $row -column 0 -sticky w
  incr row
  
  # if Glaurung, tweak some uci options which may be interesting for the game
  if { $::options(engine1) == "glaurung" } {
    $w.fnb.nb add [ttk::frame $w.fnb.nb.extra] -text [::msgcat::mc "extra"]
    set nb3 $w.fnb.nb.extra
    ttk::label $nb3.lagg -text [::msgcat::mc "Aggressiveness\n(default 130)"]
    spinbox $nb3.sbagg -background yellow -width 3 -from 0 -to 300 -increment 10 -validate all \
        -textvariable ::options(glaurungAggressiveness) -vcmd { regexp {^[0-9]+$} %P }
    ttk::label $nb3.lcow -text [::msgcat::mc "Cowardice\n(default 100)"]
    spinbox $nb3.sbcow -background yellow -width 3 -from 0 -to 300 -increment 10 -validate all \
        -textvariable ::options(glaurungCowardice) -vcmd { regexp {^[0-9]+$} %P }
    
    grid $nb3.lagg -column 0 -row $row -sticky w
    grid $nb3.sbagg -column 1 -row $row -sticky w
    incr row
    grid $nb3.lcow -column 0 -row $row -sticky w
    grid $nb3.sbcow -column 1 -row $row -sticky w
    incr row
  }
  
  # choose a specific opening
  ttk::checkbutton $nb2.fopening.cbOpening -text [::msgcat::mc "Specific opening"] -variable ::game::isOpening
  ttk::frame $nb2.fopening.fOpeningList -relief raised -borderwidth 1
  listbox $nb2.fopening.fOpeningList.lbOpening -yscrollcommand "$nb2.fopening.fOpeningList.ybar set" -xscrollcommand "$nb2.fopening.fOpeningList.xbar set" \
      -height 5 -list ::game::openingList -exportselection 0 ; # -width 50
  $nb2.fopening.fOpeningList.lbOpening selection set $::options(game_specificOpening)
  
  ttk::scrollbar $nb2.fopening.fOpeningList.ybar -command "$nb2.fopening.fOpeningList.lbOpening yview"
  ttk::scrollbar $nb2.fopening.fOpeningList.xbar -orient horiz -command "$nb2.fopening.fOpeningList.lbOpening xview"
  
  grid $nb2.fopening.fOpeningList.lbOpening -row 0 -column 0 -sticky nsew
  grid $nb2.fopening.fOpeningList.ybar -row 0 -column 1 -sticky ns
  grid $nb2.fopening.fOpeningList.xbar -row 1 -column 0 -sticky ew
  grid rowconfigure $nb2.fopening.fOpeningList 0 -weight 1
  grid columnconfigure $nb2.fopening.fOpeningList 0 -weight 1
  
  pack $nb2.fopening.cbOpening -fill x -side top
  pack $nb2.fopening.fOpeningList -expand yes -fill both -side top
  
  # ------------- Bottom buttons -----------------
  ttk::button $w.fdown.close -text [::msgcat::mc "Play"] -command {
    focus .
    set nb1 .configSerGameWin.fnb.nb.time
    set nb2 .configSerGameWin.fnb.nb.settings
    set ::options(game_specificOpening) [$nb2.fopening.fOpeningList.lbOpening curselection]
    if {$::options(game_useBook)} {
      set ::options(game_bookToUse) "[$nb2.fbook.combo get].bin"
    }
    set ::engine::data(wtime1) [expr [$nb1.spW1 get]*1000*60]
    set ::engine::data(btime1) [expr [$nb1.spB1 get]*1000*60]
    set ::engine::data(winc1) [expr [$nb1.spW2 get]*1000]
    set ::engine::data(binc1) [expr [$nb1.spB2 get]*1000]
    set ::engine::data(fixeddepth1) [$nb1.sbDepth get]
    set ::engine::data(fixednodes1) [expr [$nb1.sbNodes get]*1000]
    set ::engine::data(movetime1) [expr [$nb1.sbMoveTime get]*1000]
    
    if {$::options(game_timeMode) == "depth" || $::options(game_timeMode) == "nodes" || $::options(game_timeMode) == "movetime"} {
      set ::engine::data(wtime1) 0
      set ::engine::data(btime1) 0
      set ::engine::data(winc1) 0
      set ::engine::data(binc1) 0
    }
    destroy .configSerGameWin
    ::game::playStart
  }
  ttk::button $w.fdown.cancel -text [::msgcat::mc "Cancel"] -command "focus .; destroy .configSerGameWin"
  
  pack $w.fdown.close $w.fdown.cancel -expand yes -side left -padx 20 -pady 2
  
  pack $w.fnb -fill both -side top -expand 1
  pack $w.fdown -side top -fill x
  
  bind $w <Destroy> { set ::playMode 0 }
}
################################################################################
proc ::game::PlayConfigXBoard {} {
  set w ".configXBoardGameWin"
  if {[winfo exists $w]} {
    focus $w
    return
  }
  
  toplevel $w
  wm title $w "Configure Game"
  ::ui::setFullSize $w
  ttk::frame $w.fnb
  ttk::frame $w.fdown
  
  pack [ttk::notebook $w.fnb.nb] -fill both -expand 1
  
  # --------------- Time frame ---------------------
  $w.fnb.nb add [ttk::frame $w.fnb.nb.time] -text "time"
  set nb1 $w.fnb.nb.time
  
  set row 0
  set ::options(game_timeMode) "timebonus"
  
  ttk::label $nb1.lb1 -text [::msgcat::mc "White time"]
  grid $nb1.lb1 -row $row -column 0 -sticky w
  incr row
  spinbox $nb1.spW1 -textvar ::options(game_wtime) -background white -width 4 -from 1 -to 120 -increment 1 -validate all -vcmd { regexp {^[0-9]+$} %P }
  spinbox $nb1.spW2 -textvar ::options(game_winc) -background white -width 4 -from 0 -to 60 -increment 1 -validate all -vcmd { regexp {^[0-9]+$} %P }
  grid $nb1.spW1 -row $row -column 0 -sticky w
  grid $nb1.spW2  -row $row -column 1 -sticky w
  incr row
  
  ttk::label $nb1.lb2 -text [::msgcat::mc "Black time"]
  grid $nb1.lb2 -row $row -column 0 -sticky w
  incr row
  spinbox $nb1.spB1 -textvar ::options(game_btime) -background white -width 4 -from 1 -to 120 -increment 1 -validate all -vcmd { regexp {^[0-9]+$} %P }
  spinbox $nb1.spB2 -textvar ::options(game_binc) -background white -width 4 -from 0 -to 60 -increment 1 -validate all -vcmd { regexp {^[0-9]+$} %P }
  grid $nb1.spB1 -row $row -column 0 -sticky w
  grid $nb1.spB2  -row $row -column 1 -sticky w
  incr row
  
  ttk::checkbutton $nb1.cbEgt -text [::msgcat::mc "Add elapsed game time"] -variable ::options(game_elapsedGameTime)
  grid $nb1.cbEgt -row $row -column 0 -sticky w -columnspan 2
  incr row
  
  # --------------- Other settings frame -----------
  $w.fnb.nb add [ttk::frame $w.fnb.nb.settings] -text "settings"
  set nb2 $w.fnb.nb.settings
  
  ttk::frame $nb2.fbook -relief groove -borderwidth 1
  ttk::frame $nb2.ftime -relief groove -borderwidth 1
  ttk::frame $nb2.fopening -relief groove -borderwidth 1
  
  # load book names
  ttk::checkbutton $nb2.fbook.cbUseBook -text [::msgcat::mc "Use book"] -variable ::options(game_useBook)
  set bookPath [file join $::instalDir "books" ]
  
  set bookList [ lsort -dictionary [ glob -nocomplain -tails -directory $bookPath *.bin ] ]
  set i 0
  set idx 0
  set lbook {}
  foreach file  $bookList {
    set f [ file rootname [ file tail $file ] ]
    set lbook [concat $lbook $f]
  }
  
  ttk::combobox $nb2.fbook.combo -state readonly -width 12 -values $lbook
  
  $nb2.fbook.combo set [file rootname $::options(game_bookToUse)]
  pack $nb2.fbook.cbUseBook $nb2.fbook.combo -expand yes -fill both -side top
  
  set row 0
  # New game or use current position ?
  ttk::checkbutton $nb2.ftime.cbPosition -text [::msgcat::mc "From current position"] -variable ::game::startFromCurrent
  grid $nb2.ftime.cbPosition  -row $row -column 0 -sticky w
  incr row
  
  # make the engine simulate an opponent with a given ELO
  if {$::options(engine1) == "phalanx"} {
    $w.fnb.nb add [ttk::frame $w.fnb.nb.extra] -text "extra"
    set nb3 $w.fnb.nb.extra
    ttk::checkbutton $nb3.cbElo -text [::msgcat::mc "Opponent limited Elo"] -variable ::options(game_limitElo)
    scale $nb3.scale -from $::game::minElo -to $::game::maxElo -resolution 50 -showvalue 1 -variable ::options(game_Elo) -orient horiz ;#-length 250
    # ttk::scale $nb3.scale -from $::game::minElo -to $::game::maxElo -variable ::options(game_Elo) -orient horiz
    pack $nb3.cbElo $nb3.scale -expand yes -fill x -side top
  } else {
    set ::options(limitElo) 0
  }
  
  # choose a specific opening
  ttk::checkbutton $nb2.fopening.cbOpening -text [::msgcat::mc "Specific opening"] -variable ::game::isOpening
  ttk::frame $nb2.fopening.fOpeningList -relief raised -borderwidth 1
  listbox $nb2.fopening.fOpeningList.lbOpening -yscrollcommand "$nb2.fopening.fOpeningList.ybar set" -xscrollcommand "$nb2.fopening.fOpeningList.xbar set" \
      -height 5 -list ::game::openingList -exportselection 0 ; # -width 50
  $nb2.fopening.fOpeningList.lbOpening selection set $::options(game_specificOpening)
  
  ttk::scrollbar $nb2.fopening.fOpeningList.ybar -command "$nb2.fopening.fOpeningList.lbOpening yview"
  ttk::scrollbar $nb2.fopening.fOpeningList.xbar -orient horiz -command "$nb2.fopening.fOpeningList.lbOpening xview"
  
  grid $nb2.fopening.fOpeningList.lbOpening -row 0 -column 0 -sticky nsew
  grid $nb2.fopening.fOpeningList.ybar -row 0 -column 1 -sticky ns
  grid $nb2.fopening.fOpeningList.xbar -row 1 -column 0 -sticky ew
  grid rowconfigure $nb2.fopening.fOpeningList 0 -weight 1
  grid columnconfigure $nb2.fopening.fOpeningList 0 -weight 1
  
  pack $nb2.fopening.cbOpening -fill x -side top
  pack $nb2.fopening.fOpeningList -expand yes -fill both -side top
  
  pack $nb2.fbook $nb2.ftime -side top -fill x
  pack $nb2.fopening -side top -fill both -expand 1
  
  
  button $w.fdown.close -text [::msgcat::mc "Play"] -command {
    focus .
    set w ".configXBoardGameWin"
    set nb1 $w.fnb.nb.time
    set nb2 $w.fnb.nb.settings
    set ::options(game_specificOpening) [$nb2.fopening.fOpeningList.lbOpening curselection]
    if {$::options(game_useBook)} {
      set ::options(game_bookToUse) "[$nb2.fbook.combo get].bin"
    }
    set ::engine::data(wtime1) [expr [$nb1.spW1 get]*1000*60]
    set ::engine::data(btime1) [expr [$nb1.spB1 get]*1000*60]
    set ::engine::data(winc1) [expr [$nb1.spW2 get]*1000]
    set ::engine::data(binc1) [expr [$nb1.spB2 get]*1000]
    destroy .configXBoardGameWin
    ::game::playStart
  }
  button $w.fdown.cancel -text [::msgcat::mc "Cancel"] -command "focus .; destroy .configXBoardGameWin"
  
  pack $w.fdown.close $w.fdown.cancel -expand yes -side left -padx 20 -pady 2
  
  pack $w.fnb -fill both -side top -expand 1
  pack $w.fdown -side top -fill x
  
  bind $w <Destroy> { set ::playMode 0 }
}

################################################################################
# n => 1 for engine
# n => 2 for player
proc ::game::playStart {} {
  global ::game::isOpening ::game::openingList ::game::openingMovesList \
      ::game::openingMovesHash ::game::openingMoves ::game::outOfOpening
  set n 1
  set ::playMode 1
  
  repetitionReset
  
  ::engine::stopAnalysis $n
  
  set ::options(multipvOld) $::options(multipv)
  
  if { $::novag::connected } {
    # ::novag::writechan "U ON"
    set ::options(novag_refereeMode) 1
    ::novag::newGame
  }
  # ponder
  if {$::game::ponder && $::cacheIsUci($n)} {
    ::engine::sendToEngine "setoption name Ponder value true" $n
  } else {
    ::engine::sendToEngine "setoption name Ponder value false" $n
  }
  
  # Glaurung special options
  if { $::options(engine$n) == "glaurung" } {
    ::engine::sendToEngine "setoption name Aggressiveness value $::options(glaurungAggressiveness)" $n
    ::engine::sendToEngine "setoption name Cowardice value $::options(glaurungCowardice)" $n
  }
  
  if {$::options(game_limitElo)} {
    if {$::options(engine1) == "phalanx"} {
      set level [expr int(100-(100*($::options(game_Elo) - $::game::minElo)/($::game::maxElo-$::game::minElo)))]
      ::engine::sendToEngine "elevel $level" $n
    }
  }
  
  set title $::options(engine1)
  if {$::options(game_limitElo) && $::options(engine1) == "phalanx"} {
    set title "$title $::options(game_Elo)"
  }
  wm title . $title
  
  set ::options(showAnalysisOld) $::options(showAnalysis)
  set ::options(showAnalysis) 0
  ::infopanel::updateAnalysis
  set ::options(showBookOld) $::options(showBook)
  set ::options(showBook) 0
  ::infopanel::updateBookText
  
  set ::engine::data(prevscore$n) 0.0
  
  if {$::game::startFromCurrent} {
    set isOpening 0
  }
  # clock 1 is white
  ::gameclock::new .fTop.fr.fclocks 1 1
  ::gameclock::new .fTop.fr.fclocks 2 1
  ::gameclock::setColor 1 "white"
  ::gameclock::setColor 2 "black"
  ::gameclock::reset 1
  ::gameclock::start 1
  
  # if will follow a specific opening line
  if { $isOpening && ! $::game::startFromCurrent } {
    set fields [split [lindex $openingList $::options(game_specificOpening)] ":"]
    set openingName [lindex $fields 0]
    set openingMoves [string trim [lindex $fields 1]]
    set openingMovesList ""
    set openingMovesHash ""
    set outOfOpening 0
    foreach m [split $openingMoves] {
      # in case of multiple adjacent spaces in opening line
      if {$m =={}} {
        continue
      }
      set p [string trim $m]
      lappend openingMovesList [string trim [regsub {^[1-9]+\.} $p ""] ]
    }
    
    sc_game new
    lappend openingMovesHash [sc_pos hash]
    foreach m  $openingMovesList {
      if {[catch {sc_move addSan $m}]} { }
      lappend openingMovesHash [sc_pos hash]
    }
    sc_game new
  }
  
  if {!$::game::startFromCurrent} {
    # create a new game if a DB is opened
    sc_game new
    
    setPlayHeaders
    
    if {[sc_base inUse [sc_base current]]} { catch {sc_game save 0}  }
  }
  
  ::board::updateBoard -pgn -nolastmove
  
  # setup clocks
  if {$::options(game_timeMode) == "timebonus"} {
    ::gameclock::setdSec 1 [expr $::engine::data(wtime$n)/100]
    ::gameclock::setdSec 2 [expr $::engine::data(btime$n)/100]
  } elseif {$::options(game_timeMode) == "depth" || $::options(game_timeMode) == "nodes" || $::options(game_timeMode) == "movetime"} {
    ::gameclock::setdSec 1 0
    ::gameclock::setdSec 2 0
  }
  
  set ::game::wentOutOfBook 0
  if { [ ::engine::isUci 1 ] } {
    ::game::engineGo 1
  } else  {
    ::game::engineGoXBoard 1
  }
}
################################################################################
proc ::game::endOfGame {} {
  set move_done [sc_game info previousMove]
  if { [string index [sc_game info previousMove] end ] == "#"} {
    ::gameclock::stop 1
    ::gameclock::stop 2
    return 1
  }
  return 0
}
################################################################################
proc ::game::engineGoXBoard { n } {
  global ::game::isOpening ::game::openingMovesList ::game::openingMovesHash ::game::openingMoves ::game::outOfOpening
  
  after cancel ::game::engineGoXBoard $n
  
  if { [::game::endOfGame] } {
    tk_messageBox -type ok -title [::msgcat::mc "End of game"] -message [::msgcat::mc "Mate"] -parent .fTop -icon info
    return
  }
  
  if { [sc_pos side] != [::game::getEngineColor] } {
    after 1000 ::game::engineGoXBoard $n
    return
  }
  
  # The player moved : add clock time
  if {!([::game::getEngineColor] == "black" && [sc_pos moveNumber] == 1)} {
    if { [::game::getEngineColor] == "white" } {
      ::gameclock::add 2 $::engine::data(binc$n)/1000
    } else {
      ::gameclock::add 1 $::engine::data(winc$n)/1000
    }
  }
  
  clockStart "engine"
  repetition
  
  # make a move corresponding to a specific opening, (it is engine's turn)
  if {$isOpening && !$outOfOpening} {
    set index 0
    # Warn if the user went out of the opening line chosen
    if { !$outOfOpening } {
      set ply [ expr [sc_pos moveNumber] * 2 - 1]
      if { [sc_pos side] == "white" } {
        set ply [expr $ply - 1]
      }
      
      if { [lsearch $openingMovesHash [sc_pos hash]] == -1 && [llength $openingMovesList] >= $ply} {
        set answer [tk_messageBox -icon question -parent .fTop -title "Out of opening" -type yesno \
            -message "You did not follow the line\n$openingMoves\nDo you want to continue ?" ]
        if {$answer == no} {
          sc_move back 1
          ::board::updateBoard -pgn
          clockStart "player"
          
          after 1000 ::game::engineGoXBoard $n
          return
        }  else  {
          set outOfOpening 1
        }
      }
    }
    
    set hpos [sc_pos hash]
    # Find a corresponding position in the opening line
    set length [llength $openingMovesHash]
    for {set i 0}   { $i < [expr $length-1] } { incr i } {
      set h [lindex $openingMovesHash $i]
      if {$h == $hpos} {
        set index [lsearch $openingMovesHash $h]
        set move [lindex $openingMovesList $index]
        # play the move
        set action "replace"
        if {![sc_pos isAt vend]} { set action [confirmReplaceMove] }
        if {$action == "replace"} {
          ::game::moveAdd $move
        } elseif {$action == "var"} {
          sc_var create
          ::game::moveAdd $move
        } elseif {$action == "mainline"} {
          sc_var create
          ::sound::play move
          ::game::moveAdd $move
          sc_var exit
          sc_var promote [expr {[sc_var count] - 1}]
          sc_move forward 1
        }
        
        ::board::updateBoard -pgn
        
        repetition
        if { [::game::getEngineColor] == "white" } {
          ::gameclock::add 1 $::engine::data(winc$n)/1000
        } else  {
          ::gameclock::add 2 $::engine::data(binc$n)/1000
        }
        clockStart "player"
        after 1000 ::game::engineGoXBoard $n
        return
      }
    }
  }
  
  # use a book
  # if the opponent has a limited ELO, use book corresponding to its level
  if { $::options(game_limitElo) } {
    set mn [sc_pos moveNumber]
    if {$::options(game_Elo) < 2000 && [expr ($::options(game_Elo) - $::game::minElo)/100] < $mn} {
      set ::game::wentOutOfBook 1
    }
  }
  if {$::options(game_useBook) && ! $::game::wentOutOfBook} {
    set move [ ::book::getMove $::options(game_bookToUse) [sc_pos fen] $::game::bookSlot]
    if {$move == ""} {
      set ::game::wentOutOfBook 1
    } else  {
      ::game::moveAdd $move
      ::board::updateBoard -pgn
      repetition
      if {$::options(game_timeMode) == "timebonus"} {
        if { [::game::getEngineColor] == "white" } {
          ::gameclock::add 1 $::engine::data(winc$n)/1000
        } else  {
          ::gameclock::add 2 $::engine::data(binc$n)/1000
        }
      }
      clockStart "player"
      after 1000 ::game::engineGoXBoard $n
      return
    }
  }
  
  set wtime [::gameclock::getdSec 1]
  set btime [::gameclock::getdSec 2]
  
  # Send to the engine values with at least 1 minute on each clock, even if the flag is down
  if {$wtime < 600 } {set wtime 600}
  if {$btime < 600 } {set btime 600}
  
  ::engine::sendToEngine "setboard [sc_pos fen]" $n
  
  if { [::game::getEngineColor] == "white" } {
    ::engine::sendToEngine "level 0 [expr int($wtime /600 )] [expr int($::engine::data(winc$n) / 1000)]" $n
  } else {
    ::engine::sendToEngine "level 0 [expr int($btime /600 )] [expr int($::engine::data(binc$n) / 1000)]" $n
  }
  
  ::engine::sendToEngine "go" $n
  
  set ::engine::data(bestmove$n) ""
  vwait ::engine::data(bestmove$n)
  # check if the game is stopped
  if {! $::playMode} { return }
  
  ::game::moveAdd $::engine::data(bestmove$n)
  
  set ::engine::data(prevscore$n) $::engine::data(score$n)
  ::board::updateBoard -pgn
  
  # add time after a move played
  if { [::game::getEngineColor] == "white" } {
    ::gameclock::add 1 $::engine::data(winc$n)/1000
  } else  {
    ::gameclock::add 2 $::engine::data(binc$n)/1000
  }
  
  clockStart "player"
  
  repetition
  after 1000 ::game::engineGoXBoard $n
  
}
################################################################################
# UCI engine
proc ::game::engineGo { n } {
  global ::game::isOpening ::game::openingMovesList ::game::openingMovesHash ::game::openingMoves ::game::outOfOpening
  
  after cancel ::game::engineGo $n
  
  if { [::game::endOfGame] } {
    tk_messageBox -type ok -title [::msgcat::mc "End of game"] -message [::msgcat::mc "Mate"] -parent .fTop -icon info
    return
  }
  
  if { [sc_pos side] != [::game::getEngineColor] } {
    after 1000 ::game::engineGo $n
    return
  }
  
  # The player moved : add clock time
  if {!([::game::getEngineColor] == "black" && [sc_pos moveNumber] == 1)} {
    if { [::game::getEngineColor] == "white" } {
      ::gameclock::add 2 $::engine::data(binc$n)/1000
    } else  {
      ::gameclock::add 1 $::engine::data(winc$n)/1000
    }
  }
  # if halfmove is resetted, clear list of FEN used by repetition detection
  if { [lindex [split [sc_pos fen]] 4] == 0 } { set ::game::lFen {} }
  
  clockStart "engine"
  
  repetition
  # -------------------------------------------------------------
  # make a move corresponding to a specific opening, (it is engine's turn)
  if {$isOpening && !$outOfOpening} {
    set index 0
    # Warn if the user went out of the opening line chosen
    if { !$outOfOpening } {
      set ply [ expr [sc_pos moveNumber] * 2 - 1]
      if { [sc_pos side] == "white" } {
        set ply [expr $ply - 1]
      }
      
      if { [lsearch $openingMovesHash [sc_pos hash]] == -1 && [llength $openingMovesList] >= $ply} {
        set answer [tk_messageBox -icon question -parent .fTop -title "Out of opening" -type yesno \
            -message "You did not follow the line\n$openingMoves\nDo you want to continue ?" ]
        if {$answer == no} {
          sc_move back 1
          ::board::updateBoard -pgn
          
          clockStart "player"
          after 1000 ::game::engineGo $n
          return
        }  else  {
          set outOfOpening 1
        }
      }
    }
    
    set hpos [sc_pos hash]
    # Find a corresponding position in the opening line
    set length [llength $openingMovesHash]
    for {set i 0}   { $i < [expr $length-1] } { incr i } {
      set h [lindex $openingMovesHash $i]
      if {$h == $hpos} {
        set index [lsearch $openingMovesHash $h]
        set move [lindex $openingMovesList $index]
        # play the move
        set action "replace"
        if {![sc_pos isAt vend]} { set action [confirmReplaceMove] }
        if {$action == "replace"} {
          ::game::moveAdd $move
        } elseif {$action == "var"} {
          sc_var create
          ::game::moveAdd $move
        } elseif {$action == "mainline"} {
          sc_var create
          ::game::moveAdd $move
          sc_var exit
          sc_var promote [expr {[sc_var count] - 1}]
          sc_move forward 1
        }
        
        ::board::updateBoard -pgn
        clockStart "player"
        
        repetition
        if { [::game::getEngineColor] == "white" } {
          ::gameclock::add 1 $::engine::data(winc$n)/1000
        } else  {
          ::gameclock::add 2 $::engine::data(binc$n)/1000
        }
        after 1000 ::game::engineGo $n
        return
      }
    }
  }
  # -------------------------------------------------------------
  # use a book
  if {$::options(game_useBook) && ! $::game::wentOutOfBook} {
    set move [ ::book::getMove $::options(game_bookToUse) [sc_pos fen] $::game::bookSlot]
    if {$move == ""} {
      set ::game::wentOutOfBook 1
    } else  {
      
      if { [ catch {::game::moveAdd $move} ] } {
        tk_messageBox -type ok -message "Error book move $move" -icon error
        set ::game::wentOutOfBook 1
      } else {
        
        ::board::updateBoard -pgn
        clockStart "player"
        
        repetition
        if {$::options(game_timeMode) == "timebonus"} {
          if { [::game::getEngineColor] == "white" } {
            ::gameclock::add 1 $::engine::data(winc$n)/1000
          } else  {
            ::gameclock::add 2 $::engine::data(binc$n)/1000
          }
        }
        after 1000 ::game::engineGo $n
        return
      }
    }
  }
  
  # -------------------------------------------------------------
  # check if the engine pondered on the right move
  if { $::game::ponder && $::engine::data(ponder$n) == $::game::lastPlayerMoveUci } {
    ::engine::sendToEngine "ponderhit" $n
  } else {
    
    if { $::game::ponder && [sc_pos moveNumber] != 1} {
      set ::engine::data(waitForBestMove$n) 1
      ::engine::sendToEngine "stop" $n
      vwaitTimed ::engine::data(waitForBestMove$n) 3000 nowarn
    }
    
    set ::engine::data(waitForReadyOk$n) 1
    ::engine::sendToEngine "isready" $n
    vwait ::engine::data(waitForReadyOk$n)
    
    ::engine::sendToEngine "position fen [sc_pos fen]" $n
    
    set wtime [expr [::gameclock::getdSec 1] * 100 ]
    set btime [expr [::gameclock::getdSec 2] * 100 ]
    
    # Send to the engine values with at least 1 second on each clock, even if the flag is down
    if {$wtime < 1000} {set wtime 1000}
    if {$btime < 1000} {set btime 1000}
    
    if {$::options(game_timeMode) == "timebonus"} {
      ::engine::sendToEngine "go wtime $wtime btime $btime winc $::engine::data(winc$n) binc $::engine::data(binc$n)" $n
    } elseif {$::options(game_timeMode) == "depth"} {
      ::engine::sendToEngine "go depth $::engine::data(fixeddepth$n)" $n
    } elseif {$::options(game_timeMode) == "movetime"} {
      ::engine::sendToEngine "go movetime $::engine::data(movetime$n)" $n
    } elseif {$::options(game_timeMode) == "nodes"} {
      ::engine::sendToEngine "go nodes $::engine::data(fixednodes$n)" $n
    }
  }
  # -------------------------------------------------------------
  
  set ::engine::data(bestmove$n) ""
  vwait ::engine::data(bestmove$n)
  # check if the game is stopped
  if {! $::playMode} { return }
  
  # if halfmove is resetted, clear list of FEN used by repetition detection
  if { [lindex [split [sc_pos fen]] 4] == 0 } { set ::game::lFen {} }
  
  # -------------------------------------------------------------
  # if weak move detected, propose the user to take back
  if { $::game::coachIsWatching && $::engine::data(prevscore$n) != "" } {
    set blunder 0
    set delta [expr $::engine::data(score$n) - $::engine::data(prevscore$n)]
    
    if {$delta > $::informant("?!") && [getEngineColor] == "white" ||
      $delta < [expr 0.0 - $::informant("?!")] && [getEngineColor] == "black" } {
      set blunder 1
    }
    
    if {$delta > $::informant("?") && [getEngineColor] == "white" ||
      $delta < [expr 0.0 - $::informant("?")] && [getEngineColor] == "black" } {
      set blunder 2
    }
    
    if {$delta > $::informant("??") && [getEngineColor] == "white" ||
      $delta < [expr 0.0 - $::informant("??")] && [getEngineColor] == "black" } {
      set blunder 3
    }
    
    if {$blunder == 1} {
      set tBlunder "Dubious move played,\ndo you want to take back ?"
    } elseif {$blunder == 2} {
      set tBlunder "Weak move played,\ndo you want to take back ?"
    } elseif {$blunder == 3} {
      set tBlunder "Bad move played,\ndo you want to take back ?"
    }
    
    if {$blunder != 0} {
      set answer [tk_messageBox -icon question -parent .fTop -title "Scid" -type yesno -message $tBlunder ]
      if {$answer == yes} {
        sc_move back 1
        ::board::updateBoard -pgn
        clockStart "player"
        
        after 1000 ::game::engineGo $n
        return
      }
    }
  }
  # -------------------------------------------------------------
  if { [ catch { ::game::moveAdd $::engine::data(bestmove$n) } ] } {
    tk_messageBox -type ok -message "Error in call\n::game::moveAdd (l. 1631) $::engine::data(bestmove$n)" -icon error
  }
  
  set ::engine::data(prevscore$n) $::engine::data(score$n)
  ::board::updateBoard -pgn
  
  # add time after a move played
  if {$::options(game_timeMode) == "timebonus"} {
    if { [::game::getEngineColor] == "white" } {
      ::gameclock::add 1 $::engine::data(winc$n)/1000
    } else  {
      ::gameclock::add 2 $::engine::data(binc$n)/1000
    }
  }
  clockStart "player"
  
  repetition
  
  # -------------------------------------------------------------
  # ponder mode (the engine just played its move)
  if {$::game::ponder && $::engine::data(ponder$n) != ""} {
    ::engine::sendToEngine "position fen [sc_pos fen] moves $::engine::data(ponder$n)" $n
    set wtime [expr [::gameclock::getdSec 1] * 100 ]
    set btime [expr [::gameclock::getdSec 2] * 100 ]
    if {$::options(game_timeMode) == "timebonus"} {
      ::engine::sendToEngine "go ponder wtime $wtime btime $btime winc $::engine::data(winc$n) binc $::engine::data(binc$n)" $n
    } elseif {$::options(game_timeMode) == "depth"} {
      ::engine::sendToEngine "go ponder depth $::engine::data(fixeddepth$n)" $n
    } elseif {$::options(game_timeMode) == "movetime"} {
      ::engine::sendToEngine "go ponder movetime $::engine::data(movetime$n)" $n
    } elseif {$::options(game_timeMode) == "nodes"} {
      ::engine::sendToEngine "go ponder nodes $::engine::data(fixednodes$n)" $n
    }
  }
  
  after 1000 ::game::engineGo $n
}
################################################################################
#  start the clock of "engine" or "player" and stops the other one
# clock 1 is always for white
################################################################################
proc ::game::clockStart { arg } {
  if {$arg == "engine"} {
    if { [::game::getEngineColor] == "white" } {
      set clockPlayer 2
      ::gameclock::stop 2
      ::gameclock::start 1
    } else {
      set clockPlayer 1
      ::gameclock::stop 1
      ::gameclock::start 2
    }
    # add elapsed game time as comment like {[%egt 1:25:42]}
    if { $::options(game_elapsedGameTime) } {
      set egt [::gameclock::getEgt $clockPlayer]
      sc_pos setComment "\{\[%egt $egt\]\}"
    }
  } else {
    if { [::game::getEngineColor] == "white" } {
      ::gameclock::stop 1
      ::gameclock::start 2
    } else {
      ::gameclock::stop 2
      ::gameclock::start 1
    }
  }
}
################################################################################
# check if the game is a draw by 50 moves rule
################################################################################
proc ::game::draw50moves { { showMessage 1 } } {
  if { [lindex [split [sc_pos fen]] 4] >= 50 } {
    if { $showMessage } {
      tk_messageBox -type ok -message [::msgcat::mc "Draw"] -parent .fTop -icon info
    }
    return 1
  }
  return 0
}

################################################################################
#   add current position for 3fold repetition detection and returns 1 if
# the position is a repetion
# It also calls draw50moves
################################################################################
proc ::game::repetition { { showMessage 1 } } {
  set elt [lrange [split [sc_pos fen]] 0 2]
  lappend ::game::lFen $elt
  if { [llength [lsearch -all $::game::lFen $elt] ] >=3 } {
    if { $showMessage } {
      tk_messageBox -type ok -message [::msgcat::mc "Draw"] -parent .fTop -icon info
    }
    return 1
  }
  
  return [ draw50moves $showMessage ]
}

proc ::game::repetitionReset {} {
  set ::game::lFen {}
}
################################################################################
#
################################################################################
proc ::game::getEngineColor {} {
  # Engine always plays for the upper side
  if { $::board::isFlipped == 0 } {
    return "black"
  } else  {
    return "white"
  }
}
################################################################################
proc ::game::MoveComment {} {
  set oldNag [sc_pos getNags]
  if {$oldNag == "0"} {set oldNag ""}
  set oldComment [sc_pos getComment]
  
  set ::game::newComment ""
  set ::game::newNag ""
  
  set w .moveComment
  if {[winfo exists $w]} {
    focus $w
    return
  }
  toplevel $w
  ::ui::setFullSize $w
  ttk::frame $w.fNagDisp
  text $w.fNagDisp.text -height 1
  $w.fNagDisp.text insert end $oldNag
  ttk::button $w.fNagDisp.bClear -text "Clear" -command { .moveComment.fNagDisp.text delete 1.0 end }
  pack $w.fNagDisp.bClear -side right
  pack $w.fNagDisp.text -side right -expand 1
  
  ttk::frame $w.fNagButton
  set idx 1
  foreach nag { ! ? !! ?? !? ?! = ~ += =+ +/- -/+ +- -+ } {
    ttk::button $w.fNagButton.b$idx -text $nag -command " .moveComment.fNagDisp.text insert end \" $nag\" "
    incr idx
  }
  
  for {set i 1} {$i<=5} {incr i} { grid $w.fNagButton.b$i -row 0 -column [expr $i - 1] -sticky ew }
  for {set i 6} {$i<=10} {incr i} { grid $w.fNagButton.b$i -row 1 -column [expr $i - 6] -sticky ew }
  for {set i 11} {$i<=14} {incr i} { grid $w.fNagButton.b$i -row 2 -column [expr $i - 11] -sticky ew }
  
  ttk::frame $w.fCommentDisp
  text $w.fCommentDisp.text
  $w.fCommentDisp.text insert end $oldComment
  pack $w.fCommentDisp.text -fill both
  
  ttk::frame $w.fCommentButton
  ttk::button $w.fCommentButton.b0 -text "Clear" -command { .moveComment.fCommentDisp.text delete 1.0 end }
  pack $w.fCommentButton.b0
  
  ttk::frame $w.fClose
  ttk::button $w.fClose.bClose -text "OK" -command {::game::updateComment; destroy .moveComment}
  ttk::button $w.fClose.bCancel -text [::msgcat::mc "Cancel"] -command {destroy .moveComment}
  pack $w.fClose.bClose $w.fClose.bCancel -side left
  
  pack $w.fNagDisp $w.fNagButton -side top -fill both
  pack $w.fClose $w.fCommentButton -side bottom -fill x
  pack $w.fCommentDisp -side bottom -expand 1
  
}
################################################################################
proc ::game::updateComment {} {
  set nag [.moveComment.fNagDisp.text get 1.0 end]
  set comment [.moveComment.fCommentDisp.text get 1.0 end]
  set nag [string trim $nag]
  set comment [string trim $comment]
  
  sc_pos setComment $comment
  sc_pos clearNags
  foreach n $nag {
    sc_pos addNag $n
  }
  ::infopanel::updateComments
}
################################################################################
proc ::game::info {} {
  set w .gameInfo
  toplevel $w
  ::ui::setFullSize $w
  
  set row 0
  set f [ ttk::frame $w.tags ]
  grid columnconfigure $f 1 -weight 5
  
  ttk::label $f.labelWhite -text White
  ttk::entry $f.white
  $f.white insert end [sc_game tag get White]
  grid $f.labelWhite -row $row -column 0 -sticky w
  grid $f.white -row $row -column 1 -sticky w
  incr row
  
  ttk::label $f.labelWhiteElo -text Elo
  ttk::entry $f.whiteElo  -validate all -validatecommand { string is integer %P }
  $f.whiteElo insert end [sc_game tag get WhiteElo]
  grid $f.labelWhiteElo -row $row -column 0 -sticky w
  grid $f.whiteElo -row $row -column 1 -sticky w
  incr row
  
  ttk::label $f.labelBlack -text Black
  ttk::entry $f.black
  $f.black insert end [sc_game tag get Black]
  grid $f.labelBlack -row $row -column 0 -sticky w
  grid $f.black -row $row -column 1 -sticky w
  incr row
  
  ttk::label $f.labelBlackElo -text Elo
  ttk::entry $f.blackElo -validate all -validatecommand { string is integer %P }
  $f.blackElo insert end [sc_game tag get BlackElo]
  grid $f.labelBlackElo -row $row -column 0 -sticky w
  grid $f.blackElo -row $row -column 1 -sticky w
  incr row
  
  ttk::label $f.labelEvent -text Event
  ttk::entry $f.event
  $f.event insert end [sc_game tag get Event]
  grid $f.labelEvent -row $row -column 0 -sticky w
  grid $f.event -row $row -column 1 -sticky w
  incr row
  
  ttk::label $f.labelSite -text Site
  ttk::entry $f.site
  $f.site insert end [sc_game tag get Site]
  grid $f.labelSite -row $row -column 0 -sticky w
  grid $f.site -row $row -column 1 -sticky w
  incr row
  
  ttk::label $f.labelDate -text Date
  ttk::entry $f.date
  $f.date insert end [sc_game tag get Date]
  grid $f.labelDate -row $row -column 0 -sticky w
  grid $f.date -row $row -column 1 -sticky w
  incr row
  
  ttk::label $f.labelRound -text Round
  ttk::entry $f.round -validate all -validatecommand { string is integer %P }
  $f.round insert end [sc_game tag get Round]
  grid $f.labelRound -row $row -column 0 -sticky w
  grid $f.round -row $row -column 1 -sticky w
  incr row
  
  
  ttk::label $f.labelEco -text ECO
  ttk::entry $f.eco
  $f.eco insert end [sc_game tag get ECO]
  grid $f.labelEco -row $row -column 0 -sticky w
  grid $f.eco -row $row -column 1 -sticky w
  incr row
  
  ttk::label $f.labelResult -text Result
  ttk::combobox $f.result -state readonly -width 4 -values { "1-0" "0-1" "=" "*" }
  set result [sc_game info result]
  if {$result == "=-="} {set result "=" }
  $f.result set $result
  grid $f.labelResult -row $row -column 0 -sticky w
  grid $f.result -row $row -column 1 -sticky w
  incr row
  
  ttk::frame $w.buttons
  ttk::button $w.buttons.save -text "Save" -command {
    set f .gameInfo.tags
    sc_game tag set -white [$f.white get]
    sc_game tag set -black [$f.black get]
    sc_game tag set -whiteElo [$f.whiteElo get]
    sc_game tag set -blackElo [$f.blackElo get]
    sc_game tag set -event [$f.event get]
    sc_game tag set -site [$f.site get]
    sc_game tag set -date [$f.date get]
    sc_game tag set -round [$f.round get]
    sc_game tag set -eco [$f.eco get]
    set result [$f.result get]
    if {$result == "1-0"} {  set result 1 }
    if {$result == "0-1"} {  set result 0 }
    sc_game tag set -result $result
  }
  ttk::button $w.buttons.close -text "Close" -command " focus . ; destroy $w "
  pack $w.buttons.save $w.buttons.close -fill x -side left
  
  pack $f -fill both -expand 1
  pack $w.buttons -fill x -side bottom
}

################################################################################
set ::game::openingList [ list \
    "[::msgcat::mc Reti]: 1.Nf3" \
    "[::msgcat::mc English]: 1.c4" \
    "[::msgcat::mc [list 1.d4 Nf6 Miscellaneous]]: 1.d4 Nf6" \
    "[::msgcat::mc Trompowsky]: 1.d4 Nf6 2.Bg5" \
    "[::msgcat::mc Budapest]: 1.d4 Nf6 2.c4 e5" \
    "[::msgcat::mc [list Old Indian]]: 1.d4 Nf6 2.c4 d6" \
    "[::msgcat::mc [list Benko Gambit]]: 1.d4 Nf6 2.c4 c5 3.d5 b5" \
    "[::msgcat::mc [list Modern Benoni]]: 1.d4 Nf6 2.c4 c5 3.d5 e6" \
    "[::msgcat::mc [list Dutch Defence]]: 1.d4 f5" \
    "1.e4" \
    "[::msgcat::mc [list Scandinavian]]: 1.e4 d5" \
    "[::msgcat::mc [list Alekhine Defence]]: 1.e4 Nf6" \
    "[::msgcat::mc [list Pirc]]: 1.e4 d6" \
    "[::msgcat::mc [list Caro-Kann]]: 1.e4 c6" \
    "[::msgcat::mc [list Caro-Kann Advance]]: 1.e4 c6 2.d4 d5 3.e5" \
    "[::msgcat::mc [list Sicilian]]: 1.e4 c5" \
    "[::msgcat::mc [list Sicilian Alapin]]: 1.e4 c5 2.c3" \
    "[::msgcat::mc [list Sicilian Closed]]: 1.e4 c5 2.Nc3" \
    "[::msgcat::mc [list Sicilian]]: 1.e4 c5 2.Nf3 Nc6" \
    "[::msgcat::mc [list Sicilian]]: 1.e4 c5 2.Nf3 e6" \
    "[::msgcat::mc [list Sicilian Rauzer]]: 1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 Nc6" \
    "[::msgcat::mc [list Sicilian Dragon]]: 1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 g6 " \
    "[::msgcat::mc [list Sicilian Scheveningen]]: 1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 e6" \
    "[::msgcat::mc [list Sicilian Najdorf]]: 1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 a6" \
    "[::msgcat::mc [list Open Game]]: 1.e4 e5" \
    "[::msgcat::mc [list Vienna]]: 1.e4 e5 2.Nc3" \
    "[::msgcat::mc [list King's Gambit]]: 1.e4 e5 2.f4" \
    "[::msgcat::mc [list Russian Game]]: 1.e4 e5 2.Nf3 Nf6" \
    "[::msgcat::mc [list Open Game]]: 1.e4 e5 2.Nf3 Nc6" \
    "[::msgcat::mc [list Italian/Two Knights]]: 1.e4 e5 2.Nf3 Nc6 3.Bc4" \
    "[::msgcat::mc [list Spanish]]: 1.e4 e5 2.Nf3 Nc6 3.Bb5" \
    "[::msgcat::mc [list Spanish Exchange]]: 1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Bxc6" \
    "[::msgcat::mc [list Spanish Open]]: 1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4 Nf6 5.O-O Nxe4" \
    "[::msgcat::mc [list Spanish Closed]]: 1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4 Nf6 5.O-O Be7" \
    "[::msgcat::mc [list French Defence]]: 1.e4 e6" \
    "[::msgcat::mc [list French Advance]]: 1.e4 e6 2.d4 d5 3.e5" \
    "[::msgcat::mc [list French Tarrasch]]: 1.e4 e6 2.d4 d5 3.Nd2" \
    "[::msgcat::mc [list French Winawer]]: 1.e4 e6 2.d4 d5 3.Nc3 Bb4" \
    "[::msgcat::mc [list French Exchange]]: 1.e4 e6 2.d4 d5 3.exd5 exd5" \
    "[::msgcat::mc [list Queen's Pawn]]: 1.d4 d5" \
    "[::msgcat::mc [list Slav]]: 1.d4 d5 2.c4 c6" \
    "[::msgcat::mc [list QGA]]: 1.d4 d5 2.c4 dxc4" \
    "[::msgcat::mc [list QGD]]: 1.d4 d5 2.c4 e6" \
    "[::msgcat::mc [list QGD Exchange]]: 1.d4 d5 2.c4 e6 3.cxd5 exd5" \
    "[::msgcat::mc [list Semi-Slav]]: 1.d4 d5 2.c4 e6 3.Nc3 Nf6 4.Nf3 c6" \
    "[::msgcat::mc [list QGD with Bg5]]: 1.d4 d5 2.c4 e6 3.Nc3 Nf6 4.Bg5" \
    "[::msgcat::mc [list QGD Orthodox]]: 1.d4 d5 2.c4 e6 3.Nc3 Nf6 4.Bg5 Be7 5.e3 O-O 6.Nf3 Nbd7" \
    "[::msgcat::mc [list Gruenfeld]]: 1.d4 Nf6 2.c4 g6 3.Nc3 d5" \
    "[::msgcat::mc [list Gruenfeld Exchange]]: 1.d4 Nf6 2.c4 g6 3.Nc3 d5 4.cxd5" \
    "[::msgcat::mc [list Gruenfeld Russian]]: 1.d4 Nf6 2.c4 g6 3.Nc3 d5 4.Nf3 Bg7 5.Qb3" \
    "[::msgcat::mc [list Catalan]]: 1.d4 Nf6 2.c4 e6 3.g3 " \
    "[::msgcat::mc [list Catalan Open]]: 1.d4 Nf6 2.c4 e6 3.g3 d5 4.Bg2 dxc4" \
    "[::msgcat::mc [list Catalan Closed]]: 1.d4 Nf6 2.c4 e6 3.g3 d5 4.Bg2 Be7" \
    "[::msgcat::mc [list Queen's Indian]]: 1.d4 Nf6 2.c4 e6 3.Nf3 b6" \
    "[::msgcat::mc [list Nimzo-Indian]]: 1.d4 Nf6 2.c4 e6 3.Nc3 Bb4" \
    "[::msgcat::mc [list Nimzo-Indian Classical]]: 1.d4 Nf6 2.c4 e6 3.Nc3 Bb4 4.Qc2" \
    "[::msgcat::mc [list Nimzo-Indian Rubinstein]]: 1.d4 Nf6 2.c4 e6 3.Nc3 Bb4 4.e3" \
    "[::msgcat::mc [list King's Indian]]: 1.d4 Nf6 2.c4 g6" \
    "[::msgcat::mc [list King's Indian Sämisch]]: 1.d4 Nf6 2.c4 g6 4.e4 d6 5.f3" \
    "[::msgcat::mc [list King's Indian Main Line]]: 1.d4 Nf6 2.c4 g6 4.e4 d6 5.Nf3" \
    ]

