### tactics.tcl: part of Scid.
### Copyright (C) 2007  Pascal Georges
### Copyright (C) 2015 Fulvio Benini
###
######################################################################
### Solve tactics (mate in n moves for example)
# use Site token in pgn notation to store progress
#

namespace eval tactics {
    
    set infoEngineLabel ""
    set solved "problem solved"
    set failed "problem failed"
    set prevScore 0
    set prevLine ""
    set nextEngineMove ""
    set matePending 0
    set cancelScoreReset 0
    set askToReplaceMoves_old 0
    set showSolution 0
    set labelSolution ". . . . . . "
    set prevFen ""
    set engineSlot 5
    # Don't try to find the exact best move but to win a won game (that is a mate in 5 is ok even if there was a pending mate in 2)
    set winWonGame 0
    
    ################################################################################
    # Current base must contain games with Tactics flag and **** markers
    # for certain moves. The first var should contain the best move (the next best move
    # is at least 1.0 point away.
    ################################################################################
    proc findBestMove { {previous 0} } {
        
        set old_game [sc_game number]
        set nGames [sc_base numGames $::curr_db]
        
        if { $old_game == 1 && $previous != 0} {
            return
        }
        
        if { $old_game == $nGames && $previous == 0} {
            return
        }
        
        set found 0
        
        if {$nGames == 0} {
            tk_messageBox -type ok -icon info -title "Scid" -message "No game with Tactics flag\nor no tactics comment found"
            return
        }
        
        if {$previous != 0} {
            ::game::LoadNextPrev previous
        }
        
        # Try to find in current game, from current pos (exit vars first)
        set ::curr_db [sc_base current]
        set ::curr_game [sc_game number]
        catch {
            if {[sc_base gameflag $::curr_db $::curr_game get T]} {
                while {[sc_var level] != 0} { sc_var exit }
                if {[llength [gotoNextTacticMarker] ] != 0} {
                    set found 1
                }
            }
        }
        if { ! $found } {
            set sens 1
            set start [expr [sc_game number] +1]
            set end $nGames
            if {$previous != 0} {
                set sens -1
                set start  [expr [sc_game number] -1]
                set end 1
            }
            for {set g $start } { [expr $sens * $g ] <= [ expr $sens * $end ] } { incr g $sens} {
                if {![sc_base gameflag $::curr_db $g get T]} { continue }
                sc_game load $g
                # go through all moves and look for tactical markers ****
                if {[llength [gotoNextTacticMarker] ] != 0} {
                    set found 1
                    break
                }
            }
        }
        
        if { ! $found } {
            sc_game load $old_game
            gotoNextTacticMarker
            tk_messageBox -type ok -icon info -title "Scid" -message "No game with Tactics flag\nor no tactics comment found"
        } else  {
            sideToMoveAtBottom
        }
        updateBoard -pgn
        ::windows::gamelist::Refresh
        updateTitle
    }
    ################################################################################
    # The initial proc to start Find Best Move training
    proc findBestMoveStart {} {
        
        set f .main.fbutton.button
        
        if { $::tactics::findBestMoveRunning } {
            set ::tactics::hideNextMove_old $::gameInfo(hideNextMove)
            set ::tactics::showVarArrows_old $::showVarArrows
            set ::tactics::showVarPopup_old $::showVarPopup
            set ::gameInfo(hideNextMove) 1
            set ::showVarArrows 0 ;# so the user will not see the solution through var arrows
            set ::showVarPopup 0
            
            # create UI to handle commands and feed back for find best move
            if { ![winfo exists $f.fbm_space1]} {
                ttk::frame $f.fbm_space1 -width 15
                button $f.fbm_solution -image tb_lightbulb -command ::tactics::findBestMoveShowSolution
                ::utils::tooltip::Set $f.fbm_solution [::tr ShowSolution]
                button $f.fbm_prev -image tb_backward -command { ::tactics::findBestMove previous }
                ::utils::tooltip::Set $f.fbm_prev [::tr PrevExercise ]
                button $f.fbm_next -image tb_forward -command ::tactics::findBestMove
                ::utils::tooltip::Set $f.fbm_next [::tr NextExercise ]
                button $f.fbm_stop -image tb_stop -command { set ::tactics::findBestMoveRunning 0 ;  ::tactics::findBestMoveStart }
                ::utils::tooltip::Set $f.fbm_stop [::tr StopTraining ]
            }
            pack $f.fbm_space1 -side left -pady 1 -padx 0 -ipadx 0 -pady 0 -ipady 0
            pack $f.fbm_solution $f.fbm_prev $f.fbm_next $f.fbm_stop -side left -pady 1 -padx 0 -ipadx 0 -pady 0 -ipady 0
            
            # load the last game seen by the user
            set fname [sc_base filename $::curr_db]
            if { $fname != "<clipbase>"} {
                if { [ info exists ::tactics::findBestMove_History($fname) ] } {
                    ::game::Load $::tactics::findBestMove_History($fname)
                }
            }
            
            findBestMove
            
        } else  {
            findBestMoveStop
        }
        
    }
    ################################################################################
    # Refresh the PGN window so the solution is visible
    proc  findBestMoveShowSolution {} {
        set ::tactics::findBestMoveRunning 0
        ::pgn::Refresh 1
        set ::tactics::findBestMoveRunning 1
    }
    ################################################################################
    proc findBestMoveStop {} {
        if { ! $::tactics::findBestMoveRunning } {
            set f .main.fbutton.button
            set ::tactics::findBestMoveRunning 0
            # stop the training, restore normal PGN display
            ::pgn::Refresh 1
            set ::gameInfo(hideNextMove) $::tactics::hideNextMove_old
            set ::showVarArrows $::tactics::showVarArrows_old
            set ::showVarPopup $::tactics::showVarPopup_old
            
            set fname [sc_base filename $::curr_db]
            if { $fname != "<clipbase>"} {
                set ::tactics::findBestMove_History($fname) [sc_game number]
            }
            pack forget $f.fbm_space1 $f.fbm_solution $f.fbm_prev $f.fbm_next $f.fbm_stop
            # destroy $f.fbm_space1 $f.fbm_solution $f.fbm_prev $f.fbm_next $f.fbm_stop
        }
    }
    ################################################################################
    # Scid exists when the training is in progress : restore options
    proc findBestMoveExit {} {
        if { $::tactics::findBestMoveRunning } {
            set ::gameInfo(hideNextMove) $::tactics::hideNextMove_old
        }
    }
    ################################################################################
    # returns a list with depth score prevscore
    # or an empty list if marker not found
    proc gotoNextTacticMarker {} {
        while {![sc_pos isAt end]} {
            sc_move forward
            set cmt [sc_pos getComment]
            # TODO old format to be removed
            set res [scan $cmt "\*\*\*\*d%dfrom%fto%f" dif prevscore score ]
            if {$res != 3} { ; # try new format if the old format failed
                set res [scan $cmt "\*\*\*\*D%d %f->%f" dif prevscore score ]
            }
            if {$res == 3} {
                return [list $dif $score $prevscore]
            }
        }
        return {}
    }




