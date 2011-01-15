###
### search/board.tcl: Board Search routines for Scid.
###

set searchInVars 0
set sBoardIgnoreCols 0
set sBoardSearchType Exact
set sBoardSearchRefBase 0

# ::search::board
#   Opens the search window for the current board position.
#
proc ::search::board {} {
  global glstart searchInVars sBoardType sBoardIgnoreCols
  
  set w .sb
  if {[winfo exists $w]} {
    wm deiconify $w
    raiseWin $w
    return
  }
  
  toplevel $w
  wm title $w "Scid: $::tr(BoardSearch)"
  
  bind $w <Escape> "$w.b.cancel invoke"
  bind $w <Return> "$w.b.search invoke"
  bind $w <F1> { helpWindow Searches Board }
  
  ttk::label $w.type -textvar ::tr(SearchType) -font font_Bold -anchor center
  pack $w.type -side top -expand 1 -fill x
  pack [ttk::frame $w.g] -side top -fill x
  ttk::radiobutton $w.g.exact -textvar ::tr(SearchBoardExact) -variable sBoardSearchType -value Exact
  ttk::radiobutton $w.g.pawns -textvar ::tr(SearchBoardPawns) -variable sBoardSearchType -value Pawns
  ttk::radiobutton $w.g.files -textvar ::tr(SearchBoardFiles) -variable sBoardSearchType -value Fyles
  ttk::radiobutton $w.g.material -textvar ::tr(SearchBoardAny) -variable sBoardSearchType -value Material
  set row 0
  foreach i {exact pawns files material} {
    grid $w.g.$i -row $row -column 0 -sticky w
    incr row
  }
  addHorizontalRule $w
  
  pack [ttk::frame $w.refdb] -side top -fill x
  ttk::checkbutton $w.refdb.cb -textvar ::tr(SearchInRefDatabase) -variable sBoardSearchRefBase
  set listbases {}
  # populate the combobox
  for {set i 1} {$i <= [sc_base count total]} {incr i} {
    if {[sc_base inUse $i]} {
      set fname [file tail [sc_base filename $i]]
      lappend listbases "$i $fname"
    }
  }
  ttk::combobox $w.refdb.lb -textvariable refDatabase -values $listbases
  $w.refdb.lb current 0
  
  pack $w.refdb.cb $w.refdb.lb -side left
  addHorizontalRule $w
  
  ::search::addFilterOpFrame $w
  addHorizontalRule $w
  
  ### Progress bar:
  
  ttk::frame $w.fprogress
  canvas $w.fprogress.progress -height 20 -width 300 -bg white -relief solid -border 1
  $w.fprogress.progress create rectangle 0 0 0 0 -fill blue -outline blue -tags bar
  $w.fprogress.progress create text 295 10 -anchor e -font font_Regular -tags time -fill black -text "0:00 / 0:00"
  pack $w.fprogress.progress -side top -anchor center -expand 1 -pady 2
  
  ttk::frame $w.b2
  pack $w.b2 -side top -fill x
  ttk::frame $w.b
  pack $w.b -side top -fill x
  ttk::checkbutton $w.b2.vars -textvar ::tr(LookInVars) -onvalue 1 -offvalue 0 -variable searchInVars
  ttk::checkbutton $w.b2.flip -textvar ::tr(IgnoreColors) -onvalue 1 -offvalue 0 -variable sBoardIgnoreCols
  
  dialogbutton $w.b.stop -textvar ::tr(Stop) -command sc_progressBar
  $w.b.stop configure -state disabled
  
  dialogbutton $w.b.search -textvar ::tr(Search) -command {
    busyCursor .
    .sb.b.stop configure -state normal
    grab .sb.b.stop
    sc_progressBar .sb.fprogress.progress bar 301 21 time
    
    set base ""
    if { $sBoardSearchRefBase } {
      set base [lindex $refDatabase 0]
      set str [sc_search board $::search::filter::operation $sBoardSearchType $searchInVars $sBoardIgnoreCols $base]
    } else  {
      set str [sc_search board $::search::filter::operation $sBoardSearchType $searchInVars $sBoardIgnoreCols ]
    }
    unbusyCursor .
    grab release .sb.b.stop
    .sb.b.stop configure -state disabled
    #tk_messageBox -type ok -title $::tr(SearchResults) -message $str
    .sb.status configure -text $str
    set glstart 1
	 ::tree::refresh
    ::windows::gamelist::Refresh
    set gamesFound [lindex $str 0]
    if { $sBoardSearchRefBase && $gamesFound != 0} {
      ::file::SwitchToBase $base
      ::search::loadFirstGame
    }
    
    ::windows::stats::Refresh
  }
  dialogbutton $w.b.cancel -textvar ::tr(Close) -command "focus .; destroy $w"
  pack $w.b2.vars $w.b2.flip -side left -pady 2 -padx 5
  packbuttons right $w.b.cancel .sb.b.search .sb.b.stop
  pack $w.fprogress -side top -fill x
  ttk::label $w.status -text "" -width 1 -font font_Small -relief sunken -anchor w
  pack $w.status -side bottom -fill x
  wm resizable $w 0 0
  # standardShortcuts $w
  ::search::Config
  focus $w.b.search
}
