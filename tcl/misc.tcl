###
### misc.tcl: part of Scid.
### Copyright (C) 2001  Shane Hudson.
###
### Miscellaneous routines called by other Tcl functions

namespace eval ::date {}

# ::date::today:
#   Returns todays date, in "yyyy.mm.dd" format.
#   The optional parameter "year", "month" or "day" can be used to
#   limit the returned value to just the year, month or day.
#
proc ::date::today {{type all}} {
  set timeNow [clock seconds]
  set year [clock format $timeNow -format "%Y"]
  set month [clock format $timeNow -format "%m"]
  set day [clock format $timeNow -format "%d"]
  switch -- $type {
    "all"   { return [format "%s.%s.%s" $year $month $day] }
    "year"  { return $year }
    "month" { return $month }
    "day"   { return $day }
    default { error "Unrecognised parameter: $type" }
  }
}

image create photo calendar -data {
R0lGODdhFgAUAMIAANnZ2VFR+wAAAP////oTQP//AAAAAAAAACwAAAAAFgAUAAADTwi63A4h
yklrVAFruDO0lCCO5NMIw4CqqWAya9ySdG3LbI7He+vrsxthSLiJfitCoUBAzpwDJRNqFBCL
RqpW1QN6q+DRdrfomsvh2mvtSAAAOw==
}

#::date::chooser:
#   Produce a date-selection dialog box.
#   Originally based on code from Effective Tcl/Tk Programming by
#   Mark Harrison, but with lots of changes and improvements.
#
proc ::date::chooser {{date "now"}} {
  set time [clock seconds]
  if {$date != "now"} {
    catch {set time [clock scan $date]}
  }
  set ::date::_time $time
  set ::date::_selected [clock format $time -format "%Y-%m-%d"]

  set win .dateChooser
  toplevel $win
  canvas $win.cal -width 300 -height 220
  pack [frame $win.b] -side bottom -fill x
  button $win.b.ok -text "OK" -command "destroy $win"
  button $win.b.cancel -text $::tr(Cancel) -command "
    set ::date::_selected {}
    destroy $win"
  pack $win.b.cancel $win.b.ok -side right -padx 5 -pady 5
  pack $win.cal -side top -expand yes -fill both

  button $win.cal.prevY -image tb_start -command "::date::_month $win -12"
  button $win.cal.prev -image tb_prev -command "::date::_month $win -1"
  button $win.cal.next -image tb_next -command "::date::_month $win +1"
  button $win.cal.nextY -image tb_end -command "::date::_month $win +12"
  bind $win.cal <Configure> "::date::_redraw $win"
  bind $win.cal <Double-Button-1> "destroy $win"
  bind $win <Escape> "$win.b.cancel invoke"
  bind $win <Return> "$win.b.ok invoke"
  bind $win <Prior> "$win.cal.prev invoke"
  bind $win <Next> "$win.cal.next invoke"
  bind $win <Shift-Prior> "$win.cal.prevY invoke"
  bind $win <Shift-Next> "$win.cal.nextY invoke"
  bind $win <Up> "::date::_day $win -7"
  bind $win <Down> "::date::_day $win +7"
  bind $win <Left> "::date::_day $win -1"
  bind $win <Right> "::date::_day $win +1"

  wm minsize $win 250 200
  wm title $win "Scid: Choose Date"
  focus $win
  grab $win
  tkwait window $win
  if {$::date::_selected == ""} { return {} }
  set time [clock scan $::date::_selected]
  return [list \
          [clock format $time -format "%Y"] \
          [clock format $time -format "%m"] \
          [clock format $time -format "%d"] \
         ]
}

proc ::date::_day {win delta} {
  set unit "day"
  if {$delta < 0} {set unit "day ago"}
  set time [clock scan "[expr abs($delta)] $unit" -base $::date::_time]
  set day [string trimleft [clock format $time -format "%d"] 0]
  set month [string trimleft [clock format $time -format "%m"] 0]
  set year [clock format $time -format "%Y"]
  ::date::_select $win "$year-$month-$day"
}

