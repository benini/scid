############################################################
### Board setup window:

# Global variables for entry of the start position:
set epFile {}          ;# legal values are empty, or "a"-"h".
set moveNum 1          ;# legal values are 1-999.
set setupStatus {}     ;# stores the FEN string.
set castling KQkq      ;# will be empty or some combination of KQkq letters.
set toMove White       ;# side to move, "White" or "Black".
set pastePiece K       ;# Piece being pasted, "K", "k", "Q", "q", etc.

# Traces to keep entry values sensible:
trace variable moveNum  w {::utils::validate::Integer 999 0}
trace variable epFile   w {::utils::validate::Regexp {^(-|[a-h])?$}}
trace variable castling w {::utils::validate::Regexp {^(-|[KQkq]*)$}}

set setupBd {}
set setupFen {}

# setupBoard:
#   The main procedure for creating the dialog for setting the start board.
#   Calls switchPastePiece and makeSetupFen.
#   On "Setup" button press, calls sc_pos startBoard to try to set the
#   starting board.
#
proc setupBoard {} {
  global boardSizes boardSize lite dark setupBd pastePiece toMove epFile moveNum
  global origFen
  global setupStatus castling setupFen highcolor
  if {[winfo exists .setup]} { return }
  set setupBd [sc_pos board]
  set origFen [sc_pos fen]

  set w ".setup"
  toplevel $w
  wm title $w "Scid: Setup Board"
  wm minsize $w 650 420

  grid [ttk::frame $w.topspace -height 10] -row 0 -column 0 -columnspan 5 -sticky news

  #Board
  ttk::frame $w.l
  bind $w.l <Configure> "::board::resizeAuto $w.l.bd \[grid bbox $w 0 1\]"

  ::board::new $w.l.bd
  ::board::coords $w.l.bd
  for {set i 0} { $i < 64 } { incr i } {
    ::board::bind $w.l.bd $i <B1-Motion>       "dragBoardPiece  $w.l.bd %X %Y $i"
    ::board::bind $w.l.bd $i <ButtonRelease-1> "setupBoardPiece $w.l.bd %X %Y"
    ::board::bind $w.l.bd $i <2>               "removeBoardPiece $w.l.bd $i"
    ::board::bind $w.l.bd $i <3>               "removeBoardPiece $w.l.bd $i"
  }
  grid $w.l.bd -sticky news
  grid rowconfigure $w.l.bd 0 -weight 1
  grid columnconfigure $w.l.bd 0 -weight 1
  grid $w.l -row 1 -column 0 -sticky news
  grid rowconfigure $w 1 -weight 1
  grid columnconfigure $w 0 -weight 1
  
  ### Piece Buttons
  foreach psize $::boardSizes {
      if {$psize >= 40} { break }
  }
  grid [ttk::frame $w.piecespace -width 10] -row 1 -column 1 -sticky news
  grid [ttk::frame $w.piecesw] -row 1 -column 2 -sticky news
  grid [ttk::frame $w.piecesb] -row 1 -column 3 -sticky news
  grid [ttk::frame $w.piecesw.topspace -height 2] -column 0
  grid [ttk::frame $w.piecesb.topspace -height 2] -column 0
  foreach i {p n b r q k} {
    foreach color {w b} value "[string toupper $i] $i" {
      radiobutton $w.pieces$color.$i -image $color$i$psize -indicatoron 0 -variable pastePiece -value $value -activebackground $highcolor    
      grid $w.pieces$color.$i -column 0 -pady 2 -padx 2
    }
  }

  set sl .setup.l
  set sr .setup.r
  set sbd .setup.l.bd

  

  ttk::frame .setup.r
  ttk::frame .setup.statusbar
  grid .setup.r -row 1 -column 4 -sticky news
  grid .setup.statusbar -row 2 -column 0 -columnspan 5 -sticky news


  ### Side to move frame.
  
  set toMove [lindex {White Black} [string equal [lindex $origFen 1] b]]
  ttk::frame $sr.tomove
  ttk::label $sr.tomove.label -textvar ::tr(SideToMove:)
  ttk::frame $sr.tomove.buttons
  ttk::radiobutton $sr.tomove.buttons.w -text $::tr(White) -variable toMove -value White \
      -command {set setupFen [makeSetupFen]}
  ttk::radiobutton $sr.tomove.buttons.b -text $::tr(Black) -variable toMove -value Black \
      -command {set setupFen [makeSetupFen]}
  
  pack $sr.tomove -pady 7
  pack $sr.tomove.label -side top -pady 2
  pack $sr.tomove.buttons -side top
  pack $sr.tomove.buttons.w $sr.tomove.buttons.b -side left
  
  ### Entry boxes: Move number, Castling and En Passant file.
  
  pack [ttk::frame $sr.mid] -padx 5 -pady 5
  
  set moveNum [lindex $origFen 5]
  ttk::frame $sr.mid.movenum
  ttk::label $sr.mid.movenum.label -textvar ::tr(MoveNumber:)
  ttk::entry $sr.mid.movenum.e -width 3 -background white -textvariable moveNum
  
  pack $sr.mid.movenum -pady 10 -expand yes -fill x
  pack $sr.mid.movenum.label $sr.mid.movenum.e -side left -anchor w -expand yes -fill x
  
  set castling [lindex $origFen 2]
  ttk::frame $sr.mid.castle
  ttk::label $sr.mid.castle.label -textvar ::tr(Castling:)
  ttk::combobox $sr.mid.castle.e -width 5 -textvariable castling -values {KQkq K Q k q - KQ kq Kk Kq Kkq Qk Qq Qkq KQk KQq}

  pack $sr.mid.castle -pady 10 -expand yes -fill x
  pack $sr.mid.castle.label $sr.mid.castle.e -side left -anchor w -expand yes -fill x
  
  set epFile [string index [lindex $origFen 3] 0]
  ttk::frame $sr.mid.ep
  ttk::label $sr.mid.ep.label -textvar ::tr(EnPassantFile:)
  ttk::combobox $sr.mid.ep.e -width 2 -textvariable epFile -values {- a b c d e f g h}
  
  pack $sr.mid.ep -pady 10 -expand yes -fill x
  pack $sr.mid.ep.label $sr.mid.ep.e -side left -anchor w -expand yes -fill x
  
  # Set bindings so the Fen string is updated at any change. The "after idle"
  # is needed to ensure any keypress which causes a text edit is processed
  # before we regenerate the FEN text.
  
  foreach i "$sr.mid.ep.e $sr.mid.castle.e $sr.mid.movenum.e" {
    bind $i <Any-KeyPress> {after idle {set setupFen [makeSetupFen]}}
    bind $i <FocusOut> {
      after idle {set setupFen [makeSetupFen]}}
  }
  
  ### Buttons: Clear Board and Initial Board.
  
  ttk::frame $sr.b
  ttk::button $sr.b.clear -textvar ::tr(EmptyBoard) -command {
    set setupBd \
        "................................................................"
    ::board::update .setup.l.bd $setupBd
    set castling {}
    set setupFen [makeSetupFen]
  }
  ttk::button $sr.b.initial -textvar ::tr(InitialBoard) -command {
    set setupBd \
        "RNBQKBNRPPPPPPPP................................pppppppprnbqkbnr"
    ::board::update .setup.l.bd $setupBd
    set castling KQkq
    set setupFen [makeSetupFen]
  }
  pack $sr.b -side top -pady 15
  pack $sr.b.clear -side top -padx 5 -pady 10 -fill x
  pack $sr.b.initial -side bottom -padx 5 -pady 10 -fill x
  
  ### Buttons: Setup and Cancel.
  
  ttk::frame $sr.b2
  ttk::button $sr.b2.ok -text "OK" -width 7 -command exitSetupBoard
  ttk::button $sr.b2.cancel -textvar ::tr(Cancel) -width 7 -command {destroy .setup}
  
  pack $sr.b2 -side bottom -pady 20 -anchor s
  pack $sr.b2.ok -side left -padx 5
  pack $sr.b2.cancel -side right -padx 5
  
  ttk::button .setup.paste -textvar ::tr(PasteFen) -command {
    if {[catch {set setupFen [selection get -selection CLIPBOARD]} ]} {
      # PRIMARY is the X selection, unsure about CLIPBOARD
      if {[catch {set setupFen [selection get -selection PRIMARY]}]} { return }
    }
    setSetupBoardToFen %W $setupFen
  }
  ttk::button .setup.clear -textvar ::tr(ClearFen) -command {set setupFen ""}
  
  ttk::combobox .setup.status -textvariable setupFen -height 10
  bind .setup.status <<ComboboxSelected>> {setSetupBoardToFen %W $setupFen}
  ::utils::history::SetCombobox setupFen .setup.status
  ::utils::history::SetLimit setupFen 20
  
  update ; # necessary in case of quick-draw user interactions
  
  pack .setup.paste .setup.clear -in .setup.statusbar -side left
  pack .setup.status -in .setup.statusbar -side right -expand yes -fill x -anchor w


  if {[info exists ::winGeometry($w)]} { wm geometry $w $::winGeometry($w) }
  bind $w <Destroy> "if {\[string equal $w %W\]} { set ::winGeometry($w) \[wm geometry $w\]; options.save ::winGeometry($w) }"
  bind $w <Escape> {destroy .setup}

  set setupFen [makeSetupFen]
}

