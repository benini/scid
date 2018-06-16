# Copyright (C) 2008-2009 Pascal Georges
# Copyright (C) 2013-2018 Fulvio Benini
#
# This file is part of Scid (Shane's Chess Information Database).
#
# Scid is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.
#
# Scid is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Scid.  If not, see <http://www.gnu.org/licenses/>.

namespace eval ::win {}

# Create a container panedwindow for docking
proc ::win::createDockWindow {path} {
	ttk::panedwindow $path -orient vertical
	$path add [::docking::create_notebook_ .nb] -weight 1
	set docking::tbs(.nb) $path
	pack $path -fill both -expand true
}

# Creates a docked/undocked window.
proc ::win::createWindow { {w} {default_w} {default_h} {title} } {
	# Raise window if already exists
	if { [winfo exists $w] } {
		if { [::win::isToplevel $w] } {
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
	::win::manageWindow $w $title

	keyboardShortcuts $w

	return 1
}

# Close a window, independently of its docked state.
# If the window is undocked the window geometry is saved.
proc ::win::closeWindow {w} {
	lassign [::win::isDocked $w] docked w
	if {$docked} {
		::docking::remove_tab $w [::docking::find_tbn $w]
	} else {
		::win::saveWinGeometry $w
	}
	destroy $w
}

# if undocked window : sets the title of the toplevel window.
# if docked : sets the name of the tab.
# TODO: ::win::setTitle
proc setTitle { w title } {
	lassign [::win::isDocked $w] docked w
	if {$docked} {
		# in docked mode trim down title to spare space
		if {[string equal -length 6 $title "Scid: "]} {
			set title [string range $title 6 end]
		}
		set nb [ ::docking::find_tbn $w ]
		$nb tab $w -text $title
	} else {
		wm title $w $title
	}
}

# Return a list containing the name of the menu (or "" if a menu do not exists)
# and the name of the corresponding toplevel window
# param w: the (child) widget
proc ::win::getMenu {w} {
	lassign [::win::isDocked $w] docked wnd
	if {[string equal -length 6 $wnd ".fdock"]} {
		set w [string replace $wnd 1 5]
	}
	if {[info exists ::win::menu_($wnd)]} {
		return [list $::win::menu_($wnd) $w]
	}
	return [list "" $w]
}

# if undocked window : sets the menu of the toplevel window.
# if docked : displays a menu icon in the tab.
# param w: the (child) widget
# TODO: ::win::setMenu
proc setMenu {w m} {
	lassign [::win::isDocked $w] docked wnd
	if {$docked} {
		set nb [ ::docking::find_tbn $wnd ]
		$nb tab $wnd -image tb_tabmenu -compound left
	} else {
		$w configure -menu $m
	}
	set ::win::menu_($wnd) $m
}

# Save the geometry of an undocked toplevel window.
proc ::win::saveWinGeometry {w} {
	if {[::win::isToplevel $w]} {
		update idletasks
		if {[wm state $w] == "zoomed"} {
			set ::winGeometry($w) "zoomed"
		} else {
			set ::winGeometry($w) [wm geometry $w]
		}
	}
}

# Restore the geometry of an undocked toplevel window.
# return true if a stored geometry was available.
proc ::win::restoreWinGeometry {w} {
	if {[info exists ::winGeometry($w)]} {
		if {$::winGeometry($w) == "zoomed"} {
			if { $::windowsOS || $::macOS } {
				wm state $w zoomed
			} else {
				wm attributes $w -zoomed
			}
		} else {
			wm geometry $w $::winGeometry($w)
		}
		return 1
	}
	return 0
}

# Return true if is a toplevel undocked window
proc ::win::isToplevel {wnd} {
	lassign [::win::isDocked $wnd] docked top
	return [expr {!$docked && $top eq $wnd}]
}

# Return true if is a (child of a) docked window
proc ::win::isDocked {wnd} {
	# Get the window at the top of the hierarchy (not the toplevel)
	regexp {[.]\w*} "$wnd" wnd
	set f ".fdock[string range $wnd 1 end]"
	if {[winfo exists $f]} { set wnd $f }

	set docked [catch {wm title $wnd}]
	return [list $docked $wnd]
}

# Undock a toplevel window
proc ::win::undockWindow {wnd {srctab ""}} {
	set title ""
	if {$srctab ne "" } {
		set old_options [::docking::remove_tab $wnd $srctab]
		set title [dict get $old_options -text]
	}

	wm manage $wnd
	wm title $wnd "Scid: $title"
	wm protocol $wnd WM_DELETE_WINDOW "::win::closeWindow $wnd"
	::win::restoreWinGeometry $wnd

	lassign [::win::getMenu $wnd] menu wmenu
	if {$menu ne ""} { ::setMenu $wmenu $menu }

	# Remember the source notebook
	set ::docking::notebook_name($wnd) $srctab
}

# Dock a toplevel window
proc ::win::dockWindow {wnd} {
	# in docked mode trim down title to spare space
	set title [wm title $wnd]
	if {[string equal -length 6 $title "Scid: "]} {
		set title [string range $title 6 end]
	}

	lassign [::win::getMenu $wnd] menu wmenu
	$wmenu configure -menu {}

	::win::saveWinGeometry $wnd
	wm forget $wnd

	if {[winfo exists $::docking::notebook_name($wnd)]} {
		set dsttab $::docking::notebook_name($wnd)
	} else {
		set dsttab [::docking::choose_notebook $wnd]
	}
	unset ::docking::notebook_name($wnd)
	::docking::insert_tab $wnd $dsttab end \
		[list -text $title -image tb_close -compound left]

	if {$menu ne ""} { ::setMenu $wnd $menu }
}

# Toggle the docked/undocked status of a window
# param wnd: the (child) widget
proc ::win::toggleDocked {wnd} {
	lassign [::win::isDocked $wnd] docked wnd

	# Check if the window can be docked/undocked
	if {$wnd eq ".fdockmain" || [winfo class $wnd] ne "Frame"} {
		return
	}

	if {$docked} {
		set srctab [::docking::find_tbn $wnd]
		::win::undockWindow $wnd $srctab
	} else {
		::win::dockWindow $wnd
	}
}

proc ::win::manageWindow {wnd title} {
	if { [info exists ::docking::layout_dest_notebook]} {
		set dsttab $::docking::layout_dest_notebook
		unset ::docking::layout_dest_notebook
		set docked [expr { $dsttab ne "undocked" }]
	} else  {
		set docked $::windowsDock
	}
	if {$docked} {
		if {![info exists dsttab]} {
			set dsttab [::docking::choose_notebook $wnd]
		}
		::docking::insert_tab $wnd $dsttab end \
			[list -text $title -image tb_close -compound left]
	} else {
		::win::undockWindow $wnd
		setTitle $wnd "$title"
	}
}

# ::utils::win::Centre
#
#   Centres a window on the screen.
#
proc ::utils::win::Centre {w} {
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
        - [winfo vrootx .]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
        - [winfo vrooty .]}]
  wm geom $w +$x+$y
  wm deiconify $w
}

