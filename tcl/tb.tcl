### tb.tcl:
###   Tablebase display routines for Scid.

set tbWin 0
set tbTraining 0
set tbStatus ""

namespace eval ::tb {}

set tbInfo(section) 21
set tbInfo(material) "kpk"
set tbInfo(sections) [list 21 22 31 32 41]
foreach i $tbInfo(sections) { set tbInfo($i) [list] }

set tbInfo(21) [list kqk krk kbk knk kpk]

set tbInfo(22) [list \
  kqkq kqkr kqkb kqkn kqkp \
  -    krkr krkb krkn krkp \
  -    -    kbkb kbkn kbkp \
  -    -    -    knkn knkp \
  -    -    -    -    kpkp ]

set tbInfo(31) [list \
  kqqk kqrk kqbk kqnk kqpk \
  -    krrk krbk krnk krpk \
  -    -    kbbk kbnk kbpk \
  -    -    -    knnk knpk \
  -    -    -    -    kppk ]

set tbInfo(32) [list \
  kqqkq kqqkr kqqkb kqqkn kqqkp \
  kqrkq kqrkr kqrkb kqrkn kqrkp \
  kqbkq kqbkr kqbkb kqbkn kqbkp \
  kqnkq kqnkr kqnkb kqnkn kqnkp \
  kqpkq kqpkr kqpkb kqpkn kqpkp \
  -     -     -     -     -     \
  krrkq krrkr krrkb krrkn krrkp \
  krbkq krbkr krbkb krbkn krbkp \
  krnkq krnkr krnkb krnkn krnkp \
  krpkq krpkr krpkb krpkn krpkp \
  -     -     -     -     -     \
  kbbkq kbbkr kbbkb kbbkn kbbkp \
  kbnkq kbnkr kbnkb kbnkn kbnkp \
  kbpkq kbpkr kbpkb kbpkn kbpkp \
  -     -     -     -     -     \
  knnkq knnkr knnkb knnkn knnkp \
  knpkq knpkr knpkb knpkn knpkp \
  kppkq kppkr kppkb kppkn kppkp ]

set tbInfo(41) [list \
  kqqqk kqqrk kqqbk kqqnk kqqpk \
  -     kqrrk kqrbk kqrnk kqrpk \
  -     -     kqbbk kqbnk kqbpk \
  -     -     -     kqnnk kqnpk \
  -     -     -     -     kqppk \
  -     krrrk krrbk krrnk krrpk \
  -     -     krbbk krbnk krbpk \
  -     -     -     krnnk krnpk \
  -     -     -     -     krppk \
  -     -     kbbbk kbbnk kbbpk \
  -     -     -     kbnnk kbnpk \
  -     -     -     -     kbppk \
  -     -     -     knnnk knnpk \
  -     -     -     -     knppk \
  -     -     -     -     kpppk ]


# ::tb::isopen
#   Returns boolean value of whether the tablebase window is open.
#
proc ::tb::isopen {} {
  return [winfo exists .tbWin]
}

# ::tb::open
#   Open the tablebase window.
#
proc ::tb::open {} {
  global tbInfo
  set w .tbWin
  if {[winfo exists $w]} { return }
  toplevel $w
  setWinLocation $w
  wm title $w "Scid: [tr WindowsTB]"
  pack [frame $w.b] -side bottom -fill x
  pack [frame $w.info] -side left -fill y -expand yes
  addVerticalRule $w
  pack [frame $w.pos] -side right -fill y -expand yes

  # Left frame: tablebase browser and summary info

  set f $w.info
  pack [frame $f.sec] -side top -fill x
  foreach i $tbInfo(sections) {
    set name "[string index $i 0]-[string index $i 1]"
    radiobutton $f.sec.b$i -text " $name " \
      -variable tbInfo(section) -value $i \
      -indicatoron 0 -command "::tb::section $i"
    pack $f.sec.b$i -side left -pady 1 -padx 1
  }
  pack [frame $f.list] -side top -fill x
  text $f.list.text -width 35 -height 7 -font font_Fixed -wrap none \
    -foreground black -background white -yscrollcommand "$f.list.ybar set" \
    -cursor top_left_arrow
  scrollbar $f.list.ybar -command "$f.list.text yview" -takefocus 0
  pack $f.list.ybar -side right -fill y
  pack $f.list.text -side left
  pack [frame $f.separator -height 2]
  # addHorizontalRule $f
  pack [frame $f.data] -side top -fill y -expand yes
  text $f.data.text -width 35 -height 14 -font font_Fixed -wrap none \
    -foreground black -background white -yscrollcommand "$f.data.ybar set" \
    -cursor top_left_arrow -setgrid 1
  scrollbar $f.data.ybar -command "$f.data.text yview" -takefocus 0
  pack $f.data.ybar -side right -fill y
  pack $f.data.text -side left -fill both -expand yes

  $f.list.text tag configure avail -foreground blue
  $f.list.text tag configure unavail -foreground gray40
  $f.data.text tag configure fen -foreground blue

  # Right frame: tablebase results for current position

  set f $w.pos
  text $f.text -width 30 -height 10 -font font_Small -wrap word \
    -foreground black -background white -yscrollcommand "$f.ybar set"
  scrollbar $f.ybar -command "$f.text yview" -takefocus 0
  pack $f.ybar -side right -fill y
  pack $f.text -side left -fill both -expand yes

  $f.text tag configure indent -lmargin2 [font measure font_Fixed  "        "]

  button $w.b.random -text "Random" -command ::tb::random
  checkbutton $w.b.training -text $::tr(Training) -variable tbTraining \
    -command ::tb::training -relief raised -padx 4 -pady 5
  button $w.b.help -text $::tr(Help) -command { helpWindow TB }
  button $w.b.close -text $::tr(Close) -command "destroy $w"
  label $w.b.status -width 1 -textvar tbStatus -font font_Small \
    -relief flat -anchor w -height 0
  pack $w.b.close $w.b.help -side right -padx 2 -pady 2
  pack $w.b.random $w.b.training -side left -padx 2 -pady 2
  pack $w.b.status -side left -fill x -expand yes
  bind $w <Destroy> { set tbWin 0; set tbTraining 0 }
  bind $w <F1> { helpWindow TB }
  bind $w <Configure> "recordWinSize $w"
  set ::tbTraining 0
  ::tb::section
  ::tb::summary
  ::tb::results
}

