# maint.tcl:   Maintenance-related functions
# Part of Scid.
# Copyright (C) 2000-2004 Shane Hudson.

namespace eval ::maint {}

### TODO: Move procedures and variables into the maint namespace.
### TODO: Make sub-namespaces (sort, compact, cleaner, etc)

################################################################################
# ::maint::SetGameFlags
#
#   Updates a flag for the current game, all filtered games, or all games.
#   <type> should be "current", "filter" or "all".
#   <flag> should be "delete", "user", "endgame", etc.
#   <value> should be 0 or 1
#
proc ::maint::SetGameFlags {flag type value} {
  if {$flag == "mark"} { set flag $::maintFlag }
  if {$value} {
    set op "set"
  } else {
    set op "unset"
  }
  set base [sc_base current]
  switch -- $type {
    "current" {
      sc_base gameflag $base [sc_game number] $op $flag
    }
    "filter" {
      busyCursor .
      update idletasks
      sc_base gameflag $base "dbfilter" $op $flag
      unbusyCursor .
    }
    "all" {
      busyCursor .
      update idletasks
      sc_base gameflag $base "all" $op $flag
      unbusyCursor .
    }
    default { return }
  }
  updateBoard
  ::notify::DatabaseModified [sc_base current]
}

set maintFlag W
set maintFlaglist {W B M E N P T Q K ! ? U 1 2 3 4 5 6}
array set maintFlags {
  W WhiteOpFlag
  B BlackOpFlag
  M MiddlegameFlag
  E EndgameFlag
  N NoveltyFlag
  P PawnFlag
  T TacticsFlag
  Q QsideFlag
  K KsideFlag
  ! BrilliancyFlag
  ? BlunderFlag
  U UserFlag
  1 CustomFlag1
  2 CustomFlag2
  3 CustomFlag3
  4 CustomFlag4
  5 CustomFlag5
  6 CustomFlag6
}


set maintWin 0

# ::maint::OpenClose
#
#   Creates the database maintenance window.
#
proc ::maint::OpenClose {} {
  global maintWin maintFlag maintFlags maintFlaglist
  set w .maintWin
  if {[winfo exists $w]} {
    destroy $w
    set maintWin 0
    return
  }
  set maintWin 1
  set font font_Small
  set bold font_SmallBold
  toplevel $w
  wm title $w "Scid: [tr FileMaint]"
  wm resizable $w 0 0
  bind $w <F1> {helpWindow Maintenance}
  bind $w <Escape> "destroy $w; break"
  bind $w <Destroy> {set maintWin 0}
  foreach f {title delete mark spell db buttons} {
    ttk::frame $w.$f
  }
  foreach f {title delete mark spell db} {
    pack $w.$f -side top -fill x
    addHorizontalRule $w
  }
  pack $w.buttons -side top -fill x
  
  ttk::label $w.title.name -textvar ::tr(DatabaseName) -font font_Bold
  ttk::label $w.title.games -textvar ::tr(NumOfGames) -font font_SmallBold
  ttk::label $w.title.icon -textvar ::tr(TypeIcon)
  ttk::label $w.title.delete -textvar ::tr(NumDeletedGames) -font $font
  ttk::label $w.title.mark -font $font
  ttk::label $w.title.filter -textvar ::tr(NumFilterGames) -font $font
  ttk::label $w.title.dates -textvar ::tr(YearRange) -font $font
  ttk::label $w.title.ratings -textvar ::tr(RatingRange) -font $font
  ttk::button $w.title.vicon -command {changeBaseType [sc_base current]}
  
  ttk::frame $w.title.desc
  ttk::label $w.title.desc.lab -text $::tr(Description:) -font font_SmallBold
  ttk::label $w.title.desc.text -width 1 -font $font -relief sunken -anchor w
  ttk::button $w.title.desc.edit -text "[tr Edit]..." -style Small.TButton -command ::maint::ChangeBaseDescription
  pack $w.title.desc.lab -side left
  pack $w.title.desc.edit -side right -padx 2
  pack $w.title.desc.text -side left -fill x -expand yes
  
  # Custom flags
  ttk::frame $w.title.cust
  ttk::label $w.title.cust.lab -text "[::tr CustomFlags]:" -font font_SmallBold
  for {set i 1} { $i < 7} { incr i} {
    set desc [sc_game flag $i description]
    ttk::label $w.title.cust.text$i -width 8 -font $font -relief sunken -anchor w -text $desc
  }
  
  ttk::button $w.title.cust.edit -text "[tr Edit]..." -style Small.TButton -command ::maint::ChangeCustomDescription
  pack $w.title.cust.lab -side left
  pack $w.title.cust.edit -side right -padx 2
  for {set i 1} { $i < 7} { incr i} {
    pack $w.title.cust.text$i -side left -fill x -expand yes
  }
  foreach name {name games delete mark filter dates ratings} {
    ttk::label $w.title.v$name -text "0" -font $font
  }
  
  set row 0
  set col 0
  foreach name {name icon games filter delete mark dates ratings} {
    grid $w.title.$name -row $row -column $col -sticky w
    incr col
    grid $w.title.v$name -row $row -column $col -sticky e
    incr col
    if {$col == 2} { incr col }
    if {$col >= 5} { set col 0; incr row }
  }
  grid [ttk::label $w.title.space -text "   "] -row 0 -column 2
  $w.title.vname configure -font font_Bold
  $w.title.vgames configure -font font_SmallBold
  grid $w.title.desc -row $row -column 0 -columnspan 5 -sticky we
  incr row
  grid $w.title.cust -row $row -column 0 -columnspan 5 -sticky we
  
  foreach grid {title delete mark spell db} cols {5 3 3 4 3} {
    for {set i 0} {$i < $cols} {incr i} {
      grid columnconfigure $w.$grid $i -weight 1
    }
  }
  
  ttk::label $w.delete.title -textvar ::tr(DeleteFlag) -font $bold
  ttk::menubutton $w.mark.title -menu $w.mark.title.m ;# -indicatoron 1 -relief raised -font $bold
  menu $w.mark.title.m -font $font
  
  set i 0
  foreach flag $maintFlaglist  {
    if {$i < 12} {
      $w.mark.title.m add command -label "$::tr($maintFlags($flag)) ($flag)" -command "set maintFlag $flag; ::maint::Refresh"
    } else  {
      set tmp [sc_game flag $flag description]
      if {$tmp == "" } { set tmp $maintFlags($flag) }
      $w.mark.title.m add command -label "$tmp ($flag)" -command "set maintFlag $flag; ::maint::Refresh"
    }
    incr i
  }
  
  foreach flag {delete mark} on {Delete Mark} off {Undelete Unmark} {
    foreach b {Current Filter All} {
      ttk::button $w.$flag.on$b -textvar "::tr($on$b)" -style Small.TButton -command "::maint::SetGameFlags $flag [string tolower $b] 1"
      ttk::button $w.$flag.off$b -textvar "::tr($off$b)" -style Small.TButton -command "::maint::SetGameFlags $flag [string tolower $b] 0"
    }
    
    grid $w.$flag.title -columnspan 3 -row 0 -column 0 -sticky n
    grid $w.$flag.onCurrent -row 1 -column 0 -sticky we
    grid $w.$flag.offCurrent -row 2 -column 0 -sticky we
    grid $w.$flag.onFilter -row 1 -column 1 -sticky we
    grid $w.$flag.offFilter -row 2 -column 1 -sticky we
    grid $w.$flag.onAll -row 1 -column 2 -sticky we
    grid $w.$flag.offAll -row 2 -column 2 -sticky we
  }
  
  ttk::label $w.spell.title -textvar ::tr(Spellchecking) -font $bold
  grid $w.spell.title -columnspan 4 -row 0 -column 0 -sticky n
  ttk::button $w.spell.player -textvar ::tr(Players...) -style Small.TButton \
      -command "openSpellCheckWin Player $w"
  ttk::button $w.spell.event -textvar ::tr(Events...) -style Small.TButton \
      -command "openSpellCheckWin Event $w"
  ttk::button $w.spell.site -textvar ::tr(Sites...) -style Small.TButton \
      -command "openSpellCheckWin Site $w"
  ttk::button $w.spell.round -textvar ::tr(Rounds...) -style Small.TButton \
      -command "openSpellCheckWin Round $w"
  grid $w.spell.player -row 1 -column 0 -sticky we
  grid $w.spell.event -row 1 -column 1 -sticky we
  grid $w.spell.site -row 1 -column 2 -sticky we
  grid $w.spell.round -row 1 -column 3 -sticky we
  
  bind $w <Alt-p> "$w.spell.player invoke"
  bind $w <Alt-e> "$w.spell.event invoke"
  bind $w <Alt-s> "$w.spell.site invoke"
  bind $w <Alt-r> "$w.spell.round invoke"
  
  ttk::label $w.db.title -textvar ::tr(DatabaseOps) -font $bold
  grid $w.db.title -columnspan 3 -row 0 -column 0 -sticky n
  
  ttk::button $w.db.check -style Small.TButton -textvar ::tr(CheckGames...) -command checkAllGames
  ttk::button $w.db.eco -style Small.TButton -textvar ::tr(ReclassifyGames...) -command classifyAllGames
  ttk::button $w.db.compact -style Small.TButton -textvar ::tr(CompactDatabase...) -command makeCompactWin
  ttk::button $w.db.sort -style Small.TButton -textvar ::tr(SortDatabase...) -command makeSortWin
  ttk::button $w.db.elo -style Small.TButton -textvar ::tr(AddEloRatings...) -command allocateRatings
  ttk::button $w.db.dups -style Small.TButton -textvar ::tr(DeleteTwins...) -command "markTwins $w"
  ttk::button $w.db.cleaner -style Small.TButton -textvar ::tr(Cleaner...) -command cleanerWin
  ttk::button $w.db.autoload -style Small.TButton -textvar ::tr(AutoloadGame...) -command ::maint::SetAutoloadGame
  ttk::button $w.db.strip -style Small.TButton -textvar ::tr(StripTags...) -command stripTags
  
  foreach i {eco compact sort elo dups cleaner autoload strip} {
    $w.db.$i configure -style Small.TButton
  }
  bind $w <Alt-d> "$w.db.dups invoke"
  
  grid $w.db.eco -row 1 -column 0 -sticky we
  grid $w.db.compact -row 1 -column 1 -sticky we
  grid $w.db.sort -row 1 -column 2 -sticky we
  grid $w.db.elo -row 2 -column 0 -sticky we
  grid $w.db.dups -row 2 -column 1 -sticky we
  grid $w.db.cleaner -row 2 -column 2 -sticky we
  grid $w.db.autoload -row 3 -column 0 -sticky we
  grid $w.db.strip -row 3 -column 1 -sticky we
  grid $w.db.check -row 3 -column 2 -sticky we
  
  dialogbutton $w.buttons.help -textvar ::tr(Help) -command {helpWindow Maintenance}
  dialogbutton $w.buttons.close -textvar ::tr(Close) -command "destroy $w"
  packbuttons right $w.buttons.close $w.buttons.help
  
  bind $w <Alt-h> "$w.buttons.help invoke"
  bind $w <Alt-c> "destroy $w; break"
  standardShortcuts $w
  ::maint::Refresh
}

