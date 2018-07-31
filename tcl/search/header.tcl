###
### search/header.tcl: Header Search routines for Scid.
###

namespace eval ::search::header {}

set sTitleList [list gm im fm none wgm wim wfm w]
foreach i $sTitleList {
  set sTitles(w:$i) 1
  set sTitles(b:$i) 1
}
set sHeaderFlagList {StdStart Promotions Comments Variations Annotations \
      DeleteFlag WhiteOpFlag BlackOpFlag MiddlegameFlag EndgameFlag \
      NoveltyFlag PawnFlag TacticsFlag KsideFlag QsideFlag \
      BrilliancyFlag BlunderFlag UserFlag }

set sHeaderCustomFlagList {  CustomFlag1 CustomFlag2 CustomFlag3 CustomFlag4 CustomFlag5 CustomFlag6 }

set sHeaderFlagChars {S X _ _ _ D W B M E N P T K Q ! ? U 1 2 3 4 5 6}

set sPgntext(1) ""
set sPgntext(2) ""
set sPgntext(3) ""

# checkDates:
#    Checks minimum/maximum search dates in header search window and
#    extends them if necessary.
proc checkDates {} {
  global sDateMinEntry sDateMaxEntry sEventDateMinEntry sEventDateMaxEntry
  if {[string length $sDateMinEntry] == 4} { append sDateMinEntry ".??.??" }
  if {[string length $sDateMaxEntry] == 4} { append sDateMaxEntry ".12.31" }
  if {[string length $sDateMinEntry] == 7} { append sDateMinEntry ".??" }
  if {[string length $sDateMaxEntry] == 7} { append sDateMaxEntry ".31" }
  if {[string length $sEventDateMinEntry] == 4} { append sDateMinEntry ".??.??" }
  if {[string length $sEventDateMaxEntry] == 4} { append sDateMaxEntry ".12.31" }
  if {[string length $sEventDateMinEntry] == 7} { append sDateMinEntry ".??" }
  if {[string length $sEventDateMaxEntry] == 7} { append sDateMaxEntry ".31" }
}

proc ::search::header::initTrace {} {
  #initialize the *_old in validate.tcl
  set ::sWhiteEloMinEntry 0; set ::sWhiteEloMaxEntry 0
  set ::sBlackEloMinEntry 0; set ::sBlackEloMaxEntry 0
  set ::sEloDiffMinEntry 0; set ::sEloDiffMaxEntry 0
  set ::sGlMinEntry 0; set ::sGlMaxEntry 999
  set ::sGnumMinEntry 1; set ::sGnumMaxEntry -1
  set ::sEcoMinEntry "A00";  set ::sEcoMaxEntry "E99"
  set ::sDateMinEntry "0000.00.00"; set ::sDateMaxEntry "[sc_info limit year].12.31"
  set ::sEventDateMinEntry "0000.00.00"; set ::sEventDateMaxEntry "[sc_info limit year].12.31"
}

proc ::search::header::defaults {} {
  set ::sWhite "";  set ::sBlack ""
  set ::sEvent ""; set ::sSite "";  set ::sRound ""; set ::sAnnotator ""; set ::sAnnotated 0
  set ::sWhiteEloMinEntry ""; set ::sWhiteEloMaxEntry ""
  set ::sBlackEloMinEntry ""; set ::sBlackEloMaxEntry ""
  set ::sEloDiffMinEntry ""; set ::sEloDiffMaxEntry ""
  set ::sGlMinEntry ""; set ::sGlMaxEntry ""
  set ::sEcoMinEntry "";  set ::sEcoMaxEntry ""; set ::sEco Yes
  set ::sGnumMinEntry ""; set ::sGnumMaxEntry ""
  set ::sDateMinEntry ""; set ::sDateMaxEntry ""
  set ::sEventDateMinEntry ""; set ::sEventDateMaxEntry ""
  set ::sResWin ""; set ::sResLoss ""; set ::sResDraw ""; set ::sResOther ""
  set ::sIgnoreCol No
  set ::sSideToMoveW "w"
  set ::sSideToMoveB "b"
  foreach flag  [ concat $::sHeaderFlagList $::sHeaderCustomFlagList ] { set ::sHeaderFlags($flag) both }
  foreach i [array names ::sPgntext] { set ::sPgntext($i) "" }
  foreach i $::sTitleList {
    set ::sTitles(w:$i) 1
    set ::sTitles(b:$i) 1
  }
}

::search::header::initTrace
foreach i {sWhiteEloMinEntry sWhiteEloMaxEntry sBlackEloMinEntry sBlackEloMaxEntry} {
  trace variable $i w [list ::utils::validate::Integer [sc_info limit elo] 0]
}
trace variable sEloDiffMinEntry w [list ::utils::validate::Integer "-[sc_info limit elo]" 0]
trace variable sEloDiffMaxEntry w [list ::utils::validate::Integer "-[sc_info limit elo]" 0]

::search::header::defaults

trace variable sDateMinEntry w ::utils::validate::Date
trace variable sDateMaxEntry w ::utils::validate::Date
trace variable sEventDateMinEntry w ::utils::validate::Date
trace variable sEventDateMaxEntry w ::utils::validate::Date


trace variable sGlMinEntry w {::utils::validate::Integer 9999 0}
trace variable sGlMaxEntry w {::utils::validate::Integer 9999 0}

trace variable sGnumMinEntry w {::utils::validate::Integer -9999999 0}
trace variable sGnumMaxEntry w {::utils::validate::Integer -9999999 0}

