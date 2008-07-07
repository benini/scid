### ScidPocket.
### Copyright (C) 2007  Pascal Georges

if {$WindowsCE} {package require wce}
################################################################################
#                            U I
################################################################################
namespace eval ui { }
################################################################################
proc ::ui::setFullSize {w {topmost 1} } {
  global ::board::width ::board::height
  
  if {$::WindowsCE} {
    bind $w <ConfigureRequest> {::etcl::autofit %W}
    bind $w <Expose> {::etcl::autofit %W}
    ::etcl::autofit $w
    return
  }
  
  $w configure -borderwidth 0 -highlightthickness 0
  
  set  h [expr $height - 20]
  
  wm geometry $w "=${width}x$h"
  if {$topmost} {
    ::ui::setTopmost $w
  }
}

################################################################################
# combobox has a bug when mapped in a topmost window, so inhibit it now
################################################################################
proc ::ui::setTopmost {w} {
  if {$::WindowsCE} {
    # wm attributes $w -topmost 1
  }
}
################################################################################
proc ::ui::CurrentBoard {} {
  ::search::board
}
################################################################################
proc ::ui::Header {} {
  ::search::header
}
################################################################################
proc ::ui::MaterialPattern {} {
  ::search::material
}
################################################################################
proc ::ui::ResetFilter {} {
  ::search::filter::reset
}
################################################################################
proc ::ui::CopyFilter {target} {
  ::base::copyFilter [sc_base current] $target
}
################################################################################
proc ::ui::NegateFilter {} {
  ::search::filter::negate
}
################################################################################
proc ::ui::FilterInfo {} {
  set stats [sc_filter stats all]
  set total [lindex $stats 0]
  set white [lindex $stats 1]
  set draw [lindex $stats 2]
  set black [lindex $stats 3]
  set wsc [lindex $stats 4]
  
  set msg "Filter : $total games\nWhite wins : $white\nBlack wins $black\nDraws : $draw\nWhite score : $wsc\n[sc_base numGames] games in total"
  tk_messageBox -type ok -icon info -parent . -title "Filter info" -message $msg
}
################################################################################
proc ::ui::showTree {} {
  if {$::options(showTree)} {
    ::infopanel::updateTreeText
  } else {
    ::infopanel::clearTreeText
    sc_tree free
  }
}
################################################################################
proc ::ui::updateMenus {} {
  for {set i 1} {$i < [sc_base count total]} {incr i} {
    set n [sc_base filename $i]
    if {$n != "\[empty\]"} {
      set n [ file root [file tail $n]]
    } else  {
      set n "\[[::msgcat::mc empty]\]"
    }
    .menu.switch entryconfigure [expr $i-1] -label "$i.$n"
    .menu.copy entryconfigure [expr $i-1] -label "$i.$n"
  }
  
  .menu.base.recent delete 0 end
  foreach name $::options(recentBases) {
    .menu.base.recent add command -label [file rootname [file tail $name]] -command  "::base::baseOpen [list $name]"
  }
}

################################################################################
proc ::ui::showBook {} {
  if {$::options(showBook)} {
    ::book::scBookOpen $::options(mainBook) $::book::bookSlot
    ::infopanel::updateBookText
    ::book::closeMainBook
  } else {
    ::book::closeMainBook
    ::infopanel::clearBookText
  }
}
################################################################################
proc ::ui::showAnalysis {} {
  if {$::options(showAnalysis)} {
    ::infopanel::updateAnalysis
  } else {
    ::infopanel::clearAnalysisText
  }
}
################################################################################
proc ::ui::showComments {} {
  if {$::options(showComments)} {
    ::infopanel::updateComments
  } else {
    ::infopanel::clearComments
  }
}
#####################################################
# set theme and correct widget size
proc ::ui::setTheme {} {
  
  ttk::style theme use $::options(theme)
  
  if {$::hires} {
    option add *Scrollbar.width 20
    ttk::style configure TScrollbar -width 20 -arrowsize 20
  } else  {
    ttk::style configure TButton -padding { 0 0 } -width 0
  }
}
################################################################################
proc ::ui::About {} {
  # set qinfor [sc_msg info 1 read]
  # set qinfow [sc_msg info 1 write]
  # set msg "read $qinfor\nwrite $qinfow"
  # DEBUG (loads all games of a DB in order to check it)
  # for {set i 0 } {$i < [sc_base numGames]} { incr i} {
  # ::game::gameLoadNextPrev next
  # update
  # while {![sc_pos isAt end]} {
  # ::board::Forward
  # update
  # }
  # }

  tk_messageBox -type ok -icon info -parent .fTop -title "About" -message \
      "Engine #1 : [::engine::getName 1]\nEngine #2 : [::engine::getName 2]\n$::scidppc_version\nScid Pocket is based on Scid\nhttp://prolinux.free.fr/scid\nReleased under GPL (free)\n[sc_info pocket]"
}

################################################################################
#               I N F O P A N E L
################################################################################
namespace eval infopanel { }

################################################################################
proc ::infopanel::init {} {
  set w .fEngine.text
  setFontSize
  $w configure -wrap $::options(wrap) -background grey94 ;#-setgrid 1
  $w tag configure enginescore -foreground red -background black -relief raised -border 1 -font fontanalysis
  $w tag configure enginedepth -foreground black -background white -font fontanalysis
  $w tag configure enginepv -foreground blue -background white -relief sunken -border 1 -font fontanalysis
  $w tag configure enginemultipv -foreground black -background white -font fontanalysis
  $w tag configure engineinfo -foreground yellow -background grey20 -font fontanalysis
  $w tag configure tree -foreground black -background seashell2 -font fontanalysis
  $w tag configure treeScore -foreground red -background seashell2  -font fontanalysis
  $w tag configure treeTitle -foreground seashell2 -background DodgerBlue4 -font fontanalysis
  $w tag configure treeTitleScore -foreground red -background DodgerBlue4 -font fontanalysis
  $w tag configure book -foreground white -background DarkRed -font fontanalysis
  $w tag configure commentstext -foreground black -background azure -font fontanalysis
  $w tag configure commentsnag -foreground blue -background azure -font fontanalysis
  $w tag configure clock1 -font fontanalysis -foreground black -background white
  $w tag configure clock2 -font fontanalysis -foreground black -background white
  
  ::ui::showComments
  ::ui::showBook
  ::ui::showTree
}
################################################################################
proc ::infopanel::setFontSize {} {
  catch { font delete fontanalysis }
  font create fontanalysis -size $::options(fontAnalysisSize) -family Courier
}
################################################################################
proc ::infopanel::updateAnalysis {{n 1}} {
  global ::engine::data
  
  # Don't update if tactical training is running
  if {$::tactics::running} {return}
  
  set w .fEngine.text
  clearAnalysisText
  if {!$::options(showAnalysis)} {
    $w insert end [::msgcat::mc "Analysis hidden"] enginescore
    return
  }
  set l [lindex $data(multipv$n) 0]
  if { $::options(engineExtendedInfo) } {
    set extendedInfo "($data(seldepth$n))-$data(currmove$n)-"
  } else {
    set extendedInfo ""
  }
  $w insert end "[lindex $l 0]$extendedInfo" enginedepth
  if { [lindex $l 1] != "" } {
    if { [expr abs([lindex $l 1])] == 327.0 && [lindex $l 3] != "" } {
      $w insert end " M [lindex $l 3]" enginescore
    } else {
      set sc ""
      catch { set sc [ format "%.1f" [lindex $l 1] ] }
      $w insert end " $sc" enginescore
    }
  }
  if {$::options(scoreOnly)} {
    return
  }
  set extendedInfo ""
  if { $::options(engineExtendedInfo) } {
    set extendedInfo " hash [expr round($data(hashfull$n)/10)]%"
  }
  $w insert end " [expr round($data(nodes$n)/1000)] kn $data(nps$n) nps [expr round($data(time$n)/1000)] s$extendedInfo" engineinfo
  $w insert end "\n" engineinfo
  
  $w insert end "[lindex $l 2]\n" enginepv
  for {set i 1} { $i < $::options(multipv)} {incr i} {
    set l [lindex $data(multipv$n) $i ]
    $w insert end "$i> [lindex $l 0] " enginemultipv
    set sc ""
    catch { set sc [ format "%.1f" [lindex $l 1] ] }
    $w insert end "$sc" enginescore
    $w insert end "[lindex $l 2]\n" enginemultipv
  }
}
################################################################################
proc ::infopanel::clearAnalysisText {} {
  set txt .fEngine.text
  foreach tag {enginescore enginedepth enginepv enginemultipv engineinfo} {
    while {1} {
      set del [$txt tag nextrange $tag 1.0]
      if {$del == ""} {break}
      catch {$txt delete [lindex $del 0] [lindex $del 1]}
    }
  }
}

