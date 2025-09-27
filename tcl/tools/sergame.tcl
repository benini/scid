###
### sergame.tcl: part of Scid.
### Copyright (C) 2007  Pascal Georges
###
################################################################################
# Use new engine interface for serious game and combine a coach engine
################################################################################

namespace eval sergame {
  
  # if true, follow a specific opening
  set _Data(openingMovesList) {}
  set _Data(openingMovesHash) {}
  set _Data(outOfOpening) 0
  set _Data(bookSlot) 2
  set _Data(tacticBlunder) ""
  set _Data(actTacTime) 0
  # list of fen positions played to detect 3 fold repetition
  set _Data(lFen) {}
  
  ################################################################################
  #
  ################################################################################
  proc config {} {
    global ::sergame::_Data ::sergame::options ::sergame::configWin
    
    set w ".configSerGameWin"
    if {[winfo exists $w]} {
      focus $w
      return
    }
    
    win::createDialog $w
    wm title $w "$::tr(configuregame)"
    
    bind $w <F1> { helpWindow SeriousGame }
    setWinLocation $w
    
    ttk::frame $w.fconfig
    ttk::frame $w.fconfig2
    ttk::frame $w.fbuttons
    ttk::labelframe $w.fengines -text "$::tr(Player) - $::tr(Engine)"
    ttk::labelframe $w.coach -text "Coaching"
    ttk::labelframe $w.ftime -text $::tr(TimeMode)
    ttk::labelframe $w.fopening -text $::tr(Opening)
    
    grid $w.fengines -row 0 -column 0 -pady { 0 10 } -sticky nswe -padx { 0 10 }
    grid $w.coach -row 0 -column 1 -pady { 0 10 } -sticky nswe -padx { 0 10 }
    grid $w.fopening -row 1 -column 0 -pady { 0 10 } -sticky nswe -padx { 0 10 }
    grid $w.ftime -row 1 -column 1 -pady { 0 10 } -sticky nswe -padx { 0 10 }
    grid $w.fconfig -row 2 -column 0 -pady { 0 10 } -sticky we -padx { 0 10 }
    grid $w.fconfig2 -row 2 -column 1 -pady { 0 10 } -sticky we -padx { 0 10 }
    grid $w.fbuttons -row 3 -column 1 -sticky se
    
    # builds the list of UCI engines
    ::engineNoWin::createEngineOptionsFrame $w seriousEngine ::sergame::options(engineName) 5 ::sergame::eng_messages
    # ponder
    ttk::checkbutton $w.fengines.ponder -text $::tr(Ponder) -variable ::sergame::options(ponder)
    pack $w.seriousEngine -in $w.fengines -side top -pady 5 -anchor w -padx 4
    pack $w.fengines.ponder -side top -anchor w
    # Engine plays for the upper side
    set _Data(playerColor) [expr {[::board::isFlipped .main.board] ? "black" : "white"}]
    ttk::frame $w.fengines.player
    ttk::label $w.fengines.player.l -text "$::tr(Player) $::tr(GlistColor)"
    ttk::radiobutton $w.fengines.player.w -text $::tr(white) -value "white" -variable ::sergame::_Data(playerColor)
    ttk::radiobutton $w.fengines.player.b -text $::tr(black) -value "black" -variable ::sergame::_Data(playerColor)
    pack $w.fengines.player.l $w.fengines.player.w $w.fengines.player.b -side left
    pack $w.fengines.player -side top -anchor w

    # coach engine
    ttk::frame $w.coach.en
    ttk::checkbutton $w.coach.en.coach -text "$::tr(Engine)" -variable ::sergame::options(useCoachEngine)
    ::utils::tooltip::Set $w.coach.en.coach "Use a separate (strong) engine for coaching if the playing engine is weak."
    ::engineNoWin::createEngineOptionsFrame $w coachEngine ::sergame::options(coachName) 6 ::sergame::eng_messages
    pack $w.coach.en.coach -in $w.coach.en -side left -pady 5 -anchor w -padx 4
    pack $w.coachEngine -in $w.coach.en -side left -pady 5 -anchor w -padx 4
    ttk::frame $w.coach.cb
    ttk::checkbutton $w.coach.cb.coach -text "Bad move warning" -variable ::sergame::options(coachTypeMove)
    ::utils::tooltip::Set $w.coach.cb.coach "Coach warns if player made a bad move. Player can take back this move."
    ttk::checkbutton $w.coach.cb.fullCoach -text "Mark engine blunder" -variable ::sergame::options(coachTypeTactic) \
        -command { if { $::sergame::options(coachTypeTactic) } { set ::sergame::options(useCoachEngine) 1 } }
    ::utils::tooltip::Set $w.coach.cb.fullCoach "Gives a hint (in InfoBar) that engines has blundered. Needs coaching engine."
    pack $w.coach.cb.coach $w.coach.cb.fullCoach -side left -padx 4
    ttk::frame $w.coach.th
    ttk::label $w.coach.th.l -text $::tr(moveblunderthreshold)
    ttk::spinbox $w.coach.th.val -width 3 -from 0.4 -to 5.0 -increment 0.1 -textvariable ::sergame::options(threshold) -validate all -validatecommand { regexp {^[0-9]\.[0-9]$} %P }
    pack $w.coach.th.l $w.coach.th.val -side left -anchor w -padx 4
    ttk::frame $w.coach.ad
    ttk::checkbutton $w.coach.ad.l -text $::tr(limitanalysis) -variable ::sergame::options(isLimitedAnalysisTime)
    ttk::spinbox $w.coach.ad.val -width 3 -from 1 -to 360 -increment 1 -textvariable ::sergame::options(tacTime) -validate all -validatecommand { regexp {^[0-9]$} %P }
    pack $w.coach.ad.l $w.coach.ad.val -side left -anchor w -padx 4
    pack $w.coach.cb $w.coach.th $w.coach.en $w.coach.ad -side top -anchor w -padx 4
    
    ttk::checkbutton $w.fconfig.cbUseBook -text $::tr(UseBook) -variable ::sergame::options(useBook)
    # load book names
    lassign [getBookList $options(bookToUse)] idx tmp
    if { $idx < 0 } {
      $w.fconfig.cbUseBook configure -state disabled
      set options(useBook) 0
    }
    ttk::combobox $w.fconfig.combo -width 12 -values $tmp
    catch { $w.fconfig.combo current $idx }
    
    set row 0
    
    # Time bonus frame
    ttk::frame $w.ftime.timebonus
    pack  $w.ftime.timebonus -side top -fill x
    
    ttk::radiobutton $w.ftime.timebonus.rb1 -text $::tr(TimeBonus) -value "timebonus" -variable ::sergame::options(timeMode)
    grid $w.ftime.timebonus.rb1 -row $row -column 0 -sticky w -rowspan 2
    
    ttk::label $w.ftime.timebonus.whitelabel -text $::tr(White)
    grid $w.ftime.timebonus.whitelabel -row $row -column 1
    ttk::spinbox $w.ftime.timebonus.whitespminutes -background white -width 2 -from 1 -to 120 -increment 1 -validate all -validatecommand { regexp {^[0-9]+$} %P }
    grid $w.ftime.timebonus.whitespminutes -row $row -column 2
    ttk::label $w.ftime.timebonus.whitelminutes -text $::tr(TimeMin)
    grid $w.ftime.timebonus.whitelminutes -row $row -column 3
    ttk::spinbox $w.ftime.timebonus.whitespseconds -background white -width 2 -from 0 -to 60 -increment 1 -validate all -validatecommand { regexp {^[0-9]+$} %P }
    grid $w.ftime.timebonus.whitespseconds -row $row -column 4
    ttk::label $w.ftime.timebonus.whitelseconds -text $::tr(TimeSec)
    grid $w.ftime.timebonus.whitelseconds -row $row -column 5
    
    incr row
    ttk::label $w.ftime.timebonus.blacklabel -text $::tr(Black)
    grid $w.ftime.timebonus.blacklabel -row $row -column 1
    ttk::spinbox $w.ftime.timebonus.blackspminutes -background white -width 2 -from 1 -to 120 -increment 1 -validate all -validatecommand { regexp {^[0-9]+$} %P }
    grid $w.ftime.timebonus.blackspminutes -row $row -column 2
    ttk::label $w.ftime.timebonus.blacklminutes -text $::tr(TimeMin)
    grid $w.ftime.timebonus.blacklminutes -row $row -column 3
    ttk::spinbox $w.ftime.timebonus.blackspseconds -background white -width 2 -from 0 -to 60 -increment 1 -validate all -validatecommand { regexp {^[0-9]+$} %P }
    grid $w.ftime.timebonus.blackspseconds -row $row -column 4
    ttk::label $w.ftime.timebonus.blacklseconds -text $::tr(TimeSec)
    grid $w.ftime.timebonus.blacklseconds -row $row -column 5
    
    $w.ftime.timebonus.whitespminutes set [expr $options(wtime) / (60 * 1000)]
    $w.ftime.timebonus.whitespseconds set [expr $options(winc) /  1000]
    $w.ftime.timebonus.blackspminutes set [expr $options(btime) / (60 * 1000)]
    $w.ftime.timebonus.blackspseconds set [expr $options(binc) /  1000 ]
    
    # Fixed depth
    ttk::frame $w.ftime.depth
    ttk::radiobutton $w.ftime.depth.button -text $::tr(FixedDepth) -value "depth" -variable ::sergame::options(timeMode) -width 16
    ttk::spinbox $w.ftime.depth.value -background white -width 3 -from 1 -to 20 -increment 1 -validate all -validatecommand { regexp {^[0-9]+$} %P }
    $w.ftime.depth.value set $options(depth)
    
    pack $w.ftime.depth -side top -fill x
    pack $w.ftime.depth.button -side left
    pack $w.ftime.depth.value -side left
    
    ttk::frame $w.ftime.nodes
    ttk::radiobutton $w.ftime.nodes.button -text "$::tr(Nodes) (x1000)" -value "nodes" -variable ::sergame::options(timeMode) -width 16
    ttk::spinbox $w.ftime.nodes.value -background white -width 3 -from 5 -to 10000 -increment 5 -validate all -validatecommand { regexp {^[0-9]+$} %P }
    $w.ftime.nodes.value set [ expr $options(nodes) /1000]
    
    pack $w.ftime.nodes -side top -fill x
    pack $w.ftime.nodes.button -side left
    pack $w.ftime.nodes.value -side left
    
    ttk::frame $w.ftime.movetime
    ttk::radiobutton $w.ftime.movetime.button -text $::tr(SecondsPerMove) -value "movetime" -variable ::sergame::options(timeMode) -width 16
    ttk::spinbox $w.ftime.movetime.value -background white -width 3 -from 1 -to 120 -increment 1 -validate all -validatecommand { regexp {^[0-9]+$} %P }
    $w.ftime.movetime.value set [ expr $options(movetime) /1000]
    
    pack $w.ftime.movetime -side top -fill x
    pack $w.ftime.movetime.button -side left
    pack $w.ftime.movetime.value -side left

    pack $w.fconfig.cbUseBook -side top -anchor w
    pack $w.fconfig.combo -side top -anchor w -padx 20 -fill x
    
    # New game or use current position ?
    ttk::checkbutton $w.fconfig2.cbPosition -text $::tr(StartFromCurrentPosition) -variable ::sergame::options(startFromCurrent)
    #Should the evaluation of the position stored in the comment?
    ttk::checkbutton $w.fconfig2.storeEval -text $::tr(AddScoreToShortAnnotations) -variable ::sergame::options(storeEval)
    pack $w.fconfig2.cbPosition $w.fconfig2.storeEval -side top -anchor w
    
    # choose a specific opening
    ttk::checkbutton $w.fopening.cbOpening -text $::tr(SpecificOpening) -variable ::sergame::options(isOpening)
    ttk::frame $w.fopening.fOpeningList
    ttk::treeview $w.fopening.fOpeningList.lbOpening -columns {0} -show {} -selectmode browse \
        -yscrollcommand "$w.fopening.fOpeningList.ybar set"
    $w.fopening.fOpeningList.lbOpening column 0 -width 250
    $w.fopening.fOpeningList.lbOpening configure -height 5
    set idx 0
    foreach o $::sergame::openingList {
        $w.fopening.fOpeningList.lbOpening insert {} end -id $idx -values [list $o]
        incr idx
    }

    $w.fopening.fOpeningList.lbOpening selection set $options(chosenOpening)
    $w.fopening.fOpeningList.lbOpening see $options(chosenOpening)
    
    ttk::scrollbar $w.fopening.fOpeningList.ybar -command "$w.fopening.fOpeningList.lbOpening yview"
    pack $w.fopening.cbOpening -fill x -side top
    pack $w.fopening.fOpeningList.ybar -side right -fill y
    pack $w.fopening.fOpeningList.lbOpening -side left -fill both -expand 1
    pack $w.fopening.fOpeningList -fill both -side top
    
    ttk::button $w.fbuttons.close -text $::tr(Play) -command {
      focus .
      set ::sergame::options(chosenOpening) [.configSerGameWin.fopening.fOpeningList.lbOpening selection]
      if {$::sergame::options(useBook)} {
        set ::sergame::options(bookToUse) [.configSerGameWin.fconfig.combo get]
        if {$::sergame::options(bookToUse) == "" } {
          set ::sergame::options(useBook) 0
        }
      }
      set ::sergame::options(wtime) [expr [.configSerGameWin.ftime.timebonus.whitespminutes get]*1000*60]
      set ::sergame::options(btime) [expr [.configSerGameWin.ftime.timebonus.blackspminutes get]*1000*60]
      set ::sergame::options(winc) [expr [.configSerGameWin.ftime.timebonus.whitespseconds get]*1000]
      set ::sergame::options(binc) [expr [.configSerGameWin.ftime.timebonus.blackspseconds get]*1000]
      set ::sergame::options(fixeddepth) [.configSerGameWin.ftime.depth.value get]
      set ::sergame::options(fixednodes) [expr [.configSerGameWin.ftime.nodes.value get]*1000]
      set ::sergame::options(movetime) [expr [.configSerGameWin.ftime.movetime.value get]*1000]
      set ::sergame::options(depth) [.configSerGameWin.ftime.depth.value get]
      set ::sergame::options(nodes) [expr [.configSerGameWin.ftime.nodes.value get]*1000]
      set ::sergame::options(movetime) [expr [.configSerGameWin.ftime.movetime.value get]*1000]

      bind .configSerGameWin.seriousEngine <Destroy> ""
      destroy .configSerGameWin
      ::sergame::play seriousEngine
    }
    ttk::button $w.fbuttons.cancel -textvar ::tr(Cancel) -command "focus .; destroy $w"
    
    packbuttons right $w.fbuttons.cancel $w.fbuttons.close
    bind $w <Escape> { .configSerGameWin.fbuttons.cancel invoke }
    bind $w <Return> { .configSerGameWin.fbuttons.close invoke }
    bind $w <F1> { helpWindow SeriousGame }
    bind $w <Destroy> ""
    bind $w <Configure> "recordWinSize $w"
    wm resizable $w 0 0
  }
  
