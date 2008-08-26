#!/bin/sh

# Scid (Shane's Chess Information Database)
#
# Copyright (C) 1999-2004  Shane Hudson. All rights reserved.
#
# This is freely redistributable software; see the file named "COPYING"
# or "copying.txt" that came with this program.
#
# To contact the current maintainer of Scid, email to pascal.georges1@free.fr
# Scid's current version is an enhanced version of the original Scid, the author of which is
# Shane Hudson. His email is sgh@users.sourceforge.net

#
# The following few comments are only for Unix versions of Scid:
#

# The "\" at the end of the comment line below is necessary! It means
#   that the "exec" line is a comment to Tcl/Tk, but not to /bin/sh.
# The next line restarts using tkscid: \
exec tkscid "$0" "$@"

# For the above to work, tkscid must be in a directory in your PATH.
# Alternatively, you can set the first line to start tkscid directly
# by specifying the full name of tkscid, eg:
# #!/home/myname/bin/tkscid

############################################################

# Alter the version if any patches have been made to the Tcl code only:
set scidVersion "3.6.25"
set scidVersionDate "DEV 2008"

# Set to 0 before releasing, so some alpha-state code is not included
# Set to 1 to have access to all code
set NOT_FOR_RELEASE 0

package require Tcl 8.4
package require Tk  8.4

# Determine operating system platform: unix or windows
#
set windowsOS 0
if {$tcl_platform(platform) == "windows"} { set windowsOS 1 }
set unixOS 0
if {$tcl_platform(platform) == "unix"} { set unixOS 1 }

# A lot of code assumes tcl_platform is either windows or unix, so
# lotsa stuff may break if this is not the case.
#
if {(! $windowsOS)  &&  (! $unixOS)} {
  # What to do here? Warn the user...?
}


# Check that on Unix, the version of tkscid matches the version of this
# script or on Windows, that the scid.exe and scid.gui versions are identical.
#
if {[string compare [sc_info version] $scidVersion]} {
  wm withdraw .
  if {$windowsOS} {
    set msg "This is Scid version [sc_info version], but the scid.gui data\n"
    append msg "file has the version number $scidVersion.\n"
  } else {
    set msg "This program,\n\"$argv0\",\nis version $scidVersion,\nbut the "
    append msg "tkscid program \nit uses is version [sc_info version].\n"
    append msg "Check that the path to tkscid is correct."
  }
  tk_messageBox -type ok -icon error -title "Scid: Version Error" -message $msg
  exit 1
}

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
  ::windows::gamelist ::windows::stats ::tree ::windows::tree
  ::windows::switcher ::windows::eco ::crosstab ::pgn ::book
  ::tools
  ::tools::analysis ::tools::email
  ::tools::graphs
  ::tools::graphs::filter ::tools::graphs::absfilter ::tools::graphs::rating ::tools::graphs::score
  ::tb ::optable
  ::board ::move
  ::tacgame ::sergame ::opening ::tactics ::calvar ::uci ::fics
  ::config
} {
  namespace eval $ns {}
}


#############################################################
# Customisable variables:

# scidExeDir: contains the directory of the Scid executable program.
# Used to determine the location of various relative data directories.
set scidExecutable [info nameofexecutable]
if {[file type $scidExecutable] == "link"} {
  set scidExeDir [file dirname [file readlink $scidExecutable]]
} else {
  set scidExeDir [file dirname $scidExecutable]
}

# scidUserDir: location of user-specific Scid files.
# This is "~/.scid" on Unix, and the Scid exectuable dir on Windows.
if {$windowsOS} {
  set scidUserDir $scidExeDir
} else {
  set scidUserDir [file nativename "~/.scid"]
}

# scidConfigDir, scidDataDir, scidLogDir:
#   Location of Scid configuration, data and log files.
set scidConfigDir [file nativename [file join $scidUserDir "config"]]
set scidDataDir [file nativename [file join $scidUserDir "data"]]
set scidLogDir [file nativename [file join $scidUserDir "log"]]

