###################
# htext.tcl: Online help/hypertext display module for Scid
#
# The htext module implements html-like display in a text widget.
# It is used in Scid for the help and crosstable windows, and for
# the game information area.

namespace eval ::htext {}

set helpWin(Stack) {}
set helpWin(yStack) {}
set helpWin(Indent) 0

# help_PushStack and help_PopStack:
#   Implements the stack of help windows for the "Back" button.
#
proc help_PushStack {name {heading ""}} {
  global helpWin
  lappend helpWin(Stack) $name
  if {[llength $helpWin(Stack)] > 10} {
    set helpWin(Stack) [lrange $helpWin(Stack) 1 end]
  }
  if {[winfo exists .helpWin]} {
    set helpWin(yStack) [linsert $helpWin(yStack) 0 \
        [lindex [.helpWin.text yview] 0]]
    if {[llength $helpWin(yStack)] > 10} {
      set helpWin(yStack) [lrange $helpWin(yStack) 0 9]
    }
  }
}

set ::htext::headingColor "\#990000"
array set ::htext::amountVar {}
array set ::htext::hideVarValue {}
array set ::htext:updates {}

proc help_PopStack {} {
  global helpWin helpText
  set len [llength $helpWin(Stack)]
  if {$len < 1} { return }
  incr len -2
  set name [lindex $helpWin(Stack) $len]
  set helpWin(Stack) [lrange $helpWin(Stack) 0 $len]
  
  set ylen [llength $helpWin(yStack)]
  set yview 0.0
  if {$ylen >= 1} {
    set yview [lindex $helpWin(yStack) 0]
    set helpWin(yStack) [lrange $helpWin(yStack) 1 end]
  }
  updateHelpWindow $name
  .helpWin.text yview moveto $yview
}

# Given a window name (usually the focused widget)
# opens the help window trying to select a pertinent page
proc helpWindowPertinent {win} {
  set availTitles [array names ::helpTitle]
  regexp {[.]\w*} $win topWin

  # Look for a toplevel page (i.e. ".treeWin1" -> "tree")
  if { [regexp {[.](\w*?)Win\d*$} $topWin -> topTitle] } {
    set title [lsearch -inline -nocase $availTitles $topTitle]
    if {$title != ""} {
      return [helpWindow $title]
    }
  }

  # Default
  return [helpWindow "Contents"]
}

proc helpWindow {name {heading ""}} {
  help_PushStack $name
  updateHelpWindow $name $heading
}

