# swedish.tcl:
# Text for menu names and status bar help messages in Swedish.
# Part of Scid (Shane's Chess Information Database).
# Contributed by Martin Skjöldebrand, martin@hauntedhousesw.com

addLanguage W Swedish 1

proc setLanguage_W {} {

# File menu:
menuText W File "Arkiv" 0
menuText W FileNew "Ny..." 0 {Skapa en ny Scid databas}
menuText W FileOpen "Öppna..." 0 {Öpnna en befintlig Scid databas}
menuText W FileClose "Stäng" 0 {Stäng den aktiva Scid databasen}
menuText W FileFinder "Sök filer" 4 {Öppna sökdialogen}
menuText W FileBookmarks "Bokmärken" 0 {Hantera bokmärken (genväg: Ctrl+B)}
menuText W FileBookmarksAdd "Nytt bokmärke" 0 \
  {Markera den aktiva ställningen i partiet}
menuText W FileBookmarksFile "Spara bokmärke" 0 \
  {Spara bokmärket för den aktiva ställningen i partiet}
menuText W FileBookmarksEdit "Redigera bokmärken..." 0 \
  {Redigera bokmärken}
menuText W FileBookmarksList "Visa bokmärken som lista" 19 \
  {Visar bokmärkena som lista, inte undermenyer}
menuText W FileBookmarksSub "Visa bokmärken i undermenyer" 17 \
  {Visar bokmärkena som undermenyer, inte lista}
menuText W FileMaint "Databasverktyg" 0 {Scids databasverktyg}
menuText W FileMaintWin "Verktygsfönster" 0 \
  {Öppna/ stäng verktygsfönstret}
menuText W FileMaintCompact "Komprimera databasen..." 0 \
  {Komprimera databasen, avlägsna raderade partier och oanvända namn}
menuText W FileMaintClass "Klassificera partier enligt ECO..." 2 \
  {Klassificera om alla partier enligt ECO-systemet}
menuText W FileMaintSort "Sortera databasen..." 0 \
  {Sortera partierna i den aktiva databasen}
menuText W FileMaintDelete "Radera dubbletter..." 0 \
  {Sök dubbletter och markera de som raderingsbara}
menuText W FileMaintTwin "Sök dubbletter" 0 \
  {Öppna/ stäng dubblettfönstret}
menuText W FileMaintName "Stavningskontroll" 0 {Namnredigering och stavningskontroll}
menuText W FileMaintNameEditor "Redigera namn" 0 \
  {Öppna/stäng namnredigeringsfönstret}
menuText W FileMaintNamePlayer "Stavningskontrollera namn..." 22 \
  {Stavningskontrollera namn utifrån rättstavningsfilen}
menuText W FileMaintNameEvent "Stavningskontrollera evenemang..." 21 \
  {Stavningskontrollera evenmang utifrån rättstavningsfilen}
menuText W FileMaintNameSite "Stavningskontrollera platser..." 21 \
  {Stavningskontrollera platser utifrån rättstavningsfilen}
menuText W FileMaintNameRound "Stavningskontrollera ronder..." 21 \
  {Stavningskontrollera ronder utifrån rättstavningsfilen}
menuText W FileReadOnly "Enbart läsbar..." 8 \
  {Avlägsna temporärt redigeringsmöjligheterna till databasen}
menuText W FileExit "Avsluta" 0 {Avsluta Scid}

# Edit menu:
menuText W Edit "Redigera" 0
menuText W EditAdd "Lägg till variant" 0 {Skapa en variant vid denna ställning}
menuText W EditDelete "Radera variant" 0 {Radera en variant vid denna ställning}
menuText W EditFirst "Skapa huvudvariant" 6 \
  {Gör en av varianterna till huvudvariant}
menuText W EditMain "Skapa nytt textdrag" 11 \
  {Gör en av varianterna till partifortsättning}
menuText W EditTrial "Testa variant" 6 \
  {Starta/ stoppa testläge, undersök en ide på brädet}
menuText W EditStrip "Ta bort" 3 {Avlägsna kommentarer eller varianter från partiet}
menuText W EditStripComments "Kommentarer" 0 \
  {Avlägsna alla kommentarer och noteringar från partiet}
menuText W EditStripVars "Varianter" 0 {Avlägsna alla varinter från partiet}
menuText W EditReset "Töm Clipbase" 1 \
  {Tömmer den temporära databasen}
menuText W EditCopy "Kopiera partiet till Clipbase" 21 \
  {Kopierar det aktuella partiet till Clipbase}
menuText W EditPaste "Klistra in det senaste Clipbasepartiet" 8 \
  {Klistrar in det senaste tillagda i Clipbase i den aktiva databasen}
menuText W EditSetup "Skapa ställning..." 0 \
  {Skapa en utgångsställning för aktuellt parti}
menuText W EditPasteBoard "Klistra in utgångsställning" 10 \
  {Klistra in ställningen från aktuellt parti i den temporära databasen}

# Game menu:
menuText W Game "Partier" 0
menuText W GameNew "Nytt parti" 0 \
  {Återställ brädet inför ett nytt parti (raderar alla ändringar)}
menuText W GameFirst "Ladda det första partiet" 10 {Laddar det första partiet i filtret}
menuText W GamePrev "Ladda föregående parti" 7 {Ladda föregående parti i filtret}
menuText W GameReload "Börja om partiet" 0 \
  {Återställ partiet (raderar alla ändringar)}
menuText W GameNext "Ladda nästa parti" 6 {Ladda nästa parti i filtret}
menuText W GameLast "Ladda det sista partiet" 10 {Ladda det sista partiet i filtret}
menuText W GameRandom "Load Random Game" 8 {Load a random filtered game} ;# ***
menuText W GameNumber "Ladda parti nummer..." 6 \
  {Ladda ett parti genom att ange dess nummer}
menuText W GameReplace "Spara: Ersätt parti..." 7 \
  {Spara partiet och ersätt tidigare version}
menuText W GameAdd "Spara: Nytt parti..." 1 \
  {Spara ett nytt parti}
menuText W GameDeepest "Identifiera öppningen" 0 \
  {Gå till den mest detaljerade ställningen i ECO boken}
menuText W GameGotoMove "Gå till drag nummer..." 8 \
  {Gå till ett specifikt drag i partiet}
menuText W GameNovelty "Hitta nyhet..." 7 \
  {Hitta det första draget i partiet som inte spelats tidigare}

# Search Menu:
menuText W Search "Sök" 0
menuText W SearchReset "Återställ sökfilter" 0 {Återställ sökfiltret så att alla partiet ingår}
menuText W SearchNegate "Omvänt filter" 0 {Ta med partier som utesluts av filtret}
menuText W SearchCurrent "Aktuell position..." 8 {Sök partier med aktuell position på brädet}
menuText W SearchHeader "I huvud..." 2 {Använd fast information (spelare, evenemang, plats, mm)}
menuText W SearchMaterial "Material/ställning..." 0 {Sökning baserad på material eller ställning}
menuText W SearchUsing "Använd sökfil..." 10 {Använd en fil med lagrade sökvillkor}

# Windows menu:
menuText W Windows "Fönster" 0
menuText W WindowsComment "Kommentarseditor" 0 {Öppna/ stäng kommentarseditorn}
menuText W WindowsGList "Partilista" 5 {Öppna/ stäng partilistan}
menuText W WindowsPGN "PGN fönster" 0 \
  {Öppna/ stäng PGN fönstret}
menuText W WindowsTmt "Turneringar" 0 {Lista turneringar}
menuText W WindowsSwitcher "Databasväxlaren" 0 \
  {Öppna/ stäng databasväxlaren}
menuText W WindowsMaint "Verktygsfönster" 0 \
  {Öppna/ stäng verktygsfönstret}
menuText W WindowsECO "ECO fönster" 0 {Öppna/ stäng ECO bläddraren}
menuText W WindowsRepertoire "Repertoireditor" 0 \
  {Öppna/ stäng spelöppningsfönstret}
menuText W WindowsStats "Statistikfönster" 0 \
  {Öppna/ stäng statistikfönstret}
menuText W WindowsTree "Trädfönster" 2 {Öppna/ stäng variantträdets fönster}
menuText W WindowsTB "Slutspelsdatabas" 2 \
  {Öppna/ stäng slutspelsdatabasfönstret}

# Tools menu:
menuText W Tools "Verktyg" 0
menuText W ToolsAnalysis "Analysmotor..." 6 \
  {Starta/ stoppa en analysmotor}
menuText W ToolsAnalysis2 "Analysmotor 2..." 12 \
  {Starta/ stoppa en andra analysmotor}
menuText W ToolsCross "Resultattabell" 0 {Visa en resultattabell för den aktuella turneringen}
menuText W ToolsEmail "Eposthanterare" 0 \
  {Öppna/ stäng eposthanteraren}
menuText W ToolsFilterGraph "Filter graph" 7 \
  {Open/close the filter graph window} ;# ***
menuText W ToolsOpReport "Öppningsrapport" 0 \
  {Skapa en öppningsrapport utifrån den aktuella ställningen}
menuText W ToolsTracker "Sök material"  0 {Öppnar dialog för att söka efter en viss materiell balans} 
menuText W ToolsPInfo "Spelarinformation"  0 \
  {Öppna/ uppdatera spelarinformation}
menuText W ToolsRating "Rankingdiagram" 0 \
  {Skapa ett ranking diagram för spelarna i partiet}
menuText W ToolsScore "Resultatdiagram" 8 {Visa resultatdiagrammet}
menuText W ToolsExpCurrent "Exportera aktuellt parti" 1 \
  {Spara aktuellt parti till en textfil}
menuText W ToolsExpCurrentPGN "Exportera till PGN..." 15 \
  {Spara aktuellt parti till en PGN-fil}
menuText W ToolsExpCurrentHTML "Exportera till HTML..." 15 \
  {Spara aktuellt parti till en HTML-fil}
menuText W ToolsExpCurrentLaTeX "Exportera till LaTeX..." 15 \
  {Spara aktuellt parti till en LaTeX-fil}
menuText W ToolsExpFilter "Exportera alla filtrerade partier" 15 \
  {Spara alla filterade partier till en textfil}
menuText W ToolsExpFilterPGN "Exportera till PGN..." 15 \
  {Spara alla filterade partier till en PGN-fil}
menuText W ToolsExpFilterHTML "Exportera till HTML..." 15 \
  {Spara alla filterade partier till en HTML-fil}
menuText W ToolsExpFilterLaTeX "Exportera till LaTeX..." 15 \
  {Spara alla filterade partier till en LaTeX-fil}
menuText W ToolsImportOne "Importera ett parti i PGN-format..." 0 \
  {Importera ett parti i PGN-format}
menuText W ToolsImportFile "Importera flera partier i PGN-format..." 16 \
  {Importera flera partier i PGN-format från en fil}

# Options menu:
menuText W Options "Alternativ" 2
menuText W OptionsSize "Brädstorlek" 0 {Ändra brädets storlek}
menuText W OptionsPieces "Pjäsutseende" 1 {Ändra pjäsernas utseende} 
menuText W OptionsColors "Färger..." 0 {Ändra brädets färger}
menuText W OptionsExport "Export" 0 {Ändra exportalternativ}
menuText W OptionsFonts "Typsnitt" 0 {Ändra typsnitt}
menuText W OptionsFontsRegular "Normal" 0 {Ändra det normala typsnittet}
menuText W OptionsFontsSmall "Liten" 0 {Ändra det lilla typsnittet}
menuText W OptionsFontsFixed "Fixerad" 0 {Ändra det fixerade typsnittet}
menuText W OptionsGInfo "Partiinformation" 0 {Alternativ för partiinformation}
menuText W OptionsLanguage "Språk" 0 {Välj språk}
menuText W OptionsMoves "Drag" 0 {Alternativ för dragangivelse}
menuText W OptionsMovesAsk "Fråga före ersätt drag" 0 \
  {Fråga innan du ersätter befintliga drag}
menuText W OptionsMovesDelay "Fördröjning vid automatspel..." 1 \
  {Ange fördröjning mellan dragen när datorn spelar själv}
menuText W OptionsMovesCoord "Koordinater" 0 \
  {Acceptera koordinater ("g1f3") vid dragangivelse}
menuText W OptionsMovesSuggest "Visa föreslagna drag" 0 \
  {Visa/ Dölj föreslagna drag}
menuText W OptionsMovesKey "Tangentkomplettering" 0 \
  {Sätt på/ stäng av dragkomplettering vid tangentinmatning}
menuText W OptionsNumbers "Talformat" 3 {Välj hur tal visas}
menuText W OptionsStartup "Start" 3 {Välj vilka fönster som ska öppnas vid start}
menuText W OptionsWindows "Fönster" 1 {Fönsteralternativ}
menuText W OptionsWindowsIconify "Minimera automatiskt" 5 \
  {Minimera alla fönster när huvufönstret minimeras}
menuText W OptionsWindowsRaise "Autofokus" 0 \
  {Visa åter vissa fönster (t ex. resultaträknare) automatiskt när de döljs}
menuText W OptionsToolbar "Verktygsfält" 0 \
  {Visa/ dölj huvudfönstrets verktygsfält}
menuText W OptionsECO "Ladda ECO fil..." 7 {Ladda ECO-klassificeringen vid start}
menuText W OptionsSpell "Ladda Rättstavningsfil..." 7 \
  {Ladda rättstavningsfilen vid start}
menuText W OptionsTable "Katalog för slutspelsdatabaser..." 0 \
  {Välj en fil som innehåller en slutspelsdatabas; alla övriga filer i samma katalog kommer att användas}
menuText W OptionsSave "Spara alternativ" 7 \
  "Spara alla alternativ till en inställnignsfil"
menuText W OptionsAutoSave "Autospara vid avslut" 1 \
  {Spara alla alternativ när du avslutar Scid}

# Help menu:
menuText W Help "Hjälp" 0
menuText W HelpIndex "Index" 0 {Hjälpsystemets innehållsförteckning}
menuText W HelpGuide "Snabbguide" 0 {Visa snabbguiden}
menuText W HelpHints "Tips" 0 {Visa tips}
menuText W HelpContact "Kontaktinformation" 0 {Visa kontaktinformation}
menuText W HelpTip "Dagens tips" 0 {Användbara Scid tips}
menuText W HelpStartup "Startfönster" 5 {Visa startfönstret}
menuText W HelpAbout "Om Scid" 0 {Information om Scid}

# Game info box popup menu:
menuText W GInfoHideNext "Dölj nästa drag" 0
menuText W GInfoMaterial "Visa materialvärden" 0
menuText W GInfoFEN "Visa FEN" 5
menuText W GInfoMarks "Visa färgade fält och pilar" 22 
menuText W GInfoWrap "Radbrytning" 0
menuText W GInfoFullComment "Visa fullständiga kommentarer" 18
menuText W GInfoTBNothing "Slutspelsdatabaser: inget" 20
menuText W GInfoTBResult "Slutspelsdatabaser: endast resultat" 28
menuText W GInfoTBAll "Slutspelsdatabaser: resultat och bästa drag" 33
menuText W GInfoDelete "Återta/Radera detta parti" 0
menuText W GInfoMark "(Av-)Markera detta parti" 5

# Main window buttons:
helpMsg W .button.start {Gå till början av partiet  (tangent: Home)}
helpMsg W .button.end {Gå till slutet av partiet  (tangent: End)}
helpMsg W .button.back {Back ett drag (tangent: Vänsterpil)}
helpMsg W .button.forward {Gå fram ett drag  (tangent: Högerpil)}
helpMsg W .button.intoVar {Gå in i variant (genväg: v)}
helpMsg W .button.exitVar {Gå ur variant  (genväg: z)}
helpMsg W .button.flip {Rotera brädet  (genväg: .)}
helpMsg W .button.coords {Slå av eller på koordinater  (genväg: 0)}
helpMsg W .button.autoplay {Autospel  (tangent: Ctrl+Z)}

# General buttons:
translate W Back {Tillbaka}
translate W Cancel {Avbryt}
translate W Clear {Rensa}
translate W Close {Stäng}
translate W Defaults {Standard}
translate W Delete {Radera}
translate W Graph {Diagram}
translate W Help {Hjälp}
translate W Import {Importera}
translate W Index {Index}
translate W LoadGame {Ladda parti}
translate W BrowseGame {Bläddra genom partier}
translate W MergeGame {Slå samman partier}
translate W Preview {Förhandsgranska}
translate W Revert {Ångra inmatning}
translate W Save {Spara}
translate W Search {Sök}
translate W Stop {Stoppa}
translate W Store {Spara}
translate W Update {Uppdatera}
translate W ChangeOrient {Ändra fönstrets orientering}
translate W None {Ingen}
translate W First {Första}
translate W Current {Aktuella}
translate W Last {Sista}

# General messages:
translate W game {parti}
translate W games {partier}
translate W move {drag}
translate W moves {drag}
translate W all {alla}
translate W Yes {Ja}
translate W No {Nej}
translate W Both {Båda}
translate W King {Kung}
translate W Queen {Dam}
translate W Rook {Torn}
translate W Bishop {Löpare}
translate W Knight {Springare}
translate W Pawn {Bonde}
translate W White {Vit}
translate W Black {Svart}
translate W Player {Spelare}
translate W Rating {Ranking}
translate W RatingDiff {Rankingskillnad (Vit - Svart)}
translate W Event {Evenemang}
translate W Site {Plats}
translate W Country {Land}
translate W IgnoreColors {Ignorera färger}
translate W Date {Datum}
translate W EventDate {Evenmangsdatum}
translate W Decade {Decade} ;# ***
translate W Year {År}
translate W Month {Månad}
translate W Months {Januari Februari Mars April Maj Juni
  Juli Augusti September Oktober November December}
translate W Days {Sön Mån Tis Ons Tors Fre Lör}
translate W YearToToday {Idag}
translate W Result {Resultat}
translate W Round {Rond}
translate W Length {Längd}
translate W ECOCode {ECO kod}
translate W ECO {ECO}
translate W Deleted {Raderad}
translate W SearchResults {Sökresultat}
translate W OpeningTheDatabase {Öppnar databas}
translate W Database {Databas}
translate W Filter {Filter}
translate W noGames {inga partier}
translate W allGames {alla partier}
translate W empty {tom}
translate W clipbase {temporär databas}
translate W score {resultat}
translate W StartPos {Utgångsställning}
translate W Total {Totalt}

# Game information:
translate W twin {dubblett}
translate W deleted {raderad}
translate W comment {kommentar}
translate W hidden {dold}
translate W LastMove {Senaste draget}
translate W NextMove {Nästa}
translate W GameStart {Utgångsställning}
translate W LineStart {Varianten börjar}
translate W GameEnd {Slutställning}
translate W LineEnd {Varianten slut}

# Player information:
translate W PInfoAll {Resultat för <b>alla</b> partier}
translate W PInfoFilter {Resultat för <b>filtrerade</b> partier}
translate W PInfoAgainst {Resultat mot}
translate W PInfoMostWhite {De vanligaste öppningarna som vit}
translate W PInfoMostBlack {De vanligaste öppningarna som svart}
translate W PInfoRating {Rankinghistoria}
translate W PInfoBio {Biografisk information}

# Tablebase information:
translate W Draw {Remi}
translate W stalemate {patt}
translate W withAllMoves {med alla drag}
translate W withAllButOneMove {med alla drag utom ett}
translate W with {med}
translate W only {bara}
translate W lose {förlust}
translate W loses {förluster}
translate W allOthersLose {alla andra förlorar}
translate W matesIn {med matt i}
translate W hasCheckmated {har satt matt}
translate W longest {längst}

# Tip of the day:
translate W Tip {Tips}
translate W TipAtStartup {Tips vid start}

# Tree window menus:
menuText W TreeFile "Fil" 0
menuText W TreeFileSave "Spara cachefil" 0 {Spara trädcache (.stc) filen}
menuText W TreeFileFill "Fyll cache fil" 0 \
  {Fyll cachefilen med vanliga öppningar}
menuText W TreeFileBest "Lista bästa partier" 0 {Visa lista över de bästra partierna i trädet}
menuText W TreeFileGraph "Diagramfönster" 0 {Visa diagrammet för denna gren i trädet}
menuText W TreeFileCopy "Kopiera träd till urklipp" 1 \
  {Kopierar trädrelaterad statistik till urklipp}
menuText W TreeFileClose "Stäng trädfönstret" 0 {Stäng trädfönstret}
menuText W TreeSort "Sortera" 0
menuText W TreeSortAlpha "Alfabetiskt" 0
menuText W TreeSortECO "ECO kod" 0
menuText W TreeSortFreq "Frekvens" 0
menuText W TreeSortScore "Resultat" 0
menuText W TreeOpt "Options" 0
menuText W TreeOptLock "Lås" 0 {Lås/ lås upp trädet för den aktuella databasen}
menuText W TreeOptTraining "Träna" 0 {Sätt på/ stäng av träningsläge}
menuText W TreeOptAutosave "Spara cache filen automatiskt" 0 \
  {Spara cache filen automatiskt när trädfönstret stängs}
menuText W TreeHelp "Hjälp" 0
menuText W TreeHelpTree "Trädhjälp" 0
menuText W TreeHelpIndex "Hjälp index" 0
translate W SaveCache {Spara cache}
translate W Training {Träna}
translate W LockTree {Lås}
translate W TreeLocked {Låst}
translate W TreeBest {Bäst}
translate W TreeBestGames {Bästa partier i trädet}

# Finder window:
menuText W FinderFile "Fil" 0
menuText W FinderFileSubdirs "Sök i underkataloger" 0
menuText W FinderFileClose "Stäng File Finder" 0
menuText W FinderSort "Sortera" 0
menuText W FinderSortType "Typ" 0
menuText W FinderSortSize "Storlek" 0
menuText W FinderSortMod "Förändrad" 0
menuText W FinderSortName "Namn" 0
menuText W FinderSortPath "Sökväg" 0
menuText W FinderTypes "Typer" 0
menuText W FinderTypesScid "Scid databaser" 0
menuText W FinderTypesOld "Scid databaser i äldre format" 0
menuText W FinderTypesPGN "PGN filer" 0
menuText W FinderTypesEPD "EPD filer" 0
menuText W FinderTypesRep "Öppningsfiler" 0
menuText W FinderHelp "Hjälp" 0
menuText W FinderHelpFinder "Hjälp för File Finder" 0
menuText W FinderHelpIndex "Hjälpindex" 0
translate W FileFinder {File Finder}
translate W FinderDir {Katalog}
translate W FinderDirs {Kataloger}
translate W FinderFiles {Filer}
translate W FinderUpDir {upp}

# Tournament finder:
menuText W TmtFile "Fil" 0
menuText W TmtFileUpdate "Uppdatera" 0
menuText W TmtFileClose "Stäng turneringshanteraren" 0
menuText W TmtSort "Sortera" 0
menuText W TmtSortDate "Datum" 0
menuText W TmtSortPlayers "Spelare" 0
menuText W TmtSortGames "Partier" 0
menuText W TmtSortElo "Elo" 0
menuText W TmtSortSite "Plats" 0
menuText W TmtSortEvent "Evenemang" 1
menuText W TmtSortWinner "Vinnare" 0
translate W TmtLimit "Listbegränsningar"
translate W TmtMeanElo "Lägsta snitt Elo"
translate W TmtNone "Inga turneringar hittades."

# Graph windows:
menuText W GraphFile "Fil" 0
menuText W GraphFileColor "Spara som Postscript (färg)" 8
menuText W GraphFileGrey "Spara som Postscript (gråskala)" 8
menuText W GraphFileClose "Stäng fönster" 6
menuText W GraphOptions "Alternativ" 0
menuText W GraphOptionsWhite "Vit" 0
menuText W GraphOptionsBlack "Svart" 0
menuText W GraphOptionsBoth "Båda" 1
menuText W GraphOptionsPInfo "Spelarinformation" 0
translate W GraphFilterTitle "Filter graph: frequency per 1000 games" ;# ***

# Analysis window:
translate W AddVariation {Lägg till variant}
translate W AddMove {Lägg till drag}
translate W Annotate {Kommentera}
translate W AnalysisCommand {Analysera}
translate W PreviousChoices {Föregående val}
translate W AnnotateTime {Ange tid mellan drag i sekunder}
translate W AnnotateWhich {Lägg till varianter}
translate W AnnotateAll {för båda sidors drag}
translate W AnnotateWhite {Endast vits drag}
translate W AnnotateBlack {Endast svarts drag}
translate W AnnotateNotBest {När partidraget inte är det bästa}

# Analysis Engine open dialog:
translate W EngineList {Lista över schackprogram}
translate W EngineName {Namn}
translate W EngineCmd {Startkommando}
translate W EngineArgs {Parametrar} 
translate W EngineDir {Katalog}
translate W EngineElo {Elo}
translate W EngineTime {Datum}
translate W EngineNew {Ny}
translate W EngineEdit {Redigera}
translate W EngineRequired {Fet stil indikerar obligatoriska fält; övriga fält är frivilliga} 

# Stats window menus:
menuText W StatsFile "Fil" 0
menuText W StatsFilePrint "Skriv ut till fil..." 0
menuText W StatsFileClose "Stäng fönster" 0
menuText W StatsOpt "Alternativ" 0

# PGN window menus:
menuText W PgnFile "Fil" 0
menuText W PgnFilePrint "Skriv ut till..." 0
menuText W PgnFileClose "Stäng PGN fönster" 0
menuText W PgnOpt "Presentation" 0
menuText W PgnOptColor "Färg" 0
menuText W PgnOptShort "Kort (3-raders) huvud" 0
menuText W PgnOptSymbols "Symbolbaserad kommentar" 1
menuText W PgnOptIndentC "Indragna kommentarer" 0
menuText W PgnOptIndentV "Indragna varianter" 7
menuText W PgnOptColumn "Spaltstil (ett drag per rad)" 1
menuText W PgnOptSpace "Utrymme efter dragnummer" 1
menuText W PgnOptStripMarks "Avlägnsa koder för färgade fält och pilar" 1 
menuText W PgnColor "Färger" 0
menuText W PgnColorHeader "Huvud..." 0
menuText W PgnColorAnno "Noteringar..." 0
menuText W PgnColorComments "Kommentarer..." 0
menuText W PgnColorVars "Varianter..." 0
menuText W PgnColorBackground "Bakgrund..." 0
menuText W PgnHelp "Hjälp" 0
menuText W PgnHelpPgn "PGN hjälp" 0
menuText W PgnHelpIndex "Index" 0

# Crosstable window menus:
menuText W CrosstabFile "Fil" 0
menuText W CrosstabFileText "Skriv ut till textfil..." 9
menuText W CrosstabFileHtml "Skriv ut till HTML-fil..." 9
menuText W CrosstabFileLaTeX "Skriv ut till LaTeX-fil..." 9
menuText W CrosstabFileClose "Stäng resultattabellsfönstret" 0
menuText W CrosstabEdit "Redigera" 0
menuText W CrosstabEditEvent "Evenemang" 0
menuText W CrosstabEditSite "Plats" 0
menuText W CrosstabEditDate "Datum" 0
menuText W CrosstabOpt "Presentation" 0
menuText W CrosstabOptAll "Alla-möter-alla" 0
menuText W CrosstabOptSwiss "Schweizer" 0
menuText W CrosstabOptKnockout "Knock Out" 0
menuText W CrosstabOptAuto "Auto" 1
menuText W CrosstabOptAges "Ålder i år" 8
menuText W CrosstabOptNats "Nationalitet" 0
menuText W CrosstabOptRatings "Ranking" 0
menuText W CrosstabOptTitles "Titlar" 0
menuText W CrosstabOptBreaks "Tie-break poäng" 4
menuText W CrosstabOptDeleted "Inkludera raderade partier" 8 
menuText W CrosstabOptColors "Färg (endast Schweizer)" 0
menuText W CrosstabOptColumnNumbers "Numrerade kolumner (Endast alla-mot-alla)" 2 
menuText W CrosstabOptGroup "Gruppresultat" 0
menuText W CrosstabSort "Sortera" 0
menuText W CrosstabSortName "Namn" 0
menuText W CrosstabSortRating "Ranking" 0
menuText W CrosstabSortScore "Resultat" 0
menuText W CrosstabColor "Färg" 0
menuText W CrosstabColorPlain "Ren text" 0
menuText W CrosstabColorHyper "Hypertext" 0
menuText W CrosstabHelp "Hjälp" 0
menuText W CrosstabHelpCross "Hjälp för resultattabell" 0
menuText W CrosstabHelpIndex "Hjälpindex" 0
translate W SetFilter {Bestäm filter}
translate W AddToFilter {Utöka filter}
translate W Swiss {Schweizer}

# Opening report window menus:
menuText W OprepFile "Fil" 0
menuText W OprepFileText "Skriv ut till textfil..." 9
menuText W OprepFileHtml "Skriv ut till HTML-fil..." 9
menuText W OprepFileLaTeX "Skriv ut till LaTeX-fil..." 9
menuText W OprepFileOptions "Alternativ..." 0
menuText W OprepFileClose "Stäng rapportfönstret" 0
menuText W OprepHelp "Hjälp" 0
menuText W OprepHelpReport "Hjälp för öppningsrapporter" 0
menuText W OprepHelpIndex "Hjälpindex" 0

# Repertoire editor:
menuText W RepFile "Fil" 0
menuText W RepFileNew "Ny" 0
menuText W RepFileOpen "Öppna..." 0
menuText W RepFileSave "Spara..." 0
menuText W RepFileSaveAs "Spara som..." 5
menuText W RepFileClose "Stäng fönster" 0
menuText W RepEdit "Redigera" 0
menuText W RepEditGroup "Lägg till grupp" 4
menuText W RepEditInclude "Lägg till inkluderad variant" 4
menuText W RepEditExclude "Lägg till exkluderad variant" 4
menuText W RepView "Visa" 0
menuText W RepViewExpand "Expandera alla grupper" 0
menuText W RepViewCollapse "Implodera alla grupper" 0
menuText W RepSearch "Sök" 0
menuText W RepSearchAll "Hela öppningsrepertoaren..." 0
menuText W RepSearchDisplayed "Endast visade varianter..." 0
menuText W RepHelp "Hjälp" 0
menuText W RepHelpRep "Hjälp för spelöppningsrepertoar" 0
menuText W RepHelpIndex "Hjälpindex" 0
translate W RepSearch "Sök i spelöppningsrepertoar"
translate W RepIncludedLines "inkluderade varianter"
translate W RepExcludedLines "exkluderade varianter"
translate W RepCloseDialog {Du har osparade ändringar i repertoaren.

Vill du verkligen fortsätta och förlora dina förändringar?
}

# Header search:
translate W HeaderSearch {Sök i partihuvud}
translate W GamesWithNoECO {Partier utan ECO kod?}
translate W GameLength {Partilängd}
translate W FindGamesWith {Hitta flaggade partier}
translate W StdStart {Normal utgångsställning}
translate W Promotions {Förvandlingar}
translate W Comments {Kommentarer}
translate W Variations {Varianter}
translate W Annotations {Noteringar}
translate W DeleteFlag {Raderingsflagga}
translate W WhiteOpFlag {Vits öppning}
translate W BlackOpFlag {Svarts öppning}
translate W MiddlegameFlag {Mittspel}
translate W EndgameFlag {Slutspel}
translate W NoveltyFlag {Nyhet}
translate W PawnFlag {Bondestruktur}
translate W TacticsFlag {Taktiska ställningar}
translate W QsideFlag {Damflygelsinitiativ}
translate W KsideFlag {Kungsflygelsinitiativ}
translate W BrilliancyFlag {Utmärkt parti}
translate W BlunderFlag {Bortsättningar}
translate W UserFlag {Användare}
translate W PgnContains {PGN innehåller text}

# Game list window:
translate W GlistNumber {Nummer}
translate W GlistWhite {Vit}
translate W GlistBlack {Svart}
translate W GlistWElo {Elo, v}
translate W GlistBElo {Elo, sv}
translate W GlistEvent {Evenemang}
translate W GlistSite {Plats}
translate W GlistRound {Rond}
translate W GlistDate {Datum}
translate W GlistYear {År}
translate W GlistEDate {Startdatum}
translate W GlistResult {Resultat}
translate W GlistLength {Längd}
translate W GlistCountry {Land}
translate W GlistECO {ECO}
translate W GlistOpening {Öppning}
translate W GlistEndMaterial {Slutmaterial}
translate W GlistDeleted {Raderad}
translate W GlistFlags {Flaggor}
translate W GlistVars {Varianter}
translate W GlistComments {Kommentarer}
translate W GlistAnnos {Noteringar}
translate W GlistStart {Start}
translate W GlistGameNumber {Partinummer}
translate W GlistFindText {Sök text}
translate W GlistMoveField {Drag}
translate W GlistEditField {Konfiguration}
translate W GlistAddField {Lägg till}
translate W GlistDeleteField {Ta bort}
translate W GlistWidth {Bredd}
translate W GlistAlign {Justering}
translate W GlistColor {Färg}
translate W GlistSep {Separator}

# Maintenance window:
translate W DatabaseName {Databasnamn:}
translate W TypeIcon {Ikontyp:}
translate W NumOfGames {Partier:}
translate W NumDeletedGames {Raderade partier:}
translate W NumFilterGames {Partier i filter:}
translate W YearRange {Tidsperiod:}
translate W RatingRange {Rankingintervall:}
translate W Flag {Flagga}
translate W DeleteCurrent {Radera aktuellt parti}
translate W DeleteFilter {Radera partierna i filteret}
translate W DeleteAll {Radera alla partier}
translate W UndeleteCurrent {Återta aktuellt parti}
translate W UndeleteFilter {Återta partierna i filtret}
translate W UndeleteAll {Återta alla partier}
translate W DeleteTwins {Radera dubbletter}
translate W MarkCurrent {Markera aktuellt parti}
translate W MarkFilter {Markera partierna i filtret}
translate W MarkAll {Markera alla partier}
translate W UnmarkCurrent {Avmarkera aktuellt parti}
translate W UnmarkFilter {Avmarkera partierna i filtret}
translate W UnmarkAll {Avmarkera alla partier}
translate W Spellchecking {Rättstava}
translate W Players {Spelare}
translate W Events {Evenmang}
translate W Sites {Platser}
translate W Rounds {Ronder}
translate W DatabaseOps {Databashantering}
translate W ReclassifyGames {ECO-klassificera partier}
translate W CompactDatabase {Komprimera databasen}
translate W SortDatabase {Sortera databasen}
translate W AddEloRatings {Lägg till Elo ranking}
translate W AutoloadGame {Ladda partinummer automatiskt}
translate W StripTags {Strip PGN tags} ;# ***
translate W StripTag {Strip tag} ;# ***
translate W Cleaner {Snygga till databasen}
translate W CleanerHelp {
Databasstädaren i Scid genomför allt det underhåll av databasen du kan välja nedan på den aktiva databasen.

De nuvarande inställningarna i ECO-klassificering och Radera dubbletter kommer att appliceras om du väljer dessa åtgärder.
}
translate W CleanerConfirm {
När du väl startat Databasstädaren kan du inte avbryta den!

På en stor databas kan detta ta ett bra tag. Tidsåtgången beror på valda åtgärder och deras inställningar.

Är du säker på att du vill påbörja databasunderhållet nu?
}

# Comment editor:
translate W AnnotationSymbols  {Symboler:}
translate W Comment {Kommentar:}

# Board search:
translate W BoardSearch {Positionssökningar}
translate W FilterOperation {Hantering av aktuellt filter:}
translate W FilterAnd {AND (Restriktivt filter)}
translate W FilterOr {OR (Ackumulativt filter)}
translate W FilterIgnore {IGNORE (Använd ej filter)}
translate W SearchType {Söktyp:}
translate W SearchBoardExact {Exakt position (alla pjäser på samma rutor)}
translate W SearchBoardPawns {Bönder (samma material, alla bönder på samma rutor)}
translate W SearchBoardFiles {Filer (samma material, alla bönder på samma filer)}
translate W SearchBoardAny {Obestämt (samma material, bönder och pjäser på valfria rutor)}
translate W LookInVars {Sök i varianter}

# Material search:
translate W MaterialSearch {Materialsökning}
translate W Material {Material}
translate W Patterns {Ställningar}
translate W Zero {Inga/-en}
translate W Any {Flera}
translate W CurrentBoard {Aktuell ställning}
translate W CommonEndings {Vanliga slutspel}
translate W CommonPatterns {Vanliga ställningar}
translate W MaterialDiff {Skillnad i material}
translate W squares {fält}
translate W SameColor {Samma färg}
translate W OppColor {Motsatt färg}
translate W Either {Antingen eller}
translate W MoveNumberRange {Dragintervall}
translate W MatchForAtLeast {Träffa minst}
translate W HalfMoves {halvdrag}

# Game saving:
translate W Today {Idag}
translate W ClassifyGame {Klassificera parti}

# Setup position:
translate W EmptyBoard {Töm brädet}
translate W InitialBoard {Utgångsställning}
translate W SideToMove {Färg vid draget}
translate W MoveNumber {Antal drag}
translate W Castling {Rockad}
translate W EnPassentFile {En Passent fil}
translate W ClearFen {Rensa FEN}
translate W PasteFen {Klistra in FEN}

# Replace move dialog:
translate W ReplaceMove {Ersätt drag}
translate W AddNewVar {Lägg till ny variant}
translate W ReplaceMoveMessage {Det finns redan ett drag i denna ställning.

Du kan ersätta detta drag, och förlora samtliga följande, eller lägga till ditt drag som en ny variant.

(Om du stänger av "Fråga före ersätt drag" i Alternativ:Drag menyn slipper du denna fråga i framtiden.)}

# Make database read-only dialog:
translate W ReadOnlyDialog {Om du ger denna databas endast läsbar kan du inte göra några ändringar i den.
Inga partier kan sparas eller ersättas, och du kan inte ändra flaggor för raderbara partier.
Alla sorteringsinställningar eller ECO-klassificeringar kommer att vara temporära.

Du kan göra den skrivbar igen genom att helt enkelt stänga och öppna den igen.

Vill du verkligen ange att databasen endast ska vara läsbar?}

# Clear game dialog:
translate W ClearGameDialog {Detta parti har ändrats.

Vill du verkligen fortsätta och förlora ändringarna?
}

# Exit dialog:
translate W ExitDialog {Vill du verkligen avsluta Scid?}
translate W ExitUnsaved {De följande databaserna har osparade förändringar. Om du avslutar nu, kommer dessa förändringar att gå förlorade.} 

# Import window:
translate W PasteCurrentGame {Klistra in aktuellt parti}
translate W ImportHelp1 {Ange eller klistra in ett parti i PGN-format i området ovan.}
translate W ImportHelp2 {Eventuella felaktigheter kommer att anges här.}

# ECO Browser:
translate W ECOAllSections {alla ECO avdelningar}
translate W ECOSection {ECO avdelning}
translate W ECOSummary {Sammanfattning för}
translate W ECOFrequency {Underkodsfrekvens för}

# Opening Report:
translate W OprepTitle {Öppningsrapport}
translate W OprepReport {Rapport}
translate W OprepGenerated {Skapad av}
translate W OprepStatsHist {Statistik och historik}
translate W OprepStats {Statistik}
translate W OprepStatAll {Rapporterade partier}
translate W OprepStatBoth {Båda med ranking}
translate W OprepStatSince {Sedan}
translate W OprepOldest {De äldsta partierna}
translate W OprepNewest {De yngsta partierna}
translate W OprepPopular {Aktuell popularitet}
translate W OprepFreqAll {Frekvens totalt:   }
translate W OprepFreq1   {Under det senaste året: }
translate W OprepFreq5   {Under de 5 senaste åren: }
translate W OprepFreq10  {Under de 10 senaste åren: }
translate W OprepEvery {en gång var %u parti}
translate W OprepUp {ökat %u%s gentemot samtliga år}
translate W OprepDown {minskat %u%s gentemot samtlliga år}
translate W OprepSame {ingen förändring gentemot samtliga år}
translate W OprepMostFrequent {Spelas mest av}
translate W OprepRatingsPerf {Ranking och resultat}
translate W OprepAvgPerf {Genomsnittranking och resultat}
translate W OprepWRating {Vits ranking}
translate W OprepBRating {Svarts ranking}
translate W OprepWPerf {Vits resultat}
translate W OprepBPerf {Svarts resultat}
translate W OprepHighRating {Partierna med högst genomsnittranking}
translate W OprepTrends {Resultattrender}
translate W OprepResults {Längd och frekvens}
translate W OprepLength {Partiets längd}
translate W OprepFrequency {Frekvens}
translate W OprepWWins {Vita vinster: }
translate W OprepBWins {Svarta vinster: }
translate W OprepDraws {Remier:      }
translate W OprepWholeDB {hela databasen}
translate W OprepShortest {Kortaste vinster}
# translate W OprepShortWhite {De kortaste vita vinsterna}
# translate W OprepShortBlack {De kortaste svarta vinsterna}
translate W OprepMovesThemes {Drag och teman}
translate W OprepMoveOrders {Dragordning för att nå rapportställningen}
translate W OprepMoveOrdersOne \
  {Ställningen nåddes bara genom en dragordning:}
translate W OprepMoveOrdersAll \
  {Det fanns %u dragordningar som ledde fram denna ställning:}
translate W OprepMoveOrdersMany \
  {Det fanns %u dragordningar som ledde fram denna ställning. De %u vanligaste är:}
translate W OprepMovesFrom {Drag från rapportställningen}
translate W OprepThemes {Positionella teman}
translate W OprepThemeDescription {Antal teman vid drag %u}
translate W OprepThemeSameCastling {Rockad på samma flygel}
translate W OprepThemeOppCastling {Rockad på olika flyglar}
translate W OprepThemeNoCastling {Ingen har gjort rockad}
translate W OprepThemeKPawnStorm {Bondestorm på kungsflygeln}
translate W OprepThemeQueenswap {Dambyte}
translate W OprepThemeIQP {Isolerad dambonde}
translate W OprepThemeWP567 {Vita bonde på 5/6/7e raden}
translate W OprepThemeBP234 {Svart bonde på 2/3/4e raden}
translate W OprepThemeOpenCDE {Öppen c/d/e linje}
translate W OprepTheme1BishopPair {Endast den ena sidan har löparparet}
translate W OprepEndgames {Slutspel}
translate W OprepReportGames {Antal partier i rapporten}
translate W OprepAllGames    {Samtliga partier}
translate W OprepEndClass {Material i slutställningen}
translate W OprepTheoryTable {Teorisammanställning}
translate W OprepTableComment {Skapad från de %u högst rankade partierna.}
translate W OprepExtraMoves {Ytterligare antal drag i notförteckningen}
translate W OprepMaxGames {Maximalt antal partier i sammanställningen}

# Piece Tracker window:
translate W TrackerSelectSingle {Vänsterklicka för att välja denna pjäs.} 
translate W TrackerSelectPair {Vänsterklicka för att välja denna pjäs; använd höger musknapp för att också välja den relatede pjäsen.}
translate W TrackerSelectPawn {Vänsterklicka för att välja denna pjäs; använd höger musknapp för att välja alla 8 bönder.}
translate W TrackerStat {Statistik}
translate W TrackerGames {% partier med drag till rutan}
translate W TrackerTime {% tid på varje ruta}
translate W TrackerMoves {Drag}
translate W TrackerMovesStart {Ange vid vilket drag sökningen ska börja.}
translate W TrackerMovesStop {Ange vid vilket drag sökningen ska sluta.}

# Game selection dialogs:
translate W SelectAllGames {Alla partier i databasen}
translate W SelectFilterGames {Endast partierna i filtret}
translate W SelectTournamentGames {Endast partierna i den aktuella turneringen}
translate W SelectOlderGames {Endast äldre partier}

# Delete Twins window:
translate W TwinsNote {Partier måste minst ha samma spelare för att kunna identifieras som dubbletter samt uppfylla andra kriterier du kan ange nedan. När dubbletter hittas raderas det kortare partiet.
Tips: det bästa är att använda rättstavningen innan dubblettjämförelsen eftersom detta förbättrar möjligheten för upptäckt av dubbletter.}
translate W TwinsCriteria {Kriterium: Dubbletter måste ha...}
translate W TwinsWhich {Ange vilka partier som ska jämföras}
translate W TwinsColors {Samma färger?}
translate W TwinsEvent {Samma evenemang?}
translate W TwinsSite {Samma plats?}
translate W TwinsRound {Samma rond?}
translate W TwinsYear {Samma år?}
translate W TwinsMonth {Samma månad?}
translate W TwinsDay {Samma dag?}
translate W TwinsResult {Samma resultat?}
translate W TwinsECO {SammaECO kod?}
translate W TwinsMoves {Samma drag?}
translate W TwinsPlayers {Jämför spelarnas namn:}
translate W TwinsPlayersExact {Exakt kopia}
translate W TwinsPlayersPrefix {Endast de 4 första bokstäverna}
translate W TwinsWhen {När dubbletter raderas}
translate W TwinsSkipShort {Ignorera alla partier som är kortare än 5 drag?}
translate W TwinsUndelete {Återta alla partier först?}
translate W TwinsSetFilter {Filtrera alla raderade dubbletter?}
translate W TwinsComments {Spara alltid partier med kommentarer?}
translate W TwinsVars {Spara alltid partier med varianter?}
translate W TwinsDeleteWhich {Ange vilket parti som ska raderas:} 
translate W TwinsDeleteShorter {Det kortare pariet} 
translate W TwinsDeleteOlder {Partiet med lägst nummer} 
translate W TwinsDeleteNewer {Partiet med högst nummer} 
translate W TwinsDelete {Radera partier}

# Name editor window:
translate W NameEditType {Typ av namn att redigera}
translate W NameEditSelect {Partier att redigera}
translate W NameEditReplace {Ersätt}
translate W NameEditWith {med}
translate W NameEditMatches {Matchar: Tryck Ctrl+1 till Ctrl+9 för att välja}

# Classify window:
translate W Classify {Klassificera}
translate W ClassifyWhich {ECO-klassificera vilka partier}
translate W ClassifyAll {Alla partier (skriv över gamla ECO koder)}
translate W ClassifyYear {Alla partier spelade under det senaste året}
translate W ClassifyMonth {Alla partier spelade den senaste månaden}
translate W ClassifyNew {Endast partier som ännu ej klassificerats}
translate W ClassifyCodes {ECO koder som ska användas}
translate W ClassifyBasic {Enbart standardkoder ("B12", ...)}
translate W ClassifyExtended {Scid extensioner ("B12j", ...)}

# Compaction:
translate W NameFile {Namnfil}
translate W GameFile {Partifil}
translate W Names {Namn}
translate W Unused {Ej använd}
translate W SizeKb {Storlek (kb)}
translate W CurrentState {Aktuell status}
translate W AfterCompaction {Efter komprimering}
translate W CompactNames {Namn, komprimera namnfil}
translate W CompactGames {Partier, komprimera partifil}

# Sorting:
translate W SortCriteria {Kriterium}
translate W AddCriteria {Lägg till kriterium}
translate W CommonSorts {Normal sortering}
translate W Sort {Sortering}

# Exporting:
translate W AddToExistingFile {Lägg till partier till en existerande fil?}
translate W ExportComments {Exportera kommentarer?}
translate W ExportVariations {Exportera varianter?}
translate W IndentComments {Dra in kommentarer?}
translate W IndentVariations {Dra in varianter?}
translate W ExportColumnStyle {Kolumnstil (ett drag per rad)?}
translate W ExportSymbolStyle {Symbolbaserade kommentarer:}
translate W ExportStripMarks {Avlägsna koder för fält och pilar från kommentarerna?} 

# Goto game/move dialogs:
translate W LoadGameNumber {Ange partiets nummer:}
translate W GotoMoveNumber {Gå till drag nummer:}

# Copy games dialog:
translate W CopyGames {kopiera partier}
translate W CopyConfirm {
 Vill du verkligen kopiera
 de [thousands $nGamesToCopy] filtrerade partierna
 ur databasen "$fromName"
 till databasen "$targetName"?
}
translate W CopyErr {Kan ej kopiera partier}
translate W CopyErrSource {källdatabasen}
translate W CopyErrTarget {måldatabasen}
translate W CopyErrNoGames {har inga partier i filtret}
translate W CopyErrReadOnly {kan bara läsas}
translate W CopyErrNotOpen {är ej öppen}

# Colors:
translate W LightSquares {Ljusa fält}
translate W DarkSquares {Mörka fält}
translate W SelectedSquares {Valda fält}
translate W SuggestedSquares {Föreslagna fält}
translate W WhitePieces {Vita pjäser}
translate W BlackPieces {Svarta pjäser}
translate W WhiteBorder {Vit kantlinje}
translate W BlackBorder {Svart kantlinje}

# Novelty window:
translate W FindNovelty {Hitta nyhet}
translate W Novelty {Nyhet}
translate W NoveltyInterrupt {Nyhetssökningen avbröts}
translate W NoveltyNone {Inga nyheter hittades i detta parti}
translate W NoveltyHelp {
Scid kommer att försöka hitta det första draget som leder till en position som inte annars finns i denna databas eller i spelöppingsboken baserad på ECO.
}

# Upgrading databases:
translate W Upgrading {Uppdaterar}
translate W ConfirmOpenNew {
Denna databas är i ett gammal format (Scid 2) och kan inte öppnas i Scid 3, men en databas i det nya formatet (Scid 3) har redan skapats.

Vill du öppna den senare databasen istället?
}
translate W ConfirmUpgrade {
Denna databas är i ett gammal format (Scid 2). En databas i det nyare formatet måste skapas innan den kan användas i Scid 3.

Genom att uppdatera skapas en databas i det nya formatet med samma innehåll; uppdateringen ändrar ingenting i den gamla databasen.

Detta kan ta ett tag men behöver bara göras en gång. Om du tycker det tar alltför lång tid kan du avbryta processen.

Vill du uppdatera denna databas nu?
}

}


