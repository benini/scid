########################################################################
# Copyright (C) 2020-2023 Fulvio Benini
#
# This file is part of SCID (Shane's Chess Information Database).
# SCID is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.

### Functions and sub-window for chess engine configuration.

namespace eval enginecfg {}

# Return a list containing the engine's names sorted by last use.
proc ::enginecfg::names {} {
    return [lmap elem [lsort -integer -decreasing -index 5 $::engines(list)] {
        lindex $elem 0
    }]
}

# Return the engine's config.
# If there is no config for the requested engine's name, returns "".
proc ::enginecfg::get {name} {
    set res [lsearch -exact -inline -index 0 $::engines(list) $name]
    if {$res ne ""} {
        # The old url element is now used to store the values for:
        # scoreside notation pvwrap debugframe priority netport
        if {[llength [lindex $res 6]] != 6} {
            lset res 6 [list white 1 word false normal ""]
        }
    }
    return $res
}

# Change the name of an engine and write the "Engine list" file.
# Returns the new name on success or the old name on error.
proc ::enginecfg::rename {oldname newname} {
    set idx [lsearch -exact -index 0 $::engines(list) $oldname]
    if {$idx < 0 || $newname eq $oldname || $newname eq ""} {
        return $oldname
    }
    set newname [::enginecfg::uniquename $newname]
    lset ::engines(list) $idx 0 $newname
    ::enginecfg::write
    return $newname
}

# Append a number, or increments it, to the name of an engine to make it unique.
# Return the unique name.
proc ::enginecfg::uniquename {name} {
    set copyn 0
    while {[lsearch -exact -index 0 $::engines(list) $name] >= 0} {
        regexp {^(.*?)\s*(\(\d+\))*$} $name -> name
        set name "$name ([incr copyn])"
    }
    return $name
}

# Add an engine, possibly changing the name to make it unique,
# and save the "Engine list" file.
# Return the name of the new engine or "".
proc ::enginecfg::add {enginecfg} {
    lset enginecfg 0 [::enginecfg::uniquename [lindex $enginecfg 0]]
    lappend ::engines(list) $enginecfg
    return [::enginecfg::save $enginecfg true]
}

# Remove an engine from the "Engine list" file.
# Returns true if the engine was removed
proc ::enginecfg::remove {name} {
    set idx [lsearch -exact -index 0 $::engines(list) $name]
    if {$idx < 0} { return false }

    lassign [lindex $::engines(list) $idx] name cmd
    set msg "Name: $name\n"
    append msg "Command: $cmd\n\n"
    append msg "Do you really want to remove this engine from the list?"
    set answer [tk_messageBox -title Scid -icon question -type yesno -message $msg]
    if {$answer ne "yes"} { return false }

    set ::engines(list) [lreplace $::engines(list) $idx $idx]
    ::enginecfg::write
    return true
}

# Search a previous configuration with the same name and replace it.
# Write the "Engine list" file if it is necessary or force_write is true.
# Return the engine's name or "" (and does nothing) if the engine do not exists.
proc ::enginecfg::save {enginecfg {force_write false}} {
    lassign $enginecfg enginename
    set idx [lsearch -exact -index 0 $::engines(list) $enginename]
    if {$idx < 0} {
        return ""
    }
    lset enginecfg 8 [lmap elem [lindex $enginecfg 8] {
        lassign $elem name value type default min max var_list internal
        if {$internal || $value eq $default} { continue }
        list $name $value
    }]
    if {$force_write || [lindex $::engines(list) $idx] ne $enginecfg} {
        lset ::engines(list) $idx $enginecfg
        ::enginecfg::write
    }
    return $enginename
}

# Writes the "Engine list" file.
# Throw an exception on error.
proc ::enginecfg::write {} {
    set enginesFile [scidConfigFile engines]
    set f [open $enginesFile w]
    puts $f "\# Analysis engines list file for Scid $::scidVersion with UCI support"
    puts $f ""
    foreach e $::engines(list) {
        lassign $e name cmd args dir elo time url uci opt
        puts $f "engine {"
            puts $f "  Name [list $name]"
            puts $f "  Cmd  [list $cmd]"
            puts $f "  Args [list $args]"
            puts $f "  Dir  [list $dir]"
            puts $f "  Elo  [list $elo]"
            puts $f "  Time [list $time]"
            puts $f "  URL  [list $url]"
            puts $f "  UCI [list $uci]"
            puts $f "  UCIoptions [list $opt]"
            puts $f "}"
        puts $f ""
    }
    close $f
}