proc ::date::_month {win delta} {
  set dir [expr ($delta > 0) ? 1 : -1]
  set day [string trimleft [clock format $::date::_time -format "%d"] 0]
  set month [string trimleft [clock format $::date::_time -format "%m"] 0]
  set year [clock format $::date::_time -format "%Y"]

  for {set i 0} {$i < abs($delta)} {incr i} {
    incr month $dir
    if {$month < 1} {
      set month 12
      incr year -1
    } elseif {$month > 12} {
      set month 1
      incr year 1
    }
  }
  if {[catch {::date::_select $win "$year-$month-$day"}]} {
    ::date::_select $win "$year-$month-28"
  }
}

proc ::date::_redraw {win} {
  $win.cal delete all
  set time $::date::_time
  set wmax [winfo width $win.cal]
  set hmax [winfo height $win.cal]

  $win.cal create window 3 3 -anchor nw -window $win.cal.prevY
  $win.cal create window 40 3 -anchor nw -window $win.cal.prev
  $win.cal create window [expr $wmax-43] 3 -anchor ne -window $win.cal.next
  $win.cal create window [expr $wmax-3] 3 -anchor ne -window $win.cal.nextY
  set bottom [lindex [$win.cal bbox all] 3]

  set month [string trimleft [clock format $time -format "%m"] 0]
  set year [clock format $time -format "%Y"]
  $win.cal create text [expr $wmax/2] $bottom -anchor s -font font_Bold \
    -text "[lindex $::tr(Months) [expr $month - 1]] $year"

  incr bottom 3
  $win.cal create line 0 $bottom $wmax $bottom -width 2
  incr bottom 25

  set current ""

  set layout [::date::_layout $time]
  set weeks [expr [lindex $layout end]+1]

  for {set day 0} {$day < 7} {incr day} {
    set x0 [expr $day*($wmax-7)/7+3]
    set x1 [expr ($day+1)*($wmax-7)/7+3]
    $win.cal create text [expr ($x1+$x0)/2] $bottom -anchor s \
      -text [lindex $::tr(Days) $day] -font font_Small
  }
  incr bottom 3

  foreach {day date dcol wrow} $layout {
    set x0 [expr $dcol*($wmax-7)/7+3]
    set y0 [expr $wrow*($hmax-$bottom-4)/$weeks+$bottom]
    set x1 [expr ($dcol+1)*($wmax-7)/7+3]
    set y1 [expr ($wrow+1)*($hmax-$bottom-4)/$weeks+$bottom]

    if {$date == $::date::_selected} {set current $date}

    $win.cal create rectangle $x0 $y0 $x1 $y1 -outline black -fill white

    $win.cal create text [expr $x0+4] [expr $y0+2] -anchor nw -text "$day" \
      -fill black -font font_Small -tags [list $date-text all-text]

    $win.cal create rectangle $x0 $y0 $x1 $y1 \
      -outline "" -fill "" -tags [list $date-sensor all-sensor]

    $win.cal bind $date-sensor <ButtonPress-1> "::date::_select $win $date"
  }

  if {$current != ""} {
    $win.cal itemconfigure $current-sensor -outline red -width 3
    $win.cal raise $current-sensor
  } elseif {$::date::_selected == ""} {
    set date [clock format $time -format "%Y-%m-%d"]
    ::date::_select $win $date
  }
}

proc ::date::_layout {time} {
  set month [string trimleft [clock format $time -format "%m"] 0]
  set year  [clock format $time -format "%Y"]

  foreach lastday {31 30 29 28} {
    if {[catch {clock scan "$year-$month-$lastday"}] == 0} { break }
  }
  set seconds [clock scan "$year-$month-1"]
  set firstday [clock format $seconds -format %w]
  set weeks [expr ceil(double($lastday+$firstday)/7)]

  set rlist ""
  for {set day 1} {$day <= $lastday} {incr day} {
    set seconds [clock scan "$year-$month-$day"]
    set date [clock format $seconds -format "%Y-%m-%d"]
    set daycol [clock format $seconds -format %w]
    set weekrow [expr ($firstday+$day-1)/7]
    lappend rlist $day $date $daycol $weekrow
  }
  return $rlist
}

proc ::date::_select {win date} {
  set time [clock scan $date]
  set date [clock format $time -format "%Y-%m-%d"]

  set currentMonth [clock format $::date::_time -format "%m %Y"]
  set selectedMonth [clock format $time -format "%m %Y"]
  set ::date::_time $time
  set ::date::_selected $date

  if {$currentMonth == $selectedMonth} {
    $win.cal itemconfigure all-sensor -outline "" -width 1
    $win.cal itemconfigure $date-sensor -outline red -width 3
    $win.cal raise $date-sensor
  } else {
    ::date::_redraw $win
  }
}


