# bookmark.tcl:
# Bookmarks list and Recently-used files list in Scid.

set bookmarks(data) {}
set bookmarks(subMenus) 0

set bookmarks(file) [file join $scidUserDir "scid.bkm"]
catch {source $bookmarks(file)}

namespace eval ::bookmarks {}

# ::bookmarks::postMenu:
#   Posts the bookmarks toolbar menu.
#
proc ::bookmarks::postMenu {} {
  tkMbPost .tb.bkm
  if {[::bookmarks::canAdd]} {
    .tb.bkm.menu activate 0
  } else {
    .tb.bkm.menu activate 2
  }
}

# ::bookmarks::refresh:
#   Updates all bookmarks submenus.
#
proc ::bookmarks::refresh {} {
  foreach menu {.menu.file.bookmarks .tb.bkm.menu} {
    ::bookmarks::refresh_menu $menu
  }
}

proc ::bookmarks::refresh_menu {menu} {
  global bookmarks helpMessage

  ::bookmarks::deleteChildren $menu
  $menu delete 0 end
  # $menu configure -disabledforeground [$menu cget -foreground]
  set len [llength $bookmarks(data)]
  $menu add command -label FileBookmarksAdd -command ::bookmarks::addCurrent
  set helpMessage($menu,0) FileBookmarksAdd
  $menu add cascade -label FileBookmarksFile -menu $menu.file
  menu $menu.file
  set helpMessage($menu,1) FileBookmarksFile
  if {! [::bookmarks::canAdd]} {
    $menu entryconfigure 0 -state disabled
    $menu entryconfigure 1 -state disabled
  }
  $menu add command -label FileBookmarksEdit -command ::bookmarks::edit
  set helpMessage($menu,2) FileBookmarksEdit
  if {$bookmarks(subMenus)} {
    set display List
    set newval 0
  } else {
    set display Sub
    set newval 1
  }
  $menu add command -label FileBookmarks$display \
    -command "set bookmarks(subMenus) $newval; ::bookmarks::refresh"
  set helpMessage($menu,3) FileBookmarks$display
  foreach tag [list Add File Edit $display] {
    configMenuText $menu FileBookmarks$tag FileBookmarks$tag $::language
  }
if {$len == 0} { return }
  $menu add separator

  set current $menu
  set inSubMenu 0
  set nfolders 0
  foreach entry $bookmarks(data) {
    if {$entry == ""} { continue }
    set isfolder [::bookmarks::isfolder $entry]

    if {$isfolder} {
      incr nfolders
      $menu.file add command -label [::bookmarks::text $entry] \
        -command "::bookmarks::addCurrent $nfolders"
    }

    if {! $bookmarks(subMenus)} {
      if {$isfolder} {
        $current add command -label [::bookmarks::itext $entry]
      } elseif {!$isfolder} {
        $current add command -label [::bookmarks::itext $entry] \
          -command [list ::bookmarks::go $entry]
      }
      continue
    }

    # Move out of submenu where necessary:
    if {$isfolder  &&  $inSubMenu} {
      set current [winfo parent $current]
    }

    if {$isfolder} {
      # Menu (folder) entry:
      set current [::bookmarks::newSubMenu $current $entry]
      set inSubMenu 1
    } else {
      # Bookmark entry:
      $current add command -label [::bookmarks::text $entry] \
        -command [list ::bookmarks::go $entry]
    }
  }
}

# ::bookmarks::canAdd:
#   Returns 1 if the current game can be added as a bookmark.
#   It must be in an open database, not a PGN file, and not game number 0.
#
proc ::bookmarks::canAdd {} {
  if {! [sc_base inUse]} { return 0 }
  if {[sc_game number] == 0} { return 0 }
  if {[sc_base current] == [sc_info clipbase]} { return 0 }
  if {[file pathtype [sc_base filename]] != "absolute"} { return 0 }
  foreach suffix {.pgn .PGN .pgn.gz} {
    if {[string match "*$suffix" [sc_base filename]]} { return 0 }
  }
  return 1
}

