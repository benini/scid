### ScidPocket.
### Copyright (C) 2007  Pascal Georges
###
### search/material.tcl: Material Search routine for Scid.
###

namespace eval ::search::material {}

array set letterToPiece [list \
    "R" wr "r" br "N" wn "n" bn "B" wb "b" bb \
    "Q" wq "q" bq "K" wk "k" bk "P" wp "p" bp "." e \
    ]

image create photo button_oneplus -data {
  R0lGODlhFAAUAIAAAAAAAP///yH5BAEKAAEALAAAAAAUABQAAAIpjI+py+0P
  FwCSzVnlzZaaC3oJNooadyqmun4OGR1wHMxQ2HYgzfd+UgAAOw==
}

set ignoreColors 0
set minMoveNum 1
set maxMoveNum 999
set minHalfMoves 1
set oppBishops "Either"
set minMatDiff -40
set maxMatDiff +40

trace variable minMoveNum w {::utils::validate::Integer 999 0}
trace variable maxMoveNum w {::utils::validate::Integer 999 0}
trace variable minHalfMoves w {::utils::validate::Integer 99 0}
trace variable minMatDiff w {::utils::validate::Integer -99 0}
trace variable maxMatDiff w {::utils::validate::Integer -99 0}

set nPatterns 10

array set pMin [list wq 0 bq 0 wr 0 br 0 wb 0 bb 0 wn 0 bn 0 wm 0 bm 0 wp 0 bp 0]
array set pMax [list wq 2 bq 2 wr 2 br 2 wb 2 bb 2 wn 2 bn 2 wm 4 bm 4 wp 8 bp 8]
for { set i 1 } { $i <= $nPatterns } { incr i } {
  set pattPiece($i) "?";  set pattFyle($i) "?";  set pattRank($i) "?"
}

