# Copyright (C) 2018 Fulvio Benini
#
# This file is part of Scid (Shane's Chess Information Database).
#
# Scid is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.
#
# Scid is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Scid.  If not, see <http://www.gnu.org/licenses/>.

namespace eval ::search {}

# Create a search window using a common framework.
# It manages the database, the filter and the and/or/reset combination of the
# results with the previous filter's values.
# @param create_subwnd: a function that creates all the specific widgets of a
#                       search window. Should return a valid command that when
#                       evaluated returns a list of the search's options.
proc ::search::Open {ref_base ref_filter title create_subwnd} {
	set w ".wnd_$title"
	::win::createDialog $w
	::setTitle $w [::tr $title]

	grid [ttk::frame $w.refdb] -sticky news
	CreateSelectDBWidget "$w.refdb" "::search::dbase_($w)" "$ref_base"
	set ::search::filter_($w) $ref_filter

	grid [ttk::frame $w.options] -sticky news
	set options_cmd [$create_subwnd $w.options]

	grid [ttk::labelframe $w.filterOp] -sticky news -pady 8
	if {![info exists ::search::filterOp_($w)]} {
		set ::search::filterOp_($w) reset
	}
	ttk::radiobutton $w.filterOp.and   -text [::tr FilterAnd]    -variable ::search::filterOp_($w) -value and
	ttk::radiobutton $w.filterOp.or    -text [::tr FilterOr]     -variable ::search::filterOp_($w) -value or
	ttk::radiobutton $w.filterOp.reset -text [::tr FilterIgnore] -variable ::search::filterOp_($w) -value reset
	grid $w.filterOp.and $w.filterOp.or $w.filterOp.reset -ipadx 8

	grid [ttk::frame $w.buttons] -sticky news
	ttk::button $w.buttons.save -text [::tr Save] -command "::search::save_ $options_cmd"
	ttk::button $w.buttons.search_new -text "[tr Search] ([tr GlistNewSort] [tr Filter])" \
		-command "::search::start_newflt_ $w $options_cmd"
	ttk::button $w.buttons.search -text [::tr Search] -command "::search::start_ $w $options_cmd"
	grid $w.buttons.save x $w.buttons.search_new $w.buttons.search -sticky w -padx "0 5"
	grid columnconfigure $w.buttons 1 -weight 1

	ttk::button $w.buttons.stop -text [::tr Stop] -command progressBarCancel
	canvas $w.progressbar -width 300 -height 20 -bg white -relief solid -border 1 -highlightthickness 0
	$w.progressbar create rectangle 0 0 0 0 -fill blue -outline blue -tags bar
	$w.progressbar create text 295 10 -anchor e -font font_Regular -tags time
	grid $w.buttons.stop -row 0 -column 0
	grid $w.progressbar -in $w.buttons -row 0 -column 1 -columnspan 3 -sticky w
	progressbar_ $w hide

	::search::Refresh $w
}

proc ::search::Refresh {w} {
	# TODO:
	# Update CreateSelectDBWidget
	# set filter to "dbfilter" if the filter no longer exists because the gamelist was closed

	# TODO:
	$w.buttons.save configure -state disabled

	# TODO:
	$w.buttons.search_new configure -state disabled

	lassign [sc_filter sizes $::search::dbase_($w) $::search::filter_($w)] filterSz gameSz
	set n_games [::windows::gamelist::formatFilterText $filterSz $gameSz]
	$w.filterOp configure -text "[::tr FilterOperation] ($n_games)"
}

proc ::search::progressbar_ {w show_hide} {
	if {$show_hide eq "show"} {
		grid remove $w.buttons.save
		grid remove $w.buttons.search_new
		grid remove $w.buttons.search
		grid $w.progressbar
		progressBarSet $w.progressbar 301 21
		grid $w.buttons.stop
		grab $w.buttons.stop
	} else {
		grab release $w.buttons.stop
		grid remove $w.buttons.stop
		grid remove $w.progressbar
		grid $w.buttons.save
		grid $w.buttons.search_new
		grid $w.buttons.search
	}
}

