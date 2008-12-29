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
  global sWhite sBlack sEvent sSite sRound sDateMin sDateMax sIgnoreCol sSideToMove
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
  wm title $w "Scid: $::tr(HeaderSearch)"
  foreach frame {cWhite cBlack ignore tw tb eventsite dateround res gl ends eco} {
    ttk::frame $w.$frame
  }
  
  raise $w
  
  bind $w <F1> { helpWindow Searches Header }
  bind $w <Escape> "$w.b.cancel invoke"
  bind $w <Return> "$w.b.search invoke"
  
  set regular font_Small
  set bold font_SmallBold
  
  foreach color {White Black} {
    pack $w.c$color -side top -fill x
    ttk::label $w.c$color.lab -textvar ::tr($color:) -font $bold -width 9 -anchor w
    ttk::combobox $w.c$color.e -textvariable "s$color" -width 40
    ::utils::history::SetCombobox HeaderSearch$color $w.c$color.e
    bind $w.c$color.e <Return> { .sh.b.search invoke; break }
    
    ttk::label $w.c$color.space
    ttk::label $w.c$color.elo1 -textvar ::tr(Rating:) -font $bold
    ttk::entry $w.c$color.elomin -textvar s${color}EloMin -width 6 -justify right \
        -font $regular
    ttk::label $w.c$color.elo2 -text "-" -font $regular
    ttk::entry $w.c$color.elomax -textvar s${color}EloMax -width 6 -justify right \
        -font $regular
    bindFocusColors $w.c$color.e
    bindFocusColors $w.c$color.elomin
    bindFocusColors $w.c$color.elomax
    pack $w.c$color.lab $w.c$color.e $w.c$color.space -side left
    pack $w.c$color.elomax $w.c$color.elo2 $w.c$color.elomin $w.c$color.elo1 \
        -side right
  }
  
  pack $w.ignore -side top -fill x
  ttk::label $w.ignore.l -textvar ::tr(IgnoreColors:) -font $bold
  ttk::radiobutton $w.ignore.yes -variable sIgnoreCol -value Yes -textvar ::tr(Yes) -style Small.TRadiobutton
  ttk::radiobutton $w.ignore.no  -variable sIgnoreCol -value No -textvar ::tr(No) -style Small.TRadiobutton
  pack $w.ignore.l $w.ignore.yes $w.ignore.no -side left
  ttk::label $w.ignore.rdiff -textvar ::tr(RatingDiff:) -font $bold
  ttk::entry $w.ignore.rdmin -width 6 -textvar sEloDiffMin -justify right -font $regular
  ttk::label $w.ignore.rdto -text "-" -font $regular
  ttk::entry $w.ignore.rdmax -width 6 -textvar sEloDiffMax -justify right -font $regular
  bindFocusColors $w.ignore.rdmin
  bindFocusColors $w.ignore.rdmax
  pack $w.ignore.rdmax $w.ignore.rdto $w.ignore.rdmin $w.ignore.rdiff \
      -side right
  
  set spellstate normal
  if {[lindex [sc_name read] 0] == 0} { set spellstate disabled }
  foreach c {w b} name {White Black} {
    pack $w.t$c -side top -fill x
    ttk::label $w.t$c.label -text "$::tr($name) FIDE:" -font $bold -width 14 -anchor w
    pack $w.t$c.label -side left
    foreach i $sTitleList {
      set name [string toupper $i]
      if {$i == "none"} { set name "-" }
      checkbutton $w.t$c.b$i -text $name -width 5 -font $regular \
          -variable sTitles($c:$i) -offvalue 0 -onvalue 1 -indicatoron 0 \
          -state $spellstate -pady 0
      pack $w.t$c.b$i -side left -padx 1
    }
  }
  
  addHorizontalRule $w
  
  set f $w.eventsite
  pack $f -side top -fill x
  foreach i {Event Site} {
    ttk::label $f.l$i -textvar ::tr(${i}:) -font $bold
    ttk::combobox $f.e$i -textvariable s$i -width 30
    bind $f.e$i <Return> { .sh.b.search invoke ; break }
    ::utils::history::SetCombobox HeaderSearch$i $f.e$i
    bindFocusColors $f.e$i
  }
  pack $f.lEvent $f.eEvent -side left
  pack $f.eSite $f.lSite -side right
  
  set f $w.dateround
  pack $f -side top -fill x
  ttk::label $f.l1 -textvar ::tr(Date:) -font $bold
  ttk::label $f.l2 -text "-" -font $regular
  ttk::label $f.l3 -text " " -font $regular
  ttk::entry $f.emin -textvariable sDateMin -width 10 -font $regular
  button $f.eminCal -image ::utils::date::calendar -padx 0 -pady 0 -command {
    regsub -all {[.]} $sDateMin "-" newdate
    set ndate [::utils::date::chooser $newdate]
    if {[llength $ndate] == 3} {
      set sDateMin "[lindex $ndate 0].[lindex $ndate 1].[lindex $ndate 2]"
    }
  }
  ttk::entry $f.emax -textvariable sDateMax -width 10 -font $regular
  button $f.emaxCal -image ::utils::date::calendar -padx 0 -pady 0 -command {
    regsub -all {[.]} $sDateMax "-" newdate
    set ndate [::utils::date::chooser $newdate]
    if {[llength $ndate] == 3} {
      set sDateMax "[lindex $ndate 0].[lindex $ndate 1].[lindex $ndate 2]"
    }
  }
  bindFocusColors $f.emin
  bindFocusColors $f.emax
  bind $f.emin <FocusOut> +checkDates
  bind $f.emax <FocusOut> +checkDates
  ttk::button $f.lyear -textvar ::tr(YearToToday) -style Pad0.Small.TButton -command {
    set sDateMin "[expr [::utils::date::today year]-1].[::utils::date::today month].[::utils::date::today day]"
    set sDateMax [::utils::date::today]
  }
  
  pack $f.l1 $f.emin $f.eminCal $f.l2 $f.emax $f.emaxCal $f.l3 $f.lyear -side left
  
  ttk::label $f.lRound -textvar ::tr(Round:) -font $bold
  ttk::entry $f.eRound -textvariable sRound -width 10 -font $regular
  bindFocusColors $f.eRound
  pack $f.eRound $f.lRound -side right
  
  addHorizontalRule $w
  
  pack .sh.res -side top -fill x
  ttk::label $w.res.l1 -textvar ::tr(Result:) -font $bold
  pack $w.res.l1 -side left
  foreach i {win draw loss other} \
      v {sResWin sResDraw sResLoss sResOther} \
      text {"1-0 "  "1/2-1/2 "  "0-1 "  "* "} {
        ttk::checkbutton $w.res.e$i -text $text -variable $v -offvalue 0 -onvalue 1
        pack $w.res.e$i -side left
      }
  
  ttk::label $w.gl.l1 -textvar ::tr(GameLength:) -font $bold
  ttk::label $w.gl.l2 -text "-" -font $regular
  ttk::label $w.gl.l3 -textvar ::tr(HalfMoves) -font $regular
  ttk::entry $w.gl.emin -textvariable sGlMin -justify right -width 4 -font $regular
  ttk::entry $w.gl.emax -textvariable sGlMax -justify right -width 4 -font $regular
  bindFocusColors $w.gl.emin
  bindFocusColors $w.gl.emax
  pack $w.gl -in $w.res -side right -fill x
  pack $w.gl.l1 $w.gl.emin $w.gl.l2 $w.gl.emax $w.gl.l3 -side left
  
  ttk::label $w.ends.label -textvar ::tr(EndSideToMove:) -font $bold
  ttk::frame $w.ends.sep1 -width 5
  ttk::frame $w.ends.sep2 -width 5
  ttk::radiobutton $w.ends.white -textvar ::tr(White) -variable sSideToMove -value w
  ttk::radiobutton $w.ends.black -textvar ::tr(Black) -variable sSideToMove -value b
  ttk::radiobutton $w.ends.both -textvar ::tr(Both) -variable sSideToMove -value wb
  pack $w.ends.label $w.ends.white $w.ends.sep1 $w.ends.black $w.ends.sep2 $w.ends.both -side left
  pack $w.ends -side top -fill x
  
  ttk::label $w.eco.l1 -textvar ::tr(ECOCode:) -font $bold
  ttk::label $w.eco.l2 -text "-" -font $regular
  ttk::label $w.eco.l3 -text " " -font $regular
  ttk::label $w.eco.l4 -textvar ::tr(GamesWithNoECO:) -font $bold
  ttk::entry $w.eco.emin -textvariable sEcoMin -width 5 -font $regular
  ttk::entry $w.eco.emax -textvariable sEcoMax -width 5 -font $regular
  bindFocusColors $w.eco.emin
  bindFocusColors $w.eco.emax
  ttk::button $w.eco.range -text "..." -style  Pad0.Small.TButton -width 0 -command {
    set tempResult [chooseEcoRange]
    if {[scan $tempResult "%\[A-E0-9a-z\]-%\[A-E0-9a-z\]" sEcoMin_tmp sEcoMax_tmp] == 2} {
      set sEcoMin $sEcoMin_tmp
      set sEcoMax $sEcoMax_tmp
    }
    unset tempResult
  }
  ttk::radiobutton $w.eco.yes -variable sEco -value Yes -textvar ::tr(Yes) -style Small.TRadiobutton
  ttk::radiobutton $w.eco.no -variable sEco -value No -textvar ::tr(No) -style Small.TRadiobutton
  pack $w.eco -side top -fill x
  pack $w.eco.l1 $w.eco.emin $w.eco.l2 $w.eco.emax $w.eco.range $w.eco.l3 $w.eco.l4 $w.eco.yes $w.eco.no -side left
  
  set f [ttk::frame $w.gnum]
  pack $f -side top -fill x
  ttk::label $f.l1 -textvar ::tr(GlistGameNumber:) -font $bold
  ttk::entry $f.emin -textvariable sGnumMin -width 8 -justify right -font $regular
  ttk::label $f.l2 -text "-" -font $regular
  ttk::entry $f.emax -textvariable sGnumMax -width 8 -justify right -font $regular
  pack $f.l1 $f.emin $f.l2 $f.emax -side left
  bindFocusColors $f.emin
  bindFocusColors $f.emax
  ttk::label $f.l3 -text " " -font $regular
  ttk::button $f.all -text [::utils::string::Capital $::tr(all)] -style Pad0.Small.TButton -command {set sGnumMin 1; set sGnumMax -1}
  ttk::menubutton $f.first -style pad0.TMenubutton -textvar ::tr(First...) -menu $f.first.m
  ttk::menubutton $f.last -style pad0.TMenubutton -textvar ::tr(Last...) -menu $f.last.m
  menu $f.first.m -font $regular
  menu $f.last.m -font $regular
  foreach x {10 50 100 500 1000 5000 10000} {
    $f.first.m add command -label $x \
        -command "set sGnumMin 1; set sGnumMax $x"
    $f.last.m add command -label $x \
        -command "set sGnumMin -$x; set sGnumMax -1"
  }
  pack $f.l3 $f.all $f.first $f.last -side left -padx 2
  
  set f [ttk::frame $w.pgntext]
  pack $f -side top -fill x
  ttk::label $f.l1 -textvar ::tr(PgnContains:) -font $bold
  ttk::entry $f.e1 -textvariable sPgntext(1) -width 15 -font $regular
  ttk::label $f.l2 -text "+" -font $regular
  ttk::entry $f.e2 -textvariable sPgntext(2) -width 15 -font $regular
  ttk::label $f.l3 -text "+" -font $regular
  ttk::entry $f.e3 -textvariable sPgntext(3) -width 15 -font $regular
  bindFocusColors $f.e1
  bindFocusColors $f.e2
  bindFocusColors $f.e3
  pack $f.l1 $f.e1 $f.l2 $f.e2 $f.l3 $f.e3 -side left
  
  addHorizontalRule $w
  
  ttk::button $w.flagslabel -textvar ::tr(FindGamesWith:) -style Pad0.Small.TButton -image bluetriangle -compound left -command {
    if {$sHeaderFlagFrame} {
      set sHeaderFlagFrame 0
      pack forget .sh.flags
    } else {
      set sHeaderFlagFrame 1
      pack .sh.flags -side top -after .sh.flagslabel
    }
  }
  pack $w.flagslabel -side top -fill x
  
  ttk::frame $w.flags
  if {$::sHeaderFlagFrame} {
    pack $w.flags -side top
  }
  
  set count 0
  set row 0
  set col 0
  foreach var $::sHeaderFlagList {
    set lab [ttk::label $w.flags.l$var -textvar ::tr($var) -font font_Small]
    grid $lab -row $row -column $col -sticky e
    incr col
    grid [radiobutton $w.flags.yes$var -variable sHeaderFlags($var) -ind 0 -value yes -text $::tr(Yes) -padx 2 -pady 0 -font font_Small] \
        -row $row -column $col
    incr col
    grid [radiobutton $w.flags.no$var -variable sHeaderFlags($var) -ind 0 -value no -text $::tr(No) -padx 2 -pady 0 -font font_Small] \
        -row $row -column $col
    incr col
    grid [radiobutton $w.flags.both$var -variable sHeaderFlags($var) -ind 0 -value both -text $::tr(Both) -padx 2 -pady 0 -font font_Small] \
        -row $row -column $col
    incr count
    incr col -3
    incr row
    if {$count == 6} { set col 5; set row 0 }
    if {$count == 12} { set col 10; set row 0 }
  }
  grid [ttk::label $w.flags.space -text "" -font $regular] -row 0 -column 4
  grid [ttk::label $w.flags.space2 -text "" -font $regular] -row 0 -column 9
  
  addHorizontalRule $w
  ::search::addFilterOpFrame $w 1
  addHorizontalRule $w
  
  ### Header search: search/cancel buttons
  
  ttk::frame $w.b
  pack $w.b -side top -fill both
  ttk::button $w.b.defaults -textvar ::tr(Defaults) -command ::search::header::defaults ;# -padx 20
  ttk::button $w.b.save -textvar ::tr(Save...) -command ::search::header::save ;# -padx 20
  ttk::button $w.b.stop -textvar ::tr(Stop) -command sc_progressBar
  ttk::button $w.b.search -textvar ::tr(Search) -command { 
    ::utils::history::AddEntry HeaderSearchWhite $sWhite
    ::utils::history::AddEntry HeaderSearchBlack $sBlack
    ::utils::history::AddEntry HeaderSearchEvent $sEvent
    ::utils::history::AddEntry HeaderSearchSite $sSite
    
    set sPgnlist {}
    foreach i {1 2 3} {
      set temp [string trim $sPgntext($i)]
      if {$temp != ""} { lappend sPgnlist $temp }
    }
    busyCursor .
    pack .sh.b.stop -side right -padx 5
    grab .sh.b.stop
    sc_progressBar .sh.fprogress.progress bar 301 21 time
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
    
    grab release .sh.b.stop
    pack forget .sh.b.stop
    unbusyCursor .
    
    .sh.status configure -text $str
    set glstart 1
    ::windows::gamelist::Refresh
    
    ::search::loadFirstGame
    
    ::windows::stats::Refresh
  }
  
  ttk::button $w.b.cancel -textvar ::tr(Close) -command {focus .; destroy .sh} ;# -padx 20
  
  foreach i {defaults save cancel search stop} {
    $w.b.$i configure -style Small.TButton
    
    pack $w.b.defaults $w.b.save -side left -padx 5
    pack $w.b.cancel $w.b.search -side right -padx 5
  }
  
  pack [ ttk::frame $w.fprogress ] -fill both
  canvas $w.fprogress.progress -height 20 -width 300 -bg white -relief solid -border 1
  $w.fprogress.progress create rectangle 0 0 0 0 -fill blue -outline blue -tags bar
  $w.fprogress.progress create text 295 10 -anchor e -font font_Regular -tags time \
      -fill black -text "0:00 / 0:00"
  pack $w.fprogress.progress -side top -pady 2
  ttk::label $w.status -text "" -width 1 -font font_Small -relief sunken -anchor w
  pack $w.status -side bottom -fill x
  # update
  wm resizable $w 0 0
  # standardShortcuts $w
  ::search::Config
  focus $w.cWhite.e
}

proc ::search::header::save {} {
  global sWhite sBlack sEvent sSite sRound sDateMin sDateMax sIgnoreCol
  global sWhiteEloMin sWhiteEloMax sBlackEloMin sBlackEloMax
  global sEloDiffMin sEloDiffMax sGlMin sGlMax
  global sEco sEcoMin sEcoMax sHeaderFlags sSideToMove
  global sResWin sResLoss sResDraw sResOther glstart sPgntext
  
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
  puts $searchF "\# SearchOptions File created by Scid [sc_info version]"
  puts $searchF "set searchType Header"
  
  # First write the regular variables:
  foreach i {sWhite sBlack sEvent sSite sRound sDateMin sDateMax sResWin
    sResLoss sResDraw sResOther sWhiteEloMin sWhiteEloMax sBlackEloMin
    sBlackEloMax sEcoMin sEcoMax sEloDiffMin sEloDiffMax
    sIgnoreCol sSideToMove sGlMin sGlMax ::search::filter::operation} {
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