# centreWin:
#   Centers a window on the screen.
#
proc centreWin {w} {
  wm withdraw $w
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
                 - [winfo vrootx .]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
                 - [winfo vrooty .]}]
  wm geom $w +$x+$y
  wm deiconify $w
}

# plural:
#   Returns "s" if the number is > 1, "" otherwise.
#   Useful for printing values, e.g. "$value game[plural $value]"
#   will yield "1 game" or "2 games".
#
proc plural {n} {
  if {$n == 1} { return "" }
  return "s"
}

# thousands, percentFormat:
#   Functions to format integer numbers.
#   thousands inserts the thousands separator (usually "," or ".") for
#   every three digits before the decimal separator in the number.
#   percentFormat does the same as thousands, but also adds a percentage.
#   If "kilo" is nonzero, numbers >= $kilo are divided by 1000 and have
#   the unit "K" appended.
#
proc thousands {n {kilo 0}} {
  global locale
  set commaChar [string index $locale(numeric) 1]
  set unit ""
  if {$kilo > 0  &&  $n >= $kilo} {
    set unit "K"
    set n [expr int($n / 1000)]
  }
  if {$commaChar == ""} { return "$n$unit" }
  while {[regsub {^([-+]?[0-9]+)([0-9][0-9][0-9])} $n "\\1$commaChar\\2" n]} {}
  return "$n$unit"
}

proc percentFormat {num denom} {
  # Ensure denominator is not zero:
  if {$denom == 0} {set denom 1}
  return "[thousands $num] ([expr $num * 100 / $denom]%)"
}

# pad:
#   Given a string and a length, pads the string with padChar to have
#   the required length.
#
proc pad {str length {padChar " "}} {
  set s $str
  for {set actual [string length $s]} {$actual < $length} {incr actual} {
    append s $padChar
  }
  return $s
}

# padR:
#   Like pad, but adds the padding characters to the start of the string.
#
proc padR {str length {padChar " "}} {
  set s $str
  for {set actual [string length $s]} {$actual < $length} {incr actual} {
    set s "$padChar$s"
  }
  return $s
}

# padC:
#   Like pad and padR, but centers the specified string.
#
proc padC {str length {padChar " "}} {
  set pre 1
  set s $str
  for {set actual [string length $s]} {$actual < $length} {incr actual} {
    if {$pre} {
      set s "$padChar$s"
      set pre 0
    } else {
      append s $padChar
      set pre 1
    }
  }
  return $s
}

# capital:
#    Returns a string with the first character capitalised.
#
proc capital {str} {
  set s [string toupper [string index $str 0]]
  append s [string range $str 1 end]
  return $s
}


# bindFocusColors:
#   Configures a text or entry widget so it turns lightYellow when it
#   gets the focus, and turns white again when it loses focus.
#
proc bindFocusColors {w {inColor lightYellow} {outColor white}} {
  $w configure -background white
  bind $w <FocusIn> "$w configure -background $inColor"
  bind $w <FocusOut> "$w configure -background $outColor"
}


# bindMouseWheel:
#   Given a window and a text frame within that window, binds
#   the mouse wheel to scroll the text frame vertically.
#
proc bindMouseWheel {win text} {
  bind $win <MouseWheel> \
    [list $text yview scroll {[expr -(%D / 120)]} units]
  if {! $::windowsOS} {
    bind $win <Button-4> [list $text yview scroll -1 units]
    bind $win <Button-5> [list $text yview scroll  1 units]
  }
}

# busyCursor, unbusyCursor:
#   Sets all cursors to watch (indicating busy) or back to their normal
#   setting again.

array set scid_busycursor {}
set scid_busycursorState 0

proc doBusyCursor {w flag} {
  global scid_busycursor
  if {! [winfo exists $w]} { return }
  # The comment editor window "flashes" when its cursor is changed,
  # no idea why but skip over it:
  if {$w == ".commentWin"} { return }
  if {$w == ".menu"} { return }

  if {$flag} {
    set scid_busycursor($w) [$w cget -cursor]
    catch {$w configure -cursor watch}
  } else {
    catch {$w configure -cursor $scid_busycursor($w)} err
  }
  foreach i [winfo children $w] { doBusyCursor $i $flag }
}