proc ::maint::ChangeBaseDescription {} {
  set w .bdesc
  if {[winfo exists $w]} { return }
  toplevel $w
  wm title $w "Scid: $::tr(Description): [file tail [sc_base filename]]"
  set font font_Small
  ttk::entry $w.entry -width 50 ;# -relief sunken -background white
  $w.entry insert end [sc_base description]
  pack $w.entry -side top -pady 4
  ttk::frame $w.b
  ttk::button $w.b.ok -text OK -command {
    catch {sc_base description [.bdesc.entry get]}
    grab release .bdesc
    destroy .bdesc
    ::maint::Refresh
  }
  ttk::button $w.b.cancel -text $::tr(Cancel) -command "grab release $w; destroy $w"
  pack $w.b -side bottom -fill x
  pack $w.b.cancel $w.b.ok -side right -padx 2 -pady 2
  wm resizable $w 0 0
  catch {grab $w}
}
################################################################################
#  Change custom flags description
################################################################################
proc ::maint::ChangeCustomDescription {} {
  set w .bcustom
  if {[winfo exists $w]} { return }
  toplevel $w
  wm title $w "Scid: $::tr(CustomFlags): [file tail [sc_base filename]]"
  ttk::frame $w.a
  ttk::label $w.a.lb -text [::tr CustomFlags]
  grid $w.a.lb -column 0 -row 0 -columnspan 12
  set col 0
  for {set i 1} {$i <7} {incr i} {
    ttk::label $w.a.lab$i -text "$i:"
    ttk::entry $w.a.e$i -width 8
    set desc [sc_game flag $i description]
    $w.a.e$i insert end $desc
    grid $w.a.lab$i -column $col -row 1
    incr col
    grid $w.a.e$i -column $col -row 1
    incr col
  }
  ttk::frame $w.b
  ttk::button $w.b.ok -text OK -command {
    for {set i 1} {$i <7} {incr i} {
      set desc [.bcustom.a.e$i get]
      sc_game flag $i setdescription $desc
    }
    grab release .bcustom
    destroy .bcustom
    
    # update the drop down menu of maint window and the menu of GameInfo window
    for {set idx 12} {$idx < 18} {incr idx} {
      set flag [ lindex $::maintFlaglist $idx]
      set tmp [sc_game flag $flag description]
      if {$tmp == "" } { set tmp $::maintFlags($flag) }
      .maintWin.mark.title.m entryconfigure $idx -label "$tmp ($flag)"
    }
    
    updateGameInfoMenu
    
    # update the custom flags labels
    for {set i 1} { $i < 7} { incr i} {
      set desc [sc_game flag $i description]
      .maintWin.title.cust.text$i configure -text $desc
    }
    # ::maint::Refresh
  }
  ttk::button $w.b.cancel -text $::tr(Cancel) -command "grab release $w; destroy $w"
  pack $w.a -side top -fill x
  pack $w.b -side bottom -fill x
  pack $w.b.cancel $w.b.ok -side right -padx 2 -pady 2
  wm resizable $w 0 0
  catch {grab $w}
}

proc ::maint::Refresh {} {
  global maintFlag maintFlags
  updateSortWin
  updateClassifyWin
  
  set w .maintWin
  if {![winfo exists $w]} { return }
  set ng [sc_base numGames]
  set deleted [sc_base stats flag:D]
  set marked [sc_base stats "flag:$maintFlag"]
  set flags [sc_base stats flags]
  set dates [sc_base stats date]
  set ratings [sc_base stats ratings]
  $w.title.vgames configure -text [::utils::thousands $ng]
  $w.title.vicon configure -image dbt[sc_base type [sc_base current]]
  $w.title.vname configure -text [file tail [sc_base filename]]
  $w.title.vdelete configure -text [::utils::percentFormat $deleted $ng]
  $w.title.vmark configure -text [::utils::percentFormat $marked $ng]
  $w.title.vfilter configure -text [::utils::percentFormat [sc_filter count] $ng]
  $w.title.vdates configure \
      -text "[lindex $dates 0]-[lindex $dates 1] ([lindex $dates 2])"
  $w.title.vratings configure \
      -text "[lindex $ratings 0]-[lindex $ratings 1] ([lindex $ratings 2])"
  
  if { [lsearch -exact { 1 2 3 4 5 6 } $maintFlag ] != -1 } {
    set tmp [sc_game flag $maintFlag description]
    if {$tmp == "" } { set tmp $maintFlags($maintFlag) }
  } else  {
    set tmp $::tr($maintFlags($maintFlag))
  }
  
  set flagname "$::tr(Flag): $tmp ($maintFlag)"
  
  $w.mark.title configure -text $flagname
  $w.title.mark configure -text $flagname
  $w.title.desc.text configure -text [sc_base description]
  
  # Disable buttons if current base is closed or read-only:
  set state disabled
  set curr_base [sc_base current]
  if {[sc_base inUse]  &&  ![sc_base isReadOnly $curr_base]} {
    set state normal
  }
  foreach spell {player event site round} {
    $w.spell.$spell configure -state $state
  }
  foreach button {onCurrent offCurrent onAll offAll onFilter offFilter} {
    $w.delete.$button configure -state $state
    $w.mark.$button configure -state $state
  }
  $w.db.dups configure -state $state
  $w.title.vicon configure -state $state
  $w.title.desc.edit configure -state $state
  $w.db.elo configure -state $state
  $w.db.autoload configure -state $state
  
  set state disabled
  if {[sc_base inUse]} { set state normal }
  $w.db.eco configure -state $state
  $w.db.sort configure -state $state
  $w.db.strip configure -state $state
  
  set state disabled
  if {[baseIsCompactable]} {
    set state normal
  }
  $w.db.compact configure -state $state
  $w.db.cleaner configure -state $state
}


set autoloadGame 0
trace variable autoloadGame w {::utils::validate::Integer 9999999 0}

# ::maint::SetAutoloadGame
#
#   Creates a dialog for setting the autoload game number of the
#   current database.
#
proc ::maint::SetAutoloadGame {} {
  global autoloadGame
  set w .autoload
  if {[winfo exists $w]} { return }
  toplevel $w
  wm title $w "Scid"
  set autoloadGame [sc_base autoload]
  
  pack [ttk::frame $w.f] -side top -fill x -expand 1
  ttk::label $w.f.label -text $::tr(AutoloadGame:)
  ttk::entry $w.f.entry -textvar autoloadGame -justify right -width 10 ;# -foreground black -background white
  pack $w.f.label $w.f.entry -side left
  
  pack [ttk::frame $w.set] -side top -fill x
  ttk::button $w.set.none -text $::tr(None) -command {set autoloadGame 0}
  ttk::button $w.set.first -text $::tr(First) -command {set autoloadGame 1}
  ttk::button $w.set.current -text $::tr(Current) \
      -command {set autoloadGame [sc_game number]}
  ttk::button $w.set.last -text $::tr(Last) -command {set autoloadGame 9999999}
  foreach i {none first current last} {$w.set.$i configure -style Small.TButton}
  pack $w.set.none $w.set.first $w.set.current $w.set.last \
      -side left -padx 1 -pady 2
  
  addHorizontalRule $w
  
  pack [ttk::frame $w.b] -side top -fill x
  ttk::button $w.b.ok -text OK -command \
      "sc_base autoload \$autoloadGame; catch {grab release $w}; destroy $w"
  ttk::button $w.b.cancel -text $::tr(Cancel) -command \
      "catch {grab release $w}; destroy $w"
  pack $w.b.cancel $w.b.ok -side right -padx 2
  
  bind $w.f.entry <Return> "$w.b.ok invoke"
  bind $w.f.entry <Escape> "$w.b.cancel invoke"
  wm resizable $w 0 0
  ::utils::win::Centre $w
  focus $w.f.entry
  grab $w
}

