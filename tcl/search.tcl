###
### search.tcl: Search routines for Scid.
###

# searchType: set to Header or Material in a SearchOptions file
set searchType 0


# search_addFilterOpFrame:
#   Adds a search filter operation selection frame to the window.
#   Adds a frame of radiobuttons allowing the filter operation
#   (AND with current filter, OR with current filter, or RESET filter)
#   to be chosen.
#   The default value for the first search is RESET:
set filterOp 2

proc search_addFilterOpFrame {w {small 0}} {
  global filterOp
  frame $w.filterop
  set f $w.filterop
  pack $f -side top
  set regular font_Regular
  set bold font_Bold
  if {$small} {
    set regular font_Small
    set bold font_SmallBold
  }
  label $f.title -font $bold -textvar ::tr(FilterOperation)
  radiobutton $f.and -textvar ::tr(FilterAnd) -variable filterOp \
    -value 0 -indicatoron 0 -pady 5 -padx 5 -font $regular
  radiobutton $f.or -textvar ::tr(FilterOr) -variable filterOp \
    -value 1 -indicatoron 0 -pady 5 -padx 5 -font $regular
  radiobutton $f.ignore -textvar ::tr(FilterIgnore) -variable filterOp \
    -value 2 -indicatoron 0 -pady 5 -padx 5 -font $regular
  pack $f.title -side top
  pack $f.and $f.or $f.ignore -side left
}


########################################
### BOARD searching

set searchInVars 0
set sBoardIgnoreCols 0
set sBoardSearchType Exact

# searchBoard:
#   Searches for the current board position.
#
proc searchBoard {} {
  global glstart filterOp searchInVars sBoardType sBoardIgnoreCols

  set w .sb
  if {[winfo exists $w]} {
    wm deiconify $w
    raiseWin $w
    return
  }

  toplevel $w
  wm title $w "Scid: $::tr(BoardSearch)"

  bind $w <Escape> "$w.b.cancel invoke"
  bind $w <Return> "$w.b.search invoke"
  bind $w <F1> { helpWindow Searches Board }

  label $w.type -textvar ::tr(SearchType) -font font_Bold
  pack $w.type -side top
  pack [frame $w.g] -side top -fill x
  radiobutton $w.g.exact -textvar ::tr(SearchBoardExact) \
    -variable sBoardSearchType -value Exact
  radiobutton $w.g.pawns -textvar ::tr(SearchBoardPawns) \
    -variable sBoardSearchType -value Pawns
  radiobutton $w.g.files -textvar ::tr(SearchBoardFiles) \
    -variable sBoardSearchType -value Fyles
  radiobutton $w.g.material -textvar ::tr(SearchBoardAny) \
    -variable sBoardSearchType -value Material
  set row 0
  foreach i {exact pawns files material} {
    grid $w.g.$i -row $row -column 0 -sticky w
    incr row
  }
  addHorizontalRule $w

  search_addFilterOpFrame $w
  addHorizontalRule $w

  ### Progress bar:

  canvas $w.progress -height 20 -width 300 -bg white -relief solid -border 1
  $w.progress create rectangle 0 0 0 0 -fill blue -outline blue -tags bar
  $w.progress create text 295 10 -anchor e -font font_Regular -tags time \
    -fill black -text "0:00 / 0:00"

  frame $w.b
  pack $w.b -side top -ipady 5 -fill x
  checkbutton $w.b.vars -textvar ::tr(LookInVars) -padx 10 -pady 5 \
    -onvalue 1 -offvalue 0 -variable searchInVars -relief raised
  checkbutton $w.b.flip -textvar ::tr(IgnoreColors) -padx 10 -pady 5 \
    -onvalue 1 -offvalue 0 -variable sBoardIgnoreCols -relief raised

  button $w.b.stop -textvar ::tr(Stop) -command sc_progressBar
  $w.b.stop configure -state disabled

  button $w.b.search -textvar ::tr(Search) -command {
    busyCursor .
    .sb.b.stop configure -state normal
    grab .sb.b.stop
    sc_progressBar .sb.progress bar 301 21 time
    set str [sc_search board $filterOp $sBoardSearchType $searchInVars \
              $sBoardIgnoreCols]
    unbusyCursor .
    grab release .sb.b.stop
    .sb.b.stop configure -state disabled
    #tk_messageBox -type ok -title $::tr(SearchResults) -message $str
    .sb.status configure -text $str
    set glstart 1
    updateGList
    updateStatsWin
  }
  button $w.b.cancel -textvar ::tr(Close) -command "focus .; destroy $w"
  pack $w.b.vars $w.b.flip -side left -pady 5 -padx 5
  pack $w.b.cancel .sb.b.search .sb.b.stop -side right -pady 5 -padx 5
  pack $w.progress -side top -pady 2
  label $w.status -text "" -width 1 -font font_Small -relief sunken -anchor w
  pack $w.status -side bottom -fill x
  wm resizable $w 0 0
  standardShortcuts $w
  configSearchState
  focus $w.b.search
}

########################################
### MATERIAL searching

set ignoreColors 0
set minMoveNum 1
set maxMoveNum 999
set minHalfMoves 1
set oppBishops "Either"
set minMatDiff -40
set maxMatDiff +40

trace variable minMoveNum w {forceInt 999 0}
trace variable maxMoveNum w {forceInt 999 0}
trace variable minHalfMoves w {forceInt 99 0}
trace variable minMatDiff w {forceInt -99 0}
trace variable maxMatDiff w {forceInt -99 0}

set nPatterns 9

array set pMin [list wq 0 bq 0 wr 0 br 0 wb 0 bb 0 wn 0 bn 0 wm 0 bm 0 wp 0 bp 0]
array set pMax [list wq 2 bq 2 wr 2 br 2 wb 2 bb 2 wn 2 bn 2 wm 4 bm 4 wp 8 bp 8]
for { set i 1 } { $i <= $nPatterns } { incr i } {
  set pattPiece($i) "?";  set pattFyle($i) "?";  set pattRank($i) "?"
}

proc checkPieceCounts {name el op} {
  global pMin pMax
  forceInt 9 0 $name $el $op
  # Now make sure minor piece counts fit with bishop/knight counts:
  set wmMin [expr {$pMin(wn) + $pMin(wb)} ]
  set wmMax [expr {$pMax(wn) + $pMax(wb)} ]
  set bmMin [expr {$pMin(bn) + $pMin(bb)} ]
  set bmMax [expr {$pMax(bn) + $pMax(bb)} ]
  if {$pMin(wm) < $wmMin} { set pMin(wm) $wmMin }
  if {$pMax(wm) > $wmMax} { set pMax(wm) $wmMax }
  if {$pMin(bm) < $bmMin} { set pMin(bm) $bmMin }
  if {$pMax(bm) > $bmMax} { set pMax(bm) $bmMax }
  foreach p {wq wr wb wn wm wp bq br bb bn bm bp} {
    if {$pMax($p) != ""  &&  $pMax($p) < $pMin($p)} { set pMax($p) $pMin($p) }
  }
}

trace variable pMin w checkPieceCounts
trace variable pMax w checkPieceCounts


proc makePieceMenu {w varName} {
  global dark
  upvar #0 $varName var
  if {![info exists var]} { set var "?" }
  menubutton $w -textvariable $varName -indicatoron 0 -menu $w.menu \
    -relief raised -bd 2 -highlightthickness 2 -anchor w -image ""
  menu $w.menu -tearoff 0
  $w.menu add radiobutton -label " ? " -variable $varName -value "?" \
    -command "$w configure -image e20" -hidemargin 1
  foreach i {wk wq wr wb wn wp bk bq br bb bn bp} {
    $w.menu add radiobutton -label $i -image ${i}20 -value $i \
      -variable $varName \
      -command "$w configure -image ${i}20" -hidemargin 1
  }
  foreach i {" ? " wk bk} {
    $w.menu entryconfigure $i -columnbreak 1
  }
  return $w.menu
}

