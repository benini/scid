########################################################################
# Copyright (C) 2020-2022 Fulvio Benini
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

    grid [ttk::panedwindow $w.pane] -sticky news
    grid columnconfigure $w 0 -weight 1
    grid rowconfigure $w 0 -weight 1
    ttk::frame $w.main
    grid columnconfigure $w.main 0 -weight 1
    grid rowconfigure $w.main 0 -weight 1
    $w.pane add $w.main -weight 1

    ttk::frame $w.config
    ::enginecfg::createConfigFrame $id $w.config
    ttk::frame $w.display
    ::enginewin::createDisplayFrame $id $w.display
    autoscrollText y $w.debug $w.debug.lines Treeview
    $w.debug.lines configure -state normal

    grid $w.config -in $w.main -sticky news

    ttk::frame $w.btn
    ttk::button $w.btn.startStop -image [list tb_eng_on pressed tb_eng_off] -style Toolbutton \
        -command "::enginewin::toggleStartStop $id"
    #TODO: change the tooltip to "Start/stop engine"
    ::utils::tooltip::Set $w.btn.startStop [tr StartEngine]
    ttk::button $w.btn.lock -image tb_eng_lock -style Toolbutton -command "
        if {\$::enginewin::engState($id) eq {locked}} {
            ::enginewin::changeState $id run
            ::enginewin::onPosChanged $id
        } else {
            ::enginewin::changeState $id locked
        }
    "
    bind $w.btn.lock <Any-Enter> [list apply {{id} {
        if {"pressed" in [%W state]} {
            ::board::popup .enginewinBoard [sc_pos board [set ::enginewin::position_$id] ""] %X %Y above
        }
    }} $id]
    bind $w.btn.lock <Any-Leave> {
        catch { wm withdraw .enginewinBoard }
    }
    ::utils::tooltip::Set $w.btn.lock [tr LockEngine]
    ttk::button $w.btn.addbestmove -image tb_eng_addbestmove -style Toolbutton \
        -command "::enginewin::exportMoves $w.display.pv.lines 1.0"
    ::utils::tooltip::Set $w.btn.addbestmove [tr AddMove]
    ttk::button $w.btn.addbestline -image tb_eng_addbestline -style Toolbutton \
        -command "::enginewin::exportMoves $w.display.pv.lines 1.end"
    ::utils::tooltip::Set $w.btn.addbestline [tr AddVariation]
    ttk::button $w.btn.addlines -image tb_eng_addlines -style Toolbutton \
        -command "::enginewin::exportLines $w.display.pv.lines"
    ::utils::tooltip::Set $w.btn.addlines [tr AddAllVariations]
    ttk::spinbox $w.btn.multipv -increment 1 -width 4
    ::utils::tooltip::Set $w.btn.multipv [tr Lines]
    ttk::button $w.btn.config -image tb_eng_config -style Toolbutton \
        -command "::enginewin::changeState $id toggleConfig"
    $w.btn.config state pressed
    grid $w.btn.startStop $w.btn.lock $w.btn.addbestmove $w.btn.addbestline \
         $w.btn.addlines $w.btn.multipv x $w.btn.config -sticky ew
    grid columnconfigure $w.btn 6 -weight 1

    grid $w.btn -sticky news

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
    set engineConfig [::enginecfg::get $enginename]
    catch { ::enginewin::connectEngine $id $engineConfig }
    return $id
}