################################################################################
#
#     DockingFramework
#
#     Code is inspired by
#     http://wiki.tcl.tk/21846
#     which is published under BSD license
#
################################################################################

namespace eval docking {
  # associates notebook to paned window
  variable tbs
  variable tbcnt 0

}

################################################################################
# find notebook, corresponding to path
proc ::docking::find_tbn {path} {
  variable tbs
  
  if {$path=="" || ![winfo exists $path]} { return "" }
  # already a managed notebook?
  if {[info exists tbs($path)]} {
    return $path
  }
  # managed notebooks have the form .toplevel.tbn#
  # pages within notebooks should also have the path .toplevel.page#
  set spath [split $path "."]
  if {[winfo toplevel $path]=="."} {
    set path [join [lrange $path 0 1] "."]
  } else {
    set path [join [lrange $path 0 2] "."]
  }
  
  # is it a managed notebook?
  if {[info exists tbs($path)]} {
    return $path
  }
  
  # try to find notebook that manages this page
  foreach tb [array names tbs] {
    if {[winfo class $tb] != "TNotebook"} {
      continue
    }
    if {[lsearch -exact [$tb tabs] $path]>=0} {
      return $tb
    }
  }
  
  return {}
}

################################################################################
# added paned window of other direction, move a notebook there and create a new notebook
proc ::docking::embed_tbn {tbn anchor} {
  variable tbcnt
  variable tbs
  set pw $tbs($tbn)
  if {$anchor=="w" || $anchor=="e"} {
    set orient "horizontal"
  } else {
    set orient "vertical"
  }
  # create new paned window
  set npw [ttk::panedwindow $pw.pw$tbcnt -orient $orient  ]
  incr tbcnt
  # move old notebook
  set i [lsearch -exact [$pw panes] $tbn]
  $pw forget $tbn
  if {$i>=[llength [$pw panes]]} {
    $pw add $npw -weight 1
  } else {
    $pw insert $i $npw -weight 1
  }
  # add new notebook
  set ntb [create_notebook_ [winfo toplevel $pw].tb$tbcnt]
  set tbs($tbn) $npw
  set tbs($ntb) $npw
  # make sure correct order
  if {$anchor=="n" || $anchor=="w"} {
    $npw add $ntb -weight 1
    $npw add $tbn -weight 1
  } else {
    $npw add $tbn -weight 1
    $npw add $ntb -weight 1
  }
  return $ntb
}

