# end.tcl: part of Scid.
# Copyright (C) 2001 Shane Hudson.

############################################################
### Main window title, etc:


# updateTitle:
#   Updates the main Scid window title.
#
proc updateTitle {} {
  set title "Scid [sc_info version]: "
  set fname [sc_base filename]
  set fname [file tail $fname]
  append title "$fname ($::tr(game) "
  append title "[thousands [sc_game number]] / "
  append title "[thousands [sc_base numGames]])"
  wm title . $title
}

# filterText: returns text describing state of filter for specified
#   database, e.g. "no games" or "all / 400" or "1,043 / 2,057"
#
proc filterText {{base 0} {kilo 0}} {
  # Default to current base if no base specified:
  if {$base == 0} { set base [sc_base current] }
  set filterCount [sc_filter count $base]
  set gameCount [sc_base numGames $base]
  if {$gameCount == 0} { return $::tr(noGames) }
  if {$gameCount == $filterCount} {
    return "$::tr(all) / [thousands $gameCount $kilo]"
  }
  return "[thousands $filterCount $kilo] / [thousands $gameCount $kilo]"
}

# updateStatusBar:
#   Updates the main Scid window status bar.
#
proc updateStatusBar {} {
  global statusBar moveEntry
  updateBaseWin
  updateMaintWin
  set statusBar "  "

  if {$moveEntry(Text) != ""} {
    append statusBar "Enter move: \[" $moveEntry(Text) "\]  "
    foreach thisMove $moveEntry(List) {
      append statusBar $thisMove " "
    }
    return
  }

  # Check if translations have not been set up yet:
  if {! [info exists ::tr(Database)]} { return }

  # Show "%%" if base is read-only, "XX" if game altered, "--" otherwise:
  if {[sc_base isReadOnly]} {
    append statusBar "%%"
  } elseif {[sc_game altered]} {
    append statusBar "XX"
  } else {
    append statusBar "--"
  }
  append statusBar "  $::tr(Database) "
  append statusBar [sc_base current]
  append statusBar ": "
  set fname [sc_base filename]
  set fname [file tail $fname]
  if {$fname == ""} { set fname "<none>" }
  append statusBar $fname

  # Show filter count:
  append statusBar "   $::tr(Filter)"
  append statusBar ": [filterText]"
}


############################################################
### Menu/etc Functions:

# fileExit:
#    Prompt for confirmation then exit.
#
proc fileExit {}  {
  # Check for altered game in all bases except the clipbase:
  set unsavedCount 0
  set savedBase [sc_base current]
  set msg ""
  set nbases [sc_base count total]
  for {set i 1} {$i < [sc_base count total]} {incr i} {
    sc_base switch $i
    if {[sc_base inUse] && [sc_game altered] && ![sc_base isReadOnly]} {
      if {$unsavedCount == 0} {
        append msg $::tr(ExitUnsaved)
        append msg "\n\n"
      }
      incr unsavedCount
      set fname [file tail [sc_base filename]]
      set g [sc_game number]
      append msg "   Base $i: $fname "
      append msg "($::tr(game) $g)"
      append msg "\n"
    }
  }
  # Switch back to original database:
  sc_base switch $savedBase

  if {$msg != ""} {
    append msg "\n"
  }
  append msg $::tr(ExitDialog)

  set answer [tk_dialog .exitDialog "Scid: [tr FileExit]" \
                $msg "" 0 $::tr(Yes) $::tr(No)]
  if {$answer == 0} { 
    if {$::optionsAutoSave} { .menu.options invoke [tr OptionsSave] }
    ::recentFiles::save
    destroy . 
  }
}

proc fastExit {} {
  if {$::optionsAutoSave} { .menu.options invoke [tr OptionsSave] }
  ::recentFiles::save
  destroy . 
}

# fileNew:
#   Opens file-save dialog and creates a new database.
#
proc fileNew {} {
  if {[sc_base count free] == 0} {
    tk_messageBox -title "Scid" -type ok -icon info \
      -message "Too many databases open; close one first"
    return
  }
  set ftype { 
    { "Scid databases, EPD files" {".si3" ".epd"} }
    { "Scid databases" {".si3"} }
    { "EPD files" {".epd"} }
  }
  set fName [tk_getSaveFile -initialdir $::initialDir(base) -filetypes $ftype -title "Create a Scid database"]
  if {$fName == ""} {
    # do nothing
  } elseif {[file extension $fName] == ".epd"} {
    newEpdWin create $fName
    return
  } else {
    set fName [file rootname $fName]
    if {[catch {sc_base create $fName} result]} {
      tk_messageBox -icon warning -type ok -parent . \
        -title "Scid: Unable to create base" -message $result
    }
  }
  updateGList
  ::tree::refresh
  updateMenuStates
  updateTitle
  updateStatusBar
}

# fileOpen:
#    Opens file-open dialog and opens the selected Scid database.
#
proc fileOpen {{fName ""}} {
  global glstart
  if {[sc_base count free] == 0} {
    tk_messageBox -type ok -icon info -title "Scid" \
      -message "Too many databases are open; close one first"
    return
  }

  if {[sc_info gzip]} {
    set ftype {
      { "All Scid files" {".si3" ".si" ".pgn" ".pgn.gz" ".epd" ".epd.gz" ".sor"} }
      { "Scid databases, PGN files" {".si3" ".si" ".pgn" ".PGN" ".pgn.gz"} }
      { "Scid databases" {".si3" ".si"} }
      { "PGN files" {".pgn" ".PGN" ".pgn.gz"} }
      { "EPD files" {".epd" ".EPD" ".epd.gz"} }
      { "Repertoire files" {".sor"} }
    }
  } else {
    set ftype {
      { "All Scid files" {".si3" ".si" ".pgn" ".epd" ".sor"} }
      { "Scid databases, PGN files" {".si3" ".si" ".pgn" ".PGN"} }
      { "Scid databases" {".si3" ".si"} }
      { "PGN files" {".pgn" ".PGN"} }
      { "EPD files" {".epd" ".EPD"} }
      { "Repertoire files" {".sor"} }
    }
  }
  if {$fName == ""} {
    set fName [tk_getOpenFile -initialdir $::initialDir(base) -filetypes $ftype -title "Open a Scid file"]
    if {$fName == ""} { return }
  }

  if {[file extension $fName] == ""} {
    set fName "$fName.si3"
  }

  if {[file extension $fName] == ".sor"} {
    if {[catch {::rep::openWithFile $fName} err]} {
      tk_messageBox -parent . -type ok -icon info -title "Scid" \
        -message "Unable to open \"$fName\": $err"
    }
    return
  }

  if {[file extension $fName] == ".si"} {
    fileUpgrade [file rootname $fName]
    return
  }

  set err 0
  busyCursor .
  if {[file extension $fName] == ".si3"} {
    set fName [file rootname $fName]
    if {[catch {openBase $fName} result]} {
      set err 1
      tk_messageBox -icon warning -type ok -parent . \
        -title "Scid: Error opening file" -message $result
    } else {
      set ::initialDir(base) [file dirname $fName]
      ::recentFiles::add "$fName.si3"
    }
  } elseif {[regexp {\.epd} [string tolower $fName]]} {
    # EPD file:
    newEpdWin open $fName
  } else {
    # PGN file:
    set result "This file is not readable."
    if {(![file readable $fName])  || \
          [catch {sc_base create $fName true} result]} {
      set err 1
      tk_messageBox -icon warning -type ok -parent . \
        -title "Scid: Error opening file" -message $result
    } else {
      doPgnFileImport $fName "Opening [file tail $fName] read-only...\n"
      sc_base type [sc_base current] 3
      ::recentFiles::add $fName
    }
  }

  if {$err == 0} { catch {sc_game load auto} }
  unbusyCursor .
  set glstart 1
  updateGList
  ::tree::refresh
  updateStatsWin
  updateMenuStates
  updateBoardAndPgn
  updateTitle
  updateStatusBar
}

# fileUpgrade:
#   Upgrades an old (version 2) Scid database to version 3.
#
proc fileUpgrade {name} {
  if {[file readable "$name.si3"]} {
    set msg [string trim $::tr(ConfirmOpenNew)]
    set res [tk_messageBox -title "Scid" -type yesno -icon info -message $msg]
    if {$res == "no"} { return }
    fileOpen "$name.si3"
    return
  }

  set msg [string trim $::tr(ConfirmUpgrade)]
  set res [tk_messageBox -title "Scid" -type yesno -icon info -message $msg]
  if {$res == "no"} { return }
  progressWindow "Scid" "$::tr(Upgrading): [file tail $name]..."\
    $::tr(Cancel) "sc_progressBar"
  busyCursor .
  update
  set err [catch {sc_base upgrade $name} res]
  unbusyCursor .
  closeProgressWindow
  if {$err} {
    tk_messageBox -title "Scid" -type ok -icon warning \
      -message "Unable to upgrade the database:\n$res"
    return
  }
  fileOpen "$name.si3"
}

# openBase:
#    Opens a Scid database, showing a progress bar in a separate window
#    if the database is around 1 Mb or larger in size.
#
proc openBase {name} {
  set bsize 0
  set gfile "[file rootname $name].sg3"
  if {! [catch {file size $gfile} err]} { set bsize $err }
  set showProgress 0
  if {$bsize > 1000000} { set showProgress 1 }
  if {$showProgress} {
    progressWindow "Scid" "$::tr(OpeningTheDatabase): [file tail $name]..."
  }
  set err [catch {sc_base open $name} result]
  if {$showProgress} { closeProgressWindow }
  if {$err} { return -code error $result }
  return $result
}


# fileClose:
#   Closes the active base.
#
proc fileClose {} {
  if {[sc_base inUse]} {
    if ![confirmDiscardGame] { return }
    sc_base close
    updateGList
    # Close Tree and Email windows whenever a base is closed/switched:
    #if {[winfo exists .treeWin]} { destroy .treeWin }
    if {[winfo exists .emailWin]} { destroy .emailWin }
    updatePgnWin
    updateBoard
  }
  updateMenuStates
  updateStatusBar
  updateTitle
}


# confirmDiscardGame:
#   Prompts the user if they want to discard the changes to the
#   current game. Returns 1 if they selected yes, 0 otherwise.
#
proc confirmDiscardGame {} {
  if {$::trialMode} { return 1 }
  if {[sc_base isReadOnly]} { return 1 }
  if {! [sc_game altered]} { return 1 }
  set answer [ tk_dialog .cgDialog "Scid: [tr GameNew]" \
                 $::tr(ClearGameDialog) "" 0 $::tr(Yes) $::tr(No) ]
  if {$answer == 1} { return  0 }
  return 1
}

# gameClear:
#   Clears the active game, checking first if it is altered.
#   Updates any affected windows.
#
proc gameClear {} {
  if {![confirmDiscardGame]} { return }
  setTrialMode 0
  sc_game new
  updateBoardAndPgn
  updateTitle
  updateMenuStates
}

# gameStrip:
#   Strips all comments or variations from a game
#
proc gameStrip {type} {
  if {[catch {sc_game strip $type} result]} {
    tk_messageBox -parent . -type ok -icon info -title "Scid" -message $result
    return
  }
  updateBoardAndPgn
  updateTitle
}

