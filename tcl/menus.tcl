### Menus.tcl: part of Scid.
### Copyright (C) 2001 Shane Hudson.

############################################################
###  Status bar help for menu items, buttons, etc:

array set helpMessage {}
set showHelp 1
set oldStatus ""

# statusBarHelp:
#   Called when a button or menu entry is entered to display
#   a status bar help message if applicable.
#
proc statusBarHelp {window {item {}}} {
  global showHelp helpMessage statusBar language

  set status ""
  if {! $showHelp} { return }

  # Tcl/Tk seems to generate strange window names for menus that
  # are configured to be a toplevel window main menu, e.g.
  # .menu.file get reported as ".#menu.#menu#file" and
  # .menu.file.utils is ".#menu.#menu#file.#menu#file#utils"
  # I have no idea why it does this, but to avoid it we
  # convert a window paths with hashes to its true value:

  if {[string range $window 0 1] == ".\#"} {
    set idx [string last . $window]
    set window [string range $window [expr $idx+1] end]
    regsub -all "\#" $window . window
  }

  # Look for a status bar help message for the current button
  # or menu entry, in the current language or English:

  if {$item == ""} { set index $window } else { set index "$window,$item" }
  if {[info exists helpMessage($language,$index)]} {
    set status "  $helpMessage($language,$index)"
  } elseif {[info exists helpMessage(E,$index)]} {
    set status "  $helpMessage(E,$index)"
  } elseif {[info exists helpMessage($index)]} {
    set tag $helpMessage($index)
    if {[info exists helpMessage($language,$tag)]} {
      set status "  $helpMessage($language,$tag)"
    } elseif {[info exists helpMessage(E,$tag)]} {
      set status "  $helpMessage(E,$tag)"
    } else { set status $tag }
  }

  if {$status == ""} { statusBarRestore $window; return }

  if {[string range $window 0 7] == ".treeWin"} {
    ::tree::status $status
  } else {
    set statusBar $status
  }
}

# statusBarRestore:
#   Updates a status bar that was displaying a help message.
#
proc statusBarRestore {window} {
  global showHelp statusBar

  if {! $showHelp} { return }
  if {[string range $window 0 7] == ".treeWin"} {
    ::tree::status
  } else {
    updateStatusBar
  }
}

bind Menu <Any-Enter> "+statusBarHelp %W \[ %W index @%y \]"
bind Menu <Any-Motion> "+statusBarHelp %W \[ %W index @%y \]"
bind Menu <Any-Leave> "+statusBarRestore %W"

bind Menubutton <Any-Enter> "+statusBarHelp %W"
bind Menubutton <Any-Leave> "+statusBarRestore %W"
bind Button <Any-Enter> "+statusBarHelp %W"
bind Button <Any-Leave> "+statusBarRestore %W"
bind Label <Any-Enter> "+statusBarHelp %W"
bind Label <Any-Leave> "+statusBarRestore %W"


############################################################
### Main window menus:

option add *Menu*TearOff 0

menu .menu
. configure -menu .menu

.menu add cascade -label File -menu .menu.file
.menu add cascade -label Edit -menu .menu.edit
.menu add cascade -label Game -menu .menu.game
.menu add cascade -label Search -menu .menu.search
.menu add cascade -label Windows -menu .menu.windows
.menu add cascade -label Tools -menu .menu.tools
.menu add cascade -label Options -menu .menu.options
.menu add cascade -label Help -menu .menu.helpmenu

foreach menuname { file edit game search windows tools options helpmenu } {
    menu .menu.${menuname}
}


### File menu:

set m .menu.file
$m add command -label FileNew -acc "Ctrl+N" -command fileNew
bind . <Control-n> fileNew
set helpMessage($m,0) FileNew

$m add command -label FileOpen -acc "Ctrl+O" -command fileOpen
bind . <Control-o> fileOpen
set helpMessage($m,1) FileOpen

$m add command -label FileClose -command fileClose
set helpMessage($m,2) FileClose

$m add command -label FileFinder -acc "Ctrl+/" -command fileFinder
bind . <Control-slash> fileFinder
set helpMessage($m,3) FileFinder

$m add cascade -label FileBookmarks -accelerator "Ctrl+B" -menu $m.bookmarks
set helpMessage($m,4) FileBookmarks
menu $m.bookmarks

$m add separator

menu $m.utils
$m add cascade -label FileMaint -menu .menu.file.utils
set helpMessage($m,6) FileMaint

$m.utils add checkbutton -label FileMaintWin \
  -accelerator "Ctrl+M" -variable maintWin -command makeMaintWin 
bind . <Control-m> makeMaintWin
set helpMessage($m.utils,0) FileMaintWin

$m.utils add command -label FileMaintCompact -command makeCompactWin
set helpMessage($m.utils,1) FileMaintCompact

$m.utils add command -label FileMaintClass -command classifyAllGames
# bind . <Control-C> classifyAllGames  ;# Ctrl+C now bound to Copy-Position
set helpMessage($m.utils,2) FileMaintClass

$m.utils add command -label FileMaintSort -command makeSortWin
set helpMessage($m.utils,3) FileMaintSort

$m.utils add separator

$m.utils add command -label FileMaintDelete -state disabled -command markTwins
set helpMessage($m.utils,5) FileMaintDelete

$m.utils add command -label FileMaintTwin -command updateTwinChecker
set helpMessage($m.utils,6) FileMaintTwin

$m.utils add separator

menu $m.utils.name
$m.utils add cascade -label FileMaintName -menu .menu.file.utils.name
set helpMessage($m.utils,8) FileMaintName

$m.utils.name add checkbutton -label FileMaintNameEditor \
  -command nameEditor -variable nameEditorWin -accelerator "Ctrl+Shift+N"
bind . <Control-N> nameEditor
set helpMessage($m.utils.name,0) FileMaintNameEditor

$m.utils.name add command -label FileMaintNamePlayer -command {openSpellCheckWin Player}
set helpMessage($m.utils.name,1) FileMaintNamePlayer

$m.utils.name add command -label FileMaintNameEvent -command {openSpellCheckWin Event}
set helpMessage($m.utils.name,2) FileMaintNameEvent

$m.utils.name add command -label FileMaintNameSite -command {openSpellCheckWin Site}
set helpMessage($m.utils.name.3) FileMaintNameSite

$m.utils.name add command -label FileMaintNameRound -command {openSpellCheckWin Round}
set helpMessage($m.utils.name,4) FileMaintNameRound

bind . <Control-d> makeBaseWin

$m add command -label FileReadOnly -command makeBaseReadOnly
set helpMessage($m,7) FileReadOnly