proc updateHelpWindow {name {heading ""}} {
  global helpWin helpText helpTitle windowsOS language
  set w .helpWin
  
  set slist [split $name " "]
  if {[llength $slist] > 1} {
    set name [lindex $slist 0]
    set heading [lindex $slist 1]
  }
  
  if {[info exists helpText($language,$name)] && [info exists helpTitle($language,$name)]} {
    set title $helpTitle($language,$name)
    set helptext $helpText($language,$name)
  } elseif {[info exists helpText($name)] && [info exists helpTitle($name)]} {
    set title $helpTitle($name)
    set helptext $helpText($name)
  } else {
    return
  }
  
  if {![winfo exists $w]} {
    toplevel $w
    # wm geometry $w -10+0
    setWinLocation $w
    setWinSize $w
    
    wm minsize $w 20 5
    text $w.text -setgrid yes -wrap word -width $::winWidth($w) -height $::winHeight($w) -relief sunken -border 0 -yscroll "$w.scroll set"
    ttk::scrollbar $w.scroll -command "$w.text yview"
    
    ttk::frame $w.b -relief raised -border 2
    pack $w.b -side bottom -fill x
    ttk::button $w.b.contents -textvar ::tr(Contents) -command { helpWindow Contents }
    ttk::button $w.b.index -textvar ::tr(Index) -command { helpWindow Index }
    ttk::button $w.b.back -textvar ::tr(Back) -command { help_PopStack }
    ttk::button $w.b.close -textvar ::tr(Close) -command {
      set ::helpWin(Stack) {}
      set ::helpWin(yStack) {}
      destroy .helpWin
    }
    
    pack $w.b.contents $w.b.index $w.b.back -side left -padx 1 -pady 2
    pack $w.b.close -side right -padx 5 -pady 2
    pack $w.scroll -side right -fill y -padx 2 -pady 2
    pack $w.text -fill both -expand 1 -padx 1
    
    $w.text configure -font font_Regular -foreground black -background white
    ::htext::init $w.text
    bind $w <Configure> "recordWinSize $w"
  }
  
  $w.text configure -cursor top_left_arrow
  $w.text configure -state normal
  $w.text delete 0.0 end
  
  $w.b.index configure -state normal
  if {$name == "Index"} { $w.b.index configure -state disabled }
  $w.b.contents configure -state normal
  if {$name == "Contents"} { $w.b.contents configure -state disabled }
  $w.b.back configure -state disabled
  if {[llength $helpWin(Stack)] >= 2} {
    $w.b.back configure -state normal
  }
  
  wm title $w "Scid Help: $title"
  wm iconname $w "Scid help"
  
  $w.text delete 0.0 end
  bind $w <Up> "$w.text yview scroll -1 units"
  bind $w <Down> "$w.text yview scroll 1 units"
  bind $w <Prior> "$w.text yview scroll -1 pages"
  bind $w <Next> "$w.text yview scroll 1 pages"
  bind $w <Key-Home> "$w.text yview moveto 0"
  bind $w <Key-End> "$w.text yview moveto 0.99"
  bind $w <Escape> "$w.b.close invoke"
  bind $w <Key-b> "$w.b.back invoke"
  bind $w <Left> "$w.b.back invoke"
  bind $w <Key-i> "$w.b.index invoke"
  
  ::htext::display $w.text $helptext $heading 0
  focus $w
}

proc ::htext::updateRate {w rate} {
  set ::htext::updates($w) $rate
}

proc ::htext::init {w} {
  set cyan "\#007000"
  set maroon "\#990000"
  set green "green"
  
  set ::htext::updates($w) 100
  set ::htext::amountVar($w) 0
  set ::htext::hideVarValue($w) {}
  $w tag configure black -foreground black
  $w tag configure white -foreground white
  $w tag configure red -foreground red
  $w tag configure blue -foreground RoyalBlue3
  $w tag configure darkblue -foreground DodgerBlue3
  $w tag configure green -foreground $green
  $w tag configure cyan -foreground $cyan
  $w tag configure yellow -foreground yellow
  $w tag configure maroon -foreground $maroon
  $w tag configure gray -foreground gray20
  
  $w tag configure bgBlack -background black
  $w tag configure bgWhite -background white
  $w tag configure bgRed -background red
  $w tag configure bgBlue -background blue
  $w tag configure bgLightBlue -background lightBlue
  $w tag configure bgGreen -background $green
  $w tag configure bgCyan -background $cyan
  $w tag configure bgYellow -background yellow
  
  $w tag configure tab -lmargin2 50
  $w tag configure li -lmargin2 50
  $w tag configure center -justify center
  
  if {[$w cget -font] == "font_Small"} {
    $w tag configure b -font font_SmallBold
    $w tag configure i -font font_SmallItalic
  } else {
    $w tag configure b -font font_Bold
    $w tag configure i -font font_Italic
  }
  $w tag configure bi -font font_BoldItalic
  $w tag configure tt -font font_Fixed
  $w tag configure u -underline 1
  $w tag configure h1 -font font_H1 -foreground $::htext::headingColor \
      -justify center
  $w tag configure h2 -font font_H2 -foreground $::htext::headingColor
  $w tag configure h3 -font font_H3 -foreground $::htext::headingColor
  $w tag configure h4 -font font_H4 -foreground $::htext::headingColor
  $w tag configure h5 -font font_H5 -foreground $::htext::headingColor
  $w tag configure footer -font font_Small -justify center
  
  $w tag configure term -font font_BoldItalic -foreground $::htext::headingColor
  $w tag configure menu -font font_Bold -foreground $cyan
  
  # PGN-window-specific tags:
  $w tag configure nag -font font_Regular -foreground $::pgnColor(Nag)

  set lmargin 0
  for {set i 1} {$i <= 19} {incr i} {
    incr lmargin 25
    $w tag configure "ip$i" -lmargin1 $lmargin -lmargin2 $lmargin
  }
}