################################################################################
# add a new notebook to the side anchor of the notebook tbn
proc ::docking::add_tbn {tbn anchor} {
  variable tbcnt
  variable tbs
  
  set pw $tbs($tbn)
  set orient [$pw cget -orient]
  
  # if orientation of the uplevel panedwindow is consistent with anchor, just add the pane
  if {$orient=="horizontal" && ($anchor=="w" || $anchor=="e")} {
    set i [lsearch -exact [$pw panes] $tbn]
    if {$anchor=="e"} { incr i }
    set tbn [create_notebook_ [winfo toplevel $pw].tb$tbcnt]
    set tbs($tbn) $pw
    if {$i>=[llength [$pw panes]]} {
      $pw add $tbn -weight 1
    } else {
      $pw insert $i $tbn -weight 1
    }
  } elseif {$orient=="vertical" && ($anchor=="n" || $anchor=="s")} {
    set i [lsearch -exact [$pw panes] $tbn]
    if {$anchor=="s"} { incr i}
    set tbn [create_notebook_ [winfo toplevel $pw].tb$tbcnt]
    set tbs($tbn) $pw
    if {$i>=[llength [$pw panes]]} {
      $pw add $tbn -weight 1
    } else {
      $pw insert $i $tbn -weight 1
    }
  } else {
    # orientation of the uplevel panedwindow is opposite to the anchor
    # need to add new panedwindow
    set tbn [embed_tbn $tbn $anchor]
  }
  return $tbn
}

################################################################################
# always keep .pw paned window
proc ::docking::_cleanup_tabs {srctab} {
  variable tbs

  # if srctab is empty, then remove it
  if {[llength [$srctab tabs]]==0} {
    destroy $srctab
    set pw $tbs($srctab)
    unset tbs($srctab)

    while {[llength [$pw panes]]==0} {
      set parent [winfo parent $pw]

      if {$pw == ".pw"} {
        break
      }
      destroy $pw
      set pw $parent
    }

  }
}
################################################################################
# cleans up a window when it was closed without calling the notebook menu
proc ::docking::cleanup { w { origin "" } } {
  if {$w == $origin || $origin == ""} {
    set dockw ".fdock[string range $w 1 end]"
    set tab [::docking::find_tbn $dockw]
    if {$tab != ""} {
      $tab forget $dockw
      ::docking::_cleanup_tabs $tab
    }
    after idle "if {[winfo exists $dockw]} { destroy $dockw }"
    catch { focus .main }
  }
}
################################################################################
proc ::docking::close {w} {
  set tabid [$w select]
  if {[winfo exists $tabid]} {
    $w forget $tabid
    destroy $tabid
  }
  _cleanup_tabs $w
}

################################################################################
################################################################################
################################################################################