proc updatePatternImages {} {
  global pattPiece nPatterns
  if {! [winfo exists .sm]} { return }
  for {set i 1} {$i <= $nPatterns} {incr i} {
    if {$pattPiece($i) == "?"} {
      .sm.patt.p$i configure -image e20
    } else {
      .sm.patt.p$i configure -image "$pattPiece($i)20"
    }
  }
}

# zeroMaterial:
#   Called to clear all material minumum/maximum values to zero.
#
proc zeroMaterial {} {
  global pMin pMax
  array set pMin {wq 0 bq 0 wr 0 br 0 wb 0 bb 0 wn 0 bn 0 wm 0 bm 0 wp 0 bp 0}
  array set pMax {wq 0 bq 0 wr 0 br 0 wb 0 bb 0 wn 0 bn 0 wm 0 bm 0 wp 0 bp 0}
}

proc anyMaterial {} {
  global pMin pMax
  array set pMin {wq 0 bq 0 wr 0 br 0 wb 0 bb 0 wn 0 bn 0 wm 0 bm 0 wp 0 bp 0}
  array set pMax {wq 2 bq 2 wr 2 br 2 wb 2 bb 2 wn 2 bn 2 wm 4 bm 4 wp 8 bp 8}
  set ::minMatDiff -40
  set maxMatDiff +40
}

proc clearPatterns {} {
  global pattPiece pattFyle pattRank pattBool nPatterns

  for { set i 1 } { $i <= $nPatterns } { incr i } {
    set pattPiece($i) "?";  set pattFyle($i) "?";  set pattRank($i) "?"
    set pattBool($i) "Yes"
  }
  updatePatternImages
}

proc setPatterns {pattlist} {
  global pattPiece pattFyle pattRank pattBool nPatterns

  clearPatterns
  set count 1
  foreach patt $pattlist {
    if {$count <= $nPatterns  &&  [llength $patt] == 4} {
      set pattPiece($count) [lindex $patt 0]
      set pattFyle($count) [lindex $patt 1]
      set pattRank($count) [lindex $patt 2]
      set pattBool($count) [lindex $patt 3]
      incr count
    }
  }
  updatePatternImages
}

set smDisplayed(Material) 1
set smDisplayed(Patterns) 0

