########################################################################
### Games list window
# Copyright (C) 2011-2013 Fulvio Benini
#
# This file is part of Scid (Shane's Chess Information Database).
# Scid is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.

proc ::windows::gamelist::Open { {reuse "false"} {base ""} {filter "dbfilter"} } {
	if { $reuse != "false" } {
		# use a clipbase window
		foreach glwin $::windows::gamelist::wins {
			set b [::windows::gamelist::GetBase $glwin]
			if { [sc_base filename $b] == {[clipbase]} && [sc_base numGames $b] == 0 } {
				if {[info exists ::recentSort]} {
					set idx [lsearch -exact $::recentSort "[sc_base filename $base]"]
					if {$idx != -1} {
						set ::glist_Sort(ly$glwin) [lindex $::recentSort [expr $idx +1]]
						::windows::gamelist::createGList_ $glwin
					}
				}
				::windows::gamelist::SetBase $glwin $base $filter
				##TODO: this is a hack to raise the gamelist window
				createToplevel $glwin
				return
			}
		}
	}

	set i 1
	set closeto ""
	while {[winfo exists .glistWin$i]} {
		set closeto .glistWin$i
		incr i
	}
	set w .glistWin$i
	::createToplevel $w $closeto

	set ::gamelistTitle($w) "[tr WindowsGList]:"
	if {$base == ""} { set base [sc_base current] }
	::windows::gamelist::createWin_ $w $base $filter
}

proc ::windows::gamelist::OpenTreeBest { {base} {w} } {
	if {[::createToplevel $w] == "already_exists"} {
		focus .
		destroy $w
		return
	}
	set ::gamelistTitle($w) "[tr TreeBestGames]:"
	::windows::gamelist::createWin_ $w $base "tree"
}

proc ::windows::gamelist::Refresh {{moveup 1} {wlist ""}} {
	if {$wlist == ""} { set wlist $::windows::gamelist::wins }
	foreach w $wlist {
		set err [catch {sc_base inUse $::gamelistBase($w)} inUse]
		if {$err !=0 || $inUse == 0} {
			::windows::gamelist::SetBase $w [sc_base current]
			continue
		}
		::windows::gamelist::update_ $w $moveup
	}
}

proc ::windows::gamelist::PosMaskProgress {} {
	update
	if { $::gamelistUpdating != 1 } { break }
}

proc ::windows::gamelist::PosChanged {{wlist ""}} {
	if { [info exists ::gamelistUpdating] } {
		incr ::gamelistUpdating
		return
	}
	set ::gamelistUpdating 1

	set bases {}
	if {$wlist == ""} { set wlist $::windows::gamelist::wins }
	foreach w $wlist {
		if { $::gamelistPosMask($w) != 0 } {
			$w.games.glist tag configure fsmall -foreground #bababa
			$w.buttons.boardFilter configure -image tb_BoardMaskBusy
			if { [lsearch -exact $bases $::gamelistBase($w)] == -1 } {
				lappend bases $::gamelistBase($w)
			}
		}
	}
	foreach base $bases {
		set f [sc_base newFilter $base FEN]
		if { $::gamelistUpdating != 1 } {
			after idle {
				unset ::gamelistUpdating
				::windows::gamelist::PosChanged
			}
			return
		}
		if {$f != ""} {
			foreach w $::windows::gamelist::wins {
				if { $::gamelistBase($w) == $base && $::gamelistPosMask($w) != 0 } {
					$w.games.glist tag configure fsmall -foreground ""
					$w.buttons.boardFilter configure -image tb_BoardMask
					set ::gamelistFilter($w) [sc_filter link $::gamelistBase($w) $::gamelistFilter($w) $f]
					::windows::gamelist::Refresh 1 $w
					notify::DatabaseChanged 0
				}
			}
		}
	}
	unset ::gamelistUpdating
}

# Returns text describing state of filter for specified
# database, e.g. "no games" or "all / 400" or "1,043 / 2,057"
proc ::windows::gamelist::filterText {{w ""} {base 0}} {
	if {$base == 0} { set base [sc_base current] }
	set gameCount [sc_base numGames $base]
	if {$gameCount == 0} { return $::tr(noGames) }
	set f "dbfilter"
	if {$w != "" && $base == $::gamelistBase($w)}  {
		set f $::gamelistFilter($w)
	}
	set filterCount [sc_filter size $base $f]
	if {$gameCount == $filterCount} {
		return "$::tr(all) / [::utils::thousands $gameCount 100000]"
	}
	return "[::utils::thousands $filterCount 100000] / [::utils::thousands $gameCount 100000]"
}

proc ::windows::gamelist::GetBase {{w}} {
	if {[info exists ::gamelistBase($w)]} { return $::gamelistBase($w) }
	return ""
}

proc ::windows::gamelist::SetBase {{w} {base} {filter "dbfilter"}} {
	if {[lsearch -exact $::windows::gamelist::wins $w] == -1} { return }
	set ::gamelistBase($w) $base
	set ::gamelistFilter($w) $filter
	busyCursor $w
	update idletasks
	if { $::gamelistPosMask($w) != 0 } {
		::windows::gamelist::PosChanged $w
	} else {
		::windows::gamelist::Refresh 1 $w
	}
	unbusyCursor $w
}

proc ::windows::gamelist::CopyGames {{w} {srcBase} {dstBase}} {
	set filter "dbfilter"
	if {$w != "" && $srcBase == $::gamelistBase($w)} { set filter $::gamelistFilter($w) }

	set fromName [file tail [sc_base filename $srcBase]]
	set targetName [file tail [sc_base filename $dstBase]]
	set nGamesToCopy [sc_filter size $srcBase $filter]
	set targetReadOnly [sc_base isReadOnly $dstBase]
	set err ""
	if {$nGamesToCopy == 0} {
		set err "$::tr(CopyErrSource) $::tr(CopyErrNoGames)."
	} elseif {$targetReadOnly} {
		set err "$::tr(CopyErrTarget) ($targetName) $::tr(CopyErrReadOnly)."
	}
	if {$err != ""} {
		tk_messageBox -type ok -icon info -title "Scid" \
			-message "$::tr(CopyErr) \n\"$fromName\" -> \"$targetName\": \n$err"
		return
	}
	# If copying to the clipbase, do not bother asking for confirmation:
	if {$dstBase != [sc_info clipbase]} {
		set confirm [tk_messageBox -type "okcancel" -icon question -title "Scid: $::tr(CopyGames)" \
			-message [subst $::tr(CopyConfirm)] ]
		if {$confirm != "ok"} { return }
	}

	progressWindow "Scid" "$::tr(CopyGames)..." $::tr(Cancel) "sc_progressBar"
	set copyErr [catch {sc_base copygames $srcBase $filter $dstBase} result]
	closeProgressWindow
	if {$copyErr} {
		tk_messageBox -type ok -icon info -title "Scid" -message $result
	}
	::notify::DatabaseChanged
}


