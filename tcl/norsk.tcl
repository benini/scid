# norsk.tcl
# Text for menu names and status bar help messages in Norwegian.
# First created for Scid 3.2.beta2 by morten.skarstad@sapphire.no.
# Edited for Scid 3.2.beta4
# Thanks to Martin Skjöldebrand, swedish.tcl was of great help to me.

addLanguage O Norsk 1

proc setLanguage_O {} {

# File menu:
menuText O File "Fil" 0
menuText O FileNew "Ny..." 0 {Lag en ny Scid-database}
menuText O FileOpen "Åpne..." 0 {Åpne en Scid-database}
menuText O FileClose "Lukk" 0 {Lukk aktiv Scid-database}
menuText O FileFinder "Søk" 0 {Åpne søkevinduet}
menuText O FileBookmarks "Bokmerker" 0 {Bokmerkemeny (snarvei: Ctrl+B)}
menuText O FileBookmarksAdd "Legg til bokmerke" 0 \
  {Sett bokmerke til nåværende database, parti og stilling}
menuText O FileBookmarksFile "Lagre bokmerke" 0 \
  {Lagre et bokmerke for nåværende database, parti og stilling}
menuText O FileBookmarksEdit "Ordne bokmerker" 0 \
  {Vedlikehold av bokmerkene}
menuText O FileBookmarksList "Vis kataloger som enkel liste" 24 \
  {Vis bokmerker som liste, ikke undermenyer}
menuText O FileBookmarksSub "Vis kataloger som undermenyer" 18 \
  {Vis bokmerke-katalogene som undermenyer, ikke liste}
menuText O FileMaint "Vedlikehold" 0 {Verktøy for å vedlikeholde Scid-databasen}
menuText O FileMaintWin "Vedlikeholdsvindu" 0 \
  {Åpne/lukk Scids vedlikeholdsvindu}
menuText O FileMaintCompact "Komprimer database..." 0 \
  {Sletter ubrukte partier og navn}
menuText O FileMaintClass "ECO-klassifiser partier..." 0 \
  {Regn om ECO-koden for alle partier}
menuText O FileMaintSort "Sorter database..." 0 \
  {Sorter alle partier i databasen}
menuText O FileMaintDelete "Slett duplikater..." 6 \
  {Finner like partier og merker en av dem for sletting}
menuText O FileMaintTwin "Duplikatsjekkvindu" 1 \
  {Åpne/oppdatere duplikatsjekkvinduet}
menuText O FileMaintName "Navnestaving" 0 {Redigering og stavekontroll av navn}
menuText O FileMaintNameEditor "Navneredigering" 5 \
  {Åpne/lukk vinduet for navneredigering}
menuText O FileMaintNamePlayer "Kontroller navn..." 0 \
  {Sammenlign navn med stavekontroll-filen}
menuText O FileMaintNameEvent "Kontroller anledninger..." 11 \
  {Sammenlign anledninger med stavekontroll-filen}
menuText O FileMaintNameSite "Kontroller stedsnavn..." 12 \
  {Sammenlign stedsnavn med stavekontroll-filen}
menuText O FileMaintNameRound "Kontroller runde-navn..." 11 \
  {Sammenlign rundenavn med stavekontroll-filen}
menuText O FileReadOnly "Skrivebeskytt..." 6 \
  {Hindrer endringer på databasen}
menuText O FileSwitch "Switch to database" 0 \
  {Switch to a different opened database} ;# ***
menuText O FileExit "Avslutt" 0 {Avslutt Scid}

# Edit menu:
menuText O Edit "Rediger" 0
menuText O EditAdd "Legg til variasjon" 0 {Legg til en variasjon av dette trekket i partiet}
menuText O EditDelete "Slett variasjon" 0 {Slett en variasjon av dette trekket}
menuText O EditFirst "Flytt variasjon øverst" 0 \
  {Gjør variasjonen til den øverste på listen}
menuText O EditMain "Gjør variasjon til hovedlinje" 0 \
  {Gjør variasjon til hovedlinje}
menuText O EditTrial "Prøv variasjon" 0 \
  {Start/avslutt prøvemodus, for å teste ut en ide på brettet}
menuText O EditStrip "Fjern" 0 {Fjern kommentarer eller variasjoner fra partiet}
menuText O EditStripComments "Kommentarer" 0 \
  {Fjern alle kommentarer og annotasjoner fra dette partiet}
menuText O EditStripVars "Variasjoner" 0 {Fjern alle variasjoner fra dette partiet}
menuText O EditStripBegin "Moves from the beginning" 1 \
  {Strip moves from the beginning of the game} ;# ***
menuText O EditStripEnd "Moves to the end" 0 \
  {Strip moves to the end of the game} ;# ***
menuText O EditReset "Rensk utklippsbase" 0 \
  {Tømmer utklippsbasen fullstendig}
menuText O EditCopy "Kopier partiet til utklippsbasen" 0 \
  {Kopier dette partiet til utklippsbasen}
menuText O EditPaste "Lim inn siste parti fra utklippsbasen" 0 \
  {Limer inn gjeldende parti fra utklippsbasen her}
menuText O EditSetup "Still opp stilling..." 0 \
  {Lag en startstilling for dette partiet}
menuText O EditCopyBoard "Copy position" 6 \
  {Copy the current board in FEN notation to the text selection (clipboard)} ;# ***
menuText O EditPasteBoard "Lim inn stilling" 0 \
  {Lag en startstilling fra gjeldende utvalg (utklippstavle)}

# Game menu:
menuText O Game "Parti" 0
menuText O GameNew "Nytt parti" 0 \
  {Sletter alle trekk og starter et nytt parti}
menuText O GameFirst "Hent første parti" 0 {Henter første parti fra filteret}
menuText O GamePrev "Hent forrige parti" 0 {Henter forrige parti fra filteret}
menuText O GameReload "Hent dette partiet" 0 \
  {Henter dette partiet på nytt og fjerner alle endringer}
menuText O GameNext "Hent neste parti" 0 {Henter neste parti fra filteret}
menuText O GameLast "Hent siste parti" 0 {Henter siste parti fra filteret}
menuText O GameRandom "Hent tilfeldig parti" 8 {Hent tilfeldig parti fra filteret}
menuText O GameNumber "Hent parti nummer..." 0 \
  {Finn et parti ved å angi nummeret}
menuText O GameReplace "Lagre: Erstatt parti..." 0 \
  {Lagre og overskriv dette partiet}
menuText O GameAdd "Lagre som nytt parti..." 0 \
  {Lagre dette partiet som et nytt parti}
menuText O GameDeepest "Identifiser åpning" 0 \
  {Gå til dypeste posisjon i dette partiet listet i ECO-boken}
menuText O GameGotoMove "Gå til trekk..." 0 \
  {Gå til et angitt trekk i dette partiet}
menuText O GameNovelty "Finn avvik..." 0 \
  {Finn det første trekket i dette partiet som ikke har blitt spilt tidligere}

# Search Menu:
menuText O Search "Søk" 0
menuText O SearchReset "Nullstill filter" 0 {Nullstill filteret til å inneholde alle partier}
menuText O SearchNegate "Snu filter" 0 {Reverserer filteret til å kun inneholde eksluderte partier}
menuText O SearchCurrent "Stilling..." 0 {Søk etter denne stillingen}
menuText O SearchHeader "Header..." 0 {Søk etter Header (partier, turnering etc) informasjon}
menuText O SearchMaterial "Kvalitet/stilling..." 0 {Søk på kvalitet eller stilling}
menuText O SearchUsing "Bruk søkefil..." 0 {Søk vha lagrede søkevilkår}

# Windows menu:
menuText O Windows "Vinduer" 0
menuText O WindowsComment "Kommentarer" 0 {Åpne/lukk kommentarvinduet}
menuText O WindowsGList "Partioversikt" 0 {Åpne/lukk partioversikten}
menuText O WindowsPGN "PGN-vindu" 0 \
  {Åpne/lukk PGN-vinduet}
menuText O WindowsPList "Player Finder" 2 {Open/close the player finder} ;# ***
menuText O WindowsTmt "Turneringsøker" 0 {Åpne/lukk turneringssøkeren}
menuText O WindowsSwitcher "Databasebytter" 0 \
  {Åpne/lukk databasebytteren}
menuText O WindowsMaint "Vedlikeholdsvindu" 0 \
  {Åpne/lukk vedlikeholdsvinduet}
menuText O WindowsECO "ECO-oversikt" 0 {Åpne/lukk ECO-oversikten}
menuText O WindowsRepertoire "Repertoirvindu" 0 \
  {Åpne/lukk åpningsreportoiret}
menuText O WindowsStats "Statistikkvindu" 0 \
  {Åpne/lukk statistikk for filteret}
menuText O WindowsTree "Trevindu" 0 {Åpne/lukk trevinduet}
menuText O WindowsTB "Sluttspilltabellvindu" 0 \
  {Åpne/lukk sluttspilltabellen}

# Tools menu:
menuText O Tools "Verktøy" 0
menuText O ToolsAnalysis "Analysemotor..." 0 \
  {Start/stopp en sjakkanalysemotor}
menuText O ToolsAnalysis2 "Analysemotor #2..." 0 \
  {Start/stopp enda en sjakkanalysemotor}
menuText O ToolsCross "Krysstabell" 0 {Vis turnerigskrystabellen for dette partiet}
menuText O ToolsEmail "Epostbehandler" 0 \
  {Åpne/lukk epostbehandlingsvinduet}
menuText O ToolsFilterGraph "Filtergraf" 7 \
  {Åpne/lukk filtergrafvinduet}
menuText O ToolsOpReport "Åpningsrapport" 0 \
  {Lager en åpningsrapport for denne stillingen}
menuText O ToolsTracker "Brikkesporing"  0 {Åpne brikkesporingsvinduet}
menuText O ToolsPInfo "Spillerinformasjon"  0 \
  {Åpne/oppdater informasjonsvinduet for denne spilleren}
menuText O ToolsRating "Ratinggraf" 0 \
  {Tegner ratingen til disse spillerene over tid}
menuText O ToolsScore "Poeng-graf" 0 {Viser poeng-grafen}
menuText O ToolsExpCurrent "Eksporter parti" 0 \
  {Skriv dette partiet til en tekstfil}
menuText O ToolsExpCurrentPGN "Eksporter parti til PGN-fil..." 0 \
  {Skriv dette partiet til en PGN-fil}
menuText O ToolsExpCurrentHTML "Eksporter parti til HTML fil..." 0 \
  {Skriv dette partiet til en HTML-fil}
menuText O ToolsExpCurrentLaTeX "Eksporter partil til LaTeX fil..." 0 \
  {Skriv dette partiet til en LaTeX-fil}
menuText O ToolsExpFilter "Eksporter alle partier i filteret" 0 \
  {Skriv alle partier i filteret til en tekstfil}
menuText O ToolsExpFilterPGN "Eksporter filter til PGN-fil..." 0 \
  {Skriv alle partier i filteret til en PGN-fil}
menuText O ToolsExpFilterHTML "Eksporter filter til HTML-fil..." 0 \
  {Skriv alle partier i filteret til en HTML-fil}
menuText O ToolsExpFilterLaTeX "Eksporter filter til LaTeX-fil..." 0 \
  {Skriv alle partier i filteret til en LaTeX-fil}
menuText O ToolsImportOne "Importer ett PGN-parti..." 0 \
  {Importer ett parti fra en PGN-fil}
menuText O ToolsImportFile "Importer fil med PGN-partier..." 0 \
  {Importer partier fra en PGN-fil}

# Options menu:
menuText O Options "Innstillinger" 0
menuText O OptionsSize "Brettstørrelse" 0 {Endre brettstørrelse}
menuText O OptionsPieces "Brikkeutseende" 6 \
  {Endrer utseendet på brikkene}
menuText O OptionsColors "Farger..." 0 {Endre farger på brettet}
menuText O OptionsExport "Eksport" 0 {Endre innstillinger for eksport av tekst}
menuText O OptionsFonts "Skrifttyper" 0 {Endre skrifttyper}
menuText O OptionsFontsRegular "Vanlig" 0 {Endre den vanlige skrifttypen}
menuText O OptionsFontsMenu "Menu" 0 {Change the menu font} ;# ***
menuText O OptionsFontsSmall "Liten" 0 {Endre den lille skrifttypen}
menuText O OptionsFontsFixed "Fastbredde" 0 {Endre fastbreddeskrifttypen}
menuText O OptionsGInfo "Partiinformasjon" 0 {Informasjonsinnstillinger}
menuText O OptionsLanguage "Språk" 0 {Velg menyspråk}
menuText O OptionsMoves "Trekk" 0 {Innstillinger for hvordan trekk angis}
menuText O OptionsMovesAsk "Spør før trekk erstattes" 0 \
  {Spør før eksisterende trekk erstattes av et nytt}
menuText O OptionsMovesAnimate "Animation time" 1 \
  {Set the amount of time used to animate moves} ;# ***
menuText O OptionsMovesDelay "Autospillforsinkelse..." 0 \
  {Sett forsinkelsen ved automatisk gjennomgang av partiet}
menuText O OptionsMovesCoord "Koordinater" 0 \
  {Tillat angivelse av koordinater ("g1f3")}
menuText O OptionsMovesSuggest "Vis foreslåtte trekk" 0 \
  {Slå av/på forslag til trekk}
menuText O OptionsMovesKey "Autofullfør" 0 \
  {Slå av/på autofullføriring av tastaturtrekk}
menuText O OptionsNumbers "Tallformat" 0 {Angi tallformat}
menuText O OptionsStartup "Oppstart" 0 {Angi vinduer som skal åpne ved oppstart}
menuText O OptionsWindows "Vinduer" 0 {Vindusinnstillinger}
menuText O OptionsWindowsIconify "Auto-minimer" 5 \
  {Minimerer alle vinduer sammen med hovedvinduet}
menuText O OptionsWindowsRaise "Autoheving" 0 \
  {Hever visse vinduer (fremdriftsvisere etc) når de er skjult}
menuText O OptionsToolbar "Verktøylinje i hovedvindu" 0 \
  {Vis/skjul menylinjen i hovedvinduet}
menuText O OptionsECO "Hent ECO-fil..." 0 {Henter filen med ECO-klassifiseringer}
menuText O OptionsSpell "Hent stavekontrollfil..." 0 \
  {Henter filen med stavekontrollen til Scid}
menuText O OptionsTable "Tabellbasekatalog..." 0 \
  {Velg en tabellbase; Alle tabellbaser i katalogen vil bli brukt}
menuText O OptionsRecent "Recent files..." 0 \
  {Change the number of recent files displayed in the File menu} ;# ***
menuText O OptionsSave "Lagre innstillinger" 0 \
  "Lagre alle instillinger til $::optionsFile"
menuText O OptionsAutoSave "Autolagre innstillinger ved avslutning" 0 \
  {Autolagre alle innstillinger når Scid avsluttes}

# Help menu:
menuText O Help "Hjelp" 0
menuText O HelpIndex "Innhold" 0 {Hjelpesystemets innhold}
menuText O HelpGuide "Lynguide" 0 {Vis lynguiden}
menuText O HelpHints "Hint" 0 {Vis hint}
menuText O HelpContact "Kontaktinformasjon" 0 {Vis kontaktinformasjon}
menuText O HelpTip "Dagens tips" 0 {Vis et nyttig Scid-tips}
menuText O HelpStartup "Oppstartsvindu" 0 {Vis oppstartsvindu}
menuText O HelpAbout "Om Scid" 0 {Informasjon om Scid}

# Game info box popup menu:
menuText O GInfoHideNext "Skjul neste trekk" 0
menuText O GInfoMaterial "Vis kvalitet" 0
menuText O GInfoFEN "Vis FEN" 0
menuText O GInfoMarks "Vis fargede ruter og piler" 0
menuText O GInfoWrap "Tekstbryting" 0
menuText O GInfoFullComment "Vis full kommentar" 0
menuText O GInfoPhotos "Show Photos" 5 ;# ***
menuText O GInfoTBNothing "Tabellbaser: ingenting" 0
menuText O GInfoTBResult "Tabellbaser: kun resultater" 0
menuText O GInfoTBAll "Tabellbaser: resultater og beste trekk" 0
menuText O GInfoDelete "Slett/gjenopprett dette partiet" 0
menuText O GInfoMark "(Av)Merk dette partiet" 0

# Main window buttons:
helpMsg O .button.start {Gå til begynnelsen av partiet (tast: Home)}
helpMsg O .button.end {Gå til slutten av partiet (tast: End)}
helpMsg O .button.back {Gå ett trekk tilbake (tast: LeftArrow)}
helpMsg O .button.forward {Gå et trekk fremover (tast: RightArrow)}
helpMsg O .button.intoVar {Gå inn i en variasjon (snarvei: v)}
helpMsg O .button.exitVar {Forlat variasjon (snarvei: z)}
helpMsg O .button.flip {Roter brett (snarvei: .)}
helpMsg O .button.coords {Slå av/på brettkoordinater (snarvei: 0)}
helpMsg O .button.stm {Turn the side-to-move icon on or off} ;# ***
helpMsg O .button.autoplay {Automatisk spill (tast: Ctrl+Z)}

# General buttons:
translate O Back {Tilbake}
translate O Cancel {Avbryt}
translate O Clear {Slett}
translate O Close {Lukk}
translate O Defaults {Standard}
translate O Delete {Slett}
translate O Graph {Graf}
translate O Help {Hjelp}
translate O Import {Importer}
translate O Index {Innhold}
translate O LoadGame {Hent parti}
translate O BrowseGame {Bla gjennom parti}
translate O MergeGame {Smelt parti}
translate O Preview {Forhåndsvis}
translate O Revert {Gjør om}
translate O Save {Lagre}
translate O Search {Søk}
translate O Stop {Stopp}
translate O Store {Lagre}
translate O Update {Oppdater}
translate O ChangeOrient {Vend vindu}
translate O None {Ingen}
translate O First {Første}
translate O Current {Gjeldende}
translate O Last {Siste}

# General messages:
translate O game {parti}
translate O games {partier}
translate O move {trekk}
translate O moves {trekk}
translate O all {alle}
translate O Yes {Ja}
translate O No {Nei}
translate O Both {Begge}
translate O King {Konge}
translate O Queen {Dronning}
translate O Rook {Tårn}
translate O Bishop {Løper}
translate O Knight {Springer}
translate O Pawn {Bonde}
translate O White {Hvit}
translate O Black {Sort}
translate O Player {Spiller}
translate O Rating {Rating}
translate O RatingDiff {Ratingforskjell (Hvit - Sort)}
translate O AverageRating {Average Rating} ;# ***
translate O Event {Anledning}
translate O Site {Sted}
translate O Country {Land}
translate O IgnoreColors {Overse farger}
translate O Date {Dato}
translate O EventDate {Anledningsdato}
translate O Decade {Decade} ;# ***
translate O Year {År}
translate O Month {Måned}
translate O Months {Januar Februar Mars April Mai Juni Juli August September Oktober November Desember}
translate O Days {Søn Man Tir Ons Tor Fre Lør}
translate O YearToToday {År til i dag}
translate O Result {Utfall}
translate O Round {Runde}
translate O Length {Lengde}
translate O ECOCode {ECO-kode}
translate O ECO {ECO}
translate O Deleted {Slettet}
translate O SearchResults {Søk i resultater}
translate O OpeningTheDatabase {Åpningsdatabase}
translate O Database {Database}
translate O Filter {Filter}
translate O noGames {ingen partier}
translate O allGames {alle partier}
translate O empty {tom}
translate O clipbase {utklippsbase}
translate O score {poeng}
translate O StartPos {Utgangsstilling}
translate O Total {Sammenlagt}

# Standard error messages:
translate O ErrNotOpen {This is not an open database.} ;# ***
translate O ErrReadOnly {This database is read-only; it cannot be altered.}
translate O ErrSearchInterrupted {Search was interrupted; results are incomplete.}

# Game information:
translate O twin {duplikat}
translate O deleted {slettet}
translate O comment {kommentar}
translate O hidden {skjult}
translate O LastMove {Siste trekk}
translate O NextMove {Neste}
translate O GameStart {Begynnelse på parti}
translate O LineStart {Begynnelse på linje}
translate O GameEnd {Slutt på parti}
translate O LineEnd {Slutt på linje}

# Player information:
translate O PInfoAll {Resultater for <b>alle</b> partier}
translate O PInfoFilter {Resultater for partier i <b>filteret</b>}
translate O PInfoAgainst {Resultater mot}
translate O PInfoMostWhite {Hyppigste åpning som hvit}
translate O PInfoMostBlack {Hyppigste åpning som sort}
translate O PInfoRating {Historisk rating}
translate O PInfoBio {Biografi}
translate O PInfoEditRatings {Edit ratings} ;# ***

# Tablebase information:
translate O Draw {Uavgjort}
translate O stalemate {patt}
translate O withAllMoves {med alle trekk}
translate O withAllButOneMove {med alle trekk unntatt ett}
translate O with {med}
translate O only {kun}
translate O lose {taper} ;# tap?
translate O loses {taper}
translate O allOthersLose {alle andre taper}
translate O matesIn {setter matt i}
translate O hasCheckmated {har satt matt}
translate O longest {lengste}
translate O WinningMoves {Winning moves} ;# ***
translate O DrawingMoves {Drawing moves} ;# ***
translate O LosingMoves {Losing moves} ;# ***
translate O UnknownMoves {Unknown-result moves} ;# ***

# Tip of the day:
translate O Tip {Tips}
translate O TipAtStartup {Tips ved oppstart}

# Tree window menus:
menuText O TreeFile "Fil" 0
menuText O TreeFileSave "Lagre hurtigbuffer" 0 {Lagrer hurtigbufferfilen (.stc)}
menuText O TreeFileFill "Fyll hurtigbuffer" 0 \
  {Fyller hurtigbufferet med de hyppigste åpningsstillingene}
menuText O TreeFileBest "Idealparti" 0 {Show the best tree games list}
menuText O TreeFileGraph "Grafikk" 0 {Vis grafen for denne grenen av treet}
menuText O TreeFileCopy "Kopier treet til utklippstavlen" 0 \
  {Kopier statistikken for treet til utklippstavlen}
menuText O TreeFileClose "Lukk trevindu" 0 {Lukker trevinduet}
menuText O TreeSort "Sorter" 0
menuText O TreeSortAlpha "Alfabetisk" 0
menuText O TreeSortECO "ECO-kode" 0
menuText O TreeSortFreq "Hyppighet" 0
menuText O TreeSortScore "Poeng" 0
menuText O TreeOpt "Innstillinger" 0
menuText O TreeOptLock "Lås" 0 {Låser treet til nåværende database}
menuText O TreeOptTraining "Trening" 0 {Slår av/på treningsmodus}
menuText O TreeOptAutosave "Autolagre hurtigbuffer" 0 \
  {Autolagrer hurtigbufferet når vinduet lukkes}
menuText O TreeHelp "Hjelp" 0
menuText O TreeHelpTree "Tre hjelp" 0
menuText O TreeHelpIndex "Innholdsfortegnelse" 0
translate O SaveCache {Lagre hurtigbuffer}
translate O Training {Trening}
translate O LockTree {Lås}
translate O TreeLocked {låst}
translate O TreeBest {Beste}
translate O TreeBestGames {Idealtrepartier}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate O TreeTitleRow \
  {    Move   ECO       Frequency    Score  AvElo Perf AvYear %Draws} ;# ***
translate O TreeElapsedTime {Time} ;# ***
translate O TreeFoundInCache {  (Found in cache)} ;# ***
translate O TreeTotal {TOTAL:     } ;# ***

# Finder window:
menuText O FinderFile "Fil" 0
menuText O FinderFileSubdirs "Let i underkataloger" 0
menuText O FinderFileClose "Lukk søkevindu" 0
menuText O FinderSort "Sorter" 0
menuText O FinderSortType "Type" 0
menuText O FinderSortSize "Størrelse" 0
menuText O FinderSortMod "Endret" 0
menuText O FinderSortName "Navn" 0
menuText O FinderSortPath "Sti" 0
menuText O FinderTypes "Typer" 0
menuText O FinderTypesScid "Scid-databaser" 0
menuText O FinderTypesOld "Scid-databaser i gammelt format" 0
menuText O FinderTypesPGN "PGN-filer" 0
menuText O FinderTypesEPD "EPD-filer" 0
menuText O FinderTypesRep "Repertoire-filer" 0
menuText O FinderHelp "Hjelp" 0
menuText O FinderHelpFinder "Søkehjelp" 0
menuText O FinderHelpIndex "Innholdsfortegnelse" 0
translate O FileFinder {Søkeverktøy}
translate O FinderDir {Katalog}
translate O FinderDirs {Kataloger}
translate O FinderFiles {Filer}
translate O FinderUpDir {opp}

# Player finder:
menuText O PListFile "Fil" 0
menuText O PListFileUpdate "Oppdater" 0
menuText O PListFileClose "Close Player Finder" 0 ;# ***
menuText O PListSort "Sorter" 0
menuText O PListSortName "Name" 0 ;# ***
menuText O PListSortElo "Elo" 0
menuText O PListSortGames "Partier" 0
menuText O PListSortOldest "Oldest" 0 ;# ***
menuText O PListSortNewest "Newest" 0 ;# ***

# Tournament finder:
menuText O TmtFile "Fil" 0
menuText O TmtFileUpdate "Oppdater" 0
menuText O TmtFileClose "Lukk turneringssøker" 0
menuText O TmtSort "Sorter" 0
menuText O TmtSortDate "Dato" 0
menuText O TmtSortPlayers "Players" 0
menuText O TmtSortGames "Partier" 0
menuText O TmtSortElo "Elo" 0
menuText O TmtSortSite "Sted" 0
menuText O TmtSortEvent "Anledning" 1
menuText O TmtSortWinner "Vinner" 0
translate O TmtLimit "Listegrense"
translate O TmtMeanElo "Laveste middel-ELO"
translate O TmtNone "Ingen passende turneringer funnet."

# Graph windows:
menuText O GraphFile "Fil" 0
menuText O GraphFileColor "Lagre som farget PostScript..." 0
menuText O GraphFileGrey "Lagre som gråtonet PostScript..." 0
menuText O GraphFileClose "Lukk vindu" 0
menuText O GraphOptions "Innstillinger" 0
menuText O GraphOptionsWhite "Hvit" 0
menuText O GraphOptionsBlack "Sort" 0
menuText O GraphOptionsBoth "Begge" 0
menuText O GraphOptionsPInfo "Spiller Info spiller" 0
translate O GraphFilterTitle "Filtergraf: hyppighet per 1000 partier"

# Analysis window:
translate O AddVariation {Legg til variasjon}
translate O AddMove {Legg til trekk}
translate O Annotate {Annoter}
translate O AnalysisCommand {Analysekommando}
translate O PreviousChoices {Tidligere valg}
translate O AnnotateTime {Tid mellom trekk i sekunder}
translate O AnnotateWhich {Legg til variasjoner}
translate O AnnotateAll {For trekk av begge sider}
translate O AnnotateWhite {Kun for hvite trekk}
translate O AnnotateBlack {Kun for sorte trekk}
translate O AnnotateNotBest {Når trekket avviker fra beste linje}
translate O LowPriority {Low CPU priority} ;# ***

# Analysis Engine open dialog:
translate O EngineList {Liste over analysemotorer}
translate O EngineName {Navn}
translate O EngineCmd {Kommandolinje}
translate O EngineArgs {Parametre}
translate O EngineDir {Katalog}
translate O EngineElo {Elo}
translate O EngineTime {Dato}
translate O EngineNew {Ny}
translate O EngineEdit {Rediger}
translate O EngineRequired {Fete felter er nødvendige, de øvrige er valgfrie}

# Stats window menus:
menuText O StatsFile "Fil" 0
menuText O StatsFilePrint "Skriv til fil..." 0
menuText O StatsFileClose "Lukk vindu" 0
menuText O StatsOpt "Innstillinger" 0

# PGN window menus:
menuText O PgnFile "Fil" 0
menuText O PgnFilePrint "Skriv til fil..." 0
menuText O PgnFileClose "Lukk PGN-vindu" 0
menuText O PgnOpt "Vis" 0
menuText O PgnOptColor "Vis farger" 0
menuText O PgnOptShort "Kort (3 linjer) header" 0
menuText O PgnOptSymbols "Symbolnotasjon" 0
menuText O PgnOptIndentC "Rykk inn kommentarer" 0
menuText O PgnOptIndentV "Rykk inn variasjoner" 0
menuText O PgnOptColumn "Bruk kolonner (ett trekk per linje)" 0
menuText O PgnOptSpace "Mellomrom etter trekknummer" 0
menuText O PgnOptStripMarks "Fjern fargekoder" 0
menuText O PgnColor "Farger" 0
menuText O PgnColorHeader "Header..." 0
menuText O PgnColorAnno "Annotasjoner..." 0
menuText O PgnColorComments "Kommentarer..." 0
menuText O PgnColorVars "Variasjoner..." 0
menuText O PgnColorBackground "Bakgrunn..." 0
menuText O PgnHelp "Hjelp" 0
menuText O PgnHelpPgn "PGN-hjelp" 0
menuText O PgnHelpIndex "Innholdsfortegnelse" 0
translate O PgnWindowTitle {PGN of game} ;# ***

# Crosstable window menus:
menuText O CrosstabFile "Fil" 0
menuText O CrosstabFileText "Skriv til tekstfil..." 0
menuText O CrosstabFileHtml "Skriv til HTML-fil..." 0
menuText O CrosstabFileLaTeX "Skriv til LaTeX-fil..." 0
menuText O CrosstabFileClose "Lukk krysstabellvindu" 0
menuText O CrosstabEdit "Rediger" 0
menuText O CrosstabEditEvent "Anledning" 0
menuText O CrosstabEditSite "Sted" 0
menuText O CrosstabEditDate "Dato" 0
menuText O CrosstabOpt "Vis" 0
menuText O CrosstabOptAll "Alle-mot-alle" 0
menuText O CrosstabOptSwiss "Sveitsisk" 0
menuText O CrosstabOptKnockout "Kun vinnere" 0
menuText O CrosstabOptAuto "Auto" 0
menuText O CrosstabOptAges "Aldre i år" 0
menuText O CrosstabOptNats "Nasjonaliteter" 0
menuText O CrosstabOptRatings "Ratinger" 0
menuText O CrosstabOptTitles "Titler" 0
menuText O CrosstabOptBreaks "Poengfordel" 0
menuText O CrosstabOptDeleted "Include deleted games" 8 ;# ***
menuText O CrosstabOptColors "Farger (kun sveitsisk)" 0
menuText O CrosstabOptColumnNumbers "Nummererte kolonner (kun alle-mot-alle-tabeller)" 0
menuText O CrosstabOptGroup "Gruppepoeng" 0
menuText O CrosstabSort "Sorter" 0
menuText O CrosstabSortName "Navn" 0
menuText O CrosstabSortRating "Rating" 0
menuText O CrosstabSortScore "Poeng" 0
menuText O CrosstabColor "Farge" 0
menuText O CrosstabColorPlain "Ren tekst" 0
menuText O CrosstabColorHyper "Hypertekst" 0
menuText O CrosstabHelp "Hjelp" 0
menuText O CrosstabHelpCross "Krysstabell hjelp" 0
menuText O CrosstabHelpIndex "Innholdsfortegnelse" 0
translate O SetFilter {Sett filter}
translate O AddToFilter {Legg til i filter}
translate O Swiss {Sveitsisk}
translate O Category {Category} ;# ***

# Opening report window menus:
menuText O OprepFile "Fil" 0
menuText O OprepFileText "Skriv til tekstfil..." 0
menuText O OprepFileHtml "Skriv til HTML-fil..." 0
menuText O OprepFileLaTeX "Skriv til LaTeX-fil..." 0
menuText O OprepFileOptions "Innstillinger..." 0
menuText O OprepFileClose "Lukk rapport-vindu" 0
menuText O OprepHelp "Hjelp" 0
menuText O OprepHelpReport "Åpningsrapport hjelp" 0
menuText O OprepHelpIndex "Innholdsfortegnelse" 0

# Repertoire editor:
menuText O RepFile "Fil" 0
menuText O RepFileNew "Ny" 0
menuText O RepFileOpen "Åpne..." 0
menuText O RepFileSave "Lagre..." 0
menuText O RepFileSaveAs "Lagre som..." 0
menuText O RepFileClose "Lukk vindu" 0
menuText O RepEdit "Rediger" 0
menuText O RepEditGroup "Legg til gruppe" 0
menuText O RepEditInclude "Inkluder" 0
menuText O RepEditExclude "Ekskluder" 0
menuText O RepView "Vis" 0
menuText O RepViewExpand "Utvid alle grupper" 0
menuText O RepViewCollapse "Trekk sammen alle grupper" 0
menuText O RepSearch "Søk" 0
menuText O RepSearchAll "Alle i reportoir..." 0
menuText O RepSearchDisplayed "Kun viste linjer..." 0
menuText O RepHelp "Hjelp" 0
menuText O RepHelpRep "Repertoir hjelp" 0
menuText O RepHelpIndex "Innholdsfortegnelse" 0
translate O RepSearch "Repertoirsøk"
translate O RepIncludedLines "inkluderte linjer"
translate O RepExcludedLines "ekskluderte linjer"
translate O RepCloseDialog {Gjeldende reportoir har ulagrede endringer.

Vil du virkelig fortsette og miste disse endringene?
}

# Header search:
translate O HeaderSearch {Headersøk}
translate O GamesWithNoECO {Partier uten ECO?}
translate O GameLength {Partilengde}
translate O FindGamesWith {Finn partier merket med...}
translate O StdStart {Vanlig utgangsstilling}
translate O Promotions {Forfremmelser}
translate O Comments {Kommentarer}
translate O Variations {Variasjoner}
translate O Annotations {Annotasjoner}
translate O DeleteFlag {Slettet}
translate O WhiteOpFlag {Hvit åpning}
translate O BlackOpFlag {Sort åpning}
translate O MiddlegameFlag {Midtspill}
translate O EndgameFlag {Sluttspill}
translate O NoveltyFlag {Avvik}
translate O PawnFlag {Bondestruktur}
translate O TacticsFlag {Taktikk}
translate O QsideFlag {Spill på dronningsiden}
translate O KsideFlag {Spill på kongesiden}
translate O BrilliancyFlag {Brillians}
translate O BlunderFlag {Tabbe}
translate O UserFlag {Bruker}
translate O PgnContains {PGN inneholder tekst}

# Game list window:
translate O GlistNumber {Nummer}
translate O GlistWhite {Hvit}
translate O GlistBlack {Sort}
translate O GlistWElo {H-Elo}
translate O GlistBElo {S-Elo}
translate O GlistEvent {Anledning}
translate O GlistSite {Sted}
translate O GlistRound {Runde}
translate O GlistDate {Dato}
translate O GlistYear {År}
translate O GlistEDate {AnledningDato}
translate O GlistResult {Resultat}
translate O GlistLength {Lengde}
translate O GlistCountry {Land}
translate O GlistECO {ECO}
translate O GlistOpening {Åpning}
translate O GlistEndMaterial {Slutt-kvalitet}
translate O GlistDeleted {Slettet}
translate O GlistFlags {Flagg}
translate O GlistVars {Variasjoner}
translate O GlistComments {Kommentarer}
translate O GlistAnnos {Annotasjoner}
translate O GlistStart {Start}
translate O GlistGameNumber {Parti nummer}
translate O GlistFindText {Finn tekst}
translate O GlistMoveField {Trekk}
translate O GlistEditField {Still inn}
translate O GlistAddField {Legg til}
translate O GlistDeleteField {Fjern}
translate O GlistWidth {Bredde}
translate O GlistAlign {Justering}
translate O GlistColor {Farge}
translate O GlistSep {Skilletegn}

# Maintenance window:
translate O DatabaseName {Databasenavn:}
translate O TypeIcon {Ikon:}
translate O NumOfGames {Partier:}
translate O NumDeletedGames {Slettede partier:}
translate O NumFilterGames {Partier i filter:}
translate O YearRange {Til/fra år:}
translate O RatingRange {Til/fra rating:}
translate O Description {Description} ;# ***
translate O Flag {Flagg}
translate O DeleteCurrent {Slett gjeldende parti}
translate O DeleteFilter {Slett filtrerte partier}
translate O DeleteAll {Slett alle partier}
translate O UndeleteCurrent {Gjenopprett gjeldende parti}
translate O UndeleteFilter {Gjenopprett filtrerte partier}
translate O UndeleteAll {Gjenopprett alle partier}
translate O DeleteTwins {Slett duplikatpartier}
translate O MarkCurrent {Merk gjeldende parti}
translate O MarkFilter {Merk filtrerte partier}
translate O MarkAll {Merk alle partier}
translate O UnmarkCurrent {Fjern merking på gjeldende parti}
translate O UnmarkFilter {Fjern merking på filtrerte partier}
translate O UnmarkAll {Fjern merking på alle partier}
translate O Spellchecking {Stavekontroll}
translate O Players {Spillere}
translate O Events {Anledninger}
translate O Sites {Steder}
translate O Rounds {Runder}
translate O DatabaseOps {Databasebehandling}
translate O ReclassifyGames {ECO-klassifiser partier}
translate O CompactDatabase {Komprimer database}
translate O SortDatabase {Sorter database}
translate O AddEloRatings {Legg til ELO-ratinger}
translate O AutoloadGame {Start med parti nummer}
translate O StripTags {Fjern PGN-merker}
translate O StripTag {Fjern merke}
translate O Cleaner {Opprydding}
translate O CleanerHelp {
Scid-opprydding vil utføre alle handlinger du velger fra listen under på gjeldende database.

Gjeldende innstillinger i ECO-klassifiseringen og duplikatslettingdialogene vil virke inn om du velger disse funksjonene.
}
translate O CleanerConfirm {
Når oppryddingen er i gang kan den ikke avbrytes!

Dette kan ta lang tid på en stor databse, avhengig av funksjonene du har valgt og disses gjeldende innstillinger.

Er du sikker på at du vil starte vedlikeholdsfunksjonene du har valgt?
}

# Comment editor:
translate O AnnotationSymbols  {Notasjonssymboler:}
translate O Comment {Kommentar:}
translate O InsertMark {Insert mark} ;# ***

# Board search:
translate O BoardSearch {Stillingsøk}
translate O FilterOperation {Operasjoner på gjeldende filter:}
translate O FilterAnd {AND (Kun på filter)}
translate O FilterOr {OR (Legg til filter)}
translate O FilterIgnore {IGNORE (Nullstill filter)}
translate O SearchType {Søketype:}
translate O SearchBoardExact {Nøyaktig stilling (alle brikker på samme felt)}
translate O SearchBoardPawns {Bønder (samme kvalitet, alle bønder på samme felt)}
translate O SearchBoardFiles {Kolonner (samme kvalitet, alle bønder på samme kolonner)}
translate O SearchBoardAny {Alle (samme kvalitet, bønder og brikker hvor som helst)}
translate O LookInVars {Søk i variasjoner}

# Material search:
translate O MaterialSearch {Kvalitetssøk}
translate O Material {Kvalitet}
translate O Patterns {Mønstre}
translate O Zero {Null}
translate O Any {Hvilke som helst}
translate O CurrentBoard {Gjeldende stilling}
translate O CommonEndings {Vanlige sluttspill}
translate O CommonPatterns {Vanlige mønstre}
translate O MaterialDiff {Kvalitetsforskjell}
translate O squares {felt}
translate O SameColor {Samme farge}
translate O OppColor {Motsatt farge}
translate O Either {Begge}
translate O MoveNumberRange {Fra/til trekk nummer}
translate O MatchForAtLeast {Treff i minst}
translate O HalfMoves {halvtrekk}

# Game saving:
translate O Today {I dag}
translate O ClassifyGame {Klassifiser parti}

# Setup position:
translate O EmptyBoard {Tøm brett}
translate O InitialBoard {Utgangsstilling}
translate O SideToMove {Side i trekk}
translate O MoveNumber {Trekk nummer}
translate O Castling {Rokkade}
translate O EnPassantFile {En Passant-kolonne}
translate O ClearFen {Slett FEN}
translate O PasteFen {Lim inn FEN}

# Replace move dialog:
translate O ReplaceMove {Erstatt trekk}
translate O AddNewVar {Legg til ny variasjon}
translate O ReplaceMoveMessage {Et trekk eksisterer allerede her.

Du kan erstatte det og slette alle følgende trekk, eller du kan legge det til som en variasjon.

(Du kan unngå denne meldingen i fremtiden ved å slå av Spør før trekk erstattes-innstillingen i Innstillinger:Trekk-menyen.)}

# Make database read-only dialog:
translate O ReadOnlyDialog {Hvis du skrivebeskytter denne databasen tillates ikke lenger endringer på den. Ingen partier kan lagres eller erstattes, og ingen sletteflagg kan endres. All sortering eller ECO-klassifisering vil være midlertidig.

Du kan enkelt slå av skrivebeskyttelsen på databasen ved å lukke og gjenåpne den.

Vil du virkelig skrivebeskytte denne databasen?}

# Clear game dialog:
translate O ClearGameDialog {Dette partiet har blitt endret.

Vil du virkelig forkaste endringene som er gjort?
}

# Exit dialog:
translate O ExitDialog {Vil du virkelig avslutte Scid?}
translate O ExitUnsaved {Følgende baser har ulagrede endringer i partier. Hvis du avslutter nå vil disse endringene gå tapt.}

# Import window:
translate O PasteCurrentGame {Lim inn gjeldende parti}
translate O ImportHelp1 {Skriv eller lim inn et PGN-parti i feltet over.}
translate O ImportHelp2 {Feil i importen vil vises her.}

# ECO Browser:
translate O ECOAllSections {alle ECO-deler}
translate O ECOSection {ECO-del}
translate O ECOSummary {Sammendrag for}
translate O ECOFrequency {Hyppighet eller underkoder for}

# Opening Report:
translate O OprepTitle {Åpningsrapport}
translate O OprepReport {Rapport}
translate O OprepGenerated {Generert av}
translate O OprepStatsHist {Statistikk og historie}
translate O OprepStats {Statistikk}
translate O OprepStatAll {Alle rapporterte partier}
translate O OprepStatBoth {Begge med rating}
translate O OprepStatSince {Siden}
translate O OprepOldest {Eldste partier}
translate O OprepNewest {Nyeste partier}
translate O OprepPopular {Trend}
translate O OprepFreqAll {Frekvens i år:   }
translate O OprepFreq1   {Det siste året: }
translate O OprepFreq5   {De siste 5 årene: }
translate O OprepFreq10  {De siste 10 årene: }
translate O OprepEvery {hvert %u parti}
translate O OprepUp {opp %u%s fra alle år}
translate O OprepDown {ned %u%s fra alle år}
translate O OprepSame {ingen endring fra alle år}
translate O OprepMostFrequent {Hyppigste spillere}
translate O OprepRatingsPerf {Ratinger og resultater}
translate O OprepAvgPerf {Middelratinger og -resultater}
translate O OprepWRating {Hvit rating}
translate O OprepBRating {Sort rating}
translate O OprepWPerf {Hvite resultater}
translate O OprepBPerf {Sorte resultater}
translate O OprepHighRating {Parti med høyeste gjennomsnittsrating}
translate O OprepTrends {Resultattrend}
translate O OprepResults {Resultatlengde og -hyppighet}
translate O OprepLength {Partilengde}
translate O OprepFrequency {Hyppighet}
translate O OprepWWins {Hvit vinner: }
translate O OprepBWins {Sort vinner: }
translate O OprepDraws {Uavgjort:      }
translate O OprepWholeDB {hele databasen}
translate O OprepShortest {Korteste seire}
translate O OprepMovesThemes {Trekk og temaer}
translate O OprepMoveOrders {Trekkrekkefølger til rapportert stilling}
translate O OprepMoveOrdersOne \
  {Det var kun en trekkrekkefølge som førte til denne stillingen:}
translate O OprepMoveOrdersAll \
  {Det var %u trekkrekkefølger som førte til denne stillingen:}
translate O OprepMoveOrdersMany \
  {There were %u move orders reaching this position. The top %u are:}
translate O OprepMovesFrom {Trekk fra rapportert stilling}
translate O OprepThemes {Stillingstemaer}
translate O OprepThemeDescription {Hyppighet av tema i trekk %u}
translate O OprepThemeSameCastling {Rokkade til samme side}
translate O OprepThemeOppCastling {Rokkade til motsatt side}
translate O OprepThemeNoCastling {Ingen konger rokert}
translate O OprepThemeKPawnStorm {Bondestorm på kongesiden}
translate O OprepThemeQueenswap {Byttede dronninger}
translate O OprepThemeIQP {Isolert dronningbonde}
translate O OprepThemeWP567 {Hvit bonde på rekke 5/6/7}
translate O OprepThemeBP234 {Sort bonde på rekke 2/3/4}
translate O OprepThemeOpenCDE {Åpen c/d/e-kolonne}
translate O OprepTheme1BishopPair {Kun en side har to løpere}
translate O OprepEndgames {Sluttspill}
translate O OprepReportGames {Rapporterte partier}
translate O OprepAllGames    {Alle partier}
translate O OprepEndClass {Materiale i sluttspillet}
translate O OprepTheoryTable {Teoritabell}
translate O OprepTableComment {Generert fra de %u høyest ratede partiene.}
translate O OprepExtraMoves {Ytterligere trekk notert i teoritabellen}
translate O OprepMaxGames {Maksimalt antall partier i teoritabellen}

# Piece Tracker window:
translate O TrackerSelectSingle {Venstre museknapp merker denne brikken}
translate O TrackerSelectPair {Venstre museknapp merker denne brikken; høyre merker alle brikker av denne typen.}
translate O TrackerSelectPawn {Venstre museknapp merker denne brikken; høyre merker alle brikker av denne typen.}
translate O TrackerStat {Statistikk}
translate O TrackerGames {% partier med trekk til felt}
translate O TrackerTime {% tid på hvert felt}
translate O TrackerMoves {Trekk}
translate O TrackerMovesStart {Oppgi trekket hvor sporingen skal begynne.}
translate O TrackerMovesStop {Oppgi trekket hvor sporingen skal stoppe.}

# Game selection dialogs:
translate O SelectAllGames {Alle partier i databasen}
translate O SelectFilterGames {Kun partier i filteret}
translate O SelectTournamentGames {Kun partier i gjeldende turnering}
translate O SelectOlderGames {Kun eldre partier}

# Delete Twins window:
translate O TwinsNote {For å være duplikater må to partier minst ha de samme to spillerene, og kriterier du kan angi under. Når to duplikater finnes blir det korteste partiet slettet. Tips: Det er best å kjøre en stavekontroll før duplikatsjekken, da det forbedrer søket.}
translate O TwinsCriteria {Kriterier: Duplikater må ha...}
translate O TwinsWhich {Undersøk hvilke partier}
translate O TwinsColors {Spillere samme farge?}
translate O TwinsEvent {Samme anledning?}
translate O TwinsSite {Samme sted?}
translate O TwinsRound {Samme runde?}
translate O TwinsYear {Samme år?}
translate O TwinsMonth {Samme måned?}
translate O TwinsDay {Samme dag?}
translate O TwinsResult {Samme utfall?}
translate O TwinsECO {Samme ECO-kode?}
translate O TwinsMoves {Samme trekk?}
translate O TwinsPlayers {Sammenlign spillernavn:}
translate O TwinsPlayersExact {Nøyaktig like}
translate O TwinsPlayersPrefix {Kun første 4 bokstaver}
translate O TwinsWhen {Når duplikatpartier slettes}
translate O TwinsSkipShort {Overse alle partier kortere enn 5 trekk?}
translate O TwinsUndelete {Gjenopprett alle partier først?}
translate O TwinsSetFilter {Sett filter til alle slettede duplikatpartier?}
translate O TwinsComments {Behold alltid partier med kommentarer?}
translate O TwinsVars {Behold alltid partier med variasjoner?}
translate O TwinsDeleteWhich {Slett hvilket parti:}
translate O TwinsDeleteShorter {Korteste parti}
translate O TwinsDeleteOlder {Laveste partinummer}
translate O TwinsDeleteNewer {Høyeste partinummer}
translate O TwinsDelete {Slett partier}

# Name editor window:
translate O NameEditType {Navnetype som skal redigeres}
translate O NameEditSelect {Partier som skal redigeres}
translate O NameEditReplace {Erstatt}
translate O NameEditWith {med}
translate O NameEditMatches {Treff: Trykk Ctrl+1 til Ctrl+9 for å velge}

# Classify window:
translate O Classify {Klassifiser}
translate O ClassifyWhich {ECO-klassifiser hvilke partier}
translate O ClassifyAll {Alle partier (overskriv gamle ECO-koder)}
translate O ClassifyYear {Aller partier det siste året}
translate O ClassifyMonth {Alle partier den siste måneden}
translate O ClassifyNew {Kun partier uten ECO-kode}
translate O ClassifyCodes {ECO-koder som skal brukes}
translate O ClassifyBasic {Kun standardkoder ("B12", ...)}
translate O ClassifyExtended {Scid-utvidet ("B12j", ...)}

# Compaction:
translate O NameFile {Navnefil}
translate O GameFile {Partifil}
translate O Names {Navn}
translate O Unused {Ubrukte}
translate O SizeKb {Størrelse (kb)}
translate O CurrentState {Nåværende}
translate O AfterCompaction {Etter komprimering}
translate O CompactNames {Komrimer navnefil}
translate O CompactGames {Komprimer partifil}

# Sorting:
translate O SortCriteria {Kriterier}
translate O AddCriteria {Legg til kriterie}
translate O CommonSorts {Vanlige sorteringer}
translate O Sort {Sorter}

# Exporting:
# These lines do not use the excact notation of the original english.tcl, because this would cause inconsistency with the PGN window menus
translate O AddToExistingFile {Legg partier til en eksisterende fil}
translate O ExportComments {Eksporter kommentarer}
translate O ExportVariations {Eksporter variasjoner}
translate O IndentComments {Rykk inn kommentarer}
translate O IndentVariations {Rykk inn variasjoner}
translate O ExportColumnStyle {Bruk kolonner (ett trekk per linje)}
translate O ExportSymbolStyle {Symbolnotasjoner}
translate O ExportStripMarks {Fjern alle fargekoder og piler fra kommentarer?}

# Goto game/move dialogs:
translate O LoadGameNumber {Angi partinummer som skal lastes inn:}
translate O GotoMoveNumber {Gå til trekk nummer:}

# Copy games dialog:
translate O CopyGames {Kopier partier}
translate O CopyConfirm {
Vil du virkelig kopiere de [thousands $nGamesToCopy] filtrerte partiene fra "$fromName"
 til databasen "$targetName"?
}
translate O CopyErr {Kan ikke kopiere partiene}
translate O CopyErrSource {kildedatabasen}
translate O CopyErrTarget {måldatabasen}
translate O CopyErrNoGames {har ingen partier i sitt filter}
translate O CopyErrReadOnly {er skrivebeskyttet}
translate O CopyErrNotOpen {er ikke åpnet}

# Colors:
translate O LightSquares {Lyse felt}
translate O DarkSquares {Mørke felt}
translate O SelectedSquares {Merkede felt}
translate O SuggestedSquares {Foreslåtte trekkfelt}
translate O WhitePieces {Hvite brikker}
translate O BlackPieces {Sorte brikker}
translate O WhiteBorder {Hvit ramme}
translate O BlackBorder {Sort ramme}

# Novelty window:
translate O FindNovelty {Finn avvik}
translate O Novelty {Avvik}
translate O NoveltyInterrupt {Avvikssøk avbrutt}
translate O NoveltyNone {Ingen avvik ble funnet i dette partiet}
translate O NoveltyHelp {
Scid vil finne det første trekket i det gjeldende partiet som fører til en stilling som ikke finnes i den valgte databasen eller i ECO-åpningsboken.}

# Upgrading databases:
translate O Upgrading {Oppgraderer}
translate O ConfirmOpenNew {
Dette er en database i gammelt format (Scid 2) som ikke kan åpnes i Scid 3, men en ny versjon (Scid 3) har allerede blitt opprettet.

Vil du åpne versjonen som er i det nye formatet?
}
translate O ConfirmUpgrade {
Dette er en database i gammelt format (Scid2). En versjon i nytt format må opprettes før den kan brukes i Scid 3.

Oppgradering vil opprette en ny versjon av databasen; det vil ikke redigere eller slette de opprinnelige filene.

Dette kan ta en stund, men det trenger kun å gjøres en gang. Du kan avbryte om det tar for lang tid.

Ønsker du å oppgradere databasen nå?
}

# Recent files options:
translate O RecentFilesMenu {Number of recent files in File menu} ;# ***
translate O RecentFilesExtra {Number of recent files in extra submenu} ;# ***

}

# norsk.tcl

# Sjekkliste:
# - Snarveier