# searchMaterial:
#   Search by material or patterns.
#
proc searchMaterial {} {
  global glstart dark pMin pMax ignoreColors filterOp minMoveNum maxMoveNum
  global pattPiece pattFyle pattRank pattBool oppBishops nPatterns
  global minHalfMoves smDisplayed

  set w .sm
  if {[winfo exists $w]} {
    wm deiconify $w
    raiseWin $w
    return
  }
  set small font_Small

  toplevel $w
  wm title $w "Scid: $::tr(MaterialSearch)"
  button $w.piecelabel -font font_Bold -textvar ::tr(Material:) -command {
    if {$smDisplayed(Material)} {
      set smDisplayed(Material) 0
      pack forget .sm.q .sm.r .sm.b .sm.n .sm.m .sm.p .sm.b1 .sm.mdiff
    } else {
      set smDisplayed(Material) 1
      pack .sm.q .sm.r .sm.b .sm.n .sm.m .sm.p .sm.b1 .sm.mdiff \
        -after .sm.piecelabel
    }
  }
  pack $w.piecelabel -side top
  foreach piece {q r b n m p} {
    frame $w.$piece
    pack $w.$piece -side top -padx 2
  }

  bind $w <F1> { helpWindow Searches Material }
  bind $w <Escape> "$w.b3.cancel invoke"
  bind $w <Return> "$w.b3.search invoke"

  foreach i {q r b n m p} {
    set f $w.$i
    button $f.w0 -text "0" -command "set pMin(w$i) 0; set pMax(w$i) 0"
    button $f.w1 -text "1" -command "set pMin(w$i) 1; set pMax(w$i) 1"
    button $f.w2 -text "2" -command "set pMin(w$i) 2; set pMax(w$i) 2"
    button $f.wa -text "0+" -command "set pMin(w$i) 0; set pMax(w$i) 2"
    button $f.w1p -text "1+" -command "set pMin(w$i) 1; set pMax(w$i) 2"
    label $f.wi -image w${i}20 -font font_Small
    label $f.wto -text "-" -font font_Small -padx 0
    entry $f.wmin -width 2 -relief sunken -textvar pMin(w$i) -font font_Small \
      -justify right
    entry $f.wmax -width 2 -relief sunken -textvar pMax(w$i) -font font_Small \
      -justify right
    pack $f.w0 $f.w1 $f.w2 $f.wa $f.w1p $f.wi $f.wmin $f.wto $f.wmax -side left

    pack [frame $f.space -width 20] -side left
    button $f.b0 -text "0" -command "set pMin(b$i) 0; set pMax(b$i) 0"
    button $f.b1 -text "1" -command "set pMin(b$i) 1; set pMax(b$i) 1"
    button $f.b2 -text "2" -command "set pMin(b$i) 2; set pMax(b$i) 2"
    button $f.ba -text "0+" -command "set pMin(b$i) 0; set pMax(b$i) 2"
    button $f.b1p -text "1+" -command "set pMin(b$i) 1; set pMax(b$i) 2"
    label $f.bi -image b${i}20 -font font_Small
    label $f.bto -text "-" -font font_Small
    entry $f.bmin -width 2 -relief sunken -textvar pMin(b$i) -font font_Small \
      -justify right
    entry $f.bmax -width 2 -relief sunken -textvar pMax(b$i) -font font_Small \
      -justify right
    pack $f.b0 $f.b1 $f.b2 $f.ba $f.b1p $f.bi $f.bmin $f.bto $f.bmax -side left

    foreach b {0 1 2 a 1p} {
      $f.w$b configure -width 4 -padx 1 -pady 3 -takefocus 0 -font $small
      $f.b$b configure -width 4 -padx 1 -pady 3 -takefocus 0 -font $small
    }
    foreach widget {wmin wmax bmin bmax} {
      bindFocusColors $f.$widget
    }
  }

  $w.p.w1p configure -command "set pMin(wp) 1; set pMax(wp) 8"
  $w.p.wa configure -command "set pMin(wp) 0; set pMax(wp) 8"
  $w.p.b1p configure -command "set pMin(bp) 1; set pMax(bp) 8"
  $w.p.ba configure -command "set pMin(bp) 0; set pMax(bp) 8"

  $w.m.w1p configure -command "set pMin(wp) 1; set pMax(wp) 4"
  $w.m.wa configure -command "set pMin(wp) 0; set pMax(wp) 4"
  $w.m.b1p configure -command "set pMin(bp) 1; set pMax(bp) 4"
  $w.m.ba configure -command "set pMin(bp) 0; set pMax(bp) 4"

  # Buttons that manipulate material settings:
  set f $w.b1
  pack [frame $f] -side top -ipady 2

  button $f.zero -textvar ::tr(Zero) -font $small -command zeroMaterial
  button $f.reset -textvar ::tr(Any) -font $small -command anyMaterial
  button $f.current -textvar ::tr(CurrentBoard) -font $small -command {
      zeroMaterial
      set bd [sc_pos board]
      for {set i 0} {$i < 64} {incr i} {
        set piece $images([ string index $bd $i ])
        if {$piece != "e"  &&  $piece != "wk"  &&  $piece != "bk"} {
          incr pMin($piece); set pMax($piece) $pMin($piece)
        }
      }
    }

  menubutton .sm.b1.common -textvar ::tr(CommonEndings...) \
    -menu .sm.b1.common.m -relief raised -font $small
  menu .sm.b1.common.m -font $small
  set m .sm.b1.common.m
  $m add command -label "Pawn(s) --- Pawn(s)" -command {
    zeroMaterial
    array set pMin {wp 1 bp 1}
    array set pMax {wp 8 bp 8}
  }
  $m add command -label "Rook --- Pawn(s)" -command {
    zeroMaterial
    array set pMin {wr 1 bp 1}
    array set pMax {wr 1 bp 8}
  }
  $m add command -label "Rook + 1 Pawn --- Rook" -command {
    zeroMaterial
    array set pMin {wr 1 br 1 wp 1}
    array set pMax {wr 1 br 1 wp 1}
  }
  $m add command -label "Rook + Pawn(s) --- Rook" -command {
    zeroMaterial
    array set pMin {wr 1 br 1 wp 1}
    array set pMax {wr 1 br 1 wp 8}
  }
  $m add command -label "Rook vs. Rook endings" -command {
    zeroMaterial
    array set pMin {wr 1 br 1}
    array set pMax {wr 1 br 1 wp 8 bp 8}
    set pMin(wr) 1; set pMax(wr) 1; set pMin(wp) 0; set mPax(wp) 8
    set pMin(br) 1; set pMax(br) 1; set pMin(bp) 0; set mPax(bp) 8
  }
  $m add command -label "Rook vs. Rook: passed a-pawn" -command {
    zeroMaterial
    array set pMin {wr 1 br 1 wp 1}
    array set pMax {wr 1 br 1 wp 8 bp 8}
    setPatterns {{wp a ? Yes} {bp a ? No} {bp b ? No}}
    set ignoreColors 1
  }
  $m add command -label "Double Rooks endings" -command {
    zeroMaterial
    array set pMin {wr 2 br 2}
    array set pMax {wr 2 br 2 wp 8 bp 8}
  }
  $m add command -label "Bishop vs. Bishop endings" -command {
    zeroMaterial
    array set pMin {wb 1 bb 1 wm 1 bm 1}
    array set pMax {wb 1 bb 1 wm 1 bm 1 wp 8 bp 8}
  }
  $m add command -label "Bishop vs. Knight endings" -command {
    zeroMaterial
    array set pMin {wb 1 bn 1 wm 1 bm 1}
    array set pMax {wb 1 bn 1 wm 1 bm 1 wp 8 bp 8}
  }
  $m add command -label "Knight vs. Knight endings" -command {
    zeroMaterial
    array set pMin {wn 1 bn 1 wm 1 bm 1}
    array set pMax {wn 1 bn 1 wm 1 bm 1 wp 8 bp 8}
  }
  $m add command -label "Queen + 1 Pawn --- Queen" -command {
    zeroMaterial
    array set pMin {wq 1 bq 1 wp 1}
    array set pMax {wq 1 bq 1 wp 1}
  }
  $m add command -label "Queen vs. Queen endings" -command {
    zeroMaterial
    array set pMin {wq 1 bq 1}
    array set pMax {wq 1 bq 1 wp 8 bp 8}
  }
  $m add command -label "2B vs. 2N middlegame" -command {
    zeroMaterial
    array set pMin {wb 2 bn 2 wm 2 bm 2}
    array set pMax {wq 1 bq 1 wr 2 br 2 wb 2 bn 2 wm 2 bm 2 wp 8 bp 8}
  }

  pack $f.zero $f.reset $f.current $f.common -side left -pady 5 -padx 10
  if {! $smDisplayed(Material)} {
    pack forget .sm.q .sm.r .sm.b .sm.n .sm.m .sm.p .sm.b1 .sm.mdiff
  }

  set f $w.mdiff
  pack [frame $f] -side top
  label $f.label -font font_SmallBold -textvar ::tr(MaterialDiff)
  label $f.label2 -font $small \
    -text "($::tr(White)-$::tr(Black), Q=9 R=5 B=N=3 P=1): "
  entry $f.min -width 3 -relief sunken -textvar minMatDiff -font $small \
    -justify right
  bindFocusColors $f.min
  label $f.sep -text "-" -font $small
  entry $f.max -width 3 -relief sunken -textvar maxMatDiff -font $small \
    -justify right
  bindFocusColors $f.max
  label $f.sep2 -text " " -font $small
  button $f.any -textvar ::tr(Any) -font $small -padx 1 -pady 1 \
    -command {set minMatDiff -40; set maxMatDiff +40}
  button $f.w1 -text " + " -font $small -padx 1 -pady 1 \
    -command {set minMatDiff +1; set maxMatDiff +40}
  button $f.equal -text " = " -font $small -padx 1 -pady 1 \
    -command {set minMatDiff 0; set maxMatDiff 0}
  button $f.b1 -text " - " -font $small -padx 1 -pady 1 \
    -command {set minMatDiff -40; set maxMatDiff -1}
  pack $f.label $f.label2 $f.min $f.sep $f.max -side left
  pack $f.sep2 $f.any $f.w1 $f.equal $f.b1 -side left

  addHorizontalRule $w

  button $w.pattl -font font_Bold -textvar ::tr(Patterns:) -command {
    if {$smDisplayed(Patterns)} {
      set smDisplayed(Patterns) 0
      pack forget .sm.patt .sm.b2
    } else {
      set smDisplayed(Patterns) 1
      pack .sm.patt .sm.b2 -after .sm.pattl
    }
  }
  pack $w.pattl -side top
  set f $w.patt
  frame $f
  pack $f -ipady 5 -side top
  for { set i 1 } { $i <= $nPatterns } { incr i } {
    tk_optionMenu $f.b$i pattBool($i) "Yes" "No"
    set menuPiece1 [ makePieceMenu .sm.patt.p$i pattPiece($i) ]
    tk_optionMenu $f.f$i pattFyle($i) "?" a b c d e f g h
    tk_optionMenu $f.r$i pattRank($i) "?" 1 2 3 4 5 6 7 8
    $f.b$i configure -indicatoron 0 -width 4
    $f.f$i configure -indicatoron 0 -width 2
    $f.r$i configure -indicatoron 0 -width 2
    set column [expr {5 * (($i - 1) / 3)} ]
    set row [expr {($i - 1) % 3} ]
    grid $f.b$i -row $row -column $column; incr column
    grid $f.p$i -row $row -column $column; incr column
    grid $f.f$i -row $row -column $column; incr column
    grid $f.r$i -row $row -column $column; incr column
    if {$column == 4  ||  $column == 9} {
      label $f.sp_$i -text "  "
      grid $f.sp_$i -row $row -column $column
    }
  }

  updatePatternImages

  ### Buttons that manipulate patterns:
  set f .sm.b2
  frame $f
  button $f.clearPat -textvar ::tr(Clear) -command clearPatterns
  menubutton $f.common -textvar ::tr(CommonPatterns) \
    -menu $f.common.m -relief raised -font $small
  menu $f.common.m -font $small
  $f.common.m add command -label "White IQP" -command {
    if {$pMin(wp) < 1} { set pMin(wp) 1 }
    setPatterns {{wp d ? Yes} {wp c ? No} {wp e ? No}}
  }
  $f.common.m add command -label "White IQP: d4-d5 break vs e6" -command {
    if {$pMin(wp) < 1} { set pMin(wp) 1 }
    if {$pMin(bp) < 1} { set pMin(bp) 1 }
    setPatterns {{wp d 5 Yes} {wp c ? No} {wp e ? No} {wp d 4 No} \
                   {bp e 6 Yes} {bp c ? No} {bp d ? No}}
  }
  $f.common.m add command -label "Black IQP" -command {
    if {$pMin(bp) < 1} { set pMin(bp) 1 }
    setPatterns {{bp d ? Yes} {bp c ? No} {bp e ? No}}
  }
  $f.common.m add command -label "White IQP + Black IQP" -command {
    if {$pMin(wp) < 1} { set pMin(wp) 1 }
    if {$pMin(bp) < 1} { set pMin(bp) 1 }
    setPatterns {{wp d ? Yes} {wp c ? No} {wp e ? No} \
                   {bp d ? Yes} {bp c ? No} {bp e ? No}}
  }
  $f.common.m add command -label "White c3+d4 isolated pawn couple" -command {
    set pMin(wp) 4; set pMax(wp) 6
    set pMin(bp) 4; set pMax(bp) 6
    setPatterns {{wp c 3 Yes} {wp d 4 Yes} {wp b ? No} {wp e ? No}
      {bp c ? No} {bp d ? No}}
  }
  $f.common.m add command -label "Hanging Black c5+d5 pawns" -command {
    set pMin(bp) 4; set pMax(bp) 6
    set pMin(wp) 4; set pMax(wp) 6
    setPatterns {{bp c 5 Yes} {bp d 5 Yes} {bp b ? No} {bp e ? No}
      {wp c ? No} {wp d ? No}}
  }
  $f.common.m add command -label "Maroczy center" -command {
    if {$pMin(bp) < 1} { set pMin(bp) 1 }
    if {$pMax(bp) > 7} { set pMax(bp) 7 }
    if {$pMin(wp) < 2} { set pMin(wp) 2 }
    if {$pMax(wp) > 7} { set pMax(wp) 7 }
    setPatterns {{wp c 4 Yes} {wp e 4 Yes} {bp d ? Yes} {wp d ? No}
                 {bp c ? No} {bp d 5 No}}
  }
  $f.common.m add command -label "Rook-sac on c3" -command {
    set pMin(br) 2; set pMax(br) 2
    set pMin(wr) 2; set pMax(wr) 2
    setPatterns { {br c 3 Yes} {wp b 2 Yes} }
  }
  $f.common.m add command -label "White Kc1; Black Kg8" -command {
    setPatterns { {wk c 1 Yes} {bk g 8 Yes} }
  }
  $f.common.m add command -label "White Kg1; Black Kc8" -command {
    setPatterns { {wk g 1 Yes} {bk c 8 Yes} }
  }
  $f.common.m add command -label "4 fianchettos" -command {
    set pMin(wb) 2; set pMin(bb) 2
    setPatterns { {wb b 2 Yes} {wb g 2 Yes} {bb b 7 Yes} {bb g 7 Yes} }
  }

  pack $f -side top
  pack $f.clearPat $f.common -side left -pady 5 -padx 10
  if {! $smDisplayed(Patterns)} {
    pack forget $w.patt $w.b2
  }

  addHorizontalRule $w

  ### Now the move counter:

  set f $w.bishops
  pack [frame $f] -side top
  label $f.t1 -text "1"
  label $f.t2 -image wb20
  label $f.t3 -text "- 1"
  label $f.t4 -image bb20
  label $f.t5 -textvar ::tr(squares:)
  radiobutton $f.same -textvar ::tr(SameColor) -variable oppBishops \
    -value "Same" -indicatoron 0 -pady 5 -padx 5
  radiobutton $f.opp -textvar ::tr(OppColor) -variable oppBishops \
    -value "Opposite" -indicatoron 0 -pady 5 -padx 5
  radiobutton $f.either -textvar ::tr(Either) -variable oppBishops \
    -value "Either" -indicatoron 0 -pady 5 -padx 5
  foreach i {t1 t2 t3 t4 t5 same opp either} { pack $f.$i -side left }

  set f $w.move
  pack [frame $f] -side top -ipady 5
  label $f.fromlab -textvar ::tr(MoveNumberRange:)
  entry $f.from -width 4 -relief sunken -textvar minMoveNum -justify right
  label $f.tolab -text "-"
  entry $f.to -width 4 -relief sunken -textvar maxMoveNum -justify right
  label $f.space -text "  "
  label $f.label1 -textvar ::tr(MatchForAtLeast)
  entry $f.hmoves -width 3 -relief sunken -textvar minHalfMoves -justify right
  label $f.label2 -textvar ::tr(HalfMoves)
  bindFocusColors $f.from
  bindFocusColors $f.to
  bindFocusColors $f.hmoves
  pack $f.fromlab $f.from $f.tolab $f.to $f.space \
    $f.label1 $f.hmoves $f.label2 -side left

  addHorizontalRule $w
  search_addFilterOpFrame $w 1
  addHorizontalRule $w

  ### Progress bar:

  canvas $w.progress -height 20 -width 300 -bg white -relief solid -border 1
  $w.progress create rectangle 0 0 0 0 -outline blue -fill blue -tags bar
  $w.progress create text 295 10 -anchor e -font font_Regular -tags time \
    -fill black -text "0:00 / 0:00"

  ### Last of all, the buttons frame:

  set f $w.b3
  pack [frame $f] -side top -ipady 5 -fill x
  checkbutton $f.ignorecol -textvar ::tr(IgnoreColors) \
    -variable ignoreColors -relief raised -padx 8 -pady 5

  button $f.save -textvar ::tr(Save...) -padx 10 -command saveMaterialSearch

  button $f.stop -textvar ::tr(Stop) -command sc_progressBar
  $f.stop configure -state disabled

  button $f.search -textvar ::tr(Search) -padx 20 -command {
    busyCursor .
    .sm.b3.stop configure -state normal
    grab .sm.b3.stop
    sc_progressBar .sm.progress bar 301 21 time
    set str [sc_search material \
               -wq [list $pMin(wq) $pMax(wq)] -bq [list $pMin(bq) $pMax(bq)] \
               -wr [list $pMin(wr) $pMax(wr)] -br [list $pMin(br) $pMax(br)] \
               -wb [list $pMin(wb) $pMax(wb)] -bb [list $pMin(bb) $pMax(bb)] \
               -wn [list $pMin(wn) $pMax(wn)] -bn [list $pMin(bn) $pMax(bn)] \
               -wm [list $pMin(wm) $pMax(wm)] -bm [list $pMin(bm) $pMax(bm)] \
               -wp [list $pMin(wp) $pMax(wp)] -bp [list $pMin(bp) $pMax(bp)] \
               -flip $ignoreColors -filter $filterOp \
               -range [list $minMoveNum $maxMoveNum] \
               -length $minHalfMoves -bishops $oppBishops \
               -diff [list $minMatDiff $maxMatDiff] \
               -patt "$pattBool(1) $pattPiece(1) $pattFyle(1) $pattRank(1)" \
               -patt "$pattBool(2) $pattPiece(2) $pattFyle(2) $pattRank(2)" \
               -patt "$pattBool(3) $pattPiece(3) $pattFyle(3) $pattRank(3)" \
               -patt "$pattBool(4) $pattPiece(4) $pattFyle(4) $pattRank(4)" \
               -patt "$pattBool(5) $pattPiece(5) $pattFyle(5) $pattRank(5)" \
               -patt "$pattBool(6) $pattPiece(6) $pattFyle(6) $pattRank(6)" \
               -patt "$pattBool(7) $pattPiece(7) $pattFyle(7) $pattRank(7)" \
               -patt "$pattBool(8) $pattPiece(8) $pattFyle(8) $pattRank(8)" \
               -patt "$pattBool(9) $pattPiece(9) $pattFyle(9) $pattRank(9)" ]
    grab release .sm.b3.stop
    .sm.b3.stop configure -state disabled
    unbusyCursor .
    #tk_messageBox -type ok -title $::tr(SearchResults) -message $str
    .sm.status configure -text $str
    set glstart 1
    updateGList
    updateStatsWin
  }

  button $f.cancel -textvar ::tr(Close) -padx 20 \
    -command { focus .; destroy .sm }

  pack $f.ignorecol $w.b3.save -side left -pady 5 -padx 5
  pack $w.b3.cancel $w.b3.search $w.b3.stop -side right -pady 5 -padx 5
  pack $w.progress -side top -pady 2

  label $w.status -text "" -width 1 -font font_Small -relief sunken -anchor w
  pack $w.status -side bottom -fill x

  update
  wm resizable $w 0 0
  standardShortcuts $w
  configSearchState
  focus $f.search
}

