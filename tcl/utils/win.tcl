
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
  variable tbs
  
  if { ! $::docking::USE_DOCKING } { return }

  # if the destroy event came from a sub-widget, do nothing. Necessary because if a widget is destroyed, it sends a destroy event to
  # its containing window
  if { [ string last "." $origin ] > 0 } {
    return
  }
  
  set dockw ".fdock[string range $w 1 end]"
  
  catch {
    bind $w <Destroy> {}
    bind $dockw <Destroy> {}
  }
  
  # Maybe during Scid closing, some race conditions lead to exceptions ? In case, catch this by default
  catch {
    foreach nb [array names tbs] {
      if { [lsearch  [$nb tabs] $dockw ] != -1 } {
        $nb forget $dockw
        destroy $dockw
        ::docking::_cleanup_tabs $nb
        return
      }
    }
  }
  
  # Make sure the frame is destroyed
  if { [winfo exists $dockw]} {
    destroy $dockw
  }
  
  array unset ::docking::notebook_name $dockw
  
}
################################################################################
proc ::docking::isUndocked { w } {
  set w ".fdock[string range $w 1 end]"
  return [info exists ::docking::notebook_name($w)]
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
  
  # display window's menu (workaround for windows where the menu
  # of embedded toplevels is not displayed. The menu must be of the form $w.menu
  
  # if the tab has changed, don't display the menu at once (wait a second click)
  if { $::docking::changedTab($c_path) == 1 } {
    set ::docking::changedTab($c_path) 0
  } else  {
    # the tab was already active, show the menu
    set f [$c_path select]
    set m [getMenu $f]
    if { [winfo exists $m] } {
      tk_popup $m [winfo pointerx .] [winfo pointery .]
    }
  }
  
}
################################################################################
# returns the menu name of a toplevel window (must be in the form $w.menu)
# f is the frame embedding the toplevel (.fdock$w)
proc  ::docking::getMenu  {f} {
  if { [scan $f ".fdock%s" tl] != 1 || $f == ".fdockmain"} {
    return ""
  }
  return ".$tl.menu"
}
################################################################################
# Toggles menu visibility
# f is the frame embedding the toplevel (.fdock$w)
proc ::docking::setMenuVisibility  { f show } {
  
  if { [scan $f ".fdock%s" tl] != 1 || $f == ".fdockmain"} {
    return
  }
  set tl ".$tl"
  
  if { $show == "true" || $show == "1" } {
    $tl configure -menu "$tl.menu"
  } else  {
    $tl configure -menu {}
  }
  
}

