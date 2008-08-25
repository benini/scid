# hungary.tcl:
# Hungarian text for menu names and status bar help messages for SCID
# Translated by: Gábor Szõts

addLanguage H Hungarian 0 iso8859-2

proc setLanguage_H {} {

# File menu:
menuText H File "Fájl" 0
menuText H FileNew "Új..." 0 {Új SCID-adatbázis létrehozása}
menuText H FileOpen "Megnyit..." 3 {Meglévõ SCID-adatbázis megnyitása}
menuText H FileClose "Bezár" 2 {Az aktív SCID-adatbázis bezárása}
menuText H FileFinder "Fájlkeresõ" 0 {Kinyitja a Fájlkeresõ ablakot.}
menuText H FileBookmarks "Könyvjelzõk" 0 {Könyvjelzõmenü (gyorsbillentyû: Ctrl+B)}
menuText H FileBookmarksAdd "Új könyvjelzõ" 0 \
  {Megjelöli az aktuális játszmát és állást.}
menuText H FileBookmarksFile "Könyvjelzõ mentése" 11 \
  {Az álláshoz tartozó könyvjelzõt külön könyvtárba teszi.}
menuText H FileBookmarksEdit "Könyvjelzõk szerkesztése..." 13 \
  {Könyvjelzõk szerkesztése}
menuText H FileBookmarksList "Megjelenítés listaként" 13 \
  {A könyvjelzõk könyvtárai nem almenüként, hanem listaként jelennek meg.}
menuText H FileBookmarksSub "Megjelenítés almenüként" 13 \
  {A könyvjelzõk könyvtárai nem listaként, hanem almenüként jelennek meg.}
menuText H FileMaint "Gondozás" 0 {SCID adatbázisgondozó eszközök}
menuText H FileMaintWin "Adatbázisgondozó ablak" 0 \
  {Kinyitja/becsukja az SCID adatbázisgondozó ablakot.}
menuText H FileMaintCompact "Adatbázis tömörítése..." 10 \
  {Eltávolítja az adatbázisból a törölt játszmákat és a használaton kívül álló neveket.}
menuText H FileMaintClass "Osztályba sorolás..." 0 \
  {Újra kiszámítja az összes játszma ECO-kódját.}
menuText H FileMaintSort "Rendezés..." 0 \
  {Rendezi az adatbázis összes játszmáját.}
menuText H FileMaintDelete "Ikerjátszmák törlése..." 0 \
  {Megkeresi az ikerjátszmákat, és megjelöli õket törlésre.}
menuText H FileMaintTwin "Ikerkeresõ ablak" 4 \
  {Kinyitja/becsukja az ikerkeresõ ablakot.}
menuText H FileMaintName "Nevek helyesírása" 0 {Névszerkesztõ és helyesírási eszközök}
menuText H FileMaintNameEditor "Névszerkesztõ" 0 \
  {Kinyitja/becsukja a névszerkesztõ ablakot.}
menuText H FileMaintNamePlayer "Játékosnevek ellenõrzése..." 0 \
  {A helyesírás-ellenõrzõ fájl segítségével ellenõrzi a játékosok nevét.}
menuText H FileMaintNameEvent "Eseménynevek ellenõrzése..." 0 \
  {A helyesírás-ellenõrzõ fájl segítségével ellenõrzi események nevét.}
menuText H FileMaintNameSite "Helynevek ellenõrzése..." 0 \
  {A helyesírás-ellenõrzõ fájl segítségével ellenõrzi a helyszínek nevét.}
menuText H FileMaintNameRound "Fordulónevek ellenõrzése..." 0 \
  {A helyesírás-ellenõrzõ fájl segítségével ellenõrzi a fordulók nevét.}
menuText H FileReadOnly "Írásvédelem..." 0 \
  {Az aktuális adatbázist csak olvashatóvá teszi, nehogy meg lehessen változtatni.}
menuText H FileSwitch "Adatbázisváltás" 0 \
  {Átvált egy másik megnyitott adatbázisra.}
menuText H FileExit "Kilép" 2 {Kilép SCID-bõl.}

# Edit menu:
menuText H Edit "Szerkesztés" 1
menuText H EditAdd "Új változat" 0 {Ennél a lépésnél új változatot szúr be a játszmába.}
menuText H EditDelete "Változat törlése" 9 {Töröl egy változatot ennél a lépésnél.}
menuText H EditFirst "Elsõ változattá tesz" 0 \
  {Elsõ helyre teszi a változatot a listán.}
menuText H EditMain "Fõváltozattá tesz" 0 \
  {A változatot fõváltozattá lépteti elõ.}
menuText H EditTrial "Változat kipróbálása" 11 \
  {Elindítja/megállítja a próbaüzemmódot, amellyel egy elgondolást lehet a táblán kipróbálni.}
menuText H EditStrip "Lecsupaszít" 2 {Eltávolítja a megjegyzéseket vagy a változatokat ebbõl a játszmából.}
menuText H EditStripComments "Megjegyzések" 0 \
  {Eltávolítja az összes megjegyzést és elemzést ebbõl a játszmából.}
menuText H EditStripVars "Változatok" 0 {Eltávolítja az összes változatot ebbõl a játszmából.}
menuText H EditStripBegin "Az elejétõl" 3 \
  {Levágja a játszma elejét}
menuText H EditStripEnd "A végéig" 2 \
  {Levágja a játszma végét}
menuText H EditReset "Kiüríti a Vágóasztalt" 2 \
  {Alaphelyzetbe hozza a Vágóasztalt, hogy az teljesen üres legyen.}
menuText H EditCopy "A Vágóasztalra másolja ezt a játszmát." 15 \
  {Ezt a játszmát átmásolja a Vágóasztal adatbázisba.}
menuText H EditPaste "Beilleszti az utolsó játszmát a Vágóasztalról." 0 \
  {A Vágóasztal aktív játszmáját beilleszti ide.}
menuText H EditPastePGN "A vágólap tartalmát PGN-játszmaként beilleszti" 20 \
  {A vágólap tartalmát PGN-jelölésû játszmának tekinti, és idemásolja.}
menuText H EditSetup "Kezdõállás felállítása..." 14 \
  {Felállítja a kezdõállást ehhez a játszmához.}
menuText H EditCopyBoard "Állás másolása FEN-ként" 17 \
  {Az aktuális állást FEN-jelöléssel a vágólapra másolja.}
menuText H EditPasteBoard "Kezdõállás beillesztése" 13 \
  {Felállítja a kezdõállást kijelölt szöveg (vágólap) alapján.}

# Game menu:
menuText H Game "Játszma" 0
menuText H GameNew "Új játszma" 0 \
  {Új játszmát kezd; a változtatásokat elveti.}
menuText H GameFirst "Betölti az elsõ játszmát." 11 {Betölti az elsõ szûrt játszmát.}
menuText H GamePrev "Betölti az elõzõ játszmát." 12 {Betölti az elõzõ szûrt játszmát.}
menuText H GameReload "Ismét betölti az aktuális játszmát." 0 \
  {Újra betölti ezt a játszmát; elvet minden változtatást.}
menuText H GameNext "Betölti a következõ játszmát." 10 {Betölti a következõ szûrt játszmát.}
menuText H GameLast "Betölti az utolsó játszmát." 11 {Betölti az utolsó szûrt játszmát.}
menuText H GameRandom "Véletlenszerûen betölt egy játszmát." 0 {Véletlenszerûen betölt egy szûrt játszmát.}
menuText H GameNumber "Megadott sorszámú játszma betöltése..." 9 \
  {Betölti a sorszámmal megadott játszmát.}
menuText H GameReplace "Mentés cserével..." 7 \
  {Elmenti ezt a játszmát; felülírja a régi változatot.}
menuText H GameAdd "Mentés új játszmaként..." 0 \
  {Elmenti ezt a játszmát; új játszmát hoz létre az adatbázisban.}
menuText H GameDeepest "Megnyitás azonosítása" 10 \
  {Az ECO-könyvben szereplõ legnagyobb mélységig megy bele a játszmába.}
menuText H GameGotoMove "Ugrás megadott sorszámú lépéshez..." 1 \
  {Megadott sorszámú lépéshez ugrik az aktuális játszmában.}
menuText H GameNovelty "Újítás keresése..." 2 \
  {Megkeresi ebben a játszmában az elsõ olyan lépést, amely korábban nem fordult elõ.}

# Search Menu:
menuText H Search "Keresés" 0
menuText H SearchReset "Szûrõ törlése" 6 {Alaphelyzetbe hozza a szûrõt, hogy az összes játszma benne legyen.}
menuText H SearchNegate "Szûrõ negálása" 6 {Negálja a szûrõt, hogy csak a kizárt játszmák legyenek benne.}
menuText H SearchCurrent "Aktuális állás..." 0 {A táblán lévõ állást keresi.}
menuText H SearchHeader "Fejléc..." 0 {Keresés fejléc (játékos, esemény, stb.) alapján}
menuText H SearchMaterial "Anyag/szerkezet..." 6 {Keresés anyag vagy állásszerkezet alapján}
menuText H SearchUsing "Keresõfájl használata..." 0 {Keresés SearchOptions fájl használatával}

# Windows menu:
menuText H Windows "Ablakok" 0
menuText H WindowsComment "Megjegyzésszerkesztõ" 0 {Megnyitja/bezárja a megjegyzésszerkesztõt.}
menuText H WindowsGList "Játszmák listája" 9 {Kinyitja/becsukja a játszmák listáját mutató ablakot.}
menuText H WindowsPGN "PGN" 0 \
  {Kinyitja/becsukja a PGN-(játszmajegyzés)-ablakot.}
menuText H WindowsPList "Játékoskeresõ" 0 {Kinyitja/becsukja a játékoskeresõt.}
menuText H WindowsTmt "Versenykeresõ" 0 {Kinyitja/becsukja a versenykeresõt.}
menuText H WindowsSwitcher "Adatbázisváltó" 0 \
  {Kinyitja/becsukja az adatbázisváltó ablakot.}
menuText H WindowsMaint "Adatbázisgondozó" 9 \
  {Kinyitja/becsukja az adatbázisgondozó ablakot.}
menuText H WindowsECO "ECO-böngészõ" 0 {Kinyitja/becsukja az ECO-böngészõ ablakot.}
menuText H WindowsRepertoire "Repertoárszerkesztõ" 0 \
  {Megnyitja/bezárja a megnyitási repertoárszerkesztõt.}
menuText H WindowsStats "Statisztika" 0 \
  {Kinyitja/becsukja a szûrési statisztika ablakát.}
menuText H WindowsTree "Faszerkezet" 0 {Kinyitja/becsukja a faszerkezet-ablakot.}
menuText H WindowsTB "Végjátéktáblázatok" 8 \
  {Kinyitja/becsukja a végjátéktáblázatok ablakát.}
# ====== TODO To be translated ======
menuText H WindowsBook "Book Window" 0 {Open/close the Book window}
# ====== TODO To be translated ======
menuText H WindowsCorrChess "Correspondence Window" 0 {Open/close the Correspondence window}

# Tools menu:
menuText H Tools "Eszközök" 0
menuText H ToolsAnalysis "Elemzõ motor..." 0 \
  {Elindít/leállít egy sakkelemzõ programot.}
menuText H ToolsAnalysis2 "2. elemzõ motor..." 0 \
  {Elindítja/leállítja a 2. sakkelemzõ programot.}
menuText H ToolsCross "Versenytáblázat" 0 {Megmutatja az ehhez a játszmához tartozó verseny táblázatát.}
menuText H ToolsEmail "Levelezési sakk" 0 \
  {Kinyitja/becsukja az elektronikus sakklevelezés lebonyolítására szolgáló ablakot.}
menuText H ToolsFilterGraph "Szûrõgrafikon" 0 \
  {Kinyitja/becsukja a szûrõgrafikont mutató ablakot.}
# ====== TODO To be translated ======
menuText H ToolsAbsFilterGraph "Abs. Filter Graph" 7 {Open/close the filter graph window for absolute values}
menuText H ToolsOpReport "Megnyitási összefoglaló" 0 \
  {Ismertetõt készít az aktuális álláshoz tartozó megnyitásról.}
# ====== TODO To be translated ======
menuText H ToolsOpenBaseAsTree "Open base as tree" 0   {Open a base and use it in Tree window}
# ====== TODO To be translated ======
menuText H ToolsOpenRecentBaseAsTree "Open recent base as tree" 0   {Open a recent base and use it in Tree window}
menuText H ToolsTracker "Figurakövetõ"  0 {Kinyitja/becsukja a figurakövetõ ablakot.}
# ====== TODO To be translated ======
menuText H ToolsTraining "Training"  0 {Training tools (tactics, openings,...) }
# ====== TODO To be translated ======
menuText H ToolsTacticalGame "Tactical game"  0 {Play a game with tactics}
# ====== TODO To be translated ======
menuText H ToolsSeriousGame "Serious game"  0 {Play a serious game}
# ====== TODO To be translated ======
menuText H ToolsTrainOpenings "Openings"  0 {Train with a repertoire}
# ====== TODO To be translated ======
menuText H ToolsTrainTactics "Tactics"  0 {Solve tactics}
# ====== TODO To be translated ======
menuText H ToolsTrainCalvar "Calculation of variations"  0 {Calculation of variations training}
# ====== TODO To be translated ======
menuText H ToolsTrainFindBestMove "Find best move"  0 {Find best move}
# ====== TODO To be translated ======
menuText H ToolsTrainFics "Play on internet"  0 {Play on freechess.org}
# ====== TODO To be translated ======
menuText H ToolsBookTuning "Book tuning" 0 {Book tuning}
# ====== TODO To be translated ======
menuText H ToolsNovagCitrine "Novag Citrine" 0 {Novag Citrine}
# ====== TODO To be translated ======
menuText H ToolsNovagCitrineConfig "Configuration" 0 {Novag Citrine configuration}
# ====== TODO To be translated ======
menuText H ToolsNovagCitrineConnect "Connect" 0 {Novag Citrine connect}
menuText H ToolsPInfo "Játékosinformáció"  0 \
  {Kinyitja/frissíti a játékos adatait tartalmazó ablakot.}
menuText H ToolsPlayerReport "Összefoglaló játékosról..." 0 \
    {Összefoglalót készít a játékosról}
menuText H ToolsRating "Értékszám alakulása" 0\
  {Grafikusan ábrázolja, hogyan alakult az aktuális játszma résztvevõinek értékszáma.}
menuText H ToolsScore "Eredmény alakulása" 1 {Megmutatja az eredménygrafikont.}
menuText H ToolsExpCurrent "Az aktuális játszma exportálása" 21 \
  {Szövegfájlba írja az aktuális játszmát.}
menuText H ToolsExpCurrentPGN "Exportálás PGN-fájlba..." 11 \
  {PGN-fájlba írja az aktuális játszmát.}
menuText H ToolsExpCurrentHTML "Exportálás HTML-fájlba..." 11 \
  {HTML-fájlba írja az aktuális játszmát.}
# ====== TODO To be translated ======
menuText H ToolsExpCurrentHTMLJS "Export Game to HTML and JavaScript File..." 15 {Write current game to a HTML and JavaScript file}  
menuText H ToolsExpCurrentLaTeX "Exportálás LaTeX-fájlba..." 11 \
  {LaTeX-fájlba írja az aktuális játszmát.}
menuText H ToolsExpFilter "Az összes szûrt játszma exportálása" 10 \
  {Szövegfájlba írja az összes szûrt játszmát.}
menuText H ToolsExpFilterPGN "Szûrõ exportálása PGN-fájlba..." 18 \
  {PGN-fájlba írja az összes szûrt játszmát.}
menuText H ToolsExpFilterHTML "Szûrõ exportálása HTML-fájlba..." 18 \
  {HTML-fájlba írja az összes szûrt játszmát.}
# ====== TODO To be translated ======
menuText H ToolsExpFilterHTMLJS "Export Filter to HTML and JavaScript File..." 17 {Write all filtered games to a HTML and JavaScript file}  
menuText H ToolsExpFilterLaTeX "Szûrõ exportálása LaTeX-fájlba..." 18 \
  {LaTeX-fájlba írja az összes szûrt játszmát.}
menuText H ToolsImportOne "PGN-játszma importálása..." 0 \
  {PGN-formátumú játszma importálása}
menuText H ToolsImportFile "PGN-fájl importálása..." 2 \
  {PGN-fájl összes játszmájának importálása}
# ====== TODO To be translated ======
menuText H ToolsStartEngine1 "Start engine 1" 0  {Start engine 1}
# ====== TODO To be translated ======
menuText H ToolsStartEngine2 "Start engine 2" 0  {Start engine 2}
# ====== TODO To be translated ======
menuText H Play "Play" 0
# ====== TODO To be translated ======
menuText H CorrespondenceChess "Correspondence Chess" 0 {Functions for eMail and Xfcc based correspondence chess}
# ====== TODO To be translated ======
menuText H CCConfigure "Configure..." 0 {Configure external tools and general setup}
# ====== TODO To be translated ======
menuText H CCOpenDB "Open Database..." 0 {Open the default Correspondence database}
# ====== TODO To be translated ======
menuText H CCRetrieve "Retrieve Games" 0 {Retrieve games via external (Xfcc-)helper}
# ====== TODO To be translated ======
menuText H CCInbox "Process Inobx" 0 {Process all files in scids Inbox}
# ====== TODO To be translated ======
menuText H CCPrevious "Previous Game" 0 {Go to previous game in Inbox}
# ====== TODO To be translated ======
menuText H CCNext "Next Game" 0 {Go to next game in Inbox}
# ====== TODO To be translated ======
menuText H CCSend "Send Move" 0 {Send your move via eMail or external (Xfcc-)helper}
# ====== TODO To be translated ======
menuText H CCResign "Resign" 0 {Resign (not via eMail)}
# ====== TODO To be translated ======
menuText H CCClaimDraw "Claim Draw" 0 {Send move and claim a draw (not via eMail)}
# ====== TODO To be translated ======
menuText H CCOfferDraw "Offer Draw" 0 {Send move and offer a draw (not via eMail)}
# ====== TODO To be translated ======
menuText H CCAcceptDraw "Accept Draw" 0 {Accept a draw offer (not via eMail)}
# ====== TODO To be translated ======
menuText H CCNewMailGame "New eMail Game..." 0 {Start a new eMail game}
# ====== TODO To be translated ======
menuText H CCMailMove "Mail Move..." 0 {Send the move via eMail to the opponent}

# Options menu:
menuText H Options "Beállítások" 0
menuText H OptionsBoard "Sakktábla" 0 {Sakktábla megjelenésének megváltoztatása}
menuText H OptionsBoardSize "Táblaméret" 0 {A tábla méretének változtatása}
menuText H OptionsBoardPieces "Figurák stílusa" 0 {A figurák megjelenési formájának változtatása}
menuText H OptionsBoardColors "Színek..." 0 {A tábla színeinek változtatása}
# ====== TODO To be translated ======
menuText H OptionsBoardGraphics "Squares..." 0 {Select textures for squares}
# ====== TODO To be translated ======
translate H OptionsBGW {Select texture for squares}
# ====== TODO To be translated ======
translate H OptionsBoardGraphicsText {Select graphic files for white and black squares:}
menuText H OptionsBoardNames "Játékosnevek..." 0 {Játékosnevek átszerkesztése}
menuText H OptionsExport "Exportálás" 1 {Exportálási beállítások változtatása}
menuText H OptionsFonts "Karakterkészlet" 0 {Karakterkészlet változtatása}
menuText H OptionsFontsRegular "Szokásos" 0 {A szokásos karakterkészlet változtatása}
menuText H OptionsFontsMenu "Menü" 0 {A menük karakterkészletének a változtatása}
menuText H OptionsFontsSmall "Kisbetûs" 0 {A kisbetûs karakterkészlet változtatása}
menuText H OptionsFontsFixed "Rögzített" 0 {A rögzített szélességû karakterkészlet változtatása}
menuText H OptionsGInfo "Játszmainformáció" 0 {Játszmainformáció változtatása}
menuText H OptionsLanguage "Nyelv" 0 {A menü nyelvének kiválasztása}
# ====== TODO To be translated ======
menuText H OptionsMovesTranslatePieces "Translate pieces" 0 {Translate first letter of pieces}
menuText H OptionsMoves "Lépések" 0 {Lépések bevitelének beállításai}
menuText H OptionsMovesAsk "Lépés cseréje elõtt rákérdez." 6 \
  {Mielõtt átírna egy meglevõ lépést, rákérdez.}
menuText H OptionsMovesAnimate "Megelevenítés ideje" 0 \
  {Beállítja az idõt lépések megelevenítéséhez.}
menuText H OptionsMovesDelay "Automatikus visszajátszás késleltetése..." 0 \
  {Beállítja a késleltetést automatikus visszajátszáshoz.}
menuText H OptionsMovesCoord "Lépés megadása koordinátákkal" 15 \
  {Koordinátákkal megadott lépést ("g1f3") is elfogad.}
menuText H OptionsMovesSuggest "Javaslat" 0 \
  {Be/kikapcsolja a lépésjavaslatot.}
# ====== TODO To be translated ======
menuText H OptionsShowVarPopup "Show variations window" 0 {Turn on/off the display of a variations window}  
# ====== TODO To be translated ======
menuText H OptionsMovesSpace "Add spaces after move number" 0 {Add spaces after move number}  
menuText H OptionsMovesKey "Billentyû-kiegészítés" 0 \
  {Be/kikapcsolja a billentyûzettel részlegesen bevitt lépések automatikus kiegészítését.}
menuText H OptionsNumbers "Számformátum" 1 {Számformátum kiválasztása}
menuText H OptionsStartup "Indítás" 0 {Az indításkor kinyitandó ablakok kiválasztása}
menuText H OptionsWindows "Ablakok" 0 {Ablakbeállítások}
menuText H OptionsWindowsIconify "Automatikus ikonizálás" 12 \
  {A fõ ablak ikonizálásakor az összes többit is ikonizálja.}
menuText H OptionsWindowsRaise "Automatikus elõhozás" 12 \
  {Elõhoz bizonyos ablakokat (pl. elõrehaladás-sávokat), amikor el vannak takarva.}
menuText H OptionsSounds "Hangok..." 3 {Lépéseket bejelentõ hangok definiálása}
menuText H OptionsToolbar "Eszköztár" 0 {A fõ ablak eszköztárának összeállítása}
menuText H OptionsECO "ECO-fájl betöltése..." 2 {Betölti az ECO-osztályozó fájlt.}
menuText H OptionsSpell "Helyesírás-ellenõrzõ fájl betöltése..." 0 \
  {Betölti a helyesírás-ellenõrzõ fájlt.}
menuText H OptionsTable "Végjátéktáblázatok könyvtára..." 0 \
  {Végjátéktáblázat-fájl kiválasztása; a könyvtárban levõ összes végjátéktáblázatot használatba veszi.}
menuText H OptionsRecent "Aktuális fájlok..." 3 \
  {A Fájl menüben megjelenített aktuális fájlok számának megváltoztatása}
# ====== TODO To be translated ======
menuText H OptionsBooksDir "Books directory..." 0 {Sets the opening books directory}
# ====== TODO To be translated ======
menuText H OptionsTacticsBasesDir "Bases directory..." 0 {Sets the tactics (training) bases directory}
menuText H OptionsSave "Beállítások mentése" 12 \
  "Minden beállítható értéket elment a $::optionsFile fájlba."
menuText H OptionsAutoSave "Beállítások automatikus mentése kilépéskor." 0 \
  {Automatikusan elment minden beállítást, amikor kilépsz SCID-bõl.}

# Help menu:
menuText H Help "Segítség" 0
menuText H HelpContents "Tartalomjegyzék" 0 {Megjeleníti a tartalomjegyzéket}
menuText H HelpIndex "Tárgymutató" 0 {Megjeleníti a tárgymutatót}
menuText H HelpGuide "Rövid ismertetõ" 0 {Rövid ismertetõt nyújt a program használatáról.}
menuText H HelpHints "Kérdés-felelet" 0 {Néhány hasznos tanács}
menuText H HelpContact "Címek" 0 {Fontosabb internetcímek}
menuText H HelpTip "A nap tippje" 2 {Hasznos tipp SCID használatához}
menuText H HelpStartup "Induló ablak" 0 {A program indításakor megjelenõ ablak}
menuText H HelpAbout "SCID-rõl" 0 {Tájékoztatás SCID-rõl}

# Game info box popup menu:
menuText H GInfoHideNext "Elrejti a következõ lépést." 0
menuText H GInfoMaterial "Mutatja az anyagi helyzetet" 11
menuText H GInfoFEN "FEN-formátum megmutatása" 0
menuText H GInfoMarks "Mutatja a színes mezõket és nyilakat." 10
menuText H GInfoWrap "Hosszú sorok tördelése" 0
menuText H GInfoFullComment "A teljes kommentárt megmutatja." 9
menuText H GInfoPhotos "Mutatja a fényképeket" 1
menuText H GInfoTBNothing "Végjátéktáblázatok: nincs információ" 20
menuText H GInfoTBResult "Végjátéktáblázatok: csak eredmény" 25
menuText H GInfoTBAll "Végjátéktáblázatok: eredmény és a legjobb lépések" 42
menuText H GInfoDelete "Törli/helyreállítja ezt a játszmát." 0
menuText H GInfoMark "Megjelöli ezt a játszmát/megszünteti a jelölést." 0
# ====== TODO To be translated ======
menuText H GInfoInformant "Configure informant values" 0

# Main window buttons:
helpMsg H .button.start {Ugrás a játszma elejére  (billentyû: Home)}
helpMsg H .button.end {Ugrás a játszma végére  (billentyû: End)}
helpMsg H .button.back {Vissza egy lépéssel  (billentyû: balra mutató nyíl)}
helpMsg H .button.forward {Elõre egy lépéssel  (billentyû: jobbra mutató nyíl)}
helpMsg H .button.intoVar {Belép egy változatba  (gyorsbillentyû: v).}
helpMsg H .button.exitVar {Kilép az aktuális változatból  (gyorsbillentyû: z).}
helpMsg H .button.flip {Tábla elforgatása  (gyorsbillentyû: .)}
helpMsg H .button.coords {Koordináták be- vagy kikapcsolása  (gyorsbillentyû: 0)}
helpMsg H .button.stm {Be- vagy kikapcsolja a lépésjogot mutató ikont}
helpMsg H .button.autoplay {Automatikus visszajátszás  (billentyû: Ctrl+Z)}

# General buttons:
translate H Back {Vissza}
translate H Browse {Browse}
translate H Cancel {Mégse}
# ====== TODO To be translated ======
translate H Continue {Continue}
translate H Clear {Töröl}
translate H Close {Bezár}
translate H Contents {Contents}
translate H Defaults {Alapértékek}
translate H Delete {Töröl}
translate H Graph {Grafikon}
translate H Help {Segítség}
translate H Import {Import}
translate H Index {Tartalom}
translate H LoadGame {Játszma betöltése}
translate H BrowseGame {Játszma nézegetése}
translate H MergeGame {Játszma beolvasztása}
# ====== TODO To be translated ======
translate H MergeGames {Merge Games}
translate H Preview {Elõnézet}
translate H Revert {Elvet}
translate H Save {Ment}
translate H Search {Keres}
translate H Stop {Állj}
translate H Store {Tárol}
translate H Update {Frissít}
translate H ChangeOrient {Ablak elhelyezkedésének változtatása}
translate H ShowIcons {Show Icons} ;# ***
translate H None {Nincs}
translate H First {Elsõ}
translate H Current {Aktuális}
translate H Last {Utolsó}

# General messages:
translate H game {játszma}
translate H games {játszma}
translate H move {lépés}
translate H moves {lépés}
translate H all {mind}
translate H Yes {Igen}
translate H No {Nem}
translate H Both {Mindkettõ}
translate H King {Király}
translate H Queen {Vezér}
translate H Rook {Bástya}
translate H Bishop {Futó}
translate H Knight {Huszár}
translate H Pawn {Gyalog}
translate H White {Világos}
translate H Black {Sötét}
translate H Player {Játékos}
translate H Rating {Értékszám}
translate H RatingDiff {Értékszámkülönbség (világos - sötét)}
translate H AverageRating {Átlagos értékszám}
translate H Event {Esemény}
translate H Site {Helyszín}
translate H Country {Ország}
translate H IgnoreColors {A szín közömbös}
translate H Date {Dátum}
translate H EventDate {Az esemény dátuma}
translate H Decade {Évtized}
translate H Year {Év}
translate H Month {Hónap}
translate H Months {január február március április május június július augusztus szeptember október november december}
translate H Days {vasárnap hétfõ kedd szerda csütörtök péntek szombat}
translate H YearToToday {Az utolsó egy évben}
translate H Result {Eredmény}
translate H Round {Forduló}
translate H Length {Hossz}
translate H ECOCode {ECO-kód}
translate H ECO {ECO}
translate H Deleted {törölt}
translate H SearchResults {A keresés eredménye}
translate H OpeningTheDatabase {Adatbázis megnyitása}
translate H Database {Adatbázis}
translate H Filter {Szûrõ}
translate H noGames {Nincs találat}
translate H allGames {Összes játszma}
translate H empty {üres}
translate H clipbase {vágóasztal}
translate H score {Eredmény}
translate H StartPos {Kezdõállás}
translate H Total {Összesen}
translate H readonly {read-only} ;# ***

# Standard error messages:
translate H ErrNotOpen {Ez az adatbázis nincs megnyitva.}
translate H ErrReadOnly {Ez az adatbázis csak olvasható; nem lehet megváltoztatni.}
translate H ErrSearchInterrupted {Keresés megszakítva; az eredmények hiányosak.}

# Game information:
translate H twin {iker}
translate H deleted {törölt}
translate H comment {megjegyzés}
translate H hidden {rejtett}
translate H LastMove {Utolsó lépés}
translate H NextMove {Következõ}
translate H GameStart {Játszma eleje}
translate H LineStart {Elágazás eleje}
translate H GameEnd {Játszma vége}
translate H LineEnd {Elágazás vége}

# Player information:
translate H PInfoAll {Eredmények az <b>összes</b> játszma alapján}
translate H PInfoFilter {Eredmények a <b>szûrt</b> játszmák alapján}
translate H PInfoAgainst {Eredmények, ha az ellenfél}
translate H PInfoMostWhite {Leggyakoribb megnyitások világosként}
translate H PInfoMostBlack {Leggyakoribb megnyitások sötétként}
translate H PInfoRating {Értékszám alakulása}
translate H PInfoBio {Életrajz}
translate H PInfoEditRatings {Értékszámok átszerkesztése}

# Tablebase information:
translate H Draw {Döntetlen}
translate H stalemate {patt}
translate H withAllMoves {az összes lépéssel}
translate H withAllButOneMove {egy híján az összes lépéssel}
translate H with {with}
translate H only {csak}
translate H lose {veszítenek}
translate H loses {veszít}
translate H allOthersLose {minden más veszít}
translate H matesIn {mates in}
translate H hasCheckmated {mattot adott}
translate H longest {leghosszabb}
translate H WinningMoves {Nyerõ lépés}
translate H DrawingMoves {Döntetlenre vezetõ lépés}
translate H LosingMoves {Vesztõ lépés}
translate H UnknownMoves {Bizonytalan kimenetelû lépés}

# Tip of the day:
translate H Tip {Tipp}
translate H TipAtStartup {Tipp induláskor}

# Tree window menus:
menuText H TreeFile "Fájl" 0
# ====== TODO To be translated ======
menuText H TreeFileFillWithBase "Fill Cache with base" 0 {Fill the cache file with all games in current base}
# ====== TODO To be translated ======
menuText H TreeFileFillWithGame "Fill Cache with game" 0 {Fill the cache file with current game in current base}
# ====== TODO To be translated ======
menuText H TreeFileSetCacheSize "Cache size" 0 {Set the cache size}
# ====== TODO To be translated ======
menuText H TreeFileCacheInfo "Cache info" 0 {Get info on cache usage}
menuText H TreeFileSave "Cache-fájl mentése" 11 {Elmenti a faszerkezet-cache-fájlt (.stc)}
menuText H TreeFileFill "Cache-fájl feltöltése" 14 \
  {Feltölti a cache-fájlt gyakori megnyitásokkal.}
menuText H TreeFileBest "Legjobb játszmák listája" 0 {Megmutatja a legjobb játszmákat a fáról.}
menuText H TreeFileGraph "Grafikon" 0 {Megmutatja ennek a faágnak a grafikonját.}
menuText H TreeFileCopy "Szöveg másolása a vágólapra" 0 \
  {A kiírt statisztikai adatokat a vágólapra másolja.}
menuText H TreeFileClose "Faablak bezárása" 10 {Bezárja a faszerkezet-ablakot.}
# ====== TODO To be translated ======
menuText H TreeMask "Mask" 0
# ====== TODO To be translated ======
menuText H TreeMaskNew "New" 0 {New mask}
# ====== TODO To be translated ======
menuText H TreeMaskOpen "Open" 0 {Open mask}
# ====== TODO To be translated ======
menuText H TreeMaskSave "Save" 0 {Save mask}
# ====== TODO To be translated ======
menuText H TreeMaskClose "Close" 0 {Close mask}
# ====== TODO To be translated ======
menuText H TreeMaskFillWithGame "Fill with game" 0 {Fill mask with game}
# ====== TODO To be translated ======
menuText H TreeMaskFillWithBase "Fill with base" 0 {Fill mask with all games in base}
# ====== TODO To be translated ======
menuText H TreeMaskInfo "Info" 0 {Show statistics for current mask}
menuText H TreeSort "Rendezés" 0
menuText H TreeSortAlpha "ABC" 0
menuText H TreeSortECO "ECO-kód" 0
menuText H TreeSortFreq "Gyakoriság" 0
menuText H TreeSortScore "Pontszám" 0
menuText H TreeOpt "Beállítások" 0
# ====== TODO To be translated ======
menuText H TreeOptSlowmode "slow mode" 0 {Slow mode for updates (high accuracy)}
# ====== TODO To be translated ======
menuText H TreeOptFastmode "Fast mode" 0 {Fast mode for updates (no move transposition)}
# ====== TODO To be translated ======
menuText H TreeOptFastAndSlowmode "Fast and slow mode" 0 {Fast mode then slow mode for updates}
menuText H TreeOptLock "Rögzítés" 0 {A fát az aktuális adatbázishoz köti ill. a kötést feloldja.}
menuText H TreeOptTraining "Edzés" 0 {Edzésüzemmód be- vagy kikapcsolása}
menuText H TreeOptAutosave "Cache-fájl automatikus mentése" 11 \
  {A faablak bezárásakor automatikusan elmenti a cache-fájlt.}
menuText H TreeHelp "Segítség" 0
menuText H TreeHelpTree "Segítség a fához" 0
menuText H TreeHelpIndex "Tartalom" 0
translate H SaveCache {Cache mentése}
translate H Training {Edzés}
translate H LockTree {Rögzítés}
translate H TreeLocked {rögzítve}
translate H TreeBest {Legjobb}
translate H TreeBestGames {A fa legjobb játszmái}
translate H TreeTitleRow \
  {    Lépés  ECO       Gyakoriság  Eredm. ÁtlÉlõ Telj. Átl.év}
translate H TreeTotal {ÖSSZESEN}
# ====== TODO To be translated ======
translate H DoYouWantToSaveFirst {Do you want to save first}
# ====== TODO To be translated ======
translate H AddToMask {Add to Mask}
# ====== TODO To be translated ======
translate H RemoveFromMask {Remove from Mask}
# ====== TODO To be translated ======
translate H Nag {Nag code}
# ====== TODO To be translated ======
translate H Marker {Marker}
# ====== TODO To be translated ======
translate H Include {Include}
# ====== TODO To be translated ======
translate H Exclude {Exclude}
# ====== TODO To be translated ======
translate H MainLine {Main line}
# ====== TODO To be translated ======
translate H Bookmark {Bookmark}
# ====== TODO To be translated ======
translate H NewLine {New line}
# ====== TODO To be translated ======
translate H ToBeVerified {To be verified}
# ====== TODO To be translated ======
translate H ToTrain {To train}
# ====== TODO To be translated ======
translate H Dubious {Dubious}
# ====== TODO To be translated ======
translate H ToRemove {To remove}
# ====== TODO To be translated ======
translate H NoMarker {No marker}
# ====== TODO To be translated ======
translate H ColorMarker {Color}
# ====== TODO To be translated ======
translate H WhiteMark {White}
# ====== TODO To be translated ======
translate H GreenMark {Green}
# ====== TODO To be translated ======
translate H YellowMark {Yellow}
# ====== TODO To be translated ======
translate H BlueMark {Blue}
# ====== TODO To be translated ======
translate H RedMark {Red}
# ====== TODO To be translated ======
translate H CommentMove {Comment move}
# ====== TODO To be translated ======
translate H CommentPosition {Comment position}
# ====== TODO To be translated ======
translate H AddMoveToMaskFirst {Add move to mask first}
# ====== TODO To be translated ======
translate H OpenAMaskFileFirst {Open a mask file first}
# ====== TODO To be translated ======
translate H Positions {Positions}
# ====== TODO To be translated ======
translate H Moves {Moves}

# Finder window:
menuText H FinderFile "Fájl" 0
menuText H FinderFileSubdirs "Keresés az alkönyvtárakban" 0
menuText H FinderFileClose "A fájlkeresõ bezárása" 15
menuText H FinderSort "Rendezés" 0
menuText H FinderSortType "Típus" 0
menuText H FinderSortSize "Méret" 0
menuText H FinderSortMod "Idõ" 0
menuText H FinderSortName "Név" 0
menuText H FinderSortPath "Útvonal" 0
menuText H FinderTypes "Típusok" 0
menuText H FinderTypesScid "SCID-adatbázisok" 0
menuText H FinderTypesOld "Régi formátumú SCID-adatbázisok" 5
menuText H FinderTypesPGN "PGN-fájlok" 0
menuText H FinderTypesEPD "EPD-fájlok" 0
menuText H FinderTypesRep "Repertoárfájlok" 0
menuText H FinderHelp "Segítség" 0
menuText H FinderHelpFinder "Segítség a fájlkeresõhöz" 0
menuText H FinderHelpIndex "Tartalom" 0
translate H FileFinder {Fájlkeresõ}
translate H FinderDir {Könyvtár}
translate H FinderDirs {Könyvtárak}
translate H FinderFiles {Fájlok}
translate H FinderUpDir {fel}
# ====== TODO To be translated ======
translate H FinderCtxOpen {Open}
# ====== TODO To be translated ======
translate H FinderCtxBackup {Backup}
# ====== TODO To be translated ======
translate H FinderCtxCopy {Copy}
# ====== TODO To be translated ======
translate H FinderCtxMove {Move}
# ====== TODO To be translated ======
translate H FinderCtxDelete {Delete}

# Player finder:
menuText H PListFile "Fájl" 0
menuText H PListFileUpdate "Frissít" 0
menuText H PListFileClose "Játékoskeresõ bezárása" 16
menuText H PListSort "Rendezés" 0
menuText H PListSortName "Név" 0
menuText H PListSortElo "Élõ" 0
menuText H PListSortGames "Játszmák" 0
menuText H PListSortOldest "Legrégibb" 0
menuText H PListSortNewest "Legújabb" 3

# Tournament finder:
menuText H TmtFile "Fájl" 0
menuText H TmtFileUpdate "Frissít" 0
menuText H TmtFileClose "A versenykeresõ bezárása" 18
menuText H TmtSort "Rendezés" 0
menuText H TmtSortDate "Dátum" 0
menuText H TmtSortPlayers "Játékosok" 0
menuText H TmtSortGames "Játszmák" 1
menuText H TmtSortElo "Élõ" 0
menuText H TmtSortSite "Helyszín" 0
menuText H TmtSortEvent "Esemény" 0
menuText H TmtSortWinner "Gyõztes" 0
translate H TmtLimit "Lista hossza"
translate H TmtMeanElo "Legkisebb átlagos Élõ"
translate H TmtNone "Nem találtam hozzá versenyt."

# Graph windows:
menuText H GraphFile "Fájl" 0
menuText H GraphFileColor "Mentés Color PostScript-ként..." 7
menuText H GraphFileGrey "Mentés Greyscale PostScript-ként..." 7
menuText H GraphFileClose "Ablak bezárása" 8
menuText H GraphOptions "Beállítások" 0
menuText H GraphOptionsWhite "Világos" 0
menuText H GraphOptionsBlack "Sötét" 0
menuText H GraphOptionsBoth "Mindkettõ" 1
menuText H GraphOptionsPInfo "A játékosinformáció játékosa" 0
translate H GraphFilterTitle "Szûrõgrafikon: gyakoriság 1000 játszmánként"
# ====== TODO To be translated ======
translate H GraphAbsFilterTitle "Filter Graph: frequency of the games"
# ====== TODO To be translated ======
translate H ConfigureFilter {Configure X-Axes for Year, Rating and Moves}
# ====== TODO To be translated ======
translate H FilterEstimate "Estimate"
# ====== TODO To be translated ======
translate H TitleFilterGraph "Scid: Filter Graph"

# Analysis window:
translate H AddVariation {Változat beszúrása}
# ====== TODO To be translated ======
translate H AddAllVariations {Add All Variations}
translate H AddMove {Lépés beszúrása}
translate H Annotate {Értékelõ jelekkel lát el}
# ====== TODO To be translated ======
translate H ShowAnalysisBoard {Show analysis board}
# ====== TODO To be translated ======
translate H ShowInfo {Show engine info}
# ====== TODO To be translated ======
translate H FinishGame {Finish game}
# ====== TODO To be translated ======
translate H StopEngine {Stop engine}
# ====== TODO To be translated ======
translate H StartEngine {Start engine}
# ====== TODO To be translated ======
translate H LockEngine {Lock engine to current position}
translate H AnalysisCommand {Elemzésparancs}
translate H PreviousChoices {Korábbi választások}
translate H AnnotateTime {Két lépés közötti idõ másodpercben}
translate H AnnotateWhich {Változatok hozzáadása}
translate H AnnotateAll {Mindkét fél lépéseihez}
# ====== TODO To be translated ======
translate H AnnotateAllMoves {Annotate all moves}
translate H AnnotateWhite {Csak világos lépéseihez}
translate H AnnotateBlack {Csak sötét lépéseihez}
translate H AnnotateNotBest {Ha a játszmában nem a legjobbat lépték}
# ====== TODO To be translated ======
translate H AnnotateBlundersOnly {When game move is an obvious blunder}
# ====== TODO To be translated ======
translate H AnnotateBlundersOnlyScoreChange {Analysis reports blunder, with score change from/to: }
# ====== TODO To be translated ======
translate H BlundersThreshold {Threshold}
translate H LowPriority {Alacsony CPU-prioritás}
# ====== TODO To be translated ======
translate H ClickHereToSeeMoves {Click here to see moves}
# ====== TODO To be translated ======
translate H ConfigureInformant {Configure Informant}
# ====== TODO To be translated ======
translate H Informant!? {Interesting move}
# ====== TODO To be translated ======
translate H Informant? {Poor move}
# ====== TODO To be translated ======
translate H Informant?? {Blunder}
# ====== TODO To be translated ======
translate H Informant?! {Dubious move}
# ====== TODO To be translated ======
translate H Informant+= {White has a slight advantage}
# ====== TODO To be translated ======
translate H Informant+/- {White has a moderate advantage}
# ====== TODO To be translated ======
translate H Informant+- {White has a decisive advantage}
# ====== TODO To be translated ======
translate H Informant++- {The game is considered won}
# ====== TODO To be translated ======
translate H Book {Book}

# Analysis Engine open dialog:
translate H EngineList {Elemzõ motorok listája}
translate H EngineName {Név}
translate H EngineCmd {Parancssor}
translate H EngineArgs {Paraméterek}
translate H EngineDir {Könyvtár}
translate H EngineElo {Élõ}
translate H EngineTime {Dátum}
translate H EngineNew {Új}
translate H EngineEdit {Szerkesztés}
translate H EngineRequired {A vastagbetûs mezõk szükségesek, a többiek kihagyhatók.}

# Stats window menus:
menuText H StatsFile "Fájl" 0
menuText H StatsFilePrint "Nyomtatás fájlba..." 0
menuText H StatsFileClose "Ablak bezárása" 8
menuText H StatsOpt "Beállítások" 0

# PGN window menus:
menuText H PgnFile "Fájl" 0
menuText H PgnFileCopy "A vágólapra másolja a játszmát" 2
menuText H PgnFilePrint "Nyomtatás fájlba..." 0
menuText H PgnFileClose "PGN-ablak bezárása" 12
menuText H PgnOpt "Megjelenítés" 0
menuText H PgnOptColor "Színes szöveg" 0
menuText H PgnOptShort "Rövid (3-soros) fejléc" 0
menuText H PgnOptSymbols "Szimbólumok használata" 1
menuText H PgnOptIndentC "Megjegyzések behúzása" 0
menuText H PgnOptIndentV "Változatok behúzása" 0
menuText H PgnOptColumn "Oszlopok stílusa (soronként egy lépés)" 0
menuText H PgnOptSpace "Szóköz a lépés sorszáma után" 3
menuText H PgnOptStripMarks "Színes mezõk és nyilak kifejtése" 2
menuText H PgnOptBoldMainLine "A fõváltozat lépései vastag betûvel" 21
menuText H PgnColor "Színek" 1
menuText H PgnColorHeader "Fejléc..." 0
menuText H PgnColorAnno "Értékelõ jelek..." 0
menuText H PgnColorComments "Megjegyzések..." 0
menuText H PgnColorVars "Változatok..." 0
menuText H PgnColorBackground "Háttér..." 0
# ====== TODO To be translated ======
menuText H PgnColorMain "Main line..." 0
# ====== TODO To be translated ======
menuText H PgnColorCurrent "Current move background..." 1
# ====== TODO To be translated ======
menuText H PgnColorNextMove "Next move background..." 0
menuText H PgnHelp "Segítség" 0
menuText H PgnHelpPgn "Segítség PGN-hez" 9
menuText H PgnHelpIndex "Tartalom" 0
translate H PgnWindowTitle {Játszmajegyzés - %u. játszma}

# Crosstable window menus:
menuText H CrosstabFile "Fájl" 0
menuText H CrosstabFileText "Nyomtatás szövegfájlba..." 10
menuText H CrosstabFileHtml "Nyomtatás HTML-fájlba..." 10
menuText H CrosstabFileLaTeX "Nyomtatás LaTeX-fájlba..." 10
menuText H CrosstabFileClose "Ablak bezárása" 8
menuText H CrosstabEdit "Szerkesztés" 1
menuText H CrosstabEditEvent "Esemény" 0
menuText H CrosstabEditSite "Helyszín" 0
menuText H CrosstabEditDate "Dátum" 0
menuText H CrosstabOpt "Megjelenítés" 0
menuText H CrosstabOptAll "Körmérkõzés" 0
menuText H CrosstabOptSwiss "Svájci" 0
menuText H CrosstabOptKnockout "Kieséses" 1
menuText H CrosstabOptAuto "Találd ki!" 0
menuText H CrosstabOptAges "Életkor évben" 0
menuText H CrosstabOptNats "Nemzetiség" 0
menuText H CrosstabOptRatings "Értékszámok" 1
menuText H CrosstabOptTitles "Címek" 0
menuText H CrosstabOptBreaks "Pontszám holtverseny eldöntéséhez" 0
menuText H CrosstabOptDeleted "Törölt játszmákkal együtt" 0
menuText H CrosstabOptColors "Színek (csak svájci rendszer esetén)" 2
menuText H CrosstabOptColumnNumbers "Számozott oszlopok (csak körmérkõzéshez)" 2
menuText H CrosstabOptGroup "Pontcsoportok" 1
menuText H CrosstabSort "Rendezés" 0
menuText H CrosstabSortName "Név" 0
menuText H CrosstabSortRating "Értékszám" 0
menuText H CrosstabSortScore "Pontszám" 0
menuText H CrosstabColor "Szín" 2
menuText H CrosstabColorPlain "Közönséges szöveg" 0
menuText H CrosstabColorHyper "Hypertext" 0
menuText H CrosstabHelp "Segítség" 0
menuText H CrosstabHelpCross "Segítség versenytáblázathoz" 0
menuText H CrosstabHelpIndex "Tartalom" 0
translate H SetFilter {Szûrõ beállítása}
translate H AddToFilter {Hozzáadja a szûrõhöz}
translate H Swiss {Svájci}
translate H Category {Kategória}

# Opening report window menus:
menuText H OprepFile "Fájl" 0
menuText H OprepFileText "Nyomtatás szövegfájlba..." 10
menuText H OprepFileHtml "Nyomtatás HTML-fájlba..." 10
menuText H OprepFileLaTeX "Nyomtatás LaTeX-fájlba..." 10
menuText H OprepFileOptions "Beállítások..." 0
menuText H OprepFileClose "Ablak bezárása" 8
menuText H OprepFavorites "Kedvencek" 0
menuText H OprepFavoritesAdd "Összefoglaló hozzáadása..." 0
menuText H OprepFavoritesEdit "Kedvencek átszerkesztése..." 0
menuText H OprepFavoritesGenerate "Összefoglaló készítése..." 0
menuText H OprepHelp "Segítség" 0
menuText H OprepHelpReport "Segítség a megnyitási összefoglalóhoz" 0
menuText H OprepHelpIndex "Tárgymutató" 0

# Repertoire editor:
menuText H RepFile "Fájl" 0
menuText H RepFileNew "Új" 0
menuText H RepFileOpen "Megnyitás..." 3
menuText H RepFileSave "Mentés..." 0
menuText H RepFileSaveAs "Mentés másként..." 5
menuText H RepFileClose "Ablak bezárása" 8
menuText H RepEdit "Szerkesztés" 1
menuText H RepEditGroup "Csoport hozzáadása" 0
menuText H RepEditInclude "Beveendõ elágazás" 0
menuText H RepEditExclude "Kizárandó elágazás" 0
menuText H RepView "Nézet" 0
menuText H RepViewExpand "Az összes csoportot kibontja" 20
menuText H RepViewCollapse "Az összes csoportot összehúzza" 20
menuText H RepSearch "Keresés" 0
menuText H RepSearchAll "Az egész repertoárban..." 3
menuText H RepSearchDisplayed "Csak a megjelenített elágazásokban..." 0
#Ez igen gyanús!
menuText H RepHelp "Segítség" 0
menuText H RepHelpRep "Segítség a repertoárhoz" 0
menuText H RepHelpIndex "Tartalom" 0
translate H RepSearch "Keresés a repertoárban"
translate H RepIncludedLines "beveendõ elágazások"
translate H RepExcludedLines "kizárandó elágazások"
translate H RepCloseDialog {Ebben a repertoárban elmentetlen változtatások vannak.

Tényleg folytatni akarod, és elvetni a létrehozott változtatásokat?
}

# Header search:
translate H HeaderSearch {Keresés fejléc alapján}
translate H EndSideToMove {Aki a játszma végén lépésre következik}
translate H GamesWithNoECO {Játszmák ECO nélkül?}
translate H GameLength {Játszmahossz}
translate H FindGamesWith {Megjelölt játszmák}
translate H StdStart {Különleges kezdés}
translate H Promotions {Gyalogátváltozások}
translate H Comments {Megjegyzések}
translate H Variations {Változatok}
translate H Annotations {Értékelõ jelek}
translate H DeleteFlag {Megjelölés törlése}
translate H WhiteOpFlag {Megnyitás világossal}
translate H BlackOpFlag {Megnyitás sötéttel}
translate H MiddlegameFlag {Középjáték}
translate H EndgameFlag {Végjáték}
translate H NoveltyFlag {Újítás}
translate H PawnFlag {Gyalogszerkezet}
translate H TacticsFlag {Taktika}
translate H QsideFlag {Vezérszárnyi játék}
translate H KsideFlag {Királyszárnyi játék}
translate H BrilliancyFlag {Csillogás}
translate H BlunderFlag {Elnézés}
translate H UserFlag {Felhasználó}
translate H PgnContains {Szöveg a PGN-ben}

# Game list window:
translate H GlistNumber {Szám}
translate H GlistWhite {Világos}
translate H GlistBlack {Sötét}
translate H GlistWElo {Világos Élõje}
translate H GlistBElo {Sötét Élõje}
translate H GlistEvent {Esemény}
translate H GlistSite {Helyszín}
translate H GlistRound {Forduló}
translate H GlistDate {Dátum}
translate H GlistYear {Év}
translate H GlistEDate {Az esemény dátuma}
translate H GlistResult {Eredmény}
translate H GlistLength {Hossz}
translate H GlistCountry {Ország}
translate H GlistECO {ECO}
translate H GlistOpening {Megnyitás}
translate H GlistEndMaterial {Végsõ anyagi helyzet}
translate H GlistDeleted {Törölt}
translate H GlistFlags {Megjelölések}
translate H GlistVars {Variations}
translate H GlistComments {Megjegyzések}
translate H GlistAnnos {Értékelõ jelek}
translate H GlistStart {Kezdet}
translate H GlistGameNumber {A játszma sorszáma}
translate H GlistFindText {Szöveg keresése}
translate H GlistMoveField {Lépés}
translate H GlistEditField {Konfigurálás}
translate H GlistAddField {Hozzáad}
translate H GlistDeleteField {Eltávolít}
translate H GlistWidth {Szélesség}
translate H GlistAlign {Igazít}
translate H GlistColor {Szín}
translate H GlistSep {Elválasztó}
# ====== TODO To be translated ======
translate H GlistRemoveThisGameFromFilter  {Remove this game from Filter}
# ====== TODO To be translated ======
translate H GlistRemoveGameAndAboveFromFilter  {Remove game (and all above it) from Filter}
# ====== TODO To be translated ======
translate H GlistRemoveGameAndBelowFromFilter  {Remove game (and all below it) from Filter}
# ====== TODO To be translated ======
translate H GlistDeleteGame {(Un)Delete this game} 
# ====== TODO To be translated ======
translate H GlistDeleteAllGames {Delete all games in filter} 
# ====== TODO To be translated ======
translate H GlistUndeleteAllGames {Undelete all games in filter} 

# Maintenance window:
translate H DatabaseName {Az adatbázis neve:}
translate H TypeIcon {Típusikon:}
translate H NumOfGames {Játszmák:}
translate H NumDeletedGames {Törölt játszmák:}
translate H NumFilterGames {Szûrt játszmák:}
translate H YearRange {Évtartomány:}
translate H RatingRange {Értékszámtartomány:}
translate H Description {Leírás}
translate H Flag {Megjelölés}
translate H DeleteCurrent {Törli az aktuális játszmát.}
translate H DeleteFilter {Törli a szûrt játszmákat.}
translate H DeleteAll {Minden játszmát töröl.}
translate H UndeleteCurrent {Helyreállítja az aktuális játszmát.}
translate H UndeleteFilter {Helyreállítja a szûrt játszmákat.}
translate H UndeleteAll {Minden játszmát helyreállít.}
translate H DeleteTwins {Törli az ikerjátszmákat.}
translate H MarkCurrent {Megjelöli az aktuális játszmát.}
translate H MarkFilter {Megjelöli a szûrt játszmákat.}
translate H MarkAll {Minden játszmát megjelöl.}
translate H UnmarkCurrent {Eltávolítja az aktuális játszma megjelölését.}
translate H UnmarkFilter {Eltávolítja a szûrt játszmák megjelölését.}
translate H UnmarkAll {Minden játszma megjelölését eltávolítja.}
translate H Spellchecking {Helyesírás-ellenõrzés}
translate H Players {Játékosok}
translate H Events {Események}
translate H Sites {Helyszínek}
translate H Rounds {Fordulók}
translate H DatabaseOps {Adatbázismûveletek}
translate H ReclassifyGames {ECO alapján osztályozza a játszmákat.}
translate H CompactDatabase {Adatbázis tömörítése}
translate H SortDatabase {Adatbázis rendezése}
translate H AddEloRatings {Élõ-értékszámok hozzáadása}
translate H AutoloadGame {Játszmasorszám automatikus betöltése}
#Igaz ez?
translate H StripTags {PGN-címkék eltüntetése}
translate H StripTag {Címke eltüntetése}
translate H Cleaner {Takarító}
translate H CleanerHelp {
SCID Takarítója el fogja végezni az aktuális adatbázison az összes olyan gondozási feladatot, amelyet az alábbi listáról kijelölsz.

Az ECO-osztályozásra és az ikertörlésre vonatkozó jelenlegi beállítások akkor jutnak érvényre, ha ezeket a feladatokat is kijelölöd.
}
translate H CleanerConfirm {
Ha a Takarító már elindult, többé nem lehet megállítani!

Nagy adatbázison a kiválasztott feladatoktól és aktuális beállításaiktól függõen a mûvelet sokáig eltarthat.

Biztos, hogy neki akarsz látni a kijelölt gondozási feladatoknak?
}
# ====== TODO To be translated ======
translate H TwinCheckUndelete {to flip; "u" undeletes both)}
# ====== TODO To be translated ======
translate H TwinCheckprevPair {Previous pair}
# ====== TODO To be translated ======
translate H TwinChecknextPair {Next pair}
# ====== TODO To be translated ======
translate H TwinChecker {Scid: Twin game checker}
# ====== TODO To be translated ======
translate H TwinCheckTournament {Games in tournament:}
# ====== TODO To be translated ======
translate H TwinCheckNoTwin {No twin  }
# ====== TODO To be translated ======
translate H TwinCheckNoTwinfound {No twin was detected for this game.\nTo show twins using this window, you must first use the "Delete twin games..." function. }
# ====== TODO To be translated ======
translate H TwinCheckTag {Share tags...}
# ====== TODO To be translated ======
translate H TwinCheckFound1 {Scid found $result twin games}
# ====== TODO To be translated ======
translate H TwinCheckFound2 { and set their delete flags}
# ====== TODO To be translated ======
translate H TwinCheckNoDelete {There are no games in this database to delete.}
# ====== TODO To be translated ======
translate H TwinCriteria1 { Your settings for finding twin games are potentially likely to\ncause non-twin games with similar moves to be marked as twins.}
# ====== TODO To be translated ======
translate H TwinCriteria2 {It is recommended that if you select "No" for "same moves", you should select "Yes" for the colors, event, site, round, year and month settings.\nDo you want to continue and delete twins anyway? }
# ====== TODO To be translated ======
translate H TwinCriteria3 {It is recommended that you specify "Yes" for at least two of the "same site", "same round" and "same year" settings.\nDo you want to continue and delete twins anyway?}
# ====== TODO To be translated ======
translate H TwinCriteriaConfirm {Scid: Confirm twin settings}
# ====== TODO To be translated ======
translate H TwinChangeTag "Change the following game tags:\n\n"
# ====== TODO To be translated ======
translate H AllocRatingDescription "This command will use the current spellcheck file to add Elo ratings to games in this database. Wherever a player has no currrent rating but his/her rating at the time of the game is listed in the spellcheck file, that rating will be added."
# ====== TODO To be translated ======
translate H RatingOverride "Overwrite existing non-zero ratings?"
# ====== TODO To be translated ======
translate H AddRatings "Add ratings to:"
# ====== TODO To be translated ======
translate H AddedRatings {Scid added $r Elo ratings in $g games.}
# ====== TODO To be translated ======
translate H NewSubmenu "New submenu"