################################################################################
proc ::infopanel::updateComments {} {
  set txt .fEngine.text
  clearComments
  if {!$::options(showComments)} {
    return
  }
  set nags [sc_pos getNags]
  if {$nags == "0"} {set nags ""}
  set comment [sc_pos getComment]
  if {$nags == "" && $comment == ""} {return}
  $txt insert 1.0 "$nags" commentsnag " $comment\n" commentstext
}
################################################################################
proc ::infopanel::clearComments {} {
  set txt .fEngine.text
  foreach tag {commentstext commentsnag} {
    while {1} {
      set del [$txt tag nextrange $tag 1.0]
      if {$del == ""} {break}
      catch {$txt delete [lindex $del 0] [lindex $del 1]}
    }
  }
}
################################################################################
proc ::infopanel::clearTreeText {} {
  set txt .fEngine.text
  foreach tag {treeTitle tree treeScore treeTitleScore} {
    while {1} {
      set del [$txt tag nextrange $tag 1.0]
      if {$del == ""} {break}
      catch {$txt delete [lindex $del 0] [lindex $del 1]}
    }
  }
}
################################################################################
proc ::infopanel::getTreeLoc {} {
  set txt .fEngine.text
  # warning : enginedepth must be the first tag of analysis text
  set loc [lindex [$txt tag nextrange enginedepth 1.0] 0]
  if {$loc == "" } { set loc end }
  return $loc
}
################################################################################
proc ::infopanel::getBookLoc {} {
  set txt .fEngine.text
  set loc [lindex [$txt tag nextrange commentstext 1.0] 1]
  if {$loc == "" } { set loc [lindex [$txt tag nextrange commentsnag 1.0] 1] }
  if {$loc == "" } { set loc 1.0 }
  return $loc
}
################################################################################
# returns arg with spaces so its length is up to size
proc ::infopanel::padSpaces { arg size } {
  set spc " "
  set count [expr $size - [string length $arg]]
  if {$count < 0 } {set count 0}
  set tmp "$arg[string repeat $spc $count]"
  return $tmp
}
################################################################################
proc ::infopanel::updateTreeText {} {
  clearTreeText
  set txt .fEngine.text
  set base [sc_base current]
  if {![sc_base inUse $base] || [sc_base count total] == $base } {
    return
  }
  
  $txt insert [getTreeLoc] [::msgcat::mc "Move  Freq(games)  "] treeTitle
  $txt insert [getTreeLoc] [::msgcat::mc "Score " ] treeTitleScore
  $txt insert [getTreeLoc] [::msgcat::mc "AvElo Perf Draws\n"] treeTitle
  
  set tree [sc_tree search -hideMoves 0 -sort frequency -epd 0 -list 1 -base $base ]
  foreach l $tree {
    set lnum [lindex $l 0]
    set move [lindex $l 1]
    set mtot [lindex $l 3]
    set freq [lindex $l 4]
    set score [lindex $l 5]
    set averageElo [lindex $l 6]
    set perf [lindex $l 7]
    set year [lindex $l 8]
    set draws [lindex $l 9]
    if {$lnum != 0} {
      $txt insert [getTreeLoc] "$lnum:" tree
    }
    set tmp [padSpaces "$move" 3]
    $txt insert [getTreeLoc] "$tmp " tree
    set tmp [padSpaces "$freq%($mtot)" 12]
    $txt insert [getTreeLoc] "$tmp " tree
    set tmp [padSpaces "$score%" 5]
    $txt insert [getTreeLoc] "$tmp " treeScore
    set tmp [padSpaces "$averageElo" 4]
    $txt insert [getTreeLoc] "$tmp " tree
    set tmp [padSpaces "$perf" 4]
    $txt insert [getTreeLoc] "$tmp " tree
    set tmp [padSpaces "$draws" 2]
    $txt insert [getTreeLoc] "$tmp\n" tree
  }
}
################################################################################
proc ::infopanel::clearBookText {} {
  set txt .fEngine.text
  foreach tag {book} {
    while {1} {
      set del [$txt tag nextrange $tag 1.0]
      if {$del == ""} {break}
      catch {$txt delete [lindex $del 0] [lindex $del 1]}
    }
  }
}
################################################################################
# Book is the first info after (NAG,comment)
proc ::infopanel::updateBookText {} {
  global ::book::bookMoves
  clearBookText
  if { ! $::options(showBook) } {
    return
  }
  ::book::scBookOpen $::options(mainBook) $::book::bookSlot
  
  set txt .fEngine.text
  
  set bookMoves [sc_book moves $::book::bookSlot]
  set tmp ""
  
  for {set i 0} {$i<[llength $bookMoves]} {incr i 2} {
    set line [expr $i /2 +1]
    set m ""
    append m [lindex $bookMoves $i] " " [lindex $bookMoves [expr $i + 1] ] " "
    append tmp $m
  }
  append tmp "\n"
  
  $txt insert [getBookLoc] [::trans $tmp] book
  ::book::closeMainBook
}