proc ::search::save_ {options_cmd} {
	# TODO:
}

proc ::search::start_ {w options_cmd} {
	::search::progressbar_ $w show
	::search::do_search_ $::search::dbase_($w) $::search::filter_($w) $::search::filterOp_($w) [$options_cmd]
	::search::progressbar_ $w hide

	::notify::DatabaseModified $::search::dbase_($w) $::search::filter_($w)
	::search::Refresh $w
}

proc ::search::start_newflt_ {w options_cmd} {
	set dbase $::search::dbase_($w)
	set filter [sc_filter new $dbase]
	sc_filter copy $dbase $filter $::search::filter_($w)

	::search::progressbar_ $w show
	::search::do_search_ $dbase $filter $::search::filterOp_($w) [$options_cmd]
	::search::progressbar_ $w hide

	# TODO:
	# if interrupted
	#     delete filter
	#     return

	set ::search::filter_($w) $filter
	::windows::gamelist::Open $dbase $filter
	::search::Refresh $w
}

proc ::search::do_search_ {dbase filter filter_op options} {
	switch $filter_op {
		reset {
			sc_filter reset $dbase $filter full
		}
		and {
		}
		or {
			set or_filter [sc_filter new $dbase]
			sc_filter copy $dbase $or_filter $filter
			sc_filter negate $dbase $filter
		}
	}

	# TODO: sc_filter search $dbase $filter {*}$options
	sc_search board 0 {*}$options $dbase

	if {[info exists or_filter]} {
		sc_filter or $dbase $filter $or_filter
		sc_filter release $dbase $or_filter
	}
}


# ::search::board
#   Opens the search window for the current board position.
#
proc ::search::board {{ref_base ""}} {
	::search::Open $ref_base dbfilter BoardSearch ::search::boardCreateFrame
}

proc ::search::boardCreateFrame {w} {
	ttk::labelframe $w.pos -text [::tr SearchType]
	grid $w.pos -sticky news -pady 6
	grid columnconfigure $w 0 -weight 1
	if {![info exists ::search::boardOptType_]} {
		set ::search::boardOptType_ Exact
	}
	ttk::radiobutton $w.pos.exact -textvar ::tr(SearchBoardExact)  -variable ::search::boardOptType_ -value Exact
	ttk::radiobutton $w.pos.pawns -textvar ::tr(SearchBoardPawns)  -variable ::search::boardOptType_ -value Pawns
	ttk::radiobutton $w.pos.files -textvar ::tr(SearchBoardFiles)  -variable ::search::boardOptType_ -value Fyles
	ttk::radiobutton $w.pos.material -textvar ::tr(SearchBoardAny) -variable ::search::boardOptType_ -value Material
	grid $w.pos.exact -sticky w
	grid $w.pos.pawns -sticky w
	grid $w.pos.files -sticky w
	grid $w.pos.material -sticky w

	if {![info exists ::search::boardOptInVars_]} {
		set ::search::boardOptInVars_ 0
	}
	ttk::checkbutton $w.vars -text [::tr LookInVars] -variable ::search::boardOptInVars_ -onvalue 1 -offvalue 0
	grid $w.vars -sticky w

	if {![info exists ::search::boardOptIgnoreCol_]} {
		set ::search::boardOptIgnoreCol_ 0
	}
	ttk::checkbutton $w.flip -text [::tr IgnoreColors] -variable ::search::boardOptIgnoreCol_ -onvalue 1 -offvalue 0
	grid $w.flip -sticky w

	return "::search::boardGetOptions"
}

proc ::search::boardGetOptions {} {
	set options {}
	lappend options $::search::boardOptType_
	lappend options $::search::boardOptInVars_
	lappend options $::search::boardOptIgnoreCol_
	return $options
}