    ################################################################################
    # Tacticts training
    ################################################################################
    proc configBases {win} {
        $win.d.search configure -state disabled
        $win.fbutton.ok configure -state disabled -command {}
        $win.fbutton.reset configure -state disabled -command {}
        $win.fbutton.cancel configure -text [tr stop] -command {progressBarCancel}
        $win.fbutton.help configure -state disabled
        $win.s.bases delete [$win.s.bases children {}]

        set prevBase [sc_base current]
        set valid {}
        set fileList [lsort -dictionary [ glob -nocomplain -directory $::scidBasesDir *.si4 ] ]
        set progress 0.0
        set progressIncr 1.0
        catch { set progressIncr [expr {602.0 / [llength $fileList]}] }
        busyCursor .
        foreach fname $fileList {
            set fname [file rootname [file nativename $fname]]
            set baseId [sc_base slot $fname]
            if {$baseId == 0} {
                progressBarSet $win.dummy 100 10
                if { [catch { sc_base open $fname } baseId] } {
                    if {$::errorCode == $::ERROR::UserCancel} { break }
                    ERROR::MessageBox
                    continue
                }
                set wasOpened 0
            } else  {
                set wasOpened 1
            }

            set filter [sc_filter new $baseId]
            progressBarSet $win.dummy 100 10
            set err [catch {
                sc_filter search $baseId $filter header -filter RESET -fStdStart 1
                set nTactics [sc_filter count $baseId $filter]
                sc_filter search $baseId $filter header -filter AND -site "\"$::tactics::solved\""
                set solvedCount [sc_filter count $baseId $filter]

                set line [list [file tail $fname] [sc_base extra $baseId description] $solvedCount $nTactics]

                set pos "end"
                if {[sc_base extra $baseId type] == 15} {
                    if {![info exists nTactBases]} {
                        set nTactBases -1
                        set valid $fname
                    }
                    set pos [incr nTactBases]
                }
                $win.s.bases insert {} $pos -id $fname -values $line
                $win.s.bases see $fname
                if {$nTactics == 0} {
                    $win.s.bases item $fname -tag empty
                } else {
                    if {$valid == ""} { set valid $fname }
                }

                set progress [expr {$progress + $progressIncr +1}]
                $win.pbar coords bar 0 0 [expr {int($progress)}] 12
            }]
            sc_filter release $baseId $filter
            if {$wasOpened == 0} {
                sc_base close $baseId
            }

            if {$err} {
                if {$::errorCode == $::ERROR::UserCancel} { break }
                ERROR::MessageBox
                continue
            }
        }
        unbusyCursor .
        sc_base switch $prevBase
        $win.pbar coords bar 0 0 602 12
        $win.fbutton.help configure -state normal
        grid $win.fbutton.reset
        set eager [$win.s.bases selection]
        if {$eager != ""} {
            set valid $eager
            $win.s.bases selection set {}
        }
        bind $win.s.bases <<TreeviewSelect>> "::tactics::configValidBase $win"
        $win.s.bases selection set [list $valid]
        $win.s.bases see $valid
        $win.d.search configure -state normal
    }

