# Copyright (C) 2018-2019 Fulvio Benini
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
	if {[winfo exists $w]} { destroy $w }
	::win::createDialog $w
	::setTitle $w [::tr $title]

	grid [ttk::frame $w.refdb] -sticky news
	CreateSelectDBWidget "$w.refdb" "::search::dbase_($w)" "$ref_base"
	trace add variable ::search::dbase_($w) write ::search::use_dbfilter_
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
	ttk::button $w.buttons.save -text [::tr Save] -state normal \
		-command "::search::save_ $options_cmd"
	# Enable save button if the specific search module provides a save proc.
	# options_cmd is the command returned by the create_subwnd (eg "::search::headerGetOptions"
	# or "::search::boardOptions"). Try to derive the base module name and check for
	# a corresponding "::save" procedure (e.g. "::search::header::save").
	set save_cmd ""
	# Remove trailing GetOptions or Options to compute the module base name.
	if {[regsub {GetOptions$|Options$} $options_cmd "" base] > 0} {
		set candidate "${base}::save"
		if {[llength [info procs $candidate]] > 0 || [llength [info commands $candidate]] > 0} {
			set save_cmd $candidate
		}
	}
	if {$save_cmd ne ""} {
		# enable and bind directly to the module's save proc
		$w.buttons.save configure -state normal -command $save_cmd
	}
	ttk::button $w.buttons.reset_values -text [::tr Defaults] \
		-command "set ::search::filterOp_($w) reset; $options_cmd reset"
	ttk::button $w.buttons.load -text [::tr Load] -command "::search::load_ $options_cmd"
	ttk::button $w.buttons.make_default -text [::tr "Make Default"] -command "::search::makeDefault_ $options_cmd"
	ttk::button $w.buttons.search_new -text "[tr Search] ([tr GlistNewSort] [tr Filter])" \
		-command "::search::start_ 1 $w $options_cmd"
	ttk::button $w.buttons.search -text [::tr Search] \
		-command "::search::start_ 0 $w $options_cmd"
	grid $w.buttons.save $w.buttons.load $w.buttons.make_default $w.buttons.reset_values x $w.buttons.search_new $w.buttons.search -sticky w -padx "0 5"
	grid columnconfigure $w.buttons 2 -weight 1

	ttk::button $w.buttons.stop -text [::tr Stop] -command progressBarCancel
	canvas $w.progressbar -width 300 -height 20 -bg white -relief solid -border 1 -highlightthickness 0
	$w.progressbar create rectangle 0 0 0 0 -fill blue -outline blue -tags bar
	$w.progressbar create text 295 10 -anchor e -font font_Regular -tags time
	grid $w.buttons.stop -row 0 -column 0
	grid $w.progressbar -in $w.buttons -row 0 -column 1 -columnspan 4
	progressbar_ $w hide

	bind $w <Return> "$w.buttons.search invoke"
	bind $w.buttons.search <Destroy> "unset ::search::dbase_($w)"
	bind $w <<NotifyFilter>> [list apply {{w} {
		lassign %d dbase filter
		if {$dbase eq $::search::dbase_($w) && $filter eq $::search::filter_($w)} {
			::search::refresh_ $w
		}
	}} $w]

	::search::refresh_ $w
}

proc ::search::CloseAll {} {
	foreach {w} [array names ::search::dbase_] {
		destroy $w
	}
}

proc ::search::DatabaseModified {dbase} {
	foreach {w w_base} [array get ::search::dbase_] {
		if {$dbase == $w_base} {
			::search::refresh_ $w
		}
	}
}

proc ::search::refresh_ {w} {
	if {[catch {
		lassign [sc_filter sizes $::search::dbase_($w) $::search::filter_($w)] filterSz gameSz
	}]} {
		destroy $w
		return
	}
	set n_games [::windows::gamelist::formatFilterText $filterSz $gameSz]
	$w.filterOp configure -text "[::tr FilterOperation] ($n_games)"
}

proc ::search::use_dbfilter_ { unused1 w {unused2 ""} } {
	set ::search::filter_($w) dbfilter
}

proc ::search::progressbar_ {w show_hide} {
	if {$show_hide eq "show"} {
		grid remove $w.buttons.save
		grid remove $w.buttons.reset_values
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
		grid $w.buttons.reset_values
		grid $w.buttons.search_new
		grid $w.buttons.search
	}
}

