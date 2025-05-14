###
### annotate.tcl: part of Scid.
### This file is part of Scid (Shane's Chess Information Database).
### Copyright (C) 2025 Uwe Klimmek
### uses code from Fulvio Benini https://github.com/benini/chess_accuracy and analysis.tcl
##########################################################################################
### Annotate Dialog: uses a chess engine to analyze and annotate a chess game.

# engineNoWin will be used by annotate and finish game
namespace eval ::engineNoWin {}
# Open the engine and configure it
proc ::engineNoWin::initEngine { id engine callback } {
    if { [info exists ::enginewin::engConfig_$id] } { return 1 }
#   tk_messageBox -title Scid -icon info -type ok -message "Only UCI-Engines are supported!"
    set config [::enginecfg::get $engine]
    lassign $config name cmd args wdir elo time url uci options
    set ::enginewin::engConfig_$id $config
    ::engine::setLogCmd $id {}
    ::engine::connect $id $callback $cmd $args
    if { $options ne "" } { ::engine::send $id SetOptions $options }
    return 1
}

proc ::engineNoWin::changeEngine {id w enginevar callback} {
    ::engine::close $id
    $w.text configure -state normal
    $w.text delete 1.0 end
    foreach wchild [winfo children $w.text] { destroy $wchild }
    catch { unset ::enginewin::engConfig_$id }
    set engine [set $enginevar]
    ::engineNoWin::initEngine $id $engine [list $callback $id $w]
}

proc ::engineNoWin::showHideOptionsFrame {id w enginevar callback col} {
    if { [winfo ismapped $w] } { grid forget $w ; return }
    grid $w -row 0 -column $col -rowspan 5 -sticky ne -padx 10
    set engine [set $enginevar]
    ::engineNoWin::initEngine $id $engine [list $callback $id $w]
}

#create frame for select and edit engine options
#engType: all, uci or winboard
proc ::engineNoWin::createEngineOptionsFrame {f id var col callback {engTyp "uci"}} {
    ttk::frame $f.$id
    set allEngList [::enginecfg::names ]
    if { $engTyp ne "all"} {
        set engList {}
        foreach name $allEngList {
            set typ [lindex [::enginecfg::get $name] 7]
            if { $engTyp == "uci" && $typ || $engTyp == "winboard" && ! $typ } {
                lappend engList $name
            }
        }
    } else {
        set engList $allEngList
    }
    if { [set $var] eq "" } { set $var [lindex $engList 0] }
    ttk::combobox $f.$id.eng -width 20 -state readonly -values $engList -textvariable $var
    bind $f.$id.eng <<ComboboxSelected>> "::engineNoWin::changeEngine $id $f.opts$id $var $callback"
    ttk::button $f.$id.opts -image ::icon::filter_adv -style Toolbutton \
        -command "::engineNoWin::showHideOptionsFrame $id $f.opts$id $var $callback $col"
    pack $f.$id.eng $f.$id.opts -side left -padx { 0 5 }
    ttk::labelframe $f.opts$id -text "Engine Parameter"
    ttk::label $f.opts$id.l -textvariable $var
    ttk::button $f.opts$id.x -text "X" -style Toolbutton -command "grid forget $f.opts$id"
    ttk_text $f.opts$id.text -wrap none -padx 4
    autoscrollBars both $f.opts$id $f.opts$id.text 1
    $f.opts$id.text configure -state normal -wrap word -width 60 -height 18
    ttk::button $f.opts$id.save -text "Save Setup" -command "::engineNoWin::saveEngineSetup $id"
    grid $f.opts$id.l -row 0 -column 0 -sticky w
    grid $f.opts$id.x -row 0 -column 1 -sticky e
    grid $f.opts$id.save -row 2 -column 0 -columnspan 2 -sticky e -pady { 5 0 }
    bind $f.$id <Destroy> "catch { unset ::enginewin::engConfig_$id }; ::engine::close $id"
}

