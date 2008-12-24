
########################################################################
### Games list window

set ::windows::gamelist::isOpen 0
set glstart 1
set glSelection 0
set glNumber 0

array set ::windows::gamelist::names {
  g Number
  f Filtered
  w White
  W WElo
  b Black
  B BElo
  e Event
  s Site
  n Round
  d Date
  y Year
  E EDate
  r Result
  m Length
  c Country
  o ECO
  O Opening
  F EndMaterial
  D Deleted
  U Flags
  V Vars
  C Comments
  A Annos
  S Start
}

# glistExtra is the window that displays the starting moves of a
# game when the middle mouse button is pressed in the game list window.

toplevel .glistExtra
wm overrideredirect .glistExtra 1
wm withdraw .glistExtra
text .glistExtra.text -font font_Small -background lightYellow \
    -width 40 -height 8 -wrap word -relief solid -borderwidth 1
pack .glistExtra.text -side top

set glistMaxWidth 30

set ::windows::gamelist::findtext ""
set ::windows::gamelist::goto ""
trace variable ::windows::gamelist::goto w {::utils::validate::Regexp {^[0-9]*$}}


proc ::windows::gamelist::FindText {} {
  global glstart
  variable findtext
  busyCursor .glistWin 1
  ::utils::history::AddEntry ::windows::gamelist::findtext $findtext
  set temp [sc_filter textfind $glstart $findtext]
  busyCursor .glistWin 0
  if {$temp < 1} { set temp 1 }
  set glstart $temp
  ::windows::gamelist::Refresh
}