# ::bookmarks::addCurrent:
#   Adds the current game to the bookmarks list.
#
proc ::bookmarks::addCurrent {{folder 0}} {
  global bookmarks
  if {! [sc_base inUse]} {
    return 
  }
  set text [::bookmarks::new game]
  set len [llength $bookmarks(data)]
  set fcount 0
  for {set i 0} {$i < $len} {incr i} {
    if {[::bookmarks::isfolder [lindex $bookmarks(data) $i]]} {
      if {$fcount == $folder} { break }
      incr fcount
    }
  }
  set bookmarks(data) [linsert $bookmarks(data) $i $text]
  ::bookmarks::save
  ::bookmarks::refresh
}

# city:
#   Returns the city name given a full site.
#
proc city {site} {
  regsub { [A-Z][A-Z][A-Z]$} $site "" site
  return [string trim [surname $site]]
}

# ::bookmarks::new:
#   Returns a bookmarks list entry for the current game or a new folder.
#
proc ::bookmarks::new {type} {
  if {$type == "folder"} { return [list "f" ""] }
  set text "[file tail [sc_base filename]]: [sc_game info result], "
  append text "[surname [sc_game info white]] - "
  append text "[surname [sc_game info black]], "
  append text "[city [sc_game info site]] "
  set round [sc_game info round]
  if {$round != ""  &&  $round != "?"} { append text "($round) " }
  append text "[sc_game info year]"
  set list [list "g" $text]
  sc_game pgn
  lappend list [sc_base filename] [sc_game number] [sc_pos pgnOffset]
  lappend list [sc_game info white] [sc_game info black]
  lappend list [sc_game info year] [sc_game info site]
  lappend list [sc_game info round] [sc_game info result]
  return $list
}

# ::bookmarks::go:
#   Jumps to a selected bookmark.
#
proc ::bookmarks::go {entry} {
  if {[::bookmarks::isfolder $entry]} { return }
  set fname [lindex $entry 2]
  set gnum [lindex $entry 3]
  set ply [lindex $entry 4]
  set slot [sc_base slot $fname]
  if {$slot != 0} {
    sc_base switch $slot
  } else {
    busyCursor .
    if {[catch {openBase [file rootname $fname]} result]} {
      unbusyCursor .
      tk_messageBox -icon warning -type ok -parent . \
        -title "Scid" -message "Unable to load the database:\n$fname\n\n$result"
      return
    }
    unbusyCursor .
    set ::glist 1
    ::recentFiles::add "[file rootname $fname].si3"
  }
  # Find and load the best database game matching the bookmark:
  set white [lindex $entry 5]
  set black [lindex $entry 6]
  set year  [lindex $entry 7]
  set site  [lindex $entry 8]
  set round [lindex $entry 9]
  set result [lindex $entry 10]

  set best [sc_game find $gnum $white $black $site $round $year $result]
  if {[catch {sc_game load $best}]} {
    tk_messageBox -icon warning -type ok -parent . \
      -title "Scid" -message "Unable to load game number: $best"
  } else {
    sc_move pgn $ply
  }
  updateGList
  ::tree::refresh
  updateStatsWin
  updateMenuStates
  updateBoardAndPgn .board
  updateTitle
  updateStatusBar
}

# ::bookmarks::deleteChildren:
#   Deletes all submenus of a bookmark menu.
#
proc ::bookmarks::deleteChildren {w} {
  foreach child [winfo children $w] {
    ::bookmarks::deleteChildren $child
    destroy $child
  }
}

# ::bookmarks::newSubMenu:
#   Creates a new bookmark submenu.
#
proc ::bookmarks::newSubMenu {w entry} {
  set i 1
  while {[winfo exists $w.m$i]} { incr i }
  $w add cascade -label [::bookmarks::text $entry] -menu $w.m$i
  menu $w.m$i -tearoff 0
  return $w.m$i
}

# Globals used for bookmark editing:
#
set bookmarks(edit) ""
set bookmarks(ismenu) 0

# Button images for bookmark editing:

image create photo bookmark_up -data {
R0lGODdhGAAYAMIAALu7uwAAAMzM/5mZ/2ZmzP///zMzZgAAACwAAAAAGAAYAAADRgi63P4w
ykmrvTirEPQKwtBpYChmpUmMVVAI5kCsbfGqMy25dpzPLAfvNij+gBCDUokjLJUUQ9OAkRpn
1Mvz6el6v+AwOAEAOw==
}