# ::tb::name
#   Converts a material string like "kqkr" or "KQKR" to "KQ-KR".
#
proc ::tb::name {s} {
  set s [string toupper $s]
  set idx [string last "K" $s]
  set new [string range $s 0 [expr $idx - 1]]
  append new "-"
  append new [string range $s $idx end]
  return $new
}

# ::tb::section
#   Updates the tablebase list for the specified section.
#
proc ::tb::section {{sec 0}} {
  global tbInfo
  set w .tbWin
  if {! [winfo exists $w]} { return }
  if {$sec == 0} { set sec $tbInfo(section)}
  set tbInfo(section) $sec
  if {! [info exists tbInfo($sec)]} { return }
  set t $w.info.list.text
  $t configure -state normal
  $t delete 1.0 end
  set count 0
  foreach tb $tbInfo($sec) {
    if {$tb == "-"} {
      $t insert end [format "%-7s" ""]
    } else {
      set avail [sc_info tb available $tb]
      if {$avail} {
        set taglist [list avail $tb]
      } else {
        set taglist [list unavail $tb]
      }
      $t insert end [format "%-6s" [::tb::name $tb]] $taglist
      $t insert end " "
      # Bind tags for enter/leave/buttonpress on this tb:
      $t tag bind $tb <Any-Enter> \
        [list $t tag configure $tb -foreground yellow -background darkBlue]
      $t tag bind $tb <Any-Leave> \
        [list $t tag configure $tb -foreground {} -background {}]
      $t tag bind $tb <ButtonPress-1> [list ::tb::summary $tb]
    }
    incr count
    if {$count == 5} { set count 0; $t insert end "\n" }
  }
  $t configure -state disabled
}

# ::tb::summary
#   Shows the tablebase information for the specified tablebase.
#
proc ::tb::summary {{material ""}} {
  global tbInfo tbs
  set w .tbWin
  if {! [winfo exists $w]} { return }

  if {$material == ""} { set material $tbInfo(material) }
  set tbInfo(material) $material
  set t $w.info.data.text
  $t configure -state normal
  $t delete 1.0 end
  $t insert end [format "%-6s" [::tb::name $material]]
  if {! [info exists tbs($material)]} {
    $t insert end "\nNo summary for this tablebase."
    $t configure -state disabled
    return
  }
  set data $tbs($material)

  $t insert end [format "    %5u games per million\n\n" [lindex $data 0]]

  # Longest-mate and result-percentage stats:

  $t insert end "Side    Longest    %     %     %\n"
  $t insert end "to move   mate    Win  Draw  Loss\n"
  $t insert end "---------------------------------\n"

  # Stats for White:
  $t insert end "White     "
  set len [lindex $data 1]
  set fen [lindex $data 2]
  if {$len == "0"} { set len "-" }
  if {[string length $fen] > 2} {
    append fen " w"
    $t insert end [format "%3s" $len] [list fen $fen]
    $t tag bind $fen <Any-Enter> \
      [list $t tag configure $fen -foreground yellow -background darkBlue]
    $t tag bind $fen <Any-Leave> \
      [list $t tag configure $fen -foreground {} -background {}]
    $t tag bind $fen <ButtonPress-1> [list ::tb::setFEN $fen]
  } else {
    $t insert end [format "%3s" $len]
  }
  $t insert end "  "
  $t insert end [format " %5s" [lindex $data 5]]
  $t insert end [format " %5s" [lindex $data 6]]
  $t insert end [format " %5s" [lindex $data 7]]
  $t insert end "\n"

  # Stats for Black:
  $t insert end "Black     "
  set len [lindex $data 3]
  set fen [lindex $data 4]
  if {$len == "0"} { set len "-" }
  if {[string length $fen] > 2} {
    append fen " b"
    $t insert end [format "%3s" $len] [list fen $fen]
    $t tag bind $fen <Any-Enter> \
      [list $t tag configure $fen -foreground yellow -background darkBlue]
    $t tag bind $fen <Any-Leave> \
      [list $t tag configure $fen -foreground {} -background {}]
    $t tag bind $fen <ButtonPress-1> [list ::tb::setFEN $fen]
  } else {
    $t insert end [format "%3s" $len]
  }
  $t insert end "  "
  $t insert end [format " %5s" [lindex $data 8]]
  $t insert end [format " %5s" [lindex $data 9]]
  $t insert end [format " %5s" [lindex $data 10]]
  $t insert end "\n\n"

  set mzugs [lindex $data 11]
  $t insert end "Mutual zugzwangs: "
  if {$mzugs >= 0} { $t insert end "$mzugs\n" } else { $t insert end "?\n" }
  if {$mzugs <= 0} {
    $t configure -state disabled
    return
  }

  # Extra Zugzwang info:
  set nBtmLoses [lindex $data 12]
  set nWtmLoses [lindex $data 14]
  set nBothLose [lindex $data 16]
  set zugnames [list " White draws, Black loses: " \
                  " Black draws, White loses: " \
                  " Whoever moves loses:      "]
  if {$nBtmLoses > 0} {
    $t insert end [lindex $zugnames 0]
    $t insert end [format "%5d\n" $nBtmLoses]
  }
  if {$nWtmLoses > 0} {
    $t insert end [lindex $zugnames 1]
    $t insert end [format "%5d\n" $nWtmLoses]
  }
  if {$nBothLose > 0} {
    $t insert end [lindex $zugnames 2]
    $t insert end [format "%5d\n" $nBothLose]
  }

  # Selected zugzwang positions:
  set btmFens [lindex $data 13]
  set wtmFens [lindex $data 15]
  set bothFens [lindex $data 17]
  set nBtmFens [llength $btmFens]
  set nWtmFens [llength $wtmFens]
  set nBothFens [llength $bothFens]
  set nTotalFens [expr $nBtmFens + $nWtmFens + $nBothFens]
  if {$nTotalFens == 0} {
    $t configure -state disabled
    return
  }

  # Print the lists of selected zugzwang positions:
  $t insert end "\nSelected zugzwang positions:"
  foreach n [list $nBtmFens $nWtmFens $nBothFens] \
    fenlist [list $btmFens $wtmFens $bothFens] \
    name $zugnames tomove [list b w w] {
      if {$n == 0} { continue }
      $t insert end "\n [string trim $name]"
      set count 0
      for {set count 0} {$count < $n} {incr count} {
        set fen [lindex $fenlist $count]
        if {[expr $count % 10] == 0} {
          $t insert end "\n  "
        }
        $t insert end " "
        append fen " $tomove"
        $t insert end [format "%2d" [expr $count + 1]] [list fen $fen]
        $t tag bind $fen <Any-Enter> \
          [list $t tag configure $fen -foreground yellow -background darkBlue]
        $t tag bind $fen <Any-Leave> \
          [list $t tag configure $fen -foreground {} -background {}]
        $t tag bind $fen <ButtonPress-1> [list ::tb::setFEN $fen]
      }
    }

  $t configure -state disabled
}