proc saveMaterialSearch {} {
  global pMin pMax ignoreColors filterOp minMoveNum maxMoveNum minHalfMoves
  global pattPiece pattFyle pattRank pattBool oppBishops nPatterns

  set ftype { { "Scid SearchOptions files" {".sso"} } }
  set fName [tk_getSaveFile -initialdir [pwd] -filetypes $ftype -title "Create a SearchOptions file"]
  if {$fName == ""} { return }

  if {[string compare [file extension $fName] ".sso"] != 0} {
    append fName ".sso"
  }

  if {[catch {set searchF [open $fName w]}]} {
    tk_messageBox -title "Error: Unable to open file" -type ok -icon error \
      -message "Unable to create SearchOptions file: $fName"
    return
  }
  puts $searchF "\# SearchOptions File created by Scid [sc_info version]"
  puts $searchF "set searchType Material"
  # First write the material counts:
  foreach i {wq bq wr br wb bb wn bn wp bp} {
    puts $searchF "set pMin($i) $pMin($i)"
    puts $searchF "set pMax($i) $pMax($i)"
  }
  # Now write other numeric values:
  foreach i {ignoreColors filterOp minMoveNum maxMoveNum minHalfMoves oppBishops} {
    puts $searchF "set $i [set $i]"
  }
  # Last, write the patterns:
  for {set i 1} {$i <= $nPatterns} {incr i} {
    puts $searchF "set pattPiece($i) $pattPiece($i)"
    puts $searchF "set pattFyle($i) $pattFyle($i)"
    puts $searchF "set pattRank($i) $pattRank($i)"
    puts $searchF "set pattBool($i) $pattBool($i)"
  }
  tk_messageBox -type ok -icon info -title "Search Options saved" \
    -message "Material/pattern search options saved to: $fName"
  close $searchF
}