################################################################################
#                         B O A R D
################################################################################
namespace eval board {
  set lightSquare "#f3f3f3"
  set darkSquare "#7389b6"
  set highlight "#f3f484"
  set fromSquare -1
  set pSize 0
  set pSize_lowres 20
  set pSize_hires 45
  set pSize_hires_fullsize 60
  set pSize_hires_setup 45
  set pSize_lowres_fullsize 30
  set pSize_lowres_setup 20
  set isFlipped 0
  set height -1
  set width -1
  array set previousBoard ""
  set lastMoveList {}
}
################################################################################
proc ::board::init {} {
  global ::board::height ::board::width ::board::pSize
  
  if {$::hires} {
    set pSize $::board::pSize_hires
    setPieceData Merida $::board::pSize_hires
    setPieceData Merida $::board::pSize_hires_fullsize
    setPieceData Merida $::board::pSize_lowres
  } else  {
    set pSize $::board::pSize_lowres
    setPieceData Merida $::board::pSize_lowres
    setPieceData Merida $::board::pSize_lowres_fullsize
  }
  
  # define screen resolution
  if {$::WindowsCE} {
    set height [lindex [wm maxsize . ] 1]
    set height [ expr $height - [wce captionheight] ]
    set width [lindex [wm maxsize . ] 0]
  } else  {
    if {$::hires} {
      set height 596
      set width 476
    } else  {
      set height 298
      set width 238
    }
  }
  
  ::ui::setFullSize . 0
  update idletasks
  wm title . "Scid"
  
  menuInit
  frame .fTop -borderwidth 0 -highlightthickness 0
  frame .fTop.fBoard -borderwidth 1 -highlightthickness 0 -relief raised
  frame .fTop.fr
  frame .fTop.fr.fCmd
  frame .fTop.fr.fclocks
  
  frame .fEngine
  text .fEngine.text -borderwidth 1 -relief sunken -font font_Tiny -setgrid 0 -yscrollcommand {.fEngine.sc set} -insertofftime 0
  ttk::scrollbar .fEngine.sc -orient vert -command {.fEngine.text yview}
  grid .fEngine.text -column 0 -row 0 -sticky nsew
  grid .fEngine.sc -column 1 -row 0  -sticky ns
  grid rowconfigure .fEngine 0 -weight 1
  grid columnconfigure .fEngine 0 -weight 1
  
  pack .fTop .fEngine -side top -fill x
  
  canvas .fTop.fBoard.bd -width [expr $pSize*8 ] -height [expr $pSize*8 ] -borderwidth 0 -highlightthickness 0 ; #-relief raised
  
  set bd .fTop.fBoard.bd
  
  grid $bd -row 1 -column 1 -rowspan 8 -columnspan 8
  
  # Create empty board:
  for {set i 0} {$i < 64} {incr i} {
    set xi [expr {$i % 8} ]
    set yi [expr { 7 - int($i/8)} ]
    set x1 [expr {$xi * $pSize +1 } ]
    set y1 [expr {$yi * $pSize +1 } ]
    set x2 [expr {$x1 + $pSize } ]
    set y2 [expr {$y1 + $pSize } ]
    $bd create rectangle $x1 $y1 $x2 $y2 -tag sq$i -width 0 -fill [defaultColor $i]
  }
  
  # Set up coordinate labels:
  for {set i 1} {$i <= 8} {incr i} {
    label .fTop.fBoard.lrank$i -text [expr {9 - $i}]
    grid .fTop.fBoard.lrank$i -row $i -column 0 -sticky e
  }
  
  foreach i {1 2 3 4 5 6 7 8} file {a b c d e f g h} {
    label .fTop.fBoard.bfile$file -text $file
    grid .fTop.fBoard.bfile$file -row 9 -column $i -sticky n
  }
  
  # bindings
  for {set i 0} {$i < 64} {incr i} {
    .fTop.fBoard.bd bind sq$i <ButtonPress-1> "::board::pressSquare $i"
    .fTop.fBoard.bd bind piece$i <ButtonPress-1> "::board::pressSquare $i"
  }
  bind . <Right> ".fTop.fr.fCmd.bNext invoke"
  bind . <Left> { ::board::Back }
  bind . <Up> ".fTop.fr.fCmd.bStart invoke"
  bind . <Down> ".fTop.fr.fCmd.bEnd invoke"
  if {$::WindowsCE} {
    bind . <F23> { ::board::setBoardSize 1 }
  }
  # buttons
  if {$::hires} {
    set pad 2
  } else {
    set pad 0
  }
  
  ttk::button .fTop.fr.fCmd.bPrev -image tb_prev -command {::board::Back}
  grid .fTop.fr.fCmd.bPrev -row 1 -column 0 -padx $pad -pady $pad
  ttk::button .fTop.fr.fCmd.bNext -image tb_next -command {::board::Forward}
  grid .fTop.fr.fCmd.bNext -row 1 -column 1 -padx $pad -pady $pad
  ttk::button .fTop.fr.fCmd.bStart -image tb_start -command {::board::Back 10}
  grid .fTop.fr.fCmd.bStart -row 2 -column 0 -padx $pad -pady $pad
  ttk::button .fTop.fr.fCmd.bEnd -image tb_end -command {::board::Forward 10}
  grid .fTop.fr.fCmd.bEnd -row 2 -column 1 -padx $pad -pady $pad
  ttk::button .fTop.fr.fCmd.bGprev -image tb_gprev -command {::game::gamePrev}
  grid .fTop.fr.fCmd.bGprev -row 3 -column 0 -padx $pad -pady $pad
  ttk::button .fTop.fr.fCmd.bGnext -image tb_gnext -command {::game::gameNext}
  grid .fTop.fr.fCmd.bGnext -row 3 -column 1 -padx $pad -pady $pad
  ttk::button .fTop.fr.fCmd.bFlip -image tb_flip -command {::board::toggleFlip}
  grid .fTop.fr.fCmd.bFlip -row 6 -column 1 -padx $pad -pady $pad
  ttk::button .fTop.fr.fCmd.bPgn -image tb_pgn -command {::board::showPgn}
  grid .fTop.fr.fCmd.bPgn -row 6 -column 0 -padx $pad -pady $pad
  
  ttk::button .fTop.fr.fCmd.bAnalyze -image engine_off -command ::board::toggleAnalyze
  grid .fTop.fr.fCmd.bAnalyze -row 7 -column 1 -padx $pad -pady $pad
  # side to move
  canvas .fTop.fr.fCmd.bSide -background white -relief groove -border 1 -width 24 -height 24
  grid .fTop.fr.fCmd.bSide -row 7 -column 0 -padx $pad -pady $pad
  
  pack .fTop.fBoard -side left -anchor s
  pack .fTop.fr -side left -expand 1 -fill both
  
  # display the material balance and last move
  frame .fTop.fr.f2
  label .fTop.fr.f2.lMaterial -relief flat -fg DarkSeaGreen -textvariable ::game::materialBalance
  label .fTop.fr.f2.lLastMove -relief flat -fg Black -textvariable ::game::lastMove -font font_Tiny
  pack .fTop.fr.f2.lMaterial .fTop.fr.f2.lLastMove -side top
  
  pack .fTop.fr.f2 .fTop.fr.fclocks -side top
  pack .fTop.fr.fCmd -side bottom
  
  set ::board::previousBoard(.fTop.fBoard.bd) ""
  setBoard .fTop.fBoard.bd [ sc_pos board ] $::board::pSize
  
  update
}
################################################################################
proc ::board::setBoardSize { {toggle 0} } {
  global ::board::pSize ::board::isFlipped
  
  if {$toggle} {
    if { $::options(fullBoard) } {
      set ::options(fullBoard) 0
    } else {
      set ::options(fullBoard) 1
    }
  }
  
  if { $::options(fullBoard) } {
    if {$::hires} {
      set pSize $::board::pSize_hires_fullsize
    } else {
      set pSize $::board::pSize_lowres_fullsize
    }
    set border 0
    set border_fBoard 0
  } else {
    set border 1
    set border_fBoard 1
    if {$::hires} {
      set pSize $::board::pSize_hires
    } else {
      set pSize $::board::pSize_lowres
    }
  }
  
  set bd .fTop.fBoard.bd
  
  # to force the redraw of pieces
  set ::board::previousBoard($bd) ""
  
  $bd configure -width [expr $pSize*8] -height [expr $pSize*8] -border $border -relief raised
  .fTop.fBoard configure -borderwidth $border_fBoard -relief sunken
  
  for {set i 0} {$i < 64} {incr i} {
    $bd delete sq$i
  }
  
  # Create empty board:
  for {set i 0} {$i < 64} {incr i} {
    set xi [expr {$i % 8} ]
    set yi [expr { 7 - int($i/8)} ]
    set x1 [expr {$xi * $pSize +1} ]
    set y1 [expr {$yi * $pSize +1} ]
    set x2 [expr {$x1 + $pSize } ]
    set y2 [expr {$y1 + $pSize } ]
    $bd create rectangle $x1 $y1 $x2 $y2 -tag sq$i -width 0 -fill [::board::defaultColor $i]
  }
  
  if { ! $::options(fullBoard) } {
    # Set up coordinate labels:
    for {set i 1} {$i <= 8} {incr i} {
      label .fTop.fBoard.lrank$i -text [expr {9 - $i}]
      grid .fTop.fBoard.lrank$i -row $i -column 0 -sticky e
    }
    
    foreach i {1 2 3 4 5 6 7 8} file {a b c d e f g h} {
      label .fTop.fBoard.bfile$file -text $file
      grid .fTop.fBoard.bfile$file -row 9 -column $i -sticky n
    }
    updateCoordinates
    # remove clocks in infopanel
    set w .fEngine.text
    foreach n {1 2} {
      set del [$w tag nextrange clock$n 1.0]
      catch {$w delete [lindex $del 0] [lindex $del 1]}
    }
  } else {
    for {set i 1} {$i <= 8} {incr i} { destroy .fTop.fBoard.lrank$i }
    foreach file {a b c d e f g h} { destroy .fTop.fBoard.bfile$file }
  }
  
  ::board::updateBoard -nolastmove
}
################################################################################
proc ::board::menuInit {} {
  option add *Menu*TearOff 0
  menu .menu
  
  . configure -menu .menu
  foreach menuname { base game switch search options multipv selectBook copy} {
    menu .menu.$menuname
  }
  .menu add cascade -label [::msgcat::mc "Base"] -menu .menu.base
  .menu.base add command -label [::msgcat::mc "Open"] -command ::base::baseOpen
  menu .menu.base.recent
  .menu.base add cascade -label [::msgcat::mc "Recent"] -menu .menu.base.recent
  .menu.base add command -label [::msgcat::mc "New"] -command ::base::baseNew
  .menu.base add command -label [::msgcat::mc "Import"] -command ::base::importPgnFile
  .menu.base add command -label [::msgcat::mc "Export"] -command ::base::exportPgnFile
  
  .menu.base add cascade -label [::msgcat::mc "Switch"] -menu .menu.switch
  for {set i 1} {$i < [sc_base count total]} {incr i} {
    .menu.switch add command -label $i.\[[::msgcat::mc "empty"]\] -command "::base::switch $i"
  }
  .menu.switch add command -label [::msgcat::mc "clipbase"] -command "::base::switch [sc_base count total]"
  
  .menu.base add command -label [::msgcat::mc "Close"] -command ::base::baseClose
  .menu.base add command -label [::msgcat::mc "Compact"] -command ::base::baseCompact
  .menu.base add command -label [::msgcat::mc "Quit"] -command ::appQuit
  .menu add cascade -label [::msgcat::mc "Game"] -menu .menu.game
  .menu.game add command -label [::msgcat::mc "New"] -command ::game::new
  .menu.game add command -label [::msgcat::mc "Save"] -command ::game::save
  .menu.game add command -label [::msgcat::mc "Delete"] -command ::game::delete
  
  menu .menu.game.goto
  .menu.game add cascade -label [::msgcat::mc "Goto"] -menu .menu.game.goto
  .menu.game.goto add command -label [::msgcat::mc "Next"] -command ::game::gameNext
  .menu.game.goto add command -label [::msgcat::mc "Previous"] -command ::game::gamePrev
  .menu.game.goto add command -label [::msgcat::mc "First"] -command { ::game::gameLoad 1 }
  .menu.game.goto add command -label [::msgcat::mc "Last"] -command { ::game::gameLoad [sc_base numGames]}
  .menu.game.goto add command -label [::msgcat::mc "Number"] -command ::game::LoadNumber
  .menu.game.goto add command -label [::msgcat::mc "Random"] -command ::game::random
  
  .menu.game add command -label [::msgcat::mc "Info"] -command ::game::info
  .menu.game add command -label [::msgcat::mc "List"] -command ::game::GameList
  .menu.game add command -label [::msgcat::mc "Comment"] -command ::game::MoveComment
  .menu.game add command -label [::msgcat::mc "Board setup"] -command ::game::BoardSetup
  .menu.game add checkbutton -label [::msgcat::mc "Annotate"] -variable ::analyzeMode -command ::game::Annotate
  .menu.game add checkbutton -label [::msgcat::mc "Play"] -variable ::playMode -command ::game::Play
  
  # ------- tactics --------
  menu .menu.game.tactics
  .menu.game add cascade -label [::msgcat::mc "Tactics"] -menu .menu.game.tactics
  .menu.game.tactics add checkbutton -label [::msgcat::mc "Training"] -variable ::tactics::running -command ::tactics::start
  .menu.game.tactics add command -label [::msgcat::mc "Reset base"] -command ::tactics::resetScores
  .menu.game.tactics add command -label [::msgcat::mc "Show solution"] -command ::tactics::showSolution
  
  menu .menu.game.tactics.thinktime
  .menu.game.tactics add cascade -label [::msgcat::mc "Analysis time"] -menu .menu.game.tactics.thinktime
  foreach i { 3 5 10 15 30 60 } {
    .menu.game.tactics.thinktime add radiobutton -label "$i" -value $i -variable ::tactics::analysisTime
  }
  
  # ------- fics --------
  menu .menu.game.fics
  .menu.game add cascade -label [::msgcat::mc "FICS"] -menu .menu.game.fics
  .menu.game.fics add checkbutton -label [::msgcat::mc "Connect"] -variable ::fics::connected -command {
    if {$::fics::connected} { ::fics::config } else { ::fics::close }
  }
  .menu.game.fics add command -label [::msgcat::mc "Find opponent"] -command ::fics::findOpponent
  .menu.game.fics add command -label [::msgcat::mc "Show offers"] -command { ::fics::showOffers }
  
  .menu.game.fics add command -label [::msgcat::mc "Games"] -command { ::fics::writechan "games /bs" ; ::fics::showConsole }
  .menu.game.fics add command -label [::msgcat::mc "Draw"] -command { ::fics::writechan "draw"}
  .menu.game.fics add command -label [::msgcat::mc "Resign"] -command { ::fics::writechan "resign"}
  .menu.game.fics add command -label [::msgcat::mc "Takeback"] -command { ::fics::writechan "takeback"}
  .menu.game.fics add command -label [::msgcat::mc "Takeback 2"] -command { ::fics::writechan "takeback 2"}
  .menu.game.fics add command -label [::msgcat::mc "Console"] -command { ::fics::showConsole }
  .menu.game.fics add command -label [::msgcat::mc "Formula"] -command { ::fics::setFormula }
  menu .menu.game.fics.wifi
  .menu.game.fics add cascade -label [::msgcat::mc "Wifi"] -menu .menu.game.fics.wifi
  .menu.game.fics.wifi add command -label [::msgcat::mc "Start"] -command { wce wifi 1 }
  .menu.game.fics.wifi add command -label [::msgcat::mc "Stop"] -command { wce wifi 0 }
  
  # ------- search --------
  .menu add cascade -label [::msgcat::mc "Search"] -menu .menu.search
  .menu.search add command -label [::msgcat::mc "Current board"] -command ::ui::CurrentBoard
  .menu.search add command -label [::msgcat::mc "Header"] -command ::ui::Header
  .menu.search add command -label [::msgcat::mc "Material/Pattern"] -command ::ui::MaterialPattern
  .menu.search add command -label [::msgcat::mc "Reset filter"] -command ::ui::ResetFilter
  .menu.search add command -label [::msgcat::mc "Negate filter"] -command ::ui::NegateFilter
  
  .menu.search add cascade -label [::msgcat::mc "Copy filter to"] -menu .menu.copy
  for {set i 1} {$i < [sc_base count total]} {incr i} {
    .menu.copy add command -label $i.[::msgcat::mc "empty"] -command "::ui::CopyFilter $i"
  }
  .menu.copy add command -label [::msgcat::mc "clipbase"] -command "::ui::CopyFilter [sc_base count total]"
  
  .menu.search add command -label [::msgcat::mc "Filter info"] -command ::ui::FilterInfo
  
  # ------------- Options menu -------------------------
  .menu add cascade -label [::msgcat::mc "Options"] -menu .menu.options
  .menu.options add cascade -label [::msgcat::mc "Best lines"] -menu .menu.multipv
  for {set i 1} {$i <= $::options(multipvmax) } {incr i} {
    .menu.multipv add radiobutton -label "$i" -value $i -variable ::options(multipv) -command "::engine::setMultiPv 1"
  }
  .menu.multipv add checkbutton -label [::msgcat::mc "Word wrap"] -variable ::options(wrap) -onvalue "word" -offvalue "none" \
      -command { .fEngine.text tag configure enginemultipv -wrap $::options(wrap) }
  
  # -- Books
  .menu.options add cascade -label [::msgcat::mc "Book"] -menu .menu.selectBook
  .menu.selectBook add checkbutton -label [::msgcat::mc "Show book"] -variable ::options(showBook) -command ::ui::showBook
  set bookPath [file join $::instalDir "books" ]
  set bookList [  lsort -dictionary [ glob -nocomplain -directory $bookPath *.bin ] ]
  foreach file $bookList {
    set f [ file tail $file ]
    .menu.selectBook add radiobutton -variable ::options(mainBook) -value $f -label $f -command {
      ::book::bookSelect
      ::infopanel::updateBookText
    }
  }
  if {$::options(mainBook) == ""} {
    set ::options(mainBook) [ file tail [lindex $bookList 0] ]
  }
  
  .menu.options add checkbutton -label [::msgcat::mc "Base stats"] -variable ::options(showTree) -command ::ui::showTree
  
  .menu.options add checkbutton -label [::msgcat::mc "Show analysis"] -variable ::options(showAnalysis) -command ::ui::showAnalysis
  .menu.options add checkbutton -label [::msgcat::mc "Show comments"] -variable ::options(showComments) -command ::ui::showComments
  .menu.options add checkbutton -label [::msgcat::mc "Show material"] -variable ::options(showMaterial) -command ::board::updateMaterialBalance
  .menu.options add checkbutton -label [::msgcat::mc "Score only"] -variable ::options(scoreOnly) -command ::infopanel::updateAnalysis
  .menu.options add checkbutton -label [::msgcat::mc "Show last move"] -variable ::options(showLastMove) -command ::board::showLastMove
  .menu.options add checkbutton -label [::msgcat::mc "Full board"] -variable ::options(fullBoard) -command ::board::setBoardSize
  
  # -- UI settings
  menu .menu.options.looknfeel
  .menu.options add cascade -label [::msgcat::mc "Look'n feel"] -menu .menu.options.looknfeel
  # Font size
  menu .menu.options.looknfeel.fontsize
  .menu.options.looknfeel add cascade -label [::msgcat::mc "Font size"] -menu .menu.options.looknfeel.fontsize
  foreach i { 6 7 8 9 10 11 12 } {
    .menu.options.looknfeel.fontsize add radiobutton -label "$i" -value $i -variable ::options(fontAnalysisSize) -command "::infopanel::setFontSize"
  }
  # Themes
  menu .menu.options.looknfeel.themes
  .menu.options.looknfeel add cascade -label [::msgcat::mc "Themes"] -menu .menu.options.looknfeel.themes
  foreach i [ttk::style theme names] {
    .menu.options.looknfeel.themes add radiobutton -label "$i" -value $i -variable ::options(theme) -command "::ui::setTheme"
  }
  
  # -- engines
  menu .menu.options.engine
  .menu.options add cascade -label [::msgcat::mc "Engines"] -menu .menu.options.engine
  menu .menu.options.engine.hash
  .menu.options.engine add cascade -label [::msgcat::mc "Hash memory"] -menu .menu.options.engine.hash
  set k [::msgcat::mc "kB"]
  foreach i { 64 128 256 512 1024 2048 } {
    .menu.options.engine.hash add radiobutton -label "$i $k" -value $i -variable ::options(enginehash) \
        -command "::engine::setHash"
  }
  .menu.options.engine add command -label [::msgcat::mc "Select"] -command ::engine::associate
  .menu.options.engine add checkbutton -label [::msgcat::mc "Extended info"] -variable ::options(engineExtendedInfo)
  .menu.options.engine add checkbutton -label [::msgcat::mc "Optimize speed"] -variable ::options(engineOptimizeSpeed) -command ::engine::OptimizeSpeed
  .menu.options.engine add checkbutton -label [::msgcat::mc "Tournament"] -variable ::tournamentMode -command ::engine::tournament
  menu .menu.options.engine.setresult
  .menu.options.engine.setresult add command -label [::msgcat::mc "White wins"] -command {::engine::setGameResult "White wins"}
  .menu.options.engine.setresult add command -label [::msgcat::mc "Black wins"] -command {::engine::setGameResult "Black wins"}
  .menu.options.engine.setresult add command -label [::msgcat::mc "Draw"] -command {::engine::setGameResult "Draw"}
  
  .menu.options.engine add cascade -label [::msgcat::mc "Set result"] -menu .menu.options.engine.setresult
  .menu.options add checkbutton -label [::msgcat::mc "Sound"] -variable ::options(sound)
  menu .menu.options.lang
  foreach i { english french spanish } {
    .menu.options.lang add radiobutton -label [::msgcat::mc $i] -value $i -variable ::options(language) -command ::board::setLang
  }
  .menu.options add cascade -label [::msgcat::mc "Language"] -menu .menu.options.lang
  
  # ------- novag --------
  menu .menu.options.novag
  .menu.options.novag add command -label [::msgcat::mc "Configure"] -command ::novag::configure
  .menu.options.novag add checkbutton -label [::msgcat::mc "Connect"] -variable ::novag::connected -command ::novag::connect
  .menu.options.novag add command -label [::msgcat::mc "Console"] -command ::novag::showConsole
  .menu.options.novag add command -label [::msgcat::mc "Pos.->Citrine"] -command ::novag::setup
  .menu.options.novag add command -label [::msgcat::mc "Hard Synch."] -command ::novag::synchro
  .menu.options.novag add command -label [::msgcat::mc "Check sync"] -command ::novag::menuCheckBoardSync
  
  menu .menu.options.novag.bluetooth
  .menu.options.novag add cascade -label [::msgcat::mc "Bluetooth"] -menu .menu.options.novag.bluetooth
  .menu.options.novag.bluetooth add command -label [::msgcat::mc "Start"] -command { wce bluetooth 1 }
  .menu.options.novag.bluetooth add command -label [::msgcat::mc "Stop"] -command { wce bluetooth 0 }
  
  .menu.options.novag add checkbutton -label [::msgcat::mc "Referee mode"] -variable ::options(novag_refereeMode) \
      -command { catch ::novag::referee }
  .menu.options.novag add checkbutton -label [::msgcat::mc "Flipped board"] -variable ::novag::flippedBoard
  .menu.options.novag add checkbutton -label [::msgcat::mc "Send move twice"] -variable ::options(novag_sendmovetwice)
  .menu.options add cascade -label [::msgcat::mc "Novag Citrine"] -menu .menu.options.novag
  
  .menu.options add command -label [::msgcat::mc "About"] -command ::ui::About
}