# ::tb::results
#   Called when the main window board changes, to display tablebase
#   results for all moves from the current position.
#
proc ::tb::results {} {
  global tbTraining
  set w .tbWin
  if {! [winfo exists $w]} { return }
  set t $w.pos.text
  $t delete 1.0 end
  if {$tbTraining} {
    $t insert end "\n (Training mode; results are hidden)"
  } else {
    $t insert end [sc_pos probe report] indent
  }
}

# ::tb::random
#   Sets up a random position with the material of the tablebase
#   currently displayed in the info frame.
#
proc ::tb::random {} {
  global tbInfo
  if {[catch {sc_game startBoard "random:$tbInfo(material)"} err]} {
    tk_messageBox -title "Scid" -icon warning -type ok -message $err
    return
  }
  # The material is valid, so clear the game and regenerate a
  # random starting position:
  sc_game new
  sc_game startBoard "random:$tbInfo(material)"
  updateBoardAndPgn
}

# ::tb::setFEN
#   Called when an item in the Tablebase info browser with an
#   associated FEN position is selected with the left mouse button,
#   causing the position to be set in the main window.
#
proc ::tb::setFEN {fen} {
  if {[catch {sc_game startBoard $fen} err]} {
    tk_messageBox -title "Scid" -icon info -type ok -message $err
    return
  }
  # The FEN is valid, so clear the game and reset the FEN:
  sc_game new
  sc_game startBoard $fen
  updateBoardAndPgn
}

# ::tb::training
#   Toggle tablebase training mode.
#
proc ::tb::training {} {
  global tbTraining tbStatus gameInfo
  set w .tbWin
  set tbStatus ""
  if {$tbTraining} {
    set gameInfo(showTB_old) $gameInfo(showTB)
    set gameInfo(showTB) 0
  } else {
    if {$gameInfo(showTB) == 0} { set gameInfo(showTB) $gameInfo(showTB_old) }
  }
  updateBoardAndPgn
  ::tb::results
}

# ::tb::move
#   Finds and executes the best move in the current position,
#   if one can be determined from the tablebases.
#
proc ::tb::move {} {
  global tbTraining tbStatus
  if {! $tbTraining} { return }
  set moves [split [sc_pos probe optimal]]
  set len [llength $moves]
  if {$len == 0} {
    set tbStatus "No optimal move was found."
    return
  }
  set i [expr int(rand() * $len)]
  set move [lindex $moves $i]
  if {[catch {sc_move addSan $move}]} {
    set tbStatus "Error playing $move."
  } else {
    set tbStatus "Played $move."
  }
  updateBoardAndPgn
}


# tbs:
#   Summary data about tablebases.
#   Each list has the following elements:
#     (0) Frequency (per million games),
#     (1) Longest-wtm-mate length, (2) Longest-wtm-mate FEN,
#     (3) Longest-btm-mate length, (4) Longest-btm-mate FEN,
#     (5) wtm-win-%, (6) wtm-draw-%, (7) wtm-loss-%,
#     (8) btm-win-%, (9) btm-draw-%, (10) btm-loss-%,
#     (11) number of mutual zugzwangs (-1 if unknown).
#  The longest-mate FENs have a board field only; no side to move, etc.
#
#   There are three types of mutual zugzwang:
#     wtm draws / btm loses, wtm loses / btm draws, wtm loses / btm loses.
#   The first two are "half-point" zugzwangs, the last is "full-point".
#
#   If the number of mutual zugzwangs is known and nonzero,
#   six more items should follow in the list:
#     (12) number of wtm-draws-btm-loses zugzwangs,
#     (13) list of selected wtm-draws-btm-loses zugzwang FENs,
#     (14) number of wtm-loses-btm-draws zugzwangs,
#     (15) list of selected wtm-loses-btm-draws zugzwang FENs,
#     (16) number of whoever-moves-loses (full-point) zugzwangs,
#     (17) list of selected whoever-moves-loses zugzwang FENs.
#   These zugzwang FENs board field only; no side to move, etc.

set tbs(kqk) {
  259 10 {7K/6Q1/8/8/2k5/8/8/8} 0 -
  100.0 0.0 0.0 0.0 10.3 89.7
  0
}

set tbs(krk) {
  543 16 {8/8/2R5/3k4/8/8/8/1K6} 0 -
  100.0 0.0 0.0 0.0 9.9 90.1
  0
}

set tbs(kbk) {
  184 0 - 0 -
  0.0 100.0 0.0 0.0 100.0 0.0
  0
}

set tbs(knk) {
  224 0 - 0 -
  0.0 100.0 0.0 0.0 100.0 0.0
  0
}

set tbs(kpk) {
  2345 28 {8/8/8/1k6/8/8/K5P1/8} 0 -
  76.5 23.5 0.0 0.0 41.9 58.1
  80 80 {} 0 {} 0 {}
}

set tbs(kqkq) {
  221 13 {8/8/8/8/8/8/8/qk1K2Q1} 13 {8/8/8/8/8/8/8/QK1k2q1}
  41.7 57.8 0.5 41.7 57.8 0.5
  0
}

set tbs(kqkr) {
  398 35 {K3r3/8/5k2/Q7/8/8/8/8} 19 {k7/5r2/K7/8/8/8/1Q6/8}
  99.0 0.8 0.2 28.7 5.8 65.5
  0
}

set tbs(kqkb) {
  26 17 {K7/8/8/3k4/4b3/8/8/7Q} 0 -
  99.7 0.3 0.0 0.0 23.1 76.9
  0
}

set tbs(kqkn) {
  72 21 {8/KQ6/2n5/2k5/8/8/8/8} 0 -
  99.3 0.7 0.0 0.0 19.5 80.5
  0
}

set tbs(kqkp) {
  931 28 {3KQ3/8/8/8/8/8/3kp3/8} 29 {8/1p4k1/7Q/8/7K/8/8/8}
  99.4 0.6 0.0 7.7 12.1 80.2
  0
}

