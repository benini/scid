########################################################################
# Copyright (C) 2020-2022 Fulvio Benini
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
    ::enginelist::write
    return $newname
}

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
    ::enginelist::write
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
        ::enginelist::write
    }
    return $enginename
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

# TODO: no references to ::enginewin should exists in this file

# Creates the frame with the widgets necessary to select the desired engine and
# change its configuration.
# It also creates the buttons used to manage the configured engines:
# add a new local or remote engine; reload, clone or delete an existing engine.
proc ::enginecfg::createConfigFrame {id w} {
    ttk::frame $w.header
    ttk::combobox $w.header.engine -state readonly -postcommand "
        $w.header.engine configure -values \[::enginecfg::names \]
    "
    bind $w.header.engine <<ComboboxSelected>> [list apply {{id} {
        ::enginewin::connectEngine $id [%W get]
    }} $id]
    ttk::button $w.header.addpipe -image tb_eng_add -command [list apply {{id} {
        if {[set newEngine [::enginecfg::dlgNewLocal]] ne ""} {
            ::enginewin::connectEngine $id $newEngine
        }
    }} $id]
    ttk::button $w.header.addremote -image tb_eng_network -command [list apply {{id} {
        if {[set newEngine [::enginecfg::dlgNewRemote]] ne ""} {
            ::enginewin::connectEngine $id $newEngine
        }
    }} $id]
    ttk::button $w.header.reload -image tb_eng_reload \
        -command "event generate $w.header.engine <<ComboboxSelected>>"
    ttk::button $w.header.clone -image tb_eng_clone -command "
        ::enginewin::connectEngine $id \[::enginecfg::add \$::enginewin::engConfig_$id \]
    "
    ttk::button $w.header.delete -image tb_eng_delete -command [list apply {{id} {
        lassign [set ::enginewin::engConfig_$id] name
        if {[::enginecfg::remove $name]} {
            ::enginewin::connectEngine $id {}
        }
    }} $id]
    grid $w.header.engine $w.header.addpipe $w.header.addremote \
         $w.header.reload $w.header.clone $w.header.delete -sticky news

    autoscrollText both $w.options $w.options.text Treeview
    $w.options.text configure -wrap none

    grid columnconfigure $w 0 -weight 1
    grid rowconfigure $w 1 -weight 1
    grid $w.header
    grid $w.options -sticky news
}

# Remove all the widgets and display a message in the configFrame
proc ::enginecfg::clearConfigFrame {id configFrame} {
    upvar ::enginewin::engConfig_$id engConfig_
    lassign $engConfig_ name cmd args

    set w $configFrame.options.text
    if {$name eq ""} {
        $configFrame.header.engine set "[tr Engine]:"
        set msg "No engine open: select or add one."
    } else {
        $configFrame.header.engine set $name
        set msg "$cmd $args\nConnecting..."
    }
    $w configure -state normal
    $w delete 1.0 end
    $w insert end $msg
    $w configure -state disabled
}

# Update or recreate the config and option widgets
proc ::enginecfg::updateConfigFrame {id configFrame msgInfoConfig} {
    upvar ::enginewin::engConfig_$id engConfig_
    set w $configFrame.options.text
    lassign $msgInfoConfig protocol netclients options

    # Replace the engine's available options
    set oldOptions [lindex $engConfig_ 8]
    lset engConfig_ 8 $options

    set recreate_widgets 1
    if {$msgInfoConfig eq ""} {
        # An emtpy message -> recreate all the widgets
    } elseif {[lindex $engConfig_ 7] == ""} {
        # A new engine added with auto-config, update the name and protocol
        # and recreate all the widgets
        lassign $engConfig_ currname
        if {[set idx [lsearch -index 0 $options "myname"]] >=0} {
            set name [::enginecfg::rename $currname [lindex $options $idx 1]]
            lset engConfig_ 0 $name

            set ::enginewin_lastengine($id) $name
            ::setTitle .engineWin$id "[tr Engine]: $name"
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
            return
        }
        ::enginecfg::createOptionWidgets $id $configFrame $options
    }
    ::enginecfg::updateOptionWidgets $id $configFrame $options $oldOptions
    ::enginecfg::updateNetClients $configFrame $netclients
    $w configure -state disabled
}

