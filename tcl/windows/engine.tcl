########################################################################
# Copyright (C) 2020-2026 Fulvio Benini
#
# This file is part of Scid (Shane's Chess Information Database).
# Scid is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.

### Window for chess engine configuration and position analysis

# Functions callable from outside:
# ::enginewin::listEngines
#   Return a list containing the engine's ID, name and running state.
# ::enginewin::start id ?enginename?
#   Start an engine (opens window if necessary).
# ::enginewin::stop id
#   Stop the engine.
# ::enginewin::toggleStartStop id ?enginename?
#   Toggle the running state of the engine.
# ::enginewin::Open id ?enginename?
#   Open a new engine window.
#
# Functions responding to events:
# ::enginewin::onNewGame id
#   Handles the <<NotifyNewGame>> event, flagging the engine to reset.
# ::enginewin::onPosChanged ?ids?
#   Sends the updated position to the active engines.

namespace eval enginewin {}

# Engine states:
# close.follow            -> No engine is open.
# close.follow.disconnect -> The engine was open, but the connection was terminated.
# ready.follow.pause      -> The engine is open and ready (paused).
# ready.follow.autorun    -> The engine is analyzing the current game.
# ready.follow.run        -> The engine is analyzing the current position.
# ready.follow.run.done   -> The engine has finished analyzing the current position.
# ready.follow.run.idle   -> The engine is idle after changing an option.
# ready.locked.run        -> The engine is analyzing a fixed position.
# ready.locked.run.done   -> The engine has finished analyzing a fixed position.
# ready.locked.run.idle   -> The engine is idle after changing an option.
array set ::enginewin::engState {}

# Return a list containing the engine's ID, engine's name and true if it is running.
# Return only the engines available for current position analysis.
proc ::enginewin::listEngines {} {
    lmap id [array names ::enginewin::engState] {
        set follow [::enginewin::stateFollow $id]
        if {!$follow && ![::enginewin::statePaused $id]} { continue }
        list $id $::enginewin_lastengine($id) $follow
    }
}

# Handles <<NotifyNewGame>>. Schedule a NewGame msg for the engine.
proc ::enginewin::onNewGame {id} {
    set ::enginewin::m_(newgame,$id) true
}

# Sends the updated position to the active engines
proc ::enginewin::onPosChanged { {ids ""}} {
    set position ""
    foreach {id} [array names ::enginewin::engState] {
        if {![::enginewin::stateFollow $id]} { continue }
        if {$ids ne "" && $id ni $ids} { continue }
        if {$position eq ""} {
            set position [sc_game UCI_currentPos]
            set ply [expr {[sc_var level] ? -1 : [sc_pos location]}]
        }
        if {[catch { ::enginewin::sendPosition $id $position $ply }]} {
            ::enginewin::changeState $id paused.deceased
        }
    }
}

# Start an engine (if necessary it will opens a new enginewin window).
# Return the engine's id.
proc ::enginewin::start { {id ""} {enginename ""} } {
    if {$id eq "" || ![winfo exists .engineWin$id]} {
        set id [::enginewin::Open $id $enginename]
    } elseif {![::enginewin::statePaused $id]} {
        return $id
    }
    ::enginewin::changeState $id follow.*
    ::enginewin::onPosChanged $id
    return $id
}

# Stop the engine.
# Return true if a StopGo message was sent to the engine.
proc ::enginewin::stop {id} {
    if {[winfo exists .engineWin$id] &&
        ([::enginewin::stateFollow $id] || [::enginewin::stateLocked $id])} {
        ::enginewin::changeState $id paused.*
        ::engine::send $id StopGo
        return true
    }
    return false
}

# If the engine is running, stop it. Otherwise invoke ::enginewin::start
# Return the engine's id.
proc ::enginewin::toggleStartStop { {id ""} {enginename ""} } {
    if {[::enginewin::stop $id]} {
        return $id
    }
    return [::enginewin::start $id $enginename]
}

