
############################################################
### TREE window
### (C) 2007 Pascal Georges : multiple Tree windows support

namespace eval ::tree {
  set trainingBase 0
  array set cachesize {}
}
# ################################################################################
proc ::tree::doConfigMenus { baseNumber  { lang "" } } {
  if {! [winfo exists .treeWin$baseNumber]} { return }
  if {$lang == ""} { set lang $::language }
  set m .treeWin$baseNumber.menu
  foreach idx {0 1 2 3 4} tag {File Mask Sort Opt Help} {
    configMenuText $m $idx Tree$tag $lang
  }
  foreach idx {0 1 2 3 4 5 7 8 10 12} tag {Save Fill FillWithBase FillWithGame SetCacheSize CacheInfo Best Graph Copy Close} {
    configMenuText $m.file $idx TreeFile$tag $lang
  }
  foreach idx {0 1 2 3 4 5} tag {New Open Save Close FillWithGame FillWithBase} {
    configMenuText $m.mask $idx TreeMask$tag $lang
  }
  foreach idx {0 1 2 3} tag {Alpha ECO Freq Score } {
    configMenuText $m.sort $idx TreeSort$tag $lang
  }
  foreach idx {0 1 3 5 6 7} tag {Lock Training Autosave Slowmode Fastmode FastAndSlowmode} {
    configMenuText $m.opt $idx TreeOpt$tag $lang
  }
  foreach idx {0 1} tag {Tree Index} {
    configMenuText $m.helpmenu $idx TreeHelp$tag $lang
  }
}

# ################################################################################
proc ::tree::ConfigMenus { { lang "" } } {
  for {set i 1 } {$i <= [sc_base count total]} {incr i} {
    ::tree::doConfigMenus $i $lang
  }
}
################################################################################
proc ::tree::menuCopyToSelection { baseNumber } {
  clipboard clear
  clipboard append [ .treeWin$baseNumber.f.tl get 1.0 end ]
}
################################################################################
proc ::tree::treeFileSave {base} {
  busyCursor .
  update
  if {[catch {sc_tree write $base} result]} {
    tk_messageBox -type ok -icon warning -title "Scid: Error writing file" -message $result
  }
  unbusyCursor .
}
################################################################################
proc ::tree::make { { baseNumber -1 } } {
  global tree treeWin highcolor geometry helpMessage
  
  if {$baseNumber == -1} {set baseNumber [sc_base current]}
  
  if {[winfo exists .treeWin$baseNumber]} {
    focus .
    destroy .treeWin$baseNumber
    set treeWin$baseNumber 0
    return
  }
  
  toplevel .treeWin$baseNumber
  set w .treeWin$baseNumber
  setWinLocation $w
  
  # Set the tree window title now:
  wm title $w "Scid: [tr WindowsTree] $baseNumber [file tail [sc_base filename $baseNumber] ]"
  set ::treeWin$baseNumber 1
  set tree(training$baseNumber) 0
  set tree(autorefresh$baseNumber) 1
  set tree(locked$baseNumber) 0
  set tree(base$baseNumber) $baseNumber
  set tree(status$baseNumber) ""
  set tree(bestMax$baseNumber) 50
  set tree(order$baseNumber) "frequency"
  trace variable tree(bestMax$baseNumber) w "::tree::doTrace bestMax"
  set tree(bestRes$baseNumber) "1-0 0-1 1/2 *"
  trace variable tree(bestRes$baseNumber) w "::tree::doTrace bestRes"
  
  bind $w <Destroy> " set ::treeWin$baseNumber 0; set tree(locked$baseNumber) 0 "
  bind $w <F1> { helpWindow Tree }
  bind $w <Escape> " .treeWin$baseNumber.buttons.stop invoke "
  standardShortcuts $w
  
  menu $w.menu
  $w configure -menu $w.menu
  $w.menu add cascade -label TreeFile -menu $w.menu.file
  $w.menu add cascade -label TreeMask -menu $w.menu.mask
  $w.menu add cascade -label TreeSort -menu $w.menu.sort
  $w.menu add cascade -label TreeOpt  -menu $w.menu.opt
  $w.menu add cascade -label TreeHelp -menu $w.menu.helpmenu
  foreach i {file mask sort opt helpmenu} {
    menu $w.menu.$i -tearoff 0
  }
  
  $w.menu.file add command -label TreeFileSave -command "::tree::treeFileSave $baseNumber"
  set helpMessage($w.menu.file,0) TreeFileSave
  $w.menu.file add command -label TreeFileFill -command "::tree::prime $baseNumber"
  set helpMessage($w.menu.file,1) TreeFileFill
  $w.menu.file add command -label TreeFileFillWithBase -command "::tree::primeWithBase"
  set helpMessage($w.menu.file,2) TreeFileFillWithBase
  $w.menu.file add command -label TreeFileFillWithGame -command "::tree::primeWithGame"
  set helpMessage($w.menu.file,3) TreeFileFillWithGame
  
  menu $w.menu.file.size
  foreach i { 250 500 1000 2000 5000 10000 } {
    $w.menu.file.size add radiobutton -label "$i" -value $i -variable ::tree::cachesize($baseNumber) -command "::tree::setCacheSize $baseNumber $i"
  }
  
  $w.menu.file add cascade -menu $w.menu.file.size -label TreeFileSetCacheSize
  set helpMessage($w.menu.file,4) TreeFileSetCacheSize
  
  $w.menu.file add command -label TreeFileCacheInfo -command "::tree::getCacheInfo $baseNumber"
  set helpMessage($w.menu.file,5) TreeFileCacheInfo
  
  $w.menu.file add separator
  $w.menu.file add command -label TreeFileBest -command "::tree::best $baseNumber"
  set helpMessage($w.menu.file,7) TreeFileBest
  
  $w.menu.file add command -label TreeFileGraph -command "::tree::graph $baseNumber"
  set helpMessage($w.menu.file,8) TreeFileGraph
  $w.menu.file add separator
  $w.menu.file add command -label TreeFileCopy -command "::tree::menuCopyToSelection $baseNumber"
  set helpMessage($w.menu.file,10) TreeFileCopy
  $w.menu.file add separator
  $w.menu.file add command -label TreeFileClose -command ".treeWin$baseNumber.buttons.close invoke"
  set helpMessage($w.menu.file,12) TreeFileClose
  
  $w.menu.mask add command -label TreeMaskNew -command "::tree::mask::new"
  set helpMessage($w.menu.mask,0) TreeMaskNew
  $w.menu.mask add command -label TreeMaskOpen -command "::tree::mask::open"
  set helpMessage($w.menu.mask,1) TreeMaskOpen
  $w.menu.mask add command -label TreeMaskSave -command "::tree::mask::save"
  set helpMessage($w.menu.mask,2) TreeMaskSave
  $w.menu.mask add command -label TreeMaskClose -command "::tree::mask::close"
  set helpMessage($w.menu.mask,3) TreeMaskClose
  $w.menu.mask add command -label TreeMaskFillWithGame -command "::tree::mask::fillWithGame"
  set helpMessage($w.menu.mask,4) TreeMaskFillWithGame
  $w.menu.mask add command -label TreeMaskFillWithBase -command "::tree::mask::fillWithBase"
  set helpMessage($w.menu.mask,4) TreeMaskFillWithBase
  
  foreach label {Alpha ECO Freq Score} value {alpha eco frequency score} {
    $w.menu.sort add radiobutton -label TreeSort$label \
        -variable tree(order$baseNumber) -value $value -command " ::tree::refresh $baseNumber "
  }
  
  $w.menu.opt add checkbutton -label TreeOptLock -variable tree(locked$baseNumber) \
      -command "::tree::toggleLock $baseNumber"
  set helpMessage($w.menu.opt,0) TreeOptLock
  
  $w.menu.opt add checkbutton -label TreeOptTraining -variable tree(training$baseNumber) -command "::tree::toggleTraining $baseNumber"
  set helpMessage($w.menu.opt,1) TreeOptTraining
  
  $w.menu.opt add separator
  $w.menu.opt add checkbutton -label TreeOptAutosave -variable tree(autoSave$baseNumber)
  set helpMessage($w.menu.opt,3) TreeOptAutosave
  
  $w.menu.opt add separator
  $w.menu.opt add radiobutton -label TreeOptSlowmode -value 0 -variable tree(fastmode$baseNumber) -command "::tree::refresh $baseNumber"
  set helpMessage($w.menu.opt,5) TreeOptSlowmode
  
  $w.menu.opt add radiobutton -label TreeOptFastmode -value 1 -variable tree(fastmode$baseNumber) -command "::tree::refresh $baseNumber"
  set helpMessage($w.menu.opt,6) TreeOptFastmode
  
  $w.menu.opt add radiobutton -label TreeOptFastAndSlowmode -value 2 -variable tree(fastmode$baseNumber) -command "::tree::refresh $baseNumber"
  set helpMessage($w.menu.opt,7) TreeOptFastAndSlowmode
  set tree(fastmode$baseNumber) 0
  
  $w.menu.helpmenu add command -label TreeHelpTree -accelerator F1 -command {helpWindow Tree}
  $w.menu.helpmenu add command -label TreeHelpIndex -command {helpWindow Index}
  
  ::tree::doConfigMenus $baseNumber
  
  autoscrollframe $w.f text $w.f.tl \
      -width $::winWidth(.treeWin) -height $::winHeight(.treeWin) -wrap none \
      -font font_Fixed -foreground black -background white -setgrid 1 -exportselection 1
  #define default tags
  $w.f.tl tag configure greybg -background #fa1cfa1cfa1c
  $w.f.tl tag configure whitebg -background white
  $w.f.tl tag configure bluefg -foreground blue
  
  canvas $w.progress -width 250 -height 15 -bg white -relief solid -border 1
  $w.progress create rectangle 0 0 0 0 -fill blue -outline blue -tags bar
  selection handle $w.f.tl "::tree::copyToSelection $baseNumber"
  bindMouseWheel $w $w.f.tl
  
  bind $w.f.tl <Destroy> {
    set win "%W"
    set bn ""
    scan $win ".treeWin%%d.f.tl" bn
    ::tree::closeTree $tree(base$bn)
    set mctxt $win.ctxtMenu
    if { [winfo exists $mctxt] } {
      destroy $mctxt
    }
  }
  
  bind $w <Configure> "recordWinSize $w"
  
  label $w.status -width 1 -anchor w -font font_Small \
      -relief sunken -textvar tree(status$baseNumber)
  pack $w.status -side bottom -fill x
  pack $w.progress -side bottom
  pack [frame $w.buttons -relief sunken] -side bottom -fill x
  pack $w.f -side top -expand 1 -fill both
  
  button $w.buttons.best -image b_list -command "::tree::best $baseNumber"
  button $w.buttons.graph -image b_bargraph -command "::tree::graph $baseNumber"
  # add a button to start/stop tree refresh
  button $w.buttons.bStartStop -image engine_on -command "::tree::toggleRefresh $baseNumber" -relief flat
  
  checkbutton $w.buttons.lock -textvar ::tr(LockTree) \
      -variable tree(locked$baseNumber) -command "::tree::toggleLock $baseNumber"
  checkbutton $w.buttons.training -textvar ::tr(Training) \
      -variable tree(training$baseNumber) -command "::tree::toggleTraining $baseNumber"
  
  foreach {b t} {
    best TreeFileBest graph TreeFileGraph lock TreeOptLock
    training TreeOptTraining
  } {
    set helpMessage($w.buttons.$b) $t
  }
  
  dialogbutton $w.buttons.stop -textvar ::tr(Stop) -command { sc_progressBar }
  dialogbutton $w.buttons.close -textvar ::tr(Close) -command "::tree::closeTree $baseNumber"
  
  pack $w.buttons.best $w.buttons.graph $w.buttons.bStartStop $w.buttons.lock $w.buttons.training \
      -side left -padx 3 -pady 2
  packbuttons right $w.buttons.close $w.buttons.stop
  $w.buttons.stop configure -state disabled
  
  wm minsize $w 40 5
  
  # TODO
  # bind $w.f.tl <Return> " tree::select [lindex [ .treeWin$baseNumber.f.tl curselection] 0] $baseNumber "
  # bind $w.f.tl <ButtonRelease-1> "[list ::tree::selectCallback $baseNumber %y ] ; break"
  wm protocol $w WM_DELETE_WINDOW " .treeWin$baseNumber.buttons.close invoke "
  ::tree::refresh $baseNumber
  set ::tree::cachesize($baseNumber) [lindex [sc_tree cacheinfo $baseNumber] 1]
}