  ################################################################################
  #
  ################################################################################
  proc play { engine } {
    global ::sergame::_Data ::sergame::options
    
    set callback [list ::sergame::eng_messages $engine nop]
    if { ! [::engineNoWin::initEngine $engine $options(engineName) $callback] } {
        tk_messageBox -title Scid -icon info -type ok -message "The UCI-Engines could not be started."
        return
    }
    if {$options(isOpening) || !$options(startFromCurrent)} {
      if {[::game::Clear] eq "cancel"} { return }
    }

    set _Data(lFen) {}
    set _Data(prevscore) ""
    set _Data(score) 0.0
    set _Data(ponder) ""
    set _Data(takeback) 0
    
    if {$options(startFromCurrent)} {
      set options(isOpening) 0
    }
    
    # ponder
    set ponder false
    if {$options(ponder)} { set ponder true }
    ::engine::send $engine SetOptions [list {Ponder true}]
    
    # if will follow a specific opening line
    if {$options(isOpening)} {
      set fields [split [lindex $::sergame::openingList $options(chosenOpening)] ":"]
#      set openingName [lindex $fields 0]
      set _Data(openingMoves) [string trim [lindex $fields 1]]
      set _Data(openingMovesList) ""
      set _Data(openingMovesHash) ""
      set _Data(outOfOpening) 0
      foreach m [split $_Data(openingMoves)] {
        # in case of multiple adjacent spaces in opening line
        if {$m =={}} {
          continue
        }
        set p [string trim $m]
        lappend _Data(openingMovesList) [string trim [regsub {^[1-9]+\.} $p ""] ]
      }
      
      lappend _Data(openingMovesHash) [sc_pos hash]
      foreach m  $_Data(openingMovesList) {
        if {[catch {sc_move addSan $m}]} { }
        lappend _Data(openingMovesHash) [sc_pos hash]
      }
      #goto start pos and clear the moves
      sc_move start
      sc_game truncate
    }
    set _Data(engineColor) [expr {$_Data(playerColor) eq "white" ? "black" : "white"}]
    if { (![::board::isFlipped .main.board] && $_Data(playerColor) eq "black") || \
         ([::board::isFlipped .main.board] && $_Data(playerColor) eq "white") } {
             board::flip .main.board
    }

    if {!$options(startFromCurrent)} {
      # create a new game if a DB is opened
      sc_game tags set -event "Serious game"
      sc_game tags set -$_Data(playerColor) "Player"
      sc_game tags set -$_Data(engineColor) "$options(engineName)"
      sc_game tags set -date [::utils::date::today]
      if {$options(timeMode) eq "timebonus"} {
          sc_game tags set -extra [list "TimeControlWhite \"[expr $options(wtime)/60000]+[expr $options(winc)/1000]\"" \
                                   "TimeControlBlack \"[expr $options(btime)/60000]+[expr $options(binc)/1000]\""]
      }
      if { $options(coachTypeMove) || $options(coachTypeTactic) } {
          sc_game tags set -event "Coached game"
          set co "Coached Game: "
          if { $options(coachTypeMove) } { append co "Bad Move Warning; " }
          if { $options(coachTypeTactic) } { append co "Engine Blunder Information; " }
          append co "Blunder Threshold: $options(threshold)"
          sc_pos setComment $co
      }
    }

    set _Data(waitPlayerMove) 0
    set _Data(wentOutOfBook) 0
    ::setPlayMode "::sergame::callback"
    ::notify::GameChanged

    if { $options(coachTypeTactic) || $options(useCoachEngine) } {
        set options(useCoachEngine) 1
        set callback [list ::sergame::coachEng_messages coachEngine nop]
        if { ! [::engineNoWin::initEngine coachEngine $::sergame::options(coachName) $callback] } {
            set options(useCoachEngine) 0
        }
    }
    clocks init
    clocks start

    ::sergame::playLoop
  }

