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
    return [lsearch -exact -inline -index 0 $::engines(list) $name]
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
proc ::enginecfg::add {enginecfg} {
    lset enginecfg 0 [::enginecfg::uniquename [lindex $enginecfg 0]]
    lappend ::engines(list) $enginecfg
    ::enginecfg::save $enginecfg
    return [lindex $::engines(list) end]
}

# Search a previous configuration with the same name and replace it.
# If necessary write the "Engine list" file.
proc ::enginecfg::save {enginecfg} {
    lassign $enginecfg name
    set idx [lsearch -exact -index 0 $::engines(list) $name]
    if {$idx < 0} {
        return ""
    }
    lset enginecfg 8 [lmap elem [lindex $enginecfg 8] {
        lassign $elem name value type default min max var_list internal
        if {$internal || $value eq $default} { continue }
        list $name $value
    }]
    if {[lindex $::engines(list) $idx] ne $enginecfg} {
        lset ::engines(list) $idx $enginecfg
        ::enginelist::write
    }
    return $enginecfg
}

# Pop up a dialog box for the user to select the cmd file referring to a local engine
# and adds the engine to the list of the available ones.
# Return the new configuration entry in the engine's list.
proc ::enginecfg::dlgNewLocal {} {
    if {$::windowsOS} {
        lappend ftype [list "Executable" [list ".exe" ".bat"]]
    }
    lappend ftype [list "All files" *]
    set fName [tk_getOpenFile -filetypes $ftype]
    if {$fName eq ""} { return "" }
    return [::enginecfg::add [list $fName $fName {} {} {} 0 {} {} {}]]
}

# Pop up a dialog box for the user to enter the url of a remote engine
# and adds the engine to the list of the available ones.
# Return the new configuration entry in the engine's list.
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
        ::enginecfg::save [set ::enginewin::engConfig_$id]
        ::enginewin::connectEngine $id [::enginecfg::get [%W get]]
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
    ttk::button $w.header.delete -image tb_eng_delete -command [list apply {{id widget} {
        $widget configure -values [::enginecfg::names]
        if {[::enginelist::delete [$widget current]]} {
            ::enginewin::connectEngine $id {}
        }
    }} $id $w.header.engine]
    grid $w.header.engine $w.header.addpipe $w.header.addremote \
         $w.header.reload $w.header.clone $w.header.delete -sticky news

    autoscrollText both $w.options $w.options.text Treeview
    $w.options.text configure -wrap none

    grid columnconfigure $w 0 -weight 1
    grid rowconfigure $w 1 -weight 1
    grid $w.header
    grid $w.options -sticky news
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
