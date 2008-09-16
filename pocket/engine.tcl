### ScidPocket.
### Copyright (C) 2007  Pascal Georges
################################################################################
#
################################################################################

namespace eval engine {
  array set data {}
  set infoToken { depth seldepth time nodes pv multipv score cp mate lowerbound upperbound \
        currmove currmovenumber hashfull nps tbhits sbhits cpuload string refutation currline }
  set optionToken {name type default min max var }
  set isOpening 0
  set chosenOpening ""
  set openingMovesList {}
  set openingMovesHash {}
  set openingMoves ""
  set isTurn 1
  set priority 251
  
  trace add variable ::tournamentMode write ::engine::traceTournamentMode
  # ##################################################################
  proc traceTournamentMode { name1 name2 op } {
    if { ! $::tournamentMode } {
      catch {
        sendToEngine "stop" 1
        sendToEngine "stop" 2
        ::gameclock::delete 1
        ::gameclock::delete 2
      }
    }
  }
  # ##################################################################
  proc reset {{n 1}} {
    global ::engine::data
    set data(sock$n) ""
    set data(serversock$n) ""
    set data(depth$n) 0
    set data(seldepth$n) 0
    set data(time$n) 0 ;# msec
    set data(bestmove$n) ""
    set data(ponder$n) ""
    set data(pv$n) ""
    set data(score$n) ""
    set data(scoremate$n) ""
    set data(nps$n) 0
    set data(nodes$n) 0
    set data(multipv$n) {}
    set data(multipvnum$n) 0
    set data(uciok$n) 0
    set data(readyok$n) 0
    set data(waitForBestMove$n) 0
    set data(waitForReadyOk$n) 0
    set data(name$n) ""
    set data(currmove$n) ""
    set data(currmovenumber$n) 0
    set data(hashfull$n) 0
    set data(tbhits$n) 0
    set data(sbhits$n) 0
    set data(cpuload$n) 0
    set data(running$n) 0
  }
  # ##################################################################
  proc resetAnalysis { n } {
    global ::engine::data
    set data(depth$n) 0
    set data(bestmove$n) ""
    set data(ponder$n) ""
    set data(pv$n) ""
    set data(score$n) ""
    set data(nps$n) 0
    set data(nodes$n) 0
    set data(multipvnum$n) 0
  }
  # ##################################################################
  proc setMultiPv { n } {
    if {$::options(engine$n) == "" } {return}
    
    if { $::options(multipv) != 1 } {
      set ::options(engineOptimizeSpeed) 0
      set ::options(engineUCIFormat) 1
    }
    
    if { ! [isUci $n] } { set ::options(multipv) 1 }
    
    if { [lindex $::engineconfig($::options(engine$n)) 3] == "MultiPV_NO" && $::options(multipv) != 1} {
      set ::options(multipv) 1
      tk_messageBox -type ok -icon warning -parent . -title [::msgcat::mc "Best lines"] -message "Engine [getName $n]\ndoes not support Multi PV"
      return
    }
    
    set restartAnalysis $::engine::data(running$n)
    stopAnalysis $n
    sendToEngine "setoption name MultiPV value $::options(multipv)" $n
    # resetAnalysis $n
    if {$restartAnalysis} {
      startAnalysis $n
    }
  }
  # ##################################################################
  # will try to set engines hash to the desired value (or /2^n)
  proc setHash { } {
    set running1 $::engine::data(running1)
    stopAnalysis 1
    if {$::options(engine2) != "" } {
      set running2 $::engine::data(running2)
    } else {
      set running2 0
      stopAnalysis 2
    }
    
    for {set h $::options(enginehash)} {$h>=64} { set h [expr $h / 2]} {
      if {[isUci 1]} {
        sendToEngine "setoption name Hash value $::options(enginehash)" 1
      } else {
        sendToEngine "sethash $::options(enginehash)" 1
      }
      if { $::options(engine2) != "" } {
        if { [ isUci 2 ] } {
          sendToEngine "setoption name Hash value $::options(enginehash)" 2
        } else {
          sendToEngine "sethash $::options(enginehash)" 2
        }
      }
      
      after 100
      if {$::options(engine2) != "" } {
        if { ![ isUci 2 ] } { break }
        if { [checkEngineAlive 1] && [checkEngineAlive 2] } {
          break
        } else {
          tk_messageBox -type ok -icon error -parent . -title "Hash" -message "Hash memory too high $h\trying a lower value"
        }
      } else {
        if { ![ isUci 1 ] } { break }
        if { [checkEngineAlive 1] } {
          break
        } else {
          tk_messageBox -type ok -icon error -parent . -title "Hash" -message "Hash memory too high $h\trying a lower value"
        }
      }
      
    }
    
    set ::options(enginehash) $h
    
    if {$running1} { startAnalysis 1 }
    if {$running2} { startAnalysis 2 }
    
  }
  