    proc configValidDir {win} {
        bind $win.s.bases <<TreeviewSelect>> {}
        $win.fbutton.reset configure -state disabled -command {}
        $win.fbutton.ok configure -state disabled -command {}
        $win.d.search configure -text $::tr(Search)
        $win.pbar coords bar 0 0 0 0
        $win.fbutton.cancel configure -text [tr Cancel] -command "focus .; destroy $win"
        if {[file isdirectory $::scidBasesDir]} {
            $win.d.basedir configure -foreground black
            $win.d.search configure -state normal \
                -command "::tactics::configBases $win"
            after idle "after 1 ::tactics::configBases $win"
        } else {
            $win.d.basedir configure -foreground red
            $win.d.search configure -state disabled -command {}
        }
    }

    proc configValidBase {win} {
        set fname [$win.s.bases selection]
        $win.fbutton.cancel configure -text [tr Cancel] -command "focus .; destroy $win"
        if {$fname != "" && [$win.s.bases item {*}$fname -tags] != "empty"} {
            $win.fbutton.ok configure -state normal \
                -command "set e \[$win.e.engines selection\]; destroy $win; ::tactics::createWin $fname \$e"
            $win.fbutton.reset configure -state normal \
                -command "::tactics::resetScores $fname; ::tactics::configValidDir $win"
        } else {
            $win.fbutton.ok configure -state disabled -command {}
            $win.fbutton.reset configure -state disabled -command {}
        }
    }