#$m add separator

$m add cascade -label FileSwitch -menu $m.switch
set helpMessage($m,8) FileSwitch
menu $m.switch

set totalBaseSlots [sc_base count total]
set clipbaseSlot [sc_info clipbase]
set currentSlot [sc_base current]

for {set i 1} { $i <= $totalBaseSlots} {incr i} {
  $m.switch add radiobutton -variable currentSlot -value $i \
    -label "Base $i: <none>" \
    -underline 5 -accelerator "Ctrl+$i" -command "switchBase $i"
  set helpMessage($m.switch,[expr $i - 1]) "Switch to base slot $i"
  if {$i == $clipbaseSlot} {
    set helpMessage($m.switch,[expr $i - 1]) "Switch to the clipbase database"
  }
  bind . "<Control-Key-$i>" "switchBase $i"
}

proc switchBase {b} {
  sc_base switch $b
  # Close tree and email windows when a base is switched:
  #if {[winfo exists .treeWin]} { destroy .treeWin }
  if {[winfo exists .emailWin]} { destroy .emailWin }
  updateBoardAndPgn .board
  updateTitle
  updateMenuStates
  updateStatusBar
  updateGList
}

$m add separator

$m add command -label FileExit -accelerator "Ctrl+Q" -command fileExit
bind . <Control-q> fileExit
set helpMessage($m,10) FileExit


### Edit menu:

set m .menu.edit
$m add command -label EditAdd \
  -accel "Ctrl+A" -command {sc_var create; updateBoardAndPgn .board}
set helpMessage($m,0) EditAdd

menu $m.del
$m add cascade -label EditDelete -menu $m.del
set helpMessage($m,1) EditDelete

menu $m.first
$m add cascade -label EditFirst -menu $m.first
set helpMessage($m,2) EditFirst

menu $m.main
$m add cascade -label EditMain -menu $m.main
set helpMessage($m,3) EditMain

$m add checkbutton -label EditTrial -variable trialMode \
  -accelerator "Ctrl+space" -command {setTrialMode update}
bind . <Control-space> { setTrialMode toggle }
set helpMessage($m,4) EditTrial

$m add cascade -label EditStrip -menu $m.strip
set helpMessage($m,5) EditStrip

menu $m.strip
$m.strip add command -label EditStripComments -command {gameStrip comments}
set helpMessage($m.strip,0) EditStripComments
$m.strip add command -label EditStripVars -command {gameStrip variations}
set helpMessage($m.strip,1) EditStripVars

$m add separator

$m add command -label EditReset -command {
  sc_clipbase clear
  updateBoardAndPgn .board
  updateGList
  updateTitle
}
set helpMessage($m,7) EditReset

$m add command -label EditCopy -accelerator "Ctrl+C" -command {
  catch {sc_clipbase copy}
  updateBoard .board
}
bind . <Control-c> {catch {sc_clipbase copy}; updateBoard .board}
set helpMessage($m,8) EditCopy

$m add command -label EditPaste -accelerator "Ctrl+V" -command {
  sc_clipbase paste
  updateBoardAndPgn .board
}
bind . <Control-v> {catch {sc_clipbase paste}; updateBoardAndPgn .board}
set helpMessage($m,9) EditPaste

$m add separator

$m add command -label EditSetup -accelerator "Ctrl+Shift+S" -command setupBoard
bind . <Control-S> setupBoard
set helpMessage($m,11) EditSetup

$m add command -label EditCopyBoard -accelerator "Ctrl+Shift+C" \
  -command copyFEN
bind . <Control-C> copyFEN
set helpMessage($m,12) EditCopyBoard

$m add command -label EditPasteBoard -accelerator "Ctrl+Shift+V" \
  -command pasteFEN
bind . <Control-V> pasteFEN
set helpMessage($m,13) EditPasteBoard


### Game menu:

set m .menu.game
$m add command -label GameNew -accelerator "Ctrl+X" -command gameClear
bind . <Control-x> gameClear
set helpMessage($m,0) GameNew

$m add command -label GameFirst -accelerator "Ctrl+Shift+Up" \
  -command {gameLoadNextPrev first}
bind . <Control-Shift-Up> {gameLoadNextPrev first}
set helpMessage($m,1) GameFirst

$m add command -label GamePrev -accelerator "Ctrl+Up" \
  -command {gameLoadNextPrev previous}
bind . <Control-Up> {gameLoadNextPrev previous}
set helpMessage($m,2) GamePrev

$m add command -label GameReload -command gameReload \
  -accelerator "Ctrl+Shift+L"
bind . <Control-L> gameReload
set helpMessage($m,3) GameReload

$m add command -label GameNext -accelerator "Ctrl+Down" \
  -command {gameLoadNextPrev next}
bind . <Control-Down> {gameLoadNextPrev next}
set helpMessage($m,4) GameNext

$m add command -label GameLast -accelerator "Ctrl+Shift+Down" \
  -command {gameLoadNextPrev last}
bind . <Control-Shift-Down> {gameLoadNextPrev last}
set helpMessage($m,5) GameLast

$m add command -label GameRandom -command gameLoadRandom -accelerator "Ctrl+?"
bind . <Control-question> gameLoadRandom
set helpMessage($m,6) GameRandom

$m add command -label GameNumber -command gameLoadNumber -accelerator "Ctrl+G"
bind . <Control-g> gameLoadNumber
set helpMessage($m,7) GameNumber

$m add separator

$m add command -label GameReplace -command gameReplace -accelerator "Ctrl+R"
bind . <Control-r> { .menu.game invoke [tr GameReplace] }
set helpMessage($m,9) GameReplace

$m  add command -label GameAdd -command gameAdd  -accelerator "Ctrl+S"
bind . <Control-s> gameAdd
set helpMessage($m,10) GameAdd

$m add separator

$m add command -label GameDeepest -accelerator "Ctrl+Shift+D" -command {
  sc_move ply [sc_eco game ply]
  updateBoard .board
}
bind . <Control-D> {sc_move ply [sc_eco game ply]; updateBoard .board}
set helpMessage($m,12) GameDeepest

$m add command -label GameGotoMove -accelerator "Ctrl+U" \
  -command gotoMoveNumber
set helpMessage($m,13) GameGotoMove
bind . <Control-u> gotoMoveNumber

$m add command -label GameNovelty -accelerator "Ctrl+Shift+Y" \
  -command findNovelty
bind . <Control-Y> findNovelty
set helpMessage($m,14) GameNovelty


### Search menu:

set m .menu.search
$m  add command -label SearchReset -acc "Ctrl+F" -command searchReset
bind . <Control-f> searchReset
set helpMessage($m,0) SearchReset