# Comment editor:
translate H AnnotationSymbols  {Értékelõ szimbólumok:}
translate H Comment {Megjegyzés:}
translate H InsertMark {Megjelölés beszúrása}
translate H InsertMarkHelp {
Megjelölés beszúrása/törlése: szín, típus, mezõ kiválasztása.
Nyíl beszúrása/törlése: Kattintás a jobb gombbal két mezõn.
}

# Nag buttons in comment editor:
translate H GoodMove {Jó lépés}
translate H PoorMove {Rossz lépés}
translate H ExcellentMove {Kitûnõ lépés}
translate H Blunder {Elnézés}
translate H InterestingMove {Érdekes lépés}
translate H DubiousMove {Kétes értékû lépés}
translate H WhiteDecisiveAdvantage {Világosnak döntõ elõnye van.}
translate H BlackDecisiveAdvantage {Sötétnek döntõ elõnye van.}
translate H WhiteClearAdvantage {Világos elõnye nyilvánvaló.}
translate H BlackClearAdvantage {Sötét elõnye nyilvánvaló.}
translate H WhiteSlightAdvantage {Világos valamivel jobban áll.}
translate H BlackSlightAdvantage {Sötét valamivel jobban áll.}
translate H Equality {Egyenlõ állás}
translate H Unclear {Tisztázatlan állás}
translate H Diagram {Diagram}