#Private:
set ::windows::gamelist::wins {}

proc ::windows::gamelist::createWin_ { {w} {base} {filter} } {
	set ::gamelistBase($w) $base
	set ::gamelistFilter($w) $filter
	set ::gamelistPosMask($w) 0
	set ::gamelistMenu($w) ""
	standardShortcuts $w
	if {$filter != "tree"} { ::windows::gamelist::createMenu_ $w }
	if {[info exists ::recentSort]} {
		set idx [lsearch -exact $::recentSort "[sc_base filename $base]"]
		if {$idx != -1} { set ::glist_Sort(ly$w) [lindex $::recentSort [expr $idx +1]] }
	}
	::windows::gamelist::createGList_ $w
	grid rowconfigure $w 0 -weight 1
	grid columnconfigure $w 0 -weight 0
	grid columnconfigure $w 1 -weight 0
	grid columnconfigure $w 2 -weight 1
	bind $w <Destroy> {
		if { [winfo class %W] == "Toplevel" } {
			set idx [lsearch -exact $::windows::gamelist::wins %W]
			set ::windows::gamelist::wins [lreplace $::windows::gamelist::wins $idx $idx]
			sc_filter release $::gamelistBase(%W) $::gamelistFilter(%W)
		}
	}
	setWinLocation $w
	setWinSize $w
	bind $w <Configure> "recordWinSize $w"
	createToplevelFinalize $w
	lappend ::windows::gamelist::wins $w
	::windows::gamelist::SetBase $w $base $filter
}

proc ::windows::gamelist::createMenu_ {w} {
	ttk::frame $w.buttons -padding {5 5 2 5}
	ttk::button $w.buttons.database -image tb_CC_book -command "::windows::gamelist::menu_ $w database"
	ttk::button $w.buttons.filter -image tb_search_on -command "::windows::gamelist::menu_ $w filter"
	ttk::button $w.buttons.layout -image tb_Layout -command "::windows::gamelist::menu_ $w layout"
	ttk::button $w.buttons.boardFilter -image tb_BoardMask -command "::windows::gamelist::searchpos_ $w"
	#TODO:
	#ttk::button $w.buttons.stats -image b_bargraph
	#TODO: translate
	::utils::tooltip::Set $w.buttons.database "Show/Hide databases"
	::utils::tooltip::Set $w.buttons.filter "Change filter"
	::utils::tooltip::Set $w.buttons.layout "Load/Save/Change sorting criteria and column layout"
	::utils::tooltip::Set $w.buttons.boardFilter "Show only games that matches the current board position"
	grid $w.buttons.database -row 0
	grid $w.buttons.filter  -row 1
	grid $w.buttons.layout  -row 2
	grid $w.buttons.boardFilter  -row 3
	#grid $w.buttons.stats -row 4
	grid $w.buttons -row 0 -column 0 -sticky news

	ttk::frame $w.database -padding {0 5 6 2}
	::windows::switcher::Create $w.database $w

	ttk::frame $w.filter -padding {0 5 6 2}
	ttk::frame $w.filter.b -borderwidth 2 -relief groove
	grid $w.filter.b -sticky news
	grid rowconfigure $w.filter 0 -weight 1
	grid columnconfigure $w.filter 0 -weight 1
	button $w.filter.b.rfilter -image tb_rfilter -command "::windows::gamelist::filter_ $w r" -width 24 -height 24
	button $w.filter.b.bsearch -image tb_bsearch -command "::windows::gamelist::filter_ $w b" -width 24 -height 24
	button $w.filter.b.hsearch -image tb_hsearch -command "::windows::gamelist::filter_ $w h" -width 24 -height 24
	button $w.filter.b.msearch -image tb_msearch -command "::windows::gamelist::filter_ $w m" -width 24 -height 24
	button $w.filter.b.tmt -image tb_tmt -command ::tourney::toggle -width 40 -height 24
	button $w.filter.b.crosst -image tb_crosst -command toggleCrosstabWin -width 40 -height 24
	#TODO: rewrite the tooltip system (most tooltip are not translated when you change language)
	::utils::tooltip::Set "$w.filter.b.rfilter" "$::helpMessage($::language,SearchReset)"
	::utils::tooltip::Set "$w.filter.b.bsearch" "$::helpMessage($::language,SearchCurrent)"
	::utils::tooltip::Set "$w.filter.b.hsearch" "$::helpMessage($::language,SearchHeader)"
	::utils::tooltip::Set "$w.filter.b.msearch" "$::helpMessage($::language,SearchMaterial)"
	::utils::tooltip::Set "$w.filter.b.tmt" "$::helpMessage($::language,WindowsTmt)"
	::utils::tooltip::Set "$w.filter.b.crosst" "$::helpMessage($::language,ToolsCross)"
	grid $w.filter.b.rfilter $w.filter.b.bsearch $w.filter.b.hsearch $w.filter.b.msearch \
		$w.filter.b.tmt $w.filter.b.crosst
	#TODO: translate labels
	ttk::labelframe $w.filter.b.click -text "Double-click"
	set bgcolor [ttk::style lookup Button.label -background]
	radiobutton $w.filter.b.click.l -text $::tr(LoadGame) -font font_Tiny -background $bgcolor -variable ::glistClickOp($w.games.glist) -value 0
	radiobutton $w.filter.b.click.d -text "(Un)Delete Game" -font font_Tiny -background $bgcolor -variable ::glistClickOp($w.games.glist) -value 1
	radiobutton $w.filter.b.click.r -text "Remove from filter" -font font_Tiny -background $bgcolor -variable ::glistClickOp($w.games.glist) -value 2
	grid $w.filter.b.click.l -sticky w
	grid $w.filter.b.click.d -sticky w
	grid $w.filter.b.click.r -sticky w
	grid $w.filter.b.click -columnspan 6 -sticky news

	ttk::frame $w.layout -padding {0 5 6 2}
	ttk::frame $w.layout.b -borderwidth 2 -relief groove
	grid $w.layout.b -sticky news
	grid rowconfigure $w.layout 0 -weight 1
	grid columnconfigure $w.layout 0 -weight 1
	::glist_Ly::Create $w
}

proc ::windows::gamelist::createGList_ {{w}} {
	if {[winfo exists $w.games]} { destroy $w.games }
	ttk::frame $w.games -borderwidth 0 -padding {8 5 5 2}
	glist.create $w.games "ly$w"
	grid $w.games -row 0 -column 2 -sticky news
}

