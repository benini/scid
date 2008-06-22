
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

  set fenExplanation {
FEN is the standard text representation of a chess position.
As an example, the FEN representation of the standard starting position is:

rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1
}

  if {$fenStr == ""} {
    set msg "The current text selection is empty.\n"
    append msg "To paste the start board, select some text that contains\n"
    append msg "a position in FEN notation.\n"
    append msg $fenExplanation
    tk_messageBox -icon info -type ok -title "Scid: Invalid FEN" -message $msg
    return
  }
  if {[catch {sc_game startBoard $fenStr}]} {
    if {[string length $fenStr] > 80} {
      set fenStr [string range $fenStr 0 80]
      append fenStr "..."
    }
    set msg "The current text selection is not a valid chess position in FEN notation.\n"
    append msg "The selected text is:\n\n$fenStr\n"
    append msg $fenExplanation
    tk_messageBox -icon info -type ok -title "Scid: Invalid FEN" -message $msg
    return
  }
  updateBoard -pgn
}

############################################################
### Board setup window:

set setupBd {}
set setupFen {}

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
#   side.
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
  }
  if {$wkCount != 1} { return "There must be one white king"
  } elseif {$bkCount != 1} { return "There must be one black king"
  } elseif {$wCount > 16} { return "Too many white pieces"
  } elseif {$bCount > 16} { return "Too many black pieces"
  } elseif {$wpCount > 8} { return "Too many white pawns"
  } elseif {$bpCount > 8} { return "Too many black pawns" }
  return ""
}

# setupBoardPiece:
#    Called by setupBoard to set or clear a square when it is clicked on.
#    Sets that square to containing the active piece (stored in pastePiece)
#    unless it already contains that piece, in which case the square is
#    cleared to be empty.
#
proc setupBoardPiece { square } {
  global setupBd pastePiece boardSize setupFen
  set oldState $setupBd
  set setupBd {}
  set piece $pastePiece
  if {[string index $oldState $square] == $pastePiece} {
    set piece "."
  }
  if {$piece == "P"  ||  $piece == "p"} {
    if {$square < 8  ||  $square >= 56} {
      set setupBd $oldState
      unset oldState
      return
    }
  }
  append setupBd \
    [string range $oldState 0 [expr {$square - 1} ]] \
    $piece \
    [string range $oldState [expr {$square + 1} ] 63]
  unset oldState
  setBoard .setup.bd $setupBd $boardSize
  set setupFen [makeSetupFen]
}

# switchPastePiece:
#   Changes the active piece selection in the board setup dialog to the
#   next or previous piece in order.
#
proc switchPastePiece { switchType } {
  global pastePiece
  array set nextPiece { K Q Q R R B B N N P P k k q q r r b b n n p p K}
  array set prevPiece { K p Q K R Q B R N B P N k P q k r q b r n b p n}
  if {$switchType == "next"} {
    set pastePiece $nextPiece($pastePiece)
  } else {
    set pastePiece $prevPiece($pastePiece)
  }
}

# Global variables for entry of the start position:
set epFile {}          ;# legal values are empty, or "a"-"h".
set moveNum 1          ;# legal values are 1-999.
set setupStatus {}     ;# stores the FEN string.
set castling KQkq      ;# will be empty or some combination of KQkq letters.
set toMove White       ;# side to move, "White" or "Black".
set pastePiece K       ;# Piece being pasted, "K", "k", "Q", "q", etc.

# Traces to keep entry values sensible:

trace variable moveNum w {::utils::validate::Integer 999 0}
trace variable epFile w {::utils::validate::Regexp {^(-|[a-h])?$}}
trace variable castling w {::utils::validate::Regexp {^(-|[KQkq]*)$}}


