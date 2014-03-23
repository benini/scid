############################################################
### PGN window

namespace eval pgn {
  ################################################################################
  #
  ################################################################################
  proc ChooseColor {type name} {
    global pgnColor
    set x [tk_chooseColor -initialcolor $pgnColor($type) -title "PGN $name color"]
    if {$x != ""} { set pgnColor($type) $x; ::pgn::ResetColors }
  }
  ################################################################################
  #
  ################################################################################
  proc ConfigMenus {{lang ""}} {
    if {! [winfo exists .pgnWin]} { return }
    if {$lang == ""} { set lang $::language }
    set m .pgnWin.menu
    foreach idx {0 1 2 3} tag {File Opt Color Help} {
      configMenuText $m $idx Pgn$tag $lang
    }
    foreach idx {0 1 3} tag {Copy Print Close} {
      configMenuText $m.file $idx PgnFile$tag $lang
    }
    foreach idx {0 1 2 3 4 5 6 7 8} tag {
      Color Short Symbols IndentC IndentV Space Column StripMarks BoldMainLine
    } {
      configMenuText $m.opt $idx PgnOpt$tag $lang
    }
    foreach idx {0 1 2 3 4 5} tag {Header Anno Comments Vars Background Current} {
      configMenuText $m.color $idx PgnColor$tag $lang
    }
    foreach idx {0 1} tag {Pgn Index} {
      configMenuText $m.helpmenu $idx PgnHelp$tag $lang
    }
  }

  proc PgnClipboardCopy {} {
      setLanguageTemp E
      set pgnStr [sc_game pgn -width 75 -indentComments $::pgn::indentComments \
          -indentVariations $::pgn::indentVars -space $::pgn::moveNumberSpaces]
      setLanguageTemp $::language
      
      set wt .tempFEN
      
      if {! [winfo exists $wt]} { text $wt }
      $wt delete 1.0 end
      $wt insert end $pgnStr sel
      clipboard clear
      clipboard append $pgnStr
      selection own $wt
      selection get
  }

