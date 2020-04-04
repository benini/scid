#
# Copyright (C) 2019 Uwe Klimmek, Fulvio Benini
#
# This file is part of Scid (Shane's Chess Information Database).
# Scid is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.

### Preference setup window

namespace eval ::preferences {}

### Switch to a new selected preferences dialog from the list
proc ::preferences::replaceConfig { nr w } {
  if {[info exists ::preferences::aktConfig]} {
    grid forget $::preferences::aktConfig
  }
  set ::preferences::aktConfig $w.f.$nr
  grid $w.f.$nr -row 0 -column 1 -sticky news -pady "5 0"
  $w.f.list selection clear 0 end
  $w.f.list selection set $nr
}

proc ::preferences::updateScrollBar { w } {
  set l [winfo reqwidth $w.f]
  set h [winfo reqheight $w.f]
  $w configure -scrollregion [list 0 0 $l $h] -width $l -height $h
}

proc ::preferences::Open { {toggle ""} } {
  set w .preferences
  if {! [::win::createWindow $w "$::menuLabel($::language,ConfigureScid)"]} {
    if {$toggle eq "toggle"} { ::win::closeWindow $w }
    return
  }

  autoscrollframe -bars both $w canvas $w.c -highlightthickness 0
  ::applyThemeColor_background $w.c
  ttk::frame $w.c.f
  bind $w.c.f <Configure> "::preferences::updateScrollBar $w.c"
  $w.c create window 0 0 -window $w.c.f -anchor nw

  set t $w.c.f
  listbox $t.list -width 11 -exportselection 0
  applyThemeStyle Treeview $t.list
  bind $t.list <<ListboxSelect>> "::preferences::replaceConfig \[$t.list curselection\] $w.c"
  grid $t.list -sticky nsw -padx 10 -pady "5 0"
  grid columnconfigure $t 1 -weight 1

  ### Add all preference dialogs to this list. Add for every dialog: textlabel proc
  set idx 0
    set configList [list [tr OptionsBoard] chooseBoardColors [tr OptionsMoves] ::preferences::moves [tr OptionsToolbar] ConfigToolbar [tr OptionsMenuColor] ::appearance::menuConfigDialog [tr ConfigureInformant] configInformant [tr OptionsSounds] ::utils::sound::OptionsDialog]
  set maxlen 0
  ### create the dialogs
  foreach {m init} $configList {
    $t.list insert end $m
    set mlen [string length $m]
    if { $maxlen < $mlen } { set $maxlen $mlen }
    ttk::frame $t.$idx
    $init $t.$idx
    incr idx
  }
  $t.list configure -height $idx -width $maxlen

  unset -nocomplain ::preferences::aktConfig
  replaceConfig 0 $w.c
  focus $t
}

### wrapper function: checking for valid file or directory and changed value then calling the setter function
proc ::preferences::checkFileDir { widget command type oldvalue} {
    global spellCheckFile

    set filename [$widget get]
    if {$filename ne "" && ![file $type $filename]} {
        $widget configure -style Error.TEntry
        return
    }
    $widget configure -style TEntry
    if {$filename eq [set $oldvalue]} {
        return
    }
    grab [winfo toplevel $widget]
    $command "$filename"
}

proc ::preferences::resources { } {
    # Directories
    set w .resDialog
    if { [winfo exists $w] } return

    win::createDialog $w
    ::setTitle $w "Scid Resources"

    set idx 0
    foreach file { ::spellCheckFile ::ecoFile ::scidBooksDir ::scidBasesDir ::scidPhotoDir ::utils::sound::soundFolder } \
        label { OptionsSpell OptionsECO OptionsBooksDir OptionsTacticsBasesDir OptionsPhotosDir SoundsFolder} \
        valtype { isfile isfile isdirectory isdirectory isdirectory isdirectory } \
        command { getSpellCheckFile getECOFile getBooksDir getTacticsBasesDir getPhotoDir ::utils::sound::GetDialogChooseFolder } \
        checkvaluecommand { readSpellCheckFile readECOFile setBooksDir setTacticsBasesDir setPhotoDir ::utils::sound::OptionsDialogChooseFolder } {
        incr idx
        ttk::label $w.$file -text [tr $label]:
        ttk::frame $w.$idx
        set temp ""
        if { [info exists $file] } { set temp [set $file] }
        ttk::entry $w.$idx.file -width 80
        $w.$idx.file insert end $temp
        ttk::button $w.$idx.b -text "..." -command "$command $w.$idx.file"
        $w.$idx.file configure -validate key -validatecommand "
              after cancel ::preferences::checkFileDir $w.$idx.file $checkvaluecommand $valtype $file
              after 200 ::preferences::checkFileDir $w.$idx.file $checkvaluecommand $valtype $file
              return true"
        pack $w.$file $w.$idx -anchor w -fill x
        pack $w.$idx.b -side right -padx 2
        pack $w.$idx.file -side left -padx 2 -fill x -expand yes
    }
    ttk::label $w.folderHelp -text $::tr(SoundsFolderHelp)
    pack $w.folderHelp -side top -anchor w

    # Prompt user to select a tablebase file; all the files in its
    # directory will be used.
    ttk::label $w.title -text [tr OptionsTablebaseDir]
    pack $w.title -side top -fill x -pady "10 0"
    foreach i {1 2 3 4} {
        pack [ttk::frame $w.f$i] -side top -fill x -expand yes
        ttk::entry $w.f$i.e -width 80
        $w.f$i.e insert end $::initialDir(tablebase$i)
        $w.f$i.e configure -validate key -validatecommand "
              after cancel ::openTableBaseDirs $i $w.f$i.e
              after 200 ::openTableBaseDirs $i $w.f$i.e
              return true"
        ttk::button $w.f$i.b -text "..." -command "chooseTableBaseDir $w.f$i.e"

        pack $w.f$i.b -side right -padx 2
        pack $w.f$i.e -side left -padx 2 -fill x -expand yes
    }

    wm resizable $w 1 0
    grab $w
}

