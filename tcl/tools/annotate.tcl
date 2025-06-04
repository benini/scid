###
### annotate.tcl: part of Scid.
### This file is part of Scid (Shane's Chess Information Database).
### Copyright (C) 2025 Uwe Klimmek
### uses code from Fulvio Benini https://github.com/benini/chess_accuracy and analysis.tcl
##########################################################################################
### Annotate Dialog: uses a chess engine to analyze and annotate a chess game.

namespace eval ::annotation {

    set _Data(BookSlot) 1

    proc doAnnotate {} {
        global ::annotation::options ::annotation::_Data
        set w .annotationDialog
        # Do not do anything if the window exists
        if { [winfo exists $w] } {
            raise $w
            focus $w
            return
        }

        #Workaround for error in trace var for arrays
        set ::annotateBlunderThreshold $options(blunderThreshold)
        set ::annotateTime $options(time)
        trace variable ::annotateBlunderThreshold w {::utils::validate::Regexp {^[0-9]*\.?[0-9]*$}}
        trace variable ::annotateTime w {::utils::validate::Regexp {^[0-9]*\.?[0-9]*$}}

        win::createDialog $w
        ::setTitle $w "Scid: $::tr(Annotate)"
        catch {grab $w}
        wm resizable $w 0 0
        set f [ttk::frame $w.f]
        pack $f -expand 1

        ttk::labelframe $f.annotate -text $::tr(GameReview)
        ttk::frame $f.annotate.typ
        ttk::radiobutton $f.annotate.typ.label -text $::tr(AnnotateTime) -variable ::annotation::options(typ) -value "movetime"
        ttk::radiobutton $f.annotate.typ.ldepth -text "Depth per move" -variable ::annotation::options(typ) -value "depth"
        ttk::spinbox $f.annotate.typ.spDelay -width 5 -textvariable ::annotateTime -from 0.1 -to 999 -validate key -justify right
        ttk::spinbox $f.annotate.typ.depth -width 5 -textvariable ::annotation::options(depth) -from 2 -to 999 -validate key -justify right
        ttk::radiobutton $f.annotate.allmoves -text $::tr(AnnotateAllMoves) -variable ::annotation::options(annotateBlunders) -value allmoves
        ttk::radiobutton $f.annotate.blundersonly -text $::tr(AnnotateBlundersOnly) -variable ::annotation::options(annotateBlunders) -value blundersonly
        ttk::frame $f.annotate.blunderbox
        ttk::label $f.annotate.blunderbox.label -text $::tr(BlundersThreshold:)
        ttk::spinbox $f.annotate.blunderbox.spBlunder -width 4 -textvariable ::annotateBlunderThreshold \
            -from 0.1 -to 3.0 -increment 0.1 -justify right
        ttk::checkbutton $f.annotate.cbBook  -text $::tr(UseBook) -variable ::annotation::options(useAnalysisBook)
        ::engineNoWin::createEngineOptionsFrame $f annotateEngine ::annotation::options(engine) 3 ::annotation::eng_messages

        # load book names
        lassign [getBookList $options(AnalysisBookName)] idx tmp
        # No book found
        if { $idx < 0 } {
            set options(useAnalysisBook) 0
            $f.annotate.cbBook configure -state disabled
        }
        if { $options(AnalysisBookName) eq "" } { set options(AnalysisBookName) [lindex $tmp $idx] }
        ttk::combobox $f.annotate.comboBooks -width 12 -values $tmp -textvariable ::annotation::options(AnalysisBookName)
        catch { $f.annotate.comboBooks current $idx }
        pack $f.annotate.blunderbox.label -side left -padx { 20 0 }
        pack $f.annotate.blunderbox.spBlunder -side left -anchor w
        pack $f.annotate.typ -side top -anchor w
        pack $f.annotateEngine -in $f.annotate -side top -anchor w
        pack $f.annotate.allmoves $f.annotate.blundersonly $f.annotate.blunderbox -side top -anchor w
        pack $f.annotate.cbBook -side top -anchor w
        pack $f.annotate.comboBooks -side top -anchor w -padx 20
        grid $f.annotate.typ.label -row 0 -column 0 -sticky w
        grid $f.annotate.typ.ldepth -row 1 -column 0 -sticky w
        grid $f.annotate.typ.spDelay -row 0 -column 1 -sticky w
        grid $f.annotate.typ.depth -row 1 -column 1 -sticky w
        bind $w <Escape> { .configAnnotation.f.buttons.cancel invoke }
        bind $w <Return> { .configAnnotation.f.buttons.ok invoke }

        ttk::labelframe   $f.av -text $::tr(AnnotateWhich)
        ttk::radiobutton  $f.av.all     -text $::tr(AnnotateAll)   -variable ::annotation::options(annotateMoves) -value all
        ttk::radiobutton  $f.av.white   -text $::tr(AnnotateWhite) -variable ::annotation::options(annotateMoves) -value white
        ttk::radiobutton  $f.av.black   -text $::tr(AnnotateBlack) -variable ::annotation::options(annotateMoves) -value black
        ttk::checkbutton  $f.av.vars    -text "Store two variations" -variable ::annotation::options(anzVariation) -onvalue 2 -offvalue 1
        pack $f.av.all $f.av.white $f.av.black $f.av.vars -side top -fill x -anchor w

        ttk::labelframe   $f.comment -text $::tr(Comments)
        # Checkmark to enable all-move-scoring
        ttk::checkbutton  $f.comment.scoreAll -text $::tr(ScoreAllMoves) -variable ::annotation::options(scoreAllMoves)
        ttk::checkbutton  $f.comment.cbShortAnnotation -text $::tr(ShortAnnotations) -variable ::annotation::options(annotateShort)
        ttk::checkbutton  $f.comment.cbAddScore -text $::tr(AddScoreToShortAnnotations) -variable ::annotation::options(addScoreToShortAnnotations)
        ttk::checkbutton  $f.comment.cbAddAnnotatorTag  -text $::tr(addAnnotatorTag) -variable ::annotation::options(addAnnotatorTag)
        ttk::checkbutton  $f.comment.cbMarkTactics -text $::tr(MarkTacticalExercises) -variable ::annotation::options(tacticalExercises)
        pack $f.comment.scoreAll $f.comment.cbShortAnnotation $f.comment.cbAddScore \
            $f.comment.cbAddAnnotatorTag $f.comment.cbMarkTactics -fill x -anchor w
        # batch annotation of consecutive games, and optional opening errors finder
        ttk::labelframe $f.batch -text "Batch Annotation"
        ttk::frame $f.buttons
        ttk::frame $f.running
        ttk::label $f.running.line1 -textvariable ::annotation::_Data(msg1) -width 60
        ttk::label $f.running.line2 -textvariable ::annotation::_Data(msg2) -width 10
        ttk::label $f.running.line3 -textvariable ::annotation::_Data(msg3) -width 10
        ttk::progressbar $f.running.progress -variable ::annotation::_Data(progress) -orient horizontal -length 600
        ttk::progressbar $f.running.games -variable ::annotation::options(games) -orient horizontal -length 600
        grid $f.running.line1 -row 0 -column 1 -sticky w -pady { 0 10 }
        grid $f.running.line2 -row 1 -column 0 -sticky w
        grid $f.running.line3 -row 2 -column 0 -sticky w
        grid $f.running.games -row 1 -column 1 -sticky w
        grid $f.running.progress -row 2 -column 1 -sticky w
        grid $f.annotate -row 0 -column 0 -pady { 0 10 } -sticky nswe -padx { 0 10 }
        grid $f.comment -row 0 -column 1 -pady { 0 10 } -sticky nswe -padx { 10 0 }
        grid $f.av -row 1 -column 0 -pady { 10 0 } -sticky nswe -padx { 0 10 }
        grid $f.batch -row 1 -column 1 -pady { 10 0 } -sticky nswe -padx { 10 0 }
        grid $f.buttons -row 3 -column 1 -sticky we

        set options(batchEnd) [sc_base numGames $::curr_db]
        if {$options(batchEnd) <1} { set options(batchEnd) 1 }
        ttk::checkbutton $f.batch.cbBatch -text $::tr(AnnotateSeveralGames) -variable ::annotation::options(batchMode)
        ttk::spinbox $f.batch.spBatchEnd -width 8 -textvariable ::annotation::options(batchEnd) \
            -from 1 -to $options(batchEnd) -increment 1 -validate all -validatecommand { regexp {^[0-9]+$} %P }
        ttk::checkbutton $f.batch.cbBatchOpening -text $::tr(FindOpeningErrors) -variable ::annotation::options(OpeningErrors)
        ttk::spinbox $f.batch.spBatchOpening -width 2 -textvariable ::annotation::options(OpeningMoves) \
            -from 10 -to 20 -increment 1 -validate all -validatecommand { regexp {^[0-9]+$} %P }
        ttk::label $f.batch.lBatchOpening -text $::tr(moves)
        pack $f.batch.cbBatch -side top -anchor w -pady { 0 0 }
        pack $f.batch.spBatchEnd -side top -padx 20 -anchor w
        pack $f.batch.cbBatchOpening -side top -anchor w
        pack $f.batch.spBatchOpening -side left -anchor w -padx { 20 4 }
        pack $f.batch.lBatchOpening  -side left

        ttk::button $f.buttons.cancel -text $::tr(Cancel) -command {
            if { $::autoplayMode } {
                set ::autoplayMode 0
            } else {
                ::engineNoWin::closeEngine annotateEngine
                destroy .annotationDialog
            }
        }
        ttk::button $f.buttons.ok -text "Annotate" -command {
            if {$::annotateTime < 0.1} { set ::annotateTime 0.1 }
            set ::annotation::options(movetime) [expr {int($::annotateTime * 1000.0)}]
            set ::annotation::options(blunderThreshold) $::annotateBlunderThreshold
            set ::annotation::options(time) $::annotateTime
            if { [::engineNoWin::initEngine annotateEngine $::annotation::options(engine) \
                      [list ::annotation::eng_messages annotateEngine .annotationDialog.f.engpara]] } {
                ::annotation::runAnnotation
            }
        }
        pack $f.buttons.cancel $f.buttons.ok -side right -padx 5 -pady 5
        focus $f.annotate.typ.spDelay
        bind $w <Destroy> { focus . }
    }