  ################################################################################
  #
  ################################################################################
  proc OpenClose {} {
    global pgnWin pgnHeight pgnWidth pgnColor
    if {[winfo exists .pgnWin]} {
      focus .
      destroy .pgnWin
      set pgnWin 0
      return
    }
    
    set w .pgnWin
    
    ::createToplevel $w
    
    setWinLocation $w
    setWinSize $w
    bind $w <Configure> "recordWinSize $w"
    
    menu $w.menu
    ::setMenu $w $w.menu
    
    $w.menu add cascade -label PgnFile -menu $w.menu.file -underline 0
    $w.menu add cascade -label PgnOpt -menu $w.menu.opt -underline 0
    $w.menu add cascade -label PgnColor -menu $w.menu.color -underline 0
    $w.menu add cascade -label PgnHelp -menu $w.menu.helpmenu -underline 0
    foreach i {file opt color helpmenu} {
      menu $w.menu.$i -tearoff 0
    }
    
    $w.menu.file add command -label PgnFileCopy -accelerator "Ctrl+C" -command {::pgn::PgnClipboardCopy }
    bind $w <Control-c> {::pgn::PgnClipboardCopy}
    bind $w <Control-Insert> {::pgn::PgnClipboardCopy}
    
    $w.menu.file add command -label PgnFilePrint -command {
      set ftype {
        { "PGN files"  {".pgn"} }
        { "Text files" {".txt"} }
        { "All files"  {"*"}    }
      }
      set fname [tk_getSaveFile -initialdir [pwd] -filetypes $ftype -title "Save PGN file"]
      if {$fname != ""} {
        if {[file extension $fname] != ".txt" && [file extension $fname] != ".pgn" } {
          append fname ".pgn"
        }
        if {[catch {set tempfile [open $fname w]}]} {
          tk_messageBox -title "Scid: Error saving file" -type ok -icon warning \
              -message "Unable to save the file: $fname\n\n"
        } else {
          puts $tempfile \
              [sc_game pgn -width 75 -symbols $::pgn::symbolicNags \
              -indentVar $::pgn::indentVars -indentCom $::pgn::indentComments \
              -space $::pgn::moveNumberSpaces -format plain -column $::pgn::columnFormat \
              -markCodes $::pgn::stripMarks]
          close $tempfile
        }
      }
    }
    $w.menu.file add separator
    $w.menu.file add command -label PgnFileClose -accelerator Esc \
        -command "focus .; destroy $w"
    
    $w.menu.opt add checkbutton -label PgnOptColor \
        -variable ::pgn::showColor -command {updateBoard -pgn}
    $w.menu.opt add checkbutton -label PgnOptShort \
        -variable ::pgn::shortHeader -command {updateBoard -pgn}
    $w.menu.opt add checkbutton -label PgnOptSymbols \
        -variable ::pgn::symbolicNags -command {updateBoard -pgn}
    $w.menu.opt add checkbutton -label PgnOptIndentC \
        -variable ::pgn::indentComments -command {updateBoard -pgn}
    $w.menu.opt add checkbutton -label PgnOptIndentV \
        -variable ::pgn::indentVars -command {updateBoard -pgn}
    $w.menu.opt add checkbutton -label PgnOptSpace \
        -variable ::pgn::moveNumberSpaces -command {updateBoard -pgn}
    $w.menu.opt add checkbutton -label PgnOptColumn \
        -variable ::pgn::columnFormat -command {updateBoard -pgn}
    $w.menu.opt add checkbutton -label PgnOptStripMarks \
        -variable ::pgn::stripMarks -command {updateBoard -pgn}
    $w.menu.opt add checkbutton -label PgnOptBoldMainLine \
        -variable ::pgn::boldMainLine -command {updateBoard -pgn}
    
    $w.menu.color add command -label PgnColorHeader \
        -command {::pgn::ChooseColor Header "header text"}
    $w.menu.color add command -label PgnColorAnno \
        -command {::pgn::ChooseColor Nag annotation}
    $w.menu.color add command -label PgnColorComments \
        -command {::pgn::ChooseColor Comment comment}
    $w.menu.color add command -label PgnColorVars \
        -command {::pgn::ChooseColor Var variation}
    $w.menu.color add command -label PgnColorBackground \
        -command {::pgn::ChooseColor Background background}
    $w.menu.color add command -label PgnColorCurrent -command {::pgn::ChooseColor Current current}

    $w.menu.helpmenu add command -label PgnHelpPgn \
        -accelerator F1 -command {helpWindow PGN}
    $w.menu.helpmenu add command -label PgnHelpIndex -command {helpWindow Index}
    
    ::pgn::ConfigMenus
    
    text $w.text -width $::winWidth($w) -height $::winHeight($w) -wrap word \
        -background $pgnColor(Background) -cursor crosshair \
        -yscrollcommand "$w.scroll set" -setgrid 1 -tabs {1c right 2c 4c}
    if { $::pgn::boldMainLine } {
      $w.text configure -font font_Bold
    }
    
    ttk::scrollbar $w.scroll -command "$w.text yview" -takefocus 0
    pack [ttk::frame $w.buttons] -side bottom -fill x
    pack $w.scroll -side right -fill y
    pack $w.text -fill both -expand yes
    ttk::button $w.buttons.help -textvar ::tr(Help) -command { helpWindow PGN }
    ttk::button $w.buttons.close -textvar ::tr(Close) -command { focus .; destroy .pgnWin }
    #pack $w.buttons.close $w.buttons.help -side right -padx 5 -pady 2
    set pgnWin 1
    bind $w <Destroy> { set pgnWin 0 }
    
    # Bind left button to close ctxt menu:
    bind $w <ButtonPress-1> {
      if {[winfo exists .pgnWin.text.ctxtMenu]} { destroy .pgnWin.text.ctxtMenu; focus .pgnWin }
    }
    
    bind $w <ButtonRelease-$::MB2> ::pgn::HideBoard

    # Bind right button to popup a contextual menu:
    bind $w <ButtonPress-$::MB3> "::pgn::contextMenu .pgnWin.text 5 %x %y %X %Y"
    
    # set the same arrow key, etc bindings that the main window has:
    bind $w <F1> { helpWindow PGN }
    bind $w <Escape> {
      if {[winfo exists .pgnWin.text.ctxtMenu]} {
        destroy .pgnWin.text.ctxtMenu
        focus .pgnWin
      } else {
        focus .
        destroy .pgnWin
      }
    }
    standardShortcuts $w
    
    # Add variation navigation bindings:
    bind $w <KeyPress-v> [bind $::dot_w <KeyPress-v>]
    bind $w <KeyPress-z> [bind $::dot_w <KeyPress-z>]
    
    $w.text tag add Current 0.0 0.0
    ::pgn::ResetColors
    
    ::createToplevelFinalize $w
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

    menu $mctxt.evals1
    $mctxt.evals1 add command -label "Clear" -command {sc_pos addNag X; ::pgn::Refresh 1}
    $mctxt.evals1 add command -label "!" -command {sc_pos addNag ! ; ::pgn::Refresh 1}
    $mctxt.evals1 add command -label "?" -command {sc_pos addNag ? ; ::pgn::Refresh 1}
    $mctxt.evals1 add command -label "!?" -command {sc_pos addNag !? ; ::pgn::Refresh 1}
    $mctxt.evals1 add command -label "?!" -command {sc_pos addNag ?! ; ::pgn::Refresh 1}
    $mctxt.evals1 add command -label "!!" -command {sc_pos addNag !! ; ::pgn::Refresh 1}
    $mctxt.evals1 add command -label "??" -command {sc_pos addNag ?? ; ::pgn::Refresh 1}

    menu $mctxt.evals2
    $mctxt.evals2 add command -label "Clear" -command {sc_pos addNag Y ; ::pgn::Refresh 1}
    $mctxt.evals2 add command -label "=" -command {sc_pos addNag = ; ::pgn::Refresh 1}
    $mctxt.evals2 add command -label "~" -command {sc_pos addNag ~ ; ::pgn::Refresh 1}
    $mctxt.evals2 add command -label "+=" -command {sc_pos addNag += ; ::pgn::Refresh 1}
    $mctxt.evals2 add command -label "=+" -command {sc_pos addNag =+ ; ::pgn::Refresh 1}
    $mctxt.evals2 add command -label "+/-" -command {sc_pos addNag +/- ; ::pgn::Refresh 1}
    $mctxt.evals2 add command -label "-/+" -command {sc_pos addNag -/+ ; ::pgn::Refresh 1}
    $mctxt.evals2 add command -label "+-" -command {sc_pos addNag +- ; ::pgn::Refresh 1}
    $mctxt.evals2 add command -label "-+" -command {sc_pos addNag -+ ; ::pgn::Refresh 1}
    $mctxt.evals2 add command -label "+--" -command {sc_pos addNag +-- ; ::pgn::Refresh 1}
    $mctxt.evals2 add command -label "--+" -command {sc_pos addNag --+ ; ::pgn::Refresh 1}
    $mctxt.evals2 add command -label "N" -command {sc_pos addNag N ; ::pgn::Refresh 1}
    $mctxt.evals2 add command -label "D" -command {sc_pos addNag D ; ::pgn::Refresh 1}
	
    $mctxt add command -label [tr EditDelete] -state $state -command "::pgn::deleteVar [sc_var number]"
    $mctxt add command -label [tr EditFirst] -state $state -command "::pgn::firstVar [sc_var number]"
    $mctxt add command -label [tr EditMain] -state $state -command "::pgn::mainVar [sc_var number]"
    $mctxt add separator
    $mctxt add command -label "[tr EditStrip]:[tr EditStripBegin]" -command {::game::TruncateBegin}
    $mctxt add command -label "[tr EditStrip]:[tr EditStripEnd]" -command {::game::Truncate}
    $mctxt add separator
    $mctxt add command -label "[tr EditStrip]:[tr EditStripComments]" -command {::game::Strip comments}
    $mctxt add command -label "[tr EditStrip]:[tr EditStripVars]" -command {::game::Strip variations}
    $mctxt add separator
    $mctxt add cascade -label "!  ?  ..." -menu $mctxt.evals1
    $mctxt add cascade -label "+-  +/-  ..." -menu $mctxt.evals2
    $mctxt add command -label "[tr WindowsComment]" -command {makeCommentWin}
    
    $mctxt post [winfo pointerx .] [winfo pointery .]
    
  }

