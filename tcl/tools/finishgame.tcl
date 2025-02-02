###
### finishgame.tcl: part of Scid.
### This file is part of Scid (Shane's Chess Information Database).
### Copyright (C) 2025 Uwe Klimmek
### uses code from Fulvio Benini https://github.com/benini/chess_accuracy and analysis.tcl
##########################################################################################
### finishGame Dialog: uses a chess engine to play a game

namespace eval ::finishgame {

    set ::finishGame(annotate) 1
    set ::finishGame(annotateShort) 1
    set ::finishGame(enginewhite) ""
    set ::finishGame(engineblack) ""
    set ::finishGame(cmdwhite) movetime
    set ::finishGame(cmdblack) movetime
    set ::finishGame(cmdValuewhite) 2
    set ::finishGame(cmdValueblack) 2

    ################################################################################
    # will ask engine(s) to play the game till the end
    ################################################################################
    proc finishGameDialog { } {
        if { $::autoplayMode } { return }

        # UCI engines
        # On exit save values in options.dat
        ::options.store ::finishGame(annotate)
        ::options.store ::finishGamen(annotateShort)
        ::options.store ::finishGame(enginewhite)
        ::options.store ::finishGame(engineblack)

        set w .configFinishGame
        win::createDialog $w
        wm resizable $w 0 0
        ::setTitle $w "Scid: $::tr(FinishGame)"

        ttk::labelframe $w.wh_f -text "$::tr(White)" -padding 5
        grid $w.wh_f -column 0 -row 0 -columnspan 2 -sticky we -pady 8
        foreach psize $::boardSizes {
            if {$psize >= 40} { break }
        }
        set engList [::enginecfg::names ]
        if { $::finishGame(enginewhite) eq "" } { set ::finishGame(enginewhite) [lindex $engList 0] }
        if { $::finishGame(engineblack) eq "" } { set ::finishGame(engineblack) [lindex $engList 0] }
        ttk::label $w.wh_f.p -image wk$psize
        grid $w.wh_f.p -column 0 -row 0 -rowspan 3
        ttk::combobox $w.wh_f.engine -width 26 -state readonly -values $engList -textvariable ::finishGame(enginewhite)
        ttk::spinbox $w.wh_f.cv -width 3 -textvariable ::finishGame(cmdValuewhite) -from 1 -to 999 -justify right
        ttk::radiobutton $w.wh_f.c1 -text $::tr(seconds) -variable ::finishGame(cmdwhite) -value "movetime"
        ttk::radiobutton $w.wh_f.c2 -text $::tr(FixedDepth) -variable ::finishGame(cmdwhite) -value "depth"
        grid $w.wh_f.engine -column 1 -row 1 -columnspan 3 -sticky w
        grid $w.wh_f.cv -column 1 -row 2 -sticky w
        grid $w.wh_f.c1 -column 2 -row 2 -sticky w -padx 6
        grid $w.wh_f.c2 -column 3 -row 2 -sticky w

        ttk::labelframe $w.bk_f -text "$::tr(Black)" -padding 5
        grid $w.bk_f -column 0 -row 1 -columnspan 2 -sticky we -pady 8
        ttk::label $w.bk_f.p -image bk$psize
        grid $w.bk_f.p -column 0 -row 0 -rowspan 3
        ttk::combobox $w.bk_f.engine -width 26 -state readonly -values $engList -textvariable ::finishGame(engineblack)
        ttk::spinbox $w.bk_f.cv -width 3 -textvariable ::finishGame(cmdValueblack) -from 1 -to 999 -justify right
        ttk::radiobutton $w.bk_f.c1 -text $::tr(seconds) -variable ::finishGame(cmdblack) -value "movetime"
        ttk::radiobutton $w.bk_f.c2 -text $::tr(FixedDepth) -variable ::finishGame(cmdblack) -value "depth"
        grid $w.bk_f.engine -column 1 -row 1 -columnspan 3 -sticky w
        grid $w.bk_f.cv -column 1 -row 2 -sticky w
        grid $w.bk_f.c1 -column 2 -row 2 -sticky w -padx 6
        grid $w.bk_f.c2 -column 3 -row 2 -sticky w

        ttk::checkbutton $w.finishGame -text $::tr(Annotate) -variable ::finishGame(annotate)
        grid $w.finishGame -column 0 -row 2 -sticky w -padx 5 -pady 8
        ttk::checkbutton $w.finishGameShort -text $::tr(ShortAnnotations) -variable ::finishGame(annotateShort)
        grid $w.finishGameShort -column 1 -row 2 -sticky w -padx 5 -pady 8

        ttk::frame $w.fbuttons
        ttk::button $w.fbuttons.cancel -text $::tr(Cancel) -command {
            if { $::autoplayMode } {
                set ::autoplayMode 0
            } else {
                destroy .configFinishGame
            }
        }

        ttk::button $w.fbuttons.ok -text "OK" -command {
            set msg [::finishgame::initfgEngine white $::finishGame(enginewhite)]
            if { $msg eq "ok" } {
                set msg [::finishgame::initfgEngine black $::finishGame(engineblack)]
                if { $msg eq "ok" } {
                    ::finishgame::runFinishGame
                }
            }
            if { $msg ne "ok" } {
                tk_messageBox -title Scid -icon info -type ok -message $msg
            }
        }
        packbuttons right $w.fbuttons.cancel $w.fbuttons.ok
        grid $w.fbuttons -row 3 -column 1 -columnspan 2 -sticky we
        focus $w.fbuttons.ok
        bind $w <Escape> { .configFinishGame.cancel invoke }
        bind $w <Return> { .configFinishGame.ok invoke }
        bind $w <Destroy> { focus . }
        grab $w
    }