# Creates the widgets for engine configuration, like the engine path, command
# line parameters, uci/xboard protocol, etc...
# It also sets the header.engine combobox to the engine's name.
proc ::enginecfg::createConfigWidgets {id configFrame engCfg} {
    lassign $engCfg name cmd args wdir elo time url uci
    lassign $url scoreside notation pvwrap debugframe priority netport

    set w $configFrame.options.text

    $w delete 1.0 end
    $w configure -tabs [font measure font_Regular "Accept Network Connections:XXXXX"]

    if {$name == ""} {
        ::enginecfg::clearConfigFrame $configFrame
        return false
    }

    set fn_create_entry {{w widget label value} {
        $w insert end "$label:\t"
        ttk::entry $w.$widget
        $w window create end -window $w.$widget
        $w.$widget insert end "$value"
        set wd [string length $value]
        if {$wd < 24} { set wd 24 } elseif {$wd > 60} { set wd 60 }
        $w.$widget configure -width $wd
    }}

    $configFrame.header.engine set "$name"
    apply $fn_create_entry $w name "Engine name" $name
    bind $w.name <FocusOut> [list apply {{id} {
        lassign [set ::enginewin::engConfig_$id] old
        if {$old ne [set name [%W get]]} {
            ::enginecfg::save [set ::enginewin::engConfig_$id]
            ::enginewin::connectEngine $id [::enginecfg::rename $old $name]
        }
    }} $id]
    bind $w.name <Return> [bind $w.name <FocusOut>]

    apply $fn_create_entry $w cmd "\n[tr EngineCmd]" $cmd
    bind $w.cmd <FocusOut> "::enginecfg::onSubmitParam $id cmd \[ %W get \]"
    bind $w.cmd <Return> [bind $w.cmd <FocusOut>]
    ttk::button $w.cmdbtn -style Pad0.Small.TButton -text ... \
        -command "::enginecfg::onSubmitParam $id cmd {} 1"
    $w window create end -window $w.cmdbtn

    apply $fn_create_entry $w args "\n[tr EngineArgs]" $args
    bind $w.args <FocusOut> "::enginecfg::onSubmitParam $id args \[ %W get \]"
    bind $w.args <Return> [bind $w.args <FocusOut>]

    apply $fn_create_entry $w wdir "\n[tr EngineDir]" $wdir
    bind $w.wdir <FocusOut> "::enginecfg::onSubmitParam $id wdir \[ %W get \]"
    bind $w.wdir <Return> [bind $w.wdir <FocusOut>]
    ttk::button $w.wdirbtn -style Pad0.Small.TButton -text ... \
        -command "::enginecfg::onSubmitParam $id wdir {} 2"
    $w window create end -window $w.wdirbtn

    if {$uci == 0 || $uci == 1} {
        $w insert end "\nProtocol:\t"
        ttk::combobox $w.protocol -state readonly -width 12 -values {xboard uci}
        bind $w.protocol <<ComboboxSelected>> "::enginecfg::onSubmitParam $id protocol \[ %W current \]"
        $w window create end -window $w.protocol
        $w.protocol set [expr { $uci == 0 ? "xboard" : "uci" }]
    }

    $w insert end "\nMove lines notation:\t"
    ttk::combobox $w.notation -state readonly -width 12 -values [list engine SAN "English SAN" figurine]
    bind $w.notation <<ComboboxSelected>> "
        ::enginewin::changeDisplayLayout $id notation \[ $w.notation current \]
    "
    $w window create end -window $w.notation
    $w.notation current [expr { $notation < 0 ? 0 - $notation : $notation }]
    ::enginewin::changeDisplayLayout $id notation $notation

    $w insert end "\nScore perspective:\t"
    ttk::combobox $w.scoreside -state readonly -width 12 -values [list engine white]
    bind $w.scoreside <<ComboboxSelected>> "
        ::enginewin::changeDisplayLayout $id scoreside \[ $w.scoreside get \]
    "
    $w window create end -window $w.scoreside
    $w.scoreside set $scoreside

    $w insert end "\nWrap move lines:\t"
    ttk::combobox $w.wrap -state readonly -width 12 -values [list word char none]
    bind $w.wrap <<ComboboxSelected>> "
        ::enginewin::changeDisplayLayout $id wrap \[ $w.wrap get \]
    "
    $w window create end -window $w.wrap
    $w.wrap set $pvwrap

    $w insert end "\nShow debug frame:\t"
    ttk::combobox $w.debug -state readonly -width 12 -values [list false true]
    bind $w.debug <<ComboboxSelected>> "
        ::enginewin::logEngine $id \[ $w.debug get \]
    "
    $w window create end -window $w.debug
    $w.debug set $debugframe

    if {[catch {::engine::pid $id} enginePid]} {
        return false
    }
    if {$enginePid != ""} {
        $w insert end "\nEngine process priority:\t"
        ttk::combobox $w.priority -state readonly -width 12 -values {normal idle}
        bind $w.priority <<ComboboxSelected>> "
            catch { sc_info priority $enginePid \[ $w.priority get \] }
            lset ::enginewin::engConfig_$id 6 4 \[ $w.priority get \]
        "
        $w window create end -window $w.priority
        $w.priority set $priority
        $w insert end "  pid: $enginePid"
        if {$priority eq "idle"} {
            catch { sc_info priority $enginePid idle }
        }
    }

    $w insert end "\nAccept network connections:\t"
    ttk::combobox $w.netd -state readonly -width 12 -values {off on auto_port}
    $w window create end -window $w.netd
    $w insert end "  port: "
    ttk::entry $w.netport -width 6 -validate key -validatecommand { string is integer %P }
    $w window create end -window $w.netport
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
    set w $configFrame.options.text

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
        $w insert end "\n$name\t"
        set btn ""
        if {$type eq "button" || $type eq "save" || $type eq "reset"} {
            set btn $name
        } else {
            if {$type eq "combo"} {
                lassign [lsort -decreasing -integer [lmap elem $var_list { string length $elem }]] maxlen
                ttk::combobox $w.value$i -width [incr maxlen] -values $var_list -state readonly
                bind $w.value$i <<ComboboxSelected>> "::enginecfg::onSubmitOption $id $i %W"
            } elseif {$type eq "check"} {
                ttk::combobox $w.value$i -width 6 -values {false true} -state readonly
                bind $w.value$i <<ComboboxSelected>> "::enginecfg::onSubmitOption $id $i %W"
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
                bind $w.value$i <FocusOut> "::enginecfg::onSubmitOption $id $i $w.value$i"
                bind $w.value$i <Return> [bind $w.value$i <FocusOut>]
            }
            $w window create end -window $w.value$i
        }
        if {$btn ne ""} {
            ttk::button $w.button$i -style Pad0.Small.TButton -text $btn \
                -command "::enginecfg::onSubmitButton $id $i"
            $w window create end -window $w.button$i
        } elseif {$type eq "spin" || $type eq "slider"} {
            $w insert end " (Range: $min ... $max)"
        }
    }
}

