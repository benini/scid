########################################################################
# Copyright (C) 2020 Fulvio Benini
#
# This file is part of Scid (Shane's Chess Information Database).
# Scid is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.

### Window for chess engine configuration and position analysis

namespace eval enginewin {}
array set ::enginewin::engState {} ; # closed idle run locked

# Sends the updated position to the active engines
proc ::enginewin::onPosChanged { {ids ""} } {
    set msgData ""
    foreach {id state} [array get ::enginewin::engState] {
        if {$state ne "run"} { continue }
        if {$ids ne "" && $id ni $ids} { continue }
        if {$msgData eq ""} {
            set msgData [list [sc_game UCI_currentPos]]
        }
        ::engine::send $id Go $msgData
    }
}

proc ::enginewin::toggleStartStop {id} {
    if {![winfo exists .engineWin$id]} {
        ::enginewin::Open $id
        .engineWin$id.display.btn.showDebug invoke
        ::enginewin::connectEngine $id [lindex $::engines(list) 0]
        .engineWin$id.config.header.go invoke
        return
    }
    if {$::enginewin::engState($id) eq "idle"} {
        set ::enginewin::engState($id) "run"
        ::enginewin::onPosChanged $id
    } else {
        set ::enginewin::engState($id) "idle"
        ::engine::send $id Stop
    }
}

proc ::enginewin::Open { {id ""} } {
    if {$id == ""} {
        set id 1
        while {[winfo exists .engineWin$id]} {
            incr id
        }
    }
    set w .engineWin$id
    ::win::createWindow $w "Engine Window"
    set btn1 [::enginewin::frameConfig [ttk::frame $w.config] $id]
    $btn1 configure -command "
        grid forget $w.config
        grid $w.display -sticky news
        set ::enginewin::engState($id) run
        ::enginewin::onPosChanged $id
    "
    set btn2 [::enginewin::frameDisplay [ttk::frame $w.display] $id]
    $btn2 configure -command "
        grid forget $w.display
        grid $w.config -sticky news
    "
    grid columnconfigure $w 0 -weight 1
    grid rowconfigure $w 0 -weight 1

    # The engine should be closed before the debug .text is destroyed
    bind $w.config <Destroy> "
        ::engine::close $id
        unset ::enginewin::engState($id)
    "
    grid $w.config -sticky news

    ::engine::setLogCmd $id
    ::enginewin::clearAll $id
}

proc ::enginewin::frameConfig {w id} {
    ttk::frame $w.header
    ttk::button $w.header.go -text go
    ttk::combobox $w.header.engine -state readonly -postcommand "
        $w.header.engine configure -values \[lmap elem \$::engines(list) { lindex \$elem 0 } \]
    "
    bind $w.header.engine <<ComboboxSelected>> "
        set config \[lindex \$::engines(list) \[$w.header.engine current\]\]
        lset config 4 {}
        ::enginewin::connectEngine $id \$config
    "
    ttk::button $w.header.addpipe -text "add local" -command "::enginewin::addLocal $id"
    ttk::button $w.header.addnetwork -text "add remote" -command "::enginewin::addNetwork $id"
    ttk::button $w.header.clone -text "clone"
    ttk::button $w.header.delete -text "delete" -command "
        set name \[lindex \$::enginewin::engConfig($id) 0 \]
        ::enginelist::delete \[lsearch -exact -index 0 \$::engines(list) \$name \]
    "
    grid $w.header.go $w.header.engine $w.header.addpipe $w.header.addnetwork \
         $w.header.clone $w.header.delete -sticky news
    grid columnconfigure $w.header 1 -weight 1

    autoscrollText both $w.options $w.options.text Treeview
    $w.options.text tag configure bold -font font_Bold

    grid columnconfigure $w 0 -weight 1
    grid rowconfigure $w 1 -weight 1
    grid $w.header -sticky news
    grid $w.options -sticky news

    return $w.header.go
}