################################################################################
proc  ::docking::tabChanged  {path} {
  update
  
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

bind TNotebook <ButtonPress-$::MB3> {::docking::ctx_menu %W}
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
proc ::docking::ctx_menu {w} {
  
  # HACK ! Because notebooks may also be used inside internal windows
  if {! [info exists ::docking::changedTab($w)] } {
    return
  }
  
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
  $mctxt add separator
  # Main board can not be closed or undocked
  if { [$w select] != ".fdockmain" } {
    $mctxt add command -label [ ::tr Undock ] -command "::docking::undock $w"
    $mctxt add command -label [ ::tr Close ] -command " ::docking::close $w"
  } else {
    $mctxt add checkbutton -label [::tr "showGameInfo"] -variable ::showGameInfo -command ::toggleGameInfo
    $mctxt add checkbutton -label [::tr "autoResizeBoard"] -variable ::autoResizeBoard -command ::docking::toggleAutoResizeBoard
  }
  tk_popup $mctxt [winfo pointerx .] [winfo pointery .]
}
################################################################################
proc ::docking::toggleAutoResizeBoard {} {
  ::resizeMainBoard
  set m .menu.options.board
  
  if {$::autoResizeBoard} {
    $m entryconfigure 0 -state disabled
  } else  {
    $m entryconfigure 0 -state normal
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
  setTabStatus
}
################################################################################
proc ::docking::undock {srctab} {
  variable tbs
  if {[llength [$srctab tabs]]==1 && [llength [array names tbs]]==1} { return }
  
  set f [$srctab select]
  if {! [winfo exists $f]} { return }
  
  set name [$srctab tab $f -text]
  set o [$srctab tab $f]
  
  $srctab forget $f
  _cleanup_tabs $srctab
  
  wm manage $f
  
  setMenuVisibility $f true
  
  wm title $f $name
  
  # Uncomment this code to dock windows that have been previously undocked
  # wm protocol $f WM_DELETE_WINDOW [namespace code [list __dock $f]]
  
  wm deiconify $f
  set ::docking::notebook_name($f) [list $srctab $o]
  setTabStatus
}

################################################################################
proc ::docking::__dock {wnd} {
  variable tbs
  
  setMenuVisibility $wnd false
  
  set name [wm title $wnd]
  wm withdraw $wnd
  wm forget $wnd
  
  set d  $::docking::notebook_name($wnd)
  
  set dsttab [lindex $d 0]
  set o [lindex $d 1]
  
  if {![winfo exists $dsttab]} {
    set dsttab [lindex [array names tbs] 0]
  }
  eval $dsttab add $wnd $o
  raise $wnd
  $dsttab select $wnd
}

################################################################################
proc ::docking::add_tab {path anchor args} {
  variable tbs
  
  if { $::docking::layout_dest_notebook == ""} {
    # scan all tabs to find the most suitable
    set dsttab {}
    
    foreach tb [array names tbs] {
      set x [winfo rootx $tb]
      set y [winfo rooty $tb]
      set w [winfo width $tb]
      set h [winfo height $tb]
      switch $anchor {
        n { set rel {$y < $_y} }
        w { set rel {$x < $_x} }
        s { set rel {$y > $_y} }
        e { set rel {$x > $_x} }
      }
      if {$dsttab==""} {
        set dsttab $tb
        set _x $x
        set _y $y
      } elseif { [expr $rel] } {
        set dsttab $tb
        set _x $x
        set _y $y
      }
    }
  } else  {
    set dsttab $::docking::layout_dest_notebook
  }
  
  set title $path
  eval [list $dsttab add $path] $args -text "$title"
  setMenuMark $dsttab $path
  $dsttab select $path
}
################################################################################
# display a blue triangle showing the tab has a menu associated
proc ::docking::setMenuMark { nb tab} {
  if { $tab == ".fdockpgnWin" || [string match "\.fdocktreeWin*" $tab] || $tab == ".fdockccWindow" || \
        $tab == ".fdockoprepWin" } {
    $nb tab $tab -image tb_menu -compound left
  }
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

################################################################################
# saves layout (bail out if some windows cannot be restored like FICS)
proc ::docking::layout_save { slot } {
  if {[winfo exists .fics]} {
    tk_messageBox -title Scid -icon question -type ok -message "Cannot save layout with FICS opened"
    return
  }
  if {[winfo exists .oprepWin]} {
    tk_messageBox -title Scid -icon question -type ok -message "Cannot save layout with opening report opened"
    return
  }
  
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
      lappend ret [list "TNotebook" $p [$p tabs] ]
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
              set ::docking::zoom "wm state . zoomed"
          } else {
              set ::docking::zoom "wm attributes . -zoomed"
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
    update idletasks
    set pw [lindex $elt 0]
    set sash [lindex $elt 1]
    set i 0
    foreach pos $sash {
      $pw sashpos $i $pos
      incr i
    }
  }
}
################################################################################
# restores a notebook in a pre-existing panedwindow
# panewindow -> pw
# widget name -> name
# data to make tabs -> data (list of names wich can be used to trigger the correct windows)
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
      if { $d == ".fdockmain" } {
        $nb add $d -text $::tr(Board)
        raise $d
      }
      if { $d == ".fdockpgnWin" } { ::pgn::OpenClose ; ::pgn::Refresh 1 }
      if { $d == ".fdockanalysisWin1" } { ::makeAnalysisWin 1 0 0}
      if { $d == ".fdockanalysisWin2" } { ::makeAnalysisWin 2 0 0}
      if { $d == ".fdockbaseWin" } {  ::windows::switcher::Open }
      if { $d == ".fdockbookWin" } {  ::book::open }
      if { $d == ".fdockecograph" } {  ::windows::eco::OpenClose }
      if { $d == ".fdocktbWin" } { ::tb::Open }
      if { $d == ".fdockcommentWin" } {  ::commenteditor::Open }
      if { [string first ".fdockglistWin" $d] != -1 } {::windows::gamelist::Open}
      if { $d == ".fdockccWindow" } {::CorrespondenceChess::CCWindow}
      if { [ scan $d ".fdocktreeWin%d" base ] == 1 } { ::tree::make $base}

      update idletasks
    }
  }

  set ::docking::layout_dest_notebook $old_dest
  foreach nb $::docking::restoring_nb {
    set ::docking::restoring_tabs($nb) {}
  }
  set ::docking::restoring_nb {}
}

################################################################################
proc ::docking::layout_restore { slot } {
  variable tbcnt
  variable tbs
  bind TNotebook <<NotebookTabChanged>> {}
  
  # if no layout recorded, return
  if { $::docking::layout_list($slot) == {} } {
    return
  }
  
  closeAll {.pw}
  set tbcnt 0
  set ::docking::zoom {}
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
  restoreGeometry
  
  array set ::docking::activeTab {}
  setTabStatus
  
  bind TNotebook <<NotebookTabChanged>> {::docking::tabChanged %W}
  eval $::docking::zoom
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
  }
  
}

################################################################################
if {$::docking::USE_DOCKING} {
  pack [ttk::panedwindow .pw -orient vertical] -fill both -expand true
  .pw add [ttk::notebook .nb] -weight 1
  
  set docking::tbs(.nb) .pw
  
}