  proc ::sergame::eng_messages {id w msg} {
      global ::sergame::_Data ::sergame::options
      lassign $msg msgType msgData
      switch $msgType {
          "InfoConfig" {
              if { ! [winfo exists $w] } { return }
              set msgData [lindex $msgData 2]
              ::engineNoWin::initEngineOptions $id $w $msgData
          }
          "InfoPV" {
              if { ! $options(useCoachEngine) } {
                  # no coach engine then use score from playing engine
                  lassign $msgData multipv depth seldepth nodes nps hashfull tbhits time score score_type score_wdl pv
                  if { $multipv == 1 } {
                      set _Data(score) [expr $score / 100.0]
                      if { $score_type eq "mate" } {
                          if { $score > 0 } {
                              set _Data(score) 128.0
                          } else {
                              set _Data(score) -128.0
                          }
                      }
                  }
              }
          }
          "InfoBestMove" {
              lassign $msgData _Data(bestmove) ponder _Data(ponder)
          }
          "InfoDisconnected" {
              lassign $msgData errorMsg
              if {$errorMsg eq ""} { set errorMsg "The connection with the engine terminated unexpectedly." }
              tk_messageBox -icon warning -type ok -parent . -message $errorMsg
              ::sergame::abortGame
          }
      }
  }
  proc ::sergame::coachEng_messages {id w msg} {
      global ::sergame::_Data ::sergame::options
      lassign $msg msgType msgData
      switch $msgType {
          "InfoConfig" {
              if { ! [winfo exists $w] } { return }
              set msgData [lindex $msgData 2]
              ::engineNoWin::initEngineOptions $id $w $msgData
          }
          "InfoPV" {
              lassign $msgData multipv depth seldepth nodes nps hashfull tbhits time score score_type score_wdl pv
              if { $multipv == 1 } {
                  set _Data(bestCoachmove) [lrange $pv 0 0]
                  set _Data(score) [expr $score / 100.0]
                  if { $score_type eq "mate" } {
                      if { $score > 0 } {
                          set _Data(score) 128.0
                      } else {
                          set _Data(score) -128.0
                      }
                  }
              }
          }
          "InfoBestMove" {
              lassign $msgData _Data(bestCoachmove)
          }
          "InfoDisconnected" {
              lassign $msgData errorMsg
              if {$errorMsg eq ""} { set errorMsg "The connection with the engine terminated unexpectedly." }
              tk_messageBox -icon warning -type ok -parent . -message $errorMsg
              ::sergame::abortGame
          }
      }
  }