proc ::windows::gamelist::menu_ {{w} {button}} {
	if {$::gamelistMenu($w) != ""} {
		$w.buttons.$::gamelistMenu($w) state !pressed
		grid forget $w.$::gamelistMenu($w)
	}
	if {$::gamelistMenu($w) != $button} {
		$w.buttons.$button state pressed
		set ::gamelistMenu($w) $button
		grid $w.$button -row 0 -column 1 -sticky news
	} else {
		set ::gamelistMenu($w) ""
	}
}

proc ::windows::gamelist::filter_ {{w} {type}} {
	if {$type == "r"} {
		::search::filter::reset $::gamelistBase($w)
	} elseif {$type == "b"} {
		::search::board $::gamelistBase($w)
	} elseif {$type == "h"} {
		::search::header $::gamelistBase($w) $::gamelistFilter($w)
	} elseif {$type == "m"} {
		::search::material $::gamelistBase($w)
	}
}

proc ::windows::gamelist::update_ {{w} {moveUp}} {
	set fr [::windows::gamelist::filterText $w $::gamelistBase($w)]
	set fn [file tail [sc_base filename $::gamelistBase($w)]]
	::setTitle $w "$::gamelistTitle($w) $fn ($fr)"
	if {$moveUp} {
		#Reset double-click behavior
		set ::glistClickOp($w.games.glist) 0
	}
	glist.update $w.games $::gamelistBase($w) $::gamelistFilter($w) $moveUp
}

proc ::windows::gamelist::searchpos_ {{w}} {
	if {$::gamelistPosMask($w) == 0} {
		set ::gamelistPosMask($w) 1
		$w.buttons.boardFilter state pressed
		::windows::gamelist::PosChanged $w
	} else {
		set ::gamelistPosMask($w) 0
		$w.buttons.boardFilter state !pressed
		set ::gamelistFilter($w) [sc_filter link $::gamelistBase($w) $::gamelistFilter($w)]
		$w.games.glist tag configure fsmall -foreground ""
		$w.buttons.boardFilter configure -image tb_BoardMask
		::windows::gamelist::Refresh 1 $w
		notify::DatabaseChanged 0
	}
}

namespace eval ::glist_Ly {
	proc Create {w} {
		if {! [info exists ::glist_Layouts] } { set ::glist_Layouts {} }
		options.save ::glist_Layouts
		set ::gamelistNewLayout [::glist_Ly::createName_]
		set bgcolor [ttk::style lookup Button.label -background]
		autoscrollframe -bars y $w.layout.b canvas $w.layout.b.c -highlightthickness 0 -background $bgcolor
		bind $w.layout.b.c <Configure>  { ::glist_Ly::AdjScrollbar_ %W }
		::glist_Ly::Update_ $w
	}
	proc UpdateAll_ {} {
		foreach w $::windows::gamelist::wins {
		    if {[winfo exists $w]} { Update_ $w }
		}
	}
	proc Update_ {w} {
		if {[winfo exists $w.layout.b.c.f]} { destroy $w.layout.b.c.f}
		ttk::frame $w.layout.b.c.f -padding 5
		$w.layout.b.c create window 0 0 -window $w.layout.b.c.f -anchor nw
		tk::entry $w.layout.b.c.f.text_new -textvariable ::gamelistNewLayout -font font_Small
		tk::button $w.layout.b.c.f.new -image tb_new -command "::glist_Ly::New_ $w"
		grid $w.layout.b.c.f.text_new $w.layout.b.c.f.new
		ttk::frame $w.layout.b.c.f.sep -padding { 0 4 0 4 }
		ttk::separator $w.layout.b.c.f.sep.line
		grid rowconfigure $w.layout.b.c.f.sep 0 -weight 1
		grid columnconfigure $w.layout.b.c.f.sep 0 -weight 1
		grid $w.layout.b.c.f.sep.line -sticky news
		grid $w.layout.b.c.f.sep -columnspan 2 -sticky we
		for {set i 0} {$i < [llength $::glist_Layouts]} {incr i} {
			set name [lindex $::glist_Layouts $i]
			tk::button $w.layout.b.c.f.layout$i -text $name -font font_Small -width 20 -command "::glist_Ly::Change_ $w $i" -bg lightSteelBlue
			tk::button $w.layout.b.c.f.layoutDel$i -image tb_CC_delete -command "::glist_Ly::Del_ $w $i"
			grid $w.layout.b.c.f.layout$i $w.layout.b.c.f.layoutDel$i -sticky we
		}
		after idle "::glist_Ly::AdjScrollbar_ $w.layout.b.c"
	}
	proc New_ {w} {
		set newLy $::gamelistNewLayout
		Copy_ $newLy ly$w
		options.save ::glist_ColOrder($newLy)
		options.save ::glist_ColWidth($newLy)
		options.save ::glist_ColAnchor($newLy)
		options.save ::glist_Sort($newLy)
		options.save ::glist_FindBar($newLy)
		set replaced [lsearch -exact $::glist_Layouts $newLy]
		if {$replaced == -1 }  { lappend ::glist_Layouts $newLy }
		set ::gamelistNewLayout [::glist_Ly::createName_]
		::glist_Ly::UpdateAll_
	}
	proc Del_ {w idx} {
		set old_layout [lindex $::glist_Layouts $idx]
		options.save_cancel ::glist_ColOrder($old_layout)
		options.save_cancel ::glist_ColWidth($old_layout)
		options.save_cancel ::glist_ColAnchor($old_layout)
		options.save_cancel ::glist_Sort($old_layout)
		options.save_cancel ::glist_FindBar($old_layout)
  		set ::glist_Layouts [lreplace $::glist_Layouts $idx $idx]
		::glist_Ly::UpdateAll_
	}
	proc Change_ {w idx} {
		Copy_ ly$w [lindex $::glist_Layouts $idx]
		::windows::gamelist::createGList_ $w
		::windows::gamelist::update_ $w 1
	}
	proc Copy_ {{oldLy} {newLy}} {
		set ::glist_ColOrder($oldLy) $::glist_ColOrder($newLy)
		set ::glist_ColWidth($oldLy) $::glist_ColWidth($newLy)
		set ::glist_ColAnchor($oldLy) $::glist_ColAnchor($newLy)
		set ::glist_Sort($oldLy) $::glist_Sort($newLy)
		set ::glist_FindBar($oldLy) $::glist_FindBar($newLy)
	}
	proc createName_ {} {
		set i 1
		set prefix "NewLayout"
		while {[lsearch -exact $::glist_Layouts "$prefix$i"] != -1} { incr i }
		return "$prefix$i"
	}
	proc AdjScrollbar_ {w} {
		set l [winfo reqwidth $w.f]
		set h [winfo reqheight $w.f]
		$w configure -scrollregion [list 0 0 $l $h] -width $l
	}
}