# gameLoadNextPrev:
#   Loads the next or previous filtered game in the database.
#   The parameter <action> should be "previous" or "next".
#
proc gameLoadNextPrev {action} {
  global pgnWin statusBar
  if {![sc_base inUse]} {
    set statusBar "  There is no $action game: this is an empty database."
    return
  }
  set number [sc_filter $action]
  if {$number == 0} {
    set statusBar "  There is no $action game in the current filter."
    return
  }
  if {![confirmDiscardGame]} { return }
  setTrialMode 0
  sc_game load $number
  updateBoardAndPgn
  updateGList
  updateTitle
}

# gameReload:
#   Reloads the current game.
#
proc gameReload {} {
  if ![sc_base inUse] { return }
  if {[sc_game number] < 1} { return }
  if {![confirmDiscardGame]} { return }
  setTrialMode 0
  sc_game load [sc_game number]
  updateBoardAndPgn
  updateGList
  updateTitle
}

# gameLoadRandom:
#   Loads a random game from the database.
#
proc gameLoadRandom {} {
  set ngames [sc_filter size]
  if {$ngames == 0} { return }
  set r [expr (int (rand() * $ngames)) + 1 ]
  set gnum [sc_filter index $r]
  if {[catch {sc_game load $gnum} result]} {
    tk_messageBox -type ok -icon info -title "Scid" -message $result
  }
  updateBoardAndPgn
  updateGList
  updateTitle
}


# gameLoadNumber:
#    Prompts for the number of the game to load
set glEntryNumber ""
trace variable glEntryNumber w {forceRegexp {^[0-9]*$}}

proc gameLoadNumber {} {
  global glEntryNumber
  set glEntryNumber ""
  if {![sc_base inUse]} { return }
  if {[sc_base numGames] < 1} { return }
  set w [toplevel .glnumDialog]
  wm title $w "Scid: [tr GameNumber]"
  grab $w

  label $w.label -text $::tr(LoadGameNumber)
  pack $w.label -side top -pady 5 -padx 5

  entry $w.entry -background white -width 10 -textvariable glEntryNumber
  bind $w.entry <Escape> { .glnumDialog.buttons.cancel invoke }
  bind $w.entry <Return> { .glnumDialog.buttons.load invoke }
  pack $w.entry -side top -pady 5

  set b [frame $w.buttons]
  pack $b -side top -fill x
  button $b.cancel -text $::tr(Cancel) -command {
    focus .
    grab release .glnumDialog
    destroy .glnumDialog
    focus .
  }
  button $b.load -text "OK" -command {
    grab release .glnumDialog
    if {[catch {sc_game load $glEntryNumber} result]} {
      tk_messageBox -type ok -icon info -title "Scid" -message $result
    }
    focus .
    destroy .glnumDialog
    updateBoardAndPgn
    updateGList
    updateTitle
  }
  pack $b.cancel $b.load -side right -padx 5 -pady 5

  set x [ expr [winfo width .] / 4 + [winfo rootx .] ]
  set y [ expr [winfo height .] / 4 + [winfo rooty .] ]
  wm geometry $w "+$x+$y"

  focus $w.entry
}

# gameLoad:
#   Loads a specified game from the active database.
#
proc gameLoad { selection } {
  # If an invalid game number, just return:
  if {$selection < 1} { return }
  if {$selection > [sc_base numGames]} { return }
  setTrialMode 0
  sc_game load $selection
  updateBoardAndPgn
  updateGList
  updateTitle
}

# gameLoadMenu:
#   Produces a popup dialog for loading a game or other actions
#   such as merging it into the current game.
#
proc gameLoadMenu {w base gnum x y} {
  set m $w.gLoadMenu
  if {! [winfo exists $m]} {
    menu $m
    $m add command -label $::tr(BrowseGame)
    $m add command -label $::tr(LoadGame)
    $m add command -label $::tr(MergeGame)
  }
  $m entryconfigure 0 -command "::gbrowser::new $base $gnum"
  $m entryconfigure 1 -command "sc_base switch $base; gameLoad $gnum"
  $m entryconfigure 2 -command "mergeGame $base $gnum"
  event generate $w <ButtonRelease-1>
  $m post $x $y
  event generate $m <ButtonPress-1>
}

# gotoMoveNumber:
#    Prompts for the move number to go to in the current game.
set moveEntryNumber ""
trace variable moveEntryNumber w {forceRegexp {^[0-9]*$}}

proc gotoMoveNumber {} {
  global moveEntryNumber
  set moveEntryNumber ""
  set w [toplevel .mnumDialog]
  wm title $w "Scid: [tr GameGotoMove]"
  grab $w

  label $w.label -text $::tr(GotoMoveNumber)
  pack $w.label -side top -pady 5 -padx 5

  entry $w.entry -background white -width 10 -textvariable moveEntryNumber
  bind $w.entry <Escape> { .mnumDialog.buttons.cancel invoke }
  bind $w.entry <Return> { .mnumDialog.buttons.load invoke }
  pack $w.entry -side top -pady 5

  set b [frame $w.buttons]
  pack $b -side top -fill x
  button $b.cancel -text $::tr(Cancel) -command {
    focus .
    grab release .mnumDialog
    destroy .mnumDialog
    focus .
  }
  button $b.load -text "OK" -command {
    grab release .mnumDialog
    if {$moveEntryNumber > 0} {
      catch {sc_move ply [expr ($moveEntryNumber - 1) * 2]}
    }
    focus .
    destroy .mnumDialog
    updateBoardAndPgn
  }
  pack $b.cancel $b.load -side right -padx 5 -pady 5

  set x [ expr [winfo width .] / 4 + [winfo rootx .] ]
  set y [ expr [winfo height .] / 4 + [winfo rooty .] ]
  wm geometry $w "+$x+$y"

  focus $w.entry
}

# findNovelty:
#   Searches the for first position in the current game not
#   found in the selected database.

set noveltyOlder 0

proc findNovelty {} {
  global noveltyBase noveltyOlder
  set noveltyBase [sc_base current]
  set w .noveltyWin
  if {[winfo exists $w]} {
    updateNoveltyWin
    return
  }
  toplevel $w
  wm title $w "Scid: $::tr(FindNovelty)"

  pack [frame $w.help] -side top -fill x
  text $w.help.text -width 1 -height 5 -wrap word \
    -relief ridge -cursor top_left_arrow -yscrollcommand "$w.help.ybar set"
  scrollbar $w.help.ybar -orient vertical -command "$w.help.text yview" \
    -takefocus 0 -width 10
  pack $w.help.ybar -side right -fill y
  pack $w.help.text -side left -fill x -expand yes
  $w.help.text insert end [string trim $::tr(NoveltyHelp)]
  $w.help.text configure -state disabled

  label $w.title -text $::tr(Database:) -font font_Bold
  pack $w.title -side top
  set numBases [sc_base count total]
  for {set i 1} {$i <= $numBases} {incr i} {
    radiobutton $w.b$i -text "" -variable noveltyBase -value $i -underline 5
    pack $w.b$i -side top -anchor w -padx 10
  }
  addHorizontalRule $w

  label $w.which -text $::tr(TwinsWhich:) -font font_Bold
  pack $w.which -side top
  radiobutton $w.all -text $::tr(SelectAllGames) \
    -variable noveltyOlder -value 0
  radiobutton $w.older -text $::tr(SelectOlderGames) \
    -variable noveltyOlder -value 1
  pack $w.all $w.older -side top -anchor w -padx 10

  addHorizontalRule $w

  label $w.status -text "" -width 1 -font font_Small -relief sunken -anchor w
  pack $w.status -side bottom -fill x
  pack [frame $w.b] -side top -fill x
  button $w.b.stop -textvar ::tr(Stop) -state disabled \
    -command sc_progressBar
  button $w.b.go -text $::tr(FindNovelty) -command {
    .noveltyWin.b.stop configure -state normal
    .noveltyWin.b.go configure -state disabled
    .noveltyWin.b.close configure -state disabled
    busyCursor .
    .noveltyWin.status configure -text " ... "
    update
    grab .noveltyWin.b.stop
    if {$noveltyOlder} {
      set err [catch {sc_game novelty -older -updatelabel .noveltyWin.status $noveltyBase} result]
    } else {
      set err [catch {sc_game novelty -updatelabel .noveltyWin.status $noveltyBase} result]
    }
    grab release .noveltyWin.b.stop
    if {! $err} { set result "$::tr(Novelty): $result" }
    unbusyCursor .
    .noveltyWin.b.stop configure -state disabled
    .noveltyWin.b.go configure -state normal
    .noveltyWin.b.close configure -state normal
    .noveltyWin.status configure -text $result
    updateBoard
  }
  button $w.b.close -textvar ::tr(Close) -command {
    catch {destroy .noveltyWin}
  }
  pack $w.b.close $w.b.go $w.b.stop -side right -padx 5 -pady 2
  wm resizable $w 0 0
  focus $w.b.go
  bind $w <KeyPress-1> "$w.b1 invoke"
  bind $w <KeyPress-2> "$w.b2 invoke"
  bind $w <KeyPress-3> "$w.b3 invoke"
  bind $w <KeyPress-4> "$w.b4 invoke"
  updateNoveltyWin
}

proc updateNoveltyWin {} {
  set w .noveltyWin
  if {! [winfo exists $w]} { return }
  set numBases [sc_base count total]
  $w.older configure -text "$::tr(SelectOlderGames) (< [sc_game info date])"
  for {set i 1} {$i <= $numBases} {incr i} {
    set name [file tail [sc_base filename $i]]
    set ng [thousands [sc_base numGames $i]]
    set text "Base $i: $name ($ng $::tr(games))"
    $w.b$i configure -state normal -text $text
    if {$ng == 0} { $w.b$i configure -state disabled }
  }
}

set merge(ply) 40

# mergeGame:
#   Produces a dialog for the user to merge a selected game into
#   the current game.
#
proc mergeGame {{base 0} {gnum 0}} {
  global merge glNumber
  if {$base == 0} {
    if {$glNumber < 1} { return }
    if {$glNumber > [sc_base numGames]} { return }
    set base [sc_base current]
    set gnum $glNumber
  }
  sc_game push copy
  set err [catch {sc_game merge $base $gnum} result]
  sc_game pop
  if {$err} {
    tk_messageBox -title "Scid" -type ok -icon info \
      -message "Unable to merge the selected game:\n$result"
    return
  }
  set merge(base) $base
  set merge(gnum) $gnum
  set w .mergeDialog
  toplevel $w
  wm title $w "Scid: $::tr(MergeGame)"
  bind $w <Escape> "$w.b.cancel invoke"
  bind $w <F1> {helpWindow GameList Browsing}
  label $w.title -text $::tr(Preview:) -font font_Bold
  pack $w.title -side top
  pack [frame $w.b] -side bottom -fill x
  frame $w.f
  text $w.f.text -background white -wrap word -width 60 -height 20 \
    -font font_Small -yscrollcommand "$w.f.ybar set"
  scrollbar $w.f.ybar -takefocus 0 -command "$w.f.text yview"
  event generate $w.f.text <ButtonRelease-1>
  pack $w.f.ybar -side right -fill y
  pack $w.f.text -side left -fill both -expand yes
  pack $w.f -fill both -expand yes
  set small font_Small
  label $w.b.label -text "Up to move:" -font $small
  pack $w.b.label -side left
  foreach i {5 10 15 20 25 30 35 40} {
    radiobutton $w.b.m$i -text $i -variable merge(ply) -value [expr $i * 2] \
      -indicatoron 0 -padx 2 -pady 1 -font $small -command updateMergeGame
    pack $w.b.m$i -side left
  }
  radiobutton $w.b.all -text [capital $::tr(all)] \
    -variable merge(ply) -value 1000 -indicatoron 0 -padx 2 -pady 1 \
    -font $small -command updateMergeGame
  pack $w.b.all -side left
  button $w.b.ok -text "OK" -command {
    sc_game merge $merge(base) $merge(gnum) $merge(ply)
    catch {grab release .mergeDialog}
    destroy .mergeDialog
    updateBoardAndPgn
  }
  button $w.b.cancel -text $::tr(Cancel) \
    -command "catch {grab release $w}; destroy $w"
  pack $w.b.cancel $w.b.ok -side right -padx 2
  grab $w
  updateMergeGame
}