proc ::engineNoWin::initEngineOptions {id w options} {
    upvar ::enginewin::engConfig_$id engConfig_
    if { ! [winfo exists $w.text.reset] } {
        lset ::enginewin::engConfig_$id 8 $options
        ::enginecfg::createOptionWidgets $id $w $options
        ::engine::replyInfoConfig $id
    } else {
        lset ::enginewin::engConfig_$id 8 $options
        ::enginecfg::updateOptionWidgets $id $w $options {}
        $w.text configure -state disabled
    }
}

proc ::engineNoWin::saveEngineSetup { id } {
    upvar ::enginewin::engConfig_$id engConfig_
    ::enginecfg::save [set ::enginewin::engConfig_$id]
}

proc ::engineNoWin::disconnected { id data } {
    upvar ::enginewin::engConfig_$id engConfig_
    lassign $data errorMsg
    lassign [set ::enginewin::engConfig_$id] engine
    if {$errorMsg eq ""} { set errorMsg "The connection with the engine $id $engine terminated unexpectedly." }
    tk_messageBox -icon warning -type ok -parent . -message $errorMsg
}

namespace eval ::annotation {

    # Typ may be "movetime": time per move or "depth": analyse till depth is reached
    set annotateData(typ) "movetime"
    set annotateData(movetime) 1000
    set annotateData(time) 1
    set annotateData(depth) 20
    set annotateData(engine) ""
    set annotateData(progress) 0
    set annotateData(blunderThreshold) 0.5
    set annotateData(annotateMoves) all
    set annotateData(annotateBlunders) blundersonly
    set annotateData(scoreAllMoves) 1
    set annotateData(annotateMode) 0
    set annotateData(useAnalysisBook) 0
    set annotateData(AnalysisBookName) ""
    set annotateData(BookSlot) 1
    set annotateData(tacticalExercises) 0
    set annotateData(addAnnotatorTag) 1
    set annotateData(OpeningErrors) 0
    set annotateData(OpeningMoves) 0
    set annotateData(annotateShort) 1
    set annotateData(addScoreToShortAnnotations) 1
    set annotateData(batchMode) 0
    set annotateData(batchEnd) 0
    set annotateData(msg1) ""
    set annotateData(msg2) ""
    set annotateData(msg3) ""
    set annotateData(prevscore1) 0
    set annotateData(prevscore2) 0
    set annotateData(prevmoves1) ""
    set annotateData(prevmoves2) ""
    set annotateData(score) 0
    set annotateData(moves) ""
    set annotateData(scoremate) 0
    set annotateData(prevscoremate) 0
    set annotateData(anzVariation) 1