# Pop up a dialog box for the user to select the cmd file referring to a local engine
# and adds the engine to the list of the available ones.
# Return the name of the new engine or "".
proc ::enginecfg::dlgNewLocal {} {
    if {$::windowsOS} {
        lappend ftype [list "Executable" [list ".exe" ".bat"]]
    }
    lappend ftype [list "All files" *]
    set fName [tk_getOpenFile -initialdir $::scidEnginesDir -filetypes $ftype]
    if {$fName eq ""} { return "" }
    set ::scidEnginesDir [file dirname $fName]
    return [::enginecfg::add [list $fName $fName {} {} {} 0 {} {} {}]]
}

# Pop up a dialog box for the user to enter the url of a remote engine
# and adds the engine to the list of the available ones.
# Return the name of the new engine or "".
proc ::enginecfg::dlgNewRemote {} {
    set ::enginecfg_dlgresult ""
    set w .engineDlgNewRemote
    win::createDialog $w
    pack [ttk::label $w.msg -text "Remote engine (hostname:port):"] -fill x
    pack [ttk::entry $w.value] -fill x
    dialogbutton $w.cancel -text [tr Cancel] -command "destroy $w"
    dialogbutton $w.ok -text "OK" -command "
        set ::enginecfg_dlgresult \[$w.value get\]
        destroy $w
    "
    ::packdlgbuttons $w.cancel $w.ok
    grab $w
    tkwait window $w
    if {$::enginecfg_dlgresult eq ""} { return "" }
    return [::enginecfg::add [list $::enginecfg_dlgresult $::enginecfg_dlgresult {} {} {} 0 {} 2]]
}

# Creates buttons used for selecting an engine and managing configured engines:
# Adds a new local or remote engine; reloads, clones, or deletes an existing engine.
# fn_connect: Callback function invoked upon engine selection.
# In response to the virtual event <<UpdateEngineName>>, it updates the name of the
# selected engine and the state of the reload, clone, and delete buttons.
proc ::enginecfg::createConfigButtons {id w} {
    ttk::combobox $w.engine -width 30 -state readonly -postcommand [list apply {{w} {
        $w.engine configure -values [::enginecfg::names ]
    }} $w]
    bind $w.engine <<ComboboxSelected>> \
        "event generate $w <<EngineCfgConnect>> -data \[list $id \[%W get]]"
    ::utils::tooltip::Set $w.engine [tr EngineSelect]

    ttk::button $w.reload -text "\u21BB" -style Toolbutton \
        -command "event generate $w.engine <<ComboboxSelected>>"
    ::utils::tooltip::Set $w.reload [tr EngineReload]

    ttk::button $w.addpipe -text "\u271A" -style Toolbutton -command [list apply {{id w} {
        if {[set newEngine [::enginecfg::dlgNewLocal]] ne ""} {
            event generate $w <<EngineCfgConnect>> -data [list $id $newEngine]
        }
    }} $id $w]
    ::utils::tooltip::Set $w.addpipe [tr EngineAddLocal]

    ttk::button $w.addremote -text "\u2B82" -style Toolbutton -command [list apply {{id w} {
        if {[set newEngine [::enginecfg::dlgNewRemote]] ne ""} {
            event generate $w <<EngineCfgConnect>> -data [list $id $newEngine]
        }
    }} $id $w]
    ::utils::tooltip::Set $w.addremote [tr EngineAddRemote]

    ttk::button $w.clone -text "\u29C9" -style Toolbutton -command [list apply {{id w} {
        event generate $w <<EngineCfgConnect>> -data [list $id [::enginecfg::add [set ::enginecfg::engConfig_$id]]]
    }} $id $w]
    ::utils::tooltip::Set $w.clone [tr EngineClone]

    ttk::button $w.delete -text "\u2A02" -style Toolbutton -command [list apply {{id w} {
        if {[::enginecfg::remove [$w.engine get]]} {
            event generate $w <<EngineCfgConnect>> -data [list $id {}]
        }
    }} $id $w]
    ::utils::tooltip::Set $w.delete [tr EngineDelete]

    grid $w.engine $w.reload $w.addpipe $w.addremote \
         $w.clone $w.delete -sticky news -padx 4

    bind $w <<UpdateEngineName>> [list apply {{w} {
        lassign %d name
        set state "normal"
        if {$name eq ""} {
            set name "[tr Engine]:"
            set state "disabled"
        }
        $w.engine set $name
        $w.reload configure -state $state
        $w.clone configure -state $state
        $w.delete configure -state $state
    }} $w]
}