    # reset values for every game
    proc initGameAnnotation { } {
        global ::annotation::options ::annotation::_Data
        #reset engine
        ::engine::send annotateEngine NewGame [list analysis post_pv post_wdl [sc_game variant]]
        # calc amount of moves to analyze for progressbar
        set firstmove [llength [sc_game moves]]
        sc_game push copyfast
        catch { sc_move forward 300 }
        set anz [expr {[llength [sc_game moves]] - $firstmove + 1}]
        sc_game pop
        .annotationDialog.f.running.progress configure -maximum $anz
        #reset values
        set _Data(prevscore1) 0
        set _Data(prevscore2) 0
        set _Data(score) 0
        set _Data(scoremate) 0
        set _Data(prevscoremate) 0
        set _Data(prevmoves1) ""
        set _Data(prevmoves2) ""
        set _Data(moves) ""
        set _Data(progress) 1
        set _Data(msg1) "$::tr(game) [sc_game number]: [sc_game info white] - [sc_game info black]"
        set _Data(msg2) "$::tr(game) $options(games)"
        set _Data(msg3) "$::tr(move) 1"
        if { $options(addAnnotatorTag) } {
            appendAnnotator "$options(engine) $options(typ) $options($options(typ))"
        }
    }

    proc annotateGame { } {
        global ::annotation::options ::annotation::_Data
        initGameAnnotation
        makeBookAnnotation
        # Annotate all remaining moves of the game
        while { 1 } {
            set _Data(PV1) [list "" "" ""]
            set _Data(PV2) [list "" "" ""]
            ::engine::send annotateEngine Go [list [sc_game UCI_currentPos] [list $options(typ) $options($options(typ))]]
            vwait ::annotation::_Data(move_done)
            addAnnotation
            incr _Data(progress)
            set _Data(msg3) "$::tr(move) $_Data(progress)"
            if {[sc_pos isAt end] || ! $::autoplayMode } break
            sc_move forward
            ::notify::PosChanged -pgn
        }
    }