  # ##################################################################
  proc startAnalysis { n } {
    if {$::engine::data(running$n)} { return }
    
    if { $::engine::data(running$n) == -1 } { return }
    
    set ::engine::data(running$n) -1
    
    if { ! [isUci $n] } {
      sendToEngine "setboard [sc_pos fen]" $n
      sendToEngine "analyze" $n
    } else {
      set ::engine::data(waitForReadyOk$n) 1
      sendToEngine "isready" $n
      ::vwaitTimed ::engine::data(waitForReadyOk$n) 3000 nowarnuser
      ::engine::resetAnalysis $n
      ::infopanel::updateAnalysis $n
      sendToEngine "position fen [sc_pos fen]" $n
      sendToEngine "go infinite ponder" $n
    }
    
    set ::engine::data(running$n) 1
  }
  # ##################################################################
  proc stopAnalysis { n } {
    if { $::options(engine$n) == "" } { return }
    if {!$::engine::data(running$n)} { return }
    
    if { $::engine::data(running$n) == -1 } { return }
    
    set ::engine::data(running$n) -1
    
    set ::engine::data(waitForBestMove$n) 1
    if { ! [isUci $n] } {
      sendToEngine "exit" $n
    } else {
      sendToEngine "stop" $n
    }
    ::vwaitTimed ::engine::data(waitForBestMove$n) 1000 "nowarning"
    
    set ::engine::data(running$n) 0
    set ::engine::data(cpuload$n) 0
    ::infopanel::updateAnalysis $n
  }
  # ##################################################################
  proc associate { } {
    set w .associate
    if {[winfo exists $w]} { return }
    
    toplevel $w
    wm title $w [::msgcat::mc "Engines"]
    ::ui::setTopmost $w
    ttk::frame $w.f1
    ttk::frame $w.f2
    pack $w.f1 $w.f2 -fill x
    
    ttk::label $w.f1.l -text [::msgcat::mc "Configure engines"] -anchor w
    
    set leng {}
    foreach eng [ lsort [ array names ::engineconfig ] ] {
      lappend leng "[lindex $::engineconfig($eng) 0] [lindex $::engineconfig($eng) 1]"
    }
    
    ttk::combobox $w.f1.eng1 -width 20 -values [concat $leng [::msgcat::mc "<none>"]]
    ttk::combobox $w.f1.eng2 -width 20 -values [concat $leng [::msgcat::mc "<none>"]]
    
    $w.f1.eng1 set "[lindex $::engineconfig($::options(engine1)) 0] [lindex $::engineconfig($::options(engine1)) 1]"
    if { [catch {$w.f1.eng2 set "[lindex $::engineconfig($::options(engine2)) 0] [lindex $::engineconfig($::options(engine2)) 1]"}]} {
      $w.f1.eng2 set [::msgcat::mc "<none>"]
    }
    
    $w.f1.eng1 configure -state readonly
    $w.f1.eng2 configure -state readonly
    
    pack $w.f1.l $w.f1.eng1 $w.f1.eng2
    ttk::button $w.f2.ok -text Ok -command { ::engine::doAssociate ; destroy .associate }
    ttk::button $w.f2.cancel -text Cancel -command { destroy .associate }
    pack $w.f2.ok $w.f2.cancel -side left
  }
  # ##################################################################
  proc doAssociate {} {
    set neweng1 [ .associate.f1.eng1 get ]
    set neweng2 [ .associate.f1.eng2 get ]
    
    set eng1 ""
    set eng2 ""
    foreach eng [ array names ::engineconfig ] {
      if { $neweng1 == "[lindex $::engineconfig($eng) 0] [lindex $::engineconfig($eng) 1]" } {
        set eng1 $eng
      }
      if { $neweng2 == "[lindex $::engineconfig($eng) 0] [lindex $::engineconfig($eng) 1]" } {
        set eng2 $eng
      }
    }
    
    if {$eng1 == $eng2} {
      tk_messageBox -type ok -icon error -parent . -title [::msgcat::mc "Engines" ] -message [::msgcat::mc "Engines 1 & 2 must be different"]
      return
    }
    
    set todoInit1 0
    set todoInit2 0
    
    if {$eng1 != $::options(engine1) } {
      unload 1
      set ::options(engine1) $eng1
      set todoInit1 1
    }
    
    if {$eng2 != $::options(engine2) } {
      if { $::options(engine2) != "" } { unload 2 }
      set ::options(engine2) $eng2
      
      if {$::options(engine2) != ""} {
        set todoInit2 1
      }
    }
    
    if { $todoInit1 } { init 1 }
    if { $todoInit2 } { init 2 }
    
    setHash
    
    if { ! [isUci 1] } {
      set ::options(multipv) 1
      ::engine::setMultiPv 1
    }
    
  }
  # ##################################################################
  proc tournament {} {
    if { ! $::tournamentMode } { return }
    
    set w .tournament
    
    if {[winfo exists $w]} {
      focus $w
      return
    }
    
    if {$::options(engine2) == "" } {
      tk_messageBox -type ok -icon info -parent . -title [::msgcat::mc "Tournament"] -message [::msgcat::mc "Engine #2 not configured"]
      set ::tournamentMode 0
      return
    }
    
    toplevel $w
    wm title $w [::msgcat::mc "Tournament"]
    ::ui::setFullSize $w
    
    ttk::frame $w.fnb
    ttk::frame $w.fdown
    pack [ttk::notebook $w.fnb.nb] -fill both -expand 1
    
    # --------------- Time frame ---------------------
    $w.fnb.nb add [ttk::frame $w.fnb.nb.time] -text [::msgcat::mc "time"]
    set nb1 $w.fnb.nb.time
    
    set row 0
    
    ttk::radiobutton $nb1.rb1 -text [::msgcat::mc "Time bonus"] -value "timebonus" -variable ::options(engine_timeMode)
    grid $nb1.rb1 -row $row -column 0 -sticky w
    incr row
    ttk::label $nb1.lb1 -text [::msgcat::mc "White time"]
    grid $nb1.lb1 -row $row -column 0 -sticky w
    incr row
    spinbox $nb1.spW1 -textvar ::options(engine_wtime) -background white -width 4 -from 1 -to 120 -increment 1 -validate all -vcmd { regexp {^[0-9]+$} %P }
    spinbox $nb1.spW2 -textvar ::options(engine_winc) -background white -width 4 -from 0 -to 60 -increment 1 -validate all -vcmd { regexp {^[0-9]+$} %P }
    grid $nb1.spW1 -row $row -column 0 -sticky w
    grid $nb1.spW2  -row $row -column 1 -sticky w
    incr row
    
    ttk::label $nb1.lb2 -text [::msgcat::mc "Black time"]
    grid $nb1.lb2 -row $row -column 0 -sticky w
    incr row
    spinbox $nb1.spB1 -textvar ::options(engine_btime) -background white -width 4 -from 1 -to 120 -increment 1 -validate all -vcmd { regexp {^[0-9]+$} %P }
    spinbox $nb1.spB2 -textvar ::options(engine_binc) -background white -width 4 -from 0 -to 60 -increment 1 -validate all -vcmd { regexp {^[0-9]+$} %P }
    grid $nb1.spB1 -row $row -column 0 -sticky w
    grid $nb1.spB2  -row $row -column 1 -sticky w
    incr row
    
    ttk::radiobutton $nb1.rb2 -text [::msgcat::mc "Fixed depth"] -value "depth" -variable ::options(engine_timeMode)
    spinbox $nb1.sbDepth -background white -width 2 -from 1 -to 20 -increment 1 -validate all -vcmd { regexp {^[0-9]+$} %P }
    $nb1.sbDepth set 3
    
    ttk::radiobutton $nb1.rb3 -text [::msgcat::mc "Nodes (x1000)"] -value "nodes" -variable ::options(engine_timeMode)
    spinbox $nb1.sbNodes -background white -width 5 -from 5 -to 10000 -increment 5 -validate all -vcmd { regexp {^[0-9]+$} %P }
    $nb1.sbNodes set 10
    
    ttk::radiobutton $nb1.rb4 -text [::msgcat::mc "Sec / move"] -value "movetime" -variable ::options(engine_timeMode)
    spinbox $nb1.sbMoveTime -background white -width 3 -from 1 -to 120 -increment 1 -validate all -vcmd { regexp {^[0-9]+$} %P }
    $nb1.sbMoveTime set 5
    
    grid $nb1.rb2 -row $row -column 0 -sticky w
    grid $nb1.sbDepth -row $row -column 1 -sticky w
    incr row
    grid $nb1.rb3 -row $row -column 0 -sticky w
    grid $nb1.sbNodes -row $row -column 1 -sticky w
    incr row
    grid $nb1.rb4 -row $row -column 0 -sticky w
    grid $nb1.sbMoveTime -row $row -column 1 -sticky w
    incr row
    
    # --------------- Other settings frame -----------
    $w.fnb.nb add [ttk::frame $w.fnb.nb.settings] -text [::msgcat::mc "settings"]
    set nb2 $w.fnb.nb.settings
    
    ttk::frame $nb2.fbook -relief groove -borderwidth 1
    ttk::frame $nb2.fopening -relief groove -borderwidth 1
    ttk::frame $nb2.fgames -relief groove -borderwidth 1
    pack $nb2.fopening -side top -fill both -expand 1
    pack $nb2.fbook -side top -fill both -expand 1
    pack $nb2.fgames -side top -fill both -expand 1
    
    # load book names
    ttk::checkbutton $nb2.fbook.cbUseBook -text [::msgcat::mc "Use book"] -variable ::options(engine_useBook)
    set bookPath [file join $::instalDir "books" ]
    
    set bookList [ lsort -dictionary [ glob -nocomplain -tails -directory $bookPath *.bin ] ]
    set i 0
    set idx 0
    set lbook {}
    foreach file  $bookList {
      set f [file rootname [ file tail $file ] ]
      set lbook [concat $lbook $f]
    }
    
    ttk::combobox $nb2.fbook.combo -state readonly -width 12 -values $lbook
    
    $nb2.fbook.combo set [file rootname $::options(engine_bookToUse) ]
    pack $nb2.fbook.cbUseBook $nb2.fbook.combo -expand yes -fill both -side top
    
    # choose a specific opening
    ttk::checkbutton $nb2.fopening.cbOpening -text [::msgcat::mc "Specific opening"] -variable ::game::isOpening
    ttk::frame $nb2.fopening.fOpeningList -relief raised -borderwidth 1
    listbox $nb2.fopening.fOpeningList.lbOpening -yscrollcommand "$nb2.fopening.fOpeningList.ybar set" -xscrollcommand "$nb2.fopening.fOpeningList.xbar set" \
        -height 5 -list ::game::openingList -exportselection 0 ; # -width 50
    $nb2.fopening.fOpeningList.lbOpening selection set $::options(game_specificOpening)
    
    ttk::scrollbar $nb2.fopening.fOpeningList.ybar -command "$nb2.fopening.fOpeningList.lbOpening yview"
    ttk::scrollbar $nb2.fopening.fOpeningList.xbar -orient horiz -command "$nb2.fopening.fOpeningList.lbOpening xview"
    
    grid $nb2.fopening.fOpeningList.lbOpening -row 0 -column 0 -sticky nsew
    grid $nb2.fopening.fOpeningList.ybar -row 0 -column 1 -sticky ns
    grid $nb2.fopening.fOpeningList.xbar -row 1 -column 0 -sticky ew
    grid rowconfigure $nb2.fopening.fOpeningList 0 -weight 1
    grid columnconfigure $nb2.fopening.fOpeningList 0 -weight 1
    
    pack $nb2.fopening.cbOpening -fill x -side top
    pack $nb2.fopening.fOpeningList -expand yes -fill both -side top
    
    spinbox $nb2.fgames.sp -background yellow -width 3 -from 1 -to 200 -increment 1 -validate all -textvariable ::options(tournamentRounds) -vcmd { regexp {^[0-9]+$} %P }
    pack $nb2.fgames.sp
    
    # ------------- Bottom buttons -----------------
    ttk::button $w.fdown.close -text [::msgcat::mc "Play"] -command {
      focus .
      
      set nb1 .tournament.fnb.nb.time
      set nb2 .tournament.fnb.nb.settings
      
      set ::engine::chosenOpening [$nb2.fopening.fOpeningList.lbOpening curselection]
      if {$::options(engine_useBook)} {
        set ::options(engine_bookToUse) "[$nb2.fbook.combo get].bin"
      }
      set ::engine::data(wtime1) [expr [$nb1.spW1 get]*1000*60]
      set ::engine::data(btime1) [expr [$nb1.spB1 get]*1000*60]
      set ::engine::data(winc1) [expr [$nb1.spW2 get]*1000]
      set ::engine::data(binc1) [expr [$nb1.spB2 get]*1000]
      set ::engine::data(fixeddepth1) [$nb1.sbDepth get]
      set ::engine::data(fixednodes1) [expr [$nb1.sbNodes get]*1000]
      set ::engine::data(movetime1) [expr [$nb1.sbMoveTime get]*1000]
      
      if {$::options(engine_timeMode) == "depth" || $::options(engine_timeMode) == "nodes" || $::options(engine_timeMode) == "movetime"} {
        set ::engine::data(wtime1) 0
        set ::engine::data(btime1) 0
        set ::engine::data(winc1) 0
        set ::engine::data(binc1) 0
      }
      
      set ::engine::data(wtime2) $::engine::data(wtime1)
      set ::engine::data(btime2) $::engine::data(btime1)
      set ::engine::data(winc2) $::engine::data(winc1)
      set ::engine::data(binc2) $::engine::data(binc1)
      set ::engine::data(fixeddepth2) $::engine::data(fixeddepth1)
      set ::engine::data(fixednodes2) $::engine::data(fixednodes1)
      set ::engine::data(movetime2) $::engine::data(movetime1)
      
      destroy .tournament
      update
      ::engine::tournamentRun
    }
    
    ttk::button $w.fdown.cancel -text [::msgcat::mc "Cancel"] -command "focus .; destroy .tournament ; set ::tournamentMode 0"
    
    pack $w.fdown.close $w.fdown.cancel -expand yes -side left -padx 20 -pady 2
    
    pack $w.fnb -fill both -side top -expand 1
    pack $w.fdown -side top -fill x
  }
  # ##################################################################
  proc tournamentRun {} {
    global ::engine::chosenOpening ::engine::isOpening ::game::openingList ::engine::openingMovesList \
        ::engine::openingMovesHash ::engine::openingMoves ::engine::isTurn
    
    ::gameclock::new .fTop.fr.fclocks 2 1
    ::gameclock::new .fTop.fr.fclocks 1 1
    ::gameclock::reset 1
    ::gameclock::reset 2
    ::gameclock::setColor 1 "black"
    ::gameclock::setColor 2 "white"
    
    # if will follow a specific opening line
    if {$isOpening} {
      set fields [split [lindex $openingList $chosenOpening] ":"]
      set openingName [lindex $fields 0]
      set openingMoves [string trim [lindex $fields 1]]
      set openingMovesList ""
      set openingMovesHash ""
      foreach m [split $openingMoves] {
        # in case of multiple adjacent spaces in opening line
        if {$m =={}} {
          continue
        }
        set p [string trim $m]
        lappend openingMovesList [string trim [regsub {^[1-9]+\.} $p ""] ]
      }
      
      sc_game new
      lappend openingMovesHash [sc_pos hash]
      foreach m  $openingMovesList {
        ::game::moveAdd $m
        lappend openingMovesHash [sc_pos hash]
      }
    }
    
    array set ::engine::score {}
    set ::engine::score(1) 0.0
    set ::engine::score(2) 0.0
    for {set ::engine::currentRound 1} {$::engine::currentRound <= $::options(tournamentRounds)} {incr ::engine::currentRound} {
      # create a new game if a DB is opened
      sc_game new
      sc_game tags set -event "$::options(engine1) vs $::options(engine2)"
      sc_game tags set -round "$::engine::currentRound"
      
      if {$::engine::currentRound % 2 == 1} {
        set isTurn 1
        set white [::engine::getName 1]
        set black [::engine::getName 2]
        set sc "$::engine::score(1)-$::engine::score(2)"
      } else {
        set isTurn 2
        set white [::engine::getName 2]
        set black [::engine::getName 1]
        set sc "$::engine::score(2)-$::engine::score(1)"
      }
      
      sc_game tags set -white $white
      sc_game tags set -black $black
      wm title . "$sc $white-$black"
      
      sc_game tags set -date [::utils::date::today]
      if {[sc_base inUse [sc_base current]]} { catch {sc_game save 0}  }
      
      ::board::updateBoard -pgn -nolastmove
      
      # setup clocks
      if {$::options(engine_timeMode) == "timebonus"} {
        ::gameclock::setdSec 2 [expr $::engine::data(wtime1)/100]
        ::gameclock::setdSec 1 [expr $::engine::data(btime1)/100]
      } elseif {$::options(engine_timeMode) == "depth" || $::options(engine_timeMode) == "nodes" || $::options(engine_timeMode) == "movetime"} {
        ::gameclock::setdSec 1 0
        ::gameclock::setdSec 2 0
      }
      set ::engine::wentOutOfBook 0
      set ::engine::gameEnded 0
      ::gameclock::start [getClock 1]
      
      ::game::repetitionReset
      
      while { !$::engine::gameEnded && $::tournamentMode } {
        tournamentEngineGo $isTurn
        # case of game adjudication by user
        if {$::engine::gameEnded} { break }
        
        # if halfmove is resetted, clear list of FEN used by repetition detection
        if { [lindex [split [sc_pos fen]] 4] == 0 } { set ::game::lFen {} }
        
        if { [::game::repetition 0] } {
          set ::engine::score(1) [expr $::engine::score(1) + 0.5]
          set ::engine::score(2) [expr $::engine::score(2) + 0.5]
          set ::engine::gameEnded 1
          sc_game tags set -result "1/2-1/2"
          break
        }
        
        if { [::game::endOfGame] } {
          set ::engine::score($isTurn) [expr $::engine::score($isTurn) + 1.0]
          if {[sc_pos side] == "black" } {
            sc_game tags set -result "1-0"
          } else {
            sc_game tags set -result "0-1"
          }
          set ::engine::gameEnded 1
          break
        }
        
        set isTurn [oppN $isTurn]
      }
      
      sc_game save [sc_game number]
      
      if {! $::tournamentMode} {break}
      
    }
    
    set ::tournamentMode 0
    wm title . "$::engine::score(1)-$::engine::score(2) $::options(engine1) $::options(engine2)"
    tk_messageBox -type ok -icon info -parent . -title [::msgcat::mc "Tournament"] \
        -message "[::msgcat::mc Result]\n[::engine::getName 1] : $::engine::score(1)\n[::engine::getName 2] : $::engine::score(2)"
    
  }
  ################################################################################
  proc setGameResult { op } {
    if { !$::tournamentMode } { return }
    
    set ::engine::gameEnded 1
    sendToEngine "stop" 1
    sendToEngine "stop" 2
    
    if { $op == "White wins" } {
      if { [getEngineColor 1] == "white" } {
        set ::engine::score(1) [expr $::engine::score(1) + 1.0]
      } else {
        set ::engine::score(2) [expr $::engine::score(2) + 1.0]
      }
    }
    if { $op == "Black wins" } {
      if { [getEngineColor 1] == "black" } {
        set ::engine::score(1) [expr $::engine::score(1) + 1.0]
      } else {
        set ::engine::score(2) [expr $::engine::score(2) + 1.0]
      }
    }
    if { $op == "Draw" } {
      set ::engine::score(1) [expr $::engine::score(1) + 0.5]
      set ::engine::score(2) [expr $::engine::score(2) + 0.5]
    }
  }
  ################################################################################
  proc getEngineColor { n } {
    if {$::engine::currentRound % 2 == 1} {
      if {$n == 1} {
        return "white"
      } else {
        return "black"
      }
    } else {
      if {$n == 1} {
        return "black"
      } else {
        return "white"
      }
    }
  }
  # ##################################################################
  proc oppN { n } {
    if {$n == 1} {return 2} else {return 1}
  }
  # ##################################################################
  proc getClock { n } {
    if { [getEngineColor $n] == "white"} {
      return 2
    } else {
      return 1
    }
  }
  # ##################################################################
  proc tournamentEngineGo { n } {
    global ::engine::isOpening ::engine::openingMovesList ::engine::openingMovesHash ::engine::openingMoves
    
    if { [::game::endOfGame] } { return }
    
    # make a move corresponding to a specific opening
    if {$isOpening} {
      set index 0
      
      set hpos [sc_pos hash]
      # Find a corresponding position in the opening line
      set length [llength $openingMovesHash]
      for {set i 0}   { $i < [expr $length-1] } { incr i } {
        set h [lindex $openingMovesHash $i]
        if {$h == $hpos} {
          set index [lsearch $openingMovesHash $h]
          set move [lindex $openingMovesList $index]
          # play the move
          ::game::moveAdd $move
          ::board::updateBoard -pgn
          update
          after 300
          ::gameclock::stop [getClock $n]
          ::gameclock::start [oppN [getClock $n]]
          
          if { [::engine::getEngineColor $n] == "white" } {
            ::gameclock::add [getClock $n] $::engine::data(winc$n)/1000
          } else  {
            ::gameclock::add [getClock $n] $::engine::data(binc$n)/1000
          }
          return
        }
      }
    }
    
    # use a book
    
    if {$::options(engine_useBook) && ! $::engine::wentOutOfBook} {
      set move [ ::book::getMove $::options(engine_bookToUse) [sc_pos fen] $::game::bookSlot]
      if {$move == ""} {
        set ::engine::wentOutOfBook 1
      } else  {
        ::game::moveAdd $move
        ::board::updateBoard -pgn
        update
        after 300
        ::gameclock::stop [ getClock $n ]
        ::gameclock::start [ oppN [ getClock $n ] ]
        if {$::options(engine_timeMode) == "timebonus"} {
          if { [::engine::getEngineColor $n] == "white" } {
            ::gameclock::add [getClock $n] $::engine::data(winc$n)/1000
          } else  {
            ::gameclock::add [getClock $n] $::engine::data(binc$n)/1000
          }
        }
        return
      }
    }
    
    if {[isUci $n]} {
      ::engine::sendToEngine "position fen [sc_pos fen]" $n
    } else {
      ::engine::sendToEngine "setboard [sc_pos fen]" $n
    }
    
    set wtime [expr [::gameclock::getdSec 2] * 100 ]
    set btime [expr [::gameclock::getdSec 1] * 100 ]
    
    # Send to the engine values with at least 1 second on each clock, even if the flag is down
    if {$wtime < 1000} {set wtime 1000}
    if {$btime < 1000} {set btime 1000}
    
    if {[isUci $n]} {
      if {$::options(engine_timeMode) == "timebonus"} {
        ::engine::sendToEngine "go wtime $wtime btime $btime winc $::engine::data(winc$n) binc $::engine::data(binc$n)" $n
      } elseif {$::options(engine_timeMode) == "depth"} {
        ::engine::sendToEngine "go depth $::engine::data(fixeddepth$n)" $n
      } elseif {$::options(engine_timeMode) == "movetime"} {
        ::engine::sendToEngine "go movetime $::engine::data(movetime$n)" $n
      } elseif {$::options(engine_timeMode) == "nodes"} {
        ::engine::sendToEngine "go nodes $::engine::data(fixednodes$n)" $n
      }
    } else {
      set wtime [expr $wtime / 1000 ]
      set btime [expr $btime / 1000 ]
      if {$wtime < 60 } {set wtime 60}
      if {$btime < 60 } {set btime 60}
      if { [::engine::getEngineColor $n] == "white" } {
        ::engine::sendToEngine "level 0 [expr int($wtime /60 )] [expr int($::engine::data(winc$n) / 1000)]" $n
      } else {
        ::engine::sendToEngine "level 0 [expr int($btime /60 )] [expr int($::engine::data(binc$n) / 1000)]" $n
      }
      ::engine::sendToEngine "go" $n
    }
    
    set ::engine::data(waitForBestMove$n) 1
    vwait ::engine::data(bestmove$n)
    
    ::game::moveAdd $::engine::data(bestmove$n)
    set ::engine::data(prevscore$n) $::engine::data(score$n)
    ::board::updateBoard -pgn
    
    # add time after a move played
    if {$::options(engine_timeMode) == "timebonus"} {
      if { [::engine::getEngineColor $n] == "white" } {
        ::gameclock::add [getClock $n] $::engine::data(winc$n)/1000
      } else  {
        ::gameclock::add [getClock $n] $::engine::data(binc$n)/1000
      }
    }
    ::gameclock::stop [getClock $n]
    ::gameclock::start [ oppN [ getClock $n ] ]
  }
  # ##################################################################
  proc unload { n } {
    if {!$::WindowsCE} {
      after cancel ::engine::pollSock $n
      chan event $::engine::data(sock$n) readable {}
    }
    ::engine::sendToEngine "stop" $n 0
    ::engine::sendToEngine "quit" $n 0
    
    if {$::WindowsCE} {
      set engine_quit 0
      #wait for Toga to close msg queues
      for {set i 0} {$i < 50} {incr i} {
        set msg_queue_info [sc_msg info $n read]
        if {[lindex $msg_queue_info 3] < 1} {
          set engine_quit 1
          break
        }
        update
        after 50
      }
      if {!$engine_quit} {
        tk_messageBox -type ok -icon error -parent . -title [::msgcat::mc "Error"] -message [::msgcat::mc "Engine may be still in memory !"]
      }
      sc_msg close $n
    } else {
      close $::engine::data(sock$n)
      close $::engine::data(serversock$n)
    }
  }
  