################################################################################
proc ::tree::selectCallback { baseNumber move } {
  
  if { $::tree(refresh) } {
    return
  }
  
  if {$::tree(autorefresh$baseNumber)} {
    # TODO
    # .treeWin$baseNumber.f.tl selection clear 0 end
    # find the line clicked
    # scan [.treeWin$baseNumber.f.tl index end] "%d.%d" lastl lastc
    # puts "lastl lastc $lastl $lastc"
    # set nearest -1
    # for {set l 2} {$l < $lastl} {incr l} {
    # set box [ .treeWin$baseNumber.f.tl bbox $l.0]
    # set y [lindex $box 1]
    # set w [lindex $box 3]
    # if { $line >= $y && $line <= [expr $y + $w]} {
    # set nearest $l
    # break
    # }
    # }
    #
    # if {$nearest == -1} {
    # return
    # }
    #
    # incr nearest -1
    # puts "nearest $nearest"
    # tree::select [ .treeWin$baseNumber.f.tl nearest $line ] $baseNumber
    tree::select $move $baseNumber
    # TODO
    # .treeWin$baseNumber.f.tl selection clear 0 end
  }
}

################################################################################
# close the corresponding base if it is flagged as locked
proc ::tree::closeTree {baseNumber} {
  global tree
  
  trace remove variable tree(bestMax$baseNumber) write "::tree::doTrace bestMax"
  trace remove variable tree(bestRes$baseNumber) write "::tree::doTrace bestRes"
  
  set ::geometry(treeWin$baseNumber) [wm geometry .treeWin$baseNumber]
  focus .
  
  if {$tree(autoSave$baseNumber)} {
    busyCursor .
    catch { sc_tree write $tree(base$baseNumber) } ; # necessary as it will be triggered twice
    unbusyCursor .
  }
  
  if {$::tree(locked$baseNumber)} {
    ::file::Close $baseNumber
  } else {
    if {[winfo exists .treeGraph$baseNumber]} {
      destroy .treeGraph$baseNumber
    }
    if {[winfo exists .treeBest$baseNumber]} {
      destroy .treeBest$baseNumber
    }
    destroy .treeWin$baseNumber
  }
}
################################################################################
proc ::tree::doTrace { prefix name1 name2 op} {
  if {[scan $name2 "$prefix%d" baseNumber] !=1 } {
    tk_messageBox -parent . -icon error -type ok -title "Fatal Error" \
        -message "Scan failed in trace code\ndoTrace $prefix $name1 $name2 $op"
    return
  }
  ::tree::best $baseNumber
}
################################################################################
proc ::tree::toggleTraining { baseNumber } {
  global tree
  
  for {set i 1 } {$i <= [sc_base count total]} {incr i} {
    if {! [winfo exists .treeWin$baseNumber] || $i == $baseNumber } { continue }
    set tree(training$i) 0
  }
  
  if {$tree(training$baseNumber)} {
    set ::tree::trainingBase $baseNumber
    ::tree::doTraining
  } else {
    set ::tree::trainingBase 0
    ::tree::refresh $baseNumber
  }
}

################################################################################
proc ::tree::doTraining { { n 0 } } {
  global tree
  if {$n != 1  &&  [winfo exists .analysisWin1]  &&  $::analysis(automove1)} {
    automove 1
    return
  }
  if {$n != 2  &&  [winfo exists .analysisWin2]  &&  $::analysis(automove2)} {
    automove 2
    return
  }
  if {[::tb::isopen]  &&  $::tbTraining} {
    ::tb::move
    return
  }
  if {! [winfo exists .treeWin$::tree::trainingBase]} { return }
  if { $::tree::trainingBase == 0 } { return }
  set move [sc_tree move $::tree::trainingBase random]
  addSanMove $move -animate -notraining
  updateBoard -pgn
}

################################################################################
proc ::tree::toggleLock { baseNumber } {
  global tree
  if {$tree(locked$baseNumber)} {
    # set tree(base$baseNumber) [sc_base current]
  } else {
    # set tree(base$baseNumber) 0
  }
  ::tree::refresh $baseNumber
}

