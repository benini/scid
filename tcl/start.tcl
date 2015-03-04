#!/bin/sh

# Scid (Shane's Chess Information Database)
#
# Copyright (C) 1999-2004 Shane Hudson
# Copyright (C) 2006-2009 Pascal Georges
# Copyright (C) 2008-2011 Alexander Wagner
# Copyright (C) 2013-2014 Fulvio Benini
#
# Scid is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.

#
# The following few comments are only for Unix versions of Scid:
#

# The "\" at the end of the comment line below is necessary! It means
#   that the "exec" line is a comment to Tcl/Tk, but not to /bin/sh.
# The next line restarts using tkscid: \
exec `dirname $0`/tkscid "$0" "$@"
# exec tkscid "$0" "$@"

# The above launches tkscid from the same directory that this startup
# script was launched from (which feels as a suitable default scenario).
# Alternatively, you can change the top line of this startup script
# to start tkscid directly from a specific location, e.g.:

# For the above to work, tkscid must be in a directory in your PATH.
# Alternatively, you can set the first line to start tkscid directly
# by specifying the full name of tkscid, eg:
# #!/home/myname/bin/tkscid

############################################################

package require Tcl 8.5
package require Tk  8.5
if {$tcl_version == 8.5} { catch {package require img::png} }

set scidVersion [sc_info version]
set scidVersionDate [sc_info version date]
set scidVersionExpected "4.6.0"

# Check that the version of c++ code matches the version of tcl code
#
if {[string compare $::scidVersion $::scidVersionExpected]} {
  wm withdraw .
  set msg "This is Scid version $::scidVersion, but the scid GUI (tcl/tk code)\n"
  append msg "has the version number $scidVersionExpected.\n"
  tk_messageBox -type ok -icon error -title "Scid: Version Error" -message $msg
  exit 1
}

# Determine operating system platform: unix, windows or macos
#
set windowsOS 0
if {$tcl_platform(platform) == "windows"} { set windowsOS 1 }
set unixOS 0
if {$tcl_platform(platform) == "unix"} { set unixOS 1 }
set macOS 0
if {![catch {tk windowingsystem} wsystem] && $wsystem == "aqua"} { set macOS 1 }

proc InitDirs {} {
  global scidExeDir scidUserDir scidConfigDir scidDataDir scidLogDir scidShareDir scidImgDir scidTclDir
  global scidBooksDir scidBasesDir ecoFile

  # scidExeDir: contains the directory of the Scid executable program.
  # Used to determine the location of various relative data directories.
  set scidExecutable [info nameofexecutable]
  if {[file type $scidExecutable] == "link"} {
    set scidExeDir [file dirname [file readlink $scidExecutable]]
    if {[file pathtype $scidExeDir] == "relative"} {
      set scidExeDir [file dirname [file join [file dirname $scidExecutable]\
        [file readlink $scidExecutable]]]
    }
  } else {
    set scidExeDir [file dirname $scidExecutable]
  }

  # scidUserDir: location of user-specific Scid files.
  # This is "~/.scid" on Unix, and the Scid executable dir on Windows.
  if {$::windowsOS} {
    set scidUserDir $scidExeDir
  } else {
    set scidUserDir [file nativename "~/.scid"]
  }

  # scidConfigDir, scidDataDir, scidLogDir:
  # Location of Scid configuration, data and log files.
  set scidConfigDir [file nativename [file join $scidUserDir "config"]]
  set scidDataDir [file nativename [file join $scidUserDir "data"]]
  set scidLogDir [file nativename [file join $scidUserDir "log"]]

  # scidShareDir, scidImgDir, scidTclDir, scidBooksDir, scidBasesDir, ecoFile:
  # Location of Scid resources
  set scidShareDir [file normalize [file join $scidExeDir "../share/scid"]]
  if {! [file isdirectory $::scidShareDir]} {
    set scidShareDir $::scidExeDir
  }
  set scidTclDir [file nativename [file join $scidShareDir "tcl"]]
  if {! [file isdirectory $scidTclDir]} {
    set scidTclDir [file dirname [info script]]
    set scidShareDir [file normalize "$scidTclDir/../"]
  }
  set scidImgDir [file nativename [file join $scidShareDir "img"]]

  #Default values, can be overwritten by file option
  set scidBooksDir [file nativename [file join $scidShareDir "books"]]
  set scidBasesDir [file nativename [file join $scidShareDir "bases"]]
  set ecoFile [file nativename [file join $scidShareDir "scid.eco"]]

  proc moveOldConfigFiles {} {
    # Moves configuration files from the old (3.4 and earlier) names
    # to the new file names used since Scid 3.5.
    global scidUserDir scidConfigDir

    # Since the options file used to be ".scid", rename it:
    if {[file isfile $scidUserDir]} {
      file rename -force $scidUserDir "$scidUserDir.old"
    }

    # Rename old "~/.scid_sent_emails" if necessary:
    if {[file isfile [file nativename "~/.scid_sent_emails"]]} {
      catch {file rename [file nativename "~/.scid_sent_emails"] $email(logfile)}
    }

    foreach {oldname newname} {
      scidrc options.dat
      scid.opt options.dat
      scid.bkm bookmarks.dat
      scid.rfl recentfiles.dat
      engines.lis engines.dat
    } {
      set oldpath [file nativename [file join $scidUserDir $oldname]]
      set newpath [file nativename [file join $scidConfigDir $newname]]
      if {[file readable $oldpath]  &&  ![file readable $newpath]} {
        if {[catch {file rename $oldpath $newpath} err]} {
          tk_messageBox -message "Error moving $oldpath to $newpath: $err"
        }
      }
    }
  }
  moveOldConfigFiles

  # Create the config, data and log directories if they do not exist:
  proc makeScidDir {dir} {
    if {! [file isdirectory $dir]} {
      file mkdir $dir
    }
  }
  makeScidDir $scidUserDir
  makeScidDir $scidConfigDir
  makeScidDir $scidDataDir
  makeScidDir $scidLogDir
}
InitDirs