# Creates the frame with the widgets necessary to change an engine's configuration.
proc ::enginecfg::createConfigOptions {id configFrame} {
    ttk_text $configFrame.text -wrap none -padx 4
    autoscrollBars both $configFrame $configFrame.text
    $configFrame.text configure -state disabled
}

proc ::enginecfg::resetConfigOptions {id configFrame msg} {
    $configFrame.text configure -state normal
    $configFrame.text delete 1.0 end
    $configFrame.text insert end $msg
    $configFrame.text configure -state disabled
}

# Update or recreate the config and option widgets
# If it is a new engine added with auto-config, return the new name
# otherwise return an empty "" string
proc ::enginecfg::updateConfigOptions {id configFrame msgInfoConfig} {
    upvar ::enginecfg::engConfig_$id engConfig_
    set w $configFrame.text
    lassign $msgInfoConfig protocol netclients options

    # Replace the engine's available options
    set oldOptions [lindex $engConfig_ 8]
    lset engConfig_ 8 $options

    set renamed ""
    set recreate_widgets 1
    if {$msgInfoConfig eq ""} {
        # An emtpy message -> recreate all the widgets
    } elseif {[lindex $engConfig_ 7] == ""} {
        # A new engine added with auto-config, update the name and protocol
        # and recreate all the widgets
        lassign $engConfig_ currname
        if {[set idx [lsearch -index 0 $options "myname"]] >=0} {
            set renamed [::enginecfg::rename $currname [lindex $options $idx 1]]
            lset engConfig_ 0 $renamed
        }
        lset engConfig_ 7 [expr { $protocol eq "uci" }]

    } elseif {[winfo exists $w.name] && [string equal \
                            [lmap elem $oldOptions {lreplace $elem 1 1}] \
                            [lmap elem $options {lreplace $elem 1 1}]]} {
        # Same options, no need to recreate the widgets
        set recreate_widgets 0
    }

    $w configure -state normal
    if {$recreate_widgets} {
        if {![::enginecfg::createConfigWidgets $id $configFrame $engConfig_]} {
            # The option widgets are not created if the engine is not open
            $w configure -state disabled
            return $renamed
        }
        ::enginecfg::createOptionWidgets $id $configFrame $options
    }
    ::enginecfg::updateOptionWidgets $id $configFrame $options $oldOptions
    ::enginecfg::updateNetClients $configFrame $netclients
    $w configure -state disabled
    return $renamed
}

# If enabled will automatically write the "Engine list" file when
# the configFrame is destroyed.
proc ::enginecfg::autoSaveConfig {id configFrame {autosave false}} {
    if {$autosave} {
        bind $configFrame.text <Destroy> "
            ::enginecfg::save \[ set ::enginecfg::engConfig_$id \]
        "
    } else {
        bind $configFrame.text <Destroy> {}
    }
}

# Find an option by name (case insensitive).
# Return the index of options or throw an exception if the option do not exists.
proc ::enginecfg::findOption {id name} {
    set options [lindex [set ::enginecfg::engConfig_$id] 8]
    for {set idx 0} {$idx < [llength $options]} {incr idx} {
        lassign [lindex $options $idx] option_name
        if {[string equal -nocase $name $option_name]} {
            return $idx
        }
    }
    error "wrong option"
}

