### serbian.tcl:
# Serbian menus for Scid.
# Contributed by Milos Pejovic.

addLanguage Y Serbian 2 iso8859-2

proc setLanguage_Y {} {

# File menu:
menuText Y File "Fajl" 0
menuText Y FileNew "Novi..." 0 {Kreiraj novu Scid bazu podataka}
menuText Y FileOpen "Otvori..." 0 {Otvori postojeæu Scid bazu podataka}
menuText Y FileClose "Zatvori" 0 {Zatvori aktivnu Scid bazu podataka}
menuText Y FileFinder "Tragaè" 0 {Pokreni Fajl Tragaè}
menuText Y FileBookmarks "Markeri" 0 {Meni sa markerima (preèica: Ctrl+B)}
menuText Y FileBookmarksAdd "Dodaj u markere" 0 \
  {Dodaj u markere tekuæu partiju iz baze i poziciju}
menuText Y FileBookmarksFile "Arhiviraj marker" 0 \
  {Arhiviraj marker za tekuæu partiju i poziciju}
menuText Y FileBookmarksEdit "Izmeni markere..." 0 \
  {Izmeni menije markera}
menuText Y FileBookmarksList "Prika¾i foldere kao jedinstvenu listu" 0 \
  {Prika¾i foldere markera kao jedinstvenu listu, bez podmenija}
menuText Y FileBookmarksSub "Prika¾i foldere kao podmenije" 0 \
  {Prika¾i foldere markera kao podmenije, ne jedinstvenu listu}
menuText Y FileMaint "Odr¾avanje" 0 {Alati za odr¾avanje Scid baze podataka}
menuText Y FileMaintWin "Prozor odr¾avanja" 0 \
  {Otvori/zatvori prozor odr¾avanja Scid baze podataka}
menuText Y FileMaintCompact "Komprimuj bazu..." 0 \
  {Uèini fajlove baze kompaktnijim, uklanjajuæi obrisane partije i nekori¹æena imena}
menuText Y FileMaintClass "E©O-Klasifikacija partija..." 2 \
  {Klasifikacija svih partija po otvaranju}
menuText Y FileMaintSort "Sortiraj bazu..." 0 \
  {Sortiraj sve partije u bazi podataka}
menuText Y FileMaintDelete "Izbri¹i udvojene partije..." 0 \
  {Naði udvojene partije i oznaèi ih za brisanje}
menuText Y FileMaintTwin "Provera udvojenih partija" 0 \
  {Otvori/osve¾i prozor za proveru udvojenih partija}
menuText Y FileMaintName "Imena" 0 {Promena imena i kontrola pravopisa}
menuText Y FileMaintNameEditor "Editor imena" 0 \
  {Otvori/zatvori editor imena}
menuText Y FileMaintNamePlayer "Provera pravopisa imena igraèa..." 11 \
  {Provera pravopisa imena igraèa pomoæu spellcheck fajla}
menuText Y FileMaintNameEvent "Provera pravopisa imena turnira..." 11 \
  {Provera pravopisa imena turnira pomoæu spellcheck fajla}
menuText Y FileMaintNameSite "Provera pravopisa imena mesta..." 11 \
  {Provera pravopisa imena mesta pomoæu spellcheck fajla}
menuText Y FileMaintNameRound "Provera pravopisa kola..." 11 \
  {Provera pravopisa kola pomoæu spellcheck fajla}
menuText Y FileReadOnly "Read-only..." 0 \
  {Spreèi izmene u tekuæoj bazi}
menuText Y FileExit "Izaði" 1 {Izlazak iz Scid-a}

# Edit menu:
menuText Y Edit "Izmene" 0
menuText Y EditAdd "Dodaj varijantu" 0 {Dodaj varijantu potezu u partiji}
menuText Y EditDelete "Obri¹i varijantu" 0 {Obri¹i varijantu za ovaj potez}
menuText Y EditFirst "Postavi prvu varijantu" 5 \
  {Postavi varijantu kao prvu u listi}
menuText Y EditMain "Postavi varijantu na glavnu liniju" 21 \
  {Postavi varijantu na glavnu liniju}
menuText Y EditTrial "Probaj varijantu" 0 \
  {Pokreni/zaustavi mod za testiranje ideje na tabli}
menuText Y EditStrip "Ukloni" 2 {Ukloni komentare ili varijante iz ove partije}
menuText Y EditStripComments "Komentare" 0 \
  {Ukloni sve komentare i napomene iz ove partije}
menuText Y EditStripVars "Varijante" 0 {Ukloni sve varijante iz ove partije}
menuText Y EditReset "Isprazni Clipbase" 0 \
  {Resetuje clipbase da bude potpuno prazan}
menuText Y EditCopy "Kopiraj ovu partiju na Clipbase" 0 \
  {Kopiraj ovu partiju na clipbase partija}
menuText Y EditPaste "Prenesi poslednju clipbase partiju" 0 \
  {Prenesi aktivnu clipbase partiju ovde}
menuText Y EditSetup "Namesti poèetnu poziciju..." 0 \
  {Namesti poèetnu poziciju za ovu partiju}
menuText Y EditPasteBoard "Prenesi poèetnu poziciju" 9 \
  {Postavi poèetnu poziciju na osnovu trenutno izabranog teksta (klipbord)}

# Game menu:
menuText Y Game "Partija" 0
menuText Y GameNew "Nova partija" 0 \
  {Pokreni novu partiju, sa gubljenjem svih izmena}
menuText Y GameFirst "Uèitaj prvu partiju" 5 {Uèitaj prvu filtriranu partiju}
menuText Y GamePrev "Uèitaj prethodnu partiju" 5 {Uèitaj prethodnu filtriranu partiju}
menuText Y GameReload "Osve¾i trenutnu partiju" 3 \
  {Osve¾i ovu partiju, sa gubljenjem svih izmena}
menuText Y GameNext "Uèitaj sledeæu partiju" 5 {Uèitaj sledeæu filtriranu partiju}
menuText Y GameLast "Uèitaj poslednju partiju" 8 {Uèitaj poslednju filtriranu partiju}
menuText Y GameNumber "Uèitaj partiju broj..." 5 \
  {Uèitaj partiju, unoseæi njen broj}
menuText Y GameReplace "Saèuvaj: Zameni partiju..." 6 \
  {Saèuvaj ovu partiju preko stare partiju u bazi}
menuText Y GameAdd "Saèuvaj: Dodaj novu partiju..." 6 \
  {Saèuvaj ovu partiju kao novu u bazi}
menuText Y GameDeepest "Identifikuj otvaranje" 0 \
  {Idi na poslednju poziciju partije koja odgovara knjizi otvaranja}
menuText Y GameGotoMove "Idi na potez broj..." 5 \
  {Idi na odreðeni broj potez u tekuæoj partiji}
menuText Y GameNovelty "Pronaði novost..." 8 \
  {Pronaði prvi potez ove partije koji nije igran ranije}

# Search Menu:
menuText Y Search "Pretra¾i" 3
menuText Y SearchReset "Resetuj filter" 0 {Resetuj filter da bi sve partije bile ukljuèene}
menuText Y SearchNegate "Invertuj filter" 0 {Invertuj filter da ukljuèi samo iskljuèene partije}
menuText Y SearchCurrent "Tekuæa pozicija..." 0 {Pretra¾uj prema tekuæoj poziciji na tabli}
menuText Y SearchHeader "Zaglavlje..." 0 {Pretra¾uj prema informacijama iz zaglavlja (igraè, turnir, itd)}
menuText Y SearchMaterial "Materijal/Pozicije..." 0 {Pretra¾uj prema materijalu i poziciji}
menuText Y SearchUsing "Pomoæu Search fajla..." 0 {Pretra¾uj pomoæu Search fajla}

# Windows menu:
menuText Y Windows "Prozori" 1
menuText Y WindowsComment "Editor komentara" 0 {Otvori/zatvori editor komentara}
menuText Y WindowsGList "Lista partija" 0 {Otvori/zatvori listu partija}
menuText Y WindowsPGN "PGN prozor" 0 \
  {Otvori/zatvori PGN prozor (sa podacima o partiji)}
menuText Y WindowsTmt "Turnir tragaè" 2 {Otvori/zatvori turnir tragaè}
menuText Y WindowsSwitcher "Biraè baza" 0 \
  {Otvori/zatvori biraè baza}
menuText Y WindowsMaint "Prozor odr¾avanja" 0 \
  {Otvori/zatvori prozor odr¾avanja}
menuText Y WindowsECO "E©O prikazivaè" 0 {Otvori/zatvori E©O prikazivaè}
menuText Y WindowsRepertoire "Editor repertoara otvaranja" 0 \
  {Otvori/zatvori editor repertoara otvaranja}
menuText Y WindowsStats "Statistièki prozor" 0 \
  {Otvori/zatvori prozor statistika filtera}
menuText Y WindowsTree "Stablo varijanata" 0 {Otvori/zatvori stablo varijanata}
menuText Y WindowsTB "Tabela zavr¹nica" 1 \
  {Otvori/zatvori tabelu zavr¹nica}

# Tools menu:
menuText Y Tools "Alati" 0
menuText Y ToolsAnalysis "Program za analizu..." 0 \
  {Pokreni/zaustavi ¹ahovski program za analizu}
menuText Y ToolsAnalysis2 "Program za analizu #2..." 17 \
  {Pokreni/zaustavi drugi ¹ahovski program za analizu}
menuText Y ToolsCross "Tabela turnira" 0 {Poka¾i tabelu turnira za ovu partiju}
menuText Y ToolsEmail "Email menad¾er" 0 \
  {Otvori/zatvori menad¾er za korespodentske partije preko email-a}
menuText Y ToolsFilterGraph "Filter graph" 7 \
  {Open/close the filter graph window} ;# ***
menuText Y ToolsOpReport "Izve¹taj o otvaranjima" 0 \
  {Napravi izve¹taj o otvaranjima za trenutnu poziciju}
menuText Y ToolsTracker "Piece Tracker"  0 {Open the Piece Tracker window} ;# ***
menuText Y ToolsPInfo "Informacije o igraèu"  0 \
  {Otvori/osve¾i informacije o igraèu}
menuText Y ToolsRating "Grafikon rejtinga" 0 \
  {Iscrtava grafik istorije rejtinga igraèa u tekuæoj partiji}
menuText Y ToolsScore "Grafikon skora" 0 {Prika¾i grafikon skora}
menuText Y ToolsExpCurrent "Izvezi tekuæu partiju" 8 \
  {Snimi tekuæu partiju u tekstualni fajl}
menuText Y ToolsExpCurrentPGN "Izvezi partiju u PGN fajl..." 17 \
  {Snimi tekuæu partiju u PGN fajl}
menuText Y ToolsExpCurrentHTML "Izvezi partiju u HTML fajl..." 17 \
  {Snimi tekuæu partiju u HTML fajl}
menuText Y ToolsExpCurrentLaTeX "Izvezi partiju u LaTeX fajl..." 17 \
  {Snimi tekuæu partiju u LaTeX fajl}
menuText Y ToolsExpFilter "Izvezi sve filtrirane partije" 1 \
  {Snimi sve filtrirane partije u tekstualni fajl}
menuText Y ToolsExpFilterPGN "Izvezi filtrirane partije u PGN fajl..." 28 \
  {Snimi sve filtrirane partije u PGN fajl}
menuText Y ToolsExpFilterHTML "Izvezi filtrirane partije u HTML fajl..." 28 \
  {Snimi sve filtrirane partije u HTML fajl}
menuText Y ToolsExpFilterLaTeX "Izvezi filtrirane partije u LaTeX fajl..." 28 \
  {Snimi sve filtrirane partije u LaTeX fajl}
menuText Y ToolsImportOne "Uvezi jednu PGN partiju..." 0 \
  {Uvezi jednu partiju iz PGN fajla}
menuText Y ToolsImportFile "Uvezi vi¹e PGN partija..." 6 \
  {Uvezi vi¹e partija iz PGN fajla}

# Options menu:
menuText Y Options "Opcije" 0
menuText Y OptionsSize "Velièina table" 0 {Promeni velièinu table}
menuText Y OptionsPieces "Board Piece Style" 6 \
  {Change the board piece style} ;# ***
menuText Y OptionsColors "Boje" 0 {Promeni boje table}
menuText Y OptionsExport "Izvoz" 0 {Promeni opcije tekstualnog izvoza}
menuText Y OptionsFonts "Fontovi" 0 {Promeni fontove}
menuText Y OptionsFontsRegular "Obièan" 0 {Promeni obièan font}
menuText Y OptionsFontsSmall "Mali" 0 {Promeni mali font}
menuText Y OptionsFontsFixed "Neproporcionalni" 0 {Promeni neproporcionalni font}
menuText Y OptionsGInfo "Informacije o Partiji" 0 {Opcije informacija o partiji}
menuText Y OptionsLanguage "Jezik" 0 {Izaberi jezik}
menuText Y OptionsMoves "Potezi" 0 {Opcije uno¹enja poteza}
menuText Y OptionsMovesAsk "Pitaj pre zamene poteza" 0 \
  {Pitaj, da li se mo¾e postojeæi zameniti novim potezom}
menuText Y OptionsMovesDelay "Odlaganje izmeðu poteza..." 1 \
  {Podesi vreme odlaganja pri automatskom pregledanju poteza}
menuText Y OptionsMovesCoord "Uno¹enje koordinata poteza" 0 \
  {Prihvati uno¹enje poteza pomoæu koordinata ("g1f3")}
menuText Y OptionsMovesSuggest "Poka¾i preporuèene poteze" 0 \
  {Ukljuèi/iskljuèi preporuèene poteze}
menuText Y OptionsMovesKey "Dopunjavanje poteza" 0 \
  {Ukljuèi/iskljuèi dopunjavanje poteza zadatih tastaturom}
menuText Y OptionsNumbers "Format brojeva" 0 {Izaberi format brojeva}
menuText Y OptionsStartup "Startup" 3 {Select windows to open at startup} ;# ***
menuText Y OptionsWindows "Prozori" 0 {Opcije prozora}
menuText Y OptionsWindowsIconify "Auto-iconify" 5 \
  {Iconify all windows when the main window is iconified} ;# ***
menuText Y OptionsWindowsRaise "Auto podizanje" 0 \
  {Podigni odreðene prozore kad god su pokriveni}
menuText Y OptionsToolbar "Toolbar glavnog prozora" 12 \
  {Prika¾i/sakrij toolbar glavnog prozora}
menuText Y OptionsECO "Uèitaj E©O fajl..." 7 {Uèitaj E©O klasifikacioni fajl}
menuText Y OptionsSpell "Uèitaj fajl za kontrolu pravopisa..." 13 \
  {Uèitaj fajl za kontrolu pravopisa}
menuText Y OptionsTable "Direktorijum baza zavr¹nica..." 0 \
  {Izaberi fajl baze zavr¹nica; sve baze u direktorijumu æe biti kori¹æene}
menuText Y OptionsSave "Saèuvaj opcije" 0 \
  "Saèuvaj sve opcije u fajl $::optionsFile"
menuText Y OptionsAutoSave "Auto-saèuvaj opcije na izlasku" 0 \
  {Auto-saèuvaj sve opcije pri izlasku iz Scid-a}

# Help menu:
menuText Y Help "Pomoæ" 2
menuText Y HelpIndex "Sadr¾aj" 0 {Prika¾i glavnu stranu pomoæi}
menuText Y HelpGuide "Brzi vodiè" 0 {Prika¾i brzi vodiè}
menuText Y HelpHints "Saveti" 0 {Prika¾i savete}
menuText Y HelpContact "Kontakt" 0 {Prika¾i informacije o kontaktu}
menuText Y HelpTip "Tip of the day" 0 {Show a useful Scid tip} ;# ***
menuText Y HelpStartup "Startup prozor" 0 {Prika¾i startup prozor}
menuText Y HelpAbout "O programu Scid" 0 {Informacije o programu Scid}

# Game info box popup menu:
menuText Y GInfoHideNext "Sakrij sledeæi potez" 0
menuText Y GInfoMaterial "Prika¾i vrednosti materijala" 0
menuText Y GInfoFEN "Prika¾i FEN" 8
menuText Y GInfoMarks "Show colored squares and arrows" 5 ;# ***
menuText Y GInfoWrap "Prelomi dugaèke linije" 0
menuText Y GInfoFullComment "Show Full Comment" 10 ;# ***
menuText Y GInfoTBNothing "Baza zavr¹nica: ni¹ta" 16
menuText Y GInfoTBResult "Baza zavr¹nica: samo rezultati" 16
menuText Y GInfoTBAll "Baza zavr¹nica: rezultat i najbolji potezi" 16
menuText Y GInfoDelete "Obri¹i/vrati ovu partiju" 0
menuText Y GInfoMark "Mark/Unmark this game" 0 ;# ***

# Main window buttons:
helpMsg Y .button.start {Idi na poèetak partije  (taster: Home)}
helpMsg Y .button.end {Idi na kraj partije  (taster: End)}
helpMsg Y .button.back {Idi jedan potez nazad  (taster: Levo)}
helpMsg Y .button.forward {Idi jedan potez napred  (taster: Desno)}
helpMsg Y .button.intoVar {Preði na varijantu  (taster preèica: v)}
helpMsg Y .button.exitVar {Ostavi tekuæu varijantu  (taster preèica: z)}
helpMsg Y .button.flip {Rotiraj tablu  (taster preèica: .)}
helpMsg Y .button.coords {Ukljuèi/iskljuèi koordinate table  (taster preèica: 0)}
helpMsg Y .button.autoplay {Automatski menjaj poteze  (taster: Ctrl+Z)}

# General buttons:
translate Y Back {Nazad}
translate Y Cancel {Poni¹ti}
translate Y Clear {Oèisti}
translate Y Close {Zatvori}
translate Y Defaults {Podrazumevano}
translate Y Delete {Obri¹i}
translate Y Graph {Grafikon}
translate Y Help {Pomoæ}
translate Y Import {Uvoz}
translate Y Index {Indeks}
translate Y LoadGame {Uèitaj partiju}
translate Y BrowseGame {Browse game} ;# ***
translate Y MergeGame {Merge game} ;# ***
translate Y Preview {Preview} ;# ***
translate Y Revert {Vrati se}
translate Y Save {Saèuvaj}
translate Y Search {Tra¾i}
translate Y Stop {Stop}
translate Y Store {Saèuvaj}
translate Y Update {Osve¾i}
translate Y ChangeOrient {Promeni orijentaciju prozora}
translate Y None {None} ;# ***
translate Y First {Prvu}
translate Y Current {Trenutna}
translate Y Last {Poslednju}

# General messages:
translate Y game {partija}
translate Y games {partije}
translate Y move {potez}
translate Y moves {potezi}
translate Y all {sve}
translate Y Yes {Da}
translate Y No {Ne}
translate Y Both {Oba}
translate Y King {Kralj}
translate Y Queen {Dama}
translate Y Rook {Top}
translate Y Bishop {Lovac}
translate Y Knight {Skakaè}
translate Y Pawn {Pe¹ak}
translate Y White {Beli}
translate Y Black {Crni}
translate Y Player {Igraè}
translate Y Rating {Rejting}
translate Y RatingDiff {Razlika u rejtingu (Beli - Crni)}
translate Y Event {Turnir}
translate Y Site {Mesto}
translate Y Country {Zemlja}
translate Y IgnoreColors {Ignori¹i boje}
translate Y Date {Datum}
translate Y EventDate {Datum turnira}
translate Y Decade {Decade} ;# ***
translate Y Year {Godina}
translate Y Month {Mesec}
translate Y Months {Januar Februar Mart April Maj Jun
  Jul Avgust Septembar Oktobar Novembar Decembar}
translate Y Days {Ned Pon Uto Sre Èet Pet Sub}
translate Y YearToToday {Godina do danas}
translate Y Result {Rezultat}
translate Y Round {Kolo}
translate Y Length {Du¾ina}
translate Y ECOCode {E©O kôd}
translate Y ECO {E©O}
translate Y Deleted {Izbrisano}
translate Y SearchResults {Tra¾i rezultate}
translate Y OpeningTheDatabase {Otvaranje baze}
translate Y Database {Baza}
translate Y Filter {Filter}
translate Y noGames {ni jedna partija}
translate Y allGames {sve partije}
translate Y empty {prazno}
translate Y clipbase {clipbase}
translate Y score {skor}
translate Y StartPos {Poèetna pozicija}
translate Y Total {Ukupno}

# Game information:
translate Y twin {udvojena}
translate Y deleted {izbrisana}
translate Y comment {komentar}
translate Y hidden {sakrivena}
translate Y LastMove {Poslednji potez}
translate Y NextMove {Sledeæi}
translate Y GameStart {Poèetak partije}
translate Y LineStart {Poèetak serije poteza}
translate Y GameEnd {Kraj partije}
translate Y LineEnd {Kraj serije poteza}

# Player information:
translate Y PInfoAll {Rezultati <b>svih</b> partija}
translate Y PInfoFilter {Rezultati <b>filtriranih</b> partija}
translate Y PInfoAgainst {Rezultati protiv}
translate Y PInfoMostWhite {Najèe¹æe igrana otvaranja sa belim figurama}
translate Y PInfoMostBlack {Najèe¹æe igrana otvaranja sa crnim figurama}
translate Y PInfoRating {Istorija rejtinga}
translate Y PInfoBio {Biography} ;# ***

# Tablebase information:
translate Y Draw {Remi}
translate Y stalemate {pat}
translate Y withAllMoves {sa svim potezima}
translate Y withAllButOneMove {sa svim osim jednog poteza}
translate Y with {sa}
translate Y only {samo}
translate Y lose {gubi}
translate Y loses {gubi}
translate Y allOthersLose {svi ostali gube}
translate Y matesIn {matira u}
translate Y hasCheckmated {je matirao}
translate Y longest {najdu¾i}

# Tip of the day:
translate Y Tip {Tip} ;# ***
translate Y TipAtStartup {Tip at startup} ;# ***

# Tree window menus:
menuText Y TreeFile "Fajl" 0
menuText Y TreeFileSave "Saèuvaj cache fajl" 0 {Saèuvaj cache (.stc) fajl stabla}
menuText Y TreeFileFill "Ispuni cache fajl" 0 \
  {Ispuni cache fajl èestim pozicijama otvaranja}
menuText Y TreeFileBest "Lista najboljih partija" 0 {Prika¾i listu najboljih partija stabla}
menuText Y TreeFileGraph "Prozor grafika" 0 {Prika¾i grafik za ovu granu stabla}
menuText Y TreeFileCopy "Kopiraj tekst stabla u clipboard" 0 \
  {Kopiraj statistike stabla u clipboard}
menuText Y TreeFileClose "Zatvori stablo varijanata" 0 {Zatvori prozor stabla}
menuText Y TreeSort "Sortiraj" 0
menuText Y TreeSortAlpha "Abecedno" 0
menuText Y TreeSortECO "E©O kôd" 0
menuText Y TreeSortFreq "Uèestalost" 0
menuText Y TreeSortScore "Skor" 0
menuText Y TreeOpt "Opcije" 0
menuText Y TreeOptLock "Zakljuèaj" 0 {Zakljuèaj/otkljuèaj stablo za tekuæu bazu}
menuText Y TreeOptTraining "Trening" 0 {Ukljuèi/iskljuèi trening mod stabla}
menuText Y TreeOptAutosave "Automatski saèuvaj cache fajl" 0 \
  {Automatski saèuvaj cache fajl pri zatvaranju prozora stabla}
menuText Y TreeHelp "Pomoæ" 0
menuText Y TreeHelpTree "Pomoæ za stablo" 0
menuText Y TreeHelpIndex "Sadr¾aj pomoæi" 0
translate Y SaveCache {Saèuvaj cache}
translate Y Training {Trening}
translate Y LockTree {Zakljuèaj}
translate Y TreeLocked {zakljuèano}
translate Y TreeBest {Najbolje}
translate Y TreeBestGames {Najbolje partije stabla}

# Finder window:
menuText Y FinderFile "Fajl" 0
menuText Y FinderFileSubdirs "Pogledaj u poddirektorijumima" 0
menuText Y FinderFileClose "Zatvori Fajl tragaè" 0
menuText Y FinderSort "Sortiraj" 0
menuText Y FinderSortType "Tip" 0
menuText Y FinderSortSize "Velièina" 0
menuText Y FinderSortMod "Modifikovano" 0
menuText Y FinderSortName "Ime" 0
menuText Y FinderSortPath "Staza" 0
menuText Y FinderTypes "Tipovi" 0
menuText Y FinderTypesScid "Scid baze" 0
menuText Y FinderTypesOld "Scid baze u starom formatu" 0
menuText Y FinderTypesPGN "PGN fajlovi" 0
menuText Y FinderTypesEPD "EPD (book) fajlovi" 0
menuText Y FinderTypesRep "Repertoar fajlovi" 0
menuText Y FinderHelp "Pomoæ" 0
menuText Y FinderHelpFinder "Pomoæ - Fajl tragaè" 0
menuText Y FinderHelpIndex "Sadr¾aj pomoæi" 0
translate Y FileFinder {Fajl tragaè}
translate Y FinderDir {Direktorijum}
translate Y FinderDirs {Direktorijumi}
translate Y FinderFiles {Fajlovi}
translate Y FinderUpDir {gore}

# Tournament finder:
menuText Y TmtFile "Fajl" 0
menuText Y TmtFileUpdate "Osve¾i" 0
menuText Y TmtFileClose "Zatvori Turnir tragaè" 0
menuText Y TmtSort "Sortiraj" 0
menuText Y TmtSortDate "Datum" 0
menuText Y TmtSortPlayers "Igraèi" 0
menuText Y TmtSortGames "Partije" 0
menuText Y TmtSortElo "Elo" 0
menuText Y TmtSortSite "Mesto" 0
menuText Y TmtSortEvent "Turnir" 1
menuText Y TmtSortWinner "Pobednik" 0
translate Y TmtLimit "Ogranièenje liste"
translate Y TmtMeanElo "Najni¾i Elo"
translate Y TmtNone "Nije pronaðen odgovarajuæi turnir."

# Graph windows:
menuText Y GraphFile "Fajl" 0
menuText Y GraphFileColor "Saèuvaj kao Postscript u boji..." 25
menuText Y GraphFileGrey "Saèuvaj kao Postscript u sivim nivoima..." 25
menuText Y GraphFileClose "Zatvori prozor" 6
menuText Y GraphOptions "Opcije" 0
menuText Y GraphOptionsWhite "Beli" 0
menuText Y GraphOptionsBlack "Crni" 0
menuText Y GraphOptionsBoth "Oba" 1
menuText Y GraphOptionsPInfo "Informacije o igraèu" 0
translate Y GraphFilterTitle "Filter graph: frequency per 1000 games" ;# ***

# Analysis window:
translate Y AddVariation {Dodaj varijantu}
translate Y AddMove {Dodaj potez}
translate Y Annotate {Dodaj napomenu}
translate Y AnalysisCommand {Komanda analize}
translate Y PreviousChoices {Prethodni izbori}
translate Y AnnotateTime {Set the time between moves in seconds} ;# ***
translate Y AnnotateWhich {Add variations} ;# ***
translate Y AnnotateAll {For moves by both sides} ;# ***
translate Y AnnotateWhite {For White moves only} ;# ***
translate Y AnnotateBlack {For Black moves only} ;# ***
translate Y AnnotateNotBest {When game move is not best move} ;# ***

# Analysis Engine open dialog:
translate Y EngineList {Analysis Engine List} ;# ***
translate Y EngineName {Name} ;# ***
translate Y EngineCmd {Command} ;# ***
translate Y EngineArgs {Parameters} ;# ***
translate Y EngineDir {Directory} ;# ***
translate Y EngineElo {Elo}
translate Y EngineTime {Datum}
translate Y EngineNew {New} ;# ***
translate Y EngineEdit {Edit} ;# ***
translate Y EngineRequired {Fields in bold are required; others are optional} ;# ***

# Stats window menus:
menuText Y StatsFile "Fajl" 0
menuText Y StatsFilePrint "Print to file..." 0 ;# ***
menuText Y StatsFileClose "Close window" 0 ;# ***
menuText Y StatsOpt "Opcije" 0

# PGN window menus:
menuText Y PgnFile "Fajl" 0
menuText Y PgnFilePrint "©tampaj u fajl..." 1
menuText Y PgnFileClose "Zatvori PGN prozor" 0
menuText Y PgnOpt "Prikaz" 0
menuText Y PgnOptColor "Prikaz u boji" 0
menuText Y PgnOptShort "Kratko (3-linije) zaglavlje" 0
menuText Y PgnOptSymbols "Simbolièki komentari" 0
menuText Y PgnOptIndentC "Uvuci pasus kod komentara" 0
menuText Y PgnOptIndentV "Uvuci pasus kod varijanata" 16
menuText Y PgnOptColumn "Pasus stil (jedan potez po liniji)" 1
menuText Y PgnOptSpace "Blanko posle broja poteza" 0
menuText Y PgnOptStripMarks "Strip out colored square/arrow codes" 1 ;# ***
menuText Y PgnColor "Boje" 0
menuText Y PgnColorHeader "Zaglavlje..." 0
menuText Y PgnColorAnno "Napomene..." 0
menuText Y PgnColorComments "Komentari..." 0
menuText Y PgnColorVars "Varijante..." 0
menuText Y PgnColorBackground "Pozadina..." 0
menuText Y PgnHelp "Pomoæ" 1
menuText Y PgnHelpPgn "PGN pomoæ" 0
menuText Y PgnHelpIndex "Sadr¾aj" 0

# Crosstable window menus:
menuText Y CrosstabFile "Fajl" 0
menuText Y CrosstabFileText "©tampaj u Tekst fajl..." 10
menuText Y CrosstabFileHtml "©tampaj u HTML fajl..." 10
menuText Y CrosstabFileLaTeX "©tampaj u LaTeX fajl..." 10
menuText Y CrosstabFileClose "Zatvori tabelu turnira" 0
menuText Y CrosstabEdit "Izmena" 0
menuText Y CrosstabEditEvent "Turnir" 0
menuText Y CrosstabEditSite "Mesto" 0
menuText Y CrosstabEditDate "Datum" 0
menuText Y CrosstabOpt "Prikaz" 0
menuText Y CrosstabOptAll "Svako sa svakim" 0
menuText Y CrosstabOptSwiss "©vajcarski sistem" 0
menuText Y CrosstabOptKnockout "Nokaut" 0
menuText Y CrosstabOptAuto "Auto" 0 ;# ***
menuText Y CrosstabOptAges "Starost u godinama" 10
menuText Y CrosstabOptNats "Narodnost" 0
menuText Y CrosstabOptRatings "Rejtinzi" 0
menuText Y CrosstabOptTitles "Titule" 0
menuText Y CrosstabOptBreaks "Tie-break rezultati" 4
menuText Y CrosstabOptDeleted "Include deleted games" 8 ;# ***
menuText Y CrosstabOptColors "Boje (samo za ¹vajcarski sistem)" 0
menuText Y CrosstabOptColumnNumbers "Numbered columns (All-play-all table only)" 2 ;# ***
menuText Y CrosstabOptGroup "Grupi¹i rezultate" 0
menuText Y CrosstabSort "Sortiraj" 0
menuText Y CrosstabSortName "Ime" 0
menuText Y CrosstabSortRating "Rejting" 0
menuText Y CrosstabSortScore "Rezultat" 0
menuText Y CrosstabColor "Boja" 0
menuText Y CrosstabColorPlain "Obièan tekst" 0
menuText Y CrosstabColorHyper "Hipertekst" 0
menuText Y CrosstabHelp "Pomoæ" 0
menuText Y CrosstabHelpCross "Pomoæ - Tabela turnira" 0
menuText Y CrosstabHelpIndex "Sadr¾aj pomoæi" 0
translate Y SetFilter {Postavi filter}
translate Y AddToFilter {Dodaj u filter}
translate Y Swiss {©vajcarski sistem}

# Opening report window menus:
menuText Y OprepFile "Fajl" 0
menuText Y OprepFileText "©tampaj u Tekst fajl..." 10
menuText Y OprepFileHtml "©tampaj u HTML fajl..." 10
menuText Y OprepFileLaTeX "©tampaj u LaTeX fajl..." 10
menuText Y OprepFileOptions "Opcije..." 0
menuText Y OprepFileClose "Zatvori izve¹taj o otvaranjima" 0
menuText Y OprepHelp "Pomoæ" 0
menuText Y OprepHelpReport "Pomoæ - Izve¹taj o otvaranjima" 0
menuText Y OprepHelpIndex "Sadr¾aj pomoæi" 0

# Repertoire editor:
menuText Y RepFile "File" 0
menuText Y RepFileNew "Novi" 0
menuText Y RepFileOpen "Otvori..." 0
menuText Y RepFileSave "Saèuvaj..." 0
menuText Y RepFileSaveAs "Saèuvaj kao..." 9
menuText Y RepFileClose "Zatvori prozor" 0
menuText Y RepEdit "Izmena" 0
menuText Y RepEditGroup "Dodaj grupu" 6
menuText Y RepEditInclude "Dodaj ukljuèenu liniju" 6
menuText Y RepEditExclude "Dodaj iskljuèenu liniju" 6
menuText Y RepView "Prikaz" 0
menuText Y RepViewExpand "Razgranaj sve grupe" 0
menuText Y RepViewCollapse "Sa¾mi sve grupe" 0
menuText Y RepSearch "Pretra¾i" 3
menuText Y RepSearchAll "Ceo repertoar..." 0
menuText Y RepSearchDisplayed "Samo prikazane linije..." 0
menuText Y RepHelp "Pomoæ" 1
menuText Y RepHelpRep "Pomoæ - repertoar" 0
menuText Y RepHelpIndex "Sadr¾aj pomoæi" 0
translate Y RepSearch "Pretraga repertoara"
translate Y RepIncludedLines "ukljuèene linije"
translate Y RepExcludedLines "iskljuèene linije"
translate Y RepCloseDialog {Ovaj repertoar ima nesaèuvane izmene.

Da li zaista ¾elite da nastavite i odbacite izmene koje ste napravili?
}

# Header search:
translate Y HeaderSearch {Pretraga zaglavlja}
translate Y GamesWithNoECO {Partije bez E©O-a?}
translate Y GameLength {Du¾ina partije}
translate Y FindGamesWith {Pronaði partije sa}
translate Y StdStart {standardnim poèetkom}
translate Y Promotions {sa promocijama}
translate Y Comments {Komentari}
translate Y Variations {Varijante}
translate Y Annotations {Napomene}
translate Y DeleteFlag {Znak za brisanje}
translate Y WhiteOpFlag {Otvaranje belog}
translate Y BlackOpFlag {Otvaranje crnog}
translate Y MiddlegameFlag {Sredi¹njica}
translate Y EndgameFlag {Zavr¹nica}
translate Y NoveltyFlag {Novost}
translate Y PawnFlag {Pe¹aèka struktura}
translate Y TacticsFlag {Taktika}
translate Y QsideFlag {Igra na daminom krilu}
translate Y KsideFlag {Igra na kraljevom krilu}
translate Y BrilliancyFlag {Brilijantnost}
translate Y BlunderFlag {Gre¹ka}
translate Y UserFlag {Korisnik}
translate Y PgnContains {PGN contains text} ;# ***

# Game list window:
translate Y GlistNumber {Broj}
translate Y GlistWhite {Beli}
translate Y GlistBlack {Crni}
translate Y GlistWElo {B-Elo}
translate Y GlistBElo {C-Elo}
translate Y GlistEvent {Turnir}
translate Y GlistSite {Mesto}
translate Y GlistRound {Kolo}
translate Y GlistDate {Datum}
translate Y GlistYear {Year}
translate Y GlistEDate {Datum turnira}
translate Y GlistResult {Rezultat}
translate Y GlistLength {Du¾ina}
translate Y GlistCountry {Zemlja}
translate Y GlistECO {E©O}
translate Y GlistOpening {Otvaranje}
translate Y GlistEndMaterial {End-Material} ;# ***
translate Y GlistDeleted {Izbrisano}
translate Y GlistFlags {Oznaka}
translate Y GlistVars {Varijante}
translate Y GlistComments {Komentari}
translate Y GlistAnnos {Napomene}
translate Y GlistStart {Start} ;# ***
translate Y GlistGameNumber {Broj partije}
translate Y GlistFindText {Naði tekst}
translate Y GlistMoveField {Move} ;# ***
translate Y GlistEditField {Configure} ;# ***
translate Y GlistAddField {Add} ;# ***
translate Y GlistDeleteField {Remove} ;# ***
translate Y GlistWidth {Width} ;# ***
translate Y GlistAlign {Align} ;# ***
translate Y GlistColor {Color} ;# ***
translate Y GlistSep {Separator} ;# ***

# Maintenance window:
translate Y DatabaseName {Ime baze:}
translate Y TypeIcon {Ikona:}
translate Y NumOfGames {Partija:}
translate Y NumDeletedGames {Obrisanih partija:}
translate Y NumFilterGames {Partija u filteru:}
translate Y YearRange {Raspon godina:}
translate Y RatingRange {Raspon rejtinga:}
translate Y Flag {Oznaka}
translate Y DeleteCurrent {Obri¹i tekuæu partiju}
translate Y DeleteFilter {Obri¹i filtrirane partije}
translate Y DeleteAll {Obri¹i sve partije}
translate Y UndeleteCurrent {Obnovi tekuæu partiju}
translate Y UndeleteFilter {Obnovi filtrirane partije}
translate Y UndeleteAll {Obnovi sve partije}
translate Y DeleteTwins {Obri¹i udvojene partije}
translate Y MarkCurrent {Markiraj tekuæu partiju}
translate Y MarkFilter {Markiraj filtrirane partije}
translate Y MarkAll {Markiraj sve partije}
translate Y UnmarkCurrent {Demarkiraj tekuæu partiju}
translate Y UnmarkFilter {Demarkiraj filtrirane partije}
translate Y UnmarkAll {Demarkiraj sve partije}
translate Y Spellchecking {Provera pravopisa}
translate Y Players {Igraèi}
translate Y Events {Turniri}
translate Y Sites {Mesta}
translate Y Rounds {Kola}
translate Y DatabaseOps {Operacije sa bazom}
translate Y ReclassifyGames {Klasifikuj partije po E©O}
translate Y CompactDatabase {Komprimuj bazu}
translate Y SortDatabase {Sortiraj bazu}
translate Y AddEloRatings {Dodaj Elo rejtinge}
translate Y AutoloadGame {Autoload game number} ;# ***
translate Y StripTags {Strip PGN tags} ;# ***
translate Y StripTag {Strip tag} ;# ***
translate Y Cleaner {Èistaè}
translate Y CleanerHelp {
Scid Èistaè æe da primeni sve akcije odr¾avanja koje izaberete iz donje liste, na tekuæu bazu.

Trenutna pode¹avanja u dijalozima E©O klasifikacija i brisanje udvojenih partija æe se primeniti ako ste izabrali te funkcije.
}
translate Y CleanerConfirm {
Kada je Èistaè jednom pokrenut, ne mo¾e se prekinuti!

Ovo mo¾e potrajati na velikoj bazi, zavisno od funkcija koje ste izabrali i njihovih trenutnih pode¹avanja.

Da li ste sigurni da ¾elite da poènete funkcije odr¾avanja koje ste izabrali?
}

# Comment editor:
translate Y AnnotationSymbols  {Simboli napomena:}
translate Y Comment {Komentari:}

# Board search:
translate Y BoardSearch {Pretraga po poziciji}
translate Y FilterOperation {Operacije na tekuæem filteru:}
translate Y FilterAnd {I (Ogranièi filter)}
translate Y FilterOr {ILI (Dodaj u filter)}
translate Y FilterIgnore {IGNORI©I (Resetuj filter)}
translate Y SearchType {Tip pretrage:}
translate Y SearchBoardExact {Ista pozicija (sve figure na istim poljima)}
translate Y SearchBoardPawns {Pe¹aci (isti materijal, svi pe¹aci na istim poljima)}
translate Y SearchBoardFiles {Linije (isti materijal, svi pe¹aci na istim linijama)}
translate Y SearchBoardAny {Materijal (isti materijal, pe¹aci i figure bilo gde)}
translate Y LookInVars {Pogledaj u varijantama}

# Material search:
translate Y MaterialSearch {Pretraga po materijalu}
translate Y Material {Materijal}
translate Y Patterns {Pozicije}
translate Y Zero {Ni¹ta}
translate Y Any {Bilo koje}
translate Y CurrentBoard {Trenutna pozicija}
translate Y CommonEndings {Tipiène zavr¹nice}
translate Y CommonPatterns {Tipiène pozicije}
translate Y MaterialDiff {Material difference} ;# ***
translate Y squares {polja}
translate Y SameColor {Ista boja}
translate Y OppColor {Suprotna boja}
translate Y Either {Oba}
translate Y MoveNumberRange {Raspon broja poteza}
translate Y MatchForAtLeast {Naði za najmanje}
translate Y HalfMoves {polupoteza}

# Game saving:
translate Y Today {Danas}
translate Y ClassifyGame {Klasifikuj partiju}

# Setup position:
translate Y EmptyBoard {Isprazni tablu}
translate Y InitialBoard {Poèetna pozicija}
translate Y SideToMove {Na potezu je}
translate Y MoveNumber {Broj poteza}
translate Y Castling {Rokada}
translate Y EnPassentFile {En Passent linija}
translate Y ClearFen {Oèisti FEN}
translate Y PasteFen {Prenesi FEN}

# Replace move dialog:
translate Y ReplaceMove {Zameni potez}
translate Y AddNewVar {Dodaj novu varijantu}
translate Y ReplaceMoveMessage {Ovde veæ postoji potez.

Mo¾ete ga zameniti, odbacujuæi sve poteze posle njega, ili dodajte svoj potez kao novu varijantu.

(Mo¾ete izbeæi pojavljivanje ove poruke ubuduæe ako iskljuèite "Pitaj pre zamene poteza" opciju u meniju Opcije:Potezi.)}

# Make database read-only dialog:
translate Y ReadOnlyDialog {Ako omoguæite samo èitanje iz ove baze, neæe biti dozvoljene izmene.
Nijedna partije neæe biti saèuvana ili zamenjena, i nijedan znak za brisanje ne mo¾e biti izmenjen.
Bilo kakvo sortiranje ili rezultati E©O klasifikacije æe biti privremeni.

Mo¾ete lako ponovo omoguæiti pisanje po bazi, ako je zatvorite i ponovo otvorite.

Da li zaista ¾elite da ova baza bude samo za èitanje?}

# Clear game dialog:
translate Y ClearGameDialog {Ova partija je izmenjena.

Da li zaista ¾elite da nastavite i odbacite sve uèinjene promene?
}

# Exit dialog:
translate Y ExitDialog {Da li zaista ¾elite da napustite Scid?}
translate Y ExitUnsaved {The following databases have unsaved game changes. If you exit now, these changes will be lost.} ;# ***

# Import window:
translate Y PasteCurrentGame {Prenesi tekuæu partiju}
translate Y ImportHelp1 {Unesi ili prenesi partiju u PGN formatu u gornji okvir.}
translate Y ImportHelp2 {Bilo koja gre¹ka u uvozu partije æe biti prikazana ovde.}

# ECO Browser:
translate Y ECOAllSections {sve E©O sekcije}
translate Y ECOSection {E©O sekcija}
translate Y ECOSummary {Pregled za}
translate Y ECOFrequency {Uèestanost subkodova za}

# Opening Report:
translate Y OprepTitle {Izve¹taj o otvaranjima}
translate Y OprepReport {Izve¹taj}
translate Y OprepGenerated {Generisao}
translate Y OprepStatsHist {Statistika i Istorija}
translate Y OprepStats {Statistika}
translate Y OprepStatAll {Sve partije iz iz izve¹taja}
translate Y OprepStatBoth {Oba sa rejtingom}
translate Y OprepStatSince {Od}
translate Y OprepOldest {Najstarije partije}
translate Y OprepNewest {Najnovije partije}
translate Y OprepPopular {Trenutna popularnost}
translate Y OprepFreqAll {Uèetanost za sve godine:    }
translate Y OprepFreq1   {Tokom  1 poslednje godine:  }
translate Y OprepFreq5   {Tokom  5 poslednjih godina: }
translate Y OprepFreq10  {Tokom 10 poslednjih godina: }
translate Y OprepEvery {jednom svakih %u partija}
translate Y OprepUp {vi¹e za %u%s tokom svih godina}
translate Y OprepDown {manje za %u%s tokom svih godina}
translate Y OprepSame {bez promena tokom svih godina}
translate Y OprepMostFrequent {Najèe¹æi igraèi}
translate Y OprepRatingsPerf {Rejtinzi i ume¹nost}
translate Y OprepAvgPerf {Proseèni rejtinzi i ume¹nost}
translate Y OprepWRating {Rejting belog}
translate Y OprepBRating {Rejting crnog}
translate Y OprepWPerf {Ume¹nost belog}
translate Y OprepBPerf {Ume¹nost crnog}
translate Y OprepHighRating {Partije sa najveæim proseènim rejtingom}
translate Y OprepTrends {Rezultatski trendovi}
translate Y OprepResults {Du¾ine rezultata i uèestanosti}
translate Y OprepLength {Du¾ina partije}
translate Y OprepFrequency {Uèestanost}
translate Y OprepWWins {Pobede belog: }
translate Y OprepBWins {Pobede crnog: }
translate Y OprepDraws {Remiji:       }
translate Y OprepWholeDB {cela baza}
translate Y OprepShortest {Najkraæa pobeda} ;# ***
# translate Y OprepShortWhite {Najkraæa pobeda belog}
# translate Y OprepShortBlack {Najkraæa pobeda crnog}
translate Y OprepMovesThemes {Potezi i teme}
translate Y OprepMoveOrders {Redosledi poteza koji su dosegli poziciju iz izve¹taja}
translate Y OprepMoveOrdersOne \
  {Samo je jedan redosled poteza koji je dostigao ovu poziciju:}
translate Y OprepMoveOrdersAll \
  {Bilo je %u redosleda poteza koji su dostigli ovu poziciju:}
translate Y OprepMoveOrdersMany \
  {Bilo je %u redosleda poteza koji su dostigli ovu poziciju. Prvih %u su:}
translate Y OprepMovesFrom {Potezi iz pozicije iz izve¹taja}
translate Y OprepThemes {Pozicione teme}
translate Y OprepThemeDescription {Uèestanost tema na potezu br. %u}
translate Y OprepThemeSameCastling {Rokade sa iste strane}
translate Y OprepThemeOppCastling {Rokade sa suprotne strane}
translate Y OprepThemeNoCastling {Obe strane bez rokada}
translate Y OprepThemeKPawnStorm {Prodor pe¹aka na kraljevom krilu}
translate Y OprepThemeQueenswap {Zamena dama}
translate Y OprepThemeIQP {Izolovan damin pe¹ak}
translate Y OprepThemeWP567 {Beli pe¹ak na 5., 6. ili 7. redu}
translate Y OprepThemeBP234 {Crni pe¹ak na 2., 3. ili 4. redu}
translate Y OprepThemeOpenCDE {Otvorena c, d ili e linija}
translate Y OprepTheme1BishopPair {Jedna strana ima par lovaca}
translate Y OprepEndgames {Zavr¹nice}
translate Y OprepReportGames {Partije iz izve¹taja}
translate Y OprepAllGames {Sve partije}
translate Y OprepEndClass {Materijal na kraju svake partije}
translate Y OprepTheoryTable {Tabela teorije}
translate Y OprepTableComment {Generisano iz %u najbolje rejtiranih partija.}
translate Y OprepExtraMoves {Posebno notirani potezi u tabeli teorije}
translate Y OprepMaxGames {Maksimum partija u tabeli teorije}

# Piece Tracker window:
translate Y TrackerSelectSingle {Left mouse button selects this piece.} ;# ***
translate Y TrackerSelectPair {Left mouse button selects this piece; right button also selects its sibling.}
translate Y TrackerSelectPawn {Left mouse button selects this pawn; right button selects all 8 pawns.}
translate Y TrackerStat {Statistic}
translate Y TrackerGames {% games with move to square}
translate Y TrackerTime {% time on each square}
translate Y TrackerMoves {Moves}
translate Y TrackerMovesStart {Enter the move number where tracking should begin.}
translate Y TrackerMovesStop {Enter the move number where tracking should stop.}

# Game selection dialogs:
translate Y SelectAllGames {Sve partije u bazi}
translate Y SelectFilterGames {Samo partije u filteru}
translate Y SelectTournamentGames {Samo partije u tekuæem turniru}
translate Y SelectOlderGames {Samo starije partije}

# Delete Twins window:
translate Y TwinsNote {Da bi bile udvojene, dve partije moraju da najmanje imaju istu dvojicu igraèa, i kriterijume koje ni¾e mo¾ete podesiti. Kada se par udvojenih partija otkrije, kraæa partija se bri¹e.
Savet: Najbolje je proveriti pravopis u bazi pre brisanja udvojenih partija, jer to unapreðuje detekciju. }
translate Y TwinsCriteria {Kriterijumi: Udvojene partije moraju imati...}
translate Y TwinsWhich {Koje partije da proverim?}
translate Y TwinsColors {Iste boje igraèa?}
translate Y TwinsEvent {Isti turnir?}
translate Y TwinsSite {Isto mesto?}
translate Y TwinsRound {Isto kolo?}
translate Y TwinsYear {Ista godina?}
translate Y TwinsMonth {Isti mesec?}
translate Y TwinsDay {Isti dan?}
translate Y TwinsResult {Isti rezultat?}
translate Y TwinsECO {Isti E©O kôd?}
translate Y TwinsMoves {Isti potezi?}
translate Y TwinsPlayers {Uporeðivanje imena igraèa:}
translate Y TwinsPlayersExact {Potpuna podudarnost}
translate Y TwinsPlayersPrefix {Samo prva 4 slova}
translate Y TwinsWhen {Kod brisanja udvojenih partija}
translate Y TwinsSkipShort {Ignore all games under 5 moves long?} ;# ***
translate Y TwinsUndelete {Obnovi prvo sve partije?}
translate Y TwinsSetFilter {Postavi filter na sve obrisane udvojene partije?}
translate Y TwinsComments {Uvek saèuvaj partije sa komentarima?}
translate Y TwinsVars {Uvek saèuvaj partije sa varijantama?}
translate Y TwinsDeleteWhich {Delete which game:} ;# ***
translate Y TwinsDeleteShorter {Shorter game} ;# ***
translate Y TwinsDeleteOlder {Smaller game number} ;# ***
translate Y TwinsDeleteNewer {Larger game number} ;# ***
translate Y TwinsDelete {Obri¹i partije}

# Name editor window:
translate Y NameEditType {Tip imena za izmenu}
translate Y NameEditSelect {Partije za izmenu}
translate Y NameEditReplace {Zameni}
translate Y NameEditWith {sa}
translate Y NameEditMatches {Podudara se: Pritisni Ctrl+1 do Ctrl+9 za izbor}

# Classify window:
translate Y Classify {Klasifikuj}
translate Y ClassifyWhich {Klasifikuj partije po E©O}
translate Y ClassifyAll {Sve partije (prebri¹i stare E©O kôdove)}
translate Y ClassifyYear {Sve partije igrane poslednje godine}
translate Y ClassifyMonth {Sve partije igrane poslednjeg meseca}
translate Y ClassifyNew {Samo partije koje su jo¹ bez E©O kôda}
translate Y ClassifyCodes {Koristi E©O kôdove}
translate Y ClassifyBasic {Samo osnovne kôdove ("B12", ...)}
translate Y ClassifyExtended {Pro¹ireni Scid ("B12j", ...)}

# Compaction:
translate Y NameFile {Fajl imena}
translate Y GameFile {Fajl partija}
translate Y Names {Imena}
translate Y Unused {Nekori¹æena}
translate Y SizeKb {Velièina (kb)}
translate Y CurrentState {Trenutno stanje}
translate Y AfterCompaction {Posle komprimacije}
translate Y CompactNames {Komprimuj fajl imena}
translate Y CompactGames {Komprimuj fajl partija}

# Sorting:
translate Y SortCriteria {Kriterijumi}
translate Y AddCriteria {Dodaj kriterijum}
translate Y CommonSorts {Uobièajena sortiranja}
translate Y Sort {Sortiraj}

# Exporting:
translate Y AddToExistingFile {Dodaj partije u postojeæi fajl?}
translate Y ExportComments {Izvezi komentare?}
translate Y ExportVariations {Izvezi varijante?}
translate Y IndentComments {Uvuci pasus kod komentara?}
translate Y IndentVariations {Uvuci pasus kod varijanata?}
translate Y ExportColumnStyle {Pasus stil (jedan potez po liniji)?}
translate Y ExportSymbolStyle {Stil simbolièkih napomena:}
translate Y ExportStripMarks {Strip square/arrow mark codes from comments?} ;# ***

# Goto game/move dialogs:
translate Y LoadGameNumber {Unesi broj partije za uèitavanje:}
translate Y GotoMoveNumber {Idi na potez broj:}

# Copy games dialog:
translate Y CopyGames {Kopiraj partije}
translate Y CopyConfirm {
 Da li zaista ¾elite da kopirate
 [thousands $nGamesToCopy] filtriranih partija
 iz baze "$fromName"
 u bazu "$targetName"?
}
translate Y CopyErr {Ne mogu da kopiram partije}
translate Y CopyErrSource {izvori¹na baza}
translate Y CopyErrTarget {odredi¹na baza}
translate Y CopyErrNoGames {nema partija u svom filteru}
translate Y CopyErrReadOnly {je samo za èitanje}
translate Y CopyErrNotOpen {nije otvorena}

# Colors:
translate Y LightSquares {Svetla polja}
translate Y DarkSquares {Tamna polja}
translate Y SelectedSquares {Izabrana polja}
translate Y SuggestedSquares {Polja preporuèenog poteza}
translate Y WhitePieces {Bele figure}
translate Y BlackPieces {Crne figure}
translate Y WhiteBorder {Ivica belih figura}
translate Y BlackBorder {Ivica crnih figura}

# Novelty window:
translate Y FindNovelty {Pronaði novost}
translate Y Novelty {Novost}
translate Y NoveltyInterrupt {Tra¾enje novosti prekinuto}
translate Y NoveltyNone {Nijedna novost nije pronaðena u ovoj partiji}
translate Y NoveltyHelp {
Scid æe naæi prvi potez tekuæe partije, koji dosti¾e poziciju koja nije naðena u izabranoj bazi ili u E©O knjizi otvaranja.
}

# Upgrading databases:
translate Y Upgrading {Unapreðivanje}
translate Y ConfirmOpenNew {
Ovo je baza u starom formatu (Scid 2), koju ne mo¾e da otvori Scid 3, veæ je kreirana verzija u novom formatu (Scid 3).

Da li ¾elite da otvorite verziju baze u novom formatu?
}
translate Y ConfirmUpgrade {
Ovo je baza u starom formatu (Scid 2). Verzija baze u novom formatu mora biti kreirana pre kori¹æenja u Scid-u 3.

Unapreðivanjem æe se kreirati nova verzija baze; neæe se uklanjati originalni fajlovi.

Ovo mo¾e potrajati, ali treba da se uradi samo jednom. Mo¾ete prekinuti ukoliko bude predugo trajalo.

Da li ¾elite da sada unapredite ovu bazu?
}

}
# end of serbian.tcl