# boardSizes: a list of the available board sizes.
set boardSizes [list 25 30 35 40 45 50 55 60 65 70 80]
set boardSizesOLD [list 21 25 29 33 37 40 45 49 54 58 64 72]

#load textures for lite and dark squares
set boardfile_dark "emptySquare"
set boardfile_lite "emptySquare"

#[file join $scidExeDir "bitmaps" "empty.gif"] ;# wsquare.gif

# boardSize: Default board size. See the available board sizes above.
set boardSize 40

# boardStyle: Default board piece set. See bitmaps.tcl for styles.
set boardStyle Eboard

# language for help pages and messages:
set language E
set oldLang X

# Toolbar configuration:
foreach {tbicon status}  {
  new 1 open 1 save 1 close 1
  finder 1 bkm 1 gprev 1 gnext 1
  cut 0 copy 0 paste 0
  rfilter 1 bsearch 1 hsearch 1 msearch 1
  switcher 1 glist 1 pgn 1 tmt 1 maint 1 eco 1 tree 1 crosst 1 engine 1
} {
  set toolbar($tbicon) $status
}

# boardCoords: 1 to show board Coordinates, 0 to hide them.
set boardCoords 0

# boardSTM: 1 to show side-to-move icon, 0 to hide it.
set boardSTM 1

# Default values for fonts:
proc createFont {name} {
  set opts $::fontOptions($name)
  font create font_$name \
      -family [lindex $opts 0] -size [lindex $opts 1] \
      -weight [lindex $opts 2] -slant [lindex $opts 3]
}

proc configureFont {name} {
  set opts $::fontOptions($name)
  font configure font_$name \
      -family [lindex $opts 0] -size [lindex $opts 1] \
      -weight [lindex $opts 2] -slant [lindex $opts 3]
}

if {$windowsOS} {
  set fontOptions(Regular) [list Arial           10 normal roman]
  set fontOptions(Menu)    [list {MS Sans Serif}  9 normal roman]
  set fontOptions(Small)   [list Arial            9 normal roman]
  set fontOptions(Tiny)    [list Arial            8 normal roman]
  set fontOptions(Fixed)   [list Courier          9 normal roman]
} else {
  set fontOptions(Regular) [list helvetica 11 normal roman]
  set fontOptions(Menu)    [list helvetica 10 normal roman]
  set fontOptions(Small)   [list helvetica 10 normal roman]
  set fontOptions(Tiny)    [list helvetica  9 normal roman]
  set fontOptions(Fixed)   [list fixed     10 normal roman]
}

createFont Regular
createFont Menu
createFont Small
createFont Tiny
createFont Fixed

# Analysis command: to start chess analysis engine.
set analysisCommand ""
if {$windowsOS} {
  set analysisChoices {wcrafty.exe}
} else {
  set analysisChoices {crafty}
}

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
set borderwidth 1

set ::tactics::analysisTime 3

# Defaults for the PGN window:
# if ::pgn::showColor is 1, the PGN text will be colorized.
set ::pgn::showColor 1
set ::pgn::indentVars 1
set ::pgn::indentComments 1
set ::pgn::symbolicNags 1
set ::pgn::moveNumberSpaces 0
set ::pgn::shortHeader 0
set ::pgn::boldMainLine 1
set ::pgn::columnFormat 0
set ::pgn::stripMarks 0
set pgnColor(Header) "\#00008b"
set pgnColor(Main) "\#000000"
set pgnColor(Var) "\#0000ee"
set pgnColor(Nag) "\#ee0000"
set pgnColor(Comment) "\#008b00"
set pgnColor(Current) lightSteelBlue
set pgnColor(NextMove) "\#fefe80"
set pgnColor(Background) "\#ffffff"

