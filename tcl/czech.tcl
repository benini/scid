# czech.tcl: Czech menus for Scid.
# Contributed by Pavel Hanak.
# Untranslated messages are marked with a "***" comment.

addLanguage C Czech 0 iso8859-2

proc setLanguage_C {} {

# File menu:
menuText C File "Soubor" 0
menuText C FileNew "Nový..." 0 {Vytvoøit novou Scid databázi}
menuText C FileOpen "Otevøít..." 0 {Otevøít existující Scid databázi}
menuText C FileClose "Zavøít" 0 {Zavøít aktivní Scid databázi}
menuText C FileFinder "Vyhledávaè" 0 {Otevøít okno Vyhledávaè souborù}
menuText C FileBookmarks "Zálo¾ky" 0 {Menu zálo¾ek (klávesa: Ctrl+B)}
menuText C FileBookmarksAdd "Pøidat zálo¾ku" 0 \
  {Zálo¾ka aktuální pozice a partie z databáze}
menuText C FileBookmarksFile "Zaøadit zálo¾ku" 0 \
  {Zaøadit zálo¾ku pro aktuální partii a pozici}
menuText C FileBookmarksEdit "Editovat zálo¾ky..." 0 \
  {Editovat menu zálo¾ek}
menuText C FileBookmarksList "Zobrazit slo¾ky jako jediný seznam" 0 \
  {Zobrazit slo¾ky se zálo¾kami jako jediný seznam, bez podnabídek}
menuText C FileBookmarksSub "Zobrazit slo¾ky jako podnabídky" 0 \
  {Zobrazit zálo¾kové slo¾ky jako podnabídky, ne jako jediný seznam}
menuText C FileMaint "Údr¾ba" 1 {Nástroje pro údr¾bu Scid databáze}
menuText C FileMaintWin "Okno údr¾by" 0 \
  {Otevøít/zavøít okno pro údr¾bu Scid databáze}
menuText C FileMaintCompact "Komprimace databáze..." 0 \
  {Komprimace databázových souborù, odstranìní vymazaných partií a nepou¾ívaných jmen}
menuText C FileMaintClass "ECO klasifikace partií..." 0 \
  {Pøepoèítání ECO kódù v¹ech her}
menuText C FileMaintSort "Setøídit databázi..." 0 \
  {Stetøídit v¹echny hry v databázi}
menuText C FileMaintDelete "Vymázání zdvojených partií..." 0 \
  {Hledat zdvojené partie a oznaèit je pro vymazání}
menuText C FileMaintTwin "Kontrola zdvojených partií" 0 \
  {Otevøít/aktualizovat okno pro kontrolu zdvojených partií}
menuText C FileMaintName "Jména" 0 {Editace jmen a kontrola pravopisu}
menuText C FileMaintNameEditor "Editor jmen" 0 \
  {Otevøít/zavøít editor jmen}
menuText C FileMaintNamePlayer "Kontrola pravopisu hráèù..." 11 \
  {Kontrola pravopisu jmen hráèù s vyu¾itím souboru spellcheck}
menuText C FileMaintNameEvent "Kontrola pravopisu turnajù..." 11 \
  {Kontrola pravopisu názvù turnajù s vyu¾itím souboru spellcheck}
menuText C FileMaintNameSite "Kontrola pravopisu dìji¹»..." 11 \
  {Kontrola pravopisu dìji¹» turnajù s vyu¾itím souboru spellcheck}
menuText C FileMaintNameRound "Kontrola pravopisu kol..." 11 \
  {Kontrola pravopisu kol s vyu¾itím souboru spellcheck}
menuText C FileReadOnly "Pouze pro ètení..." 0 \
  {Nastavit u databáze ochranu proti zápisu}
menuText C FileSwitch "Switch to database" 0 \
  {Switch to a different opened database} ;# ***
menuText C FileExit "Ukonèit" 0 {Ukonèit Scid}

# Edit menu:
menuText C Edit "Editace" 0
menuText C EditAdd "Pøidat variantu" 0 {Pøidat variantu k tomuto tahu v partii}
menuText C EditDelete "Vymazat variantu" 1 {Vymazat variantu k tomuto tahu}
menuText C EditFirst "Zaøadit jako první variantu" 5 \
  {Zaøadit variantu na první místo v seznamu variant}
menuText C EditMain "Pový¹it stávající variantu na hlavní" 21 \
  {Pový¹it stávající variantu na hlavní variantu}
menuText C EditTrial "Zkusit variantu" 0 \
    {Spustit/Ukonèit zku¹ební mód pro testování my¹lenky na ¹achovnici}
menuText C EditStrip "Odstranit" 2 {Odstranit komentáøe nebo varianty z této partie}
menuText C EditStripComments "Komentáøe" 0 \
  {Odstranit v¹echny poznámky a anotace z této partie}
menuText C EditStripVars "Varianty" 0 {Odstranit v¹echny varianty z této partie}
menuText C EditReset "Vyprázdnit schránku" 0 \
  {Kompletní vyprázdnìní schránky}
menuText C EditCopy "Zkopírovat tuto partii do schránky" 1 \
  {Zkopírovat tuto partií do schránky s partiemi}
menuText C EditPaste "Vlo¾it poslední partii ze schránky" 1 \
  {Vlo¾it aktivní partii ze schránky}
menuText C EditSetup "Nastavit výchozí pozici..." 1 \
  {Nastavit výchozí pozici pro tuto partii}
menuText C EditCopyBoard "Copy position" 6 \
  {Copy the current board in FEN notation to the text selection (clipboard)} ;# ***
menuText C EditPasteBoard "Vlo¾it poèáteèní pozici" 12 \
  {Nastavit poèáteèní pozici z aktuálního textového výbìru (ze schránky)}

# Game menu:
menuText C Game "Partie" 0
menuText C GameNew "Nová partie" 0 \
  {Nastavit novou partii, v¹echny provedené zmìny budou ztraceny}
menuText C GameFirst "Natáhnout první partii" 4 {Natáhnout první partii z filtrovaných partií}
menuText C GamePrev "Natáhnout pøedchozí partii" 6 {Natáhnout pøedchozí partii z filtrovaných partií}
menuText C GameReload "Znovunatáhnout aktuální partii" 3 \
  {Znovunata¾ení aktuální partie, v¹echny doposud provedené zmìny budou ztraceny}
menuText C GameNext "Natáhnout následující partii" 13 {Natáhnout následující partii z filtrovaných partií}
menuText C GameLast "Natáhnout poslední partii" 14 {Natáhnout poslední partii z filtrovaných partií}
menuText C GameRandom "Natáhnout partii náhodnì" 8 {Natáhnout náhodnì vybranou partii z filtru}
menuText C GameNumber "Natáhnout partii èíslo..." 12 \
  {Natáhnout partii èíslo...}
menuText C GameReplace "Ulo¾it: pøepsání partie..." 0 \
  {Ulo¾it tuto partii - pøepí¹e pùvodní verzi}
menuText C GameAdd "Ulo¾it: pøidání nové partie..." 18 \
  {Ulo¾it tuto partii jako novou partii v databázi}
menuText C GameDeepest "Identifikace zahájení" 0 \
  {Pøejít na koncovou pozici z ECO knihovny, která odpovídá zvolenému zahájení}
menuText C GameGotoMove "Pøejít na tah èíslo..." 3 \
  {Pøejít v aktuální partii do pozice udané èíslem tahu}
menuText C GameNovelty "Hledat novinku..." 7 \
  {Hledat první tah této partie, který doposud nebyl hrán}

# Search Menu:
menuText C Search "Hledat" 0
menuText C SearchReset "Vyèistit filtr" 0 {Vyèistit filtr - vybrány budou v¹echny partie}
menuText C SearchNegate "Negace filtru" 0 {Negace filtru -  vybrány budou pouze partie vyòaté pøedcházejícím filtrem}
menuText C SearchCurrent "Aktuální pozice..." 0 {Hledat aktuální pozici}
menuText C SearchHeader "Hlavièka..." 1 {Hledat podle hlavièky partie (hráè, turnaj apod.)}
menuText C SearchMaterial "Materiál/Vzor..." 0 {Hledat podle materiálu nebo podle pozice}
menuText C SearchUsing "Hledat pomocí souboru voleb..." 0 {Hledat s pou¾itím voleb zapsaných v souboru}

# Windows menu:
menuText C Windows "Okna" 0
menuText C WindowsComment "Editor komentáøù" 0 {Otevøít/zavøít editor komentáøù}
menuText C WindowsGList "Seznam partií" 0 {Otevøít/zavøít okno se seznamem partií}
menuText C WindowsPGN "Okno PGN" 0 {Otevøít/zavøít okno PGN (okno se zápisem partie)}
menuText C WindowsPList "Player Finder" 2 {Open/close the player finder} ;# ***
menuText C WindowsTmt "Vyhledávaè turnajù" 0 {Otevøít/zavøít okno vyhledávaèe turnajù}
menuText C WindowsSwitcher "Výbìr databáze" 0 {Otevøít/zavøít okno pro výbìr databází}
menuText C WindowsMaint "Okno údr¾by" 1 {Otevøít/zavøít okno údr¾by}
menuText C WindowsECO "ECO prohlí¾eè" 1 {Otevøít/zavøít browser ECO (kódù zahájení)}
menuText C WindowsRepertoire "Editor repertoáru" 0 {Otevøít/zavøít editor repertoáru zahájení}
menuText C WindowsStats "Statistické okno" 1 {Otevøít/zavøít okno se statistikou}
menuText C WindowsTree "Stromové okno" 2 {Otevøít/zavøít okno se stromem variant}
menuText C WindowsTB "Okno tabulky koncovek" 1 {Otevøít/zavøít okno tabulky koncovek}

# Tools menu:
menuText C Tools "Nástroje" 0
menuText C ToolsAnalysis "Program pro analýzu..." 5 \
  {Spustit/zastavit ¹achový program pro analýzu pozice}
menuText C ToolsAnalysis2 "Program pro analýzu #2..." 20 \
  {Spustit/zastavit ¹achový program pro analýzu pozice}
menuText C ToolsCross "Turnajová tabulka" 0 {Ukázat turnajovou tabulku pro tuto partii}
menuText C ToolsEmail "Email mana¾er" 0 \
  {Otevøít/zavøít okno pro správu korespondeèních partií hraných pøes email}
menuText C ToolsFilterGraph "Graf filtru" 7 \
  {Otevøít/zavøít okno grafem èetnosti pro filtr}
menuText C ToolsOpReport "Pøehled zahájení" 3 \
  {Generovat pøehled zajímavých faktù o zahájení dané aktuální pozicí}
menuText C ToolsTracker "Stopaø figur"  0 {Otevøít okno pro stopování výskytu figur na polích}
menuText C ToolsPInfo "Informace o hráèích"  0 \
  {Otevøít/aktualizovat okno s informacemi o hráèích}
menuText C ToolsRating "Graf ELO klasifikace" 0 \
  {Graf ELO klasifikace hráèù aktuální partie}
menuText C ToolsScore "Graf skóre" 5 {Ukázat okno s grafem skóre}
menuText C ToolsExpCurrent "Export aktuální partie" 1 \
  {Zapsat aktuální partii do textového souboru}
menuText C ToolsExpCurrentPGN "Export partie do PGN souboru..." 17 \
  {Zapsat aktuální partii do PGN souboru}
menuText C ToolsExpCurrentHTML "Export partie do HTML souboru..." 17 \
  {Zapsat aktuální partii do HTML souboru}
menuText C ToolsExpCurrentLaTeX "Export partie do LaTeX souboru..." 17 \
  {Zapsat aktuální partii do LaTeX souboru}
menuText C ToolsExpFilter "Export filtrovaných partií" 7 \
  {Zapsat v¹echny filtrované partie do textového souboru}
menuText C ToolsExpFilterPGN "Export filtrovaných partií do PGN souboru..." 10 \
  {Zapsat v¹echny filtrované partie do PGN souboru}
menuText C ToolsExpFilterHTML "Export filtrovaných partií do HTML souboru..." 11 \
  {Zapsat v¹echny filtrované partie do HTML souboru}
menuText C ToolsExpFilterLaTeX "Export filtrovaných partií do LaTeX souboru..." 12 \
  {Zapsat v¹echny filtrované partie do LaTeX souboru}
menuText C ToolsImportOne "Import jedné PGN partie..." 0 \
  {Importovat partie z PGN souboru}
menuText C ToolsImportFile "Import více partií z PGN souboru..." 7 \
  {Importovat partií z PGN souboru}

# Options menu:
menuText C Options "Volby" 0
menuText C OptionsSize "Velikost ¹achovnice" 0 {Zmìnit velikost ¹achovnice}
menuText C OptionsPieces "Styl zobrazení figurek" 0 \
  {Zmìnit styl zobrazení figurek na ¹achovnici}
menuText C OptionsColors "Barvy..." 0 {Zmìnit barvy ¹achovnice}
menuText C OptionsExport "Volby exportu" 6 {Zmìnit volby pro textový export}
menuText C OptionsFonts "Písma" 0 {Zmìnit písma}
menuText C OptionsFontsRegular "Základní písmo" 0 {Zmìnit základní písmo}
menuText C OptionsFontsMenu "Menu" 0 {Zmìnit font pro menu}
menuText C OptionsFontsSmall "Malé" 0 {Zmìnit malé písmo}
menuText C OptionsFontsFixed "Neproporcionální" 0 {Zmìnit neproporcionální písmo}
menuText C OptionsGInfo "Informace o partii" 0 {Volby pro informace o partii}
menuText C OptionsLanguage "Jazyk" 0 {Vybrat jazyk}
menuText C OptionsMoves "Tahy" 0 {Volby pro vkládání tahù}
menuText C OptionsMovesAsk "Ptát se pøed nahrazením tahù" 15 \
  {Ptát se, zda se mají pøepsat existující tahy novì vkládanými}
menuText C OptionsMovesDelay "Prodleva pøi pøehrávání partie..." 3 \
  {Nastavit èasovou prodlevu mezi tahy pøi automatickém pøehrávání}
menuText C OptionsMovesCoord "Vkládání tahù zadáváním souøadnic" 1 \
  {Povolit vkládání tahù pomocí zadávání souøadnic z klávesnice ("g1f3")}
menuText C OptionsMovesSuggest "Ukázat navrhované tahy" 0 \
  {Zapnout/vypnout zobrazování navrhovaných tahù}
menuText C OptionsMovesKey "Doplòování tahù" 0 \
  {Zapnout/vypnout automatické doplòování tahù zadávaných klávesnicí}
menuText C OptionsNumbers "Formát èísel" 0 {Zvolit formát èísel}
menuText C OptionsStartup "Pøi spu¹tìní" 3 {Zvolit okna, která se otevøou pøi spu¹tìní}
menuText C OptionsWindows "Okna" 0 {Volby oken}
menuText C OptionsWindowsIconify "Automatická minimalizace" 12 \
   {Minimalizovat v¹echna okna pøi minimalizování hlavního okna}
menuText C OptionsWindowsRaise "Automaticky do popøedí" 0 \
  {Dát do popøedí jistá okna, jsou-li zakrytá}
menuText C OptionsToolbar "Nástrojová li¹ta hlavního okna" 12 \
  {Zobrazit/skrýt nástrojovou li¹tu hlavního okna}
menuText C OptionsECO "Natáhnout ECO soubor..." 7 {Natáhnout soubor s klasifikací ECO}
menuText C OptionsSpell "Natáhnout soubor pro kontrolu pravopisu..." 6 \
  {Natáhnout soubor pro kontrolu pravopisu}
menuText C OptionsTable "Adresáø pro databáze koncovek..." 0 \
  {Vybrat soubor s koncovkami; v¹echny databáze z koncovkami v tomto adresáøi budou pou¾ity}
menuText C OptionsRecent "Aktuální soubory..." 0 \
  {Zmìnit poèet aktuálních souborù zobrazovaných v nabídce Soubor}
menuText C OptionsSave "Ulo¾it volby" 0 {Ulo¾it volby}
menuText C OptionsAutoSave "Automaticky ukládat volby pøi ukonèení" 0 \
  {Automaticky ukládat v¹echny volby pøi ukonèení programu}

# Help menu:
menuText C Help "Nápovìda" 0
menuText C HelpIndex "Index" 0 {Ukázat hlavní nápovìdnou stránku}
menuText C HelpGuide "Rychlý prùvodce" 0 {Ukázat stránku s rychlým prùvodcem nápovìdou}
menuText C HelpHints "Rady" 1 {Ukázat nápovìdnou stránku s radami}
menuText C HelpContact "Kontakt" 0 {Ukázat stránku s kontaktními informacemi}
menuText C HelpTip "Tip dne" 0 {Ukázat u¾iteèný tip Scidu}
menuText C HelpStartup "Startovací okno" 0 {Ukázat startovací okno}
menuText C HelpAbout "O aplikaci Scid" 0 {Informace o aplikaci Scid}

# Game info box popup menu:
menuText C GInfoHideNext "Skrýt následující tah" 0
menuText C GInfoMaterial "Ukázat hodnoty materiálu" 0
menuText C GInfoFEN "Ukázat FEN" 7
menuText C GInfoMarks "Zobrazovat barevná pole a ¹ipky" 11
menuText C GInfoWrap "Zalamovat dlouhé øádky" 0
menuText C GInfoFullComment "Zobrazit úplný komentáø" 10
menuText C GInfoPhotos "Show Photos" 5 ;# ***
menuText C GInfoTBNothing "Databáze koncovek: nic" 0
menuText C GInfoTBResult "Databáze koncovek: jen výsledek" 2
menuText C GInfoTBAll "Databáze koncovek: výsledek a nejlep¹í tahy" 4
menuText C GInfoDelete "Vymazat/Nemazat tuto partii" 0
menuText C GInfoMark "Oznaèit/Odznaèit tuto partii" 0

# Main window buttons:
helpMsg C .button.start {Jdi na zaèátek partie  (klávesa: Home)}
helpMsg C .button.end {Jdi na konec partie  (klávesa: End)}
helpMsg C .button.back {Jdi o jeden tah nazpìt  (klávesa: ¹ipka vlevo)}
helpMsg C .button.forward {Jdi o jeden tah dopøedu  (klávesa: RightArrow)}
helpMsg C .button.intoVar {Skoè do varianty  (klávesová zkratka: v)}
helpMsg C .button.exitVar {Opus» aktuální variantu  (klávesová zkratka: z)}
helpMsg C .button.flip {Otoè ¹achovnici  (klávesová zkratka: .)}
helpMsg C .button.coords {Zapnout/Vypnout zobrazování souøadnic ¹achovnice  (klávesová zkratka: 0)}
helpMsg C .button.autoplay {Automatické pøehrávání tahù  (klávesa: Ctrl+Z)}

# General buttons:
translate C Back {Zpìt}
translate C Cancel {Zru¹it}
translate C Clear {Vyèistit}
translate C Close {Zavøít}
translate C Defaults {Pøedvolené}
translate C Delete {Vymazat}
translate C Graph {Graf}
translate C Help {Nápovìda}
translate C Import {Import}
translate C Index {Index}
translate C LoadGame {Natáhnout partii}
translate C BrowseGame {Prohlédnout partii}
translate C MergeGame {Pøipojit partii}
translate C Preview {Náhled}
translate C Revert {Vrátit se}
translate C Save {Ulo¾it}
translate C Search {Hledat}
translate C Stop {Stop}
translate C Store {Uschovat}
translate C Update {Aktualizovat}
translate C ChangeOrient {Zmìnit orientaci okna}
translate C None {Nic}
translate C First {První}
translate C Current {Aktuální}
translate C Last {Poslední}

# General messages:
translate C game {partie}
translate C games {partie}
translate C move {tah}
translate C moves {tahy}
translate C all {v¹e}
translate C Yes {Ano}
translate C No {Ne}
translate C Both {Oba}
translate C King {Král}
translate C Queen {Dáma}
translate C Rook {Vì¾}
translate C Bishop {Støelec}
translate C Knight {Jezdec}
translate C Pawn {Pì¹ec}
translate C White {Bílý}
translate C Black {Èerný}
translate C Player {Hráè}
translate C Rating {Rating}
translate C RatingDiff {Rozdíl v ratingu (Bílý - Èerný)}
translate C AverageRating {Average Rating} ;# ***
translate C Event {Turnaj}
translate C Site {Místo}
translate C Country {Zemì}
translate C IgnoreColors {Ignorovat barvy}
translate C Date {Datum}
translate C EventDate {Turnaj datum}
translate C Decade {Dekáda}
translate C Year {Rok}
translate C Month {Mìsíc}
translate C Months {Leden Únor Bøezen Duben Kvìten Èerven
  Èervenec Srpen Záøí Øíjen Listopad Prosinec}
translate C Days {Ned Pon Úte Stø Ètv Pát Sob}
translate C YearToToday {Rok zpìt}
translate C Result {Výsledek}
translate C Round {Kolo}
translate C Length {Délka}
translate C ECOCode {ECO kód}
translate C ECO {ECO}
translate C Deleted {Vymazán(a)}
translate C SearchResults {Hledat výsledky}
translate C OpeningTheDatabase {Databáze zahájení}
translate C Database {Databáze}
translate C Filter {Filtr}
translate C noGames {¾ádné partie}
translate C allGames {v¹echny partie}
translate C empty {prázdná}
translate C clipbase {schránka}
translate C score {skóre}
translate C StartPos {Poèáteèní pozice}
translate C Total {Celkem}

# Standard error messages:
translate C ErrNotOpen {This is not an open database.} ;# ***
translate C ErrReadOnly {This database is read-only; it cannot be altered.}
translate C ErrSearchInterrupted {Search was interrupted; results are incomplete.}

# Game information:
translate C twin {zdvojená}
translate C deleted {vymazaná}
translate C comment {komentáø}
translate C hidden {skrytá}
translate C LastMove {Poslední tah}
translate C NextMove {Následující}
translate C GameStart {Zaèátek partie}
translate C LineStart {Zaèátek série tahù}
translate C GameEnd {Konec partie}
translate C LineEnd {Konec série tahù}

# Player information:
translate C PInfoAll {Výsledky <b>v¹ech</b> partií}
translate C PInfoFilter {Výsledky <b>filtrovaných</b> partií}
translate C PInfoAgainst {Výsledek znovu}
translate C PInfoMostWhite {Nejèastìj¹í zahájení bílých}
translate C PInfoMostBlack {Nejèastìj¹í zahájení èerných}
translate C PInfoRating {Historie ratingu}
translate C PInfoBio {Biografie}

# Tablebase information:
translate C Draw {Remíza}
translate C stalemate {pat}
translate C withAllMoves {se v¹emi tahy}
translate C withAllButOneMove {se v¹emi tahy kromì posledního}
translate C with {s}
translate C only {jen}
translate C lose {prohrát}
translate C loses {prohrává}
translate C allOthersLose {v¹echny ostatní prohrávají}
translate C matesIn {matuje bìhem}
translate C hasCheckmated {zmatoval}
translate C longest {nejdel¹í}
translate C WinningMoves {Winning moves} ;# ***
translate C DrawingMoves {Drawing moves} ;# ***
translate C LosingMoves {Losing moves} ;# ***
translate C UnknownMoves {Unknown-result moves} ;# ***

# Tip of the day:
translate C Tip {Tip}
translate C TipAtStartup {Tip pøi spu¹tìní}

# Tree window menus:
menuText C TreeFile "Soubor" 0
menuText C TreeFileSave "Ulo¾it cache soubor" 0 \
  {Save the tree cache (.stc) file}
menuText C TreeFileFill "Naplnit cache soubor" 0 \
  {Naplnit cache soubor nejèastìj¹ími pozicemi ze zahájení}
menuText C TreeFileBest "Seznam nejlep¹ích partií" 0 {Zobrazit stromový seznam nejlep¹ích partií}
menuText C TreeFileGraph "Okno Graf" 0 {Zobrazit graf pro tuto vìtev stromu}
menuText C TreeFileCopy "Kopírovat text stromu do schránky" 0 \
  {Kopírovat statistiky ze stromu do schránky}
menuText C TreeFileClose "Zavøít stromové okno" 0 {Zavøít stromové okno}
menuText C TreeSort "Øadit" 0
menuText C TreeSortAlpha "abecednì" 0
menuText C TreeSortECO "ECO kód" 0
menuText C TreeSortFreq "Èetnost" 0
menuText C TreeSortScore "Skóre" 0
menuText C TreeOpt "Volby" 0
menuText C TreeOptLock "Zamknout" 0 {Zamknout/odemknout strom pro aktuální databázi}
menuText C TreeOptTraining "Trénink" 0 {Zapnout/vypnout stromový tréninkový mód}
menuText C TreeOptAutosave "Automatické ukládání cache souboru" 1 \
  {Automatické ukládání cache souboru pøi uzavøení stromového okna}
menuText C TreeHelp "Nápovìda" 0
menuText C TreeHelpTree "Nápovìda pro strom" 2
menuText C TreeHelpIndex "Index nápovìdy" 0
translate C SaveCache {Ulo¾it cache}
translate C Training {Trénink}
translate C LockTree {Zamknout}
translate C TreeLocked {Zamknuto}
translate C TreeBest {Nejlep¹í}
translate C TreeBestGames {Nejlep¹í partie stromu}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate C TreeTitleRow \
  {    Move   ECO       Frequency    Score  AvElo Perf AvYear} ;# ***

# Finder window:
menuText C FinderFile "Soubor" 0
menuText C FinderFileSubdirs "Hledat v podadresáøích" 0
menuText C FinderFileClose "Zavøít vyhledávaè souborù" 0
menuText C FinderSort "Øadit" 0
menuText C FinderSortType "Typ" 0
menuText C FinderSortSize "Velikost" 0
menuText C FinderSortMod "Zmìnìno" 0
menuText C FinderSortName "Jméno" 0
menuText C FinderSortPath "Cesta" 0
menuText C FinderTypes "Typy" 0
menuText C FinderTypesScid "Scid databáze" 0
menuText C FinderTypesOld "Scid databáze se starým formátem" 0
menuText C FinderTypesPGN "PGN soubory" 0
menuText C FinderTypesEPD "EPD (knihovní) soubory" 0
menuText C FinderTypesRep "Soubory s repertoárem" 0
menuText C FinderHelp "Nápovìda" 0
menuText C FinderHelpFinder "Nápovìda pro vyhledávaè souborù" 0
menuText C FinderHelpIndex "Index nápovìdy" 0
translate C FileFinder {Vyhledávaè souborù}
translate C FinderDir {Adresáø}
translate C FinderDirs {Adresáøe}
translate C FinderFiles {Soubory}
translate C FinderUpDir {nahoru}

# Player finder:
menuText C PListFile "Soubor" 0
menuText C PListFileUpdate "Aktualizovat" 0
menuText C PListFileClose "Close Player Finder" 0 ;# ***
menuText C PListSort "Øadit" 0
menuText C PListSortName "Name" 0 ;# ***
menuText C PListSortElo "Elo" 0
menuText C PListSortGames "Partie" 0
menuText C PListSortOldest "Oldest" 0 ;# ***
menuText C PListSortNewest "Newest" 0 ;# ***

# Tournament finder:
menuText C TmtFile "Soubor" 0
menuText C TmtFileUpdate "Aktualizovat" 0
menuText C TmtFileClose "Zavøít vyhledávaè souborù" 0
menuText C TmtSort "Øadit" 0
menuText C TmtSortDate "Datum" 0
menuText C TmtSortPlayers "Hráèi" 0
menuText C TmtSortGames "Partie" 0
menuText C TmtSortElo "Elo" 0
menuText C TmtSortSite "Místo" 0
menuText C TmtSortEvent "Turnaj" 0
menuText C TmtSortWinner "Vítìz" 0
translate C TmtLimit "Limit seznamu"
translate C TmtMeanElo "Nejni¾¹í prùmìrné Elo"
translate C TmtNone "®ádné odpovídající turnaje nebyly nalezeny."

# Graph windows:
menuText C GraphFile "Soubor" 0
menuText C GraphFileColor "Ulo¾it jako barevný Postscript..." 8
menuText C GraphFileGrey "Ulo¾it jako èernobílý Postscript..." 8
menuText C GraphFileClose "Zavøít okno" 0
menuText C GraphOptions "Volby" 0
menuText C GraphOptionsWhite "Bílý" 0
menuText C GraphOptionsBlack "Èerný" 1
menuText C GraphOptionsBoth "Oba" 1
menuText C GraphOptionsPInfo "Informace o hráèi" 0
translate C GraphFilterTitle "Graf filtru: èetnost na 1000 partií"

# Analysis window:
translate C AddVariation {Pøidat variantu}
translate C AddMove {Pøidat tah}
translate C Annotate {Anotace}
translate C AnalysisCommand {Program pro analýzu}
translate C PreviousChoices {Pøedchozí vybrané programy}
translate C AnnotateTime {Nastavit èas mezi tahy v sekundách}
translate C AnnotateWhich {Pøidat varianty}
translate C AnnotateAll {Pro tahy obou stran}
translate C AnnotateWhite {Pouze pro tahy bílého}
translate C AnnotateBlack {Pouze pro tahy èerného}
translate C AnnotateNotBest {Pokud tah v partii není nejlep¹ím tahem}

# Analysis Engine open dialog:
translate C EngineList {Seznam programù pro analýzu}
translate C EngineName {Jméno}
translate C EngineCmd {Pøíkaz}
translate C EngineArgs {Parametry}
translate C EngineDir {Adresáø}
translate C EngineElo {Elo}
translate C EngineTime {Datum}
translate C EngineNew {Nový}
translate C EngineEdit {Editace}
translate C EngineRequired {Tuènì vyznaèené polo¾ky jsou povinné; ostatní jsou volitelné}

# Stats window menus:
menuText C StatsFile "Soubor" 0
menuText C StatsFilePrint "Vytisknout do souboru..." 0
menuText C StatsFileClose "Zavøít okno" 0
menuText C StatsOpt "Volby" 0

# PGN window menus:
menuText C PgnFile "Soubor" 0
menuText C PgnFilePrint "Vytisknout do souboru..." 0
menuText C PgnFileClose "Uzavøít okno PGN" 0
menuText C PgnOpt "Zobrazit" 0
menuText C PgnOptColor "Barevné vysvìcování" 0
menuText C PgnOptShort "Krátká (tøíøádková) hlavièka" 0
menuText C PgnOptSymbols "Symbolické anotace" 0
menuText C PgnOptIndentC "Odsazovat komentáøe" 0
menuText C PgnOptIndentV "Odsazovat varianty" 1
menuText C PgnOptColumn "Sloupcový styl (jeden tah na øádek)" 1
menuText C PgnOptSpace "Mezera za èíslem tahu" 0
menuText C PgnOptStripMarks "Odstranit kódy barevných polí a ¹ipek" 1
menuText C PgnColor "Barvy" 2
menuText C PgnColorHeader "Hlavièka..." 0
menuText C PgnColorAnno "Anotace..." 0
menuText C PgnColorComments "Komentáøe..." 0
menuText C PgnColorVars "Varianty..." 0
menuText C PgnColorBackground "Pozadí..." 0
menuText C PgnHelp "Nápovìda" 0
menuText C PgnHelpPgn "PGN nápovìda" 0
menuText C PgnHelpIndex "Index" 0

# Crosstable window menus:
menuText C CrosstabFile "Soubor" 0
menuText C CrosstabFileText "Vytisknout do textového souboru..." 14
menuText C CrosstabFileHtml "Vytisknout do HTML souboru..." 14
menuText C CrosstabFileLaTeX "Vytisknout do LaTeX souboru..." 14
menuText C CrosstabFileClose "Zavøít okno s tabulkou" 0
menuText C CrosstabEdit "Editovat" 0
menuText C CrosstabEditEvent "Turnaj" 0
menuText C CrosstabEditSite "Místo" 0
menuText C CrosstabEditDate "Datum" 0
menuText C CrosstabOpt "Zobrazit" 0
menuText C CrosstabOptAll "V¹ichni-se-v¹emi" 0
menuText C CrosstabOptSwiss "¹výcarský systém" 0
menuText C CrosstabOptKnockout "Knockout" 0
menuText C CrosstabOptAuto "Auto" 0
menuText C CrosstabOptAges "Vìk" 8
menuText C CrosstabOptNats "Národnost" 0
menuText C CrosstabOptRatings "Elo" 0
menuText C CrosstabOptTitles "Titul" 0
menuText C CrosstabOptBreaks "Výsledky tie-breaku" 4
menuText C CrosstabOptDeleted "Vèetnì vymazaných partií" 8
menuText C CrosstabOptColors "Barvy (jen pro ¹výcarský systém)" 0
menuText C CrosstabOptColumnNumbers "Èíslované sloupce (jen v tabulkách 'ka¾dý s ka¾dým')" 2
menuText C CrosstabOptGroup "Skupiny podle skóre" 0
menuText C CrosstabSort "Øadit" 0
menuText C CrosstabSortName "Jméno" 0
menuText C CrosstabSortRating "Elo" 0
menuText C CrosstabSortScore "Skóre" 0
menuText C CrosstabColor "Barvy" 0
menuText C CrosstabColorPlain "Prostý text" 0
menuText C CrosstabColorHyper "Hypertext" 0
menuText C CrosstabHelp "Nápovìda" 0
menuText C CrosstabHelpCross "Nápovìda - Tabulka" 11
menuText C CrosstabHelpIndex "Nápovìda - index" 11
translate C SetFilter {Nastavit filtr}
translate C AddToFilter {Pøidat do filtru}
translate C Swiss {©výcarský systém}
translate C Category {Category} ;# ***

# Opening report window menus:
menuText C OprepFile "Soubor" 0
menuText C OprepFileText "Vytisknout do textového souboru..." 14
menuText C OprepFileHtml "Vytisknout do HTML souboru..." 14
menuText C OprepFileLaTeX "Vytisknout do LaTeX souboru..." 14
menuText C OprepFileOptions "Volby" 0
menuText C OprepFileClose "Zavøít okno s pøehledem" 0
menuText C OprepHelp "Nápovìda" 0
menuText C OprepHelpReport "Nápovìda - Pøehled zahájení" 11
menuText C OprepHelpIndex "Nápovìda - index" 11

# Repertoire editor:
menuText C RepFile "Soubor" 0
menuText C RepFileNew "Nový" 0
menuText C RepFileOpen "Otevøít..." 0
menuText C RepFileSave "Ulo¾it..." 0
menuText C RepFileSaveAs "Ulo¾it jako..." 5
menuText C RepFileClose "Zavøít okno" 0
menuText C RepEdit "Editace" 0
menuText C RepEditGroup "Pøidat skupinu" 4
menuText C RepEditInclude "Zahrnout variantu" 4
menuText C RepEditExclude "Vylouèit variantu" 4
menuText C RepView "Zobrazit" 0
menuText C RepViewExpand "Rozbalit v¹echny skupiny" 0
menuText C RepViewCollapse "Sbalit v¹echny skupiny" 0
menuText C RepSearch "Hledat" 0
menuText C RepSearchAll "Ve¹kerý repertoár..." 0
menuText C RepSearchDisplayed "Pouze zobrazené varianty..." 0
menuText C RepHelp "Nápovìda" 0
menuText C RepHelpRep "Nápovìda pro repertoár" 0
menuText C RepHelpIndex "Nápovìda - index" 11
translate C RepSearch "Vyhledat varianty"
translate C RepIncludedLines "zahrnuté varianty"
translate C RepExcludedLines "vylouèené varianty"
translate C RepCloseDialog {Zmìny v tomto repertoáru nebyly ulo¾eny.

Opravdu chcete pokraèovat a zru¹it v¹echny zmìny, které jste uèinili?
}

# Header search:
translate C HeaderSearch {Hledat podle hlavièky}
translate C GamesWithNoECO {Partie bez ECO?}
translate C GameLength {Délka Partie}
translate C FindGamesWith {Najít partie s}
translate C StdStart {Standardní start}
translate C Promotions {promìnami}
translate C Comments {Komentáøe}
translate C Variations {Varianty}
translate C Annotations {Anotace}
translate C DeleteFlag {Vymazáné}
translate C WhiteOpFlag {Zahájení - bílý}
translate C BlackOpFlag {Zahájení - èerný}
translate C MiddlegameFlag {Støední hra}
translate C EndgameFlag {Koncovka}
translate C NoveltyFlag {Novinka}
translate C PawnFlag {Pì¹cová struktura}
translate C TacticsFlag {Taktika}
translate C QsideFlag {Hra na dámském køídle}
translate C KsideFlag {Hra na královském køídle}
translate C BrilliancyFlag {Briliantní}
translate C BlunderFlag {Hrubky}
translate C UserFlag {U¾ivatel}
translate C PgnContains {PGN obsahuje text}

# Game list window:
translate C GlistNumber {Èíslo}
translate C GlistWhite {Bílý}
translate C GlistBlack {Èerný}
translate C GlistWElo {B-Elo}
translate C GlistBElo {È-Elo}
translate C GlistEvent {Turnaj}
translate C GlistSite {Místo}
translate C GlistRound {Kolo}
translate C GlistDate {Datum}
translate C GlistYear {Rok}
translate C GlistEDate {Turnaj-Datum}
translate C GlistResult {Výsledek}
translate C GlistLength {Délka}
translate C GlistCountry {Zemì}
translate C GlistECO {ECO}
translate C GlistOpening {Zahájení}
translate C GlistEndMaterial {Materiál na konci}
translate C GlistDeleted {Vymazán(a)}
translate C GlistFlags {Pøíznak}
translate C GlistVars {Varianty}
translate C GlistComments {Komentáøe}
translate C GlistAnnos {Anotace}
translate C GlistStart {Poèáteèní pozice}
translate C GlistGameNumber {Èíslo partie}
translate C GlistFindText {Hledat text}
translate C GlistMoveField {Pøesunout}
translate C GlistEditField {Konfigurovat}
translate C GlistAddField {Pøidat}
translate C GlistDeleteField {Odebrat}
translate C GlistWidth {©íøka}
translate C GlistAlign {Zarovnat}
translate C GlistColor {Barva}
translate C GlistSep {Oddìlovaè}

# Maintenance window:
translate C DatabaseName {Jméno databáze:}
translate C TypeIcon {Symbol:}
translate C NumOfGames {Partie:}
translate C NumDeletedGames {Vymazané partie:}
translate C NumFilterGames {Partie ve filtru:}
translate C YearRange {Rozsah rokù:}
translate C RatingRange {Rozsah ELO:}
translate C Description {Description} ;# ***
translate C Flag {Pøíznak}
translate C DeleteCurrent {Vymazat aktuální partii}
translate C DeleteFilter {Vymazat filtrované partie}
translate C DeleteAll {Vymazat v¹echny partie}
translate C UndeleteCurrent {Obnovit aktuální partie po vymazání}
translate C UndeleteFilter {Obnovit filtrovaných partií po vymazání}
translate C UndeleteAll {Obnovit v¹ech partií po vymazání}
translate C DeleteTwins {Vymazat zdvojené partie}
translate C MarkCurrent {Oznaèit aktivní partii}
translate C MarkFilter {Oznaèit filtrované partie}
translate C MarkAll {Oznaèit v¹echny partie}
translate C UnmarkCurrent {Odznaèit aktuální partii}
translate C UnmarkFilter {Odznaèit filtrované partie}
translate C UnmarkAll {Odznaèit v¹echny partie}
translate C Spellchecking {Kontrola pravopisu}
translate C Players {Hráèi}
translate C Events {Turnaje}
translate C Sites {Místa}
translate C Rounds {Kola}
translate C DatabaseOps {Databázové operace}
translate C ReclassifyGames {ECO klasifikace partií}
translate C CompactDatabase {Komprivovat databázi}
translate C SortDatabase {Øadit databázi}
translate C AddEloRatings {Pøidat Elo rating}
translate C AutoloadGame {Automaticky otevírat partii è.}
translate C StripTags {Odstranit PGN znaèky}
translate C StripTag {Odstranit znaèku}
translate C Cleaner {Èi¹tìní databáze}
translate C CleanerHelp {
    Èi¹tìní databáze Scid provede u aktuální databáze v¹echny údr¾báøské akce, které zvolíte v seznamu.

    Pokud zvolíte ECO klasifikaci a mazání zdvojených partií pou¾ijí se aktuální nastavení z pøíslu¹ných dialogù.
}
translate C CleanerConfirm {
Jakmile je èi¹tìní jednou spu¹tìno, nemù¾e ji¾ být pøeru¹eno!

Tato akce mù¾e pro velké databáze trvat dlouhou dobu v závislosti na funkcích, které jste zvolili, a v závislosti na jejich stávajícím nastavení.

Jste si jisti, ¾e chcete zaèít s udr¾báøskými funkcemi, které jste zvolili?
}

# Comment editor:
translate C AnnotationSymbols  {Anotaèní symboly:}
translate C Comment {Komentáø:}
translate C InsertMark {Insert mark} ;# ***

# Board search:
translate C BoardSearch {Hledat pozici}
translate C FilterOperation {Operace s aktuálním filtrem:}
translate C FilterAnd {A (Omezit filtr)}
translate C FilterOr {NEBO (Pøidat k filtru)}
translate C FilterIgnore {IGNOROVAT (Ignoruj filtr)}
translate C SearchType {Typ hledání:}
translate C SearchBoardExact {Pøesná pozice (v¹echny figury na stejných polích)}
translate C SearchBoardPawns {Pì¹ci (tentý¾ materiál, v¹ichni pì¹ci na tých¾ polích)}
translate C SearchBoardFiles {Øady (tentý¾ materiál, v¹ichni pì¹ci na stejných øadách)}
translate C SearchBoardAny {Materiál (tentý¾ materiál, pì¹ci a figury kdekoliv)}
translate C LookInVars {Dívat se do variant}

# Material search:
translate C MaterialSearch {Hledat materiál}
translate C Material {Materiál}
translate C Patterns {Vzory}
translate C Zero {Nic}
translate C Any {Cokoliv}
translate C CurrentBoard {Aktuální pozice}
translate C CommonEndings {Typické koncovky}
translate C CommonPatterns {Typické pozice}
translate C MaterialDiff {Rozdíl v materiálu}
translate C squares {pole}
translate C SameColor {Stejnobarevné}
translate C OppColor {Nestejnobarevné}
translate C Either {Obojí}
translate C MoveNumberRange {Rozsah èísel tahù}
translate C MatchForAtLeast {Shoda pro minimálnì}
translate C HalfMoves {pùltahù}

# Game saving:
translate C Today {Dnes}
translate C ClassifyGame {Klasifikovat partii}

# Setup position:
translate C EmptyBoard {Vyprázdnit ¹achovnici}
translate C InitialBoard {Výchozí pozice}
translate C SideToMove {Na tahu je}
translate C MoveNumber {Èíslo tahu}
translate C Castling {Ro¹áda}
translate C EnPassantFile {En Passant øada}
translate C ClearFen {Vyèistit FEN}
translate C PasteFen {Vlo¾it FEN}

# Replace move dialog:
translate C ReplaceMove {Nahradit tah}
translate C AddNewVar {Pøidat novou variantu}
translate C ReplaceMoveMessage {Zde ji¾ existuje tah.

Mù¾ete ho nahradit, a zru¹it tak i v¹echny následující vlo¾ené tahy, nebo mù¾ete vá¹ tah vlo¾it jako novou variantu.

(Zobrazení této zprávy mù¾ete v budoucnu potlaèit pøepnutím volby "Ptát se pøed nahrazením tahù" v menu Volby:Tahy.)}

# Make database read-only dialog:
translate C ReadOnlyDialog {Pokud databázi nastavíte jako read-only, nebudou povoleny ¾ádné zmìny.
®ádné partie nebude mo¾no ulo¾it a ¾ádný pøíznak nebude mo¾no zmìnit.
V¹echny výsledky operace øazení èi ECO klasifikace budou pouze doèasné.

Databázi mù¾ete uèinit opìt zapisovatelnou pomocí jejího zavøení a opìtovného otevøení.

Pøejete si skuteènì nastavit tuto databázi jako read-only?}

# Clear game dialog:
translate C ClearGameDialog {Tato partie byla zmìnìna.

Skuteènì chcete pokraèovat a zru¹it zmìny, které jste v ní uèinili?
}

# Exit dialog:
translate C ExitDialog {Opravdu si pøejete ukonèit Scid?}
translate C ExitUnsaved {Následující databáze obsahují partie s neulo¾enými zmìnami. Pokud nyní skonèíte, budou tyto zmìny ztraceny.}

# Import window:
translate C PasteCurrentGame {Vlo¾it aktuální partii}
translate C ImportHelp1 {Zapsat nebo vlo¾it partii ve formátu PGN do rámce nahoøe.}
translate C ImportHelp2 {Jakékoli chyby pøi importu partie zde budou vysvíceny.}

# ECO Browser:
translate C ECOAllSections {v¹echny ECO sekce}
translate C ECOSection {ECO sekce}
translate C ECOSummary {Souhrn pro}
translate C ECOFrequency {Èetnost subkódù pro}

# Opening Report:
translate C OprepTitle {Report zahájení}
translate C OprepReport {Report}
translate C OprepGenerated {Generován}
translate C OprepStatsHist {Statistika a historie}
translate C OprepStats {Statistika}
translate C OprepStatAll {V¹echny partie}
translate C OprepStatBoth {Oba hráèi}
translate C OprepStatSince {Od}
translate C OprepOldest {Nejstar¹í partie}
translate C OprepNewest {Nejnovìj¹í partie}
translate C OprepPopular {Stávající popularita}
translate C OprepFreqAll {Èetnost za v¹echny roky:   }
translate C OprepFreq1   {Bìhem posledního roku:     }
translate C OprepFreq5   {Bìhem posledních 5 let: }
translate C OprepFreq10  {Bìhem posledních 10 let:  }
translate C OprepEvery {jednou z %u partií}
translate C OprepUp {více o %u%s v porovnání se v¹emi roky}
translate C OprepDown {ménì o %u%s v porovnání se v¹emi roky}
translate C OprepSame {¾ádná zmìna pøi porovnání se v¹emi roky}
translate C OprepMostFrequent {Nejèastìj¹í hráèi}
translate C OprepRatingsPerf {ELO a výkonnost}
translate C OprepAvgPerf {Prùmìrné ELO a výkonnost}
translate C OprepWRating {ELO bílý}
translate C OprepBRating {ELO èerný}
translate C OprepWPerf {Výkonnost bílý}
translate C OprepBPerf {Výkonnost èerný}
translate C OprepHighRating {Partie s nejvy¹¹ím prùmìrným ELO}
translate C OprepTrends {Výsledkový trend}
translate C OprepResults {Délka partií a èetnost}
translate C OprepLength {Délka partií}
translate C OprepFrequency {Èetnost}
translate C OprepWWins {Výhry bílý: }
translate C OprepBWins {Výhry èerný: }
translate C OprepDraws {Remízy:      }
translate C OprepWholeDB {celá databáze}
translate C OprepShortest {Nejkrat¹í výhry}
translate C OprepMovesThemes {Tahy a motivy}
translate C OprepMoveOrders {Tahy vedoucí ke zkoumané pozici}
translate C OprepMoveOrdersOne \
  {Nalezena pouze jedna posloupnost tahù vedoucích k této pozici:}
translate C OprepMoveOrdersAll \
  {Nalezeno %u posloupností tahù vedoucích k této pozici:}
translate C OprepMoveOrdersMany \
  {Nalezeno %u posloupností tahù vedoucích k této pozici. Prvních %u jsou:}
translate C OprepMovesFrom {Tahy ze zkoumané pozice}
translate C OprepThemes {Pozièní motivy}
translate C OprepThemeDescription {Èetnost motivù k tahu è. %u}
translate C OprepThemeSameCastling {Ro¹ády na stejnou stranu}
translate C OprepThemeOppCastling {Ro¹ády na rùzné strany}
translate C OprepThemeNoCastling {Obì strany bez ro¹ády}
translate C OprepThemeKPawnStorm {Pì¹cový útok na královském køídle}
translate C OprepThemeQueenswap {Vymìnìné dámy}
translate C OprepThemeIQP {Isolovaný dámský pì¹ec}
translate C OprepThemeWP567 {Bílý pì¹ec na 5., 6. nebo 7. øadì}
translate C OprepThemeBP234 {Èerný pì¹ec na 2., 3. nebo 4. øadì}
translate C OprepThemeOpenCDE {Otevøený sloupec C, D nebo E}
translate C OprepTheme1BishopPair {Jedna strana má dvojici støelcù}
translate C OprepEndgames {Koncovky}
translate C OprepReportGames {Report partií}
translate C OprepAllGames {V¹echny partie}
translate C OprepEndClass {Klasifikace materiálu na konci ka¾dé partie}
translate C OprepTheoryTable {Teorie}
translate C OprepTableComment {Generováno z %u s nejvy¹¹ím prùmìrným ELO.}
translate C OprepExtraMoves {Extra poznámkové tahy v tabulce teorie}
translate C OprepMaxGames {Maximum tahù v tabulce teorie}

# Piece Tracker window:
translate C TrackerSelectSingle {Levým tlaèítkem my¹i se tato figura vybere.} 
translate C TrackerSelectPair {Levým tlaèítkem se tato figura vybere; pravým se vyberou obì stejné figury.}
translate C TrackerSelectPawn {Levým tlaèítkem se vybere tento pì¹ec; pravým se vybere v¹ech 8 pì¹cù.}
translate C TrackerStat {Statistika}
translate C TrackerGames {% partií s tahem na pole}
translate C TrackerTime {% èasu na ka¾dém poli}
translate C TrackerMoves {Tahy}
translate C TrackerMovesStart {Vlo¾te èíslo tahu, kterým má stopování zaèít.}
translate C TrackerMovesStop {Vlo¾te èíslo tahu, kterým má stopování skonèit.}

# Game selection dialogs:
translate C SelectAllGames {V¹echny partie v databázi}
translate C SelectFilterGames {Jen filtrované partie}
translate C SelectTournamentGames {Jen partie z aktuálního turnaje}
translate C SelectOlderGames {Jen star¹í partie}

# Delete Twins window:
translate C TwinsNote {Aby byly dvì partie vyhodnoceny jako zdvojené, musí být hrány tými¾ dvìma hráèi a dále musí splòovat kritéria, která nastavíte ní¾e. Pokud jsou nalezeny zdvojené partie, pak je krat¹í z nich vymazána.
Rada: je vhodné provést pøed vymazáním zdvojených partií kontrolu pravopisu, nebo» do zdokonalí detekci zdvojených partií.}
translate C TwinsCriteria {Kritéria: Zdvojené partie musí mít...}
translate C TwinsWhich {Jaké partie prozkoumat?}
translate C TwinsColors {Tyté¾ barvy u hráèù?}
translate C TwinsEvent {Tentý¾ turnaj?}
translate C TwinsSite {Toté¾ místo?}
translate C TwinsRound {Toté¾ kolo?}
translate C TwinsYear {Tentý¾ rok?}
translate C TwinsMonth {Tentý¾ mìsíc?}
translate C TwinsDay {Tentý¾ den?}
translate C TwinsResult {Tentý¾ výsledek?}
translate C TwinsECO {Tentý¾ ECO kód?}
translate C TwinsMoves {Tyté¾ tahy?}
translate C TwinsPlayers {Porovnání jmen:}
translate C TwinsPlayersExact {Pøesná shoda}
translate C TwinsPlayersPrefix {Jen první 4 znaky}
translate C TwinsWhen {Pokud se budou mazat zdvojené partie}
translate C TwinsSkipShort {Ignorovat v¹echny partie krat¹í ne¾ 5 tahù?}
translate C TwinsUndelete {obnovit nejprve v¹echny partie?}
translate C TwinsSetFilter {Nastavit filtr na v¹echny vymazané zdvojené partie?}
translate C TwinsComments {V¾dy zachovat partie s komentáøi?}
translate C TwinsVars {V¾dy zachovat partie s variantami?}
translate C TwinsDeleteWhich {Kterou partii vymazat:}
translate C TwinsDeleteShorter {Krat¹í partii}
translate C TwinsDeleteOlder {Partii s ni¾¹ím èíslem}
translate C TwinsDeleteNewer {Partii s vy¹¹ím èíslem}
translate C TwinsDelete {Vymazat partie}

# Name editor window:
translate C NameEditType {Typ jména pro editaci}
translate C NameEditSelect {Partie k editaci}
translate C NameEditReplace {Nahradit}
translate C NameEditWith {}
translate C NameEditMatches {Shoduje se: Stiskni Ctrl+1 a¾ Ctrl+9 pro výbìr}

# Classify window:
translate C Classify {Klasifikace}
translate C ClassifyWhich {ECO klasifikace partií}
translate C ClassifyAll {V¹echny partie (pøepsat staré ECO kódy)}
translate C ClassifyYear {V¹echny partie hrané za poslední rok}
translate C ClassifyMonth {V¹echny partie hrané za poslední mìsíc}
translate C ClassifyNew {Jen partie, které jsou zatím bez ECO kódu}
translate C ClassifyCodes {Pou¾ít tyto ECO kódy}
translate C ClassifyBasic {Jen základní kódy ("B12", ...)}
translate C ClassifyExtended {Roz¹íøení Scid  ("B12j", ...)}

# Compaction:
translate C NameFile {Jméno souboru}
translate C GameFile {Soubor partií}
translate C Names {Jména}
translate C Unused {Nepou¾ito}
translate C SizeKb {Velikost (kb)}
translate C CurrentState {Aktuální stav}
translate C AfterCompaction {Po komprimaci}
translate C CompactNames {Jméno komprimovaného souboru}
translate C CompactGames {Komprimovat soubor partií}

# Sorting:
translate C SortCriteria {Kritéria}
translate C AddCriteria {Pøidat kritéria}
translate C CommonSorts {Bì¾ná øazení}
translate C Sort {Øazení}

# Exporting:
translate C AddToExistingFile {Pøidat partie do existujícího souboru?}
translate C ExportComments {Exportovat komentáøe?}
translate C ExportVariations {Exportovat varianty?}
translate C IndentComments {Odsazovat komentáøe?}
translate C IndentVariations {Odsazovat varianty?}
translate C ExportColumnStyle {Sloupcový styl (jeden tah na øádek)?}
translate C ExportSymbolStyle {Styl pro zápis komentáøù:}
translate C ExportStripMarks {Odstranit kódové znaèky polí/¹ipek z komentáøù?}

# Goto game/move dialogs:
translate C LoadGameNumber {Vlo¾te èíslo partie:}
translate C GotoMoveNumber {Pøejít na tah èíslo:}

# Copy games dialog:
translate C CopyGames {Kopírovat partie}
translate C CopyConfirm {
 Skuteènì chcete kopírovat
 [thousands $nGamesToCopy] filtrovaných partií
 z databáze "$fromName"
 do databáze "$targetName"?
}
translate C CopyErr {Nelze zkopírovat partie}
translate C CopyErrSource {zdrojová databáze}
translate C CopyErrTarget {cílová databáze}
translate C CopyErrNoGames {nemá ¾ádné partie ve filtru}
translate C CopyErrReadOnly {je pouze pro ètení}
translate C CopyErrNotOpen {není otevøena}

# Colors:
translate C LightSquares {Bílá pole}
translate C DarkSquares {Èerná pole}
translate C SelectedSquares {Vybraná pole}
translate C SuggestedSquares {Navrhované tahy}
translate C WhitePieces {Bílé figury}
translate C BlackPieces {Èerné figury}
translate C WhiteBorder {Obrys bílých figur}
translate C BlackBorder {Obrys èerných figur}

# Novelty window:
translate C FindNovelty {Hledat novinky}
translate C Novelty {Novinka}
translate C NoveltyInterrupt {Hledání novinek pøeru¹eno}
translate C NoveltyNone {V této partii nebyla nalezena ¾ádná novinka}
translate C NoveltyHelp {
Scid bude hledat první tah aktuální partie, který dosáhne pozice, která se nevyskytla ve vybrané databázi ani v ECO knihovnì zahájení.
}

# Upgrading databases:
translate C Upgrading {Upgrade}
translate C ConfirmOpenNew {
Toto je starý formát (Scid 2) databáze, jen¾ není mo¾no otevøít ve Scidu 3. Verze s novým formátem (Scid 3) pøitom ji¾ byla vytvoøena.

Chcete otevøít verzi s novým formátem datábáze?
}
translate C ConfirmUpgrade {
Toto je starý formát (Scid 2) databáze. K otevøení ve Scid 3 je nutno databázi nejprve zkonvertovat do nového formátu.

Upgrade vytvoøí novou verzi databáze; originální soubory se nebudou ani editovat, ani mazat.

Tento úkon mù¾e zabrat trochu èasu, ale je tøeba jej provést pouze jednou. Mù¾ete ho pøeru¹it, pokud bude trvat pøíli¹ dlouho.

Chcete tuto databázi upgradovat nyní?
}

# Recent files options:
translate C RecentFilesMenu {Poèet aktuálních souborù v menu Soubor}
translate C RecentFilesExtra {Poèet aktuálních souborù v extra podnabídce}

}
# end of czech.tcl