# Board search:
translate H BoardSearch {Állás keresése}
translate H FilterOperation {Elvégzendõ mûvelet az aktuális szûrõn:}
translate H FilterAnd {ÉS (Szûrõ szûkítése)}
translate H FilterOr {VAGY (Szûrõ bõvítése)}
translate H FilterIgnore {SEMMI (Szûrõ törlése)}
translate H SearchType {A keresés fajtája:}
translate H SearchBoardExact {Pontos állás (minden figura azonos mezõn)}
translate H SearchBoardPawns {Gyalogok (azonos anyag, minden gyalog azonos mezõn)}
translate H SearchBoardFiles {Vonalak (azonos anyag, minden gyalog azonos vonalon)}
translate H SearchBoardAny {Bármi (azonos anyag, gyalogok és figurák bárhol)}
translate H LookInVars {Változatokban is keres.}

# Material search:
translate H MaterialSearch {Keresés anyagra}
translate H Material {Anyag}
translate H Patterns {Alakzatok}
translate H Zero {Nullázás}
translate H Any {Bármi}
translate H CurrentBoard {Aktuális állás}
translate H CommonEndings {Gyakori végjátékok}
translate H CommonPatterns {Gyakori alakzatok}
translate H MaterialDiff {Anyagkülönbség}
translate H squares {mezõk}
translate H SameColor {Azonos szín}
translate H OppColor {Ellenkezõ szín}
translate H Either {Bármelyik}
translate H MoveNumberRange {Lépéstartomány}
translate H MatchForAtLeast {Egyezzen legalább}
translate H HalfMoves {fél lépésig.}

