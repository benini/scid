###
### windows.tcl: part of Scid.
### Copyright (C) 1999-2001  Shane Hudson.
###


########################################################################
###  Optional windows: all off initially.

set treeWin 0
set pgnWin 0
set statsWin 0
set commentWin 0
set bookWin 0
set filterGraph 0

set nagValue 0

# recordWinSize:
#   Records window width and height, for saving in options file.
#
proc recordWinSize {win} {
  global winWidth winHeight tempWidth tempHeight winX winY
  if {![winfo exists $win]} { return }
  set temp [wm geometry $win]
  set n [scan $temp "%dx%d" tempWidth tempHeight]
  if {$n == 2} {
    set winWidth($win) $tempWidth
    set winHeight($win) $tempHeight
  }
  set tempX [winfo rootx $win]
  set tempY [winfo rooty $win]
  incr tempX -$winX(offset)
  incr tempY -$winY(offset)
  set winX($win) $tempX
  set winY($win) $tempY
}

proc setWinLocation {win} {
  global winX winY
  if {[info exists winX($win)]  &&  [info exists winY($win)]  && \
        $winX($win) >= 0  &&  $winY($win) >= 0} {
    wm geometry $win "+$winX($win)+$winY($win)"
  }
}

########################################################################
### Games list window

set glist 0
set glstart 1
set glSelection 0
set glNumber 0

