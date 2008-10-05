###
### search/board.tcl: Board Search routines for Scid.
###

set searchInVars 0
set sBoardIgnoreCols 0
set sBoardSearchType Exact

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
  
  label $w.type -textvar ::tr(SearchType) -font font_Bold
  pack $w.type -side top
  pack [frame $w.g] -side top -fill x
  radiobutton $w.g.exact -textvar ::tr(SearchBoardExact) \
      -variable sBoardSearchType -value Exact
  radiobutton $w.g.pawns -textvar ::tr(SearchBoardPawns) \
      -variable sBoardSearchType -value Pawns
  radiobutton $w.g.files -textvar ::tr(SearchBoardFiles) \
      -variable sBoardSearchType -value Fyles
  radiobutton $w.g.material -textvar ::tr(SearchBoardAny) \
      -variable sBoardSearchType -value Material
  set row 0
  foreach i {exact pawns files material} {
    grid $w.g.$i -row $row -column 0 -sticky w
    incr row
  }
  addHorizontalRule $w
  
  ::search::addFilterOpFrame $w
  addHorizontalRule $w
  
  ### Progress bar:
  
  canvas $w.progress -height 20 -width 300 -bg white -relief solid -border 1
  $w.progress create rectangle 0 0 0 0 -fill blue -outline blue -tags bar
  $w.progress create text 295 10 -anchor e -font font_Regular -tags time \
      -fill black -text "0:00 / 0:00"
  
  frame $w.b2
  pack $w.b2 -side top
  frame $w.b
  pack $w.b -side top -fill x
  checkbutton $w.b2.vars -textvar ::tr(LookInVars) -padx 10 -pady 5 \
      -onvalue 1 -offvalue 0 -variable searchInVars
  checkbutton $w.b2.flip -textvar ::tr(IgnoreColors) -padx 10 -pady 5 \
      -onvalue 1 -offvalue 0 -variable sBoardIgnoreCols
  
  dialogbutton $w.b.stop -textvar ::tr(Stop) -command sc_progressBar
  $w.b.stop configure -state disabled
  
  dialogbutton $w.b.search -textvar ::tr(Search) -command {
    busyCursor .
    .sb.b.stop configure -state normal
    grab .sb.b.stop
    sc_progressBar .sb.progress bar 301 21 time
    set str [sc_search board \
        $::search::filter::operation \
        $sBoardSearchType $searchInVars $sBoardIgnoreCols]
    unbusyCursor .
    grab release .sb.b.stop
    .sb.b.stop configure -state disabled
    #tk_messageBox -type ok -title $::tr(SearchResults) -message $str
    .sb.status configure -text $str
    set glstart 1
    ::windows::gamelist::Refresh
    
    ::search::loadFirstGame
    
    ::windows::stats::Refresh
  }
  dialogbutton $w.b.cancel -textvar ::tr(Close) -command "focus .; destroy $w"
  pack $w.b2.vars $w.b2.flip -side left -pady 2 -padx 5
  packbuttons right $w.b.cancel .sb.b.search .sb.b.stop
  pack $w.progress -side top -pady 2
  label $w.status -text "" -width 1 -font font_Small -relief sunken -anchor w
  pack $w.status -side bottom -fill x
  wm resizable $w 0 0
  standardShortcuts $w
  ::search::Config
  focus $w.b.search
}
