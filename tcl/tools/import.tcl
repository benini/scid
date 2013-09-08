###
### import.tcl: part of Scid.
### Copyright (C) 2000  Shane Hudson.
###

### Import game window

proc importPgnGame {} {
  if {[winfo exists .importWin]} { return }
  set w [toplevel .importWin]
  wm title $w "Scid: Import PGN game"
  wm minsize $w 50 5
  frame $w.b
  pack $w.b -side bottom
  set pane [::utils::pane::Create $w.pane edit err 650 300 0.8]
  pack $pane -side top -expand true -fill both
  set edit $w.pane.edit
  text $edit.text -height 12 -width 80 -wrap none -background white \
      -yscroll "$edit.ybar set" -xscroll "$edit.xbar set"  -setgrid 1
  # Override tab-binding for this widget:
  bind $edit.text <Key-Tab> "[bind all <Key-Tab>]; break"
  scrollbar $edit.ybar -command "$edit.text yview" -takefocus 0
  scrollbar $edit.xbar -orient horizontal -command "$edit.text xview" -takefocus 0
  grid $edit.text -row 0 -column 0 -sticky nesw
  grid $edit.ybar -row 0 -column 1 -sticky nesw
  grid $edit.xbar -row 1 -column 0 -sticky nesw
  grid rowconfig $edit 0 -weight 1 -minsize 0
  grid columnconfig $edit 0 -weight 1 -minsize 0
  
  # Right-mouse button cut/copy/paste menu:
  menu $edit.text.rmenu -tearoff 0
  $edit.text.rmenu add command -label "Cut" -command "tk_textCut $edit.text"
  $edit.text.rmenu add command -label "Copy" -command "tk_textCopy $edit.text"
  $edit.text.rmenu add command -label "Paste" -command "tk_textPaste $edit.text"
  $edit.text.rmenu add command -label "Select all" -command "$edit.text tag add sel 1.0 end"
  bind $edit.text <ButtonPress-$::MB3> "tk_popup $edit.text.rmenu %X %Y"
  
  text $pane.err.text -height 4 -width 75 -wrap word -yscroll "$pane.err.scroll set"
  $pane.err.text insert end $::tr(ImportHelp1)
  $pane.err.text insert end "\n"
  $pane.err.text insert end $::tr(ImportHelp2)
  $pane.err.text configure -state disabled
  scrollbar $pane.err.scroll -command "$pane.err.text yview" -takefocus 0
  pack $pane.err.scroll -side right -fill y
  pack $pane.err.text -side left -expand true -fill both
  
  button $w.b.paste -text "$::tr(PasteCurrentGame) (Alt-P)" -command {
    .importWin.pane.edit.text delete 1.0 end
    .importWin.pane.edit.text insert end [sc_game pgn -width 70]
    .importWin.pane.err.text configure -state normal
    .importWin.pane.err.text delete 1.0 end
    .importWin.pane.err.text configure -state disabled
  }
  button $w.b.clear -text "$::tr(Clear) (Alt-C)" -command {
    .importWin.pane.edit.text delete 1.0 end
    .importWin.pane.err.text configure -state normal
    .importWin.pane.err.text delete 1.0 end
    .importWin.pane.err.text configure -state disabled
  }
  button $w.b.ok -text "$::tr(Import) (Alt-I)" -command {
    set err [catch {sc_game import \
          [.importWin.pane.edit.text get 1.0 end]} result]
    .importWin.pane.err.text configure -state normal
    .importWin.pane.err.text delete 1.0 end
    .importWin.pane.err.text insert end $result
    .importWin.pane.err.text configure -state disabled
    if {! $err} {
      updateBoard -pgn
      updateTitle
      ::windows::gamelist::Refresh
    }
  }
  button $w.b.cancel -textvar ::tr(Close) -command {
    destroy .importWin; focus .
  }
  frame $w.b.space -width 20
  pack $w.b.paste $w.b.clear $w.b.space -side left -padx 2 -pady 2
  pack $w.b.cancel $w.b.ok -side right -padx 10 -pady 5
  # Paste the current selected text automatically:
  # if {[catch {$w.pane.edit.text insert end [selection get]}]} {
  # ?
  # }
  # Select all of the pasted text:
  $w.pane.edit.text tag add sel 1.0 end
  
  bind $w <F1> { helpWindow Import }
  bind $w <Alt-i> { .importWin.b.ok invoke }
  bind $w <Alt-p> { .importWin.b.paste invoke }
  bind $w <Alt-c> { .importWin.b.clear invoke }
  bind $w <Escape> { .importWin.b.cancel invoke }
  # bind $w.pane.edit.text <Any-KeyRelease> { .importWin.b.ok invoke }
  focus $w.pane.edit.text
}


proc importClipboardGame {} {
  importPgnGame
  catch {event generate .importWin.pane.edit.text <<Paste>>}
  # Paste the current selected text automatically if no data was pasted from clipboard:
  if { [ .importWin.pane.edit.text get 1.0 end ] == "\n" } {
    catch { .importWin.pane.edit.text insert end [selection get] }
  }
}

