# epd.tcl: EPD editing windows for Scid.
# Copyright (C) 2000  Shane Hudson

set maxEpd [sc_info limit epd]

proc storeEpdText {id} {
  sc_epd set $id [.epd$id.text get 1.0 "end-1c"]
}

proc storeEpdTexts {} {
  global maxEpd
  for {set i 1} {$i <= $maxEpd} {incr i} {
    if {[winfo exists .epd$i]} { storeEpdText $i }
  }
}

proc updateEpdWin {id} {
  set w .epd$id
  $w.text delete 1.0 end
  $w.text insert end [sc_epd get $id]

  # Update the EPD window status bar:
  set str "  --  "
  if {[sc_epd readonly $id]} {
    set str "  %%  "
  } elseif {[sc_epd altered $id]} {
    set str "  XX  "
  }
  append str "[file tail [sc_epd name $id]]  [sc_epd size $id] positions"
  set moves [lsort -ascii [sc_epd moves $id]]
  set len [llength $moves]
  if {$len} {
    append str "  \[[llength $moves]: [join $moves " "]\]"
  } else {
    append str {  [No moves from this position]}
  }
  $w.status configure -text $str
  unset str
}

proc updateEpdWins {} {
  global maxEpd
  for {set i 1} {$i <= $maxEpd} {incr i} {
    if {[winfo exists .epd$i]} { updateEpdWin $i }
  }
}

proc closeEpdWin {id} {
  catch {sc_epd close $id}
}

proc confirmCloseEpd {id} {
  if {! [winfo exists .epd$id]} { return }
  storeEpdText $id
  if {[sc_epd altered $id]  &&  ! [sc_epd readonly $id]} {
    set result [tk_dialog .dialog "Save changes?" \
      "This file has been altered; do you want to save it?" \
      "" 0 "Save changes" "Close without saving" "Cancel"]
    if {$result == 2} { return }
    if {$result == 0} { sc_epd write $id }
  }
  sc_epd close $id
  focus .
  destroy .epd$id
  return
}

proc saveEpdWin {id} {
  set w .epd$id
  busyCursor . 1
  set temp_oldcursor [$w.text cget -cursor]
  $w.text configure -cursor watch
  update idletasks
  storeEpdText $id
  sc_epd write $id
  updateEpdWin $id
  $w.text configure -cursor $temp_oldcursor
  busyCursor . 0
}

proc epd_MoveToDeepestMatch {id} {
  if {! [winfo exists .epd$id]} { return }
  sc_move ply [sc_epd deepest $id]
  updateBoard .board
  return
}