# Sends a SetOptions message to the engine if an option's value is different.
# Return true if a message was sent to the engine.
# Throw an exception in case of error.
proc ::enginecfg::setOption {id idx value} {
    lassign [lindex [set ::enginecfg::engConfig_$id] 8 $idx] \
        name oldValue type default min max

    if {$value eq $oldValue} { return false }

    if {$value eq ""} {
        set value $default
    } elseif {$min != "" && $max != ""} {
        if {$value < $min || $value > $max} {
            error "wrong value"
        }
    } elseif {![catch { set values [$widget cget -values] }]} {
        if {[set idx [lsearch -exact -nocase $values $value]] != -1} {
            set value [lindex $values $idx]
        } else {
            error "wrong value"
        }
    }
    ::engine::send $id SetOptions [list [list $name $value]]
    return true
}

# Read an option's value from a widget and if it has changed sends a SetOptions
# message to the engine.
# Return true if a message was sent to the engine.
# On error the widget style is set to Error.WidgetType
proc ::enginecfg::setOptionFromWidget {id idx widget} {
    set value [$widget get]
    if {[catch {::enginecfg::setOption $id $idx $value} res]} {
        $widget configure -style Error.[winfo class $widget]
        return false
    }
    $widget configure -style {}
    return $res
}

# Creates the widgets for engine configuration, like the engine path, command
# line parameters, uci/xboard protocol, etc...
proc ::enginecfg::createConfigWidgets {id configFrame engCfg} {
    lassign $engCfg name cmd args wdir elo time url uci
    lassign $url scoreside notation pvwrap debugframe priority netport

    set w $configFrame.text

    $w delete 1.0 end

    # Use the last element from the sorted list of the labels' width.
    $w configure -tabs [lindex [lsort -integer [lmap elem [list \
        EngineCmd EngineArgs EngineDir EngineProtocol EngineNotation \
        EngineFlipEvaluation EngineShowLog LowPriority EngineNetworkd] {
             font measure font_Regular -displayof $w "[tr $elem]: "
        }]] end]

    if {$name == ""} {
        return false
    }

    set fn_create_entry {{w widget label value} {
        $w insert end "$label:\t"
        ttk::entry $w.$widget
        $w window create end -window $w.$widget -pady 2
        $w.$widget insert end "$value"
        set wd [string length $value]
        if {$wd < 24} { set wd 24 } elseif {$wd > 60} { set wd 60 }
        $w.$widget configure -width $wd
    }}

    set fn_reconnect [list apply {{id configFrame {W %W}} {
        switch [winfo name $W] {
            "cmd"      { set configIdx 1; set newValue [$W get] }
            "cmdbtn"   { set configIdx 1; set dlgcmd tk_getOpenFile }
            "args"     { set configIdx 2; set newValue [$W get] }
            "wdir"     { set configIdx 3; set newValue [$W get] }
            "wdirbtn"  { set configIdx 3; set dlgcmd tk_chooseDirectory }
            "protocol" { set configIdx 7; set newValue [$W current] }
            default { error "wrong option" }
        }
        upvar ::enginecfg::engConfig_$id engConfig_
        set oldValue [lindex $engConfig_ $configIdx]
        if {[info exists dlgcmd]} {
            set newValue [$dlgcmd -initialdir [file dirname $oldValue]]
            if {$newValue == ""} {
                return
            }
        }
        if {$newValue ne $oldValue} {
            lset engConfig_ $configIdx $newValue
            event generate $configFrame <<EngineCfgConnect>> \
                -data [list $id [::enginecfg::save $engConfig_]]
        }
    }} $id $configFrame]

    apply $fn_create_entry $w name [tr EngineName] $name
    bind $w.name <FocusOut> [list apply {{id configFrame} {
        lassign [set ::enginecfg::engConfig_$id] old
        if {$old ne [set name [%W get]]} {
            ::enginecfg::save [set ::enginecfg::engConfig_$id]
            event generate $configFrame <<EngineCfgConnect>> \
                -data [list $id [::enginecfg::rename $old $name]]
        }
    }} $id $configFrame]
    bind $w.name <Return> [bind $w.name <FocusOut>]

    apply $fn_create_entry $w cmd "\n[tr EngineCmd]" $cmd
    bind $w.cmd <FocusOut> $fn_reconnect
    bind $w.cmd <Return> [bind $w.cmd <FocusOut>]
    ttk::button $w.cmdbtn -style Pad0.Small.TButton -text ... \
        -command [list {*}$fn_reconnect $w.cmdbtn]
    $w window create end -window $w.cmdbtn -pady 2 -padx 2

    apply $fn_create_entry $w args "\n[tr EngineArgs]" $args
    bind $w.args <FocusOut> $fn_reconnect
    bind $w.args <Return> [bind $w.args <FocusOut>]

    apply $fn_create_entry $w wdir "\n[tr EngineDir]" $wdir
    bind $w.wdir <FocusOut> $fn_reconnect
    bind $w.wdir <Return> [bind $w.wdir <FocusOut>]
    ttk::button $w.wdirbtn -style Pad0.Small.TButton -text ... \
        -command [list {*}$fn_reconnect $w.wdirbtn]
    $w window create end -window $w.wdirbtn -pady 2 -padx 2

    if {$uci == 0 || $uci == 1} {
        $w insert end "\n[tr EngineProtocol]:\t"
        ttk::combobox $w.protocol -state readonly -width 12 -values {xboard uci}
        bind $w.protocol <<ComboboxSelected>> $fn_reconnect
        $w window create end -window $w.protocol -pady 2
        $w.protocol set [expr { $uci == 0 ? "xboard" : "uci" }]
    }

    $w insert end "\n[tr EngineNotation]:\t"
    ttk::combobox $w.notation -state readonly -width 12 -values [list engine SAN "English SAN" figurine]
    bind $w.notation <<ComboboxSelected>> "
        ::enginecfg::onChangeLayout $id $configFrame notation \[ $w.notation current \]
    "
    $w window create end -window $w.notation -pady 2
    $w.notation current [expr { $notation < 0 ? 0 - $notation : $notation }]
    ::enginecfg::onChangeLayout $id $configFrame notation $notation

    ttk::checkbutton $w.wrap -text [tr GInfoWrap] -onvalue word -offvalue none -style Toolbutton \
        -command "::enginecfg::onChangeLayout $id $configFrame wrap \[ set ::$w.wrap \]"
    $w window create end -window $w.wrap -pady 2 -padx 6
    set ::$w.wrap $pvwrap

    $w insert end "\n[tr EngineFlipEvaluation]:\t"
    ttk::checkbutton $w.scoreside -style Switch.Toolbutton -onvalue engine -offvalue white \
        -command "::enginecfg::onChangeLayout $id $configFrame scoreside \[::update_switch_btn $w.scoreside \]"
    ::update_switch_btn $w.scoreside $scoreside
    $w window create end -window $w.scoreside -pady 2

    $w insert end "\n[tr EngineShowLog]:\t"
    ttk::checkbutton $w.debug -style Switch.Toolbutton \
        -command "::enginecfg::onChangeLayout $id $configFrame debug \[::update_switch_btn $w.debug \]"
    ::update_switch_btn $w.debug $debugframe
    $w window create end -window $w.debug -pady 2

    if {[catch {::engine::pid $id} enginePid]} {
        return false
    }
    if {$enginePid != ""} {
        $w insert end "\n[tr LowPriority]:\t"
        ttk::checkbutton $w.priority -onvalue idle -offvalue normal \
            -style Switch.Toolbutton -command "
                catch { sc_info priority $enginePid \[ ::update_switch_btn $w.priority \] }
                lset ::enginecfg::engConfig_$id 6 4 \[ ::update_switch_btn $w.priority \]
            "
        ::update_switch_btn $w.priority $priority
        $w window create end -window $w.priority -pady 2
        $w insert end "  pid: $enginePid"
        if {$priority eq "idle"} {
            catch { sc_info priority $enginePid idle }
        }
    }

    $w insert end "\n[tr EngineNetworkd]:\t"
    ttk::combobox $w.netd -state readonly -width 12 -values {off on auto_port}
    $w window create end -window $w.netd -pady 2
    $w insert end "  port: "
    ttk::entry $w.netport -width 6 -validate key -validatecommand { string is integer %P }
    $w window create end -window $w.netport -pady 2
    bind $w.netd <<ComboboxSelected>> "::enginecfg::onSubmitNetd $id $w"
    bind $w.netport <FocusOut> "if {\"readonly\" ni \[$w.netport state\]} {
        ::enginecfg::onSubmitNetd $id $w
    }"
    bind $w.netport <Return> [bind $w.netport <FocusOut>]
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
    }
    $w insert end "\n" netclients_tag

    return true
}