################################################################################
proc ::tree::select { move baseNumber } {
  global tree
  
  if {! [winfo exists .treeWin$baseNumber]} { return }
  # TODO
  # .treeWin$baseNumber.f.tl selection clear 0 end
  # if {$selection == 0} {
  # sc_move back
  # updateBoard -pgn
  # return
  # }
  
  # set move [sc_tree move $baseNumber $selection]
  # if {$move == ""} { return }
  addSanMove $move -animate
}

set tree(refresh) 0

################################################################################
proc ::tree::refresh { { baseNumber "" }} {
  
  set stack [lsearch -glob -inline -all [ wm stackorder . ] ".treeWin*"]
  
  if {$baseNumber == "" } {
    set topwindow [lindex [lsearch -glob -inline -all [ wm stackorder . ] ".treeWin*"] end ]
    set topbase -1
    if { [ catch { scan $topwindow ".treeWin%d" topbase } ] } {
    } else {
      ::tree::dorefresh $topbase
    }
    for {set i 1 } {$i <= [sc_base count total]} {incr i} {
      if { $i == $topbase } { continue }
      ::tree::dorefresh $i
    }
  } else {
    ::tree::dorefresh $baseNumber
  }
}

################################################################################
proc ::tree::dorefresh { baseNumber } {
  global tree treeWin glstart
  set w .treeWin$baseNumber
  
  if {![winfo exists $w]} { return }
  if { ! $tree(autorefresh$baseNumber) } { return }
  
  busyCursor .
  sc_progressBar $w.progress bar 251 16
  foreach button {best graph training lock close} {
    $w.buttons.$button configure -state disabled
  }
  $w.buttons.stop configure -state normal
  set tree(refresh) 1
  
  update
  
  set base $baseNumber
  
  if { $tree(fastmode$baseNumber) == 0 } {
    set fastmode 0
  } else {
    set fastmode 1
  }
  
  set moves [sc_tree search -hide $tree(training$baseNumber) -sort $tree(order$baseNumber) -base $base -fastmode $fastmode]
  displayLines $baseNumber $moves
  
  if {[winfo exists .treeBest$baseNumber]} { ::tree::best $baseNumber}
  
  # ========================================
  if { $tree(fastmode$baseNumber) == 2 } {
    ::tree::status "" $baseNumber
    sc_progressBar $w.progress bar 251 16
    set moves [sc_tree search -hide $tree(training$baseNumber) -sort $tree(order$baseNumber) -base $base -fastmode 0]
    displayLines $baseNumber $moves
  }
  # ========================================
  
  catch {$w.f.tl itemconfigure 0 -foreground darkBlue}
  
  foreach button {best graph training lock close} {
    $w.buttons.$button configure -state normal
  }
  $w.buttons.stop configure -state disabled -relief raised
  
  unbusyCursor .
  set tree(refresh) 0
  
  $w.f.tl configure -cursor {}
  # TODO
  # $w.f.tl selection clear 0 end
  
  ::tree::status "" $baseNumber
  set glstart 1
  ::windows::stats::Refresh
  if {[winfo exists .treeGraph$baseNumber]} { ::tree::graph $baseNumber }
  ::windows::gamelist::Refresh
  updateTitle
}

################################################################################
#
################################################################################
proc ::tree::displayLines { baseNumber moves } {
  global ::tree::mask::maskFile
  
  set lMoves {}
  set w .treeWin$baseNumber
  
  $w.f.tl configure -state normal
  
  set moves [split $moves "\n"]
  
  # for the graph display
  set ::tree::treeData$baseNumber $moves
  
  set len [llength $moves]
  $w.f.tl delete 1.0 end
  
  foreach t [$w.f.tl tag names] {
    if { [ string match "tagclick*" $t ] || [ string match "tagtooltip*" $t ] } {
      $w.f.tl tag delete $t
    }
  }
  
  # Position comment
  if { $maskFile != "" } {
    set posComment [::tree::mask::getPositionComment]
    if {$posComment != ""} {
      set firstLine [ lindex [split $posComment "\n"] 0 ]
      $w.f.tl insert end "$firstLine\n" [ list bluefg tagtooltip_poscomment ]
      ::utils::tooltip::SetTag $w.f.tl $posComment tagtooltip_poscomment
    }
  }
  
  for { set i 0 } { $i < [expr $len - 1 ] } { incr i } {
    set line [lindex $moves $i]
    if {$line == ""} { continue }
    set move [lindex $line 1]
    
    set move [::untrans $move]
    lappend lMoves $move
    
    set tagfg ""
    
    if { $maskFile != "" && $move != "\[end\]" && $i > 0 && $i < [expr $len - 3] } {
      if { [::tree::mask::moveExists $move] } {
        set tagfg "bluefg"
      }
    }
    if { $maskFile != "" } {
      if { $i > 0 && $i < [expr $len - 3] && $move != "\[end\]" } {
        # color tag
        $w.f.tl tag configure color$i -background [::tree::mask::getColor $move]
        $w.f.tl insert end "  " color$i
        # NAG tag
        $w.f.tl insert end [::tree::mask::getNag $move]
      } else  {
        $w.f.tl insert end "    "
      }
    }
    
    # Move
    if {[expr $i % 2] && $i < [expr $len -3] } {
      $w.f.tl insert end "$line" [list greybg $tagfg tagclick$i]
    } else  {
      $w.f.tl insert end "$line" [list whitebg $tagfg tagclick$i]
    }
    
    if {$move != "" && $move != "---" && $move != "\[end\]" && $i != [expr $len -2] && $i != 0} {
      $w.f.tl tag bind tagclick$i <Button-1> "[list ::tree::selectCallback $baseNumber $move ] ; break"
      if { $maskFile != "" } {
        # Bind right button to popup a contextual menu:
        $w.f.tl tag bind tagclick$i <ButtonPress-3> "::tree::mask::contextMenu $w.f.tl $move %x %y %X %Y"
      }
    }
    
    if { $maskFile != "" } {
      # Move comment
      set comment [::tree::mask::getComment $move]
      if {$comment != ""} {
        set firstLine [ lindex [split $comment "\n"] 0 ]
        $w.f.tl insert end " $firstLine" tagtooltip$i
        ::utils::tooltip::SetTag $w.f.tl $comment tagtooltip$i
      }
      $w.f.tl insert end "\n"
    } else  {
      $w.f.tl insert end "\n"
    }
  }
  
  # Add moves present in Mask and not in Tree
  set idx $len
  if { $maskFile != "" } {
    set movesMask [::tree::mask::getAllMoves]
    foreach m $movesMask {
      # move nag color move_anno
      if {[lsearch $lMoves [lindex $m 0]] != -1 || [lindex $m 0] == "null"} {
        continue
      }
      
      $w.f.tl tag bind tagclick$idx <Button-1> "[list ::tree::selectCallback $baseNumber [lindex $m 0] ] ; break"
      # Bind right button to popup a contextual menu:
      $w.f.tl tag bind tagclick$idx <ButtonPress-3> "::tree::mask::contextMenu $w.f.tl [lindex $m 0] %x %y %X %Y"
      
      # color tag
      $w.f.tl tag configure color$idx -background [lindex $m 2]
      $w.f.tl insert end "  " [ list color$idx tagclick$idx ]
      # NAG tag
      $w.f.tl insert end [::tree::mask::getNag [lindex $m 0]] tagclick$idx
      # move
      $w.f.tl insert end "[lindex $m 0] " [ list bluefg tagclick$idx ]
      # comment
      set comment [lindex $m 3]
      set firstLine [ lindex [split $comment "\n"] 0 ]
      $w.f.tl insert end "$firstLine\n" tagtooltip$idx
      ::utils::tooltip::SetTag $w.f.tl $comment tagtooltip$idx
      incr idx
    }
  }
  
  $w.f.tl configure -state disabled
  
}
################################################################################
proc ::tree::status { msg baseNumber } {
  
  global tree
  if {$msg != ""} {
    set tree(status$baseNumber) $msg
    return
  }
  set s "  $::tr(Database)"
  # set base [sc_base current]
  # if {$tree(locked$baseNumber)} { set base $tree(base$baseNumber) }
  set base $baseNumber
  set status "  $::tr(Database) $base: [file tail [sc_base filename $base]]"
  if {$tree(locked$baseNumber)} { append status " ($::tr(TreeLocked))" }
  append status "   $::tr(Filter)"
  append status ": [filterText $base]"
  set tree(status$baseNumber) $status
}

