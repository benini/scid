### reper.tcl:
### Repertoire editor functions for Scid.
### Copyright (C) 2001-2002 Shane Hudson.

# The heirarchical view used to display a repertoire in Scid was
# originally based on the  public domain Tcl/Tk tree widget written by
# D. Richard Hipp (available at: http://www.hwaci.com/sw/tk/tree.html)
# but the Scid code is completely rewritten and significantly improved.

namespace eval ::rep {}
array set ::rep::_data {}
set ::rep::Win 0

# ::rep::create
#   Create a new repertoire widget.  $args become the configuration
#   arguments to the canvas widget that is created.
#
proc ::rep::create {w args} {
  eval canvas $w -bg white -width 1 $args
  bind $w <Destroy> "catch {::rep::clear $w}"
  ::rep::_defaults $w /
  ::rep::_drawWhenIdle $w
  set ::rep::_data($w:selection) {}
  set ::rep::_data($w:selidx) {}
  set ::rep::_data($w:altered) 0
  set ::rep::_data($w:nlines) 0
  set ::rep::_data($w:ngroups) 0
  set ::rep::_data($w:filename) ""
  #set ::rep::_data($w:readonly) 0
}

# ::rep::_defaults
#   Used to initialize a new element of the tree.
#
proc ::rep::_defaults {w v} {
  set ::rep::_data($w:$v:children) {}
  set ::rep::_data($w:$v:shown) 1
  set ::rep::_data($w:$v:tags) {}
  set ::rep::_data($w:$v:comment) {}
  set ::rep::_data($w:$v:text) {}
  set ::rep::_data($w:$v:group) 0
  set ::rep::_data($w:$v:include) 1
}

# ::rep::_findGroup
#   Finds the parent group of a line or group that will be added.
#
proc ::rep::_findGroup {w v parent} {
  set p $parent
  if {$parent == ""} { set p "/" }
  foreach g $::rep::_data($w:$p:children) {
    set len [string length $g]
    set v2 [string range $v 0 [expr {$len - 1} ]]
    
    # If the next character in the line is a "-", it means we have a
    # situation with both the castling moves "O-O" and "O-O-O".
    # To avoid "O-O-O" looking like a child line of "O-O", we need to
    # deliberately ignore this possibility.
    if {[string length $v] > $len  &&  [string index $v $len] == "-"} { continue }
    
    regsub -all " " $v2 "," v2
    if {! [string compare $v2 $g]} {
      set v [string trim [string range $v $len end]]
      return [::rep::_findGroup $w $v $parent/$g]
    }
  }
  set v [string trim $v]
  regsub -all " " $v "," v
  return $parent/$v
}

# ::rep::AddCurrentBoard
#   Adds the line representing the current board position as a
#   group, included line or excluded line.
#
proc ::rep::AddCurrentBoard {w type} {
  switch -exact -- $type {
    group   { set grp 1; set inc 0; set cmd ::rep::newGroup }
    include { set grp 0; set inc 1; set cmd ::rep::newLine  }
    exclude { set grp 0; set inc 0; set cmd ::rep::newLine  }
    default { return }
  }
  # Verify that the current game began at the standard starting position:
  if {[sc_game startBoard]} {
    tk_messageBox -parent $w -type ok -icon info -title "Scid" \
        -message "The current game does not have the standard starting position, so its positions cannot be added to the repertoire."
    return
  }
  set moves [string trim [sc_game moves]]
  set err [catch {$cmd $w $moves -group $grp -include $inc} res]
  if {$err} {
    tk_messageBox -parent $w -type ok -icon info -title "Scid" -message $res
    return
  }
  ::rep::regroup $w
  ::rep::singleClick $w $res
}

# ::rep::newGroup
#   Adds a new group to the repertoire.
#
proc ::rep::newGroup {w v args} {
  if {$v == ""} {
    return -code error "The starting chess position cannot be a group."
  }
  set s [::rep::_findGroup $w $v ""]
  lappend args -group 1
  return [::rep::_newItem $w $s $args]
}

# ::rep::newLine
#   Adds a new group to the repertoire.
#
proc ::rep::newLine {w v args} {
  set s [::rep::_findGroup $w $v ""]
  lappend args -group 0
  return [::rep::_newItem $w "${s} ,LINE" $args]
}

# ::rep::_decode
#   Decodes a group or line path back to standard chess notation,
#   e.g. "/1.e4_c5/2.Nf3_d6" -> "1.e4 c5 2.Nf3 d6"
#
proc ::rep::_decode {m} {
  regsub -all "," $m " " moves
  regsub -all "/" $moves " " moves
  regsub "LINE" $moves "" moves
  set moves [string trim $moves]
  return $moves
}

# ::rep::_newItem
#   Called from newGroup or newLine to add a new element to the repertoire.
#
proc ::rep::_newItem {w v args} {
  regsub -all " " $v "," v
  set dir [file dirname $v]
  set n [file tail $v]
  if {[llength $args] == 1} {
    set args [lindex $args 0]
  }
  set image {}
  set tags {}
  set text {}
  set comment {}
  set group 0
  set include 1
  set shown 1
  
  foreach {op arg} $args {
    switch -exact -- $op {
      -image {set image $arg}
      -tags {set tags $arg}
      -text {set text $arg}
      -comment {set comment $arg}
      -group {set group $arg}
      -include {set include $arg}
      -shown {set shown $arg}
    }
  }
  if {![info exists ::rep::_data($w:$dir:shown)]} {
    return -code error "parent item \"$dir\" is missing"
  }
  set i [lsearch -exact $::rep::_data($w:$dir:children) $n]
  if {$i >= 0} {
    # Group or line already exists.
    if {! $group} {
      set ::rep::_data($w:$v:include) $include
      ::rep::updateStatus $w
    }
    return $v
    #set  type "line"
    #if {$group} { set type "group" }
    #return -code error "The $type \"[::rep::_decode $v]\" already exists in this repertoire."
  }
  if {$group} {
    incr ::rep::_data($w:ngroups)
  } else {
    incr ::rep::_data($w:nlines)
  }
  
  lappend ::rep::_data($w:$dir:children) $n
  set ::rep::_data($w:$dir:children) [lsort $::rep::_data($w:$dir:children)]
  ::rep::_defaults $w $v
  set ::rep::_data($w:$v:comment) $comment
  set ::rep::_data($w:$v:image) $image
  set ::rep::_data($w:$v:tags) $tags
  set ::rep::_data($w:$v:text) $text
  set ::rep::_data($w:$v:group) $group
  set ::rep::_data($w:$v:include) $include
  set ::rep::_data($w:$v:shown) $shown
  set ::rep::_data($w:altered) 1
  ::rep::updateStatus $w
  # ::rep::_drawWhenIdle $w
  return $v
}

# ::rep::updateStatus
#   Updates the status bar message for the repertoire window.
#
proc ::rep::updateStatus {w} {
  set s "  "
  if {$::rep::_data($w:altered)} { append s "XX" } else { append s "--" }
  append s "  "
  set f $::rep::_data($w:filename)
  if {$f == ""} {
    set f "(Untitled)"
  } else {
    set f [file tail $f]
  }
  append s "$f: $::rep::_data($w:nlines) lines"
  append s " in $::rep::_data($w:ngroups) groups"
  set ::rep::_data($w:status) $s
}

# ::rep::updateWinTitle
#   Updates the repertoire window title.
#
proc ::rep::updateWinTitle {w} {
  set f $::rep::_data($w:filename)
  if {$f == ""} {
    set f "(Untitled)"
  } else {
    set f [file tail $f]
  }
  wm title [winfo toplevel $w] "Scid: [tr WindowsRepertoire]: $f"
}

# ::rep::regroup
#   Calls ::rep::_extract to produce a set of commands for rebuilding
#   the repertoire heirarchy, then clears and rebuilds it.
#   Used to reorganise the repertoire whenever a group is added or
#   removed.
proc ::rep::regroup {w} {
  set list [::rep::_extract $w / {}]
  ::rep::clear $w
  foreach i $list {eval $i}
  ::rep::_drawWhenIdle $w
}