# Common endings in material search:
translate H EndingPawns {Gyalogvégjátékok}
translate H EndingRookVsPawns {Bástya gyalog(ok) ellen}
translate H EndingRookPawnVsRook {Bástya és 1 gyalog bástya ellen}
translate H EndingRookPawnsVsRook {Bástya és gyalogok bástya ellen}
translate H EndingRooks {Bástyavégjátékok}
translate H EndingRooksPassedA {Bástyavégjátékok szabad a-gyaloggal}
translate H EndingRooksDouble {Kettõs bástyavégjátékok}
translate H EndingBishops {Futóvégjátékok}
translate H EndingBishopVsKnight {Futó huszár ellen}
translate H EndingKnights {Huszárvégjátékok}
translate H EndingQueens {Vezérvégjátékok}
translate H EndingQueenPawnVsQueen {Vezér és 1 gyalog vezér ellen}
translate H BishopPairVsKnightPair {Futópár huszárpár ellen a középjátékban}

# Common patterns in material search:
translate H PatternWhiteIQP {Izolált világos vezérgyalog}
translate H PatternWhiteIQPBreakE6 {d4-d5 áttörés e6 ellen}
translate H PatternWhiteIQPBreakC6 {d4-d5 áttörés c6 ellen}
translate H PatternBlackIQP {Izolált sötét vezérgyalog}
translate H PatternWhiteBlackIQP {Izolált világos d-gyalog izolált sötét d-gyalog ellen}
translate H PatternCoupleC3D4 {Izolált világos c3-d4 gyalogpár}
translate H PatternHangingC5D5 {Lógó sötét gyalogok c5-ön és d5-ön}
translate H PatternMaroczy {Maróczy-centrum (gyalogok c4-en és e4-en)}
translate H PatternRookSacC3 {Bástyaáldozat c3-on}
translate H PatternKc1Kg8 {O-O-O O-O ellen (Kc1 és Kg8)}
translate H PatternKg1Kc8 {O-O O-O-O ellen (Kg1 és Kc8)}
translate H PatternLightFian {Világos mezejû fianchetto (g2 futó b7 futó ellen)}
translate H PatternDarkFian {Sötét mezejû fianchetto (b2 futó g7 futó ellen)}
translate H PatternFourFian {Négyes fianchetto (futók b2-n, g2-n, b7-en és g7-en)}