#############################################################
#
# NAMESPACES
#
# The main Tcl/Tk namespaces used in the Scid application are
# initialized here, so that default values can be set up and
# altered when the user options file is loaded.
#
foreach ns {
  ::splash
  ::utils
  ::utils::date ::utils::font ::utils::history ::utils::pane ::utils::string
  ::utils::sound ::utils::validate ::utils::win
  ::file
  ::file::finder ::file::maint ::maint
  ::bookmarks
  ::edit
  ::game
  ::gbrowser
  ::search
  ::search::filter ::search::board ::search::header ::search::material
  ::windows
  ::windows::gamelist ::windows::stats ::tree ::tree::mask ::windows::tree
  ::windows::switcher ::windows::eco ::crosstab ::pgn ::book
  ::tools
  ::tools::analysis ::tools::email
  ::tools::graphs
  ::tools::graphs::filter ::tools::graphs::absfilter ::tools::graphs::rating ::tools::graphs::score
  ::tb ::optable
  ::board ::move
  ::tacgame ::sergame ::opening ::tactics ::calvar ::uci ::fics ::reviewgame ::novag
  ::config ::docking
  ::pinfo
  ::commenteditor
} {
  namespace eval $ns {}
}

proc ::splash::add {text} {
#TODO: decide what to do with all the splash messages (delete?)
}


####################################################
# Set default values

proc InitDefaultToolbar {} {
  global toolbar
  foreach {tbicon status}  {
    new 0 open 0 save 0 close 0
    finder 0 bkm 0 gprev 0 gnext 0
    cut 0 copy 0 paste 0
    rfilter 0 bsearch 0 hsearch 0 msearch 0
    switcher 0 glist 0 pgn 0 tmt 0 maint 0 eco 0 tree 0 crosst 0 engine 0
  } {
    set toolbar($tbicon) $status
  }
}

proc InitWinsDefaultGeometry {} {
  global winX winY winWidth winHeight

  # Default window locations:
  foreach i {. .pgnWin .helpWin .crosstabWin .treeWin .commentWin .glist
    .playerInfoWin .baseWin .treeBest .treeGraph .tourney .finder
    .ecograph .statsWin .glistWin .maintWin .nedit} {
    set winX($i) -1
    set winY($i) -1
  }

  for {set b [sc_base count total] } {$b > 0} {incr b -1} {
    foreach i { .treeWin .treeBest .treeGraph } {
        set winX($i$b) -1
        set winY($i$b) -1
    }
  }

  # Default window size:
  set winWidth(.) 1024
  set winHeight(.) 570

  # Default PGN window size:
  set winWidth(.pgnWin)  65
  set winHeight(.pgnWin) 20

  # Default help window size:
  set winWidth(.helpWin)  50
  set winHeight(.helpWin) 32

  # Default stats window size:
  set winWidth(.statsWin) 60
  set winHeight(.statsWin) 13

  # Default crosstable window size:
  set winWidth(.crosstabWin)  65
  set winHeight(.crosstabWin) 15

  # Default tree window size:
  set winWidth(.treeWin)  58
  set winHeight(.treeWin) 20

  # Default comment editor size:
  set winWidth(.commentWin)  40
  set winHeight(.commentWin)  6

  # Default spellcheck results window size:
  set winWidth(.spellcheckWin)  55
  set winHeight(.spellcheckWin) 25

  # Default player info window size:
  set winWidth(.playerInfoWin)  45
  set winHeight(.playerInfoWin) 20

  # Default switcher window size:
  set winWidth(.baseWin) 310
  set winHeight(.baseWin) 110

  # Default Correspondence Chess window size:
  set winWidth(.ccWindow) 10
  set winHeight(.ccWindow) 20

  # Default size for input engine console:
  ###---### needs adjustment!
  set winWidth(.inputengineconsole) 10
  set winHeight(.inputengineconsole) 20

  # List of saved layouts : 3 slots available
  set ::docking::layout_list(1) {}
  set ::docking::layout_list(2) {{.pw vertical} {TPanedwindow {{.pw.pw0 horizontal} {TNotebook .nb .fdockmain} {TNotebook .tb1 .fdockpgnWin}}}}
  set ::docking::layout_list(3) {{MainWindowGeometry 1024x542+0+0 zoomed} {{.pw vertical {}} {TPanedwindow {{.pw.pw0 horizontal {}} {TPanedwindow {{.pw.pw0.pw2 vertical 360} {TPanedwindow {{.pw.pw0.pw2.pw6 horizontal 368} {TNotebook .nb .fdockmain} {TPanedwindow {{.pw.pw0.pw2.pw6.pw8 vertical 196} {TNotebook .tb7 .fdockpgnWin} {TNotebook .tb9 .fdockanalysisWin1}}}}} {TPanedwindow {{.pw.pw0.pw2.pw4 horizontal {}} {TNotebook .tb3 .fdockglistWin1}}}}}}}}}
  set ::docking::layout_list(auto) {{MainWindowGeometry 1024x532+0+0} {{.pw vertical {}} {TPanedwindow {{.pw.pw0 horizontal {}} {TPanedwindow {{.pw.pw0.pw2 vertical {}} {TPanedwindow {{.pw.pw0.pw2.pw6 horizontal 413} {TNotebook .nb .fdockmain} {TPanedwindow {{.pw.pw0.pw2.pw6.pw8 vertical 270} {TNotebook .tb7 {.fdockpgnWin .fdockanalysisWin1}} {TNotebook .tb9 .fdockglistWin1}}}}}}}}}}}

}