# The coefficients for the selections of the container Notebook
# have been calculated doing a linear regression of this matrix:
# board   tabs    tabs^2   similar  sim^2   sim^3   area     fitness
# 0       0       0        0        0       0       0,9      120900
# 0       0       0        0        0       0       0,5      120500
# 0       0       0        0        0       0       0,1      120100
# 0       5       25       5        25      125     0,9      99900
# 0       5       25       5        25      125     0,5      99500
# 0       5       25       5        25      125     0,1      99100
# 0       3       9        3        9       27      0,9      93900
# 0       3       9        3        9       27      0,5      93500
# 0       3       9        3        9       27      0,1      93100
# 0       2       4        2        4       8       0,9      87900
# 0       2       4        2        4       8       0,5      87500
# 0       2       4        2        4       8       0,1      87100
# 0       4       16       3        9       27      0,9      81900
# 0       4       16       3        9       27      0,5      81500
# 0       4       16       3        9       27      0,1      81100
# 0       3       9        2        4       8       0,9      75900
# 0       3       9        2        4       8       0,5      75500
# 0       3       9        2        4       8       0,1      75100
# 0       2       4        1        1       1       0,9      69900
# 0       2       4        1        1       1       0,5      69500
# 0       2       4        1        1       1       0,1      69100
# 0       3       9        1        1       1       0,9      63900
# 0       3       9        1        1       1       0,5      63500
# 0       3       9        1        1       1       0,1      63100
# 0       2       4        1        1       1       0,9      57900
# 0       2       4        1        1       1       0,5      57500
# 0       2       4        1        1       1       0,1      57100
# 0       1       1        0        0       0       0,9      39900
# 0       1       1        0        0       0       0,5      39500
# 0       1       1        0        0       0       0,1      39100
# 0       3       9        0        0       0       0,9      33900
# 0       3       9        0        0       0       0,5      33500
# 0       3       9        0        0       0       0,1      33100
# 1       2       4        1        1       1       0,9      9900
# 1       2       4        1        1       1       0,5      9500
# 1       2       4        1        1       1       0,1      9100
# 1       1       1        0        0       0       0,9      7900
# 1       1       1        0        0       0       0,5      7500
# 1       1       1        0        0       0       0,1      7100
# 1       2       4        0        0       0       0,9      5900
# 1       2       4        0        0       0       0,5      5500
# 1       2       4        0        0       0       0,1      5100
# Improving the matrix and recalculating can improve the select algorithm
proc ::docking::choose_notebook { path } {
    set dsttab {}
    set best_fitting ""
    foreach tb [array names ::docking::tbs] {
      if {[winfo class $tb] != "TNotebook"} { continue }

      set tabs [$tb tabs]

      # Features
      set feat(0) 1
      set coeff(0) "105622.84"
      # number of boards
      set feat(1) [llength [lsearch -all -regexp $tabs ".*main"]]
      set coeff(1) "-48019.31"
      # number of tabs
      set feat(2) [llength $tabs]
      set coeff(2) "-51266.84"
      # number of tabs^2
      set feat(3) [expr { $feat(2) * $feat(2) }]
      set coeff(3) "8661.97"
      # number of similar windows
      set name_striptrailnum [regsub {\d*$} $path ""]
      set feat(4) [llength [lsearch -all -regexp $tabs ".*$name_striptrailnum.*"]]
      set coeff(4) "29942.45"
      # number of similar windows^2
      set feat(5) [expr { $feat(4) * $feat(4) }]
      set coeff(5) "-3053.05"
      # number of similar windows^3
      set feat(6) [expr { $feat(4) * $feat(4) * $feat(4) }]
      set coeff(6) "-323.52"
      # ratio between the area of the notebook and the screen
      set feat(7) [expr { double([winfo width $tb] * [winfo height $tb]) }]
      set feat(7) [expr { $feat(7) / ([winfo screenwidth $tb] * [winfo screenheight $tb]) }]
      set coeff(7) "1000"

      set fit 0;
      for {set i 0} {$i < [array size feat]} {incr i} {
        set fit [expr { $fit + $feat($i) * $coeff($i)}]
      }

      if {$best_fitting == "" || $fit > $best_fitting} {
        set best_fitting $fit
        set dsttab $tb
      }
    }
    return $dsttab
}

# Insert a window into a notebook
proc ::docking::insert_tab {wnd dest_noteb {dest_pos "end"} {options ""}} {
	$dest_noteb insert $dest_pos $wnd {*}$options
	$dest_noteb select $wnd
	raise $wnd
}

# Remove a window from a notebook
proc ::docking::remove_tab {wnd src_noteb} {
	set options [$src_noteb tab $wnd]
	$src_noteb forget $wnd
	::docking::_cleanup_tabs $src_noteb
	return $options
}

# Move a window between two different notebooks
proc ::docking::move_tab_ {wnd src_noteb dest_noteb {dest_pos "end"} } {
	set options [::docking::remove_tab $wnd $src_noteb]
	::docking::insert_tab $wnd $dest_noteb $dest_pos $options
}