# markTwins:
#   Finds twin games and marks them for deletion.
#   Takes parent window as parameter since it can be the main window,
#   or the maintenance window.
#
proc markTwins {{parent .}} {
  global twinSettings
  if {! [sc_base inUse]} { return }
  if {[sc_base numGames] == 0} {
    tk_messageBox -type ok -icon info -title [concat "Scid: " $::tr(noGames)] \
        -message $::tr(TwinCheckNoDelete)
    return
  }
  
  set w .twinSettings
  if {! [winfo exists $w]} {
    toplevel $w
    wm resizable $w 0 0
    wm title $w "Scid: $::tr(DeleteTwins)"
    pack [ttk::frame $w.f]
    set small font_Small
    
    ttk::label $w.f.note -text $::tr(TwinsNote) -justify left -wraplength 500 -font $small
    pack $w.f.note -side top -anchor w -ipady 0 -pady 0
    addHorizontalRule $w.f
    ttk::label $w.f.tc -text $::tr(TwinsCriteria) -font font_Bold
    pack $w.f.tc -side top
    
    ttk::frame $w.f.g
    pack $w.f.g -side top
    set row 0
    set col 0
    foreach name {Colors Event Site Round Year Month Day Result ECO Moves} {
      set n [string tolower $name]
      ttk::checkbutton $w.f.g.b$n -text $::tr(Twins$name) \
          -variable twinSettings($n) -onvalue Yes -offvalue No
      grid $w.f.g.b$n -row $row -column $col -sticky w
      incr col
      if {$col >= 4} {
        incr row; set col 0
      } else {
        grid [ttk::label $w.f.g.space$n -text "   "] -row $row -column $col
        incr col
      }
    }
    ttk::frame $w.f.players
    ttk::label $w.f.players.label -text $::tr(TwinsPlayers) -font $small
    ttk::radiobutton $w.f.players.yes -variable twinSettings(players) -value Yes \
        -text $::tr(TwinsPlayersExact) -style Small.TRadiobutton
    ttk::radiobutton $w.f.players.no -variable twinSettings(players) -value No \
        -text $::tr(TwinsPlayersPrefix) -style Small.TRadiobutton
    
    pack $w.f.players -side top
    pack $w.f.players.label $w.f.players.yes $w.f.players.no -side left
  }
  
  
  addHorizontalRule $w.f
  ttk::label $w.f.twhich -text $::tr(TwinsWhich:) -font font_Bold
  pack $w.f.twhich -side top
  pack [ttk::frame $w.f.g2] -side top -fill x
  ttk::radiobutton $w.f.g2.exall -text $::tr(SelectAllGames) -style Small.TRadiobutton \
      -variable twinSettings(usefilter) -value No
  ttk::label $w.f.g2.space -text "    " -font $small
  ttk::radiobutton $w.f.g2.exfil -text $::tr(SelectFilterGames) -style Small.TRadiobutton \
      -variable twinSettings(usefilter) -value Yes
  grid $w.f.g2.exall -row 0 -column 0 -sticky e
  grid $w.f.g2.space -row 0 -column 1
  grid $w.f.g2.exfil -row 0 -column 2 -sticky w
  grid columnconfigure $w.f.g2 0 -weight 1
  grid columnconfigure $w.f.g2 2 -weight 1
  
  addHorizontalRule $w.f
  ttk::label $w.f.twhen -text $::tr(TwinsWhen:) -font font_Bold
  pack $w.f.twhen -side top
  pack [ttk::frame $w.f.g3] -side top
  set row 0
  set col 0
  foreach n {skipshort undelete setfilter comments variations} \
      name {SkipShort Undelete SetFilter Comments Vars} {
        ttk::checkbutton $w.f.g3.b$n -text $::tr(Twins$name) -variable twinSettings($n) -onvalue Yes -offvalue No
        grid $w.f.g3.b$n -row $row -column $col -sticky w
        incr col
        if {$col >= 2} {
          incr row; set col 0
        } else {
          grid [ttk::label $w.f.g3.space$n -text "   "] -row $row -column $col
          incr col
        }
      }
  incr row
  #$w.f.g3.lskipshort configure -text $::tr(TwinsSkipShort)
  #$w.f.g3.lundelete configure -text $::tr(TwinsUndelete)
  #$w.f.g3.lsetfilter configure -text $::tr(TwinsSetFilter)
  #$w.f.g3.lcomments configure -text $::tr(TwinsComments)
  #$w.f.g3.lvariations configure -text $::tr(TwinsVars)
  ttk::label $w.f.g3.ldelete -text $::tr(TwinsDeleteWhich) -font font_Bold
  grid $w.f.g3.ldelete -row $row -column 0 -sticky we -columnspan 3
  incr row
  ttk::frame $w.f.g3.vdelete
  foreach v {Shorter Older Newer} {
    ttk::radiobutton $w.f.g3.vdelete.v$v -text $::tr(TwinsDelete$v) \
        -variable twinSettings(delete) -value $v -style Small.TRadiobutton
    pack $w.f.g3.vdelete.v$v -side left -padx 5
  }
  grid $w.f.g3.vdelete -row $row -column 0 -columnspan 3
  
  #foreach g {g2 g3} {
  #  grid columnconfigure $w.f.$g 0 -weight 1
  #}
  
  addHorizontalRule $w.f
  ttk::frame $w.f.b
  dialogbutton $w.f.b.defaults -textvar ::tr(Defaults) -command {
    array set twinSettings [array get twinSettingsDefaults]
  }
  dialogbuttonsmall $w.f.b.help [ list -text $::tr(Help) -command "helpWindow Maintenance Twins; focus $w" ]
  dialogbuttonsmall $w.f.b.go [ list -text $::tr(TwinsDelete) -command {
    if {[twinCriteriaOK .twinSettings]} {
      grab release .twinSettings
      sc_progressBar .twinSettings.progress bar 301 21 time
      set result [doMarkDups .twinSettings]
      focus .
      destroy .twinSettings
      if {$result > 0} {
        set gn [sc_filter first]
        ::game::Load $gn
        updateTwinChecker
      }
    }
  } ]
  
  dialogbuttonsmall $w.f.b.cancel [ list -text $::tr(Cancel) -command "grab release $w; focus .; destroy $w" ]
  
  canvas $w.f.progress -width 300 -height 20 -bg white -relief solid -border 1
  $w.f.progress create rectangle 0 0 0 0 -fill blue -outline blue -tags bar
  $w.f.progress create text 295 10 -anchor e -font font_Regular -tags time \
      -fill black -text "0:00 / 0:00"
  
  pack $w.f.progress -side bottom -padx 2 -pady 2
  pack $w.f.b -side bottom -fill x
  packbuttons right  $w.f.b.cancel $w.f.b.go
  packbuttons left $w.f.b.defaults $w.f.b.help
  bind $w <F1> "$w.f.b.help invoke"
  bind $w <Escape> "$w.f.b.cancel invoke"
  bind $w <Return> "$w.f.b.go invoke"
  grab $w
  update idletasks
  $w.f.note configure -wraplength [winfo width $w]
  return
}

# twinCriteriaOK:
#   Check that the user specified at least three of the the same site,
#   same round, and same year settings, since otherwise it is quite
#   likely that actual games with simlar moves will be marked as twins:
#
proc twinCriteriaOK {{parent .}} {
  global twinSettings
  
  set msg $::tr(TwinCriteria1)
  
  # First, check that if same moves is off, then the same colors, event,
  # site, round, year and month flags should all be set:
  if {$twinSettings(moves) == "No"} {
    if {$twinSettings(colors) == "No"  ||  $twinSettings(event) == "No"  || \
          $twinSettings(site) == "No"  ||  $twinSettings(year) == "No"  || \
          $twinSettings(month) == "No"} {
      append msg $::tr(TwinCriteria2)
      set result [tk_messageBox -type yesno -parent $parent -icon warning \
          -title $::tr(TwinCriteriaConfirm) \
          -message $msg]
      if {$result == "no"} { return 0 } else { return 1 }
    }
  }
  
  # Now check that at least two of site, round, and year are set:
  set count 0
  if {$twinSettings(site) == "Yes"} { incr count }
  if {$twinSettings(round) == "Yes"} { incr count }
  if {$twinSettings(year) == "Yes"} { incr count }
  if {$count < 2} {
    append msg $::tr(TwinCriteria3)
    set result [tk_messageBox -type yesno -parent $parent -icon warning \
        -title $::tr(TwinCriteriaConfirm) \
        -message $msg]
    if {$result == "no"} { return 0 } else { return 1 }
  }
  return 1
}


