### reviewgame.tcl: part of Scid.
### Copyright (C) 2009  Pascal Georges
###
######################################################################
### Try to guess the moves of a game
#

namespace eval reviewgame {
  
  set prevScore 0
  set prevLine ""
  set nextEngineMove ""
  set prevFen ""
  set engineSlot 6
  set window ".reviewgame"
  set timeShort 5
  set timeExtended 1
  set margin 0.3
  set moveOfGameIsBest 0
  # The score of the move really played
  set scoreGame 0.0
  # The score of the user's move
  set scorePlayed 0.0
  # Score of the engine
  set scoreEngine 0.0
  
  set sequence 0
  
  array set analysisEngine {}
  
  set progressBarStep 1
  set progressBarTimer 0
  set autoProceed 0
}

################################################################################
#
################################################################################
proc ::reviewgame::start {} {
  set w $::reviewgame::window
  createToplevel $w
  setTitle $w "GameReview"
  setWinLocation $w
  wm minsize $w 200 200
  
  ttk::frame $w.fparam
  ttk::label $w.fparam.ltime1 -text "[::tr Time] ([::tr sec])"
  spinbox $w.fparam.time1 -values { 5 10 15 30 45 60 90 120 } -command { set ::reviewgame::timeShort [$::reviewgame::window.fparam.time1 get] }
  $w.fparam.time1 set $::reviewgame::timeShort
  ttk::label $w.fparam.ltime2 -text "[::tr GameReviewTimeExtended] ([ ::tr min])"
  spinbox $w.fparam.time2 -values { 1 2 3 4 5} -command { set ::reviewgame::timeExtended [$::reviewgame::window.fparam.time1 get] }
  $w.fparam.time2 set $::reviewgame::timeExtended
  ttk::label $w.fparam.lmargin -text "[::tr GameReviewMargin]"
  spinbox $w.fparam.margin -from 0.1 -to 1.0 -increment 0.1 -command { set ::reviewgame::margin [$::reviewgame::window.fparam.time1 get] }
  $w.fparam.margin set $::reviewgame::margin
  
  set row 0
  grid $w.fparam.ltime1 -column 0 -row $row -sticky nw
  grid $w.fparam.time1 -column 1 -row $row -sticky nw
  incr row
  grid $w.fparam.ltime2 -column 0 -row $row -sticky nw
  grid $w.fparam.time2 -column 1 -row $row -sticky nw
  incr row
  grid $w.fparam.lmargin -column 0 -row $row -sticky nw
  grid $w.fparam.margin -column 1 -row $row -sticky nw
  incr row
  
  ttk::checkbutton $w.fparam.cbproceed -text "[::tr GameReviewAutoContinue]" -variable ::reviewgame::autoProceed
  grid $w.fparam.cbproceed -column 0 -row $row  -columnspan 2 -sticky nw
  
  pack $w.fparam -expand 1 -fill both
  
  ttk::frame $w.finfo
  pack $w.finfo -expand 1 -fill both
  ttk::progressbar $w.finfo.pb -orient horizontal -length 100 -value 0 -mode determinate
  ttk::label $w.finfo.pblabel -image ReviewGameStop -compound left
  ttk::label $w.finfo.sc1 -text "-"
  ttk::label $w.finfo.sc2 -text "-"
  ttk::label $w.finfo.sc3 -foreground blue -text "-"
  ttk::button $w.finfo.proceed -textvar ::tr(Continue) -command ::reviewgame::proceed
  ttk::button $w.finfo.extended -text "[::tr GameReviewReCalculate]" -command ::reviewgame::extendedTime
  
  set row 0
  grid $w.finfo.pb -column 0 -row $row -sticky nw
  incr row
  grid $w.finfo.pblabel -column 0 -row $row -sticky nw
  incr row
  grid $w.finfo.proceed -column 0 -row $row -sticky nw
  grid $w.finfo.extended -column 1 -row $row -sticky nw
  incr row
  grid $w.finfo.sc1 -column 0 -row $row  -columnspan 2 -sticky nw
  incr row
  grid $w.finfo.sc2 -column 0 -row $row  -columnspan 2 -sticky nw
  incr row
  grid $w.finfo.sc3 -column 0 -row $row  -columnspan 2 -sticky nw
  incr row
  
  ttk::button $w.finfo.sol -text [::tr ShowSolution ] -command ::reviewgame::showSolution
  grid $w.finfo.sol -column 0 -row $row  -sticky nw
  
  ttk::frame $w.fbuttons
  pack $w.fbuttons -fill x
  ttk::button $w.fbuttons.close -textvar ::tr(Abort) -command ::reviewgame::endTraining
  pack $w.fbuttons.close -expand 1 -fill x
  
  if { ! [::reviewgame::launchengine] } {
    tk_messageBox -title "Scid" -icon error -type ok -message "Error launching engine"
    return
  }
  
  set ::reviewgame::prevFen [sc_pos fen]
  ::reviewgame::resetValues
  ::reviewgame::mainLoop
  
  bind $w <Destroy> { ::reviewgame::endTraining }
  bind $w <Configure> "recordWinSize $w"
  bind $w <F1> { helpWindow ReviewGame }
  createToplevelFinalize $w
}
################################################################################
#
################################################################################
proc ::reviewgame::showSolution {} {
  set w $::reviewgame::window
  $w.finfo.sol configure -text "[ sc_game info nextMove ]"
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
  destroy $w
  
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
# Handle the case where position was changed not during normal play but certainly with
# move back / forward / rewind commands
################################################################################
proc ::reviewgame::abnormalContinuation {} {
  ::reviewgame::stopAnalyze
  ::reviewgame::resetValues
  ::windows::gamelist::Refresh
  ::tree::refresh
  ::windows::stats::Refresh
  updateMenuStates
  updateTitle
  updateStatusBar
  updateBoard -pgn
  if { [sc_pos side] == "white" && [::board::isFlipped .main.board] || [sc_pos side] == "black" &&  ![::board::isFlipped .main.board] } {
    ::board::flip .main.board
  }
  set ::reviewgame::prevFen [sc_pos fen]
  ::reviewgame::startAnalyze
  ::reviewgame::mainLoop
}
################################################################################
# waits for the user to play and check the move played
################################################################################
proc ::reviewgame::mainLoop {} {
  global ::reviewgame::prevScore ::reviewgame::prevLine ::reviewgame::analysisEngine ::reviewgame::nextEngineMove
  global ::reviewgame::sequence ::reviewgame::useExtendedTime
  set w $::reviewgame::window
  
  after cancel ::reviewgame::mainLoop
  
  if { $useExtendedTime } {
    set thinkingTime [expr $::reviewgame::timeExtended * 60 ]
  } else {
    set thinkingTime $::reviewgame::timeShort
  }
  
  # if { [sc_pos fen] != $::reviewgame::prevFen } {
  # ::reviewgame::abnormalContinuation
  # return
  # }
  
  # in start position, it must be user's turn
  if { ! [::reviewgame::isPlayerTurn] } {
    ::move::Forward
  }
  
  $w.finfo.proceed configure -state disabled
  $w.finfo.sol configure -state disabled
  # $w.finfo.extended configure -state disabled
  
  # Phase 1 : analyze the move really played during the game
  if {$sequence == 0} {
    $w.finfo.sc1 configure -text ""
    $w.finfo.sc2 configure -text ""
    set ::reviewgame::movePlayed [ sc_game info nextMoveNT ]
    if {$::reviewgame::movePlayed == ""} {
      return
    }
    $w.finfo.pblabel configure -image ReviewGameStop -text "[::tr GameReviewAnalyzingMovePlayedDuringTheGame]"
    ::reviewgame::startAnalyze $thinkingTime $::reviewgame::movePlayed
    vwait ::reviewgame::sequence
    if { $::reviewgame::bailout } { return }
  }
  
  # Phase 2 : find the best engine move in current position
  if { $sequence == 1 } {
    $w.finfo.pblabel configure -image ReviewGameStop -text "[::tr GameReviewAnalyzingThePosition]"
    ::reviewgame::startAnalyze $thinkingTime
    vwait ::reviewgame::sequence
    if { $::reviewgame::bailout } { return }
  }
  
  $w.finfo.pblabel configure -image ReviewGameGreenArrowUp -text "[::tr GameReviewEnterYourMove]"
  $w.finfo.sol configure -state normal
  
  # is this player's turn (which always plays from bottom of the board) ?
  if { [::reviewgame::isPlayerTurn] } {
    after 1000  ::reviewgame::mainLoop
    return
  }
  $w.finfo.sol configure -text "[::tr ShowSolution]"
  
  # Phase 3 : ponder on user's move if different of best engine move and move played
  # We know user has played
  set user_move [sc_game info previousMoveNT]
  
  # ponder on user's move if he did not play the same move as in match
  if {$user_move != $::reviewgame::movePlayed} {
    $w.finfo.pblabel configure -image ReviewGameStop -text "[::tr GameReviewCheckingYourMove]"
    $w.finfo.sc3 configure -text ""
    ::reviewgame::startAnalyze $thinkingTime $user_move
    vwait ::reviewgame::sequence
    if { $::reviewgame::bailout } { return }
    $w.finfo.pblabel configure -image ReviewGameStop -text "[::tr GameReviewYourMoveWasAnalyzed]"
    # display user's score
    $w.finfo.sc3 configure -text "[::tr GameReviewScoreOfYourMove] : $analysisEngine(score,2)"
  }
  
  # User guessed the correct move played in game
  if {$user_move == $::reviewgame::movePlayed } {
    $w.finfo.sc3 configure -text "[::tr GameReviewYouPlayedSameMove]" -foreground green
    set var [sc_var number]
    sc_var exit
    sc_var delete $var
    # updateBoard -pgn
    sc_move forward
    updateBoard -animate -pgn
    # display played move score
    $w.finfo.sc2 configure -text "[::tr GameReviewGameMoveScore] : $analysisEngine(score,1) [::trans $::reviewgame::movePlayed]"
    # display engine's score
    $w.finfo.sc1 configure -text "[::tr GameReviewEngineScore] : $analysisEngine(score,2) [::trans [lindex $analysisEngine(moves,2) 0]]"
    if { $::reviewgame::autoProceed } {
      # guessed the correct move played during the game, so continue directly
      proceed
    }
    $w.finfo.pblabel configure -image ReviewGameGreenArrowUp -text ""
  } elseif { $user_move == [ lindex $analysisEngine(moves,2) 0] || [ isGoodScore $analysisEngine(score,2) $analysisEngine(score,3)  ] } {
    # User guessed engine's move
    if {$user_move == [ lindex $analysisEngine(moves,2) 0]} {
      $w.finfo.sc3 configure -text "[::tr GameReviewYouPlayedLikeTheEngine]" -foreground green
    } else  {
      $w.finfo.sc3 configure -text "[::tr GameReviewNotEngineMoveButGoodMove] : [::trans $user_move] ($analysisEngine(score,3))" -foreground blue
    }
    sc_var exit
    sc_move forward
    updateBoard -animate -pgn
    # display played move score
    $w.finfo.sc2 configure -text "[::tr GameReviewGameMoveScore] : $analysisEngine(score,1) [::trans $::reviewgame::movePlayed]"
    # display engine's score
    $w.finfo.sc1 configure -text "[::tr GameReviewEngineScore] $analysisEngine(score,2) [::trans [lindex $analysisEngine(moves,2) 0]]"
  } else  {
    # user played a bad move : comment it and restart the process
    $w.finfo.sc3 configure -text "[::tr GameReviewMoveNotGood] $analysisEngine(score,3) \n([::trans $analysisEngine(moves,3)])" -foreground red
    sc_pos addNag "?"
    sc_pos setComment "($analysisEngine(score,3)) $analysisEngine(moves,3) Engine : ($analysisEngine(score,2)) \n[::trans $analysisEngine(moves,2)]"
    sc_var exit
    updateBoard -pgn
    
    # allows a re-calculation
    $w.finfo.extended configure -state normal
    
    # display played move score
    $w.finfo.sc2 configure -text "[::tr GameReviewGameMoveScore] : $analysisEngine(score,1)"
    # display engine's score
    $w.finfo.sc1 configure -text "[::tr GameReviewEngineScore] $analysisEngine(score,2)"
    set  ::reviewgame::sequence 2
    after 1000 ::reviewgame::mainLoop
    return
  }
  $w.finfo.proceed configure -state normal
  $w.finfo.extended configure -state normal
  set ::reviewgame::useExtendedTime 0
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
  set ::reviewgame::prevScore 0
  set ::reviewgame::prevLine ""
  set ::reviewgame::nextEngineMove ""
  set ::reviewgame::prevFen ""
  set ::reviewgame::sequence 0
  set ::reviewgame::analysisEngine(analyzeMode) 0
  set ::reviewgame::bailout 0
  set ::reviewgame::useExtendedTime 0
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
    if { [string equal -nocase -length 4 [lindex $e 0] "toga" ] } {
      set engineFound 1
      break
    }
    incr index
  }
  if { ! $engineFound } {
    tk_messageBox -type ok -icon warning -parent . -title "Scid" -message "Unable to find engine.\nPlease configure engine with Toga as name"
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
  
  if {$move != ""} {
    sc_info preMoveCmd {}
    sc_game push copyfast
    ::uci::sc_move_add $move
    set ::analysis(fen$engineSlot) [sc_pos fen]
    sc_game pop
    sc_info preMoveCmd preMoveCommand
  } else  {
    set ::analysis(fen$engineSlot) ""
  }
  ::reviewgame::sendToEngine "position fen [sc_pos fen] $move"
  ::reviewgame::sendToEngine "go infinite ponder"
  after [expr 1000 * $analysisTime] ::reviewgame::stopAnalyze
}
# ======================================================================
# stopAnalyzeMode:
#   Stop the engine analyze mode
# ======================================================================
proc ::reviewgame::stopAnalyze { } {
  global ::reviewgame::analysisEngine ::reviewgame::sequence
  
  # Check that the engine has already had analyze mode started:
  if { ! $analysisEngine(analyzeMode) } { return }
  
  after cancel ::reviewgame::updateProgressBar
  $::reviewgame::window.finfo.pb configure -value 0
  
  incr ::reviewgame::sequence
  set pv [lindex $::analysis(multiPV$::reviewgame::engineSlot) 0]
  set analysisEngine(score,$sequence) [lindex $pv 1]
  set analysisEngine(moves,$sequence) [lindex $pv 2]
  
  set analysisEngine(analyzeMode) 0
  ::reviewgame::sendToEngine  "stop"
  
}
################################################################################
#
################################################################################
proc ::reviewgame::proceed {} {
  # next cycle
  ::move::Forward
  ::reviewgame::resetValues
  set ::reviewgame::prevFen [sc_pos fen]
  after 1000 ::reviewgame::mainLoop
}
################################################################################
# Rethink on the position with extended time
################################################################################
proc ::reviewgame::extendedTime {} {
  
  # if already calculating, to nothing
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
#   returns 1 if the player is allowed to enter a move (pondering is done)
################################################################################
proc ::reviewgame::playerCanMove {} {
  if { ! [winfo exists $::reviewgame::window] } { return 1 }
  
  if { !  [::reviewgame::isPlayerTurn]  } {
    return 0
  } elseif { $::reviewgame::sequence == 2 } {
    return 1
  }
  
  puts "DEBUG : ::reviewgame::playerCanMove returned 0"
  return 0
}

################################################################################
# Image definitions
################################################################################
if { $::png_image_support } {
  image create photo ReviewGameStop -format png -data {
    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
  }
  image create photo ReviewGameGreenArrowUp -format png -data {
    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
  }
} else  {
  image create photo ReviewGameStop -format gif -data {
    R0lGODlhIAAgAOfgAEEEAE4JBF0FAFcKBWgHAmMMAHEGAWQNAHMJA24OAHwHAnYMAH0JA3cO
    AH8LAHgPAIANAHkRAYEOAIkLA4IQAIoNAIMRAIsPAIQTAYYUAIwRAI4SAIcWBI8UAZYQBJcR
    AJAVApgTAJEXA5MYAJIYA5kVAJsWAJQaBJUbAJwYAaQVAJ0ZAp4aAJcdB54bA6AcAJ8cBKEd
    AKgaAJshCqkcAbEZAKodAp0kDJ4lDa0gBLUeALwaA64hBakmDLghAb8eBcAfAKooDaQrErok
    A8IhAKYsE7wlALslBMMiAMoeA7QoCqctFLUpC70nAMQkAKkvFs0iBc4jAMcnAqwxF8goA88l
    AK0yGNEmANIoAK81GsQuDNMpALA2G7I3HNQrAbE3ItYsAq88I7A9JLE+JbM/JbRAJro+ItY2
    BLVBJ9Y2ENE7F7lEKtg5EtQ9ENY/G71JLb1JM79KLthBHcFMMNtEH71PNtdIH8VPM8BSONhJ
    J9tMKcRVO9xNKcZXPcJaQslZP8VcPsRcRNxUMt1VM85dQt9XNdRcP8xiRMtjSslmSshmUNdk
    Q9ZlSddmSsxqU9pnRs9rT9NpT9RqUMtwXNFvWNRxWtxwUONvTORwTeRxVNN3Y9l7YeN3XeV4
    WNx9Y+J8XuR+YN2Aa+V/YeGDaOiBY92GbumCZOeIbeqKb9uRet+PeuyMceiQd+WUf9+XheeV
    euaVgOCYhu2Ue+OYgemXfOuYfeWbg+uZhO2bhuiehu+cgeShjOugiOyhie+kjO2qle+sl+uw
    n/KumeyxoPSwm++zovG0nfC0o/O1nvK3pfO4pvS5p+67rfG8qPa6qPK9qfO+qvS/q/K/sfTA
    svDDs/bDtPfEtfPHtvTIt/XJuPfKufjLu/nMvPTQxPnPxPXSxf//////////////////////
    ////////////////////////////////////////////////////////////////////////
    /////////////////////////////////yH5BAEKAP8ALAAAAAAgACAAAAj+AP8JHEiwoMGD
    CBMqXMjwn4qHDRnG6KFIk6uLk7qoiGgwBp5d2LRly6aNW7dvzBzF4PhvhZVZ1axFo3YN2zVt
    2raZLDbGRcMVZY5FgxbtGaxKiBSVGkYtmjeZfnwqRLEmmbRmylplSTEwRYpAw6LVnFaHa8Ii
    xZw5S0apxMElx5xJi3Y1TMISqpQdKwYJxUEYto4lQ3YMWbJcZg2OKWZM2CYPB1t48kW5Vhhe
    wIABOoiilK9ftmYcJHEIl+lbTzy8wcULltuCJHjh2lXnoAc4tGTlRkPiX4lRsl6NMfhFVi1W
    kAuCyGIKlfM7vf916OP8j4iCcE6torTB4I1RpEz+kQLEgSCX8Iy6D9xwR9QpPOoHtpDUqf6i
    6AOFcOrUKP6/DG9kwkltBHEAiSifYGLJdQU9Yckli1xQUA1enKHEBANhYEYhesihhl8dVTiE
    BQW5UKEWJP5jQRaFDCKIHR5gYFAGTWBxhgwyEpRBGlCccR0FN+ghSB5yBJGicl5AgcVrBEFw
    RI86MACCGmq0kQYTERxEwRFnYEEFBQetsIWSNlABBY9HgGkQBGJCAQUMCEXw5BlJnBHFGU4c
    SRADHvR4BhEQJJRBFXVCQah/A0VAQhVUJAFFBwohgIKbVFDRhAUPEBQBBDxQUSEULmSqUAQt
    ULHFmEnQ0AEFGIhQJhZNWECRBAwNNBSBBTvYmEQVhvJKqKFUlFArRw948AOjVRBK6BlV8EAB
    ASwJNEADINCggxRUDFFDCRAIEG1BAAhAQAIGJHBAAN+mq266AQEAOw==
  }
  image create photo ReviewGameGreenArrowUp -format gif -data {
    R0lGODlhIAAgAOeWADRPADxfATxgATxhAjxiAz1kAz1lBD1nBT1oBkNnBz5qBkNoCENpCT5s
    B0BrBz5tCERrCURsCj9vCT9xCkVuC0VvDD9zCz9zDEFzCT90C0B1DEF2D0F6Dz59DT59ET99
    Ej9/EkB/EUB/Ez+AFECAE0KBEUSBEUGCFEaHF1SYAF6NJV6OJ1eaAVucAWKSKmSULF+fAWSV
    LWSiAmuXMWiaMGyYMmibMWmlAmqcMm6aNG2dNW2eNW+dNmygNm6fNm+pAm6gNm6hNm+hOHCi
    OHWtA3uwBIO0NIO0N4W2NYa2N4i3NYi3OIu5NYu5OI27OI+8NpG9OZK+NpW/OZjBN5nCOZzE
    OZ3FOqHHO6LIPanMQqfKXqnLYK/QRrXUSrnVZLvXVbzYT7zYUL3YZ8HbU8HbVMHbWMHcWsDb
    ZMLba8beV8beWMXeXcfeWMbeXsXeZ8rhYcviW8viXMvhYsziXMnfdczfdMvhcszgeM/kXs/k
    X9DkX8/kZc7id9Dje9PmZ9DketPmaNTnYtLkedHkfdTlfdjpZ9bmfdfpa9TljdbngNrrbtrr
    b9npgNnpgdvqgtvrhNrpk93rhN7sht/shuDued/rmv//////////////////////////////
    ////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////
    ////////////////////////////////////////////////////////////////////////
    /////////////////////////////////yH5BAEKAP8ALAAAAAAgACAAAAj+AP8JHEiwoMGD
    CBMqXMiwocODKB46PBGk0hATEhWO6CGJ0iQhJTIeHIHj0aJCiiIBISGSIAgbjQ4FmnnI0Q4R
    Lf+BoJEIkB48QPP4YeQjhMgPMQjtmQOnadM4ewzp8JDxxR85bNJo3ZpGzRtBPDo8dHGnDZkx
    aNOmJbOGTw4ODVfQMRMGjN27eMGEKVOnxoaFKhANsuPmS5fDiBF/cWOnD6QZDDNomHyGi+XL
    l89M1nABw0MLaLKIHj0ajYWWE8RgWc2atZgJLSV4qUK7dm0vElo+uFKkt2/fVx60bGCFiPHj
    x600aOlgyo/n0KFTUdCyQpQb2LNnl4KgJYUnMsJMixcP5UDLCExgqF+/3omBlhCUtJhPn36T
    Ai0ZIGHBv3//JQS0tIARKRRooIFJDNBSAloc4eCDD24hQEsABGDhhRgGAEBOHHboYUsBAQA7
  }
}
###
### End of file: reviewgame.tcl
###