image create photo bookmark_down -data {
R0lGODdhGAAYAMIAALu7uzMzZv///8zM/5mZ/2ZmzAAAAAAAACwAAAAAGAAYAAADSQi63P4w
ykmrvRiHzbcWw0AQRfCFY0l1ATiSLGQINCiSRZ4b0UyjOB1PMgvddIXhxABEKinM1C5jkD4v
1WSGYbhuv+CweExeJAAAOw==
}

# ::bookmarks::edit:
#   Creates the bookmark editing window.
#
proc ::bookmarks::edit {} {
  global bookmarks
  set w .bmedit
  if {[winfo exists $w]} { return }
  set bookmarks(old) $bookmarks(data)
  toplevel $w
  wm title $w "Scid: [tr FileBookmarksEdit]"
  wm transient $w .
  bind $w <F1> {helpWindow Bookmarks}
  entry $w.e -width 40 -foreground black -background white \
    -textvariable bookmarks(edit) -font font_Small -exportselection 0
  bind $w.e <FocusIn>  {.bmedit.e configure -background lightYellow}
  bind $w.e <FocusOut> {.bmedit.e configure -background white}

  trace variable bookmarks(edit) w ::bookmarks::edit_refresh
  pack $w.e -side top -fill x
  pack [frame $w.b2] -side bottom -fill x
  pack [frame $w.b1] -side bottom -fill x
  pack [frame $w.f] -side top -fill both -expand 1
  listbox $w.f.list -width 50 -height 10 -yscrollcommand "$w.f.ybar set" \
    -fg black -bg white -exportselection 0 \
    -selectbackground lightCyan2 -font font_Small -setgrid 1
  scrollbar $w.f.ybar -takefocus 0 -command "$w.f.list yview"
  bind $w.f.list <<ListboxSelect>>  ::bookmarks::edit_select
  pack $w.f.ybar -side right -fill y
  pack $w.f.list -side left -fill x -expand 1
  foreach entry $bookmarks(data) {
    $w.f.list insert end [::bookmarks::itext $entry]
  }
  button $w.b1.newFolder -text "New submenu" \
    -command {::bookmarks::edit_new folder}
  button $w.b1.newGame -text [tr FileBookmarksAdd] \
    -command {::bookmarks::edit_new game}
  if {! [::bookmarks::canAdd]} { $w.b1.newGame configure -state disabled }
  button $w.b1.delete -text $::tr(Delete)  -command ::bookmarks::edit_delete
  button $w.b2.up -image bookmark_up -command {::bookmarks::edit_move up}
  button $w.b2.down -image bookmark_down -command {::bookmarks::edit_move down}
  foreach i [list $w.b2.up $w.b2.down] {
    $i configure -padx 0 -pady 0 -borderwidth 1
  }
  button $w.b2.ok -text "OK" -command ::bookmarks::edit_done
  button $w.b2.cancel -text "Cancel" -command {
    set bookmarks(data) $bookmarks(old)
    catch {grab release .bmedit}
    destroy .bmedit
  }
  pack $w.b1.newFolder $w.b1.newGame $w.b1.delete -side left -padx 2 -pady 2
  pack $w.b2.up $w.b2.down -side left -padx 2 -pady 2
  pack $w.b2.cancel $w.b2.ok -side right -padx 2 -pady 2
  set bookmarks(edit) ""

  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
                 - [winfo vrootx .]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
                 - [winfo vrooty .]}]
  wm geom $w +$x+$y
  wm deiconify $w
  update
  catch {grab .bmedit}
}

# ::bookmarks::edit_done:
#    Updates the bookmarks and closes the bookmark editing window.
#
proc ::bookmarks::edit_done {} {
  catch {grab release .bmedit}
  destroy .bmedit
  ::bookmarks::save
  ::bookmarks::refresh
}