proc updateMergeGame {args} {
  global merge
  set w .mergeDialog
  if {! [winfo exists $w]} { return }
  sc_game push copy
  sc_game merge $merge(base) $merge(gnum) $merge(ply)
  set pgn [sc_game pgn -indentV 1 -short 1 -width 60]
  sc_game pop
  $w.f.text configure -state normal
  $w.f.text tag configure red -foreground darkRed
  $w.f.text tag configure blue -foreground darkBlue
  $w.f.text delete 1.0 end
  foreach line [split $pgn "\n"] {
    if {[string index $line 0] == " "} {
      $w.f.text insert end $line blue
    } else {
      $w.f.text insert end $line
    }
    $w.f.text insert end "\n"
  }
  $w.f.text tag add red 1.0 4.0
  #$w.f.text insert end $pgn
  $w.f.text configure -state disabled
}

# setExportText:
#   Allows the user to modify the text printed at the start and end of a
#   file for a particular export format
#
proc setExportText {exportType} {
  global exportStartFile exportEndFile

  switch -- $exportType {
    "PGN" {
      set title "Set PGN file export text"
    }
    "HTML" {
      set title "Set HTML file export text"
    }
    "LaTeX" {
      set title "Set LaTeX file export text"
    }
    default {
      return
    }
  }

  set w .setExportText$exportType
  if {[winfo exists $w]} { return }
  toplevel $w
  wm title $w "Scid: $title"

  frame $w.buttons
  pack $w.buttons -side bottom -fill x -anchor e

  set pane [::pane::create $w.pane start end 500 400]
  ::pane::range $w.pane 0.3 0.7
  pack $pane -side top -expand true -fill both
  foreach f [list $pane.start $pane.end] type {start end} {
    label $f.title -font font_Bold -text "Text at $type of $exportType file:"
    text $f.text -wrap none -background white \
      -yscroll "$f.ybar set" -xscroll "$f.xbar set"
    scrollbar $f.ybar -orient vertical -command "$f.text yview"
    scrollbar $f.xbar -orient horizontal -command "$f.text xview"
    bind $f.text <FocusIn> {%W configure -background lightYellow}
    bind $f.text <FocusOut> {%W configure -background white}
    grid $f.title -row 0 -column 0 -sticky w
    grid $f.text -row 1 -column 0 -sticky nesw
    grid $f.ybar -row 1 -column 1 -sticky nesw
    grid $f.xbar -row 2 -column 0 -sticky nesw
    grid rowconfig $f 1 -weight 1 -minsize 0
    grid columnconfig $f 0 -weight 1 -minsize 0
  }

  $pane.start.text insert end $exportStartFile($exportType)
  $pane.end.text insert end $exportEndFile($exportType)

  button $w.buttons.default -text "Reset to Default" -command "
    $pane.start.text delete 1.0 end
    $pane.start.text insert end \$default_exportStartFile($exportType)
    $pane.end.text delete 1.0 end
    $pane.end.text insert end \$default_exportEndFile($exportType)
  "
  button $w.buttons.ok -text "OK" -command "
    set exportStartFile($exportType) \[$pane.start.text get 1.0 end-1c\]
    set exportEndFile($exportType) \[$pane.end.text get 1.0 end-1c\]
    focus .
    destroy $w
  "
  button $w.buttons.cancel -text "Cancel" -command "focus .; destroy $w"
  pack $w.buttons.default -side left -padx 5 -pady 2
  pack $w.buttons.cancel $w.buttons.ok -side right -padx 5 -pady 2
  focus $pane.start.text
}

image create photo htmldiag0 -data {
R0lGODdhbgBkAIAAAAAAAP///ywAAAAAbgBkAAAC/oyPqcvtD6OctNqLs968+w+G4kiW5omm
6moAgQu/ckzPdo3fes7vfv5wsYQtBFF2OCqNzCPrs4xEi0mQEyWcApxbqhfpvYa2ZCNZeQ4y
k122YgqGNs7oMtu+aH9f6XT1vydm5ddCyIenlkB3KAgnePFIJzm5yECkRVmpuPbokflpaLl2
eKeHCNcRCQo6F3e52qY3Gve04QhbJkvrGYQb+jbrB8sHaJPi25mnGItLvDmRnLwnCpH1luUb
WGwpLdUsIdaFHLtdHe09bM45Lkw9p4uRXfHKbseFntibnk9fT/4XDR6kb+BKsfrkrFuhc+b2
OYhh0J+1Z+8U6ltVMGIm/kaTpnnL95DgQzPpMC6RJtCCPArMOmqsNDFjq4YYq5lZGKokxZEc
Vtok5pIkwl2p0NXsZZDUsmH3fmpIuWxeUKEHy828yo0dT6p5sk3sZrGrP6dWx3kMCRKYykhE
xcpD1fWpxK1tOX4LK9OtVneuliKjAnEEIqkMA9UrgjctTokCY+4a29fvL6OM2ZabW3co1peH
rwVb3DmM5lpSRlV2DHryrGPFEidqShrS59azz2Zw/TTyF0e168aG1ps3bRG4bz8pvqmH8h/M
lztvDj0wVuG7g/sW3Bv48Orbr7Purky3eOpgkMsenxcuX/XHs3NzzzG8NsJQ38EnG2Uq+rWa
/s7bVrvfRtwBxhIlLHWnEHUCklegfumtpgx5AloHjYHAMTjdahbeB46D+EG4Hoj68YaXh3Sx
B9IVrADo3TUTHmjVTHA5pFuCR70G4oeSaYZiRTemyGJcw72lIWWj2TckjKLRKN5FKypZHj/B
iBQZWFS6g2GIVI3Wo15HApljFTMSlKWLP4oyo45L8himkxuq2eJ+nKV0UoUvgvlfhmb2x2FI
JsL505hPDmjjoDx1qeWWEyK655d6tunMNGbt5N2kaF0Wlop7DejnX9qRJGWj++TnJpMUhVPf
bJhBOqehWqompmmQgbejT8Bgkup4s8aZ2pU71VGYK4xVp8qqLAJriREXw1LqpaV0xXeoqJ4C
Uuyuz2g62KvL5tnqmb8uhhS128Imra03iZvtsz2xikU8CFLInXkqvVsavZwyekKZTcArZ5Pt
6vutvf3GBjC7VrRX1HMKR8fwwg4bo26+/Eq4729FCUyxHEPcO7FpFtvSscC8DJExx9vI+3G/
JfNK1ncqh4zybyuvLEEBADs=
}

image create photo htmldiag1 -data {
R0lGODdhbgBkAIQAAAAAAAsLCxYWFiAgICsrKzY2NkBAQEtLS1VVVWBgYGtra3V1dYCAgIuL
i5WVlaCgoKqqqrW1tcDAwMrKytXV1eDg4Orq6vX19f//////////////////////////////
/ywAAAAAbgBkAAAF/iAmjmRpnmiqrmzrvnAsz3Rt33iu73zv/8CgcEgsGo/IJBGAYTqb0Kc0
Sp1aq9irNst9vphLkYWAEFEEkFGEIkIQLJhxGUMhsDGQ9wis7MnNaCducH90diJ5cBgVQ3xC
AIVnaSMLiHqRh3h6GAgNUCsRBgd3NRIAp3ymqKcMe6gSKQdzkiIScAYKJJh3iW1zLBWoAzGO
GKqnI8eorSKrsCcAk7QiDG8GAA4kjIa8mwi/xSbKN8oS5g6rpwnm5SvTcAwAA6gFtrrbvZy/
LgWnk18llKUbSPCZCSbTIBjAEIGgvAQPSEjwNscCrHAmCJzaN0Ogw48GTSQUwMaCgFMH/lAJ
YJBAwEpFI76JIRChBYJVAmAU8/ixIAoABiZBIDlCAQACFfrJY2Qh3oAJMSsSmIRxBIR0w2zc
7PmRYwlFQ0lNOLXQwqoEjCaczEZn5j8VFU7i1CnoFLu7eM1tVAEmLIl5AARYMJuu1RkAv8a8
rYpBabocKV0AONDCL0MMD7juPTwpKCJmKMYSpHsiHoPTqFOnBgD6p2UEEa8JANyVzklSeIhW
dfwYRzzNy1gguDOoCS+uZdARsEo0BYWPpE38Bs56BZ/iwQrcudazZr+IEZp/KjF9YI7ymlur
KN6YrEa5HwUHG1bhzrYT3EcDLE2dlXVOmzTUX3AJAEAKAq1g/pSfeb4NqN4JCmwS14DCMARA
JQDCZMKCvUmGAnpcPVjChYqMgdxHbMijiSIYgYjKeQ7CoJEBGhGUy0etXFPBYKBAt590MfIV
h0XVmVVAjQQcABVPZGFQYE1xXIQCfAMsEIE5MPYn4ldvPCdBeNk4RUID8WFgWhwEeJLCAqew
NUNV8Ui25R6yiEDAAC6J0A9UI/Bm3pl1jldCMMtFkAB3OJgo2SYp/HMYA3VEQ4KAKJpC2X0q
sEkbAyGxEI6JQBkg6qikjnoKoweJsOMiFBAKJSBc6bUQCYzFQ+YpA8xaQ0oUouROJiiEp5le
GFIQkQrTCWDAadGJQRuFA2hIax28/qg5ggV+gmSKYQLUxBiZNOUAaq+nShtTN4owVSNwFpDZ
ylQsmGJLA4fq2oIjLlIoIh/5DIeBUf2ZCUBNrzLR1IIDaPQsYyzkGyQK/ZYRzIBOGmiCSQH/
KDC5q+y7oi8i3KrlPFYlyKZmVc7ZMMcdQ0zRCBOUKvPMuCDSHIcEudlsECSCHOUNzU2mLAMN
5IVlHzLIhOZbM2CKKQ8M7wCG0orZTNwlZAAilHiCIu3117R2IfYWZI9tdtlo0xBJILldTUjW
3FhirhFrb42bh3VbLYICB7w9Syb5MBK1DgbDPdIducCQd9snUKAmtXK3YW0Ri1smw2SzsG05
HUTfB/nH/vo088IDpzUwN1+BHk7C3SxIo3lzjGzlDwYXAP6y4usGxvoKrtutKieDh22b75xU
IJpKcOBzu+grp1MAaaoXL5oM0SPwPIgGRSxGpyrgHHwJ1V+PzBfV63E8KttEcPsY3rYAYlaS
lQ/H9DB4xjgGCyygyAPwAWUu1fByQVMG4pUV2M8y+dvfSXQCFq7F4QG5UwlEKCGVfzCsAg3o
3yqqxCfrNPBuFoDgi2RgmQTAQVhceYouAtg8zRTgaY1qjgkZokG6vKYVlAIOn6qGhwShAGDU
EYyQbmghBr3gNXpYWArtRLwTTGxACeBdc4qjxO81w18ZMkavTqi3rlGjV8tJ/gFi3KZF/SRt
ExSQWTqUVar7bO4EDyhVBOVRKsrYBI1qtOInisOjg6zCXiWwjOBa4BGVpSqLfRyRHtuANfuQ
Ih2AZA5xDCmRgVDSBHzMRH1coZMI+c0MmcjhKdRFvOIED4j06CTW/nYHAcVAf2hi5QjmWIkH
lBJVK3hiOjrYAljuYpbj81AsQUmK5wwkJ5JkJEwGl68oCvOXZhgh7mRJCYdACYmE4B4KqhiY
GEBTBCfTIyQMB7iaeK864SHjGDwRNV0OBIY/gSYEzClNF6TOdnD4yEIeoE64xasn2kTBPdHV
hHp6Shr4tJNDMKTMYTLPOT3ZHTQQSlAMrGsGn8tH/hHXeKBVxkB26QgjDDLKKErRhaTSoqU2
PkmHiAzOna8ACEpLUKMYzDQOETgNQQZwGoOs7VUoqEBOC0SQBHAKniJJKE51Gsx7YbEXFiAq
cFYiArZMAyMUyFZPCsDLgzz1ElJdBQ2gOkfN/GIaKDhMr4DaKKw5hDT5EBmFoIJWL/KqV8iE
RuQwINcOHZFR50wPBg4glC2xDAAB3SsGAquTfKSBdKqJrGQ5RQK/hGOymFUNUqOxicdi9pWK
QEDicPBGIsCSE6PFwXUqwoALiCACbmrAJJrCJwq0tote/MFqxXBbhugsaRXsYiYz10QlALCU
OwPCImmwXLqk7blniy50waebXN1qTbgeHd5elfZQsN1Afg5NyPpOJ7UiGOh1/STudqWSIu/i
AL0Nrdz6WMgz815zitkVb2iD21331gCb4dXcfJlW3zAAWL77dYsZBunf/+KXpfr1GQ/rgNTy
LuHBARbKgInZ3wbDYBvDvS7ojsvhMJg4xNodMX8/12EPvwDFEQ7d0kqMgMQSzrwwFnCCZxy3
LDbXxfnVsYQD+Dn2PMK8M1GvihXcYyP/2MUIHjJF40veGy8hyjKecCYyKSUYhAAAOw==
}

