### ScidPocket.
### Copyright (C) 2007  Pascal Georges
###
### search/header.tcl: Header Search routines for Scid.
###

namespace eval ::search::header {}

set sWhite "";  set sBlack "";  set sEvent ""; set sSite "";  set sRound ""
set sWhiteEloMin 0; set sWhiteEloMax [sc_info limit elo]
set sBlackEloMin 0; set sBlackEloMax [sc_info limit elo]
set sEloDiffMin "-[sc_info limit elo]"; set sEloDiffMax "+[sc_info limit elo]"
set sTitleList [list gm im fm none wgm wim wfm w]
foreach i $sTitleList {
  set sTitles(w:$i) 1
  set sTitles(b:$i) 1
}
set sGlMin 0; set sGlMax 999
set sEcoMin "A00";  set sEcoMax "E99"; set sEco Yes
set sDateMin "0000.00.00"; set sDateMax "[sc_info limit year].12.31"
set sResWin 1; set sResLoss 1; set sResDraw 1; set sResOther 1
set sGnumMin 1; set sGnumMax -1
set sIgnoreCol No
set sSideToMove wb
set sHeaderFlagList {StdStart Promotions Comments Variations Annotations \
      DeleteFlag WhiteOpFlag BlackOpFlag MiddlegameFlag EndgameFlag \
      NoveltyFlag PawnFlag TacticsFlag KsideFlag QsideFlag \
      BrilliancyFlag BlunderFlag UserFlag
}
foreach i $sHeaderFlagList {
  set sHeaderFlags($i) both
}
set sPgntext(1) ""
set sPgntext(2) ""
set sPgntext(3) ""

trace variable sDateMin w ::utils::validate::Date
trace variable sDateMax w ::utils::validate::Date

foreach i {sWhiteEloMin sWhiteEloMax sBlackEloMin sBlackEloMax} {
  trace variable $i w [list ::utils::validate::Integer [sc_info limit elo] 0]
}
trace variable sEloDiffMin w [list ::utils::validate::Integer "-[sc_info limit elo]" 0]
trace variable sEloDiffMax w [list ::utils::validate::Integer "-[sc_info limit elo]" 0]

trace variable sGlMin w {::utils::validate::Integer 9999 0}
trace variable sGlMax w {::utils::validate::Integer 9999 0}

trace variable sGnumMin w {::utils::validate::Integer -9999999 0}
trace variable sGnumMax w {::utils::validate::Integer -9999999 0}

# Forcing ECO entry to be valid ECO codes:
foreach i {sEcoMin sEcoMax} {
  trace variable $i w {::utils::validate::Regexp {^$|^[A-Ea-e]$|^[A-Ea-e][0-9]$|^[A-Ea-e][0-9][0-9]$|^[A-Ea-e][0-9][0-9][a-z]$|^[A-Ea-e][0-9][0-9][a-z][1-4]$}}
}
################################################################################
#
################################################################################
# checkDates:
#    Checks minimum/maximum search dates in header search window and
#    extends them if necessary.
proc checkDates {} {
  global sDateMin sDateMax
  if {[string length $sDateMin] == 0} { set sDateMin "0000" }
  if {[string length $sDateMax] == 0} { set sDateMax [sc_info limit year]}
  if {[string length $sDateMin] == 4} { append sDateMin ".??.??" }
  if {[string length $sDateMax] == 4} { append sDateMax ".12.31" }
  if {[string length $sDateMin] == 7} { append sDateMin ".??" }
  if {[string length $sDateMax] == 7} { append sDateMax ".31" }
}

