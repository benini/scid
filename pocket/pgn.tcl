### ScidPocket.
### Copyright (C) 2007  Pascal Georges
############################################################
### PGN window

namespace eval pgn {
  set pgnColor(Header) "\#00008b"
  set pgnColor(Main) "\#000000"
  set pgnColor(Var) "\#0000ee"
  set pgnColor(Nag) "\#ee0000"
  set pgnColor(Comment) "\#008b00"
  set pgnColor(Current) lightSteelBlue
  set pgnColor(NextMove) "\#fefe80"
  set pgnColor(Background) "\#ffffff"
  
  ################################################################################
  #
  ################################################################################
  proc OpenClose {} {
    global pgnWin
    
    if {[winfo exists .pgnWin]} {
      focus .
      destroy .pgnWin
      set pgnWin 0
      return
    }
    set w [toplevel .pgnWin]
    busyCursor .pgnWin
    ::ui::setFullSize $w 0
    
    frame .pgnWin.menu -borderwidth 1 -relief raised
    pack .pgnWin.menu -side top -fill x
    $w configure -menu $w.menu
    menubutton $w.menu.file -text File -menu $w.menu.file.m -underline 0
    menubutton $w.menu.opt -text Options -menu $w.menu.opt.m -underline 0
    foreach i {file opt} {
      menu $w.menu.$i.m -tearoff 0
      pack $w.menu.$i -side left
    }
    
    $w.menu.file.m add command -label "File copy" -command {
      set pgnStr [sc_game pgn -width 25 -indentComments $::pgn::indentComments \
          -indentVariations $::pgn::indentVars -space $::options(pgn_moveNumberSpaces)]
      set wt .tempFEN
      if {! [winfo exists $wt]} { text $wt }
      $wt delete 1.0 end
      $wt insert end $pgnStr sel
      clipboard clear
      clipboard append $pgnStr
      selection own $wt
      selection get
    }
    
    $w.menu.file.m add command -label "File save" -command {
      set ftype {
        { "PGN files"  {".pgn"} }
        { "Text files" {".txt"} }
        { "All files"  {"*"}    }
      }
      set fname [tk_getSaveFile -initialdir [pwd] -filetypes $ftype -title "Save PGN file" -parent .pgnWin]
      if {$fname != ""} {
        if {[catch {set tempfile [open $fname w]}]} {
          tk_messageBox -title "Scid: Error saving file" -type ok -icon warning \
              -message "Unable to save the file: $fname\n\n"
        } else {
          puts $tempfile \
              [sc_game pgn -width 25 -symbols $::options(pgn_symbolicNags) \
              -indentVar $::pgn::indentVars -indentCom $::pgn::indentComments \
              -space $::options(pgn_moveNumberSpaces) -format plain -column $::options(pgn_columnFormat) \
              -markCodes $::::pgn::stripMarks]
          close $tempfile
        }
      }
    }
    $w.menu.file.m add separator
    $w.menu.file.m add command -label "Close window" -command "focus .; destroy $w"
    
    $w.menu.opt.m add checkbutton -label "Color Display" \
        -variable ::options(pgn_showColor) -command {::board::updateBoard -pgn -nolastmove}
    $w.menu.opt.m add checkbutton -label "Short (3-line) Header" \
        -variable ::pgn::shortHeader -command {::board::updateBoard -pgn -nolastmove}
    $w.menu.opt.m add checkbutton -label "Symbolic Annotations" \
        -variable ::options(pgn_symbolicNags) -command {::board::updateBoard -pgn -nolastmove}
    $w.menu.opt.m add checkbutton -label "Indent Comments" \
        -variable ::pgn::indentComments -command {::board::updateBoard -pgn -nolastmove}
    $w.menu.opt.m add checkbutton -label "Indent Variations" \
        -variable ::pgn::indentVars -command {::board::updateBoard -pgn -nolastmove}
    $w.menu.opt.m add checkbutton -label "Column Style (one move per line)" \
        -variable ::options(pgn_columnFormat) -command {::board::updateBoard -pgn -nolastmove}
    $w.menu.opt.m add checkbutton -label "Strip out Colored Square/Arrow Codes" \
        -variable ::pgn::stripMarks -command {::board::updateBoard -pgn -nolastmove}
    $w.menu.opt.m add checkbutton -label "Use Bold Text for Main Line Moves" \
        -variable ::pgn::boldMainLine -command {::board::updateBoard -pgn -nolastmove}
    
    text $w.text -wrap word -background white -yscrollcommand "$w.scroll set" -setgrid 0 -tabs {1c right 1c 1c}
    
    if { $::pgn::boldMainLine } {
      $w.text configure -font font_Bold
    }
    ttk::scrollbar $w.scroll -command "$w.text yview" -takefocus 0
    pack [frame $w.buttons] -side bottom -fill x
    pack $w.scroll -side right -fill y
    pack $w.text -fill both ;# -expand yes
    button $w.buttons.close -text "Close" -command { focus . ; destroy .pgnWin }
    pack $w.buttons.close -side right -padx 5 -pady 2
    set pgnWin 1
    bind $w <Destroy> { set pgnWin 0 }
    
    # Bind left button to close ctxt menu:
    bind $w <ButtonPress-1> {
      if {[winfo exists .pgnWin.text.ctxtMenu]} { destroy .pgnWin.text.ctxtMenu; focus .pgnWin }
    }
    
    # Bind right button to popup a contextual menu:
    if {$::WindowsCE} {
      wce tapandhold .pgnWin.text on
    }
    
    bind $w.text <ButtonPress-3> "::pgn::contextMenu .pgnWin.text 5 %x %y %X %Y"
    
    # set the same arrow key, etc bindings that the main window has:
    # bind $w <Up>    {::move::Back 10}
    # bind $w <Left>  ::move::Back
    # bind $w <Down>  {::move::Forward 10}
    # bind $w <Right> ::move::Forward
    
    $w.text tag add Current 0.0 0.0
    ::pgn::ResetColors
    unbusyCursor .pgnWin
  }
  
