# board.tcl: part of Scid
# Copyright (C) 2001-2003 Shane Hudson. All rights reserved.
# Copyright (C) 2014-2021 Fulvio Benini
# Copyright (C) 2021 Uwe Klimmek

# letterToPiece
#    Array that maps piece letters to their two-character value.
#
array set ::board::letterToPiece [list \
    "R" wr "r" br "N" wn "n" bn "B" wb "b" bb \
    "Q" wq "q" bq "K" wk "k" bk "P" wp "p" bp "." e \
    ]

# List of color schemes: each sublist contains a reference name (not used),
# then lite, dark, highcolor, bestcolor, white, black, w border, b border.
#
set colorSchemes {
  { "Blue-white" "#f3f3f3" "#7389b6" "#f3f484" "#b8cbf8" "#ffffff" "#000000" "#000000" "#ffffff" }
  { "Green-Yellow" "#e0d070" "#70a070" "#b0d0e0" "#bebebe" }
  { "Brown" "#d0c0a0" "#a08050" "#b0d0e0" "#bebebe" }
  { "Blue-ish" "#d0e0d0" "#80a0a0" "#b0d0e0" "#f0f0a0" }
  { "M. Thomas" "#e0d8b8" "#047c24" "#1c80e0" "#fe0000" }
  { "KM. Skontorp" "#ffdb86" "#ffa200" "#b0d0e0" "#bebebe" }
}
array set newColors {}

# calculate an average of the colors from a graphic file
proc avgImgColor { file } {
    set i 0; set r 0; set g 0; set b 0
    set textureSize [image height $file]
    for { set p 2 } { $p < $textureSize } {incr p 4; incr i } {
        lassign [$file get $p $p] r1 g1 b1
        incr r $r1
        incr g $g1
        incr b $b1
    }
    set r [expr int(($r) / $i)]
    set g [expr int(($g) / $i)]
    set b [expr int(($b) / $i)]
    return [ format "#%02x%02x%02x" $r $g $b ]
}

proc SetBoardTextures {} {
  global boardfile_dark boardfile_lite
  # handle cases of old configuration files
  image create photo bgl20 -height 20 -width 20
  image create photo bgd20 -height 20 -width 20
  if { [ catch { bgl20 copy $boardfile_lite -from 0 0 20 20 ; bgd20 copy $boardfile_dark -from 0 0 20 20 } ] } {
    set boardfile_dark emptySquare
    set boardfile_lite emptySquare
    bgl20 copy $boardfile_lite -from 0 0 20 20
    bgd20 copy $boardfile_dark -from 0 0 20 20
  }

  set textureSize "[image height $boardfile_lite].0"
  foreach size $::boardSizes {
    # create lite and dark squares
    image create photo bgl$size -width $size -height $size
    image create photo bgd$size -width $size -height $size
    set z [expr int (ceil ($size / $textureSize))]
    bgl$size copy $boardfile_lite -zoom $z
    bgd$size copy $boardfile_dark -zoom $z
  }
}

# setPieceFont:
#   Given a piece font name, resets all piece images in all
#   available board sizes to that font.
#
proc setPieceFont {font} {
	set ::boardSizes {}
	set dname [file join $::scidImgDir pieces $font]
	set fnames [glob -nocomplain -directory $dname *.png]
	append fnames " " [glob -nocomplain -directory $dname *.gif]
	foreach {fname} $fnames {
		if {! [catch {image create photo tmpPieces -file "$fname"}]} {
			set size [image height tmpPieces]
			if {[lsearch -exact $::boardSizes $size] == -1} {
				image create photo e$size -height $size -width $size
				set x 0
				foreach p {wp wn wb wr wq wk bp bn bb br bq bk} {
					image create photo $p$size -width $size -height $size
					$p$size copy tmpPieces -from $x 0 [expr {$x + $size}] $size
					incr x $size
				}
				lappend ::boardSizes $size
			}
			image delete tmpPieces
		}
	}
	if {[llength $::boardSizes] == 0 && $::boardStyle != "Merida"} {
		set ::boardStyle "Merida"
		setPieceFont "$::boardStyle"
		return
	}
	set ::boardSizes [lsort -integer $::boardSizes]
	foreach size $::boardSizes {
		if {$size >= $::boardSize} { break }
	}
	set ::boardSize $size
	SetBoardTextures
}

# chooseBoardTextures:
#   Dialog for selecting board textures.
#
proc chooseBoardTextures {i} {
  global boardfile_dark boardfile_lite

  set prefix [lindex $::textureSquare $i]
  set boardfile_dark ${prefix}-d
  set boardfile_lite ${prefix}-l
  SetBoardTextures
  # create colors for coords on the board
  # use variable lite and dark from colorschemes
  set ::squareColor_lite [::avgImgColor $boardfile_lite]
  set ::squareColor_dark [::avgImgColor $boardfile_dark]
  ::board::innercoords .main.board
  updateBoard
}

proc updateBoardColors { w {choice -1}} {
  global squareColor_lite squareColor_dark highcolor bestcolor
  global colorSchemes newColors
  set colors {squareColor_lite squareColor_dark highcolor bestcolor}
  # Just update the dialog box colors and return:
  if {$choice >= 0} {
    set list [lindex $colorSchemes $choice]
    set newColors(squareColor_lite) [lindex $list 1]
    set newColors(squareColor_dark) [lindex $list 2]
    set newColors(highcolor) [lindex $list 3]
    set newColors(bestcolor) [lindex $list 4]

    # Remove board textures
    set ::boardfile_dark emptySquare
    set ::boardfile_lite emptySquare
    ::SetBoardTextures
  }
  set nlite $newColors(squareColor_lite)
  set ndark $newColors(squareColor_dark)

  foreach i {wr bn wb bq wk bp} {
    $w.bd.$i configure -background $ndark
  }
  foreach i {br wn bb wq bk wp} {
    $w.bd.$i configure -background $nlite
  }
  $w.bd.bb configure -background $newColors(highcolor)
  $w.bd.wk configure -background $newColors(bestcolor)
  foreach i $colors {
    $w.select.b$i configure -background $newColors($i)
  }

  foreach i {squareColor_lite squareColor_dark highcolor bestcolor} {
    set $i $newColors($i)
  }
  foreach i {0 1 2 3} {
    set c $w.border.c$i
    $c itemconfigure dark -fill $squareColor_dark -outline $squareColor_dark
    $c itemconfigure lite -fill $squareColor_lite -outline $squareColor_lite
  }
  foreach i {0 1 2 3 4} {
    set c $w.coords.c$i
    $c itemconfigure dark -fill $squareColor_dark -outline $squareColor_dark
    $c itemconfigure lite -fill $squareColor_lite -outline $squareColor_lite
  }
  ::board::innercoords .main.board
  updateBoard
  return
}