$m  add command -label SearchNegate -acc "Ctrl+Shift+F" -command searchNegate
bind . <Control-F> searchNegate
set helpMessage($m,1) SearchNegate

$m  add separator

$m  add command -label SearchCurrent \
  -command searchBoard -accelerator "Ctrl+Shift+B"
bind . <Control-B> searchBoard
set helpMessage($m,3) SearchCurrent

$m  add command -label SearchHeader \
  -command searchHeader -accelerator "Ctrl+Shift+H"
bind . <Control-H> searchHeader
set helpMessage($m,4) SearchHeader

$m  add command -label SearchMaterial \
  -command searchMaterial -accelerator "Ctrl+Shift+M"
bind . <Control-M> searchMaterial
set helpMessage($m,5) SearchMaterial

$m  add separator

$m add command -label SearchUsing -accel "Ctrl+Shift+U" \
  -command useSearchFile
bind . <Control-KeyPress-U> useSearchFile
set helpMessage($m,7) SearchUsing

proc useSearchFile {} {
  set ftype { { "Scid SearchOption files" {".sso"} } }
  set ::fName [tk_getOpenFile -initialdir $::initialDir(base) \
                 -filetypes $ftype -title "Select a SearchOptions file"]
  if {$::fName == ""} { return }

  if {[catch {uplevel "#0" {source $::fName} } ]} {
    tk_messageBox -title "Scid: Error reading file" -type ok -icon warning \
                -message "Unable to open or read SearchOptions file: $fName"
  } else {
    switch -- $::searchType {
      "Material" { searchMaterial }
      "Header"   { searchHeader }
      default    { return }
    }
  }
}


### Windows menu:

set m .menu.windows
$m  add checkbutton -label WindowsComment \
  -var commentWin -command makeCommentWin -accelerator "Ctrl+E"
bind . <Control-e> makeCommentWin
set helpMessage($m,0) WindowsComment

$m  add checkbutton -label WindowsGList \
  -variable glist -command makeGList  -accelerator "Ctrl+L"
bind . <Control-l> makeGList
set helpMessage($m,1) WindowsGList

$m  add checkbutton -label WindowsPGN \
  -variable pgnWin -command makePgnWin  -accelerator "Ctrl+P"
bind . <Control-p> makePgnWin
set helpMessage($m,2) WindowsPGN

$m add checkbutton -label WindowsPList \
  -variable plistWin -command ::plist::toggle -accelerator "Ctrl+Shift+P"
bind . <Control-P> ::plist::toggle
set helpMessage($m,3) WindowsPList

$m add checkbutton -label WindowsTmt \
  -variable tourneyWin -command ::tourney::toggle -accelerator "Ctrl+Shift+T"
bind . <Control-T> ::tourney::toggle
set helpMessage($m,4) WindowsTmt

$m add separator

$m add checkbutton -label WindowsSwitcher \
  -variable baseWin -accelerator "Ctrl+D" -command makeBaseWin
set helpMessage($m,6) WindowsSwitcher

$m add checkbutton -label WindowsMaint \
  -accelerator "Ctrl+M" -variable maintWin -command makeMaintWin 
bind . <Control-m> makeMaintWin
set helpMessage($m,7) WindowsMaint

$m add separator

$m add checkbutton -label WindowsECO -accelerator "Ctrl+Y" \
  -variable ecoBrowserWin -command {openCloseEcoBrowser}
bind . <Control-y> openCloseEcoBrowser
set helpMessage($m,9) WindowsECO

$m add checkbutton -label WindowsRepertoire -variable ::rep::Win \
  -accelerator "Ctrl+Shift+R" -command ::rep::openCloseWindow
bind . <Control-R> ::rep::openCloseWindow
set helpMessage($m,10) WindowsRepertoire

$m add checkbutton -label WindowsStats -variable statsWin \
  -accelerator "Ctrl+I" -command makeStatsWin
bind . <Control-i> makeStatsWin
set helpMessage($m,11) WindowsStats

$m add checkbutton -label WindowsTree \
  -variable treeWin -command ::tree::make -accelerator "Ctrl+T"
bind . <Control-t> { .menu.windows invoke [tr WindowsTree] }
set helpMessage($m,12) WindowsTree

$m add checkbutton -label WindowsTB -variable tbWin -command ::tb::open \
  -accelerator "Ctrl+="
bind . <Control-equal> ::tb::open
set helpMessage($m,13) WindowsTB


### Tools menu:

set m .menu.tools

$m  add checkbutton -label ToolsAnalysis -variable analysisWin1 \
  -command makeAnalysisWin -accelerator "Ctrl+Shift+A"
bind . <Control-A> makeAnalysisWin
set helpMessage($m,0) ToolsAnalysis

$m  add checkbutton -label ToolsAnalysis2 -variable analysisWin2 \
  -command "makeAnalysisWin 2" -accelerator "Ctrl+Shift+2"
bind . <Control-at> "makeAnalysisWin 2"
set helpMessage($m,1) ToolsAnalysis2

$m add command -label ToolsCross \
  -accelerator "Ctrl+Shift+X" -command crosstabWin
bind . <Control-X> crosstabWin
set helpMessage($m,2) ToolsCross

$m add checkbutton -label ToolsEmail \
  -accelerator "Ctrl+Shift+E" -variable emailWin -command makeEmailWin
bind . <Control-E> makeEmailWin
set helpMessage($m,3) ToolsEmail

$m add checkbutton -label ToolsFilterGraph \
  -accelerator "Ctrl+Shift+G" -variable filterGraph -command makeFilterGraph
bind . <Control-G> makeFilterGraph
set helpMessage($m,4) ToolsFilterGraph

$m add command -label ToolsOpReport \
  -accelerator "Ctrl+Shift+O" -command ::optable::makeReportWin
bind . <Control-O> ::optable::makeReportWin
set helpMessage($m,5) ToolsOpReport

$m add command -label ToolsTracker \
  -accelerator "Ctrl+Shift+K" -command ::ptrack::make
bind . <Control-K> ::ptrack::make
set helpMessage($m,6) ToolsTracker

$m add separator

menu $m.pinfo
$m add cascade -label ToolsPInfo -menu $m.pinfo
$m.pinfo add command -label White -underline 0 -command {
  playerInfo [sc_game info white]
}
$m.pinfo add command -label Black -underline 0 -command {
  playerInfo [sc_game info black]
}
set helpMessage($m,8) ToolsPInfo

$m add command -label ToolsRating -command {updateRatingGraph both}
# bind . <Control-R> {updateRatingGraph both}
set helpMessage($m,9) ToolsRating

