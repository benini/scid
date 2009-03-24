###
### misc.tcl: part of Scid.
### Copyright (C) 2001  Shane Hudson.
### Copyright (C) 2007  Pascal Georges
###
### Miscellaneous routines called by other Tcl functions

################################################################################
# vwait but will timeout after a delay. Var must be fully qualified (::)
################################################################################
proc vwaitTimed { var {delay 0} {warn "warnuser"} } {
  
  proc trigger {var warn} {
    if {$warn == "warnuser"} {
      tk_messageBox -type ok -icon error -parent . -title "Protocol error" -message "vwait timeout for $var"
    }
    set $var 1
  }
  
  if { $delay != 0 } {
    set timerId [after $delay "trigger $var $warn"]
  }
  
  vwait $var
  
  if [info exists timerId] { after cancel $timerId }
  
}

################################################################################
# bindFocusColors:
#   Configures a text or entry widget so it turns lightYellow when it
#   gets the focus, and turns white again when it loses focus.
#
# THIS IS CURRENTLY DISABLED since it works fine with regular entry widgets
# but causes problems with our combobox widgets, not sure why!
#
proc bindFocusColors {w {inColor lightYellow} {outColor white}} {
  $w configure -background $outColor
  #bind $w <FocusIn> "+$w configure -background $inColor"
  #bind $w <FocusOut> "+$w configure -background $outColor"
}


# bindMouseWheel:
#   Given a window and a text frame within that window, binds
#   the mouse wheel to scroll the text frame vertically.
#
proc bindMouseWheel {win text} {
  bind $win <MouseWheel> \
      "$text yview scroll \[expr -(%D / 120)\] units"
  if {! $::windowsOS} {
    bind $win <Button-4> [list $text yview scroll -1 units]
    bind $win <Button-5> [list $text yview scroll  1 units]
  }
}

# dialogbuttonframe:
#   Creates a frame that will be shown at the bottom of a
#   dialog window. It takes two parameters: the frame widget
#   name to create, and a list of button args. Each element
#   should contain a widget name, and button arguments.
#
proc dialogbuttonframe {frame buttonlist} {
  ttk::frame $frame
  set bnames {}
  set maxlength 0
  foreach buttonargs $buttonlist {
    set bname $frame.[lindex $buttonargs 0]
    set bargs [lrange $buttonargs 1 end]
    eval ttk::button $bname $bargs
    set bnames [linsert $bnames 0 $bname]
    set length [string length [$bname cget -text]]
    if {$length > $maxlength} { set length $maxlength}
  }
  if {$maxlength < 7} { set maxlength 7 }
  foreach b $bnames {
    $b configure -width $maxlength -padx 4
    pack $b -side right -padx 4 -pady 4
  }
}

# packbuttons
#   Packs a row of dialog buttons to the left/right of their frame
#   with a standard amount of padding.
#
proc packbuttons {side args} {
  eval pack $args -side $side -padx 5 -pady 3
}

# dialogbutton:
#   Creates a button that will be shown in a dialog box, so it
#   is given a minumin width.
#
proc dialogbutton {w args} {
  set retval [eval ttk::button $w $args] ;# -style TButton
  set length [string length [$w cget -text]]
  if {$length < 7} { set length 7 }
  $w configure -width $length
  return retval
}

proc dialogbuttonsmall {w args {style "Small.TButton"} } {
  set retval [eval ttk::button $w -style $style $args]
  set length [string length [$w cget -text]]
  if {$length < 7} { set length 7 }
  $w configure -width $length
  return retval
}