proc InitDefaultStats {} {
  # Default stats window lines:
  array set ::windows::stats::display {
    r2600 1
    r2500 1
    r2400 1
    r2300 1
    r2200 0
    r2100 0
    r2000 0
    y1900 0
    y1950 0
    y1960 0
    y1970 0
    y1980 0
    y1990 0
    y1995 0
    y2000 1
    y2002 1
    y2004 1
    y2006 1
    y2007 1
    y2008 1
  }

  # Enable stats for subsequent years
  for { set year [clock format [clock seconds] -format {%Y}] } \
    { $year>2008 && ![info exists ::windows::stats::display([subst {y$year}])] } \
    { incr year -1 } {
    set ::windows::stats::display([subst {y$year}]) 1
  }
}

proc InitDefaultFonts {} {
  global fontOptions
  if {$::windowsOS} {
    set fontOptions(Regular) [list Tahoma     9 normal roman]
    set fontOptions(Menu)    [list system     9 normal roman]
    set fontOptions(Small)   [list Tahoma     8 normal roman]
    set fontOptions(Tiny)    [list Arial      7 normal roman]
    set fontOptions(Fixed)   [list courier    9 normal roman]
  } elseif {$::macOS} {
    set fontOptions(Regular) [list system    11 normal roman]
    set fontOptions(Menu)    [list menu      14 normal roman]
    set fontOptions(Small)   [list system    10 normal roman]
    set fontOptions(Tiny)    [list system     9 normal roman]
    set fontOptions(Fixed)   [list Monaco    10 normal roman]
  } else {
    set fontOptions(Regular) [list {DejaVu Sans}       10 normal roman]
    set fontOptions(Menu)    [list {DejaVu Sans}       10 normal roman]
    set fontOptions(Small)   [list {DejaVu Sans}        9 normal roman]
    set fontOptions(Tiny)    [list {DejaVu Sans}        8 normal roman]
    set fontOptions(Fixed)   [list {DejaVu Sans Mono}  10 normal roman]
  }
}

InitDefaultFonts
InitWinsDefaultGeometry
InitDefaultToolbar
InitDefaultStats


#Default textures for lite and dark squares
set boardfile_dark "LightWood3-d"
set boardfile_lite "LightWood3-l"

# boardSize: Default board size.
set boardSize 40

# boardStyle: Default board piece set.
set boardStyle Merida1

# Colors: dark and lite are square colors
#     whitecolor/blackcolor are piece colors
#     highcolor is the color when something is selected.
#     bestcolor is used to indicate a suggested move square.
# set dark        "\#70a070"
# set lite        "\#e0d070"
set lite "\#f3f3f3"
set dark "\#7389b6"
set whitecolor  "\#ffffff"
set blackcolor  "\#000000"
set whiteborder "\#000000"
set blackborder "\#ffffff"
set highcolor   "\#b0d0e0"
set bestcolor   "\#bebebe"
set buttoncolor "\#b0c0d0"
set borderwidth 0

# boardCoords: 1 to show board Coordinates, 0 to hide them.
set boardCoords 0

# autoResizeBoard:
# resize the board to fit the container
set autoResizeBoard 1

# showGameInfo:
# The game info panel below the main board
set showGameInfo 0

