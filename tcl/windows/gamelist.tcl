########################################################################
### Games list window
# Copyright (C) 2011-2013 Fulvio Benini
#
# This file is part of Scid (Shane's Chess Information Database).
# Scid is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.

#TODO: move icons out of tcl code (image create photo -file)
image create photo glist_ImgLayout -format gif -data {
R0lGODlhGAAYAOe9AAd6tAh6tAh7tAh7tQl7tAl8tQ5+thiBtRmCtkyERk2ER02ESU6ESk6ES02FR02FSE6FS0+FS0+FTIGBgYKBgYKCgoODgoODg4SDg4SEhIWEhIWFhIWFhYaGhYaGhoiHh4iHiICifISmgYSngaipqaqrq66urq+vr7CwsLGxsLGxsbKxsY/IOY/IO7KyspDJO7OzsrOzs7SztLWztLW0tLW0tbm7vbq8vr7Awr/Bw6XYTsTDxabYUMLExqfZUcPFx8bFx8XHycbIysjKy8zJy8nLzM/M0szOz87Ozs/Pz9PO1tTO19LP1M/R0tDT1NHT1dHU1dLV1tjT29PW19XX2NXY2dvW3tbY2dfY2d3Y4b/uYNna29na3MDuYcDuYt3b3d/a4tvc3d7b397c3tzd3tzd39zd4N7d3t3e397f4N/g4eHg4OLg5eDh4uHi4+Ti5+Lj5ePj4+Pk5ePk5uTk5Obj6uTk5ufj7OTl5s74bc74bufk7Obl5ujk7OXm58/5bs/5b+fm5+nl7tD7aurm7ubo6efo6ejo6ND8a+vn7+vn8Onp6evp6enq6+nr7Ozr7O3r7Ozs7e7s7ezt7u3u7+7u7u/u7u/v7+/v8PDv7/Dv8fHv7+7w8fDw8PHw8PLw8PHx8PHx8fHx8vPx8vPz8/Pz9PTz8/X09PX19vf19vb29/j29/f39/n3+Pj4+Pj4+fn5+Pn5+fr5+fr6+fr6+vz6+vv7+/v7/P37+/78/f39/v/9/v///v///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////yH5BAEKAP8ALAAAAAAYABgAAAj+AEM8YNCgoMGDCA0yeBBCAaI/gCJKnEhR4h9EChboYdHihcePIEO+aMFCz4IFeXTw8MGypcuXPnjoyLMgwSAtXbzo3Mmzp5cuWgYlGPEggoSjEApCWMq0KVMHIt4QUkQ1kaA7WPf02cq16506bEh8AEEWRAk7QGrImMG2rVsZNHZwIBWqLikPhWLYosW3r1++tlxsCGXjho1QHRzFoOXkCZTHkB8/cUJLhYZQOHLgCMVh0uIpVKqIHi2aypTKGUD1+NEDFAdOMGhh2UK7tm0sqD0FERLEEwdRLmZxCUO8uHEus1Jk6DSkyJBOHEq5iEUGjfXr2MnEQpEh05HvmTi1qJqeRo358+jTbMdwqYn7SxleuYDVxo39+/jbwEJx4VKU//Dd4oIrcMhh4IEIwuEKf5Zc4aAlGeiygit+VGjhhRUuaEElXHRYSQa9qOCKISSWaCKJrpxQQSVmlGHGhyG60siMNNY4Y4ortqFGG5VcECIrkQQp5JBBsqJiJXjMgUePvaDgiiaYRCnllJqkOEEolExCSSgVNEkLKmCGKSaYtJgQwwQUpDlBDL0kYcKbcMYZJxIBAQA7
}
image create photo glist_ImgBoard -format gif -data {
R0lGODlhGAAYAOf/ACMkIiYoJTksJG84I3E6JUVFPXI7JXQ8J3FAKHc/KXRBJHlAJXlBK3tCJ3dELIBCLn1EKXxELn5FKYBGK4JILIdHLoJJMoZKKYVKL39MM4dLKotKK4dMMIxLMYhNMXxQP4pOLYlOMo9NNJVMMJBOL4tQNJNPK5FPNlxcVJNQMZhPMpRRMo9TMZtRLptSNZNVNJdUNHlbUZ5UMZtWMZpWNqBVM59VOJZYNlthkXlgTpxYOJ5ZNJ1ZOaRYNalXN55aOqBaNaRZPKBcPKJcN6dbOKxaOahcOZ9fN6NePqldQKVfOapeO6ZgOmNrlqxfPGdrkWlqlqhhPK1gPaxgQ6liPW1tjmFvn69iPnFtiatkPpFrXK5mOnBwkbNlO7JlQa9nQXVxjW5ymHZyjrVnQ3NzlLdoPrJqRJFxYLdpRYxzZoJ1gX12japwSoh3bW56q5x1Zql0TIN5i65zTat2To98bX9/lK55UYeAl7F7U619U7R+Va+AVYqJb7KBULiBWbODWbiGVbeGW5CPh7mJXoGRvLyKWZCSj7yLYL6MW7+NXKCSjZaVjYWVwcGOXZiWmqqZjqebnJ+elqSjiKmll6eok6qnmJOrvMWhj7KmprWqi7CptaustsKqobGvs9CsgcOtqsivpsOxppK85Ky30r64t7+7mbq8ub68wJ7D5bvDy8XEqMjDwqbK7cnIv7DQ7c/Nsc3Mw7nR1tLOrNnVs8TZ2MjX68Xd4svd1tPb5NHe38/g2fbapPDcpMzh4NTi1vXfoPXhqNTm3/jio/Xmpdfp4vvlpvnlrOLo3fXord/p5OrqwODr2Pbpru3ru/jqr/rnyP7qsfjqw/rsseTu6f3trPPvufzus/TvzfLxwOnw5ffxtP3wtfrvzvvyr/7xtvjxyfnztvfzvP/yt/7yvfr0t/3x0Pv1uO716vH14/z2uf7z0fn10vz1zP33uvv3wP/4u/34wfr5yP/5vPT45/76wvv8vf/7vf/7xP37yv/8xf78y/f76vz90v/82f7/0////yH5BAEKAP8ALAAAAAAYABgAAAj+AD01OoRoUKFAgPwE+uOnzx49ePLgsTOnohw2jbhp/FZuxIgWMmqUW7dOHbsiRXwQ6REt2rOMxpAZczbAwIEDCaxp02bNGoQJERo04PVr1yFuMZ05M5BgAQMIOr1ZI0eBwgSrwH79KvQNGTJn0BK8eaTo0TVr4syJ48ABg4YKwIAJ46rUGbVQjkid2mTJ1Dhz6USQEAHCQ7FhxgCNGEAAASdY+85Ny1UnTKcUK96le6e5xAYMgUwMOMBg1b5555L1uiPGyiUY8DhzTkECBCAVTLVgQncuG7HVXJp82nFP3j3OMFKICOQCwYIzkJYdIxbM1h0yUDQNuXcPXr53M2D+vPAjQ8GCD5t86bpFKxaXJzhAJbmHTx8+eDtowPhTTpo1abioEUcca4CBiiiszKLPFVlQ4YQS75AjTh/r9EROJqNggUUVXKDiSiv89FPGF11cwQRn5uihjk7kmBNDKoy4QUgtk0TyCj9mjFHGFVTUw5ke7KAlTjosZJADHWmUwo8kAUwyBhojXtHdO3mUM5VaKcBAww9I6BMiCgC0UQaUXehzHB5BMDABBiHEBk888TBBhRdlCADAIv34o48URgCBhw8NXOUBOOEUis0PP9yABBoFACAIP/pEQcQPdvQQaAUekANONdU0A8MPL2DgACUAGKKKPksMwUOlDDxgAQd2m72TDzxMOJHFFlHIIgkfyuhjxBA2zGHDAg1QsIFs79wzhBFOSCGFPtDqkw8RPMwwR3/dTNWBCCdoeU8+9ekzxRJM/ArtPXCw45825Fyw7QowvAMPd/ccMYQQP9iAT3dw9OefNRRoEAIJmXE2Kw886KDfcfAEBAA7
}