# autoscrollframe
#   Creates and returns a frame containing a widget which is gridded
#   with scrollbars that automatically hide themselves when they are
#   not needed.
#   The frame and widget may already exist; they are created if needed.
#   Usage:
#      autoscrolltext [-bars none|x|y|both] frame type w args
#
proc autoscrollframe {args} {
  global _autoscroll
  set bars both
  if {[lindex $args 0] == "-bars"} {
    set bars [lindex $args 1]
    if {$bars != "x" && $bars != "y" && $bars != "none" && $bars != "both"} {
      return -code error "Invalid parameter: -bars $bars"
    }
    set args [lrange $args 2 end]
  }
  if {[llength $args] < 3} {
    return -code error "Insufficient number of parameters"
  }
  set frame [lindex $args 0]
  set type [lindex $args 1]
  set w [lindex $args 2]
  set args [lrange $args 3 end]
  
  set retval $frame
  if {! [winfo exists $frame]} { frame $frame }
  $frame configure -relief sunken -borderwidth 2
  if {! [winfo exists $w]} {
    $type $w
  }
  if {[llength $args] > 0} {
    eval $w configure $args
  }
  $w configure -relief flat -borderwidth 0
  grid $w -in $frame -row 0 -column 0 -sticky news
  set setgrid 0
  catch {set setgrid [$w cget -setgrid]}
  
  if {$bars == "y"  ||  $bars == "both"} {
    ttk::scrollbar $frame.ybar -command [list $w yview] -takefocus 0
    $w configure -yscrollcommand [list _autoscroll $frame.ybar]
    grid $frame.ybar -row 0 -column 1 -sticky ns
    set _autoscroll($frame.ybar) 1
    set _autoscroll(time:$frame.ybar) [clock clicks -milli]
    if {! $setgrid} {
      # bind $frame.ybar <Map> [list _autoscrollMap $frame]
    }
  }
  if {$bars == "x"  ||  $bars == "both"} {
    ttk::scrollbar $frame.xbar -command [list $w xview] -takefocus 0 -orient horizontal
    $w configure -xscrollcommand [list _autoscroll $frame.xbar]
    grid $frame.xbar -row 1 -column 0 -sticky we
    set _autoscroll($frame.xbar) 1
    set _autoscroll(time:$frame.xbar) [clock clicks -milli]
    if {! $setgrid} {
      # bind $frame.xbar <Map> [list _autoscrollMap $frame]
    }
  }
  grid rowconfigure $frame 0 -weight 1
  grid columnconfigure $frame 0 -weight 1
  grid rowconfigure $frame 1 -weight 0
  grid columnconfigure $frame 1 -weight 0
  return $retval
}

array set _autoscroll {}

# _autoscroll
#   This is the "set" command called for auto-scrollbars.
#   If the bar is shown but should not be, it is hidden.
#   If the bar is hidden but should be shown, it is redrawn.
#   Note that once a bar is shown, it will not be removed again for
#   at least a few milliseconds; this is to overcome problematic
#   interactions between the x and y scrollbars where hiding one
#   causes the other to be shown etc. This usually happens because
#   the stupid Tcl/Tk text widget doesn't handle scrollbars well.
#
proc _autoscroll {bar args} {
  global _autoscroll
  if {[llength $args] == 2} {
    set min [lindex $args 0]
    set max [lindex $args 1]
    if {$min > 0.0  ||  $max < 1.0} {
      if {! $_autoscroll($bar)} {
        grid configure $bar
        set _autoscroll($bar) 1
        set _autoscroll(time:$bar) [clock clicks -milli]
      }
    } else {
      if {[clock clicks -milli] > [expr {$_autoscroll(time:$bar) + 100}]} {
        grid remove $bar
        set _autoscroll($bar) 0
      }
    }
    # update idletasks
  }
  eval $bar set $args
}