# Game saving:
translate H Today {Ma}
translate H ClassifyGame {Játszma osztályozása}

# Setup position:
translate H EmptyBoard {Tábla letakarítása}
translate H InitialBoard {Alapállás}
translate H SideToMove {Ki lép?}
translate H MoveNumber {Lépés száma}
translate H Castling {Sáncolás}
translate H EnPassantFile {"en passant"-vonal}
translate H ClearFen {FEN törlése}
translate H PasteFen {FEN beillesztése}
# ====== TODO To be translated ======
translate H SaveAndContinue {Save and continue}
# ====== TODO To be translated ======
translate H DiscardChangesAndContinue {Discard changes\nand continue}
# ====== TODO To be translated ======
translate H GoBack {Go back}

# Replace move dialog:
translate H ReplaceMove {Lépés cseréje}
translate H AddNewVar {Új változat beszúrása}
# ====== TODO To be translated ======
translate H NewMainLine {New Main Line}
translate H ReplaceMoveMessage {Itt már van lépés.

Kicserélheted, miáltal az összes õt követõ lépés elvész, vagy lépésedet beszúrhatod új változatként.

(Ha a jövõben nem akarod látni ezt az üzenetet, kapcsold ki a Beállítások:Lépések menüben a "Lépés cseréje elõtt rákérdez." beállítást.)}

# Make database read-only dialog:
translate H ReadOnlyDialog {Ha ezt az adatbázist kizárólag olvashatóvá teszed, nem lehet változtatásokat végezni rajta. Nem lehet játszmákat elmenteni vagy kicserélni, sem a törléskijelöléseket megváltoztatni. Minden rendezés vagy ECO-osztályozás csak átmeneti lesz.

Könnyen újra írhatóvá teheted az adatbázist, ha bezárod, majd újból megnyitod.

Tényleg kizárólag olvashatóvá akarod tenni ezt az adatbázist?}

# Clear game dialog:
translate H ClearGameDialog {Ez a játszma megváltozott.

Tényleg folytatni akarod, és elvetni a létrehozott változtatásokat?
}

# Exit dialog:
translate H ExitDialog {Tényleg ki akarsz lépni SCID-bõl?}
translate H ExitUnsaved {A következõ adatbázisokban elmentetlen játszmaváltoztatások vannak. Ha most kilépsz, ezek a változtatások elvesznek.}

# Import window:
translate H PasteCurrentGame {Beilleszti az aktuális játszmát.}
translate H ImportHelp1 {Bevisz vagy beilleszt egy PGN-formátumú játszmát a fenti keretbe.}
translate H ImportHelp2 {Itt jelennek meg az importálás közben fellépõ hibák.}
# ====== TODO To be translated ======
translate H OverwriteExistingMoves {Overwrite existing moves ?}

# ECO Browser:
translate H ECOAllSections {összes ECO-osztály}
translate H ECOSection {ECO-osztály}
translate H ECOSummary {Összefoglalás:}
translate H ECOFrequency {Alkódok gyakorisága:}

# Opening Report:
translate H OprepTitle {Megnyitási összefoglaló}
translate H OprepReport {Összefoglaló}
translate H OprepGenerated {Készítette:}
#Lehet, hogy ez "készült"?
translate H OprepStatsHist {Statisztika és történet}
translate H OprepStats {Statisztika}
translate H OprepStatAll {Az összefoglaló összes játszmája}
translate H OprepStatBoth {Mindkettõ}
translate H OprepStatSince {Idõszak kezdete:}
translate H OprepOldest {A legrégibb játszmák}
translate H OprepNewest {A legújabb játszmák}
translate H OprepPopular {Jelenlegi népszerûség}
translate H OprepFreqAll {Gyakoriság a teljes idõszakban:   }
translate H OprepFreq1   {Az utóbbi 1 évben: }
translate H OprepFreq5   {Az utóbbi 5 évben: }
translate H OprepFreq10  {Az utóbbi 10 évben: }
translate H OprepEvery {minden %u játszmában egyszer}
translate H OprepUp {%u%s növekedés az évek során}
translate H OprepDown {%u%s csökkenés az évek során}
translate H OprepSame {nincs változás az évek során}
translate H OprepMostFrequent {Leggyakoribb játékosok}
translate H OprepMostFrequentOpponents {Leggyakoribb ellenfelek}
translate H OprepRatingsPerf {Értékszám és teljesítmény}
translate H OprepAvgPerf {Átlagos értékszám és teljesítmény}
translate H OprepWRating {Világos értékszáma}
translate H OprepBRating {Sötét értékszáma}
translate H OprepWPerf {Világos teljesítménye}
translate H OprepBPerf {Sötét teljesítménye}
translate H OprepHighRating {A legnagyobb átlagértékszámú játszmák}
translate H OprepTrends {Tendenciák}
translate H OprepResults {Eredmény hosszúság és gyakoriság szerint}
translate H OprepLength {Játszmahossz}
translate H OprepFrequency {Gyakoriság}
translate H OprepWWins {Világos nyer: }
translate H OprepBWins {Sötét nyer:   }
translate H OprepDraws {Döntetlen:    }
translate H OprepWholeDB {teljes adatbázis}
translate H OprepShortest {A legrövidebb gyõzelmek}
translate H OprepMovesThemes {Lépések és témák}
translate H OprepMoveOrders {A vizsgált álláshoz vezetõ lépéssorrendek}
translate H OprepMoveOrdersOne \
  {Csak egy lépéssorrend vezetett ehhez az álláshoz:}
translate H OprepMoveOrdersAll \
  {%u lépéssorrend vezetett ehhez az álláshoz:}
translate H OprepMoveOrdersMany \
  {%u lépéssorrend vezetett ehhez az álláshoz. Az elsõ %u:}