# language for help pages and messages:
set language E

# Default theme
set ::lookTheme "default"

# Auto-save options when exiting:
set optionsAutoSave 1

#  Numeric locale: first char is decimal, second is thousands.
#  Example: ".," for "1,234.5" format; ",." for "1.234,5" format.
set locale(numeric) ".,"

# Ask for piece translations (first letter)
set translatePieces 1

# Highlight the last move played
set arrowLastMove 0
set highlightLastMove 1
set highlightLastMoveWidth 2
set highlightLastMoveColor "grey"
set highlightLastMovePattern {} ; # this option is not saved

# Gloss Of Danger
set glossOfDanger 0

# Ask before replacing existing moves: on by default
set askToReplaceMoves 1

# Show suggested moves: on by default
set suggestMoves 1

# Show variations popup window
set showVarPopup 0
set showVarArrows 1

# Keyboard Move entry options:
set moveEntry(On) 1
set moveEntry(AutoExpand) 0
set moveEntry(Coord) 1

# windowsDock:
# if true, most of toplevel windows are dockable and embedded in a main window
# windows can be moves among tabs (drag and drop) or undocked (right-clicking on tab)
set windowsDock 1


set ::tactics::analysisTime 3
set ::tactics::findBestMoveRunning 0
array set ::tactics::findBestMove_History {}

set ::tacgame::threshold 0.9
set ::tacgame::blunderwarning false
set ::tacgame::blunderwarningvalue 0.0
set ::tacgame::levelMin 1200
set ::tacgame::levelMax 2200
set ::tacgame::levelFixed 1500
set ::tacgame::randomLevel 0
set ::tacgame::isLimitedAnalysisTime 1
set ::tacgame::showblunder 1
set ::tacgame::showblundervalue 1
set ::tacgame::showblunderfound 1
set ::tacgame::showmovevalue 1
set ::tacgame::showevaluation 1
set ::tacgame::isLimitedAnalysisTime 1
set ::tacgame::analysisTime 10
set ::tacgame::openingType new
set ::tacgame::chosenOpening 0

# Analysis command: to start chess analysis engine.
set analysisCommand ""
if {$windowsOS} {
  set analysisChoices {wcrafty.exe}
} else {
  set analysisChoices {crafty}
}

set comp(timecontrol) pergame
set comp(seconds) 180
set comp(minutes) 1
set comp(incr) 0
set comp(timeout) 0 ;# disabled by default
set comp(name) "Engine tournament"
set comp(rounds) 2
set comp(showclock) 0
set comp(debug) 1 ; # print info to console
set comp(animate) 1
set comp(firstonly) 0
set comp(ponder) 0
set comp(usebook) 0
set comp(book) {}

# Default Tree sort method:
set tree(order) frequency

### Tree/mask options:
set ::tree::mask::recentMask {}
    
# Defaults for the PGN window:
# if ::pgn::showColor is 1, the PGN text will be colorized.
set ::pgn::showColor 1
set ::pgn::indentVars 1
set ::pgn::indentComments 1
set ::pgn::symbolicNags 1
set ::pgn::moveNumberSpaces 0
set ::pgn::shortHeader 1
set ::pgn::boldMainLine 1
set ::pgn::columnFormat 0
set ::pgn::stripMarks 0
set pgnColor(Header) "\#00008b"
set pgnColor(Main) "\#000000"
set pgnColor(Var) "\#0000ee"
set pgnColor(Nag) "\#ee0000"
set pgnColor(Comment) "\#008b00"
set pgnColor(Current) lightSteelBlue
set pgnColor(Background) "\#ffffff"

# Defaults for FICS
set ::fics::use_timeseal 0
set ::fics::timeseal_exec "timeseal"
set ::fics::port_fics 5000
set ::fics::port_timeseal 5001
set ::fics::login ""
set ::fics::password ""
set ::fics::usedefaultvars 1
set ::fics::findopponent(initTime) 15
set ::fics::findopponent(incTime) 20
set ::fics::findopponent(rated) "rated"
set ::fics::findopponent(color) ""
set ::fics::findopponent(limitrating) 1
set ::fics::findopponent(rating1) 1500
set ::fics::findopponent(rating2) 3000
set ::fics::findopponent(manual) "auto"
set ::fics::findopponent(formula) ""
set ::fics::consolebg     black
set ::fics::consolefg     LimeGreen
set ::fics::consoleheight 10
set ::fics::consolewidth  40
set ::fics::colseeking     coral
set ::fics::colgame        grey70
set ::fics::colgameresult  SlateBlue1
set ::fics::colficspercent khaki1
set ::fics::colficshelpnext blue
set ::fics::server_ip "0.0.0.0"
set ::fics::premoveEnabled 1
set ::fics::playing 0

set ::commenteditor::showboard 1