# ::bookmarks::edit_refresh:
#   Updates the bookmarks whenever the contents of the bookmark
#   editing entry box are changed.
#
proc ::bookmarks::edit_refresh {args} {
  global bookmarks
  set list .bmedit.f.list
  set sel [lindex [$list curselection] 0]
  if {$sel == ""} { return }
  set text $bookmarks(edit)
  set e [lindex $bookmarks(data) $sel]
  set e [::bookmarks::settext $e $text]
  set text [::bookmarks::itext $e]
  set bookmarks(data) [lreplace $bookmarks(data) $sel $sel $e]
  $list insert $sel $text
  $list delete [expr $sel + 1]
  $list selection clear 0 end
  $list selection set $sel
}

# ::bookmarks::edit_select:
#   Sets the bookmark editing entry box when a bookmark is selected.
#
proc ::bookmarks::edit_select {{sel ""}} {
  global bookmarks
  set list .bmedit.f.list
  set sel [lindex [$list curselection] 0]
  if {$sel == ""} {
    .bmedit.e delete 0 end
    return
  }
  if {$sel >= [llength $bookmarks(data)]} {
    $list selection clear 0 end
    set bookmarks(edit) ""
    return
  }
  set e [lindex $bookmarks(data) $sel]
  set bookmarks(ismenu) [::bookmarks::isfolder $e]
  set bookmarks(edit) [::bookmarks::text $e]
}

# ::bookmarks::isfolder:
#   Returns 1 if this bookmark entry is a folder (submenu).
#
proc ::bookmarks::isfolder {entry} {
  if {[lindex $entry 0] == "f"} { return 1 }
  return 0
}

# ::bookmarks::text:
#   Returns the entry text of a bookmark.
#
proc ::bookmarks::text {entry} {
  return [lindex $entry 1]
}

proc ::bookmarks::itext {entry} {
  set text ""
  if {[lindex $entry 0] == "f"} {
    append text "\[[lindex $entry 1]\]"
  } else {
    append text "    [lindex $entry 1]"
  }
  return $text
}

proc ::bookmarks::settext {entry text} {
  return [lreplace $entry 1 1 $text]
}

# ::bookmarks::edit_move:
#   Moves the selected bookmark "up" or "down" one place.
#
proc ::bookmarks::edit_move {{dir "up"}} {
  global bookmarks
  set w .bmedit
  set list $w.f.list
  set sel [lindex [$list curselection] 0]
  if {$sel == ""} { return }
  set e [lindex $bookmarks(data) $sel]
  set text [::bookmarks::itext $e]
  set newsel $sel
  if {$dir == "up"} {
    incr newsel -1
    if {$newsel < 0} { return }
  } else {
    incr newsel
    if {$newsel >= [$list index end]} { return }
  }
  set bookmarks(data) [lreplace $bookmarks(data) $sel $sel]
  set bookmarks(data) [linsert $bookmarks(data) $newsel $e]
  $list selection clear 0 end
  $list delete $sel
  $list insert $newsel $text
  $list selection set $newsel
}

# ::bookmarks::edit_delete:
#   Deletes the selected bookmark.
#
proc ::bookmarks::edit_delete {} {
  global bookmarks
  set w .bmedit
  set list $w.f.list
  set sel [lindex [$list curselection] 0]
  if {$sel == ""} { return }
  set bookmarks(data) [lreplace $bookmarks(data) $sel $sel]
  $list selection clear 0 end
  $list delete $sel
  set bookmarks(edit) ""
}

# ::bookmarks::edit_new:
#   Inserts a new entry ("folder" for a submenu or "game" for the
#   current game) after the selected bookmark.
#
proc ::bookmarks::edit_new {{type "folder"}} {
  global bookmarks
  set w .bmedit
  set list $w.f.list
  set folder 0
  if {[string index $type 0] == "f"} {
    set folder 1
    set entry [::bookmarks::new folder]
  } else {
    set entry [::bookmarks::new game]
  }
  set sel [lindex [$list curselection] 0]
  if {$sel == ""} {
    lappend bookmarks(data) $entry
    set sel [$list index end]
    $list insert end [::bookmarks::itext $entry]
    $list selection clear 0 end
    $list selection set $sel
    $list see $sel
    ::bookmarks::edit_select
    return
  }
  incr sel
  set bookmarks(data) [linsert $bookmarks(data) $sel $entry]
  $list insert $sel [::bookmarks::itext $entry]
  $list selection clear 0 end
  $list selection set $sel
  $list see $sel
  ::bookmarks::edit_select
}