set tbs(krkr) {
  417 19 {8/3R4/8/8/5k2/6r1/7K/8} 19 {1k6/2R5/3K4/8/8/8/6r1/8}
  29.1 70.2 0.7 29.1 70.2 0.7
  0
}

set tbs(krkb) {
  321 29 {k7/8/b7/8/K7/R7/8/8} 0 -
  35.2 64.8 0.0 0.0 96.8 3.2
  5  5 {
    4R3/8/8/8/8/b1K5/8/3k4 8/5R2/7b/8/8/2K5/8/1k6 8/8/1b6/5R2/8/3K4/8/2k5
    8/8/8/8/8/1k6/b7/R1K5 8/8/8/8/8/2K5/4k3/R2b4
  } 0 {} 0 {}
}

set tbs(krkn) {
  391 40 {8/8/6R1/2K5/n7/8/8/3k4} 1 {8/8/8/8/1n6/k7/8/KR6}
  48.4 51.6 0.0 0.0 89.0 11.0
  18 18 {
    8/2n5/8/4R3/3K1k2/8/8/8 8/8/5k2/4R3/3K4/2n5/8/8 8/8/8/1k6/2R5/3K4/4n3/8
    8/8/8/2n5/3K4/4R3/5k2/8 8/8/8/3k4/2R5/3K4/n7/8 8/8/8/3k4/4R3/3K4/6n1/8
    8/8/8/4k3/3R4/2K5/1n6/8 8/8/8/5k2/4R3/3K4/2n5/8 8/8/8/6n1/3K4/4R3/3k4/8
    8/8/8/8/2R5/1k1K4/4n3/8 8/8/8/8/3K1k2/4R3/8/2n5 8/8/8/8/3R4/2K1k3/1n6/8
    8/8/8/8/4R3/3K1k2/2n5/8 8/8/8/8/6n1/3K4/4R3/3k4 8/8/8/8/8/2KR4/8/2k2n2
    8/8/8/8/8/2RK4/8/n2k4 8/8/8/8/8/3KR3/8/3k2n1 8/8/8/n7/3K4/2R5/3k4/8
  } 0 {} 0 {}
}

set tbs(krkp) {
  2122 26 {2K5/8/7p/6k1/8/8/R7/8} 43 {8/8/8/8/5R2/2pk4/5K2/8}
  91.4 8.4 0.2 16.4 17.5 66.1
  12 12 {
    8/8/8/8/8/1k6/p7/R1K5   8/8/8/8/8/2k5/1p6/1R1K4 8/8/8/8/8/4k3/5p2/3K1R2
    8/3K4/8/3k4/3p4/8/8/3R4 8/1K6/8/1k6/1p6/8/8/1R6 8/2K5/8/2k5/2p5/8/8/2R5
    8/2K5/8/2k5/3p4/8/8/3R4 8/3K4/8/3k4/4p3/8/8/4R3 8/1K6/8/1k6/2p5/8/8/2R5
    8/2K5/8/2k5/1p6/8/8/1R6 8/3K4/8/3k4/2p5/8/8/2R5 8/K7/8/k7/1p6/8/8/1R6
  } 0 {} 0 {}
}

set tbs(kbkb) {
  51 1 {8/8/8/8/8/K7/7B/kb6} 1 {6BK/8/6k1/8/8/b7/8/8}
  0.0 100.0 0.0 0.0 100.0 0.0
  0
}

set tbs(kbkn) {
  82 1 {knB5/8/1K6/8/8/8/8/8} 1 {K1k1n3/B7/8/8/8/8/8/8}
  0.0 100.0 0.0 0.0 100.0 0.0
  0
}

set tbs(kbkp) {
  380 1 {7k/7p/5K2/8/8/8/1B6/8} 29 {8/1p4k1/7B/8/8/7K/8/8}
  0.0 94.8 5.2 23.6 76.4 0.0
  1 0 {} 1 {8/8/8/8/8/8/1pK5/kB6} 0 {}
}

set tbs(knkn) {
  68 1 {k7/n1K5/8/3N4/8/8/8/8} 1 {8/8/8/8/1n6/1k6/8/KN6}
  0.0 100.0 0.0 0.0 100.0 0.0
  0
}

set tbs(knkp) {
  492 7 {8/8/8/8/pN6/8/2K5/k7} 29 {8/1p6/6kN/8/8/7K/8/8}
  0.0 87.1 12.9 32.6 67.4 0.0
  29 22 {} 7 {} 0 {}
}

set tbs(kpkp) {
  2804 33 {2K5/k7/7p/8/8/8/6P1/8} 33 {8/2p1K3/8/8/8/4P3/8/3k4}
  43.4 33.3 23.2 43.4 33.3 23.2
  121 106 {} 106 {} 15 {
    8/8/8/1Kp5/2Pk4/8/8/8 8/8/8/2Kp4/3Pk3/8/8/8 8/8/8/8/1Kp5/2Pk4/8/8
    8/8/8/8/1pK5/kP6/8/8  8/8/8/8/2Kp4/3Pk3/8/8 8/8/8/8/2pK4/1kP5/8/8
    8/8/8/8/3Kp3/4Pk2/8/8 8/8/8/8/8/1Kp5/2Pk4/8 8/8/8/8/8/1pK5/kP6/8
    8/8/8/8/8/2Kp4/3Pk3/8 8/8/8/8/8/2pK4/1kP5/8 8/8/8/8/8/3Kp3/4Pk2/8
    8/8/8/8/8/Kp6/1Pk5/8  8/8/8/8/Kp6/1Pk5/8/8  8/8/8/Kp6/1Pk5/8/8/8
  }
}

set tbs(kqqk) {
  14 4 {8/8/8/4k3/8/8/1K6/QQ6} 0 -
  100.0 0.0 0.0 0.0 2.1 97.9
  0
}

set tbs(kqrk) {
  18 6 {7Q/8/8/8/4k3/8/8/1R5K} 0 -
  100.0 0.0 0.0 0.0 1.1 98.9
  0
}

set tbs(kqbk) {
  39 8 {8/Q4B2/5k2/8/8/8/8/K7} 0 -
  100.0 0.0 0.0 0.0 9.4 90.6
  0
}

set tbs(kqnk) {
  40 9 {K7/N7/8/8/8/5k2/Q7/8} 0 -
  100.0 0.0 0.0 0.0 9.7 90.3
  0
}

set tbs(kqpk) {
  154 10 {8/8/8/2k5/8/8/4P1Q1/7K} 0 -
  100.0 0.0 0.0 0.0 2.8 97.2
  0
}