proc ::enginewin::updateName {id} {
    lassign [set ::enginewin::engConfig_$id] name
    set ::enginewin_lastengine($id) $name
    set w .engineWin$id
    if {$name == ""} {
        ::setTitle .engineWin$id "Engine Window"
        $w.config.header.engine set "[tr Engine]:"
        $w.config.options.text configure -state normal
        $w.config.options.text delete 1.0 end
        $w.config.options.text insert end "No engine open: select or add one."
        $w.config.options.text configure -state disabled
        $w.debug.lines delete 1.0 end
    } else {
        ::setTitle .engineWin$id "[tr Engine]: $name"
        $w.config.header.engine set "$name"
    }
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
    if {$newState in "run toggleConfig"} {
        if {[grid info $w.config] ne ""} {
            $w.btn.config state !pressed
            grid forget $w.config
            grid $w.display -in $w.main -sticky news
        } elseif {$newState eq "toggleConfig"} {
            $w.btn.config state pressed
            grid forget $w.display
            grid $w.config -in $w.main -sticky news
        }
        if {$newState eq "toggleConfig"} { return }
    }

    if {$::enginewin::engState($id) eq $newState} { return }

    lappend btnDisabledStates [list config.header.reload closed]
    lappend btnDisabledStates [list config.header.clone closed]
    lappend btnDisabledStates [list config.header.delete closed]
    # Buttons that add moves are not disabled when the engine is locked.
    # This allow the user to later add the lines. And if the board position
    # will be different, only the valid moves will be added to the game.
    lappend btnDisabledStates [list btn.addbestmove [list closed disconnected]]
    lappend btnDisabledStates [list btn.addbestline [list closed disconnected]]
    lappend btnDisabledStates [list btn.addlines [list closed disconnected]]
    lappend btnDisabledStates [list btn.multipv [list closed disconnected locked]]
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
    if {$on} {
        .engineWin$id.pane forget .engineWin$id.main
        .engineWin$id.pane add .engineWin$id.main -weight 1
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
    $widget insert end "$t[set prefix]$msg\n" $tag
    $widget see end
}

# If any, closes the connection with the current engine.
# If "config" is not "" opens a connection with a new engine.
proc ::enginewin::connectEngine {id config} {
    upvar ::enginewin::engConfig_$id engConfig_
    ::enginecfg::save $engConfig_

    ::engine::close $id
    ::enginewin::changeState $id closed

    lassign $config name cmd args wdir elo time url uci options
    if {[llength $url] != 6} {
        set url [list white 1 word false normal ""]
    }
    lassign $url scoreside notation pvwrap debugframe priority netport
    set engConfig_ [list $name $cmd $args $wdir $elo $time $url $uci {}]

    ::enginewin::updateName $id
    ::enginewin::updateDisplay $id ""

    if {$config eq ""} {
        return
    }

    # Update engine's last used time.
    lset ::enginewin::engConfig_$id 5 [clock seconds]

    ::enginewin::changeDisplayLayout $id scoreside $scoreside
    ::enginewin::changeDisplayLayout $id notation $notation
    ::enginewin::changeDisplayLayout $id wrap $pvwrap
    ::enginewin::changeDisplayLayout $id multipv ""
    ::enginewin::logEngine $id $debugframe

    .engineWin$id.config.options.text configure -state normal
    .engineWin$id.config.options.text delete 1.0 end
    .engineWin$id.config.options.text insert end "$cmd $args\nConnecting..."
    .engineWin$id.config.options.text configure -state disabled
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
        tk_messageBox -icon warning -type ok -parent . -message $errorMsg
        ::enginewin::updateConfig $id {}
        ::enginewin::changeState $id disconnected
        return
    }

    if {[catch {
        if {[string match "auto_*" $netport]} {
            lset engConfig_ 6 5 "auto_[::engine::netserver $id 0]"
        } else {
            lset engConfig_ 6 5 [::engine::netserver $id $netport]
        }
    }]} {
        ERROR::MessageBox
    }

    if {[llength $options]} {
        ::engine::send $id SetOptions $options
    }
    ::enginewin::changeState $id idle
    ::enginewin::newGame $id
}

# Checks whether the specified connection parameter has been changed, and
# if necessary reconnects the current engine using the new parameters.
proc ::enginewin::reconnect {id connectParam newValue {opendlg 0}} {
    switch $connectParam {
        "cmd"      { set configIdx 1 }
        "args"     { set configIdx 2 }
        "wdir"     { set configIdx 3 }
        "protocol" { set configIdx 7 }
        "options"  { set configIdx 8 }
        default { error "wrong option" }
    }
    upvar ::enginewin::engConfig_$id engConfig_
    set oldValue [lindex $engConfig_ $configIdx]
    if {$opendlg} {
        set dlgcmd [expr { $opendlg == 1 ? "tk_getOpenFile" : "tk_chooseDirectory" }]
        set newValue [$dlgcmd -initialdir [file dirname $oldValue]]
        if {$newValue == ""} {
            return
        }
    }
    if {$newValue ne $oldValue} {
        lset engConfig_ $configIdx $newValue
        ::enginewin::connectEngine $id [::enginecfg::save $engConfig_]
    }
}

proc ::enginewin::callback {id msg} {
    lassign $msg msgType msgData
    switch $msgType {
        "InfoConfig" {
            ::enginewin::updateConfig $id $msgData
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
            tk_messageBox -message "The connection with the engine terminated unexpectedly."
            ::enginewin::updateConfig $id {}
            ::enginewin::changeState $id disconnected
        }
    }
}