# Forcing ECO entry to be valid ECO codes:
foreach i {sEcoMinEntry sEcoMaxEntry} {
  trace variable $i w {::utils::validate::Regexp {^$|^[A-Ea-e]$|^[A-Ea-e][0-9]$|^[A-Ea-e][0-9][0-9]$|^[A-Ea-e][0-9][0-9][a-z]$|^[A-Ea-e][0-9][0-9][a-z][1-4]$}}
}

set sHeaderFlagFrame 0

# ::search::header
#
#   Opens the window for searching by header information.
#
proc search::headerCreateFrame { w } {
  global sWhite sBlack sEvent sSite sRound sAnnotator sAnnotated sEventDateMinEntry sEventDateMaxEntry sIgnoreCol
  global sWhiteEloMinEntry sWhiteEloMaxEntry sBlackEloMinEntry sBlackEloMaxEntry
  global sEloDiffMin sEloDiffMax sSideToMoveW sSideToMoveB
  global sEco sEcoMin sEcoMax sHeaderFlags sGlMinEntry sGlMaxEntry sTitleList sTitles
  global sResWin sResLoss sResDraw sResOther sPgntext

  foreach frame {cWhite cBlack ignore tw tb eventsite eventround date res ano gl ends eco} {
    ttk::frame $w.$frame
  }
  
  set regular font_Small
  ttk::labelframe $w.player -text $::tr(Player)
  pack $w.player -side top -fill x -pady 5
  foreach color {White Black} {
    pack $w.c$color -side top -fill x -in $w.player
    ttk::label $w.c$color.lab -textvar ::tr($color:) -width 9 -anchor w
    ttk::combobox $w.c$color.e -textvariable "s$color" -width 40
    ::utils::history::SetCombobox HeaderSearch$color $w.c$color.e
    bind $w.c$color.e <Return> { .sh.b.search invoke; break }
    
    ttk::label $w.c$color.space
    ttk::label $w.c$color.elo1 -textvar ::tr(Rating:)
    ttk::entry $w.c$color.elomin -textvar s${color}EloMinEntry -width 6 -justify right
    ttk::label $w.c$color.elo2 -text "-"
    ttk::entry $w.c$color.elomax -textvar s${color}EloMaxEntry -width 6 -justify right
    bindFocusColors $w.c$color.e
    bindFocusColors $w.c$color.elomin
    bindFocusColors $w.c$color.elomax
    pack $w.c$color.lab $w.c$color.e $w.c$color.space -side left
    pack $w.c$color.elomax $w.c$color.elo2 $w.c$color.elomin $w.c$color.elo1 -side right
  }

  pack $w.ignore -side top -fill x -in $w.player
  ttk::checkbutton $w.ignore.yes -variable sIgnoreCol -onvalue Yes -offvalue No -textvar ::tr(IgnoreColors)
  pack $w.ignore.yes -side left
  ttk::label $w.ignore.rdiff -textvar ::tr(RatingDiff:)
  ttk::entry $w.ignore.rdmin -width 6 -textvar sEloDiffMinEntry -justify right
  ttk::label $w.ignore.rdto -text "-"
  ttk::entry $w.ignore.rdmax -width 6 -textvar sEloDiffMaxEntry -justify right
  bindFocusColors $w.ignore.rdmin
  bindFocusColors $w.ignore.rdmax
  pack $w.ignore.rdmax $w.ignore.rdto $w.ignore.rdmin $w.ignore.rdiff -side right

  pack [ttk::separator $w.sep] -side top -fill x -in $w.player
  set spellstate normal
  if {[lindex [sc_name read] 0] == 0} { set spellstate disabled }
  foreach c {w b} name {White Black} {
    pack $w.t$c -side top -fill x -in $w.player
    ttk::label $w.t$c.label -text "$::tr($name) FIDE:" -width 14 -anchor w
    pack $w.t$c.label -side left
    foreach i $sTitleList {
      set name [string toupper $i]
      if {$i == "none"} { set name "-" }
      ttk::checkbutton $w.t$c.b$i -text $name -variable sTitles($c:$i) -offvalue 0 -onvalue 1 -state $spellstate
      pack $w.t$c.b$i -side left -padx "0 10"
    }
  }
  
  lower $w.player
  
  ttk::labelframe $w.tournement -text $::tr(Event)
  pack $w.tournement -side top -fill x -pady 5
  set f $w.eventsite
  pack $f -side top -fill x -in $w.tournement -pady "0 3"
  foreach i {Event Site} {
    ttk::label $f.l$i -textvar ::tr(${i}:)
    ttk::combobox $f.e$i -textvariable s$i -width 30
    bind $f.e$i <Return> { .sh.b.search invoke ; break }
    ::utils::history::SetCombobox HeaderSearch$i $f.e$i
    bindFocusColors $f.e$i
  }
  pack $f.lEvent $f.eEvent -side left
  pack $f.eSite -side right
  pack $f.lSite -side right -padx "10 0"
  
  set f $w.eventround
  pack $f -side top -fill x -in $w.tournement
  lower $w.tournement
  ## Setup date of Event
  ttk::label $f.dl1 -text "$::tr(Event)\n$::tr(Date:)"
  ttk::label $f.dl2 -text "-"
  ttk::label $f.dl3 -text " "
  ttk::entry $f.demin -textvariable sEventDateMinEntry -width 10
  button $f.deminCal -image tb_calendar -padx 0 -pady 0 -command {
    regsub -all {[.]} $sEventDateMinEntry "-" newdate
    set ndate [::utils::date::chooser $newdate]
    if {[llength $ndate] == 3} {
      set sEventDateMinEntry "[lindex $ndate 0].[lindex $ndate 1].[lindex $ndate 2]"
    }
  }
  ttk::entry $f.demax -textvariable sEventDateMaxEntry -width 10
  button $f.demaxCal -image tb_calendar -padx 0 -pady 0 -command {
    regsub -all {[.]} $sEventDateMaxEntry "-" newdate
    set ndate [::utils::date::chooser $newdate]
    if {[llength $ndate] == 3} {
      set sEventDateMaxEntry "[lindex $ndate 0].[lindex $ndate 1].[lindex $ndate 2]"
    }
  }
  bindFocusColors $f.demin
  bindFocusColors $f.demax
  bind $f.demin <FocusOut> +checkDates
  bind $f.demax <FocusOut> +checkDates
  ttk::button $f.dlyear -textvar ::tr(YearToToday) -style Pad0.Small.TButton -command {
    set sEventDateMinEntry "[expr [::utils::date::today year]-1].[::utils::date::today month].[::utils::date::today day]"
    set sEventDateMaxEntry [::utils::date::today]
  }
  ::utils::tooltip::Set $f.dlyear $::tr(YearToTodayTooltip)

  pack $f.dl1 $f.demin $f.deminCal $f.dl2 $f.demax $f.demaxCal $f.dl3 $f.dlyear -side left

  ttk::label $f.lRound -textvar ::tr(Round:)
  ttk::entry $f.eRound -textvariable sRound -width 10
  bindFocusColors $f.eRound
  pack $f.eRound $f.lRound -side right

  set f $w.date
  pack $f -side top -fill x -in $w.tournement -pady "0 3"
  ## Setup Date of Game
  ttk::label $f.l1 -text "$::tr(game)\n$::tr(Date:)"
  ttk::label $f.l2 -text "-"
  ttk::label $f.l3 -text " "
  ttk::entry $f.emin -textvariable sDateMinEntry -width 10
  button $f.eminCal -image tb_calendar -padx 0 -pady 0 -command {
    regsub -all {[.]} $sDateMinEntry "-" newdate
    set ndate [::utils::date::chooser $newdate]
    if {[llength $ndate] == 3} {
      set sDateMinEntry "[lindex $ndate 0].[lindex $ndate 1].[lindex $ndate 2]"
    }
  }
  ttk::entry $f.emax -textvariable sDateMaxEntry -width 10
  button $f.emaxCal -image tb_calendar -padx 0 -pady 0 -command {
    regsub -all {[.]} $sDateMaxEntry "-" newdate
    set ndate [::utils::date::chooser $newdate]
    if {[llength $ndate] == 3} {
      set sDateMaxEntry "[lindex $ndate 0].[lindex $ndate 1].[lindex $ndate 2]"
    }
  }
  bindFocusColors $f.emin
  bindFocusColors $f.emax
  bind $f.emin <FocusOut> +checkDates
  bind $f.emax <FocusOut> +checkDates
  ttk::button $f.lyear -textvar ::tr(YearToToday) -style Pad0.Small.TButton -command {
    set sDateMinEntry "[expr [::utils::date::today year]-1].[::utils::date::today month].[::utils::date::today day]"
    set sDateMaxEntry [::utils::date::today]
  }
  ::utils::tooltip::Set $f.lyear $::tr(YearToTodayTooltip)

  pack $f.l1 $f.emin $f.eminCal $f.l2 $f.emax $f.emaxCal $f.l3 $f.lyear -side left
  
  ttk::labelframe $w.result -text $::tr(Result)
  pack $w.result -side top -fill x -pady 5
  pack $w.res -side top -fill x -in $w.result
  ttk::label $w.res.l1 -textvar ::tr(Result:)
  ttk::checkbutton $w.res.ewin -text "1-0 " -variable sResWin -offvalue "1" -onvalue ""
  ttk::checkbutton $w.res.edraw -text "1/2-1/2 " -variable sResDraw -offvalue "=" -onvalue ""
  ttk::checkbutton $w.res.eloss -text "0-1 " -variable sResLoss -offvalue "0" -onvalue ""
  ttk::checkbutton $w.res.eother -text "* " -variable sResOther -offvalue "*" -onvalue ""
  pack $w.res.l1 $w.res.ewin $w.res.edraw $w.res.eloss $w.res.eother -side left
  lower $w.result

  ttk::label $w.gl.l1 -textvar ::tr(GameLength:)
  ttk::label $w.gl.l2 -text "-"
  ttk::label $w.gl.l3 -textvar ::tr(HalfMoves)
  ttk::entry $w.gl.emin -textvariable sGlMinEntry -justify right -width 4
  ttk::entry $w.gl.emax -textvariable sGlMaxEntry -justify right -width 4
  bindFocusColors $w.gl.emin
  bindFocusColors $w.gl.emax
  pack $w.gl -in $w.res -side right -fill x
  pack $w.gl.l1 $w.gl.emin $w.gl.l2 $w.gl.emax $w.gl.l3 -side left
  
  ttk::label $w.ends.label -textvar ::tr(EndSideToMove)
  ttk::checkbutton $w.ends.white -textvar ::tr(White) -variable sSideToMoveW -offvalue "" -onvalue w
  ttk::checkbutton $w.ends.black -textvar ::tr(Black) -variable sSideToMoveB -offvalue "" -onvalue b
  pack $w.ends.label $w.ends.white $w.ends.black -side left -padx "0 5"
  pack $w.ends -side top -fill x -in $w.result
  
  pack $w.ano -side top -fill x
  ttk::label $w.ano.a1 -textvar ::tr(Annotations:)
  ttk::label $w.ano.a2 -textvar ::tr(Annotator:)
  ttk::checkbutton $w.ano.an -textvar ::tr(Cmnts) -variable sAnnotated -offvalue 0 -onvalue 1
  ttk::entry $w.ano.aname -textvariable sAnnotator -width 20
  pack $w.ano.a1 $w.ano.an -side left -padx "0 5"
  pack $w.ano.aname $w.ano.a2 -side right -padx "5 0"

  addHorizontalRule $w
  
  ttk::label $w.eco.l1 -textvar ::tr(ECOCode:)
  ttk::label $w.eco.l2 -text "-"
  ttk::label $w.eco.l3 -text " "
  ttk::entry $w.eco.emin -textvariable sEcoMinEntry -width 5
  ttk::entry $w.eco.emax -textvariable sEcoMaxEntry -width 5
  bindFocusColors $w.eco.emin
  bindFocusColors $w.eco.emax
  ttk::button $w.eco.range -text "..." -style  Pad0.Small.TButton -width 0 -command {
    set tempResult [chooseEcoRange]
    if {[scan $tempResult "%\[A-E0-9a-z\]-%\[A-E0-9a-z\]" sEcoMin_tmp sEcoMax_tmp] == 2} {
      set sEcoMinEntry $sEcoMin_tmp
      set sEcoMaxEntry $sEcoMax_tmp
    }
    unset tempResult
  }
  ttk::checkbutton $w.eco.yes -variable sEco -onvalue Yes -offvalue No -textvar ::tr(GamesWithNoECO)
  pack $w.eco -side top -fill x -pady "5 0"
  pack $w.eco.l1 $w.eco.emin $w.eco.l2 $w.eco.emax -side left
  pack $w.eco.range -side left -padx "5 10"
  pack $w.eco.l3 $w.eco.yes -side left
  
  set f [ttk::frame $w.gnum]
  pack $f -side top -fill x
  ttk::label $f.l1 -textvar ::tr(GlistGameNumber:)
  ttk::entry $f.emin -textvariable sGnumMinEntry -width 8 -justify right
  ttk::label $f.l2 -text "-" -font $regular
  ttk::entry $f.emax -textvariable sGnumMaxEntry -width 8 -justify right
  pack $f.l1 $f.emin $f.l2 $f.emax -side left
  bindFocusColors $f.emin
  bindFocusColors $f.emax
  ttk::label $f.l3 -text " "
  ttk::button $f.all -text [::utils::string::Capital $::tr(all)] -style Pad0.Small.TButton -command {set sGnumMin 1; set sGnumMax -1}
  ttk::menubutton $f.first -style pad0.TMenubutton -textvar ::tr(First...) -menu $f.first.m
  ttk::menubutton $f.last -style pad0.TMenubutton -textvar ::tr(Last...) -menu $f.last.m
  menu $f.first.m
  menu $f.last.m
  foreach x {10 50 100 500 1000 5000 10000} {
    $f.first.m add command -label $x \
        -command "set sGnumMinEntry 1; set sGnumMaxEntry $x"
    $f.last.m add command -label $x \
        -command "set sGnumMinEntry -$x; set sGnumMaxEntry -1"
  }
  pack $f.l3 $f.all $f.first $f.last -side left -padx 2
  
  set f [ttk::frame $w.pgntext]
  pack $f -side top -fill x
  ttk::label $f.l1 -textvar ::tr(PgnContains:)
  ttk::entry $f.e1 -textvariable sPgntext(1) -width 15
  ttk::label $f.l2 -text "+" -font $regular
  ttk::entry $f.e2 -textvariable sPgntext(2) -width 15
  ttk::label $f.l3 -text "+" -font $regular
  ttk::entry $f.e3 -textvariable sPgntext(3) -width 15
  bindFocusColors $f.e1
  bindFocusColors $f.e2
  bindFocusColors $f.e3
  pack $f.l1 $f.e1 $f.l2 $f.e2 $f.l3 $f.e3 -side left -pady "0 5"
  
  addHorizontalRule $w
  
  ttk::button $w.flagslabel -textvar ::tr(FindGamesWith:) -style Pad0.Small.TButton -image tb_menu -compound left -command {
    if {$sHeaderFlagFrame} {
      set sHeaderFlagFrame 0
      pack forget .sh.flags
    } else {
      set sHeaderFlagFrame 1
      ##TODO when used from searchframework
      pack .sh.flags -side top -after .sh.flagslabel
    }
  }
  pack $w.flagslabel -side top -fill x -pady "5 5"

  ttk::frame $w.flags
  if {$::sHeaderFlagFrame} {
    pack $w.flags -side top -pady 5
  }
  
  set count 0
  set row 0
  set col 0
  foreach var $::sHeaderFlagList {   
    set lab [ttk::label $w.flags.l$var -text  [ ::tr $var ] -font font_Small]
    grid $lab -row $row -column $col -sticky e
    incr col
    grid [ttk::radiobutton $w.flags.yes$var -variable sHeaderFlags($var) -value yes -text $::tr(Yes)] -row $row -column $col
    incr col
    grid [ttk::radiobutton $w.flags.no$var -variable sHeaderFlags($var) -value no -text $::tr(No)] -row $row -column $col
    incr col
    grid [ttk::radiobutton $w.flags.both$var -variable sHeaderFlags($var) -value both -text $::tr(Both)] -row $row -column $col
    incr count
    incr col -3
    incr row
    if {$count == 6} { set col 5; set row 0 }
    if {$count == 12} { set col 10; set row 0 }
  }
  
  set ::curr_db [sc_base current]
  set count 1
  set col 0
  set row 7
  foreach var $::sHeaderCustomFlagList {
    
    set lb [sc_base extra $::curr_db flag$count]
    if { $lb == ""  } {  set lb $var  }
    
    set lab [ttk::label $w.flags.l$var -text $lb -font font_Small]
    grid $lab -row $row -column $col -sticky e
    incr col
    grid [ttk::radiobutton $w.flags.yes$var -variable sHeaderFlags($var) -value yes -text $::tr(Yes)] -row $row -column $col
    incr col
    grid [ttk::radiobutton $w.flags.no$var -variable sHeaderFlags($var) -value no -text $::tr(No)] -row $row -column $col
    incr col
    grid [ttk::radiobutton $w.flags.both$var -variable sHeaderFlags($var) -value both -text $::tr(Both)] -row $row -column $col
    incr col 2
    incr count
    if {$count == 4} { set col 0; set row 8 }
  }
}