########################################
### HEADER Searching (Name, etc).

set sWhite "";  set sBlack "";  set sEvent ""; set sSite "";  set sRound ""
set sWhiteEloMin 0; set sWhiteEloMax [sc_info limit elo]
set sBlackEloMin 0; set sBlackEloMax [sc_info limit elo]
set sEloDiffMin "-[sc_info limit elo]"; set sEloDiffMax "+[sc_info limit elo]"
set sTitleList [list gm im fm none wgm wim wfm w]
foreach i $sTitleList {
  set sTitles(w:$i) 1
  set sTitles(b:$i) 1
}
set sGlMin 0; set sGlMax 999
set sEcoMin "A00";  set sEcoMax "E99"; set sEco Yes
set sDateMin "0000.00.00"; set sDateMax "[sc_info limit year].12.31"
set sResWin 1; set sResLoss 1; set sResDraw 1; set sResOther 1
set sGnumMin 1; set sGnumMax -1
set sIgnoreCol No
set sHeaderFlagList {StdStart Promotions Comments Variations Annotations \
      DeleteFlag WhiteOpFlag BlackOpFlag MiddlegameFlag EndgameFlag \
      NoveltyFlag PawnFlag TacticsFlag KsideFlag QsideFlag \
      BrilliancyFlag BlunderFlag UserFlag
}
foreach i $sHeaderFlagList {
    set sHeaderFlags($i) both
}
set sPgntext(1) ""
set sPgntext(2) ""
set sPgntext(3) ""

trace variable sDateMin w forceDate
trace variable sDateMax w forceDate

foreach i {sWhiteEloMin sWhiteEloMax sBlackEloMin sBlackEloMax} {
  trace variable $i w [list forceInt [sc_info limit elo] 0]
}
trace variable sEloDiffMin w [list forceInt "-[sc_info limit elo]" 0]
trace variable sEloDiffMax w [list forceInt "-[sc_info limit elo]" 0]

trace variable sGlMin w {forceInt 9999 0}
trace variable sGlMax w {forceInt 9999 0}

trace variable sGnumMin w {forceInt -9999999 0}
trace variable sGnumMax w {forceInt -9999999 0}

# Forcing ECO entry to be valid ECO codes:
foreach i {sEcoMin sEcoMax} {
  trace variable $i w {forceRegexp {^$|^[A-Ea-e]$|^[A-Ea-e][0-9]$|^[A-Ea-e][0-9][0-9]$|^[A-Ea-e][0-9][0-9][a-z]$|^[A-Ea-e][0-9][0-9][a-z][1-4]$}}
}

# checkDates:
#    Checks minimum/maximum search dates in header search window and
#    extends them if necessary.
proc checkDates {} {
  global sDateMin sDateMax
  if {[string length $sDateMin] == 0} { set sDateMin "0000" }
  if {[string length $sDateMax] == 0} { set sDateMax [sc_info limit year]}
  if {[string length $sDateMin] == 4} { append sDateMin ".??.??" }
  if {[string length $sDateMax] == 4} { append sDateMax ".12.31" }
  if {[string length $sDateMin] == 7} { append sDateMin ".??" }
  if {[string length $sDateMax] == 7} { append sDateMax ".31" }
}

# configSearchState:
#   Sets state of Search button in Header, Board and Material windows
#
proc configSearchState {{state ""}} {
  if {$state == ""} {
    set state disabled
    if {[sc_base inUse]} { set state normal }
  }
  catch {.sh.b.search configure -state $state }
  catch {.sb.b.search configure -state $state }
  catch {.sm.b3.search configure -state $state }
  catch {.spprep.b.search configure -state $state }
}

proc searchHeaderDefaults {} {
  global sWhite sBlack sEvent sSite sRound sDateMin sDateMax sIgnoreCol
  global sWhiteEloMin sWhiteEloMax sBlackEloMin sBlackEloMax
  global sEloDiffMin sEloDiffMax
  global sEco sEcoMin sEcoMax sHeaderFlags sGlMin sGlMax
  global sGnumMin sGnumMax
  global sResWin sResLoss sResDraw sResOther glstart filterOp
  global sPgntext sTitles

  set sWhite "";  set sBlack ""
  set sEvent ""; set sSite "";  set sRound ""
  set sWhiteEloMin 0; set sWhiteEloMax [sc_info limit elo]
  set sBlackEloMin 0; set sBlackEloMax [sc_info limit elo]
  set sEloDiffMin "-[sc_info limit elo]"
  set sEloDiffMax "+[sc_info limit elo]"
  set sGlMin 0; set sGlMax 999
  set sEcoMin "A00";  set sEcoMax "E99"; set sEco Yes
  set sGnumMin 1; set sGnumMax -1
  set sDateMin "0000.00.00"; set sDateMax "[sc_info limit year].12.31"
  set sResWin 1; set sResLoss 1; set sResDraw 1; set sResOther 1
  set sIgnoreCol No
  foreach flag $::sHeaderFlagList { set sHeaderFlags($flag) both }
  foreach i [array names sPgntext] { set sPgntext($i) "" }
  foreach i $::sTitleList {
    set sTitles(w:$i) 1
    set sTitles(b:$i) 1
  }
}

searchHeaderDefaults

set sHeaderFlagFrame 0

