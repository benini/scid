### ScidPocket.
### Copyright (C) 2007  Pascal Georges
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
  wm title $w "Scid: Board search"
  ::ui::setFullSize $w
  
  pack [ttk::notebook $w.nb] -fill both -expand 1
  
  # --------- Exec search -----------------
  $w.nb add [ttk::frame $w.nb.frun] -text [::msgcat::mc "run"] -sticky nsew
  
  ### Progress bar:
  
  canvas $w.nb.frun.progress -height 20 -width 200 -bg white -relief solid -border 1
  $w.nb.frun.progress create rectangle 0 0 0 0 -fill blue -outline blue -tags bar
  $w.nb.frun.progress create text 195 10 -anchor e -tags time -fill black -text "0:00 / 0:00"
  
  ttk::frame $w.nb.frun.b2
  pack $w.nb.frun.b2 -side top -fill x
  ttk::frame $w.nb.frun.b
  pack $w.nb.frun.b -side top -fill x
  
  ttk::checkbutton $w.nb.frun.b2.vars -text [::msgcat::mc "Look in variations"] -onvalue 1 -offvalue 0 -variable searchInVars
  ttk::checkbutton $w.nb.frun.b2.flip -text [::msgcat::mc "Ignore colors"] -onvalue 1 -offvalue 0 -variable sBoardIgnoreCols
  
  ttk::button $w.nb.frun.b.stop -text [::msgcat::mc Stop] -command sc_progressBar
  $w.nb.frun.b.stop configure -state disabled
  
  ttk::button $w.nb.frun.b.search -text [::msgcat::mc Search] -command {
    set w .sb
    busyCursor $w
    $w.nb.frun.b.stop configure -state normal
    grab $w.nb.frun.b.stop
    sc_progressBar $w.nb.frun.progress bar 201 21 time
    set str [sc_search board $::search::filter::operation $sBoardSearchType $searchInVars $sBoardIgnoreCols]
    unbusyCursor $w
    grab release $w.nb.frun.b.stop
    $w.nb.frun.b.stop configure -state disabled
    tk_messageBox -type ok -title "Search results" -parent .sb -message $str
    set glstart 1
  }
  ttk::button $w.nb.frun.b.cancel -text [::msgcat::mc Close] -command "focus .; destroy .sb"
  pack $w.nb.frun.b2.vars $w.nb.frun.b2.flip -side left
  
  grid $w.nb.frun.b.search -column 0 -row 0 -sticky ew
  grid $w.nb.frun.b.stop   -column 1 -row 0 -sticky ew
  grid $w.nb.frun.b.cancel -column 0 -row 1 -sticky ew
  pack $w.nb.frun.progress -side top 
  
  # --------- Search type -----------------
  $w.nb add [ttk::frame $w.nb.ftype] -text [::msgcat::mc "type"] -sticky nsew
  
  ttk::label $w.nb.ftype.type -text [::msgcat::mc "Search type:"]
  pack $w.nb.ftype.type -side top -fill x
  pack [ttk::frame $w.nb.ftype.g] -side top -fill both
  ttk::radiobutton $w.nb.ftype.g.exact -text [::msgcat::mc "Exact position (all\npieces on same squares)"] -variable sBoardSearchType -value Exact
  ttk::radiobutton $w.nb.ftype.g.pawns -text [::msgcat::mc "Pawns (same material,\n all pawns on same squares)"] -variable sBoardSearchType -value Pawns
  ttk::radiobutton $w.nb.ftype.g.files -text [::msgcat::mc "Files (same material,\n all pawns on same files)"] -variable sBoardSearchType -value Fyles
  ttk::radiobutton $w.nb.ftype.g.material -text [::msgcat::mc "Any (same material,\n pawns and pieces anywhere)"] -variable sBoardSearchType -value Material
  set row 0
  foreach i {exact pawns files material} {
    grid $w.nb.ftype.g.$i -row $row -column 0 -sticky ew
    incr row
  }

  # ----------------- Filter operation -------------  
  ::search::addFilterOpNoteBook $w.nb
  
  ::search::Config
  focus $w.nb.frun.b.search
}