set tbs(krrk) {
  9 7 {4R3/3k4/8/8/5R1K/8/8/8} 0 -
  100.0 0.0 0.0 0.0 0.3 99.7
  0
}

set tbs(krbk) {
  47 16 {8/8/3R4/4k3/4B3/8/8/K7} 0 -
  100.0 0.0 0.0 0.0 8.8 91.2
  0
}

set tbs(krnk) {
  12 16 {K7/2R5/3k4/3N4/8/8/8/8} 0 -
  100.0 0.0 0.0 0.0 9.2 90.8
  0
}

set tbs(krpk) {
  335 16 {K7/8/3R4/4kP2/8/8/8/8} 0 -
  100.0 0.0 0.0 0.0 2.5 97.5
  0
}

set tbs(kbbk) {
  33 19 {K7/8/3B4/3k4/8/8/4B3/8} 0 -
  49.3 50.7 0.0 0.0 58.8 41.2
  0
}

set tbs(kbnk) {
  203 33 {7K/4B3/4k3/8/8/8/8/2N5} 0 -
  99.5 0.5 0.0 0.0 18.1 81.9
  0
}

set tbs(kbpk) {
  449 31 {8/3P4/KBk5/8/8/8/8/8} 0 -
  96.0 4.0 0.0 0.0 16.8 83.2
  6 6 {
    1B1K4/8/8/k7/8/P7/8/8 1B6/3K4/8/1k6/8/P7/8/8 1BK5/8/1k6/8/8/P7/8/8
    8/B1k5/K7/P7/8/8/8/8 kB6/8/1PK5/8/8/8/8/8 kB6/8/KP6/8/8/8/8/8
  } 0 {} 0 {}
}

set tbs(knnk) {
  19 1 {k7/3N4/K1N5/8/8/8/8/8} 0 -
  0.0 100.0 0.0 0.0 100.0 0.0
  0
}

set tbs(knpk) {
  426 27 {1N6/8/8/8/8/2k3P1/8/2K5} 0 -
  96.3 3.7 0.0 0.0 18.5 81.5
  75 75 {} 0 {} 0 {}
}

set tbs(kppk) {
  571 32 {8/8/8/8/2k5/6P1/K5P1/8} 0 -
  98.4 1.6 0.0 0.0 7.9 92.1
  43 43 {} 0 {} 0 {}
}

set tbs(kqqkq) {
  49 30 {2K5/8/1k6/5q2/8/8/6Q1/7Q} 13 {7Q/7K/8/6Qk/8/8/7q/8}
  99.1 0.8 0.1 0.6 32.8 66.6
  0
}

set tbs(kqqkr) {
  0 35 {Kr6/8/8/8/8/3Q4/4Q3/2k5} 19 {6Q1/8/8/8/8/7K/2r4Q/7k}
  100.0 0.0 0.0 0.1 0.2 99.7
  0
}

set tbs(kqqkb) {
  0 15 {8/8/7Q/5k1K/7Q/5b2/8/8} 0 -
  100.0 0.0 0.0 0.0 0.1 99.9
  0
}

set tbs(kqqkn) {
  0 19 {5K2/3n4/4k3/2Q5/8/8/8/1Q6} 0 -
  100.0 0.0 0.0 0.0 0.1 99.9
  0
}

set tbs(kqqkp) {
  7 22 {8/8/8/3Q4/7Q/2k5/1p6/K7} 13 ?
  100.0 0.0 0.0 0.0 0.7 99.3
  0
}

set tbs(kqrkq) {
  33 67 ? 38 ?
  97.0 2.8 0.2 24.4 21.2 54.4
  1 1 {8/8/8/8/1R6/k4q2/8/1K2Q3} 0 {} 0 {}
}

set tbs(kqrkr) {
  123 34 {1K2Q3/8/3k4/1r2R3/8/8/8/8} 20 {6rQ/8/8/8/8/7K/5R2/6k1}
  99.8 0.1 0.0 0.3 17.1 82.1
  0
}

set tbs(kqrkb) {
  11 29 {2k5/5b2/8/8/2K5/8/Q7/6R1} 0 -
  100.0 0.0 0.0 0.0 11.6 88.4
  0
}

set tbs(kqrkn) {
  2 40 ? 1 {8/8/8/8/1n6/k7/8/KR5Q}
  99.9 0.1 0.0 0.0 7.7 92.3
  0
}

set tbs(kqrkp) {
  23 40 ? 43 ?
  100.0 0.0 0.0 0.3 1.4 98.3
  0
}

set tbs(kqbkq) {
  30 33 {5q2/8/8/5B2/k1K4Q/8/8/8} 24 {6KQ/8/1B6/6k1/8/6q1/8/8}
  55.7 44.0 0.3 30.5 62.3 7.2
  25 25 {} 0 {} 0 {}
}

set tbs(kqbkr) {
  21 40 ? 30 ?
  99.3 0.6 0.0 0.7 27.5 71.8
  0
}

set tbs(kqbkb) {
  2 17 ? 2 ?
  99.7 0.3 0.0 0.0 19.8 80.2
  0
}

set tbs(kqbkn) {
  2 21 ? 1 ?
  99.5 0.5 0.0 0.0 16.7 83.3
  0
}

set tbs(kqbkp) {
  23 32 ? 24 ?
  100.0 0.0 0.0 1.0 14.1 84.9
  0
}

set tbs(kqnkq) {
  75 41 {8/7q/8/k7/2K5/2N5/8/4Q3} 24 {7K/8/1N6/Q5k1/8/8/6q1/8}
  50.1 49.6 0.3 33.5 62.2 4.3
  38 38 {} 0 {} 0 {}
}

set tbs(kqnkr) {
  11 38 ? 41 ?
  99.2 0.7 0.0 3.0 27.2 69.8
  0
}

set tbs(kqnkb) {
  7 17 ? 1 ?
  99.8 0.2 0.0 0.0 20.9 79.1
  0
}

set tbs(kqnkn) {
  14 21 ? 1 ?
  99.4 0.6 0.0 0.0 17.8 82.2
  0
}

set tbs(kqnkp) {
  42 30 ? 29 ?
  99.9 0.1 0.0 1.9 15.0 83.1
  0
}

set tbs(kqpkq) {
  1165 124 {4q3/K7/8/8/8/4P3/6Q1/k7} 29 {8/7q/3PK3/8/8/8/Q7/3k4}
  68.4 31.2 0.4 35.2 51.2 13.6
  640 640 {} 0 {} 0 {}
}