proc doMarkDups {{parent .}} {
  global twinSettings
  
  busyCursor .
  if {$twinSettings(undelete) == "Yes"} {
    sc_base gameflag [sc_base current] all unset del
  }

  if {[catch {sc_base duplicates -colors $twinSettings(colors) \
          -event $twinSettings(event) -site $twinSettings(site) \
          -round $twinSettings(round) -year $twinSettings(year) \
          -month $twinSettings(month) -day $twinSettings(day) \
          -result $twinSettings(result) -eco $twinSettings(eco) \
          -moves $twinSettings(moves) -players $twinSettings(players) \
          -skipshort $twinSettings(skipshort) \
          -setfilter $twinSettings(setfilter) \
          -usefilter $twinSettings(usefilter) \
          -comments $twinSettings(comments) \
          -variations $twinSettings(variations) \
          -delete $twinSettings(delete)} result]} {
    unbusyCursor .
    tk_messageBox -type ok -parent $parent -icon info \
        -title "Scid" -message $result
    set result 0
  } else {
    unbusyCursor .
    set message [subst $::tr(TwinCheckFound1)]
    if {$result > 0} {append message $::tr(TwinCheckFound2)}
    append message "."
    tk_messageBox -type ok -parent $parent -icon info -title [concat "Scid: " $::tr(Result)] \
        -message $message
  }
  ::maint::Refresh
  return $result
}


set checkOption(AllGames) all

# CheckAllGames
#  Decodes all games and tries to find errors
proc checkAllGames {} {
  set w .checkGames
  if {[winfo exists $w]} {
    raiseWin $w
    return
  }
  toplevel $w
  wm title $w "Scid: [tr FileMaintClass]"
  
  pack [ttk::frame $w.f] -expand 1
  
  ttk::label $w.f.label -font font_Bold -textvar ::tr(CheckGamesWhich)
  ttk::frame $w.f.g
  ttk::radiobutton $w.f.g.all -textvar ::tr(CheckAll) -variable checkOption(AllGames) -value all
  ttk::radiobutton $w.f.g.filter -textvar ::tr(CheckSelectFilterGames) -variable checkOption(AllGames) -value filter
  set row 0
  foreach f {all filter} {
    grid $w.f.g.$f -row $row -column 0 -sticky w
    incr row
  }
  
  ttk::frame $w.f.b
  ttk::button $w.f.b.go -textvar ::tr(CheckGames) -command {
    busyCursor .
    .checkGames.f.b.cancel configure -command "sc_progressBar"
    .checkGames.f.b.cancel configure -textvar ::tr(Stop)
    sc_progressBar .checkGames.f.progress bar 301 21 time
    grab .checkGames.f.b.cancel
    if {[catch  {sc_base check $checkOption(AllGames)} result]} {
      grab release .checkGames.f.b.cancel
      unbusyCursor .
      tk_messageBox -parent .checkGames -type ok -icon info -title "Scid" -message $result
    } else {
      grab release .checkGames.f.b.cancel
      unbusyCursor .
    }
    .checkGames.f.b.cancel configure -command {focus .; destroy .checkGames}
    .checkGames.f.b.cancel configure -textvar ::tr(Close)
    ::windows::gamelist::Refresh
  }
  ttk::button $w.f.b.cancel -textvar ::tr(Close) -command "focus .; destroy $w"
  canvas $w.f.progress -width 300 -height 20 -bg white -relief solid -border 1
  $w.f.progress create rectangle 0 0 0 0 -fill blue -outline blue -tags bar
  $w.f.progress create text 295 10 -anchor e -font font_Regular -tags time \
      -fill black -text "0:00 / 0:00"
  
  pack $w.f.label $w.f.g -side top -pady 5
  addHorizontalRule $w.f
  pack $w.f.b -side top -pady 5 -fill x
  pack $w.f.progress -side bottom -padx 2 -pady 2
  pack $w.f.b.cancel $w.f.b.go -side right -pady 10 -padx 10
  wm resizable $w 0 0
  bind $w <F1> {helpWindow ECO}
  bind $w <Escape> "$w.b.cancel invoke"
  updateClassifyWin
}


set classifyOption(AllGames) all
set classifyOption(ExtendedCodes) 1

# ClassifyAllGames:
#   Reclassifies all games (recomputes the ECO code of each game).
#   User can choose to reclassify all games, or only those games that
#   currently have no ECO code assigned.
#
proc classifyAllGames {} {
  makeClassifyWin
}

proc makeClassifyWin {} {
  global classifyOption
  set w .classify
  if {[winfo exists $w]} {
    raiseWin $w
    return
  }
  toplevel $w
  wm title $w "Scid: [tr FileMaintClass]"
  
  pack [ttk::frame $w.f] -expand 1
  
  ttk::label $w.f.label -font font_Bold -textvar ::tr(ClassifyWhich)
  ttk::frame $w.f.g
  ttk::radiobutton $w.f.g.all -textvar ::tr(ClassifyAll) -variable classifyOption(AllGames) -value all
  ttk::radiobutton $w.f.g.filter -textvar ::tr(SelectFilterGames) -variable classifyOption(AllGames) -value filter
  set year [::utils::date::today year]
  set month [::utils::date::today month]
  set day [::utils::date::today day]
  ttk::radiobutton $w.f.g.year -textvar ::tr(ClassifyYear) -variable classifyOption(AllGames) \
      -value "date:[expr $year - 1].$month.$day"
  if {$month == "01"} {
    incr year -1
    set month 12
  } else {
    scan $month "%02u" month
    incr month -1
    set month [format "%02u" $month]
  }
  ttk::radiobutton $w.f.g.month -textvar ::tr(ClassifyMonth) -variable classifyOption(AllGames) \
      -value "date:$year.$month.$day"
  ttk::radiobutton $w.f.g.new -textvar ::tr(ClassifyNew) -variable classifyOption(AllGames) -value nocode
  set row 0
  foreach f {all filter year month new} {
    grid $w.f.g.$f -row $row -column 0 -sticky w
    incr row
  }
  ttk::label $w.f.codes -font font_Bold -textvar ::tr(ClassifyCodes:)
  ttk::radiobutton $w.f.extended -textvar ::tr(ClassifyBasic) -variable classifyOption(ExtendedCodes) -value 0
  ttk::radiobutton $w.f.basic -textvar ::tr(ClassifyExtended) -variable classifyOption(ExtendedCodes) -value 1
  
  ttk::frame $w.f.b
  ttk::button $w.f.b.go -textvar ::tr(Classify) -command {
    busyCursor .
    .classify.f.b.cancel configure -command "sc_progressBar"
    .classify.f.b.cancel configure -textvar ::tr(Stop)
    sc_progressBar .classify.f.progress bar 301 21 time
    grab .classify.f.b.cancel
    if {[catch  {sc_eco base $classifyOption(AllGames) $classifyOption(ExtendedCodes)} result]} {
      grab release .classify.f.b.cancel
      unbusyCursor .
      tk_messageBox -parent .classify -type ok -icon info -title "Scid" -message $result
    } else {
      grab release .classify.f.b.cancel
      unbusyCursor .
    }
    .classify.f.b.cancel configure -command {focus .; destroy .classify}
    .classify.f.b.cancel configure -textvar ::tr(Close)
    ::windows::gamelist::Refresh
  }
  ttk::button $w.f.b.cancel -textvar ::tr(Close) -command "focus .; destroy $w"
  canvas $w.f.progress -width 300 -height 20 -bg white -relief solid -border 1
  $w.f.progress create rectangle 0 0 0 0 -fill blue -outline blue -tags bar
  $w.f.progress create text 295 10 -anchor e -font font_Regular -tags time \
      -fill black -text "0:00 / 0:00"
  
  pack $w.f.label $w.f.g -side top -pady 5
  addHorizontalRule $w.f
  pack $w.f.codes $w.f.extended $w.f.basic -side top -pady 5
  addHorizontalRule $w.f
  pack $w.f.b -side top -pady 5 -fill x
  pack $w.f.progress -side bottom -padx 2 -pady 2
  pack $w.f.b.cancel $w.f.b.go -side right -pady 10 -padx 10
  wm resizable $w 0 0
  bind $w <F1> {helpWindow ECO}
  bind $w <Escape> "$w.b.cancel invoke"
  updateClassifyWin
}

proc updateClassifyWin {} {
  set w .classify
  if {! [winfo exists $w]} { return }
  set state disabled
  if {[sc_base inUse]} { set state normal }
  $w.f.b.go configure -state $state
}

# Twin checker window:
# Shows PGN of current game, and its twin.

set twincheck(left) 0
set twincheck(right) 0