proc ::htext::isStartTag {tagName} {
  return [expr {![strIsPrefix "/" $tagName]} ]
}

proc ::htext::isEndTag {tagName} {
  return [strIsPrefix "/" $tagName]
}

proc ::htext::isLinkTag {tagName} {
  return [strIsPrefix "a " $tagName]
}

proc ::htext::extractLinkName {tagName} {
  if {[::htext::isLinkTag $tagName]} {
    return [lindex [split [string range $tagName 2 end] " "] 0]
  }
  return ""
}

proc ::htext::extractSectionName {tagName} {
  if {[::htext::isLinkTag $tagName]} {
    return [lindex [split [string range $tagName 2 end] " "] 1]
  }
  return ""
}

set ::htext::interrupt 0

# Process a link tag
proc ::htext::aTagProcess {w tagName} {
    set linkName [::htext::extractLinkName $tagName]
    set sectionName [::htext::extractSectionName $tagName]
    set linkTag "link ${linkName} ${sectionName}"
    $w tag configure "$linkTag" -foreground blue -underline 1
    $w tag bind "$linkTag" <ButtonRelease-1> \
            "helpWindow $linkName $sectionName"
    $w tag bind $linkTag <Any-Enter> \
        "$w tag configure \"$linkTag\" -background yellow
            $w configure -cursor hand2"
    $w tag bind $linkTag <Any-Leave> \
        "$w tag configure \"$linkTag\" -background {}
         $w configure -cursor {}"
    return [list a $linkTag ]
}
# Process a url tag
proc ::htext::urlTagProcess {w tagName} {
    set urlName [string range $tagName 4 end]
    set urlTag "url $urlName"
    $w tag configure "$urlTag" -foreground red -underline 1
        $w tag bind "$urlTag" <ButtonRelease-1> "openURL {$urlName}"
    $w tag bind $urlTag <Any-Enter> \
        "$w tag configure \"$urlTag\" -background yellow
            $w configure -cursor hand2"
    $w tag bind $urlTag <Any-Leave> \
            "$w tag configure \"$urlTag\" -background {}
            $w configure -cursor {}"
    return [list url $urlTag ]
}
# Process a Tcl command tag:
proc ::htext::runTagProcess {w tagName} {
    set runName [string range $tagName 4 end]
    set runTag "run $runName"
    $w tag bind "$runTag" <ButtonRelease-1> "catch {$runName}"
    $w tag bind $runTag <Any-Enter> \
        "$w tag configure \"$runTag\" -foreground white
            $w tag configure \"$runTag\" -background DodgerBlue4
            $w configure -cursor hand2"
    $w tag bind $runTag <Any-Leave> \
        "$w tag configure \"$runTag\" -foreground {}
        $w tag configure \"$runTag\" -background {}
        $w configure -cursor {}"
    return [list run $runTag ]
}
# Process a goto tag
proc ::htext::goTagProcess {w tagName} {
    # Check if it is a goto tag:
    set goName [string range $tagName 3 end]
    set goTag "go $goName"
    $w tag bind "$goTag" <ButtonRelease-1> \
        "catch {$w see \[lindex \[$w tag nextrange $goName 1.0\] 0\]}"
    $w tag bind $goTag <Any-Enter> \
        "$w tag configure \"$goTag\" -foreground yellow
        $w tag configure \"$goTag\" -background maroon
        $w configure -cursor hand2"
    $w tag bind $goTag <Any-Leave> \
        "$w tag configure \"$goTag\" -foreground {}
        $w tag configure \"$goTag\" -background {}
        $w configure -cursor {}"
    return [list go $goTag ]
}
# Process a player info tag
proc ::htext::piTagProcess {w playerTag} {
    set playerName [string range $playerTag 3 end]
    $w tag configure "$playerTag" -foreground DodgerBlue3
    $w tag bind "$playerTag" <ButtonRelease-1> "::pinfo::playerInfo \"$playerName\""
    $w tag bind $playerTag <Any-Enter> \
        "$w tag configure \"$playerTag\" -foreground white
        $w tag configure \"$playerTag\" -background DodgerBlue4
        $w configure -cursor hand2"
    $w tag bind $playerTag <Any-Leave> \
        "$w tag configure \"$playerTag\" -foreground DodgerBlue3
        $w tag configure \"$playerTag\" -background {}
        $w configure -cursor {}"
return [list pi $playerTag ]
}
# Process a game-load tag
proc ::htext::gTagProcess {w gameTag} {
    set gnum [string range $gameTag 2 end]
    set glCommand "::game::LoadMenu $w [sc_base current] $gnum %X %Y"
    $w tag bind $gameTag <ButtonPress-1> $glCommand
    $w tag bind $gameTag <ButtonPress-$::MB3> \
        "::gbrowser::new [sc_base current] $gnum"
    $w tag bind $gameTag <Any-Enter> \
        "$w tag configure $gameTag -foreground white
         $w tag configure $gameTag -background DodgerBlue4
         $w configure -cursor hand2"
    $w tag bind $gameTag <Any-Leave> \
        "$w tag configure $gameTag -foreground {}
    $w tag configure $gameTag -background {}
    $w configure -cursor {}"
    return [list g $gameTag ]
}
# Process a move tag
proc ::htext::mTagProcess {w moveTag} {
    $w tag bind $moveTag <ButtonRelease-1> "sc_move pgn [string range $moveTag 2 end]; updateBoard"
    # Bind middle button to popup a PGN board:
    $w tag bind $moveTag <ButtonPress-$::MB2> "::pgn::ShowBoard .pgnWin.text $moveTag %X %Y"
    $w tag bind $moveTag <ButtonRelease-$::MB2> "::pgn::HideBoard"
    # invoking contextual menu in PGN window
    $w tag bind $moveTag <ButtonPress-$::MB3> "sc_move pgn [string range $moveTag 2 end]; updateBoard"
    $w tag bind $moveTag <Any-Enter> "$w tag configure $moveTag -underline 1
    $w configure -cursor hand2"
    $w tag bind $moveTag <Any-Leave> "$w tag configure $moveTag -underline 0
    $w configure -cursor {}"
    return [list m $moveTag ]
}
# Process a comment tag
proc ::htext::cTagProcess {w commentTag} {
    $w tag configure $commentTag -foreground $::pgnColor(Comment) -font font_Regular
    $w tag bind $commentTag <ButtonRelease-1> "sc_move pgn [string range $commentTag 2 end]; updateBoard; ::makeCommentWin"
    $w tag bind $commentTag <Any-Enter> "$w tag configure $commentTag -underline 1
    $w configure -cursor hand2"
    $w tag bind $commentTag <Any-Leave> "$w tag configure $commentTag -underline 0
    $w configure -cursor {}"
    return [list c $commentTag ]
}
proc ::htext::imgTagProcess {w tagName} {
    set imgName [string range $tagName 4 end]
    #flags are not loaded on start, so check if a flag needs to load
    if { $imgName ne [info commands $imgName] && [string range $imgName 0 3] eq "flag" } {
      set imgName [getFlagImage [string range $imgName [expr [string length $imgName] - 3] end] yes]
    }
    set winName $w.$imgName
    while {[winfo exists $winName]} { append winName a }
    ttk::label $winName -image $imgName -relief flat -borderwidth 0 -background white
    $w window create end -window $winName
}
proc ::htext::buttonTagProcess {w tagName} {
    set idx [ string first "-command" $tagName]
    set cmd ""
    if {$idx == -1} {
      set imgName [string range $tagName 7 end]
    } else  {
      set imgName [string trim [string range $tagName 7 [expr $idx -1]]]
      set cmd [ string range $tagName [expr $idx +9] end ]
    }
    set winName $w.$imgName
    while {[winfo exists $winName]} { append winName a }
    ttk::button $winName -image $imgName -command $cmd
    $w window create end -window $winName
}
proc ::htext::windowTagProcess {w tagName} {
    set winName [string range $tagName 7 end]
    $w window create end -window $winName
}
#insert a board diagramm after movenr
proc ::htext::insertBoard {w movenr} {
    ::board::new $w.bd$movenr 25
    set offSet [sc_pos pgnOffset]
    sc_move pgn $movenr
    set bd [sc_pos board]
    sc_move pgn $offSet
    if {[::board::isFlipped .main.board]} {set bd [string reverse [lindex $bd 0]]}
    ::board::update $w.bd$movenr $bd
    $w insert end "\n\n\t\t"
    $w window create end -window $w.bd$movenr
    $w insert end "\n\n"
}
#calc number of variations in pgn string to check if number has changed 
proc ::htext::countVar {w str} {
    set count [regsub -all "<var>" $str {} stripped]
    set ::htext::varChanged [expr $count - $::htext::amountVar($w)]
    set ::htext::amountVar($w) $count
}
#insert toggle token [+] or [-] for show/hide the variation
proc ::htext::varTagProcess {w tagName varIndex} {
    set hideVar $::pgn::hideVar
    set start [$w index insert]
    set pos [$w count -chars 0.0 $start]
    if {[llength $::htext::hideVarValue($w)] > $varIndex } {
        #if tag exists then use it
        if { $::htext::varChanged != 0 } {
            # number of variations has changed, ajust the values
            if { $::htext::varChanged > 0 && $pos ne $::htext::pos($varIndex)} {
                # a variation was inserted
                set ::htext::hideVarValue($w) [linsert $::htext::hideVarValue($w) $varIndex $::pgn::hideVar]
                set ::htext::varChanged 0
            } elseif { $::htext::varChanged < 0 && $pos ne $::htext::pos($varIndex)} {
                # a variation was deleted
                set ::htext::hideVarValue($w) [lreplace $::htext::hideVarValue($w) $varIndex $varIndex]
                set ::htext::varChanged 0
            }
        }
        set hideVar [lindex $::htext::hideVarValue($w) $varIndex]
    }
    if { $hideVar } {
        $w insert end " \[+\] "
    } else {
        $w insert end " \[-\] "
    }
    set end [$w index insert]
    $w tag configure var$varIndex -elide $hideVar -font font_Regular -foreground $::pgnColor(Var)
    $w tag lower var$varIndex
    $w tag configure toggle$varIndex -font font_Regular -foreground $::pgnColor(Var)
    $w tag bind toggle$varIndex <ButtonRelease-1> "::htext::toggleHideVar $w $varIndex"
    $w tag add toggle$varIndex $start $end
    set ::htext::pos($varIndex) $pos
    set ::htext::hideVarValue($w) [lreplace $::htext::hideVarValue($w) $varIndex $varIndex $hideVar]
    return [list var var$varIndex [expr {$varIndex+1}]]
}

