# Scid Pocket (C) 2007 Pascal Georges
### Based on Scid (C) Shane Hudson
#

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
    set fenStr [::msgcat::mc "Invalid board: "]
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
############################################################
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
############################################################
# setupBoardPiece:
#    Called by setupBoard to set or clear a square when it is clicked on.
#    Sets that square to containing the active piece (stored in pastePiece)
#    unless it already contains that piece, in which case the square is
#    cleared to be empty.
#
proc setupBoardPiece { square } {
  global setupBd pastePiece  setupFen
  set oldState $setupBd
  set setupBd {}
  set piece $pastePiece
  if {$::hires} {
    set pSize $::board::pSize_hires_setup
  } else {
    set pSize $::board::pSize_lowres_setup
  }
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
  ::board::setBoard .setup.fTop.bd $setupBd $pSize
  set setupFen [makeSetupFen]
}

# Global variables for entry of the start position:
set epFile {}          ;# legal values are empty, or "a"-"h".
set moveNum 1          ;# legal values are 1-999.
set castling KQkq      ;# will be empty or some combination of KQkq letters.
set toMove White       ;# side to move, "White" or "Black".
set pastePiece K       ;# Piece being pasted, "K", "k", "Q", "q", etc.

# Traces to keep entry values sensible:

trace variable moveNum w {::utils::validate::Integer 999 0}
trace variable epFile w {::utils::validate::Regexp {^(-|[a-h])?$}}
trace variable castling w {::utils::validate::Regexp {^(-|[KQkq]*)$}}

############################################################
# setupBoard:
#   The main procedure for creating the dialog for setting the start board.
#   Calls makeSetupFen.
#   On "Setup" button press, calls sc_pos startBoard to try to set the
#   starting board.
#
proc setupBoard {} {
  set lite $::board::lightSquare
  set dark $::board::darkSquare
  
  global setupBd pastePiece toMove epFile moveNum
  global castling setupFen
  if {[winfo exists .setup]} { return }
  set setupBd [sc_pos board]
  toplevel .setup
  wm title .setup [::msgcat::mc "Set position" ]
  
  ::ui::setFullSize .setup 0
  
  if {$::hires} {
    set pSize $::board::pSize_hires_setup
  } else {
    set pSize $::board::pSize_lowres_setup
  }
  
  frame .setup.fTop
  pack .setup.fTop -side top
  canvas .setup.fTop.bd -width [expr $pSize*8] -height [expr $pSize*8]
  set sbd .setup.fTop.bd
  
  # Create empty board:
  for {set i 0} {$i < 64} {incr i} {
    set xi [expr {$i % 8} ]
    set yi [expr { 7 - int($i/8)} ]
    set x1 [expr {$xi * $pSize} ]
    set y1 [expr {$yi * $pSize} ]
    set x2 [expr {$x1 + $pSize} ]
    set y2 [expr {$y1 + $pSize} ]
    $sbd create rectangle $x1 $y1 $x2 $y2 -tag sq$i
    set color [::board::defaultColor $i]
    $sbd itemconfigure sq$i -outline $color -fill $color
  }
  # bindings
  for {set i 0} {$i < 64} {incr i} {
    if {!$::board::isFlipped} {
      $sbd bind sq$i <ButtonPress-1> "setupBoardPiece $i"
      $sbd bind piece$i <ButtonPress-1> "setupBoardPiece $i"
    } else {
      set fsq [expr 63-$i]
      $sbd bind sq$i <ButtonPress-1> "setupBoardPiece $fsq"
      $sbd bind piece$i <ButtonPress-1> "setupBoardPiece $fsq"
    }
  }
  
  pack $sbd -side left
  
  set ::board::previousBoard($sbd) ""
  ::board::setBoard $sbd $setupBd $pSize
  
  ### Piece Buttons
  set sr .setup.fTop
  frame $sr.sw; frame $sr.sb
  
  foreach i {k q r b n p} {
    set i2 [string toupper $i]
    radiobutton $sr.sw.$i -image w${i}$pSize -indicatoron 0 -variable pastePiece -value $i2
    pack $sr.sw.$i -side top
    radiobutton $sr.sb.$i -image b${i}$pSize -indicatoron 0 -variable pastePiece -value $i
    pack $sr.sb.$i -side top
  }
  pack $sr.sw $sr.sb -side left
  
  ### Quick Board Setup buttons: Clear Board and Initial Board.
  frame .setup.fBottom
  pack .setup.fBottom -side top
  set sr .setup.fBottom
  
  frame $sr.b
  button $sr.b.clear -text [::msgcat::mc "Empty"] -command {
    set setupBd "................................................................"
    if {$::hires} {
      ::board::setBoard .setup.fTop.bd $setupBd $::board::pSize_hires_setup
    } else {
      ::board::setBoard .setup.fTop.bd $setupBd $::board::pSize_lowres_setup
    }
    set castling {}
    set setupFen [makeSetupFen]
  }
  button $sr.b.initial -text [::msgcat::mc "Start pos."] -command {
    set setupBd "RNBQKBNRPPPPPPPP................................pppppppprnbqkbnr"
    if {$::hires} {
      ::board::setBoard .setup.fTop.bd $setupBd $::board::pSize_hires_setup
    } else {
      ::board::setBoard .setup.fTop.bd $setupBd $::board::pSize_lowres_setup
    }
    set castling KQkq
    set setupFen [makeSetupFen]
  }
  label $sr.b.label -text [::msgcat::mc "Move:"]
  entry $sr.b.e -width 3 -background white -textvariable moveNum
  pack $sr.b.clear $sr.b.initial $sr.b.label $sr.b.e -side left
  
  ### Side to move frame.
  frame $sr.tomove
  label $sr.tomove.label -text [::msgcat::mc "Side:"]
  radiobutton $sr.tomove.w -text [::msgcat::mc "White" ] -variable toMove -value White -command {set setupFen [makeSetupFen]}
  radiobutton $sr.tomove.b -text [::msgcat::mc "Black" ] -variable toMove -value Black -command {set setupFen [makeSetupFen]}
  pack $sr.tomove.label $sr.tomove.w $sr.tomove.b -side left
  
  ### Entry boxes: Move number, Castling and En Passant file.
  
  frame $sr.castle
  label $sr.castle.label -text [::msgcat::mc "Castling:"]
  ttk::combobox $sr.castle.e -width 5 -textvariable castling -values {KQkq KQ kq -}
  # foreach c {KQkq KQ kq -} {
    # $sr.castle.e list insert end $c
  # }
  
  label $sr.castle.label2 -text "En passant"
  ttk::combobox $sr.castle.e2 -width 2 -textvariable epFile -values {- a b c d e f g h}
  set epFile {}
  # foreach f {- a b c d e f g h} {
    # $sr.castle.e2 list insert end $f
  # }
  pack $sr.castle.label $sr.castle.e $sr.castle.label2 $sr.castle.e2 -side left
  
  ### Buttons: Setup and Cancel.
  
  frame $sr.b2
  button $sr.b2.setup -text "OK" -command {
    if {[catch {sc_game startBoard [makeSetupFen]} err]} {
      tk_messageBox -icon info -type ok -title "Scid" -parent .setup -message $err
    } else {
      destroy .setup
      ::board::updateBoard -pgn -nolastmove
    }
  }
  button $sr.b2.cancel -text [::msgcat::mc "Cancel" ] -command {
    destroy .setup
  }
  pack $sr.b2.setup $sr.b2.cancel -side left
  
  pack $sr.b $sr.tomove $sr.castle -side top
  pack $sr.b2 -side top
  
  set setupFen [makeSetupFen]
}