translate H OprepMovesFrom {A vizsgált állásban tett lépések}
translate H OprepMostFrequentEcoCodes {Leggyakoribb ECO-kódok}
translate H OprepThemes {Pozíciós témák}
translate H OprepThemeDescription {Témák gyakorisága az egyes játszmák elsõ %u lépésében}
translate H OprepThemeSameCastling {Sáncolás azonos oldalra}
translate H OprepThemeOppCastling {Sáncolás ellenkezõ oldalra}
translate H OprepThemeNoCastling {Egyik király sem sáncolt.}
translate H OprepThemeKPawnStorm {Királyszárnyi gyalogroham}
translate H OprepThemeQueenswap {Vezércsere}
translate H OprepThemeWIQP {Elszigetelt világos vezérgyalog}
translate H OprepThemeBIQP {Elszigetelt sötét vezérgyalog}
translate H OprepThemeWP567 {Világos gyalog az 5./6./7. soron}
translate H OprepThemeBP234 {Sötét gyalog a 4./3./2. soron}
translate H OprepThemeOpenCDE {Nyílt c/d/e-vonal}
translate H OprepTheme1BishopPair {Csak az egyik félnek van futópárja.}
translate H OprepEndgames {Végjátékok}
translate H OprepReportGames {Az összefoglaló játszmái}
translate H OprepAllGames    {Összes játszma}
translate H OprepEndClass {Anyagi viszonyok az egyes játszmák végén}
translate H OprepTheoryTable {Elmélettáblázat}
translate H OprepTableComment {a legnagyobb értékszámú %u játszma alapján}
translate H OprepExtraMoves {A külön megjegyzéssel ellátott lépések száma az elmélettáblázatban}
translate H OprepMaxGames {Az elmélettáblázat létrehozásához felhasználható játszmák maximális száma}
translate H OprepViewHTML {HTML megtekintése}
translate H OprepViewLaTeX {LaTeX megtekintése}

# Player Report:
translate H PReportTitle {Összefoglaló játékosról}
translate H PReportColorWhite {világossal}
translate H PReportColorBlack {sötéttel}
translate H PReportMoves {%s után}
translate H PReportOpenings {Megnyitások}
translate H PReportClipbase {Kiüríti a vágólapot, és odamásolja a feltételnek megfelelõ játszmákat}

# Piece Tracker window:
translate H TrackerSelectSingle {A bal egérgomb kiválasztja ezt a figurát.}
translate H TrackerSelectPair {A bal egérgomb kiválasztja ezt a figurát; a jobb egérgomb a párját is kiválasztja.}
translate H TrackerSelectPawn {A bal egérgomb kiválasztja ezt a gyalogot; a jobb egérgomb az összes gyalogot kiválasztja.}
translate H TrackerStat {Statisztika}
translate H TrackerGames {Játszmák %-a, amelyekben erre a mezõre lépett}
translate H TrackerTime {Idõ %-a, amelyet az egyes mezõkön töltött}
translate H TrackerMoves {Lépések}
translate H TrackerMovesStart {Add meg a lépés számát, amelynél a nyomkövetésnek el kell kezdõdnie.}
translate H TrackerMovesStop {Add meg a lépés számát, amelynél a nyomkövetésnek be kell fejezõdnie.}

# Game selection dialogs:
translate H SelectAllGames {Az adatbázis összes játszmája}
translate H SelectFilterGames {Csak a szûrt játszmák}
translate H SelectTournamentGames {Csak az aktuális verseny játszmái}
translate H SelectOlderGames {Csak régebbi játszmák}

# Delete Twins window:
translate H TwinsNote {Két játszma akkor iker, ha ugyanazok játsszák õket, és megfelelnek az alant meghatározható kritériumoknak. Az ikerpárból a rövidebb játszma törlõdik. Javaslat: ikrek törlése elõtt érdemes helyesírás-ellenõrzést végezni az adatbázison, mert az javítja az ikerfelderítést.}
translate H TwinsCriteria {Kritériumok: Az ikerjátszmák közös tulajdonságai...}
translate H TwinsWhich {A megvizsgálandó játszmák}
translate H TwinsColors {Azonos szín?}
translate H TwinsEvent {Ugyanaz az esemény?}
translate H TwinsSite {Azonos helyszín?}
translate H TwinsRound {Ugyanaz a forduló?}
translate H TwinsYear {Azonos év?}
translate H TwinsMonth {Azonos hónap?}
translate H TwinsDay {Ugyanaz a nap?}
translate H TwinsResult {Azonos eredmény?}
translate H TwinsECO {Azonos ECO-kód?}
translate H TwinsMoves {Azonos lépések?}
translate H TwinsPlayers {A játékosok nevének összehasonlításakor:}
translate H TwinsPlayersExact {Teljes egyezés kell.}
translate H TwinsPlayersPrefix {Elég az elsõ 4 betûnek egyeznie.}
translate H TwinsWhen {Ikerjátszmák törlésekor}
translate H TwinsSkipShort {Hagyjuk figyelmen kívül az 5 lépésnél rövidebb játszmákat?}
translate H TwinsUndelete {Elõször állítsuk helyre az összes játszmát?}
translate H TwinsSetFilter {A szûrõt állítsuk az összes törölt ikerjátszmára?}
translate H TwinsComments {A megjegyzésekkel ellátott játszmákat mindig tartsuk meg?}
translate H TwinsVars {A változatokat tartalmazó játszmákat mindig tartsuk meg?}
translate H TwinsDeleteWhich {Melyik játszmát töröljem?}
translate H TwinsDeleteShorter {A rövidebbet}
translate H TwinsDeleteOlder {A kisebb sorszámút}
translate H TwinsDeleteNewer {A nagyobb sorszámút}
translate H TwinsDelete {Játszmák törlése}

# Name editor window:
translate H NameEditType {Szerkesztendõ névtípus}
translate H NameEditSelect {Szerkesztendõ játszmák}
translate H NameEditReplace {Cserél}
translate H NameEditWith {Erre}
translate H NameEditMatches {Egyezések: Ctrl+1...Ctrl+9 választ.}

# Classify window:
translate H Classify {Osztályoz}
translate H ClassifyWhich {Mely játszmák essenek át ECO-osztályozáson?}
translate H ClassifyAll {Az összes (írja felül a régi ECO-kódokat)}
translate H ClassifyYear {Az utóbbi évben játszott játszmák}
translate H ClassifyMonth {Az utóbbi hónapban játszott játszmák}
translate H ClassifyNew {Csak az eddig még nem osztályozott játszmák}
translate H ClassifyCodes {Használandó ECO-kódok}
translate H ClassifyBasic {Csak az alapkódok ("B12", ...)}
translate H ClassifyExtended {Kiterjesztett SCID-kódok ("B12j", ...)}

# Compaction:
translate H NameFile {Névfájl}
translate H GameFile {Játszmafájl}
translate H Names {Nevek}
translate H Unused {Használaton kívül}
translate H SizeKb {Méret (kB)}
translate H CurrentState {Jelenlegi állapot}
translate H AfterCompaction {Tömörítés után}
translate H CompactNames {Névfájl tömörítése}
translate H CompactGames {Játszmafájl tömörítése}
# ====== TODO To be translated ======
translate H NoUnusedNames "There are no unused names, so the name file is already fully compacted."
# ====== TODO To be translated ======
translate H NoUnusedGames "The game file is already fully compacted."
# ====== TODO To be translated ======
translate H NameFileCompacted {The name file for the database "[file tail [sc_base filename]]" was compacted.}
# ====== TODO To be translated ======
translate H GameFileCompacted {The game file for the database "[file tail [sc_base filename]]" was compacted.}

# Sorting:
translate H SortCriteria {Kritériumok}
translate H AddCriteria {Kritériumok hozzáadása}
translate H CommonSorts {Szokásos rendezések}
translate H Sort {Rendezés}

# Exporting:
translate H AddToExistingFile {Játszmák hozzáadása létezõ fájlhoz?}
translate H ExportComments {Megjegyzések exportálása?}
translate H ExportVariations {Változatok exportálása?}
translate H IndentComments {Megjegyzések igazítása?}
translate H IndentVariations {Változatok igazítása?}
translate H ExportColumnStyle {Oszlop stílusa (soronként egy lépés)?}
translate H ExportSymbolStyle {Szimbólumok stílusa:}
translate H ExportStripMarks {Kivegye a megjegyzésekbõl a mezõ- és nyílmegjelöléseket?}

# Goto game/move dialogs:
translate H LoadGameNumber {A betöltendõ játszma sorszáma:}
translate H GotoMoveNumber {Ugrás a következõ lépéshez:}

# Copy games dialog:
translate H CopyGames {Játszmák másolása}
translate H CopyConfirm {
 Tényleg át akarod másolni
 a [::utils::thousands $nGamesToCopy] szûrt játszmát
 a "$fromName" adatbázisból
 a "$targetName" adatbázisba?
}
translate H CopyErr {Nem tudom átmásolni a játszmákat.}
translate H CopyErrSource {forrás}
translate H CopyErrTarget {cél}
translate H CopyErrNoGames {szûrõjében nincsenek játszmák.}
translate H CopyErrReadOnly {kizárólag olvasható.}
translate H CopyErrNotOpen {nincs megnyitva.}

# Colors:
translate H LightSquares {Világos mezõk}
translate H DarkSquares {Sötét mezõk}
translate H SelectedSquares {Kiválasztott mezõk}
translate H SuggestedSquares {Javasolt lépések mezõi}
translate H WhitePieces {Világos figurák}
translate H BlackPieces {Sötét figurák}
translate H WhiteBorder {Világos körvonal}
translate H BlackBorder {Sötét körvonal}

# Novelty window:
translate H FindNovelty {Újítás keresése}
translate H Novelty {Újítás}
translate H NoveltyInterrupt {Újításkeresés leállítva}
translate H NoveltyNone {Ebben a játszmában nem találtam újítást.}
translate H NoveltyHelp {
SCID megkeresi az aktuális játszma elsõ olyan lépését, amely nem szerepel sem a kiválasztott adatbázisban, sem az ECO megnyitástárban.
}

# Sounds configuration:
translate H SoundsFolder {Hangfájlok könyvtára}
translate H SoundsFolderHelp {A könyvtárban a King.wav, a.wav, 1.wav, s.í.t. fájloknak kell szerepelniük.}
translate H SoundsAnnounceOptions {Lépésbemondások beállításai}
translate H SoundsAnnounceNew {Új lépés bemondása amint megtesszük}
translate H SoundsAnnounceForward {Lépés bemondása amikor egy lépést elõre lépünk}
translate H SoundsAnnounceBack {Lépés bemondása amikor visszaveszünk vagy egy lépést hátra lépünk}

# Upgrading databases:
translate H Upgrading {Felújítás}
translate H ConfirmOpenNew {
Ez régi formátumú (SCID 2) adatbázis, amelyet SCID 3 nem tud megnyitni, de már létrehozott egy új formátumú (SCID 3) verziót.

Szeretnéd megnyitni az adatbázis új formátumú verzióját?
}
translate H ConfirmUpgrade {
Ez régi formátumú (SCID 2) adatbázis. Új formátumú verziót kell létrehozni belõle, hogy SCID 3 használni tudja.

A felújítás új verziót hoz létre az adatbázisból. Az eredeti fájlok sértetlenül megmaradnak.

Az eljárás eltarthat egy darabig, de csak egyszer kell elvégezni. Megszakíthatod, ha túl sokáig tart.

Szeretnéd most felújítani ezt az adatbázist?
}

# Recent files options:
translate H RecentFilesMenu {Az aktuális fájlok száma a Fájl menüben}
translate H RecentFilesExtra {Az aktuális fájlok száma a kiegészítõ almenüben}

