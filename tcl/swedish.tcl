# swedish.tcl:
# Text for menu names and status bar help messages in Swedish.
# Part of Scid (Shane's Chess Information Database).
# Contributed by Martin Skjöldebrand, martin@skjoldebrand.org

addLanguage W Swedish 1

proc setLanguage_W {} {

# File menu:
menuText W File "Arkiv" 0
menuText W FileNew "Ny..." 0 {Skapa en ny Scid databas}
menuText W FileOpen "Öppna..." 0 {Öppna en befintlig Scid databas}
menuText W FileClose "Stäng" 0 {Stäng den aktiva Scid databasen}
menuText W FileFinder "Sök filer" 4 {Öppna sökdialogen}
menuText W FileBookmarks "Bokmärken" 0 {Hantera bokmärken (kortkommando: Ctrl+B)}
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
  {Öppna/ stäng dubblettfönstret för att söka dubblettpartier}
menuText W FileMaintName "Stavningskontroll" 0 {Namnredigering och stavningskontroll}
menuText W FileMaintNameEditor "Redigera namn" 0 \
  {Redigera spelarnamn utifrån rättstavningsfilen}
menuText W FileMaintNamePlayer "Stavningskontrollera namn..." 22 \
  {Stavningskontrollera namn utifrån rättstavningsfilen}
menuText W FileMaintNameEvent "Stavningskontrollera evenemang..." 21 \
  {Stavningskontrollera evenemang utifrån rättstavningsfilen}
menuText W FileMaintNameSite "Stavningskontrollera platser..." 21 \
  {Stavningskontrollera platser utifrån rättstavningsfilen}
menuText W FileMaintNameRound "Stavningskontrollera ronder..." 21 \
  {Stavningskontrollera ronder utifrån rättstavningsfilen}
menuText W FileReadOnly "Enbart läsbar..." 8 \
  {Avlägsna temporärt redigeringsmöjligheterna till databasen}
menuText W FileSwitch "Byt databas" 0 \
  {Byt till en annan öppnad databas} 
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
menuText W EditStripBegin "Avlägsna tidigare drag" 1 \
  {Avlägsna dragen fram till den aktuella ställningen} 
menuText W EditStripEnd "Avlägsna resterande drag" 0 \
  {Avlägsna partiets resterande drag} 
menuText W EditReset "Töm Clipbase" 1 \
  {Tömmer den temporära databasen}
menuText W EditCopy "Kopiera partiet till Clipbase" 21 \
  {Kopierar det aktuella partiet till Clipbase}
menuText W EditPaste "Klistra in det senaste Clipbasepartiet" 8 \
  {Klistrar in det senaste tillagda i Clipbase i den aktiva databasen}
menuText W EditSetup "Skapa ställning..." 0 \
  {Skapa en utgångsställning för aktuellt parti}
menuText W EditCopyBoard "Kopiera ställning" 0 \
  {Kopiera den aktuella ställningen i FEN kod till urklippshanteraren} 
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
menuText W GameRandom "Ladda parti slumpmässigt" 14 \
  {Ladda ett av datorn slumpmässigt valt parti} 
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
menuText W WindowsPList "Spelarförteckning" 7 {Öppna/ stäng en förteckning över spelarna i den aktiva databasen} 
menuText W WindowsTmt "Turneringar" 0 {Lista turneringar}
menuText W WindowsSwitcher "Databasväxlaren" 0 \
  {Öppna/ stäng databasväxlaren}
menuText W WindowsMaint "Verktygsfönster" 0 \
  {Öppna/ stäng verktygsfönstret}
menuText W WindowsECO "ECO fönster" 0 {Öppna/ stäng ECO bläddraren}
menuText W WindowsRepertoire "Repetoareditor" 0 \
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
menuText W ToolsFilterGraph "Filterdiagram" 7 \
  {Öppna/ stäng filterdiagramfönstret} 
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
menuText W OptionsSize "Brädstorlek" 0 {Ã„ndra brädets storlek}
menuText W OptionsPieces "Pjäsutseende" 1 {Ã„ndra pjäsernas utseende} 
menuText W OptionsColors "Färger..." 0 {Ã„ndra brädets färger}
menuText W OptionsExport "Export" 0 {Ã„ndra exportalternativ}
menuText W OptionsFonts "Typsnitt" 0 {Ã„ndra typsnitt}
menuText W OptionsFontsRegular "Normal" 0 {Ã„ndra det normala typsnittet}
menuText W OptionsFontsMenu "Menu" 0 {Ã„ndra menytypsnittet}
menuText W OptionsFontsSmall "Liten" 0 {Ã„ndra det lilla typsnittet}
menuText W OptionsFontsFixed "Fixerad" 0 {Ã„ndra det fixerade typsnittet}
menuText W OptionsGInfo "Partiinformation" 0 {Alternativ för partiinformation}
menuText W OptionsLanguage "Språk" 0 {Välj språk}
menuText W OptionsMoves "Drag" 0 {Alternativ för dragangivelse}
menuText W OptionsMovesAsk "Fråga före ersätt drag" 0 \
  {Fråga innan du ersätter befintliga drag}
menuText W OptionsMovesAnimate "Animation time" 1 \
  {Ange tid mellan varje drag när dragen görs automatiskt}
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
menuText W OptionsRecent "Senast använda filer..." 16 \
  {Ã„ndra antalet senast använda filer som visas i Arkivmenyn} 
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
menuText W GInfoPhotos "Visa bilder" 5 ;
menuText W GInfoTBNothing "Slutspelsdatabaser: inget" 20
menuText W GInfoTBResult "Slutspelsdatabaser: endast resultat" 28
menuText W GInfoTBAll "Slutspelsdatabaser: resultat och bästa drag" 33
menuText W GInfoDelete "Återta/Radera detta parti" 0
menuText W GInfoMark "(Av-)Markera detta parti" 5

# Main window buttons:
helpMsg W .button.start {Gå till början av partiet  (kortkommando: Home)}
helpMsg W .button.end {Gå till slutet av partiet  (kortkommando: End)}
helpMsg W .button.back {Back ett drag (kortkommando: Vänsterpil)}
helpMsg W .button.forward {Gå fram ett drag  (kortkommando: Högerpil)}
helpMsg W .button.intoVar {Gå in i variant (kortkommando: v)}
helpMsg W .button.exitVar {Gå ur variant  (kortkommando: z)}
helpMsg W .button.flip {Rotera brädet  (kortkommando: .)}
helpMsg W .button.coords {Visa (inte) koordinater  (kortkommando: 0)}
helpMsg W .button.stm {Visa (inte) vilka sida som är vid draget}
helpMsg W .button.autoplay {Autospel  (kortkommando: Ctrl+Z)}

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
translate W ChangeOrient {Ã„ndra fönstrets orientering}
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
translate W AverageRating {Medelranking} 
translate W Event {Evenemang}
translate W Site {Plats}
translate W Country {Land}
translate W IgnoreColors {Ignorera färger}
translate W Date {Datum}
translate W EventDate {Evenemangsdatum}
translate W Decade {Decenium}
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

# Standard error messages:
translate W ErrNotOpen {Databasen är inte öppen.}
translate W ErrReadOnly {Databasen är skrivskyddad. Du kan inte ändra den.}
translate W ErrSearchInterrupted {Söknigen avbröts; resultatet är inte fullständigt.}

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
translate W PInfoEditRatings {Redigera ranking} 

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
translate W WinningMoves {Vinstdrag} 
translate W DrawingMoves {Remidrag} 
translate W LosingMoves {Förlustdrag} 
translate W UnknownMoves {Okänt resultat} 

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
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate W TreeTitleRow \
  { Drag      ECO     Frekvens      Res.    Elo~  Nivå  År~   %Remi} 
translate W TreeElapsedTime {Tid} 
translate W TreeFoundInCache {  (Hittades i cachen)} 
translate W TreeTotal {TOTALT:     } 

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

# Player finder:
menuText W PListFile "Fil" 0
menuText W PListFileUpdate "Uppdatera" 0
menuText W PListFileClose "Stäng spelarförteckningen" 1 
menuText W PListSort "Sortera" 0
menuText W PListSortName "Namn" 0
menuText W PListSortElo "Elo" 0
menuText W PListSortGames "Partier" 0
menuText W PListSortOldest "Ã„ldst" 0 
menuText W PListSortNewest "Yngst" 0

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
translate W GraphFilterTitle "Filterdiagram: antal per 1000 partier"

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
translate W LowPriority {Kör som lågprioriterad process} 

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
translate W PgnWindowTitle {PGN version av partiet} 

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
translate W Category {Kategori} 

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

# Repetoar editor:
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
menuText W RepSearchAll "Hela öppningsrepetoaren..." 0
menuText W RepSearchDisplayed "Endast visade varianter..." 0
menuText W RepHelp "Hjälp" 0
menuText W RepHelpRep "Hjälp för spelöppningsrepetoar" 0
menuText W RepHelpIndex "Hjälpindex" 0
translate W RepSearch "Sök i spelöppningsrepetoar"
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
translate W Description {Beskrivning} 
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
translate W Events {Evenemang}
translate W Sites {Platser}
translate W Rounds {Ronder}
translate W DatabaseOps {Databashantering}
translate W ReclassifyGames {ECO-klassificera partier}
translate W CompactDatabase {Komprimera databasen}
translate W SortDatabase {Sortera databasen}
translate W AddEloRatings {Lägg till Elo ranking}
translate W AutoloadGame {Ladda partinummer automatiskt}
translate W StripTags {Avlägsna PGN taggar}
translate W StripTag {Avlägsna taggar}
translate W Cleaner {Snygga till databasen}
translate W CleanerHelp {
Databasstädaren i Scid genomför allt det underhåll av databasen du kan välja nedan på den aktiva databasen.

De nuvarande inställningarna i ECO-klassificering och Radera dubbletter kommer att appliceras om du väljer dessa åtgärder.
}
translate W CleanerConfirm {
När du väl startat Databasstädaren kan du inte avbryta den!

På en stor databas kan detta ta ett bra tag. Tidsåtgången beror på valda åtgärder och deras inställningar.

Ã„r du säker på att du vill påbörja databasunderhållet nu?
}

# Comment editor:
translate W AnnotationSymbols  {Symboler:}
translate W Comment {Kommentar:}
translate W InsertMark {Infoga symbol} 

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
translate W EnPassantFile {En Passant fil}
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

# Recent files options:
translate W RecentFilesMenu {Antal senast öppnade filer i Arkivmenyn}
translate W RecentFilesExtra {Antal senast öppnade filer i extra undermeny}

}


