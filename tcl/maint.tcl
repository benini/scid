# maint.tcl:   Maintenance-related functions
# Part of Scid.
# Copyright (C) 2000 Shane Hudson.


# setGameFlags:
#   Updates a flag for the current game, all filtered games, or all games.
#   <type> should be "current", "filter" or "all".
#   <flag> should be "delete", "user", "endgame", etc.
#   <value> should be 0 or 1
#
proc setGameFlags {flag type value} {
  if {$flag == "mark"} { set flag $::maintFlag }
  switch -- $type {
    "current" {
      busyCursor .
      catch {sc_game flag $flag [sc_game number] $value}
      unbusyCursor .
    }
    "filter" -
    "all" {
      busyCursor .
      catch {sc_game flag $flag $type $value}
      unbusyCursor .
    }
    default { return }
  }
  updateBoard .board
  updateGList
  updateMaintWin
  updateStatsWin
}

set maintFlag W
set maintFlaglist {W B M E N P T Q K ! ? U}
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
}

# makeMaintWin:
#   Creates the database maintenance window.
#
set maintWin 0
proc makeMaintWin {} {
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
    frame $w.$f
  }
  foreach f {title delete mark spell db} {
    pack $w.$f -side top -fill x
    addHorizontalRule $w
  }
  pack $w.buttons -side top -fill x

  label $w.title.name -textvar ::tr(DatabaseName) -font font_Bold
  label $w.title.games -textvar ::tr(NumOfGames) -font font_SmallBold
  label $w.title.icon -textvar ::tr(TypeIcon)
  label $w.title.delete -textvar ::tr(NumDeletedGames) -font $font
  label $w.title.mark -font $font
  label $w.title.filter -textvar ::tr(NumFilterGames) -font $font
  label $w.title.dates -textvar ::tr(YearRange) -font $font
  label $w.title.ratings -textvar ::tr(RatingRange) -font $font
  button $w.title.vicon -command {changeBaseType [sc_base current]}

  foreach name {name games delete mark filter dates ratings} {
    label $w.title.v$name -text "0" -font $font
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
  grid [label $w.title.space -text "   "] -row 0 -column 2
  $w.title.vname configure -font font_Bold
  $w.title.vgames configure -font font_SmallBold

  foreach grid {title delete mark spell db} cols {5 3 3 4 3} {
    for {set i 0} {$i < $cols} {incr i} {
      grid columnconfigure $w.$grid $i -weight 1
    }
  }

  label $w.delete.title -textvar ::tr(DeleteFlag) -font $bold
  menubutton $w.mark.title -menu $w.mark.title.m \
    -indicatoron 1 -relief raised -font $bold
  menu $w.mark.title.m -font $font
  foreach i $maintFlaglist  {
    $w.mark.title.m add command -label "$::tr($maintFlags($i)) ($i)" \
      -command "set maintFlag $i; updateMaintWin"
  }
  foreach flag {delete mark} on {Delete Mark} off {Undelete Unmark} {
    foreach b {Current Filter All} {
      button $w.$flag.on$b -textvar "::tr($on$b)" -font $font \
        -command "setGameFlags $flag [string tolower $b] 1"
      button $w.$flag.off$b -textvar "::tr($off$b)" -font $font \
        -command "setGameFlags $flag [string tolower $b] 0"
    }

    grid $w.$flag.title -columnspan 3 -row 0 -column 0 -sticky n
    grid $w.$flag.onCurrent -row 1 -column 0 -sticky we
    grid $w.$flag.offCurrent -row 2 -column 0 -sticky we
    grid $w.$flag.onFilter -row 1 -column 1 -sticky we
    grid $w.$flag.offFilter -row 2 -column 1 -sticky we
    grid $w.$flag.onAll -row 1 -column 2 -sticky we
    grid $w.$flag.offAll -row 2 -column 2 -sticky we
  }

  label $w.spell.title -textvar ::tr(Spellchecking) -font $bold
  grid $w.spell.title -columnspan 4 -row 0 -column 0 -sticky n
  button $w.spell.player -textvar ::tr(Players...) -font $font \
    -command "openSpellCheckWin Player $w"
  button $w.spell.event -textvar ::tr(Events...) -font $font \
    -command "openSpellCheckWin Event $w"
  button $w.spell.site -textvar ::tr(Sites...) -font $font \
    -command "openSpellCheckWin Site $w"
  button $w.spell.round -textvar ::tr(Rounds...) -font $font \
    -command "openSpellCheckWin Round $w"
  grid $w.spell.player -row 1 -column 0 -sticky we
  grid $w.spell.event -row 1 -column 1 -sticky we
  grid $w.spell.site -row 1 -column 2 -sticky we
  grid $w.spell.round -row 1 -column 3 -sticky we

  bind $w <Alt-p> "$w.spell.player invoke"
  bind $w <Alt-e> "$w.spell.event invoke"
  bind $w <Alt-s> "$w.spell.site invoke"
  bind $w <Alt-r> "$w.spell.round invoke"

  label $w.db.title -textvar ::tr(DatabaseOps) -font $bold
  grid $w.db.title -columnspan 3 -row 0 -column 0 -sticky n

  button $w.db.eco -textvar ::tr(ReclassifyGames...) -command classifyAllGames
  button $w.db.compact -textvar ::tr(CompactDatabase...) -command makeCompactWin
  button $w.db.sort -textvar ::tr(SortDatabase...) -command makeSortWin
  button $w.db.elo -textvar ::tr(AddEloRatings...) -command allocateRatings
  button $w.db.dups -textvar ::tr(DeleteTwins...) -command "markTwins $w"
  button $w.db.cleaner -textvar ::tr(Cleaner...) -command cleanerWin
  button $w.db.autoload -textvar ::tr(AutoloadGame...) -command setAutoloadGame
  button $w.db.strip -textvar ::tr(StripTags...) -command stripTags

  foreach i {eco compact sort elo dups cleaner autoload strip} {
    $w.db.$i configure -font $font
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

  button $w.buttons.help -textvar ::tr(Help) -command {helpWindow Maintenance}
  button $w.buttons.close -textvar ::tr(Close) -command "destroy $w"
  pack $w.buttons.close $w.buttons.help -side right -padx 2 -pady 2
  bind $w <Alt-h> "$w.buttons.help invoke"
  bind $w <Alt-c> "destroy $w; break"
  standardShortcuts $w
  updateMaintWin
}

proc updateMaintWin {} {
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
  $w.title.vgames configure -text [thousands $ng]
  $w.title.vicon configure -image dbt[sc_base type [sc_base current]]
  $w.title.vname configure -text [file tail [sc_base filename]]
  $w.title.vdelete configure -text [percentFormat $deleted $ng]
  $w.title.vmark configure -text [percentFormat $marked $ng]
  $w.title.vfilter configure -text [percentFormat [sc_filter count] $ng]
  $w.title.vdates configure \
    -text "[lindex $dates 0]-[lindex $dates 1] ([lindex $dates 2])"
  $w.title.vratings configure \
    -text "[lindex $ratings 0]-[lindex $ratings 1] ([lindex $ratings 2])"

  set flagname "$::tr(Flag): $::tr($maintFlags($maintFlag)) ($maintFlag)"
  $w.mark.title configure -text $flagname
  $w.title.mark configure -text $flagname

  # Disable buttons if current base is closed or read-only:
  set state disabled
  if {[sc_base inUse]  &&  ![sc_base isReadOnly]} {
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

# setAutoloadNumber:
#   Creates a dialog for setting the autoload game number of the
#   current database.
#
set autoloadGame 0
trace variable autoloadGame w {forceInt 9999999 0}
proc setAutoloadGame {} {
  global autoloadGame
  set w .autoload
  if {[winfo exists $w]} { return }
  toplevel $w
  wm title $w "Scid"
  set autoloadGame [sc_base autoload]

  pack [frame $w.f] -side top
  label $w.f.label -text $::tr(AutoloadGame:)
  entry $w.f.entry -textvar autoloadGame -justify right -width 10 \
    -foreground black -background white
  pack $w.f.label $w.f.entry -side left

  pack [frame $w.set] -side top -fill x
  button $w.set.none -text $::tr(None) -command {set autoloadGame 0}
  button $w.set.first -text $::tr(First) -command {set autoloadGame 1}
  button $w.set.current -text $::tr(Current) \
    -command {set autoloadGame [sc_game number]}
  button $w.set.last -text $::tr(Last) -command {set autoloadGame 9999999}
  foreach i {none first current last} {$w.set.$i configure -font font_Small}
  pack $w.set.none $w.set.first $w.set.current $w.set.last \
    -side left -padx 1 -pady 2

  addHorizontalRule $w

  pack [frame $w.b] -side top -fill x
  button $w.b.ok -text OK -command \
    "sc_base autoload \$autoloadGame; catch {grab release $w}; destroy $w"
  button $w.b.cancel -text $::tr(Cancel) -command \
    "catch {grab release $w}; destroy $w"
  pack $w.b.cancel $w.b.ok -side right -padx 2

  bind $w.f.entry <Return> "$w.b.ok invoke"
  bind $w.f.entry <Escape> "$w.b.cancel invoke"
  wm resizable $w 0 0
  centreWin $w
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
    tk_messageBox -type ok -icon info -title "Scid: No games" \
      -message "There are no games in this database to delete."
    return
  }

  set w .twinSettings
  if {! [winfo exists $w]} {
    toplevel $w
    wm resizable $w 0 0
    wm title $w "Scid: $::tr(DeleteTwins)"
    set small font_Small
    label $w.note -text $::tr(TwinsNote) -justify left \
      -wraplength 500 -font $small
    pack $w.note -side top -anchor w -ipady 0 -pady 0
    addHorizontalRule $w
    label $w.tc -text $::tr(TwinsCriteria) -font font_Bold
    pack $w.tc -side top

    frame $w.g
    pack $w.g -side top
    set row 0
    set col 0
    foreach name {Colors Event Site Round Year Month Day Result ECO Moves} {
      set n [string tolower $name]
      label $w.g.l$n -text $::tr(Twins$name) -font $small
      radiobutton $w.g.yes$n -variable twinSettings($n) -value Yes \
        -text $::tr(Yes) -font $small
      radiobutton $w.g.no$n -variable twinSettings($n) -value No \
        -text $::tr(No) -font $small
      grid $w.g.l$n -row $row -column $col -sticky w
      incr col
      grid $w.g.yes$n -row $row -column $col -sticky w
      incr col
      grid $w.g.no$n -row $row -column $col -sticky w
      incr col
      if {$col >= 5} {
        incr row; set col 0
      } else {
        grid [label $w.g.space$n -text "   "] -row $row -column $col
        incr col
      }
    }
    label $w.g.lPlayers -text $::tr(TwinsPlayers) -font $small
    radiobutton $w.g.yesPlayers -variable twinSettings(players) -value Yes \
      -text $::tr(TwinsPlayersExact) -font $small
    radiobutton $w.g.noPlayers -variable twinSettings(players) -value No \
      -text $::tr(TwinsPlayersPrefix) -font $small
    grid $w.g.lPlayers -row $row -column 0 -sticky w
    grid $w.g.yesPlayers -row $row -column 1 -columnspan 3 -sticky w
    grid $w.g.noPlayers  -row $row -column 4 -columnspan 3 -sticky w
  }
    

  addHorizontalRule $w
  label $w.twhich -text $::tr(TwinsWhich:) -font font_Bold
  pack $w.twhich -side top
  pack [frame $w.g2] -side top -fill x
  radiobutton $w.g2.exall -text $::tr(SelectAllGames) -font $small \
    -variable twinSettings(usefilter) -value No
  label $w.g2.space -text "    " -font $small
  radiobutton $w.g2.exfil -text $::tr(SelectFilterGames) -font $small \
    -variable twinSettings(usefilter) -value Yes
  grid $w.g2.exall -row 0 -column 0 -sticky e
  grid $w.g2.space -row 0 -column 1
  grid $w.g2.exfil -row 0 -column 2 -sticky w
  grid columnconfigure $w.g2 0 -weight 1
  grid columnconfigure $w.g2 2 -weight 1

  addHorizontalRule $w
  label $w.twhen -text $::tr(TwinsWhen:) -font font_Bold
  pack $w.twhen -side top
  pack [frame $w.g3] -side top
  set row 0
  foreach n {skipshort undelete setfilter comments variations} {
    label $w.g3.l$n -text "" -font $small
    checkbutton $w.g3.v$n -width 6 -variable twinSettings($n) -font $small \
      -textvariable twinSettings($n) -onvalue Yes -offvalue No -anchor w
      grid $w.g3.l$n -row $row -column 0 -sticky w
      grid $w.g3.v$n -row $row -column 1 -sticky w
      incr row
  }
  $w.g3.lskipshort configure -text $::tr(TwinsSkipShort)
  $w.g3.lundelete configure -text $::tr(TwinsUndelete)
  $w.g3.lsetfilter configure -text $::tr(TwinsSetFilter)
  $w.g3.lcomments configure -text $::tr(TwinsComments)
  $w.g3.lvariations configure -text $::tr(TwinsVars)
  label $w.g3.ldelete -text $::tr(TwinsDeleteWhich)  -font $small
  grid $w.g3.ldelete -row $row -column 0 -sticky we -columnspan 2
  incr row
  frame $w.g3.vdelete
  foreach v {Shorter Older Newer} {
    radiobutton $w.g3.vdelete.v$v -text $::tr(TwinsDelete$v) \
      -variable twinSettings(delete) -value $v -font $small
    pack $w.g3.vdelete.v$v -side left -padx 5
  }
  grid $w.g3.vdelete -row $row -column 0 -columnspan 2

  foreach g {g g2 g3} {
    grid columnconfigure $w.$g 0 -weight 1
  }

  addHorizontalRule $w
  frame $w.b
  button $w.b.defaults -textvar ::tr(Defaults) -command {
    array set twinSettings [array get twinSettingsDefaults]
  }
  button $w.b.help -text $::tr(Help) \
    -command "helpWindow Maintenance Twins; focus $w"
  button $w.b.go -text $::tr(TwinsDelete) -command {
    if {[twinCriteriaOK .twinSettings]} {
      grab release .twinSettings
      sc_progressBar .twinSettings.progress bar 301 21 time
      set result [doMarkDups .twinSettings]
      focus .
      destroy .twinSettings
      if {$result > 0} { updateTwinChecker }
    }
  }

  button $w.b.cancel -text $::tr(Cancel) \
    -command "grab release $w; focus .; destroy $w"
  canvas $w.progress -width 300 -height 20 -bg white -relief solid -border 1
  $w.progress create rectangle 0 0 0 0 -fill blue -outline blue -tags bar
  $w.progress create text 295 10 -anchor e -font font_Regular -tags time \
    -fill black -text "0:00 / 0:00"

  pack $w.progress -side bottom -padx 2 -pady 2
  pack $w.b -side bottom -fill x
  pack $w.b.cancel $w.b.go -side right -padx 10 -pady 2
  pack $w.b.help -side left -padx 10 -pady 2
  bind $w <F1> "$w.b.help invoke"
  bind $w <Escape> "$w.b.cancel invoke"
  bind $w <Return> "$w.b.go invoke"
  grab $w
  update idletasks
  $w.note configure -wraplength [winfo width $w]
  return
}

# twinCriteriaOK:
#   Check that the user specified at least three of the the same site,
#   same round, and same year settings, since otherwise it is quite
#   likely that actual games with simlar moves will be marked as twins:
#
proc twinCriteriaOK {{parent .}} {
  global twinSettings

  set msg "Your settings for finding twin games are potentially likely to "
  append msg "cause non-twin games with similar moves to be marked as twins."
  append msg "\n\n"

  # First, check that if same moves is off, then the same colors, event,
  # site, round, year and month flags should all be set:
  if {$twinSettings(moves) == "No"} {
    if {$twinSettings(colors) == "No"  ||  $twinSettings(event) == "No"  || \
        $twinSettings(site) == "No"  ||  $twinSettings(year) == "No"  || \
        $twinSettings(month) == "No"} {
      append msg "It is recommended that if you select \"No\" for \"same moves\","
      append msg "you should select \"Yes\" for the colors, event, site, round,"
      append msg "year and month settings."
      append msg "\n\n"
      append msg "Do you want to continue and delete twins anyway?"
      set result [tk_messageBox -type yesno -parent $parent -icon warning \
                    -title "Scid: Confirm twin settings" \
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
    append msg "It is recommended that you specify \"Yes\" for at least two "
    append msg "of the \"same site\", \"same round\" and \"same year\" "
    append msg "settings."
    append msg "\n\n"
    append msg "Do you want to continue and delete twins anyway?"
    set result [tk_messageBox -type yesno -parent $parent -icon warning \
                  -title "Scid: Confirm twin settings" \
                  -message $msg]
    if {$result == "no"} { return 0 } else { return 1 }
  }
  return 1
}


proc doMarkDups {{parent .}} {
  global twinSettings

  busyCursor .
  if {$twinSettings(undelete) == "Yes"} {
    catch {sc_game flag delete all 0}
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
    set message "Scid found $result twin games"
    if {$result > 0} {append message " and set their delete flags"}
    append message "."
    tk_messageBox -type ok -parent $parent -icon info -title "Scid: Result" \
      -message $message
  }
  updateMaintWin
  return $result
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
  label $w.label -font font_Bold -textvar ::tr(ClassifyWhich)
  radiobutton $w.all -textvar ::tr(ClassifyAll) \
    -variable classifyOption(AllGames) -value all
  radiobutton $w.filter -textvar ::tr(SelectFilterGames) \
    -variable classifyOption(AllGames) -value filter
  set year [::date::today year]
  set month [::date::today month]
  set day [::date::today day]
  radiobutton $w.year -textvar ::tr(ClassifyYear) \
    -variable classifyOption(AllGames) \
    -value "date:[expr $year - 1].$month.$day"
  if {$month == "01"} {
    incr year -1
    set month 12
  } else {
    scan $month "%02u" month
    incr month -1
    set month [format "%02u" $month]
  }
  radiobutton $w.month -textvar ::tr(ClassifyMonth) \
    -variable classifyOption(AllGames) \
    -value "date:$year.$month.$day"
  radiobutton $w.new -textvar ::tr(ClassifyNew) \
    -variable classifyOption(AllGames) -value nocode
  label $w.codes -font font_Bold -textvar ::tr(ClassifyCodes:)
  radiobutton $w.extended -textvar ::tr(ClassifyBasic) \
    -variable classifyOption(ExtendedCodes) -value 0
  radiobutton $w.basic -textvar ::tr(ClassifyExtended) \
    -variable classifyOption(ExtendedCodes) -value 1

  frame $w.b
  button $w.b.go -textvar ::tr(Classify) -command {
    busyCursor .
    .classify.b.cancel configure -command "sc_progressBar"
    .classify.b.cancel configure -textvar ::tr(Stop)
    sc_progressBar .classify.progress bar 301 21 time
    grab .classify.b.cancel
    if {[catch  {sc_eco base $classifyOption(AllGames) $classifyOption(ExtendedCodes)} result]} {
      grab release .classify.b.cancel
      unbusyCursor .
      tk_messageBox -parent .classify -type ok -icon info -title "Scid" -message $result
    } else {
      grab release .classify.b.cancel
      unbusyCursor .
    }
    .classify.b.cancel configure -command {focus .; destroy .classify}
    .classify.b.cancel configure -textvar ::tr(Close)
    updateGList
  }
  button $w.b.cancel -textvar ::tr(Close) -command "focus .; destroy $w"
  canvas $w.progress -width 300 -height 20 -bg white -relief solid -border 1
  $w.progress create rectangle 0 0 0 0 -fill blue -outline blue -tags bar
  $w.progress create text 295 10 -anchor e -font font_Regular -tags time \
    -fill black -text "0:00 / 0:00"

  pack $w.label $w.all $w.filter $w.year $w.month $w.new -side top -pady 5
  addHorizontalRule $w
  pack $w.codes $w.extended $w.basic -side top -pady 5
  addHorizontalRule $w
  pack $w.b -side top -pady 5 -fill x
  pack $w.progress -side bottom -padx 2 -pady 2
  pack $w.b.cancel $w.b.go -side right -pady 10 -padx 10
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
  $w.b.go configure -state $state
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
    pack [frame $w.b] -side bottom -fill x
    pack [frame $w.f] -side top -fill both -expand yes
    frame $w.f.left
    pack $w.f.left -side left -fill y -expand yes
    frame $w.f.split -width 2 -borderwidth 2 -relief sunken
    pack $w.f.split -side left -fill y -padx 5
    frame $w.f.right
    pack $w.f.right -side left -fill y -expand yes
    foreach i {left right} {
      set f $w.f.$i
      pack [frame $f.title] -side top -fill x
      label $f.title.label -font font_Bold -text "Game 0: "
      checkbutton $f.title.d -text "Deleted" -pady 5 \
        -variable twincheck($i) -font font_Small
      label $f.title.note -font font_Small
      pack $f.title.label $f.title.d $f.title.note -side left
      label $f.tmt -font font_Small -text "" -anchor w -width 1
      pack $f.tmt -side bottom -fill x
      frame $f.t
      pack $f.t -side top -fill both -expand yes
      text $f.t.text -height 16 -width 40 -background white \
        -yscroll "$f.t.ybar set" -takefocus 0 -wrap word
      $f.t.text tag configure h -background lightSteelBlue
      scrollbar $f.t.ybar -command "$f.t.text yview"
      pack $f.t.ybar -side right -fill y
      pack $f.t.text -fill both -expand yes
    }
    $w.f.left.title.note configure -text {("1" to flip; "u" undeletes both)}
    $w.f.right.title.note configure -text {("2" to flip; "u" undeletes both)}
    button $w.b.prev -text "Previous pair" -underline 0 \
      -command {gameLoadNextPrev previous}
    button $w.b.next -text "Next pair" -underline 0 \
      -command {gameLoadNextPrev next}
    button $w.b.share -text "Share tags..." -underline 0
    button $w.b.delete -text "Delete twin games..." -underline 0 \
      -command "markTwins $w"
    button $w.b.help -text "Help" -command {helpWindow Maintenance Twins}
    button $w.b.close -text "Close" -command "focus .; destroy $w"
    pack $w.b.close $w.b.help $w.b.delete -side right -padx 5 -pady 2
    pack $w.b.prev $w.b.next $w.b.share -side left -padx 5 -pady 2
    bind $w <F1> "$w.b.help invoke"
    bind $w <Escape> "focus .; destroy $w"
    bind $w <Alt-p> {gameLoadNextPrev previous}
    bind $w <KeyPress-p> {gameLoadNextPrev previous}
    bind $w <Alt-n> {gameLoadNextPrev next}
    bind $w <KeyPress-n> {gameLoadNextPrev next}
    bind $w <Alt-d> "markTwins $w"
    bind $w <KeyPress-d> "markTwins $w"
    bind $w <KeyPress-1> "$w.f.left.title.d invoke"
    bind $w <KeyPress-2> "$w.f.right.title.d invoke"
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
    wm title $w "Scid: Twin game checker"
  }

  set gn [sc_game number]
  set dup 0
  if {$gn > 0} {
    set dup [sc_game info duplicate]
  }
  set twincheck(left) 0
  set twincheck(right) 0

  $w.f.left.title.label configure -text "Game $gn:  "

  if {$gn > 0} {
    set twincheck(left) [sc_game flag delete $gn]
    $w.f.left.title.d configure -command "sc_game flag delete $gn invert; updateBoard"
    $w.f.left.title.d configure -state normal
    set tmt [sc_game crosstable count +deleted]
    $w.f.left.tmt configure -text "Games in tournament: $tmt"
  } else {
    $w.f.left.title.d configure -state disabled
    $w.f.left.tmt configure -text ""
  }
  if {$dup > 0} {
    set twincheck(right) [sc_game flag delete $dup]
    $w.f.right.title.label configure -text "Game $dup:  "
    $w.f.right.title.d configure -command "sc_game flag delete $dup invert; updateBoard"
    $w.f.right.title.d configure -state normal
    set tmt [sc_game crosstable count -game $dup +deleted]
    $w.f.right.tmt configure -text "Games in tournament: $tmt"
  } else {
    $w.f.right.title.label configure -text "No twin  "
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
    $t insert end "No twin was detected for this game.\n\n"
    $t insert end "To show twins using this window, you must first "
    $t insert end "use the \"Delete twin games...\" function."
  }

  # Now color the differences if appropriate:
  if {$dup > 0} {
    set rlen [$w.f.right.t.text index end-1c]
    set llen [$w.f.right.t.text index end-1c]

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

  set msg "Change the following game tags:\n\n"
  foreach {gn tag old new} $sharelist {
    append msg "Game $gn: $tag: \"$old\" -> \"$new\"\n"
  }
  set answer [tk_messageBox -parent $parent -title "Scid" \
                -type okcancel -default ok -icon question -message $msg]
  if {$answer != "ok"} { return }
  sc_game tags share update $g1 $g2
  sc_game tags reload
  updateBoardAndPgn
  updateGList
}

# baseIsCompactable:
#   Returns true only if the current base is compactable.
#
proc baseIsCompactable {} {
  # Only a database that is in use, not read-only, and not the
  # clipbase, can be compacted:
  if {! [sc_base inUse]} { return 0 }
  if {[sc_base isReadOnly]} { return 0 }
  if {[sc_base current] == [sc_info clipbase]} { return 0 }
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
  foreach f {top names games buttons} { frame $w.$f }
  pack $w.top -side top -fill x -padx 5
  pack $w.names -in $w.top -side left -fill x -anchor n
  addVerticalRule $w.top 12
  pack $w.games -in $w.top -side left -fill x -anchor n
  addHorizontalRule $w
  pack $w.buttons -side top -fill x

  for {set i 0} {$i < 3} {incr i} {
    grid columnconfigure $w.names $i -weight 1
    grid columnconfigure $w.games $i -weight 1
  }
  label $w.names.title -text $::tr(NameFile) -font font_Bold
  grid $w.names.title -columnspan 3 -row 0 -column 0 -sticky n
  label $w.names.nt -text "  $::tr(Names)"
  grid $w.names.nt -row 1 -column 1 -sticky e
  label $w.names.ut -text "  $::tr(Unused)"
  grid $w.names.ut -row 1 -column 2 -sticky e
  frame $w.names.h -height 1 -relief solid -bg black
  grid $w.names.h -columnspan 3 -row 2 -column 0 -sticky we
  set row 3
  set ndata [sc_compact stats names]
  set idx 0
  foreach n {p e s r} name {Players Events Sites Rounds} {
    label $w.names.t$n -text "$::tr($name)  "
    label $w.names.n$n -text "  [thousands [lindex $ndata $idx]]"
    incr idx
    label $w.names.u$n -text "  [thousands [lindex $ndata $idx]]"
    incr idx
    grid $w.names.t$n -row $row -column 0 -sticky w
    grid $w.names.n$n -row $row -column 1 -sticky e
    grid $w.names.u$n -row $row -column 2 -sticky e
    incr row
  }

  label $w.games.title -text $::tr(GameFile) -font font_Bold
  grid $w.games.title -columnspan 3 -row 0 -column 0 -sticky n
  label $w.games.gt -text "  [capital $::tr(games)]"
  grid $w.games.gt -row 1 -column 1 -sticky e
  label $w.games.st -text "  $::tr(SizeKb)"
  grid $w.games.st -row 1 -column 2 -sticky e
  frame $w.games.h -height 1 -relief solid -bg black
  grid $w.games.h -columnspan 3 -row 2 -column 0 -sticky we
  set row 3
  set ndata [sc_compact stats games]
  set idx 0
  foreach g {current compact} name {CurrentState AfterCompaction} {
    label $w.games.t$g -text "$::tr($name)  "
    label $w.games.g$g -text "  [thousands [lindex $ndata $idx]]"
    incr idx
    set kbytes [expr int(([lindex $ndata $idx] + 512) / 1024)]
    label $w.games.s$g -text "  [thousands $kbytes]"
    incr idx
    grid $w.games.t$g -row $row -column 0 -sticky w
    grid $w.games.g$g -row $row -column 1 -sticky e
    grid $w.games.s$g -row $row -column 2 -sticky e
    incr row
  }

  button $w.buttons.n -text $::tr(CompactNames) -command compactNames
  button $w.buttons.g -text $::tr(CompactGames) -command compactGames
  button $w.buttons.help -text $::tr(Help) -command {helpWindow Compact}
  button $w.buttons.cancel -text $::tr(Cancel) \
    -command "focus .; grab release $w; destroy $w"
  pack $w.buttons.cancel $w.buttons.help -side right -padx 5 -pady 2
  pack $w.buttons.n $w.buttons.g -side left -padx 5 -pady 2
  grab $w
}

proc compactNames {} {
  set w .compactWin
  set stats [sc_compact stats names]
  if {[lindex $stats 1] == 0  &&  [lindex $stats 3] == 0  && \
        [lindex $stats 5] == 0  &&  [lindex $stats 7] == 0} {
    tk_messageBox -type ok -icon info -parent $w -title "Scid: compaction" \
      -message "There are no unused names, so the name file is already fully compacted."
    return
  }
  progressWindow "Scid" "Compacting the name file..."
  busyCursor .
  set err [catch {sc_compact names} result]
  unbusyCursor .
  closeProgressWindow
  set w .compactWin
  if {$err} {
    tk_messageBox -type ok -icon warning -parent $w \
      -title "Scid: Error compacting file" -message $result
  } else {
    tk_messageBox -type ok -icon info -parent $w \
      -title "Scid: Name file compacted" \
      -message "The name file for the database \"[file tail [sc_base filename]]\" was compacted."
  }
  grab release $w
  destroy $w
  updateBoard .board
  updateGList
  updateMaintWin
}

proc compactGames {} {
  set w .compactWin
  set stats [sc_compact stats games]
  if {[lindex $stats 1] == [lindex $stats 3]  && \
        [lindex $stats 0] == [lindex $stats 2]} {
    tk_messageBox -type ok -icon info -parent $w -title "Scid: compaction" \
      -message "The game file is already fully compacted."
    return
  }
  progressWindow "Scid" "Compacting the game file..." \
    $::tr(Cancel) "sc_progressBar"
  busyCursor .
  set err [catch {sc_compact games} result]
  unbusyCursor .
  closeProgressWindow
  if {$err} {
    tk_messageBox -type ok -icon warning -parent $w \
      -title "Scid: Error compacting file" -message $result
  } else {
    tk_messageBox -type ok -icon info -parent $w \
      -title "Scid: Game file compacted" \
      -message "The game file for the database \"[file tail [sc_base filename]]\" was compacted."
  }
  grab release $w
  destroy $w
  updateBoard .board
  updateGList
  updateMaintWin
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

  label $w.torder -textvar ::tr(SortCriteria:) -font font_Bold
  pack $w.torder -side top
  label $w.order -textvar sortCriteria(translated) -width 40 -bg white \
    -relief solid -anchor w
  pack $w.order -side top -fill x -pady 2 -padx 2
  addHorizontalRule $w
  label $w.tadd -textvar ::tr(AddCriteria:) -font font_Bold
  pack $w.tadd -side top
  pack [frame $w.add] -side top -fill x
  foreach b {Date Year Month Event Site Country Round Result Length 
             White Black Rating ECO Deleted EventDate} {
    set n [string tolower $b]
    button $w.add.$n -textvar ::tr($b) -command "addSortCriteria $b"
  }
  grid $w.add.date -row 0 -column 0 -sticky we
  grid $w.add.year -row 0 -column 1 -sticky we
  grid $w.add.month -row 0 -column 2 -sticky we
  grid $w.add.event -row 1 -column 0 -sticky we
  grid $w.add.site -row 1 -column 1 -sticky we
  grid $w.add.country -row 1 -column 2 -sticky we
  grid $w.add.round -row 2 -column 0 -sticky we
  grid $w.add.result -row 2 -column 1 -sticky we
  grid $w.add.length -row 2 -column 2 -sticky we
  grid $w.add.white -row 3 -column 0 -sticky we
  grid $w.add.black -row 3 -column 1 -sticky we
  grid $w.add.rating -row 3 -column 2 -sticky we
  grid $w.add.eco -row 4 -column 0 -sticky we
  grid $w.add.deleted -row 4 -column 1 -sticky we
  grid $w.add.eventdate -row 4 -column 2 -sticky we

  for {set i 0} {$i < 3} {incr i} {
    grid columnconfigure $w.add $i -weight 1
  }

  addHorizontalRule $w

  label $w.tcommon -textvar ::tr(CommonSorts:) -font font_Bold
  pack $w.tcommon -side top
  pack [frame $w.tc] -side top -fill x
  button $w.tc.ymsedr -text "$::tr(Year), $::tr(Month), $::tr(Site), $::tr(Event), $::tr(Date), $::tr(Round)" -command {
    clearSortCriteria
    addSortCriteria Year Month Site Event Date Round
  }
  button $w.tc.yedr -text "$::tr(Year), $::tr(Event), $::tr(Date), $::tr(Round)" -command {
    clearSortCriteria
    addSortCriteria Year Event Date Round
  }
  button $w.tc.er -text "$::tr(ECO), $::tr(Rating)" -command {
    clearSortCriteria
    addSortCriteria ECO Rating
  }
  grid $w.tc.ymsedr -row 0 -column 0 -sticky we
  grid $w.tc.yedr -row 1 -column 0 -sticky we
  grid $w.tc.er -row 2 -column 0 -sticky we
  grid columnconfigure $w.tc 0 -weight 1
  addHorizontalRule $w
  pack [frame $w.b] -side bottom -fill x
  button $w.b.clear -textvar ::tr(Clear) -command clearSortCriteria
  button $w.b.help -textvar ::tr(Help) -command {helpWindow Sorting}
  button $w.b.sort -textvar ::tr(Sort) -command sortDatabase
  button $w.b.close -textvar ::tr(Close) \
    -command "focus .; destroy $w"
  pack $w.b.close $w.b.sort -side right -padx 5 -pady 2
  pack $w.b.clear $w.b.help -side left -padx 5 -pady 2
  bind $w <F1> {helpWindow Sorting}
  bind $w <Escape> "$w.b.close invoke"
  standardShortcuts $w
  updateSortWin
}

proc updateSortWin {} {
  global sortCriteria
  set w .sortWin
  if {! [winfo exists $w]} { return }
  set state disabled
  if {[sc_base inUse]  &&  $sortCriteria(real) != ""} { set state normal }
  $w.b.sort configure -state $state
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
    #tk_messageBox -type ok -icon info -parent $w \
      -title "Scid: Sort results" \
      -message "The database was successfully sorted."
  }
  updateBoard .board
  updateGList
  updateMaintWin
}

proc makeBaseReadOnly {} {
  if {! [sc_base inUse]} { return }
  if {[sc_base isReadOnly]} { return }
  set result [tk_dialog .roDialog "Scid: [tr FileReadOnly]" \
                $::tr(ReadOnlyDialog) "" 1 $::tr(Yes) $::tr(No)]
  if {$result == 0} {
    sc_base isReadOnly set
    updateMenuStates
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
  label $w.lab -wraplength 3i -justify left -text "This command will use the current spellcheck file to add Elo ratings to games in this database. Wherever a player has no currrent rating but his/her rating at the time of the game is listed in the spellcheck file, that rating will be added."
  pack $w.lab -side top
  addHorizontalRule $w
  pack [frame $w.r] -side top
  label $w.r.lab -text "Overwrite existing non-zero ratings?"
  radiobutton $w.r.yes -variable addRatings(overwrite) \
    -value 1 -text $::tr(Yes)
  radiobutton $w.r.no -variable addRatings(overwrite) \
    -value 0 -text $::tr(No)
  pack $w.r.lab $w.r.yes $w.r.no -side left
  addHorizontalRule $w
  pack [frame $w.g] -side top
  label $w.g.lab -text "Add ratings to:"
  radiobutton $w.g.all -variable addRatings(filter) \
    -value 0 -text $::tr(SelectAllGames)
  radiobutton $w.g.filter -variable addRatings(filter) \
    -value 1 -text $::tr(SelectFilterGames)
  pack $w.g.lab $w.g.all $w.g.filter -side top
  addHorizontalRule $w
  pack [frame $w.b] -side top -fill x
  button $w.b.ok -text "OK" \
    -command "catch {grab release $w}; destroy $w; doAllocateRatings"
  button $w.b.cancel -text $::tr(Cancel) \
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
    set r [thousands [lindex $result 0]]
    set g [thousands [lindex $result 1]]
    tk_messageBox -type ok -icon info -parent . \
      -title "Scid" -message "Scid added $r Elo ratings in $g games."
  }
  unbusyCursor .
}


# stripTags:
#   Strip unwanted PGN tags from the current database.

array set stripTagCount {}

proc stripTags {} {
  global stripTagChoice stripTagCount
  set w .striptags
  if {[winfo exists $w]} { return }
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
  label $w.title -text "Extra PGN tags:" -font font_Bold
  pack $w.title -side top
  pack [frame $w.f] -side top -fill x
  addHorizontalRule $w
  pack [frame $w.b] -side bottom -fill x

  set row 0
  foreach tag [lsort [array names stripTagCount]] {
    set count $stripTagCount($tag)
    radiobutton $w.f.t$tag -text "$tag  " -variable stripTagChoice -value $tag
    label $w.f.c$tag -text [thousands $count]
    if {$row == 0} { set stripTagChoice $tag }
    grid $w.f.t$tag -row $row -column 0 -sticky w
    grid $w.f.c$tag -row $row -column 1 -sticky e
    incr row
  }
  button $w.b.find -text $::tr(SetFilter) -command findStripTags
  button $w.b.strip -text $::tr(StripTag...) -command {
    set removed [doStripTags .striptags]
    set stripTagCount($stripTagChoice) \
      [expr $stripTagCount($stripTagChoice) - $removed]
    .striptags.f.c$stripTagChoice configure -text \
      [thousands $stripTagCount($stripTagChoice)]
  }
  button $w.b.cancel -text $::tr(Cancel) \
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
  updateStatsWin
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

  pack [frame $w.help] -side top -fill x
  text $w.help.text -width 1 -height 7 -wrap word \
    -relief ridge -cursor top_left_arrow -yscrollcommand "$w.help.ybar set"
  scrollbar $w.help.ybar -orient vertical -command "$w.help.text yview" \
    -takefocus 0 -width 10
  pack $w.help.ybar -side right -fill y
  pack $w.help.text -side left -fill x -expand yes
  $w.help.text insert end [string trim $::tr(CleanerHelp)]
  $w.help.text configure -state disabled

  pack [frame $w.f] -side top -padx 20
  foreach i {players events sites rounds} j {Players Events Sites Rounds} {
    label $w.f.$i -text "$::tr(Spellchecking): $::tr($j)"
  }
  label $w.f.eco -text $::tr(ReclassifyGames)
  label $w.f.elo -text $::tr(AddEloRatings)
  label $w.f.twins -text $::tr(DeleteTwins)
  label $w.f.cnames -text $::tr(CompactNames)
  label $w.f.cgames -text $::tr(CompactGames)
  label $w.f.tree -text [tr TreeFileFill]

  foreach i {players events sites rounds eco elo twins cnames cgames tree} {
    radiobutton $w.f.y$i -variable cleaner($i) -value 1 -text $::tr(Yes)
    radiobutton $w.f.n$i -variable cleaner($i) -value 0 -text $::tr(No)
  }
  set row 0
  foreach i {players events sites rounds eco elo twins cnames cgames tree} {
    grid $w.f.$i -row $row -column 0 -sticky w
    grid $w.f.y$i -row $row -column 1 -sticky w
    grid $w.f.n$i -row $row -column 2 -sticky w
    incr row
  }

  addHorizontalRule $w
  pack [frame $w.b] -side bottom -fill x
  button $w.b.ok -text "OK" -command "catch {grab release $w}; destroy $w; doCleaner"
  button $w.b.cancel -text $::tr(Cancel) -command "catch {grab release $w}; destroy $w"
  pack $w.b.cancel $w.b.ok -side right -padx 2 -pady 2
  wm resizable $w 0 0
  catch {grab $w}
}

proc doCleaner {} {
  global cleaner twinSettings

  set answer [tk_dialog .mtoolDialog "Scid" \
                [string trim $::tr(CleanerConfirm)] "" \
                0 $::tr(Yes) $::tr(No)]
  if {$answer != 0} { return }

  set w .mtoolStatus
  if {! [winfo exists $w]} {
    toplevel $w
    wm title $w "Scid: $::tr(Cleaner)"
    pack [frame $w.b] -side bottom -fill x
    pack [frame $w.t] -side top -fill both -expand yes
    text $w.t.text -width 60 -height 10 -wrap none -setgrid 1 \
      -cursor top_left_arrow -yscrollcommand "$w.t.ybar set"
    scrollbar $w.t.ybar -orient vertical -command "$w.t.text yview" \
      -takefocus 0 -width 10
    pack $w.t.ybar -side right -fill y
    pack $w.t.text -side left -fill both -expand yes
    button $w.b.close -text $::tr(Close) \
      -command "catch {grab release $w}; destroy $w"
    pack $w.b.close -side right -padx 2 -pady 2
    wm minsize $w 20 5
  }

  busyCursor .
  catch {grab $w}
  set t $w.t.text
  $t delete 1.0 end
  $t insert end "$::tr(Cleaner)."
  $t insert end "  $::tr(Database): [file tail [sc_base filename]]\n"

  $w.b.close configure -state disabled

  set count 1

  foreach nameType {Player Event Site Round} {
    set names $nameType
    append names "s"
    set tag [string tolower $names]
    if {$cleaner($tag)} {
      mtoolAdd $t "$count: $::tr(Spellchecking): $::tr($names)..."
      incr count
      set result "0 $nameType names were corrected."
      if {! [catch {sc_name spellcheck -max 100000 $nameType} corrections]} {
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
      set r [thousands [lindex $result 0]]
      set g [thousands [lindex $result 1]]
      $t insert end "   Scid added $r Elo ratings in $g games.\n"
    }
  }

  if {$cleaner(twins)} {
    mtoolAdd $t "$count: $::tr(DeleteTwins)..."
    incr count
    if {$twinSettings(undelete) == "Yes"} {
      catch {sc_game flag delete all 0}
      update
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
  updateBoard .board
  updateGList
  updateMaintWin
  $w.b.close configure -state normal
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
