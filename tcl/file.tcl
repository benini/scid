# adds a checkbox to show hidden files
catch {tk_getOpenFile -with-invalid-argument}
namespace eval ::tk::dialog::file {
  variable showHiddenBtn 1
  variable showHiddenVar 0
}

# ::file::Exit
#
#    Prompt for confirmation then exit.
#
proc ::file::Exit {}  {
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
  
  # Check if a mask is opened and dirty
  ::tree::mask::close
  
  if {$msg != ""} {
    append msg "\n"
  }
  append msg $::tr(ExitDialog)
  
  # Only ask before exiting if there are unsaved changes:
  if {$unsavedCount > 0} {
    set answer [tk_messageBox -title "Scid: [tr FileExit]" \
        -message $msg -type yesno -icon question]
    if {$answer != "yes"} { return }
  }
  if {$::optionsAutoSave} {
    # restore askToReplaceMoves if necessary
    if {[winfo exists .tacticsWin]} {
      ::tactics::restoreAskToReplaceMoves
    }
    # restore options if findBestMove in progress
    ::tactics::findBestMoveExit
    .menu.options invoke [tr OptionsSave]
  }
  ::recentFiles::save
  ::utils::history::Save
  destroy .
}

proc ::file::ExitFast {} {
  if {$::optionsAutoSave} {
    # restore askToReplaceMoves if necessary
    if {[winfo exists .tacticsWin]} {
      ::tactics::restoreAskToReplaceMoves
    }
    .menu.options invoke [tr OptionsSave]
  }
  ::recentFiles::save
  destroy .
}

# ::file::New
#
#   Opens file-save dialog and creates a new database.
#
proc ::file::New {} {
  if {[sc_base count free] == 0} {
    tk_messageBox -title "Scid" -type ok -icon info \
        -message "Too many databases open; close one first"
    return
  }
  set ftype {
    { "Scid databases, EPD files" {".si4" ".epd"} }
    { "Scid databases" {".si4"} }
    { "EPD files" {".epd"} }
  }
  
  if { [ file exists $::initialDir(base) ] } {
    set fName [tk_getSaveFile -initialdir $::initialDir(base) -filetypes $ftype -title "Create a Scid database"]
  } else  {
    set fName [tk_getSaveFile -filetypes $ftype -title "Create a Scid database"]
  }
  
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
  set ::initialDir(base) [file dirname $fName]
  ::recentFiles::add "$fName.si4"
  ::notify::DatabaseChanged
  updateBoard -pgn
}