# Create a new notebook
proc ::docking::create_notebook_ {path} {
	set noteb [ttk::notebook $path]
	incr tbcnt
	bind $noteb <B1-Motion> {
		if {[info exists ::docking::motion_]} { continue }
		set ::docking::motion_ [::docking::identify_tab_ %W %x %y]
		if {[lindex $::docking::motion_ 0] eq ""} {
			# Do nothing if motion started outside a tab
			continue
		}
		if {[lindex $::docking::motion_ 1]} {
			# Not a motion event if it starts and ends over the icon
			unset ::docking::motion_
		} else {
			%W configure -cursor hand2
		}
	}
	bind $noteb <ButtonRelease-1> {
		if {[info exists ::docking::motion_]} {
			%W configure -cursor {}
			::docking::manage_motion_ %W %X %Y
		} else {
			::docking::manage_click_ %W %X %Y %x %y
		}
	}
	bind $noteb <ButtonRelease-$::MB3> {
		::docking::manage_rightclick_ %W %X %Y %x %y
	}
	return $noteb
}

# Given the x y coords relative to a notebook, returns a list containing the
# index of the tab (or "") and true if the point given is over the tab's image.
proc ::docking::identify_tab_ {noteb localX localY} {
	set isIcon 0
	set tab [$noteb identify tab $localX $localY]
	if {$tab ne ""} {
		set icon [$noteb tab $tab -image]
		if {$icon ne ""} {
			set iconW [expr { 4 + [image width $icon] }]
			if {$tab == 0} {
				set isIcon [expr {$localX < $iconW ? 1 : 0}]
			} else {
				set isIcon [expr [$noteb identify tab [expr $localX - $iconW] $localY] != $tab]
			}
		}
	}
	return [list $tab $isIcon]
}

# Relocate tabs in response to drag events.
proc ::docking::manage_motion_ {src_noteb x y} {
	lassign $::docking::motion_ src_tab
	unset ::docking::motion_
	if {$src_tab eq ""} { return }

	set dest_noteb [winfo containing $x $y]
	if {![info exists ::docking::tbs($dest_noteb)]} { return }

	set localX [expr $x-[winfo rootx $dest_noteb]]
	set localY [expr $y-[winfo rooty $dest_noteb]]
	set dest_pos [$dest_noteb identify tab $localX $localY]
	if {$dest_pos eq ""} { set dest_pos "end" }

	set wnd [lindex [$src_noteb tabs] $src_tab]
	if {$src_noteb eq $dest_noteb} {
		$dest_noteb insert $dest_pos $wnd
	} else {
		::docking::move_tab_ $wnd $src_noteb $dest_noteb $dest_pos
	}
}

# Special handling of a left click on a tab's icon: show an associated menu
# if it exists, otherwise close the window.
proc ::docking::manage_click_ {noteb x y localX localY} {
	lassign [::docking::identify_tab_ $noteb $localX $localY] tab isIcon
	if {$tab eq "" || ! $isIcon} { return }

	set wnd [lindex [$noteb tabs] $tab]
	lassign [::win::getMenu $wnd] menu
	if {$menu ne ""} {
		tk_popup $menu $x $y
	} else {
		::win::closeWindow $wnd
	}
}

# Right click on a tab label: show a windows management menu.
proc ::docking::manage_rightclick_ {noteb x y localX localY} {
	lassign [::docking::identify_tab_ $noteb $localX $localY] tab isIcon
	if {$tab eq "" || $isIcon} { return }

	$noteb select $tab

	set noteb_tabs [$noteb tabs]
	set state [expr { [llength $noteb_tabs] > 1 ? "normal" : "disabled" }]
	set wnd [lindex $noteb_tabs $tab]

	set m .ctxtMenu
	if { [winfo exists $m] } { destroy $m }
	menu $m -tearoff 0
	$m add command -label [ ::tr DockTop ] -state $state \
		-command "::docking::move_tab_ $wnd $noteb \[::docking::add_tbn $noteb n]"
	$m add command -label [ ::tr DockBottom ] -state $state \
		-command "::docking::move_tab_ $wnd $noteb \[::docking::add_tbn $noteb s]"
	$m add command -label [ ::tr DockLeft ] -state $state \
		-command "::docking::move_tab_ $wnd $noteb \[::docking::add_tbn $noteb w]"
	$m add command -label [ ::tr DockRight ] -state $state \
		-command "::docking::move_tab_ $wnd $noteb \[::docking::add_tbn $noteb e]"
	# Main board can not be closed or undocked
	if { $wnd != ".fdockmain" } {
		$m add separator
		$m add command -label [ ::tr Undock ] -command "::win::undockWindow $wnd $noteb"
		$m add command -label [ ::tr Close ] -command "::win::closeWindow $wnd"
	}
	tk_popup $m $x $y
}