    proc config {} {
        # check if tactics window is already opened. If so, abort serial.
        set w .tacticsWin
        if {[winfo exists $w]} {
            destroy $w
        }
        
        set w ".configTactics"
        if {[winfo exists $w]} {
            focus $w
            return
        }
        toplevel $w
        wm title $w $::tr(ConfigureTactics)
        wm resizable $w 0 0

        #dummy progressbar
        canvas $w.dummy
        $w.dummy create rectangle 0 0 0 0

        #Engine selection
        grid [frame $w.sep1 -height 10] -sticky news -padx 10
        label $w.engine -font font_Bold -text "[tr Engine]:"
        grid $w.engine -sticky w -padx 10
        grid [ttk::frame $w.e] -sticky news -padx 10
        ttk::treeview $w.e.engines -columns {0 1} -selectmode browse -show {} -height 4
        $w.e.engines column 0 -width 200
        $w.e.engines column 1 -width 400

        set i 0
        set uci 0
        foreach e $::engines(list) {
            if {[lindex $e 7] != 0} {
                $w.e.engines insert {} end -id $i -values [lrange $e 0 1]
                if {$uci == 0} { $w.e.engines selection set [list $i] }
                incr uci
            }
            incr i
        }
        if {$uci == 0} {
            destroy $w
            set msg "This feature require at least one UCI engine"
            tk_messageBox -type ok -icon error -title "$::tr(ConfigureTactics)" -message $msg
            return
        }
        autoscrollframe -bars both $w.e "" $w.e.engines

        grid [ttk::frame $w.t] -sticky news -padx 10
        grid columnconfigure $w.t 2 -weight 1
        label $w.t.analabel -text "[tr SecondsPerMove]: "
        scale $w.t.analysisTime -orient horizontal -from 1 -to 60 -length 120 -variable ::tactics::analysisTime \
                -showvalue 0 -command { ::utils::validate::roundScale ::tactics::analysisTime 1 }
        label $w.t.value -textvar ::tactics::analysisTime
        grid $w.t.analabel  $w.t.value $w.t.analysisTime -sticky news
        

        #BaseDir selection
        grid [frame $w.sep2 -height 20] -sticky news -padx 10 -pady 10
        grid [frame $w.d] -sticky news -padx 10 -pady 10
        label $w.d.lbl -font font_Bold -text "[tr ChooseTrainingBase]:"
        grid $w.d.lbl -sticky w -columnspan 3
        grid columnconfigure $w.d 1 -weight 1
        button $w.d.selectDir -image tb_open -command "setTacticsBasesDir; ::tactics::configValidDir $w"
        label $w.d.basedir -textvariable scidBasesDir
        button $w.d.search -text [tr Search]
        grid $w.d.selectDir $w.d.basedir $w.d.search -sticky w -padx 10


        #Base selection
        grid [ttk::frame $w.s] -sticky news -padx 10
        ttk::treeview $w.s.bases -columns {0 1 2 3} -show headings -selectmode browse -height 8
        $w.s.bases tag configure empty -foreground #a5a2ac
        $w.s.bases heading 0 -text [tr DatabaseName]
        $w.s.bases heading 1 -text [tr Description]
        $w.s.bases heading 2 -text Solved
        $w.s.bases heading 3 -text [tr Total]
        $w.s.bases column 0 -width 140
        $w.s.bases column 1 -width 300
        $w.s.bases column 2 -width 80 -anchor c
        $w.s.bases column 3 -width 80 -anchor c
        autoscrollframe -bars both $w.s "" $w.s.bases

        canvas $w.pbar -width 600 -height 10 -bg white -relief solid -border 1
        $w.pbar create rectangle 0 0 0 0 -fill blue -outline blue -tags bar
        grid $w.pbar


        #Buttons
        grid [ttk::frame $w.fbutton] -sticky news
        grid columnconfigure $w.fbutton 1 -weight 1
        ttk::button $w.fbutton.ok -text [tr Continue]
        ttk::button $w.fbutton.cancel
        ttk::button $w.fbutton.reset -text [tr ResetScores]
        ttk::button $w.fbutton.help -text [tr Help] \
            -command "destroy $w; helpWindow TacticsTrainer"
        grid $w.fbutton.ok -row 0 -column 2
        grid $w.fbutton.cancel -row 0 -column 3
        grid $w.fbutton.reset -row 0 -column 1 -sticky w
        grid $w.fbutton.help -row 0 -column 0 -sticky w

        # Set up geometry for middle of screen:
        set x [expr ([winfo screenwidth $w] - 600) / 2]
        set y [expr ([winfo screenheight $w] - 600) / 2]
        wm geometry $w +$x+$y
        grab $w
        configValidDir $w
        focus $w
    }
    ################################################################################
    #
    ################################################################################
    proc createWin { base engineIdx} {
        global ::tactics::analysisEngine ::askToReplaceMoves ::tactics::askToReplaceMoves_old

        ::uci::resetUciInfo $::tactics::engineSlot
        set analysisEngine(analyzeMode) 0
        progressWindow "Scid" [tr StartEngine]
        set err [::uci::startEngine $engineIdx $::tactics::engineSlot]
        closeProgressWindow
        if {$err != 0} { return }

        set err [::tactics::loadBase $base]
        if {$err != 0} { return }

        
        set askToReplaceMoves_old $askToReplaceMoves
        set askToReplaceMoves 0
        
        set w .tacticsWin
        if {[winfo exists $w]} { focus $w ; return }
        
        createToplevel $w
        setTitle $w $::tr(Tactics)
        setWinLocation $w
        # because sometimes the 2 buttons at the bottom are hidden
        wm minsize $w 170 170
        ttk::frame $w.f1 -relief groove ;# -borderwidth 1
        ttk::label $w.f1.labelInfo -textvariable ::tactics::infoEngineLabel -background linen
        ttk::checkbutton $w.f1.cbWinWonGame -text $::tr(WinWonGame) -variable ::tactics::winWonGame
        pack $w.f1.labelInfo $w.f1.cbWinWonGame -expand yes -fill both -side top
        
        ttk::frame $w.fclock
        ::gameclock::new $w.fclock 1 80 0
        ::gameclock::reset 1
        ::gameclock::start 1
        
        ttk::frame $w.f2 -relief groove
        ttk::checkbutton $w.f2.cbSolution -text $::tr(ShowSolution) -variable ::tactics::showSolution -command ::tactics::toggleSolution
        ttk::label $w.f2.lSolution -textvariable ::tactics::labelSolution -wraplength 120
        pack $w.f2.cbSolution $w.f2.lSolution -expand yes -fill both -side top
        
        ttk::frame $w.fbuttons -relief groove -borderwidth 1
        pack $w.f1 $w.fclock $w.f2 $w.fbuttons -expand yes -fill both
        
        setInfoEngine $::tr(LoadingBase)
        
        ttk::button $w.fbuttons.next -text $::tr(Next) -command {
            ::tactics::stopAnalyze
            ::tactics::loadNextGame }
        ttk::button $w.fbuttons.close -textvar ::tr(Abort) -command "destroy $w"
        pack $w.fbuttons.next $w.fbuttons.close -expand yes -fill both -padx 20 -pady 2
        bind $w <Destroy> "if {\[string equal $w %W\]} {::tactics::endTraining}"
        bind $w <Configure> "recordWinSize $w"
        bind $w <F1> { helpWindow TacticsTrainer }
        createToplevelFinalize $w
        
        setInfoEngine "---"
        set ::playMode "::tactics::callback"
        ::tactics::loadNextGame
    }
    proc callback {cmd} {
        switch $cmd {
            stop { destroy .tacticsWin }
        }
        return 0
    }