##########################################################################
# June 2011: A new reusable and simplified gamelist widget
# glist.create
#   Create a gamelist widget
#   w: parent window of the gamelist widget
#   layout: a string name that will be assigned to columns layout.
#           layout will be saved and restored in successive glist.create calls.
proc glist.create {{w} {layout}} {
  # Default values
  if {! [info exists ::glist_ColOrder($layout)] } {
    set ::glist_ColOrder($layout) {{7} {1} {2} {3} {4} {5} {6} {23} {22} {8} {9} {10} {11} {12} {13} {14} {15} {16} {0}}
  }
  if {! [info exists ::glist_ColWidth($layout)] } {
    set ::glist_ColWidth($layout) {{50} {50} {50} {120} {40} {120} {40} {80} {200} {30} \
        {200} {30} {20} {20} {20} {20} {35} {50} {30} {100} {40} {40} {50} {140}}
  }
  if {! [info exists ::glist_ColAnchor($layout)] } {
    set ::glist_ColAnchor($layout) {{e} {c} {c} {w} {c} {w} {c} {w} {w} {e} \
        {w} {c} {c} {c} {c} {c} {c} {c} {c} {c} {c} {c} {c} {w}}
  }
  if {! [info exists ::glist_Sort($layout)] } {
    set ::glist_Sort($layout) { {22} {-} {7} {-} }
  }
  if {! [info exists ::glist_FindBar($layout)] } {
    set ::glist_FindBar($layout) 1
  }

  ttk::treeview $w.glist -columns $::glist_Headers -show headings -selectmode browse
  $w.glist tag configure current -background lightSteelBlue
  $w.glist tag configure fsmall -font font_Small
  $w.glist tag configure deleted -foreground #a5a2ac
  menu $w.glist.header_menu
  menu $w.glist.header_menu.addcol
  menu $w.glist.game_menu
  bind $w.glist <Configure> {
    after cancel glist.chkVisibleLn_ %W
    after 100 glist.chkVisibleLn_ %W
  }
  bind $w.glist <2> "glist.popupmenu_ %W %x %y %X %Y $layout"
  bind $w.glist <3> "glist.popupmenu_ %W %x %y %X %Y $layout"
  bind $w.glist <ButtonRelease-1> "glist.release_ %W %x %y $layout"
  bind $w.glist <Double-ButtonRelease-1> "glist.doubleclick_ %W %x %y $layout"
  bind $w.glist <KeyPress-Up> {glist.movesel_ %W prev -1 0; break}
  bind $w.glist <KeyPress-Down> {glist.movesel_ %W next +1 end; break}
  bind $w.glist <KeyPress-Right> {continue}
  bind $w.glist <KeyPress-Left> {continue}
  bind $w.glist <KeyPress-Prior> {glist.ybar_ %W scroll -1 pages; break}
  bind $w.glist <KeyPress-Next> {glist.ybar_ %W scroll 1 pages; break}
  bind $w.glist <KeyPress-Return> {
    foreach {idx ply} [split [%W selection] "_"] {}
    if {[info exists idx]} {
      ::file::SwitchToBase $::glistBase(%W) 0
      ::game::Load $idx $ply
    }
    break
  }
  bind $w.glist <Delete> {
    foreach {idx ply} [split [%W selection] "_"] {}
    if {[info exists idx]} {
      glist.delflag_ %W $idx
      glist.movesel_ %W next +1 end
    }
    break
  }
  bind $w.glist <Control-Delete> {
    foreach {idx ply} [split [%W selection] "_"] {}
    if {[info exists idx]} {
      glist.movesel_ %W next +1 end;
      sc_filter set $::glistBase(%W) $::glistFilter(%W) 0 $idx
      ::notify::DatabaseChanged 0
    }
    break
  }
  bind $w.glist <Destroy> "glist.destroy_ $w.glist"

  set i 0
  foreach col $::glist_Headers {
    $w.glist heading $col -text $::tr($col)
    $w.glist column $col -stretch 0 \
             -width [lindex $::glist_ColWidth($layout) $i]\
             -anchor [lindex $::glist_ColAnchor($layout) $i]
    incr i
  }
  $w.glist configure -displaycolumns $::glist_ColOrder($layout)

  autoscrollframe -bars both $w "" $w.glist
  set ::glistYScroll($w.glist) [$w.glist cget -yscrollcommand]
  $w.glist configure -yscrollcommand "glist.yscroll_ $w.glist"
  $w.ybar configure -command "glist.ybar_ $w.glist"
  bind $w.ybar <ButtonRelease-1> "+glist.ybar_ $w.glist buttonrelease"
  bindMouseWheel $w.glist "glist.ybar_ $w.glist"

  # Find widget
  ttk::frame $w.find
  ttk::button $w.find.hide -image tb_close
  bind $w.find.hide <ButtonPress-1> "set ::glist_FindBar($layout) 0; grid forget $w.find"
  ttk::frame $w.find.n
  ttk::label $w.find.t_gnum -text $::tr(GlistGameNumber:)
  entry $w.find.gnum -width 8 -bg white
  ttk::button $w.find.b_gnum -image tb_next -command "glist.findgame_ $w"
  bind $w.find.gnum <Return> "$w.find.b_gnum invoke"
  grid $w.find.t_gnum $w.find.gnum $w.find.b_gnum -in $w.find.n -padx 2
  ttk::frame $w.find.t
  ttk::label $w.find.t_text -text $::tr(GlistFindText:)
  entry $w.find.text -width 20 -bg white
  ttk::button $w.find.b1_text -image tb_next -command \
    "after cancel glist.findgame_ $w 1; after idle glist.findgame_ $w 1"
  bind $w.find.text <Return> "$w.find.b1_text invoke"
  ttk::button $w.find.b2_text -image tb_prev -command \
    "after cancel glist.findgame_ $w 0; after idle glist.findgame_ $w 0"
  #TODO: -from 0 -to 100
  #TODO: set scale position when normal ybar is used
  ttk::scale $w.find.scale -command "glist.ybar_ $w.glist moveto"
  grid $w.find.t_text $w.find.text $w.find.b2_text $w.find.b1_text -in $w.find.t -padx 2
  grid $w.find.hide
  grid $w.find.n -row 0 -column 1 -padx 10
  grid $w.find.t -row 0 -column 2 -padx 6
  grid $w.find.scale -row 0 -column 3 -sticky ew
  grid columnconfigure $w.find 3 -weight 1
  set ::glistFindBar($w.glist) $w.find
  glist.showfindbar_ $w.glist $layout

  # On exit save layout in options.dat
  options.save ::glist_ColOrder($layout)
  options.save ::glist_ColWidth($layout)
  options.save ::glist_ColAnchor($layout)
  options.save ::glist_Sort($layout)
  options.save ::glist_FindBar($layout)

  set ::glistLoaded($w.glist) 0.0
  set ::glistTotal($w.glist) 0.0
  set ::glistVisibleLn($w.glist) 20
  glist.sortInit_ $w.glist $layout
}