############################################################
#
# Swedish tips section:

set tips(W) {
  {
    Scid har över 30 <a Index>hjälpsidor</a>, och i de flesta fönster kan du
    genom att trycka <b>F1</b> få hjälp om det fönster du för tillfället har
    aktivt.
  }
  {
    Vissa fönster (t ex partiinformation och <a Switcher>databasväljaren</a>) 
    har en meny för höger musknapp. Prova att högerklicka i varje fönster så
    ser du vilka som har det och vilka funktioner du kommer åt den vägen.
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
    Om du har en stor databas där de flesta partierna har ett evenemangsdatum och du vill ha partierna i 
    datumordning bör du överväga att <a Sorting>sortera</a> den på evenemangsdatum i första hand och 
    evenemang i andra hand, istället för datum och evenemang, då detta kommer att hålla turneringspartierna
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
    du slå på Försöksläget (Trial mode) genom att trycka <b>Ctrl+Mellanslag</b> eller från verktygsraden. Återgå till
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
    ta versaler/gemener i beaktande. Genom att använda jokertecken inom citationstecken (där "?" = motsvarar obestämt
    enskilt tecken och "*" = noll eller flera tecken). Om du exempelvis anger "*BEL" (med citationstecken) i det platsfältet
    hittar du alla partier spelade i Belgien, men exkluderar de som spelats i Belgrad.
  }
  {
    Om du vill redigera ett drag i ett parti utan att förlora alla de drag som spelats efter detta kan du öppna
    <a Import>Importera ett parti i PGN-format</a> fönstret i Verktygsmenyn. Klicka där på <b>Klistra in aktuellt parti</b> 
    , redigera partiet och avsluta med <b>Importera</b>.
  }
  {
    Om du har en ECO klassificeringsfil laddad, kan du nå den mest exakt klassificerade ställningen för det aktuella partiet
    genom att välja <b>Identifiera öppning</b> i <b>Partier</b> menyn (kortkommando: Ctrl+Shift+D).
  }
  {
    När du vill se hur stor en fil är, eller vill se när den senast redigerades innan du öppnar den kan du använda
    <a Finder>file finder</a> (Arkiv - Sök filer).
  }
  {
    En <a repetoire>repetoarfil</a> är ett utmärkt sätt att hålla koll på dina favoritöppningar, eller hitta partier där
    där de har spelats. När du väl har skapat en repetoarfil kan du genomsöka nya filer utifrån repetoarfilen, och titta 
    igenom alla partier med just dina öppningar.
  }
  {
    Genom att skapa en <a OpReport>Öppningsrapport</a> har du en utmärkt möjlighet att lära dig en ny spelöppning. Du kan få
    information om resultat, hur remiaktig den är, vilka vanliga positionella teman som dyker upp, och mycket mer.
  }
  {
    Du kan kommentera den aktuella ställningen med de vanligaste symbolerna (!, !?, +=, etc) utan att behöva använda 
    <a Comment>kommentarseditorn<a>. Där du exempelvis vill ange ett bra drag skriver du "!" och trycker sedan ENTER
    så läggs "!" symbolen till draget. Se även hjälpsidan <a Moves>ange drag</a> för mer detaljerad information.
  }
  {
    Om du bläddrar igenom öppningarna i en databas i <a Tree>trädfönstret</a>, får du en användbar överblick över hur
    väl öppningen fungerar i sentida partier mellan högrankade spelare om du öppnar statistikfönstret (kortkommando: Ctrl+I).
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
{
  Du kan relativt enkelt rita pilar och färga rutor till dina kommentarer. Öppna <b>Kommentarseditorn</b>, klicka på <b>Infoga symbol</b> och välj önskad färg. Om du nu klicka på en första ruta, och därefter klickar på en andra så dras en pil i önskad färg från den första till den andra rutan. Klickar du bara på en ruta, blir den färgad.
  }
}



############################################################
#
# Swedish help pages:

# Basic help pages completed, no links no other sections.

##########
# Index
#
set helpTitle(W,Index) "Innehållsförteckning"
set helpText(W,Index) {<h1>Hjälp med Scid: Innehållsförteckning</h1>

<h3>Komma igång och allmänt om Scid</h3>
<h5>Under översättning</h5>
<p>Följande texter och dess länkar är under översättning. Detta påbörjades i Scid 3.4 beta 1. 
Detta betyder att menyerna är översatta. Rubriktexterna bör kunna vara översatta till Scid 3.4 men alla länkar
från rubriktexterna är förmodligen inte det. /Martin S.</p>

<ul>
<li><a Guide><b>Komma igång</b> med Scid</a> <red>(Läs detta först)</red></li>
<li><a Hints><b>Tips</b> om hur du får ut mer av Scid</a></li>
<li><a MainWindow><b>Huvudfönstret</b></a></li>
<li><a Menus><b>Menyerna</b></a> <red>(uppdaterad!)</red></li>
<li><a Moves>Ange <b>drag</b></a> <red>(uppdaterad!)</red></li>
<li><a Searches><b>Söka</b> i Scid</a></li>
<li><a Clipbase>Att använda <b>Clipbase (urklippsdatabasen)</b></a></li>
<li><a Annotating><b>Kommentera partier</b></a> <red>(Ny!)</red></li>
</ul>


<h3>Other Scid windows</h3>
<h5>Ej översatta</h5>
<p>Översättningen av följande hjälpavsnitt har ännu (2002 07 27) inte påbörjats. Detta betyder att menyerna är på engelska, likaså samtliga 
rubriktexter. Däremot <b>kan det hända</b> att vissa länktexter har översatts i samband med översättningen av föregående hjälpavsnitt. 
/Martin S.</p>

<ul>
<li><a Analysis><b>Analysis</b> window</a></li>
<li><a Comment><b>Comment editor</b> window</a></li>
<li><a Crosstable><b>Crosstable</b> window</a></li>
<li><a Switcher><b>Database Switcher</b> window</a></li>
<li><a Email><b>Email</b> chess manager window</a></li>
<li><a Finder><b>File Finder</b> window</a></li>
<li><a GameList><b>Game List</b> window</a></li>
<li><a Import><b>Import game</b> window</a></li>
<li><a OpReport><b>Opening Report</b> window</a></li>
<li><a PGN><b>PGN</b> (game text) window</a></li>
<li><a PTracker><b>Piece Tracker</b></a></li>
<li><a PInfo><b>Player Info</b> window</a></li>
<li><a Repetoire><b>Repetoareditor</b> window</a></li>
<li><a Tmt><b>Tournament Finder</b> window</a></li>
<li><a Tree><b>Tree</b> window</a></li>
<li><a Graphs><b>Graph</b> windows</a></li>
<li><a TB>Using <b>Tablebases</b> in Scid</a></li>
</ul>

<h3>Other utilities and information</h3>
<ul>
<li><a Bookmarks><b>Bookmarks</b></a></li>
<li><a Cmdline>Command-line options</a></li>
<li><a Compact><b>Compacting</b> a database</a></li>
<li><a Maintenance><b>Database maintenance</b> tools</a></li>
<li><a ECO><b>ECO</b> openings classification</a></li>
<li><a EPD><b>EPD</b> files</a></li>
<li><a Export><b>Exporting</b> games to text files</a> <red>(updated!)</red></li>
<li><a Flags>Game <b>Flags</b></a></li>
<li><a LaTeX>Using <b>LaTeX</b> with Scid</a></li>
<li><a Options><b>Options</b> and preferences</a></li>
<li><a Sorting><b>Sorting</b> a database</a></li>
<li><a Pgnscid><b>Pgnscid</b>: converting PGN files</a></li>
<li><a NAGs>Standard <b>NAG</b> annotation values</a></li>
<li><a Formats>Scid database <b>file formats</b></a></li>
<li><a Author>Contact information</a></li>
</ul>

<p><footer>(Uppdaterad: Scid 3.4, Juli 2002)</footer></p>
}
### Slut index


####################
### Quick Guide help:

set helpTitle(W,Guide) "Komma igång med Scid"
set helpText(W,Guide) {<h1>Komma igång med Scid</h1>
<p>
Scid är en schackdatabashanterare som du kan använda till att bläddra och <a Searches>söka</a> (enligt kriterier du ställer upp) igenom 
databaser med schackpartier. Du kan också redigera de partier du vill.
</p>
<p>
Scid använder sitt eget <a Formats>database format</a> baserat på tre filer. Det är mycket kompakt och snabbt, men kan konvertera såväl 
till som från PGN (Portable Game Notation) standarden om man så önskar. Scids <a PGN>PGN fönster</a> visar texten till det aktuella
partiet i PGN format.
</p>
<p>
Du kan använda Scid till att lägga till och radera partier i en databas genom att använda såväl mus som tangentbordet för att skriva in
drag. Se vidare <a Moves>att skriva in drag</a> för en noggrannare beskrivning.
</p>
<p>
Du kan också använda Scid för att hantera <a PGN>PGN</a> filer genom att klistra in PGN-text i Scids <a Import>Importfönster</a> 
eller genom att öppna en PGN-fil i Scid. PGN-filer kan dock inte redigeras av Scid (de öppnas skrivskyddade). Eftersom PGN-filer
använder mer minne och laddas långsammare rekommenderas du att konvertera stora PGN-filer till en Scid databas med verktyget
<a Pgnscid>pgnscid</a>.
</p>
<p>
Scids <a MainWindow>huvudfönster</a> (den med schackbrädet) visar det aktuella partiet och databasen i detalj. Du kan när som helst öppna 
upp till fyra databaser (fem om du räknar med urklippsdatabasen <a Clipbase>clipbase</a>). Var och ett av dessa kommer att ha sitt eget aktuella
parti. (Partier med ID-numret 0 visar att detta är ett parti som ännu inte ingår i den aktuella databasen). Du bläddrar mellan de öppnade databaserna
via <a Menus File>Filmenyn</a>.
</p>
<p>
Läs gärna övriga hjälpsidor i <a Index>Innehållsförteckningen</a> för mer information.
</p>
<p>
Läs <a Author>kontaktinformationssidan</a> om du vill komma i kontakt med skaparen av Scid. För frågor om den svenska översättningen ska du
<b>inte</b> kontakta upphovsmannen utan istället <a Translator>översättaren</a>.
</p>

<p><footer>(Updated: Scid 3.1, December 2001)</footer></p>
}


set helpTitle(W,Author) "Kontaktinformation"
set helpText(W,Author) {<h1>Kontaktinformation</h1>
<p>
Scids webbsajt finns på: <br>
<b><url http://scid.sourceforge.net/>http://scid.sourceforge.net/</url></b>
</p>
<p>
Där kan du hämta den senaste versionen av Scid och andra de filerna till Scid som du kan ha behov av.
</p>
<p>
Skicka gärna kommentarer, frågor, förslag eller buggrapporter till Scids skapare, Shane Hudson, på adressen:<br>
<b>sgh@users.sourceforge.net</b>
</p>

<p>Den svenska översättningen av Scid har gjorts av Martin Skjöldebrand. Synpunkter på översättningen ska <b>inte</b>
skickas till Shane. Däremot får du gärna skicka kommentarer, frågor och förslag till rättningar till översättaren på adressen:<br>
<b>martin@skjoldebrand.org</b>
</p>
}

####################
### Hints page:
set helpTitle(W,Hints) "Scid Tips"
set helpText(W,Hints) {<h1>Scid Tips</h1>
<p>
Denna sida innehåller användbara tips i form av frågor och svar. Genom att läsa igenom denna sida, kan du senare komma att
använda Scid bättre. Om du nyligen börjat använda Scid, så läs till en början <a Guide>Kom igång</a>.
Det mesta av informationen på denna sida finns refererad mer utförligt på andra sidor i hjälpen. Du finner dem i <a Index>innehållsförteckningen</a>.
Om har något du tips du tycker passar bra för denna sida, så skicka den till <a Author>upphovsmannen</a>.
</p>

<h4>Kan Scid ladda en databas när den startas?</h4>
<p>
Ja, du kan ange databaser, PGN filer eller <a EPD>EPD filer</a>
på kommandoraden som t ex;
<ul>
<li> <b>scid  mybase  games.pgn.gz</b> </li>
</ul>
som laddar Scid databasen <b>mybase</b> och dessutom laddar den Gzip-komprimerade PGN filen <b>games.pgn.gz</b>.
</p>

<h4>Finns det enklare sätt att ändra storleken på brädet än via Alternativmenyn?</h4>
<p>
Ja, du kan använda kortkommandoen <b>Ctrl+Shift+VänsterPil</b> och <b>Ctrl+Shift+HögerPil</b> för att förminska eller 
förtora brädets storlek.
</p>

<h4>Jag brukar träna genom att spela igenom partier, så jag vill inte att Scid visar nästa drag i partiinformationen
nedanför brädet. Kan jag dölja detta på något sätt?</h4>
<p>
Du kan dölja nästa drag genom att högerklicka partiinformationen och välja  <b>Dölj nästa drag</b> i menyn som öppnas.
</p>

<h4>Var finner jag ECO-koden för öppningen på brädet?</h4>
<p>
ECO-koden visas på sista raden i partiinformationen nedanför brädet i  <a MainWindow>huvudfönstret</a>,
om du har laddat ECO klassificeringsfilen (<b>scid.eco</b>). <br>
Hjälpsidan för <a ECO>ECO koder</a> förklarar hur man laddar ECO klassificeringsfilen och ställer in programmet så att
den laddas varje gång man startar Scid.
</p>

<h4>Jag håller på och matar in ett parti och befinner mig nu vid drag 30. Nu ser jag att drag 10 blev fel. Hur kan jag ändra
detta utan att göra om alltihop?</h4>
<p>
Du kan använda <a Import>Importfönstret</a>; se vidare <a Moves Mistakes>mata in drag</a> för mer information.
</p>

<h4>Hur kopierar jag partier från en databas till en annan?</h4>
<p>
Använd <a Switcher>databasväxlaren</a>. Drag från källdatabasen till måldatabasen så kopierar du allt i källdatabasen till
måldatabasen. Genom att använda <a Searches Filter>filter</a> kan du begränsa det du kopierar från den ena databasen till den andra.
</p>

<h4>Varje gång jag anger ett drag som redan finns får jag frågan "Ersätt drag?". Hur undviker jag detta?</h4>
<p>
Du kan antingen stänga av <b>Fråga före ersätt drag</b> valmöjligheten i menyn <menu>Altervativ: Drag</menu</menu>; eller
tänk på att göra ändringarna genom att ta tillbaka dragen genom att högerklicka. Det senare alternativet raderar drag helt ur
partiet.
</p>

<h4>Hur ändrar kolumnbredden i partilistan?</h4>
<p>
Höger- eller vänsterklicka på kolumntiteln för den kolumn du vill ändra.
</p>

<h4>Hur använder jag trädfönstret för ett filtrerade partier - till skillnad mot att använda den för hela databasen?</h4>
<p>
Använd <a Clipbase>urklippsdatabasen (Clipbase)</a>. Filtera databasen att visa endast de partier du vill använda i trädet, 
kopiera sedan partierna till urklippsdatabasen (Clipbase) via <a Switcher>databasväxlaren</a>. Öppna därefter trädfönstret
med den senare databasen som aktiv.
</p>

<h4>Trädet är långsamt när jag jobbar med stora databaser. Går det att snabba upp den?</h4>
<p>
Spara trädcachen ofta så sparar du resultaten för framtida användning. Se vidare cache-sektionen i hjälpen för 
<a Tree>trädet</a> för mer detaljerad information.
</p>

<h4>Kan jag redigera PGN texten för ett parti direkt?</h4>
<p>
Du kan inte använda <a PGN>PGN</a> fönstret till att redigera det aktuella partiet, däremot kan du använda 
<a Import>Importfönstret</a>. Öppna fönstret (kortkommando: <b>Ctrl+Shift+I</b>) och klicka på klistra in aktuellt parti
<b>Paste current game</b>, redigera partiet och klicka sedan på <b>Importera</b>.
</p>

<h4>I min databas finns många spelarnamn som är felstavade. Hur rättar jag allt detta?</h4>
<p>
Du kan rätta enstaka namn, eller göra en stavningskontroll för hela databasen via menyvalen i <menu>Arkiv: Databasverktyg</menu>.
Se vidare hjälpen för <a Maintenance Editing>databasunderhåll</a>.
</p>

<h4>Jag har två databaser öppna: den ena innehåller mina egna partier, den andra är en massor med stormästarpartier.
Hur jämför jag ett av mina egna partier mot partierna i databasen med stormästarpartier?</h4>
<p>
Öppna <a Tree>trädfönstret</a> i databasen med stormästarpartier och välj <term>Lås</term> för att låsa trädet i den databasen. 
När du sedan byter till den andra databasen kommer trädet att fortsätta visa informationen från databasen med stormästarpartier.
</p>

<p><footer>(Uppdaterad: Scid 2.6,  augusti 2001)</footer></p>
}


#################
# Authors, translators
#

set helpTitle(W,Translator) "Den svenska översättningen"
set helpText(W,Translator) {<h1>Den svenska översättningen</h1>
<p>
Scids webbsajt finns på: <br>
<b><url http://scid.sourceforge.net/>http://scid.sourceforge.net/</url></b>. Där kan du hämta den senaste versionen av Scid och 
andra de filerna till programmet som du kan ha behov av. Där finns också den senaste versionen av den svenska språkfilen.
</p>
<p>Den svenska översättningen av Scid har gjorts av Martin Skjöldebrand. Skicka gärna kommentarer, frågor och förslag till rättningar
till översättaren på adressen:<br>
<b>martin@skjoldebrand.org</b>
</p>
}

####################
### Main window help:

set helpTitle(W,MainWindow) "Huvudfönstret"
set helpText(W,MainWindow) {<h1>Scid: huvudfönstret</h1>
<p>
På brädet i huvudfönstret visas den aktuella ställningen i det aktiva partiet. Du får också information om partiet och den
aktiva databasen. För ytterligare information om <a Menus>menyerna</a> och olika sätt att <a Moves>ange drag</a> hänvisas till
andra hjälpsidor.
</p>

<h3>Att navigera i partier</h3>
<p>
Navigationsknapparna vid brädet har följande funktioner (från vänster till höger):
<ul>
<li> <button tb_start> Gå till utgångsställningen. </li>
<li> <button tb_prev> Tillbaka ett drag. </li>
<li> <button tb_next> Framåt ett drag. </li>
<li> <button tb_end> Gå till slutställningen. </li>
<li> <button tb_invar> Gå in i varianten. </li>
<li> <button tb_outvar> Gå ur varianten. </li>
<li> <button tb_addvar> Lägg till ny variant. </li>
<li> <button autoplay_off> Start/stopp för autospelsläge (se nedan). </li>
<li> <button tb_trial> Start/stopp för <a Moves Trial>försöksläge</a>. </li>
<li> <button tb_flip> Rotera brädet 180 grader. </li>
<li> <button tb_coords> Visa/dölj koordinater. </li>
</ul>

<h4><name Autoplay>Autospelsläge</name></h4>
<p>
I autospelsläge gör Scid automatiskt båda spelarnas drag i det aktuella partiet. Fördröjningen mellan varje drag kan anges i
menyn <menu>Alternativ: Drag</menu> och sparas när du sparar ändringarna av inställningsmöjligheterna.
</p>
<p>
Kortkommandot <b>Ctrl+Z</b> startar eller avbryter autospelsläget. Du kan också gå ur autospelsläge genom att trycka
 <b>Esc</b> tangenten.
</p>
<p>
Om du startar autospelsläge när <a Analysis>analysfönstret</a> är öppet <term>kommenteras</term> partiet: ställningsbedömningen 
och analysen av varje ställning läggs till som en ny variant vid varje drag.
Se hjälpen för <a Analysis>analysfönstret</a> för mer information.
</p>

<h3>Partiinformation</h3>
<p>
Nedanför brädet visas information om det aktuella partiet. Denna del av huvudskärmen kallas <term>partiinformationsområdet</term>.
På de tre första raderna ges grundinformation såsom spelarnas namn, resultat, datum och spelplats. Den fjärde raden aktuell
ställning och nästa drag.
</p>
<p>
Rad fem visar <a ECO>ECO</a> (Encyclopedia of Chess
Openings) koden för den aktuella ställningen, om ställningen ingår i den ECO-fil som används.
</p>
<p>
När man högerklickar på partiinformationsområdet visas en meny med inställningsmöjligheter som är relevanta just för denna del av
programmet. Du kan t ex välja att dölja nästa drag (användbart om du tränar genom att "gissa" nästa drag i  partiet) eller radera
/återta det aktuella partiet. Kortkommandot för denna funktion är funktionsknappen F9.
</p>

<h4>Slutspelsdatabaser</h4>
<p>
Partiinformationsområdet visar och resultaten från slutspelsdatabaserna om du har några installerade och om ställningen återfinns 
i dessa. Se hjälpsidan för <a TB>slutspelsdatabaser</a> för mer information.
</p>

<h3>Statusraden</h3>
<p>
Statusraden (längst ner i huvudfönstret) visar information om den aktuella databasen.
Det första fältet visar partiets status: <b>XX</b> betyder att det har förändrats men ännu inte sparats, medan <b>--</b> 
betyder att partiet inte har ändrats, <b>%%</b>, slutligen, betyder att databasen är skrivskyddad (det går inte att ändra i partiet.).
</p>
<p>
Om du vill, kan du öppna databasen skrivskyddad. Ã„ndra rättigheterna till scid-filerna (eller enbart indexfilen) genom att i UNIX(-lika)
system ge kommandot:
<b>chmod a-w myfile.si3</b>
vid kommandoraden.
</p>
<p>
Statusraden visar också hur många partiet som ingår i det aktiva <a Searches Filter>filtret</a>.
</p>

<p><footer>(Uppdaterad: Scid 3.1, december 2001)</footer></p>
}

####################
### Menus help screen:

set helpTitle(W,Menus) "Menyerna"
set helpText(W,Menus) {<h1>Menyerna</h1>

<h3><name File>Arkiv</name></h3>
<ul>
<li><menu>Ny</menu>: Skapar en ny, tom, Scid databas.</li>
<li><menu>Öppna</menu>: Öppnar en befintlig Scid databas.</li>
<li><menu>Stäng</menu>: Stänger den aktiva Scid databasen.</li>
<li><menu>Sök filer</menu>: Öppna <a Finder>sökdialogen</a> för filer.</li>
<li><menu>Bokmärken</menu>: Hanterar <a Bookmarks>bokmärken</a>.</li>
	<ul>
	<li><menu>Nytt bokmärke</menu>: Markerar den aktiva ställningen i partiet som ett bokmärke.</li>
	<li><menu>Spara bokmärke</menu>: Sparar bokmärket för den aktiva ställningen i partiet.</li>
	<li><menu>Redigera bokmärken</menu>: Redigerar dina bokmärken.</li>
	<li><menu>Visa bokmärken som lista</menu>: Visar bokmärkena som lista, inte undermenyer.</li>
	<li><menu>Visa bokmärken i undermenyer</menu>: Visar bokmärkena som undermenyer, inte lista.</li>
	</ul>
<li><menu>Databasverktyg</menu>: <a Maintenance>Underhåll</a> databasen.</li>
	<ul>
	<li><menu>Verktygsfönster</menu>: Öppna/ stäng verktygsfönstret.</li>
	<li><menu>Komprimera databasen</menu>: Komprimera databasen, avlägsna raderade partier och oanvända namn.</li>
	<li><menu>Klassificera partier enligt ECO</menu>: Klassificera alla partier enligt ECO-systemet.</li>
	<li><menu>Sortera databasen</menu>: Sortera partierna i den aktiva databasen.</li>
  	<li><menu>Radera dubbletter</menu>: Raderar <a Maintenance Twins>dubblettpartier</a> i databasen.</li>
	<li><menu>Sök dubbletter"</menu>: Öppna/ stäng dubblettfönstret för att söka dubblettpartier.</li>
	<li><menu>Stavningskontroll</menu>: Namnredigering och stavningskontroll.</li>
		<ul>
		<li><menu>Redigera namn</menu>: Redigerar spelarnamn utifrån rättstavningsfilen.</li>
		<li><menu>Stavningskontrollera namn</menu>: Stavningskontrollera namn utifrån rättstavningsfilen.</li>
		<li><menu>Stavningskontrollera evenemang</menu>: Stavningskontrollera evenemang utifrån rättstavningsfilen.</li>
		<li><menu>Stavningskontrollera platser</menu>: Stavningskontrollera platser utifrån rättstavningsfilen.</li>
		<li><menu>Stavningskontrollera ronder</menu>: Stavningskontrollera ronder utifrån rättstavningsfilen.</li>
  		</ul>
	</ul>	
<li><menu>Skrivskyddad</menu>: Avlägsna temporärt redigeringsmöjligheterna till databasen.</li>
<li><menu>Byt databas</menu>: Byt till en annan öppnad databas.</li>
	<ul>
		<li><menu>Base 1/2/3/4/5</menu>: Här byter du mellan de olika databaserna i databasväxlarna, inklusive <a Clipbase>urklippsdatabasen</a>.</li>
	</ul>
<li><menu>Avsluta</menu>: Avslutar Scid. </li>
</ul>

<h3>Redigera</h3>
<ul>
<li><menu>Lägg till variant</menu>: Skapar en variant vid denna ställning. Antingen för nästa drag, eller för föregående drag om det är det första draget.</li>
<li><menu>Radera variant</menu>: Visar en undermeny med de raderbara varianterna.</li>
<li><menu>Skapa huvudvariant</menu>: Upphöjer en av varianterna till huvudvariant.</li>
<li><menu>Skapa nytt textdrag</menu>: Gör en av varianterna till nytt partidrag.</li>
<li><menu>Testa en idÃ©</menu>: Slår på <a Moves Trial>testläge</a> för att tillfälligt testa en idÃ©. Förändrar inte partiet.</li>
<li><menu>Ta bort</menu>: Avlägsna kommentarer eller varianter ur partiet.</li>
<br>
<li><menu>Töm Clipbase</menu>: Tömmer den urklippsdatabasen <a Clipbase>clipbase</a> på partier.</li>
<li><menu>Kopiera partiet till Clipbase</menu>: Kopierar det aktuella partiet till urklippsdatabasen <a Clipbase>clipbase</a>.</li>
<li><menu>Klistra in det senaste Clipbasepartiet</menu>: Klistrar in det aktiva partiet i <a Clipbase>Clipbase</a> i den aktiva databasen och gör det aktivt.</li>
<br>
<li><menu>Skapa ställning</menu>: Skapa en utgångsställning för aktuellt parti.</li>
<li><menu>Kopiera ställning</menu>: Kopiera den aktuella ställningen i FEN kod till urklippshanteraren.</li>
<li><menu>Klistra in utgångsställning</menu>: Klistra in ställningen från aktuellt parti i den temporära databasen.</li>
</ul>

<h3>Partier</h3>
<ul>
<li><menu>Nytt parti</menu>: Återställ brädet inför ett nytt parti (raderar alla ändringar).</li>
<li><menu>Ladda första/föregående/nästa/sista partiet</menu>: Dessa laddar respektive parti i <a Searches Filter>sökfiltret</a>.</li>
<li><menu>Ladda om partiet</menu>: Laddar om aktuellt parti och slänger alla gjorda ändringar..</li>
<li><menu>Ladda parti slumpmässigt</menu>:  Ladda ett av datorn slumpmässigt valt parti.</li> 
<li><menu>Ladda parti nummer...</menu>: Ladda ett parti genom att ange dess nummer.</li>
<br>
<li><menu>Spara: Ersätt parti...</menu>: Spara partiet och ersätt tidigare version.</li>
<li><menu>Spara: Nytt parti...</menu>: Spara det aktuella partiet, lägg till det till databasen.</li>
<br>
<li><menu>Identifiera öppningen</menu>: Gå till den mest detaljerade ställningen i ECO boken.</li>
<li><menu>Gå till drag nummer...</menu>: Gå till ett specifikt drag i partiet.</li>
<li><menu>Hitta nyhet...</menu>: Hitta det första draget i partiet som inte spelats tidigare.</li>
</ul>

<h3>Sök</h3>
<ul>
<li><menu>Återställ sökfilter</menu>: Återställer <a Searches Filter>sökfiltret</a> så att alla partiet ingår i urvalet.</li>
<li><menu>Omvänt filter</menu>: Ta med de partier som utesluts av filtret.</li>
<br>
<li><menu>Aktuell ställning...</menu>: Sök partier med <a Searches Board>den aktuella ställningen</a> på brädet.</li>
<li><menu>I huvud...</menu>: Använd <a Searches Header>fast information</a> (spelare, evenemang, plats, mm).</li>
<li><menu>Material/ställning...</menu>: Sökning baserad på <a Searches Material>material</a> eller <a Searches Pattern>ställning</a>.</li>
<br>
<li><menu>Använd sökfil...</menu>: Använd en fil med <a Searches Settings>lagrade</a>.</li>
</ul>

<h3>Fönster</h3>
<ul>
<li><menu>Kommentarseditor</menu>: Öppna/ stäng <a Comment>kommentarseditorn</a>.</li>
<li><menu>Partilista</menu>: Öppna/ stäng <a GameList>partilistan</a>.</li>
<li><menu>PGN fönster</menu>: Öppna/ stäng <a PGN>PGN fönstret</a>.</li>
<li><menu>Spelarförteckning</menu>: Öppna/ stäng en förteckning över spelarna i den aktiva databasen.</li> 
<li><menu>Turneringar</menu>: Lista <a Tmt>turneringar</a>.</li>
<br>
<li><menu>Databasväxlaren</menu>: Öppna/ stäng <a Switcher>databasväxlaren</a>. Databasväxlaren underlättar byte mellan olika databaser
och kopiering av partier från den ena databasen till den andra.</li>
<li><menu>Databasverktyg</menu>: Öppna/ stäng <a Maintenance>verktygsfönstret</a>.</li>
<br>
<li><menu>ECO fönster</menu>: Öppna/ stäng <a ECO browser>ECO bläddraren</a>.</li>
<li><menu>Repetoareditor</menu>: Öppna/ stäng verktyget för <a repetoire>spelöppningshantering</a>.</li>
<li><menu>Statistikfönster</menu>: Öppna/ stäng <term>statistikfönstret</term>. Här hittar en statistisk sammanfattning av partierna i  
 <a Searches Filter>sökfiltret</a>.</li>
<li><menu>Trädfönster</menu>: Öppna/ stäng <a Tree>variantträdet</a>.</li>
<li><menu>Slutspelsdatabas</menu>: Öppna/ stäng slutspelsdatabasfönstret som ger dig viss information om <a TB>slutspelsdatabaserna</a>.</li>
</ul>

<h3>Verktyg</h3>
<ul>
<li><menu>Analysmotor...</menu>: Starta/ stoppa en analysmotor, t ex Crafty, som kontinuerligt bedömmer den aktuella ställningen
på brädet i ett <a Analysis>analysfönster</a>.</li>
<li><menu>Analysmotor 2...</menu>: Starta/ stoppa en andra analysmotor, t ex Crafty.</li>
<li><menu>Resultattabell</menu>: Skapa en <a Crosstable>resultattabell</a> för den aktuella turneringen/matchen som det aktuella partiet ingår i</li>
<li><menu>Eposthanteraren</menu>: Öppna/ stäng <a Email>eposthanteraren</a> för hantering av korrespondensschack.</li>
<br>
<li><menu>Öppningsrapport</menu>: Skapa en <a OpReport>öppningsrapport</a> utifrån den aktuella ställningen.</li>
<li><menu>Sök material</menu>: Öppnar dialog för att <a PTracker>söka efter en viss materiell balans</a>.</li>
<br>
<li><menu>Spelarinformation</menu>: Visa/ uppdatera <a PInfo>spelarinformation</a> för den ene av två spelare i det aktuella partiet.</li>
<li><menu>Rankingdiagram</menu>: Skapa ett <a Graphs Rating>ranking diagram</a> för spelarna i partiet.</li>
<li><menu>Resultatdiagram</menu>: Visa <a Graphs Score>resultatdiagrammet</a>.</li>
<br>
<li><menu>Exportera aktuellt parti ...</menu>: Spara aktuellt parti till olika format; text, HTML eller LaTeX. Se vidare
   hjälpsidan för  att <a Export>exportera</a> partier.</li>
<li><menu>Exportera alla filtrerade partier</menu>: Spara alla <a Searches Filter>filterade</a> partier till olika format; text, HTML eller LaTeX. Se vidare
   hjälpsidan för  att <a Export>exportera</a> partier.</li>
<br>
<li><menu>Importera ett parti i PGN-format...</menu>: Öppnar <a Import>Importfönstret</a> för att ange eller klistra in ett parti i 
 <a PGN>PGN format</a> för import till en Scid databas.</li>
<li><menu>Importera flera partier i PGN-format...</menu>: Importera flera partier i PGN-format från en fil.</li>
</ul>

<h3>Alternativ</h3>
<p>
Denna meny ger tillgång till de flesta av de parametrar som styr hur Scid fungerar.
Menyvalet <menu>Spara alternativ</menu> sparar de aktuella inställningarna till filen
 "<b>~/.scid/scidrc</b>" (eller <b>scid.opt</b> i katalogen som innehåller den exekverbara
scid-filen vad gäller Windows); denna fil laddas varje gång du startar Scid.
</p>

<h3>Hjälp</h3>
<p>
Denna meny innehåller hjälpfunktioner och ger tillgång till bl a fönstret "Dagens tips"
och startfönstret som informerar om vilka filer Scid laddat vid uppstart. 
</p>

<p><footer>(Uppdaterad: Scid 3.3, april 2002)</footer></p>
}

####################
### Entering moves help:

set helpTitle(W,Moves) "Ange drag"
set helpText(W,Moves) {<h1>Ange drag</h1>
<p>
I Scid, kan du ange partidrag såväl med musen som med tangentbordet. När du rör musmarkören över en ruta på
brädet kommer du att märka att såväl rutan som ytterligare en ruta får en annan färg. Om det finns ett legalt
drag till eller från den ruta du för musmarkören över. Detta är det <term>föreslagna draget</term>.
Du utför detta drag genom att <term>vänsterklicka</term> med musen. Om detta stör dig kan du stänga av funktionen
i Alternativmenyn.

</p>
<p>
För att utföra ett annat drag kan du <term>klicka och hålla nere vänster</term> musknapp: flytta sedan musen till önskad
 ruta och släpp musknappen.
</p>
<p>
Om du vill kan du utföra drag genom att klicka två gånger istället för att använda klicka-och-drag tekniken. Klicka då 
först på utgångsrutan med den <term>mittersta musknappen</term> och klicka sedan med samma musknapp på destinationsrutan.
(Tipset gäller kanske ffa användare av UNIX(-lika) system som ofta har stor nytta av 3-knappsmöss).
</p>

<h4>Ta tillbaka ett drag</h4>
<p>
Man kan ta tillbaka ett drag genom att högerklicka musen. Detta backar ett drag och raderar det senast utförda draget i partiet
eller varianten.
</p>

<h4>Ersätt tidigare drag</h4>
<p>
Om du anger ett drag i en ställning där ett drag redan angivits kommer Scid att fråga om du verkligen vill ersätta den tidigare
draget (draget och alla varianter längre fram som är beroende av draget tas bort), eller om du vill skapa en ny variant istället.
En del använder tycker att frågan är störande och vill alltid ersätta det tidigare draget, så man kan konfigurera Scid till att inte
ställa denna fråga. Du hittar möjligheten i  menyn <menu>Alternativ: Drag</menu> "<i>Fråga före ersätt drag</i>".
</p>

<h4><name Trial>Testläge</name></h4>
<p>
Om du går igenom ett parti och kommer till en ställning där du vill testa en idÃ© utan att påverka det registrerade partiet så väljer du
<b>Testa en idÃ©</b> från menyn <menu>Redigera</menu> för att sätta på testläge. I testläge kan du göra drag och förändringar av partiet som
är temporära, dvs de sparas inte när du återgår från testläge.
</p>

<h3><name Mistakes>Rätta fel</name></h3>
<p>
Om du skriver in ett parti och plötsligt upptäcker ett fel flera drag tidigare är det möjligt att rätta till detta utan att 
behöva göra om alla drag efter feldraget. Det ända sättet är att redigera PGN-versionen av partiet: Öppna <a Import>Importfönstret</a>, 
välj Klistra in aktivt parti, korrigera felet och välj därefter "Importera".
</p>

<h3>Ange drag via tangentbordet</h3>
<p>
Du kan ange drag via tangentbordet genom att helt enkelt skriva in dem med bokstäver och siffror. Lägg märke till att dragen
ska anges i <term>SAN notation</term>, <i>utan</i> (x) tecknet för slag eller (=) tecknet för promovering. Dragnotationen är 
inte versal/gemenkänslig så t ex:
[n][f][3] är samma drag som Nf3 -- men kontrollera med noten nedan för drag som står i konflikt med varandra.
</p>
<p>
För att säkerställa att inga drag är prefix för ett annat drag så används en särskild metod att ange rockad. Kort och lång rockad
representeras med hjälp av bokstäver som följer:
kort rockad anges med  [O][K]
lång rockad anges med [O][Q] istället för det vanliga O-O and O-O-O.
</p>
<p>
När du anger drag kommer du i statusraden att se en lista över giltiga drag. Du kan, genom att trycka [mellanslag] välja det första i listan och föra in det
i partiet. För att radera tecken använder du de vanliga raderingstangenterna.
</p>
<p>
<b>OBS</b> gemena tecken kopplas i första hand till bönder, vilket betyder att [b]kan betyda b-bonden istället för löparen (Bishop). Om du hamnar
i situationer när konflikter uppstår måste du istället ange pjäserna med versaler (B) i detta fallet.
</p>
<b>Översättarens kommentar</b> Scid förstår inte svenska. Detta betyder att du inte kan använda de svenska förkortningarna till att ange drag. [s][f][6] 
förstås inte av Scid (däremot funkar [n][f][6] utmärkt). Om du vill använda tangentbordet att skriva in drag får du istället använda notationen [g][8][f][6] för
samma drag.
</p>
<h4>Autokomplettering</h4>
<p>
I Alternativmenyn kan du slå på eller av <term>Autokomplettering</term>
av drag.
Med denna påslagen görs draget så fort du skrivit in tillräckligt mycket för att särskilja det från andra möjliga drag. Exempelvis räcker det att skriva [n][f] istället
för [n][f][3] för draget <b>Nf3</b>i utgångsställningen.
</p>
<p><b>Översättarens kommentar</b> Scid förstår som sagt inte svenska. Däremot fungerar det med rutangivelsen om t ex pjäsen på g1 bara har ett fält 
att gå till.</p>

<h3><name Null>Ange null-drag</name></h3>
<p>
<a Annotating Null>Null</a> (tomma, planerade) drag kan vara användbara i  kommentarer för att hoppa över den ena spelarens drag. Du anger null-drag
genom att slå den ena kungen med den andra, eller via tangentbordet genom att skriva  "<b>--</b>" (minustecknet två gånger).
</p>
<p><b>Översättarens kommentar</b> "null" är en dataterm för att beskriva ingenting (till skillnad mot noll som har ett värde om dock noll, null har inget värde).
Shane använder termen null här, någon som har förslag på bättre i den svenska översättningen? Kolla intro sidan för att föreslå något.</p>

<h3>Ange de vanligaste kommentarsymbolerna</h3>
<p>
Du kan även ange <a NAGs>kommentarsymboler</a> via tangentbordet utan att behöva använda <a Comment>kommentarseditorn</a>. 
Följande lista kan anges via tangentbordet:
<ul>
<li> !	: [!][ENTER] </li>
<li> ?	: [?][ENTER] </li>
<li> !?	: [!][?][ENTER] </li>
<li> ?!	: [?][!][ENTER] </li>
<li> !!	: [!][!][ENTER] </li>
<li> ??	: [?][?][ENTER] </li>
<li> </li>
<li> +-	: [+][-] </li>
<li> +/-	: [+][/] </li>
<li> +=	: [+][=] </li>
<li> =	: [=][ENTER] </li>
<li> -+	: [-][+] </li>
<li> -/+	: [-][/] </li>
<li> =+	: [=][+] </li>
</ul>

<p><footer>(Uppdaterad: Scid 3.4,  juli 2002)</footer></p>
}


########################################
### Searches help screen:

set helpTitle(W,Searches) "Söka i Scid"
set helpText(W,Searches) {<h1>Söka i Scid</h1>
<p>
I Scid kan man söka information på flera olika sätt. 
Det finns tre huvudmetoder att använda sig av beroende på vilken typ av information man
är ute efter:
<ul>
<li><b>1)</b> utifrån den aktuella ställningen på brädet, </li>
<li><b>2)</b> utifrån specifikt material eller en specifik ställningstyp; och </li>
<li><b>3)</b> utifrån fast information, t ex spelare, ort, resultat eller datum. </li>
</ul>
<p>
Utöver dessa metoder kan man använda sig av en automatisk sökfunktion, <a Tree>trädfönstret</a>, som förklaras
separat.
</p>

