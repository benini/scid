# Scid Pocket (C) 2007 Pascal Georges
### Based on Scid (C) Shane Hudson
#
###
### book.tcl: part of Scid.
### Copyright (C) 2007  Pascal Georges
###
######################################################################
### Book window

namespace eval book {
  set isOpen 0
  set bookList ""
  set bookPath ""
  set currentBook "" ; # book in form abc.bin
  set bookMoves ""
  set cancelBookExport 0
  set exportCount 0
  set exportMax 3000
  set hashList ""
  set bookSlot 0
  
  ################################################################################
  # open a book, closing any previously opened one (called by annotation analysis)
  # arg name : gm2600.bin for example
  ################################################################################
  proc scBookOpen { name slot } {
    
    if {$slot == $::book::bookSlot} {
      if {$::book::currentBook != ""} {
        sc_book close $::book::bookSlot
      }
      set ::book::currentBook $name
    }
    
    set bn [ file join  $::instalDir "books" $name ]
    sc_book load $bn $slot
  }
  
  ################################################################################
  # Return a move in book for position fen. If there is no move in book, returns ""
  # Is used by engines, not book windows
  ################################################################################
  proc getMove { book fen slot} {
    set tprob 0
    ::book::scBookOpen $book $slot
    set bookmoves [sc_book moves $slot]
    if {[llength $bookmoves] == 0} {
      return ""
    }

    set r [expr {(int (rand() * 100))} ]
    for {set i 0} {$i<[llength $bookmoves]} {incr i 2} {
      set m [lindex $bookmoves $i]
      set prob [string range [lindex $bookmoves [expr $i + 1] ] 0 end-1 ]
      incr tprob $prob
      if { $tprob >= $r } {
        break
      }
    }
    sc_book close $slot
    return $m
  }
  
  ################################################################################
  #
  ################################################################################
  proc closeMainBook {} {
    if { $::book::currentBook == "" } { return }
    sc_book close $::book::bookSlot
    set ::book::isOpen 0
    set ::book::currentBook ""
  }
  ################################################################################
  #
  ################################################################################
  proc makeBookMove { move } {
    set action "replace"
    if {![sc_pos isAt vend]} { set action [confirmReplaceMove] }
    if {$action == "replace"} {
      sc_move addSan $move
    } elseif {$action == "var"} {
      sc_var create
      sc_move addSan $move
    } elseif {$action == "mainline"} {
      sc_var create
      sc_move addSan $move
      sc_var exit
      sc_var promote [expr {[sc_var count] - 1}]
      sc_move forward 1
    }
    ::board::updateBoard -pgn
    destroy .bookWin
  }
  ################################################################################
  #
  ################################################################################
  proc bookSelect { { n "" }  { v  0} } {
    scBookOpen $::options(mainBook) $::book::bookSlot    
  }
}
###
### End of file: book.tcl
###