# glist.update
#   Retrieve values from database and update the widget
#   w: the parent windows of the widget that was passed to glist.create
#   base: the database from which retrieve values
#   filter: returns only values in the specified filter
#   moveUp: reset glist to show the first results
proc glist.update {{w} {base} {filter} {moveUp 1}} {
  set w $w.glist
  if {! [winfo exists $w]} { return }

  set ::glistFilter($w) $filter
  set ::glistTotal($w) [sc_filter size $base $filter]
  if {$moveUp == 1} { set ::glistFirst($w) 0.0 }

  glist.update_ $w $base
}


##########################################################################
#private:

set glist_Headers {"GlistNumber" "GlistResult" "GlistLength" "GlistWhite" "GlistWElo"
                   "GlistBlack" "GlistBElo"  "GlistDate" "GlistEvent" "GlistRound"
                   "GlistSite" "GlistAnnos" "GlistComments" "GlistVars" "GlistDeleted"
                   "GlistFlags" "GlistECO" "GlistEndMaterial" "GlistStart" "GlistEDate"
                   "GlistYear" "GlistAverageElo" "GlistRating" "GlistMoveField" }

set glist_SortShortcuts { "N" "r" "m" "w" "W"
                    "b" "B" "d" "e" "n"
                    "s" "A" "C" "V" "D"
                    "???" "o" "???" "???" "E"
                    "y" "R" "i" "???" }

proc glist.destroy_ {{w}} {
  after cancel glist.chkVisibleLn_ $w
  if {[info exists ::glistSortCache($w)]} {
    catch { sc_base sortcache $::glistBase($w) release $::glistSortCache($w) }
    unset ::glistSortCache($w)
  }
  unset ::glistSortStr($w)
  if {[info exists ::glistBase($w)]} { unset ::glistBase($w) }
  if {[info exists ::glistFilter($w)]} { unset ::glistFilter($w) }
  if {[info exists ::glistFirst($w)]} { unset ::glistFirst($w) }
  if {[info exists ::glistClickOp($w)]} { unset ::glistClickOp($w) }
  unset ::glistVisibleLn($w)
  unset ::glistLoaded($w)
  unset ::glistTotal($w)
  unset ::glistYScroll($w)
  unset ::glistFindBar($w)
}

proc glist.update_ {{w} {base}} {
  if {! [info exists ::glistBase($w)] } {
    #Create a sortcache to speed up sorting
    sc_base sortcache $base create $::glistSortStr($w)
    set ::glistFirst($w) 0.0
  } elseif {$::glistBase($w) != $base || $::glistSortCache($w) != $::glistSortStr($w)} {
    #Create a new sortcache
    catch { sc_base sortcache $::glistBase($w) release $::glistSortCache($w) }
    sc_base sortcache $base create $::glistSortStr($w)
    set ::glistFirst($w) 0.0
  }
  set ::glistSortCache($w) $::glistSortStr($w)
  set ::glistBase($w) $base
  glist.loadvalues_ $w
  after cancel glist.chkVisibleLn_ $w
  after idle glist.chkVisibleLn_ $w
}

proc glist.loadvalues_ {{w}} {
  set sel [$w selection]
  $w delete [$w children {}]
  set base $::glistBase($w)
  if {$base == [sc_base current]} {
    set current_game [sc_game number]
  } else {
    set current_game -1
  }
  set i 0
  foreach {idx line deleted} [sc_base gameslist $base $::glistFirst($w) [expr 1 + $::glistVisibleLn($w)]\
                                        $::glistFilter($w) $::glistSortStr($w)] {
    $w insert {} end -id $idx -values $line -tag fsmall
    if {$deleted == "D"} { $w item $idx -tag {fsmall deleted} }
    foreach {n ply} [split $idx "_"] {
      if {$n == $current_game} { $w item $idx -tag "[$w item $idx -tag] current" }
    }
    incr i
  }
  set ::glistLoaded($w) $i
  catch {$w selection set $sel}
}

proc glist.chkVisibleLn_ {w} {
  set i 0
  set nvisible 0
  foreach {idx} [$w children {}] {
    if {[$w bbox $idx] != ""} { incr nvisible }
	incr i
  }
  if {$nvisible != $i} {
    set ::glistVisibleLn($w) $nvisible
  } elseif {$::glistLoaded($w) != $::glistTotal($w)} {
    if {[expr $::glistFirst($w) + $::glistLoaded($w)] == $::glistTotal($w)} {
      #TODO: update ::glistVisibleLn windows when at the bottom of the list
      #set ::glistFirst($w) [expr $::glistFirst($w) -1.0]
      return
    }
    set ::glistVisibleLn($w) [expr 2* $i]
    glist.loadvalues_ $w
    after cancel glist.chkVisibleLn_ $w
    after idle glist.chkVisibleLn_ $w
  }
  after cancel glist.ybarupdate_ $w
  after idle glist.ybarupdate_ $w
}

proc glist.showfindbar_ {{w} {layout}} {
  if {$::glist_FindBar($layout) == 0} {
    grid forget $::glistFindBar($w)
  } else {
    grid $::glistFindBar($w) -row 2 -columnspan 2 -sticky news
  }
}

proc glist.findcurrentgame_ {{w} {gnum}} {
  set r [sc_base gamelocation $::glistBase($w) $::glistFilter($w) $::glistSortStr($w) $gnum]
  if {$r != ""} {
    set ::glistFirst($w) [expr $r -1]
    glist.ybar_ $w scroll
  }
}