  proc callback {cmd args} {
    global ::sergame::_Data
    switch $cmd {
        premove { # TODO: currently we just return true if it is the engine turn.
            return [expr { ! $_Data(waitPlayerMove) }]
        }
        stop { ::sergame::abortGame }
    }
    return 0
  }

  proc setResult {} {
      set w .askResult
      ::win::createDialog $w
      wm resizable $w 0 0
      wm title $w "Scid: [tr Result]"
      ttk::button $w.win -text "  1-0  " -command { sc_game tags set -result 1; destroy .askResult }
      ttk::button $w.loss -text "  0-1  " -command { sc_game tags set -result 0; destroy .askResult }
      ttk::button $w.draw -text "1/2-1/2" -command { sc_game tags set -result =; destroy .askResult }
      ttk::button $w.undef -text "   *   " -command { sc_game tags set -result *; destroy .askResult }
      pack $w.win $w.draw $w.loss $w.undef -side left -padx 10
      tk::PlaceWindow $w
      grab $w
      tkwait window $w
  }

  proc abortGame { } {
    global ::sergame::_Data ::sergame::options
    ::setPlayMode ""
    after cancel ::sergame::playLoop
    clocks stop
    set _Data(lFen) {}
    ::engine::send seriousEngine StopGo
    ::engineNoWin::closeEngine seriousEngine
    set _Data(bestmove) "abort"
    if { $options(useCoachEngine) } {
        ::engine::send coachEngine StopGo
        ::engineNoWin::closeEngine coachEngine
    }
    # if { [sc_game tag get Result] eq "*" } { setResult }
    ::notify::GameChanged
  }