$m add command -label ToolsScore \
  -accelerator "Ctrl+Shift+Z" -command updateScoreGraph
bind . <Control-Z> updateScoreGraph
set helpMessage($m,10) ToolsScore

$m add separator

menu $m.exportcurrent

$m add cascade -label ToolsExpCurrent -menu $m.exportcurrent
set helpMessage($m,12) ToolsExpCurrent

$m.exportcurrent add command -label ToolsExpCurrentPGN \
  -command {exportGames current PGN}
set helpMessage($m.exportcurrent,0) ToolsExpCurrentPGN

$m.exportcurrent add command -label ToolsExpCurrentHTML \
  -command {exportGames current HTML}
set helpMessage($m.exportcurrent,1) ToolsExpCurrentHTML

$m.exportcurrent add command -label ToolsExpCurrentLaTeX \
  -command {exportGames current LaTeX}
set helpMessage($m.exportcurrent,2) ToolsExpCurrentLaTeX

menu $m.exportfilter

$m add cascade -label ToolsExpFilter -menu $m.exportfilter
set helpMessage($m,13) ToolsExpFilter

$m.exportfilter add command -label ToolsExpFilterPGN \
  -command {exportGames filter PGN}
set helpMessage($m.exportfilter,0) ToolsExpFilterPGN

$m.exportfilter add command -label ToolsExpFilterHTML \
  -command {exportGames filter HTML}
set helpMessage($m.exportfilter,1) ToolsExpFilterHTML

$m.exportfilter add command -label ToolsExpFilterLaTeX \
  -command {exportGames filter LaTeX}
set helpMessage($m.exportfilter,2) ToolsExpFilterLaTeX

$m add separator

$m add command -label ToolsImportOne \
  -accelerator "Ctrl+Shift+I" -command importPgnGame
bind . <Control-I> importPgnGame
set helpMessage($m,15) ToolsImportOne

$m add command -label ToolsImportFile -command importPgnFile
set helpMessage($m,16) ToolsImportFile

### Options menu:

set m .menu.options
$m add cascade -label OptionsSize -menu $m.bdsize
set helpMessage($m,0) OptionsSize

$m add cascade -label OptionsPieces -menu $m.pieces
set helpMessage($m,1) OptionsPieces

$m add command -label OptionsColors -command chooseBoardColors
set helpMessage($m,2) OptionsColors

set optMenus {export fonts ginfo language entry numbers startup windows}
set optLabels {Export Fonts GInfo Language Moves Numbers Startup Windows}
set i 3
foreach menu $optMenus label $optLabels {
  $m add cascade -label Options$label -menu $m.$menu
  set helpMessage($m,$i) Options$label
  incr i
}

$m add command -label OptionsToolbar -command configToolbar
set helpMessage($m,11) OptionsToolbar

$m add separator

$m add command -label OptionsECO -command {
  set ftype { { "Scid ECO files" {".eco"} } }
  if {[sc_info gzip]} {
    set ftype { { "Scid ECO files" {".eco" ".eco.gz"} } }
  }
  set fullname [tk_getOpenFile -initialdir [pwd] -filetypes $ftype -title "Load ECO file"]
  if {[string compare $fullname ""]} {
    if {[catch {sc_eco read $fullname} result]} {
      tk_messageBox -title "Scid" -type ok \
        -icon warning -message $result
    } else {
      set ecoFile $fullname
      tk_messageBox -title "Scid: ECO file loaded." -type ok -icon info \
        -message "ECO file $fullname loaded: $result positions.\n\nTo have this file automatically loaded when you start Scid, select \"Save Options\" from the Options menu before exiting."
    }
  }
}
set helpMessage($m,13) OptionsECO

$m add command -label OptionsSpell -command readSpellCheckFile
set helpMessage($m,14) OptionsSpell

$m add command -label OptionsTable -command setTableBaseDir
set helpMessage($m,15) OptionsTable
if {![sc_info tb]} { $m entryconfigure 15 -state disabled }

# setTableBaseDir:
#    Prompt user to select a tablebase file; all the files in its 
#    directory will be used.
#
proc setTableBaseDir {} {
  global initialDir tempDir
  set ftype { { "Tablebase files" {".emd" ".nbw" ".nbb"} } }

  set w .tbDialog
  toplevel $w
  wm title $w Scid
  label $w.title -text "Select up to 4 table base directories:"
  pack $w.title -side top
  foreach i {1 2 3 4} {
    set tempDir(tablebase$i) $initialDir(tablebase$i)
    pack [frame $w.f$i] -side top -pady 3 -fill x -expand yes
    entry $w.f$i.e -width 30 -textvariable tempDir(tablebase$i)
    bindFocusColors $w.f$i.e
    button $w.f$i.b -text "..." -pady 2 -command [list chooseTableBaseDir $i]
    pack $w.f$i.b -side right -padx 2
    pack $w.f$i.e -side left -padx 2 -fill x -expand yes
  }
  addHorizontalRule $w
  pack [frame $w.b] -side top -fill x
  button $w.b.ok -text "OK" \
    -command "catch {grab release $w; destroy $w}; openTableBaseDirs"
  button $w.b.cancel -text $::tr(Cancel) \
    -command "catch {grab release $w; destroy $w}"
  pack $w.b.cancel $w.b.ok -side right -padx 2
  bind $w <Escape> "$w.b.cancel invoke"
  wm resizable $w 1 0
  grab $w
}

proc openTableBaseDirs {} {
  global initialDir tempDir
  set tableBaseDirs ""
  foreach i {1 2 3 4} {
    set tbDir [string trim $tempDir(tablebase$i)]
    if {$tbDir != ""} {
      if {$tableBaseDirs != ""} { append tableBaseDirs ";" }
      append tableBaseDirs [file nativename $tbDir]
    }
  }

  set npieces [sc_info tb $tableBaseDirs]
  if {$npieces == 0} {
    set msg "No tablebases were found."
  } else {
    set msg "Tablebases with up to $npieces pieces were found.\n\n"
    append msg "If you want these tablebases be used whenever\n"
    append msg "you start Scid, select \"Save Options\" from the\n"
    append msg "Options menu before you exit Scid."
    foreach i {1 2 3 4} {
      set initialDir(tablebase$i) $tempDir(tablebase$i)
    }
  }
  tk_messageBox -type ok -icon info -title "Scid: Tablebase results" \
    -message $msg
    
}
proc chooseTableBaseDir {i} {
  global tempDir

  set ftype { { "Tablebase files" {".emd" ".nbw" ".nbb"} } }
  set idir $tempDir(tablebase$i)
  if {$idir == ""} { set idir [pwd] }

  set fullname [tk_getOpenFile -initialdir $idir -filetypes $ftype \
                  -title "Scid: Select a Tablebase file"]
  if {$fullname == ""} { return }

  set tempDir(tablebase$i) [file dirname $fullname]
}

