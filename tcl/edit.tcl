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

proc setSetupBoardToFen {w setupFen} {
  
  # Called from ".setup.status" FEN combo S.A
  
  # Once the FEN combo box in the Setup board widget is accessed, the original
  # game poisiotn can still be had, but game history is lost
  
  global setupboardSize setupBd
  
  
  if {[catch {sc_game startBoard $setupFen} err]} {
    fenErrorDialog $err
  } else {
    # ::utils::history::AddEntry setupFen $setupFen
    set setupBd [sc_pos board]
    setBoard .setup.l.bd $setupBd $setupboardSize
  }
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
  global setupBd pastePiece setupboardSize setupFen
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
  setBoard .setup.l.bd $setupBd $setupboardSize
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

proc exitSetupBoard {} {
  
  # called when "OK" button hit
  
  global setupFen
  
  # unbind cancel binding
  bind .setup <Destroy> {}
  
  if {[catch {sc_game startBoard $setupFen} err]} {
    fenErrorDialog $err
    bind .setup <Destroy> cancelSetupBoard
    
    # Ideally, "$err" should be more specific than "Invalid FEN", but
    # procedural flow is a little complicated S.A.
  } else {
    ::utils::history::AddEntry setupFen $setupFen
    destroy .setup
    updateBoard -pgn
  }
}

proc cancelSetupBoard {} {
  
  # When FEN strings are previewed, the gameboard state is changed, but *not*
  # drawn in the main window. This means that while the game state can be
  # restored in the event of user hitting "cancel", game history has been lost
  # This behaviour is necessary to enable FEN previewing.
  
  global origFen
  
  bind .setup <Destroy> {}
  
  # restore old gamestate if unchanged
  
  if {$origFen != "[sc_pos fen]"} {
    catch {sc_game startBoard $origFen}
    updateBoard -pgn
  }
  destroy .setup
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

#   todo: perhaps ensure all engines have stopped before doing this S.A.

proc setupBoard {} {
  global boardSizes boardSize setupboardSize lite dark setupBd pastePiece toMove epFile moveNum
  global origFen
  global setupStatus castling setupFen highcolor
  if {[winfo exists .setup]} { return }
  set setupBd [sc_pos board]
  set origFen [sc_pos fen]
  toplevel .setup
  wm title .setup "Scid: Setup Board"
  
  ### Status entrybox contains the current FEN string.
  
  ttk::frame .setup.statusbar
  pack .setup.statusbar -side bottom -expand yes -fill x
  
  ### The actual board is created here. Bindings: left mouse sets/clears
  ### a square, middle mouse selects previous piece, right mouse selects
  ### next piece.  I should also set shortcut keys, e.g. "Q" for Queen.
  
  # todo: drag and drop of pieces would be nice :>
  
  ttk::frame .setup.l
  ttk::frame .setup.r
  ttk::frame .setup.l.bd
  
  set sl .setup.l
  set sr .setup.r
  set sbd .setup.l.bd
  
  pack $sl -side left -expand yes -fill y
  pack $sr -side right -expand yes -fill y
  
  # make the setup board a couple of sizes smaller
  set index [lsearch -exact $boardSizes $boardSize]
  # incr index 0
  # incr index -2
  incr index -3
  if {$index < 0} {
    set index 0
  }
  set setupboardSize [lindex $boardSizes $index]
  
  for {set i 0} {$i < 64} {incr i} {
    ttk::label $sbd.$i -image e$setupboardSize
    set rank [expr {7 - int ($i / 8)} ]
    set fyle [expr {$i % 8} ]
    grid $sbd.$i -row $rank -column $fyle -sticky nesw
    if {[expr {($fyle % 2) == ($rank % 2)} ]} {
      $sbd.$i configure -background $lite
    } else {
      $sbd.$i configure -background $dark
    }
    bind $sbd.$i <ButtonPress-1> "setupBoardPiece $i"
    bind $sbd.$i <ButtonPress-$::MB2> "switchPastePiece prev"
    bind $sbd.$i <ButtonPress-$::MB3> "switchPastePiece next"
  }
  
  pack $sbd -padx 10 -pady 10 -expand 1
  pack [ttk::frame $sl.b] -side top -padx 8 -pady 8 ;# -expand yes -fill x
  # rearrange above two lines for different setup
  pack [ttk::frame $sl.w] -side bottom -padx 8 -pady 8 ;# -expand yes -fill x
  
  setBoard $sbd $setupBd $setupboardSize
  
  ### Piece Buttons
  
  # set pastePiece P
  # set toMove White
  
  foreach i {p n b r q k} {
    foreach color {w b} value "[string toupper $i] $i" {
      radiobutton $sl.$color.$i -image $color$i$setupboardSize -indicatoron 0 -variable pastePiece -value $value -activebackground $highcolor    
      # ttk::radiobutton $sl.$color.$i -image $color$i$setupboardSize -variable pastePiece -value $value
      pack $sl.$color.$i -side left ;# -expand yes -fill x -padx 5
    }
  }
  
  ### Side to move frame.
  
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
  
  ttk::frame $sr.mid.movenum
  ttk::label $sr.mid.movenum.label -textvar ::tr(MoveNumber:)
  ttk::entry $sr.mid.movenum.e -width 3 -background white -textvariable moveNum
  
  pack $sr.mid.movenum -pady 10 -expand yes -fill x
  pack $sr.mid.movenum.label $sr.mid.movenum.e -side left -anchor w -expand yes -fill x
  
  ttk::frame $sr.mid.castle
  ttk::label $sr.mid.castle.label -textvar ::tr(Castling:)
  ttk::combobox $sr.mid.castle.e -width 5 -textvariable castling -values {KQkq K Q k q - KQ kq Kk Kq Kkq Qk Qq Qkq KQk KQq}

  pack $sr.mid.castle -pady 10 -expand yes -fill x
  pack $sr.mid.castle.label $sr.mid.castle.e -side left -anchor w -expand yes -fill x
  
  ttk::frame $sr.mid.ep
  ttk::label $sr.mid.ep.label -textvar ::tr(EnPassantFile:)
  ttk::combobox $sr.mid.ep.e -width 2 -textvariable epFile -values {- a b c d e f g h}
  set epFile {}
  
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
    setBoard .setup.l.bd $setupBd $setupboardSize
    set castling {}
    set setupFen [makeSetupFen]
  }
  ttk::button $sr.b.initial -textvar ::tr(InitialBoard) -command {
    set setupBd \
        "RNBQKBNRPPPPPPPP................................pppppppprnbqkbnr"
    setBoard .setup.l.bd $setupBd $setupboardSize
    set castling KQkq
    set setupFen [makeSetupFen]
  }
  pack $sr.b -side top -pady 15
  pack $sr.b.clear -side top -padx 5 -pady 10 -fill x
  pack $sr.b.initial -side bottom -padx 5 -pady 10 -fill x
  
  ### Buttons: Setup and Cancel.
  
  ttk::frame $sr.b2
  ttk::button $sr.b2.ok -text "OK" -width 7 -command exitSetupBoard
  ttk::button $sr.b2.cancel -textvar ::tr(Cancel) -width 7 -command cancelSetupBoard
  
  pack $sr.b2 -side bottom -pady 20 -anchor s
  pack $sr.b2.ok -side left -padx 5
  pack $sr.b2.cancel -side right -padx 5
  
  ttk::button .setup.paste -textvar ::tr(PasteFen) -command {
    if {[catch {set setupFen [selection get -selection CLIPBOARD]} ]} {
      catch {set setupFen [selection get -selection PRIMARY]}
      # PRIMARY is the X selection, unsure about CLIPBOARD
    }
  }
  ttk::button .setup.clear -textvar ::tr(ClearFen) -command {set setupFen ""}
  
  ttk::combobox .setup.status -textvariable setupFen -height 10
  bind .setup.status <<ComboboxSelected>> {setSetupBoardToFen %W $setupFen}
  ::utils::history::SetCombobox setupFen .setup.status
  ::utils::history::SetLimit setupFen 20
  
  update ; # necessary in case of quick-draw user interactions
  
  pack .setup.paste .setup.clear -in .setup.statusbar -side left
  pack .setup.status -in .setup.statusbar -side right -expand yes -fill x -anchor w
  #bind .setup.status <FocusIn>  { %W configure -background lightYellow }
  #bind .setup.status <FocusOut> { %W configure -background white }
  bind .setup <Escape> cancelSetupBoard
  bind .setup <Destroy> cancelSetupBoard
  
  set setupFen [makeSetupFen]
}