# ::rep::newFile
#   Clears the repertoire and reset the filename to be untitled.
#
proc ::rep::newFile {w} {
  ::rep::clear $w
  set ::rep::_data($w:filename) ""
  #set ::rep::_data($w:readonly) 0
  ::rep::updateWinTitle $w
  ::rep::_drawWhenIdle $w
}

# ::rep::clear
#   Clears the repertoire, but keeps its filename.
#
proc ::rep::clear {w} {
  set fname ""
  set fname $::rep::_data($w:filename)
  foreach t [array names ::rep::_data $w:*] {
    unset ::rep::_data($t)
  }
  set ::rep::_data($w:filename) $fname
  set ::rep::_data($w:selection) {}
  set ::rep::_data($w:selidx) {}
  set ::rep::_data($w:altered) 0
  set ::rep::_data($w:nlines) 0
  set ::rep::_data($w:ngroups) 0
  ::rep::_defaults $w /
}

# ::rep::deleteGroup
#   After verification from the user, this deletes the specified
#   group but keeps all subgroups and lines.
#
proc ::rep::deleteGroup {w v} {
  if {! [info exists ::rep::_data($w:$v:group)]} { return }
  if {! $::rep::_data($w:$v:group)} { return }
  set v2 [::rep::_decode $v]
  set msg "The group \"$v2\" contains [::rep::_numChildLines $w $v] lines "
  append msg "in [expr [::rep::_numChildGroups $w $v] - 1] subgroups.\n\n"
  append msg "Are you sure you want to delete this group, keeping all the groups and lines under it?"
  set answer [tk_messageBox -parent $w -title "Scid: Delete group?" \
      -type yesno -icon question -message $msg]
  if {$answer != "yes"} { return }
  set ::rep::_data($w:$v:delete) 1
  ::rep::regroup $w
}

# ::rep::pruneGroup
#   After verification from the user, this deletes the specified
#   group AND all its subgroups and lines.
#
proc ::rep::pruneGroup {w v} {
  if {! [info exists ::rep::_data($w:$v:group)]} { return }
  if {! $::rep::_data($w:$v:group)} { return }
  set v2 [::rep::_decode $v]
  set msg "The group \"$v2\" contains [::rep::_numChildLines $w $v] lines "
  append msg "in [expr [::rep::_numChildGroups $w $v] - 1] subgroups.\n\n"
  append msg "Are you sure you want to delete this group AND ALL the groups and lines under it?"
  set answer [tk_messageBox -parent $w -title "Scid: Delete group?" \
      -type yesno -icon question -message $msg]
  if {$answer != "yes"} { return }
  set ::rep::_data($w:$v:delete) 1
  set ::rep::_data($w:$v:prune) 1
  ::rep::regroup $w
}

# ::rep::deleteGroup
#   After verification from the user, this deletes the specified line.
#
proc ::rep::deleteLine {w v} {
  if {! [info exists ::rep::_data($w:$v:group)]} { return }
  if {$::rep::_data($w:$v:group)} { return }
  set v2 [::rep::_decode $v]
  set msg "Delete: $v2\n\n"
  append msg "Are you sure you want to delete this line?"
  set answer [tk_messageBox -parent $w -title "Scid: Delete line?" \
      -type yesno -icon question -message $msg]
  if {$answer != "yes"} { return }
  set ::rep::_data($w:$v:delete) 1
  ::rep::regroup $w
}

# ::rep::showAll
#   Expands the specified group and all its subgroups.
#
proc ::rep::showAll {w {v ""}} {
  foreach i [array names ::rep::_data $w:$v*:shown] {
    set ::rep::_data($i) 1
  }
  ::rep::_drawWhenIdle $w
}

# ::rep::hideAll
#   Collapses the specified group and all its subgroups.
#
proc ::rep::hideAll {w {v ""}} {
  foreach i [array names ::rep::_data $w:$v*:shown] {
    set ::rep::_data($i) 0
  }
  ::rep::_drawWhenIdle $w
}

# ::rep::setSelection
#   Changes the selection to the specified group or line.
#
proc ::rep::setSelection {w v} {
  set ::rep::_data($w:selection) $v
  ::rep::_drawSelection $w
  ::rep::updateStatus $w
}

# ::rep::getSelection
#   Retrieves the current selection.
#
proc ::rep::getSelection {w} {
  return $::rep::_data($w:selection)
}

# ::rep::_numChildGroups
#   Returns the number of (direct and indirect) subgroups of a group.
#
proc ::rep::_numChildGroups {w v} {
  if {! $::rep::_data($w:$v:group)} { return 0 }
  set count 1
  if {[info exists ::rep::_data($w:$v:children)]} {
    foreach child $::rep::_data($w:$v:children) {
      incr count [::rep::_numChildGroups $w $v/$child]
    }
  }
  return $count
}


# ::rep::_numChildLines
#   Returns the number of (direct and indirect) child lines of a group.
#
proc ::rep::_numChildLines {w v} {
  if {! $::rep::_data($w:$v:group)} { return 1 }
  set count 0
  if {[info exists ::rep::_data($w:$v:children)]} {
    foreach child $::rep::_data($w:$v:children) {
      incr count [::rep::_numChildLines $w $v/$child]
    }
  }
  return $count
}

# ::rep::_draw
#   Draws the repertoire heirarchy.
#
proc ::rep::_draw {w} {
  catch {unset ::rep::_data($w:drawPending)}
  $w delete all
  set ::rep::_data($w:y) 30
  ::rep::_drawLevel $w "/" 10
  $w config -scrollregion [$w bbox all]
  ::rep::_drawSelection $w
  ::rep::updateStatus $w
  $w xview moveto 0.0
}

# ::rep::_drawLevel
#   Draws a single level of the heirarchy, indented by $in pixels.
#
proc ::rep::_drawLevel {w v in} {
  set p $v
  if {$v == "/"} { set p "" }
  set start [expr {$::rep::_data($w:y)-10} ]
  set y 0
  if {[llength $::rep::_data($w:$v:children)] == 0} {
    set y $::rep::_data($w:y)
    incr ::rep::_data($w:y) 17
    $w create line $in $y [expr {$in+10} ] $y -fill gray50
    incr in 12
    $w create text $in $y -font font_Small -anchor w -text "(empty)"
    return
  }
  
  foreach c $::rep::_data($w:$v:children) {
    set y $::rep::_data($w:y)
    incr ::rep::_data($w:y) 17
    $w create line $in $y [expr {$in + 10} ] $y -fill gray50
    set group $::rep::_data($w:$p/$c:group)
    set icon $::rep::_data($w:$p/$c:image)
    set taglist x
    foreach tag $::rep::_data($w:$p/$c:tags) { lappend taglist $tag }
    if {$group} {
      set icon ::rep::_closedgroup
      if {$::rep::_data($w:$p/$c:shown)} { set icon ::rep::_opengroup }
    } else {
      set icon ::rep::_cross
      if {$::rep::_data($w:$p/$c:include)} { set icon ::rep::_tick }
    }
    set x [expr {$in + 12} ]
    
    if {$icon != ""} {
      set tag [$w create image $x $y -image $icon -anchor w -tags $taglist]
      incr x 20
      set ::rep::_data($w:tag:$tag) $p/$c
      if {$group} {
        set s [expr {1 - $::rep::_data($w:$p/$c:shown)} ]
        $w bind $tag <1> "set ::rep::_data($w:$p/$c:shown) $s; ::rep::_draw $w"
      }
      $w bind $tag <$::MB3> "::rep::_popupMenu $w $p/$c %X %Y"
    }
    set moves [::rep::_decode $c]
    if {$moves == ""} { set moves "..." }
    if {$group} {
      append moves " ([::rep::_numChildLines $w $p/$c])"
    }
    set tag [$w create text $x $y -text $moves -font font_Small \
        -anchor w -tags $taglist]
    set ::rep::_data($w:tag:$tag) $p/$c
    set ::rep::_data($w:$p/$c:tag) $tag
    $w bind $tag <$::MB3> "::rep::_popupMenu $w $p/$c %X %Y"
    set comment ""
    if {[string length $::rep::_data($w:$p/$c:text)] > 0} {
      set comment "** "
    }
    if {[string length $::rep::_data($w:$p/$c:comment)] > 0} {
      append comment "$::rep::_data($w:$p/$c:comment)"
    }
    if {$comment != ""} {
      incr x [expr {3 + [lindex [$w bbox $tag] 2] - [lindex [$w bbox $tag] 0]} ]
      set tag [$w create text $x $y -text $comment -font font_Small \
          -fill red3 -anchor w -tags $taglist]
      $w bind $tag <$::MB3> "::rep::_popupMenu $w $p/$c %X %Y"
      set ::rep::_data($w:tag:$tag) $p/$c
    }
    
    if {[llength $::rep::_data($w:$p/$c:children)] > 0} {
      if {$::rep::_data($w:$p/$c:shown)} {
        set tag [$w create image $in $y -image ::rep::_shown]
        $w bind $tag <1> "set ::rep::_data($w:$p/$c:shown) 0; ::rep::_draw $w"
        ::rep::_drawLevel $w $p/$c [expr {$in + 18} ]
      } else {
        set tag [$w create image $in $y -image ::rep::_hidden]
        $w bind $tag <1> "set ::rep::_data($w:$p/$c:shown) 1; ::rep::_draw $w"
      }
      $w bind $tag <$::MB3> "::rep::_popupMenu $w $p/$c %X %Y"
    }
  }
  set tag [$w create line $in $start $in [expr {$y+1} ] -fill gray50 ]
  $w lower $tag
}