array set glName {
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
wm withdraw .glistExtra
wm overrideredirect .glistExtra 1
text .glistExtra.text -font font_Small -background lightYellow \
  -width 40 -height 8 -wrap word -relief solid -borderwidth 1
pack .glistExtra.text -side top

set glistMaxWidth 30

set glFindText ""
set glGoto ""
trace variable glGoto w {forceRegexp {^[0-9]*$}}

proc findGListText {} {
  global glstart glFindtext
  busyCursor .glistWin 1
  set temp [sc_filter textfind $glstart $glFindtext]
  busyCursor .glistWin 0
  if {$temp < 1} { set temp 1 }
  set glstart $temp
  updateGList
}

proc makeGList {} {
  global glist glstart glistSize highcolor glSelection helpMessage
  global glistFields glNumber glGoto glFindText buttoncolor glName
  if [winfo exists .glistWin] {
    focus .
    destroy .glistWin
    set glist 0
    return
  }
  set w .glistWin
  toplevel $w
  # Window is only directly resizable vertically:
  wm resizable $w false true
  setWinLocation $w

  # Pack buttons frame first:
  pack [frame $w.b] -side bottom -fill x -ipady 5 -padx 10
  scale $w.scale -from 1 -length 250 -orient horiz \
    -variable glstart -showvalue 0 -command {setGLstart} \
    -bigincrement $glistSize -takefocus 0 -width 10 -troughcolor $buttoncolor
  pack $w.scale -side bottom -fill x -padx 30 -pady 4
  frame $w.columns -takefocus 1 -highlightcolor black -highlightthickness 2
  pack $w.columns -side top -expand yes -fill both

  # Make each column in the listing:
  foreach i $glistFields {
    set code [lindex $i 0]
    set width [lindex $i 1]
    set justify [lindex $i 2]
    set fgcolor [lindex $i 3]
    set sep [lindex $i 4]
    frame $w.c$code

    if {[info exists glName($code)]} { set name $glName($code) }
    if {[info exists ::tr(Glist$name)]} { set name $::tr(Glist$name) }

    # Each heading is a label:
    label $w.c$code.header -foreground darkBlue -width $width \
      -font font_Small -relief flat -background gray90 \
      -text $name -anchor w
    set helpMessage(E,$w.c$code.header) \
      {Press the left or right mouse button here for a configuration menu}

    bind $w.c$code.header <Control-ButtonPress-3> "incrGLwidth $code; break"
    bind $w.c$code.header <Control-ButtonPress-1> "decrGLwidth $code; break"
    bind $w.c$code.header <Shift-ButtonPress-3> "incrGLwidth $code; break"
    bind $w.c$code.header <Shift-ButtonPress-1> "decrGLwidth $code; break"
    bind $w.c$code.header <ButtonPress-1> "popupGLconfig $code %x %y %X %Y"
    bind $w.c$code.header <ButtonPress-3> "popupGLconfig $code %x %y %X %Y"
    pack $w.c$code -in $w.columns -side left -expand yes -fill y -padx 0
    pack $w.c$code.header -side top
    addHorizontalRule $w.c$code 1 flat

    text $w.c$code.text -background white -width $width \
      -height $glistSize -font font_Small -relief flat \
      -foreground $fgcolor -wrap none -setgrid 1 -cursor top_left_arrow
    $w.c$code.text tag configure align -justify $justify \
      -foreground $fgcolor
    $w.c$code.text tag configure highlight -background lightBlue
    $w.c$code.text tag configure current -background lightYellow2
    $w.c$code.text tag configure underline -underline true

    bind $w.c$code.text <Button1-Motion> "break"
    bind $w.c$code.text <Button2-Motion> "break"
    bind $w.c$code.text <Double-Button-1> \
      "setGLselection $code %x %y; gameLoad \$glNumber; break"
    bind $w.c$code.text <Button-1> \
      "setGLselection $code %x %y; highlightGLline \$glSelection; break"
    bind $w.c$code.text <ButtonRelease-1> \
      "setGLselection $code %x %y; unhighlightGL; break"

    bind $w.c$code.text <ButtonPress-3> "popupGLmenu $code %x %y %X %Y"

    bind $w.c$code.text <ButtonPress-2> \
      "setGLselection $code %x %y; showMovesGList %X %Y; break"
    bind $w.c$code.text <ButtonRelease-2> \
      "wm withdraw .glistExtra; unhighlightGL; break"

    pack $w.c$code.text -side top -expand true -fill y
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
  $w.popup add command -label $::tr(BrowseGame) \
    -command {::gbrowser::new 0 $glNumber}
  $w.popup add command -label $::tr(LoadGame) -command {gameLoad $glNumber}
  $w.popup add command -label $::tr(MergeGame) -command mergeGame
  $w.popup add separator
  $w.popup add command -label "Remove this game from Filter" \
    -command removeFromFilter
  $w.popup add command -label "Remove game (and all above it) from Filter" \
    -command {removeFromFilter up}
  $w.popup add command -label "Remove game (and all below it) from Filter" \
    -command {removeFromFilter down}
  $w.popup add separator
  $w.popup add command -label "(Un)Delete this game" \
    -command {toggleGameFlag delete}
  $w.popup add command -label "Delete all games in filter" \
    -command {catch {sc_game flag delete filter 1}; updateGList}
  $w.popup add command -label "Undelete all games in filter" \
    -command {catch {sc_game flag delete filter 0}; updateGList}

  button $w.b.start -image tb_start -command {set glstart 1; updateGList}
  set helpMessage(E,$w.b.start) {Go to the first page of games}

  button $w.b.pgup -image tb_prev -command {
    set glstart [expr $glstart - $glistSize];
    if {$glstart < 1} { set glstart 1 };
    updateGList
  }
  set helpMessage(E,$w.b.pgup) {Previous page of games}

  button $w.b.pgdn -image tb_next  -command {
    set glstart [expr $glstart + $glistSize];
    if {$glstart > [sc_filter count] } {
      set glstart [sc_filter count]
    }
    if {$glstart < 1} { set glstart 1 }
    updateGList
  }
  set helpMessage(E,$w.b.pgdn) {Next page of games}

  button $w.b.end -image tb_end -command {
    set glstart [expr [sc_filter count] - $glistSize + 1]
    if {$glstart < 1} { set glstart 1}
    updateGList
  }
  set helpMessage(E,$w.b.end) {Go to the last page of games}

  button $w.b.current -textvar ::tr(Current) -font font_Small -command {
    set glstart [sc_filter locate [sc_game number]]
    if {$glstart < 1} { set glstart 1}
    updateGList
  }

  bind $w <Up> {
    set glstart [expr $glstart - 1]
    if {$glstart < 1} { set glstart 1 }
    updateGList
  }
  bind $w <Down> {
    set glstart [expr $glstart + 1]
    if {$glstart > [sc_filter count] } {
      set glstart [sc_filter count]
    }
    updateGList
  }

  bind $w <Home>  "$w.b.start invoke"
  bind $w <End>   "$w.b.end invoke"
  bind $w <Prior> "$w.b.pgup invoke"
  bind $w <Next>  "$w.b.pgdn invoke"

  label $w.b.gotolabel -textvar ::tr(GlistGameNumber:)
  entry $w.b.goto -bg white -width 8 -textvariable glGoto
  bind $w.b.goto <Home> "$w.b.start invoke; break"
  bind $w.b.goto <End> "$w.b.end invoke; break"
  bind $w.b.goto <Return> {
    set glstart [sc_filter locate $glGoto]
    if {$glstart < 1} { set glstart 1}
    set glGoto ""
    updateGList
  }

  label $w.b.findlabel -textvar ::tr(GlistFindText:)
  entry $w.b.find -background white -width 15 -textvariable glFindtext
  bind $w.b.find <Return> findGListText
  bind $w.b.find <Home> "$w.b.find icursor 0; break"
  bind $w.b.find <End> "$w.b.find icursor end; break"

  frame $w.b.space -width 0.25c
  frame $w.b.space2 -width 0.25c

  button $w.b.export -textvar ::tr(Save...) -command openExportGList
  button $w.b.help -textvar ::tr(Help) -command { helpWindow GameList }
  button $w.b.close -textvar ::tr(Close) -command { focus .; destroy .glistWin }

  pack $w.b.start $w.b.pgup $w.b.pgdn $w.b.end $w.b.current -side left -padx 1
  pack $w.b.space $w.b.gotolabel $w.b.goto -side left
  pack $w.b.space2 $w.b.findlabel $w.b.find -side left
  pack $w.b.close $w.b.help $w.b.export -side right -padx 5

  set glist 1
  bind $w <F1> { helpWindow GameList }
  bind $w <Destroy> { set glist 0 }
  bind $w <Escape> "$w.b.close invoke"
  standardShortcuts $w

  # Binding to reset glistSize when the window is resized:
  # The way this is done is very ugly, but the only way I could
  # find that actually works.
  # Set temp to window geometry (e.g. 80x20+...) and then
  # extract the part between the "x" and the first "+" or "-":
  bind $w <Configure> {
    recordWinSize .glistWin
    set temp [wm geometry .glistWin]
    set temp [string range $temp [expr [string first "x" $temp] + 1] end]
    set idx [string first "+" $temp]
    if {$idx != -1} {
      set temp [string range $temp 0 [expr $idx - 1]]
    }
    set idx [string first "-" $temp]
    if {$idx != -1} {
      set temp [string range $temp 0 [expr $idx - 1]]
    }
    if {$temp != $glistSize && $temp > 0} {
      set glistSize $temp
      updateGList
    }
  }

  wm iconname $w "Scid: [tr WindowsGList]"
  updateGList
  focus $w.b.goto
}

proc setGLselection {code xcoord ycoord} {
  global glSelection glNumber
  set glSelection [expr int([.glistWin.c$code.text index @$xcoord,$ycoord])]
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

proc unhighlightGL {} {
  global glistFields glistSize
  foreach column $glistFields {
    set code [lindex $column 0]
    .glistWin.c$code.text tag remove highlight 1.0 end
  }
}

proc highlightGLline {linenum} {
  global glistFields glistSize
  foreach column $glistFields {
    set code [lindex $column 0]
    .glistWin.c$code.text tag remove highlight 1.0 end
    .glistWin.c$code.text tag add highlight $linenum.0 [expr $linenum+1].0
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
      set name $::glName($tcode)
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
  $menu post $xscreen [expr $yscreen + 2]
  event generate $menu <ButtonPress-1>
}

array set glconfig {}

proc configGLdialog {code} {
  global glistFields glconfig glName
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
  label $w.title -text "$glName($code)" -font font_Bold
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
  centreWin $w
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
  destroy .glistWin
  makeGList
}

proc moveGLfield {code delta} {
  global glistFields
  set len [llength $glistFields]
  for {set i 0} {$i < $len} {incr i} {
    set column [lindex $glistFields $i]
    set tcode [lindex $column 0]
    if {$tcode == $code} {
      set glistFields [lreplace $glistFields $i $i]
      set insert [expr $i + $delta]
      set glistFields [linsert $glistFields $insert $column]
      break
    }
  }
  destroy .glistWin
  makeGList
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
  destroy .glistWin
  makeGList
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
  destroy .glistWin
  makeGList
}

proc popupGLmenu {code xcoord ycoord xscreen yscreen} {
  global glSelection glNumber
  setGLselection $code $xcoord $ycoord
  if {$glNumber < 1} {return}
  highlightGLline $glSelection
  if {[sc_base isReadOnly]} {
    .glistWin.popup entryconfig "*elete this*" -state disabled
    .glistWin.popup entryconfig "Delete all*" -state disabled
    .glistWin.popup entryconfig "Undelete all*" -state disabled
  } else {
    .glistWin.popup entryconfig "*elete this*" -state normal
    .glistWin.popup entryconfig "Delete all*" -state normal
    .glistWin.popup entryconfig "Undelete all*" -state normal
  }
  .glistWin.popup post $xscreen [expr $yscreen + 2]
  event generate .glistWin.popup <ButtonPress-1>
}

proc setGLstart { start } {
  global glstart
  set glstart $start
  updateGList
}

proc toggleGameFlag {flag} {
  global glNumber
  # If an invalid game number, just return:
  if {$glNumber < 1} { return }
  if {$glNumber > [sc_base numGames]} { return }
  catch {sc_game flag $flag $glNumber invert}
  updateGList
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
  updateStatsWin
  updateGList
}

proc showMovesGList {xcoord ycoord} {
  global glistSelectPly glNumber glSelection
  # If an invalid game number, just return:
  if {$glNumber < 1} { return }
  if {$glNumber > [sc_base numGames]} { return }

  highlightGLline $glSelection
  .glistExtra.text delete 1.0 end
  .glistExtra.text insert end [sc_game firstMoves $glNumber $glistSelectPly]
  wm geometry .glistExtra +$xcoord+$ycoord
  wm deiconify .glistExtra
  raiseWin .glistExtra
}

proc updateGList {} {
  global glistSize glstart
  global glistFields
  updateStatusBar
  if ![winfo exists .glistWin] { return }
  set totalSize [sc_filter count]
  set linenum [sc_game list $glstart $glistSize -current]
  foreach column $glistFields {
    set code [lindex $column 0]
    set cformat $code
    append cformat "*\n"
    .glistWin.c$code.text config -state normal
    .glistWin.c$code.text delete 1.0 end
    .glistWin.c$code.text insert end \
      [sc_game list $glstart $glistSize $cformat] align
    if {$linenum > 0} {
      .glistWin.c$code.text tag add current $linenum.0 [expr $linenum+1].0
    }
    .glistWin.c$code.text config -state disabled
  }

  # Now update the window title:
  set str "Scid [tr WindowsGList]: "
  if {$totalSize > 0} {
    set right [expr $totalSize + 1 - $glistSize]
    if {$right < 1} { set right 1 }
    .glistWin.scale configure -to $right
    set glend [expr $glstart + $glistSize - 1]
    if {$glend > $totalSize} { set glend $totalSize}
    append str [thousands $glstart] " .. " \
      [thousands $glend] " / " [thousands $totalSize] " " $::tr(games)
  } else {
    append str $::tr(noGames)
    .glistWin.scale configure -to 1
  }
  wm title .glistWin $str
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
  text $w.tfmt -width 1 -height 5 -font font_Fixed -fg black \
    -wrap none -relief flat
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
  set fname [tk_getSaveFile -filetypes $ftypes -parent .glexport \
               -title "Scid: Save Game List"]
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


############################################################
### TREE window

namespace eval ::tree {}
set tree(training) 0
set tree(locked) 0
set tree(base) 0
set tree(status) ""

proc ::tree::configMenus {{lang ""}} {
  if {! [winfo exists .treeWin]} { return }
  if {$lang == ""} { set lang $::language }
  set m .treeWin.menu
  foreach menu {file sort opt help} tag {File Sort Opt Help} {
    configMenuName $m.$menu Tree$tag $lang
  }
  foreach idx {0 1 3 4 6 8} tag {Save Fill Best Graph Copy Close} {
    configMenuText $m.file.m $idx TreeFile$tag $lang
  }
  foreach idx {0 1 2 3} tag {Alpha ECO Freq Score} {
    configMenuText $m.sort.m $idx TreeSort$tag $lang
  }
  foreach idx {0 1 3} tag {Lock Training Autosave} {
    configMenuText $m.opt.m $idx TreeOpt$tag $lang
  }
  foreach idx {0 1} tag {Tree Index} {
    configMenuText $m.help.m $idx TreeHelp$tag $lang
  }
}

proc ::tree::copyToSelection {args} {
  set sel [join [.treeWin.f.tl get 0 end] "\n"]
  append sel "\n"
  return $sel
}

proc ::tree::make {} {
  global tree treeWin highcolor geometry helpMessage
  if {[winfo exists .treeWin]} {
    focus .
    destroy .treeWin
    set treeWin 0
    return
  }
  toplevel .treeWin
  set w .treeWin
  setWinLocation $w

  # Set the tree window title now:
  wm title $w "Scid: [tr WindowsTree]"
  set treeWin 1
  set tree(training) 0

  bind $w <Destroy> { set treeWin 0; set tree(locked) 0 }
  bind $w <F1> { helpWindow Tree }
  bind $w <Escape> { .treeWin.buttons.stop invoke }
  standardShortcuts $w

  frame $w.menu
  pack $w.menu -side top -fill x
  $w configure -menu $w.menu
  menubutton $w.menu.file -text TreeFile -menu $w.menu.file.m
  menubutton $w.menu.sort -text TreeSort -menu $w.menu.sort.m
  menubutton $w.menu.opt  -text TreeOpt  -menu $w.menu.opt.m
  menubutton $w.menu.help -text TreeHelp -menu $w.menu.help.m
  foreach i {file sort opt help} {
    menu $w.menu.$i.m -tearoff 0
    pack $w.menu.$i -side left
  }

  $w.menu.file.m add command -label TreeFileSave -command {
    busyCursor .
    update
    if {[catch {sc_tree write $tree(base)} result]} {
      tk_messageBox -type ok -icon warning -title "Scid: Error writing file" \
        -message $result
    }
    unbusyCursor .
  }
  set helpMessage($w.menu.file.m,0) TreeFileSave
  $w.menu.file.m add command -label TreeFileFill -command ::tree::prime
  set helpMessage($w.menu.file.m,1) TreeFileFill
  $w.menu.file.m add separator
  $w.menu.file.m add command -label TreeFileBest -command ::tree::best
  set helpMessage($w.menu.file.m,3) TreeFileBest
  $w.menu.file.m add command -label TreeFileGraph -command ::tree::graph
  set helpMessage($w.menu.file.m,4) TreeFileGraph
  $w.menu.file.m add separator
  $w.menu.file.m add command -label TreeFileCopy -command {
    clipboard clear
    clipboard append [::tree::copyToSelection]
    selection own .treeWin.f.tl
    selection get
  }
  set helpMessage($w.menu.file.m,6) TreeFileCopy
  $w.menu.file.m add separator
  $w.menu.file.m add command -label TreeFileClose \
    -command {.treeWin.buttons.close invoke}
  set helpMessage($w.menu.file.m,8) TreeFileClose

  foreach label {Alpha ECO Freq Score} value {alpha eco frequency score} {
    $w.menu.sort.m add radiobutton -label TreeSort$label \
      -variable tree(order) -value $value -command ::tree::refresh
  }

  $w.menu.opt.m add checkbutton -label TreeOptLock -variable tree(locked) \
    -command ::tree::toggleLock
  set helpMessage($w.menu.opt.m,0) TreeOptLock

  $w.menu.opt.m add checkbutton -label TreeOptTraining \
    -variable tree(training) -command ::tree::toggleTraining
  set helpMessage($w.menu.opt.m,1) TreeOptTraining

  $w.menu.opt.m add separator
  $w.menu.opt.m add checkbutton -label TreeOptAutosave \
    -variable tree(autoSave)
  set helpMessage($w.menu.opt.m,3) TreeOptAutosave

  $w.menu.help.m add command -label TreeHelpTree \
    -accelerator F1 -command {helpWindow Tree}
  $w.menu.help.m add command -label TreeHelpIndex -command {helpWindow Index}

  ::tree::configMenus

  frame $w.f
  listbox $w.f.tl -borderwidth 2 \
    -width $::winWidth($w) -height $::winHeight($w) \
    -font font_Fixed -foreground black -background white \
    -selectbackground $highcolor -selectmode browse -setgrid 1 \
    -yscroll "$w.f.ybar set" -xscroll "$w.f.xbar set"
  scrollbar $w.f.ybar -command ".treeWin.f.tl yview"
  scrollbar $w.f.xbar -orient horizontal -command ".treeWin.f.tl xview"
  canvas $w.progress -width 250 -height 15 -bg white -relief solid -border 1
  $w.progress create rectangle 0 0 0 0 -fill blue -outline blue -tags bar
  selection handle $w.f.tl ::tree::copyToSelection

  bind $w.f.tl <Destroy> {
    if {$tree(autoSave)} {
      busyCursor .
      catch [sc_tree write $tree(base)]
      unbusyCursor .
    }
  }

  bind $w <Configure> "recordWinSize $w"

  label $w.status -width 1 -anchor w -font font_Small \
    -relief sunken -textvar tree(status)
  pack $w.status -side bottom -fill x
  pack $w.progress -side bottom
  pack [frame $w.buttons -relief sunken] -side bottom -fill x
  pack $w.f -side top -expand 1 -fill both
  grid $w.f.tl -row 0 -column 0 -sticky news
  grid $w.f.ybar -row 0 -column 1 -sticky news
  grid $w.f.xbar -row 1 -column 0 -sticky news
  grid rowconfig $w.f 0 -weight 1 -minsize 0
  grid columnconfig $w.f 0 -weight 1 -minsize 0

  button $w.buttons.best -image b_list -command ::tree::best
  button $w.buttons.graph -image b_bargraph -command ::tree::graph
  checkbutton $w.buttons.lock -textvar ::tr(LockTree) \
    -variable tree(locked) -relief raised -pady 5 -padx 5 \
    -command ::tree::toggleLock
  checkbutton $w.buttons.training -textvar ::tr(Training) \
    -variable tree(training) -relief raised -pady 5 -padx 5 \
    -command ::tree::toggleTraining

  foreach {b t} {
    best TreeFileBest graph TreeFileGraph lock TreeOptLock
    training TreeOptTraining
  } {
    set helpMessage($w.buttons.$b) $t
  }

  button $w.buttons.stop -textvar ::tr(Stop) -command { sc_progressBar }
  button $w.buttons.close -textvar ::tr(Close) -command {
    set geometry(treeWin) [wm geometry .treeWin]
    focus .; destroy .treeWin
  }

  pack $w.buttons.best $w.buttons.graph $w.buttons.lock $w.buttons.training \
    -side left -padx 2 -pady 2
  pack $w.buttons.close $w.buttons.stop -side right -padx 2 -pady 2
  $w.buttons.stop configure -state disabled

  wm minsize $w 40 5

  bind $w.f.tl <Return> {
    tree::select [lindex [ .treeWin.f.tl curselection] 0]
  }
  bind $w.f.tl <ButtonRelease-1> {
    .treeWin.f.tl selection clear 0 end
    tree::select [ .treeWin.f.tl nearest %y ]
    .treeWin.f.tl selection clear 0 end
    break
  }

  wm protocol $w WM_DELETE_WINDOW { .treeWin.buttons.close invoke }
  ::tree::refresh
}

proc ::tree::toggleTraining {} {
  global tree
  if {$tree(training)} {
    ::tree::doTraining
  } else {
    ::tree::refresh
  }
}

proc ::tree::doTraining {{n 0}} {
  global tree
  if {$n != 1  &&  [winfo exists .analysisWin1]  &&  $::analysis(automove1)} {
    automove 1
    return
  }
  if {$n != 2  &&  [winfo exists .analysisWin2]  &&  $::analysis(automove2)} {
    automove 2
    return
  }
  if {[winfo exists .tbWin]  &&  $::tbTraining} {
    makeTBMove
    return
  }
  if {! [winfo exists .treeWin]} { return }
  if {$tree(training) == 0} { return }
  sc_tree click $tree(base) random
  updateBoardAndPgn .board
}

proc ::tree::toggleLock {} {
  global tree
  if {$tree(locked)} {
    set tree(base) [sc_base current]
  } else {
    set tree(base) 0
  }
  ::tree::refresh
}

proc ::tree::select { selection } {
  global tree
  if {! [winfo exists .treeWin]} { return }
  sc_tree click $tree(base) $selection
  .treeWin.f.tl selection clear 0 end
  updateBoardAndPgn .board
}

set tree(refresh) 0

proc ::tree::refresh {} {
  global tree treeWin glstart
  set w .treeWin

  if {![winfo exists $w]} { return }
  busyCursor .
  sc_progressBar $w.progress bar 251 16
  foreach button {best graph training lock close} {
    $w.buttons.$button configure -state disabled
  }
  $w.buttons.stop configure -state normal
  set tree(refresh) 1
  catch {grab $w.buttons.stop}

  update
  set base 0
  if {$tree(locked)} { set base $tree(base) }
  set moves [sc_tree search -hide $tree(training) -sort $tree(order) -base $base]
  catch {grab release $w.buttons.stop}
  set tree(refresh) 0
  foreach button {best graph training lock close} {
    $w.buttons.$button configure -state normal
  }
  $w.buttons.stop configure -state disabled -relief raised

  set moves [split $moves "\n"]
  set len [llength $moves]
  $w.f.tl delete 0 end
  for { set i 0 } { $i < $len } { incr i } {
    $w.f.tl insert end [lindex $moves $i]
  }
  catch {$w.f.tl itemconfigure 0 -foreground darkBlue}

  #set n [expr $len - 4]
  #if {$n > 0} {
  #  for {set i 1} {$i < $n} {incr i} {
  #    set f [string range [lindex $moves $i] 25 27]
  #    if {$f < 5} {
  #      catch {$w.f.tl itemconfigure $i -foreground gray50}
  #    }
  #  }
  #  while {$n < $len} {
  #    catch {$w.f.tl itemconfigure $n -foreground darkBlue}
  #    incr n
  #  }
  #}

  if {[winfo exists .treeBest]} { ::tree::best }

  unbusyCursor .
  $w.f.tl configure -cursor {}
  $w.f.tl selection clear 0 end

  ::tree::status
  set glstart 1
  updateStatsWin
  if {[winfo exists .treeGraph]} ::tree::graph
  updateGList
  updateTitle
}

proc ::tree::status {{msg ""}} {
  global tree
  if {$msg != ""} {
    set tree(status) $msg
    return
  }
  set s "  $::tr(Database)"
  set base [sc_base current]
  if {$tree(locked)} { set base $tree(base) }
  set status "  $::tr(Database) $base: [file tail [sc_base filename $base]]"
  if {$tree(locked)} { append status " ($::tr(TreeLocked))" }
  append status "   $::tr(Filter)"
  append status ": [filterText $base]"
  set tree(status) $status
}

set tree(standardLines) {
  {}
  {1.c4}
  {1.c4 c5}
  {1.c4 c5 2.Nf3}
  {1.c4 e5}
  {1.c4 Nf6}
  {1.c4 Nf6 2.Nc3}
  {1.d4}
  {1.d4 d5}
  {1.d4 d5 2.c4}
  {1.d4 d5 2.c4 c6}
  {1.d4 d5 2.c4 c6 3.Nf3}
  {1.d4 d5 2.c4 c6 3.Nf3 Nf6}
  {1.d4 d5 2.c4 c6 3.Nf3 Nf6 4.Nc3}
  {1.d4 d5 2.c4 c6 3.Nf3 Nf6 4.Nc3 dxc4}
  {1.d4 d5 2.c4 c6 3.Nf3 Nf6 4.Nc3 e6}
  {1.d4 d5 2.c4 c6 3.Nf3 Nf6 4.Nc3 e6 5.e3}
  {1.d4 d5 2.c4 e6}
  {1.d4 d5 2.c4 e6 3.Nc3}
  {1.d4 d5 2.c4 e6 3.Nc3 Nf6}
  {1.d4 d5 2.c4 e6 3.Nf3}
  {1.d4 d5 2.c4 dxc4}
  {1.d4 d5 2.c4 dxc4 3.Nf3}
  {1.d4 d5 2.c4 dxc4 3.Nf3 Nf6}
  {1.d4 d5 2.Nf3}
  {1.d4 d5 2.Nf3 Nf6}
  {1.d4 d5 2.Nf3 Nf6 3.c4}
  {1.d4 d6}
  {1.d4 d6 2.c4}
  {1.d4 Nf6}
  {1.d4 Nf6 2.c4}
  {1.d4 Nf6 2.c4 c5}
  {1.d4 Nf6 2.c4 d6}
  {1.d4 Nf6 2.c4 e6}
  {1.d4 Nf6 2.c4 e6 3.Nc3}
  {1.d4 Nf6 2.c4 e6 3.Nc3 Bb4}
  {1.d4 Nf6 2.c4 e6 3.Nf3}
  {1.d4 Nf6 2.c4 g6}
  {1.d4 Nf6 2.c4 g6 3.Nc3}
  {1.d4 Nf6 2.c4 g6 3.Nc3 Bg7}
  {1.d4 Nf6 2.c4 g6 3.Nc3 Bg7 4.e4}
  {1.d4 Nf6 2.c4 g6 3.Nc3 Bg7 4.e4 d6}
  {1.d4 Nf6 2.c4 g6 3.Nc3 Bg7 4.e4 d6 5.Nf3}
  {1.d4 Nf6 2.c4 g6 3.Nc3 Bg7 4.e4 d6 5.Nf3 O-O}
  {1.d4 Nf6 2.c4 g6 3.Nc3 Bg7 4.e4 d6 5.Nf3 O-O 6.Be2}
  {1.d4 Nf6 2.c4 g6 3.Nf3}
  {1.d4 Nf6 2.Bg5}
  {1.d4 Nf6 2.Bg5 Ne4}
  {1.d4 Nf6 2.Nf3}
  {1.d4 Nf6 2.Nf3 e6}
  {1.d4 Nf6 2.Nf3 g6}
  {1.e4}
  {1.e4 c5}
  {1.e4 c5 2.c3}
  {1.e4 c5 2.c3 d5}
  {1.e4 c5 2.c3 Nf6}
  {1.e4 c5 2.Nc3}
  {1.e4 c5 2.Nc3 Nc6}
  {1.e4 c5 2.Nf3}
  {1.e4 c5 2.Nf3 d6}
  {1.e4 c5 2.Nf3 d6 3.d4}
  {1.e4 c5 2.Nf3 d6 3.d4 cxd4}
  {1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4}
  {1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6}
  {1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3}
  {1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 a6}
  {1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 e6}
  {1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 g6}
  {1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 Nc6}
  {1.e4 c5 2.Nf3 d6 3.Bb5+}
  {1.e4 c5 2.Nf3 e6}
  {1.e4 c5 2.Nf3 Nc6}
  {1.e4 c5 2.Nf3 Nc6 3.d4}
  {1.e4 c5 2.Nf3 Nc6 3.Bb5}
  {1.e4 c6}
  {1.e4 c6 2.d4}
  {1.e4 c6 2.d4 d5}
  {1.e4 c6 2.d4 d5 3.e5}
  {1.e4 c6 2.d4 d5 3.Nc3}
  {1.e4 c6 2.d4 d5 3.Nd2}
  {1.e4 d5}
  {1.e4 d6}
  {1.e4 d6 2.d4}
  {1.e4 d6 2.d4 Nf6}
  {1.e4 d6 2.d4 Nf6 3.Nc3}
  {1.e4 e5}
  {1.e4 e5 2.Nf3}
  {1.e4 e5 2.Nf3 Nc6}
  {1.e4 e5 2.Nf3 Nc6 3.d4}
  {1.e4 e5 2.Nf3 Nc6 3.Bb5}
  {1.e4 e5 2.Nf3 Nc6 3.Bb5 a6}
  {1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4}
  {1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4 Nf6}
  {1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4 Nf6 5.O-O}
  {1.e4 e5 2.Nf3 Nc6 3.Bc4}
  {1.e4 e5 2.Nf3 Nf6}
  {1.e4 e6}
  {1.e4 e6 2.d4}
  {1.e4 e6 2.d4 d5}
  {1.e4 e6 2.d4 d5 3.Nc3}
  {1.e4 e6 2.d4 d5 3.Nc3 Bb4}
  {1.e4 e6 2.d4 d5 3.Nc3 Nf6}
  {1.e4 e6 2.d4 d5 3.Nd2}
  {1.e4 e6 2.d4 d5 3.Nd2 c5}
  {1.e4 e6 2.d4 d5 3.Nd2 Nf6}
  {1.e4 Nf6}
  {1.e4 Nf6 2.e5}
  {1.e4 Nf6 2.e5 Nd5}
  {1.Nf3}
  {1.Nf3 Nf6}
}

# ::tree::prime
#   Primes the tree for this database, filling it with a number of
#   common opening positions.
#
proc ::tree::prime {} {
  global tree
  if {! [winfo exists .treeWin]} { return }
  set base [sc_base current]
  if {$tree(locked)} { set base $tree(base) }
  if {! [sc_base inUse]} { return }
  set fname [sc_base filename $base]
  if {[string index $fname 0] == "\["  ||  [file extension $fname] == ".pgn"} {
    tk_messageBox -parent .treeWin -icon info -type ok -title "Scid" \
      -message "Sorry, only Scid-format database files can have a tree cache file."
    return
  }

  set ::interrupt 0
  progressWindow "Scid: [tr TreeFileFill]" "" $::tr(Cancel) {set ::interrupt 1}
  resetProgressWindow
  leftJustifyProgressWindow
  busyCursor .
  sc_game push
  set i 1
  set len [llength $tree(standardLines)]
  foreach line $tree(standardLines) {
    sc_game new
    set text [format "%3d/\%3d" $i $len]
    if {[llength $line] > 0}  {
      sc_move addSan $line
      changeProgressWindow "$text: $line"
    } else {
      changeProgressWindow "$text: start position"
    }
    sc_tree search -base $base
    updateProgressWindow $i $len
    incr i
    if {$::interrupt} {
      closeProgressWindow
      set ::interrupt 0
      sc_game pop
      unbusyCursor .
      ::tree::refresh
      return
    }
  }
  closeProgressWindow
  if {[catch {sc_tree write $base} result]} {
    #tk_messageBox -type ok -icon warning -title "Scid: Error writing file" \
        -message $result
  } else {
    #set a "$fname.stc: [sc_tree positions] positions, "
    #append a "$result bytes: "
    #set pergame [expr double($result) / double([sc_base numGames])]
    #append a [format "%.2f" $pergame]
    #append a " bytes per game"
    #tk_messageBox -type ok -parent .treeWin -title "Scid" -message $a
  }
  sc_game pop
  unbusyCursor .
  ::tree::refresh
}

set tree(bestMax) 50
trace variable tree(bestMax) w ::tree::best
set tree(bestRes) "1-0 0-1 1/2 *"
trace variable tree(bestRes) w ::tree::best

# ::tree::best
#   Updates the window of best (highest-rated) tree games.
#
proc ::tree::best {args} {
  global tree
  set w .treeBest
  if {! [winfo exists .treeWin]} { return }
  if {! [winfo exists $w]} {
    toplevel $w
    wm title $w "Scid: $::tr(TreeBestGames)"
    bind $w <Configure> "recordWinSize $w"
    setWinLocation $w
    bind $w <Escape> "destroy $w"
    bind $w <F1> {helpWindow Tree Best}
    pack [frame $w.b] -side bottom -fill x
    pack [frame $w.opt] -side bottom -fill x
    set pane [::pane::create $w.pane blist bpgn 520 320 0.6]
    ::pane::range $w.pane 0.3 0.8
    pack $pane -side top -expand true -fill both
    scrollbar $pane.blist.ybar -command "$pane.blist.list yview" -takefocus 0
    listbox $pane.blist.list -background white -selectbackground $::highcolor \
      -yscrollcommand "$pane.blist.ybar set" -font font_Small
    pack $pane.blist.ybar -side right -fill y
    pack $pane.blist.list -side left -fill both -expand yes
    bind $pane.blist.list <<ListboxSelect>> ::tree::bestPgn
    bind $pane.blist.list <Double-Button-1> ::tree::bestBrowse

    scrollbar $pane.bpgn.ybar -command "$pane.bpgn.text yview" -takefocus 0
    text $pane.bpgn.text -width 50 -height 20 -wrap none -background gray90 \
      -cursor top_left_arrow -yscrollcommand "$pane.bpgn.ybar set" -wrap word \
      -state disabled -font font_Small
    pack $pane.bpgn.ybar -side right -fill y
    pack $pane.bpgn.text -side left -fill both -expand yes
    set t $pane.bpgn.text
    bind $t <ButtonPress-1> "showPgnBoard $pane.bpgn.text 4 %x %y %X %Y"
    bind $t <ButtonRelease-1> hidePgnBoard
    bind $t <ButtonPress-2> "showPgnBoard $pane.bpgn.text 4 %x %y %X %Y"
    bind $t <ButtonRelease-2> hidePgnBoard
    bind $t <ButtonPress-3> "showPgnBoard $pane.bpgn.text 4 %x %y %X %Y"
    bind $t <ButtonRelease-3> hidePgnBoard

    label $w.opt.lmax -text $::tr(TreeBest:) -font font_Small
    set m [tk_optionMenu $w.opt.max tree(bestMax) 10 20 50 100 200 500]
    $m configure -font font_Small
    $w.opt.max configure -font font_Small
    label $w.opt.lres -text " $::tr(Result):" -font font_Small
    set m [tk_optionMenu $w.opt.res tree(bestRes) \
             "1-0 0-1 1/2 *" 1-0 0-1 "1-0 0-1" 1/2-1/2]
    $m configure -font font_Small
    $w.opt.res configure -font font_Small

    button $w.b.browse -text $::tr(BrowseGame) -command ::tree::bestBrowse
    button $w.b.load -text $::tr(LoadGame) -command ::tree::bestLoad
    button $w.b.merge -text $::tr(MergeGame) -command ::tree::bestMerge
    button $w.b.close -text $::tr(Close) -command "destroy $w"
    foreach i {browse load merge close} { $w.b.$i configure -font font_Small }
    pack $w.b.close $w.b.merge $w.b.load $w.b.browse \
      -side right -padx 1 -pady 2
    pack $w.opt.lmax $w.opt.max -side left -padx 0 -pady 2
    pack $w.opt.lres $w.opt.res -side left -padx 0 -pady 2
    focus $w.pane.blist.list
  }
  $w.pane.blist.list delete 0 end
  set tree(bestList) {}
  set count 0
  if {! [sc_base inUse]} { return }
  foreach {idx line} [sc_tree best $tree(base) $tree(bestMax) $tree(bestRes)] {
    incr count
    $w.pane.blist.list insert end "[format %02d $count]:  $line"
    lappend tree(bestList) $idx
  }
  catch {$w.pane.blist.list selection set 0}
  ::tree::bestPgn
}

proc ::tree::bestLoad {} {
  global tree
  if {[catch {set sel [.treeBest.pane.blist.list curselection]}]} { return }
  if {[catch {set g [lindex $tree(bestList) $sel]}]} { return }
  if {$tree(locked)} { sc_base switch $tree(base) }
  gameLoad $g
}

proc ::tree::bestMerge {} {
  global tree
  if {[catch {set sel [.treeBest.pane.blist.list curselection]}]} { return }
  if {[catch {set gnum [lindex $tree(bestList) $sel]}]} { return }
  set base [sc_base current]
  if {$tree(locked)} { set base $tree(base) }
  mergeGame $base $gnum
}

proc ::tree::bestBrowse {} {
  global tree
  if {[catch {set sel [.treeBest.pane.blist.list curselection]}]} { return }
  if {[catch {set gnum [lindex $tree(bestList) $sel]}]} { return }
  set base [sc_base current]
  if {$tree(locked)} { set base $tree(base) }
  ::gbrowser::new $base $gnum
}

proc ::tree::bestPgn {} {
  global tree
  set t .treeBest.pane.bpgn.text
  $t configure -state normal
  $t delete 1.0 end
  if {[catch {set sel [.treeBest.pane.blist.list curselection]}]} { return }
  if {[catch {set g [lindex $tree(bestList) $sel]}]} { return }
  set base [sc_base current]
  if {$tree(locked)} { set base $tree(base) }
  if {[catch {sc_game summary -base $base -game $g header} header]} { return }
  if {[catch {sc_game summary -base $base -game $g moves} moves]} { return }
  if {[catch {sc_filter value $base $g} ply]} { return }
  $t tag configure header -foreground darkBlue
  $t tag configure start -foreground darkRed
  $t insert end $header header
  $t insert end "\n\n"
  set m 0
  foreach move $moves {
    incr m
    if {$m < $ply} {
      $t insert end $move start
    } else {
      $t insert end $move
    }
    $t insert end " "
  }
  #catch {$t insert end [sc_game pgn -base $base -game $g \
  #                        -short 1 -indentC 1 -indentV 1 -symbol 1 -tags 0]}
  $t configure -state disabled
}

# ::tree::graph
#   Updates the tree graph window, creating it if necessary.
#
proc ::tree::graph {} {
  set w .treeGraph
  if {! [winfo exists .treeWin]} { return }
  if {! [winfo exists $w]} {
    toplevel $w
    setWinLocation $w
    bind $w <Escape> "destroy $w"
    bind $w <F1> {helpWindow Tree Graph}
    frame $w.menu -relief raised -borderwidth 2
    pack $w.menu -side top -fill x
    $w configure -menu $w.menu
    menubutton $w.menu.file -text GraphFile -menu $w.menu.file.m
    menu $w.menu.file.m
    $w.menu.file.m add command -label GraphFileColor \
      -command "saveGraph color $w.c"
    $w.menu.file.m add command -label GraphFileGrey \
      -command "saveGraph gray $w.c"
    $w.menu.file.m add separator
    $w.menu.file.m add command -label GraphFileClose -command "destroy $w"
    pack $w.menu.file -side left

    canvas $w.c -width 500 -height 300
    pack $w.c -side top -fill both -expand yes
    $w.c create text 25 10 -tag text -justify center -width 1 \
      -font font_Regular -anchor n
    bind $w <Configure> {
      .treeGraph.c itemconfigure text -width [expr [winfo width .treeGraph.c] - 50]
      .treeGraph.c coords text [expr [winfo width .treeGraph.c] / 2] 10
      ::graph::configure tree -height [expr [winfo height .treeGraph.c] - 100]
      ::graph::configure tree -width [expr [winfo width .treeGraph.c] - 50]
      ::graph::redraw tree
    }
    bind $w.c <Button-1> ::tree::graph
    wm title $w "Scid: Tree Graph"
    # wm minsize $w 300 200
    standardShortcuts $w
    ::tree::configGraphMenus
  }

  $w.c itemconfigure text -width [expr [winfo width $w.c] - 50]
  $w.c coords text [expr [winfo width $w.c] / 2] 10
  set height [expr [winfo height $w.c] - 100]
  set width [expr [winfo width $w.c] - 50]
  ::graph::create tree -width $width -height $height -xtop 25 -ytop 60 \
    -xmin 0.5 -xtick 1 -ytick 5 -font font_Small -canvas $w.c

  set data {}
  set xlabels {}
  set othersCount 0
  set numOthers 0
  set othersName "..."
  set count 0
  set othersScore 0.0
  set mean 50.0
  set totalGames 0
  set treeData [.treeWin.f.tl get 0 end]

  for {set i 0} {$i < [llength $treeData]} {incr i} {
    # Extract info from each line of the tree window:
    # Note we convert "," decimal char back to "." where necessary.
    set line [lindex $treeData $i]
    set mNum [string trim [string range $line  0  1]]
    set freq [string trim [string range $line 17 23]]
    set fpct [string trim [string range $line 25 29]]
    regsub -all {,} $fpct . fpct
    set move [string trim [string range $line  4 9]]
    set score [string trim [string range $line 33 37]]
    regsub -all {,} $score . score
    if {$score > 99.9} { set score 99.9 }
    # Check if this line is "TOTAL:" line:
    if {![string compare "TO" $mNum]} {
      set mean $score
      set totalGames $freq
    }
    # Add info for this move to the graph if necessary:
    if {[string index $line 2] == ":"  &&  [string compare "<end>" $move]} {
      if {$fpct < 1.0  ||  $freq < 5  ||  $i > 5} {
        incr othersCount $freq
        incr numOthers
        set othersScore [expr $othersScore + (double($freq) * $score)]
        set m $move
        if {$numOthers > 1} { set m "..." }
      } else {
        incr count
        lappend data $count
        lappend data $score
        lappend xlabels [list $count "$move ([expr round($score)]%)\n$freq: [expr round($fpct)]%"]
      }
    }
  }

  # Add extra bar for other moves if necessary:
  if {$numOthers > 0} {
    incr count
    set fpct [expr double($othersCount) * 100.0 / double($totalGames)]
    set sc [expr round($othersScore / double($othersCount))]
    set othersName "$m ($sc%)\n$othersCount: [expr round($fpct)]%"
    lappend data $count
    lappend data [expr $othersScore / double($othersCount)]
    lappend xlabels [list $count $othersName]
  }

  # Plot fake bounds data so graph at least shows range 40-65:
  ::graph::data tree bounds -points 0 -lines 0 -bars 0 -coords {1 41 1 64}

  # Replot the graph:
  ::graph::data tree data -color red -points 0 -lines 0 -bars 1 \
    -barwidth 0.75 -outline black -coords $data
  ::graph::configure tree -xlabels $xlabels -xmax [expr $count + 0.5] \
    -hline [list {gray80 1 each 5} {gray50 1 each 10} {black 2 at 50} \
              {black 1 at 55} [list red 2 at $mean]] \
    -brect [list [list 0.5 55 [expr $count + 0.5] 50 LightSkyBlue1]]

  ::graph::redraw tree
  set moves ""
  catch {set moves [sc_game firstMoves 0 -1]}
  if {[string length $moves] == 0} { set moves $::tr(StartPos) }
  set title "$moves ([thousands $totalGames] $::tr(games))"
  $w.c itemconfigure text -text $title
}

proc ::tree::configGraphMenus {{lang ""}} {
  if {! [winfo exists .treeGraph]} { return }
  if {$lang == ""} { set lang $::language }
  set m .treeGraph.menu
  foreach menu {file} tag {File} {
    configMenuName $m.$menu Graph$tag $lang
  }
  foreach idx {0 1 3} tag {Color Grey Close} {
    configMenuText $m.file.m $idx GraphFile$tag $lang
  }
}

# saveGraph:
#   Saves a graph (e.g. tree graph or rating graph) to a
#   color or greyscale Postscript file. The mode should be
#   "color" or "gray"
#
proc saveGraph {mode w} {
  if {! [winfo exists $w]} { return }
  set ftypes {{"PostScript files" {.eps .ps}} {"All files" *}}
  set fname [tk_getSaveFile -filetypes $ftypes -parent $w \
               -defaultextension ".eps" -title "Scid: Save Graph"]
  if {$fname == ""} { return }
  if {[catch {$w postscript -file $fname -colormode $mode} result]} {
    tk_messageBox -icon info -parent $w -title "Scid" -message $result
  }
}

###############################################
### Filter Statistics window

proc makeStatsWin {} {
  global statsWin stats
  set w .statsWin
  if [winfo exists $w] {
    focus .
    destroy $w
    set statsWin 0
    return
  }
  toplevel $w
  wm title $w "Scid: Filter Statistics"
  setWinLocation $w
  bind $w <Configure> "recordWinSize $w"

  frame $w.menu -borderwidth 3 -relief raised
  pack $w.menu -side top -fill x
  $w configure -menu $w.menu
  menubutton $w.menu.file -text StatsFile -menu $w.menu.file.m
  menubutton $w.menu.opt -text StatsOpt -menu $w.menu.opt.m
  menu $w.menu.file.m
  $w.menu.file.m add command -label StatsFilePrint -command {
    set ftype {
      { "Text files" {".txt"} }
      { "All files"  {"*"}    }
    }
    set fname [tk_getSaveFile -initialdir [pwd] -filetypes $ftype -title "Save text file"]
    if {$fname != ""} {
      if {[catch {set tempfile [open $fname w]}]} {
        tk_messageBox -title "Scid: Error saving file" -type ok -icon warning \
          -message "Unable to save the file: $fname\n\n"
      } else {
        puts $tempfile [.statsWin.stats get 1.0 end-1c]
        close $tempfile
      }
    }
  }
  $w.menu.file.m add separator
  $w.menu.file.m add command -label StatsFileClose -accelerator Esc \
      -command "destroy $w"

  menu $w.menu.opt.m
  $w.menu.opt.m add cascade -label $::tr(OprepStatBoth) -menu $w.menu.opt.m.elo
  menu $w.menu.opt.m.elo
  foreach i [lsort -decreasing [array names stats r*]] {
    set elo [string range $i 1 end]
    $w.menu.opt.m.elo add checkbutton -label "$::tr(OprepStatBoth) $elo+" \
      -variable stats($i) -command updateStatsWin
  }
  $w.menu.opt.m add separator
  $w.menu.opt.m add cascade -label $::tr(OprepStatSince) \
    -menu $w.menu.opt.m.year
  menu $w.menu.opt.m.year
  foreach i [lsort [array names stats y*]] {
    set year [string range $i 1 end]
    $w.menu.opt.m.year add checkbutton \
      -label "$::tr(OprepStatSince) $year.01.01" \
      -variable stats($i) -command updateStatsWin
  }

  pack $w.menu -side top -fill x
  pack $w.menu.file $w.menu.opt -side left

  text $w.stats -borderwidth 0 \
    -width $::winWidth($w) -height $::winHeight($w) -font font_Fixed \
    -foreground black -background white -cursor top_left_arrow -wrap none \
    -setgrid 1
  pack $w.stats -side top -fill both -expand yes
  set statsWin 1
  bind $w <Control-q> "destroy $w"
  bind $w <Escape> "destroy $w"
  bind $w <F1> { helpWindow Index }
  bind $w <Destroy> {
    set statsWin 0
  }
  standardShortcuts $w
  wm resizable $w 1 0
  configStatsMenus
  updateStatsWin
}

proc updateStatsWin {} {
  global statsWin stats
  if {[winfo exists .playerInfoWin]} { playerInfo }
  updateGList
  updateMaintWin
  updateStatusBar
  updateFilterGraph
  if {! [winfo exists .statsWin]} { return }

  # Set up variables for translated phrases:
  set all [capital $::tr(allGames)]
  set both $::tr(OprepStatBoth)
  set since $::tr(OprepStatSince)
  set games [capital $::tr(games)]
  set score [capital $::tr(score)]

  # Find length of longest left-hand column:
  set alen [expr [string length $all] + 1]
  set blen [expr [string length $both] + 7]
  set slen [expr [string length $since] + 12]
  set len $alen
  if {$len < $blen} { set len $blen }
  if {$len < $slen} { set len $slen }

  set height 4
  set ratings 0
  set years 0
  set rlist [lsort -decreasing [array names stats r*]]
  set ylist [lsort [array names stats y*]]

  foreach i $rlist {
    if {$stats($i)} { set ratings 1 }
  }
  foreach i $ylist {
    if {$stats($i)} { set years 1 }
  }

  if {$ratings} { incr height }
  if {$years} { incr height }

  set s ""
  set stat ""
  append s " [pad $stat [expr $len - 4]] [padR $games 10]"
  append s "     1-0     =-=     0-1 [padR $score 8]\n"
  append s "------------------------------------------------------------------------"
  append s "\n [pad $all $len]" [sc_filter stats all]

  if {$ratings} {
    append s "\n"
    foreach i $rlist {
      if {$stats($i)} {
        incr height
        set elo [string range $i 1 end]
        set stat "$both $elo+"
        append s "\n [pad $stat $len]"   [sc_filter stats elo $elo]
      }
    }
  }

  if {$years} {
    append s "\n"
    foreach i $ylist {
      if {$stats($i)} {
        incr height
        set year [string range $i 1 end]
        set stat "$since $year.01.01"
        append s "\n [pad $stat $len]"   [sc_filter stats year $year]
      }
    }
  }

  set w .statsWin.stats
  $w configure -state normal
  $w delete 1.0 end
  $w insert end $s
  $w tag configure blue -foreground darkBlue
  $w tag configure red -foreground red
  $w tag add blue 1.0 2.0
  $w tag add red 2.0 3.0
  $w configure -height $height
  $w configure -state disabled
}

proc configStatsMenus {{lang ""}} {
  if {! [winfo exists .statsWin]} { return }
  if {$lang == ""} { set lang $::language }
  set m .statsWin.menu
  foreach menu {file opt} tag {File Opt} {
    configMenuName $m.$menu Stats$tag $lang
  }
  foreach idx {0 2} tag {Print Close} {
    configMenuText $m.file.m $idx StatsFile$tag $lang
  }
}

#####################
# Filter graph window

# fgraphType: can be "decade", "year" or "elo"
set fgraphType decade

proc makeFilterGraph {} {
  global filterGraph
  set w .fgraph
  if {[winfo exists $w]} {
    focus .
    destroy $w
    set filterGraph 0
    return
  }
  toplevel $w
  wm title $w "Scid: Filter Graph"
  set filterGraph 1
  bind $w <Destroy> {set filterGraph 0}

  frame $w.b
  pack $w.b -side bottom -fill x
  label $w.b.status -width 1 -font font_Small -anchor w
  frame $w.sep -height 2 -borderwidth 2 -relief sunken -background white
  pack $w.sep -side bottom -fill x -pady 4

  canvas $w.c -width 500 -height 300
  $w.c create text 25 5 -tag title -justify center -width 1 \
    -font font_Small -anchor n
  $w.c create text 250 295 -tag type -justify center -width 1 \
    -font font_Small -anchor s
  pack $w.c -side top -expand yes -fill both
  ::graph::create filter

  bind $w <F1> {helpWindow Graphs Filter}
  bind $w <Configure> {
    .fgraph.c itemconfigure title -width [expr [winfo width .fgraph.c] - 50]
    .fgraph.c coords title [expr [winfo width .fgraph.c] / 2] 10
    .fgraph.c itemconfigure type -width [expr [winfo width .fgraph.c] - 50]
    .fgraph.c coords type [expr [winfo width .fgraph.c] / 2] \
      [expr [winfo height .fgraph.c] - 10]
    ::graph::configure filter -height [expr [winfo height .fgraph.c] - 80]
    ::graph::configure filter -width [expr [winfo width .fgraph.c] - 60]
    ::graph::redraw filter
  }
  bind $w.c <1> switchFilterGraph
  bind $w.c <3> updateFilterGraph

  foreach {name text} {decade Decade year Year elo Rating} {
    radiobutton $w.b.$name -variable fgraphType -value $name -padx 4 -pady 3 \
      -text $::tr($text) -indicatoron 0 -command updateFilterGraph
    pack $w.b.$name -side left -padx 1 -pady 2
  }
  button $w.b.close -text $::tr(Close) -command "destroy $w"
  pack $w.b.decade $w.b.elo -side left -padx 1 -pady 2
  pack $w.b.close -side right -padx 2 -pady 2
  pack $w.b.status -side left -padx 2 -pady 2 -fill x -expand yes

  updateFilterGraph
}

proc switchFilterGraph {} {
  global fgraphType
  switch $fgraphType {
    "decade" { set fgraphType "year" }
    "year" { set fgraphType "elo" }
    "elo" { set fgraphType "decade" }
  }
  updateFilterGraph
}

proc updateFilterGraph {} {
  global fgraphType
  set w .fgraph
  if {! [winfo exists $w]} { return }

  $w.c itemconfigure title -width [expr [winfo width $w.c] - 50]
  $w.c coords title [expr [winfo width $w.c] / 2] 10
  $w.c itemconfigure type -width [expr [winfo width $w.c] - 50]
  $w.c coords type [expr [winfo width $w.c] / 2] \
    [expr [winfo height $w.c] - 10]
  set height [expr [winfo height $w.c] - 80]
  set width [expr [winfo width $w.c] - 60]
  set vlines {}
  if {$fgraphType == "elo"} {
    # Vertical lines for Elo-range graph:
    for {set i 1} {$i < 9} { incr i } {
      lappend vlines [list gray80 1 at $i.5]
    }
  } elseif {$fgraphType == "year"} {
    # Vertical lines for Year-range graph:
    for {set i 1} {$i < 11} { incr i } {
      lappend vlines [list gray80 1 at $i.5]
    }
  } else {
    # Vertical lines for Decade graph: most are gray, but those
    # just before 1950s and 2000s are blue to make them stand out.
    for {set i 1} {$i < 10} {incr i} {
      set vlineColor gray80
      if {$i == 4  ||  $i == 9} { set vlineColor steelBlue }
      lappend vlines [list $vlineColor 1 at $i.5]
    }
  }
  ::graph::create filter -width $width -height $height -xtop 40 -ytop 35 \
    -ytick 1 -xtick 1 -font font_Small -canvas $w.c -textcolor black \
    -vline $vlines -background lightYellow -tickcolor black -xmin 0 -xmax 1
  ::graph::redraw filter
  busyCursor .
  update

  set count 0
  set dlist {}
  set xlabels {}
  set max 0.0

  # Generate plot values and labels:
  if {$fgraphType == "decade"} {
    set ftype date
    set typeName $::tr(Decade)
    set rlist [list 0000 1919 -1919  1920 1929 20-29 \
                 1930 1939 30-39  1940 1949 40-49  1950 1959 50-59 \
                 1960 1969 60-69  1970 1979 70-79  1980 1989 80-89 \
                 1990 1999 90-99  2000 2009 2000+]
  } elseif {$fgraphType == "year"} {
    set ftype date
    set typeName $::tr(Year)
    set endYear [::date::today year]
    set startYear [expr $endYear - 10]
    set rlist {}
    for {set i $startYear} {$i <= $endYear} {incr i} {
      lappend rlist $i
      lappend rlist $i
      lappend rlist $i
    }
  } else {
    set ftype elo
    set typeName $::tr(Rating)
    set rlist [list 0 1999 0-1999  2000 2099 20xx  2100 2199 21xx  \
                 2200 2299 22xx  2300 2399 23xx  2400 2499 24xx  \
                 2500 2599 25xx  2600 2699 26xx  2700 3999 2700+]
  }

  foreach {start end label} $rlist {
    if {$ftype == "date"} { append end ".12.31" }
    set r [sc_filter freq $ftype $start $end]
    set filter [lindex $r 0]
    set all [lindex $r 1]
    if {$all == 0} {
      set freq 0.0
    } else {
      set freq [expr double($filter) * 1000.0 / double($all)]
    }
    if {$freq >= 1000.0} { set freq 999.99 }
    incr count
    lappend dlist $count
    lappend dlist $freq
    if {$freq > $max} { set max $freq }
    lappend xlabels [list $count $label]
  }

  # Find a suitable spacing of y-axis labels:
  set ytick 0.1
  if {$max > 1.0} { set ytick 0.2 }
  if {$max > 2.5} { set ytick 0.5 }
  if {$max >   5} { set ytick   1 }
  if {$max >  10} { set ytick   2 }
  if {$max >  25} { set ytick   5 }
  if {$max >  50} { set ytick  10 }
  if {$max > 100} { set ytick  20 }
  if {$max > 250} { set ytick  50 }
  if {$max > 500} { set ytick 100 }
  set hlines [list [list gray80 1 each $ytick]]
  # Add mean horizontal line:
  set filter [sc_filter count]
  set all [sc_base numGames]
  if {$all > 0} {
    set mean [expr double($filter) * 1000.0 / double($all)]
    if {$mean >= 1000.0} { set mean 999.9 }
    lappend hlines [list red 1 at $mean]
  }

  # Create fake dataset with bounds so we see 0.0::
  #::graph::data decade bounds -points 0 -lines 0 -bars 0 -coords {1 0.0 1 0.0}

  ::graph::data filter data -color darkBlue -points 1 -lines 1 -bars 0 \
    -linewidth 2 -radius 4 -outline darkBlue -coords $dlist
  ::graph::configure filter -xlabels $xlabels -ytick $ytick \
    -hline $hlines -ymin 0 -xmin 0.5 -xmax [expr $count + 0.5]
  ::graph::redraw filter
  $w.c itemconfigure title -text $::tr(GraphFilterTitle)
  $w.c itemconfigure type -text $typeName
  $w.b.status configure -text "  $::tr(Filter): [filterText]"
  unbusyCursor .
  update
}



############################################################
### PGN window

proc choosePgnColor {type name} {
  global pgnColor
  set x [tk_chooseColor -initialcolor $pgnColor($type) \
           -title "PGN $name color"]
  if {$x != ""} { set pgnColor($type) $x; resetPgnColors }
}

proc configPgnMenus {{lang ""}} {
  if {! [winfo exists .pgnWin]} { return }
  if {$lang == ""} { set lang $::language }
  set m .pgnWin.menu
  foreach menu {file opt color help} tag {File Opt Color Help} {
    configMenuName $m.$menu Pgn$tag $lang
  }
  foreach idx {0 2} tag {Print Close} {
    configMenuText $m.file.m $idx PgnFile$tag $lang
  }
  foreach idx {0 1 2 3 4 5 6 7} tag {Color Short Symbols IndentC IndentV Space Column StripMarks} {
    configMenuText $m.opt.m $idx PgnOpt$tag $lang
  }
  foreach idx {0 1 2 3 4} tag {Header Anno Comments Vars Background} {
    configMenuText $m.color.m $idx PgnColor$tag $lang
  }
  foreach idx {0 1} tag {Pgn Index} {
    configMenuText $m.help.m $idx PgnHelp$tag $lang
  }
}

proc makePgnWin {} {
  global pgnWin pgnHeight pgnWidth pgnColor pgnColumn pgnStripMarks
  if [winfo exists .pgnWin] {
    focus .
    destroy .pgnWin
    set pgnWin 0
    return
  }
  set w [toplevel .pgnWin]
  setWinLocation $w
  bind $w <Configure> "recordWinSize $w"

  frame $w.menu -borderwidth 3 -relief raised
  pack $w.menu -side top -fill x
  $w configure -menu $w.menu
  menubutton $w.menu.file -text PgnFile -menu $w.menu.file.m -underline 0
  menubutton $w.menu.opt -text PgnOpt -menu $w.menu.opt.m -underline 0
  menubutton $w.menu.color -text PgnColor -menu $w.menu.color.m -underline 0
  menubutton $w.menu.help -text PgnHelp -menu $w.menu.help.m -underline 0
  foreach i {file opt color help} {
    menu $w.menu.$i.m -tearoff 0
    pack $w.menu.$i -side left
  }

  $w.menu.file.m add command -label PgnFilePrint -command {
    set ftype {
      { "PGN files"  {".pgn"} }
      { "Text files" {".txt"} }
      { "All files"  {"*"}    }
    }
    set fname [tk_getSaveFile -initialdir [pwd] -filetypes $ftype -title "Save PGN file"]
    if {$fname != ""} {
      if {[catch {set tempfile [open $fname w]}]} {
        tk_messageBox -title "Scid: Error saving file" -type ok -icon warning \
          -message "Unable to save the file: $fname\n\n"
      } else {
        puts $tempfile \
          [sc_game pgn -width 75 -symbols $pgnSymbolicNags \
             -indentVar $pgnIndentVars -indentCom $pgnIndentComments \
             -space $pgnMoveNumSpace -format plain -column $::pgnColumn \
             -markCodes $::pgnStripMarks]
        close $tempfile
      }
    }
  }
  $w.menu.file.m add separator
  $w.menu.file.m add command -label PgnFileClose -accelerator Esc \
      -command "focus .; destroy $w"

  $w.menu.opt.m add checkbutton -label PgnOptColor \
    -variable doColorPgn -command {updateBoardAndPgn .board}
  $w.menu.opt.m add checkbutton -label PgnOptShort \
    -variable pgnShortHeader -command {updateBoardAndPgn .board}
  $w.menu.opt.m add checkbutton -label PgnOptSymbols \
    -variable pgnSymbolicNags -command {updateBoardAndPgn .board}
  $w.menu.opt.m add checkbutton -label PgnOptIndentC \
    -variable pgnIndentComments -command {updateBoardAndPgn .board}
  $w.menu.opt.m add checkbutton -label PgnOptIndentV \
    -variable pgnIndentVars -command {updateBoardAndPgn .board}
  $w.menu.opt.m add checkbutton -label PgnOptSpace \
    -variable pgnMoveNumSpace -command {updateBoardAndPgn .board}
  $w.menu.opt.m add checkbutton -label PgnOptColumn \
    -variable pgnColumn -command {updateBoardAndPgn .board}
  $w.menu.opt.m add checkbutton -label PgnOptStripMarks \
    -variable pgnStripMarks -command {updateBoardAndPgn .board}

  $w.menu.color.m add command -label PgnColorHeader \
    -command {choosePgnColor Header "header text"}
  $w.menu.color.m add command -label PgnColorAnno \
    -command {choosePgnColor Nag annotation}
  $w.menu.color.m add command -label PgnColorComments \
    -command {choosePgnColor Comment comment}
  $w.menu.color.m add command -label PgnColorVars \
    -command {choosePgnColor Var variation}
  $w.menu.color.m add command -label PgnColorBackground \
    -command {choosePgnColor Background background}

  $w.menu.help.m add command -label PgnHelpPgn \
    -accelerator F1 -command {helpWindow PGN}
  $w.menu.help.m add command -label PgnHelpIndex -command {helpWindow Index}

  configPgnMenus

  text $w.text -width $::winWidth($w) -height $::winHeight($w) -wrap word \
    -background $pgnColor(Background) -cursor crosshair \
    -yscrollcommand "$w.scroll set" -setgrid 1 -tabs {1c right 2c 4c}
  scrollbar $w.scroll -command "$w.text yview" -takefocus 0
  pack [frame $w.buttons] -side bottom -fill x
  pack $w.scroll -side right -fill y
  pack $w.text -fill both -expand yes
  button $w.buttons.help -textvar ::tr(Help) -command { helpWindow PGN }
  button $w.buttons.close -textvar ::tr(Close) -command { focus .; destroy .pgnWin }
  #pack $w.buttons.close $w.buttons.help -side right -padx 5 -pady 2
  set pgnWin 1
  bind $w <Destroy> { set pgnWin 0 }

  # Bind middle or right button to popup a PGN board:
  bind $w <ButtonPress-2> "showPgnBoard .pgnWin.text 5 %x %y %X %Y"
  bind $w <ButtonRelease-2> hidePgnBoard
  bind $w <ButtonPress-3> "showPgnBoard .pgnWin.text 5 %x %y %X %Y"
  bind $w <ButtonRelease-3> hidePgnBoard

  # set the same arrow key, etc bindings that the main window has:
  bind $w <F1> { helpWindow PGN }
  bind $w <Home>  {sc_move start; updateBoard .board}
  bind $w <Up>    {sc_move back 10; updateBoard .board}
  bind $w <Left>  {sc_move back; updateBoard .board}
  bind $w <Down>  {sc_move forward 10; updateBoard .board}
  bind $w <Right> {sc_move forward; updateBoard .board}
  bind $w <End>   {sc_move end; updateBoard .board}
  bind $w <Escape> {focus .; destroy .pgnWin}
  standardShortcuts $w

  # Add variation navigation bindings:
  bind $w <KeyPress-v> [bind . <KeyPress-v>]
  bind $w <KeyPress-z> [bind . <KeyPress-z>]

  $w.text tag add Current 0.0 0.0
  resetPgnColors
}

# showPgnBoard:
#    Produces a popup window showing the board position in the
#    game at the current mouse location in the PGN window.
#
proc showPgnBoard {win startLine x y xc yc} {
  global lite dark
  set bd [sc_pos pgnBoard [$win get $startLine.0 @$x,$y]]
  set w .pgnPopup
  set psize 30
  if {$psize > $::boardSize} { set psize $::boardSize }

  if {! [winfo exists $w]} {
    toplevel $w -relief solid -borderwidth 2
    wm withdraw $w
    wm overrideredirect $w 1
    ::board::new $w.bd $psize
    pack $w.bd -side top -padx 2 -pady 2
    wm withdraw $w
  }

  ::board::update $w.bd $bd

  # Make sure the popup window can fit on the screen:
  incr xc 5
  incr yc 5
  update idletasks
  set dx [winfo width $w]
  set dy [winfo height $w]
  if {($xc+$dx) > [winfo screenwidth $w]} {
    set xc [expr [winfo screenwidth $w] - $dx]
  }
  if {($yc+$dy) > [winfo screenheight $w]} {
    set yc [expr [winfo screenheight $w] - $dy]
  }
  wm geometry $w "+$xc+$yc"
  wm deiconify $w
  raiseWin $w
}

# hidePgnBoard:
#    Hides the window produced by showPgnBoard.
#
proc hidePgnBoard {} {
  wm withdraw .pgnPopup
}

# resetPgnColors:
#    Reconfigures the pgn Colors, after a color is changed by the user
proc resetPgnColors {} {
  global pgnColor
  if {![winfo exists .pgnWin]} { return }
  .pgnWin.text configure -background $pgnColor(Background)
  .pgnWin.text tag configure Current -background $pgnColor(Current)
  .pgnWin.text tag configure NextMove -background $pgnColor(NextMove)
  ::htext::init .pgnWin.text
  ::htext::updateRate .pgnWin.text 60
  updatePgnWin 1
}

# updatePgnWin:
#    Updates the PGN window. If $pgnNeedsUpdate == 0, then the
#    window text is not regenerated; only the current and next move
#    tags will be updated.
#
proc updatePgnWin {{pgnNeedsUpdate 0}} {
  global doColorPgn pgnIndentVars pgnIndentComments pgnSymbolicNags
  global pgnMoveNumSpace pgnShortHeader pgnColumn pgnStripMarks
  if {![winfo exists .pgnWin]} { return }
  set format plain
  if {$doColorPgn} {set format color}
  set pgnStr [sc_game pgn -symbols $pgnSymbolicNags \
                -indentVar $pgnIndentVars -indentCom $pgnIndentComments \
                -space $pgnMoveNumSpace -format $format -column $pgnColumn \
                -short $pgnShortHeader -markCodes $pgnStripMarks]
  if {$pgnNeedsUpdate} {
    busyCursor .
    wm title .pgnWin "Scid: PGN of Game [sc_game number]"
    .pgnWin.text configure -state normal
    .pgnWin.text delete 1.0 end
    if {$doColorPgn} {
      #set start [clock clicks -milli]
      ::htext::display .pgnWin.text $pgnStr
      #set end [clock clicks -milli]
      #puts "PGN: [expr $end - $start] ms"
    } else {
      .pgnWin.text insert 1.0 $pgnStr
    }
    unbusyCursor .
  }

  if {$doColorPgn} {
    # Now update Current and NextMove tags:
    .pgnWin.text tag remove Current 1.0 end
    set offset [sc_pos pgnOffset]
    set moveRange [.pgnWin.text tag nextrange "m_$offset" 1.0]
    if {[llength $moveRange] == 2} {
      .pgnWin.text tag add Current [lindex $moveRange 0] [lindex $moveRange 1]
      .pgnWin.text see [lindex $moveRange 0]
    }

    .pgnWin.text tag remove NextMove 1.0 end
    set noffset [sc_pos pgnOffset next]
    if {$noffset == $offset} {set noffset 0}
    set moveRange [.pgnWin.text tag nextrange "m_$noffset" 1.0]
    if {[llength $moveRange] == 2} {
      .pgnWin.text tag add NextMove [lindex $moveRange 0] [lindex $moveRange 1]
    }
    .pgnWin.text configure -state disabled
  }
  return
}


############################################################
### Comment Editor window

proc addNag {nag} {
  if {![winfo exists .commentWin]} { return }
  .commentWin.nf.tf.text insert end "$nag  "
  storeComment
  updatePgnWin 1
}

proc makeCommentWin {} {
  global commentWin
  if {[winfo exists .commentWin]} {
    closeCommentWin
  } else {
    openCommentWin
  }
}

proc closeCommentWin {} {
  global commentWin
  if {[winfo exists .commentWin]} {
    focus .
    destroy .commentWin
    set commentWin 0
  }
}

proc openCommentWin {} {
  global commentWin nagValue highcolor helpMessage
  set commentWin 1
  if {[winfo exists .commentWin]} {
    focus .commentWin.cf.text
    return
  }
  set w .commentWin
  toplevel $w
  setWinLocation $w
  bind $w <F1> {helpWindow Comment}
  bind $w <Destroy> {set commentWin 0}

  # Comment frame:
  frame $w.cf
  text $w.cf.text -width $::winWidth($w) -height $::winHeight($w) \
    -background white -wrap word -font font_Regular \
    -yscrollcommand ".commentWin.cf.scroll set" -setgrid 1
  scrollbar $w.cf.scroll -command ".commentWin.cf.text yview"
  label $w.cf.label -font font_Bold -textvar ::tr(Comment)
  bindFocusColors $w.cf.text
  bind $w.cf.text <Alt-KeyRelease-c> { .commentWin.b.close invoke }
  bind $w.cf.text <Alt-KeyRelease-s> { .commentWin.b.store invoke }
  bind $w <Configure> "recordWinSize $w"

  # NAG frame:
  frame $w.nf -width 100
  frame $w.nf.tf
  entry $w.nf.tf.text -width 20 -background white
  bindFocusColors $w.nf.tf.text
  bind $w.nf.tf.text <Alt-KeyRelease-c> { .commentWin.b.close invoke }

  set nagbox $w.nf.tf.text
  set nagbuttons $w.nf.b
  frame $w.nf.b
  button $nagbuttons.b1 -text "!" -command {addNag "!"}
  set helpMessage(E,$nagbuttons.b1) {Good move}
  button $nagbuttons.b2 -text "?" -command {addNag "?"}
  set helpMessage(E,$nagbuttons.b2) {Poor move}
  button $nagbuttons.b3 -text "!!" -command {addNag "!!"}
  set helpMessage(E,$nagbuttons.b3) {Excellent move}
  button $nagbuttons.b4 -text "??" -command {addNag "??"}
  set helpMessage(E,$nagbuttons.b4) {Blunder; terrible move}
  button $nagbuttons.b5 -text "!?" -command {addNag "!?"}
  set helpMessage(E,$nagbuttons.b5) {Interesting move}
  button $nagbuttons.b6 -text "?!" -command {addNag "?!"}
  set helpMessage(E,$nagbuttons.b6) {Dubious move}
  button $nagbuttons.b7 -text "N" -command {addNag "N"}
  set helpMessage(E,$nagbuttons.b7) {Novelty; new move}
  button $nagbuttons.b8 -text "D" -command {addNag "D"}
  set helpMessage(E,$nagbuttons.b8) {Diagram symbol}

  frame $w.nf.b2
  set nagbuttons $w.nf.b2
  button $nagbuttons.b1 -text "+-" -command {addNag "+-"}
  set helpMessage(E,$nagbuttons.b1) {White has a decisive advantage}
  button $nagbuttons.b2 -text "+/-" -command {addNag "+/-"}
  set helpMessage(E,$nagbuttons.b2) {White has a clear advantage}
  button $nagbuttons.b3 -text "+=" -command {addNag "+="}
  set helpMessage(E,$nagbuttons.b3) {White has a slight advantage}
  button $nagbuttons.b4 -text "=" -command {addNag "="}
  set helpMessage(E,$nagbuttons.b4) {Equal or drawish position}
  button $nagbuttons.b5 -text "=+" -command {addNag "=+"}
  set helpMessage(E,$nagbuttons.b5) {Black has a slight advantage}
  button $nagbuttons.b6 -text "-/+" -command {addNag "-/+"}
  set helpMessage(E,$nagbuttons.b6) {Black has a clear advantage}
  button $nagbuttons.b7 -text "-+" -command {addNag "-+"}
  set helpMessage(E,$nagbuttons.b7) {Black has a decisive advantage}

  label $w.nf.label -font font_Bold -textvar ::tr(AnnotationSymbols)
  pack $w.nf -side top
  addHorizontalRule $w

  button $w.nf.tf.clear -textvar ::tr(Clear) \
    -command {.commentWin.nf.tf.text delete 0 end}
  set helpMessage(E,$w.nf.tf.clear) {Clear all symbols for this move}
  pack $w.nf.label -side top -expand 0
  pack $w.nf.tf -side top
  pack $w.nf.tf.text -side left
  pack $w.nf.tf.clear -side right -padx 20 -pady 5
  pack $w.nf.b -side top
  for {set i 1} { $i <= 8 } { incr i } {
    pack $w.nf.b.b$i -side left
  }
  pack $w.nf.b2 -side top
  for {set i 1} { $i <= 7 } { incr i } {
    pack $w.nf.b2.b$i -side left
  }

  frame $w.b
  pack $w.b -side bottom -ipady 4 -fill x -padx 2

  pack $w.cf -side top -expand 1 -fill both
  pack $w.cf.label -side top
  pack $w.cf.scroll -side right -fill y
  pack $w.cf.text -side right -expand 1 -fill both

  addHorizontalRule $w

  wm minsize $w 40 3

  # Buttons:

  button $w.b.mark -text "Insert mark..." -command {
    .commentWin.cf.text insert insert [insertMarkComment]
    storeComment
  }

  button $w.b.clear -textvar ::tr(Clear) \
    -command ".commentWin.cf.text delete 0.0 end"
  set helpMessage(E,$w.b.clear) {Clear this comment}
  button $w.b.revert -textvar ::tr(Revert) \
    -command updateCommentWin
  set helpMessage(E,$w.b.revert) {Revert to the stored comment}
  button $w.b.store -textvar ::tr(Store) \
    -command {storeComment; updatePgnWin 1}
  set helpMessage(E,$w.b.store) {Store this comment in the game}
  frame $w.b.space -width 10
  button $w.b.close -textvar ::tr(Close) \
    -command { set commentWin 0; focus .; destroy .commentWin}
  set helpMessage(E,$w.b.close) {Close the comment editor window}

  pack $w.b.close $w.b.space $w.b.store $w.b.revert $w.b.clear -side right
  pack $w.b.mark -side left

  wm title $w "Scid: Comment editor"
  wm iconname $w "Scid: Comment editor"
  updateCommentWin
  focus $w.cf.text
}

set insertMark(Text) ""
set insertMark(OK) 0
set insertMark(from) -1
set insertMark(to) -1
set insertMark(color) red
set insertMark(colorList) {
  red red2 orange yellow green darkGreen blue darkBlue purple
}

# insertMarkComment:
#   Produces a dialog box for inserting a square color mark
#   or arrow into the current comment.
#
proc insertMarkComment {} {
  global insertMark
  set w .markDlg
  if {![winfo exists .commentWin]} { return }
  toplevel $w
  wm title $w "Scid: Insert mark"
  set insertMark(Text) ""
  set insertMark(OK) 0
  set insertMark(from) -1
  set insertMark(to) -1

  ::board::new $w.bd
  pack $w.bd -side top

  pack [frame $w.c] -side top -pady 2
  foreach i $insertMark(colorList) {
    image create photo markColor_$i -width 20 -height 20
    markColor_$i put $i -to 1 1 18 18
    radiobutton $w.c.c$i -variable insertMark(color) -value $i \
      -indicatoron 0 -image markColor_$i -command insertMarkSelect
    pack $w.c.c$i -side left -padx 1
  }

  pack [frame $w.f] -side bottom -fill x -pady 2
  entry $w.f.e -textvar insertMark(Text) -width 30
  bindFocusColors $w.f.e
  button $w.f.ok -text OK -command "set insertMark(OK) 1; destroy $w"
  button $w.f.cancel -text $::tr(Cancel) -command "destroy $w"
  pack $w.f.cancel $w.f.ok -side right -padx 1
  pack $w.f.e -side left -padx 1

  for {set i 0} {$i < 64} {incr i} {
    ::board::bind $w.bd $i <1> "insertMarkSelect $i"
  }

  update
  catch {grab $w}
  tkwait window $w
  if {$insertMark(OK)} { return $insertMark(Text) }
  return ""
}

# insertMarkSelect:
#   Called when a square is selected in the Insert Mark dialog box.
#
proc insertMarkSelect {{sq -1}} {
  global insertMark
  set w .markDlg
  ::board::update $w.bd
  ::board::recolor $w.bd

  if {$sq >= 0} {
    if {$insertMark(from) < 0  ||  $insertMark(from) != $insertMark(to)} {
      set insertMark(from) $sq
      set insertMark(to) $sq
    } else {
      set insertMark(to) $sq
    }
  }

  set files [list a b c d e f g h]
  set from [lindex $files [expr $insertMark(from) % 8]]
  append from [expr int($insertMark(from)/8) + 1]
  set to [lindex $files [expr $insertMark(to) % 8]]
  append to [expr int($insertMark(to)/8) + 1]

  if {$insertMark(from) < 0} { return }
  if {$insertMark(from) == $insertMark(to)} {
    ::board::colorSquare $w.bd $insertMark(from) $insertMark(color)
    set insertMark(Text) "\[%mark $from $insertMark(color)\]"
  } else {
    ::board::arrow $w.bd $insertMark(from) $insertMark(to) $insertMark(color)
    set insertMark(Text) "\[%arrow $from $to $insertMark(color)\]"
  }
}

proc storeComment {} {
  if {![winfo exists .commentWin]} { return }
  sc_pos clearNags
  foreach i [split [.commentWin.nf.tf.text get] " "] {
    sc_pos addNag $i
  }

  # The "end-1c" below is because Tk adds a newline to text contents:
  set newComment [.commentWin.cf.text get 1.0 end-1c]
  set oldComment [sc_pos getComment]
  if {[string compare $oldComment $newComment]} {
    sc_pos setComment $newComment
    updateStatusBar
    updatePgnWin 1
    updateBoard .board
  }
}


proc updateCommentWin {} {
  if {![winfo exists .commentWin]} { return }
  set nag [sc_pos getNags]
  .commentWin.nf.tf.text configure -state normal
  .commentWin.nf.tf.text delete 0 end
  if {$nag != "0"} {
    .commentWin.nf.tf.text insert end $nag
  }
  .commentWin.cf.text delete 0.0 end
  .commentWin.cf.text insert 0.0 [sc_pos getComment]
}


######################################################################
### Crosstable window

set crosstab(sort) score
set crosstab(type) auto
set crosstab(ages) "+ages"
set crosstab(colors) "+colors"
set crosstab(ratings) "+ratings"
set crosstab(countries) "+countries"
set crosstab(titles) "+titles"
set crosstab(groups) "-groups"
set crosstab(breaks) "-breaks"
set crosstab(deleted) "-deleted"
set crosstab(cnumbers) "-numcolumns"
set crosstab(text) hypertext

proc configCrosstabMenus {{lang ""}} {
  if {! [winfo exists .crosstabWin]} { return }
  if {$lang == ""} { set lang $::language }
  set m .crosstabWin.menu
  foreach menu {file edit opt sort color help} tag {File Edit Opt Sort Color Help} {
    configMenuName $m.$menu Crosstab$tag $lang
  }
  foreach idx {0 1 2 4} tag {Text Html LaTeX Close} {
    configMenuText $m.file.m $idx CrosstabFile$tag $lang
  }
  foreach idx {0 1 2} tag {Event Site Date} {
    configMenuText $m.edit.m $idx CrosstabEdit$tag $lang
  }
  foreach idx {0 1 2 3 5 6 7 8 9 10 12 13 15} tag {All Swiss Knockout Auto Ages Nats Ratings Titles Breaks Deleted Colors ColumnNumbers Group} {
    configMenuText $m.opt.m $idx CrosstabOpt$tag $lang
  }
  foreach idx {0 1 2} tag {Name Rating Score} {
    configMenuText $m.sort.m $idx CrosstabSort$tag $lang
  }
  foreach idx {0 1} tag {Plain Hyper} {
    configMenuText $m.color.m $idx CrosstabColor$tag $lang
  }
  foreach idx {0 1} tag {Cross Index} {
    configMenuText $m.help.m $idx CrosstabHelp$tag $lang
  }
}

proc toggleCrosstabWin {} {
  set w .crosstabWin
  if {[winfo exists $w]} {
    destroy $w
  } else {
    crosstabWin
  }
}

proc updateCrosstabWin {} {
  set w .crosstabWin
  if {[winfo exists $w]} { crosstabWin }
}

proc crosstabWin {} {
  global crosstab
  set w .crosstabWin
  if {! [winfo exists $w]} {
    toplevel $w
    wm title $w "Scid: [tr ToolsCross]"
    wm minsize $w 50 5
    setWinLocation $w

    frame $w.menu -borderwidth 3 -relief raised
    pack $w.menu -side top -fill x
    $w configure -menu $w.menu
    menubutton $w.menu.file -text CrosstabFile -menu $w.menu.file.m
    menubutton $w.menu.edit -text CrosstabEdit -menu $w.menu.edit.m
    menubutton $w.menu.opt -text CrosstabOpt -menu $w.menu.opt.m
    menubutton $w.menu.sort -text CrosstabSort -menu $w.menu.sort.m
    menubutton $w.menu.color -text CrosstabText -menu $w.menu.color.m
    menubutton $w.menu.help -text CrosstabHelp -menu $w.menu.help.m
    foreach i {file edit opt sort color help} {
      menu $w.menu.$i.m -tearoff 0
      pack $w.menu.$i -side left
    }

    $w.menu.file.m add command -label CrosstabFileText -command {
      set ftype {
        { "Text files" {".txt"} }
        { "All files"  {"*"}    }
      }
      set fname [tk_getSaveFile -initialdir [pwd] -filetypes $ftype  -title "Save Crosstable"]
      if {$fname != ""} {
        if {[catch {set tempfile [open $fname w]}]} {
          tk_messageBox -title "Scid: Error saving file" \
            -type ok -icon warning \
            -message "Unable to save the file: $fname\n\n"
        } else {
          puts -nonewline $tempfile [.crosstabWin.f.text get 1.0 end]
          close $tempfile
        }
      }
    }
    $w.menu.file.m add command -label CrosstabFileHtml -command {
      set ftype {
        { "HTML files" {".html" ".htm"} }
        { "All files"  {"*"}    }
      }
      set fname [tk_getSaveFile -initialdir $::initialDir(html) -filetypes $ftype  -title "Save Crosstable as HTML"]
      if {$fname != ""} {
        if {[catch {set tempfile [open $fname w]}]} {
          tk_messageBox -title "Scid: Error saving file" \
            -type ok -icon warning \
            -message "Unable to save the file: $fname\n\n"
        } else {
          catch {sc_game crosstable html $crosstab(sort) $crosstab(type) \
                   $crosstab(ratings) $crosstab(countries) $crosstab(titles) \
                   $crosstab(colors) $crosstab(groups) $crosstab(ages) \
                   $crosstab(breaks) $crosstab(cnumbers) $crosstab(deleted)} \
            result
          puts $tempfile $result
          close $tempfile
        }
      }
    }
    $w.menu.file.m add command -label CrosstabFileLaTeX -command {
      set ftype {
        { "LaTeX files" {".tex" ".ltx"} }
        { "All files"  {"*"}    }
      }
      set fname [tk_getSaveFile -initialdir $::initialDir(tex) -filetypes $ftype  -title "Save Crosstable as LaTeX"]
      if {$fname != ""} {
        if {[catch {set tempfile [open $fname w]}]} {
          tk_messageBox -title "Scid: Error saving file" \
            -type ok -icon warning \
            -message "Unable to save the file: $fname\n\n"
        } else {
          catch {sc_game crosstable latex $crosstab(sort) $crosstab(type) \
                   $crosstab(ratings) $crosstab(countries) $crosstab(titles) \
                   $crosstab(colors) $crosstab(groups) $crosstab(ages) \
                   $crosstab(breaks) $crosstab(cnumbers) $crosstab(deleted)} \
            result
          puts $tempfile $result
          close $tempfile
        }
      }
    }
    $w.menu.file.m add separator
    $w.menu.file.m add command -label CrosstabFileClose \
      -command { .crosstabWin.b.cancel invoke } -accelerator Esc

    $w.menu.edit.m add command -label CrosstabEditEvent -command {
      makeNameEditor
      setNameEditorType event
      set editName [sc_game info event]
      set editNameNew ""
      set editNameSelect crosstable
    }
    $w.menu.edit.m add command -label CrosstabEditSite -command {
      makeNameEditor
      setNameEditorType site
      set editName [sc_game info site]
      set editNameNew ""
      set editNameSelect crosstable
    }
    $w.menu.edit.m add command -label CrosstabEditDate -command {
      makeNameEditor
      setNameEditorType date
      set editNameNew " "
      set editDate [sc_game info date]
      set editDateNew [sc_game info date]
      set editNameSelect crosstable
    }

    $w.menu.opt.m add radiobutton -label CrosstabOptAll \
      -variable crosstab(type) -value allplay -command crosstabWin
    $w.menu.opt.m add radiobutton -label CrosstabOptSwiss \
      -variable crosstab(type) -value swiss -command crosstabWin
    $w.menu.opt.m add radiobutton -label CrosstabOptKnockout \
      -variable crosstab(type) -value knockout -command crosstabWin
    $w.menu.opt.m add radiobutton -label CrosstabOptAuto \
      -variable crosstab(type) -value auto -command crosstabWin
    $w.menu.opt.m add separator
    $w.menu.opt.m add checkbutton -label CrosstabOptAges \
      -variable crosstab(ages) -onvalue "+ages" \
      -offvalue "-ages" -command crosstabWin
    $w.menu.opt.m add checkbutton -label CrosstabOptNats \
      -variable crosstab(countries) -onvalue "+countries" \
      -offvalue "-countries" -command crosstabWin
    $w.menu.opt.m add checkbutton -label CrosstabOptRatings \
      -variable crosstab(ratings) -onvalue "+ratings" -offvalue "-ratings" \
      -command crosstabWin
    $w.menu.opt.m add checkbutton -label CrosstabOptTitles \
      -variable crosstab(titles) -onvalue "+titles" -offvalue "-titles" \
      -command crosstabWin
    $w.menu.opt.m add checkbutton -label CrosstabOptBreaks \
      -variable crosstab(breaks) -onvalue "+breaks" \
      -offvalue "-breaks" -command crosstabWin
    $w.menu.opt.m add checkbutton -label CrosstabOptDeleted \
      -variable crosstab(deleted) -onvalue "+deleted" \
      -offvalue "-deleted" -command crosstabWin
    $w.menu.opt.m add separator
    $w.menu.opt.m add checkbutton -label CrosstabOptColors \
      -underline 0 -variable crosstab(colors) \
      -onvalue "+colors" -offvalue "-colors" -command crosstabWin
    $w.menu.opt.m add checkbutton -label CrosstabOptColumnNumbers \
      -underline 0 -variable crosstab(cnumbers) \
      -onvalue "+numcolumns" -offvalue "-numcolumns" -command crosstabWin
    $w.menu.opt.m add separator
    $w.menu.opt.m add checkbutton -label CrosstabOptGroup \
      -underline 0 -variable crosstab(groups) \
      -onvalue "+groups" -offvalue "-groups" -command crosstabWin

    $w.menu.sort.m add radiobutton -label CrosstabSortName \
      -variable crosstab(sort) -value name -command crosstabWin
    $w.menu.sort.m add radiobutton -label CrosstabSortRating \
      -variable crosstab(sort) -value rating -command crosstabWin
    $w.menu.sort.m add radiobutton -label CrosstabSortScore \
      -variable crosstab(sort) -value score -command crosstabWin

    $w.menu.color.m add radiobutton -label CrosstabColorPlain \
      -variable crosstab(text) -value plain -command crosstabWin
    $w.menu.color.m add radiobutton -label CrosstabColorHyper \
      -variable crosstab(text) -value hypertext -command crosstabWin

    $w.menu.help.m add command -label CrosstabHelpCross \
      -accelerator F1 -command {helpWindow Crosstable}
    $w.menu.help.m add command -label CrosstabHelpIndex \
       -command {helpWindow Index}

    configCrosstabMenus

    frame $w.b
    pack $w.b -side bottom -fill x
    frame $w.f
    pack $w.f -side top -fill both -expand true
    text $w.f.text -width $::winWidth($w) -height $::winHeight($w) \
      -wrap none -font font_Fixed \
      -background white -yscroll "$w.f.ybar set" \
      -xscroll "$w.f.xbar set" -setgrid 1 -cursor top_left_arrow
    ::htext::init $w.f.text
    $w.f.text tag configure bgGray -background gray95
    scrollbar $w.f.ybar -command "$w.f.text yview"
    scrollbar $w.f.xbar -orient horizontal -command "$w.f.text xview"
    grid $w.f.text -row 0 -column 0 -sticky nesw
    grid $w.f.ybar -row 0 -column 1 -sticky nesw
    grid $w.f.xbar -row 1 -column 0 -sticky nesw
    grid rowconfig $w.f 0 -weight 1 -minsize 0
    grid columnconfig $w.f 0 -weight 1 -minsize 0
    button $w.b.stop -textvar ::tr(Stop) -state disabled \
      -command { set ::htext::interrupt 1 }
    menubutton $w.b.type -text "" -menu $w.b.type.menu \
      -relief raised -bd 2 -indicatoron 1
    menu $w.b.type.menu
    $w.b.type.menu add radiobutton -label [tr CrosstabOptAll] \
      -variable crosstab(type) -value allplay -command crosstabWin
    $w.b.type.menu add radiobutton -label [tr CrosstabOptSwiss] \
      -variable crosstab(type) -value swiss -command crosstabWin
    $w.b.type.menu add radiobutton -label [tr CrosstabOptKnockout] \
      -variable crosstab(type) -value knockout -command crosstabWin
    $w.b.type.menu add radiobutton -label [tr CrosstabOptAuto] \
      -variable crosstab(type) -value auto -command crosstabWin
    button $w.b.update -textvar ::tr(Update) -command crosstabWin
    button $w.b.cancel -textvar ::tr(Close) -command {
      focus .
      destroy .crosstabWin
    }
    button $w.b.setfilter -textvar ::tr(SetFilter) -command {
        searchReset
        searchNegate
        sc_game crosstable filter
        updateGList
    }
    button $w.b.addfilter -textvar ::tr(AddToFilter) -command {
        sc_game crosstable filter
        updateGList
    }
    pack $w.b.cancel $w.b.update $w.b.type \
      -side right -pady 3 -padx 5
    pack $w.b.setfilter $w.b.addfilter -side left -pady 3 -padx 5
    bind $w <Configure> "recordWinSize $w"
    bind $w <F1> { helpWindow Crosstable }
    bind $w <Return> { .crosstabWin.b.update invoke }
    bind $w <Escape> { .crosstabWin.b.cancel invoke }
    bind $w <Up> { .crosstabWin.f.text yview scroll -1 units }
    bind $w <Down> { .crosstabWin.f.text yview scroll 1 units }
    bind $w <Prior> { .crosstabWin.f.text yview scroll -1 pages }
    bind $w <Next> { .crosstabWin.f.text yview scroll 1 pages }
    bind $w <Left> { .crosstabWin.f.text xview scroll -1 units }
    bind $w <Right> { .crosstabWin.f.text xview scroll 1 units }
    bind $w <Key-Home> {
      .crosstabWin.f.text xview moveto 0
    }
    bind $w <Key-End> {
      .crosstabWin.f.text xview moveto 0.99
    }
    standardShortcuts $w
  }

  switch $crosstab(type) {
    allplay  { $w.b.type configure -text [tr CrosstabOptAll] }
    swiss    { $w.b.type configure -text [tr CrosstabOptSwiss] }
    knockout { $w.b.type configure -text [tr CrosstabOptKnockout] }
    auto     { $w.b.type configure -text [tr CrosstabOptAuto] }
  }
  $w.f.text configure -state normal
  $w.f.text delete 1.0 end
  busyCursor .
  $w.f.text configure -state disabled
  update idle
  $w.b.stop configure -state normal
  foreach button {update cancel setfilter addfilter type} {
    $w.b.$button configure -state disabled
  }
  pack $w.b.stop -side right -padx 5 -pady 3
  catch {grab $w.b.stop}
  update
  catch {sc_game crosstable $crosstab(text) $crosstab(sort) $crosstab(type) \
         $crosstab(ratings) $crosstab(countries) $crosstab(titles) \
         $crosstab(colors) $crosstab(groups) $crosstab(ages) \
         $crosstab(breaks) $crosstab(cnumbers) $crosstab(deleted)} result
  $w.f.text configure -state normal
  if {$crosstab(text) == "plain"} {
    $w.f.text insert end $result
  } else {
    ::htext::display $w.f.text $result
  }
  # Shade every second line to help readability:
  set lastLineNum [expr int([$w.f.text index end])]
  for {set i 2} {$i <= $lastLineNum} {incr i 2} {
    $w.f.text tag add bgGray $i.0 "$i.0 lineend +1c"
  }
  unbusyCursor .
  catch {grab release $w.b.stop}
  $w.b.stop configure -state disabled
  pack forget $w.b.stop
  foreach button {update cancel setfilter addfilter type} {
    $w.b.$button configure -state normal
  }
  $w.f.text configure -state disabled
  raiseWin $w
}


####################
# Game score graph

proc updateScoreGraph {} {
  set linecolor red
  set linewidth 2
  set psize 2

  set w .sgraph

  if {! [winfo exists $w]} {
    toplevel $w
    frame $w.menu -relief raised -borderwidth 2
    pack $w.menu -side top -fill x
    $w configure -menu $w.menu
    menubutton $w.menu.file -text GraphFile -menu $w.menu.file.m
    menu $w.menu.file.m
    $w.menu.file.m add command -label GraphFileColor \
      -command "saveGraph color $w.c"
    $w.menu.file.m add command -label GraphFileGrey \
      -command "saveGraph gray $w.c"
    $w.menu.file.m add separator
    $w.menu.file.m add command -label GraphFileClose -command "destroy $w"
    pack $w.menu.file -side left

    canvas $w.c -width 500 -height 300
    $w.c create text 25 5 -tag text -justify center -width 1 \
      -font font_Regular -anchor n
    pack $w.c -side top -expand yes -fill both
    bind $w <F1> {helpWindow Graphs Score}
    bind $w <Configure> {
      .sgraph.c itemconfigure text -width [expr [winfo width .sgraph.c] - 50]
      .sgraph.c coords text [expr [winfo width .sgraph.c] / 2] 10
      ::graph::configure score -height [expr [winfo height .sgraph.c] - 90]
      ::graph::configure score -width [expr [winfo width .sgraph.c] - 100]
      ::graph::redraw score
    }
    bind $w.c <3> updateScoreGraph
    bind $w.c <1> {moveInScoreGraph %x}
    wm title $w "Scid: [tr ToolsScore]"
    configScoreGraphMenus
  }

  $w.c itemconfigure text -width [expr [winfo width $w.c] - 50]
  $w.c coords text [expr [winfo width $w.c] / 2] 10
  set height [expr [winfo height $w.c] - 90]
  set width [expr [winfo width $w.c] - 100]
  ::graph::create score -width $width -height $height -xtop 50 -ytop 45 \
    -ytick 1 -xtick 5 -font font_Small -canvas $w.c -textcolor black \
    -hline {{gray80 1 each 1} {black 1 at 0}} \
    -vline {{gray80 1 each 1} {steelBlue 1 each 5}}

  # Create fake dataset with bounds so we see at least -1.0 to 1.0:
  ::graph::data score bounds -points 0 -lines 0 -bars 0 -coords {1 -0.9 1 0.9}

  # Update the graph:
  $w.c itemconfigure text -text "[sc_game info white] - [sc_game info black]\n[sc_game info site]  [sc_game info date]"
  busyCursor $w
  update
  catch {::graph::data score data -color $linecolor -points 1 -lines 1 \
             -linewidth $linewidth -radius $psize -outline $linecolor \
             -coords [sc_game scores]}
  ::graph::redraw score
  unbusyCursor $w
  update
}

proc configScoreGraphMenus {{lang ""}} {
  if {! [winfo exists .sgraph]} { return }
  if {$lang == ""} { set lang $::language }
  set m .sgraph.menu
  foreach menu {file} tag {File} {
    configMenuName $m.$menu Graph$tag $lang
  }
  foreach idx {0 1 3} tag {Color Grey Close} {
    configMenuText $m.file.m $idx GraphFile$tag $lang
  }
}

proc moveInScoreGraph {xc} {
  set x [expr round([::graph::xunmap score $xc] * 2)]
  sc_move start
  sc_move forward $x
  updateBoard
}


####################
# Rating graph

set rgraph(year) 1900
set rgraph(type) both
set rgraph(player) ""

proc updateRatingGraph {{type ""} {player ""}} {
  global rgraph
  set white [sc_game info white]
  set black [sc_game info black]
  set whiteColor red
  set blackColor blue
  set lwidth 2
  set psize 2

  if {$type == ""} { set type $rgraph(type) }
  if {$player == ""} { set player $rgraph(player) }
  set rgraph(type) $type
  set rgraph(player) $player

  set w .rgraph

  if {! [winfo exists $w]} {
    toplevel $w
    frame $w.menu -relief raised -borderwidth 2
    pack $w.menu -side top -fill x
    $w configure -menu $w.menu
    menubutton $w.menu.file -text GraphFile -menu $w.menu.file.m
    menu $w.menu.file.m
    $w.menu.file.m add command -label GraphFileColor \
      -command "saveGraph color $w.c"
    $w.menu.file.m add command -label GraphFileGrey \
      -command "saveGraph gray $w.c"
    $w.menu.file.m add separator
    $w.menu.file.m add command -label GraphFileClose -command "destroy $w"
    menubutton $w.menu.options -text GraphOptions -menu $w.menu.options.m
    menu $w.menu.options.m
    foreach i {White Black Both PInfo} j {white black both player} {
      $w.menu.options.m add radiobutton -label GraphOptions$i \
        -variable rgraph(type) -value $j -command "updateRatingGraph"
    }
    $w.menu.options.m add separator
    foreach i {1900 1980 1985 1990 1995 2000} {
      $w.menu.options.m add radiobutton -label "Since $i" \
        -variable rgraph(year) -value $i -command "updateRatingGraph"
    }
    pack $w.menu.file $w.menu.options -side left

    canvas $w.c -width 500 -height 300
    $w.c create text 25 10 -tag text -justify center -width 1 \
      -font font_Regular -anchor n
    pack $w.c -side top -expand yes -fill both
    bind $w <F1> {helpWindow Graphs Rating}
    bind $w <Configure> {
      .rgraph.c itemconfigure text -width [expr [winfo width .rgraph.c] - 50]
      .rgraph.c coords text [expr [winfo width .rgraph.c] / 2] 10
      ::graph::configure ratings -height [expr [winfo height .rgraph.c] - 70]
      ::graph::configure ratings -width [expr [winfo width .rgraph.c] - 100]
      ::graph::configure ratings -logy 10
      ::graph::redraw ratings
    }
    bind $w.c <Button-1> "updateRatingGraph"
    bind $w.c <Button-3> "updateRatingGraph"
    wm title $w "Scid: [tr ToolsRating]"
    configRatingGraphMenus
  }

  $w.c itemconfigure text -width [expr [winfo width $w.c] - 50]
  $w.c coords text [expr [winfo width $w.c] / 2] 10
  set height [expr [winfo height $w.c] - 70]
  set width [expr [winfo width $w.c] - 100]
  ::graph::create ratings -width $width -height $height -xtop 50 -ytop 35 \
    -ytick 50 -xtick 1 -font font_Small -canvas $w.c -textcolor black \
    -hline {{gray80 1 each 25} {steelBlue 1 each 100}} \
    -vline {{gray80 1 each 1} {steelBlue 1 each 5}}
  ::graph::redraw ratings
  busyCursor $w
  update

  set title "[tr ToolsRating]: "
  if {$type == "player"} {
    append title $player
    catch {::graph::data ratings d -color $whiteColor -points 1 -lines 1 \
             -linewidth $lwidth -radius $psize -outline $whiteColor \
             -coords [sc_name info -ratings:$rgraph(year) $player]}
  }
  if {$type == "white"  ||  $type == "both"} {
    set key ""
    if {$type == "both"} { set key [surname $white] }
    append title $white
    catch {::graph::data ratings d -color $whiteColor -points 1 -lines 1 \
             -linewidth $lwidth -radius $psize -outline $whiteColor \
             -key $key -coords [sc_name info -ratings:$rgraph(year) $white]}
  }
  if {$type == "both"} { append title " - " }
  if {$type == "black"  ||  $type == "both"} {
    set key ""
    if {$type == "both"} { set key [surname $black] }
    append title $black
    catch {::graph::data ratings d2 -color $blackColor -points 1 -lines 1 \
             -linewidth $lwidth -radius $psize -outline $blackColor \
             -key $key -coords [sc_name info -ratings:$rgraph(year) $black]}
  }
  set minYear [expr int([::graph::cget ratings axmin])]
  set maxYear [expr int([::graph::cget ratings axmax])]
  ::graph::configure ratings -xtick 1
  if {[expr $maxYear - $minYear] > 10} {::graph::configure ratings -xtick 5}
  ::graph::redraw ratings
  $w.c itemconfigure text -text $title
  unbusyCursor $w
}

proc configRatingGraphMenus {{lang ""}} {
  if {! [winfo exists .rgraph]} { return }
  if {$lang == ""} { set lang $::language }
  set m .rgraph.menu
  foreach menu {file options} tag {File Options} {
    configMenuName $m.$menu Graph$tag $lang
  }
  foreach idx {0 1 3} tag {Color Grey Close} {
    configMenuText $m.file.m $idx GraphFile$tag $lang
  }
  foreach idx {0 1 2 3} tag {White Black Both PInfo} {
    configMenuText $m.options.m $idx GraphOptions$tag $lang
  }
}


# surname:
#   Returns the surname of a player name.
#
proc surname {name} {
  set idx [string first "," $name]
  if {$idx > 0} { set name [string range $name 0 [expr $idx - 1]] }
  return $name
}


####################
# Player Info window

set playerInfoName ""

proc playerInfo {{player ""}} {
  global playerInfoName
  if {$player == ""} { set player $playerInfoName }
  if {[catch {sc_name info -htext $player} pinfo]} { return }
  set playerInfoName $player
  set ::rgraph(player) $player
  set w .playerInfoWin
  if {! [winfo exists $w]} {
    toplevel $w
    setWinLocation $w
    wm title $w "Scid: Player Info"
    wm minsize $w 40 5
    pack [frame $w.b2] -side bottom -fill x
    pack [frame $w.b] -side bottom -fill x
    button $w.b.graph -text "Rating graph" \
      -command {updateRatingGraph player $playerInfoName}
    button $w.b.edit -text "Edit ratings" -command {
      makeNameEditor
      setNameEditorType rating
      set editName $playerInfoName
      set editNameSelect crosstable
    }
    button $w.b2.help -textvar ::tr(Help) -command {helpWindow PInfo}
    button $w.b2.update -textvar ::tr(Update) -command {playerInfo $playerInfoName}
    button $w.b2.close -textvar ::tr(Close) -command "focus .; destroy $w"
    pack $w.b2.close $w.b2.update $w.b2.help -side right -padx 3
    pack $w.b.graph $w.b.edit -side left -padx 3
    scrollbar $w.ybar -command "$w.text yview"
    pack $w.ybar -side right -fill y
    text $w.text -font font_Regular -background white \
      -width $::winWidth($w) -height $::winHeight($w) \
      -setgrid 1 -wrap none -yscrollcommand "$w.ybar set"
    pack $w.text -side top -fill both -expand yes
    bind $w <Escape> "focus .; destroy $w"
    ::htext::init $w.text
    ::htext::updateRate $w.text 0
    bind $w <Escape> "focus .; destroy $w"
    bind $w <F1> {helpWindow PInfo}
    bind $w <Configure> "recordWinSize $w"
    standardShortcuts $w
  }
  $w.text configure -state normal
  $w.text delete 1.0 end
  ::htext::display $w.text $pinfo
  $w.text configure -state disabled
  updateGList
  updateMaintWin
  #raiseWin $w
}


####################
# Game Browser window

namespace eval ::gbrowser {}
set ::gbrowser::size 35

proc ::gbrowser::new {base gnum {ply -1}} {
  set n 0
  while {[winfo exists .gb$n]} { incr n }
  set w .gb$n
  toplevel $w
  if {$base < 1} { set base [sc_base current] }
  if {$gnum < 1} { set game [sc_game number] }
  set filename [file tail [sc_base filename $base]]
  wm title $w "Scid: $::tr(BrowseGame) ($filename: $gnum)"
  set header [sc_game summary -base $base -game $gnum header]
  set ::gbrowser::boards($n) [sc_game summary -base $base -game $gnum boards]
  set moves [sc_game summary -base $base -game $gnum moves]

  pack [frame $w.b] -side bottom -fill x
  ::board::new $w.bd $::gbrowser::size
  $w.bd configure -relief solid -borderwidth 1
  pack $w.bd -side left -padx 4 -pady 4

  pack [frame $w.t] -side right -fill both -expand yes
  text $w.t.text -foreground black -background white -wrap word \
    -width 45 -height 12 -font font_Small -yscrollcommand "$w.t.ybar set" \
    -setgrid 1
  scrollbar $w.t.ybar -command "$w.t.text yview" -takefocus 0
  pack $w.t.ybar -side right -fill y
  pack $w.t.text -side left -fill both -expand yes
  set t $w.t.text
  event generate $t <ButtonRelease-1>
  $t tag configure header -foreground darkBlue
  $t tag configure next -foreground yellow -background darkBlue
  $t insert end "$header" header
  $t insert end "\n\n"
  set m 0
  foreach i $moves {
    set moveTag m$m
    $t insert end $i $moveTag
    $t insert end " "
    $t tag bind $moveTag <ButtonRelease-1> "::gbrowser::update $n $m"
    $t tag bind $moveTag <Any-Enter> \
      "$t tag configure $moveTag -foreground red
       $t configure -cursor hand2"
    $t tag bind $moveTag <Any-Leave> \
      "$t tag configure $moveTag -foreground {}
       $t configure -cursor {}"
    incr m
  }
  bind $w <F1> {helpWindow GameList Browsing}
  bind $w <Escape> "destroy $w"
  bind $w <Home> "::gbrowser::update $n start"
  bind $w <End> "::gbrowser::update $n end"
  bind $w <Left> "::gbrowser::update $n -1"
  bind $w <Right> "::gbrowser::update $n +1"
  bind $w <Up> "::gbrowser::update $n -10"
  bind $w <Down> "::gbrowser::update $n +10"
  bind $w <Control-Shift-Left> "::board::resize $w.bd -1"
  bind $w <Control-Shift-Right> "::board::resize $w.bd +1"

  button $w.b.start -image tb_start -command "::gbrowser::update $n start"
  button $w.b.back -image tb_prev -command "::gbrowser::update $n -1"
  button $w.b.forward -image tb_next -command "::gbrowser::update $n +1"
  button $w.b.end -image tb_end -command "::gbrowser::update $n end"
  pack $w.b.start $w.b.back $w.b.forward $w.b.end -side left -padx 1 -pady 1

  set ::gbrowser::flip($n) [::board::isFlipped .board]
  button $w.b.flip -image tb_flip -command "::gbrowser::flip $n"
  pack $w.b.flip -side left -padx 3 -pady 1

  if {$gnum > 0} {
    button $w.b.load -textvar ::tr(LoadGame) \
      -command "sc_base switch $base; gameLoad $gnum"
    button $w.b.merge -textvar ::tr(MergeGame) \
      -command "mergeGame $base $gnum"
  }
  button $w.b.close -textvar ::tr(Close) -command "destroy $w"
  pack $w.b.close -side right -padx 1 -pady 1
  if {$gnum > 0} {
    pack $w.b.merge $w.b.load -side right -padx 1 -pady 1
  }

  wm resizable $w 1 0
  if {$ply < 0} {
    set ply 0
    if {$gnum > 0} {
      set ply [sc_filter value $base $gnum]
      if {$ply > 0} { incr ply -1 }
    }
  }
  ::gbrowser::update $n $ply
}

proc ::gbrowser::flip {n} {
  ::board::flip .gb$n.bd
}

proc ::gbrowser::update {n ply} {
  set w .gb$n
  if {! [winfo exists $w]} { return }
  set oldply 0
  if {[info exists ::gbrowser::ply($n)]} { set oldply $::gbrowser::ply($n) }
  if {$ply == "forward"} { set ply [expr $oldply + 1] }
  if {$ply == "back"} { set ply [expr $oldply - 1] }
  if {$ply == "start"} { set ply 0 }
  if {$ply == "end"} { set ply 9999 }
  if {[string index $ply 0] == "-"  ||  [string index $ply 0] == "+"} {
    set ply [expr $oldply + $ply]
  }
  if {$ply < 0} { set ply 0 }
  set max [expr [llength $::gbrowser::boards($n)] - 1]
  if {$ply > $max} { set ply $max }
  set ::gbrowser::ply($n) $ply
  ::board::update $w.bd [lindex $::gbrowser::boards($n) $ply]

  set t $w.t.text
  $t configure -state normal
  set moveRange [$t tag nextrange m$ply 1.0]
  $t tag remove next 1.0 end
  set moveRange [$t tag nextrange m$ply 1.0]
  if {[llength $moveRange] == 2} {
    $t tag add next [lindex $moveRange 0] [lindex $moveRange 1]
    $t see [lindex $moveRange 0]
  }
  $t configure -state disabled
}


####################
# ECO Browser window

set ecoBrowser(code) ""
set ecoBrowser(count) 0
set ecoBrowserWin 0

proc openCloseEcoBrowser {} {
  if {[winfo exists .ecograph]} {
    destroy .ecograph
  } else {
    updateEcoWin
  }
}

# updateEcoWin:
#    Updates the ECO Browser window, opening it if necessary.
#    If the ECO code "code" is "x", then the value of the global
#    variable ecoBrowser(code) is used instead.
#
proc updateEcoWin {{code "x"}} {
  set w .ecograph
  set graph $w.pane.graph
  set text $w.pane.text
  if {$code != "x"} { set ::ecoBrowser(code) $code }
  if {! [winfo exists $w]} {
    set ::ecoBrowserWin 1
    toplevel $w
    wm minsize $w 200 100
    setWinLocation $w
    bind $w <Escape> "destroy $w"
    bind $w <F1> {helpWindow ECO}
    bind $w <Destroy> {set ::ecoBrowserWin 0}
    text $w.title -relief flat -height 1 -width 1 -wrap word -font font_Bold
    $w.title tag configure center -justify center
    $w.title configure -cursor top_left_arrow
    pack $w.title -side top -fill x
    frame $w.b
    pack $w.b -side bottom -fill x
    button $w.b.classify -textvar ::tr(ReclassifyGames) -command classifyAllGames
    button $w.b.help -textvar ::tr(Help) -command {helpWindow ECO}
    button $w.b.close -textvar ::tr(Close) -command "destroy $w"
    pack $w.b.classify -side left -padx 5 -pady 5
    pack $w.b.close $w.b.help -side right -padx 5 -pady 5
    set pane [::pane::create $w.pane graph text 500 400 0.5]
    ::pane::range $w.pane 0.3 0.7
    ::pane::setdrag $w.pane 0
    pack $pane -side top -expand true -fill both

    canvas $graph.c -width 500 -height 250
    pack $graph.c -side top -fill both -expand yes
    text $text.text -height 12 -width 75 -wrap word -font font_Regular \
      -background white -selectbackground lightBlue \
      -yscroll "$text.ybar set" -xscroll "$text.xbar set"
    $text.text tag configure bold -font font_Bold
    $text.text tag configure indent -lmargin2 20
    $text.text configure -cursor top_left_arrow
    ::htext::init $text.text
    scrollbar $text.ybar -command "$text.text yview"
    scrollbar $text.xbar -orient horizontal -command "$text.text xview"
    grid $text.text -row 0 -column 0 -sticky nesw
    grid $text.ybar -row 0 -column 1 -sticky nesw
    #grid $text.xbar -row 1 -column 0 -sticky nesw
    grid rowconfig $text 0 -weight 1 -minsize 0
    grid columnconfig $text 0 -weight 1 -minsize 0

    foreach i {0 1 2 3 4 5 6 7 8 9 A B C D E a b c d e f g h i j k l m n o p
               q r s t u v w x y z} {
      bind $w <KeyPress-$i> "keyEcoBrowser $i"
    }

    foreach i {Left Delete less BackSpace} {
      bind $w <KeyPress-$i> {keyEcoBrowser "<"}
    }

    bind $w <Home>  {.ecograph.pane.text.text yview moveto 0}
    bind $w <End>   {.ecograph.pane.text.text yview moveto 1.0}
    bind $w <Up>    {.ecograph.pane.text.text yview scroll -1 units}
    bind $w <Down>  {.ecograph.pane.text.text yview scroll 1 units}
    bind $w <Prior> {.ecograph.pane.text.text yview scroll -1 pages}
    bind $w <Next>  {.ecograph.pane.text.text yview scroll 1 pages}
    standardShortcuts $w

    bind $graph.c <1> { selectEcoBrowser %x }
    bind $graph.c <3> { keyEcoBrowser "<" }

    bind $graph <Configure> {
      ::graph::configure eco -height [expr [winfo height .ecograph.pane.graph.c] - 50]
      ::graph::configure eco -width [expr [winfo width .ecograph.pane.graph.c] - 60]
      ::graph::redraw eco
    }
    bind $w <Configure> {
      ::graph::configure eco -height [expr [winfo height .ecograph.pane.graph.c] - 50]
      ::graph::configure eco -width [expr [winfo width .ecograph.pane.graph.c] - 60]
      ::graph::redraw eco
    }
    wm title $w "Scid: [tr WindowsECO]"
    ::graph::create eco -width 1 -height 1 -xtop 50 -ytop 20 \
      -xmin 0.5 -xtick 1 -ytick 5 -font font_Small -canvas $graph.c
    update
  }

  set height [expr [winfo height $graph.c] - 50]
  set width [expr [winfo width $graph.c] - 60]

  set code $::ecoBrowser(code)
  # Collect data:
  set len [string length $code]
  set subcodes {}
  if {$len == 0} {
    set subcodes {A B C D E}
  } elseif {$len == 1  ||  $len == 2} {
    set subcodes {0 1 2 3 4 5 6 7 8 9}
  } elseif {$len == 3} {
    set subcodes {a b c d e f g h i j k l m n o p q r s t u v w x y z}
  }

  set xlabels {}
  set count 0
  set data {}
  set maxfreq 1
  set wins {}
  set draws {}

  foreach i $subcodes {
    set subcode "$code$i"
    set stats [sc_base ecoStats $subcode]
    set freq [lindex $stats 0]
    incr count
    lappend data $count
    lappend data $freq
    lappend wins $count
    lappend wins [lindex $stats 1]
    lappend draws $count
    lappend draws [expr [lindex $stats 1] + [lindex $stats 2] + [lindex $stats 4]]
    if {$freq > $maxfreq} {set maxfreq $freq}
    if {$len == 3} {
      set subcode $i
    }
    lappend xlabels [list $count $subcode]
  }
  set hline 5
  if {$maxfreq >    20} { set hline    10 }
  if {$maxfreq >    50} { set hline    25 }
  if {$maxfreq >   100} { set hline    50 }
  if {$maxfreq >   200} { set hline   100 }
  if {$maxfreq >   500} { set hline   250 }
  if {$maxfreq >  1000} { set hline   500 }
  if {$maxfreq >  2000} { set hline  1000 }
  if {$maxfreq >  5000} { set hline  2500 }
  if {$maxfreq > 10000} { set hline  5000 }
  if {$maxfreq > 20000} { set hline 10000 }
  if {$maxfreq > 50000} { set hline 25000 }
  if {$maxfreq > 100000} { set hline 50000 }

  ::graph::create eco -width $width -height $height -xtop 50 -ytop 20 \
    -xmin 0.5 -xtick 1 -ytick $hline -font font_Small -canvas $graph.c
  ::graph::data eco data -color SteelBlue4 -points 0 -lines 0 -bars 1 \
    -barwidth 0.8 -outline black -coords $data
  ::graph::data eco draws -color SteelBlue3 -points 0 -lines 0 -bars 1 \
    -barwidth 0.8 -outline black -coords $draws
  ::graph::data eco wins -color SteelBlue1 -points 0 -lines 0 -bars 1 \
    -barwidth 0.8 -outline black -coords $wins
  ::graph::data eco bounds -points 0 -lines 0 -bars 0 -coords {1 0 1 1}
  ::graph::configure eco -ymin 0 -xmin 0.4 -xmax [expr $count + 0.6] \
    -xlabels $xlabels -hline [list [list gray80 1 each $hline]]
  ::graph::redraw eco
  $text.text configure -state normal
  $text.text delete 1.0 end
  set stats [sc_base eco $code]
  if {$len == 0} {
    set section $::tr(ECOAllSections)
  } elseif {$len < 3} {
    set section "$::tr(ECOSection) \"$code\""
  } else {
    set section "$::tr(ECOCode) \"$code\""
  }
  set header "<center><b>$::tr(ECOSummary) $section</b><br>"
  append header "[lindex $stats 0] $::tr(games): +[lindex $stats 1] =[lindex $stats 2] -[lindex $stats 3]  ([lindex $stats 5]%)</center>\n\n"
  ::htext::display $text.text "$header[sc_eco summary $code 1]"
  $text.text configure -state disabled
  $w.title configure -state normal
  $w.title delete 1.0 end
  $w.title insert end "$::tr(ECOFrequency) $section" center
  $w.title configure -state disabled
  set ::ecoBrowser(count) $count
}

proc selectEcoBrowser {xc} {
  set count $::ecoBrowser(count)
  set code $::ecoBrowser(code)
  set x [::graph::xunmap eco $xc]
  set selection 0
  for {set i 1} {$i <= $count} {incr i} {
    if {$x >= [expr $i - 0.4]  &&  $x <= [expr $i + 0.4]} {
      set selection $i
    }
  }
  if {$selection == 0} { return }
  incr selection -1
  set len [string length $code]
  if {$len == 0} {
    set code [lindex {A B C D E} $selection]
  } elseif {$len == 1  ||  $len == 2} {
    append code $selection
  } elseif {$len == 3} {
    append code [lindex {a b c d e f g h i j k l m n o p q r s t u v w x y z} $selection]
  } else {
    return
  }
  set ::ecoBrowser(code) $code
  updateEcoWin
}

# keyEcoBrowser:
#    Handles keyboard events in ECO browser window
#
proc keyEcoBrowser {key} {
  set code $::ecoBrowser(code)
  set len [string length $code]
  if {$key == "<"} {
    set ::ecoBrowser(code) [string range $code 0 [expr $len - 2]]
    updateEcoWin
    return
  }
  if {$key == "top"} {
    set ::ecoBrowser(code) ""
    updateEcoWin
    return
  }

  if {$len == 0} {
    set key [string toupper $key]
    switch $key {
      A - B - C - D - E {
        # nothing
      }
      default { set key "" }
    }
  } elseif {$len == 1 || $len == 2} {
    switch $key {
      0 - 1 - 2 - 3 - 4 - 5 - 6 - 7 - 8 - 9 {
        # nothing
      }
      default { set key "" }
    }
  } elseif {$len == 3} {
    set key [string tolower $key]
    switch $key {
      a - b - c - d - e - f - g - h - i - j - k - l - m - n - o - p - q - r -
      s - t - u - v - w - x - y - z {
        # nothing
      }
      default { set key "" }
    }
  }

  if {$key != ""} {
    set ::ecoBrowser(code) "$code$key"
    updateEcoWin
  }
}


####################
# Tablebase window

set tbWin 0
set tbTraining 0
set tbStatus ""

proc makeTBWin {} {
  set w .tbWin
  if {[winfo exists $w]} {
    #focus .
    destroy $w
    set tbWin 0
    return
  }
  toplevel $w
  wm title $w "Scid: [tr WindowsTB]"
  text $w.t -font font_Fixed -wrap word -width 45 -height 10 \
    -yscrollcommand "$w.ybar set" -setgrid 1 -fg black -bg white
  scrollbar $w.ybar -command "$w.t yview"
  #pack [frame $w.status] -side bottom -fill x -expand yes
  pack [frame $w.b] -side bottom -fill x
  label $w.b.status -width 1 -font font_Small -relief flat -anchor w \
    -textvar tbStatus -height 0
  checkbutton $w.b.training -textvar ::tr(Training) -variable tbTraining \
    -command toggleTBTraining -relief raised -pady 5 -padx 4
  button $w.b.close -textvar ::tr(Close) -command "destroy $w"
  pack $w.ybar -side right -fill y
  pack $w.t -side left -fill both -expand 1
  pack $w.b.training -side left -padx 2 -pady 2
  pack $w.b.close -side right -padx 2 -pady 2
  pack $w.b.status -side left -fill x -expand 1
  $w.t tag configure indent -lmargin2 [font measure font_Fixed  "        "]
  bind $w <Destroy> { set tbWin 0; set tbTraining 0 }
  set ::tbTraining 0
  updateTBWin
}

proc updateTBWin {} {
  global tbTraining
  set w .tbWin
  if {![winfo exists $w]} { return }
  $w.t delete 1.0 end
  if {$tbTraining} {
    $w.t insert end "\n (Training mode; results are hidden)"
  } else {
    $w.t insert end [sc_pos probe report] indent
  }
}

proc toggleTBTraining {} {
  global tbTraining gameInfo
  set w .tbWin
  set ::tbStatus ""
  if {$tbTraining} {
    set gameInfo(showTB_old) $gameInfo(showTB)
    set gameInfo(showTB) 0
    updateBoardAndPgn .board
    updateTBWin
  } else {
    if {$gameInfo(showTB) == 0} { set gameInfo(showTB) $gameInfo(showTB_old) }
    updateBoardAndPgn .board
    updateTBWin
  }
}

proc makeTBMove {} {
  global tbTraining tbStatus
  if {! $tbTraining} { return }
  set moves [split [sc_pos probe optimal]]
  set len [llength $moves]
  if {$len == 0} {
    set ::tbStatus "No optimal move was found."
    return
  }
  set i [expr int(rand() * $len)]
  set move [lindex $moves $i]
  if {[catch {sc_move addSan $move}]} {
    set tbStatus "Error playing $move."
  } else {
    set tbStatus "Played $move."
  }
  updateBoardAndPgn .board
}


####################
# File finder window

set finder(dir) [pwd]
set finder(sort) name
set finder(recurse) 0
set finder(stop) 0
set finder(Scid) 1
set finder(PGN) 1
set finder(Rep) 1
set finder(EPD) 1
set finder(Old) 1

image create photo updir -data {
  R0lGODdhGQAUAKEAANnZ2QAAAPD/gAAngSwAAAAAGQAUAAACToSPqcvtEGJ8LIh7A00WY71B
  0kiWnIemHmh06pshrjAM8CpjdX3HR7fboXifnM6WIvpaHmUTuYQ8g1Tcb0gVWpk9FUvaTX1F
  pfIohE4zCgA7
}

proc fileFinder {} {
  global finder
  set w .finder
  if {[winfo exists $w]} { return }

  toplevel $w
  wm title $w "Scid: $::tr(FileFinder)"
  bind $w <F1> {helpWindow Finder}
  setWinLocation $w
  bind $w <Configure> "recordWinSize $w"

  frame $w.menu -relief raised -borderwidth 2
  pack $w.menu -side top -fill x
  $w configure -menu $w.menu
  menubutton $w.menu.file -text FinderFile -menu $w.menu.file.m
  menu $w.menu.file.m
  $w.menu.file.m add checkbutton -label FinderFileSubdirs \
    -variable finder(recurse) -onvalue 1 -offvalue 0 -command updateFileFinder
  $w.menu.file.m add separator
  $w.menu.file.m add command -label FinderFileClose -command "destroy $w"
  menubutton $w.menu.sort -text FinderSort -menu $w.menu.sort.m
  menu $w.menu.sort.m
  foreach {name value} {Type type Size size Mod mod Filename name Path path} {
    $w.menu.sort.m add radiobutton -label FinderSort$name \
      -variable finder(sort) -value $value -command {updateFileFinder -fast}
  }
  menubutton $w.menu.types -text FinderTypes -menu $w.menu.types.m
  menu $w.menu.types.m
  foreach type {Scid Old PGN Rep EPD} {
    $w.menu.types.m add checkbutton -label FinderTypes$type \
      -variable finder($type) -onvalue 1 -offvalue 0 -command updateFileFinder
  }
  menubutton $w.menu.help -text FinderHelp -menu $w.menu.help.m
  menu $w.menu.help.m
  $w.menu.help.m add command -label FinderHelpFinder \
    -accelerator F1 -command {helpWindow Finder}
  $w.menu.help.m add command -label FinderHelpIndex -command {helpWindow Index}
  pack $w.menu.file $w.menu.sort $w.menu.types $w.menu.help -side left

  pack [frame $w.d] -side top -fill x
  label $w.d.label -text "$::tr(FinderDir):" -font font_Small
  set finder(menu) [tk_optionMenu $w.d.mb finder(dir) ""]
  $w.d.mb configure -font font_Small -width 1 -anchor e
  $finder(menu) configure -font font_Small
  button $w.d.up -image updir -command {updateFileFinder ..}
  pack $w.d.label -side left -padx 5
  pack $w.d.up -side right -padx 5
  pack $w.d.mb -side left -fill x -expand yes

  frame $w.t
  frame $w.b
  text $w.t.text -width 65 -height 25 -font font_Small -wrap none \
    -fg black -bg white -yscrollcommand "$w.t.ybar set" -setgrid 1 \
    -cursor top_left_arrow
  scrollbar $w.t.ybar -command "$w.t.text yview" -width 12
  $w.t.text tag configure Dir -foreground brown
  $w.t.text tag configure Vol -foreground gray25
  $w.t.text tag configure PGN -foreground blue
  $w.t.text tag configure Scid -foreground red
  $w.t.text tag configure Old -foreground black
  $w.t.text tag configure Rep -foreground darkGreen
  $w.t.text tag configure EPD -foreground orange
  $w.t.text tag configure bold -font font_SmallBold
  $w.t.text tag configure center -justify center
  set xwidth [font measure [$w.t.text cget -font] "x"]
  set tablist {}
  foreach {tab justify} {15 r 30 r 32 l 50 l} {
    set tabwidth [expr $xwidth * $tab]
    lappend tablist $tabwidth $justify
  }
  $w.t.text configure -tabs $tablist

  checkbutton $w.b.sub -text [tr FinderFileSubdirs] \
    -relief raised -pady 5 -padx 10 \
    -variable finder(recurse) -onvalue 1 -offvalue 0 -command updateFileFinder
  button $w.b.stop -textvar ::tr(Stop) -command {set finder(stop) 1 }
  button $w.b.help -textvar ::tr(Help) -command {helpWindow Finder}
  button $w.b.close -textvar ::tr(Close) -command "destroy $w"
  bind $w <Escape> "$w.b.stop invoke"

  pack $w.b -side bottom -fill x
  pack $w.b.sub -side left -padx 5 -pady 2
  pack $w.b.close $w.b.help $w.b.stop -side right -padx 5 -pady 2
  pack $w.t -side top -fill both -expand yes
  pack $w.t.ybar -side right -fill y
  pack $w.t.text -side left -fill both -expand yes
  configFinderMenus
  updateFileFinder
}

proc updateFileFinder {{newdir ""}} {
  global finder
  set w .finder
  if {! [winfo exists $w]} { return }
  set t $w.t.text

  # When parameter is "-fast", just re-sort the existing data:
  set fastmode 0
  if {$newdir == "-fast"} {
    set fastmode 1
    set newdir ""
  }
  if {$newdir == ".."} { set newdir [file dirname $finder(dir)] }
  if {$newdir != ""} { set finder(dir) $newdir }

  busyCursor .
  set finder(stop) 0
  $w.b.close configure -state disabled
  $w.b.help configure -state disabled
  $w.b.sub configure -state disabled
  $w.b.stop configure -state normal
  catch {grab $w.b.stop}
  $t configure -state normal
  update

  if {$fastmode} {
    set flist $finder(flist)
  } else {
    set flist [finder_getFiles $finder(dir)]
    set finder(flist) $flist
  }

  switch $finder(sort) {
    "none" {}
    "type" { set flist [lsort -decreasing -index 1 $flist] }
    "size" { set flist [lsort -integer -decreasing -index 0 $flist] }
    "name" { set flist [lsort -dict -index 2 $flist] }
    "path" { set flist [lsort -dict -index 3 $flist] }
    "mod"  { set flist [lsort -integer -decreasing -index 4 $flist] }
  }

  set hc yellow
  $t delete 1.0 end
  set dcount 0
  $t insert end "$::tr(FinderDirs)\n" {center bold}
  set dlist {}

  # Insert drive letters, on Windows:
  if {$::windowsOS} {
    foreach drive [lsort -dictionary [file volume]] {
      $t insert end " $drive " [list Vol v$drive]
      $t insert end "    "
      $t tag bind v$drive <1> [list updateFileFinder $drive]
      $t tag bind v$drive <Any-Enter> \
        "$t tag configure [list v$drive] -background $hc"
      $t tag bind v$drive <Any-Leave> \
        "$t tag configure [list v$drive] -background {}"
    }
    $t insert end "\n"
  }

  # Insert parent directory entry:
  lappend dlist ..

  # Generate other directory entries:
  set dirlist [lsort -dictionary [glob -nocomplain [file join $finder(dir) *]]]
  foreach dir $dirlist {
    if {[file isdir $dir]} {
      lappend dlist $dir
    }
  }
  foreach dir $dlist {
    if {$dcount != 0} {
      set sep "\n"
      if {$dcount % 2 != 0} { set sep "\t\t\t" }
      $t insert end $sep
    }
    incr dcount
    if {$dir == ".."} {
      set d ..
      $t insert end " .. ($::tr(FinderUpDir)) " [list Dir d..]
    } else {
      set d [file tail $dir]
      $t insert end " $d " [list Dir d$d]
    }
    $t tag bind d$d <1> [list updateFileFinder $dir]
    $t tag bind d$d <Any-Enter> \
      "$t tag configure [list d$d] -background $hc"
    $t tag bind d$d <Any-Leave> \
      "$t tag configure [list d$d] -background {}"
  }

  # Add File section headings:
  $t insert end "\n\n"
  if {[llength $flist] != 0} {
    foreach i {Type Size Mod Name Path} v {type size mod name path} {
      $t tag configure s$i -font font_SmallBold
      $t tag bind s$i <1> "set finder(sort) $v; updateFileFinder -fast"
      $t tag bind s$i <Any-Enter> "$t tag config s$i -foreground red"
      $t tag bind s$i <Any-Leave> "$t tag config s$i -foreground {}"
    }
    $t insert end "$::tr(FinderFiles)\n" {center bold}
    $t insert end " "
    $t insert end "[tr FinderSortType]" sType
    $t insert end "\t"
    $t insert end "[tr FinderSortSize]" sSize
    $t insert end "\t"
    $t insert end "[tr FinderSortMod]" sMod
    $t insert end "\t"
    $t insert end "[tr FinderSortName]" sName
    $t insert end "\t"
    $t insert end "[tr FinderSortPath]" sPath
    $t insert end "\n"
  }

  # Add each file:
  foreach i $flist {
    set size [lindex $i 0]
    set type [lindex $i 1]
    set fname [lindex $i 2]
    set path [lindex $i 3]
    set mtime [lindex $i 4]
    set est [lindex $i 5]
    $t insert end "\n "
    $t insert end $type [list $type f$path]
    set esize ""
    if {$est} { set esize "~" }
    append esize [thousands $size]
    $t insert end "\t$esize" f$path
    $t insert end "\t[clock format $mtime -format {%b %d %Y}]" f$path
    $t insert end "\t$fname\t" f$path
    set dir [file dirname $path]
    set tail [file tail $path]
    set fullpath $finder(dir)/$dir/$tail
    $t tag bind f$path <ButtonPress-1> "fileOpen [list $fullpath]"
    $t tag bind f$path <Any-Enter> \
      "$t tag configure [list f$path] -background $hc"
    $t tag bind f$path <Any-Leave> \
      "$t tag configure [list f$path] -background {}"
    if {$dir == "."} {
      set fullpath "$finder(dir)/$tail"
    } else {
      $t tag configure p$path -foreground darkblue
      $t insert end "$dir/" [list p$path f$path]
    }
    $t tag configure t$path -foreground blue
    $t insert end $tail [list t$path f$path]
  }
  $t configure -state disabled

  # Update directory menubutton:
  $finder(menu) delete 0 end
  set mlist {}
  set d {}
  foreach subdir [file split $finder(dir)] {
    set d [file join $d $subdir]
    lappend mlist $d
  }
  foreach m $mlist {
    $finder(menu) add command -label $m -command "updateFileFinder [list $m]"
  }

  catch {grab release $w.b.stop}
  $w.b.stop configure -state disabled
  $w.b.help configure -state normal
  $w.b.close configure -state normal
  $w.b.sub configure -state normal
  unbusyCursor .
}

proc configFinderMenus {{lang ""}} {
  if {! [winfo exists .finder]} { return }
  if {$lang == ""} { set lang $::language }
  set m .finder.menu
  foreach menu {file sort types help} tag {File Sort Types Help} {
    configMenuName $m.$menu Finder$tag $lang
  }
  foreach idx {0 2} tag {Subdirs Close} {
    configMenuText $m.file.m $idx FinderFile$tag $lang
  }
  foreach idx {0 1 2 3 4} tag {Type Size Mod Name Path} {
    configMenuText $m.sort.m $idx FinderSort$tag $lang
  }
  foreach idx {0 1 2 3 4} tag {Scid Old PGN Rep EPD} {
    configMenuText $m.types.m $idx FinderTypes$tag $lang
  }
  foreach idx {0 1} tag {Finder Index} {
    configMenuText $m.help.m $idx FinderHelp$tag $lang
  }
}

proc finder_getFiles {dir {len -1}} {
  global finder
  set dlist {}
  set flist {}
  if {$len < 0} {
    set len [expr [string length $dir] + 1]
  }

  foreach f [glob -nocomplain [file join $dir *]] {
    if {[file isdir $f]} {
      lappend dlist $f
    } elseif {[file isfile $f]} {
      set ext [string tolower [file extension $f]]
      if {[catch {set mtime [file mtime $f]}]} { set mtime 0 }
      set showFile 0
      set rootname [file rootname $f]
      set type PGN
      if {$ext == ".si3"} {
        set showFile 1
        set type Scid
      } elseif {$ext == ".si"} {
        set showFile 1
        set type Old
      } elseif {$ext == ".sor"} {
        set showFile 1
        set type Rep
      } elseif {$ext == ".epd"} {
        set type EPD
        set showFile 1
      } elseif {$ext == ".pgn"} {
        set showFile 1
      } elseif {$ext == ".gz"} {
        set rootname [file rootname $rootname]
        if {[regexp {\.epd\.gz} $f]} { set showFile 1; set type EPD }
        if {[regexp {\.pgn\.gz} $f]} { set showFile 1 }
      }
      if {$showFile  &&  [info exists finder($type)]  &&  $finder($type)} {
        set path [string range $f $len end]
        set est 0
        if {[catch {set size [sc_info fsize $f]}]} {
          # Could not determine file size, probably a PGN or EPD file
          # that the user does not have permission to read.
          set est 1
          set size 0
        }
        if {$size < 0} {
          set est 1
          set size [expr 0 - $size]
        }
        if {[file dirname $path] == "."} { set path "./$path" }
        lappend flist [list $size $type [file tail $rootname] $path $mtime $est]
      }
    }
    update
    if {$finder(stop)} { break }
  }
  if {$finder(recurse)} {
    foreach f $dlist {
      foreach i [finder_getFiles $f $len] {
        lappend flist $i
        update
        if {$finder(stop)} { break }
      }
    }
  }
  return $flist
}


####################
# Tournament window

namespace eval ::tourney {}

foreach {n v} {start 0000.00.00 end 2047.12.31 minPlayers 2 maxPlayers 999 \
                 minGames 1 maxGames 9999 minElo 0 sort Date country "" \
                 site "" player ""} {
  set ::tourney::$n $v
}

trace variable ::tourney::start w forceDate
trace variable ::tourney::end w forceDate
foreach {n v} {minPlayers 999 maxPlayers 999 minGames 9999 maxGames 9999 \
                 minElo 4000} {
  trace variable ::tourney::$n w [list forceInt $v 0]
}

set tourneyWin 0

proc ::tourney::toggle {} {
  set w .tourney
  if {[winfo exists $w]} {
    destroy $w
  } else {
    ::tourney::open
  }
}

proc ::tourney::open {} {
  global tourneyWin
  set w .tourney
  if {[winfo exists $w]} { return }
  set tourneyWin 1

  if {! [info exists ::tourney::_defaults]} { ::tourney::defaults }

  toplevel $w
  wm title $w "Scid: [tr WindowsTmt]"
  setWinLocation $w
  bind $w <Configure> "recordWinSize $w"

  bind $w <F1> {helpWindow Tmt}
  bind $w <Escape> "$w.b.close invoke"
  bind $w <Return> ::tourney::refresh
  bind $w <Destroy> { set tourneyWin 0 }
  standardShortcuts $w
  bind $w <Up> "$w.t.text yview scroll -1 units"
  bind $w <Down> "$w.t.text yview scroll 1 units"
  bind $w <Prior> "$w.t.text yview scroll -1 pages"
  bind $w <Next> "$w.t.text yview scroll 1 pages"
  bind $w <Key-Home> "$w.t.text yview moveto 0"
  bind $w <Key-End> "$w.t.text yview moveto 0.99"

  frame $w.menu -relief raised -borderwidth 2
  pack $w.menu -side top -fill x
  $w configure -menu $w.menu
  menubutton $w.menu.file -text File -menu $w.menu.file.m
  menu $w.menu.file.m
  $w.menu.file.m add command -label Update -command ::tourney::refresh
  $w.menu.file.m add command -label Close -command "destroy $w"
  menubutton $w.menu.sort -text Sort -menu $w.menu.sort.m
  menu $w.menu.sort.m
  foreach name {Date Players Games Elo Site Event Winner} {
    $w.menu.sort.m add radiobutton -label $name \
      -variable ::tourney::sort -value $name -command {::tourney::refresh -fast}
  }
  pack $w.menu.file $w.menu.sort -side left

  foreach i {t o1 o2 o3 b} {frame $w.$i}
  text $w.t.text -width 75 -height 22 -font font_Small -wrap none \
    -fg black -bg white -yscrollcommand "$w.t.ybar set" -setgrid 1 \
    -cursor top_left_arrow -xscrollcommand "$w.t.xbar set"
  scrollbar $w.t.ybar -command "$w.t.text yview" -width 12 -takefocus 0
  scrollbar $w.t.xbar -orient horiz -command "$w.t.text xview" -width 12 \
    -takefocus 0
  set xwidth [font measure [$w.t.text cget -font] "0"]
  set tablist {}
  foreach {tab justify} {3 r 4 l 18 r 23 r 30 r 32 l 55 l} {
    set tabwidth [expr $xwidth * $tab]
    lappend tablist $tabwidth $justify
  }
  $w.t.text configure -tabs $tablist
  $w.t.text tag configure date -foreground darkRed
  $w.t.text tag configure np -foreground darkBlue
  $w.t.text tag configure elo -foreground darkGreen
  $w.t.text tag configure best -foreground steelBlue
  $w.t.text tag configure event -foreground darkRed
  $w.t.text tag configure title -font font_SmallBold

  set font font_Small
  set fbold font_SmallBold
  set f $w.o1
  label $f.from -text "[tr TmtSortDate]:" -font $fbold
  entry $f.efrom -textvariable ::tourney::start -width 10 -font $font
  bindFocusColors $f.efrom
  bind $f.efrom <FocusOut> +::tourney::check
  label $f.to -text "-" -font $font
  entry $f.eto -textvariable ::tourney::end -width 10 -font $font
  bindFocusColors $f.eto
  bind $f.eto <FocusOut> +::tourney::check
  pack $f.from $f.efrom $f.to $f.eto -side left

  label $f.cn -text "  $::tr(Country):" -font $fbold
  entry $f.ecn -textvariable ::tourney::country -width 4 -font $font
  bindFocusColors $f.ecn
  bind $f.ecn <FocusOut> +::tourney::check
  menubutton $f.cm -font font_Small -text "..." -menu $f.cm.m \
    -relief raised
  menu $f.cm.m -font font_Small
  $f.cm.m add command -label --- -command {set ::tourney::country ""}
  foreach c {AUT CZE DEN ENG ESP FRA GER GRE HUN ITA NED POL RUS SUI SWE \
             USA YUG} {
    $f.cm.m add command -label $c -command [list set ::tourney::country $c]
  }
  $f.cm.m entryconfigure 6 -columnbreak 1
  $f.cm.m entryconfigure 12 -columnbreak 1
  pack $f.cn $f.ecn -side left
  pack $f.cm -side left -padx 2

  label $f.size -text $::tr(TmtLimit:) -font $fbold
  set m [tk_optionMenu $f.msize ::tourney::size 10 20 50 100 200]
  $f.msize configure -width 3 -anchor e -font $font
  $m configure -font $font
  pack $f.msize $f.size -side right

  set f $w.o2
  label $f.players -text "[tr TmtSortPlayers]:" -font $fbold
  entry $f.pmin -textvariable ::tourney::minPlayers \
    -width 3 -justify right -font $font
  bindFocusColors $f.pmin
  bind $f.pmin <FocusOut> +::tourney::check
  label $f.pto -text "-"
  entry $f.pmax -textvariable ::tourney::maxPlayers \
    -width 3 -justify right -font $font
  bindFocusColors $f.pmax
  bind $f.pmax <FocusOut> +::tourney::check
  pack $f.players $f.pmin $f.pto $f.pmax -side left

  label $f.games -text "   [tr TmtSortGames]:" -font $fbold
  entry $f.gmin -textvariable ::tourney::minGames \
    -width 4 -justify right -font $font
  bindFocusColors $f.gmin
  bind $f.gmin <FocusOut> +::tourney::check
  label $f.gto -text "-" -font $font
  entry $f.gmax -textvariable ::tourney::maxGames \
    -width 4 -justify right -font $font
  bindFocusColors $f.gmax
  bind $f.gmax <FocusOut> +::tourney::check
  pack $f.games $f.gmin $f.gto $f.gmax -side left
  label $f.elolab -text "$::tr(TmtMeanElo):" -font $fbold
  entry $f.elo -textvariable ::tourney::minElo \
    -width 5 -justify right -font $font
  bindFocusColors $f.elo
  pack $f.elo $f.elolab -side right

  set f $w.o3
  label $f.sitelab -text "$::tr(Site):" -font $fbold
  entry $f.site -textvariable ::tourney::site -width 12 -font $font
  bindFocusColors $f.site
  pack $f.sitelab $f.site -side left
  label $f.playerlab -text "$::tr(Player):" -font $fbold
  entry $f.player -textvariable ::tourney::player -width 12 -font $font
  bindFocusColors $f.player
  pack $f.player $f.playerlab -side right

  button $w.b.defaults -textvar ::tr(Defaults) -command ::tourney::defaults
  button $w.b.help -textvar ::tr(Help) -command {helpWindow Tmt}
  button $w.b.update -textvar ::tr(Update) -command ::tourney::refresh
  button $w.b.close -textvar ::tr(Close) -command "destroy $w"
  pack $w.b -side bottom -fill x
  pack $w.b.close $w.b.update $w.b.help -side right -padx 2 -pady 2
  pack $w.b.defaults -side left -padx 2 -pady 2
  pack $w.o3 -side bottom -fill x -padx 2
  pack $w.o2 -side bottom -fill x -padx 2
  pack $w.o1 -side bottom -fill x -padx 2
  pack $w.t -side top -fill both -expand yes
  grid $w.t.text -row 0 -column 0 -sticky news
  grid $w.t.ybar -row 0 -column 1 -sticky news
  grid $w.t.xbar -row 1 -column 0 -sticky news
  grid rowconfig $w.t 0 -weight 1 -minsize 0
  grid columnconfig $w.t 0 -weight 1 -minsize 0

  ::tourney::configMenus
  ::tourney::refresh
}

proc ::tourney::configMenus {{lang ""}} {
  set w .tourney
  if {! [winfo exists $w]} { return }
  if {$lang == ""} { set lang $::language }
  set m $w.menu
  foreach menu {file sort} tag {File Sort} {
    configMenuName $m.$menu Tmt$tag $lang
  }
  foreach idx {0 2} tag {Update Close} {
    configMenuText $m.file.m $idx TmtFile$tag $lang
  }
  foreach idx {0 1 2 3 4 5 6} tag {Date Players Games Elo Site Event Winner} {
    configMenuText $m.sort.m $idx TmtSort$tag $lang
  }
}

proc ::tourney::defaults {} {
  set ::tourney::_defaults 1
  set year [::date::today year]
  #set ::tourney::start "$year.??.??"
  set ::tourney::start "1800.??.??"
  set ::tourney::end "$year.12.31"
  set ::tourney::size 50
  set ::tourney::minPlayers 2
  set ::tourney::maxPlayers 999
  set ::tourney::minGames 1
  set ::tourney::maxGames 9999
  set ::tourney::minElo 0
  set ::tourney::country ""
  set ::tourney::site ""
  set ::tourney::player ""
}

proc ::tourney::refresh {{option ""}} {
  set w .tourney
  if {! [winfo exists $w]} { return }
  busyCursor $w
  set t $w.t.text
  $t configure -state normal
  $t delete 1.0 end
  update
  set fastmode 0
  if {$option == "-fast"} { set fastmode 1 }

  if {$fastmode  &&  $::tourney::list != ""} {
    set tlist $::tourney::list
  } else {
    if {[catch {sc_base tournaments \
                  -start $::tourney::start \
                  -end $::tourney::end \
                  -size 2500 \
                  -minPlayers $::tourney::minPlayers \
                  -maxPlayers $::tourney::maxPlayers \
                  -minGames $::tourney::minGames \
                  -maxGames $::tourney::maxGames \
                  -minElo $::tourney::minElo \
                  -country [string toupper $::tourney::country] \
                  -site $::tourney::site \
                  -player $::tourney::player \
                } tlist]} {
      $t insert end $tlist
      $t configure -state disabled
      unbusyCursor .
      return
    }
    set ::tourney::list $tlist
  }

  switch $::tourney::sort {
    "None" {}
    "Date" { set tlist [lsort -decreasing -index 0 $tlist] }
    "Players" { set tlist [lsort -integer -decreasing -index 3 $tlist] }
    "Games" { set tlist [lsort -integer -decreasing -index 4 $tlist] }
    "Elo" { set tlist [lsort -integer -decreasing -index 5 $tlist] }
    "Site" { set tlist [lsort -dict -index 1 $tlist] }
    "Event" { set tlist [lsort -dict -index 2 $tlist] }
    "Winner" { set tlist [lsort -dict -index 7 $tlist] }
  }

  if {[llength $tlist] > 0} {
    foreach i {Date Players Games Elo Site Event Winner} {
      $t tag configure s$i -font font_SmallBold
      $t tag bind s$i <1> "set ::tourney::sort $i; ::tourney::refresh -fast"
      $t tag bind s$i <Any-Enter> "$t tag config s$i -foreground red"
      $t tag bind s$i <Any-Leave> "$t tag config s$i -foreground {}"
    }
    $t insert end "\t\t"
    $t insert end [tr TmtSortDate] sDate
    $t insert end "\t"
    $t insert end [tr TmtSortPlayers] sPlayers
    $t insert end "\t"
    $t insert end [tr TmtSortGames] sGames
    $t insert end "\t"
    $t insert end [tr TmtSortElo] sElo
    $t insert end "\t"
    $t insert end [tr TmtSortSite] sSite
    $t insert end ": "
    $t insert end [tr TmtSortEvent] sEvent
    $t insert end "\t"
    $t insert end [tr TmtSortWinner] sWinner
    $t insert end "\n"
  } else {
    $t insert end $::tr(TmtNone)
  }

  set hc yellow
  set count 0
  foreach tmt $tlist {
    incr count
    if {$count > $::tourney::size} { break }
    set date [lindex $tmt 0]
    set site [lindex $tmt 1]
    set event [lindex $tmt 2]
    set np [lindex $tmt 3]
    set ng [lindex $tmt 4]
    set elo [lindex $tmt 5]
    set g [lindex $tmt 6]
    set white [surname [lindex $tmt 7]]
    set welo [lindex $tmt 8]
    set wscore [lindex $tmt 9]
    set black [surname [lindex $tmt 10]]
    set belo [lindex $tmt 11]
    set bscore [lindex $tmt 12]
    if {$welo > 0} { append white "($welo)" }
    if {$belo > 0} { append black "($belo)" }
    append white " $wscore"
    append black " $bscore"
    set one "1."
    set two "2."
    if {$wscore == $bscore} {
      set one "1="; set two "1="
    }
    set best "$one $white, $two $black, ..."
    if {$np == 2} { set best "$one $white, $two $black" }

    $t tag bind g$count <ButtonPress-1> [list ::tourney::select $g]
    $t tag bind g$count <ButtonPress-3> [list ::tourney::select $g 1]
    $t tag bind g$count <Any-Enter> \
      "$t tag configure g$count -background $hc"
    $t tag bind g$count <Any-Leave> \
      "$t tag configure g$count -background {}"
    $t insert end "\n"
    $t insert end "\t$count\t" g$count
    $t insert end $date [list date g$count]
    $t insert end "\t" g$count
    $t insert end $np [list np g$count]
    $t insert end "\t" g$count
    $t insert end $ng [list ng g$count]
    $t insert end "\t" g$count
    $t insert end $elo [list elo g$count]
    $t insert end "\t" g$count
    $t insert end "$site: " [list site g$count]
    $t insert end "$event" [list event g$count]
    $t insert end "\t$best" [list best g$count]
  }
  $t insert end "\n"
  $t configure -state disabled
  unbusyCursor .
}

proc ::tourney::check {} {
  set start $::tourney::start
  set end $::tourney::end
  if {[string length $start] == 0} { set start "0000" }
  if {[string length $end] == 0} { set end [sc_info limit year]}
  if {[string length $start] == 4} { append start ".??.??" }
  if {[string length $end] == 4} { append end ".12.31" }
  if {[string length $start] == 7} { append start ".??" }
  if {[string length $end] == 7} { append end ".31" }
  set ::tourney::start $start
  set ::tourney::end $end
  if {$::tourney::minPlayers < 2} {set ::tourney::minPlayers 2}
  if {$::tourney::minPlayers > $::tourney::maxPlayers} {
    set ::tourney::maxPlayers $::tourney::minPlayers
  }
  set s $::tourney::country
  set s [string toupper [string trim $s]]
  if {[string length $s] > 3} { set s [string range $s 0 2] }
  set ::tourney::country $s
}

proc ::tourney::select {gnum {openCrosstable 0}} {
  if {[catch {sc_game load $gnum} result]} {
    tk_messageBox -type ok -icon info -title "Scid" -message $result
    return
  }
  updateBoardAndPgn .board
  updateTitle
  if {$openCrosstable} {
    crosstabWin
  } else {
    updateCrosstabWin
  }
}


####################
# Piece tracker window

namespace eval ::ptrack {}

set ::ptrack::psize 35
set ::ptrack::select d1
set ::ptrack::moves(start) 1
set ::ptrack::moves(end) 20
set ::ptrack::mode "-games"
set ::ptrack::color blue
set ::ptrack::colors [list black red yellow cyan blue xblack xred xyellow xcyan xblue]

trace variable ::ptrack::moves(start) w {forceInt 999 0}
trace variable ::ptrack::moves(end) w {forceInt 999 0}

# ::ptrack::sq
#   Given a square number (0=a1 to 63=h8), returns the square name.
#
proc ::ptrack::sq {n} {
  set sq [lindex [list a b c d e f g h] [expr $n % 8]]
  append sq [expr int($n/8) + 1]
  return $sq
}

# ::ptrack::unselect
#   Unselects all pieces in the Piece Tracker window.
#
proc ::ptrack::unselect {} {
  set w .ptracker
  set ::ptrack::select {}
  foreach i {a1 c1 e1 g1 b2 d2 f2 h2 a7 c7 e7 g7 b8 d8 f8 h8} {
    $w.bd.p$i configure -background $::dark
  }
  foreach i {b1 d1 f1 h1 a2 c2 e2 g2 b7 d7 f7 h7 a8 c8 e8 g8} {
    $w.bd.p$i configure -background $::lite
  }
}

# ::ptrack::select
#   Selects all the listed pieces the Piece Tracker window.
#
proc ::ptrack::select {plist} {
  ::ptrack::unselect
  foreach p $plist {
    lappend ::ptrack::select $p
    .ptracker.bd.p$p configure -background $::highcolor
  }
}

# ::ptrack::status
#   Sets the Piece Tracker window status bar.
#
proc ::ptrack::status {{text ""}} {
  set t .ptracker.status
  if {$text == ""} {
    $t configure -text "$::tr(Filter): [filterText]"
  } else {
    $t configure -text $text
  }
}

# ::ptrack::recolor
#   Changes the color scheme for track values.
#
proc ::ptrack::recolor {color} {
  set ::ptrack::color $color
  .ptracker.t.color.b configure -image ptrack_$::ptrack::color
  ::ptrack::refresh color
}

# ::ptrack::color
#   Given a real value between 0.0 and 100.0, returns
#   the corresponding Piece Tracker color value.
#
proc ::ptrack::color {pct {col ""}} {
  if {$col == ""} {
    set col $::ptrack::color
  }
  set x $pct
  if {$x > 100.0} { set x 100.0}
  if {$x < 0.01} { set x 0.01 }
  set y [expr 255 - round($x * 0.5 + 10 * log($x))]
  set yb [expr 255 - round($x * 2.0 + 10 * log($x))]
  if {$y > 255} { set y 255}
  if {$yb > 255} { set yb 255}
  if {$yb < 0} { set yb 0}
  if {$y < 0} { set y 0}
  if {$pct > 0.0  &&  $y == 0} { set y 1 }
  if {$pct > 0.0  &&  $yb == 0} { set yb 1 }
  set xy [expr 255 - $y]
  set xyb [expr 255 - $yb]
  switch $col {
    black   { set color [format "\#%02X%02X%02X" $yb $yb $yb] }
    red     { set color [format "\#%02X%02X%02X" $y $yb $yb] }
    yellow  { set color [format "\#%02X%02X%02X" $y $y $yb] }
    cyan    { set color [format "\#%02X%02X%02X" $yb $y $y] }
    blue    { set color [format "\#%02X%02X%02X" $yb $yb $y] }
    xblack  { set color [format "\#%02X%02X%02X" $xyb $xyb $xyb] }
    xred    { set color [format "\#%02X%02X%02X" $xyb $xy $xy] }
    xyellow { set color [format "\#%02X%02X%02X" $xyb $xyb $xy] }
    xcyan   { set color [format "\#%02X%02X%02X" $xy $xyb $xyb] }
    xblue   { set color [format "\#%02X%02X%02X" $xy $xy $xyb] }
  }
  return $color
}

# ::ptrack::make
#   Creates the Piece Tracker window
#
proc ::ptrack::make {} {
  set w .ptracker
  if {[winfo exists $w]} { return }

  toplevel $w
  wm title $w "Scid: [tr ToolsTracker]"
  bind $w <Escape> "destroy $w"
  bind $w <F1> {helpWindow PTracker}
  image create photo ptrack -width $::ptrack::psize -height $::ptrack::psize
  pack [label $w.status -width 1 -anchor w -relief sunken] -side bottom -fill x

  canvas $w.progress -height 20 -width 400 -bg white -relief solid -border 1
  $w.progress create rectangle 0 0 0 0 -fill blue -outline blue -tags bar
  $w.progress create text 395 10 -anchor e -font font_Regular -tags time \
    -fill black -text "0:00 / 0:00"
  pack $w.progress -side bottom -pady 2

  frame $w.bd
  pack $w.bd -side left -padx 2 -pady 4

  frame $w.t
  pack $w.t -side right -fill y -expand yes
  pack [frame $w.gap -width 5] -side left

  frame $w.t.color
  frame $w.t.mode
  frame $w.t.moves
  frame $w.t.buttons
  pack $w.t.buttons -side bottom -fill x
  pack $w.t.moves -side bottom
  pack $w.t.mode -side bottom
  pack $w.t.color -side bottom

  set ::ptrack::shade {}
  for {set i 0} {$i < 64} {incr i} {
    label $w.bd.sq$i -image ptrack -background white -border 1 -relief raised
    set rank [expr $i / 8]
    set file [expr $i % 8]
    grid $w.bd.sq$i -row [expr 7 - $rank] -column [expr $file + 1]
    lappend ::ptrack::shade 0.0
  }

  foreach rank {1 2 3 4 5 6 7 8} {
    label $w.bd.r$rank -text $rank -width 2
    grid $w.bd.r$rank -column 0 -row [expr 8 - $rank]
  }

  foreach column {1 2 3 4 5 6 7 8} file {a b c d e f g h} {
    label $w.bd.f$file -text $file
    grid $w.bd.f$file -row 8 -column $column
  }

  grid [frame $w.bd.gap1 -height 5] -row 9 -column 0

  foreach file {a b c d e f g h} c {1 2 3 4 5 6 7 8} p {r n b q k b n r} {
    set sq ${file}8
    set b $w.bd.p$sq
    label $b -image b$p$::ptrack::psize -border 1 -relief raised
    grid $b -row 10 -column $c
    bind $b <1> "::ptrack::select $sq"
  }
  foreach file {a b c d e f g h} c {1 2 3 4 5 6 7 8} p {p p p p p p p p} {
    set sq ${file}7
    set b $w.bd.p$sq
    label $b -image b$p$::ptrack::psize -border 1 -relief raised
    grid $b -row 11 -column $c
    bind $b <1> "::ptrack::select $sq"
    bind $b <3> "::ptrack::select {a7 b7 c7 d7 e7 f7 g7 h7}"
  }
  grid [frame $w.bd.gap2 -height 5] -row 12 -column 0
  foreach file {a b c d e f g h} c {1 2 3 4 5 6 7 8} p {p p p p p p p p} {
    set sq ${file}2
    set b $w.bd.p$sq
    label $b -image w$p$::ptrack::psize -border 1 -relief raised
    grid $b -row 13 -column $c
    bind $b <ButtonPress-1> "::ptrack::select $sq"
    bind $b <3> "::ptrack::select {a2 b2 c2 d2 e2 f2 g2 h2}"
  }
  foreach file {a b c d e f g h} c {1 2 3 4 5 6 7 8} p {r n b q k b n r} {
    set sq ${file}1
    set b $w.bd.p$sq
    label $b -image w$p$::ptrack::psize -border 1 -relief raised
    grid $b -row 14 -column $c
    bind $b <Button-1> "::ptrack::select $sq"
  }

  # Both-piece bindings:
  foreach sq {d1 e1 d8 e8} {
    bind $w.bd.p$sq <3> [list ::ptrack::select $sq]
  }
  foreach left {a b c} right {h g f} {
    set cmd [list ::ptrack::select [list ${left}1 ${right}1]]
    bind $w.bd.p${left}1 <ButtonPress-3> $cmd
    bind $w.bd.p${right}1 <ButtonPress-3> $cmd
    set cmd [list ::ptrack::select [list ${left}8 ${right}8]]
    bind $w.bd.p${left}8 <ButtonPress-3> $cmd
    bind $w.bd.p${right}8 <ButtonPress-3> $cmd
  }

  # Status-bar help:
  foreach sq {d1 e1 d8 e8} {
    bind $w.bd.p$sq <Any-Enter> {
      ::ptrack::status $::tr(TrackerSelectSingle)
    }
    bind $w.bd.p$sq <Any-Leave> ::ptrack::status
  }

  foreach sq {a1 b1 c1 f1 g1 h1 a8 b8 c8 f8 g8 h8} {
    bind $w.bd.p$sq <Any-Enter> {
      ::ptrack::status $::tr(TrackerSelectPair)
    }
    bind $w.bd.p$sq <Any-Leave> ::ptrack::status
  }
  foreach sq {a2 b2 c2 d2 e2 f2 g2 h2 a7 b7 c7 d7 e7 f7 g7 h7} {
    bind $w.bd.p$sq <Any-Enter> {
      ::ptrack::status $::tr(TrackerSelectPawn)
    }
    bind $w.bd.p$sq <Any-Leave> ::ptrack::status
  }
  set plist $::ptrack::select
  ::ptrack::unselect
  ::ptrack::select $plist

  set f $w.t.text
  pack [frame $f] -side top -fill both -expand yes -padx 2 -pady 2
  text $f.text -width 28 -height 1 -foreground black -background white \
    -yscrollcommand "$f.ybar set" -relief sunken -takefocus 0 \
    -wrap none -font font_Small
  set xwidth [font measure [$f.text cget -font] "x"]
  foreach {tab justify} {3 r 5 l 19 r 29 r} {
    set tabwidth [expr $xwidth * $tab]
    lappend tablist $tabwidth $justify
  }
  $f.text configure -tabs $tablist
  scrollbar $f.ybar -takefocus 0 -command "$f.text yview"
  pack $f.ybar -side right -fill y
  pack $f.text -side left -fill y -expand yes

  set f $w.t.color

  menubutton $f.b -menu $f.b.menu -indicatoron 0 -relief raised
  menu $f.b.menu
  foreach col $::ptrack::colors {
    image create photo ptrack_$col -width 101 -height 20
    for {set i 0} {$i <= 100} {incr i} {
      set color [::ptrack::color $i $col]
      ptrack_$col put $color -to $i 0 [expr $i+1] 19
    }
    $f.b.menu add command -image ptrack_$col \
      -command "::ptrack::recolor $col"
  }
  $f.b configure -image ptrack_$::ptrack::color
  label $f.label -text $::tr(GlistColor:) -font font_Bold
  pack $f.label $f.b -side left -pady 5

  set f $w.t.mode
  label $f.mode -text $::tr(TrackerStat:) -font font_Bold
  grid $f.mode -row 0 -column 0
  radiobutton $f.games -text $::tr(TrackerGames) -anchor w \
    -variable ::ptrack::mode -value "-games"
  radiobutton $f.time -text $::tr(TrackerTime) -anchor w \
    -variable ::ptrack::mode -value "-time"
  grid $f.games -row 1 -column 0 -sticky we
  grid $f.time -row 2 -column 0 -sticky we

  set f $w.t.moves
  label $f.lfrom -text $::tr(TrackerMoves:) -font font_Bold
  entry $f.from -width 3 -justify right -textvariable ::ptrack::moves(start)
  label $f.lto -text "-"
  entry $f.to -width 3 -justify right -textvariable ::ptrack::moves(end)
  pack $f.lfrom $f.from $f.lto $f.to -side left -pady 5
  bindFocusColors $f.from
  bindFocusColors $f.to
  bind $f.from <FocusIn> [list +::ptrack::status $::tr(TrackerMovesStart)]
  bind $f.from <FocusOut> +::ptrack::status
  bind $f.to <FocusIn> [list +::ptrack::status $::tr(TrackerMovesStop)]
  bind $f.to <FocusOut> +::ptrack::status

  set f $w.t.buttons
  button $f.stop -text $::tr(Stop) -command sc_progressBar -state disabled
  button $f.update -text $::tr(Update) -command ::ptrack::refresh
  button $f.close -text $::tr(Close) -command "destroy $w"
  pack $f.close $f.update $f.stop -side right -padx 3 -pady 5
  ::ptrack::status
  wm resizable $w 0 0
  focus $w.t.buttons.update
}

# ::ptrack::refresh
#   Regenerates Piece Tracker statistics and updates the window
#
proc ::ptrack::refresh {{type "all"}} {
  set w .ptracker
  if {! [winfo exists $w]} { return }

  # Check if only the color needs refreshing:
  if {$type == "color"} {
    for {set i 0} {$i < 64} {incr i} {
      set x [lindex $::ptrack::shade $i]
      $w.bd.sq$i configure -background [::ptrack::color $x]
    }
    return
  }

  busyCursor .
  $w.t.buttons.update configure -state disabled
  $w.t.buttons.close configure -state disabled
  $w.t.buttons.stop configure -state normal
  catch {grab $w.t.buttons.stop}

  if {$::ptrack::moves(end) < $::ptrack::moves(start)} {
    set ::ptrack::moves(end) $::ptrack::moves(start)
  }

  set timeMode 0
  if {$::ptrack::mode == "-time"} { set timeMode 1 }

  sc_progressBar $w.progress bar 401 21 time
  set data [eval sc_base piecetrack $::ptrack::mode \
              $::ptrack::moves(start) $::ptrack::moves(end) \
              $::ptrack::select]
  set ::ptrack::data $data

  catch {grab release $w.t.buttons.stop}
  $w.t.buttons.stop configure -state disabled
  $w.t.buttons.update configure -state normal
  $w.t.buttons.close configure -state normal
  unbusyCursor .

  set dfilter [sc_filter count]
  if {$timeMode} {
    set nmoves [expr $::ptrack::moves(end) + 1 - $::ptrack::moves(start)]
    set dfilter [expr $dfilter * $nmoves]
  }
  if {$dfilter == 0} { set dfilter 1 } ;# to avoid divide-by-zero

  set max 1
  for {set i 0} {$i < 64} {incr i} {
    set freq [lindex $data $i]
    if {$freq > $max} {set max $freq}
  }

  set ::ptrack::shade {}
  for {set i 0} {$i < 64} {incr i} {
    set freq [lindex $data $i]
    set x [expr $freq * 100.0 / $max]
    set color [::ptrack::color $x]
    lappend ::ptrack::shade $x
    $w.bd.sq$i configure -background $color
  }

  # Update text frame:
  set text $w.t.text.text
  $text delete 1.0 end
  array set printed {}
  for {set top 1} {$top <= 64} {incr top} {
    set best -1
    set idx -1
    for {set i 0} {$i < 64} {incr i} {
      set n [lindex $data $i]
      if {$n > $best  &&  ![info exists printed($i)]} {
        set idx $i
        set best $n
      }
    }

    set printed($idx) 1
    set pct [expr round(double($best) * 10000.0 / double($dfilter)) / 100.0]
    set line [format "\t%2d.\t%s\t%7s\t%6.2f %%" $top \
                [::ptrack::sq $idx] [thousands $best] $pct]
    $text insert end "$line\n"
    set status "  [::ptrack::sq $idx]: [thousands $best] ($pct%%)  $top/64"
    bind $w.bd.sq$idx <Any-Enter> [list ::ptrack::status $status]
    bind $w.bd.sq$idx <Any-Leave> ::ptrack::status
  }
}

###
### End of file: windows.tcl
###