proc search::header {{ref_base ""} {ref_filter ""}} {
  set w .sh
  if {[winfo exists $w]} {
    wm deiconify $w
    raiseWin $w
    return
  }
  
  win::createDialog $w
  wm title $w "Scid: $::tr(HeaderSearch)"
  if {$ref_base != ""} {
    set ::refDatabaseH $ref_base
    set ::refFilterH $ref_filter
  } else {
    pack [ttk::frame $w.refdb] -side top -fill x
    CreateSelectDBWidget "$w.refdb" "refDatabaseH" "$ref_base"
    set ::refFilterH ""
  }
  bind $w <F1> { helpWindow Searches Header }
  bind $w <Escape> "$w.b.cancel invoke"
  bind $w <Return> "$w.b.search invoke"

  headerCreateFrame $w
  ::search::addFilterOpFrame $w 1
  
  ### Header search: search/cancel buttons
  ttk::frame $w.b
  pack $w.b -side top -fill both -pady 5
  ttk::button $w.b.defaults -textvar ::tr(Defaults) -command ::search::header::defaults
  ttk::button $w.b.save -textvar ::tr(Save...) -command ::search::header::save
  ttk::button $w.b.stop -textvar ::tr(Stop) -command progressBarCancel
  ttk::button $w.b.new_search -text "[tr Search] ([tr GlistNewSort] [tr Filter])" -command {::search::header::do_search 1 }
  ttk::button $w.b.search -textvar ::tr(Search) -command {::search::header::do_search 0 }
  ttk::button $w.b.cancel -textvar ::tr(Close) -command {focus .; destroy .sh}

  pack $w.b.defaults $w.b.save -side left -padx 5
  pack $w.b.cancel $w.b.new_search $w.b.search -side right -padx 5

  pack [ ttk::frame $w.fprogress ] -fill both
  canvas $w.fprogress.progress -height 20 -width 300 -bg white -relief solid -border 1
  $w.fprogress.progress create rectangle 0 0 0 0 -fill blue -outline blue -tags bar
  $w.fprogress.progress create text 295 10 -anchor e -font font_Regular -tags time \
      -fill black -text "0:00 / 0:00"
  pack $w.fprogress.progress -side top -pady 2
  # update
  wm resizable $w 0 0
  ::search::Config
  focus $w.cWhite.e
}

