#!/usr/bin/tclsh

# Scid Pocket (C) 2007 - 2008 Pascal Georges
### Based on Scid (C) Shane Hudson
# #############################################################################
# TODO
# gestion de temps Scorpio et Phalanx
# entrainement ouvertures
#
# # BUGS
# highlight des coups après nouvelle position
# #############################################################################

package require Tk
package require msgcat

set profile 0

if {$profile} {
  package require profiler
  ::profiler::init
}

set scidppc_version "Scid Pocket 1.4"

set chan ""
set chanid ""

set WindowsCE 0
set quitPending 0

if { $tcl_platform(os) == "Windows CE" } {
  set WindowsCE 1
  package require wce
}

# ########################### S P L A S H #########################
if { $WindowsCE } {
  set w .splash
  toplevel $w
  set sh [lindex [wm maxsize . ] 1]
  set sh [ expr $sh - [wce captionheight] ]
  set sw [lindex [wm maxsize . ] 0]
  wm geometry $w =+100+100
  wm attributes $w -topmost 1
  label $w.l1 -text [::msgcat::mc "Loading Scid..." ]
  label $w.l2 -text [::msgcat::mc "This may take several seconds" ]
  pack $w.l1 $w.l2
  update
}
proc splashUpdate {msg} {
  if {$::WindowsCE} {
    .splash.l2 configure -text $msg
  }
  update
}
# ##################################################################
splashUpdate [::msgcat::mc "Options" ]

array set options {}
set options(addVariationWithoutAsking) 0
set options(askToReplaceMoves) 1
set options(showTree) 0
set options(showBook) 1
set options(mainBook) "Performance.bin"
set options(showAnalysis) 1
set options(showComments) 1
set options(showVarPopup) 1
set options(scoreOnly) 0
set options(fullBoard) 0
set options(showAnalysisOld) $options(showAnalysis)
set options(showBookOld) $options(showBook)
set options(showLastMove) 1
set options(recentBases) {}
set options(maxRecentBases) 5
set options(multipv) 1
set options(multipv_old) 1
set options(engineUCIFormat) 1
set options(multipvmax) 4
set options(enginehash) 128 ; # in kB
set options(engine1) "toga"
set options(engine2) ""
set options(engineOptimizeSpeed) 1
set options(tournamentRounds) 2
set options(sound) 0
set options(engine_timeMode) "timebonus"
set options(engine_wtime) 5
set options(engine_btime) 5
set options(engine_winc) 10
set options(engine_binc) 10
set options(game_timeMode) "timebonus"
set options(game_wtime) 5
set options(game_btime) 5
set options(game_winc) 10
set options(game_binc) 10
set options(game_fixeddepth) 5
set options(game_fixednodes) 10
set options(game_movetime) 5
set options(game_specificOpening) 0
set options(game_limitElo) 0
set options(game_Elo) 1500
set options(engineExtendedInfo) 0
set options(engine_useBook) 1
set options(game_useBook) 1
set options(game_elapsedGameTime) 1
set options(engine_bookToUse) "Performance.bin"
set options(game_bookToUse) "Performance.bin"
set options(fontAnalysisSize) 7
set options(language) "english"
set options(fics_login) ""
set options(fics_password) ""
set options(fics_initTime) 15
set options(fics_incTime) 20
set options(fics_rated) "rated"
set options(fics_color) "auto"
set options(fics_limitrating) 1
set options(fics_rating1) 1500
set options(fics_rating2) 3000
set options(fics_manual) "auto"
set options(fics_formula) ""
set options(fics_port) 5000
set options(fics_useformula) ""
set options(analyze_time) 10
set options(analyze_threshold) 0.2
set options(analyze_usebook) 1
set options(glaurungAggressiveness) 130
set options(glaurungCowardice) 100
set options(wrap) "word"
set options(pgn_showColor) 1
set options(pgn_symbolicNags) 1
set options(pgn_columnFormat) 0
set options(pgn_moveNumberSpaces) 0

if {! $::WindowsCE} {
  set options(novag_port) "/dev/ttyUSB0"
} else {
  set options(novag_port) "COM8:"
}
set options(novag_sendmovetwice) 1
set options(novag_refereeMode) 1

set options(theme) "clam"

################################################################################
set instalDir [file dirname [info script]]
set initialDir(base) $instalDir

if {$::WindowsCE} {
  set scidConfigFile [file join $instalDir "scid.rc"]
} else {
  set scidConfigFile [file join "/tmp" "scid.rc"]
}
proc loadOptions { } {
  catch {source $::scidConfigFile}
}