# searchHeader:
#   Search by header information.
#
proc searchHeader {} {
  global sWhite sBlack sEvent sSite sRound sDateMin sDateMax sIgnoreCol
  global sWhiteEloMin sWhiteEloMax sBlackEloMin sBlackEloMax
  global sEloDiffMin sEloDiffMax
  global sEco sEcoMin sEcoMax sHeaderFlags sGlMin sGlMax sTitleList sTitles
  global sResWin sResLoss sResDraw sResOther glstart filterOp sPgntext

  set w .sh
  if {[winfo exists $w]} {
    wm deiconify $w
    raiseWin $w
    return
  }

  toplevel $w
  wm title $w "Scid: $::tr(HeaderSearch)"
  foreach frame {white black ignore tw tb eventsite dateround res gl eco} {
    frame $w.$frame
  }

  bind $w <F1> { helpWindow Searches Header }
  bind $w <Escape> "$w.b.cancel invoke"
  bind $w <Return> "$w.b.search invoke"

  set regular font_Small
  set bold font_SmallBold

  foreach color {white black} Color {White Black} {
    pack $w.$color -side top -fill x
    label $w.$color.lab -textvar ::tr($Color:) -font $bold -width 9 -anchor w
    entry $w.$color.e -textvariable "s$Color" -width 40 -font $regular
    label $w.$color.space
    label $w.$color.elo1 -textvar ::tr(Rating:) -font $bold
    entry $w.$color.elomin -textvar s${Color}EloMin -width 6 -justify right \
      -font $regular
    label $w.$color.elo2 -text "-" -font $regular
    entry $w.$color.elomax -textvar s${Color}EloMax -width 6 -justify right \
      -font $regular
    bindFocusColors $w.$color.e
    bindFocusColors $w.$color.elomin
    bindFocusColors $w.$color.elomax
    pack $w.$color.lab $w.$color.e $w.$color.space -side left
    pack $w.$color.elomax $w.$color.elo2 $w.$color.elomin $w.$color.elo1 \
      -side right
  }

  pack $w.ignore -side top -fill x
  label $w.ignore.l -textvar ::tr(IgnoreColors:) -font $bold
  radiobutton $w.ignore.yes -variable sIgnoreCol -value Yes \
    -textvar ::tr(Yes) -font $regular
  radiobutton $w.ignore.no  -variable sIgnoreCol -value No \
    -textvar ::tr(No) -font $regular
  pack $w.ignore.l $w.ignore.yes $w.ignore.no -side left
  label $w.ignore.rdiff -textvar ::tr(RatingDiff:) -font $bold
  entry $w.ignore.rdmin -width 6 -textvar sEloDiffMin -justify right \
    -font $regular
  label $w.ignore.rdto -text "-" -font $regular
  entry $w.ignore.rdmax -width 6 -textvar sEloDiffMax -justify right \
    -font $regular
  bindFocusColors $w.ignore.rdmin
  bindFocusColors $w.ignore.rdmax
  pack $w.ignore.rdmax $w.ignore.rdto $w.ignore.rdmin $w.ignore.rdiff \
    -side right

  set spellstate normal
  if {[lindex [sc_name read] 0] == 0} { set spellstate disabled }
  foreach c {w b} name {White Black} {
    pack $w.t$c -side top -fill x
    label $w.t$c.label -text "$::tr($name) FIDE:" \
      -font $bold -width 14 -anchor w
    pack $w.t$c.label -side left
    foreach i $sTitleList {
      set name [string toupper $i]
      if {$i == "none"} { set name "-" }
      checkbutton $w.t$c.b$i -text $name -width 5 -font $regular \
        -variable sTitles($c:$i) -offvalue 0 -onvalue 1 -indicatoron 0 \
        -state $spellstate -pady 0
      pack $w.t$c.b$i -side left -padx 1
    }
  }

  addHorizontalRule $w

  set f $w.eventsite
  pack $f -side top -fill x
  foreach i {Event Site} {
    label $f.l$i -textvar ::tr(${i}:) -font $bold
    entry $f.e$i -textvariable s$i -width 30 -font $regular
    bindFocusColors $f.e$i
  }
  pack $f.lEvent $f.eEvent -side left
  pack $f.eSite $f.lSite -side right

  set f $w.dateround
  pack $f -side top -fill x
  label $f.l1 -textvar ::tr(Date:) -font $bold
  label $f.l2 -text "-" -font $regular
  label $f.l3 -text " " -font $regular
  entry $f.emin -textvariable sDateMin -width 10 -font $regular
  button $f.eminCal -image calendar -padx 0 -pady 0 -command {
    regsub -all {[.]} $sDateMin "-" newdate
    set ndate [::date::chooser $newdate]
    if {[llength $ndate] == 3} {
      set sDateMin "[lindex $ndate 0].[lindex $ndate 1].[lindex $ndate 2]"
    }
  }
  entry $f.emax -textvariable sDateMax -width 10 -font $regular
  button $f.emaxCal -image calendar -padx 0 -pady 0 -command {
    regsub -all {[.]} $sDateMax "-" newdate
    set ndate [::date::chooser $newdate]
    if {[llength $ndate] == 3} {
      set sDateMax "[lindex $ndate 0].[lindex $ndate 1].[lindex $ndate 2]"
    }
  }
  bindFocusColors $f.emin
  bindFocusColors $f.emax
  bind $f.emin <FocusOut> +checkDates
  bind $f.emax <FocusOut> +checkDates
  button $f.lyear -textvar ::tr(YearToToday) -font $regular -pady 2 -command {
    set sDateMin "[expr [::date::today year]-1].[::date::today month].[::date::today day]"
    set sDateMax [::date::today]
  }
  if {$::tcl_version >= 8.3} {
    pack $f.l1 $f.emin $f.eminCal $f.l2 $f.emax $f.emaxCal $f.l3 $f.lyear \
      -side left
  } else {
    pack $f.l1 $f.emin $f.l2 $f.emax $f.l3 $f.lyear -side left
  }

  label $f.lRound -textvar ::tr(Round:) -font $bold
  entry $f.eRound -textvariable sRound -width 10 -font $regular
  bindFocusColors $f.eRound
  pack $f.eRound $f.lRound -side right

  addHorizontalRule $w

  pack .sh.res -side top -fill x
  label $w.res.l1 -textvar ::tr(Result:) -font $bold
  pack $w.res.l1 -side left
  foreach i {win draw loss other} \
          v {sResWin sResDraw sResLoss sResOther} \
          text {"1-0:"  " =-=:"  " 0-1:"  " *:"} {
    checkbutton $w.res.e$i -variable $v -offvalue 0 -onvalue 1
    label $w.res.$i -text $text -font $regular
    pack $w.res.$i $w.res.e$i -side left
  }

  label $w.gl.l1 -textvar ::tr(GameLength:) -font $bold
  label $w.gl.l2 -text "-" -font $regular
  label $w.gl.l3 -textvar ::tr(HalfMoves) -font $regular
  entry $w.gl.emin -textvariable sGlMin -justify right -width 4 -font $regular
  entry $w.gl.emax -textvariable sGlMax -justify right -width 4 -font $regular
  bindFocusColors $w.gl.emin
  bindFocusColors $w.gl.emax
  pack $w.gl -in $w.res -side right -fill x
  pack $w.gl.l1 $w.gl.emin $w.gl.l2 $w.gl.emax $w.gl.l3 -side left

  label $w.eco.l1 -textvar ::tr(ECOCode:) -font $bold
  label $w.eco.l2 -text "-" -font $regular
  label $w.eco.l3 -text " " -font $regular
  label $w.eco.l4 -textvar ::tr(GamesWithNoECO:) -font $bold
  entry $w.eco.emin -textvariable sEcoMin -width 5 -font $regular
  entry $w.eco.emax -textvariable sEcoMax -width 5 -font $regular
  bindFocusColors $w.eco.emin
  bindFocusColors $w.eco.emax
  button $w.eco.range -text "..." -font $regular -pady 2 -padx 4 -command {
    set tempResult [chooseEcoRange]
    if {[scan $tempResult "%\[A-E0-9a-z\]-%\[A-E0-9a-z\]" sEcoMin_tmp sEcoMax_tmp] == 2} {
      set sEcoMin $sEcoMin_tmp
      set sEcoMax $sEcoMax_tmp
    }
    unset tempResult
  }
  radiobutton $w.eco.yes -variable sEco -value Yes -textvar ::tr(Yes) \
     -font $regular
  radiobutton $w.eco.no -variable sEco -value No -textvar ::tr(No) \
     -font $regular
  pack $w.eco -side top -fill x
  pack $w.eco.l1 $w.eco.emin $w.eco.l2 $w.eco.emax \
    $w.eco.range $w.eco.l3 $w.eco.l4 $w.eco.yes $w.eco.no -side left

  set f [frame $w.gnum]
  pack $f -side top -fill x
  label $f.l1 -textvar ::tr(GlistGameNumber:) -font $bold
  entry $f.emin -textvariable sGnumMin -width 8 -justify right -font $regular
  label $f.l2 -text "-" -font $regular
  entry $f.emax -textvariable sGnumMax -width 8 -justify right -font $regular
  pack $f.l1 $f.emin $f.l2 $f.emax -side left
  bindFocusColors $f.emin
  bindFocusColors $f.emax
  label $f.l3 -text " " -font $regular
  button $f.all -text [capital $::tr(all)] -pady 2 -font $regular \
    -command {set sGnumMin 1; set sGnumMax -1}
  menubutton $f.first -textvar ::tr(First...) -pady 2 -font $regular \
    -menu $f.first.m -indicatoron 0 -relief raised
  menubutton $f.last -textvar ::tr(Last...) -pady 2 -font $regular \
    -menu $f.last.m -indicatoron 0 -relief raised
  menu $f.first.m -font $regular
  menu $f.last.m -font $regular
  foreach x {10 50 100 500 1000 5000 10000} {
    $f.first.m add command -label $x \
      -command "set sGnumMin 1; set sGnumMax $x"
    $f.last.m add command -label $x \
      -command "set sGnumMin -$x; set sGnumMax -1"
  }
  pack $f.l3 $f.all $f.first $f.last -side left -padx 2

  set f [frame $w.pgntext]
  pack $f -side top -fill x
  label $f.l1 -textvar ::tr(PgnContains:) -font $bold
  entry $f.e1 -textvariable sPgntext(1) -width 15 -font $regular
  label $f.l2 -text "+" -font $regular
  entry $f.e2 -textvariable sPgntext(2) -width 15 -font $regular
  label $f.l3 -text "+" -font $regular
  entry $f.e3 -textvariable sPgntext(3) -width 15 -font $regular
  bindFocusColors $f.e1
  bindFocusColors $f.e2
  bindFocusColors $f.e3
  pack $f.l1 $f.e1 $f.l2 $f.e2 $f.l3 $f.e3 -side left

  addHorizontalRule $w

  button $w.flagslabel -textvar ::tr(FindGamesWith:) -font $bold -command {
    if {$sHeaderFlagFrame} {
      set sHeaderFlagFrame 0
      pack forget .sh.flags
    } else {
      set sHeaderFlagFrame 1
      pack .sh.flags -side top -after .sh.flagslabel
    }
  }
  pack $w.flagslabel -side top

  frame $w.flags
  if {$::sHeaderFlagFrame} {
    pack $w.flags -side top
  }

  set count 0
  set row 0
  set col 0
  foreach var $::sHeaderFlagList {
    set lab [label $w.flags.l$var -textvar ::tr($var) -font font_Small]
    grid $lab -row $row -column $col -sticky e
    incr col
    grid [radiobutton $w.flags.yes$var -variable sHeaderFlags($var) \
            -ind 0 -value yes -text $::tr(Yes) -padx 2 -pady 0 \
            -font font_Small] \
      -row $row -column $col
    incr col
    grid [radiobutton $w.flags.no$var -variable sHeaderFlags($var) \
            -ind 0 -value no -text $::tr(No) -padx 2 -pady 0 \
            -font font_Small] \
      -row $row -column $col
    incr col
    grid [radiobutton $w.flags.both$var -variable sHeaderFlags($var) \
            -ind 0 -value both -text $::tr(Both) -padx 2 -pady 0 \
            -font font_Small] \
      -row $row -column $col
    incr count
    incr col -3
    incr row
    if {$count == 6} { set col 5; set row 0 }
    if {$count == 12} { set col 10; set row 0 }
  }
  grid [label $w.flags.space -text "" -font $regular] -row 0 -column 4
  grid [label $w.flags.space2 -text "" -font $regular] -row 0 -column 9

  addHorizontalRule $w
  search_addFilterOpFrame $w 1
  addHorizontalRule $w

  ### Header search: search/cancel buttons

  frame $w.b
  pack $w.b -side top -pady 2 -fill x
  button $w.b.defaults -textvar ::tr(Defaults) -padx 20 \
    -command searchHeaderDefaults
  button $w.b.save -textvar ::tr(Save...) -padx 20 -command saveHeaderSearch
  button $w.b.stop -textvar ::tr(Stop) -command sc_progressBar
  button $w.b.search -textvar ::tr(Search) -padx 20 -command {
    set sPgnlist {}
    foreach i {1 2 3} {
        set temp [string trim $sPgntext($i)]
        if {$temp != ""} { lappend sPgnlist $temp }
    }
    busyCursor .
    pack .sh.b.stop -side right -padx 5
    grab .sh.b.stop
    sc_progressBar .sh.progress bar 301 21 time
    set wtitles {}
    set btitles {}
    foreach i $sTitleList {
      if $sTitles(w:$i) { lappend wtitles $i }
      if $sTitles(b:$i) { lappend btitles $i }
    }
    set str [sc_search header -white $sWhite -black $sBlack \
               -event $sEvent -site $sSite -round $sRound \
               -date [list $sDateMin $sDateMax] \
               -results [list $sResWin $sResDraw $sResLoss $sResOther] \
               -welo [list $sWhiteEloMin $sWhiteEloMax] \
               -belo [list $sBlackEloMin $sBlackEloMax] \
               -delo [list $sEloDiffMin $sEloDiffMax] \
               -eco [list $sEcoMin $sEcoMax $sEco] \
               -length [list $sGlMin $sGlMax] \
               -gameNumber [list $sGnumMin $sGnumMax] \
               -flip $sIgnoreCol -filter $filterOp \
               -fStdStart $sHeaderFlags(StdStart) \
               -fPromotions $sHeaderFlags(Promotions) \
               -fComments $sHeaderFlags(Comments) \
               -fVariations $sHeaderFlags(Variations) \
               -fAnnotations $sHeaderFlags(Annotations) \
               -fDelete $sHeaderFlags(DeleteFlag) \
               -fWhiteOp $sHeaderFlags(WhiteOpFlag) \
               -fBlackOp $sHeaderFlags(BlackOpFlag) \
               -fMiddlegame $sHeaderFlags(MiddlegameFlag) \
               -fEndgame $sHeaderFlags(EndgameFlag) \
               -fNovelty $sHeaderFlags(NoveltyFlag) \
               -fPawnStruct $sHeaderFlags(PawnFlag) \
               -fTactics $sHeaderFlags(TacticsFlag) \
               -fKingside $sHeaderFlags(KsideFlag) \
               -fQueenside $sHeaderFlags(QsideFlag) \
               -fBrilliancy $sHeaderFlags(BrilliancyFlag) \
               -fBlunder $sHeaderFlags(BlunderFlag) \
               -fUser $sHeaderFlags(UserFlag) \
               -pgn $sPgnlist -wtitles $wtitles -btitles $btitles \
              ]

    grab release .sh.b.stop
    pack forget .sh.b.stop
    unbusyCursor .

    .sh.status configure -text $str
    set glstart 1
    updateGList
    updateStatsWin
  }

  button $w.b.cancel -textvar ::tr(Close) -padx 20 \
    -command {focus .; destroy .sh}

  foreach i {defaults save cancel search stop} {
    $w.b.$i configure -font $regular
  }

  pack $w.b.defaults $w.b.save -side left -padx 5
  pack $w.b.cancel $w.b.search -side right -padx 5


  canvas $w.progress -height 20 -width 300 -bg white -relief solid -border 1
  $w.progress create rectangle 0 0 0 0 -fill blue -outline blue -tags bar
  $w.progress create text 295 10 -anchor e -font font_Regular -tags time \
    -fill black -text "0:00 / 0:00"
  pack $w.progress -side top -pady 2
  label $w.status -text "" -width 1 -font font_Small -relief sunken -anchor w
  pack $w.status -side bottom -fill x
  update
  wm resizable $w 0 0
  standardShortcuts $w
  configSearchState
  focus $w.white.e
}