set tbs(kqpkr) {
  214 38 ? 33 ?
  99.6 0.3 0.1 19.7 6.1 74.1
  1 1 {k7/8/KQ1r4/P7/8/8/8/8} 0 {} 0 {}
}

set tbs(kqpkb) {
  18 28 ? 2 ?
  99.9 0.1 0.0 0.0 16.7 83.3
  0
}

set tbs(kqpkn) {
  44 30 ? 8 ?
  99.7 0.3 0.0 0.0 12.5 87.5
  0
}

set tbs(kqpkp) {
  601 105 ? 34 ?
  100.0 0.0 0.0 3.3 7.3 89.4
  0
}

set tbs(krrkq) {
  9 29 ? 49 ?
  58.2 36.8 5.1 52.0 37.0 11.0
  10 10 {
    6R1/8/8/8/6R1/7q/1K5k/8 6R1/8/8/8/8/6R1/7q/K6k  8/6R1/8/8/8/3K2R1/7q/7k
    8/6R1/8/8/8/6R1/7q/1K5k 8/8/1R6/8/8/1R1K4/q7/k7 8/8/6R1/8/8/6R1/7q/2K4k
    8/8/8/3R4/8/k7/2KR4/4q3 8/8/8/6R1/8/6R1/7q/3K3k 8/8/8/8/1R6/1R6/q7/k2K4
    8/8/8/8/8/2K5/2R1R3/kq6
  } 0 {} 0 {}
}

set tbs(krrkr) {
  37 31 {8/1R6/8/8/8/5r1K/4R3/k7} 20 {1k6/2R5/7r/3K3R/8/8/8/8}
  99.2 0.7 0.0 0.4 33.4 66.2
  0
}

set tbs(krrkb) {
  9 29 ? 0 -
  99.3 0.7 0.0 0.0 22.4 77.6
  1 1 {8/8/8/8/8/b1k5/1R6/1RK5} 0 {} 0 {}
}

set tbs(krrkn) {
  9 40 ? 1 {8/8/8/8/1n6/k7/8/KR1R4}
  99.7 0.3 0.0 0.0 15.0 85.0
  0
}

set tbs(krrkp) {
  2 33 ? 50 ?
  100.0 0.0 0.0 1.0 5.7 93.3
  0
}

set tbs(krbkq) {
  21 21 ? 70 ?
  38.7 48.0 13.4 71.2 25.6 3.2
  372 0 {} 372 {3Kn3/8/8/8/8/4r3/7Q/3k4} 0 {}
}

set tbs(krbkr) {
  668 65 {k7/7r/3K4/8/6B1/8/4R3/8} 30 {8/4R2K/8/5k2/8/8/7B/4r3}
  41.3 58.7 0.0 0.8 94.1 5.1
  17 17 {
    8/8/8/8/8/1R1K4/2B5/r1k5 8/8/8/8/8/2KB4/2R5/kr6   8/8/8/8/7B/4r3/5R2/2K1k3
    8/8/8/8/rB6/8/1R6/1K1k4  7k/6R1/7r/8/8/8/1B6/1K6  8/8/8/8/8/2K4B/6R1/3r1k2
    8/8/8/8/4R3/k7/2K1B3/4r3 8/8/8/8/8/2R3Br/k1K5/8   8/8/8/3B1r2/3K4/8/6R1/3k4
    8/8/8/8/8/R2K4/5B2/1r1k4 8/8/8/8/8/3K2R1/8/4k1Br  8/8/8/2B5/8/6r1/k1K4R/8
    8/5r2/8/8/1R4B1/8/3K4/k7 8/8/3B4/1r6/8/2K5/4R3/1k6 8/8/8/8/3KB2r/8/5R2/k7
    8/8/3B4/8/8/5r2/k1K1R3/8 5R2/8/8/8/8/3K4/5Br1/2k5
  } 0 {} 0 {}
}

set tbs(krbkb) {
  18 30 ? 2 ?
  98.2 1.8 0.0 0.0 31.1 68.9
  0
}

set tbs(krbkn) {
  4 40 ? 1 ?
  98.9 1.1 0.0 0.0 24.0 76.0
  0
}

set tbs(krbkp) {
  32 28 ? 70 ?
  99.1 0.9 0.0 2.4 17.1 80.5
  1 1 {1k1K4/7R/8/8/8/8/6p1/7B} 0 {} 0 {}
}

set tbs(krnkq) {
  16 20 ? 69 ?
  35.4 41.1 23.4 78.2 19.7 2.1
  455 0 {} 455 {} 0 {}
}

set tbs(krnkr) {
  435 37 {2k1r3/8/R7/N2K4/8/8/8/8} 41 {4K3/8/1r6/8/5k2/1R4N1/8/8}
  36.7 63.3 0.1 3.2 93.6 3.2
  10 10 {
    2R5/8/8/8/8/k2K4/8/r1N5  8/8/8/8/3N4/1R1K4/8/r1k5 8/8/8/8/3N4/2KR4/8/2k1r3
    8/8/8/8/4N3/7R/k1K5/5r2  8/8/8/8/8/2KRN3/8/2k1r3  8/8/8/8/8/3KN3/3R4/2k1r3
    8/8/8/8/8/5RN1/8/2K1k1r1 8/8/8/8/8/6RN/8/3K1k1r   8/8/8/8/8/NR1K4/8/r1k5
    8/8/8/8/r1N5/2R5/k1K5/8
  } 0 {} 0 {}
}

set tbs(krnkb) {
  7 31 ? 1 ?
  97.7 2.3 0.0 0.0 32.4 67.6
  0
}

set tbs(krnkn) {
  11 37 ? 1 ?
  99.0 1.0 0.0 0.0 24.6 75.4
  3 3 {
    8/8/8/8/4n3/1k6/N7/R1K5 8/8/8/8/8/3n4/N2k4/RK6 8/8/8/8/8/n7/1k6/N1RK4
  } 0 {} 0 {}
}

set tbs(krnkp) {
  32 29 ? 68 ?
  98.5 1.5 0.0 4.5 17.1 78.4
  0
}

set tbs(krpkq) {
  366 68 ? 104 ?
  37.7 11.8 50.5 91.0 7.1 1.8
  243 2 {} 241 {} 0 {}
}

