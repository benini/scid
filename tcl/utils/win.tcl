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


# Creates a docked/undocked window.
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

# if undocked window : sets the title of the toplevel window.
# if docked : sets the name of the tab.
proc setTitle { w title } {
	set nb [ ::docking::find_tbn $w ]
	if {$nb ne ""} {
		# in docked mode trim down title to spare space
		if {[string equal -length 6 $title "Scid: "]} {
			set title [string range $title 6 end]
		}
		$nb tab $w -text $title
	} else {
		set f ".fdock[string range $w 1 end]"
		if {[winfo exists $f]} { return [::setTitle $f $title] }

		wm title $w $title
	}
}

# if undocked window : sets the menu of the toplevel window.
# if docked : displays a menu icon in the tab.
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

# if undocked window : saves the geometry of the window.
# return true if the geometry was saved.
proc saveWinGeometry {w} {
	if {[winfo toplevel $w] == $w} {
		set ::winGeometry($w) [wm geometry $w]
		return 1
	}
	return 0
}

# Restores the geometry of the window.
# return true if a stored geometry was available.
proc restoreWinGeometry {w} {
	if {[info exists ::winGeometry($w)]} {
		wm geometry $w $::winGeometry($w)
		return 1
	}
	return 0
}

# Closes a window, independently of its docked state.
# If the window is undocked the window geometry is saved.
proc closeWindow {w} {
	set nb [ ::docking::find_tbn $w ]
	if {$nb ne ""} {
		::docking::close $nb
	} else {
		set f ".fdock[string range $w 1 end]"
		if {[winfo exists $f]} { return [::closeWindow $f] }

		saveWinGeometry $w
		destroy $w
	}
}


# ::utils::win::Centre
#
#   Centres a window on the screen.
#
proc ::utils::win::Centre {w} {
  if { $::docking::USE_DOCKING } { return }
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
  
  # keep tracks of active tab for each notebook
  array set activeTab {}
  # associates notebook with a boolean value indicating the tab has changed
  array set changedTab {}
  
  variable tbcnt 0
  array set notebook_name {}
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
    if {[get_class $tb] != "TNotebook"} {
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
  set ntb [ttk::notebook [winfo toplevel $pw].tb$tbcnt]
  incr tbcnt
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
    set tbn [ttk::notebook [winfo toplevel $pw].tb$tbcnt]
    incr tbcnt
    set tbs($tbn) $pw
    if {$i>=[llength [$pw panes]]} {
      $pw add $tbn -weight 1
    } else {
      $pw insert $i $tbn -weight 1
    }
  } elseif {$orient=="vertical" && ($anchor=="n" || $anchor=="s")} {
    set i [lsearch -exact [$pw panes] $tbn]
    if {$anchor=="s"} { incr i}
    set tbn [ttk::notebook [winfo toplevel $pw].tb$tbcnt]
    incr tbcnt
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
proc ::docking::get_class {path} {
  if {![winfo exists $path]} {
    return ""
  }
  return [lindex [bindtags $path] 1]
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
      ::docking::setTabStatus
    }
    after idle "if {[winfo exists $dockw]} { destroy $dockw }"
    catch { focus .main }
  }
}
################################################################################
proc ::docking::isUndocked { w } {
  set w ".fdock[string range $w 1 end]"
  return [expr { [winfo exists $w] && [winfo toplevel $w] == $w }]
}
################################################################################
proc ::docking::move_tab {srctab dsttab} {
  variable tbs
  # move tab
  set f [$srctab select]
  set o [$srctab tab $f]
  $srctab forget $f
  eval $dsttab add $f $o
  raise $f
  $dsttab select $f
  _cleanup_tabs $srctab
}

variable ::docking::c_path {}

################################################################################
proc ::docking::start_motion {path} {
  variable c_path
  if {[winfo exists .ctxtMenu]} {
    destroy .ctxtMenu
  }
  if {$path!=$c_path} {
    set c_path [find_tbn $path]
  }
}
################################################################################
proc ::docking::motion {path} {
  variable c_path
  if {$c_path==""} { return }
  
  $c_path configure -cursor exchange
}
################################################################################
proc ::docking::end_motion {w x y} {
  variable c_path
  
  bind TNotebook <ButtonRelease-1> [namespace code {::docking::show_menu %W %X %Y}]
  
  if {$c_path==""} { return }
  set path [winfo containing $x $y]
  if {$path == ""} {
    return
  }
  $path configure -cursor {}
  
  set t [find_tbn $path]
  if {$t!=""} {
    if {$t==$c_path} {
      # we stayed on the same notebook, so display the menu
      show_menu $w $x $y
      
      if {[$c_path identify [expr $x-[winfo rootx $c_path]] [expr $y-[winfo rooty $c_path]]]!=""} {
        set c_path {}
        return
      }
    }
    if {$t!=$c_path} {
      move_tab $c_path $t
    }
  }
  set c_path {}
  
  setTabStatus
  
}
################################################################################
proc ::docking::show_menu { path x y} {
  variable c_path
  
  if {[winfo exists .ctxtMenu]} {
    destroy .ctxtMenu
  }
  
  if {$path!=$c_path} {
    set c_path [find_tbn $path]
  }
  
  # HACK ! Because notebooks may also be used inside internal windows
  if {! [info exists ::docking::changedTab($c_path)] } {
    return
  }
  
  set localX [expr $x - [winfo rootx $path]]
  set localY [expr $y - [winfo rooty $path]]
  set tab [$path identify tab $localX $localY]
  if {$tab == ""} { return }
  set iconW 20
  if {$tab == 0} {
    set isIcon [expr {$localX < $iconW ? 1 : 0}]
  } else {
    set isIcon [expr [$path identify tab [expr $localX - $iconW] $localY] != $tab]
  }

  # display window's menu (workaround for windows where the menu
  # of embedded toplevels is not displayed. The menu must be of the form $w.menu
  if {$isIcon} {
    set f [lindex [$path tabs] $tab]
    set m [getMenu $f]
    if {$m ne ""} {
      tk_popup $m [winfo pointerx .] [winfo pointery .]
    } else {
      if {$f != ".fdockmain"} { ::docking::close $c_path }
    }
  }
  
}
################################################################################
# returns the menu name of a toplevel window (must be in the form $w.menu)
proc  ::docking::getMenu  {w} {
  if {[string equal -length 6 $w ".fdock"]} {
    set w [string replace $w 1 5]
  }
  set m "$w.menu"
  if {![winfo exists $m]} { return "" }
  return $m
}