array set findopponent {}
set ::fics::use_timeseal 1
set ::fics::timeseal_exec "timeseal"
set ::fics::port_fics 5000
set ::fics::port_timeseal 5001
set ::fics::login ""
set ::fics::password ""
set ::fics::findopponent(initTime) 15
set ::fics::findopponent(incTime) 20
set ::fics::findopponent(rated) "rated"
set ::fics::findopponent(color) ""
set ::fics::findopponent(limitrating) 1
set ::fics::findopponent(rating1) 1500
set ::fics::findopponent(rating2) 3000
set ::fics::findopponent(manual) "auto"
set ::fics::findopponent(formula) ""

# Defaults for initial directories:
set initialDir(base) "."
set initialDir(book) "."
set initialDir(epd) "."
set initialDir(html) "."
set initialDir(tex)  "."
set initialDir(report) "."
set initialDir(tablebase1) ""
set initialDir(tablebase2) ""
set initialDir(tablebase3) ""
set initialDir(tablebase4) ""

# glistSize: Number of games displayed in the game list window
set glistSize 15

# glexport: Format for saving Game List to text file.
set glexportDefault "g6: w13 W4  b13 B4  r3:m2 y4 s11 o4"
set glexport $glexportDefault

# glistSelectPly: The number of moves to display in a game list entry
# when that entry is selected with button-2 to shoe the first moves
# of a game. E.g., a value of 4 might give: "1.e4 e5 2.Nf3 Nc6".
set glistSelectPly 80


# Default window locations:
foreach i {. .pgnWin .helpWin .crosstabWin .treeWin .commentWin .glist \
      .playerInfoWin .baseWin .treeBest .treeGraph .tourney .finder \
      .ecograph .statsWin .glistWin .maintWin .nedit} {
  set winX($i) -1
  set winY($i) -1
}

for {set b 1} {$b<=[sc_base count total]} {incr b} {
  foreach i { .treeWin .treeBest .treeGraph } {
    set winX($i$b) -1
    set winY($i$b) -1
  }
}

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

# Default PGN display options:
set pgnStyle(Tags) 1
set pgnStyle(Comments) 1
set pgnStyle(Vars) 1


# Default Tree sort method:
set tree(order) frequency

# Auto-save tree cache when closing tree window:
set tree(autoSave) 0

# Auto-save options when exiting:
set optionsAutoSave 1

#  Numeric locale: first char is decimal, second is thousands.
#  Example: ".," for "1,234.5" format; ",." for "1.234,5" format.
set locale(numeric) ".,"

# Ask for piece translations (first letter)
set translatePieces 1

# Ask before replacing existing moves: on by default
set askToReplaceMoves 1

# Show suggested moves: on by default
set suggestMoves 1

# Show variations popup window
set showVarPopup 1

# Keyboard Move entry options:
set moveEntry(On) 1
set moveEntry(AutoExpand) 0
set moveEntry(Coord) 1

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

# glistFields: Layout of the GameList window fields.
#    element 0: code (e.g. g for gameNumber, w for White name)
#    element 1: initial width, in characters
#    element 2: justification (left or right)
#    element 3: color
#    element 4: true if a separator field should follow
#
#    Note that the "g" (game number) field MUST appear somewhere,
#    but the fields can be in any order.
#    See the comments at the start of the function "PrintGameInfo" in
#    src/index.cpp for a list of available field codes.
#
set glistFields {
  { g  7 right black      1 }
  { w 14 left  darkBlue   0 }
  { W  5 right darkGreen  1 }
  { b 14 left  darkBlue   0 }
  { B  5 right darkGreen  1 }
  { e 10 left  black      0 }
  { s 10 left  black      0 }
  { n  2 right black      1 }
  { d  7 left  darkRed    1 }
  { r  3 left  blue       0 }
  { m  3 right black      1 }
  { o  5 left  darkGreen  0 }
  { O  6 left  darkGreen  1 }
  { D  1 left  darkRed    0 }
  { U  2 left  blue       1 }
  { V  2 right blue       0 }
  { C  2 right blue       0 }
  { A  2 right blue       0 }
  { S  1 left  darkRed    0 }
}