proc setSetupBoardToFen {w setupFen} {
  global setupBd toMove castling epFile moveNum

  sc_game push
  if {[catch {sc_game startBoard $setupFen} err]} {
    fenErrorDialog $err
  } else {
    set setupBd [sc_pos board]
    set toMove [lindex {White Black} [string equal [lindex $setupFen 1] b]]
    set castling [lindex $setupFen 2]
    set epFile [string index [lindex $setupFen 3] 0]
    set moveNum [lindex $setupFen 5]
    ::board::update .setup.l.bd $setupBd
  }
  sc_game pop
}


# makeSetupFen:
#    Reconstructs the FEN string from the current settings in the
#    setupBoard dialog. Check to see if the position is
#    acceptable (a position can be unacceptable by not having exactly
#    one King per side, or by having more than 16 pieces per side).
#
proc makeSetupFen {} {
  global setupFen setupBd moveNum toMove castling epFile
  set fenStr ""
  set errorStr [validateSetup]
  if {$errorStr != ""} {
    set fenStr "Invalid board: "
    append fenStr $errorStr
    return $fenStr
  }
  for {set bRow 56} {$bRow >= 0} {incr bRow -8} {
    if {$bRow < 56} { append fenStr "/" }
    set emptyRun 0
    for {set bCol 0} {$bCol < 8} {incr bCol} {
      set sq [expr {$bRow + $bCol} ]
      set piece [string index $setupBd $sq]
      if {$piece == "."} {
        incr emptyRun
      } else {
        if {$emptyRun > 0} {
          append fenStr $emptyRun
          set emptyRun 0
        }
        append fenStr $piece
      }
    }
    if {$emptyRun > 0} { append fenStr $emptyRun }
  }
  append fenStr " " [string tolower [string index $toMove 0]] " "
  if {$castling == ""} {
    append fenStr "- "
  } else {
    append fenStr $castling " "
  }
  if {$epFile == ""  ||  $epFile == "-"} {
    append fenStr "-"
  } else {
    append fenStr $epFile
    if {$toMove == "White"} {
      append fenStr "6"
    } else {
      append fenStr "3"
    }
  }
  # We assume a halfmove clock of zero:
  append fenStr " 0 " $moveNum
  set setupFen $fenStr
  return $fenStr
}