################################################################################
set tree(standardLines) {
  {}
  {1.c4}
  {1.c4 c5}
  {1.c4 c5 2.Nf3}
  {1.c4 e5}
  {1.c4 Nf6}
  {1.c4 Nf6 2.Nc3}
  {1.d4}
  {1.d4 d5}
  {1.d4 d5 2.c4}
  {1.d4 d5 2.c4 c6}
  {1.d4 d5 2.c4 c6 3.Nf3}
  {1.d4 d5 2.c4 c6 3.Nf3 Nf6}
  {1.d4 d5 2.c4 c6 3.Nf3 Nf6 4.Nc3}
  {1.d4 d5 2.c4 c6 3.Nf3 Nf6 4.Nc3 dxc4}
  {1.d4 d5 2.c4 c6 3.Nf3 Nf6 4.Nc3 e6}
  {1.d4 d5 2.c4 c6 3.Nf3 Nf6 4.Nc3 e6 5.e3}
  {1.d4 d5 2.c4 e6}
  {1.d4 d5 2.c4 e6 3.Nc3}
  {1.d4 d5 2.c4 e6 3.Nc3 Nf6}
  {1.d4 d5 2.c4 e6 3.Nf3}
  {1.d4 d5 2.c4 dxc4}
  {1.d4 d5 2.c4 dxc4 3.Nf3}
  {1.d4 d5 2.c4 dxc4 3.Nf3 Nf6}
  {1.d4 d5 2.Nf3}
  {1.d4 d5 2.Nf3 Nf6}
  {1.d4 d5 2.Nf3 Nf6 3.c4}
  {1.d4 d6}
  {1.d4 d6 2.c4}
  {1.d4 Nf6}
  {1.d4 Nf6 2.c4}
  {1.d4 Nf6 2.c4 c5}
  {1.d4 Nf6 2.c4 d6}
  {1.d4 Nf6 2.c4 e6}
  {1.d4 Nf6 2.c4 e6 3.Nc3}
  {1.d4 Nf6 2.c4 e6 3.Nc3 Bb4}
  {1.d4 Nf6 2.c4 e6 3.Nf3}
  {1.d4 Nf6 2.c4 g6}
  {1.d4 Nf6 2.c4 g6 3.Nc3}
  {1.d4 Nf6 2.c4 g6 3.Nc3 Bg7}
  {1.d4 Nf6 2.c4 g6 3.Nc3 Bg7 4.e4}
  {1.d4 Nf6 2.c4 g6 3.Nc3 Bg7 4.e4 d6}
  {1.d4 Nf6 2.c4 g6 3.Nc3 Bg7 4.e4 d6 5.Nf3}
  {1.d4 Nf6 2.c4 g6 3.Nc3 Bg7 4.e4 d6 5.Nf3 O-O}
  {1.d4 Nf6 2.c4 g6 3.Nc3 Bg7 4.e4 d6 5.Nf3 O-O 6.Be2}
  {1.d4 Nf6 2.c4 g6 3.Nf3}
  {1.d4 Nf6 2.Bg5}
  {1.d4 Nf6 2.Bg5 Ne4}
  {1.d4 Nf6 2.Nf3}
  {1.d4 Nf6 2.Nf3 e6}
  {1.d4 Nf6 2.Nf3 g6}
  {1.e4}
  {1.e4 c5}
  {1.e4 c5 2.c3}
  {1.e4 c5 2.c3 d5}
  {1.e4 c5 2.c3 Nf6}
  {1.e4 c5 2.Nc3}
  {1.e4 c5 2.Nc3 Nc6}
  {1.e4 c5 2.Nf3}
  {1.e4 c5 2.Nf3 d6}
  {1.e4 c5 2.Nf3 d6 3.d4}
  {1.e4 c5 2.Nf3 d6 3.d4 cxd4}
  {1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4}
  {1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6}
  {1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3}
  {1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 a6}
  {1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 e6}
  {1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 g6}
  {1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 Nc6}
  {1.e4 c5 2.Nf3 d6 3.Bb5+}
  {1.e4 c5 2.Nf3 e6}
  {1.e4 c5 2.Nf3 Nc6}
  {1.e4 c5 2.Nf3 Nc6 3.d4}
  {1.e4 c5 2.Nf3 Nc6 3.Bb5}
  {1.e4 c6}
  {1.e4 c6 2.d4}
  {1.e4 c6 2.d4 d5}
  {1.e4 c6 2.d4 d5 3.e5}
  {1.e4 c6 2.d4 d5 3.Nc3}
  {1.e4 c6 2.d4 d5 3.Nd2}
  {1.e4 d5}
  {1.e4 d6}
  {1.e4 d6 2.d4}
  {1.e4 d6 2.d4 Nf6}
  {1.e4 d6 2.d4 Nf6 3.Nc3}
  {1.e4 e5}
  {1.e4 e5 2.Nf3}
  {1.e4 e5 2.Nf3 Nc6}
  {1.e4 e5 2.Nf3 Nc6 3.d4}
  {1.e4 e5 2.Nf3 Nc6 3.Bb5}
  {1.e4 e5 2.Nf3 Nc6 3.Bb5 a6}
  {1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4}
  {1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4 Nf6}
  {1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4 Nf6 5.O-O}
  {1.e4 e5 2.Nf3 Nc6 3.Bc4}
  {1.e4 e5 2.Nf3 Nf6}
  {1.e4 e6}
  {1.e4 e6 2.d4}
  {1.e4 e6 2.d4 d5}
  {1.e4 e6 2.d4 d5 3.Nc3}
  {1.e4 e6 2.d4 d5 3.Nc3 Bb4}
  {1.e4 e6 2.d4 d5 3.Nc3 Nf6}
  {1.e4 e6 2.d4 d5 3.Nd2}
  {1.e4 e6 2.d4 d5 3.Nd2 c5}
  {1.e4 e6 2.d4 d5 3.Nd2 Nf6}
  {1.e4 Nf6}
  {1.e4 Nf6 2.e5}
  {1.e4 Nf6 2.e5 Nd5}
  {1.Nf3}
  {1.Nf3 Nf6}
}
# if there is a treecache file source it, otherwise use hard coded
# values above
set scidConfigFiles(treecache) "treecache.dat"
catch {source [scidConfigFile treecache]}

################################################################################
# ::tree::prime
#   Primes the tree for this database, filling it with a number of
#   common opening positions.
#
proc ::tree::prime { baseNumber } {
  global tree
  if {! [winfo exists .treeWin$baseNumber]} { return }
  
  set base $baseNumber
  if {$tree(locked$baseNumber)} { set base $tree(base$baseNumber) }
  if {! [sc_base inUse]} { return }
  set fname [sc_base filename $base]
  if {[string index $fname 0] == "\["  ||  [file extension $fname] == ".pgn"} {
    tk_messageBox -parent .treeWin$baseNumber -icon info -type ok -title "Scid" \
        -message "Sorry, only Scid-format database files can have a tree cache file."
    return
  }
  
  set ::interrupt 0
  progressWindow "Scid: [tr TreeFileFill]" "" $::tr(Cancel) {set ::interrupt 1}
  resetProgressWindow
  leftJustifyProgressWindow
  busyCursor .
  sc_game push
  set i 1
  set len [llength $tree(standardLines)]
  foreach line $tree(standardLines) {
    sc_game new
    set text [format "%3d/\%3d" $i $len]
    if {[llength $line] > 0}  {
      sc_move addSan $line
      changeProgressWindow "$text: $line"
    } else {
      changeProgressWindow "$text: start position"
    }
    sc_tree search -base $base -fastmode 0
    updateProgressWindow $i $len
    incr i
    if {$::interrupt} {
      closeProgressWindow
      set ::interrupt 0
      sc_game pop
      unbusyCursor .
      ::tree::refresh $baseNumber
      return
    }
  }
  closeProgressWindow
  if {[catch {sc_tree write $base} result]} {
    #tk_messageBox -type ok -icon warning -title "Scid: Error writing file" -message $result
  } else {
    #set a "$fname.stc: [sc_tree positions] positions, "
    #append a "$result bytes: "
    #set pergame [expr double($result) / double([sc_base numGames])]
    #append a [format "%.2f" $pergame]
    #append a " bytes per game"
    #tk_messageBox -type ok -parent .treeWin -title "Scid" -message $a
  }
  sc_game pop
  unbusyCursor .
  ::tree::refresh $baseNumber
}

