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
  global winWidth winHeight winX winY
  if {![winfo exists $win]} { return }
  set temp [wm geometry $win]

  set n [scan $temp "%dx%d+%d+%d" width height x y]
  if {$n == 4} {
    set winWidth($win) $width
    set winHeight($win) $height
    set winX($win) $x
    set winY($win) $y
  }
}

proc setWinLocation {win} {
  global winX winY
  if {[info exists winX($win)]  &&  [info exists winY($win)]  && \
        $winX($win) >= 0  &&  $winY($win) >= 0} {
    catch [list wm geometry $win "+$winX($win)+$winY($win)"]
  }
}

proc setWinSize {win} {
  global winWidth winHeight
  if {[info exists winWidth($win)]  &&  [info exists winHeight($win)]  &&  \
    $winWidth($win) > 0  &&  $winHeight($win) > 0} {
    catch [list wm geometry $win "$winWidth($win)x$winHeight($win)"]
  }
}


###
### End of file: windows.tcl
###