  if { ! $::WindowsCE } {
    # ##################################################################"
    proc Server1 {channel clientaddr clientport} {
      # puts "Connection from $clientaddr registered channel $channel 1"
      set ::engine::data(sock1) $channel
      chan configure $::engine::data(sock1) -blocking 0 -buffering line -buffersize 4096
    }
    proc Server2 {channel clientaddr clientport} {
      # puts "Connection from $clientaddr registered channel $channel 2"
      set ::engine::data(sock2) $channel
      chan configure $::engine::data(sock2) -blocking 0 -buffering line -buffersize 4096
    }
  }
  
  array set ::cacheIsUci ""
  
  # ##################################################################
  proc init { n } {
    if { $::options(engine$n) == "" } { return }
    
    reset $n
    
    if {$::WindowsCE} {
      set name [file join $::instalDir "$::options(engine$n).exe"]
      sc_msg init $n $::options(engine$n)
    } else {
      set name "./$::options(engine$n)/src/$::options(engine$n)"
      set port [ lindex $::engineconfig($::options(engine$n)) 2 ]
      set ::engine::data(serversock$n) [socket -server ::engine::Server$n $port]
    }
    
    if {![file exists $name]} {
      tk_messageBox -type ok -icon error -parent . -title [::msgcat::mc "Engine error"] -message "The engine $name can't be found"
      return
    }
    
    if { [catch { exec $name & } result ] } {
      tk_messageBox -type ok -icon error -parent . -title [::msgcat::mc "Engine error"] -message "exec error $result for $name"
      return
    }
    
    set ::cacheIsUci($n) [ ::engine::isUci $n ]
    
    set count 0
    if {$::WindowsCE} {
      set ready 0
      while {!$ready && $count < 300 } {
        incr count
        set qinfor [sc_msg info $n read]
        set qinfow [sc_msg info $n write]
        if {[lindex $qinfor 3] >= 1 && [lindex $qinfow 2] >= 1} {
          set ready 1
        } else {
          after 10
        }
      }
      if {!$ready} {
        tk_messageBox -type ok -icon error -parent . -title "Fatal Error" \
            -message "Msg queue error\nread [sc_msg info $n read]\nwrite [sc_msg info $n write]"
        return
      }
      if {[isUci $n]} {
        sendToEngine "uci" $n
      } else {
        sendToEngine "xboard" $n
        sendToEngine "protover 2" $n
        sendToEngine "ponder off" $n
        sendToEngine "post" $n
      }
      ::engine::pollSock $n
    } else {
      ::vwaitTimed ::engine::data(sock$n) 5000
      ::engine::pollSock $n
      if {[isUci $n]} {
        sendToEngine "uci" $n
      } else {
        sendToEngine "xboard" $n
        sendToEngine "protover 2" $n
        sendToEngine "ponder off" $n
        sendToEngine "post" $n
      }
    }
    
    ::vwaitTimed ::engine::data(uciok$n) 3000
    
    # no need to set multiPV for engines != 1 (but may lead to comparison problems in tournament)
    if {$n == 1} { setMultiPv $n }
    
    sendToEngine "setpriority $::engine::priority" $n
  }
  