proc busyCursor {w {flag 1}} {
  global scid_busycursor scid_busycursorState
  if {$scid_busycursorState == $flag} { return }
  set scid_busycursorState $flag
  doBusyCursor $w $flag
}

proc unbusyCursor {w} {busyCursor $w 0}


# addHorizontalRule, addVerticalRule
#   Add a horizontal/vertical rule frame to a window.
#   The optional parameters [x/y]padding and sunken allow the spacing and
#   appearance of the rule to be specified.
#
set horizRuleCounter 0
set vertRuleCounter 0

proc addHorizontalRule {w {ypadding 5} {relief sunken} {height 2} } {
  global horizRuleCounter
  set f [ frame $w.line$horizRuleCounter -height $height -borderwidth 2 \
            -relief $relief -background white ]
  pack $f -fill x -pady $ypadding
  incr horizRuleCounter
  return $f
}

proc addVerticalRule {w {xpadding 5} {relief sunken}} {
  global vertRuleCounter
  set f [ frame $w.line$vertRuleCounter -width 2 -borderwidth 2 \
            -relief $relief -background white ]
  pack $f -fill y -padx $xpadding -side left
  incr vertRuleCounter
  return $f
}


## Variable tracing:

# forceInt:
#   Used to check the size of integers in entry boxes.
#
proc forceInt {maxValue allowQuestionMarks name el op} {
  global $name ${name}_old
  if {[string comp {} $el]} {
    set old  ${name}_old\($el\)
    set name $name\($el\)
  } else {
    set old ${name}_old
  }

  if {$allowQuestionMarks > 0} {
    if {[regexp {^\?*$} [set $name]]} {
      # Accept this value:
      set $old [set $name]
      return
    }
  }

  # Only non-negative integers up to maxValue are allowed, unless the
  # value is negative:
  set allowNegatives 0
  if {$maxValue < 0} {
    set allowNegatives 1
    set maxValue [expr 0 - $maxValue]
  }

  if {$allowNegatives} {
    if {![regexp {^[-+]?[0-9]*$} [set $name]]} {
      set $name [set $old]
      bell
      return
    }
  } else {
    if {![regexp {^[+]?[0-9]*$} [set $name]]} {
      set $name [set $old]
      bell
      return
    }
  }
  if {[set $name] > $maxValue} {
    set $name [set $old]
    bell
    return
  }
  #if {[expr {0 - [set $name]}] < [expr {0 - $maxValue}]} {
  #  set $name [set $old]
  #  bell
  #  return
  #}
  set $old [set $name]
}

# forceDate:
#    Used to check the validity of a date string as it is entered.
#
proc forceDate {name el op} {
  global $name ${name}_old
  set old ${name}_old
  if {![sc_info validDate [set $name]]} {
    set $name [set $old]
    bell
    return
  }
  set $old [set $name]
}

# forceResult:
#    Used to check the validity of a result entrybox value.
#    Result can be empty, "1", "0", "=", or "*".
#
proc forceResult {name el op} {
  global $name ${name}_old
  set old ${name}_old
  if {![regexp {^[1|0|=|\*]?$} [set $name]]} {
    set $name [set $old]
    bell
    return
  }
  set $old [set $name]
}

# forceAlpha:
#    Used to check that an entrybox contains only letters.
proc forceAlpha {name el op} {
  global $name ${name}_old
  set old ${name}_old
  if {![regexp {^[A-Za-z]*$} [set $name]]} {
    set $name [set $old]
    bell
    return
  }
  set $old [set $name]

}

# forceRegexp:
#    Used to check the validity of an entrybox given a regular expression.
#    Used to verify a file is "a-h", for example.
#
proc forceRegexp {expression name el op} {
  global $name ${name}_old
  set old ${name}_old
  if ![regexp $expression [set $name]] {
    set $name [set $old]
    bell
    return
  }
  set $old [set $name]
}