################################################################################
# Layout management
################################################################################

# associates pw -> notebook list
array set ::docking::layout_notebook {}

# associates notebook -> list of tabs
array set ::docking::layout_tabs {}

################################################################################
# saves layout (bail out if some windows cannot be restored like FICS)
proc ::docking::layout_save { slot } {
  if {! $::docking::USE_DOCKING} { return }
  #TODo: Save FICS window

  # on Windows the geometry is false if the window was maximized (x and y offsets are the ones before the maximization)
  set geometry [wm geometry .]
  set ::docking::layout_list($slot) [list [list "MainWindowGeometry" $geometry] ]
  if {[wm state .] == "zoomed"} {
    if { [scan $geometry "%dx%d+%d+%d" w h x y] == 4 } {
      set geometry "${w}x${h}+0+0"
      set ::docking::layout_list($slot) [list [list "MainWindowGeometry" $geometry "zoomed"] ]
    }
  }

  lappend ::docking::layout_list($slot) [ layout_save_pw .pw ]

  # Append undocked windows
  foreach wnd [array names ::docking::notebook_name] {
    if {[winfo exists $wnd]} {
      lappend ::docking::layout_list($slot) [list [list "Toplevel" $wnd]]
    }
  }
}
################################################################################
proc ::docking::layout_save_pw {pw} {
  set ret {}
  
  # record sash position for each panes
  set sashpos {}
  for {set i 0} {$i < [ expr [llength [$pw panes]] -1]} {incr i} {
    lappend sashpos [$pw sashpos $i]
  }
  lappend ret [list $pw [$pw cget -orient ] $sashpos ]

  foreach p [$pw panes] {
    if {[winfo class $p] == "TNotebook"} {
      set wins [$p tabs]
      # Keep only the first glistWin in each pane
      set glistWins [lsearch -all -regexp $wins "\.(fdock)?glistWin\[0-9\]+"]
      set i [llength $glistWins]
      while {$i > 1} {
        incr i -1
        set remove [lindex $glistWins $i]
        set wins [lreplace $wins $remove $remove]
      }
      lappend ret [list "TNotebook" $p $wins ]

    } elseif {[winfo class $p] == "TPanedwindow"} {
      lappend ret [ list "TPanedwindow" [layout_save_pw $p] ]
    }
  }

  return $ret
}

################################################################################
# restores paned windows and internal notebooks
proc ::docking::layout_restore_pw { data } {
  foreach elt $data {
    set type [lindex $elt 0]
    
    if {$type == "MainWindowGeometry"} {
      wm geometry . [lindex $data 1]
      if {[lindex $data 2]  == "zoomed"} {
        if { $::windowsOS || $::macOS } {
          wm state . zoomed
        } else {
          wm attributes . -zoomed
        }
      }
      break

    } elseif {$type == "Toplevel"} {
        set ::docking::layout_dest_notebook "undocked"
        ::docking::create_window [lindex $elt 1]

    } elseif {$type == "TPanedwindow"} {
      layout_restore_pw [lindex $elt 1]
      
    } elseif {$type == "TNotebook"} {
      set name [lindex $elt 1]
      set tabs [lindex $elt 2]
      ::docking::layout_restore_nb $pw $name $tabs
      
    } else {
      set pw [lindex $elt 0]
      set orient [lindex $elt 1]
      # we have sash geometry
      if {[llength $elt] > 2} {
        lappend ::docking::sashpos [ list $pw [lindex $elt 2] ]
      }
      if { $pw == ".pw"} { continue }
      # build a new pw
      ttk::panedwindow $pw -orient $orient
      
      set parent [string range $pw 0 [expr [string last "." $pw ]-1 ] ]
      $parent add $pw -weight 1
    }
    
  }
  
}
################################################################################
# Sash position
################################################################################
proc ::docking::restoreGeometry {} {
  foreach elt $::docking::sashpos {
    set pw [lindex $elt 0]
    set sash [lindex $elt 1]
    set i 0
    foreach pos $sash {
      update
      $pw sashpos $i $pos
      incr i
    }
  }
}
################################################################################
# restores a notebook in a pre-existing panedwindow
# panewindow -> pw
# widget name -> name
# data to make tabs -> data (list of names which can be used to trigger the correct windows)
proc ::docking::layout_restore_nb { pw name tabs} {
  variable tbcnt
  variable tbs
  
  set nb [create_notebook_ $name]
  if {[scan $name ".tb%d" tmp] == 1} {
    if {$tmp >= $tbcnt} {
      set tbcnt [ expr $tmp +1]
    }
  }

  set tbs($nb) $pw
  $pw add $nb -weight 1
  set ::docking::tbs($nb) $pw
  lappend ::docking::restoring_nb $nb
  set ::docking::restoring_tabs($nb) $tabs
}