<h3><name Filter>Sökfiltret</name></h3>
<p>
Sökningar baseras i  Scid på <term>filter</term>.
Ett filter representerar en delmängd av den aktiva databasen. Vid varje specifikt tillfälle kommer ett parti att antingen vara
del av denna delmängd (filtret) eller uteslutas av detta. I varje typ av sökning (se ovan) kan du välja att begränsa, utöka eller
ignorera det aktiva filtret och istället söka i hela databasen. Detta gör att man stegvis kan bygga komplicerade sökningar. 
Du kan också kopiera alla filtrerade partier från den ena databasen till den andra genom att använda <a Switcher>databasväxlaren</a>.
</p>

<p>
När du söker på exakt ställning, <a Tree>träd</a> eller material/ställningstyp, sparas dragnumret i den första ställningen och varje
parti med identisk ställning lagras i minnet så att man, när man senare laddar de framsökta partierna, automatiskt kommer till den ställning
som var av intresse (som sökningen grundades på).
</p>
<p>
<b>OBS</b> sökningen gäller endast textdragen, inte varianterna.
</p>

<h3><name Board>Sök: Aktuell ställning</name></h3>
<p>
Med denna metod hittas partier med samma ställning som det på brädet i huvudfönstret. Rockadmöjligheter och 
rättigheter att göra <i>en passant</i> ignoreras. Det finns fyra undertyper att välja på, samtliga kräver att ställningen har exakt samma material och spelare vid draget för att en träff ska
anses ha inträffat:
<ul>
<li> [1] exakt (de båda ställningarna måste vara exakt lika), </li>
<li> [2] bönder (bondestrukturen måste vara identisk, men de övriga pjäsernas placering kan variera), </li>
<li> [3] linjer (antalet vita och svarta bönder på varje linje måste vara identisk - i övrigt kan pjäsplaceringen variera), och slutligen; </li>
<li> [4] material (bönder och pjäser kan stå var som helst på brädet.). </li>
</ul>
<p>
Att söka på bondeställning är användbart när man studerar spelöppningar med likartad bondstruktur, medan att söka på linjer och material är lämpliga metoder
att finna liknande ställningar i slutspel. När man söker på specifika ställningar kan man skapa den först (från menyvalet <menu>Redigera: Skapa ställning</menu>) och starta sökningen därifrån.
(Man kan naturligtvis också spela upp ställningen på brädet, <i>övers anm</i>).
</p>
<p>
Du kan ange att sökningen även ska leta i varianter (istället för att bara inkludera de egentliga partidragen) genom att markera kryssrutan <b>Sök i varianter</b>, 
men detta kan göra sökningen långsammare om databasen är stor och har många partier med varianter.
</p>