    proc runAnnotation { } {
        global ::annotation::options
        # make sure, we have 2 best lines
        ::engine::send annotateEngine SetOptions [list {MultiPV 2}]
        set f .annotationDialog.f
        grid forget $f.annotate $f.comment $f.av $f.batch $f.optsannotateEngine
        pack forget $f.buttons.ok
        if {!$options(batchMode)} { grid forget $f.running.games $f.running.line2 }
        # show progressbar and game infos
        set options(games) 1
        set gameNo [sc_game number]
        $f.running.games configure -maximum [expr {$options(batchEnd) - $gameNo + 1}]
        grid $f.running -row 2 -column 0 -columnspan 2 -sticky we

        # tactical positions is selected, must be in multipv mode
        if {$options(tacticalExercises)} { ::engine::send annotateEngine SetOptions [list {MultiPV 4}] }

        set ::autoplayMode 1
        set gameNo [sc_game number]
        if { $gameNo == 0 } { return }
        annotateGame
        while {$options(batchMode)} {
            sc_game save $gameNo
            incr gameNo
            incr options(games)
            if { ! $::autoplayMode || $gameNo > $options(batchEnd) } { break }
            sc_game load $gameNo
            annotateGame
        }
        set ::autoplayMode 0
        ::engineNoWin::closeEngine annotateEngine
        ::notify::PosChanged -pgn
        destroy .annotationDialog
    }