#
##
### Start Swedish tip set
##
#
set tips(W) {
  {
    Scid har över 30 <a Index>hjälpsidor</a>, och i de flesta fönster kan du
    genom att trycka <b>F1</b> få hjälp om det fönster du för tillfället har
    aktivt.
  }
  {
    Vissa fönster (t ex partiinformation och <a Switcher>databasväljaren</a>) 
    har en meny för höger musknapp. Prova att högerklicka i varje fönster så
    får du vilka som har det och vilka funktioner du kommer åt den vägen.
  }
  {
    Du kan ange drag på mer än ett sätt, så du kan välja vilket som passar dig
    bäst. Du kan använda musen (med eller utan dragförslag) eller tangentbordet
    (med eller utan autokomplettering). Läs hjälpsidan för 
    <a Moves>att ange drag</a> för mer information.
  }
  {
    Om du har databaser du ofta öppnar så kan du lägga till ett 
    <a Bookmarks>bokmärke</a> för varje databas. Du kommer då att kunna öppna 
    databaserna snabbare via bokmärkesmenyn.
  }
  {
    Du kan se alla drag i det aktuella partiet (inklusive varianter och kommentarer)
    genom att öppna <a PGN>PGN-fönstret</a>.
    Du navigerar igenom partiet i PGN-fönstret genom att klicka på valfritt drag med
    vänster musknapp. Genom att klicka på draget med mellan- eller högermusknapp så
    får du en förhandsvisning av just den ställningen.
  }
  {
    Du kan kopiera partier mellan databaserna i <a Switcher>databasväljaren</a> genom
    att dra-och-släppa dem mellan respektive databas.
  }
  {
    Scid kan öppna PGN filer, även de som är komprimerade med Gzip (dvs har en .gz filändelse). 
    PGN filer öppnas med enbart läsrättigheter, så om du vill redigera en PGN fil i Scid 
    måste du kopiera filen till en Scid databas med hjälp av <a Switcher>databasväljaren</a>.
  }
  {
    Om du ofta använder <a Tree>Trädfönstret</a> med stora databaser, är det värt att välja
    <b>Fyll cache fil</b> från Arkivmenyn i Trädfönstret. Detta innebär att trädstatistik för 
    många av de vanligare ställningarna sparas, vilket ger en snabbare trädåtkomst för databasen
    ifråga.
  }
  {
    <a Tree>Trädfönstret</a> kan visa alla drag från den aktuella ställningen. Men om också vill 
    se alla dragföljder som har lett till denna ställning kan du få fram det genom att skapa en
   <a OpReport>öppningsrapport</a>.
  }
  {
    Du kan vänster- eller högerklicka i en kolumn i <a GameList>partilistan</a> för att ändra 
    dess bredd.
  }
  {
    Med <a PInfo>spelarinformationen</a> aktuell (klicka på endera spelarens namn under brädet i 
    huvudfönstret för att få fram den) är det enkelt att <a Searches Filter>filtrera</a> fram partier
    av en särskild spelares enskilda resultat. Klicka bara på valfritt värde som har angivits med
    <red>röd text</red>.
  }
  {
    När du studerar öppningar kan det vara en poäng att markera valen <b>Bönder</b> eller <b>Filer</b> i 
    <a Searches Board>Sök aktuell position</a>. Genom dessa val kan du hitta andra öppningar som ger
    liknande bondestrukturer.
  }
  {
    Du kan högerklicka i partiinformationsdelen av huvudfönstret (under brädet) för att få fram en 
    kontextmeny. Du kan t ex göra så att Scid döljer nästa drag i ett parti, vilket kan vara användbart 
    om du vill träna genom att "gissa" nästa drag.
  }
  {
    Om du ofta <a Maintenance>underhåller</a> stora databaser kan du utföra flera underhållsuppgifter 
    vid samma tillfälle via <a Maintenance Cleaner>databasverktyget</a>.
  }
  {
    Om du har en stor databas där de flesta partierna har ett evenmangsdatum och du vill ha partierna i 
    datumordning bör du överväga att <a Sorting>sortera</a> den på evenemangsdatum i första hand och 
    evenmang i andra hand, istället för datum och evenemang, då detta kommer att hålla turneringspartierna
    från olika datum samman. Under förutsättning att alla partier har samma evenemangsdatum naturligtvis).
    Alternativt kan du se till att fälten evenemang, rond och datum är så enhetliga och korrekta som möjligt.
    (ms).
  }
  {
    Det kan vara en bra ide att <a Maintenance Spellcheck>stavningskontrollera</a> din databas innan du 
    <a Maintenance Twins>raderar dubbletter</a> då Scid har större möjlighet att hitta dubbletterna och 
    markera dessa för borttagning.
  }
  {
    <a Flags>Flaggor</a> är användbara för att markera upp partier med karaktäristika du vill söka på senare,
    såsom bondeställning, taktiska finesser, osv. Du kan söka på flaggor när du söker på fält i partihuvudet.
  }
  {
    Om du går igenom ett parti, och helt enkelt vill testa en ny variant utan att förändra partiet i sig, kan 
    du slå på Försöksläget (Trial mode) genom att trycka <b>Ctrl+space</b> eller från verktygsraden. Återgå till
    ursprungspartiet när du är klar.
  }
  {
    Om du vill hitta det mest betydelsefulla partiet (med högst rankade spelare) i en viss position kan du
    öppna <a Tree>Trädfönstret</a> och i denna öppna listan med de bästa partierna. I trädfönstret kan du till
    och med begränsa partierna till endast ett särskilt resultat.
  }
  {
    Ett bra sätt att studera en öppning är att i en stor databas slå på träningsläget i <a Tree>Trädfönstret</a>, 
    och sedan spela igenom databasen för att se vilka varianter som förekommer oftast.
  }
  {
    Om du har två databaser öppna, och vill ha ett variantträd att studera medan du går igenom ett parti
    i den andra databasen kan du <b>låsa</b> trädet i den databasen och sedan byta till den andra.
  }
  {
    <a Tmt>Turneringssökaren (tournament finder)</a> är inte bara användbar för att lokalisera en särskild 
    turnering. Du kan också använda den för att söka efter turneringar en specifik spelare nyligen deltagit 
    i, eller att bläddra genom turneringar som genomförts i ett visst land.
  }
  {
    Det finns ett antal vanliga ställningstyper definierade i <a Searches Material>Sök material/ställning</a>
    fönstret som du kan ha nytta av när du studerar öppningar och mittspel.
  }
  {
    När du söker på <a Searches Material>material eller ställning</a> kan det ofta vara fördelaktigt att begränsa
    sökningen till sådana partier där ställningen eller materialet förekommit i åtminstone några drag. Du slipper
    du få med träffar där situationen du söker uppkom helt tillfälligt.
  }
  {
    Om du har en viktig databas du inte vill radera av misstag kan du välja  <b>Enbart läsbar</b> från <b>Arkiv</b>
    menyn efter att du har öppnat den. Alternativt kan du sätta dess filrättigheter till enbart läsrättigheter.
  }
  {
    Om du använder XBoard eller WinBoard (eller något annat program som kan hantera FEN notation via urklippshanteraren)
    och vill kopiera den aktuella ställningen från ditt program är det snabbaste sättet att göra det så här:
    Välj <b>Copy Position</b> från <b>File</b> menyn i Xboard/Winboard, välj sedan <b>Klistra in utgångsställning</b>
    i Redigera menyn i Scid.
  }
  {
    I <a Searches Header>Sök i huvud</a>, är spelare-, evenemang-, plats-, och rondnamn okänsliga för stora eller små
    bokstäver och ger träffar varhelst de finns i ett namn. Om du vill kan du ange att du istället vill att sökningen <b>ska</b>
    ta kapitäler/gemener i beaktande. Genom att använda jokertecken inom citationstecken (där "?" = motsvarar obestämt
    enskilt tecken och "*" = noll eller flera tecken). Om du exempelvis anger "*BEL" (med citationstecken) i det platsfältet
    hittar du alla partier spelade i Belgien, men exkluderar de som spelats i Belgrad.
  }
  {
    Om du vill redigera ett drag i ett parti utan att förlora alla de drag som spelats efter detta kan du öppna
    <a Import>Importera ett parti i PGN-format</a> fönstret i Verktygsmenyn. Klicka där på <b>Klistra in aktuellt parti</b> 
    , redigera partiet och avsluta med <b>Importera</b>.
  }
  {
    Om du har en ECO klassificeringsfil laddad, kan du nå den mest esakt klassificerade ställningen för det aktuella partiet
    genom att välja <b>Identifiera öppning</b> i <b>Partier</b> menyn (genväg: Ctrl+Shift+D).
  }
  {
    När du vill se hur stor en fil är, eller vill se när den senast redigerades innan du öppnar den kan du använda
    <a Finder>file finder</a> (Arkiv - Sök filer).
  }
  {
    En <a Repertoire>repertoirefil</a> är ett utmärkt sätt att hålla koll på dina favoritöppningar, eller hitta partier där
    där de har spelats. När du väl har skapat en repertoirefil kan du genomsöka nya filer utifrån repertoirefilen, och titta 
    igenom alla partier med just dina öppningar.
  }
  {
    Genom att skapa en <a OpReport>Öppningsrapport</a> har du en utmärk möjlighet att lära dig en ny spelöppning. Du kan få
    information om resultat, hur remiaktig den är, vilka vanliga positionella teman som dyker upp, och mycket mer.
  }
  {
    Du kan kommentera den aktuella ställningen med de vanligaste symbolerna (!, !?, +=, etc) utan att behöva använda 
    <a Comment>kommentarseditorn<a>. Där du exempelvis vill ange ett bra drag skriver du "!" och trycker sedan ENTER
    så läggs "!" symbolen till draget. Se även hjälpsidan <a Moves>ange drag</a> för mer detaljerad information.
  }
  {
    Om du bläddrar igenom öppningarna i en databas i <a Tree>trädfönstret</a>, får du en användbar överblick över hur
    väl öppningen fungerar i sentida partier mellan högrankade spelare om du öppnar statistikfönstret (genväg: Ctrl+I).
  }
  {
    Du ändrar enkelt huvudfönstrets brädstorlek genom att hålla nere <b>Ctrl</b> och <b>Shift</b> tangenterna, samtidigt
    som du trycker höger- eller vänster piltangent.
  }
  {
    Efter genomförd <a Searches>sökning</a>, är det enkelt att navigera genom urvalet genom att hålla nere <b>Ctrl</b> 
    tangenten samtidigt som du trycker upp- eller nerpiltangenterna för att gå till föregående eller nästa parti i 
    <a Searches Filter>urvalet</a>.
  }
}
# end of swedish.tcl