proc newEpdWin {cmd {fname ""}} {
  global maxEpd
  set showErrors 1
  if {$cmd == "openSilent"} { set showErrors 0 }
  if {$fname == ""} { set showErrors 1 }
  if {[sc_epd available] < 1} {
    if {$showErrors} {
      tk_messageBox -type ok -icon info -title "Too many EPD files open" \
        -message "You already have $maxEpd EPD files open; close one first."
    }
    return 0
  }
  set new_types { {"EPD files" {".epd"} } }
  set open_types $new_types
  if {[sc_info gzip]} {
    set open_types { {"EPD files" {".epd" ".epd.gz"} } }
  }
  if {$fname == ""} {
    if {$cmd == "create"} {
      set fname [tk_getSaveFile -initialdir $::initialDir(epd) -filetypes $new_types -title "Create an EPD file"]
    } elseif {$cmd == "open"} {
      set fname [tk_getOpenFile -initialdir $::initialDir(epd) -filetypes $open_types -title "Open an EPD file"]
    } else { return 0 }
  }
  if {$fname == ""} { return 0 }

  busyCursor . 1
  if {[catch {sc_epd $cmd $fname} result]} {
    if {$showErrors} {
      busyCursor . 0
      tk_messageBox -type ok -icon error -title "Scid: EPD file error" \
        -message $result
    }
    return 0
  }
  busyCursor . 0
  set id $result
  set w .epd$id
  toplevel $w
  wm title $w "Scid EPD: [file tail $fname]"
  wm minsize $w 40 1
  bind $w <Destroy> "closeEpdWin $id"
  bind $w <F1> { helpWindow EPD }

  frame $w.grid
  text $w.text -background white -font font_Regular -width 60 -height 7 \
    -wrap none -setgrid 1 -yscrollcommand "$w.ybar set" \
    -xscrollcommand "$w.xbar set"
  scrollbar $w.ybar -takefocus 0 -command "$w.text yview"
  scrollbar $w.xbar -orient horizontal -takefocus 0 -command "$w.text xview"
  label $w.status -width 1 -anchor w -font font_Small -relief sunken

  frame $w.menu -borderwidth 3 -relief raised
  pack $w.menu  -side top -fill x
  menubutton $w.menu.file -text File -menu $w.menu.file.m -underline 0
  menubutton $w.menu.edit -text Edit -menu $w.menu.edit.m -underline 0
  menubutton $w.menu.tools -text Tools -menu $w.menu.tools.m -underline 0
  menubutton $w.menu.help -text Help -menu $w.menu.help.m -underline 0

  foreach i {file edit tools help} {
    menu $w.menu.$i.m -tearoff 0
    pack $w.menu.$i -side left
  }

  set m $w.menu.file.m
  $m add command -label "New" -acc "Ctrl+N" -underline 0 \
    -command {newEpdWin create}
  bind $w <Control-n> {newEpdWin create}
  $m add command -label "Open" -acc "Ctrl+O" -underline 0 \
    -command {newEpdWin open}
  bind $w <Control-o> {newEpdWin open}
  $m add command -label "Save" -acc "Ctrl+S" -underline 0 \
    -command "saveEpdWin $id"
  if {[sc_epd readonly $id]} {
    $m entryconfig "Save" -state disabled
  } else {
    bind $w <Control-s> "saveEpdWin $id; break"
  }
  $m add command -label "Close" -acc "Ctrl+Q" -underline 0 \
    -command "confirmCloseEpd $id"
  bind $w <Control-q> "confirmCloseEpd $id"

  set m $w.menu.edit.m
  $m add command -label "Cut" -acc "Ctrl+X" -underline 2 -command "tk_textCut $w.text"
  bind $w <Control-x> "tk_textCut $w.text; break"
  $m add command -label "Copy" -acc "Ctrl+C" -underline 0 -command "tk_textCopy $w.text"
  bind $w <Control-c> "tk_textCopy $w.text; break"
  $m add command -label "Paste" -acc "Ctrl+V" -underline 0 -command "tk_textPaste $w.text"
  bind $w <Control-v> "tk_textPaste $w.text; break"
  $m add command -label "Select All" -acc "Ctrl+A" -underline 7 \
    -command "$w.text tag add sel 1.0 end"
  bind $w <Control-a> "$w.text tag add sel 1.0 end; break"
  $m add separator
  $m add command -label "Revert" -acc "Ctrl+R" -underline 0 \
    -command "updateEpdWin $id"
  bind $w <Control-r> "updateEpdWin $id; break"
  $m add command -label "Sort lines" -accel "Ctrl+Shift+S" \
    -underline 0 -command "epd_sortLines $w.text"
  bind $w <Control-S> "epd_sortLines $w.text; break"

  set m $w.menu.tools.m
  $m add command -label "Find Deepest game position" \
    -underline 5 -command "epd_MoveToDeepestMatch $id"
  $m add separator
  $m add command -label "Next position in file" \
    -accelerator "Ctrl+DownArrow" -underline 0 \
    -command "sc_epd next $id; updateBoardAndPgn .board"
  bind $w <Control-Down> "sc_epd next $id; updateBoardAndPgn .board; break"
  $m add command -label "Previous position in file" \
    -accelerator "Ctrl+UpArrow" -underline 0 \
    -command "sc_epd prev $id; updateBoardAndPgn .board"
  bind $w <Control-Up> "sc_epd prev $id; updateBoardAndPgn .board; break"
  $m add separator
  $m add command -label "Paste analysis" -accelerator "Ctrl+Shift+A" \
    -underline 6 -command "epd_pasteAnalysis $w.text"
  bind $w <Control-A> "epd_pasteAnalysis $w.text; break"
  $m add separator
  $m add command -label "Strip out EPD field" -underline 0 \
    -command "epd_chooseStripField $id"

  $w.menu.help.m add command -label "EPD files help" -underline 0 \
    -acc "F1" -command "helpWindow EPD"
  $w.menu.help.m add command -label "General index" -underline 0 \
    -command "helpWindow Index"

  pack $w.status -side bottom -fill x
  pack $w.grid -fill both -expand yes
  grid $w.text -in $w.grid -row 0 -column 0 -sticky news
  grid $w.ybar -in $w.grid -row 0 -column 1 -sticky news
  grid $w.xbar -in $w.grid -row 1 -column 0 -sticky news

  grid rowconfig $w.grid 0 -weight 1 -minsize 0
  grid columnconfig $w.grid 0 -weight 1 -minsize 0

  # Right-mouse button cut/copy/paste menu:
  menu $w.text.edit -tearoff 0
  $w.text.edit add command -label "Cut"  -command "tk_textCut $w.text"
  $w.text.edit add command -label "Copy" -command "tk_textCopy $w.text"
  $w.text.edit add command -label "Paste" -command "tk_textPaste $w.text"
  bind $w.text <ButtonPress-3> "tk_popup $w.text.edit %X %Y"

  updateEpdWin $id
  return 1
}