### Copy values from header search dialog to search variables. Use empty string as "all"
proc getSearchEntries {} {
  global sWhiteEloMin sWhiteEloMax sBlackEloMin sBlackEloMax
  global sGlMin sGlMax sGlMinEntry sGlMaxEntry
  global sWhiteEloMinEntry sWhiteEloMaxEntry sBlackEloMinEntry sBlackEloMaxEntry
  global sEloDiffMin sEloDiffMax sEloDiffMinEntry sEloDiffMaxEntry sEventDateMin sEventDateMax
  global sGnumMin sGnumMax sGnumMinEntry sGnumMaxEntry sEventDateMinEntry sEventDateMaxEntry
  global sEcoMin sEcoMax sDateMin sDateMax sEcoMinEntry sEcoMaxEntry sDateMinEntry sDateMaxEntry
  set sWhiteEloMin 0; set sWhiteEloMax [sc_info limit elo]
  set sBlackEloMin 0; set sBlackEloMax [sc_info limit elo]
  set ::sEloDiffMin "-[sc_info limit elo]"
  set ::sEloDiffMax "+[sc_info limit elo]"
  set ::sGlMin 0; set ::sGlMax 999
  set ::sGnumMin 1; set ::sGnumMax -1
  set ::sEcoMin "A00";  set ::sEcoMax "E99"
  set ::sDateMin "0000.00.00"; set ::sDateMax "[sc_info limit year].12.31"
  set ::sEventDateMin "0000.00.00"; set ::sEventDateMax "[sc_info limit year].12.31"
  foreach i { sWhiteEloMin sWhiteEloMax sBlackEloMin sBlackEloMax sGlMin sGlMax sEloDiffMin sEloDiffMax sGnumMin sGnumMax sDateMin sDateMax sEcoMin sEcoMax sEventDateMin sEventDateMax} {
     set j $i
     append j Entry
     if { [set $j] != "" } { set $i [set $j] }
  }
}