proc updateTwinChecker {} {
  global twincheck
  set w .twinchecker
  if {![winfo exists $w]} {
    toplevel $w
    pack [ttk::frame $w.b] -side bottom -fill x
    pack [ttk::frame $w.f] -side top -fill both -expand yes
    ttk::frame $w.f.left
    pack $w.f.left -side left -fill y -expand yes
    ttk::frame $w.f.split -width 2 -borderwidth 2 -relief sunken
    pack $w.f.split -side left -fill y -padx 5
    ttk::frame $w.f.right
    pack $w.f.right -side left -fill y -expand yes
    foreach i {left right} {
      set f $w.f.$i
      pack [ttk::frame $f.title] -side top -fill x
      ttk::label $f.title.label -font font_Bold -text [concat $::tr(game) " 0: "]
      ttk::checkbutton $f.title.d -text $::tr(Deleted) -variable twincheck($i) -style Small.TCheckbutton
      ttk::label $f.title.note -font font_Small
      pack $f.title.label $f.title.d $f.title.note -side left
      ttk::label $f.tmt -font font_Small -text "" -anchor w -width 1 -relief sunken
      pack $f.tmt -side bottom -fill x
      autoscrollframe $f.t text $f.t.text \
          -height 16 -width 40 -background white \
          -takefocus 0 -wrap word
      $f.t.text tag configure h -background lightSteelBlue
      pack $f.t -side top -fill both -expand yes
    }
    $w.f.left.title.note configure -text [concat "(\"1\"" $::tr(TwinCheckUndelete)]
    $w.f.right.title.note configure -text  [concat "(\"2\"" $::tr(TwinCheckUndelete)]
    ttk::button $w.b.prev -text $::tr(TwinCheckprevPair) \
        -command {::game::LoadNextPrev previous}
    ttk::button $w.b.next -text $::tr(TwinChecknextPair) -underline 0 \
        -command {::game::LoadNextPrev next}
    ttk::button $w.b.share -text $::tr(TwinCheckTag) -underline 0
    ttk::button $w.b.delete -text $::tr(DeleteTwins) -underline 0 \
        -command "markTwins $w"
    ttk::button $w.b.help -text $::tr(Help) -command {helpWindow Maintenance Twins}
    ttk::button $w.b.close -text $::tr(Close) -command "focus .; destroy $w"
    pack $w.b.close $w.b.help $w.b.delete -side right -padx 5 -pady 2
    pack $w.b.prev $w.b.next $w.b.share -side left -padx 5 -pady 2
    bind $w <F1> "$w.b.help invoke"
    bind $w <Escape> "focus .; destroy $w"
    bind $w <Alt-p> {::game::LoadNextPrev previous}
    bind $w <KeyPress-p> {::game::LoadNextPrev previous}
    bind $w <Alt-n> {::game::LoadNextPrev next}
    bind $w <KeyPress-n> {::game::LoadNextPrev next}
    bind $w <Alt-d> "markTwins $w"
    bind $w <KeyPress-d> "markTwins $w"
    bind $w <KeyPress-1> "$w.f.left.title.d invoke"
    bind $w <KeyPress-$::MB2> "$w.f.right.title.d invoke"
    bind $w <KeyPress-s> "$w.b.share invoke"
    bind $w <KeyPress-u> {
      if {$twincheck(left)} {.twinchecker.f.left.title.d invoke}
      if {$twincheck(right)} {.twinchecker.f.right.title.d invoke}
    }
    bind $w <Alt-u> {
      if {$twincheck(left)} {.twinchecker.f.left.title.d invoke}
      if {$twincheck(right)} {.twinchecker.f.right.title.d invoke}
    }
    wm resizable $w 0 1
    wm title $w $::tr(TwinChecker)
  }
  
  set gn [sc_game number]
  set dup 0
  if {$gn > 0} {
    set dup [sc_game info duplicate]
  }
  set twincheck(left) 0
  set twincheck(right) 0
  
  $w.f.left.title.label configure -text [concat $::tr(game) " $gn:  "]
  
  if {$gn > 0} {
    set twincheck(left) [sc_game flag delete $gn]
    $w.f.left.title.d configure -command "sc_game flag delete $gn invert; updateBoard"
    $w.f.left.title.d configure -state normal
    set tmt [sc_game crosstable count +deleted]
    $w.f.left.tmt configure -text [concat $::tr(TwinCheckTournament) $tmt]
  } else {
    $w.f.left.title.d configure -state disabled
    $w.f.left.tmt configure -text ""
  }
  if {$dup > 0} {
    set twincheck(right) [sc_game flag delete $dup]
    $w.f.right.title.label configure -text [concat $::tr(game) " $dup:  "]
    $w.f.right.title.d configure -command "sc_game flag delete $dup invert; updateBoard"
    $w.f.right.title.d configure -state normal
    set tmt [sc_game crosstable count -game $dup +deleted]
    $w.f.right.tmt configure -text [concat $::tr(TwinCheckTournament) $tmt]
  } else {
    $w.f.right.title.label configure -text $::tr(TwinCheckNoTwin)
    $w.f.right.title.d configure -state disabled
    $w.f.right.tmt configure -text ""
  }
  
  $w.b.share configure -state disabled -command {}
  if {$gn > 0  &&  $dup > 0} {
    if {[llength [sc_game tags share check $gn $dup]] > 0} {
      $w.b.share configure -state normal -command "shareTwinTags $gn $dup $w"
    }
  }
  set t $w.f.left.t.text
  $t configure -state normal
  $t delete 1.0 end
  $t insert end [sc_game pgn]
  
  set t $w.f.right.t.text
  $t configure -state normal
  $t delete 1.0 end
  if {$dup > 0} {
    $t insert end [sc_game pgn -gameNumber $dup]
  } else {
    $t insert end $::tr(TwinCheckNoTwinfound)
  }
  
  # Now color the differences if appropriate:
  if {$dup > 0} {
    set rlen [$w.f.right.t.text index end-1c]
    set llen [$w.f.left.t.text index end-1c]
    
    for {set i 0} {$i < $rlen} {incr i} {
      set line [$w.f.right.t.text get $i.0 "$i.0 lineend"]
      set length [string length $line]
      set max 0
      for {set j 0} {$j < $llen} {incr j} {
        set otherLine [$w.f.left.t.text get $j.0 "$j.0 lineend"]
        set plen [strPrefixLen $line $otherLine]
        if {$plen > $max} { set max $plen }
      }
      if {$max < $length} {
        if {![string compare [string index $line 0] "\["]} { set max 0 }
        $w.f.right.t.text tag add h $i.$max "$i.0 lineend"
      }
    }
    
    for {set i 0} {$i < $llen} {incr i} {
      set line [$w.f.left.t.text get $i.0 "$i.0 lineend"]
      set length [string length $line]
      set max 0
      for {set j 0} {$j < $rlen} {incr j} {
        set otherLine [$w.f.right.t.text get $j.0 "$j.0 lineend"]
        set plen [strPrefixLen $line $otherLine]
        if {$plen > $max} { set max $plen }
      }
      if {$max < $length} {
        if {![string compare [string index $line 0] "\["]} { set max 0 }
        $w.f.left.t.text tag add h $i.$max "$i.0 lineend"
      }
    }
  }
  
  if {[sc_base inUse]} {
    $w.b.delete configure -state normal
  } else {
    $w.b.delete configure -state disabled
  }
  
  foreach side {left right} {
    $w.f.$side.t.text configure -state disabled
  }
  
}

# shareTwinTags:
#   Updates the tags of two twin games by sharing information,
#   filling in the date, round or ratings of each game based on
#   the other where possible.
#
proc shareTwinTags {g1 g2 {parent .}} {
  set sharelist [sc_game tags share check $g1 $g2]
  if {[llength $sharelist] == 0} { return }
  
  set msg $::tr(TwinChangeTag)
  foreach {gn tag old new} $sharelist {
    append msg [concat $::tr(game) " $gn: $tag: \"$old\" -> \"$new\""]
    append msg "\n"
  }
  set answer [tk_messageBox -parent $parent -title "Scid" \
      -type okcancel -default ok -icon question -message $msg]
  if {$answer != "ok"} { return }
  sc_game tags share update $g1 $g2
  sc_game tags reload
  updateBoard -pgn
  ::windows::gamelist::Refresh
}

# baseIsCompactable:
#   Returns true only if the current base is compactable.
#
proc baseIsCompactable {} {
  # Only a database that is in use, not read-only, and not the
  # clipbase, can be compacted:
  set curr_base [sc_base current]
  if {! [sc_base inUse]} { return 0 }
  if {[sc_base isReadOnly $curr_base]} { return 0 }
  if {$curr_base == [sc_info clipbase]} { return 0 }
  return 1
}