<h3><name Material>Sök: Material/ställningstyp</name></h3>
<p>
Denna sökning är användbar när man vill finna slut- eller mittspelsteman. Du kan specificera minimalt och maximalt antal av varje pjästyp, och hitta ställningar
av typen "Löpare på f7" eller "Bonde på f-linjen". Det finns ett antal vanliga ställningstyper fördefinierade, t ex "Torn och Bondeslutspel" eller "Isolerade d-bönder".
</p>
<p>
<b>Tips:</b><br>
Tidsåtgången för denna typ av sökning kan variera kraftigt. Man kan minska tiden som behövs genom att använda sig av förnuftiga begränsningar.
Om man, som exempel,  vill undersöka slutspel. kan man sätta det minimala antalet drag partiet ska innehålla till 20. Då kommer alla partier 
med färre än 20 drag att ignoreras.
</p>

<h3><name Header>Sök: fasta uppgifter ("header search")</name></h3>
<p>
Denna sökning används för att finna aspekter på partier som lagras i partiets huvud (jmf eposthuvud) såsom datum, resultat, plats och rankingtal. Den
kräver ingen avkodning av dragen i partiet. För att en träff ska registreras krävs att alla fält du specificerar stämmer överens. Namnfälten  (Vit, Svart, 
Evenemang, Plats och Rond) är versal/gementoleranta. Träffar registrerars på all text i dessa fält och mellanslag ignoreras .
</p>
<p>
Du kan generera exakta sökning ar och använda jokertecken i huvudfälten som nämnts ovan. Jokertecknet  <b>?</b> betyder "ett
valfritt tecken" medan <b>*</b> betyder "inget eller flera valfria tecken". Man genererar exakta sökningar genom att innesluta den text man
önskar hitta i citattecken ("). Exempel:
</p>

<p>
En sökning på platsen <b>USA</b> kommer att generera amerikanska städer, men även <b>Lausanne SUI</b>, vilket du förmodligen inte var ute efter! 
Detta löser man genom att istället söka efter platsen <b>"*USA"</b> (notera citattecknen) som endast kommer att presentera städer i USA.</p>
<p>
Om du söker efter en särskild spelare (eller två särskilda spelare) som vit eller svart och det inte spelar någon roll vet som har vilken färg väljer du med 
fördel <b>Ignorera färg</b> i stället för svart/vit i färgangivelsen.
</p>
<p>
Avslutningsvis kan fasta sökningar göras för att hitta valfri text (versal/gemen intolerant och utan jokertecken) i PGN versionen av partierna. Du kan
ange upp till tre textsträngar, och alla måste finnas i ett parti för att de ska räknas som en träff. Denna sökning är mycket användbar när det gäller
kommentarsfältet eller extra märkord i partierna (exempelvis  <b>förlorar på tid</b> eller <b>Kommentator</b>), eller för en dragföljd som 
<b>Bxh7+</b> och <b>Kxh7</b> när en löpare har offrats (och accepterats) på h7.

Tänk dock på att denna typ av sökningar kan vara <i>mycket</i> tidskrävande eftersom alla partier som möter vissa kriterier måste avkodas och
genomsökas efter textsträngen/-arna. Det är därför en bra ide att begränsa denna typ av sökning så mycket som möjligt. Exempel:
</p>

<p>
För att hitta partier med underpromovering till torn säker man på <b>=R</b> och sätter <b>Förvandlingar</b> flaggan till Ja.
För att hitta text i kommentarer sätter du flaggan <b>Kommentarer</b> till Ja.
Om du söker på dragen <b>Bxh7+</b> och <b>Kxh7</b>, kan det vara en ide att begränsa partierna till de som har resultatet  1-0 result och innehåller
minst 20 halvdrag. Eller gör en Material/Ställningstypssökning för att hitta partier där löparen flyttas till h7.
</p>

<h3><name Settings>Spara sökkriterierna</name></h3>
<p>
I Material/Ställningstyp and Huvudsökningsfönstrena finns valet att  
<term>Spara inställningarna</term>. Detta ger dig möjligheten att spara de aktuella sökkriterierna för senare användning.
Kriterierna sparas till en <term>sökningsfil</term> med filändelsen  .sso. För att återanvända en tidigare sparad sökningfil
väljer du <menu>Öppna ...</menu> från menyn <menu>Sök</menu>.
</p>

<h3>Söktider och ignorerade partier</h3>
<p>
De flesta sökningar meddelar en hur lång tid sökningen tog och hur många partier som <term>ignorerades</term>. Ignorerade partier
är de som exkluderats från en sökning utan att något av dess drag har avkodats (från Scids databasformat). Detta baseras på information
som lagrats i index. Se vidare hjälpfilen om <a Formats>filformat</a> för ytterligare information. 
</p>

<p><footer>(Uppdaterad: Scid 3.0, november 2001)</footer></p>
}