proc saveHeaderSearch {} {
  global sWhite sBlack sEvent sSite sRound sDateMin sDateMax sIgnoreCol
  global sWhiteEloMin sWhiteEloMax sBlackEloMin sBlackEloMax
  global sEloDiffMin sEloDiffMax sGlMin sGlMax
  global sEco sEcoMin sEcoMax sHeaderFlags
  global sResWin sResLoss sResDraw sResOther glstart filterOp sPgntext

  set ftype { { "Scid SearchOptions files" {".sso"} } }
  set fName [tk_getSaveFile -initialdir [pwd] -filetypes $ftype -title "Create a SearchOptions file"]
  if {$fName == ""} { return }

  if {[string compare [file extension $fName] ".sso"] != 0} {
    append fName ".sso"
  }

  if {[catch {set searchF [open [file nativename $fName] w]} ]} {
    tk_messageBox -title "Error: Unable to open file" -type ok -icon error \
      -message "Unable to create SearchOptions file: $fName"
    return
  }
  puts $searchF "\# SearchOptions File created by Scid [sc_info version]"
  puts $searchF "set searchType Header"

  # First write the regular variables:
  foreach i {sWhite sBlack sEvent sSite sRound sDateMin sDateMax sResWin
     sResLoss sResDraw sResOther sWhiteEloMin sWhiteEloMax sBlackEloMin
     sBlackEloMax sEcoMin sEcoMax filterOp sEloDiffMin sEloDiffMax
     sIgnoreCol sGlMin sGlMax} {
    puts $searchF "set $i [list [set $i]]"
  }

  # Now write the array values:
  foreach i [array names sHeaderFlags] {
    puts $searchF "set sHeaderFlags($i) [list $sHeaderFlags($i)]"
  }
  foreach i [array names sPgntext] {
    puts $searchF "set sPgntext($i) [list $sPgntext($i)]"
  }

  tk_messageBox -type ok -icon info -title "Search Options saved" \
    -message "Header search options saved to: $fName"
  close $searchF
}