proc importPgnLine {line} {
  importPgnGame
  set w .importWin.pane.edit.text
  $w delete 1.0 end
  $w insert end $line
  $w tag add sel 1.0 end
  focus $w
}

################################################################################
#
################################################################################
proc importMoveList {line} {
  sc_move start
  sc_move addSan $line
  updateBoard -pgn
}
################################################################################
#
################################################################################
proc importMoveListTrans {line} {
  
  set doImport 0
  
  if { $::askToReplaceMoves } {
    if {[llength [sc_game firstMoves 0 1]] == 0} {
      set doImport 1
    } elseif {[tk_messageBox -message [::tr "OverwriteExistingMoves"] -type yesno -icon question ] == yes} {
      set doImport 1
    }
  } else  {
    set doImport 1
  }
  if {$doImport} {
    set line [untrans $line]
    sc_move start
    sc_move addSan $line
    updateBoard -pgn
  }
  
}

set importPgnErrors ""

### Import file of Pgn games:

proc importPgnFile {} {
  global importPgnErrors
  
  set err ""
  set curr_base [sc_base current]
  if {[sc_base isReadOnly $curr_base]} { set err "This database is read-only." }
  if {![sc_base inUse]} { set err "This is not an open database." }
  if {$err != ""} {
    tk_messageBox -type ok -icon error -title "Scid: Error" -message $err
    return
  }
  if {[sc_info gzip]} {
    set ftypes {
      { "Portable Game Notation files" {".pgn" ".PGN" ".pgn.gz"} }
      { "Text files" {".txt" ".TXT"} }
      { "All files" {"*"} }
    }
  } else {
    set ftypes {
      { "Portable Game Notation files" {".pgn" ".PGN"} }
      { "Text files" {".txt" ".TXT"} }
      { "All files" {"*"} }
    }
  }
  set fnames [tk_getOpenFile -multiple 1 -initialdir $::initialDir(pgn) -filetypes $ftypes -title "Import from PGN files" ]
  if {$fnames == ""} { return }
  
  set ::initialDir(pgn) [file dirname [lindex $fnames 0]]
  foreach fname $fnames {
    doPgnFileImport $fname "" 1
  }
  ::windows::gamelist::Refresh
}

proc doPgnFileImport {fname text {multiple 0} } {
  set w .ipgnWin
  if {[winfo exists $w] && ! $multiple } { destroy $w }
  if {! [winfo exists $w]} {
    toplevel $w
    wm title $w "Scid: Importing PGN file"
    canvas $w.progress -width 400 -height 20 -bg white -relief solid -border 1
    $w.progress create rectangle 0 0 0 0 -fill blue -outline blue -tags bar
    $w.progress create text 395 10 -anchor e -font font_Regular -tags time \
        -fill black -text "0:00 / 0:00"
    
    pack $w.progress -side bottom
    
    frame $w.buttons
    pack $w.buttons -side bottom -fill x
    button $w.buttons.stop -textvar ::tr(Stop) -command {sc_progressBar}
    button $w.buttons.close -textvar ::tr(Close) -command "focus .; destroy $w"
    pack $w.buttons.close $w.buttons.stop -side right -ipadx 5 -padx 5 -pady 2
    
    pack [frame $w.tf] -side top -expand yes -fill both
    text $w.text -height 8 -width 60 -background gray90 \
        -wrap none -cursor watch -setgrid 1 -yscrollcommand "$w.ybar set"
    scrollbar $w.ybar -command "$w.text yview"
    pack $w.ybar -in $w.tf -side right -fill y
    pack $w.text -in $w.tf -side left -fill both -expand yes
  }
  
  sc_progressBar $w.progress bar 401 21 time
  update
  busyCursor .
  catch {grab $w.buttons.stop}
  bind $w <Escape> "$w.buttons.stop invoke"
  $w.buttons.close configure -state disabled
  $w.text configure -state normal
  $w.text insert end $text
  $w.text insert end "Importing PGN games from [file tail $fname]...\n"
  $w.text configure -state disabled
  
  set importPgnErrors ""
  set err [catch {sc_base import file $fname} result]
  unbusyCursor .
  
  set warnings ""
  $w.text configure -state normal
  $w.text configure -cursor top_left_arrow
  if {$err} {
    $w.text insert end $result
  } else {
    set nImported [lindex $result 0]
    set warnings [lindex $result 1]
    set str "Imported $nImported "
    if {$nImported == 1} { append str "game" } else { append str "games" }
    if {$warnings == ""} {
      append str " with no PGN errors or warnings."
    } else {
      append str ".\nPGN errors/warnings:\n$warnings"
    }
    $w.text insert end "$str\n\n"
  }
  
  $w.text configure -state disabled
  $w.buttons.close configure -state normal
  $w.buttons.stop configure -state disabled
  catch {grab release $w.buttons.stop}
  bind $w <Escape> "$w.buttons.close invoke; break"
  
  # Auto-close import progress window if there were no errors/warnings?
  if {!$err  &&  $warnings == "" && ! $multiple} { destroy $w }
  updateTitle
  updateMenuStates
  ::windows::switcher::Refresh
  ::maint::Refresh
  update
}

###
### End of file: import.tcl
###