proc ::search::header::do_search {new_filter} {
    global sWhite sBlack sEvent sSite sRound sAnnotator sAnnotated sDateMin sDateMax sIgnoreCol
    global sWhiteEloMin sWhiteEloMax sBlackEloMin sBlackEloMax sEventDateMin sEventDateMax
    global sEloDiffMin sEloDiffMax sEloDiffMinEntry sEloDiffMaxEntry sSideToMoveW sSideToMoveB
    global sEco sEcoMin sEcoMax sHeaderFlags sGlMin sGlMax sTitleList sTitles
    global sResWin sResLoss sResDraw sResOther sPgntext

    set dbase [string index $::refDatabaseH 0]
    if {$::refFilterH ne ""} {
        set ::refFilterH [sc_filter compose $dbase $::refFilterH ""]
    } else {
        set ::refFilterH "dbfilter"
    }
    if {$new_filter} {
        set tmp_filter [sc_filter new $dbase]
        sc_filter copy $dbase $tmp_filter $::refFilterH
        set ::refFilterH $tmp_filter
    }
    set filter $::refFilterH

    ::utils::history::AddEntry HeaderSearchWhite $sWhite
    ::utils::history::AddEntry HeaderSearchBlack $sBlack
    ::utils::history::AddEntry HeaderSearchEvent $sEvent
    ::utils::history::AddEntry HeaderSearchSite $sSite
    
    set sPgnlist {}
    foreach i {1 2 3} {
      set temp [string trim $sPgntext($i)]
      if {$temp != ""} { lappend sPgnlist $temp }
    }
    pack .sh.b.stop -side right -padx 5
    grab .sh.b.stop
    set wtitles {}
    set btitles {}
    foreach i $sTitleList {
      if $sTitles(w:$i) { lappend wtitles $i }
      if $sTitles(b:$i) { lappend btitles $i }
    }

    if {$sEco == "Yes"} {
        set noEco "-eco|"
    } else {
        set noEco "-eco!"
    }

    if {$::search::filter::operation != "2" } {
        set fOrig [sc_filter new $dbase]
        sc_filter copy $dbase $fOrig $filter
    }

    set flagsYes ""
    set flagsNo ""
    set idx -1
    foreach i [ concat $::sHeaderFlagList $::sHeaderCustomFlagList ] {
        incr idx
        if {$i == "Comments"} { continue }
        if {$i == "Variations"} { continue }
        if {$i == "Annotations"} { continue }

        if  { $sHeaderFlags($i) == "yes" } {
            append flagsYes [lindex $::sHeaderFlagChars $idx]
        } elseif  { $sHeaderFlags($i) == "no" } {
            append flagsNo [lindex $::sHeaderFlagChars $idx]
        }
    }

    set fCounts(Variations) "-n_variations"
    set fCountsV(Variations) ""
    set fCounts(Comments) "-n_comments"
    set fCountsV(Comments) ""
    set fCounts(Annotations) "-n_nags"
    set fCountsV(Annotations) ""
    foreach i {"Variations" "Comments" "Annotations"} {
        if  { $sHeaderFlags($i) == "yes" } {
             append fCounts($i) "!"
             set fCountsV($i) "0"
        } elseif  { $sHeaderFlags($i) == "no" } {
             set fCountsV($i) "0"
        }
    }

    set results ""
    append results $sResWin
    append results $sResDraw
    append results $sResLoss
    append results $sResOther
    getSearchEntries

    progressBarSet .sh.fprogress.progress 301 21
    sc_filter search $dbase $filter header \
          -filter RESET \
          -white $sWhite -black $sBlack \
          -event $sEvent -site $sSite -round $sRound \
          -eventdate [list $sEventDateMin $sEventDateMax] \
          -date [list $sDateMin $sDateMax] \
          -result! $results \
          -welo [list $sWhiteEloMin $sWhiteEloMax] \
          -belo [list $sBlackEloMin $sBlackEloMax] \
          -delo [list $sEloDiffMin $sEloDiffMax] \
          -eco [list $sEcoMin $sEcoMax] $noEco [list 0 0] \
          -length [list $sGlMin $sGlMax] \
          -toMove "$sSideToMoveW$sSideToMoveB" \
          -gnum [list $::sGnumMin $::sGnumMax] \
          -annotated $sAnnotated \
          -annotator $sAnnotator \
          -flag $flagsYes -flag! $flagsNo \
          $fCounts(Variations) $fCountsV(Variations) \
          $fCounts(Comments) $fCountsV(Comments) \
          $fCounts(Annotations) $fCountsV(Annotations) \
          -pgn $sPgnlist -wtitles $wtitles -btitles $btitles \

    if {$sIgnoreCol == "Yes"} {
        set fIgnore [sc_filter new $dbase]
        set deloMin [ expr { $sEloDiffMax * -1 }]
        set deloMax [ expr { $sEloDiffMin * -1 }]
        progressBarSet .sh.fprogress.progress 301 21
        sc_filter search $dbase $fIgnore header \
          -filter RESET \
          -white $sBlack -black $sWhite \
          -event $sEvent -site $sSite -round $sRound \
          -eventdate [list $sEventDateMin $sEventDateMax] \
          -date [list $sDateMin $sDateMax] \
          -result! $results \
          -welo [list $sBlackEloMin $sBlackEloMax] \
          -belo [list $sWhiteEloMin $sWhiteEloMax] \
          -delo [list $deloMin $deloMax] \
          -eco [list $sEcoMin $sEcoMax] $noEco [list 0 0] \
          -length [list $sGlMin $sGlMax] \
          -toMove $sSideToMove \
          -gnum [list $::sGnumMin $::sGnumMax] \
          -annotated $sAnnotated \
          -annotator $sAnnotator \
          -flag $flagsYes -flag! $flagsNo \
          $fCounts(Variations) $fCountsV(Variations) \
          $fCounts(Comments) $fCountsV(Comments) \
          $fCounts(Annotations) $fCountsV(Annotations) \
          -pgn $sPgnlist -wtitles $wtitles -btitles $btitles \

        sc_filter or $dbase $filter $fIgnore
        sc_filter release $dbase $fIgnore
    }

    if {[info exists fOrig]} {
        if {$::search::filter::operation == "0" } {
            sc_filter and $dbase $filter $fOrig
        } else {
            sc_filter or $dbase $filter $fOrig
        }
        sc_filter release $dbase $fOrig
        unset fOrig
    }

    foreach {filterSz gameSz mainSz} [sc_filter sizes $dbase $filter] {}
    set str [::windows::gamelist::formatFilterText $filterSz $gameSz]
    .sh.filterop configure -text "$::tr(FilterOperation) ($str)"
    
    grab release .sh.b.stop
    pack forget .sh.b.stop

    if {$new_filter} {
        ::windows::gamelist::Open $dbase $::refFilterH
    } else {
        ::notify::DatabaseModified $dbase $::refFilterH
    }
}