proc ::search::header::defaults {} {
  global sWhite sBlack sEvent sSite sRound sDateMin sDateMax sIgnoreCol
  global sWhiteEloMin sWhiteEloMax sBlackEloMin sBlackEloMax
  global sEloDiffMin sEloDiffMax
  global sEco sEcoMin sEcoMax sHeaderFlags sGlMin sGlMax
  global sGnumMin sGnumMax
  global sResWin sResLoss sResDraw sResOther glstart
  global sPgntext sTitles
  
  set sWhite "";  set sBlack ""
  set sEvent ""; set sSite "";  set sRound ""
  set sWhiteEloMin 0; set sWhiteEloMax [sc_info limit elo]
  set sBlackEloMin 0; set sBlackEloMax [sc_info limit elo]
  set sEloDiffMin "-[sc_info limit elo]"
  set sEloDiffMax "+[sc_info limit elo]"
  set sGlMin 0; set sGlMax 999
  set sEcoMin "A00";  set sEcoMax "E99"; set sEco Yes
  set sGnumMin 1; set sGnumMax -1
  set sDateMin "0000.00.00"; set sDateMax "[sc_info limit year].12.31"
  set sResWin 1; set sResLoss 1; set sResDraw 1; set sResOther 1
  set sIgnoreCol No
  set sSideToMove wb
  foreach flag $::sHeaderFlagList { set sHeaderFlags($flag) both }
  foreach i [array names sPgntext] { set sPgntext($i) "" }
  foreach i $::sTitleList {
    set sTitles(w:$i) 1
    set sTitles(b:$i) 1
  }
}

::search::header::defaults