#Helper procs for show/hide variation
#when new game is loaded delete all tags with varN
proc ::htext::deleteToggleVar { w } {
    foreach i [ lsearch -all -inline [$w tag names] var* ] {
        $w tag delete $i
    }
    set ::htext::amountVar($w) 0
    set ::htext::hideVarValue($w) { }
}

#make sure a variation is shown when a move from variation is on the board
proc ::htext::showVar { w pos } {
    set tag [lsearch -inline [$w tag names $pos] var*]
    if { $tag ne "" && [$w tag cget $tag -elide]} {
        ::htext::toggleHideVar $w [string range $tag 3 end]
    }
}

#reset status for hide/show on all variations according hideVar
proc ::htext::resetToggleVar { w hideVar} {
    set i [llength $::htext::hideVarValue($w)]
    while { $i > 0 } {
        incr i -1
        toggleHideVar $w $i $hideVar
    }
}

#toggle status of hide/show of a variation or set it to hv
proc ::htext::toggleHideVar { w n {hv ""}} {
    lassign [$w tag nextrange toggle$n 1.0] start end
    if { $hv eq "" } {
        set hv [expr - [$w tag cget var$n -elide] + 1 ];
    }
    $w tag configure var$n -elide $hv
    $w configure -state normal
    if { $hv } {
        $w replace $start $end " \[+\] "
    } else {
        $w replace $start $end " \[-\] "
    }
    $w tag configure var$n -elide $hv
    $w tag add toggle$n $start $end
    $w configure -state disabled
    set ::htext::hideVarValue($w) [lreplace $::htext::hideVarValue($w) $n $n $hv]
}