# ::rep::showGroup
#   Expand a single group.
#
proc ::rep::showGroup {w v} {
  if {[info exists ::rep::_data($w:$v:shown)]
    &&  $::rep::_data($w:$v:shown) == 0
    &&  [info exists ::rep::_data($w:$v:children)]
    &&  [llength $::rep::_data($w:$v:children)] > 0} {
    set ::rep::_data($w:$v:shown) 1
    ::rep::_draw $w
  }
}

# ::rep::showGroup
#   Collapse a single group.
#
proc ::rep::hideGroup {w v} {
  if {[info exists ::rep::_data($w:$v:shown)]
    &&  $::rep::_data($w:$v:shown) == 1} {
    set ::rep::_data($w:$v:shown) 0
    ::rep::_draw $w
  }
}

# ::rep::toggleLineState
#   Change the state of a line (included vs excluded).
#
proc ::rep::toggleLineState {w v} {
  if {[info exists ::rep::_data($w:$v:group)]
    &&  $::rep::_data($w:$v:group) == 0} {
    set state $::rep::_data($w:$v:include)
    set state [expr {1 - $state} ]
    set ::rep::_data($w:$v:include) $state
    set ::rep::_data($w:altered) 1
    ::rep::_draw $w
  }
}

# ::rep::_drawSelection
#   Highlight the selected goupr or line.
#
proc ::rep::_drawSelection w {
  if {[string length $::rep::_data($w:selidx)]} {
    $w delete $::rep::_data($w:selidx)
  }
  set v $::rep::_data($w:selection)
  if {[string length $v]==0} { return }
  if {![info exists ::rep::_data($w:$v:tag)]} { return }
  set bbox [$w bbox $::rep::_data($w:$v:tag)]
  if {[llength $bbox]==4} {
    set i [eval $w create rectangle $bbox -fill yellow2 -outline {{}}]
    set ::rep::_data($w:selidx) $i
    $w lower $i
  } else {
    set ::rep::_data($w:selidx) {}
  }
}

# ::rep::_drawWhenIdle
#   Schedule a redraw event of the repertoire heirarchy.
#
proc ::rep::_drawWhenIdle w {
  if {![info exists ::rep::_data($w:drawPending)]} {
    set ::rep::_data($w:drawPending) 1
    after idle "::rep::_draw $w"
  }
}

# ::rep::labelAtXY
#   Return the group or line in the repertoire located at the
#   real coordinates ($x,$y).
#
proc ::rep::labelAtXY {w x y} {
  set x [$w canvasx $x]
  set y [$w canvasy $y]
  foreach m [$w find overlapping $x $y $x $y] {
    if {[info exists ::rep::_data($w:tag:$m)]} {
      return $::rep::_data($w:tag:$m)
    }
  }
  return ""
}

# ::rep::OpenCloseWindow
#   Open/close the repertoire editor.
#
proc ::rep::OpenCloseWindow {} {
  set w .repWin

  set DeprecatedTxt "The repertoir editor is deprecated and may be removed in a future version of Scid.\n\nWe feel, that Tree Masks offer much better functionality and versality and strongly encourage transition to them.\nIf you feel Masks can not cover all functions of the repertoir editor and you would like to have it kept, please subscribe to\n\nscid-users@lists.sourceforge.net\n\nfor an open discussion.\n\nDo you want to learn more about Masks?"


  if {[winfo exists $w]} {
    destroy $w
    return
  }
  set result [tk_dialog .roDialog "Scid: Function Deprecated" \
				$DeprecatedTxt "" 1 $::tr(No) $::tr(Yes)]

  if {$result ==0} {
     ::rep::makeWindow
  } else {
	  helpWindow TreeMasks
  }
}

# ::rep::closeWindow
#   Close the repertoire editor.
#
proc ::rep::closeWindow {} {
  set w .repWin
  if {! [winfo exists $w]} { return }
  if {$::rep::_data($w.f.w.rep:altered)} {
    set answer [tk_messageBox -parent .repWin \
        -type yesno -icon question \
        -title "Scid: [tr RepFileClose]" \
        -message $::tr(RepCloseDialog)]
    if {$answer != "yes"} { return }
  }
  destroy $w
  set ::rep::Win 0
}

# ::rep::OpenWithFile
#   Open the repertoire editor and losd the specified file.
#
proc ::rep::OpenWithFile {fname} {
  ::rep::makeWindow
  ::rep::readFile .repWin.f.w.rep $fname
}

# ::rep::ConfigMenus
#   Called to set the window menus to a specified language.
proc ::rep::ConfigMenus {w {lang ""}} {
  if {! [winfo exists $w]} { return }
  if {$lang == ""} { set lang $::language }
  set m $w.menu
  foreach idx {0 1 2 3 4} tag {File Edit View Search Help} {
    configMenuText $m $idx Rep$tag $lang
  }
  foreach idx {0 1 3 4 6} tag {New Open Save SaveAs Close} {
    configMenuText $m.file $idx RepFile$tag $lang
  }
  foreach idx {0 1 2} tag {Group Include Exclude} {
    configMenuText $m.edit $idx RepEdit$tag $lang
  }
  foreach idx {0 1} tag {Expand Collapse} {
    configMenuText $m.view $idx RepView$tag $lang
  }
  foreach idx {0 1} tag {All Displayed} {
    configMenuText $m.search $idx RepSearch$tag $lang
  }
  foreach idx {0 1} tag {Rep Index} {
    configMenuText $m.helpmenu $idx RepHelp$tag $lang
  }
}