proc ::windows::gamelist::Open {{w .glistWin}} {
	if {[::createToplevel $w] == "already_exists"} {
		focus .
		destroy $w
		return
	}

	if {! [info exists ::glistLayout($w)] } {
		set ::glistLayout($w) [::glist_Ly::CreateName]
		lappend ::glist_Layouts $::glistLayout($w)
	}
	options.save ::glist_Layouts
	options.save ::glistLayout($w)

	set ::gamelistBase($w) 0
	set ::gamelistMenu($w) ""
	set ::gamelistNewLayout($w) [::glist_Ly::CreateName]
	set ::gamelistFilter($w) "dbfilter"
	ttk::frame $w.buttons -padding {5 5 2 5}
	ttk::button $w.buttons.database -image tb_CC_book -command "::windows::gamelist::menu_ $w database"
	ttk::button $w.buttons.filter -image engine_on -command "::windows::gamelist::menu_ $w filter"
	ttk::button $w.buttons.layout -image glist_ImgLayout -command "::windows::gamelist::menu_ $w layout"
	ttk::button $w.buttons.boardFilter -image glist_ImgBoard -command "::windows::gamelist::searchpos_ $w"
	#TODO:
	#Se diamo la possibilita di avere finestre multiple, con filtri diversi per lo stesso database,
	#la tree window non sara sufficiente e bisognera visualizzare le statistiche per ogni gamelist window
	#ttk::button $w.buttons.stats -image b_bargraph
	grid $w.buttons.database -row 0
	grid $w.buttons.filter  -row 1
	grid $w.buttons.layout  -row 2
	grid $w.buttons.boardFilter  -row 3
	#grid $w.buttons.stats -row 4
	# End of $w.buttons frame
	ttk::frame $w.games -borderwidth 0 -padding {8 5 5 0}
	glist.create $w.games $::glistLayout($w)
	grid $w.buttons -row 0 -column 0 -sticky news
	grid $w.games -row 0 -column 2 -sticky news
	grid rowconfigure $w 0 -weight 1
	grid columnconfigure $w 0 -weight 0
	grid columnconfigure $w 1 -weight 0
	grid columnconfigure $w 2 -weight 1
	createToplevelFinalize $w

	ttk::frame $w.database -padding {0 5 6 2}
	::windows::switcher::Create $w.database
	#TODO: remove this hack
	bind $w <Configure> "::windows::switcher::Refresh"
	###########################

	ttk::frame $w.filter -padding {0 5 6 2}
	ttk::frame $w.filter.border -borderwidth 2 -relief groove
	grid $w.filter.border -sticky news
	grid rowconfigure $w.filter 0 -weight 1
	grid columnconfigure $w.filter 0 -weight 1
	ttk::label $w.filter.text -text "TODO:\n-load/save filter\n-multiple filters\n-show cur filter" -font font_Tiny
	grid $w.filter.text -in $w.filter.border


	#TODO: scrollbars
	ttk::frame $w.layout -padding {0 5 6 2}
	grid rowconfigure $w.layout 0 -weight 1
	grid columnconfigure $w.layout 0 -weight 1
	::glist_Ly::Update $w


	::windows::gamelist::Refresh
}