################################################################################
# ::tree::best
#   Updates the window of best (highest-rated) tree games.
#
proc ::tree::best { baseNumber } {
  global tree
  set w .treeBest$baseNumber
  if {! [winfo exists .treeWin$baseNumber]} { return }
  if {! [winfo exists $w]} {
    toplevel $w
    wm title $w "Scid: $::tr(TreeBestGames) $baseNumber: [file tail [sc_base filename $baseNumber]]"
    setWinLocation $w
    bind $w <Escape> "destroy $w"
    bind $w <F1> {helpWindow Tree Best}
    pack [frame $w.b] -side bottom -fill x
    pack [frame $w.opt] -side bottom -fill x
    set pane [::utils::pane::Create $w.pane blist bpgn 520 320 0.6]
    ::utils::pane::SetRange $w.pane 0.3 0.8
    pack $pane -side top -expand true -fill both
    scrollbar $pane.blist.ybar -command "$pane.blist.list yview" -takefocus 0
    listbox $pane.blist.list -background white -yscrollcommand "$pane.blist.ybar set" -font font_Small
    pack $pane.blist.ybar -side right -fill y
    pack $pane.blist.list -side left -fill both -expand yes
    bind $pane.blist.list <<ListboxSelect>> "::tree::bestPgn $baseNumber"
    bind $pane.blist.list <Double-Button-1> "::tree::bestBrowse $baseNumber"
    
    scrollbar $pane.bpgn.ybar -command "$pane.bpgn.text yview" -takefocus 0
    text $pane.bpgn.text -width 50 -height 20 -background gray90 \
        -cursor top_left_arrow -yscrollcommand "$pane.bpgn.ybar set" -wrap word \
        -state disabled -font font_Small
    pack $pane.bpgn.ybar -side right -fill y
    pack $pane.bpgn.text -side left -fill both -expand yes
    set t $pane.bpgn.text
    bind $t <ButtonPress-1> "::pgn::ShowBoard $pane.bpgn.text 4 %x %y %X %Y"
    bind $t <ButtonRelease-1> ::pgn::HideBoard
    bind $t <ButtonPress-2> "::pgn::ShowBoard $pane.bpgn.text 4 %x %y %X %Y"
    bind $t <ButtonRelease-2> ::pgn::HideBoard
    bind $t <ButtonPress-3> "::pgn::ShowBoard $pane.bpgn.text 4 %x %y %X %Y"
    bind $t <ButtonRelease-3> :::pgn::HideBoard
    
    label $w.opt.lmax -text $::tr(TreeBest:) -font font_Small
    set m [tk_optionMenu $w.opt.max tree(bestMax$baseNumber) 10 20 50 100 200 500]
    $m configure -font font_Small
    $w.opt.max configure -font font_Small
    label $w.opt.lres -text " $::tr(Result):" -font font_Small
    set m [tk_optionMenu $w.opt.res tree(bestRes$baseNumber) \
        "1-0 0-1 1/2 *" 1-0 0-1 "1-0 0-1" 1/2-1/2]
    $m configure -font font_Small
    $w.opt.res configure -font font_Small
    
    button $w.b.browse -text $::tr(BrowseGame) -command "::tree::bestBrowse $baseNumber"
    button $w.b.load -text $::tr(LoadGame) -command "::tree::bestLoad $baseNumber"
    button $w.b.merge -text $::tr(MergeGame) -command "::tree::bestMerge $baseNumber"
    button $w.b.close -text $::tr(Close) -command "destroy $w"
    foreach i {browse load merge close} { $w.b.$i configure -font font_Small }
    pack $w.b.close $w.b.merge $w.b.load $w.b.browse \
        -side right -padx 1 -pady 2
    pack $w.opt.lmax $w.opt.max -side left -padx 0 -pady 2
    pack $w.opt.lres $w.opt.res -side left -padx 0 -pady 2
    bind $w <Configure> "recordWinSize $w"
    focus $w.pane.blist.list
  }
  $w.pane.blist.list delete 0 end
  set tree(bestList$baseNumber) {}
  set count 0
  
  if {! [sc_base inUse]} { return }
  foreach {idx line} [sc_tree best $tree(base$baseNumber) $tree(bestMax$baseNumber) $tree(bestRes$baseNumber)] {
    incr count
    $w.pane.blist.list insert end "[format %02d $count]:  $line"
    lappend tree(bestList$baseNumber) $idx
  }
  catch {$w.pane.blist.list selection set 0}
  ::tree::bestPgn $baseNumber
}

################################################################################
proc ::tree::bestLoad { baseNumber } {
  global tree
  if {[catch {set sel [.treeBest$baseNumber.pane.blist.list curselection]}]} { return }
  if {[catch {set g [lindex $tree(bestList$baseNumber) $sel]}]} { return }
  if {$tree(locked$baseNumber)} { sc_base switch $tree(base$baseNumber) }
  ::game::Load $g
}

################################################################################
proc ::tree::bestMerge { baseNumber } {
  global tree
  if {[catch {set sel [.treeBest$baseNumber.pane.blist.list curselection]}]} { return }
  if {[catch {set gnum [lindex $tree(bestList$baseNumber) $sel]}]} { return }
  set base $baseNumber
  if {$tree(locked$baseNumber)} { set base $tree(base$baseNumber) }
  mergeGame $base $gnum
}

################################################################################
proc ::tree::bestBrowse { baseNumber } {
  global tree
  if {[catch {set sel [.treeBest$baseNumber.pane.blist.list curselection]}]} { return }
  if {[catch {set gnum [lindex $tree(bestList$baseNumber) $sel]}]} { return }
  set base $baseNumber
  if {$tree(locked$baseNumber)} { set base $tree(base$baseNumber) }
  ::gbrowser::new $base $gnum
}

################################################################################
proc ::tree::bestPgn { baseNumber } {
  global tree
  set t .treeBest$baseNumber.pane.bpgn.text
  $t configure -state normal
  $t delete 1.0 end
  if {[catch {set sel [.treeBest$baseNumber.pane.blist.list curselection]}]} { return }
  if {[catch {set g [lindex $tree(bestList$baseNumber) $sel]}]} { return }
  
  set base $baseNumber
  
  if {[catch {sc_game summary -base $base -game $g header} header]} { return }
  if {[catch {sc_game summary -base $base -game $g moves} moves]} { return }
  if {[catch {sc_filter value $base $g} ply]} { return }
  $t tag configure header -foreground darkBlue
  $t tag configure start -foreground darkRed
  $t insert end $header header
  $t insert end "\n\n"
  set m 0
  set moves [::trans $moves]
  foreach move $moves {
    incr m
    if {$m < $ply} {
      $t insert end $move start
    } else {
      $t insert end $move
    }
    $t insert end " "
  }
  
  $t configure -state disabled
}