proc ::enginewin::createConfigWidgets {id options} {
    set w .engineWin$id.config.options.text

    $w configure -tabs [font measure font_Regular "Accept Network Connections:XXXXX"]

    $w insert end "Engine name:\t"
    ttk::entry $w.name
    $w window create end -window $w.name

    $w insert end "\n[tr EngineCmd]:\t"
    ttk::entry $w.cmd
    bind $w.cmd <FocusOut> "::enginewin::reconnect $id cmd \[ %W get \]"
    $w window create end -window $w.cmd
    ttk::button $w.cmdbtn -style Pad0.Small.TButton -text ... \
        -command "::enginewin::reconnect $id cmd {} 1"
    $w window create end -window $w.cmdbtn

    $w insert end "\n[tr EngineArgs]:\t"
    ttk::entry $w.args
    bind $w.args <FocusOut> "::enginewin::reconnect $id args \[ %W get \]"
    $w window create end -window $w.args

    $w insert end "\n[tr EngineDir]:\t"
    ttk::entry $w.wdir
    bind $w.wdir <FocusOut> "::enginewin::reconnect $id wdir \[ %W get \]"
    $w window create end -window $w.wdir
    ttk::button $w.wdirbtn -style Pad0.Small.TButton -text ... \
        -command "::enginewin::reconnect $id wdir {} 2"
    $w window create end -window $w.wdirbtn

    $w insert end "\nProtocol:\t"
    ttk::combobox $w.protocol -width 12 -values {xboard uci}
    bind $w.protocol <<ComboboxSelected>> "::enginewin::reconnect $id protocol \[ %W current \]"
    $w window create end -window $w.protocol

    foreach {layout op label values} [list \
        scoreside get "Score perspective" [list engine white] \
        notation current "Move lines notation" [list engine SAN "English SAN" figurine] \
        wrap get "Wrap move lines" [list word char none]
    ] {
        $w insert end "\n$label:\t"
        ttk::combobox $w.$layout -state readonly -width 12 -values $values
        bind $w.$layout <<ComboboxSelected>> "
            ::enginewin::changeDisplayLayout $id $layout \[ $w.$layout $op \]
        "
        $w window create end -window $w.$layout
    }

     $w insert end "\nShow debug frame:\t"
     ttk::combobox $w.debug -state readonly -width 12 -values [list false true]
     bind $w.debug <<ComboboxSelected>> "
         ::enginewin::logEngine $id \[ $w.debug get \]
     "
     $w window create end -window $w.debug

    if {[catch {::engine::pid $id} enginePid]} {
        return
    }
    if {$enginePid != ""} {
        $w insert end "\nEngine process priority:\t"
        ttk::combobox $w.priority -state readonly -width 12 -values {normal idle}
        bind $w.priority <<ComboboxSelected>> "
            catch { sc_info priority $enginePid \[ $w.priority get \] }
            lset ::enginewin::engConfig_$id 6 4 \[ $w.priority get \]
        "
        $w window create end -window $w.priority
        $w insert end "  pid: $enginePid"
    }


    $w insert end "\nAccept network connections:\t"
    ttk::combobox $w.netd -state readonly -width 12 -values {off on auto_port}
    $w window create end -window $w.netd
    $w insert end "  port: "
    ttk::entry $w.netport -width 6 -validate key -validatecommand { string is integer %P }
    $w window create end -window $w.netport
    bind $w.netd <<ComboboxSelected>> "::enginewin::updateConfigNetd $id $w"
    $w insert end "\n" netclients

    set disableReset 1
    for {set i 0} {$i < [llength $options]} {incr i} {
        lassign [lindex $options $i] name value type default min max var_list internal
        if {$internal} { continue }

        if {$disableReset} {
            set disableReset 0
            $w insert end "\n"
            ttk::button $w.reset -style Pad0.Small.TButton -text "Reset Options" \
                -command "::enginewin::updateConfigReset $id"
            $w window create end -window $w.reset
        }
        $w insert end "\n$name\t"
        set btn ""
        if {$type eq "button" || $type eq "save" || $type eq "reset"} {
            set btn $name
        } else {
            if {$type eq "spin" || $type eq "slider"} {
                ttk::spinbox $w.value$i -width 12 -from $min -to $max -increment 1
            } elseif {$type eq "combo"} {
                lassign [lsort -decreasing -integer [lmap elem $var_list { string length $elem }]] maxlen
                ttk::combobox $w.value$i -width [incr maxlen] -values $var_list
            } elseif {$type eq "check"} {
                ttk::combobox $w.value$i -width 6 -values {false true}
            } else {
                ttk::entry $w.value$i
                if {$type eq "file" || $type eq "path"} {
                    set btn "..."
                }
            }
            bind $w.value$i <FocusOut> "::enginewin::updateConfigSetOption $id $i $w.value$i"
            $w window create end -window $w.value$i
        }
        if {$btn ne ""} {
            ttk::button $w.button$i -style Pad0.Small.TButton -text $btn \
                -command "::enginewin::updateConfigBtn $id \"$name\" $type"
            $w window create end -window $w.button$i
        } elseif {$type eq "spin" || $type eq "slider"} {
            $w insert end " (Range: $min ... $max)"
        }
    }
}