# default resolvers for player info
set ::pinfo::wikipAPI      "http://de.wikipedia.org/w/api.php?action=query&format=xml"
# Appers PND resolver
set ::pinfo::wikipurl      "http://toolserver.org/~apper/pd/person/pnd-redirect"
# SeeAlso resolver for PND -> WikiPedia
set ::pinfo::SeeAlsoPND2WP "http://ws.gbv.de/seealso/pnd2wikipedia/?format=seealso&id="
# Deutsche NationalBibliothek
set ::pinfo::dnburl        "http://d-nb.info/gnd"
# all other ID resolvers come from [scidConfigFile resolvers]

# Defaults for Novag Citrine
set ::novag::referee "OFF"

# Defaults for serious game training
set ::sergame::isOpening 0
set ::sergame::chosenOpening 0
set ::sergame::chosenEngine 0
set ::sergame::useBook 1
set ::sergame::bookToUse ""
set ::sergame::startFromCurrent 0
set ::sergame::coachIsWatching 0
set ::sergame::timeMode "timebonus"
set ::sergame::depth 3
set ::sergame::movetime 0
set ::sergame::nodes 10000
set ::sergame::ponder 0
set ::uci::uciInfo(wtime3) [expr 5 * 60 * 1000 ]
set ::uci::uciInfo(winc3) [expr 10 * 1000 ]
set ::uci::uciInfo(btime3) [expr 5 * 60 * 1000 ]
set ::uci::uciInfo(binc3) [expr 10 * 1000 ]

# Defaults for initial directories:
set initialDir(base) "."
set initialDir(pgn) "."
set initialDir(book) "."
set initialDir(html) "."
set initialDir(tex)  "."
set initialDir(stm)  "."
set initialDir(report) "."
set initialDir(tablebase1) ""
set initialDir(tablebase2) ""
set initialDir(tablebase3) ""
set initialDir(tablebase4) ""

# Default PGN display options:
set pgnStyle(Tags) 1
set pgnStyle(Comments) 1
set pgnStyle(Vars) 1

# Autoplay and animation delays in milliseconds:
set autoplayDelay 5000
set animateDelay 200

# Blunder Threshold
set blunderThreshold 1.0

# Geometry of windows:
array set geometry {}

# startup:
#   Stores which windows should be opened on startup.
set startup(pgn) 0
set startup(switcher) 0
set startup(tip) 1
set startup(tree) 0
set startup(finder) 0
set startup(crosstable) 0
set startup(gamelist) 0
set startup(stats) 0
set startup(book) 0


# Game information area options:
set gameInfo(photos) 1
set gameInfo(hideNextMove) 0
set gameInfo(showMaterial) 0
set gameInfo(showFEN) 0
set gameInfo(showMarks) 1
set gameInfo(wrap) 0
set gameInfo(fullComment) 0
set gameInfo(showTB) 0
if {[sc_info tb]} { set gameInfo(showTB) 2 }

# Twin deletion options:

array set twinSettings {
  players No
  colors  No
  event   No
  site    Yes
  round   Yes
  year    Yes
  month   Yes
  day     No
  result  No
  eco     No
  moves   Yes
  skipshort  Yes
  setfilter  Yes
  undelete   Yes
  comments   Yes
  variations Yes
  usefilter  No
  delete     Shorter
}
array set twinSettingsDefaults [array get twinSettings]

# Opening report options:
array set optable {
  Stats 1
  Oldest 5
  Newest 5
  Popular 1
  MostFrequent 6
  MostFrequentWhite 1
  MostFrequentBlack 1
  AvgPerf 1
  HighRating 8
  Results 1
  Shortest 5
  ShortestWhite 1
  ShortestBlack 1
  MoveOrders 8
  MovesFrom 1
  Themes 1
  Endgames 1
  MaxGames 500
  ExtraMoves 1
}
array set optableDefaults [array get optable]

# Player report options
array set preport {
  Stats 1
  Oldest 5
  Newest 5
  MostFrequentOpponents 6
  AvgPerf 1
  HighRating 8
  Results 1
  MostFrequentEcoCodes 6
  Themes 1
  Endgames 1
  MaxGames 500
  ExtraMoves 1
}
array set preportDefaults [array get preport]

# Analysis options (Informant values)
# The different threshold values for !? ?? += etc
array set informant {}
set informant("!?") 0.5
set informant("?") 1.5
set informant("??") 3.0
set informant("?!") 0.5
set informant("+=") 0.5
set informant("+/-") 1.5
set informant("+-") 3.0
set informant("++-") 5.5

# Export file options:
set exportFlags(comments) 1
set exportFlags(indentc) 0
set exportFlags(vars) 1
set exportFlags(indentv) 1
set exportFlags(column) 0
set exportFlags(append) 0
set exportFlags(symbols) 1
set exportFlags(htmldiag) 0
set exportFlags(stripMarks) 0
set exportFlags(convertNullMoves) 1
set default_exportStartFile(PGN) {}
set default_exportEndFile(PGN) {}