# makeCompactWin:
# Opens the database compaction dialog box.
#
proc makeCompactWin {} {
  if {! [baseIsCompactable]} { return }
  set w .compactWin
  toplevel $w
  wm title $w "Scid: $::tr(CompactDatabase)"
  wm resizable $w 0 0
  foreach f {top names games buttons} { ttk::frame $w.$f }
  pack $w.top -side top -expand 1 -fill both
  pack $w.names -in $w.top -side left -fill x -anchor n
  addVerticalRule $w.top 12
  pack $w.games -in $w.top -side left -fill x -anchor n
  addHorizontalRule $w
  pack $w.buttons -side top -fill x
  
  for {set i 0} {$i < 3} {incr i} {
    grid columnconfigure $w.names $i -weight 1
    grid columnconfigure $w.games $i -weight 1
  }
  ttk::label $w.names.title -text $::tr(NameFile) -font font_Bold
  grid $w.names.title -columnspan 3 -row 0 -column 0 -sticky n
  ttk::label $w.names.nt -text "  $::tr(Names)"
  grid $w.names.nt -row 1 -column 1 -sticky e
  ttk::label $w.names.ut -text "  $::tr(Unused)"
  grid $w.names.ut -row 1 -column 2 -sticky e
  ttk::frame $w.names.h -height 1 -relief solid ;# -bg black
  grid $w.names.h -columnspan 3 -row 2 -column 0 -sticky we
  set row 3
  set ndata [sc_compact stats names]
  set idx 0
  foreach n {p e s r} name {Players Events Sites Rounds} {
    ttk::label $w.names.t$n -text "$::tr($name)  "
    ttk::label $w.names.n$n -text "  [::utils::thousands [lindex $ndata $idx]]"
    incr idx
    ttk::label $w.names.u$n -text "  [::utils::thousands [lindex $ndata $idx]]"
    incr idx
    grid $w.names.t$n -row $row -column 0 -sticky w
    grid $w.names.n$n -row $row -column 1 -sticky e
    grid $w.names.u$n -row $row -column 2 -sticky e
    incr row
  }
  
  ttk::label $w.games.title -text $::tr(GameFile) -font font_Bold
  grid $w.games.title -columnspan 3 -row 0 -column 0 -sticky n
  ttk::label $w.games.gt -text "  [::utils::string::Capital $::tr(games)]"
  grid $w.games.gt -row 1 -column 1 -sticky e
  ttk::label $w.games.st -text "  $::tr(SizeKb)"
  grid $w.games.st -row 1 -column 2 -sticky e
  ttk::frame $w.games.h -height 1 -relief solid ;# -bg black
  grid $w.games.h -columnspan 3 -row 2 -column 0 -sticky we
  set row 3
  set ndata [sc_compact stats games]
  set idx 0
  foreach g {current compact} name {CurrentState AfterCompaction} {
    ttk::label $w.games.t$g -text "$::tr($name)  "
    ttk::label $w.games.g$g -text "  [::utils::thousands [lindex $ndata $idx]]"
    incr idx
    set kbytes [expr {int(([lindex $ndata $idx] + 512) / 1024)} ]
    ttk::label $w.games.s$g -text "  [::utils::thousands $kbytes]"
    incr idx
    grid $w.games.t$g -row $row -column 0 -sticky w
    grid $w.games.g$g -row $row -column 1 -sticky e
    grid $w.games.s$g -row $row -column 2 -sticky e
    incr row
  }
  
  ttk::button $w.buttons.n -text $::tr(CompactNames) -command "compactNames; destroy $w"
  ttk::button $w.buttons.g -text $::tr(CompactGames) -command "compactGames; destroy $w"
  ttk::button $w.buttons.help -text $::tr(Help) -command {helpWindow Compact}
  ttk::button $w.buttons.cancel -text $::tr(Cancel) -command "focus .; grab release $w; destroy $w"
  pack $w.buttons.cancel $w.buttons.help -side right -padx 5 -pady 2
  pack $w.buttons.n $w.buttons.g -side left -padx 5 -pady 2
  grab $w
}

proc compactNames {{base -1}} {
  if {$base < 0} { set base [sc_base current] }
  set stats [sc_base compact $base stats names]
  if {[lindex $stats 1] == 0  &&  [lindex $stats 3] == 0  && \
        [lindex $stats 5] == 0  &&  [lindex $stats 7] == 0} {
    tk_messageBox -type ok -icon info -parent . -title [concat "Scid: " $::tr(CompactNames)] -message $::tr(NoUnusedNames)
    return
  }
  progressWindow "Scid" [concat $::tr(CompactNames) "..."]
  busyCursor .
  set err [catch {sc_base compact $base names} result]
  unbusyCursor .
  closeProgressWindow
  if {$err} {
    tk_messageBox -type ok -icon warning -parent . -title "Scid: Error compacting file" -message $result
  } else {
    tk_messageBox -type ok -icon info -parent . -title [concat "Scid: " $::tr(CompactNames)] -message [subst $::tr(NameFileCompacted)]
  }
  ::notify::DatabaseModified $base
}

proc compactGames {{base -1}} {
  if {$base < 0} { set base [sc_base current] }
  set stats [sc_base compact $base stats games]
  if {[lindex $stats 1] == [lindex $stats 3]  && \
        [lindex $stats 0] == [lindex $stats 2]} {
    tk_messageBox -type ok -icon info -parent . -title [concat "Scid: " $::tr(CompactGames)] -message $::tr(NoUnusedGames)
    return
  }
  progressWindow "Scid" [concat $::tr(CompactGames) "..."] \
      $::tr(Cancel) "sc_progressBar"
  busyCursor .
  set err [catch {sc_base compact $base games} result]
  unbusyCursor .
  closeProgressWindow
  if {$err} {
    tk_messageBox -type ok -icon warning -parent . \
        -title "Scid: Error compacting file" -message $result
  } else {
    tk_messageBox -type ok -icon info -parent . \
        -title [concat "Scid: " $::tr(CompactGames)] \
        -message [subst $::tr(GameFileCompacted)]
  }
  ::notify::DatabaseModified $base
}

set sortCriteria(real) ""
set sortCriteria(translated) ""

proc clearSortCriteria {} {
  set ::sortCriteria(real) ""
  set ::sortCriteria(translated) ""
  updateSortWin
}

proc addSortCriteria {args} {
  global sortCriteria
  foreach x $args {
    if {$sortCriteria(real) == ""} {
      set sortCriteria(real) $x
      set sortCriteria(translated) $::tr($x)
    } else {
      append sortCriteria(real) ", $x"
      append sortCriteria(translated) ", $::tr($x)"
    }
  }
  updateSortWin
}

proc makeSortWin {} {
  global sortCriteria
  set w .sortWin
  if {[winfo exists $w]} {
    raiseWin $w
    return
  }
  toplevel $w
  wm title $w "Scid: [tr FileMaintSort]"
  wm resizable $w 0 0
  pack [ttk::frame $w.f]
  
  ttk::label $w.f.torder -textvar ::tr(SortCriteria:) -font font_Bold
  pack $w.f.torder -side top
  ttk::label $w.f.order -textvar sortCriteria(translated) -width 40 -background white \
      -relief solid -anchor w
  pack $w.f.order -side top -fill x -pady 2 -padx 2
  addHorizontalRule $w.f
  ttk::label $w.f.tadd -textvar ::tr(AddCriteria:) -font font_Bold
  pack $w.f.tadd -side top
  pack [ttk::frame $w.f.add] -side top -fill x
  foreach b {Date Year Month Event Site Country Round Result Length
    White Black Rating ECO Deleted EventDate} {
    set n [string tolower $b]
    ttk::button $w.f.add.$n -textvar ::tr($b) -command "addSortCriteria $b"
  }
  grid $w.f.add.date -row 0 -column 0 -sticky we
  grid $w.f.add.year -row 0 -column 1 -sticky we
  grid $w.f.add.month -row 0 -column 2 -sticky we
  grid $w.f.add.event -row 1 -column 0 -sticky we
  grid $w.f.add.site -row 1 -column 1 -sticky we
  grid $w.f.add.country -row 1 -column 2 -sticky we
  grid $w.f.add.round -row 2 -column 0 -sticky we
  grid $w.f.add.result -row 2 -column 1 -sticky we
  grid $w.f.add.length -row 2 -column 2 -sticky we
  grid $w.f.add.white -row 3 -column 0 -sticky we
  grid $w.f.add.black -row 3 -column 1 -sticky we
  grid $w.f.add.rating -row 3 -column 2 -sticky we
  grid $w.f.add.eco -row 4 -column 0 -sticky we
  grid $w.f.add.deleted -row 4 -column 1 -sticky we
  grid $w.f.add.eventdate -row 4 -column 2 -sticky we
  
  for {set i 0} {$i < 3} {incr i} {
    grid columnconfigure $w.f.add $i -weight 1
  }
  
  addHorizontalRule $w.f
  
  ttk::label $w.f.tcommon -textvar ::tr(CommonSorts:) -font font_Bold
  pack $w.f.tcommon -side top
  pack [ttk::frame $w.f.tc] -side top -fill x
  ttk::button $w.f.tc.ymsedr -text "$::tr(Year), $::tr(Month), $::tr(Site), $::tr(Event), $::tr(Date), $::tr(Round)" -command {
    clearSortCriteria
    addSortCriteria Year Month Site Event Date Round
  }
  ttk::button $w.f.tc.yedr -text "$::tr(Year), $::tr(Event), $::tr(Date), $::tr(Round)" -command {
    clearSortCriteria
    addSortCriteria Year Event Date Round
  }
  ttk::button $w.f.tc.er -text "$::tr(ECO), $::tr(Rating)" -command {
    clearSortCriteria
    addSortCriteria ECO Rating
  }
  grid $w.f.tc.ymsedr -row 0 -column 0 -sticky we
  grid $w.f.tc.yedr -row 1 -column 0 -sticky we
  grid $w.f.tc.er -row 2 -column 0 -sticky we
  grid columnconfigure $w.f.tc 0 -weight 1
  addHorizontalRule $w.f
  pack [ttk::frame $w.f.b] -side bottom -fill x
  ttk::button $w.f.b.clear -textvar ::tr(Clear) -command clearSortCriteria
  ttk::button $w.f.b.help -textvar ::tr(Help) -command {helpWindow Sorting}
  ttk::button $w.f.b.sort -textvar ::tr(Sort) -command sortDatabase
  ttk::button $w.f.b.close -textvar ::tr(Close) \
      -command "focus .; destroy $w"
  pack $w.f.b.close $w.f.b.sort -side right -padx 5 -pady 2
  pack $w.f.b.clear $w.f.b.help -side left -padx 5 -pady 2
  bind $w <F1> {helpWindow Sorting}
  bind $w <Escape> "$w.f.b.close invoke"
  standardShortcuts $w
  updateSortWin
}

