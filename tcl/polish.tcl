### Polish menus for Scid.
# Contributed by Michal Rudolf and Adam Umiastowski.

addLanguage P Polish 0 iso8859-2

proc setLanguage_P {} {

menuText P File "Plik" 0
menuText P FileNew "Nowy..." 0 {Twórz nowa bazê Scid}
menuText P FileOpen "Otwórz..." 0 {Otwórz istniej±c± bazê Scid}
menuText P FileClose "Zamknij" 0 {Zamknij aktywna bazê Scid}
menuText P FileFinder "Poszukiwacz plików" 0 {Otwórz okno poszukiwacza plików}
menuText P FileBookmarks "Zak³adki" 2 {Menu zak³adek (klawisz: Ctrl+B)}
menuText P FileBookmarksAdd "Dodaj zak³adkê" 0 \
  {Dodaj zak³adkê do aktualnej bazy i pozycji}
menuText P FileBookmarksFile "Wstaw zak³adkê" 0 \
  {Wstaw do wybranego katalogu zak³adkê do aktualnej bazy i pozycji}
menuText P FileBookmarksEdit "Edycja zak³adek..." 0 \
  {Edytuj menu zak³adek}
menuText P FileBookmarksList "Wy¶wietlaj katalogi jako listê" 0 \
  {Wy¶wietlaj katalogi zak³adek jako listê, nie jako zagnie¿d¿one menu}
menuText P FileBookmarksSub "Wy¶wietl katalogi jako menu" 0 \
  {Wy¶wietlaj katalogi zak³adek jako zagnie¿d¿one menu, nie jako listê}
menuText P FileMaint "Obs³uga" 1 {Narzêdzia obs³ugi bazy Scid}
menuText P FileMaintWin "Obs³uga" 0 \
  {Otwórz/zamknij obs³ugê bazy Scid}
menuText P FileMaintCompact "Porz±dkuj bazê..." 0 \
  {Porz±dkuj bazê, usuwaj±c skasowane partie i nieu¿ywane nazwiska}
menuText P FileMaintClass "Klasyfikacja debiutowa partii..." 0 \
  {Przelicz klasyfikacjê debiutowa wszystkich partii}
menuText P FileMaintSort "Sortuj bazê..." 0 \
  {Sortuj wszystkie partie w bazie}
menuText P FileMaintDelete "Usuñ podwójne partie..." 0 \
  {Szukaj podwójnych partii i oznacz je do skasowania}
menuText P FileMaintTwin "Wyszukiwanie podwójnych partii" 0 \
  {Otwórz/uaktualnij wyszukiwanie podwójnych partii}
menuText P FileMaintName "Pisownia" 0 \
  {Edycja nazw/nazwisk i kontrola pisowni}
menuText P FileMaintNameEditor "Edytor nazwisk" 0 \
  {Otwórz/zamknij edytor nazwisk}
menuText P FileMaintNamePlayer "Sprawd¼ pisowniê nazwisk..." 17 \
  {Sprawd¼ pisowniê nazwisk przy pomocy pliku nazwisk}
menuText P FileMaintNameEvent "Sprawd¼ pisowniê nazw zawodów..." 22 \
  {Sprawd¼ pisowniê nazw zawodów przy pomocy pliku turniejów}
menuText P FileMaintNameSite "Sprawd¼ pisowniê nazw miejscowo¶ci..." 22 \
  {Sprawd¼ pisowniê nazw miejscowo¶ci przy pomocy pliku miejscowo¶ci}
menuText P FileMaintNameRound "Sprawd¼ numery rund..." 15 \
  {Sprawd¼ numery rund przy pomocy pliku}
menuText P FileReadOnly "Tylko do odczytu..." 0 \
  {Zabezpiecz bazê przed zapisem}
menuText P FileExit "Koniec" 0 {Zamknij Scida}

menuText P Edit "Edytuj" 0
menuText P EditAdd "Dodaj wariant" 0 {Dodaj wariant do ruchu w partii}
menuText P EditDelete "Usuñ wariant" 0 {Usuñ wariant dla tego posuniêcia}
menuText P EditFirst "Twórz pierwszy wariant" 0 \
  {Przesuñ wariant na pierwsze miejsce na li¶cie}
menuText P EditMain "Zmieñ wariant na tekst partii" 0 \
   {Zamieñ wariant i tekst partii}
menuText P EditTrial "Sprawd¼ wariant" 0 \
  {W³±cz/wy³±cz tryb sprawdzania wariantów}
menuText P EditStrip "Usuñ" 2 \
  {Usuñ komentatarze i warianty}
menuText P EditStripComments "Komentarze" 0 \
  {Usuñ wszystkie komentarze z aktualnej partii}
menuText P EditStripVars "Warianty" 0 \
  {Usuñ wszystkie warianty z aktualnej partii}
menuText P EditReset "Opró¿nij schowek" 0 \
  {Opró¿nij schowek bazy}
menuText P EditCopy "Kopiuj partiê do schowka" 0 \
  {Kopiuj partiê do schowka}
menuText P EditPaste "Wklej aktywn± partiê ze schowka" 0 \
  {Wklej aktywn± partiê ze schowka}
menuText P EditSetup "Ustaw pozycjê pocz±tkow±..." 6 \
  {Ustaw pozycjê pocz±tkow± partii}
menuText P EditPasteBoard "Ustaw pozycjê ze schowka" 3 \
  {Ustaw pozycjê ze schowka}

menuText P Game "Partia" 1
menuText P GameNew "Opu¶æ partiê" 0 \
  {Opu¶æ partiê, rezygnuj±c z wszelkich zmian}
menuText P GameFirst "Pierwsza partia" 2 {Za³aduj pierwsz± partiê z filtra}
menuText P GamePrev "Poka¿ poprzedni± partiê" 0 \
  {Poka¿ poprzedni± wyszukan± partiê}
menuText P GameReload "Prze³aduj aktualn± partiê"  10 \
  {Prze³aduj partiê, rezygnuj±c z wszelkich zmian}
menuText P GameNext "Za³aduj nastêpn± partiê" 0 \
  {Za³aduj nastêpn± wyszukan± partiê}
menuText P GameLast "Ostatnia partia" 2 {Za³aduj ostatni± partiê z filtra}
menuText P GameRandom "Load Random Game" 8 {Load a random filtered game} ;# ***
menuText P GameNumber "Za³aduj partiê numer..." 17 \
  {Za³aduj partiê wprowadzaj±c jej numer}
menuText P GameReplace "Zapisz: zast±p partiê..." 3 \
  {Zapisz partiê, zast±p poprzedni± wersjê}
menuText P GameAdd "Zapisz: dodaj now± partiê..." 8 \
  {Zapisz tê partiê jako nowa partiê w bazie}
menuText P GameDeepest "Rozpoznaj debiut" 0 \
  {Przejd¼ do najd³u¿szego wariantu z ksi±¿ki debiutowej}
menuText P GameGotoMove "Przejd¼ do posuniêcia nr..." 13 \
  {Przejd¼ do posuniêcia o podanym numerze}
menuText P GameNovelty "Znajd¼ nowinkê..." 7 \
  {Znajd¼ pierwsze posuniêcie partii niegrane wcze¶niej}

menuText P Search "Szukaj" 0
menuText P SearchReset "Resetuj filtr" 0 \
  {Wstaw wszystkie partie do filtra}
menuText P SearchNegate "Odwróæ filtr" 0 \
  {Zamieñ partie w filtrze i poza nim}
menuText P SearchCurrent "Aktualna pozycja..." 0 \
  {Szukaj aktualnej pozycji}
menuText P SearchHeader "Nag³ówek..." 0 \
  {Szukaj informacji o nag³ówkach (nazwiska, nazwy turnieju itp.)}
menuText P SearchMaterial "Materia³/wzorzec..." 0 \
  {Szukaj wed³ug materia³u lub wzorca}
menuText P SearchUsing "Stosuj plik poszukiwania..." 0 \
  {Szukaj stosuj±c plik z opcjami poszukiwania}

menuText P Windows "Okna" 1
menuText P WindowsComment "Edytor komentarzy" 0 \
  {Otwórz/zamknij edytor komentarzy}
menuText P WindowsGList "Lista partii" 0 {Otwórz/zamknij listê partii}
menuText P WindowsPGN "Okno PGN" 0 {Otwórz/zamknij (zapis partii) PGN }
menuText P WindowsTmt "Turnieje" 0 {Otwórz/zamknij przegl±darkê turniejów}
menuText P WindowsSwitcher "Prze³±cznik baz" 12 \
  {Otwórz/zamknij prze³±cznik baz}
menuText P WindowsMaint "Zarz±dzanie baz±" 0 \
  {Otwórz/zamknij okno zarz±dzania baz±}
menuText P WindowsECO "Przegl±darka kodów debiutowych" 0 \
  {Otwórz/zamknij przegl±darkê kodów debiutowych}
menuText P WindowsRepertoire "Repertuar debiutowy" 0 \
  {Otwórz/zamknij okno repertuaru debiutowego}
menuText P WindowsStats "Statystyka" 0 \
  {Otwórz/zamknij statystykê}
menuText P WindowsTree "Drzewo wariantów" 0 {Otwórz/zamknij drzewo wariantów}
menuText P WindowsTB "Tablica koñcówek" 8 \
  {Otwórz/zamknij okno tablicy koñcówek}

menuText P Tools "Narzêdzia" 0
menuText P ToolsAnalysis "Program analizuj±cy..." 8 \
  {Uruchom/zatrzymaj program analizuj±cy}
menuText P ToolsAnalysis2 "Program analizuj±cy #2..." 21 \
  {Uruchom/zatrzymaj program analizuj±cy}
menuText P ToolsCross "Tabela turniejowa" 0 \
  {Poka¿ tabelê turniejow± dla aktualnej partii}
menuText P ToolsEmail "Zarz±dzanie poczt± e-mail" 0 \
  {Otwórz/zamknij zarz±dzanie adresami e-mail}
menuText P ToolsFilterGraph "Filter graph" 7 \
  {Open/close the filter graph window} ;# ***
menuText P ToolsOpReport "Raport debiutowy" 0 \
  {Utwórz raport debiutowy dla aktualnej pozycji}
menuText P ToolsTracker "¦ledzenie figur"  10 {Otwórz/zamknij okno ¶ledzenia figur} 
menuText P ToolsPInfo "Informacje o zawodniku"  0 \
  {Otwórz/od¶wie¿ okno informacji o zawodniku}
menuText P ToolsRating "Wykres rankingu" 0 \
  {Wykres historii rankingu graj±cych partiê}
menuText P ToolsScore "Wykres wyników" 1 {Poka¿ wykres wyników}
menuText P ToolsExpCurrent "Eksportuj partiê" 0 \
  {Zapisz partiê do pliku tekstowego}
menuText P ToolsExpCurrentPGN "Do pliku PGN..." 9 \
  {Zapisz partiê do pliku PGN}
menuText P ToolsExpCurrentHTML "Do pliku HTML..." 9 \
  {Zapisz partiê do pliku HTML}
menuText P ToolsExpCurrentLaTeX "Do pliku LaTeX-a..." 9 \
  {Zapisz partiê do pliku LaTeX-a}
menuText P ToolsExpFilter "Eksportuj wyszukane partie" 1 \
  {Zapisz wyszukane partie do pliku tekstowego}
menuText P ToolsExpFilterPGN "Do pliku PGN..." 9 \
  {Zapisz wyszukane partie do pliku PGN}
menuText P ToolsExpFilterHTML "Do pliku HTML..." 9 \
  {Zapisz wyszukane partie do pliku HTML}
menuText P ToolsExpFilterLaTeX "Do pliku LaTeX..." 9 \
  {Zapisz wyszukane partie do pliku LaTeX}
menuText P ToolsImportOne "Pobierz partiê z pliku PGN..." 0 \
  {Pobierz partiê z pliku PGN}
menuText P ToolsImportFile "Pobierz plik PGN..." 2 \
  {Pobierz partie z pliku PGN}

menuText P Options "Opcje" 0
menuText P OptionsSize "Wielko¶æ szachownicy" 0 {Zmieñ wielko¶æ szachownicy}
menuText P OptionsPieces "Typ figur" 4 \
  {Zmienia typ wyswietlanych figur} 
menuText P OptionsColors "Kolory..." 0 {Zmieñ kolory szachownicy}
menuText P OptionsExport "Eksport" 0 {Zmieñ opcje eksportu tekstu}
menuText P OptionsFonts "Czcionka" 0 {Zmieñ font}
menuText P OptionsFontsRegular "Podstawowa" 0 {Zmieñ podstawow± czcionkê}
menuText P OptionsFontsMenu "Menu" 0 {Change the menu font} ;# ***
menuText P OptionsFontsSmall "Ma³a" 0 {Zmieñ ma³± czcionkê}
menuText P OptionsFontsFixed "Sta³a" 0 {Zmieñ czcionkê sta³ej szeroko¶ci}
menuText P OptionsGInfo "Informacje o partii" 0 {Sposób wy¶wietlania informacji o partii}
menuText P OptionsLanguage "Jêzyk" 0 {Wybierz jêzyk}
menuText P OptionsMoves "Posuniêcia" 0 {Wprowadzanie posuniêæ}
menuText P OptionsMovesAsk "Zapytaj przed zast±pieniem posuniêæ" 0 \
  {Zapytaj przed zast±pieniem aktualnych posuniêæ}
menuText P OptionsMovesDelay "Automatyczne przegl±danie..." 0 \
  {Ustaw opó¼nienie przy automatycznym przegl±daniu partii}
menuText P OptionsMovesCoord "Posuniêcia w formacie \"g1f3\"" 0 \
  {Akceptuj posuniêcia wprowadzone w formacie "g1f3"}
menuText P OptionsMovesSuggest "Poka¿ proponowane posuniêcia" 1 \
  {W³±cz/wy³±cz proponowanie posuniêæ}
menuText P OptionsMovesKey "Automatyczne dope³nianie posuniêæ" 1 \
  {W³±cz/wy³±cz automatyczne dope³nianie posuniêæ wprowadzanych z klawiatury}
menuText P OptionsNumbers "Format zapisu liczb" 0 {Wybierz format zapisu liczb}
menuText P OptionsStartup "Start" 0 {Wybierz okna, które maj± byæ widoczne po uruchomieniu programu}
menuText P OptionsWindows "Okna" 0 {Opcje okien}
menuText P OptionsWindowsIconify "Minimalizuj wszystkie okna" 0 \
  {Schowaj wszystkie okna przy minimalizacji g³ównego okna}
menuText P OptionsWindowsRaise "Automatyczne uaktywnianie" 0 \
  {Automatycznie uaktywniaj niektóre okna (np. pasek postêpu), gdy s± zas³oniête}
menuText P OptionsToolbar "Pasek narzêdziowy" 6 \
  {Schowaj/poka¿ pasek narzêdziowy}
menuText P OptionsECO "Za³aduj ksi±¿kê debiutow±..." 16 \
  {Za³aduj plik z klasyfikacja debiutów}
menuText P OptionsSpell "Za³aduj plik sprawdzania pisowni..." 13 \
  {Za³aduj plik do sprawdzania pisowni nazwisk i nazw}
menuText P OptionsTable "Katalog z baz± koñcówek..." 10 \
  {Wybierz bazê koñcówek; u¿yte zostan± wszystkie bazy z tego katalogu}
menuText P OptionsRecent "Recent files..." 0 \
  {Change the number of recent files displayed in the File menu} ;# ***
menuText P OptionsSave "Zapamiêtaj opcje" 0 \
  "Zapamiêtaj wszystkie ustawienia w pliku $::optionsFile"
menuText P OptionsAutoSave "Automatycznie zapisuj opcje" 0 \
  {Automatycznie zapisz opcje przy zamykaniu programu}

menuText P Help "Pomoc" 2
menuText P HelpIndex "Spis tre¶ci" 0 {Poka¿ spis tre¶ci pomocy}
menuText P HelpGuide "Krótki przewodnik" 0 {Poka¿ krótki przewodnik}
menuText P HelpHints "Podpowiedzi" 0 {Poka¿ podpowiedzi}
menuText P HelpContact "Informacja o autorze" 0 \
  {Poka¿ informacjê o autorze i stronie Scid-a}
menuText P HelpTip "Porada dnia" 0 {Poka¿ poradê Scida}
menuText P HelpStartup "Okno powitalne" 2 {Pokazuj okno startowe}
menuText P HelpAbout "O programie" 0 {Informacje o programie Scid}

# Game info box popup menu:
menuText P GInfoHideNext "Ukryj nastêpne posuniêcie" 0
menuText P GInfoMaterial "Poka¿ materia³" 0
menuText P GInfoFEN "Poka¿ pozycjê w formacie FEN" 16
menuText P GInfoMarks "Pokazuj kolorowe pola i strza³ki" 5 
menuText P GInfoWrap "Zawijaj d³ugie linie" 0
menuText P GInfoFullComment "Poka¿ ca³y komentarz" 6
menuText P GInfoTBNothing "Tablica koñcówek: nic" 0
menuText P GInfoTBResult "Tablica koñcówek: tylko wynik" 18
menuText P GInfoTBAll "Tablica koñcówek: wszystko" 18
menuText P GInfoDelete "Usuñ/przywróæ tê partiê" 0
menuText P GInfoMark "W³±cz/wy³±cz zaznaczenie tej partii" 0

# Main window buttons:
helpMsg P .button.start {Id¼ do pocz±tku partii (klawisz: Home)}
helpMsg P .button.end {Id¼ na koniec partii  (klawisz: End)}
helpMsg P .button.back {Cofnij o jedno posuniêcie  (klawisz: strza³ka w lewo)}
helpMsg P .button.forward {Jedno posuniêcie do przodu (klawisz: strza³ka w prawo)}
helpMsg P .button.intoVar {Wejd¼ w wariant (klawisz skrótu: v)}
helpMsg P .button.exitVar {Opu¶æ wariant (klawisz skrótu: z)}
helpMsg P .button.flip {Obróæ szachownicê  (klawisz skrótu: .)}
helpMsg P .button.coords {W³±cz lub wy³±cz opis szachownicy  (klawisz skrótu: 0)}
helpMsg P .button.autoplay \
  {Automatyczne przestawianie bierek (klawisz skrótu: Ctrl+Z)}

# General buttons:
translate P Back {Z powrotem}
translate P Cancel {Anuluj}
translate P Clear {Wyczy¶æ}
translate P Close {Zamknij}
translate P Defaults {Domy¶lne}
translate P Delete {Usuñ}
translate P Graph {Wykres}
translate P Help {Pomoc}
translate P Import {Pobierz}
translate P Index {Indeks}
translate P LoadGame {Wczytaj partiê}
translate P BrowseGame {Przegl±daj partiê}
translate P MergeGame {Do³±cz partiê}
translate P Preview {Podgl±d}
translate P Revert {Odwróæ}
translate P Save {Zapisz}
translate P Search {Szukaj}
translate P Stop {Stop}
translate P Store {Zapamiêtaj}
translate P Update {Uaktualnij}
translate P ChangeOrient {Zmieñ po³o¿enie okna}
translate P None {Brak}
translate P First {Pierwsza}
translate P Current {Aktualn±}
translate P Last {Ostatni±}

# General messages:
translate P game {partia}
translate P games {partie}
translate P move {posuniêcie}
translate P moves {pos.}
translate P all {wszystkie}
translate P Yes {Tak}
translate P No {Nie}
translate P Both {Oba}
translate P King {Król}
translate P Queen {Hetman}
translate P Rook {Wie¿a}
translate P Bishop {Goniec}
translate P Knight {Skoczek}
translate P Pawn {Pion}
translate P White {Bia³e}
translate P Black {Czarne}
translate P Player {Gracz}
translate P Rating {Ranking}
translate P RatingDiff {Ró¿nica rankingów}
translate P Event {Turniej}
translate P Site {Miejsce}
translate P Country {Kraj}
translate P IgnoreColors {Ignoruj kolory}
translate P Date {Data}
translate P EventDate {Turniej data}
translate P Decade {Decade} ;# ***
translate P Year {Rok}
translate P Month {Miesi±c}
translate P Months {Styczeñ Luty Marzec Kwiecieñ Maj Czerwiec
  Lipiec Sierpieñ Wrzesieñ Pa¼dziernik Listopad Grudzieñ}
translate P Days {N Pn Wt ¦r Cz Pt So}
translate P YearToToday {Ostatni rok}
translate P Result {Wynik}
translate P Round {Runda}
translate P Length {D³ugo¶æ}
translate P ECOCode {Kod ECO}
translate P ECO {ECO}
translate P Deleted {Usuniêta}
translate P SearchResults {Wyniki wyszukiwania}
translate P OpeningTheDatabase "Otwieranie bazy"
translate P Database {Bazy}
translate P Filter {Filtr}
translate P noGames {brak partii}
translate P allGames {wszystkie partie}
translate P empty {brak}
translate P clipbase {schowek}
translate P score {punkty}
translate P StartPos {Pozycja pocz±tkowa}
translate P Total {Razem}

# Game information:
translate P twin {powtórzona}
translate P deleted {usuniêta}
translate P comment {komentarz}
translate P hidden {ukryte}
translate P LastMove {Poprzednie}
translate P NextMove {nastêpne}
translate P GameStart {Pocz±tek partii}
translate P LineStart {Pocz±tek wariantu}
translate P GameEnd {Koniec partii}
translate P LineEnd {Koniec wariantu}

# Player information:
translate P PInfoAll {Wyniki - <b>wszystkie</b> partie}
translate P PInfoFilter {Wyniki - partie z <b>filtra</b>}
translate P PInfoAgainst {Wyniki - }
translate P PInfoMostWhite {Najczêstsze debiuty bia³ymi}
translate P PInfoMostBlack {Najczêstsze debiuty czarnymi}
translate P PInfoRating {Historia rankingu}
translate P PInfoBio {Biografia}

# Tablebase information:
translate P Draw {remis}
translate P stalemate {pat}
translate P withAllMoves {po dowolnym posuniêciu}
translate P withAllButOneMove {po dowolnym posuniêciu oprócz}
translate P with {po}
translate P only {tylko}
translate P lose {przegrywaj±}
translate P loses {przegrywa}
translate P allOthersLose {inne posuniêcia przegrywaj±}
translate P matesIn {matuj± w}
translate P hasCheckmated {matuj±}
translate P longest {najlepsze}

# Tip of the day:
translate P Tip {Porada}
translate P TipAtStartup {Poka¿ poradê przy starcie}

# Tree window menus:
menuText P TreeFile "Plik" 0
menuText P TreeFileSave "Zapisz bufor" 7 {Zapisz plik bufora (.stc)}
menuText P TreeFileFill "Twórz standardowy plik cache" 0 {Wstaw typowe pozycje debiutowe do bufora}
menuText P TreeFileBest "Najlepsze partie" 0 {Poka¿ listê najlepszych partii}
menuText P TreeFileGraph "Poka¿ wykres" 0 {Poka¿ wykres dla tej ga³êzi drzewa}
menuText P TreeFileCopy "Kopiuj drzewo do schowka" 0 \
  {Skopiuj drzewo ze statystykami do schowka}
menuText P TreeFileClose "Zamknij" 0 {Zamknij okno drzewa}
menuText P TreeSort "Sortowanie" 0
menuText P TreeSortAlpha "Alfabetycznie" 0
menuText P TreeSortECO "Kod ECO" 0
menuText P TreeSortFreq "Czêsto¶æ" 0
menuText P TreeSortScore "Punkty" 0
menuText P TreeOpt "Opcje" 0
menuText P TreeOptLock "Blokada" 0 {Zablokuj/odblokuj drzewo na aktualnej bazie}
menuText P TreeOptTraining "Trening" 0 {W³±cz/wy³±cz tryb treningowy}
menuText P TreeOptAutosave "Automatyczny zapis bufora" 0 \
  {Automatycznie zapisz plik bufora przy wyj¶ciu}
menuText P TreeHelp "Pomoc" 2
menuText P TreeHelpTree "Drzewo" 0
menuText P TreeHelpIndex "Spis tre¶ci" 0
translate P SaveCache {Zapisz bufor}
translate P Training {Trening}
translate P LockTree {Blokada}
translate P TreeLocked {zablokowane}
translate P TreeBest {Najlepsze}
translate P TreeBestGames {Najlepsze partie}

# Finder window:
menuText P FinderFile "Plik" 0
menuText P FinderFileSubdirs "Przeszukuj podkatalogi" 0
menuText P FinderFileClose "Zamknij wyszukiwacza plików" 0
menuText P FinderSort "Sortowanie" 0
menuText P FinderSortType "Typ" 0
menuText P FinderSortSize "Rozmiar" 0
menuText P FinderSortMod "Zmieniony" 0
menuText P FinderSortName "Nazwa" 0
menuText P FinderSortPath "¦cie¿ka" 0
menuText P FinderTypes "Typy" 0
menuText P FinderTypesScid "Bazy Scid-a" 0
menuText P FinderTypesOld "Bazy Scid-a (stary format)" 1
menuText P FinderTypesPGN "Pliki PGN" 0
menuText P FinderTypesEPD "Ksi±¿ki debiutowe EPD" 0
menuText P FinderTypesRep "Pliki repertuaru debiutowego" 0
menuText P FinderHelp "Pomoc" 2
menuText P FinderHelpFinder "Pomoc poszukiwacza plików" 1
menuText P FinderHelpIndex "Spis tre¶ci" 0
translate P FileFinder {Poszukiwacz plików}
translate P FinderDir {Katalog}
translate P FinderDirs {Katalogi}
translate P FinderFiles {Pliki}
translate P FinderUpDir {wy¿ej}

# Tournament finder:
menuText P TmtFile "Plik" 0
menuText P TmtFileUpdate "Uaktualnij" 0
menuText P TmtFileClose "Zamknij turnieje" 0
menuText P TmtSort "Sortowanie" 0
menuText P TmtSortDate "Data" 0
menuText P TmtSortPlayers "Zawodnicy" 0
menuText P TmtSortGames "Partie" 0
menuText P TmtSortElo "Elo" 0
menuText P TmtSortSite "Miejsce" 0
menuText P TmtSortEvent "Turniej" 0
menuText P TmtSortWinner "Zwyciêzca" 0
translate P TmtLimit "Max. turniejów"
translate P TmtMeanElo "Min. ¶rednie ELO"
translate P TmtNone "Nie znaleziono turniejów."

# Graph windows:
menuText P GraphFile "Plik" 0
menuText P GraphFileColor "Zapisz jako kolorowy PostScript" 12
menuText P GraphFileGrey "Zapisz jako zwyk³y PostScript..." 0
menuText P GraphFileClose "Zamknij okno" 6
menuText P GraphOptions "Opcje" 0
menuText P GraphOptionsWhite "Bia³e" 0
menuText P GraphOptionsBlack "Czarne" 0
menuText P GraphOptionsBoth "Oba kolory" 1
menuText P GraphOptionsPInfo "Gracz z Informacji o graczu" 0
translate P GraphFilterTitle "Filter graph: frequency per 1000 games" ;# ***

# Analysis window:
translate P AddVariation {Dodaj wariant}
translate P AddMove {Dodaj posuniêcie}
translate P Annotate {Komentuj}
translate P AnalysisCommand {Program do analizy}
translate P PreviousChoices {Poprzednie programy}
translate P AnnotateTime {Czas miêdzy ruchami (w sekundach)}
translate P AnnotateWhich {Dodaj warianty}
translate P AnnotateAll {Dla obu stron}
translate P AnnotateWhite {Dla bia³ych}
translate P AnnotateBlack {Dla czarnych}
translate P AnnotateNotBest {Tylko dla posuniêæ lepszych ni¿ w partii}

# Analysis Engine open dialog:
translate P EngineList {Programy szachowe}
translate P EngineName {Nazwa}
translate P EngineCmd {Polecenie}
translate P EngineArgs {Parametry} 
translate P EngineDir {Katalog}
translate P EngineElo {Elo}
translate P EngineTime {Data}
translate P EngineNew {Dodaj}
translate P EngineEdit {Edytuj}
translate P EngineRequired {Pola wyt³uszczone s± konieczne; reszta opcjonalna} 

# Stats window menus:
menuText P StatsFile "Plik" 0
menuText P StatsFilePrint "Zapisz do pliku..." 7
menuText P StatsFileClose "Zamknij" 0
menuText P StatsOpt "Opcje" 0

# PGN window menus:
menuText P PgnFile "Plik" 0
menuText P PgnFilePrint "Zapisz do pliku..." 7
menuText P PgnFileClose "Zamknij" 0
menuText P PgnOpt "Wygl±d" 0
menuText P PgnOptColor "Wy¶wietlanie w kolorach" 0
menuText P PgnOptShort "Krótki (3-wierszowy) nag³ówek" 0
menuText P PgnOptSymbols "Symbole Informatora" 0
menuText P PgnOptIndentC "Wcinaj komentarze" 7
menuText P PgnOptIndentV "Wcinaj warianty" 7
menuText P PgnOptColumn "Kolumny (jedno posuniêcie w wierszu)" 0
menuText P PgnOptSpace "Spacja po numerze ruchu" 0
menuText P PgnOptStripMarks "Usuñ kody kolorowych pól i strza³ek" 0
menuText P PgnColor "Kolory" 0
menuText P PgnColorHeader "Nag³ówek..." 0
menuText P PgnColorAnno "Uwagi..." 3
menuText P PgnColorComments "Komentarze..." 0
menuText P PgnColorVars "Warianty..." 0
menuText P PgnColorBackground "T³o..." 0
menuText P PgnHelp "Pomoc" 2
menuText P PgnHelpPgn "PGN" 0
menuText P PgnHelpIndex "Spis tre¶ci" 0

# Crosstable window menus:
menuText P CrosstabFile "Plik" 0
menuText P CrosstabFileText "Zapisz w pliku tekstowym..." 15
menuText P CrosstabFileHtml "Zapisz w pliku HTML..." 15
menuText P CrosstabFileLaTeX "Zapisz w pliku LaTeX-a..." 15
menuText P CrosstabFileClose "Zamknij" 0
menuText P CrosstabEdit "Edytuj" 0
menuText P CrosstabEditEvent "Turniej" 0
menuText P CrosstabEditSite "Miejsce" 0
menuText P CrosstabEditDate "Data" 0
menuText P CrosstabOpt "Wy¶wietlanie" 0
menuText P CrosstabOptAll "Turniej ko³owy" 0
menuText P CrosstabOptSwiss "Szwajcar" 0
menuText P CrosstabOptKnockout "Knockout" 0
menuText P CrosstabOptAuto "Automatycznie" 0
menuText P CrosstabOptAges "Wiek" 0
menuText P CrosstabOptNats "Narodowo¶æ" 0
menuText P CrosstabOptRatings "Ranking" 0
menuText P CrosstabOptTitles "Tytu³" 0
menuText P CrosstabOptBreaks "Punkty pomocnicze" 1
menuText P CrosstabOptDeleted "Uwzglêdniaj usuniête partie" 0
menuText P CrosstabOptColors "Kolory (tylko szwajcar)" 0
menuText P CrosstabOptColumnNumbers "Numerowane kolumny (tylko turniej ko³owy)" 0
menuText P CrosstabOptGroup "Grupuj po liczbie punktów" 0
menuText P CrosstabSort "Sortowanie" 0
menuText P CrosstabSortName "Nazwisko" 0
menuText P CrosstabSortRating "Ranking" 0
menuText P CrosstabSortScore "Punkty" 0
menuText P CrosstabColor "Kolor" 0
menuText P CrosstabColorPlain "Zwyk³y tekst" 0
menuText P CrosstabColorHyper "Hipertekst" 0
menuText P CrosstabHelp "Pomoc" 2
menuText P CrosstabHelpCross "Tabela turniejowa" 0
menuText P CrosstabHelpIndex "Spis tre¶ci" 0
translate P SetFilter {Ustaw filtr}
translate P AddToFilter {Dodaj do filtra}
translate P Swiss {Szwajcar}

# Opening report window menus:
menuText P OprepFile "Plik" 0
menuText P OprepFileText "Zapisz w pliku tekstowym..." 15
menuText P OprepFileHtml "Zapisz w pliku HTML..." 15
menuText P OprepFileLaTeX "Zapisz w pliku LaTeX-a..." 15
menuText P OprepFileOptions "Opcje" 2
menuText P OprepFileClose "Zamknij okno raportu" 0
menuText P OprepHelp "Pomoc" 2
menuText P OprepHelpReport "Pomoc raportu debiutowego" 0
menuText P OprepHelpIndex "Spis tre¶ci" 0

# Repertoire editor:
menuText P RepFile "Plik" 0
menuText P RepFileNew "Nowy" 0
menuText P RepFileOpen "Otwórz..." 0
menuText P RepFileSave "Zapisz" 0
menuText P RepFileSaveAs "Zapisz jako..." 7
menuText P RepFileClose "Zamknij" 3
menuText P RepEdit "Edytuj" 0
menuText P RepEditGroup "Dodaj grupê" 6
menuText P RepEditInclude "W³±cz wariant" 0
menuText P RepEditExclude "Wy³±cz wariant" 1
menuText P RepView "Widok" 0
menuText P RepViewExpand "Rozwiñ wszystkie grupy" 0
menuText P RepViewCollapse "Zwiñ wszystkie grupy" 0
menuText P RepSearch "Szukaj" 0
menuText P RepSearchAll "Wszystkie warianty..." 0
menuText P RepSearchDisplayed "Tylko widoczne warianty..." 0
menuText P RepHelp "Pomoc" 2
menuText P RepHelpRep "Repertuar debiutowy" 0
menuText P RepHelpIndex "Spis tre¶ci" 0
translate P RepSearch "Poszukiwanie wariantów"
translate P RepIncludedLines "w³±czone warianty"
translate P RepExcludedLines "wy³±czone warianty"
translate P RepCloseDialog {Ten repertuar ma niezapisane zmiany.

Na pewno zamkn±æ repertuar, rezygnuj±c z wszelkich zmian?
}

# Header search:
translate P HeaderSearch {Wyszukiwanie wg nag³ówka}
translate P GamesWithNoECO {Partie bez ECO?}
translate P GameLength {D³ugo¶æ}
translate P FindGamesWith {Znajd¼ partie}
translate P StdStart {ca³a partia}
translate P Promotions {z promocj±}
translate P Comments {Komentarze}
translate P Variations {Warianty}
translate P Annotations {Uwagi}
translate P DeleteFlag {Usuwanie}
translate P WhiteOpFlag {Debiut - bia³e}
translate P BlackOpFlag {Debiut - czarne}
translate P MiddlegameFlag {Gra ¶rodkowa}
translate P EndgameFlag {Koñcówka}
translate P NoveltyFlag {Nowinka}
translate P PawnFlag {Struktura pionowa}
translate P TacticsFlag {Taktyka}
translate P QsideFlag {Gra na skrzydle hetmañskim}
translate P KsideFlag {Gra na skrzydle królewskim}
translate P BrilliancyFlag {Nagroda za piêkno¶æ}
translate P BlunderFlag {Podstawka}
translate P UserFlag {Inne}
translate P PgnContains {PGN zawiera tekst}

# Game list window:
translate P GlistNumber {Numer}
translate P GlistWhite {Bia³e}
translate P GlistBlack {Czarne}
translate P GlistWElo {B-Elo}
translate P GlistBElo {C-Elo}
translate P GlistEvent {Turniej}
translate P GlistSite {Miejsce}
translate P GlistRound {Runda}
translate P GlistDate {Data}
translate P GlistYear {Rok}
translate P GlistEDate {Turniej-Data}
translate P GlistResult {Wynik}
translate P GlistLength {D³ugo¶æ}
translate P GlistCountry {Kraj}
translate P GlistECO {ECO}
translate P GlistOpening {Debiut}
translate P GlistEndMaterial {Materia³}
translate P GlistDeleted {Usuniêta}
translate P GlistFlags {Oznaczenie}
translate P GlistVars {Warianty}
translate P GlistComments {Komentarze}
translate P GlistAnnos {Uwagi}
translate P GlistStart {Pozycja pocz±tkowa}
translate P GlistGameNumber {Numer partii}
translate P GlistFindText {Znajd¼ tekst}
translate P GlistMoveField {Przesuñ}
translate P GlistEditField {Konfiguruj}
translate P GlistAddField {Dodaj}
translate P GlistDeleteField {Usuñ}
translate P GlistWidth {Szeroko¶æ}
translate P GlistAlign {Wyrównanie}
translate P GlistColor {Kolor}
translate P GlistSep {Separator}

# Maintenance window:
translate P DatabaseName {Nazwa bazy:}
translate P TypeIcon {Ikona:}
translate P NumOfGames {Liczba partii:}
translate P NumDeletedGames {Liczba usuniêtych partii:}
translate P NumFilterGames {Liczba partii w filtrze:}
translate P YearRange {Data:}
translate P RatingRange {Ranking:}
translate P Flag {Oznaczenie:}
translate P DeleteCurrent {Usuñ aktualn± partiê}
translate P DeleteFilter {Usuñ partie z filtra}
translate P DeleteAll {Usuñ wszystkie partie}
translate P UndeleteCurrent {Odzyskaj aktualn± partiê}
translate P UndeleteFilter {Odzyskaj partie z filtra}
translate P UndeleteAll {Odzyskaj wszystkie partie}
translate P DeleteTwins {Usuñ powtórzone partie}
translate P MarkCurrent {Zaznacz aktualn± partiê}
translate P MarkFilter {Zaznacz partie z filtra}
translate P MarkAll {Zaznacz wszystkie partie z filtra}
translate P UnmarkCurrent {Usuñ zaznaczenie aktualnej partii}
translate P UnmarkFilter {Usuñ zaznaczenie partii z filtra}
translate P UnmarkAll {Usuñ zaznaczenie wszystkich partii}
translate P Spellchecking {Pisownia}
translate P Players {Zawodnicy}
translate P Events {Turnieje}
translate P Sites {Miejsca}
translate P Rounds {Rundy}
translate P DatabaseOps {Operacje bazodanowe}
translate P ReclassifyGames {Klasyfikacja debiutowa}
translate P CompactDatabase {Uporz±dkuj bazê}
translate P SortDatabase {Sortuj bazê}
translate P AddEloRatings {Dodaj rankingi ELO}
translate P AutoloadGame {Domy¶lna partia}
translate P StripTags {Strip PGN tags} ;# ***
translate P StripTag {Strip tag} ;# ***
translate P Cleaner {Zestaw zadañ}
translate P CleanerHelp {
Zestaw zadañ pozwala wykonaæ od razu kilka operacji porz±dkowania bazy. Operacje wybrane z listy
zostan± wykonane na aktualnej bazie.

Do klasyfikacji debiutowej i usuwania powtórzonych partii u¿yte zostan± aktualne ustawienia.
}
translate P CleanerConfirm {
Kiedy wykonanie zestawu zadañ zostanie rozpoczête, nie bêdzie mo¿na ju¿ go przerwaæ.

Na du¿ej bazie mo¿e to zaj±æ du¿o czasu (zale¿y to równie¿ od wybranego zestawu zadañ i ich
ustawieñ).

Na pewno wykonaæ wybrane zadania?
}

# Comment editor:
translate P AnnotationSymbols  {Symbole:}
translate P Comment {Komentarz:}

# Board search:
translate P BoardSearch {Wyszukiwanie wg pozycji}
translate P FilterOperation {Operacje na aktualnym filtrze:}
translate P FilterAnd {I (ogranicz filtr)}
translate P FilterOr {LUB (dodaj do filtr)}
translate P FilterIgnore {NOWY (ignoruj poprzedni filtr)}
translate P SearchType {Typ wyszukiwania:}
translate P SearchBoardExact {Identyczna pozycja (bierki na tych samych polach)}
translate P SearchBoardPawns {Pionki (ten sam materia³, pionki na tych samych polach)}
translate P SearchBoardFiles {Kolumny (ten sam materia³, pionki na tych samych kolumnach)}
translate P SearchBoardAny {Materia³ (ten sam materia³, pozycja dowolna)}
translate P LookInVars {Przeszukuj warianty}

# Material search:
translate P MaterialSearch {Wyszukiwanie wg materia³u}
translate P Material {Materia³}
translate P Patterns {Wzorce}
translate P Zero {Brak}
translate P Any {Dowolny}
translate P CurrentBoard {Aktualna pozycja}
translate P CommonEndings {Typowe koñcówki}
translate P CommonPatterns {Typowe wzorce}
translate P MaterialDiff {Przewaga materialna}
translate P squares {pola}
translate P SameColor {jednopolowe}
translate P OppColor {ró¿nopolowe}
translate P Either {dowolne}
translate P MoveNumberRange {Zakres posuniêæ}
translate P MatchForAtLeast {Pasuje min.}
translate P HalfMoves {pó³ruchy}

# Game saving:
translate P Today {Dzisiaj}
translate P ClassifyGame {Klasyfikacja debiutowa}

# Setup position:
translate P EmptyBoard {Pusta szachownica}
translate P InitialBoard {Pozycja pocz±tkowa}
translate P SideToMove {Na posuniêciu}
translate P MoveNumber {Posuniêcie nr}
translate P Castling {Roszada}
translate P EnPassentFile {Bicie w przelocie}
translate P ClearFen {Kopiuj FEN}
translate P PasteFen {Wklej pozycjê FEN}

# Replace move dialog:
translate P ReplaceMove {Zmieñ posuniêcie}
translate P AddNewVar {Dodaj wariant}
translate P ReplaceMoveMessage {Posuniêcie ju¿ istnieje.

Mo¿esz je zast±piæ, usuwaj±c dalszy ci±g partii lub dodaæ nowy wariant.

(Mo¿na wy³±czyæ to ostrze¿enie, wy³±czaj±c opcjê  "Zapytaj przed zast±pieniem posuniêæ" w menu
Opcje:Posuniêcia)}

# Make database read-only dialog:
translate P ReadOnlyDialog {Je¶li zabezpieczysz tê bazê przed zapisem, zmiany bêd± zablokowane
¯adna partia nie bêdzie zapisana ani zmodyfikowana, ¿adne flagi nie bêd± zmienione.
Sortowanie i klasyfikacja debiutowa bêd± tylko tymczasowe.

¯eby usun±æ zabezpieczenie przez zapisem, wystarczy zamkn±æ bazê i otworzyæ j± ponownie.

Na pewno zabezpieczyæ bazê przed zapisem?}

# Clear game dialog:
translate P ClearGameDialog {Partia zosta³a zmieniona.

Na pewno kontynuowaæ, rezygnuj±c z wszelkich zmian?
}

# Exit dialog:
translate P ExitDialog {Na pewno zakoñczyæ pracê z programem?}
translate P ExitUnsaved {Nastêpuj±ce bazy zawieraj± niezapisane zmiany. 
Je¶li zamkniesz program teraz, zmiany zostan± utracone.} 

# Import window:
translate P PasteCurrentGame {Wklej aktualn± partiê}
translate P ImportHelp1 {Wprowad¼ lub wklej partiê w formacie PGN w poni¿sz± ramkê.}
translate P ImportHelp2 {Tu bêd± wy¶wietlane b³êdy przy importowaniu partii.}

# ECO Browser:
translate P ECOAllSections {Wszystkie kody ECO}
translate P ECOSection {Czê¶æ ECO}
translate P ECOSummary {Podsumowanie dla}
translate P ECOFrequency {Czêsto¶ci kodów dla}

# Opening Report:
translate P OprepTitle {Raport debiutowy}
translate P OprepReport {Raport}
translate P OprepGenerated {Utworzony przez}
translate P OprepStatsHist {Statystyka i historia}
translate P OprepStats {Statystyka}
translate P OprepStatAll {Wszystkie partie}
translate P OprepStatBoth {Obaj zawodnicy z Elo}
translate P OprepStatSince {Od}
translate P OprepOldest {Najdawniejsze partie}
translate P OprepNewest {Ostatnie partie}
translate P OprepPopular {Popularno¶æ}
translate P OprepFreqAll {Czêsto¶æ w ca³ej bazie:         }
translate P OprepFreq1   {W ostatnim roku:                }
translate P OprepFreq5   {W ostatnich piêciu latach:      }
translate P OprepFreq10  {W ostatnich dziesiêciu latach:  }
translate P OprepEvery {co %u partii}
translate P OprepUp {wiêcej o %u%s ni¿ w ca³ej bazie}
translate P OprepDown {mniej o %u%s ni¿ w ca³ej bazie}
translate P OprepSame {jak w ca³ej bazie}
translate P OprepMostFrequent {Zawodnicy najczê¶ciej graj±cy wariant}
translate P OprepRatingsPerf {Rankingi i wyniki}
translate P OprepAvgPerf {¦rednie rankingi i wyniki}
translate P OprepWRating {Ranking bia³ych}
translate P OprepBRating {Ranking czarnych}
translate P OprepWPerf {Wynik bia³ych}
translate P OprepBPerf {Wynik czarnych}
translate P OprepHighRating {Partie graczy o najwy¿szym ¶rednim rankingu}
translate P OprepTrends {Wyniki}
translate P OprepResults {D³ugo¶æ partii i czêsto¶ci}
translate P OprepLength {D³ugo¶æ partii}
translate P OprepFrequency {Czêsto¶æ}
translate P OprepWWins {Zwyciêstwa bia³ych:  }
translate P OprepBWins {Zwyciêstwa czarnych: }
translate P OprepDraws {Remisy:              }
translate P OprepWholeDB {ca³a baza}
translate P OprepShortest {Najkrótsze zwyciêstwa}
translate P OprepMovesThemes {Posuniêcia i motywy}
translate P OprepMoveOrders {Posuniêcia prowadz±ce do badanej pozycji}
translate P OprepMoveOrdersOne \
  {Badana pozycja powstawa³a jedynie po posuniêciach:}
translate P OprepMoveOrdersAll \
  {Badana pozycja powstawa³a na %u sposobów:}
translate P OprepMoveOrdersMany \
  {Badana pozycja powstawa³a na %u sposobów. Najczêstsze %u to:}
translate P OprepMovesFrom {Posuniêcia w badanej pozycji}
translate P OprepThemes {Motywy pozycyjne}
translate P OprepThemeDescription {Czêsto¶æ wystêpowania motywów w ruchu %u}
translate P OprepThemeSameCastling {Jednostronne roszady}
translate P OprepThemeOppCastling {Ró¿nostronne roszady}
translate P OprepThemeNoCastling {Obie strony bez roszady}
translate P OprepThemeKPawnStorm {Atak pionowy na skrzydle królewskim}
translate P OprepThemeQueenswap {Wymiana hetmanów}
translate P OprepThemeIQP {Izolowany pion d}
translate P OprepThemeWP567 {Bia³y pion na 5/6/7 linii}
translate P OprepThemeBP234 {Czarny pion na 2/3/4 linii}
translate P OprepThemeOpenCDE {Otwarta kolumna c/d/e}
translate P OprepTheme1BishopPair {Jedna ze stron ma parê goñców}
translate P OprepEndgames {Koñcówki}
translate P OprepReportGames {Partie raportu}
translate P OprepAllGames {Wszystkie partie}
translate P OprepEndClass {Materia³ w pozycji koñcowej}
translate P OprepTheoryTable {Teoria}
translate P OprepTableComment {Utworzono z %u partii o najwy¿szym ¶rednim rankingu.}
translate P OprepExtraMoves {Dodatkowe posuniêcia w przypisach}
translate P OprepMaxGames {Maksymalna liczba partii w teorii}

# Piece Tracker window:
translate P TrackerSelectSingle {Lewy przycisk wybiera tê figurê.} ;# ***
translate P TrackerSelectPair {Lewy przycisk wybiera tê figurê; prawy obie takie figury.}
translate P TrackerSelectPawn {Lewy przycisk wybiera tego piona; prawy wszystkie 8 pionów.}
translate P TrackerStat {Statystyka}
translate P TrackerGames {% partie z posuniêciem na tym pole}
translate P TrackerTime {% czasu na tym polu}
translate P TrackerMoves {Posuniêcia}
translate P TrackerMovesStart {Podaj numer posuniêcia, od którego zacz±æ ¶ledzenie.}
translate P TrackerMovesStop {Podaj numer posuniêcia, na którym skoñczyæ ¶ledzenie.}

# Game selection dialogs:
translate P SelectAllGames {Wszystkie partie w bazie}
translate P SelectFilterGames {Partie w filtrze}
translate P SelectTournamentGames {Tylko partie z aktualnego turnieju}
translate P SelectOlderGames {Tylko wcze¶niejsze partie}

# Delete Twins window:
translate P TwinsNote {Partie zostan± uznane za identyczne, je¶li zosta³y rozegrane przez tych
samych graczy i spe³niaj± ustawione poni¿ej kryteria. Krótsza z partii zostanie usuniêta.
Uwaga: dobrze przez wyszukaniem powtórzonych partii sprawdziæ pisowniê nazwisk.}
translate P TwinsCriteria {Kryteria: co musi byæ jednakowe w obu partiach?}
translate P TwinsWhich {Przeszukiwane partie}
translate P TwinsColors {Kolory}
translate P TwinsEvent {Turniej:}
translate P TwinsSite {Miejsce:}
translate P TwinsRound {Runda:}
translate P TwinsYear {Rok:}
translate P TwinsMonth {Miesi±c:}
translate P TwinsDay {Dzieñ:}
translate P TwinsResult {Wynik:}
translate P TwinsECO {Kod ECO:}
translate P TwinsMoves {Posuniêcia:}
translate P TwinsPlayers {Porównywanie nazwisk:}
translate P TwinsPlayersExact {Dok³adne}
translate P TwinsPlayersPrefix {Tylko pierwsze 4 litery}
translate P TwinsWhen {Usuwanie znalezionych powtórzonych partii}
translate P TwinsSkipShort {Pomijaæ partie krótsze ni¿ 5 posuniêæ?}
translate P TwinsUndelete {Odzyskaæ wszystkie partie przed poszukiwaniem?}
translate P TwinsSetFilter {Wstawiæ wszystkie usuniête partie do filtra?}
translate P TwinsComments {Zawsze zachowywaæ partie komentowane?}
translate P TwinsVars {Zawsze zachowywaæ partie z wariantami?}
translate P TwinsDeleteWhich {Któr± partiê usun±æ:} 
translate P TwinsDeleteShorter {Krótsz±} 
translate P TwinsDeleteOlder {O ni¿szym numerze}
translate P TwinsDeleteNewer {O wy¿szym numerze}
translate P TwinsDelete {Usuñ partie}

# Name editor window:
translate P NameEditType {Nazwa do wyboru}
translate P NameEditSelect {Partie do edycji}
translate P NameEditReplace {Zast±p}
translate P NameEditWith {przez}
translate P NameEditMatches {Pasuj±ce: Ctrl+1 do Ctrl+9 wybiera}

# Classify window:
translate P Classify {Przyporz±dkowanie ECO}
translate P ClassifyWhich {Partie do przyporz±dkowania ECO}
translate P ClassifyAll {Wszystkie partie (zmiana starych kodów ECO)}
translate P ClassifyYear {Wszystkie partie z ostatniego roku}
translate P ClassifyMonth {Wszystkie partie z ostatniego miesi±ca}
translate P ClassifyNew {Tylko partie bez kodu ECO}
translate P ClassifyCodes {Kody ECO}
translate P ClassifyBasic {Tylko podstawowe ("B12", ...)}
translate P ClassifyExtended {Rozszerzone kody Scida ("B12j", ...)}

# Compaction:
translate P NameFile {Plik nazw}
translate P GameFile {Plik z partiami}
translate P Names {Nazwy}
translate P Unused {Nieu¿ywane}
translate P SizeKb {Rozmiar (kb)}
translate P CurrentState {Status}
translate P AfterCompaction {Po uporz±dkowaniu}
translate P CompactNames {Uporz±dkuj nazwy}
translate P CompactGames {Uporz±dkuj partie}

# Sorting:
translate P SortCriteria {Kryteria sortowania}
translate P AddCriteria {Dodaj kryteria}
translate P CommonSorts {Standardowe kryteria}
translate P Sort {Sortuj}

# Exporting:
translate P AddToExistingFile {Dodaæ partie do pliku?}
translate P ExportComments {Eksportowaæ komentarze?}
translate P ExportVariations {Eksportowaæ warianty?}
translate P IndentComments {Wcinaj komentarze?}
translate P IndentVariations {Wcinaj warianty?}
translate P ExportColumnStyle {Kolumny (jedno posuniêcie w wierszu)?}
translate P ExportSymbolStyle {Styl znaków komentarza:}
translate P ExportStripMarks {Usuwaæ z komentarzy kody kolorowania pól/strza³ek?} 

# Goto game/move dialogs:
translate P LoadGameNumber {Podaj numer partii do wczytania:}
translate P GotoMoveNumber {Id¼ do posuniêcia nr:}

# Copy games dialog:
translate P CopyGames {Kopiuj partie}
translate P CopyConfirm {
 Czy na pewno skopiowaæ
 [thousands $nGamesToCopy] partii z filtra
 w bazie "$fromName"
 do bazy "$targetName"?
}
translate P CopyErr {Nie mo¿na skopiowaæ partii}
translate P CopyErrSource {baza ¼ród³owa}
translate P CopyErrTarget {baza docelowa}
translate P CopyErrNoGames {nie ma partii w filtrze}
translate P CopyErrReadOnly {jest tylko do odczytu}
translate P CopyErrNotOpen {nie jest otwarta}

# Colors:
translate P LightSquares {Jasne pola}
translate P DarkSquares {Ciemne pola}
translate P SelectedSquares {Wybrane pola}
translate P SuggestedSquares {Wybrane posuniêcie}
translate P WhitePieces {Bia³e figury}
translate P BlackPieces {Czarne figury}
translate P WhiteBorder {Kontur bia³ych figur}
translate P BlackBorder {Kontur czarnych figur}

# Novelty window:
translate P FindNovelty {Znajd¼ nowinkê}
translate P Novelty {Nowinka}
translate P NoveltyInterrupt {Poszukiwanie nowinki przerwano}
translate P NoveltyNone {Nie znaleziono nowinki w partii}
translate P NoveltyHelp {
Scid znajdzie pierwsze posuniêcie w partii, po którym powstanie pozycja niewystêpuj±ca ani w bazie, ani w ksi±¿ce debiutowej.
}

# Upgrading databases:
translate P Upgrading {Konwersja}
translate P ConfirmOpenNew {
Ta baza jest zapisana w starym formacie (Scid 2) i nie mo¿e zostaæ otwarta w nowszej wersji
Scid-a. Baza zosta³a ju¿ automatycznie przekonwertowana do nowego formatu.

Czy otworzyæ now± wersjê bazy?
}
translate P ConfirmUpgrade {
Ta baza jest zapisana w starym formacie (Scid 2) i nie mo¿e zostaæ otwarta w nowszej wersji Scid-a. ¯eby móc otworzyæ bazê, trzeba przekonwertowaæ j± do nowego formatu.

Konwersja utworzy now± wersjê bazy - stara wersja nie zostanie zmieniona ani usuniêta.

Mo¿e to zaj±æ trochê czasu, ale jest to operacja jednorazowa. Mo¿esz j± przerwaæ, je¶li potrwa za d³ugo.

Przekonwertowaæ bazê?
}

# Recent files options:
translate P RecentFilesMenu {Number of recent files in File menu} ;# ***
translate P RecentFilesExtra {Number of recent files in extra submenu} ;# ***

}

