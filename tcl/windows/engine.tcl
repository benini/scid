########################################################################
# Copyright (C) 2020-2023 Fulvio Benini
#
# This file is part of Scid (Shane's Chess Information Database).
# Scid is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.

### Window for chess engine configuration and position analysis

namespace eval enginewin {}
array set ::enginewin::engState {} ; # closed disconnected idle run locked

# Return a list contatining the engine's ID, engine's name and true if it is running.
# Return only the engines in idle or run state.
proc ::enginewin::listEngines {} {
    set result {}
    foreach {id state} [array get ::enginewin::engState] {
        if {$state ni {idle run}} { continue }
        lassign [set ::enginewin::engConfig_$id] name
        lappend result [list $id $name [expr { $state eq "run" ? 1 : 0 }] ]
    }
    return $result
}

# Sends the updated position to the active engines
proc ::enginewin::onPosChanged { {ids ""} {newgame ""}} {
    if {$newgame ne ""} {
        ::enginewin::newGame $ids
    }
    set position ""
    foreach {id state} [array get ::enginewin::engState] {
        if {$state ne "run"} { continue }
        if {$ids ne "" && $id ni $ids} { continue }
        if {$position eq ""} {
            set position [sc_game UCI_currentPos]
        }
        ::enginewin::sendPosition $id $position
    }
}

# Sends a position to an engine.
# When the engine replies with an InfoGo message the state will change to "run".
proc ::enginewin::sendPosition {id position} {
    ::enginewin::updateDisplay $id ""
    if {[set ::enginewin::newgame_$id]} {
        set ::enginewin::newgame_$id false
        ::engine::send $id NewGame [list analysis post_pv post_wdl [sc_game variant]]
    }
    ::engine::send $id Go [list $position]
}

# Start an engine (if necessary it will opens a new enginewin window).
# Return the engine's id.
proc ::enginewin::start { {id ""} {enginename ""} } {
    if {$id eq "" || ![winfo exists .engineWin$id]} {
        set id [::enginewin::Open $id $enginename]
    }
    if {$::enginewin::engState($id) eq "idle"} {
        ::enginewin::sendPosition $id [sc_game UCI_currentPos]
    }
    return $id
}

