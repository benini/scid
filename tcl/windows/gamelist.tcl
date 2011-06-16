
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

set sortCriteria(real) ""
set sortCriteria(translated) ""

set critList { "GsortDate" "GsortYear" "GsortEvent" "GsortSite" 
               "GsortRound" "GsortWhiteName" "GsortBlackName" "GsortECO" 
			   "GsortResult" "GsortMoveCount" "GsortAverageElo" "GsortCountry" 
			   "GsortDeleted" "GsortEventDate" "GsortWhiteElo" "GsortBlackElo" 
               "GsortComments" "GsortVariations" "GsortNAGs" }
set critShortcuts { "d" "y" "e" "s" 
                    "n" "w" "b" "o" 
                    "r" "m" "R" "c" 
                    "D" "E" "W" "B" 
                    "C" "V" "A" }
array set sortingHandles {
0 -1
1 -1 
2 -1 
3 -1
4 -1
5 -1
6 -1
7 -1
8 -1
9 -1
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
  global glstart sortingHandles
  variable findtext
  busyCursor .glistWin 1
  ::utils::history::AddEntry ::windows::gamelist::findtext $findtext
  set dbNum [sc_base current]
  set temp [sc_filter textfind $glstart $findtext $sortingHandles($dbNum)]
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
  bind $w <Destroy> {}
  
  # erase the window
  foreach c [winfo children $w] {
    destroy $c
  }
  
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
    frame $w.columns.c$code
    
    if {[info exists ::windows::gamelist::names($code)]} {
      set name $::windows::gamelist::names($code)
    }
    if {[info exists ::tr(Glist$name)]} { set name $::tr(Glist$name) }
    
    # Each heading is a label:
    ttk::label $w.columns.c$code.header -foreground darkBlue -width $width -font font_Small -relief flat -background gray90 \
        -text $name -anchor w
    ::utils::tooltip::Set $w.columns.c$code.header $name
    set helpMessage(E,$w.columns.c$code.header) {Press the left or right mouse button here for a configuration menu}
    
    bind $w.columns.c$code.header <Control-ButtonPress-$::MB3> "incrGLwidth $code; break"
    bind $w.columns.c$code.header <Control-ButtonPress-1> "decrGLwidth $code; break"
    bind $w.columns.c$code.header <Shift-ButtonPress-$::MB3> "incrGLwidth $code; break"
    bind $w.columns.c$code.header <Shift-ButtonPress-1> "decrGLwidth $code; break"
    bind $w.columns.c$code.header <ButtonPress-1> "popupGLconfig $code %x %y %X %Y"
    bind $w.columns.c$code.header <ButtonPress-$::MB3> "popupGLconfig $code %x %y %X %Y"
    
    pack $w.columns.c$code -side left -expand yes -fill both -padx 0
    
    pack $w.columns.c$code.header -side top -fill x -padx 2
    addHorizontalRule $w.columns.c$code 1 flat
    # -height $glistSize
    text $w.columns.c$code.text -background white -width $width -height 50 -font font_Small -relief flat -foreground $fgcolor -wrap none -setgrid 1 -cursor top_left_arrow
    $w.columns.c$code.text tag configure align -justify $justify -foreground $fgcolor
    $w.columns.c$code.text tag configure highlight -background lightBlue
    $w.columns.c$code.text tag configure current -background lightYellow2
    $w.columns.c$code.text tag configure underline -underline true
    
    bind $w.columns.c$code.text <Button1-Motion> "break"
    bind $w.columns.c$code.text <Button2-Motion> "break"
    bind $w.columns.c$code.text <Double-Button-1> "::windows::gamelist::SetSelection $code %x %y; ::game::Load \$glNumber; break"
    bind $w.columns.c$code.text <Button-1> "::windows::gamelist::SetSelection $code %x %y; ::windows::gamelist::Highlight \$glSelection; break"
    bind $w.columns.c$code.text <ButtonRelease-1> "::windows::gamelist::SetSelection $code %x %y; ::windows::gamelist::Dehighlight; break"
    
    bind $w.columns.c$code.text <ButtonPress-$::MB3> "popupGLmenu $code %x %y %X %Y"
    
    bind $w.columns.c$code.text <ButtonPress-$::MB2> "::windows::gamelist::SetSelection $code %x %y; ::windows::gamelist::ShowMoves %X %Y; break"
    bind $w.columns.c$code.text <ButtonRelease-$::MB2> "wm withdraw .glistExtra; ::windows::gamelist::Dehighlight; break"
    
    pack $w.columns.c$code.text -side top -expand true -fill both
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
  menu $w.popup.merge
  for {set i 1} {$i <= [sc_base count total]} {incr i} {
    if { $i == [sc_base current] || [sc_base isReadOnly] } { continue }
    if {[sc_base inUse $i]} {
      set fname [file tail [sc_base filename $i]]
      $w.popup.merge add command -label "$i $fname" -command "::game::mergeInBase [sc_base current] $i"
    }
  }
  $w.popup add cascade -label $::tr(GlistMergeGameInBase) -menu $w.popup.merge
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
    set dbNum [sc_base current]
    set glstart [sc_filter locate [sc_game number] $sortingHandles($dbNum)]
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
    set dbNum [sc_base current]
    set glstart [sc_filter locate $::windows::gamelist::goto $sortingHandles($dbNum)]
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
  
  ttk::button $w.b.sortbutton -textvar ::tr(GsortSort) -style Pad0.Small.TButton -command { makeSortWin }
  ttk::button $w.b.export -textvar ::tr(Save...) -style Pad0.Small.TButton -command openExportGList
  ttk::button $w.b.help -textvar ::tr(Help) -style Pad0.Small.TButton -command { helpWindow GameList }
  ttk::button $w.b.close -textvar ::tr(Close) -style Pad0.Small.TButton -command { focus .; destroy .glistWin }
  
  pack $w.b.start $w.b.pgup $w.b.pgdn $w.b.end $w.b.current -side left -padx 1
  pack $w.b.space $w.b.gotolabel $w.b.goto -side left
  pack $w.b.space2 $w.b.findlabel $w.b.find -side left
  pack $w.b.close $w.b.help $w.b.export $w.b.sortbutton -side right -padx 5
  
  set ::windows::gamelist::isOpen 1
  bind $w <F1> { helpWindow GameList }
  bind $w <Destroy> { set ::windows::gamelist::isOpen 0 }
  bind $w <Escape> "$w.b.close invoke"
  standardShortcuts $w
  ::createToplevelFinalize $w
  
  # MouseWheel bindings:
  if { $::macOS } {
    bind $w <MouseWheel> {::windows::gamelist::Scroll [expr {- (%D)}]}
  } else {
    bind $w <MouseWheel> {::windows::gamelist::Scroll [expr {- (%D / 120)}]}
  }
  if {! $::windowsOS} {
    bind $w <Button-4> {::windows::gamelist::Scroll -1}
    bind $w <Button-5> {::windows::gamelist::Scroll 1}
  }
  
  update idletasks
  bind $w <Configure> { ::docking::handleConfigureEvent ::windows::gamelist::Resize }
  wm iconname $w "Scid: [tr WindowsGList]"
  ::windows::gamelist::Refresh
  focus $w.b.goto
  setWinLocation $w
  setWinSize $w
}