proc ::docking::create_window {wnd} {
      switch -regexp -matchvar regmatch -- $wnd {
      "\.(fdock)?pgnWin"              { ::pgn::OpenClose
                                        ::pgn::Refresh 1 }
      "\.(fdock)?baseWin"             { ::windows::switcher::Open }
      "\.(fdock)?bookWin"             { ::book::open }
      "\.(fdock)?ecograph"            { ::windows::eco::OpenClose }
      "\.(fdock)?tbWin"               { ::tb::Open }
      "\.(fdock)?commentWin"          { ::makeCommentWin }
      "\.(fdock)?ccWindow"            { ::CorrespondenceChess::CCWindow }
      "\.(fdock)?oprepWin"            { ::optable::makeReportWin }
      "\.(fdock)?plist"               { ::plist::Open }
      "\.(fdock)?tourney"             { ::tourney::Open }
      "\.(fdock)?sgraph"              { ::tools::graphs::score::Refresh }
      "\.(fdock)?glistWin([0-9]+)"    { ::windows::gamelist::Open }
      "\.(fdock)?treeWin([0-9]+)"     { ::tree::make [lindex $regmatch end]}
      "\.(fdock)?analysisWin([0-9]+)" { ::makeAnalysisWin [lindex $regmatch end] 0 0}
      "\.(fdock)?crosstabWin"         { crosstabWin }
      }
}

proc ::docking::restore_tabs {} {
  foreach nb $::docking::restoring_nb {
    foreach d $::docking::restoring_tabs($nb) {
      set ::docking::layout_dest_notebook $nb
      if {$d eq ".fdockmain"} {
        $nb add $d -text $::tr(Board)
        raise $d
      } else {
        ::docking::create_window $d
      }
      update
      update idletasks
    }
  }
  foreach nb $::docking::restoring_nb {
    set ::docking::restoring_tabs($nb) {}
  }
  set ::docking::restoring_nb {}

  # Bring the main board to the front
  set mainboard ".fdockmain"
  set maintab [::docking::find_tbn $mainboard]
  if {$maintab != ""} {
    raise $mainboard
    $maintab select $mainboard
  }
  raise .
}

################################################################################
proc ::docking::layout_restore { slot } {
  variable tbcnt
  variable tbs
  
  # if no layout recorded, retry with the last used
  if { $::docking::layout_list($slot) == {} } {
    if { $slot != "auto" } { ::docking::layout_restore "auto" }
    return
  }
  
  closeAll {.pw}
  set tbcnt 0
  array set ::docking::notebook_name {}
  array set ::docking::tbs {}
  set ::docking::sashpos {}
  if {[info exists ::docking::restoring_nb]} {
    foreach nb $::docking::restoring_nb {
      set ::docking::restoring_tabs($nb) {}
    }
    set ::docking::restoring_nb {}
  }

  foreach mainwnd $::docking::layout_list($slot) {
	layout_restore_pw $mainwnd
  }
  ::docking::restoreGeometry

  after idle ::docking::restore_tabs
}
################################################################################
# erase all mapped windows, except .main
proc ::docking::closeAll {pw} {
  
  foreach p [$pw panes] {
    if {[winfo class $p] == "TPanedwindow"} {
      ::docking::closeAll $p

    } elseif {[winfo class $p] == "TNotebook"} {
      foreach tabid [$p tabs] {
        $p forget $tabid
        if {$tabid != ".fdockmain"} {
          destroy $tabid
        }
        _cleanup_tabs $p
      }
    }

    destroy $p
  }
}

# themeToplevel
#   Standard initialize a toplevel window with unique attributes
#   y is used for windows with menu. They do not need a border on the top and call with y=0
proc themeToplevel {w {y 10}} {
    toplevel $w -background [ttk::style lookup . -background] -padx 10 -pady $y
}

