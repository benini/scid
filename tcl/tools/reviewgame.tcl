### reviewgame.tcl: part of Scid.
### Copyright (C) 2009  Pascal Georges
###
######################################################################
### Try to guess the moves of a game
#

namespace eval reviewgame {
  set engineSlot 6
  set window ".reviewgame"
  set timeShort 3
  set timeExtended 15
  set margin 0.3
  
  set sequence 0
  
  array set analysisEngine {}
  
  set progressBarStep 1
  set progressBarTimer 0
}

################################################################################
#
################################################################################
proc ::reviewgame::start {} {
  if { ! [::reviewgame::launchengine] } {
    tk_messageBox -type ok -icon warning -title "Scid" -message "This feature require at least one UCI engine"
    return
  }

  set w $::reviewgame::window
  createToplevel $w
  setTitle $w [::tr "GameReview" ]
  wm minsize $w 200 200
  
  ttk::frame $w.fgameinfo
  set welo [sc_game tags get WhiteElo]
  set belo [sc_game tags get BlackElo]
  if { $welo == "0"} { set welo "-" }
  if { $belo == "0"} { set belo "-" }
  ttk::label $w.fgameinfo.l1 -text "[sc_game tags get White] ($welo) - [sc_game tags get Black] ($belo)"
  set result [sc_game tags get Result]
  if { $result == "1" } { set result "1-0" }
  if { $result == "0" } { set result "0-1" }
  if { $result == "=" } { set result "1/2 - 1/2" }
  ttk::label $w.fgameinfo.l2 -text "$result"
  pack $w.fgameinfo.l1 $w.fgameinfo.l2
  pack $w.fgameinfo -expand 1 -fill both
  
  ttk::frame $w.fparam
  ttk::label $w.fparam.ltime1 -text "[::tr Time] ([::tr sec])"
  ttk::spinbox $w.fparam.time1 -from 1 -to 120 -textvariable ::reviewgame::timeShort -width 7
  ttk::label $w.fparam.ltime2 -text "[::tr GameReviewTimeExtended] ([::tr sec])"
  ttk::spinbox $w.fparam.time2 -from 3 -to 300 -textvariable ::reviewgame::timeExtended -width 7
  ttk::label $w.fparam.lmargin -text "[::tr GameReviewMargin]"
  ttk::spinbox $w.fparam.margin -from 0.1 -to 1.0 -increment 0.1 -textvariable ::reviewgame::margin -width 7
  
  set row 0
  grid $w.fparam.ltime1 -column 0 -row $row -sticky nw
  grid $w.fparam.time1 -column 1 -row $row -sticky nw
  incr row
  grid $w.fparam.ltime2 -column 0 -row $row -sticky nw
  grid $w.fparam.time2 -column 1 -row $row -sticky nw
  incr row
  grid $w.fparam.lmargin -column 0 -row $row -sticky nw
  grid $w.fparam.margin -column 1 -row $row -sticky nw
  
  pack $w.fparam -expand 1 -fill both
  
  ttk::frame $w.finfo
  pack $w.finfo -expand 1 -fill both
  ttk::progressbar $w.finfo.pb -orient horizontal -length 100 -value 0 -mode determinate
  ttk::label $w.finfo.pblabel -image tb_stop -compound left
  ttk::label $w.finfo.sc1 -text "[::tr GameReviewEngineScore]"
  ttk::label $w.finfo.sc2 -text "[::tr GameReviewGameMoveScore]"
  ttk::label $w.finfo.sc3 -foreground dodgerblue3 -text ""
  ttk::label $w.finfo.eval1 -text ""
  ttk::label $w.finfo.eval2 -text ""
  ttk::label $w.finfo.eval3 -text ""
  ttk::button $w.finfo.proceed -textvar ::tr(Continue) -command ::reviewgame::proceed
  ttk::button $w.finfo.extended -text "[::tr GameReviewReCalculate]" -command ::reviewgame::extendedTime
  
  set row 0
  grid $w.finfo.pb -column 0 -row $row -sticky we -columnspan 2
  incr row
  grid $w.finfo.pblabel -column 0 -row $row -sticky we -columnspan 2
  incr row
  grid $w.finfo.proceed -column 0 -row $row -sticky nw
  grid $w.finfo.extended -column 1 -row $row -sticky nw
  incr row
  grid $w.finfo.sc1 -column 0 -row $row -sticky nw
  grid $w.finfo.eval1 -column 1 -row $row -sticky nw -padx 10
  incr row
  grid $w.finfo.sc2 -column 0 -row $row -sticky nw
  grid $w.finfo.eval2 -column 1 -row $row -sticky nw -padx 10
  incr row
  grid $w.finfo.sc3 -column 0 -row $row -sticky nw
  grid $w.finfo.eval3 -column 1 -row $row -sticky nw -padx 10
  incr row
  
  ttk::button $w.finfo.sol -text [::tr ShowSolution ] -command ::reviewgame::showSolution
  grid $w.finfo.sol -column 0 -row $row  -sticky nw
  incr row
  
  # Display statistics
  ttk::label $w.finfo.stats -text ""
  grid $w.finfo.stats -column 0 -row $row -sticky nw -columnspan 2
  incr row

  ttk::frame $w.fbuttons
  pack $w.fbuttons -fill x
  ttk::button $w.fbuttons.close -textvar ::tr(Abort) -command ::reviewgame::endTraining
  pack $w.fbuttons.close -expand 1 -fill x
  
  set ::reviewgame::boardFlipped [::board::isFlipped .main.board]
  
  bind $w <Destroy> "if {\[string equal $w %W\]} {::reviewgame::endTraining}"
  bind $w <F1> { helpWindow ReviewGame }
  ::createToplevelFinalize $w
  set ::reviewgame::movesLikePlayer 0
  set ::reviewgame::movesLikeEngine 0
  set ::reviewgame::numberMovesPlayed 0
  ::setPlayMode "::reviewgame::callback"
  ::reviewgame::resetValues
  ::reviewgame::mainLoop
}