proc ::htext::display {w str {section ""} {fixed 1}} {
  global helpWin
  # set start [clock clicks -milli]
  set helpWin(Indent) 0
  set ::htext::interrupt 0
  $w mark set insert 0.0
  $w configure -state normal
  set count 0
  set varIndex 0
  if {$fixed} {
    regsub -all "\n\n" $str "<p>" str
    regsub -all "\n" $str " " str
  } else {
    regsub -all "\[ \n\]+" $str " " str
    regsub -all ">\[ \n\]+" $str "> " str
    regsub -all "\[ \n\]+<" $str " <" str
  }
  set seePoint ""

  if {! [info exists ::htext::updates($w)]} {
    set ::htext::updates($w) 100
  }

  # Loop through the text finding the next formatting tag:
  while {1} {
    set startPos [string first "<" $str]
    if {$startPos < 0} { break }
    set endPos [string first ">" $str]
    if {$endPos < 1} { break }

    set tagName [string range $str [expr {$startPos + 1}] [expr {$endPos - 1}]]

    # Now insert the text up to the formatting tag:
    set text [string range $str 0 [expr {$startPos - 1}]]
    $w insert end $text

    # Check if it is a starting tag (no "/" at the start) and process the tag:
    set tagList { "a" aTagProcess "url" urlTagProcess "run" runTagProcess "go" goTagProcess "pi" piTagProcess "g_" gTagProcess
                  "m_" mTagProcess "c_" cTagProcess "var" varTagProcess "img" imgTagProcess "button" buttonTagProcess "window" windowTagProcess }
    if {![strIsPrefix "/" $tagName]} {
      set fullTag($tagName) $tagName
      foreach {tag proc} $tagList {
        if {[strIsPrefix $tag $tagName]} {
          switch $tag {
              img - button - window { $proc $w $tagName }
              var { lassign [$proc $w $tagName $varIndex] tagName fullTag($tagName) varIndex }
              default { lassign [$proc $w $tagName] tagName fullTag($tagName) }
          }
          break
        }
      }
    }

    #check for Diagramm in NAG D or in comment [#]
    if { $::pgn::showDiagramm && [info exists fullTag(m)] && (([strIsPrefix "/nag" $tagName] && [string first " D" $text] >= 0) ||
         ([strIsPrefix "/c" $tagName] && [string first "\[#\]" $text] >= 0 ))} {
        # fullTag(m) has the movenumber of the last processed move
        insertBoard $w [string range $fullTag(m) 2 end]
    }
    # Check if it is a name tag matching the section we want:
    if {$section != ""  &&  [strIsPrefix "name " $tagName]} {
      set sect [string range $tagName 5 end]
      if {$section == $sect} { set seePoint [$w index insert] }
    }

    if {[string index $tagName 0] == "/"} {
      # Get rid of initial "/" character:
      set tagName [string range $tagName 1 end]
      switch -- $tagName {
        menu {$w insert end "\]"}
        ul   {incr helpWin(Indent) -4; $w insert end "\n"}
        h1 - h2 - h3 - h4 - h5 - p {$w insert end "\n"}
      }
      if {[info exists startIndex($tagName)]} {
        $w tag add $fullTag($tagName) $startIndex($tagName) [$w index insert]
        unset startIndex($tagName)
      }
    } else {
      switch -- $tagName {
        ul {incr helpWin(Indent) 4}
        li {
          $w insert end "\n"
          for {set space 0} {$space < $helpWin(Indent)} {incr space} {
            $w insert end " "
          }
        }
        q  {$w insert end "\""}
        lt {$w insert end "<"}
        gt {$w insert end ">"}
        menu {$w insert end "\["}
        h1 - h2 - h3 - h4 - h5 - p - br {$w insert end "\n"}
      }
      #Set the start index for this type of tag:
      set startIndex($tagName) [$w index insert]
    }
    # Now eliminate the processed text from the string:
    set str [string range $str [expr {$endPos + 1}] end]
    incr count
    if {$count == $::htext::updates($w)} { update idletasks; set count 1 }
    if {$::htext::interrupt} {
      $w configure -state disabled
      return
    }
  }

  # Now add any remaining text:
  if {! $::htext::interrupt} { $w insert end $str }
  
  if {$seePoint != ""} { $w yview $seePoint }
  $w configure -state disabled
  # set elapsed [expr {[clock clicks -milli] - $start}]
}