# ::rep::makeWindow
#   Create the repertoire editor window.
#
proc ::rep::makeWindow {} {
  set w .repWin
  if {[winfo exists $w]} { return }
  set ::rep::Win 1
  toplevel $w
  
  standardShortcuts $w
  wm protocol $w WM_DELETE_WINDOW ::rep::closeWindow
  
  frame $w.m -bd 1 -relief raised
  pack $w.m -side top -fill x
  menu $w.menu
  $w configure -menu $w.menu
  $w.menu add cascade -label RepFile -menu $w.menu.file
  menu $w.menu.file
  $w.menu.file add command -label RepFileNew -accelerator "Ctrl+N" \
      -command "::rep::newFile $w.f.w.rep"
  bind $w <Control-n> "$w.menu.file invoke 0"
  $w.menu.file add command -label RepFileOpen -accelerator "Ctrl+O" \
      -command "::rep::OpenFile $w.f.w.rep"
  bind $w <Control-o> "$w.menu.file invoke 1"
  $w.menu.file add separator
  $w.menu.file add command -label RepFileSave -accelerator "Ctrl+S" \
      -command "::rep::saveFile $w.f.w.rep"
  bind $w <Control-s> "$w.menu.file invoke 3"
  $w.menu.file add command -label RepFileSaveAs \
      -command "::rep::saveFile $w.f.w.rep new"
  $w.menu.file add separator
  $w.menu.file add command -label RepFileClose -accelerator "Ctrl+Q" \
      -command "destroy $w"
  bind $w <Control-q> "destroy $w"
  
  $w.menu add cascade -label RepEdit -menu $w.menu.edit
  menu $w.menu.edit
  $w.menu.edit add command -label RepEditGroup -accelerator "Ctrl+G" \
      -command "::rep::AddCurrentBoard $w.f.w.rep group"
  bind $w <Control-g> "$w.menu.edit invoke 0"
  $w.menu.edit add command -label RepEditInclude -accelerator "Ctrl+I" \
      -command "::rep::AddCurrentBoard $w.f.w.rep include"
  bind $w <Control-i> "$w.menu.edit invoke 1"
  $w.menu.edit add command -label RepEditExclude -accelerator "Ctrl+X" \
      -command "::rep::AddCurrentBoard $w.f.w.rep exclude"
  bind $w <Control-x> "$w.menu.edit invoke 2"
  
  $w.menu add cascade -label RepView -menu $w.menu.view
  menu $w.menu.view
  $w.menu.view add command -label RepViewExpand \
      -command "::rep::showAll $w.f.w.rep"
  $w.menu.view add command -label RepViewCollapse \
      -command "::rep::hideAll $w.f.w.rep"
  
  $w.menu add cascade -label RepSearch -menu $w.menu.search
  menu $w.menu.search
  $w.menu.search add command -label RepSearchAll \
      -command "::rep::search $w.f.w.rep all"
  $w.menu.search add command -label RepSearchDisplayed \
      -command "::rep::search $w.f.w.rep displayed"
  
  $w.menu add cascade -label RepHelp -menu $w.menu.helpmenu
  menu $w.menu.helpmenu
  $w.menu.helpmenu add command -label RepHelpRep -command {helpWindow Repertoire}
  $w.menu.helpmenu add command -label RepHelpIndex -command {helpWindow Index}
  
  
  # Toolbar:
  set f [frame $w.toolbar -relief raised -border 1]
  pack $f -side top -fill x
  button $f.new -image tb_new -command "::rep::newFile $w.f.w.rep"
  button $f.open -image tb_open -command "::rep::OpenFile $w.f.w.rep"
  button $f.save -image tb_save -command "::rep::saveFile $w.f.w.rep"
  button $f.close -image tb_close -command "destroy $w"
  frame $f.space1 -width 12
  button $f.group -image ::rep::_tb_group \
      -command "::rep::AddCurrentBoard $w.f.w.rep group"
  button $f.include -image ::rep::_tb_include \
      -command "::rep::AddCurrentBoard $w.f.w.rep include"
  button $f.exclude -image ::rep::_tb_exclude \
      -command "::rep::AddCurrentBoard $w.f.w.rep exclude"
  
  foreach i {new open save close group include exclude} {
    $f.$i configure -relief flat -border 1 -highlightthickness 0 -anchor n \
        -takefocus 0
    bind $f.$i <Any-Enter> "+$f.$i configure -relief groove"
    bind $f.$i <Any-Leave> "+$f.$i configure -relief flat"
  }
  foreach {b m} {
    new RepFileNew open RepFileOpen save RepFileSave
    group RepEditGroup include RepEditInclude exclude RepEditExclude
  } {
    set ::helpMessage($f.$b) [tr $m]
  }
  pack $f.new $f.open $f.save $f.close $f.space1 \
      $f.group $f.include $f.exclude \
      -side left -padx 0 -ipadx 0 -pady 0 -ipady 0 -expand yes
  
  label $w.status -relief sunken -width 1 -anchor w -font font_Small
  pack $w.status -side bottom -anchor w -fill x -expand yes
  
  set pane [::utils::pane::Create $w.f w text 600 600 0.5 h] ;# 600 300
  ::utils::pane::SetRange $w.f 0.2 0.8
  #::pane::SetDrag $w.f 0
  pack $w.f -fill both -expand 1
  
  ::rep::create $w.f.w.rep -yscrollcommand "$w.f.w.sb set"
  scrollbar $w.f.w.sb -orient vertical -command "$w.f.w.rep yview"
  pack $w.f.w.sb -side right -fill y
  pack $w.f.w.rep -side left -fill both -expand 1 -padx 5 -pady 5
  text $w.f.text.moves -height 3 -fg darkBlue -bg white -font font_Small -state disabled -cursor top_left_arrow -wrap word
  entry $w.f.text.entry -width 1 -fg black -bg white -font font_Small
  text $w.f.text.note -width 40 -height 10 -fg black -bg white -font font_Small
  pack $w.f.text.moves -side top -fill x
  pack $w.f.text.entry -side top -fill x
  pack $w.f.text.note -side top -expand 1 -fill both
  $w.status configure -textvar ::rep::_data($w.f.w.rep:status)
  
  bind $w <F1> {helpWindow Repertoire}
  bind $w <Down> "$w.f.w.rep yview scroll +1 units"
  bind $w <Up> "$w.f.w.rep yview scroll -1 units"
  bind $w <Prior> "$w.f.w.rep yview scroll -1 pages"
  bind $w <Next> "$w.f.w.rep yview scroll +1 pages"
  bind $w <Home> "$w.f.w.rep yview moveto 0.0"
  bind $w <End> "$w.f.w.rep yview moveto 0.99"
  $w.f.w.rep xview moveto 0.0
  $w.f.w.rep yview moveto 0.0
  
  $w.f.w.rep bind x <1> \
      "::rep::singleClick $w.f.w.rep \[::rep::labelAtXY %W %x %y\]"
  $w.f.w.rep bind x <Double-Button-1> \
      "::rep::doubleClick $w.f.w.rep \[::rep::labelAtXY %W %x %y\]"
  
  bind $w.f.text.moves <1> "if {\[string length \[$w.f.text.moves get 1.0 end\]\] > 1} { importMoveList \[$w.f.text.moves get 1.0 end\] }"
  
  bind $w.f.text.entry <KeyPress> {
    after idle {
      set label [::rep::getSelection .repWin.f.w.rep]
      if {$label != ""} {
        set ::rep::_data(.repWin.f.w.rep:$label:comment) \
            [string trim [.repWin.f.text.entry get]]
        ::rep::_draw .repWin.f.w.rep
      }
    }
  }
  
  bind $w.f.text.note <KeyPress> {
    after idle {
      set label [::rep::getSelection .repWin.f.w.rep]
      if {$label != ""} {
        set ::rep::_data(.repWin.f.w.rep:$label:text) \
            [string trim [.repWin.f.text.note get 1.0 end]]
      }
    }
  }
  
  ::rep::ConfigMenus $w
  ::rep::updateWinTitle $w.f.w.rep
  wm geometry $w =500x400
}

# ::rep::singleClick
#   Updates the move list label, single-line comment entry widget
#   and multi-line comment text widget in the repertoire editor.
#   Called whenever the left mouse button is clicked on a group or
#   line in the repertoire.
#
proc ::rep::singleClick {w label} {
  ::rep::setSelection $w $label
  if {$label == ""} { return }
  set moves [::rep::_decode $label]
  set win [winfo toplevel $w]
  $win.f.text.moves configure -state normal
  $win.f.text.moves delete 1.0 end
  $win.f.text.moves insert end $moves
  $win.f.text.moves configure -state disabled
  set comment ""
  catch {set comment $::rep::_data($w:$label:comment)}
  $win.f.text.entry delete 0 end
  $win.f.text.entry insert end $comment
  set temptext ""
  catch {set temptext $::rep::_data($w:$label:text)}
  set temptext [string trim $temptext]
  $win.f.text.note delete 1.0 end
  $win.f.text.note insert end $temptext
}

# ::rep::doubleClick
#   Called whenever the left mouse button is double-clicked on a group or
#   line in the repertoire.
#
proc ::rep::doubleClick {w label} {
  ::rep::setSelection $w $label
  if {$label == ""} { return }
  set moves [::rep::_decode $label]
  catch {sc_game import $moves}
  updateBoard -pgn
}