proc ::windows::gamelist::ReOpen {} {
  global glstart glistSize highcolor glSelection helpMessage
  global glistFields glNumber buttoncolor
  set w .glistWin
  
  bind $w <Configure> {}
  set oldDestroy [bind $w <Destroy>]
  bind $w <Destroy> {}
  
  # erase the window
  foreach c [winfo children $w] {
    destroy $c
  }
  
  # bind $w <Destroy> $oldDestroy
  
  # Pack buttons frame first:
  pack [ttk::frame $w.b] -side bottom -fill x -expand 1 -ipady 5 ;# -padx 10
  scale $w.scale -from 1 -length 250 -orient horiz -variable glstart -showvalue 0 -command ::windows::gamelist::SetStart \
      -bigincrement $glistSize -takefocus 0 -width 10 -troughcolor $buttoncolor
  pack $w.scale -side bottom -fill x
  frame $w.columns -takefocus 1 -highlightcolor black ;# -highlightthickness 2
  pack $w.columns -side top -expand yes -fill both
  
  # Make each column in the listing:
  foreach i $glistFields {
    set code [lindex $i 0]
    set width [lindex $i 1]
    set justify [lindex $i 2]
    set fgcolor [lindex $i 3]
    set sep [lindex $i 4]
    frame $w.c$code
    
    if {[info exists ::windows::gamelist::names($code)]} {
      set name $::windows::gamelist::names($code)
    }
    if {[info exists ::tr(Glist$name)]} { set name $::tr(Glist$name) }
    
    # Each heading is a label:
    ttk::label $w.c$code.header -foreground darkBlue -width $width -font font_Small -relief flat -background gray90 \
        -text $name -anchor w
    ::utils::tooltip::Set $w.c$code.header $name
    set helpMessage(E,$w.c$code.header) {Press the left or right mouse button here for a configuration menu}
    
    bind $w.c$code.header <Control-ButtonPress-3> "incrGLwidth $code; break"
    bind $w.c$code.header <Control-ButtonPress-1> "decrGLwidth $code; break"
    bind $w.c$code.header <Shift-ButtonPress-3> "incrGLwidth $code; break"
    bind $w.c$code.header <Shift-ButtonPress-1> "decrGLwidth $code; break"
    bind $w.c$code.header <ButtonPress-1> "popupGLconfig $code %x %y %X %Y"
    bind $w.c$code.header <ButtonPress-3> "popupGLconfig $code %x %y %X %Y"
    
    pack $w.c$code -in $w.columns -side left -expand yes -fill both -padx 0
    
    pack $w.c$code.header -side top -fill x -padx 2
    addHorizontalRule $w.c$code 1 flat
    
    text $w.c$code.text -background white -width $width -height $glistSize -font font_Small -relief flat \
        -foreground $fgcolor -wrap none -setgrid 1 -cursor top_left_arrow
    $w.c$code.text tag configure align -justify $justify -foreground $fgcolor
    $w.c$code.text tag configure highlight -background lightBlue
    $w.c$code.text tag configure current -background lightYellow2
    $w.c$code.text tag configure underline -underline true
    
    bind $w.c$code.text <Button1-Motion> "break"
    bind $w.c$code.text <Button2-Motion> "break"
    bind $w.c$code.text <Double-Button-1> "::windows::gamelist::SetSelection $code %x %y; ::game::Load \$glNumber; break"
    bind $w.c$code.text <Button-1> "::windows::gamelist::SetSelection $code %x %y; ::windows::gamelist::Highlight \$glSelection; break"
    bind $w.c$code.text <ButtonRelease-1> "::windows::gamelist::SetSelection $code %x %y; ::windows::gamelist::Dehighlight; break"
    
    bind $w.c$code.text <ButtonPress-3> "popupGLmenu $code %x %y %X %Y"
    
    bind $w.c$code.text <ButtonPress-2> "::windows::gamelist::SetSelection $code %x %y; ::windows::gamelist::ShowMoves %X %Y; break"
    bind $w.c$code.text <ButtonRelease-2> "wm withdraw .glistExtra; ::windows::gamelist::Dehighlight; break"
    
    pack $w.c$code.text -side top -expand true -fill both
    if {$sep} { addVerticalRule $w.columns 1 flat }
  }
  
  menu $w.config -tearoff 0
  $w.config add cascade -label $::tr(GlistMoveField) -menu $w.config.move
  menu $w.config.move -tearoff 0
  $w.config add command -label $::tr(GlistEditField...)
  $w.config add cascade -label $::tr(GlistAddField) -menu $w.config.insert
  menu $w.config.insert -tearoff 0
  $w.config add command -label $::tr(GlistDeleteField)
  
  menu $w.popup -tearoff 0
  $w.popup add command -label $::tr(BrowseGame) -command {::gbrowser::new 0 $glNumber}
  $w.popup add command -label $::tr(LoadGame) -command {::game::Load $glNumber}
  $w.popup add command -label $::tr(MergeGame) -command mergeGame
  $w.popup add separator
  $w.popup add command -label $::tr(GlistRemoveThisGameFromFilter) -command removeFromFilter
  $w.popup add command -label $::tr(GlistRemoveGameAndAboveFromFilter) -command {removeFromFilter up}
  $w.popup add command -label $::tr(GlistRemoveGameAndBelowFromFilter) -command {removeFromFilter down}
  #when changing here the menu entry then change index numbers in proc popupGLmenu also
  $w.popup add separator
  $w.popup add command -label $::tr(GlistDeleteGame) -command {::windows::gamelist::ToggleFlag delete}
  $w.popup add command -label $::tr(GlistDeleteAllGames) -command {catch {sc_game flag delete filter 1}; ::windows::gamelist::Refresh}
  $w.popup add command -label $::tr(GlistUndeleteAllGames) -command {catch {sc_game flag delete filter 0}; ::windows::gamelist::Refresh}
  
  ttk::button $w.b.start -image tb_start -style Pad0.Small.TButton -command {set glstart 1; ::windows::gamelist::Refresh}
  set helpMessage(E,$w.b.start) {Go to the first page of games}
  
  ttk::button $w.b.pgup -image tb_prev -style Pad0.Small.TButton -command {
    set glstart [expr {$glstart - $glistSize}];
    if {$glstart < 1} { set glstart 1 };
    ::windows::gamelist::Refresh
  }
  set helpMessage(E,$w.b.pgup) {Previous page of games}
  
  ttk::button $w.b.pgdn -image tb_next  -style Pad0.Small.TButton -command {
    set glstart [expr {$glstart + $glistSize}];
    if {$glstart > [sc_filter count] } {
      set glstart [sc_filter count]
    }
    if {$glstart < 1} { set glstart 1 }
    ::windows::gamelist::Refresh
  }
  set helpMessage(E,$w.b.pgdn) {Next page of games}
  
  ttk::button $w.b.end -image tb_end  -style Pad0.Small.TButton -command {
    set glstart [expr {[sc_filter count] - $glistSize + 1}]
    if {$glstart < 1} { set glstart 1}
    ::windows::gamelist::Refresh
  }
  set helpMessage(E,$w.b.end) {Go to the last page of games}
  
  ttk::button $w.b.current -textvar ::tr(Current) -style Pad0.Small.TButton -command {
    set glstart [sc_filter locate [sc_game number]]
    if {$glstart < 1} { set glstart 1}
    ::windows::gamelist::Refresh
  }
  
  bind $w <Up> {
    set glstart [expr {$glstart - 1}]
    if {$glstart < 1} { set glstart 1 }
    ::windows::gamelist::Refresh
  }
  bind $w <Down> {
    set glstart [expr {$glstart + 1}]
    if {$glstart > [sc_filter count] } {
      set glstart [sc_filter count]
    }
    ::windows::gamelist::Refresh
  }
  
  bind $w <Home>  "$w.b.start invoke"
  bind $w <End>   "$w.b.end invoke"
  bind $w <Prior> "$w.b.pgup invoke"
  bind $w <Next>  "$w.b.pgdn invoke"
  
  ttk::label $w.b.gotolabel -textvar ::tr(GlistGameNumber:)
  ttk::entry $w.b.goto -width 8 -textvariable ::windows::gamelist::goto ;# -bg white
  bind $w.b.goto <Home> "$w.b.start invoke; break"
  bind $w.b.goto <End> "$w.b.end invoke; break"
  bind $w.b.goto <Return> {
    set glstart [sc_filter locate $::windows::gamelist::goto]
    if {$glstart < 1} { set glstart 1}
    set ::windows::gamelist::goto ""
    ::windows::gamelist::Refresh
  }
  
  ttk::label $w.b.findlabel -textvar ::tr(GlistFindText:)
  ttk::combobox $w.b.find -width 15 -textvariable ::windows::gamelist::findtext
  ::utils::history::SetCombobox ::windows::gamelist::findtext $w.b.find
  bind $w.b.find <Return> ::windows::gamelist::FindText
  bind $w.b.find <Home> "$w.b.find icursor 0; break"
  bind $w.b.find <End> "$w.b.find icursor end; break"
  
  ttk::frame $w.b.space -width 0.25c
  ttk::frame $w.b.space2 -width 0.25c
  
  ttk::button $w.b.export -textvar ::tr(Save...) -style Pad0.Small.TButton -command openExportGList
  ttk::button $w.b.help -textvar ::tr(Help) -style Pad0.Small.TButton -command { helpWindow GameList }
  ttk::button $w.b.close -textvar ::tr(Close) -style Pad0.Small.TButton -command { focus .; destroy .glistWin }
  
  pack $w.b.start $w.b.pgup $w.b.pgdn $w.b.end $w.b.current -side left -padx 1
  pack $w.b.space $w.b.gotolabel $w.b.goto -side left
  pack $w.b.space2 $w.b.findlabel $w.b.find -side left
  pack $w.b.close $w.b.help $w.b.export -side right -padx 5
  
  set ::windows::gamelist::isOpen 1
  bind $w <F1> { helpWindow GameList }
  bind $w <Destroy> { set ::windows::gamelist::isOpen 0 }
  bind $w <Escape> "$w.b.close invoke"
  standardShortcuts $w
  ::createToplevelFinalize $w
  
  # MouseWheel bindings:
  bind $w <MouseWheel> {::windows::gamelist::Scroll [expr {- (%D / 120)}]}
  if {! $::windowsOS} {
    bind $w <Button-4> {::windows::gamelist::Scroll -1}
    bind $w <Button-5> {::windows::gamelist::Scroll 1}
  }
  
  # Binding to reset glistSize when the window is resized:
  # The way this is done is very ugly, but the only way I could
  # find that actually works.
  # Set temp to window geometry (e.g. 80x20+...) and then
  # extract the part between the "x" and the first "+" or "-":
  bind $w <Configure> { ::docking::handleConfigureEvent ::windows::gamelist::Resize }
  
  wm iconname $w "Scid: [tr WindowsGList]"
  ::windows::gamelist::Refresh
  focus $w.b.goto
  
}

