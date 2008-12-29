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
set commentWin 0
set filterGraph 0

set nagValue 0

# recordWinSize:
#   Records window width and height, for saving in options file.
#
proc recordWinSize {win} {
  global winWidth winHeight winX winY winX_docked winY_docked winWidth_docked winHeight_docked
  if {![winfo exists $win]} { return }
  set temp [wm geometry $win]
  
  if { $::docking::USE_DOCKING } {
    set suffix "_docked"
  } else  {
    set suffix ""
  }
  
  set n [scan $temp "%dx%d+%d+%d" width height x y]
  if {$n == 4} {
    set winWidth[subst $suffix]($win) $width
    set winHeight[subst $suffix]($win) $height
    set winX[subst $suffix]($win) $x
    set winY[subst $suffix]($win) $y
  }
}

proc setWinLocation {win} {
  global winX winY winX_docked winY_docked

if { $::docking::USE_DOCKING } {
    set suffix "_docked"
  } else  {
    set suffix ""
  }
  
  if {[info exists winX[subst $suffix]($win)]  &&  [info exists winY[subst $suffix]($win)]  && \
        [subst $[subst winX$suffix]($win) ] >= 0  &&  [subst $[subst winY$suffix]($win) ] >= 0} {
    catch [list wm geometry $win "+[subst $[subst winX$suffix]($win) ]+[subst $[subst winY$suffix]($win) ]"]
  }
}

proc setWinSize {win} {
  global winWidth winHeight winWidth_docked winHeight_docked
  
  if { $::docking::USE_DOCKING } {
    set suffix "_docked"
  } else  {
    set suffix ""
  }
  
  if {[info exists winWidth[subst $suffix]($win)]  &&  [info exists winHeight[subst $suffix]($win)]  &&  \
        [subst $[subst winWidth$suffix]($win) ] > 0  &&  [subst $[subst winHeight$suffix]($win) ] > 0 } {
    catch [list wm geometry $win "[subst $[subst winWidth$suffix]($win) ]x[subst $[subst winHeight$suffix]($win) ]"]
  }
}


###
### End of file: windows.tcl
###