# exportOptions:
#   Prompts the user to select exporting options.
#
proc exportOptions {exportType} {
  global exportFlags

  set w .exportFlagsWin
  set exportFlags(ok) -1
  toplevel $w
  wm title $w "Scid: [tr OptionsExport]"
  wm transient $w .
  wm protocol $w WM_DELETE_WINDOW { }
  bind $w <Escape> "$w.b.cancel invoke"
  bind $w <Return> "$w.b.ok invoke"
  bind $w <F1> {helpWindow Export}

  pack [frame $w.o] -side top -fill x -pady 5 -padx 5
  label $w.o.append -text $::tr(AddToExistingFile)
  radiobutton $w.o.appendYes -text $::tr(Yes) \
    -variable exportFlags(append) -value 1
  radiobutton $w.o.appendNo -text $::tr(No) \
    -variable exportFlags(append) -value 0
  label $w.o.comments -text $::tr(ExportComments)
  radiobutton $w.o.commentsOn -text $::tr(Yes) \
    -variable exportFlags(comments) -value 1
  radiobutton $w.o.commentsOff -text $::tr(No) \
    -variable exportFlags(comments) -value 0
  label $w.o.stripMarks -text $::tr(ExportStripMarks)
  radiobutton $w.o.stripMarksOn -text $::tr(Yes) \
    -variable exportFlags(stripMarks) -value 1
  radiobutton $w.o.stripMarksOff -text $::tr(No) \
    -variable exportFlags(stripMarks) -value 0
  label $w.o.indentc -text $::tr(IndentComments)
  radiobutton $w.o.indentcOn -text $::tr(Yes) \
    -variable exportFlags(indentc) -value 1
  radiobutton $w.o.indentcOff -text $::tr(No) \
    -variable exportFlags(indentc) -value 0
  label $w.o.vars -text $::tr(ExportVariations)
  radiobutton $w.o.varsOn -text $::tr(Yes) -variable exportFlags(vars) -value 1
  radiobutton $w.o.varsOff -text $::tr(No) -variable exportFlags(vars) -value 0
  label $w.o.indentv -text $::tr(IndentVariations)
  radiobutton $w.o.indentvOn -text $::tr(Yes) \
    -variable exportFlags(indentv) -value 1
  radiobutton $w.o.indentvOff -text $::tr(No) \
    -variable exportFlags(indentv) -value 0
  label $w.o.column -text $::tr(ExportColumnStyle)
  radiobutton $w.o.columnOn -text $::tr(Yes) \
    -variable exportFlags(column) -value 1
  radiobutton $w.o.columnOff -text $::tr(No) \
    -variable exportFlags(column) -value 0
  label $w.o.symbols -text $::tr(ExportSymbolStyle)
  radiobutton $w.o.symbolsOn -text "! +=" \
    -variable exportFlags(symbols) -value 1
  radiobutton $w.o.symbolsOff -text {$2 $14} \
    -variable exportFlags(symbols) -value 0
  grid $w.o.append -row 0 -column 0 -sticky w
  grid $w.o.appendYes -row 0 -column 1 -sticky w
  grid $w.o.appendNo -row 0 -column 2 -sticky w
  grid $w.o.comments -row 1 -column 0 -sticky w
  grid $w.o.commentsOn -row 1 -column 1 -sticky w
  grid $w.o.commentsOff -row 1 -column 2 -sticky w
  grid $w.o.stripMarks -row 2 -column 0 -sticky w
  grid $w.o.stripMarksOn -row 2 -column 1 -sticky w
  grid $w.o.stripMarksOff -row 2 -column 2 -sticky w
  grid $w.o.indentc -row 3 -column 0 -sticky w
  grid $w.o.indentcOn -row 3 -column 1 -sticky w
  grid $w.o.indentcOff -row 3 -column 2 -sticky w
  grid $w.o.vars -row 4 -column 0 -sticky w
  grid $w.o.varsOn -row 4 -column 1 -sticky w
  grid $w.o.varsOff -row 4 -column 2 -sticky w
  grid $w.o.indentv -row 5 -column 0 -sticky w
  grid $w.o.indentvOn -row 5 -column 1 -sticky w
  grid $w.o.indentvOff -row 5 -column 2 -sticky w
  grid $w.o.column -row 6 -column 0 -sticky w
  grid $w.o.columnOn -row 6 -column 1 -sticky w
  grid $w.o.columnOff -row 6 -column 2 -sticky w
  grid $w.o.symbols -row 7 -column 0 -sticky w
  grid $w.o.symbolsOn -row 7 -column 1 -sticky w
  grid $w.o.symbolsOff -row 7 -column 2 -sticky w

  # Extra option for PGN format: handling of null moves
  if {$exportType == "PGN"} {
    label $w.o.space -text ""
    grid $w.o.space -row 8 -column 0 -sticky w
    label $w.o.nullMoves -text "Convert null moves to comments"
    radiobutton $w.o.convertNullMoves -text $::tr(Yes) \
      -variable exportFlags(convertNullMoves) -value 1
    radiobutton $w.o.keepNullMoves -text $::tr(No) \
      -variable exportFlags(convertNullMoves) -value 0    
    grid $w.o.nullMoves -row 9 -column 0 -sticky w
    grid $w.o.convertNullMoves -row 9 -column 1 -sticky w
    grid $w.o.keepNullMoves -row 9 -column 2 -sticky w
  }

  # Extra option for HTML format: diagram image set
  if {$exportType == "HTML"} {
    label $w.o.space -text ""
    label $w.o.hdiag -text "Diagram"
    radiobutton $w.o.hb0 -text "bitmaps" \
      -variable exportFlags(htmldiag) -value 0
    radiobutton $w.o.hb1 -text "bitmaps2" \
      -variable exportFlags(htmldiag) -value 1
    label $w.o.hl0 -image htmldiag0
    label $w.o.hl1 -image htmldiag1
    grid $w.o.space -row 8 -column 0
    grid $w.o.hdiag -row 9 -column 0 -sticky w
    grid $w.o.hb0 -row 9 -column 1 -sticky w
    grid $w.o.hb1 -row 9 -column 2 -sticky w
    grid $w.o.hl0 -row 10 -column 1
    grid $w.o.hl1 -row 10 -column 2
  }

  addHorizontalRule $w
  pack [frame $w.b] -side top
  button $w.b.ok -text "OK" -command {
    set exportFlags(ok) 1
  }
  button $w.b.cancel -text $::tr(Cancel) -command {
    set exportFlags(ok) 0
  }
  pack $w.b.ok $w.b.cancel -side left -padx 5 -pady 5

  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
                 - [winfo vrootx [winfo parent $w]]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
                 - [winfo vrooty [winfo parent $w]]}]
  wm geom $w +$x+$y
  wm deiconify $w

  grab $w
  tkwait variable exportFlags(ok)
  grab release $w
  destroy $w
  return $exportFlags(ok)
}