### Tips of the day in Polish:

set tips(P) {
  {
    Scid ma ponad 30 <a Index>stron pomocy</a> i w wiêkszo¶ci okien Scida
    naci¶niêcie klawisza <b>F1</b> spowoduje wy¶wietlenie odpowiedniej
    strony.
  }
  {
    Niektóre okna Scida (np. informacje pod szachownic±,
    <a Switcher>prze³±cznik baz</a>) maj± menu przywo³ywane prawym przyciskiem
    myszy. Spróbuj nacisn±æ prawy przycisk myszy w ka¿dym oknie, by
    sprawdziæ, czy menu jest dostêpne i jakie funkcje zawiera.
  }
  {
    Scid pozwala wprowadzaæ posuniêcia na kilka ró¿nych sposobów.
    Mo¿esz u¿yæ myszy (z wy¶wietlaniem mo¿liwych posuniêæ lub bez)
    albo klawiatury (z opcjonalnym automatycznym dope³nianiem).
    Wiêcej informacji mo¿na znale¼æ na stronie pomocy
    <a Moves>Wprowadzenie posuniêæ</a>.
  }
  {
    Je¶li masz kilka baz, które otwierasz czêsto, dodaj
    <a Bookmarks>zak³adkê</a> dla ka¿dej z nich. Umo¿liwi to ³atwe
    otwieranie baz z menu.
  }
  {
    Mo¿esz obejrzeæ wszystkie posuniêcia w aktualnej partii
    (z wariantami i komentarzami lub bez) w <a PGN>Oknie PGN</a>.
    W oknie PGN mo¿esz przej¶æ do dowolnego posuniêcia, klikaj±c
    na nim lewym przyciskiem myszy oraz u¿yæ ¶rodkowego lub prawego
    przycisku myszy do obejrzenia aktualnej pozycji.
  }
  {
    Mo¿esz kopiowaæ partie z bazy do bazy przeci±gaj±c je lewym
    przyciskiem myszy w oknie <a Switcher>Prze³±cznika baz</a>.
  }
  {
    Scid mo¿e otwieraæ pliki PGN, nawet je¶li s± one skompresowane
    Gzip-em (z rozszerzeniem .gz). Pliki PGN mog± byæ jedynie
    czytane, wiêc je¶li chcesz co¶ zmieniæ, utwórz now± bazê Scida
    i skopiuj do niej partie z pliku PGN.
  }
  {
    Je¶li masz du¿± bazê i czêsto u¿ywasz okna <a Tree>Drzewa wariantów</a>,
    warto wybraæ polecenie <b>Twórz standardowy plik cache/b>
    z menu Plik okna Drzewo wariantów. Statystyki dla najpopularniejszych
    pozycji debiutowych zostan± zapamiêtane w pliku, co przyspieszy
    dzia³anie drzewa.
  }
  {
    <a Tree>Drzewo wariantów</a> mo¿e pokazaæ wszystkie posuniêcia
    z aktualnej pozycji, ale je¶li chcesz zobaczyæ wszystkie kolejno¶ci
    posuniêæ prowadz±ce do aktualnej pozycji, mo¿esz u¿yæ
    <a OpReport>Raportu debiutowego</a>.
  }
  {
    W <a GameList>li¶cie partii</a> kliknij lewym lub prawym przyciskiem
    myszy na nag³ówku wybranej kolumny, by zmieniæ jej szeroko¶æ.
  }
  {
    W oknie <a PInfo>Informacja o graczu</a> (kliknij na nazwisku gracza
    w polu pod szachownic±, by je otworzyæ) mo¿esz ³atwo ustawiæ
    <a Searches Filter>filtr</a> zawieraj±cy wszystkie partie danego
    gracza zakoñczeone wybranym wynikiem, klikaj±c na dowolnej warto¶ci
    wy¶wietlanej na <red>czerowono</red>.
  }
  {
    Podczas pracy nad debiutem warto u¿yæ funkcji
    <a Searches Board>wyszukiwania pozycji</a> z opcj± <b>Pionki</b> lub
    <b>Kolumny</b>. Pozowli to znale¼æ inne warianty debiutowe z t±
    sam± struktur± pionow±.
  }
  {
    W polu informacji o partii (pod szachownic±) mo¿na u¿yæ prawego
    przycisku myszy, by wy¶wietliæ menu konfiguracji pola. Mo¿na
    np. ukryæ nastêpne posuniêcie, co jest przydatne przy rozwi±zywaniu
    zadañ.
  }
  {
    Je¶li czêsto u¿ywasz funkcji <a Maintenance>obs³ugi</a> na du¿ej
    bazie, mo¿esz u¿yæ okna <a Maintenance Cleaner>Zestaw zadañ</a>
    do wykonania kilka funkcji naraz.
  }
  {
    Je¶li masz du¿± bazê, w której wiêkszo¶æ partii ma ustawiony
    znacznik EventDate, mo¿esz <a Sorting>posortowaæ</a> j±
    wg tego znacznika (zamiast Daty). Dziêki temu wszystkie partie
    z jednego turnieju znajd± siê ko³o siebie.
  }
  {
    Przed u¿yciem funkcji <a Maintenance Twins>usuwania podwójnych partii</a>
    dobrze jest <a Maintenance Spellcheck>sprawdziæ pisowniê</a>
    nazwisk w bazie, co usprawni wyszukiwanie powtórzeñ.
  }
  {
    <a Flags>Flagi</a> s± przydatne do oznaczania partii, które
    zawieraj± wa¿ne motywy taktyczne, strkutury pionowe, nowinki itd.
    Potem mo¿esz znale¼æ takie partie
    <a Searches Header>wyszukiwaniem wg nag³ówka</a>.
  }
  {
    Je¶li przegl±dasz partiê i chcesz sprawdziæ jaki¶ wariant nie
    zmieniaj±c partii, mo¿esz w³±czyæ tryb testowania wariantu
    (klawisz <b>Ctrl+spacja</b> lub ikona na pasku narzêdziowym).
    Po wy³±czeniu trybu testowania powrócisz do pozycji z partii.
  }
  {
    ¯eby znale¼æ najwa¿niejsze partie (z najsilniejszymi przeciwnikami),
    w których powsta³a aktualna pozycja, otwórz <a Tree>Drzewo wariantów</a>
    i wybierz listê najlepszych partii. Mo¿esz nawet wybraæ tylko
    partie zakoñczone konkretnym wynikiem.
  }
  {
    Dobr± metod± na naukê debiutu przy u¿yciu du¿ej bazy jest
    w³±czenie trybu treningu w <a Tree>Drzewie wariantów</a>
    i gra z programem. Pozwala to sprawdziæ, które posuniêcia s±
    grane najczê¶ciej.
  }
  {
    Je¶li masz otwarte dwie bazy i chcesz obejrzeæ
    <a Tree>Drzewo wariantów</a> dla pierwszej bazy, przegl±daj±c
    partiê z drugiej, kliknij przycisk <b>Blokada</b> na drzewie,
    by zablokowaæ je na pierwszej bazie, a nastêpnie prze³±cz siê
    do drugiej bazy.
  }
  {
    Okno <a Tmt>Turnieje</a> jest przydatne nie tylko do znajdowania
    turniejów, ale pozwala tak¿e sprawdziæ, w jakich turniejach gra³
    ostatnio dany zawodnik i jakie turnieje s± rozgrywane w wybranym
    kraju.
  }
  {
    Mo¿esz u¿yæ jednego z wielu typowych wzorców w oknie
    <a Searches Material>Wyszukiwania wg materia³u</a> do znalezienia
    partii do studiowania debiutów lub gry ¶rodkowej.
  }
  {
    W oknie <a Searches Material>Wyszukiwanie wg materia³u</a>, mo¿esz
    ograniczyæ liczbê znajdowanych partii przez warunek, by
    podany stosunek materia³u utrzymywa³ siê przynajmniej przez
    kilka pó³ruchów.
  }
  {
    Je¶li masz wa¿n± bazê, której nie chcesz przez przypadek zmieniæ,
    w³±cz <b>Tylko do odczytu...</b> w menu <b>Plik</b> po jej otwarciu
    (albo zmieñ prawa dostêpu do pliku).
  }
  {
    Je¶li u¿ywasz XBoard-a lub WinBoard-a (albo programu szachowego,
    który pozwala na skopiowania pozycji w notacji FEN do schowka)
    i chcesz skopiowaæ aktualn± pozycjê do Scid-a, wybierz
    <b>Copy position</b> w menu File programu XBoard/Winboard, a potem
    <b>Wklej aktywn± partiê ze schowka</b> z menu Edycja Scid-a.
  }
  {
    W oknie <a Searches Header>Wyszukiwanie wg nag³ówka</a>,
    szukane nazwy graczy/turnieju/miejsca/rundy s± znajdowane niezale¿nie
    od wielko¶ci liter i równie¿ wewn±trz nazw.
    Zamiast tego mo¿esz u¿yæ poszukiwania z symbolami wieloznacznymi
    (gdzie "?" oznacza dowolny znak, za¶ "*" - 0 lub wiêcej znaków),
    wpisuj±c szukany tekst w cudzys³owie. Wielko¶æ liter zostanie
    uwzglêdniona. Na przyk³ad "*BEL" znajdzie wszystkie turnieje grane
    w Belgii (ale nie w Belgradzie).
  }
  {
    Je¶li chcesz poprawiæ posuniêcie nie zmieniaj±c nastêpnych,
    otwórz okno <a Import>Pobierz partiê</a>, wci¶nij
    <b>Wklej aktualn± partiê</b>, zmieñ b³êdne posuniêcie i wci¶nij
    <b>Pobierz</b>.
  }
  {
    Je¶li plik klasyfikacji debiutowej ECO jest wczytany, mo¿esz przej¶æ
    do ostatniej sklasyfikowanej pozycji w partii za pomoc± polecenia
    <b>Rozpoznaj debiut</b> w menu <b>Partia</b> (klawisz Ctrl+Shift+D).
  }
  {
    Je¶li chcesz sprawdziæ wielko¶æ lub datê modyfikacji pliku
    przed jego otwarciem, u¿yj okna <a Finder>Poszukiwacza plików</a>.
  }
  {
    Plik<a Repertoire>repertuaru debiutowego</a> pozwala na ¶ledzenie
    partii w ulubionych wariantach. Kiedy dodasz grane przez siebie
    debiuty do pliku repertuaru debiutowego, bêdziesz móg³ ³atwo
    znajdowaæ je w nowych partiach.
  }
  {
    <a OpReport>Raport debiutowy</a> pozwala dowiedzieæ siê wiêcej
    o konkretnej pozycji. Mo¿esz zobaczyæ wyniki, nazwiska najczê¶ciej
    graj±cych j± zawodników, typowe motywy pozycyjne itd.
  }
  {
    Mo¿esz dodaæ wiêkszo¶æ typowych symboli (!, !?, += itd.) do
    aktualnego posuniêcia lub pozycji za pomoc± skrótów klawiszowych,
    bez potrzeby otwierania okna <a Comment>Edytora komentarzy</a>
    -- np. wci¶niêcie "!" i Enter spowoduje dodanie symbolu "!".
    Na stronie <a Moves>Wprowadzanie posuniêæ</a> mo¿na znale¼æ
    wiêcej informacji.
  }
  {
    Mo¿esz ³atwo przegl±daæ debiuty w bazie w oknie
    <a Tree>Drzewo wariantów</a>. W oknie Statystyka (klawisz Ctrl+I)
    mo¿na znale¼æ informacje o ostatnich wynikach w wariancie oraz
    o partiach granych przez silnych graczy.
  }
  {
    Mo¿esz zmieniæ wielko¶æ szachownicy, naciskaj±c <b>lewo</b> lub <b>prawo</b>
    przy wci¶niêtych klawiszach <b>Ctrl</b> i <b>Shift</b>.
  }
  {
    Po <a Searches>wyszukiwaniu</a> mo¿esz ³atwo przegl±daæ wszystkie
    znalezione partie, naciskaj±c klawisz <b>góra</b> lub <b>dó³</b>
    przy wci¶niêtym <b>Ctrl</b> by obejrzeæ poprzedni±/nastêpn± partiê
    w filtrze.
  }
}

# end of polish.tcl