$m add command -label OptionsRecent -command ::recentFiles::configure
set helpMessage($m,16) OptionsRecent

$m add separator

$m add command -label OptionsSave -command {
  set optionF ""
  if {[catch {open $optionsFile w} optionF]} {
    tk_messageBox -title "Scid: Unable to write file" -type ok -icon warning \
      -message "Unable to write options file: $optionsFile\n$optionF"
  } else {
    puts $optionF "# Scid options file"
    puts $optionF "# Version: $scidVersion"
    puts $optionF "# This file contains commands in the Tcl language format."
    puts $optionF "# If you edit this file, you must preserve valid its Tcl"
    puts $optionF "# format or it will not set your Scid options properly."
    puts $optionF ""
    foreach i {boardSize boardStyle language doColorPgn \
                 pgnIndentVars pgnIndentComments \
                 pgnSymbolicNags pgnMoveNumSpace pgnColumn \
                 tree(order) tree(autoSave) optionsAutoSave \
                 ecoFile suggestMoves glistSize glexport autoplayDelay \
                 boardCoords moveEntry(AutoExpand) moveEntry(Coord) \
                 askToReplaceMoves switcherVertical locale(numeric) \
                 spellCheckFile autoCloseSplash autoRaise autoIconify \
                 exportFlags(comments) exportFlags(vars) \
                 exportFlags(indentc) exportFlags(indentv) \
                 exportFlags(column) exportFlags(symbols) \
                 exportFlags(htmldiag) exportFlags(convertNullMoves) \
                 email(smtp) email(smproc) email(server) \
                 email(from) email(bcc) \
                 gameInfo(photos) gameInfo(hideNextMove) gameInfo(wrap) \
                 gameInfo(fullComment) gameInfo(showMarks) \
                 gameInfo(showMaterial) gameInfo(showFEN) gameInfo(showTB)} {
      puts $optionF "set $i [list [set $i]]"
    }
    foreach i [lsort [array names winWidth]] {
      puts $optionF "set winWidth($i)  [expr $winWidth($i)]"
      puts $optionF "set winHeight($i) [expr $winHeight($i)]"
    }
    foreach i [lsort [array names winX]] {
      puts $optionF "set winX($i)  [expr $winX($i)]"
      puts $optionF "set winY($i)  [expr $winY($i)]"
    }
    puts $optionF "set analysisCommand [list $analysisCommand]"
    puts $optionF "set analysisChoices [list $analysisChoices]"
    foreach i {lite dark whitecolor blackcolor highcolor bestcolor \
               whiteborder blackborder \
               pgnColor(Header) pgnColor(Main) pgnColor(Var) \
               pgnColor(Nag) pgnColor(Comment) pgnColor(Background) \
               pgnColor(Current) pgnColor(NextMove) } {
      puts $optionF "set $i [list [set $i]]"
    }
    foreach i [lsort [array names optable]] {
      puts $optionF "set optable($i) [list $optable($i)]"
    }
    foreach i [lsort [array names stats]] {
      puts $optionF "set stats($i) [list $stats($i)]"
    }
    foreach i [lsort [array names startup]] {
      puts $optionF "set startup($i) [list $startup($i)]"
    }
    foreach i [lsort [array names toolbar]] {
      puts $optionF "set toolbar($i) [list $toolbar($i)]"
    }
    foreach i [lsort [array names twinSettings]] {
      puts $optionF "set twinSettings($i) [list $twinSettings($i)]"
    }
    foreach i {Regular Menu Small Fixed} {
      puts $optionF "set fontOptions($i) [list $fontOptions($i)]"
    }
    puts $optionF "set glistFields [list $glistFields]"
    foreach type {base book html tex tablebase1 tablebase2 tablebase3 tablebase4} {
      puts $optionF "set initialDir($type) [list $initialDir($type)]"
    }
    foreach type {PGN HTML LaTeX} {
      puts $optionF "set exportStartFile($type) [list $exportStartFile($type)]"
      puts $optionF "set exportEndFile($type) [list $exportEndFile($type)]"
    }
    close $optionF
    set ::statusBar "Options were saved to: $optionsFile"
    #tk_messageBox -title "Saved options" -type ok -icon info \
      -message "Options were saved to: $optionsFile"
  }
}
set helpMessage($m,18) OptionsSave

$m add checkbutton -label OptionsAutoSave -variable optionsAutoSave
set helpMessage($m,19) OptionsAutoSave

menu $m.ginfo
$m.ginfo add checkbutton -label GInfoHideNext \
  -variable gameInfo(hideNextMove) -offvalue 0 -onvalue 1 \
  -command {updateBoard .board}
$m.ginfo add checkbutton -label GInfoMaterial \
  -variable gameInfo(showMaterial) -offvalue 0 -onvalue 1 \
  -command {updateBoard .board}
$m.ginfo add checkbutton -label GInfoFEN \
  -variable gameInfo(showFEN) -offvalue 0 -onvalue 1 \
  -command {updateBoard .board}
$m.ginfo add checkbutton -label GInfoMarks \
  -variable gameInfo(showMarks) -offvalue 0 -onvalue 1 \
  -command {updateBoard .board}
$m.ginfo add checkbutton -label GInfoWrap \
  -variable gameInfo(wrap) -offvalue 0 -onvalue 1 \
  -command {updateBoard .board}
$m.ginfo add checkbutton -label GInfoFullComment \
  -variable gameInfo(fullComment) -offvalue 0 -onvalue 1 \
  -command {updateBoard .board}
$m.ginfo add checkbutton -label GInfoPhotos \
  -variable gameInfo(photos) -offvalue 0 -onvalue 1 \
  -command {updatePlayerPhotos -force}
$m.ginfo add separator
$m.ginfo add radiobutton -label GInfoTBNothing \
  -variable gameInfo(showTB) -value 0 -command {updateBoard .board}
$m.ginfo add radiobutton -label GInfoTBResult \
  -variable gameInfo(showTB) -value 1 -command {updateBoard .board}
$m.ginfo add radiobutton -label GInfoTBAll \
  -variable gameInfo(showTB) -value 2 -command {updateBoard .board}

menu $m.entry
$m.entry add checkbutton -label OptionsMovesAsk \
  -variable askToReplaceMoves -offvalue 0 -onvalue 1