# exportGames:
#   exports current game or all filtered games to a new PGN, LaTeX or Html file.
#
proc exportGames {selection exportType} {
  global pgnMoveNumSpace exportStartFile exportEndFile exportFlags
  set exportFilter 0
  if {$selection == "filter"} { set exportFilter 1 }
  if {$exportFilter} {
    # Check that we have some games to export:
    if {![sc_base inUse]} {
      tk_messageBox -title "Scid: Empty database" -type ok -icon info \
        -message "This is an empty database, there are no games to export."
      return
    }
    if {[sc_filter count] == 0} {
      tk_messageBox -title "Scid: Filter empty" -type ok -icon info \
        -message "The filter contains no games."
      return
    }
  }

  if {[exportOptions $exportType] == 0} { return }
  sc_info html $exportFlags(htmldiag)

  switch -- $exportType {
    "PGN" {
      set ftype {
        { "PGN files" {".pgn"} }
        { "All files" {"*"} }
      }
      set title "a PGN file"
      set idir $::initialDir(base)
      set default ".pgn"
    }
    "HTML" {
      set ftype {
        { "HTML files" {".html" ".htm"} }
        { "All files" {"*"} }
      }
      set title "an HTML file"
      set idir $::initialDir(html)
      set default ".html"
    }
    "LaTeX" {
      set ftype {
        { "LaTeX files" {".tex" ".ltx"} }
        { "All files" {"*"} }
      }
      set title "a LaTeX file"
      set idir $::initialDir(tex)
      set default ".tex"
    }
    default { return }
  }

  if {$exportFlags(append)} { 
    set getfile tk_getOpenFile 
    set title "Add games to $title"
  } else {
    set getfile tk_getSaveFile
    set title "Create $title"
  }
  set fName [$getfile -initialdir $idir -filetypes $ftype \
               -defaultextension $default -title $title]
  if {$fName == ""} { return }

  if {$exportFilter} {
    progressWindow "Scid" "Exporting games..." $::tr(Cancel) "sc_progressBar"
  }
  busyCursor .
  sc_base export $selection $exportType $fName -append $exportFlags(append) \
    -starttext $exportStartFile($exportType) \
    -endtext $exportEndFile($exportType) \
    -comments $exportFlags(comments) -variations $exportFlags(vars) \
    -space $pgnMoveNumSpace -symbols $exportFlags(symbols) \
    -indentC $exportFlags(indentc) -indentV $exportFlags(indentv) \
    -column $exportFlags(column) -noMarkCodes $exportFlags(stripMarks) \
    -convertNullMoves $exportFlags(convertNullMoves)
  unbusyCursor .
  if {$exportFilter} {
    closeProgressWindow
  }
}



proc copyFilter {frombaseNum tobaseNum} {
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
    set err "$::tr(CopyErrSource) $::tr(CopyErrNoGames)."
  }
  if {$targetReadOnly} {
    set err "$::tr(CopyErrTarget) ($targetName) $::tr(CopyErrReadOnly)."
  }
  if {! $targetInUse} {set err "$::tr(CopyErrTarget) $::tr(CopyErrNotOpen)."}
  if {! $fromInUse} {set err "$::tr(CopyErrSource) $::tr(CopyErrNotOpen)."}
  if {$frombaseNum == $tobaseNum} {
    set err "$::tr(CopyErrSource) == $::tr(CopyErrTarget)."
  }

  if {$err != ""} {
    tk_messageBox -type ok -icon info -title "Scid" \
      -message "$::tr(CopyErr) \n\"$fromName\" -> \"$targetName\": \n$err"
    return
  }

  # If copying to the clipbase, do not bother asking for confirmation:
  if {$tobaseNum == [sc_info clipbase]} {
    progressWindow "Scid" "$::tr(CopyGames)..." $::tr(Cancel) "sc_progressBar"
    busyCursor .
    set copyErr [catch {sc_filter copy $frombaseNum $tobaseNum} result]
    unbusyCursor .
    closeProgressWindow
    if {$copyErr} {
      tk_messageBox -type ok -icon info -title "Scid" -message $result
    }
    return
  }

  set w [toplevel .fcopyWin]
  wm title $w "Scid: $::tr(CopyGames)"
  label $w.text -text [subst $::tr(CopyConfirm)]
  frame $w.b
  button $w.b.go -text $::tr(CopyGames) -command "
    busyCursor .
    $w.b.cancel configure -command \"sc_progressBar\"
    $w.b.cancel configure -text $::tr(Stop)
    sc_progressBar $w.bar bar 301 21 time
    grab $w.b.cancel
    if {\[catch {sc_filter copy $frombaseNum $tobaseNum} result\]} {
      tk_messageBox -type ok -icon info \
        -title \"Scid\" -message \$result
    }
    unbusyCursor .
    focus .
    destroy $w
    updateStatusBar
  "
  button $w.b.cancel -text $::tr(Cancel) -command "focus .; destroy $w"
  canvas $w.bar -width 300 -height 20 -bg white -relief solid -border 1
  $w.bar create rectangle 0 0 0 0 -fill blue -outline blue -tags bar
  $w.bar create text 295 10 -anchor e -font font_Regular -tags time \
    -fill black -text "0:00 / 0:00"

  pack $w.text $w.b -side top -pady 5
  pack $w.bar -side bottom
  pack $w.b.go $w.b.cancel -side left -padx 10 -pady 10
  grab $w
  bind $w <Return> "$w.b.go invoke"
  bind $w <Escape> "$w.b.cancel invoke"
  focus $w.b.go
}


###########################################################################
### Global variables used in gameSave:
set date 0; set year 0; set month 0; set day 0; set white 0; set black 0
set resultVal 0; set event 0; set site 0; set round 0
set whiteElo 0; set blackElo 0; set eco 0; set extraTags ""
set whiteRType "Elo"; set blackRType "Elo"
set edate 0; set eyear 0; set emonth 0; set eday 0

# Traces on game-save dialog variables to ensure sane values:

trace variable resultVal w  forceResult
trace variable whiteElo w {forceInt [sc_info limit elo] 0}
trace variable blackElo w {forceInt [sc_info limit elo] 0}
trace variable year w {forceInt [sc_info limit year] 1}
trace variable month w {forceInt 12 1}
trace variable day w {forceInt 31 1}
trace variable eyear w {forceInt [sc_info limit year] 1}
trace variable emonth w {forceInt 12 1}
trace variable eday w {forceInt 31 1}

set gsaveNum 0
set i 0; set j 0
set temp 0

array set nameMatches {}
set nameMatchCount 0

# updateMatchList:
#    Called from gameSave to update the matching name list as the user
#    types a player/site/event/round name.
#
proc updateMatchList { tw nametype maxMatches name el op } {
  global nameMatches nameMatchCount
  global $name editNameType
  if {![winfo exists $tw]} return

  if {$nametype == ""} { set nametype $editNameType }
  if {$nametype == "rating"} { set nametype "player" }
  set val [set $name]
  $tw configure -state normal
  $tw delete 0.0 end
  set matches {}
  catch {set matches [sc_name match $nametype $val $maxMatches]}
  set count [llength $matches]
  set nameMatchCount [expr $count / 2]
  for {set i 0} { $i < $count } {incr i 2} {
    set nameMatchCount [expr ($i / 2) + 1]
    set nameMatches($nameMatchCount) [lindex $matches [expr $i + 1]]
    set str "$nameMatchCount:\t[lindex $matches $i]\t$nameMatches($nameMatchCount)\n"
    $tw insert end $str
  }
  $tw configure -state disabled
}

proc clearMatchList { tw } {
  global nameMatches nameMatchCount
  set nameMatchCount 0
  $tw configure -state normal
  $tw delete 0.0 end
  $tw configure -state disabled
}

# Traces to update the match list as names are typed in:

trace variable event w { updateMatchList .save.g.list e 9 }
trace variable site  w { updateMatchList .save.g.list s 9 }
trace variable white w { updateMatchList .save.g.list p 9 }
trace variable black w { updateMatchList .save.g.list p 9 }
trace variable round w { updateMatchList .save.g.list r 9 }

set editName ""
set editNameNew ""
set editNameType "player"
set editNameSelect "all"
set editNameRating ""
set editNameRType "Elo"
set editDate ""
set editDateNew ""

trace variable editNameRating w {forceInt [sc_info limit elo] 0}
trace variable editName w { updateMatchList .nedit.g.list "" 9 }
trace variable editDate w forceDate
trace variable editDateNew w forceDate

proc editNameNewProc { tw nametype maxMatches name el op } {
  global editNameNew
  if {! [winfo exists .nedit]} { return } 
  if {[string compare $editNameNew ""]} {
    .nedit.buttons.replace configure -state normal
  } else {
    .nedit.buttons.replace configure -state disabled
  }
  catch {updateMatchList $tw $nametype $maxMatches $name $el $op}
}

trace variable editNameNew w { editNameNewProc .nedit.g.list "" 9 }


set nameEditorWin 0

proc makeNameEditor {} {
  if {! [winfo exists .nedit]} { nameEditor }
}

proc setNameEditorType {type} {
  if {! [winfo exists .nedit]} { return }
  catch {.nedit.typeButtons.$type invoke}
}

