### Menus.tcl: part of Scid.
### Copyright (C) 2001-2003 Shane Hudson.

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
  
  if {[string first {.#} $window] != -1} {
    set idx [string last . $window]
    set window [string range $window [expr {$idx+1} ] end]
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
    set bn ""
    catch { scan $window .treeWin%d.%s bn dummy}
    ::tree::status $status $bn
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
    set bn ""
    catch { scan $window .treeWin%d.%s bn dummy}
    ::tree::status "" $bn
  } else {
    updateStatusBar
  }
}

# bind Menu <Any-Enter> "+statusBarHelp %W \[%W index @%y \]"
# bind Menu <Any-Motion> "+statusBarHelp %W \[%W index @%y \]"
# bind Menu <Any-Leave> "+statusBarRestore %W"

bind Menu <<MenuSelect>> {+
  if {[catch {%W index active} tempMenuIndex]} {
    statusBarRestore %W
  } else {
    statusBarHelp %W $tempMenuIndex
  }
}

bind Menubutton <Any-Enter> "+statusBarHelp %W"
bind Menubutton <Any-Leave> "+statusBarRestore %W"
bind Button <Any-Enter> "+statusBarHelp %W"
bind Button <Any-Leave> "+statusBarRestore %W"
bind Label <Any-Enter> "+statusBarHelp %W"
bind Label <Any-Leave> "+statusBarRestore %W"

bind TMenubutton <Any-Enter> "+statusBarHelp %W"
bind TMenubutton <Any-Leave> "+statusBarRestore %W"
bind TButton <Any-Enter> "+statusBarHelp %W"
bind TButton <Any-Leave> "+statusBarRestore %W"
bind TLabel <Any-Enter> "+statusBarHelp %W"
bind TLabel <Any-Leave> "+statusBarRestore %W"

############################################################
### Main window menus:

option add *Menu*TearOff 0

menu .menu

if { $::docking::USE_DOCKING } {
  . configure -menu .menu
} else  {
  .main configure -menu .menu
}

.menu add cascade -label File -menu .menu.file
.menu add cascade -label Edit -menu .menu.edit
.menu add cascade -label Game -menu .menu.game
.menu add cascade -label Search -menu .menu.search
.menu add cascade -label Windows -menu .menu.windows
.menu add cascade -label Play -menu .menu.play
.menu add cascade -label Tools -menu .menu.tools
.menu add cascade -label Options -menu .menu.options
.menu add cascade -label Help -menu .menu.helpmenu

foreach menuname { file edit game search windows play tools options helpmenu } {
  menu .menu.$menuname
}

### File menu:

set menuindex -1
set m .menu.file
$m add command -label FileNew -acc "Ctrl+N" -command ::file::New
bind $dot_w <Control-n> ::file::New
set helpMessage($m,[incr menuindex]) FileNew

$m add command -label FileOpen -acc "Ctrl+O" -command ::file::Open
bind $dot_w <Control-o> ::file::Open
set helpMessage($m,[incr menuindex]) FileOpen

$m add command -label FileClose -acc "Ctrl+W" -command ::file::Close
bind $dot_w <Control-w> ::file::Close
set helpMessage($m,[incr menuindex]) FileClose

$m add command -label FileFinder -acc "Ctrl+/" -command ::file::finder::Open
bind $dot_w <Control-slash> ::file::finder::Open
set helpMessage($m,[incr menuindex]) FileFinder

$m add cascade -label FileBookmarks -accelerator "Ctrl+B" -menu $m.bookmarks
set helpMessage($m,[incr menuindex]) FileBookmarks
menu $m.bookmarks

$m add separator
incr menuindex

# naming is weird because the menus are moved from Tools to File menus

$m add command -label ToolsOpenBaseAsTree -command ::file::openBaseAsTree
set helpMessage($m,[incr menuindex]) ToolsOpenBaseAsTree

menu $m.recenttrees
$m add cascade -label ToolsOpenRecentBaseAsTree -menu $m.recenttrees
set helpMessage($m,[incr menuindex]) ToolsOpenRecentBaseAsTree

$m add separator
incr menuindex

menu $m.utils
$m add cascade -label FileMaint -menu .menu.file.utils
set helpMessage($m,[incr menuindex]) FileMaint

$m.utils add checkbutton -label FileMaintWin -accelerator "Ctrl+M" -variable maintWin -command ::maint::OpenClose
bind $dot_w <Control-m> ::maint::OpenClose
set helpMessage($m.utils,0) FileMaintWin

$m.utils add command -label FileMaintCompact -command makeCompactWin
set helpMessage($m.utils,1) FileMaintCompact

$m.utils add command -label FileMaintClass -command classifyAllGames
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

$m.utils.name add checkbutton -label FileMaintNameEditor -command nameEditor -variable nameEditorWin -accelerator "Ctrl+Shift+N"
bind $dot_w <Control-N> nameEditor
set helpMessage($m.utils.name,0) FileMaintNameEditor

$m.utils.name add command -label FileMaintNamePlayer -command {openSpellCheckWin Player}
set helpMessage($m.utils.name,1) FileMaintNamePlayer

$m.utils.name add command -label FileMaintNameEvent -command {openSpellCheckWin Event}
set helpMessage($m.utils.name,2) FileMaintNameEvent

$m.utils.name add command -label FileMaintNameSite -command {openSpellCheckWin Site}
set helpMessage($m.utils.name.3) FileMaintNameSite

$m.utils.name add command -label FileMaintNameRound -command {openSpellCheckWin Round}
set helpMessage($m.utils.name,4) FileMaintNameRound

$m.utils add separator
$m.utils add command -label FileMaintFixBase -command ::maint::fixCorruptedBase
set helpMessage($m.utils,10) FileMaintFixBase

bind $dot_w <Control-d> ::windows::switcher::Open

$m add command -label FileReadOnly -command makeBaseReadOnly
set helpMessage($m,[incr menuindex]) FileReadOnly

$m add cascade -label FileSwitch -menu $m.switch
set helpMessage($m,[incr menuindex]) FileSwitch
menu $m.switch

set totalBaseSlots [sc_base count total]
set clipbaseSlot [sc_info clipbase]
set currentSlot [sc_base current]

for {set i 1} { $i <= $totalBaseSlots} {incr i} {
  $m.switch add radiobutton -variable currentSlot -value $i \
      -label "Base $i: <none>" \
      -underline 5 -accelerator "Ctrl+$i" -command [list ::file::SwitchToBase $i]
  set helpMessage($m.switch,[expr {$i - 1} ]) "Switch to base slot $i"
  if {$i == $clipbaseSlot} {
    set helpMessage($m.switch,[expr {$i - 1} ]) "Switch to the clipbase database"
  }
  bind $dot_w "<Control-Key-$i>" [list ::file::SwitchToBase $i]
}

$m add separator
incr menuindex

$m add command -label FileExit -accelerator "Ctrl+Q" -command ::file::Exit
bind $dot_w <Control-q> ::file::Exit
set helpMessage($m,[incr menuindex]) FileExit


### Edit menu:
set menuindex -1
set m .menu.edit
$m add command -label EditAdd -accel "Ctrl+A" -command {sc_var create; updateBoard -pgn}
set helpMessage($m,[incr menuindex]) EditAdd

menu $m.del
$m add cascade -label EditDelete -menu $m.del
set helpMessage($m,[incr menuindex]) EditDelete

menu $m.first
$m add cascade -label EditFirst -menu $m.first
set helpMessage($m,[incr menuindex]) EditFirst

menu $m.main
$m add cascade -label EditMain -menu $m.main
set helpMessage($m,[incr menuindex]) EditMain

$m add checkbutton -label EditTrial -variable trialMode -accelerator "Ctrl+space" -command {setTrialMode update}
bind $dot_w <Control-space> { setTrialMode toggle }
set helpMessage($m,[incr menuindex]) EditTrial

$m add cascade -label EditStrip -menu $m.strip
set helpMessage($m,[incr menuindex]) EditStrip

menu $m.strip
$m.strip add command -label EditStripComments -command {::game::Strip comments}
set helpMessage($m.strip,0) EditStripComments
$m.strip add command -label EditStripVars -command {::game::Strip variations}
set helpMessage($m.strip,1) EditStripVars
$m.strip add command -label EditStripBegin -command {::game::TruncateBegin}
set helpMessage($m.strip,2) EditStripBegin
$m.strip add command -label EditStripEnd -command {::game::Truncate}
set helpMessage($m.strip,3) EditStripEnd

$m add separator
incr menuindex

$m add command -label EditReset -command {
  sc_clipbase clear
  updateBoard -pgn
  ::windows::gamelist::Refresh
  updateTitle
}
set helpMessage($m,[incr menuindex]) EditReset

$m add command -label EditCopy -accelerator "Ctrl+C" -command {
  catch {sc_clipbase copy}
  updateBoard
}
bind $dot_w <Control-c> {catch {sc_clipbase copy}; updateBoard}
bind $dot_w <Control-Insert> {catch {sc_clipbase copy}; updateBoard}
set helpMessage($m,[incr menuindex]) EditCopy

$m add command -label EditPaste -accelerator "Ctrl+V" -command {
  sc_clipbase paste
  updateBoard -pgn
}
bind $dot_w <Control-v> {catch {sc_clipbase paste}; updateBoard -pgn}
bind $dot_w <Shift-Insert> {catch {sc_clipbase paste}; updateBoard -pgn}
set helpMessage($m,[incr menuindex]) EditPaste

$m add command -label EditPastePGN -command importClipboardGame
set helpMessage($m,[incr menuindex]) EditPastePGN

$m add separator
incr menuindex

$m add command -label EditSetup -accelerator "Ctrl+Shift+S" -command setupBoard
bind $dot_w <Control-S> setupBoard
set helpMessage($m,[incr menuindex]) EditSetup

$m add command -label EditCopyBoard -accelerator "Ctrl+Shift+C" -command copyFEN
bind $dot_w <Control-C> copyFEN
set helpMessage($m,[incr menuindex]) EditCopyBoard

$m add command -label EditPasteBoard -accelerator "Ctrl+Shift+V" -command pasteFEN
bind $dot_w <Control-V> pasteFEN
set helpMessage($m,[incr menuindex]) EditPasteBoard


### Game menu:
set menuindex -1
set m .menu.game
$m add command -label GameNew -accelerator "Ctrl+X" -command ::game::Clear
bind $dot_w <Control-x> ::game::Clear
set helpMessage($m,[incr menuindex]) GameNew

$m add command -label GameFirst -accelerator "Ctrl+Shift+Up" -command {::game::LoadNextPrev first}
bind $dot_w <Control-Shift-Up> {::game::LoadNextPrev first}
set helpMessage($m,[incr menuindex]) GameFirst

$m add command -label GamePrev -accelerator "Ctrl+Up" -command {::game::LoadNextPrev previous}
bind $dot_w <Control-Up> {::game::LoadNextPrev previous}
set helpMessage($m,[incr menuindex]) GamePrev

$m add command -label GameReload -command ::game::Reload -accelerator "Ctrl+Shift+L"
bind $dot_w <Control-L> ::game::Reload
set helpMessage($m,[incr menuindex]) GameReload

$m add command -label GameNext -accelerator "Ctrl+Down" -command {::game::LoadNextPrev next}
bind $dot_w <Control-Down> {::game::LoadNextPrev next}
set helpMessage($m,[incr menuindex]) GameNext

$m add command -label GameLast -accelerator "Ctrl+Shift+Down" -command {::game::LoadNextPrev last}
bind $dot_w <Control-Shift-Down> {::game::LoadNextPrev last}
set helpMessage($m,[incr menuindex]) GameLast

$m add command -label GameRandom -command ::game::LoadRandom -accelerator "Ctrl+?"
bind $dot_w <Control-question> ::game::LoadRandom
set helpMessage($m,[incr menuindex]) GameRandom

$m add command -label GameNumber -command ::game::LoadNumber -accelerator "Ctrl+G"
bind $dot_w <Control-g> ::game::LoadNumber
set helpMessage($m,[incr menuindex]) GameNumber

$m add separator
incr menuindex

$m add command -label GameReplace -command gameReplace -accelerator "Ctrl+R"
bind $dot_w <Control-r> { .menu.game invoke [tr GameReplace] }
set helpMessage($m,[incr menuindex]) GameReplace

$m  add command -label GameAdd -command gameAdd  -accelerator "Ctrl+S"
bind $dot_w <Control-s> gameAdd
set helpMessage($m,[incr menuindex]) GameAdd

$m add separator
incr menuindex

$m add command -label GameDeepest -accelerator "Ctrl+Shift+D" -command {
  sc_move ply [sc_eco game ply]
  updateBoard
}
bind $dot_w <Control-D> {sc_move ply [sc_eco game ply]; updateBoard}
set helpMessage($m,[incr menuindex]) GameDeepest

$m add command -label GameGotoMove -accelerator "Ctrl+U" -command ::game::GotoMoveNumber
set helpMessage($m,[incr menuindex]) GameGotoMove
bind $dot_w <Control-u> ::game::GotoMoveNumber

$m add command -label GameNovelty -accelerator "Ctrl+Shift+Y" -command findNovelty
bind $dot_w <Control-Y> findNovelty
set helpMessage($m,[incr menuindex]) GameNovelty


### Search menu:
set menuindex -1
set m .menu.search
$m  add command -label SearchReset -acc "Ctrl+F" -command ::search::filter::reset
bind $dot_w <Control-f> search::filter::reset
set helpMessage($m,[incr menuindex]) SearchReset

$m  add command -label SearchNegate -acc "Ctrl+Shift+F" -command ::search::filter::negate
bind $dot_w <Control-F> ::search::filter::negate
set helpMessage($m,[incr menuindex]) SearchNegate

$m  add separator
incr menuindex

$m  add command -label SearchCurrent -command ::search::board -accelerator "Ctrl+Shift+B"
bind $dot_w <Control-B> ::search::board
set helpMessage($m,[incr menuindex]) SearchCurrent

$m  add command -label SearchHeader -command ::search::header -accelerator "Ctrl+Shift+H"
bind $dot_w <Control-H> ::search::header
set helpMessage($m,[incr menuindex]) SearchHeader

$m  add command -label SearchMaterial -command ::search::material -accelerator "Ctrl+Shift+M"
bind $dot_w <Control-M> ::search::material
set helpMessage($m,[incr menuindex]) SearchMaterial

$m  add separator
incr menuindex

$m add command -label SearchUsing -accel "Ctrl+Shift+U" -command ::search::usefile
bind $dot_w <Control-KeyPress-U> ::search::usefile
set helpMessage($m,[incr menuindex]) SearchUsing

### Play menu:
set menuindex -1
set m .menu.play

$m add command -label ToolsSeriousGame -command ::sergame::config
incr menuindex
$m add command -label ToolsTacticalGame -command ::tacgame::config
incr menuindex
$m add command -label ToolsTrainFics -command ::fics::config
incr menuindex
$m add separator
incr menuindex

# sub-menu for training
menu $m.training
$m add cascade -label ToolsTraining -menu $m.training
set helpMessage($m,[incr menuindex]) ToolsTraining
$m.training add command -label ToolsTrainOpenings -command ::opening::config
$m.training add command -label ToolsTrainTactics -command ::tactics::config
$m.training add command -label ToolsTrainCalvar -command ::calvar::config
$m.training add command -label ToolsTrainFindBestMove -command ::tactics::findBestMove

$m add separator
incr menuindex

# Add support for Correspondence Chess by means of Xfcc and cmail
menu $m.correspondence
$m add cascade -label CorrespondenceChess -menu $m.correspondence
set helpMessage($m,[incr menuindex]) CorrespondenceChess

$m.correspondence add command -label CCConfigure   -command {::CorrespondenceChess::config}
set helpMessage($m.correspondence,0) CCConfigure

$m.correspondence add separator
$m.correspondence add command -label CCOpenDB      -command {::CorrespondenceChess::OpenCorrespondenceDB; ::CorrespondenceChess::ReadInbox} \
    -accelerator "Ctrl+F12"
bind $dot_w <Control-F12> {::CorrespondenceChess::OpenCorrespondenceDB; ::CorrespondenceChess::ReadInbox}
set helpMessage($m.correspondence,2) CCOpenDB

$m.correspondence add separator
$m.correspondence add command -label CCRetrieve    -command { ::CorrespondenceChess::FetchGames }
set helpMessage($m.correspondence,4) CCRetrieve

$m.correspondence add command -label CCInbox       -command { ::CorrespondenceChess::ReadInbox }
set helpMessage($m.correspondence,5) CCInbox

$m.correspondence add separator
$m.correspondence add command -label CCSend        -command {::CorrespondenceChess::SendMove 0 0 0 0}
set helpMessage($m.correspondence,7) CCSend
$m.correspondence add command -label CCResign      -command {::CorrespondenceChess::SendMove 1 0 0 0}
set helpMessage($m.correspondence,8) CCResign
$m.correspondence add command -label CCClaimDraw   -command {::CorrespondenceChess::SendMove 0 1 0 0}
set helpMessage($m.correspondence,9) CCClaimDraw
$m.correspondence add command -label CCOfferDraw   -command {::CorrespondenceChess::SendMove 0 0 1 0}
set helpMessage($m.correspondence,10) CCOfferDraw
$m.correspondence add command -label CCAcceptDraw  -command {::CorrespondenceChess::SendMove 0 0 0 1}
set helpMessage($m.correspondence,11) CCAcceptDraw
$m.correspondence add command -label CCGamePage    -command {::CorrespondenceChess::CallWWWGame}
set helpMessage($m.correspondence,12) CCGamePage
$m.correspondence add separator
$m.correspondence add command -label CCNewMailGame -command {::CorrespondenceChess::newEMailGame}
set helpMessage($m.correspondence,14) CCNewMailGame
$m.correspondence add command -label CCMailMove    -command {::CorrespondenceChess::eMailMove}
set helpMessage($m.correspondence,15) CCMailMove


### Windows menu:
set menuindex -1
set m .menu.windows
$m  add checkbutton -label WindowsComment -var commentWin -command makeCommentWin -accelerator "Ctrl+E"

bind $dot_w <Control-e> makeCommentWin
set helpMessage($m,[incr menuindex]) WindowsComment

$m  add checkbutton -label WindowsGList \
    -variable ::windows::gamelist::isOpen -command ::windows::gamelist::Open  -accelerator "Ctrl+L"
bind $dot_w <Control-l> ::windows::gamelist::Open
set helpMessage($m,[incr menuindex]) WindowsGList

$m  add checkbutton -label WindowsPGN -variable pgnWin -command ::pgn::OpenClose  -accelerator "Ctrl+P"
bind $dot_w <Control-p> ::pgn::OpenClose
set helpMessage($m,[incr menuindex]) WindowsPGN

$m add checkbutton -label WindowsPList -variable plistWin -command ::plist::toggle -accelerator "Ctrl+Shift+P"
bind $dot_w <Control-P> ::plist::toggle
set helpMessage($m,[incr menuindex]) WindowsPList

$m add checkbutton -label WindowsTmt -variable tourneyWin -command ::tourney::toggle -accelerator "Ctrl+Shift+T"
bind $dot_w <Control-T> ::tourney::toggle
set helpMessage($m,[incr menuindex]) WindowsTmt

$m add separator
incr menuindex

$m add checkbutton -label WindowsSwitcher -variable baseWin -accelerator "Ctrl+D" -command ::windows::switcher::Open
set helpMessage($m,[incr menuindex]) WindowsSwitcher

$m add checkbutton -label WindowsMaint -accelerator "Ctrl+M" -variable maintWin -command ::maint::OpenClose
bind $dot_w <Control-m> ::maint::OpenClose
set helpMessage($m,[incr menuindex]) WindowsMaint

$m add separator
incr menuindex

$m add checkbutton -label WindowsECO -accelerator "Ctrl+Y" -variable ::windows::eco::isOpen -command {::windows::eco::OpenClose}
bind $dot_w <Control-y> ::windows::eco::OpenClose
set helpMessage($m,[incr menuindex]) WindowsECO

$m add checkbutton -label WindowsRepertoire -variable ::rep::Win -accelerator "Ctrl+Shift+R" -command ::rep::OpenCloseWindow
bind $dot_w <Control-R> ::rep::OpenCloseWindow
set helpMessage($m,[incr menuindex]) WindowsRepertoire

$m add checkbutton -label WindowsStats -variable ::windows::stats::isOpen -accelerator "Ctrl+I" -command ::windows::stats::Open
bind $dot_w <Control-i> ::windows::stats::Open
set helpMessage($m,[incr menuindex]) WindowsStats

$m add checkbutton -label WindowsTree -variable treeWin -command ::tree::make -accelerator "Ctrl+T"
bind $dot_w <Control-t> { .menu.windows invoke [tr WindowsTree] }
set helpMessage($m,[incr menuindex]) WindowsTree

$m add checkbutton -label WindowsTB -variable ::tb::isOpen -command ::tb::Open -accelerator "Ctrl+="
bind $dot_w <Control-equal> ::tb::Open
set helpMessage($m,[incr menuindex]) WindowsTB

$m add checkbutton -label WindowsBook -variable ::book::isOpen -command ::book::open -accelerator "F11"
set helpMessage($m,[incr menuindex]) WindowsBook
bind $dot_w <F11>  ::book::open

$m add checkbutton -label WindowsCorrChess -variable ::CorrespondenceChess::isOpen \
    -command ::CorrespondenceChess::CCWindow -accelerator "F12"
bind $dot_w <F12> ::CorrespondenceChess::CCWindow

### Tools menu:

set menuindex -1
set m .menu.tools
$m  add checkbutton -label ToolsAnalysis -variable analysisWin1 \
    -command makeAnalysisWin -accelerator "Ctrl+Shift+A"
bind $dot_w <Control-A> makeAnalysisWin
set helpMessage($m,[incr menuindex]) ToolsAnalysis

$m  add checkbutton -label ToolsAnalysis2 -variable analysisWin2 \
    -command "makeAnalysisWin 2" -accelerator "Ctrl+Shift+2"
bind $dot_w <Control-at> "makeAnalysisWin 2"
set helpMessage($m,[incr menuindex]) ToolsAnalysis2

#Add Menu for Start Engine 1 and Engine 2
$m  add checkbutton -label ToolsStartEngine1 -variable analysisWin1 \
    -command "makeAnalysisWin 1 0" -accelerator "F2"
bind $dot_w <F2> "makeAnalysisWin 1 0"
set helpMessage($m,[incr menuindex]) ToolsStartEngine1

$m  add checkbutton -label ToolsStartEngine2 -variable analysisWin2 \
    -command "makeAnalysisWin 2 0" -accelerator "F3"
bind $dot_w <F3> "makeAnalysisWin 2 0"
set helpMessage($m,[incr menuindex]) ToolsStartEngine2

$m add separator
incr menuindex

$m add command -label ToolsCross \
    -accelerator "Ctrl+Shift+X" -command crosstabWin
bind $dot_w <Control-X> crosstabWin
set helpMessage($m,[incr menuindex]) ToolsCross

$m add checkbutton -label ToolsEmail \
    -accelerator "Ctrl+Shift+E" -variable emailWin -command ::tools::email
bind $dot_w <Control-E> ::tools::email
set helpMessage($m,[incr menuindex]) ToolsEmail

$m add checkbutton -label ToolsFilterGraph \
    -accelerator "Ctrl+Shift+G" -variable filterGraph -command tools::graphs::filter::Open
bind $dot_w <Control-G> tools::graphs::filter::Open
set helpMessage($m,[incr menuindex]) ToolsFilterGraph

$m add checkbutton -label ToolsAbsFilterGraph \
    -accelerator "Ctrl+Shift+J" -variable absfilterGraph -command tools::graphs::absfilter::Open
bind $dot_w <Control-J> tools::graphs::absfilter::Open
set helpMessage($m,[incr menuindex]) ToolsAbsFilterGraph

$m add command -label ToolsOpReport \
    -accelerator "Ctrl+Shift+O" -command ::optable::makeReportWin
bind $dot_w <Control-O> ::optable::makeReportWin
set helpMessage($m,[incr menuindex]) ToolsOpReport

$m add command -label ToolsTracker \
    -accelerator "Ctrl+Shift+K" -command ::ptrack::make
bind $dot_w <Control-K> ::ptrack::make
set helpMessage($m,[incr menuindex]) ToolsTracker

# book tuning
$m add command -label ToolsBookTuning -command ::book::tuning
set helpMessage($m,[incr menuindex]) ToolsBookTuning

# Connect Hardware
menu $m.hardware
$m add cascade -label ToolsConnectHardware -menu $m.hardware
set helpMessage($m,[incr menuindex]) ToolsConnectHardware
incr menuindex
$m.hardware add command -label ToolsConnectHardwareConfigure -command ::ExtHardware::config
set helpMessage($m.hardware,0) ToolsConnectHardwareConfigure
$m.hardware add command -label ToolsConnectHardwareInputEngineConnect -command ::inputengine::connectdisconnect
set helpMessage($m.hardware,1) ToolsConnectHardwareInputEngineConnect
$m.hardware add command -label ToolsConnectHardwareNovagCitrineConnect -command ::novag::connect
set helpMessage($m.hardware,2) ToolsConnectHardwareNovagCitrineConnect

$m add separator
incr menuindex

menu $m.pinfo
$m add cascade -label ToolsPInfo -menu $m.pinfo
set helpMessage($m,[incr menuindex]) ToolsPInfo
$m.pinfo add command -label White -underline 0 -command {
  playerInfo [sc_game info white]
}
$m.pinfo add command -label Black -underline 0 -command {
  playerInfo [sc_game info black]
}

$m add command -label ToolsPlayerReport -command ::preport::preportDlg -state disabled
set helpMessage($m,[incr menuindex]) ToolsPlayerReport

$m add command -label ToolsRating -command {::tools::graphs::rating::Refresh both}
# bind $dot_w <Control-R> {::tools::graphs::rating::Refresh both}
set helpMessage($m,[incr menuindex]) ToolsRating

$m add command -label ToolsScore \
    -accelerator "Ctrl+Shift+Z" -command ::tools::graphs::score::Refresh
bind $dot_w <Control-Z> ::tools::graphs::score::Refresh
set helpMessage($m,[incr menuindex]) ToolsScore

$m add separator
incr menuindex

menu $m.exportcurrent

$m add cascade -label ToolsExpCurrent -menu $m.exportcurrent
set helpMessage($m,[incr menuindex]) ToolsExpCurrent

$m.exportcurrent add command -label ToolsExpCurrentPGN \
    -command {exportGames current PGN}
set helpMessage($m.exportcurrent,0) ToolsExpCurrentPGN

$m.exportcurrent add command -label ToolsExpCurrentHTML \
    -command {exportGames current HTML}
set helpMessage($m.exportcurrent,1) ToolsExpCurrentHTML

$m.exportcurrent add command -label ToolsExpCurrentHTMLJS \
    -command {::html::exportCurrentGame}
set helpMessage($m.exportcurrent,2) ToolsExpCurrentHTMLJS

$m.exportcurrent add command -label ToolsExpCurrentLaTeX \
    -command {exportGames current LaTeX}
set helpMessage($m.exportcurrent,3) ToolsExpCurrentLaTeX

menu $m.exportfilter

$m add cascade -label ToolsExpFilter -menu $m.exportfilter
set helpMessage($m,[incr menuindex]) ToolsExpFilter

$m.exportfilter add command -label ToolsExpFilterPGN \
    -command {exportGames filter PGN}
set helpMessage($m.exportfilter,0) ToolsExpFilterPGN

$m.exportfilter add command -label ToolsExpFilterHTML \
    -command {exportGames filter HTML}
set helpMessage($m.exportfilter,1) ToolsExpFilterHTML

$m.exportfilter add command -label ToolsExpFilterHTMLJS \
    -command {::html::exportCurrentFilter}
set helpMessage($m.exportfilter,2) ToolsExpFilterHTMLJS

$m.exportfilter add command -label ToolsExpFilterLaTeX \
    -command {exportGames filter LaTeX}
set helpMessage($m.exportfilter,3) ToolsExpFilterLaTeX

$m add separator
incr menuindex

$m add command -label ToolsImportOne \
    -accelerator "Ctrl+Shift+I" -command importPgnGame
bind $dot_w <Control-I> importPgnGame
set helpMessage($m,[incr menuindex]) ToolsImportOne

$m add command -label ToolsImportFile -command importPgnFile
set helpMessage($m,[incr menuindex]) ToolsImportFile

### Options menu:

set m .menu.options
set optMenus {board export fonts ginfo language entry numbers startup windows theme}
set optLabels {Board Export Fonts GInfo Language Moves Numbers Startup Windows Theme}
set menuindex -1
foreach menu $optMenus label $optLabels {
  $m add cascade -label Options$label -menu $m.$menu
  set helpMessage($m,[incr menuindex]) Options$label
}

$m add command -label OptionsSounds -command ::utils::sound::OptionsDialog
set helpMessage($m,[incr menuindex]) OptionsSounds

$m add command -label OptionsToolbar -command configToolbar
set helpMessage($m,[incr menuindex]) OptionsToolbar

$m add separator
incr menuindex

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
set helpMessage($m,[incr menuindex]) OptionsECO

$m add command -label OptionsSpell -command readSpellCheckFile
set helpMessage($m,[incr menuindex]) OptionsSpell

$m add command -label OptionsTable -command setTableBaseDir
set helpMessage($m,[incr menuindex]) OptionsTable
if {![sc_info tb]} { $m entryconfigure 13 -state disabled }

# setTableBaseDir:
#    Prompt user to select a tablebase file; all the files in its
#    directory will be used.
#
proc setTableBaseDir {} {
  global initialDir tempDir
  set ftype { { "Tablebase files" {".emd" ".nbw" ".nbb"} } }
  
  set w .tbDialog
  toplevel $w
  ::setTitle $w Scid
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
set helpMessage($m,[incr menuindex]) OptionsRecent

$m add command -label OptionsBooksDir -command setBooksDir
set helpMessage($m,[incr menuindex]) OptionsBooksDir

$m add command -label OptionsTacticsBasesDir -command setTacticsBasesDir
set helpMessage($m,[incr menuindex]) OptionsTacticsBasesDir

proc setBooksDir {} {
  global scidBooksDir
  set dir [tk_chooseDirectory -initialdir $scidBooksDir -mustexist 1]
  if {$dir == ""} {
    return
  } else {
    set scidBooksDir $dir
  }
}

proc setTacticsBasesDir {} {
  global scidBasesDir
  set dir [tk_chooseDirectory -initialdir $scidBasesDir -mustexist 1]
  if {$dir == ""} {
    return
  } else {
    set scidBasesDir $dir
  }
}

$m add separator
incr menuindex

$m add command -label OptionsSave -command {
  set optionF ""
  if {[catch {open [scidConfigFile options] w} optionF]} {
    tk_messageBox -title "Scid: Unable to write file" -type ok -icon warning \
        -message "Unable to write options file: [scidConfigFile options]\n$optionF"
  } else {
    puts $optionF "# Scid options file"
    puts $optionF "# Version: $scidVersion"
    puts $optionF "# This file contains commands in the Tcl language format."
    puts $optionF "# If you edit this file, you must preserve valid its Tcl"
    puts $optionF "# format or it will not set your Scid options properly."
    puts $optionF ""
    foreach i {boardSize boardStyle language ::pgn::showColor \
          ::pgn::indentVars ::pgn::indentComments \
          ::pgn::shortHeader ::pgn::boldMainLine ::pgn::stripMarks \
          ::pgn::symbolicNags ::pgn::moveNumberSpaces ::pgn::columnFormat myPlayerNames \
          tree(order) tree(autoSave) optionsAutoSave ::tree::mask::recentMask \
          ecoFile suggestMoves showVarPopup glistSize glexport \
          blunderThreshold autoplayDelay animateDelay boardCoords boardSTM \
          moveEntry(AutoExpand) moveEntry(Coord) \
          translatePieces askToReplaceMoves ::windows::switcher::vertical locale(numeric) \
          spellCheckFile ::splash::autoclose autoRaise autoIconify windowsDock showGameInfo autoLoadLayout \
          exportFlags(comments) exportFlags(vars) \
          exportFlags(indentc) exportFlags(indentv) \
          exportFlags(column) exportFlags(symbols) \
          exportFlags(htmldiag) exportFlags(convertNullMoves) \
          email(smtp) email(smproc) email(server) \
          email(from) email(bcc) \
          gameInfo(photos) gameInfo(hideNextMove) gameInfo(wrap) \
          gameInfo(fullComment) gameInfo(showMarks) \
          gameInfo(showMaterial) gameInfo(showFEN) gameInfo(showTB) \
          engineCoach1 engineCoach2 scidBooksDir scidBasesDir ::book::lastBook \
          ::utils::sound::soundFolder ::utils::sound::announceNew \
          ::utils::sound::announceForward ::utils::sound::announceBack \
          ::tacgame::threshold ::tacgame::blunderwarning ::tacgame::blunderwarningvalue \
          ::tacgame::levelMin  ::tacgame::levelMax  ::tacgame::levelFixed ::tacgame::randomLevel \
          ::tacgame::isLimitedAnalysisTime ::tacgame::showblunder ::tacgame::showblundervalue \
          ::tacgame::showblunderfound ::tacgame::showmovevalue ::tacgame::showevaluation \
          ::tacgame::isLimitedAnalysisTime ::tacgame::analysisTime ::tacgame::openingType ::tacgame::chosenOpening \
          ::sergame::chosenOpening ::sergame::chosenEngine ::sergame::useBook ::sergame::bookToUse \
          ::sergame::startFromCurrent ::sergame::coachIsWatching ::sergame::timeMode \
          ::sergame::depth ::sergame::movetime ::sergame::nodes ::sergame::ponder ::sergame::isOpening \
          ::uci::uciInfo(wtime3) ::uci::uciInfo(winc3) ::uci::uciInfo(btime3) ::uci::uciInfo(binc3) \
          boardfile_lite boardfile_dark \
          FilterMaxMoves FilterMinMoves FilterStepMoves FilterMaxElo FilterMinElo FilterStepElo \
          FilterMaxYear FilterMinYear FilterStepYear FilterGuessELO lookTheme autoResizeBoard } {
      puts $optionF "set $i [list [set $i]]"
    }
    puts $optionF ""
    foreach i [lsort [array names winWidth]] {
      puts $optionF "set winWidth($i)  [expr $winWidth($i)]"
      puts $optionF "set winHeight($i) [expr $winHeight($i)]"
    }
    puts $optionF ""
    foreach i [lsort [array names winX]] {
      puts $optionF "set winX($i)  [expr $winX($i)]"
      puts $optionF "set winY($i)  [expr $winY($i)]"
    }
    puts $optionF ""
    foreach i [lsort [array names winWidth_docked]] {
      puts $optionF "set winWidth_docked($i)  [expr $winWidth_docked($i)]"
      puts $optionF "set winHeight_docked($i) [expr $winHeight_docked($i)]"
    }
    puts $optionF ""
    foreach i [lsort [array names winX_docked]] {
      puts $optionF "set winX_docked($i)  [expr $winX_docked($i)]"
      puts $optionF "set winY_docked($i)  [expr $winY_docked($i)]"
    }
    puts $optionF ""
    puts $optionF "set analysisCommand [list $analysisCommand]"
    puts $optionF "set analysisChoices [list $analysisChoices]"
    puts $optionF ""
    foreach i {lite dark whitecolor blackcolor highcolor bestcolor \
          whiteborder blackborder borderwidth \
          pgnColor(Header) pgnColor(Main) pgnColor(Var) \
          pgnColor(Nag) pgnColor(Comment) pgnColor(Background) \
          pgnColor(Current) pgnColor(NextMove) } {
      puts $optionF "set $i [list [set $i]]"
    }
    puts $optionF ""
    foreach i [lsort [array names optable]] {
      puts $optionF "set optable($i) [list $optable($i)]"
    }
    foreach i [lsort [array names ::windows::stats::display]] {
      puts $optionF "set ::windows::stats::display($i) [list $::windows::stats::display($i)]"
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
    puts $optionF ""
    foreach i {Regular Menu Small Tiny Fixed} {
      puts $optionF "set fontOptions($i) [list $fontOptions($i)]"
    }
    puts $optionF ""
    puts $optionF "set glistFields [list $glistFields]"
    foreach type {base book html tex tablebase1 tablebase2 tablebase3 tablebase4} {
      puts $optionF "set initialDir($type) [list $initialDir($type)]"
    }
    puts $optionF ""
    foreach type {PGN HTML LaTeX} {
      puts $optionF "set exportStartFile($type) [list $exportStartFile($type)]"
      puts $optionF "set exportEndFile($type) [list $exportEndFile($type)]"
    }
    puts $optionF ""
    foreach i [lsort [array names informant]] {
      puts $optionF "set informant($i) [list $informant($i)]"
    }
    puts $optionF ""
    
    # save FICS config
    foreach i { use_timeseal timeseal_exec port_fics port_timeseal login password usedefaultvars consolebg consolefg consoleheight consolewidth colseeking colgame colgameresult colficspercent} {
      puts $optionF "set ::fics::$i [list [set ::fics::$i]]"
    }
    # foreach i [lsort [array names ::fics::findopponent]] {
    # puts $optionF "set ::fics::findopponent($i) [list $::fics::findopponent($i)]"
    # }
    foreach i [lsort [array names ::fics::profileVars]] {
      puts $optionF "set ::fics::profileVars($i) [list $::fics::profileVars($i)]"
    }
    
    # Save layouts
    foreach slot {1 2 3} {
      puts $optionF "set ::docking::layout_list($slot) [list $::docking::layout_list($slot)]"
    }
    
    close $optionF
    set ::statusBar "Options were saved to: [scidConfigFile options]"
  }
}
set helpMessage($m,[incr menuindex]) OptionsSave

$m add checkbutton -label OptionsAutoSave -variable optionsAutoSave
set helpMessage($m,[incr menuindex]) OptionsAutoSave

menu $m.ginfo
$m.ginfo add checkbutton -label GInfoHideNext \
    -variable gameInfo(hideNextMove) -offvalue 0 -onvalue 1 -command updateBoard
$m.ginfo add checkbutton -label GInfoMaterial \
    -variable gameInfo(showMaterial) -offvalue 0 -onvalue 1 -command toggleShowMaterial
$m.ginfo add checkbutton -label GInfoFEN \
    -variable gameInfo(showFEN) -offvalue 0 -onvalue 1 -command updateBoard
$m.ginfo add checkbutton -label GInfoMarks \
    -variable gameInfo(showMarks) -offvalue 0 -onvalue 1 -command updateBoard
$m.ginfo add checkbutton -label GInfoWrap \
    -variable gameInfo(wrap) -offvalue 0 -onvalue 1 -command updateBoard
$m.ginfo add checkbutton -label GInfoFullComment \
    -variable gameInfo(fullComment) -offvalue 0 -onvalue 1 -command updateBoard
$m.ginfo add checkbutton -label GInfoPhotos \
    -variable gameInfo(photos) -offvalue 0 -onvalue 1 \
    -command {updatePlayerPhotos -force}
$m.ginfo add separator
$m.ginfo add radiobutton -label GInfoTBNothing \
    -variable gameInfo(showTB) -value 0 -command updateBoard
$m.ginfo add radiobutton -label GInfoTBResult \
    -variable gameInfo(showTB) -value 1 -command updateBoard
$m.ginfo add radiobutton -label GInfoTBAll \
    -variable gameInfo(showTB) -value 2 -command updateBoard
$m.ginfo add separator
$m.ginfo add command -label GInfoInformant -command configInformant

menu $m.entry
$m.entry add checkbutton -label OptionsMovesAsk \
    -variable askToReplaceMoves -offvalue 0 -onvalue 1
set helpMessage($m.entry,0) OptionsMovesAsk \
    
$m.entry add cascade -label OptionsMovesAnimate -menu $m.entry.animate
menu $m.entry.animate
foreach i {0 100 150 200 250 300 400 500 600 800 1000} {
  $m.entry.animate add radiobutton -label "$i ms" \
      -variable animateDelay -value $i
}
set helpMessage($m.entry,1) OptionsMovesAnimate

$m.entry add command -label OptionsMovesDelay -command setAutoplayDelay
set helpMessage($m.entry,2) OptionsMovesDelay

$m.entry add checkbutton -label OptionsMovesCoord \
    -variable moveEntry(Coord) -offvalue 0 -onvalue 1
set helpMessage($m.entry,3) OptionsMovesCoord

$m.entry add checkbutton -label OptionsMovesKey \
    -variable moveEntry(AutoExpand) -offvalue 0 -onvalue 1
set helpMessage($m.entry,4) OptionsMovesKey

$m.entry add checkbutton -label OptionsMovesSuggest \
    -variable suggestMoves -offvalue 0 -onvalue 1
set helpMessage($m.entry,5) OptionsMovesSuggest

$m.entry add checkbutton -label OptionsShowVarPopup \
    -variable showVarPopup -offvalue 0 -onvalue 1
set helpMessage($m.entry,6) OptionsShowVarPopup

$m.entry add checkbutton -label OptionsMovesSpace \
    -variable ::pgn::moveNumberSpaces -offvalue 0 -onvalue 1
set helpMessage($m.entry,7) OptionsMovesSpace

$m.entry add checkbutton -label OptionsMovesTranslatePieces \
    -variable ::translatePieces -offvalue 0 -onvalue 1 -command setLanguage
set helpMessage($m.entry,8) OptionsMovesTranslatePieces

proc updateLocale {} {
  global locale
  sc_info decimal $locale(numeric)
  ::windows::gamelist::Refresh
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
$m add checkbutton -label OptionsWindowsDock -variable windowsDock
set helpMessage($m,2) OptionsWindowsDock
$m add checkbutton -label OptionsWindowsShowGameInfo -variable showGameInfo -command ::toggleGameInfo
set helpMessage($m,3) OptionsShowGameInfo

if { $::docking::USE_DOCKING } {
  set state "normal"
} else  {
  set state "disabled"
}
$m add checkbutton -label OptionsWindowsAutoLoadLayout -variable autoLoadLayout -state $state
set helpMessage($m,4) OptionsWindowsAutoLoadLayout

if {$::docking::USE_DOCKING} {
  menu $m.savelayout
  menu $m.restorelayout
  foreach i {"1 (default)" "2" "3"} slot {1 2 3} {
    $m.savelayout add command -label $i -command "::docking::layout_save $slot"
    $m.restorelayout add command -label $i -command "::docking::layout_restore $slot"
  }
  $m add cascade -label OptionsWindowsSaveLayout -menu $m.savelayout
  set helpMessage($m,5) OptionsWindowsSaveLayout
  $m add cascade -label OptionsWindowsRestoreLayout -menu $m.restorelayout
  set helpMessage($m,6) OptionsWindowsRestoreLayout
}

set m .menu.options.theme
menu $m
foreach i [ttk::style theme names] {
  $m add radiobutton -label "$i" -value $i -variable ::lookTheme -command {ttk::style theme use $::lookTheme}
}

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
  font configure font_H1 -family $font -size [expr {$fontsize + 8} ]
  font configure font_H2 -family $font -size [expr {$fontsize + 6} ]
  font configure font_H3 -family $font -size [expr {$fontsize + 4} ]
  font configure font_H4 -family $font -size [expr {$fontsize + 2} ]
  font configure font_H5 -family $font -size [expr {$fontsize + 0} ]
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

# The windows that are not dockable are always configurable for auto start
set m .menu.options.startup
menu $m
if { $::docking::USE_DOCKING } {
  set state "disabled"
} else  {
  set state "normal"
}
$m add checkbutton -label HelpTip -variable startup(tip)
$m add checkbutton -label ToolsCross -variable startup(crosstable)
$m add checkbutton -label WindowsSwitcher -variable startup(switcher) -state $state
$m add checkbutton -label FileFinder -variable startup(finder)
$m add checkbutton -label WindowsGList -variable startup(gamelist) -state $state
$m add checkbutton -label WindowsPGN -variable startup(pgn) -state $state
$m add checkbutton -label WindowsStats -variable startup(stats)
$m add checkbutton -label WindowsTree -variable startup(tree) -state $state
$m add checkbutton -label WindowsBook -variable startup(book) -state $state

set m .menu.options.board
menu $m

# Menu for changing board size:
$m add cascade -label OptionsBoardSize -menu $m.bdsize
set helpMessage($m,0) OptionsBoardSize

$m add cascade -label OptionsBoardPieces -menu $m.pieces
set helpMessage($m,1) OptionsBoardPieces

$m add command -label OptionsBoardColors -command chooseBoardColors
set helpMessage($m,2) OptionsBoardColors

#Klimmek: Menu for selecting chessboard textures
# $m add command -label OptionsBoardGraphics -command chooseBoardTextures
# set helpMessage($m,3) OptionsBoardGraphics

$m add separator

$m add command -label OptionsBoardNames -command editMyPlayerNames
set helpMessage($m,4) OptionsBoardNames

menu $m.bdsize
set count 0

foreach i $boardSizes {
  incr count
  set underline -1
  if {$count < 10} {set underline 0}
  if {$count == 10} {set underline 1}
  # PG : dirty workaround !
  $m.bdsize add radio -label $count -variable boardSize -value $i -underline $underline -command "::board::resize2 .main.board $i "
  unset underline
}

# Shortcut keys for changing board size:

bind $dot_w <Control-Shift-Left>  decreaseBoardSize
bind $dot_w <Control-Shift-Right> increaseBoardSize

proc decreaseBoardSize {} {
  global boardSize
  set boardSize [::board::resize2 .main.board -1]
}

proc increaseBoardSize {} {
  global boardSize
  set boardSize [::board::resize2 .main.board +1]
}

# Menu for changing Piece set:
menu $m.pieces
foreach i $boardStyles {
  $m.pieces add radio -label $i \
      -variable boardStyle -value $i \
      -underline 0 -command "setPieceFont $i"
}

### Help menu:
set menuindex -1
set m .menu.helpmenu
# On Mac use accelerator "Command-?" for Help:
if { $macOS } {
  $m add command -label HelpContents -command {helpWindow Contents} -accelerator "Command-?"
  
} else {
  $m add command -label HelpContents -command {helpWindow Contents} -accelerator "F1"
}
set helpMessage($m,[incr menuindex]) HelpContents
$m add command -label HelpIndex -command {helpWindow Index}
set helpMessage($m,[incr menuindex]) HelpIndex
$m add command -label HelpGuide -command {helpWindow Guide}
set helpMessage($m,[incr menuindex]) HelpGuide
$m add command -label HelpHints -command {helpWindow Hints}
set helpMessage($m,[incr menuindex]) HelpHints
$m add command -label HelpContact -command {helpWindow Author}
set helpMessage($m,[incr menuindex]) HelpContact
$m add separator
incr menuindex
$m add command -label HelpTip -command ::tip::show
set helpMessage($m,[incr menuindex]) HelpTip
$m add command -label HelpStartup -command {
  wm deiconify .splash
  raiseWin .splash
}
set helpMessage($m,[incr menuindex]) HelpStartup

$m add separator
incr menuindex

$m  add command -label HelpAbout -command helpAbout
set helpMessage($m,[incr menuindex]) HelpAbout

bind $dot_w <F1> {helpWindow Contents}

### Mac Application Menu:

if { $macOS } {
  # Application menu:
  .menu add cascade -label Scid -menu .menu.apple
  menu .menu.apple
  
  set menuindex -1
  set m .menu.apple
  
  $m add command -label HelpAbout -command helpAbout
  set helpMessage($m,[incr menuindex]) HelpAbout
  
  $m add separator
  incr menuindex
  
  # To Quit
  bind all <Command-q> "exit"
  bind all <Command-Q> "exit"
  
  # To get Help
  bind all <Command-?> {helpWindow Contents}
  bind all <Help> {helpWindow Contents}
  
  # Fix Quitting on MacOS X, now it will save options on quit:
  proc exit {}  {
    ::file::Exit
  }
}


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
    $m.file.switch entryconfig [expr {$i - 1} ] -label "Base $i: $fname"
  }
  foreach i {Compact Delete} {
    $m.file.utils entryconfig [tr FileMaint$i] -state disabled
  }
  foreach i {Player Event Site Round} {
    $m.file.utils.name entryconfig [tr FileMaintName$i] -state disabled
  }
  
  $m.file entryconfig [tr FileReadOnly] -state disabled
  
  # update recent Tree list (open base as Tree)
  set ntreerecent [::recentFiles::treeshow .menu.file.recenttrees]
  
  # Remove and reinsert the Recent files list and Exit command:
  set idx 13
  $m.file delete $idx end
  set nrecent [::recentFiles::show $m.file]
  if {$nrecent > 0} {
    $m.file add separator
  }
  set idx [$m.file index end]
  incr idx
  $m.file add command -label [tr FileExit] -accelerator "Ctrl+Q" \
      -command ::file::Exit
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
    .main.tb.gprev configure -state $state
    
    # Reload button:
    if {[sc_game number]} {set state normal} else {set state disabled}
    $m.game entryconfig [tr GameReload] -state $state
    
    # Load next button:
    if {[sc_filter next]} {set state normal} else {set state disabled}
    $m.game entryconfig [tr GameNext] -state $state
    .main.tb.gnext configure -state $state
    
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
    $m.tools entryconfig [tr ToolsEmail] -state normal
    $m.tools entryconfig [tr ToolsOpReport] -state normal
    $m.tools entryconfig [tr ToolsPlayerReport] -state normal
    
  } else {
    # Base is not in use:
    $m.file entryconfig [tr FileClose] -state disabled
    
    foreach i {First Prev Reload Next Last Random Number Replace Add} {
      $m.game entryconfig [tr Game$i] -state disabled
    }
    .main.tb.gprev configure -state disabled
    .main.tb.gnext configure -state disabled
    
    # search:
    foreach i {Reset Negate} {
      $m.search entryconfig [tr Search$i] -state disabled
    }
    #$m.windows entryconfig [tr WindowsTree] -state disabled
    
    # tools:
    $m.tools entryconfig [tr ToolsEmail] -state disabled
    $m.tools entryconfig [tr ToolsOpReport] -state disabled
    $m.tools entryconfig [tr ToolsPlayerReport] -state disabled
  }
  
  if {[sc_base numGames] == 0} {
    $m.tools entryconfig [tr ToolsExpFilter] -state disabled
  } else {
    $m.tools entryconfig [tr ToolsExpFilter] -state normal
  }
  
  set state disabled
  if {[baseIsCompactable]} { set state normal }
  $m.file.utils entryconfig [tr FileMaintCompact] -state $state
  
  ::search::Config
  ::windows::switcher::Refresh
  ::maint::Refresh
  ::bookmarks::Refresh
}


##############################
#
# Multiple-language menu support functions.

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
  
  foreach tag {CorrespondenceChess ToolsTraining ToolsTacticalGame ToolsSeriousGame ToolsTrainFics} {
    configMenuText .menu.play [tr $tag $oldLang] $tag $lang
  }
  
  foreach tag {TrainOpenings TrainTactics TrainCalvar TrainFindBestMove} {
    configMenuText .menu.play.training [tr Tools$tag $oldLang] Tools$tag $lang
  }
  
  foreach tag { CCConfigure CCOpenDB CCRetrieve CCInbox \
        CCSend CCResign CCClaimDraw CCOfferDraw CCAcceptDraw   \
        CCNewMailGame CCMailMove CCGamePage } {
    configMenuText .menu.play.correspondence [tr $tag $oldLang] $tag $lang
  }
  
  foreach tag {File Edit Game Search Play Windows Tools Options Help} {
    configMenuText .menu [tr $tag $oldLang] $tag $lang
  }
  
  foreach tag {New Open Close Finder Bookmarks Maint ReadOnly Switch Exit} {
    configMenuText .menu.file [tr File$tag $oldLang] File$tag $lang
  }
  
  # open base as tree was moved from tools to file menus
  foreach tag { ToolsOpenBaseAsTree ToolsOpenRecentBaseAsTree } {
    configMenuText .menu.file [tr $tag $oldLang] $tag $lang
  }
  
  foreach tag {Win Compact Delete Twin Class Sort Name FixBase} {
    configMenuText .menu.file.utils [tr FileMaint$tag $oldLang] \
        FileMaint$tag $lang
  }
  foreach tag {Editor Player Event Site Round} {
    configMenuText .menu.file.utils.name [tr FileMaintName$tag $oldLang] \
        FileMaintName$tag $lang
  }
  foreach tag {Add Delete First Main Trial Strip Reset Copy Paste PastePGN Setup
    CopyBoard PasteBoard} {
    configMenuText .menu.edit [tr Edit$tag $oldLang] Edit$tag $lang
  }
  foreach tag {Comments Vars Begin End} {
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
  
  foreach tag {Comment GList PGN PList Tmt Switcher Maint ECO Repertoire Stats Tree TB Book CorrChess } {
    configMenuText .menu.windows [tr Windows$tag $oldLang] Windows$tag $lang
  }
  
  foreach tag {Analysis Analysis2 Cross Email FilterGraph AbsFilterGraph OpReport Tracker
    Rating Score ExpCurrent ExpFilter ImportOne ImportFile StartEngine1 StartEngine2 BookTuning
    PInfo PlayerReport ConnectHardware} {
    configMenuText .menu.tools [tr Tools$tag $oldLang] Tools$tag $lang
  }
  
  .menu.tools.pinfo entryconfigure 0 -label $::tr(White)
  .menu.tools.pinfo entryconfigure 1 -label $::tr(Black)
  foreach tag {ToolsExpCurrentPGN ToolsExpCurrentHTML ToolsExpCurrentHTMLJS ToolsExpCurrentLaTeX} {
    configMenuText .menu.tools.exportcurrent [tr $tag $oldLang] $tag $lang
  }
  foreach tag {ToolsExpFilterPGN ToolsExpFilterHTML ToolsExpFilterHTMLJS ToolsExpFilterLaTeX} {
    configMenuText .menu.tools.exportfilter [tr $tag $oldLang] $tag $lang
  }
  foreach tag {Board Export Fonts GInfo Language Moves Numbers
    Startup Sounds Toolbar Windows Theme ECO Spell Table BooksDir TacticsBasesDir Recent Save AutoSave} {
    configMenuText .menu.options [tr Options$tag $oldLang] Options$tag $lang
  }
  
  foreach tag { Configure NovagCitrineConnect InputEngineConnect  } {
    configMenuText .menu.tools.hardware [tr ToolsConnectHardware$tag $oldLang] ToolsConnectHardware$tag $lang
  }
  
  foreach tag {Regular Menu Small Fixed} {
    configMenuText .menu.options.fonts [tr OptionsFonts$tag $oldLang] \
        OptionsFonts$tag $lang
  }
  foreach tag {Size Pieces Colors Names} {
    configMenuText .menu.options.board [tr OptionsBoard$tag $oldLang] \
        OptionsBoard$tag $lang
  }
  foreach tag {HideNext Material FEN Marks Wrap FullComment Photos \
        TBNothing TBResult TBAll Informant} {
    configMenuText .menu.options.ginfo [tr GInfo$tag $oldLang] \
        GInfo$tag $lang
  }
  configMenuText .menu.options.entry [tr OptionsShowVarPopup $oldLang] OptionsShowVarPopup $lang
  foreach tag {Ask Animate Delay Suggest Key Coord Space TranslatePieces } {
    configMenuText .menu.options.entry [tr OptionsMoves$tag $oldLang] \
        OptionsMoves$tag $lang
  }
  foreach tag {HelpTip WindowsSwitcher WindowsPGN WindowsTree FileFinder \
        ToolsCross WindowsGList WindowsStats WindowsBook} {
    configMenuText .menu.options.startup [tr $tag $oldLang] $tag $lang
  }
  
  foreach tag {Iconify Raise Dock ShowGameInfo AutoLoadLayout} {
    configMenuText .menu.options.windows [tr OptionsWindows$tag $oldLang] \
        OptionsWindows$tag $lang
  }
  if {$::docking::USE_DOCKING} {
    foreach tag {SaveLayout RestoreLayout} {
      configMenuText .menu.options.windows [tr OptionsWindows$tag $oldLang] \
          OptionsWindows$tag $lang
    }
  }
  foreach tag {Contents Index Guide Hints Contact Tip Startup About} {
    configMenuText .menu.helpmenu [tr Help$tag $oldLang] Help$tag $lang
  }
  
  if { $::macOS } {
    foreach tag {About} {
      configMenuText .menu.apple [tr Help$tag $oldLang] Help$tag $lang
    }
  }
  
  
  foreach tag {HideNext Material FEN Marks Wrap FullComment Photos \
        TBNothing TBResult TBAll Delete Mark} {
    configMenuText .main.gameInfo.menu [tr GInfo$tag $oldLang] GInfo$tag $lang
  }
  
  set i 0
  foreach flag $::maintFlaglist {
    .main.gameInfo.menu.mark entryconfigure $i \
        -label "$::tr($::maintFlags($flag)) ($flag)"
    incr i
  }
  
  ::pgn::ConfigMenus
  ::windows::stats::ConfigMenus
  ::tree::ConfigMenus
  ::crosstab::ConfigMenus
  ::optable::ConfigMenus
  ::preport::ConfigMenus
  ::tourney::ConfigMenus
  
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
  
  # Global shortcuts for docked mode
  if { $::docking::USE_DOCKING } {
    bind $w <F1> {helpWindow Contents}
    bind $w <period> {if {!$tree(refresh)} {toggleRotateBoard}}
    bind $w <Control-N> nameEditor
    bind $w <Control-a> {sc_var create; updateBoard -pgn}
    bind $w <Control-space> { setTrialMode toggle }
    bind $w <Control-D> {sc_move ply [sc_eco game ply]; updateBoard}
    bind $w <Control-u> ::game::GotoMoveNumber
    bind $w <Control-Y> findNovelty
    bind $w <Control-F> ::search::filter::negate
    bind $w <Control-p> ::pgn::OpenClose
    bind $w <Control-P> ::plist::toggle
    bind $w <Control-T> ::tourney::toggle
    bind $w <Control-y> ::windows::eco::OpenClose
    bind $w <Control-equal> ::tb::Open
    bind $w <Control-G> tools::graphs::filter::Open
    bind $w <Control-J> tools::graphs::absfilter::Open
    bind $w <Control-O> ::optable::makeReportWin
    bind $w <Control-K> ::ptrack::make
    
    bind $w <exclam><Return> "sc_pos addNag !; updateBoard -pgn"
    bind $w <exclam><exclam><Return> "sc_pos addNag !!; updateBoard -pgn"
    bind $w <exclam><question><Return> "sc_pos addNag !?; updateBoard -pgn"
    bind $w <question><Return> "sc_pos addNag ?; updateBoard -pgn"
    bind $w <question><question><Return> "sc_pos addNag ??; updateBoard -pgn"
    bind $w <question><exclam><Return> "sc_pos addNag ?!; updateBoard -pgn"
    
    bind $w <plus><minus> "sc_pos addNag +-; updateBoard -pgn"
    bind $w <plus><slash> "sc_pos addNag +/-; updateBoard -pgn"
    bind $w <plus><equal> "sc_pos addNag +=; updateBoard -pgn"
    bind $w <equal><Return> "sc_pos addNag =; updateBoard -pgn"
    bind $w <minus><plus> "sc_pos addNag -+; updateBoard -pgn"
    bind $w <minus><slash> "sc_pos addNag -/+; updateBoard -pgn"
    bind $w <equal><plus> "sc_pos addNag =+; updateBoard -pgn"
    bind $w <asciitilde><Return> "sc_pos addNag ~; updateBoard -pgn"
    bind $w <asciitilde><equal><Return> "sc_pos addNag ~=; updateBoard -pgn"
  }
  
  bind $w <Control-c> {catch {sc_clipbase copy}; ::updateBoard}
  bind $w <Control-d> ::windows::switcher::Open
  bind $w <Control-e> makeCommentWin
  bind $w <Control-f> ::search::filter::reset
  bind $w <Control-g> ::game::LoadNumber
  bind $w <Control-i> ::windows::stats::Open
  bind $w <Control-l> ::windows::gamelist::Open
  bind $w <Control-m> ::maint::OpenClose
  bind $w <Control-n> ::file::New
  bind $w <Control-o> ::file::Open
  bind $w <Control-p> ::pgn::OpenClose
  bind $w <Control-q> ::file::Exit
  bind $w <Control-r> ::gameReplace
  bind $w <Control-s> ::gameAdd
  bind $w <Control-t> ::tree::make
  bind $w <Control-v> {catch {sc_clipbase paste}; ::updateBoard -pgn}
  bind $w <Control-w> ::file::Close
  bind $w <Control-x> ::game::Clear
  
  bind $w <Control-A> makeAnalysisWin
  bind $w <Control-Shift-2>  "makeAnalysisWin 2"
  bind $w <Control-B> ::search::board
  bind $w <Control-C> ::copyFEN
  bind $w <Control-E> ::tools::email
  bind $w <Control-H> ::search::header
  bind $w <Control-I> importPgnGame
  bind $w <Control-L> ::game::Reload
  bind $w <Control-M> ::search::material
  bind $w <Control-O> ::optable::makeReportWin
  bind $w <Control-R> ::rep::OpenCloseWindow
  bind $w <Control-S> ::setupBoard
  bind $w <Control-T> ::tourney::toggle
  bind $w <Control-V> ::pasteFEN
  bind $w <Control-KeyPress-U> ::search:::usefile
  bind $w <Control-X> crosstabWin
  bind $w <Control-Z> ::tools::graphs::score::Refresh
  
  bind $w <Control-slash> ::file::finder::Open
  bind $w <Control-Shift-Up> {::game::LoadNextPrev first}
  bind $w <Control-Shift-Down> {::game::LoadNextPrev last}
  bind $w <Control-Up> {::game::LoadNextPrev previous}
  bind $w <Control-Down> {::game::LoadNextPrev next}
  bind $w <Control-question> ::game::LoadRandom
  
  bind $w <KeyPress-v> { ::showVars }
  bind $w <KeyPress-z> {.main.fbutton.button.exitVar invoke}
  
  for {set i 1} { $i <= $::totalBaseSlots} {incr i} {
    bind $w "<Control-Key-$i>" "::file::SwitchToBase $i"
  }
  
  bind $w <Home>  ::move::Start
  bind $w <Up> {
    if {[sc_pos isAt vstart]} {
      .main.fbutton.button.exitVar invoke
    } else  {
      ::move::Back 10
    }
  }
  bind $w <Left>  { ::move::Back }
  bind $w <Down>  {::move::Forward 10}
  bind $w <Right> ::move::Forward
  bind $w <End>   ::move::End
  bind $w <F2> "::makeAnalysisWin 1 0"
  bind $w <F3> "::makeAnalysisWin 2 0"
  bind $w <F4> { if {[winfo exists .analysisWin1]} { .analysisWin1.b1.bStartStop invoke } }
  bind $w <F5> { if {[winfo exists .analysisWin2]} { .analysisWin2.b1.bStartStop invoke } }
  bind $w <F11>  ::book::open
  bind $w <F12> ::CorrespondenceChess::CCWindow
  bind $w <Control-F12> {::CorrespondenceChess::OpenCorrespondenceDB; ::CorrespondenceChess::ReadInbox}
  bind $w <Alt-F12> {::CorrespondenceChess::OpenCorrespondenceDB;  ::CorrespondenceChess::FetchGames}
}
################################################################################
#
################################################################################
proc configInformant {} {
  global informant
  
  set w .configInformant
  if {[winfo exists $w]} {
    destroy $w
  }
  
  toplevel $w
  ::setTitle $w $::tr(ConfigureInformant)
  setWinLocation $w
  frame $w.spinF
  set idx 0
  set row 0
  
  foreach i [lsort [array names informant]] {
    label $w.spinF.labelExpl$idx -text [ ::tr "Informant[ string trim $i "\""]" ]
    label $w.spinF.label$idx -text $i
    spinbox $w.spinF.sp$idx -textvariable informant($i) -width 3 -from 0.0 -to 9.9 -increment 0.1 -validate all -vcmd { regexp {^[0-9]\.[0-9]$} %P }
    grid $w.spinF.labelExpl$idx -row $row -column 0 -sticky w
    incr row
    grid $w.spinF.label$idx -row $row -column 0 -sticky w
    grid $w.spinF.sp$idx -row $row -column 1 -sticky w
    incr row
    incr idx
  }
  
  button $w.close -textvar ::tr(Close) -command "destroy $w"
  pack $w.spinF $w.close
  bind $w <Configure> "recordWinSize $w"
}

### End of file: menus.tcl