proc ::windows::gamelist::Resize {} {
    global glistSize glistFields
    set w .glistWin
    recordWinSize .glistWin
    set temp [wm geometry .glistWin]
    set temp [string range $temp [expr {[string first "x" $temp] + 1}] end]
    set idx [string first "+" $temp]
    if {$idx != -1} {
      set temp [string range $temp 0 [expr {$idx - 1}]]
    }
    set idx [string first "-" $temp]
    if {$idx != -1} {
      set temp [string range $temp 0 [expr {$idx - 1}]]
    }
    if {$temp != $glistSize && $temp > 0} {
      set glistSize $temp
      foreach i $glistFields {
        set code [lindex $i 0]
        .glistWin.c$code.text configure -height $glistSize
      }
      ::windows::gamelist::Refresh
    }
}

proc ::windows::gamelist::Open {} {
  global glstart glistSize highcolor glSelection helpMessage
  global glistFields glNumber buttoncolor
  if {[winfo exists .glistWin]} {
    focus .
    destroy .glistWin
    set ::windows::gamelist::isOpen 0
    return
  }
  set w .glistWin
  
  ::createToplevel $w
  
  # Window is only directly resizable vertically:
  wm resizable $w false true
  setWinLocation $w
  
  ::windows::gamelist::ReOpen
  event generate $w <Configure>
}

