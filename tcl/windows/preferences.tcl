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
  grid $w.f.$nr -row 0 -column 1 -sticky news -pady "5 0" -padx "5 0"
  $w xview moveto 0
  $w yview moveto 0
}

proc ::preferences::updateScrollBar { w } {
  set l [winfo reqwidth $w.f]
  set h [winfo reqheight $w.f]
  $w configure -scrollregion [list 0 0 $l $h] -width $l -height $h
}

proc ::preferences::Open { {toggle ""} } {
  set w .preferences
  if {! [::win::createWindow $w "$::menuLabel($::language,ConfigureScid)"]} {
    ::win::makeVisible $w
    return
  }

  ttk::frame $w.options
  ttk::treeview $w.options.list -columns {0} -show {} -selectmode browse
  autoscrollBars y $w.options $w.options.list
  bind $w.options.list <<TreeviewSelect>> "::preferences::replaceConfig \[%W selection\] $w.c"

  ttk::frame $w.config
  canvas $w.c -highlightthickness 0
  ::applyThemeColor_background $w.c
  autoscrollBars both $w.config $w.c
  ttk::frame $w.c.f
  bind $w.c.f <Configure> "::preferences::updateScrollBar $w.c"
  $w.c create window 0 0 -window $w.c.f -anchor nw
  grid columnconfigure $w.c.f 1 -weight 1

  grid $w.options -row 0 -column 0 -sticky news
  grid $w.config -row 0 -column 1 -sticky news
  grid rowconfigure $w 0 -weight 1
  grid columnconfigure $w 1 -weight 1

  ### Add all preference dialogs to this list. Add for every dialog: textlabel proc
  set idx 0
  set configList {}
  lappend configList [tr OptionsBoard] chooseBoardColors
  lappend configList [tr OptionsFonts] ::preferences::fonts
  lappend configList [tr OptionsToolbar] ConfigToolbar
  lappend configList [tr OptionsInternationalization] ::preferences::internationalization
  lappend configList [tr OptionsRecent] ::recentFiles::configure
  lappend configList [tr OptionsSounds] ::utils::sound::OptionsDialog
  lappend configList [tr OptionsMoves] ::preferences::moves
  lappend configList [tr ConfigureInformant] configInformant
  set maxlen 0
  ### create the dialogs
  foreach {m init} $configList {
    $w.options.list insert {} end -id $idx -values [list $m]
    set mlen [font measure font_Regular $m]
    if { $maxlen < $mlen } { set maxlen $mlen }
    ttk::frame $w.c.f.$idx
    $init $w.c.f.$idx
    incr idx
  }
  $w.options.list column 0 -width [incr maxlen 12]
  $w.options.list configure -height $idx

  unset -nocomplain ::preferences::aktConfig
  $w.options.list selection set 0
  focus $w.options
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
    if {[info exists $oldvalue] && $filename eq [set $oldvalue]} {
        return
    }
    grab [winfo toplevel $widget]
    $command "$filename"
}

proc ::preferences::resources {} {
    set w .resDialog
    if { [winfo exists $w] } return

    win::createDialog $w
    ::setTitle $w "Scid Resources"

    # Resource configuration: {varName labelKey validationType browseCmd validateCmd}
    set resourceConfig {
        {::ThemePackageFile          OptionsThemeDir        isfile      getThemePkgFile                       readThemePkgFile}
        {::spellCheckFile            OptionsSpell           isfile      getSpellCheckFile                     readSpellCheckFile}
        {::ecoFile                   OptionsECO             isfile      getECOFile                            readECOFile}
        {::scidBooksDir              OptionsBooksDir        isdirectory getBooksDir                           setBooksDir}
        {::scidBasesDir              OptionsTacticsBasesDir isdirectory getTacticsBasesDir                    setTacticsBasesDir}
        {::scidPhotoDir              OptionsPhotosDir       isdirectory getPhotoDir                           setPhotoDir}
        {::utils::sound::soundFolder SoundsFolder           isdirectory ::utils::sound::GetDialogChooseFolder ::utils::sound::OptionsDialogChooseFolder}
    }

    set row 0
    foreach config $resourceConfig {
        lassign $config varName labelKey valType browseCmd validateCmd
        createResourceEntry $w $row $varName $labelKey $valType $browseCmd $validateCmd
        incr row
    }

    ttk::label $w.folderHelp -text $::tr(SoundsFolderHelp)
    pack $w.folderHelp -side top -anchor w

    wm protocol $w WM_DELETE_WINDOW [list apply {{w} {
        if {[grab current $w] eq $w} {
            destroy $w
        }
    }} $w]
    wm resizable $w 1 0
    grab $w
}