set default_exportStartFile(LaTeX) {\documentclass[10pt,twocolumn]{article}
  % This is a LaTeX file generated by Scid.
  % You must have the "chess12" package installed to typeset this file.
  
  \usepackage{times}
  \usepackage{a4wide}
  \usepackage{chess}
  \usepackage[T1]{fontenc}
  
  \setlength{\columnsep}{7mm}
  \setlength{\parindent}{0pt}
  
  % Macros for variations and diagrams:
  \newenvironment{variation}{\begin{quote}}{\end{quote}}
  \newenvironment{diagram}{\begin{nochess}}{$$\showboard$$\end{nochess}}
  
  \begin{document}
}
set default_exportEndFile(LaTeX) {\end{document}
}


set default_exportStartFile(HTML) {<html>
  <head><title>Scid export</title></head>
  <body bgcolor="#ffffff">
}
set default_exportEndFile(HTML) {</body>
  </html>
}

foreach type {PGN HTML LaTeX} {
  set exportStartFile($type) $default_exportStartFile($type)
  set exportEndFile($type) $default_exportEndFile($type)
}

# autoRaise: defines whether the "raise" command should be used to raise
# certain windows (like progress bars) when they become obscured.
# Some Unix window managers (e.g. some versions of Enlightenment and sawfish,
# so I have heard) have a bug where the Tcl/Tk "raise" command times out
# and takes a few seconds. Setting autoRaise to 0 will help avoid this.

set autoRaise 1

proc raiseWin {w} {
  global autoRaise
  if {$autoRaise} { raise $w }
  return
}

# autoIconify:
#   Specified whether Scid should iconify all other Scid windows when
#   the main window is iconified. Most people like this behaviour but
#   some window managers send an "UnMap" event when the user switches
#   to another virtual window without iconifying the Scid window so
#   users of such managers will probably want to turn this off.

set autoIconify 1

# Email configuration:
set email(logfile) [file join $scidLogDir "scidmail.log"]
set email(oldlogfile) [file join $scidUserDir "scidmail.log"]
set email(smtp) 1
set email(smproc) "/usr/lib/sendmail"
set email(server) localhost
set email(from) ""
set email(bcc) ""
# Rename old email log file if necessary:
if {[file readable $email(oldlogfile)]  &&  ![file readable $email(logfile)]} {
  catch {file rename $email(oldlogfile) $email(logfile)}
}

### Audio move announcement options:
set ::utils::sound::soundFolder [file nativename [file join $::scidExeDir sounds]]
set ::utils::sound::announceNew 0
set ::utils::sound::announceForward 0
set ::utils::sound::announceBack 0

# Spell-checking file: default is "spelling.ssp".
if {$windowsOS} {
  set spellCheckFile [file join $scidDataDir "spelling.ssp"]
} else {
  set spellCheckFile "/usr/local/share/scid/spelling.ssp"
}

# book configuration
set ::book::lastBook "" ; # book name without extension (.bin)

# Engines list file: -- OLD NAMES, NO LONGER USED
#set engines(file) [file join $scidUserDir "engines.lis"]
#set engines(backup) [file join $scidUserDir "engines.bak"]

# Engines data:
set engines(list) {}
set engines(sort) Time
set engineCoach1 {}
set engineCoach2 {}


# Reversed mouse buttons in mac (::MB2 and ::MB3 are middle and right mouse buttons respectively.):
if { $macOS } {
  set ::MB2 3
  set ::MB3 2
} else {
  set ::MB2 2
  set ::MB3 3
}


# Opening files by drag & drop on Scid icon on Mac
if { $macOS } {
  # Drag & Drop
  set dndisbusy 0
  set isopenBaseready 0
  set dndargs 0
  
  proc dragndrop {args} {
    global dndisbusy
    global isopenBaseready
    global dndargs
    
    # Un-nest arguments:
    set args [join $args]
    
    # Wait for openBase to be ready, if needed.
    if {$isopenBaseready == 0} {
      if {$dndargs != 0} {
        tk_messageBox -type ok -icon info -title "Scid" -message \
            "Please, wait until Scid finish starting up."
        return
      } else {
        # Save file names for later use:
        set dndargs $args
      }
      return
    }
    
    # Are we busy opening files? if so, display message and do nothing
    if {$dndisbusy != 0} {
      tk_messageBox -type ok -icon info -title "Scid" -message \
          "Please, wait until the previou(s) database(s) are opened and try again."
      return
    }
    
    # Un-nest arguments again if Scid opened on drag & drop
    if {$isopenBaseready == 2} {
      # Un-nest arguments:
      set args [join $args]
      set isopenBaseready 1
    }
    
    set dndisbusy 1
    set errmsg ""
    foreach file $args {
      # Email File:
      if {[file extension $file] == ".sem"} {
        #::tools::email
        continue
      }
      # SearchOptions file:
      if {[file extension $file] == ".sso"} {
        set ::fName $file
        if {[catch {uplevel "#0" {source $::fName}} errmsg]} {
          tk_messageBox -title "Scid: Error reading file" -type ok -icon warning \
              -message "Unable to open or read SearchOptions file: $file"
        } else {
          switch -- $::searchType {
            "Material" { ::search::material }
            "Header"   { ::search::header }
            default    { continue }
          }
        }
        continue
      }
      
      # Scid doesn't handle well .sg4 and .sn4 files.
      if {([file extension $file] == ".sg4") || \
            ([file extension $file] == ".sn4")} {
        set eName ".si4"
        set fName [file rootname $file]
        set file "$fName$eName"
      }
      # Scid doesn't handle well .sg3 and .sn3 files.
      if {([file extension $file] == ".sg3") || \
            ([file extension $file] == ".sn3")} {
        set eName ".si3"
        set fName [file rootname $file]
        set file "$fName$eName"
      }
      
      # Check if base is already opened
      if {[sc_base slot $file] != 0} {
        tk_messageBox -type ok -icon info -title "Scid" -message \
            "$file is already opened."
      } else  {
        # All seems good, let's open those files:
        catch {::file::Open $file} errmsg
      }
    }
    set dndisbusy 0
    set dndargs 0
  }
  proc tkOpenDocument {args} {
    after idle [list dragndrop $args]
  }
  rename tkOpenDocument ::tk::mac::OpenDocument
}