# Stop the engine.
# Return true if a StopGo message was sent to the engine.
proc ::enginewin::stop {id} {
    if {[winfo exists .engineWin$id] && $::enginewin::engState($id) in "run locked"} {
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

# Invoke ::enginecfg::changeOption and restart the engine if it was running
proc ::enginewin::changeOption {id name widget} {
    set prev_state $::enginewin::engState($id)
    if {[::enginecfg::changeOption $id multipv $widget] && $prev_state in {run}} {
        ::enginewin::sendPosition $id [set ::enginewin::position_$id]
    }
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

    # The main windows is divided in three parts:
    # - at the top $w.header_info which shows time, nps, etc...
    # - at the bottom the buttons bar
    # - in the middle $w.main which is further divided in three parts:
    #   - top-left: $w.display where the pv lines are shown
    #   - bottom-left: $w.debug where all the engine's i/o is shown
    #   - right: $w.config with all the engine options.
    # $w.debug can be hidden and $w.display would expand downward.
    # $w.config can be hidden and $w.display and eventually $w.debug would expand rightward.

    ttk::frame $w.header_info
    ttk_text $w.header_info.text -style Toolbutton -wrap word -height 1 -pady 2
    autoscrollBars y $w.header_info $w.header_info.text

    ttk::frame $w.main
    ttk::panedwindow $w.pane
    ttk::frame $w.config
    ::enginecfg::createConfigFrame $id $w.config
    ttk::frame $w.display
    ::enginewin::createDisplayFrame $id $w.display
    $w.pane add $w.display -weight 1
    ttk::frame $w.debug
    ttk_text $w.debug.lines -state disabled
    autoscrollBars y $w.debug $w.debug.lines
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

    # The engine should be closed before the debug .text is destroyed
    bind $w.config <Destroy> "
        unset ::enginewin::engState($id)
        ::engine::close $id
        ::enginecfg::save \[ set ::enginewin::engConfig_$id \]
        unset ::enginewin::engConfig_$id
        unset ::enginewin::position_$id
        unset ::enginewin::newgame_$id
        unset ::enginewin::startTime_$id
        ::notify::EngineBestMove $id {} {}
    "

    options.persistent ::enginewin_lastengine($id) ""
    set ::enginewin::engState($id) {}
    set ::enginewin::engConfig_$id {}
    set ::enginewin::position_$id ""
    set ::enginewin::newgame_$id true
    set ::enginewin::startTime_$id [clock milliseconds]

    if {$enginename eq ""} {
        set enginename $::enginewin_lastengine($id)
    }
    catch { ::enginewin::connectEngine $id $enginename }
    return $id
}

# Creates $w.display, where the pv lines sent by the engine would be shown.
proc ::enginewin::createDisplayFrame {id display} {
    ttk_text $display.pv_lines -exportselection true -padx 4 -state disabled
    autoscrollBars both $display $display.pv_lines
    set tab [font measure font_Regular "xxxxxxx"]
    $display.pv_lines configure -tabs [list [expr {$tab * 2}] right [expr {int($tab * 2.2)}]]
    $display.pv_lines tag configure lmargin -lmargin2 [expr {$tab * 3}]
    $display.pv_lines tag configure markmove -underline 1
    $display.pv_lines tag bind moves <ButtonRelease-1> {
        if {[%W tag ranges sel] eq ""} {
            ::enginewin::exportMoves %W @%x,%y
        }
    }
    $display.pv_lines tag bind moves <Motion> [list apply {{id} {
        %W tag remove markmove 1.0 end
        if {[%W tag ranges sel] eq "" && ![catch {
                # An exception will be thrown if the engine sent an illegal pv
                sc_pos board [set ::enginewin::position_$id] [::enginewin::getMoves %W @%x,%y] } pos]} {
            # TODO:
            # Using wordstart and wordend would be a lot more efficient.
            # However they do not consider the [+.-] chars as part of the word.
            # set movestart [%W index "@%x,%y wordstart"]
            # %W tag add markmove $movestart "$movestart wordend"
            set movestart "[%W search -backwards -regexp {\s} "@%x,%y"] +1chars"
            %W tag add markmove $movestart [%W search " " $movestart]
            ::board::popup .enginewinBoard $pos %X %Y
        } else {
            catch { wm withdraw .enginewinBoard }
        }
    }} $id]
    $display.pv_lines tag bind moves <Any-Leave> {
        %W tag remove markmove 1.0 end
        catch { wm withdraw .enginewinBoard }
    }
}

# Creates the buttons bar
proc ::enginewin::createButtonsBar {id btn display} {
    ttk::button $btn.startStop -image [list tb_eng_on pressed tb_eng_off] -style Toolbutton \
        -command "::enginewin::toggleStartStop $id"
    #TODO: change the tooltip to "Start/stop engine"
    ::utils::tooltip::Set $btn.startStop [tr StartEngine]
    ttk::button $btn.lock -image tb_eng_lock -style Toolbutton -command "
        if {\$::enginewin::engState($id) eq {locked}} {
            ::enginewin::changeState $id run
            ::enginewin::onPosChanged $id
        } else {
            ::enginewin::changeState $id locked
        }
    "
    bind $btn.lock <Any-Enter> [list apply {{id} {
        if {"pressed" in [%W state]} {
            ::board::popup .enginewinBoard [sc_pos board [set ::enginewin::position_$id] ""] %X %Y above
        }
    }} $id]
    bind $btn.lock <Any-Leave> {
        catch { wm withdraw .enginewinBoard }
    }
    ::utils::tooltip::Set $btn.lock [tr LockEngine]
    ttk::button $btn.addbestmove -image tb_eng_addbestmove -style Toolbutton \
        -command "::enginewin::exportMoves $display.pv_lines 1.0"
    ::utils::tooltip::Set $btn.addbestmove [tr AddMove]
    ttk::button $btn.addbestline -image tb_eng_addbestline -style Toolbutton \
        -command "::enginewin::exportMoves $display.pv_lines 1.end"
    ::utils::tooltip::Set $btn.addbestline [tr AddVariation]
    ttk::button $btn.addlines -image tb_eng_addlines -style Toolbutton \
        -command "::enginewin::exportLines $display.pv_lines"
    ::utils::tooltip::Set $btn.addlines [tr AddAllVariations]
    ttk::spinbox $btn.multipv -increment 1 -width 4 -state disabled \
        -validate key -validatecommand { string is integer %P } \
        -command "after idle \[bind $btn.multipv <FocusOut>\]"
    bind $btn.multipv <Return> { {*}[bind %W <FocusOut>] }
    bind $btn.multipv <FocusOut> "::enginewin::changeOption $id multipv $btn.multipv"
    ::utils::tooltip::Set $btn.multipv [tr Lines]
    ttk::button $btn.config -image tb_eng_config -style Toolbutton \
        -command "::enginewin::changeState $id toggleConfig"
    $btn.config state pressed
    grid $btn.startStop $btn.lock $btn.addbestmove $btn.addbestline \
         $btn.addlines $btn.multipv x $btn.config -sticky ew
    grid columnconfigure $btn 6 -weight 1
}

# Inform the engine that there is a new game
proc ::enginewin::newGame { {ids ""} } {
    foreach {id state} [array get ::enginewin::engState] {
        if {$ids ne "" && $id ni $ids} { continue }
        set ::enginewin::newgame_$id true
    }
}

# Sets the current state of the engine and updates the relevant buttons.
# The states are:
# closed -> No engine is open.
# disconnected -> The engine was open but the connection was terminated.
# idle -> The engine is open and ready.
# run -> The engine is analyzing the current position.
# locked -> The engine is analyzing a fixed position.
proc ::enginewin::changeState {id newState} {
    set w .engineWin$id
    if {$newState eq "toggleConfig"} {
        if {[grid info $w.config] ne ""} {
            $w.btn.config state !pressed
            grid remove $w.config
        } else {
            $w.btn.config state pressed
            grid $w.config
        }
        return
    }

    if {$::enginewin::engState($id) eq $newState} { return }

    # Hide the config frame
    if {$newState eq "run"} {
        $w.btn.config state !pressed
        grid remove $w.config
    }

    lappend btnDisabledStates [list config.header.reload closed]
    lappend btnDisabledStates [list config.header.clone closed]
    lappend btnDisabledStates [list config.header.delete closed]
    # Buttons that add moves are not disabled when the engine is locked.
    # This allow the user to later add the lines. And if the board position
    # will be different, only the valid moves will be added to the game.
    lappend btnDisabledStates [list btn.addbestmove [list closed disconnected]]
    lappend btnDisabledStates [list btn.addbestline [list closed disconnected]]
    lappend btnDisabledStates [list btn.addlines [list closed disconnected]]
    lappend btnDisabledStates [list btn.startStop [list closed disconnected] [list locked run]]
    lappend btnDisabledStates [list btn.lock [list closed disconnected idle] locked]
    foreach {elem} $btnDisabledStates {
        lassign $elem btn states pressed
        if {$newState in $states} {
            $w.$btn configure -state disabled
        } else {
            $w.$btn configure -state normal
        }
        if {$newState in $pressed} {
            $w.$btn state pressed
        } else {
            $w.$btn state !pressed
        }
    }
    set ::enginewin::engState($id) $newState

    if {$newState in {closed disconnected idle locked}} {
        ::notify::EngineBestMove $id "" ""
    }
}

proc ::enginewin::logEngine {id on} {
    catch { .engineWin$id.pane forget .engineWin$id.debug }
    .engineWin$id.debug.lines configure -state normal
    .engineWin$id.debug.lines delete 1.0 end
    .engineWin$id.debug.lines configure -state disabled
    if {$on} {
        .engineWin$id.pane add .engineWin$id.debug -weight 1
        ::engine::setLogCmd $id \
            [list ::enginewin::logHandler $id .engineWin$id.debug.lines "" ""]\
            [list ::enginewin::logHandler $id .engineWin$id.debug.lines header ">>"]
    } else {
        ::engine::setLogCmd $id "" ""
    }
    lset ::enginewin::engConfig_$id 6 3 $on
}

proc ::enginewin::logHandler {id widget tag prefix msg} {
    upvar ::enginewin::startTime_$id startTime_
    set t [format "(%.3f) " \
        [expr {( [clock milliseconds] - $startTime_ ) / 1000.0}]]
    $widget configure -state normal
    $widget insert end "$t[set prefix]$msg\n" $tag
    $widget see end
    $widget configure -state disabled
}

# If any, closes the connection with the current engine.
# If "config" is not "" opens a connection with a new engine.
proc ::enginewin::connectEngine {id enginename} {
    upvar ::enginewin::engConfig_$id engConfig_
    ::enginecfg::save $engConfig_

    set config [::enginecfg::get $enginename]

    ::engine::close $id
    ::enginewin::changeState $id closed

    lassign $config name cmd args wdir elo time url uci options
    set engConfig_ [list $name $cmd $args $wdir $elo $time $url $uci {}]
    # Update engine's last used time.
    lset engConfig_ 5 [clock seconds]

    set ::enginewin_lastengine($id) $name

    ::enginecfg::clearConfigFrame $id .engineWin$id.config

    ::enginewin::updateDisplay $id ""

    if {$config eq ""} {
        ::setTitle .engineWin$id "Engine Window"
        ::enginewin::logEngine $id false
        return
    }

    ::setTitle .engineWin$id "[tr Engine]: $name"

    lassign $url scoreside notation pvwrap debugframe priority netport
    ::enginewin::changeDisplayLayout $id scoreside $scoreside
    ::enginewin::changeDisplayLayout $id notation $notation
    ::enginewin::changeDisplayLayout $id wrap $pvwrap
    ::enginewin::updateOptions $id ""
    ::enginewin::logEngine $id $debugframe

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
    ::enginewin::changeState $id idle
    ::enginewin::newGame $id
}

proc ::enginewin::callback {id msg} {
    lassign $msg msgType msgData
    switch $msgType {
        "InfoConfig" {
            ::enginewin::updateOptions $id $msgData
            set renamed [::enginecfg::updateConfigFrame $id .engineWin$id.config $msgData]
            if {$renamed ne ""} {
                set ::enginewin_lastengine($id) $renamed
                ::setTitle .engineWin$id "[tr Engine]: $renamed"
            }
            ::enginewin::changeState $id idle
        }
        "InfoGo" {
            lassign $msgData ::enginewin::position_$id
            ::enginewin::changeState $id run
        }
        "InfoPV" {
            ::enginewin::updateDisplay $id $msgData
        }
        "InfoReady" {
            ::enginewin::changeState $id idle
        }
        "InfoDisconnected" {
            lassign $msgData errorMsg
            if {$errorMsg eq ""} {
                set errorMsg "The connection with the engine terminated unexpectedly."
            }
            tk_messageBox -icon warning -type ok -parent . -message $errorMsg
            ::enginecfg::updateConfigFrame $id .engineWin$id.config {}
            ::enginewin::changeState $id disconnected
        }
    }
}

proc ::enginewin::changeDisplayLayout {id param value} {
    upvar ::enginewin::engConfig_$id engConfig_
    set w .engineWin$id
    switch $param {
        "scoreside" {
            set idx 0
        }
        "notation" {
            set idx 1
            if {$value < 0} {
                set value [expr { 0 - $value }]
            }
            # If it is an xboard engine with san=1 store it as a negative value
            foreach elem [lsearch -all -inline -index 0 [lindex $engConfig_ 8] "san"] {
                if {[lindex $elem 7]} {
                    set value [expr { 0 - $value }]
                    break
                }
            }
        }
        "wrap" {
            set idx 2
            $w.display.pv_lines configure -wrap $value
        }
        default { error "changeDisplayLayout unknown $param" }
    }
    lset engConfig_ 6 $idx $value
}

proc ::enginewin::updateOptions {id msgData} {
    set w .engineWin$id
    if {$msgData eq ""} {
        $w.btn.multipv set ""
        $w.btn.multipv configure -state disabled
        return
    }
    lassign $msgData protocol netclients options
    for {set i 0} {$i < [llength $options]} {incr i} {
        lassign [lindex $options $i] name value type default min max var_list internal
        if {$internal || $type in [list button save reset]} { continue }

        if {[string equal -nocase $name "multipv"] && $min ne "" && $max ne ""} {
            $w.btn.multipv configure -state normal -from $min -to $max -style {}
            $w.btn.multipv set $value
        }
    }
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

    set w .engineWin$id.display
    $w.pv_lines configure -state normal
    if {$msgData eq ""} {
        $w.pv_lines delete 1.0 end
        $w.pv_lines configure -state disabled
        return
    }

    lassign [lindex [set ::enginewin::engConfig_$id] 6] scoreside notation
    if {[catch {

    if {$notation > 0} {
        set pv [sc_pos coordToSAN [set ::enginewin::position_$id] $pv]
    }
    if {$notation == 1 || $notation == -1} {
        set pv [::trans $pv]
    } elseif {$notation == 3 || $notation == -3} {
        # Figurine
        set pv [string map {K "\u2654" Q "\u2655" R "\u2656" B "\u2657" N "\u2658"} $pv]
    }

    }]} {
        set pv "illegal_pv! $pv"
    }

    if {$score ne ""} {
        if {$scoreside eq "white" && [sc_pos side] eq "black"} {
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
        lappend extraInfo [format "w%.1f%%" [expr {$win / 10.0}]]
        lappend extraInfo [format "d%.1f%%" [expr {$draw / 10.0}]]
        lappend extraInfo [format "l%.1f%%" [expr {$lose / 10.0}]]
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
        $w.pv_lines tag remove header 1.0 1.end
    }
    # If the engine has repeatedly sent multipv 1, do not delete the obsolete lines
    catch { $w.pv_lines tag nextrange header 2.0 } multilines
    if {$line > 1 || $multilines ne ""} {
        # Multipv lines >= than the current one are now obsolete and deleted.
        $w.pv_lines delete $line.0 end
    }
    $w.pv_lines insert $line.0 "\n"
    $w.pv_lines insert $line.end "$depth\t"
    $w.pv_lines insert $line.end "$score" header
    $w.pv_lines insert $line.end "\t"
    $w.pv_lines insert $line.end "$pv" [list header moves]
    $w.pv_lines insert $line.end "$pvline" [list lmargin moves]
    if {[info exists extraInfo]} {
        $w.pv_lines insert $line.end "  ([join $extraInfo {  }])" lmargin
    }

    $w.pv_lines configure -state disabled
    if {$line == 1 && $::enginewin::engState($id) ne "locked"} {
        if {$scoreside eq "engine" && [sc_pos side] eq "black" && $score ne ""} {
            set sign_reversed [expr { [string index $score 0] eq "+" ? "-" : "+" }]
            set score "$sign_reversed[string range $score 1 end]"
        }
        if {$notation == 2 || $notation == -2} {
            set best_move [::trans $pv]
        } else {
            set best_move $pv
        }
        ::notify::EngineBestMove $id $best_move $score
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
    set moves [::untrans [$w get $begin $end]]
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
    sc_game import $line
    ::notify::GameChanged
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
        sc_game import $line
        sc_move pgn $location
        incr i_line
    }
    ::notify::GameChanged
}