proc nameEditor {} {
  global editName editNameType editNameNew nameEditorWin editNameSelect
  global editNameRating editDate editDateNew

  set w .nedit
  if {[winfo exists $w]} {
    destroy $w
    return
  }
  toplevel $w
  wm title $w "Scid: [tr FileMaintNameEditor]"
  set nameEditorWin 1
  setWinLocation $w
  bind $w <Configure> "recordWinSize $w"

  label $w.typeLabel -textvar ::tr(NameEditType:) -font font_Bold
  frame $w.typeButtons
  pack $w.typeLabel $w.typeButtons -side top -pady 5
  foreach i { "Player" "Event" "Site" "Round"} {
    set j [string tolower $i]
    radiobutton $w.typeButtons.$j -textvar ::tr($i) -variable editNameType \
      -value $j -indicatoron false -pady 5 -padx 5 -command {
        grid remove .nedit.g.ratingE
        grid remove .nedit.g.rtype
        grid remove .nedit.g.fromD
        grid remove .nedit.g.toD
        grid .nedit.g.toL -row 1 -column 1 -sticky e
        grid .nedit.g.fromE -row 0 -column 2 -sticky w
        grid .nedit.g.toE -row 1 -column 2 -sticky w
      }
    pack $w.typeButtons.$j -side left -padx 5
  }
  radiobutton $w.typeButtons.rating -textvar ::tr(Rating) -variable editNameType \
    -value rating -indicatoron false -pady 5 -padx 5 -command {
      grid remove .nedit.g.toE
      grid remove .nedit.g.toL
      grid remove .nedit.g.fromD
      grid remove .nedit.g.toD
      grid .nedit.g.fromE -row 0 -column 2 -sticky w
      grid .nedit.g.rtype -row 1 -column 0 -columnspan 2 -sticky e
      grid .nedit.g.ratingE -row 1 -column 2 -sticky w
    }
  radiobutton $w.typeButtons.date -textvar ::tr(Date) -variable editNameType \
    -value date -indicatoron false -pady 5 -padx 5 -command {
      grid remove .nedit.g.toE
      grid remove .nedit.g.fromE
      grid remove .nedit.g.ratingE
      grid remove .nedit.g.rtype
      grid .nedit.g.fromD -row 0 -column 2 -sticky w
      grid .nedit.g.toL -row 1 -column 1 -sticky e
      grid .nedit.g.toD -row 1 -column 2 -sticky w
    }
  pack $w.typeButtons.rating $w.typeButtons.date -side left -padx 5

  addHorizontalRule .nedit

  label $w.selectLabel -textvar ::tr(NameEditSelect) -font font_Bold
  frame $w.selectButtons
  pack $w.selectLabel $w.selectButtons -side top -pady 5
  foreach i {all filter crosstable} row {0 1 2} text {
    SelectAllGames 
    SelectFilterGames 
    SelectTournamentGames
  } {
    radiobutton $w.selectButtons.$i -textvar ::tr($text) \
      -variable editNameSelect -value $i -pady 5 -padx 5 -indicatoron false
    grid $w.selectButtons.$i -row $row -column 0 -sticky we
  }

  addHorizontalRule $w

  pack [frame $w.g] -side top
  label $w.g.space -text "    "
  grid $w.g.space $w.g.space -row 0 -column 0
  label $w.g.fromL -textvar ::tr(NameEditReplace:) -font font_Bold -anchor e
  entry $w.g.fromE -width 40 -background white -relief sunken \
    -textvariable editName
  entry $w.g.fromD -width 15 -background white -relief sunken \
    -textvariable editDate
  grid $w.g.fromL -row 0 -column 1 -sticky e
  grid $w.g.fromE -row 0 -column 2 -sticky we

  label $w.g.toL -textvar ::tr(NameEditWith:) -font font_Bold -anchor e
  entry $w.g.toE -width 40 -background white -relief sunken \
    -textvariable editNameNew
  entry $w.g.toD -width 15 -background white -relief sunken \
    -textvariable editDateNew
  grid $w.g.toL -row 1 -column 1 -sticky e
  grid $w.g.toE -row 1 -column 2 -sticky we

  entry $w.g.ratingE -width 5 -background white -relief sunken \
    -textvariable editNameRating -justify right
  eval tk_optionMenu $w.g.rtype editNameRType [sc_info ratings]
  $w.g.rtype configure -pady 2

  label $w.g.title -textvar ::tr(NameEditMatches) \
    -font font_Bold
  text $w.g.list -height 9 -width 40 -relief sunken \
    -background grey90 -tabs {2c right 2.5c left} -wrap none

  label $w.g.padding -text ""
  grid $w.g.padding -row 2 -column 0

  grid $w.g.title -row 3 -column 1 -columnspan 2 -sticky n
  grid $w.g.list -row 4 -column 1 -rowspan 9 -columnspan 2 -sticky n

  updateMatchList $w.g.list "" 9 editName "" w

  foreach i {fromE toE ratingE fromD toD} {
    bind $w.g.$i <FocusIn> { %W configure -background lightYellow }
    bind $w.g.$i <FocusOut> { %W configure -background white }
  }
  foreach {i j} {.nedit.g.fromE "editName"  .nedit.g.toE "editNameNew" } {
    for {set z 1} {$z <= 9} {incr z} {
      bind $i [format "<Control-Key-%d>" $z] \
        [format "eval {if {\$nameMatchCount >= %d} { \
                         set %s \$nameMatches(%d)}}; break" $z $j $z ]
    }
  }

  addHorizontalRule $w

  frame $w.buttons
  button $w.buttons.replace -textvar ::tr(NameEditReplace) -command {
    if {$editNameType == "rating"} {
      set err [catch {sc_name edit $editNameType $editNameSelect $editName $editNameRating $editNameRType} result]
    } elseif {$editNameType == "date"} {
      set err [catch {sc_name edit $editNameType $editNameSelect $editDate $editDateNew} result]
    } else {
      set err [catch {sc_name edit $editNameType $editNameSelect $editName $editNameNew} result]
    }
    if {$err} {
      tk_messageBox -type ok -icon info -parent .nedit -title "Scid" \
        -message $result
    } else {
      .nedit.status configure -text $result
    }
    sc_game tags reload
    updateBoardAndPgn
    updateGList
  }

  button $w.buttons.cancel -textvar ::tr(Close) -command {focus .; destroy .nedit}
  pack $w.buttons -side top -pady 5
  pack $w.buttons.replace $w.buttons.cancel -side left -padx 10

  label $w.status -text "" -width 1 -font font_Small -relief sunken -anchor w
  pack $w.status -side bottom -fill x

  wm resizable $w 0 0
  bind $w <Escape> { focus .; destroy .nedit }
  bind $w <Return> {.nedit.buttons.replace invoke}
  bind $w <Destroy> {set nameEditorWin 0}
  bind $w <F1> {helpWindow Maintenance Editing}
  standardShortcuts $w
  focus $w
  $w.typeButtons.$editNameType invoke
}


# addGameSaveEntry:
#   used in gameSave for setting up the simpler labels and entry boxes.
#
proc addGameSaveEntry { name row textname } {
  label .save.g.${name}label -textvar $textname
  entry .save.g.${name}entry -width 30 -background white -relief sunken \
    -textvariable $name
  grid .save.g.${name}label -row $row -column 0 -sticky w
  grid .save.g.${name}entry -row $row -column 1 -columnspan 7 -sticky w
}

# gameSave:
#   The game save dialog. Used for adding and replacing games. If the
#   value gnum is zero, it is to add a new game; otherwise it is to
#   replace game number gnum.
#
proc gameSave { gnum } {
  global date year month day white black resultVal event site round
  global whiteElo blackElo whiteRType blackRType eco extraTags gsaveNum
  global edate eyear emonth eday

  if {![sc_base inUse]} {
    # We can't load a game, no database is open
    tk_messageBox -title "Scid: No database open" -type ok -icon info \
      -message "No database is open; open or create one first."
    return
  }

  # Make a new toplevel that contains the game save dialog:
  set w .save
  toplevel $w
  if {$gnum == 0} {
    wm title $w "Scid: [tr GameAdd]"
  } else {
    wm title $w "Scid: [tr GameReplace]"
  }
  set gsaveNum $gnum
  catch {grab $w}

  set f [frame $w.g]
  pack $f -side top

  label $f.title -textvar ::tr(NameEditMatches)
  text $f.list -height 9 -width 40 -relief sunken -background grey90 \
    -tabs {2c right 2.5c left} -wrap none

  # Get current values of tags:
  set year [sc_game tag get Year];    set eyear [sc_game tag get EYear]
  set month [sc_game tag get Month];  set emonth [sc_game tag get EMonth]
  set day [sc_game tag get Day];      set eday [sc_game tag get EDay]
  set white [sc_game tag get White];  set black [sc_game tag get Black]
  set event [sc_game tag get Event];  set site [sc_game tag get Site]
  set resultVal [sc_game tag get Result];  set round [sc_game tag get Round]
  set whiteElo [sc_game tag get WhiteElo]
  set blackElo [sc_game tag get BlackElo]
  set whiteRType [sc_game tag get WhiteRType]
  set blackRType [sc_game tag get BlackRType]
  set eco [sc_game tag get ECO];  set extraTags [sc_game tag get Extra]
  clearMatchList $f.list

  # Use question marks instead of zero values in date:
  if {$year == 0} { set year "????" }
  if {$month == 0} { set month "??" }
  if {$day == 0} { set day "??" }
  if {$eyear == 0} { set eyear "????" }
  if {$emonth == 0} { set emonth "??" }
  if {$eday == 0} { set eday "??" }

  addGameSaveEntry event 0 ::tr(Event:)
  addGameSaveEntry site 1 ::tr(Site:)

  frame $f.dateframe
  label $f.datelabel -textvar ::tr(Date:)
  entry $f.dateyear -width 6 -background white -relief sunken \
    -textvariable year -justify right
  label $f.datedot1 -text "."
  entry $f.datemonth -width 3 -background white -relief sunken \
    -textvariable month -justify right
  label $f.datedot2 -text "."
  entry $f.dateday -width 3 -background white -relief sunken \
    -textvariable day -justify right
  grid $f.datelabel -row 2 -column 0 -sticky w
  grid $f.dateframe -row 2 -column 1 -columnspan 5 -sticky w
  button $f.datechoose -image calendar -command {
    set newdate [::date::chooser "$year-$month-$day"]
    if {[llength $newdate] == 3} {
      set year [lindex $newdate 0]
      set month [lindex $newdate 1]
      set day [lindex $newdate 2]
    }
  }
  button $f.today -textvar ::tr(Today) -command {
    set year [::date::today year]
    set month [::date::today month]
    set day [::date::today day]
  }
  pack $f.dateyear $f.datedot1 $f.datemonth $f.datedot2 $f.dateday \
    -in $f.dateframe -side left
  if {$::tcl_version >= 8.3} {
    pack $f.datechoose -in $f.dateframe -side left
  }
  pack $f.today -in $f.dateframe -side left

  frame $f.edateframe
  label $f.edatelabel -textvar ::tr(EventDate:)
  entry $f.edateyear -width 6 -background white -relief sunken \
    -textvariable eyear -justify right
  label $f.edatedot1 -text "."
  entry $f.edatemonth -width 3 -background white -relief sunken \
    -textvariable emonth -justify right
  label $f.edatedot2 -text "."
  entry $f.edateday -width 3 -background white -relief sunken \
    -textvariable eday -justify right
  grid $f.edatelabel -row 3 -column 0 -sticky w
  grid $f.edateframe -row 3 -column 1 -columnspan 5 -sticky w
  button $f.edatechoose -image calendar -command {
    set newdate [::date::chooser "$eyear-$emonth-$eday"]
    if {[llength $newdate] == 3} {
      set eyear [lindex $newdate 0]
      set emonth [lindex $newdate 1]
      set eday [lindex $newdate 2]
    }
  }
  button $f.esame -text "=$::tr(Date)" -command {
    set eyear $year
    set emonth $month
    set eday $day
  }
  pack $f.edateyear $f.edatedot1 $f.edatemonth $f.edatedot2 $f.edateday \
    -in $f.edateframe -side left
  if {$::tcl_version >= 8.3} {
    pack $f.edatechoose -in $f.edateframe -side left
  }
  pack $f.esame -in $f.edateframe -side left

  addGameSaveEntry round 4 ::tr(Round:)
  addGameSaveEntry white 5 ::tr(White:)
  addGameSaveEntry black 6 ::tr(Black:)

  label $f.reslabel -textvar ::tr(Result:)
  entry $f.resentry -width 2 -background white -relief sunken \
    -textvariable resultVal
  label $f.rescomment -text "(1, =, 0, *)"
  grid $f.reslabel -row 7 -column 0 -sticky w
  grid $f.resentry -row 7 -column 1 -sticky w
  grid $f.rescomment -row 7 -column 2 -columnspan 4 -sticky w

  label $f.welolabel -text "$::tr(White) "
  eval tk_optionMenu $f.wrtype whiteRType [sc_info ratings]
  $f.wrtype configure -indicatoron 0 -width 7 -takefocus 1
  entry $f.weloentry -width 5 -background white -relief sunken \
    -textvariable whiteElo -justify right

  label $f.belolabel -text "$::tr(Black) "
  eval tk_optionMenu $f.brtype blackRType [sc_info ratings]
  $f.brtype configure -indicatoron 0 -width 7 -takefocus 1
  entry $f.beloentry -width 5 -background white -relief sunken \
    -textvariable blackElo -justify right

  grid $f.welolabel -row 8 -column 0 -sticky w
  grid $f.wrtype -row 8 -column 1 -sticky w
  grid $f.weloentry -row 8 -column 2 -sticky w
  grid $f.belolabel -row 9 -column 0 -sticky w
  grid $f.brtype -row 9 -column 1 -sticky w
  grid $f.beloentry -row 9 -column 2 -sticky w

  label $f.ecolabel -text "ECO Code:"
  entry $f.ecoentry -width 6 -background white -relief sunken \
    -textvariable eco
  grid $f.ecolabel -row 10 -column 0 -sticky w
  grid $f.ecoentry -row 10 -column 1 -sticky w

  button $f.ecob -textvar ::tr(ClassifyGame) -command {set eco [sc_eco game]}
  grid $f.ecob -row 10 -column 2 -sticky w

  grid $f.title -row 0 -column 8 -sticky n -padx 10
  grid $f.list -row 1 -column 8 -rowspan 9 -sticky nw -padx 10

  frame .save.bar -height 2 -borderwidth 1 -relief sunken
  pack .save.bar -fill x -pady 4

  label .save.extralabel -text \
    "Extra Tags: (example format: Annotator \"Anand, V\") "
  pack .save.extralabel -side top
  frame .save.extra
  text .save.extra.text -height 4 -width 40 -bg white -wrap none \
    -yscrollcommand ".save.extra.scroll set"
  # Override tab-binding for this text widget:
  bind .save.extra.text <Key-Tab> "[bind all <Key-Tab>]; break"
  scrollbar .save.extra.scroll -command ".save.extra.text yview" \
    -takefocus 0
  button .save.extra.last -text "Use\nlast\ngame's\ntags" -command {
    set extraTags [sc_game tag get -last Extra]
    .save.extra.text delete 1.0 end
    .save.extra.text insert 1.0 $extraTags
  }
  pack .save.extra -side top -ipady 10
  pack .save.extra.text -side left -fill both -expand 1
  if {$gnum == 0} {
    pack .save.extra.last -side right -padx 10
  }
  pack .save.extra.scroll -side right -fill y
  .save.extra.text insert 1.0 $extraTags

  foreach i {evententry siteentry dateyear datemonth dateday \
               roundentry whiteentry blackentry resentry \
               weloentry beloentry ecoentry edateyear edatemonth edateday} {
    bind $f.$i <FocusIn> {%W configure -background lightYellow }
    bind $f.$i <FocusOut> {%W configure -background white }
  }
  bind .save.extra.text <FocusIn> {%W configure -background lightYellow }
  bind .save.extra.text <FocusOut> {%W configure -background white }

  # Bindings so Ctrl-1 to Ctrl-9 select a matching name in the player,
  # site, event and round entryboxes:

  set j 0
  foreach {i j} {evententry "event" siteentry "site"
      whiteentry "white" blackentry "black"
      roundentry "round" } {
    for {set z 1} {$z <= 9} {incr z} {
      bind $f.$i [format "<Control-Key-%d>" $z] \
        [format "eval {if {\$nameMatchCount >= %d} \
                         {set %s \$nameMatches(%d)}}" $z $j $z ]
    }
  }

  frame .save.bar2 -height 2 -borderwidth 1 -relief sunken
  pack .save.bar2 -fill x -pady 10
  frame .save.buttons
  if {$gnum == 0} {
    button .save.buttons.prev -text "As last game" -command {
    }
  }
  button .save.buttons.save -textvar ::tr(Save) -underline 0 -command {
    set extraTags [.save.extra.text get 1.0 end-1c]
    gsave $gsaveNum;
    destroy .save
  }

  button .save.buttons.cancel -textvar ::tr(Cancel) -command {destroy .save}
  pack .save.buttons -side bottom -pady 10 -fill x
  if {$gnum == 0} {
    #pack .save.buttons.prev -side left -padx 10
  }
  pack .save.buttons.cancel .save.buttons.save -side right -padx 10

  bind .save <Alt-s> {
    set extraTags [.save.extra.text get 1.0 end-1c]
    gsave $gsaveNum;
    focus .
    destroy .save
    break
  }
  bind .save <Escape> { focus .; destroy .save; }
  focus .save
  if {$gnum > 0} { focus .save.buttons.save }
}