  proc clocks {cmd} {
    global ::sergame::options
    if {$options(timeMode) != "timebonus"} { return }

    switch $cmd {
      init {
          ::gameclock::new "" 1
          ::gameclock::new "" 2
          ::gameclock::setSec 1 [expr 0 - $options(wtime)/1000]
          ::gameclock::setSec 2 [expr 0 - $options(btime)/1000]
      }
      start {
          if { [sc_pos side] == "white" } {
            ::gameclock::start 1
          } else {
            ::gameclock::start 2
          }
      }
      stop {
          ::gameclock::stop 1
          ::gameclock::stop 2
      }
      toggle {
          if {[::gameclock::stop 1]} {
            ::gameclock::add 1 [expr $options(winc)/1000]
            ::gameclock::storeTimeComment 1
            ::gameclock::start 2
          } elseif {[::gameclock::stop 2]} {
            ::gameclock::add 2 [expr $options(binc)/1000]
            ::gameclock::storeTimeComment 2
            ::gameclock::start 1
          }
          ::notify::PosChanged -pgn
      }
    }
  }

  proc takeBack {takebackClockW takebackClockB} {
    global ::sergame::_Data
    sc_pos setComment "Player takes back this move"
    sc_move back 1
    set _Data(takeback) 1
    set _Data(prevscore) ""
    set _Data(score) 0.0
    if {$takebackClockW != ""} {
      ::gameclock::setSec 1 [expr 0 - $takebackClockW]
      ::gameclock::setSec 2 [expr 0 - $takebackClockB]
      clocks start
    }
    ::notify::PosChanged -pgn
  }
  
  ################################################################################
  # returns true if last move is a mate and stops clocks
  ################################################################################
  proc endOfGame {} {
    global ::sergame::_Data
    if { [string index [sc_game info previousMove] end ] == "#"} {
      tk_messageBox -type ok -message "This is Mate!" -parent .main -icon info
      set result 0
      if { [sc_pos side] == "black" } { set result 1 }
      sc_game tags set -result $result
      ::sergame::abortGame
      return 1
    }
    return 0
  }

  # start playing engine: ponder must be "" or "ponder"
  proc startEngine { ponder } {
      global ::sergame::_Data ::sergame::options
      if {$options(timeMode) == "timebonus"} {
        set wtime [expr [::gameclock::getSec 1] * 1000 ]
        set btime [expr [::gameclock::getSec 2] * 1000 ]
        set parameter "$ponder wtime $wtime btime $btime winc $options(winc) binc $options(binc)"
      } elseif {$options(timeMode) == "depth"} {
        set parameter "$ponder depth $options(fixeddepth)"
      } elseif {$options(timeMode) == "movetime"} {
        set parameter "$ponder movetime $options(movetime)"
      } elseif {$options(timeMode) == "nodes"} {
        set parameter "$ponder nodes $options(fixednodes)"
      }
      if { $ponder ne "" } { set ponder "moves $options(ponder)" }
      ::engine::send seriousEngine Go [list "position fen [sc_pos fen] $ponder" $parameter]
  }