    ################################################################################
    # Part of annotation process : will check the moves if they are in te book, and add a comment
    # when going out of it
    ################################################################################
    proc makeBookAnnotation { } {
        global ::annotation::options ::annotation::_Data
        if {$options(useAnalysisBook)} {
            set prevbookmoves ""
            set bn [ file join $::scidBooksDir $options(AnalysisBookName) ]
            sc_book load $bn $_Data(BookSlot)

            lassign [sc_book moves $_Data(BookSlot)] bookmoves
            while {[string length $bookmoves] != 0 && ![sc_pos isAt vend]} {
                # we are in book, so move immediately forward
                ::move::Forward
                set prevbookmoves $bookmoves
                lassign [sc_book moves $_Data(BookSlot)] bookmoves
            }
            sc_book close $_Data(BookSlot)

            if { [ string match -nocase "*[sc_game info previousMoveNT]*" $prevbookmoves ] != 1 } {
                if {$prevbookmoves != ""} {
                    sc_pos setComment "[sc_pos getComment] $::tr(LastBookMove) [::trans $prevbookmoves]"
                } else  {
                    sc_pos setComment "[sc_pos getComment] $::tr(LastBookMove)"
                }
                # last move was out of book: it needs to be analyzed, so take back
                sc_move back
            } else  {
                sc_pos setComment "[sc_pos getComment] $::tr(MoveOutOfBook)"
            }
            if { $options(OpeningErrors) && ([sc_pos moveNumber] < $options(OpeningMoves) ) } {
                appendAnnotator "opBlunder [sc_pos moveNumber] ([sc_pos side])"
            }
        }
    }

    ################################################################################
    # will append arg to current game Annotator tag
    ################################################################################
    proc appendAnnotator { s } {
        # Get the current collection of extra tags
        set extra [sc_game tags get "Extra"]
        set annot 0
        set other ""
        set nExtra {}
        # Walk through the extra tags, just copying the crap we do not need
        # If we meet the existing annotator tag, add our name to the list
        foreach line $extra {
            if { $annot == 1 } {
                lappend nExtra "Annotator \"$line, $s\"\n"
                set annot 2
            } elseif { $other != "" } {
                lappend nExtra "$other \"$line\"\n"
                set other ""
            } elseif {[string match "Annotator" $line]} {
                set annot 1
            } else {
                set other $line
            }
        }
        # First annotator: Create a tag
        if { $annot == 0 } {
            lappend nExtra "Annotator \"$s\"\n"
        }
        # Put the extra tags back to the game
        sc_game tags set -extra $nExtra
    }