proc ::windows::gamelist::Scroll {nlines} {
  global glstart
  set glstart [expr {$glstart + $nlines}]
  if {$glstart > [sc_filter count] } {
    set glstart [sc_filter count]
  }
  if {$glstart < 1} { set glstart 1 }
  ::windows::gamelist::Refresh
}

proc ::windows::gamelist::SetSelection {code xcoord ycoord} {
  global glSelection glNumber
  set glSelection [expr {int([.glistWin.c$code.text index @$xcoord,$ycoord])}]
  set glNumber [.glistWin.cg.text get $glSelection.0 $glSelection.end]
}

proc incrGLwidth {code} {
  global glistSize glistMaxWidth
  set w .glistWin.c$code
  set width [$w.header cget -width]
  if {$width >= $glistMaxWidth} { return }
  incr width
  $w.header configure -width $width
  $w.text configure -width $width
  updateGLwidths $code $width
}

proc decrGLwidth {code} {
  global glistSize
  set w .glistWin.c$code
  set width [$w.header cget -width]
  if {$width <= 1} { return }
  incr width -1
  $w.header configure -width $width
  $w.text configure -width $width
  updateGLwidths $code $width
}

proc updateGLwidths {code width} {
  global glistFields
  set len [llength $glistFields]
  for {set i 0} {$i < $len} {incr i} {
    set column [lindex $glistFields $i]
    set tcode [lindex $column 0]
    if {$tcode != $code} { continue }
    set oldwidth [lindex $column 1]
    if {$oldwidth != $width} {
      set column [lreplace $column 1 1 $width]
      set glistFields [lreplace $glistFields $i $i $column]
    }
  }
}

proc ::windows::gamelist::Dehighlight {} {
  global glistFields glistSize
  foreach column $glistFields {
    set code [lindex $column 0]
    .glistWin.c$code.text tag remove highlight 1.0 end
  }
}

proc ::windows::gamelist::Highlight {linenum} {
  global glistFields glistSize
  foreach column $glistFields {
    set code [lindex $column 0]
    .glistWin.c$code.text tag remove highlight 1.0 end
    .glistWin.c$code.text tag add highlight $linenum.0 [expr {$linenum+1}].0
  }
}

proc popupGLconfig {code xcoord ycoord xscreen yscreen} {
  global glistFields glistAllFields
  set menu .glistWin.config
  
  # Move-field submenu:
  $menu.move delete 0 end
  $menu.move add command -label "|<<" -command "moveGLfield $code -99"
  $menu.move add command -label "<" -command "moveGLfield $code -1"
  $menu.move add command -label ">" -command "moveGLfield $code 1"
  $menu.move add command -label ">>|" -command "moveGLfield $code 99"
  
  # Configure-field command:
  $menu entryconfig 1 -command "configGLdialog $code"
  
  # Insert-field submenu:
  array set displayed {}
  foreach column $glistAllFields {
    set field [lindex $column 0]
    set displayed($field) 0
  }
  foreach column $glistFields {
    set tcode [lindex $column 0]
    set displayed($tcode) 1
  }
  $menu.insert delete 0 end
  foreach column $glistAllFields {
    set tcode [lindex $column 0]
    if {! $displayed($tcode)} {
      set name $::windows::gamelist::names($tcode)
      $menu.insert add command -label $::tr(Glist$name) \
          -command "insertGLfield $code $tcode"
    }
  }
  
  # Delete-field command:
  if {$code == "g"} {
    $menu entryconfig 3 -state disabled
  } else {
    $menu entryconfig 3 -state normal -command "deleteGLfield $code"
  }
  # event generate .glistWin <ButtonRelease-3>
  $menu post $xscreen [expr {$yscreen + 2}]
  event generate $menu <ButtonPress-1>
}