proc ::enginewin::frameDisplay {w id} {
    ttk::frame $w.header
    autoscrollText y $w.header.info $w.header.info.text TLabel
    $w.header.info.text configure -wrap word -height 1
    $w.header.info.text tag configure bold -font font_Bold
    ttk::button $w.header.config -style Toolbutton -image tb_config
    grid $w.header.info $w.header.config -sticky news
    grid columnconfigure $w.header 0 -weight 1

    set tab [font measure font_Regular "xxxxxxx"]
    autoscrollText both $w.pv $w.pv.lines Treeview
    $w.pv.lines configure -wrap word -tabs [list [expr {$tab * 2}] right [expr {int($tab * 2.2)}]]
    $w.pv.lines tag configure pv -lmargin2 [expr {$tab * 3}]
    $w.pv.lines tag configure bold -font font_Bold
    grid propagate $w.pv 0

    autoscrollText y $w.debug $w.debug.lines TLabel
    $w.debug.lines configure -state normal -relief sunken
    $w.debug.lines tag configure bold -font font_Bold
    grid propagate $w.debug 0

    ttk::frame $w.btn
    ttk::button $w.btn.startStop -image [list tb_eng_on pressed tb_eng_off] \
        -command "::enginewin::toggleStartStop $id"
    ttk::button $w.btn.threats -text "Threats"
    ttk::button $w.btn.showDebug -text "showDebug" \
        -command "::enginewin::showDebug $w $id"
    grid $w.btn.startStop $w.btn.threats $w.btn.showDebug

    grid $w.header -sticky news
    grid $w.pv -sticky news
    grid $w.debug -sticky news
    grid $w.btn -sticky news

    grid columnconfigure $w 0 -weight 1
    grid rowconfigure $w 1 -weight 1

    return $w.header.config
}

proc ::enginewin::showDebug {w id} {
    if {[grid rowconfigure $w 2 -weight]} {
        $w.btn.showDebug state !pressed
        grid rowconfigure $w 2 -weight 0
        ::engine::setLogCmd $id "" ""
    } else {
        $w.btn.showDebug state pressed
        grid rowconfigure $w 2 -weight 1
        ::engine::setLogCmd $id \
            [list ::enginewin::logEngine $w.debug.lines "" ""]\
            [list ::enginewin::logEngine $w.debug.lines bold ">>"]
    }
}

proc ::enginewin::logEngine {widget tag prefix msg} {
    $widget insert end "[set prefix]$msg\n" $tag
    $widget see end
}

proc ::enginewin::clearAll {id} {
    unset -nocomplain ::enginewin::engConfig($id)
    set ::enginewin::engState($id) "idle"

    ::setTitle .engineWin$id "Engine Window"
    ::enginewin::updateDisplay $id ""
    .engineWin$id.config.header.engine set ""
    .engineWin$id.config.options.text configure -state normal
    .engineWin$id.config.options.text delete 1.0 end
    .engineWin$id.config.options.text configure -state disabled

    #TODO: disable buttons
}

proc ::enginewin::connectEngine {id config} {
    lassign $config name cmd args dir netport time url uci options
    set ::enginewin::engConfig($id) [lrange $config 0 3]

    ::setTitle .engineWin$id "Engine: $name"
    ::enginewin::updateDisplay $id ""
    .engineWin$id.config.options.text configure -state normal
    .engineWin$id.config.options.text delete 1.0 end
    .engineWin$id.config.options.text insert 1.0 "Connecting..."
    .engineWin$id.config.options.text configure -state disabled
    update idletasks

    switch $uci {
      0 { set protocol "xboard" }
      1 { set protocol "uci" }
      2 { set protocol "network" }
      default { set protocol [list uci xboard] }
    }
    if {[catch {
        ::engine::connect $id [list ::enginewin::callback $id] $cmd $args $protocol
    }]} {
        ERROR::MessageBox
        ::enginewin::clearAll $id
        return
    }
    #TODO: enable buttons

    if {[catch {
        if {[string match "auto_*" $netport]} {
            lappend ::enginewin::engConfig($id) "auto_[::engine::netserver $id 0]"
        } else {
            lappend ::enginewin::engConfig($id) [::engine::netserver $id $netport]
        }
    }]} {
        ERROR::MessageBox
    }

    if {[llength $options]} {
        ::engine::send $id SetOptions $options
    }
    ::engine::send $id NewGame [list analysis post_pv post_wdl]
}

proc ::enginewin::callback {id msg} {
    lassign $msg msgType msgData
    switch $msgType {
        "InfoConfig" { ::enginewin::updateConfig $id $msgData }
        "InfoPV" { ::enginewin::updateDisplay $id $msgData }
        "InfoReady" {
            set ::enginewin::engState($id) "idle"
            .engineWin$id.display.btn.startStop state !pressed
        }
        "Disconnected" {
            tk_messageBox -message "The connection with the engine terminated unexpectedly."
            ::enginewin::clearAll $id
        }
    }
}