# Update the widgets with the engine's specific options
proc ::enginecfg::updateOptionWidgets {id configFrame options oldOptions} {
    set w $configFrame.options.text

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
        if {$type in {combo check}} {
            $w.value$i set $value
        } else {
            $w.value$i delete 0 end
            $w.value$i insert 0 $value
        }

        if {[string equal -nocase $name "multipv"]} {
            ::enginewin::changeDisplayLayout $id multipv [list $i $value $min $max]
        }
    }
    if {$disableReset && [winfo exists $w.reset]} {
        $w.reset configure -state disabled
    }
}

proc ::enginecfg::updateNetClients {configFrame netclients} {
    set w $configFrame.options.text

    set strclients "\n"
    if {[llength $netclients]} {
        append strclients "Network Connections:"
        foreach client $netclients {
            append strclients "\t$client\n"
        }
    }
    $w replace netclients_tag.first netclients_tag.last $strclients netclients_tag
}

# Checks whether the specified connection parameter has been changed, and
# if necessary reconnects the current engine using the new parameters.
proc ::enginecfg::onSubmitParam {id connectParam newValue {opendlg 0}} {
    switch $connectParam {
        "cmd"      { set configIdx 1 }
        "args"     { set configIdx 2 }
        "wdir"     { set configIdx 3 }
        "protocol" { set configIdx 7 }
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

# Reset all the engine's options to their default values.
proc ::enginecfg::onSubmitReset {id w} {
    upvar ::enginewin::engConfig_$id engConfig_
    if {[lindex $engConfig_ 7] != 2} {
        # Local engine: reset options and re-open
        lset engConfig_ 8 {}
        $w.header.reload invoke
        return
    }

    set options {}
    foreach option [lindex engConfig_ 8] {
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
    lassign [lindex [set ::enginewin::engConfig_$id] 8 $idx] \
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


# Read an option's value from widget and if it has changed sends a SetOptions
# message to the engine.
proc ::enginecfg::onSubmitOption {id idx widget} {
    lassign [lindex [set ::enginewin::engConfig_$id] 8 $idx] \
        name oldValue type default min max

    $widget configure -style {}
    set value [$widget get]
    if {$value eq $oldValue} { return }

    if {$value eq ""} {
        set value $default
    } elseif {$min != "" && $max != ""} {
        if {$value < $min || $value > $max} {
            $widget configure -style Error.TSpinbox
            return
        }
    } elseif {![catch { set values [$widget cget -values] }]} {
        if {[set idx [lsearch -exact -nocase $values $value]] != -1} {
            set value [lindex $values $idx]
        } else {
            $widget configure -style Error.TCombobox
            return
        }
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
    lset ::enginewin::engConfig_$id 6 5 $new_value
    return $port
}

# Invoked when the value of one of the netd widgets has changed.
# Invoke ::enginecfg::setupNetd and update the netd widgets accordingly.
proc ::enginecfg::onSubmitNetd {id w} {
    set old_value [lindex [set ::enginewin::engConfig_$id] 6 5]

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