    proc addAnnotation { } {
        global ::annotation::options ::annotation::_Data
        # Let's try to assess the situation:
        # We are here, now that the engine has analyzed the position reached by
        # our last move. Currently it is the opponent to move:
        set tomove [sc_pos side]
        set gamemove [sc_game info previousMoveUCI]

        # And this is his best line:
        lassign $_Data(PV1) score score_type _Data(moves)
        if { $gamemove eq "" || $score eq "" } { set _Data(prevscore1) $score; return }
        set moves $_Data(moves)
        set bestMoveIsMate 0
        if { $score_type eq "mate" } {
        # We do not want to insert a best-line variation into the game
        # if we did play along that line. Even not when annotating all moves.
        # It simply makes no sense to do so (unless we are debugging the engine!)
        # Sooner or later the game will deviate anyway; a variation at that point will
        # do nicely and is probably more accurate as well.
            set bestMoveIsMate 1
            set _Data(scoremate) $score
            set score [expr { $score < 0 ? -127 : 127 }]
            set _Data(score) $score
        } else {
            set _Data(score) $score
            set _Data(scoremate) 0
        }

        # We will add a closing line at the end of variation or game
        set addClosingLine 0
        if {  [sc_pos isAt vend] } {
            set addClosingLine 1
        }

        # This is the score we could have had if we had played our best move
        set prevscore $_Data(prevscore1)

        # Note that the engine's judgement is in relative terms, a negative score
        # being favorable to opponent, a positive score favorable to player
        # Looking primarily for blunders, we are interested in the score decay,
        # which, for white, is (previous-current)
        set deltamove [expr {$prevscore + $score}]
        # and whether the game was already lost for us
        set gameIsLost [expr {$prevscore < (0.0 - $::informant("+--"))}]

        # Invert this logic for black
        if { $tomove == "white" } {
            set gameIsLost [expr {$prevscore > $::informant("+--")}]
        }

        # Set an "isBlunder" filter.
        # Let's mark moves with a decay greater than the threshold.
        set isBlunder 0
        if { $deltamove > $options(blunderThreshold) } {
            set isBlunder 2
        } elseif { $deltamove > 0 } {
            set isBlunder 1
        }
        set absdeltamove [expr { abs($deltamove) } ]

        # to parse scores if the engine's name contains - or + chars (see sc_game_scores)
        set engine_name  [string map {"-" " " "+" " "} $options(engine)]

        # Prepare score strings for the opponent
        if { $_Data(scoremate) != 0 } {
            set text [format "M%d" [expr abs($_Data(scoremate))]]
        } else {
            set wscore [format "%+.2f" $score]
            if { $tomove eq "black" } {set wscore [expr 0.0 - $wscore] }
            set text "\[%eval $wscore\]"
        }

        # See if we have the threshold filter activated.
        # If so, take only bad moves and missed mates until the position is lost anyway
        # Or that we must annotate all moves
        if { ( $options(annotateBlunders) == "blundersonly"
                 && ($isBlunder > 1 || ($isBlunder > 0 && [expr abs($score)] >= 327.0))
                 && ! $gameIsLost)
              || ($options(annotateBlunders) == "allmoves") } {
            if { $isBlunder > 0 } {
                # Add move score nag, and possibly an exercise
                if {       $absdeltamove > $::informant("??") } {
                    markExercise $prevscore $score "??"
                } elseif { $absdeltamove > $::informant("?")  } {
                    markExercise $prevscore $score "?"
                } elseif { $absdeltamove > $::informant("?!") } {
                    sc_pos addNag "?!"
                }
            } elseif { $absdeltamove > $::informant("!?") } {
                sc_pos addNag "!?"
            }

            # Add score comment and engine name if needed
            if { ! $options(annotateShort) } {
                sc_pos setComment "[sc_pos getComment] $engine_name: $text"
            } elseif { $options(addScoreToShortAnnotations) || $options(scoreAllMoves) } {
                sc_pos setComment "[sc_pos getComment] $text"
            }

             # Add position score nag
            sc_pos addNag [scoreToNag $score]
            # Add the variation
            sc_move back
            if { $options(annotateBlunders) == "blundersonly" } {
                # Add a diagram tag, but avoid doubles
                if { [string first "D" "[sc_pos getNags]"] == -1 } {
                    sc_pos addNag "D"
                }
            }

            if { $_Data(prevmoves1) != "" && ( $options(annotateMoves) == "all" ||
                                       $options(annotateMoves) == "white"  &&  $tomove == "black" ||
                                       $options(annotateMoves) == "black"  &&  $tomove == "white" )} {
                set n 1
                while { $n <= $options(anzVariation) && $_Data(prevmoves$n) ne "" } {
                    sc_var create
                    # Add the starting move
                    sc_move addSan [lrange $_Data(prevmoves$n) 0 0]
                    # Add its score
                    if { ! $options(annotateShort) || $options(addScoreToShortAnnotations) } {
                        # And for the (missed?) chance
                        if { $_Data(prevscoremate) != 0 } {
                            set prevtext [format "M%d" [expr abs($_Data(prevscoremate))]]
                        } else {
                            set wprevscore [format "%+.2f" $_Data(prevscore$n)]
                            if { $tomove eq "white" } {set wprevscore [expr 0.0 - $wprevscore] }
                            set prevtext "\[%eval $wprevscore\]"
                        }
                        sc_pos setComment "$prevtext"
                    }
                    # Add remaining moves
                    sc_move addSan [lrange $_Data(prevmoves$n) 1 end]
                    # Add position NAG, unless the line ends in mate
                    if { $n == 1 && $_Data(prevscoremate) == 0 } {
                        sc_pos addNag [scoreToNag $prevscore]
                    }
                    sc_var exit
                    incr n
                }
            }
            sc_move forward
        } else {
            if { $isBlunder == 0 && $absdeltamove > $::informant("!?") } {
                sc_pos addNag "!?"
            }
            if { $options(scoreAllMoves) } {
                # Add a score mark anyway
                sc_pos setComment "[sc_pos getComment] $text"
            }
        }

        if { $addClosingLine } {
            sc_move back
            sc_var create
            sc_move addSan $gamemove
            if { ($_Data(scoremate) == 0) && ( ! $options(annotateShort) || $options(addScoreToShortAnnotations)) } {
                sc_pos setComment "$text"
            }
            sc_move addSan $moves
            if { $_Data(scoremate) == 0 } {
                sc_pos addNag [scoreToNag $score]
            }
            sc_var exit
            # Now up to the end of the game
            ::move::Forward
        }
        set _Data(prevscore1) $_Data(score)
        set _Data(prevmoves1) $_Data(moves)
        lassign $_Data(PV2) _Data(prevscore2) score_type _Data(prevmoves2)
        set _Data(prevscoremate) $_Data(scoremate)
        updateBoard -pgn
    }

