########################################################################
# Copyright (C) 2020-2022 Fulvio Benini
#
# This file is part of SCID (Shane's Chess Information Database).
# SCID is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.

### Functions and sub-window for chess engine configuration.

namespace eval enginecfg {}


# Creates the frame with the widgets necessary to select the desired engine and
# change its configuration.
# It also creates the buttons used to manage the configured engines:
# add a new local or remote engine; reload, clone or delete an existing engine.
proc ::enginecfg::createConfigFrame {id w} {
    ttk::frame $w.header
    ttk::combobox $w.header.engine -state readonly -postcommand "
        $w.header.engine configure -values \[::enginelist::names \]
    "
    bind $w.header.engine <<ComboboxSelected>> [list apply {{id} {
        ::enginelist::save [set ::enginewin::engConfig_$id]
        ::enginewin::connectEngine $id [::enginelist::get [%W get]]
    }} $id]
    ttk::button $w.header.addpipe -image tb_eng_add -command [list apply {{id} {
        if {[set fName [tk_getOpenFile]] != ""} {
            ::enginewin::connectEngine $id \
                [::enginelist::add [list $fName $fName {} {} {} 0 {} {} {}]]
        }
    }} $id]
    ttk::button $w.header.addnetwork -image tb_eng_network \
        -command "::enginewin::addNetwork $id"
    ttk::button $w.header.reload -image tb_eng_reload \
        -command "event generate $w.header.engine <<ComboboxSelected>>"
    ttk::button $w.header.clone -image tb_eng_clone -command "
        ::enginewin::connectEngine $id \[::enginelist::add \$::enginewin::engConfig_$id \]
    "
    ttk::button $w.header.delete -image tb_eng_delete -command [list apply {{id widget} {
        $widget configure -values [::enginelist::names]
        if {[::enginelist::delete [$widget current]]} {
            ::enginewin::connectEngine $id {}
        }
    }} $id $w.header.engine]
    grid $w.header.engine $w.header.addpipe $w.header.addnetwork \
         $w.header.reload $w.header.clone $w.header.delete -sticky news

    autoscrollText both $w.options $w.options.text Treeview
    $w.options.text configure -wrap none

    grid columnconfigure $w 0 -weight 1
    grid rowconfigure $w 1 -weight 1
    grid $w.header
    grid $w.options -sticky news
}
