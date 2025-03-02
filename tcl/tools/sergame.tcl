###
### sergame.tcl: part of Scid.
### Copyright (C) 2007  Pascal Georges
###
################################################################################
# The number used for the engine playing a serious game is 3
################################################################################

namespace eval sergame {
  
  # DEBUG
  set ::sergame::data(log_stdout) 0
  
  # if true, follow a specific opening
  set openingMovesList {}
  set openingMovesHash {}
  set openingMoves ""
  set outOfOpening 0
  set engineName ""
  set coachName ""
  set bookSlot 2
  set storeEval 0
  set coachTypeMove 1
  set coachTypeTactic 1
  set useCoachEngine 1
  set tacticBlunder ""
  set tacTime 10
  set actTacTime 0
  set threshold 0.6
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
    
    ttk::frame $w.fconfig -padding 10
    ttk::frame $w.fbuttons
    ttk::labelframe $w.fengines -text $::tr(Engine)
    ttk::labelframe $w.ftime -text $::tr(TimeMode)
    ttk::labelframe $w.fopening -text $::tr(Opening)
    
    grid $w.fengines -row 0 -column 0 -pady { 0 10 } -sticky nswe -padx { 0 10 }
    grid $w.fopening -row 0 -column 1 -pady { 0 10 } -sticky nswe -padx { 10 0 }
    grid $w.ftime -row 1 -column 0 -pady { 10 0 } -sticky nswe -padx { 0 10 }
    grid $w.fconfig -row 1 -column 1 -pady { 10 0 } -sticky we -padx { 10 0 }
    grid $w.fbuttons -row 2 -column 1 -sticky we
    
    # builds the list of UCI engines
    ::engineNoWin::createEngineOptionsFrame $w seriousEngine ::sergame::engineName 5 ::sergame::eng_messages
    pack $w.seriousEngine -in $w.fengines -side top -pady 5 -anchor w -padx 4
    # coach engine
    ::engineNoWin::createEngineOptionsFrame $w coachEngine ::sergame::coachName 6 ::sergame::eng_messages
    ttk::label $w.fengines.lcoach -text "Coaching"
    ttk::frame $w.fengines.cb
    ttk::checkbutton $w.fengines.cb.noCoach -text "use $::tr(Coachengine)" -variable ::sergame::useCoachEngine
    ttk::checkbutton $w.fengines.cb.coach -text "Move" -variable ::sergame::coachTypeMove
    ttk::checkbutton $w.fengines.cb.fullCoach -text "Tactical advice" -variable ::sergame::coachTypeTactic
    pack $w.fengines.cb.noCoach $w.fengines.cb.coach $w.fengines.cb.fullCoach -side left -padx 4
    ttk::frame $w.fengines.th
    ttk::label $w.fengines.th.l -text $::tr(moveblunderthreshold)
    ttk::spinbox $w.fengines.th.val -width 3 -from 0.4 -to 5.0 -increment 0.1 -textvariable ::sergame::threshold -validate all -validatecommand { regexp {^[0-9]\.[0-9]$} %P }
    pack $w.fengines.th.l $w.fengines.th.val -side left -anchor w -padx 4
    ttk::frame $w.fengines.ad
    ttk::checkbutton $w.fengines.ad.l -text $::tr(limitanalysis) -variable ::sergame::isLimitedAnalysisTime
    ttk::spinbox $w.fengines.ad.val -width 3 -from 1 -to 360 -increment 1 -textvariable ::sergame::tacTime -validate all -validatecommand { regexp {^[0-9]$} %P }
    pack $w.fengines.ad.l $w.fengines.ad.val -side left -anchor w -padx 4
    pack $w.fengines.lcoach $w.fengines.cb $w.fengines.th $w.fengines.ad -side top -anchor w -padx 4
    pack $w.coachEngine -in $w.fengines -side top -pady 5 -anchor w -padx 4
    
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
    ttk::checkbutton $w.fconfig.cbPosition -text $::tr(StartFromCurrentPosition) -variable ::sergame::startFromCurrent
    pack $w.fconfig.cbPosition  -side top -anchor w
    
    # ponder
    ttk::checkbutton $w.fconfig.cbPonder -text $::tr(Ponder) -variable ::sergame::ponder
    pack $w.fconfig.cbPonder  -side top -anchor w
    
    #Should the evaluation of the position stored in the comment?
    ttk::checkbutton $w.fconfig.storeEval -text $::tr(AddScoreToShortAnnotations) -variable ::sergame::storeEval
    pack $w.fconfig.storeEval -side top -anchor w
    