set helpMessage($m.entry,0) OptionsMovesAsk \

$m.entry add command -label OptionsMovesDelay -command setAutoplayDelay
set helpMessage($m.entry,1) OptionsMovesDelay

$m.entry add checkbutton -label OptionsMovesCoord \
 -variable moveEntry(Coord) -offvalue 0 -onvalue 1
set helpMessage($m.entry,2) OptionsMovesCoord

$m.entry add checkbutton -label OptionsMovesKey \
  -variable moveEntry(AutoExpand) -offvalue 0 -onvalue 1
set helpMessage($m.entry,3) OptionsMovesKey

$m.entry add checkbutton -label OptionsMovesSuggest \
  -variable suggestMoves -offvalue 0 -onvalue 1
set helpMessage($m.entry,4) OptionsMovesSuggest

proc updateLocale {} {
  global locale
  sc_info decimal $locale(numeric)
  updateGList
  updateTitle
}

set m .menu.options.numbers
menu $m
foreach numeric {".,"   ". "   "."   ",."   ", "   ","} \
      underline {  0     1      2     4      5      6} {
  set decimal [string index $numeric 0]
  set thousands [string index $numeric 1]
  $m add radiobutton -label "12${thousands}345${decimal}67" \
    -underline $underline \
    -variable locale(numeric) -value $numeric -command updateLocale
}

set m .menu.options.export
menu $m
foreach format {PGN HTML LaTeX} {
  $m add command -label "$format file text" -underline 0 \
    -command "setExportText $format"
}

set m .menu.options.windows
menu $m
$m add checkbutton -label OptionsWindowsIconify -variable autoIconify
set helpMessage($m,0) OptionsWindowsIconify
$m add checkbutton -label OptionsWindowsRaise -variable autoRaise
set helpMessage($m,1) OptionsWindowsRaise

menu .menu.options.language

set m .menu.options.fonts
menu $m
$m add command -label OptionsFontsRegular -underline 0 -command {
  set fontOptions(temp) [FontDialog font_Regular $fontOptions(Regular)]
  if {$fontOptions(temp) != ""} { set fontOptions(Regular) $fontOptions(temp) }
  set font [font configure font_Regular -family]
  set fontsize [font configure font_Regular -size]
  font configure font_Bold -family $font -size $fontsize
  font configure font_Italic -family $font -size $fontsize
  font configure font_BoldItalic -family $font -size $fontsize
  font configure font_H1 -family $font -size [expr $fontsize + 8]
  font configure font_H2 -family $font -size [expr $fontsize + 6]
  font configure font_H3 -family $font -size [expr $fontsize + 4]
  font configure font_H4 -family $font -size [expr $fontsize + 2]
  font configure font_H5 -family $font -size [expr $fontsize + 0]
}
set helpMessage($m,0) OptionsFontsRegular
$m add command -label OptionsFontsMenu -underline 0 -command {
  set fontOptions(temp) [FontDialog font_Menu $fontOptions(Menu)]
  if {$fontOptions(temp) != ""} { set fontOptions(Menu) $fontOptions(temp) }
}
set helpMessage($m,1) OptionsFontsMenu
$m add command -label OptionsFontsSmall -underline 0 -command {
  set fontOptions(temp) [FontDialog font_Small $fontOptions(Small)]
  if {$fontOptions(temp) != ""} { set fontOptions(Small) $fontOptions(temp) }
  set font [font configure font_Small -family]
  set fontsize [font configure font_Small -size]
  font configure font_SmallBold -family $font -size $fontsize
  font configure font_SmallItalic -family $font -size $fontsize
}
set helpMessage($m,2) OptionsFontsSmall
$m add command -label OptionsFontsFixed -underline 0 -command {
  set fontOptions(temp) [FontDialog font_Fixed $fontOptions(Fixed) 1]
  if {$fontOptions(temp) != ""} { set fontOptions(Fixed) $fontOptions(temp) }
}
set helpMessage($m,3) OptionsFontsFixed

set m .menu.options.startup
menu $m
$m add checkbutton -label HelpTip -variable startup(tip)
$m add checkbutton -label ToolsCross -variable startup(crosstable)
$m add checkbutton -label WindowsSwitcher -variable startup(switcher)
$m add checkbutton -label FileFinder -variable startup(finder)
$m add checkbutton -label WindowsGList -variable startup(gamelist)
$m add checkbutton -label WindowsPGN -variable startup(pgn)
$m add checkbutton -label WindowsStats -variable startup(stats)
$m add checkbutton -label WindowsTree -variable startup(tree)

# Menu for changing board size:
menu .menu.options.bdsize
set count 0
foreach i $boardSizes {
  incr count
  set underline -1
  if {$count < 10} {set underline 0}
  if {$count == 10} {set underline 1}
  .menu.options.bdsize add radio -label $count -variable boardSize \
    -value $i -underline $underline -command "::board::resize .board $i"
  unset underline
}

# Shortcut keys for changing board size:

bind . <Control-Shift-Left>  decreaseBoardSize
bind . <Control-Shift-Right> increaseBoardSize

proc decreaseBoardSize {} {
  global boardSize
  set boardSize [::board::resize .board -1]
}

proc increaseBoardSize {} {
  global boardSize
  set boardSize [::board::resize .board +1]
}

# Menu for changing Piece set:
menu .menu.options.pieces
foreach i $boardStyles {
  .menu.options.pieces add radio -label $i -variable boardStyle -value $i \
    -underline 0 -command "setPieceFont $i"
}

### Help menu:
set m .menu.helpmenu
$m add command -label HelpIndex -command {helpWindow Index} -accelerator "F1"
set helpMessage($m,0) HelpIndex
$m add command -label HelpGuide -command {helpWindow Guide}
set helpMessage($m,1) HelpGuide
$m add command -label HelpHints -command {helpWindow Hints}
set helpMessage($m,2) HelpHints
$m add command -label HelpContact -command {helpWindow Author}
set helpMessage($m,3) HelpContact
$m add command -label HelpTip -command ::tip::show
set helpMessage($m,4) HelpTip
$m add separator
$m add command -label HelpStartup -command {
  wm deiconify .splash
  raiseWin .splash
}
set helpMessage($m,6) HelpStartup
$m  add command -label HelpAbout -command helpAbout
set helpMessage($m,7) HelpAbout

bind . <F1> {helpWindow Index}

##################################################