# scidConfigFile:
#   Returns the full path and name of a Scid configuration file,
#   given its configuration type.
#
proc scidConfigFile {type} {
  global scidConfigDir

  foreach {cfgtype fname} {
    options "options.dat"
    engines "engines.dat"
    engines.bak "engines.dat"
    recentfiles "recent.dat"
    history "history.dat"
    bookmarks "bookmarks.dat"
    reports "reports.dat"
    optrainer "optrainer.dat"
    resolvers "resolvers.dat"
    xfccstate "xfccstate.dat"
    correspondence "correspondence.dat"
    ExtHardware "hardware.dat"
    treecache "treecache.dat"
  } {
    if { $type == $cfgtype } {
      return [file nativename [file join $scidConfigDir $fname]]
    }
  }

  return -code error "No such config file type: $type"
}

set optionsFile [scidConfigFile options]

################################################################################
#  Load options file. All default values should be set before this point or new saved values will be overwritten by default ones
################################################################################
catch {source $optionsFile}

# Now, if the options file was written by Scid 3.5 or older, it has a lot of
# yucky variable names in the global namespace. So convert them to the new
# namespace variables:
#
proc ConvertOldOptionVariables {} {
  set oldNewNames {
    doColorPgn ::pgn::showColor
    pgnIndentVars ::pgn::indentVars
    pgnIndentComments ::pgn::indentComments
    pgnShortHeader ::pgn::shortHeader
    pgnMoveFont ::pgn::boldMainLine
    pgnMoveNumSpace ::pgn::moveNumberSpaces
    pgnStripMarks ::pgn::stripMarks
    pgnSymbolicNags ::pgn::symbolicNags
    pgnColumn ::pgn::columnFormat
  }
  
  foreach {old new} $oldNewNames {
    if {[info exists ::$old]} {
      set $new [set ::$old]
    }
  }
}

ConvertOldOptionVariables

# Check for old (single-directory) tablebase option:
if {[info exists initialDir(tablebase)]} {
  set initialDir(tablebase1) $initialDir(tablebase)
}

set ::docking::USE_DOCKING $windowsDock

proc createFonts {} {
  foreach name {Regular Menu Small Tiny Fixed} {
    set opts $::fontOptions($name)
    font create font_$name \
      -family [lindex $opts 0] -size [lindex $opts 1] \
      -weight [lindex $opts 2] -slant [lindex $opts 3]
  }

  set fontsize [font configure font_Regular -size]
  set font [font configure font_Regular -family]
  font create font_Bold -family $font -size $fontsize -weight bold
  font create font_BoldItalic -family $font -size $fontsize -weight bold -slant italic
  font create font_Italic -family $font -size $fontsize -slant italic
  font create font_H1 -family $font -size [expr {$fontsize + 8} ] -weight bold
  font create font_H2 -family $font -size [expr {$fontsize + 6} ] -weight bold
  font create font_H3 -family $font -size [expr {$fontsize + 4} ] -weight bold
  font create font_H4 -family $font -size [expr {$fontsize + 2} ] -weight bold
  font create font_H5 -family $font -size [expr {$fontsize + 0} ] -weight bold

  set fontsize [font configure font_Small -size]
  set font [font configure font_Small -family]
  font create font_SmallBold -family $font -size $fontsize -weight bold
  font create font_SmallItalic -family $font -size $fontsize -slant italic
}
createFonts

# Load theme
ttk::style theme use $::lookTheme

