#  nederlan.tcl:
#  Dutch language support for Scid.
#  Added by J.Kees Hofkamp.
#  Changes by J. Krabbenbos.

addLanguage N Nederlands 0

proc setLanguage_N {} {

# File menu:
menuText N File "Bestand" 0
menuText N FileNew "Nieuw..." 0 {Maak een nieuwe Scid database}
menuText N FileOpen "Openen..." 0 {Open een bestaande Scid database}
menuText N FileClose "Sluiten" 0 {Sluit de  actieve Scid database}
menuText N FileFinder "Finder" 0 {Open het bestandszoekvenster}
menuText N FileBookmarks "Bookmarks" 0 {Bookmarks menu (shortcut: Ctrl+B)}
menuText N FileBookmarksAdd "Toevoegen bookmark" 0 \
  {Bookmark de huidige databasepartij en positie}
menuText N FileBookmarksFile "Bookmark-bestand" 0 \
  {File a bookmark for the current game and position}
menuText N FileBookmarksEdit "Wijzigen bookmarks..." 0 \
  {Wijzig de bookmarkmenu's}
menuText N FileBookmarksList "Weergeven folders als lijst" 0 \
  {Weergeven bookmark-folders als lijst, niet als submenu's}
menuText N FileBookmarksSub "Weergeven folders als submenu's" 0 \
  {Weergeven bookmark-folders als submenu's, niet als lijst}
menuText N FileMaint "Onderhoud" 2 {Onderhoud Scid database}
menuText N FileMaintWin "Onderhoudsvenster" 2 \
  {Open/sluit het Scid onderhoudsvenster}
menuText N FileMaintCompact "Reorganiseer database..." 0 \
  {Reorganiseer database bestanden}
menuText N FileMaintClass "Partijen ECO-classificeren..." 10 \
  {Herbereken de ECO code van alle partijen}
menuText N FileMaintSort "Sorteren..." 0 \
  {Sorteer alle partijen in de database}
menuText N FileMaintDelete "Doublures verwijderen..." 0 \
  {Vind dubbele partijen om ze te verwijderen}
menuText N FileMaintTwin "Doublure-venster" 1 \
  {Open/update het doublure-controle venster}
menuText N FileMaintName "Namen" 0 \
  {Corrigeer namen/spelling}
menuText N FileMaintNameEditor "Namen-editor" 6 \
  {Open/sluit het namen-correctie venster}
menuText N FileMaintNamePlayer "Corrigeer naam speler..." 15 \
  {Controleer spelling namen via het spellingcontrole bestand}
menuText N FileMaintNameEvent "Corrigeer naam evenement..." 15 \
  {Controleer spelling evenementen via spellingcontrole bestand}
menuText N FileMaintNameSite "Corrigeer naam plaats..." 15 \
  {Controleer plaatsnamen via spellingcontrole bestand}
menuText N FileMaintNameRound "Corrigeer ronde..." 10 \
  {Controleer rondenamen via spellingcontrole bestand}
menuText N FileReadOnly "Alleen lezen..." 7 \
  {Zet huidige database op alleen-lezen en voorkom veranderingen}
menuText N FileExit "Einde programma" 0 {Einde Scid}

# Edit menu:
menuText N Edit "Bewerken" 0
menuText N EditAdd "Nieuwe variant" 8 \
 {Voeg op dit punt een variant toe}
menuText N EditDelete "Variant verwijderen" 11 \
 {Verwijder een variant voor deze zet}
menuText N EditFirst "Maak hoofdvariant" 5 \
  {Maak deze variant de eerste in de lijst}
menuText N EditMain "Variatie op hoofdvariant" 13 \
   {Promoveerd de variant als hoofdvariant}
menuText N EditTrial "Probeer variatie" 0 \
  {Start/stop probeer modus, om een idee op het bord te testen}
menuText N EditStrip "Strip" 2 {Verwijder commentaar of varianten uit deze partij}
menuText N EditStripComments "Commentaar" 0 \
  {Verwijder alle commentaar en annotaties uit deze partij}
menuText N EditStripVars "Varianten" 0 {Verwijder alle varianten uit deze partij}
menuText N EditReset "Klembord leegmaken" 0 \
  {Maak het klembord helemaal leeg}
menuText N EditCopy "Partij naar klembord" 7 \
  {Kopieer deze partij naar het klembord}
menuText N EditPaste "Partij vanuit klembord" 7 \
  {Plak actieve klembord-partij hier}
menuText N EditSetup "Stelling opzetten..." 0 \
  {Kies een start-stelling voor de partij}
menuText N EditPasteBoard "Invoegen start stelling" 12 \
  {Maak de start stelling van de huidige tekst selectie (klembord)}

# Game menu:
menuText N Game "Partij" 0
menuText N GameNew "Partij leegmaken" 7 \
  {Maak partij leeg; sla veranderingen niet op}
menuText N GameFirst "Eerste partij laden" 5 {Laad de eerste gefilterde partij}
menuText N GamePrev "Vorige partij laden" 0 \
  {Laad vorige partij in het filter}
menuText N GameReload "Partij opnieuw laden" 7 \
  {Laad partij opnieuw; sla veranderingen niet op}
menuText N GameNext "Volgende partij laden" 3 \
  {Laad volgende partij in het filter}
menuText N GameLast "Laatste partij laden" 6 {Laad de laatste gefilterde partijd}
menuText N GameNumber "Laad partij nummer..." 12 \
  {Laad partijnummer:}
menuText N GameReplace "Partij overschrijven..." 11 \
  {Bewaar partij; overschrijf oude versie}
menuText N GameAdd "Partij toevoegen..." 7 \
  {Bewaar partij en voeg toe aan de database}
menuText N GameDeepest "Opening bepalen" 8 \
  {Ga naar de diepste positie uit het ECO openingboek}
menuText N GameGotoMove "Zetnummer..." 0 \
  {Ga naar zetnummer .. in de partij}
menuText N GameNovelty "Vind nieuwtje..." 7 \
  {Vind de eerste zet in deze partij die nog niet eerder is gespeeld}

# Search menu:
menuText N Search "Selecteren" 0
menuText N SearchReset "Alle partijen" 0 \
  {Reset filter en toon alle partijen}
menuText N SearchNegate "Selectie omdraaien" 9 \
  {Draai filter om en toon de andere partijen uit de databse}
menuText N SearchCurrent "Zoek huidige stelling" 5 \
  {Zoek in database naar huidige stelling}
menuText N SearchHeader "Partijgegevens..." 5 \
  {Zoek op speciale informatie: speler, evenement enz.}
menuText N SearchMaterial "Materiaal/Kenmerken..." 0 \
  {Zoek op patroon: bord, materiaal enz.}
menuText N SearchUsing "Zoekopties" 0 \
  {Zoek met gebruikmaking van opgeslagen opties}

# Windows menu:
menuText N Windows "Venster" 0
menuText N WindowsComment "Bewerk commentaar" 0 \
 {Open/sluit commentaar bewerkings venster}
menuText N WindowsGList "Toon alle partijen" 0 \
  {Open/sluit lijst met partijen}
menuText N WindowsPGN "PGN-venster" 0 \
 {Open/sluit het PGN-notatie venster}
menuText N WindowsTmt "Toernooi Zoeker" 9 {Open/sluit het toernooi zoekvenster}
menuText N WindowsSwitcher  "Database wisselen" 0 \
  {Open/sluit het database-wisselen venster}
menuText N WindowsMaint "Onderhoudsvenster" 5 \
  {Open/sluit het onderhoudsvenster}
menuText N WindowsECO "ECO Browser" 0 {Open/sluit het ECO browser venster}
menuText N WindowsRepertoire "Repertoire editor" 0 {Open/sluit de openingsrepertoir editor}
menuText N WindowsStats "Statistiek" 0 \
  {Open/sluit het filter statieken-venster}
menuText N WindowsTree "Openingoverzicht" 0 {Open/sluit het zoekboom venster}
menuText N WindowsTB "Tablebase venster" 1 \
  {Open/sluit het Tablebase venster}

# Tools menu:
menuText N Tools "Utilities" 0
menuText N ToolsAnalysis "Schaakprogramma..." 3 \
  {Start/stop een schaak-analyse programma}
menuText N ToolsAnalysis2 "Schaakprogramma #2..." 17 \
  {Start/stop een schaak-analyse programma}
menuText N ToolsCross "Kruistabel" 0 \
  {Toon toernooi-kruistabel voor deze partij}
menuText N ToolsEmail "Email-Manager" 0 {Open/sluit het email venster}
menuText N ToolsFilterGraph "Filter graph" 7 \
  {Open/close the filter graph window} ;# ***
menuText N ToolsOpReport "Openings rapportage" 0 \
  {Genereer een openingsrapport voor de huidige positie}
menuText N ToolsTracker "Piece Tracker"  0 {Open the Piece Tracker window} ;# ***
menuText N ToolsPInfo "Player Information"  7 \
  {Open/wijzig het spelerinformatievenster} ;# ***
menuText N ToolsRating "Rating geschiedenis" 0 \
  {Grafiek van de ratings van de twee spelers}
menuText N ToolsScore "Partij score" 7 \
  {Laat het partij-score venster zien}
menuText N ToolsExpCurrent "Partij exporteren" 8 \
  {Schrijf huidige partij naar tekstbestand}
menuText N ToolsExpCurrentPGN "Partij in PGN-formaat exporteren..." 11 \
  {Schrijf huidige partij naar PGN-bestand}
menuText N ToolsExpCurrentHTML "Partij in HTML-formaat exporteren..." 11 \
  {Schrijf huidige partij naar HTML-bestand}
menuText N ToolsExpCurrentLaTeX "Partij in LaTeX-formaat exporteren..." 11 \
  {Schrijf huidige partij naar LaTex-bestand}
menuText N ToolsExpFilter "Alle partijen in filter exporteren" 17 \
  {Schrijf alle geslecteerde partijen naar tekstbestand}
menuText N ToolsExpFilterPGN "Filter in PGN-formaat exporteren..." 10 \
  {Schrijf selectie naar PGN-bestand}
menuText N ToolsExpFilterHTML "Filter in HTML-formaat exporteren..." 10 \
  {Schrijf selectie naar HTML-bestand}
menuText N ToolsExpFilterLaTeX "Filter in LaTeX-formaat exporteren..." 10 \
  {Schrijf selectie naar LaTex-bestand}
menuText N ToolsImportOne "Een PGN partij importeren..." 4 \
  {Importeer PGN partij}
menuText N ToolsImportFile "PGN database importeren..." 4 \
  {Importeer PGN bestand}

# Options menu:
menuText N Options "Opties" 0
menuText N OptionsSize "Grootte van bord" 0 {Wijzig bord grootte}
menuText N OptionsPieces "Board Piece Style" 6 \
  {Change the board piece style} ;# ***
menuText N OptionsColors "Kleuren..." 0 {Wijzig bord kleuren}
menuText N OptionsExport "Export" 1 {Wijzig tekst export opties}
menuText N OptionsFonts "Lettertypen" 0 {Wijzig lettertype}
menuText N OptionsFontsRegular "Standaard" 0 {Wijzig het standaard lettertype}
menuText N OptionsFontsSmall "Klein" 0 {Wijzig het kleine lettertype}
menuText N OptionsFontsFixed "Vaste grootte" 0 {Wijzig dit lettertype}
menuText N OptionsGInfo "Partij Informatie" 7 {Parij-informatie opties}
menuText N OptionsLanguage "Kies taal" 5 {Kies taal}
menuText N OptionsMoves "Zetten" 0 {Wijzig optie voor zet-invoer}
menuText N OptionsMovesAsk "Bevestiging voor overschrijven" 0 \
  {Bevestig het overschrijven van bestaande zetten}
menuText N OptionsMovesDelay "Tijdinstelling voor auto-play" 10 \
  {Stel de tijd in voor het afspelen van de zetten}
menuText N OptionsMovesCoord "Zet-ingave" 0 \
  {Accepteer de volgende manier van zetten invoeren ("g1f3")}
menuText N OptionsMovesSuggest "Toon hint" 0 \
  {Schakel hints aan of uit}
menuText N OptionsMovesKey "Auto-aanvullen" 0 \
  {Aan/uitschakelen van toetsenbordzet auto-aanvullen}
menuText N OptionsNumbers "Getalformaat" 5 \
  {Kies de manier waarop getallen te zien zijn}
menuText N OptionsStartup "Startup" 3 {Selecteer de vensters die tijdens starten geopend worden} ;# ***
menuText N OptionsWindows "Venster" 0 {Venster opties}
menuText N OptionsWindowsIconify "Auto-iconify" 5 \
  {Iconify all windows when the main window is iconified} ;# ***
menuText N OptionsWindowsRaise "Auto-raise" 0 \
  {Raise certain windows (e.g. progress bars) whenever they are obscured}
menuText N OptionsToolbar "Hoofdvenster Gereedschappen" 0 \
  {Weergeven/verbergen hoofdvenster gereedschappen}
menuText N OptionsECO "ECO data laden..." 0 \
  {Laad het ECO classificatie bestand}
menuText N OptionsSpell "Laad spelling (namen)..." 5 \
  {Laad het Scid spellingbestand}
menuText N OptionsTable "Eindspel database laden..." 9 \
  {Kies een eindspel database, alle in de directory aanwezige worden gebruikt}
menuText N OptionsSave "Opties bewaren" 0 \
  "Bewaar alle instellingen in het bestand $::optionsFile"
menuText N OptionsAutoSave "Automatisch bewaren opties tijdens afsluiten" 0 \
  {Automatisch bewaren alle gewijzigde opties bij het afsluiten van Scid}

# Help menu:
menuText N Help "Help" 0
menuText N HelpIndex "Index" 0 {Show het help index page}
menuText N HelpGuide "Snelle hulp" 0 {Laat de snelle-hulp pagina zien}
menuText N HelpHints "Hints" 0 {Laat de hints-hulp pagina zien}
menuText N HelpContact "Contact-info" 0 {Laat de contact-infopagina zien}
menuText N HelpTip "Tip van de dag" 0 {Laat een handige Scid tip zien}
menuText N HelpStartup "Startvenster" 5 {Laat het startvenster zien}
menuText N HelpAbout "Over Scid" 0 {Informatie over Scid}

# Game info box popup menu:
menuText N GInfoHideNext "Verberg volgende zet" 0
menuText N GInfoMaterial "Materiaalverhouding" 0
menuText N GInfoFEN "FEN" 0
menuText N GInfoMarks "Show colored squares and arrows" 5 ;# ***
menuText N GInfoWrap "Lange regels wikkelen" 0
menuText N GInfoFullComment "Volledig commentaar weergeven" 10
menuText N GInfoTBNothing "Tablebases: niets" 12
menuText N GInfoTBResult "Tablebases: alleen resultaat" 12
menuText N GInfoTBAll "Tablebases: resultaat en beste zetten" 19
menuText N GInfoDelete "Partij wissen/terughalen" 9
menuText N GInfoMark "Partij markeren/niet markeren" 7

# Main windows buttons:
helpMsg N .button.start {Naar begin van partij  (toets: home)}
helpMsg N .button.end {Naar eind van partij  (toets: end)}
helpMsg N .button.back {Een zet terug   (toets: pijl links)}
helpMsg N .button.forward {Een zet vooruit  (toets: pijl rechts)}
helpMsg N .button.intoVar {Naar variant  (toets: v)}
helpMsg N .button.exitVar {Verlaat variant  (toets: z)}
helpMsg N .button.flip {Draai bord  (toets: .)}
helpMsg N .button.coords {Coordinaten aan/uit  (toets: 0)}
helpMsg N .button.autoplay {Speel zetten automatisch  (toets: Ctrl+Z)}

# General buttons:
translate N Back {Terug}
translate N Cancel {Annuleren}
translate N Clear {Leegmaken}
translate N Close {Sluiten}
translate N Defaults {Standaard}
translate N Delete {Wis}
translate N Graph {Grafiek}
translate N Help {Help}
translate N Import {Importeren}
translate N Index {Index}
translate N LoadGame {Partij laden}
translate N BrowseGame {Browse game} ;# ***
translate N MergeGame {Merge game} ;# ***
translate N Preview {Preview} ;# ***
translate N Revert {Omdraaien}
translate N Save {Opslaan}
translate N Search {Zoeken}
translate N Stop {Stop}
translate N Store {Opslaan}
translate N Update {Bijwerken}
translate N ChangeOrient {Wijzigen venster orientatie}
translate N None {Geen}
translate N First {Eerste}
translate N Current {Huidige}
translate N Last {Laatste}

# General messages:
translate N game {Partij}
translate N games {Partijen}
translate N move {Zet}
translate N moves {Zetten}
translate N all {Alle}
translate N Yes {Ja}
translate N No {Nee}
translate N Both {Beide}
translate N King {Koning}
translate N Queen {Dame}
translate N Rook {Toren}
translate N Bishop {Loper}
translate N Knight {Paard}
translate N Pawn {Pion}
translate N White {Wit}
translate N Black {Zwart}
translate N Player {Speler}
translate N Rating {Rating}
translate N RatingDiff {Ratingverschil (Wit - Zwart)}
translate N Event {Evenement}
translate N Site {Plaats}
translate N Country {Country}
translate N IgnoreColors {Kleuren negeren}
translate N Date {Datum}
translate N EventDate {Datum evenement}
translate N Decade {Decade} ;# ***
translate N Year {Jaar}
translate N Month {Maand}
translate N Months {Januari Februari Maart April Mei Juni
  Juli Augustus September October November December}
translate N Days {Zon Maa Din Woe Don Vri Zat}
translate N YearToToday {Een jaar geleden}
translate N Result {Uitslag}
translate N Round {Ronde}
translate N Length {Lengte}
translate N ECOCode {ECO Code}
translate N ECO {ECO}
translate N Deleted {Verwijderd}
translate N SearchResults {Zoekresultaten}
translate N OpeningTheDatabase {Opening the database} ;# ***
translate N Database {Database}
translate N Filter {Filter}
translate N noGames {Geen partijen}
translate N allGames {Alle partijen}
translate N empty {leeg}
translate N clipbase {Klembord}
translate N score {Score}
translate N StartPos {Start positie}
translate N Total {Totaal}

# Game information:
translate N twin {Dubbele partijen}
translate N deleted {Gewist}
translate N comment {Commentaar}
translate N hidden {Verborgen}
translate N LastMove {Laatste zet}
translate N NextMove {Volgende zet}
translate N GameStart {Start partij}
translate N LineStart {Start variant}
translate N GameEnd {Einde partij}
translate N LineEnd {Einde variant}

# Player information:
translate N PInfoAll {Resultaten voor <b>alle</b> partijen}
translate N PInfoFilter {Resultaten voor <b>filter</b> partijen}
translate N PInfoAgainst {Resultaten tegen}
translate N PInfoMostWhite {Meest gespeelde opening als Wit}
translate N PInfoMostBlack {Meest gespeelde opening als Zwart}
translate N PInfoRating {Rating historie}
translate N PInfoBio {Biografie}

# Tablebase information:
translate N Draw {Remise}
translate N stalemate {Pat}
translate N withAllMoves {met alle zetten}
translate N withAllButOneMove {alle zetten behalve een zet}
translate N with {met}
translate N only {alleen}
translate N lose {verlies}
translate N loses {verliest}
translate N allOthersLose {alle overigen verliezen}
translate N matesIn {Mat in}
translate N hasCheckmated {heeft mat}
translate N longest {langste}

# Tip of the day:
translate N Tip {Tip}
translate N TipAtStartup {Tip bij opstarten}

# Tree window menus:
menuText N TreeFile "Data" 0
menuText N TreeFileSave "Data in cache opslaan" 0 {Bewaar de data in een boomcache (.stc) bestand}
menuText N TreeFileFill "Vullen cache bestand" 0 \
  {Vul het cache bestand met algemene openingsposities}
menuText N TreeFileBest "Lijst beste partijen" 0 {Weergeven van de lijst met beste partijen}
menuText N TreeFileGraph "Grafiek-venster" 0 \
  {Weergeven van de grafiek voor deze tak}
menuText N TreeFileCopy "Kopieer boom tekst naar klembord" 0 \
  {Kopieren van de boomstatistieken naar het klembord}
menuText N TreeFileClose "Zoekboom venster sluiten" 0 {Sluiten van het zoekboom venster}
menuText N TreeSort "Sorteren" 0
menuText N TreeSortAlpha "Alfabetisch" 0
menuText N TreeSortECO "ECO code" 0
menuText N TreeSortFreq "Frequentie" 0
menuText N TreeSortScore "Punten" 0
menuText N TreeOpt "Opties" 0
menuText N TreeOptLock "Vergrendelen" 0 {Vergrendelen/Ontgrendelen van de boom bij de huidige database}
menuText N TreeOptTraining "Training" 0 {Aan/Uit zetten training modus}
menuText N TreeOptAutosave "Autom.cache-data opslaan" 4 \
  {Automatisch bewaren van het cache bestand bij sluiten boomvenster}
menuText N TreeHelp "Help" 0
menuText N TreeHelpTree "Hulp bij zoekboom" 0
menuText N TreeHelpIndex "Index" 0
translate N SaveCache {Cache opslaan}
translate N Training {Training}
translate N LockTree {Vergrendelen}
translate N TreeLocked {Vergrendeld}
translate N TreeBest {Beste}
translate N TreeBestGames {Beste boom partijen}

# Finder window:
menuText N FinderFile "Data" 0
menuText N FinderFileSubdirs "Kijken in subdirectories" 0
menuText N FinderFileClose "Sluiten bestandszoeker" 0
menuText N FinderSort "Sorteren" 0
menuText N FinderSortType "Type" 0
menuText N FinderSortSize "Grootte" 0
menuText N FinderSortMod "Gewijzigd" 0
menuText N FinderSortName "Naam" 0
menuText N FinderSortPath "Pad" 0
menuText N FinderTypes "Types" 0
menuText N FinderTypesScid "Scid databases" 0
menuText N FinderTypesOld "Oud formaat Scid databases" 0
menuText N FinderTypesPGN "PGN bestanden" 0
menuText N FinderTypesEPD "EPD (boek) bestanden" 0
menuText N FinderTypesRep "Repertoir bestanden" 0
menuText N FinderHelp "Help" 0
menuText N FinderHelpFinder "Bestandszoeker help" 0
menuText N FinderHelpIndex "Index" 0
translate N FileFinder {Bestandszoeker}
translate N FinderDir {Folder}
translate N FinderDirs {Folders}
translate N FinderFiles {Bestanden}
translate N FinderUpDir {Omhoog}

# Tournament finder:
menuText N TmtFile "Data" 0
menuText N TmtFileUpdate "Bijwerken" 0
menuText N TmtFileClose "Sluiten Toernooi zoeker" 0
menuText N TmtSort "Sorteren" 0
menuText N TmtSortDate "Datum" 0
menuText N TmtSortPlayers "Spelers" 0
menuText N TmtSortGames "Partijen" 0
menuText N TmtSortElo "Elo" 0
menuText N TmtSortSite "Plaats" 0
menuText N TmtSortEvent "Evenement" 1
menuText N TmtSortWinner "Winnaar" 0
translate N TmtLimit "Limiet Lijst"
translate N TmtMeanElo "Laagste gem. Elo"
translate N TmtNone "Geen toernooien gevonden."

# Graph windows:
menuText N GraphFile "Data" 0
menuText N GraphFileColor "Bewaren als kleuren Postscript..." 8
menuText N GraphFileGrey "Bewaren als grijze Postscript..." 8
menuText N GraphFileClose "Venster sluiten" 0
menuText N GraphOptions "Opties" 0
menuText N GraphOptionsWhite "Wit" 0
menuText N GraphOptionsBlack "Zwart" 0
menuText N GraphOptionsBoth "Beide" 1
menuText N GraphOptionsPInfo "Speler informatie speler" 0
translate N GraphFilterTitle "Filter graph: frequency per 1000 games" ;# ***

# Analysis window:
translate N AddVariation {Toevoegen variant}
translate N AddMove {Toevoegen zet}
translate N Annotate {Annotatie}
translate N AnalysisCommand {Analyse commando}
translate N PreviousChoices {Voorgaande keuzes}
translate N AnnotateTime {Set the time between moves in seconds} ;# ***
translate N AnnotateWhich {Add variations} ;# ***
translate N AnnotateAll {For moves by both sides} ;# ***
translate N AnnotateWhite {For White moves only} ;# ***
translate N AnnotateBlack {For Black moves only} ;# ***
translate N AnnotateNotBest {When game move is not best move} ;# ***

# Analysis Engine open dialog:
translate N EngineList {Analysis Engine List} ;# ***
translate N EngineName {Name} ;# ***
translate N EngineCmd {Command} ;# ***
translate N EngineArgs {Parameters} ;# ***
translate N EngineDir {Directory} ;# ***
translate N EngineElo {Elo}
translate N EngineTime {Datum}
translate N EngineNew {New} ;# ***
translate N EngineEdit {Edit} ;# ***
translate N EngineRequired {Fields in bold are required; others are optional} ;# ***

# Stats window menus:
menuText N StatsFile "Data" 0
menuText N StatsFilePrint "Data afdrukken..." 0
menuText N StatsFileClose "Venster sluiten" 0
menuText N StatsOpt "Opties" 0

# PGN window menus:
menuText N PgnFile "Data" 0
menuText N PgnFilePrint "Data afdrukken..." 0
menuText N PgnFileClose "PGN-venster sluiten" 0
menuText N PgnOpt "Opties" 0
menuText N PgnOptColor "Instellen kleuren" 10
menuText N PgnOptShort "Korte (3 regelige) kop" 0
menuText N PgnOptSymbols "Instellen symbolen" 10
menuText N PgnOptIndentC "Inspringen (commentaar)" 12
menuText N PgnOptIndentV "Inspringen (variant)" 12
menuText N PgnOptColumn "Kolom stijl (een zet per regel)" 0
menuText N PgnOptSpace "Spatie na zetnummer" 0
menuText N PgnOptStripMarks "Strip out colored square/arrow codes" 1 ;# ***
menuText N PgnColor "Kleuren" 0
menuText N PgnColorHeader "Kop..." 0
menuText N PgnColorAnno "Opmerkingen..." 0
menuText N PgnColorComments "Commentaar..." 0
menuText N PgnColorVars "Varianten..." 0
menuText N PgnColorBackground "Achtergrond kleur..." 0
menuText N PgnHelp "Help" 0
menuText N PgnHelpPgn "PGN help" 0
menuText N PgnHelpIndex "Index" 0

# Crosstable window menus:
menuText N CrosstabFile "Data" 0
menuText N CrosstabFileText "Afdrukken in tekstformaat..." 13
menuText N CrosstabFileHtml "Afdrukken in HTML-formaat..." 13
menuText N CrosstabFileLaTeX "Afdrukken in LaTeX-formaat..." 13
menuText N CrosstabFileClose "Kruistabel sluiten" 0
menuText N CrosstabEdit "Bewerken" 0
menuText N CrosstabEditEvent "Evenement" 0
menuText N CrosstabEditSite "Plaats" 0
menuText N CrosstabEditDate "Datum" 0
menuText N CrosstabOpt "Opties" 0
menuText N CrosstabOptAll "Normale weergave" 0
menuText N CrosstabOptSwiss "Zwitsers" 0
menuText N CrosstabOptKnockout "Knockout" 0
menuText N CrosstabOptAuto "Auto" 0
menuText N CrosstabOptAges "Leeftijd in jaren" 8
menuText N CrosstabOptNats "Nationaliteiten" 1
menuText N CrosstabOptRatings "Elo" 0
menuText N CrosstabOptTitles "Titel" 0
menuText N CrosstabOptBreaks "Tie-break scores" 4 ;# ***
menuText N CrosstabOptDeleted "Include deleted games" 8 ;# ***
menuText N CrosstabOptColors "Kleuren (alleen bij Zwitsers)" 0
menuText N CrosstabOptColumnNumbers "Numbered columns (All-play-all table only)" 2 ;# ***
menuText N CrosstabOptGroup "Punten (groep)" 0
menuText N CrosstabSort "Sorteren" 0
menuText N CrosstabSortName "Naam" 0
menuText N CrosstabSortRating "Elo" 0
menuText N CrosstabSortScore "Punten" 0
menuText N CrosstabColor "Kleuren" 0
menuText N CrosstabColorPlain "Tekst" 0
menuText N CrosstabColorHyper "Hypertekst" 1
menuText N CrosstabHelp "Help" 0
menuText N CrosstabHelpCross "Help (kruistabel)" 0
menuText N CrosstabHelpIndex "Index" 0
translate N SetFilter {Zet Filter}
translate N AddToFilter {Toevoegen aan selectie}
translate N Swiss {Zwitsers}

# Opening report window menus:
menuText N OprepFile "Data" 0
menuText N OprepFileText "Afdrukken in tekstformaat..." 13
menuText N OprepFileHtml "Afdrukken in HTML-formaat..." 13
menuText N OprepFileLaTeX "Afdrukken in LaTeX-formaat..." 13
menuText N OprepFileOptions "Optie..." 0
menuText N OprepFileClose "Sluit rapportvenster" 0
menuText N OprepHelp "Help" 0
menuText N OprepHelpReport "Help (openingsrapport)" 0
menuText N OprepHelpIndex "Index" 0

# Repertoire editor:
menuText N RepFile "Data" 0
menuText N RepFileNew "Nieuw" 0
menuText N RepFileOpen "Openen..." 0
menuText N RepFileSave "Bewaren..." 0
menuText N RepFileSaveAs "Bewaren als..." 5
menuText N RepFileClose "Sluit venster" 2
menuText N RepEdit "Bewerken" 0
menuText N RepEditGroup "Toevoegen Groep" 4
menuText N RepEditInclude "Toevoegen inclusief regel" 4
menuText N RepEditExclude "Toevoegen exclusief regel" 4
menuText N RepView "Bekijken" 0
menuText N RepViewExpand "Uitklappen alle groepen" 0
menuText N RepViewCollapse "Inklappen alle groepen" 0
menuText N RepSearch "Selecteren" 0
menuText N RepSearchAll "Alles van repetoir..." 0
menuText N RepSearchDisplayed "Alleen weergegeven regels..." 0
menuText N RepHelp "Help" 0
menuText N RepHelpRep "Repertoir help" 0
menuText N RepHelpIndex "Index" 0
translate N RepSearch "Zoeken repertoir"
translate N RepIncludedLines "inclusief regels"
translate N RepExcludedLines "exclusief regels"
translate N RepCloseDialog {Dit repetoir heeft onopgeslagen wijzigingen.

Wilt u doorgaan en de wijzigingen niet opslaan?
}

# Header search:
translate N HeaderSearch {Zoek naar kop}
translate N GamesWithNoECO {Partijen zonder ECO?}
translate N GameLength {Lengte partij}
translate N FindGamesWith {Vind partijen met vlag:}
translate N StdStart {Normaal begin}
translate N Promotions {Promotie}
translate N Comments {Commentaar}
translate N Variations {Varianten}
translate N Annotations {Opmerkingen}
translate N DeleteFlag {Gewist-kenmerken}
translate N WhiteOpFlag {Wit opening}
translate N BlackOpFlag {Zwart opening}
translate N MiddlegameFlag {Middlegame}
translate N EndgameFlag {Eindspel}
translate N NoveltyFlag {Nieuwtje}
translate N PawnFlag {Pionnenstructur}
translate N TacticsFlag {Taktiek}
translate N QsideFlag {Damevleugel}
translate N KsideFlag {Koningsvleugel}
translate N BrilliancyFlag {Briljant}
translate N BlunderFlag {Blunder}
translate N UserFlag {Gebruiker}
translate N PgnContains {PGN bevat tekst}

# Game list window:
translate N GlistNumber {Nummer}
translate N GlistWhite {Wit}
translate N GlistBlack {Zwart}
translate N GlistWElo {W-Elo}
translate N GlistBElo {Z-Elo}
translate N GlistEvent {Evenement}
translate N GlistSite {Plaats}
translate N GlistRound {Ronde}
translate N GlistDate {Datum}
translate N GlistYear {Jaar}
translate N GlistEDate {Datum evenement}
translate N GlistResult {Uitslag}
translate N GlistLength {Lengte}
translate N GlistCountry {Country}
translate N GlistECO {ECO}
translate N GlistOpening {Opening}
translate N GlistEndMaterial {End-Material} ;# ***
translate N GlistDeleted {Verwijderd}
translate N GlistFlags {Flags} ;# ***
translate N GlistVars {Varianten}
translate N GlistComments {Commentaar}
translate N GlistAnnos {Opmerkingen}
translate N GlistStart {Start}
translate N GlistGameNumber {Partij nummer}
translate N GlistFindText {Tekst vinden}
translate N GlistMoveField {Move} ;# ***
translate N GlistEditField {Configure} ;# ***
translate N GlistAddField {Add} ;# ***
translate N GlistDeleteField {Remove} ;# ***
translate N GlistWidth {Width} ;# ***
translate N GlistAlign {Align} ;# ***
translate N GlistColor {Kleuren}
translate N GlistSep {Separator} ;# ***

# Maintenance windows
translate N DatabaseName {Naam database:}
translate N TypeIcon {Symbool:}
translate N NumOfGames {Partijen:}
translate N NumDeletedGames {Gewiste partijen:}
translate N NumFilterGames {Partijen in filter:}
translate N YearRange {Periode:}
translate N RatingRange {Elo (laag/hoog):}
translate N Flag {Vlag}
translate N DeleteCurrent {Wis huidige partij}
translate N DeleteFilter {Wis geselecteerde partijen}
translate N DeleteAll {Wis alle partijen}
translate N UndeleteCurrent {Haal huidige partij terug}
translate N UndeleteFilter {Haal selectie terug}
translate N UndeleteAll {Haal alle partijen terug}
translate N DeleteTwins {Wis doublures}
translate N MarkCurrent {Markeer huidige partij}
translate N MarkFilter {Markeer geselecteerde partijen}
translate N MarkAll {Markeer alle partijen}
translate N UnmarkCurrent {Markering weghalen (partij)}
translate N UnmarkFilter { Markering weghalen (selectie)}
translate N UnmarkAll { Markering weghalen (alle partijen)}
translate N Spellchecking {Spellingscontrole}
translate N Players {Spelers}
translate N Events {Evenement}
translate N Sites {Plaats}
translate N Rounds {Ronde}
translate N DatabaseOps {Database bewerkingen}
translate N ReclassifyGames {Partijen ECO-classificeren...}
translate N CompactDatabase {Database compact maken}
translate N SortDatabase {Database sorteren}
translate N AddEloRatings {Toevoegen Elo ratings}
translate N AutoloadGame {Auto-laden partij nummer}
translate N StripTags {Strip PGN tags} ;# ***
translate N StripTag {Strip tag} ;# ***
translate N Cleaner {Cleaner}
translate N CleanerHelp {
De Scid Cleaner zal alle onderhoudsactiviteiten op de huidige database doen, welk u selecteert uit de onderstaande lijst.

De huidige instellingen in de ECO classificatie en verwijderen dubbelen dialogen zullen worden toegepast indien u deze selecteert.
}
translate N CleanerConfirm {
Als Cleaner onderhoud is gestart, kan deze niet worden onderbroken!

Dit kan lang duren op een grote database, afhankelijk van de geselecteerde functies en de bijbehorende instellingen.

Weet u zeker dat u de geselecteerde onderhoudsfuncties wilt uitvoeren?
}

# Comment editor:
translate N AnnotationSymbols  {Symbolen voor annotatie:}
translate N Comment {Commentaar:}

# Board search:
translate N BoardSearch {Zoeken Bord}
translate N FilterOperation {Toepassen op huidige selectie:}
translate N FilterAnd {AND (Selectie beperken)}
translate N FilterOr {OR (Selectie uitbreiden)}
translate N FilterIgnore {Ongedaan maken (Geen selectie)}
translate N SearchType {Zoek type stelling:}
translate N SearchBoardExact {Exacte positie (stukken op deze velden)}
translate N SearchBoardPawns {Pionnen (gelijke stukken, alle pionnen op gelijke velden)}
translate N SearchBoardFiles {Lijnen (gelijk materiaal, alle pionnen op dezelfde lijnen)}
translate N SearchBoardAny {Materiaal (gelijk materiaal, pionnen en stukken willekeurig)}
translate N LookInVars {Zoek in varianten}

# Material search:
translate N MaterialSearch {Zoeken Materiaal}
translate N Material {Materiaal}
translate N Patterns {Patroon}
translate N Zero {Niets}
translate N Any {Willekeurig}
translate N CurrentBoard {Huidige stelling}
translate N CommonEndings {Eindspelen}
translate N CommonPatterns {Zelfde patroon}
translate N MaterialDiff {Material difference} ;# ***
translate N squares {Velden}
translate N SameColor {Gelijke kleur}
translate N OppColor {Ongelijke kleur}
translate N Either {Beide}
translate N MoveNumberRange {Zet bereik }
translate N MatchForAtLeast {Op z'n minst}
translate N HalfMoves {halve zetten}

# Game saving:
translate N Today {Nu}
translate N ClassifyGame {Partij classificeren}

# Setup position:
translate N EmptyBoard {Bord leegmaken}
translate N InitialBoard {Beginstelling}
translate N SideToMove {Aan zet:}
translate N MoveNumber {Zetnummer}
translate N Castling {Rokade}
translate N EnPassentFile {En passant lijn}
translate N ClearFen {FEN leegmaken}
translate N PasteFen {FEN plakken}

# Replace move dialog:
translate N ReplaceMove {Zet vervangen}
translate N AddNewVar {Nieuwe variant}
translate N ReplaceMoveMessage {Een zet bestaat hier al..

U kunt hem vervangen en alle volgende zetten wissen, of uw zet toevoegen als een nieuwe variant.

(U kunt deze boodschap vermijden door de optie "Zet vervangen bevestigen" uit te zetten in het menu:Zetten)}

# Make database read-only dialog:
translate N ReadOnlyDialog {Als u deze database "alleen-lezen" maakt, zijn geen veranderingen toegestaan.
Geen partijen kunnen worden opgeslagen of veranderd en ook geen wis-markering.
Elke sortering of ECO-classificering is tijdelijk.

U kunt de database weer schrijf-toegankelijk maken door hem te sluiten en weer te openen.

Wilt u echt deze database alleen-lezen maken?}

# Clear game dialog:
translate N ClearGameDialog {Deze partij is gewijzigd.

Wilt u doorgaan en de wijzigingen niet doorvoeren?
}

# Exit dialog:
translate N ExitDialog {Wilt u Scid werkelijk afsluiten?}
translate N ExitUnsaved {The following databases have unsaved game changes. If you exit now, these changes will be lost.} ;# ***

# Import window:
translate N PasteCurrentGame {Plak huidige partij}
translate N ImportHelp1 {Invoeren of plak PGN-formaat partij in het scherm hierboven.}
translate N ImportHelp2 {Alle import-fouten worden hier weergegeven.}

# ECO Browser:
translate N ECOAllSections {alle ECO codes}
translate N ECOSection {ECO code}
translate N ECOSummary {Samenvatting voor}
translate N ECOFrequency {Frequentie van subcodes voor}

# Opening Report:
translate N OprepTitle {Openings rapportage}
translate N OprepReport {Rapportage}
translate N OprepGenerated {Samensesteld door}
translate N OprepStatsHist {Statistieken en geschiedenis}
translate N OprepStats {Statistieken}
translate N OprepStatAll {Alle Rapportage Partijen}
translate N OprepStatBoth {Beide Spelers}
translate N OprepStatSince {Sinds}
translate N OprepOldest {Oudste partijen}
translate N OprepNewest {Meest recente partijen}
translate N OprepPopular {Populariteit}
translate N OprepFreqAll {Frequentie over alle jaren: }
translate N OprepFreq1   {In het afgelopen jaar:      }
translate N OprepFreq5   {In de afgelopen  5 jaar:    }
translate N OprepFreq10  {In de afgelopen 10 jaar:    }
translate N OprepEvery {Eens per %u partijen}
translate N OprepUp {%u%s dan alle jaren}
translate N OprepDown {%u%s lager dan alle jaren}
translate N OprepSame {zelfde als alle jaren}
translate N OprepMostFrequent {Meest frequente spelers}
translate N OprepRatingsPerf {Ratings en resultaten}
translate N OprepAvgPerf {Gemiddelde rating en resultaten}
translate N OprepWRating {Witte rating}
translate N OprepBRating {Zwarte rating}
translate N OprepWPerf {Resultaten wit}
translate N OprepBPerf {Resultaten zwart}
translate N OprepHighRating {Partijen met de hoogste gemiddelde rating}
translate N OprepTrends {Resultaten trends}
translate N OprepResults {Resultaat lengtes en frequenties}
translate N OprepLength {Partij lengte}
translate N OprepFrequency {Frequentie}
translate N OprepWWins {Overwinningen wit:   }
translate N OprepBWins {Overwinningen zwart: }
translate N OprepDraws {Remises: }
translate N OprepWholeDB {hele database}
translate N OprepShortest {Shortest wins} ;# ***
# translate N OprepShortWhite {Kortste witte overwinningen}
# translate N OprepShortBlack {Kortste zwarte overwinningen}
translate N OprepMovesThemes {Zetten en thema's}
translate N OprepMoveOrders {Zetvolgorde om rapportstelling te bereiken}
translate N OprepMoveOrdersOne \
  {Er was slechts 1 volgorde om deze stelling te bereiken:}
translate N OprepMoveOrdersAll \
  {Er waren %u zet-volgordes om deze stelling te bereiken:}
translate N OprepMoveOrdersMany \
  {Er waren %u zet-volgordes om deze stelling te bereiken. De top %u zijn:}
translate N OprepMovesFrom {Zetten vanuit de rapportpositie:}
translate N OprepThemes {thema's}
translate N OprepThemeDescription {Frequentie van thema's bij zet %u:}
translate N OprepThemeSameCastling {Gelijke rochades}
translate N OprepThemeOppCastling {Tegengestelde rochades}
translate N OprepThemeNoCastling {Beide zijden niet gerocheerd}
translate N OprepThemeKPawnStorm {Pionnenstorm op koningsvleugel}
translate N OprepThemeQueenswap {Dameruil}
translate N OprepThemeIQP {Geisoleerde d-pion}
translate N OprepThemeWP567 {Witte pion op de 5e/6e/7e rij}
translate N OprepThemeBP234 {Zwarte pion op de 2e/3e/4e rij}
translate N OprepThemeOpenCDE {Open c/d/e lijn}
translate N OprepTheme1BishopPair {Slechts 1 kant heeft loperpaar}
translate N OprepEndgames {Eindspelen}
translate N OprepReportGames {Rapportage partijen}
translate N OprepAllGames {Alle partijen}
translate N OprepEndClass {Materiaal classificatie van eindstellingen}
translate N OprepTheoryTable {Theorie tabel}
translate N OprepTableComment {Samengesteld uit de %u partijen met de hoogste rating.}
translate N OprepExtraMoves {Extra zetten in theorie tabel}
translate N OprepMaxGames {Maximaal aantal partijen in theorie tabel}

# Piece Tracker window:
translate N TrackerSelectSingle {Left mouse button selects this piece.} ;# ***
translate N TrackerSelectPair {Left mouse button selects this piece; right button also selects its sibling.}
translate N TrackerSelectPawn {Left mouse button selects this pawn; right button selects all 8 pawns.}
translate N TrackerStat {Statistic}
translate N TrackerGames {% games with move to square}
translate N TrackerTime {% time on each square}
translate N TrackerMoves {Moves}
translate N TrackerMovesStart {Enter the move number where tracking should begin.}
translate N TrackerMovesStop {Enter the move number where tracking should stop.}

# Game selection dialogs:
translate N SelectAllGames {Alle partijen in de database}
translate N SelectFilterGames {Alleen partijen uit filter}
translate N SelectTournamentGames {Alleen partijen in huidig toernooi}
translate N SelectOlderGames {Alleen oudere partijen}

# Delete Twins window:
translate N TwinsNote {Om een dubbele partij te zijn moet deze minimaal dezelfde twee spelers en de onderstaande te selecteren criteriums bevatten. Bij vondst van een dubbele partij wordt de kortste partij verwijderd.
Hint: Controleer de database op spelfouten voordat dubbelen worden verwijderd. Dit verhoogd de kans op vinden van dubbele partijen. }
translate N TwinsCriteria {Criteriums: Dubbele partijen moeten hebben...}
translate N TwinsWhich {Onderzoek welke partijen}
translate N TwinsColors {Spelers dezelfde kleur?}
translate N TwinsEvent {Dezelfde gelegenheid?}
translate N TwinsSite {Dezelfde lokatie?}
translate N TwinsRound {Dezelfde ronde?}
translate N TwinsYear {Hetzelfde jaar?}
translate N TwinsMonth {Dezelfde maand?}
translate N TwinsDay {Dezelfde dag?}
translate N TwinsResult {Hetzelfde resultaat?}
translate N TwinsECO {Dezelfde ECO code?}
translate N TwinsMoves {Dezelfde zetten?}
translate N TwinsPlayers {Vergelijken speler namen:}
translate N TwinsPlayersExact {Exacte overeenkomst}
translate N TwinsPlayersPrefix {Alleen eerste 4 letters}
translate N TwinsWhen {Indien dubbelen verwijderen}
translate N TwinsSkipShort {Negeer alle partijen korter dan 5 zetten?}
translate N TwinsUndelete {Herstel eerste alle verwijderde partijen?}
translate N TwinsSetFilter {Instellen filter voor alle verwijderde dubbele partijen?}
translate N TwinsComments {Altijd partijen met commentaar bewaren?}
translate N TwinsVars {Altijd partijen met varianten bewaren?}
translate N TwinsDeleteWhich {Delete which game:} ;# ***
translate N TwinsDeleteShorter {Shorter game} ;# ***
translate N TwinsDeleteOlder {Smaller game number} ;# ***
translate N TwinsDeleteNewer {Larger game number} ;# ***
translate N TwinsDelete {Verwijderen partijen}

# Name editor window:
translate N NameEditType {Type naam om te wijzigen}
translate N NameEditSelect {Partijen om te wijzigen}
translate N NameEditReplace {Vervangen}
translate N NameEditWith {met}
translate N NameEditMatches {Matches: Druk Ctrl+1 tot Ctrl+9 om te selecteren}

# Classify window:
translate N Classify {Classificeren}
translate N ClassifyWhich {ECO-Classificatie welke partij}
translate N ClassifyAll {Alle partijen (overschrijven oude ECO codes)}
translate N ClassifyYear {Alle partijen gespeeld in het afgelopen jaar}
translate N ClassifyMonth {Alle partijen gespeeld in de afgelopen maand}
translate N ClassifyNew {Alleen partijen zonder ECO code}
translate N ClassifyCodes {ECO Codes om te gebruiken}
translate N ClassifyBasic {Alleen basis codes ("B12", ...)}
translate N ClassifyExtended {Scid extenties ("B12j", ...)}

# Compaction:
translate N NameFile {Bestandsnaam}
translate N GameFile {Partijenbestand}
translate N Names {Namen}
translate N Unused {Ongebruikt}
translate N SizeKb {Grootte (kb)}
translate N CurrentState {Huidige toestand}
translate N AfterCompaction {Na comprimeren}
translate N CompactNames {Gecomprimeerd bestandsnaam}
translate N CompactGames {Gecomprimeerd partijenbestand}

# Sorting:
translate N SortCriteria {Criteriums}
translate N AddCriteria {Toevoegen criterium}
translate N CommonSorts {Algemene sorteringen}
translate N Sort {Sorteren}

# Exporting:
translate N AddToExistingFile {Toevoegen partijen aan bestaand bestand?}
translate N ExportComments {Exporteren commentaar?}
translate N ExportVariations {Exporteren varianten?}
translate N IndentComments {Inspringen commentaar?}
translate N IndentVariations {Inspringen varianten?}
translate N ExportColumnStyle {Kolomstijl (een zet per regel)?}
translate N ExportSymbolStyle {Symbolische annotatie stijl:}
translate N ExportStripMarks {Strip square/arrow mark codes from comments?} ;# ***

# Goto game/move dialogs:
translate N LoadGameNumber {Geef het nummer van de te laden partij:}
translate N GotoMoveNumber {Ga na zetnummer:}

# Copy games dialog:
translate N CopyGames {Kopieren partijen}
translate N CopyConfirm {
 Wilt u kopieren
 de [thousands $nGamesToCopy] gefilterde partijen
 in de database "$fromName"
 naar de database "$targetName"?
}
translate N CopyErr {Kan partijen niet kopieren}
translate N CopyErrSource {de bron database}
translate N CopyErrTarget {de doel database}
translate N CopyErrNoGames {heeft geen partijen in het filter}
translate N CopyErrReadOnly {is alleen-lezen}
translate N CopyErrNotOpen {is niet geopend}

# Colors:
translate N LightSquares {Lichte velden}
translate N DarkSquares {Donkere velden}
translate N SelectedSquares {Geselecteerde velden}
translate N SuggestedSquares {Zetsuggestie velden}
translate N WhitePieces {Witte stukken}
translate N BlackPieces {Zwarte stukken}
translate N WhiteBorder {Witte rand}
translate N BlackBorder {Zwarte rand}

# Novelty window:
translate N FindNovelty {Vind Nieuwtje}
translate N Novelty {Nieuwtje}
translate N NoveltyInterrupt {Zoeken nieuwtje onderbroken}
translate N NoveltyNone {In deze partij is geen nieuwtje gevonden}
translate N NoveltyHelp {
Scid zal de eerste zet vinden in de huidige partij, welke een positie heeft die nog niet was gevonden in de database of het ECO openingsboek.
}

# Upgrading databases:
translate N Upgrading {Upgrading}
translate N ConfirmOpenNew {
Dit is een oud formaat (Scid 2) database welke in Scid 3 niet kan worden geopend. Maar een nieuwe versie (Scid 3) is reeds aangemaakt.

Wilt u de database in het nieuwe formaat openen?
}
translate N ConfirmUpgrade {
Dit is een oud formaat (Scid 2) database. Een versie in het nieuwe formaat moet worden gemaakt, voordat het in Scid 3 kan worden gebruikt.

Een upgrade creeert een nieuwe versie van de database. De originele bestanden blijven bestaan en worden niet gewijzigd..

Dit kan enige tijd duren, maar het hoeft slechts eenmalig plaats te vinden. U kunt het afbreken indien het te lang duurt.

Wilt u de database nu upgraden?
}

}
# End of nederlan.tcl