set sHeaderFlagFrame 0
################################################################################
#
################################################################################
# ::search::header
#
#   Opens the window for searching by header information.
#
proc search::header {} {
  global sWhite sBlack sEvent sSite sRound sDateMin sDateMax sIgnoreCol
  global sWhiteEloMin sWhiteEloMax sBlackEloMin sBlackEloMax
  global sEloDiffMin sEloDiffMax sSideToMove
  global sEco sEcoMin sEcoMax sHeaderFlags sGlMin sGlMax sTitleList sTitles
  global sResWin sResLoss sResDraw sResOther glstart sPgntext
  
  set w .sh
  if {[winfo exists $w]} {
    wm deiconify $w
    raiseWin $w
    return
  }
  
  toplevel $w
  wm title $w [::msgcat::mc "Header search"]
  ::ui::setFullSize $w
  
  pack [ttk::notebook $w.nb] -fill both -expand 1
  
  # --------- Exec search -----------------
  $w.nb add [ttk::frame $w.nb.frun] -text [::msgcat::mc "run"]
  
  ttk::button $w.nb.frun.defaults -text [::msgcat::mc "Defaults"] -command ::search::header::defaults
  ttk::button $w.nb.frun.stop -text [::msgcat::mc "Stop"] -command sc_progressBar
  ttk::button $w.nb.frun.search -text [::msgcat::mc "Search"] -command {
    set w .sh
    ::utils::history::AddEntry HeaderSearchWhite $sWhite
    ::utils::history::AddEntry HeaderSearchBlack $sBlack
    ::utils::history::AddEntry HeaderSearchEvent $sEvent
    ::utils::history::AddEntry HeaderSearchSite $sSite
    
    set sPgnlist {}
    foreach i {1 2} {
      set temp [string trim $sPgntext($i)]
      if {$temp != ""} { lappend sPgnlist $temp }
    }
    busyCursor .sh
    grid $w.nb.frun.stop -column 0 -row 4 -sticky ew
    grab $w.nb.frun.stop
    sc_progressBar $w.nb.frun.progress bar 201 21 time
    set wtitles {}
    set btitles {}
    foreach i $sTitleList {
      if $sTitles(w:$i) { lappend wtitles $i }
      if $sTitles(b:$i) { lappend btitles $i }
    }
    
    set str [sc_search header -white $sWhite -black $sBlack \
        -event $sEvent -site $sSite -round $sRound \
        -date [list $sDateMin $sDateMax] \
        -results [list $sResWin $sResDraw $sResLoss $sResOther] \
        -welo [list $sWhiteEloMin $sWhiteEloMax] \
        -belo [list $sBlackEloMin $sBlackEloMax] \
        -delo [list $sEloDiffMin $sEloDiffMax] \
        -eco [list $sEcoMin $sEcoMax $sEco] \
        -length [list $sGlMin $sGlMax] \
        -toMove $sSideToMove \
        -gameNumber [list $sGnumMin $sGnumMax] \
        -flip $sIgnoreCol -filter $::search::filter::operation \
        -fStdStart $sHeaderFlags(StdStart) \
        -fPromotions $sHeaderFlags(Promotions) \
        -fComments $sHeaderFlags(Comments) \
        -fVariations $sHeaderFlags(Variations) \
        -fAnnotations $sHeaderFlags(Annotations) \
        -fDelete $sHeaderFlags(DeleteFlag) \
        -fWhiteOp $sHeaderFlags(WhiteOpFlag) \
        -fBlackOp $sHeaderFlags(BlackOpFlag) \
        -fMiddlegame $sHeaderFlags(MiddlegameFlag) \
        -fEndgame $sHeaderFlags(EndgameFlag) \
        -fNovelty $sHeaderFlags(NoveltyFlag) \
        -fPawnStruct $sHeaderFlags(PawnFlag) \
        -fTactics $sHeaderFlags(TacticsFlag) \
        -fKingside $sHeaderFlags(KsideFlag) \
        -fQueenside $sHeaderFlags(QsideFlag) \
        -fBrilliancy $sHeaderFlags(BrilliancyFlag) \
        -fBlunder $sHeaderFlags(BlunderFlag) \
        -fUser $sHeaderFlags(UserFlag) \
        -pgn $sPgnlist -wtitles $wtitles -btitles $btitles \
        ]
    
    grab release $w.nb.frun.stop
    grid forget $w.nb.frun.stop
    unbusyCursor .sh
    
    tk_messageBox -type ok -icon info -parent .sh -title [::msgcat::mc "Search result"] -message $str
    
    set glstart 1
  }
  
  ttk::button $w.nb.frun.cancel -text [::msgcat::mc "Close"] -command {focus .; destroy .sh}
  grid $w.nb.frun.defaults -column 0 -row 0 -sticky ew
  grid $w.nb.frun.cancel -column 0 -row 1 -sticky ew
  grid $w.nb.frun.search -column 1 -row 1 -sticky ew
  
  canvas $w.nb.frun.progress -height 20 -width 200 -bg white -relief solid -border 1
  $w.nb.frun.progress create rectangle 0 0 0 0 -fill blue -outline blue -tags bar
  $w.nb.frun.progress create text 195 10 -anchor e -tags time -fill black -text "0:00 / 0:00"
  grid $w.nb.frun.progress -column 0 -row 2 -columnspan 2 -pady 2
  
  # ---------------- Players ------------------------
  $w.nb add [ttk::frame $w.nb.fplayer] -text [::msgcat::mc "player"]
  
  foreach frame {cWhite cBlack ignore} { ;# eventsite dateround res gl ends eco
    ttk::frame $w.nb.fplayer.$frame
  }
  
  foreach color {White Black} {
    pack $w.nb.fplayer.c$color -side top -fill x
    ttk::label $w.nb.fplayer.c$color.lab -text "[::msgcat::mc $color]:" -anchor w
    ttk::combobox $w.nb.fplayer.c$color.e -text "s$color"
    ::utils::history::SetCombobox HeaderSearch$color $w.nb.fplayer.c$color.e
    ttk::label $w.nb.fplayer.c$color.elo1 -text "ELO:"
    ttk::entry $w.nb.fplayer.c$color.elomin -text s${color}EloMin -width 6 -justify right
    ttk::label $w.nb.fplayer.c$color.elo2 -text "-"
    ttk::entry $w.nb.fplayer.c$color.elomax -text s${color}EloMax -width 6 -justify right
    
    grid $w.nb.fplayer.c$color.lab -column 0 -row 0
    grid $w.nb.fplayer.c$color.e -column 1 -row 0 -columnspan 3
    
    grid $w.nb.fplayer.c$color.elo1 -column 0 -row 1
    grid $w.nb.fplayer.c$color.elomin -column 1 -row 1
    grid $w.nb.fplayer.c$color.elo2 -column 2 -row 1
    grid $w.nb.fplayer.c$color.elomax -column 3 -row 1
  }
  
  pack $w.nb.fplayer.ignore -side top -fill x
  ttk::label $w.nb.fplayer.ignore.l -text [::msgcat::mc "Ignore colors"]
  ttk::radiobutton $w.nb.fplayer.ignore.yes -variable sIgnoreCol -value Yes -text [::msgcat::mc "Yes"]
  ttk::radiobutton $w.nb.fplayer.ignore.no  -variable sIgnoreCol -value No -text [::msgcat::mc "No"]
  grid $w.nb.fplayer.ignore.l -column 0 -row 0
  grid $w.nb.fplayer.ignore.yes -column 1 -row 0
  grid $w.nb.fplayer.ignore.no -column 2 -row 0
  
  ttk::label $w.nb.fplayer.ignore.rdiff -text [::msgcat::mc "ELO diff:"]
  ttk::entry $w.nb.fplayer.ignore.rdmin -width 6 -text sEloDiffMin -justify right
  ttk::label $w.nb.fplayer.ignore.rdto -text "-"
  ttk::entry $w.nb.fplayer.ignore.rdmax -width 6 -text sEloDiffMax -justify right
  
  grid $w.nb.fplayer.ignore.rdiff -column 0 -row 1
  grid $w.nb.fplayer.ignore.rdmin -column 1 -row 1
  grid $w.nb.fplayer.ignore.rdto -column 2 -row 1
  grid $w.nb.fplayer.ignore.rdmax -column 3 -row 1
  
  # ------------------ Game info (event , site) -------------------------
  $w.nb add [ttk::frame $w.nb.fgame] -text [::msgcat::mc "game"]
  
  foreach frame {eventsite dateround res gl eco} {
    ttk::frame $w.nb.fgame.$frame
  }
  
  set f $w.nb.fgame.eventsite
  pack $f -side top -fill x
  
  foreach i {Event Site} {
    ttk::label $f.l$i -text "[::msgcat::mc $i]:"
    ttk::combobox $f.e$i -text s$i -width 15
    ::utils::history::SetCombobox HeaderSearch$i $f.e$i
  }
  grid $f.lEvent -column 0 -row 0
  grid $f.eEvent -column 1 -row 0
  grid $f.lSite -column 0 -row 1
  grid $f.eSite -column 1 -row 1
  
  set f $w.nb.fgame.dateround
  pack $f -side top -fill x
  pack [ttk::frame $f.f1] [ttk::frame $f.f2] -side top -fill x
  ttk::label $f.f1.l1 -text "[::msgcat::mc Date]:"
  ttk::label $f.f2.l2 -text "-"
  ttk::entry $f.f2.emin -text sDateMin -width 10
  ttk::button $f.f2.eminCal -image ::utils::date::calendar -command {
    regsub -all {[.]} $sDateMin "-" newdate
    set ndate [::utils::date::chooser $newdate]
    if {[llength $ndate] == 3} {
      set sDateMin "[lindex $ndate 0].[lindex $ndate 1].[lindex $ndate 2]"
    }
  }
  ttk::entry $f.f2.emax -text sDateMax -width 10
  ttk::button $f.f2.emaxCal -image ::utils::date::calendar -command {
    regsub -all {[.]} $sDateMax "-" newdate
    set ndate [::utils::date::chooser $newdate]
    if {[llength $ndate] == 3} {
      set sDateMax "[lindex $ndate 0].[lindex $ndate 1].[lindex $ndate 2]"
    }
  }
  bind $f.f2.emin <FocusOut> +checkDates
  bind $f.f2.emax <FocusOut> +checkDates
  ttk::button $f.f1.lyear -text [::msgcat::mc "Last year"] -command {
    set sDateMin "[expr [::utils::date::today year]-1].[::utils::date::today month].[::utils::date::today day]"
    set sDateMax [::utils::date::today]
  }
  
  pack $f.f1.l1 $f.f1.lyear -side left
  pack $f.f2.emin $f.f2.eminCal $f.f2.l2 $f.f2.emax $f.f2.emaxCal -side left
  
  # label $f.lRound -text Round:
  # entry $f.eRound -text sRound -width 10
  # pack $f.eRound $f.lRound -side right
  
  pack $w.nb.fgame.res -side top -fill x
  ttk::label $w.nb.fgame.res.l1 -text "[::msgcat::mc Result]:"
  pack $w.nb.fgame.res.l1 -side left
  foreach i {win draw loss other} v {sResWin sResDraw sResLoss sResOther} text {"1-0 "  "1/2-1/2 "  "0-1 "  "* "} {
    ttk::checkbutton $w.nb.fgame.res.e$i -text $text -variable $v -offvalue 0 -onvalue 1
    pack $w.nb.fgame.res.e$i -side left
  }
  
  ttk::label $w.nb.fgame.gl.l1 -text [::msgcat::mc "Game length:"]
  ttk::label $w.nb.fgame.gl.l2 -text "-"
  ttk::label $w.nb.fgame.gl.l3 -text [::msgcat::mc "Half moves"]
  ttk::entry $w.nb.fgame.gl.emin -textvariable sGlMin -justify right -width 4
  ttk::entry $w.nb.fgame.gl.emax -textvariable sGlMax -justify right -width 4
  pack $w.nb.fgame.gl -side top -fill x
  pack $w.nb.fgame.gl.l1 $w.nb.fgame.gl.emin $w.nb.fgame.gl.l2 $w.nb.fgame.gl.emax $w.nb.fgame.gl.l3 -side left
  
  # label $w.nb.fgame.ends.label -text "End side to move:"
  # frame $w.nb.fgame.ends.sep1 -width 5
  # frame $w.nb.fgame.ends.sep2 -width 5
  # radiobutton $w.nb.fgame.ends.white -text White -variable sSideToMove -value w
  # radiobutton $w.nb.fgame.ends.black -text Black -variable sSideToMove -value b
  # radiobutton $w.nb.fgame.ends.both -text Both -variable sSideToMove -value wb
  # pack $w.nb.fgame.ends.label $w.nb.fgame.ends.white $w.nb.fgame.ends.sep1 \
  # $w.nb.fgame.ends.black $w.nb.fgame.ends.sep2 $w.nb.fgame.ends.both -side left
  # pack $w.nb.fgame.ends -side top -fill x
  
  pack $w.nb.fgame.eco -side top -fill x
  pack [ttk::frame $w.nb.fgame.eco2] -side top -fill x
  
  ttk::label $w.nb.fgame.eco.l1 -text [::msgcat::mc "ECO Code:"]
  ttk::label $w.nb.fgame.eco.l2 -text "-"
  ttk::entry $w.nb.fgame.eco.emin -textvariable sEcoMin -width 5
  ttk::entry $w.nb.fgame.eco.emax -textvariable sEcoMax -width 5
  ttk::button $w.nb.fgame.eco.range -text "..." -command {
    set tempResult [chooseEcoRange]
    if {[scan $tempResult "%\[A-E0-9a-z\]-%\[A-E0-9a-z\]" sEcoMin_tmp sEcoMax_tmp] == 2} {
      set sEcoMin $sEcoMin_tmp
      set sEcoMax $sEcoMax_tmp
    }
    unset tempResult
  }
  ttk::label $w.nb.fgame.eco2.l4 -text [::msgcat::mc "Games without ECO:"]
  ttk::radiobutton $w.nb.fgame.eco2.yes -variable sEco -value Yes -text [::msgcat::mc Yes]
  ttk::radiobutton $w.nb.fgame.eco2.no -variable sEco -value No -text [::msgcat::mc No]
  pack $w.nb.fgame.eco.l1 $w.nb.fgame.eco.emin $w.nb.fgame.eco.l2 $w.nb.fgame.eco.emax $w.nb.fgame.eco.range -side left
  pack $w.nb.fgame.eco2.l4 $w.nb.fgame.eco2.yes $w.nb.fgame.eco2.no -side left
  
  set f [ttk::frame $w.nb.fgame.gnum]
  pack $f -side top -fill x
  ttk::label $f.l1 -text [::msgcat::mc "Game number:"]
  ttk::entry $f.emin -textvariable sGnumMin -width 6 -justify right
  ttk::label $f.l2 -text "-"
  ttk::entry $f.emax -textvariable sGnumMax -width 6 -justify right
  
  ttk::button $f.all -text [::utils::string::Capital all] -command {set sGnumMin 1; set sGnumMax -1}
  pack $f.l1 $f.emin $f.l2 $f.emax $f.all -side left
  
  # menubutton $f.first -text First... -pady 2 -menu $f.first.m -indicatoron 0 -relief raised
  # menubutton $f.last -text Last... -pady 2 -menu $f.last.m -indicatoron 0 -relief raised
  # menu $f.first.m
  # menu $f.last.m
  # foreach x {10 50 100 500 1000 5000 10000} {
  # $f.first.m add command -label $x \
  # -command "set sGnumMin 1; set sGnumMax $x"
  # $f.last.m add command -label $x \
  # -command "set sGnumMin -$x; set sGnumMax -1"
  # }
  # pack $f.first $f.last -side left -padx 2
  
  set f [ttk::frame $w.nb.fgame.pgntext]
  pack $f -side top -fill x
  
  ttk::label $f.l1 -text [::msgcat::mc "Pgn contains:"]
  ttk::entry $f.e1 -textvariable sPgntext(1) -width 20
  ttk::label $f.l2 -text "+"
  ttk::entry $f.e2 -textvariable sPgntext(2) -width 20
  
  grid $f.l1 -column 0 -row 0
  grid $f.e1 -column 1 -row 0
  grid $f.l2 -column 0 -row 1 -sticky e
  grid $f.e2 -column 1 -row 1
  
  # button $w.flagslabel -text "Find games with flags:" -command {
  # set w .sh.sf.scrolled
  # if {$sHeaderFlagFrame} {
  # set sHeaderFlagFrame 0
  # pack forget $w.flags
  # } else {
  # set sHeaderFlagFrame 1
  # pack $w.flags -side top -after $w.flagslabel
  # }
  # }
  # pack $w.flagslabel -side top
  #
  # frame $w.flags
  # if {$::sHeaderFlagFrame} {
  # pack $w.flags -side top
  # }
  #
  # set count 0
  # set row 0
  # set col 0
  #
  # foreach var $::sHeaderFlagList {
  # set lab [label $w.flags.l$var -text $var ]
  # grid $lab -row $row -column $col -sticky e
  # incr col
  # grid [radiobutton $w.flags.yes$var -variable sHeaderFlags($var) \
  # -ind 0 -value yes -text Yes -padx 2 -pady 0 ] \
  # -row $row -column $col
  # incr col
  # grid [radiobutton $w.flags.no$var -variable sHeaderFlags($var) \
  # -ind 0 -value no -text No -padx 2 -pady 0 ] \
  # -row $row -column $col
  # incr col
  # grid [radiobutton $w.flags.both$var -variable sHeaderFlags($var) \
  # -ind 0 -value both -text Both -padx 2 -pady 0 ] \
  # -row $row -column $col
  # incr count
  # incr col -3
  # incr row
  # if {$count == 6} { set col 5; set row 0 }
  # if {$count == 12} { set col 10; set row 0 }
  # }
  # grid [label $w.flags.space -text "" ] -row 0 -column 4
  # grid [label $w.flags.space2 -text "" ] -row 0 -column 9
  
  # ----------------- Filter operation -------------
  ::search::addFilterOpNoteBook $w.nb
  
  # update
  ::search::Config
  
  # focus $w.cWhite.e
}

