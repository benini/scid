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


proc createWindow { {w} {default_w} {default_h} {title} } {
	# Raise window if already exists
	if { [winfo exists $w] } {
		if {[winfo toplevel $w] == $w} {
			wm deiconify $w
		} else {
			[::docking::find_tbn $w] select $w
		}
		return 0
	}

	# Set default width and height values, if they do not exists
	if {![info exists ::winGeometry($w)]} {
		set ::winGeometry($w) [string cat "$default_w" "x" "$default_h"]
	}

	# Create the window
	frame $w
	if {![info exists ::docking::notebook_name($w)] && $::docking::USE_DOCKING } {
		::docking::add_tab $w "$title"
	} else {
		::docking::undock_win $w "$title"
	}

	keyboardShortcuts $w

	return 1
}

proc saveWinGeometry {w} {
	if {[winfo toplevel $w] == $w} {
		set ::winGeometry($w) [wm geometry $w]
		return 1
	}
	return 0
}

proc restoreWinGeometry {w} {
	if {[info exists ::winGeometry($w)]} {
		wm geometry $w $::winGeometry($w)
		return 1
	}
	return 0
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

################################################################################
# if undocked window : sets the title of the toplevel window
# if docked : sets the name of the tab
# w : name of the toplevel window
proc setTitle { w title } {
  set nb [ ::docking::find_tbn $w ]
  if {$nb ne ""} {
    # in docked mode trim down title to spare space
    if { [ string range $title 0 5 ] == "Scid: " &&  [ string length $title ] > 6 } {
      set title [string range $title 6 end]
    }
    $nb tab $w -text $title
  } else {
    set f ".fdock[string range $w 1 end]"
    if {[winfo exists $f]} { return [::setTitle $f $title] }

    wm title $w $title
  }
}

################################################################################
# Sets the menu for a new window : in docked mode the menu is displayed by clicking on the tab of the notebook
################################################################################
proc setMenu { w m} {
  if {[string equal -length 6 $w ".fdock"]} {
    set wnd [string replace $w 1 5]
  } else {
    set wnd $w
  }

  set nb [ ::docking::find_tbn $w ]
  if {$nb ne ""} {
    $nb tab $w -image tb_menu -compound left
    catch { $wnd configure -menu "" }
  } else {
    set f ".fdock[string range $w 1 end]"
    if {[winfo exists $f]} { return [::setMenu $f $m] }
    $wnd configure -menu $m
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
