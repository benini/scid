
# ::game::ConfirmDiscard
#
#   Prompts the user if they want to discard the changes to the
#   current game. Returns 1 if they selected yes, 0 otherwise.
#
proc ::game::ConfirmDiscard {} {
  if {$::trialMode} { return 1 }
  if {[sc_base isReadOnly]} { return 1 }
  if {! [sc_game altered]} { return 1 }
  set answer [ tk_dialog .cgDialog "Scid: [tr GameNew]" \
      $::tr(ClearGameDialog) "" 0 $::tr(Yes) $::tr(No) ]
  if {$answer == 1} { return  0 }
  return 1
}

# ::game::ConfirmDiscard2
# Clearer buttons than ConfirmDiscard
#   Prompts the user if they want to discard the changes to the
#   current game. Returns :
# 0 -> saves then continue
# 1 -> discard changes and continue
# 2 -> cancel action
#
proc ::game::ConfirmDiscard2 {} {
  if {$::trialMode} { return 1 }
  if {[sc_base isReadOnly]} { return 1 }
  if {! [sc_game altered]} { return 1 }
  # set answer [ tk_dialog .cgDialog "Scid: [tr GameNew]" $::tr(ClearGameDialog) "" 2 \
  # $::tr(SaveAndContinue) $::tr(DiscardChangesAndContinue) $::tr(GoBack) ]
  
  set w .confirmDiscard
  toplevel $w
  wm title $w "Scid: [tr GameNew]"
  set ::game::answer 2
  frame $w.top
  frame $w.bottom
  label $w.top.txt -text $::tr(ClearGameDialog)
  pack $w.top.txt -expand 1 -fill both
  
  button $w.bottom.b1 -text $::tr(SaveAndContinue) -command {destroy .confirmDiscard ; set ::game::answer 0}
  button $w.bottom.b2 -text $::tr(DiscardChangesAndContinue) -command {destroy .confirmDiscard ; set ::game::answer 1}
  button $w.bottom.b3 -text $::tr(GoBack) -command {destroy .confirmDiscard ; set ::game::answer 2}
  pack $w.bottom.b1 $w.bottom.b2 $w.bottom.b3 -side left -expand 1 -fill both
  
  pack $w.top $w.bottom -expand 1 -fill both
  
  bind $w <Destroy> {set ::game::answer 2}
  
  # ceinture et bretelle pour le grab !
  update
  catch { grab $w }
  
  focus $w.bottom.b3
  vwait ::game::answer
  return $::game::answer
}

# ::game::Clear
#
#   Clears the active game, checking first if it is altered.
#   Updates any affected windows.
#
proc ::game::Clear {} {
  set confirm [::game::ConfirmDiscard2]
  if {$confirm == 2} { return }
  if {$confirm == 0} {
    sc_game save [sc_game number]
    # ::gameReplace
  }
  
  setTrialMode 0
  sc_game new
  updateBoard -pgn
  updateTitle
  updateMenuStates
}

# ::game::Strip
#
#   Strips all comments or variations from a game
#
proc ::game::Strip {type} {
  undoFeature save
  if {[catch {sc_game strip $type} result]} {
    tk_messageBox -parent . -type ok -icon info -title "Scid" -message $result
    return
  }
  updateBoard -pgn
  updateTitle
}

# ::game::TruncateBegin
#
proc ::game::TruncateBegin {} {
  undoFeature save
  if {[catch {sc_game truncate -start} result]} {
    tk_messageBox -parent . -type ok -icon info -title "Scid" -message $result
    return
  }
  updateBoard -pgn
  updateTitle
}

# ::game::Truncate
#
proc ::game::Truncate {} {
  undoFeature save
  if {[catch {sc_game truncate} result]} {
    tk_messageBox -parent . -type ok -icon info -title "Scid" -message $result
    return
  }
  updateBoard -pgn
  updateTitle
}

# game::LoadNextPrev
#
#   Loads the next or previous filtered game in the database.
#   The parameter <action> should be "previous" or "next".
#
proc ::game::LoadNextPrev {action} {
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
  ::game::Load $number
}

# ::game::Reload
#
#   Reloads the current game.
#
proc ::game::Reload {} {
  if {![sc_base inUse]} { return }
  if {[sc_game number] < 1} { return }
  ::game::Load [sc_game number]
}

# ::game::LoadRandom
#
#   Loads a random game from the database.
#
proc ::game::LoadRandom {} {
  set ngames [sc_filter size]
  if {$ngames == 0} { return }
  set r [expr {(int (rand() * $ngames)) + 1} ]
  set gnumber [sc_filter index $r]
  ::game::Load $gnumber
}


# ::game::LoadNumber
#
#    Prompts for the number of the game to load.
#
set ::game::entryLoadNumber ""
trace variable ::game::entryLoadNumber w {::utils::validate::Regexp {^[0-9]*$}}