##############################
### Selecting common ECO ranges

set ecoCommonRanges {
  {A04-A09  Reti: 1.Nf3}
  {A10-A39  English: 1.c4}
  {A40-A49  1.d4, 1.d4 Nf6 Miscellaneous}
  {A45l-A45z  Trompowsky: 1.d4 Nf6 2.Bg5}
  {A51-A52  Budapest: 1.d4 Nf6 2.c4 e5}
  {A53-A55  Old Indian: 1.d4 Nf6 2.c4 d6}
  {A57-A59  Benko Gambit: 1.d4 Nf6 2.c4 c5 3.d5 b5}
  {A60-A79  Modern Benoni: 1.d4 Nf6 2.c4 c5 3.d5 e6}
  {A80-A99  Dutch Defence: 1.d4 f5}
  {____________________________________________________________}
  {B00-C99  1.e4}
  {B01-B01     Scandinavian: 1.e4 d5}
  {B02-B05     Alekhine Defence: 1.e4 Nf6}
  {B07-B09     Pirc: 1.e4 d6}
  {B10-B19     Caro-Kann: 1.e4 c6}
  {B12i-B12z      Caro-Kann: Advance: 1.e4 c6 2.d4 d5 3.e5}
  {B20-B99  Sicilian: 1.e4 c5}
  {B22-B22     Sicilian: Alapin: 1.e4 c5 2.c3}
  {B23-B26     Sicilian: Closed: 1.e4 c5 2.Nc3}
  {B30-B39     Sicilian: 1.e4 c5 2.Nf3 Nc6}
  {B40-B49     Sicilian: 1.e4 c5 2.Nf3 e6}
  {B50-B59     Sicilian Rauzer: 1.e4 c5 2.Nf3 d6 ... 5.Nc3 Nc6}
  {B70-B79     Sicilian Dragon: 1.e4 c5 2.Nf3 d6 ... 5.Nc3 g6}
  {B80-B89     Sicilian Scheveningen: 1.e4 c5 2.Nf3 d6 ... 5.Nc3 e6}
  {B90-B99     Sicilian Najdorf: 1.e4 c5 2.Nf3 d6 ... 5.Nc3 a6}
  {____________________________________________________________}
  {C00-C19  French Defence: 1.e4 e6}
  {C02-C02     French: Advance: 1.e4 e6 2.d4 d5 3.e5}
  {C03-C09     French: Tarrasch: 1.e4 e6 2.d4 d5 3.Nd2}
  {C15-C19     French: Winawer: 1.e4 e6 2.d4 d5 3.Nc3 Bb4}
  {C20-C99  Open Game: 1.e4 e5}
  {C25-C29     Vienna: 1.e4 e5 2.Nc3}
  {C30-C39     King's Gambit: 1.e4 e5 2.f4}
  {C42-C43     Russian Game: 1.e4 e5 2.Nf3 Nf6}
  {C44-C49     Open Game: 1.e4 e5 2.Nf3 Nc6}
  {C50-C59     Italian/Two Knights: 1.e4 e5 2.Nf3 Nc6 3.Bc4}
  {C60-C99  Spanish: 1.e4 e5 2.Nf3 Nc6 3.Bb5}
  {C68-C69      Spanish: Exchange: 3.Bb5 a6 4.Bxc6}
  {C80-C83      Spanish: Open: 3.Bb5 a6 4.Ba4 Nf6 5.O-O Nxe4}
  {C84-C99      Spanish: Closed: 3.Bb5 a6 4.Ba4 Nf6 5.O-O Be7}
  {____________________________________________________________}
  {D00-D99  Queen's Pawn: 1.d4 d5}
  {D10-D19  Slav: 1.d4 d5 2.c4 c6}
  {D20-D29  QGA: 1.d4 d5 2.c4 dxc4}
  {D30-D69  QGD: 1.d4 d5 2.c4 e6}
  {D35-D36     QGD: Exchange: 1.d4 d5 2.c4 e6 3.cxd5 exd5}
  {D43-D49     Semi-Slav: 3.Nc3 Nf6 4.Nf3 c6}
  {D50-D69     QGD with Bg5: 1.d4 d5 2.c4 e6 3.Nc3 Nf6 4.Bg5}
  {D60-D69     QGD: Orthodox: 4.Bg5 Be7 5.e3 O-O 6.Nf3 Nbd7}
  {D70-D99  Grünfeld: 1.d4 Nf6 2.c4 g6 with 3...d5}
  {D85-D89     Grünfeld: Exchange: 3.Nc3 d5 4.e4 Nxc3 5.bxc3}
  {D96-D99     Grünfeld: Russian: 3.Nc3 d5 4.Nf3 Bg7 5.Qb3}
  {____________________________________________________________}
  {E00-E09  Catalan: 1.d4 Nf6 2.c4 e6 3.g3/...}
  {E02-E05     Catalan: Open: 3.g3 d5 4.Bg2 dxc4}
  {E06-E09     Catalan: Closed: 3.g3 d5 4.Bg2 Be7}
  {E12-E19  Queen's Indian: 1.d4 Nf6 2.c4 e6 3.Nf3 b6}
  {E20-E59  Nimzo-Indian: 1.d4 Nf6 2.c4 e6 3.Nc3 Bb4}
  {E32-E39     Nimzo-Indian: Classical: 4.Qc2}
  {E40-E59     Nimzo-Indian: Rubinstein: 4.e3}
  {E60-E99  King's Indian: 1.d4 Nf6 2.c4 g6}
  {E80-E89     King's Indian: Sämisch: 4.e4 d6 5.f3}
  {E90-E99     King's Indian: Main Line: 4.e4 d6 5.Nf3}
}

set scid_ecoRangeChosen ""
################################################################################
#
################################################################################
proc chooseEcoRange {} {
  global ecoCommonRanges scid_ecoRangeChosen
  if {[winfo exists .ecoRangeWin]} { return }
  set w .ecoRangeWin
  toplevel $w
  wm title $w [::msgcat::mc "Choose ECO Range"]
  ::ui::setFullSize $w
  
  listbox $w.list -yscrollcommand "$w.ybar set" -xscrollcommand "$w.xbar set"  ;#-height 20 -width 60 -background white -setgrid 0
  foreach i $ecoCommonRanges { $w.list insert end $i }
  ttk::scrollbar $w.xbar -command "$w.list xview" -takefocus 0  -orient horizontal
  ttk::scrollbar $w.ybar -command "$w.list yview" -takefocus 0
  
  pack [ttk::frame $w.b] -side bottom -fill x
  pack $w.xbar -side bottom -fill x
  pack $w.ybar -side right -fill y
  pack $w.list -side left -fill both -expand yes
  
  ttk::button $w.b.ok -text [::msgcat::mc "OK"] -command {
    set sel [.ecoRangeWin.list curselection]
    if {[llength $sel] > 0} {
      set scid_ecoRangeChosen [lindex $ecoCommonRanges [lindex $sel 0]]
    }
    # focus .
    destroy .ecoRangeWin
  }
  ttk::button $w.b.cancel -text [::msgcat::mc Cancel] -command "destroy $w"
  pack $w.b.cancel $w.b.ok -side right -padx 5 -pady 2
  bind $w <Return> "$w.b.ok invoke; break"
  bind $w.list <Double-ButtonRelease-1> "$w.b.ok invoke; break"
  focus $w.list
  grab $w
  tkwait window $w
  return $scid_ecoRangeChosen
}


###
### End of file: search.tcl

