#
# Copyright (C) 2014 Fulvio Benini
#
# This file is part of Scid (Shane's Chess Information Database).
# Scid is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.


# CUSTOMIZATION:
# By editing this file you can customize the keyboard shortcuts,
# in order to best suit your preferences.
# It is not necessary to recompile scid after changing this file.

proc keyboardShortcuts {w} {
	# Go back one move
	bind $w <Left> {
		eval [excludeTextWidget %W]
		::move::Back;
		break
	}

	# Go forward one move
	bind $w <Right> {
		eval [excludeTextWidget %W]
		::move::Forward
		break
	}

	bind $w <Up> {
		eval [excludeTextWidget %W]
		::move::Back 10
		break
	}

	bind $w <Down> {
		eval [excludeTextWidget %W]
		::move::Forward 10
		break
	}

	# Exit Variation/Go to game start
	bind $w <Home> {
		eval [excludeTextWidget %W]
		if {[::move::ExitVar] != 0} { break }
		::move::Start
		break
	}

	# Go to game end
	bind $w <End> {
		eval [excludeTextWidget %W]
		::move::End
		break
	}

	# Go to previous game
	bind $w <Alt-Left>	{ ::game::LoadHistory -1; break }

	# Go to next game
	bind $w <Alt-Right> { ::game::LoadHistory +1; break }

	# Close Scid
	bind $w <Alt-F4> { ::file::Exit }

	# Create a new database
	bind $w <Control-n> { ::file::New }

	# Open a database
	bind $w <Control-o> { ::file::Open }

	# Close the current database
	# TODO: is better to use control-w to close the focused window?
	bind $w <Control-w> { ::file::Close }

	# Undo
	bind $w <Control-z> { undoFeature undo }

	# Redo
	bind $w <Control-y> { undoFeature redo }

	# Save current game
	bind $w <Control-s> { ::gameReplace }

	# Save current game as new
	bind $w <Control-S> { ::gameAdd }

	# Toggle fullscreen
	bind $w <F11> { wm attributes . -fullscreen [expr ![wm attributes . -fullscreen]] }

	# Rotate the chess board
	bind $w <period> {
		eval [excludeTextWidget %W]
		toggleRotateBoard
		break
	}

	# Open "Setup Board" dialog
	bind $w <s> {
		eval [excludeTextWidget %W]
		::setupBoard
		break
	}


	# Open the enter/create variation dialog
	# TODO: <v> is not intuitive: <space> or <up> <down> may be better
	bind $w <KeyPress-v> {
		eval [excludeTextWidget %W]
		::showVars
		break
	}

	# Change current database
	set totalBaseSlots [sc_base count total]
	for {set i 1} { $i <= $totalBaseSlots} {incr i} {
		bind $w <Control-Key-$i> "::file::SwitchToBase $i"
	}

	#TODO: to be checked
	bind $w <F6>	::book::open
	bind $w <F12> ::CorrespondenceChess::CCWindow
	bind $w <Control-F12> {::CorrespondenceChess::OpenCorrespondenceDB; ::CorrespondenceChess::ReadInbox}
	bind $w <Alt-F12> {::CorrespondenceChess::OpenCorrespondenceDB;	::CorrespondenceChess::FetchGames}
	bind $w <Control-equal> ::tb::Open
	bind $w <Control-d> ::windows::switcher::Open
	bind $w <Control-e> makeCommentWin
	bind $w <Control-i> ::windows::stats::Open
	bind $w <Control-l> ::windows::gamelist::Open
	bind $w <Control-m> ::maint::OpenClose
	bind $w <Control-p> ::pgn::OpenClose
	bind $w <Control-t> ::tree::make
	bind $w <Control-E> ::windows::eco::OpenClose
	bind $w <Control-K> ::ptrack::make
	bind $w <Control-O> ::optable::makeReportWin
	bind $w <Control-P> ::plist::toggle
	bind $w <Control-T> ::tourney::toggle
	bind $w <Control-X> crosstabWin


	#TODO: to be improved
	bind $w <F2> "::makeAnalysisWin 1 0"
	bind $w <F3> "::makeAnalysisWin 2 0"
	bind $w <F4> { if {[winfo exists .analysisWin1]} { .analysisWin1.b1.bStartStop invoke } }
	bind $w <F5> { if {[winfo exists .analysisWin2]} { .analysisWin2.b1.bStartStop invoke } }
	bind $w <Control-A> makeAnalysisWin
	bind $w <Control-Shift-2>	"makeAnalysisWin 2"
	bind $w <Control-a> {sc_var create; updateBoard -pgn}


	#TODO: are these shortcuts useful?
	bind $w <Control-B> ::search::board
	bind $w <Control-H> ::search::header
	bind $w <Control-M> ::search::material
	bind $w <Control-KeyPress-U> ::search:::usefile

	bind $w <Control-C> ::copyFEN
	bind $w <Control-V> ::pasteFEN
	bind $w <Control-E> ::tools::email
	bind $w <Control-I> importPgnGame
	bind $w <Control-D> {sc_move ply [sc_eco game ply]; updateBoard}
	bind $w <Control-G> tools::graphs::filter::Open
	bind $w <Control-J> tools::graphs::absfilter::Open
	bind $w <Control-u> ::game::GotoMoveNumber
	bind $w <Control-Y> findNovelty
	bind $w <F1> {helpWindow Contents}
	bind $w <Control-N> nameEditor

	bind $w <Control-slash> ::file::finder::Open
	bind $w <Control-Shift-Up> {::game::LoadNextPrev first}
	bind $w <Control-Shift-Down> {::game::LoadNextPrev last}
	bind $w <Control-Up> {::game::LoadNextPrev previous}
	bind $w <Control-Down> {::game::LoadNextPrev next}
	bind $w <Control-question> ::game::LoadRandom

	#TODO: this bind should not be global
	# Add null move (also "king take king" move)
	bind $w <minus><minus> { addMove null null }

	bind $w <exclam><Return> "sc_pos addNag !; updateBoard -pgn"
	bind $w <exclam><exclam><Return> "sc_pos addNag !!; updateBoard -pgn"
	bind $w <exclam><question><Return> "sc_pos addNag !?; updateBoard -pgn"
	bind $w <question><Return> "sc_pos addNag ?; updateBoard -pgn"
	bind $w <question><question><Return> "sc_pos addNag ??; updateBoard -pgn"
	bind $w <question><exclam><Return> "sc_pos addNag ?!; updateBoard -pgn"
	bind $w <plus><minus> "sc_pos addNag +-; updateBoard -pgn"
	bind $w <plus><slash> "sc_pos addNag +/-; updateBoard -pgn"
	bind $w <plus><equal> "sc_pos addNag +=; updateBoard -pgn"
	bind $w <equal><Return> "sc_pos addNag =; updateBoard -pgn"
	bind $w <minus><plus> "sc_pos addNag -+; updateBoard -pgn"
	bind $w <minus><slash> "sc_pos addNag -/+; updateBoard -pgn"
	bind $w <equal><plus> "sc_pos addNag =+; updateBoard -pgn"
	bind $w <asciitilde><Return> "sc_pos addNag ~; updateBoard -pgn"
	bind $w <asciitilde><equal><Return> "sc_pos addNag ~=; updateBoard -pgn"
}

proc excludeTextWidget {w} {
	if { [regexp ".*(Entry|Text|Combobox)" [winfo class $w] ] } {
		return "continue"
	}
}