# ::file::Open
#
#    Opens file-open dialog and opens the selected Scid database.
#
proc ::file::Open {{fName ""}} {
  if {[sc_base count free] == 0} {
    tk_messageBox -type ok -icon info -title "Scid" \
        -message "Too many databases are open; close one first"
    return
  }
  
  if {[sc_info gzip]} {
    set ftype {
      { "All Scid files" {".si4" ".si3" ".pgn" ".pgn.gz" ".epd" ".epd.gz" ".sor"} }
      { "Scid databases, PGN files" {".si4" ".si3" ".pgn" ".PGN" ".pgn.gz"} }
      { "Scid databases" {".si4" ".si3"} }
      { "PGN files" {".pgn" ".PGN" ".pgn.gz"} }
      { "EPD files" {".epd" ".EPD" ".epd.gz"} }
      { "Repertoire files" {".sor"} }
    }
  } else {
    set ftype {
      { "All Scid files" {".si4" ".si3" ".pgn" ".epd" ".sor"} }
      { "Scid databases, PGN files" {".si4" ".si3" ".pgn" ".PGN"} }
      { "Scid databases" {".si4" ".si3"} }
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
    set fName "$fName.si4"
  }
  
  if {[file extension $fName] == ".sor"} {
    if {[catch {::rep::OpenWithFile $fName} err]} {
      tk_messageBox -parent . -type ok -icon info -title "Scid" \
          -message "Unable to open \"$fName\": $err"
    }
    return
  }
  
  if {[file extension $fName] == ".si3"} {
    ::file::Upgrade [file rootname $fName]
    return
  }
  
  set err 0
  busyCursor .
  if {[file extension $fName] == ".si4"} {
    set fName [file rootname $fName]
    if {[catch {openBase $fName} result]} {
      set err 1
      tk_messageBox -icon warning -type ok -parent . \
          -title "Scid: Error opening file" -message $result
    } else {
      set ::initialDir(base) [file dirname $fName]
      ::recentFiles::add "$fName.si4"
    }
  } elseif {[string match "*.epd*" [string tolower $fName]]} {
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
  
  if {$err == 0} {
    catch {sc_game load auto}
    flipBoardForPlayerNames $::myPlayerNames
  }
  unbusyCursor .
  updateBoard -pgn
  updateGameInfoMenu
  ::notify::DatabaseChanged
}

# ::file::Upgrade
#
#   Upgrades an old (version 3) Scid database to version 4.
#
proc ::file::Upgrade {name} {
  if {[file readable "$name.si4"]} {
    set msg [string trim $::tr(ConfirmOpenNew)]
    set res [tk_messageBox -title "Scid" -type yesno -icon info -message $msg]
    if {$res == "no"} { return }
    ::file::Open "$name.si4"
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
  } else  {
    # rename game and name files, delete old .si3
    file rename "$name.sg3"  "$name.sg4"
    file rename "$name.sn3"  "$name.sn4"
    file delete "$name.si3"
  }
  ::file::Open "$name.si4"
}

# openBase:
#    Opens a Scid database, showing a progress bar in a separate window
#    if the database is around 1 Mb or larger in size.
#   ::file::Open should be used if the base is not already in si4 format
proc openBase {name} {
  set bsize 0
  set gfile "[file rootname $name].sg4"
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


# ::file::Close:
#   Closes the active base.
#
proc ::file::Close {{base -1}} {
  # Remember the current base:
  set current [sc_base current]
  if {$base < 0} { set base $current }
  if {![sc_base inUse $base]} { return }
  # Switch to the base which will be closed, and check for changes:
  sc_base switch $base
  if {![::game::ConfirmDiscard]} {
    sc_base switch $current
    return
  }
  sc_base close
  ::game::HistoryRemoveDB $base
    
  # If base to close was the current one, reset to clipbase
  if { $current == $base } {
    setTrialMode 0
    set current 9
  }

  # Close Tree window whenever a base is closed/switched:
  if {[winfo exists .treeWin$base]} { destroy .treeWin$base }
  # Now switch back to the original base
  ::file::SwitchToBase $current
  updateBoard -pgn
  ::notify::DatabaseChanged
}


proc ::file::SwitchToBase {{b} {saveHistory 1}} {
  if {[sc_base current] == $b} { return }
  sc_base switch $b
  if {$saveHistory == 1} { ::game::HistoryDatabaseSwitch }
  # Close email window when a base is switched:
  if {[winfo exists .emailWin]} { destroy .emailWin }
  updateBoard -pgn
  ::notify::DatabaseChanged
}

################################################################################
proc ::file::openBaseAsTree { { fName "" } } {
  set current [sc_base current]
  
  if {[sc_base count free] == 0} {
    tk_messageBox -type ok -icon info -title "Scid" \
        -message "Too many databases are open; close one first"
    return
  }
  
  if {$fName == ""} {
    if {[sc_info gzip]} {
      set ftype {
        { "Scid databases, PGN files" {".si4" ".si3" ".pgn" ".PGN" ".pgn.gz"} }
        { "Scid databases" {".si4" ".si3"} }
        { "PGN files" {".pgn" ".PGN" ".pgn.gz"} }
      }
    } else {
      set ftype {
        { "Scid databases, PGN files" {".si4" ".si3" ".pgn" ".PGN"} }
        { "Scid databases" {".si4" ".si3"} }
        { "PGN files" {".pgn" ".PGN"} }
      }
    }
    set fName [tk_getOpenFile -initialdir $::initialDir(base) -filetypes $ftype -title "Open a Scid file"]
    if {$fName == ""} { return }
  }
  
  if {[file extension $fName] == ""} {
    set fName "$fName.si3"
  }
  
  if {[file extension $fName] == ".sor"} {
    if {[catch {::rep::OpenWithFile $fName} err]} {
      tk_messageBox -parent . -type ok -icon info -title "Scid" \
          -message "Unable to open \"$fName\": $err"
    }
    return
  }
  
  if {[file extension $fName] == ".si3"} {
    ::file::Upgrade [file rootname $fName]
    return
  }
  
  set err 0
  busyCursor .
  if {[file extension $fName] == ".si4"} {
    set fName [file rootname $fName]
    if {[catch {openBase $fName} result]} {
      unbusyCursor .
      set err 1
      tk_messageBox -icon warning -type ok -parent . -title "Scid: Error opening file" -message $result
      return
    } else {
      set ::initialDir(base) [file dirname $fName]
      ::recentFiles::add "$fName.si4"
    }
  } else {
    # PGN file:
    set result "This file is not readable."
    if {(![file readable $fName])  || \
          [catch {sc_base create $fName true} result]} {
      unbusyCursor .
      set err 1
      tk_messageBox -icon warning -type ok -parent . -title "Scid: Error opening file" -message $result
      return
    } else {
      doPgnFileImport $fName "Opening [file tail $fName] read-only...\n"
      sc_base type [sc_base current] 3
      ::recentFiles::add $fName
    }
  }
  
  unbusyCursor .
  set new_base [sc_base current]
  sc_base switch $current
  ::tree::make $new_base 1
}