    proc doAnnotate {} {
        global ::annotation::annotateData
        set w .annotationDialog
        # Do not do anything if the window exists
        if { [winfo exists $w] } {
            raise $w
            focus $w
            return
        }

        #Workaround for error in trace var for arrays
        set ::annotateBlunderThreshold $annotateData(blunderThreshold)
        set ::annotateTime $annotateData(time)
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
        ttk::radiobutton $f.annotate.typ.label -text $::tr(AnnotateTime) -variable ::annotation::annotateData(typ) -value "movetime"
        ttk::radiobutton $f.annotate.typ.ldepth -text "Depth per move" -variable ::annotation::annotateData(typ) -value "depth"
        ttk::spinbox $f.annotate.typ.spDelay -width 5 -textvariable ::annotateTime -from 0.1 -to 999 -validate key -justify right
        ttk::spinbox $f.annotate.typ.depth -width 5 -textvariable ::annotation::annotateData(depth) -from 2 -to 999 -validate key -justify right
        ttk::radiobutton $f.annotate.allmoves -text $::tr(AnnotateAllMoves) -variable ::annotation::annotateData(annotateBlunders) -value allmoves
        ttk::radiobutton $f.annotate.blundersonly -text $::tr(AnnotateBlundersOnly) -variable ::annotation::annotateData(annotateBlunders) -value blundersonly
        ttk::frame $f.annotate.blunderbox
        ttk::label $f.annotate.blunderbox.label -text $::tr(BlundersThreshold:)
        ttk::spinbox $f.annotate.blunderbox.spBlunder -width 4 -textvariable ::annotateBlunderThreshold \
            -from 0.1 -to 3.0 -increment 0.1 -justify right
        ttk::checkbutton $f.annotate.cbBook  -text $::tr(UseBook) -variable ::annotation::annotateData(useAnalysisBook)
        ::engineNoWin::createEngineOptionsFrame $f annotateEngine ::annotation::annotateData(engine) 3 ::annotation::eng_messages

        # choose a book for analysis
        # load book names
        set bookPath $::scidBooksDir
        set bookList [  lsort -dictionary [ glob -nocomplain -directory $bookPath *.bin ] ]
        # No book found
        if { [llength $bookList] == 0 } {
            set annotateData(useAnalysisBook) 0
            $f.annotate.cbBook configure -state disabled
        }
        set tmp {}
        set idx 0
        set i 0
        foreach file $bookList {
            lappend tmp [ file tail $file ]
            if {$::book::lastBook == [ file tail $file ] } {
                set idx $i
            }
            incr i
        }
        if { $annotateData(AnalysisBookName) eq "" } { set annotateData(AnalysisBookName) [lindex $tmp $idx] }
        ttk::combobox $f.annotate.comboBooks -width 12 -values $tmp -textvariable ::annotation::annotateData(AnalysisBookName)
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
        ttk::radiobutton  $f.av.all     -text $::tr(AnnotateAll)   -variable ::annotation::annotateData(annotateMoves) -value all
        ttk::radiobutton  $f.av.white   -text $::tr(AnnotateWhite) -variable ::annotation::annotateData(annotateMoves) -value white
        ttk::radiobutton  $f.av.black   -text $::tr(AnnotateBlack) -variable ::annotation::annotateData(annotateMoves) -value black
        ttk::checkbutton  $f.av.vars    -text "Store two variations" -variable ::annotation::annotateData(anzVariation) -onvalue 2 -offvalue 1
        pack $f.av.all $f.av.white $f.av.black $f.av.vars -side top -fill x -anchor w

        ttk::labelframe   $f.comment -text $::tr(Comments)
        # Checkmark to enable all-move-scoring
        ttk::checkbutton  $f.comment.scoreAll -text $::tr(ScoreAllMoves) -variable ::annotation::annotateData(scoreAllMoves)
        ttk::checkbutton  $f.comment.cbShortAnnotation -text $::tr(ShortAnnotations) -variable ::annotation::annotateData(annotateShort)
        ttk::checkbutton  $f.comment.cbAddScore -text $::tr(AddScoreToShortAnnotations) -variable ::annotation::annotateData(addScoreToShortAnnotations)
        ttk::checkbutton  $f.comment.cbAddAnnotatorTag  -text $::tr(addAnnotatorTag) -variable ::annotation::annotateData(addAnnotatorTag)
        ttk::checkbutton  $f.comment.cbMarkTactics -text $::tr(MarkTacticalExercises) -variable ::annotation::annotateData(tacticalExercises)
        pack $f.comment.scoreAll $f.comment.cbShortAnnotation $f.comment.cbAddScore \
            $f.comment.cbAddAnnotatorTag $f.comment.cbMarkTactics -fill x -anchor w
        # batch annotation of consecutive games, and optional opening errors finder
        ttk::labelframe $f.batch -text "Batch Annotation"
        ttk::frame $f.buttons
        ttk::frame $f.running
        ttk::label $f.running.line1 -textvariable ::annotation::annotateData(msg1) -width 60
        ttk::label $f.running.line2 -textvariable ::annotation::annotateData(msg2) -width 10
        ttk::label $f.running.line3 -textvariable ::annotation::annotateData(msg3) -width 10
        ttk::progressbar $f.running.progress -variable ::annotation::annotateData(progress) -orient horizontal -length 600
        ttk::progressbar $f.running.games -variable ::annotation::annotateData(games) -orient horizontal -length 600
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

        set annotateData(batchEnd) [sc_base numGames $::curr_db]
        if {$annotateData(batchEnd) <1} { set annotateData(batchEnd) 1 }
        ttk::checkbutton $f.batch.cbBatch -text $::tr(AnnotateSeveralGames) -variable ::annotation::annotateData(batchMode)
        ttk::spinbox $f.batch.spBatchEnd -width 8 -textvariable ::annotation::annotateData(batchEnd) \
            -from 1 -to $annotateData(batchEnd) -increment 1 -validate all -validatecommand { regexp {^[0-9]+$} %P }
        ttk::checkbutton $f.batch.cbBatchOpening -text $::tr(FindOpeningErrors) -variable ::annotation::annotateData(OpeningErrors)
        ttk::spinbox $f.batch.spBatchOpening -width 2 -textvariable ::annotation::annotateData(OpeningMoves) \
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
                catch { unset ::enginewin::engConfig_annotateEngine }
                ::engine::close annotateEngine
                destroy .annotationDialog
            }
        }
        ttk::button $f.buttons.ok -text "Annotate" -command {
            if {$::annotateTime < 0.1} { set ::annotateTime 0.1 }
            set annotateData(movetime) [expr {int($::annotateTime * 1000.0)}]
            set annotateData(blunderThreshold) $::annotateBlunderThreshold
            set annotateData(time) $::annotateTime
            if { [::engineNoWin::initEngine annotateEngine $::annotation::annotateData(engine) \
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
        global ::annotation::annotateData
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
        set annotateData(prevscore1) 0
        set annotateData(prevscore2) 0
        set annotateData(score) 0
        set annotateData(scoremate) 0
        set annotateData(prevscoremate) 0
        set annotateData(prevmoves1) ""
        set annotateData(prevmoves2) ""
        set annotateData(moves) ""
        set annotateData(progress) 1
        set annotateData(msg1) "$::tr(game) [sc_game number]: [sc_game info white] - [sc_game info black]"
        set annotateData(msg2) "$::tr(game) $annotateData(games)"
        set annotateData(msg3) "$::tr(move) 1"
        if { $annotateData(addAnnotatorTag) } {
            appendAnnotator "$annotateData(engine) $annotateData(typ) $annotateData($annotateData(typ))"
        }
    }

    proc annotateGame { } {
        global ::annotation::annotateData
        initGameAnnotation
        makeBookAnnotation
        # Annotate all remaining moves of the game
        while { 1 } {
            set annotateData(PV1) [list "" "" ""]
            set annotateData(PV2) [list "" "" ""]
            ::engine::send annotateEngine Go [list [sc_game UCI_currentPos] [list $annotateData(typ) $annotateData($annotateData(typ))]]
            vwait ::annotation::annotateData(move_done)
            addAnnotation
            incr annotateData(progress)
            set annotateData(msg3) "$::tr(move) $annotateData(progress)"
            if {[sc_pos isAt end] || ! $::autoplayMode } break
            sc_move forward
            ::notify::PosChanged -pgn
        }
    }

    proc runAnnotation { } {
        global ::annotation::annotateData
        # make sure, we have 2 best lines
        ::engine::send annotateEngine SetOptions [list {MultiPV 2}]
        set f .annotationDialog.f
        grid forget $f.annotate $f.comment $f.av $f.batch $f.optsannotateEngine
        pack forget $f.buttons.ok
        if {!$annotateData(batchMode)} { grid forget $f.running.games $f.running.line2 }
        # show progressbar and game infos
        set annotateData(games) 1
        set gameNo [sc_game number]
        $f.running.games configure -maximum [expr {$annotateData(batchEnd) - $gameNo + 1}]
        grid $f.running -row 2 -column 0 -columnspan 2 -sticky we

        # tactical positions is selected, must be in multipv mode
        if {$annotateData(tacticalExercises)} { ::engine::send annotateEngine SetOptions [list {MultiPV 4}] }

        set ::autoplayMode 1
        set gameNo [sc_game number]
        if { $gameNo == 0 } { return }
        annotateGame
        while {$annotateData(batchMode)} {
            sc_game save $gameNo
            incr gameNo
            incr annotateData(games)
            if { ! $::autoplayMode || $gameNo > $annotateData(batchEnd) } { break }
            sc_game load $gameNo
            annotateGame
        }
        set ::autoplayMode 0
        unset ::enginewin::engConfig_annotateEngine
        ::engine::close annotateEngine
        ::notify::PosChanged -pgn
        destroy .annotationDialog
    }

    ################################################################################
    # Part of annotation process : will check the moves if they are in te book, and add a comment
    # when going out of it
    ################################################################################
    proc makeBookAnnotation { } {
        global ::annotation::annotateData
        if {$annotateData(useAnalysisBook)} {
            set prevbookmoves ""
            set bn [ file join $::scidBooksDir $annotateData(AnalysisBookName) ]
            sc_book load $bn $annotateData(BookSlot)

            lassign [sc_book moves $annotateData(BookSlot)] bookmoves
            while {[string length $bookmoves] != 0 && ![sc_pos isAt vend]} {
                # we are in book, so move immediately forward
                ::move::Forward
                set prevbookmoves $bookmoves
                lassign [sc_book moves $annotateData(BookSlot)] bookmoves
            }
            sc_book close $annotateData(BookSlot)

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
            if { $annotateData(OpeningErrors) && ([sc_pos moveNumber] < $annotateData(OpeningMoves) ) } {
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
        global ::annotation::annotateData
        # Let's try to assess the situation:
        # We are here, now that the engine has analyzed the position reached by
        # our last move. Currently it is the opponent to move:
        set tomove [sc_pos side]
        set gamemove [sc_game info previousMoveUCI]

        # And this is his best line:
        lassign $annotateData(PV1) score score_type annotateData(moves)
        if { $gamemove eq "" || $score eq "" } { set annotateData(prevscore1) $score; return }
        set moves $annotateData(moves)
        set bestMoveIsMate 0
        if { $score_type eq "mate" } {
        # We do not want to insert a best-line variation into the game
        # if we did play along that line. Even not when annotating all moves.
        # It simply makes no sense to do so (unless we are debugging the engine!)
        # Sooner or later the game will deviate anyway; a variation at that point will
        # do nicely and is probably more accurate as well.
            set bestMoveIsMate 1
            set annotateData(scoremate) $score
            set score [expr { $score < 0 ? -127 : 127 }]
            set annotateData(score) $score
        } else {
            set annotateData(score) $score
            set annotateData(scoremate) 0
        }

        # We will add a closing line at the end of variation or game
        set addClosingLine 0
        if {  [sc_pos isAt vend] } {
            set addClosingLine 1
        }

        # This is the score we could have had if we had played our best move
        set prevscore $annotateData(prevscore1)

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
        if { $deltamove > $annotateData(blunderThreshold) } {
            set isBlunder 2
        } elseif { $deltamove > 0 } {
            set isBlunder 1
        }
        set absdeltamove [expr { abs($deltamove) } ]

        # to parse scores if the engine's name contains - or + chars (see sc_game_scores)
        set engine_name  [string map {"-" " " "+" " "} $annotateData(engine)]

        # Prepare score strings for the opponent
        if { $annotateData(scoremate) != 0 } {
            set text [format "M%d" [expr abs($annotateData(scoremate))]]
        } else {
            set wscore [format "%+.2f" $score]
            if { $tomove eq "black" } {set wscore [expr 0.0 - $wscore] }
            set text "\[%eval $wscore\]"
        }

        # See if we have the threshold filter activated.
        # If so, take only bad moves and missed mates until the position is lost anyway
        # Or that we must annotate all moves
        if { ( $annotateData(annotateBlunders) == "blundersonly"
                 && ($isBlunder > 1 || ($isBlunder > 0 && [expr abs($score)] >= 327.0))
                 && ! $gameIsLost)
              || ($annotateData(annotateBlunders) == "allmoves") } {
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
            if { ! $annotateData(annotateShort) } {
                sc_pos setComment "[sc_pos getComment] $engine_name: $text"
            } elseif { $annotateData(addScoreToShortAnnotations) || $annotateData(scoreAllMoves) } {
                sc_pos setComment "[sc_pos getComment] $text"
            }

             # Add position score nag
            sc_pos addNag [scoreToNag $score]
            # Add the variation
            sc_move back
            if { $annotateData(annotateBlunders) == "blundersonly" } {
                # Add a diagram tag, but avoid doubles
                if { [string first "D" "[sc_pos getNags]"] == -1 } {
                    sc_pos addNag "D"
                }
            }

            if { $annotateData(prevmoves1) != "" && ( $annotateData(annotateMoves) == "all" ||
                                       $annotateData(annotateMoves) == "white"  &&  $tomove == "black" ||
                                       $annotateData(annotateMoves) == "black"  &&  $tomove == "white" )} {
                set n 1
                while { $n <= $annotateData(anzVariation) && $annotateData(prevmoves$n) ne "" } {
                    sc_var create
                    # Add the starting move
                    sc_move addSan [lrange $annotateData(prevmoves$n) 0 0]
                    # Add its score
                    if { ! $annotateData(annotateShort) || $annotateData(addScoreToShortAnnotations) } {
                        # And for the (missed?) chance
                        if { $annotateData(prevscoremate) != 0 } {
                            set prevtext [format "M%d" [expr abs($annotateData(prevscoremate))]]
                        } else {
                            set wprevscore [format "%+.2f" $annotateData(prevscore$n)]
                            if { $tomove eq "white" } {set wprevscore [expr 0.0 - $wprevscore] }
                            set prevtext "\[%eval $wprevscore\]"
                        }
                        sc_pos setComment "$prevtext"
                    }
                    # Add remaining moves
                    sc_move addSan [lrange $annotateData(prevmoves$n) 1 end]
                    # Add position NAG, unless the line ends in mate
                    if { $n == 1 && $annotateData(prevscoremate) == 0 } {
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
            if { $annotateData(scoreAllMoves) } {
                # Add a score mark anyway
                sc_pos setComment "[sc_pos getComment] $text"
            }
        }

        if { $addClosingLine } {
            sc_move back
            sc_var create
            sc_move addSan $gamemove
            if { ($annotateData(scoremate) == 0) && ( ! $annotateData(annotateShort) || $annotateData(addScoreToShortAnnotations)) } {
                sc_pos setComment "$text"
            }
            sc_move addSan $moves
            if { $annotateData(scoremate) == 0 } {
                sc_pos addNag [scoreToNag $score]
            }
            sc_var exit
            # Now up to the end of the game
            ::move::Forward
        }
        set annotateData(prevscore1) $annotateData(score)
        set annotateData(prevmoves1) $annotateData(moves)
        lassign $annotateData(PV2) annotateData(prevscore2) score_type annotateData(prevmoves2)
        set annotateData(prevscoremate) $annotateData(scoremate)
        updateBoard -pgn
    }

    ################################################################################
    # Will add **** to any position considered as a tactical shot
    # check at which depth the tactical shot is found
    ################################################################################
    proc markExercise { prevscore score nag} {
        global ::annotation::annotateData
        sc_pos addNag $nag
        if { ! $annotateData(tacticalExercises)} { return 0 }

        set deltamove [expr {$score + $prevscore}]
        # filter tactics so only those with high gains are kept
        if { [expr abs($deltamove)] < $::informant("+/-") } { return 0 }
        # dismiss games where the result is already clear (high score,and we continue in the same way)
        if { [expr $prevscore * $score] >= 0} {
            if { [expr abs($prevscore) ] > $::informant("+--") } { return 0 }
            if { [expr abs($prevscore)] > $::informant("+-") && [expr abs($score) ] < [expr 2 * abs($prevscore)]} { return 0 }
        }

        # The best move is much better than others.
        set sc2 [lindex $annotateData(PV2) 0]
        if { [expr abs( $score - $sc2 )] < 1.5 } { return 0 }

        # The best move does not lose position.
        if {([sc_pos side] == "black") && ($score < [expr 0.0 - $::informant("+/-")]) } { return 0 }
        if {([sc_pos side] == "white") && ($score > $::informant("+/-")) } { return 0}

        # Move is not obvious: check that it is not the first move guessed at low depths
        set pv [ lindex [ lindex $annotateData(PV1) 2 ] 0 ]
        # bm0 must SAN, pv is UCI: convert
        set bm0 [string range [lindex $pv 0] 0 4]
        set bm0 [sc_pos coordToSAN $annotateData(position) $bm0]
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
        global ::annotation::annotateData
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
                set annotateData(PV$multipv) [list $score $score_type $pv]
            }
            "InfoBestMove" {
                lassign $msgData annotateData(bestmove)
                set annotateData(move_done) 1
            }
            "InfoGo" {
                lassign $msgData annotateData(position)
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