  proc checkBlunder { delta } {
      global ::sergame::options
      set ret ""
      if { $delta >= $options(threshold) } {
          if {$delta > $::informant("?!") } { set ret [list "?!" "DubiousMovePlayedTakeBack"] }
          if {$delta > $::informant("?") } { set ret [list "?" "WeakMovePlayedTakeBack"] }
          if {$delta > $::informant("??") } { set ret [list "??" "BadMovePlayedTakeBack"] }
      }
      return $ret
  }
  proc checkEngineBlunder { } {
      global ::sergame::_Data ::sergame::options
      set delta [expr $_Data(score) + $_Data(prevscore)]
      if { [sc_pos side] == $_Data(engineColor) } { set delta [expr 0.0 - $delta] }
      lassign [checkBlunder $delta] _Data(tacticBlunder)
      if { $_Data(tacticBlunder) ne "" } {
          if { $_Data(engineColor) eq "white" } {
              set from $_Data(prevscore)
              set to [expr 0.0 - $_Data(score)]
          } else {
              set from [expr 0.0 - $_Data(prevscore)]
              set to $_Data(score)
          }
          ::board::setInfoAlert .main.board "Engine blunders: $_Data(tacticBlunder) $from -> $to" "Show move" red \
              {::board::setInfoAlert .main.board "Try move $::sergame::_Data(bestCoachmove) Playing..." [tr Stop] red {{*}$::playMode stop}}
      }
  }