set glistDefaultFields $glistFields
set glistAllFields $glistFields
lappend glistAllFields { c  3 left  black      0 }
lappend glistAllFields { E  7 left  darkRed    0 }
lappend glistAllFields { F  7 left  darkBlue   0 }

# myPlayerNames:
#   List of player name patterns for which the chessboard should be
#   flipped each time a game is loaded to show the board from that
#   players perspective.
#
set myPlayerNames {}


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


# ::windows::switcher::vertical
#
#   If 1, Switcher frames are arranged vertically.
#
set ::windows::switcher::vertical 0
set ::windows::switcher::icons 1

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

# Engines list file: -- OLD NAMES, NO LONGER USED
#set engines(file) [file join $scidUserDir "engines.lis"]
#set engines(backup) [file join $scidUserDir "engines.bak"]

# Engines data:
set engines(list) {}
set engines(sort) Time
set engineCoach1 {}
set engineCoach2 {}

# Set up Scid icon in Windows:
if {$::windowsOS} {
  # Look in each of the following directories for a file named scid.ico:
  set iconFileDirs [list \
      $scidExeDir $scidUserDir $scidConfigDir [file join $scidExeDir "src"]]
  
  foreach iconFileDir $iconFileDirs {
    set scidIconFile [file join $iconFileDir "scid.ico"]
    if {[file readable $scidIconFile]} {
      catch {wm iconbitmap . -default $scidIconFile}
    }
  }
}

# Add empty updateStatusBar proc to avoid errors caused by early
# closing of the splash window:
#
proc updateStatusBar {} {}

# Start up splash screen:

set ::splash::autoclose 1

proc ::splash::make {} {
  wm withdraw .
  set w [toplevel .splash]
  wm withdraw $w
  wm protocol $w WM_DELETE_WINDOW [list wm withdraw $w]
  wm title $w "Welcome to Scid $::scidVersion"
  frame $w.f
  frame $w.b
  text $w.t -height 15 -width 60 -cursor top_left_arrow \
      -background white -font font_Regular -wrap word \
      -yscrollcommand [list $w.ybar set] -setgrid 1
  scrollbar $w.ybar -command [list $w.t yview]
  checkbutton $w.auto -text "Auto-close after startup" \
      -variable ::splash::autoclose -font font_Small -pady 5 -padx 5
  button $w.dismiss -text Close -width 8 -command [list wm withdraw $w] \
      -font font_Small
  pack $w.f -side top -expand yes -fill both
  pack $w.b -side top -fill x
  pack $w.auto -side left -in .splash.b -pady 2 -ipadx 10 -padx 10
  pack $w.dismiss -side right -in .splash.b -pady 2 -ipadx 10 -padx 10
  pack $w.ybar -in $w.f -side right -fill y
  pack $w.t -in $w.f -side left -fill both -expand yes
  
  # Centre the splash window:
  update idletasks
  set x [expr {[winfo screenwidth $w]/2 - [winfo reqwidth $w]/2 \
        - [winfo vrootx .]}]
  set y [expr {[winfo screenheight $w]/2 - [winfo reqheight $w]/2 \
        - [winfo vrooty .]}]
  wm geom $w +$x+$y
  wm deiconify $w
  
  bind $w <F1> {helpWindow Index}
  bind $w <Escape> {.splash.dismiss invoke}
  
  $w.t tag configure indent -lmargin2 20
  
  $w.t image create end -image splash
  $w.t insert end "Shane's Chess Information Database"
}


# Old Scid logo:
image create photo splash -format gif -data \
    "R0lGODdhZgAmAMIAAP///6CBUNHBoQAAcAAAAFK4bgAAAAAAACwAAAAAZgAmAAAD/gi63P4w