  proc deleteVar { var } {
    sc_var exit
    sc_var delete $var
    updateBoard -pgn
  }
  
  proc firstVar { var } {
    sc_var exit
    sc_var first $var
    updateBoard -pgn
  }
  
  proc mainVar { var } {
    sc_var exit
    sc_var promote $var
    updateBoard -pgn
  }
  ################################################################################
  # ::pgn::ShowBoard:
  #    Produces a popup window showing the board position in the
  #    game at the current mouse location in the PGN window.
  #
  ################################################################################
  proc ShowBoard {win moveTag xc yc} {
    set offSet [sc_pos pgnOffset]
    sc_move pgn [string range $moveTag 2 end]
    set bd [sc_pos board]
    if {[::board::isFlipped .main.board]} {set bd [string reverse [lindex $bd 0]]}
    sc_move pgn $offSet

    set w .pgnPopup
    set psize 30
    if {$psize > $::boardSize} { set psize $::boardSize }
    
    if {! [winfo exists $w]} {
      toplevel $w -relief solid -borderwidth 2
      wm withdraw $w
      wm overrideredirect $w 1
      ::board::new $w.bd $psize
      pack $w.bd -side top -padx 2 -pady 2
      wm withdraw $w
    }
    
    ::board::update $w.bd $bd
    
    # Make sure the popup window can fit on the screen:
    incr xc 5
    incr yc 5
    update idletasks
    set dx [winfo width $w]
    set dy [winfo height $w]
    if {($xc+$dx) > [winfo screenwidth $w]} {
      set xc [expr {[winfo screenwidth $w] - $dx}]
    }
    if {($yc+$dy) > [winfo screenheight $w]} {
      set yc [expr {[winfo screenheight $w] - $dy}]
    }
    wm geometry $w "+$xc+$yc"
    wm deiconify $w
    raiseWin $w
  }
  