#################
### Clipbase help:

set helpTitle(W,Clipbase) "Urklippsdatabasen"
set helpText(W,Clipbase) {<h1>Urklippsdatabasen</h1>
<p>
Förutom de databaser du öppnar själv, öppnar Scid ytterligare en - <term>urklippsdatabasen</term>. Urklippsdatabasen,
fungerar precis som alla andra databaser, med ett undantag. Den existerar bara i datorns arbetsminne och sparar inte data
någonstans permanent. Urklippsdatabasen töms således när du stänger av datorn.
</p>
<p>
Urklippsdatabasen är användbar som en tillfällig lagringsplats, för att slå samman sökresultat från olika databaser, eller för att man där
kan behandla resultat från en sökning som en egen databas. 
</p>
<p>
Antag, exempelvis, att du vill förbereda dig för en särskild motståndare. Du har sökt igenom databasen efter partier av denne där motståndaren
spelar vit. Kopiera alla partier i <a Searches Filter>sökfiltret</a> till urklippsdatabasen. Du kan göra det genom att i <a Switcher>databasväxlaren</a>
 dra dem från deras ordinarie databas till urklippsdatabasen. Därefter kan du öppna urklippsdatabasen och undersöka partierna i  <a Tree>trädfönstret</a>, 
till exempel för att kartlägga motståndarens öppningrepertoir.
</p>
<p>
Observera att du kan kopiera partier från en databas till en annan utan att använda urklippsdatabasen som mellanlagringsplats. Notera också att
urklippsdatabasen <i>inte</i> kan stängas via menyvalet <menu>Arkiv: Stäng</menu>medan du är i urklippsdatabasen. Det som händer då är
motsvarigheten till  <menu>Redigera: Återställ urklippsdatabasen</menu>, dvs databasen töms.
</p>
<p>
Du kan maximalt ha 20,000 partier i minnet samtidigt.
</p>

<p><footer>(Uppdaterad: Scid 2.5,  juni 2001)</footer></p>
}