proc ::preferences::createResourceEntry {w row varName labelKey valType browseCmd validateCmd} {
    ttk::label $w.label$row -text "[tr $labelKey]:"
    ttk::frame $w.entry$row
    set entry $w.entry$row.path

    set currentValue ""
    if {[info exists $varName]} {
        set currentValue [set $varName]
    }

    ttk::entry $entry -width 80
    $entry insert end $currentValue

    ttk::button $w.entry$row.browse -text "..." \
        -command [list $browseCmd $entry]

    # Debounce: avoid validating incomplete paths during typing
    set validateCall [list ::preferences::checkFileDir $entry $validateCmd $valType $varName]
    bind $entry <KeyRelease> [list apply {{cmd} {
        after cancel $cmd
        after 200 $cmd
    }} $validateCall]

    pack $w.label$row $w.entry$row -anchor w -fill x
    pack $w.entry$row.browse -side right -padx 2
    pack $entry -side left -padx 2 -fill x -expand yes
}

proc ::preferences::validateautoplay { } {
    global autoplayDelay tempdelay
    if { ! [string is digit $tempdelay] } {
        set tempdelay 1
        return 0
    }
    if { $tempdelay != "" } {
        set autoplayDelay [expr {int($tempdelay * 1000)}]
    }
    if {$autoplayDelay < 0.1} { set autoplayDelay 0.1 }
    return 1
}

# preferences dialog for moves
proc ::preferences::moves { t } {
    global autoplayDelay tempdelay

    set tempdelay [expr {int($autoplayDelay / 1000.0)}]
    ttk::frame $t.ani
    ttk::label $t.ani.al -text [tr OptionsMovesAnimate]
    ttk::label $t.ani.ms -text "ms"
    ttk::combobox $t.ani.animate -width 4 -textvar animateDelay -values {0 100 150 200 250 300 400 500 600 800 1000}
    pack $t.ani.al $t.ani.animate $t.ani.ms -side left -anchor w -padx "0 5"
    ttk::checkbutton $t.omc -variable  moveEntry(Coord) -text [tr OptionsMovesCoord]
    ttk::checkbutton $t.omk -variable  moveEntry(AutoExpand) -text [tr OptionsMovesKey]
    ttk::checkbutton $t.oms -variable  suggestMoves -text [tr OptionsMovesSuggest]
    ttk::checkbutton $t.osv -variable  showVarPopup -text [tr OptionsShowVarPopup]
    ttk::checkbutton $t.osp -variable ::pgn::moveNumberSpaces -text [tr OptionsMovesSpace]
    ttk::checkbutton $t.sva -variable showVarArrows -text [tr OptionsMovesShowVarArrows]
    ttk::checkbutton $t.god -variable glossOfDanger -text [tr OptionsMovesGlossOfDanger] -command updateBoard

    ttk::frame $t.auto
    ttk::label $t.auto.label -text "[tr OptionsMovesDelay]\n$::tr(AnnotateTime:)"
    ttk::spinbox $t.auto.spDelay -width 4 -textvariable tempdelay -from 1 -to 999 -increment 1 \
        -validate all -validatecommand { ::preferences::validateautoplay }
    ttk::labelframe $t.high -text [tr OptionsMovesHighlightLastMove]
    ttk::checkbutton $t.high.hlm -variable ::highlightLastMove -text [tr OptionsMovesHighlightLastMoveDisplay] -command "updateBoard"
    ttk::checkbutton $t.high.arrow -variable ::arrowLastMove -text [tr OptionsMovesHighlightLastMoveArrow] -command "updateBoard"
    ttk::label $t.high.tl -text [tr OptionsMovesHighlightLastMoveWidth]
    ttk::spinbox $t.high.thick -width 2 -textvariable ::highlightLastMoveWidth -from 1 -to 5 -increment 1 \
        -validate key -validatecommand { return [string is digit %S] } -command "updateBoard"
    ttk::button $t.high.color -text $::tr(ColorMarker) -command chooseHighlightColor
    ttk::checkbutton $t.high.nag -variable ::highlightLastMoveNag -text [tr OptionsMovesHighlightLastMoveNag] -command "updateBoard"
    grid $t.high.hlm -row 0 -column 0 -sticky w
    grid $t.high.tl -row 0 -column 1 -padx "10 5"
    grid $t.high.thick -row 0 -column 2
    grid $t.high.color -row 1 -column 2 -pady "2 0"
    grid $t.high.arrow -row 1 -column 0 -columnspan 2 -sticky w
    grid $t.high.nag -row 2 -column 0 -sticky w
    pack $t.auto.label $t.auto.spDelay -side left -padx "0 10" -anchor w
    pack $t.ani $t.omc $t.omk $t.oms $t.osv $t.osp $t.auto $t.sva $t.god -side top -anchor w
    pack $t.high -side top -anchor w -pady "5 0"
}