proc checkPieceCounts {name el op} {
  global pMin pMax
  ::utils::validate::Integer 9 0 $name $el $op
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


proc makeBoolMenu {w varName} {
  upvar #0 $varName var
  if {![info exists var]} { set var "Yes" }
  menubutton $w -textvariable $varName -indicatoron 0 -menu $w.menu \
      -relief raised -bd 2 -highlightthickness 2 -anchor w -image ""
  menu $w.menu -tearoff 0
  $w.menu add radiobutton -label Yes -image _tick \
      -variable $varName -value Yes \
      -command "$w configure -image _tick" ;# -hidemargin 1
  $w.menu add radiobutton -label No -image _cross \
      -variable $varName -value No \
      -command "$w configure -image _cross" ;# -hidemargin 1
  return $w.menu
}

proc makePieceMenu {w varName} {
  global dark
  upvar #0 $varName var
  if {![info exists var]} { set var "?" }
  menubutton $w -textvariable $varName -indicatoron 0 -menu $w.menu \
      -relief raised -bd 2 -highlightthickness 2 -anchor w -image ""
  menu $w.menu -tearoff 0
  $w.menu add radiobutton -label " ? " -variable $varName -value "?" \
      -command "$w configure -image e20" ;# -hidemargin 1
  foreach i {wk wq wr wb wn wp bk bq br bb bn bp} {
    $w.menu add radiobutton -label $i -image ${i}20 -value $i \
        -variable $varName \
        -command "$w configure -image ${i}20" ;# -hidemargin 1
  }
  foreach i {" ? " wk bk} {
    $w.menu entryconfigure $i -columnbreak 1
  }
  return $w.menu
}

proc updatePatternImages {} {
  global pattPiece nPatterns pattBool
  if {! [winfo exists .sm]} { return }
  set w .sm.sf.scrolled
  for {set i 1} {$i <= $nPatterns} {incr i} {
    if {$pattBool($i) == "Yes"} {
      $w.mp.patt.grid.b$i configure -image _tick
    } else {
      $w.mp.patt.grid.b$i configure -image _cross
    }
    if {$pattPiece($i) == "?"} {
      $w.mp.patt.grid.p$i configure -image e20
    } else {
      $w.mp.patt.grid.p$i configure -image "$pattPiece($i)20"
    }
  }
}

# ::search::material::zero
#
#   Called to clear all material minumum/maximum values to zero.
#
proc ::search::material::zero {} {
  global pMin pMax
  array set pMin {wq 0 bq 0 wr 0 br 0 wb 0 bb 0 wn 0 bn 0 wm 0 bm 0 wp 0 bp 0}
  array set pMax {wq 0 bq 0 wr 0 br 0 wb 0 bb 0 wn 0 bn 0 wm 0 bm 0 wp 0 bp 0}
}

proc ::search::material::any {} {
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


# ::search::material
#
#   Opens the window for searching by material or patterns.
#
proc ::search::material {} {
  global glstart dark pMin pMax ignoreColors minMoveNum maxMoveNum
  global pattPiece pattFyle pattRank pattBool oppBishops nPatterns
  global minHalfMoves smDisplayed
  
  set w .sm
  if {[winfo exists $w]} {
    wm deiconify $w
    raiseWin $w
    return
  }
  
  toplevel $w
  wm title $w "Scid:Material search)"
  ::ui::setFullSize $w
  
  ::scrolledframe::scrolledframe .sm.sf -xscrollcommand {.sm.hs set} -yscrollcommand {.sm.vs set}  -fill both ;# try both, x, y or none
  scrollbar .sm.vs -command {.sm.sf yview}
  scrollbar .sm.hs -command {.sm.sf xview} -orient horizontal
  grid .sm.sf -row 0 -column 0 -sticky nsew
  grid .sm.vs -row 0 -column 1 -sticky ns
  grid .sm.hs -row 1 -column 0 -sticky ew
  grid rowconfigure .sm 0 -weight 1
  grid columnconfigure .sm 0 -weight 1
  
  set w .sm.sf.scrolled
  
  pack [frame $w.mp] -side top
  pack [frame $w.mp.material] -side left
  
  label $w.mp.material.title -textvar Material:
  pack $w.mp.material.title -side top -pady 3
  
  foreach piece {q r b n m p} {
    frame $w.mp.material.$piece
    pack $w.mp.material.$piece -side top ;# -padx 2
  }
  
  foreach i {q r b n m p} {
    set f $w.mp.material.$i
    button $f.w0 -text "0" -command "set pMin(w$i) 0; set pMax(w$i) 0"
    button $f.w1 -text "1" -command "set pMin(w$i) 1; set pMax(w$i) 1"
    button $f.w2 -text "2" -command "set pMin(w$i) 2; set pMax(w$i) 2"
    button $f.wa -text "0+" -command "set pMin(w$i) 0; set pMax(w$i) 2"
    button $f.w1p -text "1+" -command "set pMin(w$i) 1; set pMax(w$i) 2"
    label $f.wi -image w${i}20
    label $f.wto -text "-" -padx 0
    entry $f.wmin -width 2 -relief sunken -textvar pMin(w$i) -justify right
    entry $f.wmax -width 2 -relief sunken -textvar pMax(w$i) -justify right
    pack $f.w0 $f.w1 $f.w2 $f.wa $f.w1p $f.wi $f.wmin $f.wto $f.wmax -side left -pady 1
    
    pack [frame $f.space -width 20] -side left
    button $f.b0 -text "0" -command "set pMin(b$i) 0; set pMax(b$i) 0"
    button $f.b1 -text "1" -command "set pMin(b$i) 1; set pMax(b$i) 1"
    button $f.b2 -text "2" -command "set pMin(b$i) 2; set pMax(b$i) 2"
    button $f.ba -text "0+" -command "set pMin(b$i) 0; set pMax(b$i) 2"
    button $f.b1p -text "1+" -command "set pMin(b$i) 1; set pMax(b$i) 2"
    label $f.bi -image b${i}20
    label $f.bto -text "-"
    entry $f.bmin -width 2 -relief sunken -textvar pMin(b$i) -justify right
    entry $f.bmax -width 2 -relief sunken -textvar pMax(b$i) -justify right
    pack $f.b0 $f.b1 $f.b2 $f.ba $f.b1p $f.bi $f.bmin $f.bto $f.bmax -side left -pady 1
    
    foreach b {0 1 2 a 1p} {
      $f.w$b configure -width 2 -pady 0 -padx 1 -takefocus 0
      $f.b$b configure -width 2 -pady 0 -padx 1 -takefocus 0
    }
    
    if {$i == "p"} {
      $f.w1p configure -command "set pMin(wp) 1; set pMax(wp) 8"
      $f.wa configure -command "set pMin(wp) 0; set pMax(wp) 8"
      $f.b1p configure -command "set pMin(bp) 1; set pMax(bp) 8"
      $f.ba configure -command "set pMin(bp) 0; set pMax(bp) 8"
    }
    if {$i == "m"} {
      $f.w1p configure -command "set pMin(wm) 1; set pMax(wm) 4"
      $f.wa configure -command "set pMin(wm) 0; set pMax(wm) 4"
      $f.b1p configure -command "set pMin(bm) 1; set pMax(bm) 4"
      $f.ba configure -command "set pMin(bm) 0; set pMax(bm) 4"
    }
  }
  
  # Buttons that manipulate material settings:
  set f $w.mp.material.b1
  pack [frame $f] -side top -ipady 2
  
  dialogbutton $f.zero -text Zero -command ::search::material::zero
  dialogbutton $f.reset -text Any -command ::search::material::any
  dialogbutton $f.current -text "Current board" -command {
    ::search::material::zero
    set bd [sc_pos board]
    for {set i 0} {$i < 64} {incr i} {
      set piece $::letterToPiece([ string index $bd $i ])
      if {$piece != "e"  &&  $piece != "wk"  &&  $piece != "bk"} {
        incr pMin($piece); set pMax($piece) $pMin($piece)
      }
    }
  }
  
  pack $f.zero $f.reset $f.current -side left -pady 5 -padx 10
  
  set f $w.mp.material.mdiff
  pack [frame $f] -side top
  label $f.label -text "Material diff:"
  entry $f.min -width 3 -relief sunken -textvar minMatDiff -justify right
  label $f.sep -text "-"
  entry $f.max -width 3 -relief sunken -text maxMatDiff -justify right
  label $f.sep2 -text " "
  button $f.any -text Any -padx 1 -pady 1 -command {set minMatDiff -40; set maxMatDiff +40}
  button $f.w1 -text " + " -padx 1 -pady 1 -command {set minMatDiff +1; set maxMatDiff +40}
  button $f.equal -text " = " -padx 1 -pady 1 -command {set minMatDiff 0; set maxMatDiff 0}
  button $f.b1 -text " - " -padx 1 -pady 1 -command {set minMatDiff -40; set maxMatDiff -1}
  pack $f.label $f.min $f.sep $f.max -side left
  pack $f.sep2 $f.any $f.w1 $f.equal $f.b1 -side left
  set f [frame $w.mp.material.mdiff2]
  pack $f -side top
  label $f.explan -text "(Material diff = White - Black; Q=9 R=5 B=3 N=3 P=1)"
  pack $f.explan -side top
  
  addVerticalRule $w.mp
  
  set f [frame $w.mp.patt]
  pack $f -side top
  
  label $w.mp.patt.title -text Patterns:
  pack $w.mp.patt.title -side top -pady 3
  
  pack [frame $f.grid] -side top
  for { set i 1 } { $i <= $nPatterns } { incr i } {
    makeBoolMenu $f.grid.b$i pattBool($i)
    set menuPiece1 [ makePieceMenu $f.grid.p$i pattPiece($i) ]
    tk_optionMenu $f.grid.f$i pattFyle($i) "?" a b c d e f g h
    tk_optionMenu $f.grid.r$i pattRank($i) "?" 1 2 3 4 5 6 7 8
    $f.grid.b$i configure -indicatoron 0 ;# -width 4
    $f.grid.f$i configure -indicatoron 0 -width 1 -pady 1
    $f.grid.r$i configure -indicatoron 0 -width 1 -pady 1
    set column [expr {5 * (($i - 1) / 5)} ]
    set row [expr {($i - 1) % 5} ]
    grid $f.grid.b$i -row $row -column $column -padx 0; incr column
    grid $f.grid.p$i -row $row -column $column -padx 0; incr column
    grid $f.grid.f$i -row $row -column $column -padx 0; incr column
    grid $f.grid.r$i -row $row -column $column -padx 0; incr column
    if {$column == 4  ||  $column == 9} {
      label $f.grid.sp_$i -text "  "
      grid $f.grid.sp_$i -row $row -column $column
    }
  }
  
  updatePatternImages
  
  ### Buttons that manipulate patterns:
  set f $w.mp.patt.b2
  frame $f
  dialogbutton $f.clearPat -text Clear -command clearPatterns
  
  pack $f -side top
  pack $f.clearPat -side left -pady 5 -padx 10
  #if {! $smDisplayed(Patterns)} {
  #  pack forget $w.patt $w.b2
  #}
  updatePatternImages
  
  addHorizontalRule $w
  
  ### Now the move counter:
  
  set f $w.bishops
  pack [frame $f] -side top
  label $f.t1 -text "1"
  label $f.t2 -image wb20
  label $f.t3 -text "- 1"
  label $f.t4 -image bb20
  label $f.t5 -text squares:
  radiobutton $f.same -text "Same color" -variable oppBishops \
      -value "Same" -padx 5 -pady 4
  radiobutton $f.opp -text "Opp color" -variable oppBishops \
      -value "Opposite" -padx 5 -pady 4
  radiobutton $f.either -text Either -variable oppBishops \
      -value "Either" -padx 5 -pady 4
  foreach i {t1 t2 t3 t4 t5 same opp either} { pack $f.$i -side left }
  
  set f $w.move
  pack [frame $f] -side top -ipady 5
  label $f.fromlab -text "Move number range:"
  entry $f.from -width 4 -relief sunken -textvar minMoveNum -justify right
  label $f.tolab -text "-"
  entry $f.to -width 4 -relief sunken -textvar maxMoveNum -justify right
  label $f.space -text "  "
  label $f.label1 -textvar MatchForAtLeast
  entry $f.hmoves -width 3 -relief sunken -textvar minHalfMoves -justify right
  label $f.label2 -textvar HalfMoves
  pack $f.fromlab $f.from $f.tolab $f.to $f.space \
      $f.label1 $f.hmoves $f.label2 -side left
  
  addHorizontalRule $w
  ::search::addFilterOpFrame $w 1
  addHorizontalRule $w
  
  ### Progress bar:
  
  canvas $w.progress -height 20 -width 200 -bg white -relief solid -border 1
  $w.progress create rectangle 0 0 0 0 -outline blue -fill blue -tags bar
  $w.progress create text 295 10 -anchor e -tags time -fill black -text "0:00 / 0:00"
  
  ### Last of all, the buttons frame:
  
  set f $w.b3
  pack [frame $f] -side top -ipady 5 -fill x
  checkbutton $f.ignorecol -textvar IgnoreColors \
      -variable ignoreColors -padx 4
  
  dialogbutton $f.stop -text [::msgcat::mc "Stop"] -command sc_progressBar
  $f.stop configure -state disabled
  
  dialogbutton $f.search -text [::msgcat::mc "Search"] -command {
    busyCursor .sm
    set w .sm.sf.scrolled
    $w.b3.stop configure -state normal
    grab $w.b3.stop
    sc_progressBar $w.progress bar 201 21 time
    set str [sc_search material \
        -wq [list $pMin(wq) $pMax(wq)] -bq [list $pMin(bq) $pMax(bq)] \
        -wr [list $pMin(wr) $pMax(wr)] -br [list $pMin(br) $pMax(br)] \
        -wb [list $pMin(wb) $pMax(wb)] -bb [list $pMin(bb) $pMax(bb)] \
        -wn [list $pMin(wn) $pMax(wn)] -bn [list $pMin(bn) $pMax(bn)] \
        -wm [list $pMin(wm) $pMax(wm)] -bm [list $pMin(bm) $pMax(bm)] \
        -wp [list $pMin(wp) $pMax(wp)] -bp [list $pMin(bp) $pMax(bp)] \
        -flip $ignoreColors -filter $::search::filter::operation \
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
        -patt "$pattBool(9) $pattPiece(9) $pattFyle(9) $pattRank(9)" \
        -patt "$pattBool(10) $pattPiece(10) $pattFyle(10) $pattRank(10)" ]
    grab release $w.b3.stop
    $w.b3.stop configure -state disabled
    unbusyCursor .sm
    tk_messageBox -type ok -title "Search results" -parent .sm -message $str
    set glstart 1
  }
  
  dialogbutton $f.cancel -text Close -command { destroy .sm  }
  
  pack $w.b3.cancel $w.b3.search $w.b3.stop -side right -pady 5 -padx 5
  pack $w.progress -side top -pady 2
  
  label $w.status -text "" -width 1 -relief sunken -anchor w
  pack $w.status -side bottom -fill x
  
  # update
  ::search::Config
  focus $f.search
}

