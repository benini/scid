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
  set currentTuningBook ""
  set bookMoves ""
  set cancelBookExport 0
  set exportCount 0
  set exportMax 3000
  set hashList ""
  set bookSlot 0
  set bookTuningSlot 2
  
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
    if {$slot == $::book::bookTuningSlot} {
      if {$::book::currentTuningBook != ""} {
        sc_book close $::book::bookTuningSlot
      }
      set ::book::currentTuningBook $name
    }
    
    set bn [ file join $::scidBooksDir $name ]
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
  #  Open a window to select book and display book moves
  # arg name : gm2600.bin for example
  ################################################################################
  proc open { {name ""} } {
    global ::book::bookList ::book::bookPath ::book::currentBook ::book::isOpen
    
    set w .bookWin
    
    if {[winfo exists $w]} { return }
    
    set ::book::isOpen 1
    
    toplevel $w
    wm title $w $::tr(Book)
    wm resizable $w 0 1
    
    setWinLocation $w
    bind $w <Configure> "recordWinSize $w"
    bind $w <F1> { helpWindow Book }
    
    frame $w.f
    # load book names
    set bookPath $::scidBooksDir
    ::combobox::combobox $w.f.combo -editable false -width 12
    set bookList [  lsort -dictionary [ glob -nocomplain -directory $bookPath *.bin ] ]
    set i 0
    set idx 0
    foreach file  $bookList {
      set f [ file tail $file ]
      $w.f.combo list insert end $f
      if {$name == $f} {
        set idx $i
      }
      incr i
    }
    
    $w.f.combo select $idx
    pack $w.f.combo
    
    # text displaying book moves
    text $w.f.text -wrap word -state disabled -width 12
    pack $w.f.text -expand yes -fill both
    
    pack $w.f
    
    $w.f.combo configure -command ::book::bookSelect
    bind $w <Destroy> "::book::closeMainBook"
    bind $w <Escape> { destroy  .bookWin }
    if { [catch {bookSelect} ] } {
      tk_messageBox -title "Scid" -type ok -icon error -message "No books found. Check books directory"
      set ::book::isOpen 0
      set ::book::currentBook ""
      destroy  .bookWin
    }
  }
  ################################################################################
  #
  ################################################################################
  proc closeMainBook {} {
    if { $::book::currentBook == "" } { return }
    focus .
    sc_book close $::book::bookSlot
    set ::book::isOpen 0
    set ::book::currentBook ""
  }
  ################################################################################
  #   updates book display when board changes
  ################################################################################
  proc refresh {} {
    global ::book::bookMoves
    
    foreach t [.bookWin.f.text tag names] {
      if { [string match "bookMove*" $t] } {
        .bookWin.f.text tag delete $t
      }
    }
    set bookMoves [sc_book moves $::book::bookSlot]
    .bookWin.f.text configure -state normal
    .bookWin.f.text delete 1.0 end
    for {set i 0} {$i<[llength $bookMoves]} {incr i 2} {
      set line [expr $i /2 +1]
      set m ""
      append m [::trans [lindex $bookMoves $i]] "\t" [lindex $bookMoves [expr $i + 1] ] "\n"
      .bookWin.f.text insert end $m
      .bookWin.f.text tag add bookMove$line $line.0 $line.end
      .bookWin.f.text tag bind bookMove$line <ButtonPress-1> "::book::makeBookMove [lindex $bookMoves $i]"
    }
    .bookWin.f.text configure -state disabled -height [expr [llength $bookMoves] / 2 ]
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
    updateBoard -pgn -animate
    ::utils::sound::AnnounceNewMove $move
    if {$action == "replace"} { ::tree::doTraining }
  }
  ################################################################################
  #
  ################################################################################
  proc bookSelect { { n "" }  { v  0} } {
    scBookOpen [.bookWin.f.combo get] $::book::bookSlot
    refresh
  }
  ################################################################################
  #
  ################################################################################
  proc tuning { {name ""} } {
    global ::book::bookList ::book::bookPath ::book::currentBook ::book::isOpen
    
    set w .bookTuningWin
    
    if {[winfo exists $w]} {
      return
    }
    
    toplevel $w
    wm title $w $::tr(Book)
    # wm resizable $w 0 0
    
    bind $w <F1> { helpWindow BookTuningWindow }
    setWinLocation $w
    
    frame $w.fcombo
    frame $w.f
    # load book names
    set bookPath $::scidBooksDir
    ::combobox::combobox $w.fcombo.combo -editable false -width 0
    pack $w.fcombo.combo -expand yes -fill x
    set bookList [  lsort -dictionary [ glob -nocomplain -directory $bookPath *.bin ] ]
    set i 0
    set idx 0
    foreach file  $bookList {
      set f [ file tail $file ]
      $w.fcombo.combo list insert end $f
      if {$name == $f} {
        set idx $i
      }
      incr i
    }
    
    $w.fcombo.combo select $idx
    
    frame $w.fbutton
    button $w.fbutton.bExport -text $::tr(Export) -command ::book::export
    button $w.fbutton.bSave -text $::tr(Save) -command ::book::save
    pack $w.fbutton.bExport $w.fbutton.bSave -side top -fill x -expand yes
    
    pack $w.fcombo $w.f $w.fbutton -side top
    
    $w.fcombo.combo configure -command ::book::bookTuningSelect
    bind $w <Destroy> "::book::closeTuningBook"
    bind $w <Escape> { destroy  .bookTuningWin }
    bind $w <F1> { helpWindow BookTuning }

    bookTuningSelect
    
  }
  ################################################################################
  #
  ################################################################################
  proc closeTuningBook {} {
    if { $::book::currentTuningBook == "" } { return }
    focus .
    sc_book close $::book::bookTuningSlot
    set ::book::currentTuningBook ""
  }
  ################################################################################
  #
  ################################################################################
  proc bookTuningSelect { { n "" }  { v  0} } {
    scBookOpen [.bookTuningWin.fcombo.combo get] $::book::bookTuningSlot
    refreshTuning
  }
  ################################################################################
  #   updates book display when board changes
  ################################################################################
  proc refreshTuning {} {
    set moves [sc_book moves $::book::bookTuningSlot]
    
    set w .bookTuningWin
    bind $w <Destroy> "" ;# avoid the closing of the book
    # erase previous children
    set children [winfo children $w.f]
    foreach c $children {
      destroy $c
    }
    
    set row 0
    for {set i 0} {$i<[llength $moves]} {incr i 2} {
      label $w.f.m$row -text [::trans [lindex $moves $i]]
      bind $w.f.m$row <ButtonPress-1> " ::book::makeBookMove [lindex $moves $i] "
      spinbox $w.f.sp$row -from 0 -to 100 -width 3
      set pct [lindex $moves [expr $i+1] ]
      set value [string replace $pct end end ""]
      $w.f.sp$row set $value
      grid $w.f.m$row -row $row -column 0 -sticky w
      grid $w.f.sp$row -row $row -column 1 -sticky w
      incr row
    }
    
  }
  ################################################################################
  # sends to book the list of updated probs in order. As the list of moves is in the same order, no need
  # to send the moves.
  ################################################################################
  proc save {} {
    set prob {}
    set w .bookTuningWin
    set children [winfo children $w.f]
    set count [expr [llength $children] / 2]
    for {set row 0} {$row < $count} {incr row} {
      lappend prob [$w.f.sp$row get]
    }
    sc_book update $prob $::book::bookTuningSlot
  }
  ################################################################################
  #
  ################################################################################
  proc export {} {
    ::windows::gamelist::Refresh
    updateTitle
    progressWindow "Scid" "ExportingBook..." $::tr(Cancel) "::book::sc_progressBar"
    set ::book::cancelBookExport 0
    set ::book::exportCount 0
    ::book::book2pgn
    set ::book::hashList ""
    closeProgressWindow
    if { $::book::exportCount >= $::book::exportMax } {
      tk_messageBox -title "Scid" -type ok -icon info \
          -message "$::tr(Movesloaded)  $::book::exportCount\n$::tr(BookPartiallyLoaded)"
    } else  {
      tk_messageBox -title "Scid" -type ok -icon info -message "$::tr(Movesloaded)  $::book::exportCount"
    }
    updateBoard -pgn
  }
  ################################################################################
  #
  ################################################################################
  proc book2pgn { } {
    global ::book::hashList
    
    if {$::book::cancelBookExport} { return  }
    if { $::book::exportCount >= $::book::exportMax } {
      return
    }
    set hash [sc_pos hash]
    if {[lsearch -sorted -integer -exact $hashList $hash] != -1} {
      return
    } else  {
      lappend hashList $hash
      set hashList [lsort -integer -unique $hashList]
    }
    
    set bookMoves [sc_book moves $::book::bookTuningSlot]
    incr ::book::exportCount
    if {[expr $::book::exportCount % 50] == 0} {
      updateProgressWindow $::book::exportCount $::book::exportMax
      updateBoard
      update
    }
    if {[llength $bookMoves] == 0} { return }
    
    for {set i 0} {$i<[llength $bookMoves]} {incr i 2} {
      set move [lindex $bookMoves $i]
      if {$i == 0} {
        sc_move addSan $move
        book2pgn
        sc_move back
      } else  {
        sc_var create
        sc_move addSan $move
        book2pgn
        sc_var exit
      }
    }
    
  }
  ################################################################################
  # cancel book export
  ################################################################################
  proc sc_progressBar {} {
    set ::book::cancelBookExport 1
  }
}
###
### End of file: book.tcl
###
