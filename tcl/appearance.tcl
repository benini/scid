# Copyright (C) 2018  Uwe Klimmek
#
# This file is part of SCID (Shane's Chess Information Database).
#
# SCID is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.
#
# SCID is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with SCID. If not, see <http://www.gnu.org/licenses/>.

# Set Menu colors for Linux and Windows, if customized
proc initMenuColor {} {
  # create fake menu to get the standard colors
  menu .xmenu
  set ::menuColorStandard(activeBackground) [.xmenu cget -activebackground]
  set ::menuColorStandard(background) [.xmenu cget  -background]
  set ::menuColorStandard(selectColor) [.xmenu cget -selectcolor]
  set ::menuColorStandard(activeForeground) [.xmenu cget -activeforeground]
  set ::menuColorStandard(foreground) [.xmenu cget  -foreground]
  set ::menuColorStandard(disabledforeground) [.xmenu cget  -disabledforeground]
  destroy .xmenu
  foreach c [array names ::menuColorStandard] {
    if { [info exists ::menuColor($c)] } {
      option add *Menu.$c $::menuColor($c)
    }
  }
}
if { ! $::macOS } {
  initMenuColor
}

proc chooseMenuColor {c} {
  global menuDialog_
  set col [ tk_chooseColor -initialcolor $::menuDialog_($c) -title "Scid"]
  if { $col != "" } {
      set menuDialog_($c) $col
      .menuOptions.f.menuline0 configure -background $menuDialog_(bg) -foreground $menuDialog_(dfg)
      .menuOptions.f.menuline1 configure -background $menuDialog_(bg) -foreground $menuDialog_(fg)
      .menuOptions.f.menuline2 configure -background $menuDialog_(abg) -foreground $menuDialog_(afg)
      .menuOptions.f.select configure -foreground $menuDialog_(sc)
  }
  raiseWin .menuOptions
  focus .menuOptions.f.bg
}

proc setNewMenuColors { m bg fg abg afg sc dfg } {
  $m configure -background $bg -foreground $fg -selectcolor $sc -activebackground $abg -activeforeground $afg -disabledforeground $dfg
  foreach child [winfo children $m] {
    setNewMenuColors $child $bg $fg $abg $afg $sc $dfg
  }
}

proc setMenuColors {} {
  global menuDialog_
  foreach c { background foreground activeBackground activeForeground selectColor disabledforeground } newc  {bg fg abg afg sc dfg} {
    if { $menuDialog_($newc) != $::menuColorStandard($c) } {
      set ::menuColor($c) $menuDialog_($newc)
    } else {
      unset -nocomplain ::menuColor($c)
    }
    option add *Menu.$c $::menuDialog_($newc)
  }
  setNewMenuColors .menu $menuDialog_(bg) $menuDialog_(fg) $menuDialog_(abg) $menuDialog_(afg) $menuDialog_(sc) $menuDialog_(dfg)

  set w .menuOptions
  catch {grab release $w}
  destroy $w
}

proc resetMenuColors {} {
  global menuDialog_
  foreach c { background foreground activeBackground activeForeground selectColor disabledforeground } newc  {bg fg abg afg sc dfg} {
      set menuDialog_($newc) $::menuColorStandard($c)
  }
  setMenuColors
}

# Menu Color Config
#
#   Dialog window for configuring Menu colors
proc menuConfigDialog {} {
  global menuDialog_
  set menuDialog_(bg)  [.menu cget -background]
  set menuDialog_(fg)  [.menu cget -foreground]
  set menuDialog_(abg) [.menu cget -activebackground]
  set menuDialog_(afg) [.menu cget -activeforeground]
  set menuDialog_(sc)  [.menu cget -selectcolor]
  set menuDialog_(dfg) [.menu cget -disabledforeground]

  set w .menuOptions

  win::createDialog $w
  wm title $w "Scid: [tr OptionsMenuColor]"

  ttk::label $w.status -text ""
  pack [ttk::frame $w.b] -side bottom -fill x
  pack [ttk::frame $w.f] \
      -side top -fill x

  set f $w.f
  set r 0

  foreach c { background foreground activeBackground activeForeground selectColor disabledforeground } newc  {bg fg abg afg sc dfg} {
      if { [info exists ::menuColor($c)] } {
        set menuDialog_($newc) $::menuColor($c)
      } else {
        set menuDialog_($newc) $::menuColorStandard($c)
      }
  }

  ttk::label $f.menuline0 -text "Disabled"  -background $menuDialog_(bg) -foreground $menuDialog_(dfg)
  grid $f.menuline0 -row $r -column 2 -padx 4
  ttk::button $f.dfg -text $::tr(MenuColorForeground) -command { chooseMenuColor dfg }
  grid $f.dfg -row $r -column 3 -padx 4
  incr r
  ttk::button $f.sel -text $::tr(MenuColorSelect) -command { chooseMenuColor sc }
  grid $f.sel -row $r -column 0 -padx 4
  ttk::label $f.select -text "x" -background $menuDialog_(bg) -foreground $menuDialog_(sc)
  grid $f.select -row $r -column 1
  ttk::label $f.menuline1 -text "Menu1" -background $menuDialog_(bg) -foreground $menuDialog_(fg)
  grid $f.menuline1 -row $r -column 2 -padx 4
  ttk::button $f.fg -text $::tr(MenuColorForeground) -command { chooseMenuColor fg }
  grid $f.fg -row $r -column 3 -padx 4 -pady 5
  ttk::button $f.bg -text $::tr(MenuColorBackground) -command { chooseMenuColor bg }
  grid $f.bg -row $r -column 4 -padx 4
  incr r
  ttk::label $f.menuline2 -text "Menu2"  -background $menuDialog_(abg) -foreground $menuDialog_(afg)
  grid $f.menuline2 -row $r -column 2 -padx 4
  ttk::button $f.afg -text $::tr(MenuColorForeground) -command { chooseMenuColor afg }
  grid $f.afg -row $r -column 3 -padx 4
  ttk::button $f.abg -text $::tr(MenuColorBackground) -command { chooseMenuColor abg }
  grid $f.abg -row $r -column 4 -padx 4 -pady 5
  incr r
  addHorizontalRule $w
  dialogbutton $w.b.ok -text OK -command setMenuColors
  dialogbutton $w.b.reset -text $::tr(Defaults) -command { resetMenuColors }
  dialogbutton $w.b.cancel -text $::tr(Cancel) -command [list destroy $w]
  packdlgbuttons $w.b.cancel $w.b.ok $w.b.reset
  bind $w <Return> [list $w.b.ok invoke]
  bind $w <Escape> [list $w.b.cancel invoke]
  bind $w.f <Destroy>  { unset ::menuDialog_ }
  ::utils::win::Centre $w
  wm resizable $w 0 0
  raiseWin $w
  grab $w
  focus $w.f.bg
}

