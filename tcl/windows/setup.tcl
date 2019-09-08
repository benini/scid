#
# Copyright (C) 2019 Uwe Klimmek
#
# This file is part of Scid (Shane's Chess Information Database).
# Scid is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.

### Preference setup window

namespace eval ::config {}

set config::aktConfig ""

proc ::config::toggle {} {
  set w .config
  if {[winfo exists $w]} {
    ::win::closeWindow $w
  } else {
    ::config::Open
  }
}

### Switch to a new selected preferences dialog from the list
proc ::config::replaceConfig { nr } {
  global ::config::aktConfig
  pack forget $::config::aktConfig 
  set ::config::aktConfig .config.c.f.$nr
  pack $::config::aktConfig -side left -anchor n -padx "10 0" -pady "5 0"
  .config.c.f.configs.list selection clear 0 end
  .config.c.f.configs.list selection set $nr
}

proc ::config::Open {} {
  set w .config
  if {[winfo exists .config]} { return }

  ::createToplevel $w
  ::setTitle $w "Scid: $::menuLabel($::language,ConfigureScid)"
  autoscrollframe -bars both $w canvas $w.c -highlightthickness 0 -background [ttk::style lookup Button.label -background]
  bind $w.c <Configure>  {
         set l [winfo reqwidth %W.f]
         set h [winfo reqheight %W.f]
         %W configure -scrollregion [list 0 0 $l $h] -width $l -height $h
  }
  grid [ttk::frame $w.c.f]
  $w.c create window 0 0 -window $w.c.f -anchor nw
  set w $w.c.f

  ttk::frame $w.configs
  set t $w.configs
  listbox $t.list -width 11 -exportselection 0 -font {{} 11 } -background [ttk::style lookup . -background "" #d9d9d9] -foreground [ttk::style lookup . -foreground "" #202020] -relief flat
  bind $t.list <<ListboxSelect>> { ::config::replaceConfig [.config.c.f.configs.list curselection] }

  ### Add all preference dialogs to this list. Add for every dialog: textlabel proc
  set idx 0
  set configList [list [tr OptionsBoard] chooseBoardColors [tr OptionsMenuColor] ::appearance::menuConfigDialog ] 
  ### create the dialogs
  foreach {m init} $configList {
	$t.list insert end $m 
	ttk::frame $w.$idx
	$init $w.$idx
	incr idx
  }
  $t.list configure -height $idx
  pack $w.configs.list -side left -anchor w -fill y
  pack $w.configs -side left -anchor n -fill y

  replaceConfig 0
  focus $w.configs.list
}