# Creates the widgets used to show/change the engine's specific options
proc ::enginecfg::createOptionWidgets {id configFrame options} {
    set w $configFrame.text

    set tab_width 0
    set disableReset 1
    for {set i 0} {$i < [llength $options]} {incr i} {
        lassign [lindex $options $i] name value type default min max var_list internal
        if {$internal} { continue }

        if {$disableReset} {
            set disableReset 0
            $w insert end "\n"
            ttk::button $w.reset -style Pad0.Small.TButton -text "Reset Options" \
                -command "::enginecfg::onSubmitReset $id $configFrame"
            $w window create end -window $w.reset
        }
        $w insert end "\n$name:" opt_label "\t"
        set label_width [font measure font_Regular -displayof $w "$name: "]
        if {$label_width > $tab_width} {
            set tab_width $label_width
            $w tag configure opt_label -tabs $tab_width
        }
        set btn ""
        if {$type eq "button" || $type eq "save" || $type eq "reset"} {
            set btn $name
        } else {
            if {$type eq "combo"} {
                lassign [lsort -decreasing -integer [lmap elem $var_list { string length $elem }]] maxlen
                ttk::combobox $w.value$i -width [incr maxlen] -values $var_list -state readonly
                bind $w.value$i <<ComboboxSelected>> "::enginecfg::setOptionFromWidget $id $i %W"
            } elseif {$type eq "check"} {
                ttk::checkbutton $w.value$i -onvalue true -offvalue false -style Switch.Toolbutton -command \
                    "::enginecfg::setOption $id $i \[::update_switch_btn $w.value$i \]"
            } else {
                if {$type eq "spin" || $type eq "slider"} {
                    ttk::spinbox $w.value$i -width 12 -from $min -to $max -increment 1 \
                        -validate key -validatecommand { string is integer %P } \
                        -command "after idle \[bind $w.value$i <FocusOut>\] "
                } else {
                    ttk::entry $w.value$i
                    if {$type eq "file"} {
                        set btn "..."
                    } elseif {$type eq "path"} {
                        set btn "+ ..."
                    }
                }
                # Special vars like %W cannot be used in <FocusOut> because the
                # other events are forwarded to it
                bind $w.value$i <FocusOut> "::enginecfg::setOptionFromWidget $id $i $w.value$i"
                bind $w.value$i <Return> [bind $w.value$i <FocusOut>]
            }
            $w window create end -window $w.value$i -pady 2
        }
        if {$btn ne ""} {
            ttk::button $w.button$i -style Pad0.Small.TButton -text $btn \
                -command "::enginecfg::onSubmitButton $id $i"
            $w window create end -window $w.button$i -padx 2 -pady 2
        } elseif {$type eq "spin" || $type eq "slider"} {
            $w insert end " (Range: $min ... $max)"
        }
    }
}