# ::bookmarks::save:
#   Saves the bookmarks file, reporting any error in a message box if
#   reportError is true.
#
proc ::bookmarks::save {{reportError 0}} {
  global bookmarks
  set f {}
  if  {[catch {open [file nativename $bookmarks(file)] w} f]} {
    if {$reportError} {
      tk_messageBox -title "Scid" -type ok -icon warning \
        -message "Unable to write bookmarks file: $bookmarks(file)\n$f"
    }
    return
  }
  puts $f "# Scid [sc_info version] bookmarks file\n"
  foreach i {subMenus data} {
    puts $f "set bookmarks($i) [list [set bookmarks($i)]]"
    puts $f ""
  }
  close $f
}


####################
# Recent files list:

set recentFiles(limit) 10   ;# Maximum number of recent files to remember.
set recentFiles(menu)   5   ;# Maximum number of files to show in File menu.
set recentFiles(extra)  5   ;# Maximum number of files to show in extra menu.
set recentFiles(data)  {}   ;# List of recently used files.

set recentFiles(file) [file join $scidUserDir "scid.rfl"]
catch {source $recentFiles(file)}

namespace eval ::recentFiles {}

# ::recentFiles::save
#   Saves the recent-file-list file, reporting any error in a message box
#   if reportError is true.
#
proc ::recentFiles::save {{reportError 0}} {
  global recentFiles
  set f {}
  if  {[catch {open [file nativename $recentFiles(file)] w} f]} {
    if {$reportError} {
      tk_messageBox -title "Scid" -type ok -icon warning \
        -message "Unable to write file: $recentFiles(file)\n$f"
    }
    return
  }
  puts $f "# Scid [sc_info version] recent files list"
  puts $f ""
  foreach i {limit menu extra data} {
    puts $f "set recentFiles($i) [list [set recentFiles($i)]]"
    puts $f ""
  }
  close $f
}

# ::recentFiles::add
#   Adds a file to the recent files list, or moves it to the front
#   if that file is already in the list.
#
proc ::recentFiles::add {fname} {
  global recentFiles
  set rlist $recentFiles(data)

  # Remove file ot be added from its current place in the
  # list, if it is there:
  while {1} {
    set idx [lsearch -exact $rlist $fname]
    if {$idx < 0} { break }
    set rlist [lreplace $rlist $idx $idx]
  }

  # Insert the current file at the start of the list:
  set rlist [linsert $rlist 0 $fname]

  # Trim the list if necessary:
  if {[llength $rlist] < $recentFiles(limit)} {
    set rlist [lrange $rlist 0 [expr $recentFiles(limit) - 1]]
  }

  set recentFiles(data) $rlist
  # ::recentFiles::save
}

# ::recentFiles::load
#   Loads the selected recent file, or swtches to its database slot
#   if it is already open.
#
proc ::recentFiles::load {fname} {
  set rname $fname
  if {[file extension $rname] == ".si3"} {
    set rname [file rootname $rname]
  }
  for {set i 1} {$i <= [sc_base count total]} {incr i} {
    if {$rname == [sc_base filename $i]} {
      sc_base switch $i
      ::recentFiles::add $fname
      updateGList
      ::tree::refresh
      updateStatsWin
      updateMenuStates
      updateBoardAndPgn .board
      updateTitle
      updateStatusBar
      return
    }
  }
  fileOpen $fname
}