proc ::reviewgame::clearEvaluation {} {
  set w $::reviewgame::window
  $w.finfo.sol configure -text "[::tr ShowSolution]"
  $w.finfo.eval1 configure -text ""
  $w.finfo.eval2 configure -text ""
  $w.finfo.eval3 configure -text ""
  $w.finfo.sc3 configure -text ""
}

proc ::reviewgame::callback {cmd args} {
  switch $cmd {
      premove { # TODO: currently we just return true if it is the engine turn.
        return [expr { $::reviewgame::sequence != 2 || ![::reviewgame::isPlayerTurn] }]
      }
      stop { ::reviewgame::endTraining }
  }
  return 0
}

################################################################################
#
################################################################################
proc ::reviewgame::showSolution {} {
  set w $::reviewgame::window
  $w.finfo.sol configure -text "[ sc_game info nextMove ]"
  set ::reviewgame::solutionDisplayed 1
}
################################################################################
#
################################################################################
proc ::reviewgame::endTraining {} {
  set w $::reviewgame::window
  
  after cancel ::reviewgame::mainLoop
  set ::reviewgame::bailout 1
  set ::reviewgame::sequence 0
  after cancel ::reviewgame::stopAnalyze
  ::reviewgame::stopAnalyze
  focus .
  bind $w <Destroy> {}
  ::win::closeWindow $w
  ::setPlayMode ""
  
  catch { ::uci::closeUCIengine $::reviewgame::engineSlot }
}
################################################################################
#
################################################################################
proc ::reviewgame::isPlayerTurn {} {
  if { [sc_pos side] == "white" &&  ![::board::isFlipped .main.board] || [sc_pos side] == "black" &&  [::board::isFlipped .main.board] } {
    return 1
  }
  return 0
}
################################################################################
# waits for the user to play and check the move played
################################################################################
proc ::reviewgame::mainLoop {} {
  global ::reviewgame::sequence ::reviewgame::useExtendedTime ::reviewgame::analysisEngine
  set w $::reviewgame::window
  
  after cancel ::reviewgame::mainLoop
  
  if { $useExtendedTime } {
    set ::reviewgame::thinkingTime $::reviewgame::timeExtended
  } else {
    set ::reviewgame::thinkingTime $::reviewgame::timeShort
  }
  
  # check player side, if  not at bottom, flip the board
  if { ((! [::reviewgame::isPlayerTurn] && $sequence == 0) || ! [ checkConsistency ]) && \
       [ sc_game info nextMoveNT ] != "" } {
      ::board::flip .main.board
      set ::reviewgame::boardFlipped [::board::isFlipped .main.board]
      updateBoard -pgn -animate
  }
  
  $w.finfo.proceed configure -state disabled
  $w.finfo.sol configure -state disabled
  
  # Phase 1 : analyze the move really played during the game
  if {$sequence == 0} {
    set ::reviewgame::movePlayed [ sc_game info nextMoveNT ]
    if {$::reviewgame::movePlayed == ""} {
      return
    }
    $w.finfo.pblabel configure -image tb_stop -text "[::tr GameReviewAnalyzingMovePlayedDuringTheGame]"
    ::reviewgame::startAnalyze $::reviewgame::thinkingTime $::reviewgame::movePlayed
    vwait ::reviewgame::sequence
    if { $::reviewgame::bailout } { return }
  }
  
  # Phase 2 : find the best engine move in current position
  if { $sequence == 1 } {
    $w.finfo.pblabel configure -image tb_stop -text "[::tr GameReviewAnalyzingThePosition]"
    ::reviewgame::startAnalyze $::reviewgame::thinkingTime
    vwait ::reviewgame::sequence
    if { $::reviewgame::bailout } { return }
  }
  
  $w.finfo.pblabel configure -image tb_play -text "[::tr GameReviewEnterYourMove]"
  $w.finfo.sol configure -state normal
  $w.finfo.proceed configure -state normal
  
  # is this player's turn (which always plays from bottom of the board) ?
  if { [::reviewgame::isPlayerTurn] } {
    after 1000 ::reviewgame::mainLoop
    return
  }
  
  ::reviewgame::clearEvaluation
  checkPlayerMove
  
  $w.finfo.extended configure -state normal
  updateStats
  set ::reviewgame::useExtendedTime 0
  after 1000 ::reviewgame::mainLoop
}
################################################################################
#
################################################################################
proc ::reviewgame::checkPlayerMove {} {
  global ::reviewgame::sequence ::reviewgame::useExtendedTime ::reviewgame::analysisEngine
  set w $::reviewgame::window
  set moveForward 0
  
  incr ::reviewgame::numberMovesPlayed
  
  # Phase 3 : ponder on user's move if different of best engine move and move played
  # We know user has played
  set user_move [sc_game info previousMoveNT]
  
  # ponder on user's move if he did not play the same move as in match
  if {$user_move != $::reviewgame::movePlayed} {
    $w.finfo.pblabel configure -image tb_stop -text "[::tr GameReviewCheckingYourMove]"
    ::reviewgame::startAnalyze $::reviewgame::thinkingTime ;#$user_move
    vwait ::reviewgame::sequence
    if { $::reviewgame::bailout } { return }
    $w.finfo.pblabel configure -image tb_stop -text "[::tr GameReviewYourMoveWasAnalyzed]"
    # display user's score
    $w.finfo.eval3 configure -text "$analysisEngine(score,2)\t[::trans $user_move]"
    set moveForward 1
  }
  
  # User guessed the correct move played in game
  if {$user_move == $::reviewgame::movePlayed } {
    set ::reviewgame::sequence 0
    
    $w.finfo.sc3 configure -text "[::tr GameReviewYouPlayedSameMove]" -foreground "sea green"
    set result "$analysisEngine(score,1)\t[::trans $::reviewgame::movePlayed]"
    $w.finfo.eval3 configure -text $result
    if { ! $::reviewgame::solutionDisplayed } {
      incr ::reviewgame::movesLikePlayer
    }
    
    # display played move score
    $w.finfo.eval2 configure -text $result
    # display engine's score
    $w.finfo.eval1 configure -text "$analysisEngine(score,2)\t[::trans [lindex $analysisEngine(moves,2) 0]]"
    $w.finfo.pblabel configure -image tb_play -text ""
    set sequence 0
    set moveForward 1
  } elseif { $user_move == [ lindex $analysisEngine(moves,2) 0] || [ isGoodScore $analysisEngine(score,2) $analysisEngine(score,3)  ] } {
    set  ::reviewgame::sequence 0
    
    # ToDo: Check if position has changed
    # User guessed engine's move
    if {$user_move == [ lindex $analysisEngine(moves,2) 0]} {
      $w.finfo.sc3 configure -text "[::tr GameReviewYouPlayedLikeTheEngine]" -foreground "sea green"
      incr ::reviewgame::movesLikeEngine
    } else  {
      $w.finfo.sc3 configure -text "[::tr GameReviewNotEngineMoveButGoodMove]" -foreground dodgerblue3
      $w.finfo.eval3 configure -text "$analysisEngine(score,3)\t[::trans $user_move]"
    }
    sc_var exit
    sc_move forward
    updateBoard -pgn -animate
    # display played move score
    $w.finfo.eval2 configure -text "$analysisEngine(score,1)\t[::trans $::reviewgame::movePlayed]"
    # display engine's score
    $w.finfo.eval1 configure -text "$analysisEngine(score,2)\t[::trans [lindex $analysisEngine(moves,2) 0]]"
  } else  {
    # user played a bad move : comment it and restart the process
    set  ::reviewgame::sequence 2
    
    $w.finfo.sc3 configure -text "[::tr GameReviewMoveNotGood]" -foreground red
    $w.finfo.eval3 configure -text "$analysisEngine(score,3)\t[::trans $user_move]\n([::trans $analysisEngine(moves,3)])"
    sc_pos addNag "?"
    
    # Instead of adding info in comments, add real variations
    # sc_pos setComment "($analysisEngine(score,3)) $analysisEngine(moves,3) Engine : ($analysisEngine(score,2)) \n[::trans $analysisEngine(moves,2)]"
    sc_pos setComment "($analysisEngine(score,3))"
    sc_move addSan $analysisEngine(moves,3)
    set ::reviewgame::sequence 2
    sc_var exit
    sc_var create
    sc_pos setComment "Engine : ($analysisEngine(score,2))"
    if { [catch { sc_move addSan $analysisEngine(moves,2) } ] } {
        ::reviewgame::clearEvaluation
        tk_messageBox -type ok -icon warning -title "Scid" -message "Position changed. New evaluation required!"
        ::reviewgame::resetValues
        set ::reviewgame::sequence 0
    }
    sc_var exit
    updateBoard -pgn
    set moveForward 0
    
    # allows a re-calculation
    $w.finfo.extended configure -state normal
    
    # display played move score
    $w.finfo.eval2 configure -text "$analysisEngine(score,1)"
    # display engine's score
    $w.finfo.eval1 configure -text "$analysisEngine(score,2)"
  }
  if { $moveForward } {
      sc_var exit
      sc_move forward
      updateBoard -pgn -animate
  }
}
################################################################################
#
################################################################################
proc ::reviewgame::updateStats {} {
  set l $::reviewgame::window.finfo.stats
  if { ![::board::isFlipped .main.board] } {
    set player [sc_game info white]
  } else  {
    set player [sc_game info black]
  }
  
  $l configure -text "[::tr GameReviewMovesPlayedLike] $player : $::reviewgame::movesLikePlayer / $::reviewgame::numberMovesPlayed\n[::tr GameReviewMovesPlayedEngine] : $::reviewgame::movesLikeEngine / $::reviewgame::numberMovesPlayed"
}
################################################################################
#
################################################################################
proc ::reviewgame::isGoodScore {engine player} {
  global ::reviewgame::margin
  if { ![::board::isFlipped .main.board] } {
    # if player plays white
    if {$player >= [expr $engine - $margin]} {
      return 1
    }
  } else  {
    if {$player <= [expr $engine + $margin]} {
      return 1
    }
  }
  return 0
}
################################################################################
## resetValues
#   Resets global data.
################################################################################
proc ::reviewgame::resetValues {} {
  set ::reviewgame::sequence 0
  set ::reviewgame::analysisEngine(analyzeMode) 0
  set ::reviewgame::bailout 0
  set ::reviewgame::useExtendedTime 0
  set ::reviewgame::solutionDisplayed 0
}