# preferences dialog for moves
proc ::preferences::moves { w } {
    global autoplayDelay tempdelay

    set tempdelay [expr {int($autoplayDelay / 1000.0)}]
    set t $w
    ttk::frame $t.ani
    ttk::label $t.ani.al -text [tr OptionsMovesAnimate]
    ttk::label $t.ani.ms -text "ms"
    ttk::combobox $t.ani.animate -width 4 -textvar animateDelay -values {0 100 150 200 250 300 400 500 600 800 1000}
    pack $t.ani.al $t.ani.animate $t.ani.ms -side left -anchor w -padx "0 5"
    ttk::checkbutton $t.oma -variable askToReplaceMoves -text [tr OptionsMovesAsk]
    ttk::checkbutton $t.omc -variable  moveEntry(Coord) -text [tr OptionsMovesCoord]
    ttk::checkbutton $t.omk -variable  moveEntry(AutoExpand) -text [tr OptionsMovesKey]
    ttk::checkbutton $t.oms -variable  suggestMoves -text [tr OptionsMovesSuggest]
    ttk::checkbutton $t.osv -variable  showVarPopup -text [tr OptionsShowVarPopup]
    ttk::checkbutton $t.osp -variable ::pgn::moveNumberSpaces -text [tr OptionsMovesSpace]
    ttk::checkbutton $t.tp -variable ::translatePieces -text [tr OptionsMovesTranslatePieces]
    ttk::checkbutton $t.sva -variable showVarArrows -text [tr OptionsMovesShowVarArrows]
    ttk::checkbutton $t.god -variable glossOfDanger -text [tr OptionsMovesGlossOfDanger] -command updateBoard

    ttk::frame $t.auto
    ttk::label $t.auto.label -text "[tr OptionsMovesDelay]\n$::tr(AnnotateTime:)"
    ttk::spinbox $t.auto.spDelay -width 4 -textvariable tempdelay -from 1 -to 999 -increment 1 \
        -validate key -validatecommand { return [string is digit %S] }
    ttk::labelframe $t.high -text [tr OptionsMovesHighlightLastMove]
    ttk::checkbutton $t.high.hlm -variable ::highlightLastMove -text [tr OptionsMovesHighlightLastMoveDisplay]
    ttk::checkbutton $t.high.arrow -variable ::arrowLastMove -text [tr OptionsMovesHighlightLastMoveArrow]
    ttk::label $t.high.tl -text [tr OptionsMovesHighlightLastMoveWidth]
    ttk::spinbox $t.high.thick -width 2 -textvariable ::highlightLastMoveWidth -from 1 -to 5 -increment 1 \
        -validate key -validatecommand { return [string is digit %S] }
    ttk::button $t.high.color -text $::tr(ColorMarker) -command chooseHighlightColor
    grid $t.high.hlm -row 0 -column 0 -sticky w
    grid $t.high.tl -row 0 -column 1 -padx "10 5"
    grid $t.high.thick -row 0 -column 2
    grid $t.high.color -row 1 -column 2 -pady "2 0"
    grid $t.high.arrow -row 1 -column 0 -columnspan 2 -sticky w
    pack $t.auto.label $t.auto.spDelay -side left -padx "0 10" -anchor w
    pack $t.oma $t.ani $t.omc $t.omk $t.oms $t.osv $t.osp $t.tp $t.auto $t.sva $t.god -side top -anchor w
    pack $t.high -side top -anchor w -pady "5 0"
}