# ::rep::_extract
#   Traverses the repertoire heirarchy, producing a list of
#   commands needed to reconstruct the entire repertoire.
#   If a line or group is marked deleted, it is not included in
#   the list. If a group is marked pruned, its children are not
#   included either.
#
proc ::rep::_extract {w v returnList} {
  set p $v
  if {$v == "/"} { set p "" }
  foreach c $::rep::_data($w:$v:children) {
    set text [string trim $::rep::_data($w:$p/$c:text)]
    set comment [string trim $::rep::_data($w:$p/$c:comment)]
    set moves [::rep::_decode $p/$c]
    
    set recurse 0
    if {$::rep::_data($w:$p/$c:group)} {
      if {! [info exists ::rep::_data($w:$p/$c:prune)]} { set recurse 1 }
      set cmd "::rep::newGroup $w [list $moves]"
      append cmd " -shown $::rep::_data($w:$p/$c:shown)"
    } else {
      set cmd "::rep::newLine $w [list $moves]"
      append cmd " -include $::rep::_data($w:$p/$c:include)"
    }
    append cmd " -comment [list $comment] -text [list $text]"
    if {! [info exists ::rep::_data($w:$p/$c:delete)]} {
      lappend returnList $cmd
    }
    
    if {$recurse  &&  [llength $::rep::_data($w:$p/$c:children)] > 0} {
      set returnList [::rep::_extract $w $p/$c $returnList]
    }
  }
  return $returnList
}

# ::rep::_searchLines
#   Traverses the repertoire heirarchy, producing a list of
#   lines to be searched. If type is "all", all lines in the
#   repertoire will appear. Otherwise, type should be "displayed"
#   and only currently displayed lines will appear.
#   Each include-line returned has "1 " prepended to its moves, and
#   each exclude-line returned has "0 " prepended to its moves.
#
proc ::rep::_searchLines {w type v returnList} {
  set p $v
  if {$v == "/"} { set p "" }
  foreach c $::rep::_data($w:$v:children) {
    set text [string trim $::rep::_data($w:$p/$c:text)]
    set comment [string trim $::rep::_data($w:$p/$c:comment)]
    set moves [::rep::_decode $p/$c]
    
    set recurse 0
    if {$::rep::_data($w:$p/$c:group)} {
      if {$type == "all"  ||  $::rep::_data($w:$p/$c:shown)} {
        set recurse 1
      }
    } else {
      lappend returnList "$::rep::_data($w:$p/$c:include) $moves"
    }
    
    if {$recurse  &&  [llength $::rep::_data($w:$p/$c:children)] > 0} {
      set returnList [::rep::_searchLines $w $type $p/$c $returnList]
    }
  }
  return $returnList
}

# ::rep::readFile
#   Reads the specified repertoire file.
#
proc ::rep::readFile {w fname} {
  #set readonly 0
  #if {[catch {open $fname r+} f]} {
  #  set readonly 1
  #} else {
  #  close $f
  #}
  
  if {[catch {open $fname r} f]} {
    return -code error "Unable to open the file: $fname"
  }
  ::rep::clear $w
  set ::rep::_data($w:altered) 1
  #set ::rep::_data($w:readonly) 1
  set text ""
  set count 0
  set groups {}
  while {1} {
    set line [string trim [gets $f]]
    if {[eof $f]} { break }
    incr count
    set sep [string first ";" $line]
    if {$sep < 0} {
      set moves $line
      set comment ""
    } else {
      set moves [string trim [string range $line 0 [expr {$sep - 1} ]]]
      set comment [string trim [string range $line [expr {$sep + 1} ] end]]
    }
    set c [string index $line 0]
    
    switch -exact -- $c {
      "\#" {
        set line [string trim [string range $line 1 end]]
        append text "$line\n"
      }
      "\[" {
        set group [string trim [string range $moves 1 end]]
        set m [join $groups]
        append m " $group"
        if {[catch {::rep::newGroup $w $m -comment $comment -text $text} err]} {
          return -code error "Error: $fname: line $count: $err"
        }
        lappend groups $group
        set text ""
      }
      "\]" {
        set len [llength $groups]
        if {$len == 0} {
          return -code error "Error: $fname: line $count: extra \"\]\" symbol."
        } elseif {$len == 1} {
          set groups {}
        } else {
          set groups [lrange $groups 0 [expr {$len - 2} ]]
        }
      }
      "-" {
        set m [join $groups]
        append m " "
        append m [string trim [string range $moves 1 end]]
        if {[catch {::rep::newLine $w $m -include 0 -comment $comment -text $text} err]} {
          return -code error "Error: $fname: line $count: $err"
        }
        set text ""
      }
      "+" {
        set m [join $groups]
        append m " "
        append m [string trim [string range $moves 1 end]]
        if {[catch {::rep::newLine $w $m -include 1 -comment $comment -text $text} err]} {
          return -code error "Error: $fname: line $count: $err"
        }
        set text ""
      }
      "" -
      "@" {
        # do nothing
      }
      default {
        return -code error "Error in $fname at line $count: unexpected character: \"$c\""
      }
    }
  }
  close $f
  set ::rep::_data($w:altered) 0
  set ::rep::_data($w:filename) $fname
  ::rep::_drawWhenIdle $w
  ::rep::updateWinTitle $w
  return
}

# ::rep::writeFile
#   Writes the repertoire to the specified file.
#
proc ::rep::writeFile {w fname} {
  if {[catch {open $fname w} f]} {
    return -code error "Unable to open the file \"$fname\""
  }
  puts $f "@ Scid opening repertoire file.  Updated: [::utils::date::today]."
  if {[catch {::rep::_writeFileLevel $w $f "/" 0} err]} {
    return -code error "Error writing the file \"$fname\": $err"
  }
  close $f
  set ::rep::_data($w:altered) 0
  set ::rep::_data($w:filename) $fname
  ::rep::updateStatus $w
  ::rep::updateWinTitle $w
  return
}

# ::rep::_writeFileLevel
#   Writes a single level of the repertoire to the open
#   file channel "f", indented "in" spaces.
#
proc ::rep::_writeFileLevel {w f v in} {
  set p $v
  if {$v == "/"} { set p "" }
  if {[llength $::rep::_data($w:$v:children)] == 0} { return }
  
  foreach c $::rep::_data($w:$v:children) {
    if {$in == 0} { puts $f "" }
    set text [split [string trim $::rep::_data($w:$p/$c:text)] "\n"]
    foreach line $text {
      for {set i 0} {$i < $in} {incr i} { puts -nonewline $f " " }
      puts -nonewline $f "\# "
      puts $f [string trim $line]
    }
    
    for {set i 0} {$i < $in} {incr i} { puts -nonewline $f " " }
    if {$::rep::_data($w:$p/$c:group)} {
      puts -nonewline $f "\[ "
    } else {
      if {$::rep::_data($w:$p/$c:include)} {
        puts -nonewline $f "+ "
      } else {
        puts -nonewline $f "- "
      }
    }
    set moves [::rep::_decode $c]
    if {[string length $::rep::_data($w:$p/$c:comment)] > 0} {
      append moves " ; $::rep::_data($w:$p/$c:comment)"
    }
    puts $f $moves
    if {[llength $::rep::_data($w:$p/$c:children)] > 0} {
      ::rep::_writeFileLevel $w $f $p/$c [expr {$in + 4} ]
    }
    if {$::rep::_data($w:$p/$c:group)} {
      for {set i 0} {$i < $in} {incr i} { puts -nonewline $f " " }
      puts $f "\]"
    }
  }
}

# ::rep::OpenFile
#   Prompts the user to select a repertoire file, and reads it.
#
proc ::rep::OpenFile {w} {
  set ftype { {"Scid repertoire files" {".sor"}} }
  set fname [tk_getOpenFile -filetypes $ftype -title "Open a repertoire file"]
  if {$fname == ""} { return }
  ::rep::readFile $w $fname
}

# ::rep::saveFile
#   Prompts the user to select a repertoire file name if the file is
#   untitled or if the user type is "new", and then writes the file.
#
proc ::rep::saveFile {w {type current}} {
  set fname $::rep::_data($w:filename)
  if {$type == "new"  ||  $fname == ""} {
    set ftype { {"Scid repertoire files" {".sor"}} }
    set fname [tk_getSaveFile -filetypes $ftype -defaultextension ".sor" -title "Create a repertoire file"]
  }
  if {$fname == ""} { return }
  if {[file extension $fname] != ".sor" } {
    append fname ".sor"
  }
  ::rep::writeFile $w $fname
}