################################################################################
# ::tree::graph
#   Updates the tree graph window, creating it if necessary.
#
proc ::tree::graph { baseNumber } {
  set w .treeGraph$baseNumber
  if {! [winfo exists .treeWin$baseNumber]} { return }
  if {! [winfo exists $w]} {
    toplevel $w
    setWinLocation $w
    bind $w <Escape> "destroy $w"
    bind $w <F1> {helpWindow Tree Graph}
    
    menu $w.menu
    $w configure -menu $w.menu
    $w.menu add cascade -label GraphFile -menu $w.menu.file
    menu $w.menu.file
    $w.menu.file add command -label GraphFileColor -command "saveGraph color $w.c"
    $w.menu.file add command -label GraphFileGrey -command "saveGraph gray $w.c"
    $w.menu.file add separator
    $w.menu.file add command -label GraphFileClose -command "destroy $w"
    
    canvas $w.c -width 500 -height 300
    pack $w.c -side top -fill both -expand yes
    $w.c create text 25 10 -tag text -justify center -width 1 -font font_Regular -anchor n
    update
    bind $w <Configure> " \
        .treeGraph$baseNumber.c itemconfigure text -width [expr {[winfo width .treeGraph$baseNumber.c] - 50}] ;\
        .treeGraph$baseNumber.c coords text [expr {[winfo width .treeGraph$baseNumber.c] / 2}] 10 ;\
        ::utils::graph::configure tree$baseNumber -height [expr {[winfo height .treeGraph$baseNumber.c] - 100}] ;\
        ::utils::graph::configure tree$baseNumber -width [expr {[winfo width .treeGraph$baseNumber.c] - 50}] ;\
        ::utils::graph::redraw tree$baseNumber "
    bind $w.c <Button-1> "::tree::graph $baseNumber"
    wm title $w "Scid: Tree Graph $baseNumber: [file tail [sc_base filename $baseNumber]]"
    # wm minsize $w 300 200
    standardShortcuts $w
    ::tree::configGraphMenus "" $baseNumber
  }
  
  $w.c itemconfigure text -width [expr {[winfo width $w.c] - 50}]
  $w.c coords text [expr {[winfo width $w.c] / 2}] 10
  set height [expr {[winfo height $w.c] - 100}]
  set width [expr {[winfo width $w.c] - 50}]
  ::utils::graph::create tree$baseNumber -width $width -height $height -xtop 25 -ytop 60 \
      -xmin 0.5 -xtick 1 -ytick 5 -font font_Small -canvas $w.c
  
  set data {}
  set xlabels {}
  set othersCount 0
  set numOthers 0
  set othersName "..."
  set count 0
  set othersScore 0.0
  set mean 50.0
  set totalGames 0
  set treeData [subst $[subst {::tree::treeData$baseNumber} ] ]
  # [.treeWin$baseNumber.f.tl get 0 end]
  
  set numTreeLines [llength $treeData]
  set totalLineIndex [expr $numTreeLines - 2]
  
  for {set i 0} {$i < [llength $treeData]} {incr i} {
    # Extract info from each line of the tree window:
    # Note we convert "," decimal char back to "." where necessary.
    set line [lindex $treeData $i]
    set mNum [string trim [string range $line  0  1]]
    set freq [string trim [string range $line 17 23]]
    set fpct [string trim [string range $line 25 29]]
    regsub -all {,} $fpct . fpct
    set move [string trim [string range $line  4 9]]
    set score [string trim [string range $line 33 37]]
    regsub -all {,} $score . score
    if {$score > 99.9} { set score 99.9 }
    # Check if this line is "TOTAL:" line:
    if {$i == $totalLineIndex} {
      set mean $score
      set totalGames $freq
    }
    # Add info for this move to the graph if necessary:
    if {[string index $line 2] == ":"  &&  [string compare "<end>" $move]} {
      if {$fpct < 1.0  ||  $freq < 5  ||  $i > 5} {
        incr othersCount $freq
        incr numOthers
        set othersScore [expr {$othersScore + (double($freq) * $score)}]
        set m $move
        if {$numOthers > 1} { set m "..." }
      } else {
        incr count
        lappend data $count
        lappend data $score
        lappend xlabels [list $count "$move ([expr round($score)]%)\n$freq: [expr round($fpct)]%"]
      }
    }
  }
  
  # Add extra bar for other moves if necessary:
  if {$numOthers > 0  &&  $totalGames > 0} {
    incr count
    set fpct [expr {double($othersCount) * 100.0 / double($totalGames)}]
    set sc [expr {round($othersScore / double($othersCount))}]
    set othersName "$m ($sc%)\n$othersCount: [expr round($fpct)]%"
    lappend data $count
    lappend data [expr {$othersScore / double($othersCount)}]
    lappend xlabels [list $count $othersName]
  }
  
  # Plot fake bounds data so graph at least shows range 40-65:
  ::utils::graph::data tree$baseNumber bounds -points 0 -lines 0 -bars 0 -coords {1 41 1 64}
  
  # Replot the graph:
  ::utils::graph::data tree$baseNumber data -color red -points 0 -lines 0 -bars 1 \
      -barwidth 0.75 -outline black -coords $data
  ::utils::graph::configure tree$baseNumber -xlabels $xlabels -xmax [expr {$count + 0.5}] \
      -hline [list {gray80 1 each 5} {gray50 1 each 10} {black 2 at 50} \
      {black 1 at 55} [list red 2 at $mean]] \
      -brect [list [list 0.5 55 [expr {$count + 0.5}] 50 LightSkyBlue1]]
  
  ::utils::graph::redraw tree$baseNumber
  set moves ""
  catch {set moves [sc_game firstMoves 0 -1]}
  if {[string length $moves] == 0} { set moves $::tr(StartPos) }
  set title "$moves ([::utils::thousands $totalGames] $::tr(games))"
  $w.c itemconfigure text -text $title
}

################################################################################
proc ::tree::configGraphMenus { lang baseNumber } {
  if {! [winfo exists .treeGraph$baseNumber]} { return }
  if {$lang == ""} { set lang $::language }
  set m .treeGraph$baseNumber.menu
  foreach idx {0} tag {File} {
    configMenuText $m $idx Graph$tag $lang
  }
  foreach idx {0 1 3} tag {Color Grey Close} {
    configMenuText $m.file $idx GraphFile$tag $lang
  }
}

# ################################################################################
proc ::tree::toggleRefresh { baseNumber } {
  global tree
  set b .treeWin$baseNumber.buttons.bStartStop
  
  if {$tree(autorefresh$baseNumber)} {
    $b configure -image engine_off -relief flat
    set tree(autorefresh$baseNumber) 0
  } else  {
    $b configure -image engine_on -relief flat
    set tree(autorefresh$baseNumber) 1
    ::tree::refresh $baseNumber
  }
}
################################################################################
#
################################################################################
proc ::tree::setCacheSize { base size } {
  sc_tree cachesize $base $size
}
################################################################################
#
################################################################################
proc ::tree::getCacheInfo { base } {
  set ci [sc_tree cacheinfo $base]
  tk_messageBox -title "Scid" -type ok -icon info \
      -message "Cache used : [lindex $ci 0] / [lindex $ci 1]"
  
}
################################################################################
# will go through all moves of all games of current base
################################################################################
set ::tree::cancelPrime 0

proc ::tree::primeWithBase {{ fillMask 0 }} {
  set ::tree::cancelPrime 0
  for {set g 1} { $g <= [sc_base numGames]} { incr g} {
    sc_game load $g
    ::tree::primeWithGame $fillMask
    if {$::tree::cancelPrime } { return }
  }
}
################################################################################
#
################################################################################
proc ::tree::primeWithGame { { fillMask 0 } } {
  set ::tree::totalMoves [countBaseMoves "singleGame" ]
  sc_move start
  updateBoard -pgn
  if {$fillMask} { ::tree::mask::feedMask [ sc_pos fen ] }
  
  set ::tree::parsedMoves 0
  set ::tree::cancelPrime 0
  progressWindow "Scid: [tr TreeFileFill]" "$::tree::totalMoves moves" $::tr(Cancel) {
    set ::tree::cancelPrime 1
    for {set i 1 } {$i <= [sc_base count total]} {incr i} {
      catch { .treeWin$i.buttons.stop invoke }
    }
  }
  resetProgressWindow
  leftJustifyProgressWindow
  ::tree::parseGame $fillMask
  closeProgressWindow
  updateBoard -pgn
}

################################################################################
# parse one game and fill the list
################################################################################
proc ::tree::parseGame {{ fillMask 0 }} {
  if {$::tree::cancelPrime } { return  }
  ::tree::refresh
  if {$::tree::cancelPrime } { return }
  while {![sc_pos isAt vend]} {
    updateProgressWindow $::tree::parsedMoves $::tree::totalMoves
    
    # Go through all variants
    for {set v 0} {$v<[sc_var count]} {incr v} {
      # enter each var (beware the first move is played)
      set fen [ sc_pos fen ]
      sc_var enter $v
      updateBoard -pgn
      if {$fillMask} { ::tree::mask::feedMask $fen }
      if {$::tree::cancelPrime } { return }
      ::tree::refresh
      if {$::tree::cancelPrime } { return }
      ::tree::parseVar $fillMask
      if {$::tree::cancelPrime } { return }
    }
    # now treat the main line
    set fen [ sc_pos fen ]
    sc_move forward
    updateBoard -pgn
    if {$fillMask} { ::tree::mask::feedMask $fen }
    incr ::tree::parsedMoves
    if {$::tree::cancelPrime } { return }
    ::tree::refresh
    if {$::tree::cancelPrime } { return }
  }
}
################################################################################
# parse recursively variants.
################################################################################
proc ::tree::parseVar {{ fillMask 0 }} {
  while {![sc_pos isAt vend]} {
    # Go through all variants
    for {set v 0} {$v<[sc_var count]} {incr v} {
      set fen [ sc_pos fen ]
      sc_var enter $v
      updateBoard -pgn
      if {$fillMask} { ::tree::mask::feedMask $fen }
      if {$::tree::cancelPrime } { return }
      ::tree::refresh
      if {$::tree::cancelPrime } { return }
      # we are at the start of a var, before the first move : start recursive calls
      parseVar $fillMask
      if {$::tree::cancelPrime } { return }
    }
    
    set fen [ sc_pos fen ]
    sc_move forward
    updateBoard -pgn
    if {$fillMask} { ::tree::mask::feedMask $fen }
    incr ::tree::parsedMoves
    updateProgressWindow $::tree::parsedMoves $::tree::totalMoves
    if {$::tree::cancelPrime } { return }
    ::tree::refresh
    if {$::tree::cancelPrime } { return }
  }
  
  sc_var exit
}
################################################################################
# count moves that will fill the cache
################################################################################
proc ::tree::countBaseMoves { {args ""} } {
  set ::tree::total 0
  
  ################################################################################
  proc countParseGame {} {
    sc_move start
    
    while {![sc_pos isAt vend]} {
      for {set v 0} {$v<[sc_var count]} {incr v} {
        sc_var enter $v
        countParseVar
      }
      sc_move forward
      incr ::tree::total
    }
  }
  ################################################################################
  proc countParseVar {} {
    while {![sc_pos isAt vend]} {
      for {set v 0} {$v<[sc_var count]} {incr v} {
        sc_var enter $v
        countParseVar
        incr ::tree::total
      }
      sc_move forward
      incr ::tree::total
    }
    sc_var exit
  }
  
  if {$args == "singleGame"} {
    countParseGame
  } else {
    for {set g 1} { $g <= [sc_base numGames]} { incr g} {
      sc_game load $g
      countParseGame
    }
  }
  return $::tree::total
}

