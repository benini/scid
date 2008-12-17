############################################################
### Comment Editor window

namespace eval ::commenteditor {
  
  namespace export open close update storeComment addNag
  
  # List of colors and types used to mark a square
  
  variable  colorList {}  markTypeList {}
  lappend   colorList red orange yellow   \
      green blue darkBlue \
      purple white black
  # Each list is a set of buttons in the dialog menu:
  lappend   markTypeList [list full circle disk x + - = ? !]
  lappend   markTypeList [list 1 2 3 4 5 6 7 8 9]
  
  # IO state of the comment editor
  variable  State
  array set State [list isOpen 0 \
      markColor red  markType full  text "" \
      pending ""]
  
  proc addMark {args} {eval ::board::mark::add $args}
  proc delMark {args} {eval ::board::mark::remove $args}
}

proc ::commenteditor::addNag {nag} {
  if {![winfo exists .commentWin]} { return }
  .commentWin.nf.tf.text insert end "$nag  "
  ::commenteditor::storeComment
  ::pgn::Refresh 1
}

proc makeCommentWin {} {
  if {[winfo exists .commentWin]} {
    # ::commenteditor::close
    focus .
    destroy .commentWin
  } else {
    ::commenteditor::Open
  }
}

# ::commenteditor::Open --
#
proc ::commenteditor::Open {} {
  global commentWin nagValue highcolor helpMessage
  variable colorList
  variable markTypeList
  variable State
  
  set commentWin 1
  set State(isOpen) 1
  if {[winfo exists .commentWin]} {
    focus .commentWin.cf.text
    return
  }
  set w .commentWin
  ::createToplevel $w
  setWinLocation $w
  bind $w <F1> {helpWindow Comment}
  bind $w <Destroy> [namespace code {set commentWin 0; set State(isOpen) 0}]
  bind $w <Configure> "recordWinSize $w"
  
  set mark [ttk::frame $w.markFrame]
  pack $mark -side left -fill both -expand 1 -padx 1 -anchor n
  
  # Comment frame:
  ttk::frame $w.cf
  text $w.cf.text -width $::winWidth($w) -height $::winHeight($w) -background white -wrap word -font font_Regular \
      -yscrollcommand ".commentWin.cf.scroll set" -setgrid 1
  ttk::scrollbar $w.cf.scroll -command ".commentWin.cf.text yview"
  ttk::label $w.cf.label -font font_Bold -textvar ::tr(Comment)
  bindFocusColors $w.cf.text
  bind $w.cf.text <Alt-KeyRelease-c> { .commentWin.b.close invoke }
  bind $w.cf.text <Alt-KeyRelease-s> { .commentWin.b.store invoke }
  
  # NAG frame:
  ttk::frame $w.nf -width 100
  ttk::frame $w.nf.tf
  ttk::entry $w.nf.tf.text -width 20 -background white
  bindFocusColors $w.nf.tf.text
  bind $w.nf.tf.text <Alt-KeyRelease-c> { .commentWin.b.close invoke }
  
  set nagbox $w.nf.tf.text
  set nagbuttons $w.nf.b
  ttk::frame $w.nf.b
  set i 0
  set row 0
  set column 0
  foreach {nag description} {
    ! GoodMove
    ? PoorMove
    !! ExcellentMove
    ?? Blunder
    !? InterestingMove
    ?! DubiousMove
    +- WhiteDecisiveAdvantage
    -+ BlackDecisiveAdvantage
    +/- WhiteClearAdvantage
    -/+ BlackClearAdvantage
    += WhiteSlightAdvantage
    =+ BlackSlightAdvantage
    = Equality
    ~ Unclear
    N Novelty
    D Diagram
  } {
    ttk::button $nagbuttons.b$i -takefocus 0 -text "$nag" -width 2 -command [namespace code [list addNag "$nag"]]
    # set helpMessage(E,$nagbuttons.b$i) $description
    ::utils::tooltip::Set $nagbuttons.b$i $description
    grid $nagbuttons.b$i -row [expr {$i % 2}] -column [expr {int($i / 2)}] -padx 2 -pady 2
    incr i
  }
  
  ttk::label $w.nf.label -font font_Bold -textvar ::tr(AnnotationSymbols)
  pack $w.nf -side top -pady 1 -expand 1 -fill both
  #addHorizontalRule $w
  
  ttk::button $w.nf.tf.clear -textvar ::tr(Clear) -command {
    .commentWin.nf.tf.text delete 0 end
    ::commenteditor::storeComment
    ::pgn::Refresh 1
    updateBoard
  }
  set helpMessage(E,$w.nf.tf.clear) {Clear all symbols for this move}
  pack $w.nf.label -side top -expand 0
  pack $w.nf.tf -side top
  pack $w.nf.tf.text -side left
  pack $w.nf.tf.clear -side right -padx 20 -pady 5
  pack $w.nf.b -side top
  
  ttk::frame $w.b
  pack $w.b -side bottom -ipady 4 -fill both -expand 1 -padx 1
  
  pack $w.cf -side top -expand 1 -fill both
  pack $w.cf.label -side top -pady 2
  pack $w.cf.scroll -side right -fill y
  pack $w.cf.text -side right -expand 1 -fill both
  
  # addHorizontalRule $w
  
  wm minsize $w 40 3
  
  # Main buttons:
  
  dialogbutton $w.b.clear -textvar ::tr(Clear) -command [namespace code [list ClearComments .commentWin]]
  set helpMessage(E,$w.b.clear) {Clear this comment}
  dialogbutton $w.b.revert -textvar ::tr(Revert) -command ::commenteditor::Refresh
  set helpMessage(E,$w.b.revert) {Revert to the stored comment}
  dialogbutton $w.b.store -textvar ::tr(Store) -command [namespace code {storeComment; ::pgn::Refresh 1; updateBoard}]
  set helpMessage(E,$w.b.store) {Store this comment in the game}
  ttk::frame $w.b.space -width 10
  dialogbutton $w.b.close -textvar ::tr(Close) -command { focus .; destroy .commentWin}
  set helpMessage(E,$w.b.close) {Close the comment editor window}
  
  pack $w.b.close $w.b.space $w.b.store $w.b.revert $w.b.clear -side right -padx 1
  
  ### Insert-mark frame
  
  ttk::label $mark.header -font font_Bold -text $::tr(InsertMark:)
  pack $mark.header -side top -ipady 1 -fill x -padx 1
  
  # pack [ttk::frame $mark.usage] -side bottom -pady 1 -expand true
  # pack [ttk::label $mark.usage.text -text [string trim $::tr(InsertMarkHelp)] -justify left]
  ::utils::tooltip::Set $mark [string trim $::tr(InsertMarkHelp)]
  
  # Subframes for insert board and two button rows:
  pack [ttk::frame [set colorButtons $mark.colorButtons]] -side top -pady 1 -anchor n
  pack [ttk::frame [set insertBoard $mark.insertBoard]] -side top -pady 1
  pack [ttk::frame [set typeButtons $mark.typeButtons]] -side top -pady 1 -anchor s
  
  # Left subframe: color (radio)buttons
  foreach color $colorList {
    image create photo markColor_$color -width 18 -height 18
    markColor_$color put $color -to 1 1 16 16
    radiobutton $colorButtons.c$color -image markColor_$color -variable [namespace current]::State(markColor) \
        -value $color -takefocus 0 -command [namespace code [list SetMarkColor $color]] -indicatoron 0
    pack $colorButtons.c$color -side left -padx 0 -pady 3
  }
  
  # Central subframe: a small board
  set board [::board::new $insertBoard.board 20]
  ::board::showMarks $board 1
  set ::board::_mark($board) $::board::_mark(.main.board)
  ::board::update $board
  pack $board -side top
  for {set square 0} {$square < 64} {incr square} {
    ::board::bind $board $square <ButtonPress-1> [namespace code [list InsertMark $board $square]]
    ::board::bind $board $square <ButtonRelease-1> [namespace code [list ButtonReleased $board %b %X %Y]]
    ::board::bind $board $square <ButtonPress-3> [namespace code [list InsertMark $board [expr {$square + 64}]]]
  }
  
  # Right subframe: type/shape (pseudo-radio)buttons
  set size 20	;# button/rectangle size
  pack [set types [ttk::frame $typeButtons.all]] -side left -padx 10
  set row 0
  foreach buttons $markTypeList {
    set column 0
    foreach shape $buttons {
      set color [::board::defaultColor [expr {($column + $row) % 2}]]
      # Create and draw a button:
      set button [ttk::frame $types.button_${shape} -class PseudoButton]
      grid $button -row $row -column $column -padx 1 -pady 1
      # The "board" is a 1x1 board, containing one single square.
      set board1x1 [canvas $button.bd -height $size -width $size -highlightthickness 0 -borderwidth 1 -relief raised]
      $board1x1 create rectangle 0 0 $size $size -fill $color -outline "" -tag [list sq0 button${shape}]
      ::board::mark::add $types.button_${shape} $shape 0 $State(markColor) "false"
      pack $board1x1
      bind $board1x1 <Button-1> [namespace code [list SetMarkType $board $shape]]
      incr column
    } ;# foreach shape
    incr row
  } ;# foreach button_line
  # "Press" button:
  SetMarkType $board $State(markType)
  
  ### Start editing
  ::setTitle $w "Scid: [tr {Comment editor}]"
  wm iconname $w "Scid: [tr {Comment editor}]"
  ::commenteditor::Refresh
  focus $w.cf.text
  ::createToplevelFinalize $w
}