set tbs(krpkr) {
  9138 74 {8/1k6/4R3/8/8/8/6Pr/4K3} 33 {8/1P6/2k5/8/K7/8/8/1r5R}
  66.6 33.0 0.4 20.1 54.4 25.5
  209 209 {} 0 {} 0 {}
}

set tbs(krpkb) {
  615 73 ? 2 ?
  96.4 3.6 0.0 0.0 32.6 67.4
  225 225 {} 0 {} 0 {}
}

set tbs(krpkn) {
  398 54 ? 8 ?
  97.5 2.5 0.0 0.0 24.7 75.3
  413 413 {} 0 {} 0 {} 0 {}
}

set tbs(krpkp) {
  1069 56 ? 103 ?
  99.4 0.4 0.3 10.0 6.6 83.5
  3 0 {} 2 {
    8/8/8/8/8/1p6/kP6/1RK5 8/8/8/8/8/k7/Pp6/RK6
  } 1 {8/8/8/8/8/2p5/1kP5/2RK4}
}

set tbs(kbbkq) {
  4 21 ? 81 ?
  15.3 20.2 64.5 96.5 2.9 0.6
  1 0 {} 1 {8/8/8/8/q7/2BB4/1K6/3k4} 0 {}
}

set tbs(kbbkr) {
  14 23 {4r3/8/8/8/8/4B3/8/k1K4B} 31 {1K4B1/8/3k4/8/B5r1/8/8/8}
  16.5 83.4 0.1 1.3 97.2 1.5
  3 3 {
    8/8/8/8/8/3K1k2/6r1/4B2B 8/8/8/8/8/5k2/6r1/3KB2B 8/8/8/B7/8/3k4/2r5/KB6
  } 0 {} 0 {}
}

set tbs(kbbkb) {
  37 22 {6B1/8/7B/8/b7/2K5/8/k7} 2 {1B5K/5k1B/8/8/8/4b3/8/8}
  15.6 84.3 0.0 0.0 98.6 1.4
  0
}

set tbs(kbbkn) {
  30 78 {8/K7/8/8/8/5k2/6n1/2B4B} 1 ?
  48.2 51.8 0.0 0.0 66.1 33.9
  1 1 {8/8/8/8/8/6n1/2K4B/kB6} 0 {} 0 {}
}

set tbs(kbbkp) {
  25 74 ? 83 ?
  48.0 50.2 1.8 11.4 54.1 34.5
  1 1 {B1k5/1pB5/3K4/8/8/8/8/8} 0 {} 0 {}
}

set tbs(kbnkq) {
  12 36 ? 53 ?
  25.0 6.4 68.6 97.6 1.7 0.7
  1 0 {} 1 {8/8/q7/8/3K4/2N5/8/k1B5} 0 {}
}

set tbs(kbnkr) {
  65 36 {8/8/8/2N5/8/8/B6K/5kr1} 41 {8/8/1B4N1/5k2/8/1r6/8/4K3}
  26.0 73.8 0.2 3.8 94.6 1.6
  8 6 {
    3r4/8/2B5/8/1N6/8/8/k1K5 8/8/8/8/8/2k5/1r6/B1NK4  8/8/8/8/8/2k5/3r4/1KN1B3
    8/8/8/8/8/3k4/4r3/2KN1B2 8/8/8/8/8/4k3/5r2/3KN1B1 8/8/8/8/B7/1r6/N1k5/K7
  } 2 {8/8/8/8/8/1k3r2/8/1KB4N 8/r7/8/B7/8/8/N1k5/K7} 0 {}
}

set tbs(kbnkb) {
  53 39 {8/7B/8/8/6N1/8/3k4/1Kb5} 2 {KB6/8/k4N2/8/6b1/8/8/8}
  25.5 74.5 0.0 0.0 98.8 1.2
  45 45 {} 0 {} 0 {}
}

set tbs(kbnkn) {
  32 107 {6Bk/8/8/7N/8/7K/6n1/8} 1 {8/8/3N4/8/3n4/8/B7/K1k5}
  32.2 67.8 0.0 0.0 96.1 3.9
  922 922 {} 0 {} 0 {}
}

set tbs(kbnkp) {
  166 104 ? 55 ?
  91.4 5.5 3.2 14.7 23.0 62.4
  62 61 {} 1 {8/8/8/1N6/3K4/B7/5p2/k7} 0 {}
}

set tbs(kbpkq) {
  119 35 ? 50 ?
  21.3 11.5 67.2 96.8 2.8 0.4
  16 0 {} 16 {
    3K4/2P5/B3qk2/8/8/8/8/8   8/1KP1q3/1B1k4/8/8/8/8/8 8/qPK5/8/3k4/1B6/8/8/8
    2q5/2B2P2/3K4/1k6/8/8/8/8 8/2P5/4q3/KB6/8/k7/8/8   8/3P4/5q2/1KB5/8/1k6/8/8
    8/1KP1q3/4k3/B7/8/8/8/8   3K4/q1P5/B4k2/8/8/8/8/8  8/5P2/3K4/8/4k2B/7q/8/8
    8/4P3/6q1/k1K5/2B5/8/8/8  3k4/KP1q4/3B4/8/8/8/8/8  8/3K1P2/1k2Bq2/8/8/8/8/8
    3K4/2P5/2B2k2/8/1q6/8/8/8 8/1P1K4/1qB2k2/8/8/8/8/8 1k6/3K1P2/4Bq2/8/8/8/8/8
    5k2/1P1K4/1qB5/8/8/8/8/8
  } 0 {}
}

set tbs(kbpkr) {
  440 45 ? 39 ?
  30.9 67.3 1.8 23.4 73.1 3.5
  306 4 {} 302 {} 0 {}
}

set tbs(kbpkb) {
  564 51 ? 3 ?
  41.3 58.7 0.0 0.0 86.9 13.1
  160 160 {} 0 {} 0 {}
}

set tbs(kbpkn) {
  449 105 ? 8 ?
  53.7 46.3 0.0 0.0 76.4 23.6
  2125 2112 {} 13 {} 0 {}
}

set tbs(kbpkp) {
  1437 67 ? 51 ?
  86.4 9.5 4.1 16.7 24.1 59.2
  406 403 {} 2 {} 1 {8/8/8/8/8/k1p5/2P5/1BK5}
}

set tbs(knnkq) {
  4 1 {k1N5/2K5/8/3N4/8/5q2/8/8} 72 ?
  0.0 42.8 57.1 94.0 6.0 0.0
  229 0 {} 229 {} 0 {}
}