# ::rep::_popupMenu
#   Creates and presents a right-mouse-button popup menu for a
#   group or line at the real coordinates ($x,$y).
#
proc ::rep::_popupMenu {w v x y} {
  if {! [info exists ::rep::_data($w:$v:group)]} { return }
  catch {destroy $w.popup}
  set group $::rep::_data($w:$v:group)
  menu $w.popup
  $w.popup add command -label "Paste moves as current game" \
      -command "catch {sc_game import \"[::rep::_decode $v]\"};
  updateBoard -pgn"
  $w.popup add separator
  if {$group} {
    $w.popup add command -label "Expand group and all subgroups" \
        -command "::rep::showAll $w $v"
    $w.popup add command -label "Collapse group and all subgroups" \
        -command "::rep::hideAll $w $v"
    $w.popup add separator
    $w.popup add command -label "Delete group, keeping subgroups..." \
        -command "::rep::deleteGroup $w $v"
    $w.popup add command -label "Delete group and subgroups..." \
        -command "::rep::pruneGroup $w $v"
  } else {
    $w.popup add command -label "Toggle included/excluded state" \
        -command "::rep::toggleLineState $w $v"
    $w.popup add separator
    $w.popup add command -label "Delete line..." \
        -command "::rep::deleteLine $w $v"
  }
  tk_popup $w.popup $x $y
}

# ::rep::search
#   Opens the repertoire search window. The parameter "type" should be
#   "all" or "displayed", indicating which lines to use in the search.
#
proc ::rep::search {repwin {type all}} {
  sc_search repertoire clear
  set lines [::rep::_searchLines $repwin $type / {}]
  set numIncluded 0
  set numExcluded 0
  foreach i $lines {
    set include [string index $i 0]
    set moves [string range $i 2 end]
    sc_game push
    if {[catch {eval "sc_move addSan $moves"} result]} {
      sc_game pop
      tk_messageBox -parent $repwin -type ok -icon warning -title "Scid" \
          -message "Error in line \"$moves\": $result"
      sc_search repertoire clear
      return
    }
    sc_search repertoire add $include
    sc_game pop
    if {$include} { incr numIncluded } else { incr numExcluded }
  }
  if {$numIncluded == 0} {
    tk_messageBox -parent $repwin -type ok -icon info -title "Scid" \
        -message "The repertoire you want to search for has no included lines, so it cannot possibly match any games."
    return
  }
  
  set w .searchRep
  toplevel $w
  wm title $w "Scid: $::tr(RepSearch)"
  bind $w <Escape> "$w.b.cancel invoke"
  bind $w <Return> "$w.b.search invoke"
  bind $w <F1> {helpWindow Repertoire Search}
  
  pack [label $w.l -anchor w] -side top -fill x
  set t "$::tr(RepSearch): $numIncluded $::tr(RepIncludedLines), "
  append t "$numExcluded $::tr(RepExcludedLines)"
  $w.l configure -text $t
  
  ::search::addFilterOpFrame $w
  addHorizontalRule $w
  
  canvas $w.progress -height 20 -width 300 -bg white -relief solid -border 1
  $w.progress create rectangle 0 0 0 0 -fill blue -outline blue -tags bar
  $w.progress create text 295 10 -anchor e -font font_Regular -tags time \
      -fill black -text "0:00 / 0:00"
  
  frame $w.b
  pack $w.b -side top -ipady 5 -fill x
  
  set ::_searchRep $repwin
  button $w.b.search -textvar ::tr(Search) -command {
    busyCursor .
    grab .searchRep.b.cancel
    sc_progressBar .searchRep.progress bar 301 21 time
    .searchRep.b.cancel configure -command sc_progressBar
    set err [catch {sc_search repertoire go $::search::filter::operation} result]
    sc_search repertoire clear
    unbusyCursor .
    grab release .searchRep.b.cancel
    grab release .searchRep
    focus .repWin
    destroy .searchRep
    if {$err} {
      tk_messageBox -parent $::_searchRep -type ok -icon info -title "Scid" \
          -message $result
    } else {
      set ::rep::_data($::_searchRep:status) "  $::tr(RepSearch): $result"
    }
    ::windows::gamelist::Refresh
    ::windows::stats::Refresh
  }
  button $w.b.cancel -textvar ::tr(Cancel) \
      -command "grab release $w; focus $repwin; destroy $w"
  pack $w.b.cancel $w.b.search -side right -pady 5 -padx 5
  pack $w.progress -side bottom
  wm resizable $w 0 0
  grab $w
}


# Images and bitmaps used in heirarchical repertoire view.
# I found the open and closed folder images used at the sourceforge.net
# website, but i hope to find or create nicer-looking ones...

image create photo ::rep::_closedgroup -data {
  R0lGODdhDwANAIQAAP7+/AICBMa6la6ehJaJda6ihPbu6ubcwNbGtN7V2c7Dp97Opc66m8a1
  lLaniu7q2Xp0cHJuW+7m1LaulKaYfL6zl25mWJ6ObYJ5a1pVTQAAAAAAAAAAAAAAAAAAAAAA
  ACwAAAAADwANAAAFYSAgjmQ5BmhgkoEwuOoaDARdEGkqBsbR/wZE4qBQBQ6CBUO5EDQcAhwg
  8GgynVAHxHhYLgWCbCFilDAbYUFhQiFPu4tK2uGgUCzlBRpaqF8IeG8QBBgUGIQRFhYZMTmO
  OiEAOw==
}

#image create photo ::rep::_oldgroup -data {
#R0lGODdhEAAPAMIAAP////j4+Hh4eLi4uPj4AAAAAAAAAAAAACwAAAAAEAAPAAADPAi63BBB
#SAlrfWIQPYS92SZ2EwUIjiMUJzC+2tpy8CajNX0DdG+zOJ8OyMv9WsYYsMQssQKFqHQ6TVkV
#CQA7
#}

image create photo ::rep::_opengroup -data {
  R0lGODdhDwANAKUAAP7+/O7u7M7OzDo6NN7e3PLy5J6enNbW1K6urH5+fDo2LIZ+bK6qnJaW
  lGpqbFZSRF5eXG5ubG5mVLaunNLOxObm4HpyZGJiXA4ODBoWFJaOfHZuXI6GdObi3OLi5EpG
  RJqOfMrKzNrWzPb27Pr69CIiHH52ZJqSfBoaFFpWT4J6ZN7azCoqLGZeVKqqrLq2pO7q5IaG
  hKKahL6+vFZWVGpmVD4+PJKKdAYGBAAAAAAAAAAAAAAAAAAAAAAAAAAAACwAAAAADwANAAAG
  kkCAcBgQCAYDwrBgOAAQhoRCsWA0BAaD4wGJQB6SCYVSsVwemIxmseF0PAUA5ONYgDIhhUY0
  IhESJSYcICcnKAQpKisADSwtIBonGpMZAC4fLyMoJyCdkJMoAB0RGzAZhJKchJUAMS0yKJOy
  HA8lM0M0JhmFnDU2BkNCBimnIDUPN8HBLCgWCgnAykMHODQCAdJBADs=
}

image create photo ::rep::_tick -data {
  R0lGODdhEAAQAKEAAP///wAAAFFR+wAAACwAAAAAEAAQAAACMISPacHtvpQKUSIKsBQiV8V1
  mIaEFWmYJ8Cl7TGynQpH4XtV9/ThuWepZR5ERtBSAAA7
}

image create photo ::rep::_cross -data {
  R0lGODdhEAAQAKEAAP///wAAAPoTQAAAACwAAAAAEAAQAAACL4SPacHtvpQKUSIKsFA7V9EZ
  YIUBoxliJXqSSeseIKzKXVujyJlbse/JPIYMoKQAADs=
}