proc ::search::header::save {} {
  global sWhite sBlack sEvent sSite sRound sAnnotator sAnnotated sDateMin sDateMax sIgnoreCol
  global sWhiteEloMin sWhiteEloMax sBlackEloMin sBlackEloMax
  global sEloDiffMin sEloDiffMax sGlMin sGlMax
  global sEco sEcoMin sEcoMax sHeaderFlags sSideToMoveW sSideToMoveB
  global sResWin sResLoss sResDraw sResOther sPgntext
  
  set ftype { { "Scid SearchOptions files" {".sso"} } }
  set fName [tk_getSaveFile -initialdir [pwd] -filetypes $ftype -title "Create a SearchOptions file"]
  if {$fName == ""} { return }
  
  if {[string compare [file extension $fName] ".sso"] != 0} {
    append fName ".sso"
  }
  
  if {[catch {set searchF [open [file nativename $fName] w]} ]} {
    tk_messageBox -title "Error: Unable to open file" -type ok -icon error \
        -message "Unable to create SearchOptions file: $fName"
    return
  }
  puts $searchF "\# SearchOptions File created by Scid $::scidVersion"
  puts $searchF "set searchType Header"
  getSearchEntries

  # First write the regular variables:
  foreach i {sWhite sBlack sEvent sSite sRound sAnnotator sAnnotated sDateMin sDateMax sResWin
    sResLoss sResDraw sResOther sWhiteEloMin sWhiteEloMax sBlackEloMin
    sBlackEloMax sEcoMin sEcoMax sEloDiffMin sEloDiffMax
    sIgnoreCol sSideToMoveW sSideToMoveB sGlMin sGlMax ::search::filter::operation} {
    puts $searchF "set $i [list [set $i]]"
  }
  # Now write the array values:
  foreach i [array names sHeaderFlags] {
    puts $searchF "set sHeaderFlags($i) [list $sHeaderFlags($i)]"
  }
  foreach i [array names sPgntext] {
    puts $searchF "set sPgntext($i) [list $sPgntext($i)]"
  }
  
  tk_messageBox -type ok -icon info -title "Search Options saved" \
      -message "Header search options saved to: $fName"
  close $searchF
}

