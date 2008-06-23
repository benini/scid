### ScidPocket.
### Copyright (C) 2008  Pascal Georges
#
################################################################################
#            T A C T I C A L   T R A I N I N G
################################################################################
namespace eval tactics {
  set prevScore ""
  set prevLine ""
  set nextMove ""
  set matePending 0
  set analysisTime 5
  set isThinking 0
  set running 0
  set lastGameLoaded 0
  set solved "problem solved"
  set failed "problem failed"
  set winWonGame 0
}
##########################################################
proc ::tactics::config {} {
}
##########################################################
proc ::tactics::start {} {
  if { $::tactics::running } {
    # check at least a base is opened for current slot
    if { [sc_base numGames] < 1 } {
      tk_messageBox -title "Scid" -icon warning -type ok -message [::msgcat::mc "Open first a base with tactical exercises"]
      set ::tactics::running 0
      return
    }
    set ::options(addVariationWithoutAsking) 1
    set ::options(showAnalysisOld) $::options(showAnalysis)
    set ::options(showAnalysis) 0
    ::infopanel::updateAnalysis
    set ::tactics::lastGameLoaded 0
    ::tactics::loadNextGame
    ::tactics::mainLoop
  } else {
    setInfo ""
    set ::options(addVariationWithoutAsking) 0
    after cancel ::tactics::mainLoop
    set ::options(showAnalysis) $::options(showAnalysisOld)
    ::infopanel::updateAnalysis
  }
}
##########################################################
proc ::tactics::resetValues {} {
  set ::tactics::prevScore 0
  set ::tactics::prevLine ""
  set ::tactics::nextMove ""
  set ::tactics::matePending 0
  set ::tactics::showSolution 0
  set ::tactics::labelSolution ""
  set ::tactics::prevFen ""
}
##########################################################
proc ::tactics::showSolution {} {
  set l [lindex $::engine::data(multipv1) 0]
  set score [lindex $l 1]
  set pv [lindex $l 2]
  
  if { $score != "" } {
    if { [expr abs($score)] == 327.0 && [lindex $l 3] != "" } {
      set score "M [lindex $l 3]"
    }
  }
  
  tk_messageBox -title "Scid" -icon info -type ok -message "$score\n$pv"
}
################################################################################
# waits for the user to play and check the move played
proc ::tactics::mainLoop {} {
  global ::tactics::prevScore ::tactics::prevLine ::tactics::nextMove
  
  after cancel ::tactics::mainLoop
  
  if {[sc_pos fen] != $::tactics::prevFen && [sc_pos isAt start]} {
    ::tactics::abnormalContinuation
    return
  }
  
  # is this player's turn (which always plays from bottom of the board) ?
  if { [::tactics::isPlayerTurn] } {
    after 1000 ::tactics::mainLoop
    return
  }
  
  set ::tactics::prevFen [sc_pos fen]
  
  # check if player's move is a direct mate : no need to wait for engine analysis in this case
  set move_done [sc_game info previousMove]
  if { [string index $move_done end] == "#"} { ::tactics::exSolved; return }
  
  # if the engine is still analyzing, wait the end of it
  if {$::tactics::isThinking} { vwait ::tactics::isThinking }
  if {[sc_pos fen] != $::tactics::prevFen  && [sc_pos isAt start]} {
    ::tactics::abnormalContinuation
    return
  }
  
  # the player moved and analysis is over : check if his move was as good as expected
  set l [lindex $::engine::data(multipv1) 0]
  set prevScore [lindex $l 1]
  set prevLine [lindex $l 2]
  
  ::tactics::startAnalyze
  
  # now wait for the end of analyzis
  if {$::tactics::isThinking} { vwait ::tactics::isThinking }
  if {[sc_pos fen] != $::tactics::prevFen  && [sc_pos isAt start]} {
    ::tactics::abnormalContinuation
    return
  }
  
  # compare results
  set res [::tactics::foundBestLine]
  
  if {  $res != ""} {
    tk_messageBox -title "Scid" -icon info -type ok -message "[::msgcat::mc [list Best solution not found]]\n$res"
    # take back last move so restore engine status
    # TODO : à virer ou utile ??
    #  ****************************************************************************************
    # set analysisEngine(score) $prevScore
    # set analysisEngine(moves) $prevLine
    sc_game tags set -site $::tactics::failed
    sc_game save [sc_game number]
    sc_move back
    ::board::updateBoard -pgn
    set ::tactics::prevFen [sc_pos fen]
  } else  {
    catch { sc_move addSan [::untrans $nextMove] }
    set ::tactics::prevFen [sc_pos fen]
    ::board::updateBoard -pgn
    if { $::tactics::matePending } {
      # continue until end of game
    } else  {
      sc_game tags set -site $::tactics::solved
      sc_game save [sc_game number]
      tk_messageBox -title "Scid" -icon info -type ok -message [::msgcat::mc "Good move"]
      loadNextGame
      return
    }
  }
  
  after 1000 ::tactics::mainLoop
}
################################################################################
proc ::tactics::isPlayerTurn {} {
  if { [sc_pos side] == "white" &&  ! $::board::isFlipped || [sc_pos side] == "black" &&  $::board::isFlipped } {
    return 1
  }
  return 0
}
################################################################################
proc ::tactics::exSolved {} {
  ::tactics::stopAnalyze
  tk_messageBox -title "Scid" -icon info -type ok -message [::msgcat::mc "Mate found"]
  sc_game tags set -site $::tactics::solved
  sc_game save [sc_game number]
  ::tactics::loadNextGame
}
################################################################################
proc ::tactics::loadNextGame {} {
  ::tactics::resetValues
  
  set newGameFound 0
  # find a game with site tag != problem solved
  for {set g [ expr $::tactics::lastGameLoaded +1 ] } { $g <= [sc_base numGames]} { incr g} {
    # sc_game load $g
    ::game::gameLoad $g
    set tag [sc_game tags get "Site"]
    if {$tag != $::tactics::solved} { set newGameFound 1 ; break }
  }
  # it seems we finished the serial
  if {! $newGameFound } {
    tk_messageBox -title "Scid" -icon info -type ok -message [::msgcat::mc "All exercises done"]
    return
  }
  set ::tactics::lastGameLoaded $g
  
  if { [sc_pos side] == "white" && $::board::isFlipped || [sc_pos side] == "black" &&  ! $::board::isFlipped } {
    ::board::toggleFlip
  }
  
  ::board::updateBoard -pgn
  set ::tactics::prevFen [sc_pos fen]
  
  ::tactics::startAnalyze
  ::tactics::mainLoop
}
##########################################################
proc ::tactics::startAnalyze {} {
  ::engine::startAnalysis 1
  set ::tactics::isThinking 1
  setInfo [::msgcat::mc "Thinking, wait before entering your move"] IndianRed
  after [expr 1000 * $::tactics::analysisTime] ::tactics::stopAnalyze
}
##########################################################
proc ::tactics::stopAnalyze {} {
  ::engine::stopAnalysis 1
  set ::tactics::isThinking 0
  setInfo [::msgcat::mc "Analyze done"] ForestGreen
}
##########################################################
proc ::tactics::foundBestLine {} {
  global ::tactics::prevScore ::tactics::prevLine ::tactics::nextMove ::tactics::matePending
  
  set l [lindex $::engine::data(multipv1) 0]
  set score [lindex $l 1]
  set line [lindex $l 2]
  
  set s [ regsub -all "\[\.\]{3} " $line "" ]
  set s [ regsub -all "\[0-9\]+\[\.\] " $s "" ]
  set nextMove [ lindex [ split $s ] 0 ]
  set ply [ llength [split $s] ]
  
  # check if the player played the same move predicted by Engine
  set s [ regsub -all "\[\.\]{3} " $prevLine "" ]
  set s [ regsub -all "\[0-9\]+\[\.\] " $s "" ]
  set prevBestMove [ lindex [ split $s ] 1 ]
  
  if { [sc_game info previousMoveNT] == $prevBestMove} {
    return ""
  }
  
  # Case of mate
  if { [string index $prevLine end] == "#"} {
    set matePending 1
    #  Engine may find a mate then put a score != 300 but rather 10
    if {[string index $line end] != "#"} {
      # Engine line does not end with a # but the score is a mate (we can't count plies here)
      if {[sc_pos side] == "white" && $score < -300 || [sc_pos side] == "black" && $score > 300} {
        return ""
      }
      if {! $::tactics::winWonGame } {
        return [::msgcat::mc "Mate not found"]
      } else  {
        # win won game but still have to find a mate
        if {[sc_pos side] == "white" && $score < -300 || [sc_pos side] == "black" && $score > 300} {
          return ""
        } else  {
          return [::msgcat::mc "Mate not found"]
        }
      }
    }
    # Engine found a mate, search in how many plies
    set s [ regsub -all "\[\.\]{3} " $prevLine "" ]
    set s [ regsub -all "\[0-9\]+\[\.\] " $s "" ]
    set prevPly [ llength [ split $s ] ]
    if { $ply > [ expr $prevPly - 1 ] && ! $::tactics::winWonGame } {
      return [::msgcat::mc "Shorter mate exists"]
    } else  {
      return ""
    }
  } else  {
    # no mate case
    set matePending 0
    set threshold 0.5
    if {$::tactics::winWonGame} {
      # Only alert when the advantage clearly changes side
      if {[sc_pos side] == "white" && $prevScore < 0 && $score >= $threshold  || \
            [sc_pos side] == "black" &&  $prevScore >= 0 && $score < [expr 0 - $threshold]  } {
        return "[::msgcat::mc [list Score played]] $score\n$[::msgcat::mc Expected] $prevScore"
      } else  {
        return ""
      }
    }
    if {[ expr abs($prevScore) ] > 3.0 } { set threshold 1.0 }
    if {[ expr abs($prevScore) ] > 5.0 } { set threshold 1.5 }
    # the player moved : score is from opponent side
    if {[sc_pos side] == "white" && $score < [ expr $prevScore + $threshold ] || \
          [sc_pos side] == "black" && $score > [ expr $prevScore - $threshold ] } {
      return ""
    } else  {
      return "[::msgcat::mc [list Score played]] $score\n[::msgcat::mc Expected] $prevScore"
    }
  }
}
################################################################################
# Handle the case where position was changed not during normal play but certainly with
# move back / forward / rewind commands
################################################################################
proc ::tactics::abnormalContinuation {} {
  ::tactics::stopAnalyze
  ::tactics::resetValues
  
  ::board::updateBoard -pgn
  if { [sc_pos side] == "white" && $::board::isFlipped || [sc_pos side] == "black" &&  ! $::board::isFlipped } {
    ::board::toggleFlip
  }
  set ::tactics::prevFen [sc_pos fen]
  ::tactics::startAnalyze
  ::tactics::mainLoop
}
################################################################################
proc ::tactics::resetScores {} {
  global ::tactics::cancelScoreReset
  
  #reset site tag for each game
  progressWindow "Scid" "Resetting score" "Cancel" ::tactics::sc_progressBar
  set numGames [sc_base numGames]
  set cancelScoreReset 0
  for {set g 1} { $g <= $numGames } { incr g} {
    if { $cancelScoreReset } { break }
    sc_game load $g
    if { [sc_game tags get "Site"] != ""} {
      sc_game tags set -site ""
      sc_game save [sc_game number]
    }
    if { [expr $g % 10] == 0 } {
      updateProgressWindow $g $numGames
    }
  }
  closeProgressWindow
  
}
################################################################################
# cancel score reset loading
################################################################################
proc ::tactics::sc_progressBar {} {
  set ::tactics::cancelScoreReset 1
}
################################################################################
proc ::tactics::setInfo { msg {bg white} } {
  # $w tag configure enginescore -foreground red -background black -relief raised -border 1 -font fontanalysis
  set w .fEngine.text
  $w delete 1.0 end
  $w configure -bg $bg
  $w insert end $msg enginescore
}