################################################################################
proc  ::docking::tabChanged  {path} {
  update
  #TODO: the update is dangerous!
  #For example the windows may be destroyed
  if {! [winfo exists $path] } { return }
  
  # HACK ! Because notebooks may also be used inside internal windows
  if { ! [ info exists ::docking::activeTab($path)] } {
    return
  }

  if { [$path select] != $::docking::activeTab($path)} {
    set ::docking::activeTab($path) [$path select]
    set ::docking::changedTab($path) 1
  }
}

################################################################################

bind TNotebook <ButtonRelease-1> {::docking::show_menu %W %X %Y}

bind TNotebook <ButtonPress-1> +[ list ::docking::start_motion %W ]

bind TNotebook <B1-Motion> {
  ::docking::motion %W
  bind TNotebook <ButtonRelease-1> {::docking::end_motion %W %X %Y}
}

bind TNotebook <Escape> {
  if {[winfo exists .ctxtMenu]} {
    destroy .ctxtMenu
  }
}

bind TNotebook <ButtonPress-$::MB3> {::docking::ctx_menu %W %x %y}
bind TNotebook <<NotebookTabChanged>> {::docking::tabChanged %W}

################################################################################
#
################################################################################
proc ::docking::ctx_cmd {path anchor} {
  variable c_path
  
  if {$path!=$c_path} {
    set c_path [find_tbn $path]
  }
  
  if {$c_path==""} {
    puts "WARNING c_path null in ctx_cmd"
    return
  }
  
  set tbn [add_tbn $path $anchor]
  move_tab $c_path $tbn
  
  set c_path {}
  
  setTabStatus
}
################################################################################
proc ::docking::ctx_menu {w x y} {
  
  # HACK ! Because notebooks may also be used inside internal windows
  if {! [info exists ::docking::changedTab($w)] } {
    return
  }

  if {[catch { $w select @$x,$y }]} { return }
  update idletasks
  set mctxt .ctxtMenu
  if { [winfo exists $mctxt] } {
    destroy $mctxt
  }
  
  menu $mctxt -tearoff 0
  set state "normal"
  if { [llength [$w tabs]] <= 1} {
    set state "disabled"
  }
  $mctxt add command -label [ ::tr DockTop ] -state $state -command "::docking::ctx_cmd $w n"
  $mctxt add command -label [ ::tr DockBottom ] -state $state -command "::docking::ctx_cmd $w s"
  $mctxt add command -label [ ::tr DockLeft ] -state $state -command "::docking::ctx_cmd $w w"
  $mctxt add command -label [ ::tr DockRight ] -state $state -command "::docking::ctx_cmd $w e"
  # Main board can not be closed or undocked
  if { [$w select] != ".fdockmain" } {
    $mctxt add separator
    $mctxt add command -label [ ::tr Undock ] -command "::docking::undock $w"
    $mctxt add command -label [ ::tr Close ] -command " ::docking::close $w"
  }
  tk_popup $mctxt [winfo pointerx .] [winfo pointery .]
}
################################################################################
proc ::docking::close {w} {
  set tabid [$w select]
  if {[winfo exists $tabid]} {
    $w forget $tabid
    destroy $tabid
  }
  _cleanup_tabs $w
  setTabStatus
}
################################################################################
proc ::docking::undock {srctab} {
  variable tbs
  if {[llength [$srctab tabs]]==1 && [llength [array names tbs]]==1} { return }
  
  set f [$srctab select]
  if {! [winfo exists $f]} { return }
  
  set name [$srctab tab $f -text]
  $srctab forget $f
  _cleanup_tabs $srctab
  setTabStatus

  ::docking::undock_win $f $name

  set m [getMenu $f]
  if {$m ne ""} { ::setMenu $f $m }

  # Uncomment this code to allow the advanced docking/re-docking behavior
  # set ::docking::notebook_name($f) $srctab
}