proc epd_sortLines {textwidget} {
  if {! [winfo exists $textwidget]} { return }
  set text [$textwidget get 1.0 "end-1c"]
  set fieldlist [split $text "\n"]
  set sortedlist [lsort $fieldlist]
  while {[lindex $sortedlist 0] == ""} {
    set sortedlist [lrange $sortedlist 1 end]
  }
  set newtext [join $sortedlist "\n"]
  append newtext "\n"
  if {! [string compare $text $newtext]} { return }
  $textwidget delete 1.0 end
  $textwidget insert end "$newtext"
}

# epd_pasteAnalysis:
#    Pastes current chess engine analysis into this EPD file position.
proc epd_pasteAnalysis {textwidget} {
  global analysis
  if {! [winfo exists $textwidget]} { return }
  if {! [winfo exists .analysisWin1]} { return }
  $textwidget insert insert "acd $analysis(depth1)\n"
  $textwidget insert insert "acn $analysis(nodes1)\n"
  set ce [expr int($analysis(score1) * 100)]
  if {[sc_pos side] == "black"} { set ce [expr 0 - $ce] }
  $textwidget insert insert "ce $ce\n"
  $textwidget insert insert "pv $analysis(moves1)\n"
}


set epd_stripField ""

proc epd_chooseStripField {id} {
  global epd_stripField
  if {! [winfo exists .epd$id]} { return }
  set w [toplevel .epdStrip]
  wm title $w "Scid: Strip EPD field"
  wm resizable $w false false
  label $w.label -text "Enter the name of the EPD field you want\n\
removed from all positions in this file:"
  entry $w.e -width 10 -background white -textvariable epd_stripField
  pack $w.label $w.e -side top -pady 5 -padx 5
  addHorizontalRule $w
  set b [frame $w.buttons]
  pack $b -side bottom -pady 5
  button $b.ok -text "Strip EPD field" \
    -command "epd_stripEpdField $id \$epd_stripField"
  button $b.cancel -text "Cancel" -command "focus .epd$id; destroy $w"
  pack $b.ok $b.cancel -side left -padx 5
  bind $w <Return> "$b.ok invoke"
  bind $w <Escape> "$b.cancel invoke"
  focus .epdStrip.e
  grab .epdStrip
}

proc epd_stripEpdField {id field} {
  if {! [winfo exists .epdStrip]} { return }
  if {! [string compare $field ""]} { beep; return }
  set result [sc_epd strip $id $field]
  updateEpdWin $id
  tk_messageBox -type ok -icon info -title "Scid: EPD field stripped" \
    -message "Scid found and stripped an EPD field named \"$field\" from\
$result positions."
  focus .epd$id
  destroy .epdStrip
}