proc ::windows::gamelist::Refresh {{w .glistWin}} {
	if {! [winfo exists $w]} { return }
	#TODO: Multiple windows
	set ::gamelistBase($w) [sc_base current]
	::setTitle $w "[file tail [sc_base filename $::gamelistBase($w)]] ([filterText $::gamelistBase($w) 100000])"
	glist.update $w.games $::gamelistBase($w) $::gamelistFilter($w)
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

proc ::windows::gamelist::searchpos_ {{w}} {
	if {$::gamelistFilter($w) == "dbfilter"} {
		if {! [winfo exists .treeWin$::gamelistBase($w)]} { ::tree::make $::gamelistBase($w) }
		set ::gamelistFilter($w) "filter"
		$w.buttons.boardFilter state pressed
	} else {
		set ::gamelistFilter($w) "dbfilter"
		$w.buttons.boardFilter state !pressed
	}
	::windows::gamelist::Refresh $w
}

namespace eval ::glist_Ly {
	proc Update {w} {
		if {[winfo exists $w.layout.b]} { destroy $w.layout.b}
		ttk::frame $w.layout.b -borderwidth 2 -relief groove -padding 5
		grid $w.layout.b -sticky news
		tk::entry $w.layout.b.text_new -textvariable ::gamelistNewLayout($w) -font font_Small
		tk::button $w.layout.b.new -image tb_new -command "::glist_Ly::New $w"
		grid $w.layout.b.text_new $w.layout.b.new
		ttk::frame $w.layout.b.sep -padding { 0 4 0 4 }
		ttk::separator $w.layout.b.sep.line
		grid rowconfigure $w.layout.b.sep 0 -weight 1
		grid columnconfigure $w.layout.b.sep 0 -weight 1
		grid $w.layout.b.sep.line -sticky news
		grid $w.layout.b.sep -columnspan 2 -sticky we
		for {set i 0} {$i < [llength $::glist_Layouts]} {incr i} {
			set name [lindex $::glist_Layouts $i]
			tk::button $w.layout.b.layout$i -text $name -font font_Small -width 20 -command "::glist_Ly::Change $w $i"
			if {$name == $::glistLayout($w)} { $w.layout.b.layout$i configure -bg lightSteelBlue }
			tk::button $w.layout.b.layoutDel$i -image tb_CC_delete -command "::glist_Ly::Del $w $i"
			grid $w.layout.b.layout$i $w.layout.b.layoutDel$i -sticky we
		}
	}
	proc New {w} {
		#TODO:
		#no nomi uguali
		#copia il layout attuale
		lappend ::glist_Layouts $::gamelistNewLayout($w)
		set ::gamelistNewLayout($w) [::glist_Ly::CreateName]
		::glist_Ly::Change $w end
	}
	proc Del {w idx} {
		#TODO: what to do if user delete the layout of another window?
		set old_layout [lindex $::glist_Layouts $idx]
		options.save_cancel ::glist_ColOrder($old_layout)
		options.save_cancel ::glist_ColWidth($old_layout)
		options.save_cancel ::glist_ColAnchor($old_layout)
		options.save_cancel ::glist_Sort($old_layout)
		options.save_cancel ::glist_FindBar($old_layout)
  		set ::glist_Layouts [lreplace $::glist_Layouts $idx $idx]
		::glist_Ly::Update $w
	}
	proc Change {w idx} {
		set ::glistLayout($w) [lindex $::glist_Layouts $idx]
		::glist_Ly::Update $w
		if {[winfo exists $w.games]} { destroy $w.games}
		ttk::frame $w.games -borderwidth 0 -padding {8 5 5 0}
		grid $w.games -row 0 -column 2 -sticky news		
		glist.create $w.games $::glistLayout($w)
		::windows::gamelist::Refresh $w
	}
	proc CreateName {} {
		set i 1
		set prefix "Layout"
		if {! [info exists ::glist_Layouts] } { return "$prefix$i" }
		while {[lsearch $::glist_Layouts "$prefix$i"] != -1} { incr i }
		return "$prefix$i"
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
  menu $w.glist.header_menu
  menu $w.glist.header_menu.addcol
  menu $w.glist.game_menu
  bind $w.glist <Configure> "set ::glistResized($w.glist) 1"
  bind $w.glist <2> "glist.popupmenu_ %W %x %y %X %Y $layout"
  bind $w.glist <3> "glist.popupmenu_ %W %x %y %X %Y $layout"
  bind $w.glist <ButtonRelease-1> "glist.release_ %W %x %y $layout"
  bind $w.glist <Double-ButtonRelease-1> "glist.doubleclick_ %W %x %y $layout"
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
  ttk_bindMouseWheel $w.glist "glist.ybar_ $w.glist"

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
  ttk::button $w.find.b1_text -image tb_next -command "glist.findgame_ $w 1"
  bind $w.find.text <Return> "$w.find.b1_text invoke"
  ttk::button $w.find.b2_text -image tb_prev -command "glist.findgame_ $w 0"
  grid $w.find.t_text $w.find.text $w.find.b2_text $w.find.b1_text -in $w.find.t -padx 2
  grid $w.find.hide
  grid $w.find.n -row 0 -column 1 -padx 10
  grid $w.find.t -row 0 -column 2
  set ::glistFindBar($w.glist) $w.find
  glist.showfindbar_ $w.glist $layout

  # On exit save layout in options.dat
  options.save ::glist_ColOrder($layout)
  options.save ::glist_ColWidth($layout)
  options.save ::glist_ColAnchor($layout)
  options.save ::glist_Sort($layout)
  options.save ::glist_FindBar($layout)

  set ::glistYDrag($w.glist) 0
  set ::glistLoaded($w.glist) 0.0
  set ::glistTotal($w.glist) 0.0
  set ::glistVisibleLn($w.glist) 0
  set ::glistResized($w) 0
  glist.sortInit_ $w.glist $layout
}

# glist.update
#   Retrieve values from database and update the widget
#   w: the parent windows of the widget that was passed to glist.create
#   base: the database from which retrieve values
#   filter: returns only values in the specified filter
#         - "all": all the values in the database *** NOT YET IMPLEMENTED ***
#         - "dbfilter": only values that matches the user defined filters
#         - "tree": only games from which are calculated the stats in the tree window
proc glist.update {{w} {base} {filter}} {
  set w $w.glist
  if {! [winfo exists $w]} { return }

  set ::glistFilter($w) $filter
  set ::glistTotal($w) [sc_filter count $base $filter]
  if {$::glistVisibleLn($w) == 0 && $::glistTotal($w) > 0} {
    # Guess glistVisibleLn
    set ::glistVisibleLn($w) 50
    if {$::glistVisibleLn($w) >= $::glistTotal($w)} {
      set ::glistVisibleLn($w) [expr $::glistTotal($w) -1]
    }
  }
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
  if {[info exists ::glistSortCache($w)]} {
    sc_base sortcache $::glistBase($w) release $::glistSortCache($w)
    unset ::glistSortCache($w)
  }
  unset ::glistSortStr($w)
  if {[info exists ::glistBase($w)]} { unset ::glistBase($w) }
  if {[info exists ::glistFilter($w)]} { unset ::glistFilter($w) }
  if {[info exists ::glistFirst($w)]} { unset ::glistFirst($w) }
  unset ::glistVisibleLn($w)
  unset ::glistLoaded($w)
  unset ::glistTotal($w)
  unset ::glistYDrag($w)
  unset ::glistYScroll($w)
  unset ::glistResized($w)
  unset ::glistFindBar($w)
}

proc glist.update_ {{w} {base}} {
  if {! [info exists ::glistBase($w)] } {
    #Create a sortcache to speed up sorting
    sc_base sortcache $base create $::glistSortStr($w)
  } elseif {$::glistBase($w) != $base || $::glistSortCache($w) != $::glistSortStr($w)} {
    #Create a new sortcache
    sc_base sortcache $::glistBase($w) release $::glistSortCache($w)
    sc_base sortcache $base create $::glistSortStr($w)
  }
  set ::glistSortCache($w) $::glistSortStr($w)
  set ::glistBase($w) $base
  set ::glistFirst($w) 0.0
  glist.loadvalues_ $w
  glist.ybarupdate_ $w
}

proc glist.loadvalues_ {w} {
  $w delete [$w children {}]
  set base $::glistBase($w)
  if {$base == [sc_base current]} {
    set current_game [sc_game number]
  } else {
    set current_game -1
  }
  set i 0
  foreach {idx line} [sc_base gameslist $base $::glistFirst($w) [expr 1 + $::glistVisibleLn($w)]\
                                        $::glistFilter($w) $::glistSortStr($w)] {
    $w insert {} end -id $idx -values $line -tag fsmall
    foreach {n ply} [split $idx "_"] {
      if {$n == $current_game} { $w item $idx -tag {fsmall current} }
    }
    incr i
  }
  set ::glistLoaded($w) $i
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
  busyCursor .
  update idletasks

  if {$dir == ""} {
    set r [sc_base gamelocation $::glistBase($w) $::glistFilter($w) $::glistSortStr($w) $gnum]
  } else {
	set gstart [expr int($::glistFirst($w))]
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
    set ::glistFirst($w) [expr $r -1]
    #glist.ybar can change ::glistFirst($w)
    set f [expr $r -1]
    glist.ybar_ $w scroll
    #Select the founded game
	#TODO: If there are more than one result in the last page only the first will be selected
    set f [expr int($f - $::glistFirst($w))]
    set items [$w children {}]
    $w selection set [lindex $items $f]
  }
  unbusyCursor .
}

proc glist.doubleclick_ {{w} {x} {y} {layout}} {
  lassign [$w identify $x $y] what
  if {$what == "heading"} {
    foreach {c dir} $::glist_Sort($layout) { $w heading $c -image "" }
    set ::glist_Sort($layout) {}
    glist.sortClickHandle_ $w $x $y $layout
  } else {
    foreach {idx ply} [split [$w selection] "_"] {}
    if {[info exist idx]} {
      sc_base switch $::glistBase($w)
      ::game::Load $idx $ply
    }
  }
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
    if {[info exist idx]} {
      $w.game_menu delete 0 end
      #LOAD/BROWSE/MERGE GAME
      $w.game_menu add command -label $::tr(LoadGame) \
         -command "sc_base switch $::glistBase($w); ::game::Load $idx $ply"
      $w.game_menu add command -label $::tr(BrowseGame) \
         -command "::gbrowser::new $::glistBase($w) $idx $ply"
      $w.game_menu add command -label $::tr(MergeGame) \
         -command "mergeGame $::glistBase($w) $idx"

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
      if {$::glistBase($w) == [sc_base current]} {
        #DELETE
        #TODO: Delete games even for "not current" databases
        #TODO: translate labels
        #TODO: refresh the other windows after delete/undelete
        $w.game_menu add separator
        set deleted [sc_game flag delete $idx]
        if {$deleted} {
          $w.game_menu add command -label "Undelete game" -command "sc_game flag delete $idx 0"
        } else {
          $w.game_menu add command -label "Delete game" -command "sc_game flag delete $idx 1"
        }
      }
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

proc glist.sortClickHandle_ {{w} {x} {y} {layout}} {
  set col [$w identify column $x $y]
  set col_idx [lsearch -exact $::glist_Headers [$w column $col -id] ]
  if {"???" == [lindex $::glist_SortShortcuts $col_idx]} {
    # TODO: notify the user that the column cannot be used for sorting
    return
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

  glist.sortInit_ $w $layout
  if {[info exist ::glistBase($w)]} { glist.update_ $w $::glistBase($w) }
}

# Scrollbar
proc glist.ybar_ {w cmd {n 0} {units ""}} {
  if { $cmd == "-1" || $cmd == "+1" } {
#TODO: Profile to verify if this speedup is significative
# if { $cmd == "-1" } {
#   if {$::glistFirst($w) == 0} { return }
#   set items [$w children {}]
#   $w delete [lindex $items 0]
#   if {$::glistBase($w) == [sc_base current]} {
#     set current_game [sc_game number]
#   } else {
#     set current_game -1
#   }
#   set ::glistFirst($w) [expr $::glistFirst($w) -1]
#   foreach {idx line} [sc_base gameslist $::glistBase($w) $::glistFirst($w) 1\
#                                        $::glistFilter($w) $::glistSortStr($w)] {
#     $w insert {} 0 -id $idx -values $line -tag fsmall
#     foreach {n ply} [split $idx "_"] {
#       if {$n == $current_game} { $w item $idx -tag {fsmall current} }
#     }
#   }
# }
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

    if { $cmd == "scroll"} {
      glist.loadvalues_ $w
    } else {
      set ::glistYDrag($w) 1
      set t $w.balloon
      if {! [winfo exists $t] } {
        toplevel $t -bd 1 -bg black
        wm overrideredirect $t 1
        pack [message $t.txt -aspect 10000 -bg lightyellow -font fixed]
      }
      $t.txt configure -text [format "%0.0f (%0.0f%%)" [expr 1 + $::glistFirst($w)]\
          [expr ($::glistFirst($w) + $::glistVisibleLn($w))*100.0/$::glistTotal($w) ]]
      set wmx [expr [winfo pointerx .] - [winfo reqwidth $t.txt] - 10]
      set wmy [winfo pointery .]
      wm geometry $t \
        [winfo reqwidth $t.txt]x[winfo reqheight $t.txt]+$wmx+$wmy
      raise $t
    }
    glist.ybarupdate_ $w
  } elseif { $cmd == "buttonrelease" && $::glistYDrag($w) != 0 } {
      set ::glistYDrag($w) 0
      destroy $w.balloon
      glist.loadvalues_ $w
      glist.ybarupdate_ $w
  }
}

proc glist.ybarupdate_ {w} {
  if { $::glistLoaded($w) != $::glistTotal($w) } {
    set first [expr double($::glistFirst($w)) / $::glistTotal($w)]
    set last [expr double($::glistFirst($w) + $::glistLoaded($w)) / $::glistTotal($w)]
    eval $::glistYScroll($w) $first $last
  }
}

proc glist.yscroll_ {w first last} {
  if { $first != 0 } {
#TODO: MouseWheel problem
    $w yview moveto 0
    return
  }

  if { $::glistLoaded($w) != $::glistTotal($w) } {
    if { $first != 0 || $last != 1} {
      set ::glistResized($w) 0
      if { $last < 1 } { set ::glistVisibleLn($w) [expr floor($last * $::glistLoaded($w) +1)] }
      glist.ybarupdate_ $w
    } elseif {$::glistResized($w)} {
      # Increase glistVisibleLn (recursion)
      set ::glistVisibleLn($w) [expr $::glistVisibleLn($w) + 1]
      glist.ybar_ $w scroll
    }
  } else { eval $::glistYScroll($w) $first $last }
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