# Update the widgets with the engine's specific options
proc ::enginecfg::updateOptionWidgets {id configFrame options oldOptions} {
    set w $configFrame.text

    set disableReset 1
    for {set i 0} {$i < [llength $options]} {incr i} {
        lassign [lindex $options $i] name value type default min max var_list internal
        if {$internal || $type in [list button save reset]} { continue }

        if {$disableReset && $value ne $default} {
            $w.reset configure -state normal
            set disableReset 0
        }

        if {$oldOptions ne "" && $value eq [lindex $oldOptions $i 1]} {
            if {$type eq "check"} {
                set widget_value [::update_switch_btn $w.value$i]
            } else {
                set widget_value [$w.value$i get]
            }
            if {$value eq $widget_value} { continue }
        }

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
        if {$type eq "combo"} {
            $w.value$i set $value
        } elseif {$type eq "check"} {
            ::update_switch_btn $w.value$i $value
        } else {
            $w.value$i configure -style {}
            $w.value$i delete 0 end
            $w.value$i insert 0 $value
        }
    }
    if {$disableReset && [winfo exists $w.reset]} {
        $w.reset configure -state disabled
    }
}

proc ::enginecfg::updateNetClients {configFrame netclients} {
    set w $configFrame.text

    set strclients "\n"
    if {[llength $netclients]} {
        append strclients "Network Connections:"
        foreach client $netclients {
            append strclients "\t$client\n"
        }
    }
    $w replace netclients_tag.first netclients_tag.last $strclients netclients_tag
}