# progressWindow:
#   Creates a window with a label, progress bar, and (if specified),
#   a cancel button and cancellation command.
#
proc progressWindow {args} {
  set w .progressWin
  if {[winfo exists $w]} { return }
  toplevel $w
  wm withdraw $w
  wm resizable $w 0 0
  if {[llength $args] == 2} {
    set title [lindex $args 0]
    set text [lindex $args 1]
    set b 0
  } elseif {[llength $args] == 4} {
    set title [lindex $args 0]
    set text [lindex $args 1]
    set button [lindex $args 2]
    set command [lindex $args 3]
    set b 1
  } else { return }
  wm title $w $title
  label $w.t -text $text
  pack $w.t -side top
  canvas $w.c -width 400 -height 20 -bg white -relief solid -border 1
  $w.c create rectangle 0 0 0 0 -fill blue -outline blue -tags bar
  $w.c create text 395 10 -anchor e -font font_Regular -tags time \
    -fill black -text "0:00 / 0:00"
  pack $w.c -side top -pady 10
  if {$b} {
    pack [frame $w.b] -side bottom -fill x
    button $w.b.cancel -text $button -command $command
    pack $w.b.cancel -side right -padx 5 -pady 2
  }
  # Set up geometry for middle of screen:
  set x [winfo screenwidth $w]
  set x [expr $x - 400]
  set x [expr $x / 2]
  set y [winfo screenheight $w]
  set y [expr $y - 20]
  set y [expr $y / 2]
  wm geometry $w +$x+$y
  sc_progressBar $w.c bar 401 21 time
  update idletasks
  wm deiconify $w
  raiseWin $w
  if {$b} {
    grab $w.b.cancel
  } else {
    grab $w
  }
  bind $w <Visibility> "raiseWin $w"
  set ::progressWin_time [clock seconds]
}

proc leftJustifyProgressWindow {} {
  set w .progressWin
  if {! [winfo exists $w]} { return }
  pack configure $w.t -fill x
  $w.t configure -width 1 -anchor w
}

proc changeProgressWindow {newtext} {
  set w .progressWin
  if {[winfo exists $w]} { 
    $w.t configure -text $newtext
    update idletasks
  }
}

proc resetProgressWindow {} {
  set w .progressWin
  set ::progressWin_time [clock seconds]
  if {[winfo exists $w]} { 
    $w.c coords bar 0 0 0 0
    $w.c itemconfigure time -text "0:00 / 0:00"
    update idletasks
  }
}

proc updateProgressWindow {done total} {
  set w .progressWin
  if {! [winfo exists $w]} { return }
  set elapsed [expr [clock seconds] - $::progressWin_time]
  set width 401
  if {$total > 0} { 
    set width [expr int(double($width) * double($done) / double($total))]
  }
  $w.c coords bar 0 0 $width 21
  set estimated $elapsed
  if {$done != 0} {
    set estimated [expr int(double($elapsed) * double($total) / double($done))]
  }
  set t [format "%d:%02d / %d:%02d" \
           [expr $elapsed / 60] [expr $elapsed % 60] \
           [expr $estimated / 60] [expr $estimated % 60]]
  $w.c itemconfigure time -text $t
  update
}

proc closeProgressWindow {} {
  set w .progressWin
  if {! [winfo exists $w]} {
    # puts stderr "Hmm, no progress window -- bug?"
    return
  }
  grab release $w
  destroy $w
}


# The following paned window code is from the book:
#
#  Effective Tcl/Tk Programming
#     Mark Harrison, DSC Communications Corp.
#     Michael McLennan, Bell Labs Innovations for Lucent Technologies
#     Addison-Wesley Professional Computing Series
#  Copyright (c) 1996-1997  Lucent Technologies Inc. and Mark Harrison
#
# Some modifications and improvements for use in Scid have been made,
# including namespacing the code.
#
#  -- Shane Hudson, February 2000.

namespace eval ::pane {}
array set ::pane::_data {}