##############################
### Selecting common ECO ranges

set scid_ecoRangeChosen ""
set ecoCommonRanges {}
proc chooseEcoRange {} {
  global ecoCommonRanges scid_ecoRangeChosen
  set ecoCommonRanges [ list \
      "A04-A09  [tr Reti]: [trans 1.Nf3]" \
      "A10-A39  [tr English]: 1.c4" \
      "A40-A49  1.d4, [tr d4Nf6Miscellaneous]" \
      "A45l-A45z  [tr Trompowsky]: [trans [list 1.d4 Nf6 2.Bg5]]" \
      "A51-A52  [tr Budapest]: [trans [list 1.d4 Nf6 2.c4 e5]]" \
      "A53-A55  [tr OldIndian]: [trans [list 1.d4 Nf6 2.c4 d6]]" \
      "A57-A59  [tr BenkoGambit]: [trans [list 1.d4 Nf6 2.c4 c5 3.d5 b5]]" \
      "A60-A79  [tr ModernBenoni]: [trans [list 1.d4 Nf6 2.c4 c5 3.d5 e6]]" \
      "A80-A99  [tr DutchDefence]: 1.d4 f5" \
      "____________________________________________________________" \
      "B00-C99  1.e4" \
      "B01-B01     [tr Scandinavian]: 1.e4 d5" \
      "B02-B05     [tr AlekhineDefence]: [trans [list 1.e4 Nf6]]" \
      "B07-B09     [tr Pirc]: 1.e4 d6" \
      "B10-B19     [tr CaroKann]: 1.e4 c6" \
      "B12i-B12z      [tr CaroKannAdvance]: 1.e4 c6 2.d4 d5 3.e5" \
      "B20-B99  [tr Sicilian]: 1.e4 c5" \
      "B22-B22     [tr SicilianAlapin]: 1.e4 c5 2.c3" \
      "B23-B26     [tr SicilianClosed]: [trans [list 1.e4 c5 2.Nc3]]" \
      "B30-B39     [tr Sicilian]: [trans [list 1.e4 c5 2.Nf3 Nc6]]" \
      "B40-B49     [tr Sicilian]: [trans [list 1.e4 c5 2.Nf3 e6]]" \
      "B50-B59     [tr SicilianRauzer]: [trans [list 1.e4 c5 2.Nf3 d6 ... 5.Nc3 Nc6]]" \
      "B70-B79     [tr SicilianDragon]: [trans [list 1.e4 c5 2.Nf3 d6 ... 5.Nc3 g6]]" \
      "B80-B89     [tr SicilianScheveningen]: [trans [list 1.e4 c5 2.Nf3 d6 ... 5.Nc3 e6]]" \
      "B90-B99     [tr SicilianNajdorf]: [trans [list 1.e4 c5 2.Nf3 d6 ... 5.Nc3 a6]]" \
      "____________________________________________________________" \
      "C00-C19  [tr FrenchDefence]: 1.e4 e6" \
      "C02-C02     [tr FrenchAdvance]: 1.e4 e6 2.d4 d5 3.e5" \
      "C03-C09     [tr FrenchTarrasch]: [trans [list 1.e4 e6 2.d4 d5 3.Nd2]]" \
      "C15-C19     [tr FrenchWinawer]: [trans [list 1.e4 e6 2.d4 d5 3.Nc3 Bb4]]" \
      "C20-C99  [tr OpenGame]: 1.e4 e5" \
      "C25-C29     [tr Vienna]: [trans [list 1.e4 e5 2.Nc3]]" \
      "C30-C39     [tr KingsGambit]: 1.e4 e5 2.f4" \
      "C42-C43     [tr RussianGame]: [trans [list 1.e4 e5 2.Nf3 Nf6]]" \
      "C44-C49     [tr OpenGame]: [trans [list 1.e4 e5 2.Nf3 Nc6]]" \
      "C50-C59     [tr ItalianTwoKnights]: 1.e4 e5 2.Nf3 Nc6 3.Bc4]]" \
      "C60-C99  [tr Spanish]: [trans [list 1.e4 e5 2.Nf3 Nc6 3.Bb5]]" \
      "C68-C69      [tr SpanishExchange]: [trans [list 3.Bb5 a6 4.Bxc6]]" \
      "C80-C83      [tr SpanishOpen]: [trans [list 3.Bb5 a6 4.Ba4 Nf6 5.O-O Nxe4]]" \
      "C84-C99      [tr SpanishClosed]: [trans [list 3.Bb5 a6 4.Ba4 Nf6 5.O-O Be7]]" \
      "____________________________________________________________" \
      "D00-D99  [tr Queen's Pawn]: 1.d4 d5" \
      "D10-D19  [tr Slav]: 1.d4 d5 2.c4 c6" \
      "D20-D29  [tr QGA]: 1.d4 d5 2.c4 dxc4" \
      "D30-D69  [tr QGD]: 1.d4 d5 2.c4 e6" \
      "D35-D36     [tr QGDExchange]: 1.d4 d5 2.c4 e6 3.cxd5 exd5" \
      "D43-D49     [tr SemiSlav]: [trans [list 3.Nc3 Nf6 4.Nf3 c6]]" \
      "D50-D69     [tr QGDwithBg5]: [trans [list 1.d4 d5 2.c4 e6 3.Nc3 Nf6 4.Bg5]]" \
      "D60-D69     [tr QGDOrthodox]: [trans [list 4.Bg5 Be7 5.e3 O-O 6.Nf3 Nbd7]]" \
      "D70-D99  [tr Grunfeld]: [trans [list 1.d4 Nf6 2.c4 g6 with 3...d5]]" \
      "D85-D89     [tr GrunfeldExchange]: [trans [list 3.Nc3 d5 4.e4 Nxc3 5.bxc3]]" \
      "D96-D99     [tr GrunfeldRussian]: [trans [list 3.Nc3 d5 4.Nf3 Bg7 5.Qb3]]" \
      "____________________________________________________________" \
      "E00-E09  [tr Catalan]: [trans [list 1.d4 Nf6 2.c4 e6 3.g3/...]]" \
      "E02-E05     [tr CatalanOpen]: [trans [list 3.g3 d5 4.Bg2 dxc4]]" \
      "E06-E09     [tr CatalanClosed]: [trans [list 3.g3 d5 4.Bg2 Be7]]" \
      "E12-E19  [tr QueensIndian]: [trans [list 1.d4 Nf6 2.c4 e6 3.Nf3 b6]]" \
      "E20-E59  [tr NimzoIndian]: [trans [list 1.d4 Nf6 2.c4 e6 3.Nc3 Bb4]]" \
      "E32-E39     [tr NimzoIndianClassical]: [trans [list 4.Qc2]]" \
      "E40-E59     [tr NimzoIndianRubinstein]: 4.e3" \
      "E60-E99  [tr KingsIndian]: [trans [list 1.d4 Nf6 2.c4 g6]]" \
      "E80-E89     [tr KingsIndianSamisch]: 4.e4 d6 5.f3" \
      "E90-E99     [tr KingsIndianMainLine]: [trans [list 4.e4 d6 5.Nf3]]" \
      ]
  
  if {[winfo exists .ecoRangeWin]} { return }
  set w .ecoRangeWin
  toplevel $w
  wm title $w "Scid: Choose ECO Range"
  wm minsize $w 30 5
  
  listbox $w.list -yscrollcommand "$w.ybar set" -height 20 -width 60 -background white -setgrid 1
  foreach i $ecoCommonRanges { $w.list insert end $i }
  ttk::scrollbar $w.ybar -command "$w.list yview" -takefocus 0
  pack [ttk::frame $w.b] -side bottom -fill x
  pack $w.ybar -side right -fill y
  pack $w.list -side left -fill both -expand yes
  
  ttk::button $w.b.ok -text "OK" -command {
    set sel [.ecoRangeWin.list curselection]
    if {[llength $sel] > 0} {
      set scid_ecoRangeChosen [lindex $ecoCommonRanges [lindex $sel 0]]
      set ::sEco No
    }
    focus .sh
    destroy .ecoRangeWin
  }
  ttk::button $w.b.cancel -text $::tr(Cancel) -command "focus .sh; destroy $w"
  pack $w.b.cancel $w.b.ok -side right -padx 5 -pady 2
  bind $w <Escape> "
  set scid_ecoRangeChosen {}
  grab release $w
  focus .
  destroy $w
  break"
  bind $w <Return> "$w.b.ok invoke; break"
  bind $w.list <Double-ButtonRelease-1> "$w.b.ok invoke; break"
  focus $w.list
  grab $w
  tkwait window $w
  return $scid_ecoRangeChosen
}

###
### End of file: search.tcl