################################################################################
#  Will start engine
# in case of an error, return 0, or 1 if the engine is ok
################################################################################
proc ::reviewgame::launchengine {} {
  global ::reviewgame::analysisEngine
  
  ::uci::resetUciInfo $::reviewgame::engineSlot
  set analysisEngine(analyzeMode) 0
  
  # find engine
  set engineFound 0
  set index 0
  foreach e $::engines(list) {
    if {[lindex $e 7] != 0} {
      set engineFound 1
      break
    }
    incr index
  }
  if { ! $engineFound } {
    return 0
  }
  
  ::uci::startEngine $index $::reviewgame::engineSlot ;# start engine in analysis mode
  return 1
}

# ======================================================================
# sendToEngine:
#   Send a command to a running analysis engine.
# ======================================================================
proc ::reviewgame::sendToEngine {text} {
  ::uci::sendToEngine $::reviewgame::engineSlot $text
}

# ======================================================================
# startAnalyzeMode:
#   Put the engine in analyze mode, from current position after move played (in UCI format), time is in seconds
# ======================================================================
proc ::reviewgame::startAnalyze { analysisTime { move "" } } {
  global ::reviewgame::analysisEngine ::reviewgame::engineSlot
  
  set pb $::reviewgame::window.finfo.pb
  set length [$pb cget -maximum]
  set ::reviewgame::progressBarTimer  [expr ( $analysisTime * 1000 * $::reviewgame::progressBarStep ) / $length ]
  after $::reviewgame::progressBarTimer ::reviewgame::updateProgressBar
  
  # Check that the engine has not already had analyze mode started:
  if {$analysisEngine(analyzeMode)} {
    ::reviewgame::sendToEngine  "exit"
  }
  set analysisEngine(analyzeMode) 1
  after cancel ::reviewgame::stopAnalyze
  
  # we want to ponder on a particular move, hence we need to switch to a temporary position so
  # UCI code can correctly format the variations
  if {$move != ""} {
    sc_game push copyfast
    sc_move addSan $move
    set ::analysis(fen$engineSlot) [sc_pos fen]
    sc_game pop
  } else  {
    set ::analysis(fen$engineSlot) [sc_pos fen]
  }
  
  ::reviewgame::sendToEngine "position fen $::analysis(fen$engineSlot) $move"
  ::reviewgame::sendToEngine "go infinite"
  after [expr 1000 * $analysisTime] "::reviewgame::stopAnalyze $move"
}
# ======================================================================
# stopAnalyzeMode:
#   Stop the engine analyze mode
# ======================================================================
proc ::reviewgame::stopAnalyze { { move "" } } {
  global ::reviewgame::analysisEngine ::reviewgame::sequence
  
  # Check that the engine has already had analyze mode started:
  if { ! $analysisEngine(analyzeMode) } { return }
  
  after cancel ::reviewgame::updateProgressBar
  if { [winfo exists $::reviewgame::window.finfo.pb]} {
    $::reviewgame::window.finfo.pb configure -value 0
  }

  incr ::reviewgame::sequence
  set pv [lindex $::analysis(multiPV$::reviewgame::engineSlot) 0]
  set analysisEngine(score,$sequence) [lindex $pv 1]
  if { $sequence == 1 } { ;# change score to white perspective
      set analysisEngine(score,$sequence) [expr 0 - $analysisEngine(score,$sequence)]
  }
  set analysisEngine(moves,$sequence) [lindex $pv 2]
  
  set analysisEngine(analyzeMode) 0
  ::reviewgame::sendToEngine "stop"
}
################################################################################
#
################################################################################
proc ::reviewgame::proceed {} {
  # skip this move, go to next cycle
  ::reviewgame::clearEvaluation
  sc_var exit
  sc_move forward
  sc_move forward
  updateBoard -pgn -animate
  ::reviewgame::resetValues
  after 1000 ::reviewgame::mainLoop
}
################################################################################
# Rethink on the position with extended time
################################################################################
proc ::reviewgame::extendedTime {} {
  # if already calculating, do nothing
  if { $::reviewgame::analysisEngine(analyzeMode)} {
    return
  }
  
  if { ![::reviewgame::isPlayerTurn] } {
    ::move::Back
  }
  
  set ::reviewgame::useExtendedTime 1
  set ::reviewgame::sequence 0
  ::reviewgame::mainLoop
}
################################################################################
#
################################################################################
proc ::reviewgame::updateProgressBar {} {
  $::reviewgame::window.finfo.pb step $::reviewgame::progressBarStep
  after $::reviewgame::progressBarTimer ::reviewgame::updateProgressBar
}
################################################################################
#
################################################################################
proc ::reviewgame::checkConsistency {} {
  if { $::reviewgame::boardFlipped != [::board::isFlipped .main.board] } {
    tk_messageBox -type ok -icon warning -title "Scid" -message "Player side is not at bottom. Flipping board!"
    return 0
  }
  return 1
}

###
### End of file: reviewgame.tcl
###
