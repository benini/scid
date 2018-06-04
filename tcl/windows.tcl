###
### windows.tcl: part of Scid.
### Copyright (C) 1999-2003  Shane Hudson.
###


namespace eval ::windows {
  
  # TODO
}

########################################################################
###  Optional windows: all off initially.

set treeWin 0
set pgnWin 0
set filterGraph 0

################################################################################
# Creates a toplevel window depending of the docking option
################################################################################
proc createToplevel { {w} {closeto ""} } {
  set name [string range $w 1 end]
  set f .fdock$name

  # Raise window if already exist
  if { [winfo exists $w] } {
    if {! $::docking::USE_DOCKING } {
      tk::PlaceWindow $w
    } else {
      if { [::docking::isUndocked $w] } {
        tk::PlaceWindow $f
      } else {
        [::docking::find_tbn $f] select $f
      }
    }
    return "already_exists"
  }

  if { $::docking::USE_DOCKING } {
    frame $f  -container 1
    toplevel .$name -use [ winfo id $f ]
    if {[info exists ::docking::notebook_name($f)]} {
      ::docking::undock_win $f ""
    } else {
      set old_dest $::docking::layout_dest_notebook
      if {$old_dest == "" && $closeto != ""} {
        set tab [string range $closeto 1 end]
        set ::docking::layout_dest_notebook [::docking::find_tbn .fdock$tab]
      }
      docking::add_tab "$f" "$f"
      set ::docking::layout_dest_notebook $old_dest
    }
  } else  {
    toplevel $w
  }
}

################################################################################
# In the case of a window closed without the context menu in docked mode, arrange for the tabs to be cleaned up
# Alternative way : directly call ::docking::cleanup $w when closing window
################################################################################
proc createToplevelFinalize {w} {
  if { $::docking::USE_DOCKING } {
    bind $w <Destroy> "+if {\[string equal $w %W\]} {
      ::docking::cleanup $w %W
    }"
  }
}

# recordWinSize:
#   Records window width and height, for saving in options file.
#
proc recordWinSize {win} {
  global winWidth winHeight winX winY
  if {![winfo exists $win]} { return }
  if { $::docking::USE_DOCKING && ! [ ::docking::isUndocked $win ]} { return }
  set temp [wm geometry $win]
  
  set suffix ""
  set n [scan $temp "%dx%d+%d+%d" width height x y]
  if {$n == 4} {
    set winWidth${suffix}($win) $width
    set winHeight${suffix}($win) $height
    set winX${suffix}($win) $x
    set winY${suffix}($win) $y
  }
}

proc setWinLocation {win} {
  global winX winY
  set suffix ""
  if {[info exists winX${suffix}($win)]  &&  [info exists winY${suffix}($win)]  && \
        [set winX${suffix}($win)] >= 0  &&  [set winY${suffix}($win)] >= 0} {
    catch [list wm geometry $win "+[set winX${suffix}($win)]+[set winY${suffix}($win)]"]
  }
}

proc setWinSize {win} {
  global winWidth winHeight
  set suffix ""
  if {[info exists winWidth${suffix}($win)]  &&  [info exists winHeight${suffix}($win)]  &&  \
        [set winWidth${suffix}($win) ] > 0  &&  [set winHeight${suffix}($win) ] > 0 } {
    catch [list wm geometry $win "[set winWidth${suffix}($win) ]x[set winHeight${suffix}($win) ]"]
  }
}

###
### End of file: windows.tcl
###