# gsave:
#    Called by gameSave when the user presses the "Save" button
#    to save the game. Attempts to save and reports the result.
#
proc gsave { gnum } {
  global date year month day white black resultVal event site round
  global whiteElo blackElo whiteRType blackRType eco extraTags
  global edate eyear emonth eday

  set date [format "%s.%s.%s" $year $month $day]
  set edate [format "%s.%s.%s" $eyear $emonth $eday]
  set extraTagsList [split $extraTags "\n"]
  sc_game tags set -event $event -site $site -date $date -round $round \
    -white $white -black $black -result $resultVal \
    -whiteElo $whiteElo -whiteRatingType $whiteRType \
    -blackElo $blackElo -blackRatingType $blackRType \
    -eco $eco -eventdate $edate -extra $extraTagsList
  set res [sc_game save $gnum]
  if {$res != ""} {
    tk_messageBox -type ok -icon info -parent .save \
      -title "Scid" -message $res
  }
  updateBoardAndPgn
  updateGList
  updateTitle
}

# gameAdd:
#   Calls gameSave with a game number of zero.
#
proc gameAdd {} { gameSave 0 }

# gameReplace:
#   Calls gameSave with the current game number, which should be nonzero.
#
proc gameReplace {} { gameSave [sc_game number] }


# helpAbout:
#    Displays information about Scid.
#
proc helpAbout {} {
  set str {}
  append str "Scid: Shane's chess information database\n\n"
  append str "Version [sc_info version], [sc_info version date]\n"
  append str "Using Tcl/Tk version: [info patchlevel]\n\n"
  append str "Author: Shane Hudson\n"
  append str "Email: shane@cosc.canterbury.ac.nz\n"
  append str "Website: scid.sourceforge.net\n\n"
  append str "Copyright (C) Shane Hudson 1999-2001.\n"
  append str "Scid is freeware, but you are welcome to make "
  append str "a small donation for it -- just email the author for details."
  set asserts [sc_info asserts]
  if {$asserts > 0} {
    append str "\n\n[thousands $asserts] asserts tested."
  }
  tk_messageBox -title "About Scid" -message $str -type ok
}


############################################################
# Keyboard move entry:
#   Handles letters, digits and BackSpace/Delete keys.
#   Note that king- and queen-side castling moves are denoted
#   "OK" and "OQ" respectively.
#   The letters n, r, q, k, o and l are promoted to uppercase
#   automatically. A "b" can match to a b-pawn or Bishop move,
#   so in some rare cases, a capital B may be needed for the
#   Bishop move to distinguish it from the pawn move.

set moveEntry(Text) ""
set moveEntry(List) {}

# Bind Alt+letter key to nothing, to stop Alt+letter from
# matching the move entry bindings, so Alt+letter ONLY invokes
# the menus:
foreach key {a b c d e f g h i j k l m n o p q r s t u v w x y z} {
  bind . <Alt-$key> { 
    # nothing
  }
}

proc moveEntry_Clear {} {
  global moveEntry
  set moveEntry(Text) ""
  set moveEntry(List) {}
}

proc moveEntry_Complete {} {
  global moveEntry
  set len [llength $moveEntry(List)]
  if {$len > 0} {
    if {$moveEntry(AutoExpand)} { bell }
    set move [lindex $moveEntry(List) 0]
    if {$move == "OK"} { set move "O-O" }
    if {$move == "OQ"} { set move "O-O-O" }
    set action "replace"
    if {![sc_pos isAt vend]} { set action [confirmReplaceMove] }
    if {$action == "replace"} {
      sc_move addSan $move
    } elseif {$action == "var"} {
      sc_var create
      sc_move addSan $move
    }
    moveEntry_Clear
    updateBoardAndPgn
    if {$action == "replace"} { ::tree::doTraining }
  }
}

proc moveEntry_Backspace {} {
  global moveEntry
  set moveEntry(Text) [string range $moveEntry(Text) 0 \
                         [expr [string length $moveEntry(Text)] - 2]]
  set moveEntry(List) [sc_pos matchMoves $moveEntry(Text) $moveEntry(Coord)]
  updateStatusBar
}

proc moveEntry_Char {ch} {
  global moveEntry
  set oldMoveText $moveEntry(Text)
  set oldMoveList $moveEntry(List)
  append moveEntry(Text) $ch
  set moveEntry(List) [sc_pos matchMoves $moveEntry(Text) $moveEntry(Coord)]
  set len [llength $moveEntry(List)]
  if {$len == 0} {
    # No matching moves, so do not accept this character as input:
    set moveEntry(Text) $oldMoveText
    set moveEntry(List) $oldMoveList
  } elseif {$len == 1} {
    # Exactly one matching move, so make it if AutoExpand is on,
    # or if it equals the move entered. Note the comparison is
    # case insensitive to allow for 'b' to match both pawn and
    # Bishop moves.
    set move [string tolower [lindex $moveEntry(List) 0]]

    if {$moveEntry(AutoExpand) > 0  ||
        ![string compare [string tolower $moveEntry(Text)] $move]} {
      moveEntry_Complete
    }
  } elseif {$len == 2} {
    # Check for the special case where the user has entered a b-pawn
    # capture that clashes with a Bishop move (e.g. bxc4 and Bxc4):
    set first [string tolower [lindex $moveEntry(List) 0]]
    set second [string tolower [lindex $moveEntry(List) 1]]
    if {[string equal $first $second]} {
        set moveEntry(List) [list $moveEntry(Text)]
        moveEntry_Complete
    }
  }
  updateStatusBar
}


# preMoveCommand: called before making a move to store text in the comment
#   editor window and EPD windows.
proc preMoveCommand {} {
  resetAnalysis
  storeComment
  storeEpdTexts
}

sc_info preMoveCmd preMoveCommand


############################################################
#### Square Bindings:

for {set i 0} { $i < 64 } { incr i } {
  ::board::bind .board $i <Enter> "enterSquare $i"
  ::board::bind .board $i <Leave> "leaveSquare $i"
  ::board::bind .board $i <ButtonPress-1> "pressSquare $i"
  ::board::bind .board $i <B1-Motion> "::board::dragPiece .board %X %Y"
  ::board::bind .board $i <ButtonRelease-1> "releaseSquare .board %X %Y"
  ::board::bind .board $i <ButtonPress-2> "pressSquare $i"
  ::board::bind .board $i <ButtonPress-3> backSquare
}

foreach i {o q r n k O Q R B N K} {
  bind . <$i> "moveEntry_Char [string toupper $i]"
}
foreach i {a b c d e f g h 1 2 3 4 5 6 7 8} {
  bind . <Key-$i> "moveEntry_Char $i"
}

bind . <Control-BackSpace> backSquare
bind . <Control-Delete> backSquare
bind . <BackSpace> moveEntry_Backspace
bind . <Delete> moveEntry_Backspace
bind . <space> moveEntry_Complete


###  Other Key bindings:

# Bindings for quick move annotation entry in the main window:

bind . <exclam><Return> "sc_pos addNag !; updateBoardAndPgn .board"
bind . <exclam><exclam><Return> "sc_pos addNag !!; updateBoardAndPgn .board"
bind . <exclam><question><Return> "sc_pos addNag !?; updateBoardAndPgn .board"
bind . <question><Return> "sc_pos addNag ?; updateBoardAndPgn .board"
bind . <question><question><Return> "sc_pos addNag ??; updateBoardAndPgn .board"
bind . <question><exclam><Return> "sc_pos addNag ?!; updateBoardAndPgn .board"