    # Open the engine and configure it
    proc initfgEngine { color engine } {
        set config [::enginecfg::get $engine]
        lassign $config name cmd args wdir elo time url uci options
        if { ! $uci } { return "Only UCI-Engines are supported!" }
        ::engine::setLogCmd fgEngine$color {}
        ::engine::connect fgEngine$color ::finishgame::eng_messages $cmd {}
        lappend options "MultiPV 2"
        ::engine::send fgEngine$color SetOptions $options
        return "ok"
    }

    proc ::finishgame::annotate { tomove } {
        lassign $::finishGame(PV1) score score_type pv
        if { $tomove eq "black" } {set score [expr 0.0 - $score] }
        set tmp [sc_pos getComment]
        if { $score_type eq "mate" } {
            set score "M$score"
        } else {
            set score "\[%eval $score\]"
        }
        sc_pos setComment "$tmp $score"
    }

    proc ::finishgame::runFinishGame { } {
        set w .configFinishGame
        grid forget $w.wh_f $w.bk_f
        pack forget $w.fbuttons.ok
        set ::autoplayMode 1
        set tomove [sc_pos side]
        set value(white) $::finishGame(cmdValuewhite)
        set value(black) $::finishGame(cmdValueblack)
        if { $::finishGame(cmdwhite) eq "movetime" } { set value(white) [expr {$::finishGame(cmdValuewhite) * 1000 }] }
        if { $::finishGame(cmdblack) eq "movetime" } { set value(black) [expr {$::finishGame(cmdValueblack) * 1000 }] }

        sc_var create
        while {$::autoplayMode} {
            ::engine::send fgEngine$tomove Go [list [sc_game UCI_currentPos] [list $::finishGame(cmd$tomove) $value($tomove)]]
            vwait ::finishGame(moveDone)
            if { [catch { sc_move addSan $::finishGame(bestmove) }] } {
                set ::autoplayMode 0
            } else {
                ::finishgame::annotate $tomove
            }
            sc_move forward
            ::notify::PosChanged -pgn
            set tomove [expr {$tomove eq "white" ? "black" : "white"}]
        }
        sc_var exit

        set ::autoplayMode 0
        set tmp [sc_pos getComment]
        sc_pos setComment "$tmp\n\n$::tr(FinishGame) $::tr(White): $::finishGame(enginewhite) $::finishGame(cmdwhite) $::finishGame(cmdValuewhite)\n\n$::tr(Black): $::finishGame(engineblack) $::finishGame(cmdblack) $::finishGame(cmdValueblack)"
        ::engine::close fgEnginewhite
        ::engine::close fgEngineblack
        ::notify::PosChanged -pgn
        destroy .configFinishGame
    }

    proc ::finishgame::eng_messages {msg} {
        lassign $msg msgType msgData
        switch $msgType {
            "InfoPV" {
                lassign $msgData multipv depth seldepth nodes nps hashfull tbhits time score score_type score_wdl pv
                if { $score_type ne "mate" } { set score [expr {$score / 100.0}] }
                set ::finishGame(PV$multipv) [list $score $score_type $pv]
            }
            "InfoBestMove" {
                lassign $msgData ::finishGame(bestmove)
                set ::finishGame(moveDone) 1
            }
            "InfoGo" {
                lassign $msgData ::annotate(position)
            }
            "InfoDisconnected" {
                lassign $msgData errorMsg
                if {$errorMsg eq ""} { set errorMsg "The connection with the engine terminated unexpectedly." }
                tk_messageBox -icon warning -type ok -parent . -message $errorMsg
                set ::autoplayMode 0
            }
        }
    }

}
