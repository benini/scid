# board.tcl: part of Scid
# Copyright (C) 2001 Shane Hudson. All rights reserved.

# images:
#    Array that maps piece letters to their two-character value.
#
array set images [list "R" wr "r" br "N" wn "n" bn "B" wb "b" bb \
                       "Q" wq "q" bq "K" wk "k" bk "P" wp "p" bp "." e]

############################################################
### Board setup window:

set setupBd {}
set setupFen {}

# pasteFEN:
#   Bypasses the board setup window and tries to paste the current
#   text selection as the setup position, producing a message box
#   if the selection does not appear to be a valid FEN string.
#
proc pasteFEN {} {
  set fenStr ""
  catch {selection get} fenStr
  set fenStr [string trim $fenStr]
  if {$fenStr == ""} {
    tk_messageBox -icon info -type ok -title "Scid" \
        -message "The current text selection is empty.\nTo paste the start board, select some text that contains a position in FEN notation."
    return
  }
  if {[catch {sc_game startBoard $fenStr}]} {
    if {[string length $fenStr] > 30} {
      set fenStr [string range $fenStr 0 30]
      append fenStr "..."
    }
    tk_messageBox -icon info -type ok -title "Scid" \
      -message "The current text selection is not a valid chess position in FEN notation.\nThe selected text is:\n\n$fenStr"
    return
  }
  updateBoardAndPgn
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
      set sq [expr $bRow + $bCol]
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
#    XXX I need to add checking for a pawn, so pawns cannot be added to
#    the first or eighth rank.
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
    [string range $oldState 0 [expr $square - 1]] \
    $piece \
    [string range $oldState [expr $square + 1] 63]
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

trace variable moveNum w {forceInt 999 0}
trace variable epFile w {forceRegexp {^(-|[a-h])?$}}
trace variable castling w { forceRegexp {^(-|[KQkq]*)$}}


# List of color schemes: each sublist contains a reference name (not used),
# then lite, dark, highcolor, bestcolor, white, black, w border, b border.
#
set colorSchemes {
  { "Brown" "#d0c0a0" "#a08050" "#b0d0e0" "#bebebe" }
  { "Green-Yellow" "#e0d070" "#70a070" "#b0d0e0" "#bebebe" }
  { "Blue-ish" "#d0e0d0" "#80a0a0" "#b0d0e0" "#f0f0a0" }
  { "M. Thomas" "#e0d8b8" "#047c24" "#1c80e0" "#fe0000" }
  { "KM. Skontorp" "#ffdb86" "#ffa200" "#b0d0e0" "#bebebe" }
}
array set newColors {}

# chooseBoardColors:
#   Dialog for selecting board colors.
#
proc chooseBoardColors {{choice -1}} {
  global lite dark highcolor bestcolor
  global colorSchemes newColors

  set colors {lite dark highcolor bestcolor}

  set w .boardColorDialog

  if {[winfo exists $w]} {
    # Just update the dialog box colors and return:
    if {$choice >= 0} {
      set list [lindex $colorSchemes $choice]
      set newColors(lite) [lindex $list 1]
      set newColors(dark) [lindex $list 2]
      set newColors(highcolor) [lindex $list 3]
      set newColors(bestcolor) [lindex $list 4]
    }
    set nlite $newColors(lite)
    set ndark $newColors(dark)

    foreach i {wr bn wb bq wk bp} {
      $w.bd.$i configure -background $ndark
    }
    foreach i {br wn bb wq bk wp} {
      $w.bd.$i configure -background $nlite
    }
    foreach i $colors {
      $w.select.b$i configure -background $newColors($i)
    }
    return
  }

  toplevel $w
  wm title $w "Scid: [tr OptionsColors]"

  foreach i $colors { set newColors($i) [set $i] }
  set bd $w.bd
  pack [frame $bd] -side top -padx 2 -pady 2
  addHorizontalRule $w
  pack [frame $w.select] -side top -fill x
  addHorizontalRule $w
  pack [frame $w.preset] -side top -fill x
  addHorizontalRule $w
  pack [frame $w.buttons] -side top -fill x

  set column 0
  foreach j {r n b q k p} {
    label $bd.w$j -image w${j}40
    label $bd.b$j -image b${j}40
    grid $bd.b$j -row 0 -column $column
    grid $bd.w$j -row 1 -column $column
    incr column
  }

  set f $w.select
  foreach row {0 1 0 1} column {0 0 2 2} c {
    lite dark highcolor bestcolor
  } n {
    LightSquares DarkSquares SelectedSquares SuggestedSquares
  } {
    button $f.b$c -image e20 -background [set $c] -command "
      set x \[ tk_chooseColor -initialcolor \$newColors($c) -title Scid \]
      if {\$x != \"\"} { set newColors($c) \$x; chooseBoardColors }
    "
    label $f.l$c -text "$::tr($n)  "
    grid $f.b$c -row $row -column $column
    grid $f.l$c -row $row -column [expr $column + 1] -sticky w
  }

  set count 0
  set psize 40
  foreach list $colorSchemes {
    set f $w.preset.p$count
    pack [frame $f] -side left -padx 5
    label $f.blite -image bp40 -background [lindex $list 1]
    label $f.bdark -image bp40 -background [lindex $list 2]
    label $f.wlite -image wp40 -background [lindex $list 1]
    label $f.wdark -image wp40 -background [lindex $list 2]
    button $f.select -text [expr $count + 1] -pady 2 \
      -command "chooseBoardColors $count"
    foreach i {blite bdark wlite wdark} {
      bind $f.$i <1> "chooseBoardColors $count"
    }
    grid $f.blite -row 0 -column 0
    grid $f.bdark -row 0 -column 1
    grid $f.wlite -row 1 -column 1
    grid $f.wdark -row 1 -column 0
    grid $f.select -row 2 -column 0 -columnspan 2 -sticky we
    incr count
  }

  button $w.buttons.ok -text "OK" -command "
    foreach i {lite dark highcolor bestcolor} {
      set \$i \$newColors(\$i)
    }
    ::board::recolor .board
    recolorPieces
    grab release $w
    destroy $w
  "
  button $w.buttons.cancel -text $::tr(Cancel) \
    -command "catch {grab release $w}; destroy $w"
  bind $w <Escape> "catch {grab release $w}; destroy $w"
  pack $w.buttons.cancel $w.buttons.ok -side right -padx 2 -pady 2
  chooseBoardColors
  wm resizable $w 0 0
  catch {grab $w}
}

# recolorPieces:
#   Used to recolor the pieces after a color is changed by the user.
#
proc recolorPieces {} {

  # This now does nothing since pieces are transparent photo images
  # and only square colors can be altered.
  return

  # global whitecolor blackcolor whiteborder blackborder boardSizes
  # foreach i $boardSizes {
  #   foreach p { k q r b n p } {
  #     if {[w$p$i cget -maskdata] != ""} {
  #       w${p}$i configure -foreground $whiteborder -background $whitecolor
  #     } else {
  #       w${p}$i configure -foreground $whitecolor
  #     }
  #     if {[b$p$i cget -maskdata] != ""} {
  #       b${p}$i configure -foreground $blackborder -background $blackcolor
  #     } else {
  #       b${p}$i configure -foreground $blackcolor
  #     }
  #   }
  # }
}

# setupBoard:
#   The main procedure for creating the dialog for setting the start board.
#   Calls switchPastePiece and makeSetupFen.
#   On "Setup" button press, calls sc_pos startBoard to try to set the
#   starting board.
#
proc setupBoard {} {
  global boardSize lite dark images setupBd pastePiece toMove epFile moveNum
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
    set rank [expr 7 - int ($i / 8)]
    set fyle [expr $i % 8 ]
    grid $sbd.$i -row $rank -column $fyle -sticky nesw
    if [expr ($fyle % 2) == ($rank % 2)] {
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

  ### Entry boxes: Move number, Castling and En Passent file.

  frame $sr.movenum
  label $sr.movenum.label -textvar ::tr(MoveNumber:)
  entry $sr.movenum.e -width 3 -background white -textvariable moveNum
  pack $sr.movenum.label $sr.movenum.e -side left

  frame $sr.castle
  label $sr.castle.label -textvar ::tr(Castling:)
  entry $sr.castle.e -width 5 -background white -textvariable castling
  pack $sr.castle.label $sr.castle.e -side left

  frame $sr.ep
  label $sr.ep.label -textvar ::tr(EnPassentFile:)
  entry $sr.ep.e -width 2 -background white -textvariable epFile
  set epFile {}
  pack $sr.ep.label $sr.ep.e -side left

  ### Set bindings so the active entrybox is colored and the Fen string
  ###   is updated at any change:

  foreach i "$sr.ep.e $sr.castle.e $sr.movenum.e" {
    bind $i <FocusIn> {%W configure -background lightYellow }
    bind $i <FocusOut> {
      %W configure -background white;
      set setupFen [makeSetupFen]}
  }

  ### Buttons: Setup and Cancel.

  frame $sr.b2
  button $sr.b2.setup -text "OK" -command {
    if {[catch {sc_game startBoard $setupFen} err]} {
      tk_messageBox -icon info -type ok -title "Scid" -message $err
    } else {
      destroy .setup
      updateBoardAndPgn
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
  entry .setup.status -relief sunken -textvariable setupFen \
    -font font_Small -background white
  pack .setup.paste .setup.clear -in .setup.statusbar -side left
  pack .setup.status -in .setup.statusbar -side right -expand yes -fill x -anchor w
  bind .setup.status <FocusIn>  { %W configure -background lightYellow }
  bind .setup.status <FocusOut> { %W configure -background white }

  set setupFen [makeSetupFen]
}


############################################################
### Toolbar and game movement buttons:

image create photo tb_open -data {
R0lGODdhEQARAMIAANnZ2QAAAKmpqf///76+vgAAAAAAAAAAACwAAAAAEQARAAADSQi63B0w
RuFAGDjfQF/WGOd9g9RZEPlFSkC4RCwTpYVKuMtxqgoJu8FsSAAaL8ThjoJMxoCipvMlsgwE
2KzW2Mp5T9twtkJWJAAAOw==
}

image create photo tb_new -data {
R0lGODdhEQARAKEAANnZ2ampqf///wAAACwAAAAAEQARAAACQoRvkaLowECI8Rk2RFaj+y+E
WhBkopiZp7qG5kCyqKcJhnzWpI23ytRDNSRB1xBQHCGSsGUu1zwwj5+q53ggabfHAgA7
}

image create photo tb_save -data {
R0lGODdhEQARAKEAANnZ2QAAAJmZAP///ywAAAAAEQARAAACPISPecHtvkQYtNIAsAnS2hZN
3iWFI6ll3cml7Tm0kfQwQrnd+q67d93AqWgQlY8IMs5quVQG+FBIp1RFAQA7
}

image create photo tb_close -data {
R0lGODdhEQARAIAAANnZ2YsAACwAAAAAEQARAAACJISPqcsXoeB6iTILnpxSN6NhTfiBXhlu
lyVWWIu08KiW9o0bBQA7
}

image create photo tb_finder -data {
R0lGODdhEQARAMIAANnZ2QAAAKmpqf///76+vrDE3gAAAAAAACwAAAAAEQARAAADUgi63B0w
RuFAGDjfQF/WGOd9g9RZEPlFSkC4RCwTpcBJ0jvZghoWwMLNNpi9Cpggh2gMIINCAeUyc0Kj
06LM+sS2BlIpF9vB3SYQRni9ZlUqkAQAOw==
}

image create photo tb_bkm -data {
R0lGODdhEQARAMIAANnZ2YsAAAAAAP///6mpqbDE3gAAAAAAACwAAAAAEQARAAADTgi60ftQ
iBakFXEMqrsgy0VdwxcWKIUWQgkqwqqirQkXVM66Z67WL0AMp9vZhLLGCniSrYzB4XPJu02p
R+SV9QnCLheCVyEum8WQtBqQAAA7
}

image create photo tb_cut -data {
R0lGODdhEQARAKEAANnZ2QAAAKmpqb+/vywAAAAAEQARAAACNYSPqZEhehyS0DD7Kt7aAtp9
AhiSXYBm2piZU2qhkMNiwzUNdyvsjU5x+Bq0iAsgUBmSoVABADs=
}

image create photo tb_copy -data {
R0lGODdhEQARAKEAANnZ2QAAAP///6mpqSwAAAAAEQARAAACPYSPecHtCoKYdIahpNsvVllR
gaE1AndioBWK6mmilye21sucsJPSrD2TrW6GgXEw/GASHMdScYwaIdSqtQAAOw==
}

image create photo tb_paste -data {
R0lGODdhEQARAMIAANnZ2VFR+wAAAKmpqf///76+vgAAAAAAACwAAAAAEQARAAADUggKIb4w
MickpCE3N6IgBUUNg9AtXzGoLGlexFqKtJKuH6HvRAV8sg9N2LmFeLwXUCWk9YogHHKnjDF7
ziqpNNW9fiIs8gvY5qZk1HBkKW/fnQQAOw==
}

image create photo tb_gprev -data {
R0lGODlhEQARAMIAANnZ2RwyggAAAP///6mpqampqampqampqSwAAAAAEQARAAADQgi63P4w
wrCEvViFrcT44CcAWwl4mDUIRMl5Ichq1ZquBN3Fck7WKZSPsuPhdCdbbPYr8pjEU/DicxCu
WKxkywUkAAA7
}

image create photo tb_gnext -data {
R0lGODlhEQARAMIAANnZ2RwyggAAAP///6mpqampqampqampqSwAAAAAEQARAAADQQi63P4w
wrCEvXhRJYb/nqBVA2aVhLIBHfgJKbB2Jh3P7nuTNRr8P1YuRAAGaS2dLCgcwlSV2iXmIFiv
V4l2C0gAADs=
}

image create photo tb_rfilter -data {
R0lGODdhEQARAMIAANnZ2YsAAAAAALDE3v///76+vgAAAAAAACwAAAAAEQARAAADPggQob7v
sTijqwvbypqVnfdd3QhqY+gJrEBxgTDMg6uUt0wQtI3qtJpJFhSOiAOe8RgUFEyKlpMFjbSq
D1YCADs=
}

image create photo tb_bsearch -data {
R0lGODdhEQARAMIAANDAoKCAUAAAANnZ2bDE3v///76+vgAAACwAAAAAEQARAAADSQgarMBB
jDkctEzSu5rSE/d4ADiIookFq9qxrzvCpWBTJ5kRPAGiAkKh0NMAhT3fxMZkJnkm3CDIIyql
OCrUgJU2DbdulykeCxIAOw==
}

image create photo tb_hsearch -data {
R0lGODdhEQARAMIAANnZ2QAngQAAALDE3v///76+vgAAAAAAACwAAAAAEQARAAADPgi63L7h
SRAnrRcHDFWNH7R5JEeR5xl64CW8wjgJQz0IFk0QNi7pttssWPM9aDWecNgrWAAwQeH1ZMCq
i1cCADs=
}

image create photo tb_msearch -data {
R0lGODdhEQARAMIAANnZ2QAngQAAAP///7DE3rLA3L6+vgAAACwAAAAAEQARAAADSQi63A4h
PCfCGHKqem9+Atd9lOhpoUiCKpAKTWh1AmET8GYO9XXnOx5hQCjYgDPa7bdJXmo2Iq4ZqQag
R4PuxQ0ZQppSLrwIJQAAOw==
}

image create photo tb_switcher -data {
R0lGODdhFAAUAMIAANnZ2QAngf///wAAAP/tuMvFxosAAAAAACwAAAAAFAAUAAADWQi63B0w
ykmrvZiKzbvn0DaMZPmFwkCsLDGkHqqWs9jJLVsWYCC6pdaAt8HlhEQBjjZaDXu/I6uQlDFH
BYOh6ttQv2CtAdoRm8/KLufMHqM+ZS0Zvh73MpYEADs=
}

image create photo tb_pgn -data {
R0lGODdhFAAUAKEAANnZ2QAngf///wAAACwAAAAAFAAUAAACSISPmcHtD6OcFIqLs8Zse90N
IiYOl3kKYYoK5uiqQRy3J2qutfbGel/a5WZBmtBHzLR6rqHRyBzpSMGl7IO9Zj2d7abrzVQo
BQA7
}

image create photo tb_glist -data {
R0lGODdhFAAUAMIAANnZ2QAngf///wAAAIsAAAAAAAAAAAAAACwAAAAAFAAUAAADQgi63B0w
ykmrvZiKzbvnkDAMX7mFo6AJRNuqgSnDIjl3KCl17hvenxwQFEutegTaEFe0DYUTDlK5PAUc
2Mc1y81gEgA7
}

image create photo tb_tmt -data {
R0lGODdhFAAUAMIAANnZ2QAngf///wAAAIsAALDE3gAAAAAAACwAAAAAFAAUAAADXgi63B0w
ykmrvZiKzbvnkDCMokCY6HkKoTd8Xji+J52ibACXu0yqpdlr09oNCsjC0GerFTbJV/FzFCSV
OdEPdbxip66k9aub3UTXAUAA0O02QsCo/YbN3HXXIDNZDBIAOw==
}

image create photo tb_maint -data {
R0lGODdhFAAUAMIAANnZ2QAngf///wAAAMvm/wAAAAAAAAAAACwAAAAAFAAUAAADUAi63B0w
ykmrvZiKzbvn0Cd6oTCc3Tl85aCs5gKDwea+t9y1TjPzPd0G6Lj9ajHcK3a0LQcEwsrVNKFM
UdhVUPJApbaqN8sRp8gs5BiczlgSADs=
}

image create photo tb_eco -data {
R0lGODdhFAAUAMIAANnZ2QAngf///wAAADZki4sAAAAAAAAAACwAAAAAFAAUAAADVgi63B0w
ykmrvZiKzbvn0DaM4lB6oWCK3Lpu6Wi+bhe3uGoHpeujvI9QQCAIQqaiUKlEEo0fphFZKBau
2CpBe+QloR5pVyfmiJ3i9NQra7tl46E8g0kAADs=
}

image create photo tb_tree -data {
R0lGODdhFAAUAKEAANnZ2QAngf///6CAUCwAAAAAFAAUAAACRISPmcHtD6OcFIqLs8Zsi4GB
WheK5kZm4BpywSXC7EC7pXlm6U3HtlwKXnafnnH08tQ8RCEquVk+lT0mlCf9ebaCCqUAADs=
}

image create photo tb_engine -data {
R0lGODdhFAAUAMIAANnZ2QAngf///7i4uAAAAAAAAAAAAAAAACwAAAAAFAAUAAADUwi63B0w
ykmrvZiKzcXooAB1Q/mdnveNnLmZpSoGHGGHISvcOKjbwKCQ8BsaibSdDTYIwljHIzQ6hMKW
JuxA1yRcvVlkDVhydsXjDm9j0/VwGUwCADs=
}

image create photo tb_crosst -data {
R0lGODdhFAAUAMIAANnZ2QAngf///wAAAIsAAAAAAAAAAAAAACwAAAAAFAAUAAADSQi63B0w
ykmrvZiKzbvnkDCMo1h+QoiuW1iS5qqyaDilApHvehrILJtk99MZW79g7Xc7Fnc+WssjjPCI
0Jk0GW1edUmtFJS5JAAAOw==
}

image create photo tb_help -data {
R0lGODdhEQARAIQAANnZ2QAAAKa/ovD07+vx6uHp4MvayfP289Lf0MPUwazDqLzPuCsrK+bt
5CEuH2WLXoythpa0kbjMtY2tiAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
ACwAAAAAEQARAAAFSSAgjkFZjigaCANRGEGqGsdQ3EgsB8mgmIuCgiEDBBoO0k2XgqmEzKIo
cHtEi9QC5Lq7baWkiJbbjZB3JrB6bTx3JW6VZBJXnUMAOw==
}

image create photo b_bargraph -data {
R0lGODdhGAAYAMIAANnZ2QAngf///wAAAIsAAAAAAAAAAAAAACwAAAAAGAAYAAADYwi63P4w
ygmDvThnpnvnXmhxQmmeqBmQaXuuS+DOAqzIwkCjNoDrlhfuxQIOa8dS70ewEJ7NAJSgLCKF
12qsZLwGg9ob1yv7DpdjM1llVavDPu5gTq/T4ckdXp9aikIUgYITCQA7
}

image create photo b_list -data {
R0lGODdhGAAYAKEAANnZ2QAngf///wAAACwAAAAAGAAYAAACT4SPqcvtz4KctFZkc8a6SyyE
4kiKATgM5RqeRyCkgjfNIIu7BizjpA7gqWgS28vHAgqRI2VsSDTumCVnj2qF0qRB6g8DUSjD
CSVxQ06rEQUAOw==
}

frame .tb -relief raised -border 1
button .tb.new -image tb_new -command fileNew
button .tb.open -image tb_open -command fileOpen
button .tb.save -image tb_save -command {
  if {[sc_game number] != 0} {
    busyCursor .
    gameReplace
    catch {.save.buttons.save invoke}
    unbusyCursor .
  } else {
    gameAdd
  }
}
button .tb.close -image tb_close -command fileClose
button .tb.finder -image tb_finder -command fileFinder
menubutton .tb.bkm -image tb_bkm -menu .tb.bkm.menu
menu .tb.bkm.menu
bind . <Control-b> ::bookmarks::postMenu
bind .tb.bkm <ButtonPress-1> "+.tb.bkm configure -relief flat"


frame .tb.space1 -width 12
button .tb.cut -image tb_cut -command gameClear
button .tb.copy -image tb_copy \
  -command {catch {sc_clipbase copy}; updateBoard}
button .tb.paste -image tb_paste \
  -command {catch {sc_clipbase paste}; updateBoardAndPgn}
frame .tb.space2 -width 12
button .tb.gprev -image tb_gprev -command {gameLoadNextPrev previous}
button .tb.gnext -image tb_gnext -command {gameLoadNextPrev next}
frame .tb.space3 -width 12
button .tb.rfilter -image tb_rfilter -command searchReset
button .tb.bsearch -image tb_bsearch -command searchBoard
button .tb.hsearch -image tb_hsearch -command searchHeader
button .tb.msearch -image tb_msearch -command searchMaterial
frame .tb.space4 -width 12
button .tb.switcher -image tb_switcher -command makeBaseWin
button .tb.glist -image tb_glist -command makeGList
button .tb.pgn -image tb_pgn -command makePgnWin
button .tb.tmt -image tb_tmt -command ::tourney::toggle
button .tb.maint -image tb_maint -command makeMaintWin
button .tb.eco -image tb_eco -command openCloseEcoBrowser
button .tb.tree -image tb_tree -command ::tree::make
button .tb.crosst -image tb_crosst -command toggleCrosstabWin
button .tb.engine -image tb_engine -command makeAnalysisWin
button .tb.help -image tb_help -command {helpWindow Index}

foreach i {new open save close finder bkm cut copy paste gprev gnext \
             rfilter bsearch hsearch msearch \
             switcher glist pgn tmt maint eco tree crosst engine help} {
  .tb.$i configure -relief flat -border 1 -highlightthickness 0 -anchor n \
    -takefocus 0
  bind .tb.$i <Any-Enter> "+.tb.$i configure -relief raised"
  bind .tb.$i <Any-Leave> "+.tb.$i configure -relief flat"
}

#pack .tb -side top -fill x -before .button

proc configToolbar {} {
  set w .tbconfig
  toplevel $w
  wm title $w "Scid: [tr OptionsToolbar]"

  array set ::toolbar_temp [array get ::toolbar]
  pack [frame $w.f1] -side top -fill x
  foreach i {new open save close finder bkm} {
    checkbutton $w.f1.$i -indicatoron 1 -image tb_$i -height 20 -width 22 \
      -variable toolbar_temp($i) -relief solid -borderwidth 1 
    pack $w.f1.$i -side left -ipadx 2 -ipady 2
  }
  pack [frame $w.f2] -side top -fill x
  foreach i {gprev gnext} {
    checkbutton $w.f2.$i -indicatoron 1 -image tb_$i -height 20 -width 22 \
      -variable toolbar_temp($i) -relief solid -borderwidth 1
    pack $w.f2.$i -side left -ipadx 1 -ipady 1
  }
  pack [frame $w.f3] -side top -fill x
  foreach i {cut copy paste} {
    checkbutton $w.f3.$i -indicatoron 1 -image tb_$i -height 20 -width 22 \
      -variable toolbar_temp($i) -relief solid -borderwidth 1
    pack $w.f3.$i -side left -ipadx 1 -ipady 1
  }
  pack [frame $w.f4] -side top -fill x
  foreach i {rfilter bsearch hsearch msearch} {
    checkbutton $w.f4.$i -indicatoron 1 -image tb_$i -height 20 -width 22 \
      -variable toolbar_temp($i) -relief solid -borderwidth 1
    pack $w.f4.$i -side left -ipadx 1 -ipady 1
  }
  pack [frame $w.f5] -side top -fill x
  foreach i {switcher glist pgn tmt maint eco tree crosst engine} {
    checkbutton $w.f5.$i -indicatoron 1 -image tb_$i -height 20 -width 22 \
      -variable toolbar_temp($i) -relief solid -borderwidth 1
    pack $w.f5.$i -side left -ipadx 1 -ipady 1
  }

  addHorizontalRule $w
  pack [frame $w.b] -side bottom -fill x
  button $w.on -text "+ [capital $::tr(all)]" -command {
    foreach i [array names toolbar_temp] { set toolbar_temp($i) 1 }
  }
  button $w.off -text "- [capital $::tr(all)]" -command {
    foreach i [array names toolbar_temp] { set toolbar_temp($i) 0 }
  }
  button $w.ok -text "OK" -command {
    array set toolbar [array get toolbar_temp]
    catch {grab release .tbconfig}
    destroy .tbconfig
    redrawToolbar
  }
  button $w.cancel -text $::tr(Cancel) \
    -command "catch {grab release $w}; destroy $w"
  pack $w.cancel $w.ok -side right -padx 2
  pack $w.on $w.off -side left -padx 2
  catch {grab $w}
}

proc redrawToolbar {} {
  global toolbar
  foreach i [winfo children .tb] { pack forget $i }
  set seenAny 0
  set seen 0
  foreach i {new open save close finder bkm} {
    if {$toolbar($i)} {
      set seen 1; set seenAny 1
      pack .tb.$i -side left -pady 1 -padx 0 -ipadx 0 -pady 0 -ipady 0
    }
  }
  if {$seen} { pack .tb.space1 -side left }
  set seen 0
  foreach i {gprev gnext} {
    if {$toolbar($i)} {
      set seen 1; set seenAny 1
      pack .tb.$i -side left -pady 1 -padx 0 -ipadx 0 -pady 0 -ipady 0
    }
  }
  if {$seen} { pack .tb.space2 -side left }
  set seen 0
  foreach i {cut copy paste} {
    if {$toolbar($i)} {
      set seen 1; set seenAny 1
      pack .tb.$i -side left -pady 1 -padx 0 -ipadx 0 -pady 0 -ipady 0
    }
  }
  if {$seen} { pack .tb.space3 -side left }
  set seen 0
  foreach i {rfilter bsearch hsearch msearch} {
    if {$toolbar($i)} {
      set seen 1; set seenAny 1
      pack .tb.$i -side left -pady 1 -padx 0 -ipadx 0 -pady 0 -ipady 0
    }
  }
  if {$seen} { pack .tb.space4 -side left }
  set seen 0
  foreach i {switcher glist pgn tmt maint eco tree crosst engine} {
    if {$toolbar($i)} {
      set seen 1; set seenAny 1
      pack .tb.$i -side left -pady 1 -padx 0 -ipadx 0 -pady 0 -ipady 0
    }
  }
  if {$seenAny} {
    pack .tb -side top -fill x -before .button
  } else {
    pack forget .tb
  }
}

proc setToolbar {x} {
  if {$x} {
    pack .tb -side top -fill x -before .button
  } else {
    pack forget .tb
  }
}

# Set toolbar help status messages:
foreach {b m} {
  new FileNew open FileOpen finder FileFinder
  save GameReplace close FileClose bkm FileBookmarks
  gprev GamePrev gnext GameNext
  cut GameNew copy EditCopy paste EditPaste
  rfilter SearchReset bsearch SearchCurrent
  hsearch SearchHeader msearch SearchMaterial
  switcher WindowsSwitcher glist WindowsGList pgn WindowsPGN tmt WindowsTmt
  maint WindowsMaint eco WindowsECO tree WindowsTree crosst ToolsCross
  engine ToolsAnalysis
} {
  set helpMessage(.tb.$b) $m
}
set helpMessage(.button.addVar) EditAdd
set helpMessage(.button.trial) EditTrial


image create photo tb_start -data {
R0lGODdhFAAUAPAAANnZ2VFR+ywAAAAAFAAUAAACPoSPqQGsf5iDT1JoU5hm96Z5kZh123Q6
ZaqmX+uyKijXs2Szrxnr9HjikUBAVPCHOPJ2oSbyoiFCk9KpFVIAADs=
}

image create photo tb_prev -data {
R0lGODdhFAAUAPAAANnZ2VFR+ywAAAAAFAAUAAACI4SPqcvtD6MJVAKKI95v++aFS0iO5Mec
maNqooRaq0XXNl0AADs=
}


image create photo tb_next -data {
R0lGODdhFAAUAIAAANnZ2VFR+ywAAAAAFAAUAAACI4SPqcvtD1WYEc1bwd1x++eFTUgupCid
FKOCqItVcUbX9q0UADs=
}

image create photo tb_end -data {
R0lGODdhFAAUAIAAANnZ2VFR+ywAAAAAFAAUAAACPoSPqcsBztqLEgZ4rnJWZ59Nz4WR2NSR
hlmKLMeu7kujK/3ao7mretxrpUo+WQpRNN4SoNCJ4oRuRNJodVEAADs=
}

image create photo tb_invar -data {
R0lGODdhFAAUAKEAANnZ2QAngVFR+wAAACwAAAAAFAAUAAACO4SPqcvtf0JQ0ghBZ6rgYsSB
mvdFmhGSJRCyp1q2KWyiZ0fb+pHvrZpp4S4LidDDMN5wDiHE9YxKp4sCADs=
}

image create photo tb_outvar -data {
R0lGODdhFAAUAKEAANnZ2QAngVFR+wAAACwAAAAAFAAUAAACO4SPqcvtf0JQcgkBatLoYh5N
nWeAIOBdpbiOaRseKQmDs1qzxh1n+v4KnWS01ZCIEf4SuB4EcXxKp9QCADs=
}

image create photo tb_addvar -data {
R0lGODdhFAAUAKEAANnZ2QAngc4PNAAAACwAAAAAFAAUAAACNoSPqcvtf0JQ0tV0jxBxYq9x
HZKFJAhk27qmqMq2rlGaJ43a46xslJR7AIMWIORzRCaXzKahAAA7
}

frame .button -relief raised -border 1
button .button.start -image tb_start -command "sc_move start; updateBoard"
button .button.back -image tb_prev -command "sc_move back; updateBoard"
button .button.forward -image tb_next -command "sc_move forward; updateBoard"
button .button.end -image tb_end -command "sc_move end; updateBoard"
frame .button.space -width 15

# The go-into-variation button is a menubutton:
menubutton .button.intoVar -image tb_invar -menu .button.intoVar.menu \
  -relief raised
menu .button.intoVar.menu -tearoff 0 -font font_Regular

button .button.exitVar -image tb_outvar \
  -command {sc_var exit; updateBoard}
button .button.addVar -image tb_addvar \
  -command {sc_var create; updateBoardAndPgn}
frame .button.space2 -width 15

image create photo tb_flip -data {
R0lGODdhFAAUAKEAAAAAANDAoKCAUIsAACwAAAAAFAAUAAACXoSPqcHiHJyA0tDXcHS2jT9s
UyYYEgheY2AKXxaSUPuK6gww3/S66MDJBVK9H7AkHKIiywpAotxFa6ynD8ULpaoOY5YZ69hk
yuBNh9khz1M1EirD4uDjemtFpyv2/AIAOw==
}

image create photo tb_coords -data {
R0lGODdhFAAUAKEAANnZ2QAAANDAoKCAUCwAAAAAFAAUAAACR4QRFsItA+FJyrUoUdjIMjwc
4uKB4gRC1oSmq9aCLxJjM4Wkw11H70YJ6GYjoPF4SiqXTEVTwWE9nZPoEjh6BrPaBA47VRYA
ADs=
}

image create photo tb_trial -data {
R0lGODdhFAAUAKEAANnZ2YsAAAAAAKCAUCwAAAAAFAAUAAACPISPqRAdC52DqhlL48t1AwEK
GWaEIkWWJ+p9IZeYMnik5oDnQ93OMmWCxVZCF61oJFJwCuZSB81Ao0hIAQA7
}

image create photo tb_trial_on -data {
R0lGODdhFAAUAKEAAP//4IsAAAAAAKCAUCwAAAAAFAAUAAACPISPqRAdC52DqhlL48t1AwEK
GWaEIkWWJ+p9IZeYMnik5oDnQ93OMmWCxVZCF61oJFJwCuZSB81Ao0hIAQA7
}

##############################

namespace eval ::board {}

# ::board::new
#   Creates a new board in the specified frame.
#   The psize option should be a piece bitmap size supported
#   in Scid (see the boardSizes variable in start.tcl).
#
proc ::board::new {w {psize 40}} {
  if {[winfo exists $w]} { return }

  set ::board::_size($w) $psize
  set ::board::_coords($w) 1
  set ::board::_flip($w) 0
  set ::board::_data($w) [sc_pos board]
  set ::board::_marks($w) 0
  set ::board::_drag($w) -1
  set bsize [expr {8 * ($psize+2) - 1}]
  frame $w
  canvas $w.bd -width $bsize -height $bsize -cursor crosshair
  grid $w.bd -row 1 -column 1 -rowspan 8 -columnspan 8
  set bd $w.bd

  # Create empty board:
  for {set i 0} {$i < 64} {incr i} {
    set xi [expr $i % 8]
    set yi [expr int($i/8)]
    set x1 [expr $xi * ($psize+2)]
    set y1 [expr (7 - $yi) * ($psize+2)]
    set x2 [expr $x1 + $psize+1]
    set y2 [expr $y1 + $psize+1]
    $bd create rectangle $x1 $y1 $x2 $y2 -tag sq$i
    ::board::colorSquare $w $i
  }

  # Set up coordinate labels:
  for {set i 1} {$i <= 8} {incr i} {
    label $w.lrank$i -text [expr 9 - $i]
    grid $w.lrank$i -row $i -column 0 -sticky e
    label $w.rrank$i -text [expr 9 - $i]
    grid $w.rrank$i -row $i -column 9 -sticky w
  }
  foreach i {1 2 3 4 5 6 7 8} file {a b c d e f g h} {
    label $w.tfile$file -text $file
    grid $w.tfile$file -row 0 -column $i -sticky s
    label $w.bfile$file -text $file
    grid $w.bfile$file -row 9 -column $i -sticky n
  }
  ::board::coords $w
  ::board::update $w
}

# ::board::defaultColor
#   Returns the color (the value of the global
#   variable "lite" or "dark") depending on whether the
#   specified square number (0=a1, 1=b1, ..., 63=h8) is
#   a light or dark square.
#
proc ::board::defaultColor {sq} {
  set x [expr $sq % 8]
  set y [expr int($sq/8)]
  if {($x%2) == ($y%2)} { return $::dark }
  return $::lite
}

# ::board::size
#   Returns the current board size.
#
proc ::board::size {w} {
  return $::board::_size($w)
}

# ::board::resize
#   Resizes the board. Takes a numeric piece size (which should
#   be in the global boardSizes list variable), or "-1" or "+1".
#   Returns the new size of the board.
#
proc ::board::resize {w psize} {
  global boardSizes
  set oldsize $::board::_size($w)
  if {$psize == $oldsize} { return $oldsize }
  if {$psize == "-1"} {
    set index [lsearch -exact $boardSizes $oldsize]
    if {$index == 0} { return $oldsize }
    incr index -1
    set psize [lindex $boardSizes $index]
  } elseif {$psize == "+1"} {
    set index [lsearch -exact $boardSizes $oldsize]
    incr index
    if {$index == [llength $boardSizes]} { return $oldsize }
    set psize [lindex $boardSizes $index]
  }

  # Verify that we have a valid size:
  if {[lsearch -exact $boardSizes $psize] < 0} { return $oldsize }

  set bsize [expr ($psize+2) * 8 - 1]
  $w.bd configure -width $bsize -height $bsize
  set ::board::_size($w) $psize

  # Resize each square:
  for {set i 0} {$i < 64} {incr i} {
    set c [$w.bd coords sq$i]
    set x1 [expr int([lindex $c 0] * ($psize+2) / ($oldsize+2))]
    set y1 [expr int([lindex $c 1] * ($psize+2) / ($oldsize+2))]
    set x2 [expr $x1 + $psize +1]
    set y2 [expr $y1 + $psize +1]
    $w.bd coords sq$i $x1 $y1 $x2 $y2
  }
  ::board::update $w
  return $psize
}

# ::board::getSquare
#   Given a board frame and root-window X and Y screen coordinates,
#   returns the square number (0-63) containing that screen location,
#   or -1 if the location is outside the board.
#
proc ::board::getSquare {w x y} {
  if {[winfo containing $x $y] != "$w.bd"} {
    return -1
  }
  set x [expr $x - [winfo rootx $w.bd]]
  set y [expr $y - [winfo rooty $w.bd]]
  set psize $::board::_size($w)
  set x [expr int($x / ($psize+2))]
  set y [expr int($y / ($psize+2))]
  if {$x < 0  ||  $y < 0  ||  $x > 7  ||  $y > 7} {
    set sq -1
  } else {
    set sq [expr (7-$y)*8 + $x]
    if {$::board::_flip($w)} { set sq [expr 63 - $sq] }
  }
  return $sq
}

# ::board::showMarks
#   Turns on/off the showing of marks (colored squares).
#
proc ::board::showMarks {w value} {
  set ::board::_marks($w) $value
}

# ::board::recolor
#   Recolor every square on the board.
#
proc ::board::recolor {w} {
  for {set i 0} {$i < 64} {incr i} {
    ::board::colorSquare $w $i
  }
}

# ::board::colorSquare
#   Colors the specified square (0-63) of the board.
#   If the color is the empty string, the appropriate
#   color for the square (light or dark) is used.
#
proc ::board::colorSquare {w i {color ""}} {
  if {$color != ""} {
    $w.bd itemconfigure sq$i -outline $color -fill $color
    return
  }
  set color [::board::defaultColor $i]
  $w.bd itemconfigure sq$i -outline $color -fill $color
  if {$::board::_marks($w)  &&  [info exists ::markSquares($i)]} {
    set color $::markSquares($i)
    catch {$w.bd itemconfigure sq$i -outline $color -fill $color}
  }
}

# ::board::midSquare
#   Given a board and square number, returns the canvas X/Y
#   coordinates of the midpoint of that square.
#
proc ::board::midSquare {w sq} {
  set c [$w.bd coords sq$sq]
  set x [expr ([lindex $c 0] + [lindex $c 2]) / 2]
  set y [expr ([lindex $c 1] + [lindex $c 3]) / 2]
  return [list $x $y]
}

# ::board::piece {w sq}
#   Given a board and square number, returns the piece type
#   (e for empty, wp for White Pawn, etc) of the square.
proc ::board::piece {w sq} {
  set p [string index $::board::_data($w) $sq]
  return $::images($p)
}

# ::board::setDragSquare
#   Sets the square from whose piece should be dragged.
#   To drag nothing, the square value should be -1.
#   If the previous value is a valid square (0-63), the
#   piece being dragged is returned to its home square first.
#
proc ::board::setDragSquare {w sq} {
  set oldSq $::board::_drag($w)
  if {$oldSq >= 0  &&  $oldSq <= 63} {
    ::board::drawPiece $w $oldSq [string index $::board::_data($w) $oldSq]
    $w.bd raise arrows
  }
  set ::board::_drag($w) $sq
}

# ::board::dragPiece
#   Drags the piece of the drag-square (as set above) to
#   the specified global (root-window) screen cooordinates.
#
proc ::board::dragPiece {w x y} {
  set sq $::board::_drag($w)
  if {$sq < 0} { return }
  set x [expr $x - [winfo rootx $w.bd]]
  set y [expr $y - [winfo rooty $w.bd]]
  $w.bd coords p$sq $x $y
  $w.bd raise p$sq
}

# ::board::arrow
#   Draws an arrow on the board, from one square to another,
#   in the specified color.
#
proc ::board::arrow {w from to color} {
  if {$from < 0  ||  $from > 63} { return }
  if {$to < 0  ||  $to > 63} { return }
  set fromXY [::board::midSquare $w $from]
  set toXY [::board::midSquare $w $to]
  catch {$w.bd create line [lindex $fromXY 0] [lindex $fromXY 1] \
           [lindex $toXY 0] [lindex $toXY 1] -fill $color \
           -arrow last -width 2 -tag arrows}
  $w.bd raise arrows
}

# ::board::bind
#   Binds the given event on the given square number to
#   the specified action.
#
proc ::board::bind {w sq event action} {
  if {$sq == "all"} {
    for {set i 0} {$i < 64} {incr i} {
      $w.bd bind p$i $event $action
    }
  } else {
    $w.bd bind p$sq $event $action
  }
}

# ::board::drawPiece
#   Draws a piece on a specified square.
#
proc ::board::drawPiece {w sq piece} {
  global images
  set psize $::board::_size($w)
  set flip $::board::_flip($w)
  # Compute the XY coordinates for the centre of the square:
  set midpoint [::board::midSquare $w $sq]
  set xc [lindex $midpoint 0]
  set yc [lindex $midpoint 1]
  # Delete any old image for this square, and add the new one:
  $w.bd delete p$sq
  $w.bd create image $xc $yc -image $images($piece)$psize -tag p$sq
}

# ::board::update
#   Update the board given a 64-character board string as returned
#   by the "sc_pos board" command. If the board string is empty, it
#   defaults to the previous value for this board.
#
proc ::board::update {w {board ""}} {
  global images
  if {$board == ""} {
    set board $::board::_data($w)
  } else {
    set ::board::_data($w) $board
  }
  set psize $::board::_size($w)
  set flip $::board::_flip($w)

  # Remove all arrows from the board:
  $w.bd delete arrows

  for {set sq 0} { $sq < 64 } { incr sq } {
    set piece [string index $board $sq]
    # Compute the XY coordinates for the centre of the square:
    set midpoint [::board::midSquare $w $sq]
    set xc [lindex $midpoint 0]
    set yc [lindex $midpoint 1]
    # Delete any old image for this square, and add the new one:
    $w.bd delete p$sq
    $w.bd create image $xc $yc -image $images($piece)$psize -tag p$sq
  }
}

proc ::board::isFlipped {w} {
  return $::board::_flip($w)
}

proc ::board::flip {w} {
  if {! [info exists ::board::_flip($w)]} { return }
  set flip [expr 1 - $::board::_flip($w)]
  set ::board::_flip($w) $flip

  for {set i 0} {$i < 64} {incr i} {
    set swap [expr 63 - $i]
    set coords [$w.bd coords sq$swap]
    set x1($i) [lindex $coords 0]
    set y1($i) [lindex $coords 1]
    set x2($i) [lindex $coords 2]
    set y2($i) [lindex $coords 3]
  }
  for {set i 0} {$i < 64} {incr i} {
    $w.bd coords sq$i $x1($i) $y1($i) $x2($i) $y2($i)
  }

  # Change coordinate labels:
  for {set i 1} {$i <= 8} {incr i} {
    set value [expr 9 - [$w.lrank$i cget -text]]
    $w.lrank$i configure -text $value
    $w.rrank$i configure -text $value
  }
  if {$flip} {
    foreach file {a b c d e f g h} newvalue {h g f e d c b a} {
      $w.tfile$file configure -text $newvalue
      $w.bfile$file configure -text $newvalue
    }
  } else {
    foreach file {a b c d e f g h} {
      $w.tfile$file configure -text $file
      $w.bfile$file configure -text $file
    }
  }
  ::board::update $w
}

proc ::board::coords {w} {
  set coords [expr 1 - $::board::_coords($w)]
  set ::board::_coords($w) $coords
  if {$coords} {
    for {set i 1} {$i <= 8} {incr i} {
      grid configure $w.lrank$i
      grid configure $w.rrank$i
    }
    foreach i {a b c d e f g h} {
      grid configure $w.tfile$i
      grid configure $w.bfile$i
    }
  } else {
    for {set i 1} {$i <= 8} {incr i} {
      grid remove $w.lrank$i
      grid remove $w.rrank$i
    }
    foreach i {a b c d e f g h} {
      grid remove $w.tfile$i
      grid remove $w.bfile$i
    }
  }
}

proc toggleRotateBoard {} {
  ::board::flip .board
}

proc toggleCoords {} {
  global boardCoords
  set boardCoords [expr 1 - $boardCoords]
  ::board::coords .board
}

frame .button.space3 -width 15
button .button.flip -image tb_flip -takefocus 0 \
  -command "::board::flip .board"

button .button.coords -image tb_coords -takefocus 0 \
  -command toggleCoords
bind . <KeyPress-0> toggleCoords

image create photo autoplay_off -data {
R0lGODdhFAAUAKEAANnZ2QAAAFFR+wAAACwAAAAAFAAUAAACMYSPqbvBb4JLsto7D94StowI
IgOG4ugd55oC6+u98iPXSz0r+Enjcf7jtVyoofGoKAAAOw==
}

image create photo autoplay_on -data {
R0lGODdhFAAUAKEAAP//4AAAAPoTQAAAACwAAAAAFAAUAAACMYSPqbvBb4JLsto7D94StowI
IgOG4ugd55oC6+u98iPXSz0r+Enjcf7jtVyoofGoKAAAOw==
}

button .button.autoplay -image autoplay_off -command toggleAutoplay
button .button.trial -image tb_trial -command {setTrialMode toggle}

foreach i {start back forward end intoVar exitVar addVar autoplay \
             flip coords trial} {
  .button.$i configure -relief flat -border 1 -highlightthickness 0 \
    -anchor n -takefocus 0
  bind .button.$i <Any-Enter> "+.button.$i configure -relief raised"
  bind .button.$i <Any-Leave> "+.button.$i configure -relief flat"
}

pack .button.start .button.back .button.forward .button.end \
  .button.space .button.intoVar .button.exitVar .button.addVar .button.space2 \
  .button.autoplay .button.trial .button.space3 .button.flip .button.coords \
  -side left -pady 1 -padx 0 -ipadx 0 -pady 0 -ipady 0


############################################################
### The board:

::board::new .board $boardSize
#.board configure -relief solid -border 1
::board::showMarks .board 1
if {$boardCoords} {
  ::board::coords .board
}

# .gameInfo is the game information widget:
#
text .gameInfo -width 20 -height 6 -fg black -bg white \
  -wrap none -relief sunken -state disabled -cursor top_left_arrow \
  -xscroll ".ginfoXbar set" -yscroll ".ginfoYbar set" -setgrid 1
scrollbar .ginfoXbar -width 10 -orient horizontal -command ".gameInfo xview"
scrollbar .ginfoYbar -width 10 -orient vertical -command ".gameInfo yview"
::htext::init .gameInfo

# Right-mouse button menu for gameInfo frame:
menu .gameInfo.menu -tearoff 0

.gameInfo.menu add checkbutton -label GInfoHideNext \
  -variable gameInfo(hideNextMove) -offvalue 0 -onvalue 1 -command updateBoard

.gameInfo.menu add checkbutton -label GInfoMaterial \
  -variable gameInfo(showMaterial) -offvalue 0 -onvalue 1 -command updateBoard

.gameInfo.menu add checkbutton -label GInfoFEN \
  -variable gameInfo(showFEN) -offvalue 0 -onvalue 1 -command updateBoard

.gameInfo.menu add checkbutton -label GInfoMarks \
  -variable gameInfo(showMarks) -offvalue 0 -onvalue 1 -command updateBoard

.gameInfo.menu add checkbutton -label GInfoWrap \
  -variable gameInfo(wrap) -offvalue 0 -onvalue 1 -command updateBoard

.gameInfo.menu add checkbutton -label GInfoFullComment \
  -variable gameInfo(fullComment) -offvalue 0 -onvalue 1 -command updateBoard

#.gameInfo.menu add checkbutton -label Photos \
#  -variable gameInfo(photos) -offvalue 0 -onvalue 1 \
#  -command {updatePlayerPhotos -force}

.gameInfo.menu add separator

.gameInfo.menu add radiobutton -label GInfoTBNothing \
  -variable gameInfo(showTB) -value 0 -command updateBoard

.gameInfo.menu add radiobutton -label GInfoTBResult \
  -variable gameInfo(showTB) -value 1 -command updateBoard

.gameInfo.menu add radiobutton -label GInfoTBAll \
  -variable gameInfo(showTB) -value 2 -command updateBoard

.gameInfo.menu add separator

.gameInfo.menu add command -label GInfoDelete -command {
  catch {sc_game flag delete [sc_game number] invert}
  updateBoard
  updateGList
}

.gameInfo.menu add cascade -label GInfoMark -menu .gameInfo.menu.mark
menu .gameInfo.menu.mark
foreach flag $maintFlaglist {
  .gameInfo.menu.mark add command -label "" -command "
    catch {sc_game flag $flag \[sc_game number\] invert}
    updateBoard
    updateGList
  "
}

bind .gameInfo <ButtonPress-3> "tk_popup .gameInfo.menu %X %Y"
bind . <F9> "tk_popup .gameInfo.menu %X %Y"


# setBoard:
#   Resets the squares of the board according to the board string
#   "boardStr" and the piece bitmap size "psize".
#
proc setBoard {board boardStr psize {rotated 0}} {
  global images
  for {set i 0} { $i < 64 } { incr i } {
    if {$rotated > 0} {
      set piece [string index $boardStr [expr 63 - $i]]
    } else {
      set piece [ string index $boardStr $i ]
    }
    $board.$i configure -image $images($piece)$psize
  }
}

# updateVarMenus:
#   Updates the menus for moving into or deleting an existing variation.
#   Calls sc_var list and sc_var count to get the list of variations.
#
proc updateVarMenus {} {
  set varList [sc_var list]
  set numVars [sc_var count]
  .button.intoVar.menu delete 0 end
  .menu.edit.del delete 0 end
  .menu.edit.first delete 0 end
  .menu.edit.main delete 0 end
  for {set i 0} {$i < $numVars} {incr i} {
    set move [lindex $varList $i]
    set state normal
    if {$move == ""} {
      set move "($::tr(empty))"
      set state disabled
    }
    set str "[expr $i + 1]: $move"
    set commandStr "sc_var moveInto $i; updateBoard"
    if {$i < 9} {
      .button.intoVar.menu add command -label $str -command $commandStr \
        -underline 0
    } else {
      .button.intoVar.menu add command -label $str -command $commandStr
    }
    set commandStr "sc_var delete $i; updateBoardAndPgn"
    .menu.edit.del add command -label $str -command $commandStr
    set commandStr "sc_var first $i; updateBoardAndPgn"
    .menu.edit.first add command -label $str -command $commandStr
    set commandStr "sc_var promote $i; updateBoardAndPgn"
    .menu.edit.main add command -label $str -command $commandStr \
      -state $state
  }
}

bind . <KeyPress-v> {
  if {[sc_var count] == 1} {
    sc_var moveInto 0
    updateBoard
  } else {
    focus .
    update idletasks
    tkMbPost .button.intoVar
  }
}
bind . <KeyPress-z> {.button.exitVar invoke}

# updateBoardAndPgn:
#    Calls updateBoard() with the parameter pgnNeedsUpdate set to true
#    so the PGN representation is regenerated.
proc updateBoardAndPgn {{bd .board}} { updateBoard $bd 1 }

# updateBoard:
#    Updates the main board. Also updates the navigation buttons, disabling
#    those that have no effect at this point in the game.
#    Also ensure all menu settings are up to date.
#    If the optional parameter pgnNeedsUpdate is true, the PGN text
#    is also regenerated.
#
proc updateBoard { {bd .board} {pgnNeedsUpdate 0} } {
  global boardSize gameInfo
  ::board::resize .board $boardSize
  ::board::update .board [sc_pos board]
  set cmt [sc_pos getComment]
  set cmtOrig $cmt
  resetMarkSquares
  if {$gameInfo(showMarks)} {
    while {1} {
      set idx [string first "\[%mark " $cmt]
      if {$idx < 0} { break }
      set cmt [string range $cmt $idx end]
      set cmt [string trim [string range $cmt 7 end]]
      set sq [string range $cmt 0 1]
      set cmt [string trim [string range $cmt 2 end]]
      set end [string first "\]" $cmt]
      set color [string trim [string range $cmt 0 [expr $end - 1]]]
      if {$color == ""} { set color red }
      markSquare $sq $color
    }
    set cmt $cmtOrig
    while {1} {
      set idx [string first "\[%arrow " $cmt]
      if {$idx < 0} { break }
      set cmt [string range $cmt $idx end]
      set cmt [string trim [string range $cmt 7 end]]
      set fromSq [string range $cmt 0 1]
      set cmt [string trim [string range $cmt 2 end]]
      set toSq [string range $cmt 0 1]
      set cmt [string trim [string range $cmt 2 end]]
      set end [string first "\]" $cmt]
      set color [string trim [string range $cmt 0 [expr $end - 1]]]
      if {$color == ""} { set color red }
      arrowSquare $fromSq $toSq $color
    }
  }
  # Update the status of each navigation button:
  if {[sc_pos isAt start]} {
    .button.start configure -state disabled
  } else { .button.start configure -state normal }
  if {[sc_pos isAt end]} {
    .button.end configure -state disabled
  } else { .button.end configure -state normal }
  if {[sc_pos isAt vstart]} {
    .button.back configure -state disabled
  } else { .button.back configure -state normal }
  if {[sc_pos isAt vend]} {
    .button.forward configure -state disabled
  } else { .button.forward configure -state normal }
  # Cannot add a variation to an empty line:
  if {[sc_pos isAt vstart]  &&  [sc_pos isAt vend]} {
    .menu.edit entryconfig [tr EditAdd] -state disabled
    .button.addVar configure -state disabled
    bind . <Control-a> {}
  } else {
    .menu.edit entryconfig [tr EditAdd] -state normal
    .button.addVar configure -state normal
    bind . <Control-a> {sc_var create; updateBoardAndPgn}
  }
  if {[sc_var count] == 0} {
    .button.intoVar configure -state disabled
    .menu.edit entryconfig [tr EditDelete] -state disabled
    .menu.edit entryconfig [tr EditFirst] -state disabled
    .menu.edit entryconfig [tr EditMain] -state disabled
  } else {
    .button.intoVar configure -state normal
    .menu.edit entryconfig [tr EditDelete] -state normal
    .menu.edit entryconfig [tr EditFirst] -state normal
    .menu.edit entryconfig [tr EditMain] -state normal
  }
  updateVarMenus
  if {[sc_var level] == 0} {
    .button.exitVar configure -state disabled
  } else {
    .button.exitVar configure -state normal
  }

  if {![sc_base inUse]  ||  $::trialMode  ||  [sc_base isReadOnly]} {
    .tb.save configure -state disabled
  } else {
    .tb.save configure -state normal
  }
  .gameInfo configure -state normal
  .gameInfo delete 0.0 end
  ::htext::display .gameInfo [sc_game info -hide $gameInfo(hideNextMove) \
                                -material $gameInfo(showMaterial) \
                                -cfull $gameInfo(fullComment) \
                                -fen $gameInfo(showFEN) -tb $gameInfo(showTB)]
  if {$gameInfo(wrap)} {
    .gameInfo configure -wrap word
    .gameInfo tag configure wrap -lmargin2 10
    .gameInfo tag add wrap 1.0 end
  } else {
    .gameInfo configure -wrap none
  }
  .gameInfo configure -state disabled
  updatePlayerPhotos
  updateEpdWins
  if {[winfo exists .analysisWin1]} { updateAnalysis 1 }
  if {[winfo exists .analysisWin2]} { updateAnalysis 2 }
  if {[winfo exists .treeWin]} { ::tree::refresh }
  if {[winfo exists .commentWin]} { updateCommentWin }
  if {[::tb::isopen]} { ::tb::results }
  updateMenuStates
  moveEntry_Clear
  updateStatusBar
  if {[winfo exists .twinchecker]} { updateTwinChecker }
  if {[winfo exists .pgnWin]} { updatePgnWin $pgnNeedsUpdate }
  if {[winfo exists .noveltyWin]} { updateNoveltyWin }
}

image create photo photoW
image create photo photoB
label .photoW -background white -image photoW -anchor ne
label .photoB -background white -image photoB -anchor ne

array set photo {}
catch {source [file join $scidUserDir players.img]}
set photo(oldWhite) {}
set photo(oldBlack) {}

# updatePlayerPhotos
#   Updates the player photos in the game information area
#   for the two players of the current game.
#
proc updatePlayerPhotos {{force ""}} {
  global photo
  if {$force == "-force"} {
    # Force update even if it seems unnecessary. This is done
    # when the user selects to show or hide the photos.
    set photo(oldWhite) {}
    set photo(oldBlack) {}
    place forget .photoW
    place forget .photoB
  }
  if {! $::gameInfo(photos)} { return }
  set white [sc_game info white]
  set black [sc_game info black]
  if {$black != $photo(oldBlack)} {
    set photo(oldBlack) $black
    place forget .photoB
    if {[info exists ::photo($black)]} {
      image create photo photoB -data $::photo($black)
      .photoB configure -image photoB -anchor ne
      place .photoB -in .gameInfo -x -1 -relx 1.0 \
        -rely 0.12 -relheight 0.88 -anchor ne
    }
  }
  if {$white != $photo(oldWhite)} {
    set photo(oldWhite) $white
    place forget .photoW
    if {[info exists ::photo($white)]} {
      image create photo photoW -data $::photo($white)
      .photoW configure -image photoW -anchor ne
      place .photoW -in .gameInfo -x -82 -relx 1.0 \
        -rely 0.12 -relheight 0.88 -anchor ne
    }
  }
}

#########################################################
### Chess move input

# Globals for mouse-based move input:

set selectedSq -1
set currentSq -1
set bestSq -1

set EMPTY 0
set KING 1
set QUEEN 2
set ROOK 3
set BISHOP 4
set KNIGHT 5
set PAWN 6

# getPromoPiece:
#     Called whenever a pawn promotion move is made, to query the user
#     for the promotion piece. I'd prefer this to show the piece bitmaps
#     rather than english names, should change it sometime...
#
proc getPromoPiece {} {
  global EMPTY QUEEN ROOK BISHOP KNIGHT
  if {[catch {tk_dialog .dialog "Select Promotion Piece" \
                "Select the promotion piece:" \
                "" 0 "Queen" "Rook" "Bishop" "Knight"} answer]} {
    return 2
  }
  return [expr $answer + 2]
}

# confirmReplaceMove:
#   Asks the user what to do when adding a move when a move already
#   exists.
#   Returns a string value:
#      "replace" to replace the move, truncating the game.
#      "var" to add the move as a new variation.
#      "cancel" to do nothing.
#
proc confirmReplaceMove {} {
  global askToReplaceMoves trialMode
  if {! $askToReplaceMoves} { return "replace" }
  if {$trialMode} { return "replace" }

  option add *Dialog.msg.wrapLength 4i interactive
  catch {tk_dialog .dialog "Scid: $::tr(ReplaceMove)?" \
           $::tr(ReplaceMoveMessage) "" 0 \
           $::tr(ReplaceMove) $::tr(AddNewVar) [tr EditTrial] \
           $::tr(Cancel)} answer
  option add *Dialog.msg.wrapLength 3i interactive
  if {$answer == 0} { return "replace" }
  if {$answer == 1} { return "var" }
  if {$answer == 2} { setTrialMode 1; return "replace" }
  return "cancel"
}

# addMove:
#   Adds the move indicated by sq1 and sq2 if it is legal. If the move
#   is a promotion, getPromoPiece will be called to get the promotion
#   piece from the user.
#
proc addMove { sq1 sq2 } {
  global EMPTY
  if {[sc_pos isLegal $sq1 $sq2] == 0} { return }
  set promo $EMPTY
  if {[sc_pos isPromotion $sq1 $sq2] == 1} { set promo [getPromoPiece] }
  set action "replace"
  if {![sc_pos isAt vend]} {
    set action [confirmReplaceMove]
  }
  if {$action == "replace"} {
    sc_move add $sq1 $sq2 $promo
  } elseif {$action == "var"} {
    sc_var create
    sc_move add $sq1 $sq2 $promo
  } else {
    return
  }
  moveEntry_Clear
  updateBoardAndPgn
  ::tree::doTraining
}

# highlightSquare:
#   Changes a square's color so it is highlighted, provided there is
#   a legal move to or from that square. Also colors the suggested
#   square for the best matching move.
#
proc highlightSquare {square} {
  global highcolor bestcolor bestSq suggestMoves
  set bestSq -1
  if {$suggestMoves} {
    set bestSq [sc_pos bestSquare $square]
  }
  if {[expr $bestSq != -1]} {
    ::board::colorSquare .board $square $highcolor
    ::board::colorSquare .board $bestSq $bestcolor
  }
}

# resetMarkSquares:
#    Removes all marked square colors.
#
proc resetMarkSquares {} {
  global markSquares
  foreach i [array names markSquares] {
    unset markSquares($i)
  }
  ::board::recolor .board
}

array set markSquares {}

# markSquare:
#    Given a square in a1,h8, etc notation and a color, makes
#    the square that color.
#
proc markSquare {square color} {
  array set files {a 0 b 1 c 2 d 3 e 4 f 5 g 6 h 7}
  set file [string index $square 0]
  set rank [string index $square 1]
  if {! [info exists files($file)]} { return }
  if {$rank < 1  || $rank > 8} { return }
  set rank [expr $rank - 1]
  set sq [expr $files($file) + ($rank * 8)]
  set ::markSquares($sq) $color
  ::board::colorSquare .board $sq $color
}

# arrowSquare:
#    Draws an arrow between the two specified squares.
#
proc arrowSquare {from to color} {
  array set files {a 0 b 1 c 2 d 3 e 4 f 5 g 6 h 7}
  set file [string index $from 0]
  set rank [string index $from 1]
  if {! [info exists files($file)]} { return }
  if {$rank < 1  || $rank > 8} { return }
  set rank [expr $rank - 1]
  set from [expr $files($file) + ($rank * 8)]

  set file [string index $to 0]
  set rank [string index $to 1]
  if {! [info exists files($file)]} { return }
  if {$rank < 1  || $rank > 8} { return }
  set rank [expr $rank - 1]
  set to [expr $files($file) + ($rank * 8)]
  ::board::arrow .board $from $to $color
}

# enterSquare:
#   Called when the mouse pointer enters a board square.
#   Finds the best matching square for a move (if there is a
#   legal move to or from this square), and colors the squares
#   to indicate the suggested move.
#
proc enterSquare { square } {
  global highcolor currentSq bestSq bestcolor selectedSq suggestMoves
  set currentSq $square
  if {$selectedSq == -1} {
    ::board::recolor .board
    set bestSq -1
    if {$suggestMoves} {
      set bestSq [sc_pos bestSquare $square]
    }
    if [expr $bestSq != -1] {
      ::board::colorSquare .board $square $bestcolor
      ::board::colorSquare .board $bestSq $bestcolor
    }
  }
}

# leaveSquare:
#    Called when the mouse pointer leaves a board square.
#    Recolors squares to normal (lite/dark) color.
#
proc leaveSquare { square } {
  global currentSq selectedSq bestSq
  set currentSq -1
  if {$square != $selectedSq} {
    ::board::colorSquare .board $square
  }
  if {$bestSq != -1} {
    ::board::colorSquare .board $bestSq
  }
}

# pressSquare:
#    Called when the left mouse button is pressed on a square. Sets
#    that square to be the selected square.
#
proc pressSquare { square } {
  global selectedSq highcolor
  if {$selectedSq == -1} {
    set selectedSq $square
    ::board::recolor .board
    ::board::colorSquare .board $square $highcolor
    # Drag this piece if it is the same color as the side to move:
    set c [string index [sc_pos side] 0]  ;# will be "w" or "b"
    set p [string index [::board::piece .board $square] 0] ;# "w", "b" or "e"
    if {$c == $p} {
      ::board::setDragSquare .board $square
    }
  } else {
    ::board::setDragSquare .board -1
    ::board::colorSquare .board $selectedSq
    ::board::colorSquare .board $square
    addMove $square $selectedSq
    set selectedSq -1
    enterSquare $square
  }
}

# pressSquare2:
#   Called when the middle mouse button is pressed on a square. This
#   makes the suggested best move.
#
proc pressSquare2 { square } {
  global selectedSq bestSq
  ::board::colorSquare .board $bestSq
  ::board::colorSquare .board $square
  addMove $square $bestSq
  enterSquare $square
}

# releaseSquare:
#   Called when the left mouse button is released over a square.
#   If the square is different to that the button was pressed on, it
#   is a dragged move; otherwise it is just selecting this square as
#   part of a move.
#
proc releaseSquare { w x y } {
  global selectedSq bestSq currentSq

  ::board::setDragSquare .board -1
  set square [::board::getSquare $w $x $y]
  if {$square < 0} {
    set selectedSq -1
    ::board::recolor $w
    return
  }

  if {$square == $selectedSq} {
    if {$::suggestMoves} {
      # User pressed and released on same square, so make the
      # suggested move if there is one:
      set selectedSq -1
      ::board::colorSquare $w $bestSq
      ::board::colorSquare $w $square
      addMove $square $bestSq
      enterSquare $square
    } else {
      # Current square is the square user pressed the button on,
      # so we do nothing.
    }
  } else {
    # User has dragged to another square, so try to add this as a move:
    addMove $square $selectedSq
    ::board::colorSquare $w $selectedSq
    set selectedSq -1
    ::board::colorSquare $w $square
  }
}


# searchReset:
#   Resets the filter to contain all games. Calls sc_filter reset and
#   updates relevant windows.
#
proc searchReset {} {
  global glstart
  sc_filter reset
  set glstart 1
  updateGList
  updateStatsWin
  updateMenuStates
}

# searchNegate:
#   Negates the filter, to include only excluded games.
#
proc searchNegate {} {
  global glstart
  sc_filter negate
  set glstart 1
  updateGList
  updateStatsWin
  updateMenuStates
}


# backSquare:
#    Handles the retracting of a move (when the right mouse button is
#    clicked on a square). Recolors squares to normal color also.
#    If the move is the last in the game or variation, is is removed
#    by truncating the game after retracting the move.
#
proc backSquare {} {
  global selectedSq bestSq
  set lastMoveInLine 0
  if {[sc_pos isAt vend]} {
    set lastMoveInLine 1
  }
  sc_move back
  if {$lastMoveInLine} {
    sc_game truncate
  }
  ::board::colorSquare .board $selectedSq
  ::board::colorSquare .board $bestSq
  set selectedSq -1
  set bestSq -1
  updateBoardAndPgn .board
}


##
## Auto-playing of moves:
##
set autoAnnotate 1
set autoplayMode 0

set tempdelay 0
trace variable tempdelay w {forceRegexp {^[0-9]*\.?[0-9]*$}}

proc setAutoplayDelay {{askAnnotate 0}} {
  global autoplayDelay tempdelay autoplayResult
  set autoplayResult -1
  set tempdelay [expr $autoplayDelay / 1000.0]
  set w .apdialog
  toplevel $w
  wm title $w "Scid"
  wm resizable $w 0 0
  label $w.label -text $::tr(AnnotateTime:)
  pack $w.label -side top -pady 5 -padx 5
  entry $w.entry -background white -width 10 -textvariable tempdelay
  pack $w.entry -side top -pady 5
  bind $w.entry <Escape> { .apdialog.buttons.cancel invoke }
  bind $w.entry <Return> { .apdialog.buttons.ok invoke }

  if {$askAnnotate} {
    addHorizontalRule $w
    label $w.avlabel -text $::tr(AnnotateWhich:)
    radiobutton $w.all -text $::tr(AnnotateAll) \
      -variable annotateMoves -value all -anchor w
    radiobutton $w.white -text $::tr(AnnotateWhite) \
      -variable annotateMoves -value white -anchor w
    radiobutton $w.black -text $::tr(AnnotateBlack) \
      -variable annotateMoves -value black -anchor w
    radiobutton $w.notbest -text $::tr(AnnotateNotBest) \
      -variable annotateMoves -value notbest -anchor w
    pack $w.avlabel -side top
    pack $w.all $w.white $w.black $w.notbest -side top -fill x
  }

  addHorizontalRule $w

  set b [frame $w.buttons]
  pack $b -side top -fill x
  button $b.cancel -text $::tr(Cancel) -command {
    focus .
    grab release .apdialog
    destroy .apdialog
    focus .
    set autoplayResult 0
  }
  button $b.ok -text "OK" -command {
    grab release .apdialog
    if {$tempdelay < 0.1} { set tempdelay 0.1 }
    set autoplayDelay [expr int($tempdelay * 1000)]
    focus .
    grab release .apdialog
    destroy .apdialog
    focus .
    set autoplayResult 1
  }
  pack $b.cancel $b.ok -side right -padx 5 -pady 5
  focus $w.entry
  update idletasks
  grab $w
  tkwait variable autoplayResult
  return $autoplayResult
}


proc toggleAutoplay {{askForDelay 0}} {
  global autoplayMode annotateMode
  if {$autoplayMode == 0} {
    if {$askForDelay} {
      if {! [setAutoplayDelay 1]} {
        set annotateMode 0
        return
      }
    }
    set autoplayMode 1
    set annotateMode 1
    .button.autoplay configure -image autoplay_on -relief sunken
    autoplay
  } else {
    cancelAutoplay
  }
}

proc autoplay {} {
  global autoplayDelay autoplayMode autoAnnotate
  if {$autoplayMode == 0} { return }
  if {[sc_pos isAt vend]} {
    cancelAutoplay
    return
  }
  if {$autoAnnotate} {
    if {![sc_pos isAt start]} { addAnalysisVariation }
  }
  sc_move forward
  updateBoard .board
  after $autoplayDelay autoplay
}

proc cancelAutoplay {} {
  global autoplayMode annotateMode
  set autoplayMode 0
  set annotateMode 0
  after cancel autoplay
  .button.autoplay configure -image autoplay_off -relief flat
}

bind . <Control-z> {toggleAutoplay; break}
bind . <Escape> cancelAutoplay

set trialMode 0

proc setTrialMode {mode} {
  global trialMode
  if {$mode == "toggle"} {
    set mode [expr 1 - $trialMode]
  }
  if {$mode == $trialMode} { return }
  if {$mode == "update"} { set mode $trialMode }

  if {$mode == 1} {
    set trialMode 1
    sc_game push copy
    .button.trial configure -image tb_trial_on
  } else {
    set trialMode 0
    sc_game pop
    .button.trial configure -image tb_trial
  }
  updateBoardAndPgn .board
}

###
### End of file: board.tcl
###