proc ::enginewin::updateConfig {id msgData} {
    upvar ::enginewin::engConfig_$id engConfig_
    lassign $msgData protocol netclients options
    lassign $engConfig_ name cmd args wdir elo time url uci
    lassign $url scoreside notation pvwrap debugframe priority netport

    set oldOptions [lindex $engConfig_ 8]
    lset engConfig_ 8 $options
    if {$uci == ""} {
        if {[set idx [lsearch -index 0 $options "myname"]] >=0} {
            set name [::enginecfg::rename $name [lindex $options $idx 1]]
            lset engConfig_ 0 $name
        }
        lset engConfig_ 7 [expr { $protocol eq "uci" }]
    }

    set w .engineWin$id.config.options.text
    $w configure -state normal

    if {![winfo exists $w.name] || ![string equal \
        [lmap elem $oldOptions {lreplace $elem 1 1}] \
        [lmap elem $options {lreplace $elem 1 1}] \
    ]} {
        set oldOptions {}
        $w delete 1.0 end
        ::enginewin::createConfigWidgets $id $options

        ::enginewin::updateName $id
        $w.name delete 0 end
        $w.name insert end "$name"
        set wd [string length $name]
        if {$wd < 24} { set wd 24 } elseif {$wd > 60} { set wd 60 }
        $w.name configure -width $wd
        bind $w.name <FocusOut> [list apply {{id} {
            set old [lindex [set ::enginewin::engConfig_$id] 0]
            if {$old ne [set name [%W get]]} {
                set name [::enginecfg::rename $old $name]
                %W delete 0 end
                %W insert 0 $name
                lset ::enginewin::engConfig_$id 0 $name
                ::enginewin::updateName $id
            }
        }} $id]

        $w.cmd delete 0 end
        $w.cmd insert end $cmd
        set wd [string length $cmd]
        if {$wd < 24} { set wd 24 } elseif {$wd > 60} { set wd 60 }
        $w.cmd configure -width $wd

        $w.args delete 0 end
        $w.args insert end $args
        set wd [string length $args]
        if {$wd < 24} { set wd 24 } elseif {$wd > 60} { set wd 60 }
        $w.args configure -width $wd

        $w.wdir delete 0 end
        $w.wdir insert end $wdir
        set wd [string length $wdir]
        if {$wd < 24} { set wd 24 } elseif {$wd > 60} { set wd 60 }
        $w.wdir configure -width $wd

        $w.protocol set $protocol
        $w.protocol configure -state [expr { $uci == 2 ? "disabled" : "readonly" }]

        ::enginewin::changeDisplayLayout $id notation $notation
        $w.notation current [expr { $notation < 0 ? 0 - $notation : $notation }]

        $w.scoreside set $scoreside
        $w.wrap set $pvwrap
        $w.debug set $debugframe

        if {[catch {::engine::pid $id} enginePid]} {
            $w configure -state disabled
            return
        }
        if {$enginePid != ""} {
            $w.priority set $priority
            if {$priority eq "idle"} {
                catch { sc_info priority $enginePid idle }
            }
        }
    }

    if {$netport eq ""} {
        $w.netd set "off"
        $w.netport configure -state disabled
        bind $w.netport <FocusOut> {}
    } elseif {[string match "auto_*" $netport]} {
        $w.netd set "auto_port"
        $w.netport insert 0 [string range $netport 5 end]
        $w.netport configure -state readonly
        bind $w.netport <FocusOut> {}
    } else {
        $w.netd set "on"
        $w.netport insert 0 $netport
        bind $w.netport <FocusOut> "::enginewin::updateConfigNetd $id $w"
    }
    set strclients "\n"
    if {[llength $netclients]} {
        append strclients "Network Connections:"
        foreach client $netclients {
            append strclients "\t$client\n"
        }
    }
    $w replace netclients.first netclients.last $strclients netclients

    set disableReset 1
    for {set i 0} {$i < [llength $options]} {incr i} {
        lassign [lindex $options $i] name value type default min max var_list internal
        if {$internal || $type in [list button save reset]} { continue }

        if {$disableReset && $value ne $default} {
            $w.reset configure -state normal
            set disableReset 0
        }
        if {$oldOptions ne "" && \
            $value eq [lindex $oldOptions $i 1] && \
            $value eq [$w.value$i get]} { continue }

        if {$value eq $default} {
            $w tag remove header "$w.value$i linestart" $w.value$i
        } else {
            $w tag add header "$w.value$i linestart" $w.value$i
        }
        if {$type eq "string" || $type eq "file" || $type eq "path"} {
            set wd [string length $value]
            if {$wd < 24} { set wd 24 } elseif {$wd > 60} { set wd 60 }
            $w.value$i configure -width $wd
        }
        $w.value$i delete 0 end
        $w.value$i insert 0 $value

        if {[string equal -nocase $name "multipv"]} {
            ::enginewin::changeDisplayLayout $id multipv [list $i $value $min $max]
        }
    }
    if {$disableReset && [winfo exists $w.reset]} {
        $w.reset configure -state disabled
    }

    $w configure -state disabled
}