proc ::docking::undock_win {w title} {
  wm manage $w
  wm title $w "Scid: $title"
  wm protocol $w WM_DELETE_WINDOW "closeWindow $w"
  wm deiconify $w
  if {![::restoreWinGeometry $w]} {
    ::setWinSize $w
    ::setWinLocation $w
  }
  focus $w
}

proc ::docking::dock {wnd} {
  ::saveWinGeometry $wnd
  set name [wm title $wnd]
  if {[string equal -length 6 $name "Scid: "]} {
    set name [string range $name 6 end]
  }

  wm forget $wnd

  set old_dest $::docking::layout_dest_notebook
  if {[winfo exists $::docking::notebook_name($wnd)]} {
    set ::docking::layout_dest_notebook $::docking::notebook_name($wnd)
  }
  unset ::docking::notebook_name($wnd)
  docking::add_tab "$wnd" $name
  set ::docking::layout_dest_notebook $old_dest

  set m [getMenu $wnd]
  if {$m ne ""} { ::setMenu $wnd $m }
}

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
proc ::docking::add_tab { {path} {title} } {
  variable tbs

  if { $::docking::layout_dest_notebook == ""} {
    set dsttab {}
    set best_fitting ""
    foreach tb [array names ::docking::tbs] {
      if {[::docking::get_class $tb] != "TNotebook"} { continue }

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
  } else  {
    set dsttab $::docking::layout_dest_notebook
  }

  $dsttab add $path -text "$title" -image tb_close -compound left
  $dsttab select $path
}

################################################################################
# Layout management
################################################################################

set ::docking::layout_tbcnt 0

# associates pw -> notebook list
array set ::docking::layout_notebook {}

# associates notebook -> list of tabs
array set ::docking::layout_tabs {}

# the notebook into which to create a new tab
set ::docking::layout_dest_notebook ""

# list of windows to be opened undocked
set ::docking::layout_undocked {}

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
  set ::docking::layout_undocked [array names ::docking::notebook_name]
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
    if {[get_class $p] == "TNotebook"} {
      set wins [$p tabs]
      if {[lsearch -exact $wins ".fdockmain"] != "-1"} {
        # Append the list of undocked windows
        foreach wnd [array names ::docking::notebook_name] {
          if {[winfo exists $wnd]} { lappend wins $wnd }
        }
      }
      # Keep only the first glistWin in each pane
      set glistWins [lsearch -all -regexp $wins "\.(fdock)?glistWin\[0-9\]+"]
      set i [llength $glistWins]
      while {$i > 1} {
        incr i -1
        set remove [lindex $glistWins $i]
        set wins [lreplace $wins $remove $remove]
      }
      lappend ret [list "TNotebook" $p $wins ]
    }
    if {[get_class $p] == "TPanedwindow"} {
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
      wm geometry . [lindex $elt 1]
      layout_restore_pw [lindex $data 1]
      if {[lindex $elt 2]  == "zoomed"} {
        if { $::windowsOS || $::macOS } {
          wm state . zoomed
        } else {
          wm attributes . -zoomed
        }
      }
      break
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
  
  set nb [ttk::notebook $name]
  incr tbcnt
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

proc ::docking::restore_tabs {} {
  set old_dest $::docking::layout_dest_notebook
  foreach nb $::docking::restoring_nb {
    foreach d $::docking::restoring_tabs($nb) {
      set ::docking::layout_dest_notebook $nb
      switch -regexp -matchvar regmatch -- $d {
      "\.fdockmain"                   { $nb add $d -text $::tr(Board)
                                        raise $d }
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
      }
      update
      update idletasks
    }
  }
  set ::docking::layout_dest_notebook $old_dest
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
  bind TNotebook <<NotebookTabChanged>> {}
  
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

  layout_restore_pw $::docking::layout_list($slot)
  ::docking::restoreGeometry

  array set ::docking::activeTab {}
  setTabStatus
  
  bind TNotebook <<NotebookTabChanged>> {::docking::tabChanged %W}
  after idle ::docking::restore_tabs
}
################################################################################
# for every notebook, keeps track of the last selected tab to see if the local menu can be popped up or not
proc ::docking::setTabStatus { } {
  variable tbs
  array set ::docking::activeTab {}
  array set ::docking::changedTab {}
  
  foreach nb [array names tbs] {
    set ::docking::activeTab($nb) [$nb select]
    set ::docking::changedTab($nb) 0
  }
  
}
################################################################################
# erase all mapped windows, except .main
proc ::docking::closeAll {pw} {
  
  foreach p [$pw panes] {
    
    if {[get_class $p] == "TPanedwindow"} {
      ::docking::closeAll $p
    }
    
    if {[get_class $p] == "TNotebook"} {
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

################################################################################
if {$::docking::USE_DOCKING} {
  pack [ttk::panedwindow .pw -orient vertical] -fill both -expand true
  .pw add [ttk::notebook .nb] -weight 1
  
  set docking::tbs(.nb) .pw
  
}

