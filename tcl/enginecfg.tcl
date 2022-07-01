########################################################################
# Copyright (C) 2020-2022 Fulvio Benini
#
# This file is part of SCID (Shane's Chess Information Database).
# SCID is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.

### Functions and sub-window for chess engine configuration.

namespace eval enginecfg {}

# Return a list containing the engine's names.
proc ::enginecfg::names {} {
    return [lmap elem $::engines(list) { lindex $elem 0 }]
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
    set fName [tk_getOpenFile]
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