ykkrDThjwTvXmueBmdiRmymggbqirqawMazSt23iuy7KAN7PNyKejB/ki1TDzJTCIjM37VWH
moFWiw08r1JQU0wlW83YrXrQ/ZrX8NQ5VKbPSzn4th2E6f9sd3JddoR4PYB8LIB/dYeGg2GF
knB8KokccWBHm0mdS2gCmo8KJn+Da1Cqn1Gjg6Uieo+prKoEt4+Sua4tHbAdp6hqq6Ent8eR
nKG8Hr+ZssJbRMG9JsfX1YZrosy+ALHQ2dxaNozSLtfITea0pN8ejOLKWex7Kum4NfXDhc7P
mJAaBdCDDp+8f2oKgOPnjkS9YsHGtcuADxmKSqAGbgvj/gbDvgG5JPITKU1DRWwgCGbEqKyj
x4/iqJEkZ/IkrpQbV+b05KWPw48L280kYfNmBpU61Sgqtw9eOIRsiBbFmZOqvZY+0dRzOmoM
xZM/q9JTyjHrpJk5ZToKYDMs2aRXebpMBjXtU0dFCVi9ujcQ1qBMRzXiOSnvLa4Mg9J0B3gK
tcEZHxk+BgyaYpD93lUuSSecRpVCJh+uS/MyGn8TU3hmFFljB9EENscxnVkxE2ovcX8OBHs0
Wi6kT2uuO5ZXbqACescm/bA24qYXPwJX/hwm4+rmCJdAnrz3CNa/X5k9DuisJ/BLlNtJjQlI
lHkhtdNtfZC+1/ig5tZ/L38/GjHz9pWh333z8RegIP7V4oQFDDbo4IMQLpAAADs="

# New Scid logo:
image create photo splash -format gif -data {
  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
  eoGp4WkYkYCVQ6MQF/MBwZAr3xkQADs=
}

::splash::make

proc ::splash::add {text} {
  if {! [winfo exists .splash]} {return}
  .splash.t configure -state normal
  .splash.t insert end "\n$text" indent
  .splash.t see end
  .splash.t configure -state disabled
  update
}

::splash::add "Copyright (C) 1999-2004 Shane Hudson  (sgh@users.sourceforge.net)"
::splash::add "Copyright (C) 2006-2008 Pascal Georges  (pascal.georges1@free.fr)"
::splash::add "This is Scid $::scidVersion, released $::scidVersionDate."
::splash::add "Website: scid.sourceforge.net\n"

# Remember old font settings before loading options file:
set fontOptions(oldRegular) $fontOptions(Regular)
set fontOptions(oldMenu) $fontOptions(Menu)
set fontOptions(oldSmall) $fontOptions(Small)
set fontOptions(oldTiny) $fontOptions(Tiny)
set fontOptions(oldFixed) $fontOptions(Fixed)

# New configuration file names:
set scidConfigFiles(options) "options.dat"
set scidConfigFiles(engines) "engines.dat"
set scidConfigFiles(engines.bak) "engines.dat"
set scidConfigFiles(recentfiles) "recent.dat"
set scidConfigFiles(history) "history.dat"
set scidConfigFiles(bookmarks) "bookmarks.dat"
set scidConfigFiles(reports) "reports.dat"
set scidConfigFiles(optrainer) "optrainer.dat"

# scidConfigFile:
#   Returns the full path and name of a Scid configuration file,
#   given its configuration type.
#
proc scidConfigFile {type} {
  global scidConfigDir scidConfigFiles
  if {! [info exists scidConfigFiles($type)]} {
    return -code error "No such config file type: $type"
  }
  return [file nativename [file join $scidConfigDir $scidConfigFiles($type)]]
}