  ################################################################################
  # ::pgn::HideBoard
  #
  #    Hides the window produced by ::pgn::ShowBoard.
  #
  ################################################################################
  proc HideBoard {} {
    if {[winfo exists .pgnPopup]} {wm withdraw .pgnPopup}
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
    .pgnWin.text configure -background $pgnColor(Background)
    .pgnWin.text tag configure Current -background $pgnColor(Current)
    ::htext::init .pgnWin.text
    ::htext::updateRate .pgnWin.text 0
    ::pgn::Refresh 1
  }
  ################################################################################
  # ::pgn::Refresh
  #
  #    Updates the PGN window. If $pgnNeedsUpdate == 0, then the
  #    window text is not regenerated; only the current and next move
  #    tags will be updated.
  ################################################################################
  proc Refresh { {pgnNeedsUpdate 0} } {
    if {![winfo exists .pgnWin]} { return }

    if {$pgnNeedsUpdate} {
      busyCursor .
      set format plain
      if {$::pgn::showColor} {set format color}
      set pgnStr [sc_game pgn -symbols $::pgn::symbolicNags \
          -indentVar $::pgn::indentVars -indentCom $::pgn::indentComments \
          -space $::pgn::moveNumberSpaces -format $format -column $::pgn::columnFormat \
          -short $::pgn::shortHeader -markCodes $::pgn::stripMarks]

      set windowTitle [format $::tr(PgnWindowTitle) [sc_game number]]
      ::setTitle .pgnWin "$windowTitle"
      .pgnWin.text configure -state normal
      .pgnWin.text delete 1.0 end
      
      # Hide all information after the first **** encountered in order to hide tactics to user
      # This has the drawback to also hide the first moves when there is several markers ****
      if { $::tactics::findBestMoveRunning } {
        set idx [ string first "****"  $pgnStr ]
        if { $idx != -1 } {
          set pgnStr "[ string range $pgnStr 0 [expr $idx + 3] ]</c>\n"
        }
      }

      if {$::pgn::showColor} {
        ::htext::display .pgnWin.text $pgnStr
      } else {
        .pgnWin.text insert 1.0 $pgnStr
      }
      .pgnWin.text configure -state disabled
      unbusyCursor .
    }

    if {$::pgn::showColor} {
      set offset [sc_pos pgnOffset]
      .pgnWin.text tag remove Current 1.0 end
      set moveRange [.pgnWin.text tag nextrange "m_$offset" 1.0]
      if {[llength $moveRange] == 2} {
        .pgnWin.text tag add Current [lindex $moveRange 0] [lindex $moveRange 1]
        .pgnWin.text see [lindex $moveRange 1]
      } else {
        .pgnWin.text yview moveto 0
      }
    }
  }
  ################################################################################
  #
  ################################################################################
  
}