splashUpdate [::msgcat::mc "Loading options"]
loadOptions
# The options that should always have their default value at startup
set options(fullBoard) 0
set options(addVariationWithoutAsking) 0
set options(askToReplaceMoves) 1

ttk::style theme use $options(theme)

# ################## L A N G U A G E ##############################
array set locale {}
set locale(english) "en"
set locale(french) "fr"
set locale(spanish) "es"

::msgcat::mclocale $locale($::options(language))
::msgcat::mcload [file join [ file dirname [info script] ] msgs ]

# all engines should be configured here. Format : Name Version Port MultiPv uci/xboard
array set engineconfig {}
set engineconfig(toga)          { Toga        1.2.1a      12933  MultiPV_OK uci }
set engineconfig(glaurung)      { Glaurung    1.2.1       12934  MultiPV_OK uci }
set engineconfig(fruit_21)      { Fruit       2.1         12935  MultiPV_NO uci }
set engineconfig(gambitfruit)   { GambitFruit 1.0Beta4bx  12936  MultiPV_OK uci }
set engineconfig(toga134)       { Toga        1.3.4       12937  MultiPV_OK uci }
set engineconfig(viper01)       { Viper       0.1         12938  MultiPV_OK uci }
set engineconfig(phalanx)       { Phalanx     XXII        12939  MultiPV_NO xboard }
set engineconfig(fruit_231)     { Fruit       2.3.1       12940  MultiPV_OK uci }
set engineconfig(scorpio)       { Scorpio     2.0         12941  MultiPV_NO xboard }
set engineconfig(greko)         { Greko       6.0         12942  MultiPV_OK uci }
set engineconfig(scidlet)       { Scidlet     3.4         12943  MultiPV_NO xboard }
set engineconfig(toga141SE)       { Toga        1.4.1SE       12944  MultiPV_NO uci }

set playMode 0
set tournamentMode 0

proc appQuit {} {
  if {$::profile} {
    set f [open [file join $::instalDir "prof.txt"] w]
    puts $f [::profiler::print]
    close $f
  }
  if {$::quitPending} {return}
  
  if {$::WindowsCE} {
    set answer [tk_messageBox -icon question -parent .fTop -title  [::msgcat::mc "Scid quit"] -type yesno -message  [::msgcat::mc "Do you want to quit Scid ?"] ]
    if {$answer == no} { return }
  }
  
  set ::quitPending 1
  
  catch {::close $::fics::sockchan}
  
  ::engine::unload 1
  if { $::options(engine2) != "" } { ::engine::unload 2 }
  
  for {set i 1} {$i <= [sc_base count]} {incr i} {
    if {[sc_base inUse $i]} {
      sc_base close $i
    }
  }
  
  saveOptions
  
  destroy .
  exit
}

# ##################################################################"
# define screen resolution
if {$::WindowsCE} {
  if {[lindex [wm maxsize . ] 0] > 400} {
    set ::hires 1
  } else  {
    set ::hires 0
  }
} else  {
  set ::hires 0 ;# set this to test QVGA or VGA under Linux
}

# check for sound support
if {$::WindowsCE} {
  if { [catch {package require evodio} ] } {
    set hasSound 0
  } else {
    set hasSound 1
  }
}

#####################################################
splashUpdate [::msgcat::mc "Loading DLL"]

if { $WindowsCE } {
  load [file join $instalDir "tkscid.dll"]
} else {
  puts [load "../tkscid.so"]
}

#################### load TCL files ##################
splashUpdate [::msgcat::mc "Loading TCL" ]
if {$WindowsCE} {
  source [file join $instalDir core.tcl]
} else  {
  source core.tcl
}

::board::setLang
::ui::setTheme

# set the UI priority to engine's -1
sc_info pocket_priority 250

#######################################################
splashUpdate [::msgcat::mc "User interface"]
board::init
splashUpdate [::msgcat::mc "User interface : board"]
infopanel::init
splashUpdate [::msgcat::mc "User interface : infopanel"]
ui::updateMenus
splashUpdate [::msgcat::mc "User interface : menus"]
# wm deiconify .

splashUpdate [::msgcat::mc "Engine #1 init"]
engine::init 1
splashUpdate [::msgcat::mc "Engine #2 init"]
engine::init 2
engine::setHash

sc_base switch clipbase
sc_game new

bind .fTop <Destroy> { appQuit }
wm protocol . WM_DELETE_WINDOW { appQuit }

destroy .splash

tkwait window .fTop