proc glist.findgame_ {{w_parent} {dir ""}} {
  set w $w_parent.glist
  set w_entryN $w_parent.find.gnum
  set gnum [$w_entryN get]
  set w_entryT $w_parent.find.text
  set txt [$w_entryT get]
  $w_entryN configure -bg white
  $w_entryT configure -bg white
  if {($dir == "" && $gnum == "") || ($dir != "" && $txt == "")} { return }
  busyCursor $w_parent
  update idletasks

  if {$dir == ""} {
    set r [sc_base gamelocation $::glistBase($w) $::glistFilter($w) $::glistSortStr($w) $gnum]
  } else {
    set gstart [expr int($::glistFirst($w))]
    foreach {n ply} [split [$w selection] "_"] {
      if {$n != ""} {
        set n [sc_base gamelocation $::glistBase($w) $::glistFilter($w) $::glistSortStr($w) $n]
        set gstart [expr $n -1]
      }
    }
    if {$dir == "1"} { incr gstart }
    set r [sc_base gamelocation $::glistBase($w) $::glistFilter($w) $::glistSortStr($w) 0\
            $txt $gstart $dir]
  }
  if {$r == ""} {
    if {$dir == ""} {
      $w_entryN configure -bg red
    } else {
      $w_entryT configure -bg red
    }
  } else {
    if {[expr $::glistFirst($w) + $::glistVisibleLn($w)] <= $r} {
      set ::glistFirst($w) [expr $r -1]
      glist.ybar_ $w scroll
    }
    after idle glist.select_ $w $r
  }
  unbusyCursor $w_parent
}

proc glist.select_ {w {idx 0}} {
  if {$idx != "end" && $idx > 0} {
    set idx [expr int($idx - $::glistFirst($w) -1)]
  }
  $w selection set [lindex [$w children {}] $idx]
}

proc glist.movesel_ {{w} {cmd} {scroll} {select}} {
  set sel [$w selection]
  if {$sel == ""} { glist.select_ $w; return }
  set newsel [$w $cmd $sel]
  if {$newsel == "" || [$w bbox $newsel] == ""} {
    glist.ybar_ $w scroll $scroll
  }
  if {$newsel == ""} {
    after idle glist.select_ $w $select
  } else {
    $w selection set $newsel
  }
}

proc glist.delflag_ {{w} {idx}} {
  if {[sc_base gameflag $::glistBase($w) $idx get del]} {
    sc_base gameflag $::glistBase($w) $idx unset del
  } else {
    sc_base gameflag $::glistBase($w) $idx set del
  }
  ::notify::DatabaseChanged 0
}

proc glist.doubleclick_ {{w} {x} {y} {layout}} {
  lassign [$w identify $x $y] what
  if {$what == "heading"} {
    glist.sortClickHandle_ $w $x $y $layout 1
  } else {
    foreach {idx ply} [split [$w identify item $x $y] "_"] {}
    if {[info exists idx]} {
      if {[info exists ::glistClickOp($w)]} {
        if {$::glistClickOp($w) == 1} {
          glist.delflag_ $w $idx;
          $w selection set {};
          return
        }
        if {$::glistClickOp($w) == 2} {
          glist.removeFromFilter_ $w $idx
          return
        }
      }
      ::file::SwitchToBase $::glistBase($w) 0
      ::game::Load $idx $ply
    }
  }
}

proc glist.removeFromFilter_ {{w} {idx} {dir ""}} {
  if {$dir == ""} {
    sc_filter set $::glistBase($w) $::glistFilter($w) 0 $idx
    ::notify::DatabaseChanged 0
    return
  }
  set fc [sc_filter size $::glistBase($w) $::glistFilter($w)]
  sc_filter set $::glistBase($w) $::glistFilter($w) 0 $idx $dir$fc $::glistSortStr($w)
  ::notify::DatabaseChanged 1
  if {$dir == "+"} { glist.ybar_ $w moveto 1 }
}