# Binding to reset glistSize when the window is resized:
# The way this is done is very ugly, but the only way I could
# find that actually works.
# Set temp to window geometry (e.g. 80x20+...) and then
# extract the part between the "x" and the first "+" or "-":
proc ::windows::gamelist::Resize {} {
  global glistSize glistFields
  set w .glistWin
  bind $w <Configure> {}
  
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
  
  # setgrid option does not work in docked mode, so the last line may be partially visible
  if { $::docking::USE_DOCKING } {
    catch { incr temp -1 }
  }
  
  if {$temp != $glistSize && $temp > 0} {
    set glistSize $temp
    set t $w.columns.cg.text
    if { $::docking::USE_DOCKING } {
      # foreach i $glistFields {
      # set code [lindex $i 0]
      # .glistWin.columns.c$code.text configure -height $glistSize
      # }
    }
    ::windows::gamelist::Refresh
  }
  update idletasks
  bind $w <Configure> { ::docking::handleConfigureEvent ::windows::gamelist::Resize }
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
  
  ::windows::gamelist::ReOpen
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
  set glSelection [expr {int([.glistWin.columns.c$code.text index @$xcoord,$ycoord])}]
  set glNumber [.glistWin.columns.cg.text get $glSelection.0 $glSelection.end]
}

proc incrGLwidth {code} {
  global glistSize glistMaxWidth
  set w .glistWin.columns.c$code
  set width [$w.header cget -width]
  if {$width >= $glistMaxWidth} { return }
  incr width
  $w.header configure -width $width
  $w.text configure -width $width
  updateGLwidths $code $width
}

proc decrGLwidth {code} {
  global glistSize
  set w .glistWin.columns.c$code
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
    .glistWin.columns.c$code.text tag remove highlight 1.0 end
  }
}

