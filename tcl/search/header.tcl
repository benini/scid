###
### search/header.tcl: Header Search routines for Scid.
###

namespace eval ::search::header {}

# Store custom preset filters
array set ::sHeader_PresetFilters {}
::options.store ::sHeader_PresetFilters

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

set sVariantStd 1
set sVariant960 1

set sPgntext(1) ""
set sPgntext(2) ""
set sPgntext(3) ""

# checkDates:
#    Checks minimum/maximum search dates in header search window and
#    extends them if necessary.
proc checkDates {} {
  global sDateMin sDateMax sEventDateMin sEventDateMax
  if {[string length $sDateMin] == 4} { append sDateMin ".??.??" }
  if {[string length $sDateMax] == 4} { append sDateMax ".12.31" }
  if {[string length $sDateMin] == 7} { append sDateMin ".??" }
  if {[string length $sDateMax] == 7} { append sDateMax ".31" }
  if {[string length $sEventDateMin] == 4} { append sEventDateMin ".??.??" }
  if {[string length $sEventDateMax] == 4} { append sEventDateMax ".12.31" }
  if {[string length $sEventDateMin] == 7} { append sEventDateMin ".??" }
  if {[string length $sEventDateMax] == 7} { append sEventDateMax ".31" }
}

proc ::search::header::defaults {} {
  set ::sWhite "";  set ::sBlack ""
  set ::sEvent ""; set ::sSite "";  set ::sRound ""; set ::sAnnotated 0
  set ::sTagName "Annotator";
  set ::sTagValue "";
  set ::sWhiteEloMin ""; set ::sWhiteEloMax ""
  set ::sBlackEloMin ""; set ::sBlackEloMax ""
  set ::sEloDiffMin ""; set ::sEloDiffMax ""
  set ::sGlMin ""; set ::sGlMax ""
  set ::sEcoMin "";  set ::sEcoMax ""; set ::sEco Yes
  set ::sGnumMin ""; set ::sGnumMax ""
  set ::sDateMin ""; set ::sDateMax ""
  set ::sEventDateMin ""; set ::sEventDateMax ""
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
::search::header::defaults

set sHeaderFlagFrame 0

# ::search::header
#
#   Opens the window for searching by header information.
#
proc ::search::header {{ref_base ""} {ref_filter "dbfilter"}} {
  ::search::Open $ref_base $ref_filter HeaderSearch ::search::headerCreateFrame
}

proc search::headerCreateFrame { w } {
  global sWhite sBlack sEvent sSite sRound sAnnotated sEventDateMin sEventDateMax sIgnoreCol
  global sWhiteEloMin sWhiteEloMax sBlackEloMin sBlackEloMax
  global sEloDiffMin sEloDiffMax sSideToMoveW sSideToMoveB
  global sEco sEcoMin sEcoMax sHeaderFlags sGlMin sGlMax sTitleList sTitles
  global sResWin sResLoss sResDraw sResOther sPgntext

  set regular font_Small
  set elo_limit [sc_info limit elo]

  # Configure main window grid - two columns: left (main content) and right (flags)
  grid columnconfigure $w 0 -weight 1
  grid columnconfigure $w 1 -weight 0
  grid rowconfigure $w 0 -weight 1

  # ============ LEFT SIDE CONTAINER ============
  ttk::frame $w.left
  grid $w.left -row 0 -column 0 -sticky nsew -padx "0 5"
  grid columnconfigure $w.left 0 -weight 1

  # Create sub-frames
  foreach frame {cWhite cBlack ignore tw tb eventsite eventround date res gl ends eco} {
    ttk::frame $w.left.$frame
  }

  set mainRow 0

  # ============ PLAYER SECTION ============
  ttk::labelframe $w.left.player -text $::tr(Player)
  grid $w.left.player -row $mainRow -column 0 -sticky ew -pady 5
  incr mainRow
  grid columnconfigure $w.left.player 0 -weight 1

  set playerRow 0
  foreach color {White Black} {
    grid $w.left.c$color -row $playerRow -column 0 -sticky ew -in $w.left.player
    incr playerRow

    ttk::label $w.left.c$color.lab -textvar ::tr($color:) -width 9 -anchor w
    ttk::combobox $w.left.c$color.e -textvariable "s$color" -width 40
    ::utils::history::SetCombobox HeaderSearch$color $w.left.c$color.e

    ttk::label $w.left.c$color.space
    ttk::label $w.left.c$color.elo1 -textvar ::tr(Rating:)
    ttk::entry $w.left.c$color.elomin -textvar s${color}EloMin -width 6 -justify right \
      -validate key -validatecommand [list ::validate::integer %P 0 $elo_limit]
    ttk::label $w.left.c$color.elo2 -text "-"
    ttk::entry $w.left.c$color.elomax -textvar s${color}EloMax -width 6 -justify right \
      -validate key -validatecommand [list ::validate::integer %P 0 $elo_limit]

    grid $w.left.c$color.lab     -row 0 -column 0 -sticky w
    grid $w.left.c$color.e       -row 0 -column 1 -sticky w
    grid $w.left.c$color.space   -row 0 -column 2 -sticky ew
    grid $w.left.c$color.elo1    -row 0 -column 3 -sticky e
    grid $w.left.c$color.elomin  -row 0 -column 4 -sticky e
    grid $w.left.c$color.elo2    -row 0 -column 5 -sticky e
    grid $w.left.c$color.elomax  -row 0 -column 6 -sticky e
    grid columnconfigure $w.left.c$color 2 -weight 1
  }

  # Ignore colors row
  grid $w.left.ignore -row $playerRow -column 0 -sticky ew -in $w.left.player
  incr playerRow

  ttk::checkbutton $w.left.ignore.yes -variable sIgnoreCol -onvalue Yes -offvalue No -textvar ::tr(IgnoreColors)
  ttk::label $w.left.ignore.rdiff -textvar ::tr(RatingDiff:)
  ttk::entry $w.left.ignore.rdmin -width 6 -textvar sEloDiffMin -justify right \
    -validate key -validatecommand [list ::validate::integer %P -$elo_limit $elo_limit]
  ttk::label $w.left.ignore.rdto -text "-"
  ttk::entry $w.left.ignore.rdmax -width 6 -textvar sEloDiffMax -justify right \
    -validate key -validatecommand [list ::validate::integer %P -$elo_limit $elo_limit]

  grid $w.left.ignore.yes    -row 0 -column 0 -sticky w
  grid $w.left.ignore.rdiff  -row 0 -column 1 -sticky e
  grid $w.left.ignore.rdmin  -row 0 -column 2 -sticky e
  grid $w.left.ignore.rdto   -row 0 -column 3 -sticky e
  grid $w.left.ignore.rdmax  -row 0 -column 4 -sticky e
  grid columnconfigure $w.left.ignore 0 -weight 1

  # Separator
  grid [ttk::separator $w.left.sep] -row $playerRow -column 0 -sticky ew -in $w.left.player
  incr playerRow

  # FIDE titles
  set spellstate normal
  if {[lindex [sc_name read] 0] == 0} { set spellstate disabled }
  foreach c {w b} name {White Black} {
    grid $w.left.t$c -row $playerRow -column 0 -sticky ew -in $w.left.player
    incr playerRow

    ttk::label $w.left.t$c.label -text "$::tr($name) FIDE:" -width 14 -anchor w
    grid $w.left.t$c.label -row 0 -column 0 -sticky w

    set col 1
    foreach i $sTitleList {
      set titleName [string toupper $i]
      if {$i == "none"} { set titleName "-" }
      ttk::checkbutton $w.left.t$c.b$i -text $titleName -variable sTitles($c:$i) -offvalue 0 -onvalue 1 -state $spellstate
      grid $w.left.t$c.b$i -row 0 -column $col -sticky w -padx "0 10"
      incr col
    }
  }

  lower $w.left.player

  # ============ TOURNAMENT SECTION ============
  ttk::labelframe $w.left.tournement -text $::tr(Event)
  grid $w.left.tournement -row $mainRow -column 0 -sticky ew -pady 5
  incr mainRow
  grid columnconfigure $w.left.tournement 0 -weight 1

  set tournRow 0

  # Event and Site row
  set f $w.left.eventsite
  grid $f -row $tournRow -column 0 -sticky ew -in $w.left.tournement -pady "0 3"
  incr tournRow

  ttk::label $f.lEvent -textvar ::tr(Event:)
  ttk::combobox $f.eEvent -textvariable sEvent -width 30
  ::utils::history::SetCombobox HeaderSearchEvent $f.eEvent
  ttk::label $f.lSite -textvar ::tr(Site:)
  ttk::combobox $f.eSite -textvariable sSite -width 30
  ::utils::history::SetCombobox HeaderSearchSite $f.eSite

  grid $f.lEvent -row 0 -column 0 -sticky w
  grid $f.eEvent -row 0 -column 1 -sticky w
  grid $f.lSite  -row 0 -column 2 -sticky e -padx "10 0"
  grid $f.eSite  -row 0 -column 3 -sticky e
  grid columnconfigure $f 1 -weight 1

  # Event date and round row
  set f $w.left.eventround
  grid $f -row $tournRow -column 0 -sticky ew -in $w.left.tournement
  incr tournRow

  ttk::label $f.dl1 -text "$::tr(Event)\n$::tr(Date:)"
  ttk::entry $f.demin -textvariable sEventDateMin -width 10 \
    -validate key -validatecommand [list ::validate::date %P]
  ttk::button $f.deminCal -image tb_calendar -style Pad0.Small.TButton -command {
    regsub -all {[.]} $sEventDateMin "-" newdate
    set ndate [::utils::date::chooser $newdate]
    if {[llength $ndate] == 3} {
      set sEventDateMin "[lindex $ndate 0].[lindex $ndate 1].[lindex $ndate 2]"
    }
  }
  ttk::label $f.dl2 -text "-"
  ttk::entry $f.demax -textvariable sEventDateMax -width 10 \
    -validate key -validatecommand [list ::validate::date %P]
  ttk::button $f.demaxCal -image tb_calendar -style Pad0.Small.TButton -command {
    regsub -all {[.]} $sEventDateMax "-" newdate
    set ndate [::utils::date::chooser $newdate]
    if {[llength $ndate] == 3} {
      set sEventDateMax "[lindex $ndate 0].[lindex $ndate 1].[lindex $ndate 2]"
    }
  }
  bind $f.demin <FocusOut> +checkDates
  bind $f.demax <FocusOut> +checkDates
  ttk::label $f.dl3 -text " "
  ttk::button $f.dlyear -textvar ::tr(YearToToday) -style Pad0.Small.TButton -command {
    set sEventDateMin "[expr [::utils::date::today year]-1].[::utils::date::today month].[::utils::date::today day]"
    set sEventDateMax [::utils::date::today]
  }
  ::utils::tooltip::Set $f.dlyear $::tr(YearToTodayTooltip)

  ttk::label $f.lRound -textvar ::tr(Round:)
  ttk::entry $f.eRound -textvariable sRound -width 10

  grid $f.dl1      -row 0 -column 0 -sticky w
  grid $f.demin    -row 0 -column 1 -sticky w
  grid $f.deminCal -row 0 -column 2 -sticky w
  grid $f.dl2      -row 0 -column 3 -sticky w
  grid $f.demax    -row 0 -column 4 -sticky w
  grid $f.demaxCal -row 0 -column 5 -sticky w
  grid $f.dl3      -row 0 -column 6 -sticky w
  grid $f.dlyear   -row 0 -column 7 -sticky w
  grid $f.lRound   -row 0 -column 8 -sticky e
  grid $f.eRound   -row 0 -column 9 -sticky e
  grid columnconfigure $f 8 -weight 1

  # Game date row
  set f $w.left.date
  grid $f -row $tournRow -column 0 -sticky ew -in $w.left.tournement -pady "0 3"
  incr tournRow

  ttk::label $f.l1 -text "$::tr(game)\n$::tr(Date:)"
  ttk::entry $f.emin -textvariable sDateMin -width 10 \
    -validate key -validatecommand [list ::validate::date %P]
  ttk::button $f.eminCal -image tb_calendar -style Pad0.Small.TButton -command {
    regsub -all {[.]} $sDateMin "-" newdate
    set ndate [::utils::date::chooser $newdate]
    if {[llength $ndate] == 3} {
      set sDateMin "[lindex $ndate 0].[lindex $ndate 1].[lindex $ndate 2]"
    }
  }
  ttk::label $f.l2 -text "-"
  ttk::entry $f.emax -textvariable sDateMax -width 10 \
    -validate key -validatecommand [list ::validate::date %P]
  ttk::button $f.emaxCal -image tb_calendar -style Pad0.Small.TButton -command {
    regsub -all {[.]} $sDateMax "-" newdate
    set ndate [::utils::date::chooser $newdate]
    if {[llength $ndate] == 3} {
      set sDateMax "[lindex $ndate 0].[lindex $ndate 1].[lindex $ndate 2]"
    }
  }
  bind $f.emin <FocusOut> +checkDates
  bind $f.emax <FocusOut> +checkDates
  ttk::label $f.l3 -text " "
  ttk::button $f.lyear -textvar ::tr(YearToToday) -style Pad0.Small.TButton -command {
    set sDateMin "[expr [::utils::date::today year]-1].[::utils::date::today month].[::utils::date::today day]"
    set sDateMax [::utils::date::today]
  }
  ::utils::tooltip::Set $f.lyear $::tr(YearToTodayTooltip)

  grid $f.l1      -row 0 -column 0 -sticky w
  grid $f.emin    -row 0 -column 1 -sticky w
  grid $f.eminCal -row 0 -column 2 -sticky w
  grid $f.l2      -row 0 -column 3 -sticky w
  grid $f.emax    -row 0 -column 4 -sticky w
  grid $f.emaxCal -row 0 -column 5 -sticky w
  grid $f.l3      -row 0 -column 6 -sticky w
  grid $f.lyear   -row 0 -column 7 -sticky w

  lower $w.left.tournement

  # ============ RESULT SECTION ============
  ttk::labelframe $w.left.result -text $::tr(Result)
  grid $w.left.result -row $mainRow -column 0 -sticky ew -pady 5
  incr mainRow
  grid columnconfigure $w.left.result 0 -weight 1

  set resultRow 0

  # Result checkbuttons and game length
  grid $w.left.res -row $resultRow -column 0 -sticky ew -in $w.left.result
  incr resultRow

  ttk::label $w.left.res.l1 -textvar ::tr(Result:)
  ttk::checkbutton $w.left.res.ewin -text "1-0 " -variable sResWin -offvalue "1" -onvalue ""
  ttk::checkbutton $w.left.res.edraw -text "1/2-1/2 " -variable sResDraw -offvalue "=" -onvalue ""
  ttk::checkbutton $w.left.res.eloss -text "0-1 " -variable sResLoss -offvalue "0" -onvalue ""
  ttk::checkbutton $w.left.res.eother -text "* " -variable sResOther -offvalue "*" -onvalue ""

  grid $w.left.res.l1     -row 0 -column 0 -sticky w
  grid $w.left.res.ewin   -row 0 -column 1 -sticky w
  grid $w.left.res.edraw  -row 0 -column 2 -sticky w
  grid $w.left.res.eloss  -row 0 -column 3 -sticky w
  grid $w.left.res.eother -row 0 -column 4 -sticky w

  # Game length (in same row as results, right side)
  ttk::label $w.left.gl.l1 -textvar ::tr(GameLength:)
  ttk::entry $w.left.gl.emin -textvariable sGlMin -justify right -width 4 \
    -validate key -validatecommand [list ::validate::integer %P 0 9999]
  ttk::label $w.left.gl.l2 -text "-"
  ttk::entry $w.left.gl.emax -textvariable sGlMax -justify right -width 4 \
    -validate key -validatecommand [list ::validate::integer %P 0 9999]
  ttk::label $w.left.gl.l3 -textvar ::tr(HalfMoves)

  grid $w.left.gl -row 0 -column 5 -sticky e -in $w.left.res
  grid columnconfigure $w.left.res 4 -weight 1

  grid $w.left.gl.l1   -row 0 -column 0 -sticky w
  grid $w.left.gl.emin -row 0 -column 1 -sticky w
  grid $w.left.gl.l2   -row 0 -column 2 -sticky w
  grid $w.left.gl.emax -row 0 -column 3 -sticky w
  grid $w.left.gl.l3   -row 0 -column 4 -sticky w

  lower $w.left.result

  # Side to move row
  grid $w.left.ends -row $resultRow -column 0 -sticky ew -in $w.left.result
  incr resultRow

  ttk::label $w.left.ends.label -textvar ::tr(EndSideToMove)
  ttk::checkbutton $w.left.ends.white -textvar ::tr(White) -variable sSideToMoveW -offvalue "" -onvalue w
  ttk::checkbutton $w.left.ends.black -textvar ::tr(Black) -variable sSideToMoveB -offvalue "" -onvalue b

  grid $w.left.ends.label -row 0 -column 0 -sticky w
  grid $w.left.ends.white -row 0 -column 1 -sticky w -padx "0 5"
  grid $w.left.ends.black -row 0 -column 2 -sticky w -padx "0 5"

  # ============ ECO SECTION ============
  grid $w.left.eco -row $mainRow -column 0 -sticky ew -pady 5
  incr mainRow

  ttk::label $w.left.eco.l1 -textvar ::tr(ECOCode:)
  ttk::entry $w.left.eco.emin -textvariable sEcoMin -width 6 \
    -validate key -validatecommand [list regexp {^([A-Ea-e](\d(\d([a-z]([1-4])?)?)?)?)?$} %P]

  ttk::label $w.left.eco.l2 -text "-"
  ttk::entry $w.left.eco.emax -textvariable sEcoMax -width 6 \
    -validate key -validatecommand [list regexp {^([A-Ea-e](\d(\d([a-z]([1-4])?)?)?)?)?$} %P]

  ttk::button $w.left.eco.range -text "..." -style Pad0.Small.TButton -width 0 -command {
    set tempResult [chooseEcoRange]
    if {[scan $tempResult "%\[A-E0-9a-z\]-%\[A-E0-9a-z\]" sEcoMin_tmp sEcoMax_tmp] == 2} {
      set sEcoMin $sEcoMin_tmp
      set sEcoMax $sEcoMax_tmp
    }
    unset tempResult
  }
  ttk::label $w.left.eco.l3 -text " "
  ttk::checkbutton $w.left.eco.yes -variable sEco -onvalue Yes -offvalue No -textvar ::tr(GamesWithNoECO)

  grid $w.left.eco.l1    -row 0 -column 0 -sticky w
  grid $w.left.eco.emin  -row 0 -column 1 -sticky w
  grid $w.left.eco.l2    -row 0 -column 2 -sticky w
  grid $w.left.eco.emax  -row 0 -column 3 -sticky w
  grid $w.left.eco.range -row 0 -column 4 -sticky w -padx "5 10"
  grid $w.left.eco.l3    -row 0 -column 5 -sticky w
  grid $w.left.eco.yes   -row 0 -column 6 -sticky w

  # ============ GAME NUMBER SECTION ============
  set f [ttk::frame $w.left.gnum]
  grid $f -row $mainRow -column 0 -sticky ew -pady "0 5"
  incr mainRow

  ttk::label $f.l1 -textvar ::tr(GlistGameNumber:)
  ttk::entry $f.emin -textvariable sGnumMin -width 12 -justify right \
    -validate key -validatecommand [list ::validate::integer %P 0]
  ttk::label $f.l2 -text "-" -font $regular
  ttk::entry $f.emax -textvariable sGnumMax -width 12 -justify right \
    -validate key -validatecommand [list ::validate::integer %P 0]
  ttk::label $f.l3 -text " "
  ttk::button $f.all -text [::utils::string::Capital $::tr(all)] -style Pad0.Small.TButton -command {set sGnumMin ""; set sGnumMax ""}
  ttk::menubutton $f.first -style pad0.TMenubutton -textvar ::tr(First...) -menu $f.first.m
  ttk::menubutton $f.last -style pad0.TMenubutton -textvar ::tr(Last...) -menu $f.last.m
  menu $f.first.m
  menu $f.last.m
  foreach x {10 50 100 500 1000 5000 10000} {
    $f.first.m add command -label $x \
        -command "set sGnumMin 1; set sGnumMax $x"
    $f.last.m add command -label $x \
        -command "set sGnumMin -$x; set sGnumMax -1"
  }

  grid $f.l1    -row 0 -column 0 -sticky w
  grid $f.emin  -row 0 -column 1 -sticky w
  grid $f.l2    -row 0 -column 2 -sticky w
  grid $f.emax  -row 0 -column 3 -sticky w
  grid $f.l3    -row 0 -column 4 -sticky w
  grid $f.all   -row 0 -column 5 -sticky w -padx 2
  grid $f.first -row 0 -column 6 -sticky w -padx 2
  grid $f.last  -row 0 -column 7 -sticky w -padx 2

  # ============ VARIANT SECTION ============
  set f [ttk::frame $w.left.variant]
  grid $f -row $mainRow -column 0 -sticky ew -pady "0 5"
  incr mainRow
  grid columnconfigure $f 2 -weight 1

  ttk::label $f.label -text "[tr Variant]:"
  ttk::checkbutton $f.std -text "standard" -variable sVariantStd -offvalue 0 -onvalue 1
  ttk::checkbutton $f.960 -text "960" -variable sVariant960 -offvalue 0 -onvalue 1
  ttk::checkbutton $f.annotated -textvar ::tr(Cmnts) -variable sAnnotated -offvalue 0 -onvalue 1

  grid $f.label     -row 0 -column 0 -sticky w
  grid $f.std       -row 0 -column 1 -sticky w -padx "5 0"
  grid $f.960       -row 0 -column 2 -sticky w -padx "5 0"
  grid $f.annotated -row 0 -column 3 -sticky e

  # ============ TAG PAIR SECTION ============
  set f [ttk::frame $w.left.tagpair]
  grid $f -row $mainRow -column 0 -sticky ew -pady "0 5"
  incr mainRow
  grid columnconfigure $f 3 -weight 1

  ttk::label $f.label1 -text "[tr PgnTag]:"
  ttk::entry $f.tagname -textvariable sTagName -width 20
  ttk::label $f.label2 -text "[tr TagContains]"
  ttk::entry $f.tagvalue -textvariable sTagValue

  grid $f.label1   -row 0 -column 0 -sticky w
  grid $f.tagname  -row 0 -column 1 -sticky w -padx "0 5"
  grid $f.label2   -row 0 -column 2 -sticky w -padx "0 5"
  grid $f.tagvalue -row 0 -column 3 -sticky ew

  # ============ PGN TEXT SECTION ============
  set f [ttk::frame $w.left.pgntext]
  grid $f -row $mainRow -column 0 -sticky ew -pady "0 5"
  incr mainRow

  ttk::label $f.l1 -textvar ::tr(PgnContains:)
  ttk::entry $f.e1 -textvariable sPgntext(1) -width 15
  ttk::label $f.l2 -text "+" -font $regular
  ttk::entry $f.e2 -textvariable sPgntext(2) -width 15
  ttk::label $f.l3 -text "+" -font $regular
  ttk::entry $f.e3 -textvariable sPgntext(3) -width 15

  grid $f.l1 -row 0 -column 0 -sticky w
  grid $f.e1 -row 0 -column 1 -sticky w
  grid $f.l2 -row 0 -column 2 -sticky w
  grid $f.e2 -row 0 -column 3 -sticky w
  grid $f.l3 -row 0 -column 4 -sticky w
  grid $f.e3 -row 0 -column 5 -sticky w

  # ============ FLAGS TOGGLE BUTTON (at bottom of left side) ============
  ttk::button $w.left.flagstoggle -textvar ::tr(FindGamesWith:) -style Pad0.Small.TButton \
    -image tb_menu -compound left -command [list ::search::header::toggleFlags $w]
  grid $w.left.flagstoggle -row $mainRow -column 0 -sticky ew -pady "5 0"

  # ============ FLAGS SECTION (Right Column) ============
  ttk::labelframe $w.flags -text $::tr(FindGamesWith:)

  set row 0
  set col 0
  foreach var [concat $::sHeaderFlagList $::sHeaderCustomFlagList] {
    grid [ttk::label $w.flags.l$var -text [::tr $var] -font font_Small] -row $row -column $col -sticky w
    incr col
    grid [ttk::radiobutton $w.flags.yes$var -variable sHeaderFlags($var) -value yes -text $::tr(Yes)] -row $row -column $col
    incr col
    grid [ttk::radiobutton $w.flags.no$var -variable sHeaderFlags($var) -value no -text $::tr(No)] -row $row -column $col
    incr col
    grid [ttk::radiobutton $w.flags.both$var -variable sHeaderFlags($var) -value both -text $::tr(Both)] -row $row -column $col
    incr col -3
    incr row
  }

  # Add some padding around the flags content
  foreach child [winfo children $w.flags] {
    grid configure $child -padx 2 -pady 1
  }

  # Show flags panel if previously open
  if {$::sHeaderFlagFrame} {
    grid $w.flags -row 0 -column 1 -sticky nsew -padx "5 0"
  }

  #TODO: ref_base should be used instead of curr_db
  set ::curr_db [sc_base current]
  foreach {tagname tagvalue} [sc_base extra $::curr_db] {
    if { $tagvalue ne "" && [regexp {flag([1-6])} $tagname -> i] } {
      $w.flags.lCustomFlag$i configure -text $tagvalue
    }
  }

  return "::search::headerGetOptions"
}

# Toggle the flags panel visibility
proc ::search::header::toggleFlags {w} {
  if {$::sHeaderFlagFrame} {
    set ::sHeaderFlagFrame 0
    grid forget $w.flags
  } else {
    set ::sHeaderFlagFrame 1
    grid $w.flags -row 0 -column 1 -sticky nsew -padx "5 0"
  }
}

proc ::search::headerGetOptions {{cmd ""}} {
	if {[string index $cmd 0] eq "."} {
		set m $cmd.sHeader_presets
		menu $m -postcommand [list apply {{m} {
		    foreach submenu [winfo children $m] { destroy $submenu }
			$m delete 0 end
			$m add command -label [::tr Save] -command "::search::header::savePreset {}"
			$m add separator
			set i 0
			foreach name [array names ::sHeader_PresetFilters] {
				menu $m.i[incr i]
				$m.i$i add command -label [::tr Load] -command "::search::header::loadPreset [list $name]"
				$m.i$i add command -label [::tr Delete] -command "unset [list ::sHeader_PresetFilters($name)]"
				$m add cascade -label $name -menu $m.i$i
			}
		}} $m]
		return [list -menu $m]
	}

	if {$cmd eq "reset"} {
		::search::header::defaults
		return
	}

	::utils::history::AddEntry HeaderSearchWhite $::sWhite
	::utils::history::AddEntry HeaderSearchBlack $::sBlack
	::utils::history::AddEntry HeaderSearchEvent $::sEvent
	::utils::history::AddEntry HeaderSearchSite $::sSite

	set options {header}
	::search::headerPlayerOptions options -white -welo -black -belo

	set invert_col 0
	if {$::sIgnoreCol == "Yes" && [llength $options] > 1} { set invert_col 1 }

	::search::getSearchOptions options
	if {! $invert_col } {
		return [list $options]
	}

	set options2 {header}
	::search::headerPlayerOptions options2 -black -belo -white -welo
	::search::getSearchOptions options2
	return [list $options $options2]
}

proc ::search::getRange {var_min var_max cmd_min cmd_max} {
	if {[set $var_min] ne ""} {
		if {[set $var_max] ne ""} {
			return [list [set $var_min] [set $var_max]]
		}
		return [list [set $var_min] [subst $cmd_max]]
	} elseif {[set $var_max] ne ""} {
		return [list [subst $cmd_min] [set $var_max]]
	}
	return {}
}

proc ::search::headerPlayerOptions {dest_list white welo black belo} {
	upvar $dest_list options

	if {$::sWhite ne ""} { lappend options $white $::sWhite }

	if {$::sBlack ne ""} { lappend options $black $::sBlack	}

	set range [::search::getRange ::sWhiteEloMin ::sWhiteEloMax 0 "\[sc_info limit elo\]"]
	if {$range ne ""} { lappend options $welo $range }

	set range [::search::getRange ::sBlackEloMin ::sBlackEloMax 0 "\[sc_info limit elo\]"]
	if {$range ne ""} { lappend options $belo $range }
}

### Read values from header search dialog. Use empty string as "all"
proc ::search::getSearchOptions {dest_list} {
	upvar $dest_list search

	if {$::sTagName ne "" && $::sTagValue ne ""} {
		set value $::sTagValue
		if {[string match {"*"} $value] || [string match {'*'} $value]} {
			set value [string range $value 1 end-1]
		} else {
			if {[string index $value 0] ne "*"} { set value "*$value" }
			if {[string index $value end] ne "*"} { append value "*" }
		}
		lappend search [list "-tag_pair" $::sTagName $value]
	}

	if {$::sEvent ne ""} { lappend search "-event" $::sEvent }

	if {$::sSite ne ""} { lappend search "-site" $::sSite }

	if {$::sRound ne ""} { lappend search "-round" $::sRound }

	set range [::search::getRange ::sGnumMin ::sGnumMax 0 -1]
	if {$range ne ""} { lappend search "-gnum" $range }

	set range [::search::getRange ::sGlMin ::sGlMax 0 999]
	if {$range ne ""} { lappend search "-length" $range }

	set range [::search::getRange ::sDateMin ::sDateMax "1800.01.01" "\[sc_info limit year\].12.31"]
	if {$range ne ""} { lappend search "-date" $range }

	set range [::search::getRange ::sEventDateMin ::sEventDateMax "1800.01.01" "\[sc_info limit year\].12.31"]
	if {$range ne ""} { lappend search "-eventdate" $range }

	set range [::search::getRange ::sEloDiffMin ::sEloDiffMax "-\[sc_info limit elo\]" "\[sc_info limit elo\]"]
	if {$range ne ""} {
		lappend search "-delo" $range
		if {$::sIgnoreCol == "Yes"} {
			lassign $range elo_min elo_max
			lappend search "-delo|" [list [expr -1 * $elo_max] [expr -1 * $elo_min]]
		}
	}

	set range [::search::getRange ::sEcoMin ::sEcoMax A00 E99]
	if {$range ne ""} {
		lappend search "-eco" $range
		if {$::sEco eq "Yes"} { lappend search "-eco|" [list 0 0] }
	}
	if {$::sEco ne "Yes"} { lappend search "-eco!" [list 0 0] }

	set wtitles {}
	set btitles {}
	foreach i $::sTitleList {
	  if $::sTitles(w:$i) { lappend wtitles $i }
	  if $::sTitles(b:$i) { lappend btitles $i }
	}
	if {[llength $wtitles] != 8} { lappend search -wtitles $wtitles }
	if {[llength $btitles] != 8} { lappend search -btitles $btitles }

	if {$::sSideToMoveW eq "" || $::sSideToMoveB eq ""} {
		lappend search -toMove "$::sSideToMoveW$::sSideToMoveB"
	}

	if {$::sAnnotated} {
		lappend search "-n_comments!" "0"
		lappend search "-n_nags!|" "0"
		lappend search "-n_variations!|" "0"
	}

    if {! $::sVariantStd} { lappend search "-variant!" "std"}
    if {! $::sVariant960} { lappend search "-variant!" "960"}

    global sHeaderFlags
    global sResWin sResLoss sResDraw sResOther sPgntext

    set sPgnlist {}
    foreach i {1 2 3} {
      set temp [string trim $sPgntext($i)]
      if {$temp != ""} { lappend sPgnlist $temp }
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

    set results ""
    append results $sResWin $sResDraw $sResLoss $sResOther
    foreach { i j} { -result! results -flag flagsYes -flag! flagsNo -pgn sPgnlist} {
	if { [llength [set $j]] > 0 } {
	    lappend search $i [set $j]
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
	     lappend search $fCounts($i) $fCountsV($i)
        } elseif  { $sHeaderFlags($i) == "no" } {
             set fCountsV($i) "0"
	     lappend search $fCounts($i) $fCountsV($i)
        }
    }
}

proc ::search::header::loadPreset {name} {
  set scalar_vars {
    sWhite sBlack sEvent sSite sRound sAnnotated
    sDateMin sDateMax sEventDateMin sEventDateMax
    sWhiteEloMin sWhiteEloMax sBlackEloMin sBlackEloMax
    sEloDiffMin sEloDiffMax sGlMin sGlMax
    sGnumMin sGnumMax sEcoMin sEcoMax sEco
    sSideToMoveW sSideToMoveB
    sResWin sResLoss sResDraw sResOther
    sTagName sTagValue sVariantStd sVariant960 sIgnoreCol
  }
  set array_vars {sPgntext sHeaderFlags sTitles}

  array set data $::sHeader_PresetFilters($name)
  foreach var $scalar_vars {
    set ::$var [expr {[info exists data($var)] ? $data($var) : {}}]
  }
  foreach arr $array_vars {
    array unset ::$arr
    array set ::$arr $data($arr)
  }
}

proc ::search::header::savePreset {name} {
  if {$name eq ""} {
    set w .searchHeaderNewPreset
    ::win::createDialog $w
    grid [ttk::label $w.msg -text "New preset filter:"] -row 0 -column 0 -columnspan 2 -sticky ew
    grid [ttk::entry $w.value] -row 1 -column 0 -columnspan 2 -sticky ew
    dialogbutton $w.cancel -text [tr Cancel] -command "destroy $w"
    dialogbutton $w.ok -text "OK" -command [list apply {{w} {
      set value [$w.value get]
      destroy $w
      if {$value ne ""} {
        ::search::header::savePreset $value
      }
    }} $w]
    grid $w.ok -row 2 -column 0 -sticky e -padx 5 -pady 5
    grid $w.cancel -row 2 -column 1 -sticky w -padx 5 -pady 5
    grid columnconfigure $w 0 -weight 1
    grid columnconfigure $w 1 -weight 1
    bind $w <Escape> "$w.cancel invoke"
    bind $w <Return> "$w.ok invoke"
    grab $w
    tk::PlaceWindow $w pointer
    focus $w.value
    tkwait window $w
    return
  }
  set scalar_vars {
    sWhite sBlack sEvent sSite sRound sAnnotated
    sDateMin sDateMax sEventDateMin sEventDateMax
    sWhiteEloMin sWhiteEloMax sBlackEloMin sBlackEloMax
    sEloDiffMin sEloDiffMax sGlMin sGlMax
    sGnumMin sGnumMax sEcoMin sEcoMax sEco
    sSideToMoveW sSideToMoveB
    sResWin sResLoss sResDraw sResOther
    sTagName sTagValue sVariantStd sVariant960 sIgnoreCol
  }
  set array_vars {sPgntext sHeaderFlags sTitles}

  set data {}
  foreach var $scalar_vars {
    if {[set value [set ::$var]] ne ""} {
      lappend data $var $value
    }
  }
  foreach arr $array_vars {
    lappend data $arr [array get ::$arr]
  }
  set ::sHeader_PresetFilters($name) $data
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

  ttk::treeview $w.list -yscrollcommand "$w.ybar set" -columns {0} -show {} -selectmode browse
  $w.list column 0 -width 400
  set i -1
  foreach elem $ecoCommonRanges {
    $w.list insert {} end -id [incr i] -values [list $elem]
  }
  ttk::scrollbar $w.ybar -command "$w.list yview" -takefocus 0
  ttk::frame $w.b

  grid $w.list -row 0 -column 0 -sticky nsew
  grid $w.ybar -row 0 -column 1 -sticky ns
  grid $w.b    -row 1 -column 0 -columnspan 2 -sticky ew

  grid rowconfigure $w 0 -weight 1
  grid columnconfigure $w 0 -weight 1

  ttk::button $w.b.ok -text "OK" -command {
    set sel [.ecoRangeWin.list selection]
    if {[llength $sel] > 0} {
      set scid_ecoRangeChosen [lindex $ecoCommonRanges [lindex $sel 0]]
      set ::sEco No
    }
    destroy .ecoRangeWin
  }
  ttk::button $w.b.cancel -text $::tr(Cancel) -command "destroy $w"

  grid $w.b.ok     -row 0 -column 0 -sticky e -padx 5 -pady 2
  grid $w.b.cancel -row 0 -column 1 -sticky e -padx 5 -pady 2
  grid columnconfigure $w.b 0 -weight 1

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