array set glconfig {}

proc configGLdialog {code} {
  global glistFields glconfig
  foreach column $glistFields {
    if {$code == [lindex $column 0]} {
      set glconfig(width) [lindex $column 1]
      set glconfig(align) [lindex $column 2]
      set glconfig(color) [lindex $column 3]
      set glconfig(sep) [lindex $column 4]
    }
  }
  set w .glconfig
  if {[winfo exists $w]} { return }
  toplevel $w
  wm title $w "Scid"
  label $w.title -text "$::windows::gamelist::names($code)" -font font_Bold
  pack $w.title -side top
  pack [frame $w.g] -side top -fill x
  label $w.g.width -text $::tr(GlistWidth)
  set m [tk_optionMenu $w.g.vwidth glconfig(width) 1 2 3 4 5 6 7 8 9 10 \
      11 12 13 14 15 16 17 18 19 20]
  $w.g.vwidth configure -width 3
  $m entryconfigure 10 -columnbreak 1
  label $w.g.align -text $::tr(GlistAlign)
  frame $w.g.valign
  radiobutton $w.g.valign.left -text "<<" -indicatoron 0 \
      -variable glconfig(align) -value left
  radiobutton $w.g.valign.right -text ">>" -indicatoron 0 \
      -variable glconfig(align) -value right
  pack $w.g.valign.left $w.g.valign.right -side left -padx 1
  label $w.g.color -text $::tr(GlistColor)
  frame $w.g.vcolor
  foreach color {black darkBlue blue darkGreen darkRed red2 gray50} {
    image create photo color_$color -width 14 -height 16
    color_$color put $color -to 1 1 12 14
    radiobutton $w.g.vcolor.$color -image color_$color -indicatoron 0 \
        -variable glconfig(color) -value $color
    pack $w.g.vcolor.$color -side left -padx 1
  }
  label $w.g.sep -text $::tr(GlistSep)
  frame $w.g.vsep
  radiobutton $w.g.vsep.yes -text $::tr(Yes) -indicatoron 0 \
      -variable glconfig(sep) -value 1
  radiobutton $w.g.vsep.no -text $::tr(No) -indicatoron 0 \
      -variable glconfig(sep) -value 0
  pack $w.g.vsep.yes $w.g.vsep.no -side left -padx 1
  
  set row 0
  foreach t {width align color sep} {
    grid $w.g.$t -row $row -column 0 -sticky w
    grid $w.g.v$t -row $row -column 1 -sticky e
    incr row
  }
  
  addHorizontalRule $w
  pack [frame $w.b] -side top -fill x
  button $w.b.ok -text "OK" \
      -command "catch {grab release $w}; destroy $w; configGLfield $code"
  button $w.b.cancel -text $::tr(Cancel) \
      -command "catch {grab release $w}; destroy $w"
  pack $w.b.cancel $w.b.ok -side right -padx 2 -pady 2
  wm resizable $w 0 0
  ::utils::win::Centre $w
  catch {grab $w}
}

proc configGLfield {code} {
  global glistFields glconfig
  set newcolumn [list $code $glconfig(width) $glconfig(align) \
      $glconfig(color) $glconfig(sep)]
  set len [llength $glistFields]
  for {set i 0} {$i < $len} {incr i} {
    set column [lindex $glistFields $i]
    set tcode [lindex $column 0]
    if {$tcode == $code} {
      set glistFields [lreplace $glistFields $i $i $newcolumn]
      break
    }
  }
  # destroy .glistWin
  ::windows::gamelist::ReOpen
}

proc moveGLfield {code delta} {
  global glistFields
  set len [llength $glistFields]
  for {set i 0} {$i < $len} {incr i} {
    set column [lindex $glistFields $i]
    set tcode [lindex $column 0]
    if {$tcode == $code} {
      set glistFields [lreplace $glistFields $i $i]
      set insert [expr {$i + $delta}]
      set glistFields [linsert $glistFields $insert $column]
      break
    }
  }
  # destroy .glistWin
  ::windows::gamelist::ReOpen
}