  # ##################################################################
  proc restartEngine { n {warnUser 1}} {
    
    after cancel ::engine::pollSock $n
    
    if {$warnUser} {
      tk_messageBox -type ok -icon warning -parent . -title [::msgcat::mc "Engine error"] -message "The engine #$n probably crashed\nIt will be restarted"
    }
    
    unload $n
    
    if {$::WindowsCE} {
      reset $n
      sc_msg close $n
      sc_msg init $n $::options(engine$n)
    } else {
      set ::engine::data(sock$n) ""
      set ::engine::data(uciok$n) 0
      set ::engine::data(waitForReadyOk$n) 0
      set ::engine::data(waitForBestMove$n) 0
      catch { chan event $::engine::data(sock$n) readable {} }
      catch { close $data(sock$n) }
    }
    init $::cmd $n
    # reset analysis, play status
    set ::engine::data(running$n) 0
    .fTop.fr.fCmd.bAnalyze configure -image engine_off -relief flat -state normal
    resetAnalysis $n
    if {$::playMode} {
      set ::playMode 0
      after cancel ::game::engineGo $n
      set ::options(showAnalysis) $::options(showAnalysisOld)
      set ::options(showBook) $::options(showBookOld)
      ::infopanel::updateAnalysis
      ::infopanel::updateBookText
      ::gameclock::delete 1
      ::gameclock::delete 2
    }
  }
  # ##################################################################
  proc checkEngineAlive { n } {
    if {$::WindowsCE} {
      set qinfor [sc_msg info $n read]
      set qinfow [sc_msg info $n write]
      if {[lindex $qinfor 3] == 1 && [lindex $qinfow 2] == 1} {
        return 1
      } else {
        set msg "read $qinfor\nwrite $qinfow"
        tk_messageBox -type ok -icon warning -parent . -title "Engine dead" -message $msg
        return 0
      }
    } else {
      global ::engine::data
      if {[eof $data(sock$n)]} {
        restartEngine $n
        return 0
      }
      return 1
    }
  }
  # ##################################################################"
  if {!$::WindowsCE} {
    proc checkSocketReady { n } {
      set ::writable$n 0
      chan event $::engine::data(sock$n) writable "set ::writable$n 1"
      ::vwaitTimed ::writable$n 3000
      chan event $::engine::data(sock$n) writable ""
    }
  }
  # ##################################################################"
  proc sendToEngine { msg n {checkAlive 1} } {
    # ::log "send $n $msg"
    # puts ">> $n $msg"
    if {$::WindowsCE} {
      if { $checkAlive } {
        if { ! [checkEngineAlive $n] } {
          tk_messageBox -type ok -icon error -parent . -title "Error" -message "Engine $n dead"
          # restartEngine $n
          return
        }
      }
      sc_msg send $n $msg
    } else {
      if { $checkAlive && ! [checkEngineAlive $n] } { return }
      # checkSocketReady $n
      puts $::engine::data(sock$n) $msg
      flush $::engine::data(sock$n)
    }
  }
  # ##################################################################
  proc pollSock { n } {
    after cancel ::engine::pollSock $n
    set ::interesting 0
    
    while {1} {
      if {$::WindowsCE} {
        set line [sc_msg recv $n]
      } else {
        set line [gets $::engine::data(sock$n)]
      }
      
      if {$line == ""} {break}
      
      #DEBUG
      if {[string match "ERROR*" $line]} {
        tk_messageBox -type ok -icon warning -parent . -title "Engine sends error" -message $line
      }
      # puts "recv $n $line"
      if { $::cacheIsUci($n) } {
        readSock $line $n
      } else {
        readXboard $line $n
      }
    }
    
    if { $::interesting } {
      ::infopanel::updateAnalysis $n
    }
    
    after 300 ::engine::pollSock $n
  }
  # ##################################################################
  proc readSock { line n } {
    global ::engine::data ::engine::infoToken
    
    # To speed up parsing of engine's output. Should be removed if currmove info is used
    if {[string first "info currmove" $line ] == 0} { return }
    
    # if {![string match "info *" $line ]} { puts "readSock $line" }
    
    if {[string match "error*" $line]} {
      tk_messageBox -type ok -icon warning -parent . -title "Engine sends error" -message $line
    }
    if { $line == "uciok" } { set data(uciok$n) 1 ; return  }
    if { $line == "readyok" } {
      if {$data(waitForReadyOk$n)} { set data(waitForReadyOk$n) 0 }
      set data(readyok$n) 1
      return
    }
    if {[string match "bestmove*" $line]} {
      set d [split $line]
      set data(bestmove$n) [lindex $d 1]
      # get ponder move
      if {[lindex $d 2] == "ponder"} {
        set data(ponder$n) [lindex $d 3]
      } else {
        set data(ponder$n) ""
      }
      if { $data(waitForBestMove$n) } {
        set data(waitForBestMove$n) 0
        return
      }
    }
    if {[string match "id *name *" $line]} {
      set data(name$n) [ regsub {id[ ]?name[ ]?} $line "" ]
    }
    
    set toBeFormatted 0
    
    # parse an info line
    if {[string first "info" $line ] == 0} {
      set d [split $line]
      set length [llength $d]
      for {set i 0} {$i < $length } {incr i} {
        set t [lindex $d $i]
        if { $t == "info" } { continue }
        if { $t == "depth" } { incr i ; set data(depth$n) [ lindex $d $i ] ; continue }
        if { $t == "seldepth" } { incr i ; set data(seldepth$n) [ lindex $d $i ] ; continue }
        if { $t == "time" } { incr i ; if {$data(multipvnum$n) == 1} {set data(time$n) [ lindex $d $i ]} ; continue }
        if { $t == "nodes" } { incr i ; if {$data(multipvnum$n) == 1} { set data(nodes$n) [ lindex $d $i ]} ; continue }
        if { $t == "pv" } {
          set ::interesting 1
          incr i
          set data(pv$n) [ lindex $d $i ]
          incr i
          while { [ lsearch -exact $infoToken [ lindex $d $i ] ] == -1 && $i < $length } {
            append data(pv$n) " " [ lindex $d $i ]
            incr i
          }
          set toBeFormatted 1
          
          incr i -1
          continue
        }
        if { $t == "multipv" } {
          incr i
          set data(multipvnum$n) [ lindex $d $i ]
          continue
        }
        if { $t == "score" } {
          set ::interesting 1
          incr i
          set next [ lindex $d $i ]
          if { $next == "cp" } {
            incr i
            set data(score$n) [ lindex $d $i ]
          }
          
          if { $next == "mate" } {
            incr i
            set next [ lindex $d $i ]
            set data(scoremate$n) $next
            if {$next < 0} { set data(score$n) -32700 } else  { set data(score$n) 32700 }
          }
          
          # convert the score to white's perspective (not engine's one)
          if { [sc_pos side] == "black"} {
            set data(score$n) [ expr 0.0 - $data(score$n) ]
            if { $data(scoremate$n) != ""} {
              set data(scoremate$n) [ expr 0 - $data(scoremate$n) ]
            }
          }
          set data(score$n) [expr {double($data(score$n)) / 100.0} ]
          
          # don't consider lowerbound & upperbound score info
          continue
        }
        # if { $t == "currmove" } { incr i ; set data(currmove$n) [ lindex $d $i ] ; continue }
        if { $t == "currmovenumber" } { incr i ; set data(currmovenumber$n) [ lindex $d $i ] ; continue }
        if { $t == "hashfull" } { incr i ; set data(hashfull$n) [ lindex $d $i ] ; continue }
        if { $t == "nps" } { incr i ; set nps [ lindex $d $i ] ; set data(nps$n) $nps ; continue }
        if { $t == "tbhits" } { incr i ; set data(tbhits$n) [ lindex $d $i ] ; continue }
        if { $t == "cpuload" } { incr i ; set data(cpuload$n) [ lindex $d $i ] ; continue }
        if { $t == "string" } { continue }
        if { $t == "refutation" } { continue }
        if { $t == "currline" } { continue }
      };# end for data loop
      
      # handle the case an UCI engine does not send multiPV
      if { $data(multipvnum$n) == 0 } { set data(multipvnum$n) 1 }
      
      # convert to something more readable
      if { $toBeFormatted && $::options(engineUCIFormat) } {
        set data(pv$n) [formatPv $data(pv$n) $n]
        set toBeFormatted 0
      }
      
      if { $data(multipvnum$n) <= $::options(multipv) } {
        if { $data(multipvnum$n) <= [llength $data(multipv$n)] } {
          lset data(multipv$n) [expr $data(multipvnum$n) - 1] "$data(depth$n) $data(score$n) [list $data(pv$n)] $data(scoremate$n)"
        } else  {
          lappend data(multipv$n) "$data(depth$n) $data(score$n) [list $data(pv$n)] $data(scoremate$n)"
        }
      }
    } ;# end of info line
    
  }
  
