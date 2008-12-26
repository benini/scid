### ScidPocket.
### Copyright (C) 2007  Pascal Georges
################################################################################
#
################################################################################

namespace eval fics {
  set port 5000
  set login ""
  set password ""
  set sockchan 0
  set server "freechess.org"
  set seeklist {}
  set observedGame -1
  set playing 0
  set waitForRating ""
  set consoleList {}
  set connected 0
  variable logged 0
  variable isGuestLogin 0
  
  ################################################################################
  #
  ################################################################################
  proc config {} {
    set w ".ficsConfig"
    
    if {[winfo exists $w]} {
      focus $w
      return
    }
    
    toplevel $w
    wm title $w "ConfigureFics"
    label $w.lLogin -text [::msgcat::mc "Login:"]
    entry $w.login -width 20 -textvariable ::options(fics_login)
    label $w.lPwd -text [::msgcat::mc "Password:"]
    entry $w.passwd -width 20 -textvariable ::options(fics_password)
    button $w.connect -text [::msgcat::mc "Connect"] -command {
      ::fics::connect [.ficsConfig.login get] [.ficsConfig.passwd get]
      destroy .ficsConfig
    }
    button $w.guest -text [::msgcat::mc "Login as guest"] -command {
      ::fics::connect "guest" ""
      destroy .ficsConfig
    }
    button $w.cancel -text [::msgcat::mc "Cancel"] -command { destroy .ficsConfig }
    
    grid $w.lLogin -column 0 -row 0 -sticky ew
    grid $w.login -column 1 -row 0 -sticky ew
    grid $w.lPwd -column 0 -row 1 -sticky ew
    grid $w.passwd -column 1 -row 1 -sticky ew
    grid $w.guest -column 0 -row 2 -columnspan 2 -sticky ew
    grid $w.connect -column 0 -row 3 -sticky ew
    grid $w.cancel -column 1 -row 3 -sticky ew
    
  }
  ################################################################################
  #
  ################################################################################
  proc connect {login passwd} {
    global ::fics::sockchan
    
    set isGuestLogin [string match -nocase "guest" $login]
    
    set ::options(fics_login) $login
    set ::options(fics_password) $passwd
    set ::fics::login $login
    
    set ::options(novag_refereeMode) 1
    
    if { [catch { set sockchan [socket $::fics::server $::options(fics_port)] } ] } {
      tk_messageBox -title "Error" -icon error -type ok \
          -message "Network error\nCan't connect to $::fics::server $::options(fics_port)\nTrying other port"
      # try the other port (23 or 5000)
      if { $::options(fics_port) == 5000 } {
        set port 23
      } else {
        set port 5000
      }
      if { [catch { set sockchan [socket $::fics::server $port] } ] } {
        tk_messageBox -title "Error" -icon error -type ok -message "Network error\nCan't connect to $::fics::server $port"
        set ::fics::connected 0
        return
      }
      
    }
    
    chan configure $sockchan -blocking 0 -buffering line -translation auto ;#-encoding iso8859-1 -translation crlf
    chan event $sockchan readable ::fics::readchan
    
    # clock 1 is white
    set ::options(game_timeMode) "timebonus"
    ::gameclock::new .fTop.fr.fclocks 2 1
    ::gameclock::new .fTop.fr.fclocks 1 1
    ::gameclock::setColor 1 white
    ::gameclock::setColor 2 black
    
  }
  ################################################################################
  #
  ################################################################################
  proc setFormula {} {
    set w .ficsformula
    if {[winfo exists $w]} { focus $w ; return }
    toplevel $w
    entry $w.formula -width 25 -textvariable ::options(fics_formula)
    button $w.save -text Save -command { ::fics::writechan "set formula $::options(fics_formula)" ; destroy .ficsformula }
    button $w.cancel -text Cancel -command { destroy .ficsformula }
    
    grid $w.formula -column 0 -row 0 -columnspan 2 -sticky ew
    grid $w.save  -column 0 -row 1 -sticky ew
    grid $w.cancel  -column 1 -row 1 -sticky ew
  }
  ################################################################################
  #
  ################################################################################
  proc showConsole {} {
    set w .ficsconsole
    if {[winfo exists $w]} { focus $w ; return }
    toplevel $w
    
    ::ui::setFullSize $w 0
    
    frame $w.fcmd
    entry $w.fcmd.cmd -width 25
    button $w.fcmd.send -text Send -command {
      ::fics::writechan [.ficsconsole.fcmd.cmd get]
      .ficsconsole.fcmd.cmd delete 0 end
    }
    bind $w.fcmd.cmd <Return> {.ficsconsole.fcmd.send invoke}
    pack $w.fcmd.cmd $w.fcmd.send -side left -fill x
    pack $w.fcmd
    focus $w.fcmd.cmd
    
    frame $w.top
    pack $w.top -fill both -expand 1
    frame $w.bottom
    pack $w.bottom
    
    ttk::scrollbar $w.top.ysc -command { .ficsconsole.top.console yview }
    text $w.top.console -height 10 -width 40 -wrap word -yscrollcommand "$w.top.ysc set"
    pack $w.top.ysc -side left -fill y -side right
    pack $w.top.console -side left -fill both -expand 1 -side right
    
    button $w.bottom.close -text Close -command "destroy $w"
    pack $w.bottom.close -fill x
    set lines ""
    foreach line $::fics::consoleList {
      append lines "$line\n"
    }
    $w.top.console insert end $lines
    
    update idletasks
    $w.top.console yview moveto 1
  }
  ################################################################################
  #
  ################################################################################
  proc findOpponent {} {
    set w .ficsfindopp
    if {[winfo exists $w]} {
      focus $w
      return
    }
    toplevel $w
    
    label $w.linit -text [::msgcat::mc "Initial time (min)"]
    spinbox $w.sbTime1 -background white -width 3 -textvariable ::options(fics_initTime) -from 0 -to 120 -increment 1 -validate all -vcmd { regexp {^[0-9]+$} %P }
    label $w.linc -text [::msgcat::mc "Increment (sec)"]
    spinbox $w.sbTime2 -background white -width 3 -textvariable ::options(fics_incTime) -from 0 -to 120 -increment 1 -validate all -vcmd { regexp {^[0-9]+$} %P }
    grid $w.linit -column 0 -row 0 -sticky ew
    grid $w.sbTime1 -column 1 -row 0 -sticky ew
    grid $w.linc -column 0 -row 1 -sticky ew
    grid $w.sbTime2 -column 1 -row 1 -sticky ew
    
    checkbutton $w.cbrated -text [::msgcat::mc "Rated game"] -onvalue "rated" -offvalue "unrated" -variable ::options(fics_rated)
    grid $w.cbrated -column 0 -row 2 -columnspan 2 -sticky ew
    
    label $w.color -text [::msgcat::mc "Color"]
    grid $w.color -column 0 -row 3 -columnspan 3 -sticky ew
    radiobutton $w.rb1 -text [::msgcat::mc "Automatic"] -value "auto" -variable ::options(fics_color)
    radiobutton $w.rb2 -text [::msgcat::mc "White"] -value "white" -variable ::options(fics_color)
    radiobutton $w.rb3 -text [::msgcat::mc "Black"] -value "black" -variable ::options(fics_color)
    grid $w.rb1 -column 0 -row 4 -sticky ew
    grid $w.rb2 -column 1 -row 4 -sticky ew
    grid $w.rb3 -column 2 -row 4 -sticky ew
    
    checkbutton $w.cblimitrating -text [::msgcat::mc "Limit rating between"] -variable ::options(fics_limitrating)
    spinbox $w.sbrating1 -background white -width 4 -textvariable ::options(fics_rating1) -from 1000 -to 3000 -increment 50 -validate all -vcmd { regexp {^[0-9]+$} %P }
    spinbox $w.sbrating2 -background white -width 4 -textvariable ::options(fics_rating2) -from 1000 -to 3000 -increment 50 -validate all -vcmd { regexp {^[0-9]+$} %P }
    grid $w.cblimitrating -column 0 -row 5 -columnspan 2 -sticky ew
    grid $w.sbrating1 -column 0 -row 6 -sticky ew
    grid $w.sbrating2 -column 1 -row 6 -sticky ew
    
    checkbutton $w.cbmanual -text [::msgcat::mc "Confirm manually"] -onvalue "manual" -offvalue "auto" -variable ::options(fics_manual)
    grid $w.cbmanual -column 0 -row 7 -columnspan 2 -sticky ew
    checkbutton $w.cbformula -text [::msgcat::mc "Filter with formula"] -onvalue "formula" -offvalue "" -variable ::options(fics_useformula)
    grid $w.cbformula -column 0 -row 8 -columnspan 2 -sticky ew
    
    button $w.seek -text [::msgcat::mc "Issue seek"] -command {
      set range ""
      if {$::options(fics_limitrating) } {
        set range "$::options(fics_rating1)-$::options(fics_rating2)"
      }
      if { $::options(fics_color) == "auto" } {
        set fcolor ""
      } else {
        set fcolor $::options(fics_color)
      }
      set cmd "seek $::options(fics_initTime) $::options(fics_incTime) $::options(fics_rated) \
          $fcolor $::options(fics_manual) $::options(fics_useformula) $range"
      ::fics::writechan $cmd
      destroy .ficsfindopp
    }
    button $w.cancel -text [::msgcat::mc "Cancel"] -command "destroy $w"
    grid $w.seek -column 0 -row 9 -sticky ew
    grid $w.cancel -column 1 -row 9 -sticky ew
  }
  ################################################################################
  #
  ################################################################################
  proc readchan {} {
    # gets $::fics::sockchan line
    variable logged
    
    if {[eof $::fics::sockchan]} {
      tk_messageBox -title "FICS" -icon error -type ok -message "Network error"
      return
    }
    
    # switch from read to gets in case a read is done at the middle of a line
    if {! $logged} {
      set line [read $::fics::sockchan]
      foreach l [split $line "\n"] {
        readparse $l
      }
    } else  {
      set line [gets $::fics::sockchan]
      set line [string map {"\a" ""} $line]
      readparse $line
    }
    
  }
  ################################################################################
  #
  ################################################################################
  proc readparse {line} {
    variable logged
    variable isGuestLogin
    
    if {$line == "" || [string match "fics*" $line] } {return}
    
    if {[string match "login: " $line]} {
      writechan $::options(fics_login)
      if { $isGuestLogin} {
        set logged 1
      }
      return
    }
    if {[string match "password: " $line]} {
      writechan $::options(fics_password)
      set logged 1
      return
    }
    if {[string match "<sc>*" $line]} {
      set ::fics::seeklist {}
      refreshOffers
      return
    }
    if {[string match "<s>*" $line]} {
      parseSeek $line
      return
    }
    if {[string match "<sr>*" $line]} {
      removeSeek $line
      return
    }
    
    if {[string match "<12>*" $line]} {
      parseStyle12 $line
      return
    }
    
    updateConsole $line
    
    if {[string match "Creating: *" $line]} {
      sc_game new
      ::novag::newGame
      set white [lindex $line 1]
      set whiteElo [string map { "(" "" ")" "" } [lindex $line 2] ]
      set black [lindex $line 3]
      set blackElo [string map { "(" "" ")" "" } [lindex $line 4] ]
      
      sc_game tags set -white $white
      sc_game tags set -whiteElo $whiteElo
      sc_game tags set -black $black
      sc_game tags set -blackElo $blackElo
      
      sc_game tags set -event "Fics [lrange $line 5 end]"
      if {$::board::isFlipped} {
        if { [ string match -nocase $white $::fics::login ] } { ::board::toggleFlip }
      } else {
        if { [ string match -nocase $black $::fics::login ] } { ::board::toggleFlip }
      }
      ::sound::play alert
      ::board::updateBoard -pgn
      return
    }
    
    if {[string match "\{Game *" $line]} {
      set num [lindex [lindex $line 0] 1]
      set res [lindex $line end]
      if {$num == $::fics::observedGame} {
        if {[string match "1/2*" $res]} {
          ::sound::play draw
          tk_messageBox -title "Game result" -icon info -type ok -message "Draw"
        } else {
          ::sound::play checkmate
          tk_messageBox -title "Game result" -icon info -type ok -message "$res"
        }
        sc_game tags set -result $res
        ::board::updateBoard -pgn
        set ::fics::playing 0
        set ::fics::observedGame -1
        ::gameclock::stop 1
        ::gameclock::stop 2
      }
      return
    }
    
    if { [string match "You are now observing game*" $line] } {
      scan $line "You are now observing game %d." ::fics::observedGame
    }
    
    if {[string match "*Starting FICS session*" $line]} {
      # init commands
      writechan "iset seekremove 1"
      writechan "iset seekinfo 1"
      writechan "set seek 1"
      writechan "set silence 1"
      writechan "set chanoff 1"
      writechan "set cshout 0"
      writechan "style 12"
      writechan "iset nowrap 1"
      writechan "iset nohighlight 1"
      writechan "set formula $::options(fics_formula)"
      ::sound::play connect
      return
    }
    
    if { $::fics::waitForRating == "wait" } {
      if {[lindex $line 0] == "Standard"} {
        set ::fics::waitForRating [lindex $line 1]
        return
      }
    }
    
    if {[string match "Challenge:*" $line]} {
      ::sound::play alert
      set ans [tk_dialog .challenge "Challenge" $line "" 0 "accept" "decline"]
      if {$ans == 0} {
        writechan "accept"
      } else {
        writechan "decline"
      }
    }
    
    # abort request
    if {[string match "* would like to abort the game;*" $line]} {
      ::sound::play alert
      set ans [tk_messageBox -title "Abort" -icon question -type yesno -message "$line\nDo you accept ?" ]
      if {$ans == yes} {
        writechan "accept"
      } else {
        writechan "decline"
      }
    }
    
    # takeback
    if {[string match "* would like to take back *" $line]} {
      ::sound::play takeback
      set ans [tk_messageBox -title "Abort" -icon question -type yesno -message "$line\nDo you accept ?" ]
      if {$ans == yes} {
        writechan "accept"
      } else {
        writechan "decline"
      }
    }
    
    # draw
    if {[string match "*offers you a draw*" $line]} {
      ::sound::play alert
      set ans [tk_messageBox -title "Abort" -icon question -type yesno -message "$line\nDo you accept ?" ]
      if {$ans == yes} {
        writechan "accept"
      } else {
        writechan "decline"
      }
    }
    
    # adjourn
    if {[string match "*would like to adjourn the game*" $line]} {
      ::sound::play alert
      set ans [tk_messageBox -title "Abort" -icon question -type yesno -message "$line\nDo you accept ?" ]
      if {$ans == yes} {
        writechan "accept"
      } else {
        writechan "decline"
      }
    }
    
    # guest logging
    if {[string match "Logging you in as*" $line]} {
      set line [string map {"\"" "" ";" ""} $line ]
      set ::fics::login [lindex $line 4]
    }
    if {[string match "Press return to enter the server as*" $line]} {
      writechan "\n"
    }
  }
  ################################################################################
  #
  ################################################################################
  proc updateConsole {line} {
    lappend ::fics::consoleList $line
    if {[winfo exists .ficsconsole]} {
      set t .ficsconsole.top.console
      $t insert end "$line\n"
      $t yview moveto 1
    }
  }
  ################################################################################
  #
  ################################################################################
  proc removeSeek {line} {
    global ::fics::seeklist
    foreach l $line {
      if { $l == "<sr>" } {continue}
      for {set i 0} {$i < [llength $seeklist]} {incr i} {
        array set a [lindex $seeklist $i]
        if {$a(index) == $l} {
          set seeklist [lreplace $seeklist $i $i]
          break
        }
      }
    }
    refreshOffers
  }
  ################################################################################
  #
  ################################################################################
  proc parseStyle12 {line} {
    set color [lindex $line 9]
    set gameNumber [lindex $line 16]
    set white [lindex $line 17]
    set black [lindex $line 18]
    set relation [lindex $line 19]
    set initialTime [lindex $line 20]
    set increment [lindex $line 21]
    set whiteMaterial [lindex $line 22]
    set blackMaterial [lindex $line 23]
    set whiteRemainingTime  [lindex $line 24]
    set blackRemainingTime  [lindex $line 25]
    set moveNumber [lindex $line 26]
    set verbose_move [lindex $line 27]
    set moveTime [lindex $line 28]
    set moveSan [lindex $line 29]
    
    set ::fics::playing $relation
    set ::fics::observedGame $gameNumber
    
    ::gameclock::setdSec 1 [expr $whiteRemainingTime * 10]
    ::gameclock::setdSec 2 [expr $blackRemainingTime * 10]
    if {$color == "W"} {
      ::gameclock::start 1
      ::gameclock::stop 2
    } else {
      ::gameclock::start 2
      ::gameclock::stop 1
    }
    
    set fen ""
    for {set i 1} {$i <=8} { incr i} {
      set l [lindex $line $i]
      set count 0
      
      for { set col 0 } { $col < 8 } { incr col } {
        set c [string index $l $col]
        if { $c == "-"} {
          incr count
        } else {
          if {$count != 0} {
            set fen "$fen$count"
            set count 0
          }
          set fen "$fen$c"
        }
      }
      
      if {$count != 0} { set fen "$fen$count" }
      if {$i != 8} { set fen "$fen/" }
    }
    
    set fen "$fen [string tolower $color]"
    set f [lindex $line 10]
    
    # en passant
    if { $f == "-1" || $verbose_move == "none"} {
      set enpassant "-"
    } else {
      set enpassant "-"
      set conv "abcdefgh"
      set fl [string index $conv $f]
      if {$color == "W"} {
        if { [ string index [lindex $line 4] [expr $f - 1]] == "P" || [ string index [lindex $line 4] [expr $f + 1]] == "P" } {
          set enpassant "${fl}6"
        }
      } else {
        if { [ string index [lindex $line 5] [expr $f - 1]] == "p" || [ string index [lindex $line 5] [expr $f + 1]] == "p" } {
          set enpassant "${fl}3"
        }
      }
    }
    
    set castle ""
    if {[lindex $line 11] == "1"} {set castle "${castle}K"}
    if {[lindex $line 12] == "1"} {set castle "${castle}Q"}
    if {[lindex $line 13] == "1"} {set castle "${castle}k"}
    if {[lindex $line 14] == "1"} {set castle "${castle}q"}
    if {$castle == ""} {set castle "-"}
    
    set fen "$fen $castle $enpassant [lindex $line 15] $moveNumber"
    
    # try to play the move and check if fen corresponds. If not this means the position needs to be set up.
    if {$moveSan != "none"} {
      # if the move is an echo of the move previously entered with an external board, do nothing
      if { $::novag::connected && $relation == -1} {
        return
      }
      if { [catch { ::game::moveAdd $moveSan } err ] } {
        # tk_messageBox -title "FICS error" -icon error -type ok -message "FICS error\n$err"
      } else {
        # check that Scid has the same board as FICS
        if {$fen != [sc_pos fen]} {
          tk_messageBox -title "FICS error" -icon error -type ok -message "FICS move entered but\nfen different.\nNew game Creation"
        } else {
          ::board::updateBoard -pgn
          return
        }
      }
    }
    
    if {$fen != [sc_pos fen]} {
      sc_game new
      
      set ::fics::waitForRating "wait"
      writechan "finger $white /s"
      vwaitTimed ::fics::waitForRating 2000 "nowarn"
      if {$::fics::waitForRating == "wait"} { set ::fics::waitForRating "0" }
      sc_game tags set -white $white
      sc_game tags set -whiteElo $::fics::waitForRating
      
      set ::fics::waitForRating "wait"
      writechan "finger $black /s"
      vwaitTimed ::fics::waitForRating 2000 "nowarn"
      if {$::fics::waitForRating == "wait"} { set ::fics::waitForRating "0" }
      sc_game tags set -black $black
      sc_game tags set -blackElo $::fics::waitForRating
      
      set ::fics::waitForRating ""
      
      sc_game tags set -event "Fics game $gameNumber $initialTime/$increment"
      sc_game startBoard $fen
      ::board::updateBoard -pgn -nolastmove
    }
  }
  ################################################################################
  #
  ################################################################################
  proc parseSeek {line} {
    array set seekelt {}
    set seekelt(index) [lindex $line 1]
    foreach m [split $line] {
      if {[string match "w=*" $m]} { set seekelt(name_from) [string range $m 2 end] ; continue }
      if {[string match "ti=*" $m]} { set seekelt(titles) [string range $m 3 end] ; continue }
      if {[string match "rt=*" $m]} { set seekelt(rating) [string range $m 3 end] ; continue }
      if {[string match "t=*" $m]} { set seekelt(time) [string range $m 2 end] ; continue }
      if {[string match "i=*" $m]} { set seekelt(increment) [string range $m 2 end] ; continue }
      if {[string match "r=*" $m]} { set seekelt(rated) [string range $m 2 end] ; continue }
      if {[string match "tp=*" $m]} { set seekelt(type) [string range $m 3 end] ; continue }
      if {[string match "c=*" $m]} { set seekelt(color) [string range $m 2 end] ; continue }
      if {[string match "rr=*" $m]} { set seekelt(rating_range) [string range $m 3 end] ; continue }
      if {[string match "a=*" $m]} { set seekelt(automatic) [string range $m 2 end] ; continue }
      if {[string match "f=*" $m]} { set seekelt(formula_checked) [string range $m 2 end] ; continue }
    }
    lappend ::fics::seeklist [array get seekelt]
    refreshOffers
  }
  ################################################################################
  #
  ################################################################################
  proc refreshOffers {} {
    global ::fics::seeklist
    if {[winfo exists .ficsoffers]} {
      set ws .ficsoffers.sf.scrolled
      foreach c [winfo child $ws] {
        destroy $c
      }
      set count 0
      foreach l $seeklist {
        array set a $l
        button $ws.play$count -text "$a(time)/$a(increment) $a(rating) $a(rated)" -command "::fics::play $a(index)"
        pack $ws.play$count -fill x
        incr count
      }
    }
  }
  ################################################################################
  #
  ################################################################################
  proc showOffers {} {
    global ::fics::seeklist
    
    set w .ficsoffers
    
    if {[winfo exists .ficsoffers]} {
      focus .ficsoffers
      return
    }
    
    toplevel $w
    ::ui::setFullSize $w 0
    ::scrolledframe::scrolledframe $w.sf -yscrollcommand {.ficsoffers.vs set}  -fill both
    ttk::scrollbar $w.vs -command {.ficsoffers.sf yview}
    grid $w.sf -row 0 -column 0 -sticky nsew
    grid $w.vs -row 0 -column 1 -sticky ns
    grid rowconfigure $w 0 -weight 1
    grid columnconfigure $w 0 -weight 1
    
    refreshOffers
    
    button $w.close -text "Close" -command "destroy .ficsoffers"
    grid $w.close -row 1 -column 0 -columnspan 2 -sticky ew
  }
  ################################################################################
  #
  ################################################################################
  proc play { index } {
    writechan "play $index"
    # set ::fics::playing 1
    set ::fics::observedGame $index
  }
  ################################################################################
  #
  ################################################################################
  proc writechan {line} {
    if {$line == ""} { return }
    puts $::fics::sockchan $line
    updateConsole "->>$line"
  }
  
  ################################################################################
  #
  ################################################################################
  proc close {} {
    writechan "exit"
    set ::fics::playing 0
    set ::fics::observedGame -1
    set ::fics::consoleList {}
    ::close $::fics::sockchan
    ::gameclock::delete 1
    ::gameclock::delete 2
    ::sound::play disconnect
  }
}

###
### End of file: fics.tcl
###