bind . <plus><minus> "sc_pos addNag +-; updateBoardAndPgn .board"
bind . <plus><slash> "sc_pos addNag +/-; updateBoardAndPgn .board"
bind . <plus><equal> "sc_pos addNag +=; updateBoardAndPgn .board"
bind . <equal><Return> "sc_pos addNag =; updateBoardAndPgn .board"
bind . <minus><plus> "sc_pos addNag -+; updateBoardAndPgn .board"
bind . <minus><slash> "sc_pos addNag -/+; updateBoardAndPgn .board"
bind . <equal><plus> "sc_pos addNag =+; updateBoardAndPgn .board"
# bind . <asciitilde><Return> "sc_pos addNag ~; updateBoardAndPgn .board"
# Null move entry:
bind . <minus><minus> "addMove null null"

# Arrow keys, Home and End:
bind . <Home> {if {!$tree(refresh)} {sc_move start; updateBoard .board}}
bind . <Up> {if {!$tree(refresh)} {sc_move back 10; updateBoard .board}}
bind . <Left> {if {!$tree(refresh)} {sc_move back; updateBoard .board}}
bind . <Down> {if {!$tree(refresh)} {sc_move forward 10; updateBoard .board}}
bind . <Right> {if {!$tree(refresh)} {sc_move forward; updateBoard .board}}
bind . <End> {if {!$tree(refresh)} {sc_move end; updateBoard .board}}

bind . <period> {if {!$tree(refresh)} {toggleRotateBoard}}

# MouseWheel in main window:
bind . <MouseWheel> {
  if {! $tree(refresh)} {
    if {[expr -%D] < 0} { sc_move back; updateBoard .board }
    if {[expr -%D] > 0} { sc_move forward; updateBoard .board }
  }
}
if {! $windowsOS} {
  bind . <Button-4> {
    if {! $tree(refresh)} { sc_move back; updateBoard .board }
  }
  bind . <Button-5> {
    if {! $tree(refresh)} { sc_move forward; updateBoard .board }
  }
}


############################################################
### Packing the main window:

pack .button -side top -ipadx 0 -pady 3

label .statusbar -textvariable statusBar -relief sunken -anchor w -width 1 \
  -font font_Small
pack .statusbar -side bottom -fill x
bind .statusbar <1> gotoNextBase

proc gotoNextBase {} {
  set n [sc_base current]
  set cb [sc_info clipbase]
  while {1} {
    incr n; if {$n > $cb} { set n 1 }
    sc_base switch $n
    if {[sc_base inUse]} { break }
  }
  updateBoardAndPgn .board
  updateTitle
  updateMenuStates
  updateStatusBar
  updateGList
}

pack .board -side top -padx 5 -pady 5

pack .ginfoXbar -side bottom -fill x
pack .ginfoYbar -side right -fill y
pack .gameInfo -side bottom -fill both -expand yes

#setToolbar $showToolbar
redrawToolbar

wm resizable . 0 1
wm minsize . 0 0
wm iconname . "Scid"


#################
# Open files and databases:

# Check for arguments starting with "-" (or "/" on Windows):

set loadAtStart(spell) 1
set loadAtStart(eco) 1
set loadAtStart(tb) 1

proc getCommandLineOptions {} {
  global argc argv windowsOS loadAtStart
  while {$argc > 0} {
    set arg [lindex $argv 0]
    set firstChar [string index $arg 0]
    if {$firstChar == "-"  ||  ($windowsOS  &&  $firstChar == "/")} {
      # Seen option argument:
      incr argc -1
      set argv [lrange $argv 1 end]

      # Special argument "--" means no more options:
      if {$arg == "--"} { return }

      # Check for known option names:
      #   -f (/f), -fast (/fast): Fast start with no tablebases, etc.
      #   -xeco, -xe: Do not load ECO file.
      #   -xspell, -xs: Do not load spellcheck file.
      #   -xtb, -xt: Do not check tablebase directory.

      set argName [string range $arg 1 end]
      switch $argName {
        "f"    -
        "fast" {
          addSplash "Fast start: no tablebases, ECO or spelling file loaded."
          set loadAtStart(spell) 0
          set loadAtStart(eco) 0
          set loadAtStart(tb) 0
        }
        "xt" -
        "xtb" {
          set loadAtStart(tb) 0
        }
        "xe" -
        "xeco" {
          set loadAtStart(eco) 0
        }
        "xs" -
        "xspell" {
          set loadAtStart(spell) 0
        }
        "s1"  { set ::boardSize 21 }
        "s2"  { set ::boardSize 25 }
        "s3"  { set ::boardSize 29 }
        "s4"  { set ::boardSize 33 }
        "s5"  { set ::boardSize 37 }
        "s6"  { set ::boardSize 40 }
        "s7"  { set ::boardSize 45 }
        "s8"  { set ::boardSize 49 }
        "s9"  { set ::boardSize 54 }
        "s10" { set ::boardSize 58 }
        "s11" { set ::boardSize 64 }
        "s12" { set ::boardSize 72 }
        default {
          addSplash "Warning: unknown option: \"$arg\""
        }
      }
    } else {
      # Seen first non-option argument:
      return
    }
  }
}

getCommandLineOptions


setLanguage $language

updateTitle
updateBoard .board
updateStatusBar
update idle

# Try to find tablebases:
if {$loadAtStart(tb)} {
  if {[sc_info tb]} {
    addSplash "Checking for endgame tablebase files..."
    set tbDirs {}
    foreach i {1 2 3 4} {
      if {$initialDir(tablebase$i) != ""} {
        if {$tbDirs != ""} { append tbDirs ";" }
        append tbDirs [file nativename $initialDir(tablebase$i)]
      }
    }
    set result 0
    if {$tbDirs != ""} {
      set result [sc_info tb $tbDirs]
    }
    if {$result == 0} {
      addSplash "    No tablebases were found."
    } else {
      addSplash "    Tablebases with up to $result pieces were found."
    }
  }
}

# Try to open the ECO classification file:
set result 0
set ecoFile_fullname [file nativename $ecoFile]

if {$loadAtStart(eco)} {
  addSplash "Trying to load the ECO openings file..."
  if {[catch { sc_eco read $ecoFile_fullname } result]} {
    # Could not load, so try "scid.eco" in the current directory:
    if [catch {sc_eco read "scid.eco"} result] {
      # Neither attempt worked, so do not use ECO classification
      addSplash "    Unable to open the ECO file: $ecoFile"
    } else {
      addSplash "    ECO file \"./scid.eco\" loaded: $result positions."
    }
  } else {
    addSplash "    ECO file \"[file tail $ecoFile_fullname]\"  loaded: $result positions."
  }
}

###
# Try to load the spellcheck file:
if {$loadAtStart(spell)} {
  if {[catch {sc_name read $spellCheckFile} result]} {
    #addSplash "Unable to load the default spellcheck file: $spellCheckFile"
  } else {
    addSplash "Spellcheck file \"[file tail $spellCheckFile]\" loaded:"
    addSplash "    [lindex $result 0] players, [lindex $result 1] events, [lindex $result 2] sites, [lindex $result 3] rounds."
  }
}

# fullname:
#   Given a file name, returns its absolute name.
#
proc fullname {fname} {
  if {[file pathtype $fname] == "absolute"} { return $fname }
  set old [pwd]
  if {[catch {cd [file dirname $fname]}]} { return $fname }
  set fname [file join [pwd] [file tail $fname]]
  catch {cd $old}
  return $fname
}

# Loading a database if specified on the command line:
# Need to check file type: .epd, .pgn, .pgn.gz, etc

while {$argc > 0} {
  set startbase [fullname [lindex $argv 0]]
  if {! [catch {sc_game startBoard $startbase}]} {
    set argc 0
    break
  }
  if {! [catch {sc_game startBoard [join $argv " "]}]} {
    set argc 0
    break
  }
  if {[string match "*.epd*" $startbase]} {
    addSplash "Opening EPD file: $startbase..."
    if {![newEpdWin openSilent $startbase]} {
      addSplash "   Error opening EPD file: $startbase"
    }
    set initialDir(epd) [file dirname $startbase]
  } elseif {[string match "*.sor" $startbase]} {
    addSplash "Opening repertoire file: $startbase..."
    if {[catch {::rep::openWithFile $startbase} err]} {
      addSplash "Error opening $startbase: $err"
    }
  } else {
    busyCursor .
    addSplash "Opening database: $startbase ..."
    set err 0
    set errMessage ""
    if {[string match "*.pgn" $startbase] || \
        [string match "*.PGN" $startbase] || \
        [string match "*.pgn.gz" $startbase]} {
      set err [catch {sc_base create $startbase true} errMessage]
      if {$err == 0} {
        doPgnFileImport $startbase "\nOpening [file tail $startbase] read-only...\n"
        sc_base type [sc_base current] 3
        ::recentFiles::add $startbase
      }
    } else {
      set err [catch {openBase [file rootname $startbase]} errMessage]
      if {! $err} { ::recentFiles::add "[file rootname $startbase].si3" }
    }
    if {$err} {
      addSplash "   Error: could not open database \"$startbase\":\n  $errMessage"
    } else {
      addSplash "   Database \"$startbase\" opened: [sc_base numGames] games."
      set initialDir(base) [file dirname $startbase]
      catch {sc_game load auto}
    }
  }
  unbusyCursor .
  incr argc -1
  set argv [lrange $argv 1 end]
}

addSplash "\nStartup completed."
addSplash "Scid has over 35 online help pages; just press F1 for help!"
bind . <Configure> "recordWinSize ."
setWinLocation .
wm deiconify .
wm protocol . WM_DELETE_WINDOW { fileExit }

if {$startup(switcher)} { makeBaseWin }
if {$startup(pgn)} { makePgnWin }
if {$startup(gamelist)} { makeGList }
if {$startup(tree)} { ::tree::make }
if {$startup(stats)} { makeStatsWin }
if {$startup(crosstable)} { crosstabWin }
if {$startup(finder)} { fileFinder }


updateBoard .board
updateStatusBar
updateTitle
updateLocale
update

# Bindings to map/unmap all windows when main window is mapped:
bind .statusbar <Map> {showHideAllWindows deiconify}
bind .statusbar <Unmap> {showHideAllWindows iconify}

# showHideAllWindows:
#   Arranges for all major Scid windows to be shown/hidden
#   Should be called type = "iconify" or "deiconify"
#
proc showHideAllWindows {type} {
  # Don't do this if user option is off:
  if {! $::autoIconify} { return }

  # Some window managers like KDE generate Unmap events for other
  # situations like switching to another desktop, etc.
  # So if the main window is still mapped, do not iconify others:
  if {($type == "iconify")  && ([winfo ismapped .] == 1)} { return }

  # Now iconify/deiconify all the major Scid windows that exist:
  foreach w {.baseWin .glistWin .pgnWin .tourney .maintWin \
               .ecograph .crosstabWin .treeWin .analysisWin1 .anslysisWin2 \
               .playerInfoWin .commentWin .repWin .statsWin .tbWin \
               .sb .sh .sm .noveltyWin .emailWin .oprepWin \
               .rgraph .sgraph .importWin .helpWin .tipsWin} {
    if {[winfo exists $w]} { catch {wm $type $w} }
  }
}

if {$startup(tip)} { ::tip::show }

after 1500 {
  if {$autoCloseSplash} {wm withdraw .splash}
}

### End of file: end.tcl