# ::commenteditor::SetMarkColor --
#
#	Called when a color is selected.
#
# Arguments:
#	color	The selected color.
# Results:
#	TODO
#
proc ::commenteditor::SetMarkColor {color} {
  variable   markTypeList
  variable   State
  set path   .commentWin.markFrame.typeButtons.all
  set square 0	;# square number of a 1x1-board
  foreach buttons $markTypeList {
    foreach shape $buttons {
      set button $path.button_${shape}
      if {$shape == "square"} {
        $button.bd itemconfigure sq$square \
            -fill $color -outline $color
      } else {
        $button.bd delete mark
        addMark $button $shape $square $color "false"
      }
    }
  }
  set State(markColor) $color
}

# ::commenteditor::SetMarkType --
#
# Arguments:
#	board	The frame variable of the board.
#	type	The selected type/shape, e.g. "circle", "1", etc.
# Results:
#	TODO
#
proc ::commenteditor::SetMarkType {board type} {
  variable State
  set cur_type $State(markType)
  set path .commentWin.markFrame.typeButtons.all
  $path.button_${cur_type}.bd configure -relief raised
  $path.button_${type}.bd configure -relief sunken
  set State(markType) $type
}

# ::commenteditor::InsertMark --
#
#	Called when a square is selected on the insert board.
#
# Arguments:
#	board	The frame variable of the board.
#	from	Number (0-63) of the selected square
#		(+64 if right mouse button used).
#	to	Number of destination square (0-63) if an
#		arrow is to be drawn (+64 if right mouse button).
# Results:
#	TODO
#
proc ::commenteditor::InsertMark {board square} {
  variable State
  set textwin .commentWin.cf.text
  if {![string length $State(pending)]} {
    set State(pending) $square
    return
  }
  # Right mouse click results in square-no + 64:
  set from [expr {$State(pending) % 64}]
  set to   [expr {$square         % 64}]
  
  set key $::board::mark::Command
  array set tag [list remove 0 value {}]
  if {$square == $State(pending)} {
    if {$square >= 64} { return }
    if {[lsearch [$textwin tag names] $square] >= 0} {
      array set tag [list remove 1 value $square]
      delMark $board $square
    } else {
      set tag(value) $square
      addMark $board $State(markType) $square $State(markColor)
      set to [::board::san $square]
      set State(text) "\[%$key $State(markType),$to,$State(markColor)\]"
    }
  } else {
    if {($square & 64) != ($State(pending) & 64)} {
      if {$square < 64} { set State(pending) $square }
      return
    }
    if {[lsearch [$textwin tag names] ${from}:${to}] >= 0} {
      set tag(remove) 1
      set tag(value)  [list ${from}:${to} ${to}:${from}]
      delMark $board $from $to
    } else {
      set tag(value) [list ${from}:${to} ${to}:${from}]
      addMark $board arrow $from $to $State(markColor)
      set from [::board::san $from]
      set to   [::board::san $to]
      set State(text) "\[%$key arrow,$from,$to,$State(markColor)\]"
    }
  }
  set State(pending) ""
  
  if {$tag(remove)} {
    set remove [lindex $tag(value) 0]
    if [llength [$textwin tag range $remove]] {
      $textwin delete $remove.first $remove.last
    }
    eval $textwin tag delete $tag(value)
  } else {
    $textwin insert insert $State(text) $tag(value)
  }
}

