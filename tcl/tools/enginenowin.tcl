###
### enginenowin.tcl: part of Scid.
### This file is part of Scid (Shane's Chess Information Database).
### Copyright (C) 2025 Uwe Klimmek
### uses code from Fulvio Benini https://github.com/benini/chess_accuracy and analysis.tcl
##########################################################################################
### procs for using engines without a engine window

# engineNoWin will be used by annotate and finish game
namespace eval ::engineNoWin {}
# Open the engine and configure it
proc ::engineNoWin::initEngine { id engine callback } {
    if { [info exists ::enginewin::engConfig_$id] } { return 1 }
    set config [::enginecfg::get $engine]
    lassign $config name cmd args wdir elo time url uci options
    set ::enginewin::engConfig_$id $config
    ::engine::setLogCmd $id {}
    ::engine::connect $id $callback $cmd $args
    if { $options ne "" } { ::engine::send $id SetOptions $options }
    return 1
}

proc ::engineNoWin::closeEngine { id } {
    ::engine::close $id
     unset -nocomplain ::enginewin::engConfig_$id
}

proc ::engineNoWin::changeEngine {id w enginevar callback} {
    ::engine::close $id
    $w.text configure -state normal
    $w.text delete 1.0 end
    foreach wchild [winfo children $w.text] { destroy $wchild }
    catch { unset ::enginewin::engConfig_$id }
    set engine [set $enginevar]
    ::engineNoWin::initEngine $id $engine [list $callback $id $w]
}

proc ::engineNoWin::showHideOptionsFrame {id w enginevar callback col} {
    if { [winfo ismapped $w] } { grid forget $w ; return }
    grid $w -row 0 -column $col -rowspan 5 -sticky ne -padx 10
    set engine [set $enginevar]
    ::engineNoWin::initEngine $id $engine [list $callback $id $w]
}

#create frame for select and edit engine options
#engType: all, uci or winboard
proc ::engineNoWin::createEngineOptionsFrame {f id var col callback {engTyp "uci"}} {
    ttk::frame $f.$id
    set allEngList [::enginecfg::names ]
    if { $engTyp ne "all"} {
        set engList {}
        foreach name $allEngList {
            set typ [lindex [::enginecfg::get $name] 7]
            if { $engTyp == "uci" && $typ || $engTyp == "winboard" && ! $typ } {
                lappend engList $name
            }
        }
    } else {
        set engList $allEngList
    }
    if { [set $var] eq "" } { set $var [lindex $engList 0] }
    ttk::combobox $f.$id.eng -width 20 -state readonly -values $engList -textvariable $var
    bind $f.$id.eng <<ComboboxSelected>> "::engineNoWin::changeEngine $id $f.opts$id $var $callback"
    ttk::button $f.$id.opts -image ::icon::filter_adv -style Toolbutton \
        -command "::engineNoWin::showHideOptionsFrame $id $f.opts$id $var $callback $col"
    pack $f.$id.eng $f.$id.opts -side left -padx { 0 5 }
    ttk::labelframe $f.opts$id -text "Engine Parameter"
    ttk::label $f.opts$id.l -textvariable $var
    ttk::button $f.opts$id.x -image tb_close -style Toolbutton -command "grid forget $f.opts$id"
    ttk_text $f.opts$id.text -wrap none -padx 4
    autoscrollBars both $f.opts$id $f.opts$id.text 1
    $f.opts$id.text configure -state normal -wrap word -width 60 -height 18
    ttk::button $f.opts$id.save -text "Save Setup" -command "::engineNoWin::saveEngineSetup $id"
    grid $f.opts$id.l -row 0 -column 0 -sticky w
    grid $f.opts$id.x -row 0 -column 1 -sticky e
    grid $f.opts$id.save -row 2 -column 0 -columnspan 2 -sticky e -pady { 5 0 }
    bind $f.$id <Destroy> "catch { unset ::enginewin::engConfig_$id }; ::engine::close $id"
}

proc ::engineNoWin::initEngineOptions {id w options} {
    upvar ::enginewin::engConfig_$id engConfig_
    if { ! [winfo exists $w.text.reset] } {
        lset ::enginewin::engConfig_$id 8 $options
        ::enginecfg::createOptionWidgets $id $w $options
        ::engine::replyInfoConfig $id
    } else {
        lset ::enginewin::engConfig_$id 8 $options
        ::enginecfg::updateOptionWidgets $id $w $options {}
        $w.text configure -state disabled
    }
}

proc ::engineNoWin::saveEngineSetup { id } {
    upvar ::enginewin::engConfig_$id engConfig_
    ::enginecfg::save [set ::enginewin::engConfig_$id]
}

proc ::engineNoWin::disconnected { id data } {
    upvar ::enginewin::engConfig_$id engConfig_
    lassign $data errorMsg
    lassign [set ::enginewin::engConfig_$id] engine
    if {$errorMsg eq ""} { set errorMsg "The connection with the engine $id $engine terminated unexpectedly." }
    tk_messageBox -icon warning -type ok -parent . -message $errorMsg
}