# validateSetup:
#   Called by makeSetupFen to check that the board is sensible: that is,
#   that there is one king per side and there are at most 16 pieces per
#   side and there are no pawn in the 1st or 8th row
#
proc validateSetup {} {
  global setupBd
  set wkCount 0; set bkCount 0; set wCount 0; set bCount 0
  set wpCount 0; set bpCount 0
  for {set i 0} {$i < 64} {incr i} {
    set p [string index $setupBd $i]
    if {$p == "."} {
    } elseif {$p == "P"} { incr wCount; incr wpCount
    } elseif {$p == "p"} { incr bCount; incr bpCount
    } elseif {$p == "N" || $p == "B" || $p == "R" || $p == "Q"} {
      incr wCount
    } elseif {$p == "n" || $p == "b" || $p == "r" || $p == "q"} {
      incr bCount
    } elseif {$p == "K"} { incr wCount; incr wkCount
    } elseif {$p == "k"} { incr bCount; incr bkCount
    } else { return "Invalid piece: $p" }
    if {$p == "P"  ||  $p == "p"} {
      if {$i < 8}   { return "There must be no pawn in the 1st row" }
      if {$i >= 56} { return "There must be no pawn in the 8th row" }
    }
  }
  if {$wkCount != 1} { return "There must be one white king"
  } elseif {$bkCount != 1} { return "There must be one black king"
  } elseif {$wCount > 16} { return "Too many white pieces"
  } elseif {$bCount > 16} { return "Too many black pieces"
  } elseif {$wpCount > 8} { return "Too many white pawns"
  } elseif {$bpCount > 8} { return "Too many black pawns" }
  return ""
}