##############################
### Selecting common ECO ranges

set ecoCommonRanges {
  {A04-A09  Reti: 1.Nf3}
  {A10-A39  English: 1.c4}
  {A40-A49  1.d4, 1.d4 Nf6 Miscellaneous}
  {A45l-A45z  Trompowsky: 1.d4 Nf6 2.Bg5}
  {A51-A52  Budapest: 1.d4 Nf6 2.c4 e5}
  {A53-A55  Old Indian: 1.d4 Nf6 2.c4 d6}
  {A57-A59  Benko Gambit: 1.d4 Nf6 2.c4 c5 3.d5 b5}
  {A60-A79  Modern Benoni: 1.d4 Nf6 2.c4 c5 3.d5 e6}
  {A80-A99  Dutch Defence: 1.d4 f5}
  {____________________________________________________________}
  {B00-C99  1.e4}
  {B01-B01     Scandinavian: 1.e4 d5}
  {B02-B05     Alekhine Defence: 1.e4 Nf6}
  {B07-B09     Pirc: 1.e4 d6}
  {B10-B19     Caro-Kann: 1.e4 c6}
  {B12i-B12z      Caro-Kann: Advance: 1.e4 c6 2.d4 d5 3.e5}
  {B20-B99  Sicilian: 1.e4 c5}
  {B22-B22     Sicilian: Alapin: 1.e4 c5 2.c3}
  {B23-B26     Sicilian: Closed: 1.e4 c5 2.Nc3}
  {B30-B39     Sicilian: 1.e4 c5 2.Nf3 Nc6}
  {B40-B49     Sicilian: 1.e4 c5 2.Nf3 e6}
  {B50-B59     Sicilian Rauzer: 1.e4 c5 2.Nf3 d6 ... 5.Nc3 Nc6}
  {B70-B79     Sicilian Dragon: 1.e4 c5 2.Nf3 d6 ... 5.Nc3 g6}
  {B80-B89     Sicilian Scheveningen: 1.e4 c5 2.Nf3 d6 ... 5.Nc3 e6}
  {B90-B99     Sicilian Najdorf: 1.e4 c5 2.Nf3 d6 ... 5.Nc3 a6}
  {____________________________________________________________}
  {C00-C19  French Defence: 1.e4 e6}
  {C02-C02     French: Advance: 1.e4 e6 2.d4 d5 3.e5}
  {C03-C09     French: Tarrasch: 1.e4 e6 2.d4 d5 3.Nd2}
  {C15-C19     French: Winawer: 1.e4 e6 2.d4 d5 3.Nc3 Bb4}
  {C20-C99  Open Game: 1.e4 e5}
  {C25-C29     Vienna: 1.e4 e5 2.Nc3}
  {C30-C39     King's Gambit: 1.e4 e5 2.f4}
  {C42-C43     Russian Game: 1.e4 e5 2.Nf3 Nf6}
  {C44-C49     Open Game: 1.e4 e5 2.Nf3 Nc6}
  {C50-C59     Italian/Two Knights: 1.e4 e5 2.Nf3 Nc6 3.Bc4}
  {C60-C99  Spanish: 1.e4 e5 2.Nf3 Nc6 3.Bb5}
  {C68-C69      Spanish: Exchange: 3.Bb5 a6 4.Bxc6}
  {C80-C83      Spanish: Open: 3.Bb5 a6 4.Ba4 Nf6 5.O-O Nxe4}
  {C84-C99      Spanish: Closed: 3.Bb5 a6 4.Ba4 Nf6 5.O-O Be7}
  {____________________________________________________________}
  {D00-D99  Queen's Pawn: 1.d4 d5}
  {D10-D19  Slav: 1.d4 d5 2.c4 c6}
  {D20-D29  QGA: 1.d4 d5 2.c4 dxc4}
  {D30-D69  QGD: 1.d4 d5 2.c4 e6}
  {D35-D36     QGD: Exchange: 1.d4 d5 2.c4 e6 3.cxd5 exd5}
  {D43-D49     Semi-Slav: 3.Nc3 Nf6 4.Nf3 c6}
  {D50-D69     QGD with Bg5: 1.d4 d5 2.c4 e6 3.Nc3 Nf6 4.Bg5}
  {D60-D69     QGD: Orthodox: 4.Bg5 Be7 5.e3 O-O 6.Nf3 Nbd7}
  {D70-D99  Grünfeld: 1.d4 Nf6 2.c4 g6 with 3...d5}
  {D85-D89     Grünfeld: Exchange: 3.Nc3 d5 4.e4 Nxc3 5.bxc3}
  {D96-D99     Grünfeld: Russian: 3.Nc3 d5 4.Nf3 Bg7 5.Qb3}
  {____________________________________________________________}
  {E00-E09  Catalan: 1.d4 Nf6 2.c4 e6 3.g3/...}
  {E02-E05     Catalan: Open: 3.g3 d5 4.Bg2 dxc4}
  {E06-E09     Catalan: Closed: 3.g3 d5 4.Bg2 Be7}
  {E12-E19  Queen's Indian: 1.d4 Nf6 2.c4 e6 3.Nf3 b6}
  {E20-E59  Nimzo-Indian: 1.d4 Nf6 2.c4 e6 3.Nc3 Bb4}
  {E32-E39     Nimzo-Indian: Classical: 4.Qc2}
  {E40-E59     Nimzo-Indian: Rubinstein: 4.e3}
  {E60-E99  King's Indian: 1.d4 Nf6 2.c4 g6}
  {E80-E89     King's Indian: Sämisch: 4.e4 d6 5.f3}
  {E90-E99     King's Indian: Main Line: 4.e4 d6 5.Nf3}
}

set scid_ecoRangeChosen ""

proc chooseEcoRange {} {
  global ecoCommonRanges scid_ecoRangeChosen
  if {[winfo exists .ecoRangeWin]} { return }
  set w .ecoRangeWin
  toplevel $w
  wm title $w "Scid: Choose ECO Range"
  wm minsize $w 30 5

  listbox $w.list -yscrollcommand "$w.ybar set" -height 20 -width 60 \
    -background white -selectbackground lightBlue -setgrid 1
  foreach i $ecoCommonRanges { $w.list insert end $i }
  scrollbar $w.ybar -command "$w.list yview" -takefocus 0
  pack [frame $w.b] -side bottom -fill x
  pack $w.ybar -side right -fill y
  pack $w.list -side left -fill both -expand yes

  button $w.b.ok -text "OK" -command {
    set sel [.ecoRangeWin.list curselection]
    if {[llength $sel] > 0} {
      set scid_ecoRangeChosen [lindex $ecoCommonRanges [lindex $sel 0]]
    }
    focus .
    destroy .ecoRangeWin
  }
  button $w.b.cancel -text $::tr(Cancel) -command "focus .; destroy $w"
  pack $w.b.cancel $w.b.ok -side right -padx 5 -pady 2
  bind $w <Escape> "
    set scid_ecoRangeChosen {}
    grab release $w
    focus .
    destroy $w
    break"
  bind $w <Return> "$w.b.ok invoke; break"
  bind $w.list <Double-ButtonRelease-1> "$w.b.ok invoke; break"
  focus $w.list
  grab $w
  tkwait window $w
  return $scid_ecoRangeChosen
}


###
### End of file: search.tcl