# updateMenuStates:
#   Update all the menus, rechecking which state each item should be in.
#
proc updateMenuStates {} {
  global totalBaseSlots windowsOS
  set ::currentSlot [sc_base current]
  set lang $::language
  set m .menu
  for {set i 1} { $i <= $totalBaseSlots } { incr i } {
    set fname [file tail [sc_base filename $i]]
    $m.file.switch entryconfig [expr $i - 1] -label "Base $i: $fname"
  }
  foreach i {Compact Delete} {
    $m.file.utils entryconfig [tr FileMaint$i] -state disabled
  }
  foreach i {Player Event Site Round} {
    $m.file.utils.name entryconfig [tr FileMaintName$i] -state disabled
  }
  $m.file entryconfig [tr FileReadOnly] -state disabled

  # Remove and reinsert the Recent files list and Exit command:
  set idx 10
  $m.file delete $idx end
  set nrecent [::recentFiles::show $m.file]
  if {$nrecent > 0} {
    $m.file add separator
  }
  set idx [$m.file index end]
  incr idx
  $m.file add command -label [tr FileExit] -accelerator "Ctrl+Q" \
    -command fileExit
  set helpMessage($m.file,$idx) FileExit

  # Configure File menu entry states::
  if {[sc_base inUse]} {
    set isReadOnly [sc_base isReadOnly]
    $m.file entryconfig [tr FileClose] -state normal
    if {! $isReadOnly} {
      $m.file.utils entryconfig [tr FileMaintDelete] -state normal
      $m.file.utils entryconfig [tr FileMaintName] -state normal
      foreach i {Player Event Site Round} {
        $m.file.utils.name entryconfig [tr FileMaintName$i] -state normal
      }
      $m.file entryconfig [tr FileReadOnly] -state normal
    }

    # Load first/last/random buttons:
    set filtercount [sc_filter count]
    if {$filtercount == 0} {set state disabled} else {set state normal}
    $m.game entryconfig [tr GameFirst] -state $state
    $m.game entryconfig [tr GameLast] -state $state
    $m.game entryconfig [tr GameRandom] -state $state

    # Load previous button:
    if {[sc_filter previous]} {set state normal} else {set state disabled}
    $m.game entryconfig [tr GamePrev] -state $state
    .tb.gprev configure -state $state

    # Reload button:
    if {[sc_game number]} {set state normal} else {set state disabled}
    $m.game entryconfig [tr GameReload] -state $state

    # Load next button:
    if {[sc_filter next]} {set state normal} else {set state disabled}
    $m.game entryconfig [tr GameNext] -state $state
    .tb.gnext configure -state $state

    $m.game entryconfig [tr GameNumber] -state normal

    # Save add button:
    set state normal
    if {$isReadOnly  ||  $::trialMode} {set state disabled}
    $m.game entryconfig [tr GameAdd] -state $state

    # Save replace button:
    set state normal
    if {[sc_game number] == 0  ||  $isReadOnly  ||  $::trialMode} {
      set state disabled
    }
    $m.game entryconfig [tr GameReplace] -state $state

    # Searching:
    foreach i {Reset Negate} {
      $m.search entryconfig [tr Search$i] -state normal
    }
    #$m.windows entryconfig [tr WindowsTree] -state normal

    # Tools:
    # Email manager only available in Unix:
    $m.tools entryconfig [tr ToolsEmail] -state normal
    $m.tools entryconfig [tr ToolsOpReport] -state normal

  } else {
    # Base is not in use:
    $m.file entryconfig [tr FileClose] -state disabled

    foreach i {First Prev Reload Next Last Random Number Replace Add} {
      $m.game entryconfig [tr Game$i] -state disabled
    }
    .tb.gprev configure -state disabled
    .tb.gnext configure -state disabled

    # search:
    foreach i {Reset Negate} {
      $m.search entryconfig [tr Search$i] -state disabled
    }
    #$m.windows entryconfig [tr WindowsTree] -state disabled

    # tools:
    $m.tools entryconfig [tr ToolsEmail] -state disabled
    $m.tools entryconfig [tr ToolsOpReport] -state disabled
  }

  if {[sc_base numGames] == 0} {
    $m.tools entryconfig [tr ToolsExpFilter] -state disabled
  } else {
    $m.tools entryconfig [tr ToolsExpFilter] -state normal
  }

  set state disabled
  if {[baseIsCompactable]} { set state normal }
  $m.file.utils entryconfig [tr FileMaintCompact] -state $state

  configSearchState
  updateBaseWin
  updateMaintWin
  ::bookmarks::refresh
}


##############################
#
# Multiple-language menu support functions.

# configMenuName:
#    Reconfigure a menu name.
#
proc configMenuName {menu tag lang} {
  global menuLabel menuUnder
  if {[info exists menuLabel($lang,$tag)] && [info exists menuUnder($lang,$tag)]} {
    $menu configure -text $menuLabel($lang,$tag) \
      -underline $menuUnder($lang,$tag)
  } else {
    $menu configure -text $menuLabel(E,$tag) \
      -underline $menuUnder(E,$tag)
  }
}

# configMenuText:
#    Reconfigures the main window menus. Called when the language is changed.
#
proc configMenuText {menu entry tag lang} {
  global menuLabel menuUnder
  if {[info exists menuLabel($lang,$tag)] && [info exists menuUnder($lang,$tag)]} {
      $menu entryconfig $entry -label $menuLabel($lang,$tag) \
        -underline $menuUnder($lang,$tag)
  } else {
      $menu entryconfig $entry -label $menuLabel(E,$tag) \
        -underline $menuUnder(E,$tag)
  }
}