proc updateSortWin {} {
  global sortCriteria
  set w .sortWin
  if {! [winfo exists $w]} { return }
  set state disabled
  if {[sc_base inUse]  &&  $sortCriteria(real) != ""} { set state normal }
  $w.f.b.sort configure -state $state
}

proc sortDatabase {} {
  global sortCriteria
  set w .sortWin
  if {! [sc_base inUse]} {
    tk_messageBox -type ok -icon info -parent $w -title "Scid: Sort results" \
        -message "This is not an open database; there are no games to sort."
    return
  }
  progressWindow "Scid" "Sorting the database..."
  busyCursor .
  set err [catch {sc_base sort $sortCriteria(real) \
        {changeProgressWindow "Storing results..."} \
      } result]
  unbusyCursor .
  closeProgressWindow
  if {$err} {
    tk_messageBox -type ok -icon warning -parent $w \
        -title "Scid: Sort results" -message $result
  } else {
    tk_messageBox -type ok -icon info -parent $w \
        -title "Scid: Sort results" \
        -message "The database was successfully sorted."
  }
  updateBoard
  ::windows::gamelist::Refresh
  ::maint::Refresh
}

proc makeBaseReadOnly {} {
  set curr_base [sc_base current]
  if {! [sc_base inUse]} { return }
  if {[sc_base isReadOnly $curr_base]} { return }
  set result [tk_dialog .roDialog "Scid: [tr FileReadOnly]" \
      $::tr(ReadOnlyDialog) "" 1 $::tr(Yes) $::tr(No)]
  if {$result == 0} {
    sc_base isReadOnly $curr_base set
  }
}


# allocateRatings:
#   Allocate player ratings to games based on the spellcheck file.
#
set addRatings(overwrite) 0
set addRatings(filter) 0

proc allocateRatings {} {
  if {[catch {sc_name ratings -test 1} result]} {
    tk_messageBox -type ok -icon info -parent . -title "Scid" -message $result
    return
  }
  set w .ardialog
  toplevel $w
  wm title $w "Scid"
  ttk::label $w.lab -wraplength 3i -justify center -text $::tr(AllocRatingDescription)
  pack $w.lab -side top -expand 1 -fill x -anchor center
  addHorizontalRule $w
  pack [ttk::frame $w.r] -side top
  ttk::label $w.r.lab -text $::tr(RatingOverride)
  ttk::radiobutton $w.r.yes -variable addRatings(overwrite) \
      -value 1 -text $::tr(Yes)
  ttk::radiobutton $w.r.no -variable addRatings(overwrite) \
      -value 0 -text $::tr(No)
  pack $w.r.lab $w.r.yes $w.r.no -side left
  addHorizontalRule $w
  pack [ttk::frame $w.g] -side top -expand 1 -fill x
  ttk::label $w.g.lab -text $::tr(AddRatings)
  ttk::radiobutton $w.g.all -variable addRatings(filter) \
      -value 0 -text $::tr(SelectAllGames)
  ttk::radiobutton $w.g.filter -variable addRatings(filter) \
      -value 1 -text $::tr(SelectFilterGames)
  pack $w.g.lab $w.g.all $w.g.filter -side top
  addHorizontalRule $w
  pack [ttk::frame $w.b] -side top -fill x
  ttk::button $w.b.ok -text "OK" \
      -command "catch {grab release $w}; destroy $w; doAllocateRatings"
  ttk::button $w.b.cancel -text $::tr(Cancel) \
      -command "catch {grab release $w}; destroy $w"
  pack $w.b.cancel $w.b.ok -side right -padx 3 -pady 3
  catch {grab $w}
  focus $w.b.ok
}

proc doAllocateRatings {} {
  global addRatings
  if {[catch {sc_name ratings -test 1} result]} {
    tk_messageBox -type ok -icon info -parent . -title "Scid" -message $result
    return
  }
  progressWindow "Scid" "Adding Elo ratings..."
  busyCursor .
  if {[catch {sc_name ratings -change $addRatings(overwrite) -filter $addRatings(filter)} result]} {
    closeProgressWindow
    tk_messageBox -type ok -icon warning -parent . \
        -title "Scid" -message $result
  } else {
    closeProgressWindow
    set r [::utils::thousands [lindex $result 0]]
    set g [::utils::thousands [lindex $result 1]]
    tk_messageBox -type ok -icon info -parent . \
        -title "Scid" -message [subst $::tr(AddedRatings)]
  }
  unbusyCursor .
}


# stripTags:
#   Strip unwanted PGN tags from the current database.

array set stripTagCount {}

proc stripTags {} {
  global stripTagChoice stripTagCount
  set w .striptags
  if {[winfo exists $w]} {
    raise $w
    return
  }
  set stripTagList {}
  
  # Find extra PGN tags:
  set ::interrupt 0
  progressWindow "Scid" "Searching for extra PGN tags..." \
      $::tr(Cancel) "set ::interrupt 1; sc_progressBar"
  busyCursor .
  set err [catch {sc_base tag list} result]
  unbusyCursor .
  closeProgressWindow
  if {$::interrupt} { return }
  if {$err} {
    tk_messageBox -title "Scid" -icon warning -type ok -message $result
    return
  }
  
  # Make list of extra tags and their frequency:
  array unset stripTagCount
  set nTags 0
  foreach {tag count} $result {
    set stripTagCount($tag) $count
    incr nTags
  }
  
  if {$nTags == 0} {
    tk_messageBox -title "Scid" -icon info -type ok \
        -message "No extra tags were found."
    return
  }
  
  toplevel $w
  wm title $w "Scid: $::tr(StripTags)"
  ttk::label $w.title -text "Extra PGN tags:" -font font_Bold -anchor center
  pack $w.title -side top -fill x -anchor center
  pack [ttk::frame $w.f] -side top -fill x
  addHorizontalRule $w
  pack [ttk::frame $w.b] -side bottom -fill x
  
  set row 0
  foreach tag [lsort [array names stripTagCount]] {
    set count $stripTagCount($tag)
    ttk::radiobutton $w.f.t$tag -text "$tag  " -variable stripTagChoice -value $tag
    ttk::label $w.f.c$tag -text [::utils::thousands $count]
    if {$row == 0} { set stripTagChoice $tag }
    grid $w.f.t$tag -row $row -column 0 -sticky w
    grid $w.f.c$tag -row $row -column 1 -sticky e
    incr row
  }
  ttk::button $w.b.find -text $::tr(SetFilter) -command findStripTags
  ttk::button $w.b.strip -text $::tr(StripTag...) -command {
    set removed [doStripTags .striptags]
    set stripTagCount($stripTagChoice) \
        [expr {$stripTagCount($stripTagChoice) - $removed} ]
    .striptags.f.c$stripTagChoice configure -text \
        [::utils::thousands $stripTagCount($stripTagChoice)]
  }
  ttk::button $w.b.cancel -text $::tr(Cancel) \
      -command "catch {grab release $w}; destroy $w"
  pack $w.b.cancel $w.b.strip $w.b.find -side right -padx 2 -pady 2
  wm resizable $w 0 0
  update
  catch {grab $w}
}

proc doStripTags {{parent .}} {
  global stripTagChoice
  set msg "Do you really want to remove all occurences of the PGN tag"
  append msg " \"$stripTagChoice\" from this database?"
  set result [tk_messageBox -title "Scid" -parent $parent \
      -icon question -type yesno -message $msg]
  if {$result == "no"} { return 0 }
  progressWindow "Scid" "Removing the PGN tag $stripTagChoice..." \
      $::tr(Cancel) "sc_progressBar"
  busyCursor .
  set err [catch {sc_base tag strip $stripTagChoice} result]
  unbusyCursor .
  closeProgressWindow
  set count 0
  if {! $err} {
    set count $result
    set result "Removed $result instances of \"$stripTagChoice\"."
    append result "\n\n"
    append result "To save space and maintain database efficiency, it is a "
    append result "good idea to compact the game file after removing tags."
  }
  tk_messageBox -title "Scid" -parent $parent -type ok -icon info \
      -message $result
  return $count
}

proc findStripTags {} {
  global stripTagChoice
  progressWindow "Scid" "Finding games with the PGN tag $stripTagChoice..." \
      $::tr(Cancel) "sc_progressBar"
  busyCursor .
  set err [catch {sc_base tag find $stripTagChoice} result]
  unbusyCursor .
  closeProgressWindow
  ::windows::stats::Refresh
}


# cleanerWin:
#   Open a dialog so the user can choose several maintenance tasks
#   in one action.

set cleaner(players) 1
set cleaner(events) 1
set cleaner(sites) 1
set cleaner(rounds) 1
set cleaner(eco) 1
set cleaner(elo) 1
set cleaner(twins) 1
set cleaner(cnames) 0
set cleaner(cgames) 0
set cleaner(tree) 0