    ################################################################################
    # Will add **** to any position considered as a tactical shot
    # check at which depth the tactical shot is found
    ################################################################################
    proc markExercise { prevscore score nag} {
        global ::annotation::options ::annotation::_Data
        sc_pos addNag $nag
        if { ! $options(tacticalExercises)} { return 0 }

        set deltamove [expr {$score + $prevscore}]
        # filter tactics so only those with high gains are kept
        if { [expr abs($deltamove)] < $::informant("+/-") } { return 0 }
        # dismiss games where the result is already clear (high score,and we continue in the same way)
        if { [expr $prevscore * $score] >= 0} {
            if { [expr abs($prevscore) ] > $::informant("+--") } { return 0 }
            if { [expr abs($prevscore)] > $::informant("+-") && [expr abs($score) ] < [expr 2 * abs($prevscore)]} { return 0 }
        }

        # The best move is much better than others.
        set sc2 [lindex $_Data(PV2) 0]
        if { [expr abs( $score - $sc2 )] < 1.5 } { return 0 }

        # The best move does not lose position.
        if {([sc_pos side] == "black") && ($score < [expr 0.0 - $::informant("+/-")]) } { return 0 }
        if {([sc_pos side] == "white") && ($score > $::informant("+/-")) } { return 0}

        # Move is not obvious: check that it is not the first move guessed at low depths
        set pv [ lindex [ lindex $_Data(PV1) 2 ] 0 ]
        # bm0 must SAN, pv is UCI: convert
        set bm0 [string range [lindex $pv 0] 0 4]
        set bm0 [sc_pos coordToSAN $_Data(position) $bm0]
        set bm0 [string range $bm0 [expr [string first "." $bm0] + 1] end]

        foreach depth {1 2 3} {
            set res [ sc_pos analyze -time 1000 -hashkb 32 -pawnkb 1 -searchdepth $depth ]
            set bm$depth [lindex $res 1]
        }
        if { $bm0 == $bm1 && $bm0 == $bm2 && $bm0 == $bm3 } {
            return 0
        }

        # find what time is needed to get the solution (use internal analyze function)
        set timer {1 2 5 10 50 100 200 1000}
        set movelist {}
        for {set t 0} {$t < [llength $timer]} { incr t} {
            set res [sc_pos analyze -time [lindex $timer $t] -hashkb 1 -pawnkb 1 -mindepth 0]
            set move_analyze [lindex $res 1]
            lappend movelist $move_analyze
        }

        # find at what timing the right move was reliably found
        # only the move is checked, not if the score is close to the expected one
        for {set t [expr [llength $timer] -1]} {$t >= 0} { incr t -1} {
            if { [lindex $movelist $t] != $bm0 } {
                break
            }
        }
        set difficulty [expr $t +2]

        # If the base opened is read only, like a PGN file, avoids an exception
        catch { sc_base gameflag [sc_base current] [sc_game number] set T }
        sc_pos setComment "****D${difficulty} [format %.1f $prevscore]->[format %.1f $score] [sc_pos getComment]"
        updateBoard
        return 1
    }