proc ::search::save_ {options_cmd} {
	# options_cmd is the command returned by the create_subwnd (eg
	# "::search::headerGetOptions" or "::search::boardOptions").
	# Derive the base module name and call its ::save proc if present.
	if {[string length $options_cmd] == 0} {
		tk_messageBox -type ok -icon info -title [::tr Save] -message [::tr "Save not available for this dialog"]
		return
	}

	# Try to extract a base name: strip trailing GetOptions or Options
	if {[regexp {^(.+)(GetOptions|Options)$} $options_cmd -> base _]} {
		set candidate "${base}::save"
	} else {
		# Fallback: try to replace trailing Get... patterns conservatively
		set candidate "${options_cmd}::save"
	}

	# Try to invoke the computed candidate directly. If it fails, inform the user.
	if {[catch $candidate errMsg]} {
		# Diagnostic information to help understand why the module save failed.
		set procList [info procs $candidate]
		set cmdList  [info commands $candidate]
		set diagMsg "Failed invoking save candidate:\n$candidate\n\nError:\n$errMsg\n\nprocs found: [llength $procList]\ncommands found: [llength $cmdList]"
		# Show diagnostics in a message box (avoid writing temp debug files).
		tk_messageBox -type ok -icon error -title [::tr Save] -message $diagMsg
	}
}

proc ::search::load_ {options_cmd} {
	# Open a saved SearchOptions (.sso) file and source it to restore variables.
	set ftype { { "Scid SearchOptions files" {".sso"} } }
	set fName [tk_getOpenFile -initialdir [pwd] -filetypes $ftype -title "Open a SearchOptions file"]
	if {$fName == ""} { return }
	# Source the file in the global namespace so it sets variables like ::sWhite
	set nativeName [file nativename $fName]
	if {[catch {namespace eval :: [list source $nativeName]} errMsg]} {
		tk_messageBox -title "Error: Unable to load file" -type ok -icon error \
			-message "Unable to load SearchOptions file: $fName\n\nError:\n$errMsg"
		return
	}
	# Update combobox history so loaded values appear and are selected
	catch { ::utils::history::AddEntry HeaderSearchSite $::sSite }
	catch { ::utils::history::AddEntry HeaderSearchEvent $::sEvent }
	catch { ::utils::history::AddEntry HeaderSearchWhite $::sWhite }
	catch { ::utils::history::AddEntry HeaderSearchBlack $::sBlack }
	# After sourcing, the variables bound to widgets should update automatically.
	# Refresh any open search windows so UI reflects the loaded values.
	foreach w [array names ::search::dbase_] {
		catch { ::search::refresh_ $w }
		# If the window is a HeaderSearch, also re-run the create frame function
		# to ensure widgets reflect the newly loaded variables when necessary.
		if {[string match *.wnd_HeaderSearch $w] || [string match .wnd_HeaderSearch $w]} {
			if {[winfo exists $w]} {
				# try to re-evaluate header create frame to sync widgets
				catch { ::search::headerCreateFrame $w.options }
			}
		}
	}
	tk_messageBox -type ok -icon info -title "Search Options loaded" -message "Loaded: $fName"
}

proc ::search::makeDefault_ {options_cmd} {
	# Register current header search variables to be saved as options across restarts.
	# List of vars and arrays to persist:
	set vars {
		sWhite sBlack sEvent sSite sRound sAnnotated sDateMin sDateMax
		sResWin sResLoss sResDraw sResOther
		sWhiteEloMin sWhiteEloMax sBlackEloMin sBlackEloMax
		sEcoMin sEcoMax sEloDiffMin sEloDiffMax
		sIgnoreCol sSideToMoveW sSideToMoveB sGlMin sGlMax
		sTagName sTagValue ::search::filter::operation
		sPgntext sHeaderFlags sTitles
	}

	foreach v $vars {
		# Use fully-qualified options.store so we always register in global scope
		catch { ::options.store $v }
	}

	# Now write options file to persist the registered variables
	if {[catch { ::options.write } errMsg]} {
		tk_messageBox -type ok -icon error -title [::tr "Make Default"] -message "Unable to save defaults:\n$errMsg"
		return
	}

		# Previously we appended an explicit `set ::sSite [list $::sSite]` here
		# to force persistence of the scalar site preference. That explicit
		# append is no longer necessary because header prefs are registered
		# via ::options.store above and written by ::options.write. Removing
		# the manual append avoids duplicate/boilerplate entries in the
		# options file.

		# (debugging removed)

	# Try to apply them immediately by sourcing the options file.
	if {[catch { namespace eval :: [list source [scidConfigFile options]] } srcErr]} {
		# Not fatal; inform user that restart is required to apply.
		tk_messageBox -type ok -icon info -title [::tr "Make Default"] -message "Header search settings saved as defaults. Restart Scid to apply them on startup.\n\nSourcing options now failed: $srcErr"
		return
	}

		# After applying defaults, update history lists so comboboxes show the
		# new default as the selected/top entry.
		catch { ::utils::history::AddEntry HeaderSearchSite $::sSite }
		catch { ::utils::history::AddEntry HeaderSearchEvent $::sEvent }
		catch { ::utils::history::AddEntry HeaderSearchWhite $::sWhite }
		catch { ::utils::history::AddEntry HeaderSearchBlack $::sBlack }

		# Refresh open search windows to reflect applied defaults
	foreach w [array names ::search::dbase_] {
		catch { ::search::refresh_ $w }
	}

	tk_messageBox -type ok -icon info -title [::tr "Make Default"] -message "Header search settings saved as defaults and applied to current session."
}

