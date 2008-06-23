### ScidPocket.
### Copyright (C) 2008  Pascal Georges
#
################################################################################
#                         N O V A G
################################################################################
namespace eval novag {
  
  set connected 0
  set fd 0
  set waitBetweenMessages 0
  set consoleList {}
  set setupCmd ""
  set synchroPending 0
  set flippedBoard 0
}
################################################################################
proc ::novag::connect {} {
  if {$::novag::connected} {
    
    if { [catch {set ::novag::fd [open $::options(novag_port) RDWR]} ] } {
      tk_messageBox -title "Novag Citrine" -type ok -icon error -message "Connection failed"
      set ::novag::connected 0
      return
    }
    
    fconfigure $::novag::fd -buffering line -blocking 0 -translation auto -mode 57600,n,8,1
    fileevent $::novag::fd readable ::novag::readchan
    set ::novag::consoleList {}
    # by default start in referee mode
    wait 200
    ::novag::referee
  } else {
    close $::novag::fd
  }
}
################################################################################
proc ::novag::configure {} {
  set w .serialConfig
  if { [winfo exists $w]} { return }
  toplevel $w
  wm title $w "Set COM port"
  label $w.l -text "COM7: , COM8 , ..."
  entry $w.e -width 15 -textvariable ::options(novag_port)
  button $w.bOk -text OK -command "destroy $w"
  pack $w.l $w.e $w.bOk
}
################################################################################
proc ::novag::showConsole {} {
  set w .novagconsole
  if {[winfo exists $w]} { focus $w ; return }
  toplevel $w
  
  ::ui::setFullSize $w 0
  
  frame $w.fcmd
  entry $w.fcmd.cmd -width 25
  button $w.fcmd.send -text Send -command {
    ::novag::writechan [.novagconsole.fcmd.cmd get]
    .novagconsole.fcmd.cmd delete 0 end
  }
  bind $w.fcmd.cmd <Return> {.novagconsole.fcmd.send invoke}
  pack $w.fcmd.cmd $w.fcmd.send -side left -fill x
  pack $w.fcmd
  focus $w.fcmd.cmd
  
  frame $w.top
  pack $w.top -fill both -expand 1
  frame $w.bottom
  pack $w.bottom
  
  ttk::scrollbar $w.top.ysc -command { .novagconsole.top.console yview }
  text $w.top.console -height 10 -width 40 -wrap word -yscrollcommand "$w.top.ysc set"
  pack $w.top.ysc -side left -fill y -side right
  pack $w.top.console -side left -fill both -expand 1 -side right
  
  button $w.bottom.close -text Close -command "destroy $w"
  pack $w.bottom.close -fill x
  foreach line $::novag::consoleList {
    $w.top.console insert end "$line\n"
  }
  
  update idletasks
  $w.top.console yview moveto 1
}
##########################################################
proc ::novag::newGame {} {
  if {! $::novag::connected} {return}
  writechan "N"
  wait 100
  ::novag::referee
}
##########################################################
proc ::novag::addMove {san} {
  # if promotion add "/"
  if {[string length $san] == 5} {
    set san "[string range $san 0 3]/[string range $san 4 end]"
  }
  
  ::novag::writechan "M $san"
  if { $::options(novag_sendmovetwice) } {
    if { [ string first "x" [sc_game info previousMove] ] != -1 } {
      wait 2000
    } else {
      wait 1000
    }
    ::novag::writechan "M $san"
  }
}
################################################################################
proc ::novag::checkBoardSync {} {
  if { ! $::novag::connected } { return }
  set novagfen [::novag::getFen]
  set fen [sc_pos fen]
  set fen "[lindex $fen 0] [lindex $fen 1]"
  
  if { $novagfen != $fen } {
    set lret [::novag::fenDiff $fen $novagfen ]
    if {[llength $lret] > 6} {
      set msg "$fen\n$novagfen"
    } else {
      set msg "\tScid\tNovag\n"
      foreach l $lret {
        append msg "[lindex $l 0]\t[lindex $l 1]\t[lindex $l 2]\n"
      }
    }
    
    tk_messageBox -title "Novag Citrine" -type ok -icon warning -message "Out of sync\n$msg"
    return 0
  }
  return 1
}
################################################################################
proc ::novag::fenDiff { fen1 fen2 } {
  
  set lcol { a b c d e f g h }
  set row 8
  set lret {}
  
  foreach e1 [split $fen1 "/" ] e2 [ split $fen2 "/" ] {
    
    if {$e1 != $e2 } {
      
      # remplace les chiffres par autant de 0
      set e1 [string map { 1 0 2 00 3 000 4 0000 5 00000 6 000000 7 0000000 8 00000000 } $e1]
      set e2 [string map { 1 0 2 00 3 000 4 0000 5 00000 6 000000 7 0000000 8 00000000 } $e2]
      for {set i 0} { $i < 8 } { incr i } {
        set c1 [string index $e1 $i]
        set c2 [string index $e2 $i]
        if {$c1 != $c2} {
          if {$c1 == "0"} {
            set c1 "<>"
          } else {
            if {[string is lower $c1]} { set c1 "b$c1" } else {set c1 "W$c1"}
          }
          if {$c2 == "0"} {
            set c2 "<>"
          } else {
            if {[string is lower $c2]} { set c2 "b$c2" } else {set c2 "W$c2"}
          }
          lappend lret "[lindex $lcol $i]$row $c1 $c2"
        }
      }
    }
    incr row -1
  }
  return $lret
  
}
################################################################################
proc ::novag::menuCheckBoardSync {} {
  if { [::novag::checkBoardSync] } {
    tk_messageBox -title "Novag Citrine" -type ok -icon info -message "Synchronization OK"
  }
}
################################################################################
# try to sync Citrine when it looks locked
################################################################################
# Perte de synchro :
#
#   1. ->Déconnecter
#   2. Mettre pièces en position de départ
#   3. ->Connecter
#   4. ->Setup
#   5. Mettre la position en place
#
# Cas de figure :
# 1. setup
# 2. Mettre en place pièces
# 3. setup
#
# Etapes 1 et 3 facultatives puisque normalement New game demande confirmation
################################################################################
proc ::novag::synchro {} {
  
  if { ! $::novag::connected } { return }
  
  if {[winfo exists .novagsynchro]} {
    focus .novagsynchro
    return
  }
  
  set w .novagsynchro
  toplevel $w
  wm title $w "Scid: Sync Novag"
  
  set ::novag::synchroPending 1
  
  label $w.inst1 -text [::msgcat::mc "In order to unlock Citrine,\nput pieces at start position"] -fg MidnightBlue
  
  button $w.cancel -text [::msgcat::mc "Close" ] -command {
    set ::novag::synchroPending 0
    # it seems that position must be resent
    ::novag::setup
    destroy .novagsynchro
  }
  pack $w.inst1 $w.cancel
  
  bind $w <Destroy> { set ::novag::synchroPending 0 }
  wm geometry $w +50+100
  
}
################################################################################
# send to Novag the current board
proc ::novag::setup {} {
  
  set cmd "pc"
  set board [sc_pos board]
  
  for {set i 0} {$i<64} {incr i} {
    set c [string index $board $i]
    if { $c != "." && [string is upper $c]} {
      append cmd "[string tolower $c][::board::san $i]"
    }
  }
  # scan black pieces
  append cmd "b"
  for {set i 0} {$i<64} {incr i} {
    set c [string index $board $i]
    if { $c != "." && [string is lower $c]} {
      append cmd "[string tolower $c][::board::san $i]"
    }
  }
  
  # set color
  if {[string index $board 65] == "w"} {
    append cmd "+"
  } else {
    append cmd "-"
  }
  writechan $cmd
  set ::novag::setupCmd $cmd
  set ::novag::waitForSetupOk 1
  ::vwaitTimed ::novag::waitForSetupOk 1000 nowarnuser
  if { $::novag::waitForSetupOk } {
    tk_messageBox -type ok -icon error -parent . -title "Setup" -message "Setup failed after timeout\nBoard locked !?"
  }
}
################################################################################
# returns the position part of fen and w or b
proc ::novag::getFen {} {
  writechan "P"
  set ::novag::fen ""
  vwaitTimed ::novag::fen 2000
  return $::novag::fen
}
################################################################################
proc ::novag::writechan {line} {
  # puts ">$line"
  set line "$line\r\n"
  puts -nonewline $::novag::fd $line
}
################################################################################
proc ::novag::readchan {} {
  global ::novag::fd
  set l [gets $fd]
  if { $l == "" } { return }
  
  # puts "<$l"
  
  updateConsole $l
  
  if {[string match -nocase "New Game*" $l]} {
    if { $::novag::synchroPending } {
      .novagsynchro.inst1 configure -text [::msgcat::mc "Set pieces back to the position\nand press button when finished"] -fg SeaGreen
      
      # the board should be ok, send it the position
      ::novag::setup
      wait 200
      ::novag::referee
      return
    }
    ::game::new
    ::board::updateBoard -pgn -nolastmove
    # new game resets board flip
    if {$::novag::flippedBoard} {
      wait 100
      writechan "F"
    }
    wait 100
    ::novag::referee
    return
  }
  # move
  if {[lindex $l 0] == "M"} {
    
    if {[sc_pos side] == "white" && [string index [lindex $l 1] end ] == ","} {  return }
    if {[sc_pos side] == "black" && [string index [lindex $l 1] end ] != ","} {  return }
    
    set m [lindex $l 2]
    
    if { $m == "O-O" || $m == "O-O-O"} {
      if { [ catch { sc_move addSan $m } err ] } {
        tk_messageBox -type ok -icon error -parent . -title "Novag" -message "sc_move addSan $m\n$err"
        return
      }
    } else {
      set m [string map { "-" "" "/" "" "x" "" } $m ]
      if { [ catch { sc_move addUCI $m } err ] } {
        tk_messageBox -type ok -icon error -parent . -title "Novag" -message "sc_move addUCI $m\n$err"
        return
      }
    }
    
    if { $::fics::playing == 1} {
      ::fics::writechan [ sc_game info previousMoveNT ]
    }
    
    ::board::updateBoard -pgn
    # ::novag::checkBoardSync
    return
  }
  
  # takeback
  if {[lindex $l 0] == "T"} {
    sc_move back
    ::board::updateBoard -pgn
    return
  }
  
  # position
  if {$l == ".  aa bb cc dd ee ff gg hh"} {
    set f ""
    for {set i 8} { $i > 0} {incr i -1} {
      set l [gets $fd]
      if {$l == ""} {
        after 100
        set l [gets $fd]
      }
      updateConsole $l
      if { [string range $l 0 1] != ".$i" || [string range $l end end] != "$i"} {
      }
      set f "$f[fenline $l]"
      if {$i != 1} {
        set f "$f/"
      } else {
        if {[string index $l end] == "+"} { set color "w" } else { set color "b" }
        set f "$f $color"
      }
    }
    set l [gets $fd] ;# last ".  aa bb cc dd ee ff gg hh"
    
    set ::novag::fen $f
  }
  
  # setup confirmation
  if {[string match "pc*" $l]} {
    if { $::novag::synchroPending } {
      if { $l == $::novag::setupCmd } {
        .novagsynchro.inst1 configure -fg SeaGreen
      } else {
        .novagsynchro.inst1 configure -fg red
      }
      set ::novag::waitForSetupOk 0
      return
    }
    if { $l == $::novag::setupCmd } {
      tk_messageBox -type ok -icon info -parent . -title "Setup" -message "Setup successfull"
    } else {
      tk_messageBox -type ok -icon error -parent . -title "Setup" -message "Setup failed"
    }
    set ::novag::waitForSetupOk 0
  }
}
################################################################################
proc ::novag::fenline {l} {
  set s ""
  set empty 0
  for {set i 3} { $i <= 24} {incr i 3} {
    set elt [string range $l $i [expr $i +1]]
    if {$elt == "  " || $elt == "::"} {
      incr empty
    } else {
      if {$empty != 0} {
        set s "$s$empty"
        set empty 0
      }
      set s "$s[string index $elt 1]"
    }
  }
  if {$empty != 0} {
    set s "$s$empty"
  }
  return $s
}
################################################################################
proc ::novag::updateConsole {line} {
  lappend ::novag::consoleList $line
  if {[winfo exists .novagconsole]} {
    set t .novagconsole.top.console
    $t insert end "$line\n"
    $t yview moveto 1
  }
}
##########################################################
proc ::novag::wait {ms} {
  after $ms {set ::novag::waitBetweenMessages 1}
  vwait ::novag::waitBetweenMessages
}
##########################################################
proc ::novag::referee {} {
  if { $::options(novag_refereeMode) } {
    ::novag::writechan "U ON"
  } else  {
    ::novag::writechan "U OFF"
  }
}