image create photo ::rep::_tb_group -data {
  R0lGODlhEQARAIQAANnZ2QICBMa6la6ehJaJda6ihPbu6ubcwNbGtN7V2c7Dp97Opc66m8a1
  lLaniqmpqe7q2Xp0cHJuW+7m1LaulKaYfL6zl25mWJ6ObYJ5a1pVTScznicznicznicznicz
  niwAAAAAEQARAAAFdiAgjmRpnigQrEE6BsIQt2kwEHdBsCwZGAeg0IBIHBQ01UGwYDQXgoZD
  sHuIAhDoMzp1RAJWpdMpEHQLEvB18myYBQVKJR0OHJyWt8NRqVzUKmxuUwV8GAR/dQcRBBkV
  GY0SFxcagCo8mCsPYSKbnp+eLqKjIyEAOw==
}

image create photo ::rep::_tb_include -data {
  R0lGODlhEQARAKEAAP///9nZ2QAAAFFR+ywAAAAAEQARAAACOYyPecLtvoCcVIpY8zUizzEA
  W9B5YDiW1WlhFNtyACjBMTmH9t2ddJWq7XifkMbl4T2WDIXzCVUUAAA7
}

image create photo ::rep::_tb_exclude -data {
  R0lGODlhEQARAKEAANnZ2QAAAP////oTQCwAAAAAEQARAAACOoSPecHtvoScVIZY8zVBjvwJ
  G9AJQ+iFY2mG57RS5wtjE11z8kzF6W/B4FpBXabiO+ZIjyZDAY1KFQUAOw==
}