proc ::game::LoadNumber {} {
  set ::game::entryLoadNumber ""
  if {![sc_base inUse]} { return }
  
  set confirm [::game::ConfirmDiscard2]
  if {$confirm == 2} { return }
  if {$confirm == 0} {
    # ::gameReplace
    sc_game save [sc_game number]
  }
  
  if {[sc_base numGames] < 1} { return }
  set w [toplevel .glnumDialog]
  wm title $w "Scid: [tr GameNumber]"
  grab $w
  
  label $w.label -text $::tr(LoadGameNumber)
  pack $w.label -side top -pady 5 -padx 5
  
  entry $w.entry -background white -width 10 -textvariable ::game::entryLoadNumber
  bind $w.entry <Escape> { .glnumDialog.buttons.cancel invoke }
  bind $w.entry <Return> { .glnumDialog.buttons.load invoke }
  pack $w.entry -side top -pady 5
  
  set b [frame $w.buttons]
  pack $b -side top -fill x
  dialogbutton $b.load -text "OK" -command {
    grab release .glnumDialog
    if {[catch {sc_game load $::game::entryLoadNumber} result]} {
      tk_messageBox -type ok -icon info -title "Scid" -message $result
    }
    focus .
    destroy .glnumDialog
    flipBoardForPlayerNames $::myPlayerNames
    updateBoard -pgn
    ::windows::gamelist::Refresh
    updateTitle
  }
  dialogbutton $b.cancel -text $::tr(Cancel) -command {
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


# History of viewed games
set hgame_i 0

proc ::game::HistoryRemoveDB {db} {
  set i 0
  while {[info exist ::hgame_game($i)]} {
    if {$::hgame_db($i) == $db} {
      set a $i; set b [expr $i +1]
      while {[info exist ::hgame_game($b)]} {
        set ::hgame_db($a) $::hgame_db($b)
        set ::hgame_game($a) $::hgame_game($b)
        set ::hgame_ply($a) $::hgame_ply($b)
        incr a; incr b
      }
      unset ::hgame_game($a)
      if {$i < $::hgame_i} { incr ::hgame_i -1 }
    } else {
      incr i
    }
  }
}

proc ::game::HistoryDatabaseSwitch {} {
  ::game::HistorySavePos_
  ::game::HistoryAdd_
}

proc ::game::Hprev_btnstate {} {
  if {$::hgame_i > 0} { return "normal" }
  return "disabled"
}

proc ::game::Hnext_btnstate {} {
  set i [expr "$::hgame_i + 1"]
  if {[info exist ::hgame_game($i)]} {return "normal"}
  return "disabled"
}

proc ::game::HistorySavePos_ {} {
  if {[info exist ::hgame_game($::hgame_i)]} {
    set cur_db [sc_base current]
    if {$cur_db != $::hgame_db($::hgame_i)} {
      sc_base switch $::hgame_db($::hgame_i)
      set ::hgame_ply($::hgame_i) [sc_pos location]
      sc_base switch $cur_db
    } else {
      set ::hgame_ply($::hgame_i) [sc_pos location]
    }
  }
}

proc ::game::HistoryAdd_ {} {
  if {[info exist ::hgame_game($::hgame_i)]} {
    if {$::hgame_db($::hgame_i) == [sc_base current] && \
        $::hgame_game($::hgame_i) == [sc_game number]} {
      return
    } else {
      incr ::hgame_i
    }
  }
  set i $::hgame_i
  while {[info exist ::hgame_game($i)]} {
    unset ::hgame_game($i)
    incr i
  }
  set ::hgame_db($::hgame_i) [sc_base current]
  set ::hgame_game($::hgame_i) [sc_game number]
  set ::hgame_ply($::hgame_i) [sc_pos location]
}

# ::game::Load
#
#   Loads a specified game from the active database.
#
proc ::game::Load { selection {ply ""} } {
  ::game::HistorySavePos_
  if {[::game::Load_ $selection $ply]} {
    ::game::HistoryAdd_
    ::notify::GameChanged
  }
}

proc ::game::LoadHistory {dir} {
  set check [expr $::hgame_i + $dir]
  if {$check < 0 || ![info exist ::hgame_game($check)]} {return}

  ::game::HistorySavePos_
  incr ::hgame_i $dir
  sc_base switch $::hgame_db($::hgame_i)
  #If the game is still in memory avoid the ::game::ConfirmDiscard2 call
  if {$::hgame_game($::hgame_i) != [sc_game number]} {
    ::game::Load_ $::hgame_game($::hgame_i) $::hgame_ply($::hgame_i)
  }
  ::notify::GameChanged
}

proc ::game::Load_ { selection {ply ""} } {
  # If an invalid game number, just return:
  if {$selection < 1} { return 0}
  if {$selection > [sc_base numGames]} { return 0}
  set confirm [::game::ConfirmDiscard2]
  if {$confirm == 2} { return 0}
  if {$confirm == 0} {
    sc_game save [sc_game number]
    # ::gameReplace
  }
  setTrialMode 0
  sc_game load $selection
  if {$ply != ""} { sc_move ply $ply }
  return 1
}

# ::game::LoadMenu
#
#   Produces a popup dialog for loading a game or other actions
#   such as merging it into the current game.
#
proc ::game::LoadMenu {w base gnum x y} {
  set m $w.gLoadMenu
  if {! [winfo exists $m]} {
    menu $m
    $m add command -label $::tr(BrowseGame)
    $m add command -label $::tr(LoadGame)
    $m add command -label $::tr(MergeGame)
  }
  $m entryconfigure 0 -command "::gbrowser::new $base $gnum"
  $m entryconfigure 1 -command "sc_base switch $base; ::game::Load $gnum"
  $m entryconfigure 2 -command "mergeGame $base $gnum"
  event generate $w <ButtonRelease-1>
  $m post $x $y
  event generate $m <ButtonPress-1>
}


# ::game::moveEntryNumber
#
#   Entry variable for GotoMoveNumber dialog.
#
set ::game::moveEntryNumber ""
trace variable ::game::moveEntryNumber w {::utils::validate::Regexp {^[0-9]*$}}

# ::game::GotoMoveNumber
#
#    Prompts for the move number to go to in the current game.
#
proc ::game::GotoMoveNumber {} {
  set ::game::moveEntryNumber ""
  set w [toplevel .mnumDialog]
  wm title $w "Scid: [tr GameGotoMove]"
  grab $w
  
  label $w.label -text $::tr(GotoMoveNumber)
  pack $w.label -side top -pady 5 -padx 5
  
  entry $w.entry -background white -width 10 -textvariable ::game::moveEntryNumber
  bind $w.entry <Escape> { .mnumDialog.buttons.cancel invoke }
  bind $w.entry <Return> { .mnumDialog.buttons.load invoke }
  pack $w.entry -side top -pady 5
  
  set b [frame $w.buttons]
  pack $b -side top -fill x
  dialogbutton $b.load -text "OK" -command {
    grab release .mnumDialog
    if {$::game::moveEntryNumber > 0} {
      catch {sc_move ply [expr {($::game::moveEntryNumber - 1) * 2}]}
    }
    focus .
    destroy .mnumDialog
    updateBoard -pgn
  }
  dialogbutton $b.cancel -text $::tr(Cancel) -command {
    focus .
    grab release .mnumDialog
    destroy .mnumDialog
    focus .
  }
  packbuttons right $b.cancel $b.load
  
  set x [ expr {[winfo width .] / 4 + [winfo rootx .] } ]
  set y [ expr {[winfo height .] / 4 + [winfo rooty .] } ]
  wm geometry $w "+$x+$y"
  
  focus $w.entry
}

################################################################################
# merge game gnum in base srcBase in current game in base destBase
# then switch to destbase
# If game number is not provided, take current glNumber
################################################################################
proc ::game::mergeInBase { srcBase destBase { gnum -1 }} {
  if {$gnum == -1} {
    set gnum $::glNumber
  }
  ::file::SwitchToBase $destBase
  mergeGame $srcBase $gnum
}


# FBF: 2012/03/08
# Grouping intercommunication between windows
# When complete this should be moved to a new notify.tcl file
namespace eval ::notify {
  proc GameChanged {} {
    flipBoardForPlayerNames $::myPlayerNames
    updateBoard -pgn
    ::windows::gamelist::Refresh
    updateTitle
  }

  proc PosChanged {} {
    if {![sc_base inUse]  ||  $::trialMode  ||  [sc_base isReadOnly]} {
        .main.tb.save configure -state disabled
    } else {
        .main.tb.save configure -state normal
    }

    if {$::showGameInfo} { updateGameInfo }
    updateAnalysis 1
    updateAnalysis 2
    updateEpdWins
    ::commenteditor::Refresh
    ::tb::results
    updateMenuStates
    moveEntry_Clear
    updateStatusBar
    if {[winfo exists .twinchecker]} { updateTwinChecker }
    ::pgn::Refresh
    if {[winfo exists .bookWin]} { ::book::refresh }
    if {[winfo exists .bookTuningWin]} { ::book::refreshTuning }
    updateNoveltyWin
    ::tree::refresh
  }

  proc DatabaseChanged {} {
    ::windows::gamelist::Refresh
    ::windows::switcher::Refresh
    ::windows::stats::Refresh
    updateTitle
    updateStatusBar
  }
}