  ################################################################################
  #
  ################################################################################
  proc contextMenu {win startLine x y xc yc} {
    
    update idletasks
    
    set mctxt $win.ctxtMenu
    if { [winfo exists $mctxt] } { destroy $mctxt }
    if {[sc_var level] == 0} {
      set state disabled
    } else  {
      set state normal
    }
    menu $mctxt
    $mctxt add command -label [::msgcat::mc "Delete var"] -state $state -command "::pgn::deleteVar [sc_var number]"
    $mctxt add command -label [::msgcat::mc "To first var"] -state $state -command "::pgn::firstVar [sc_var number]"
    $mctxt add command -label [::msgcat::mc "Main line"] -state $state -command "::pgn::mainVar [sc_var number]"
    $mctxt add separator
    $mctxt add command -label [::msgcat::mc "Strip begin"] -command {::pgn::TruncateBegin}
    $mctxt add command -label [::msgcat::mc "Strip end"] -command {::pgn::Truncate}
    $mctxt add separator
    $mctxt add command -label [::msgcat::mc "Strip comments"] -command {::pgn::Strip comments}
    $mctxt add command -label [::msgcat::mc "Strip vars"] -command {::pgn::Strip variations}
    
    $mctxt post [winfo pointerx .] [winfo pointery .]
    
  }
  
  #   Strips all comments or variations from a game
  proc Strip {type} {
    if {[catch {sc_game strip $type} result]} {
      tk_messageBox -parent . -type ok -icon info -title "Scid" -message $result
      return
    }
    ::board::updateBoard -pgn -nolastmove
    ::board::updateTitle
  }
  
  # ::game::TruncateBegin
  proc TruncateBegin {} {
    if {[catch {sc_game truncate -start} result]} {
      tk_messageBox -parent . -type ok -icon info -title "Scid" -message $result
      return
    }
    ::board::updateBoard -pgn -nolastmove
    ::board::updateTitle
  }
  