    # choose a specific opening
    ttk::checkbutton $w.fopening.cbOpening -text $::tr(SpecificOpening) -variable ::sergame::isOpening
    ttk::frame $w.fopening.fOpeningList
    ttk::treeview $w.fopening.fOpeningList.lbOpening -columns {0} -show {} -selectmode browse \
        -yscrollcommand "$w.fopening.fOpeningList.ybar set"
    $w.fopening.fOpeningList.lbOpening column 0 -width 250
    $w.fopening.fOpeningList.lbOpening configure -height 5
    set idx 0
    foreach o $::tacgame::openingList {
        $w.fopening.fOpeningList.lbOpening insert {} end -id $idx -values [list $o]
        incr idx
    }

    $w.fopening.fOpeningList.lbOpening selection set $::sergame::chosenOpening
    $w.fopening.fOpeningList.lbOpening see $::sergame::chosenOpening
    
    ttk::scrollbar $w.fopening.fOpeningList.ybar -command "$w.fopening.fOpeningList.lbOpening yview"
    pack $w.fopening.fOpeningList.ybar -side right -fill y
    pack $w.fopening.fOpeningList.lbOpening -side left -fill both -expand 1
    pack $w.fopening.fOpeningList -fill both -side top
    pack $w.fopening.cbOpening -fill x -side top
    
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

      set callback [list ::sergame::eng_messages seriousEngine nop]
      if { [::engineNoWin::initEngine seriousEngine $::sergame::engineName $callback] } {
          destroy .configSerGameWin
          ::sergame::play seriousEngine
      }
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
    global ::sergame::chosenOpening ::sergame::isOpening ::tacgame::openingList ::sergame::openingMovesList \
        ::sergame::openingMovesHash ::sergame::openingMoves ::sergame::outOfOpening
    
    if {$::sergame::isOpening || !$::sergame::startFromCurrent} {
      if {[::game::Clear] eq "cancel"} { return }
    }