# ::commenteditor::ClearComments --
#
#	Called when the 'Clear' button is pressed.
#
# Arguments:
#	win	The window variable.
# Results:
#	Clears text area and chess board of the comment editor.
#
proc ::commenteditor::ClearComments {win} {
  ${win}.cf.text delete 0.0 end
  set board ${win}.markFrame.insertBoard.board
  ::board::mark::clear $board
  ::board::update $board
}

# ::commenteditor::ButtonReleased --
#
#	Auxiliary routine:
#	Called when a button is released over a square.
#
# Arguments:
#	board	The frame variable of the board.
#	button	The number (%b) of the button that was released.
#	x_root	The x-coodinate (%X) from the event.
#	y_root	The y-coodinate (%Y) from the event.
# Results:
#
proc ::commenteditor::ButtonReleased {board button x_root y_root} {
  set square [::board::getSquare $board $x_root $y_root]
  if {$square < 0}  {
    set $State(pending) ""
    return
  }
  if {$button != 1} {set square [expr {$square + 64}]}
  InsertMark $board $square
}

# ::commenteditor::storeComment --
#
#	Set the comment of the current position to
#	the text of the commenteditor.
#
proc ::commenteditor::storeComment {} {
  if {![winfo exists .commentWin]} { return }
  set nag [sc_pos getNags]
  if {$nag == "0"} { set nag "" }
  if { $nag != [.commentWin.nf.tf.text get] } {
    sc_pos clearNags
    foreach i [split [.commentWin.nf.tf.text get] " "] {
      sc_pos addNag $i
    }
  }
  
  # The "end-1c" below is because Tk adds a newline to text contents:
  set newComment [.commentWin.cf.text get 1.0 end-1c]
  set oldComment [sc_pos getComment]
  if {[string compare $oldComment $newComment]} {
    sc_pos setComment $newComment
    updateStatusBar
    ::pgn::Refresh 1
    updateBoard
  }
}