  # ##################################################################
  proc formatPv { moves n } {
    set tmp ""
    
    sc_info preMoveCmd {}
    set altered [sc_game altered]
    if {![sc_pos isAt vend]} {
      sc_var create
      set tmp [sc_move addUCI $moves]
      set var [sc_var number]
      sc_var exit
      sc_var deletefree $var
    } else {
      set count 0
      set tmp [sc_move addUCI $moves]
      set count [llength $tmp]
      
      if { $count !=0 } {
        sc_move back $count
        sc_game truncatefree
      }
    }
    
    sc_info preMoveCmd preMoveCommand
    set tmp [string trim $tmp]
    sc_game setaltered $altered
    return $tmp
  }
  ################################################################################
  # UCI moves use long notation
  # returns 1 if an error occured when entering a move
  ################################################################################
  proc sc_move_add { moves n } {
    
    # CODE MORT !!
    
    if { ! $::cacheIsUci($n) } {
      return [ catch { sc_move addSan $moves } ]
    }
    
    foreach m $moves {
      # get rid of leading piece : to be removed ??
      # set c [string index $m 0]
      # if {$c == "K" || $c == "Q" || $c == "R" || $c == "B" || $c == "N"} { set m [string range $m 1 end] }
      set s1 [string range $m 0 1]
      set s1 [::board::sq $s1]
      set s2 [string range $m 2 3]
      set s2 [::board::sq $s2]
      if {[string length $m] > 4} {
        set promo [string range $m 4 end]
        # inverse transformation : const char PIECE_CHAR [] = "xKQRBNP.xkqrbnpxMm";
        # it seems capitalisation does not matter (see addMove proc in main.tcl)
        switch -- $promo {
          q { set p 2}
          r { set p 3}
          b { set p 4}
          n { set p 5}
          default {puts "Promo error $promo"}
        }
        if { [catch { sc_move add $s1 $s2 $p } ] } { return 1}
      } else  {
        if { [catch { sc_move add $s1 $s2 0 } ] } { return 1 }
      }
    }
    return 0
  }
  ################################################################################
  # returns "Name Version"
  proc getName {n} {
    if {$::options(engine$n) == ""} {return ""}
    return "[lindex $::engineconfig($::options(engine$n)) 0] [lindex $::engineconfig($::options(engine$n)) 1]"
  }
  ################################################################################
  proc OptimizeSpeed {} {
    if { $::options(engineOptimizeSpeed) } {
      set ::options(multipv_old) $::options(multipv)
      set ::options(multipv) 1
      ::engine::setMultiPv 1
      ::engine::setMultiPv 2
      set ::options(engineUCIFormat) 0
    } else {
      set ::options(multipv) $::options(multipv_old)
      ::engine::setMultiPv 1
      ::engine::setMultiPv 2
      set ::options(engineUCIFormat) 1
    }
  }
  ################################################################################
  proc isUci { n } {
    if { [ lindex $::engineconfig($::options(engine$n)) 4 ] == "uci" } { return 1 } else { return 0 }
  }
  ################################################################################
  #   X B O A R D specific code
  ################################################################################
  proc readXboard { line n } {
    global ::engine::data
    
    # puts "readXboard $line"
    
    set data(uciok$n) 1
    # ply score time nodes pv
    set res [scan $line "%d %d %d %s %\[^\n\]\n" \
        temp_depth temp_score temp_time temp_nodes temp_moves]
    if {$res == 5} {
      # Phalanx inverts score : TODO check this for other ported xboard engines in the future
      if { [sc_pos side] == "black" } {
        set temp_score [expr { 0.0 - $temp_score } ]
      }
      set data(depth$n) $temp_depth
      set data(score$n) $temp_score
      # Convert score to pawns from centipawns:
      set data(score$n) [expr {double($data(score$n)) / 100.0} ]
      set data(pv$n) $temp_moves
      set data(time$n) [ expr $temp_time *10]
      set data(nodes$n) $temp_nodes
      set data(scoremate$n) 0
      if {$data(time$n) != 0} {
        set data(nps$n) [expr int( ($data(nodes$n) * 1000) / $data(time$n)) ]
      } else {
        set data(nps$n) 0
      }
      set data(multipv$n) [ list "$data(depth$n) $data(score$n) [::trans [list $data(pv$n)]] $data(scoremate$n)" ]
      set ::interesting 1
      return
    }
    
    # Check for a "stat01:" line, the reply to the "." command:
    #
    if {! [string compare [string range $line 0 6] "stat01:"]} {
      if {[scan $line "%s %d %s %d" \
            dummy temp_time temp_nodes temp_depth] == 4} {
        set data(depth$n) $temp_depth
        set data(time$n) $temp_time
        set data(nodes$n) $temp_nodes
        set data(time$n) [expr {double($data(time$n)) / 100.0} ]
      }
      return
    }
    # if the engine moves
    set res [ scan $line "my move is %s" move]
    if { $res != 1 } { set res [ scan $line "move %s" move] }
    if { $res == 1 } {
      if { $data(waitForBestMove$n) } {
        set data(waitForBestMove$n) 0
      }
      set ::engine::data(bestmove$n) $move
    }
    
  }
  ################################################################################
  #   end of X B O A R D specific code
  ################################################################################
}