    proc endTraining {} {
        unset ::playMode
        set w .tacticsWin
        ::tactics::stopAnalyze
        after cancel ::tactics::mainLoop
        set ::askToReplaceMoves $::tactics::askToReplaceMoves_old

        #TODO:
        #sc_filter release $::tactics::baseId $::tactics::filter
        sc_filter set $::tactics::baseId "dbfilter" 1
        catch { ::uci::closeUCIengine $::tactics::engineSlot }

        updateStatusBar
        updateTitle
    }
    ################################################################################
    #
    ################################################################################
    proc toggleSolution {} {
        global ::tactics::showSolution ::tactics::labelSolution ::tactics::analysisEngine
        if {$showSolution} {
            set labelSolution "$analysisEngine(score) : [::trans $analysisEngine(moves)]"
        } else  {
            set labelSolution ". . . . . . "
        }
    }
    ################################################################################
    #
    ################################################################################
    proc resetScores {fname} {
        global ::tactics::cancelScoreReset
        
        set prevBase [sc_base current]
        set baseId [sc_base slot $fname]
        if {$baseId == 0} {
            if { [catch { sc_base open $fname } baseId] } {
                ERROR::MessageBox
                continue
            }
            set wasOpened 0
        } else  {
            sc_base switch $baseId
            set curr_game [sc_game number]
            sc_game push
            set wasOpened 1
        }
        set filter [sc_filter new $baseId]
        sc_filter search $baseId $filter header -filter RESET -site "\"$::tactics::solved\""
        
        #reset site tag for each game
        set numGames [sc_filter count $baseId $filter]
        set cancelScoreReset 0
        progressWindow "Scid" $::tr(ResettingScore) $::tr(Cancel) "set ::tactics::cancelScoreReset 1"
        for {set g 0} {$g < $numGames && $cancelScoreReset == 0} {incr g 100} {
            updateProgressWindow $g $numGames

            foreach {idx line deleted} [sc_base gameslist $baseId $g 100 $filter N+] {
                foreach {n ply} [split $idx "_"] {
                    sc_game load $n
                    sc_game tags set -site ""
                    sc_game save [sc_game number]
                }
            }
        }
        closeProgressWindow
        sc_filter release $baseId $filter
        if { ! $wasOpened } {
            sc_base close $baseId
        } else {
            if {$curr_game == 0} {
                sc_game new
            } else {
                sc_game load $curr_game
            }
            sc_game pop
            ::notify::DatabaseModified $baseId
            ::notify::GameChanged
        }
        sc_base switch $prevBase
    }
    ################################################################################
    #
    ################################################################################
    proc loadNextGame {} {
        ::tactics::resetValues
        setInfoEngine $::tr(LoadingGame)

        set g [sc_filter next]
        if {$g == 0} {
            tk_messageBox -title "Scid" -icon info -type ok -message $::tr(AllExercisesDone)
            return
        }
        sc_game load $g
        ::notify::GameChanged
        sideToMoveAtBottom
        focus .main
        
        ::gameclock::reset 1
        ::gameclock::start 1
        
        set ::tactics::prevFen [sc_pos fen]
        ::tactics::startAnalyze
        ::tactics::mainLoop
    }
    ################################################################################
    # flips the board if necessary so the side to move is at the bottom
    ################################################################################
    proc sideToMoveAtBottom {} {
        if { [sc_pos side] == "white" && [::board::isFlipped .main.board] || [sc_pos side] == "black" &&  ![::board::isFlipped .main.board] } {
            ::board::flip .main.board
        }
    }
    ################################################################################
    #
    ################################################################################
    proc isPlayerTurn {} {
        if { [sc_pos side] == "white" &&  ![::board::isFlipped .main.board] || [sc_pos side] == "black" &&  [::board::isFlipped .main.board] } {
            return 1
        }
        return 0
    }
    ################################################################################
    #
    ################################################################################
    proc exSolved {} {
        ::tactics::stopAnalyze
        ::gameclock::stop 1
        tk_messageBox -title "Scid" -icon info -type ok -message $::tr(MateFound)
        sc_game tags set -site $::tactics::solved
        sc_game save [sc_game number]
        ::tactics::loadNextGame
    }
    ################################################################################
    # Handle the case where position was changed not during normal play but certainly with
    # move back / forward / rewind commands
    ################################################################################
    proc abnormalContinuation {} {
        ::tactics::stopAnalyze
        ::tactics::resetValues
        ::notify::GameChanged
        ::notify::DatabaseChanged
        if { [sc_pos side] == "white" && [::board::isFlipped .main.board] || [sc_pos side] == "black" &&  ![::board::isFlipped .main.board] } {
            ::board::flip .main.board
        }
        set ::tactics::prevFen [sc_pos fen]
        ::tactics::startAnalyze
        ::tactics::mainLoop
    }
    ################################################################################
    # waits for the user to play and check the move played
    ################################################################################
    proc mainLoop {} {
        global ::tactics::prevScore ::tactics::prevLine ::tactics::analysisEngine ::tactics::nextEngineMove
        
        after cancel ::tactics::mainLoop
        
        if {[sc_pos fen] != $::tactics::prevFen && [sc_pos isAt start]} {
            ::tactics::abnormalContinuation
            return
        }
        
        # is this player's turn (which always plays from bottom of the board) ?
        if { [::tactics::isPlayerTurn] } {
            after 1000  ::tactics::mainLoop
            return
        }
        
        set ::tactics::prevFen [sc_pos fen]
        
        # check if player's move is a direct mate : no need to wait for engine analysis in this case
        set move_done [sc_game info previousMove]
        if { [string index $move_done end] == "#"} { ::tactics::exSolved; return }
        
        # if the engine is still analyzing, wait the end of it
        if {$analysisEngine(analyzeMode)} { vwait ::tactics::analysisEngine(analyzeMode) }
        
        if {[sc_pos fen] != $::tactics::prevFen  && [sc_pos isAt start]} {
            ::tactics::abnormalContinuation
            return
        }
        
        # the player moved and analysis is over : check if his move was as good as expected
        set prevScore $analysisEngine(score)
        set prevLine $analysisEngine(moves)
        ::tactics::startAnalyze
        
        # now wait for the end of analyzis
        if {$analysisEngine(analyzeMode)} { vwait ::tactics::analysisEngine(analyzeMode) }
        if {[sc_pos fen] != $::tactics::prevFen  && [sc_pos isAt start]} {
            ::tactics::abnormalContinuation
            return
        }
        
        # compare results
        set res [::tactics::foundBestLine]
        if {  $res != ""} {
            tk_messageBox -title "Scid" -icon info -type ok -message "$::tr(BestSolutionNotFound)\n$res"
            # take back last move so restore engine status
            set analysisEngine(score) $prevScore
            set analysisEngine(moves) $prevLine
            sc_game tags set -site $::tactics::failed
            sc_game save [sc_game number]
            sc_move back
            updateBoard -pgn
            set ::tactics::prevFen [sc_pos fen]
        } else  {
            catch { sc_move addSan $nextEngineMove }
            set ::tactics::prevFen [sc_pos fen]
            updateBoard -pgn
            if { $::tactics::matePending } {
                # continue until end of game
            } else  {
                setInfoEngine $::tr(GoodMove)
                sc_game tags set -site $::tactics::solved
                sc_game save [sc_game number]
            }
        }
        
        after 1000 ::tactics::mainLoop
    }
    ################################################################################
    # Returns "" if the user played the best line, otherwise an explanation about the missed move :
    # - guessed the same next move as engine
    # - mate found in the minimal number of moves
    # - combination's score is close enough (within 0.5 point)
    ################################################################################
    proc foundBestLine {} {
        global ::tactics::analysisEngine ::tactics::prevScore ::tactics::prevLine ::tactics::nextEngineMove ::tactics::matePending
        set score $analysisEngine(score)
        set line $analysisEngine(moves)
        
        set s [ regsub -all "\[\.\]{3} " $line "" ]
        set s [ regsub -all "\[0-9\]+\[\.\] " $s "" ]
        set nextEngineMove [ lindex [ split $s ] 0 ]
        set ply [ llength [split $s] ]
        
        # check if the player played the same move predicted by engine
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
                    return $::tr(MateNotFound)
                } else  {
                    # win won game but still have to find a mate
                    if {[sc_pos side] == "white" && $score < -300 || [sc_pos side] == "black" && $score > 300} {
                        return ""
                    } else  {
                        return $::tr(MateNotFound)
                    }
                }
            }
            # Engine found a mate, search in how many plies
            set s [ regsub -all "\[\.\]{3} " $prevLine "" ]
            set s [ regsub -all "\[0-9\]+\[\.\] " $s "" ]
            set prevPly [ llength [ split $s ] ]
            if { $ply > [ expr $prevPly - 1 ] && ! $::tactics::winWonGame } {
                return $::tr(ShorterMateExists)
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
                    return "$::tr(ScorePlayed) $score\n$::tr(Expected) $prevScore"
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
                return "$::tr(ScorePlayed) $score\n$::tr(Expected) $prevScore"
            }
        }
    }
    ################################################################################
    # Loads a base bundled with Scid (in ./bases directory)
    ################################################################################
    proc loadBase { name } {
        global ::tactics::baseId ::tactics::filter
        set baseId [sc_base slot $name]
        if {$baseId != 0} {
            ::file::SwitchToBase $baseId 0
        } else  {
            progressWindow "Scid" "$::tr(OpeningTheDatabase): [file tail "$name"]..."
            set err [catch {sc_base open "$name"} baseId]
            closeProgressWindow
            if {$err && $::errorCode != $::ERROR::NameDataLoss } {
                ERROR::MessageBox "$fName\n"
                return $err
            }
        }
        #TODO:
        #set filter [sc_filter new $baseId]
        set filter dbfilter
        sc_filter search $baseId $filter header -filter RESET -fStdStart 1 -site! "\"$::tactics::solved\""

        ::notify::GameChanged
        ::notify::DatabaseChanged
        return 0
    }
    ################################################################################
    ## resetValues
    #   Resets global data.
    ################################################################################
    proc resetValues {} {
        set ::tactics::prevScore 0
        set ::tactics::prevLine ""
        set ::tactics::nextEngineMove ""
        set ::tactics::matePending 0
        set ::tactics::showSolution 0
        set ::tactics::labelSolution ""
        set ::tactics::prevFen ""
    }
    ################################################################################
    #
    ################################################################################
    proc  restoreAskToReplaceMoves {} {
        set ::askToReplaceMoves $::tactics::askToReplaceMoves_old
    }
    ################################################################################
    #
    ################################################################################
    proc setInfoEngine { s { color linen } } {
        set ::tactics::infoEngineLabel $s
        .tacticsWin.f1.labelInfo configure -background $color
    }
    # ======================================================================
    # sendToEngine:
    #   Send a command to a running analysis engine.
    # ======================================================================
    proc sendToEngine {text} {
        ::uci::sendToEngine $::tactics::engineSlot $text
    }
    
    # ======================================================================
    # startAnalyzeMode:
    #   Put the engine in analyze mode
    # ======================================================================
    proc startAnalyze { } {
        global ::tactics::analysisEngine ::tactics::analysisTime
        setInfoEngine "$::tr(Thinking) ..." PaleVioletRed
        
        # Check that the engine has not already had analyze mode started:
        if {$analysisEngine(analyzeMode)} {
            ::tactics::sendToEngine  "exit"
        }
        
        set analysisEngine(analyzeMode) 1
        after cancel ::tactics::stopAnalyze
        ::tactics::sendToEngine "position fen [sc_pos fen]"
        ::tactics::sendToEngine "go infinite"
        after [expr 1000 * $analysisTime] ::tactics::stopAnalyze
    }
    # ======================================================================
    # stopAnalyzeMode:
    #   Stop the engine analyze mode
    # ======================================================================
    proc stopAnalyze { } {
        global ::tactics::analysisEngine ::tactics::analysisTime
        # Check that the engine has already had analyze mode started:
        if {!$analysisEngine(analyzeMode)} { return }
        
        set pv [lindex $::analysis(multiPV$::tactics::engineSlot) 0]
        set analysisEngine(score) [lindex $pv 1]
        set analysisEngine(moves) [lindex $pv 2]
        
        set analysisEngine(analyzeMode) 0
        ::tactics::sendToEngine  "stop"
        setInfoEngine $::tr(AnalyzeDone) PaleGreen3
    }
    
}

###
### End of file: tactics.tcl
###