# openURL:
#    Sends a command to the user's web browser to view a webpage given
#    its URL.
#
proc openURL {url} {
  global windowsOS
  busyCursor .
  if {$windowsOS} {
    # On Windows, use the "start" command:
    regsub -all " " $url "%20" url
    if {[string match $::tcl_platform(os) "Windows NT"]} {
      catch {exec $::env(COMSPEC) /c start $url &}
    } else {
      catch {exec start $url &}
    }
  } elseif {$::macOS} {
    # On Mac OS X use the "open" command:
    catch {exec open $url &}
  } else {
    # First, check if xdg-open works:
    if {! [catch {exec xdg-open $url &}] } {
	#lauch default browser seems ok, nothing more to do
    } elseif {[file executable [auto_execok firefox]]} {
      # Mozilla seems to be available:
      # First, try -remote mode:
      if {[catch {exec /bin/sh -c "$::auto_execs(firefox) -remote 'openURL($url)'"}]} {
        # Now try a new Mozilla process:
        catch {exec /bin/sh -c "$::auto_execs(firefox) '$url'" &}
      }
    } elseif {[file executable [auto_execok iceweasel]]} {
      # First, try -remote mode:
      if {[catch {exec /bin/sh -c "$::auto_execs(iceweasel) -remote 'openURL($url)'"}]} {
        # Now try a new Mozilla process:
        catch {exec /bin/sh -c "$::auto_execs(iceweasel) '$url'" &}
      }
    } elseif {[file executable [auto_execok mozilla]]} {
      # First, try -remote mode:
      if {[catch {exec /bin/sh -c "$::auto_execs(mozilla) -remote 'openURL($url)'"}]} {
        # Now try a new Mozilla process:
        catch {exec /bin/sh -c "$::auto_execs(mozilla) '$url'" &}
      }
    } elseif {[file executable [auto_execok www-browser]]} {
      # Now try a new Mozilla process:
      catch {exec /bin/sh -c "$::auto_execs(www-browser) '$url'" &}
    } elseif {[file executable [auto_execok netscape]]} {
      # OK, no Mozilla (poor user) so try Netscape (yuck):
      # First, try -remote mode to avoid starting a new netscape process:
      if {[catch {exec /bin/sh -c "$::auto_execs(netscape) -raise -remote 'openURL($url)'"}]} {
        # Now just try starting a new netscape process:
        catch {exec /bin/sh -c "$::auto_execs(netscape) '$url'" &}
      }
    } else {
      foreach executable {iexplorer opera lynx w3m links epiphan galeon
        konqueror mosaic amaya browsex elinks} {
        set executable [auto_execok $executable]
        if [string length $executable] {
          # Is there any need to give options to these browsers? how?
          set command [list $executable $url &]
          catch {exec /bin/sh -c "$executable '$url'" &}
          break
        }
      }
    }
  }
  unbusyCursor .
}