proc setLanguageMenus {{lang ""}} {
  global menuLabel menuUnder oldLang

  if {$lang == ""} {set lang $::language}

  foreach tag {File Edit Game Search Windows Tools Options Help} {
    configMenuText .menu [tr $tag $oldLang] $tag $lang
  }

  foreach tag {New Open Close Finder Bookmarks Maint ReadOnly Switch Exit} {
    configMenuText .menu.file [tr File$tag $oldLang] File$tag $lang
  }
  foreach tag {Win Compact Delete Twin Class Sort Name} {
    configMenuText .menu.file.utils [tr FileMaint$tag $oldLang] \
      FileMaint$tag $lang
  }
  foreach tag {Editor Player Event Site Round} {
    configMenuText .menu.file.utils.name [tr FileMaintName$tag $oldLang] \
      FileMaintName$tag $lang
  }
  foreach tag {Add Delete First Main Trial Strip Reset Copy Paste Setup
               CopyBoard PasteBoard} {
    configMenuText .menu.edit [tr Edit$tag $oldLang] Edit$tag $lang
  }
  foreach tag {Comments Vars} {
    configMenuText .menu.edit.strip [tr EditStrip$tag $oldLang] \
      EditStrip$tag $lang
  }
  foreach tag {New First Prev Reload Next Last Random Number
               Replace Add Deepest GotoMove Novelty} {
    configMenuText .menu.game [tr Game$tag $oldLang] Game$tag $lang
  }
  foreach tag {Reset Negate Material Current Header Using} {
    configMenuText .menu.search [tr Search$tag $oldLang] Search$tag $lang
  }
  foreach tag {Comment GList PGN PList Tmt Switcher Maint ECO Repertoire
               Stats Tree TB} {
    configMenuText .menu.windows [tr Windows$tag $oldLang] Windows$tag $lang
  }
  foreach tag {Analysis Analysis2 Cross Email FilterGraph OpReport Tracker
               Rating Score ExpCurrent ExpFilter ImportOne ImportFile PInfo} {
    configMenuText .menu.tools [tr Tools$tag $oldLang] Tools$tag $lang
  }
  .menu.tools.pinfo entryconfigure 0 -label $::tr(White)
  .menu.tools.pinfo entryconfigure 1 -label $::tr(Black)
  foreach tag {ToolsExpCurrentPGN ToolsExpCurrentHTML ToolsExpCurrentLaTeX} {
    configMenuText .menu.tools.exportcurrent [tr $tag $oldLang] $tag $lang
  }
  foreach tag {ToolsExpFilterPGN ToolsExpFilterHTML ToolsExpFilterLaTeX} {
    configMenuText .menu.tools.exportfilter [tr $tag $oldLang] $tag $lang
  }
  foreach tag {Size Pieces Colors Export Fonts GInfo Language Moves Numbers
               Startup Toolbar Windows ECO Spell Table Recent Save AutoSave} {
    configMenuText .menu.options [tr Options$tag $oldLang] Options$tag $lang
  }
  foreach tag {Regular Menu Small Fixed} {
    configMenuText .menu.options.fonts [tr OptionsFonts$tag $oldLang] \
      OptionsFonts$tag $lang
  }
  foreach tag {HideNext Material FEN Marks Wrap FullComment Photos \
                 TBNothing TBResult TBAll} {
    configMenuText .menu.options.ginfo [tr GInfo$tag $oldLang] \
      GInfo$tag $lang
  }
  foreach tag {Ask Delay Suggest Key Coord} {
    configMenuText .menu.options.entry [tr OptionsMoves$tag $oldLang] \
      OptionsMoves$tag $lang
  }
  foreach tag {HelpTip WindowsSwitcher WindowsPGN WindowsTree FileFinder \
                 ToolsCross WindowsGList WindowsStats} {
    configMenuText .menu.options.startup [tr $tag $oldLang] $tag $lang
  }
  foreach tag {Iconify Raise} {
    configMenuText .menu.options.windows [tr OptionsWindows$tag $oldLang] \
      OptionsWindows$tag $lang
  }
  foreach tag {Index Guide Hints Contact Tip Startup About} {
    configMenuText .menu.helpmenu [tr Help$tag $oldLang] Help$tag $lang
  }

  foreach tag {HideNext Material FEN Marks Wrap FullComment Photos \
                 TBNothing TBResult TBAll Delete Mark} {
    configMenuText .gameInfo.menu [tr GInfo$tag $oldLang] GInfo$tag $lang
  }

  set i 0
  foreach flag $::maintFlaglist {
    .gameInfo.menu.mark entryconfigure $i \
      -label "$::tr($::maintFlags($flag)) ($flag)"
    incr i
  }

  configPgnMenus
  configStatsMenus
  ::tree::configMenus
  configCrosstabMenus
  ::optable::configMenus
  ::tourney::configMenus

  # Check for duplicate menu underline characters in this language:
  # set ::verifyMenus 1
  if {[info exists ::verifyMenus] && $::verifyMenus} {
    foreach m {file edit game search windows tools options help} {
      set list [checkMenuUnderline .menu.$m]
      if {[llength $list] > 0} {
        puts stderr "Menu $m has duplicate underline letters: $list"
      }
    }
  }
}

# checkMenuUnderline:
#  Given a menu widget, returns a list of all the underline
#  characters that appear more than once.
#
proc checkMenuUnderline {menu} {
  array set found {}
  set duplicates {}
  set last [$menu index last]
  for {set i [$menu cget -tearoff]} {$i <= $last} {incr i} {
    if {[string equal [$menu type $i] "separator"]} {
      continue
    }
    set char [string index [$menu entrycget $i -label] \
                [$menu entrycget $i -underline]]
    set char [string tolower $char]
    if {$char == ""} { 
      continue 
    }
    if {[info exists found($char)]} {
      lappend duplicates $char
    }
    set found($char) 1
  }
  return $duplicates
}


# standardShortcuts:
#    Sets up a number of standard shortcut keys for the specified window.
#
proc standardShortcuts {w} {
  if {! [winfo exists $w]} { return }
  bind $w <Control-o> fileOpen
  bind $w <Control-slash> fileFinder
  bind $w <Control-m> makeMaintWin
  bind $w <Control-d> makeBaseWin
  bind $w <Control-q> fileExit
  bind $w <Control-L> gameReload
  bind $w <Control-Shift-Up> {gameLoadNextPrev first}
  bind $w <Control-Shift-Down> {gameLoadNextPrev last}
  bind $w <Control-Up> {gameLoadNextPrev previous}
  bind $w <Control-Down> {gameLoadNextPrev next}
  bind $w <Control-question> gameLoadRandom
  bind $w <Control-g> gameLoadNumber
  bind $w <Control-f> searchReset
  bind $w <Control-B> searchBoard
  bind $w <Control-H> searchHeader
  bind $w <Control-M> searchMaterial
  bind $w <Control-KeyPress-U> useSearchFile
  bind $w <Control-e> makeCommentWin
  bind $w <Control-l> makeGList
  bind $w <Control-p> makePgnWin
  bind $w <Control-T> ::tourney::toggle
  bind $w <Control-i> makeStatsWin
  bind $w <Control-t> ::tree::make
  bind $w <Control-A> makeAnalysisWin
  bind $w <Control-X> crosstabWin
  bind $w <Control-E> makeEmailWin
  bind $w <Control-O> ::optable::makeReportWin
  # bind $w <Control-R> {updateRatingGraph both}
  bind $w <Control-R> ::rep::openCloseWindow
  bind $w <Control-Z> updateScoreGraph
  bind $w <Control-I> importPgnGame
  for {set i 1} { $i <= $::totalBaseSlots} {incr i} {
    bind $w "<Control-Key-$i>" "switchBase $i"
  }
}

### End of file: menus.tcl