proc ::windows::gamelist::Highlight {linenum} {
  global glistFields glistSize
  foreach column $glistFields {
    set code [lindex $column 0]
    .glistWin.columns.c$code.text tag remove highlight 1.0 end
    .glistWin.columns.c$code.text tag add highlight $linenum.0 [expr {$linenum+1}].0
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
  # event generate .glistWin <ButtonRelease-$::MB3>
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
    .glistWin.popup entryconfig 9 -state disabled
    .glistWin.popup entryconfig 10 -state disabled
    .glistWin.popup entryconfig 11 -state disabled
  } else {
    .glistWin.popup entryconfig 9 -state normal
    .glistWin.popup entryconfig 10 -state normal
    .glistWin.popup entryconfig 11 -state normal
  }
  # update the list of opened base for game merging
  set m .glistWin.popup.merge
  $m delete 0 end
  for {set i 1} {$i <= [sc_base count total]} {incr i} {
    if { $i == [sc_base current] } { continue }
    if {[sc_base inUse $i]} {
      set fname [file tail [sc_base filename $i]]
      $m add command -label "$i $fname" -command "::game::mergeInBase [sc_base current] $i"
    }
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
  global glNumber glstart sortingHandles
  if {$glNumber < 1} { return }
  if {$glNumber > [sc_base numGames]} { return }
  set db [ sc_base current]
  if {$dir == "none"} {
    sc_filter remove 0 $glNumber 
  } elseif {$dir == "up"} {
    sc_filter remove 1 $glNumber $sortingHandles($db)
    set glstart 1
  } else {
    sc_filter remove 2 $glNumber $sortingHandles($db)
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
  global glistFields sortingHandles
  updateStatusBar
  if {![winfo exists .glistWin]} { return }
  set totalSize [sc_filter count]
  set dbNum [sc_base current]
  set linenum [sc_sort list $dbNum $glstart $glistSize -current $sortingHandles($dbNum)]
  foreach column $glistFields {
    set code [lindex $column 0]
    set cformat $code
    append cformat "*\n"
    .glistWin.columns.c$code.text config -state normal
    .glistWin.columns.c$code.text delete 1.0 end
    .glistWin.columns.c$code.text insert end [sc_sort list $dbNum $glstart $glistSize $cformat $sortingHandles($dbNum)] align
    if {$linenum > 0} {
      .glistWin.columns.c$code.text tag add current $linenum.0 [expr {$linenum+1}].0
    }
    .glistWin.columns.c$code.text config -state disabled
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
  configureSortWin
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
  global glexport sortingHandles
  set w .glexport
  if {! [winfo exists $w]} { return }
  set dbNum [sc_base current]
  set text [sc_sort list $dbNum 1 5 "$glexport\n" $sortingHandles($dbNum)]
  $w.preview configure -state normal
  $w.preview delete 1.0 end
  $w.preview insert end $text
  $w.preview configure -state disabled
}

proc saveExportGList {} {
  global glexport sortingHandles
  set ftypes {{"Text files" {.txt}} {"All files" *}}
  set fname [tk_getSaveFile -filetypes $ftypes -parent .glexport -title "Scid: Save Game List"]
  if {$fname == ""} { return }
  set showProgress 0
  if {[sc_filter count] >= 20000} { set showProgress 1 }
  if {$showProgress} {
    progressWindow "Scid" "Saving game list..." $::tr(Cancel) sc_progressBar
  }
  busyCursor .
  set dbNum [sc_base current]
  set res [catch {sc_sort list $dbNum 1 9999999 "$glexport\n" $sortingHandles($dbNum) $fname} err]
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

proc makeSortWin {} {
  global sortCriteria critList
  set w .glSortWin
  if {[winfo exists $w]} {
    raiseWin $w
    return
  }
  toplevel $w
  wm title $w "Scid: Game List Sort"
  wm resizable $w 0 0
  pack [ttk::frame $w.f]
  
  ttk::label $w.f.torder -textvar ::tr(SortCriteria:) -font font_Bold
  pack $w.f.torder -side top
  ttk::label $w.f.order -textvar sortCriteria(translated) -width 40 -background white -relief solid -anchor w
  pack $w.f.order -side top -fill x -pady 2 -padx 2
  addHorizontalRule $w.f
  ttk::label $w.f.tadd -textvar ::tr(AddCriteria:) -font font_Bold
  pack $w.f.tadd -side top

  addHorizontalRule $w.f

  pack [ttk::frame $w.f.cr] -fill x
  
  set locCritList {}
  foreach cr $critList { lappend locCritList $::tr($cr) } 
  ttk::combobox $w.f.cr.critcombo -width 20 -values $locCritList
  $w.f.cr.critcombo set [lindex $locCritList 0]
  pack $w.f.cr.critcombo -side left

  set locOrderList [::list $::tr(GsortAscending) $::tr(GsortDescending) ]
  ttk::combobox $w.f.cr.ordercombo -width 12 -values $locOrderList
  $w.f.cr.ordercombo set $::tr(GsortAscending)
  pack $w.f.cr.ordercombo -side left

  ttk::button $w.f.cr.add -textvar ::tr(GsortAdd) -command addSortCriteria
  pack $w.f.cr.add -side right
  
  addHorizontalRule $w.f

  pack [ttk::frame $w.f.b1] -fill x
  ttk::button $w.f.b1.clear -textvar ::tr(Clear) -command clearSortCriteria
  ttk::button $w.f.b1.sort -textvar ::tr(Sort) -command sortGameList
  pack $w.f.b1.clear -side left
  pack $w.f.b1.sort -side right

  pack [ttk::frame $w.f.b2] -side bottom -fill x
  ttk::button $w.f.b2.store -textvar ::tr(GsortStore) -command storeSortingCache
  ttk::button $w.f.b2.load -textvar ::tr(GsortLoad) -command loadSortingCache
  ttk::button $w.f.b2.close -textvar ::tr(Close) -command "focus .; destroy $w"
  pack $w.f.b2.store $w.f.b2.load -side left -padx 5 -pady 2
  pack $w.f.b2.close -side right

  bind $w <Escape> "$w.f.b.close invoke"
  configureSortWin
}

proc configureSortWin {} {
  global sortCriteria sortingHandles
  set w .glSortWin
  if {[winfo exists $w]} {
    set db [ sc_base current]
    if {[sc_base inUse $db]} {
      set handle $sortingHandles($db)
      if { $handle == -1 || $db == 9 } { $w.f.b2.store configure -state disabled } else { $w.f.b2.store configure -state normal }
      if { $db == 9 } { $w.f.b2.load configure -state disabled } else {
  	    set canLoad [ sc_sort testload $db ]
	    if { $canLoad } { $w.f.b2.load configure -state normal } else { $w.f.b2.load configure -state disabled }
      }
      if {$sortCriteria(real) == ""} {$w.f.b1.clear configure -state disabled } else { $w.f.b1.clear configure -state normal }
	}
  }
}

proc clearSortCriteria {} {
  set ::sortCriteria(real) ""
  set ::sortCriteria(translated) ""
  configureSortWin
}

proc addSortCriteria {args} {
  global sortCriteria critShortcuts

  set critSelected [.glSortWin.f.cr.critcombo get]
  set orderSelected [.glSortWin.f.cr.ordercombo current]
  set shortCrit [lindex $critShortcuts [.glSortWin.f.cr.critcombo current]]
  set shortOrder "+" 
  if { $orderSelected == 1 } { set shortOrder "-" }

  if {$sortCriteria(real) == ""} {
    set sortCriteria(real) "$shortCrit$shortOrder"
    set sortCriteria(translated) "$critSelected$shortOrder"
  } else {
    append sortCriteria(real) "$shortCrit$shortOrder"
    append sortCriteria(translated) ", $critSelected$shortOrder"
  }
  configureSortWin
}

proc sortGameList {} {
  global sortCriteria sortingHandles
  set db [ sc_base current]
  progressWindow "Scid" [concat "Sorting" "..."]
  busyCursor .
  set handle [ sc_sort sort $db $sortCriteria(real) $sortingHandles($db)]
  unbusyCursor .
  closeProgressWindow
  set sortingHandles($db) $handle 
  ::windows::gamelist::Refresh
  configureSortWin
}

proc storeSortingCache {} {
  global sortingHandles
  set db [ sc_base current]
  sc_sort store $db $sortingHandles($db)
  getSortingCrit
}

proc loadSortingCache {} {
  global sortCriteria sortingHandles
  set db [ sc_base current]
  set sortingHandles($db) [sc_sort load $db $sortingHandles($db)] 
  getSortingCrit
  ::windows::gamelist::Refresh
  configureSortWin
}

proc getSortingCrit {} {
  global sortCriteria sortingHandles critShortcuts critList
    
  set db [ sc_base current]
  set critString [ sc_sort crit $db $sortingHandles($db)]
  set critStringList [split $critString {} ]
  set sortCriteria(real) $critString
  set sortCriteria(translated) ""

  set sep ""
  foreach c $critStringList {
	set found 0
	set p 0
	foreach l $critShortcuts {
	if { $l == $c } {
      set idx [lindex $critList $p]
      append sortCriteria(translated) $sep $::tr($idx) 
      set sep ","
      set found 1
    }
    incr p 
    }
    if { $found == 0 } {
      append sortCriteria(translated) $c
    }
  }
}



##########################################################################
# June 2011: A new reusable and simplified gamelist widget
#

# glist.create
#   Create a gamelist widget
#   w: parent window of the gamelist widget
#   layout: a string name that will be assigned to columns layout.
#           layout will be saved and restored in successive glist.create calls.
proc glist.create {{w} {layout}} {
  # Default values
  if {! [info exists ::glist_ColOrder($layout)] } {
    set ::glist_ColOrder($layout) {{7} {1} {2} {3} {4} {5} {6} {23} {22} {8} {9} {10} {11} {12} {13} {14} {15} {16} {0}}
  }
  if {! [info exists ::glist_ColWidth($layout)] } {
    set ::glist_ColWidth($layout) {{50} {50} {50} {120} {40} {120} {40} {80} {200} {30} \
        {200} {30} {20} {20} {20} {20} {35} {50} {30} {100} {40} {40} {50} {140}}
  }
  if {! [info exists ::glist_ColAnchor($layout)] } {
    set ::glist_ColAnchor($layout) {{e} {c} {c} {w} {c} {w} {c} {w} {w} {e} \
        {w} {c} {c} {c} {c} {c} {c} {c} {c} {c} {c} {c} {c} {w}}
  }
  if {! [info exists ::glist_Sort($w.glist)] } {
    set ::glist_Sort($w.glist) { {22} {-} {7} {-} }
  }

  ttk::treeview $w.glist -columns $::glist_Headers -show headings -selectmode browse
  $w.glist tag configure current -background lightBlue
  $w.glist tag configure fsmall -font font_Small
  menu $w.glist.header_menu
  menu $w.glist.header_menu.addcol
  menu $w.glist.header_menu.sort -disabledforeground blue
  menu $w.glist.game_menu
  bind $w.glist <Configure> "set ::glistResized($w.glist) 1"
  bind $w.glist <2> "glist.popupmenu_ %W %x %y %X %Y $layout"
  bind $w.glist <3> "glist.popupmenu_ %W %x %y %X %Y $layout"
  bind $w.glist <ButtonRelease-1> "glist.release_ %W %x %y $layout"
  bind $w.glist <Double-ButtonPress-1> {
    foreach {idx ply} [split [%W selection] "_"] {}
    if {[info exist idx]} {
      sc_base switch $::glistBase(%W)
      ::game::Load $idx $ply
    }
  }
  bind $w.glist <Destroy> "glist.destroy_ $w.glist"

  set i 0
  foreach col $::glist_Headers {
    $w.glist heading $col -text $::tr($col)
    $w.glist column $col -stretch 0 \
             -width [lindex $::glist_ColWidth($layout) $i]\
             -anchor [lindex $::glist_ColAnchor($layout) $i]
    incr i
  }
  $w.glist configure -displaycolumns $::glist_ColOrder($layout)

  autoscrollframe -bars both $w "" $w.glist
  set ::glistYScroll($w.glist) [$w.glist cget -yscrollcommand]
  $w.glist configure -yscrollcommand "glist.yscroll_ $w.glist"
  $w.ybar configure -command "glist.ybar_ $w.glist"
  bind $w.ybar <ButtonRelease-1> "+glist.ybar_ $w.glist buttonrelease"
  ttk::bindMouseWheel $w.glist "glist.ybar_ $w.glist"

  # On exit save layout in options.dat
  options.save ::glist_ColOrder($layout)
  options.save ::glist_ColWidth($layout)
  options.save ::glist_ColAnchor($layout)
  options.save ::glist_Sort($w.glist)

  set ::glistYDrag($w.glist) 0
  set ::glistLoaded($w.glist) 0.0
  set ::glistTotal($w.glist) 0.0
  set ::glistVisibleLn($w.glist) 0
  set ::glistResized($w) 0
  glist.sortInit_ $w.glist
}

# glist.update
#   Retrieve values from database and update the widget
#   w: the parent windows of the widget that was passed to glist.create
#   base: the database from which retrieve values
#   filter: returns only values in the specified filter
#         - "all": all the values in the database *** NOT YET IMPLEMENTED ***
#         - "dbfilter": only values that matches the user defined filters
#         - "tree": only games from which are calculated the stats in the tree window
proc glist.update {{w} {base} {filter}} {
  set w $w.glist
  if {! [winfo exists $w]} { return }

  set ::glistFilter($w) $filter
  set ::glistTotal($w) [sc_filter count $base $filter]
  if {$::glistVisibleLn($w) == 0 && $::glistTotal($w) > 0} {
    # Guess glistVisibleLn
    set ::glistVisibleLn($w) 50
    if {$::glistVisibleLn($w) >= $::glistTotal($w)} {
      set ::glistVisibleLn($w) [expr $::glistTotal($w) -1]
    }
  }
  glist.update_ $w $base
}


#private:
set glist_Headers {"GlistNumber" "GlistResult" "GlistLength" "GlistWhite" "GlistWElo"
                   "GlistBlack" "GlistBElo"  "GlistDate" "GlistEvent" "GlistRound"
                   "GlistSite" "GlistAnnos" "GlistComments" "GlistVars" "GlistDeleted"
                   "GlistFlags" "GlistECO" "GlistEndMaterial" "GlistStart" "GlistEDate"
                   "GlistYear" "GlistAverageElo" "GlistRating" "GlistMoveField" }

set glist_SortShortcuts { "N" "r" "m" "w" "W"
                    "b" "B" "d" "e" "n"
                    "s" "A" "C" "V" "D"
                    "???" "o" "???" "???" "E"
                    "y" "R" "i" "???" }

proc glist.destroy_ {{w}} {
  if {[info exists ::glistSortCache($w)]} {
    sc_base sortcache $::glistBase($w) release $::glistSortCache($w)
    unset ::glistSortCache($w)
  }
  unset ::glistSortStr($w)
  if {[info exists ::glistBase($w)]} { unset ::glistBase($w) }
  if {[info exists ::glistFilter($w)]} { unset ::glistFilter($w) }
  if {[info exists ::glistFirst($w)]} { unset ::glistFirst($w) }
  unset ::glistVisibleLn($w)
  unset ::glistLoaded($w)
  unset ::glistTotal($w)
  unset ::glistYDrag($w)
  unset ::glistYScroll($w)
  unset ::glistResized($w)
}

proc glist.update_ {{w} {base}} {
  if {! [info exists ::glistBase($w)] } {
    #Create a sortcache to speed up sorting
    sc_base sortcache $base create $::glistSortStr($w)
  } elseif {$::glistBase($w) != $base || $::glistSortCache($w) != $::glistSortStr($w)} {
    #Create a new sortcache
    sc_base sortcache $::glistBase($w) release $::glistSortCache($w)
    sc_base sortcache $base create $::glistSortStr($w)
  }
  set ::glistSortCache($w) $::glistSortStr($w)
  set ::glistBase($w) $base
  set ::glistFirst($w) 0.0
  glist.loadvalues_ $w
  glist.ybarupdate_ $w
}

proc glist.loadvalues_ {w} {
  $w delete [$w children {}]
  set base $::glistBase($w)
  if {$base == [sc_base current]} {
    set current_game [sc_game number]
  } else {
    set current_game -1
  }
  set i 0
  busyCursor .
  foreach {idx line} [sc_base gameslist $base $::glistFirst($w) [expr 1 + $::glistVisibleLn($w)]\
                                        $::glistFilter($w) $::glistSortStr($w)] {
    $w insert {} end -id $idx -values $line -tag fsmall
    foreach {n ply} [split $idx "_"] {
      if {$n == $current_game} { $w item $idx -tag {fsmall current} }
    }
    incr i
  }
  set ::glistLoaded($w) $i
  unbusyCursor .
}

proc glist.ybar_ {w cmd {n 0} {units ""}} {
  if { $cmd == "-1" || $cmd == "+1" } {
    #MouseWheel
    set n [expr $cmd * $::glistVisibleLn($w) * 0.75]
    set units "units"
    set cmd scroll
  }
  if { $cmd == "scroll" || $cmd == "moveto"} {
    if {$cmd == "moveto"} {
      set ::glistFirst($w) [expr ceil($n * $::glistTotal($w))]
    } else {
      if {$units == "pages"} {
        set ::glistFirst($w) [expr $::glistFirst($w) + $n * ($::glistVisibleLn($w) -1)]
      } else {
        set ::glistFirst($w) [expr $::glistFirst($w) + $n]
      }
    }

    set d [expr $::glistTotal($w) - $::glistVisibleLn($w) +1]
    if {$::glistFirst($w) > $d } { set ::glistFirst($w) $d }
    if { $::glistFirst($w) < 0.0 } { set ::glistFirst($w) 0.0 }

    if { $cmd == "scroll"} {
      glist.loadvalues_ $w
    } else {
      set ::glistYDrag($w) 1
      set t $w.balloon
      if {! [winfo exists $t] } {
        toplevel $t -bd 1 -bg black
        wm overrideredirect $t 1
        pack [message $t.txt -aspect 10000 -bg lightyellow -font fixed]
      }
      $t.txt configure -text [format "%0.0f (%0.0f%%)" [expr 1 + $::glistFirst($w)]\
          [expr ($::glistFirst($w) + $::glistVisibleLn($w))*100.0/$::glistTotal($w) ]]
      set wmx [expr [winfo pointerx .] - [winfo reqwidth $t.txt] - 10]
      set wmy [winfo pointery .]
      wm geometry $t \
        [winfo reqwidth $t.txt]x[winfo reqheight $t.txt]+$wmx+$wmy
      raise $t
    }
    glist.ybarupdate_ $w
  } elseif { $cmd == "buttonrelease" && $::glistYDrag($w) != 0 } {
      set ::glistYDrag($w) 0
      destroy $w.balloon
      glist.loadvalues_ $w
      glist.ybarupdate_ $w
  }
}

proc glist.ybarupdate_ {w} {
  if { $::glistLoaded($w) != $::glistTotal($w) } {
	set first [expr $::glistFirst($w) / $::glistTotal($w)]
    set last [expr ($::glistFirst($w) + $::glistLoaded($w)) / $::glistTotal($w)]
    eval $::glistYScroll($w) $first $last
  }
}

proc glist.yscroll_ {w first last} {
  if { $first != 0 } {
#TODO: MouseWheel problem
    $w yview moveto 0
    return
  }

  if { $::glistLoaded($w) != $::glistTotal($w) } {
    if { $first != 0 || $last != 1} {
      set ::glistResized($w) 0
      if { $last < 1 } { set ::glistVisibleLn($w) [expr floor($last * $::glistLoaded($w) +1)] }
      glist.ybarupdate_ $w
    } elseif {$::glistResized($w)} {
      # Increase glistVisibleLn (recursion)
      set ::glistVisibleLn($w) [expr $::glistVisibleLn($w) + 1]
      glist.ybar_ $w scroll
    }
  } else { eval $::glistYScroll($w) $first $last }
}

proc glist.popupmenu_ {{w} {x} {y} {abs_x} {abs_y} {layout}} {
# identify region requires at least tk 8.5.9
# identify row have scrollbar problems
  if { 0 != [catch {set region [$w identify region $x $y] }] } {
    if {[$w identify row $x $y] == "" } {
      set region "heading"
    } else {
      set region ""
    }
  }
  if { $region != "heading" } {
# if {[$w identify region $x $y] != "heading" }
    event generate $w <ButtonPress-1> -x $x -y $y
    foreach {idx ply} [split [$w selection] "_"] {}
    if {[info exist idx]} {
      $w.game_menu delete 0 end
      #LOAD/BROWSE/MERGE GAME
      $w.game_menu add command -label $::tr(LoadGame) \
         -command "sc_base switch $::glistBase($w); ::game::Load $idx $ply"
      $w.game_menu add command -label $::tr(BrowseGame) \
         -command "::gbrowser::new $::glistBase($w) $idx $ply"
      $w.game_menu add command -label $::tr(MergeGame) \
         -command "mergeGame $::glistBase($w) $idx"

      #GOTO GAME
      #$w.game_menu add separator
      #TODO: add a goto game number
      if {$::glistBase($w) == [sc_base current]} {
        #TODO: add a goto current game
        #DELETE
        #TODO: Delete games even for "not current" databases
        #TODO: translate labels
        #TODO: refresh the other windows after delete/undelete
        $w.game_menu add separator
        set deleted [sc_game flag delete $idx]
        if {$deleted} {
          $w.game_menu add command -label "Undelete game" -command "sc_game flag delete $idx 0"
        } else {
          $w.game_menu add command -label "Delete game" -command "sc_game flag delete $idx 1"
        }
      }
      tk_popup $w.game_menu $abs_x $abs_y
    }
  } else {
    set col [$w identify column $x $y]
    set col_idx [lsearch -exact $::glist_Headers [$w column $col -id] ]
    $w.header_menu delete 0 end

    #SORT
    $w.header_menu.sort delete 0 end
    if {"???" != [lindex $::glist_SortShortcuts $col_idx]} {
      $w.header_menu.sort add command -label $::tr(GlistNewSort) -image ::glist_Arrows(0)\
                               -compound right -command [list glist.sortBy_ $w $col_idx +]
      $w.header_menu.sort add command -label $::tr(GlistNewSort) -image ::glist_Arrows(1)\
                               -compound right -command [list glist.sortBy_ $w $col_idx -]
      set a1 [llength $::glist_Sort($w)]
      set a2 [expr $a1 +1]
      if {[lsearch -exact $::glist_Sort($w) $col_idx ] == -1 && $a1 <= 16} {
        $w.header_menu.sort add separator
        $w.header_menu.sort add command -label $::tr(GlistAddToSort) -image ::glist_Arrows($a1)\
                                -compound right -command [list glist.sortBy_ $w $col_idx + 0]
        $w.header_menu.sort add command -label $::tr(GlistAddToSort) -image ::glist_Arrows($a2)\
                                -compound right -command [list glist.sortBy_ $w $col_idx - 0]
    }
    $w.header_menu.sort add separator
    }
    $w.header_menu.sort add command -label $::tr(GlistCurrentSep) -state disabled
    set i 0
    foreach {c dir} $::glist_Sort($w) {
      set h [lindex $::glist_Headers $c]
      set arrow_idx [expr $i *2]
      if {$dir == "-"} { incr arrow_idx }
      $w.header_menu.sort add command -label $::tr($h) -image ::glist_Arrows($arrow_idx) \
                                      -compound left -state disabled
      incr i
    }
    $w.header_menu add cascade -label $::tr(Sort) -menu $w.header_menu.sort

    #ADD/REMOVE COLUMN
    $w.header_menu add separator
    $w.header_menu.addcol delete 0 end
    set empty disabled
    set i 0
    foreach h $::glist_Headers {
      if {[lsearch -exact $::glist_ColOrder($layout) $i] == -1} {
        set empty normal
        $w.header_menu.addcol add command -label $::tr($h) -command "glist.insertcol_ $w $layout $i $col"
      }
      incr i
    }
    $w.header_menu add cascade -label $::tr(GlistAddField) -menu $w.header_menu.addcol -state $empty
    $w.header_menu add command -label $::tr(GlistDeleteField) -command "glist.removecol_ $w $layout $col"

    #CHANGE ALIGNMENT
    $w.header_menu add separator
    set cur_a [lindex $::glist_ColAnchor($layout) $col_idx]
    if {$cur_a != "w"} {
      $w.header_menu add command -label $::tr(GlistAlignL) \
                     -command "$w column $col -anchor w; lset ::glist_ColAnchor($layout) $col_idx w"
    }
    if {$cur_a != "e"} {
      $w.header_menu add command -label $::tr(GlistAlignR) \
                     -command "$w column $col -anchor e; lset ::glist_ColAnchor($layout) $col_idx e"
    }
    if {$cur_a != "c"} {
      $w.header_menu add command -label $::tr(GlistAlignC) \
                     -command "$w column $col -anchor c; lset ::glist_ColAnchor($layout) $col_idx c"
    }

    tk_popup $w.header_menu $abs_x $abs_y
  }
}

proc glist.sortInit_ {w} {
  set ::glistSortStr($w) ""
  set i 0
  foreach {c dir} $::glist_Sort($w) {
    set arrow_idx [expr $i *2]
    if {$dir == "-"} { incr arrow_idx }
    $w heading $c -image ::glist_Arrows($arrow_idx)
    append ::glistSortStr($w) [lindex $::glist_SortShortcuts $c] $dir
    incr i
  }
}

proc glist.sortBy_ {w col direction {clear 1}} {
  foreach {c dir} $::glist_Sort($w) { $w heading $c -image "" }
  if {$clear} { unset ::glist_Sort($w) }
  lappend ::glist_Sort($w) $col $direction
  glist.sortInit_ $w
  if {[info exist ::glistBase($w)]} { glist.update_ $w $::glistBase($w) }
}

#Drag and drop and changes in column's layout
proc glist.insertcol_ {{w} {layout} {col} {after}} {
  set b [expr [string trimleft $after {#}]]
  set ::glist_ColOrder($layout) [linsert $::glist_ColOrder($layout) $b $col]
  $w configure -displaycolumns $::glist_ColOrder($layout)
}

proc glist.removecol_ {{w} {layout} {col}} {
  set d [expr [string trimleft $col {#}] -1]
  set ::glist_ColOrder($layout) [lreplace $::glist_ColOrder($layout) $d $d]
  $w configure -displaycolumns $::glist_ColOrder($layout)
}

proc glist.release_ {{w} {x} {y} {layout}} {
  switch $::ttk::treeview::State(pressMode) {
    resize {
      set col_id [$w column $::ttk::treeview::State(resizeColumn) -id]
      set i [lsearch -exact $::glist_Headers $col_id]
      if {$i != -1} {
        lset ::glist_ColWidth($layout) $i [$w column $::ttk::treeview::State(resizeColumn) -width]
      }
    }
    heading {
      lassign [$w identify $x $y] what
      if {$what == "heading"} {
        set new_col [$w identify column $x $y]
        set from [expr [string trimleft $::ttk::treeview::State(heading) {#}] -1]
        set to [expr [string trimleft $new_col {#}] -1]
        set val [lindex $::glist_ColOrder($layout) $from]
        set ::glist_ColOrder($layout) [lreplace $::glist_ColOrder($layout) $from $from]
        set ::glist_ColOrder($layout) [linsert $::glist_ColOrder($layout) $to $val]
        $w configure -displaycolumns $::glist_ColOrder($layout)
      }
    }
  }
  ttk::treeview::Release $w $x $y
}

image create bitmap ::glist_Arrows(0) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x00, 0x03, 0x00, 0x02, 0x00, 0x02, 0x00, 0x02, 0x10, 0x02,
       0x38, 0x07, 0x7c, 0x00, 0xfe, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(1) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x00, 0x03, 0x00, 0x02, 0x00, 0x02, 0x00, 0x02, 0xfe, 0x02,
       0x7c, 0x07, 0x38, 0x00, 0x10, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(2) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x80, 0x03, 0x00, 0x04, 0x00, 0x04, 0x00, 0x02, 0x08, 0x01,
       0x9c, 0x07, 0x3e, 0x00, 0x7f, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(3) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x80, 0x03, 0x00, 0x04, 0x00, 0x04, 0x00, 0x02, 0x7f, 0x01,
       0xbe, 0x07, 0x1c, 0x00, 0x08, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(4) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x80, 0x03, 0x00, 0x04, 0x00, 0x04, 0x00, 0x03, 0x08, 0x04,
       0x9c, 0x07, 0x3e, 0x00, 0x7f, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(5) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x80, 0x03, 0x00, 0x04, 0x00, 0x04, 0x00, 0x03, 0x7f, 0x04,
       0xbe, 0x03, 0x1c, 0x00, 0x08, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(6) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x00, 0x02, 0x00, 0x03, 0x00, 0x03, 0x80, 0x02, 0x88, 0x07,
       0x1c, 0x02, 0x3e, 0x00, 0x7f, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(7) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x00, 0x02, 0x00, 0x03, 0x00, 0x03, 0x80, 0x02, 0xff, 0x07,
       0x3e, 0x02, 0x1c, 0x00, 0x08, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(8) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x80, 0x07, 0x80, 0x00, 0x80, 0x03, 0x00, 0x04, 0x08, 0x04,
       0x9c, 0x03, 0x3e, 0x00, 0x7f, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(9) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x80, 0x07, 0x80, 0x00, 0x80, 0x03, 0x00, 0x04, 0x7f, 0x04,
       0xbe, 0x03, 0x1c, 0x00, 0x08, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(10) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x00, 0x07, 0x80, 0x00, 0x80, 0x00, 0x80, 0x03, 0x88, 0x04,
       0x1c, 0x07, 0x3e, 0x00, 0x7f, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(11) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x00, 0x07, 0x80, 0x01, 0x80, 0x00, 0x80, 0x07, 0xff, 0x04,
       0x3e, 0x03, 0x1c, 0x00, 0x08, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(12) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x80, 0x07, 0x00, 0x04, 0x00, 0x02, 0x00, 0x02, 0x08, 0x02,
       0x1c, 0x01, 0x3e, 0x00, 0x7f, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(13) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x80, 0x07, 0x00, 0x04, 0x00, 0x02, 0x00, 0x02, 0x7f, 0x02,
       0x3e, 0x01, 0x1c, 0x00, 0x08, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(14) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x00, 0x03, 0x80, 0x04, 0x80, 0x04, 0x00, 0x03, 0x88, 0x04,
       0x9c, 0x07, 0x3e, 0x00, 0x7f, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(15) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x00, 0x03, 0x80, 0x04, 0x80, 0x04, 0x00, 0x03, 0xff, 0x04,
       0xbe, 0x07, 0x1c, 0x00, 0x08, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(16) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x00, 0x03, 0x80, 0x04, 0x80, 0x07, 0x00, 0x04, 0x08, 0x06,
       0x9c, 0x03, 0x3e, 0x00, 0x7f, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(17) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x00, 0x03, 0x80, 0x04, 0x80, 0x07, 0x00, 0x04, 0x7f, 0x06,
       0xbe, 0x03, 0x1c, 0x00, 0x08, 0x00, 0x00, 0x00 };
}

##########################################################################
