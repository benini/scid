# czech.tcl: Czech menus and help for Scid.
# Contributed by Pavel Hanak and Vlastimil Babula
# Untranslated messages are marked with a "***" comment.

addLanguage C Czech 0 iso8859-2

proc setLanguage_C {} {

# File menu:
menuText C File "Soubor" 0
menuText C FileNew "Nový..." 0 {Vytvoøit novou Scid databázi}
menuText C FileOpen "Otevøít..." 0 {Otevøít existující Scid databázi}
menuText C FileClose "Zavøít" 0 {Zavøít aktivní Scid databázi}
menuText C FileFinder "Vyhledávaè" 2 {Otevøít okno vyhledávaèe souborù}
menuText C FileBookmarks "Zálo¾ky" 2 {Menu zálo¾ek (klávesa: Ctrl+B)}
menuText C FileBookmarksAdd "Pøidat zálo¾ku" 0 \
  {Zálo¾ka aktuální pozice a partie z databáze}
menuText C FileBookmarksFile "Zaøadit zálo¾ku" 0 \
  {Zaøadit zálo¾ku pro aktuální partii a pozici}
menuText C FileBookmarksEdit "Editovat zálo¾ky..." 0 \
  {Editovat menu zálo¾ek}
menuText C FileBookmarksList "Zobrazit slo¾ky jako jediný seznam" 0 \
  {Zobrazit slo¾ky se zálo¾kami jako jediný seznam, bez podnabídek}
menuText C FileBookmarksSub "Zobrazit slo¾ky jako podnabídky" 9 \
  {Zobrazit zálo¾kové slo¾ky jako podnabídky, ne jako jediný seznam}
menuText C FileMaint "Údr¾ba" 2 {Nástroje pro údr¾bu databáze Scidu}
menuText C FileMaintWin "Okno údr¾by" 0 \
  {Otevøít/zavøít okno pro údr¾bu Scid databáze}
menuText C FileMaintCompact "Kompaktování databáze..." 13 \
  {Kompaktování databázových souborù, odstranìní vymazaných partií a nepou¾ívaných jmen}
menuText C FileMaintClass "ECO klasifikace partií..." 0 \
  {Pøepoèítání ECO kódù v¹ech partií}
menuText C FileMaintSort "Setøídit databázi..." 0 \
  {Setøídit v¹echny partie v databázi}
menuText C FileMaintDelete "Vymazání zdvojených partií..." 0 \
  {Hledat zdvojené partie a oznaèit je pro vymazání}
menuText C FileMaintTwin "Kontrola zdvojených partií" 0 \
  {Otevøít/aktualizovat okno pro kontrolu zdvojených partií}
menuText C FileMaintName "Jména" 0 {Editace jmen a kontrola pravopisu}
menuText C FileMaintNameEditor "Editor jmen" 0 \
  {Otevøít/zavøít editor jmen}
menuText C FileMaintNamePlayer "Kontrola pravopisu hráèù..." 19 \
  {Kontrola pravopisu jmen hráèù s vyu¾itím souboru pro kontrolu pravopisu}
menuText C FileMaintNameEvent "Kontrola pravopisu turnajù..." 19 \
  {Kontrola pravopisu názvù turnajù s vyu¾itím souboru pro kontrolu pravopisu}
menuText C FileMaintNameSite "Kontrola pravopisu míst..." 19 \
  {Kontrola pravopisu míst turnajù s vyu¾itím souboru pro kontrolu pravopisu}
menuText C FileMaintNameRound "Kontrola pravopisu kol..." 19 \
  {Kontrola pravopisu kol s vyu¾itím souboru pro kontrolu pravopisu}
menuText C FileReadOnly "Pouze pro ètení..." 0 \
  {Nastavit aktuální databázi jako jen ke ètení, a zabránit tak zmìnám}
menuText C FileSwitch "Pøepnout se do databáze" 15 \
  {Pøepnout se do jiné otevøené databáze}
menuText C FileExit "Ukonèit" 0 {Ukonèit Scid}
# ====== TODO To be translated ======
menuText C FileMaintFixBase "Fix corrupted base" 0 {Try to fix a corrupted base}

# Edit menu:
menuText C Edit "Editace" 0
menuText C EditAdd "Pøidat variantu" 0 {Pøidat variantu k tomuto tahu v partii}
menuText C EditDelete "Vymazat variantu" 0 {Vymazat variantu k tomuto tahu}
menuText C EditFirst "Zaøadit jako první variantu" 0 \
  {Zaøadit variantu na první místo v seznamu variant}
menuText C EditMain "Pový¹it stávající variantu na hlavní" 30 \
  {Pový¹it stávající variantu na hlavní variantu}
menuText C EditTrial "Zkusit variantu" 1 \
    {Spustit/Ukonèit zku¹ební mód pro testování my¹lenky na ¹achovnici}
menuText C EditStrip "Odstranit" 0 {Odstranit komentáøe nebo varianty z této partie}
menuText C EditStripComments "Komentáøe" 0 \
  {Odstranit v¹echny poznámky a anotace z této partie}
menuText C EditStripVars "Varianty" 0 {Odstranit v¹echny varianty z této partie}
menuText C EditStripBegin "Tahy ze zaèátku" 5 \
  {Odstranit tahy ze zaèátku partie}
menuText C EditStripEnd "Tahy do konce" 5 \
  {Odstranit tahy do konce partie}
menuText C EditReset "Vyprázdnit schránku" 11 \
  {Kompletní vyprázdnìní databáze schránka}
menuText C EditCopy "Zkopírovat tuto partii do schránky" 23 \
  {Zkopírovat tuto partií do databáze schránka}
menuText C EditPaste "Vlo¾it poslední partii ze schránky" 24 \
  {Vlo¾it aktivní partii z databáze schránka}
menuText C EditPastePGN "Paste Clipboard text as PGN game..." 10 \
  {Interpret the clipboard text as a game in PGN notation and paste it here} ;# ***
menuText C EditSetup "Nastavit výchozí pozici..." 0 \
  {Nastavit výchozí pozici pro tuto partii}
menuText C EditCopyBoard "Kopírovat pozici" 4 \
  {Kopírovat aktuální pozici ve FEN notaci do textového výbìru (do clipboardu)}
menuText C EditPasteBoard "Vlo¾it poèáteèní pozici" 1 \
  {Nastavit poèáteèní pozici z aktuálního textového výbìru (z clipboardu)}

# Game menu:
menuText C Game "Partie" 0
menuText C GameNew "Nová partie" 0 \
  {Nastavit novou partii, v¹echny provedené zmìny budou ztraceny}
menuText C GameFirst "Natáhnout první partii" 10 {Natáhnout první partii z filtrovaných partií}
menuText C GamePrev "Natáhnout pøedchozí partii" 13 {Natáhnout pøedchozí partii z filtrovaných partií}
menuText C GameReload "Znovunatáhnout aktuální partii" 0 \
  {Znovunata¾ení aktuální partie, v¹echny doposud provedené zmìny budou ztraceny}
menuText C GameNext "Natáhnout následující partii" 14 {Natáhnout následující partii z filtrovaných partií}
menuText C GameLast "Natáhnout poslední partii" 11 {Natáhnout poslední partii z filtrovaných partií}
menuText C GameRandom "Natáhnout partii náhodnì" 1 {Natáhnout náhodnì vybranou partii z filtru}
menuText C GameNumber "Natáhnout partii èíslo..." 19 \
  {Natáhnout partii èíslo...}
menuText C GameReplace "Ulo¾it: pøepsání partie..." 0 \
  {Ulo¾it tuto partii - pøepí¹e pùvodní verzi}
menuText C GameAdd "Ulo¾it: pøidání nové partie..." 1 \
  {Ulo¾it tuto partii jako novou partii v databázi}
menuText C GameDeepest "Identifikace zahájení" 0 \
  {Pøejít na koncovou pozici z ECO knihovny, která odpovídá zvolenému zahájení}
menuText C GameGotoMove "Pøejít na tah èíslo..." 10 \
  {Pøejít v aktuální partii do pozice udané èíslem tahu}
menuText C GameNovelty "Hledat novinku..." 0 \
  {Hledat první tah této partie, který doposud nebyl hrán}

# Search Menu:
menuText C Search "Hledat" 0
menuText C SearchReset "Vyèistit filtr" 0 {Vyèistit filtr - vybrány budou v¹echny partie}
menuText C SearchNegate "Negace filtru" 0 {Negace filtru -  vybrány budou pouze partie vyòaté pøedcházejícím filtrem}
menuText C SearchCurrent "Aktuální pozice..." 0 {Hledat aktuální pozici}
menuText C SearchHeader "Hlavièka..." 0 {Hledat podle hlavièky partie (hráè, turnaj apod.)}
menuText C SearchMaterial "Materiál/Vzor..." 0 {Hledat podle materiálu nebo podle vzoru}
menuText C SearchUsing "Hledat pomocí souboru voleb..." 14 {Hledat s pou¾itím voleb zapsaných v souboru}

# Windows menu:
menuText C Windows "Okna" 0
menuText C WindowsComment "Editor komentáøù" 0 {Otevøít/zavøít editor komentáøù}
menuText C WindowsGList "Seznam partií" 2 {Otevøít/zavøít okno se seznamem partií}
menuText C WindowsPGN "Okno PGN" 5 {Otevøít/zavøít okno PGN}
menuText C WindowsPList "Vyhledávaè hráèù" 11 {Otevøít/zavøít okno vyhledávaèe hráèù}
menuText C WindowsTmt "Vyhledávaè turnajù" 11 {Otevøít/zavøít okno vyhledávaèe turnajù}
menuText C WindowsSwitcher "Výbìr databáze" 0 {Otevøít/zavøít okno pro výbìr databází}
menuText C WindowsMaint "Okno údr¾by" 6 {Otevøít/zavøít okno údr¾by}
menuText C WindowsECO "ECO prohlí¾eè" 1 {Otevøít/zavøít okno ECO prohlí¾eèe}
menuText C WindowsRepertoire "Editor repertoáru" 7 {Otevøít/zavøít editor repertoáru zahájení}
menuText C WindowsStats "Statistické okno" 0 {Otevøít/zavøít statistické okno filtru}
menuText C WindowsTree "Stromové okno" 4 {Otevøít/zavøít stromové okno}
menuText C WindowsTB "Okno tabulky koncovek" 13 {Otevøít/zavøít okno tabulek koncovek}
# ====== TODO To be translated ======
menuText C WindowsBook "Book Window" 0 {Open/close the Book window}
# ====== TODO To be translated ======
menuText C WindowsCorrChess "Correspondence Window" 0 {Open/close the Correspondence window}

# Tools menu:
menuText C Tools "Nástroje" 3
menuText C ToolsAnalysis "Program pro analýzu..." 0 \
  {Spustit/zastavit ¹achový program pro analýzu pozice}
menuText C ToolsAnalysis2 "Program pro analýzu #2..." 20 \
  {Spustit/zastavit druhý ¹achový program pro analýzu pozice}
menuText C ToolsCross "Turnajová tabulka" 0 {Ukázat turnajovou tabulku pro tuto partii}
menuText C ToolsEmail "Email mana¾er" 1 \
  {Otevøít/zavøít okno emailového mana¾era}
menuText C ToolsFilterGraph "Graf filtru" 0 \
  {Otevøít/zavøít okno grafu filtru}
# ====== TODO To be translated ======
menuText C ToolsAbsFilterGraph "Abs. Filter Graph" 7 {Open/close the filter graph window for absolute values}
menuText C ToolsOpReport "Profil zahájení" 7 \
  {Generovat profil zahájení pro aktuální pozicí}
# ====== TODO To be translated ======
menuText C ToolsOpenBaseAsTree "Open base as tree" 0   {Open a base and use it in Tree window}
# ====== TODO To be translated ======
menuText C ToolsOpenRecentBaseAsTree "Open recent base as tree" 0   {Open a recent base and use it in Tree window}
menuText C ToolsTracker "Stopaø figur"  0 {Otevøít okno stopaøe figur}
# ====== TODO To be translated ======
menuText C ToolsTraining "Training"  0 {Training tools (tactics, openings,...) }
# ====== TODO To be translated ======
menuText C ToolsTacticalGame "Tactical game"  0 {Play a game with tactics}
# ====== TODO To be translated ======
menuText C ToolsSeriousGame "Serious game"  0 {Play a serious game}
# ====== TODO To be translated ======
menuText C ToolsTrainOpenings "Openings"  0 {Train with a repertoire}
# ====== TODO To be translated ======
menuText C ToolsTrainTactics "Tactics"  0 {Solve tactics}
# ====== TODO To be translated ======
menuText C ToolsTrainCalvar "Calculation of variations"  0 {Calculation of variations training}
# ====== TODO To be translated ======
menuText C ToolsTrainFindBestMove "Find best move"  0 {Find best move}
# ====== TODO To be translated ======
menuText C ToolsTrainFics "Play on internet"  0 {Play on freechess.org}
# ====== TODO To be translated ======
menuText C ToolsBookTuning "Book tuning" 0 {Book tuning}
# ====== TODO To be translated ======
menuText C ToolsConnectHardware "Connect Hardware" 0 {Connect external hardware}
# ====== TODO To be translated ======
menuText C ToolsConnectHardwareConfigure "Configure..." 0 {Configure external hardware and connection}
# ====== TODO To be translated ======
menuText C ToolsConnectHardwareNovagCitrineConnect "Connect Novag Citrine" 0 {Connect Novag Citrine}
# ====== TODO To be translated ======
menuText C ToolsConnectHardwareInputEngineConnect "Connect Input Engine" 0 {Connect Input Engine (e.g. DGT)}
menuText C ToolsPInfo "Informace o hráèích"  0 \
  {Otevøít/aktualizovat okno s informacemi o hráèích}
menuText C ToolsPlayerReport "Profil hráèe..." 7 \
  {Generovat profil hráèe}
menuText C ToolsRating "Graf ratingu" 5 \
  {Zobrazit graf vývoje ratingu hráèù aktuální partie}
menuText C ToolsScore "Graf skóre" 6  {Zobrazit okno grafu skóre}
menuText C ToolsExpCurrent "Export aktuální partie" 7 \
  {Zapsat aktuální partii do textového souboru}
menuText C ToolsExpCurrentPGN "Export partie do PGN souboru..." 17 \
  {Zapsat aktuální partii do PGN souboru}
menuText C ToolsExpCurrentHTML "Export partie do HTML souboru..." 17 \
  {Zapsat aktuální partii do HTML souboru}
# ====== TODO To be translated ======
menuText C ToolsExpCurrentHTMLJS "Export Game to HTML and JavaScript File..." 15 {Write current game to a HTML and JavaScript file}  
menuText C ToolsExpCurrentLaTeX "Export partie do LaTeX souboru..." 17 \
  {Zapsat aktuální partii do LaTeX souboru}
menuText C ToolsExpFilter "Export filtrovaných partií" 7 \
  {Zapsat v¹echny filtrované partie do textového souboru}
menuText C ToolsExpFilterPGN "Export filtrovaných partií do PGN souboru..." 30 \
  {Zapsat v¹echny filtrované partie do PGN souboru}
menuText C ToolsExpFilterHTML "Export filtrovaných partií do HTML souboru..." 30 \
  {Zapsat v¹echny filtrované partie do HTML souboru}
# ====== TODO To be translated ======
menuText C ToolsExpFilterHTMLJS "Export Filter to HTML and JavaScript File..." 17 {Write all filtered games to a HTML and JavaScript file}  
menuText C ToolsExpFilterLaTeX "Export filtrovaných partií do LaTeX souboru..." 30 \
  {Zapsat v¹echny filtrované partie do LaTeX souboru}
menuText C ToolsImportOne "Import jedné PGN partie..." 7 \
  {Importovat partii z PGN zápisu}
menuText C ToolsImportFile "Import souboru PGN partií..." 10 \
  {Importovat partie z PGN souboru}
# ====== TODO To be translated ======
menuText C ToolsStartEngine1 "Start engine 1" 0  {Start engine 1}
# ====== TODO To be translated ======
menuText C ToolsStartEngine2 "Start engine 2" 0  {Start engine 2}
# ====== TODO To be translated ======
menuText C Play "Play" 0
# ====== TODO To be translated ======
menuText C CorrespondenceChess "Correspondence Chess" 0 {Functions for eMail and Xfcc based correspondence chess}
# ====== TODO To be translated ======
menuText C CCConfigure "Configure..." 0 {Configure external tools and general setup}
# ====== TODO To be translated ======
menuText C CCOpenDB "Open Database..." 0 {Open the default Correspondence database}
# ====== TODO To be translated ======
menuText C CCRetrieve "Retrieve Games" 0 {Retrieve games via external (Xfcc-)helper}
# ====== TODO To be translated ======
menuText C CCInbox "Process Inobx" 0 {Process all files in scids Inbox}
# ====== TODO To be translated ======
menuText C CCPrevious "Previous Game" 0 {Go to previous game in Inbox}
# ====== TODO To be translated ======
menuText C CCNext "Next Game" 0 {Go to next game in Inbox}
# ====== TODO To be translated ======
menuText C CCSend "Send Move" 0 {Send your move via eMail or external (Xfcc-)helper}
# ====== TODO To be translated ======
menuText C CCResign "Resign" 0 {Resign (not via eMail)}
# ====== TODO To be translated ======
menuText C CCClaimDraw "Claim Draw" 0 {Send move and claim a draw (not via eMail)}
# ====== TODO To be translated ======
menuText C CCOfferDraw "Offer Draw" 0 {Send move and offer a draw (not via eMail)}
# ====== TODO To be translated ======
menuText C CCAcceptDraw "Accept Draw" 0 {Accept a draw offer (not via eMail)}
# ====== TODO To be translated ======
menuText C CCNewMailGame "New eMail Game..." 0 {Start a new eMail game}
# ====== TODO To be translated ======
menuText C CCMailMove "Mail Move..." 0 {Send the move via eMail to the opponent}
# ====== TODO To be translated ======
menuText C CCGamePage "Game Page..." 0 {Call up the game via the web browser}

# Options menu:
menuText C Options "Volby" 0
menuText C OptionsBoard "©achovnice" 1 {Volby zobrazení ¹achovnice}
menuText C OptionsBoardSize "Velikost ¹achovnice" 0 {Zmìnit velikost ¹achovnice}
menuText C OptionsBoardPieces "Styl figur" 0 \
  {Zmìnit styl zobrazení figur}
menuText C OptionsBoardColors "Barvy..." 0 {Zmìnit barvy ¹achovnice}
# ====== TODO To be translated ======
menuText C OptionsBoardGraphics "Squares..." 0 {Select textures for squares}
# ====== TODO To be translated ======
translate C OptionsBGW {Select texture for squares}
# ====== TODO To be translated ======
translate C OptionsBoardGraphicsText {Select graphic files for white and black squares:}
menuText C OptionsBoardNames "Jména mých hráèù..." 0 {Editovat jména mých hráèù}
menuText C OptionsExport "Volby exportu" 7 {Zmìnit volby pro textový export}
menuText C OptionsFonts "Fonty" 2 {Zmìnit fonty}
menuText C OptionsFontsRegular "Základní" 0 {Zmìnit základní font}
menuText C OptionsFontsMenu "Menu" 1 {Zmìnit font pro menu}
menuText C OptionsFontsSmall "Malé" 0 {Zmìnit malý font}
menuText C OptionsFontsFixed "Fixní" 0 {Zmìnit font fixní ¹íøky}
menuText C OptionsGInfo "Informace o partii" 0 {Volby pro informace o partii}
menuText C OptionsLanguage "Jazyk" 0 {Vybrat jazyk menu}
# ====== TODO To be translated ======
menuText C OptionsMovesTranslatePieces "Translate pieces" 0 {Translate first letter of pieces}
menuText C OptionsMoves "Tahy" 0 {Volby pro zadávání tahù}
menuText C OptionsMovesAsk "Ptát se pøed nahrazením tahù" 0 \
  {Ptát se v¾dy pøed pøepsáním existujícího tahu}
menuText C OptionsMovesAnimate "Èas animace" 4 \
  {Nastavit èas pou¾itý na animaci tahù}
menuText C OptionsMovesDelay "Prodleva pøi automatickém pøehrávání..." 1 \
  {Nastavit èasovou prodlevu pøi automatickém pøehrávání}
menuText C OptionsMovesCoord "Souøadnicové zadávání tahù" 0 \
  {Povolit zadávání tahù pomocí souøadnic (napø. "g1f3")}
menuText C OptionsMovesSuggest "Ukázat navrhované tahy" 0 \
  {Zapnout/vypnout zobrazování navrhovaných tahù}
# ====== TODO To be translated ======
menuText C OptionsShowVarPopup "Show variations window" 0 {Turn on/off the display of a variations window}  
# ====== TODO To be translated ======
menuText C OptionsMovesSpace "Add spaces after move number" 0 {Add spaces after move number}  
menuText C OptionsMovesKey "Klávesnicové doplòování" 13 \
  {Zapnout/vypnout automatické doplòování tahù zadávaných klávesnicí}
menuText C OptionsNumbers "Formát èísel" 0 {Zvolit formát èísel}
menuText C OptionsStartup "Pøi spu¹tìní" 4 {Zvolit okna, která se otevøou pøi spu¹tìní}
# ====== TODO To be translated ======
menuText C OptionsTheme "Theme" 0 {Change look of interface}
menuText C OptionsWindows "Okna" 0 {Volby oken}
menuText C OptionsWindowsIconify "Automatická minimalizace" 12 \
   {Minimalizovat v¹echna okna pøi minimalizování hlavního okna}
menuText C OptionsWindowsRaise "Automaticky do popøedí" 15 \
  {Dát do popøedí jistá okna, jsou-li zakrytá}
menuText C OptionsSounds "Sounds..." 2 {Configure move announcement sounds} ;# ***
# ====== TODO To be translated ======
menuText C OptionsWindowsDock "Dock windows" 0 {Dock windows}
# ====== TODO To be translated ======
menuText C OptionsWindowsSaveLayout "Save layout" 0 {Save layout}
# ====== TODO To be translated ======
menuText C OptionsWindowsRestoreLayout "Restore layout" 0 {Restore layout}
# ====== TODO To be translated ======
menuText C OptionsWindowsShowGameInfo "Show game info" 0 {Show game info}
# ====== TODO To be translated ======
menuText C OptionsWindowsAutoLoadLayout "Auto load first layout" 0 {Auto load first layout at startup}
menuText C OptionsToolbar "Nástrojová li¹ta..." 11 \
  {Konfigurovat nástrojovou li¹tu hlavního okna}
menuText C OptionsECO "Natáhnout ECO soubor..." 10 {Natáhnout soubor s klasifikací ECO}
menuText C OptionsSpell "Natáhnout soubor pro kontrolu pravopisu..." 21 \
  {Natáhnout soubor Scidu pro kontrolu pravopisu}
menuText C OptionsTable "Adresáø pro tabulky koncovek..." 14 \
  {Vybrat soubor s tabulkami koncovek; v¹echny tabulky koncovek v jeho adresáøi budou pou¾ity}
menuText C OptionsRecent "Nedávné soubory..." 0 \
  {Zmìnit poèet nedávných souborù zobrazovaných v menu Soubor}
# ====== TODO To be translated ======
menuText C OptionsBooksDir "Books directory..." 0 {Sets the opening books directory}
# ====== TODO To be translated ======
menuText C OptionsTacticsBasesDir "Bases directory..." 0 {Sets the tactics (training) bases directory}
menuText C OptionsSave "Ulo¾it volby" 0 \
  "Ulo¾it v¹echny nastavitelné volby do souboru $::optionsFile"
menuText C OptionsAutoSave "Automaticky ukládat volby pøi ukonèení" 20 \
  {Automaticky ukládat v¹echny volby pøi ukonèení Scidu}

# Help menu:
menuText C Help "Nápovìda" 0
menuText C HelpContents "Obsah" 0 {Zobrazit stránku nápovìdy s obsahem}
menuText C HelpIndex "Index" 0 {Zobrazit stránku nápovìdy s indexem}
menuText C HelpGuide "Rychlý prùvodce" 7 {Zobrazit stránku nápovìdy s rychlým prùvodcem}
menuText C HelpHints "Rady" 0 {Zobrazit stránku nápovìdy s radami}
menuText C HelpContact "Kontakt" 0 {Zobrazit stránku nápovìdy s kontaktními informacemi}
menuText C HelpTip "Tip dne" 4 {Zobrazit u¾iteèný tip Scidu}
menuText C HelpStartup "Startovací okno" 0 {Zobrazit startovací okno}
menuText C HelpAbout "O aplikaci Scid" 2 {Informace o aplikaci Scid}

# Game info box popup menu:
menuText C GInfoHideNext "Skrýt následující tah" 0
menuText C GInfoMaterial "Ukázat hodnoty materiálu" 15
menuText C GInfoFEN "Ukázat FEN" 7
menuText C GInfoMarks "Zobrazovat barevná pole a ¹ipky" 11
menuText C GInfoWrap "Zalamovat dlouhé øádky" 0
menuText C GInfoFullComment "Zobrazit úplný komentáø" 15
menuText C GInfoPhotos "Zobrazit fotky" 10
menuText C GInfoTBNothing "Tabulky koncovek: nic" 19
menuText C GInfoTBResult "Tabulky koncovek: jen výsledek" 23
menuText C GInfoTBAll "Tabulky koncovek: výsledek a nejlep¹í tahy" 39
menuText C GInfoDelete "Vymazat/Nemazat tuto partii" 0
menuText C GInfoMark "Oznaèit/Odznaèit tuto partii" 0
# ====== TODO To be translated ======
menuText C GInfoInformant "Configure informant values" 0

# Main window buttons:
helpMsg C .main.fbutton.button.start {Jdi na zaèátek partie  (klávesa: Home)}
helpMsg C .main.fbutton.button.end {Jdi na konec partie  (klávesa: End)}
helpMsg C .main.fbutton.button.back {Jdi o jeden tah nazpìt  (klávesa: ©ipkaVlevo)}
helpMsg C .main.fbutton.button.forward {Jdi o jeden tah dopøedu  (klávesa: ©ipkaVpravo)}
helpMsg C .main.fbutton.button.intoVar {Skoè do varianty  (klávesová zkratka: v)}
helpMsg C .main.fbutton.button.exitVar {Opus» aktuální variantu  (klávesová zkratka: z)}
helpMsg C .main.fbutton.button.flip {Otoè ¹achovnici  (klávesová zkratka: .)}
helpMsg C .main.fbutton.button.coords {Zapnout/Vypnout zobrazování souøadnic ¹achovnice  (klávesová zkratka: 0)}
helpMsg C .main.fbutton.button.stm {Zapnout/Vypnout zobrazování ikony strany, která je na tahu}
helpMsg C .main.fbutton.button.autoplay {Automatické pøehrávání tahù  (klávesa: Ctrl+Z)}

# General buttons:
translate C Back {Zpìt}
translate C Browse {Prohlí¾et}
translate C Cancel {Zru¹it}
# ====== TODO To be translated ======
translate C Continue {Continue}
translate C Clear {Vyèistit}
translate C Close {Zavøít}
translate C Contents {Obsah}
translate C Defaults {Pøedvolené}
translate C Delete {Vymazat}
translate C Graph {Graf}
translate C Help {Nápovìda}
translate C Import {Import}
translate C Index {Index}
translate C LoadGame {Natáhnout partii}
translate C BrowseGame {Prohlédnout partii}
translate C MergeGame {Pøipojit partii}
# ====== TODO To be translated ======
translate C MergeGames {Merge Games}
translate C Preview {Náhled}
translate C Revert {Vrátit se}
translate C Save {Ulo¾it}
translate C Search {Hledat}
translate C Stop {Stop}
translate C Store {Uschovat}
translate C Update {Aktualizovat}
translate C ChangeOrient {Zmìnit orientaci okna}
translate C ShowIcons {Show Icons} ;# ***
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
translate C AverageRating {Prùmìrný rating}
translate C Event {Turnaj}
translate C Site {Místo}
translate C Country {Zemì}
translate C IgnoreColors {Ignorovat barvy}
translate C Date {Datum}
translate C EventDate {Datum turnaje}
translate C Decade {Dekáda}
translate C Year {Rok}
translate C Month {Mìsíc}
translate C Months {Leden Únor Bøezen Duben Kvìten Èerven Èervenec Srpen Záøí Øíjen Listopad Prosinec}
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
translate C readonly {read-only} ;# ***

# Standard error messages:
translate C ErrNotOpen {To není otevøená databáze.}
translate C ErrReadOnly {Tato databáze je jen ke ètení; nemù¾e být zmìnìna.}
translate C ErrSearchInterrupted {Hledání bylo pøeru¹eno; výsledky nejsou kompletní.}

# Game information:
translate C twin {zdvojená}
translate C deleted {vymazaná}
translate C comment {komentáø}
translate C hidden {skrytá}
translate C LastMove {Poslední tah}
translate C NextMove {Následující tah}
translate C GameStart {Zaèátek partie}
translate C LineStart {Zaèátek série tahù}
translate C GameEnd {Konec partie}
translate C LineEnd {Konec série tahù}

# Player information:
translate C PInfoAll {Výsledky <b>v¹ech</b> partií}
translate C PInfoFilter {Výsledky <b>filtrovaných</b> partií}
translate C PInfoAgainst {Výsledky proti}
translate C PInfoMostWhite {Nejèastìj¹í zahájení za bílé}
translate C PInfoMostBlack {Nejèastìj¹í zahájení za èerné}
translate C PInfoRating {Historie ratingu}
translate C PInfoBio {Biografie}
translate C PInfoEditRatings {Editovat ratingy}

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
translate C WinningMoves {vyhrávající tahy}
translate C DrawingMoves {remizující tahy}
translate C LosingMoves {prohrávající tahy}
translate C UnknownMoves {tahy s neznámým výsledkem}

# Tip of the day:
translate C Tip {Tip}
translate C TipAtStartup {Tip pøi spu¹tìní}

# Tree window menus:
menuText C TreeFile "Soubor" 0
# ====== TODO To be translated ======
menuText C TreeFileFillWithBase "Fill Cache with base" 0 {Fill the cache file with all games in current base}
# ====== TODO To be translated ======
menuText C TreeFileFillWithGame "Fill Cache with game" 0 {Fill the cache file with current game in current base}
# ====== TODO To be translated ======
menuText C TreeFileSetCacheSize "Cache size" 0 {Set the cache size}
# ====== TODO To be translated ======
menuText C TreeFileCacheInfo "Cache info" 0 {Get info on cache usage}
menuText C TreeFileSave "Ulo¾it cache soubor" 0 \
  {Ulo¾it stromový cache (.stc) soubor}
menuText C TreeFileFill "Naplnit cache soubor" 0 \
  {Naplnit cache soubor nejbì¾nìj¹ími pozicemi zahájení}
menuText C TreeFileBest "Seznam nejlep¹ích partií" 0 {Zobrazit seznam nejlep¹ích partií  stromu}
menuText C TreeFileGraph "Okno grafu" 0 {Zobrazit graf pro tuto vìtev stromu}
menuText C TreeFileCopy "Kopírovat text stromu do clipboardu" 0 \
  {Kopírovat stromové statistiky do textového výbìru}
menuText C TreeFileClose "Zavøít stromové okno" 0 {Zavøít stromové okno}
# ====== TODO To be translated ======
menuText C TreeMask "Mask" 0
# ====== TODO To be translated ======
menuText C TreeMaskNew "New" 0 {New mask}
# ====== TODO To be translated ======
menuText C TreeMaskOpen "Open" 0 {Open mask}
# ====== TODO To be translated ======
menuText C TreeMaskSave "Save" 0 {Save mask}
# ====== TODO To be translated ======
menuText C TreeMaskClose "Close" 0 {Close mask}
# ====== TODO To be translated ======
menuText C TreeMaskFillWithGame "Fill with game" 0 {Fill mask with game}
# ====== TODO To be translated ======
menuText C TreeMaskFillWithBase "Fill with base" 0 {Fill mask with all games in base}
# ====== TODO To be translated ======
menuText C TreeMaskInfo "Info" 0 {Show statistics for current mask}
menuText C TreeSort "Øadit" 2
menuText C TreeSortAlpha "Abecednì" 0
menuText C TreeSortECO "ECO kód" 0
menuText C TreeSortFreq "Frekvence" 0
menuText C TreeSortScore "Skóre" 0
menuText C TreeOpt "Volby" 0
# ====== TODO To be translated ======
menuText C TreeOptSlowmode "slow mode" 0 {Slow mode for updates (high accuracy)}
# ====== TODO To be translated ======
menuText C TreeOptFastmode "Fast mode" 0 {Fast mode for updates (no move transposition)}
# ====== TODO To be translated ======
menuText C TreeOptFastAndSlowmode "Fast and slow mode" 0 {Fast mode then slow mode for updates}
# ====== TODO To be translated ======
menuText C TreeOptStartStop "Auto refreshing" 0 {Toggles automatic refreshing of the tree window}
menuText C TreeOptLock "Zamknout" 0 {Zamknout/Odemknout strom k aktuální databázi}
menuText C TreeOptTraining "Trénink" 0 {Zapnout/Vypnout stromový tréninkový mód}
menuText C TreeOptAutosave "Automatické ukládání cache souboru" 0 \
  {Automatické ukládání cache souboru pøi uzavøení stromového okna}
menuText C TreeHelp "Nápovìda" 0
menuText C TreeHelpTree "Nápovìda - Strom" 11
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
  {    Tah    ECO       Frekvence    Skóre  PrElo Perf  PrRok %remíz}
translate C TreeTotal {CELKEM}
# ====== TODO To be translated ======
translate C DoYouWantToSaveFirst {Do you want to save first}
# ====== TODO To be translated ======
translate C AddToMask {Add to Mask}
# ====== TODO To be translated ======
translate C RemoveFromMask {Remove from Mask}
# ====== TODO To be translated ======
translate C AddThisMoveToMask {Add this move to Mask}
# ====== TODO To be translated ======
translate C Nag {Nag code}
# ====== TODO To be translated ======
translate C Marker {Marker}
# ====== TODO To be translated ======
translate C Include {Include}
# ====== TODO To be translated ======
translate C Exclude {Exclude}
# ====== TODO To be translated ======
translate C MainLine {Main line}
# ====== TODO To be translated ======
translate C Bookmark {Bookmark}
# ====== TODO To be translated ======
translate C NewLine {New line}
# ====== TODO To be translated ======
translate C ToBeVerified {To be verified}
# ====== TODO To be translated ======
translate C ToTrain {To train}
# ====== TODO To be translated ======
translate C Dubious {Dubious}
# ====== TODO To be translated ======
translate C ToRemove {To remove}
# ====== TODO To be translated ======
translate C NoMarker {No marker}
# ====== TODO To be translated ======
translate C ColorMarker {Color}
# ====== TODO To be translated ======
translate C WhiteMark {White}
# ====== TODO To be translated ======
translate C GreenMark {Green}
# ====== TODO To be translated ======
translate C YellowMark {Yellow}
# ====== TODO To be translated ======
translate C BlueMark {Blue}
# ====== TODO To be translated ======
translate C RedMark {Red}
# ====== TODO To be translated ======
translate C CommentMove {Comment move}
# ====== TODO To be translated ======
translate C CommentPosition {Comment position}
# ====== TODO To be translated ======
translate C AddMoveToMaskFirst {Add move to mask first}
# ====== TODO To be translated ======
translate C OpenAMaskFileFirst {Open a mask file first}
# ====== TODO To be translated ======
translate C Positions {Positions}
# ====== TODO To be translated ======
translate C Moves {Moves}

# Finder window:
menuText C FinderFile "Soubor" 0
menuText C FinderFileSubdirs "Hledat v podadresáøích" 0
menuText C FinderFileClose "Zavøít vyhledávaè souborù" 0
menuText C FinderSort "Øadit" 2
menuText C FinderSortType "Typ" 0
menuText C FinderSortSize "Velikost" 0
menuText C FinderSortMod "Zmìnìno" 0
menuText C FinderSortName "Jméno" 0
menuText C FinderSortPath "Cesta" 0
menuText C FinderTypes "Typy" 0
menuText C FinderTypesScid "Databáze Scidu" 0
menuText C FinderTypesOld "Databáze Scidu starého formátu" 15
menuText C FinderTypesPGN "PGN soubory" 0
menuText C FinderTypesEPD "EPD soubory" 0
menuText C FinderTypesRep "Repertoárové soubory" 0
menuText C FinderHelp "Nápovìda" 0
menuText C FinderHelpFinder "Nápovìda - Vyhledávaè souborù" 11
menuText C FinderHelpIndex "Index nápovìdy" 0
translate C FileFinder {Vyhledávaè souborù}
translate C FinderDir {Adresáø}
translate C FinderDirs {Adresáøe}
translate C FinderFiles {Soubory}
translate C FinderUpDir {nahoru}
# ====== TODO To be translated ======
translate C FinderCtxOpen {Open}
# ====== TODO To be translated ======
translate C FinderCtxBackup {Backup}
# ====== TODO To be translated ======
translate C FinderCtxCopy {Copy}
# ====== TODO To be translated ======
translate C FinderCtxMove {Move}
# ====== TODO To be translated ======
translate C FinderCtxDelete {Delete}

# Player finder:
menuText C PListFile "Soubor" 0
menuText C PListFileUpdate "Aktualizovat" 0
menuText C PListFileClose "Zavøít vyhledávaè hráèù" 0
menuText C PListSort "Øadit" 2
menuText C PListSortName "Jméno" 0
menuText C PListSortElo "ELO" 0
menuText C PListSortGames "Partie" 0
menuText C PListSortOldest "Nejstar¹í" 3
menuText C PListSortNewest "Nejnovìj¹í" 3

# Tournament finder:
menuText C TmtFile "Soubor" 0
menuText C TmtFileUpdate "Aktualizovat" 0
menuText C TmtFileClose "Zavøít vyhledávaè souborù" 0
menuText C TmtSort "Øadit" 2
menuText C TmtSortDate "Datum" 0
menuText C TmtSortPlayers "Hráèi" 0
menuText C TmtSortGames "Partie" 0
menuText C TmtSortElo "ELO" 0
menuText C TmtSortSite "Místo" 0
menuText C TmtSortEvent "Turnaj" 0
menuText C TmtSortWinner "Vítìz" 0
translate C TmtLimit "Limit seznamu"
translate C TmtMeanElo "Prùmìrné ELO"
translate C TmtNone "®ádné odpovídající turnaje nebyly nalezeny."

# Graph windows:
menuText C GraphFile "Soubor" 0
menuText C GraphFileColor "Ulo¾it jako barevný Postscript..." 12
menuText C GraphFileGrey "Ulo¾it jako èernobílý Postscript..." 13
menuText C GraphFileClose "Zavøít okno" 0
menuText C GraphOptions "Volby" 0
menuText C GraphOptionsWhite "Bílý" 0
menuText C GraphOptionsBlack "Èerný" 1
menuText C GraphOptionsBoth "Oba" 0
menuText C GraphOptionsPInfo "Informace o hráèi" 0
translate C GraphFilterTitle "Graf filtru: èetnost na 1000 partií"
# ====== TODO To be translated ======
translate C GraphAbsFilterTitle "Filter Graph: frequency of the games"
# ====== TODO To be translated ======
translate C ConfigureFilter {Configure X-Axes for Year, Rating and Moves}
# ====== TODO To be translated ======
translate C FilterEstimate "Estimate"
# ====== TODO To be translated ======
translate C TitleFilterGraph "Scid: Filter Graph"

# Analysis window:
translate C AddVariation {Pøidat variantu}
# ====== TODO To be translated ======
translate C AddAllVariations {Add All Variations}
translate C AddMove {Pøidat tah}
translate C Annotate {Anotace}
# ====== TODO To be translated ======
translate C ShowAnalysisBoard {Show analysis board}
# ====== TODO To be translated ======
translate C ShowInfo {Show engine info}
# ====== TODO To be translated ======
translate C FinishGame {Finish game}
# ====== TODO To be translated ======
translate C StopEngine {Stop engine}
# ====== TODO To be translated ======
translate C StartEngine {Start engine}
# ====== TODO To be translated ======
translate C LockEngine {Lock engine to current position}
translate C AnalysisCommand {Program pro analýzu}
translate C PreviousChoices {Pøedchozí vybrané programy}
translate C AnnotateTime {Nastavit èas mezi tahy v sekundách}
translate C AnnotateWhich {Pøidat varianty}
translate C AnnotateAll {Pro tahy obou stran}
# ====== TODO To be translated ======
translate C AnnotateAllMoves {Annotate all moves}
translate C AnnotateWhite {Pouze pro tahy bílého}
translate C AnnotateBlack {Pouze pro tahy èerného}
translate C AnnotateNotBest {Pokud tah v partii není nejlep¹ím tahem}
# ====== TODO To be translated ======
translate C AnnotateBlundersOnly {When game move is an obvious blunder}
# ====== TODO To be translated ======
translate C AnnotateBlundersOnlyScoreChange {Analysis reports blunder, with score change from/to: }
# ====== TODO To be translated ======
translate C BlundersThreshold {Threshold}
translate C LowPriority {Nízká CPU priorita}
# ====== TODO To be translated ======
translate C ClickHereToSeeMoves {Click here to see moves}
# ====== TODO To be translated ======
translate C ConfigureInformant {Configure Informant}
# ====== TODO To be translated ======
translate C Informant!? {Interesting move}
# ====== TODO To be translated ======
translate C Informant? {Poor move}
# ====== TODO To be translated ======
translate C Informant?? {Blunder}
# ====== TODO To be translated ======
translate C Informant?! {Dubious move}
# ====== TODO To be translated ======
translate C Informant+= {White has a slight advantage}
# ====== TODO To be translated ======
translate C Informant+/- {White has a moderate advantage}
# ====== TODO To be translated ======
translate C Informant+- {White has a decisive advantage}
# ====== TODO To be translated ======
translate C Informant++- {The game is considered won}
# ====== TODO To be translated ======
translate C Book {Book}
# ====== TODO To be translated ======
translate C OtherBookMoves {Opponent's book}
# ====== TODO To be translated ======
translate C OtherBookMovesTooltip {Moves to which the opponent has a reply}
# Analysis Engine open dialog:
translate C EngineList {Seznam programù pro analýzu}
translate C EngineName {Jméno}
translate C EngineCmd {Pøíkaz}
translate C EngineArgs {Parametry}
translate C EngineDir {Adresáø}
translate C EngineElo {ELO}
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
menuText C PgnFileCopy "Kopírovat partii do clipboardu" 0
menuText C PgnFilePrint "Vytisknout do souboru..." 0
menuText C PgnFileClose "Zavøít okno PGN" 0
menuText C PgnOpt "Zobrazit" 0
menuText C PgnOptColor "Barevné zobrazení" 0
menuText C PgnOptShort "Krátká (tøíøádková) hlavièka" 20
menuText C PgnOptSymbols "Symbolické anotace" 0
menuText C PgnOptIndentC "Odsazovat komentáøe" 10
menuText C PgnOptIndentV "Odsazovat varianty" 10
menuText C PgnOptColumn "Sloupcový styl (jeden tah na øádek)" 1
menuText C PgnOptSpace "Mezera za èíslem tahu" 0
menuText C PgnOptStripMarks "Odstranit kódy barevných polí a ¹ipek" 0
menuText C PgnOptBoldMainLine "Use Bold Text for Main Line Moves" 4 ;# ***
menuText C PgnColor "Barvy" 0
menuText C PgnColorHeader "Hlavièka..." 0
menuText C PgnColorAnno "Anotace..." 0
menuText C PgnColorComments "Komentáøe..." 0
menuText C PgnColorVars "Varianty..." 0
menuText C PgnColorBackground "Pozadí..." 0
# ====== TODO To be translated ======
menuText C PgnColorMain "Main line..." 0
# ====== TODO To be translated ======
menuText C PgnColorCurrent "Current move background..." 1
# ====== TODO To be translated ======
menuText C PgnColorNextMove "Next move background..." 0
menuText C PgnHelp "Nápovìda" 0
menuText C PgnHelpPgn "Nápovìda - Okno PGN " 16
menuText C PgnHelpIndex "Index nápovìdy" 0
translate C PgnWindowTitle {Game Notation - game %u} ;# ***

# Crosstable window menus:
menuText C CrosstabFile "Soubor" 0
menuText C CrosstabFileText "Vytisknout do textového souboru..." 14
menuText C CrosstabFileHtml "Vytisknout do HTML souboru..." 14
menuText C CrosstabFileLaTeX "Vytisknout do LaTeX souboru..." 14
menuText C CrosstabFileClose "Zavøít okno turnajové tabulky" 0
menuText C CrosstabEdit "Editovat" 0
menuText C CrosstabEditEvent "Turnaj" 0
menuText C CrosstabEditSite "Místo" 0
menuText C CrosstabEditDate "Datum" 0
menuText C CrosstabOpt "Zobrazit" 0
menuText C CrosstabOptAll "Ka¾dý s ka¾dým" 0
menuText C CrosstabOptSwiss "©výcarský systém" 3
menuText C CrosstabOptKnockout "Vyøazovací" 4
menuText C CrosstabOptAuto "Auto" 0
menuText C CrosstabOptAges "Vìk" 0
menuText C CrosstabOptNats "Národnost" 0
menuText C CrosstabOptRatings "Rating" 0
menuText C CrosstabOptTitles "Titul" 0
menuText C CrosstabOptBreaks "Výsledky tie-breaku" 10
menuText C CrosstabOptDeleted "Vèetnì vymazaných partií" 9
menuText C CrosstabOptColors "Barvy (jen pro ¹výcarský systém)" 0
menuText C CrosstabOptColumnNumbers "Èíslované sloupce (jen v tabulkách 'ka¾dý s ka¾dým')" 3
menuText C CrosstabOptGroup "Skupiny podle skóre" 0
menuText C CrosstabSort "Øadit" 2
menuText C CrosstabSortName "Jméno" 0
menuText C CrosstabSortRating "Rating" 0
menuText C CrosstabSortScore "Skóre" 0
menuText C CrosstabColor "Barvy" 0
menuText C CrosstabColorPlain "Prostý text" 0
menuText C CrosstabColorHyper "Hypertext" 0
menuText C CrosstabHelp "Nápovìda" 0
menuText C CrosstabHelpCross "Nápovìda - Turnajovou tabulku" 11
menuText C CrosstabHelpIndex "Index nápovìdy" 0
translate C SetFilter {Nastavit filtr}
translate C AddToFilter {Pøidat do filtru}
translate C Swiss {©výcarský systém}
translate C Category {Kategorie}

# Opening report window menus:
menuText C OprepFile "Soubor" 0
menuText C OprepFileText "Vytisknout do textového souboru..." 14
menuText C OprepFileHtml "Vytisknout do HTML souboru..." 14
menuText C OprepFileLaTeX "Vytisknout do LaTeX souboru..." 14
menuText C OprepFileOptions "Volby" 0
menuText C OprepFileClose "Zavøít okno s profilem" 0
menuText C OprepFavorites "Oblíbené" 0
menuText C OprepFavoritesAdd "Pøidat profil..." 0
menuText C OprepFavoritesEdit "Editovat oblíbené profily..." 0
menuText C OprepFavoritesGenerate "Generovat profil..." 0
menuText C OprepHelp "Nápovìda" 0
menuText C OprepHelpReport "Nápovìda - Profil zahájení" 11
menuText C OprepHelpIndex "Index nápovìdy" 11

# Repertoire editor:
menuText C RepFile "Soubor" 0
menuText C RepFileNew "Nový" 0
menuText C RepFileOpen "Otevøít..." 0
menuText C RepFileSave "Ulo¾it..." 0
menuText C RepFileSaveAs "Ulo¾it jako..." 7
menuText C RepFileClose "Zavøít okno" 0
menuText C RepEdit "Editace" 0
menuText C RepEditGroup "Pøidat skupinu" 0
menuText C RepEditInclude "Zahrnout variantu" 0
menuText C RepEditExclude "Vylouèit variantu" 0
menuText C RepView "Zobrazit" 0
menuText C RepViewExpand "Rozbalit v¹echny skupiny" 0
menuText C RepViewCollapse "Sbalit v¹echny skupiny" 0
menuText C RepSearch "Hledat" 0
menuText C RepSearchAll "Ve¹kerý repertoár..." 0
menuText C RepSearchDisplayed "Pouze zobrazené varianty..." 0
menuText C RepHelp "Nápovìda" 0
menuText C RepHelpRep "Nápovìda - Repertoár" 11
menuText C RepHelpIndex "Index nápovìdy" 0
translate C RepSearch "Repertoárové vyhledávání"
translate C RepIncludedLines "zahrnuté varianty"
translate C RepExcludedLines "vylouèené varianty"
translate C RepCloseDialog {Tento repertoár obsahuje neulo¾ené zmìny.

Opravdu chcete pokraèovat a zru¹it v¹echny zmìny, které jste uèinili?
}

# Header search:
translate C HeaderSearch {Hledat podle hlavièky}
translate C EndSideToMove {Side to move at end of game} ;# ***
translate C GamesWithNoECO {Partie bez ECO?}
translate C GameLength {Délka Partie}
translate C FindGamesWith {Najít partie s pøíznaky}
translate C StdStart {Nestandardní start}
translate C Promotions {Promìny}
translate C Comments {Komentáøe}
translate C Variations {Varianty}
translate C Annotations {Anotace}
translate C DeleteFlag {Mazací pøíznak}
translate C WhiteOpFlag {Zahájení bílého}
translate C BlackOpFlag {Zahájení èerného}
translate C MiddlegameFlag {Støední hra}
translate C EndgameFlag {Koncovka}
translate C NoveltyFlag {Novinka}
translate C PawnFlag {Pì¹cová struktura}
translate C TacticsFlag {Taktika}
translate C QsideFlag {Hra na dámském køídle}
translate C KsideFlag {Hra na královském køídle}
translate C BrilliancyFlag {Brilantní}
translate C BlunderFlag {Hrubka}
translate C UserFlag {U¾ivatel}
translate C PgnContains {PGN obsahuje text}

# Game list window:
translate C GlistNumber {Èíslo}
translate C GlistWhite {Bílý}
translate C GlistBlack {Èerný}
translate C GlistWElo {B-ELO}
translate C GlistBElo {È-ELO}
translate C GlistEvent {Turnaj}
translate C GlistSite {Místo}
translate C GlistRound {Kolo}
translate C GlistDate {Datum}
translate C GlistYear {Rok}
translate C GlistEDate {Datum turnaje}
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
# ====== TODO To be translated ======
translate C GlistRemoveThisGameFromFilter  {Remove this game from Filter}
# ====== TODO To be translated ======
translate C GlistRemoveGameAndAboveFromFilter  {Remove game (and all above it) from Filter}
# ====== TODO To be translated ======
translate C GlistRemoveGameAndBelowFromFilter  {Remove game (and all below it) from Filter}
# ====== TODO To be translated ======
translate C GlistDeleteGame {(Un)Delete this game} 
# ====== TODO To be translated ======
translate C GlistDeleteAllGames {Delete all games in filter} 
# ====== TODO To be translated ======
translate C GlistUndeleteAllGames {Undelete all games in filter} 

# Maintenance window:
translate C DatabaseName {Jméno databáze:}
translate C TypeIcon {Symbol:}
translate C NumOfGames {Partie:}
translate C NumDeletedGames {Vymazané partie:}
translate C NumFilterGames {Partie ve filtru:}
translate C YearRange {Rozsah rokù:}
translate C RatingRange {Rozsah ratingu:}
translate C Description {Popis}
translate C Flag {Pøíznak}
translate C DeleteCurrent {Vymazat aktuální partii}
translate C DeleteFilter {Vymazat filtrované partie}
translate C DeleteAll {Vymazat v¹echny partie}
translate C UndeleteCurrent {Obnovit aktuální partie po vymazání}
translate C UndeleteFilter {Obnovit filtrované partie po vymazání}
translate C UndeleteAll {Obnovit v¹echny partie po vymazání}
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
translate C CompactDatabase {Kompaktovat databázi}
translate C SortDatabase {Øadit databázi}
translate C AddEloRatings {Pøidat ELO rating}
translate C AutoloadGame {Automaticky otevírat partii è.}
translate C StripTags {Odstranit PGN znaèky}
translate C StripTag {Odstranit znaèku}
translate C Cleaner {Èi¹tìní databáze}
translate C CleanerHelp {
    Èi¹tìním databáze Scid provede u aktuální databáze v¹echny údr¾báøské akce, které zvolíte v seznamu.

    Pokud zvolíte ECO klasifikaci a mazání zdvojených partií pou¾ijí se aktuální nastavení z pøíslu¹ných dialogù.
}
translate C CleanerConfirm {
Jakmile je èi¹tìní jednou spu¹tìno, nemù¾e ji¾ být pøeru¹eno!

Tato akce mù¾e pro velké databáze trvat dlouhou dobu v závislosti na funkcích, které jste zvolili, a v závislosti na jejich stávajícím nastavení.

Jste si jisti, ¾e chcete zaèít s údr¾báøskými funkcemi, které jste zvolili?
}
# ====== TODO To be translated ======
translate C TwinCheckUndelete {to flip; "u" undeletes both)}
# ====== TODO To be translated ======
translate C TwinCheckprevPair {Previous pair}
# ====== TODO To be translated ======
translate C TwinChecknextPair {Next pair}
# ====== TODO To be translated ======
translate C TwinChecker {Scid: Twin game checker}
# ====== TODO To be translated ======
translate C TwinCheckTournament {Games in tournament:}
# ====== TODO To be translated ======
translate C TwinCheckNoTwin {No twin  }
# ====== TODO To be translated ======
translate C TwinCheckNoTwinfound {No twin was detected for this game.\nTo show twins using this window, you must first use the "Delete twin games..." function. }
# ====== TODO To be translated ======
translate C TwinCheckTag {Share tags...}
# ====== TODO To be translated ======
translate C TwinCheckFound1 {Scid found $result twin games}
# ====== TODO To be translated ======
translate C TwinCheckFound2 { and set their delete flags}
# ====== TODO To be translated ======
translate C TwinCheckNoDelete {There are no games in this database to delete.}
# ====== TODO To be translated ======
translate C TwinCriteria1 { Your settings for finding twin games are potentially likely to\ncause non-twin games with similar moves to be marked as twins.}
# ====== TODO To be translated ======
translate C TwinCriteria2 {It is recommended that if you select "No" for "same moves", you should select "Yes" for the colors, event, site, round, year and month settings.\nDo you want to continue and delete twins anyway? }
# ====== TODO To be translated ======
translate C TwinCriteria3 {It is recommended that you specify "Yes" for at least two of the "same site", "same round" and "same year" settings.\nDo you want to continue and delete twins anyway?}
# ====== TODO To be translated ======
translate C TwinCriteriaConfirm {Scid: Confirm twin settings}
# ====== TODO To be translated ======
translate C TwinChangeTag "Change the following game tags:\n\n"
# ====== TODO To be translated ======
translate C AllocRatingDescription "This command will use the current spellcheck file to add Elo ratings to games in this database. Wherever a player has no currrent rating but his/her rating at the time of the game is listed in the spellcheck file, that rating will be added."
# ====== TODO To be translated ======
translate C RatingOverride "Overwrite existing non-zero ratings?"
# ====== TODO To be translated ======
translate C AddRatings "Add ratings to:"
# ====== TODO To be translated ======
translate C AddedRatings {Scid added $r Elo ratings in $g games.}
# ====== TODO To be translated ======
translate C NewSubmenu "New submenu"

# Comment editor:
translate C AnnotationSymbols  {Anotaèní symboly:}
translate C Comment {Komentáø:}
translate C InsertMark {Vlo¾it znaèku}
translate C InsertMarkHelp {
Insert/remove mark: Select color, type, square.
Insert/remove arrow: Right-click two squares.
} ;# ***

# Nag buttons in comment editor:
translate C GoodMove {Good move} ;# ***
translate C PoorMove {Poor move} ;# ***
translate C ExcellentMove {Excellent move} ;# ***
translate C Blunder {Hrubka}
translate C InterestingMove {Interesting move} ;# ***
translate C DubiousMove {Dubious move} ;# ***
translate C WhiteDecisiveAdvantage {White has a decisive advantage} ;# ***
translate C BlackDecisiveAdvantage {Black has a decisive advantage} ;# ***
translate C WhiteClearAdvantage {White has a clear advantage} ;# ***
translate C BlackClearAdvantage {Black has a clear advantage} ;# ***
translate C WhiteSlightAdvantage {White has a slight advantage} ;# ***
translate C BlackSlightAdvantage {Black has a slight advantage} ;# ***
translate C Equality {Equality} ;# ***
translate C Unclear {Unclear} ;# ***
translate C Diagram {Diagram} ;# ***

# Board search:
translate C BoardSearch {Hledat pozici}
translate C FilterOperation {Operace s aktuálním filtrem:}
translate C FilterAnd {A (Omezit filtr)}
translate C FilterOr {NEBO (Pøidat k filtru)}
translate C FilterIgnore {IGNOROVAT (Ignoruj filtr)}
translate C SearchType {Typ hledání:}
translate C SearchBoardExact {Pøesná pozice (v¹echny figury na stejných polích)}
translate C SearchBoardPawns {Pì¹ci (tentý¾ materiál, v¹ichni pì¹ci na stejných polích)}
translate C SearchBoardFiles {Sloupce (tentý¾ materiál, v¹ichni pì¹ci na stejných sloupcích)}
translate C SearchBoardAny {Jakákoliv (tentý¾ materiál, pì¹ci a figury kdekoliv)}
translate C LookInVars {Dívat se do variant}

# Material search:
translate C MaterialSearch {Hledat materiál}
translate C Material {Materiál}
translate C Patterns {Vzory}
translate C Zero {Nic}
translate C Any {Cokoliv}
translate C CurrentBoard {Aktuální pozice}
translate C CommonEndings {Typické koncovky}
translate C CommonPatterns {Typické vzory}
translate C MaterialDiff {Rozdíl v materiálu}
translate C squares {pole}
translate C SameColor {Stejnobarevné}
translate C OppColor {Nestejnobarevné}
translate C Either {Obojí}
translate C MoveNumberRange {Rozsah tahù}
translate C MatchForAtLeast {Shoda pro minimálnì}
translate C HalfMoves {pùltahù}

# Common endings in material search:
translate C EndingPawns {Pawn endings} ;# ***
translate C EndingRookVsPawns {Rook vs. Pawn(s)} ;# ***
translate C EndingRookPawnVsRook {Rook and 1 Pawn vs. Rook} ;# ***
translate C EndingRookPawnsVsRook {Rook and Pawn(s) vs. Rook} ;# ***
translate C EndingRooks {Rook vs. Rook endings} ;# ***
translate C EndingRooksPassedA {Rook vs. Rook endings with a passed a-pawn} ;# ***
translate C EndingRooksDouble {Double Rook endings} ;# ***
translate C EndingBishops {Bishop vs. Bishop endings} ;# ***
translate C EndingBishopVsKnight {Bishop vs. Knight endings} ;# ***
translate C EndingKnights {Knight vs. Knight endings} ;# ***
translate C EndingQueens {Queen vs. Queen endings} ;# ***
translate C EndingQueenPawnVsQueen {Queen and 1 Pawn vs. Queen} ;# ***
translate C BishopPairVsKnightPair {Two Bishops vs. Two Knights middlegame} ;# ***

# Common patterns in material search:
translate C PatternWhiteIQP {White IQP} ;# ***
translate C PatternWhiteIQPBreakE6 {White IQP: d4-d5 break vs. e6} ;# ***
translate C PatternWhiteIQPBreakC6 {White IQP: d4-d5 break vs. c6} ;# ***
translate C PatternBlackIQP {Black IQP} ;# ***
translate C PatternWhiteBlackIQP {White IQP vs. Black IQP} ;# ***
translate C PatternCoupleC3D4 {White c3+d4 Isolated Pawn Couple} ;# ***
translate C PatternHangingC5D5 {Black Hanging Pawns on c5 and d5} ;# ***
translate C PatternMaroczy {Maroczy Center (with Pawns on c4 and e4)} ;# ***
translate C PatternRookSacC3 {Rook Sacrifice on c3} ;# ***
translate C PatternKc1Kg8 {O-O-O vs. O-O (Kc1 vs. Kg8)} ;# ***
translate C PatternKg1Kc8 {O-O vs. O-O-O (Kg1 vs. Kc8)} ;# ***
translate C PatternLightFian {Light-Square Fianchettos (Bishop-g2 vs. Bishop-b7)} ;# ***
translate C PatternDarkFian {Dark-Square Fianchettos (Bishop-b2 vs. Bishop-g7)} ;# ***
translate C PatternFourFian {Four Fianchettos (Bishops on b2,g2,b7,g7)} ;# ***

# Game saving:
translate C Today {Dnes}
translate C ClassifyGame {Klasifikovat partii}

# Setup position:
translate C EmptyBoard {Vyprázdnit ¹achovnici}
translate C InitialBoard {Výchozí pozice}
translate C SideToMove {Na tahu je}
translate C MoveNumber {Èíslo tahu}
translate C Castling {Ro¹áda}
translate C EnPassantFile {En Passant sloupec}
translate C ClearFen {Vyèistit FEN}
translate C PasteFen {Vlo¾it FEN}
# ====== TODO To be translated ======
translate C SaveAndContinue {Save and continue}
# ====== TODO To be translated ======
translate C DiscardChangesAndContinue {Discard changes\nand continue}
# ====== TODO To be translated ======
translate C GoBack {Go back}

# Replace move dialog:
translate C ReplaceMove {Nahradit tah}
translate C AddNewVar {Pøidat novou variantu}
# ====== TODO To be translated ======
translate C NewMainLine {New Main Line}
translate C ReplaceMoveMessage {Zde ji¾ existuje tah.

Mù¾ete ho nahradit, a zru¹it tak i v¹echny následující tahy, nebo mù¾ete vá¹ tah pøidat jako novou variantu.

(Zobrazení této zprávy mù¾ete v budoucnu potlaèit pøepnutím volby "Ptát se pøed nahrazením tahù" v menu Volby:Tahy.)}

# Make database read-only dialog:
translate C ReadOnlyDialog {Pokud databázi nastavíte jako jen ke ètení, nebudou povoleny ¾ádné zmìny.
®ádné partie nebude mo¾no ulo¾it ani pøepsat a ¾ádný mazací pøíznak nebude mo¾no zmìnit.
V¹echny výsledky operace øazení èi ECO klasifikace budou pouze doèasné.

Databázi mù¾ete uèinit opìt zapisovatelnou pomocí jejího zavøení a opìtovného otevøení.

Pøejete si skuteènì nastavit tuto databázi jako jen ke ètení?}

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
translate C ImportHelp2 {Jakékoli chyby pøi importu partie budou zobrazeny zde.}
# ====== TODO To be translated ======
translate C OverwriteExistingMoves {Overwrite existing moves ?}

# ECO Browser:
translate C ECOAllSections {v¹echny ECO sekce}
translate C ECOSection {ECO sekce}
translate C ECOSummary {Souhrn pro}
translate C ECOFrequency {Frekvence subkódù pro}

# Opening Report:
translate C OprepTitle {Profil zahájení}
translate C OprepReport {Profil}
translate C OprepGenerated {Generován}
translate C OprepStatsHist {Statistika a historie}
translate C OprepStats {Statistika}
translate C OprepStatAll {V¹echny partie profilu}
translate C OprepStatBoth {Oba ratingovaní}
translate C OprepStatSince {Od}
translate C OprepOldest {Nejstar¹í partie}
translate C OprepNewest {Nejnovìj¹í partie}
translate C OprepPopular {Stávající popularita}
translate C OprepFreqAll {Frekvence za v¹echny roky: }
translate C OprepFreq1   {Bìhem posledního roku:     }
translate C OprepFreq5   {Bìhem posledních 5 let:    }
translate C OprepFreq10  {Bìhem posledních 10 let:   }
translate C OprepEvery {jednou z %u partií}
translate C OprepUp {více o %u%s v porovnání se v¹emi roky}
translate C OprepDown {ménì o %u%s v porovnání se v¹emi roky}
translate C OprepSame {¾ádná zmìna pøi porovnání se v¹emi roky}
translate C OprepMostFrequent {Nejèastìj¹í hráèi}
translate C OprepMostFrequentOpponents {Nejèastìj¹í soupeøi}
translate C OprepRatingsPerf {Ratingy a performance}
translate C OprepAvgPerf {Prùmìrné ratingy a performance}
translate C OprepWRating {Rating bílý}
translate C OprepBRating {Rating èerný}
translate C OprepWPerf {Performance bílý}
translate C OprepBPerf {Performance èerný}
translate C OprepHighRating {Partie s nejvy¹¹ím prùmìrným ratingem}
translate C OprepTrends {Výsledkový trend}
translate C OprepResults {Délka partií a frekvence}
translate C OprepLength {Délka partií}
translate C OprepFrequency {Frekvence}
translate C OprepWWins {Výhry bílý: }
translate C OprepBWins {Výhry èerný: }
translate C OprepDraws {Remízy:      }
translate C OprepWholeDB {celá databáze}
translate C OprepShortest {Nejkrat¹í výhry}
translate C OprepMovesThemes {Tahy a témata}
translate C OprepMoveOrders {Posloupnosti tahù vedoucí k profilované pozici}
translate C OprepMoveOrdersOne \
  {Nalezena pouze jedna posloupnost tahù vedoucích k této pozici:}
translate C OprepMoveOrdersAll \
  {Nalezeno %u posloupností tahù vedoucích k této pozici:}
translate C OprepMoveOrdersMany \
  {Nalezeno %u posloupností tahù vedoucích k této pozici. Prvních %u jsou:}
translate C OprepMovesFrom {Tahy z profilované pozice}
translate C OprepMostFrequentEcoCodes {Nejèastìj¹í ECO kódy}
translate C OprepThemes {Pozièní témata}
translate C OprepThemeDescription {Frekvence témat v prvních %u tazích ka¾dé partie}
translate C OprepThemeSameCastling {Ro¹ády na stejnou stranu}
translate C OprepThemeOppCastling {Ro¹ády na rùzné strany}
translate C OprepThemeNoCastling {Obì strany bez ro¹ády}
translate C OprepThemeKPawnStorm {Pì¹cový útok na královském køídle}
translate C OprepThemeQueenswap {Vymìnìné dámy}
translate C OprepThemeWIQP {Bílý izolovaný dámský pì¹ec}
translate C OprepThemeBIQP {Èerný izolovaný dámský pì¹ec}
translate C OprepThemeWP567 {Bílý pì¹ec na 5., 6. nebo 7. øadì}
translate C OprepThemeBP234 {Èerný pì¹ec na 2., 3. nebo 4. øadì}
translate C OprepThemeOpenCDE {Otevøený sloupec C, D nebo E}
translate C OprepTheme1BishopPair {Jedna strana má dvojici støelcù}
translate C OprepEndgames {Koncovky}
translate C OprepReportGames {Profilované partie}
translate C OprepAllGames {V¹echny partie}
translate C OprepEndClass {Materiálu na konci ka¾dé partie}
translate C OprepTheoryTable {Tabulka teorie}
translate C OprepTableComment {Generováno z %u partií s nejvy¹¹ím prùmìrným ratingem.}
translate C OprepExtraMoves {Extra poznámkové tahy v tabulce teorie}
translate C OprepMaxGames {Maximum tahù v tabulce teorie}
translate C OprepViewHTML {Zobrazit HTML}
translate C OprepViewLaTeX {Zobrazit LaTeX}

# Player Report:
translate C PReportTitle {Profil hráèe}
translate C PReportColorWhite {bílými figurami}
translate C PReportColorBlack {èernými figurami}
translate C PReportMoves {po %s}
translate C PReportOpenings {Zahájení}
translate C PReportClipbase {Vyprázdnit schránku a zkopírovat do ní odpovídající partie}

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
translate C TwinsNote {Aby byly dvì partie vyhodnoceny jako zdvojené, musí být hrány tými¾ dvìma hráèi a dále musí splòovat kritéria, která nastavíte ní¾e. Pokud jsou nalezeny zdvojené partie, pak je krat¹í z nich vymazána. Rada: je vhodné provést pøed vymazáním zdvojených partií kontrolu pravopisu, nebo» to zdokonalí detekci zdvojených partií.}
translate C TwinsCriteria {Kritéria: Zdvojené partie musí mít...}
translate C TwinsWhich {Jaké partie prozkoumat}
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
translate C TwinsUndelete {Obnovit nejprve v¹echny partie?}
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
translate C ClassifyWhich {ECO klasifikace kterých partií}
translate C ClassifyAll {V¹echny partie (pøepsat staré ECO kódy)}
translate C ClassifyYear {V¹echny partie hrané za poslední rok}
translate C ClassifyMonth {V¹echny partie hrané za poslední mìsíc}
translate C ClassifyNew {Jen partie, které jsou zatím bez ECO kódu}
translate C ClassifyCodes {Pou¾ít tyto ECO kódy}
translate C ClassifyBasic {Jen základní kódy ("B12", ...)}
translate C ClassifyExtended {Roz¹íøení Scidu  ("B12j", ...)}

# Compaction:
translate C NameFile {Jmenný soubor}
translate C GameFile {Partiový soubor}
translate C Names {Jména}
translate C Unused {Nepou¾ito}
translate C SizeKb {Velikost (kb)}
translate C CurrentState {Aktuální stav}
translate C AfterCompaction {Po kompaktování}
translate C CompactNames {Kompaktovat jmenný soubor}
translate C CompactGames {Kompaktovat partiový soubor}
# ====== TODO To be translated ======
translate C NoUnusedNames "There are no unused names, so the name file is already fully compacted."
# ====== TODO To be translated ======
translate C NoUnusedGames "The game file is already fully compacted."
# ====== TODO To be translated ======
translate C NameFileCompacted {The name file for the database "[file tail [sc_base filename]]" was compacted.}
# ====== TODO To be translated ======
translate C GameFileCompacted {The game file for the database "[file tail [sc_base filename]]" was compacted.}

# Sorting:
translate C SortCriteria {Kritéria}
translate C AddCriteria {Pøidat kritéria}
translate C CommonSorts {Bì¾ná øazení}
translate C Sort {Setøídit}

# Exporting:
translate C AddToExistingFile {Pøidat partie do existujícího souboru?}
translate C ExportComments {Exportovat komentáøe?}
translate C ExportVariations {Exportovat varianty?}
translate C IndentComments {Odsazovat komentáøe?}
translate C IndentVariations {Odsazovat varianty?}
translate C ExportColumnStyle {Sloupcový styl (jeden tah na øádek)?}
translate C ExportSymbolStyle {Styl pro symbolické anotace:}
translate C ExportStripMarks {Odstranit kódové znaèky polí/¹ipek z komentáøù?}

# Goto game/move dialogs:
translate C LoadGameNumber {Vlo¾te èíslo partie:}
translate C GotoMoveNumber {Pøejít na tah èíslo:}

# Copy games dialog:
translate C CopyGames {Kopírovat partie}
translate C CopyConfirm {
 Skuteènì chcete kopírovat
 [::utils::thousands $nGamesToCopy] filtrovaných partií
 z databáze "$fromName"
 do databáze "$targetName"?
}
translate C CopyErr {Nelze zkopírovat partie}
translate C CopyErrSource {zdrojová databáze}
translate C CopyErrTarget {cílová databáze}
translate C CopyErrNoGames {nemá ¾ádné partie ve filtru}
translate C CopyErrReadOnly {je pouze ke ètení}
translate C CopyErrNotOpen {není otevøena}

# Colors:
translate C LightSquares {Bílá pole}
translate C DarkSquares {Èerná pole}
translate C SelectedSquares {Vybraná pole}
translate C SuggestedSquares {Pole navrhovaných tahù}
translate C WhitePieces {Bílé figury}
translate C BlackPieces {Èerné figury}
translate C WhiteBorder {Obrys bílých figur}
translate C BlackBorder {Obrys èerných figur}

# Novelty window:
translate C FindNovelty {Hledat novinku}
translate C Novelty {Novinka}
translate C NoveltyInterrupt {Hledání novinky pøeru¹eno}
translate C NoveltyNone {V této partii nebyla nalezena ¾ádná novinka}
translate C NoveltyHelp {
Scid bude hledat první tah aktuální partie, který dosáhne pozice, která se nevyskytla ve vybrané databázi ani v knihovnì zahájení ECO.
}

# Sounds configuration:
translate C SoundsFolder {Sound Files Folder} ;# ***
translate C SoundsFolderHelp {The folder should contain the files King.wav, a.wav, 1.wav, etc} ;# ***
translate C SoundsAnnounceOptions {Move Announcement Options} ;# ***
translate C SoundsAnnounceNew {Announce new moves as they are made} ;# ***
translate C SoundsAnnounceForward {Announce moves when moving forward one move} ;# ***
translate C SoundsAnnounceBack {Announce when retracting or moving back one move} ;# ***

# Upgrading databases:
translate C Upgrading {Upgrade}
translate C ConfirmOpenNew {
Toto je starý formát (Scid 2) databáze, jen¾ není mo¾no otevøít ve Scidu 3. Verze s novým formátem (Scid 3) pøitom ji¾ byla vytvoøena.

Chcete otevøít verzi s novým formátem datábáze?
}
translate C ConfirmUpgrade {
Toto je starý formát (Scid 2) databáze. K otevøení ve Scidu 3 je nutno databázi nejprve zkonvertovat do nového formátu.

Upgrade vytvoøí novou verzi databáze; originální soubory se nebudou ani editovat, ani mazat.

Tento úkon mù¾e zabrat trochu èasu, ale je tøeba jej provést pouze jednou. Mù¾ete ho pøeru¹it, pokud bude trvat pøíli¹ dlouho.

Chcete tuto databázi upgradovat nyní?
}

# Recent files options:
translate C RecentFilesMenu {Poèet nedávných souborù v menu Soubor}
translate C RecentFilesExtra {Poèet nedávných souborù v extra podmenu}

# My Player Names options:
translate C MyPlayerNamesDescription {
Otevøe seznam se jmény preferovaných hráèù, ka¾dé jméno na jeden øádek. Zástupné znaky (tj. "?" pro jakýkoliv jeden znak, "*" pro jakoukoliv sekvenci znakù) jsou povoleny.

V¾dy, kdy¾ se natáhne partie hráèe uvedeného v seznamu, ¹achovnice v hlavním oknì se otoèí, jestli¾e je to nutné k zobrazení partie z perspektivy tohoto hráèe.
}
# ====== TODO To be translated ======
translate C showblunderexists {show blunder exists}
# ====== TODO To be translated ======
translate C showblundervalue {show blunder value}
# ====== TODO To be translated ======
translate C showscore {show score}
# ====== TODO To be translated ======
translate C coachgame {coach game}
# ====== TODO To be translated ======
translate C configurecoachgame {configure coach game}
# ====== TODO To be translated ======
translate C configuregame {Game configuration}
# ====== TODO To be translated ======
translate C Phalanxengine {Phalanx engine}
# ====== TODO To be translated ======
translate C Coachengine {Coach engine}
# ====== TODO To be translated ======
translate C difficulty {difficulty}
# ====== TODO To be translated ======
translate C hard {hard}
# ====== TODO To be translated ======
translate C easy {easy}
# ====== TODO To be translated ======
translate C Playwith {Play with}
# ====== TODO To be translated ======
translate C white {white}
# ====== TODO To be translated ======
translate C black {black}
# ====== TODO To be translated ======
translate C both {both}
# ====== TODO To be translated ======
translate C Play {Play}
# ====== TODO To be translated ======
translate C Noblunder {No blunder}
# ====== TODO To be translated ======
translate C blunder {blunder}
# ====== TODO To be translated ======
translate C Noinfo {-- No info --}
# ====== TODO To be translated ======
translate C PhalanxOrTogaMissing {Phalanx or Toga not found}
# ====== TODO To be translated ======
# ====== TODO To be translated ======
# ====== TODO To be translated ======
translate C moveblunderthreshold {move is a blunder if loss is greater than}
# ====== TODO To be translated ======
translate C limitanalysis {limit engine analysis time}
# ====== TODO To be translated ======
translate C seconds {seconds}
# ====== TODO To be translated ======
translate C Abort {Abort}
# ====== TODO To be translated ======
translate C Resume {Resume}
# ====== TODO To be translated ======
translate C OutOfOpening {Out of opening}
# ====== TODO To be translated ======
translate C NotFollowedLine {You did not follow the line}
# ====== TODO To be translated ======
translate C DoYouWantContinue {Do you want yo continue ?}
# ====== TODO To be translated ======
translate C CoachIsWatching {Coach is watching}
# ====== TODO To be translated ======
translate C Ponder {Permanent thinking}
# ====== TODO To be translated ======
translate C LimitELO {Limit ELO strength}
# ====== TODO To be translated ======
translate C DubiousMovePlayedTakeBack {Dubious move played, do you want to take back ?}
# ====== TODO To be translated ======
translate C WeakMovePlayedTakeBack {Weak move played, do you want to take back ?}
# ====== TODO To be translated ======
translate C BadMovePlayedTakeBack {Bad move played, do you want to take back ?}
# ====== TODO To be translated ======
translate C Iresign {I resign}
# ====== TODO To be translated ======
translate C yourmoveisnotgood {your move is not good}
# ====== TODO To be translated ======
translate C EndOfVar {End of variation}
# ====== TODO To be translated ======
translate C Openingtrainer {Opening trainer}
# ====== TODO To be translated ======
translate C DisplayCM {Display candidate moves}
# ====== TODO To be translated ======
translate C DisplayCMValue {Display candidate moves value}
# ====== TODO To be translated ======
translate C DisplayOpeningStats {Show statistics}
# ====== TODO To be translated ======
translate C ShowReport {Show report}
# ====== TODO To be translated ======
translate C NumberOfGoodMovesPlayed {good moves played}
# ====== TODO To be translated ======
translate C NumberOfDubiousMovesPlayed {dubious moves played}
# ====== TODO To be translated ======
translate C NumberOfMovesPlayedNotInRepertoire {moves played not in repertoire}
# ====== TODO To be translated ======
translate C NumberOfTimesPositionEncountered {times position encountered}
# ====== TODO To be translated ======
translate C PlayerBestMove  {Allow only best moves}
# ====== TODO To be translated ======
translate C OpponentBestMove {Opponent plays best moves}
# ====== TODO To be translated ======
translate C OnlyFlaggedLines {Only flagged lines}
# ====== TODO To be translated ======
translate C resetStats {Reset statistics}
# ====== TODO To be translated ======
translate C Repertoiretrainingconfiguration {Repertoire training configuration}
# ====== TODO To be translated ======
translate C Loadingrepertoire {Loading repertoire}
# ====== TODO To be translated ======
translate C Movesloaded {Moves loaded}
# ====== TODO To be translated ======
translate C Repertoirenotfound {Repertoire not found}
# ====== TODO To be translated ======
translate C Openfirstrepertoirewithtype {Open first a repertoire database with icon/type set to the right side}
# ====== TODO To be translated ======
translate C Movenotinrepertoire {Move not in repertoire}
# ====== TODO To be translated ======
translate C PositionsInRepertoire {Positions in repertoire}
# ====== TODO To be translated ======
translate C PositionsNotPlayed {Positions not played}
# ====== TODO To be translated ======
translate C PositionsPlayed {Positions played}
# ====== TODO To be translated ======
translate C Success {Success}
# ====== TODO To be translated ======
translate C DubiousMoves {Dubious moves}
# ====== TODO To be translated ======
translate C OutOfRepertoire {OutOfRepertoire}
# ====== TODO To be translated ======
# ====== TODO To be translated ======
# ====== TODO To be translated ======
# ====== TODO To be translated ======
translate C ConfigureTactics {Configure tactics}
# ====== TODO To be translated ======
translate C ResetScores {Reset scores}
# ====== TODO To be translated ======
translate C LoadingBase {Loading base}
# ====== TODO To be translated ======
translate C Tactics {Tactics}
# ====== TODO To be translated ======
translate C ShowSolution {Show solution}
# ====== TODO To be translated ======
translate C Next {Next}
# ====== TODO To be translated ======
translate C ResettingScore {Resetting score}
# ====== TODO To be translated ======
translate C LoadingGame {Loading game}
# ====== TODO To be translated ======
translate C MateFound {Mate found}
# ====== TODO To be translated ======
translate C BestSolutionNotFound {Best solution NOT found !}
# ====== TODO To be translated ======
translate C MateNotFound {Mate not found}
# ====== TODO To be translated ======
translate C ShorterMateExists {Shorter mate exists}
# ====== TODO To be translated ======
translate C ScorePlayed {Score played}
# ====== TODO To be translated ======
translate C Expected {expected}
# ====== TODO To be translated ======
translate C ChooseTrainingBase {Choose training base}
# ====== TODO To be translated ======
translate C Thinking {Thinking}
# ====== TODO To be translated ======
translate C AnalyzeDone {Analyze done}
# ====== TODO To be translated ======
translate C WinWonGame {Win won game}
# ====== TODO To be translated ======
translate C Lines {Lines}
# ====== TODO To be translated ======
translate C ConfigureUCIengine {Configure UCI engine}
# ====== TODO To be translated ======
translate C SpecificOpening {Specific opening}
# ====== TODO To be translated ======
translate C StartNewGame {Start new game}
# ====== TODO To be translated ======
translate C FixedLevel {Fixed level}
# ====== TODO To be translated ======
translate C Opening {Opening}
# ====== TODO To be translated ======
translate C RandomLevel {Random level}
# ====== TODO To be translated ======
translate C StartFromCurrentPosition {Start from current position}
# ====== TODO To be translated ======
translate C FixedDepth {Fixed depth}
# ====== TODO To be translated ======
translate C Nodes {Nodes} 
# ====== TODO To be translated ======
translate C Depth {Depth}
# ====== TODO To be translated ======
translate C Time {Time} 
# ====== TODO To be translated ======
translate C SecondsPerMove {Seconds per move}
# ====== TODO To be translated ======
translate C Engine {Engine}
# ====== TODO To be translated ======
translate C TimeMode {Time mode}
# ====== TODO To be translated ======
translate C TimeBonus {Time + bonus}
# ====== TODO To be translated ======
# ====== TODO To be translated ======
translate C TimeMin {min}
# ====== TODO To be translated ======
translate C TimeSec {sec}
# ====== TODO To be translated ======
# ====== TODO To be translated ======
# ====== TODO To be translated ======
translate C AllExercisesDone {All exercises done}
# ====== TODO To be translated ======
translate C MoveOutOfBook {Move out of book}
# ====== TODO To be translated ======
translate C LastBookMove {Last book move}
# ====== TODO To be translated ======
translate C AnnotateSeveralGames {Annotate several games\nfrom current to :}
# ====== TODO To be translated ======
translate C FindOpeningErrors {Find opening errors}
# ====== TODO To be translated ======
translate C MarkTacticalExercises {Mark tactical exercises}
# ====== TODO To be translated ======
translate C UseBook {Use book}
# ====== TODO To be translated ======
translate C MultiPV {Multiple variations}
# ====== TODO To be translated ======
translate C Hash {Hash memory}
# ====== TODO To be translated ======
translate C OwnBook {Use engine book}
# ====== TODO To be translated ======
translate C BookFile {Opening book}
# ====== TODO To be translated ======
translate C AnnotateVariations {Annotate variations}
# ====== TODO To be translated ======
translate C ShortAnnotations {Short annotations}
# ====== TODO To be translated ======
translate C addAnnotatorTag {Add annotator tag}
# ====== TODO To be translated ======
translate C AddScoreToShortAnnotations {Add score to short annotations}
# ====== TODO To be translated ======
translate C Export {Export}
# ====== TODO To be translated ======
translate C BookPartiallyLoaded {Book partially loaded}
# ====== TODO To be translated ======
translate C Calvar {Calculation of variations}
# ====== TODO To be translated ======
translate C ConfigureCalvar {Configuration}
# ====== TODO To be translated ======
# ====== TODO To be translated ======
translate C Reti {Reti}
# ====== TODO To be translated ======
translate C English {English}
# ====== TODO To be translated ======
translate C d4Nf6Miscellaneous {1.d4 Nf6 Miscellaneous}
# ====== TODO To be translated ======
translate C Trompowsky {Trompowsky}
# ====== TODO To be translated ======
translate C Budapest {Budapest}
# ====== TODO To be translated ======
translate C OldIndian {Old Indian}
# ====== TODO To be translated ======
translate C BenkoGambit {Benko Gambit}
# ====== TODO To be translated ======
translate C ModernBenoni {Modern Benoni}
# ====== TODO To be translated ======
translate C DutchDefence {Dutch Defence}
# ====== TODO To be translated ======
translate C Scandinavian {Scandinavian}
# ====== TODO To be translated ======
translate C AlekhineDefence {Alekhine Defence}
# ====== TODO To be translated ======
translate C Pirc {Pirc}
# ====== TODO To be translated ======
translate C CaroKann {Caro-Kann}
# ====== TODO To be translated ======
translate C CaroKannAdvance {Caro-Kann Advance}
# ====== TODO To be translated ======
translate C Sicilian {Sicilian}
# ====== TODO To be translated ======
translate C SicilianAlapin {Sicilian Alapin}
# ====== TODO To be translated ======
translate C SicilianClosed {Sicilian Closed}
# ====== TODO To be translated ======
translate C SicilianRauzer {Sicilian Rauzer}
# ====== TODO To be translated ======
translate C SicilianDragon {Sicilian Dragon}
# ====== TODO To be translated ======
translate C SicilianScheveningen {Sicilian Scheveningen}
# ====== TODO To be translated ======
translate C SicilianNajdorf {Sicilian Najdorf}
# ====== TODO To be translated ======
translate C OpenGame {Open Game}
# ====== TODO To be translated ======
translate C Vienna {Vienna}
# ====== TODO To be translated ======
translate C KingsGambit {King's Gambit}
# ====== TODO To be translated ======
translate C RussianGame {Russian Game}
# ====== TODO To be translated ======
translate C ItalianTwoKnights {Italian/Two Knights}
# ====== TODO To be translated ======
translate C Spanish {Spanish}
# ====== TODO To be translated ======
translate C SpanishExchange {Spanish Exchange}
# ====== TODO To be translated ======
translate C SpanishOpen {Spanish Open}
# ====== TODO To be translated ======
translate C SpanishClosed {Spanish Closed}
# ====== TODO To be translated ======
translate C FrenchDefence {French Defence}
# ====== TODO To be translated ======
translate C FrenchAdvance {French Advance}
# ====== TODO To be translated ======
translate C FrenchTarrasch {French Tarrasch}
# ====== TODO To be translated ======
translate C FrenchWinawer {French Winawer}
# ====== TODO To be translated ======
translate C FrenchExchange {French Exchange}
# ====== TODO To be translated ======
translate C QueensPawn {Queen's Pawn}
# ====== TODO To be translated ======
translate C Slav {Slav}
# ====== TODO To be translated ======
translate C QGA {QGA}
# ====== TODO To be translated ======
translate C QGD {QGD}
# ====== TODO To be translated ======
translate C QGDExchange {QGD Exchange}
# ====== TODO To be translated ======
translate C SemiSlav {Semi-Slav}
# ====== TODO To be translated ======
translate C QGDwithBg5 {QGD with Bg5}
# ====== TODO To be translated ======
translate C QGDOrthodox {QGD Orthodox}
# ====== TODO To be translated ======
translate C Grunfeld {Grünfeld}
# ====== TODO To be translated ======
translate C GrunfeldExchange {Grünfeld Exchange}
# ====== TODO To be translated ======
translate C GrunfeldRussian {Grünfeld Russian}
# ====== TODO To be translated ======
translate C Catalan {Catalan}
# ====== TODO To be translated ======
translate C CatalanOpen {Catalan Open}
# ====== TODO To be translated ======
translate C CatalanClosed {Catalan Closed}
# ====== TODO To be translated ======
translate C QueensIndian {Queen's Indian}
# ====== TODO To be translated ======
translate C NimzoIndian {Nimzo-Indian}
# ====== TODO To be translated ======
translate C NimzoIndianClassical {Nimzo-Indian Classical}
# ====== TODO To be translated ======
translate C NimzoIndianRubinstein {Nimzo-Indian Rubinstein}
# ====== TODO To be translated ======
translate C KingsIndian {King's Indian}
# ====== TODO To be translated ======
translate C KingsIndianSamisch {King's Indian Sämisch}
# ====== TODO To be translated ======
translate C KingsIndianMainLine {King's Indian Main Line}
# ====== TODO To be translated ======
translate C CCDlgConfigureWindowTitle {Configure Correspondence Chess}
# ====== TODO To be translated ======
translate C CCDlgCGeneraloptions {General Options}
# ====== TODO To be translated ======
translate C CCDlgDefaultDB {Default Database:}
# ====== TODO To be translated ======
translate C CCDlgInbox {Inbox (path):}
# ====== TODO To be translated ======
translate C CCDlgOutbox {Outbox (path):}
# ====== TODO To be translated ======
translate C CCDlgXfcc {Xfcc Configuration:}
# ====== TODO To be translated ======
translate C CCDlgExternalProtocol {External Protocol Handler (e.g. Xfcc)}
# ====== TODO To be translated ======
translate C CCDlgFetchTool {Fetch Tool:}
# ====== TODO To be translated ======
translate C CCDlgSendTool {Send Tool:}
# ====== TODO To be translated ======
translate C CCDlgEmailCommunication {eMail Communication}
# ====== TODO To be translated ======
translate C CCDlgMailPrg {Mail program:}
# ====== TODO To be translated ======
translate C CCDlgBCCAddr {(B)CC Address:}
# ====== TODO To be translated ======
translate C CCDlgMailerMode {Mode:}
# ====== TODO To be translated ======
translate C CCDlgThunderbirdEg {e.g. Thunderbird, Mozilla Mail, Icedove...}
# ====== TODO To be translated ======
translate C CCDlgMailUrlEg {e.g. Evolution}
# ====== TODO To be translated ======
translate C CCDlgClawsEg {e.g Sylpheed Claws}
# ====== TODO To be translated ======
translate C CCDlgmailxEg {e.g. mailx, mutt, nail...}
# ====== TODO To be translated ======
translate C CCDlgAttachementPar {Attachment parameter:}
# ====== TODO To be translated ======
translate C CCDlgInternalXfcc {Use internal Xfcc support}
# ====== TODO To be translated ======
translate C CCDlgSubjectPar {Subject parameter:}
# ====== TODO To be translated ======
translate C CCDlgStartEmail {Start new eMail game}
# ====== TODO To be translated ======
translate C CCDlgYourName {Your Name:}
# ====== TODO To be translated ======
translate C CCDlgYourMail {Your eMail Address:}
# ====== TODO To be translated ======
translate C CCDlgOpponentName {Opponents Name:}
# ====== TODO To be translated ======
translate C CCDlgOpponentMail {Opponents eMail Address:}
# ====== TODO To be translated ======
translate C CCDlgGameID {Game ID (unique):}
# ====== TODO To be translated ======
translate C CCDlgTitNoOutbox {Scid: Correspondence Chess Outbox}
# ====== TODO To be translated ======
translate C CCDlgTitNoInbox {Scid: Correspondence Chess Inbox}
# ====== TODO To be translated ======
translate C CCDlgTitNoGames {Scid: No Correspondence Chess Games}
# ====== TODO To be translated ======
translate C CCErrInboxDir {Correspondence Chess inbox directory:}
# ====== TODO To be translated ======
translate C CCErrOutboxDir {Correspondence Chess outbox directory:}
# ====== TODO To be translated ======
translate C CCErrDirNotUsable {does not exist or is not accessible!\nPlease check and correct the settings.}
# ====== TODO To be translated ======
translate C CCErrNoGames {does not contain any games!\nPlease fetch them first.}
# ====== TODO To be translated ======
translate C CCDlgTitNoCCDB {Scid: No Correspondence Database}
# ====== TODO To be translated ======
translate C CCErrNoCCDB {No Database of type 'Correspondence' is opened. Please open one before using correspondence chess functions.}
# ====== TODO To be translated ======
translate C CCFetchBtn {Fetch games from the server and process the Inbox}
# ====== TODO To be translated ======
translate C CCPrevBtn {Goto previous game}
# ====== TODO To be translated ======
translate C CCNextBtn {Goto next game}
# ====== TODO To be translated ======
translate C CCSendBtn {Send move}
# ====== TODO To be translated ======
translate C CCEmptyBtn {Empty In- and Outbox}
# ====== TODO To be translated ======
translate C CCHelpBtn {Help on icons and status indicators.\nFor general Help press F1!}
# ====== TODO To be translated ======
translate C CCDlgServerName {Server Name:}
# ====== TODO To be translated ======
translate C CCDlgLoginName  {Login Name:}
# ====== TODO To be translated ======
translate C CCDlgPassword   {Password:}
# ====== TODO To be translated ======
translate C CCDlgURL        {Xfcc-URL:}
# ====== TODO To be translated ======
translate C CCDlgRatingType {Rating Type:}
# ====== TODO To be translated ======
translate C ExtHWConfigConnection {Configure external hardware}
# ====== TODO To be translated ======
translate C ExtHWPort {Port}
# ====== TODO To be translated ======
translate C ExtHWEngineCmd {Engine command}
# ====== TODO To be translated ======
translate C ExtHWEngineParam {Engine parameter}
# ====== TODO To be translated ======
translate C ExtHWShowButton {Show button}
# ====== TODO To be translated ======
translate C ExtHWHardware {Hardware}
# ====== TODO To be translated ======
translate C ExtHWNovag {Novag Citrine}
# ====== TODO To be translated ======
translate C ExtHWInputEngine {Input Engine}
# ====== TODO To be translated ======
translate C ExtHWNoBoard {No board}
# ====== TODO To be translated ======
translate C IEConsole {Input Engine Console}
# ====== TODO To be translated ======
translate C IESending {Moves sent for}
# ====== TODO To be translated ======
translate C IESynchronise {Synchronise}
# ====== TODO To be translated ======
translate C IERotate  {Rotate}
# ====== TODO To be translated ======
translate C IEUnableToStart {Unable to start Input Engine:}
# ====== TODO To be translated ======
translate C DoneWithPosition {Done with position}
# ====== TODO To be translated ======
translate C Board {Board}
# ====== TODO To be translated ======
translate C showGameInfo {Show game info}
# ====== TODO To be translated ======
translate C autoResizeBoard {Automatic resize of board}
# ====== TODO To be translated ======
translate C DockTop {Move to top}
# ====== TODO To be translated ======
translate C DockBottom {Move to bottom}
# ====== TODO To be translated ======
translate C DockLeft {Move to left}
# ====== TODO To be translated ======
translate C DockRight {Move to right}
# ====== TODO To be translated ======
translate C Undock {Undock}
# ====== TODO To be translated ======
}


############################################################
#
# Czech help pages:


#############
### Contents:

set helpTitle(C,Contents) "Obsah"
set helpText(C,Contents) {<h1>Obsah nápovìdy Scidu</h1>

<h4>Start a v¹eobecná nápovìda</h4>
<ul>
<li><a Guide><b>Rychlý prùvodce</b> pou¾íváním Scidu</a> <red>(Ètìte
 nejprve)</red></li>
<li><a Hints><b>Rady</b> na zefektivnìní práce se Scidem</a></li>
<li><a MainWindow><b>Hlavní okno</b> Scidu</a></li>
<li><a Menus><b>Menu</b> Scidu</a> <red>(aktualizováno!)</red></li>
<li><a Moves>Zadávání <b>tahù</b></a></li>
<li><a Searches><b>Vyhledávání</b> Scidem</a></li>
<li><a Clipbase>Pou¾ití databáze <b>schránka</b></a></li>
<li><a Annotating><b>Anotace partií</b></a></li>
</ul>

<h4>Ostatní okna Scidu</h4>
<ul>
<li><a Analysis><b>Analytické</b> okno</a></li>
<li><a Comment>Okno <b>editoru komentáøù</b></a></li>
<li><a Crosstable>Okno <b>turnajové tabulky</b></a></li>
<li><a Switcher>Okno <b>výbìru databáze</b></a></li>
<li><a Email>Okno <b>emailového</b> mana¾era</a></li>
<li><a Finder>Okno <b>vyhledávaèe souborù</b></a></li>
<li><a GameList>Okno <b>seznamu partií</b></a></li>
<li><a Import>Okno <b>importu partií</b></a></li>
<li><a Reports><b>Profily</b></a> <red>(aktualizováno!)</red></li>
<li><a PGN>Okno <b>PGN</b> (text partie)</a></li>
<li><a PTracker><b>Stopaø figur</b></a></li>
<li><a PList>Okno <b>vyhledávaèe hráèù</b></a></li>
<li><a PInfo>Okno <b>informací o hráèi</b></a></li>
<li><a Repertoire>Okno <b>editoru repertoáru</b></a></li>
<li><a Tmt>Okno <b>vyhledávaèe turnajù</b></a></li>
<li><a Tree><b>Stromové</b> okno</a></li>
<li><a Graphs>Okno <b>grafù</b></a></li>
<li><a TB>Pou¾ití <b>tabulek koncovek</b></a>
 <red>(aktualizováno!)</red></li>
</ul>

<h4>Ostatní pomocné programy a informace</h4>
<ul>
<li><a Bookmarks><b>Zálo¾ky</b></a></li>
<li><a Cmdline>Volby z pøíkazového øádku</a></li>
<li><a Compact><b>Kompaktování</b> databáze</a></li>
<li><a Maintenance>Nástroje <b>údr¾by databáze</b></a></li>
<li><a ECO>Klasifikace zahájení <b>ECO</b></a></li>
<li><a EPD>Soubory <b>EPD</b></a></li>
<li><a Export><b>Export</b> partií do textových souborù</a>
 <red>(aktualizováno!)</red></li>
<li><a Flags><b>Pøíznaky</b> u partií</a></li>
<li><a LaTeX>Pou¾ití <b>LaTeXu</b> se Scidem</a></li>
<li><a Options><b>Volby</b> a preference</a> <red>(aktualizováno!)</red></li>
<li><a Sorting><b>Tøídìní</b> databáze</a></li>
<li><a Pgnscid><b>Pgnscid</b>: konverze souborù PGN</a></li>
<li><a NAGs>Standardní <b>NAG</b> numerická hodnocení</a></li>
<li><a Formats><b>Formát souborù</b> Scidu</a></li>
<li><a Author>Kontaktní informace</a></li>
</ul>

<p><footer>(Aktualizováno: Scid 3.5, Prosinec 2003)</footer></p>
}


###############
### Topic Index

set helpTitle(C,Index) "Index nápovìdy Scidu"
set helpText(C,Index) {<h1>Index nápovìdy Scidu</h1>

<h3>A</h3>
<ul>
<li><a Analysis>Analytické</a> okno</li>
<li><a Annotating>Anotace partií</a></li>
<li><a NAGs>Anotaèní symboly</a></li>
<li><a MainWindow Autoplay>Automatické pøehrávání</a></li>
<li><a Author>Autor, kontaktování</a></li>
</ul>

<h3>È</h3>
<ul>
<li><a Maintenance Cleaner>Èi¹tìní</a></li>
</ul>

<h3>D</h3>
<ul>
<li><a Compact>Databáze, kompaktování</a></li>
<li><a Formats>Databáze, formáty souborù</a></li>
<li><a Maintenance>Databáze, údr¾ba</a></li>
<li><a Sorting>Databáze, tøídìní</a></li>
<li><a Switcher>Databáze</a>, okno výbìru</li>
</ul>

<h3>E</h3>
<ul>
<li><a ECO Browser>ECO prohlí¾eè</a>, okno</li>
<li><a ECO Codes>ECO, systém kódù </a></li>
<li><a ECO>ECO, klasifikace zahájení </a></li>
<li><a Menus Edit>Editace, menu</a></li>
<li><a Email>Emailový mana¾er</a>, okno</li>
<li><a EPD>EPD soubory</a></li>
<li><a Export>Export partií do textových souborù</a></li>
</ul>

<h3>F</h3>
<ul>
<li><a Searches Filtr>Filtr</a></li>
<li><a Export>Filtr, exportování</a></li>
<li><a Graphs Filtr>Filtr, graf</a></li>
<li><a Options Fonts>Fonty</a></li>
</ul>

<h3>G</h3>
<ul>
<li><a Graphs>Graf, okna</a></li>
</ul>

<h3>H</h3>
<ul>
<li><a Searches Header>Hlavièka, vyhledávání</a></li>
<li><a MainWindow>Hlavní okno</a></li>
<li><a Menus Search>Hledat, menu</a></li>
<li><a PList>Hráè</a>, okno vyhledávaèe</li>
<li><a PInfo>Hráè</a>, okno informací</li>
<li><a Reports Player>Hráè</a>, okno profilu</li>
</ul>

<h3>I</h3>
<ul>
<li><a Import>Import</a>, okno</li>
</ul>

<h3>J</h3>
<ul>
<li><a Maintenance Editing>Jména, editace</a></li>
<li><a Maintenance Spellcheck>Jména, kontrola pravopisu</a></li>
</ul>

<h3>K</h3>
<ul>
<li><a Comment>Komentáøù</a>, okno editoru</li>
<li><a Compact>Kompaktování databáze</a></li>
<li><a Author>Kontaktní informace</a></li>
</ul>

<h3>L</h3>
<ul>
<li><a LaTeX>LaTeX</a>, výstupní formát</li>
</ul>

<h3>M</h3>
<ul>
<li><a Maintenance Twins>Mazání zdvojených partií</a></li>
<li><a Analysis List>Motory</a>, seznam</li>
<li><a Searches Material>Materiál/vzor, vyhledávání</a></li>
<li><a Menus>Menu</a></li>
</ul>

<h3>N</h3>
<ul>
<li><a Menus Help>Nápovìda, menu</a></li>
<li><a Menus Tools>Nástroje, menu</a></li>
<li><a Tree Best>Nejlep¹í partie</a>, okno</li>
<li><a NAGs>NAG anotaèní hodnoty</a></li>
<li><a Annotating Null>Nulové tahy</a></li>
</ul>

<h3>O</h3>
<ul>
<li><a Contents>Obsah</a></li>
<li><a Menus Windows>Okna, menu</a></li>
</ul>

<h3>P</h3>
<ul>
<li><a Menus Game>Partie, menu</a></li>
<li><a GameList>Partie</a>, okno seznamu</li>
<li><a Flags>Partie, pøíznaky</a></li>
<li><a Searches Board>Pozice, vyhledávání</a></li>
<li><a Maintenance Spellcheck>Pravopis jmen, kontrola</a></li>
<li><a GameList Browsing>Prohlí¾ení partií</a></li>
<li><a Cmdline>Pøíkazový øádek, volby</a></li>
<li><a GameList Browsing>Pøipojování partií</a></li>
<li><a Flags>Pøíznaky</a></li>
<li><a PGN>PGN</a>, okno</li>
<li><a Pgnscid>Pgnscid</a></li>
</ul>

<h3>R</h3>
<ul>
<li><a Hints>Rady</a></li>
<li><a Guide>Rychlý prùvodce pou¾íváním Scidu</a></li>
<li><a Graphs Rating>Rating, graf</a></li>
<li><a Repertoire>Repertoár, editor</a></li>
</ul>

<h3>S</h3>
<ul>
<li><a Clipbase>Schránka</a></li>
<li><a Formats>Soubor, formáty</a></li>
<li><a Menus File>Soubor, menu</a></li>
<li><a Finder>Soubor, vyhledávaè</a></li>
<li><a PTracker>Stopaø figur</a>, okno</li>
<li><a Tree>Stromové okno</a></li>
</ul>

<h3>T</h3>
<ul>
<li><a TB>Tabulky koncovek</a></li>
<li><a Moves>Tahy, zadávání</a></li>
<li><a Sorting>Tøídìní databáze</a></li>
<li><a Crosstable>Turnajová tabulka</a>, okno</li>
<li><a Tmt>Turnaj, vyhledávaè</a></li>
</ul>

<h3>U</h3>
<ul>
<li><a Maintenance>Údr¾ba, nástroje</a></li>
</ul>

<h3>V</h3>
<ul>
<li><a Options>Volby</a></li>
<li><a Switcher>Výbìr databáze</a>, okno</li>
<li><a Searches Filter>Vyhledávací filtr</a></li>
<li><a Searches>Vyhledávání</a></li>
<li><a Annotating Vars>Varianty</a></li>
</ul>

<h3>Z</h3>
<ul>
<li><a Moves>Zadávání tahù</a></li>
<li><a ECO>Zahájení, klasifikace (ECO)</a></li>
<li><a Reports Opening>Zahájení</a>, okno profilu</a>
<li><a Repertoire>Zahájení, repertoáry</a></li>
<li><a Bookmarks>Zálo¾ky</a></li>
<li><a Maintenance Twins>Zdvojené (duplicitní) partie</a></li>
<li><a Moves Trial>Zku¹ební mód</a></li>
</ul>

<p><footer>(Aktualizováno: Scid 3.5, Únor 2003)</footer></p>
}


################
### Quick guide:

set helpTitle(C,Guide) "Rychlý prùvodce pou¾íváním Scidu"
set helpText(C,Guide) {<h1>Rychlý prùvodce pou¾íváním Scidu</h1>
<p>
Scid je ¹achová databázová aplikace; mù¾ete s ní prohlí¾et databáze ¹achových
partií, partie editovat a pou¾itím rùzných kritérií partie <a Searches>vyhledávat</a>.
</p>
<p>
Scid pou¾ívá svùj vlastní <a Formats>formát dat</a>, sestávající ze tøí souborù,
který je velmi kompaktní a rychlý, ale mù¾e být obousmìrnì konvertován mezi
standardním PGN (Portable Game Notation) formátem.
<a PGN>Okno PGN</a> Scidu zobrazuje zápis aktuální partie v PGN formátu.
</p>
<p>
Scid mù¾ete pou¾ít k pøidání partie do databáze, tahy lze zadávat klávesnicí i
my¹í. Pro dal¹í informace se podívejte na stránky nápovìdy o
<a Moves>zadávání tahù</a>.
</p>
<p>
Scid mù¾ete také pou¾ít jako prohlí¾eè <a PGN>PGN</a> souborù, buï vlo¾ením PGN
notace do okna <a Import>Importu</a> Scidu nebo otevøením PGN souboru ve Scidu.
Av¹ak PGN soubory nemohou být ve Scidu editovány (jsou otevøeny jen ke ètení),
jsou nároèné na pamì» a pomaleji se otevírají. Z tìchto dùvodù se doporuèuje
velké PGN soubory nejprve zkonvertovat do formátu Scidu pou¾itím pomocného
programu <a Pgnscid>pgnscid</a>.
</p>
<p>
<a MainWindow>Hlavní okno</a> Scidu (s grafickou ¹achovnicí) zobrazuje detaily
aktuální partie a databáze. Kdykoliv mù¾ete mít otevøeny a¾ ètyøi databáze
souèasnì (s <a Clipbase>databází schránka</a> pìt) a ka¾dá z nich bude mít svou
aktuální partii.
(Partie èíslo 0 indikuje zadávání partie, která není souèástí
aktuální databáze).
Mezi otevøenými databázemi lze pøepínat v
<a Menus File>menu Soubor</a>.
</p>
<p>
Pro více informací si prosím pøeètìte ostatní stránky nápovìdy v 
<a Index>indexu nápovìdy</a>.
</p>
<p>
Jestli¾e chcete kontaktovat autora Scidu, jdìte na stránku s
<a Author>kontaktními informacemi</a>.
</p>

<p><footer>(Aktualizováno: Scid 3.1, Prosinec 2001)</footer></p>
}


###############
### Hints page:

set helpTitle(C,Hints) "Rady k pou¾ívání"
set helpText(C,Hints) {<h1>Rady k pou¾ívání</h1>
<p>
Tato stránka obsahuje ve formì otázek a odpovìdí u¾iteèné rady, které vám
pomohou Scid lépe pou¾ívat. Jestli¾e s programem Scid teprve zaèínáte, pøeètìte
si prosím nejdøíve <a Guide>rychlého prùvodce</a>.
Vìt¹ina informací na této stránce je probrána detailnì na dal¹ích stránkách
nápovìdy, viz <a Index>index</a>.
Jestli¾e chcete pøispìt na tuto stánku nìjakou svojí u¾iteènou radou, po¹lete ji
<a  Author>autorovi Scidu</a>. </p>

<h4>Mohu spustit Scid pøímo se zvolenou databází?</h4>
<p>
Ano, na pøíkazový øádek staèí pøidat databáze, PGN soubory nebo
<a EPD>EPD soubory</a>. Napø.
<ul>
<li> <b>scid  mybase  games.pgn.gz</b> </li>
</ul>
otevøe databázi ve formátu Scidu <b>mybase</b> a rovnì¾ PGN soubor komprimovaný
Gzipem <b>games.pgn.gz</b>.
</p>

<h4>Existuje jednodu¹¹í mo¾nost jak zmìnit velikost ¹achovnice ne¾ pou¾itím menu
Volby?</h4>
<p>
Ano, pou¾ijte klávesovou zkratku <b>Control+Shift+©ipkaVlevo</b> pro zmen¹ení ¹achovnice
a <b>Control+Shift+©ipkaVpravo</b> pro zvìt¹ení.
</p>

<h4>Pøi tréninku si pøehrávám partii, a tím pádem nechci, aby Scid zobrazoval
následující tah v informaèní zónì partie pod ¹achovnicí. Je mo¾né ho
skrýt?</h4>
<p>
Následující tah lze skrýt tak, ¾e v informaèní zónì partie stisknìte
<b>pravé</b> tlaèítko my¹i a z menu, které se objeví, vyberete
<b>Skrýt následující tah</b>.
</p>

<h4>Jak mohu vidìt ECO kód zahájení pro aktuální pozici?</h4>
<p>
Jestli¾e byl nahrán klasifikaèní soubor ECO (<b>scid.eco</b>), ECO kód je
zobrazen na posledním øádku informaèní zóny, pod ¹achovnicí v
<a MainWindow>hlavním oknì</a>. <br>
Stránka nápovìdy <a ECO>ECO kódu</a> vysvìtluje, jak nahrát
klasifikaèní soubor ECO a ulo¾it nastavení tak, aby se nahrál  pøi ka¾dém
spu¹tìní Scidu. </p>

<h4>Zadávám partii a jsem okolo 30. tahu, ale najednou zjistím, ¾e 10. tah jsem
zadal ¹patnì. Jak ho mohu opravit, abych neztratil následující tahy?</h4>
<p>
Mù¾ete pou¾ít okno <a Import>importu</a>; pro dal¹í informace se podívejte na
stránku nápovìdy o <a Moves Mistakes>zadávání tahù</a>.
</p>

<h4>Jak zkopíruji partie z jedné databáze do druhé?</h4>
<p>
Pou¾ijte <a Switcher>okno výbìru databáze</a>; pøeta¾ením ze zdrojové databáze
do cílové databáze zkopírujete v¹echny partie z <a Searches Filter>filtru</a>
zdrojové databáze.
</p>

<h4>Kdykoliv kdy¾ zadávám tah, kde u¾ nìjaký existuje, objeví se dialogové okno
"Nahradit tah?". Jak tomu mohu zabránit?</h4>
<p>
Vypnìte volbu <b>Ptát se pøed nahrazením tahù</b> v menu
<menu>Volby: Tahy</menu>. Nebo si zvyknìte na vrácení tahu zpátky pou¾ívat
pravé tlaèítko my¹i, tak vlastnì dojde k odstranìní tahu z partie, je-li to její
poslední tah.
</p>

<h4>Jak zmìním v Oknì seznamu partií ¹íøku sloupcù?</h4>
<p>
Kliknìte levým nebo pravým tlaèítkem my¹i na ka¾dý titulek sloupce.
</p>

<h4>Jak mohu pou¾ít okno stromu s výbìrem partií, ne s celou databází?</h4>
<p>
Pou¾ijte <a Clipbase>databázi schránka</a>. Nastavte filtr databáze tak, aby
obsahoval partie, které chcete pou¾ít pro strom, a zkopírujte je pomocí okna
<a Switcher>výbìru databáze</a> do databáze schránka.  Pak v databázi schránka
otevøete okno stromu.
</p>

<h4>Pro velké databáze je strom pomalý. Jak ho urychlím?</h4>
<p>
Pro pro dal¹í pou¾ití údajù stromu èasto ukládejte cache stromu. Dal¹í
detaily najdete na stránkách nápovìdy <a Tree>stromu</a>, v sekci o cache.
</p>

<h4>Jak mohu pøímo editovat PGN zápis partie?</h4>
<p>
K editaci aktuální partie nemù¾ete pou¾ít okno <a PGN>PGN</a>, ale mù¾ete
editovat její PGN zápis pou¾itím okna <a Import>importu partie</a>.  Otevøete ho
(klávesová zkratka <b>Control+Shift+I</b>) a zvolte
<b>Vlo¾it aktuální partii</b>, pak mù¾ete partii editovat a nakonec zvolte
<b>Import</b>.
</p>

<h4>Moje databáze obsahuje rùzné tvary jmen nìkterých hráèù. Jak je mohu v¹echny
opravit?</h4>
<p>
Pou¾itím pøíkazù v menu <menu>Soubor: Údr¾ba</menu> mù¾ete editovat
individuální jména hráèù nebo opravit v¹echna jména v databázi. Ètìte stránku
<a Maintenance Editing>údr¾ba</a>.
</p>

<h4>Mám otevøeny dvì databáze: první s mými vlastními partiemi a druhou velkou s
velmistrovskými partiemi. Jak porovnám jednu z mých partií s tìmi ve velké
databázi?</h4>
<p>
Ve velké databázi si otevøete <a Tree>okno stromu</a> a zvolte
<term>Zamknout</term>, aby jste zamknuli strom k této databázi. Potom se
pøepnìte do druhé databáze a strom bude dále pokraèovat v zobrazování údajù pro
velkou databázi.
</p>

<p><footer>(Aktualizováno: Scid 2.6, Srpen 2001)</footer></p>
}


################
### Main window:

set helpTitle(C,MainWindow) "Hlavní okno Scidu"
set helpText(C,MainWindow) {<h1>Hlavní okno Scidu</h1>
<p>
Hlavní okno Scidu zobrazuje ¹achovnici s aktuální pozicí aktivní partie a
informace o této partii a o otevøené databázi. Jednotlivé stránky nápovìdy
popisují <a Menus>menu</a> hlavního okna a <a Moves>zpùsoby zadávání tahù</a>.
</p>

<h3>Tlaèítka navigace v partii</h3>
<p>
Navigaèní tlaèítka nad ¹achovnicí mají tyto významy, zleva doprava:
<ul>
<li> <button tb_start> Jdi na zaèátek partie. </li>
<li> <button tb_prev> Jdi o jeden tah nazpìt. </li>
<li> <button tb_next> Jdi o jeden tah dopøedu. </li>
<li> <button tb_end> Jdi na konec partie. </li>
<li> <button tb_invar> Skoè do varianty. </li>
<li> <button tb_outvar> Opus» aktuální variantu. </li>
<li> <button tb_addvar> Pøidej variantu k tomuto tahu v partii. </li>
<li> <button autoplay_off> Spus»/Ukonèi automatické pøehrávání tahù (viz
 ní¾e). </li>
<li> <button tb_trial> Spus»/Ukonèi <a Moves Trial>zku¹ební mód</a>. </li>
<li> <button tb_flip> Otoè ¹achovnici. </li>
<li> <button tb_coords>  Zapni/Vypni zobrazování souøadnic ¹achovnice. </li>
</ul>

<h4><name Autoplay>Automatické pøehrávání</name></h4>
<p>
V re¾imu automatického pøehrávání Scid automaticky pøehrává smìrem dopøedu
aktuální partii, dokud nedojde na její konec. Èasový interval mezi tahy lze
nastavit z menu <menu>Volby: Tahy</menu>, pøi ulo¾ení voleb je ulo¾en do
va¹eho souboru voleb.
</p>
<p>
Re¾im automatického pøehrávání spou¹tí nebo ukonèuje klávesová zkratka
<b>Control+Z</b>, ukonèit ho lze rovnì¾ klávesou <b>Escape</b>.
</p>
<p>
Jestli¾e spustíte re¾im automatického pøehrávání pøi otevøeném
<a Analysis>analytickém oknì</a>, partie se bude
<term>komentovat</term>: pøed provedením ka¾dého tahu bude jako nová varianta
pøidána analýza programu a jeho hodnocení. Podrobnosti se doètete na stránce
nápovìdy o <a Analysis>analytickém oknì</a>.
</p>

<h3>Informaèní zóna partie</h3>
<p>
Oblast pod ¹achovnicí zobrazující informace o partii se nazývá
<term>informaèní zóna partie</term>.
Její první tøi øádky zobrazují jména hráèù,
výsledek, datum a místo.
Ètvrtý øádek indikuje souèasnou pozici partie a
následující tah.
</p>
<p>
Pátý øádek zobrazuje <a ECO>ECO</a> (Encyclopedia of Chess Openings, tj.
Encyklopedie ¹achových zahájení) kód aktuální pozice, jestli¾e se tato pozice
nalézá v pou¾ívaném ECO souboru.
</p>
<p>
Pravým tlaèítkem mù¾ete v informaèní zónì partie aktivovat menu, kde lze napø.
skrýt následující tah (u¾iteèné pøi tréninku, kdy¾ hádáte jednotlivé tahy
partie) a smazat nebo obnovit aktuální partii. Toto menu lze aktivovat i bez
my¹i stisknutím funkèní klávesy <b>[F9]</b>.
</p>

<h4>Tabulky koncovek (tablebases)</h4>
<p>
Kdykoliv aktuální pozice dosáhne materiální konfiguraci nalezenou v databázovém
souboru tabulek koncovek, informaèní zóna partie rovnì¾ zobrazuje její
hodnocení podle této tabulky. Detaily hledejte na stránce nápovìdy o
<a TB>tabulkách koncovek</a>.
</p>

<h3>Stavová li¹ta</h3>
<p>
Stavová li¹ta zobrazuje informace o aktuální databázi. První pole indikuje stav
partie: <b>XX</b> znamená, ¾e partie byla zmìnìna, ale je¹tì neulo¾ena, zatímco
<b>--</b> znamená, ¾e zmìnìna nebyla, a <b>%%</b> indikuje, ¾e databáze je jen
ke ètení (nedá se zmìnit).
</p>
<p>
Jestli¾e chcete, aby databáze byla otevøena jen ke ètení, nastavte
adekvátnì pøístupová práva k jejím souborùm, minimálnì aspoò k jejímu indexovému
souboru, napø. na pøíkazovém øádku zadejte
<b>chmod a-w myfile.si3</b>
a tato databáze pak bude Scidem otevøena jen ke ètení.
</p>
<p>
Stavová li¹ta rovnì¾ zobrazuje, kolik partií je aktuálnì ve
<a Searches Filter>filtru</a>.
</p>

<p><footer>(Aktualizováno: Scid 3.1, Prosinec 2001)</footer></p>
}


######################
### Menus help screen:

set helpTitle(C,Menus) "Menu"
set helpText(C,Menus) {<h1>Menu Scidu</h1>

<h3><name File>Soubor</name></h3>
<ul>
<li><menu>Nový</menu>: Vytvoøí novou databázi.</li>
<li><menu>Otevøít</menu>: Otevøe existující databázi.</li>
<li><menu>Zavøít</menu>: Zavøe aktuální databázi.</li>
<li><menu>Vyhledávaè</menu>: Otevøe <a Finder>Vyhledávaè souborù</a>.</li>
<li><menu>Zálo¾ky</menu>: <a Bookmarks>Zálo¾ky</a> a jejich funkce.</li>
<li><menu>Údr¾ba</menu>: Funkce <a Maintenance>údr¾by</a> databáze.</li>
<ul>
  <li><menu>Okno údr¾by</menu>: Otevírá/Zavírá okno údr¾by databáze.</li>
  <li><menu>Vymazání zdvojených partií</menu>: Nalezne v databázi
      <a Maintenance Twins>zdvojené</a> partie.</li>
  <li><menu>ECO klasifikace partie</menu>: Pøepoèítá
      <a ECO>ECO kódy</a> v¹ech partií v databázi.</li>
  <li><menu>Editor jmen</menu>: Nahradí v¹echny výskyty jména hráèe, místa
      turnaje a kola.</li>
</ul>
<li><menu>Pouze pro ètení</menu>: Nastaví aktuální databázi jen ke ètení.</li>
<li><menu>Base 1/2/3/4/5</menu>: Tìmito pøíkazy lze pøepínat a¾ mezi ètyømi
    aktivními databázemi a <a Clipbase>databází schránka</a>.</li>
<li><menu>Ukonèit</menu>: Ukonèí program Scid.</li>
</ul>

<h3><name Edit>Editace</name></h3>
<ul>
<li><menu>Pøidat variantu</menu>: Pøidá novou prázdnou variantu k následujícímu
    tahu nebo k poslednímu, jestli¾e za ním u¾ ¾ádný jiný tah nenásleduje.</li>
<li><menu>Vymazat variantu</menu>: Zobrazí submenu variant k aktuálnímu (tj.
    následujícímu) tahu, které lze vymazat.</li>
<li><menu>Zaøadit jako první variantu</menu>: Zaøadí vybranou variantu k
    aktuálnímu tahu na první místo.</li>
<li><menu>Pový¹it stávající variantu na hlavní</menu>: Pový¹í vybranou variantu
    na hlavní výmìnou se souèasnou hlavní variantou.</li>
<li><menu>Zkusit variantu</menu>: Spustí <a Moves Trial>zku¹ební mód</a> pro
    testování varianty bez zásahu do aktuální partie.</li>
<li><menu>Odstranit</menu>: Odstraní z aktuální partie v¹echny komentáøe nebo
    varianty.</li>
<br>
<li><menu>Vyprázdnit schránku</menu>: Vyprázdní
    <a Clipbase>databázi schránka</a>, tak¾e neobsahuje ¾ádné partie.</li>
<li><menu>Zkopírovat tuto partii do schránky</menu>: Zkopíruje aktuální partii
    do <a Clipbase>databáze schránka</a>.</li>
<li><menu>Vlo¾it poslední partii ze schránky</menu>: Vlo¾í aktivní partii z
    <a Clipbase>databáze schránka</a> do aktuální databáze.</li>
<br>
<li><menu>Nastavit výchozí pozici</menu>: Nastaví výchozí pozici aktuální
    partie.</li>
<li><menu>Vlo¾it poèáteèní pozici</menu>: Vlo¾í poèáteèní pozici z
    aktuálního vybraného textu (v clipboardu).</li>
</ul>

<h3><name Game>Partie</name></h3>
<ul>
<li><menu>Nová partie</menu>: Nastaví aktuální partii do poèáteèní pozice a
    zru¹í v¹echny její neulo¾ené zmìny.</li>
<li><menu>Natáhnout první/pøedchozí/následující/poslední partii</menu>: Natáhne
    první/pøedchozí/následující/poslední partii do
    <a Searches Filter>filtru</a>.</li>
<li><menu>Znovunatáhnout aktuální partii</menu>: Znovunatáhne aktuální partii a
    zru¹í v¹echny její neulo¾ené zmìny.</li>
<li><menu>Natáhnout partii èíslo</menu>: Natáhne z aktuální databáze partii
    daného èísla.</li>
<br>
<li><menu>Ulo¾it: pøepsání partie</menu>: Ulo¾í aktuální partii pøepsáním její
    originální verze v databázi</li>
<li><menu>Ulo¾it: pøidání nové partie</menu>: Ulo¾í aktuální partii jako novou
    partii pøidáním na konec databáze.</li>
<br>
<li><menu>Identifikace zahájení</menu>: Najde nejhlub¹í pozici z aktuální
    partie, která se je¹tì nachází v ECO souboru.</li>
<li><menu>Pøejít na tah èíslo</menu>: Pøejde na specifikovaný tah aktuální
    partie.</li>
<li><menu>Hledat novinku</menu>: Najde první tah aktuální partie, který se je¹tì
    pøedtím nehrál. </li>
</ul>

<h3><name Search>Hledat</name></h3>
<ul>
<li><menu>Vyèistit filter</menu>: Vyèistí <a Searches Filter>filter</a>,
    tak¾e obsahuje v¹echny partie.</li>
<li><menu>Negace filtru</menu>: Invertuje filtr tak, ¾e obsahuje jen partie,
    které neobsahoval.</li>
<br>
<li><menu>Aktuální pozice</menu>: Vyhledává
    <a Searches Board>aktuální pozici</a> na ¹achovnici.</li>
<li><menu>Hlavièka: Vyhledává podle informací v
    <a Searches Header>hlavièce</a>, napø. podle jmen hráèù.</li>
<li><menu>Materiál/Vzor</menu>: Vyhledává podle
    <a Searches Material>materiálu</a> nebo vzorù.</li>
<br>
<li><menu>Hledat pomocí souboru voleb</menu>: Vyhledává pou¾itím
    <a Searches Settings>nastavení</a> ze souboru vyhledávacích voleb.</li>
</ul>

<h3><name Windows>Okna</name></h3>
<ul>
<li><menu>Editor komentáøù</menu>: Otevírá/Zavírá okno
    <a Comment>editoru komentáøù</a>.</li>
<li><menu>Seznam partií</menu>: Otevírá/Zavírá
    <a GameList>okno seznamu partií</a>.</li>
<li><menu>Okno PGN</menu>: Otevírá/Zavírá
    <a PGN>okno PGN</a>.</li>
<li><menu>Vyhledávaè turnajù</menu>: Otevírá/Zavírá okno
    <a Tmt>vyhledávaèe turnajù</a>.</li>
<br>
<li><menu>Výbìr databáze</menu>: Otevírá/Zavírá okno
    <a Switcher>výbìru databáze</a>, kde se lze pøepnout do jiné databáze nebo
    jednodu¹e kopírovat partie mezi databázemi.</li>
<li><menu>Okno údr¾by</menu>: Otevírá/Zavírá okno
    <a Maintenance>údr¾by</a> databáze.</li>
<br>
<li><menu>ECO prohlí¾eè</menu>: Otevírá/Zavírá okno
    <a ECO browser>ECO prohlí¾eèe</a>.</li>
<li><menu>Editor repertoáru</menu>: Otevírá/Zavírá
    <a Repertoire>editor repertoáru</a>.</li>
<li><menu>Statistické okno</menu>: Otevírá/Zavírá
    <term>Statistické okno filtru</term>, které zobrazuje pøehled výher/proher
    partií ve <a Searches Filter>filtru</a>.</li>
<li><menu>Stromové okno</menu>: Otevírá/Zavírá
    <a Tree>stromové okno</a>.</li>
<li><menu>Okno tabulky koncovek</menu>: Otevírá/Zavírá okno, které zobrazuje
    informace z <a TB>tabulek koncovek</a>.</li>
</ul>

<h3><name Tools>Nástroje</name></h3>
<ul>
<li><menu>Program pro analýzu</menu>: Spou¹tí/Zastavuje ¹achový program pro
    analýzu pozice, který zobrazuje v
    <a Analysis>analytickém oknì</a> hodnocení souèasné pozice.</li>
<li><menu>Program pro analýzu #2</menu>: Spou¹tí/Zastavuje druhý ¹achový program
    pro analýzu pozice.</li>
<li><menu>Turnajová tabulka</menu>: Zkonstruuje a zobrazí
    <a Crosstable>turnajovou tabulku</a> pro aktuální partii.</li>
<li><menu>Email mana¾er</menu>: Otevírá/Zavírá okno
    <a Email>emailového mana¾era</a> pro správu korespondenèních partií hraných
    emailem.</li>
<br>
<li><menu>Profil zahájení</menu>: Generuje
    <a Reports Opening>profil zahájení</a> pro aktuální pozicí.</li>
<li><menu>Stopaø figur</menu>: Otevírá okno
    <a PTracker>stopaøe figur</a>.</li>
<br>
<li><menu>Informace o hráèích</menu>: Zobrazí
    <a PInfo>informace o hráèích</a> aktuální partie.</li>
<li><menu>Graf ratingu </menu>: Zobrazí
    <a Graphs Rating>graf ratingu</a>.</li>
<li><menu>Graf skóre</menu>: Zobrazí
    <a Graphs Score>graf skóre</a>.</li>
<br>
<li><menu>Export aktuální partie</menu>: Zapí¹e aktuální partii do textového
    souboru ve formátu PGN, HTML nebo LaTeX. Ètìte stránku nápovìdy o
    <a Export>exportu</a>.</li>
<li><menu>Export filtrovaných partií</menu>: Zapí¹e v¹echny partie ve
    vyhledávacím <a Searches Filter>filtru</a> do textového souboru ve formátu
    PGN, HTML nebo LaTeX. Ètìte stránku nápovìdy o <a Export>exportu</a>.</li>
<br>
<li><menu>Import jedné PGN partie</menu>: Otevøe <a Import>okno Importu</a> pro
    zadávání partie nebo její vlo¾ení v <a PGN>PGN formátu</a>.</li>
<li><menu>Import souboru PGN partií</menu>: Importuje celý soubor partií
    v PGN formátu do aktuální databáze.</li>
</ul>

<h3><name Options>Volby</name></h3>
<p>
Toto menu poskytuje pøíkazy pro nastavení takøka v¹ech konfigurovatelných voleb
Scidu. Pøíkaz <menu>Ulo¾it volby</menu> ulo¾í aktuální nastavení voleb do
souboru "<b>~/.scid/scidrc</b>" (nebo <b>scid.opt</b> v adresáøi Scidu pro
u¾ivatele Windows); tento soubor se naèítá pøi ka¾dém startu Scidu.
</p>

<h3><name Help>Nápovìda</name></h3>
<p>
Toto menu obsahuje funkce nápovìdy a pøístup k oknu tipù dne nebo k startovacímu
oknu, které poskytuje informace o souborech, které Scid naèetl pøi startu.
</p>

<p><footer>(Aktualizováno: Scid 3.5, Únor 2003)</footer></p>
}


########################
### Entering moves help:

set helpTitle(C,Moves) "Zadávání tahù"
set helpText(C,Moves) {<h1>Zadávání tahù</h1>
<p>
Ve Scidu mù¾ete zadávat tahy partie pou¾itím my¹i nebo klávesnice. Kdy¾ pohnete
my¹í na nìjaké pole ¹achovnice, toto pole spolu s dal¹ím zmìní barvu, jestli¾e
existuje z tohoto nebo na toto pole mo¾ný tah. Jedná se o
<term>navrhovaný tah</term>. Chcete-li zadat tento tah, jednodu¹e kliknìte
<term>levým</term> tlaèítkem my¹i. Jestli¾e vás navrhování tahù ru¹í, mù¾ete ho
vypnout v menu Volby.
</p>
<p>
Jestli¾e chcete zadat jiný tah ne¾ navrhovaný, mù¾ete pou¾ít <term>levé</term>
tlaèítko my¹i; stisknìte tlaèítko na jednom poli a uvolnìte na druhém.
</p>
<p>
Jestli¾e upøednostòujete zadávat tahy dvìma kliknutím my¹i pøed jejím ta¾ením
se stisknutým tlaèítkem, mù¾ete pou¾ít <term>prostøední</term> tlaèítko;
kliknìte na jedno pole a pak na druhé.
</p>

<h4>Vrácení tahu zpìt</h4>
<p>
Chcete-li vrátit poslední tah zpìt, kliknìte pravým tlaèítkem my¹i. Vrátíte se
tak jeden tah nazpìt a tah se sma¾e, jestli¾e byl poslední v partii nebo ve
variantì.
</p>

<h4>Náhrada pùvodních tahù</h4>
<p>
Kdy¾ zadáte tah v takovém místì partie, kde u¾ nìjaký tah existuje, Scid zobrazí
dialogové okno, zda opravdu chcete nahradit pùvodní tah (pùvodní tah a v¹echny
tahy za ním budou ztraceny) nebo chcete pøidat nový tah jako variantu. Nìkterým
lidem mù¾e toto dialogové okno vadit, proto¾e v¾dy chtìjí nahradit pùvodní tahy,
z tohoto dùvodu to lze v menu <menu>Volby: Tahy</menu> volbou
"<i>Ptát se pøed nahrazením tahù</i>" vypnout.
</p>

<h4><name Trial>Zku¹ební mód</name></h4>
<p>
Jestli¾e studujete partii a dojdete do pozice, kde chcete zkusit alternativní
variantu beze zmìny partie, vyberte z menu <menu>Editace</menu> pøíkaz
<b>Zkusit variantu</b> pro spu¹tìní zku¹ebního módu. V tomto módu mù¾ete zadávat
tahy a jinak doèasnì mìnit partii, po ukonèení zku¹ebního módu se pak vrátíte do
pozice, kde jste tento mód spustili.</p>

<h3><name Mistakes>Oprava chyb</name></h3>
<p>
Kdy¾ zadáváte partii a najednou uvidíte chybný tah nìkolik tahù døív, je mo¾né
chybu opravit bez ztráty následujících, ji¾ zadaných tahù. Jediným zpùsobem je
editace PGN reprezentace partie: otevøete okno <a Import>Importu</a>, zadejte
"Vlo¾it aktuální partii", opravte chybný tah a zadejte "Import".
</p>

<h3>Zadávání tahù z klávesnice</h3>
<p>
Pro zadávání tahù z klávesnice jednodu¹e stisknìte odpovídající klávesy písmene
a èíslice. V¹imnìte si, ¾e akceptovatelné tahy musí být v
<term>SAN notaci</term>, <i>bez</i> symbolù braní (x) a promìny (=). Pøi zadávání
se nerozli¹uje velikost písmen, tak¾e napø. místo Nf3 mù¾ete zadat [n][f][3] --
pøeètìte si ale poznámku ní¾e o konfliktech u pì¹cových tahù.
</p>
<p>
Aby nedocházelo k problémùm, notace pro krátkou a dlouhou ro¹ádu je [O][K] resp.
[O][Q] místo bì¾ných oznaèení O-O a O-O-O.
</p>
<p>
Pøi zadávání tahù stavová li¹ta ukazuje adekvátní mo¾né tahy. Kdykoliv mù¾ete
stiskem [space] vybrat ze seznamu první tah a pøidat ho tak do partie. Chcete-li
smazat nìjaký znak, stisknìte [Backspace] nebo [Delete].
</p>
<p>
<b>V¹imnìte si</b>, ¾e pøi malých písmenech se nejprve navrhují tahy pì¹ci,
tak¾e [b] mù¾e odpovídat pì¹ci nebo støelci (Bishop), ale v pøípadì konfliktu
musíte pro tah støelcem pou¾ít velké písmeno [B].</p>

<h4>Doplòování tahù</h4>
<p>
V menu Volby mù¾ete zapnout nebo vypnout automatické
<term>doplòování tahù</term>. Pøi zapnutém doplòování tahù je tah zahrán,
jakmile jste zadali dostatek informací pro jeho rozeznání mezi ostatními mo¾nými
tahmi. Napø. pøi zapnutém doplòování staèí pro tah <b>Jf3</b> v poèáteèní pozici
zadat [n][f] místo [n][f][3].</p>

<h3><name Null>Zadávání nulových tahù</name></h3>
<p>
<a Annotating Null>Nulové</a> (prázdné) tahy mohou být u¾iteèné ve variantách,
 kde
chcete pøeskoèit tah jedné strany. Nulový tah mù¾ete zadat my¹í vzetím jednoho
krále druhým králem nebo klávesnicí zadáním "<b>--</b>" (tj. dvakrát stisknout
tlaèítko mínus).</p>

<h3>Zadávání bì¾ných anotaèních symbolù</h3>
<p>
Rovnì¾ mù¾ete v hlavním oknì s pomocí klávesnice zadávat bì¾né
<a NAGs>anotaèní symboly</a>, bez nutnosti pou¾ít okno
<a Comment>editoru komentáøù</a>. Následující seznam ukazuje,které symboly mù¾ete
zadat a jejich klávesové zkratky:
<ul>
<li> !  : [!][Return]</li>
<li> ?  : [?][Return] </li>
<li> !? : [!][?][Return] </li>
<li> ?! : [?][!][Return] </li>
<li> !! : [!][!][Return] </li>
<li> ?? : [?][?][Return] </li>
<li> </li>
<li> +- : [+][-] </li>
<li> +/-: [+][/] </li>
<li> += : [+][=] </li>
<li> =  : [=][Return] </li>
<li> -+ : [-][+] </li>
<li> -/+: [-][/] </li>
<li> =+ : [=][+] </li>
</ul>

<p><footer>(Aktualizováno: Scid 3.4, Èervenec 2002)</footer></p>
}


#########################
### Searches help screen:

set helpTitle(C,Searches) "Vyhledávání"
set helpText(C,Searches) {<h1>Vyhledávání Scidem</h1>
<p>
Scid mù¾e v databázi vyhledávat podle rùzných typù. Tøi hlavní typy vyhledávání
 jsou:
<ul>
<li><b>1)</b> podle aktuální pozice na ¹achovnici, </li>
<li><b>2)</b> podle specifikovaných vzorù materiálu nebo figur, a </li>
<li><b>3)</b> podle informací v hlavièce jako napø. hráèi, výsledek, datum.
 </li>
</ul>
<p>
K tìmto tøem typùm vyhledávání navíc existuje automatický vyhledávací mód zvaný
<a Tree>Okno stromu</a>, který je objasnìn zvlá¹».
</p>

<h3><name Filter>Vyhledávací filtr</name></h3>
<p>
Vyhledávání ve Scidu jsou zalo¾eny na pojmu <term>filtr</term>. Filtr
reprezentuje podmno¾inu aktuální databáze: v ka¾dém okam¾iku je ka¾dá partie buï
ve filtru obsa¾ena nebo z filtru vyòata.
</p>
<p>
U ka¾dého typu vyhledávání mù¾ete vyhledávání omezit na existující filtr, pøidat
k existujícímu filtru nebo filtr ignorovat a prohledat tak celou databázi.
</p>
<p>
Mù¾ete rovnì¾ v¹echny partie jedné databáze obsa¾ené ve filtru zkopírovat do
jiné databáze pou¾itím okna <a Switcher>výbìru databáze</a>.
</p>
<p>
Pøi vyhledávání podle pozice, podle materiálu/vzoru nebo pøi
<a Tree>stromových</a> vyhledáváních se èíslo tahu první odpovídající pozice
ka¾dé odpovídající partie zapamatuje, tak¾e pøi nahrání ka¾dé partie bude
automaticky zobrazena odpovídající pozice.
</p>
<p>
<b>V¹imnìte si</b>, ¾e vyhledávání probíhá jen v hlavní variantì ka¾dé partie, ne
v ostatních variantách. </p>

<h3><name Board>Vyhledávání podle aktuální pozice</name></h3>
<p>
Tento zpùsob vyhledávání nalezne partie, které obsahují aktuální zobrazenou
pozici, pøi ignorování práv ro¹ády a braní mimochodem (<i>en passant</i>).
</p>
<p>
Existují ètyøi typy vyhledávání podle pozice. V¹echny ètyøi vy¾adují tentý¾
materiál a shodu u strany, která má být na tahu. Tyto typy jsou:
<ul>
<li> [1] pøesná pozice (v¹echny figury na stejných polích), </li>
<li> [2] pì¹ci (v¹ichni pì¹ci na stejných polích, figury mohou být kdekoliv),
     </li>
<li> [3] sloupce (v¹ichni pì¹ci na stejných sloupcích, figury mohou být
     kdekoliv), a </li>
<li> [4] materiál (pì¹ci a figury mohou být kdekoliv). </li>
</ul>
<p>
Vyhledávání podle pì¹cù je u¾iteèné pøi studiu zahájení podle pì¹cové struktury,
vyhledávání podle øad a materiálu je zase u¾iteèné pro nalezení podobných pozic
v koncovce.
</p>
<p>
Chcete-li hledat libovolnou pozici, mù¾ete si pozici nejprve nastavit na
¹achovnici (z menu <menu>Editace: Nastavit výchozí pozici</menu>) a potom
spustit její vyhledávání. </p>
<p>
Výbìrem <b>Dívat se do variant</b> mù¾ete po¾adovat vyhledávání i ve variantách
(místo jen v hlavní variantì partie), ale to mù¾e vyhledávání znaènì zpomalit,
je-li databáze velká a obsahuje mnoho partií s variantami.
</p>

<h3><name Material>Vyhledávání podle materiálu/vzoru</name></h3>
<p>
Tento zpùsob vyhledávání je vhodný pro hledání témat z koncovek a støední hry.
Mù¾ete specifikovat minimální a maximální poèet jednotlivých kamenù a hledat
vzory jako napø. støelec na f7 nebo pì¹ec na f sloupci.
</p>
<p>
Je pøeddefinováno mno¾ství bì¾ných materiálních sestav a vzorù, jako napø.
koncovky vì¾ proti pì¹ci nebo dámský izolovaný pì¹ec.
</p>
<p>
<b>Rada:</b><br>
Rychlost vyhledávání podle vzoru se mù¾e ¹iroce li¹it. Nastavením inteligentních
omezení mù¾ete vyhledávací èas redukovat. Napø. jestli¾e pøi hledání koncovky
nastavíte minimální èíslo tahu na 20, v¹echny partie konèící pod 20 tahù mohou
být pøeskoèeny.
</p>

<h3><name Header>Vyhledávání podle hlavièky</name></h3>
<p>
Tento zpùsob vyhledávání mù¾e být pou¾it na hledání takových aspektù partie,
které jsou ulo¾eny v její hlavièce (jako datum, výsledek, jména, pøíznaky a
ratingy), tak¾e nevy¾aduje ¾ádné dekódování tahù.
</p>
<p>
Aby partie vyhovovala vyhledávání podle hlavièky, musí vyhovovat <b>v¹echna</b>
pole, která jste specifikovali.
</p>
<p>
Pøi vyhledávání podle polí jmen (Bílý, Èerný, Turnaj, Místo a Kolo) vyhovuje
jakýkoliv text obsahující zadané jméno, pøitom se nerozli¹uje velikost písmen a
ignorují se mezery. </p>
<p>
Pro tato pole jmen mù¾ete pou¾ívat bì¾né zástupné znaky (<b>?</b> reprezentující
jeden jakýkoliv znak a <b>*</b> reprezentující nulu nebo více znakù) a provádìt
vyhledávání s rozli¹ováním velikosti písmen uzavøením hledaného textu do
uvozovek.  Napø. vyhledávání Místo <b>USA</b> najde americká mìsta a také
<b>Lausanne SUI</b>, co¾ pravdìpodobnì není to, èeho jste chtìli dosáhnout! Ale
vyhledávání Místo <b>"*USA"</b> (nezapomeòte pou¾ít uvozovky) opravdu najde jen
mìsta ve Spojených Státech. </p>
<p>
Jestli¾e hledáte jednotlivého hráèe (nebo dvojici soupeøù) jako Bílý nebo Èerný
a nezále¾í na tom, jakými barvami hráli, zvolte <b>Ignorovat barvy</b>.
</p>
<p>
Koneènì, vyhledávání podle hlavièky mù¾e být pou¾ito na nalezení jakéhokoliv
textu (pøi rozli¹ování velikosti písmen a bez pou¾ití zástupných znakù)v PGN
reprezentaci ka¾dé partie. Mù¾ete zadat a¾ tøi textové øetìzce, které se v¹echny
musí objevit v partii, aby partie vyhovovala.
Tento zpùsob vyhledávání je velmi u¾iteèný pro hledání v komentáøích nebo
zvlá¹tních poznámek (jako napø. <b>prohra na èas</b> nebo <b>Komentátor</b>),
nebo pro sekvenci tahù jako <b>Sxh7+</b> a <b>Kxh7</b> pro pøijatou obì» støelce
na h7.
Av¹ak tento typ vyhledávání mù¾e být <i>velmi</i> pomalý, proto¾e v¹echny
partie, vyhovující ostatním kritérium, musí být dekódovány a prohledány na
výskyt tìchto textových øetìzcù.
Proto je dobrou ideou tato vyhledávání co nejvíc omezit.
Zde jsou nìjaké pøíklady.
Hledáte-li partie s promìnou pì¹ce na vì¾, zadejte <b>=V</b> a rovnì¾ nastavte
pøíznak <b>Promìny</b> na Ano. Hledáte-li text, který by se mohl objevit v
komentáøích, nastavte pøíznak <b>Komentáøe</b> na Ano.
Hledáte-li tahy <b>Sxh7+</b> a <b>Kxh7</b>, budete mo¾ná napø. chtít vyhledávání
omezit na partie s výsledkem 1-0 a nejménì s 40 pùltahy, nebo nejprve provést
vyhledávání podle materiálu/vzoru, kde bílý støelec táhnul na h7.
</p>

<h3><name Settings>Ulo¾ení vyhledávacích nastavení</name></h3>
<p>
Okna vyhledávání podle materiálu/vzoru a podle hlavièky poskytují tlaèítko
<term>Ulo¾it</term>. To vám dovoluje ulo¾it svoje aktuální nastavení vyhledávání
pro pozdìj¹í pou¾ití, které se ulo¾í do <term>souboru vyhledávacích voleb</term>
(SearchOption, pøípona .sso).
Chcete-li provádìt vyhledávání pou¾itím døíve ulo¾eného souboru vyhledávacích
voleb (.sso), z menu <menu>Hledat</menu> vyberte <menu>Hledat pomocí souboru
voleb</menu>.
</p>

<h3>Vyhledávací èasy a pøeskoèené partie</h3>
<p>
Vìt¹ina vyhledávání produkuje zprávu indikující spotøebovaný èas a poèet partií,
které byly <term>pøeskoèeny</term>. Pøeskoèená partie je taková partie, která
mù¾e být z vyhledávání vyòata na základì informací ulo¾ených v indexu, bez
dekódování jakéhokoliv jejího tahu. Pro více informací se podívejte na stránku
nápovìdy o <a Formats>formátech souborù</a>.
</p>

<p><footer>(Aktualizováno: Scid 3.0, Listopad 2001)</footer></p>
}


##################
### Clipbase help:

set helpTitle(C,Clipbase) "Schránka"
set helpText(C,Clipbase) {<h1>Databáze schránka</h1>
<p>
K databázím, které máte otevøené, Scid navíc poskytuje databázi
<term>schránka</term>, která je stejná jako ostatní databáze kromì toho, ¾e
existuje jen v pamìti a nemá ¾ádné soubory pro trvalé ulo¾ení.
</p>
<p>
Tato schránka je u¾iteèná jako doèasná databáze, pro sjednocování výsledkù
vyhledávání ve více ne¾ jedné databázi nebo jako samostatná databáze pro
zpracování výsledkù vyhledávání.
</p>
<p>
Pøedpokládejme napø., ¾e se chcete pøipravit na soupeøe a prohledali jste
databázi, tak¾e <a Searches Filter>filtr</a> obsahuje jen partie, kde soupeø
hrál bílýma.
Tyto partie mù¾ete zkopírovat do schránky (ta¾ením z jejich databáze do schránky
v oknì <a Switcher>výbìru databáze</a>), pøepnout se do databáze schránka a
otevøením <a Tree>okna stromu</a> prozkoumat repertoár tohoto hráèe. </p>
<p>
V¹imnìte si, ¾e partie ve filtru z jedné databáze mù¾ete pøímo zkopírovat do
jiné otevøené databáze (bez pou¾ití schránky jako zprostøedkujícího místa)
pou¾itím okna <a Switcher>výbìru databáze</a>.
</p>
<p>
V¹imnìte si, ¾e schránka <i>nemù¾e</i> být zavøena; nacházíte-li se ve schránce,
pøíkaz <menu>Soubor: Zavøít</menu> je ekvivalentní pøíkazu
<menu>Editace: Vyprázdnit schránku</menu>, který vyprázdní schránku.
</p>
<p>
Velikost schránky je trvale omezena 20,000 partiemi, proto¾e existuje jen v
pamìti.
</p>

<p><footer>(Aktualizováno: Scid 2.5, Èerven 2001)</footer></p>
}

#################################
### Variations and comments help:

set helpTitle(C,Annotating) "Anotace partií"
set helpText(C,Annotating) {<h1>Anotace partií</h1>
<p>
Scid vám umo¾òuje k partii pøidat poznámky. Jsou tøi typy anotací, které mù¾ete
pøidat za tah: symboly, komentáø a varianty.
</p>

<h3>Symboly a komentáøe</h3>
<p>
Symboly se pou¾ívají pro indikaci hodnocení pozice (jako napø. "+-" nebo "=")
nebo k oznaèení dobrých ("!") a ¹patných ("?") tahù, zatímco komentáø mù¾e být
libovolný text. Chcete-li k partii pøidat symboly, pou¾ijte okno
<a Comment>Editoru komentáøù</a>.
Je zde také stránka nápovìdy se seznamem
<a NAGs>standardních symbolických hodnot</a>. </p>
<p>
Uvìdomte si, ¾e ka¾dý tah mù¾e mít více ne¾ jeden anotaèní symbol, ale pouze
jeden komentáø. Komentáø pøed prvním tahem partie je zobrazen jako text pøed
zaèátkem partie.
</p>

<h3><name Vars>Varianty</name></h3>
<p>
<term>Varianta</term> tahu je alternativní posloupnost tahù v urèitém místì
partie. Varianty mohou obsahovat komentáøe a dokonce rekurzivnì mohou mít
podvarianty. Pro vytvoøení, navigaci a editaci variant lze pou¾ít tlaèítka nad
¹achovnicí se symbolem "<b>V</b>" a pøíkazy v menu <menu>Edit</menu>.
</p>

<h4>Klávesové zkratky</h4>
<p>
Kdy¾ má tah varianty, jsou zobrazeny v informaèní zónì partie. První bude
oznaèena <b>v1</b>, druhá <b>v2</b> atd.
Kliknutím na variantu mù¾ete do ní skoèit nebo stisknìte "<b>v</b>" následované
èíslem varianty. (Jestli¾e k tahu existuje jen jedna varianta, jednoduchý stisk
<b>v</b> do ní skoèí.)
Chcete-li variantu opustit, mù¾ete pou¾ít klávesovou zkratku "<b>z</b>".
</p>

<h3><name Null>Nulové tahy</name></h3>
<p>
Nìkdy mù¾ete shledat u¾iteèným ve variantì pøeskoèit tah jedné strany. Napø.
mù¾ete chtít pøidat do varianty tah 14.Sd3 a poukázat, ¾e hrozí 15.Sxh7+ Kxh7
16.Jg5+ s útokem. To mù¾ete udìlat provedením <term>nulového tahu</term>, v
pøíkladu vý¹e mezi 14.Sd3 a 15.Sxh7+. Nulový tah je zobrazen jako  "<b>--</b>"
a mù¾e být zadán pou¾itím my¹i provedením nemo¾ného tahu vzetí jednoho krále
druhým nebo z klávesnice zadáním "<b>--</b>" (dvì znaménka mínus).
</p>
<p>
Uvìdomte si, ¾e nulové tahy nejsou souèástí PGN standardu, tak¾e jestli¾e
exportujete partie s nulovými tahy do PGN souboru, Scid poskytne (kromì jiných
voleb exportu) volbu uchovat nulové tahy nebo je zkonvertovat na komentáøe pro
kompatibilitu s jiným softwarem.
Pro více detailù ètìte stránku nápovìdy o <a Export>exportování</a>.
</p>

<p><footer>(Aktualizováno: Scid 3.4, Èervenec 2002)</footer></p>
}

###############################
### Comment editor window help:

set helpTitle(C,Comment) "Okno editoru komentáøù"
set helpText(C,Comment) {<h1>Okno editoru komentáøù</h1>
<p>
Okno editoru komentáøù umo¾òuje pøidávat nebo editovat komentáøe a symbolické
anotaèní znaky k tahùm aktivní partie.
</p>

<h3>Anotaèní symboly</h3>
<p>
Scid pou¾ívá pro anotaèní symboly <a Author Related>PGN standard</a> spolu s
<a NAGs>NAG (numeric annotation glyph)</a> anotaèními hodnotami. Nìkteré z vìt¹iny
bì¾ných znakù (jako "!" nebo "+-") jsou zobrazeny jako znaky a pro rychlé pou¾ití
je pro nì v oknì editoru komentáøù tlaèítko. Pro ostatní symboly mù¾ete zadat
odpovídající  numerickou NAG hodnotu, která je èíslo od 1 do 255.
Napø. NAG hodnota 36 znamená  "Bílý má iniciativu" a bude v
<a PGN>PGN zápisu</a> partie zobrazena jako "$36".
</p>
<p>
Pøeètìte si stránku nápovìdy o <a NAGs>NAG hodnotách</a> definovaných
PGN standardem.
</p>
<p>
<b>Rada:</b> Bì¾né hodnotící symboly k tahùm (!, ?, !!, ??, !? and ?!)
mù¾ete zadat v hlavním oknì, bez pou¾ití okna editoru komentáøù, stiskem
odpovídajícího znaku následovaného klávesou [Return].
To je velmi u¾iteèné, zvlá¹tì pøi <a Moves>zadávání tahù</a> z klávesnice.
</p>

<h3>Komentáøe</h3>
<p>
Komentáøe mù¾ete editovat zápisem v poskytované textové oblasti a pou¾itím
tlaèítek Vyèistit, Vrátit se a Uschovat.
K úschovì komentáøe není potøeba neustále pou¾ívat tlaèítko Uschovat; komentáø
je automaticky uschován, kdykoliv pøejdete k jiné pozici partie.</p>

<h3>Barevné znaèení polí</h3>
<p>
Pou¾itím speciálního vlo¾eného pøíkazu, který se mù¾e objevit kdekoliv v
komentáøi, mù¾ete libovolnou barvou barevnì oznaèit libovolné pole ¹achovnice.
Formát tohoto pøíkazu je:
</p>
<ul>
<li><b>[%mark square color]</b><li>
</ul>
<p>
kde <b>square</b> (tj. pole) je oznaèení pole jako napø. d4 a <b>color</b> (tj.
barva) je libovolné známé jméno barvy (jako napø. red, blue4, darkGreen,
lightSteelBlue atd.) nebo RGB kód (znak <b>#</b> následovaný ¹esticí
hexadecimálních èíslic, jako napø. #a0b0c8). Jestli¾e color je vynecháno,
pou¾ije se implicitnì <red>red</red>.
</p>
<p>
Komentáø mù¾e obsahovat libovolný poèet tìchto pøíkazù, ale ka¾dý musí mít své
vlastní <b>[%mark ...]</b> oznaèení. Napø. text komentáøe
</p>
<p>
  Nyní je d6 [%mark d6] slabé a mù¾e být napadeno jezdcem z b5.
  [%mark b5 #000070]
</p>
<p>
oznaèí d6 <red>èervenì</red> a b5 tmavomodrou barvou
<darkblue>#000070</darkblue>.
</p>

<h3>Kreslení ¹ipek</h3>
<p>
Pou¾itím speciálního komentovacího pøíkazu podobnému pøedchozímu mù¾ete
nakreslit ¹ipku z jednoho pole k druhému. Formát tohoto pøíkazu je:
</p>
<ul>
<li><b>[%arrow fromSquare toSquare color]</b><li>
</ul>
<p>
kde <b>fromSquare</b> (tj. z pole) a <b>toSquare</b> (tj. na pole) jsou oznaèení
polí jako napø. d4 a <b>color</b> (tj. barva) je libovolné známé jméno barvy
(napø. red, blue4 atd.) nebo RGB kód (napø. #a0b0c8). Jestli¾e color je
vynecháno, pou¾ije se implicitnì <red>red</red>.
</p>
<p>
Napø. text komentáøe
</p>
<p>
  Jezdec c3 a støelec c4 kontrolují slabé pole d5.
  [%arrow c3 d5 red] [%arrow c4 d5 blue]
</p>
<p>
nakreslí èervenou ¹ipku z c3 na d5 a modrou z c4 na d5.
</p>

<p><footer>(Aktualizováno: Scid 3.2, Únor 2002)</footer></p>
}

###########################
### Crosstable window help:

set helpTitle(C,Crosstable) "Okno turnajové tabulky"
set helpText(C,Crosstable) {<h1>Okno turnajové tabulky</h1>
<p>
Okno turnajové tabulky zobrazuje turnajovou tabulku pro aktuální partii.
Kdykoliv zvolíte aktualizaci tohoto okna (stiskem tlaèítka Aktualizovat nebo
stiskem klávesy <b>Return</b> v oknì turnajové tabulky nebo klávesovou zkratkou
<b>Control+Shift+X</b> v <a MainWindow>hlavním oknì</a> nebo v
<a GameList>oknì seznamu partií</a>), Scid vyhledá v¹echny partie toho turnaje,
z kterého je aktuální partie.
</p>
<p>
Partie se pova¾uje ze stejného turnaje jako je aktuální partie, jestli¾e se
hrála v <b>èasovém intervalu maximálnì tøí mìsícù</b> od aktuální partie a má
<b>pøesnì stejné speciální oznaèení Event</b> (turnaj) a <b>Site</b> (místo).
</p>
<p>
Kliknutím levým tlaèítkem my¹i na kterýkoliv výsledek v tabulce lze natáhnout
odpovídající partii.
Pomocí tlaèítka <b>Pøidat do filtru</b> v oknì turnajové tabulky mù¾ete v¹echny
partie turnaje pøidat do <a Searches Filter>filtru</a>.
</p>

<h4>Menu okna turnajové tabulky</h4>
<p>
Menu <menu>Soubor</menu> umo¾òuje tisk aktuální tabulky do textového, LaTeX
nebo HTML souboru.
</p>
<p>
Menu <menu>Zobrazit</menu> umo¾òuje vybrat formát tabulky:
<b>Ka¾dý s ka¾dým</b>, <b>©výcarský systém</b> nebo <b>Vyøazovací</b> nebo
<b>Auto</b>.
</p>
<p>
Formát ka¾dý s ka¾dým (pro kruhové turnaje) je omezen poètem 30 hráèù, ale
¹výcarský systém (pro turnaje s mnoha hráèi) mù¾e zobrazit a¾ 200 hráèù a a¾ 20
kol. Formát <b>auto</b>, který pro ka¾dý turnaj automaticky vybere nejlep¹í
formát, je nastaven implicitnì.
</p>
<p>
Uvìdomte si, ¾e Scid pou¾ívá k pøípravì tabulky ¹výcarského systému speciální
oznaèení <b>Round</b> (Kolo) ka¾dé partie, tak¾e v turnajové tabulce ¹výcarského
systému neuvidíte ¾ádné partie, jestli¾e jeho partie nebudou mít numerická
oznaèení kol: 1, 2, 3, atd.
</p>
<p>
Menu Zobrazit vám rovnì¾ umo¾òuje pøizpùsobit si prezentované údaje pøidáním
nebo odebráním ratingù, zemí a titulù hráèù. Mù¾ete rovnì¾ zvolit, zda mají být
v tabulce indikovány barvy (jen pro ¹výcarský systém).
</p>
<p>
Volba <b>Skupiny podle skóre</b> ovlivòuje zobrazení tabulky jen tehdy, kdy¾
jsou hráèi seøazeni podle bodù: mezi skupiny hráèù se stejným poètem bodù je pro
lep¹í pøehlednost vlo¾en prázdný øádek.
</p>
<p>
Menu <menu>Øadit</menu> umo¾òuje seøadit hráèe podle jména, ratingu nebo podle
skóre; implicitnì jsou øazeni podle skóre.
</p>
<p>
Menu <menu>Barvy</menu> umo¾òuje zapnout nebo vypnout barevné (hypertextové)
zobrazování. Proto¾e v¹ak formátování a zobrazení velké tabulky v hypertextu
mù¾e trvat velmi dlouho, volbou <b>Prostý text</b> pro velké turnaje u¹etøíte
spoustu èasu.
Av¹ak v textovém módu nelze klikat na hráèe èi partie.
</p>

<h4>Duplicitní partie v tabulce</h4>
<p>
Abyste dostali v turnajové tabulce správné výsledky, je potøeba oznaèit k
výmazu duplicitní partie a partie musí mít shodné tvary jmen hráèù, turnajù a
míst.
Pro dal¹í nápovìdu o mazání duplicitních partií a editaci (nebo kontrole
pravopisu) jmen hráèù, turnajù, míst ètìte stránku
<a Maintenance>údr¾by databáze</a>.
</p>

<p><footer>(Aktualizováno: Scid 3.1, Prosinec 2001)</footer></p>
}


###########################
### Database switcher help:

set helpTitle(C,Switcher) "Výbìr databáze"
set helpText(C,Switcher) {<h1>Okno výbìru databáze</h1>
<p>
Okno výbìru databáze poskytuje pohled, který umo¾òuje jednodu¹e se pøepínat a
kopírovat partie mezi databázemi.
Je zobrazeno jméno, stav <a Searches Filter>filtru</a> a graficky typ ikony
ka¾dé databáze, aktivní databáze je zvýraznìna ¾lutým pozadím.
</p>
<p>
Okno výbìru databáze mù¾ete otevøít z menu <menu>Okna</menu> nebo jeho
klávesovou zkratkou: <b>Control+D</b>.
</p>
<p>
Chcete-li zkopírovat v¹echny filtrované partie jedné databáze do druhé,
táhnìte stisknutým levým tlaèítkem my¹i od zdrojové databáze do cílové. Jestli¾e
partie mohou být zkopírovány, uvidíte potvrzovací dialog (jestli¾e cílová
databáze není <a Clipbase>schránka</a>), jestli¾e partie nemohou být
zkopírovány, uvidíte chybovou zprávu.
</p>
<p>
Stisk pravého tlaèítka my¹i nad databází vyvolá vyskakovací menu
týkající se této databáze, z kterého lze zmìnit typ ikony databáze nebo
resetovat její <a Searches Filter>filtr</a>. Toto menu lze rovnì¾ pou¾ít ke
zmìnì orientace okna (vertikálnì nebo horizontálnì), co¾ je u¾iteèné pro
men¹í obrazovky.
</p>

<p><footer>(Aktualizováno: Scid 3.1, Prosinec 2001)</footer></p>
}


############################
### File Finder window help:

set helpTitle(C,Finder) "Okno vyhledávaèe souborù"
set helpText(C,Finder) {<h1>Okno vyhledávaèe souborù</h1>
<p>
<term>Vyhledávaè souborù</term> vám pomáhá pøi hledání souborù v¹ech typù, které
lze ve Scidu pou¾ít: databází, <a PGN>PGN</a> souborù, <a EPD>EPD</a> souborù a
<a Repertoire>repertoárových</a> souborù.
</p>
<p>
Vyhledávaè zobrazuje o ka¾dém souboru u¾iteèné informace jako jeho velikost
(ètìte ní¾e) a datum poslední modifikace. Kterýkoliv zobrazený soubor lze
otevøít jeho vybráním jednoduchým kliknutím levým tlaèítkem my¹i.
</p>

<h3>Hledání v podadresáøích</h3>
<p>
Jestli¾e chcete nalézt v¹echny soubory ve v¹ech podadresáøích souèasného
adresáøe, zapnìte volbu <b>Hledat v podadresáøích</b>. Takto bude Scid
rekurzivnì hledat ve v¹ech podadresáøích soubory, které lze ve Scidu otevøít.
Pro mnoho podadresáøù to mù¾e trvat velmi dlouho, tak¾e není vhodné to provádìt
pro adresáø blízko koøenového adresáøe souborového systému. Vyhledávání souborù
lze zastavit tlaèítkem <b>Stop</b>.
</p>

<h3>Velikost souboru</h3>
<p>
Význam velikosti souboru zobrazené vyhledávaèem závisí na typu souboru. Pro
databáze Scidu a PGN soubory znamená poèet partií. Pro EPD soubory znamená poèet
pozic. Pro repertoárové soubory znamená poèet (zahrnutým nebo vylouèených)
variant.
</p>
<p>
Pro v¹echny typy souborù kromì databázi Scidu je velikost souboru
odhad vytvoøený prohlédnutím jen prvních 64 kilobytù souboru, tak¾e velikost
souborù vìt¹ích ne¾ 64 kb nemusí být správná. Odhadnuté velikosti jsou zobrazeny
se znakem tilda (~), indikujíc tak, ¾e nejsou pøesné.
</p>

<p><footer>(Aktualizováno: Scid 2.7, Záøí 2001)</footer></p>
}

##################################
### Tournament Finder window help:

set helpTitle(C,Tmt) "Okno vyhledávaèe turnajù"
set helpText(C,Tmt) {<h1>Okno vyhledávaèe turnajù</h1>
<p>
<term>Vyhledávaè turnajù</term> vám umo¾òuje najít turnaje v aktuální databázi.
Prochází v¹echny partie databáze a ovìøuje údaje o nalezených turnajích.
V¹imnìte si, ¾e dvì partie se pova¾ují za partie ze stejného turnaje, jestli¾e
mají stejné speciální oznaèení Event (Turnaj), stejné speciální oznaèení Site
(Místo) a hrály se v èasovém intervalu maximálnì tøí mìsícù od sebe.
</p>
<p>
Editací polí pod seznamem turnajù a následným stiskem tlaèítka
<b>Aktualizovat</b> mù¾ete seznam omezit poètem hráèù a partií, datumem,
prùmìrným Elo ratingem a zemí.
</p>
<p>
Zobrazený seznam mù¾e být setøídìn podle data, poètem hráèù, poètem partií,
prùmìrným Elo ratingem, místem, turnajem nebo pøíjmením vítìze. Kategorii
vyberte z menu <menu>Øadit</menu> nebo kliknìte na titulek po¾adovaného sloupce.
</p>
<p>
Chcete-li natáhnout první partii libovolného zobrazeného turnaje, staèí kliknout
levým tlaèítkem my¹i, kdy¾ je øádek po¾adovaného turnaje zvýraznìn. Tak dojde
rovnì¾ k aktualizaci okna <a Crosstable>turnajové tabulky</a>, je-li otevøeno.
Jestli¾e místo toho kliknete pravým tlaèítkem my¹i, partie se natáhne a okno
turnajové tabulky se otevøe, i kdy¾ bylo zavøeno.
</p>
<p>
Pro urychlení procesu vyhledávání turnajù je dobrou ideou nastavit docela malý
èasový rozsah (jako nanejvý¹e nìkolik let) nebo vybrat urèitou zemi (jejím
tøíznakovým standardním kódem). To znaènì zredukuje poèet partií, které Scid
musí vzít do úvahy pøi zformování turnajù z partií v databázi.
</p>

<p><footer>(Aktualizováno: Scid 3.3, Duben 2002)</footer></p>
}

#########################
### GameList window help:

set helpTitle(C,GameList) "Okno seznamu partií"
set helpText(C,GameList) {<h1>Okno seznamu partií</h1>
<p>
Okno seznamu partií zobrazuje jednoøádkový souhrn informací pro ka¾dou partii
obsa¾enou v aktuálním <term>filtru</term>.
</p>

<h3>Navigace v seznamu partií</h3>
<p>
V seznamu partií se mù¾ete pohybovat pomocí posuvné li¹ty nebo pou¾itím ètyø
tlaèítek pod seznamem. V seznamu se lze pohybovat rovnì¾ pomocí klávesnice, a to
klávesami [Home], [End], [Page Up], [Page Down] a ¹ipkami.
</p>
<p>
Pou¾itím okénka <b>Hledat text</b> lze vyhledávat následující partii v seznamu,
která obsahuje v poli Bílý, Èerný, Turnaj nebo Místo jistý text.
</p>

<h3>Akce s partiemi v seznamu</h3>
<p>
Natáhnout partii ze seznamu lze dvojklikem levého tlaèítka na partii.
Kliknutím prostøedního tlaèítka my¹i se zobrazí poèáteèní tahy partie; to mù¾e
být u¾iteèné na kontrolu zahájení partie pøed jejím nata¾ením.
</p>
<p>
Pravé tlaèítko my¹i vyvolá pro vybranou partii menu, v kterém mù¾ete prohlédnout
nebo pøipojit partii (viz ní¾e), smazat (nebo obnovit) partii nebo ji vyjmout z
filtru.
Uvìdomte si, ¾e smazaní partie jen zapne její mazací pøíznak; partie zùstane a¾
do <a Compact>kompaktování</a> v databázi.
</p>

<h3>Konfigurace seznamu partií</h3>
<p>
Ke konfiguraci seznamu partií kliknìte levým nebo pravým tlaèítkem my¹i na
titulku sloupce. Mù¾ete tak zmìnit ¹íøku sloupce, pøidat nebo odebrat sloupce a
zmìnit bravu pro ka¾dý sloupec.
</p>
<p>
Chcete-li jen zmìnit velikost sloupce, lze pou¾ít klávesovou zkratku; pøidr¾ením
klávesy <b>Control</b> (nebo <b>Shift</b>) a souèasným stiskem levého tlaèítka
my¹i na titulku sloupce ho zú¾íte a stiskem pravého tlaèítka roz¹íøíte.
</p>

<h3>Zmìna velikosti seznamu partií</h3>
<p>
Velikost okna seznamu partií se zapí¹e do souboru voleb pøi ka¾dém ulo¾ení
voleb.
Tak¾e chcete-li, aby seznam partií zobrazoval implicitnì 10 partií, zmìòte
velikost okna seznamu partií a zadejte pøíkaz <menu>Ulo¾it volby</menu> z menu
<menu>Volby</menu>.
</p>

<h3><name Browsing>Prohlí¾ení a pøipojování partií</name></h3>
<p>
Menu vyvolané pravým tlaèítkem my¹i v seznamu partií (a také jiná okna jako
okno <a Reports Opening>profilu zahájení</a> a
<a Tree Best>seznam nejlep¹ích partií</a> v oknì <a Tree>stromu</a>) poskytuje
výbìr nata¾ení, prohlédnutí a pøipojení partie.
</p>
<p>
Pøi volbì <term>Prohlédnout partii</term> jsou tahy vybrané partie (bez
komentáøù nebo variant) zobrazovány v samostatném oknì. To je u¾iteèná cesta k
prohlédnutí jiné partie bez ovlivnìní aktuálnì nata¾ené partie.
</p>
<p>
Volba <term>Pøipojit partii</term> poskytuje zpùsob k pøipojení vybrané partie
jako varianty k aktuální partii. Scid nalezne nejhlub¹í místo, kde se vybraná
partie li¹í od aktuální partie (pøehození tahù se berou v úvahu), a v této
pozici pøidá vybranou partii jako variantu. Mù¾ete rovnì¾ zmìnit poèet pøidaných
tahù vybrané partie podle toho, jestli chcete pøipojit celou partii nebo jen
její zahájení.
</p>

<p><footer>(Aktualizováno: Scid 3.2, Únor 2002)</footer></p>
}


#######################
### Import window help:

set helpTitle(C,Import) "Okno importu partií"
set helpText(C,Import) {<h1>Okno importu partií</h1>
<p>
Okno importu Scidu vám poskytuje jednoduchý zpùsob ke vkládání partie v
<a PGN>PGN formátu</a> z jiné aplikace nebo okna do Scidu.
</p>
<p>
Velký bílý rámec v oknì je místo, kam zapí¹ete nebo vlo¾íte text partie v PGN
formátu, ¹edý rámec pod poskytuje zpìtnou vazbu v¹ech chyb a varování.
</p>

<h3>Editace aktuální partie prostøednictvím okna importu</h3>
<p>
Okno importu lze rovnì¾ pou¾ít jako ¹ikovný prostøedek k provedení nìkolika málo
zmìn v aktuální partii: mù¾ete vlo¾it aktuální partii do okna importu (pou¾itím
tlaèítka <b>Vlo¾it aktuální partii</b>), editovat její text a po skonèení
kliknout <b>Import</b>.
</p>

<h3>Speciální oznaèení PGN v oknì importu</h3>
<p>
Scid oèekává pøed v¹emi tahmi speciální hlavièkové oznaèení PGN jako napø.
<ul>
<li> <b>[Result "*"]</b>, </li>
</ul>
ale klidnì mù¾ete vlo¾it partii jako
<ul>
<li> <b>1.e4 e5 2.Sc4 Sc5 3.Dh5?! Jf6?? 4.Dxf7# 1-0</b> </li>
</ul>
bez v¹ech speciálních hlavièkových oznaèení a Scid ji importuje.
</p>

<h3>Pou¾ívání PGN souborù ve Scidu</h3>
<p>
Jestli¾e chcete ve Scidu pou¾ívat formát souborù PGN, ale nechcete ho nejprve
zkonvertovat pou¾itím <a Pgnscid>pgnscid</a>, existují zde dvì cesty.
</p>
<p>
Za prvé mù¾ete importovat partie v souboru do existující databáze pou¾itím
pøíkazu menu <menu>Nástroje: Import souboru PGN partií...</menu>.
</p>
<p>
Alternativou je otevøení PGN souboru pøímo ve Scidu. Av¹ak soubory formátu PGN
jsou otevøeny pouze ke ètení a spotøebovávají více pamìti ne¾ porovnatelná
databáze Scidu, tak¾e to lze doporuèit jen pro relativnì malé PGN soubory.
</p>

<p><footer>(Aktualizováno: Scid 2.5, Èerven 2001)</footer></p>
}

###################
### Exporting help:

set helpTitle(C,Export) "Export partií"
set helpText(C,Export) {<h1>Export partií</h1>
<p>
K exportu aktuální partie nebo v¹ech partií v aktuálním filtru do textového
souboru mù¾ete pou¾ít pøíkazy v menu <menu>Nástroje</menu>.
</p>
<p>
Textový soubor je k dispozici ve tøech formátech: <a PGN>PGN</a> (portable game
notation), HTML (pro webové stránky) a LaTeX (populární sázecí systém).
</p>
<p>
Pøi exportování si mù¾ete vybrat, zda-li chcete vytvoøit nový soubor nebo pøidat
partie k existujícímu souboru partií exportovaných Scidem.
</p>

<h3>Diagramy</h3>
<p>
Pøi exportu v HTML nebo LaTeX formátu Scid automaticky pøidá diagram, kdykoliv
se v partii objeví diagramový <a NAGs>nag</a> ("D") nebo <a Comment>komentáø</a>
zaèínající znakem "#".
</p>

<h3><name Null>Nulové tahy v PGN exportu</name></h3>
<p>
Scid umo¾òuje ukládat do partie <a Annotating Null>nulové (prázdné) tahy</a>,
proto¾e mohou být u¾iteèné pøi anotaci partií variantami.
Av¹ak  PGN standard pojem nulový tah neobsahuje. Tak¾e exportujete-li partie
Scidu s nulovými tahy do PGN souboru, ostatní PGN ètecí software nebude schopen
nulové tahy pøeèíst.
</p>
<p>
K øe¹ení tohoto problému Scid poskytuje pøi exportu partií do PGN formátu navíc
volbu <b>Convert null moves to comments</b>.
Chcete-li vytvoøit PGN soubor, který mù¾e pou¾ít jiný software, tuto volbu
zapnìte a varianty obsahující nulový tah budou konvertovány na komentáøe. Av¹ak
chcete-li vytvoøit PGN soubor, který mù¾e být pozdìji importován zpìt do Scidu
se zachovanými nulovými tahmi, ponechte tuto volbu vypnutou.
</p>

<h3>HTML export</h3>
<p>
Scid mù¾e exportovat partie do HTML souboru. Aby se zobrazily diagramy, je
potøebovat, aby obrázky diagramù (distribuované spoleènì se Scidem v adresáøi
"<b>bitmaps/</b>") byly v podadresáøi <b>bitmaps/</b> pod adresáøem, kde se
nachází HTML soubor.
</p>

<h3>LaTeX export</h3>
<p>
Scid mù¾e exportovat partie do LaTeX souboru.
Partie jsou sázeny ve dvou sloupcích na stranu a tahy jsou v symbolické
algebraické notaci.
</p>
<p>
Pro více informací ètìte stránku nápovìdy <a LaTeX>Pou¾ití LaTeXu se Scidem</a>.
</p>

<p><footer>(Aktualizováno: Scid 3.4, Èervenec 2002)</footer></p>
}

###############
### LaTeX help:

set helpTitle(C,LaTeX) "Scid a LaTeX"
set helpText(C,LaTeX) {<h1>Pou¾ití LaTeXu se Scidem</h1>
<p>
Scid mù¾e partie a profily zahájení ukládat do souborù v LaTeX formátu. LaTeX
je roz¹íøení TeXu, populárního sázecího systému.
</p>
<p>
Chcete-li sázet LaTeX soubory vytvoøené Scidem, musíte mít (samozøejmì) LaTeX a
musíte mít nainstalovaný balík ¹achových fontù "chess12". Tento balík fontù
obvykle není souèástí standardní instalace LaTeXu, tak¾e klidnì mù¾ete mít LaTeX
a nemusíte mít ¹achové fonty.
</p>
<p>
Pro informace o sta¾ení a instalaci ¹achových fontù nav¹tivte stránku
<url http://scid.sourceforge.net/latex.html>Pou¾ití LaTeXu se Scidem</url>
na <url http://scid.sourceforge.net/>webové stránce Scidu</url>.
</p>

<p><footer>(Aktualizováno: Scid 2.5, Èerven 2001)</footer></p>
}

####################
### PGN window help:

set helpTitle(C,PGN) "Okno PGN"
set helpText(C,PGN) {<h1>Okno PGN</h1>
<p>
Okno PGN Scidu zobrazuje obsah aktuální partie ve standardní PGN reprezentaci. V
zápisu tahù jsou komentáøe {ve slo¾ených závorkách} a varianty (v závorkách).
</p>

<h3>PGN formát</h3>
<p>
PGN (Portable Game Notation) je obecný standard pro pøenos ¹achových partií mezi
poèítaèovými programy.
PGN partie se skládá ze dvou sekcí. První je hlavièka, která obsahuje speciální
oznaèení jako napø.
<b>[White "Kasparov, Gary"]</b>
a
<b>[Result "1/2-1/2"]</b>.
</p>
<p>
Druhá sekce obsahuje skuteèné tahy partie ve standardní algebraické notaci
(standard algebraic notation, SAN) spoleènì se v¹emi variantami,
<a NAGs>anotaèními symboly</a> a <a Comment>komentáøi</a>.
</p>

<h3>Akce v oknì PGN</h3>
<p>
Okno PGN mù¾ete pou¾ít k navigaci v partii: kliknutím levým tlaèítkem my¹i na
tah skoèíte do pozice po tomto tahu. Kliknutím levým tlaèítkem my¹i na komentáø
spustíte jeho editaci.
Navigaèní klávesy (tj. ¹ipky) (a klávesy <b>v</b> a <b>z</b> pro skok do a z
varianty) umo¾òují navigaci v partii jako v hlavním oknì.
</p>

<h3>Volby zobrazení PGN</h3>
<p>
Menu okna PGN obsahují volby, které ovlivòují vzhled okna PGN. Scid mù¾e
zobrazit partii barevnì nebo jako obyèejný text -- viz menu
<menu>Zobrazit</menu> v oknì PGN.
Barevné zobrazení se snadnìji ète a dovoluje vám výbìr tahù a komentáøù pou¾itím
my¹i, ale je mnohem pomalej¹í na aktualizaci. Pro velmi dlouhé partie budete
mo¾ná chtít zvolit zobrazení jako obyèejný text.
</p>
<p>
Pro vìt¹í èitelnost mù¾ete rovnì¾ zmìnit formát komentáøù a
variant volbou jejich odsazování na nový øádek.
</p>
<p>
Volby zobrazení PGN a velikost okna PGN se ulo¾í do souboru voleb v¾dy, kdy¾
zadáte pøíkaz <b>Ulo¾it volby</b> z menu <menu>Volby</menu> v hlavním oknì.
</p>

<p><footer>(Aktualizováno: Scid 3.1, Prosinec 2001)</footer></p>
}


#######################
### Piece Tracker help:

set helpTitle(C,PTracker) "Stopaø figur"
set helpText(C,PTracker) {<h1>Okno stopaøe figur</h1>
<p>
<term>Stopaø figur</term> je nástroj, který zaznamenává pohyb jednotlivé figury
ve v¹ech partiích v aktuálním filtru a generuje "stopu", která zobrazuje, jak
èasto bylo ka¾dé pole figurou nav¹tíveno.
</p>
<p>
Chcete-li pou¾ít stopaøe figur, nejprve se ujistìte, ¾e filtr obsahuje ty
partie, o které máte zájem, jako napø. partie, ve kterých se vyskytla urèitá
pozice zahájení, nebo v¹echny partie jistého hráèe bílými figurami. Potom
vyberte figuru, kterou chcete stopovat a nastavte dal¹í stopovací volby; jsou
vysvìtleny ní¾e. Pak stisknìte tlaèítko <b>Aktualizovat</b>.
</p>
<p>
Informace o pohybu stopované figury jsou zobrazeny dvìma zpùsoby: grafickou
"stopou" a textovým seznamem s jedním øádkem údajù pro jednotlivé pole.
</p>

<h3>Výbìr stopované figury</h3>
<p>
©achové figury jsou zobrazeny pod grafem stopy na svých poèáteèním pozicích.
Jednotlivou figuru (jako napø. bílého jezdce b1 nebo èerného pì¹ce d7) lze
vybrat levým tlaèítkem my¹i a v¹echny figury stejného typu a barvy (jako napø.
v¹echny bílé pì¹ce nebo obì èerné vì¾e) lze vybrat pravým tlaèítkem my¹i.
</p>

<h3>Ostatní volby stopaøe figur</h3>
<p>
Rozsah tahù urèuje, odkud má zaèít a kde má skonèit stopování v ka¾dé partii.
Implicitní rozsah 1-20 (znamenající konec stopování po 20. tahu èerného) je
vhodný pro studium motivù zahájení, ale (napø.) rozsah jako 15-35 bude lep¹í pro
sledování trendù støední hry.
</p>
<p>
Stopaøem lze generovat dva typy statistik:
<ul>
<li> <b>% games with move to square</b>: zobrazuje podíl partií ve filtru, které
 obsahují
     tah stopované figury na ka¾dé pole. To je implicitní a vìt¹inou
     nejvhodnìj¹í volba.
<li> <b>% time in each square</b>: zobrazuje podíl èasu, který stopovaná
     figura strávila na ka¾dém poli.
</ul>
</p>

<h3>Rady</h3>
<p>
Existují (aspoò) tøi dobrá pou¾ití pro stopaøe figur: pøíprava zahájení, motivy
støední hry a pøíprava na hráèe.
</p>
<p>
Pro pøípravu zahájení pou¾ívejte stopaøe figur spoleènì s otevøeným
<a Tree>stromem</a>. Stopováním figur mù¾ete zjistit trendy v aktuálním zahájení
jako napø. obvyklé postupy pì¹cù, pøedsunuté jezdcové posty a kam se nejèastìji
rozmis»ují støelci. Mù¾ete shledat u¾iteèným nastavit rozsah tahù tak, aby
zaèínal aktuálním tahem partie, tak¾e tahy k dosa¾ení aktuální pozice nebudou ve
statistice zahrnuty.
</p>
<p>
Pro motivy støední hry mù¾e být stopaø figur u¾iteèný tehdy, kdy¾ filtr byl
nastaven tak, ¾e obsahuje urèitý rozsah ECO (pou¾itím
<a Searches Header>Vyhledávání podle hlavièky</a>) nebo i vzor jako napø. bílý
izolovaný dámský pì¹ec (White IQP) (pou¾itím
<a Searches Material>Vyhledávání podle materiálu/vzoru</a>). Nastavte nìjak
vhodnì (napø. 20-40) rozsah tahù a ze "stopy" figur mù¾ete vidìt napø. postupy
pì¹cù v pozdní støední høe nebo rané koncovce.
</p>
<p>
Pro pøípravu na hráèe pou¾ijte <a Searches Header>Vyhledávání podle hlavièky</a>
nebo <a PInfo>Okno informací o hráèi</a>, abyste na¹li v¹echny partie jistého
hráèe jednou barvou. Pak mù¾e být stopaø figur u¾iteèný k vypátrání napø. toho,
jak pravdìpodobnì soupeø fianchetuje støelce, ro¹uje nadlouho nebo staví pì¹cový
klín d5 nebo e5.
</p>

<p><footer>(Aktualizováno: Scid 3.3, Duben 2002)</footer></p>
}


###########################
### Repertoire editor help:

set helpTitle(C,Repertoire) "Editor repertoáru"
set helpText(C,Repertoire) {<h1>Okno editoru repertoáru</h1>
<p>
Editor repertoáru vám umo¾òuje vytvoøit, prohlí¾et a editovat
<term>repertoárové</term> soubory. Repertoárový soubor (.sor) je seznam pozic
zahájení, kterých chcete dosáhnout nebo kterým se chcete vyhnout, a lze ho
pou¾ít ke správì va¹ich preferovaných pozic zahájení a také k vyhledávání v
databázích ve Scidu.
</p>

<h3>Repertoárové skupiny a varianty</h3>
<p>
Repertoár obsahuje dva typy elementù: <term>skupiny</term> a
<term>varianty</term>. Skupiny vlastnì nejsou èástí va¹eho repertoáru; pou¾ívají
se jen k jeho uspoøádání stejnì jako adresáøe k uspoøádání souborù na disku
poèítaèe.
</p>
<p>
Varianty v repertoáru jsou dvou typù: <term>zahrnuté</term> varianty, které
reprezentují pozice zahájení, které vás zajímají a kterých chcete dosáhnout, a
<term>vylouèené</term> varianty, které nemáte zájem hrát a chcete se jim
vyhnout.
Napø. hrajete-li èernýma pøijatý dámský gambit (1.d4 d5 2.c4 dxc4) a po 3.e4
hrajete v¹echny tahy kromì 3...Jf6, budete mít 1.d4 d5 2.c4 dxc4 3.e4 jako
zahrnutou variantu a 1.d4 d5 2.c4 dxc4 3.e4 Nf6 jako vylouèenou variantu.
</p>

<h3>Komentáøe a poznámky</h3>
<p>
Ka¾dá skupina nebo varianta mù¾e mít k sobì pøipojený komentáø. Existují dva
typy: krátké (jednoøádkové) komentáøe jsou zobrazeny (èervenì) v hierarchii
repertoáru vedle tahù skupiny nebo varianty, zatímco dlouhý (víceøádkový)
komentáø se zobrazí, jen kdy¾ je skupina nebo varianta vybrána.
</p>

<h3>Pou¾ití okna editoru repertoáru</h3>
<p>
<b>Levá</b> strana okna zobrazuje hierarchii repertoáru. Kliknutím na ikonu
slo¾ky mù¾ete rozbalit nebo sbalit skupinu a kliknutím na tahy skupiny nebo
varianty ji vybrat a prohlédnout si její komentáø.
Zahrnuté varianty jsou oznaèeny modrou za¹krtávací ikonou a vylouèené varianty
mají èervený køí¾ek.
</p>
<p>
Jestli¾e má varianta nebo skupina krátký komentáø, je zobrazen za tahmi.
Jestli¾e má dlouhý komentáø, je indikován <b><red>**</red></b> za tahmi. Skupiny
mají za svými tahmi v závorkách èíslo, které urèuje poèet variant (zahrnutých
nebo vylouèených), které skupiny obsahují.
</p>
<p>
Kliknutí pravým tlaèítkem my¹i na skupinu nebo variantu vyvolá pro ni menu
funkcí, jako napø. její výmaz nebo zmìnu jejího stavu (zahrnutá/vylouèená).
</p>
<p>
<b>Pravá</b> strana okna obsahuje tøi rámce. První rámec je seznam tahù aktuálnì
vybrané varianty nebo skupiny. Kliknutím levého tlaèítka my¹i na nìj mù¾ete
vlo¾it tyto tahy do okna <a Import>importu</a>, co¾ je u¾iteèné k nastavení
aktuální partie tak, aby zaèínala touto variantou repertoáru.
Druhý rámec obsahuje krátký komentáø k variantì nebo skupinì a tøetí rámec
obsahuje její dlouhý komentáø.
</p>

<h3>Pøidávání skupin a variant do repertoáru</h3>
<p>
Chcete-li do okna pøidat variantu nebo skupinu, udìlejte na ¹achovnici v hlavním
oknì její tahy a pak pou¾itím menu <menu>Editace</menu> v editoru repertoáru ji
pøidejte jako skupinu, zahrnutou variantu nebo vylouèenou variantu.
</p>
<p>
Chcete-li smazat skupinu nebo variantu, kliknìte na ni pravým tlaèítkem my¹i a z
menu, které se objeví, vyberte po¾adovaný pøíkaz.
</p>

<h3><name Search>Vyhledávání v databázích pou¾itím repertoárových
 souborù</name></h3>
<p>
Menu <menu>Hledat</menu> v editoru repertoáru vám umo¾òuje vyhledávat v aktuální
databázi pou¾itím repertoáru. V ka¾dé partii se budou vyhledávat pozice z
repertoáru a partie bude vyhovovat, jen kdy¾ nalezená <i>nejhlub¹í</i>
repertoárová pozice je v <i>zahrnuté</i> variantì.
</p>
<p>
Mù¾ete si zvolit mezi vyhledáváním pou¾itím celého repertoáru nebo pouze
pou¾itím zobrazených variant. Vyhledávání pou¾itím pouze zobrazených variant je
u¾iteèné, kdy¾ chcete pou¾ít jen èást repertoáru. Napø. repertoár mù¾e mít na
nejvy¹¹í úrovni dvì hlavní skupiny, jednu pro 1.e4 a druhou pro 1.d4. Jestli¾e
vás zajímají jen varianty po 1.e4, jednodu¹e sbalte vìtev 1.d4 a potom
vyhledávejte pouze pou¾itím zobrazených variant.
</p>

<h3>Rady navíc</h3>
<p>
Repertoárový soubor je skvìlý pro nalezení nových partií pro vá¹ systém
zahájení. Napø. kdykoliv získáte nový PGN soubor pro pøipojení k va¹í hlavní
databázi (jako napø. vynikající týdenní PGN soubor z
<url http://www.chesscenter.com/twic/>The Week In Chess</url>),
otevøete tento PGN soubor ve Scidu a proveïte repertoárové vyhledávání.
Prohlédnutím filtrovaných partií pak zjistíte v¹echny nové partie, které jsou ve
va¹em repertoáru.
</p>
<p>
Mo¾ná budete chtít mít dva repertoárové soubory: jeden pro èerné a
druhý pro bílé, tak¾e budete moct vyhledávat pou¾itím ka¾dého souboru zvlá¹».
</p>
<p>
Repertoárový soubor lze otevøít z pøíkazové øádky, napø.: <br>
<b>scid mybase white.sor</b>
</p>
<p>
Repertoárový soubor(.sor) mù¾ete editovat v libovolném textovém editoru, buïte
v¹ak opatrní, abyste zachovali jeho formát nebo jinak ho nebude mo¾né natáhnout
nebo pou¾ít k vyhledávání.
</p>

<p><footer>(Aktualizováno: Scid 2.6, Srpen 2001)</footer></p>
}

#####################
### Tree window help:

set helpTitle(C,Tree) "Stromové okno"
set helpText(C,Tree) {<h1>Stromové okno</h1>
<p>
<term>Stromové</term> okno zobrazuje informace o v¹ech tazích zahraných v
aktuální pozici v partiích databáze. Ve stromovém módu je okno stromu
aktualizováno automaticky, kdykoliv se v hlavním oknì zmìní pozice na
¹achovnici. Pro velké databáze to mù¾e být pomalé.
</p>
<p>
V¹imnìte si, ¾e kdykoliv je stromové okno aktualizováno,
<a Searches Filter>filtr</a> je znovu nastaven tak, ¾e zahrnuje jen partie,
které obsahují aktuální pozici.
</p>
<p>
Kliknutí levým tlaèítkem my¹i na tah ve stromovém oknì pøidá tento tah do
partie.
</p>

<h3>Obsah stromového okna</h3>
<p>
Stromové okno zobrazuje <a ECO>ECO kód</a> (je-li nìjaký), frekvenci (jednak
 jako poèet
partií, jednak procento) a skóre ka¾dého tahu.
<term>Skóre</term> je v¾dy poèítáno z perspektivy <b>bílého</b>, tak¾e 100%
znamená samé výhry bílého a 0% znamená samé výhry èerného.
</p>
<p>
Tahy v oknì stromu mohou být øazeny podle tahu (abecednì), ECO kódu, frekvence
nebo skóre. Pou¾itím menu <menu>Øadit</menu> mù¾ete metodu øazení zmìnit.
</p>

<h3><name Best>Okno nejlep¹ích partií</name></h3>
<p>
Stromové okno má tlaèítko a v souborovém menu pøíkaz pro otevøení okna
<term>nejlep¹ích partií</term>, které zobrazuje seznam nejcennìj¹ích partií v
aktuálnì zobrazené vìtvi stromu.
Partie jsou øazeny podle prùmìrného ratingu a tento seznam mù¾ete omezit tak,
aby zobrazoval jen partie s urèitým výsledkem.
</p>

<h3><name Graph>Okno grafu stromu</name></h3>
<p>
Tlaèítka stromového okna zahrnují tlaèítko oznaèené <term>Graf</term>, které
vyvolává grafické zobrazení relativní úspì¹nosti ka¾dého tahu hraného v aktuální
pozici.
Zobrazeny jsou v¹echny tahy, které se hrály nejménì v 1% partií a
nejménì 5 krát.
Procentní skóre jsou v¾dy z perspektivy bílého, i kdy¾ je na
tahu èerný.
</p>
<p>
V grafu stromu je nakreslena èervená èára zobrazující prùmìrnou úspì¹nost ze
v¹ech partií obsahující aktuální pozici a oblast mezi 50 a 55% (kde le¾í
oèekávaná úspì¹nost standardních zahájení) je kvùli snadnìj¹ímu porovnání tahù
zobrazena modøe. V¹imnìte si, ¾e na mistrovské úrovni bílí obyèejnì dosahují
úspì¹nosti okolo 55%.
</p>

<h3><name Lock>Zamknutí okna stromu</name></h3>
<p>
Tlaèítko <term>Zamknout</term> ve stromovém oknì mù¾e být pou¾ito k zamknutí
stromu k aktuální databázi. To znamená, ¾e strom bude nadále pou¾ívat tuto
databázi, i kdy¾ se pøepnete do jiné otevøené databáze. To je u¾iteèné, kdy¾
chcete pou¾ít velkou databázi jako referenèní pøi pøehrávání partie z jiné
databáze: jednodu¹e otevøete strom pro referenèní databázi, zamknìte ho a potom
se pøepnìte do druhé databáze.
</p>

<h3><name Training>Trénink</name></h3>
<p>
Kdy¾ aktivujete tlaèítko <term>Trénink</term>, v¾dy, kdy¾ zahrajete svùj
tah, Scid náhodnì provede tah.
Tah, který Scid zvolí, závisí na databázové statistice tak, ¾e tah zahraný v 80%
partií databáze bude Scidem zvolen s 80% pravdìpodobností.
Dobrým zpùsobem, jak si otestovat znalosti svého repertoáru zahájení, je zapnout
tuto funkci, potom skrýt (nebo minimalizovat) stromové okno a hrát zahájení
proti velké databázi.
</p>

<h3>Pou¾ití stromu s otevøenými EPD soubory</h3>
<p>
Pro ka¾dý otevøený <a EPD>EPD soubor</a> stromové okno obsahuje jeden sloupec
 navíc, který
zobrazuje krátký (pìtiznakový) souhrn obsahu EPD souboru pro ka¾dou pozici,
dosa¾enou tahy v seznamu.
</p>
<p>
Souhrn mù¾e být hodnocení, kód zahájení nebo navr¾ený tah; bude to obsah prvního
EPD pole nalezeného v následujícím seznamu: <b>ce, eco, nic, pv, pm, bm, id</b>
nebo jen první EPD pole, jestli¾e v¹echny z uvedených chybí.
</p>
<p>
Pro popis EPD polí si pøeètìte stránku nápovìdy o <a EPD>EPD souborech</a>.
V¹imnìte si, ¾e jestli¾e je souhrn z <b>ce</b> pole, je zobrazen z dùvodu lep¹í 
èitelnosti jako hodnocení v pì¹cích z perspektivy bílého (radìji ne¾ skóre 
v setinách pì¹cù z perspektivy strany, která je na tahu, jako je jeho vlastní 
formát ulo¾ení v EPD souboru).
</p>

<h3>Pou¾ívání cache pro rychlej¹í výsledky</h3>
<p>
Scid pou¾ívá cache pro stromové vyhledávací výsledky pro pozice, kterým odpovídá
nejvíce partií. Jestli¾e se ve stromovém módu posunete v partii o tah dopøedu a
zpìt, aktualizace okna stromu se provede témìø okam¾itì, jestli¾e vyhledávaná
pozice je v cache.
</p>
<p>
Okno stromu obsahuje v souborovém menu pøíkaz <term>Ulo¾it cache soubor</term>.
Kdy¾ ho zadáte, aktuální obsah stromové cache v pamìti se zapí¹e do souboru (s
pøíponou <b>.stc</b>) a dojde tak ke zrychlení budoucího pou¾ití této databáze
ve stromovém módu.
</p>
<p>
Pøíkaz <term>Naplnit cache soubor</term> v souborovém menu okna
stromu naplní cache soubor údaji pro mnoho pozic zahájení.
Provede se stromové vyhledávání pro asi 100 nejbì¾nìj¹ích pozic zahájení a poté
se ulo¾í cache soubor.
</p>
<p>
Uvìdomte si, ¾e stromový cache (.stc) soubor je celý nadbyteèný; mù¾ete
ho smazat bez toho, aby jste ovlivnili danou databázi, a ve skuteènosti je
Scidem smazán v¾dy, kdy¾ se objeví operace, po které by zùstal neaktuální --
napø. pøidání nebo nahrazení partie nebo tøídìní databáze.
</p>

<p><footer>(Aktualizováno: Scid 3.0, Listopad 2001)</footer></p>
}



####################
### Compaction help:

set helpTitle(C,Compact) "Kompaktování databáze"
set helpText(C,Compact) {<h1>Kompaktování databáze</h1>
<p>
<term>Kompaktování</term> databáze je specifický typ <a Maintenance>údr¾by</a>,
kterým se databáze uchovává co mo¾ná nejmen¹í a nejvýkonnìj¹í.
Kompaktování databáze znamená odstranìní v¹echno nevyu¾itého prostoru v jejích
souborech.
Existují dva druhy kompaktování: jmenného souboru a partiového
souboru.
</p>

<h3>Kompaktování jmenného souboru</h3>
<p>
Èasem mo¾ná zjistíte, ¾e databáze zaèíná obsahovat mno¾ství jmen hráèù, turnajù,
míst a kol, která u¾ nejsou v ¾ádné partii pou¾ita. To se èasto stane po
kontrole pravopisu jmen. Nepou¾itá jména v jmenném souboru zbyteènì zabírají
místo a mohou zpomalit vyhledávání podle jmen.
Kompaktování jmenného souboru odstraní v¹echny jména, která nejsou pou¾ita v
¾ádné partii.
</p>

<h3>Kompaktování partiového souboru</h3>
<p>
Kdykoliv je partie nahrazena nebo smazána, zùstane v partiovém souboru
(nejvìt¹í ze tøí souborù tvoøící databázi Scidu) zbyteènì volné místo.
Kompaktování partiového souboru odstraní v¹echno zbyteènì volné místo, nesmazané
partie ponechá v databázi. Uvìdomte si, ¾e tato operace je nevratná: po
kompaktování jsou smazané partie nav¾dy pryè!
</p>
<p>
Kompaktování partiového souboru se doporuèuje také po <a Sorting>tøídìní</a>
databáze, aby se udr¾el stav partiového souboru konzistentní se setøídìným
indexovým souborem.
</p>

<p><footer>(Aktualizováno: Scid 2.5, Èerven 2001)</footer></p>
}


####################################
### Database maintenance tools help:

set helpTitle(C,Maintenance) "Údr¾ba databáze"
set helpText(C,Maintenance) {<h1>Údr¾ba databáze</h1>
<p>
Scid poskytuje mno¾ství nástrojù pro údr¾bu databáze, jsou dostupné z menu Scidu
<a Menus File>Soubor</a>. <a Compact>Kompaktování</a> databáze a
<a Sorting>tøídící</a> funkce jsou vysvìtleny na samostatných stránkách
nápovìdy.
</p>

<h3>Okno údr¾by</h3>
<p>
Vìt¹inu údr¾by databáze ve formátu Scidu lze provést z okna údr¾by, které mù¾ete
otevøít z menu <menu>Soubor: Údr¾ba</menu> nebo z menu <menu>Okna</menu> nebo
pou¾itím klávesové zkratky <b>Ctrl+M</b>.
</p>
<p>
Toto okno mù¾ete pou¾ít k údr¾bì <a Flags>pøíznakù partií</a>, kontrole
pravopisu jmen, <a Compact>kompaktování</a> nebo <a Sorting>tøídìní</a>
databáze. V¹imnìte si, ¾e v¹echny operace, které nejsou pro aktuální databázi
dostupné (napø. proto¾e je jen ke ètení nebo je PGN soubor), budou zobrazeny
¹edou barvou.
</p>

<h3><name Twins>Mazání zdvojených partií</name></h3>
<p>
Menu <menu>Soubor: Údr¾ba</menu> obsahuje pøíkaz
<menu>Vymazání zdvojených partií...</menu> pro detekci dal¹ích kopií (dvojníkù)
partií v databázi.
Tento pøíkaz nalezne v¹echny páry partií, které jsou dvojníky, a pro ka¾dý pár
nastaví pøíznak krat¹í partie na smazaný a pøíznak del¹í partie ponechá na
nesmazaný.
Dvì partie jsou pokládány za dvojníky, jestli¾e se jejich hráèi (a libovolné
jiné speciální oznaèení, které mù¾ete volitelnì specifikovat) pøesnì shodují.
</p>
<p>
Jestli¾e specifikujete volbu "tyté¾ tahy", ka¾dý pár partií musí mít stejné
aktuální tahy a¾ do délky krat¹í partie (nebo do 60. tahu kterékoliv), aby byli
partie pokládány za dvojníky.
</p>
<p>
Jestli¾e jste provedli mazání dvojníkù, je dobrou my¹lenkou ovìøit si, jestli¾e
ka¾dá smazaná partie je opravdu kopií druhé partie.
To mù¾ete jednodu¹e provést, jestli¾e v dialogovém oknì mazání zdvojených partií
vyberete volbu "<b>Nastavit filtr na v¹echny vymazané zdvojené partie</b>".
Filtr budu potom obsahovat v¹echny smazané partie.
Mù¾ete si je prohlédnout (pou¾itím kláves <b>p</b> a <b>n</b>) pou¾itím okna
<term>kontroly zdvojených partií</term> (dostupné z menu údr¾by nebo pou¾itím
klávesové zkratky <b>Ctrl+Shift+T</b>) a ovìøit si, ¾e partie jsou smazané,
proto¾e jsou skuteènì dvojníky jiné partie.
</p>

<h3><name Editing>Editace jmen hráèù, turnajù, míst a kol</name></h3>
<p>
Ve va¹í databázi mù¾ete najít ¹patnì napsaná jména a chcete je opravit.
To mù¾ete provést ve Scidu pou¾itím okna <term>editoru jmen</term> (klávesová
zkratka: <b>Control+Shift+N</b>), dostupného z podmenu
<menu>Soubor: Údr¾ba</menu>.
</p>
<p>
Ka¾dé jedineèné jméno je ulo¾eno v jmenném souboru jen jednou,
tak¾e jeho zmìna vlastnì zmìní v¹echny jeho výskyty.
</p>

<h3><name Spellcheck>Kontrola pravopisu jmen</name></h3>
<p>
Scid se distribuuje spoleènì se souborem <term>pro kontrolu pravopisu</term>
pojmenovaném <b>spelling.ssp</b>, pou¾ívaným pro opravu jmen hráèù, turnajù,
míst a kol.
Scid se pokou¹í nahrát soubor pro kontrolu pravopisu pøi ka¾dém startu; jestli¾e
se nenatáhne, mù¾ete ho natáhnout z menu <menu>Volby</menu>.
</p>
<p>
Kdy¾ u¾ je soubor pro kontrolu pravopisu nata¾en, mù¾ete ho pou¾ít pro databáze
ve formátu Scidu prostøednictvím pøíkazù pro kontrolu pravopisu v menu
<menu>Soubor: Údr¾ba</menu> nebo z okna údr¾by.
</p>
<p>
Kdy¾ kontrolujete pravopis jmen databáze, Scid produkuje seznam korekcí, které
mù¾ete pøed jejich vlastním provedením editovat, tak¾e mù¾ete odstranit v¹echny
korekce, které provést nechcete.
</p>
<p>
Kontrola pravopisu je zvlá¹» u¾iteèná pro standardizaci databáze, aby v¹echny
pøíklady jednotlivého jména mìli stejný tvar.
Napø. se standardním souborem pro kontrolu pravopisu by byla jména "Kramnik,V.",
"Vladimir Kramnik", and "V. Kramnik" opravena na "Kramnik, Vladimir".
</p>
<p>
Soubor pro kontrolu pravopisu má jedno pou¾ití navíc: kdy¾ je nata¾en, jeho
údaje o hráèích jsou pou¾ity k roz¹íøení okna <a PInfo>informací o hráèi</a> a
 okna
<a Crosstable>turnajové tabulky</a>: pro ka¾dého hráèe obsa¾eného v souboru pro
kontrolu pravopisu uvidíte jeho mistrovský titul FIDE (<b>gm</b> = mezinárodní
velmistr, <b>im</b> = mezinárodní mistr atd.) a jeho zemi. Soubor
<b>spelling.ssp</b>, distribuovaný spoleènì se Scidem, obsahuje pøes 6500
silných hráèù minulosti a pøítomnosti.
</p>

<h3><name Ratings>Pøidání Elo ratingù do partií</name></h3>
<p>
Tlaèítko "Pøidat Elo ratingy..." v oknì údr¾by zpùsobí, ¾e Scid vyhledá v
aktuální databázi partie, v kterých hráè nemá rating, ale soubor pro kontrolu
pravopisu jeho rating k datu partie obsahuje. Scid v¹echny takové ratingy
automaticky pøidá. To je velmi u¾iteèné pro databáze mistrovských partií, které
mají málo ratingù.
</p>
<p>
Soubor pro kontrolu pravopisu "spelling.ssp", dodávaný spoleènì se Scidem,
neobsahuje informace o Elo ratingách potøebných pro tuto funkci, ale jeho vìt¹í
verze s názvem "ratings.ssp" je dostupná na <a Author>webové stránce Scidu</a>.
</p>

<h3><name Cleaner>Èi¹tìní databáze</name></h3>
<p>
<term>Èi¹tìní databáze</term> (dostupné z okna údr¾by) je nástroj pro vykonávání
více operací údr¾by databáze naráz. Mù¾ete si vybrat, které operace chcete
provést, a Scid je s aktuální databází provede bez nutnosti u¾ivatelského
zásahu. To je zvlá¹» u¾iteèné pro údr¾bu velkých databází.
</p>

<h3>Výbìr automaticky otevírané partie</h3>
<p>
<term>Automaticky otevíraná</term> partie databáze je partie, která se
automaticky natáhne pøi ka¾dém otevøení databáze. Chcete-li zmìnit automaticky
otevíranou partii databáze, pou¾ijte tlaèítko  "Automaticky otevírat partii
èíslo...". Jestli¾e chcete, aby se natáhla v¾dy poslední partie databáze (bez
ohledu na skuteèný poèet partií v databázi), nastavte ji na velmi vysoké èíslo
napø. 9999999.
</p>

<p><footer>(Aktualizováno: Scid 3.1, Prosinec 2001)</footer></p>
}

#################
### Sorting help:

set helpTitle(C,Sorting) "Tøídìní databáze"
set helpText(C,Sorting) {<h1>Tøídìní databáze</h1>
<p>
<term>Tøídící</term> funkce tøídí v¹echny partie v databázi. Mù¾ete si vybrat
mno¾ství tøídících kritérií.
Kdy¾ jsou dvì partie rovnocenné podle prvního kritéria, jsou setøídìny podle
druhého kritéria atd. </p>

<h3>Tøídící kritéria</h3>
<p>
Dostupná tøídící kritéria jsou:
</p>
<ul>
<li> Datum (nejstar¹í partie první)
<li> Rok (stejné jako datum, ale pou¾ije se jen rok)
<li> Jméno turnaje
<li> Jméno místa
<li> Zemì (poslední 3 písmena jména místa)
<li> Jméno kola
<li> Jméno bílého
<li> Rating (prùmìr ratingu bílého a èerného, nejvy¹¹í první)
<li> Jméno èerného
<li> Výsledek (výhry bílého, remízy a pak výhry èerného)
<li> Délka (poèet kompletních tahù v partii)
<li> ECO (<a ECO>kód Encyklopedie ¹achových zahájení</a>)
</ul>

<h3>Výsledky tøídìní</h3>
<p>
Kdy¾ tøídíte databázi Scidu, která není jen ke ètení, výsledky tøídìní jsou
ulo¾eny, tak¾e poøadí partií v databázi je trvale zmìnìno. Jestli¾e chcete, aby
setøídìní bylo jen doèasné, pou¾itím pøíkazu menu <b>Soubor: Pouze pro ètení</b>
nastavte nejprve databázi jen ke ètení.
</p>
<p>
Kdy¾ tøídíte databázi, která je jen ke ètení nebo je skuteènì PGN soubor,
výsledky tøídìní nemohou být ulo¾eny, tak¾e po zavøení souboru bude setøídìné
poøadí partií ztraceno.
</p>
<p>
V¹imnìte si, ¾e tøídìní databáze znovu nastaví
<a Searches Filter>vyhledávací filtr</a> tak, ¾e obsahuje v¹echny partie.
</p>

<h3>Dùle¾itá poznámka k tøídìní databází:</h3>
<p>
Pøi tøídìní databáze je zmìnìn indexový soubor, ale partiový soubor nikoliv. To
znamená, ¾e tøídìní databáze zanechá záznamy v partiovém souboru pomíchané
vzhledem k indexovému souboru. To mù¾e významnì <b>zpomalit</b> <a
 Tree>stromová</a>
vyhledávání, <a Searches>vyhledávání</a> podle pozice a podle materiálu/vzoru,
 tak¾e abyste
udr¾eli dobré vyhledávací výsledky, mìli byste po setøídìní databáze
reorganizovat partiový soubor jeho <a Compact>kompaktováním</a>.
</p>

<p><footer>(Aktualizováno: Scid 2.5, Èerven 2001)</footer></p>
}

###############
### Flags help:

set helpTitle(C,Flags) "Pøíznaky partie"
set helpText(C,Flags) {<h1>Pøíznaky partie</h1>
<p>
<term>Pøíznak</term> je indikátor nìjakých ¹achových charakteristik, který mù¾e
být zapnutý nebo vypnutý pro ka¾dou partii v databázi.
Ve Scidu existuje 13 u¾ivatel nastavitelných pøíznakù, které mù¾ete pøímo
nastavit pro ka¾dou partii. Z nich jen mazací pøíznak má speciální význam:
partie se zapnutým mazacím pøíznakem jsou oznaèeny k výmazu a pøi
<a Compact>kompaktování</a> databáze budou odstranìny.
</p>
<p>
12 ostatních u¾ivatelem nastavitelných pøíznakù a jejich symboly jsou:
</p>

<ul>
<li>Zahájení bílého (W)</li>
<li>Zahájení èerného (B)</li>
<li>Støední hra (M)</li>
<li>Koncovka (E)</li>
<li>Novinka (N)</li>
<li>Pì¹cová struktura (P)</li>
<li>Taktika (T)</li>
<li>Hra na dámském køídle (Q)</li>
<li>Hra na královské køídle (K)</li>
<li>Brilantní (!)</li>
<li>Hrubka (?)</li>
<li>U¾ivatel (U)</li>
</ul>

<p>
Pøíznak mù¾e být nastaven pro aktuální partii, pro v¹echny partie filtru nebo
pro v¹echny partie databáze pou¾itím okna <a Maintenance>údr¾by</a>.
</p>
<p>
Mù¾ete pou¾ít <a Searches Header>vyhledávání podle hlavièky</a> pro nalezení
v¹ech partií v databázi, které mají konkrétní pøíznak zapnutý nebo vypnutý, nebo
pou¾ít pøíznaky jako èást komplexnìj¹ích vyhledávání.
</p>
<p>
Proto¾e v¹echny u¾ivatelem nastavitelné pøíznaky (kromì mazacího pøíznaku)
nemají pro Scid ¾ádný význam, mù¾ete je pou¾ívat pro jakýkoliv úèel, vhodný pro
va¹e potøeby. Napø. mù¾ete pou¾ít pøíznak hry na královském køídle (K) pro
pì¹cové útoky na královské køídle nebo pro útok na královském køídle tì¾kými
figurami nebo dokonce pro koncovky se v¹emi pì¹ci na královském køídle.
</p>

<p><footer>(Aktualizováno: Scid 3.0, Listopad 2001)</footer></p>
}

#########################
### Analysis window help:

set helpTitle(C,Analysis) "Analytické okno"
set helpText(C,Analysis) {<h1>Analytické okno</h1>
<p>
Analytické okno ve Scidu zobrazuje analýzu ¹achového programu
(oznaèovaného jako <term>motor</term>) souèasné pozice na ¹achovnici. Pøi ka¾dé
zmìnì na ¹achovnici posílá Scid motoru novou pozici a zobrazuje jeho hodnocení
této pozice.
</p>
<p>
Skóre zobrazené v tomto analytickém oknì je v¾dy z perspektivy
bílého, tak¾e negativní skóre indikuje lep¹í pozici èerného.
Spodní rámec v tomto oknì (s posuvníkem) zobrazuje historii hodnocení této
pozice produkovaná motorem, tak¾e si mù¾ete prohlídnout, jak se hodnocení
mìnila.
</p>
<p>
Chcete-li pøidat nejlep¹í tah vybraný motorem jako nový tah aktuální partie,
stisknìte tlaèítko <b>Pøidat tah</b>.
</p>

<h3><name List>Seznam analytických motorù</name></h3>
<p>
Scid si udr¾uje seznam pou¾ívaných motorù, spolu s odhadem jejich Elo ratingu
(jestli nìjaký máte) a datem jejich posledního pou¾ití. Seznam motorù lze
setøídit podle jména, Elo ratingu nebo data.
Chcete-li do seznamu pøidat nový motor nebo editovat detaily existujícího
motoru, stisknìte tlaèítko <b>Nový</b> nebo <b>Editace</b>.
</p>

<h3><name Start>Pøíkazy a adresáøe motorù</name></h3>
<p>
Pro ka¾dý motor musíte specifikovat jeho spustitelný soubor a adresáø, kde má
být Scidem spu¹tìn.
</p>
<p>
Dùvodem vìt¹iny problémù se startem motorù je výbìr adresáøe, v kterém má být
motor spu¹tìn. Nìkteré motory vy¾adují ke svému øádnému startu ve svém
startovacím adresáøi existenci inicializaèního souboru nebo souboru knihoven
zahájení.
Jiné motory (jako Crafty) zapisují do adresáøe, kde byly spu¹tìny, tzv. logovací
soubory, tak¾e je nutné je spustit v takových adresáøích, kde máte pøístupové
právo zápisu.
Jestli¾e nastavení adresáøe pro motor je ".", Scid nastartuje tento motor v
aktuálním adresáøi.
</p>
<p>
Tak¾e jestli¾e nìjaký motor, který by mìl ve Scidu skvìle pracovat, nelze
nastartovat, zkuste zmìnit nastavení jeho adresáøe. Chcete-li zabránit vzniku
logovacích souborù v mnoha rùzných adresáøích, doporuèuji vám spou¹tìt motory v
adresáøi u¾ivatelských souborù Scidu (tj. tam, kde se nachází soubor
<b>scid.exe</b> pro Windows nebo v adresáøi <b>~/.scid/</b> pro Unix); v
dialogovém oknì pro editaci detailù motoru je tlaèítko oznaèené
<b>scid.exe dir</b> pro Windows nebo <b>~/.scid</b> pro Unix, kterým mù¾ete
nastavit spou¹tìní motoru v tomto adresáøi.
</p>

<h3>Trénink</h3>
<p>
Tlaèítkem <b>Trénink</b> mù¾ete proti analytickému motoru hrát. Èas na ka¾dý tah
je pevnì daný a v tréninkovém módu nejsou zobrazeny výsledky analýzy.
</p>

<h3>Anotace partie</h3>
<p>
Tlaèítko <b>Pøidat variantu</b> v analytickém oknì pøidá do partie aktuální
skóre a nejlep¹í pokraèování za obì strany jako novou variantu.
</p>
<p>
Anotaci série tahù (i celé partie) mù¾ete provést automaticky stiskem tlaèítka
<b>Anotace</b>. Budete dotázáni na urèitá nastavení anotace a potom se spustí
re¾im automatického pøehrávání.
V re¾imu automatického pøehrávání pøi otevøeném analytickém oknì je pro ka¾dou
pozici (pøehranou v automatickém re¾imu) samoèinnì pøidána varianta obsahující
skóre a nejlep¹í pokraèování za obì strany.
Anotovány jsou pouze pozice od aktuální pozice do konce partie (nebo dokud
neukonèíte re¾im automatického pøehrávání), tak¾e pøesunem do pozice ze støední
hry pøed spu¹tìním re¾imu automatického pøehrávání mù¾ete pøeskoèit anotaci
zahájení.
</p>
<p>
Chcete-li kdykoliv anotaci ukonèit, staèí jen ukonèit re¾im automatického
pøehrávání, napø. stiskem klávesy <b>Escape</b> v hlavním oknì.
</p>
<p>
V¹imnìte si, ¾e pro zjednodu¹ení je tlaèítko <b>Anotace</b> pøístupné jen v oknì
analytického motoru 1. Jestli¾e spustíte motor jako analytický motor 2, nebudete
ho moci pou¾ít k anotaci partie.
</p>

<h3>Analytická ¹achovnice</h3>
<p>
Stisk tlaèítka ikony ¹achovnice v analytickém oknì zobrazí nebo skryje
analytickou ¹achovnici, která zobrazuje pozici na konci aktuálnì nejlep¹í
varianty hry nalezenou motorem. Funguje to pro vìt¹inu motorù kompatibilních se
Scidem, ale nemusí pro v¹echny; zále¾í to na tom, jakou notaci tahù motor
pou¾ívá.
</p>

<h3>Priorita motoru</h3>
<p>
Jestli¾e motor vyu¾ívá pøíli¹ mnoho èasu CPU (tj. procesoru) a negativnì
tak ovlivòuje pou¾ívání Scidu nebo jiných aplikací, mù¾e pomoct zapnutí
tlaèítka <b>Nízká CPU priorita</b>; tím dáte motoru nízkou prioritu pøi
plánování CPU. </p>

<h3>Detaily rozhraní</h3>
<p>
Abyste mohli pou¾ívat analytické okno, budete potøebovat ¹achový program, který
podporuje <term>WinBoard/Xboard</term> protokol.
</p>
<p>
Scid posílá motoru pøi jeho startu pøíkazy <b>xboard</b>, <b>post</b> a
<b>protover 2</b> a jestli¾e motor svou odpovìdí indikuje, ¾e je podporuje, Scid
pou¾ije pro efektivnìj¹í komunikaci s motorem pøíkazy <b>setboard</b> a
<b>analyze</b>.
Jestli¾e motor nepodporuje pøíkaz <b>setboard</b>, nebude schopen poskytovat
analýzu ¾ádné partie, která zaèíná s nestandardní poèáteèní pozicí.
</p>
<p>
Programùm, které nepodporují pøíkaz <b>analyze</b>, Scid pøi ka¾dé zmìnì pozice
posílá následující pøíkazy: <b>new</b> a <b>force</b>, tím se pøesune do partie
do aktuální pozice a pak <b>go</b>.
</p>
<p>
Já pou¾ívám a doporuèuji pro analytické okno Scidu znamenitý ¹achový freeware
program <term>Crafty</term> od Boba Hyatta, ale se Scidem bylo úspì¹nì pou¾ito
mnoho dal¹ích WinBoard nebo XBoard kompatibilních programù. Ní¾e je seznam
webových stránek pro sta¾ení nìkolika motorù.
</p>
<p>
Crafty:
<url ftp://ftp.cis.uab.edu/pub/hyatt/>ftp://ftp.cis.uab.edu/pub/hyatt/</url>
</p>
<p>
Yace:
<url http://home1.stofanet.dk/moq/>http://home1.stofanet.dk/moq/</url>
</p>
<p>
Phalanx:
<url
 ftp://ftp.math.muni.cz/pub/math/people/Dobes/>ftp://ftp.math.muni.cz/pub/math/people/Dobes/</url>
</p>
<p>
Comet:
<url
 http://members.aol.com/utuerke/comet/>http://members.aol.com/utuerke/comet/</url>
</p>
<p>
Gnuchess:
<url
 http://www.gnu.org/software/chess/chess.html>http://www.gnu.org/software/chess/chess.html</url>
</p>
<p>
The Crazy Bishop:
<url http://remi.coulom.free.fr/>http://remi.coulom.free.fr/</url>
</p>

<p><footer>(Aktualizováno: Scid 3.4, Záøí 2002)</footer></p>
}

###################
### EPD files help:

set helpTitle(C,EPD) "EPD soubory"
set helpText(C,EPD) {<h1>EPD soubory</h1>
<p>
EPD (extended position description, tj. roz¹íøený popisovaè pozice) soubor je
kolekce pozic, kde ka¾dá pozice má nìjaký doprovodný text. Jako <a PGN>PGN</a>,
je to obecný standard pro ¹achové informace.
</p>
<p>
EPD soubor má poèet definovaných <term>opkódù (opcodes)</term> (polí), které
jsou ulo¾eny v souboru oddìleny støedníkem(<b>;</b>), ale v oknì EPD Scidu jsou
kvùli jednodu¹í editaci zobrazeny na samostatných øádcích.
Støedník uvnitø EPD pole je ulo¾en Scidem jako "<b>\s</b>", aby byl odli¹en od
znaku konce pole.
Ka¾dá pozice a k ní asociované opkódy jsou ulo¾eny na jedné øádce v EPD
souboru.
</p>
<p>
Standardní EPD opkódy zahrnují:
<ul>
<li> <b>acd</b> analytický poèet: hloubka vyhledávání.</li>
<li> <b>acn</b> analytický poèet: poèet uzlù (nodes) vyhledávání.</li>
<li> <b>acs</b> analytický poèet: doba vyhledávání v sekundách.</li>
<li> <b>bm</b> nejlep¹í tahy: tah(y) ocenìný(é) nejlépe z nìjakého dùvodu.</li>
<li> <b>ce</b> setinopì¹cové hodnocení: hodnocení v setinách pì¹cù z perspektivy
     <b>strany, která je na tahu</b> -- v¹imnìte si rozdílu proti oknu analýzy,
     které zobrazuje hodnocení v pì¹cích z perspektivy bílého.</li>
<li> <b>cX</b> komentáø (kde <b>X</b> je èíslo, 0-9).</li>
<li> <b>eco</b> kód zahájení podle <a ECO>ECO</a> systému.</li>
<li> <b>id</b> jedineèná identifikace pro tuto pozici.</li>
<li> <b>nic</b> kód zahájení podle <i>New In Chess</i> systému.</li>
<li> <b>pm</b> pøedpokládaný tah: první tah PV.</li>
<li> <b>pv</b> pøedpokládaná varianta: varianta nejlep¹í hry.</li>
</ul>

<p>
EPD soubory mají mnoho pou¾ití: Scid pou¾ívá EPD soubor ke klasifikaci partií
podle systému <a ECO>Encyklopedie ¹achových zahájení</a> (Encyclopedia of Chess
Openings, ECO) a vy sami si mù¾ete vytvoøit EPD soubor pro vá¹ repertoár
zahájení pøidáním komentáøù k pozicím, které se ve va¹ich partiích pravidelnì
vyskytují.
</p>
<p>
Vytvoøit nový EPD soubor nebo otevøít u¾ existující mù¾ete pøíkazy
<menu>Nový</menu> a <menu>Otevøít</menu> z menu <menu>Soubor</menu>. Kdykoliv
mù¾e být otevøeno nejvý¹e ètyøi EPD soubory.
</p>

<h3>EPD okna</h3>
<p>
Pro ka¾dý otevøený EPD soubor uvidíte jedno okno, které zobrazuje text k
aktuální pozici. Chcete-li ulo¾it zmìny v textu k pozici, není potøeba
stisknout tlaèítko Ulo¾it; text bude ulo¾en v¾dy, kdy¾ se pøesunete k jiné
pozici v partii.
</p>

<h3>Navigace v EPD souborech</h3>
<p>
Chcete-li si prohlédnout pozice v EPD souboru, pou¾ijte pøíkazy
<menu>Next position</menu> a <menu>Previous position</menu> z menu
<menu>Tools</menu> v EPD oknì nebo pou¾ijte klávesové zkratky
<b>Ctrl+©ipkaDolù</b> a <b>Ctrl+©ipkaNahoru</b>.
Tyto pøíkazy zpùsobí pøesun na následující/pøedcházející pozici v souboru spolu
s odstranìním aktuální partie a nastavením její poèáteèní pozice.
</p>

<h3>Odstranìní EPD polí</h3>
<p>
EPD soubory, které naleznete na Internetu, mohou obsahovat pole, která vás
nezajímají a mohou tak zbyteènì zabírat mnoho místa v souboru.
Napø. EPD soubor hodnocení ¹achového programu mù¾e mít pole ce, acd, acn, pm, pv
a id, ale mo¾ná budete potøebovat jen pole ce a pv.
</p>
<p>
EPD opkód mù¾ete odstranit ze v¹ech pozic v EPD souboru pou¾itím pøíkazu
<menu>Strip out EPD field</menu> z menu <menu>Tools</menu> v EPD oknì.
</p>

<h3>Stavová li¹ta EPD okna</h3>
<p>
Stavová li¹ta ka¾dého EPD okna ukazuje:
<ul>
<li>- status souboru (<b>--</b> znamená nezmìnìn, <b>XX</b> znamená zmìnìn
      a <b>%%</b> znamená jen ke ètení); </li>
<li>- jméno souboru; </li>
<li>- poèet pozic v souboru; </li>
<li>- legální tahy z aktuální pozici vedoucí do jiné pozice v tomto EPD
      souboru.</li>
</ul>

<p><footer>(Aktualizováno: Scid 2.5, Èerven 2001)</footer></p>
}

######################
### Email window help:

set helpTitle(C,Email) "Emailové okno"
set helpText(C,Email) {<h1>Emailové okno</h1>
<p>
Okno emailového mana¾era Scidu vám poskytuje prostøedky ke správì
korespondenèních partií hraných emailem.
Jestli¾e nehrajete ¹achy pøes email, nebude vás to zajímat.
Ale jestli¾e hrajete korespondenèní partie pøes email, mù¾ete emailové zprávy
posílat pøímo ze Scidu!
</p>
<p>
Pou¾ití emailového mana¾era:
<ul>
<li><b>1)</b> Vytvoøte v databázi partii(e) pro va¹eho soupeøe. </li>
<li><b>2)</b> V oknì emailového mana¾era zvolte <b>Add</b> a zadejte údaje o
va¹em soupeøi: jméno, emailová adresa a èísla partií v databázi. </li>
<li><b>3)</b> V emailovém oknì zvolte <b>Send email</b> v¾dy, kdy¾ jste pøidali
tahy do partie(í) a chcete odeslat zprávu. </li>
</ul>

<p>
Pøi odeslání emailové zprávy Scid vygeneruje zprávu s partií v PGN formátu
<b>bez</b> jakýchkoliv komentáøù, anotací a variant, proto¾e obvykle nebudete
chtít, aby soupeø vidìl va¹e analýzy.
Pøed odesláním mù¾ete zprávu editovat pøidáním podmínìných tahù nebo jiného
textu.
</p>
<p>
Pro ka¾dého soupeøe mù¾ete mít libovolný poèet partií; nejèastìji jednu nebo
dvì. Uvìdomte si, ¾e Scid nekontroluje zmìny èísel partií, tak¾e po zadaní údajù
o va¹em soupeøi dávejte pozor, abyste databázi va¹ich emailových partií
netøídili ani v ní nemazali ¾ádné partie, proto¾e tak by do¹lo k pøeuspoøádání
partií a èísla partií pro ka¾dého soupeøe by byla ¹patná.
</p>

<h3>Omezení</h3>
<p>
Scid dosud nedisponuje ¾ádnou funkcí kontroly va¹ich emailových poøadaèù, tak¾e
je stále nutné pøidávat tahy va¹eho soupeøe do partie manuálnì.</p>

<h3>Konfigurace</h3>
<p>
Kopie v¹ech emailových zpráv odeslaných Scidem je ulo¾ena v souboru
<b>~/.scid/scidmail.log</b>. Jestli¾e chcete, aby byly ulo¾eny v jiném souboru,
budete muset editovat soubor <b>tcl/start.tcl</b> a rekompilovat Scid.
</p>
<p>
Scid mù¾e posílat zprávy pou¾itím SMTP serveru nebo pøíkazu sendmail. Ke
specifikaci va¹í volby pou¾ijte tlaèítko <b>Settings</b> v oknì emailového
mana¾era.
</p>
<p>
Scid ukládá údaje o soupeøích z databáze va¹ich emailových partií v
souboru se stejným jménem jako tato databáze a pøíponou "<b>.sem</b>".
</p>

<p><footer>(Aktualizováno: Scid 3.0, Listopad 2001)</footer></p>
}

########################
### Reports help:

set helpTitle(C,Reports) "Profily"
set helpText(C,Reports) {<h1>Profily</h1>
<p>
<term>Profil</term> ve Scidu je dokument obsahující informace o urèité pozici nebo urèitém hráèi. Existují dva typy profilù, které mù¾e Scid generovat: profil zahájení a profil hráèe.
</p>

<h3><name Opening>Profily zahájení</name></h3>
<p>
Scid mù¾e vytvoøit <term>profil zahájení</term>, který zobrazuje zajímavé
informace o pozici zahájení. Chcete-li vytvoøit profil zahájení, nejprve se
ujistìte, ¾e zobrazená pozice je ta, pro kterou profil chcete, a potom zvolte
<b>Profil zahájení</b> z menu <b>Nástroje</b>.
</p>
<p>
Okno <term>profilu zahájení</term> zobrazuje výsledek profilu vygenerovaného
Scidem. Menu <b>Soubor</b> obsahuje pøíkazy pro ulo¾ení (vyti¹tìní) profilu do
textového souboru, do HTML souboru nebo <a LaTeX>LaTeX</a> souboru.
</p>
<p>
První sekce profilu prezentují informace na partiích, které dosáhly pozice
profilu, a na tazích hraných od této pozice. Lze zde vidìt, jestli se zahájení
stává více populárním, jestli má mnoho krátkých remíz a jaká poøadí tahù
(transpozice) se pou¾ívají k její dosa¾ení.
</p>
<p>
Sekce pozièních témat zobrazuje  frekvenci urèitých bì¾ných pozièních témat v profilovaných partiích. K tomu se pou¾ije prvních 20 tahù ka¾dé partie (tedy prvních 40 pozicí ka¾dé partie po poèáteèní pozici). Partie se zapoète jako partie obsahující urèité téma, jestli¾e obsahuje dané téma alespoò ve 4 pozicích v prvních 20 tazích partie. Tak se zabrání ovlivnìní výsledku krátkým výskytem témat (jako napø. izolovaný dámský pì¹ec, který je okam¾itì vzatý).
</p>
<p>
Poslední a nejvìt¹í èástí profilu je tabulka teorie. Pøi ukládání profilu do
souboru si mù¾ete vybrat mezi ulo¾ením jen tabulky teorie, kompaktním profilem
bez tabulky teorie nebo celým profilem.
</p>
<p>
Skoro v¹echny sekce profilu mohou být zapnuty nebo vypnuty nebo upraveny
prostøednictvím voleb profilu zahájení, tak¾e si mù¾ete profil pøizpùsobit
tak, aby zobrazoval jen informace, které vás zajímají.
</p>
<p>
Vìt¹ina informací v profilu zahájení, které jsou zobrazeny barevnì, vyvolají
pøi výbìru levým tlaèítkem my¹i nìjakou akci. Napøíklad pøi kliknutí na
referenci partie dojde k její nata¾ení, pøi kliknutí na pozièní motiv dojde k
nastavení filtru tak, ¾e bude obsahovat jen partie profilu, ve kterých se tento
motiv vyskytl.
</p>

<h4>Oblíbené</h4>
<p>
Menu <menu>Oblíbené</menu> v oknì profilu umo¾òuje udr¾ovat sbírku oblíbených pozic profilu zahájení a jednodu¹e generovat profil zahájení pro v¹echny tyto pozice. Výbìrem "Add Report..." z menu Oblíbené pøidáte aktuální pozici jako oblíbenou profilovanou pozici; budete vyzváni k zadání jména, které bude pou¾ito jako jméno souboru pøi generování oblíbených profilù.
</p>
<p>
Chcete-li generovat profil pro ka¾dý oblíbený profil pøi pou¾ití aktuální databáze, zvolte z menu Oblíbené "Generovat profil...". Objeví se dialogové okno, které Vám umo¾ní specifikovat typ a formát profilu a adresáø, kde budou ulo¾eny soubory profilù. Podle formátu, který jste zvolili, bude ke ka¾dému souboru profilu pøidána vhodná pøípona (napø. ".html" pro HTML formát).
</p>

<h3><name Player>Profily hráèù</name></h3>
<p>
<term>Profil hráèe</term> je velmi podobný profilu zahájení, ale obsahuje informace o partiích jednoho hráèe bílými nebo èernými figurami. Profil hráèe mù¾ete generovat z menu Nástroje nebo z okna <a PInfo>Informací o hráèi</a>.
</p>
<p>
Profil hráèe mù¾e být generován buï pro v¹echny partie daného hráèe danými figurami nebo jen pro podmno¾inu tìch partií, které dosáhly aktuální pozici na ¹achovnici v hlavním oknì.
</p>


<h3>Omezení</h3>
<p>
Pro vìt¹inu dat generovaných profilem existuje limit 2000 partií, tak¾e
jestli¾e se pozice profilu vyskytuje ve více ne¾ 2000 partiích, nìjaké výsledky
mohou být trochu nesprávné.
</p>
<p>
Rovnì¾ pro tabulku teorie existuje limit 500 partií. Jestli¾e se pozice profilu
vyskytuje ve více ne¾ 500 partiích, jen 500 partií s nejvy¹¹ím prùmìrným Elo
ratingem se pou¾ije ke generování tabulky teorie. Poèet partií pou¾itých ke
generování tabulky teorie mù¾ete upravit ve volbách Profilu zahájení.
</p>

<p><footer>(Aktualizováno: Scid 3.5, Únor 2003)</footer></p>
}


#####################
### Player List help:

set helpTitle(C,PList) "Okno vyhledávaèe hráèù"
set helpText(C,PList) {<h1>Okno vyhledávaèe hráèù</h1>
<p>
Okno <term> vyhledávaèe hráèù</term> zobrazuje seznam jmen
hráèù v aktuální databázi. Výbìrem hráèe se otevøe okno
<a PInfo>informací o hráèi</a> s podrobnìj¹ími informacemi o tomto hráèi.
</p>
<p>
Zobrazuje se pìt sloupcù, které zobrazují jméno ka¾dého hráèe, jeho nejvy¹¹í
rating, poèet jeho partií a rok jeho nejstar¹í a nejnovìj¹í partie.
Chcete-li setøídit seznam podle nìkterého sloupce, kliknìte na jeho titulek
nahoøe v seznamu.
</p>
<p>
Obsah seznamu mù¾ete filtrovat pomocí ovládání dole pod seznamem. Mù¾ete zmìnit
limit seznamu, zadat bez ohledu na velikost písmen pøedponu jména hráèe (jako
tøeba "ada" pro vyhledání "Adams") a omezit rozsah Elo ratingu a poètu partií.
</p>

<p><footer>(Aktualizováno: Scid 3.4, Èervenec 2002)</footer></p>
}

#####################
### Player Info help:

set helpTitle(C,PInfo) "Okno informací o hráèi"
set helpText(C,PInfo) {<h1>Okno informací o hráèi</h1>
<p>
Okno <term>informací o hráèi</term> se otevøe nebo aktualizuje v¾dy, kdy¾
kliknete levým tlaèítkem my¹i na jméno hráèe v informaèní zónì partie (pod
¹achovnicí) nebo v oknì <a Crosstable>turnajové tabulky</a>.
</p>
<p>
Okno zobrazuje (doufám) u¾iteèné informace o hráèi, zejména jejich úspì¹nost
bílýma a èernýma, oblíbená zahájení (podle <a ECO>kódu ECO</a>) a historii
ratingu.
</p>
<p>
V¹echna zobrazená procenta jsou oèekávaný výsledek (míra úspì¹nosti) z
perspektivy hráèe -- tak¾e vy¹¹í procento je v¾dy lep¹í pro hráèe, nezávisle na
tom, je-li bílý èi èerný.
</p>
<p>
Stiskem tlaèítka <a Graphs Rating>Graf ratingu</a> mù¾ete vidìt graf historie
ratingu hráèe.
</p>
<p>
Kliknutím levým tlaèítkem my¹i na libovolné èervené èíslo nastavíte
<a Searches Filter>filtr</a> na ty partie, které dané èíslo reprezentuje.
</p>

<p><footer>(Aktualizováno: Scid 2.5, Èerven 2001)</footer></p>
}

################
### Graphs help:

set helpTitle(C,Graphs) "Okna grafù"
set helpText(C,Graphs) {<h1>Okna grafù</h1>
<p>
Scid má nìkolik oken, která zobrazují informace graficky.
Jsou vysvìtleny ní¾e.
</p>

<h3><name Filter>Okno grafu filtru</name></h3>
<p>
Okno <term>grafu filtru</term> zobrazuje trendy partií v aktuálním filtru ve
srovnání s celou databází, a to podle podle data nebo podle Elo ratingu. Napø.
kdy¾ máte otevøený <a Tree>strom</a>, okno grafu je u¾iteèné jako nástroj
zobrazující, jak se mìnila popularita aktuální pozice zahájení v posledních
letech nebo dekádách nebo jestli je zvlá¹tì oblíbená mezi hráèi s vìt¹ím
ratingem jako velmistry.
Ka¾dý bod grafu reprezentuje pro jednotlivý rozsah data nebo Elo ratingu poèet
partií ve filtru na 1000 partií v celé databázi.
</p>
<p>
Pøi kreslení grafu filtru podle ratingu, Scid pou¾ívá pro ka¾dou partii prùmìrný
(støední) rating. Odhady ratingù (jako napø. ty z pravopisného souboru) se
nepou¾ijí. Jestli¾e jeden hráè partie rating má, ale jeho soupeø nikoliv, pak se
a¾ do hranice 2200 Elo pøedpokládá, ¾e soupeø má stejný rating.
Napø. jestli¾e jeden hráè má 2500 Elo a soupeø nemá ¾ádný rating, støední rating
je (2500+2200)/2=2350.
</p>

<h3><name Rating>Okno grafu ratingu</name></h3>
<p>
Okno <term>grafu ratingu</term> zobrazuje historii ratingu jednoho nebo obou
hráèù aktuální partie.
Pro jednoho hráèe mù¾ete graf vyvolat stiskem tlaèítka <b>Graf ratingu</b> v
oknì <a PInfo>informací o hráèi</a> nebo pro oba hráèe aktuální partie výbìrem
<b>Graf ratingu</b> z menu <menu>Nástroje</menu>.
</p>

<h3><name Score>Okno grafu skóre</name></h3>
<p>
Okno <term>grafu skóre</term> zobrazuje numerická hodnocení (skóre) ulo¾ená v
komentáøích aktuální partie jako graf.
Kliknutím levým tlaèítkem my¹i kdekoliv v grafu skóre se mù¾ete dostat do
korespondující pozice partie.
</p>
<p>
Jsou rozeznávány dva druhy hodnotících komentáøù: ty, které produkuje
<a Analysis>analytické</a> okno Scidu (které mají formát
<ul>
<li><b>1.e4 {"+0.25 ...."}</b></li>
</ul>
a jsou brány v¾dy z perspektivy bílého) a ty, které jsou produkovány Craftyho
anotaèním pøíkazem (které mají formát
<ul>
<li><b>1.e4 ({9:+0.25} ....)</b></li>
</ul>
a jsou rovnì¾ brány v¾dy z perspektivy bílého).
</p>

<h3><name Tree>Okno grafu stromu</name></h3>
<p>
Okno <term>grafu stromu</term> je dostupné ze stromového okna. Zobrazuje
úspì¹nost nejpopulárnìj¹ích tahù v aktuální pozici. Více informací naleznete na
stránce nápovìdy <a Tree Graph>stromu</a>.
</p>

<p><footer>(Aktualizováno: Scid 3.3, Duben 2002)</footer></p>
}

####################
### Tablebases help:

set helpTitle(C,TB) "Tabulky koncovek"
set helpText(C,TB) {<h1>Tabulky koncovek</h1>

<p>
<term>Tabulka koncovek</term> (tablebase) je soubor obsahující  pøesné informace
o výsledku v¹ech pozic s urèitým materiálem, jako napø. král a vì¾ proti králi a
pì¹ci. Byly generovány tabulky v¹ech koncovek s materiálem a¾ do pìti kamenù
(bráno i s králi) a jsou rovnì¾ k dispozici i nìkteré ¹estikamenové tabulky
koncovek.
</p>
<p>
Scid mù¾e pou¾ívat tabulky koncovek v Nalimovovì formátu, které vyu¾ívají mnohé
moderních ¹achové motory. Tyto tabulky vìt¹inou konèí pøíponou <b>.nbw.emd</b>
nebo <b>.nbb.emd</b>. Ve Scidu mohou být pou¾ity v¹echny 3, 4 a 5 kamenové
Nalimovovy tabulky koncovek.
</p>

<h3>Pou¾ití tabulek koncovek ve Scidu</h3>
<p>
Chcete-li pou¾ívat ve Scidu tabulky koncovek, staèí nastavit jejich adresáø
výbìrem <b>Adresáø pro tabulky koncovek ...</b> z menu <menu>Volby</menu>.
Mù¾ete vybrat a¾ 4 adresáøe, kde jsou va¹e tabulky koncovek ulo¾eny.
Stiskem tlaèítka <b>...</b> napravo mù¾ete vybrat soubor a tím urèit, ¾e má být
pou¾it adresáø tohoto souboru.
</p>
<p>
Kdy¾ dosáhnete pozice, která je nalezená v souboru tabulky koncovek, informaèní
zóna partie (pod ¹achovnicí) zobrazí informace z tabulky. Mno¾ství zobrazených
informací mù¾ete konfigurovat kliknutím pravého tlaèítka my¹i v této zónì nebo
výbìrem <b>Informace o partii</b> z menu <menu>Volby</menu>. Volba "výsledek a
nejlep¹í tahy" dává neju¾iteènìj¹í informace, ale je velmi èasto pomalej¹í ne¾
volba "jen výsledek".
</p>

<h3>Okno tabulky koncovek</h3>
<p>
Z tabulky koncovek mù¾ete získat je¹tì více informací o aktuální pozici
otevøením <term>okna tabulky koncovek</term> (menu <menu>Okna</menu>, klávesová
zkratka: Ctrl+=). Toto okno zobrazuje výsledek s precizní hrou na v¹echny mo¾né
tahy v aktuální pozici.
</p>
<p>
Toto okno má dvì hlavní èásti. Souhrnný rámec (nalevo) zobrazuje, které tabulky
koncovek Scid nalezl na va¹em poèítaèi a pøehled pro ka¾dou tabulku. Výsledkový
rámec (napravo) zobrazuje optimální výsledky pro v¹echny tahy v aktuální pozici
v hlavním oknì.
</p>

<h4>Souhrnný rámec</h4>
<p>
Horní èást souhrnného rámce vám umo¾òuje výbìr konkrétní tabulky koncovek.
Tabulky, které máte k dispozici, jsou zobrazeny modøe a ty, které jsou
nedostupné, jsou zobrazeny ¹edì, ale mù¾ete vybrat libovolnou tabulku.
Dolní èást souhrnného rámce zobrazuje pøehled informací pro zvolenou tabulku
koncovek. (Je¹tì ne v¹echny tabulky mají ve Scidu ulo¾en pøehled).
</p>
<p>
Pøehled zahrnuje frekvenci (poèet partií na milión, které dosáhly pozice s tímto
materiálem, spoèteno z databáze témìø 600,000 mistrovských partií), nejdel¹í mat
za obì strany a poèet vzájemných (nebo "reciproèních") zugzwangù. Vzájemný
zugwang je taková pozice, kde bílý pøi svém tahu remizuje a èerný pøi svém tahu
prohraje nebo kde ta strana, která je na tahu, prohrává.
</p>
<p>
Pro nìkteré tabulky koncovek se vzájemnými zugzwangy pøehled zahrnuje také výèet
v¹ech zugzwangových pozic nebo jejich výbìr. Úplný výèet pro ka¾dou tabulku
koncovek není proveditelný, proto¾e nìkteré tabulky mají tisíce vzájemných
zugzwangù.
</p>
<p>
Stiskem tlaèítka <b>Random</b> mù¾ete nastavit náhodnou pozici ze zvolené
tabulky koncovek.
</p>

<h4>Výsledkový rámec</h4>
<p>
Výsledkový rámec je aktualizován kdykoliv se zmìní pozice na ¹achovnici v
hlavním oknì. První øádek ukazuje kolik tahù vyhrává (+), remizuje (=), prohrává
(-) nebo má neznámý výsledek(?). Zbytek rámce udává podrobnìj¹í seznam výsledkù,
v poøadí od nejkrat¹ích k nejdel¹ím výhrám, potom remízy a  nakonec od
nejdel¹ích k nejkrat¹ím prohrám. V¹echny vzdálenosti jsou poèítány k matu.
</p>

<h4>Výsledková ¹achovnice</h4>
<p>
V pozici obsa¾ené v tabulkách koncovek je èasto u¾iteèné, jaký by byl výsledek,
kdyby v¹echny kameny v aktuální pozici byly na svých souèasných místech, ale
pozice jedné urèité figury by byla jiná.
Napø. mù¾ete chtít rozhodnout, jak blízko musí být král k volnému pì¹ci, aby
urèitá pozice byla vyhraná nebo remízová. V knihách koncovek je tato informace
èasto nazývána jako <i>vítìzná zóna</i> nebo <i>remízová zóna</i> figury v
pozici.
</p>
<p>
Tuto informaci mù¾ete zjistit ve Scidu stiskem tlaèítka s obrázkem
¹achovnice, v oknì tabulky koncovek se poté zobrazí
<term>výsledková ¹achovnice</term>.
Stisknete-li levé tlaèítko my¹i na kterékoliv figuøe na této ¹achovnici, na
ka¾dém prázdném poli se nakreslí symbol urèující jaký by byl výsledek (pøi tahu
stejné strany jako v pozici v hlavním oknì), kdyby vybraná figura byla na
takovém poli.
</p>
<p>
Je pìt druhù symbolù, které pole mù¾e mít:
bílý <b>#</b> znamená výhru bílého;
èerný <b>#</b> znamená výhru èerného;
modrý <b>=</b> znamená, ¾e pozice je remízová;
èervený <b>X</b> znamená, ¾e pozice je ilegální (kvùli sousedícím králùm nebo
proto¾e strana na tahu dává ¹ach); a
èervený <b>?</b> znamená, ¾e výsledek není znám, proto¾e potøebný soubor tabulek
koncovek není k dispozici.
</p>

<h3>Obstarání souborù tabulek koncovek</h3>
<p>
Pro pomoc ohlednì vyhledání souborù tabulek koncovek na internetu ètìte
<a Author Related>pøíbuzné odkazy</a>.
</p>

<p><footer>(Aktualizováno: Scid 3.4, Záøí 2002)</footer></p>
}

###################
### Bookmarks help:

set helpTitle(C,Bookmarks) "Zálo¾ky"
set helpText(C,Bookmarks) {<h1>Zálo¾ky</h1>
<p>
Scid vám umo¾òuje pro snadný budoucí pøístup pou¾ít pro dùle¾ité partie
<term>zálo¾ky</term>. Menu zálo¾ek je dostupné z menu <menu>Soubor</menu>, z
nástrojové li¹ty nebo prostøednictvím klávesové zkratky <B>Ctrl+B</b>.
</p>
<p>
Kdy¾ z menu Zálo¾ky vyberete zalo¾enou partii, Scid, jestli¾e je to nutné,
otevøe její databázi, nalezne tuto partii a pøesune se do té pozice v partii, v
které byla zalo¾ena.
</p>
<p>
Zálo¾ky mohou být pou¾ity jen pro databáze ve formátu Scidu (ne pro PGN soubory
nebo pro databázi schránka).
</p>
<p>
Pøi tøídìní nebo kompaktování databáze obsahující zalo¾enou partii se detaily
zálo¾ky mohou stát zastaralými. Kdy¾ se tak stane, pøi výbìru takové zálo¾ky
Scid vyhledá v databázi nejlépe odpovídající partii (srovnáním jmen hráèù,
místa, atd.), tak¾e zalo¾ená partie by mìla i tak být nata¾ena. Av¹ak jestli¾e
se zmìní detaily zalo¾ené partie, je mo¾né, ¾e detailùm zálo¾ky bude lépe
odpovídat jiná partie a bude nata¾ena místo ní. Tak¾e je dobrou my¹lenkou znovu
zalo¾it partii, jestli¾e edituje její hráèe, místo, výsledek, kolo nebo rok.
</p>

<h3>Editace zálo¾ek</h3>
<p>
Pomocí editoru zálo¾ek mù¾ete zmìnit text menu zobrazený pro ka¾dou zalo¾enou
partii a pøidat slo¾ku ke kategorizaci zálo¾ek.
</p>

<h3>Rady</h3>
<p>
Zálo¾ky mù¾ete pou¾ívat pro rychlý pøístup k databázím, které èasto pou¾íváte, a
to tak, ¾e z ka¾dé databáze si zalo¾íte partii. Dal¹ím dobrým pou¾itím zálo¾ek
je pøidávání dùle¾itých partií pøi studiu jednotlivých ¹achových zahájení.
</p>
<p>
Menu zálo¾ek obsahuje polo¾ku pro kontrolu zobrazování slo¾ek zálo¾ek: mohou být
zobrazovány jako podmenu (u¾iteèné pøi velkém poètu zálo¾ek) nebo jako jediný
seznam.
</p>

<p><footer>(Aktualizováno: Scid 3.0, Listopad 2001)</footer></p>
}

##############################
### Command-line options help:

set helpTitle(C,Cmdline) "Volby pøíkazového øádku"
set helpText(C,Cmdline) {<h1>Volby pøíkazového øádku</h1>
<p>
Kdy¾ spou¹títe Scid z shellu nebo z konsole, mù¾ete specifikovat rùzné volby
pøíkazového øádku. Mù¾ete zadat databázi ve formátu Scidu (s nebo bez pøípony
souboru jako napø. ".si3") a PGN soubor, které se mají otevøít, napø. pøíkaz:
<ul>
<li>scid mybase newgames.pgn</li>
</ul>
spustí Scid a otevøe databázi Scidu pojmenovanou mybase a PGN soubor pojmenovaný
newgames.pgn.
</p>
<p>
Jsou zde také volitelné argumenty slou¾ící ke kontrole souborù, které má Scid
prohledat a pou¾ít pøi svém startu. Volbou <b>-xtb</b> (nebo <b>-xt</b>) mù¾ete
vypnout pou¾ívání <a TB>tabulek koncovek</a>, volbou <b>-xeco</b> nebo
<b>-xe</b> mù¾ete zru¹it natahování souboru
<a ECO>klasifikace zahájení ECO</a> a volbou <b>-xspell</b> nebo <b>-xs</b>
mù¾ete zru¹it natahování <a Maintenance Spellcheck>pravopisného souboru</a>.
Zároveò existuje volba <b>-fast</b> nebo <b>-f</b>, která dìlá v¹echno, co tøi
pøedchozí volby dohromady, tak¾e pøíkaz <b>scid -f</b> je ekvivalentní pøíkazu
<b>scid -xeco -xspell -xtb</b>.
</p>

<p><footer>(Aktualizováno: Scid 3.1, Listopad 2001)</footer></p>
}

#################
### Pgnscid help:

set helpTitle(C,Pgnscid) "Pgnscid"
set helpText(C,Pgnscid) {<h1>Pgnscid</h1>
<p>
<term>Pgnscid</term> je separátní program, který je potøeba ke konverzi PGN
(portable game notation) souborù na databáze Scidu.
</p>
<p>
Chcete-li zkonvertovat soubor pojmenovaný <i>myfile.pgn</i>, jednodu¹e zadejte:
<ul>
<li> <b>pgnscid myfile.pgn</b> </li>
</ul>
a databáze Scidu (skládající se z <i>myfile.si3</i>, <i>myfile.sg3</i>
a <i>myfile.sn3</i>) bude vytvoøena.
Ve¹keré chyby a varování budou zapsány do souboru <i>myfile.err</i>.
</p>
<p>
Chcete-li, aby databáze byla vytvoøena v jiném adresáøi nebo mìla jiné jméno,
mù¾ete jméno databáze pøidat do pøíkazového øádku, napø.:
<ul>
<li> <b>pgnscid myfile.pgn mybase</b> </li>
</ul>
vytvoøí databázi skládající se ze souborù <i>mybase.si3</i>,
<i>mybase.sg3</i> a <i>mybase.sn3</i>.
</p>
<p>
V¹imnìte si, ¾e pgnscid (a scid) mù¾e èíst PGN soubory komprimované Gzipem
(t.j. <b>mybase.pgn.gz</b>) pøímo, tak¾e máte-li velký PGN soubor k u¹etøení
místa komprimovaný Gzipem, není potøeba ho nejprve dekomprimovat.
</p>

<h3>Volby</h3>
<p>
Pgnscid akceptuje pøed jménem souboru dva volitelné parametry: <b>-f</b> a
<b>-x</b>.
</p>
<p>
Pou¾itím parametru <b>-f</b> dojde k násilnému pøepsaní existující databáze;
implicitnì pgnscid neprovede konverzi na databázi, která u¾ existuje.
</p>
<p>
Parametr <b>-x</b> zpùsobí, ¾e pgnscid bude ignorovat v¹echen text mezi
partiemi.
Implicitnì je text mezi partiemi ulo¾en jako pøedpartiový komentáø k partii,
která následuje. Tato volba ovlivòuje jen text mezi partiemi; standardní
komentáøe uvnitø ka¾dé partie jsou i tak zkonvertovány a ulo¾eny.
</p>

<h3>Formátování jmen hráèù</h3>
<p>
Aby se zredukoval poèet vícenásobného pravopisu jmen, která odkazují na stejného
hráèe, pgnscid provádí nìkterá základní formátování jmen hráèù. Napø. poèet
mezer za ka¾dou èárkou je standardizován na jednu, v¹echny mezery na zaèátku a
na konci jména jsou odstranìny a teèka na konci jména je odstranìna.
Holandské pøedpony jako "van den" a "Van Der" jsou rovnì¾ normalizovány tak, ¾e
mají velké písmeno V a malé d.
</p>
<p>
Jména hráèù, turnajù, míst a kol lze ve Scidu editovat (a dokonce kontrolovat
jejich pravopis); detaily najdete na stránce nápovìdy
<a Maintenance Editing>Údr¾ba</a>.
</p>

<p><footer>(Aktualizováno: Scid 2.5, Èerven 2001)</footer></p>
}


######################
### File formats help:

set helpTitle(C,Formats) "Formáty souborù"
set helpText(C,Formats) {<h1>Formáty souborù Scidu</h1>
<p>
Databáze Scidu se skládají ze tøí základních souborù: Indexový soubor, Jmenný
soubor a Partiový soubor. V¹echny mají dvoupísmennou pøíponu zaèínající na "s":
".si" pro indexové (index) soubory, ".sn" pro jmenné (name) soubory a ".sg" pro
partiové (game) soubory.
</p>

<h3>Indexový (.si) soubor</h3>
<p>
Tento soubor obsahuje popis databáze a malý záznam pevné velikosti pro ka¾dou
partii. Souèasná velikost je 41 bytù na partii. 28 bytù z této velikosti jsou
základní informace jako napø. výsledek, datum, identifikaèní èísla jmen hráèù,
turnaje, místa (skuteèná jména jsou v Jmenném souboru), atd.
</p>
<p>
Zbývajících 13 bytù obsahuje nadbyteèné, ale u¾iteèné informace o partii, které
se pou¾ívají k urychlení vyhledávání podle pozice, materiálu a vzoru. Pro více
informací ètìte ní¾e sekci <a Formats Fast>Rychlá vyhledávání</a>.
</p>

<h3>Jmenný (.sn) soubor</h3>
<p>
Tento soubor obsahuje v¹echny jména hráèù, turnajù, míst a kol pou¾itých v
databázi. Ka¾dé jméno je ulo¾eno jen jednou, i kdy¾ se vyskytuje ve více
partiích. Jmenný soubor je obvykle nejmen¹í ze tøí základních souborù v
databázi.
</p>

<h3>Partiový (.sg) soubor</h3>
<p>
Tento soubor obsahuje skuteèné tahy, varianty a komentáøe ka¾dé partie.
Formát kódování tahù je velmi úsporný: vìt¹ina tahù zabírá pouze jeden byte
místa.
</p>
<p>
Kdy¾ je partie nahrazena, je její nová verze ulo¾ena na <i>konec</i> partiového
souboru, tak¾e èasem mù¾e dojít k nahromadìní zbyteènì nepou¾itého místa.
Databázi mù¾ete navrátit do její minimální velikosti jejím
<a Compact>kompaktováním</a>.
</p>

<h3>Ostatní soubory Scidu</h3>
<p>
<a EPD>EPD</a> soubor (pøípona: ".epd") obsahuje mno¾ství ¹achových pozicí,
ka¾dou s textovým komentáøem.
Formát EPD souboru je popsán v <a Author Related>PGN standardu</a>.
</p>
<p>
V emailovém (pøípona: ".sem") souboru pro databázi jsou ulo¾eny detaily
oponentù, kterým posíláte emailové zprávy.
</p>
<p>
Soubor vyhledávacích voleb (pøípona: ".sso") obsahuje nastavení pro vyhledávání
podle <a Searches Header>hlavièky</a> nebo podle
<a Searches Material>materiálu/vzoru</a>.
</p>

<h3><name Fast>Rychlá vyhledávání ve Scidu</name></h3>
<p>
Jak bylo øeèeno vý¹e, indexový soubor uchovává nìkteré nadbyteèné, ale u¾iteèné
informace o ka¾dé partii za úèelem urychlení vyhledávání podle pozice nebo podle
materiálu.
</p>
<p>
Napø. je ulo¾en materiál koneèné pozice. Jestli¾e hledáte vì¾ové a pì¹cové
koncovky, pak v¹echny partie, které konèí s dámou, støelcem nebo jezdcem na
¹achovnici (a nemají ¾ádné promìny pì¹cù) budou rychle pøeskoèeny.
</p>
<p>
Dal¹í u¾iteèná informace, která je ulo¾ena, je poøadí, s jakou pì¹ci opou¹tìjí
svá poèáteèní postavení (buï svým tahem nebo vzetím). To se pou¾ije k urychlení
stromových vyhledávání nebo vyhledávání podle pøesné pozice, zvlá¹tì pak pro
pozice zahájení. Napø. hledáte-li poèáteèní pozici francouzské obrany (1.e4 e6),
ka¾dá partie zaèínající 1.e4 c5 nebo 1.d4 atd. bude pøeskoèena, ale partie
zaèínající 1.e4 e5 bude tøeba je¹tì prohledat.
</p>

<p><footer>(Aktualizováno: Scid 2.5, Èerven 2001)</footer></p>
}

###########################
### Options and Fonts help:

set helpTitle(C,Options) "Volby"
set helpText(C,Options) {<h1>Volby a preference</h1>
<p>
Mnoho voleb a preferencí Scidu (jako napø. velikost ¹achovnice, barvy, fonty a
implicitní nastavení) mù¾ete nastavit v menu <menu>Volby</menu>.
Kdy¾ z menu Volby zvolíte <b>Ulo¾it volby</b>, tato nastavení (a je¹tì dal¹í,
jako napø. poslední adresáø, z kterého se natáhla databáze a velikosti nìkterých
oken) jsou ulo¾eny do souboru voleb.
Tento soubor voleb se naète pøi ka¾dém spu¹tìní Scidu.
</p>
<p>
Jestli¾e pou¾íváte Windows, soubor voleb je <b>scid.opt</b> v adresáøi, kde se
nachází spustitelný soubor Scidu <b>scid.exe</b>. Pro u¾ivatele unixových
operaèních  systémù (jako napø. Solaris nebo Linux) je soubor voleb
<b>~/.scid/scidrc</b>.
</p>

<h3><name MyPlayerNames>Nastavení jmen va¹ich hráèù</name></h3>
<p>
Mù¾e být takové jméno hráèe (nebo nìkolik jmen), pro které byste chtìli, aby kdykoliv se natáhne jeho partie, ¹achovnice v hlavním oknì byla zobrazena z perspektivy tohoto hráèe. Pou¾itím <b>Jména mých hráèù...</b> z menu <menu>Volby/©achovnice</menu> mù¾ete konfigurovat seznam takových jmen. V dialogovém oknì, které se objeví, zadejte na ka¾dý øádek jedno jméno hráèe. Zástupné znaky ("<b>?</b>" pro pøesnì jeden znak a "<b>*</b>" pro sekvenci nula nebo více znakù) mohou být pou¾ity.
</p>

<h3><name Fonts>Nastavení fontù</name></h3>
<p>
Scid má tøi základní fonty, které pou¾ívá ve vìt¹inì svých oken, a v¹echny z
nich si mù¾ete pøizpùsobit. Nazývají se <b>základní</b>, <b>malé</b> a
<b>fixní</b>.
</p>
<p>
Fixní font musí mít pevnou ¹íøku fontu (neproporcionální). Pou¾ívá se pro okna
<a Tree>stromu</a> a <a Crosstable>turnajové tabulky</a>.
</p>

<p><footer>(Aktualizováno: Scid 3.5, Únor 2003)</footer></p>
}

####################
### NAG values help:

set helpTitle(C,NAGs) "NAG hodnoty"
set helpText(C,NAGs) {<h1>Standardní NAG hodnoty</h1>
<p>
Standardní NAG (Numeric Annotation Glyph, tj. numerický anotaèní piktograf)
hodnoty definované v <a Author Related>PGN standardu</a> jsou:
</p>
<cyan>
<ul>
<li>  1   silný tah (!) </li>
<li>  2   ¹patný tah (?) </li>
<li>  3   velmi silný tah (!!) </li>
<li>  4   hrubá chyba (??) </li>
<li>  5   zajímavý tah (!?) </li>
<li>  6   pochybný tah (?!) </li>
<li>  7   vynucený tah </li>
<li>  8   jediný tah; ¾ádné rozumné alternativy </li>
<li>  9   nejhor¹í tah </li>
<li> 10   remízová pozice (=) </li>
<li> 11   vyrovnané ¹ance, klidná pozice (=) </li>
<li> 12   vyrovnané ¹ance, ¾ivá pozice (=) </li>
<li> 13   nejasná pozice (~) </li>
<li> 14   bílý má malou výhodu (+=) </li>
<li> 15   èerný má malou výhodu (=+) </li>
<li> 16   bílý má výhodu (+/-) </li>
<li> 17   èerný má výhodu (-/+) </li>
<li> 18   bílý má rozhodující výhodu (+-) </li>
<li> 19   èerný má rozhodující výhodu (-+) </li>
<li> 20   bílý má drtivou výhodu (+-) </li>
<li> 21   èerný má drtivou výhodu (-+) </li>
<li> 22   bílý je v nevýhodì tahu (zugzwang) </li>
<li> 23   èerný je v nevýhodì tahu (zugzwang) </li>
<li> 24   bílý má malou prostorovou pøevahu </li>
<li> 25   èerný má malou prostorovou pøevahu </li>
<li> 26   bílý má prostorovou pøevahu </li>
<li> 27   èerný má prostorovou pøevahu </li>
<li> 28   bílý má rozhodující prostorovou pøevahu </li>
<li> 29   èerný má rozhodující prostorovou pøevahu </li>
<li> 30   bílý má malý náskok ve vývinu </li>
<li> 31   èerný má malý náskok ve vývinu </li>
<li> 32   bílý má náskok ve vývinu </li>
<li> 33   èerný má náskok ve vývinu </li>
<li> 34   bílý má rozhodující náskok ve vývinu </li>
<li> 35   èerný má rozhodující náskok ve vývinu </li>
<li> 36   bílý má iniciativu </li>
<li> 37   èerný má iniciativu </li>
<li> 38   bílý má trvalou iniciativu </li>
<li> 39   èerný má trvalou iniciativu </li>
<li> 40   bílý má útok </li>
<li> 41   èerný má útok </li>
<li> 42   bílý má nedostateènou kompenzaci za materiální újmu </li>
<li> 43   èerný má nedostateènou kompenzaci za materiální újmu </li>
<li> 44   bílý má dostateènou kompenzaci za materiální újmu </li>
<li> 45   èerný má dostateènou kompenzaci za materiální újmu </li>
<li> 46   bílý má více ne¾ adekvátní kompenzaci za materiální újmu </li>
<li> 47   èerný má více ne¾ adekvátní kompenzaci za materiální újmu </li>
<li> 48   bílý s malou výhodou kontroluje centrum </li>
<li> 49   èerný s malou výhodou kontroluje centrum </li>
<li> 50   bílý s výhodou kontroluje centrum </li>
<li> 51   èerný s výhodou kontroluje centrum </li>
<li> 52   bílý s rozhodující výhodou kontroluje centrum </li>
<li> 53   èerný s rozhodující výhodou kontroluje centrum </li>
<li> 54   bílý s malou výhodou kontroluje královské køídlo </li>
<li> 55   èerný s malou výhodou kontroluje královské køídlo </li>
<li> 56   bílý s výhodou kontroluje královské køídlo </li>
<li> 57   èerný s výhodou kontroluje královské køídlo </li>
<li> 58   bílý s rozhodující výhodou kontroluje královské køídlo </li>
<li> 59   èerný s rozhodující výhodou kontroluje královské køídlo </li>
<li> 60   bílý s malou výhodou kontroluje dámské køídlo </li>
<li> 61   èerný s malou výhodou kontroluje dámské køídlo </li>
<li> 62   bílý s výhodou kontroluje dámské køídlo </li>
<li> 63   èerný s výhodou kontroluje dámské køídlo </li>
<li> 64   bílý s rozhodující výhodou kontroluje dámské køídlo </li>
<li> 65   èerný s rozhodující výhodou kontroluje dámské køídlo </li>
<li> 66   bílý má slabou první øadu </li>
<li> 67   èerný má slabou první øadu </li>
<li> 68   bílý má dobøe chránìnou první øadu </li>
<li> 69   èerný má dobøe chránìnou první øadu </li>
<li> 70   bílý má ¹patnì chránìného krále </li>
<li> 71   èerný má ¹patnì chránìného krále </li>
<li> 72   bílý má dobøe chránìného krále </li>
<li> 73   èerný má dobøe chránìného krále </li>
<li> 74   bílý má ¹patnì postaveného krále </li>
<li> 75   èerný má slabì postaveného krále </li>
<li> 76   bílý má dobøe postaveného krále </li>
<li> 77   èerný má dobøe postaveného krále </li>
<li> 78   bílý má velmi ¹patnou pì¹covou strukturu </li>
<li> 79   èerný má velmi ¹patnou pì¹covou strukturu </li>
<li> 80   bílý má ¹patnou pì¹covou strukturu </li>
<li> 81   èerný má ¹patnou pì¹covou strukturu </li>
<li> 82   bílý má dobrou pì¹covou strukturu </li>
<li> 83   èerný má dobrou pì¹covou strukturu </li>
<li> 84   bílý má velmi dobrou pì¹covou strukturu </li>
<li> 85   èerný má velmi dobrou pì¹covou strukturu </li>
<li> 86   bílý má ¹patnì postaveného jezdce </li>
<li> 87   èerný má ¹patnì postaveného jezdce </li>
<li> 88   bílý má dobøe postaveného jezdce </li>
<li> 89   èerný má dobøe postaveného jezdce </li>
<li> 90   bílý má ¹patnì postaveného støelce </li>
<li> 91   èerný má ¹patnì postaveného støelce </li>
<li> 92   bílý má dobøe postaveného støelce </li>
<li> 93   èerný má dobøe postaveného støelce </li>
<li> 94   bílý má ¹patnì postavenou vì¾ </li>
<li> 95   èerný má ¹patnì postavenou vì¾ </li>
<li> 96   bílý má dobøe postavenou vì¾ </li>
<li> 97   èerný má dobøe postavenou vì¾ </li>
<li> 98   bílý má ¹patnì postavenou dámu </li>
<li> 99   èerný má ¹patnì postavenou dámu </li>
<li>100   bílý má dobøe postavenou dámu </li>
<li>101   èerný má dobøe postavenou dámu </li>
<li>102   bílý má ¹patnou souhru figur </li>
<li>103   èerný má ¹patnou souhru figur </li>
<li>104   bílý má dobrou souhru figur </li>
<li>105   èerný má dobrou souhru figur </li>
<li>106   bílý sehrál zahájení velmi slabì </li>
<li>107   èerný sehrál zahájení velmi slabì </li>
<li>108   bílý sehrál zahájení slabì </li>
<li>109   èerný sehrál zahájení slabì </li>
<li>110   bílý sehrál zahájení dobøe </li>
<li>111   èerný sehrál zahájení dobøe </li>
<li>112   bílý sehrál zahájení velmi dobøe </li>
<li>113   èerný sehrál zahájení velmi dobøe </li>
<li>114   bílý sehrál støední hru velmi slabì </li>
<li>115   èerný sehrál støední hru velmi slabì </li>
<li>116   bílý sehrál støední hru slabì </li>
<li>117   èerný sehrál støední hru slabì </li>
<li>118   bílý sehrál støední hru dobøe </li>
<li>119   èerný sehrál støední hru dobøe </li>
<li>120   bílý sehrál støední hru velmi dobøe </li>
<li>121   èerný sehrál støední hru velmi dobøe </li>
<li>122   bílý sehrál koncovku velmi slabì </li>
<li>123   èerný sehrál koncovku velmi slabì </li>
<li>124   bílý sehrál koncovku slabì </li>
<li>125   èerný sehrál koncovku slabì </li>
<li>126   bílý sehrál koncovku dobøe </li>
<li>127   èerný sehrál koncovku dobøe </li>
<li>128   bílý sehrál koncovku velmi dobøe </li>
<li>129   èerný sehrál koncovku velmi dobøe </li>
<li>130   bílý má mírnou protihru </li>
<li>131   èerný má mírnou protihru </li>
<li>132   bílý má protihru </li>
<li>133   èerný má protihru </li>
<li>134   bílý má rozhodující protihru </li>
<li>135   èerný má rozhodující protihru </li>
<li>136   bílý má èasovou tíseò </li>
<li>137   èerný má èasovou tíseò </li>
<li>138   bílý má obrovskou èasovou tíseò </li>
<li>139   èerný má obrovskou èasovou tíseò </li>
</ul>
</cyan>

<p>
Ostatní pøedlo¾ené NAG hodnoty pro symboly publikací ©achového Informátoru
(Chess Informant) obsahují:
</p>
<cyan>
<ul>
<li>140   s my¹lenkou ... </li>
<li>141   namíøeno proti ... </li>
<li>142   lep¹í tah </li>
<li>143   hor¹í tah </li>
<li>144   rovnocenný tah </li>
<li>145   poznámka redakce ("RR") </li>
<li>146   novinka ("N") </li>
<li>147   slabý bod </li>
<li>148   koncovka </li>
<li>149   sloupec; øada </li>
<li>150   diagonála </li>
<li>151   bílý má dvojici støelcù </li>
<li>152   èerný má dvojici støelcù </li>
<li>153   rùznobarevní støelci </li>
<li>154   stejnobarevní støelci </li>
</ul>
</cyan>

<p>
Ostatní navr¾ené hodnoty jsou:
</p>
<cyan>
<ul>
<li>190   atd. </li>
<li>191   zdvojení pì¹ci </li>
<li>192   izolovaní pì¹ci </li>
<li>193   spojení pì¹ci </li>
<li>194   visící pì¹ci </li>
<li>195   opo¾dìný pì¹ec </li>
</ul>
</cyan>

<p>
Symboly definované Scidem pro jeho vlastní pou¾ití jsou:
</p>
<cyan>
<ul>
<li>201   Diagram ("D", nìkdy oznaèovaný "#") </li>
</ul>
</cyan>

<p><footer>(Aktualizováno: Scid 2.5, Èerven 2001)</footer></p>
}

##############
### ECO guide:

set helpTitle(C,ECO) "ECO prùvodce"
set helpText(C,ECO) {<h1>Klasifikace zahájení ECO</h1>
<p>
Scid mù¾e klasifikovat ¹achové partie podle klasifikace ¹achových zahájení
<b>ECO</b> (Encyclopedia of Chess Openings, tj. Encyklopedie ¹achových
zahájení).
Standardní ECO kód se skládá z písmene (A..E) následovaného dvìma èíslicemi,
tak¾e existuje 500 rozdílných standardních ECO kódù.
</p>

<h3>Roz¹íøení ECO systému podporovaná Scidem</h3>
<p>
ECO systém je velmi omezený a nedostateèný pro moderní partie: nìkteré z 500
kódù se skoro vùbec nevyskytují, zatímco nìkteré se vyskytují velmi èasto. Pro
zlep¹ení této situace Scid umo¾òuje volitelné roz¹íøení základních ECO kódù:
ka¾dý kód mù¾e být roz¹íøen písmenem (a..z), dal¹í roz¹íøení (èíslicí, 1..4)
jsou mo¾ná, ale je¹tì nejsou pou¾ity ve standardním ECO souboru Scidu.
Tak¾e roz¹íøený ECO kód Scidu vypadá asi jako "<b>A41e</b>" nebo "<b>E99b2</b>".
Mnoho nejbì¾nìj¹ích ECO kódù z moderních mistrovských partií mají roz¹íøení
definovaná v ECO souboru Scidu.
</p>

<h3><name Browser>Okno ECO prohlí¾eèe</name></h3>
<p>
Okno <term>ECO prohlí¾eèe</term> vám zobrazuje pozice, které jsou pou¾ívány ke
klasifikaci ka¾dého ECO kódu a èetnost a úspì¹nost ECO kódù v aktuální databázi.
</p>
<p>
Horní pole zobrazuje èetnost ka¾dého ECO kódu v aktuální databázi. Li¹ta v grafu
má tøi úseky: nejni¾¹í (nejsvìtlej¹í barva) je poèet výher bílého, prostøední je
poèet remíz a nejvy¹¹í (nejtmav¹í) je poèet výher èerného. To vám umo¾òuje
rychle zjistit charakteristiky zahájení: napø. jestli bílí skórují velmi dobøe
nebo jestli jsou velmi èasté remízy.
</p>
<p>
Chcete-li jít do hlub¹í ECO úrovnì, kliknìte levým tlaèítkem my¹i na li¹tu v
grafu (nebo zadejte korespondující písmeno nebo èíslici). Chcete-li jít zpìt do
vy¹¹í úrovnì, kliknìte pravým tlaèítkem my¹i kamkoliv v grafu nebo stisknìte
klávesu levé ¹ipky (nebo Delete nebo Backspace).
</p>
<p>
Dolní pole zobrazuje pozice, které obsahuje jednotlivý ECO kód, podle ECO
souboru, který jste natáhli.
</p>

<h3>Nata¾ení ECO souboru Scidu</h3>
<p>
ECO soubor distribuovaný spoleènì se Scidem se jmenuje <b>scid.eco</b> a Scid se
ho pokou¹í pøi svém startu natáhnout.
Jestli¾e ho Scid nemù¾e najít, bude potøeba, aby byla mo¾ná ECO klasifikace,
udìlat následující:
<ul>
<li>(a) Ve Scidu, pou¾ijte pøíkaz menu
        <menu>Volby: Natáhnout ECO
        soubor...</menu> a vyberte soubor <b>scid.eco</b>. </li>
<li>(b) Ulo¾te volby (z menu <menu>Volby</menu>). </li>
</ul>
Poté, co to provedete, ECO soubor bude nata¾en pøi ka¾dém spu¹tìní Scidu.
</p>

<h3><name Codes>Systém kódù ECO</name></h3>
<p>
Základní struktura ECO systému je:
</p>
<p>
<b><blue><run updateEcoWin A>A</run></blue></b>
   1.d4 Jf6 2...;  1.d4 ...;  1.c4;  1.rùzné
<ul>
<li>  <b>A0</b>  1.<i>rùzné</i>
      (<b>A02-A03</b> 1.f4: <i>Birdovo zahájení</i>,
      <b>A04-A09</b>  1.Jf3: <i>Rétiho, Královský indický útok</i>) </li>
<li>  <b>A1</b>  1.c4 ...: <i>Anglická</i> </li>
<li>  <b>A2</b>  1.c4 e5: <i>Anglická královská</i> </li>
<li>  <b>A3</b>  1.c4 c5: <i>Anglická symetrická</i> </li>
<li>  <b>A4</b>  1.d4 ...: <i>Dámským pì¹cem</i> </li>
<li>  <b>A5</b>  1.d4 Jf6 2.c4 ..: <i>Indická obrana</i> </li>
<li>  <b>A6</b>  1.d4 Nf6 2.c4 c5 3.d5 e6: <i>Moderní Benoni</i> </li>
<li>  <b>A7</b>  A6 + 4.Jc3 exd5 5.cxd5 d6 6.e4 g6 7.Jf3 </li>
<li>  <b>A8</b>  1.d4 f5: <i>Holandská obrana</i> </li>
<li>  <b>A9</b>  1.d4 f5 2.c4 e6: <i>Holandská obrana</i> </li>
</ul>

<p>
<b><blue><run updateEcoWin B>B</run></blue></b>
   1.e4 c5;  1.e4 c6;  1.e4 d6;  1.e4 <i>rùzné</i>
<ul>
<li>  <b>B0</b>  1.e4 ...
      (<b>B02-B05</b>  1.e4 Jf6: <i>Alechinova obrana</i>;
      <b>B07-B09</b>  1.e4 d6: <i>Pircova</i>) </li>
<li>  <b>B1</b>  1.e4 c6: <i>Caro-Kann</i> </li>
<li>  <b>B2</b>  1.e4 c5: <i>Sicilská obrana</i> </li>
<li>  <b>B3</b>  1.e4 c5 2.Jf3 Jc6: <i>Sicilská</i> </li>
<li>  <b>B4</b>  1.e4 c5 2.Jf3 e6: <i>Sicilská</i> </li>
<li>  <b>B5</b>  1.e4 c5 2.Jf3 d6: <i>Sicilská</i> </li>
<li>  <b>B6</b>  B5 + 3.d4 cxd4 4.Jxd4 Jf6 5.Jc3 Jc6 </li>
<li>  <b>B7</b>  B5 + 4.Jxd4 Jf6 5.Jc3 g6: <i>Sicilská draèí</i> </li>
<li>  <b>B8</b>  B5 + 4.Nxd4 Nf6 5.Nc3 e6: <i>Sicilská Scheveningen</i> </li>
<li>  <b>B9</b>  B5 + 4.Nxd4 Nf6 5.Nc3 a6: <i>Sicilská Najdorf</i> </li>
</ul>

<p>
<b><blue><run updateEcoWin C>C</run></blue></b>
   1.e4 e5;  1.e4 e6
<ul>
<li>  <b>C0</b>  1.e4 e6: <i>Francouzská obrana</i> </li>
<li>  <b>C1</b>  1.e4 e6 2.d4 d5 3.Jc3: <i>Francouzská, Winawer/klasická</i>
  </li>
<li>  <b>C2</b>  1.e4 e5: <i>Otevøená hra</i> </li>
<li>  <b>C3</b>  1.e4 e5 2.f4: <i>Královský gambit</i> </li>
<li>  <b>C4</b>  1.e4 e5 2.Jf3: <i>Otevøená hra</i> </li>
<li>  <b>C5</b>  1.e4 e5 2.Jf3 Jc6 3.Sc4: <i>Italská; Hra dvou jezdcù</i> </li>
<li>  <b>C6</b>  1.e4 e5 2.Jf3 Jc6 3.Sb5: <i>©panìlská</i> </li>
<li>  <b>C7</b>  1.e4 e5 2.Jf3 Jc6 3.Sb5 a6 4.Sa4: <i>©panìlská</i> </li>
<li>  <b>C8</b>  C7 + 4...Jf6 5.O-O: <i>©panìlská, zavøená a otevøená</i>
      (<b>C80-C83</b>  5.O-O Jxe4: <i>©panìlská, otevøený systém</i>;
      <b>C84-C89</b>  5.O-O Se7: <i>©panìlská, zavøený systém</i>) </li>
<li>  <b>C9</b>  C8 + 5...Se7 6.Ve1 b5 7.Sb3 d6: <i>©panìlská, zavøená</i> </li>
</ul>

<p>
<b><blue><run updateEcoWin D>D</run></blue></b>
   1.d4 d5; 1.d4 Jf6 2.c4 g6 s 3...d5
<ul>
<li>  <b>D0</b>  1.d4 d5: <i>Dámským pì¹cem</i> </li>
<li>  <b>D1</b>  1.d4 d5 2.c4 c6: <i>Slovanská obrana</i> </li>
<li>  <b>D2</b>  1.d4 d5 2.c4 dxc4: <i>Dámský gambit pøijatý</i> </li>
<li>  <b>D3</b>  1.d4 d5 2.c4 e6: <i>Dámský gambit odmítnutý</i> </li>
<li>  <b>D4</b>  D3 + 3.Jc3 Jf6 4.Jf3 c5/c6: <i>Semi-Tarraschova;
  Poloslovanská</i>  </li>
<li>  <b>D5</b>  D3 + 3.Jc3 Jf6 4.Sg5: <i>Dámský gambit odmítnutý klasický</i>
 </li>
<li>  <b>D6</b>  D5 + 4...Se7 5.e3 O-O 6.Jf3 Jbd7: <i>Dámský gambit
 odmítnutý  ortodoxní</i> </li>
<li>  <b>D7</b>  1.d4 Jf6 2.c4 g6 s 3...d5: <i>Grunfeldova obrana</i> </li>
<li>  <b>D8</b>  1.d4 Jf6 2.c4 g6 3.Jc3 d5: <i>Grunfeldova</i> </li>
<li>  <b>D9</b>  1.d4 Jf6 2.c4 g6 3.Jc3 d5 4.Jf3: <i>Grunfeldova</i> </li>
</ul>

<p>
<b><blue><run updateEcoWin E>E</run></blue></b>
   1.d4 Jf6 2.c4 e6; 1.d4 Jf6 2.c4 g6 </li>
<ul>
<li>  <b>E0</b>  1.d4 Jf6 2.c4 e6: <i>Katalánská, atd.</i> </li>
<li>  <b>E1</b>  1.d4 Jf6 2.c4 e6 3.Jf3 (b6): <i>Dámská indická, atd.</i> </li>
<li>  <b>E2</b>  1.d4 Jf6 2.c4 e6 3.Jc3 (Sb4): <i>Nimcovièova indická, atd.</i>
 </li>
<li>  <b>E3</b>  E2 + 4.Sg5 nebo 4.Dc2: <i>Nimcovièova indická</i> </li>
<li>  <b>E4</b>  E2 + 4.e3: <i>Nimcovièova indická, Rubinstein</i> </li>
<li>  <b>E5</b>  E4 + 4...O-O 5.Jf3: <i>Nimcovièova indická, hlavní varianta</i>
 </li>
<li>  <b>E6</b>  1.d4 Jf6 2.c4 g6: <i>Královská indická</i> </li>
<li>  <b>E7</b>  1.d4 Jf6 2.c4 g6 3.Jc3 Sg7 4.e4: <i>Královská indická</i> </li>
<li>  <b>E8</b>  E7 + 4...d6 5.f3: <i>Královská indická, Samisch</i> </li>
<li>  <b>E9</b>  E7 + 4...d6 5.Jf3: <i>Královská indická, hlavní
 varianty</i> </li>
</ul>

<p><footer>(Aktualizováno: Scid 2.5, Èerven 2001)</footer></p>
}

#################
### Contact info:


set helpTitle(C,Author) "Kontaktní informace"
set helpText(C,Author) {<h1>Kontaktní informace</h1>
<p>
Webová stránka Scidu je: <br>
<b><url http://scid.sourceforge.net/>http://scid.sourceforge.net/</url></b>
</p>
<p>
Mù¾ete si tam stáhnout poslední verzi Scidu a k dispozici jsou i jiné soubory.
</p>
<p>
Ve¹keré komentáøe, dotazy, návrhy a informace o chybách posílejte prosím autorovi
Scidu, Shaneovi Hudsonovi, na emailovou adresu:<br>
<b>sgh@users.sourceforge.net</b>
</p>

<h3><name Related>Pøíbuzné odkazy</name></h3>
<p>
Jestli¾e se vám Scid líbí, mo¾ná vás budou zajímat následující webové stránky:
</p>
<ul>
<li><url http://www.tim-mann.org/chess.html>http://www.tim_mann.org/chess.html</url> --
Domovská stránka programu Tima Manna <b>xboard & winboard</b>, který lze pou¾ít ke
ètení PGN a jako rozhraní pro internetové ¹achové servery. Jeho stránka obsahuje
rovnì¾ dobré informace o Crafty, GNUchess a dal¹ích volnì ¹iøitelných ¹achových
programech. </li>

<li><url ftp://ftp.cis.uab.edu/pub/hyatt/>ftp://ftp.cis.uab.edu/pub/hyatt/</url> --
silný ¹achy hrající program Crafty. Podadresáø pojmenovaný <b>TB</b> obsahuje mnoho
souborù tabulek koncovek (tablebase) v Nalimovovì formátu, které lze pou¾ít v
nìkolika ¹achových programech a rovnì¾ ve Scidu.</li>

<li><url http://www.chesscenter.com/twic/>http://www.chesscenter.com/twic/</url> --
TWIC (the week in chess), znamenitý týdenní zpravodaj mezinárodních ¹achových
partií dostupný v PGN formátu.</li>

<li><url http://scid.sourceforge.net/doc/standard.txt>http://scid.sourceforge.net/doc/standard.txt</url> --
<b>PGN Standard</b>, vytvoøený Stevenem J. Edwardsem v roce 1994. Tento text
vysvìtluje detailnì formáty PGN a EPD.</li> </ul>

<p><footer>(Aktualizováno: Scid 2.6, Srpen 2001)</footer></p>
}

# end of czech.tcl