proc _autoscrollMap {frame} {
  # wm geometry [winfo toplevel $frame] [wm geometry [winfo toplevel $frame]]
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
  if {[winfo class $w] == "Menu"} { return }
  
  if {$flag} {
    if { [ catch { set scid_busycursor($w) [$w cget -cursor] } ] } {
      return
    }
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
  
  ttk::separator $w.line$horizRuleCounter -orient horizontal
  pack $w.line$horizRuleCounter -fill x ;# -pady $ypadding
  
  # set f [ ttk::frame $w.line$horizRuleCounter -height $height -borderwidth 2 -relief $relief ]
  # pack $f -fill x -pady $ypadding
  incr horizRuleCounter
}

proc addVerticalRule {w {xpadding 5} {relief sunken}} {
  global vertRuleCounter
  
  ttk::separator $w.line$vertRuleCounter -orient vertical
  pack $w.line$vertRuleCounter -fill y -side left ;# -padx $xpadding
  
  # set f [ ttk::frame $w.line$vertRuleCounter -width 2 -borderwidth 2 -relief $relief ]
  # pack $f -fill y -padx $xpadding -side left
  incr vertRuleCounter
}

# progressWindow:
#   Creates a window with a label, progress bar, and (if specified),
#   a cancel button and cancellation command.
#
proc progressWindow {args} {
  set w .progressWin
  if {[winfo exists $w]} { return }
  toplevel $w
  pack [ttk::frame $w.f] -expand 1
  
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
  ttk::label $w.f.t -text $text
  pack $w.f.t -side top -expand 1 -fill both
  canvas $w.f.c -width 400 -height 20 -bg white -relief solid -border 1
  $w.f.c create rectangle 0 0 0 0 -fill blue -outline blue -tags bar
  $w.f.c create text 395 10 -anchor e -font font_Regular -tags time -fill black -text "0:00 / 0:00"
  pack $w.f.c -side top -pady 10
  if {$b} {
    pack [ttk::frame $w.f.b] -side bottom -fill x
    ttk::button $w.f.b.cancel -text $button -command $command
    pack $w.f.b.cancel -side right -padx 5 -pady 2
  }
  # Set up geometry for middle of screen:
  set x [winfo screenwidth $w]
  set x [expr {$x - 400} ]
  set x [expr {$x / 2} ]
  set y [winfo screenheight $w]
  set y [expr {$y - 20} ]
  set y [expr {$y / 2} ]
  wm geometry $w +$x+$y
  sc_progressBar $w.f.c bar 401 21 time
  update idletasks
  wm deiconify $w
  raiseWin $w
  if {$b} {
    catch { grab $w.f.b.cancel }
  } else {
    grab $w
  }
  bind $w <Visibility> "raiseWin $w"
  set ::progressWin_time [clock seconds]
}

proc leftJustifyProgressWindow {} {
  set w .progressWin
  if {! [winfo exists $w]} { return }
  pack configure $w.f.t -fill x
  $w.f.t configure -width 1 -anchor w
}

proc changeProgressWindow {newtext} {
  set w .progressWin
  if {[winfo exists $w]} {
    $w.f.t configure -text $newtext
    update idletasks
  }
}

proc resetProgressWindow {} {
  set w .progressWin
  set ::progressWin_time [clock seconds]
  if {[winfo exists $w]} {
    $w.f.c coords bar 0 0 0 0
    $w.f.c itemconfigure time -text "0:00 / 0:00"
    update idletasks
  }
}

proc updateProgressWindow {done total} {
  set w .progressWin
  if {! [winfo exists $w]} { return }
  set elapsed [expr {[clock seconds] - $::progressWin_time}]
  set width 401
  if {$total > 0} {
    set width [expr {int(double($width) * double($done) / double($total))}]
  }
  $w.f.c coords bar 0 0 $width 21
  set estimated $elapsed
  if {$done != 0} {
    set estimated [expr {int(double($elapsed) * double($total) / double($done))}]
  }
  set t [format "%d:%02d / %d:%02d" \
      [expr {$elapsed / 60}] [expr {$elapsed % 60}] \
      [expr {$estimated / 60}] [expr {$estimated % 60}]]
  $w.f.c itemconfigure time -text $t
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
################################################################################
# clock widget
################################################################################
namespace eval gameclock {
  array set data {}
  ################################################################################
  proc new { parent n { size 100 } {showfall 0} } {
    global ::gameclock::data
    set data(showfallen$n) $showfall
    set data(id$n) $parent.clock$n
    canvas $data(id$n) -height $size -width $size
    pack $data(id$n) -side top -anchor center
    for {set i 1} {$i<13} {incr i} {
      set a [expr {$i/6.*acos(-1)}]
      set x [expr { ($size/2 + (($size-15)/2)*sin($a) ) }]
      set y [expr { ($size/2 - (($size-15)/2)*cos($a) ) }]
      $data(id$n) create text $x $y -text $i -tag clock$n
    }
    set data(fg$n) "black"
    set data(running$n) 0
    set data(digital$n) 1
    ::gameclock::reset $n
    ::gameclock::draw $n
    bind $data(id$n) <Button-1> "::gameclock::toggleClock $n"
  }
  ################################################################################
  proc draw { n } {
    global ::gameclock::data
    if {! [winfo exists $data(id$n)]} { return }
    $data(id$n) delete aig$n
    
    set w [$data(id$n) cget -width ]
    set h [$data(id$n) cget -height ]
    set cx [ expr $w / 2 ]
    set cy [ expr $h / 2 ]
    if {$w < $h} {
      set size [ expr $w - 15 ]
    } else  {
      set size [ expr $h - 15 ]
    }
    
    set sec $data(counter$n)
    if { $sec > 0 && $data(showfallen$n) } {
      set color "red"
    } else  {
      set color $::gameclock::data(fg$n)
    }
    
    if {$color == "white"} {set fg "black"} else {set fg "white"}
    
    foreach divisor {30 1800 21600} length "[expr $size/2 * 0.8] [expr $size/2 * 0.7] [expr $size/2 * 0.4]" \
        width {1 2 3} {
          set angle [expr {$sec * acos(-1) / $divisor}]
          set x [expr {$cx + $length * sin($angle)}]
          set y [expr {$cy - $length * cos($angle)}]
          $data(id$n) create line $cx $cy $x $y -width $width -tags aig$n -fill $color
        }
    # draw a digital clock
    if {$data(digital$n)} {
      set m [format "%02d" [expr abs($sec) / 60] ]
      set s [format "%02d" [expr abs($sec) % 60] ]
      $data(id$n) create text $cx [expr $cy + $size/4 ] -text "$m:$s" -anchor center -fill $color -tag aig$n
    }
  }
  ################################################################################
  proc every {ms body n} {
    incr ::gameclock::data(counter$n)
    eval $body
    if {[winfo exists $::gameclock::data(id$n)]} {
      after $ms [info level 0]
    }
  }
  ################################################################################
  proc getSec { n } {
    return [expr 0 - $::gameclock::data(counter$n)]
  }
  ################################################################################
  proc setSec { n value } {
    set ::gameclock::data(counter$n) $value
    ::gameclock::draw $n
  }
  ################################################################################
  proc add { n value } {
    set ::gameclock::data(counter$n) [ expr $::gameclock::data(counter$n) - $value ]
    ::gameclock::draw $n
  }
  
  ################################################################################
  proc reset { n } {
    ::gameclock::stop $n
    set ::gameclock::data(counter$n) 0
  }
  ################################################################################
  proc start { n } {
    if {$::gameclock::data(running$n)} { return }
    set ::gameclock::data(running$n) 1
    ::gameclock::every 1000 "draw $n" $n
  }
  ################################################################################
  proc stop { n } {
    if {! $::gameclock::data(running$n)} { return }
    set ::gameclock::data(running$n) 0
    after cancel "::gameclock::every 1000 \{draw $n\} $n"
  }
  ################################################################################
  proc toggleClock { n } {
    if { $::gameclock::data(running$n) } {
      stop $n
    } else  {
      start $n
    }
  }
  ################################################################################
  proc setColor { n color } {
    if {$color == "white"} {
      set fg "black"
      set bg "white"
    } else {
      set fg "white"
      set bg "black"
    }
    set ::gameclock::data(fg$n) $fg
    $::gameclock::data(id$n) configure -background $bg
    $::gameclock::data(id$n) itemconfigure clock$n -fill $fg
    $::gameclock::data(id$n) itemconfigure aig$n -fill $fg
  }
}
################################################################################
# html generation
################################################################################
namespace eval html {
  set data {}
  set idx 0
  set black_square "#7389b6"
  set white_square "#f3f3f3"
  
  ################################################################################
  proc exportCurrentFilter {} {
    # Check that we have some games to export:
    if {![sc_base inUse]} {
      tk_messageBox -title "Scid: Empty database" -type ok -icon info \
          -message "This is an empty database, there are no games to export."
      return
    }
    if {[sc_filter count] == 0} {
      tk_messageBox -title "Scid: Filter empty" -type ok -icon info \
          -message "The filter contains no games."
      return
    }
    set ftype {
      { "HTML files" {".html" ".htm"} }
      { "All files" {"*"} }
    }
    set idir $::initialDir(html)
    set fName [tk_getSaveFile -initialdir $idir -filetypes $ftype -defaultextension ".html" -title "Create an HTML file"]
    if {$fName == ""} { return }
    if {[file extension $fName] != ".html" } {
      append fName ".html"
    }
    set prefix [file rootname [file tail $fName] ]
    set dirtarget [file dirname $fName]
    set sourcedir [file join $::scidExeDir html]
    catch {file copy -force [file join $sourcedir bitmaps] $dirtarget}
    catch {file copy -force [file join $sourcedir scid.js] $dirtarget}
    catch {file copy -force [file join $sourcedir scid.css] $dirtarget}
    # writeIndex "[file join $dirtarget $prefix].html" $prefix
    progressWindow "Scid" "Exporting games..." $::tr(Cancel) "sc_progressBar"
    busyCursor .
    set savedGameNum [sc_game number]
    set gn [sc_filter first]
    set players {}
    set ::html::cancelHTML 0
    set total [sc_filter count]
    
    # build the list of matches
        set idx 1
    while {$gn != 0 && ! $::html::cancelHTML} {
      updateProgressWindow $idx $total
      sc_game load $gn
      set pl "[sc_game tags get White] - [sc_game tags get Black]"
      lappend players $pl
      set gn [sc_filter next]
      incr idx
    }
    
    set idx 1
    set gn [sc_filter first]
    while {$gn != 0 && ! $::html::cancelHTML} {
      updateProgressWindow $idx $total
      sc_game load $gn
      fillData
      set pl "[sc_game tags get White] - [sc_game tags get Black]"
      toHtml $::html::data $idx $dirtarget $prefix $players $pl [sc_game tags get "Event"] [sc_game tags get "ECO"] [sc_game info result] [sc_game tags get "Date"]
      set gn [sc_filter next]
      incr idx
    }
    
    # navhtml $dirtarget $players $prefix
    closeProgressWindow
    unbusyCursor .
    exportPGN "[file join $dirtarget $prefix].pgn" "filter"
    sc_game load $savedGameNum
  }
  ################################################################################
  proc sc_progressBar {} {
    set ::html::cancelHTML 1
  }
  ################################################################################
  proc exportCurrentGame {} {
    
    set ftype {
      { "HTML files" {".html" ".htm"} }
      { "All files" {"*"} }
    }
    set idir $::initialDir(html)
    set fName [tk_getSaveFile -initialdir $idir -filetypes $ftype -defaultextension ".html" -title "Create an HTML file"]
    if {[file extension $fName] != ".html" && [file extension $fName] != ".htm" } {
      append fName ".html"
    }
    if {$fName == ""} { return }
    set prefix [file rootname [file tail $fName] ]
    set dirtarget [file dirname $fName]
    set sourcedir [file join $::scidExeDir html]
    catch { file copy -force [file join $sourcedir bitmaps] $dirtarget }
    catch { file copy -force [file join $sourcedir scid.js] $dirtarget }
    catch { file copy -force [file join $sourcedir scid.css] $dirtarget }
    # writeIndex "[file join $dirtarget $prefix].html" $prefix
    
    fillData
    set players [list "[sc_game tags get White] - [sc_game tags get Black]"]
    # navhtml $dirtarget $players $prefix
    toHtml $::html::data 1 $dirtarget $prefix $players $players \
        [sc_game tags get "Event"] [sc_game tags get "ECO"] \
        [sc_game info result] [sc_game tags get "Date"]
    exportPGN "[file join $dirtarget $prefix].pgn" "current"
  }
  ################################################################################
  proc toHtml { dt game dirtarget prefix {players ""} {this_players ""} {event ""} {eco "ECO"} {result "*"} {date ""} } {
    set f [open "[file join $dirtarget $prefix]_${game}.html" w]
    # header
    puts $f "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Strict//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd\">"
    puts $f "<html xmlns=\"http://www.w3.org/1999/xhtml\" xml:lang=\"en\" lang=\"en\">"
    puts $f "<head>"
    puts $f "<meta http-equiv=\"content-type\" content=\"text/html; charset=utf-8\" />"
    puts $f "<link rel=\"stylesheet\" type=\"text/css\" href=\"scid.css\" />"
    puts $f "<script src=\"scid.js\" type=\"text/javascript\"></script>"
    puts $f "<script type=\"text/javascript\">"
    puts $f "// <!\[CDATA\["
    puts $f "movesArray = new Array("
    for {set i 0} {$i<[llength $dt]} {incr i} {
      array set elt [lindex $dt $i]
      puts -nonewline $f "\"$elt(fen) $elt(prev) $elt(next)\""
      if {$i < [expr [llength $dt] -1]} { puts $f "," }
    }
    puts $f ");"
    puts $f "var current = 0;"
    puts $f "var prefix = \"$prefix\";"
    puts $f "// \]\]>"
    puts $f "</script>"
    puts $f "<title>Scid</title>"
    puts $f "<meta content=\"Scid\" name=\"author\" />"
    puts $f "</head>"
    puts $f "<body onload=\"doinit()\" onkeydown=\"handlekey(event)\">"
    puts $f "<table>"
    puts $f "<tr>"
    puts $f "<td id=\"diagram\" style=\"width: 380px\"><!-- diagram goes here --></td>"
    puts $f "<td rowspan=\"2\" id=\"moves\"><!-- moves go here -->"
    # game header
    puts $f "<span class=\"hPlayers\">$this_players</span>"
    puts $f "<span class=\"hEvent\"><br />$event</span>"
    puts $f "<span class=\"hAnnot\"><br />\[$eco\]</span>"
    puts $f "<span class=\"hEvent\"><br />\[$date\]</span>"
    puts $f "<p>"
    # link moves
    set prevdepth 0
    set prevvarnumber 0
    for {set i 1} {$i<[llength $dt]} {incr i} {
      array set elt [lindex $dt $i]
      if {$elt(depth) == 0} {
        set class "V0"
      } elseif {$elt(depth) == 1} {
        set class "V1"
      } else {
        set class "V2"
      }
      if {$prevdepth != $elt(depth) || $prevvarnumber != $elt(var)} {
        if {$prevdepth != 0} { puts $f "\]" }
        puts $f "<br>"
        for {set j 0} {$j<$elt(depth)} {incr j} {puts $f "&nbsp; &nbsp; "}
        if {$elt(depth) != 0} { puts $f "\[" }
      }
      set prevdepth $elt(depth)
      set prevvarnumber $elt(var)
      # id = "mv1" not "id=1" now
      puts $f "<a href=\"javascript:gotoMove($elt(idx))\" id=\"mv$elt(idx)\" class=\"$class\">$elt(move)</a>$elt(nag)$elt(comment)"
      if {$elt(diag)} {
        insertMiniDiag $elt(fen) $f
      }
    }
    if {$prevdepth != 0} {puts $f "\]"}
    
    # <a href="javascript:gotoMove(1)" id="mv1" class="V0">1.Rd8</a>
    puts $f "<br /><span class=\"VH\">$result</span>"
    puts $f "</p>"
    puts $f "<a href=\"http://scid.sourceforge.net/\" style=\"font-size: 0.8em\">Created with Scid</a>"
    puts $f "</td>"
    puts $f "</tr>"
    puts $f "<tr>"
    puts $f "<td id=\"nav\" style=\"text-align: center\"><!-- navigation goes here -->"
    puts $f "<form action=\"#\">"
    puts $f "<p>"
    puts $f "<input type='button' value=' o ' onclick='rotate()' /> <input type='button' value=' |&lt; ' onclick='jump(0)' /> <input type='button' value=' &lt; ' onclick='moveForward(0)' /> <input type='button' value=' &gt; ' onclick='moveForward(1)' /> <input type='button' value=' &gt;| ' onclick='jump(1)' /> "
    puts $f "</p><p>"
    puts $f "<select name=\"gameselect\" id=\"gameselect\" size=\"1\" onchange=\"gotogame()\">"
    set i 1
    foreach l $players {
      # next line needs a function to change "<option>" to <option selected="selected"> when it is the corresponding game
      # for example if it is game1 or i==1 than the modification will occur
      if { $game == $i } {
        puts $f "<option  selected=\"selected\">$i. $l</option>"
      } else  {
        puts $f "<option>$i. $l</option>"
      }
      incr i
    }
    puts $f "</select>"
    puts $f "</p<p>"
    puts $f "<input type=\"button\" value=\"&lt;--\" onclick=\"gotoprevgame()\" /> &nbsp; <input type=\"button\" value=\"--&gt;\" onclick=\"gotonextgame()\" />"
    puts $f "</p><p>"
    puts $f "<a href=\"${prefix}.pgn\">${prefix}.pgn</a>"
    puts $f "</p>"
    puts $f "</form>"
    puts $f "</td></tr></table>"
    puts $f "</body>"
    puts $f "</html>"
    close $f
  }
  ################################################################################
  proc toHtml2 { dt game dirtarget prefix {players ""} {event ""} {eco "ECO"} {result "*"} {date ""} } {
    set f [open "[file join $dirtarget $prefix]_${game}.html" w]
    # header
    puts $f "<html>"
    puts $f "<head>"
    puts $f "<meta content=\"text/html; charset=ISO-8859-1\" http-equiv=\"content-type\">"
    puts $f "<title>Scid</title>"
    puts $f "<meta content=\"Scid\" name=\"author\">"
    puts $f "<link rel=\"stylesheet\" type=\"text/css\" href=\"scid.css\">"
    puts $f "<script SRC=\"scid.js\" LANGUAGE=\"JavaScript1.1\"></script>"
    puts $f "</head>"
    puts $f "<body ONLOAD=\"doinit()\" TEXT=\"#000000\" LINK=\"#000000\" VLINK=\"#000000\" ALINK=\"#000000\" BGCOLOR=\"#ECECEC\" onKeyDown=\"handlekey(event)\">"
    puts $f "<p>"
    puts $f "<font COLOR=\"#000000\">"
    puts $f "<script LANGUAGE=\"JavaScript1.1\">"
    puts $f "<!--"
    puts $f "movesArray = new Array("
    for {set i 0} {$i<[llength $dt]} {incr i} {
      array set elt [lindex $dt $i]
      puts -nonewline $f "\"$elt(fen) $elt(prev) $elt(next)\""
      if {$i < [expr [llength $dt] -1]} { puts $f "," }
    }
    puts $f ");"
    puts $f "var current = 0;"
    puts $f "var prefix = \"$prefix\";"
    puts $f "//-->"
    puts $f "</script>"
    puts $f "<NOSCRIPT>You need to have Javascript enabled in your browser to see this page.</NOSCRIPT>"
    # game header
    puts $f "<span class=\"hPlayers\">$players</span>"
    puts $f "<span class=\"hEvent\"><br>$event</span>"
    puts $f "<span class=\"hAnnot\"><br>\[$eco\]</span>"
    puts $f "<span class=\"hEvent\"><br>\[$date\]</span>"
    puts $f "<br>"
    
    # link moves
    set prevdepth 0
    set prevvarnumber 0
    for {set i 1} {$i<[llength $dt]} {incr i} {
      array set elt [lindex $dt $i]
      if {$elt(depth) == 0} {
        set class "V0"
      } elseif {$elt(depth) == 1} {
        set class "V1"
      } else  {
        set class "V2"
      }
      if {$prevdepth != $elt(depth) || $prevvarnumber != $elt(var)} {
        if {$prevdepth != 0} { puts $f "\]" }
        puts $f "<br>"
        for {set j 0} {$j<$elt(depth)} {incr j} {puts $f "&nbsp; &nbsp; "}
        if {$elt(depth) != 0} { puts $f "\[" }
      }
      set prevdepth $elt(depth)
      set prevvarnumber $elt(var)
      puts $f "<a href=\"javascript:gotoMove($elt(idx))\" ID=\"$elt(idx)\" class=\"$class\">$elt(move)</a>$elt(nag) $elt(comment)"
      if {$elt(diag)} {
        insertMiniDiag $elt(fen) $f
      }
    }
    if {$prevdepth != 0} {puts $f "\]"}
    
    # <a href="javascript:gotoMove(1)" ID="1" class="V0">1.Rd8</a>
    puts $f "<br><class=\"VH\">$result"
    puts $f "</font>"
    puts $f "</p>"
    puts $f "<font size=-2><a href=\"http://scid.sourceforge.net/\" target=_blank>Created with Scid</a></font>"
    puts $f "</body>"
    puts $f "</html>"
    close $f
  }
  ################################################################################
  proc colorSq {sq} {
    if { [expr $sq % 2] == 1 && [expr int($sq / 8) %2 ] == 0 || [expr $sq % 2] == 0 && [expr int($sq / 8) %2 ] == 1 } {
      return $::html::black_square
    } else {
      return $::html::white_square
    }
  }
  ################################################################################
  proc piece2gif {piece} {
    if {$piece == "K"} { return "wk" }
    if {$piece == "k"} { return "bk" }
    if {$piece == "Q"} { return "wq" }
    if {$piece == "q"} { return "bq" }
    if {$piece == "R"} { return "wr" }
    if {$piece == "r"} { return "br" }
    if {$piece == "B"} { return "wb" }
    if {$piece == "b"} { return "bb" }
    if {$piece == "N"} { return "wn" }
    if {$piece == "n"} { return "bn" }
    if {$piece == "P"} { return "wp" }
    if {$piece == "p"} { return "bp" }
    if {$piece == " "} { return "sq" }
  }
  ################################################################################
  proc insertMiniDiag {fen f} {
    
    set square 0
    set space " "
    puts $f "<table Border=0 CellSpacing=0 CellPadding=0><tr>"
    
    for {set i 0} {$i < [string length $fen]} {incr i} {
      set l [string range $fen $i $i ]
      set res [scan $l "%d" c]
      if {$res == 1} {
        if  { $c >= 1 && $c <= 8 } {
          for { set j 0} {$j < $c} {incr j} {
            puts $f "<td bgcolor= [colorSq $square ] ><img border=0 src=bitmaps/mini/[piece2gif $space].gif </td>"
            incr square
          }
        }
      } elseif {$l == "/"}  {
        puts $f "</tr><tr>"
      } else  {
        puts $f "<td bgcolor= [colorSq $square ] ><img border=0 src=bitmaps/mini/[piece2gif $l].gif </td>"
        incr square
      }
    }
    
    puts $f "</tr></table>"
    puts $f "</body></html>"
  }
  
  ################################################################################
  # generate nav.html
  # proc navhtml { dirtarget players prefix } {
  # set f [open "[file join $dirtarget ${prefix}_nav.html]" w]
  # puts $f "<body BGCOLOR=\"#d7d7d7\">"
  # puts $f "<table ALIGN='CENTER'>"
  # puts $f "<td VALIGN='TOP'>"
  # puts $f "<center>"
  # puts $f "<form NAME='formgames'>"
  # puts $f "<input TYPE='button' VALUE=' o ' ONCLICK='parent.moves.rotate()'>"
  # puts $f "<input TYPE='button' VALUE=' |&lt; ' ONCLICK='parent.moves.jump(0)'>"
  # puts $f "<input TYPE='button' VALUE=' &lt; '  ONCLICK='parent.moves.moveForward(0)'>"
  # puts $f "<input TYPE='button' VALUE=' &gt; '  ONCLICK='parent.moves.moveForward(1)'>"
  # puts $f "<input TYPE='button' VALUE=' &gt;| ' ONCLICK='parent.moves.jump(1)'>"
  # puts $f "</center>"
  # puts $f "</td>"
  # puts $f "</table>"
  #
  # puts $f "<center>"
  # puts $f "<select NAME=\"gameselect\" ID=\"gameselect\" SIZE=1 WIDTH=244 ONCHANGE='parent.moves.gotogame()'>"
  # set i 1
  # foreach l $players {
  # puts $f "<option>$i. $l"
  # incr i
  # }
  # puts $f "</select>"
  # puts $f "<nobr>"
  # puts $f "<input TYPE=\"button\" VALUE=\"&lt;--\" ONCLICK=\"parent.moves.gotoprevgame()\">"
  # puts $f "<input TYPE=\"button\" VALUE=\"--&gt;\" ONCLICK=\"parent.moves.gotonextgame()\">"
  # puts $f "</nobr>"
  # puts $f "</center>"
  # puts $f "</form>"
  # puts $f "<br><CENTER><a href=\"${prefix}.pgn\">${prefix}.pgn</a></CENTER>"
  # puts $f "</body>"
  #
  # close $f
  # }
  ################################################################################
  # fill data with { idx FEN prev next move nag comment depth }
  proc fillData {} {
    sc_info preMoveCmd {}
    set ::html::data {}
    set ::html::idx -1
    sc_move start
    parseGame
    sc_info preMoveCmd preMoveCommand
  }
  
  ################################################################################
  proc parseGame { {prev -2} {dots 0} } {
    global ::html::data ::html::idx
    
    while {1} {
      recordElt $prev $dots
      set prev -2
      set dots 0
      
      # handle variants
      if {[sc_var count]>0} {
        if { ![sc_pos isAt vend]} {
          sc_move forward
          recordElt
          set lastIdx $idx
          sc_move back
        }
        set dots 1
        for {set v 0} {$v<[sc_var count]} {incr v} {
          sc_var enter $v
          parseGame $idx $dots
          sc_var exit
        }
        if { ![sc_pos isAt vend] } { sc_move forward }
        #update the "next" token
        array set elt [lindex $data $lastIdx]
        set elt(next) [expr $idx + 1]
        lset data $lastIdx [array get elt]
        #update the "previous" token
        set prev $lastIdx
      }
      
      if {[sc_pos isAt vend]} { break }
      sc_move forward
    }
  }
  ################################################################################
  proc recordElt { {prev -2} {dots 0} } {
    global ::html::data ::html::idx
    
    array set elt {}
    
    incr idx
    set elt(idx) $idx
    set elt(fen) [lindex [split [sc_pos fen]] 0]
    if {$prev != -2} {
      set elt(prev) $prev
    } else  {
      set elt(prev) [expr $idx-1]
    }
    
    set nag [sc_pos getNags]
    if {$nag == "0"} { set nag "" }
    if {[string match "*D *" $nag] || [string match "*# *" $nag]} {
      set elt(diag) 1
    } else  {
      set elt(diag) 0
    }
    set nag [regsub -all "D " $nag "" ]
    set nag [regsub -all "# " $nag "" ]
    set elt(nag) $nag
    set comment [sc_pos getComment]
    set comment [regsub -all "\[\x5B\]%draw (.)+\[\x5D\]" $comment ""]
    set elt(comment) $comment
    set elt(depth) [sc_var level]
    set elt(var) [sc_var number]
    if {![sc_pos isAt vend]} {
      set elt(next) [expr $idx +1 ]
    } else  {
      set elt(next) -1
    }
    
    set m [sc_game info previousMove]
    set mn [sc_pos moveNumber]
    
    if {[sc_pos side] == "black"} {
      set elt(move) "$mn.$m"
    } else {
      if {$dots} {
        set elt(move) "[expr $mn -1]. ... $m"
      } else  {
        set elt(move) $m
      }
    }
    
    lappend ::html::data [array get elt]
    
  }
  
  ################################################################################
  # proc writeIndex {fn prefix} {
  # set f [open $fn w]
  # puts $f "<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">"
  # puts $f "<html>"
  # puts $f "<head>"
  # puts $f "<meta content=\"text/html; charset=ISO-8859-1\" http-equiv=\"content-type\">"
  # puts $f "<title>Scid</title>"
  # puts $f "<meta content=\"Scid\" name=\"author\">"
  # puts $f "</head>"
  # puts $f "<frameset BORDER=\"0\" FRAMEBORDER=\"0\" FRAMESPACING=\"0\" COLS=\"380,*\">"
  # puts $f "<frameset BORDER=\"0\" FRAMEBORDER=\"0\" FRAMESPACING=\"0\" ROWS=\"380,*\">"
  # puts $f "<frame NAME=\"diagram\" SCROLLING=\"Auto\">"
  # puts $f "<frame NAME=\"nav\" SRC=\"${prefix}_nav.html\" SCROLLING=\"Auto\">"
  # puts $f "</frameset>"
  # puts $f "<frame NAME=\"moves\" SRC=\"${prefix}_1.html\" SCROLLING=\"Auto\">"
  # puts $f "</frameset>"
  # puts $f "</html>"
  # close $f
  # }
  ################################################################################
  proc exportPGN { fName selection } {
    if {$selection == "filter"} {
      progressWindow "Scid" "Exporting games..." $::tr(Cancel) "sc_progressBar"
    }
    busyCursor .
    sc_base export $selection "PGN" $fName -append 0 -starttext "" -endtext "" -comments 1 -variations 1 \
        -space 1 -symbols 1 -indentC 0 -indentV 0 -column 0 -noMarkCodes 1 -convertNullMoves 1
    unbusyCursor .
    if {$selection == "filter"} {
      closeProgressWindow
    }
  }
  
}
################################################################################
#
################################################################################

# end of misc.tcl