proc insertGLfield {code newcode} {
  global glistFields glistAllFields
  set len [llength $glistFields]
  set newcolumn ""
  foreach column $glistAllFields {
    set tcode [lindex $column 0]
    if {$tcode == $newcode} { set newcolumn $column }
  }
  if {$newcolumn == ""} { return }
  
  for {set i 0} {$i < $len} {incr i} {
    set column [lindex $glistFields $i]
    set tcode [lindex $column 0]
    if {$tcode == $code} {
      incr i
      set glistFields [linsert $glistFields $i $newcolumn]
      break
    }
  }
  # destroy .glistWin
  ::windows::gamelist::ReOpen
}

proc deleteGLfield {code} {
  global glistFields
  set len [llength $glistFields]
  for {set i 0} {$i < $len} {incr i} {
    set column [lindex $glistFields $i]
    set tcode [lindex $column 0]
    if {$tcode != $code} { continue }
    set glistFields [lreplace $glistFields $i $i]
  }
  # destroy .glistWin
  ::windows::gamelist::ReOpen
}

proc popupGLmenu {code xcoord ycoord xscreen yscreen} {
  global glSelection glNumber
  ::windows::gamelist::SetSelection $code $xcoord $ycoord
  if {$glNumber < 1} {return}
  ::windows::gamelist::Highlight $glSelection
  #Enable/disable last 3 Popupmenupoint: Delete/Undelete (all) Games
  if {[sc_base isReadOnly]} {
    .glistWin.popup entryconfig 8 -state disabled
    .glistWin.popup entryconfig 9 -state disabled
    .glistWin.popup entryconfig 10 -state disabled
  } else {
    .glistWin.popup entryconfig 8 -state normal
    .glistWin.popup entryconfig 9 -state normal
    .glistWin.popup entryconfig 10 -state normal
  }
  .glistWin.popup post $xscreen [expr {$yscreen + 2}]
  event generate .glistWin.popup <ButtonPress-1>
}

proc ::windows::gamelist::SetStart { start } {
  global glstart
  set glstart $start
  ::windows::gamelist::Refresh
}

proc ::windows::gamelist::ToggleFlag {flag} {
  global glNumber
  # If an invalid game number, just return:
  if {$glNumber < 1} { return }
  if {$glNumber > [sc_base numGames]} { return }
  catch {sc_game flag $flag $glNumber invert}
  ::windows::gamelist::Refresh
}

proc removeFromFilter {{dir none}} {
  global glNumber glstart
  if {$glNumber < 1} { return }
  if {$glNumber > [sc_base numGames]} { return }
  if {$dir == "none"} {
    sc_filter remove $glNumber
  } elseif {$dir == "up"} {
    sc_filter remove 1 $glNumber
    set glstart 1
  } else {
    sc_filter remove $glNumber 9999999
  }
  ::windows::stats::Refresh
  ::windows::gamelist::Refresh
}

proc ::windows::gamelist::ShowMoves {xcoord ycoord} {
  global glistSelectPly glNumber glSelection
  # If an invalid game number, just return:
  if {$glNumber < 1} { return }
  if {$glNumber > [sc_base numGames]} { return }
  
  ::windows::gamelist::Highlight $glSelection
  .glistExtra.text delete 1.0 end
  .glistExtra.text insert end [sc_game firstMoves $glNumber $glistSelectPly]
  wm geometry .glistExtra +$xcoord+$ycoord
  wm deiconify .glistExtra
  raiseWin .glistExtra
}

proc ::windows::gamelist::Refresh {} {
  global glistSize glstart
  global glistFields
  updateStatusBar
  if {![winfo exists .glistWin]} { return }
  set totalSize [sc_filter count]
  set linenum [sc_game list $glstart $glistSize -current]
  foreach column $glistFields {
    set code [lindex $column 0]
    set cformat $code
    append cformat "*\n"
    .glistWin.c$code.text config -state normal
    .glistWin.c$code.text delete 1.0 end
    .glistWin.c$code.text insert end [sc_game list $glstart $glistSize $cformat] align
    if {$linenum > 0} {
      .glistWin.c$code.text tag add current $linenum.0 [expr {$linenum+1}].0
    }
    .glistWin.c$code.text config -state disabled
  }
  
  # Now update the window title:
  set str "Scid [tr WindowsGList]: "
  if {$totalSize > 0} {
    set right [expr {$totalSize + 1 - $glistSize}]
    if {$right < 1} { set right 1 }
    .glistWin.scale configure -to $right
    set glend [expr {$glstart + $glistSize - 1}]
    if {$glend > $totalSize} { set glend $totalSize}
    append str [::utils::thousands $glstart] " .. " \
        [::utils::thousands $glend] " / " [::utils::thousands $totalSize] " " $::tr(games)
  } else {
    append str $::tr(noGames)
    .glistWin.scale configure -to 1
  }
  ::setTitle .glistWin $str
}