proc dragBoardPiece {w x y startSq} {
  set square [::board::getSquare $w $x $y]
  if {$square != $startSq && [::board::getDragSquare $w] == -1} {
    set tmp [string index $::setupBd $startSq]
    if {$tmp == "."} { return }
    set ::pastePiece $tmp
    ::board::setDragSquare .setup.l.bd $startSq
  }

  ::board::dragPiece .setup.l.bd $x $y
}

proc setupBoardPiece {w x y} {
  global setupBd pastePiece setupFen

  set square [::board::getSquare $w $x $y]
  set newPiece $pastePiece
  set oldPiece [string index $setupBd $square]
  set delSq [::board::setDragSquare .setup.l.bd -1]
  if {$delSq != -1} {
    #Dragged
    if {$delSq == $square} { return }
    set setupBd [string replace $setupBd $delSq $delSq "."]
    catch { unset ::erasePiece }
  } else {
    #Left click
    if {$oldPiece == $newPiece} {
      set newPiece [string tolower $newPiece]
      if {$newPiece == $pastePiece} { set newPiece [string toupper $newPiece] }
      set ::erasePiece "$oldPiece$square"
    } else {
      if {[info exists ::erasePiece] && $::erasePiece == "$newPiece$square"} {
        set newPiece "."
      }
      catch { unset ::erasePiece }
    }
  }

  set setupBd [string replace $setupBd $square $square $newPiece]
  ::board::update .setup.l.bd $setupBd
  set setupFen [makeSetupFen]
}

proc removeBoardPiece {w square} {
  global setupBd setupFen

  set setupBd [string replace $setupBd $square $square "."]
  ::board::update $w $setupBd
  set setupFen [makeSetupFen]
}

proc exitSetupBoard {} {
  global setupFen

  undoFeature save
  if {[catch {sc_game startBoard $setupFen} err]} {
    undoFeature undo
    fenErrorDialog $err
  } else {
    ::utils::history::AddEntry setupFen $setupFen
    destroy .setup
    ::notify::PosChanged -pgn
  }
}

### End of Board setup window
############################################################


proc fenErrorDialog {{msg {}}} {
  if {[winfo exists .setup]} {
    tk_messageBox -icon info -type ok -title "Scid: Invalid FEN" -message $msg -parent .setup
  } else {
    tk_messageBox -icon info -type ok -title "Scid: Invalid FEN" -message $msg
  }
}

# copyFEN
#
#   Copies the FEN of the current position to the text clipboard.
#
proc copyFEN {} {
  set fen [sc_pos fen]
  # Create a text widget to hold the fen so it can be the owner
  # of the current text selection:
  set w .tempFEN
  if {! [winfo exists $w]} { text $w }
  $w delete 1.0 end
  $w insert end $fen sel
  clipboard clear
  clipboard append $fen
  selection own $w
  selection get
}

# pasteFEN
#
#   Bypasses the board setup window and tries to paste the current
#   text selection as the setup position, producing a message box
#   if the selection does not appear to be a valid FEN string.
#
proc pasteFEN {} {
  set fenStr ""
  if {[catch {set fenStr [selection get -selection CLIPBOARD]} ]} {
    catch {set fenStr [selection get -selection PRIMARY]}
  }
  set fenStr [string trim $fenStr]

  set fenExplanation {FEN is the standard text representation of a chess position. As an example, the FEN representation of the standard starting position is:
    "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"}

  if {$fenStr == ""} {
    set msg "The current text selection is empty. To paste the start board, select some text that contains a position in FEN notation.\n\n$fenExplanation"
    fenErrorDialog $msg
    return
  }
  if {[catch {sc_game startBoard $fenStr}]} {
    if {[string length $fenStr] > 80} {
      set fenStr [string range $fenStr 0 80]
      append fenStr "..."
    }
    set msg "\"$fenStr\" is not a valid chess position in FEN notation.\n\n $fenExplanation"

    fenErrorDialog $msg
    return
  }
  updateBoard -pgn
}

