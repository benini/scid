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
  if {! [::win::createWindow $w "Scid: $::menuLabel($::language,ConfigureScid)"]} {
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
  set configList [list [tr OptionsBoard] chooseBoardColors [tr OptionsMenuColor] ::appearance::menuConfigDialog [tr OptionsToolbar] ConfigToolbar]
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