proc ::enginewin::updateConfigSetOption {idEngine idx widgetValue} {
    set options [lindex [set ::enginewin::engConfig_$idEngine] 8]
    lassign [lindex $options $idx] name oldValue type default min max
    set value [$widgetValue get]
    if {$value eq $oldValue} {
        return
    }
    if {$value eq ""} {
        set value $default
    } elseif {$min != "" && $max != ""} {
        if {$value < $min || $value > $max} {
            $widgetValue configure -style Error.TSpinbox
            return
        }
    } elseif {![catch { set values [$widgetValue cget -values] }]} {
        if {[set idx [lsearch -exact -nocase $values $value]] != -1} {
            set value [lindex $values $idx]
        } else {
            $widgetValue configure -style Error.TCombobox
            return
        }
    }
    $widgetValue configure -style {}
    ::engine::send $idEngine SetOptions [list [list $name $value]]
}

proc ::enginewin::updateConfigBtn {idEngine name type} {
    if {$type eq "file"} {
        set value [tk_getOpenFile]
        if {$value == ""} { return }
    } elseif {$type eq "path"} {
        set value [tk_chooseDirectory]
        if {$value == ""} { return }
    } else {
        set value ""
    }
    ::engine::send $idEngine SetOptions [list [list $name $value]]
}

proc ::enginewin::updateConfigReset {id} {
    upvar ::enginewin::engConfig_$id engConfig_
    if {[lindex $engConfig_ 7] != 2} {
        # Local engine: re-open
        ::enginewin::reconnect $id options {}
        return
    }

    set options {}
    foreach option [lindex [set ::enginewin::engConfig_$id] 8] {
        lassign $option name value type default min max var_list internal
        if {! $internal && $value ne $default} {
            lappend options [list $name $default]
        }
    }
    if {[llength $options]} {
        ::engine::send $id SetOptions $options
    }
}

proc ::enginewin::updateConfigNetd {id w} {
    bind $w.netport <FocusOut> {}
    $w.netport configure -state normal -style {}
    set port [$w.netport get]
    $w.netport delete 0 end
    if {[catch {
        switch [$w.netd get] {
          "auto_port" {
              set port [::engine::netserver $id 0]
              $w.netport insert 0 $port
              $w.netport configure -state readonly
              lset ::enginewin::engConfig_$id 6 5 "auto_$port"
          }
          "on" {
              bind $w.netport <FocusOut> "::enginewin::updateConfigNetd $id $w"
              set port [::engine::netserver $id $port]
              $w.netport insert 0 $port
              lset ::enginewin::engConfig_$id 6 5 $port
          }
          default {
              set port [::engine::netserver $id ""]
              $w.netport insert 0 $port
              $w.netport configure -state disabled
              lset ::enginewin::engConfig_$id 6 5 $port
          }
        }
    }]} {
        $w.netport configure -style Error.TEntry
        if {[$w.netd get] ne "on"} {
            $w.netport configure -state disabled
        }
        ERROR::MessageBox
    }
}