#----------------------------------------------------------------------
if {$png_image_support} {
	image create photo ::rep::_closedgroup -data {
		iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QAAAAAAAD5Q7t/AAABHElE
		QVR42s2TTUoDQRCF3wwuXCjRjeBRIp7AM7idreBpPIF4CPeRRDRCCJigSURHSdwY1MXEqnpZ9PSQ
		SQ/Bn40NRf/Q36tX/QP8p1YHwKWo/wh+SgfsdFvsdFs8PTv5lkic9433jzdcNM8xeX3EeDzCxuY6
		jo4PAaBR4cxHEuUCfH65R622g+l0UqibGeI4hqi4TWSxnqYj7O8dYM1v3t7axd2wDYCgGcwMRoWp
		wgpQXdDQvrkslYAs+/zVyRcOEEWgaZDZZwUAoxXu1KQsQBKiXwHoIV/7YoKSgJlCRALQQ86BA0mD
		2pIAQYjMAnAxG2nQfBycgcwyqEoAVkGVAoOHPq6um84u6Zzk11fVerfD0jxZ8dpWRfLnHzgHi+4c
		BY9h5BAAAAAASUVORK5CYII=
	}

	image create photo ::rep::_opengroup -data {
		iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAACo0lE
		QVR42pVTS0wTURQ9r9MvUKeD2JaCbQUxgFVREQzGhRsXJibudO3GtZDowqUxxsRE4wdidKMmYnTh
		xoWK8gnCAokLpLUtGfqhpVNaoJ0HU+iUeW6AkPhBTnI393POTe65wO9oMJkt4WMnTq55PN4cgAbs
		AA3l1l1iMiUxRVHYzVu3FYPB+O1/hw+UW3kxmZJYoVBgwWCQRWPxZY93nwqgZVtlg8kSSKQkrVAo
		sGAoxCYmJlg8HmcDQ8Miz/P+vw1yAM6Yy61vo5FIfVWlTSeKIlKzszAajaCUorraWRSnI3t+BgLj
		6/0qgOIGgZ7TG6/0PHro4a0VJBAIgBACm82GdDoNnufVXJ6WdXVeNXA68ikSiWwqE0JKfr9/Ur9W
		KtYmpdTa4NfRtaaGOnM4HIYgCOB5HlRZpeHpmOnC+XOmV729AGNgDGAAcosLXEfHqSYOwOdwKHT2
		aEuLnYBxPM9DVVWsFlU5PZdRD/uaeYPBQGSZwlJWBk3TIKUkjI2Pk57ux8M6APFEIjEzk0xiRdVU
		h8OBUqkEeakQd9irrPvr64jT6YTD6dxcP5PN4udUlAGY0K/nLj190jO3AlPeyMHh9XrT6cwPV9vx
		I2ZKKfKyDLvdAQZAklJIZ+bx4N5dAmBkg4CmJenl99HByy67IMlLiuprbnS4XC4wxqAxBk3ToCME
		8wt5DI6MQUrGXwMY0G05aVd/38fFSf8UnQqHBEEQkM1mAUJA1kMpKBCjM3jxrBsA7gPIclsIigD6
		YrHYdZWr4Hw+H1nM5cgypaByHhaLBdFIFF+GRvDh/bs7AJ4DAPmDuVqqa91vhMrdNrfHW9be1mre
		W1Oj05utkKmMG9c6VZpfPAQgvJ29reufePFg6+n+anfdsru+UQPQjh3C8K/iLzfsMM5wz19XAAAA
		AElFTkSuQmCC
	}

	image create photo ::rep::_tick -data {
		iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAACXBI
		WXMAAAsRAAALEQF/ZF+RAAAAB3RJTUUH0gsWDAwVWfJ8VQAAAhlJREFUeJyVkltIk2Ecxn/7lkvZ
		aKDCGiMP1FJIyOakUKhQTKhAihEV3WRQF9FBsDu7KSjsQHRTu+jOggyMNulGlpAJaxZMm2m2dLqD
		pZQDc1vNbW8XfYuPIdWem/eF/3P4Py8v5IerwCDQ1dphz0uoRaUa2NVi+9baYReAT1tsyMug7/DZ
		K5k7T0eEttiQBm7kEoqAdYCkN1bkzi5vtTZlXr4LCsuhcwL4ABxUEnR7z3TH9caKWaAW0JRbmrOz
		45XVO0btDo9ov/1c6Eo2ZoC7wBalQamxqi48Gfwqyi3NceAEoDM3tgH4Tt10iocv3ov6I50CCAE2
		YIPSQA20H73mEE63X5gb21KawsKLwL3NtQ1jPa5xcey6U5SUVQugF6iR6/4RC2Bq+u3Avk3WA6aq
		7TulUCjckoxFP1+61bPHPx9lcnSEj6/64gjuA2+AmNIAIJX6mRgKRyKna+p3qw3mOmlVVWC27W+S
		hnwhxl2PWF6Y8wCPgQCQyhpI8imAwKx38MnYhB+1pKKr84La4fazND/D4rQ3A7iAOWBV2V9S3JMi
		nT7v6e1eSCTTPHAME/g0Rdg3TDK+MgN4gSiQyX1AJVI/lpeC8VjMtl6rZ9HvJTLhJhn/3g/0A1/k
		bf8KbUGR1m3a1iB0pSYhp54EigHVv8TZWmWoSMjiZ4AV0KxFzq2AvGJMFiaB14AHWPmf9FxU8vvj
		rJkO8As57sg7EP2vzQAAAABJRU5ErkJggg==
	}

	image create photo ::rep::_cross -data {
		iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAC6UlE
		QVR42p2TS2hcdRSHv/u/907mzp07GJM0sUwgZip0oTEWC1abphaSKMEGIq2IWt0IQUTITheiiMZS
		UnBTEDeKuLTipggighgDIbE1jal2xvHRRmcyk3k4mft+uZCRKnahv9U5nPP9OOfAkflTuhDimBBC
		j+N4m/+qdDo9f2zotvhQtt8zDGPhZn2app0QQuRVVf1eVdWRvwoHBnquF8++HH/z9MPx8cHe2DCM
		V/4J67o+eVd/b/TFC6fi85MHYk1VfgEQAOmEinVlHdd2eHE0x3gm8aphGM914GQyefyOjHbhw8en
		JGljle1yBY3IAZABGkH42KN9etarlAhsi/HhLG3Hm/7Ri6upVOpyt8y3Hz8xLV9bW2GzbvLpdov1
		tjcBlAXA/WNHPnp+JR/L3b3EgFff4WRPgrt19Zxpmj+fPzUjXbu0xkp1l3d+qnChZk3EcXwJQOqM
		mUqlXrpdUxbePrQfr7FDCIQRhMP72Ws3WS1e582rJX8r4L4gCC52OLkT+L6/ZAmluFlrzU7lsgS2
		hZCgW5Goblc4nS9TsMMzYRh+cONx5RsT3/cvb1luV6nRHHvkyGHcnQqOaSILGO/LsG6HY6akbPi+
		/92/GiiKMjegSKffnZ+j8fUyLhJxFCFLoEpw+JYkF1vurCnJK77vF/9mIISYP7ine/H9uSeVxtJn
		bDZtnt0oFQpW0PNQbpDIsegSEkd7dHm56c40HG8TyMsAkiQtnBwaeP2NE9NK/avPKZgui4WKFSSS
		QyU3KOWrjemJfYNEtkWXBKO9ma5Pyq3RIIrOyQC5VOK9t56azfy+ukTR8jn7QzX4LWBfu91ueJ63
		WhOquVVvTT44PEhsW/hBwFrbFzXHOyMDRIryTK5V6a95Ia9dLVMJpQccx7nSWc/zvOUSyp5fm62D
		R4ezlHYtvqzbuzXHXQRAVdWROzPaTlZT65qmzdzsmQzDWLh3b59/T/+tcTqdnuf/SJblESHEFKAD
		/AFjPUc+w8q9dwAAAABJRU5ErkJggg==
	}

	image create photo ::rep::_tb_group -data {
		iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QAAAAAAAD5Q7t/AAABHElE
		QVR42s2TTUoDQRCF3wwuXCjRjeBRIp7AM7idreBpPIF4CPeRRDRCCJigSURHSdwY1MXEqnpZ9PSQ
		SQ/Bn40NRf/Q36tX/QP8p1YHwKWo/wh+SgfsdFvsdFs8PTv5lkic9433jzdcNM8xeX3EeDzCxuY6
		jo4PAaBR4cxHEuUCfH65R622g+l0UqibGeI4hqi4TWSxnqYj7O8dYM1v3t7axd2wDYCgGcwMRoWp
		wgpQXdDQvrkslYAs+/zVyRcOEEWgaZDZZwUAoxXu1KQsQBKiXwHoIV/7YoKSgJlCRALQQ86BA0mD
		2pIAQYjMAnAxG2nQfBycgcwyqEoAVkGVAoOHPq6um84u6Zzk11fVerfD0jxZ8dpWRfLnHzgHi+4c
		BY9h5BAAAAAASUVORK5CYII=
	}

	image create photo ::rep::_tb_include -data {
		iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAACXBI
		WXMAAAsRAAALEQF/ZF+RAAAAB3RJTUUH0gsWDAwVWfJ8VQAAAhlJREFUeJyVkltIk2Ecxn/7lkvZ
		aKDCGiMP1FJIyOakUKhQTKhAihEV3WRQF9FBsDu7KSjsQHRTu+jOggyMNulGlpAJaxZMm2m2dLqD
		pZQDc1vNbW8XfYuPIdWem/eF/3P4Py8v5IerwCDQ1dphz0uoRaUa2NVi+9baYReAT1tsyMug7/DZ
		K5k7T0eEttiQBm7kEoqAdYCkN1bkzi5vtTZlXr4LCsuhcwL4ABxUEnR7z3TH9caKWaAW0JRbmrOz
		45XVO0btDo9ov/1c6Eo2ZoC7wBalQamxqi48Gfwqyi3NceAEoDM3tgH4Tt10iocv3ov6I50CCAE2
		YIPSQA20H73mEE63X5gb21KawsKLwL3NtQ1jPa5xcey6U5SUVQugF6iR6/4RC2Bq+u3Avk3WA6aq
		7TulUCjckoxFP1+61bPHPx9lcnSEj6/64gjuA2+AmNIAIJX6mRgKRyKna+p3qw3mOmlVVWC27W+S
		hnwhxl2PWF6Y8wCPgQCQyhpI8imAwKx38MnYhB+1pKKr84La4fazND/D4rQ3A7iAOWBV2V9S3JMi
		nT7v6e1eSCTTPHAME/g0Rdg3TDK+MgN4gSiQyX1AJVI/lpeC8VjMtl6rZ9HvJTLhJhn/3g/0A1/k
		bf8KbUGR1m3a1iB0pSYhp54EigHVv8TZWmWoSMjiZ4AV0KxFzq2AvGJMFiaB14AHWPmf9FxU8vvj
		rJkO8As57sg7EP2vzQAAAABJRU5ErkJggg==
	}

	image create photo ::rep::_tb_exclude -data {
		iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAABmJLR0QA/wD/AP+gvaeTAAAC6UlE
		QVR42p2TS2hcdRSHv/u/907mzp07GJM0sUwgZip0oTEWC1abphaSKMEGIq2IWt0IQUTITheiiMZS
		UnBTEDeKuLTipggighgDIbE1jal2xvHRRmcyk3k4mft+uZCRKnahv9U5nPP9OOfAkflTuhDimBBC
		j+N4m/+qdDo9f2zotvhQtt8zDGPhZn2app0QQuRVVf1eVdWRvwoHBnquF8++HH/z9MPx8cHe2DCM
		V/4J67o+eVd/b/TFC6fi85MHYk1VfgEQAOmEinVlHdd2eHE0x3gm8aphGM914GQyefyOjHbhw8en
		JGljle1yBY3IAZABGkH42KN9etarlAhsi/HhLG3Hm/7Ri6upVOpyt8y3Hz8xLV9bW2GzbvLpdov1
		tjcBlAXA/WNHPnp+JR/L3b3EgFff4WRPgrt19Zxpmj+fPzUjXbu0xkp1l3d+qnChZk3EcXwJQOqM
		mUqlXrpdUxbePrQfr7FDCIQRhMP72Ws3WS1e582rJX8r4L4gCC52OLkT+L6/ZAmluFlrzU7lsgS2
		hZCgW5Goblc4nS9TsMMzYRh+cONx5RsT3/cvb1luV6nRHHvkyGHcnQqOaSILGO/LsG6HY6akbPi+
		/92/GiiKMjegSKffnZ+j8fUyLhJxFCFLoEpw+JYkF1vurCnJK77vF/9mIISYP7ine/H9uSeVxtJn
		bDZtnt0oFQpW0PNQbpDIsegSEkd7dHm56c40HG8TyMsAkiQtnBwaeP2NE9NK/avPKZgui4WKFSSS
		QyU3KOWrjemJfYNEtkWXBKO9ma5Pyq3RIIrOyQC5VOK9t56azfy+ukTR8jn7QzX4LWBfu91ueJ63
		WhOquVVvTT44PEhsW/hBwFrbFzXHOyMDRIryTK5V6a95Ia9dLVMJpQccx7nSWc/zvOUSyp5fm62D
		R4ezlHYtvqzbuzXHXQRAVdWROzPaTlZT65qmzdzsmQzDWLh3b59/T/+tcTqdnuf/SJblESHEFKAD
		/AFjPUc+w8q9dwAAAABJRU5ErkJggg==
	}
}
#----------------------------------------------------------------------


set maskdata "#define solid_width 9\n#define solid_height 9"
append maskdata {
  static unsigned char solid_bits[] = {
    0xff, 0x01, 0xff, 0x01, 0xff, 0x01, 0xff, 0x01, 0xff, 0x01, 0xff, 0x01,
    0xff, 0x01, 0xff, 0x01, 0xff, 0x01
  };
}

set data "#define open_width 9\n#define open_height 9"
append data {
  static unsigned char open_bits[] = {
    0xff, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x01, 0x7d, 0x01, 0x01, 0x01,
    0x01, 0x01, 0x01, 0x01, 0xff, 0x01
  };
}

image create bitmap ::rep::_shown -data $data -maskdata $maskdata \
    -foreground black -background white

set data "#define closed_width 9\n#define closed_height 9"
append data {
  static unsigned char closed_bits[] = {
    0xff, 0x01, 0x01, 0x01, 0x11, 0x01, 0x11, 0x01, 0x7d, 0x01, 0x11, 0x01,
    0x11, 0x01, 0x01, 0x01, 0xff, 0x01
  };
}

image create bitmap ::rep::_hidden -data $data -maskdata $maskdata \
    -foreground black -background white

###
### End of file: reper.tcl
###