set tbs(knnkr) {
  16 3 {5r1k/8/7K/4N3/5N2/8/8/8} 41 {8/8/1r4N1/4kN2/8/8/8/4K3}
  0.0 99.6 0.4 6.3 93.7 0.0
  25 0 {} 25 {} 0 {}
}

set tbs(knnkb) {
  2 4 {7k/5K2/8/8/5NN1/8/8/2b5} 1 {8/8/8/8/8/8/N1k5/K1b4N}
  0.0 100.0 0.0 0.0 100.0 0.0
  0
}

set tbs(knnkn) {
  9 7 {7n/8/8/8/1N1KN3/8/8/k7} 1 {K7/N1k5/8/3n4/3N4/8/8/8}
  0.1 99.9 0.0 0.0 100.0 0.0
  362 362 {} 0 {} 0 {}
}

set tbs(knnkp) {
  70 115 ? 74 ?
  31.3 66.4 2.3 12.8 73.6 13.6
  3143 3124 {} 19 {} 0 {}
}

set tbs(knpkq) {
  131 41 ? 55 ?
  17.9 11.9 70.2 97.2 2.3 0.5
  52 0 {} 52 {} 0 {}
}

set tbs(knpkr) {
  424 44 ? 67 ?
  26.7 69.3 4.0 29.3 68.5 2.2
  1181 23 {} 1158 {} 0 {}
}

set tbs(knpkb) {
  740 43 ? 9 ?
  38.8 61.2 0.0 0.0 88.1 11.9
  642 640 {} 2 {} 0 {}
}

set tbs(knpkn) {
  773 97 ? 7 ?
  49.2 50.8 0.0 0.0 77.2 22.8
  4191 4128 {} 63 {} 0 {}
}

set tbs(knpkp) {
  1399 57 ? 58 ?
  78.3 13.6 8.1 21.8 27.6 50.6
  2303 2281 {} 14 {} 8 {
    8/8/8/8/3K4/NkpP4/8/8   8/8/8/8/3K4/3PpkN1/8/8 8/8/8/8/8/1k2p3/4P3/KN6
    8/8/8/8/8/2K5/2PpkN2/8  8/8/8/8/8/3K4/3PpkN1/8 8/8/8/8/8/3K4/NkpP4/8
    8/8/8/8/1p6/1P6/K7/N1k5 8/8/8/8/8/1K6/1PpkN3/8
  }
}

set tbs(kppkq) {
  713 124 {8/5P2/8/8/3K4/3P3q/7k/8} 41 {8/2KP2q1/8/2P5/5k2/8/8/8}
  16.0 12.6 71.4 98.4 1.5 0.1
  2 0 {} 2 {8/2KP3q/2P2k2/8/8/8/8/8 8/2KP3q/8/2P3k1/8/8/8/8} 0 {}
}

set tbs(kppkr) {
  1675 54 {3K4/8/8/4P3/8/2r5/5P2/2k5} 40 {8/8/8/7K/5P2/3Pr3/8/2k5}
  35.4 20.1 44.5 75.2 18.2 6.6
  119 18 {} 99 {} 2 {1r1k4/1P6/1PK5/8/8/8/8/8 8/8/8/8/k7/r1P5/1KP5/8}
}

set tbs(kppkb) {
  522 43 {8/6P1/7k/8/6P1/1K6/8/1b6} 4 {K5b1/P7/1k6/8/8/8/2P5/8}
  54.4 45.6 0.0 0.0 75.4 24.6
  212 211 {} 1 {8/8/8/8/8/b2k4/P2P4/1K6} 0 {}
}

set tbs(kppkn) {
  703 50 {3n4/5P2/8/8/3K2P1/8/k7/8} 17 {7K/8/4k2P/8/8/8/5P2/5n2}
  64.7 35.3 0.0 0.0 62.4 37.6
  1077 920 {} 157 {} 0 {}
}

set tbs(kppkp) {
  5096 127 {8/8/8/8/1p2P3/1k1KP3/8/8} 43 {7K/8/4P3/5P2/3k4/7p/8/8}
  77.1 10.3 12.6 27.7 19.1 53.2
  4237 4179 {} 52 {} 6 {
    8/8/8/8/2k5/K1p5/P3P3/8   8/8/8/8/3k4/1K1p4/1P3P2/8
    8/8/8/8/4k3/2K1p3/2P3P1/8 8/8/8/2k5/K1p5/P3P3/8/8
    8/8/8/8/5k2/3K1p2/3P3P/8  8/8/8/k7/p1K5/2P5/2P5/8
  }
}

set tbs(kqppk) {
  68 9 ? 0 -
  100.0 0.0 0.0 0.0 0.7 99.3
}

set tbs(krppk) {
  119 15 {8/8/4k3/8/8/3P4/3P4/5R1K} 0 -
  100.0 0.0 0.0 0.0 0.2 98.8
  0
}

set tbs(kbppk) {
  91 25 ? 0 -
  99.8 0.2 0.0 0.0 1.3 98.7
  6 6 {
    8/B1k5/K7/P7/P7/8/8/8 K7/8/1k6/1P6/BP6/8/8/8 K7/8/Bk6/1P6/1P6/8/8/8
    KBk5/P1P5/8/8/8/8/8/8 kB6/8/1PK5/1P6/8/8/8/8 kB6/8/KP6/1P6/8/8/8/8
  } 0 {} 0 {}
}

set tbs(knppk) {
  96 32 ? 0 -
  100.0 0.0 0.0 0.0 1.0 99.0
  93 93 {} 0 {} 0 {}
}

set tbs(kpppk) {
  98 33 {7K/5k2/8/8/1P6/1P6/1P6/8} 0 -
  99.9 0.1 0.0 0.0 0.6 99.4
  11 11 {
    1k6/1P6/K7/P7/P7/8/8/8  1k6/1P6/K7/PP6/8/8/8/8  2k5/2P5/3K4/P7/P7/8/8/8
    8/1k6/1P6/KP6/1P6/8/8/8 8/8/1k6/1P6/KP6/1P6/8/8 8/8/8/1k1P4/8/PK6/P7/8
    8/8/8/1k6/1P6/KP6/1P6/8 8/K1k5/P1P5/P7/8/8/8/8  K1k5/2P5/P1P5/8/8/8/8/8
    K1k5/8/P1P5/P7/8/8/8/8  k7/8/KP6/PP6/8/8/8/8
  } 0 {} 0 {}
}

# End of file: tb.tcl