proc ::enginewin::addLocal {id} {
    if {[set fName [tk_getOpenFile]] != ""} {
        ::engine [list Name $fName Cmd $fName Dir .]
        lset ::engines(list) end 7 {}
        ::enginewin::connectEngine $id [lindex $::engines(list) end]
    }
}

proc ::enginewin::addNetwork {id} {
    set w .enginewinAddNetwork
    win::createDialog $w
    grid [ttk::label $w.option_name -text "<hostname>:<port>"] [ttk::entry $w.new_value]
    dialogbutton $w.cancel -text "cancel" -command "destroy $w"
    dialogbutton $w.ok -text "OK" -command "
        set host \[$w.new_value get\]
        destroy $w
        ::enginewin::connectEngine $id \[list \$host \$host {} {} {} {} {} 2 \]
    "
    grid $w.cancel $w.ok
}

proc ::enginewin::updateConfig {id msgData} {
    lassign $::enginewin::engConfig($id) name cmd args dir netport
    lassign $msgData protocol netclients ::enginewin::options

    set w .engineWin$id.config.options.text
    set focus [focus -displayof $w]
    $w configure -state normal -wrap none
    $w delete 1.0 end

    $w insert end "[tr EngineName]:\t$name\n"
    $w insert end "[tr EngineCmd]:\t$cmd\n"
    $w insert end "[tr EngineArgs]:\t$args\n"

    $w insert end "Protocol:\t"
    ttk::combobox $w.protocol -width 9 -values {uci xboard2 xboard}
    $w.protocol insert 0 $protocol
    $w.protocol configure -state readonly
    $w window create end -window $w.protocol
    $w insert end "\n"

    $w insert end "Score as white\n"
    $w insert end "SAN notation\n"
    $w insert end "Wrap lines\n"

    $w insert end "Accept Network Connections:\t"
    ttk::combobox $w.netd -state readonly -width 9 -values {off on auto_port}
    $w window create end -window $w.netd
    $w insert end "  port:"
    ttk::entry $w.netport -width 6 -validate key -validatecommand { string is integer %P }
    $w window create end -window $w.netport
    $w insert end "\n"
    if {$netport eq ""} {
        $w.netd set "off"
        $w.netport configure -state disabled
    } elseif {[string match "auto_*" $netport]} {
        $w.netd set "auto_port"
        $w.netport insert 0 [string range $netport 5 end]
        $w.netport configure -state readonly
    } else {
        $w.netd set "on"
        $w.netport insert 0 $netport
        bind $w.netport <FocusOut> "::enginewin::updateConfigNetd $id $w"
    }
    bind $w.netd <<ComboboxSelected>> "::enginewin::updateConfigNetd $id $w"
    if {[llength $netclients]} {
        $w insert end "Network Connections:"
        foreach client $netclients {
            $w insert end "\t$client\n"
        }
    }
    $w insert end "\n"

    if {[llength $::enginewin::options]} {
        ttk::button $w.reset -style Pad0.Small.TButton -text "Reset Options" \
            -command "::enginewin::updateConfigReset $id"
        $w window create end -window $w.reset
        $w insert end "\n"
    }

    for {set i 0} {$i < [llength $::enginewin::options]} {incr i} {
        lassign [lindex $::enginewin::options $i] name value type default min max var_list internal
        if {$internal} { continue }
        if {$value eq $default} {
            $w insert end "$name\t"
        } else {
            $w insert end "$name\t" bold
        }
        set endline "\n"
        set btn ""
        if {$type eq "button" || $type eq "save" || $type eq "reset"} {
            set btn $name
        } else {
            if {$type eq "spin" || $type eq "slider"} {
                ttk::spinbox $w.value$i -width 12 -from $min -to $max -increment 1
                set endline " (Range: $min ... $max)\n"
            } elseif {$type eq "combo"} {
                lassign [lsort -decreasing -integer [lmap elem $var_list { string length $elem }]] maxlen
                ttk::combobox $w.value$i -width [incr maxlen] -values $var_list
            } elseif {$type eq "check"} {
                ttk::combobox $w.value$i -width 6 -values {false true}
            } else {
                set wd [string length $value]
                if {$wd < 24} { set wd 24 } elseif {$wd > 60} { set wd 60 }
                ttk::entry $w.value$i -width $wd
                $w window create end -window $w.value$i
                if {$type eq "file" || $type eq "path"} {
                    set btn "..."
                }
            }
            $w window create end -window $w.value$i
            $w.value$i insert 0 $value
            bind $w.value$i <FocusOut> "::enginewin::updateConfigSetOption $id $i %W"
        }
        if {$btn != ""} {
            ttk::button $w.openfile$i -style Pad0.Small.TButton -text $btn \
                -command "::enginewin::updateConfigBtn $id \"$name\" $type"
            $w window create end -window $w.openfile$i
        }
        $w insert end $endline
    }
    $w configure -tabs {5c}
    $w configure -state disabled
    if {[lsearch -exact [winfo children $w] $focus] != -1} {
        focus $focus
        $w see $focus
    }
}