# My Player Names options:
translate H MyPlayerNamesDescription {
Add meg az általad kedvelt játékosok nevét, soronként egyet. Helyettesítõ karaktereket (pl. "?" tetszõleges karakter helyett, "*" tetszõleges karaktersorozat helyett) is használhatsz.

Amikor betöltöd egy a listán szereplõ játékos játszmáját, a fõablak sakktáblája szükség esetén elfordul, hogy a játszmát annak a játékosnak a szemszögébõl mutassa.
}
# ====== TODO To be translated ======
translate H showblunderexists {show blunder exists}
# ====== TODO To be translated ======
translate H showblundervalue {show blunder value}
# ====== TODO To be translated ======
translate H showscore {show score}
# ====== TODO To be translated ======
translate H coachgame {coach game}
# ====== TODO To be translated ======
translate H configurecoachgame {configure coach game}
# ====== TODO To be translated ======
translate H configuregame {Game configuration}
# ====== TODO To be translated ======
translate H Phalanxengine {Phalanx engine}
# ====== TODO To be translated ======
translate H Coachengine {Coach engine}
# ====== TODO To be translated ======
translate H difficulty {difficulty}
# ====== TODO To be translated ======
translate H hard {hard}
# ====== TODO To be translated ======
translate H easy {easy}
# ====== TODO To be translated ======
translate H Playwith {Play with}
# ====== TODO To be translated ======
translate H white {white}
# ====== TODO To be translated ======
translate H black {black}
# ====== TODO To be translated ======
translate H both {both}
# ====== TODO To be translated ======
translate H Play {Play}
# ====== TODO To be translated ======
translate H Noblunder {No blunder}
# ====== TODO To be translated ======
translate H blunder {blunder}
# ====== TODO To be translated ======
translate H Noinfo {-- No info --}
# ====== TODO To be translated ======
translate H PhalanxOrCraftyMissing {Phalanx or Crafty not found}
# ====== TODO To be translated ======
# ====== TODO To be translated ======
translate H moveblunderthreshold {move is a blunder if loss is greater than}
# ====== TODO To be translated ======
translate H limitanalysis {limit engine analysis time}
# ====== TODO To be translated ======
translate H seconds {seconds}
# ====== TODO To be translated ======
translate H Abort {Abort}
# ====== TODO To be translated ======
translate H OutOfOpening {Out of opening}
# ====== TODO To be translated ======
translate H NotFollowedLine {You did not follow the line}
# ====== TODO To be translated ======
translate H DoYouWantContinue {Do you want yo continue ?}
# ====== TODO To be translated ======
translate H CoachIsWatching {Coach is watching}
# ====== TODO To be translated ======
translate H Ponder {Permanent thinking}
# ====== TODO To be translated ======
translate H LimitELO {Limit ELO strength}
# ====== TODO To be translated ======
translate H DubiousMovePlayedTakeBack {Dubious move played, do you want to take back ?}
# ====== TODO To be translated ======
translate H WeakMovePlayedTakeBack {Weak move played, do you want to take back ?}
# ====== TODO To be translated ======
translate H BadMovePlayedTakeBack {Bad move played, do you want to take back ?}
# ====== TODO To be translated ======
translate H Iresign {I resign}
# ====== TODO To be translated ======
translate H yourmoveisnotgood {your move is not good}
# ====== TODO To be translated ======
translate H EndOfVar {End of variation}
# ====== TODO To be translated ======
translate H Openingtrainer {Opening trainer}
# ====== TODO To be translated ======
translate H DisplayCM {Display candidate moves}
# ====== TODO To be translated ======
translate H DisplayCMValue {Display candidate moves value}
# ====== TODO To be translated ======
translate H DisplayOpeningStats {Show statistics}
# ====== TODO To be translated ======
translate H ShowReport {Show report}
# ====== TODO To be translated ======
translate H NumberOfGoodMovesPlayed {good moves played}
# ====== TODO To be translated ======
translate H NumberOfDubiousMovesPlayed {dubious moves played}
# ====== TODO To be translated ======
translate H NumberOfMovesPlayedNotInRepertoire {moves played not in repertoire}
# ====== TODO To be translated ======
translate H NumberOfTimesPositionEncountered {times position encountered}
# ====== TODO To be translated ======
translate H PlayerBestMove  {Allow only best moves}
# ====== TODO To be translated ======
translate H OpponentBestMove {Opponent plays best moves}
# ====== TODO To be translated ======
translate H OnlyFlaggedLines {Only flagged lines}
# ====== TODO To be translated ======
translate H resetStats {Reset statistics}
# ====== TODO To be translated ======
translate H Repertoiretrainingconfiguration {Repertoire training configuration}
# ====== TODO To be translated ======
translate H Loadingrepertoire {Loading repertoire}
# ====== TODO To be translated ======
translate H Movesloaded {Moves loaded}
# ====== TODO To be translated ======
translate H Repertoirenotfound {Repertoire not found}
# ====== TODO To be translated ======
translate H Openfirstrepertoirewithtype {Open first a repertoire database with icon/type set to the right side}
# ====== TODO To be translated ======
translate H Movenotinrepertoire {Move not in repertoire}
# ====== TODO To be translated ======
translate H PositionsInRepertoire {Positions in repertoire}
# ====== TODO To be translated ======
translate H PositionsNotPlayed {Positions not played}
# ====== TODO To be translated ======
translate H PositionsPlayed {Positions played}
# ====== TODO To be translated ======
translate H Success {Success}
# ====== TODO To be translated ======
translate H DubiousMoves {Dubious moves}
# ====== TODO To be translated ======
translate H OutOfRepertoire {OutOfRepertoire}
# ====== TODO To be translated ======
# ====== TODO To be translated ======
# ====== TODO To be translated ======
# ====== TODO To be translated ======
translate H ConfigureTactics {Configure tactics}
# ====== TODO To be translated ======
translate H ResetScores {Reset scores}
# ====== TODO To be translated ======
translate H LoadingBase {Loading base}
# ====== TODO To be translated ======
translate H Tactics {Tactics}
# ====== TODO To be translated ======
translate H ShowSolution {Show solution}
# ====== TODO To be translated ======
translate H Next {Next}
# ====== TODO To be translated ======
translate H ResettingScore {Resetting score}
# ====== TODO To be translated ======
translate H LoadingGame {Loading game}
# ====== TODO To be translated ======
translate H MateFound {Mate found}
# ====== TODO To be translated ======
translate H BestSolutionNotFound {Best solution NOT found !}
# ====== TODO To be translated ======
translate H MateNotFound {Mate not found}
# ====== TODO To be translated ======
translate H ShorterMateExists {Shorter mate exists}
# ====== TODO To be translated ======
translate H ScorePlayed {Score played}
# ====== TODO To be translated ======
translate H Expected {expected}
# ====== TODO To be translated ======
translate H ChooseTrainingBase {Choose training base}
# ====== TODO To be translated ======
translate H Thinking {Thinking}
# ====== TODO To be translated ======
translate H AnalyzeDone {Analyze done}
# ====== TODO To be translated ======
translate H WinWonGame {Win won game}
# ====== TODO To be translated ======
translate H Lines {Lines}
# ====== TODO To be translated ======
translate H ConfigureUCIengine {Configure UCI engine}
# ====== TODO To be translated ======
translate H SpecificOpening {Specific opening}
# ====== TODO To be translated ======
translate H RandomLevel {Random level}
# ====== TODO To be translated ======
translate H StartFromCurrentPosition {Start from current position}
# ====== TODO To be translated ======
translate H FixedDepth {Fixed depth}
# ====== TODO To be translated ======
translate H Nodes {Nodes} 
# ====== TODO To be translated ======
translate H Depth {Depth}
# ====== TODO To be translated ======
translate H Time {Time} 
# ====== TODO To be translated ======
translate H SecondsPerMove {Seconds per move}
# ====== TODO To be translated ======
translate H TimeBonus {Time + bonus}
# ====== TODO To be translated ======
translate H WhiteTime {White time (minutes + sec/move)}
# ====== TODO To be translated ======
translate H BlackTime {Black time (minutes + sec/move)}
# ====== TODO To be translated ======
translate H AllExercisesDone {All exercises done}
# ====== TODO To be translated ======
translate H MoveOutOfBook {Move out of book}
# ====== TODO To be translated ======
translate H LastBookMove {Last book move}
# ====== TODO To be translated ======
translate H AnnotateSeveralGames {Annotate several games\nfrom current to :}
# ====== TODO To be translated ======
translate H FindOpeningErrors {Find opening errors}
# ====== TODO To be translated ======
translate H MarkTacticalExercises {Mark tactical exercises}
# ====== TODO To be translated ======
translate H UseBook {Use book}
# ====== TODO To be translated ======
translate H MultiPV {Multiple variations}
# ====== TODO To be translated ======
translate H Hash {Hash memory}
# ====== TODO To be translated ======
translate H OwnBook {Use engine book}
# ====== TODO To be translated ======
translate H BookFile {Opening book}
# ====== TODO To be translated ======
translate H AnnotateVariations {Annotate variations}
# ====== TODO To be translated ======
translate H ShortAnnotations {Short annotations}
# ====== TODO To be translated ======
translate H addAnnotatorTag {Add annotator tag}
# ====== TODO To be translated ======
translate H AddScoreToShortAnnotations {Add score to short annotations}
# ====== TODO To be translated ======
translate H Export {Export}
# ====== TODO To be translated ======
translate H BookPartiallyLoaded {Book partially loaded}
# ====== TODO To be translated ======
translate H Calvar {Calculation of variations}
# ====== TODO To be translated ======
translate H ConfigureCalvar {Configuration}
# ====== TODO To be translated ======
# ====== TODO To be translated ======
translate H Reti {Reti}
# ====== TODO To be translated ======
translate H English {English}
# ====== TODO To be translated ======
translate H d4Nf6Miscellaneous {1.d4 Nf6 Miscellaneous}
# ====== TODO To be translated ======
translate H Trompowsky {Trompowsky}
# ====== TODO To be translated ======
translate H Budapest {Budapest}
# ====== TODO To be translated ======
translate H OldIndian {Old Indian}
# ====== TODO To be translated ======
translate H BenkoGambit {Benko Gambit}
# ====== TODO To be translated ======
translate H ModernBenoni {Modern Benoni}
# ====== TODO To be translated ======
translate H DutchDefence {Dutch Defence}
# ====== TODO To be translated ======
translate H Scandinavian {Scandinavian}
# ====== TODO To be translated ======
translate H AlekhineDefence {Alekhine Defence}
# ====== TODO To be translated ======
translate H Pirc {Pirc}
# ====== TODO To be translated ======
translate H CaroKann {Caro-Kann}
# ====== TODO To be translated ======
translate H CaroKannAdvance {Caro-Kann Advance}
# ====== TODO To be translated ======
translate H Sicilian {Sicilian}
# ====== TODO To be translated ======
translate H SicilianAlapin {Sicilian Alapin}
# ====== TODO To be translated ======
translate H SicilianClosed {Sicilian Closed}
# ====== TODO To be translated ======
translate H SicilianRauzer {Sicilian Rauzer}
# ====== TODO To be translated ======
translate H SicilianDragon {Sicilian Dragon}
# ====== TODO To be translated ======
translate H SicilianScheveningen {Sicilian Scheveningen}
# ====== TODO To be translated ======
translate H SicilianNajdorf {Sicilian Najdorf}
# ====== TODO To be translated ======
translate H OpenGame {Open Game}
# ====== TODO To be translated ======
translate H Vienna {Vienna}
# ====== TODO To be translated ======
translate H KingsGambit {King's Gambit}
# ====== TODO To be translated ======
translate H RussianGame {Russian Game}
# ====== TODO To be translated ======
translate H ItalianTwoKnights {Italian/Two Knights}
# ====== TODO To be translated ======
translate H Spanish {Spanish}
# ====== TODO To be translated ======
translate H SpanishExchange {Spanish Exchange}
# ====== TODO To be translated ======
translate H SpanishOpen {Spanish Open}
# ====== TODO To be translated ======
translate H SpanishClosed {Spanish Closed}
# ====== TODO To be translated ======
translate H FrenchDefence {French Defence}
# ====== TODO To be translated ======
translate H FrenchAdvance {French Advance}
# ====== TODO To be translated ======
translate H FrenchTarrasch {French Tarrasch}
# ====== TODO To be translated ======
translate H FrenchWinawer {French Winawer}
# ====== TODO To be translated ======
translate H FrenchExchange {French Exchange}
# ====== TODO To be translated ======
translate H QueensPawn {Queen's Pawn}
# ====== TODO To be translated ======
translate H Slav {Slav}
# ====== TODO To be translated ======
translate H QGA {QGA}
# ====== TODO To be translated ======
translate H QGD {QGD}
# ====== TODO To be translated ======
translate H QGDExchange {QGD Exchange}
# ====== TODO To be translated ======
translate H SemiSlav {Semi-Slav}
# ====== TODO To be translated ======
translate H QGDwithBg5 {QGD with Bg5}
# ====== TODO To be translated ======
translate H QGDOrthodox {QGD Orthodox}
# ====== TODO To be translated ======
translate H Grunfeld {Grünfeld}
# ====== TODO To be translated ======
translate H GrunfeldExchange {Grünfeld Exchange}
# ====== TODO To be translated ======
translate H GrunfeldRussian {Grünfeld Russian}
# ====== TODO To be translated ======
translate H Catalan {Catalan}
# ====== TODO To be translated ======
translate H CatalanOpen {Catalan Open}
# ====== TODO To be translated ======
translate H CatalanClosed {Catalan Closed}
# ====== TODO To be translated ======
translate H QueensIndian {Queen's Indian}
# ====== TODO To be translated ======
translate H NimzoIndian {Nimzo-Indian}
# ====== TODO To be translated ======
translate H NimzoIndianClassical {Nimzo-Indian Classical}
# ====== TODO To be translated ======
translate H NimzoIndianRubinstein {Nimzo-Indian Rubinstein}
# ====== TODO To be translated ======
translate H KingsIndian {King's Indian}
# ====== TODO To be translated ======
translate H KingsIndianSamisch {King's Indian Sämisch}
# ====== TODO To be translated ======
translate H KingsIndianMainLine {King's Indian Main Line}
# ====== TODO To be translated ======
translate H CCDlgConfigureWindowTitle {Configure Correspondence Chess}
# ====== TODO To be translated ======
translate H CCDlgCGeneraloptions {General Options}
# ====== TODO To be translated ======
translate H CCDlgDefaultDB {Default Database:}
# ====== TODO To be translated ======
translate H CCDlgInbox {Inbox (path):}
# ====== TODO To be translated ======
translate H CCDlgOutbox {Outbox (path):}
# ====== TODO To be translated ======
translate H CCDlgXfcc {Xfcc Configuration:}
# ====== TODO To be translated ======
translate H CCDlgExternalProtocol {External Protocol Handler (e.g. Xfcc)}
# ====== TODO To be translated ======
translate H CCDlgFetchTool {Fetch Tool:}
# ====== TODO To be translated ======
translate H CCDlgSendTool {Send Tool:}
# ====== TODO To be translated ======
translate H CCDlgEmailCommunication {eMail Communication}
# ====== TODO To be translated ======
translate H CCDlgMailPrg {Mail program:}
# ====== TODO To be translated ======
translate H CCDlgBCCAddr {(B)CC Address:}
# ====== TODO To be translated ======
translate H CCDlgMailerMode {Mode:}
# ====== TODO To be translated ======
translate H CCDlgThunderbirdEg {e.g. Thunderbird, Mozilla Mail, Icedove...}
# ====== TODO To be translated ======
translate H CCDlgMailUrlEg {e.g. Evolution}
# ====== TODO To be translated ======
translate H CCDlgClawsEg {e.g Sylpheed Claws}
# ====== TODO To be translated ======
translate H CCDlgmailxEg {e.g. mailx, mutt, nail...}
# ====== TODO To be translated ======
translate H CCDlgAttachementPar {Attachment parameter:}
# ====== TODO To be translated ======
translate H CCDlgInternalXfcc {Use internal Xfcc support}
# ====== TODO To be translated ======
translate H CCDlgSubjectPar {Subject parameter:}
# ====== TODO To be translated ======
translate H CCDlgStartEmail {Start new eMail game}
# ====== TODO To be translated ======
translate H CCDlgYourName {Your Name:}
# ====== TODO To be translated ======
translate H CCDlgYourMail {Your eMail Address:}
# ====== TODO To be translated ======
translate H CCDlgOpponentName {Opponents Name:}
# ====== TODO To be translated ======
translate H CCDlgOpponentMail {Opponents eMail Address:}
# ====== TODO To be translated ======
translate H CCDlgGameID {Game ID (unique):}
# ====== TODO To be translated ======
translate H CCDlgTitNoOutbox {Scid: Correspondence Chess Outbox}
# ====== TODO To be translated ======
translate H CCDlgTitNoInbox {Scid: Correspondence Chess Inbox}
# ====== TODO To be translated ======
translate H CCDlgTitNoGames {Scid: No Correspondence Chess Games}
# ====== TODO To be translated ======
translate H CCErrInboxDir {Correspondence Chess inbox directory:}
# ====== TODO To be translated ======
translate H CCErrOutboxDir {Correspondence Chess outbox directory:}
# ====== TODO To be translated ======
translate H CCErrDirNotUsable {does not exist or is not accessible!\nPlease check and correct the settings.}
# ====== TODO To be translated ======
translate H CCErrNoGames {does not contain any games!\nPlease fetch them first.}
# ====== TODO To be translated ======
translate H CCDlgTitNoCCDB {Scid: No Correspondence Database}
# ====== TODO To be translated ======
translate H CCErrNoCCDB {No Database of type 'Correspondence' is opened. Please open one before using correspondence chess functions.}
# ====== TODO To be translated ======
translate H CCFetchBtn {Fetch games from the server and process the Inbox}
# ====== TODO To be translated ======
translate H CCPrevBtn {Goto previous game}
# ====== TODO To be translated ======
translate H CCNextBtn {Goto next game}
# ====== TODO To be translated ======
translate H CCSendBtn {Send move}
# ====== TODO To be translated ======
translate H CCEmptyBtn {Empty In- and Outbox}
# ====== TODO To be translated ======
translate H CCHelpBtn {Help on icons and status indicators.\nFor general Help press F1!}
# ====== TODO To be translated ======
translate H DoneWithPosition {Done with position}
# ====== TODO To be translated ======
}

# Tips of the day in Hungarian

set tips(H) {
  {
    Scid-ben több mint 30 oldalnyi <a Index>segítség</a> van, és a legtöbb Scid-ablakban
    az <b>F1</b> billentyû megnyomására elõbukkan egy arra az ablakra vonatkozó
    segítõ szöveg.
  }
  {
    Egyes Scid-ablakoknak (pl. a játszmainformációs terület, az
    <a Switcher>adatbázisváltó</a>) jobbegérgombos menüjük van.
    Nyomd meg a jobb egérgombot az egyes ablakokban, és meglátod,
    hogy ott is van-e, és milyen lehetõségeket kínál.
  }
  {
    Scid több lehetõséget is kínál lépések bevitelére, amelyek
    közül kedved szerint választhatsz. Használhatod az egeret
    (lépésjavaslattal vagy anélkül) vagy a billentyûzetet
    (lépéskiegészítéssel vagy anélkül). Olvasd el a részleteket a
    <a Moves>Lépések bevitele</a> címû segítõlapon.
  }
  {
    Ha bizonyos adatbázisokat gyakran használsz, jelöld meg õket egy-egy
    <a Bookmarks>könyvjelzõ</a> segítségével, s ezután a könyvjelzõmenü
    útján gyorsabban tudod megnyitni õket.
  }
  {
    A <a PGN>PGN-ablak</a> révén az aktuális játszma összes
    lépését láthatod (elágazásokkal és megjegyzésekkel).
    A PGN-ablakban bármelyik lépéshez elugorhatsz, ha rákattintasz a bal
    egérgombbal; a középsõ vagy a jobb egérgomb használatával pedig
    a lépéshez tartozó állást tekintheted meg.
  }
  {
    A bal egérgomb révén áthúzással egyik adatbázisból a másikba
    másolhatsz játszmákat az <a Switcher>adatbázisváltó</a> ablakban.
  }
  {
    Scid meg tud nyitni PGN-fájlokat, még akkor is, ha Gzip útján
    tömörítve vannak (.gz fájlnév-kiterjesztéssel). A megnyitott PGN-fájlok
    csak olvashatóak, ezért ha egy PGN-fájlt Scidben akarsz átszerkeszteni,
    hozz létre új Scid-adatbázist, és az <a Switcher>adatbázisváltó</a>
    segítségével másold bele a PGN-fájl játszmáit.
  }
  {
    Ha egy nagy adatbázist gyakran használsz a <a Tree>faszerkezet</a>-ablakkal,
    érdemes a <b>Cache-fájl feltöltése</b> pontot választani a faszerkezet-ablak
    Fájl menüjébõl. Ez megjegyzi sok gyakori megnyitás faszerkezet-adatait,
    miáltal gyorsabb lesz a hozzáférés az adatbázishoz.
  }
  {
    A <a Tree>faszerkezet</a>-ablak megmutatja az összes lépést, amelyet
    az adott állásban tettek, de ha az összes lépéssorrendet látni akarod,
    amely ehhez az álláshoz vezetett, <a OpReport>megnyitási összefoglaló</a>
    létrehozásával megkaphatod.
  }
  {
    A <a GameList>játszmák listája</a> ablakban egy oszlop fejlécére
    kattintva módosíthatod az oszlop szélességét.
  }
  {
    A <a PInfo>játékosinformáció</a>-ablak segítségével (kinyitásához
    egyszerûen kattints valamelyik játékos nevére a fõablak sakktáblája alatt
    található játszmainformációs területen) könnyedén beállítható úgy
    a <a Searches Filter>szûrõ</a>, hogy bizonyos játékos bizonyos eredménnyel
    végzõdött összes játszmáját tartalmazza. Ehhez csak a <red>piros színû</red>
    értékek valamelyikére kell kattintani.
  }
  {
    Megnyitás tanulmányozásakor egy fontos állásban nagyon hasznos lehet a
    <a Searches Board>pozíciókeresés</a> <b>Gyalogok</b> vagy
    <b>Oszlopok</b> beállítással, mert ez megmutathatja,
    hogy még mely megnyitások vezetnek ugyanehhez a gyalogszerkezethez.
  }
  {
    Ha a játszmainformációs területen (a sakktábla alatt) megnyomod
    a jobb egérgombot, elõbukkan egy menü, amellyel testre szabható. 
    Például megkérheted Scidet, hogy rejtse el a következõ lépést, ami
    edzésnél hasznos, ha egy játszma lépéseit ki akarod találni.
  }
  {
    Ha gyakran végzel <a Maintenance>gondozás</a>t nagy adatbázison,
    egyszerre hajthatsz végre több gondozási feladatot a
    <a Maintenance Cleaner>takarító</a> segítségével.
  }
  {
    Ha nagy adatbázisod van, amelyben a legtöbb játszmánál az esemény ideje
    is fel van tüntetve, és a játszmákat idõ szerint szeretnéd rendezni, végezd
    a <a Sorting>rendezés</a>t az esemény ideje majd esemény szerint,
    s ne fordítva. Így ugyanannak a versenynek a különbözõ keltezésû játszmái
    együtt fognak maradni (természetesen csak akkor, ha mindegyiknél azonos
    az esemény keltezése).
  }
  {
    <a Maintenance Twins>Ikerjátszmák törlése</a> elõtt célszerû
    <a Maintenance Spellcheck>helyesírásellenõrzés</a> alá vetni
    az adatbázist, mert így Scid több ikret tud megtalálni és törlésre kijelölni.
  }
  {
    <a Flags>Megjelölések</a> révén az adatbázis játszmáinak olyan
    jellegzetességeit lehet kiemelni, amelyek alapján késõbb keresést
    akarsz végezni (gyalogszerkezet, taktikai motívum stb.).
    Megjelölésekre <a Searches Header>keresés fejléc alapján</a> lehet
    keresni.
  }
  {
    Ha egy játszmát tanulmányozva szeretnél kipróbálni lépéseket
    a játszma megváltoztatása nélkül, egyszerûen kapcsold be a
    Változat kipróbálása üzemmódot (a <b>Ctrl+space</b>
    billentyûkombinációval vagy az eszköztár ikonjával), majd kapcsold ki,
    ha végeztél, és vissza akarsz térni az eredeti játszmához.
  }
  {
    Ha meg akarod keresni egy adott álláshoz vezetõ legkiemelkedõbb
    játszmákat (nagy értékszámú ellenfelek között), nyisd ki a
    <a Tree>faszerkezet</a>-ablakot, majd onnan nyisd ki a legjobb
    játszmák listáját. Még ezt a listát is szûkítheted, hogy csak
    meghatározott eredménnyel végzõdõ játszmákat mutasson.
  }
  {
    Remekül lehet megnyitást tanulmányozni nagy adatbázisra
    támaszkodva oly módon, hogy a <a Tree>faszerkezet</a>-ablakban
    bekapcsolod az edzést, majd az adatbázis ellen játszva megnézheted,
    mely elágazások fordulnak elõ gyakran.
  }
  {
    Ha két adatbázisod van nyitva, és látni szeretnéd az elsõ adatbázis
    <a Tree>faszerkezet</a>-adatait, miközben a másiknak egyik
    játszmáját tanulmányozod, a <b>Rögzítés</b> gomb megnyomásával
    rögzítsd a fát az elsõ adatbázishoz, majd válts át a másikra.
  }
  {
    A <a Tmt>versenykeresõ</a> nemcsak arra való, hogy megkeress
    vele egy versenyt. Arra is használható, hogy megnézd, hogy egy játékos
    mely versenyeken indult mostanában, vagy végignézd egy adott országban
    rendezett legkiemelkedõbb versenyeket.
  }
  {
    Az <a Searches Material>Anyag/szerkezet</a> keresõablakban
    megtalálható néhány gyakran elõforduló állásszerkezet, amely
    hasznos lehet megnyitás vagy középjáték tanulmányozásakor.
  }
  {
    Ha meghatározott anyagi helyzetre keresel az
    <a Searches Material>Anyag/szerkezet</a> keresõablakban, sokszor célszerû
    a keresést olyan játszmákra korlátozni, amelyek több lépésen keresztül
    megfelelnek a feltételeknek. Ily módon ki lehet zárni azokat a játszmákat,
    amelyekben a keresett helyzet csak rövid ideig állt fenn.
  }
  {
    Ha egy fontos adatbázist nem szeretnél véletlenül megváltoztatni,
    megnyitása után válaszd az <b>Írásvédelem...</b> pontot a
    <b>Fájl</b> menübõl, vagy állítsd át attribútumát csak olvashatóra.
  }
  {
    Ha XBoardot vagy WinBoardot használod (vagy más olyan sakkprogramot,
    amely egy sakkállást szabványos FEN-jelöléssel a vágólapra tud másolni),
    és át akarod másolni a rajta lévõ állást Scidbe, ennek leggyorsabb és
    legegyszerûbb módja az, hogy XBoard/WinBoard File menüjébõl
    <b>Copy Position</b> révén, majd Scid Szerkesztés menüjébõl
    <b>Kezdõállás beillesztése</b> útján átemeled az állást.
  }
  {
    <a Searches Header>Keresés fejléc alapján</a> esetében a
    játékos-, esemény-, helyszín- és fordulónevek nem érzékenyek
    kis- vagy nagybetû szempontjából, és az egyezés név belsejében is lehet.
    Ehelyett végeztethetsz kis- vagy nagybetû szempontjából érzékeny
    dzsókerkeresést is (ahol "?" = bármilyen karakter, "*" = esetleges
    további karakterek), ha a keresendõ szöveget "idézõjelben" adod meg.
    Például írj "*BEL"-t (idézõjelekkel) a helyszínmezõbe, ha meg akarod találni
    a Belgiumban játszott játszmákat, de a Belgrádban játszottakat nem.
  }
  {
    Ha egy játszmában helyesbíteni akarsz egy lépést, de nem szeretnéd,
    ha az õt követõ lépések elvesznének, nyisd ki az <a Import>Import</a>
    ablakot, nyomd meg a <b>Beilleszti az aktuális játszmát.</b> gombot,
    javítsd ki a téves lépést, majd nyomd meg az <b>Import</b> gombot.
  }
  {
    Ha van betöltve ECO-osztályozó fájlod, a <b>Játszma</b> menübõl
    <b>Megnyitás azonosítása</b> útján (gyorsbillentyû: Ctrl+Shift+D)
    elugorhatsz az aktuális játszmában elõforduló legmélyebb osztályozott álláshoz.
    .
  }
  {
    Ha meg akarod nézni egy fájl méretét vagy utolsó módosításának
    idõpontját, mielõtt megnyitnád, használd megnyitására a
    <a Finder>fájlkeresõ</a>t.
  }
  {
    A <a Repertoire>repertoár</a>fájl remek mód kedvelt megnyitásaid
    nyilvántartására, emellett meg lehet vele keresni azokat a játszmákat,
    amelyekben e megnyitások elõfordultak. Ha megnyitásaidat repertoárfájlban
    tartod, minden új játszmagyûjteményt átszûrhetsz vele,
    és végignézheted azokat a játszmákat, amelyekben kedvelt megnyitásaid
    elõfordulnak.
  }
  {
    A <a OpReport>megnyitási összefoglaló</a> nagyszerû lehetõséget nyújt
    egy állás megismerésére. Megnézheted, mennyire eredményes,
    gyakran vezet-e rövid döntetlenre, megmutatja a gyakran elõforduló
    pozíciós témákat.
  }
  {
    A leghasználatosabb értékelõ jeleket (!, !?, += stb.) a
    <a Comment>megjegyzésszerkesztõ<a> használata nélkül,
    billentyûzéssel is hozzá lehet fûzni az aktuális lépéshez vagy álláshoz.
    Például "!", majd Enter leütésével be tudod szúrni a "!" jelet.
    Bõvebb ismertetést a <a Moves>Lépések bevitele</a> címû segítõlap
    nyújt.
  }
  {
    Ha egy adatbázis megnyitásai között <a Tree>faszerkezet</a> segítségével
    böngészel, hasznos összefoglalót kaphatsz arról, hogy a vizsgált megnyitás
    milyen eredményes volt az utóbbi idõben erõs játékosok között. Ehhez nyisd ki
    a Statisztika ablakot (gyorsbillentyû: Ctrl+I).
  }
  {
    Megváltoztathatod a fõablak sakktáblájának méretét, ha a <b>Ctrl</b>
    és a <b>Shift</b> billentyûk nyomva tartása mellett megnyomod a
    <b>bal</b> vagy a <b>jobb</b> nyilat.
  }
  {
    <a Searches>Keresés</a> után könnyûszerrel végignézheted a talált
    játszmákat. Tartsd nyomva a <b>Ctrl</b> billentyût, és nyomd meg a
    <b>fel</b> vagy a <b>le</b> nyilat az elõzõ vagy a következõ
    <a Searches Filter>szûrõ</a>játszma betöltéséhez.
  }
}

# end of hungary.tcl