proc ::search::start_ {new_filter w options_cmd} {
	set dbase $::search::dbase_($w)
	set src_filter $::search::filter_($w)
	set src_op $::search::filterOp_($w)

	if {$new_filter} {
		set dest_filter [sc_filter new $dbase]
	} else {
		set dest_filter [sc_filter compose $dbase $src_filter ""]
	}
	if {$dest_filter ne $src_filter && $src_op ne "reset"} {
		sc_filter copy $dbase $dest_filter $src_filter
	}

	lassign [$options_cmd] options ignore_color_hack
	if {$ignore_color_hack ne ""} {
		set filter_hack [sc_filter new $dbase]
		sc_filter copy $dbase $filter_hack $dest_filter
	}

	set err [catch {::search::do_search_ $dbase $dest_filter $src_op $options "::search::progressbar_ $w show"}]
	::search::progressbar_ $w hide
	if {$err} {
		if {$::errorCode != $::ERROR::UserCancel} { ERROR::MessageBox }
	}

	if {!$err && $ignore_color_hack ne ""} {
		set err [catch {::search::do_search_ $dbase $filter_hack $src_op $ignore_color_hack "::search::progressbar_ $w show"}]
		::search::progressbar_ $w hide
		if {$err} {
			if {$::errorCode != $::ERROR::UserCancel} { ERROR::MessageBox }
		} else {
			sc_filter or $dbase $dest_filter $filter_hack
		}
	}
	if {$ignore_color_hack ne ""} {
		sc_filter release $dbase $filter_hack
	}

	set ::search::filter_($w) $dest_filter
	::notify::filter $dbase $dest_filter

	if {$new_filter} {
		::windows::gamelist::Open $dbase $dest_filter
	}
}

proc ::search::do_search_ {dbase filter filter_op options reset_progressbar} {
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

	set tag_pairs [lsearch -all -inline -index 0 -exact $options "-tag_pair"]
	if {[llength tag_pairs] > 0} {
		set options [lsearch -all -inline -index 0 -not -exact $options "-tag_pair"]
	}

	{*}$reset_progressbar
	sc_filter search $dbase $filter {*}$options -filter AND
	foreach {elem} $tag_pairs {
		{*}$reset_progressbar
		lassign $elem -> tagName tagValue
		sc_filter search $dbase $filter tags $tagName $tagValue
	}

	if {[info exists or_filter]} {
		sc_filter or $dbase $filter $or_filter
		sc_filter release $dbase $or_filter
	}
}


# ::search::board
#   Opens the search window for the current board position.
#
proc ::search::board {{ref_base ""} {ref_filter "dbfilter"}} {
	::search::Open $ref_base $ref_filter BoardSearch ::search::boardCreateFrame
}

proc ::search::boardCreateFrame {w} {
	if {![info exists ::search::boardOptType_]} {
		::search::boardOptions reset
	}

	ttk::labelframe $w.pos -text [::tr SearchType]
	grid $w.pos -sticky news -pady 6
	grid columnconfigure $w 0 -weight 1

	ttk::radiobutton $w.pos.exact -textvar ::tr(SearchBoardExact)  -variable ::search::boardOptType_ -value Exact
	ttk::radiobutton $w.pos.pawns -textvar ::tr(SearchBoardPawns)  -variable ::search::boardOptType_ -value Pawns
	ttk::radiobutton $w.pos.files -textvar ::tr(SearchBoardFiles)  -variable ::search::boardOptType_ -value Fyles
	ttk::radiobutton $w.pos.material -textvar ::tr(SearchBoardAny) -variable ::search::boardOptType_ -value Material
	grid $w.pos.exact -sticky w
	grid $w.pos.pawns -sticky w
	grid $w.pos.files -sticky w
	grid $w.pos.material -sticky w

	ttk::checkbutton $w.vars -text [::tr LookInVars] -variable ::search::boardOptInVars_ -onvalue 1 -offvalue 0
	grid $w.vars -sticky w

	ttk::checkbutton $w.flip -text [::tr IgnoreColors] -variable ::search::boardOptIgnoreCol_ -onvalue 1 -offvalue 0
	grid $w.flip -sticky w

	return "::search::boardOptions"
}

proc ::search::boardOptions {{cmd ""}} {
	if {$cmd eq "reset"} {
		set ::search::boardOptType_ Exact
		set ::search::boardOptInVars_ 0
		set ::search::boardOptIgnoreCol_ 0
		return
	}

	set options {board}
	lappend options $::search::boardOptType_
	lappend options $::search::boardOptInVars_
	lappend options $::search::boardOptIgnoreCol_
	return [list $options]
}