proc ::enginewin::updateConfigSetOption {idEngine idx widgetValue} {
    lassign [lindex $::enginewin::options $idx] name oldValue type default min max
    set value [$widgetValue get]
    if {$value eq $oldValue} {
        return
    }
    if {$value eq ""} {
        set value $default
    }
    if {$min != "" && $max != ""} {
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

proc ::enginewin::updateConfigReset {idEngine} {
    set options {}
    foreach option $::enginewin::options {
        lassign $option name value type default min max var_list internal
        if {! $internal && $value ne $default} {
            lappend options [list $name $default]
        }
    }
    if {[llength $options]} {
        ::engine::send $idEngine SetOptions $options
    }
}

proc ::enginewin::updateConfigNetd {id w} {
    bind $w.netport <FocusOut> {}
    $w.netport configure -state normal
    set port [$w.netport get]
    $w.netport delete 0 end
    $w.netport configure -style {}
    if {[catch {
        switch [$w.netd get] {
          "auto_port" {
              set port [::engine::netserver $id 0]
              $w.netport insert 0 $port
              $w.netport configure -state readonly
              lset ::enginewin::engConfig($id) 4 "auto_$port"
          }
          "on" {
              bind $w.netport <FocusOut> "::enginewin::updateConfigNetd $id $w"
              set port [::engine::netserver $id $port]
              $w.netport insert 0 $port
              lset ::enginewin::engConfig($id) 4 $port
          }
          default {
              set port [::engine::netserver $id ""]
              $w.netport insert 0 $port
              $w.netport configure -state disabled
              lset ::enginewin::engConfig($id) 4 $port
          }
        }
    }]} {
        $w.netport configure -style Error.TEntry
        ERROR::MessageBox
    }
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
    $w.header.info.text insert end "[tr Time]: " bold
    $w.header.info.text insert end [format "%.2f s" [expr {$time / 1000.0}]]
    $w.header.info.text insert end "   [tr Nodes]: " bold
    $w.header.info.text insert end [format "%.2f Kn/s" [expr {$nps / 1000.0}]]
    $w.header.info.text insert end "   Hash: " bold
    $w.header.info.text insert end [format "%.1f%%" [expr {$hashfull / 10.0}]]
    $w.header.info.text insert end "   TB Hits: " bold
    $w.header.info.text insert end $tbhits
    $w.header.info.text configure -state disabled

    $w.pv.lines configure -state normal
    if {$msgData eq ""} {
        $w.pv.lines delete 1.0 end
        $w.pv.lines configure -state disabled
        set ::enginewin::engState($id) "run"
        $w.btn.startStop state pressed
        return
    }

    if {$score ne ""} {
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
    set firstMove [string wordend $pv 0]
    if {$multipv == 1} {
        set line $multipv
        $w.pv.lines tag remove bold 1.0 1.end
    } else {
        #TODO: this assumes that the lines are sent in order
        set line $multipv
        $w.pv.lines delete $line.0 end
    }
    $w.pv.lines insert $line.0 "\n"
    $w.pv.lines insert $line.end "$depth"
    $w.pv.lines insert $line.end "\t$score" bold
    $w.pv.lines insert $line.end "\t[string range $pv 0 $firstMove]" bold
    $w.pv.lines insert $line.end "[string range $pv [incr firstMove] end]" pv
    if {[info exists extraInfo]} {
        $w.pv.lines insert $line.end "  ([join $extraInfo {  }])" pv
    }

    $w.pv.lines configure -state disabled
}