# Use default font everywhere
ttk::style configure TLabel -font font_Regular
ttk::style configure TButton -font font_Regular
ttk::style configure TRadiobutton -font font_Regular
ttk::style configure TCheckbutton -font font_Regular
ttk::style configure TMenubutton -font font_Regular
ttk::style configure TCombobox -font font_Regular
ttk::style configure TEntry -font font_Regular
ttk::style configure TNotebook.Tab -font font_Regular

# Style definitions
ttk::style configure Bold.TCheckbutton -font font_Bold
ttk::style configure Small.TCheckbutton -font font_Small

ttk::style configure Small.TButton -font font_Small
ttk::style configure Bold.TButton -font font_Bold
ttk::style configure Pad0.Small.TButton -padding 0

ttk::style configure Small.TRadiobutton -font font_Small
ttk::style configure Regular.TRadiobutton -font font_Regular
ttk::style configure Bold.TRadiobutton -font font_Bold
ttk::style configure SmallBold.TRadiobutton -font font_SmallBold

ttk::style configure pad0.TMenubutton -padding 0 -indicatorwidth 0 -indicatorheight 0  -font font_Small

# font_Regular is the default font for widgets:
option add *Font font_Regular

# Use font_Menu for menu entries:
option add *Menu*Font font_Menu

proc InitImg {} {
	global scidImgDir boardStyle boardStyles textureSquare

	#Set app icon
	set scidIconFile [file nativename [file join $scidImgDir "scid.gif"]]
	if {[file readable $scidIconFile]} {
		wm iconphoto . -default [image create photo -file "$scidIconFile"]
	}

	#Load all img/buttons/_filename_.gif
	set dname [file join $::scidImgDir buttons]
	foreach {fname} [glob -directory $dname *.gif] {
		set iname [string range [file tail $fname] 0 end-4]
		image create photo $iname -file $fname
	}

	#Load all img/buttons/_filename_.png
	set dname [file join $::scidImgDir buttons]
	foreach {fname} [glob -directory $dname *.png] {
		set iname [string range [file tail $fname] 0 end-4]
		image create photo $iname -format png -file $fname
	}

	#Load all img/boards/_filename_.gif
	set textureSquare {}
	set dname [file join $::scidImgDir boards]
	foreach {fname} [glob -directory $dname *.gif] {
		set iname [string range [file tail $fname] 0 end-4]
		image create photo $iname -file $fname
		if {[string range $iname end-1 end] == "-l"} {
			lappend textureSquare [string range $iname 0 end-2]
		}
	}
	
	#Search available piece sets
	set boardStyles {}
	set dname [file join $::scidImgDir pieces]
	foreach {piecetype} [glob -directory $dname *] {
		if {[file isdirectory $piecetype] == 1} {
			lappend boardStyles [file tail $piecetype]
		}
	}

	#Load all img/flags/_filename_.gif
	set dname [file join $::scidImgDir flags]
	foreach {fname} [glob -directory $dname *.gif] {
		set iname [string range [file tail $fname] 0 end-4]
		image create photo $iname -file $fname
	}
}
InitImg

# Set numeric format
sc_info decimal $::locale(numeric)

# Start in the clipbase, if no database is loaded at startup.
sc_base switch clipbase

set tcl_files {
language.tcl
errors.tcl
utils.tcl
utils/date.tcl
utils/font.tcl
utils/graph.tcl
utils/history.tcl
utils/pane.tcl
utils/sound.tcl
utils/string.tcl
utils/tooltip.tcl
utils/validate.tcl
utils/win.tcl
misc/misc.tcl
htext.tcl
file.tcl
file/finder.tcl
file/bookmark.tcl
file/recent.tcl
file/spellchk.tcl
file/maint.tcl
edit.tcl
game.tcl
game/browser.tcl
windows.tcl
windows/gamelist.tcl
windows/pgn.tcl
windows/book.tcl
windows/comment.tcl
windows/eco.tcl
windows/stats.tcl
windows/tree.tcl
windows/crosstab.tcl
windows/pfinder.tcl
windows/tourney.tcl
windows/switcher.tcl
search/search.tcl
search/board.tcl
search/header.tcl
search/material.tcl
contrib/ezsmtp/ezsmtp.tcl
tools/email.tcl
tools/import.tcl
tools/optable.tcl
tools/preport.tcl
tools/pinfo.tcl
tools/analysis.tcl
tools/wbdetect.tcl
tools/graphs.tcl
tools/tablebase.tcl
tools/ptracker.tcl
help/help.tcl
help/tips.tcl
keyboard.tcl
menus.tcl
board.tcl
move.tcl
main.tcl
tools/correspondence.tcl
tools/uci.tcl
end.tcl
tools/tacgame.tcl
tools/sergame.tcl
tools/calvar.tcl
tools/fics.tcl
tools/opening.tcl
tools/tactics.tcl
tools/reviewgame.tcl
utils/metadata.tcl
tools/inputengine.tcl
tools/novag.tcl
utils/bibliography.tcl
}

foreach f $tcl_files {
    source [file nativename [file join $::scidTclDir "$f"]]
}

###
### End of file: start.tcl