proc cleanerWin {} {
  set w .mtoolWin
  if {[winfo exists $w]} { return }
  
  toplevel $w
  wm title $w "Scid: $::tr(Cleaner)"
  bind $w <F1> {helpWindow Maintenance Cleaner}
  pack [ttk::frame $w.f]
  
  pack [ttk::frame $w.f.help] -side top -fill x
  text $w.f.help.text -width 1 -height 8 -wrap word \
      -relief ridge -cursor top_left_arrow -yscrollcommand "$w.f.help.ybar set"
  ttk::scrollbar $w.f.help.ybar -orient vertical -command "$w.f.help.text yview" \
      -takefocus 0
  pack $w.f.help.ybar -side right -fill y
  pack $w.f.help.text -side left -fill x -expand yes
  $w.f.help.text insert end [string trim $::tr(CleanerHelp)]
  $w.f.help.text configure -state disabled
  
  pack [ttk::frame $w.f.f] -side top -padx 20
  foreach i {players events sites rounds} j {Players Events Sites Rounds} {
    ttk::label $w.f.f.$i -text "$::tr(Spellchecking): $::tr($j)"
  }
  ttk::label $w.f.f.eco -text $::tr(ReclassifyGames)
  ttk::label $w.f.f.elo -text $::tr(AddEloRatings)
  ttk::label $w.f.f.twins -text $::tr(DeleteTwins)
  ttk::label $w.f.f.cnames -text $::tr(CompactNames)
  ttk::label $w.f.f.cgames -text $::tr(CompactGames)
  ttk::label $w.f.f.tree -text [tr TreeFileFill]
  
  foreach i {players events sites rounds eco elo twins cnames cgames tree} {
    ttk::radiobutton $w.f.f.y$i -variable cleaner($i) -value 1 -text $::tr(Yes)
    ttk::radiobutton $w.f.f.n$i -variable cleaner($i) -value 0 -text $::tr(No)
  }
  set row 0
  foreach i {players events sites rounds eco elo twins cnames cgames tree} {
    grid $w.f.f.$i -row $row -column 0 -sticky w
    grid $w.f.f.y$i -row $row -column 1 -sticky w
    grid $w.f.f.n$i -row $row -column 2 -sticky w
    incr row
  }
  
  addHorizontalRule $w.f
  pack [ttk::frame $w.f.b] -side bottom -fill x
  ttk::button $w.f.b.ok -text "OK" -command "catch {grab release $w}; destroy $w; doCleaner"
  ttk::button $w.f.b.cancel -text $::tr(Cancel) -command "catch {grab release $w}; destroy $w"
  pack $w.f.b.cancel $w.f.b.ok -side right -padx 2 -pady 2
  wm resizable $w 0 0
  # Remove the scrollbar if it is not needed:
  update
  set yview [$w.f.help.text yview]
  if {[lindex $yview 0] <= 0.01  &&  [lindex $yview 1] >= 0.99} {
    pack forget $w.f.help.ybar
  }
  catch {grab $w}
}

# Maximum nr of corrections to be scanned
# Set to zero to find them all
# Set to some positive number to limit
#
set cleaner_maxSpellCorrections 0


proc doCleaner {} {
  global cleaner twinSettings
  global cleaner_maxSpellCorrections
  
  set answer [tk_dialog .mtoolDialog "Scid" \
      [string trim $::tr(CleanerConfirm)] "" \
      0 $::tr(Yes) $::tr(No)]
  if {$answer != 0} { return }
  
  set w .mtoolStatus
  if {! [winfo exists $w]} {
    toplevel $w
    wm title $w "Scid: $::tr(Cleaner)"
    pack [ttk::frame $w.f]
    pack [ttk::frame $w.f.b] -side bottom -fill x -expand yes
    pack [ttk::frame $w.f.t] -side top -fill both -expand yes
    text $w.f.t.text -width 60 -height 10 -wrap none -setgrid 1 \
        -cursor top_left_arrow -yscrollcommand "$w.f.t.ybar set"
    ttk::scrollbar $w.f.t.ybar -orient vertical -command "$w.f.t.text yview" -takefocus 0
    pack $w.f.t.ybar -side right -fill y
    pack $w.f.t.text -side left -fill both -expand yes
    ttk::button $w.f.b.close -text $::tr(Close) -command "catch {grab release $w}; destroy $w"
    pack $w.f.b.close -side right -padx 2 -pady 2
    wm minsize $w 20 5
  }
  
  busyCursor .
  catch {grab $w}
  set t $w.f.t.text
  $t delete 1.0 end
  $t insert end "$::tr(Cleaner)."
  $t insert end "  $::tr(Database): [file tail [sc_base filename]]\n"
  
  $w.f.b.close configure -state disabled
  
  set count 1
  
  foreach nameType {Player Event Site Round} {
    set names $nameType
    append names "s"
    set tag [string tolower $names]
    if {$cleaner($tag)} {
      mtoolAdd $t "$count: $::tr(Spellchecking): $::tr($names)..."
      incr count
      set result "0 $nameType names were corrected."
      if {! [catch {sc_name spellcheck -max $cleaner_maxSpellCorrections $nameType} corrections]} {
        update
        catch {sc_name correct $nameType $corrections} result
      }
      $t insert end "   $result\n"
      $t see end
    }
  }
  
  if {$cleaner(eco)} {
    mtoolAdd $t "$count: $::tr(ReclassifyGames)..."
    incr count
    catch {sc_eco base $::classifyOption(AllGames) \
          $::classifyOption(ExtendedCodes)} result
    $t insert end "   $result\n"
    $t see end
  }
  
  if {$cleaner(elo)} {
    mtoolAdd $t "$count: $::tr(AddEloRatings)..."
    incr count
    if {[catch {sc_name ratings} result]} {
      $t insert end "   $result\n"
    } else {
      set r [::utils::thousands [lindex $result 0]]
      set g [::utils::thousands [lindex $result 1]]
      $t insert end "   Scid added $r Elo ratings in $g games.\n"
    }
  }
  
  if {$cleaner(twins)} {
    mtoolAdd $t "$count: $::tr(DeleteTwins)..."
    incr count
    if {$twinSettings(undelete) == "Yes"} {
      sc_base gameflag [sc_base current] all unset del
    }
    if {[catch {sc_base duplicates -colors $twinSettings(colors) \
            -event $twinSettings(event) -site $twinSettings(site) \
            -round $twinSettings(round) -year $twinSettings(year) \
            -month $twinSettings(month) -day $twinSettings(day) \
            -result $twinSettings(result) -eco $twinSettings(eco) \
            -moves $twinSettings(moves) -players $twinSettings(players) \
            -setfilter $twinSettings(setfilter) \
            -usefilter $twinSettings(usefilter) \
            -comments $twinSettings(comments) \
            -variations $twinSettings(variations) \
            -delete $twinSettings(delete)} result]} {
      set message $result
    } else {
      set message "Scid found $result twin games"
      if {$result > 0} {append message " and set their delete flags"}
    }
    $t insert end "   $message.\n"
  }
  
  if {$cleaner(cnames)} {
    mtoolAdd $t "$count: $::tr(CompactNames)..."
    incr count
    set stats [sc_compact stats names]
    if {[lindex $stats 1] == 0  &&  [lindex $stats 3] == 0  && \
          [lindex $stats 5] == 0  &&  [lindex $stats 7] == 0} {
      $t insert end "   Name file already compacted.\n"
    } else {
      set err [catch {sc_compact names} result]
      if {$err} {
        $t insert end "   $result\n"
      } else {
        $t insert end "   Done.\n"
      }
    }
    $t see end
  }
  
  if {$cleaner(cgames)} {
    mtoolAdd $t "$count: $::tr(CompactGames)..."
    incr count
    set stats [sc_compact stats games]
    if {[lindex $stats 1] == [lindex $stats 3]  && \
          [lindex $stats 0] == [lindex $stats 2]} {
      $t insert end "   Game file already compacted.\n"
    } else {
      set err [catch {sc_compact games} result]
      if {$err} {
        $t insert end "   $result\n"
      } else {
        $t insert end "   Done.\n"
      }
    }
    $t see end
  }
  
  if {$cleaner(tree)} {
    mtoolAdd $t "$count: [tr TreeFileFill]..."
    incr count
    sc_game push
    set base [sc_base current]
    set len [llength $::tree(standardLines)]
    foreach line $::tree(standardLines) {
      sc_game new
      if {[llength $line] > 0}  {
        foreach move $line {sc_move addSan $move}
      }
      sc_tree search -base $base
      update
    }
    catch {sc_tree write $base} result
    sc_game pop
    $t insert end "   Done.\n"
  }
  
  mtoolAdd $t "Done."
  updateBoard
  ::windows::gamelist::Refresh
  ::maint::Refresh
  $w.f.b.close configure -state normal
  catch {grab release $w}
  unbusyCursor .
}

proc mtoolAdd {tw title} {
  set time [clock format [clock seconds] -format "%H:%M:%S"]
  $tw insert end "\n\[$time\]\n"
  if {$title != ""} { $tw insert end "$title\n" }
  $tw see end
  update
}