proc glist.popupmenu_ {{w} {x} {y} {abs_x} {abs_y} {layout}} {
# identify region requires at least tk 8.5.9
# identify row have scrollbar problems
  if { 0 != [catch {set region [$w identify region $x $y] }] } {
    if {[$w identify row $x $y] == "" } {
      set region "heading"
    } else {
      set region ""
    }
  }
  if { $region != "heading" } {
# if {[$w identify region $x $y] != "heading" }
    event generate $w <ButtonPress-1> -x $x -y $y
    foreach {idx ply} [split [$w selection] "_"] {}
    if {[info exists idx]} {
      if { [winfo exists $w.game_menu.merge] } { destroy $w.game_menu.merge }
      if { [winfo exists $w.game_menu.copy] } { destroy $w.game_menu.copy }
      if { [winfo exists $w.game_menu.filter] } { destroy $w.game_menu.filter }
      $w.game_menu delete 0 end
      #LOAD/BROWSE/MERGE GAME
      $w.game_menu add command -label $::tr(LoadGame) \
         -command "::file::SwitchToBase $::glistBase($w) 0; ::game::Load $idx $ply"
      $w.game_menu add command -label $::tr(BrowseGame) \
         -command "::gbrowser::new $::glistBase($w) $idx $ply"
      $w.game_menu add command -label $::tr(MergeGame) \
         -command "mergeGame $::glistBase($w) $idx"
      menu $w.game_menu.merge
      menu $w.game_menu.copy
      for {set i [sc_base count total] } {$i > 0} {incr i -1} {
        if {[sc_base inUse $i]} {
          if { $i == $::glistBase($w) || [sc_base isReadOnly $i] } { continue }
          set fname [file tail [sc_base filename $i]]
          $w.game_menu.merge add command -label "$i $fname" -command "::game::mergeInBase $::glistBase($w) $i $idx"
          $w.game_menu.copy add command -label "$i $fname" \
              -command "sc_base copygames $::glistBase($w) $idx $i; ::notify::DatabaseChanged 0"
        }
      }
      $w.game_menu add cascade -label $::tr(GlistMergeGameInBase) -menu $w.game_menu.merge
      #TODO: translate label
      $w.game_menu add cascade -label "Copy Game to" -menu $w.game_menu.copy

      #GOTO GAME
      $w.game_menu add separator
      #TODO: translate label
      $w.game_menu add checkbutton -variable ::glist_FindBar($layout) \
                   -label "Find Bar" -command "glist.showfindbar_ $w $layout"
      if {$::glistBase($w) == [sc_base current] && [sc_game number] != 0} {
        #TODO: translate label
        $w.game_menu add command -label "Find current game" -command "glist.findcurrentgame_ $w [sc_game number]"
      } else {
        #TODO: translate label
        $w.game_menu add command -label "Find current game" -state disabled
      }
      $w.game_menu add separator
      menu $w.game_menu.filter
      $w.game_menu.filter add command -label [tr SearchReset] \
        -command "sc_filter set $::glistBase($w) $::glistFilter($w) 1; ::notify::DatabaseChanged"
      $w.game_menu.filter add command -label [tr SearchNegate] \
        -command "sc_filter negate $::glistBase($w) $::glistFilter($w); ::notify::DatabaseChanged"
      $w.game_menu.filter add separator
      $w.game_menu.filter add command -label $::tr(GlistRemoveGameAndAboveFromFilter) \
        -command "glist.removeFromFilter_ $w $idx -"
      $w.game_menu.filter add command -label $::tr(GlistRemoveThisGameFromFilter) \
        -command "glist.removeFromFilter_ $w $idx"
      $w.game_menu.filter add command -label $::tr(GlistRemoveGameAndBelowFromFilter) \
        -command "glist.removeFromFilter_ $w $idx +"
      $w.game_menu.filter add separator
      $w.game_menu.filter add command -label $::tr(GlistDeleteAllGames) \
        -command "sc_base gameflag $::glistBase($w) $::glistFilter($w) set del; ::notify::DatabaseChanged"
      $w.game_menu.filter add command -label $::tr(GlistUndeleteAllGames) \
        -command "sc_base gameflag $::glistBase($w) $::glistFilter($w) unset del; ::notify::DatabaseChanged"
      $w.game_menu add cascade -label $::tr(Filter) -menu $w.game_menu.filter
      $w.game_menu add separator
      #TODO: translate labels
      set dellabel "Delete game"
      if {[sc_base gameflag $::glistBase($w) $idx get del]} { set dellabel "Undelete game" }
      $w.game_menu add command -label $dellabel -command "glist.delflag_ $w $idx; $w selection set {};"
      tk_popup $w.game_menu $abs_x $abs_y
    }
  } else {
    set col [$w identify column $x $y]
    set col_idx [lsearch -exact $::glist_Headers [$w column $col -id] ]
    $w.header_menu delete 0 end

    #CHANGE ALIGNMENT
    set cur_a [lindex $::glist_ColAnchor($layout) $col_idx]
    if {$cur_a != "w"} {
      $w.header_menu add command -label $::tr(GlistAlignL) \
                     -command "$w column $col -anchor w; lset ::glist_ColAnchor($layout) $col_idx w"
    }
    if {$cur_a != "e"} {
      $w.header_menu add command -label $::tr(GlistAlignR) \
                     -command "$w column $col -anchor e; lset ::glist_ColAnchor($layout) $col_idx e"
    }
    if {$cur_a != "c"} {
      $w.header_menu add command -label $::tr(GlistAlignC) \
                     -command "$w column $col -anchor c; lset ::glist_ColAnchor($layout) $col_idx c"
    }

    #ADD/REMOVE COLUMN
    $w.header_menu add separator
    $w.header_menu.addcol delete 0 end
    set empty disabled
    set i 0
    foreach h $::glist_Headers {
      if {[lsearch -exact $::glist_ColOrder($layout) $i] == -1} {
        set empty normal
        $w.header_menu.addcol add command -label $::tr($h) -command "glist.insertcol_ $w $layout $i $col"
      }
      incr i
    }
    $w.header_menu add cascade -label $::tr(GlistAddField) -menu $w.header_menu.addcol -state $empty
    $w.header_menu add command -label $::tr(GlistDeleteField) -command "glist.removecol_ $w $layout $col"

    #RESET SORT
    $w.header_menu add separator
    #TODO: translate label
    $w.header_menu add command -label "Reset sort" -command "glist.sort_ $w 0 $layout 1"

    #BARS
    $w.header_menu add separator
    #TODO: translate label
    $w.header_menu add checkbutton -variable ::glist_FindBar($layout) \
                   -label "Find Bar" -command "glist.showfindbar_ $w $layout"

    tk_popup $w.header_menu $abs_x $abs_y
  }
}

# Sorting
proc glist.sortInit_ {w {layout}} {
  set ::glistSortStr($w) ""
  set i 0
  foreach {c dir} $::glist_Sort($layout) {
    set arrow_idx [expr $i *2]
    if {$dir == "-"} { incr arrow_idx }
    $w heading $c -image ::glist_Arrows($arrow_idx)
    append ::glistSortStr($w) [lindex $::glist_SortShortcuts $c] $dir
    incr i
  }
}

proc glist.sortClickHandle_ {{w} {x} {y} {layout} {clear 0}} {
  set col [$w identify column $x $y]
  set col_idx [lsearch -exact $::glist_Headers [$w column $col -id] ]
  if {"???" == [lindex $::glist_SortShortcuts $col_idx]} {
    # TODO: notify the user that the column cannot be used for sorting
    return
  }
  glist.sort_ $w $col_idx $layout $clear
}

proc glist.sort_ {{w} {col_idx} {layout} {clear 0}} {
  if {[lindex $::glist_Sort($layout) 0] == 0 && $col_idx != 0} { set clear 1; }
  if {$clear} {
    foreach {c dir} $::glist_Sort($layout) { $w heading $c -image "" }
    set ::glist_Sort($layout) {}
  }

  set exists [lsearch -exact $::glist_Sort($layout) $col_idx ]
  if {$exists == -1} {
    lappend ::glist_Sort($layout) $col_idx -
  } else {
    incr exists
    if {[lindex $::glist_Sort($layout) $exists ] == "+"} {
      lset ::glist_Sort($layout) $exists {-}
    } else {
      lset ::glist_Sort($layout) $exists {+}
    }
  }
  busyCursor $w
  update idletasks
  glist.sortInit_ $w $layout
  set file [sc_base filename $::glistBase($w)]
  if {[info exists ::recentSort]} {
    set idx [lsearch -exact $::recentSort "$file"]
    if {$idx != -1} {
      set ::recentSort [lreplace $::recentSort $idx [expr $idx +1] ]
    }
    while {[llength $::recentSort] > 20} {
      set ::recentSort [lreplace $::recentSort 0 1]
    }
  }
  lappend ::recentSort "$file" "$::glist_Sort($layout)"
  glist.update_ $w $::glistBase($w)
  unbusyCursor $w
}

# Scrollbar
proc glist.ybar_ {w cmd {n 0} {units ""}} {
  if { $cmd == "-1" || $cmd == "+1" } {
    #MouseWheel
    set n [expr $cmd * $::glistVisibleLn($w) * 0.25]
    set units "units"
    set cmd scroll
  }
  if { $cmd == "scroll" || $cmd == "moveto"} {
    if {$cmd == "moveto"} {
      set ::glistFirst($w) [expr ceil($n * $::glistTotal($w))]
    } else {
      if {$units == "pages"} {
        set ::glistFirst($w) [expr $::glistFirst($w) + $n * ($::glistVisibleLn($w) -1)]
      } else {
        set ::glistFirst($w) [expr $::glistFirst($w) + $n]
      }
    }

    set d [expr $::glistTotal($w) - $::glistVisibleLn($w) +1]
    if {$::glistFirst($w) > $d } { set ::glistFirst($w) $d }
    if { $::glistFirst($w) < 0.0 } { set ::glistFirst($w) 0.0 }

    after cancel glist.loadvalues_ $w
    after idle glist.loadvalues_ $w
    glist.ybarupdate_ $w
  }
}