    set ::sergame::lFen {}
    set ::sergame::data(prevscore) 0.0
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
      if { $::sergame::coachTypeMove || $::sergame::coachTypeTactic } {
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

    ::sergame::engineGo
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
                  set ::sergame::data(bestCoachmove) $pv
                  set ::sergame::data(score) [expr $score / 100.0]
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

  proc abortGame { } {
    ::setPlayMode ""
    after cancel ::sergame::engineGo
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
    set move_done [sc_game info previousMove]
    if { [string index [sc_game info previousMove] end ] == "#"} {
      clocks stop
      return 1
    }
    return 0
  }
  ################################################################################
  #
  ################################################################################
  proc engineGo { } {
    global ::sergame::isOpening ::sergame::openingMovesList ::sergame::openingMovesHash ::sergame::openingMoves \
        ::sergame::timeMode ::sergame::outOfOpening
    
    after cancel ::sergame::engineGo
    
    if { [::sergame::endOfGame] } { return }
    
    if { [sc_pos side] != $::sergame::engineColor } {
      set ::sergame::waitPlayerMove 1
      after 1000 ::sergame::engineGo
      if { $::sergame::useCoachEngine && $::sergame::coachTypeTactic && $::sergame::actTacTime > 0 && $::sergame::data(prevscore) != "" } {
          incr ::sergame::actTacTime -1
          if { $::sergame::isLimitedAnalysisTime && ! $::sergame::actTacTime } {
              ::engine::send coachEngine StopGo
          } else {
              set ::sergame::tacticBlunder ""
              set delta [expr $::sergame::data(score) + $::sergame::data(prevscore)]
              if { [sc_pos side] == $::sergame::engineColor } { set delta [expr 0.0 - $delta] }
              if { $delta >= $::sergame::threshold } {
                  if {$delta > $::informant("?!") } { set ::sergame::tacticBlunder "?!" }
                  if {$delta > $::informant("?") } { set ::sergame::tacticBlunder "?" }
                  if {$delta > $::informant("??") } { set ::sergame::tacticBlunder "??" }
                  if { $::sergame::tacticBlunder ne "" } {
                      if { $::sergame::engineColor eq "white" } {
                          set from $::sergame::data(prevscore)
                          set to [expr 0.0 - $::sergame::data(score)]
                      } else {
                          set from [expr 0.0 - $::sergame::data(prevscore)]
                          set to $::sergame::data(score)
                      }
                      ::board::setInfoAlert .main.board "Engine blunders: $::sergame::tacticBlunder" "$from -> $to" red {{*}$::playMode stop}
                  }
              }
          }
      }
      return
    }
    if { $::sergame::useCoachEngine } {
        ::board::updateEvalBar .main.board ""
        ::engine::send coachEngine StopGo
        if { $::sergame::tacticBlunder ne "" } {
            sc_move back
            sc_pos addNag $::sergame::tacticBlunder
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
            after 1000 ::sergame::engineGo
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
              after 1000 ::sergame::engineGo
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
        set ::sergame::data(prevscore) 0.0
        clocks toggle
        updateBoard -pgn -animate
        if { ! [repetition] } {
            after 1000 ::sergame::engineGo
        }
        return
      }
    }
    # -------------------------------------------------------------
    # check if the engine pondered on the right move
    
    if { $::sergame::ponder && $::sergame::data(ponder) == [sc_game info previousMoveUCI]} {
      ::engine::rawsend seriousEngine "ponderhit"
    } else {
      if { $::sergame::ponder } {
        ::engine::send seriousEngine StopGo
      }
      if {$timeMode == "timebonus"} {
        set wtime [expr [::gameclock::getSec 1] * 1000 ]
        set btime [expr [::gameclock::getSec 2] * 1000 ]
        set parameter "wtime $wtime btime $btime winc $::sergame::data(winc) binc $::sergame::data(binc)"
      } elseif {$timeMode == "depth"} {
        set parameter "depth $::sergame::data(fixeddepth)"
      } elseif {$timeMode == "movetime"} {
        set parameter "movetime $::sergame::data(movetime)"
      } elseif {$timeMode == "nodes"} {
        set parameter "nodes $::sergame::data(fixednodes)"
      }
      ::engine::send seriousEngine Go [list "position fen [sc_pos fen]" $parameter]
      if { $::sergame::useCoachEngine } {
          ::engine::send coachEngine Go [list "position fen [sc_pos fen]" "infinite"]
      }
    }
    
    set ::sergame::data(bestmove) ""
    vwait ::sergame::data(bestmove)
    if { $::sergame::useCoachEngine } {
        ::engine::send coachEngine StopGo
    }
    
    # -------------------------------------------------------------
    # if weak move detected, propose the user to tack back
    if { $::sergame::coachTypeMove && $::sergame::data(prevscore) != "" } {
      set tBlunder ""
      set delta [expr $::sergame::data(score) - $::sergame::data(prevscore)]
      if { [sc_pos side] != $::sergame::engineColor } { set delta [expr 0.0 - $delta] }
      if { $delta >= $::sergame::threshold } {
          if {$delta > $::informant("?!") } { set tBlunder "DubiousMovePlayedTakeBack" }
          if {$delta > $::informant("?") } { set tBlunder "WeakMovePlayedTakeBack" }
          if {$delta > $::informant("??") } { set tBlunder "BadMovePlayedTakeBack" }
      }
      if {$tBlunder ne ""} {
        clocks stop
        set answer [tk_messageBox -icon question -parent .main -title "Scid" -type yesno -message $::tr($tBlunder) ]
        if {$answer == yes} {
          takeBack $takebackClockW $takebackClockB
          after 1000 ::sergame::engineGo
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

    # ponder mode (the engine just played its move) ;&& $::sergame::data(ponder) != ""
    if {$::sergame::ponder } {
      if {$timeMode == "timebonus"} {
        set wtime [expr [::gameclock::getSec 1] * 1000 ]
        set btime [expr [::gameclock::getSec 2] * 1000 ]
        set parameter "ponder wtime $wtime btime $btime winc $::sergame::data(winc) binc $::sergame::data(binc)"
      } elseif {$timeMode == "depth"} {
        set parameter "ponder depth $::sergame::data(fixeddepth)"
      } elseif {$timeMode == "movetime"} {
        set parameter "ponder movetime $::sergame::data(movetime)"
      } elseif {$timeMode == "nodes"} {
        set parameter "ponder nodes $::sergame::data(fixednodes)"
      }
      ::engine::send seriousEngine Go [list "position fen [sc_pos fen] moves $::sergame::data(ponder)" $parameter]
    }
    
    if { $::sergame::useCoachEngine } {
        set ::sergame::actTacTime $::sergame::tacTime
        ::engine::send coachEngine Go [list "position fen [sc_pos fen]" "infinite"]
    }
    after 1000 ::sergame::engineGo
  }
  ################################################################################
  #   add current position for 3fold repetition detection and returns 1 if
  # the position is a repetition
  ################################################################################
  proc repetition {} {
    lassign [checkRepetition $::sergame::lFen] isRepetition ::sergame::lFen
    if { $isRepetition } {
      tk_messageBox -type ok -message $::tr(Draw) -parent .main -icon info
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
  
}
###
### End of file: sergame.tcl
###