proc ::pane::create {win pane1 pane2 width height {ratio 0.5} {orient vert}} {
  set ::pane::_data($win,1) $pane1
  set ::pane::_data($win,2) $pane2
  set ::pane::_data($win,drag) 1
  set vertical 1
  if {[string index $orient 0] == "h"} { set vertical 0 }
  set ::pane::_data($win,vertical) $vertical
  # Default minimum size of each frame is 10%:
  set ::pane::_data($win,min) 0.1
  set ::pane::_data($win,max) 0.9

  frame $win -width $width -height $height
  frame $win.$pane1
  frame $win.$pane2
  if {$vertical} {
    place $win.$pane1 -relx 0.5 -rely 0 -anchor n -relwidth 1.0 -relheight 0.5
    place $win.$pane2 -relx 0.5 -rely 1 -anchor s -relwidth 1.0 -relheight 0.5

    frame $win.pane_sash -height 1 -borderwidth 1 -relief flat \
      -cursor sb_v_double_arrow -background black
    place $win.pane_sash -relx 0.5 -rely 0.5 -relwidth 1.0 -anchor c

    frame $win.pane_grip -width 20 -height 7 -borderwidth 1 -relief solid \
      -cursor sb_v_double_arrow -background gray
    place $win.pane_grip -relx 0.95 -rely 0.5 -anchor c
  } else {
    place $win.$pane1 -relx 0 -rely 0.5 -anchor w -relwidth 0.5 -relheight 1.0
    place $win.$pane2 -relx 1 -rely 0.5 -anchor e -relwidth 0.5 -relheight 1.0

    frame $win.pane_sash -width 1 -borderwidth 1 -relief flat \
      -cursor sb_h_double_arrow -background black
    place $win.pane_sash -relx 0.5 -rely 0.5 -relheight 1.0 -anchor c

    frame $win.pane_grip -height 20 -width 7 -borderwidth 1 -relief solid \
      -cursor sb_h_double_arrow -background gray
    place $win.pane_grip -relx 0.5 -rely 0.95 -anchor c
  }

  #bind $win.pane_grip <Enter>           "::pane::enter $win"
  #bind $win.pane_grip <Leave>           "::pane::leave $win"
  #bind $win.pane_sash <Enter>           "::pane::enter $win"
  #bind $win.pane_sash <Leave>           "::pane::leave $win"

  if {$vertical} { set c "%Y" } else { set c "%X" }
  bind $win.pane_grip <ButtonPress-1>   "::pane::grab $win"
  bind $win.pane_grip <B1-Motion>       "::pane::drag $win $c"
  bind $win.pane_grip <ButtonRelease-1> "::pane::drop $win $c"
  bind $win.pane_sash <ButtonPress-1>   "::pane::grab $win"
  bind $win.pane_sash <B1-Motion>       "::pane::drag $win $c"
  bind $win.pane_sash <ButtonRelease-1> "::pane::drop $win $c"

  ::pane::divide $win $ratio
  return $win
}

proc ::pane::setdrag {win bool} {
  set ::pane::_data($win,drag) $bool
}

proc ::pane::range {win min max} {
  set ::pane::_data($win,min) $min
  set ::pane::_data($win,max) $max
}

proc ::pane::enter {win} {
  $win.pane_sash configure -background yellow
  $win.pane_grip configure -background yellow
}

proc ::pane::leave {win} {
  $win.pane_sash configure -background black
  $win.pane_grip configure -background black
}

proc ::pane::grab {win} {
  $win.pane_sash configure -background red
  $win.pane_grip configure -background red
}

proc ::pane::drag {win y} {
  set vertical $::pane::_data($win,vertical)
  if {$vertical} {
    set realY [expr $y-[winfo rooty $win]]
    set Ymax  [winfo height $win]
  } else {
    set realY [expr $y-[winfo rootx $win]]
    set Ymax  [winfo width $win]
  }
  set frac [expr double($realY)/$Ymax]
  if {$frac < $::pane::_data($win,min)} {set frac $::pane::_data($win,min)}
  if {$frac > $::pane::_data($win,max)} {set frac $::pane::_data($win,max)}

  if {$::pane::_data($win,drag)} {
    ::pane::divide $win $frac
  } else {
    if {$vertical} {
      place $win.pane_sash -rely $frac
      place $win.pane_grip -rely $frac
    } else {
      place $win.pane_sash -relx $frac
      place $win.pane_grip -relx $frac
    }
  }
  return $frac
}

proc ::pane::drop {win y} {
  set frac [::pane::drag $win $y]
  ::pane::divide $win $frac
  $win.pane_sash configure -background black
  $win.pane_grip configure -background gray
}

proc ::pane::divide {win frac} {
  if {$::pane::_data($win,vertical)} {
    place $win.pane_sash -rely $frac
    place $win.pane_grip -rely $frac
    place $win.$::pane::_data($win,1) -relheight $frac
    place $win.$::pane::_data($win,2) -relheight [expr 1-$frac]
  } else {
    place $win.pane_sash -relx $frac
    place $win.pane_grip -relx $frac
    place $win.$::pane::_data($win,1) -relwidth $frac
    place $win.$::pane::_data($win,2) -relwidth [expr 1-$frac]
  }
}


