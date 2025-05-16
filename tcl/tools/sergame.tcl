###
### sergame.tcl: part of Scid.
### Copyright (C) 2007  Pascal Georges
###
################################################################################
# Use new engine interface for serious game and combine a coach engine
################################################################################

namespace eval sergame {
  
  # DEBUG
  set ::sergame::data(log_stdout) 0
  
  # if true, follow a specific opening
  set openingMovesList {}
  set openingMovesHash {}
  set outOfOpening 0
  set bookSlot 2
  set actTacTime 0
  set isLimitedAnalysisTime 1
  # list of fen positions played to detect 3 fold repetition
  set lFen {}
  
  ################################################################################
  #
  ################################################################################
  proc config {} {
    global ::sergame::configWin ::sergame::chosenOpening
    
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
    ttk::labelframe $w.fengines -text $::tr(Engine)
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
    ::engineNoWin::createEngineOptionsFrame $w seriousEngine ::sergame::engineName 5 ::sergame::eng_messages
    # ponder
    ttk::checkbutton $w.fengines.ponder -text $::tr(Ponder) -variable ::sergame::ponder
    pack $w.seriousEngine -in $w.fengines -side top -pady 5 -anchor w -padx 4
    pack $w.fengines.ponder -side top -anchor w

    # coach engine
    ttk::frame $w.coach.en
    ttk::checkbutton $w.coach.en.coach -text "$::tr(Engine)" -variable ::sergame::useCoachEngine
    ::utils::tooltip::Set $w.coach.en.coach "Use a separate (strong) engine for coaching if the playing engine is weak."
    ::engineNoWin::createEngineOptionsFrame $w coachEngine ::sergame::coachName 6 ::sergame::eng_messages
    pack $w.coach.en.coach -in $w.coach.en -side left -pady 5 -anchor w -padx 4
    pack $w.coachEngine -in $w.coach.en -side left -pady 5 -anchor w -padx 4
    ttk::frame $w.coach.cb
    ttk::checkbutton $w.coach.cb.coach -text "Bad move warning" -variable ::sergame::coachTypeMove
    ::utils::tooltip::Set $w.coach.cb.coach "Coach warns if player made a bad move. Player can take back this move."
    ttk::checkbutton $w.coach.cb.fullCoach -text "Mark engine blunder" -variable ::sergame::coachTypeTactic \
        -command { if { $::sergame::coachTypeTactic } { set ::sergame::useCoachEngine 1 } }
    ::utils::tooltip::Set $w.coach.cb.fullCoach "Gives a hint (in InfoBar) that engines has blundered. Needs coaching engine."
    pack $w.coach.cb.coach $w.coach.cb.fullCoach -side left -padx 4
    ttk::frame $w.coach.th
    ttk::label $w.coach.th.l -text $::tr(moveblunderthreshold)
    ttk::spinbox $w.coach.th.val -width 3 -from 0.4 -to 5.0 -increment 0.1 -textvariable ::sergame::threshold -validate all -validatecommand { regexp {^[0-9]\.[0-9]$} %P }
    pack $w.coach.th.l $w.coach.th.val -side left -anchor w -padx 4
    ttk::frame $w.coach.ad
    ttk::checkbutton $w.coach.ad.l -text $::tr(limitanalysis) -variable ::sergame::isLimitedAnalysisTime
    ttk::spinbox $w.coach.ad.val -width 3 -from 1 -to 360 -increment 1 -textvariable ::sergame::tacTime -validate all -validatecommand { regexp {^[0-9]$} %P }
    pack $w.coach.ad.l $w.coach.ad.val -side left -anchor w -padx 4
    pack $w.coach.cb $w.coach.th $w.coach.en $w.coach.ad -side top -anchor w -padx 4
    
    # load book names
    ttk::checkbutton $w.fconfig.cbUseBook -text $::tr(UseBook) -variable ::sergame::useBook
    set bookPath $::scidBooksDir
    set bookList [ lsort -dictionary [ glob -nocomplain -directory $bookPath *.bin ] ]
    if { [llength $bookList] == 0 } {
      $w.fconfig.cbUseBook configure -state disabled
      set ::sergame::useBook 0
    }
    set i 0
    set idx 0
    set tmp {}
    foreach file  $bookList {
      lappend tmp [ file tail $file ]
      if { $::sergame::bookToUse == [ file tail $file ]} {
        set idx $i
      }
      incr i
    }
    
    ttk::combobox $w.fconfig.combo -width 12 -values $tmp
    catch { ch$w.fconfig.combo current $idx }
    
    set row 0
    
    # Time bonus frame
    ttk::frame $w.ftime.timebonus
    pack  $w.ftime.timebonus -side top -fill x
    
    ttk::radiobutton $w.ftime.timebonus.rb1 -text $::tr(TimeBonus) -value "timebonus" -variable ::sergame::timeMode
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
    
    $w.ftime.timebonus.whitespminutes set [expr $::sergame::data(wtime) / (60 * 1000)]
    $w.ftime.timebonus.whitespseconds set [expr $::sergame::data(winc) /  1000]
    $w.ftime.timebonus.blackspminutes set [expr $::sergame::data(btime) / (60 * 1000)]
    $w.ftime.timebonus.blackspseconds set [expr $::sergame::data(binc) /  1000 ]
    
    # Fixed depth
    ttk::frame $w.ftime.depth
    ttk::radiobutton $w.ftime.depth.button -text $::tr(FixedDepth) -value "depth" -variable ::sergame::timeMode -width 16
    ttk::spinbox $w.ftime.depth.value -background white -width 3 -from 1 -to 20 -increment 1 -validate all -validatecommand { regexp {^[0-9]+$} %P }
    $w.ftime.depth.value set $::sergame::depth
    
    pack $w.ftime.depth -side top -fill x
    pack $w.ftime.depth.button -side left
    pack $w.ftime.depth.value -side left
    
    ttk::frame $w.ftime.nodes
    ttk::radiobutton $w.ftime.nodes.button -text "$::tr(Nodes) (x1000)" -value "nodes" -variable ::sergame::timeMode  -width 16
    ttk::spinbox $w.ftime.nodes.value -background white -width 3 -from 5 -to 10000 -increment 5 -validate all -validatecommand { regexp {^[0-9]+$} %P }
    $w.ftime.nodes.value set [ expr $::sergame::nodes /1000]
    
    pack $w.ftime.nodes -side top -fill x
    pack $w.ftime.nodes.button -side left
    pack $w.ftime.nodes.value -side left
    
    ttk::frame $w.ftime.movetime
    ttk::radiobutton $w.ftime.movetime.button -text $::tr(SecondsPerMove) -value "movetime" -variable ::sergame::timeMode -width 16
    ttk::spinbox $w.ftime.movetime.value -background white -width 3 -from 1 -to 120 -increment 1 -validate all -validatecommand { regexp {^[0-9]+$} %P }
    $w.ftime.movetime.value set [ expr $::sergame::movetime /1000]
    
    pack $w.ftime.movetime -side top -fill x
    pack $w.ftime.movetime.button -side left
    pack $w.ftime.movetime.value -side left

    pack $w.fconfig.cbUseBook -side top -anchor w
    pack $w.fconfig.combo -side top -anchor w -padx 20 -fill x
    
    # New game or use current position ?
    ttk::checkbutton $w.fconfig2.cbPosition -text $::tr(StartFromCurrentPosition) -variable ::sergame::startFromCurrent
    #Should the evaluation of the position stored in the comment?
    ttk::checkbutton $w.fconfig2.storeEval -text $::tr(AddScoreToShortAnnotations) -variable ::sergame::storeEval
    pack $w.fconfig2.cbPosition $w.fconfig2.storeEval -side top -anchor w
    
    # choose a specific opening
    ttk::checkbutton $w.fopening.cbOpening -text $::tr(SpecificOpening) -variable ::sergame::isOpening
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

    $w.fopening.fOpeningList.lbOpening selection set $::sergame::chosenOpening
    $w.fopening.fOpeningList.lbOpening see $::sergame::chosenOpening
    
    ttk::scrollbar $w.fopening.fOpeningList.ybar -command "$w.fopening.fOpeningList.lbOpening yview"
    pack $w.fopening.cbOpening -fill x -side top
    pack $w.fopening.fOpeningList.ybar -side right -fill y
    pack $w.fopening.fOpeningList.lbOpening -side left -fill both -expand 1
    pack $w.fopening.fOpeningList -fill both -side top
    
    ttk::button $w.fbuttons.close -text $::tr(Play) -command {
      focus .
      set ::sergame::chosenOpening [.configSerGameWin.fopening.fOpeningList.lbOpening selection]
      if {$::sergame::useBook} {
        set ::sergame::bookToUse [.configSerGameWin.fconfig.combo get]
        if {$::sergame::bookToUse == "" } {
          set ::sergame::useBook 0
        }
      }
      set ::sergame::data(wtime) [expr [.configSerGameWin.ftime.timebonus.whitespminutes get]*1000*60]
      set ::sergame::data(btime) [expr [.configSerGameWin.ftime.timebonus.blackspminutes get]*1000*60]
      set ::sergame::data(winc) [expr [.configSerGameWin.ftime.timebonus.whitespseconds get]*1000]
      set ::sergame::data(binc) [expr [.configSerGameWin.ftime.timebonus.blackspseconds get]*1000]
      set ::sergame::data(fixeddepth) [.configSerGameWin.ftime.depth.value get]
      set ::sergame::data(fixednodes) [expr [.configSerGameWin.ftime.nodes.value get]*1000]
      set ::sergame::data(movetime) [expr [.configSerGameWin.ftime.movetime.value get]*1000]
      set ::sergame::depth [.configSerGameWin.ftime.depth.value get]
      set ::sergame::nodes [expr [.configSerGameWin.ftime.nodes.value get]*1000]
      set ::sergame::movetime [expr [.configSerGameWin.ftime.movetime.value get]*1000]

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
    global ::sergame::chosenOpening ::sergame::isOpening ::sergame::openingList ::sergame::openingMovesList \
        ::sergame::openingMovesHash ::sergame::openingMoves ::sergame::outOfOpening
    
    set callback [list ::sergame::eng_messages $engine nop]
    if { ! [::engineNoWin::initEngine $engine $::sergame::engineName $callback] } {
        tk_messageBox -title Scid -icon info -type ok -message "The UCI-Engines could not be started."
        return
    }
    if {$::sergame::isOpening || !$::sergame::startFromCurrent} {
      if {[::game::Clear] eq "cancel"} { return }
    }

    set ::sergame::lFen {}
    set ::sergame::data(prevscore) ""
    set ::sergame::data(score) 0.0
    set ::sergame::data(ponder) ""
    
    if {$::sergame::startFromCurrent} {
      set isOpening 0
    }
    
    # ponder
    set ponder false
    if {$::sergame::ponder} { set ponder true }
    ::engine::send $engine SetOptions [list {Ponder true}]
    
    # if will follow a specific opening line
    if {$isOpening} {
      set fields [split [lindex $openingList $chosenOpening] ":"]
      set openingName [lindex $fields 0]
      set openingMoves [string trim [lindex $fields 1]]
      set openingMovesList ""
      set openingMovesHash ""
      set outOfOpening 0
      foreach m [split $openingMoves] {
        # in case of multiple adjacent spaces in opening line
        if {$m =={}} {
          continue
        }
        set p [string trim $m]
        lappend openingMovesList [string trim [regsub {^[1-9]+\.} $p ""] ]
      }
      
      lappend openingMovesHash [sc_pos hash]
      foreach m  $openingMovesList {
        if {[catch {sc_move addSan $m}]} { }
        lappend openingMovesHash [sc_pos hash]
      }
      #goto start pos and clear the moves
      sc_move start
      sc_game truncate
    }

    # Engine plays for the upper side
    if {[::board::isFlipped .main.board]} {
      set ::sergame::playerColor "black"
      set ::sergame::engineColor "white"
    } else {
      set ::sergame::playerColor "white"
      set ::sergame::engineColor "black"
    }

    if {!$::sergame::startFromCurrent} {
      # create a new game if a DB is opened
      sc_game tags set -event "Serious game"
      sc_game tags set -$::sergame::playerColor "Player"
      sc_game tags set -$::sergame::engineColor "$::sergame::engineName"
      sc_game tags set -date [::utils::date::today]
      if {$::sergame::timeMode eq "timebonus"} {
          sc_game tags set -extra [list "TimeControlWhite \"[expr $::sergame::data(wtime)/60000]+[expr $::sergame::data(winc)/1000]\"" \
                                   "TimeControlBlack \"[expr $::sergame::data(btime)/60000]+[expr $::sergame::data(binc)/1000]\""]
      }
      if { $::sergame::coachTypeMove || $::sergame::coachTypeTactic } {
          sc_game tags set -event "Coached game"
          set co "Coached Game: "
          if { $::sergame::coachTypeMove } { append co "Bad Move Warning; " }
          if { $::sergame::coachTypeTactic } { append co "Engine Blunder Information; " }
          append co "Blunder Threshold: $::sergame::threshold "
          sc_pos setComment $co
      }
    }

    set ::sergame::waitPlayerMove 0
    set ::sergame::wentOutOfBook 0
    ::setPlayMode "::sergame::callback"
    ::notify::GameChanged

    if { $::sergame::coachTypeTactic || $::sergame::useCoachEngine } {
        set ::sergame::useCoachEngine 1
        set callback [list ::sergame::coachEng_messages coachEngine nop]
        if { ! [::engineNoWin::initEngine coachEngine $::sergame::coachName $callback] } {
            set ::sergame::useCoachEngine 0
        }
    }
    clocks init
    clocks start

    ::sergame::playLoop
  }

  proc ::sergame::eng_messages {id w msg} {
      lassign $msg msgType msgData
      switch $msgType {
          "InfoConfig" {
              if { ! [winfo exists $w] } { return }
              set msgData [lindex $msgData 2]
              ::engineNoWin::initEngineOptions $id $w $msgData
          }
          "InfoPV" {
              if { ! $::sergame::useCoachEngine } {
                  # no coach engine then use score from playing engine
                  lassign $msgData multipv depth seldepth nodes nps hashfull tbhits time score score_type score_wdl pv
                  if { $multipv == 1 } {
                      set ::sergame::data(score) [expr $score / 100.0]
                      if { $score_type eq "mate" } {
                          if { $score > 0 } {
                              set ::sergame::data(score) 128.0
                          } else {
                              set ::sergame::data(score) -128.0
                          }
                      }
                  }
              }
          }
          "InfoBestMove" {
              lassign $msgData ::sergame::data(bestmove) ponder ::sergame::data(ponder)
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
                  set ::sergame::data(bestCoachmove) [lrange $pv 0 0]
                  set ::sergame::data(score) [expr $score / 100.0]
                  if { $score_type eq "mate" } {
                      if { $score > 0 } {
                          set ::sergame::data(score) 128.0
                      } else {
                          set ::sergame::data(score) -128.0
                      }
                  }
              }
          }
          "InfoBestMove" {
              lassign $msgData ::sergame::data(bestCoachmove)
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
    switch $cmd {
        premove { # TODO: currently we just return true if it is the engine turn.
            return [expr { ! $::sergame::waitPlayerMove }]
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
    ::setPlayMode ""
    after cancel ::sergame::playLoop
    clocks stop
    set ::sergame::lFen {}
    ::engine::send seriousEngine StopGo
    ::engine::close seriousEngine
    unset ::enginewin::engConfig_seriousEngine
    set ::sergame::data(bestmove) "abort"
    if { $::sergame::useCoachEngine } {
        ::engine::send coachEngine StopGo
        ::engine::close coachEngine
        unset ::enginewin::engConfig_coachEngine
    }
    # if { [sc_game tag get Result] eq "*" } { setResult }
    ::notify::GameChanged
  }

  proc clocks {cmd} {
    if {$::sergame::timeMode != "timebonus"} { return }

    switch $cmd {
      init {
          ::gameclock::new "" 1
          ::gameclock::new "" 2
          ::gameclock::setSec 1 [expr 0 - $::sergame::data(wtime)/1000]
          ::gameclock::setSec 2 [expr 0 - $::sergame::data(btime)/1000]
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
            ::gameclock::add 1 [expr $::sergame::data(winc)/1000]
            ::gameclock::storeTimeComment 1
            ::gameclock::start 2
          } elseif {[::gameclock::stop 2]} {
            ::gameclock::add 2 [expr $::sergame::data(binc)/1000]
            ::gameclock::storeTimeComment 2
            ::gameclock::start 1
          }
          ::notify::PosChanged -pgn
      }
    }
  }

  proc takeBack {takebackClockW takebackClockB} {
    sc_move back 1
    sc_game truncate
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
      global ::sergame::timeMode
      if {$timeMode == "timebonus"} {
        set wtime [expr [::gameclock::getSec 1] * 1000 ]
        set btime [expr [::gameclock::getSec 2] * 1000 ]
        set parameter "$ponder wtime $wtime btime $btime winc $::sergame::data(winc) binc $::sergame::data(binc)"
      } elseif {$timeMode == "depth"} {
        set parameter "$ponder depth $::sergame::data(fixeddepth)"
      } elseif {$timeMode == "movetime"} {
        set parameter "$ponder movetime $::sergame::data(movetime)"
      } elseif {$timeMode == "nodes"} {
        set parameter "$ponder nodes $::sergame::data(fixednodes)"
      }
      if { $ponder ne "" } { set ponder "moves $::sergame::data(ponder)" }
      ::engine::send seriousEngine Go [list "position fen [sc_pos fen] $ponder" $parameter]
  }

  proc checkBlunder { delta } {
      set ret ""
      if { $delta >= $::sergame::threshold } {
          if {$delta > $::informant("?!") } { set ret [list "?!" "DubiousMovePlayedTakeBack"] }
          if {$delta > $::informant("?") } { set ret [list "?" "WeakMovePlayedTakeBack"] }
          if {$delta > $::informant("??") } { set ret [list "??" "BadMovePlayedTakeBack"] }
      }
      return $ret
  }
  proc checkEngineBlunder { } {
      set delta [expr $::sergame::data(score) + $::sergame::data(prevscore)]
      if { [sc_pos side] == $::sergame::engineColor } { set delta [expr 0.0 - $delta] }
      lassign [checkBlunder $delta] ::sergame::tacticBlunder
      if { $::sergame::tacticBlunder ne "" } {
          if { $::sergame::engineColor eq "white" } {
              set from $::sergame::data(prevscore)
              set to [expr 0.0 - $::sergame::data(score)]
          } else {
              set from [expr 0.0 - $::sergame::data(prevscore)]
              set to $::sergame::data(score)
          }
          ::board::setInfoAlert .main.board "Engine blunders: $::sergame::tacticBlunder $from -> $to" "Show move" red \
              {::board::setInfoAlert .main.board "Try move $::sergame::data(bestCoachmove) Playing..." [tr Stop] red {{*}$::playMode stop}}
      }
  }

  ################################################################################
  #
  ################################################################################
  proc playLoop { } {
    global ::sergame::isOpening ::sergame::openingMovesList ::sergame::openingMovesHash ::sergame::openingMoves \
        ::sergame::timeMode ::sergame::outOfOpening
    
    after cancel ::sergame::playLoop
    
    if { [::sergame::endOfGame] } { return }
    
    if { [sc_pos side] != $::sergame::engineColor } {
      # wait until player has moved
      set ::sergame::waitPlayerMove 1
      after 1000 ::sergame::playLoop
      if { $::sergame::useCoachEngine && $::sergame::coachTypeTactic && $::sergame::actTacTime > 0 && $::sergame::data(prevscore) != "" } {
          #check for engine blunder with coach engine
          incr ::sergame::actTacTime -1
          if { $::sergame::isLimitedAnalysisTime && ! $::sergame::actTacTime } {
              # make sure we have a move and evaluation from coach engine 
              while { $::sergame::data(bestCoachmove) eq "" } { vwait ::sergame::data(bestCoachmove) }
              ::engine::send coachEngine StopGo
          } else {
              checkEngineBlunder
          }
      }
      return
    }

    if { $::sergame::useCoachEngine } {
        ::engine::send coachEngine StopGo
        if { $::sergame::tacticBlunder ne "" } {
            # engine blundered, add nag and correct eval comment
            sc_move back
            sc_pos addNag $::sergame::tacticBlunder
            if { $::sergame::storeEval == 1 } {
                set score $::sergame::data(score)
                if { $::sergame::engineColor eq "white" } { set score [expr 0.0 - $score] }
                storeEvalComment $score
            }
            sc_move forward
        }
    }
    
    set takebackClockW ""
    set takebackClockB ""
    if {$::sergame::waitPlayerMove} {
      # The player moved
      set ::sergame::waitPlayerMove 0
      if {$::sergame::timeMode == "timebonus"} {
        set takebackClockW [::gameclock::getSec 1]
        set takebackClockB [::gameclock::getSec 2]
        clocks toggle
      }
      if { [repetition] } { [return }
    }
    
    # make a move corresponding to a specific opening, (it is engine's turn)
    if {$isOpening && !$outOfOpening} {
      set index 0
      # Warn if the user went out of the opening line chosen
      if { !$outOfOpening } {
        set ply [ expr [sc_pos moveNumber] * 2 - 1]
        if { [sc_pos side] == "white" } {
          set ply [expr $ply - 1]
        }
        
        if { [lsearch $openingMovesHash [sc_pos hash]] == -1 && [llength $openingMovesList] >= $ply} {
          clocks stop
          set answer [tk_messageBox -icon question -parent .main -title $::tr(OutOfOpening) -type yesno \
              -message "$::tr(NotFollowedLine) $openingMoves\n $::tr(DoYouWantContinue)" ]
          if {$answer == no} {
            takeBack $takebackClockW $takebackClockB
            after 1000 ::sergame::playLoop
            return
          }  else  {
            set outOfOpening 1
          }
          clocks start
        }
      }
      
      set hpos [sc_pos hash]
      # Find a corresponding position in the opening line
      set length [llength $openingMovesHash]
      for {set i 0}   { $i < [expr $length-1] } { incr i } {
        set h [lindex $openingMovesHash $i]
        if {$h == $hpos} {
          set index [lsearch $openingMovesHash $h]
          set move [lindex $openingMovesList $index]
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
    if {$::sergame::useBook && ! $::sergame::wentOutOfBook} {
      set move [ ::book::getMove $::sergame::bookToUse [sc_pos fen] $::sergame::bookSlot]
      if {$move == ""} {
        set ::sergame::wentOutOfBook 1
      } else  {
        sc_move addSan $move
        ::utils::sound::AnnounceNewMove $move
        # we made a book move so assume a score = 0
        set ::sergame::data(prevscore) ""
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
    if { $::sergame::ponder && $::sergame::data(ponder) ne "" && $::sergame::data(ponder) == [sc_game info previousMoveUCI]} {
      ::engine::rawsend seriousEngine "ponderhit"
    } else {
      if { $::sergame::ponder } { ::engine::send seriousEngine StopGo }
      startEngine ""
    }
    if { $::sergame::useCoachEngine } {
        set ::sergame::data(bestCoachmove) ""
        ::engine::send coachEngine Go [list "position fen [sc_pos fen]" "infinite"]
    }
    
    set ::sergame::data(bestmove) ""
    vwait ::sergame::data(bestmove)
    if { $::sergame::useCoachEngine } {
        # make sure we have a move and evaluation from coach engine 
        while { $::sergame::data(bestCoachmove) eq "" } { vwait ::sergame::data(bestCoachmove) }
        ::engine::send coachEngine StopGo
    }
    
    # -------------------------------------------------------------
    # if weak move detected, propose the user to take back
    if { $::sergame::coachTypeMove && $::sergame::data(prevscore) != "" } {
      set delta [expr $::sergame::data(score) - $::sergame::data(prevscore)]
      if { [sc_pos side] != $::sergame::engineColor } { set delta [expr 0.0 - $delta] }
      lassign [checkBlunder $delta] nop tBlunder
      if {$tBlunder ne ""} {
        clocks stop
        set answer [tk_messageBox -icon question -parent .main -title "Scid" -type yesno -message "$::tr($tBlunder)\n$::sergame::data(prevscore) -> $::sergame::data(score)" ]
        if {$answer == yes} {
          takeBack $takebackClockW $takebackClockB
          after 1000 ::sergame::playLoop
          return
        }
        clocks start
      }
    }
    
    # -------------------------------------------------------------
    if { $::sergame::data(bestmove) == "abort" } {
      return
    }
    
    sc_move addSan $::sergame::data(bestmove)
    ::utils::sound::AnnounceNewMove $::sergame::data(bestmove)
    set ::sergame::data(prevscore) $::sergame::data(score)
    if { $::sergame::storeEval == 1 } {
      set score $::sergame::data(score)
      if { $::sergame::engineColor eq "black" } { set score [expr 0.0 - $score] }
      storeEvalComment $score
    }
    updateBoard -pgn -animate
    if { [repetition] } { return }
    
    clocks toggle

    # ponder mode (the engine just played its move)
    if {$::sergame::ponder } { startEngine ponder }
    
    if { $::sergame::useCoachEngine } {
        set ::sergame::actTacTime $::sergame::tacTime
        set ::sergame::data(bestCoachmove) ""
        ::engine::send coachEngine Go [list "position fen [sc_pos fen]" "infinite"]
    }
    after 1000 ::sergame::playLoop
  }
  ################################################################################
  #   add current position for 3fold repetition detection and returns 1 if
  # the position is a repetition
  ################################################################################
  proc repetition {} {
    lassign [checkRepetition $::sergame::lFen] isRepetition ::sergame::lFen
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
  proc logEngine {n text} {
    if {$::sergame::data(log_stdout)} {
      puts stdout "$n $text"
    }
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