    proc ::annotation::eng_messages {id w msg} {
        global ::annotation::_Data
        lassign $msg msgType msgData
        switch $msgType {
            "InfoConfig" {
                if { $::autoplayMode } { return }
                set msgData [lindex $msgData 2]
                ::engineNoWin::initEngineOptions $id $w $msgData
            }
            "InfoPV" {
                lassign $msgData multipv depth seldepth nodes nps hashfull tbhits time score score_type score_wdl pv
                if { $score_type ne "mate" } { set score [expr {$score / 100.0}] }
                set _Data(PV$multipv) [list $score $score_type $pv]
            }
            "InfoBestMove" {
                lassign $msgData _Data(bestmove)
                set _Data(move_done) 1
            }
            "InfoGo" {
                lassign $msgData _Data(position)
            }
            "InfoDisconnected" {
                ::engineNoWin::disconnected $id $msgData
                set ::autoplayMode 0
            }
        }
    }
    # Informant index strings
    array set ana_informantList { 0 "+=" 1 "+/-" 2 "+-" 3 "+--" }
    # Nags. Note the slight inconsistency for the "crushing" symbol (see game.cpp)
    array set ana_nagList  { 0 "=" 1 "+=" 2 "+/-" 3 "+-" 4 "+--" 5 "=" 6 "=+" 7 "-/+" 8 "-+" 9 "--+" }
    ################################################################################
    #
    ################################################################################
    proc scoreToNag {score} {
        global ana_informantList ana_nagList
        # Find the score in the informant map
        set tmp [expr { abs( $score ) }]
        for { set i 0 } { $i < 4 } { incr i } {
            if { $tmp < $::informant("$ana_informantList($i)") } { break }
        }
        # Jump into negative counterpart
        if { $score < 0.0 } {
            set i [expr {$i + 5}]
        }
        return $ana_nagList($i)
    }
}