proc ::enginewin::Open { {id ""} {enginename ""} } {
    if {$id == ""} {
        set id 1
        while {[winfo exists .engineWin$id]} {
            incr id
        }
    }
    set w .engineWin$id
    if {! [::win::createWindow $w ""]} {
        ::win::makeVisible $w
        return
    }

    ::options.store ::enginewin_lastengine($id) ""
    ::options.store ::enginewin_limits($id) {}
    ::options.store ::enginewin_autorun($id) {{movetime 50}}
    ::options.store ::enginewin_chartH($id) 160

    # The main windows is divided in three parts:
    # - at the top $w.header_info which shows time, nps, etc...
    # - at the bottom the buttons bar
    # - in the middle $w.main which is further divided in parts:
    #   - $w.debug where all the engine's i/o is shown (can be hidden)
    #   - $w.display where the pv lines are shown
    #   - $w.chart where the evaluation chart is shown
    #   - right: $w.config with all the engine options (can be hidden)

    ttk::frame $w.header_info
    ttk_text $w.header_info.text -style Toolbutton -wrap word -height 1 -pady 2
    autoscrollBars y $w.header_info $w.header_info.text

    ttk::frame $w.main

    ttk::frame $w.config
    ttk::frame $w.config.btn
    ::enginecfg::createConfigButtons $id $w.config.btn
    bind $w.config.btn <<EngineCfgConnect>> "::enginewin::connectEngine {*}%d"
    ttk::frame $w.config.options
    ::enginecfg::createConfigOptions $id $w.config.options
    bind $w.config.options <<EngineCfgConnect>> "::enginewin::connectEngine {*}%d"
    bind $w.config.options <<EngineCfgLayout>> "::enginewin::changeDisplayLayout {*}%d"
    grid columnconfigure $w.config 0 -weight 1
    grid rowconfigure $w.config 1 -weight 1
    grid $w.config.btn
    grid $w.config.options -sticky news

    ttk::panedwindow $w.pane -orient vertical
    ttk::frame $w.debug
    ttk_text $w.debug.lines -state disabled
    autoscrollBars y $w.debug $w.debug.lines
    ttk::frame $w.display
    ::enginewin::createDisplayFrame $id $w.display
    $w.pane add $w.display -weight 1
    ttk::frame $w.chart
    ttk_canvas $w.chart.canvas -highlightthickness 0
    ::chart::init $w.chart.canvas {FONT font_Regular}
    grid $w.chart.canvas -sticky news
    grid rowconfigure $w.chart 0 -weight 1
    grid columnconfigure $w.chart 0 -weight 1
    $w.pane add $w.chart -weight 0
    bind $w.pane <Map>  [list apply {{id w} {
        update idletasks
        $w.pane sashpos [expr {[llength [$w.pane panes]] - 2}] \
            [expr {[winfo height $w.pane] - $::enginewin_chartH($id)}]
    }} $id $w]
    bind $w.pane <ButtonRelease-1> [list apply {{id w} {
        set n_sash [expr {[llength [$w.pane panes]] - 2}]
        set ::enginewin_chartH($id) [expr {[winfo height $w.pane] - [$w.pane sashpos $n_sash]}]
    }} $id $w]

    grid $w.pane -row 0 -column 0 -in $w.main -sticky news
    grid $w.config -row 0 -column 1 -in $w.main -sticky news -padx {10 0}
    grid rowconfigure $w.main 0 -weight 1
    grid columnconfigure $w.main 0 -weight 1000
    grid columnconfigure $w.main 1 -weight 1

    ttk::frame $w.btn
    ::enginewin::createButtonsBar $id $w.btn $w.display

    grid $w.header_info -sticky news
    grid $w.main -sticky news
    grid $w.btn -sticky news
    grid rowconfigure $w 0 -weight 0
    grid rowconfigure $w 1 -weight 1
    grid rowconfigure $w 2 -weight 0
    grid columnconfigure $w 0 -weight 1

    bind $w <<NotifyNewGame>> "::enginewin::onNewGame $id"

    # The engine should be closed before the debug .text is destroyed
    bind $w.config <Destroy> "
        unset ::enginewin::engState($id)
        ::engine::close $id
        array unset ::enginewin::m_ *,$id
        array unset ::enginewin::pv_ *,$id
        unset ::enginecfg::engConfig_$id
        ::notify::EngineBestMove $id {} {}
    "

    set ::enginewin::engState($id) {}
    set ::enginewin::m_(afterId,$id) {}
    set ::enginewin::m_(limits,$id) $::enginewin_limits($id)
    set ::enginewin::m_(position,$id) ""
    set ::enginewin::m_(posPly,$id) ""
    set ::enginewin::m_(mainLine,$id) ""
    set ::enginewin::m_(newgame,$id) true
    set ::enginewin::m_(startTime,$id) [clock milliseconds]

    if {$enginename eq ""} {
        set enginename $::enginewin_lastengine($id)
    }
    catch { ::enginewin::connectEngine $id $enginename }
    return $id
}

# Creates $w.display, where the pv lines sent by the engine will be shown.
proc ::enginewin::createDisplayFrame {id display} {
    set pv_lines $display.pv_lines
    ttk_text $pv_lines -exportselection true -padx 4 -state disabled
    autoscrollBars both $display $pv_lines

    set tab [font measure font_Regular -displayof $display "xxxxxxx"]
    $pv_lines configure -tabs [list [expr {$tab * 2}] right [expr {int($tab * 2.2)}]]
    $pv_lines tag configure lmargin -lmargin2 [expr {$tab * 3}]
    $pv_lines tag configure markmove -underline 1
    $pv_lines tag bind moves <ButtonRelease-1> {
        if {[%W tag ranges sel] eq ""} {
            ::enginewin::exportMoves %W @%x,%y
        }
    }
    $pv_lines tag bind moves <Motion> [list apply {{id} {
        set old_markmove [%W tag nextrange markmove 1.0]
        if {[%W tag ranges sel] ne ""} {
            destroy .enginewinBoard
            if {$old_markmove ne ""} { %W tag remove markmove {*}$old_markmove }
            return
        }
        # TODO:
        # Using wordstart and wordend would be a lot more efficient.
        # However they do not consider the [+.-] chars as part of the word.
        # set movestart [%W index "@%x,%y wordstart"]
        # %W tag add markmove $movestart "$movestart wordend"
        set movestart "[%W search -backwards -regexp {\s} "@%x,%y"] +1chars"
        set new_markmove [list [%W index $movestart] [%W search " " $movestart]]
        if {$new_markmove eq $old_markmove} { return }

        if {$old_markmove ne ""} { %W tag remove markmove {*}$old_markmove }
        %W tag add markmove {*}$new_markmove
        after cancel $::enginewin:::m_(afterId,$id)
        set ::enginewin::m_(afterId,$id) [after 10 [list apply {{id w} {
            # An exception will be thrown if the engine sent an illegal pv,
            # the tag was removed, the text widget is destroyed or not visible
            if {[catch {
                lassign [$w tag nextrange markmove 1.0] index
                set moves [::enginewin::getMoves $w $index]
                set pos [sc_pos board $::enginewin::m_(position,$id) $moves]
                lassign [$w bbox $index] x y width height
                set x [expr {$x + [winfo rootx $w] + $width}]
                incr y [winfo rooty $w]
                ::board::popup .enginewinBoard $pos $x $y $height
                ::board::flip .enginewinBoard.bd [main_isFlipped]
            }]} {
                destroy .enginewinBoard
            }
        }} $id %W]]
    }} $id]
    $pv_lines tag bind moves <Any-Leave> {
        %W tag remove markmove 1.0 end
        destroy .enginewinBoard
    }
}