#################################
### Variations and comments help:

set helpTitle(W,Annotating) "Kommentera partier"
set helpText(W,Annotating) {<h1>Kommentera partier</h1>
<p>
I Scid kan lägga till noter till partierna. Det finns tre typer av anteckningar du kan lägga till till varje drag:
symboler, kommentarer och varianter.
</p>

<h3>Symboler och kommentarer</h3>
<p>
Symboler används för ställningsbedömningar om vem som står bäst (t ex "+-" eller "=") , om draget som just gjordes var bra eller dåligt
(t ex "!" eller "?") medan kommentarer kan bestå av valfri text. För att lägga till symboler och kommentarer använder man
<a Comment>kommentarseditorn</a>. Det finns också en särskild hjälpsida för <a NAGs>standardsymbolerna</a>.
</p>
<p>
Tänk på att även om varje drag kan ha fler symboler, kan det bara ha en kommentar. En kommentar för första draget skrivs ut som 
text före partidragen. 
</p>

<h3><name Vars>Varianter</name></h3>
<p>
En <term>variant</term> är en alternativ fortsättning av partiet som skulle ha kunnat utföras vid något
tillfälle i partiet. Varianter kan innehålla kommentarer, symboler och varianter. Knappen märkt "<b>V</b>" 
ovanför brädet i huvudfönstret, samt valmöjligheter från menyn <menu>Redigera</menu> kan användas till att skapa,
navigera i och redigera varianter.
</p>

<h4>Kortkommandon</h4>
<p>
När det finns varianter till ett drag visas dem i partiinformationsområdet. Den första varianten är <b>v1</b>, den andra
är <b>v2</b>, osv. För att följa en variant kan man klicka på den, eller trycka  "<b>v</b>" följt av variantens nummer 
(Om det bara finns en variant räcker det med att trycka <b>v</b>.). Kortkommandot för att gå ur en variant är "<b>z</b>".
</p>

<h3><name Null>Null-drag</name></h3>
<p>
Det kan ibland vara användbart att hoppa över drag i varianter. Du kan exempelvis till draget 14.Bd3 lägga till en variant och
nämna att det hotar 15.Bxh7+ Kxh7 16.Ng5+ med angrepp. Du kan också göra detta genom att använda <term>null-drag</term>
mellan 14.Bd3 och 15.Bxh7+, i exemplet ovan. Ett null-drag visas som "<b>--</b>" och infogas genom att med musen utföra det
ogiltiga draget att med kungen slå den andra kungen, eller att helt enkelt skriva in "<b>--</b>" (två minustecken).
</p>
<p>
Observera att null-drag inte ingår i PGN standarden, så om du vill expotera partier som innehåller null-drag till en PGN-fil måste du 
välja mellan att bevara null-dragen(-t) eller konvertera dem till kommentarer för att bibehålla exportmöjligheter till andra
program. Se hjälpsidan för att <a Export>exportera</a> partier för mer information.
</p>

<p><footer>(Uppdaterad: Scid 3.4, juli 2002)</footer></p>
}


# end of swedish.tcl