  ################################################################################
  #
  ################################################################################
  proc playLoop { } {
    global ::sergame::_Data ::sergame::options
    
    after cancel ::sergame::playLoop
    
    if { [::sergame::endOfGame] } { return }
    
    if { [sc_pos side] != $_Data(engineColor) } {
      # wait until player has moved
      set _Data(waitPlayerMove) 1
      after 1000 ::sergame::playLoop
      if { $options(useCoachEngine) && $options(coachTypeTactic) && $_Data(actTacTime) > 0 && $_Data(prevscore) != "" } {
          #check for engine blunder with coach engine
          incr _Data(actTacTime) -1
          if { $options(isLimitedAnalysisTime) && ! $_Data(actTacTime) } {
              # make sure we have a move and evaluation from coach engine 
              while { $_Data(bestCoachmove) eq "" } { vwait ::sergame::_Data(bestCoachmove) }
              ::engine::send coachEngine StopGo
          } else {
              checkEngineBlunder
          }
      }
      return
    }

    if { $_Data(takeback) } {
        # player has taken back his move and played an new move, make new move mainline and old move to var
        if {[info exists ::guessedAddMove]} {
            sc_game undo; addMoveEx [lindex $::guessedAddMove 1] mainline
            unset ::guessedAddMove
        }
        set _Data(takeback) 0
    }

    if { $options(useCoachEngine) } {
        ::engine::send coachEngine StopGo
        if { $_Data(tacticBlunder) ne "" } {
            # engine blundered, add nag and correct eval comment
            sc_move back
            sc_pos addNag $_Data(tacticBlunder)
            if { $options(storeEval) == 1 } {
                set score $_Data(score)
                if { $_Data(engineColor) eq "white" } { set score [expr 0.0 - $score] }
                storeEvalComment $score
            }
            sc_move forward
        }
    }
    
    set takebackClockW ""
    set takebackClockB ""
    if {$_Data(waitPlayerMove)} {
      # The player moved
      set _Data(waitPlayerMove) 0
      if {$options(timeMode) == "timebonus"} {
        set takebackClockW [::gameclock::getSec 1]
        set takebackClockB [::gameclock::getSec 2]
        clocks toggle
      }
      if { [repetition] } { [return }
    }
    
    # make a move corresponding to a specific opening, (it is engine's turn)
    if {$options(isOpening) && !$_Data(outOfOpening)} {
      set index 0
      # Warn if the user went out of the opening line chosen
      if { !$_Data(outOfOpening) } {
        set ply [ expr [sc_pos moveNumber] * 2 - 1]
        if { [sc_pos side] == "white" } {
          set ply [expr $ply - 1]
        }
        
        if { [lsearch $_Data(openingMovesHash) [sc_pos hash]] == -1 && [llength $_Data(openingMovesList)] >= $ply} {
          clocks stop
          set answer [tk_messageBox -icon question -parent .main -title $::tr(OutOfOpening) -type yesno \
              -message "$::tr(NotFollowedLine) $_Data(openingMoves)\n $::tr(DoYouWantContinue)" ]
          if {$answer == no} {
            takeBack $takebackClockW $takebackClockB
            after 1000 ::sergame::playLoop
            return
          }  else  {
            set _Data(outOfOpening) 1
          }
          clocks start
        }
      }
      
      set hpos [sc_pos hash]
      # Find a corresponding position in the opening line
      set length [llength $_Data(openingMovesHash)]
      for {set i 0}   { $i < [expr $length-1] } { incr i } {
        set h [lindex $_Data(openingMovesHash) $i]
        if {$h == $hpos} {
          set index [lsearch $_Data(openingMovesHash) $h]
          set move [lindex $_Data(openingMovesList) $index]
          # play the move
          set action "replace"
          if {![sc_pos isAt vend]} { set action [confirmReplaceMove] }
          if {$action == "replace"} {
            if {[catch {sc_move addSan $move}]} {}
          } elseif {$action == "var"} {
            sc_var create
            if {[catch {sc_move addSan $move}]} {}
          } elseif {$action == "mainline"} {
            sc_var create
            if {[catch {sc_move addSan $move}]} {}
            sc_var promote
            sc_move forward 1
          }
          
          clocks toggle
          updateBoard -pgn -animate
          if { ! [repetition] } {
              after 1000 ::sergame::playLoop
          }
          return
        }
      }
    }
    # -------------------------------------------------------------
    # use a book
    if {$options(useBook) && ! $_Data(wentOutOfBook)} {
      set move [ ::book::getMove $options(bookToUse) [sc_pos fen] $_Data(bookSlot)]
      if {$move == ""} {
        set _Data(wentOutOfBook) 1
      } else  {
        sc_move addSan $move
        ::utils::sound::AnnounceNewMove $move
        # we made a book move so assume a score = 0
        set _Data(prevscore) ""
        clocks toggle
        updateBoard -pgn -animate
        if { ! [repetition] } {
            after 1000 ::sergame::playLoop
        }
        return
      }
    }
    # -------------------------------------------------------------
    # check if the engine pondered on the right move
    if { $options(ponder) && $_Data(ponder) ne "" && $_Data(ponder) == [sc_game info previousMoveUCI]} {
      ::engine::rawsend seriousEngine "ponderhit"
    } else {
      if { $options(ponder) } { ::engine::send seriousEngine StopGo }
      startEngine ""
    }
    if { $options(useCoachEngine) } {
        set _Data(bestCoachmove) ""
        ::engine::send coachEngine Go [list "position fen [sc_pos fen]" "infinite"]
    }
    
    set _Data(bestmove) ""
    vwait ::sergame::_Data(bestmove)
    if { $options(useCoachEngine) } {
        # make sure we have a move and evaluation from coach engine 
        while { $_Data(bestCoachmove) eq "" } { vwait ::sergame::_Data(bestCoachmove) }
        ::engine::send coachEngine StopGo
    }
    
    # -------------------------------------------------------------
    # if weak move detected, propose the user to take back
    if { $options(coachTypeMove) && $_Data(prevscore) != "" } {
      set delta [expr $_Data(score) - $_Data(prevscore)]
      if { [sc_pos side] != $_Data(engineColor) } { set delta [expr 0.0 - $delta] }
      lassign [checkBlunder $delta] nop tBlunder
      if {$tBlunder ne ""} {
        clocks stop
        set prevScore $_Data(prevscore)
        set actScore $_Data(score)
        if { $_Data(playerColor) eq "white" } {
            set prevScore [expr 0.0 - $prevScore]
            set actScore [expr 0.0 - $actScore]
        }
        set answer [tk_messageBox -icon question -parent .main -title "Scid" -type yesno -message "$::tr($tBlunder)\n$prevScore -> $actScore" ]
        if {$answer == yes} {
          takeBack $takebackClockW $takebackClockB
          after 1000 ::sergame::playLoop
          return
        }
        clocks start
      }
    }
    
    # -------------------------------------------------------------
    if { $_Data(bestmove) == "abort" } {
      return
    }
    
    sc_move addSan $_Data(bestmove)
    ::utils::sound::AnnounceNewMove $_Data(bestmove)
    set _Data(prevscore) $_Data(score)
    if { $options(storeEval) == 1 } {
      set score $_Data(score)
      if { $_Data(engineColor) eq "black" } { set score [expr 0.0 - $score] }
      storeEvalComment $score
    }
    updateBoard -pgn -animate
    if { [repetition] } { return }
    
    clocks toggle

    # ponder mode (the engine just played its move)
    if {$options(ponder) } { startEngine ponder }
    
    if { $options(useCoachEngine) } {
        set _Data(actTacTime) $options(tacTime)
        set _Data(bestCoachmove) ""
        ::engine::send coachEngine Go [list "position fen [sc_pos fen]" "infinite"]
    }
    after 1000 ::sergame::playLoop
  }
  ################################################################################
  #   add current position for 3fold repetition detection and returns 1 if
  # the position is a repetition
  ################################################################################
  proc repetition {} {
    global ::sergame::_Data
    lassign [checkRepetition $_Data(lFen)] isRepetition _Data(lFen)
    if { $isRepetition } {
      tk_messageBox -type ok -message $::tr(Draw) -parent .main -icon info
      sc_game tags set -result =
      ::sergame::abortGame
      return 1
    }
    return 0
  }
  ################################################################################
  #
  ################################################################################
  set openingList [ list \
      "$::tr(Reti): 1.Nf3" \
      "$::tr(English): 1.c4" \
      "$::tr(d4Nf6Miscellaneous): 1.d4 Nf6" \
      "$::tr(Trompowsky): 1.d4 Nf6 2.Bg5" \
      "$::tr(Budapest): 1.d4 Nf6 2.c4 e5" \
      "$::tr(OldIndian): 1.d4 Nf6 2.c4 d6" \
      "$::tr(BenkoGambit): 1.d4 Nf6 2.c4 c5 3.d5 b5" \
      "$::tr(ModernBenoni): 1.d4 Nf6 2.c4 c5 3.d5 e6" \
      "$::tr(DutchDefence): 1.d4 f5" \
      "1.e4" \
      "$::tr(Scandinavian): 1.e4 d5" \
      "$::tr(AlekhineDefence): 1.e4 Nf6" \
      "$::tr(Pirc): 1.e4 d6" \
      "$::tr(CaroKann): 1.e4 c6" \
      "$::tr(CaroKannAdvance): 1.e4 c6 2.d4 d5 3.e5" \
      "$::tr(Sicilian): 1.e4 c5" \
      "$::tr(SicilianAlapin): 1.e4 c5 2.c3" \
      "$::tr(SicilianClosed): 1.e4 c5 2.Nc3" \
      "$::tr(Sicilian): 1.e4 c5 2.Nf3 Nc6" \
      "$::tr(Sicilian): 1.e4 c5 2.Nf3 e6" \
      "$::tr(SicilianRauzer): 1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 Nc6" \
      "$::tr(SicilianDragon): 1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 g6 " \
      "$::tr(SicilianScheveningen): 1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 e6" \
      "$::tr(SicilianNajdorf): 1.e4 c5 2.Nf3 d6 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 a6" \
      "$::tr(OpenGame): 1.e4 e5" \
      "$::tr(Vienna): 1.e4 e5 2.Nc3" \
      "$::tr(KingsGambit): 1.e4 e5 2.f4" \
      "$::tr(RussianGame): 1.e4 e5 2.Nf3 Nf6" \
      "$::tr(OpenGame): 1.e4 e5 2.Nf3 Nc6" \
      "$::tr(ItalianTwoKnights): 1.e4 e5 2.Nf3 Nc6 3.Bc4" \
      "$::tr(Spanish): 1.e4 e5 2.Nf3 Nc6 3.Bb5" \
      "$::tr(SpanishExchange): 1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Bxc6" \
      "$::tr(SpanishOpen): 1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4 Nf6 5.O-O Nxe4" \
      "$::tr(SpanishClosed): 1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4 Nf6 5.O-O Be7" \
      "$::tr(FrenchDefence): 1.e4 e6" \
      "$::tr(FrenchAdvance): 1.e4 e6 2.d4 d5 3.e5" \
      "$::tr(FrenchTarrasch): 1.e4 e6 2.d4 d5 3.Nd2" \
      "$::tr(FrenchWinawer): 1.e4 e6 2.d4 d5 3.Nc3 Bb4" \
      "$::tr(FrenchExchange): 1.e4 e6 2.d4 d5 3.exd5 exd5" \
      "$::tr(QueensPawn): 1.d4 d5" \
      "$::tr(Slav): 1.d4 d5 2.c4 c6" \
      "$::tr(QGA): 1.d4 d5 2.c4 dxc4" \
      "$::tr(QGD): 1.d4 d5 2.c4 e6" \
      "$::tr(QGDExchange): 1.d4 d5 2.c4 e6 3.cxd5 exd5" \
      "$::tr(SemiSlav): 1.d4 d5 2.c4 e6 3.Nc3 Nf6 4.Nf3 c6" \
      "$::tr(QGDwithBg5): 1.d4 d5 2.c4 e6 3.Nc3 Nf6 4.Bg5" \
      "$::tr(QGDOrthodox): 1.d4 d5 2.c4 e6 3.Nc3 Nf6 4.Bg5 Be7 5.e3 O-O 6.Nf3 Nbd7" \
      "$::tr(Grunfeld): 1.d4 Nf6 2.c4 g6 3.Nc3 d5" \
      "$::tr(GrunfeldExchange): 1.d4 Nf6 2.c4 g6 3.Nc3 d5 4.cxd5" \
      "$::tr(GrunfeldRussian): 1.d4 Nf6 2.c4 g6 3.Nc3 d5 4.Nf3 Bg7 5.Qb3" \
      "$::tr(Catalan): 1.d4 Nf6 2.c4 e6 3.g3 " \
      "$::tr(CatalanOpen): 1.d4 Nf6 2.c4 e6 3.g3 d5 4.Bg2 dxc4" \
      "$::tr(CatalanClosed): 1.d4 Nf6 2.c4 e6 3.g3 d5 4.Bg2 Be7" \
      "$::tr(QueensIndian): 1.d4 Nf6 2.c4 e6 3.Nf3 b6" \
      "$::tr(NimzoIndian): 1.d4 Nf6 2.c4 e6 3.Nc3 Bb4" \
      "$::tr(NimzoIndianClassical): 1.d4 Nf6 2.c4 e6 3.Nc3 Bb4 4.Qc2" \
      "$::tr(NimzoIndianRubinstein): 1.d4 Nf6 2.c4 e6 3.Nc3 Bb4 4.e3" \
      "$::tr(KingsIndian): 1.d4 Nf6 2.c4 g6" \
      "$::tr(KingsIndianSamisch): 1.d4 Nf6 2.c4 g6 4.e4 d6 5.f3" \
      "$::tr(KingsIndianMainLine): 1.d4 Nf6 2.c4 g6 4.e4 d6 5.Nf3" \
      ]
}
###
### End of file: sergame.tcl
###
