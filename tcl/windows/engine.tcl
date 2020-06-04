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
    set position ""
    foreach {id state} [array get ::enginewin::engState] {
        if {$state ne "run"} { continue }
        if {$ids ne "" && $id ni $ids} { continue }
        if {$position eq ""} {
            set position [sc_game UCI_currentPos]
        }
        ::enginewin::updateDisplay $id ""
        ::engine::send $id Go [list $position]
    }
}

proc ::enginewin::toggleStartStop {id} {
    if {![winfo exists .engineWin$id]} {
        ::enginewin::Open $id
        after 300 ".engineWin$id.config.header.go invoke"
        return
    }
    if {$::enginewin::engState($id) eq "idle"} {
        ::enginewin::changeState $id run
        ::enginewin::onPosChanged $id
    } else {
        ::enginewin::changeState $id idle
        ::engine::send $id StopGo
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
    ::enginewin::frameConfig $w.config $id "
        grid forget $w.config
        grid $w.display -in $w.main -sticky news
        ::enginewin::changeState $id run
        ::enginewin::onPosChanged $id
    "
    ttk::frame $w.display
    ::enginewin::frameDisplay $id $w.display "
        grid forget $w.display
        grid $w.config -in $w.main -sticky news
    "
    autoscrollText y $w.debug $w.debug.lines Treeview
    $w.debug.lines configure -state normal

    grid $w.config -in $w.main -sticky news

    # The engine should be closed before the debug .text is destroyed
    bind $w.config <Destroy> "
        unset ::enginewin::engState($id)
        ::engine::close $id
        ::enginelist::save \[ set ::enginewin::engConfig_$id \]
        unset ::enginewin::engConfig_$id
        unset ::enginewin::position_$id
        unset ::enginewin::startTime_$id
    "

    options.persistent ::enginewin_lastengine($id) ""
    set lastEngine [lsearch -exact -inline -index 0 $::engines(list) $::enginewin_lastengine($id)]

    set ::enginewin::engState($id) {}
    ::enginewin::clear $id
    ::enginewin::changeState $id closed
    ::enginewin::updateName $id

    set ::enginewin::startTime_$id [clock milliseconds]

    if {$lastEngine ne ""} {
        catch { ::enginewin::connectEngine $id $lastEngine }
    }
}

proc ::enginewin::clear {id} {
    ::engine::close $id
    set ::enginewin_lastengine($id) ""
    set ::enginewin::engConfig_$id {}
    set ::enginewin::position_$id ""
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

proc ::enginewin::frameConfig {w id showDisplay} {
    ttk::frame $w.header
    ttk::button $w.header.go -text go -command $showDisplay
    ttk::combobox $w.header.engine -state readonly -postcommand "
        $w.header.engine configure -values \[lmap elem \$::engines(list) { lindex \$elem 0 } \]
    "
    bind $w.header.engine <<ComboboxSelected>> "
        ::enginewin::connectEngine $id \[lindex \$::engines(list) \[$w.header.engine current\]\]
    "
    ttk::button $w.header.addpipe -text "add local" -command [list apply {{id} {
        if {[set fName [tk_getOpenFile]] != ""} {
            ::enginewin::connectEngine $id \
                [::enginelist::add [list $fName $fName {} {} {} 0 {} {} {}]]
        }
    }} $id]
    ttk::button $w.header.addnetwork -text "add remote" \
        -command "::enginewin::addNetwork $id"
    ttk::button $w.header.clone -text "clone" -command "
        ::enginewin::connectEngine $id \[::enginelist::add \$::enginewin::engConfig_$id \]
    "
    ttk::button $w.header.delete -text "delete" -command "
        $w.header.engine configure -values \[lmap elem \$::engines(list) { lindex \$elem 0 } \]
        ::enginelist::delete \[$w.header.engine current\]
        ::enginewin::clear $id
        ::enginewin::changeState $id closed
        ::enginewin::updateName $id
    "
    grid $w.header.go $w.header.engine $w.header.addpipe $w.header.addnetwork \
         $w.header.clone $w.header.delete -sticky news
    grid columnconfigure $w.header 1 -weight 1

    autoscrollText both $w.options $w.options.text Treeview
    $w.options.text configure -wrap none

    grid columnconfigure $w 0 -weight 1
    grid rowconfigure $w 1 -weight 1
    grid $w.header -sticky news
    grid $w.options -sticky news
}

proc ::enginewin::changeState {id newState} {
    if {$::enginewin::engState($id) eq $newState} { return }

    set w .engineWin$id
    if {$::enginewin::engState($id) eq "closed"} {
        $w.config.header.go configure -state normal
        $w.config.header.clone configure -state normal
        $w.config.header.delete configure -state normal
        $w.display.btn.startStop configure -state normal
    }
    switch $newState {
      "closed" {
          $w.config.header.go configure -state disabled
          $w.config.header.clone configure -state disabled
          $w.config.header.delete configure -state disabled
          $w.display.btn.startStop state !pressed
          $w.display.btn.startStop configure -state disabled
      }
      "idle" {
          $w.display.btn.startStop state !pressed
      }
      "run" {
          $w.display.btn.startStop state pressed
      }
    }
    set ::enginewin::engState($id) $newState
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

proc ::enginewin::connectEngine {id config} {
    upvar ::enginewin::engConfig_$id engConfig_
    ::enginelist::save $engConfig_
    ::enginewin::clear $id
    ::enginewin::changeState $id closed

    lassign $config name cmd args wdir elo time url uci options
    if {[llength $url] != 6} {
        set url [list white 1 word false normal ""]
    }
    lassign $url scoreside notation pvwrap debugframe priority netport
    set engConfig_ [list $name $cmd $args $wdir $elo $time $url $uci {}]

    ::enginewin::updateName $id
    ::enginewin::updateDisplay $id ""
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
    }]} {
        ERROR::MessageBox
        ::enginewin::updateConfig $id {}
        .engineWin$id.config.header.delete configure -state normal
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
    ::engine::send $id NewGame [list analysis post_pv post_wdl]
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
        ::enginewin::connectEngine $id [::enginelist::save $engConfig_]
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
        "Disconnected" {
            tk_messageBox -message "The connection with the engine terminated unexpectedly."
            ::enginewin::updateConfig $id {}
            ::enginewin::changeState $id closed
            .engineWin$id.config.header.delete configure -state normal
        }
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

proc ::enginewin::createConfigWidgets {id options} {
    set w .engineWin$id.config.options.text

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
    $w configure -tabs [font measure font_Regular "Accept Network Connections:XXXXX"]
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
            set name [::enginelist::rename $name [lindex $options $idx 1]]
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
                set name [::enginelist::rename $old $name]
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

proc ::enginewin::frameDisplay {id w showConfig} {
    ttk::frame $w.header
    autoscrollText y $w.header.info $w.header.info.text TLabel
    $w.header.info.text configure -wrap word -height 1
    ttk::button $w.header.config -style Toolbutton -image tb_tabmenu \
        -command $showConfig
    grid $w.header.config $w.header.info -sticky news
    grid columnconfigure $w.header 1 -weight 1

    set tab [font measure font_Regular "xxxxxxx"]
    autoscrollText both $w.pv $w.pv.lines Treeview
    $w.pv.lines configure -tabs [list [expr {$tab * 2}] right [expr {int($tab * 2.2)}]]
    $w.pv.lines tag configure lmargin -lmargin2 [expr {$tab * 3}]

    ttk::frame $w.btn
    ttk::button $w.btn.startStop -image [list tb_eng_on pressed tb_eng_off] \
        -command "::enginewin::toggleStartStop $id"
    ttk::button $w.btn.threats -text "Threats"
    ttk::spinbox $w.btn.multipv -increment 1 -width 4
    grid $w.btn.startStop $w.btn.threats $w.btn.multipv

    grid $w.header -sticky news
    grid $w.pv -sticky news
    grid $w.btn -sticky news

    grid columnconfigure $w 0 -weight 1
    grid rowconfigure $w 1 -weight 1
}

proc ::enginewin::changeDisplayLayout {id param value} {
    upvar ::enginewin::engConfig_$id engConfig_
    set w .engineWin$id.display
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
            $w.pv.lines configure -wrap $value
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
    regexp {^([\d. ]*[\w-]+)(.*)$} $pv -> pv pvline
    if {$multipv == 1} {
        set line $multipv
        $w.pv.lines tag remove header 1.0 1.end
    } else {
        #TODO: this assumes that the lines are sent in order
        set line $multipv
        $w.pv.lines delete $line.0 end
    }
    $w.pv.lines insert $line.0 "\n"
    $w.pv.lines insert $line.end "$depth\t"
    $w.pv.lines insert $line.end "$score" header
    $w.pv.lines insert $line.end "\t"
    $w.pv.lines insert $line.end "$pv" header
    $w.pv.lines insert $line.end "$pvline" lmargin
    if {[info exists extraInfo]} {
        $w.pv.lines insert $line.end "  ([join $extraInfo {  }])" lmargin
    }

    $w.pv.lines configure -state disabled
}
