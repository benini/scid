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
    ::setTitle $w [::tr "ConfigureFics"]
    pack [ttk::frame $w.f]
    
    ttk::label $w.f.lLogin -text [::tr "CCDlgLoginName"]
    ttk::entry $w.f.login -width 20 -textvariable ::fics::login
    ttk::label $w.f.lPwd -text [::tr "CCDlgPassword"]
    ttk::entry $w.f.passwd -width 20 -textvariable ::fics::password
    ttk::button $w.f.connect -text [::tr "FICSConnect"] -state disabled -command {
      ::fics::connect [.ficsConfig.f.login get] [.ficsConfig.f.passwd get]
      destroy .ficsConfig
    }
    ttk::button $w.f.guest -text [::tr FICSGuest] -state disabled -command {
      ::fics::connect "guest" ""
      destroy .ficsConfig
    }
    ttk::button $w.f.cancel -text [::tr "Cancel"] -command { destroy .ficsConfig }
    
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
    ttk::label $w.f.lFICS_port -text [::tr "FICSServerPort"]
    ttk::entry $w.f.portserver -width 6 -textvariable ::fics::port_fics
    ttk::label $w.f.ltsport -text [::tr "FICSTimesealPort"]
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
    
    ttk::notebook $w.f.top
    
    ttk::frame $w.f.top.fconsole
    ttk::frame $w.f.top.fconsole.f1
    ttk::frame $w.f.top.fconsole.f2
    
    ttk::frame $w.f.top.foffers
    $w.f.top add $w.f.top.fconsole -sticky nsew -text [::tr "FICSConsole"]
    $w.f.top add $w.f.top.foffers -sticky nsew -text [::tr "FICSOffers"]
    
    pack $w.f.top.fconsole.f1  -fill both -expand 1
    pack $w.f.top.fconsole.f2 -fill x
    ttk::frame $w.f.bottom
    
    $w.f add $w.f.top -weight 1
    $w.f add $w.f.bottom -weight 1
    
    ttk::frame $w.f.bottom.left
    ttk::frame $w.f.bottom.right
    pack $w.f.bottom.left -side left
    pack $w.f.bottom.right -side left
    
    # graph
    canvas $w.f.top.foffers.c -background white -width $width -height $height -relief solid
    pack $w.f.top.foffers.c
    
    ttk::scrollbar $w.f.top.fconsole.f1.ysc -command { .fics.f.top.fconsole.f1.console yview }
    text $w.f.top.fconsole.f1.console -bg $::fics::consolebg -fg $::fics::consolefg -height $::fics::consoleheight -width $::fics::consolewidth  \
        -wrap word -yscrollcommand "$w.f.top.fconsole.f1.ysc set"
    pack $w.f.top.fconsole.f1.ysc -side left -fill y -side right
    pack $w.f.top.fconsole.f1.console -side left -fill both -expand 1 -side right
    
    #define colors for console
    $w.f.top.fconsole.f1.console tag configure seeking     -foreground $::fics::colseeking
    $w.f.top.fconsole.f1.console tag configure game        -foreground $::fics::colgame
    $w.f.top.fconsole.f1.console tag configure gameresult  -foreground $::fics::colgameresult
    $w.f.top.fconsole.f1.console tag configure ficspercent -foreground $::fics::colficspercent
    
    ttk::entry $w.f.top.fconsole.f2.cmd -width 32
    ttk::button $w.f.top.fconsole.f2.send -text [::tr "FICSSend"] -command ::fics::cmd
    bind $w.f.top.fconsole.f2.cmd <Return> { ::fics::cmd }
    bind $w.f.top.fconsole.f2.cmd <Up> { ::fics::cmdHistory up ; break }
    bind $w.f.top.fconsole.f2.cmd <Down> { ::fics::cmdHistory down ; break }
    bind $w.f.top.fconsole.f2.cmd <Left> " [bind TEntry <Left>] ; break "
    bind $w.f.top.fconsole.f2.cmd <Right> " [bind TEntry <Right>] ; break "
    pack $w.f.top.fconsole.f2.cmd $w.f.top.fconsole.f2.send -side left -fill x
    
    # clock 1 is white
    ::gameclock::new $w.f.bottom.left 1 100 0
    ::gameclock::new $w.f.bottom.left 2 100 0
    
    set row 0
    ttk::checkbutton $w.f.bottom.right.silence -text [::tr "FICSSilence"] -variable ::fics::silence -onvalue 0 -offvalue 1 -command {
      ::fics::writechan "set gin $::fics::silence" "echo"
      ::fics::writechan "set seek $::fics::silence" "echo"
      ::fics::writechan "set silence $::fics::silence" "echo"
      ::fics::writechan "set chanoff [expr ! $::fics::silence ]" "echo"
    }
    set ::fics::silence 1
    
    grid $w.f.bottom.right.silence -column 0 -row $row -sticky w
    incr row
    
    set ::fics::graphon 0
    
    ttk::button $w.f.bottom.right.findopp -image FICSsearch  -command { ::fics::findOpponent }
    ::utils::tooltip::Set $w.f.bottom.right.findopp [::tr "FICSFindOpponent"]
    grid $w.f.bottom.right.findopp -column 0 -row $row -sticky ew
    ttk::button $w.f.bottom.right.games -image FICSusers -compound image -command { ::fics::writechan "games /bs"}
    ::utils::tooltip::Set $w.f.bottom.right.games "[::tr FICSGames]\n(games /bs)"
    grid $w.f.bottom.right.games -column 2 -row $row -sticky ew
    ttk::button $w.f.bottom.right.relay -image FICSrelayedgames -compound image -command { ::fics::writechan "tell relay listgames"}
    ::utils::tooltip::Set $w.f.bottom.right.relay "[::tr FICSRelayedGames]\n(tell relay listgames)"
    grid $w.f.bottom.right.relay -column 1 -row $row -sticky ew
    
    incr row
    
    ttk::button $w.f.bottom.right.draw -image FICSdraw -command { ::fics::writechan "draw"}
    ::utils::tooltip::Set $w.f.bottom.right.draw "[::tr CCClaimDraw]\n(draw)"
    ttk::button $w.f.bottom.right.resign -image FICSresign -command { ::fics::writechan "resign"}
    ::utils::tooltip::Set $w.f.bottom.right.resign "[::tr CCResign]\n(resign)"
    grid $w.f.bottom.right.draw -column 0 -row $row -sticky ew
    grid $w.f.bottom.right.resign -column 1 -row $row -sticky ew
    ttk::button $w.f.bottom.right.abort -image FICSabort -command { ::fics::writechan "abort" }
    ::utils::tooltip::Set $w.f.bottom.right.abort "[::tr Abort]\n(abort)"
    grid $w.f.bottom.right.abort -column 2 -row $row -sticky ew
    incr row
    
    ttk::button $w.f.bottom.right.takeback -image FICStakeback1 -command { ::fics::writechan "takeback"}
    ::utils::tooltip::Set $w.f.bottom.right.takeback "[::tr FICSTakeback]\n(takeback)"
    ttk::button $w.f.bottom.right.takeback2 -image FICStakeback2 -command { ::fics::writechan "takeback 2"}
    ::utils::tooltip::Set $w.f.bottom.right.takeback2 "[::tr FICSTakeback2]\n(takeback 2)"
    
    grid $w.f.bottom.right.takeback -column 0 -row $row -sticky ew
    grid $w.f.bottom.right.takeback2 -column 1 -row $row -sticky ew
    incr row
    
    ttk::button $w.f.bottom.right.cancel -image FICSexit -command { ::fics::close }
    ::utils::tooltip::Set $w.f.bottom.right.cancel [::tr "Close"]
    grid $w.f.bottom.right.cancel -column 0 -columnspan 3 -row $row -sticky ew
    
    bind $w.f.top <<NotebookTabChanged>> { ::fics::tabchanged }
    bind $w <Destroy> { catch ::fics::close }
    bind $w <Configure> "recordWinSize $w"
    
    bind $w <F1> { helpWindow FICS}
    bind $w.f.top.fconsole.f1.console <FocusIn> "focus $w.f.top.fconsole.f2.cmd"
    bind $w.f.top.fconsole.f1.console <Configure> { .fics.f.top.fconsole.f1.console yview moveto 1 }
    bind $w.f.top.fconsole.f1.console <ButtonPress-1> { ::fics::consoleClick %x %y %W }
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
    set l [.fics.f.top.fconsole.f2.cmd get]
    .fics.f.top.fconsole.f2.cmd delete 0 end
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
    set t .fics.f.top.fconsole.f2.cmd
    
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
    
    ttk::label $w.f.linit -text [::tr "FICSInitialTime"]
    spinbox $w.f.sbTime1 -background white -width 3 -textvariable ::fics::findopponent(initTime) -from 0 -to 120 -increment 1 -validate all -vcmd { regexp {^[0-9]+$} %P }
    ttk::label $w.f.linc -text [::tr "FICSIncrement"]
    spinbox $w.f.sbTime2 -background white -width 3 -textvariable ::fics::findopponent(incTime) -from 0 -to 120 -increment 1 -validate all -vcmd { regexp {^[0-9]+$} %P }
    grid $w.f.linit -column 0 -row 0 -sticky ew
    grid $w.f.sbTime1 -column 1 -row 0 -sticky ew
    grid $w.f.linc -column 0 -row 1 -sticky ew
    grid $w.f.sbTime2 -column 1 -row 1 -sticky ew
    
    ttk::checkbutton $w.f.cbrated -text [::tr "FICSRatedGame"] -onvalue "rated" -offvalue "unrated" -variable ::fics::findopponent(rated)
    grid $w.f.cbrated -column 0 -row 2 -columnspan 2 -sticky ew
    
    ttk::label $w.f.color -text [::tr "FICSColour"]
    grid $w.f.color -column 0 -row 3 -columnspan 3 -sticky ew
    ttk::radiobutton $w.f.rb1 -text [::tr "FICSAutoColour"] -value "" -variable ::fics::findopponent(color)
    ttk::radiobutton $w.f.rb2 -text [::tr "White"] -value "white" -variable ::fics::findopponent(color)
    ttk::radiobutton $w.f.rb3 -text [::tr "Black"] -value "black" -variable ::fics::findopponent(color)
    grid $w.f.rb1 -column 0 -row 4 -sticky ew
    grid $w.f.rb2 -column 1 -row 4 -sticky ew
    grid $w.f.rb3 -column 2 -row 4 -sticky ew
    
    ttk::checkbutton $w.f.cblimitrating -text [::tr "RatingRange"] -variable ::fics::findopponent(limitrating)
    spinbox $w.f.sbrating1 -background white -width 4 -textvariable ::fics::findopponent(rating1) -from 1000 -to 3000 -increment 50 -validate all -vcmd { regexp {^[0-9]+$} %P }
    spinbox $w.f.sbrating2 -background white -width 4 -textvariable ::fics::findopponent(rating2) -from 1000 -to 3000 -increment 50 -validate all -vcmd { regexp {^[0-9]+$} %P }
    grid $w.f.cblimitrating -column 0 -row 5 -columnspan 2 -sticky ew
    grid $w.f.sbrating1 -column 0 -row 6 -sticky ew
    grid $w.f.sbrating2 -column 1 -row 6 -sticky ew
    
    ttk::checkbutton $w.f.cbmanual -text [::tr "FICSManualConfirm"] -onvalue "manual" -offvalue "auto" -variable ::fics::findopponent(manual)
    grid $w.f.cbmanual -column 0 -row 7 -columnspan 2 -sticky ew
    ttk::checkbutton $w.f.cbformula -text [::tr "FICSFilterFormula"] -onvalue "formula" -offvalue "" -variable ::fics::findopponent(formula)
    grid $w.f.cbformula -column 0 -row 8 -columnspan 2 -sticky ew
    
    ttk::button $w.f.seek -text [::tr "FICSIssueSeek"] -command {
      set range ""
      if {$::fics::findopponent(limitrating) } {
        set range "$::fics::findopponent(rating1)-$::fics::findopponent(rating2)"
      }
      set cmd "seek $::fics::findopponent(initTime) $::fics::findopponent(incTime) $::fics::findopponent(rated) \
          $::fics::findopponent(color) $::fics::findopponent(manual) $::fics::findopponent(formula) $range"
      ::fics::writechan $cmd
      destroy .ficsfindopp
    }
    ttk::button $w.f.cancel -text [::tr "Cancel"] -command "destroy $w"
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
      # if { $::fics::graphon } {
      # .fics.f.bottom.right.offers invoke
      .fics.f.top select 0
      # }
      ::utils::sound::PlaySound sound_move
      # Create a game in an opened base
      if {![sc_base inUse]} {
        sc_base switch clipbase
      }
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
          tk_messageBox -title [::tr "Result"] -icon info -type ok -message "Draw"
        } else {
          tk_messageBox -title [::tr "Result"] -icon info -type ok -message "$res"
        }
        sc_game tags set -result $res
        set ::fics::playing 0
        set ::fics::observedGame -1
        ::gameclock::stop 1
        ::gameclock::stop 2
        updateBoard -pgn
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
      set ans [tk_dialog .challenge [::tr "FICSChallenge"] $line "" 0 [::tr "FICSAccept"] [::tr "FICSDecline"]]
      if {$ans == 0} {
        writechan "accept"
      } else {
        writechan "decline"
      }
    }
    
    # abort request
    if {[string match "* would like to abort the game;*" $line]} {
      set ans [tk_messageBox -title [::tr "Abort"] -icon question -type yesno -message "$line\nDo you accept ?" ]
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
    
    foreach elt [list $w.f.bottom.right.silence $w.f.top.fconsole.f2.send $w.f.bottom.right.games \
        $w.f.bottom.right.findopp $w.f.bottom.right.abort $w.f.bottom.right.draw $w.f.bottom.right.resign $w.f.bottom.right.takeback \
        $w.f.bottom.right.takeback2] {
          $elt configure -state $state
        }
    if {$state == "normal" } {
      $w.f.top add $w.f.top.foffers ;# -sticky nsew -text [::tr "FICSOffers"]
    } else  {
      $w.f.top hide $w.f.top.foffers
    }
  }
  ################################################################################
  #
  ################################################################################
  proc updateConsole {line} {
    set t .fics.f.top.fconsole.f1.console
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
    
    set pos [ lindex [ .fics.f.top.fconsole.f1.ysc get ] 1 ]
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
            .fics.f.top.foffers.c delete game_$idx
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
      # Create a game in an opened base
      if {![sc_base inUse]} {
        sc_base switch clipbase
      }
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
    
    set w .fics.f.top.foffers
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
    
    set w .fics.f.top.foffers
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
  # Handle mouse button 1 on console : observe the selected game
  ################################################################################
  proc consoleClick { x y win } {
    set idx [ $win index @$x,$y ]
    if { [ scan $idx "%d.%d" l c ] != 2 } {
      # should never happen
      return
    }
    set elt [$win get $l.0 $l.end]
    set found 0
    
    if { [llength $elt] > 4} {
      # validate format
      set game [lindex $elt 0]
      set elow [lindex $elt 1]
      set white [lindex $elt 2]
      set elob [lindex $elt 3]
      set black [lindex $elt 4]
      
      if { [ scan $game "%d" tmp ] != 1 || \
            ( [ scan $elow "%d" tmp ] != 1 && $elow != "++++" ) || \
            ( [ scan $elob "%d" tmp ] != 1 && $elob != "++++" ) } {
      } else  {
        set found 1
      }
    }
    
    # Second chance : try to parse "tell relay listgames" (:104 GMxxxx GMyyyyy * B22)
    if { [llength $elt] == 5 && ! $found } {
      if { [ scan [lindex $elt 0] ":%d" game ] == 1 } {
        set white [lindex $elt 1]
        set black [lindex $elt 2]
        set elow "-"
        set elob "-"
        set found 1
      }
    }
    
    if { ! $found } {
      puts "$elt not a valid game"
      return
    }
    
    # warn the user before observing a game because it can interfere with a game played or
    # other that would be disturbed by observing a game
    set ans [tk_messageBox -title "Observe game" -icon question -type yesno \
        -message "Do you want to observe game $game\n$white ($elow) - $black ($elob)  ?" ]
    if { $ans == yes } {
      writechan "unobserve" "echo"
      writechan "observe $game" "echo"
    }
    
  }
  ################################################################################
  # updates the offers view if it is visible
  ################################################################################
  proc tabchanged {} {
    set nb .fics.f.top
    set w .fics.f.top.foffers
    
    if { [ $nb select ] == $w } {
      updateOffers
      set ::fics::graphon 1
    } else  {
      after cancel ::fics::updateOffers
      set ::fics::graphon 0
    }
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

image create photo FICSrelayedgames -format png -data {
  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
  AOOs2H7xibo+AAAAAElFTkSuQmCC
}
image create photo FICSusers -format png -data {
  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
  AAAAAElFTkSuQmCC
}
image create photo FICSexit -format png -data {
  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
}
image create photo FICSdraw -format png -data {
  iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAABmJLR0QA/wD/AP+gvaeTAAAA
  CXBIWXMAAAsTAAALEwEAmpwYAAAAB3RJTUUH2QMEFDo5UKRXHQAAASBJREFUWMPtlN1KAzEQ
  hc/J9qbiHxRfwTdS8AVEfCQFrwRR9Im871K6P92lmyzZdMaLdVEEy1LqlTkQMhBIPk5mDhAV
  FfXfxW2HRVGcWGsnTdNwsViwLEtTFAW990zTlNZas1wuuV6vmec5sywzq9WKVVWxqioCsADm
  OwGoqqnr+vTp5TF3roVzrl/tV926Ft77Xy9/fX47B/C+DWAyxqab61uQHMigfQGCAAnDYTcg
  CZK4vLoY9QWjAFQE1lmICkIICCGgCx5d1+Ho8Bgb2UBFAABJMsFsdja6B8YBqEJUIKJQVfQe
  ECQgIr0TxgAAzOe+d4Dp9KB/6EcHfbedNEiSZP8A9w93OzXhn43hMGr7GMMYRDGIYhDFIIpB
  FBUV9QEJxZl+R43kHQAAAABJRU5ErkJggg==
}
image create photo FICSabort -format png -data {
  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
}
image create photo FICSresign -format png -data {
  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
  AAAAAElFTkSuQmCC
}
image create photo FICSsearch -format png -data {
  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
}
image create photo FICStakeback1 -format png -data {
  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
}
image create photo FICStakeback2 -format png -data {
  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
  iwJ5hqQAAAAASUVORK5CYII=
}
###
### End of file: fics.tcl
###