# chooseBoardColors:
#   Dialog for selecting board colors.
#   Frame for this dialog is generated by preferences dialog
#
proc chooseBoardColors { w {choice -1}} {
  global squareColor_lite squareColor_dark highcolor bestcolor
  global colorSchemes newColors

  set colors {squareColor_lite squareColor_dark highcolor bestcolor}

  foreach i $colors { set newColors($i) [set $i] }
  set bd $w.bd
  pack [ttk::frame $bd] -side top -expand 1 -anchor w
  addHorizontalRule $w
  pack [ttk::frame $w.select] -side top -fill x -padx 5
  addHorizontalRule $w
  pack [ttk::frame $w.preset] -side top -fill x
  pack [ttk::frame $w.texture] -side top -fill x -pady 2
  addHorizontalRule $w
  pack [ttk::frame $w.coords] -side top -fill x -pady 4
  addHorizontalRule $w
  pack [ttk::frame $w.border] -side top -anchor w -pady { 4 0 }

  foreach psize $::boardSizes {
    if {$psize >= 40} { break }
  }
  set column 0
  foreach j {r n b q k p} {
    ttk::label $bd.w$j -image w${j}$psize
    ttk::label $bd.b$j -image b${j}$psize
    grid $bd.b$j -row 0 -column $column
    grid $bd.w$j -row 1 -column $column
    incr column
  }
  ttk::frame $bd.p
  ttk::label $bd.p.lb -text [tr OptionsBoardPieces]
  ttk::combobox $bd.p.pieces -width 12 -textvar ::boardStyle -values $::boardStyles
  bind $bd.p.pieces <<ComboboxSelected>> { setPieceFont $::boardStyle; updateBoard }
  ttk::frame $bd.s
  ttk::label $bd.s.lb -text [tr OptionsBoardSize]
  ttk::checkbutton $bd.s.auto -text "Auto" -variable ::autoResizeBoard -command "::resizeMainBoard"
  ttk::combobox $bd.s.size -width 4 -textvar ::boardSize  -values $::boardSizes
  bind $bd.s.size <<ComboboxSelected>> { ::board::resize .main.board $::boardSize }
  pack $bd.p.lb $bd.p.pieces -side left -anchor w -padx 5
  pack $bd.s.lb $bd.s.auto $bd.s.size -side left -anchor w -padx 5
  ttk::label $bd.empty -text "  "
  grid $bd.empty -row 0 -column 7
  grid $bd.p -row 0 -column 8
  grid $bd.s -row 1 -column 8

  set f $w.select
  foreach row {0 1 0 1} column {0 0 2 2} c {
    squareColor_lite squareColor_dark highcolor bestcolor
  } n {
    LightSquares DarkSquares SelectedSquares SuggestedSquares
  } {
    button $f.b$c -image e20 -background [set $c] -command "
    set x \[ tk_chooseColor -initialcolor \$newColors($c) -title Scid \]
    if {\$x != \"\"} { set newColors($c) \$x; updateBoardColors $w}
    "
    ttk::label $f.l$c -text "$::tr($n)  "
    grid $f.b$c -row $row -column $column
    grid $f.l$c -row $row -column [expr {$column + 1} ] -sticky w
  }

  # Border width option:
  set f $w.border
  foreach i {0 1 2 3} {
    if {$i != 0} { pack [ttk::frame $f.gap$i -width 20] -side left -padx 1 }
    set b $f.b$i
    ttk::radiobutton $b -text "$i:" -variable ::borderwidth -value $i -command "set ::borderwidth $i; ::board::border .main.board $i; updateBoard"
    set c $f.c$i
    canvas $c -height $psize -width $psize -background black
    $c create rectangle 0 0 [expr {20 - $i}] [expr {20 - $i}] -tag dark
    $c create rectangle [expr {20 + $i}] [expr {20 + $i}] $psize $psize -tag dark
    $c create rectangle 0 [expr {20 + $i}] [expr 20 - $i] $psize -tag lite
    $c create rectangle [expr {20 + $i}] 0 $psize [expr {20 - $i}] -tag lite
    pack $b $c -side left -padx 1
    bind $c <Button-1> "set ::borderwidth $i; ::board::border .main.board $i; updateBoard"
  }

  # Coords option:
  set f $w.coords
  # bl: border left, bt: border top, ssi: squaresize
  set slist [list 0 0 20 8 0 16 8 8 12 8 0 20 8 0 20]
  foreach i {0 1 2 3 4} {bl bt ssi} $slist {
    if {$i != 0} { pack [ttk::frame $f.gap$i -width 20] -side left -padx 1 }
    set b $f.b$i
    set fcom "set ::boardCoords $i
              ::board::coords .main.board $i
              ::board::resize .main.board redraw"
    ttk::radiobutton $b -text "$i:" -variable ::boardCoords -value $i -command $fcom
    set c $f.c$i
    canvas $c -height $psize -width $psize -background white
    if { $i >= 3 } {
        set x0 0
        set y0 0
    } else {
        set x0 [expr $bl]
        set y0 [expr $bt]
    }
    set x1 [expr $x0 + $ssi]
    set y1 [expr $y0 + $ssi]
    set x2 [expr $x1 + $ssi]
    set y2 [expr $y1 + $ssi]
    $c create rectangle $x0 $y0 $x1 $y1 -tag dark
    $c create rectangle $x1 $y1 $x2 $y2 -tag dark
    $c create rectangle $x0 $y1 $x1 $y2 -tag lite
    $c create rectangle $x1 $y0 $x2 $y1 -tag lite
    if { $i > 0 } {
        foreach { x y co } { 4 30 1 4 10 2 14 36 a 28 36 b } {
            $c create text $x $y -text $co -fill black -font font_Small
        }
        if { $i == 2 || $i == 4 } {
            foreach { x y co } { 38 30 1 38 10 2 14 4 a 28 4 b } {
                $c create text $x $y -text $co -fill black -font font_Small
            }
        }
    }
    pack $b $c -side left -padx 1
    bind $c <Button-1> $fcom
  }

  set count 0
  foreach list $colorSchemes {
    set f $w.preset.p$count
    pack [ttk::frame $f] -side left -padx 5
    ttk::label $f.blite -image bp$psize -background [lindex $list 1]
    ttk::label $f.bdark -image bp$psize -background [lindex $list 2]
    ttk::label $f.wlite -image wp$psize -background [lindex $list 1]
    ttk::label $f.wdark -image wp$psize -background [lindex $list 2]
    ttk::button $f.select -text [expr {$count + 1}] \
        -command "updateBoardColors $w $count"
    bind $f.blite <1> "$f.select invoke"
    bind $f.bdark <1> "$f.select invoke"
    bind $f.wlite <1> "$f.select invoke"
    bind $f.wdark <1> "$f.select invoke"
    grid $f.blite -row 0 -column 0 -sticky e
    grid $f.bdark -row 0 -column 1 -sticky w
    grid $f.wlite -row 1 -column 1 -sticky w
    grid $f.wdark -row 1 -column 0 -sticky e
    grid $f.select -row 2 -column 0 -columnspan 2 ; # -sticky we
    incr count
  }

  #########################################################
  set f $w.texture
  set count 0
  set row 0
  set col 0
  foreach tex $::textureSquare {
    set f $w.texture.p$count
    grid [ ttk::frame $f ] -row $row -column $col -padx 5
    canvas $f.c -width [expr $psize*2] -height [expr $psize*2] -background red
    $f.c create image 0 0 -image ${tex}-l -anchor nw
    $f.c create image $psize 0 -image ${tex}-d -anchor nw
    $f.c create image 0 $psize -image ${tex}-d -anchor nw
    $f.c create image $psize $psize -image ${tex}-l -anchor nw

    $f.c create image 0 0 -image bp$psize -anchor nw
    $f.c create image $psize 0 -image wp$psize -anchor nw
    $f.c create image 0 $psize -image wp$psize -anchor nw
    $f.c create image $psize $psize -image bp$psize -anchor nw
    ttk::button $f.select -text [expr {$count + 1}] -command "chooseBoardTextures $count"
    bind $f.c <1> "chooseBoardTextures $count"
    pack $f.c $f.select -side top

    incr count
    incr col
    if {$col > 5} { set col 0 ; incr row }
  }
  updateBoardColors $w
}

namespace eval ::board {

  namespace export sq

  # List of square names in order; used by sq procedure.
  variable squareIndex [list a1 b1 c1 d1 e1 f1 g1 h1 a2 b2 c2 d2 e2 f2 g2 h2 \
      a3 b3 c3 d3 e3 f3 g3 h3 a4 b4 c4 d4 e4 f4 g4 h4 \
      a5 b5 c5 d5 e5 f5 g5 h5 a6 b6 c6 d6 e6 f6 g6 h6 \
      a7 b7 c7 d7 e7 f7 g7 h7 a8 b8 c8 d8 e8 f8 g8 h8]
}

# ::board::sq:
#    Given a square name, returns its index as used in board
#    representations, or -1 if the square name is invalid.
#    Examples: [sq h8] == 63; [sq a1] = 0; [sq notASquare] = -1.
#
proc ::board::sq {sqname} {
  variable squareIndex
  return [lsearch -exact $squareIndex $sqname]
}

# ::board::san --
#
#	Convert a square number (0-63) used in board representations
#	to the SAN square name (a1, a2, ..., h8).
#
# Arguments:
#	sqno	square number 0-63.
# Results:
#	Returns square name "a1"-"h8".
#
proc ::board::san {sqno} {
  if {($sqno < 0) || ($sqno > 63)} { return }
  return [format %c%c \
      [expr {($sqno % 8) + [scan a %c]}] \
      [expr {($sqno / 8) + [scan 1 %c]}]]

}

# Show a pop-up board.
# xc and yc are the coordinates of the top-left corner, or the bottom-left
# corner if above is not "".
proc ::board::popup {w positionLongStr xc yc {above ""}} {
    set psize 30
    if {$psize > $::boardSize} { set psize $::boardSize }

    if {! [winfo exists $w]} {
        toplevel $w
        wm overrideredirect $w 1
        ::board::new $w.bd $psize
        grid $w.bd
        ::update idletasks
    }

    lassign $positionLongStr pos lastmove
    ::board::update $w.bd $pos

    if {$lastmove ne ""} {
      ::board::lastMoveHighlight $w.bd $lastmove
    }

    # Make sure the popup window can fit on the screen:
    set screenwidth [winfo screenwidth $w]
    set screenheight [winfo screenheight $w]
    set dx [winfo width $w]
    set dy [winfo height $w]
    incr xc 8
    if {($xc+$dx) > $screenwidth} {
        set xc [expr {$screenwidth - $dx}]
    }
    if {($yc+$dy) > ($screenheight -8)} {
            set above 1
    }
    if {$above ne ""} {
        set yc [expr { $yc -$dy -8 }]
        if {$yc < 0} { set yc 0 }
    } else {
        incr yc 8
    }
    wm geometry $w "+$xc+$yc"
    wm deiconify $w
    raiseWin $w
}

# ::board::new
#   Creates a new board in the specified frame.
#
proc ::board::new {w {psize 40} } {
  if {[winfo exists $w]} { return }

  foreach size $::boardSizes {
    if {$size >= $psize} { break }
  }
  set psize $size

  set ::board::_size($w) $psize
  set ::board::_border($w) $::borderwidth
  set ::board::_coords($w) 4
  set ::board::_flip($w) 0
  set ::board::_data($w) [sc_pos board]
  set ::board::_showMarks($w) 0
  set ::board::_mark($w) {}
  set ::board::_drag($w) -1
  set ::board::_showmat($w) 0
  set ::board::_evalbarShow($w) 0
  set ::board::_evalbarMaxScore($w) 4
  set ::board::_evalbarScore($w) 0
  set ::board::_evalbarHeight($w) 0
  set ::board::_evalbarWidth($w) 0
  set ::board::_evalbarScale($w) 1

  set border $::board::_border($w)
  set bsize [expr {$psize * 8 + $border * 9} ]

  ttk::frame $w -class Board
  canvas $w.bd -width $bsize -height $bsize -cursor crosshair -borderwidth 0 -highlightthickness 0
  ::applyThemeColor_background $w.bd
  catch { grid anchor $w center }

  set startrow 5
  grid $w.bd -row [expr $startrow +1] -column 3 -rowspan 8 -columnspan 8
  set bd $w.bd

  # Create empty board:
  for {set i 0} {$i < 64} {incr i} {
    set xi [expr {$i % 8} ]
    set yi [expr {int($i/8)} ]
    set x1 [expr {$xi * ($psize + $border) + $border } ]
    set y1 [expr {(7 - $yi) * ($psize + $border) + $border } ]
    set x2 [expr {$x1 + $psize }]
    set y2 [expr {$y1 + $psize }]

    $bd create rectangle $x1 $y1 $x2 $y2 -tag sq$i -outline ""
  }

  # Set up coordinate labels:
  for {set i 1} {$i <= 8} {incr i} {
    ttk::label $w.lrank$i -text [expr {9 - $i}]
    grid $w.lrank$i -row [expr $startrow + $i] -column 2 -sticky e -padx 5
    ttk::label $w.rrank$i -text [expr {9 - $i}]
    grid $w.rrank$i -row [expr $startrow + $i] -column 11 -sticky w -padx 5
  }
  foreach i {1 2 3 4 5 6 7 8} file {a b c d e f g h} {
    ttk::label $w.tfile$file -text $file
    grid $w.tfile$file -row $startrow -column [expr $i + 2] -sticky s
    ttk::label $w.bfile$file -text $file
    grid $w.bfile$file -row [expr $startrow + 9] -column [expr $i + 2] -sticky n
  }

  canvas $w.score -width 8 -cursor hand2
  grid $w.score -row 6 -column 12 -rowspan 8 -sticky ew
  grid remove $w.score
  canvas $w.mat -width 20 -height $bsize -highlightthickness 0
  ::applyThemeColor_background $w.mat
  grid $w.mat -row 6 -column 13 -rowspan 8 -pady 0
  grid remove $w.mat

  ::board::coords $w
  ::board::update $w
  return $w
}

proc ::board::addNamesBar {w {varname}} {
  ttk::frame $w.playerW -style fieldbg.TLabel
  frame $w.playerW.color -background #EAE0C8 -width 6 -height 6
  ttk_canvas $w.playerW.tomove -borderwidth 0 -highlightthickness 0 -width 9 -height 9
  ttk::label $w.playerW.name -textvariable ${varname}(nameW) -font font_SmallBold -style fieldbg.TLabel
  ttk::label $w.playerW.elo -textvariable ${varname}(eloW) -font font_Small -style fieldbg.TLabel
  ttk::label $w.playerW.clock -textvariable ${varname}(clockW) -font font_Regular -style fieldbg.TLabel
  grid $w.playerW.color -row 0 -column 0 -sticky news -padx 2 -pady 2
  grid $w.playerW.name -row 0 -column 1 -sticky w
  grid $w.playerW.elo -row 0 -column 2 -sticky w
  grid $w.playerW.clock -row 0 -column 3 -sticky e
  grid $w.playerW.tomove -row 0 -column 4 -sticky w -padx 4
  grid columnconfigure $w.playerW 3 -weight 1
  grid $w.playerW -row 16 -column 3 -columnspan 8 -sticky news -pady 4

  ttk::frame $w.playerB -style fieldbg.TLabel
  frame $w.playerB.color -background black -width 6 -height 6
  ttk_canvas $w.playerB.tomove -borderwidth 0 -highlightthickness 0 -width 9 -height 9
  ttk::label $w.playerB.name -textvariable ${varname}(nameB) -font font_SmallBold -style fieldbg.TLabel
  ttk::label $w.playerB.elo -textvariable ${varname}(eloB) -font font_Small -style fieldbg.TLabel
  ttk::label $w.playerB.clock -textvariable ${varname}(clockB) -font font_Regular -style fieldbg.TLabel
  grid $w.playerB.color -row 0 -column 0 -sticky news -padx 2 -pady 2
  grid $w.playerB.name -row 0 -column 1 -sticky w
  grid $w.playerB.elo -row 0 -column 2 -sticky w
  grid $w.playerB.clock -row 0 -column 3 -sticky e
  grid $w.playerB.tomove -row 0 -column 4 -sticky w -padx 4
  grid columnconfigure $w.playerB 3 -weight 1
  grid $w.playerB -row 3 -column 3 -columnspan 8 -sticky news -pady 4
}

proc ::board::addInfoBar {w varname} {
  ttk::frame $w.bar
  ttk::frame $w.bar.info
  ttk_text $w.bar.info.t -style Toolbutton
  autoscrollBars y $w.bar.info $w.bar.info.t
  $w.bar.info.t tag bind click <Any-Enter> "$w.bar.info.t configure -cursor hand2"
  $w.bar.info.t tag bind click <Any-Leave> "$w.bar.info.t configure -cursor {}"
  grid propagate $w.bar.info 0
  ttk::button $w.bar.leavevar -image tb_BD_BackStart -style Toolbutton
  ttk::button $w.bar.back -image tb_BD_Back -style Toolbutton
  ttk::button $w.bar.forward -image tb_BD_Forward -style Toolbutton
  ttk::button $w.bar.endvar -image tb_BD_ForwardEnd -style Toolbutton
  set menu [::board::newToolBar_ $w $varname]
  ttk::button $w.bar.cmd -image tb_BD_ShowToolbar -style Toolbutton \
    -command "::board::updateToolBar_ $menu $varname $w.bar.cmd"
  grid $w.bar.cmd -in $w.bar -row 0 -column 0 -sticky news
  grid $w.bar.info -in $w.bar -row 0 -column 1 -sticky news -padx 4
  grid $w.bar.leavevar -row 0 -column 2 -sticky news
  grid $w.bar.back -row 0 -column 3 -sticky news
  grid $w.bar.forward -row 0 -column 4 -sticky news
  grid $w.bar.endvar -row 0 -column 5 -sticky news
  grid columnconfigure $w.bar 1 -weight 1
  grid $w.bar -row 20 -column 3 -columnspan 8 -sticky news -pady 4
  ::bind $w.bar <Configure> {+
	grid remove %W.leavevar
	grid remove %W.endvar
	if {%w > 450} {
	  grid %W.leavevar
	  grid %W.endvar
	}
  }
}

proc ::board::addInfo {{w} {msg}} {
  if {$msg eq ""} { return }
  $w.bar.info.t configure -state normal
  $w.bar.info.t insert end "\n$msg"
  $w.bar.info.t configure -state disabled
}

proc ::board::setInfo {{w} {msg}} {
  $w.bar.info.t configure -state normal
  $w.bar.info.t delete 1.0 end
  foreach {elem tag} $msg {
    $w.bar.info.t insert end $elem $tag
  }
  $w.bar.info.t configure -state disabled
}

# Show an alert message in the infobar.
# If @e header is empty, append the message at the current infobar.
proc ::board::setInfoAlert {{w} {header} {msg} {msgcolor} {cmd}} {
  $w.bar.info.t configure -state normal
  if {$header ne ""} {
    $w.bar.info.t delete 1.0 end
    $w.bar.info.t insert end "$header " {header click}
  } else {
    $w.bar.info.t insert end "\n"
  }
  $w.bar.info.t insert end "$msg" {color click}
  $w.bar.info.t configure -state disabled
  $w.bar.info.t tag configure color -foreground $msgcolor
  $w.bar.info.t tag bind click <ButtonRelease-1> "
    if {[winfo exists $cmd]} {
      after idle \"tk_popup $cmd %X \[expr -10 + %Y - \[winfo reqheight $cmd\] \]\"
    } else {
      after idle $cmd
    }
  "
}

set ::board::repeatCmd 400
proc ::board::setButtonCmd {{w} {button} {cmd}} {
  if {$cmd == ""} {
    $w.bar.$button configure -state disabled
  } else {
    $w.bar.$button configure -state normal
    ::bind $w.bar.$button <ButtonPress-1> "
      $cmd
      set ::board::repeatCmd \[expr int(\$::board::repeatCmd *0.8)\]
      after \$::board::repeatCmd \"event generate $w.bar.$button <ButtonPress-1>\"
    "
    ::bind $w.bar.$button <Any-Leave> "
      after cancel \"event generate $w.bar.$button <ButtonPress-1>\"
      set ::board::repeatCmd 400
    "
    ::bind $w.bar.$button <ButtonRelease-1> "
      after cancel \"event generate $w.bar.$button <ButtonPress-1>\"
      set ::board::repeatCmd 400
    "
  }
}

proc ::board::setButtonImg {{w} {button} {img}} {
  $w.bar.$button configure -image $img
}

# Associates fn with the specified evaluation bar's event.
proc ::board::bindEvalBar {w event fn} {
  ::bind $w.score $event $fn
}

proc ::board::toggleEvalBar {w} {
  set ::board::_evalbarShow($w) [expr {1 - $::board::_evalbarShow($w)}]
  if {$::board::_evalbarShow($w)} {
      grid $w.score
      ::board::drawEvalBar_ $w
  } else {
      grid remove $w.score
  }
  return $::board::_evalbarShow($w)
}

proc ::board::drawEvalBar_ { w } {
    if { ! $::board::_evalbarShow($w) } { return }
    set maxscore $::board::_evalbarMaxScore($w)
    set h [expr $::board::_size($w) * 8 + $::board::_border($w) * 6 - 2 ]
    set width 14

    $w.score delete nl barUp barDown
    $w.score configure -background grey50 -width [expr $width -2] -height $h \
        -borderwidth 1 -highlightthickness 0

    set colorUp grey7
    set colorDown grey94
    set ::board::_evalbarScale($w) [expr ($h + 2) / ($maxscore * -2.0)]
    if { $::board::_flip($w) } {
        set colorUp grey94
        set colorDown grey7
        set ::board::_evalbarScale($w) [expr $::board::_evalbarScale($w) * -1]
    }
    $w.score create rectangle 0 0 0 0 -tag barUp -width 0 -fill $colorUp
    $w.score create rectangle 0 0 0 0 -tag barDown -width 0 -fill $colorDown

    for { set i [expr 1 - $maxscore] } { $i < $maxscore } { incr i } {
        set h1 [expr $h / 2 + $i * $::board::_evalbarScale($w)]
        if { $i == 0 } {
            $w.score create rectangle 0 $h1 $width [expr $h1 + 2] -fill red -width 0 -tag nl
        } else {
            $w.score create line 0 $h1 $width $h1 -fill gray40 -tag nl
        }
    }
    set ::board::_evalbarHeight($w) $h
    set ::board::_evalbarWidth($w) $width
    ::board::updateEvalBar $w $::board::_evalbarScore($w)
}

# Update the score bar (if it is visibile) to reflect the provided score.
# The score value is from white prospective. An empty "" value means no score.
proc ::board::updateEvalBar { w score } {
    set ::board::_evalbarScore($w) $score
    if { ! $::board::_evalbarShow($w) } { return }

    if { $score eq "" } {
        $w.score coords barUp 0 0 0 0
        $w.score coords barDown 0 0 0 0
    } else {
        set width $::board::_evalbarWidth($w)
        set h $::board::_evalbarHeight($w)

        # Handle mate notation like +M12 or -M5
        if {[string index $score 1] eq "M" && [string is integer [string range $score 2 end]]} {
            if {[set sign [string index $score 0]] in {- +}} {
                set score [expr {$::board::_evalbarMaxScore($w) * ($sign eq "+" ? 1 : -1)}]
            }
        }

        set midY [expr $h / 2 + $score * $::board::_evalbarScale($w)]
        $w.score coords barUp 0 0 $width $midY
        $w.score coords barDown 0 $midY $width [expr $h + 1]
    }
}

proc ::board::updateToolBar_ {{menu} {varname} {mb ""} } {
  global "$varname"
  set i [$menu index end]
  while {$i >= 0} {
    set idx -1
    catch { set idx [lindex [$menu entryconfigure $i -image] 4] }
    if {[info exists "${varname}($idx)"] } {
      $menu entryconfigure $i -state normal -command "eval \$::${varname}($idx)"
    } else {
      catch { $menu entryconfigure $i -state disabled -command "" }
    }
    incr i -1
  }
  if {$mb != ""} {
    set x [winfo rootx $mb]
    set y [winfo rooty $mb]
    set bh [winfo height $mb]
    set mh [winfo reqheight $menu]
    if {$y >= $mh} { incr y -$mh } { incr y $bh }
    tk_popup $menu $x $y
  }
}

proc ::board::newToolBar_ {{w} {varname}} {
  global "$varname"

  set m [menu $w.menu_back]
  $m add command -label "  [tr BackToMainline]" -image tb_BD_BackToMainline -compound left
  $m add command -label "  [tr EditDelete]" -image tb_BD_VarDelete -compound left
  $m add command -label "  [tr LeaveVariant]" -image tb_BD_VarLeave -compound left
  $m add command -label "  [tr GameStart]" -image tb_BD_Start -compound left -accelerator "<home>"
  ::bind $w.bar.back <ButtonRelease-$::MB3> "::board::updateToolBar_ $m $varname %W"

  set m [menu $w.menu_forw]
  $m add command -label "  [tr Autoplay]" -image tb_BD_Autoplay -compound left
  $m add command -label "  [tr GameEnd]" -image tb_BD_End -compound left -accelerator "<end>"
  ::bind $w.bar.forward <ButtonRelease-$::MB3> "::board::updateToolBar_ $m $varname %W"

  set m [menu $w.menu]
  $m add command -label "  [tr EditSetup]" -image tb_BD_SetupBoard -compound left
  $m add command -label "  [tr IERotate]" -image tb_BD_Flip -compound left
  $m add command -label "  [tr ShowHideMaterial]" -image tb_BD_Material -compound left
  #TODO translate
  $m add command -label "  Show/Hide Evaluation Bar" -image tb_BD_Scorebar -compound left
  $m add command -label "  [tr ConfigureScid]" -image tb_BD_Layout -compound left

  set ${varname}(tb_BD_Flip) "::board::flip $w"
  set ${varname}(tb_BD_Material) "::board::toggleMaterial $w"
  set ${varname}(tb_BD_Scorebar) "::board::toggleEvalBar $w"
  set ${varname}(tb_BD_Layout) {::preferences::Open toggle}

  return $m
}

proc ::board::flipNames_ { {w} {white_on_top} } {
  if {![winfo exist $w.playerW] } { return }
  if {$white_on_top} {
    grid $w.playerW -row 3
    grid $w.playerB -row 16
  } else {
    grid configure $w.playerW -row 16
    grid configure $w.playerB -row 3
  }
}

proc ::board::sideToMove_ { {w} {side} } {
  if {![winfo exist $w.playerW] } { return }
  if {$side == "w"} {
    $w.playerB.tomove delete -tag tomove
    $w.playerW.tomove create rectangle 0 0 100 100 -fill blue -tag tomove
    $w.playerW.clock configure -font font_Bold
    $w.playerB.clock configure -font font_Regular
  } elseif {$side == "b"} {
    $w.playerW.tomove delete -tag tomove
    $w.playerB.tomove create rectangle 0 0 100 100 -fill blue -tag tomove
    $w.playerB.clock configure -font font_Bold
    $w.playerW.clock configure -font font_Regular
  }
}

# ::board::defaultColor
#   Returns the color (the value of the global
#   variable "lite" or "dark") depending on whether the
#   specified square number (0=a1, 1=b1, ..., 63=h8) is
#   a light or dark square.
#
proc ::board::defaultColor {sq} {
  return [expr {($sq + ($sq / 8)) % 2 ? "$::squareColor_lite" : "$::squareColor_dark"}]
}

# ::board::size
#   Returns the current board size.
#
proc ::board::size {w} {
  return $::board::_size($w)
}

proc ::board::resizeAuto {w bbox} {
  set availw  [lindex $bbox 2]
  set availh  [lindex $bbox 3]
  set extraw  [expr [winfo reqwidth $w]  - $::board::_size($w) * 8]
  set extrah  [expr [winfo reqheight $w] - $::board::_size($w) * 8]
  set availw  [expr $availw - $extraw]
  set availh  [expr $availh - $extrah]
  set maxSize [expr {$availh < $availw ? $availh : $availw}]
  set maxSize [expr $maxSize / 8]

  set newSize 0
  foreach size $::boardSizes {
    if {$size <= $maxSize && $size > $newSize} { set newSize $size }
  }

  return [::board::resize $w $newSize]
}

# ::board::resize
#   Resizes the board. Takes a numeric piece size (which should
#   be in the global boardSizes list variable), or "-1" or "+1".
#   If the size argument is "redraw", the board is redrawn.
#   Returns the new size of the board.
#
proc ::board::resize {w psize} {
  global boardSizes

  set oldsize $::board::_size($w)
  if {$psize == $oldsize} { return $oldsize }
  if {$psize == "redraw"} { set psize $oldsize }
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

  set border $::board::_border($w)
  set bsize [expr {$psize * 8 + $border * 9} ]

  $w.bd configure -width $bsize -height $bsize
  set ::board::_size($w) $psize

  # Resize each square:
  for {set i 0} {$i < 64} {incr i} {
    set xi [expr {$i % 8}]
    set yi [expr {int($i/8)}]
    set x1 [expr {$xi * ($psize + $border) + $border }]
    set y1 [expr {(7 - $yi) * ($psize + $border) + $border }]
    set x2 [expr {$x1 + $psize }]
    set y2 [expr {$y1 + $psize }]
    set pos $i
    if {$::board::_flip($w)} { set pos [expr {63 - $i}] }
    $w.bd coords sq$pos $x1 $y1 $x2 $y2
  }

  # resize the material canvas
  $w.mat configure -height $bsize

  ::board::coords $w $::board::_coords($w)
  ::board::update $w
  ::board::drawEvalBar_ $w

  return $psize
}

# ::board::border
#   Get or set the border width.
#   If the optional argument is missing or the empty string, returns
#   the width of the board.
#   Otherwise, the board sqyare borders are set to the specified width.
#
proc ::board::border {w {border ""}} {
  if {$border == ""} {
    return $::board::_border($w)
  } else {
    set ::board::_border($w) $border
    ::board::resize $w redraw
  }
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
  set x [expr {$x - [winfo rootx $w.bd]}]
  set y [expr {$y - [winfo rooty $w.bd]}]
  set psize $::board::_size($w)
  set border $::board::_border($w)
  set x [expr {int($x / ($psize+$border))}]
  set y [expr {int($y / ($psize+$border))}]

  if {$x < 0  ||  $y < 0  ||  $x > 7  ||  $y > 7} {
    set sq -1
  } else {
    set sq [expr {(7-$y)*8 + $x}]
    if {$::board::_flip($w)} { set sq [expr {63 - $sq}] }
  }
  return $sq
}

# ::board::showMarks
#   Turns on/off the showing of marks (colored squares).
#
proc ::board::showMarks {w value} {
  set ::board::_showMarks($w) $value
}

# ::board::colorSquare
#   Colors the specified square (0-63) of the board.
#   If the color is the empty string, the appropriate
#   color for the square (light or dark) is used.
#
proc ::board::colorSquare {w i {color ""}} {
  if {$i < 0  ||  $i > 63} { return }
  if {$color != ""} {
    $w.bd itemconfigure br$i -state hidden
  } else {
    set color [::board::defaultColor $i]
    set brstate "normal"
    if { $::glossOfDanger } {
      array set attacks [sc_pos attacks]
      if {[info exists attacks($i)]} {
        set color $attacks($i)
      }
    }
    foreach mark $::board::_mark($w) {
      if {[lindex $mark 1] == $i && [lindex $mark 0] == "full"} {
        set color [lindex $mark 3]
        set brstate "hidden"
      }
    }
    $w.bd itemconfigure br$i -state $brstate
  }
  $w.bd itemconfigure sq$i -fill $color -outline ""
}

# ::board::midSquare
#   Given a board and square number, returns the canvas X/Y
#   coordinates of the midpoint of that square.
#
proc ::board::midSquare {w sq} {
  set c [$w.bd coords sq$sq]
  #Klimmek: calculation change, because some sizes are odd and then some squares are shifted by 1 pixel
  # set x [expr {([lindex $c 0] + [lindex $c 2]) / 2} ]
  # set y [expr {([lindex $c 1] + [lindex $c 3]) / 2} ]
  set psize $::board::_size($w)
  if { $psize % 2 } { set psize [expr {$psize - 1}] }
  set x [expr {[lindex $c 0] + $psize/2} ]
  set y [expr {[lindex $c 1] + $psize/2} ]
  return [list $x $y]
}


# ::board::setmarks --
#
#	Set the marks for the board:
#	colored squares, arrows, circles, etc.
#
# Arguments:
#	w	A frame containing a board '$win.bd'.
#       cmds    Commands to draw the marks
# Results:
#	Sets ::board::_mark($w) with all the right formatted commands.
#       Marks will be drawn by ::board::update
#	Returns nothing.
#
proc ::board::setmarks {w cmds} {
  set ::board::_mark($w) {}
  if {$cmds eq ""} { return }

  set ::board::_mark($w) [lmap elem [mark::getEmbeddedCmds $cmds] {
    lassign $elem type arg1 arg2 color

    # Normalize the mark type
    switch -glob $type {
        ""     {set type [expr {[string length $arg2] ? "arrow" : "circle"}]}
        "mark" {set type "full"}
        ?      {set arg2 $type ; set type "text" }
    }

    # Normalize square coordinates
    set arg1 [::board::sq $arg1]
    set sq2 [::board::sq $arg2]
    if {$sq2 != -1} { set arg2 $sq2 }

    # Map color codes to color names
    switch -nocase $color {
      "" -
      "R" {set color "red"   }
      "G" {set color "green" }
      "Y" {set color "yellow"}
      "B" {set color "blue"  }
    }
    list $type $arg1 $arg2 $color
  }]
}

### Namespace ::board::mark

namespace eval ::board::mark {
  namespace import [namespace parent]::sq

  # Regular expression constants for
  # matching Scid's embedded commands in PGN files.

  variable ScidKey  {mark|arrow}
  variable Command  {draw}
  variable Type     {full|square|arrow|circle|disk|tux}
  variable Text     {[-+=?!A-Za-z0-9]}
  variable Square   {[a-h][1-8]\M}
  variable Color    {[\w#][^]]*\M}	;# FIXME: too lax for #nnnnnn!

  variable regex

  # Current (non-standard) version:
  set regex(mark) \
  "(?:($ScidKey)\\\ +)?  # (old) command name + space chars (may be omitted)
  ($Square)              # mandatory square (e.g. 'a4')
  (?:\\ +($Square))?     # optional: another (destination) square
  (?:\\ *($Color))?      # optional: color name
  "
  set regex(arrow) $regex(mark)

  # Proposed new version, according to the
  # PGN Specification and Implementation Guide (Supplement):
  set regex($Command) \
  "(?:(${Type}|$Text),)? # keyword, e.g. 'arrow' (may be omitted)
                         # or single char (indicating type 'text')
  ($Square)              # mandatory square (e.g. 'a4')
  (?:,($Square))?        # optional: (destination) square
  (?:,($Color))?         # optional: color name
  "

  # ChessBase' syntax for markers and arrows
  variable CBSquare    {csl}
  variable CBarrow     {cal}
  variable CBColor     {[BGRY]}
  variable Square      {[a-h][1-8]\M}
  variable sqintern    {[a-h][1-8]}

  # A sequence of color and square separated by commas, allowing for optional whitespace at the beginning and end.
  # e.g. "Rd4" " Rd4 , Gc3 "
  set regex($CBSquare) "^(\\s*$CBColor$Square\\s*,?)+$"
  set regex($CBarrow)  "^(\\s*$CBColor$sqintern$sqintern\\s*,?)+$"
}

# ::board::mark::getEmbeddedCmds --
#
#  Scans a game comment string and extracts embedded commands
#  used by Scid to mark squares or draw arrows.
#
# Arguments:
#   comment     The game comment string, containing
#               embedded commands, e.g.:
#                   [%mark e4 green],
#                   [%arrow c4 f7],
#                   [%draw h4],
#                   [%draw circle,f7,blue],
#                   [%draw X,d5,green],
#                   [%csl Rd4 , Gc3,Yh8 ],
#                   [%cal Rd4c7 , Ya1b5 ].
# Results:
#    Returns a list of embedded Scid commands:
#        '{type square ?arg? color}',
#        e.g. '{circle f7 red}' or '{arrow c4 f7 green}',
#
proc ::board::mark::getEmbeddedCmds {comment} {
  set result {}
  # Extracts embedded commands with the [%command args] syntax.
  # Without the weird {1,1}? the non-greedy (.*?) does not work (see re_syntax tcl documentation).
  # TODO: there are other function that extract the embedded commands with a similar regex.
  #       It would be better to receive the list {{cmd args} ... } instead of re-running the regex on the full comment.
  foreach {fullcmd cmd args} [regexp -all -inline {\[%([A-Za-z]+){1,1}?\s+(.*?)\s*\]} $comment] {
    set cmd [string tolower $cmd]
    if {$cmd in {draw arrow mark}} {
      if {[regexp -expanded $::board::mark::regex($cmd) $args -> type arg1 arg2 color]} {
        lappend result [list $type $arg1 $arg2 $color]
      }
    } elseif {$cmd in [list $::board::mark::CBSquare $::board::mark::CBarrow]} {
      if {[regexp $::board::mark::regex($cmd) $args]} {
        # Convert the string to a list of embedded commands.
        # e.g. Rd4,Gc3e4,Ya2 -> {"" d4 "" R} {"" c3 e4 G} {"" a2 "" Y}
        foreach {mark} [split $args ","] {
          set mark [string trim $mark]
          set color [string index $mark 0]
          set sq1 [string range $mark 1 2]
          set sq2 [string range $mark 3 end]
          lappend result [list "" $sq1 $sq2 $color]
        }
      }
    }
  }
  return $result
}

# ::board::mark::remove --
#
#	Removes a specified mark.
#
# Arguments:
#	win	A frame containing a board '$win.bd'.
#	args	List of one or two squares.
# Results:
#	Appends a dummy mark to the bord's list of marks
#	which causes the add routine to delete all marks for
#	the specified square(s).
#
proc ::board::mark::remove {win args} {
  if {[llength $args] == 2} {
    eval add $win arrow $args nocolor 1
  } else {
    add $win DEL [lindex $args 0] "" nocolor 1
  }
}

# ::board::mark::add --
#
#	Draws arrow or mark on the specified square(s).
#
# Arguments:
#	win		A frame containing a board 'win.bd'.
#	args		What kind of mark:
#	  type  	  Either type id (e.g., square, circle) or
#			    a single character, which is of type 'text'.
#	  square	  Square number 0-63 (0=a1, 1=a2, ...).
#	  ?arg2?	  Optional: additional type-specific parameter.
#	  color 	  Color to use for marking the square (mandatory).
#	  ?new? 	  Optional: whether or not this mark should be
#			    added to the list of marks; defaults to 'true'.
# Results:
#	For a given square, mark type, color, and optional (type-specific)
#	destination arguments, creates the proper canvas object.
#
proc ::board::mark::add {win args} {
  # Rearrange list if "type" is simple character:
  if {[string length [lindex $args 0]] == 1} {
    # ... e.g.,  {c e4 red} --> {text e4 c red}
    set args [linsert $args 1 "text"]
    set args [linsert [lrange $args 1 end] 2 [lindex $args 0]]
  }
  # Add default arguments:
  if {[lindex $args end] ni [list "true" "false" "1" "0"]} {
    lappend args "true"
  }
  if {[llength $args] == 4} { set args [linsert $args 2 ""]}

  # Here we (should) have: args == <type> <square> ?<arg>? <color> <new>
  foreach {type square dest color new} $args {break}	;# assign
  if {[llength $args] != 5 } { return }

  set board $win.bd
  set type  [lindex $args 0]

  # Remove existing marks:
  if {$type == "arrow"} {
    $board delete "mark${square}:${dest}" "mark${dest}:${square}"
    if {[string equal $color "nocolor"]} { set type DEL }
  } else {
    $board delete "mark${square}"
    #not needed anymore
    #    ::board::colorSquare $win $square [::board::defaultColor $square]
  }

  switch -- $type {
    full    { ::board::colorSquare $win $square $color }
    DEL     { set new 1 }
    default {
      # Find a subroutine to draw the canvas object:
      set drawingScript "Draw[string totitle $type]"
      if {![llength [info procs $drawingScript]]} { return }

      # ... and try it:
      if {[catch {eval $drawingScript $board $square $dest $color}]} {
        return
      }
    }
  }
  if {$new} { lappend ::board::_mark($win) [lrange $args 0 end-1] }
}

# ::board::mark::DrawXxxxx --
#
#	Draws specified canvas object,
#	where "Xxxxx" is some required type, e.g. "Circle".
#
# Arguments:
#	pathName	Name of the canvas widget.
#	args		Type-specific arguments, e.g.
#				<square> <color>,
#				<square> <square> <color>,
#				<square> <char> <color>.
# Results:
#	Constructs and evaluates the proper canvas command
#	    "pathName create type coordinates options"
#	for the specified object.
#

# ::board::mark::DrawCircle --
#
proc ::board::mark::DrawCircle {pathName square color} {
  # Some "constants":
  set size  0.94 ;# inner (enclosing) box size, 0.0 <  $size < 1.0
  set width 0.06 ;# outline around circle, 0.0 < $width < 1.0

  set box [GetBox $pathName $square $size]
  set width [expr int($width * [lindex $box 4] / $size)]
  $pathName create oval [lrange $box 0 3] \
      -fill "" -outline $color -width $width \
      -tag [list mark circle mark$square p$square]
}

# ::board::mark::DrawDisk --
#
proc ::board::mark::DrawDisk {pathName square color} {
  # Size of the inner (enclosing) box within the square:
  set size 0.6	;# 0.0 <  $size < 1.0 = size of rectangle

  set box [GetBox $pathName $square $size]
  eval $pathName \
      {create oval [lrange $box 0 3]} \
      -fill $color \
      {-tag [list mark disk mark$square p$square]}
}

# ::board::mark::DrawText --
# Pascal Georges : if shadow!="", try to make the text visible even if fg and bg colors are close
proc ::board::mark::DrawText {pathName square char color {size 0} {shadowColor ""}} {
  set box [GetBox $pathName $square 0.8]
  set len [expr {($size > 0) ? $size : int([lindex $box 4])}]
  set x   [lindex $box 5]
  set y   [lindex $box 6]
  $pathName delete text$square mark$square
  if {$shadowColor!=""} {
    eval $pathName \
        create text [expr $x+1] [expr $y+1] -fill $shadowColor \
        {-font [list helvetica $len bold]} \
        {-text [string index $char 0]}     \
        {-anchor c} \
        {-tag  [list mark text text$square mark$square p$square]}

  }
  eval $pathName \
      create text $x $y -fill $color     \
      {-font [list helvetica $len bold]} \
      {-text [string index $char 0]}     \
      {-anchor c} \
      {-tag  [list mark text text$square mark$square p$square]}
}

# Draw an arrow with a custom thickness, shape and associated tag.
# thickness: if >= 1 it represent the arrow thickness in pixels.
#            Otherwise it is interpreted as a percentage of the square width (default 0.1).
#
proc ::board::mark::DrawArrowEx {w from to color thickness arrowshape tag} {
  set pathName $w.bd
  $pathName delete $tag

  if {$from < 0  ||  $from > 63} { return }
  if {$to   < 0  ||  $to   > 63} { return }

  lassign [GetBox $pathName $from] left top right bottom length x0 y0
  lassign [lrange [GetBox $pathName $to] 5 6] x1 y1

  # Drawing from middle point to middle point is confusing when there are multiple arrows.
  # Solve equation: "midpoint + (lambda * vector) = edge point":
  set dX [expr {$x1 - $x0}]
  set dY [expr {$y1 - $y0}]
  if {abs($dX) > abs($dY)} {
    set edge [expr {($dX > 0) ? $right : $left}]
    set offX [expr {($edge - $x0) * 0.1}]
    set offY [expr {$offX * $dY / $dX}]
  } else {
    set edge [expr {($dY > 0) ? $bottom : $top}]
    set offY [expr {($edge - $y0) * 0.1}]
    set offX [expr {$offY * $dX / $dY}]
  }
  set coord [list [expr {$x0 + $offX}] [expr {$y0 + $offY}] [expr {$x1 - $offX}] [expr {$y1 - $offY}]]

  # If the squares are occupied, apply a bigger offset.
  if {[string index $::board::_data($w) $from] ne "."} {
    lset coord 0 [expr {$x0 + $offX * 5}]
    lset coord 1 [expr {$y0 + $offY * 5}]
  }
  if {[string index $::board::_data($w) $to] ne "."} {
    lset coord 2 [expr {$x1 - $offX * 5}]
    lset coord 3 [expr {$y1 - $offY * 5}]
  }

  if {$thickness < 1} {
    set thickness [expr {$length * $thickness}]
  }
  $pathName create line $coord -fill $color -arrow last -width $thickness \
    -arrowshape [lmap elem $arrowshape { expr {$elem * $thickness} }] \
    -tag [list mark arrows $tag]
}

proc ::board::mark::DrawArrow {pathName from to color} {
  ::board::mark::DrawArrowEx [winfo parent $pathName] $from $to $color 0.1 {3.3 3.3 1.0} "mark${from}:${to}"
}

# Draw an arrow to indicate the best move.
# It also eliminate any existing best move arrow.
# So, if moveUCI == "", it just deletes any existing best move arrow.
# TODO: draw a better arrow that has the alpha channel.
proc ::board::mark::DrawBestMove {w moveUCI} {
  set from [ ::board::sq [ string range $moveUCI 0 1 ] ]
  set to [ ::board::sq [ string range $moveUCI 2 3 ] ]
  ::board::mark::DrawArrowEx $w $from $to "#FF5E0E" 0.066 {3.6 4.8 2.0} "bestmove"
}

# ::board::mark::DrawRectangle --
# Draws a rectangle surrounding the square
proc ::board::mark::DrawRectangle { pathName square color pattern } {
  if {$square < 0  ||  $square > 63} { return }
  set box [::board::mark::GetBox $pathName $square]
  $pathName create rectangle [lindex $box 0] [lindex $box 1] [lindex $box 2] [lindex $box 3] \
      -outline $color -width $::highlightLastMoveWidth -dash $pattern -tag highlightLastMove
}

# ::board::mark::DrawNag --
# Display Nag/Text at the upper right corner of a square
proc ::board::mark::DrawNag { pathName square nag color} {
  if {$square < 0  ||  $square > 63} { return }
  set box [::board::mark::GetBox $pathName.bd $square]
  set bsize $::board::_size($pathName)
  set size [expr  $bsize / 5]
  set p(0) [expr [lindex $box 2] - $size]
  set p(1) [expr [lindex $box 1] - $size]
  set p(2) [expr $p(0) + 2 * $size]
  set p(3) [expr $p(1) + 2 * $size]
  set offsetX 0
  set offsetY 0
  #check for outside board
  if { $p(2) > [expr 8 * $bsize] } {
      set p(0) [expr $p(0) - $size]
      set p(2) [expr $p(2) - $size]
      set offsetX $size
  }
  if { $p(1) < 0 } {
      set p(1) [expr $p(1) + $size]
      set p(3) [expr $p(3) + $size]
      set offsetY $size
  }
  $pathName.bd create oval $p(0) $p(1) $p(2) $p(3) -outline $color -fill $color -tag highlightLastMove
  $pathName.bd create text [expr [lindex $box 2] - $offsetX] [expr [lindex $box 1] + $offsetY] -text $nag \
      -tag highlightLastMove -fill white -font [list font_Bold $size bold]
}

# ::board::mark::DrawTux --
#
image create photo tux16x16 -data \
    {R0lGODlhEAAQAPUyAAAAABQVFiIcBi0tLTc0Kj4+PkQ3CU9ADVVFD1hJFV1X
      P2pXFWJUKHttLnttOERERVVWWWRjYWlqcYNsGJR5GrSUIK6fXsKdGMCdI8er
      ItCuNtm2KuS6KebAKufBOvjJIfnNM/3TLP/aMP/lM+/We//lQ//jfoGAgJaU
      jpiYmqKipczBmv/wk97e3v//3Ojo6f/96P7+/v///wAAAAAAAAAAAAAAAAAA
      AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEBADIALAAAAAAQABAAAAbm
      QJlMJpMBAAAAQCaTyWQymUwmAwQAAQAAIJPJZDKZTCYDQCInCQAgk8lkMplM
      JgMwOBoHACCTyYAymUwmkwEao5IFAADIZDKZTCaTAVQu2GsAAMhkMplMJgMU
      YrFY7AQAAGQymUwmA6RisVjsFQAAATKZTCYDBF6xWCwWewAAAJlMJjMoYrFY
      LBaDAAAAmUwW+oBWsVgsxlokFgCZTBYChS6oWCxmAn5CHYNMJhOJQiFS7JXS
      iEQjCkAmw3BCow0hAMiMNggAQCYDAAyTAwAASEwEAABAJpPJAAAAAACUAQAA
      gEwmCwIAOw==}
set ::board::mark::tux16x16 tux16x16

image create photo tux32x32 -data \
    {R0lGODlhIAAgAPU0AAAAABANAxERESAaBiwkCDAnCSQkJEM2DEA3GVBBDllJ
      EFNKLG5aFHBbFHpkFnZoMkBAQFBQUGBgYHBwcIBpF4xyGZ+DHZ+GKqmKHq+T
      Lb+hNsynJNSuJtu0J9+6NeW8Kc+wQPnMLPTJMP7QLv/UO//aVf/dYv/ifIiI
      hp+fn6+vr7+/v//lif/ol//rpM/Pz9/f3//22O/u6v/55f///////wAAAAAA
      AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAACH5BAEBADUALAAAAAAgACAAAAb+
      wFqtVqvVarVarQYAAAAAAABQq9VqtVqtVqvVarVarVar1Wq1Wg0AAAAAAAAA
      AKjVarVarVar1YC1Wq1Wq9VqtVqtBgAAAAAAAAAAAGq1Wq1Wq9VqtVqtVqvV
      arVaDQAAAAAAAAAAAABqtVqtVqsBa7VarVar1Wq1Wq0GMMgighdtAgAAALVa
      rVar1Wq1Wq1Wq9VqtVqtBphEUpCUQQUAAAC1Wq1WA9ZqtVqtVqvVarVarVYD
      RBYejwahAgAAgFqtVqvVarVarVar1Wq1Wq1WAxRIIdFolAEAAABArQas1Wq1
      Wq1Wq9VqtVqtVqvVGqPRaDTSAAAAAKBWq9VqtVr+rVar1Wq1Wq1Wq9UMp9Fo
      xJIJAAAAAFir1Wq1Wq1Wq9VqtVqtVqvVABGaqzWj0SYAAAAAqNVqtVqtVqvV
      arVarVarAQQyGo1Go9FgAAAQAAAAarVarVar1Wq1Wq1WqwEAExqNRqPRaDSD
      AAAAAGq1Wq1Wq9VqtVqtVqsBAC8ajUaj0Wg0oAoAAAAAgFqtVqvVarVarVar
      AQACGo1Go9FoNBpNAAAAAIBarVar1Wq1Wq1WqwEAKhqNRqPRaEAajYYCAAAA
      AKBWq9VqtVqtVqvVAAIajUaj0Wg0Go22AgAAAACgVqvVarVarVarAQARGo1G
      o9GANBqNRpMBAAAAAAD+qNVqtVqtVqvVAAAUjUaj0Wg0Go1GowkAAAAAAKjV
      arVarVar1QgUFI1GowFpNBqNRqPRDAZDAAAA1Gq1Wq1Wq9VGo1HpRaPRaDQa
      jUY7iQAAwUMBANRqtVqtVhuFRqPR6LIC0mg0Go1Go5lGiYBlVAEAarVarVar
      jUaj0Wg0KqRoNBqNRqOZRqPRaPQBAGq1Wq1Wq41Go9FoBBxtADIajUaj0Uyj
      0Wg0Gn0YgFqtVqvVRqPRaDQajVw0Go1Go6VGo9FoNBqNOABArVar1Uaj0Qg4
      Go1GoxiNRntFBqPRaDQajT4KAKBWq9Vqo9FoNBqNRiOHASIAAAqj0Wg0CmGW
      AAAAoFar1WoYDlAUGo1Go1FFAAAAAInRaDT6EAAAAABQq9VqNQAAAHB0QqNO
      AQAAAACA0Gi0AQAAAECtVqvVajUgAAAAAAAAAAAAAAAAAAAAAAAAAIBarVar
      1Wq1Wq1WqwEAAAAAAKjVarUaAAAAAAC1Wq1Wq9VqwFqtVqvVarVarVar1Wq1
      Wq1Wq9VqtVqtVqvVarUgADs=
    }
set ::board::mark::tux32x32 tux32x32

proc ::board::mark::DrawTux {pathName square discard} {
  variable tux16x16
  variable tux32x32
  set box [::board::mark::GetBox $pathName $square]
  for {set len [expr {int([lindex $box 4])}]} {$len > 0} {incr len -1} {
    if {[info exists tux${len}x${len}]} break
  }
  if {!$len} return
  $pathName create image [lrange $box 5 6] \
      -image tux${len}x${len} \
      -tag [list mark "mark$square" tux]
}

# ::board::mark::GetBox --
#
#	Auxiliary function:
#	Get coordinates of an inner box for a specified square.
#
# Arguments:
#	pathName	Name of a canvas widget containing squares.
#	square		Square number (0..63).
#	portion		Portion (length inner box) / (length square)
#			(1.0 means: box == square).
# Results:
#	Returns a list whose elements are upper left and lower right
#	corners, length, and midpoint (x,y) of the inner box.
#
proc ::board::mark::GetBox {pathName square {portion 1.0}} {
  set coord [$pathName coords sq$square]
  set len [expr {[lindex $coord 2] - [lindex $coord 0]}]
  if {$portion < 1.0} {
    set dif [expr {$len * (1.0 -$portion) * 0.5}]
    foreach i {0 1} { lappend box [expr {[lindex $coord $i] + $dif}] }
    foreach i {2 3} { lappend box [expr {[lindex $coord $i] - $dif}] }
  } else {
    set box $coord
  }
  lappend box [expr { [lindex $box 2] - [lindex $box 0]     }]
  lappend box [expr {([lindex $box 0] + [lindex $box 2]) / 2}]
  lappend box [expr {([lindex $box 1] + [lindex $box 3]) / 2}]
  return $box
}

### End of namespace ::board::mark

# ::board::piece {w sq}
#   Given a board and square number, returns the piece type
#   (e for empty, wp for White Pawn, etc) of the square.
proc ::board::piece {w sq} {
  set p [string index $::board::_data($w) $sq]
  return $::board::letterToPiece($p)
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
  return $oldSq
}

proc ::board::getDragSquare {w} {
  return $::board::_drag($w)
}


# ::board::dragPiece
#   Drags the piece of the drag-square (as set above) to
#   the specified global (root-window) screen coordinates.
#
proc ::board::dragPiece {w x y} {
  set sq $::board::_drag($w)
  if {$sq < 0} { return }
  set x [expr {$x - [winfo rootx $w.bd]} ]
  set y [expr {$y - [winfo rooty $w.bd]} ]
  $w.bd coords p$sq $x $y
  $w.bd raise p$sq
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
  set psize $::board::_size($w)
  set flip $::board::_flip($w)
  # Compute the XY coordinates for the centre of the square:
  set midpoint [::board::midSquare $w $sq]
  set xc [lindex $midpoint 0]
  set yc [lindex $midpoint 1]
  # Delete any old image for this square, and add the new one:
  $w.bd delete p$sq
  $w.bd create image $xc $yc -image $::board::letterToPiece($piece)$psize -tag p$sq
}

# ::board::clearText
#   Remove all text annotations from the board.
#
proc ::board::clearText {w} {
  $w.bd delete texts
}

# ::board::drawText
#   Draws the specified text on the specified square.
#   Additional arguments are treated as canvas text parameters.
#
proc ::board::drawText {w sq text color args {shadow ""} } {
  mark::DrawText ${w}.bd $sq $text $color \
      [expr {[catch {font actual font_Bold -size} size] ? 11 : $size}] \
      $shadow
  #if {[llength $args] > 0} {
  #  catch {eval $w.bd itemconfigure text$sq $args}
  #}
}

# Highlight last move played by drawing a rectangle around the two squares and/or an arrow
proc  ::board::lastMoveHighlight {w moveuci {nag ""}} {
  $w.bd delete highlightLastMove
  if {[string length $moveuci] >= 4} {
    set moveuci [ string range $moveuci 0 3 ]
    set square1 [ ::board::sq [string range $moveuci 0 1 ] ]
    set square2 [ ::board::sq [string range $moveuci 2 3 ] ]
    if { $::highlightLastMove } {
        ::board::mark::DrawRectangle $w.bd $square1 $::highlightLastMoveColor $::highlightLastMovePattern
        ::board::mark::DrawRectangle $w.bd $square2 $::highlightLastMoveColor $::highlightLastMovePattern
    }
    if { $::arrowLastMove } {
        ::board::mark::DrawArrow $w.bd $square1 $square2 $::highlightLastMoveColor
    }
    if { $::highlightLastMoveNag && [regexp {[!?]+} $nag nag] } {
        # green background for ! !! !?  red background for ? ?? ?! 
        set color [expr {[string index $nag 0] eq "!" ? "#30c030" : "#ff3030"}]
        ::board::mark::DrawNag $w $square2 $nag $color
    }
  }
}

# ::board::update
#   Update the board given a 64-character board string as returned
#   by the "sc_pos board" command. If the board string is empty, it
#   defaults to the previous value for this board.
#   If the optional parameter "animate" is 1 and the changes from
#   the previous board state appear to be a valid chess move, the
#   move is animated.
#
proc ::board::update {w {board ""} {animate 0}} {
  set oldboard $::board::_data($w)
  if {$board == ""} {
    set board $::board::_data($w)
  } else {
    set ::board::_data($w) $board
  }
  set psize $::board::_size($w)

  # Cancel any current animation:
  after cancel "::board::_animate $w"

  # Remove all marks (incl. arrows) from the board:
  $w.bd delete mark

  # Draw each square:
  for {set sq 0} { $sq < 64 } { incr sq } {
    set piece [string index $board $sq]
    # Compute the XY coordinates for the centre of the square:
    set midpoint [::board::midSquare $w $sq]
    set xc [lindex $midpoint 0]
    set yc [lindex $midpoint 1]
    #update every square with color and texture
    set color [::board::defaultColor $sq]
    $w.bd itemconfigure sq$sq -fill $color -outline "" ; #-outline $color

    set boc bgd$psize
    if { ($sq + ($sq / 8)) % 2 } { set boc bgl$psize }
    $w.bd delete br$sq
    $w.bd create image $xc $yc -image $boc -tag br$sq

    # Delete any old image for this square, and add the new one:
    $w.bd delete p$sq
    $w.bd create image $xc $yc -image $::board::letterToPiece($piece)$psize -tag p$sq
  }
  if {$::board::_coords($w) >= 3 } {
      $w.bd raise innercoords
  }

  # Update side-to-move icon:
  ::board::sideToMove_ $w [string index $::board::_data($w) 65]

  # Gloss Of Danger:
  if { $::glossOfDanger } {
    foreach {sq col} [sc_pos attacks] {
      ::board::colorSquare $w $sq $col
    }
  }

  # Redraw marks and arrows if required:
  if {$::board::_showMarks($w)} {
    foreach mark $::board::_mark($w) {
      set type  [lindex $mark 0]
      if {$type == "full"}    {
        ::board::colorSquare $w [lindex $mark 1] [lindex $mark 3]
      } else {
        # Find a subroutine to draw the canvas object:
        set drawingScript "mark::Draw[string totitle $type]"
        if {[llength [info procs $drawingScript]]} {
          catch {eval $drawingScript $w.bd [join [lrange $mark 1 3]]}
        }
      }
    }
  }

  # Redraw last move highlight if mainboard
  if { $w == ".main.board"} {
    ::board::lastMoveHighlight $w [sc_game info previousMoveUCI] [sc_pos getNags]
  }

  # Redraw material values
  if {$::board::_showmat($w)} {
      ::board::material $w
  }

  # Animate board changes if requested:
  if {$animate  &&  $board != $oldboard} {
    ::board::animate $w $oldboard $board
  }
}

proc ::board::isFlipped {w} {
  return $::board::_flip($w)
}

# ::board::flipAuto
#   Sometimes SCID wants to automatically rotate the board,
#   i.e. when playing a game or loading a game with the "FlipB" flag set.
#   This function flip the board, but allow to restore the last state
#   (rotated, not rotated) selected by the user
#   @newstate:  0 ->white bottom
#               1 ->black bottom
#              -1 ->restore previous state
#
proc ::board::flipAuto {w {newstate -1}} {
  if {$newstate == -1} {
    if {[info exists ::board::flipAuto_($w)]} {::board::flip $w $::board::flipAuto_($w)}
    return
  }
  set tmp $::board::_flip($w)
  if {[info exists ::board::flipAuto_($w)]} { set tmp $::board::flipAuto_($w) }
  ::board::flip $w $newstate
  set ::board::flipAuto_($w) $tmp
}

# ::board::flip
#   Rotate the board 180 degrees.
#
proc ::board::flip {w {newstate -1}} {
  if {! [info exists ::board::_flip($w)]} { return }
  catch {unset ::board::flipAuto_($w)}
  if {$newstate == $::board::_flip($w)} { return }
  set flip [expr {1 - $::board::_flip($w)} ]
  set ::board::_flip($w) $flip

  # Swap squares:
  for {set i 0} {$i < 32} {incr i} {
    set swap [expr {63 - $i}]
    set coords(South) [$w.bd coords sq$i]
    set coords(North) [$w.bd coords sq$swap]
    $w.bd coords sq$i    $coords(North)
    $w.bd coords sq$swap $coords(South)
  }

  # Change coordinate labels:
  for {set i 1} {$i <= 8} {incr i} {
    set value [expr {9 - [$w.lrank$i cget -text]} ]
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
  ::board::flipNames_ $w $flip
  ::board::coords $w $::board::_coords($w)
  ::board::update $w
  ::board::drawEvalBar_ $w
  return $w
}
################################################################################
# ::board::material
# displays material balance
################################################################################
proc ::board::material {w} {
  set f $w.mat

  $f delete material

  set board [string range $::board::_data($w) 0 63]
  set p 0
  set n 0
  set b 0
  set r 0
  set q 0
  for {set i 0} {$i < [string length $board]} {incr i} {
    set ch [string index $board $i]
    switch -- $ch {
      p {incr p -1}
      P {incr p}
      n {incr n -1}
      N {incr n}
      b {incr b -1}
      B {incr b}
      r {incr r -1}
      R {incr r}
      q {incr q -1}
      Q {incr q}
    }
  }
  set sum [expr abs($p) + abs($n) +abs($b) +abs($r) +abs($q) ]
  set rank 0

  foreach pType {q r b n p} {
    set count [expr "\$$pType"]
    if {$count < 0} {
      addMaterial $count $pType $f $rank $sum
      incr rank [expr abs($count) ]
    }
  }
  foreach pType {q r b n p} {
    set count [expr "\$$pType"]
    if {$count > 0} {
      addMaterial $count $pType $f $rank $sum
      incr rank [expr abs($count) ]
    }
  }
}
proc ::board::addMaterial {count piece parent rank sum} {
  if {$count == 0} {return}
  if {$count <0} {
    set col "b"
    set count [expr 0 - $count ]
  } else  {
    set col "w"
  }
  set w [$parent cget -width]
  set h [$parent cget -height]
  set offset [expr ($h - ($sum * 20)) / 2]
  if {$offset <0} { set offset 0 }
  set x [expr $w / 2]
  for {set i 0} {$i<$count} {incr i} {
    set y [expr $rank * 20 +10 + $offset + $i * 20]
    $parent create image $x $y -image $col${piece}20 -tag material
  }
}
proc ::board::toggleMaterial {w} {
  set ::board::_showmat($w) [expr {1 - $::board::_showmat($w)}]
  if {$::board::_showmat($w)} {
    grid $w.mat
  } else {
    grid remove $w.mat
  }
  ::board::update $w
  return $::board::_showmat($w)
}

################################################################################
# draw coordinates on the board
# sq: square c: character pos: 0=left,bottom  1=right,top
# use dark and lite from colorscheme as fontcolor:
#     lite on dark squares and dark on lite squares
################################################################################
proc ::board::drawInnerCoords { w sq c pos fontsize color} {
    set box [::board::mark::GetBox $w.bd $sq 1.0]
    set len [expr int([lindex $box 4])]
    if { [string is digit $c] } {
        set x   [expr [lindex $box 0] + $pos * ($len - $fontsize)]
        set y   [expr [lindex $box 1] + $fontsize ]
    } else {
        set x   [expr [lindex $box 0] ]
        set y   [expr [lindex $box 3] - $fontsize - $pos * ($len - 2 * $fontsize)]
        # avoid collision a1 and h8 in the upper right square
        if { $pos && (($::board::_flip($w) && $c eq "h") || (!$::board::_flip($w) && $c eq "a")) } {
            set x [expr $x + $fontsize]
        }
    }
    $w.bd create text $x $y -fill $color \
        -font [list font_Regular $fontsize ] \
        -text $c \
        -anchor w \
        -tag innercoords
}

# ::board::innercoords
#   Add or remove coordinates on the square on the board.
#   0 (no coords), 1 (left and bottom beside board ), 2 (all sides beside board),
#   3 (left and bottom, on board ), 4 (all sides on board)
proc ::board::innercoords {w} {
    $w.bd delete innercoords
    if {$::board::_coords($w) < 3 } {
        return
    }
    # Use 20% of square for fontsize, but not larger than font_small
    set fontSize [expr int($::board::_size($w) / 5) ]
    set size [font configure font_Small -size]
    if { $fontSize > $size } { set fontSize $size }
    if { ! $::board::_flip($w) } {
        set ch_l [list a c e g 1 3 5 7]
        set ch_d [list b d f h 2 4 6 8]
        set sq_bl_l [list 0 2 4 6 0 16 32 48]
        set sq_tr_d [list 56 58 60 62 7 23 39 55]
        set sq_bl_d [list 1 3 5 7 8 24 40 56]
        set sq_tr_l [list 57 59 61 63 15 31 47 63]
    } else {
        set ch_d [list 1 3 5 7 a c e g]
        set ch_l [list h f d b 8 6 4 2]
        set sq_bl_d [list 7 23 39 55 56 58 60 62]
        set sq_tr_l [list 0 16 32 48 0 2 4 6]
        set sq_bl_l [list 63 61 59 57 63 47 31 15]
        set sq_tr_d [list 7 5 3 1 56 40 24 8]
    }
    if {$::board::_coords($w) >= 3 } {
        foreach sq $sq_bl_l ch $ch_l {
            drawInnerCoords $w $sq $ch 0 $fontSize $::squareColor_lite
        }
        foreach sq $sq_bl_d ch  $ch_d {
            drawInnerCoords $w $sq $ch 0 $fontSize $::squareColor_dark
        }
    }
    if {$::board::_coords($w) == 4 } {
        foreach sq $sq_tr_l ch $ch_d {
            drawInnerCoords $w $sq $ch 1 $fontSize $::squareColor_lite
        }
        foreach sq $sq_tr_d ch  $ch_l {
            drawInnerCoords $w $sq $ch 1 $fontSize $::squareColor_dark
        }
    }
}

# ::board::coords
#   Configure coordinates around the edge of the board or on the board
#   Toggle ::board::_coords between 0 (no coords), 1 (left and bottom beside board ),
#   2 (all sides beside board), 3 (left and bottom, on board ), 4 (all sides on board)
proc ::board::coords {w {coordstype ""}} {
  # if coordstype is set then use it, else toggle between options
  if { $coordstype eq "" } {
    set coordstype [expr {1 + $::board::_coords($w)} ]
    if { $coordstype > 4 } { set coordstype 0 }
  }
  if { $coordstype >= 0 && $coordstype <= 4 } {
    set ::board::_coords($w) $coordstype
  }

  if {$coordstype == 1 } {
    for {set i 1} {$i <= 8} {incr i} {
      grid configure $w.lrank$i
      grid remove $w.rrank$i
    }
    foreach i {a b c d e f g h} {
      grid remove $w.tfile$i
      grid configure $w.bfile$i
    }
  } elseif {$coordstype == 2 } {
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
  ::board::innercoords $w

  return $coordstype
}

# ::board::animate
#   Check for board changes that appear to be a valid chess move,
#   and start animating the move if applicable.
#
proc ::board::animate {w oldboard newboard} {
  global animateDelay
  if {$animateDelay <= 0} { return }

  # Find which squares differ between the old and new boards:
  set diffcount 0
  set difflist [list]
  for {set i 0} {$i < 64} {incr i} {
    if {[string index $oldboard $i] != [string index $newboard $i]} {
      incr diffcount
      lappend difflist $i
    }
  }

  # Check the number of differences could mean a valid move:
  if {$diffcount < 2  ||  $diffcount > 4} { return }

  for {set i 0} {$i < $diffcount} {incr i} {
    set sq($i) [lindex $difflist $i]
    set old($i) [string index $oldboard $sq($i)]
    set new($i) [string index $newboard $sq($i)]
  }

  set from -1
  set to -1
  set from2 -1
  set to2 -1
  set captured -1
  set capturedPiece "."

  if {$diffcount == 4} {
    # Check for making/unmaking a castling move:
    set castlingList [list 4 6 7 5 60 62 63 61 4 2 0 3 60 58 56 59]

    foreach {kfrom kto rfrom rto} $castlingList {
      if {[lsort $difflist] == [lsort [list $kfrom $kto $rfrom $rto]]} {
        if {[string tolower [string index $oldboard $kfrom]] == "k"  &&
          [string tolower [string index $oldboard $rfrom]] == "r"  &&
          [string tolower [string index $newboard $kto]] == "k"  &&
          [string tolower [string index $newboard $rto]] == "r"} {
          # A castling move animation.
          # Move the rook back to initial square until animation is complete:
          eval $w.bd coords p$rto [::board::midSquare $w $rfrom]
          set from $kfrom
          set to $kto
          set from2 $rfrom
          set to2 $rto
        } elseif {[string tolower [string index $newboard $kfrom]] == "k"  &&
          [string tolower [string index $newboard $rfrom]] == "r"  &&
          [string tolower [string index $oldboard $kto]] == "k"  &&
          [string tolower [string index $oldboard $rto]] == "r"} {
          eval $w.bd coords p$rfrom [::board::midSquare $w $rto]
          set from $kto
          set to $kfrom
          set from2 $rto
          set to2 $rfrom
        }
      }
    }
  }

  if {$diffcount == 3} {
    # Three squares are different, so check for an En Passant capture:
    foreach i {0 1 2} {
      foreach j {0 1 2} {
        foreach k {0 1 2} {
          if {$i == $j  ||  $i == $k  ||  $j == $k} { continue }
          # Check for an en passant capture from i to j with the enemy
          # pawn on k:
          if {$old($i) == $new($j) && $old($j) == "." && $new($k) == "."  &&
            (($old($i) == "p" && $old($k) == "P") ||
            ($old($i) == "P" && $old($k) == "p"))} {
            set from $sq($i)
            set to $sq($j)
          }
          # Check for undoing an en-passant capture from j to i with
          # the enemy pawn on k:
          if {$old($i) == $new($j) && $old($k) == "." && $new($i) == "."  &&
            (($old($i) == "p" && $new($k) == "P") ||
            ($old($i) == "P" && $new($k) == "p"))} {
            set from $sq($i)
            set to $sq($j)
            set captured $sq($k)
            set capturedPiece $new($k)
          }
        }
      }
    }
  }

  if {$diffcount == 2} {
    # Check for a regular move or capture: one old square should have the
    # same (non-empty) piece as the other new square, and at least one
    # of the old or new squares should be empty.

    if {$old(0) != "." && $old(1) != "." && $new(0) != "." && $new(1) != "."} {
      return
    }

    foreach i {0 1} {
      foreach j {0 1} {
        if {$i == $j} { continue }
        if {$old($i) == $new($j)  &&  $old($i) != "."} {
          set from $sq($i)
          set to $sq($j)
          set captured $sq($j)
          set capturedPiece $old($j)
        }

        # Check for a (white or black) pawn promotion from i to j:
        if {($old($i) == "P"  &&  [string is upper $new($j)]  &&
          $sq($j) >= [sq a8]  &&  $sq($j) <= [sq h8])  ||
          ($old($i) == "p"  &&  [string is lower $new($j)]  &&
          $sq($j) >= [sq a1]  &&  $sq($j) <= [sq h1])} {
          set from $sq($i)
          set to $sq($j)
        }

        # Check for undoing a pawn promotion from j to i:
        if {($new($j) == "P"  &&  [string is upper $old($i)]  &&
          $sq($i) >= [sq a8]  &&  $sq($i) <= [sq h8])  ||
          ($new($j) == "p"  &&  [string is lower $old($i)]  &&
          $sq($i) >= [sq a1]  &&  $sq($i) <= [sq h1])} {
          set from $sq($i)
          set to $sq($j)
          set captured $sq($j)
          set capturedPiece $old($j)
        }
      }
    }
  }

  # Check that we found a valid-looking move to animate:
  if {$from < 0  ||  $to < 0} { return }

  # Redraw the captured piece during the animation if necessary:
  if {$capturedPiece != "."  &&  $captured >= 0} {
    ::board::drawPiece $w $from $capturedPiece
    eval $w.bd coords p$from [::board::midSquare $w $captured]
  }

  # Move the animated piece back to its starting point:
  eval $w.bd coords p$to [::board::midSquare $w $from]
  $w.bd raise p$to

  # Start the animation:
  set start [clock clicks -milli]
  set ::board::_animate($w,start) $start
  set ::board::_animate($w,end) [expr {$start + $::animateDelay} ]
  set ::board::_animate($w,from) $from
  set ::board::_animate($w,to) $to
  set ::board::_animate($w,from2) $from2
  set ::board::_animate($w,to2) $to2
  ::board::_animate $w
}

# ::board::_animate
#   Internal procedure for updating a board move animation.
#
proc ::board::_animate {w} {
  if {! [winfo exists $w]} { return }
  set from $::board::_animate($w,from)
  set to $::board::_animate($w,to)
  set start $::board::_animate($w,start)
  set end $::board::_animate($w,end)
  set now [clock clicks -milli]
  if {$now > $end} {
    ::board::update $w
    return
  }

  # Compute where the moving piece should be displayed and move it:
  set ratio [expr {double($now - $start) / double($end - $start)} ]
  set fromMid [::board::midSquare $w $from]
  set toMid [::board::midSquare $w $to]
  set fromX [lindex $fromMid 0]
  set fromY [lindex $fromMid 1]
  set toX [lindex $toMid 0]
  set toY [lindex $toMid 1]
  set x [expr {$fromX + round(($toX - $fromX) * $ratio)} ]
  set y [expr {$fromY + round(($toY - $fromY) * $ratio)} ]
  $w.bd coords p$to $x $y
  $w.bd raise p$to
  if { $::board::_animate($w,from2) >= 0 } {
      # move second piece
      set from $::board::_animate($w,from2)
      set to $::board::_animate($w,to2)
      set fromMid [::board::midSquare $w $from]
      set toMid [::board::midSquare $w $to]
      set fromX [lindex $fromMid 0]
      set fromY [lindex $fromMid 1]
      set toX [lindex $toMid 0]
      set toY [lindex $toMid 1]
      set x [expr {$fromX + round(($toX - $fromX) * $ratio)} ]
      set y [expr {$fromY + round(($toY - $fromY) * $ratio)} ]
      $w.bd coords p$to $x $y
      $w.bd raise p$to
  }

  # Schedule another animation update in a few milliseconds:
  after 5 "::board::_animate $w"
}

proc InitBoard {} {
  # Ensure that the current board style is valid:
  if {[lsearch -exact "$::boardStyles" "$::boardStyle"] == -1} {
    set ::boardStyle [lindex $::boardStyles 0]
  }

  setPieceFont "$::boardStyle"
}
InitBoard


###
### End of file: board.tcl
###