# Create user ".scid" directory in Unix if necessary:
# Since the options file used to be ".scid", rename it:
if {! [file isdirectory $scidUserDir]} {
  if {[file isfile $scidUserDir]} {
    catch {file rename -force $scidUserDir "$scidUserDir.old"}
  }
  if {[catch {file mkdir $scidUserDir} err]} {
    ::splash::add "Error creating ~/.scid directory: $err"
  } else {
    catch {file rename "$scidUserDir.old" $optionsFile}
  }
  # Rename old "~/.scid_sent_emails" if necessary:
  if {[file isfile [file nativename "~/.scid_sent_emails"]]} {
    catch {file rename [file nativename "~/.scid_sent_emails"] $email(logfile)}
  }
}

# Create the config, data and log directories if they do not exist:
proc makeScidDir {dir} {
  if {! [file isdirectory $dir]} {
    if {[catch {file mkdir $dir} err]} {
      ::splash::add "Error creating directory $dir: $err"
    } else {
      ::splash::add "Created directory: $dir"
    }
  }
}

makeScidDir $scidConfigDir
makeScidDir $scidDataDir
makeScidDir $scidLogDir

# Rename old email log file if necessary:
if {[file readable $email(oldlogfile)]  &&  ![file readable $email(logfile)]} {
  catch {file rename $email(oldlogfile) $email(logfile)}
}

# moveOldConfigFiles
#   Moves configuration files from the old (3.4 and earlier) names
#   to the new file names used since Scid 3.5.
#
proc moveOldConfigFiles {} {
  global scidUserDir scidConfigDir
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
        ::splash::add "Error moving $oldpath to $newpath: $err"
      } else {
        ::splash::add "Moved old config file $oldname to $newpath"
      }
    }
  }
}

moveOldConfigFiles

set optionsFile [scidConfigFile options]

set ecoFile ""

if {[catch {source $optionsFile} ]} {
  #::splash::add "Unable to find the options file: [file tail $optionsFile]"
} else {
  ::splash::add "Your options file \"[file tail $optionsFile]\" was found and loaded."
}

# Now, if the options file was written by Scid 3.5 or older, it has a lot of
# yucky variable names in the global namespace. So convert them to the new
# namespace variables:
#
proc ConvertOldOptionVariables {} {
  
  set oldNewNames {
    autoCloseSplash ::splash::autoclose
    switcherVertical ::windows::switcher::vertical
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


# Reconfigure fonts if necessary:
foreach i {Regular Menu Small Tiny Fixed} {
  if {$fontOptions($i) == $fontOptions(old$i)} {
    # Old font format in options file, or no file. Extract new options:
    set fontOptions($i) {}
    lappend fontOptions($i) [font actual font_$i -family]
    lappend fontOptions($i) [font actual font_$i -size]
    lappend fontOptions($i) [font actual font_$i -weight]
    lappend fontOptions($i) [font actual font_$i -slant]
  } else {
    # New font format in options file:
    configureFont $i
  }
}

# Check board size is valid:
set newSize [lindex $boardSizes 0]
foreach sz $boardSizes {
  if {$boardSize >= $sz} { set newSize $sz }
}
set boardSize $newSize

# Check for old (single-directory) tablebase option:
if {[info exists initialDir(tablebase)]} {
  set initialDir(tablebase1) $initialDir(tablebase)
}

# font_Regular is the default font for widgets:
option add *Font font_Regular

# Use font_Menu for menu entries:
option add *Menu*Font font_Menu
# option add *Menubutton*Font font_Menu

if {$unixOS} {
  option add Scrollbar*borderWidth 1
}

# Set the radiobutton and checkbutton background color if desired.
# I find the maroon color on Unix ugly!
if {$unixOS} {
  option add *Radiobutton*selectColor $buttoncolor
  option add *Checkbutton*selectColor $buttoncolor
  option add *Menu*selectColor $buttoncolor
}

set fontsize [font configure font_Regular -size]
set font [font configure font_Regular -family]

font create font_Bold -family $font -size $fontsize -weight bold
font create font_BoldItalic -family $font -size $fontsize -weight bold \
    -slant italic
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

# Start in the clipbase, if no database is loaded at startup.
sc_base switch clipbase

###
### End of file: start.tcl