# setupBoard:
#   The main procedure for creating the dialog for setting the start board.
#   Calls switchPastePiece and makeSetupFen.
#   On "Setup" button press, calls sc_pos startBoard to try to set the
#   starting board.
#
proc setupBoard {} {
  global boardSize lite dark setupBd pastePiece toMove epFile moveNum
  global setupStatus castling setupFen highcolor
  if {[winfo exists .setup]} { return }
  set setupBd [sc_pos board]
  toplevel .setup
  wm title .setup "Scid: Set Start Board"

  ### Status entrybox contains the current FEN string.

  frame .setup.statusbar
  pack .setup.statusbar -side bottom -expand yes -fill x

  ### The actual board is created here. Bindings: left mouse sets/clears
  ### a square, middle mouse selects previous piece, right mouse selects
  ### next piece.  I should also set shortcut keys, e.g. "Q" for Queen.

  frame .setup.bd -cursor crosshair
  set sbd .setup.bd
  for {set i 0} {$i < 64} {incr i} {
    label $sbd.$i -image e$boardSize
    set rank [expr {7 - int ($i / 8)} ]
    set fyle [expr {$i % 8} ]
    grid $sbd.$i -row $rank -column $fyle -sticky nesw
    if {[expr {($fyle % 2) == ($rank % 2)} ]} {
      $sbd.$i configure -background $lite
    } else {
      $sbd.$i configure -background $dark
    }
    bind $sbd.$i <ButtonPress-1> "setupBoardPiece $i"
    bind $sbd.$i <ButtonPress-2> "switchPastePiece prev"
    bind $sbd.$i <ButtonPress-3> "switchPastePiece next"
  }
  pack $sbd -side left -ipadx 10 -ipady 10
  setBoard $sbd $setupBd $boardSize

  ### Piece Buttons

  frame .setup.r
  set sr .setup.r
  frame $sr.sw; frame $sr.sb
  #set pastePiece P
  #set toMove White
  foreach i {k q r b n p} {
    set i2 [string toupper $i]
    radiobutton $sr.sw.$i -image w${i}$boardSize -indicatoron 0 \
      -variable pastePiece -value $i2 -activebackground $highcolor
    pack $sr.sw.$i -side left
    radiobutton $sr.sb.$i -image b${i}$boardSize -indicatoron 0 \
      -variable pastePiece -value $i -activebackground $highcolor
    pack $sr.sb.$i -side left
  }

  ### Quick Board Setup buttons: Clear Board and Initial Board.

  frame $sr.b
  button $sr.b.clear -textvar ::tr(EmptyBoard) -command {
    set setupBd \
      "................................................................"
    setBoard .setup.bd $setupBd $boardSize
    set castling {}
    set setupFen [makeSetupFen]
  }
  button $sr.b.initial -textvar ::tr(InitialBoard) -command {
    set setupBd \
      "RNBQKBNRPPPPPPPP................................pppppppprnbqkbnr"
    setBoard .setup.bd $setupBd $boardSize
    set castling KQkq
    set setupFen [makeSetupFen]
  }

  ### Side to move frame.

  frame $sr.tomove
  label $sr.tomove.label -textvar ::tr(SideToMove:)
  radiobutton $sr.tomove.w -text $::tr(White) -variable toMove -value White \
    -command {set setupFen [makeSetupFen]}
  radiobutton $sr.tomove.b -text $::tr(Black) -variable toMove -value Black \
    -command {set setupFen [makeSetupFen]}
  pack $sr.tomove.label $sr.tomove.w $sr.tomove.b -side left

  ### Entry boxes: Move number, Castling and En Passant file.

  frame $sr.movenum
  label $sr.movenum.label -textvar ::tr(MoveNumber:)
  entry $sr.movenum.e -width 3 -background white -textvariable moveNum
  pack $sr.movenum.label $sr.movenum.e -side left

  frame $sr.castle
  label $sr.castle.label -textvar ::tr(Castling:)
  ::combobox::combobox $sr.castle.e -width 5 -background white -textvariable castling
  pack $sr.castle.label $sr.castle.e -side left
  foreach c {KQkq KQ kq -} {
    $sr.castle.e list insert end $c
  }

  frame $sr.ep
  label $sr.ep.label -textvar ::tr(EnPassantFile:)
  ::combobox::combobox $sr.ep.e -width 2 -background white -textvariable epFile
  set epFile {}
  pack $sr.ep.label $sr.ep.e -side left
  foreach f {- a b c d e f g h} {
    $sr.ep.e list insert end $f
  }

  # Set bindings so the Fen string is updated at any change. The "after idle"
  # is needed to ensure any keypress which causes a text edit is processed
  # before we regenerate the FEN text.

  foreach i "$sr.ep.e $sr.castle.e $sr.movenum.e" {
    bind $i <Any-KeyPress> {after idle {set setupFen [makeSetupFen]}}
    bind $i <FocusOut> {
      after idle {set setupFen [makeSetupFen]}}
  }

  ### Buttons: Setup and Cancel.

  frame $sr.b2
  button $sr.b2.setup -text "OK" -command {
    if {[catch {sc_game startBoard $setupFen} err]} {
      tk_messageBox -icon info -type ok -title "Scid" -message $err
    } else {
      ::utils::history::AddEntry setupFen $setupFen
      destroy .setup
      updateBoard -pgn
    }
  }
  button $sr.b2.cancel -textvar ::tr(Cancel) -command {
    destroy .setup
  }
  pack $sr.b2.setup $sr.b2.cancel -side left -ipadx 10 -padx 5
  pack $sr -side right
  pack $sr.sw $sr.sb $sr.b $sr.tomove $sr.movenum $sr.castle $sr.ep \
    $sr.b2 -side top -pady 10
  pack $sr.b.clear $sr.b.initial -side left

  button .setup.paste -textvar ::tr(PasteFen) -command {
    if {[catch {set setupFen [selection get -selection CLIPBOARD]} ]} {
      catch {set setupFen [selection get -selection PRIMARY]}
    }
  }
  button .setup.clear -textvar ::tr(ClearFen) -command {set setupFen ""}
  ::combobox::combobox .setup.status -relief sunken -textvariable setupFen \
    -font font_Small -background white
  ::utils::history::SetCombobox setupFen .setup.status
  pack .setup.paste .setup.clear -in .setup.statusbar -side left
  pack .setup.status -in .setup.statusbar -side right -expand yes -fill x -anchor w
  #bind .setup.status <FocusIn>  { %W configure -background lightYellow }
  #bind .setup.status <FocusOut> { %W configure -background white }

  set setupFen [makeSetupFen]
}