proc ::enginewin::createDisplayFrame {id w} {
    ttk::frame $w.header
    autoscrollText y $w.header.info $w.header.info.text Toolbutton
    $w.header.info.text configure -wrap word -height 1
    grid $w.header.info -sticky news -pady 2
    grid columnconfigure $w.header 0 -weight 1

    set tab [font measure font_Regular "xxxxxxx"]
    autoscrollText both $w.pv $w.pv.lines Treeview
    $w.pv.lines configure -exportselection true
    $w.pv.lines configure -tabs [list [expr {$tab * 2}] right [expr {int($tab * 2.2)}]]
    $w.pv.lines tag configure lmargin -lmargin2 [expr {$tab * 3}]
    $w.pv.lines tag configure markmove -underline 1
    $w.pv.lines tag bind moves <ButtonRelease-1> {
        if {[%W tag ranges sel] eq ""} {
            ::enginewin::exportMoves %W @%x,%y
        }
    }
    $w.pv.lines tag bind moves <Motion> [list apply {{id} {
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
    $w.pv.lines tag bind moves <Any-Leave> {
        %W tag remove markmove 1.0 end
        catch { wm withdraw .enginewinBoard }
    }

    grid $w.header -sticky news
    grid $w.pv -sticky news

    grid columnconfigure $w 0 -weight 1
    grid rowconfigure $w 1 -weight 1
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
            $w.display.pv.lines configure -wrap $value
        }
        "multipv" {
            if {$value eq ""} {
                $w.btn.multipv configure -state disabled
            } else {
                lassign $value idx value min max
                # TODO: bind focusout
                $w.btn.multipv configure -state normal -from $min -to $max \
                  -command "after idle {
                    set go \[expr { \$::enginewin::engState($id) in {run lock} }\]
                    ::enginewin::updateConfigSetOption $id $idx $w.btn.multipv
                    if {\$go} {
                        ::enginewin::onPosChanged $id
                    }
                }"
            }
            $w.btn.multipv set $value
            return
        }
        default { error "changeDisplayLayout unknown $param" }
    }
    lset engConfig_ 6 $idx $value
}

proc ::enginewin::updateDisplay {id msgData} {
    lassign $msgData multipv depth seldepth nodes nps hashfull tbhits time score score_type score_wdl pv
    if {$time eq ""} { set time 0 }
    if {$nps eq ""} { set nps 0 }
    if {$hashfull eq ""} { set hashfull 0 }
    if {$tbhits eq ""} { set tbhits 0 }

    set w .engineWin$id.display
    $w.header.info.text configure -state normal
    $w.header.info.text delete 1.0 end
    $w.header.info.text insert end "[tr Time]: " header
    $w.header.info.text insert end [format "%.2f s" [expr {$time / 1000.0}]]
    $w.header.info.text insert end "   [tr Nodes]: " header
    $w.header.info.text insert end [format "%.2f Kn/s" [expr {$nps / 1000.0}]]
    $w.header.info.text insert end "   Hash: " header
    $w.header.info.text insert end [format "%.1f%%" [expr {$hashfull / 10.0}]]
    $w.header.info.text insert end "   TB Hits: " header
    $w.header.info.text insert end $tbhits
    $w.header.info.text configure -state disabled

    $w.pv.lines configure -state normal
    if {$msgData eq ""} {
        $w.pv.lines delete 1.0 end
        $w.pv.lines configure -state disabled
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
        $w.pv.lines tag remove header 1.0 1.end
    }
    # If the engine has repeatedly sent multipv 1, do not delete the obsolete lines
    catch { $w.pv.lines tag nextrange header 2.0 } multilines
    if {$line > 1 || $multilines ne ""} {
        # Multipv lines >= than the current one are now obsolete and deleted.
        $w.pv.lines delete $line.0 end
    }
    $w.pv.lines insert $line.0 "\n"
    $w.pv.lines insert $line.end "$depth\t"
    $w.pv.lines insert $line.end "$score" header
    $w.pv.lines insert $line.end "\t"
    $w.pv.lines insert $line.end "$pv" [list header moves]
    $w.pv.lines insert $line.end "$pvline" [list lmargin moves]
    if {[info exists extraInfo]} {
        $w.pv.lines insert $line.end "  ([join $extraInfo {  }])" lmargin
    }

    $w.pv.lines configure -state disabled
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