# ::recentFiles::show
#   Adds the recent files to the end of the specified menu.
#   Returns the number of menu entries added.
#
proc ::recentFiles::show {menu} {
  global recentFiles
  set idx [$menu index end]
  incr idx
  set rlist $recentFiles(data)
  set nfiles [llength $rlist]
  set nExtraFiles [expr $nfiles - $recentFiles(menu)]
  if {$nfiles > $recentFiles(menu)} { set nfiles $recentFiles(menu) }
  if {$nExtraFiles > $recentFiles(extra)} {
    set nExtraFiles $recentFiles(extra)
  }
  if {$nExtraFiles < 0} { set nExtraFiles 0 }

  # Add menu commands for the most recent files:

  for {set i 0} {$i < $nfiles} {incr i} {
    set fname [lindex $rlist $i]
    set mname [::recentFiles::menuname $fname]
    set text [file tail $fname]
    set num [expr $i + 1]
    set underline -1
    if {$num <= 9} { set underline 0 }
    if {$num == 10} { set underline 1 }
    $menu add command -label "$num: $mname" -underline $underline \
      -command [list ::recentFiles::load $fname]
    set ::helpMessage($menu,$idx) "  $fname"
    incr idx
  }

  # If no extra submenu of recent files is needed, return now:
  if {$nExtraFiles <= 0} { return $nfiles }

  # Now add the extra submenu of files:
  catch {destroy $menu.recentFiles}
  menu $menu.recentFiles
  $menu add cascade -label "..." -underline 0 -menu $menu.recentFiles
  set i $nfiles
  for {set extra 0} {$extra < $nExtraFiles} {incr extra} {
    set fname [lindex $rlist $i]
    incr i
    set mname [::recentFiles::menuname $fname]
    set text [file tail $fname]
    set num [expr $extra + 1]
    set underline -1
    if {$num <= 9} { set underline 0 }
    if {$num == 10} { set underline 1 }
    $menu.recentFiles add command -label "$num: $mname" -underline $underline \
      -command [list ::recentFiles::load $fname]
    set ::helpMessage($menu.recentFiles,$extra) "  $fname"
  }
  return [expr $nfiles + 1]
}

# ::recentFiles::menuname
#   Given a full-path filename, returns a possibly shortened
#   version suitable for displaying in a menu, such as
#   "..../my/files/abc.pgn" instead of "/long/path/to/my/files/abc.pgn"
#
proc ::recentFiles::menuname {fname} {
  set mname $fname
  if {[file extension $mname] == ".si3"} {
    set mname [file rootname $mname]
  }
  if {[string length $mname] < 25} { return $mname }

  # Generate a menu name " ..../path/filename" for the file:
  set dir [file dirname $fname]
  while {1} {
    set tail [file join [file tail $dir] $mname]
    set dir [file dirname $dir]
    if {[string length $tail] > 20} { break }
    set mname $tail
  }
  set mname [file join .... $mname]
  return $mname
}

# ::recentFiles::configure
#   Produces a dialog box for configuring the number of recent files
#   to display in the File menu and in a submenu.
#
proc ::recentFiles::configure {} {
  global recentFiles
  set recentFiles(temp_menu) $recentFiles(menu)
  set recentFiles(temp_extra) $recentFiles(extra)
  set w .recentFilesDlg
  toplevel $w 
  wm title $w "Scid: [tr OptionsRecent]"
  label $w.lmenu -text $::tr(RecentFilesMenu)
  scale $w.menu -variable recentFiles(temp_menu) -from 0 -to 10 -length 250 \
    -orient horizontal -showvalue 0 -tickinterval 1 -font font_Small
  frame $w.sep -height 4
  label $w.lextra -text $::tr(RecentFilesExtra)
  scale $w.extra -variable recentFiles(temp_extra) -from 0 -to 10 -length 250 \
    -orient horizontal -showvalue 0 -tickinterval 1 -font font_Small
  pack $w.lmenu $w.menu $w.sep $w.lextra $w.extra -side top -padx 10
  addHorizontalRule $w
  pack [frame $w.b] -side bottom
  button $w.b.ok -text "OK" -command {
    set recentFiles(menu) $recentFiles(temp_menu)
    set recentFiles(extra) $recentFiles(temp_extra)
    catch {grab release .recentFilesDlg}
    destroy .recentFilesDlg
    ::recentFiles::save
    updateMenuStates
  }
  button $w.b.cancel -text $::tr(Cancel) \
    -command "catch {grab release $w}; destroy $w"
  pack $w.b.cancel $w.b.ok -side right -padx 5 -pady 5
  catch {grab $w}
}


# End of file: bookmark.tcl