proc ::preferences::numbers { w } {
    global locale
    set numeric {".,"   ". "   ",."   ", "   "."   ","}
    set locale(numeric) [lindex $numeric [$w current]]
    updateLocale
}

# preferences dialog for internationalization settings
proc ::preferences::internationalization { w } {
    global locale

    ttk::checkbutton $w.tp -variable ::translatePieces -text [tr OptionsMovesTranslatePieces] \
        -command "setLanguage; ::notify::PosChanged pgnonly"
    set numList { }
    set pre ""
    foreach numeric {".,"   ". "   ",."   ", "   "."   ","} {
        set decimal [string index $numeric 0]
        set thousands [string index $numeric 1]
        if { [string length $numeric] < 2 } { set pre " " }
        lappend numList "${pre}12${thousands}345${decimal}67"
        if { $numeric == $locale(numeric) } { set ::newNumbers "12${thousands}345${decimal}67" }
    }
    ttk::frame $w.n
    ttk::label $w.n.nlb -text [tr OptionsNumbers]
    ttk::combobox $w.n.number -width 9 -textvar ::newNumbers -values $numList -state readonly -font font_Fixed
    set popdown [ttk::combobox::PopdownWindow $w.n.number]
    $popdown.f.l configure -font font_Fixed
    bind $w.n.number <<ComboboxSelected>> "::preferences::numbers $w.n.number"
    pack $w.n.nlb $w.n.number -side left -padx "0 5"
    pack $w.n $w.tp  -side top -anchor w
}

# preferences dialog for fonts
proc ::preferences::fonts { w } {
    global locale

    set idx 0
    foreach font { Regular Menu Small Tiny Fixed } {
        set f [string tolower $font]
        ttk::label $w.lb$f -font font_$font -text "[tr OptionsFonts$font]: AaBbCcDdEe 01234"
        ttk::button $w.font$f  -text "..." -command [list apply {{name} {
            set new_options [FontDialog font_$name $::fontOptions($name)]
            if {$new_options != ""} {
                set ::fontOptions($name) $new_options
            }
        }} $font]
        grid $w.lb$f -row $idx -column 0 -sticky w -pady 5
        grid $w.font$f -row $idx -column 1 -sticky w -padx 5 -pady 5
        incr idx
    }
}