proc glist.ybarupdate_ {w} {
  if { $::glistLoaded($w) != $::glistTotal($w) } {
    set first [expr double($::glistFirst($w)) / $::glistTotal($w)]
    set last [expr double($::glistFirst($w) + $::glistVisibleLn($w)) / $::glistTotal($w)]
    eval $::glistYScroll($w) $first $last
  }
}

proc glist.yscroll_ {w first last} {
  if { $::glistLoaded($w) == $::glistTotal($w) } {
    eval $::glistYScroll($w) $first $last
  }
}

#Drag and drop and changes in column's layout
proc glist.insertcol_ {{w} {layout} {col} {after}} {
  set b [expr [string trimleft $after {#}]]
  set ::glist_ColOrder($layout) [linsert $::glist_ColOrder($layout) $b $col]
  $w configure -displaycolumns $::glist_ColOrder($layout)
}

proc glist.removecol_ {{w} {layout} {col}} {
  set d [expr [string trimleft $col {#}] -1]
  set ::glist_ColOrder($layout) [lreplace $::glist_ColOrder($layout) $d $d]
  $w configure -displaycolumns $::glist_ColOrder($layout)
}

proc glist.release_ {{w} {x} {y} {layout}} {
  switch $::ttk::treeview::State(pressMode) {
    resize {
      set col_id [$w column $::ttk::treeview::State(resizeColumn) -id]
      set i [lsearch -exact $::glist_Headers $col_id]
      if {$i != -1} {
        lset ::glist_ColWidth($layout) $i [$w column $::ttk::treeview::State(resizeColumn) -width]
      }
    }
    heading {
      lassign [$w identify $x $y] what
      if {$what == "heading"} {
        set new_col [$w identify column $x $y]
        set from [expr [string trimleft $::ttk::treeview::State(heading) {#}] -1]
        set to [expr [string trimleft $new_col {#}] -1]
        set val [lindex $::glist_ColOrder($layout) $from]
        if {$from != $to} {
          set ::glist_ColOrder($layout) [lreplace $::glist_ColOrder($layout) $from $from]
          set ::glist_ColOrder($layout) [linsert $::glist_ColOrder($layout) $to $val]
          $w configure -displaycolumns $::glist_ColOrder($layout)
        } else {
          glist.sortClickHandle_ $w $x $y $layout
        }
      }
    }
  }
  ttk::treeview::Release $w $x $y
}

image create bitmap ::glist_Arrows(0) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x00, 0x03, 0x00, 0x02, 0x00, 0x02, 0x00, 0x02, 0x10, 0x02,
       0x38, 0x07, 0x7c, 0x00, 0xfe, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(1) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x00, 0x03, 0x00, 0x02, 0x00, 0x02, 0x00, 0x02, 0xfe, 0x02,
       0x7c, 0x07, 0x38, 0x00, 0x10, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(2) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x80, 0x03, 0x00, 0x04, 0x00, 0x04, 0x00, 0x02, 0x08, 0x01,
       0x9c, 0x07, 0x3e, 0x00, 0x7f, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(3) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x80, 0x03, 0x00, 0x04, 0x00, 0x04, 0x00, 0x02, 0x7f, 0x01,
       0xbe, 0x07, 0x1c, 0x00, 0x08, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(4) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x80, 0x03, 0x00, 0x04, 0x00, 0x04, 0x00, 0x03, 0x08, 0x04,
       0x9c, 0x07, 0x3e, 0x00, 0x7f, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(5) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x80, 0x03, 0x00, 0x04, 0x00, 0x04, 0x00, 0x03, 0x7f, 0x04,
       0xbe, 0x03, 0x1c, 0x00, 0x08, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(6) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x00, 0x02, 0x00, 0x03, 0x00, 0x03, 0x80, 0x02, 0x88, 0x07,
       0x1c, 0x02, 0x3e, 0x00, 0x7f, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(7) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x00, 0x02, 0x00, 0x03, 0x00, 0x03, 0x80, 0x02, 0xff, 0x07,
       0x3e, 0x02, 0x1c, 0x00, 0x08, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(8) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x80, 0x07, 0x80, 0x00, 0x80, 0x03, 0x00, 0x04, 0x08, 0x04,
       0x9c, 0x03, 0x3e, 0x00, 0x7f, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(9) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x80, 0x07, 0x80, 0x00, 0x80, 0x03, 0x00, 0x04, 0x7f, 0x04,
       0xbe, 0x03, 0x1c, 0x00, 0x08, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(10) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x00, 0x07, 0x80, 0x00, 0x80, 0x00, 0x80, 0x03, 0x88, 0x04,
       0x1c, 0x07, 0x3e, 0x00, 0x7f, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(11) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x00, 0x07, 0x80, 0x01, 0x80, 0x00, 0x80, 0x07, 0xff, 0x04,
       0x3e, 0x03, 0x1c, 0x00, 0x08, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(12) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x80, 0x07, 0x00, 0x04, 0x00, 0x02, 0x00, 0x02, 0x08, 0x02,
       0x1c, 0x01, 0x3e, 0x00, 0x7f, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(13) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x80, 0x07, 0x00, 0x04, 0x00, 0x02, 0x00, 0x02, 0x7f, 0x02,
       0x3e, 0x01, 0x1c, 0x00, 0x08, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(14) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x00, 0x03, 0x80, 0x04, 0x80, 0x04, 0x00, 0x03, 0x88, 0x04,
       0x9c, 0x07, 0x3e, 0x00, 0x7f, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(15) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x00, 0x03, 0x80, 0x04, 0x80, 0x04, 0x00, 0x03, 0xff, 0x04,
       0xbe, 0x07, 0x1c, 0x00, 0x08, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(16) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x00, 0x03, 0x80, 0x04, 0x80, 0x07, 0x00, 0x04, 0x08, 0x06,
       0x9c, 0x03, 0x3e, 0x00, 0x7f, 0x00, 0x00, 0x00 };
}
image create bitmap ::glist_Arrows(17) -foreground blue -data {
    #define arrows_width 12
    #define arrows_height 10
    static unsigned char arrows_bits[] = {
       0x00, 0x00, 0x00, 0x03, 0x80, 0x04, 0x80, 0x07, 0x00, 0x04, 0x7f, 0x06,
       0xbe, 0x03, 0x1c, 0x00, 0x08, 0x00, 0x00, 0x00 };
}

##########################################################################