# ::commenteditor::Refresh --
#
#	(Re)builds textwindow and board of the comment editor.
#
proc ::commenteditor::Refresh {} {
  if {![winfo exists .commentWin]} { return }
  
  set nag [sc_pos getNags]
  .commentWin.nf.tf.text configure -state normal
  .commentWin.nf.tf.text delete 0 end
  if {$nag != "0"} {
    .commentWin.nf.tf.text insert end $nag
  }
  
  # if at vstart, disable NAG codes
  if {[sc_pos isAt vstart]} {
    set state "disabled"
  } else  {
    set state "normal"
  }
  foreach c [winfo children .commentWin.nf.tf] {
    $c configure -state $state 
  }
  foreach c [winfo children .commentWin.nf.b] {
    $c configure -state $state
  }
  
  # Rewrite text window, tag embedded commands,
  # and draw marks according to text window commands.
  set text  .commentWin.cf.text
  set board .commentWin.markFrame.insertBoard.board
  set comment [sc_pos getComment]
  set offset  0
  ::board::mark::clear $board
  $text delete 1.0 end
  foreach {mark pos} [::board::mark::getEmbeddedCmds $comment] {
    foreach {type square arg color} $mark {begin end} $pos {break}  ;# set
    set square [::board::sq $square]
    regsub -all -- {[^[:alnum:]]} $color {_} _color
    switch -- $type {
      arrow   { set arg  [::board::sq $arg]
        set tags [list ${square}:${arg} ${arg}:${square} \
            ${square}:${arg}:$_color]
      }
      default { set tags [list $square ${square}:$type:$_color] }
    }
    $text insert insert [string range $comment $offset [expr {$begin-1}]]
    $text insert insert [string range $comment $begin $end] $tags
    set offset [expr {$end + 1}]
    addMark $board $type $square $arg $color 1
  }
  $text insert insert [string range $comment $offset end]
  ::board::update $board
}

### End of namespace ::commenteditor
