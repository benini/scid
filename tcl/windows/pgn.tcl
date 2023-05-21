############################################################
### PGN window

namespace eval pgn {
  ################################################################################
  #
  ################################################################################
  proc ChooseColor {type name} {
    global pgnColor
    set initial_color {}
    if {$::pgnColor($type) ne ""} {
      lappend initial_color "-initialcolor" $::pgnColor($type)
    }
    set x [tk_chooseColor {*}$initial_color -title "PGN $name color"]
    if {$x != ""} { set pgnColor($type) $x; ::pgn::ResetColors }
  }
  ################################################################################
  #
  ################################################################################
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

    set w .pgnWin
    if {! [::win::createWindow $w [tr PgnWindowTitle] ]} {
      ::win::closeWindow $w
      return
    }

    menu $w.menu
    ::setMenu $w $w.menu

    $w.menu add cascade -label PgnFile -menu $w.menu.file -underline 0
    $w.menu add cascade -label PgnOpt -menu $w.menu.opt -underline 0
    $w.menu add cascade -label PgnColor -menu $w.menu.color -underline 0
    $w.menu add cascade -label PgnHelp -menu $w.menu.helpmenu -underline 0
    foreach i {file opt color helpmenu} {
      menu $w.menu.$i -tearoff 0
    }

    $w.menu.file add command -label PgnFileCopy -command {::pgn::PgnClipboardCopy }

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
    $w.menu.file add command -label PgnFileClose \
        -command "::win::closeWindow $w"

    $w.menu.opt add checkbutton -label PgnOptColor \
        -variable ::pgn::showColor -command {updateBoard -pgn}
    $w.menu.opt add checkbutton -label PgnOptShort \
        -variable ::pgn::shortHeader -command {::pgn::Refresh 1}
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
        -variable ::pgn::boldMainLine -command {::pgn::Refresh 1}
    $w.menu.opt add checkbutton -label GInfoPhotos \
        -variable ::pgn::showPhoto -command {::pgn::Refresh 1}

    $w.menu.color add command -label PgnColorAnno \
        -command {::pgn::ChooseColor Nag annotation}
    $w.menu.color add command -label PgnColorComments \
        -command {::pgn::ChooseColor Comment comment}
    $w.menu.color add command -label PgnColorVars \
        -command {::pgn::ChooseColor Var variation}
    $w.menu.color add command -label PgnColorCurrent -command {::pgn::ChooseColor Current current}

    $w.menu.helpmenu add command -label PgnHelpPgn -command {helpWindow PGN}
    $w.menu.helpmenu add command -label PgnHelpIndex -command {helpWindow Index}

    translateMenuLabels $w.menu

    ttk::frame $w.frame
    ttk_text $w.text -wrap word -tabs {1c right 2c 4c}
    autoscrollBars y $w.frame $w.text

    grid $w.frame -sticky news
    grid rowconfigure $w 0 -weight 1
    grid columnconfigure $w 0 -weight 1

    set pgnWin 1
    bind $w <Destroy> { set pgnWin 0 }

    # Take input focus even if -state is disabled
    bind $w.text <ButtonPress-1> "focus %W"

    # Bind right button to popup a contextual menu:
    bind $w.text <ButtonPress-$::MB3> "::pgn::contextMenu .pgnWin.text %X %Y"

    # Clicking on the header toggle between short-3-lines/full header
    $w.text tag bind tag <ButtonRelease-1> {
      if {[%W tag ranges sel] eq ""} {
        set ::pgn::shortHeader [expr {!$::pgn::shortHeader}]
        ::pgn::Refresh 1
        %W yview moveto 0
      }
    }

    # Workaround for Text widget bug (Tk 8.6.6+)
    # The new "asynchronous update of line heights" does not work if
    # the Text widget is inside an inactive ttk::notebook tab.
    if {![catch { $w.text sync }]} { bind $w.text <Visibility> "$w.text sync" }