# Creates the buttons bar
proc ::enginewin::createButtonsBar {id btn display} {
    ttk::button $btn.startStop -image [list ::icon::tb_eng_on pressed ::icon::tb_eng_off user1 ::icon::tb_eng_off] \
        -style Toolbutton -command "::enginewin::toggleStartStop $id"
    #TODO: change the tooltip to "Start/stop engine"
    ::utils::tooltip::Set $btn.startStop [tr StartEngine]

    ttk::button $btn.lock -image ::icon::tb_eng_lock -style Toolbutton -command [list apply {{id} {
        if {[::enginewin::stateLocked $id]} {
            ::enginewin::changeState $id follow.*
            ::enginewin::onPosChanged $id
        } elseif {[::enginewin::stateFollow $id]} {
            ::enginewin::changeState $id locked.*
        }
    }} $id]
    ::utils::tooltip::Set $btn.lock [tr LockEngine]

    set pv_lines $display.pv_lines
    ttk::button $btn.addbestmove -image ::icon::tb_eng_addbestmove -style Toolbutton \
        -command "::enginewin::exportMoves $pv_lines 1.0"
    ::utils::tooltip::Set $btn.addbestmove [tr AddMove]
    ttk::button $btn.addlines -image ::icon::tb_eng_addlines -style Toolbutton \
        -command "::enginewin::exportLines $pv_lines"
    ::utils::tooltip::Set $btn.addlines [tr AddAllVariations]

    ttk::spinbox $btn.multipv -increment 1 -width 4 -state disabled \
        -validate key -validatecommand [list ::validate::integer %P 0] \
        -command "after idle \[bind $btn.multipv <FocusOut>\]"
    bind $btn.multipv <Return> { {*}[bind %W <FocusOut>] }
    bind $btn.multipv <FocusOut> "::enginewin::changeOption $id multipv $btn.multipv"
    ::utils::tooltip::Set $btn.multipv [tr Lines]

    menu $btn.menus
    ttk::menubutton $btn.overflow -text "..." -style Toolbutton \
        -direction above -menu $btn.menus

    menu $btn.menus.threads
    foreach {threads_value} {1 2 4 6 8 12 16 32 64} {
        $btn.menus.threads add command -label "$threads_value CPU" -command \
            "::enginewin::changeOption $id threads $threads_value"
    }
    #TODO: change keyboard focus to the threads widget
    $btn.menus.threads add command -label "..." -command \
        "::enginewin::toggleConfigPane $id threads"
    ttk::menubutton $btn.threads -text "1 CPU" -state disabled \
        -style Toolbutton -direction above -menu $btn.menus.threads

    menu $btn.menus.hash
    foreach {hash_value} {16 64 256 1024 2048 4096 8192} {
        $btn.menus.hash add command -label "$hash_value MB" -command \
            "::enginewin::changeOption $id hash $hash_value"
    }
    $btn.menus.hash add command -label "..." -command \
        "::enginewin::toggleConfigPane $id hash"
    ttk::menubutton $btn.hash -text "?? MB" -state disabled \
        -style Toolbutton -direction above -menu $btn.menus.hash

    menu $btn.menus.limits
    foreach {depth_value} {16 20 24 28 32 36 40} {
        $btn.menus.limits add command -label "[tr Depth]: $depth_value" -command \
            "::enginewin::changeOption $id _go_limits \[list \[list depth $depth_value \] \]"
    }
    $btn.menus.limits add command -label "[tr Depth]: ∞" -command \
        "::enginewin::changeOption $id _go_limits {}"
    ttk::menubutton $btn.limits -style Toolbutton -direction above -menu $btn.menus.limits
    trace add variable ::enginewin::m_(limits,$id) write [list apply {{btn arrayName key op} {
        set value [set ${arrayName}($key)]
        set ::enginewin_limits([string range $key 7 end]) $value
        if {$value eq ""} {
            $btn configure -text "depth ∞"
        } else {
            $btn configure -text [join $value]
        }
    }} $btn.limits]

    menu $btn.menus.autorun
    $btn.menus.autorun add radiobutton -label "Off" -value {{}} -variable ::enginewin_autorun($id)
    foreach {ms} {10 25 50 100 250 500 1000} {
        $btn.menus.autorun add radiobutton -variable ::enginewin_autorun($id) \
            -label "$ms ms" -value [list [list movetime $ms]]
    }
    ttk::style configure AutorunButton.Toolbutton
    ttk::style map EnginewinAuto.Toolbutton -foreground {user1 #FF5E0E}
    ttk::menubutton $btn.autorun -text "\u601D" \
        -style EnginewinAuto.Toolbutton -direction above -menu $btn.menus.autorun

    ttk::button $btn.config -image ::icon::tb_eng_config -style Toolbutton \
        -command "::enginewin::toggleConfigPane $id"
    $btn.config state pressed

    grid $btn.startStop $btn.lock $btn.addbestmove $btn.addlines \
         $btn.multipv $btn.limits $btn.autorun $btn.threads $btn.hash \
         $btn.overflow x $btn.config -sticky ew
    grid columnconfigure $btn 10 -weight 1
    grid remove $btn.overflow

    set collapsible [dict create limits "Limits" autorun "Autoscan" threads "CPUs" hash "Hash"]
    bind $btn <Configure> [list ::collapseMenubuttons %W overflow $collapsible]
}

# Show or hide the configuration pane for a specific engine window.
# Show can be "hide", "" (toggle), or the name of an option
proc ::enginewin::toggleConfigPane {id {show ""}} {
    set w .engineWin$id
    set isVisible [expr {[grid info $w.config] ne ""}]
    if {$show eq "" && $isVisible} { set show "hide" }

    if {$show eq "hide"} {
        $w.btn.config state !pressed
        grid remove $w.config
    } else {
        $w.btn.config state pressed
        grid $w.config
        if {$show ne ""} {
            ::enginecfg::focusOption $id $w.config.options $show
        }
    }
}

proc ::enginewin::changeDisplayLayout {id param value} {
    set w .engineWin$id
    switch $param {
        "debug" {
            ::enginewin::logEngine $id $value
        }
        "notation" -
        "scoreside" {
            set ::enginewin::m_($param,$id) $value
        }
        "wrap" {
            $w.display.pv_lines configure -wrap $value
        }
    }
}

proc ::enginewin::logEngine {id on} {
    catch { .engineWin$id.pane forget .engineWin$id.debug }
    .engineWin$id.debug.lines configure -state normal
    .engineWin$id.debug.lines delete 1.0 end
    .engineWin$id.debug.lines configure -state disabled
    if {$on} {
        .engineWin$id.pane insert 0 .engineWin$id.debug -weight 1
        ::engine::setLogCmd $id \
            [list ::enginewin::updateDebug $id .engineWin$id.debug.lines "" ""]\
            [list ::enginewin::updateDebug $id .engineWin$id.debug.lines header ">>"]
    } else {
        ::engine::setLogCmd $id "" ""
    }
}

# Determine whether it is Black to move in a given UCI "position" string.
# Returns {isBlackToMove plyCount}.
proc ::enginewin::blackToMove {uci_pos} {
    set idx [string first "moves" $uci_pos]
    if {$idx < 0} {
        set n 0
    } else {
        set t [string range $uci_pos $idx end]
        set n [expr {[string length $t] - [string length [string map {{ } {}} $t]]}]
        set uci_pos [string range $uci_pos 0 $idx]
    }
    if {[string first "fen" $uci_pos] >= 0 && [string first "w" $uci_pos] < 0} {
        set base 1
    } else {
        set base 0
    }
    return [list [expr {($base + $n) % 2 == 1}] $n]
}

# Checks if the given UCI position appears within the main line of moves.
# ply_pos: the number of plies contained in uci_pos.
# Returns a list of all the plies where the position appears in the main line.
# or an empty list if not found. Multiple matches are possible due to null moves.
proc ::enginewin::inMainLine {main_line uci_pos ply_pos {acc {}}} {
    set match [string last $uci_pos [join $main_line]]
    if {$match == -1} {
        return $acc
    }
    if {$match == 0} {
        return [lappend acc $ply_pos]
    }
    set pre_ply 0
    set i 0
    while {$i < $match} {
        incr i [expr {[string length [lindex $main_line $pre_ply]] + 1}]
        incr pre_ply
    }
    tailcall inMainLine [lrange $main_line 0 [expr {$pre_ply - 1}]] \
        $uci_pos $ply_pos [lappend acc [expr {$pre_ply + $ply_pos}]]
}

proc ::enginewin::formatPV {notation position pv} {
    set translated untranslated
    if {$notation > 0} {
        set pv [sc_pos coordToSAN $position $pv]
    }
    if {$notation == 1 || $notation == -1} {
        set pv [::trans $pv]
        set translated translated
    } elseif {$notation == 3 || $notation == -3} {
        set pv [string map {K "\u2654" Q "\u2655" R "\u2656" B "\u2657" N "\u2658"} $pv]
    }
    return [list $pv $translated]
}

proc ::enginewin::updateDebug {id widget tag prefix msg} {
    set t [format "(%.3f) " \
        [expr {( [clock milliseconds] - $::enginewin::m_(startTime,$id) ) / 1000.0}]]
    $widget configure -state normal
    $widget insert end "$t[set prefix]$msg\n" $tag
    $widget see end
    $widget configure -state disabled
}

proc ::enginewin::updateChart {id {msgData ""}} {
    if {[set ::enginewin_chartH($id)] < 10} { return }

    lassign $msgData multipv depth seldepth nodes nps hashfull tbhits time score score_type score_wdl pv
    if {$multipv != 1 || $score eq ""} { return }

    upvar ::enginewin::pv_(depths,$id) depths
    set plies [lmap elem $::enginewin::pv_(ply,$id) {
        if {[dict exists $depths $elem] && $depth < [dict get $depths $elem]} { continue }
        set elem
    }]
    if {$plies eq ""} { return }

    if {$::enginewin::m_(scoreside,$id) eq "white" && $::enginewin::pv_(btm,$id)} {
        set score [expr { - $score }]
    }
    if {$score_type eq "mate"} {
        set score [expr {$score * 100000}]
    }

    foreach ply $plies {
        dict set depths $ply $depth
        ::chart::setDataPoint .engineWin$id.chart.canvas $ply $score \
            [list ::enginewin::chartCallback $id $::enginewin::pv_(pos,$id) $depth $seldepth]
    }
}
proc ::enginewin::chartCallback {id uci_pos depth seldepth ply value} {
    if {$value eq "" } {
        ::move::MainLine $ply $uci_pos
        return ""
    }
    if {$ply == 0} {
        set txt ""
    } else {
        set move [lindex $uci_pos end]
        if {[catch {
            lassign [::enginewin::formatPV $::enginewin::m_(notation,$id) [lrange $uci_pos 0 end-1] $move] txt
        }]} {
            set moveNum [expr {($ply + 1) / 2}]
            set suffix  [expr {$ply % 2 ? "." : "..."}]
            set txt "$moveNum$suffix$move"
        }
    }
    if {abs($value) < 100000} {
        set value [format {%+.2f} [expr {$value / 100.0}]]
    } else {
        set value "#[format {%+d} [expr {$value / 100000}]]"
    }
    if {$seldepth ne ""} { set depth "$depth/$seldepth" }
    return "$txt\n$value\n$depth"
}

proc ::enginewin::updateDisplay {id msgData} {
    lassign $msgData multipv depth seldepth nodes nps hashfull tbhits time score score_type score_wdl pv
    if {$time eq ""} { set time 0 }
    if {$nps eq ""} { set nps 0 }
    if {$hashfull eq ""} { set hashfull 0 }
    if {$tbhits eq ""} { set tbhits 0 }

    set w .engineWin$id
    $w.header_info.text configure -state normal
    $w.header_info.text delete 1.0 end
    $w.header_info.text insert end "[tr Time]: " header
    $w.header_info.text insert end [format "%.2f s" [expr {$time / 1000.0}]]
    $w.header_info.text insert end "   [tr Nodes]: " header
    $w.header_info.text insert end [format "%.2f Kn/s" [expr {$nps / 1000.0}]]
    $w.header_info.text insert end "   Hash: " header
    $w.header_info.text insert end [format "%.1f%%" [expr {$hashfull / 10.0}]]
    $w.header_info.text insert end "   TB Hits: " header
    $w.header_info.text insert end $tbhits
    $w.header_info.text configure -state disabled

    set pv_lines $w.display.pv_lines
    $pv_lines configure -state normal
    if {$msgData eq ""} {
        $pv_lines delete 1.0 end
        $pv_lines configure -state disabled
        return
    }

    set notation $::enginewin::m_(notation,$id)
    set scoreside $::enginewin::m_(scoreside,$id)

    if {[catch {
        lassign [::enginewin::formatPV $notation $::enginewin::pv_(pos,$id) $pv] pv translated
    }]} {
        set pv "illegal_pv! $pv"
        set translated untranslated
    }

    if {$score ne ""} {
        if {$scoreside eq "white" && $::enginewin::pv_(btm,$id)} {
            set score [expr { - $score }]
        }
        if {$score_type eq "mate"} {
            if {$score >= 0} {
                set score "+M$score"
            } else {
                set score "-M[string range $score 1 end]"
            }
        } else {
            set score [format "%+.2f" [expr {$score / 100.0}]]
            if {$score_type eq "lowerbound" || $score_type eq "upperbound"} {
                lappend extraInfo $score_type
            }
        }
    }
    if {$seldepth ne ""} {
        set depth "$depth/$seldepth"
    }
    if {$score_wdl ne ""} {
        lassign $score_wdl win draw lose
        if {$draw eq ""} { set draw 0 }
        if {$lose eq ""} { set lose 0 }
        lappend extraInfo [format "W: %.1f%%" [expr {$win / 10.0}]]
        lappend extraInfo [format "D: %.1f%%" [expr {$draw / 10.0}]]
        lappend extraInfo [format "L: %.1f%%" [expr {$lose / 10.0}]]
    }
    if {$nodes ne ""} {
        if {$nodes > 100000000} {
            lappend extraInfo [format "%.2fM nodes" [expr {$nodes / 1000000.0}]]
        } else {
            lappend extraInfo [format "%.2fK nodes" [expr {$nodes / 1000.0}]]
        }
    }
    set pvline ""
    # End of the first move: first space after the first alpha char
    regexp {^(.*?[A-Za-z].*?)(\s.*)$} $pv -> pv pvline

    set line $multipv
    if {$multipv == 1} {
        # Previous line nr. 1 is now obsolete
        $pv_lines tag remove header 1.0 1.end
    }
    # If the engine has repeatedly sent multipv 1, do not delete the obsolete lines
    catch { $pv_lines tag nextrange header 2.0 } multilines
    if {$line > 1 || $multilines ne ""} {
        # Multipv lines >= than the current one are now obsolete and deleted.
        $pv_lines delete $line.0 end
    }
    $pv_lines insert $line.0 "\n"
    $pv_lines insert $line.end "$depth\t"
    $pv_lines insert $line.end "$score" header
    $pv_lines insert $line.end "\t"
    $pv_lines insert $line.end "$pv" [list header moves $translated]
    $pv_lines insert $line.end "$pvline" [list lmargin moves]
    if {[info exists extraInfo]} {
        $pv_lines insert $line.end "  ([join $extraInfo {  }])" lmargin
    }

    $pv_lines configure -state disabled
    if {$line == 1 && ![::enginewin::stateLocked $id]} {
        if {$scoreside eq "engine" && $::enginewin::pv_(btm,$id) && $score ne ""} {
            set sign_reversed [expr { [string index $score 0] eq "+" ? "-" : "+" }]
            set score "$sign_reversed[string range $score 1 end]"
        }
        set best_move [string trimleft $pv ".0123456789"]
        if {$notation == 2 || $notation == -2} {
            set best_move [::trans $best_move]
        }
        ::notify::EngineBestMove $id $best_move $score
    }
}

# Invoked when the engine's name changes.
# Update the window's title and ::enginewin_lastengine accordingly.
proc ::enginewin::updateEngineName {id name} {
    set ::enginewin_lastengine($id) $name
    ::setTitle .engineWin$id "[tr Engine]: $name"
    event generate .engineWin$id.config.btn <<UpdateEngineName>> -data [list $name]
}

proc ::enginewin::updateOptions {id msgData} {
    set w .engineWin$id
    if {$msgData eq ""} {
        $w.btn.multipv set ""
        $w.btn.multipv configure -state disabled
        $w.btn.threads configure -state disabled -text "1 CPU"
        $w.btn.hash configure -state disabled -text "?? MB"
        return
    }
    lassign $msgData protocol netclients options
    for {set i 0} {$i < [llength $options]} {incr i} {
        lassign [lindex $options $i] name value type default min max var_list internal
        if {$internal || $type in [list button save reset]} { continue }

        if {[string equal -nocase $name "multipv"] && $min ne "" && $max ne ""} {
            $w.btn.multipv configure -state normal -from $min -to $max -style {}
            $w.btn.multipv set $value
        } elseif {[string equal -nocase $name "threads"]} {
            $w.btn.threads configure -state normal -text "$value CPU"
        } elseif {[string equal -nocase $name "hash"]} {
            $w.btn.hash configure -state normal -text "$value MB"
        }
    }
}

# Retrieve the moves at the line specified by index.
# An index linenumber.0 can be used to retrive just the first move.
# An index linenumber.end can be used to retrive all the moves.
# If index is not valid an exception is raised.
proc ::enginewin::getMoves {w index} {
    lassign [$w tag nextrange moves "$index linestart"] begin end
    if {[regexp {^\d+\.0$} $index]} {
        set end [$w search " " $begin]
    } elseif {![regexp {^\d+\.end$} $index]} {
        set end [$w search " " $index]
    }
    if {[$w tag nextrange translated $begin $end] eq ""} {
        set moves [$w get $begin $end]
    } else {
        set moves [::untrans [$w get $begin $end]]
    }
    return [string map {"\u2654" K "\u2655" Q "\u2656" R "\u2657" B "\u2658" N} $moves]
}

# Add the moves to the current game
# An index linenumber.0 can be used to add just the first move.
# An index linenumber.end can be used to add all the moves.
# Return false if index is not valid.
proc ::enginewin::exportMoves {w index} {
    if {[catch {::enginewin::getMoves $w $index} line]} {
        return false
    }
    ::undoFeature save
    catch {sc_game import $line}
    ::notify::PosChanged -pgn
    return true
}

# Add all the move lines to the current game.
proc ::enginewin::exportLines {w} {
    set i_line 1
    set location [sc_move pgn]
    while {![catch {::enginewin::getMoves $w $i_line.end} line]} {
        # When multipv is 1, the old lines are also shown, but do not export them
        lassign [$w tag nextrange header "$i_line.end linestart"] is_latest
        if {$is_latest eq ""} { break }
        if {$i_line == 1} { ::undoFeature save }
        catch {sc_game import $line}
        sc_move pgn $location
        incr i_line
    }
    ::notify::PosChanged pgnonly
}

# Sends a SetOptions message to the engine if an option's value is different.
proc ::enginewin::changeOption {id name widget_or_value} {
    set restart [expr {[::enginewin::stateFollow $id] || [::enginewin::stateLocked $id]}]
    if {$name eq "_go_limits"} {
        set ::enginewin::m_(limits,$id) $widget_or_value
        set changed true
    } else {
        set idx [::enginecfg::findOption $id $name]
        if {[winfo exists $widget_or_value]} {
            set changed [::enginecfg::setOptionFromWidget $id $idx $widget_or_value]
        } else {
            set changed [::enginecfg::setOption $id $idx $widget_or_value]
        }
    }
    if {$changed && $restart} {
        set ply [expr {[sc_var level] ? -1 : [sc_pos location]}]
        ::enginewin::sendPosition $id $::enginewin::m_(position,$id) $ply
    }
}

# Sets the current state of the engine and updates the relevant buttons.
# The first part is the USER-REQUESTED MODE:
#    - paused:   The engine is not analyzing
#    - follow:   The engine analyzes the current board position
#    - locked:   The engine remains fixed on a specific position
# The second part is the ENGINE STATUS:
#    - closed:   The engine process is not running (connection closed)
#    - deceased: The engine process terminated unexpectedly
#    - idle:     The engine is idle and waiting for a task
#    - done:     The engine has completed its assigned task (e.g., reached the depth/time limit).
#    - run:      The engine is currently analyzing
#
# | engState             | startStop | lock | addbestmove | addlines | limits |
# |----------------------|-----------|------|-------------|----------|--------|
# | paused.closed        | D         | D    | D           | D        | D      |
# | paused.deceased      | D         | D    | D           | D        | D      |
# | paused.idle          |           | D    |             |          |        |
# | follow.idle          | U         |      |             |          |        |
# | follow.done          | U         |      |             |          | P      |
# | follow.run           | P         |      |             |          |        |
# | follow.done.autorun  | P         |      |             | P        | P      |
# | follow.idle.autorun  | P         |      |             | P        |        |
# | locked.run           | P         | P    |             |          |        |
# | locked.idle          | U         | P    |             |          |        |
# | locked.done          | U         | P    |             |          | P      |
#
# newState can contain "*" as a placeholder for the old corresponding part.
proc ::enginewin::changeState {id newState} {
    # Handle pattern with * placeholder
    if {[string first * $newState] >= 0} {
        set newState [join [lmap new [split $newState .] old [split $::enginewin::engState($id) .] {
            set v [expr {$new eq "*" ? $old : $new}]
            expr {$v eq "" ? [continue] : $v}
        }] .]
    }

    if {$::enginewin::engState($id) eq $newState} { return }

    set buttons {
        btn.addbestmove {}
        btn.addlines    {}
        btn.autorun     {*autorun user1   * !user1}
        btn.limits      {*done* pressed   * !pressed}
        btn.lock        {l* pressed   * !pressed}
        btn.startStop   {p* {!pressed !user1}   *run {pressed !user1}   * {!pressed user1}}
    }
    set w .engineWin$id
    set closed [string match *sed $newState]
    foreach {btn btnspec} $buttons {
        if {$closed} {
            $w.$btn configure -state disabled
            $w.$btn state {!pressed !user1}
        } else {
            $w.$btn configure -state normal
            foreach {p s} $btnspec {
                if {[string match $p $newState]} {
                    $w.$btn state $s
                    break
                }
            }
        }
    }

    if {![string match f* $newState]} {
        if {[string match p* $newState]} {
            $w.btn.lock configure -state disabled
        }
        ::chart::moveCursorLine $w.chart.canvas ""
        ::notify::EngineBestMove $id "" ""
    } elseif {$::enginewin::engState($id) in {paused.idle paused.closed}} {
        ::enginewin::toggleConfigPane $id hide
    }
    set ::enginewin::engState($id) $newState
}

proc ::enginewin::stateFollow {id} {string match f* $::enginewin::engState($id)}
proc ::enginewin::stateLocked {id} {string match l* $::enginewin::engState($id)}
proc ::enginewin::statePaused {id} {string match paused.idle $::enginewin::engState($id)}

# If any, closes the connection with the current engine.
# If "config" is not "" opens a connection with a new engine.
proc ::enginewin::connectEngine {id enginename} {
    ::engine::close $id
    ::enginewin::updateDisplay $id ""
    ::enginewin::updateOptions $id ""
    ::enginewin::changeState $id paused.closed

    set ::enginewin::pv_(depths,$id) [dict create]
    set ::enginewin::pv_(pos,$id) ""
    set ::enginewin::pv_(limits,$id) ""
    set ::enginewin::pv_(btm,$id) 0
    set ::enginewin::pv_(ply,$id) ""
    set ::enginewin::pv_(postponed,$id) ""

    set config [::enginecfg::get $enginename]
    lassign $config name cmd args wdir elo time _ uci options
    ::enginewin::updateEngineName $id $name

    set configFrame .engineWin$id.config.options
    set netport [::enginecfg::resetConfigOptions $id $configFrame $config]

    if {$config eq ""} { return }

    update idletasks

    switch $uci {
      0 { set protocol "xboard" }
      1 { set protocol "uci" }
      2 { set protocol "network" }
      default { set protocol [list uci xboard] }
    }
    if {[catch {
        if {$wdir != "" && $wdir != "."} {
            set oldwdir [pwd]
            cd $wdir
        }
        ::engine::connect $id [list ::enginewin::callback $id] $cmd $args $protocol
        if {[info exists oldwdir]} {
            cd $oldwdir
        }
    } errorMsg]} {
        return [::enginewin::callback $id [list InfoDisconnected [list $errorMsg]]]
    }

    if {[catch { ::enginecfg::setupNetd $id $netport }]} {
        ERROR::MessageBox
    }

    if {[llength $options]} {
        ::engine::send $id SetOptions $options
    }
    # Send a NewGame message to receive InfoReady when the engine completes the initialization.
    ::engine::send $id NewGame [list {}]
    # But also schedule a NewGame message, that depends on the position, when the engine starts.
    set ::enginewin::m_(newgame,$id) true
}

# Receive the engine's messages
proc ::enginewin::callback {id msg} {
    variable pv_
    set configFrame .engineWin$id.config.options
    lassign $msg msgType msgData
    switch $msgType {
        "InfoConfig" {
            ::enginewin::updateOptions $id $msgData
            set renamed [::enginecfg::updateConfigOptions $id $configFrame $msgData]
            if {$renamed ne ""} {
                ::enginewin::updateEngineName $id $renamed
            }
            ::enginewin::changeState $id *.idle
        }
        "InfoGo" {
            lassign $msgData pv_(pos,$id) pv_(limits,$id)
            lassign [blackToMove $pv_(pos,$id)] pv_(btm,$id) n_ply
            if {$::enginewin::m_(posPly,$id) ne "" && $pv_(pos,$id) eq $::enginewin::m_(position,$id)} {
                set pv_(ply,$id) $::enginewin::m_(posPly,$id)
                if {$pv_(ply,$id) < 0} { set pv_(ply,$id) "" }
                set ::enginewin::m_(posPly,$id) ""
                ::enginewin::changeState $id *.run
                ::chart::moveCursorLine .engineWin$id.chart.canvas $pv_(ply,$id)
            } else {
                ::enginewin::changeState $id *.*.autorun
                set pv_(ply,$id) [inMainLine $::enginewin::m_(mainLine,$id) $pv_(pos,$id) $n_ply]
            }
        }
        "InfoPV" {
            if {$pv_(pos,$id) eq $::enginewin::m_(position,$id)} {
                ::enginewin::updateDisplay $id $msgData
            }
            ::enginewin::updateChart $id $msgData
        }
        "InfoBestMove" {
            if {$pv_(limits,$id) eq $::enginewin_limits($id)
                && $pv_(pos,$id) eq $::enginewin::m_(position,$id)} {
                ::enginewin::changeState $id *.done
            }
            if {![::enginewin::analyzeMainLine $id]} {
                ::enginewin::changeState $id *.*
                if {$pv_(postponed,$id) ne ""} {
                    ::enginewin::sendPosition $id $::enginewin::m_(position,$id) $pv_(postponed,$id)
                }
            }
        }
        "InfoReady" {
            ::enginecfg::autoSaveConfig $id $configFrame true
            ::enginewin::changeState $id *.idle
        }
        "InfoDisconnected" {
            ::enginewin::updateOptions $id ""
            ::enginecfg::autoSaveConfig $id $configFrame false
            ::enginecfg::updateConfigOptions $id $configFrame {}
            ::enginewin::changeState $id paused.deceased
            lassign $msgData errorMsg
            if {$errorMsg eq ""} {
                set errorMsg "The connection with the engine terminated unexpectedly."
            }
            tk_messageBox -icon warning -type ok -parent . -message $errorMsg
        }
    }
}

# Sends a position to an engine.
# When the engine replies with an InfoGo message the state will change to "run".
proc ::enginewin::sendPosition {id position plyInMainLine} {
    variable m_
    set ::enginewin::pv_(postponed,$id) ""
    ::enginewin::updateDisplay $id ""
    if {$m_(newgame,$id)} {
        set m_(newgame,$id) false
        ::engine::send $id NewGame [list analysis post_pv post_wdl [sc_game variant]]
        set m_(mainLine,$id) [sc_game UCI_mainLine]
        ::chart::clear .engineWin$id.chart.canvas [expr {[llength $m_(mainLine,$id)] - 1}]
        set ::enginewin::pv_(depths,$id) [dict create]
        set ::enginewin::pv_(postponed,$id) $plyInMainLine
    }
    set m_(position,$id) $position
    set m_(posPly,$id) ""
    if {$::enginewin::pv_(postponed,$id) eq "" || ![analyzeMainLine $id]} {
        set ::enginewin::pv_(postponed,$id) ""
        set m_(posPly,$id) $plyInMainLine
        ::engine::send $id Go [list $position $m_(limits,$id)]
    }
}

# Searches for unevaluated positions in the main line.
# Returns 0 if all positions have been evaluated, otherwise, returns 1 and
# starts analyzing the last unevaluated position.
proc ::enginewin::analyzeMainLine {id} {
    if {[lindex $::enginewin_autorun($id) 0] eq ""
        || [::enginewin::stateLocked $id]} { return 0 }

    upvar ::enginewin::pv_(depths,$id) depths
    set i [llength $::enginewin::m_(mainLine,$id)]
    while {[incr i -1] >= 0} {
        if {![dict exists $depths $i] && $i ne $::enginewin::pv_(postponed,$id)} {
            dict set depths $i 0
            set uci_pos [join [lrange $::enginewin::m_(mainLine,$id) 0 $i]]
            set uci_pos [string range $uci_pos [string last "position" $uci_pos] end]
            ::engine::send $id Go [list $uci_pos $::enginewin_autorun($id)]
            return 1
        }
    }
    return 0
}