  # ::game::Truncate
  proc Truncate {} {
    if {[catch {sc_game truncate} result]} {
      tk_messageBox -parent . -type ok -icon info -title "Scid" -message $result
      return
    }
    ::board::updateBoard -pgn -nolastmove
    ::board::updateTitle
  }
  
  proc deleteVar { var } {
    sc_var exit
    sc_var delete $var
    ::board::updateBoard -pgn -nolastmove
  }
  
  proc firstVar { var } {
    sc_var exit
    sc_var first $var
    ::board::updateBoard -pgn -nolastmove
  }
  
  proc mainVar { var } {
    sc_var exit
    sc_var promote $var
    ::board::updateBoard -pgn -nolastmove
  }
  
  ################################################################################
  # # ::pgn::ResetColors
  #
  #    Reconfigures the pgn Colors, after a color is changed by the user
  #
  ################################################################################
  proc ResetColors {} {
    global pgnColor
    if {![winfo exists .pgnWin]} { return }
    .pgnWin.text configure -background $::pgn::pgnColor(Background)
    .pgnWin.text tag configure Current -background $::pgn::pgnColor(Current)
    .pgnWin.text tag configure NextMove -background $::pgn::pgnColor(NextMove)
    ::htext::init .pgnWin.text
    ::htext::updateRate .pgnWin.text 60
    ::pgn::Refresh 1
  }
  ################################################################################
  # ::pgn::Refresh
  #
  #    Updates the PGN window. If $pgnNeedsUpdate == 0, then the
  #    window text is not regenerated; only the current and next move
  #    tags will be updated.
  ################################################################################
  proc Refresh {{pgnNeedsUpdate 0}} {
    
    if {![winfo exists .pgnWin]} { return }
    
    set format plain
    if {$::options(pgn_showColor)} {set format color}
    
    set pgnStr [sc_game pgn -symbols $::options(pgn_symbolicNags) \
        -indentVar $::pgn::indentVars -indentCom $::pgn::indentComments \
        -space $::options(pgn_moveNumberSpaces) -format $format -column $::options(pgn_columnFormat) \
        -short $::pgn::shortHeader -markCodes $::pgn::stripMarks]

    if {$pgnNeedsUpdate} {
      set windowTitle [format Pgn [sc_game number]]
      wm title .pgnWin "Scid: $windowTitle"
      .pgnWin.text configure -state normal
      .pgnWin.text delete 1.0 end
      if {$::options(pgn_showColor)} {
        #set start [clock clicks -milli]
        ::htext::display .pgnWin.text $pgnStr
        #set end [clock clicks -milli]
        #puts "PGN: [expr $end - $start] ms"
      } else {
        .pgnWin.text insert 1.0 $pgnStr
      }
    }
    
    if {$::options(pgn_showColor)} {
      if { $::pgn::boldMainLine } {
        .pgnWin.text configure -font font_Bold
      } else {
        .pgnWin.text configure -font font_Regular
      }
      # Now update Current and NextMove tags:
      .pgnWin.text tag remove Current 1.0 end
      set offset [sc_pos pgnOffset]
      set moveRange [.pgnWin.text tag nextrange "m_$offset" 1.0]
      if {[llength $moveRange] == 2} {
        .pgnWin.text tag add Current [lindex $moveRange 0] [lindex $moveRange 1]
        .pgnWin.text see [lindex $moveRange 0]
      }
      
      .pgnWin.text tag remove NextMove 1.0 end
      set noffset [sc_pos pgnOffset next]
      if {$noffset == $offset} {set noffset 0}
      set moveRange [.pgnWin.text tag nextrange "m_$noffset" 1.0]
      if {[llength $moveRange] == 2} {
        .pgnWin.text tag add NextMove [lindex $moveRange 0] [lindex $moveRange 1]
      }
      .pgnWin.text configure -state disabled
    }
    return
  }
  ################################################################################
  #
  ################################################################################
  
}