# Reset all the engine's options to their default values.
proc ::enginecfg::onSubmitReset {id w} {
    upvar ::enginecfg::engConfig_$id engConfig_
    set options {}
    foreach option [lindex $engConfig_ 8] {
        lassign $option name value type default min max var_list internal
        if {! $internal && $value ne $default} {
            lappend options [list $name $default]
        }
    }
    if {[llength $options]} {
        ::engine::send $id SetOptions $options
    }
}

# Invoked to send to the engine a button option that have no value.
# It also used for option of type "file" and type "path": a dialog is showed
# to select the path (a directory path is appended to the previous value).
# Also, for the options of type "file" or "path", the related widget that
# display the value is updated when the engine replies with InfoConfig.
proc ::enginecfg::onSubmitButton {id idx} {
    lassign [lindex [set ::enginecfg::engConfig_$id] 8 $idx] \
        name oldValue type default min max

    if {$type eq "file"} {
        set value [tk_getOpenFile]
        if {$value == ""} { return }
    } elseif {$type eq "path"} {
        set value [tk_chooseDirectory]
        if {$value == ""} { return }
        if {$oldValue ne "" && $oldValue ne "<empty>"} {
            append oldValue [expr {$::windowsOS ? ";" : ":"}]
            set value "$oldValue$value"
        }
    } else {
        set value ""
    }
    ::engine::send $id SetOptions [list [list $name $value]]
}

# Invoke ::engine::netserver to start/stop listening to remote connection.
# If successful it also updates engConfig_$id
# Return the listening port ("" is the engine is not accepting remote connection).
proc ::enginecfg::setupNetd {id netport} {
    set new_value ""
    if {[string match "auto_*" $netport]} {
        set new_value "auto_"
        set netport 0
    }
    set port [::engine::netserver $id $netport]
    append new_value $port
    lset ::enginecfg::engConfig_$id 6 5 $new_value
    return $port
}

# Invoked when the value of one of the netd widgets has changed.
# Invoke ::enginecfg::setupNetd and update the netd widgets accordingly.
proc ::enginecfg::onSubmitNetd {id w} {
    set old_value [lindex [set ::enginecfg::engConfig_$id] 6 5]

    switch [$w.netd get] {
      "auto_port" {
          set netport auto_
          set state readonly
      }
      "on" {
          set netport [$w.netport get]
          set state normal
      }
      default {
          set netport ""
          set state disabled
      }
    }
    $w.netport configure -state normal -style {}
    if {$old_value ne $netport} {
        if {[catch {
            set port [::enginecfg::setupNetd $id $netport]
            $w.netport delete 0 end
            $w.netport insert 0 $port
        }]} {
            $w.netport configure -style Error.TEntry
            ERROR::MessageBox
        }
    }
    $w.netport configure -state $state
}

proc ::enginecfg::onChangeLayout {id configFrame param value} {
    upvar ::enginecfg::engConfig_$id engConfig_
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
        }
        "debug" {
            set idx 3
        }
        default { error "changeLayout unknown $param" }
    }
    lset engConfig_ 6 $idx $value
    event generate $configFrame <<EngineCfgLayout>> -data [list $id $param $value]
}