################################################################################
proc ::board::setLang {} {
  switch $::options(language) {
    french  {sc_info language fr}
    spanish {sc_info language es}
    default {sc_info language en}
  }
}
################################################################################
proc ::board::toggleFlip {} {
  global ::board::isFlipped
  
  resetShowLastMove
  
  # to force the redraw of pieces
  set ::board::previousBoard(.fTop.fBoard.bd) ""
  
  set isFlipped [expr 1 - $isFlipped]
  updateCoordinates
  updateBoard -noanalyze -nolastmove
  
  # if a game is in progress, update status
  if {$::playMode} {
    ::game::setPlayHeaders
  }
  
}
################################################################################
proc ::board::updateCoordinates {} {
  global ::board::isFlipped
  set w .fTop.fBoard
  for {set i 1} {$i <= 8} {incr i} {
    if {!$isFlipped} {
      $w.lrank$i configure -text [expr {9 - $i}]
    } else  {
      $w.lrank$i configure -text $i
    }
  }
  
  if {!$isFlipped} {
    foreach file {a b c d e f g h} {
      $w.bfile$file configure -text $file
    }
  } else  {
    foreach file {a b c d e f g h} newfile {h g f e d c b a} {
      $w.bfile$file configure -text $newfile
    }
  }
}

################################################################################
proc ::board::Start {} {
  sc_move start
  updateBoard -nolastmove
}
################################################################################
proc ::board::End {} {
  sc_move end
  updateBoard -nolastmove
}
################################################################################
proc ::board::Back {{count 1}} {
  if {[sc_pos isAt start]} { return }
  if {[sc_pos isAt vstart]} {
    sc_var exit
    return
  }
  
  # if in a variation, exit it
  if {[sc_var level] != 0 && $count != 1} {
    sc_var exit
  } else {
    sc_move back $count
  }
  updateBoard -nolastmove
}