trace variable glexport w updateExportGList

proc openExportGList {} {
  global glexport
  set w .glexport
  
  if {[sc_filter count] < 1} {
    tk_messageBox -type ok -icon info -title "Scid" \
        -message "This are no games in the current filter."
    return
  }
  
  if {[winfo exists $w]} {
    raiseWin $w
    updateExportGList
    return
  }
  toplevel $w
  wm title $w "Scid: Save Game List"
  
  label $w.lfmt -text "Format:" -font font_Bold
  pack $w.lfmt -side top
  entry $w.fmt -textvar glexport -bg white -fg black -font font_Fixed
  pack $w.fmt -side top -fill x
  text $w.tfmt -width 1 -height 5 -font font_Fixed -fg black -wrap none -relief flat
  pack $w.tfmt -side top -fill x
  $w.tfmt insert end "w: White            b: Black            "
  $w.tfmt insert end "W: White Elo        B: Black Elo        \n"
  $w.tfmt insert end "m: Moves count      r: Result           "
  $w.tfmt insert end "y: Year             d: Date             \n"
  $w.tfmt insert end "e: Event            s: Site             "
  $w.tfmt insert end "n: Round            o: ECO code         \n"
  $w.tfmt insert end "g: Game number      f: Filtered number  "
  $w.tfmt insert end "F: Final material   S: Non-std start pos\n"
  $w.tfmt insert end "D: Deleted flag     U: User flags       "
  $w.tfmt insert end "C: Comments flag    V: Variations flag  \n"
  $w.tfmt configure -cursor top_left_arrow -state disabled
  addHorizontalRule $w
  label $w.lpreview -text $::tr(Preview:) -font font_Bold
  pack $w.lpreview -side top
  text $w.preview -width 80 -height 5 -font font_Fixed -bg gray95 -fg black \
      -wrap none -setgrid 1 -xscrollcommand "$w.xbar set"
  scrollbar $w.xbar -orient horizontal -command "$w.preview xview"
  pack $w.preview -side top -fill x
  pack $w.xbar -side top -fill x
  addHorizontalRule $w
  pack [frame $w.b] -side bottom -fill x
  button $w.b.default -text "Default" -command {set glexport $glexportDefault}
  button $w.b.ok -text "OK" -command saveExportGList
  button $w.b.close -textvar ::tr(Cancel) -command "focus .; grab release $w; destroy $w"
  pack $w.b.close $w.b.ok -side right -padx 2 -pady 2
  pack $w.b.default -side left -padx 2 -pady 2
  wm resizable $w 1 0
  focus $w.fmt
  updateExportGList
  grab $w
}

proc updateExportGList {args} {
  global glexport
  set w .glexport
  if {! [winfo exists $w]} { return }
  set text [sc_game list 1 5 "$glexport\n"]
  $w.preview configure -state normal
  $w.preview delete 1.0 end
  $w.preview insert end $text
  $w.preview configure -state disabled
}

proc saveExportGList {} {
  global glexport
  set ftypes {{"Text files" {.txt}} {"All files" *}}
  set fname [tk_getSaveFile -filetypes $ftypes -parent .glexport -title "Scid: Save Game List"]
  if {$fname == ""} { return }
  set showProgress 0
  if {[sc_filter count] >= 20000} { set showProgress 1 }
  if {$showProgress} {
    progressWindow "Scid" "Saving game list..." $::tr(Cancel) sc_progressBar
  }
  busyCursor .
  set res [catch {sc_game list 1 9999999 "$glexport\n" $fname} err]
  unbusyCursor .
  if {$showProgress} { closeProgressWindow }
  if {$res} {
    tk_messageBox -type ok -icon warning -title "Scid" -message $err
    return
  }
  focus .
  grab release .glexport
  destroy .glexport
  return
}