################################################################################
#
#                                 Mask namespace
#
#  All function calls with move in english
################################################################################
namespace eval ::tree::mask {
  # list of (fen (moves) position_annotation )
  # where moves is ( move nag color move_anno )
  set mask {}
  set maskFile ""
  set defaultColor white
  set emptyNag "  "
  set textComment ""
}
################################################################################
#
################################################################################
proc ::tree::mask::open {} {
  set types {
    {{Tree Mask Files}       {.stm}        }
  }
  set filename [tk_getOpenFile -filetypes $types -defaultextension ".stm"]
  
  if {$filename != ""} {
    source $filename
    set ::tree::mask::maskFile $filename
    ::tree::refresh
  }
}
################################################################################
#
################################################################################
proc ::tree::mask::new {} {
  set types {
    {{Tree Mask Files}       {.stm}        }
  }
  set filename [tk_getSaveFile -filetypes $types -defaultextension ".stm"]
  
  if {$filename != ""} {
    set ::tree::mask::maskFile $filename
    set ::tree::mask::mask {}
    ::tree::refresh
  }
}
################################################################################
#
################################################################################
proc ::tree::mask::close {} {
  set ::tree::mask::mask {}
  set ::tree::mask::maskFile ""
  ::tree::refresh
}
################################################################################
#
################################################################################
proc ::tree::mask::save {} {
  set f [ ::open $::tree::mask::maskFile w ]
  puts $f "set ::tree::mask::mask [list $::tree::mask::mask]"
  ::close $f
}
################################################################################
#
################################################################################
proc ::tree::mask::contextMenu {win move x y xc yc} {
  
  update idletasks
  
  set mctxt $win.ctxtMenu
  if { [winfo exists $mctxt] } {
    destroy $mctxt
  }
  
  menu $mctxt
  $mctxt add command -label "Add to Mask" -command "::tree::mask::addToMask $move"
  $mctxt add command -label "Remove from Mask" -command "::tree::mask::removeFromMask $move"
  $mctxt add separator
  $mctxt add command -label "White" -background white -command "::tree::mask::setColor $move white"
  $mctxt add command -label "Green" -background green -command "::tree::mask::setColor $move green"
  $mctxt add command -label "Yellow" -background yellow -command "::tree::mask::setColor $move yellow"
  $mctxt add command -label "Blue" -background blue -command "::tree::mask::setColor $move blue"
  $mctxt add command -label "Red" -background red -command "::tree::mask::setColor $move red"
  $mctxt add separator
  foreach nag { "!!" " !" "!?" "?!" "??" " ~"} {
    $mctxt add command -label $nag -command "::tree::mask::setNag [list $move $nag]"
  }
  $mctxt add separator
  $mctxt add command -label "Comment move" -command "::tree::mask::addComment $move"
  $mctxt add command -label "Comment position" -command "::tree::mask::addComment"
  # $mctxt add separator
  # $mctxt add command -label "Move at top" -command "::tree::mask::move $move top"
  
  $mctxt post [winfo pointerx .] [winfo pointery .]
  grab $mctxt
}
################################################################################
#
################################################################################
proc ::tree::mask::addToMask { move {fen ""} } {
  global ::tree::mask::mask
  
  if {$fen == ""} {
    set fen [ toShortFen [sc_pos fen] ]
  }
  set idx [ lsearch -sorted -regexp $mask "$fen *" ]
  if {$idx == -1} {
    lappend mask [ list $fen {} {} ]
  }
  
  set idx [ lsearch -sorted -regexp $mask "$fen *" ]
  
  set pos [ lindex $mask $idx ]
  set moves [ lindex $pos 1 ]
  if {[lsearch $moves $move] == -1} {
    lappend moves [list $move {} $::tree::mask::defaultColor {}]
    set newpos [lreplace $pos 1 1 $moves]
    set mask [ lreplace $mask $idx $idx $newpos ]
    ::tree::refresh
  }
  set mask [ lsort -index 0 $mask ]
}
################################################################################
#
################################################################################
proc ::tree::mask::removeFromMask { move {fen ""} } {
  global ::tree::mask::mask
  
  if {$fen == ""} {
    set fen [ toShortFen [sc_pos fen] ]
  }
  
  set idx [ lsearch -sorted -regexp $mask "$fen *" ]
  if {$idx == -1} {
    return
  }
  
  set pos [ lindex $mask $idx ]
  set moves [ lindex $pos 1 ]
  set idxm [lsearch -regexp $moves "^$move *"]
  if { $idxm != -1} {
    set moves [lreplace $moves $idxm $idxm]
    lset pos 1 $moves
    lset mask $idx $pos
    ::tree::refresh
  }
  
}
################################################################################
# returns 1 if the move is already in mask
################################################################################
proc ::tree::mask::moveExists { move {fen ""} } {
  global ::tree::mask::mask
  
  if {$fen == ""} {
    set fen [ toShortFen [sc_pos fen] ]
  }
  
  set idx [ lsearch -sorted -regexp $mask "$fen *" ]
  if {$idx == -1} {
    return 0
  }
  set pos [ lindex $mask $idx ]
  set moves [ lindex $pos 1 ]
  if {[lsearch -regexp $moves "^$move *"] == -1} {
    return 0
  }
  return 1
}
################################################################################
# return the list of moves with their data
################################################################################
proc ::tree::mask::getAllMoves {} {
  global ::tree::mask::mask
  
  set fen [ toShortFen [sc_pos fen] ]
  
  set idx [ lsearch -sorted -regexp $mask "$fen *" ]
  if {$idx == -1} {
    return ""
  }
  set pos [ lindex $mask $idx ]
  set moves [ lindex $pos 1 ]
  return $moves
}
################################################################################
#
################################################################################
proc ::tree::mask::getColor { move {fen ""}} {
  global ::tree::mask::mask
  if {$fen == ""} {
    set fen [ toShortFen [sc_pos fen] ]
  }
  
  set idx [ lsearch -sorted -regexp $mask "$fen *" ]
  if {$idx == -1} {
    return $::tree::mask::defaultColor
  }
  set pos [ lindex $mask $idx ]
  set moves [ lindex $pos 1 ]
  set idxm [lsearch -regexp $moves "^$move *"]
  if { $idxm == -1} {
    return $::tree::mask::defaultColor
  }
  set col [ lindex $moves $idxm 2 ]
  
  return $col
}
################################################################################
#
################################################################################
proc ::tree::mask::setColor { move color {fen ""}} {
  global ::tree::mask::mask
  
  if {$fen == ""} {
    set fen [ toShortFen [sc_pos fen] ]
  }
  
  set idx [ lsearch -sorted -regexp $mask "$fen *" ]
  if {$idx == -1} {
    tk_messageBox -title "Scid" -type ok -icon warning -message "Add move to mask first"
    return
  }
  set pos [ lindex $mask $idx ]
  set moves [ lindex $pos 1 ]
  set idxm [lsearch -regexp $moves "^$move *"]
  if { $idxm == -1} {
    tk_messageBox -title "Scid" -type ok -icon warning -message "Add move to mask first"
    return
  }
  set newmove [lreplace [lindex $moves $idxm] 2 2 $color ]
  set moves [lreplace $moves $idxm $idxm $newmove ]
  set newpos [ lreplace $pos 1 1 $moves ]
  set mask [ lreplace $mask $idx $idx $newpos ]
  ::tree::refresh
}
################################################################################
# defaults to "  " (2 spaces)
################################################################################
proc ::tree::mask::getNag { move { fen "" }} {
  global ::tree::mask::mask ::tree::mask::emptyNag
  
  if {$fen == ""} {
    set fen [ toShortFen [sc_pos fen] ]
  }
  
  set idx [ lsearch -sorted -regexp $mask "$fen *" ]
  if {$idx == -1} {
    return $emptyNag
  }
  set pos [ lindex $mask $idx ]
  set moves [ lindex $pos 1 ]
  set idxm [lsearch -regexp $moves "^$move *"]
  if { $idxm == -1} {
    return $emptyNag
  }
  set nag [ lindex $moves $idxm 1 ]
  if {$nag == ""} {
    set nag $emptyNag
  }
  if { [string length $nag] == 1} { set nag " $nag" }
  return $nag
}
################################################################################
#
################################################################################
proc ::tree::mask::setNag { move nag {fen ""} } {
  global ::tree::mask::mask
  
  if {$fen == ""} {
    set fen [ toShortFen [sc_pos fen] ]
  }
  
  set idx [ lsearch -sorted -regexp $mask "$fen *" ]
  if {$idx == -1} {
    tk_messageBox -title "Scid" -type ok -icon warning -message "Add move to mask first"
    return
  }
  set pos [ lindex $mask $idx ]
  set moves [ lindex $pos 1 ]
  set idxm [lsearch -regexp $moves "^$move *"]
  if { $idxm == -1} {
    tk_messageBox -title "Scid" -type ok -icon warning -message "Add move to mask first"
    return
  }
  set newmove [lreplace [lindex $moves $idxm] 1 1 $nag ]
  set moves [lreplace $moves $idxm $idxm $newmove ]
  set newpos [ lreplace $pos 1 1 $moves ]
  set mask [ lreplace $mask $idx $idx $newpos ]
  ::tree::refresh
}
################################################################################
#
################################################################################
proc ::tree::mask::getComment { move { fen "" } } {
  global ::tree::mask::mask
  
  if {$fen == ""} {
    set fen [ toShortFen [sc_pos fen] ]
  }
  
  set idx [ lsearch -sorted -regexp $mask "$fen *" ]
  if {$idx == -1} {
    return ""
  }
  set pos [ lindex $mask $idx ]
  set moves [ lindex $pos 1 ]
  set idxm [lsearch -regexp $moves "^$move *"]
  if { $idxm == -1} {
    return ""
  }
  set comment [ lindex $moves $idxm 3 ]
  if {$comment == ""} {
    set comment "  "
  }
  return $comment
}
################################################################################
#
################################################################################
proc ::tree::mask::setComment { move comment { fen "" } } {
  global ::tree::mask::mask
  
  if {$fen == ""} {
    set fen [ toShortFen [sc_pos fen] ]
  }
  
  set idx [ lsearch -sorted -regexp $mask "$fen *" ]
  if {$idx == -1} {
    tk_messageBox -title "Scid" -type ok -icon warning -message "Add move to mask first"
    return
  }
  set pos [ lindex $mask $idx ]
  set moves [ lindex $pos 1 ]
  set idxm [lsearch -regexp $moves "^$move *"]
  if { $idxm == -1} {
    tk_messageBox -title "Scid" -type ok -icon warning -message "Add move to mask first"
    return
  }
  set newmove [lreplace [lindex $moves $idxm] 3 3 $comment ]
  set moves [lreplace $moves $idxm $idxm $newmove ]
  set newpos [ lreplace $pos 1 1 $moves ]
  set mask [ lreplace $mask $idx $idx $newpos ]
  ::tree::refresh
}
################################################################################
#
################################################################################
proc ::tree::mask::getPositionComment {{fen ""}} {
  global ::tree::mask::mask
  
  if {$fen == ""} {
    set fen [ toShortFen [sc_pos fen] ]
  }
  
  set idx [ lsearch -sorted -regexp $mask "$fen *" ]
  if {$idx == -1} {
    return ""
  }
  set pos [ lindex $mask $idx ]
  set comment [ lindex $pos 2 ]
  return $comment
}
################################################################################
#
################################################################################
proc ::tree::mask::setPositionComment { comment {fen ""} } {
  global ::tree::mask::mask
  
  if {$fen == ""} {
    set fen [ toShortFen [sc_pos fen] ]
  }
  
  set idx [ lsearch -sorted -regexp $mask "$fen *" ]
  if {$idx == -1} {
    tk_messageBox -title "Scid" -type ok -icon warning -message "Add move to mask first"
    return
  }
  
  set pos [ lindex $mask $idx ]
  set newpos [ lreplace $pos 2 2 $comment ]
  set mask [ lreplace $mask $idx $idx $newpos ]
  ::tree::refresh
}
################################################################################
# if move is null, this is a position comment
################################################################################
proc ::tree::mask::addComment { { move "" } } {
  set w .treeMaskAddComment
  toplevel .treeMaskAddComment
  if {$move == ""} {
    set oldComment [::tree::mask::getPositionComment]
  } else  {
    set oldComment [::tree::mask::getComment $move ]
  }
  set oldComment [ string trim $oldComment ]
  # entry $w.e -width 40
  autoscrollframe $w.f text $w.f.e -width 40 -height 5 -wrap none -setgrid 1
  $w.f.e insert end $oldComment
  button $w.ok -text OK -command "::tree::mask::updateComment $move ; destroy $w ; ::tree::refresh"
  pack $w.f $w.ok
}
################################################################################
#
################################################################################
proc ::tree::mask::updateComment { { move "" } } {
  set e .treeMaskAddComment.f.e
  set newComment [$e get 1.0 end]
  if {$move == ""} {
    ::tree::mask::setPositionComment $newComment
  } else  {
    ::tree::mask::setComment $move $newComment
  }
}