################################################################################
proc ::board::Forward {{count 1}} {
  if {[sc_pos isAt end]  ||  [sc_pos isAt vend]} { return }
  if {$count == 1} {
    if {[sc_var count] != 0 && $::options(showVarPopup)} {
      showVars
    } else  {
      sc_move forward
      updateBoard
    }
  } else {
    sc_move forward $count
    updateBoard -nolastmove
  }
}
################################################################################
proc ::board::showVars {} {
  
  # No need to display an empty menu
  if {[sc_var count] == 0} {
    return
  }
  
  if {[sc_var count] == 1 &&  [sc_game info nextMove] == ""} {
    # There is only one variation and no main line, so enter it
    sc_var moveInto 0
    updateBoard
    return
  }
  
  sc_info preMoveCmd {}
  
  set w .variations
  if {[winfo exists $w]} { return }
  
  set varList [sc_var list]
  set numVars [sc_var count]
  
  # Present a menu of the possible variations
  toplevel $w
  wm title $w [::msgcat::mc "Variations" ]
  ::ui::setTopmost $w
  
  set h [expr $numVars + 1]
  if { $h> 10} { set h 10 }
  listbox $w.lbVar -selectmode browse -height $h -width 20
  pack $w.lbVar -expand yes -fill both -side top
  
  #insert main line
  set move [sc_game info nextMove]
  if {$move == ""} {
    set move "empty"
  } else  {
    $w.lbVar insert end "0: [getNextMoves 5]"
  }
  
  # insert variations
  for {set i 0} {$i < $numVars} {incr i} {
    set move [::trans [lindex $varList $i]]
    if {$move == ""} {
      set move "empty"
    } else  {
      sc_var moveInto $i
      append move [getNextMoves 5]
      sc_var exit
    }
    set str "[expr {$i + 1}]: $move"
    $w.lbVar insert end $str
  }
  $w.lbVar selection set 0
  
  bind .variations <Button-1> {catch { event generate .variations <Right> } }
  bind .variations <Right> {
    set cur [.variations.lbVar curselection]
    destroy .variations
    sc_info preMoveCmd preMoveCommand
    if {$cur == 0} {
      catch { sc_move forward }
    } else  {
      catch { sc_var moveInto [expr $cur - 1] }
    }
    ::board::updateBoard
  }
  bind .variations <Up> { set cur [.variations.lbVar curselection] ; .variations.lbVar selection clear $cur
    set sel [expr $cur - 1]
    if {$sel < 0} { set sel 0 }
    .variations.lbVar selection set $sel ; .variations.lbVar see $sel}
  bind .variations <Down> { set cur [.variations.lbVar curselection] ; .variations.lbVar selection clear $cur
    set sel [expr $cur + 1]
    if {$sel >= [.variations.lbVar index end]} { set sel end }
    .variations.lbVar selection set $sel ; .variations.lbVar see $sel}
  bind .variations <Left> { catch { event generate .variations <Destroy> } }
  #in order to have the window always on top : this does not really work ...
  bind .variations <Visibility> {
    if { "%s" != "VisibilityUnobscured" } {
      focus .variations
      raise .variations
    }
  }
  bind .variations <FocusOut> {
    focus .variations
    raise .variations
  }
  sc_info preMoveCmd preMoveCommand
  update
  focus .variations
  grab set $w
}
################################################################################
# returns the next moves, translated
proc ::board::getNextMoves { {num 4} } {
  set tmp ""
  set count 0
  while { [sc_game info nextMove] != "" && $count < $num} {
    append tmp " [sc_game info nextMove]"
    sc_move forward
    incr count
  }
  sc_move back $count
  return $tmp
}
################################################################################
proc ::board::showPgn {} {
  ::pgn::OpenClose
}

