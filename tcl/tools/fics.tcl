###
### fics.tcl: part of Scid.
### Copyright (C) 2007  Pascal Georges
###

namespace eval fics {
  set server "freechess.org"
  set sockchan 0
  set seeklist {}
  set observedGame -1
  set playing 0
  set waitForRating ""
  set waitForMoves ""
  set silence 1
  set sought 0
  set soughtlist {}
  set width 300
  set height 300
  set off 20
  set graphon 0
  set timeseal_pid 0
  font create font_offers -family courier -size 12 -weight bold
  set history {}
  set history_pos 0
  set offers_minelo 1000
  set offers_maxelo 2500
  set offers_mintime 0
  set offers_maxtime 60
  variable logged 0
  variable isGuestLogin 0
  
  ################################################################################
  #
  ################################################################################
  proc config {} {
    variable logged
    global ::fics::sockChan
    set w ".ficsConfig"
    
    if {[winfo exists $w]} {
      focus $w
      return
    }
    
    if {[winfo exists .fics]} {
      focus .fics
      return
    }
    
    set logged 0
    
    toplevel $w
    ::setTitle $w "ConfigureFics"
    pack [ttk::frame $w.f]
    
    ttk::label $w.f.lLogin -text "login:"
    ttk::entry $w.f.login -width 20 -textvariable ::fics::login
    ttk::label $w.f.lPwd -text "password:"
    ttk::entry $w.f.passwd -width 20 -textvariable ::fics::password
    ttk::button $w.f.connect -text Connect -state disabled -command {
      ::fics::connect [.ficsConfig.f.login get] [.ficsConfig.f.passwd get]
      destroy .ficsConfig
    }
    ttk::button $w.f.guest -text "Login as guest" -state disabled -command {
      ::fics::connect "guest" ""
      destroy .ficsConfig
    }
    ttk::button $w.f.cancel -text Cancel -command { destroy .ficsConfig }
    
    set row 0
    grid $w.f.lLogin -column 0 -row $row
    grid $w.f.login -column 1 -row $row
    incr row
    grid $w.f.lPwd -column 0 -row $row
    grid $w.f.passwd -column 1 -row $row
    incr row
    
    # horizontal line
    ttk::frame $w.f.line$row -height 2 -borderwidth 2 -relief sunken
    grid $w.f.line$row -pady 5 -column 0 -row $row -columnspan 3 -sticky ew
    incr row
    
    # Time seal configuration
    ttk::checkbutton $w.f.cbts -text "Time seal" -variable ::fics::use_timeseal -onvalue 1 -offvalue 0
    grid $w.f.cbts -column 0 -row $row
    incr row
    ttk::entry $w.f.eExec -width 30 -textvariable ::fics::timeseal_exec
    ttk::button $w.f.bExec -text "..." -command { set ::fics::timeseal_exec [tk_getOpenFile] }
    grid $w.f.eExec -column 0 -row $row -columnspan 2
    grid $w.f.bExec -column 2 -row $row -sticky w
    incr row
    ttk::label $w.f.lFICS_port -text "Server port"
    ttk::entry $w.f.portserver -width 6 -textvariable ::fics::port_fics
    ttk::label $w.f.ltsport -text "Timeseal port"
    ttk::entry $w.f.portts -width 6 -textvariable ::fics::port_timeseal
    
    grid $w.f.lFICS_port -column 0 -row $row
    grid $w.f.portserver -column 1 -row $row
    incr row
    grid $w.f.ltsport -column 0 -row $row
    grid $w.f.portts -column 1 -row $row
    incr row
    
    # horizontal line
    ttk::separator $w.f.line$row -orient horizontal
    grid $w.f.line$row -pady 5 -column 0 -row $row -columnspan 3 -sticky ew
    incr row
    
    grid $w.f.connect -column 0 -row $row -sticky ew
    grid $w.f.guest  -column 1 -row $row -sticky ew
    grid $w.f.cancel -column 2 -row $row -sticky ew
    
    bind $w <Escape> "$w.f.cancel invoke"
    bind $w <F1> { helpWindow FICSLogin}
    
    update
    # Get IP adress of server (as Timeseal needs IP adress)
    # First handle the case of a network down
    if { [catch {set sockChan [socket -async $::fics::server $::fics::port_fics]} err]} {
      tk_messageBox -icon error -type ok -title "Unable to contact $::fics::server" -message $err -parent $w.f
      return
    }
    
    # Then the case of a proxy
    set timeOut 5
    set i 0
    while { $i <= $timeOut } {
      after 1000
      
      if { [catch {set peer [ fconfigure $sockChan -peername ]} err]} {
        if {$i == $timeOut} {
          tk_messageBox -icon error -type ok -title "Unable to contact $::fics::server" -message $err -parent $w.f
          return
        }
      } else  {
        break
      }
      incr i
    }
    
    set ::fics::server_ip [lindex $peer 0]
    ::close $sockChan
    
    $w.f.connect configure -state normal
    $w.f.guest configure -state normal
    
  }
  
