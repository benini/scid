# english.tcl:
# Text for menu names and status bar help messages in English.
# Part of Scid (Shane's Chess Information Database).
#
# Instructions for adding a new language:
#
# (1) Choose a letter code for the language. Currently assigned codes are:
#      E=English, D=Deutsch, F=Francais, S=Spanish, P=Polish,
#      N=Nederlands, C=Czech.
#
# (2) Edit the code below that has the lines "addLanguage ..." and add your
#     new language. The final digit in each line is the index of the
#     letter to underline in the menu, counting from 0 as the first letter.
#
# (3) Copy the section of English menu and help message details below (all
#     the commands that start "menuText E ..." or "helpMsg E ..." or
#     "translate E ...") and change all the "E" letters to the letter you
#     assigned for the new language.
#
# (4) Write the translations. This involves changing anything "in quotes"
#     or {in braces} for the menuText, helpMsg and translate commands.
#
#     A menu command has the format:
#         menuText L tag "Name..." underline {HelpMessage...}
#
#     A status bar help message for a button has the format:
#         helpMsg L tag {HelpMessage...}
#
#     A general word or message translation has the format:
#         translate L tag {message...}
#
#     where "L" is the language letter, "tag" is the name of the menu entry
#     or the button widget name, and "underline" is the index of the letter
#     to underline, counting from zero as the first letter. Two menu entries
#     that appear in the same menu should have a different underlined letter.
#     If in doubt, just make them all "0" and I'll assign sensible underlined
#     letters when your translations are incorporated into Scid.
#
# Additions, corrections? Email: shane@cosc.canterbury.ac.nz


addLanguage E English 0