################################################################################
proc ::board::updateEngine {{n 1 }} {
  if {$::engine::data(running$n)} {
    ::engine::stopAnalysis $n
    ::engine::startAnalysis $n
  }
}
################################################################################
proc ::board::toggleAnalyze {{n 1 }} {
  global ::engine::data
  set b .fTop.fr.fCmd.bAnalyze
  if {$data(running$n)} {
    $b configure -image engine_off -state disabled
    ::engine::stopAnalysis $n
    $b configure -state normal
  } else  {
    $b configure -image engine_on -state disabled
    ::engine::startAnalysis $n
    $b configure -state normal
  }
}
################################################################################
proc ::board::pressSquare { square } {
  if { $::fics::playing == -1} { return } ;# not player's turn
  if { $::tactics::isThinking } { return } ;# to prevent engine update
  
  global ::board::fromSquare
  set bd .fTop.fBoard.bd
  
  resetShowLastMove
  
  if {$fromSquare == -1} {
    set fromSquare $square
    if {$::board::isFlipped} { set fromSquare [expr 63-$fromSquare] }
    $bd itemconfigure sq$square -outline $::board::highlight -fill $::board::highlight
  } else {
    set toSquare $square
    if {$::board::isFlipped} { set toSquare [expr 63-$toSquare] }
    if {$fromSquare == $toSquare} {
      set color [defaultColor $square]
      $bd itemconfigure sq$square -outline $color -fill $color
      set fromSquare -1
      return
    } else  {
      makeMove $fromSquare $toSquare
      set color [defaultColor $fromSquare]
      if {$::board::isFlipped} { set fromSquare [expr 63-$fromSquare] }
      $bd itemconfigure sq$fromSquare -outline $color -fill $color
      set fromSquare -1
    }
  }
}
################################################################################
proc ::board::resetShowLastMove {} {
  set bd .fTop.fBoard.bd
  foreach sq $::board::lastMoveList {
    set color [defaultColor $sq]
    # if {$::board::isFlipped} { set sq [expr 63-$sq] }
    $bd itemconfigure sq$sq -outline $color -fill $color
  }
  set ::board::lastMoveList {}
}
################################################################################
proc ::board::resetSquaresColor {} {
  set bd .fTop.fBoard.bd
  for {set i 0} {$i < 64} {incr i} {
    $bd itemconfigure sq$i -fill [defaultColor $i]
  }
}
################################################################################
proc ::board::showLastMove {} {
  set bd .fTop.fBoard.bd
  if { $::options(showLastMove) } {
    foreach sq $::board::lastMoveList {
      # if {$::board::isFlipped} { set sq [expr 63-$sq] }
      $bd itemconfigure sq$sq -outline $::board::highlight -fill $::board::highlight
    }
  } else {
    resetShowLastMove
  }
}
################################################################################
proc ::board::setBoard {bd board size} {
  
  set ::board::lastMoveList {}
  
  for {set sq 0} {$sq<64} {incr sq} {
    if {$::board::isFlipped} {
      set fsq [expr 63-$sq]
    } else {
      set fsq $sq
    }
    if { [ string index $board $fsq ] == [ string index $::board::previousBoard($bd) $fsq ] } { continue }
    
    lappend ::board::lastMoveList $sq
    
    set img [getImg $fsq $size $board]
    $bd delete piece$sq
    if {$img == ""} { continue }
    $bd create image [getMidSq $bd $sq] -image $img -tag piece$sq
  }
  set ::board::previousBoard($bd) $board
}