  ################################################################################
  #
  ################################################################################
  proc connect { login passwd } {
    global ::fics::sockchan ::fics::seeklist ::fics::width ::fics::height ::fics::off
    variable isGuestLogin
    
    if {$login != ""} {
      set ::fics::reallogin $login
      set ::fics::password $passwd
    } else {
      return
    }
    
    set isGuestLogin [string match -nocase "guest" $login]
    
    # check timeseal configuration
    if {$::fics::use_timeseal} {
      if {![ file executable $::fics::timeseal_exec ]} {
        tk_messageBox -title "Error" -icon error -type ok -message "Timeseal exec error : $::fics::timeseal_exec"
        return
      }
    }
    
    set w .fics
    ::createToplevel $w
    ::setTitle $w "Free Internet Chess Server $::fics::reallogin"
    pack [ttk::panedwindow $w.f -orient vertical] -expand 1 -fill both
    
    ttk::frame $w.f.top
    ttk::frame $w.f.top.f1
    ttk::frame $w.f.top.f2
    pack $w.f.top.f1  -fill both -expand 1
    pack $w.f.top.f2 -fill x
    ttk::frame $w.f.bottom
    
    # pack $w.f.top -fill both -expand 1
    # pack $w.f.bottom
    $w.f add $w.f.top -weight 1
    $w.f add $w.f.bottom -weight 1
    
    ttk::frame $w.f.bottom.left
    ttk::frame $w.f.bottom.right
    ttk::frame $w.f.bottom.graph -relief sunken
    pack $w.f.bottom.left -side left
    pack $w.f.bottom.right -side left
    
    # graph
    canvas $w.f.bottom.graph.c -background white -width $width -height $height -relief solid
    pack $w.f.bottom.graph.c
    
    ttk::scrollbar $w.f.top.f1.ysc -command { .fics.f.top.f1.console yview }
    text $w.f.top.f1.console -bg $::fics::consolebg -fg $::fics::consolefg -height $::fics::consoleheight -width $::fics::consolewidth  \
        -wrap word -yscrollcommand "$w.f.top.f1.ysc set"
    pack $w.f.top.f1.ysc -side left -fill y -side right
    pack $w.f.top.f1.console -side left -fill both -expand 1 -side right
    
    #define colors for console
    # $w.f.top.f1.console tag configure seeking     -foreground coral
    # $w.f.top.f1.console tag configure game        -foreground grey70
    # $w.f.top.f1.console tag configure gameresult  -foreground SlateBlue1
    # $w.f.top.f1.console tag configure ficspercent -foreground khaki1
    
    $w.f.top.f1.console tag configure seeking     -foreground $::fics::colseeking
    $w.f.top.f1.console tag configure game        -foreground $::fics::colgame
    $w.f.top.f1.console tag configure gameresult  -foreground $::fics::colgameresult
    $w.f.top.f1.console tag configure ficspercent -foreground $::fics::colficspercent
    
    ttk::entry $w.f.top.f2.cmd -width 32
    ttk::button $w.f.top.f2.send -text send -command ::fics::cmd
    bind $w.f.top.f2.cmd <Return> { ::fics::cmd }
    bind $w.f.top.f2.cmd <Up> { ::fics::cmdHistory up ; break }
    bind $w.f.top.f2.cmd <Down> { ::fics::cmdHistory down ; break }
    bind $w.f.top.f2.cmd <Left> " [bind TEntry <Left>] ; break "
    bind $w.f.top.f2.cmd <Right> " [bind TEntry <Right>] ; break "
    pack $w.f.top.f2.cmd $w.f.top.f2.send -side left -fill x
    
    # clock 1 is white
    ::gameclock::new $w.f.bottom.left 1 100 0
    ::gameclock::new $w.f.bottom.left 2 100 0
    
    set row 0
    ttk::checkbutton $w.f.bottom.right.silence -text "Silence" -variable ::fics::silence -onvalue 0 -offvalue 1 -command {
      ::fics::writechan "set gin $::fics::silence" "echo"
      ::fics::writechan "set seek $::fics::silence" "echo"
      ::fics::writechan "set silence $::fics::silence" "echo"
      ::fics::writechan "set chanoff [expr ! $::fics::silence ]" "echo"
    }
    set ::fics::silence 1
    
    grid $w.f.bottom.right.silence -column 0 -row $row -sticky w
    incr row
    ttk::checkbutton $w.f.bottom.right.offers -text "Offers" -variable ::fics::graphon -command ::fics::showOffers
    set ::fics::graphon 0
    ttk::button $w.f.bottom.right.games -text "Games" -command { ::fics::writechan "games /bs"}
    grid $w.f.bottom.right.offers -column 0 -row $row -sticky w
    grid $w.f.bottom.right.games -column 1 -row $row -sticky ew
    incr row
    ttk::button $w.f.bottom.right.findopp -text "Find opponent" -command { ::fics::findOpponent }
    grid $w.f.bottom.right.findopp -column 0 -row $row -sticky ew
    ttk::button $w.f.bottom.right.abort -text "Abort" -command { ::fics::writechan "abort" }
    grid $w.f.bottom.right.abort -column 1 -row $row -sticky ew
    incr row
    
    ttk::button $w.f.bottom.right.draw -text "Draw" -command { ::fics::writechan "draw"}
    ttk::button $w.f.bottom.right.resign -text "Resign" -command { ::fics::writechan "resign"}
    grid $w.f.bottom.right.draw -column 0 -row $row -sticky ew
    grid $w.f.bottom.right.resign -column 1 -row $row -sticky ew
    incr row
    
    ttk::button $w.f.bottom.right.takeback -text "Takeback" -command { ::fics::writechan "takeback"}
    ttk::button $w.f.bottom.right.takeback2 -text "Takeback 2" -command { ::fics::writechan "takeback 2"}
    grid $w.f.bottom.right.takeback -column 0 -row $row -sticky ew
    grid $w.f.bottom.right.takeback2 -column 1 -row $row -sticky ew
    incr row
    
    ttk::button $w.f.bottom.right.cancel -text "Close" -command { ::fics::close }
    
    grid $w.f.bottom.right.cancel -column 0 -row $row -sticky ew
    
    bind $w <Destroy> { catch ::fics::close }
    bind $w <Configure> "recordWinSize $w"
    
    bind $w <F1> { helpWindow FICS}
    bind $w.f.top.f1.console <FocusIn> "focus $w.f.top.f2.cmd"
    bind $w.f.top.f1.console <Configure> { .fics.f.top.f1.console yview moveto 1 }
    standardShortcuts $w
    
    # all widgets must be visible
    update
    set x [winfo reqwidth $w]
    set y [winfo reqheight $w]
    wm minsize $w $x $y
    
    setWinLocation $w
    setWinSize $w
    
    ::gameclock::setColor 1 white
    ::gameclock::setColor 2 black
    
    updateConsole "Connecting $login"
    
    # start timeseal proxy
    if {$::fics::use_timeseal} {
      updateConsole "Starting TimeSeal"
      if { [catch { set timeseal_pid [exec $::fics::timeseal_exec $::fics::server_ip $::fics::port_fics -p $::fics::port_timeseal &]} ] } {
        set ::fics::use_timeseal 0
        set port $::fics::port_fics
      } else {
        #wait for proxy to be ready !?
        after 500
        set server "localhost"
        set port $::fics::port_timeseal
      }
    } else {
      set server $::fics::server
      set port $::fics::port_fics
    }
    
    updateConsole "Socket opening"
    
    if { [catch { set sockchan [socket $server $port] } ] } {
      tk_messageBox -title "Error" -icon error -type ok -message "Network error\nCan't connect to $server $port" -parent .fics
      return
    }
    
    updateConsole "Channel configuration"
    
    fconfigure $sockchan -blocking 0 -buffering line -translation auto ;#-encoding iso8859-1 -translation crlf
    fileevent $sockchan readable ::fics::readchan
    setState disabled
  }
  ################################################################################
  #
  ################################################################################
  proc cmd {} {
    set l [.fics.f.top.f2.cmd get]
    .fics.f.top.f2.cmd delete 0 end
    if {$l == "quit"} {
      ::fics::close
      return
    }
    # do nothing if the command is void
    if {[string trim $l] == ""} { return }
    writechan $l "echo"
    lappend ::fics::history $l
    set ::fics::history_pos [llength $::fics::history]
  }
  ################################################################################
  #
  ################################################################################
  proc cmdHistory { action } {
    set t .fics.f.top.f2.cmd
    
    if {$action == "up" && $::fics::history_pos > 0} {
      incr ::fics::history_pos -1
      $t delete 0 end
      $t insert end [lindex $::fics::history $::fics::history_pos]
    }
    if {$action == "down" && $::fics::history_pos < [expr [llength $::fics::history] -1] } {
      incr ::fics::history_pos
      $t delete 0 end
      $t insert end [lindex $::fics::history $::fics::history_pos]
    }
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
    pack [ttk::frame $w.f]
    
    ttk::label $w.f.linit -text "initial time (min)"
    spinbox $w.f.sbTime1 -background white -width 3 -textvariable ::fics::findopponent(initTime) -from 0 -to 120 -increment 1 -validate all -vcmd { regexp {^[0-9]+$} %P }
    ttk::label $w.f.linc -text "increment (sec)"
    spinbox $w.f.sbTime2 -background white -width 3 -textvariable ::fics::findopponent(incTime) -from 0 -to 120 -increment 1 -validate all -vcmd { regexp {^[0-9]+$} %P }
    grid $w.f.linit -column 0 -row 0 -sticky ew
    grid $w.f.sbTime1 -column 1 -row 0 -sticky ew
    grid $w.f.linc -column 0 -row 1 -sticky ew
    grid $w.f.sbTime2 -column 1 -row 1 -sticky ew
    
    ttk::checkbutton $w.f.cbrated -text "Rated game" -onvalue "rated" -offvalue "unrated" -variable ::fics::findopponent(rated)
    grid $w.f.cbrated -column 0 -row 2 -columnspan 2 -sticky ew
    
    ttk::label $w.f.color -text color
    grid $w.f.color -column 0 -row 3 -columnspan 3 -sticky ew
    ttk::radiobutton $w.f.rb1 -text "automatic" -value "" -variable ::fics::findopponent(color)
    ttk::radiobutton $w.f.rb2 -text "white" -value "white" -variable ::fics::findopponent(color)
    ttk::radiobutton $w.f.rb3 -text "black" -value "black" -variable ::fics::findopponent(color)
    grid $w.f.rb1 -column 0 -row 4 -sticky ew
    grid $w.f.rb2 -column 1 -row 4 -sticky ew
    grid $w.f.rb3 -column 2 -row 4 -sticky ew
    
    ttk::checkbutton $w.f.cblimitrating -text "Limit rating between" -variable ::fics::findopponent(limitrating)
    spinbox $w.f.sbrating1 -background white -width 4 -textvariable ::fics::findopponent(rating1) -from 1000 -to 3000 -increment 50 -validate all -vcmd { regexp {^[0-9]+$} %P }
    spinbox $w.f.sbrating2 -background white -width 4 -textvariable ::fics::findopponent(rating2) -from 1000 -to 3000 -increment 50 -validate all -vcmd { regexp {^[0-9]+$} %P }
    grid $w.f.cblimitrating -column 0 -row 5 -columnspan 2 -sticky ew
    grid $w.f.sbrating1 -column 0 -row 6 -sticky ew
    grid $w.f.sbrating2 -column 1 -row 6 -sticky ew
    
    ttk::checkbutton $w.f.cbmanual -text "confirm manually" -onvalue "manual" -offvalue "auto" -variable ::fics::findopponent(manual)
    grid $w.f.cbmanual -column 0 -row 7 -columnspan 2 -sticky ew
    ttk::checkbutton $w.f.cbformula -text "Filter with formula" -onvalue "formula" -offvalue "" -variable ::fics::findopponent(formula)
    grid $w.f.cbformula -column 0 -row 8 -columnspan 2 -sticky ew
    
    ttk::button $w.f.seek -text "Issue seek" -command {
      set range ""
      if {$::fics::findopponent(limitrating) } {
        set range "$::fics::findopponent(rating1)-$::fics::findopponent(rating2)"
      }
      set cmd "seek $::fics::findopponent(initTime) $::fics::findopponent(incTime) $::fics::findopponent(rated) \
          $::fics::findopponent(color) $::fics::findopponent(manual) $::fics::findopponent(formula) $range"
      ::fics::writechan $cmd
      destroy .ficsfindopp
    }
    ttk::button $w.f.cancel -text "Cancel" -command "destroy $w"
    bind $w <F1> { helpWindow FICSfindOpp}
    
    grid $w.f.seek -column 0 -row 9 -sticky ew
    grid $w.f.cancel -column 1 -row 9 -sticky ew
  }
  ################################################################################
  #
  ################################################################################
  proc readchan {} {
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
  # Appends an array to soughtlist if the parameter is correct
  ################################################################################
  proc parseSoughtLine { l } {
    global ::fics::offers_minelo ::fics::offers_maxelo ::fics::offers_mintime ::fics::offers_maxtime
    
    if { [ catch { if {[llength $l] < 8} { return } } ] } { return }
    array set ga {}
    
    set offset 0
    set ga(game) [lindex $l 0]
    if { ! [string is integer $ga(game)] } { return }
    set tmp [lindex $l 1]
    if { [scan $tmp "%d" ga(elo)] != 1} { set ga(elo) $offers_minelo }
    if { $ga(elo) < $offers_minelo } { set ga(elo) $offers_minelo }
    set ga(name) [lindex $l 2]
    
    set tmp [lindex $l 3]
    if { [scan $tmp "%d" ga(time_init)] != 1} { set ga(time_init) $offers_maxtime}
    set tmp [lindex $l 4]
    if { [scan $tmp "%d" ga(time_inc)] != 1} { set ga(time_inc) 0 }
    
    set ga(rated) [lindex $l 5]
    if {$ga(rated) != "rated" && $ga(rated) != "unrated"} { return }
    
    set ga(type) [lindex $l 6]
    if { $ga(type) != "untimed" && $ga(type) != "blitz" && $ga(type) != "standard" && $ga(type) != "lightning" } {
      return
    }
    set ga(color) ""
    if { [lindex $l 7] == "\[white\]" || [lindex $l 7] == "\[black\]" } {
      set ga(color) [lindex $l 7]
      set offset 1
    }
    set ga(rating_range) [lindex $l [expr 7 + $offset]]
    if { [ catch { set ga(start) [lindex $l [expr 8 + $offset]] } ] } {
      set ga(start) ""
    }
    
    lappend ::fics::soughtlist [array get ga]
  }
  ################################################################################
  #
  ################################################################################
  proc readparse {line} {
    variable logged
    variable isGuestLogin
    
    if {$line == "" || $line == "fics% "} {return}
    
    # puts  "readparse $line"
    
    if { $::fics::sought } {
      if {[string match "* ad* displayed." $line]} {
        set ::fics::sought 0
        catch { displayOffers }
        return
      }
      # lappend ::fics::soughtlist $line
      parseSoughtLine $line
      return
    }
    
    if {[string match "login: " $line]} {
      writechan $::fics::reallogin
      if { $isGuestLogin} {
        set logged 1
      }
      return
    }
    if {[string match "password: " $line]} {
      writechan $::fics::password
      set logged 1
      return
    }
    if {[string match "<sc>*" $line]} {
      set ::fics::seeklist {}
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
    
    # puts "readparse->$line"
    updateConsole $line
    if {[string match "Creating: *" $line]} {
      # hide offers graph
      if { $::fics::graphon } {
        .fics.f.bottom.right.offers invoke
      }
      ::utils::sound::PlaySound sound_move
      sc_game new
      set idx1 [string first "(" $line]
      set white [string trim [string range $line 10 [expr $idx1 -1]] ]
      set idx2 [string first ")" $line]
      set whiteElo [string trim [string range $line [expr $idx1 +1] [expr $idx2 -1]] ]
      
      set idx1 [expr $idx2 +1]
      set idx2 [string first "(" $line $idx1]
      set black [string trim [string range $line $idx1 [expr $idx2 -1]] ]
      
      set idx1 [expr $idx2 +1]
      set idx2 [string first ")" $line $idx1]
      set blackElo [string trim [string range $line $idx1 [expr $idx2 -1]] ]
      
      if { $whiteElo == "++++"} { set whiteElo 0 }
      if { $blackElo == "++++"} { set blackElo 0 }
      
      sc_game tags set -white $white
      sc_game tags set -whiteElo $whiteElo
      sc_game tags set -black $black
      sc_game tags set -blackElo $blackElo
      
      sc_game tags set -event "Fics [lrange $line 5 end]"
      if { [::board::isFlipped .main.board] } {
        if { [ string match -nocase $white $::fics::reallogin ] } { ::board::flip .main.board }
      } else {
        if { [ string match -nocase $black $::fics::reallogin ] } { ::board::flip .main.board }
      }
      updateBoard -pgn -animate
      return
    }
    
    if {[string match "\{Game *" $line]} {
      set num [lindex [lindex $line 0] 1]
      set res [lindex $line end]
      if {$num == $::fics::observedGame} {
        if {[string match "1/2*" $res]} {
          tk_messageBox -title "Game result" -icon info -type ok -message "Draw"
        } else {
          tk_messageBox -title "Game result" -icon info -type ok -message "$res"
        }
        sc_game tags set -result $res
        updateBoard -pgn
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
    
    # Start session
    if {[string match "*Starting FICS session*" $line]} {
      # init commands
      writechan "iset seekremove 1"
      writechan "iset seekinfo 1"
      writechan "set seek 1"
      writechan "set silence 1"
      writechan "set chanoff 0"
      writechan "set echo 1"
      writechan "set cshout 0"
      writechan "style 12"
      writechan "iset nowrap 1"
      writechan "iset nohighlight 1"
      setState normal
      return
    }
    
    if { $::fics::waitForRating == "wait" } {
      if {[catch {set val [lindex $line 0]}]} {
        return
      } else  {
        if {[lindex $line 0] == "Standard"} {
          set ::fics::waitForRating [lindex $line 1]
          return
        }
      }
    }
    
    if { $::fics::waitForMoves != "" } {
      set m1 ""
      set m2 ""
      set line [string trim $line]
            
      # Because some free text may be in the form (".)
      if {[catch {llength $line} err]} {
        puts "Exception $err llength $line"
        return
      }
      
      if {[llength $line ] == 5 && [scan $line "%d. %s (%d:%d) %s (%d:%d)" t1 m1 t2 t3 m2 t4 t5] != 7} {
        return
      }
      if {[llength $line ] == 3 && [scan $line "%d. %s (%d:%d)" t1 m1 t2 t3] != 4} {
        return
      }
      catch { sc_move addSan $m1 }
      if {$m2 != ""} {
        catch { sc_move addSan $m2 }
      }
      
      if {[sc_pos fen] == $::fics::waitForMoves } {
        set ::fics::waitForMoves ""
      }
    }
    
    if {[string match "Challenge:*" $line]} {
      set ans [tk_dialog .challenge "Challenge" $line "" 0 "accept" "decline"]
      if {$ans == 0} {
        writechan "accept"
      } else {
        writechan "decline"
      }
    }
    
    # abort request
    if {[string match "* would like to abort the game;*" $line]} {
      set ans [tk_messageBox -title "Abort" -icon question -type yesno -message "$line\nDo you accept ?" ]
      if {$ans == yes} {
        writechan "accept"
      } else {
        writechan "decline"
      }
    }
    
    # takeback
    if {[string match "* would like to take back *" $line]} {
      set ans [tk_messageBox -title "Abort" -icon question -type yesno -message "$line\nDo you accept ?" ]
      if {$ans == yes} {
        writechan "accept"
      } else {
        writechan "decline"
      }
    }
    
    # draw
    if {[string match "*offers you a draw*" $line]} {
      set ans [tk_messageBox -title "Abort" -icon question -type yesno -message "$line\nDo you accept ?" ]
      if {$ans == yes} {
        writechan "accept"
      } else {
        writechan "decline"
      }
    }
    
    # adjourn
    if {[string match "*would like to adjourn the game*" $line]} {
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
      set ::fics::reallogin [lindex $line 4]
      ::setTitle .fics "Free Internet Chess Server $::fics::reallogin"
    }
    if {[string match "Press return to enter the server as*" $line]} {
      writechan "\n"
    }
    
  }
  ################################################################################
  #  Set the state of user interface related to connection state
  ################################################################################
  proc setState { state } {
    set w .fics
    
    foreach elt [list $w.f.bottom.right.offers $w.f.bottom.right.silence $w.f.top.f2.send $w.f.bottom.right.offers $w.f.bottom.right.games \
        $w.f.bottom.right.findopp $w.f.bottom.right.abort $w.f.bottom.right.draw $w.f.bottom.right.resign $w.f.bottom.right.takeback \
        $w.f.bottom.right.takeback2] {
          $elt configure -state $state
        }
  }
  ################################################################################
  #
  ################################################################################
  proc updateConsole {line} {
    set t .fics.f.top.f1.console
    if { [string match "* seeking *" $line ] } {
      $t insert end "$line\n" seeking
    } elseif { [string match "\{Game *\}" $line ] } {
      $t insert end "$line\n" game
    } elseif { [string match "\{Game *\} *" $line ] } {
      $t insert end "$line\n" gameresult
    } elseif { [string match "fics% *" $line ] } {
      $t insert end "$line\n" ficspercent
    } else  {
      $t insert end "$line\n"
    }
    
    set pos [ lindex [ .fics.f.top.f1.ysc get ] 1 ]
    if {$pos == 1.0} {
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
      
      # remove seek from seeklist
      for {set i 0} {$i < [llength $seeklist]} {incr i} {
        array set a [lindex $seeklist $i]
        if {$a(index) == $l} {
          set seeklist [lreplace $seeklist $i $i]
          break
        }
      }
      
      # remove seek from graph
      if { $::fics::graphon } {
        for {set idx 0} { $idx < [llength $::fics::soughtlist]} { incr idx } {
          array set g [lindex $::fics::soughtlist $idx]
          set num $g(game)
          if { $num == $l } {
            .fics.f.bottom.graph.c delete game_$idx
            break
          }
        }
      }
      
    }
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
    
    ::gameclock::setSec 1 [ expr 0 - $whiteRemainingTime ]
    ::gameclock::setSec 2 [ expr 0 - $blackRemainingTime ]
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
    
    # puts $verbose_move
    # try to play the move and check if fen corresponds. If not this means the position needs to be set up.
    if {$moveSan != "none" && $::fics::playing != -1} {
      # first check side's coherency
      if { ([sc_pos side] == "white" && $color == "B") || ([sc_pos side] == "black" && $color == "W") } {
        # puts "sc_move addSan $moveSan"
        ::utils::sound::PlaySound sound_move
        ::utils::sound::AnnounceNewMove $moveSan
        if { [catch { sc_move addSan $moveSan } err ] } {
          puts "error $err"
        } else {
          if { $::novag::connected } {
            set m $verbose_move
            if { [string index $m 1] == "/" } { set m [string range $m 2 end] }
            set m [string map { "-" "" "=" "" } $m]
            ::novag::addMove $m
          }
          updateBoard -pgn -animate
        }
      }
    }
    
    if {$fen != [sc_pos fen]} {
      puts "Debug fen \n$fen\n[sc_pos fen]"
      
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
      
      # try to get first moves of game
      writechan "moves $gameNumber"
      set ::fics::waitForMoves $fen
      vwaitTimed ::fics::waitForMoves 2000 "nowarn"
      set ::fics::waitForMoves ""
      
      # Did not manage to reconstruct the game, just set its position
      if {$fen != [sc_pos fen]} {
        sc_game startBoard $fen
      }
      updateBoard -pgn -animate
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
  }
  ################################################################################
  #
  ################################################################################
  proc redim {} {
    set w .fics
    update
    set x [winfo reqwidth $w]
    set y [winfo reqheight $w]
    wm geometry $w ${x}x${y}
  }
  ################################################################################
  #
  ################################################################################
  proc showOffers {} {
    set w .fics.f.bottom.graph
    
    if { $::fics::graphon } {
      bind .fics <Configure> ""
      pack $w -side right -after .fics.f.bottom.right -anchor n
      redim
      updateOffers
    } else {
      after cancel ::fics::updateOffers
      pack forget $w
      setWinSize .fics
      bind .fics <Configure> "recordWinSize .fics"
    }
  }
  ################################################################################
  #
  ################################################################################
  proc updateOffers { } {
    set ::fics::sought 1
    set ::fics::soughtlist {}
    writechan "sought"
    vwaitTimed ::fics::sought 5000 "nowarn"
    after 3000 ::fics::updateOffers
  }
  ################################################################################
  #
  ################################################################################
  proc displayOffers { } {
    global ::fics::width ::fics::height ::fics::off \
        ::fics::offers_minelo ::fics::offers_maxelo ::fics::offers_mintime ::fics::offers_maxtime
    after cancel ::fics::updateOffers
    
    set w .fics.f.bottom.graph
    set size 5
    set idx 0
    
    #first erase the canvas
    foreach id [ $w.c find all] { $w.c delete $id }
    
    # draw scales
    $w.c create line $off [expr $height - $off ] $width [expr $height - $off] -fill blue
    $w.c create line $off 0 $off [expr $height - $off] -fill blue
    $w.c create text 1 1 -fill black -anchor nw -text ELO
    $w.c create text [expr $width - 1 ] [expr $height - 1 ] -fill black -anchor se -text [tr Time]
    
    # draw time markers at 5', 15'
    set x [ expr $off + 5 * ($width - $off) / ($offers_maxtime - $offers_mintime)]
    $w.c create line $x 0 $x [expr $height - $off] -fill red
    set x [ expr $off + 15 * ($width - $off) / ($offers_maxtime - $offers_mintime)]
    $w.c create line $x 0 $x [expr $height - $off] -fill red
    
    foreach g $::fics::soughtlist {
      array set l $g
      set fillcolor green
      # if the time is too large, put it in red
      set tt [expr $l(time_init) + $l(time_inc) * 2 / 3 ]
      if { $tt > $offers_maxtime } {
        set tt $offers_maxtime
        set fillcolor red
      }
      # if a computer, put it in blue
      if { [string match "*(C)" $l(name)] } {
        set fillcolor blue
      }
      # if player without ELO, in gray
      if { [string match "Guest*" $l(name)] } {
        set fillcolor gray
      }
      
      set x [ expr $off + $tt * ($width - $off) / ($offers_maxtime - $offers_mintime)]
      set y [ expr $height - $off - ( $l(elo) - $offers_minelo ) * ($height - $off) / ($offers_maxelo - $offers_minelo)]
      if { $l(rated) == "rated" } {
        set object "oval"
      } else {
        set object "rectangle"
      }
      $w.c create $object [expr $x - $size ] [expr $y - $size ] [expr $x + $size ] [expr $y + $size ] -tag game_$idx -fill $fillcolor
      
      $w.c bind game_$idx <Enter> "::fics::setOfferStatus $idx %x %y"
      $w.c bind game_$idx <Leave> "::fics::setOfferStatus -1 %x %y"
      $w.c bind game_$idx <ButtonPress> "::fics::getOffersGame $idx"
      incr idx
    }
    
  }
  ################################################################################
  # Play the selected game
  ################################################################################
  proc getOffersGame { idx } {
    array set ga [lindex $::fics::soughtlist $idx]
    catch { writechan "play $ga(game)" }
  }
  ################################################################################
  #
  ################################################################################
  proc setOfferStatus { idx x y } {
    global ::fics::height ::fics::width
    
    set w .fics.f.bottom.graph
    if { $idx != -1 } {
      set gl [lindex $::fics::soughtlist $idx]
      if { $gl == "" } { return }
      array set l [lindex $::fics::soughtlist $idx]
      set m "$l(game) $l(name)($l(elo))\n$l(time_init)/$l(time_inc) $l(rated)\n$l(color) $l(start)"
      
      if {$y < [expr $height / 2]} {
        set anchor "n"
      } else {
        set anchor "s"
      }
      
      if {$x < [expr $width / 2]} {
        append anchor "w"
      } else {
        append anchor "e"
      }
      
      $w.c create text $x $y -tags status -text $m -font font_offers -anchor $anchor -width 150
      $w.c raise game_$idx
    } else {
      $w.c delete status
    }
  }
  ################################################################################
  #
  ################################################################################
  proc play {index} {
    writechan "play $index"
    # set ::fics::playing 1
    set ::fics::observedGame $index
  }
  ################################################################################
  #
  ################################################################################
  proc writechan {line {echo "noecho"}} {
    after cancel ::fics::stayConnected
    if {[eof $::fics::sockchan]} {
      tk_messageBox -title "FICS" -icon error -type ok -message "Network error"
      return
    }
    puts $::fics::sockchan $line
    if {$echo != "noecho"} {
      updateConsole "->>$line"
    }
    after 2700000 ::fics::stayConnected
  }
  ################################################################################
  # FICS seems to close connexion after 1 hr idle. So send a dummy command
  # every 45 minutes
  ################################################################################
  proc stayConnected {} {
    catch {
      writechan "date" "noecho"
      after 2700000 ::fics::stayConnected
    }
  }
  ################################################################################
  #   returns 1 if the player is allowed to enter a move (either playing or using puzzlebot)
  ################################################################################
  proc playerCanMove {} {
    
    if { ! [winfo exists .fics] } { return 1 }
    
    if { [sc_game info white] == "puzzlebot" && [sc_game info white] == "puzzlebot" } {
      return 1
    }
    
    if { $::fics::playing == 1 } { return 1 }
    
    return 0
  }
  ################################################################################
  #
  ################################################################################
  proc close {} {
    variable logged
    # stop recursive call
    bind .fics <Destroy> {}
    
    set ::fics::sought 0
    after cancel ::fics::updateOffers
    after cancel ::fics::stayConnected
    set logged 0
    
    writechan "exit"
    set ::fics::playing 0
    set ::fics::observedGame -1
    ::close $::fics::sockchan
    if { ! $::windowsOS } { catch { exec -- kill -s INT [ $::fics::timeseal_pid ] }  }
    destroy .fics
    # necessary on windows
    ::docking::cleanup .fics
  }
}

###
### End of file: fics.tcl
###
