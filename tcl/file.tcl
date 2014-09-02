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
  for {set i [sc_base count total] } {$i > 0} {incr i -1} {
    sc_base switch $i
    if {[sc_base inUse] && [sc_game altered] && ![sc_base isReadOnly $i]} {
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
      ERROR::MessageBox "$fName\n"
    }
  }
  set ::initialDir(base) [file dirname $fName]
  ::recentFiles::add "$fName.si4"
  ::notify::GameChanged
  ::notify::DatabaseChanged
}

# ::file::Open
#
#    Opens file-open dialog and opens the selected Scid database.
#
proc ::file::Open {{fName ""}} {
  set err [::file::Open_ "$fName"]
  if {$err == 0} {
    ::game::Load [sc_base autoload [sc_base current] ] 0
    ::windows::gamelist::Open $::file::lastOpened
    ::notify::GameChanged
    ::notify::DatabaseChanged
  }
  return $err
}

proc ::file::openBaseAsTree { { fName "" } } {
  set current [sc_base current]
  set err [::file::Open_ "$fName"]
  if {$err == 0} { ::tree::make $::file::lastOpened 1 }
  sc_base switch $current
  ::notify::DatabaseChanged
  return $err
}

proc ::file::Open_ {{fName ""} } {
  if {[sc_base count free] == 0} {
    tk_messageBox -type ok -icon info -title "Scid" \
        -message "Too many databases are open; close one first"
    return 1
  }

  if {$fName == ""} {
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
  
    set fName [tk_getOpenFile -initialdir $::initialDir(base) -filetypes $ftype -title "Open a Scid file"]
    if {$fName == ""} { return 2}
  }

  if {[file extension $fName] == ".si4"} { set fName [file rootname $fName] }
  for {set i [sc_base count total] } {$i > 0} {incr i -1} {
    if {$fName == [sc_base filename $i]} {
      tk_messageBox -title "Scid: opening file" -message "The database you selected is already opened."
      return 1
    }
  }

  set err 0
  busyCursor .
  if {[file extension $fName] == "" || [file extension $fName] == ".si4"} {
    set fName [file rootname $fName]
    if {[catch {openBase $fName} result]} {
      if { $::errorCode != $::ERROR::NameDataLoss } { set err 1 }
      ERROR::MessageBox "$fName\n"
    } else {
      set ::initialDir(base) [file dirname $fName]
      ::recentFiles::add "$fName.si4"
    }
  } elseif {[file extension $fName] == ".si3"} {
    ::file::Upgrade [file rootname $fName]
  } elseif {[file extension $fName] == ".sor"} {
    if {[catch {::rep::OpenWithFile $fName} err]} {
      tk_messageBox -parent . -type ok -icon info -title "Scid" \
          -message "Unable to open \"$fName\": $err"
      set err 1
    }
  } elseif {[string match "*.epd*" [string tolower $fName]]} {
    # EPD file:
    newEpdWin open $fName
  } else {
    # PGN file:
    if {(![file readable $fName])  || \
          [catch {sc_base create $fName true} result]} {
      ERROR::MessageBox "$fName\n"
      set err 1
    } else {
      importPgnFile [sc_base current] [list "$fName"]
      sc_base type [sc_base current] 3
      set ::initialDir(base) [file dirname $fName]
      ::recentFiles::add $fName
    }
  }
  
  unbusyCursor .
  if {$err == 0} { set ::file::lastOpened $result }
  return $err
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
  if {$err} { return -code error -errorcode $::errorCode $result }
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
}

proc ::file::SwitchToBase {{b} {saveHistory 1}} {
  if {![sc_base inUse $b]} { return }
  if {[sc_base current] == $b} { return }
  sc_base switch $b
  if {$saveHistory == 1} { ::game::HistoryDatabaseSwitch }
  # Close email window when a base is switched:
  if {[winfo exists .emailWin]} { destroy .emailWin }
  ::notify::GameChanged
  ::notify::DatabaseChanged
}

# Databases that will be automatically loaded ad startup
proc ::file::autoLoadBases.load {} {
  if {![info exists ::autoLoadBases]} { return }
  foreach base $::autoLoadBases {
    if {[::file::Open $base] != 0} {
      set idx [lsearch -exact $::autoLoadBases $base]
      if {$idx != -1} { set ::autoLoadBases [lreplace $::autoLoadBases $idx $idx] }
    }
  }
}

proc ::file::autoLoadBases.save { {channelId} } {
  if {![info exists ::autoLoadBases]} { return }
  puts $channelId "set ::autoLoadBases [list $::autoLoadBases]"
}
proc ::file::autoLoadBases.find { {baseIdx} } {
  if {![info exists ::autoLoadBases]} { return -1 }
  if {[ catch {set base [sc_base filename $baseIdx]} ]} { return -1}
  return [lsearch -exact $::autoLoadBases $base]
}
proc ::file::autoLoadBases.add { {baseIdx} } {
  if {[ catch {set base [sc_base filename $baseIdx]} ]} { return }
  lappend ::autoLoadBases $base
}
proc ::file::autoLoadBases.remove { {baseIdx} } {
  if {![info exists ::autoLoadBases]} { return }
  if {[ catch {set base [sc_base filename $baseIdx]} ]} { return }
  set idx [lsearch -exact $::autoLoadBases $base]
  if {$idx != -1} {
    set ::autoLoadBases [lreplace $::autoLoadBases $idx $idx]
  }
}