################################################################################
proc ::board::getMidSq {w sq} {
  set c [$w coords sq$sq]
  set x [expr {([lindex $c 0] + [lindex $c 2]) / 2 } ]
  set y [expr {([lindex $c 1] + [lindex $c 3]) / 2 } ]
  return [list $x $y]
}
################################################################################
proc ::board::getImg {sq size board} {
  set p [string index $board $sq]
  if {$p == "."} { return "" }
  if { [string is lower $p] } {
    set color "b"
  } else  {
    set color "w"
  }
  set ret "$color[string tolower $p]$size"
  return $ret
}
################################################################################
proc ::board::makeMove {from to} {
  set EMPTY 0 ;    set KING 1 ;    set QUEEN 2 ;    set ROOK 3 ;    set BISHOP 4 ;    set KNIGHT 5 ;    set PAWN 6
  
  set promo $EMPTY
  if {[sc_pos isPromotion $from $to] == 1} {
    # sometimes, addMove is triggered twice
    if { [winfo exists .promoWin] } { return }
    set promo [getPromoPiece]
  }
  
  set action "replace"
  if {![sc_pos isAt vend]} {
    set action [confirmReplaceMove]
  }
  if {$action == "replace"} {
    # nothing
  } elseif {$action == "mainline" || $action == "var"} {
    sc_var create
  } else {
    # Do not add the move at all:
    return
  }
  
  if {[sc_pos isLegal $from $to] == 0} { return }
  
  if { [catch { ::game::moveAdd [list $from $to $promo] } err ] } {
    tk_messageBox -type ok -icon error -parent . -title "Error" -message "catch ::game::moveAdd ( $from $to $promo ) $err"
    return
  }
  
  # check if the engine pondered on the right move
  if {$::playMode} {
    switch -- $promo {
      2 { set p "q"}
      3 { set p "r"}
      4 { set p "b"}
      5 { set p "n"}
      default {set p ""}
    }
    set ::game::lastPlayerMoveUci "[::board::san $from][::board::san $to]$p"
  }
  
  if {$action == "mainline"} {
    sc_var exit
    sc_var promote [expr {[sc_var count] - 1}]
    sc_move forward 1
  }
  if { $::fics::playing == 1} {
    if { $promo != $EMPTY } {
      switch $promo {
        2 {set p "q"}
        3 {set p "r"}
        4 {set p "b"}
        5 {set p "n"}
        default {set p "q"}
      }
      ::fics::writechan "promote $p"
    }
    ::fics::writechan [ string range [sc_game info previousMoveUCI] 0 3 ]
    sc_move back
    sc_game truncatefree
    ::sound::play alert
  } else {
    updateBoard
  }
  
}
################################################################################
#
################################################################################
proc ::board::getPromoPiece {} {
  set w .promoWin
  set ::result 2
  toplevel $w
  wm title $w [::msgcat::mc "Promotion"]
  ::ui::setTopmost $w
  
  # wm resizable $w 0 0
  set col "w"
  if { [sc_pos side] == "black" } { set col "b" }
  ttk::button $w.bq -image ${col}q$::board::pSize -command "set ::result 2 ; destroy $w"
  ttk::button $w.br -image ${col}r$::board::pSize -command "set ::result 3 ; destroy $w"
  ttk::button $w.bb -image ${col}b$::board::pSize -command "set ::result 4 ; destroy $w"
  ttk::button $w.bn -image ${col}n$::board::pSize -command "set ::result 5 ; destroy $w"
  pack $w.bq $w.br $w.bb $w.bn -side left
  update
  grab $w
  tkwait window $w
  return $::result
}
################################################################################
proc ::board::confirmReplaceMove {} {
  set ::board::answer "cancel"
  if {$::options(addVariationWithoutAsking)} { return "var" }
  
  if {! $::options(askToReplaceMoves)} { return "replace" }
  set w .confirmRepMove
  toplevel $w
  wm title $w [::msgcat::mc "Replace move" ]
  ::ui::setTopmost $w
  
  label $w.l -text [::msgcat::mc "Scid: Replace Move ?"] -anchor w
  pack $w.l
  ttk::button $w.b1 -text [::msgcat::mc "Replace move"] -command "set ::board::answer replace "
  ttk::button $w.b2 -text [::msgcat::mc "New main line"] -command "set ::board::answer mainline "
  ttk::button $w.b3 -text [::msgcat::mc "Add variation"] -command "set ::board::answer var "
  ttk::button $w.b4 -text [::msgcat::mc "Cancel"] -command "set ::board::answer cancel "
  
  pack $w.b1 $w.b2 $w.b3 $w.b4 -fill x
  bind $w <Destroy> ""
  update
  grab $w
  vwait ::board::answer
  destroy $w
  return $::board::answer
}
################################################################################
proc ::board::defaultColor {sq} {
  return [expr {($sq + ($sq / 8)) % 2 ? "$::board::lightSquare" : "$::board::darkSquare"}]
}
################################################################################
proc ::board::updateMenuStates {} {
  # Load first/last/random buttons:
  set filtercount [sc_filter count]
  if {$filtercount == 0} {set state disabled} else {set state normal}
  .menu.game.goto entryconfig [::msgcat::mc "Random"] -state $state
  
  # Load previous button:
  if {[sc_filter previous]} {set state normal} else {set state disabled}
  .fTop.fr.fCmd.bGprev configure -state $state
  .menu.game.goto entryconfig [::msgcat::mc "Previous"] -state $state
  
  # Load next button:
  if {[sc_filter next]} {set state normal} else {set state disabled}
  .fTop.fr.fCmd.bGnext configure -state $state
  .menu.game.goto entryconfig [::msgcat::mc "Next"] -state $state
}
################################################################################
proc ::board::updateBoard {args} {
  set updateAnalyze 1
  set updatePgn 0
  set nolastmove 0
  set nobook 0
  foreach arg $args {
    if {! [string compare $arg "-noanalyze"]} { set updateAnalyze 0 }
    if {! [string compare $arg "-pgn"]} { set updatePgn 1 }
    if {! [string compare $arg "-nolastmove"]} { set nolastmove 1 }
    if {! [string compare $arg "-nobook"]} { set nobook 1 }
  }
  set board [sc_pos board]
  resetShowLastMove
  setBoard .fTop.fBoard.bd $board $::board::pSize
  if {$nolastmove} {
    set ::board::lastMoveList {}
    ::board::resetShowLastMove
  } else {
    showLastMove
  }
  
  .fTop.fr.fCmd.bSide configure -background [sc_pos side]
  if {$updateAnalyze} {
    updateEngine 1
  }
  if {$updatePgn} {
    ::pgn::Refresh 1
  }
  if {$::options(showComments)} {
    ::infopanel::updateComments
  }
  if {$::options(showBook) && ! $nobook} {
    ::infopanel::updateBookText
  }
  if {$::options(showTree)} {
    ::infopanel::updateTreeText
  }
  
  set nag [sc_pos getNags]
  if {$nag == "0"} {set nag ""}
  set num [sc_pos moveNumber]
  if {[sc_pos side] == "white"} { incr num -1 }
  set ::game::lastMove "$num.[sc_game info previousMove]$nag"
  updateMaterialBalance
  updateMenuStates
  
}
################################################################################
proc ::board::updateMaterialBalance {} {
  if {$::options(showMaterial)} {
    set fen [lindex [sc_pos fen] 0]
    set p 0
    set n 0
    set b 0
    set r 0
    set q 0
    for {set i 0} {$i < [string length $fen]} {incr i} {
      set ch [string index $fen $i]
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
    set ::game::materialBalance [expr $p + $n * 3 + $b * 3 + $r * 5 + $q * 9 ]
  } else {
    set ::game::materialBalance ""
  }
}
################################################################################
proc ::board::updateTitle {} {
  set delete ""
  if { [sc_game flag delete [sc_game number] ] == 1 } {set delete " D"}
  if {[sc_base current] == [sc_base count total]} {
    wm title . "clipbase:[sc_game number]/[sc_base numGames]$delete"
  } else  {
    wm title . "[sc_base current]:[sc_game number]/[sc_base numGames]$delete"
  }
}
################################################################################
proc ::board::san {sqno} {
  if {($sqno < 0) || ($sqno > 63)} { return }
  return [format %c%c \
      [expr {($sqno % 8) + [scan a %c]}] \
      [expr {($sqno / 8) + [scan 1 %c]}]]
}
################################################################################
proc ::board::sq {sqname} {
  set squareIndex [list a1 b1 c1 d1 e1 f1 g1 h1 a2 b2 c2 d2 e2 f2 g2 h2 \
      a3 b3 c3 d3 e3 f3 g3 h3 a4 b4 c4 d4 e4 f4 g4 h4 \
      a5 b5 c5 d5 e5 f5 g5 h5 a6 b6 c6 d6 e6 f6 g6 h6 \
      a7 b7 c7 d7 e7 f7 g7 h7 a8 b8 c8 d8 e8 f8 g8 h8]
  return [lsearch -exact $squareIndex $sqname]
}
################################################################################
proc ::board::setPieceData {font size} {
  image create photo e$size -height $size -width $size
  image create photo tempPieces$font$size -data $::pieceImageData($font,$size)
  set x 0
  foreach p {wp wn wb wr wq wk bp bn bb br bq bk} {
    image create photo $p$size -width $size -height $size
    $p$size copy tempPieces$font$size -from $x 0 [expr $x + $size - 1] [expr $size - 1]
    incr x $size
  }
  image delete tempPieces$font$size
}