################################################################################
#
################################################################################
proc ::tree::mask::fillWithGame {} {
  if {$::tree::mask::maskFile == ""} {
    tk_messageBox -title "Scid" -type ok -icon warning -message "Open a mask file first"
    return
  }
  ::tree::primeWithGame 1
}
################################################################################
#
################################################################################
proc ::tree::mask::fillWithBase {} {
  if {$::tree::mask::maskFile == ""} {
    tk_messageBox -title "Scid" -type ok -icon warning -message "Open a mask file first"
    return
  }
  ::tree::primeWithBase 1
}
################################################################################
# Take current position information and fill the mask (move, nag, comments, etc)
################################################################################
proc ::tree::mask::feedMask { fen } {
  set stdNags { "!!" "!" "!?" "?!" "??" "~"}
  set fen [toShortFen $fen]
  set move [sc_game info previousMoveNT]
  set comment [sc_pos getComment $fen ]
  
  if {$move == ""} {
    set move "null"
  }
  
  # add move if not in mask
  if { ![moveExists $move $fen]} {
    addToMask $move $fen
  }
  
  if {$move == "null"} {
    set comment "$comment [getPositionComment]"
    setPositionComment $comment $fen
    return
  }
  
  # NAG
  set nag [string trim [sc_pos getNags]]
  if {$nag == 0} { set nag "" }
  if {$nag != ""} {
    # append the NAGs to comment if not standard
    if {[lsearch $stdNags $nag ] == -1 } {
      set comment "$nag $comment"
      set nag ""
    } else  {
      set oldNag [getNag $move]
      if {$oldNag != $::tree::mask::emptyNag && $oldNag != $nag} {
        set comment "<$oldNag>(?!?) $comment"
      }
      setNag $move $nag $fen
    }
  }
  
  # append comment
  set oldComment [getComment $move $fen]
  if { $oldComment != "" && $oldComment != $comment } {
    set comment "$comment $oldComment"
  }
  setComment $move $comment $fen
  
}
################################################################################
#  trim the fen to keep position data only
################################################################################
proc ::tree::mask::toShortFen {fen} {
  set ret [lreplace $fen end-1 end]
  return $ret
}
################################################################################
#
################################################################################
