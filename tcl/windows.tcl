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
    set old_dest $::docking::layout_dest_notebook
    if {$old_dest == "" && $closeto != ""} {
      set tab [string range $closeto 1 end]
      set ::docking::layout_dest_notebook [::docking::find_tbn .fdock$tab]
    }
    frame $f  -container 1
    toplevel .$name -use [ winfo id $f ]
    docking::add_tab "$f" "$f"
    set ::docking::layout_dest_notebook $old_dest
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
	if {![info exists ::winWidth($w)]} {
		set ::winWidth($w) $default_w
	}
	if {![info exists ::winHeight($w)]} {
		set ::winHeight($w) $default_h
	}

	# Create the window
	frame $w
	if { $::docking::USE_DOCKING } {
		docking::add_tab $w "$title"
	} else {
		wm manage $w
		wm title $w "Scid: $title"
		setWinLocation $w
		setWinSize $w
	}

	keyboardShortcuts $w
	after idle "bind $w <Destroy> \"+cleanupWindow $w %W\""

	return 1
}

proc cleanupWindow { {w} {w_destroy} } {
	if {[string equal $w $w_destroy]} {
		if {[winfo toplevel $w] == $w} {
			scan [wm geometry $w] "%dx%d+%d+%d" l h x y
			set ::winWidth($w) $l
			set ::winHeight($w) $h
			set ::winX($w) $x
			set ::winY($w) $y
		} else {
			::docking::cleanup $w
		}
	}
}


################################################################################
# In the case of a window closed without the context menu in docked mode, arrange for the tabs to be cleaned up
# Alternative way : directly call ::docking::cleanup $w when closing window
################################################################################
proc createToplevelFinalize {w} {
  if { $::docking::USE_DOCKING } {
    bind $w <Destroy> +[ namespace code "::docking::cleanup $w %W"]
  }
}

################################################################################
# if undocked window : sets the title of the toplevel window
# if docked : sets the name of the tab
# w : name of the toplevel window
proc setTitle { w title } {
    set f .fdock[ string range $w 1 end ]
    if { [catch {set nb [ ::docking::find_tbn $f ]} ]} {
      set nb ""
    }

    if { $nb == "" } {
      wm title $w $title
    } else  {
      # in docked mode trim down title to spare space
      if { [ string range $title 0 5 ] == "Scid: " &&  [ string length $title ] > 6 } {
        set title [string range $title 6 end]
      }
      $nb tab $f -text $title
    }
}

################################################################################
# Sets the menu for a new window : in docked mode the menu is displayed by clicking on the tab of the notebook
################################################################################
proc setMenu { w m} {
  if { ! $::docking::USE_DOCKING } {
    $w configure -menu $m
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