    $w.text tag add Current 0.0 0.0
    ::pgn::ResetColors
  }

  ################################################################################
  #
  ################################################################################
  proc contextMenu {win x y} {

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
    $mctxt.evals1 add command -label "Clear" -command {::addNag X}
    $mctxt.evals1 add command -label "!" -command {::addNag !}
    $mctxt.evals1 add command -label "?" -command {::addNag ?}
    $mctxt.evals1 add command -label "!?" -command {::addNag !?}
    $mctxt.evals1 add command -label "?!" -command {::addNag ?!}
    $mctxt.evals1 add command -label "!!" -command {::addNag !!}
    $mctxt.evals1 add command -label "??" -command {::addNag ??}

    menu $mctxt.evals2
    $mctxt.evals2 add command -label "Clear" -command {::addNag Y}
    $mctxt.evals2 add command -label "=" -command {::addNag =}
    $mctxt.evals2 add command -label "~" -command {::addNag ~}
    $mctxt.evals2 add command -label "+=" -command {::addNag +=}
    $mctxt.evals2 add command -label "=+" -command {::addNag =+}
    $mctxt.evals2 add command -label "+/-" -command {::addNag +/-}
    $mctxt.evals2 add command -label "-/+" -command {::addNag -/+}
    $mctxt.evals2 add command -label "+-" -command {::addNag +-}
    $mctxt.evals2 add command -label "-+" -command {::addNag -+}
    $mctxt.evals2 add command -label "+--" -command {::addNag +--}
    $mctxt.evals2 add command -label "--+" -command {::addNag --+}
    $mctxt.evals2 add command -label "N" -command {::addNag N}
    $mctxt.evals2 add command -label "D" -command {::addNag D}

    $mctxt add command -label [tr EditDelete] -state $state -command "::pgn::deleteVar"
    $mctxt add command -label [tr EditFirst] -state $state -command "::pgn::firstVar"
    $mctxt add command -label [tr EditMain] -state $state -command "::pgn::mainVar"
    $mctxt add separator
    $mctxt add command -label "[tr EditStrip]:[tr EditStripBegin]" -command {::game::TruncateBegin}
    $mctxt add command -label "[tr EditStrip]:[tr EditStripEnd]" -command {::game::Truncate}
    $mctxt add separator
    $mctxt add command -label "[tr EditStrip]:[tr EditStripComments]" -command {::game::Strip comments}
    $mctxt add command -label "[tr EditStrip]:[tr EditStripVars]" -command {::game::Strip variations}
    $mctxt add separator
    $mctxt add cascade -label "!  ?  ..." -menu $mctxt.evals1
    $mctxt add cascade -label "+-  +/-  ..." -menu $mctxt.evals2
    $mctxt add command -label "[tr WindowsComment]" -command {::makeCommentWin}

    tk_popup $mctxt $x $y
  }

  proc deleteVar {} {
    undoFeature save
    sc_var delete
    updateBoard -pgn
  }

  proc firstVar {} {
    undoFeature save
    sc_var first
    updateBoard -pgn
  }

  proc mainVar {} {
    undoFeature save
    sc_var promote
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

    ::board::popup .pgnPopup $bd $xc $yc
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
      if { $::pgn::boldMainLine } {
          .pgnWin.text configure -font font_Bold
      } else {
          .pgnWin.text configure -font font_Regular
      }
      .pgnWin.text configure -state normal
      .pgnWin.text delete 1.0 end

      if {$::pgn::showColor} {
        ::htext::display .pgnWin.text $pgnStr
      } else {
        .pgnWin.text insert 1.0 $pgnStr
      }

      if {$::pgn::showPhoto} {
        updatePlayerPhotos
        if {[image width photoW] != 0} {
          .pgnWin.text image create 1.0 -image photoW -padx 10 -pady 10
        }
        if {[image width photoB] != 0} {
          .pgnWin.text image create 1.end -image photoB -padx 10 -pady 10
        }
      }

      .pgnWin.text configure -state disabled
      unbusyCursor .
    }
    ::pgn::update_current_move
  }

  proc update_current_move {} {
    if {[winfo exists .pgnWin] && $::pgn::showColor} {
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
}