proc setLanguage_E {} {

# File menu:
menuText E File "File" 0
menuText E FileNew "New..." 0 {Create a new Scid database}
menuText E FileOpen "Open..." 0 {Open an existing Scid database}
menuText E FileClose "Close" 0 {Close the active Scid database}
menuText E FileFinder "Finder" 0 {Open the File Finder window}
menuText E FileBookmarks "Bookmarks" 0 {Bookmarks menu (shortcut: Ctrl+B)}
menuText E FileBookmarksAdd "Add bookmark" 0 \
  {Bookmark the current database game and position}
menuText E FileBookmarksFile "File bookmark" 0 \
  {File a bookmark for the current game and position}
menuText E FileBookmarksEdit "Edit bookmarks..." 0 \
  {Edit the bookmarks menus}
menuText E FileBookmarksList "Display folders as single list" 0 \
  {Display bookmark folders as a single list, not submenus}
menuText E FileBookmarksSub "Display folders as submenus" 0 \
  {Display bookmark folders as submenus, not a single list}
menuText E FileMaint "Maintenance" 0 {Scid database maintenance tools}
menuText E FileMaintWin "Maintenance Window" 0 \
  {Open/close the Scid database maintenance window}
menuText E FileMaintCompact "Compact database..." 0 \
  {Compact database files, removing deleted games and unused names}
menuText E FileMaintClass "ECO-Classify games..." 2 \
  {Recompute the ECO code of all games}
menuText E FileMaintSort "Sort database..." 0 \
  {Sort all games in the database}
menuText E FileMaintDelete "Delete twin games..." 0 \
  {Find twin games and set them to be deleted}
menuText E FileMaintTwin "Twin checker window" 0 \
  {Open/update the Twin checker window}
menuText E FileMaintName "Name spelling" 0 {Name editing and spelling tools}
menuText E FileMaintNameEditor "Name editor" 0 \
  {Open/close the name editor window}
menuText E FileMaintNamePlayer "Spellcheck Player names..." 11 \
  {Spellcheck player names using the spellcheck file}
menuText E FileMaintNameEvent "Spellcheck Event names..." 11 \
  {Spellcheck event names using the spellcheck file}
menuText E FileMaintNameSite "Spellcheck Site names..." 11 \
  {Spellcheck site names using the spellcheck file}
menuText E FileMaintNameRound "Spellcheck Round names..." 11 \
  {Spellcheck round names using the spellcheck file}
menuText E FileReadOnly "Read-only..." 0 \
  {Treat the current database as read-only, preventing changes}
menuText E FileExit "Exit" 1 {Exit Scid}

# Edit menu:
menuText E Edit "Edit" 0
menuText E EditAdd "Add Variation" 0 {Add a variation at this move in the game}
menuText E EditDelete "Delete Variation" 0 {Delete a variation for this move}
menuText E EditFirst "Make First Variation" 5 \
  {Promote a variation to be first in the list}
menuText E EditMain "Promote Variation to Main line" 21 \
  {Promote a variation to be the main line}
menuText E EditTrial "Try variation" 0 \
  {Start/stop trial mode, for testing an idea on the board}
menuText E EditStrip "Strip" 2 {Strip comments or variations from this game}
menuText E EditStripComments "Comments" 0 \
  {Strip all comments and annotations from this game}
menuText E EditStripVars "Variations" 0 {Strip all variations from this game}
menuText E EditReset "Empty Clipbase" 0 \
  {Reset the clipbase to be completely empty}
menuText E EditCopy "Copy this game to Clipbase" 0 \
  {Copy this game to the Clipbase database}
menuText E EditPaste "Paste last Clipbase game" 0 \
  {Paste the active Clipbase game here}
menuText E EditSetup "Setup start board..." 0 \
  {Set the start position for this game}
menuText E EditPasteBoard "Paste start board" 12 \
  {Set the start board from the current text selection (clipboard)}

# Game menu:
menuText E Game "Game" 0
menuText E GameNew "New game" 0 \
  {Reset to an empty game, discarding any changes}
menuText E GameFirst "Load First Game" 5 {Load the first filtered game}
menuText E GamePrev "Load Previous Game" 5 {Load the previous filtered game}
menuText E GameReload "Re-Load Current Game" 3 \
  {Reload this game, discarding any changes made}
menuText E GameNext "Load Next Game" 7 {Load the next filtered game}
menuText E GameLast "Load Last Game" 8 {Load the last filtered game}
menuText E GameRandom "Load Random Game" 8 {Load a random filtered game}
menuText E GameNumber "Load Game Number..." 5 \
  {Load a game by entering its number}
menuText E GameReplace "Save: Replace game..." 6 \
  {Save this game, replacing the old version}
menuText E GameAdd "Save: Add new game..." 6 \
  {Save this game as a new game in the database}
menuText E GameDeepest "Identify opening" 0 \
  {Goto the deepest game position listed in the ECO book}
menuText E GameGotoMove "Goto move number..." 5 \
  {Go to a specified move number in the current game}
menuText E GameNovelty "Find Novelty..." 7 \
  {Find the first move of this game that has not played before}

# Search Menu:
menuText E Search "Search" 0
menuText E SearchReset "Reset Filter" 0 {Reset the filter so all games are included}
menuText E SearchNegate "Negate Filter" 0 {Negate the filter to only include excluded games}
menuText E SearchCurrent "Current Board..." 0 {Search for the current board position}
menuText E SearchHeader "Header..." 0 {Search by Header (player, event, etc) information}
menuText E SearchMaterial "Material/Pattern..." 0 {Search for material or board patterns}
menuText E SearchUsing "Using search file..." 0 {Search using a SearchOptions file}

# Windows menu:
menuText E Windows "Windows" 0
menuText E WindowsComment "Comment editor" 0 {Open/close the comment editor}
menuText E WindowsGList "Game List" 0 {Open/close the game list window}
menuText E WindowsPGN "PGN window" 0 \
  {Open/close the PGN (game notation) window}
menuText E WindowsTmt "Tournament Finder" 2 {Open/close the tournament finder}
menuText E WindowsSwitcher "Database switcher" 0 \
  {Open/close the Database Switcher window}
menuText E WindowsMaint "Maintenance window" 0 \
  {Open/close the Maintenance window}
menuText E WindowsECO "ECO Browser" 0 {Open/close the ECO Browser window}
menuText E WindowsRepertoire "Repertoire editor" 0 \
  {Open/close the opening repertoire editor}
menuText E WindowsStats "Statistics window" 0 \
  {Open/close the filter statistics window}
menuText E WindowsTree "Tree window" 0 {Open/close the Tree window}
menuText E WindowsTB "Endgame Tablebase window" 1 \
  {Open/close the Tablebase window}

# Tools menu:
menuText E Tools "Tools" 0
menuText E ToolsAnalysis "Analysis engine..." 0 \
  {Start/stop a chess analysis engine}
menuText E ToolsAnalysis2 "Analysis engine #2..." 17 \
  {Start/stop the 2nd chess analysis engine}
menuText E ToolsCross "Crosstable" 0 {Show tournament crosstable for this game}
menuText E ToolsEmail "Email manager" 0 \
  {Open/close the email chess manager window}
menuText E ToolsFilterGraph "Filter graph" 7 \
  {Open/close the filter graph window}
menuText E ToolsOpReport "Opening report" 0 \
  {Generate an opening report for the current position}
menuText E ToolsTracker "Piece Tracker"  6 {Open the Piece Tracker window}
menuText E ToolsPInfo "Player Information"  0 \
  {Open/update the Player Information window}
menuText E ToolsRating "Rating graph" 0 \
  {Graph the rating history of the current game players}
menuText E ToolsScore "Score graph" 0 {Show the score graph window}
menuText E ToolsExpCurrent "Export current game" 8 \
  {Write current game to a text file}
menuText E ToolsExpCurrentPGN "Export game to PGN file..." 15 \
  {Write current game to a PGN file}
menuText E ToolsExpCurrentHTML "Export game to HTML file..." 15 \
  {Write current game to a HTML file}
menuText E ToolsExpCurrentLaTeX "Export game to LaTeX file..." 15 \
  {Write current game to a LaTeX file}
menuText E ToolsExpFilter "Export all filter games" 1 \
  {Write all filtered games to a text file}
menuText E ToolsExpFilterPGN "Export filter to PGN file..." 17 \
  {Write all filtered games to a PGN file}
menuText E ToolsExpFilterHTML "Export filter to HTML file..." 17 \
  {Write all filtered games to a HTML file}
menuText E ToolsExpFilterLaTeX "Export filter to LaTeX file..." 17 \
  {Write all filtered games to a LaTeX file}
menuText E ToolsImportOne "Import one PGN game..." 0 \
  {Import a game from PGN text}
menuText E ToolsImportFile "Import file of PGN games..." 7 \
  {Import games from a PGN file}

# Options menu:
menuText E Options "Options" 0
menuText E OptionsSize "Board Size" 0 {Change the board size}
menuText E OptionsPieces "Board Piece Style" 6 {Change the board piece style}
menuText E OptionsColors "Colors..." 0 {Change board colors}
menuText E OptionsExport "Exporting" 0 {Change text export options}
menuText E OptionsFonts "Fonts" 0 {Change fonts}
menuText E OptionsFontsRegular "Regular" 0 {Change the regular font}
menuText E OptionsFontsSmall "Small" 0 {Change the small font}
menuText E OptionsFontsFixed "Fixed" 0 {Change the fixed-width font}
menuText E OptionsGInfo "Game information" 0 {Game information options}
menuText E OptionsLanguage "Language" 0 {Select menu language}
menuText E OptionsMoves "Moves" 0 {Move entry options}
menuText E OptionsMovesAsk "Ask before replacing moves" 0 \
  {Ask before overwriting any existing moves}
menuText E OptionsMovesDelay "Autoplay time delay..." 1 \
  {Set the time delay for autoplay mode}
menuText E OptionsMovesCoord "Coordinate move entry" 0 \
  {Accept coordinate-style move entry ("g1f3")}
menuText E OptionsMovesSuggest "Show suggested moves" 0 \
  {Turn on/off move suggestion}
menuText E OptionsMovesKey "Keyboard completion" 0 \
  {Turn on/off keyboard move auto-completion}
menuText E OptionsNumbers "Number format" 0 {Select the number format}
menuText E OptionsStartup "Startup" 3 {Select windows to open at startup}
menuText E OptionsWindows "Windows" 0 {Window options}
menuText E OptionsWindowsIconify "Auto-iconify" 5 \
  {Iconify all windows when the main window is iconified}
menuText E OptionsWindowsRaise "Auto-raise" 5 \
  {Raise certain windows (e.g. progress bars) whenever they are obscured}
menuText E OptionsToolbar "Toolbar" 0 {Configure the main window toolbar}
menuText E OptionsECO "Load ECO file..." 7 {Load the ECO classification file}
menuText E OptionsSpell "Load Spellcheck file..." 11 \
  {Load the Scid spellcheck file}
menuText E OptionsTable "Tablebase directory..." 10 \
  {Select a tablebase file; all tablebases in its directory will be used}
menuText E OptionsSave "Save Options" 0 \
  "Save all settable options to the file $::optionsFile"
menuText E OptionsAutoSave "Auto-save Options on Exit" 0 \
  {Auto-save all options when exiting Scid}

# Help menu:
menuText E Help "Help" 0
menuText E HelpIndex "Index" 0 {Show the help index page}
menuText E HelpGuide "Quick Guide" 0 {Show the quick guide help page}
menuText E HelpHints "Hints" 0 {Show the hints help page}
menuText E HelpContact "Contact info" 0 {Show the contact information help page}
menuText E HelpTip "Tip of the day" 0 {Show a useful Scid tip}
menuText E HelpStartup "Startup window" 0 {Show the startup window}
menuText E HelpAbout "About Scid" 0 {Information about Scid}

# Game info box popup menu:
menuText E GInfoHideNext "Hide next move" 0
menuText E GInfoMaterial "Show material values" 0
menuText E GInfoFEN "Show FEN" 5
menuText E GInfoMarks "Show colored squares and arrows" 5
menuText E GInfoWrap "Wrap long lines" 0
menuText E GInfoFullComment "Show Full Comment" 10
menuText E GInfoTBNothing "Tablebases: nothing" 12
menuText E GInfoTBResult "Tablebases: result only" 12
menuText E GInfoTBAll "Tablebases: result and best moves" 19
menuText E GInfoDelete "(Un)Delete this game" 4
menuText E GInfoMark "(Un)Mark this game" 4

# Main window buttons:
helpMsg E .button.start {Go to start of game  (key: Home)}
helpMsg E .button.end {Go to end of game  (key: End)}
helpMsg E .button.back {Go back one move  (key: LeftArrow)}
helpMsg E .button.forward {Go forward one move  (key: RightArrow)}
helpMsg E .button.intoVar {Move into a variation  (shortcut key: v)}
helpMsg E .button.exitVar {Leave the current variation  (shortcut key: z)}
helpMsg E .button.flip {Rotate board  (shortcut key: .)}
helpMsg E .button.coords {Turn board coordinates on or off  (shortcut key: 0)}
helpMsg E .button.autoplay {Autoplay moves  (key: Ctrl+Z)}

# General buttons:
translate E Back {Back}
translate E Cancel {Cancel}
translate E Clear {Clear}
translate E Close {Close}
translate E Defaults {Defaults}
translate E Delete {Delete}
translate E Graph {Graph}
translate E Help {Help}
translate E Import {Import}
translate E Index {Index}
translate E LoadGame {Load game}
translate E BrowseGame {Browse game}
translate E MergeGame {Merge game}
translate E Preview {Preview}
translate E Revert {Revert}
translate E Save {Save}
translate E Search {Search}
translate E Stop {Stop}
translate E Store {Store}
translate E Update {Update}
translate E ChangeOrient {Change window orientation}
translate E None {None}
translate E First {First}
translate E Current {Current}
translate E Last {Last}

# General messages:
translate E game {game}
translate E games {games}
translate E move {move}
translate E moves {moves}
translate E all {all}
translate E Yes {Yes}
translate E No {No}
translate E Both {Both}
translate E King {King}
translate E Queen {Queen}
translate E Rook {Rook}
translate E Bishop {Bishop}
translate E Knight {Knight}
translate E Pawn {Pawn}
translate E White {White}
translate E Black {Black}
translate E Player {Player}
translate E Rating {Rating}
translate E RatingDiff {Rating difference (White - Black)}
translate E Event {Event}
translate E Site {Site}
translate E Country {Country}
translate E IgnoreColors {Ignore colors}
translate E Date {Date}
translate E EventDate {Event date}
translate E Decade {Decade}
translate E Year {Year}
translate E Month {Month}
translate E Months {January February March April May June
  July August September October November December}
translate E Days {Sun Mon Tue Wed Thu Fri Sat}
translate E YearToToday {Year to today}
translate E Result {Result}
translate E Round {Round}
translate E Length {Length}
translate E ECOCode {ECO code}
translate E ECO {ECO}
translate E Deleted {Deleted}
translate E SearchResults {Search Results}
translate E OpeningTheDatabase {Opening database}
translate E Database {Database}
translate E Filter {Filter}
translate E noGames {no games}
translate E allGames {all games}
translate E empty {empty}
translate E clipbase {clipbase}
translate E score {score}
translate E StartPos {Start position}
translate E Total {Total}

# Game information:
translate E twin {twin}
translate E deleted {deleted}
translate E comment {comment}
translate E hidden {hidden}
translate E LastMove {Last move}
translate E NextMove {Next}
translate E GameStart {Start of game}
translate E LineStart {Start of line}
translate E GameEnd {End of game}
translate E LineEnd {End of line}

# Player information:
translate E PInfoAll {Results for <b>all</b> games}
translate E PInfoFilter {Results for <b>filter</b> games}
translate E PInfoAgainst {Results against}
translate E PInfoMostWhite {Most common openings as White}
translate E PInfoMostBlack {Most common openings as Black}
translate E PInfoRating {Rating history}
translate E PInfoBio {Biography}

# Tablebase information:
translate E Draw {Draw}
translate E stalemate {stalemate}
translate E withAllMoves {with all moves}
translate E withAllButOneMove {with all but one move}
translate E with {with}
translate E only {only}
translate E lose {lose}
translate E loses {loses}
translate E allOthersLose {all others lose}
translate E matesIn {mates in}
translate E hasCheckmated {has checkmated}
translate E longest {longest}

# Tip of the day:
translate E Tip {Tip}
translate E TipAtStartup {Tip at startup}

# Tree window menus:
menuText E TreeFile "File" 0
menuText E TreeFileSave "Save cache file" 0 {Save the tree cache (.stc) file}
menuText E TreeFileFill "Fill cache file" 0 \
  {Fill the cache file with common opening positions}
menuText E TreeFileBest "Best games list" 0 {Show the best tree games list}
menuText E TreeFileGraph "Graph window" 0 {Show the graph for this tree branch}
menuText E TreeFileCopy "Copy tree text to clipboard" 1 \
  {Copy the tree statisctics to the clipboard}
menuText E TreeFileClose "Close tree window" 0 {Close the tree window}
menuText E TreeSort "Sort" 0
menuText E TreeSortAlpha "Alphabetical" 0
menuText E TreeSortECO "ECO code" 0
menuText E TreeSortFreq "Frequency" 0
menuText E TreeSortScore "Score" 0
menuText E TreeOpt "Options" 0
menuText E TreeOptLock "Lock" 0 {Lock/unlock the tree to the current database}
menuText E TreeOptTraining "Training" 0 {Turn on/off tree training mode}
menuText E TreeOptAutosave "Auto-save cache file" 0 \
  {Auto-save the cache file when closing the tree window}
menuText E TreeHelp "Help" 0
menuText E TreeHelpTree "Tree help" 0
menuText E TreeHelpIndex "Help index" 0
translate E SaveCache {Save cache}
translate E Training {Training}
translate E LockTree {Lock}
translate E TreeLocked {locked}
translate E TreeBest {Best}
translate E TreeBestGames {Best tree games}

# Finder window:
menuText E FinderFile "File" 0
menuText E FinderFileSubdirs "Look in subdirectories" 0
menuText E FinderFileClose "Close File Finder" 0
menuText E FinderSort "Sort" 0
menuText E FinderSortType "Type" 0
menuText E FinderSortSize "Size" 0
menuText E FinderSortMod "Modified" 0
menuText E FinderSortName "Name" 0
menuText E FinderSortPath "Path" 0
menuText E FinderTypes "Types" 0
menuText E FinderTypesScid "Scid databases" 0
menuText E FinderTypesOld "Old-format Scid databases" 0
menuText E FinderTypesPGN "PGN files" 0
menuText E FinderTypesEPD "EPD files" 0
menuText E FinderTypesRep "Repertoire files" 0
menuText E FinderHelp "Help" 0
menuText E FinderHelpFinder "File Finder help" 0
menuText E FinderHelpIndex "Help index" 0
translate E FileFinder {File Finder}
translate E FinderDir {Directory}
translate E FinderDirs {Directories}
translate E FinderFiles {Files}
translate E FinderUpDir {up}

# Tournament finder:
menuText E TmtFile "File" 0
menuText E TmtFileUpdate "Update" 0
menuText E TmtFileClose "Close Tournament Finder" 0
menuText E TmtSort "Sort" 0
menuText E TmtSortDate "Date" 0
menuText E TmtSortPlayers "Players" 0
menuText E TmtSortGames "Games" 0
menuText E TmtSortElo "Elo" 0
menuText E TmtSortSite "Site" 0
menuText E TmtSortEvent "Event" 1
menuText E TmtSortWinner "Winner" 0
translate E TmtLimit "List limit"
translate E TmtMeanElo "Lowest mean Elo"
translate E TmtNone "No matching tournaments were found."

# Graph windows:
menuText E GraphFile "File" 0
menuText E GraphFileColor "Save as Color PostScript..." 8
menuText E GraphFileGrey "Save as Greyscale PostScript..." 8
menuText E GraphFileClose "Close window" 6
menuText E GraphOptions "Options" 0
menuText E GraphOptionsWhite "White" 0
menuText E GraphOptionsBlack "Black" 0
menuText E GraphOptionsBoth "Both" 1
menuText E GraphOptionsPInfo "Player Info player" 0
translate E GraphFilterTitle "Filter graph: frequency per 1000 games"

# Analysis window:
translate E AddVariation {Add variation}
translate E AddMove {Add move}
translate E Annotate {Annotate}
translate E AnalysisCommand {Analysis command}
translate E PreviousChoices {Previous choices}
translate E AnnotateTime {Set the time between moves in seconds}
translate E AnnotateWhich {Add variations}
translate E AnnotateAll {For moves by both sides}
translate E AnnotateWhite {For White moves only}
translate E AnnotateBlack {For Black moves only}
translate E AnnotateNotBest {When game move is not best move}

# Analysis Engine open dialog:
translate E EngineList {Analysis Engine List}
translate E EngineName {Name}
translate E EngineCmd {Command}
translate E EngineArgs {Parameters}
translate E EngineDir {Directory}
translate E EngineElo {Elo}
translate E EngineTime {Date}
translate E EngineNew {New}
translate E EngineEdit {Edit}
translate E EngineRequired {Fields in bold are required; others are optional}

# Stats window menus:
menuText E StatsFile "File" 0
menuText E StatsFilePrint "Print to file..." 0
menuText E StatsFileClose "Close window" 0
menuText E StatsOpt "Options" 0

# PGN window menus:
menuText E PgnFile "File" 0
menuText E PgnFilePrint "Print to file..." 0
menuText E PgnFileClose "Close PGN window" 0
menuText E PgnOpt "Display" 0
menuText E PgnOptColor "Color display" 0
menuText E PgnOptShort "Short (3-line) header" 0
menuText E PgnOptSymbols "Symbolic annotations" 1
menuText E PgnOptIndentC "Indent comments" 0
menuText E PgnOptIndentV "Indent variations" 7
menuText E PgnOptColumn "Column style (one move per line)" 1
menuText E PgnOptSpace "Space after move numbers" 1
menuText E PgnOptStripMarks "Strip out colored square/arrow codes" 1
menuText E PgnColor "Colors" 0
menuText E PgnColorHeader "Header..." 0
menuText E PgnColorAnno "Annotations..." 0
menuText E PgnColorComments "Comments..." 0
menuText E PgnColorVars "Variations..." 0
menuText E PgnColorBackground "Background..." 0
menuText E PgnHelp "Help" 0
menuText E PgnHelpPgn "PGN help" 0
menuText E PgnHelpIndex "Index" 0

# Crosstable window menus:
menuText E CrosstabFile "File" 0
menuText E CrosstabFileText "Print to Text file..." 9
menuText E CrosstabFileHtml "Print to HTML file..." 9
menuText E CrosstabFileLaTeX "Print to LaTeX file..." 9
menuText E CrosstabFileClose "Close Crosstable window" 0
menuText E CrosstabEdit "Edit" 0
menuText E CrosstabEditEvent "Event" 0
menuText E CrosstabEditSite "Site" 0
menuText E CrosstabEditDate "Date" 0
menuText E CrosstabOpt "Display" 0
menuText E CrosstabOptAll "All-play-all" 0
menuText E CrosstabOptSwiss "Swiss" 0
menuText E CrosstabOptKnockout "Knockout" 0
menuText E CrosstabOptAuto "Auto" 1
menuText E CrosstabOptAges "Ages in years" 8
menuText E CrosstabOptNats "Nationalities" 0
menuText E CrosstabOptRatings "Ratings" 0
menuText E CrosstabOptTitles "Titles" 0
menuText E CrosstabOptBreaks "Tie-break scores" 4
menuText E CrosstabOptDeleted "Include deleted games" 8
menuText E CrosstabOptColors "Colors (Swiss table only)" 0
menuText E CrosstabOptColumnNumbers "Numbered columns (All-play-all table only)" 2
menuText E CrosstabOptGroup "Group scores" 0
menuText E CrosstabSort "Sort" 0
menuText E CrosstabSortName "Name" 0
menuText E CrosstabSortRating "Rating" 0
menuText E CrosstabSortScore "Score" 0
menuText E CrosstabColor "Color" 0
menuText E CrosstabColorPlain "Plain text" 0
menuText E CrosstabColorHyper "Hypertext" 0
menuText E CrosstabHelp "Help" 0
menuText E CrosstabHelpCross "Crosstable help" 0
menuText E CrosstabHelpIndex "Help index" 0
translate E SetFilter {Set Filter}
translate E AddToFilter {Add to Filter}
translate E Swiss {Swiss}

# Opening report window menus:
menuText E OprepFile "File" 0
menuText E OprepFileText "Print to Text file..." 9
menuText E OprepFileHtml "Print to HTML file..." 9
menuText E OprepFileLaTeX "Print to LaTeX file..." 9
menuText E OprepFileOptions "Options..." 0
menuText E OprepFileClose "Close report window" 0
menuText E OprepHelp "Help" 0
menuText E OprepHelpReport "Opening Report help" 0
menuText E OprepHelpIndex "Help index" 0

# Repertoire editor:
menuText E RepFile "File" 0
menuText E RepFileNew "New" 0
menuText E RepFileOpen "Open..." 0
menuText E RepFileSave "Save..." 0
menuText E RepFileSaveAs "Save As..." 5
menuText E RepFileClose "Close window" 0
menuText E RepEdit "Edit" 0
menuText E RepEditGroup "Add Group" 4
menuText E RepEditInclude "Add Include line" 4
menuText E RepEditExclude "Add Exclude line" 4
menuText E RepView "View" 0
menuText E RepViewExpand "Expand all groups" 0
menuText E RepViewCollapse "Collapse all groups" 0
menuText E RepSearch "Search" 0
menuText E RepSearchAll "All of repertoire..." 0
menuText E RepSearchDisplayed "Displayed lines only..." 0
menuText E RepHelp "Help" 0
menuText E RepHelpRep "Repertoire help" 0
menuText E RepHelpIndex "Help index" 0
translate E RepSearch "Repertoire search"
translate E RepIncludedLines "included lines"
translate E RepExcludedLines "excluded lines"
translate E RepCloseDialog {This repertoire has unsaved changes.

Do you really want to continue and discard the changes you have made?
}

# Header search:
translate E HeaderSearch {Header Search}
translate E GamesWithNoECO {Games with no ECO?}
translate E GameLength {Game length}
translate E FindGamesWith {Find games with flags}
translate E StdStart {Non-standard start}
translate E Promotions {Promotions}
translate E Comments {Comments}
translate E Variations {Variations}
translate E Annotations {Annotations}
translate E DeleteFlag {Delete flag}
translate E WhiteOpFlag {White opening}
translate E BlackOpFlag {Black opening}
translate E MiddlegameFlag {Middlegame}
translate E EndgameFlag {Endgame}
translate E NoveltyFlag {Novelty}
translate E PawnFlag {Pawn structure}
translate E TacticsFlag {Tactics}
translate E QsideFlag {Queenside play}
translate E KsideFlag {Kingside play}
translate E BrilliancyFlag {Brilliancy}
translate E BlunderFlag {Blunder}
translate E UserFlag {User}
translate E PgnContains {PGN contains text}

# Game list window:
translate E GlistNumber {Number}
translate E GlistWhite {White}
translate E GlistBlack {Black}
translate E GlistWElo {W-Elo}
translate E GlistBElo {B-Elo}
translate E GlistEvent {Event}
translate E GlistSite {Site}
translate E GlistRound {Round}
translate E GlistDate {Date}
translate E GlistYear {Year}
translate E GlistEDate {EventDate}
translate E GlistResult {Result}
translate E GlistLength {Length}
translate E GlistCountry {Country}
translate E GlistECO {ECO}
translate E GlistOpening {Opening}
translate E GlistEndMaterial {End-Material}
translate E GlistDeleted {Deleted}
translate E GlistFlags {Flags}
translate E GlistVars {Variations}
translate E GlistComments {Comments}
translate E GlistAnnos {Annotations}
translate E GlistStart {Start}
translate E GlistGameNumber {Game number}
translate E GlistFindText {Find text}
translate E GlistMoveField {Move}
translate E GlistEditField {Configure}
translate E GlistAddField {Add}
translate E GlistDeleteField {Remove}
translate E GlistWidth {Width}
translate E GlistAlign {Align}
translate E GlistColor {Color}
translate E GlistSep {Separator}

# Maintenance window:
translate E DatabaseName {Database Name:}
translate E TypeIcon {Type Icon:}
translate E NumOfGames {Games:}
translate E NumDeletedGames {Deleted games:}
translate E NumFilterGames {Games in filter:}
translate E YearRange {Year range:}
translate E RatingRange {Rating range:}
translate E Flag {Flag}
translate E DeleteCurrent {Delete current game}
translate E DeleteFilter {Delete filter games}
translate E DeleteAll {Delete all games}
translate E UndeleteCurrent {Undelete current game}
translate E UndeleteFilter {Undelete filter games}
translate E UndeleteAll {Undelete all games}
translate E DeleteTwins {Delete twin games}
translate E MarkCurrent {Mark current game}
translate E MarkFilter {Mark filter games}
translate E MarkAll {Mark all games}
translate E UnmarkCurrent {Unmark current game}
translate E UnmarkFilter {Unmark filter games}
translate E UnmarkAll {Unmark all games}
translate E Spellchecking {Spell-checking}
translate E Players {Players}
translate E Events {Events}
translate E Sites {Sites}
translate E Rounds {Rounds}
translate E DatabaseOps {Database operations}
translate E ReclassifyGames {ECO-classify games}
translate E CompactDatabase {Compact database}
translate E SortDatabase {Sort database}
translate E AddEloRatings {Add Elo ratings}
translate E AutoloadGame {Autoload game number}
translate E StripTags {Strip PGN tags}
translate E StripTag {Strip tag}
translate E Cleaner {Cleaner}
translate E CleanerHelp {
The Scid Cleaner will perform all the maintenance actions you select from the list below, on the current database.

Current settings in the ECO classification and twin deletion dialogs will apply if you select those functions.
}
translate E CleanerConfirm {
Once Cleaner maintenance is started, it cannot be interrupted!

This may take a long time on a large database, depending on the functions you have selected and their current settings.

Are you sure you want to commence the maintenance functions you selected?
}

# Comment editor:
translate E AnnotationSymbols  {Annotation Symbols:}
translate E Comment {Comment:}

# Board search:
translate E BoardSearch {Board Search}
translate E FilterOperation {Operation on current filter:}
translate E FilterAnd {AND (Restrict filter)}
translate E FilterOr {OR (Add to filter)}
translate E FilterIgnore {IGNORE (Reset filter)}
translate E SearchType {Search type:}
translate E SearchBoardExact {Exact position (all pieces on same squares)}
translate E SearchBoardPawns {Pawns (same material, all pawns on same squares)}
translate E SearchBoardFiles {Files (same material, all pawns on same files)}
translate E SearchBoardAny {Any (same material, pawns and pieces anywhere)}
translate E LookInVars {Look in variations}

# Material search:
translate E MaterialSearch {Material Search}
translate E Material {Material}
translate E Patterns {Patterns}
translate E Zero {Zero}
translate E Any {Any}
translate E CurrentBoard {Current board}
translate E CommonEndings {Common endings}
translate E CommonPatterns {Common patterns}
translate E MaterialDiff {Material difference}
translate E squares {squares}
translate E SameColor {Same color}
translate E OppColor {Opposite color}
translate E Either {Either}
translate E MoveNumberRange {Move number range}
translate E MatchForAtLeast {Match for at least}
translate E HalfMoves {half-moves}

# Game saving:
translate E Today {Today}
translate E ClassifyGame {Classify game}

# Setup position:
translate E EmptyBoard {Empty board}
translate E InitialBoard {Initial board}
translate E SideToMove {Side to move}
translate E MoveNumber {Move number}
translate E Castling {Castling}
translate E EnPassentFile {En Passent file}
translate E ClearFen {Clear FEN}
translate E PasteFen {Paste FEN}

# Replace move dialog:
translate E ReplaceMove {Replace move}
translate E AddNewVar {Add new variation}
translate E ReplaceMoveMessage {A move already exists here.

You can replace it, discarding all moves after it, or add your move as a new variation.

(You can avoid seeing this message in future by turning off the "Ask before replacing moves" option in the Options:Moves menu.)}

# Make database read-only dialog:
translate E ReadOnlyDialog {If you make this database read-only, no changes will be permitted.
No games can be saved or replaced, and no delete flags can be altered.
Any sorting or ECO-classification results will be temporary.

You can easily make the database writable again, by closing and reopening it.

Do you really want to make this database read-only?}

# Clear game dialog:
translate E ClearGameDialog {This game has been altered.

Do you really want to continue and discard the changes made to it?
}

# Exit dialog:
translate E ExitDialog {Do you really want to exit Scid?}
translate E ExitUnsaved {The following databases have unsaved game changes. If you exit now, these changes will be lost.}

# Import window:
translate E PasteCurrentGame {Paste current game}
translate E ImportHelp1 {Enter or paste a PGN-format game in the frame above.}
translate E ImportHelp2 {Any errors importing the game will be displayed here.}

# ECO Browser:
translate E ECOAllSections {all ECO sections}
translate E ECOSection {ECO section}
translate E ECOSummary {Summary for}
translate E ECOFrequency {Frequency of subcodes for}

# Opening Report:
translate E OprepTitle {Opening Report}
translate E OprepReport {Report}
translate E OprepGenerated {Generated by}
translate E OprepStatsHist {Statistics and History}
translate E OprepStats {Statistics}
translate E OprepStatAll {All report games}
translate E OprepStatBoth {Both rated}
translate E OprepStatSince {Since}
translate E OprepOldest {Oldest games}
translate E OprepNewest {Newest games}
translate E OprepPopular {Current popularity}
translate E OprepFreqAll {Frequency in all years:   }
translate E OprepFreq1   {In the  1 year  to today: }
translate E OprepFreq5   {In the  5 years to today: }
translate E OprepFreq10  {In the 10 years to today: }
translate E OprepEvery {once every %u games}
translate E OprepUp {up %u%s from all years}
translate E OprepDown {down %u%s from all years}
translate E OprepSame {no change from all years}
translate E OprepMostFrequent {Most frequent players}
translate E OprepRatingsPerf {Ratings and Performance}
translate E OprepAvgPerf {Average ratings and performance}
translate E OprepWRating {White rating}
translate E OprepBRating {Black rating}
translate E OprepWPerf {White performance}
translate E OprepBPerf {Black performance}
translate E OprepHighRating {Games with highest average rating}
translate E OprepTrends {Result Trends}
translate E OprepResults {Result lengths and frequencies}
translate E OprepLength {Game length}
translate E OprepFrequency {Frequency}
translate E OprepWWins {White wins: }
translate E OprepBWins {Black wins: }
translate E OprepDraws {Draws:      }
translate E OprepWholeDB {whole database}
translate E OprepShortest {Shortest wins}
translate E OprepMovesThemes {Moves and Themes}
translate E OprepMoveOrders {Move orders reaching the report position}
translate E OprepMoveOrdersOne \
  {There was only one move order reaching this position:}
translate E OprepMoveOrdersAll \
  {There were %u move orders reaching this position:}
translate E OprepMoveOrdersMany \
  {There were %u move orders reaching this position. The top %u are:}
translate E OprepMovesFrom {Moves from the report position}
translate E OprepThemes {Positional Themes}
translate E OprepThemeDescription {Frequency of themes at move %u}
translate E OprepThemeSameCastling {Same-side castling}
translate E OprepThemeOppCastling {Opposite castling}
translate E OprepThemeNoCastling {Both Kings uncastled}
translate E OprepThemeKPawnStorm {Kingside pawn storm}
translate E OprepThemeQueenswap {Queens exchanged}
translate E OprepThemeIQP {Isolated Queen Pawn}
translate E OprepThemeWP567 {White Pawn on 5/6/7th rank}
translate E OprepThemeBP234 {Black Pawn on 2/3/4th rank}
translate E OprepThemeOpenCDE {Open c/d/e file}
translate E OprepTheme1BishopPair {Only one side has Bishop pair}
translate E OprepEndgames {Endgames}
translate E OprepReportGames {Report games}
translate E OprepAllGames    {All games}
translate E OprepEndClass {Material at the end of each game}
translate E OprepTheoryTable {Theory Table}
translate E OprepTableComment {Generated from the %u highest-rated games.}
translate E OprepExtraMoves {Extra note moves in theory table}
translate E OprepMaxGames {Maximum games in theory table}

# Piece Tracker window:
translate E TrackerSelectSingle {Left mouse button selects this piece.}
translate E TrackerSelectPair {Left mouse button selects this piece; right button also selects its sibling.}
translate E TrackerSelectPawn {Left mouse button selects this pawn; right button selects all 8 pawns.}
translate E TrackerStat {Statistic}
translate E TrackerGames {% games with move to square}
translate E TrackerTime {% time on each square}
translate E TrackerMoves {Moves}
translate E TrackerMovesStart {Enter the move number where tracking should begin.}
translate E TrackerMovesStop {Enter the move number where tracking should stop.}

# Game selection dialogs:
translate E SelectAllGames {All games in the database}
translate E SelectFilterGames {Only games in the filter}
translate E SelectTournamentGames {Only games in the current tournament}
translate E SelectOlderGames {Only older games}

# Delete Twins window:
translate E TwinsNote {To be twins, two games must at least have the same two players, and criteria you can set below. When a pair of twins is found, the shorter game is deleted.
Hint: it is best to spellcheck the database before deleting twins, since it improves twin detection. }
translate E TwinsCriteria {Criteria: Twin games must have...}
translate E TwinsWhich {Examine which games}
translate E TwinsColors {Same player colors?}
translate E TwinsEvent {Same event?}
translate E TwinsSite {Same site?}
translate E TwinsRound {Same round?}
translate E TwinsYear {Same year?}
translate E TwinsMonth {Same month?}
translate E TwinsDay {Same day?}
translate E TwinsResult {Same result?}
translate E TwinsECO {Same ECO code?}
translate E TwinsMoves {Same moves?}
translate E TwinsPlayers {Comparing player names:}
translate E TwinsPlayersExact {Exact match}
translate E TwinsPlayersPrefix {First 4 letters only}
translate E TwinsWhen {When deleting twin games}
translate E TwinsSkipShort {Ignore all games under 5 moves long?}
translate E TwinsUndelete {Undelete all games first?}
translate E TwinsSetFilter {Set filter to all deleted twin games?}
translate E TwinsComments {Always keep games with comments?}
translate E TwinsVars {Always keep games with variations?}
translate E TwinsDeleteWhich {Delete which game:}
translate E TwinsDeleteShorter {Shorter game}
translate E TwinsDeleteOlder {Smaller game number}
translate E TwinsDeleteNewer {Larger game number}
translate E TwinsDelete {Delete games}

# Name editor window:
translate E NameEditType {Type of name to edit}
translate E NameEditSelect {Games to edit}
translate E NameEditReplace {Replace}
translate E NameEditWith {with}
translate E NameEditMatches {Matches: Press Ctrl+1 to Ctrl+9 to select}

# Classify window:
translate E Classify {Classify}
translate E ClassifyWhich {ECO-Classify which games}
translate E ClassifyAll {All games (overwrite old ECO codes)}
translate E ClassifyYear {All games played in the last year}
translate E ClassifyMonth {All games played in the last month}
translate E ClassifyNew {Only games with no ECO code yet}
translate E ClassifyCodes {ECO Codes to use}
translate E ClassifyBasic {Basic codes only ("B12", ...)}
translate E ClassifyExtended {Scid extensions ("B12j", ...)}

# Compaction:
translate E NameFile {Name file}
translate E GameFile {Game file}
translate E Names {Names}
translate E Unused {Unused}
translate E SizeKb {Size (kb)}
translate E CurrentState {Current State}
translate E AfterCompaction {After compaction}
translate E CompactNames {Compact name file}
translate E CompactGames {Compact game file}

# Sorting:
translate E SortCriteria {Criteria}
translate E AddCriteria {Add criteria}
translate E CommonSorts {Common sorts}
translate E Sort {Sort}

# Exporting:
translate E AddToExistingFile {Add games to an existing file?}
translate E ExportComments {Export comments?}
translate E ExportVariations {Export variations?}
translate E IndentComments {Indent comments?}
translate E IndentVariations {Indent variations?}
translate E ExportColumnStyle {Column style (one move per line)?}
translate E ExportSymbolStyle {Symbolic annotation style:}
translate E ExportStripMarks {Strip square/arrow mark codes from comments?}

# Goto game/move dialogs:
translate E LoadGameNumber {Enter the game number to load:}
translate E GotoMoveNumber {Goto move number:}

# Copy games dialog:
translate E CopyGames {Copy games}
translate E CopyConfirm {
 Do you really want to copy
 the [thousands $nGamesToCopy] filtered games
 in the database "$fromName"
 to the database "$targetName"?
}
translate E CopyErr {Cannot copy games}
translate E CopyErrSource {the source database}
translate E CopyErrTarget {the target database}
translate E CopyErrNoGames {has no games in its filter}
translate E CopyErrReadOnly {is read-only}
translate E CopyErrNotOpen {is not open}

# Colors:
translate E LightSquares {Light squares}
translate E DarkSquares {Dark squares}
translate E SelectedSquares {Selected squares}
translate E SuggestedSquares {Suggested move squares}
translate E WhitePieces {White pieces}
translate E BlackPieces {Black pieces}
translate E WhiteBorder {White border}
translate E BlackBorder {Black border}

# Novelty window:
translate E FindNovelty {Find Novelty}
translate E Novelty {Novelty}
translate E NoveltyInterrupt {Novelty search interrupted}
translate E NoveltyNone {No novelty was found for this game}
translate E NoveltyHelp {
Scid will find the first move of the current game that reaches a position not found in the selected database or in the ECO openings book.
}

# Upgrading databases:
translate E Upgrading {Upgrading}
translate E ConfirmOpenNew {
This is an old-format (Scid 2) database that cannot be opened in Scid 3, but a new-format (Scid 3) version has already been created.

Do you want to open the new-format version of the database?
}
translate E ConfirmUpgrade {
This is an old-format (Scid 2) database. A new-format version of the database must be created before it can be used in Scid 3.

Upgrading will create a new version of the database; it will not edit or remove the original files.

This may take a while, but it only needs to be done one time. You can cancel if it takes too long.

Do you want to upgrade this database now?
}

}
# end of english.tcl
