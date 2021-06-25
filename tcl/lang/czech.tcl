# czech.tcl: Czech menus and help for Scid.
# Contributed by Pavel Han�k, Vlastimil Babula and Milan Zamazal.
# Untranslated messages are marked with a "***" comment.

proc setLanguage_C {} {

# File menu:
menuText C File "Soubor" 0
menuText C FileNew "Nov�..." 0 {Vytvo�it novou Scid datab�zi}
menuText C FileOpen "Otev��t..." 0 {Otev��t existuj�c� Scid datab�zi}
menuText C FileClose "Zav��t" 0 {Zav��t aktivn� Scid datab�zi}
menuText C FileFinder "Vyhled�va�" 2 {Otev��t okno vyhled�va�e soubor�}
menuText C FileBookmarks "Z�lo�ky" 2 {Menu z�lo�ek (kl�vesa: Ctrl+B)}
menuText C FileBookmarksAdd "P�idat z�lo�ku" 0 \
  {Z�lo�ka aktu�ln� pozice a partie z datab�ze}
menuText C FileBookmarksFile "Za�adit z�lo�ku" 0 \
  {Za�adit z�lo�ku pro aktu�ln� partii a pozici}
menuText C FileBookmarksEdit "Editovat z�lo�ky..." 0 \
  {Editovat menu z�lo�ek}
menuText C FileBookmarksList "Zobrazit slo�ky jako jedin� seznam" 0 \
  {Zobrazit slo�ky se z�lo�kami jako jedin� seznam, bez podnab�dek}
menuText C FileBookmarksSub "Zobrazit slo�ky jako podnab�dky" 9 \
  {Zobrazit z�lo�kov� slo�ky jako podnab�dky, ne jako jedin� seznam}
menuText C FileMaint "�dr�ba" 2 {N�stroje pro �dr�bu datab�ze Scidu}
menuText C FileMaintWin "Okno �dr�by" 0 \
  {Otev��t/zav��t okno pro �dr�bu Scid datab�ze}
menuText C FileMaintCompact "Zhutn�n� datab�ze..." 13 \
  {Zhutn�n� datab�zov�ch soubor�, odstran�n� vymazan�ch parti� a nepou��van�ch jmen}
menuText C FileMaintClass "ECO klasifikace parti�..." 0 \
  {P�epo��t�n� ECO k�d� v�ech parti�}
menuText C FileMaintSort "Set��dit datab�zi..." 0 \
  {Set��dit v�echny partie v datab�zi}
menuText C FileMaintDelete "Vymaz�n� zdvojen�ch parti�..." 0 \
  {Hledat zdvojen� partie a ozna�it je pro vymaz�n�}
menuText C FileMaintTwin "Kontrola zdvojen�ch parti�" 0 \
  {Otev��t/aktualizovat okno pro kontrolu zdvojen�ch parti�}
menuText C FileMaintName "Jm�na" 0 {Editace jmen a kontrola pravopisu}
menuText C FileMaintNameEditor "Editor jmen" 0 \
  {Otev��t/zav��t editor jmen}
menuText C FileMaintNamePlayer "Kontrola pravopisu hr���..." 19 \
  {Kontrola pravopisu jmen hr��� s vyu�it�m souboru pro kontrolu pravopisu}
menuText C FileMaintNameEvent "Kontrola pravopisu turnaj�..." 19 \
  {Kontrola pravopisu n�zv� turnaj� s vyu�it�m souboru pro kontrolu pravopisu}
menuText C FileMaintNameSite "Kontrola pravopisu m�st..." 19 \
  {Kontrola pravopisu m�st turnaj� s vyu�it�m souboru pro kontrolu pravopisu}
menuText C FileMaintNameRound "Kontrola pravopisu kol..." 19 \
  {Kontrola pravopisu kol s vyu�it�m souboru pro kontrolu pravopisu}
menuText C FileReadOnly "Pouze pro �ten�..." 0 \
  {Nastavit aktu�ln� datab�zi jako jen ke �ten�, a zabr�nit tak zm�n�m}
menuText C FileSwitch "P�epnout se do datab�ze" 15 \
  {P�epnout se do jin� otev�en� datab�ze}
menuText C FileExit "Ukon�it" 0 {Ukon�it Scid}
menuText C FileMaintFixBase "Opravit po�kozenou datab�zi" 0 {Pokusit se opravit po�kozenou datab�zi}

# Edit menu:
menuText C Edit "Editace" 0
menuText C EditAdd "P�idat variantu" 0 {P�idat variantu k tomuto tahu v partii}
menuText C EditDelete "Vymazat variantu" 0 {Vymazat variantu k tomuto tahu}
menuText C EditFirst "Za�adit jako prvn� variantu" 0 \
  {Za�adit variantu na prvn� m�sto v seznamu variant}
menuText C EditMain "Pov��it st�vaj�c� variantu na hlavn�" 30 \
  {Pov��it st�vaj�c� variantu na hlavn� variantu}
menuText C EditTrial "Zkusit variantu" 1 \
    {Spustit/Ukon�it zku�ebn� m�d pro testov�n� my�lenky na �achovnici}
menuText C EditStrip "Odstranit" 0 {Odstranit koment��e nebo varianty z t�to partie}
menuText C EditUndo "Vz�t zp�t" 0 {Vz�t zp�t posledn� zm�nu v partii}
# ====== TODO To be translated ======
menuText C EditRedo "Redo" 0 {Redo last game change}
menuText C EditStripComments "Koment��e" 0 \
  {Odstranit v�echny pozn�mky a anotace z t�to partie}
menuText C EditStripVars "Varianty" 0 {Odstranit v�echny varianty z t�to partie}
menuText C EditStripBegin "Tahy ze za��tku" 5 \
  {Odstranit tahy ze za��tku partie}
menuText C EditStripEnd "Tahy do konce" 5 \
  {Odstranit tahy do konce partie}
menuText C EditReset "Vypr�zdnit schr�nku" 11 \
  {Kompletn� vypr�zdn�n� datab�ze schr�nka}
menuText C EditCopy "Zkop�rovat tuto partii do schr�nky" 23 \
  {Zkop�rovat tuto parti� do datab�ze schr�nka}
menuText C EditPaste "Vlo�it posledn� partii ze schr�nky" 24 \
  {Vlo�it aktivn� partii z datab�ze schr�nka}
menuText C EditPastePGN "Vlo�it text ze schr�nky jako PGN..." 10 \
  {Interpretovat text schr�nky jako partii v PGN notaci a vlo�it ji sem}
menuText C EditSetup "Nastavit v�choz� pozici..." 0 \
  {Nastavit v�choz� pozici pro tuto partii}
menuText C EditCopyBoard "Kop�rovat pozici" 4 \
  {Kop�rovat aktu�ln� pozici ve FEN notaci do textov�ho v�b�ru (do clipboardu)}
menuText C EditPasteBoard "Vlo�it po��te�n� pozici" 1 \
  {Nastavit po��te�n� pozici z aktu�ln�ho textov�ho v�b�ru (z clipboardu)}
# ====== TODO To be translated ======
menuText C ConfigureScid "Preferences..." 0 {Configure all options for SCID}

# Game menu:
menuText C Game "Partie" 0
menuText C GameNew "Nov� partie" 0 \
  {Nastavit novou partii, v�echny proveden� zm�ny budou ztraceny}
menuText C GameFirst "Nat�hnout prvn� partii" 10 {Nat�hnout prvn� partii z filtrovan�ch parti�}
menuText C GamePrev "Nat�hnout p�edchoz� partii" 13 {Nat�hnout p�edchoz� partii z filtrovan�ch parti�}
menuText C GameReload "Znovunat�hnout aktu�ln� partii" 0 \
  {Znovunata�en� aktu�ln� partie, v�echny doposud proveden� zm�ny budou ztraceny}
menuText C GameNext "Nat�hnout n�sleduj�c� partii" 14 {Nat�hnout n�sleduj�c� partii z filtrovan�ch parti�}
menuText C GameLast "Nat�hnout posledn� partii" 11 {Nat�hnout posledn� partii z filtrovan�ch parti�}
menuText C GameRandom "Nat�hnout partii n�hodn�" 1 {Nat�hnout n�hodn� vybranou partii z filtru}
menuText C GameNumber "Nat�hnout partii ��slo..." 19 \
  {Nat�hnout partii ��slo...}
menuText C GameReplace "Ulo�it: p�eps�n� partie..." 0 \
  {Ulo�it tuto partii - p�ep�e p�vodn� verzi}
menuText C GameAdd "Ulo�it: p�id�n� nov� partie..." 1 \
  {Ulo�it tuto partii jako novou partii v datab�zi}
menuText C GameDeepest "Identifikace zah�jen�" 0 \
  {P�ej�t na koncovou pozici z ECO knihovny, kter� odpov�d� zvolen�mu zah�jen�}
menuText C GameGotoMove "P�ej�t na tah ��slo..." 10 \
  {P�ej�t v aktu�ln� partii do pozice udan� ��slem tahu}
menuText C GameNovelty "Hledat novinku..." 0 \
  {Hledat prvn� tah t�to partie, kter� doposud nebyl hr�n}

# Search Menu:
menuText C Search "Hledat" 0
menuText C SearchReset "Vy�istit filtr" 0 {Vy�istit filtr - vybr�ny budou v�echny partie}
menuText C SearchNegate "Negace filtru" 0 {Negace filtru -  vybr�ny budou pouze partie vy�at� p�edch�zej�c�m filtrem}
menuText C SearchCurrent "Aktu�ln� pozice..." 0 {Hledat aktu�ln� pozici}
menuText C SearchHeader "Hlavi�ka..." 0 {Hledat podle hlavi�ky partie (hr��, turnaj apod.)}
menuText C SearchMaterial "Materi�l/Vzor..." 0 {Hledat podle materi�lu nebo podle vzoru}
menuText C SearchUsing "Hledat pomoc� souboru voleb..." 14 {Hledat s pou�it�m voleb zapsan�ch v souboru}

# Windows menu:
menuText C Windows "Okna" 0
menuText C WindowsComment "Editor koment���" 0 {Otev��t/zav��t editor koment���}
menuText C WindowsGList "Seznam parti�" 2 {Otev��t/zav��t okno se seznamem parti�}
menuText C WindowsPGN "Okno PGN" 5 {Otev��t/zav��t okno PGN}
menuText C WindowsPList "Vyhled�va� hr���" 11 {Otev��t/zav��t okno vyhled�va�e hr���}
menuText C WindowsTmt "Vyhled�va� turnaj�" 11 {Otev��t/zav��t okno vyhled�va�e turnaj�}
menuText C WindowsSwitcher "V�b�r datab�ze" 0 {Otev��t/zav��t okno pro v�b�r datab�z�}
menuText C WindowsMaint "Okno �dr�by" 6 {Otev��t/zav��t okno �dr�by}
menuText C WindowsECO "ECO prohl�e�" 1 {Otev��t/zav��t okno ECO prohl�e�e}
menuText C WindowsStats "Statistick� okno" 0 {Otev��t/zav��t statistick� okno filtru}
menuText C WindowsTree "Stromov� okno" 4 {Otev��t/zav��t stromov� okno}
menuText C WindowsTB "Okno tabulky koncovek" 13 {Otev��t/zav��t okno tabulek koncovek}
menuText C WindowsBook "Okno knihovny zah�jen�" 0 {Otev��t/zav��t okno knihovny zah�jen�}
menuText C WindowsCorrChess "Koresponden�n� okno" 0 {Otev��t/zav��t okno knihovny zah�jen�}

# Tools menu:
menuText C Tools "N�stroje" 3
menuText C ToolsAnalysis "Program pro anal�zu..." 0 \
  {Spustit/zastavit �achov� program pro anal�zu pozice}
menuText C ToolsAnalysis2 "Program pro anal�zu #2..." 20 \
  {Spustit/zastavit druh� �achov� program pro anal�zu pozice}
menuText C ToolsCross "Turnajov� tabulka" 0 {Uk�zat turnajovou tabulku pro tuto partii}
menuText C ToolsEmail "Email mana�er" 1 \
  {Otev��t/zav��t okno emailov�ho mana�era}
menuText C ToolsFilterGraph "Graf filtru" 0 \
  {Otev��t/zav��t okno grafu filtru}
menuText C ToolsAbsFilterGraph "Abs. graf filtru" 7 {Otev��t/zav��t okno grafu filtru s absolutn�mi hodnotami}
menuText C ToolsOpReport "Profil zah�jen�" 7 \
  {Generovat profil zah�jen� pro aktu�ln� pozic�}
menuText C ToolsOpenBaseAsTree "Otev��t datab�zi jako strom" 0   {Otev��t datab�zi a pou��t ji ve stromov�m okn�}
menuText C ToolsOpenRecentBaseAsTree "Otev��t ned�vnou datab�zi jako strom" 0   {Otev��t ned�vnou datab�zi a pou��t ji ve stromov�m okn�}
menuText C ToolsTracker "Stopa� figur"  0 {Otev��t okno stopa�e figur}
menuText C ToolsTraining "Tr�nink"  0 {Tr�ninkov� n�stroje (taktika, zah�jen�,...) }
menuText C ToolsTacticalGame "Taktick� partie"  0 {Hr�t partii s taktick�m zam��en�m}
menuText C ToolsSeriousGame "V�n� partie"  0 {Hr�t v�nou partii}
menuText C ToolsTrainOpenings "Zah�jen�"  0 {Tr�novat s reperto�rem zah�jen�}
menuText C ToolsTrainReviewGame "Proj�t partii"  0 {H�dat tahy sehran� v partii}
menuText C ToolsTrainTactics "Taktika"  0 {�e�it taktick� �koly}
menuText C ToolsTrainCalvar "Propo�et variant"  0 {Tr�nink propo�tu variant}
menuText C ToolsTrainFindBestMove "Nal�zt nejlep�� tah"  0 {Nal�zt nejlep�� tah}
menuText C ToolsTrainFics "Hr�t na internetu"  0 {Hr�t na freechess.org}
# ====== TODO To be translated ======
menuText C ToolsEngineTournament "Engine tournament"  0 {Start a tournament between chess engines}
menuText C ToolsBookTuning "Lad�n� knihovny zah�jen�" 0 {Lad�n� knihovny zah�jen�}
menuText C ToolsConnectHardware "P�ipojit hardware" 0 {P�ipojit extern� hardware}
menuText C ToolsConnectHardwareConfigure "Konfigurovat..." 0 {Konfigurovat extern� hardware a p�ipojen�}
menuText C ToolsConnectHardwareNovagCitrineConnect "P�ipojit Novag Citrine" 0 {P�ipojit Novag Citrine}
menuText C ToolsConnectHardwareInputEngineConnect "P�ipojit vstupn� p��stroj" 0 {P�ipojit vstupn� p��stroj (nap�. DGT)}
menuText C ToolsPInfo "Informace o hr���ch"  0 \
  {Otev��t/aktualizovat okno s informacemi o hr���ch}
menuText C ToolsPlayerReport "Profil hr��e..." 7 \
  {Generovat profil hr��e}
menuText C ToolsRating "Graf ratingu" 5 \
  {Zobrazit graf v�voje ratingu hr��� aktu�ln� partie}
menuText C ToolsScore "Graf sk�re" 6  {Zobrazit okno grafu sk�re}
menuText C ToolsExpCurrent "Export aktu�ln� partie" 7 \
  {Zapsat aktu�ln� partii do textov�ho souboru}
menuText C ToolsExpCurrentPGN "Export partie do PGN souboru..." 17 \
  {Zapsat aktu�ln� partii do PGN souboru}
menuText C ToolsExpCurrentHTML "Export partie do HTML souboru..." 17 \
  {Zapsat aktu�ln� partii do HTML souboru}
menuText C ToolsExpCurrentHTMLJS "Exportovat partii do souboru HTML s JavaScriptem..." 15 {Ulo�it aktu�ln� partii do souboru s HTML a JavaScriptem}  
menuText C ToolsExpCurrentLaTeX "Export partie do LaTeX souboru..." 17 \
  {Zapsat aktu�ln� partii do LaTeX souboru}
menuText C ToolsExpFilter "Export filtrovan�ch parti�" 7 \
  {Zapsat v�echny filtrovan� partie do textov�ho souboru}
menuText C ToolsExpFilterPGN "Export filtrovan�ch parti� do PGN souboru..." 30 \
  {Zapsat v�echny filtrovan� partie do PGN souboru}
menuText C ToolsExpFilterHTML "Export filtrovan�ch parti� do HTML souboru..." 30 \
  {Zapsat v�echny filtrovan� partie do HTML souboru}
menuText C ToolsExpFilterHTMLJS "Exportovat filtr do souboru HTML s JavaScriptem..." 17 {Ulo�it v�echny vyfiltrovan� partie do souboru HTML s JavaScriptem}  
menuText C ToolsExpFilterLaTeX "Export filtrovan�ch parti� do LaTeX souboru..." 30 \
  {Zapsat v�echny filtrovan� partie do LaTeX souboru}
menuText C ToolsImportOne "Import jedn� PGN partie..." 7 \
  {Importovat partii z PGN z�pisu}
menuText C ToolsImportFile "Import souboru PGN parti�..." 10 \
  {Importovat partie z PGN souboru}
menuText C ToolsStartEngine1 "Spustit hern� program 1" 0  {Spustit hern� program 1}
menuText C ToolsStartEngine2 "Spustit hern� program 2" 0  {Spustit hern� program 2}
menuText C ToolsCaptureBoard "Ulo�it aktu�ln� �achovnici..." 0  {Ulo�it aktu�ln� �achovnici jako obr�zek.}
menuText C Play "Hra" 0
menuText C CorrespondenceChess "Koresponden�n� �ach" 0 {Funkce pro koresponden�n� �ach zalo�en� na e-mailu a Xfcc}
menuText C CCConfigure "Konfigurovat..." 0 {Konfigurovat extern� n�stroje a obecn� nastaven�}
menuText C CCConfigRelay "Konfigurovat sledov�n�..." 10 {Konfigurovat partie ke sledov�n�}
menuText C CCOpenDB "Otev��t datab�zi..." 0 {Otev��t v�choz� koresponden�n� datab�zi}
menuText C CCRetrieve "St�hnout partie" 0 {St�hnout partie s pomoc� extern�ho (Xfcc-)n�stroje}
menuText C CCInbox "Zpracovat p��choz� schr�nku" 0 {Zpracovat v�echny soubory v p��choz� schr�nce scidu}
menuText C CCSend "Poslat tah" 0 {Poslat tah prost�ednictv�m e-mailu nebo extern�ho (Xfcc-)n�stroje}
menuText C CCResign "Vzd�t" 0 {Vzd�t (nikoliv prost�ednictv�m e-mailu)}
menuText C CCClaimDraw "Reklamovat rem�zu" 0 {Poslat tah a reklamovat rem�zu (nikoliv prost�ednictv�m e-mailu)}
menuText C CCOfferDraw "Nab�dnout rem�zu" 0 {Odeslat tah a nab�dnout rem�zu (nikoliv prost�ednictv�m e-mailu)}
menuText C CCAcceptDraw "P�ijmout rem�zu" 0 {P�ijmout nab�dku rem�zy (nikoliv prost�ednictv�m e-mailu)}
menuText C CCNewMailGame "Nov� e-mailov� partie..." 0 {Za��t novou e-mailovou partii}
menuText C CCMailMove "Mailovat tah..." 0 {Odeslat tah soupe�i prost�ednictv�m e-mailu}
menuText C CCGamePage "Str�nka partie..." 0 {Vyvolat partii pomoc� webov�ho prohl�e�e}
menuText C CCEditCopy "Zkop�rovat seznam parti� do schr�nky" 0 {Zkop�rovat partie jako CVS seznam do schr�nky}

# Options menu:
menuText C Options "Volby" 0
menuText C OptionsBoardGraphics "Pole..." 0 {Vybrat vzorek pro pole}
translate C OptionsBGW {Vybrat vzorek pro pole}
translate C OptionsBoardGraphicsText {Vybrat grafick� soubory pro b�l� a �ern� pole:}
menuText C OptionsBoardNames "Jm�na m�ch hr���..." 0 {Editovat jm�na m�ch hr���}
menuText C OptionsExport "Volby exportu" 7 {Zm�nit volby pro textov� export}
menuText C OptionsFonts "Fonty" 2 {Zm�nit fonty}
menuText C OptionsFontsRegular "Z�kladn�" 0 {Zm�nit z�kladn� font}
menuText C OptionsFontsMenu "Menu" 1 {Zm�nit font pro menu}
menuText C OptionsFontsSmall "Mal�" 0 {Zm�nit mal� font}
# ====== TODO To be translated ======
menuText C OptionsFontsTiny "Tiny" 0 {Change the tiny font}
menuText C OptionsFontsFixed "Fixn�" 0 {Zm�nit font fixn� ���ky}
menuText C OptionsGInfo "Informace o partii" 0 {Volby pro informace o partii}
menuText C OptionsLanguage "Jazyk" 0 {Vybrat jazyk menu}
menuText C OptionsMovesTranslatePieces "P�ekl�dat figury" 0 {P�ekl�dat prvn� p�smena figur}
menuText C OptionsMovesHighlightLastMove "Zv�raz�ovat posledn� tah" 0 {Zv�raz�ovat posledn� tah}
menuText C OptionsMovesHighlightLastMoveDisplay "Uk�zat" 0 {Zobrazit zv�razn�n� posledn� tah}
menuText C OptionsMovesHighlightLastMoveWidth "���ka" 0 {Tlou��ka ��ry}
menuText C OptionsMovesHighlightLastMoveColor "Barva" 0 {Barva ��ry}
# ====== TODO To be translated ======
menuText C OptionsMovesHighlightLastMoveArrow "include Arrow" 0 {Include Arrow with Highlight}
menuText C OptionsMoves "Tahy" 0 {Volby pro zad�v�n� tah�}
menuText C OptionsMovesAnimate "�as animace" 4 \
  {Nastavit �as pou�it� na animaci tah�}
menuText C OptionsMovesDelay "Prodleva p�i automatick�m p�ehr�v�n�..." 1 \
  {Nastavit �asovou prodlevu p�i automatick�m p�ehr�v�n�}
menuText C OptionsMovesCoord "Sou�adnicov� zad�v�n� tah�" 0 \
  {Povolit zad�v�n� tah� pomoc� sou�adnic (nap�. "g1f3")}
menuText C OptionsMovesSuggest "Uk�zat navrhovan� tahy" 0 \
  {Zapnout/vypnout zobrazov�n� navrhovan�ch tah�}
menuText C OptionsShowVarPopup "Zobrazit okno variant" 0 {Zapnout/vypnout zobrazen� okna variant}  
menuText C OptionsMovesSpace "P�idat mezeru za ��slo tahu" 0 {P�idat mezeru za ��slo tahu}  
menuText C OptionsMovesKey "Kl�vesnicov� dopl�ov�n�" 13 \
  {Zapnout/vypnout automatick� dopl�ov�n� tah� zad�van�ch kl�vesnic�}
menuText C OptionsMovesShowVarArrows "Zobrazit �ipky pro varianty" 0 {Zapnout/vypnout zobrazov�n� �ipek ukazuj�c�ch tahy variant}
# ====== TODO To be translated ======
menuText C OptionsMovesGlossOfDanger "Color Coded Gloss of Danger" 0 {Turn on/off color coded gloss of danger}
menuText C OptionsNumbers "Form�t ��sel" 0 {Zvolit form�t ��sel}
menuText C OptionsTheme "T�ma" 0 {Zm�nit vzhled u�ivatelsk�ho rozhran�}
menuText C OptionsWindows "Okna" 0 {Volby oken}
menuText C OptionsSounds "Zvuky" 2 {Konfigurovat zvuky oznamuj�c� tah}
# ====== TODO To be translated ======
menuText C OptionsResources "Resources..." 0 {Choose resource files and folders}
menuText C OptionsWindowsDock "Zaparkovat okna" 0 {Zaparkovat okna}
menuText C OptionsWindowsSaveLayout "Ulo�it rozlo�en�" 0 {Ulo�it rozlo�en�}
menuText C OptionsWindowsRestoreLayout "Obnovit rozlo�en�" 0 {Obnovit rozlo�en�}
menuText C OptionsWindowsShowGameInfo "Uk�zat informace o partii" 0 {Uk�zat informace o partii}
menuText C OptionsWindowsAutoLoadLayout "Automaticky nat�hnout prvn� rozlo�en�" 0 {Automaticky na za��tku nat�hnout prvn� rozlo�en�}
menuText C OptionsECO "Nat�hnout ECO soubor" 10 {Nat�hnout soubor s klasifikac� ECO}
menuText C OptionsSpell "Nat�hnout soubor pro kontrolu pravopisu" 21 \
  {Nat�hnout soubor Scidu pro kontrolu pravopisu}
menuText C OptionsTable "Adres�� pro tabulky koncovek" 14 \
  {Vybrat soubor s tabulkami koncovek; v�echny tabulky koncovek v jeho adres��i budou pou�ity}
menuText C OptionsRecent "Ned�vn� soubory..." 0 \
  {Zm�nit po�et ned�vn�ch soubor� zobrazovan�ch v menu Soubor}
menuText C OptionsBooksDir "Adres�� knihoven zah�jen�" 0 {Nastaven� adres��e knihoven zah�jen�}
menuText C OptionsTacticsBasesDir "Adres�� datab�z�" 0 {Nastaven� adres��� taktick�ch (tr�ninkov�ch) datab�z�}
# ====== TODO To be translated ======
menuText C OptionsPhotosDir "Photos directory" 0 {Sets the photos bases directory}
# ====== TODO To be translated ======
menuText C OptionsThemeDir "Theme(s) File:"  0 { Load a GUI theme package file }
menuText C OptionsSave "Ulo�it volby" 0 \
  "Ulo�it v�echny nastaviteln� volby do souboru $::optionsFile"
menuText C OptionsAutoSave "Automaticky ukl�dat volby p�i ukon�en�" 20 \
  {Automaticky ukl�dat v�echny volby p�i ukon�en� Scidu}

# Help menu:
menuText C Help "N�pov�da" 0
menuText C HelpContents "Obsah" 0 {Zobrazit str�nku n�pov�dy s obsahem}
menuText C HelpIndex "Index" 0 {Zobrazit str�nku n�pov�dy s indexem}
menuText C HelpGuide "Rychl� pr�vodce" 7 {Zobrazit str�nku n�pov�dy s rychl�m pr�vodcem}
menuText C HelpHints "Rady" 0 {Zobrazit str�nku n�pov�dy s radami}
menuText C HelpContact "Kontakt" 0 {Zobrazit str�nku n�pov�dy s kontaktn�mi informacemi}
menuText C HelpTip "Tip dne" 4 {Zobrazit u�ite�n� tip Scidu}
menuText C HelpStartup "Startovac� okno" 0 {Zobrazit startovac� okno}
menuText C HelpAbout "O aplikaci Scid" 2 {Informace o aplikaci Scid}

# Game info box popup menu:
menuText C GInfoHideNext "Skr�t n�sleduj�c� tah" 0
menuText C GInfoMaterial "Uk�zat hodnoty materi�lu" 15
menuText C GInfoFEN "Uk�zat FEN" 7
menuText C GInfoMarks "Zobrazovat barevn� pole a �ipky" 11
menuText C GInfoWrap "Zalamovat dlouh� ��dky" 0
menuText C GInfoFullComment "Zobrazit �pln� koment��" 15
menuText C GInfoPhotos "Zobrazit fotky" 10
menuText C GInfoTBNothing "Tabulky koncovek: nic" 19
menuText C GInfoTBResult "Tabulky koncovek: jen v�sledek" 23
menuText C GInfoTBAll "Tabulky koncovek: v�sledek a nejlep�� tahy" 39
menuText C GInfoDelete "Vymazat/Nemazat tuto partii" 0
menuText C GInfoMark "Ozna�it/Odzna�it tuto partii" 0
menuText C GInfoInformant "Konfigurovat inform�torov� hodnoty" 0

# General buttons:
translate C Back {Zp�t}
translate C Browse {Prohl�et}
translate C Cancel {Zru�it}
translate C Continue {Pokra�ovat}
translate C Clear {Vy�istit}
translate C Close {Zav��t}
translate C Contents {Obsah}
translate C Defaults {P�edvolen�}
translate C Delete {Vymazat}
translate C Graph {Graf}
translate C Help {N�pov�da}
translate C Import {Import}
translate C Index {Index}
translate C LoadGame {Nat�hnout partii}
translate C BrowseGame {Prohl�dnout partii}
translate C MergeGame {P�ipojit partii}
translate C MergeGames {P�ipojit partie}
translate C Preview {N�hled}
translate C Revert {Vr�tit se}
translate C Save {Ulo�it}
translate C Search {Hledat}
translate C Stop {Stop}
translate C Store {Uschovat}
translate C Update {Aktualizovat}
translate C ChangeOrient {Zm�nit orientaci okna}
translate C ShowIcons {Zobrazit ikony}
translate C None {Nic}
translate C First {Prvn�}
translate C Current {Aktu�ln�}
translate C Last {Posledn�}

# General messages:
translate C game {partie}
translate C games {partie}
translate C move {tah}
translate C moves {tahy}
translate C all {v�e}
translate C Yes {Ano}
translate C No {Ne}
translate C Both {Oba}
translate C King {Kr�l}
translate C Queen {D�ma}
translate C Rook {V�}
translate C Bishop {St�elec}
translate C Knight {Jezdec}
translate C Pawn {P�ec}
translate C White {B�l�}
translate C Black {�ern�}
translate C Player {Hr��}
translate C Rating {Rating}
translate C RatingDiff {Rozd�l v ratingu (B�l� - �ern�)}
translate C AverageRating {Pr�m�rn� rating}
translate C Event {Turnaj}
translate C Site {M�sto}
translate C Country {Zem�}
translate C IgnoreColors {Ignorovat barvy}
translate C Date {Datum}
translate C EventDate {Datum turnaje}
translate C Decade {Dek�da}
translate C Year {Rok}
translate C Month {M�s�c}
translate C Months {Leden �nor B�ezen Duben Kv�ten �erven �ervenec Srpen Z��� ��jen Listopad Prosinec}
translate C Days {Ned Pon �te St� �tv P�t Sob}
translate C YearToToday {Rok zp�t}
# ====== TODO To be translated ======
translate C YearToTodayTooltip {Set date from 1 year back to today}
translate C Result {V�sledek}
translate C Round {Kolo}
translate C Length {D�lka}
translate C ECOCode {ECO k�d}
translate C ECO {ECO}
translate C Deleted {Vymaz�n(a)}
translate C SearchResults {Hledat v�sledky}
translate C OpeningTheDatabase {Datab�ze zah�jen�}
translate C Database {Datab�ze}
translate C Filter {Filtr}
translate C noGames {��dn� partie}
translate C allGames {v�echny partie}
translate C empty {pr�zdn�}
translate C clipbase {schr�nka}
translate C score {sk�re}
translate C StartPos {Po��te�n� pozice}
translate C Total {Celkem}
translate C readonly {jen ke �ten�}

# Standard error messages:
translate C ErrNotOpen {To nen� otev�en� datab�ze.}
translate C ErrReadOnly {Tato datab�ze je jen ke �ten�; nem��e b�t zm�n�na.}
translate C ErrSearchInterrupted {Hled�n� bylo p�eru�eno; v�sledky nejsou kompletn�.}

# Game information:
translate C twin {zdvojen�}
translate C deleted {vymazan�}
translate C comment {koment��}
translate C hidden {skryt�}
translate C LastMove {Posledn� tah}
translate C NextMove {N�sleduj�c� tah}
translate C GameStart {Za��tek partie}
translate C LineStart {Za��tek s�rie tah�}
translate C GameEnd {Konec partie}
translate C LineEnd {Konec s�rie tah�}

# Player information:
translate C PInfoAll {V�sledky <b>v�ech</b> parti�}
translate C PInfoFilter {V�sledky <b>filtrovan�ch</b> parti�}
translate C PInfoAgainst {V�sledky proti}
translate C PInfoMostWhite {Nej�ast�j�� zah�jen� za b�l�}
translate C PInfoMostBlack {Nej�ast�j�� zah�jen� za �ern�}
translate C PInfoRating {Historie ratingu}
translate C PInfoBio {Biografie}
translate C PInfoEditRatings {Editovat ratingy}
# ====== TODO To be translated ======
translate C PInfoEloFile {File}

# Tablebase information:
translate C Draw {Rem�za}
translate C stalemate {pat}
translate C withAllMoves {se v�emi tahy}
translate C withAllButOneMove {se v�emi tahy krom� posledn�ho}
translate C with {s}
translate C only {jen}
translate C lose {prohr�t}
translate C loses {prohr�v�}
translate C allOthersLose {v�echny ostatn� prohr�vaj�}
translate C matesIn {matuje b�hem}
translate C hasCheckmated {zmatoval}
translate C longest {nejdel��}
translate C WinningMoves {vyhr�vaj�c� tahy}
translate C DrawingMoves {remizuj�c� tahy}
translate C LosingMoves {prohr�vaj�c� tahy}
translate C UnknownMoves {tahy s nezn�m�m v�sledkem}
# ====== TODO To be translated ======
translate C SideLongest {Side    Longest    %     %     %\n}
# ====== TODO To be translated ======
translate C toNoveMate {to move   mate    Win  Draw  Loss\n}
# ====== TODO To be translated ======
translate C NoSummary {\nNo summary for this tablebase.}
# ====== TODO To be translated ======
translate C MutualZugzwang {Mutual zugzwangs: }
# ====== TODO To be translated ======
translate C SelectetZugzwang {\nSelected zugzwang positions:}
# ====== TODO To be translated ======
translate C WdrawBloss {White draws, Black loses:}
# ====== TODO To be translated ======
translate C BdrawWloss {Black draws, White loses:}
# ====== TODO To be translated ======
translate C AllLoss {" Whoever moves loses:     " }

# Tip of the day:
translate C Tip {Tip}
translate C TipAtStartup {Tip p�i spu�t�n�}

# Tree window menus:
menuText C TreeFile "Soubor" 0
menuText C TreeFileFillWithBase "Naplnit cache z datab�ze" 0 {Naplnit cachovac� soubor v�emi partiemi z aktu�ln� datab�ze}
menuText C TreeFileFillWithGame "Naplnit cache parti�" 0 {Naplnit cachovac� soubor aktu�ln� parti� z aktu�ln� datab�ze}
menuText C TreeFileSetCacheSize "Velikost cache" 0 {Nastavit velikost cache}
menuText C TreeFileCacheInfo "Informace o cache" 0 {Z�skat informaci o vyu�it� cache}
menuText C TreeFileSave "Ulo�it cache soubor" 0 \
  {Ulo�it stromov� cache (.stc) soubor}
menuText C TreeFileFill "Naplnit cache soubor" 0 \
  {Naplnit cache soubor nejb�n�j��mi pozicemi zah�jen�}
menuText C TreeFileBest "Seznam nejlep��ch parti�" 0 {Zobrazit seznam nejlep��ch parti�  stromu}
menuText C TreeFileGraph "Okno grafu" 0 {Zobrazit graf pro tuto v�tev stromu}
menuText C TreeFileCopy "Kop�rovat text stromu do clipboardu" 0 \
  {Kop�rovat stromov� statistiky do textov�ho v�b�ru}
menuText C TreeFileClose "Zav��t stromov� okno" 0 {Zav��t stromov� okno}
menuText C TreeMask "Maska" 0
menuText C TreeMaskNew "Nov�" 0 {Nov� maska}
menuText C TreeMaskOpen "Otev��t" 0 {Otev��t masku}
menuText C TreeMaskOpenRecent "Otev��t ned�vnou" 0 {Otev��t ned�vnou masku}
menuText C TreeMaskSave "Ulo�it" 0 {Ulo�it masku}
menuText C TreeMaskClose "Zav��t" 0 {Uzav��t masku}
menuText C TreeMaskFillWithGame "Naplnit parti�" 0 {Naplnit masku parti�}
menuText C TreeMaskFillWithBase "Naplnit datab�z�" 0 {Naplnit masku v�emi partiemi z datab�ze}
menuText C TreeMaskInfo "Informace" 0 {Uk�zat statistiku aktu�ln� masky}
menuText C TreeMaskDisplay "Uk�zat mapu masky" 0 {Uk�zat data masky ve form� stromu}
menuText C TreeMaskSearch "Hledat" 0 {Hledat v aktu�ln� masce}
menuText C TreeSort "�adit" 2
menuText C TreeSortAlpha "Abecedn�" 0
menuText C TreeSortECO "ECO k�d" 0
menuText C TreeSortFreq "Frekvence" 0
menuText C TreeSortScore "Sk�re" 0
menuText C TreeOpt "Volby" 0
menuText C TreeOptSlowmode "Pomal� re�im" 0 {Pomal� re�im aktualizace (vysok� p�esnost)}
menuText C TreeOptFastmode "Rychl� re�im" 0 {Rychl� re�im aktualizace (beze zm�ny po�ad� tah�)}
menuText C TreeOptFastAndSlowmode "Rychl� a pomal� re�im" 0 {Rychl� re�im a potom pomal� re�im aktualizace}
menuText C TreeOptStartStop "Automatick� aktualizace" 0 {P�epnout automatick� aktualizace stromov�ho okna}
menuText C TreeOptLock "Zamknout" 0 {Zamknout/Odemknout strom k aktu�ln� datab�zi}
menuText C TreeOptTraining "Tr�nink" 0 {Zapnout/Vypnout stromov� tr�ninkov� m�d}
menuText C TreeOptAutosave "Automatick� ukl�d�n� cache souboru" 0 \
  {Automatick� ukl�d�n� cache souboru p�i uzav�en� stromov�ho okna}
menuText C TreeHelp "N�pov�da" 0
menuText C TreeHelpTree "N�pov�da - Strom" 11
menuText C TreeHelpIndex "Index n�pov�dy" 0
translate C SaveCache {Ulo�it cache}
translate C Training {Tr�nink}
translate C LockTree {Zamknout}
translate C TreeLocked {Zamknuto}
translate C TreeBest {Nejlep��}
translate C TreeBestGames {Nejlep�� partie stromu}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate C TreeTitleRow \
  {    Tah    ECO       Frekvence    Sk�re  PrElo Perf  PrRok %rem�z}
translate C TreeTotal {CELKEM}
translate C DoYouWantToSaveFirst {Chcete nejprve ulo�it}
translate C AddToMask {P�idat do masky}
translate C RemoveFromMask {Odstranit z masky}
translate C AddThisMoveToMask {P�idat tento tah do masky}
translate C SearchMask {Hledat v masce}
translate C DisplayMask {Zobrazit masku}
translate C Nag {Nag k�d}
translate C Marker {Zna�ka}
translate C Include {Zahrnout}
translate C Exclude {Vylou�it}
translate C MainLine {Hlavn� varianta}
translate C Bookmark {Z�lo�ka}
translate C NewLine {Nov� varianta}
translate C ToBeVerified {K prov��en�}
translate C ToTrain {Tr�novat}
translate C Dubious {Pochybn�}
translate C ToRemove {Odstranit}
translate C NoMarker {��dn� zna�ka}
translate C ColorMarker {Barva}
translate C WhiteMark {B�l�}
translate C GreenMark {Zelen�}
translate C YellowMark {�lut�}
translate C BlueMark {Modr�}
translate C RedMark {�erven�}
translate C CommentMove {Okomentovat tah}
translate C CommentPosition {Okomentovat pozici}
translate C AddMoveToMaskFirst {Nejprve p�idejte tah do masky}
translate C OpenAMaskFileFirst {Nejprve otev�ete soubor masky}
translate C Positions {Pozice}
translate C Moves {Tahy}

# Finder window:
menuText C FinderFile "Soubor" 0
menuText C FinderFileSubdirs "Hledat v podadres���ch" 0
menuText C FinderFileClose "Zav��t vyhled�va� soubor�" 0
menuText C FinderSort "�adit" 2
menuText C FinderSortType "Typ" 0
menuText C FinderSortSize "Velikost" 0
menuText C FinderSortMod "Zm�n�no" 0
menuText C FinderSortName "Jm�no" 0
menuText C FinderSortPath "Cesta" 0
menuText C FinderTypes "Typy" 0
menuText C FinderTypesScid "Datab�ze Scidu" 0
menuText C FinderTypesOld "Datab�ze Scidu star�ho form�tu" 15
menuText C FinderTypesPGN "PGN soubory" 0
menuText C FinderTypesEPD "EPD soubory" 0
menuText C FinderTypesRep "Reperto�rov� soubory" 0
menuText C FinderHelp "N�pov�da" 0
menuText C FinderHelpFinder "N�pov�da - Vyhled�va� soubor�" 11
menuText C FinderHelpIndex "Index n�pov�dy" 0
translate C FileFinder {Vyhled�va� soubor�}
translate C FinderDir {Adres��}
translate C FinderDirs {Adres��e}
translate C FinderFiles {Soubory}
translate C FinderUpDir {nahoru}
translate C FinderCtxOpen {Otev��t}
translate C FinderCtxBackup {Z�lohovat}
translate C FinderCtxCopy {Kop�rovat}
translate C FinderCtxMove {P�esunout}
translate C FinderCtxDelete {Smazat}

# Player finder:
menuText C PListFile "Soubor" 0
menuText C PListFileUpdate "Aktualizovat" 0
menuText C PListFileClose "Zav��t vyhled�va� hr���" 0
menuText C PListSort "�adit" 2
menuText C PListSortName "Jm�no" 0
menuText C PListSortElo "ELO" 0
menuText C PListSortGames "Partie" 0
menuText C PListSortOldest "Nejstar��" 3
menuText C PListSortNewest "Nejnov�j��" 3

# Tournament finder:
menuText C TmtFile "Soubor" 0
menuText C TmtFileUpdate "Aktualizovat" 0
menuText C TmtFileClose "Zav��t vyhled�va� soubor�" 0
menuText C TmtSort "�adit" 2
menuText C TmtSortDate "Datum" 0
menuText C TmtSortPlayers "Hr��i" 0
menuText C TmtSortGames "Partie" 0
menuText C TmtSortElo "ELO" 0
menuText C TmtSortSite "M�sto" 0
menuText C TmtSortEvent "Turnaj" 0
menuText C TmtSortWinner "V�t�z" 0
translate C TmtLimit "Limit seznamu"
translate C TmtMeanElo "Pr�m�rn� ELO"
translate C TmtNone "��dn� odpov�daj�c� turnaje nebyly nalezeny."

# Graph windows:
menuText C GraphFile "Soubor" 0
menuText C GraphFileColor "Ulo�it jako barevn� Postscript..." 12
menuText C GraphFileGrey "Ulo�it jako �ernob�l� Postscript..." 13
menuText C GraphFileClose "Zav��t okno" 0
menuText C GraphOptions "Volby" 0
menuText C GraphOptionsWhite "B�l�" 0
menuText C GraphOptionsBlack "�ern�" 1
menuText C GraphOptionsBoth "Oba" 0
menuText C GraphOptionsPInfo "Informace o hr��i" 0
# ====== TODO To be translated ======
menuText C GraphOptionsEloFile "Elo from rating file" 0
# ====== TODO To be translated ======
menuText C GraphOptionsEloDB "Elo from database" 0
translate C GraphFilterTitle "Graf filtru: �etnost na 1000 parti�"
translate C GraphAbsFilterTitle "Graf filtru: �etnost parti�"
translate C ConfigureFilter {Konfigurovat x-sou�adnici pro rok, rating a tahy}
translate C FilterEstimate "Odhadnout"
translate C TitleFilterGraph "Scid: Graf filtru"

# Analysis window:
translate C AddVariation {P�idat variantu}
translate C AddAllVariations {P�idat v�echny varianty}
translate C AddMove {P�idat tah}
translate C Annotate {Anotace}
translate C ShowAnalysisBoard {Uk�zat �achovnici anal�zy}
translate C ShowInfo {Uk�zat informaci o hern�m programu}
translate C FinishGame {Ukon�it partii}
translate C StopEngine {Zastavit hern� program}
translate C StartEngine {Spustit hern� program}
translate C LockEngine {Uzam��t hern� program v aktu�ln� pozici}
translate C AnalysisCommand {Program pro anal�zu}
translate C PreviousChoices {P�edchoz� vybran� programy}
translate C AnnotateTime {Nastavit �as mezi tahy v sekund�ch}
translate C AnnotateWhich {P�idat varianty}
translate C AnnotateAll {Pro tahy obou stran}
translate C AnnotateAllMoves {Anotovat v�echny tahy}
translate C AnnotateWhite {Pouze pro tahy b�l�ho}
translate C AnnotateBlack {Pouze pro tahy �ern�ho}
translate C AnnotateBlundersOnly {Jestli�e tah v partii je evidentn� hrub� chyba}
translate C AnnotateBlundersOnlyScoreChange {Anal�za ukazuje hrubou chybu, jestli�e se sk�re zm�n� z/na: }
translate C BlundersThreshold {Hranice}
# TODO: Translate
translate C ScoreAllMoves {Score all moves}
translate C LowPriority {N�zk� priorita procesoru}
translate C ClickHereToSeeMoves {Klikn�te sem pro zobrazen� tah�}
translate C ConfigureInformant {Inform�tor}
translate C Informant!? {Zaj�mav� tah}
translate C Informant? {Slab� tah}
translate C Informant?? {Hrub� chyba}
translate C Informant?! {Pochybn� tah}
translate C Informant+= {B�l� m� malou v�hodu}
translate C Informant+/- {B�l� m� st�edn� v�hodu}
translate C Informant+- {B�l� m� rozhoduj�c� v�hodu}
translate C Informant++- {Partie je pova�ov�na za vyhranou}
translate C Book {Knihovna zah�jen�}
translate C OtherBookMoves {Soupe�ova knihovna zah�jen�}
translate C OtherBookMovesTooltip {Tahy, na kter� m� soupe� odpov��}
# Analysis Engine open dialog:
translate C EngineList {Seznam hern�ch program� pro anal�zu}
translate C EngineName {Jm�no}
translate C EngineCmd {P��kaz}
translate C EngineArgs {Parametry}
translate C EngineDir {Adres��}
translate C EngineElo {ELO}
translate C EngineTime {Datum}
translate C EngineNew {Nov�}
translate C EngineEdit {Editace}
translate C EngineRequired {Tu�n� vyzna�en� polo�ky jsou povinn�; ostatn� jsou voliteln�}

# PGN window menus:
menuText C PgnFile "Soubor" 0
menuText C PgnFileCopy "Kop�rovat partii do clipboardu" 0
menuText C PgnFilePrint "Vytisknout do souboru..." 0
menuText C PgnFileClose "Zav��t okno PGN" 0
menuText C PgnOpt "Zobrazit" 0
menuText C PgnOptColor "Barevn� zobrazen�" 0
menuText C PgnOptShort "Kr�tk� (t����dkov�) hlavi�ka" 20
menuText C PgnOptSymbols "Symbolick� anotace" 0
menuText C PgnOptIndentC "Odsazovat koment��e" 10
menuText C PgnOptIndentV "Odsazovat varianty" 10
menuText C PgnOptColumn "Sloupcov� styl (jeden tah na ��dek)" 1
menuText C PgnOptSpace "Mezera za ��slem tahu" 0
menuText C PgnOptStripMarks "Odstranit k�dy barevn�ch pol� a �ipek" 0
menuText C PgnOptBoldMainLine "Pou��t tu�n� text pro tahy hlavn� varianty" 4
menuText C PgnColor "Barvy" 0
menuText C PgnColorHeader "Hlavi�ka..." 0
menuText C PgnColorAnno "Anotace..." 0
menuText C PgnColorComments "Koment��e..." 0
menuText C PgnColorVars "Varianty..." 0
menuText C PgnColorBackground "Pozad�..." 0
menuText C PgnColorMain "Hlavn� varianta..." 0
menuText C PgnColorCurrent "Pozad� aktu�ln�ho tahu..." 1
menuText C PgnHelp "N�pov�da" 0
menuText C PgnHelpPgn "N�pov�da - Okno PGN " 16
menuText C PgnHelpIndex "Index n�pov�dy" 0
translate C PgnWindowTitle {Z�pis partie - partie %u}

# Crosstable window menus:
menuText C CrosstabFile "Soubor" 0
menuText C CrosstabFileText "Vytisknout do textov�ho souboru..." 14
menuText C CrosstabFileHtml "Vytisknout do HTML souboru..." 14
menuText C CrosstabFileLaTeX "Vytisknout do LaTeX souboru..." 14
menuText C CrosstabFileClose "Zav��t okno turnajov� tabulky" 0
menuText C CrosstabEdit "Editovat" 0
menuText C CrosstabEditEvent "Turnaj" 0
menuText C CrosstabEditSite "M�sto" 0
menuText C CrosstabEditDate "Datum" 0
menuText C CrosstabOpt "Zobrazit" 0
menuText C CrosstabOptAll "Ka�d� s ka�d�m" 0
menuText C CrosstabOptSwiss "�v�carsk� syst�m" 3
menuText C CrosstabOptKnockout "Vy�azovac�" 4
menuText C CrosstabOptAuto "Auto" 0
menuText C CrosstabOptAges "V�k" 0
menuText C CrosstabOptNats "N�rodnost" 0
menuText C CrosstabOptRatings "Rating" 0
menuText C CrosstabOptTitles "Titul" 0
menuText C CrosstabOptBreaks "V�sledky tie-breaku" 10
menuText C CrosstabOptDeleted "V�etn� vymazan�ch parti�" 9
menuText C CrosstabOptColors "Barvy (jen pro �v�carsk� syst�m)" 0
menuText C CrosstabOptColumnNumbers "��slovan� sloupce (jen v tabulk�ch 'ka�d� s ka�d�m')" 3
menuText C CrosstabOptGroup "Skupiny podle sk�re" 0
menuText C CrosstabSort "�adit" 2
menuText C CrosstabSortName "Jm�no" 0
menuText C CrosstabSortRating "Rating" 0
menuText C CrosstabSortScore "Sk�re" 0
menuText C CrosstabColor "Barvy" 0
menuText C CrosstabColorPlain "Prost� text" 0
menuText C CrosstabColorHyper "Hypertext" 0
menuText C CrosstabHelp "N�pov�da" 0
menuText C CrosstabHelpCross "N�pov�da - Turnajovou tabulku" 11
menuText C CrosstabHelpIndex "Index n�pov�dy" 0
translate C SetFilter {Nastavit filtr}
translate C AddToFilter {P�idat do filtru}
translate C Swiss {�v�carsk� syst�m}
translate C Category {Kategorie}

# Opening report window menus:
menuText C OprepFile "Soubor" 0
menuText C OprepFileText "Vytisknout do textov�ho souboru..." 14
menuText C OprepFileHtml "Vytisknout do HTML souboru..." 14
menuText C OprepFileLaTeX "Vytisknout do LaTeX souboru..." 14
menuText C OprepFileOptions "Volby" 0
menuText C OprepFileClose "Zav��t okno s profilem" 0
menuText C OprepFavorites "Obl�ben�" 0
menuText C OprepFavoritesAdd "P�idat profil..." 0
menuText C OprepFavoritesEdit "Editovat obl�ben� profily..." 0
menuText C OprepFavoritesGenerate "Generovat profil..." 0
menuText C OprepHelp "N�pov�da" 0
menuText C OprepHelpReport "N�pov�da - Profil zah�jen�" 11
menuText C OprepHelpIndex "Index n�pov�dy" 11

# Header search:
translate C HeaderSearch {Hledat podle hlavi�ky}
translate C EndSideToMove {Strana na tahu na konci hry}
translate C GamesWithNoECO {Partie bez ECO?}
translate C GameLength {D�lka Partie}
translate C FindGamesWith {Naj�t partie s p��znaky}
translate C StdStart {Nestandardn� start}
translate C Promotions {Prom�ny}
translate C Comments {Koment��e}
translate C Variations {Varianty}
translate C Annotations {Anotace}
translate C DeleteFlag {Mazac� p��znak}
translate C WhiteOpFlag {Zah�jen� b�l�ho}
translate C BlackOpFlag {Zah�jen� �ern�ho}
translate C MiddlegameFlag {St�edn� hra}
translate C EndgameFlag {Koncovka}
translate C NoveltyFlag {Novinka}
translate C PawnFlag {P�cov� struktura}
translate C TacticsFlag {Taktika}
translate C QsideFlag {Hra na d�msk�m k��dle}
translate C KsideFlag {Hra na kr�lovsk�m k��dle}
translate C BrilliancyFlag {Velmi siln� tah}
translate C BlunderFlag {Hrub� chyba}
translate C UserFlag {U�ivatel}
translate C PgnContains {PGN obsahuje text}
# ====== TODO To be translated ======
translate C Annotator {Annotator}
# ====== TODO To be translated ======
translate C Cmnts {Annotated games only}

# Game list window:
translate C GlistNumber {��slo}
translate C GlistWhite {B�l�}
translate C GlistBlack {�ern�}
translate C GlistWElo {B-ELO}
translate C GlistBElo {�-ELO}
translate C GlistEvent {Turnaj}
translate C GlistSite {M�sto}
translate C GlistRound {Kolo}
translate C GlistDate {Datum}
translate C GlistYear {Rok}
translate C GlistEDate {Datum turnaje}
translate C GlistResult {V�sledek}
translate C GlistLength {D�lka}
translate C GlistCountry {Zem�}
translate C GlistECO {ECO}
translate C GlistOpening {Zah�jen�}
translate C GlistEndMaterial {Materi�l na konci}
translate C GlistDeleted {Vymaz�n(a)}
translate C GlistFlags {P��znak}
translate C GlistVars {Varianty}
translate C GlistComments {Koment��e}
translate C GlistAnnos {Anotace}
translate C GlistStart {Po��te�n� pozice}
translate C GlistGameNumber {��slo partie}
# ====== TODO To be translated ======
translate C GlistAverageElo {Average Elo}
# ====== TODO To be translated ======
translate C GlistRating {Rating}
translate C GlistFindText {Hledat text}
translate C GlistMoveField {P�esunout}
translate C GlistEditField {Konfigurovat}
translate C GlistAddField {P�idat}
translate C GlistDeleteField {Odebrat}
translate C GlistWidth {���ka}
translate C GlistAlign {Zarovnat}
# ====== TODO To be translated ======
translate C GlistAlignL {Align: left}
# ====== TODO To be translated ======
translate C GlistAlignR {Align: right}
# ====== TODO To be translated ======
translate C GlistAlignC {Align: center}
translate C GlistColor {Barva}
translate C GlistSep {Odd�lova�}
# ====== TODO To be translated ======
translate C GlistCurrentSep {-- Current --}
# ====== TODO To be translated ======
translate C GlistNewSort {New}
# ====== TODO To be translated ======
translate C GlistAddToSort {Add}
# ====== TODO To be translated ======
translate C GsortSort {Sort...}
# ====== TODO To be translated ======
translate C GsortDate {Date}
# ====== TODO To be translated ======
translate C GsortYear {Year}
# ====== TODO To be translated ======
translate C GsortEvent {Event}
# ====== TODO To be translated ======
translate C GsortSite {Site}
# ====== TODO To be translated ======
translate C GsortRound {Round}
# ====== TODO To be translated ======
translate C GsortWhiteName {White Name}
# ====== TODO To be translated ======
translate C GsortBlackName {Black Name}
# ====== TODO To be translated ======
translate C GsortECO {ECO}
# ====== TODO To be translated ======
translate C GsortResult {Result}
# ====== TODO To be translated ======
translate C GsortMoveCount {Move Count}
# ====== TODO To be translated ======
translate C GsortAverageElo {Average Elo}
# ====== TODO To be translated ======
translate C GsortCountry {Country}
# ====== TODO To be translated ======
translate C GsortDeleted {Deleted}
# ====== TODO To be translated ======
translate C GsortEventDate {Event Date}
# ====== TODO To be translated ======
translate C GsortWhiteElo {White Elo}
# ====== TODO To be translated ======
translate C GsortBlackElo {Black Elo}
# ====== TODO To be translated ======
translate C GsortComments {Comments}
# ====== TODO To be translated ======
translate C GsortVariations {Variations}
# ====== TODO To be translated ======
translate C GsortNAGs {NAGs}
# ====== TODO To be translated ======
translate C GsortAscending {Ascending}
# ====== TODO To be translated ======
translate C GsortDescending {Descending}
# ====== TODO To be translated ======
translate C GsortAdd {Add}
# ====== TODO To be translated ======
translate C GsortStore {Store}
# ====== TODO To be translated ======
translate C GsortLoad {Load}
translate C GlistRemoveThisGameFromFilter  {Odstranit tuto partii z filtru}
translate C GlistRemoveGameAndAboveFromFilter  {Odstranit partii (a v�echny nad n�) z filtru}
translate C GlistRemoveGameAndBelowFromFilter  {Odstranit partii (a v�echny pod n�) z filtru}
translate C GlistDeleteGame {Smazat/obnovit tuto partii} 
translate C GlistDeleteAllGames {Smazat v�echny partii obsa�en� ve filtru} 
translate C GlistUndeleteAllGames {Obnovit v�echny smazan� partie obsa�en� ve filtru} 
translate C GlistMergeGameInBase {P�ipojit partii z jin� datab�ze} 

# Maintenance window:
translate C DatabaseName {Jm�no datab�ze:}
translate C TypeIcon {Symbol:}
translate C NumOfGames {Partie:}
translate C NumDeletedGames {Vymazan� partie:}
translate C NumFilterGames {Partie ve filtru:}
translate C YearRange {Rozsah rok�:}
translate C RatingRange {Rozsah ratingu:}
translate C Description {Popis}
translate C Flag {P��znak}
translate C CustomFlags {U�ivatelsk� p��znaky}
translate C DeleteCurrent {Vymazat aktu�ln� partii}
translate C DeleteFilter {Vymazat filtrovan� partie}
translate C DeleteAll {Vymazat v�echny partie}
translate C UndeleteCurrent {Obnovit aktu�ln� partie po vymaz�n�}
translate C UndeleteFilter {Obnovit filtrovan� partie po vymaz�n�}
translate C UndeleteAll {Obnovit v�echny partie po vymaz�n�}
translate C DeleteTwins {Vymazat zdvojen� partie}
translate C MarkCurrent {Ozna�it aktivn� partii}
translate C MarkFilter {Ozna�it filtrovan� partie}
translate C MarkAll {Ozna�it v�echny partie}
translate C UnmarkCurrent {Odzna�it aktu�ln� partii}
translate C UnmarkFilter {Odzna�it filtrovan� partie}
translate C UnmarkAll {Odzna�it v�echny partie}
translate C Spellchecking {Kontrola pravopisu}
translate C Players {Hr��i}
translate C Events {Turnaje}
translate C Sites {M�sta}
translate C Rounds {Kola}
translate C DatabaseOps {Datab�zov� operace}
translate C ReclassifyGames {ECO klasifikace parti�}
translate C CompactDatabase {Zhutnit datab�zi}
translate C SortDatabase {�adit datab�zi}
translate C AddEloRatings {P�idat ELO rating}
translate C AutoloadGame {Automaticky otev�rat partii �.}
translate C StripTags {Odstranit PGN zna�ky}
translate C StripTag {Odstranit zna�ku}
translate C Cleaner {�i�t�n� datab�ze}
translate C CleanerHelp {
    �i�t�n�m datab�ze Scid provede u aktu�ln� datab�ze v�echny �dr�b��sk� akce, kter� zvol�te v seznamu.

    Pokud zvol�te ECO klasifikaci a maz�n� zdvojen�ch parti� pou�ij� se aktu�ln� nastaven� z p��slu�n�ch dialog�.
}
translate C CleanerConfirm {
Jakmile je �i�t�n� jednou spu�t�no, nem��e ji� b�t p�eru�eno!

Tato akce m��e pro velk� datab�ze trvat dlouhou dobu v z�vislosti na funkc�ch, kter� jste zvolili, a v z�vislosti na jejich st�vaj�c�m nastaven�.

Jste si jisti, �e chcete za��t s �dr�b��sk�mi funkcemi, kter� jste zvolili?
}
# ====== TODO To be translated ======
translate C TwinCheckUndelete {to flip; "u" undeletes both)}
translate C TwinCheckprevPair {P�edchoz� dvojice}
translate C TwinChecknextPair {N�sleduj�c� dvojice}
translate C TwinChecker {Scid: Kontrola zdvojen�ch parti�}
translate C TwinCheckTournament {Partie turnaje:}
translate C TwinCheckNoTwin {��dn� duplicita  }
translate C TwinCheckNoTwinfound {Pro tuto partii nebyla nalezena ��dn� zdvojen� partie.\nPro zobrazen� zdvojen�ch parti� v tomto okn� mus�te nejprve pou��t funkci "Smazat zdvojen� partie...". }
translate C TwinCheckTag {Sd�let zna�ky...}
translate C TwinCheckFound1 {Scid na�el $result zdvojen�ch parti�}
translate C TwinCheckFound2 { a nastavil jim p��znak smaz�n�}
translate C TwinCheckNoDelete {V t�to datab�zi nejsou ��dn� partie ke smaz�n�.}
translate C TwinCriteria1 { Va�e nastaven� pro hled�n� zdvojen�ch parti� mohou zp�sobit ozna�en�\nnezdvojen�ch parti� s podobn�mi tahy jako zdvojen� partie.}
translate C TwinCriteria2 {Pokud pro "stejn� tahy" uvedete "Ne", doporu�uje se uv�st "Ano" pro barvu, ud�lost, m�sto, kolo, rok a m�s�c.\Chcete p�esto pokra�ovat a smazat zdvojen� partie? }
translate C TwinCriteria3 {Doporu�uje se uv�st "Ano" pro alespo� dv� z nastaven� "stejn� m�sto", "stejn� kolo" a "stejn� rok".\nChcete p�esto pokra�ovat a smazat zdvojen� partie?}
translate C TwinCriteriaConfirm {Scid: Potvrdit nastaven� dvojic}
translate C TwinChangeTag "Zm�nit n�sleduj�c� tagy partie:\n\n"
translate C AllocRatingDescription "Tento p��kaz pou�ije aktu�ln� soubor kontroly p�eklep� pro p�id�n� Elo rating� do parti� v t�to datab�zi. Pokud n�jak� hr�� nem� aktu�ln� rating, ale jeho rating z doby sehr�n� partie je uveden v souboru kontroly p�eklep�, bude tento jeho rating p�id�n."
translate C RatingOverride "P�epsat st�vaj�c� nenulov� ratingy?"
translate C AddRatings "P�idat ratingy do:"
translate C AddedRatings {Scid p�idal $r Elo rating� v $g parti�ch.}
translate C NewSubmenu "Nov� podmenu"

# Comment editor:
translate C AnnotationSymbols  {Anota�n� symboly:}
translate C Comment {Koment��:}
translate C InsertMark {Vlo�it zna�ku}
translate C InsertMarkHelp {
Vlo�it/odstranit zna�ky: Vyberte barvu, typ, pole.
Vlo�it/odstranit �ipku: Klikn�te prav�m tla��tkem na dv� pole.
}

# Nag buttons in comment editor:
translate C GoodMove {Dobr� tah}
translate C PoorMove {Slab� tah}
translate C ExcellentMove {V�born� tah}
translate C Blunder {Hrub� chyba}
translate C InterestingMove {Zaj�mav� tah}
translate C DubiousMove {Pochybn� tah}
translate C WhiteDecisiveAdvantage {B�l� m� rozhoduj�c� v�hodu}
translate C BlackDecisiveAdvantage {�ern� m� rozhoduj�c� v�hodu}
translate C WhiteClearAdvantage {B�l� m� jasnou v�hodu}
translate C BlackClearAdvantage {�ern� m� jasnou v�hodu}
translate C WhiteSlightAdvantage {B�l� m� malou v�hodu}
translate C BlackSlightAdvantage {�ern� m� malou v�hodu}
translate C Equality {Rovn� �ance}
translate C Unclear {Nejasn� pozice}
translate C Diagram {Diagram}

# Board search:
translate C BoardSearch {Hledat pozici}
translate C FilterOperation {Operace s aktu�ln�m filtrem:}
translate C FilterAnd {A (Omezit filtr)}
translate C FilterOr {NEBO (P�idat k filtru)}
translate C FilterIgnore {IGNOROVAT (Ignoruj filtr)}
translate C SearchType {Typ hled�n�:}
translate C SearchBoardExact {P�esn� pozice (v�echny figury na stejn�ch pol�ch)}
translate C SearchBoardPawns {P�ci (tent�� materi�l, v�ichni p�ci na stejn�ch pol�ch)}
translate C SearchBoardFiles {Sloupce (tent�� materi�l, v�ichni p�ci na stejn�ch sloupc�ch)}
translate C SearchBoardAny {Jak�koliv (tent�� materi�l, p�ci a figury kdekoliv)}
translate C SearchInRefDatabase { Hledat v datab�zi }
translate C LookInVars {D�vat se do variant}

# Material search:
translate C MaterialSearch {Hledat materi�l}
translate C Material {Materi�l}
translate C Patterns {Vzory}
translate C Zero {Nic}
translate C Any {Cokoliv}
translate C CurrentBoard {Aktu�ln� pozice}
translate C CommonEndings {Typick� koncovky}
translate C CommonPatterns {Typick� vzory}
translate C MaterialDiff {Rozd�l v materi�lu}
translate C squares {pole}
translate C SameColor {Stejnobarevn�}
translate C OppColor {Nestejnobarevn�}
translate C Either {Oboj�}
translate C MoveNumberRange {Rozsah tah�}
translate C MatchForAtLeast {Shoda pro minim�ln�}
translate C HalfMoves {p�ltah�}

# Common endings in material search:
translate C EndingPawns {P�cov� koncovky}
translate C EndingRookVsPawns {V� proti p�c�m}
translate C EndingRookPawnVsRook {V� a 1 p�ec proti v�i}
translate C EndingRookPawnsVsRook {V� a p�ci proti v�i}
translate C EndingRooks {V�ov� koncovky}
translate C EndingRooksPassedA {V�ov� koncovky s voln�m a-p�cem}
translate C EndingRooksDouble {�ty�v�ov� koncovky}
translate C EndingBishops {St�elcov� koncovky}
translate C EndingBishopVsKnight {Koncovky st�elce proti jezdci}
translate C EndingKnights {Jezdcov� koncovky}
translate C EndingQueens {D�msk� koncovky}
translate C EndingQueenPawnVsQueen {D�ma a 1 p�ec proti d�m�}
translate C BishopPairVsKnightPair {Dvojice st�elc� proti dvojici jezdc� ve st�edn� h�e}

# Common patterns in material search:
translate C PatternWhiteIQP {B�l� d�msk� izolovan� p�ec}
translate C PatternWhiteIQPBreakE6 {B�l� d�msk� izolovan� p�ec: pr�lom d4-d5 proti e6}
translate C PatternWhiteIQPBreakC6 {B�l� d�msk� izolovan� p�ec: pr�lom d4-d5 proti c6}
translate C PatternBlackIQP {�ern� d�msk� izolovan� p�ec}
translate C PatternWhiteBlackIQP {B�l� d�msk� izolovan� p�ec proti �ern�mu d�msk�mu izolovan�mu p�ci}
translate C PatternCoupleC3D4 {P�r b�l�ch izolovan�ch p�c� c3+d4}
translate C PatternHangingC5D5 {�ern� vis�c� p�ci na c5 a d5}
translate C PatternMaroczy {Maroczyho centrum (s p�ci na c4 a e4)}
translate C PatternRookSacC3 {Ob� v�e na c3}
translate C PatternKc1Kg8 {O-O-O proti O-O (Kc1 proti Kg8)}
translate C PatternKg1Kc8 {O-O proti O-O-O (Kg1 proti Kc8)}
translate C PatternLightFian {Fianchetta na b�l�ch pol�ch (st�elec g2 proti st�elci b7)}
translate C PatternDarkFian {Fianchetta na �ern�ch pol�ch (st�elec b2 proti st�elci g7)}
translate C PatternFourFian {�ty�i fianchetta (st�elci na b2,g2,b7,g7)}

# Game saving:
translate C Today {Dnes}
translate C ClassifyGame {Klasifikovat partii}

# Setup position:
translate C EmptyBoard {Vypr�zdnit �achovnici}
translate C InitialBoard {V�choz� pozice}
translate C SideToMove {Na tahu je}
translate C MoveNumber {��slo tahu}
translate C Castling {Ro��da}
translate C EnPassantFile {En Passant sloupec}
translate C ClearFen {Vy�istit FEN}
translate C PasteFen {Vlo�it FEN}
translate C SaveAndContinue {Ulo�it a pokra�ovat}
translate C DiscardChangesAndContinue {Zru�it zm�ny\na pokra�ovat}
translate C GoBack {J�t zp�t}

# Replace move dialog:
translate C ReplaceMove {Nahradit tah}
translate C AddNewVar {P�idat novou variantu}
translate C NewMainLine {Nov� hlavn� varianta}
translate C ReplaceMoveMessage {Zde ji� existuje tah.

M��ete ho nahradit, a zru�it tak i v�echny n�sleduj�c� tahy, nebo m��ete v� tah p�idat jako novou variantu.

(Zobrazen� t�to zpr�vy m��ete v budoucnu potla�it p�epnut�m volby "Pt�t se p�ed nahrazen�m tah�" v menu Volby:Tahy.)}

# Make database read-only dialog:
translate C ReadOnlyDialog {Pokud datab�zi nastav�te jako jen ke �ten�, nebudou povoleny ��dn� zm�ny.
��dn� partie nebude mo�no ulo�it ani p�epsat a ��dn� mazac� p��znak nebude mo�no zm�nit.
V�echny v�sledky operace �azen� �i ECO klasifikace budou pouze do�asn�.

Datab�zi m��ete u�init op�t zapisovatelnou pomoc� jej�ho zav�en� a op�tovn�ho otev�en�.

P�ejete si skute�n� nastavit tuto datab�zi jako jen ke �ten�?}

# Clear game dialog:
translate C ClearGameDialog {Tato partie byla zm�n�na.

Skute�n� chcete pokra�ovat a zru�it zm�ny, kter� jste v n� u�inili?
}

# Exit dialog:
translate C ExitDialog {Opravdu si p�ejete ukon�it Scid?}
translate C ExitUnsaved {N�sleduj�c� datab�ze obsahuj� partie s neulo�en�mi zm�nami. Pokud nyn� skon��te, budou tyto zm�ny ztraceny.}

# Import window:
translate C PasteCurrentGame {Vlo�it aktu�ln� partii}
translate C ImportHelp1 {Zapsat nebo vlo�it partii ve form�tu PGN do r�mce naho�e.}
translate C ImportHelp2 {Jak�koli chyby p�i importu partie budou zobrazeny zde.}
translate C OverwriteExistingMoves {P�epsat st�vaj�c� tahy?}

# ECO Browser:
translate C ECOAllSections {v�echny ECO sekce}
translate C ECOSection {ECO sekce}
translate C ECOSummary {Souhrn pro}
translate C ECOFrequency {Frekvence subk�d� pro}

# Opening Report:
translate C OprepTitle {Profil zah�jen�}
translate C OprepReport {Profil}
translate C OprepGenerated {Generov�n}
translate C OprepStatsHist {Statistika a historie}
translate C OprepStats {Statistika}
translate C OprepStatAll {V�echny partie profilu}
translate C OprepStatBoth {Oba ratingovan�}
translate C OprepStatSince {Od}
translate C OprepOldest {Nejstar�� partie}
translate C OprepNewest {Nejnov�j�� partie}
translate C OprepPopular {St�vaj�c� popularita}
translate C OprepFreqAll {Frekvence za v�echny roky: }
translate C OprepFreq1   {B�hem posledn�ho roku:     }
translate C OprepFreq5   {B�hem posledn�ch 5 let:    }
translate C OprepFreq10  {B�hem posledn�ch 10 let:   }
translate C OprepEvery {jednou z %u parti�}
translate C OprepUp {v�ce o %u%s v porovn�n� se v�emi roky}
translate C OprepDown {m�n� o %u%s v porovn�n� se v�emi roky}
translate C OprepSame {��dn� zm�na p�i porovn�n� se v�emi roky}
translate C OprepMostFrequent {Nej�ast�j�� hr��i}
translate C OprepMostFrequentOpponents {Nej�ast�j�� soupe�i}
translate C OprepRatingsPerf {Ratingy a performance}
translate C OprepAvgPerf {Pr�m�rn� ratingy a performance}
translate C OprepWRating {Rating b�l�}
translate C OprepBRating {Rating �ern�}
translate C OprepWPerf {Performance b�l�}
translate C OprepBPerf {Performance �ern�}
translate C OprepHighRating {Partie s nejvy���m pr�m�rn�m ratingem}
translate C OprepTrends {V�sledkov� trend}
translate C OprepResults {D�lka parti� a frekvence}
translate C OprepLength {D�lka parti�}
translate C OprepFrequency {Frekvence}
translate C OprepWWins {V�hry b�l�: }
translate C OprepBWins {V�hry �ern�: }
translate C OprepDraws {Rem�zy:      }
translate C OprepWholeDB {cel� datab�ze}
translate C OprepShortest {Nejkrat�� v�hry}
translate C OprepMovesThemes {Tahy a t�mata}
translate C OprepMoveOrders {Posloupnosti tah� vedouc� k profilovan� pozici}
translate C OprepMoveOrdersOne \
  {Nalezena pouze jedna posloupnost tah� vedouc�ch k t�to pozici:}
translate C OprepMoveOrdersAll \
  {Nalezeno %u posloupnost� tah� vedouc�ch k t�to pozici:}
translate C OprepMoveOrdersMany \
  {Nalezeno %u posloupnost� tah� vedouc�ch k t�to pozici. Prvn�ch %u jsou:}
translate C OprepMovesFrom {Tahy z profilovan� pozice}
translate C OprepMostFrequentEcoCodes {Nej�ast�j�� ECO k�dy}
translate C OprepThemes {Pozi�n� t�mata}
translate C OprepThemeDescription {Frekvence t�mat v prvn�ch %u taz�ch ka�d� partie}
translate C OprepThemeSameCastling {Ro��dy na stejnou stranu}
translate C OprepThemeOppCastling {Ro��dy na r�zn� strany}
translate C OprepThemeNoCastling {Ob� strany bez ro��dy}
translate C OprepThemeKPawnStorm {P�cov� �tok na kr�lovsk�m k��dle}
translate C OprepThemeQueenswap {Vym�n�n� d�my}
translate C OprepThemeWIQP {B�l� izolovan� d�msk� p�ec}
translate C OprepThemeBIQP {�ern� izolovan� d�msk� p�ec}
translate C OprepThemeWP567 {B�l� p�ec na 5., 6. nebo 7. �ad�}
translate C OprepThemeBP234 {�ern� p�ec na 2., 3. nebo 4. �ad�}
translate C OprepThemeOpenCDE {Otev�en� sloupec C, D nebo E}
translate C OprepTheme1BishopPair {Jedna strana m� dvojici st�elc�}
translate C OprepEndgames {Koncovky}
translate C OprepReportGames {Profilovan� partie}
translate C OprepAllGames {V�echny partie}
translate C OprepEndClass {Materi�lu na konci ka�d� partie}
translate C OprepTheoryTable {Tabulka teorie}
translate C OprepTableComment {Generov�no z %u parti� s nejvy���m pr�m�rn�m ratingem.}
translate C OprepExtraMoves {Extra pozn�mkov� tahy v tabulce teorie}
translate C OprepMaxGames {Maximum tah� v tabulce teorie}
translate C OprepViewHTML {Zobrazit HTML}
translate C OprepViewLaTeX {Zobrazit LaTeX}

# Player Report:
translate C PReportTitle {Profil hr��e}
translate C PReportColorWhite {b�l�mi figurami}
translate C PReportColorBlack {�ern�mi figurami}
translate C PReportMoves {po %s}
translate C PReportOpenings {Zah�jen�}
translate C PReportClipbase {Vypr�zdnit schr�nku a zkop�rovat do n� odpov�daj�c� partie}

# Piece Tracker window:
translate C TrackerSelectSingle {Lev�m tla��tkem my�i se tato figura vybere.}
translate C TrackerSelectPair {Lev�m tla��tkem se tato figura vybere; prav�m se vyberou ob� stejn� figury.}
translate C TrackerSelectPawn {Lev�m tla��tkem se vybere tento p�ec; prav�m se vybere v�ech 8 p�c�.}
translate C TrackerStat {Statistika}
translate C TrackerGames {% parti� s tahem na pole}
translate C TrackerTime {% �asu na ka�d�m poli}
translate C TrackerMoves {Tahy}
translate C TrackerMovesStart {Vlo�te ��slo tahu, kter�m m� stopov�n� za��t.}
translate C TrackerMovesStop {Vlo�te ��slo tahu, kter�m m� stopov�n� skon�it.}

# Game selection dialogs:
translate C SelectAllGames {V�echny partie v datab�zi}
translate C SelectFilterGames {Jen filtrovan� partie}
translate C SelectTournamentGames {Jen partie z aktu�ln�ho turnaje}
translate C SelectOlderGames {Jen star�� partie}

# Delete Twins window:
translate C TwinsNote {Aby byly dv� partie vyhodnoceny jako zdvojen�, mus� b�t hr�ny t�mi� dv�ma hr��i a d�le mus� spl�ovat krit�ria, kter� nastav�te n�e. Pokud jsou nalezeny zdvojen� partie, pak je krat�� z nich vymaz�na. Rada: je vhodn� prov�st p�ed vymaz�n�m zdvojen�ch parti� kontrolu pravopisu, nebo� to zdokonal� detekci zdvojen�ch parti�.}
translate C TwinsCriteria {Krit�ria: Zdvojen� partie mus� m�t...}
translate C TwinsWhich {Jak� partie prozkoumat}
translate C TwinsColors {Tyt� barvy u hr���?}
translate C TwinsEvent {Tent�� turnaj?}
translate C TwinsSite {Tot� m�sto?}
translate C TwinsRound {Tot� kolo?}
translate C TwinsYear {Tent�� rok?}
translate C TwinsMonth {Tent�� m�s�c?}
translate C TwinsDay {Tent�� den?}
translate C TwinsResult {Tent�� v�sledek?}
translate C TwinsECO {Tent�� ECO k�d?}
translate C TwinsMoves {Tyt� tahy?}
translate C TwinsPlayers {Porovn�n� jmen:}
translate C TwinsPlayersExact {P�esn� shoda}
translate C TwinsPlayersPrefix {Jen prvn� 4 znaky}
translate C TwinsWhen {Pokud se budou mazat zdvojen� partie}
translate C TwinsSkipShort {Ignorovat v�echny partie krat�� ne� 5 tah�?}
translate C TwinsUndelete {Obnovit nejprve v�echny partie?}
translate C TwinsSetFilter {Nastavit filtr na v�echny vymazan� zdvojen� partie?}
translate C TwinsComments {V�dy zachovat partie s koment��i?}
translate C TwinsVars {V�dy zachovat partie s variantami?}
translate C TwinsDeleteWhich {Kterou partii vymazat:}
translate C TwinsDeleteShorter {Krat�� partii}
translate C TwinsDeleteOlder {Partii s ni���m ��slem}
translate C TwinsDeleteNewer {Partii s vy���m ��slem}
translate C TwinsDelete {Vymazat partie}

# Name editor window:
translate C NameEditType {Typ jm�na pro editaci}
translate C NameEditSelect {Partie k editaci}
translate C NameEditReplace {Nahradit}
translate C NameEditWith {}
translate C NameEditMatches {Shoduje se: Stiskni Ctrl+1 a� Ctrl+9 pro v�b�r}
# ====== TODO To be translated ======
translate C CheckGames {Check games}
# ====== TODO To be translated ======
translate C CheckGamesWhich {Check games}
# ====== TODO To be translated ======
translate C CheckAll {All games}
# ====== TODO To be translated ======
translate C CheckSelectFilterGames {Only games in filter}

# Classify window:
translate C Classify {Klasifikace}
translate C ClassifyWhich {ECO klasifikace kter�ch parti�}
translate C ClassifyAll {V�echny partie (p�epsat star� ECO k�dy)}
translate C ClassifyYear {V�echny partie hran� za posledn� rok}
translate C ClassifyMonth {V�echny partie hran� za posledn� m�s�c}
translate C ClassifyNew {Jen partie, kter� jsou zat�m bez ECO k�du}
translate C ClassifyCodes {Pou��t tyto ECO k�dy}
translate C ClassifyBasic {Jen z�kladn� k�dy ("B12", ...)}
translate C ClassifyExtended {Roz���en� Scidu  ("B12j", ...)}

# Compaction:
translate C NameFile {Jmenn� soubor}
translate C GameFile {Partiov� soubor}
translate C Names {Jm�na}
translate C Unused {Nepou�ito}
translate C SizeKb {Velikost (kb)}
translate C CurrentState {Aktu�ln� stav}
translate C AfterCompaction {Po zhu�t�n�}
translate C CompactNames {Zhustit jmenn� soubor}
translate C CompactGames {Zhustit partiov� soubor}
translate C NoUnusedNames "Nejsou ��dn� nevyu�it� jm�na, tak�e jmenn� soubor je ji� pln� zhu�t�n."
translate C NoUnusedGames "Partiov� soubor je ji� pln� zhu�t�n."
translate C GameFileCompacted {Partiov� soubor pro datab�zi byl zhu�t�n.}

# Sorting:
translate C SortCriteria {Krit�ria}
translate C AddCriteria {P�idat krit�ria}
translate C CommonSorts {B�n� �azen�}
translate C Sort {Set��dit}

# Exporting:
translate C AddToExistingFile {P�idat partie do existuj�c�ho souboru?}
translate C ExportComments {Exportovat koment��e?}
translate C ExportVariations {Exportovat varianty?}
translate C IndentComments {Odsazovat koment��e?}
translate C IndentVariations {Odsazovat varianty?}
translate C ExportColumnStyle {Sloupcov� styl (jeden tah na ��dek)?}
translate C ExportSymbolStyle {Styl pro symbolick� anotace:}
translate C ExportStripMarks {Odstranit k�dov� zna�ky pol�/�ipek z koment���?}

# Goto game/move dialogs:
translate C LoadGameNumber {Vlo�te ��slo partie:}
translate C GotoMoveNumber {P�ej�t na tah ��slo:}

# Copy games dialog:
translate C CopyGames {Kop�rovat partie}
translate C CopyConfirm {
 Skute�n� chcete kop�rovat
 [::utils::thousands $nGamesToCopy] filtrovan�ch parti�
 z datab�ze "$fromName"
 do datab�ze "$targetName"?
}
translate C CopyErr {Nelze zkop�rovat partie}
translate C CopyErrSource {zdrojov� datab�ze}
translate C CopyErrTarget {c�lov� datab�ze}
translate C CopyErrNoGames {nem� ��dn� partie ve filtru}
translate C CopyErrReadOnly {je pouze ke �ten�}
translate C CopyErrNotOpen {nen� otev�ena}

# Colors:
translate C LightSquares {B�l� pole}
translate C DarkSquares {�ern� pole}
translate C SelectedSquares {Vybran� pole}
translate C SuggestedSquares {Pole navrhovan�ch tah�}
translate C WhitePieces {B�l� figury}
translate C BlackPieces {�ern� figury}
translate C WhiteBorder {Obrys b�l�ch figur}
translate C BlackBorder {Obrys �ern�ch figur}

# Novelty window:
translate C FindNovelty {Hledat novinku}
translate C Novelty {Novinka}
translate C NoveltyInterrupt {Hled�n� novinky p�eru�eno}
translate C NoveltyNone {V t�to partii nebyla nalezena ��dn� novinka}
translate C NoveltyHelp {
Scid bude hledat prvn� tah aktu�ln� partie, kter� dos�hne pozice, kter� se nevyskytla ve vybran� datab�zi ani v knihovn� zah�jen� ECO.
}

# Sounds configuration:
translate C SoundsFolder {Adres�� se zvukov�mi soubory}
translate C SoundsFolderHelp {Adres�� by m�l obsahovat soubory King.wav, a.wav, 1.wav, atd.}
translate C SoundsAnnounceOptions {Volby oznamov�n� tahu}
translate C SoundsAnnounceNew {Oznamovat tahy p�i jejich proveden�}
translate C SoundsAnnounceForward {Oznamovat tahy p�i posunu o tah vp�ed}
translate C SoundsAnnounceBack {Oznamovat p�i vzet� tahu zp�t nebo posunu o tah zp�t}
# ====== TODO To be translated ======
translate C SoundsSoundDisabled {Scid could not find the Snack audio package at startup;\nSound is disabled.}

# Upgrading databases:
translate C Upgrading {Upgrade}
translate C ConfirmOpenNew {
Toto je star� form�t (Scid 3) datab�ze, jen� nen� mo�no otev��t ve Scidu 4. Verze s nov�m form�tem (Scid 4) p�itom ji� byla vytvo�ena.

Chcete otev��t verzi s nov�m form�tem dat�b�ze?
}
translate C ConfirmUpgrade {
Toto je star� form�t (Scid 3) datab�ze. K otev�en� ve Scidu 4 je nutno datab�zi nejprve zkonvertovat do nov�ho form�tu.

Upgrade vytvo�� novou verzi datab�ze.

Tento �kon m��e zabrat trochu �asu, ale je t�eba jej prov�st pouze jednou. M��ete ho p�eru�it, pokud bude trvat p��li� dlouho.

Chcete tuto datab�zi upgradovat nyn�?
}

# Recent files options:
translate C RecentFilesMenu {Po�et ned�vn�ch soubor� v menu Soubor}
translate C RecentFilesExtra {Po�et ned�vn�ch soubor� v extra podmenu}

# My Player Names options:
translate C MyPlayerNamesDescription {
Otev�e seznam se jm�ny preferovan�ch hr���, ka�d� jm�no na jeden ��dek. Z�stupn� znaky (tj. "?" pro jak�koliv jeden znak, "*" pro jakoukoliv sekvenci znak�) jsou povoleny.

V�dy, kdy� se nat�hne partie hr��e uveden�ho v seznamu, �achovnice v hlavn�m okn� se oto��, jestli�e je to nutn� k zobrazen� partie z perspektivy tohoto hr��e.
}
translate C showblunderexists {uk�zat p��tomnost hrub� chyby}
translate C showblundervalue {uk�zat hodnotu hrub� chyby}
translate C showscore {uk�zat sk�re}
translate C coachgame {kou�ovac� partie}
translate C configurecoachgame {konfigurovat kou�ovac� partii}
translate C configuregame {Konfigurace partie}
translate C Phalanxengine {Hern� program phalanx}
translate C Coachengine {Kou�ovac� hern� program}
translate C difficulty {obt�nost}
translate C hard {n�ro�n�}
translate C easy {snadn�}
translate C Playwith {Hr�t s}
translate C white {b�l�}
translate C black {�ern�}
translate C both {oba}
translate C Play {Hr�t}
translate C Noblunder {��dn� hrub� chyba}
translate C blunder {hrub� chyba}
translate C Noinfo {-- ��dn� informace --}
translate C PhalanxOrTogaMissing {Phalanx nebo Toga nenalezen}
translate C moveblunderthreshold {chyba je hrub�, jestli�e ztr�ta je v�t�� ne�}
translate C limitanalysis {omezit �as anal�zy hern�ho programu}
translate C seconds {sekund}
translate C Abort {P�eru�it}
translate C Resume {Pokra�ovat}
# ====== TODO To be translated ======
translate C OutOfOpening {Out of opening}
translate C NotFollowedLine {Nen�sledoval jste variantu}
translate C DoYouWantContinue {Chcete pokra�ovat?}
translate C CoachIsWatching {Kou� sleduje}
translate C Ponder {Neust�l� p�em��len�}
translate C LimitELO {Omezit s�lu ELO}
translate C DubiousMovePlayedTakeBack {Byl zahr�n pochybn� tah, chcete ho vr�tit?}
translate C WeakMovePlayedTakeBack {Byl zahr�n slab� tah, chcete ho vr�tit?}
translate C BadMovePlayedTakeBack {Byl zahr�n �patn� tah, chcete ho vr�tit?}
translate C Iresign {Vzd�v�m}
translate C yourmoveisnotgood {v� tah nen� dobr�}
translate C EndOfVar {Konec varianty}
translate C Openingtrainer {Tren�r zah�jen�}
translate C DisplayCM {Zobrazit mo�n� vhodn� tahy}
translate C DisplayCMValue {Zobrazit hodnut mo�n�ch vhodn�ch tah�}
translate C DisplayOpeningStats {Uk�zat statistiku}
translate C ShowReport {Uk�zat report}
translate C NumberOfGoodMovesPlayed {dobr�ch odehran�ch tah�}
translate C NumberOfDubiousMovesPlayed {pochybn�ch odehran�ch tah�}
translate C NumberOfMovesPlayedNotInRepertoire {odehran�ch tah�, kter� nejsou v reperto�ru}
translate C NumberOfTimesPositionEncountered {v�skyt� pozice}
translate C PlayerBestMove  {Dovolit pouze nejlep�� tahy}
translate C OpponentBestMove {Soupe� hraje nejlep�� tahy}
translate C OnlyFlaggedLines {Pouze ozna�en� varianty}
translate C resetStats {Smazat statistiku}
translate C Repertoiretrainingconfiguration {Konfigurace tr�ninku reperto�ru}
translate C Loadingrepertoire {Natahuji reperto�r}
translate C Movesloaded {Tahy nata�eny}
translate C Repertoirenotfound {Reperto�r nenalezen}
translate C Openfirstrepertoirewithtype {Otev��t prvn� datab�zi reperto�ru s ikonou/typem nastavenou pro spr�vnou stranu}
translate C Movenotinrepertoire {Tah nen� v reperto�ru}
translate C PositionsInRepertoire {Pozice v reperto�ru}
translate C PositionsNotPlayed {Nehran� pozice}
translate C PositionsPlayed {Hran� pozice}
translate C Success {�sp�ch}
translate C DubiousMoves {Pochybn� tahy}
translate C OutOfRepertoire {Mimo reperto�r}
translate C ConfigureTactics {Konfigurovat taktiku}
translate C ResetScores {Smazat sk�re}
translate C LoadingBase {Natahuji datab�zi}
translate C Tactics {Taktika}
translate C ShowSolution {Uk�zat �e�en�}
translate C NextExercise {Dal�� cvi�en�}
translate C PrevExercise {p�edchoz� cvi�en�}
translate C StopTraining {Ukon�it tr�nink}
translate C Next {Dal��}
translate C ResettingScore {Ma�u sk�re}
translate C LoadingGame {Natahuji partii}
translate C MateFound {Mat nalezen}
translate C BestSolutionNotFound {Nejlep�� �e�en� nenalezeno!}
translate C MateNotFound {Mat nenalezen}
translate C ShorterMateExists {Existuje rychlej�� mat}
translate C ScorePlayed {Odehran� sk�re}
# ====== TODO To be translated ======
translate C Expected {expected}
translate C ChooseTrainingBase {Vybrat tr�ninkovou datab�zi}
translate C Thinking {P�em��l�m}
translate C AnalyzeDone {Anal�za hotova}
translate C WinWonGame {Vyhr�t vyhranou partii}
translate C Lines {Varianty}
translate C ConfigureUCIengine {Konfigurovat n�stroj UCI}
translate C SpecificOpening {Vybran� zah�jen�}
translate C StartNewGame {Za��t novou hru}
translate C FixedLevel {Pevn� �rove�}
translate C Opening {Zah�jen�}
translate C RandomLevel {N�hodn� �rove�}
translate C StartFromCurrentPosition {Za��t z aktu�ln� pozice}
translate C FixedDepth {Pevn� hloubka}
translate C Nodes {Uzly} 
translate C Depth {Hloubka}
translate C Time {�as} 
translate C SecondsPerMove {Sekund na tah}
translate C Engine {Hern� program}
translate C TimeMode {Re�im �asu}
translate C TimeBonus {�as + bonus}
translate C TimeMin {min}
translate C TimeSec {s}
translate C AllExercisesDone {V�echna cvi�en� hotova}
translate C MoveOutOfBook {Tah mimo knihovnu zah�jen�}
translate C LastBookMove {Posledn� tah z knihovny zah�jen�}
translate C AnnotateSeveralGames {Anotovat n�kolik parti�\od aktu�ln� do:}
translate C FindOpeningErrors {Naj�t chyby v zah�jen�}
translate C MarkTacticalExercises {Ozna�it taktick� cvi�en�}
translate C UseBook {Pou��vat knihovnu zah�jen�}
translate C MultiPV {N�kolik variant}
translate C Hash {Hashovac� pam�}
translate C OwnBook {Pou��t knihovnu zah�jen� hern�ho programu}
translate C BookFile {Knihovna zah�jen�}
translate C AnnotateVariations {Anotovat varianty}
translate C ShortAnnotations {Kr�tk� anotace}
translate C addAnnotatorTag {P�idat zna�ku anot�tora}
translate C AddScoreToShortAnnotations {P�idat sk�re ke kr�tk�m anotac�m}
translate C Export {Export}
translate C BookPartiallyLoaded {Knihovna zah�jen� ��ste�n� nata�ena}
translate C Calvar {Propo�et variant}
translate C ConfigureCalvar {Konfigurace}
translate C Reti {R�tiho}
translate C English {Anglick�}
translate C d4Nf6Miscellaneous {1.d4 Nf6 r�zn�}
translate C Trompowsky {Opo�ensk�ho hra}
translate C Budapest {Budape��sk� gambit}
translate C OldIndian {Staroindick�}
translate C BenkoGambit {Vol�sk� gambit}
translate C ModernBenoni {Modern� Benoni}
translate C DutchDefence {Holandsk�}
translate C Scandinavian {Skandin�vsk�}
translate C AlekhineDefence {Aljechinova}
translate C Pirc {Pircova}
translate C CaroKann {Caro-Kann}
translate C CaroKannAdvance {Caro-Kann, zav�en� syst�m}
translate C Sicilian {Sicilsk�}
translate C SicilianAlapin {Sicilsk�, Alapinova varianta}
translate C SicilianClosed {Zav�en� sicilsk�}
translate C SicilianRauzer {Sicilsk�, Rauzer�v �tok}
translate C SicilianDragon {Sicilsk�, dra�� varianta}
translate C SicilianScheveningen {Sicilsk�, scheveningsk� varianta}
translate C SicilianNajdorf {Sicilsk�, Najdorfova varianta}
translate C OpenGame {Otev�en� hra}
translate C Vienna {V�de�sk�}
translate C KingsGambit {Kr�lovsk� gambit}
translate C RussianGame {Rusk�}
translate C ItalianTwoKnights {Italsk�/Hra dvou jezdc� v obran�}
translate C Spanish {�pan�lsk�}
translate C SpanishExchange {V�m�nn� �pan�lsk�}
translate C SpanishOpen {Otev�en� �pan�lsk�}
translate C SpanishClosed {Zav�en� �pan�lsk�}
translate C FrenchDefence {Francouzsk�}
translate C FrenchAdvance {Francouzsk�, Steinitz�v syst�m}
translate C FrenchTarrasch {Francouzsk�, Tarrasch�v syst�m}
translate C FrenchWinawer {Francouzsk�, Nimcovi��v syst�m}
translate C FrenchExchange {Francouzsk�, v�m�nn� varianta}
translate C QueensPawn {D�msk�m p�cem}
translate C Slav {Slovansk�}
translate C QGA {P�ijat� d�msk� gambit}
translate C QGD {Odm�tnut� d�msk� gambit}
translate C QGDExchange {V�m�nn� d�msk� gambit}
translate C SemiSlav {Poloslovansk�}
translate C QGDwithBg5 {D�msk� gambit se Sg5}
translate C QGDOrthodox {Ortodoxn� d�msk� gambit}
translate C Grunfeld {Gr�nfeldova indick�}
# ====== TODO To be translated ======
translate C GrunfeldExchange {Gr�nfeld Exchange}
# ====== TODO To be translated ======
translate C GrunfeldRussian {Gr�nfeld Russian}
translate C Catalan {Katal�nsk�}
# ====== TODO To be translated ======
translate C CatalanOpen {Catalan Open}
# ====== TODO To be translated ======
translate C CatalanClosed {Catalan Closed}
translate C QueensIndian {D�msk� indick�}
translate C NimzoIndian {Nimcovi�ova indick�}
translate C NimzoIndianClassical {Nimcovi�ova indick�, klasick� syst�m}
translate C NimzoIndianRubinstein {Nimcovi�ova indick�, Rubinstein�v syst�m}
translate C KingsIndian {Kr�lovsk� indick�}
translate C KingsIndianSamisch {Kr�lovsk� indick�, S�misch�v �tok}
translate C KingsIndianMainLine {Kr�lovsk� indick�, hlavn� varianta}
translate C ConfigureFics {Konfigurovat FICS}
translate C FICSGuest {P�ihl�sit jako host}
translate C FICSServerPort {Port serveru}
translate C FICSServerAddress {IP adresa}
translate C FICSRefresh {Obnovit}
translate C FICSTimesealPort {Port timesealu}
translate C FICSSilence {Ticho}
translate C FICSOffers {Nab�dky}
translate C FICSConsole {Konzola}
translate C FICSGames {Hry}
translate C FICSUnobserve {Ukon�it sledov�n� partie}
translate C FICSProfile {Zobrazit va�i historii a profil}
# ====== TODO To be translated ======
translate C FICSRelayedGames {Relayed games}
translate C FICSFindOpponent {Naj�t soupe�e}
translate C FICSTakeback {Vr�tit tah}
translate C FICSTakeback2 {Vr�tit tah 2}
translate C FICSInitTime {Po��te�n� �as (min)}
translate C FICSIncrement {Inkrement (s)}
translate C FICSRatedGame {Partie zapo��tan� do ratingu}
translate C FICSAutoColour {automatick�}
translate C FICSManualConfirm {potvrdit ru�n�}
translate C FICSFilterFormula {Filtrovat formul�}
# ====== TODO To be translated ======
translate C FICSIssueSeek {Issue seek}
# ====== TODO To be translated ======
translate C FICSChallenge {Challenge}
# ====== TODO To be translated ======
translate C FICSAccept {accept}
# ====== TODO To be translated ======
translate C FICSDecline {decline}
translate C FICSColour {Barva}
# ====== TODO To be translated ======
translate C FICSSend {send}
translate C FICSConnect {P�ipojit}
translate C FICSdefaultuservars {Pou��t v�choz� prom�nn�}
translate C FICSObserveconfirm {Chcete sledovat partii}
# ====== TODO To be translated ======
translate C FICSpremove {Enable premove}
# ====== TODO To be translated ======
translate C FICSObserve {Observe}
# ====== TODO To be translated ======
translate C FICSRatedGames {Rated Games}
# ====== TODO To be translated ======
translate C FICSUnratedGames {Unrated Games}
# ====== TODO To be translated ======
translate C FICSRated {Rated}
# ====== TODO To be translated ======
translate C FICSUnrated {Unrated}
# ====== TODO To be translated ======
translate C FICSRegisteredPlayer {Registered player only}
# ====== TODO To be translated ======
translate C FICSFreePlayer {Free player only}
# ====== TODO To be translated ======
translate C FICSNetError {Network error\nCan't connect to }
translate C GameReview {Prohl�en� partie}
translate C GameReviewTimeExtended {�as prodlou�en}
# ====== TODO To be translated ======
translate C GameReviewMargin {Error margin}
translate C GameReviewAutoContinue {Automaticky pokra�ovat, je-li tah spr�vn�}
# ====== TODO To be translated ======
translate C GameReviewReCalculate {Use extended time}
translate C GameReviewAnalyzingMovePlayedDuringTheGame {Analyzuji tahy sehran� v partii}
translate C GameReviewAnalyzingThePosition {Analyzuji pozici}
translate C GameReviewEnterYourMove {Zadejte v� tah}
translate C GameReviewCheckingYourMove {Kontroluji v� tah}
translate C GameReviewYourMoveWasAnalyzed {V� tah by zanalyzov�n}
translate C GameReviewYouPlayedSameMove {Hr�l jste ten sam� tah jako v partii}
translate C GameReviewScoreOfYourMove {Sk�re va�ho tahu}
translate C GameReviewGameMoveScore {Sk�re tahu v partii}
translate C GameReviewEngineScore {Sk�re hern�ho programu}
translate C GameReviewYouPlayedLikeTheEngine {Hr�l jste jako hern� program}
translate C GameReviewNotEngineMoveButGoodMove {Nen� to tah hern�ho programu, ale je to tak� dobr� tah}
translate C GameReviewMoveNotGood {Tento tah nen� dobr�, sk�re je}
translate C GameReviewMovesPlayedLike {Tahy hran� jako}
translate C GameReviewMovesPlayedEngine {Tahy hran� jako hern�m programem}
translate C CCDlgConfigureWindowTitle {Konfigurovat koresponden�n� �ach}
translate C CCDlgCGeneraloptions {Obecn� nastaven�}
translate C CCDlgDefaultDB {V�choz� datab�ze:}
translate C CCDlgInbox {P��choz� schr�nka (cesta):}
translate C CCDlgOutbox {Odchoz� schr�nka (cesta):}
translate C CCDlgXfcc {Konfigurace Xfcc:}
translate C CCDlgExternalProtocol {Extern� n�stroj pro protokoly (nap�. Xfcc)}
translate C CCDlgFetchTool {Stahovac� n�stroj:}
translate C CCDlgSendTool {Odes�lac� n�stroj:}
translate C CCDlgEmailCommunication {E-mailov� komunikace}
translate C CCDlgMailPrg {E-mailov� program:}
translate C CCDlgBCCAddr {(B)CC adresa:}
translate C CCDlgMailerMode {Re�im:}
translate C CCDlgThunderbirdEg {nap�. Thunderbird, Mozilla Mail, Icedove...}
translate C CCDlgMailUrlEg {nap�. Evolution}
translate C CCDlgClawsEg {nap�. Sylpheed Claws}
translate C CCDlgmailxEg {nap�. mailx, mutt, nail...}
translate C CCDlgAttachementPar {Parametr p��lohy:}
translate C CCDlgInternalXfcc {Pou��t vystav�nou podporu Xfcc}
translate C CCDlgConfirmXfcc {Potvrdit tahy}
translate C CCDlgSubjectPar {P�edm�t:}
translate C CCDlgDeleteBoxes {Pr�zdn� p��choz�/odchoz� schr�nka}
translate C CCDlgDeleteBoxesText {Opravdu chcete vypr�zdnit p��choz� a odchoz� schr�nky pro koresponde�n� �ach? To vy�aduje novou synchronizaci, aby mohl b�t zobrazen posledn� stav va�ich parti�.}
translate C CCDlgConfirmMove {Potvrdit tah}
translate C CCDlgConfirmMoveText {Pokud potvrd�te, n�sleduj�c� tah a koment�� bude zasl�n na server:}
translate C CCDlgDBGameToLong {Nekonzistentn� hlavn� varianta}
translate C CCDlgDBGameToLongError {Hlavn� varianta v datab�zi je del�� ne� partie v p��choz� schr�nce. Jestli�e p��choz� schr�nka obsahuje aktu�ln� partie, tj. �erstv� po synchronizaci, n�kter� tahy byly do hlavn� varianty v datab�zi p�id�ny chybn�.\nV takov�m p��pad� pros�m zkra�te hlavn� variantu do (max.) tahu\n}
translate C CCDlgStartEmail {Za��t novou e-mailovou partii}
translate C CCDlgYourName {Va�e jm�na:}
translate C CCDlgYourMail {Va�e e-mailov� adresa:}
translate C CCDlgOpponentName {Jm�no soupe�e:}
translate C CCDlgOpponentMail {E-mailov� adresa soupe�e:}
translate C CCDlgGameID {Identifik�tor partie (jednozna�n�):}
translate C CCDlgTitNoOutbox {Scid: Odchoz� schr�nka koresponden�n�ho �achu}
translate C CCDlgTitNoInbox {Scid: P��choz� schr�nka koresponden�n�ho �achu}
translate C CCDlgTitNoGames {Scid: ��dn� koresponden�n� partie}
translate C CCErrInboxDir {Adres�� p��choz� schr�nky koresponden�n�ho �achu:}
translate C CCErrOutboxDir {Adres�� odchoz� schr�nky koresponden�n�ho �achu:}
translate C CCErrDirNotUsable {neexistuje nebo nen� p��stupn�!\nPros�m zkontrolujte a opravte nastaven�.}
translate C CCErrNoGames {neobsahuje ��dn� partie!\nNejprve je pros�m st�hn�te.}
translate C CCDlgTitNoCCDB {Scid: ��dn� koresponden�n� datab�ze.}
translate C CCErrNoCCDB {��dn� koresponden�n� datab�ze nen� otev�ena. Pros�m otev�ete n�jakou ne� budete pou��vat funkce koresponden�n�ho �achu.}
translate C CCFetchBtn {St�hnout partie ze serveru a zpracovat p��choz� schr�nku}
translate C CCPrevBtn {J�t na p�edchoz� partii}
translate C CCNextBtn {J�t na n�sleduj�c� partii}
translate C CCSendBtn {Poslat tah}
translate C CCEmptyBtn {Vypr�zdnit p��choz� a odchoz� schr�nku}
translate C CCHelpBtn {N�pov�da k ikon�m a stavov�m indik�tor�m.\nPro obecnou n�pov�du stiskn�te F1!}
translate C CCDlgServerName {Jm�no serveru:}
translate C CCDlgLoginName  {P�ihla�ovac� jm�no:}
translate C CCDlgPassword   {Heslo:}
# ====== TODO To be translated ======
translate C CCDlgShowPassword {Show password}
translate C CCDlgURL        {URL Xfcc:}
translate C CCDlgRatingType {Typ ratingu:}
translate C CCDlgDuplicateGame {Nejednozna�n� identifik�tor partie}
translate C CCDlgDuplicateGameError {Tato partie se v datab�zi vyskytuje v�ce ne� jednou. Pros�m sma�te v�echny duplik�ty a soubor parti� zhutn�te (Soubor/�dr�ba/Zhutnit datab�zi).}
translate C CCDlgSortOption {T��d�n�:}
# ====== TODO To be translated ======
translate C CCDlgListOnlyOwnMove {Only games I have the move}
translate C CCOrderClassicTxt {M�sto, ud�lost, kolo, v�sledek, b�l�, �ern�}
translate C CCOrderMyTimeTxt {M� hodiny}
translate C CCOrderTimePerMoveTxt {�as na ka�d� tah do p��t� �asov� kontroly}
translate C CCOrderStartDate {Po��te�n� datum}
translate C CCOrderOppTimeTxt {Soupe�ovy hodiny}
translate C CCDlgConfigRelay {Konfigurovat sledov�n� ICCF}
translate C CCDlgConfigRelayHelp {B�te na str�nku parti� na http://www.iccf-webchess.com a zobrazte partii, kter� m� b�t sledov�na. Pokud vid�te �achovnici, zkop�rujte URL z prohl�e�e do seznamu n�e. Pouze jedin� URL na ka�d�m ��dku!\nP��klad: http://www.iccf-webchess.com/MakeAMove.aspx?id=266452}
translate C ExtHWConfigConnection {Konfigurovat extern� hardware}
translate C ExtHWPort {Port}
translate C ExtHWEngineCmd {P��kaz hern�ho programu}
translate C ExtHWEngineParam {Parametr hern�ho programu}
translate C ExtHWShowButton {Uk�zat tla��tko}
translate C ExtHWHardware {Hardware}
translate C ExtHWNovag {Novag Citrine}
translate C ExtHWInputEngine {Vstupn� p��stroj}
translate C ExtHWNoBoard {��dn� �achovnice}
# ====== TODO To be translated ======
translate C NovagReferee {Referee}
translate C IEConsole {Konzola vstupn�ho p��stroje}
# ====== TODO To be translated ======
translate C IESending {Moves sent for}
translate C IESynchronise {Synchronizovat}
translate C IERotate  {Oto�it}
translate C IEUnableToStart {Nemohu spustit vstupn� p��stroj:}
# ====== TODO To be translated ======
translate C DoneWithPosition {Done with position}
translate C Board {�achovnice}
translate C showGameInfo {Uk�zat informace o partii}
translate C autoResizeBoard {Automatick� zm�na velikosti �achovnice}
translate C DockTop {P�esunout nahoru}
translate C DockBottom {P�esunout dol�}
translate C DockLeft {P�esunout doleva}
translate C DockRight {P�esunout doprava}
# ====== TODO To be translated ======
translate C Undock {Undock}
translate C ChangeIcon {Zm�nit ikonu...}
# ====== TODO To be translated ======
translate C NewGameListWindow {New Game List Window}
# ====== TODO To be translated ======
translate C LoadatStartup {Load at startup}
# ====== TODO To be translated ======
translate C ShowHideDB {Show/Hide databases}
# ====== TODO To be translated ======
translate C ChangeFilter {Change filter}
# ====== TODO To be translated ======
translate C ChangeLayout {Load/Save/Change sorting criteria and column layout}
# ====== TODO To be translated ======
translate C ShowHideStatistic {Show/Hide statistics}
# ====== TODO To be translated ======
translate C BoardFilter {Show only games that matches the current board position}
# ====== TODO To be translated ======
translate C CopyGameTo {Copy Game to}
# ====== TODO To be translated ======
translate C FindBar {Find Bar}
# ====== TODO To be translated ======
translate C FindCurrentGame {Find current game}
# ====== TODO To be translated ======
translate C DeleteGame {Delete game}
# ====== TODO To be translated ======
translate C UndeleteGame {Undelete game}
# ====== TODO To be translated ======
translate C ResetSort {Reset sort}
# ====== TODO To be translated ======
translate C ConvertNullMove {Convert null moves to comments}
# ====== TODO To be translated ======
translate C SetupBoard {Setup Board}
# ====== TODO To be translated ======
translate C Rotate {Rotate}
# ====== TODO To be translated ======
translate C SwitchColors {Switch colors}
# ====== TODO To be translated ======
translate C FlipBoard {Flip Board}
# ====== TODO To be translated ======
translate C ImportPGN {Import PGN game}
# ====== TODO To be translated ======
translate C ImportingFiles {Importing PGN files in}
# ====== TODO To be translated ======
translate C ImportingFrom {Importing from}
# ====== TODO To be translated ======
translate C ImportingIn {Import games in}
# ====== TODO To be translated ======
translate C UseLastTag {Use last\ngame's tags}
# ====== TODO To be translated ======
translate C Random {Random}
# ====== TODO To be translated ======
translate C BackToMainline {Go back to mainline}
# ====== TODO To be translated ======
translate C LeaveVariant {Leave variant}
# ====== TODO To be translated ======
translate C Autoplay {Autoplay}
# ====== TODO To be translated ======
translate C ShowHideCoords {Show/Hide Coord.}
# ====== TODO To be translated ======
translate C ShowHideMaterial {Show/Hide Material}
# ====== TODO To be translated ======
translate C FullScreen {Full Screen}
# ====== TODO To be translated ======
translate C FilterStatistic {Filter Statistics}
# ====== TODO To be translated ======
translate C MakeCorrections {Make Corrections}
# ====== TODO To be translated ======
translate C Surnames {Surnames}
# ====== TODO To be translated ======
translate C Ambiguous {Ambiguous}
translate C OptionsToolbar "N�strojov� li�ta"
translate C OptionsBoard "�achovnice"
# ====== TODO To be translated ======
translate C OptionsMenuColor "Menu colors"
translate C OptionsBoardSize "Velikost �achovnice"
translate C OptionsBoardPieces "Styl figur"
# ====== TODO To be translated ======
translate C OptionsInternationalization "Internationalization"
# ====== TODO To be translated ======
translate C MenuColorForeground "Textcolor"
# ====== TODO To be translated ======
translate C MenuColorBackground "Background"
# ====== TODO To be translated ======
translate C MenuColorSelect "Select"
# ====== TODO To be translated ======
translate C OptionsTablebaseDir "Select up to 4 table base folders:"
}


############################################################
#
# Czech help pages:


#############
### Contents:

set helpTitle(C,Contents) "Obsah"
set helpText(C,Contents) {<h1>Obsah n�pov�dy Scidu</h1>

<h4>Start a v�eobecn� n�pov�da</h4>
<ul>
<li><a Guide><b>Rychl� pr�vodce</b> pou��v�n�m Scidu</a> <red>(�t�te
 nejprve)</red></li>
<li><a Hints><b>Rady</b> na zefektivn�n� pr�ce se Scidem</a></li>
<li><a MainWindow><b>Hlavn� okno</b> Scidu</a></li>
<li><a Menus><b>Menu</b> Scidu</a> <red>(aktualizov�no!)</red></li>
<li><a Moves>Zad�v�n� <b>tah�</b></a></li>
<li><a Searches><b>Vyhled�v�n�</b> Scidem</a></li>
<li><a Clipbase>Pou�it� datab�ze <b>schr�nka</b></a></li>
<li><a Annotating><b>Anotace parti�</b></a></li>
</ul>

<h4>Ostatn� okna Scidu</h4>
<ul>
<li><a Analysis><b>Analytick�</b> okno</a></li>
<li><a Comment>Okno <b>editoru koment���</b></a></li>
<li><a Crosstable>Okno <b>turnajov� tabulky</b></a></li>
<li><a Switcher>Okno <b>v�b�ru datab�ze</b></a></li>
<li><a Email>Okno <b>emailov�ho</b> mana�era</a></li>
<li><a Finder>Okno <b>vyhled�va�e soubor�</b></a></li>
<li><a GameList>Okno <b>seznamu parti�</b></a></li>
<li><a Import>Okno <b>importu parti�</b></a></li>
<li><a Reports><b>Profily</b></a> <red>(aktualizov�no!)</red></li>
<li><a PGN>Okno <b>PGN</b> (text partie)</a></li>
<li><a PTracker><b>Stopa� figur</b></a></li>
<li><a PList>Okno <b>vyhled�va�e hr���</b></a></li>
<li><a PInfo>Okno <b>informac� o hr��i</b></a></li>
<li><a Repertoire>Okno <b>editoru reperto�ru</b></a></li>
<li><a Tmt>Okno <b>vyhled�va�e turnaj�</b></a></li>
<li><a Tree><b>Stromov�</b> okno</a></li>
<li><a Graphs>Okno <b>graf�</b></a></li>
<li><a TB>Pou�it� <b>tabulek koncovek</b></a>
 <red>(aktualizov�no!)</red></li>
</ul>

<h4>Ostatn� pomocn� programy a informace</h4>
<ul>
<li><a Bookmarks><b>Z�lo�ky</b></a></li>
<li><a Cmdline>Volby z p��kazov�ho ��dku</a></li>
<li><a Compact><b>Zhutn�n�</b> datab�ze</a></li>
<li><a Maintenance>N�stroje <b>�dr�by datab�ze</b></a></li>
<li><a ECO>Klasifikace zah�jen� <b>ECO</b></a></li>
<li><a EPD>Soubory <b>EPD</b></a></li>
<li><a Export><b>Export</b> parti� do textov�ch soubor�</a>
 <red>(aktualizov�no!)</red></li>
<li><a Flags><b>P��znaky</b> u parti�</a></li>
<li><a LaTeX>Pou�it� <b>LaTeXu</b> se Scidem</a></li>
<li><a Options><b>Volby</b> a preference</a> <red>(aktualizov�no!)</red></li>
<li><a Sorting><b>T��d�n�</b> datab�ze</a></li>
<li><a Pgnscid><b>Pgnscid</b>: konverze soubor� PGN</a></li>
<li><a NAGs>Standardn� <b>NAG</b> numerick� hodnocen�</a></li>
<li><a Formats><b>Form�t soubor�</b> Scidu</a></li>
<li><a Author>Kontaktn� informace</a></li>
</ul>

<p><footer>(Aktualizov�no: Scid 3.5, Prosinec 2003)</footer></p>
}


###############
### Topic Index

set helpTitle(C,Index) "Index n�pov�dy Scidu"
set helpText(C,Index) {<h1>Index n�pov�dy Scidu</h1>

<h3>A</h3>
<ul>
<li><a Analysis>Analytick�</a> okno</li>
<li><a Annotating>Anotace parti�</a></li>
<li><a NAGs>Anota�n� symboly</a></li>
<li><a MainWindow Autoplay>Automatick� p�ehr�v�n�</a></li>
<li><a Author>Autor, kontaktov�n�</a></li>
</ul>

<h3>�</h3>
<ul>
<li><a Maintenance Cleaner>�i�t�n�</a></li>
</ul>

<h3>D</h3>
<ul>
<li><a Compact>Datab�ze, zhutn�n�</a></li>
<li><a Formats>Datab�ze, form�ty soubor�</a></li>
<li><a Maintenance>Datab�ze, �dr�ba</a></li>
<li><a Sorting>Datab�ze, t��d�n�</a></li>
<li><a Switcher>Datab�ze</a>, okno v�b�ru</li>
</ul>

<h3>E</h3>
<ul>
<li><a ECO Browser>ECO prohl�e�</a>, okno</li>
<li><a ECO Codes>ECO, syst�m k�d� </a></li>
<li><a ECO>ECO, klasifikace zah�jen� </a></li>
<li><a Menus Edit>Editace, menu</a></li>
<li><a Email>Emailov� mana�er</a>, okno</li>
<li><a EPD>EPD soubory</a></li>
<li><a Export>Export parti� do textov�ch soubor�</a></li>
</ul>

<h3>F</h3>
<ul>
<li><a Searches Filtr>Filtr</a></li>
<li><a Export>Filtr, exportov�n�</a></li>
<li><a Graphs Filtr>Filtr, graf</a></li>
<li><a Options Fonts>Fonty</a></li>
</ul>

<h3>G</h3>
<ul>
<li><a Graphs>Graf, okna</a></li>
</ul>

<h3>H</h3>
<ul>
<li><a Searches Header>Hlavi�ka, vyhled�v�n�</a></li>
<li><a MainWindow>Hlavn� okno</a></li>
<li><a Menus Search>Hledat, menu</a></li>
<li><a PList>Hr��</a>, okno vyhled�va�e</li>
<li><a PInfo>Hr��</a>, okno informac�</li>
<li><a Reports Player>Hr��</a>, okno profilu</li>
</ul>

<h3>I</h3>
<ul>
<li><a Import>Import</a>, okno</li>
</ul>

<h3>J</h3>
<ul>
<li><a Maintenance Editing>Jm�na, editace</a></li>
<li><a Maintenance Spellcheck>Jm�na, kontrola pravopisu</a></li>
</ul>

<h3>K</h3>
<ul>
<li><a Comment>Koment���</a>, okno editoru</li>
<li><a Compact>Zhutn�n� datab�ze</a></li>
<li><a Author>Kontaktn� informace</a></li>
</ul>

<h3>L</h3>
<ul>
<li><a LaTeX>LaTeX</a>, v�stupn� form�t</li>
</ul>

<h3>M</h3>
<ul>
<li><a Maintenance Twins>Maz�n� zdvojen�ch parti�</a></li>
<li><a Analysis List>Motory</a>, seznam</li>
<li><a Searches Material>Materi�l/vzor, vyhled�v�n�</a></li>
<li><a Menus>Menu</a></li>
</ul>

<h3>N</h3>
<ul>
<li><a Menus Help>N�pov�da, menu</a></li>
<li><a Menus Tools>N�stroje, menu</a></li>
<li><a Tree Best>Nejlep�� partie</a>, okno</li>
<li><a NAGs>NAG anota�n� hodnoty</a></li>
<li><a Annotating Null>Nulov� tahy</a></li>
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
<li><a Flags>Partie, p��znaky</a></li>
<li><a Searches Board>Pozice, vyhled�v�n�</a></li>
<li><a Maintenance Spellcheck>Pravopis jmen, kontrola</a></li>
<li><a GameList Browsing>Prohl�en� parti�</a></li>
<li><a Cmdline>P��kazov� ��dek, volby</a></li>
<li><a GameList Browsing>P�ipojov�n� parti�</a></li>
<li><a Flags>P��znaky</a></li>
<li><a PGN>PGN</a>, okno</li>
<li><a Pgnscid>Pgnscid</a></li>
</ul>

<h3>R</h3>
<ul>
<li><a Hints>Rady</a></li>
<li><a Guide>Rychl� pr�vodce pou��v�n�m Scidu</a></li>
<li><a Graphs Rating>Rating, graf</a></li>
<li><a Repertoire>Reperto�r, editor</a></li>
</ul>

<h3>S</h3>
<ul>
<li><a Clipbase>Schr�nka</a></li>
<li><a Formats>Soubor, form�ty</a></li>
<li><a Menus File>Soubor, menu</a></li>
<li><a Finder>Soubor, vyhled�va�</a></li>
<li><a PTracker>Stopa� figur</a>, okno</li>
<li><a Tree>Stromov� okno</a></li>
</ul>

<h3>T</h3>
<ul>
<li><a TB>Tabulky koncovek</a></li>
<li><a Moves>Tahy, zad�v�n�</a></li>
<li><a Sorting>T��d�n� datab�ze</a></li>
<li><a Crosstable>Turnajov� tabulka</a>, okno</li>
<li><a Tmt>Turnaj, vyhled�va�</a></li>
</ul>

<h3>U</h3>
<ul>
<li><a Maintenance>�dr�ba, n�stroje</a></li>
</ul>

<h3>V</h3>
<ul>
<li><a Options>Volby</a></li>
<li><a Switcher>V�b�r datab�ze</a>, okno</li>
<li><a Searches Filter>Vyhled�vac� filtr</a></li>
<li><a Searches>Vyhled�v�n�</a></li>
<li><a Annotating Vars>Varianty</a></li>
</ul>

<h3>Z</h3>
<ul>
<li><a Moves>Zad�v�n� tah�</a></li>
<li><a ECO>Zah�jen�, klasifikace (ECO)</a></li>
<li><a Reports Opening>Zah�jen�</a>, okno profilu</a>
<li><a Repertoire>Zah�jen�, reperto�ry</a></li>
<li><a Bookmarks>Z�lo�ky</a></li>
<li><a Maintenance Twins>Zdvojen� (duplicitn�) partie</a></li>
<li><a Moves Trial>Zku�ebn� m�d</a></li>
</ul>

<p><footer>(Aktualizov�no: Scid 3.5, �nor 2003)</footer></p>
}


################
### Quick guide:

set helpTitle(C,Guide) "Rychl� pr�vodce pou��v�n�m Scidu"
set helpText(C,Guide) {<h1>Rychl� pr�vodce pou��v�n�m Scidu</h1>
<p>
Scid je �achov� datab�zov� aplikace; m��ete s n� prohl�et datab�ze �achov�ch
parti�, partie editovat a pou�it�m r�zn�ch krit�ri� partie <a Searches>vyhled�vat</a>.
</p>
<p>
Scid pou��v� sv�j vlastn� <a Formats>form�t dat</a>, sest�vaj�c� ze t�� soubor�,
kter� je velmi kompaktn� a rychl�, ale m��e b�t obousm�rn� konvertov�n mezi
standardn�m PGN (Portable Game Notation) form�tem.
<a PGN>Okno PGN</a> Scidu zobrazuje z�pis aktu�ln� partie v PGN form�tu.
</p>
<p>
Scid m��ete pou��t k p�id�n� partie do datab�ze, tahy lze zad�vat kl�vesnic� i
my��. Pro dal�� informace se pod�vejte na str�nky n�pov�dy o
<a Moves>zad�v�n� tah�</a>.
</p>
<p>
Scid m��ete tak� pou��t jako prohl�e� <a PGN>PGN</a> soubor�, bu� vlo�en�m PGN
notace do okna <a Import>Importu</a> Scidu nebo otev�en�m PGN souboru ve Scidu.
Av�ak PGN soubory nemohou b�t ve Scidu editov�ny (jsou otev�eny jen ke �ten�),
jsou n�ro�n� na pam� a pomaleji se otev�raj�. Z t�chto d�vod� se doporu�uje
velk� PGN soubory nejprve zkonvertovat do form�tu Scidu pou�it�m pomocn�ho
programu <a Pgnscid>pgnscid</a>.
</p>
<p>
<a MainWindow>Hlavn� okno</a> Scidu (s grafickou �achovnic�) zobrazuje detaily
aktu�ln� partie a datab�ze. Kdykoliv m��ete m�t otev�eny a� �ty�i datab�ze
sou�asn� (s <a Clipbase>datab�z� schr�nka</a> p�t) a ka�d� z nich bude m�t svou
aktu�ln� partii.
(Partie ��slo 0 indikuje zad�v�n� partie, kter� nen� sou��st�
aktu�ln� datab�ze).
Mezi otev�en�mi datab�zemi lze p�ep�nat v
<a Menus File>menu Soubor</a>.
</p>
<p>
Pro v�ce informac� si pros�m p�e�t�te ostatn� str�nky n�pov�dy v 
<a Index>indexu n�pov�dy</a>.
</p>
<p>
Jestli�e chcete kontaktovat autora Scidu, jd�te na str�nku s
<a Author>kontaktn�mi informacemi</a>.
</p>

<p><footer>(Aktualizov�no: Scid 3.1, Prosinec 2001)</footer></p>
}


###############
### Hints page:

set helpTitle(C,Hints) "Rady k pou��v�n�"
set helpText(C,Hints) {<h1>Rady k pou��v�n�</h1>
<p>
Tato str�nka obsahuje ve form� ot�zek a odpov�d� u�ite�n� rady, kter� v�m
pomohou Scid l�pe pou��vat. Jestli�e s programem Scid teprve za��n�te, p�e�t�te
si pros�m nejd��ve <a Guide>rychl�ho pr�vodce</a>.
V�t�ina informac� na t�to str�nce je probr�na detailn� na dal��ch str�nk�ch
n�pov�dy, viz <a Index>index</a>.
Jestli�e chcete p�isp�t na tuto st�nku n�jakou svoj� u�ite�nou radou, po�lete ji
<a  Author>autorovi Scidu</a>. </p>

<h4>Mohu spustit Scid p��mo se zvolenou datab�z�?</h4>
<p>
Ano, na p��kazov� ��dek sta�� p�idat datab�ze, PGN soubory nebo
<a EPD>EPD soubory</a>. Nap�.
<ul>
<li> <b>scid  mybase  games.pgn.gz</b> </li>
</ul>
otev�e datab�zi ve form�tu Scidu <b>mybase</b> a rovn� PGN soubor komprimovan�
Gzipem <b>games.pgn.gz</b>.
</p>

<h4>Existuje jednodu��� mo�nost jak zm�nit velikost �achovnice ne� pou�it�m menu
Volby?</h4>
<p>
Ano, pou�ijte kl�vesovou zkratku <b>Control+Shift+�ipkaVlevo</b> pro zmen�en� �achovnice
a <b>Control+Shift+�ipkaVpravo</b> pro zv�t�en�.
</p>

<h4>P�i tr�ninku si p�ehr�v�m partii, a t�m p�dem nechci, aby Scid zobrazoval
n�sleduj�c� tah v informa�n� z�n� partie pod �achovnic�. Je mo�n� ho
skr�t?</h4>
<p>
N�sleduj�c� tah lze skr�t tak, �e v informa�n� z�n� partie stiskn�te
<b>prav�</b> tla��tko my�i a z menu, kter� se objev�, vyberete
<b>Skr�t n�sleduj�c� tah</b>.
</p>

<h4>Jak mohu vid�t ECO k�d zah�jen� pro aktu�ln� pozici?</h4>
<p>
Jestli�e byl nahr�n klasifika�n� soubor ECO (<b>scid.eco</b>), ECO k�d je
zobrazen na posledn�m ��dku informa�n� z�ny, pod �achovnic� v
<a MainWindow>hlavn�m okn�</a>. <br>
Str�nka n�pov�dy <a ECO>ECO k�du</a> vysv�tluje, jak nahr�t
klasifika�n� soubor ECO a ulo�it nastaven� tak, aby se nahr�l  p�i ka�d�m
spu�t�n� Scidu. </p>

<h4>Zad�v�m partii a jsem okolo 30. tahu, ale najednou zjist�m, �e 10. tah jsem
zadal �patn�. Jak ho mohu opravit, abych neztratil n�sleduj�c� tahy?</h4>
<p>
M��ete pou��t okno <a Import>importu</a>; pro dal�� informace se pod�vejte na
str�nku n�pov�dy o <a Moves Mistakes>zad�v�n� tah�</a>.
</p>

<h4>Jak zkop�ruji partie z jedn� datab�ze do druh�?</h4>
<p>
Pou�ijte <a Switcher>okno v�b�ru datab�ze</a>; p�eta�en�m ze zdrojov� datab�ze
do c�lov� datab�ze zkop�rujete v�echny partie z <a Searches Filter>filtru</a>
zdrojov� datab�ze.
</p>

<h4>Kdykoliv kdy� zad�v�m tah, kde u� n�jak� existuje, objev� se dialogov� okno
"Nahradit tah?". Jak tomu mohu zabr�nit?</h4>
<p>
Vypn�te volbu <b>Pt�t se p�ed nahrazen�m tah�</b> v menu
<menu>Volby: Tahy</menu>. Nebo si zvykn�te na vr�cen� tahu zp�tky pou��vat
prav� tla��tko my�i, tak vlastn� dojde k odstran�n� tahu z partie, je-li to jej�
posledn� tah.
</p>

<h4>Jak zm�n�m v Okn� seznamu parti� ���ku sloupc�?</h4>
<p>
Klikn�te lev�m nebo prav�m tla��tkem my�i na ka�d� titulek sloupce.
</p>

<h4>Jak mohu pou��t okno stromu s v�b�rem parti�, ne s celou datab�z�?</h4>
<p>
Pou�ijte <a Clipbase>datab�zi schr�nka</a>. Nastavte filtr datab�ze tak, aby
obsahoval partie, kter� chcete pou��t pro strom, a zkop�rujte je pomoc� okna
<a Switcher>v�b�ru datab�ze</a> do datab�ze schr�nka.  Pak v datab�zi schr�nka
otev�ete okno stromu.
</p>

<h4>Pro velk� datab�ze je strom pomal�. Jak ho urychl�m?</h4>
<p>
Pro pro dal�� pou�it� �daj� stromu �asto ukl�dejte cache stromu. Dal��
detaily najdete na str�nk�ch n�pov�dy <a Tree>stromu</a>, v sekci o cache.
</p>

<h4>Jak mohu p��mo editovat PGN z�pis partie?</h4>
<p>
K editaci aktu�ln� partie nem��ete pou��t okno <a PGN>PGN</a>, ale m��ete
editovat jej� PGN z�pis pou�it�m okna <a Import>importu partie</a>.  Otev�ete ho
(kl�vesov� zkratka <b>Control+Shift+I</b>) a zvolte
<b>Vlo�it aktu�ln� partii</b>, pak m��ete partii editovat a nakonec zvolte
<b>Import</b>.
</p>

<h4>Moje datab�ze obsahuje r�zn� tvary jmen n�kter�ch hr���. Jak je mohu v�echny
opravit?</h4>
<p>
Pou�it�m p��kaz� v menu <menu>Soubor: �dr�ba</menu> m��ete editovat
individu�ln� jm�na hr��� nebo opravit v�echna jm�na v datab�zi. �t�te str�nku
<a Maintenance Editing>�dr�ba</a>.
</p>

<h4>M�m otev�eny dv� datab�ze: prvn� s m�mi vlastn�mi partiemi a druhou velkou s
velmistrovsk�mi partiemi. Jak porovn�m jednu z m�ch parti� s t�mi ve velk�
datab�zi?</h4>
<p>
Ve velk� datab�zi si otev�ete <a Tree>okno stromu</a> a zvolte
<term>Zamknout</term>, aby jste zamknuli strom k t�to datab�zi. Potom se
p�epn�te do druh� datab�ze a strom bude d�le pokra�ovat v zobrazov�n� �daj� pro
velkou datab�zi.
</p>

<p><footer>(Aktualizov�no: Scid 2.6, Srpen 2001)</footer></p>
}


################
### Main window:

set helpTitle(C,MainWindow) "Hlavn� okno Scidu"
set helpText(C,MainWindow) {<h1>Hlavn� okno Scidu</h1>
<p>
Hlavn� okno Scidu zobrazuje �achovnici s aktu�ln� pozic� aktivn� partie a
informace o t�to partii a o otev�en� datab�zi. Jednotliv� str�nky n�pov�dy
popisuj� <a Menus>menu</a> hlavn�ho okna a <a Moves>zp�soby zad�v�n� tah�</a>.
</p>

<h3>Tla��tka navigace v partii</h3>
<p>
Naviga�n� tla��tka nad �achovnic� maj� tyto v�znamy, zleva doprava:
<ul>
<li> <button tb_start> Jdi na za��tek partie. </li>
<li> <button tb_prev> Jdi o jeden tah nazp�t. </li>
<li> <button tb_next> Jdi o jeden tah dop�edu. </li>
<li> <button tb_end> Jdi na konec partie. </li>
<li> <button tb_invar> Sko� do varianty. </li>
<li> <button tb_outvar> Opus� aktu�ln� variantu. </li>
<li> <button tb_addvar> P�idej variantu k tomuto tahu v partii. </li>
<li> <button tb_play> Spus�/Ukon�i automatick� p�ehr�v�n� tah� (viz
 n�e). </li>
<li> <button tb_trial> Spus�/Ukon�i <a Moves Trial>zku�ebn� m�d</a>. </li>
<li> <button tb_flip> Oto� �achovnici. </li>
<li> <button tb_coords>  Zapni/Vypni zobrazov�n� sou�adnic �achovnice. </li>
</ul>

<h4><name Autoplay>Automatick� p�ehr�v�n�</name></h4>
<p>
V re�imu automatick�ho p�ehr�v�n� Scid automaticky p�ehr�v� sm�rem dop�edu
aktu�ln� partii, dokud nedojde na jej� konec. �asov� interval mezi tahy lze
nastavit z menu <menu>Volby: Tahy</menu>, p�i ulo�en� voleb je ulo�en do
va�eho souboru voleb.
</p>
<p>
Re�im automatick�ho p�ehr�v�n� spou�t� nebo ukon�uje kl�vesov� zkratka
<b>Control+Z</b>, ukon�it ho lze rovn� kl�vesou <b>Escape</b>.
</p>
<p>
Jestli�e spust�te re�im automatick�ho p�ehr�v�n� p�i otev�en�m
<a Analysis>analytick�m okn�</a>, partie se bude
<term>komentovat</term>: p�ed proveden�m ka�d�ho tahu bude jako nov� varianta
p�id�na anal�za programu a jeho hodnocen�. Podrobnosti se do�tete na str�nce
n�pov�dy o <a Analysis>analytick�m okn�</a>.
</p>

<h3>Informa�n� z�na partie</h3>
<p>
Oblast pod �achovnic� zobrazuj�c� informace o partii se naz�v�
<term>informa�n� z�na partie</term>.
Jej� prvn� t�i ��dky zobrazuj� jm�na hr���,
v�sledek, datum a m�sto.
�tvrt� ��dek indikuje sou�asnou pozici partie a
n�sleduj�c� tah.
</p>
<p>
P�t� ��dek zobrazuje <a ECO>ECO</a> (Encyclopedia of Chess Openings, tj.
Encyklopedie �achov�ch zah�jen�) k�d aktu�ln� pozice, jestli�e se tato pozice
nal�z� v pou��van�m ECO souboru.
</p>
<p>
Prav�m tla��tkem m��ete v informa�n� z�n� partie aktivovat menu, kde lze nap�.
skr�t n�sleduj�c� tah (u�ite�n� p�i tr�ninku, kdy� h�d�te jednotliv� tahy
partie) a smazat nebo obnovit aktu�ln� partii. Toto menu lze aktivovat i bez
my�i stisknut�m funk�n� kl�vesy <b>[F9]</b>.
</p>

<h4>Tabulky koncovek (tablebases)</h4>
<p>
Kdykoliv aktu�ln� pozice dos�hne materi�ln� konfiguraci nalezenou v datab�zov�m
souboru tabulek koncovek, informa�n� z�na partie rovn� zobrazuje jej�
hodnocen� podle t�to tabulky. Detaily hledejte na str�nce n�pov�dy o
<a TB>tabulk�ch koncovek</a>.
</p>

<h3>Stavov� li�ta</h3>
<p>
Stavov� li�ta zobrazuje informace o aktu�ln� datab�zi. Prvn� pole indikuje stav
partie: <b>XX</b> znamen�, �e partie byla zm�n�na, ale je�t� neulo�ena, zat�mco
<b>--</b> znamen�, �e zm�n�na nebyla, a <b>%%</b> indikuje, �e datab�ze je jen
ke �ten� (ned� se zm�nit).
</p>
<p>
Jestli�e chcete, aby datab�ze byla otev�ena jen ke �ten�, nastavte
adekv�tn� p��stupov� pr�va k jej�m soubor�m, minim�ln� aspo� k jej�mu indexov�mu
souboru, nap�. na p��kazov�m ��dku zadejte
<b>chmod a-w myfile.si3</b>
a tato datab�ze pak bude Scidem otev�ena jen ke �ten�.
</p>
<p>
Stavov� li�ta rovn� zobrazuje, kolik parti� je aktu�ln� ve
<a Searches Filter>filtru</a>.
</p>

<p><footer>(Aktualizov�no: Scid 3.1, Prosinec 2001)</footer></p>
}


######################
### Menus help screen:

set helpTitle(C,Menus) "Menu"
set helpText(C,Menus) {<h1>Menu Scidu</h1>

<h3><name File>Soubor</name></h3>
<ul>
<li><menu>Nov�</menu>: Vytvo�� novou datab�zi.</li>
<li><menu>Otev��t</menu>: Otev�e existuj�c� datab�zi.</li>
<li><menu>Zav��t</menu>: Zav�e aktu�ln� datab�zi.</li>
<li><menu>Vyhled�va�</menu>: Otev�e <a Finder>Vyhled�va� soubor�</a>.</li>
<li><menu>Z�lo�ky</menu>: <a Bookmarks>Z�lo�ky</a> a jejich funkce.</li>
<li><menu>�dr�ba</menu>: Funkce <a Maintenance>�dr�by</a> datab�ze.</li>
<ul>
  <li><menu>Okno �dr�by</menu>: Otev�r�/Zav�r� okno �dr�by datab�ze.</li>
  <li><menu>Vymaz�n� zdvojen�ch parti�</menu>: Nalezne v datab�zi
      <a Maintenance Twins>zdvojen�</a> partie.</li>
  <li><menu>ECO klasifikace partie</menu>: P�epo��t�
      <a ECO>ECO k�dy</a> v�ech parti� v datab�zi.</li>
  <li><menu>Editor jmen</menu>: Nahrad� v�echny v�skyty jm�na hr��e, m�sta
      turnaje a kola.</li>
</ul>
<li><menu>Pouze pro �ten�</menu>: Nastav� aktu�ln� datab�zi jen ke �ten�.</li>
<li><menu>Base 1/2/3/4/5</menu>: T�mito p��kazy lze p�ep�nat a� mezi �ty�mi
    aktivn�mi datab�zemi a <a Clipbase>datab�z� schr�nka</a>.</li>
<li><menu>Ukon�it</menu>: Ukon�� program Scid.</li>
</ul>

<h3><name Edit>Editace</name></h3>
<ul>
<li><menu>P�idat variantu</menu>: P�id� novou pr�zdnou variantu k n�sleduj�c�mu
    tahu nebo k posledn�mu, jestli�e za n�m u� ��dn� jin� tah nen�sleduje.</li>
<li><menu>Vymazat variantu</menu>: Zobraz� submenu variant k aktu�ln�mu (tj.
    n�sleduj�c�mu) tahu, kter� lze vymazat.</li>
<li><menu>Za�adit jako prvn� variantu</menu>: Za�ad� vybranou variantu k
    aktu�ln�mu tahu na prvn� m�sto.</li>
<li><menu>Pov��it st�vaj�c� variantu na hlavn�</menu>: Pov��� vybranou variantu
    na hlavn� v�m�nou se sou�asnou hlavn� variantou.</li>
<li><menu>Zkusit variantu</menu>: Spust� <a Moves Trial>zku�ebn� m�d</a> pro
    testov�n� varianty bez z�sahu do aktu�ln� partie.</li>
<li><menu>Odstranit</menu>: Odstran� z aktu�ln� partie v�echny koment��e nebo
    varianty.</li>
<br>
<li><menu>Vypr�zdnit schr�nku</menu>: Vypr�zdn�
    <a Clipbase>datab�zi schr�nka</a>, tak�e neobsahuje ��dn� partie.</li>
<li><menu>Zkop�rovat tuto partii do schr�nky</menu>: Zkop�ruje aktu�ln� partii
    do <a Clipbase>datab�ze schr�nka</a>.</li>
<li><menu>Vlo�it posledn� partii ze schr�nky</menu>: Vlo�� aktivn� partii z
    <a Clipbase>datab�ze schr�nka</a> do aktu�ln� datab�ze.</li>
<br>
<li><menu>Nastavit v�choz� pozici</menu>: Nastav� v�choz� pozici aktu�ln�
    partie.</li>
<li><menu>Vlo�it po��te�n� pozici</menu>: Vlo�� po��te�n� pozici z
    aktu�ln�ho vybran�ho textu (v clipboardu).</li>
</ul>

<h3><name Game>Partie</name></h3>
<ul>
<li><menu>Nov� partie</menu>: Nastav� aktu�ln� partii do po��te�n� pozice a
    zru�� v�echny jej� neulo�en� zm�ny.</li>
<li><menu>Nat�hnout prvn�/p�edchoz�/n�sleduj�c�/posledn� partii</menu>: Nat�hne
    prvn�/p�edchoz�/n�sleduj�c�/posledn� partii do
    <a Searches Filter>filtru</a>.</li>
<li><menu>Znovunat�hnout aktu�ln� partii</menu>: Znovunat�hne aktu�ln� partii a
    zru�� v�echny jej� neulo�en� zm�ny.</li>
<li><menu>Nat�hnout partii ��slo</menu>: Nat�hne z aktu�ln� datab�ze partii
    dan�ho ��sla.</li>
<br>
<li><menu>Ulo�it: p�eps�n� partie</menu>: Ulo�� aktu�ln� partii p�eps�n�m jej�
    origin�ln� verze v datab�zi</li>
<li><menu>Ulo�it: p�id�n� nov� partie</menu>: Ulo�� aktu�ln� partii jako novou
    partii p�id�n�m na konec datab�ze.</li>
<br>
<li><menu>Identifikace zah�jen�</menu>: Najde nejhlub�� pozici z aktu�ln�
    partie, kter� se je�t� nach�z� v ECO souboru.</li>
<li><menu>P�ej�t na tah ��slo</menu>: P�ejde na specifikovan� tah aktu�ln�
    partie.</li>
<li><menu>Hledat novinku</menu>: Najde prvn� tah aktu�ln� partie, kter� se je�t�
    p�edt�m nehr�l. </li>
</ul>

<h3><name Search>Hledat</name></h3>
<ul>
<li><menu>Vy�istit filter</menu>: Vy�ist� <a Searches Filter>filter</a>,
    tak�e obsahuje v�echny partie.</li>
<li><menu>Negace filtru</menu>: Invertuje filtr tak, �e obsahuje jen partie,
    kter� neobsahoval.</li>
<br>
<li><menu>Aktu�ln� pozice</menu>: Vyhled�v�
    <a Searches Board>aktu�ln� pozici</a> na �achovnici.</li>
<li><menu>Hlavi�ka: Vyhled�v� podle informac� v
    <a Searches Header>hlavi�ce</a>, nap�. podle jmen hr���.</li>
<li><menu>Materi�l/Vzor</menu>: Vyhled�v� podle
    <a Searches Material>materi�lu</a> nebo vzor�.</li>
<br>
<li><menu>Hledat pomoc� souboru voleb</menu>: Vyhled�v� pou�it�m
    <a Searches Settings>nastaven�</a> ze souboru vyhled�vac�ch voleb.</li>
</ul>

<h3><name Windows>Okna</name></h3>
<ul>
<li><menu>Editor koment���</menu>: Otev�r�/Zav�r� okno
    <a Comment>editoru koment���</a>.</li>
<li><menu>Seznam parti�</menu>: Otev�r�/Zav�r�
    <a GameList>okno seznamu parti�</a>.</li>
<li><menu>Okno PGN</menu>: Otev�r�/Zav�r�
    <a PGN>okno PGN</a>.</li>
<li><menu>Vyhled�va� turnaj�</menu>: Otev�r�/Zav�r� okno
    <a Tmt>vyhled�va�e turnaj�</a>.</li>
<br>
<li><menu>V�b�r datab�ze</menu>: Otev�r�/Zav�r� okno
    <a Switcher>v�b�ru datab�ze</a>, kde se lze p�epnout do jin� datab�ze nebo
    jednodu�e kop�rovat partie mezi datab�zemi.</li>
<li><menu>Okno �dr�by</menu>: Otev�r�/Zav�r� okno
    <a Maintenance>�dr�by</a> datab�ze.</li>
<br>
<li><menu>ECO prohl�e�</menu>: Otev�r�/Zav�r� okno
    <a ECO browser>ECO prohl�e�e</a>.</li>
<li><menu>Editor reperto�ru</menu>: Otev�r�/Zav�r�
    <a Repertoire>editor reperto�ru</a>.</li>
<li><menu>Statistick� okno</menu>: Otev�r�/Zav�r�
    <term>Statistick� okno filtru</term>, kter� zobrazuje p�ehled v�her/proher
    parti� ve <a Searches Filter>filtru</a>.</li>
<li><menu>Stromov� okno</menu>: Otev�r�/Zav�r�
    <a Tree>stromov� okno</a>.</li>
<li><menu>Okno tabulky koncovek</menu>: Otev�r�/Zav�r� okno, kter� zobrazuje
    informace z <a TB>tabulek koncovek</a>.</li>
</ul>

<h3><name Tools>N�stroje</name></h3>
<ul>
<li><menu>Program pro anal�zu</menu>: Spou�t�/Zastavuje �achov� program pro
    anal�zu pozice, kter� zobrazuje v
    <a Analysis>analytick�m okn�</a> hodnocen� sou�asn� pozice.</li>
<li><menu>Program pro anal�zu #2</menu>: Spou�t�/Zastavuje druh� �achov� program
    pro anal�zu pozice.</li>
<li><menu>Turnajov� tabulka</menu>: Zkonstruuje a zobraz�
    <a Crosstable>turnajovou tabulku</a> pro aktu�ln� partii.</li>
<li><menu>Email mana�er</menu>: Otev�r�/Zav�r� okno
    <a Email>emailov�ho mana�era</a> pro spr�vu koresponden�n�ch parti� hran�ch
    emailem.</li>
<br>
<li><menu>Profil zah�jen�</menu>: Generuje
    <a Reports Opening>profil zah�jen�</a> pro aktu�ln� pozic�.</li>
<li><menu>Stopa� figur</menu>: Otev�r� okno
    <a PTracker>stopa�e figur</a>.</li>
<br>
<li><menu>Informace o hr���ch</menu>: Zobraz�
    <a PInfo>informace o hr���ch</a> aktu�ln� partie.</li>
<li><menu>Graf ratingu </menu>: Zobraz�
    <a Graphs Rating>graf ratingu</a>.</li>
<li><menu>Graf sk�re</menu>: Zobraz�
    <a Graphs Score>graf sk�re</a>.</li>
<br>
<li><menu>Export aktu�ln� partie</menu>: Zap�e aktu�ln� partii do textov�ho
    souboru ve form�tu PGN, HTML nebo LaTeX. �t�te str�nku n�pov�dy o
    <a Export>exportu</a>.</li>
<li><menu>Export filtrovan�ch parti�</menu>: Zap�e v�echny partie ve
    vyhled�vac�m <a Searches Filter>filtru</a> do textov�ho souboru ve form�tu
    PGN, HTML nebo LaTeX. �t�te str�nku n�pov�dy o <a Export>exportu</a>.</li>
<br>
<li><menu>Import jedn� PGN partie</menu>: Otev�e <a Import>okno Importu</a> pro
    zad�v�n� partie nebo jej� vlo�en� v <a PGN>PGN form�tu</a>.</li>
<li><menu>Import souboru PGN parti�</menu>: Importuje cel� soubor parti�
    v PGN form�tu do aktu�ln� datab�ze.</li>
</ul>

<h3><name Options>Volby</name></h3>
<p>
Toto menu poskytuje p��kazy pro nastaven� tak�ka v�ech konfigurovateln�ch voleb
Scidu. P��kaz <menu>Ulo�it volby</menu> ulo�� aktu�ln� nastaven� voleb do
souboru "<b>~/.scid/scidrc</b>" (nebo <b>scid.opt</b> v adres��i Scidu pro
u�ivatele Windows); tento soubor se na��t� p�i ka�d�m startu Scidu.
</p>

<h3><name Help>N�pov�da</name></h3>
<p>
Toto menu obsahuje funkce n�pov�dy a p��stup k oknu tip� dne nebo k startovac�mu
oknu, kter� poskytuje informace o souborech, kter� Scid na�etl p�i startu.
</p>

<p><footer>(Aktualizov�no: Scid 3.5, �nor 2003)</footer></p>
}


########################
### Entering moves help:

set helpTitle(C,Moves) "Zad�v�n� tah�"
set helpText(C,Moves) {<h1>Zad�v�n� tah�</h1>
<p>
Ve Scidu m��ete zad�vat tahy partie pou�it�m my�i nebo kl�vesnice. Kdy� pohnete
my�� na n�jak� pole �achovnice, toto pole spolu s dal��m zm�n� barvu, jestli�e
existuje z tohoto nebo na toto pole mo�n� tah. Jedn� se o
<term>navrhovan� tah</term>. Chcete-li zadat tento tah, jednodu�e klikn�te
<term>lev�m</term> tla��tkem my�i. Jestli�e v�s navrhov�n� tah� ru��, m��ete ho
vypnout v menu Volby.
</p>
<p>
Jestli�e chcete zadat jin� tah ne� navrhovan�, m��ete pou��t <term>lev�</term>
tla��tko my�i; stiskn�te tla��tko na jednom poli a uvoln�te na druh�m.
</p>
<p>
Jestli�e up�ednost�ujete zad�vat tahy dv�ma kliknut�m my�i p�ed jej�m ta�en�m
se stisknut�m tla��tkem, m��ete pou��t <term>prost�edn�</term> tla��tko;
klikn�te na jedno pole a pak na druh�.
</p>

<h4>Vr�cen� tahu zp�t</h4>
<p>
Chcete-li vr�tit posledn� tah zp�t, klikn�te prav�m tla��tkem my�i. Vr�t�te se
tak jeden tah nazp�t a tah se sma�e, jestli�e byl posledn� v partii nebo ve
variant�.
</p>

<h4>N�hrada p�vodn�ch tah�</h4>
<p>
Kdy� zad�te tah v takov�m m�st� partie, kde u� n�jak� tah existuje, Scid zobraz�
dialogov� okno, zda opravdu chcete nahradit p�vodn� tah (p�vodn� tah a v�echny
tahy za n�m budou ztraceny) nebo chcete p�idat nov� tah jako variantu. N�kter�m
lidem m��e toto dialogov� okno vadit, proto�e v�dy cht�j� nahradit p�vodn� tahy,
z tohoto d�vodu to lze v menu <menu>Volby: Tahy</menu> volbou
"<i>Pt�t se p�ed nahrazen�m tah�</i>" vypnout.
</p>

<h4><name Trial>Zku�ebn� m�d</name></h4>
<p>
Jestli�e studujete partii a dojdete do pozice, kde chcete zkusit alternativn�
variantu beze zm�ny partie, vyberte z menu <menu>Editace</menu> p��kaz
<b>Zkusit variantu</b> pro spu�t�n� zku�ebn�ho m�du. V tomto m�du m��ete zad�vat
tahy a jinak do�asn� m�nit partii, po ukon�en� zku�ebn�ho m�du se pak vr�t�te do
pozice, kde jste tento m�d spustili.</p>

<h3><name Mistakes>Oprava chyb</name></h3>
<p>
Kdy� zad�v�te partii a najednou uvid�te chybn� tah n�kolik tah� d��v, je mo�n�
chybu opravit bez ztr�ty n�sleduj�c�ch, ji� zadan�ch tah�. Jedin�m zp�sobem je
editace PGN reprezentace partie: otev�ete okno <a Import>Importu</a>, zadejte
"Vlo�it aktu�ln� partii", opravte chybn� tah a zadejte "Import".
</p>

<h3>Zad�v�n� tah� z kl�vesnice</h3>
<p>
Pro zad�v�n� tah� z kl�vesnice jednodu�e stiskn�te odpov�daj�c� kl�vesy p�smene
a ��slice. V�imn�te si, �e akceptovateln� tahy mus� b�t v
<term>SAN notaci</term>, <i>bez</i> symbol� bran� (x) a prom�ny (=). P�i zad�v�n�
se nerozli�uje velikost p�smen, tak�e nap�. m�sto Nf3 m��ete zadat [n][f][3] --
p�e�t�te si ale pozn�mku n�e o konfliktech u p�cov�ch tah�.
</p>
<p>
Aby nedoch�zelo k probl�m�m, notace pro kr�tkou a dlouhou ro��du je [O][K] resp.
[O][Q] m�sto b�n�ch ozna�en� O-O a O-O-O.
</p>
<p>
P�i zad�v�n� tah� stavov� li�ta ukazuje adekv�tn� mo�n� tahy. Kdykoliv m��ete
stiskem [space] vybrat ze seznamu prvn� tah a p�idat ho tak do partie. Chcete-li
smazat n�jak� znak, stiskn�te [Backspace] nebo [Delete].
</p>
<p>
<b>V�imn�te si</b>, �e p�i mal�ch p�smenech se nejprve navrhuj� tahy p�ci,
tak�e [b] m��e odpov�dat p�ci nebo st�elci (Bishop), ale v p��pad� konfliktu
mus�te pro tah st�elcem pou��t velk� p�smeno [B].</p>

<h4>Dopl�ov�n� tah�</h4>
<p>
V menu Volby m��ete zapnout nebo vypnout automatick�
<term>dopl�ov�n� tah�</term>. P�i zapnut�m dopl�ov�n� tah� je tah zahr�n,
jakmile jste zadali dostatek informac� pro jeho rozezn�n� mezi ostatn�mi mo�n�mi
tahmi. Nap�. p�i zapnut�m dopl�ov�n� sta�� pro tah <b>Jf3</b> v po��te�n� pozici
zadat [n][f] m�sto [n][f][3].</p>

<h3><name Null>Zad�v�n� nulov�ch tah�</name></h3>
<p>
<a Annotating Null>Nulov�</a> (pr�zdn�) tahy mohou b�t u�ite�n� ve variant�ch,
 kde
chcete p�esko�it tah jedn� strany. Nulov� tah m��ete zadat my�� vzet�m jednoho
kr�le druh�m kr�lem nebo kl�vesnic� zad�n�m "<b>--</b>" (tj. dvakr�t stisknout
tla��tko m�nus).</p>

<h3>Zad�v�n� b�n�ch anota�n�ch symbol�</h3>
<p>
Rovn� m��ete v hlavn�m okn� s pomoc� kl�vesnice zad�vat b�n�
<a NAGs>anota�n� symboly</a>, bez nutnosti pou��t okno
<a Comment>editoru koment���</a>. N�sleduj�c� seznam ukazuje,kter� symboly m��ete
zadat a jejich kl�vesov� zkratky:
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

<p><footer>(Aktualizov�no: Scid 3.4, �ervenec 2002)</footer></p>
}


#########################
### Searches help screen:

set helpTitle(C,Searches) "Vyhled�v�n�"
set helpText(C,Searches) {<h1>Vyhled�v�n� Scidem</h1>
<p>
Scid m��e v datab�zi vyhled�vat podle r�zn�ch typ�. T�i hlavn� typy vyhled�v�n�
 jsou:
<ul>
<li><b>1)</b> podle aktu�ln� pozice na �achovnici, </li>
<li><b>2)</b> podle specifikovan�ch vzor� materi�lu nebo figur, a </li>
<li><b>3)</b> podle informac� v hlavi�ce jako nap�. hr��i, v�sledek, datum.
 </li>
</ul>
<p>
K t�mto t�em typ�m vyhled�v�n� nav�c existuje automatick� vyhled�vac� m�d zvan�
<a Tree>Okno stromu</a>, kter� je objasn�n zvlṻ.
</p>

<h3><name Filter>Vyhled�vac� filtr</name></h3>
<p>
Vyhled�v�n� ve Scidu jsou zalo�eny na pojmu <term>filtr</term>. Filtr
reprezentuje podmno�inu aktu�ln� datab�ze: v ka�d�m okam�iku je ka�d� partie bu�
ve filtru obsa�ena nebo z filtru vy�ata.
</p>
<p>
U ka�d�ho typu vyhled�v�n� m��ete vyhled�v�n� omezit na existuj�c� filtr, p�idat
k existuj�c�mu filtru nebo filtr ignorovat a prohledat tak celou datab�zi.
</p>
<p>
M��ete rovn� v�echny partie jedn� datab�ze obsa�en� ve filtru zkop�rovat do
jin� datab�ze pou�it�m okna <a Switcher>v�b�ru datab�ze</a>.
</p>
<p>
P�i vyhled�v�n� podle pozice, podle materi�lu/vzoru nebo p�i
<a Tree>stromov�ch</a> vyhled�v�n�ch se ��slo tahu prvn� odpov�daj�c� pozice
ka�d� odpov�daj�c� partie zapamatuje, tak�e p�i nahr�n� ka�d� partie bude
automaticky zobrazena odpov�daj�c� pozice.
</p>
<p>
<b>V�imn�te si</b>, �e vyhled�v�n� prob�h� jen v hlavn� variant� ka�d� partie, ne
v ostatn�ch variant�ch. </p>

<h3><name Board>Vyhled�v�n� podle aktu�ln� pozice</name></h3>
<p>
Tento zp�sob vyhled�v�n� nalezne partie, kter� obsahuj� aktu�ln� zobrazenou
pozici, p�i ignorov�n� pr�v ro��dy a bran� mimochodem (<i>en passant</i>).
</p>
<p>
Existuj� �ty�i typy vyhled�v�n� podle pozice. V�echny �ty�i vy�aduj� tent��
materi�l a shodu u strany, kter� m� b�t na tahu. Tyto typy jsou:
<ul>
<li> [1] p�esn� pozice (v�echny figury na stejn�ch pol�ch), </li>
<li> [2] p�ci (v�ichni p�ci na stejn�ch pol�ch, figury mohou b�t kdekoliv),
     </li>
<li> [3] sloupce (v�ichni p�ci na stejn�ch sloupc�ch, figury mohou b�t
     kdekoliv), a </li>
<li> [4] materi�l (p�ci a figury mohou b�t kdekoliv). </li>
</ul>
<p>
Vyhled�v�n� podle p�c� je u�ite�n� p�i studiu zah�jen� podle p�cov� struktury,
vyhled�v�n� podle �ad a materi�lu je zase u�ite�n� pro nalezen� podobn�ch pozic
v koncovce.
</p>
<p>
Chcete-li hledat libovolnou pozici, m��ete si pozici nejprve nastavit na
�achovnici (z menu <menu>Editace: Nastavit v�choz� pozici</menu>) a potom
spustit jej� vyhled�v�n�. </p>
<p>
V�b�rem <b>D�vat se do variant</b> m��ete po�adovat vyhled�v�n� i ve variant�ch
(m�sto jen v hlavn� variant� partie), ale to m��e vyhled�v�n� zna�n� zpomalit,
je-li datab�ze velk� a obsahuje mnoho parti� s variantami.
</p>

<h3><name Material>Vyhled�v�n� podle materi�lu/vzoru</name></h3>
<p>
Tento zp�sob vyhled�v�n� je vhodn� pro hled�n� t�mat z koncovek a st�edn� hry.
M��ete specifikovat minim�ln� a maxim�ln� po�et jednotliv�ch kamen� a hledat
vzory jako nap�. st�elec na f7 nebo p�ec na f sloupci.
</p>
<p>
Je p�eddefinov�no mno�stv� b�n�ch materi�ln�ch sestav a vzor�, jako nap�.
koncovky v� proti p�ci nebo d�msk� izolovan� p�ec.
</p>
<p>
<b>Rada:</b><br>
Rychlost vyhled�v�n� podle vzoru se m��e �iroce li�it. Nastaven�m inteligentn�ch
omezen� m��ete vyhled�vac� �as redukovat. Nap�. jestli�e p�i hled�n� koncovky
nastav�te minim�ln� ��slo tahu na 20, v�echny partie kon��c� pod 20 tah� mohou
b�t p�esko�eny.
</p>

<h3><name Header>Vyhled�v�n� podle hlavi�ky</name></h3>
<p>
Tento zp�sob vyhled�v�n� m��e b�t pou�it na hled�n� takov�ch aspekt� partie,
kter� jsou ulo�eny v jej� hlavi�ce (jako datum, v�sledek, jm�na, p��znaky a
ratingy), tak�e nevy�aduje ��dn� dek�dov�n� tah�.
</p>
<p>
Aby partie vyhovovala vyhled�v�n� podle hlavi�ky, mus� vyhovovat <b>v�echna</b>
pole, kter� jste specifikovali.
</p>
<p>
P�i vyhled�v�n� podle pol� jmen (B�l�, �ern�, Turnaj, M�sto a Kolo) vyhovuje
jak�koliv text obsahuj�c� zadan� jm�no, p�itom se nerozli�uje velikost p�smen a
ignoruj� se mezery. </p>
<p>
Pro tato pole jmen m��ete pou��vat b�n� z�stupn� znaky (<b>?</b> reprezentuj�c�
jeden jak�koliv znak a <b>*</b> reprezentuj�c� nulu nebo v�ce znak�) a prov�d�t
vyhled�v�n� s rozli�ov�n�m velikosti p�smen uzav�en�m hledan�ho textu do
uvozovek.  Nap�. vyhled�v�n� M�sto <b>USA</b> najde americk� m�sta a tak�
<b>Lausanne SUI</b>, co� pravd�podobn� nen� to, �eho jste cht�li dos�hnout! Ale
vyhled�v�n� M�sto <b>"*USA"</b> (nezapome�te pou��t uvozovky) opravdu najde jen
m�sta ve Spojen�ch St�tech. </p>
<p>
Jestli�e hled�te jednotliv�ho hr��e (nebo dvojici soupe��) jako B�l� nebo �ern�
a nez�le�� na tom, jak�mi barvami hr�li, zvolte <b>Ignorovat barvy</b>.
</p>
<p>
Kone�n�, vyhled�v�n� podle hlavi�ky m��e b�t pou�ito na nalezen� jak�hokoliv
textu (p�i rozli�ov�n� velikosti p�smen a bez pou�it� z�stupn�ch znak�)v PGN
reprezentaci ka�d� partie. M��ete zadat a� t�i textov� �et�zce, kter� se v�echny
mus� objevit v partii, aby partie vyhovovala.
Tento zp�sob vyhled�v�n� je velmi u�ite�n� pro hled�n� v koment���ch nebo
zvl�tn�ch pozn�mek (jako nap�. <b>prohra na �as</b> nebo <b>Koment�tor</b>),
nebo pro sekvenci tah� jako <b>Sxh7+</b> a <b>Kxh7</b> pro p�ijatou ob� st�elce
na h7.
Av�ak tento typ vyhled�v�n� m��e b�t <i>velmi</i> pomal�, proto�e v�echny
partie, vyhovuj�c� ostatn�m krit�rium, mus� b�t dek�dov�ny a prohled�ny na
v�skyt t�chto textov�ch �et�zc�.
Proto je dobrou ideou tato vyhled�v�n� co nejv�c omezit.
Zde jsou n�jak� p��klady.
Hled�te-li partie s prom�nou p�ce na v�, zadejte <b>=V</b> a rovn� nastavte
p��znak <b>Prom�ny</b> na Ano. Hled�te-li text, kter� by se mohl objevit v
koment���ch, nastavte p��znak <b>Koment��e</b> na Ano.
Hled�te-li tahy <b>Sxh7+</b> a <b>Kxh7</b>, budete mo�n� nap�. cht�t vyhled�v�n�
omezit na partie s v�sledkem 1-0 a nejm�n� s 40 p�ltahy, nebo nejprve prov�st
vyhled�v�n� podle materi�lu/vzoru, kde b�l� st�elec t�hnul na h7.
</p>

<h3><name Settings>Ulo�en� vyhled�vac�ch nastaven�</name></h3>
<p>
Okna vyhled�v�n� podle materi�lu/vzoru a podle hlavi�ky poskytuj� tla��tko
<term>Ulo�it</term>. To v�m dovoluje ulo�it svoje aktu�ln� nastaven� vyhled�v�n�
pro pozd�j�� pou�it�, kter� se ulo�� do <term>souboru vyhled�vac�ch voleb</term>
(SearchOption, p��pona .sso).
Chcete-li prov�d�t vyhled�v�n� pou�it�m d��ve ulo�en�ho souboru vyhled�vac�ch
voleb (.sso), z menu <menu>Hledat</menu> vyberte <menu>Hledat pomoc� souboru
voleb</menu>.
</p>

<h3>Vyhled�vac� �asy a p�esko�en� partie</h3>
<p>
V�t�ina vyhled�v�n� produkuje zpr�vu indikuj�c� spot�ebovan� �as a po�et parti�,
kter� byly <term>p�esko�eny</term>. P�esko�en� partie je takov� partie, kter�
m��e b�t z vyhled�v�n� vy�ata na z�klad� informac� ulo�en�ch v indexu, bez
dek�dov�n� jak�hokoliv jej�ho tahu. Pro v�ce informac� se pod�vejte na str�nku
n�pov�dy o <a Formats>form�tech soubor�</a>.
</p>

<p><footer>(Aktualizov�no: Scid 3.0, Listopad 2001)</footer></p>
}


##################
### Clipbase help:

set helpTitle(C,Clipbase) "Schr�nka"
set helpText(C,Clipbase) {<h1>Datab�ze schr�nka</h1>
<p>
K datab�z�m, kter� m�te otev�en�, Scid nav�c poskytuje datab�zi
<term>schr�nka</term>, kter� je stejn� jako ostatn� datab�ze krom� toho, �e
existuje jen v pam�ti a nem� ��dn� soubory pro trval� ulo�en�.
</p>
<p>
Tato schr�nka je u�ite�n� jako do�asn� datab�ze, pro sjednocov�n� v�sledk�
vyhled�v�n� ve v�ce ne� jedn� datab�zi nebo jako samostatn� datab�ze pro
zpracov�n� v�sledk� vyhled�v�n�.
</p>
<p>
P�edpokl�dejme nap�., �e se chcete p�ipravit na soupe�e a prohledali jste
datab�zi, tak�e <a Searches Filter>filtr</a> obsahuje jen partie, kde soupe�
hr�l b�l�ma.
Tyto partie m��ete zkop�rovat do schr�nky (ta�en�m z jejich datab�ze do schr�nky
v okn� <a Switcher>v�b�ru datab�ze</a>), p�epnout se do datab�ze schr�nka a
otev�en�m <a Tree>okna stromu</a> prozkoumat reperto�r tohoto hr��e. </p>
<p>
V�imn�te si, �e partie ve filtru z jedn� datab�ze m��ete p��mo zkop�rovat do
jin� otev�en� datab�ze (bez pou�it� schr�nky jako zprost�edkuj�c�ho m�sta)
pou�it�m okna <a Switcher>v�b�ru datab�ze</a>.
</p>
<p>
V�imn�te si, �e schr�nka <i>nem��e</i> b�t zav�ena; nach�z�te-li se ve schr�nce,
p��kaz <menu>Soubor: Zav��t</menu> je ekvivalentn� p��kazu
<menu>Editace: Vypr�zdnit schr�nku</menu>, kter� vypr�zdn� schr�nku.
</p>
<p>
Velikost schr�nky je trvale omezena 20,000 partiemi, proto�e existuje jen v
pam�ti.
</p>

<p><footer>(Aktualizov�no: Scid 2.5, �erven 2001)</footer></p>
}

#################################
### Variations and comments help:

set helpTitle(C,Annotating) "Anotace parti�"
set helpText(C,Annotating) {<h1>Anotace parti�</h1>
<p>
Scid v�m umo��uje k partii p�idat pozn�mky. Jsou t�i typy anotac�, kter� m��ete
p�idat za tah: symboly, koment�� a varianty.
</p>

<h3>Symboly a koment��e</h3>
<p>
Symboly se pou��vaj� pro indikaci hodnocen� pozice (jako nap�. "+-" nebo "=")
nebo k ozna�en� dobr�ch ("!") a �patn�ch ("?") tah�, zat�mco koment�� m��e b�t
libovoln� text. Chcete-li k partii p�idat symboly, pou�ijte okno
<a Comment>Editoru koment���</a>.
Je zde tak� str�nka n�pov�dy se seznamem
<a NAGs>standardn�ch symbolick�ch hodnot</a>. </p>
<p>
Uv�domte si, �e ka�d� tah m��e m�t v�ce ne� jeden anota�n� symbol, ale pouze
jeden koment��. Koment�� p�ed prvn�m tahem partie je zobrazen jako text p�ed
za��tkem partie.
</p>

<h3><name Vars>Varianty</name></h3>
<p>
<term>Varianta</term> tahu je alternativn� posloupnost tah� v ur�it�m m�st�
partie. Varianty mohou obsahovat koment��e a dokonce rekurzivn� mohou m�t
podvarianty. Pro vytvo�en�, navigaci a editaci variant lze pou��t tla��tka nad
�achovnic� se symbolem "<b>V</b>" a p��kazy v menu <menu>Edit</menu>.
</p>

<h4>Kl�vesov� zkratky</h4>
<p>
Kdy� m� tah varianty, jsou zobrazeny v informa�n� z�n� partie. Prvn� bude
ozna�ena <b>v1</b>, druh� <b>v2</b> atd.
Kliknut�m na variantu m��ete do n� sko�it nebo stiskn�te "<b>v</b>" n�sledovan�
��slem varianty. (Jestli�e k tahu existuje jen jedna varianta, jednoduch� stisk
<b>v</b> do n� sko��.)
Chcete-li variantu opustit, m��ete pou��t kl�vesovou zkratku "<b>z</b>".
</p>

<h3><name Null>Nulov� tahy</name></h3>
<p>
N�kdy m��ete shledat u�ite�n�m ve variant� p�esko�it tah jedn� strany. Nap�.
m��ete cht�t p�idat do varianty tah 14.Sd3 a pouk�zat, �e hroz� 15.Sxh7+ Kxh7
16.Jg5+ s �tokem. To m��ete ud�lat proveden�m <term>nulov�ho tahu</term>, v
p��kladu v��e mezi 14.Sd3 a 15.Sxh7+. Nulov� tah je zobrazen jako  "<b>--</b>"
a m��e b�t zad�n pou�it�m my�i proveden�m nemo�n�ho tahu vzet� jednoho kr�le
druh�m nebo z kl�vesnice zad�n�m "<b>--</b>" (dv� znam�nka m�nus).
</p>
<p>
Uv�domte si, �e nulov� tahy nejsou sou��st� PGN standardu, tak�e jestli�e
exportujete partie s nulov�mi tahy do PGN souboru, Scid poskytne (krom� jin�ch
voleb exportu) volbu uchovat nulov� tahy nebo je zkonvertovat na koment��e pro
kompatibilitu s jin�m softwarem.
Pro v�ce detail� �t�te str�nku n�pov�dy o <a Export>exportov�n�</a>.
</p>

<p><footer>(Aktualizov�no: Scid 3.4, �ervenec 2002)</footer></p>
}

###############################
### Comment editor window help:

set helpTitle(C,Comment) "Okno editoru koment���"
set helpText(C,Comment) {<h1>Okno editoru koment���</h1>
<p>
Okno editoru koment��� umo��uje p�id�vat nebo editovat koment��e a symbolick�
anota�n� znaky k tah�m aktivn� partie.
</p>

<h3>Anota�n� symboly</h3>
<p>
Scid pou��v� pro anota�n� symboly <a Author Related>PGN standard</a> spolu s
<a NAGs>NAG (numeric annotation glyph)</a> anota�n�mi hodnotami. N�kter� z v�t�iny
b�n�ch znak� (jako "!" nebo "+-") jsou zobrazeny jako znaky a pro rychl� pou�it�
je pro n� v okn� editoru koment��� tla��tko. Pro ostatn� symboly m��ete zadat
odpov�daj�c�  numerickou NAG hodnotu, kter� je ��slo od 1 do 255.
Nap�. NAG hodnota 36 znamen�  "B�l� m� iniciativu" a bude v
<a PGN>PGN z�pisu</a> partie zobrazena jako "$36".
</p>
<p>
P�e�t�te si str�nku n�pov�dy o <a NAGs>NAG hodnot�ch</a> definovan�ch
PGN standardem.
</p>
<p>
<b>Rada:</b> B�n� hodnot�c� symboly k tah�m (!, ?, !!, ??, !? and ?!)
m��ete zadat v hlavn�m okn�, bez pou�it� okna editoru koment���, stiskem
odpov�daj�c�ho znaku n�sledovan�ho kl�vesou [Return].
To je velmi u�ite�n�, zvl�t� p�i <a Moves>zad�v�n� tah�</a> z kl�vesnice.
</p>

<h3>Koment��e</h3>
<p>
Koment��e m��ete editovat z�pisem v poskytovan� textov� oblasti a pou�it�m
tla��tek Vy�istit, Vr�tit se a Uschovat.
K �schov� koment��e nen� pot�eba neust�le pou��vat tla��tko Uschovat; koment��
je automaticky uschov�n, kdykoliv p�ejdete k jin� pozici partie.</p>

<h3>Barevn� zna�en� pol�</h3>
<p>
Pou�it�m speci�ln�ho vlo�en�ho p��kazu, kter� se m��e objevit kdekoliv v
koment��i, m��ete libovolnou barvou barevn� ozna�it libovoln� pole �achovnice.
Form�t tohoto p��kazu je:
</p>
<ul>
<li><b>[%mark square color]</b><li>
</ul>
<p>
kde <b>square</b> (tj. pole) je ozna�en� pole jako nap�. d4 a <b>color</b> (tj.
barva) je libovoln� zn�m� jm�no barvy (jako nap�. red, blue4, darkGreen,
lightSteelBlue atd.) nebo RGB k�d (znak <b>#</b> n�sledovan� �estic�
hexadecim�ln�ch ��slic, jako nap�. #a0b0c8). Jestli�e color je vynech�no,
pou�ije se implicitn� <red>red</red>.
</p>
<p>
Koment�� m��e obsahovat libovoln� po�et t�chto p��kaz�, ale ka�d� mus� m�t sv�
vlastn� <b>[%mark ...]</b> ozna�en�. Nap�. text koment��e
</p>
<p>
  Nyn� je d6 [%mark d6] slab� a m��e b�t napadeno jezdcem z b5.
  [%mark b5 #000070]
</p>
<p>
ozna�� d6 <red>�erven�</red> a b5 tmavomodrou barvou
<darkblue>#000070</darkblue>.
</p>

<h3>Kreslen� �ipek</h3>
<p>
Pou�it�m speci�ln�ho komentovac�ho p��kazu podobn�mu p�edchoz�mu m��ete
nakreslit �ipku z jednoho pole k druh�mu. Form�t tohoto p��kazu je:
</p>
<ul>
<li><b>[%arrow fromSquare toSquare color]</b><li>
</ul>
<p>
kde <b>fromSquare</b> (tj. z pole) a <b>toSquare</b> (tj. na pole) jsou ozna�en�
pol� jako nap�. d4 a <b>color</b> (tj. barva) je libovoln� zn�m� jm�no barvy
(nap�. red, blue4 atd.) nebo RGB k�d (nap�. #a0b0c8). Jestli�e color je
vynech�no, pou�ije se implicitn� <red>red</red>.
</p>
<p>
Nap�. text koment��e
</p>
<p>
  Jezdec c3 a st�elec c4 kontroluj� slab� pole d5.
  [%arrow c3 d5 red] [%arrow c4 d5 blue]
</p>
<p>
nakresl� �ervenou �ipku z c3 na d5 a modrou z c4 na d5.
</p>

<p><footer>(Aktualizov�no: Scid 3.2, �nor 2002)</footer></p>
}

###########################
### Crosstable window help:

set helpTitle(C,Crosstable) "Okno turnajov� tabulky"
set helpText(C,Crosstable) {<h1>Okno turnajov� tabulky</h1>
<p>
Okno turnajov� tabulky zobrazuje turnajovou tabulku pro aktu�ln� partii.
Kdykoliv zvol�te aktualizaci tohoto okna (stiskem tla��tka Aktualizovat nebo
stiskem kl�vesy <b>Return</b> v okn� turnajov� tabulky nebo kl�vesovou zkratkou
<b>Control+Shift+X</b> v <a MainWindow>hlavn�m okn�</a> nebo v
<a GameList>okn� seznamu parti�</a>), Scid vyhled� v�echny partie toho turnaje,
z kter�ho je aktu�ln� partie.
</p>
<p>
Partie se pova�uje ze stejn�ho turnaje jako je aktu�ln� partie, jestli�e se
hr�la v <b>�asov�m intervalu maxim�ln� t�� m�s�c�</b> od aktu�ln� partie a m�
<b>p�esn� stejn� speci�ln� ozna�en� Event</b> (turnaj) a <b>Site</b> (m�sto).
</p>
<p>
Kliknut�m lev�m tla��tkem my�i na kter�koliv v�sledek v tabulce lze nat�hnout
odpov�daj�c� partii.
Pomoc� tla��tka <b>P�idat do filtru</b> v okn� turnajov� tabulky m��ete v�echny
partie turnaje p�idat do <a Searches Filter>filtru</a>.
</p>

<h4>Menu okna turnajov� tabulky</h4>
<p>
Menu <menu>Soubor</menu> umo��uje tisk aktu�ln� tabulky do textov�ho, LaTeX
nebo HTML souboru.
</p>
<p>
Menu <menu>Zobrazit</menu> umo��uje vybrat form�t tabulky:
<b>Ka�d� s ka�d�m</b>, <b>�v�carsk� syst�m</b> nebo <b>Vy�azovac�</b> nebo
<b>Auto</b>.
</p>
<p>
Form�t ka�d� s ka�d�m (pro kruhov� turnaje) je omezen po�tem 30 hr���, ale
�v�carsk� syst�m (pro turnaje s mnoha hr��i) m��e zobrazit a� 200 hr��� a a� 20
kol. Form�t <b>auto</b>, kter� pro ka�d� turnaj automaticky vybere nejlep��
form�t, je nastaven implicitn�.
</p>
<p>
Uv�domte si, �e Scid pou��v� k p��prav� tabulky �v�carsk�ho syst�mu speci�ln�
ozna�en� <b>Round</b> (Kolo) ka�d� partie, tak�e v turnajov� tabulce �v�carsk�ho
syst�mu neuvid�te ��dn� partie, jestli�e jeho partie nebudou m�t numerick�
ozna�en� kol: 1, 2, 3, atd.
</p>
<p>
Menu Zobrazit v�m rovn� umo��uje p�izp�sobit si prezentovan� �daje p�id�n�m
nebo odebr�n�m rating�, zem� a titul� hr���. M��ete rovn� zvolit, zda maj� b�t
v tabulce indikov�ny barvy (jen pro �v�carsk� syst�m).
</p>
<p>
Volba <b>Skupiny podle sk�re</b> ovliv�uje zobrazen� tabulky jen tehdy, kdy�
jsou hr��i se�azeni podle bod�: mezi skupiny hr��� se stejn�m po�tem bod� je pro
lep�� p�ehlednost vlo�en pr�zdn� ��dek.
</p>
<p>
Menu <menu>�adit</menu> umo��uje se�adit hr��e podle jm�na, ratingu nebo podle
sk�re; implicitn� jsou �azeni podle sk�re.
</p>
<p>
Menu <menu>Barvy</menu> umo��uje zapnout nebo vypnout barevn� (hypertextov�)
zobrazov�n�. Proto�e v�ak form�tov�n� a zobrazen� velk� tabulky v hypertextu
m��e trvat velmi dlouho, volbou <b>Prost� text</b> pro velk� turnaje u�et��te
spoustu �asu.
Av�ak v textov�m m�du nelze klikat na hr��e �i partie.
</p>

<h4>Duplicitn� partie v tabulce</h4>
<p>
Abyste dostali v turnajov� tabulce spr�vn� v�sledky, je pot�eba ozna�it k
v�mazu duplicitn� partie a partie mus� m�t shodn� tvary jmen hr���, turnaj� a
m�st.
Pro dal�� n�pov�du o maz�n� duplicitn�ch parti� a editaci (nebo kontrole
pravopisu) jmen hr���, turnaj�, m�st �t�te str�nku
<a Maintenance>�dr�by datab�ze</a>.
</p>

<p><footer>(Aktualizov�no: Scid 3.1, Prosinec 2001)</footer></p>
}


###########################
### Database switcher help:

set helpTitle(C,Switcher) "V�b�r datab�ze"
set helpText(C,Switcher) {<h1>Okno v�b�ru datab�ze</h1>
<p>
Okno v�b�ru datab�ze poskytuje pohled, kter� umo��uje jednodu�e se p�ep�nat a
kop�rovat partie mezi datab�zemi.
Je zobrazeno jm�no, stav <a Searches Filter>filtru</a> a graficky typ ikony
ka�d� datab�ze, aktivn� datab�ze je zv�razn�na �lut�m pozad�m.
</p>
<p>
Okno v�b�ru datab�ze m��ete otev��t z menu <menu>Okna</menu> nebo jeho
kl�vesovou zkratkou: <b>Control+D</b>.
</p>
<p>
Chcete-li zkop�rovat v�echny filtrovan� partie jedn� datab�ze do druh�,
t�hn�te stisknut�m lev�m tla��tkem my�i od zdrojov� datab�ze do c�lov�. Jestli�e
partie mohou b�t zkop�rov�ny, uvid�te potvrzovac� dialog (jestli�e c�lov�
datab�ze nen� <a Clipbase>schr�nka</a>), jestli�e partie nemohou b�t
zkop�rov�ny, uvid�te chybovou zpr�vu.
</p>
<p>
Stisk prav�ho tla��tka my�i nad datab�z� vyvol� vyskakovac� menu
t�kaj�c� se t�to datab�ze, z kter�ho lze zm�nit typ ikony datab�ze nebo
resetovat jej� <a Searches Filter>filtr</a>. Toto menu lze rovn� pou��t ke
zm�n� orientace okna (vertik�ln� nebo horizont�ln�), co� je u�ite�n� pro
men�� obrazovky.
</p>

<p><footer>(Aktualizov�no: Scid 3.1, Prosinec 2001)</footer></p>
}


############################
### File Finder window help:

set helpTitle(C,Finder) "Okno vyhled�va�e soubor�"
set helpText(C,Finder) {<h1>Okno vyhled�va�e soubor�</h1>
<p>
<term>Vyhled�va� soubor�</term> v�m pom�h� p�i hled�n� soubor� v�ech typ�, kter�
lze ve Scidu pou��t: datab�z�, <a PGN>PGN</a> soubor�, <a EPD>EPD</a> soubor� a
<a Repertoire>reperto�rov�ch</a> soubor�.
</p>
<p>
Vyhled�va� zobrazuje o ka�d�m souboru u�ite�n� informace jako jeho velikost
(�t�te n�e) a datum posledn� modifikace. Kter�koliv zobrazen� soubor lze
otev��t jeho vybr�n�m jednoduch�m kliknut�m lev�m tla��tkem my�i.
</p>

<h3>Hled�n� v podadres���ch</h3>
<p>
Jestli�e chcete nal�zt v�echny soubory ve v�ech podadres���ch sou�asn�ho
adres��e, zapn�te volbu <b>Hledat v podadres���ch</b>. Takto bude Scid
rekurzivn� hledat ve v�ech podadres���ch soubory, kter� lze ve Scidu otev��t.
Pro mnoho podadres��� to m��e trvat velmi dlouho, tak�e nen� vhodn� to prov�d�t
pro adres�� bl�zko ko�enov�ho adres��e souborov�ho syst�mu. Vyhled�v�n� soubor�
lze zastavit tla��tkem <b>Stop</b>.
</p>

<h3>Velikost souboru</h3>
<p>
V�znam velikosti souboru zobrazen� vyhled�va�em z�vis� na typu souboru. Pro
datab�ze Scidu a PGN soubory znamen� po�et parti�. Pro EPD soubory znamen� po�et
pozic. Pro reperto�rov� soubory znamen� po�et (zahrnut�m nebo vylou�en�ch)
variant.
</p>
<p>
Pro v�echny typy soubor� krom� datab�zi Scidu je velikost souboru
odhad vytvo�en� prohl�dnut�m jen prvn�ch 64 kilobyt� souboru, tak�e velikost
soubor� v�t��ch ne� 64 kb nemus� b�t spr�vn�. Odhadnut� velikosti jsou zobrazeny
se znakem tilda (~), indikuj�c tak, �e nejsou p�esn�.
</p>

<p><footer>(Aktualizov�no: Scid 2.7, Z��� 2001)</footer></p>
}

##################################
### Tournament Finder window help:

set helpTitle(C,Tmt) "Okno vyhled�va�e turnaj�"
set helpText(C,Tmt) {<h1>Okno vyhled�va�e turnaj�</h1>
<p>
<term>Vyhled�va� turnaj�</term> v�m umo��uje naj�t turnaje v aktu�ln� datab�zi.
Proch�z� v�echny partie datab�ze a ov��uje �daje o nalezen�ch turnaj�ch.
V�imn�te si, �e dv� partie se pova�uj� za partie ze stejn�ho turnaje, jestli�e
maj� stejn� speci�ln� ozna�en� Event (Turnaj), stejn� speci�ln� ozna�en� Site
(M�sto) a hr�ly se v �asov�m intervalu maxim�ln� t�� m�s�c� od sebe.
</p>
<p>
Editac� pol� pod seznamem turnaj� a n�sledn�m stiskem tla��tka
<b>Aktualizovat</b> m��ete seznam omezit po�tem hr��� a parti�, datumem,
pr�m�rn�m Elo ratingem a zem�.
</p>
<p>
Zobrazen� seznam m��e b�t set��d�n podle data, po�tem hr���, po�tem parti�,
pr�m�rn�m Elo ratingem, m�stem, turnajem nebo p��jmen�m v�t�ze. Kategorii
vyberte z menu <menu>�adit</menu> nebo klikn�te na titulek po�adovan�ho sloupce.
</p>
<p>
Chcete-li nat�hnout prvn� partii libovoln�ho zobrazen�ho turnaje, sta�� kliknout
lev�m tla��tkem my�i, kdy� je ��dek po�adovan�ho turnaje zv�razn�n. Tak dojde
rovn� k aktualizaci okna <a Crosstable>turnajov� tabulky</a>, je-li otev�eno.
Jestli�e m�sto toho kliknete prav�m tla��tkem my�i, partie se nat�hne a okno
turnajov� tabulky se otev�e, i kdy� bylo zav�eno.
</p>
<p>
Pro urychlen� procesu vyhled�v�n� turnaj� je dobrou ideou nastavit docela mal�
�asov� rozsah (jako nanejv��e n�kolik let) nebo vybrat ur�itou zemi (jej�m
t��znakov�m standardn�m k�dem). To zna�n� zredukuje po�et parti�, kter� Scid
mus� vz�t do �vahy p�i zformov�n� turnaj� z parti� v datab�zi.
</p>

<p><footer>(Aktualizov�no: Scid 3.3, Duben 2002)</footer></p>
}

#########################
### GameList window help:

set helpTitle(C,GameList) "Okno seznamu parti�"
set helpText(C,GameList) {<h1>Okno seznamu parti�</h1>
<p>
Okno seznamu parti� zobrazuje jedno��dkov� souhrn informac� pro ka�dou partii
obsa�enou v aktu�ln�m <term>filtru</term>.
</p>

<h3>Navigace v seznamu parti�</h3>
<p>
V seznamu parti� se m��ete pohybovat pomoc� posuvn� li�ty nebo pou�it�m �ty�
tla��tek pod seznamem. V seznamu se lze pohybovat rovn� pomoc� kl�vesnice, a to
kl�vesami [Home], [End], [Page Up], [Page Down] a �ipkami.
</p>
<p>
Pou�it�m ok�nka <b>Hledat text</b> lze vyhled�vat n�sleduj�c� partii v seznamu,
kter� obsahuje v poli B�l�, �ern�, Turnaj nebo M�sto jist� text.
</p>

<h3>Akce s partiemi v seznamu</h3>
<p>
Nat�hnout partii ze seznamu lze dvojklikem lev�ho tla��tka na partii.
Kliknut�m prost�edn�ho tla��tka my�i se zobraz� po��te�n� tahy partie; to m��e
b�t u�ite�n� na kontrolu zah�jen� partie p�ed jej�m nata�en�m.
</p>
<p>
Prav� tla��tko my�i vyvol� pro vybranou partii menu, v kter�m m��ete prohl�dnout
nebo p�ipojit partii (viz n�e), smazat (nebo obnovit) partii nebo ji vyjmout z
filtru.
Uv�domte si, �e smazan� partie jen zapne jej� mazac� p��znak; partie z�stane a�
do <a Compact>zhutn�n�</a> v datab�zi.
</p>

<h3>Konfigurace seznamu parti�</h3>
<p>
Ke konfiguraci seznamu parti� klikn�te lev�m nebo prav�m tla��tkem my�i na
titulku sloupce. M��ete tak zm�nit ���ku sloupce, p�idat nebo odebrat sloupce a
zm�nit bravu pro ka�d� sloupec.
</p>
<p>
Chcete-li jen zm�nit velikost sloupce, lze pou��t kl�vesovou zkratku; p�idr�en�m
kl�vesy <b>Control</b> (nebo <b>Shift</b>) a sou�asn�m stiskem lev�ho tla��tka
my�i na titulku sloupce ho z���te a stiskem prav�ho tla��tka roz����te.
</p>

<h3>Zm�na velikosti seznamu parti�</h3>
<p>
Velikost okna seznamu parti� se zap�e do souboru voleb p�i ka�d�m ulo�en�
voleb.
Tak�e chcete-li, aby seznam parti� zobrazoval implicitn� 10 parti�, zm��te
velikost okna seznamu parti� a zadejte p��kaz <menu>Ulo�it volby</menu> z menu
<menu>Volby</menu>.
</p>

<h3><name Browsing>Prohl�en� a p�ipojov�n� parti�</name></h3>
<p>
Menu vyvolan� prav�m tla��tkem my�i v seznamu parti� (a tak� jin� okna jako
okno <a Reports Opening>profilu zah�jen�</a> a
<a Tree Best>seznam nejlep��ch parti�</a> v okn� <a Tree>stromu</a>) poskytuje
v�b�r nata�en�, prohl�dnut� a p�ipojen� partie.
</p>
<p>
P�i volb� <term>Prohl�dnout partii</term> jsou tahy vybran� partie (bez
koment��� nebo variant) zobrazov�ny v samostatn�m okn�. To je u�ite�n� cesta k
prohl�dnut� jin� partie bez ovlivn�n� aktu�ln� nata�en� partie.
</p>
<p>
Volba <term>P�ipojit partii</term> poskytuje zp�sob k p�ipojen� vybran� partie
jako varianty k aktu�ln� partii. Scid nalezne nejhlub�� m�sto, kde se vybran�
partie li�� od aktu�ln� partie (p�ehozen� tah� se berou v �vahu), a v t�to
pozici p�id� vybranou partii jako variantu. M��ete rovn� zm�nit po�et p�idan�ch
tah� vybran� partie podle toho, jestli chcete p�ipojit celou partii nebo jen
jej� zah�jen�.
</p>

<p><footer>(Aktualizov�no: Scid 3.2, �nor 2002)</footer></p>
}


#######################
### Import window help:

set helpTitle(C,Import) "Okno importu parti�"
set helpText(C,Import) {<h1>Okno importu parti�</h1>
<p>
Okno importu Scidu v�m poskytuje jednoduch� zp�sob ke vkl�d�n� partie v
<a PGN>PGN form�tu</a> z jin� aplikace nebo okna do Scidu.
</p>
<p>
Velk� b�l� r�mec v okn� je m�sto, kam zap�ete nebo vlo��te text partie v PGN
form�tu, �ed� r�mec pod poskytuje zp�tnou vazbu v�ech chyb a varov�n�.
</p>

<h3>Editace aktu�ln� partie prost�ednictv�m okna importu</h3>
<p>
Okno importu lze rovn� pou��t jako �ikovn� prost�edek k proveden� n�kolika m�lo
zm�n v aktu�ln� partii: m��ete vlo�it aktu�ln� partii do okna importu (pou�it�m
tla��tka <b>Vlo�it aktu�ln� partii</b>), editovat jej� text a po skon�en�
kliknout <b>Import</b>.
</p>

<h3>Speci�ln� ozna�en� PGN v okn� importu</h3>
<p>
Scid o�ek�v� p�ed v�emi tahmi speci�ln� hlavi�kov� ozna�en� PGN jako nap�.
<ul>
<li> <b>[Result "*"]</b>, </li>
</ul>
ale klidn� m��ete vlo�it partii jako
<ul>
<li> <b>1.e4 e5 2.Sc4 Sc5 3.Dh5?! Jf6?? 4.Dxf7# 1-0</b> </li>
</ul>
bez v�ech speci�ln�ch hlavi�kov�ch ozna�en� a Scid ji importuje.
</p>

<h3>Pou��v�n� PGN soubor� ve Scidu</h3>
<p>
Jestli�e chcete ve Scidu pou��vat form�t soubor� PGN, ale nechcete ho nejprve
zkonvertovat pou�it�m <a Pgnscid>pgnscid</a>, existuj� zde dv� cesty.
</p>
<p>
Za prv� m��ete importovat partie v souboru do existuj�c� datab�ze pou�it�m
p��kazu menu <menu>N�stroje: Import souboru PGN parti�...</menu>.
</p>
<p>
Alternativou je otev�en� PGN souboru p��mo ve Scidu. Av�ak soubory form�tu PGN
jsou otev�eny pouze ke �ten� a spot�ebov�vaj� v�ce pam�ti ne� porovnateln�
datab�ze Scidu, tak�e to lze doporu�it jen pro relativn� mal� PGN soubory.
</p>

<p><footer>(Aktualizov�no: Scid 2.5, �erven 2001)</footer></p>
}

###################
### Exporting help:

set helpTitle(C,Export) "Export parti�"
set helpText(C,Export) {<h1>Export parti�</h1>
<p>
K exportu aktu�ln� partie nebo v�ech parti� v aktu�ln�m filtru do textov�ho
souboru m��ete pou��t p��kazy v menu <menu>N�stroje</menu>.
</p>
<p>
Textov� soubor je k dispozici ve t�ech form�tech: <a PGN>PGN</a> (portable game
notation), HTML (pro webov� str�nky) a LaTeX (popul�rn� s�zec� syst�m).
</p>
<p>
P�i exportov�n� si m��ete vybrat, zda-li chcete vytvo�it nov� soubor nebo p�idat
partie k existuj�c�mu souboru parti� exportovan�ch Scidem.
</p>

<h3>Diagramy</h3>
<p>
P�i exportu v HTML nebo LaTeX form�tu Scid automaticky p�id� diagram, kdykoliv
se v partii objev� diagramov� <a NAGs>nag</a> ("D") nebo <a Comment>koment��</a>
za��naj�c� znakem "#".
</p>

<h3><name Null>Nulov� tahy v PGN exportu</name></h3>
<p>
Scid umo��uje ukl�dat do partie <a Annotating Null>nulov� (pr�zdn�) tahy</a>,
proto�e mohou b�t u�ite�n� p�i anotaci parti� variantami.
Av�ak  PGN standard pojem nulov� tah neobsahuje. Tak�e exportujete-li partie
Scidu s nulov�mi tahy do PGN souboru, ostatn� PGN �tec� software nebude schopen
nulov� tahy p�e��st.
</p>
<p>
K �e�en� tohoto probl�mu Scid poskytuje p�i exportu parti� do PGN form�tu nav�c
volbu <b>Convert null moves to comments</b>.
Chcete-li vytvo�it PGN soubor, kter� m��e pou��t jin� software, tuto volbu
zapn�te a varianty obsahuj�c� nulov� tah budou konvertov�ny na koment��e. Av�ak
chcete-li vytvo�it PGN soubor, kter� m��e b�t pozd�ji importov�n zp�t do Scidu
se zachovan�mi nulov�mi tahmi, ponechte tuto volbu vypnutou.
</p>

<h3>HTML export</h3>
<p>
Scid m��e exportovat partie do HTML souboru. Aby se zobrazily diagramy, je
pot�ebovat, aby obr�zky diagram� (distribuovan� spole�n� se Scidem v adres��i
"<b>bitmaps/</b>") byly v podadres��i <b>bitmaps/</b> pod adres��em, kde se
nach�z� HTML soubor.
</p>

<h3>LaTeX export</h3>
<p>
Scid m��e exportovat partie do LaTeX souboru.
Partie jsou s�zeny ve dvou sloupc�ch na stranu a tahy jsou v symbolick�
algebraick� notaci.
</p>
<p>
Pro v�ce informac� �t�te str�nku n�pov�dy <a LaTeX>Pou�it� LaTeXu se Scidem</a>.
</p>

<p><footer>(Aktualizov�no: Scid 3.4, �ervenec 2002)</footer></p>
}

###############
### LaTeX help:

set helpTitle(C,LaTeX) "Scid a LaTeX"
set helpText(C,LaTeX) {<h1>Pou�it� LaTeXu se Scidem</h1>
<p>
Scid m��e partie a profily zah�jen� ukl�dat do soubor� v LaTeX form�tu. LaTeX
je roz���en� TeXu, popul�rn�ho s�zec�ho syst�mu.
</p>
<p>
Chcete-li s�zet LaTeX soubory vytvo�en� Scidem, mus�te m�t (samoz�ejm�) LaTeX a
mus�te m�t nainstalovan� bal�k �achov�ch font� "chess12". Tento bal�k font�
obvykle nen� sou��st� standardn� instalace LaTeXu, tak�e klidn� m��ete m�t LaTeX
a nemus�te m�t �achov� fonty.
</p>
<p>
Pro informace o sta�en� a instalaci �achov�ch font� nav�tivte str�nku
<url http://scid.sourceforge.net/latex.html>Pou�it� LaTeXu se Scidem</url>
na <url http://scid.sourceforge.net/>webov� str�nce Scidu</url>.
</p>

<p><footer>(Aktualizov�no: Scid 2.5, �erven 2001)</footer></p>
}

####################
### PGN window help:

set helpTitle(C,PGN) "Okno PGN"
set helpText(C,PGN) {<h1>Okno PGN</h1>
<p>
Okno PGN Scidu zobrazuje obsah aktu�ln� partie ve standardn� PGN reprezentaci. V
z�pisu tah� jsou koment��e {ve slo�en�ch z�vork�ch} a varianty (v z�vork�ch).
</p>

<h3>PGN form�t</h3>
<p>
PGN (Portable Game Notation) je obecn� standard pro p�enos �achov�ch parti� mezi
po��ta�ov�mi programy.
PGN partie se skl�d� ze dvou sekc�. Prvn� je hlavi�ka, kter� obsahuje speci�ln�
ozna�en� jako nap�.
<b>[White "Kasparov, Gary"]</b>
a
<b>[Result "1/2-1/2"]</b>.
</p>
<p>
Druh� sekce obsahuje skute�n� tahy partie ve standardn� algebraick� notaci
(standard algebraic notation, SAN) spole�n� se v�emi variantami,
<a NAGs>anota�n�mi symboly</a> a <a Comment>koment��i</a>.
</p>

<h3>Akce v okn� PGN</h3>
<p>
Okno PGN m��ete pou��t k navigaci v partii: kliknut�m lev�m tla��tkem my�i na
tah sko��te do pozice po tomto tahu. Kliknut�m lev�m tla��tkem my�i na koment��
spust�te jeho editaci.
Naviga�n� kl�vesy (tj. �ipky) (a kl�vesy <b>v</b> a <b>z</b> pro skok do a z
varianty) umo��uj� navigaci v partii jako v hlavn�m okn�.
</p>

<h3>Volby zobrazen� PGN</h3>
<p>
Menu okna PGN obsahuj� volby, kter� ovliv�uj� vzhled okna PGN. Scid m��e
zobrazit partii barevn� nebo jako oby�ejn� text -- viz menu
<menu>Zobrazit</menu> v okn� PGN.
Barevn� zobrazen� se snadn�ji �te a dovoluje v�m v�b�r tah� a koment��� pou�it�m
my�i, ale je mnohem pomalej�� na aktualizaci. Pro velmi dlouh� partie budete
mo�n� cht�t zvolit zobrazen� jako oby�ejn� text.
</p>
<p>
Pro v�t�� �itelnost m��ete rovn� zm�nit form�t koment��� a
variant volbou jejich odsazov�n� na nov� ��dek.
</p>
<p>
Volby zobrazen� PGN a velikost okna PGN se ulo�� do souboru voleb v�dy, kdy�
zad�te p��kaz <b>Ulo�it volby</b> z menu <menu>Volby</menu> v hlavn�m okn�.
</p>

<p><footer>(Aktualizov�no: Scid 3.1, Prosinec 2001)</footer></p>
}


#######################
### Piece Tracker help:

set helpTitle(C,PTracker) "Stopa� figur"
set helpText(C,PTracker) {<h1>Okno stopa�e figur</h1>
<p>
<term>Stopa� figur</term> je n�stroj, kter� zaznamen�v� pohyb jednotliv� figury
ve v�ech parti�ch v aktu�ln�m filtru a generuje "stopu", kter� zobrazuje, jak
�asto bylo ka�d� pole figurou nav�t�veno.
</p>
<p>
Chcete-li pou��t stopa�e figur, nejprve se ujist�te, �e filtr obsahuje ty
partie, o kter� m�te z�jem, jako nap�. partie, ve kter�ch se vyskytla ur�it�
pozice zah�jen�, nebo v�echny partie jist�ho hr��e b�l�mi figurami. Potom
vyberte figuru, kterou chcete stopovat a nastavte dal�� stopovac� volby; jsou
vysv�tleny n�e. Pak stiskn�te tla��tko <b>Aktualizovat</b>.
</p>
<p>
Informace o pohybu stopovan� figury jsou zobrazeny dv�ma zp�soby: grafickou
"stopou" a textov�m seznamem s jedn�m ��dkem �daj� pro jednotliv� pole.
</p>

<h3>V�b�r stopovan� figury</h3>
<p>
�achov� figury jsou zobrazeny pod grafem stopy na sv�ch po��te�n�m pozic�ch.
Jednotlivou figuru (jako nap�. b�l�ho jezdce b1 nebo �ern�ho p�ce d7) lze
vybrat lev�m tla��tkem my�i a v�echny figury stejn�ho typu a barvy (jako nap�.
v�echny b�l� p�ce nebo ob� �ern� v�e) lze vybrat prav�m tla��tkem my�i.
</p>

<h3>Ostatn� volby stopa�e figur</h3>
<p>
Rozsah tah� ur�uje, odkud m� za��t a kde m� skon�it stopov�n� v ka�d� partii.
Implicitn� rozsah 1-20 (znamenaj�c� konec stopov�n� po 20. tahu �ern�ho) je
vhodn� pro studium motiv� zah�jen�, ale (nap�.) rozsah jako 15-35 bude lep�� pro
sledov�n� trend� st�edn� hry.
</p>
<p>
Stopa�em lze generovat dva typy statistik:
<ul>
<li> <b>% games with move to square</b>: zobrazuje pod�l parti� ve filtru, kter�
 obsahuj�
     tah stopovan� figury na ka�d� pole. To je implicitn� a v�t�inou
     nejvhodn�j�� volba.
<li> <b>% time in each square</b>: zobrazuje pod�l �asu, kter� stopovan�
     figura str�vila na ka�d�m poli.
</ul>
</p>

<h3>Rady</h3>
<p>
Existuj� (aspo�) t�i dobr� pou�it� pro stopa�e figur: p��prava zah�jen�, motivy
st�edn� hry a p��prava na hr��e.
</p>
<p>
Pro p��pravu zah�jen� pou��vejte stopa�e figur spole�n� s otev�en�m
<a Tree>stromem</a>. Stopov�n�m figur m��ete zjistit trendy v aktu�ln�m zah�jen�
jako nap�. obvykl� postupy p�c�, p�edsunut� jezdcov� posty a kam se nej�ast�ji
rozmis�uj� st�elci. M��ete shledat u�ite�n�m nastavit rozsah tah� tak, aby
za��nal aktu�ln�m tahem partie, tak�e tahy k dosa�en� aktu�ln� pozice nebudou ve
statistice zahrnuty.
</p>
<p>
Pro motivy st�edn� hry m��e b�t stopa� figur u�ite�n� tehdy, kdy� filtr byl
nastaven tak, �e obsahuje ur�it� rozsah ECO (pou�it�m
<a Searches Header>Vyhled�v�n� podle hlavi�ky</a>) nebo i vzor jako nap�. b�l�
izolovan� d�msk� p�ec (White IQP) (pou�it�m
<a Searches Material>Vyhled�v�n� podle materi�lu/vzoru</a>). Nastavte n�jak
vhodn� (nap�. 20-40) rozsah tah� a ze "stopy" figur m��ete vid�t nap�. postupy
p�c� v pozdn� st�edn� h�e nebo ran� koncovce.
</p>
<p>
Pro p��pravu na hr��e pou�ijte <a Searches Header>Vyhled�v�n� podle hlavi�ky</a>
nebo <a PInfo>Okno informac� o hr��i</a>, abyste na�li v�echny partie jist�ho
hr��e jednou barvou. Pak m��e b�t stopa� figur u�ite�n� k vyp�tr�n� nap�. toho,
jak pravd�podobn� soupe� fianchetuje st�elce, ro�uje nadlouho nebo stav� p�cov�
kl�n d5 nebo e5.
</p>

<p><footer>(Aktualizov�no: Scid 3.3, Duben 2002)</footer></p>
}


###########################
### Repertoire editor help:

set helpTitle(C,Repertoire) "Editor reperto�ru"
set helpText(C,Repertoire) {<h1>Okno editoru reperto�ru</h1>
<p>
Editor reperto�ru v�m umo��uje vytvo�it, prohl�et a editovat
<term>reperto�rov�</term> soubory. Reperto�rov� soubor (.sor) je seznam pozic
zah�jen�, kter�ch chcete dos�hnout nebo kter�m se chcete vyhnout, a lze ho
pou��t ke spr�v� va�ich preferovan�ch pozic zah�jen� a tak� k vyhled�v�n� v
datab�z�ch ve Scidu.
</p>

<h3>Reperto�rov� skupiny a varianty</h3>
<p>
Reperto�r obsahuje dva typy element�: <term>skupiny</term> a
<term>varianty</term>. Skupiny vlastn� nejsou ��st� va�eho reperto�ru; pou��vaj�
se jen k jeho uspo��d�n� stejn� jako adres��e k uspo��d�n� soubor� na disku
po��ta�e.
</p>
<p>
Varianty v reperto�ru jsou dvou typ�: <term>zahrnut�</term> varianty, kter�
reprezentuj� pozice zah�jen�, kter� v�s zaj�maj� a kter�ch chcete dos�hnout, a
<term>vylou�en�</term> varianty, kter� nem�te z�jem hr�t a chcete se jim
vyhnout.
Nap�. hrajete-li �ern�ma p�ijat� d�msk� gambit (1.d4 d5 2.c4 dxc4) a po 3.e4
hrajete v�echny tahy krom� 3...Jf6, budete m�t 1.d4 d5 2.c4 dxc4 3.e4 jako
zahrnutou variantu a 1.d4 d5 2.c4 dxc4 3.e4 Nf6 jako vylou�enou variantu.
</p>

<h3>Koment��e a pozn�mky</h3>
<p>
Ka�d� skupina nebo varianta m��e m�t k sob� p�ipojen� koment��. Existuj� dva
typy: kr�tk� (jedno��dkov�) koment��e jsou zobrazeny (�erven�) v hierarchii
reperto�ru vedle tah� skupiny nebo varianty, zat�mco dlouh� (v�ce��dkov�)
koment�� se zobraz�, jen kdy� je skupina nebo varianta vybr�na.
</p>

<h3>Pou�it� okna editoru reperto�ru</h3>
<p>
<b>Lev�</b> strana okna zobrazuje hierarchii reperto�ru. Kliknut�m na ikonu
slo�ky m��ete rozbalit nebo sbalit skupinu a kliknut�m na tahy skupiny nebo
varianty ji vybrat a prohl�dnout si jej� koment��.
Zahrnut� varianty jsou ozna�eny modrou za�krt�vac� ikonou a vylou�en� varianty
maj� �erven� k��ek.
</p>
<p>
Jestli�e m� varianta nebo skupina kr�tk� koment��, je zobrazen za tahmi.
Jestli�e m� dlouh� koment��, je indikov�n <b><red>**</red></b> za tahmi. Skupiny
maj� za sv�mi tahmi v z�vork�ch ��slo, kter� ur�uje po�et variant (zahrnut�ch
nebo vylou�en�ch), kter� skupiny obsahuj�.
</p>
<p>
Kliknut� prav�m tla��tkem my�i na skupinu nebo variantu vyvol� pro ni menu
funkc�, jako nap�. jej� v�maz nebo zm�nu jej�ho stavu (zahrnut�/vylou�en�).
</p>
<p>
<b>Prav�</b> strana okna obsahuje t�i r�mce. Prvn� r�mec je seznam tah� aktu�ln�
vybran� varianty nebo skupiny. Kliknut�m lev�ho tla��tka my�i na n�j m��ete
vlo�it tyto tahy do okna <a Import>importu</a>, co� je u�ite�n� k nastaven�
aktu�ln� partie tak, aby za��nala touto variantou reperto�ru.
Druh� r�mec obsahuje kr�tk� koment�� k variant� nebo skupin� a t�et� r�mec
obsahuje jej� dlouh� koment��.
</p>

<h3>P�id�v�n� skupin a variant do reperto�ru</h3>
<p>
Chcete-li do okna p�idat variantu nebo skupinu, ud�lejte na �achovnici v hlavn�m
okn� jej� tahy a pak pou�it�m menu <menu>Editace</menu> v editoru reperto�ru ji
p�idejte jako skupinu, zahrnutou variantu nebo vylou�enou variantu.
</p>
<p>
Chcete-li smazat skupinu nebo variantu, klikn�te na ni prav�m tla��tkem my�i a z
menu, kter� se objev�, vyberte po�adovan� p��kaz.
</p>

<h3><name Search>Vyhled�v�n� v datab�z�ch pou�it�m reperto�rov�ch
 soubor�</name></h3>
<p>
Menu <menu>Hledat</menu> v editoru reperto�ru v�m umo��uje vyhled�vat v aktu�ln�
datab�zi pou�it�m reperto�ru. V ka�d� partii se budou vyhled�vat pozice z
reperto�ru a partie bude vyhovovat, jen kdy� nalezen� <i>nejhlub��</i>
reperto�rov� pozice je v <i>zahrnut�</i> variant�.
</p>
<p>
M��ete si zvolit mezi vyhled�v�n�m pou�it�m cel�ho reperto�ru nebo pouze
pou�it�m zobrazen�ch variant. Vyhled�v�n� pou�it�m pouze zobrazen�ch variant je
u�ite�n�, kdy� chcete pou��t jen ��st reperto�ru. Nap�. reperto�r m��e m�t na
nejvy��� �rovni dv� hlavn� skupiny, jednu pro 1.e4 a druhou pro 1.d4. Jestli�e
v�s zaj�maj� jen varianty po 1.e4, jednodu�e sbalte v�tev 1.d4 a potom
vyhled�vejte pouze pou�it�m zobrazen�ch variant.
</p>

<h3>Rady nav�c</h3>
<p>
Reperto�rov� soubor je skv�l� pro nalezen� nov�ch parti� pro v� syst�m
zah�jen�. Nap�. kdykoliv z�sk�te nov� PGN soubor pro p�ipojen� k va�� hlavn�
datab�zi (jako nap�. vynikaj�c� t�denn� PGN soubor z
<url http://www.chesscenter.com/twic/>The Week In Chess</url>),
otev�ete tento PGN soubor ve Scidu a prove�te reperto�rov� vyhled�v�n�.
Prohl�dnut�m filtrovan�ch parti� pak zjist�te v�echny nov� partie, kter� jsou ve
va�em reperto�ru.
</p>
<p>
Mo�n� budete cht�t m�t dva reperto�rov� soubory: jeden pro �ern� a
druh� pro b�l�, tak�e budete moct vyhled�vat pou�it�m ka�d�ho souboru zvlṻ.
</p>
<p>
Reperto�rov� soubor lze otev��t z p��kazov� ��dky, nap�.: <br>
<b>scid mybase white.sor</b>
</p>
<p>
Reperto�rov� soubor(.sor) m��ete editovat v libovoln�m textov�m editoru, bu�te
v�ak opatrn�, abyste zachovali jeho form�t nebo jinak ho nebude mo�n� nat�hnout
nebo pou��t k vyhled�v�n�.
</p>

<p><footer>(Aktualizov�no: Scid 2.6, Srpen 2001)</footer></p>
}

#####################
### Tree window help:

set helpTitle(C,Tree) "Stromov� okno"
set helpText(C,Tree) {<h1>Stromov� okno</h1>
<p>
<term>Stromov�</term> okno zobrazuje informace o v�ech taz�ch zahran�ch v
aktu�ln� pozici v parti�ch datab�ze. Ve stromov�m m�du je okno stromu
aktualizov�no automaticky, kdykoliv se v hlavn�m okn� zm�n� pozice na
�achovnici. Pro velk� datab�ze to m��e b�t pomal�.
</p>
<p>
V�imn�te si, �e kdykoliv je stromov� okno aktualizov�no,
<a Searches Filter>filtr</a> je znovu nastaven tak, �e zahrnuje jen partie,
kter� obsahuj� aktu�ln� pozici.
</p>
<p>
Kliknut� lev�m tla��tkem my�i na tah ve stromov�m okn� p�id� tento tah do
partie.
</p>

<h3>Obsah stromov�ho okna</h3>
<p>
Stromov� okno zobrazuje <a ECO>ECO k�d</a> (je-li n�jak�), frekvenci (jednak
 jako po�et
parti�, jednak procento) a sk�re ka�d�ho tahu.
<term>Sk�re</term> je v�dy po��t�no z perspektivy <b>b�l�ho</b>, tak�e 100%
znamen� sam� v�hry b�l�ho a 0% znamen� sam� v�hry �ern�ho.
</p>
<p>
Tahy v okn� stromu mohou b�t �azeny podle tahu (abecedn�), ECO k�du, frekvence
nebo sk�re. Pou�it�m menu <menu>�adit</menu> m��ete metodu �azen� zm�nit.
</p>

<h3><name Best>Okno nejlep��ch parti�</name></h3>
<p>
Stromov� okno m� tla��tko a v souborov�m menu p��kaz pro otev�en� okna
<term>nejlep��ch parti�</term>, kter� zobrazuje seznam nejcenn�j��ch parti� v
aktu�ln� zobrazen� v�tvi stromu.
Partie jsou �azeny podle pr�m�rn�ho ratingu a tento seznam m��ete omezit tak,
aby zobrazoval jen partie s ur�it�m v�sledkem.
</p>

<h3><name Graph>Okno grafu stromu</name></h3>
<p>
Tla��tka stromov�ho okna zahrnuj� tla��tko ozna�en� <term>Graf</term>, kter�
vyvol�v� grafick� zobrazen� relativn� �sp�nosti ka�d�ho tahu hran�ho v aktu�ln�
pozici.
Zobrazeny jsou v�echny tahy, kter� se hr�ly nejm�n� v 1% parti� a
nejm�n� 5 kr�t.
Procentn� sk�re jsou v�dy z perspektivy b�l�ho, i kdy� je na
tahu �ern�.
</p>
<p>
V grafu stromu je nakreslena �erven� ��ra zobrazuj�c� pr�m�rnou �sp�nost ze
v�ech parti� obsahuj�c� aktu�ln� pozici a oblast mezi 50 a 55% (kde le��
o�ek�van� �sp�nost standardn�ch zah�jen�) je kv�li snadn�j��mu porovn�n� tah�
zobrazena mod�e. V�imn�te si, �e na mistrovsk� �rovni b�l� oby�ejn� dosahuj�
�sp�nosti okolo 55%.
</p>

<h3><name Lock>Zamknut� okna stromu</name></h3>
<p>
Tla��tko <term>Zamknout</term> ve stromov�m okn� m��e b�t pou�ito k zamknut�
stromu k aktu�ln� datab�zi. To znamen�, �e strom bude nad�le pou��vat tuto
datab�zi, i kdy� se p�epnete do jin� otev�en� datab�ze. To je u�ite�n�, kdy�
chcete pou��t velkou datab�zi jako referen�n� p�i p�ehr�v�n� partie z jin�
datab�ze: jednodu�e otev�ete strom pro referen�n� datab�zi, zamkn�te ho a potom
se p�epn�te do druh� datab�ze.
</p>

<h3><name Training>Tr�nink</name></h3>
<p>
Kdy� aktivujete tla��tko <term>Tr�nink</term>, v�dy, kdy� zahrajete sv�j
tah, Scid n�hodn� provede tah.
Tah, kter� Scid zvol�, z�vis� na datab�zov� statistice tak, �e tah zahran� v 80%
parti� datab�ze bude Scidem zvolen s 80% pravd�podobnost�.
Dobr�m zp�sobem, jak si otestovat znalosti sv�ho reperto�ru zah�jen�, je zapnout
tuto funkci, potom skr�t (nebo minimalizovat) stromov� okno a hr�t zah�jen�
proti velk� datab�zi.
</p>

<h3>Pou�it� stromu s otev�en�mi EPD soubory</h3>
<p>
Pro ka�d� otev�en� <a EPD>EPD soubor</a> stromov� okno obsahuje jeden sloupec
 nav�c, kter�
zobrazuje kr�tk� (p�tiznakov�) souhrn obsahu EPD souboru pro ka�dou pozici,
dosa�enou tahy v seznamu.
</p>
<p>
Souhrn m��e b�t hodnocen�, k�d zah�jen� nebo navr�en� tah; bude to obsah prvn�ho
EPD pole nalezen�ho v n�sleduj�c�m seznamu: <b>ce, eco, nic, pv, pm, bm, id</b>
nebo jen prvn� EPD pole, jestli�e v�echny z uveden�ch chyb�.
</p>
<p>
Pro popis EPD pol� si p�e�t�te str�nku n�pov�dy o <a EPD>EPD souborech</a>.
V�imn�te si, �e jestli�e je souhrn z <b>ce</b> pole, je zobrazen z d�vodu lep�� 
�itelnosti jako hodnocen� v p�c�ch z perspektivy b�l�ho (rad�ji ne� sk�re 
v setin�ch p�c� z perspektivy strany, kter� je na tahu, jako je jeho vlastn� 
form�t ulo�en� v EPD souboru).
</p>

<h3>Pou��v�n� cache pro rychlej�� v�sledky</h3>
<p>
Scid pou��v� cache pro stromov� vyhled�vac� v�sledky pro pozice, kter�m odpov�d�
nejv�ce parti�. Jestli�e se ve stromov�m m�du posunete v partii o tah dop�edu a
zp�t, aktualizace okna stromu se provede t�m�� okam�it�, jestli�e vyhled�van�
pozice je v cache.
</p>
<p>
Okno stromu obsahuje v souborov�m menu p��kaz <term>Ulo�it cache soubor</term>.
Kdy� ho zad�te, aktu�ln� obsah stromov� cache v pam�ti se zap�e do souboru (s
p��ponou <b>.stc</b>) a dojde tak ke zrychlen� budouc�ho pou�it� t�to datab�ze
ve stromov�m m�du.
</p>
<p>
P��kaz <term>Naplnit cache soubor</term> v souborov�m menu okna
stromu napln� cache soubor �daji pro mnoho pozic zah�jen�.
Provede se stromov� vyhled�v�n� pro asi 100 nejb�n�j��ch pozic zah�jen� a pot�
se ulo�� cache soubor.
</p>
<p>
Uv�domte si, �e stromov� cache (.stc) soubor je cel� nadbyte�n�; m��ete
ho smazat bez toho, aby jste ovlivnili danou datab�zi, a ve skute�nosti je
Scidem smaz�n v�dy, kdy� se objev� operace, po kter� by z�stal neaktu�ln� --
nap�. p�id�n� nebo nahrazen� partie nebo t��d�n� datab�ze.
</p>

<p><footer>(Aktualizov�no: Scid 3.0, Listopad 2001)</footer></p>
}



####################
### Compaction help:

set helpTitle(C,Compact) "Zhutn�n� datab�ze"
set helpText(C,Compact) {<h1>Zhutn�n� datab�ze</h1>
<p>
<term>Zhutn�n�</term> datab�ze je specifick� typ <a Maintenance>�dr�by</a>,
kter�m se datab�ze uchov�v� co mo�n� nejmen�� a nejv�konn�j��.
Zhutn�n� datab�ze znamen� odstran�n� v�echno nevyu�it�ho prostoru v jej�ch
souborech.
Existuj� dva druhy zhutn�n�: jmenn�ho souboru a partiov�ho
souboru.
</p>

<h3>Zhutn�n� jmenn�ho souboru</h3>
<p>
�asem mo�n� zjist�te, �e datab�ze za��n� obsahovat mno�stv� jmen hr���, turnaj�,
m�st a kol, kter� u� nejsou v ��dn� partii pou�ita. To se �asto stane po
kontrole pravopisu jmen. Nepou�it� jm�na v jmenn�m souboru zbyte�n� zab�raj�
m�sto a mohou zpomalit vyhled�v�n� podle jmen.
Zhutn�n� jmenn�ho souboru odstran� v�echny jm�na, kter� nejsou pou�ita v
��dn� partii.
</p>

<h3>Zhutn�n� partiov�ho souboru</h3>
<p>
Kdykoliv je partie nahrazena nebo smaz�na, z�stane v partiov�m souboru
(nejv�t�� ze t�� soubor� tvo��c� datab�zi Scidu) zbyte�n� voln� m�sto.
Zhutn�n� partiov�ho souboru odstran� v�echno zbyte�n� voln� m�sto, nesmazan�
partie ponech� v datab�zi. Uv�domte si, �e tato operace je nevratn�: po
zhutn�n� jsou smazan� partie nav�dy pry�!
</p>
<p>
Zhutn�n� partiov�ho souboru se doporu�uje tak� po <a Sorting>t��d�n�</a>
datab�ze, aby se udr�el stav partiov�ho souboru konzistentn� se set��d�n�m
indexov�m souborem.
</p>

<p><footer>(Aktualizov�no: Scid 2.5, �erven 2001)</footer></p>
}


####################################
### Database maintenance tools help:

set helpTitle(C,Maintenance) "�dr�ba datab�ze"
set helpText(C,Maintenance) {<h1>�dr�ba datab�ze</h1>
<p>
Scid poskytuje mno�stv� n�stroj� pro �dr�bu datab�ze, jsou dostupn� z menu Scidu
<a Menus File>Soubor</a>. <a Compact>Zhutn�n�</a> datab�ze a
<a Sorting>t��d�c�</a> funkce jsou vysv�tleny na samostatn�ch str�nk�ch
n�pov�dy.
</p>

<h3>Okno �dr�by</h3>
<p>
V�t�inu �dr�by datab�ze ve form�tu Scidu lze prov�st z okna �dr�by, kter� m��ete
otev��t z menu <menu>Soubor: �dr�ba</menu> nebo z menu <menu>Okna</menu> nebo
pou�it�m kl�vesov� zkratky <b>Ctrl+M</b>.
</p>
<p>
Toto okno m��ete pou��t k �dr�b� <a Flags>p��znak� parti�</a>, kontrole
pravopisu jmen, <a Compact>zhutn�n�</a> nebo <a Sorting>t��d�n�</a>
datab�ze. V�imn�te si, �e v�echny operace, kter� nejsou pro aktu�ln� datab�zi
dostupn� (nap�. proto�e je jen ke �ten� nebo je PGN soubor), budou zobrazeny
�edou barvou.
</p>

<h3><name Twins>Maz�n� zdvojen�ch parti�</name></h3>
<p>
Menu <menu>Soubor: �dr�ba</menu> obsahuje p��kaz
<menu>Vymaz�n� zdvojen�ch parti�...</menu> pro detekci dal��ch kopi� (dvojn�k�)
parti� v datab�zi.
Tento p��kaz nalezne v�echny p�ry parti�, kter� jsou dvojn�ky, a pro ka�d� p�r
nastav� p��znak krat�� partie na smazan� a p��znak del�� partie ponech� na
nesmazan�.
Dv� partie jsou pokl�d�ny za dvojn�ky, jestli�e se jejich hr��i (a libovoln�
jin� speci�ln� ozna�en�, kter� m��ete voliteln� specifikovat) p�esn� shoduj�.
</p>
<p>
Jestli�e specifikujete volbu "tyt� tahy", ka�d� p�r parti� mus� m�t stejn�
aktu�ln� tahy a� do d�lky krat�� partie (nebo do 60. tahu kter�koliv), aby byli
partie pokl�d�ny za dvojn�ky.
</p>
<p>
Jestli�e jste provedli maz�n� dvojn�k�, je dobrou my�lenkou ov��it si, jestli�e
ka�d� smazan� partie je opravdu kopi� druh� partie.
To m��ete jednodu�e prov�st, jestli�e v dialogov�m okn� maz�n� zdvojen�ch parti�
vyberete volbu "<b>Nastavit filtr na v�echny vymazan� zdvojen� partie</b>".
Filtr budu potom obsahovat v�echny smazan� partie.
M��ete si je prohl�dnout (pou�it�m kl�ves <b>p</b> a <b>n</b>) pou�it�m okna
<term>kontroly zdvojen�ch parti�</term> (dostupn� z menu �dr�by nebo pou�it�m
kl�vesov� zkratky <b>Ctrl+Shift+T</b>) a ov��it si, �e partie jsou smazan�,
proto�e jsou skute�n� dvojn�ky jin� partie.
</p>

<h3><name Editing>Editace jmen hr���, turnaj�, m�st a kol</name></h3>
<p>
Ve va�� datab�zi m��ete naj�t �patn� napsan� jm�na a chcete je opravit.
To m��ete prov�st ve Scidu pou�it�m okna <term>editoru jmen</term> (kl�vesov�
zkratka: <b>Control+Shift+N</b>), dostupn�ho z podmenu
<menu>Soubor: �dr�ba</menu>.
</p>
<p>
Ka�d� jedine�n� jm�no je ulo�eno v jmenn�m souboru jen jednou,
tak�e jeho zm�na vlastn� zm�n� v�echny jeho v�skyty.
</p>

<h3><name Spellcheck>Kontrola pravopisu jmen</name></h3>
<p>
Scid se distribuuje spole�n� se souborem <term>pro kontrolu pravopisu</term>
pojmenovan�m <b>spelling.ssp</b>, pou��van�m pro opravu jmen hr���, turnaj�,
m�st a kol.
Scid se pokou�� nahr�t soubor pro kontrolu pravopisu p�i ka�d�m startu; jestli�e
se nenat�hne, m��ete ho nat�hnout z menu <menu>Volby</menu>.
</p>
<p>
Kdy� u� je soubor pro kontrolu pravopisu nata�en, m��ete ho pou��t pro datab�ze
ve form�tu Scidu prost�ednictv�m p��kaz� pro kontrolu pravopisu v menu
<menu>Soubor: �dr�ba</menu> nebo z okna �dr�by.
</p>
<p>
Kdy� kontrolujete pravopis jmen datab�ze, Scid produkuje seznam korekc�, kter�
m��ete p�ed jejich vlastn�m proveden�m editovat, tak�e m��ete odstranit v�echny
korekce, kter� prov�st nechcete.
</p>
<p>
Kontrola pravopisu je zvlṻ u�ite�n� pro standardizaci datab�ze, aby v�echny
p��klady jednotliv�ho jm�na m�li stejn� tvar.
Nap�. se standardn�m souborem pro kontrolu pravopisu by byla jm�na "Kramnik,V.",
"Vladimir Kramnik", and "V. Kramnik" opravena na "Kramnik, Vladimir".
</p>
<p>
Soubor pro kontrolu pravopisu m� jedno pou�it� nav�c: kdy� je nata�en, jeho
�daje o hr���ch jsou pou�ity k roz���en� okna <a PInfo>informac� o hr��i</a> a
 okna
<a Crosstable>turnajov� tabulky</a>: pro ka�d�ho hr��e obsa�en�ho v souboru pro
kontrolu pravopisu uvid�te jeho mistrovsk� titul FIDE (<b>gm</b> = mezin�rodn�
velmistr, <b>im</b> = mezin�rodn� mistr atd.) a jeho zemi. Soubor
<b>spelling.ssp</b>, distribuovan� spole�n� se Scidem, obsahuje p�es 6500
siln�ch hr��� minulosti a p��tomnosti.
</p>

<h3><name Ratings>P�id�n� Elo rating� do parti�</name></h3>
<p>
Tla��tko "P�idat Elo ratingy..." v okn� �dr�by zp�sob�, �e Scid vyhled� v
aktu�ln� datab�zi partie, v kter�ch hr�� nem� rating, ale soubor pro kontrolu
pravopisu jeho rating k datu partie obsahuje. Scid v�echny takov� ratingy
automaticky p�id�. To je velmi u�ite�n� pro datab�ze mistrovsk�ch parti�, kter�
maj� m�lo rating�.
</p>
<p>
Soubor pro kontrolu pravopisu "spelling.ssp", dod�van� spole�n� se Scidem,
neobsahuje informace o Elo rating�ch pot�ebn�ch pro tuto funkci, ale jeho v�t��
verze s n�zvem "ratings.ssp" je dostupn� na <a Author>webov� str�nce Scidu</a>.
</p>

<h3><name Cleaner>�i�t�n� datab�ze</name></h3>
<p>
<term>�i�t�n� datab�ze</term> (dostupn� z okna �dr�by) je n�stroj pro vykon�v�n�
v�ce operac� �dr�by datab�ze nar�z. M��ete si vybrat, kter� operace chcete
prov�st, a Scid je s aktu�ln� datab�z� provede bez nutnosti u�ivatelsk�ho
z�sahu. To je zvlṻ u�ite�n� pro �dr�bu velk�ch datab�z�.
</p>

<h3>V�b�r automaticky otev�ran� partie</h3>
<p>
<term>Automaticky otev�ran�</term> partie datab�ze je partie, kter� se
automaticky nat�hne p�i ka�d�m otev�en� datab�ze. Chcete-li zm�nit automaticky
otev�ranou partii datab�ze, pou�ijte tla��tko  "Automaticky otev�rat partii
��slo...". Jestli�e chcete, aby se nat�hla v�dy posledn� partie datab�ze (bez
ohledu na skute�n� po�et parti� v datab�zi), nastavte ji na velmi vysok� ��slo
nap�. 9999999.
</p>

<p><footer>(Aktualizov�no: Scid 3.1, Prosinec 2001)</footer></p>
}

#################
### Sorting help:

set helpTitle(C,Sorting) "T��d�n� datab�ze"
set helpText(C,Sorting) {<h1>T��d�n� datab�ze</h1>
<p>
<term>T��d�c�</term> funkce t��d� v�echny partie v datab�zi. M��ete si vybrat
mno�stv� t��d�c�ch krit�ri�.
Kdy� jsou dv� partie rovnocenn� podle prvn�ho krit�ria, jsou set��d�ny podle
druh�ho krit�ria atd. </p>

<h3>T��d�c� krit�ria</h3>
<p>
Dostupn� t��d�c� krit�ria jsou:
</p>
<ul>
<li> Datum (nejstar�� partie prvn�)
<li> Rok (stejn� jako datum, ale pou�ije se jen rok)
<li> Jm�no turnaje
<li> Jm�no m�sta
<li> Zem� (posledn� 3 p�smena jm�na m�sta)
<li> Jm�no kola
<li> Jm�no b�l�ho
<li> Rating (pr�m�r ratingu b�l�ho a �ern�ho, nejvy��� prvn�)
<li> Jm�no �ern�ho
<li> V�sledek (v�hry b�l�ho, rem�zy a pak v�hry �ern�ho)
<li> D�lka (po�et kompletn�ch tah� v partii)
<li> ECO (<a ECO>k�d Encyklopedie �achov�ch zah�jen�</a>)
</ul>

<h3>V�sledky t��d�n�</h3>
<p>
Kdy� t��d�te datab�zi Scidu, kter� nen� jen ke �ten�, v�sledky t��d�n� jsou
ulo�eny, tak�e po�ad� parti� v datab�zi je trvale zm�n�no. Jestli�e chcete, aby
set��d�n� bylo jen do�asn�, pou�it�m p��kazu menu <b>Soubor: Pouze pro �ten�</b>
nastavte nejprve datab�zi jen ke �ten�.
</p>
<p>
Kdy� t��d�te datab�zi, kter� je jen ke �ten� nebo je skute�n� PGN soubor,
v�sledky t��d�n� nemohou b�t ulo�eny, tak�e po zav�en� souboru bude set��d�n�
po�ad� parti� ztraceno.
</p>
<p>
V�imn�te si, �e t��d�n� datab�ze znovu nastav�
<a Searches Filter>vyhled�vac� filtr</a> tak, �e obsahuje v�echny partie.
</p>

<h3>D�le�it� pozn�mka k t��d�n� datab�z�:</h3>
<p>
P�i t��d�n� datab�ze je zm�n�n indexov� soubor, ale partiov� soubor nikoliv. To
znamen�, �e t��d�n� datab�ze zanech� z�znamy v partiov�m souboru pom�chan�
vzhledem k indexov�mu souboru. To m��e v�znamn� <b>zpomalit</b> <a
 Tree>stromov�</a>
vyhled�v�n�, <a Searches>vyhled�v�n�</a> podle pozice a podle materi�lu/vzoru,
 tak�e abyste
udr�eli dobr� vyhled�vac� v�sledky, m�li byste po set��d�n� datab�ze
reorganizovat partiov� soubor jeho <a Compact>zhutn�n�m</a>.
</p>

<p><footer>(Aktualizov�no: Scid 2.5, �erven 2001)</footer></p>
}

###############
### Flags help:

set helpTitle(C,Flags) "P��znaky partie"
set helpText(C,Flags) {<h1>P��znaky partie</h1>
<p>
<term>P��znak</term> je indik�tor n�jak�ch �achov�ch charakteristik, kter� m��e
b�t zapnut� nebo vypnut� pro ka�dou partii v datab�zi.
Ve Scidu existuje 13 u�ivatel nastaviteln�ch p��znak�, kter� m��ete p��mo
nastavit pro ka�dou partii. Z nich jen mazac� p��znak m� speci�ln� v�znam:
partie se zapnut�m mazac�m p��znakem jsou ozna�eny k v�mazu a p�i
<a Compact>zhutn�n�</a> datab�ze budou odstran�ny.
</p>
<p>
12 ostatn�ch u�ivatelem nastaviteln�ch p��znak� a jejich symboly jsou:
</p>

<ul>
<li>Zah�jen� b�l�ho (W)</li>
<li>Zah�jen� �ern�ho (B)</li>
<li>St�edn� hra (M)</li>
<li>Koncovka (E)</li>
<li>Novinka (N)</li>
<li>P�cov� struktura (P)</li>
<li>Taktika (T)</li>
<li>Hra na d�msk�m k��dle (Q)</li>
<li>Hra na kr�lovsk� k��dle (K)</li>
<li>Velmi siln� tah (!)</li>
<li>Hrub� chyba (?)</li>
<li>U�ivatel (U)</li>
</ul>

<p>
P��znak m��e b�t nastaven pro aktu�ln� partii, pro v�echny partie filtru nebo
pro v�echny partie datab�ze pou�it�m okna <a Maintenance>�dr�by</a>.
</p>
<p>
M��ete pou��t <a Searches Header>vyhled�v�n� podle hlavi�ky</a> pro nalezen�
v�ech parti� v datab�zi, kter� maj� konkr�tn� p��znak zapnut� nebo vypnut�, nebo
pou��t p��znaky jako ��st komplexn�j��ch vyhled�v�n�.
</p>
<p>
Proto�e v�echny u�ivatelem nastaviteln� p��znaky (krom� mazac�ho p��znaku)
nemaj� pro Scid ��dn� v�znam, m��ete je pou��vat pro jak�koliv ��el, vhodn� pro
va�e pot�eby. Nap�. m��ete pou��t p��znak hry na kr�lovsk�m k��dle (K) pro
p�cov� �toky na kr�lovsk� k��dle nebo pro �tok na kr�lovsk�m k��dle t�k�mi
figurami nebo dokonce pro koncovky se v�emi p�ci na kr�lovsk�m k��dle.
</p>

<p><footer>(Aktualizov�no: Scid 3.0, Listopad 2001)</footer></p>
}

#########################
### Analysis window help:

set helpTitle(C,Analysis) "Analytick� okno"
set helpText(C,Analysis) {<h1>Analytick� okno</h1>
<p>
Analytick� okno ve Scidu zobrazuje anal�zu �achov�ho programu
(ozna�ovan�ho jako <term>motor</term>) sou�asn� pozice na �achovnici. P�i ka�d�
zm�n� na �achovnici pos�l� Scid motoru novou pozici a zobrazuje jeho hodnocen�
t�to pozice.
</p>
<p>
Sk�re zobrazen� v tomto analytick�m okn� je v�dy z perspektivy
b�l�ho, tak�e negativn� sk�re indikuje lep�� pozici �ern�ho.
Spodn� r�mec v tomto okn� (s posuvn�kem) zobrazuje historii hodnocen� t�to
pozice produkovan� motorem, tak�e si m��ete prohl�dnout, jak se hodnocen�
m�nila.
</p>
<p>
Chcete-li p�idat nejlep�� tah vybran� motorem jako nov� tah aktu�ln� partie,
stiskn�te tla��tko <b>P�idat tah</b>.
</p>

<h3><name List>Seznam analytick�ch motor�</name></h3>
<p>
Scid si udr�uje seznam pou��van�ch motor�, spolu s odhadem jejich Elo ratingu
(jestli n�jak� m�te) a datem jejich posledn�ho pou�it�. Seznam motor� lze
set��dit podle jm�na, Elo ratingu nebo data.
Chcete-li do seznamu p�idat nov� motor nebo editovat detaily existuj�c�ho
motoru, stiskn�te tla��tko <b>Nov�</b> nebo <b>Editace</b>.
</p>

<h3><name Start>P��kazy a adres��e motor�</name></h3>
<p>
Pro ka�d� motor mus�te specifikovat jeho spustiteln� soubor a adres��, kde m�
b�t Scidem spu�t�n.
</p>
<p>
D�vodem v�t�iny probl�m� se startem motor� je v�b�r adres��e, v kter�m m� b�t
motor spu�t�n. N�kter� motory vy�aduj� ke sv�mu ��dn�mu startu ve sv�m
startovac�m adres��i existenci inicializa�n�ho souboru nebo souboru knihoven
zah�jen�.
Jin� motory (jako Crafty) zapisuj� do adres��e, kde byly spu�t�ny, tzv. logovac�
soubory, tak�e je nutn� je spustit v takov�ch adres���ch, kde m�te p��stupov�
pr�vo z�pisu.
Jestli�e nastaven� adres��e pro motor je ".", Scid nastartuje tento motor v
aktu�ln�m adres��i.
</p>
<p>
Tak�e jestli�e n�jak� motor, kter� by m�l ve Scidu skv�le pracovat, nelze
nastartovat, zkuste zm�nit nastaven� jeho adres��e. Chcete-li zabr�nit vzniku
logovac�ch soubor� v mnoha r�zn�ch adres���ch, doporu�uji v�m spou�t�t motory v
adres��i u�ivatelsk�ch soubor� Scidu (tj. tam, kde se nach�z� soubor
<b>scid.exe</b> pro Windows nebo v adres��i <b>~/.scid/</b> pro Unix); v
dialogov�m okn� pro editaci detail� motoru je tla��tko ozna�en�
<b>scid.exe dir</b> pro Windows nebo <b>~/.scid</b> pro Unix, kter�m m��ete
nastavit spou�t�n� motoru v tomto adres��i.
</p>

<h3>Tr�nink</h3>
<p>
Tla��tkem <b>Tr�nink</b> m��ete proti analytick�mu motoru hr�t. �as na ka�d� tah
je pevn� dan� a v tr�ninkov�m m�du nejsou zobrazeny v�sledky anal�zy.
</p>

<h3>Anotace partie</h3>
<p>
Tla��tko <b>P�idat variantu</b> v analytick�m okn� p�id� do partie aktu�ln�
sk�re a nejlep�� pokra�ov�n� za ob� strany jako novou variantu.
</p>
<p>
Anotaci s�rie tah� (i cel� partie) m��ete prov�st automaticky stiskem tla��tka
<b>Anotace</b>. Budete dot�z�ni na ur�it� nastaven� anotace a potom se spust�
re�im automatick�ho p�ehr�v�n�.
V re�imu automatick�ho p�ehr�v�n� p�i otev�en�m analytick�m okn� je pro ka�dou
pozici (p�ehranou v automatick�m re�imu) samo�inn� p�id�na varianta obsahuj�c�
sk�re a nejlep�� pokra�ov�n� za ob� strany.
Anotov�ny jsou pouze pozice od aktu�ln� pozice do konce partie (nebo dokud
neukon��te re�im automatick�ho p�ehr�v�n�), tak�e p�esunem do pozice ze st�edn�
hry p�ed spu�t�n�m re�imu automatick�ho p�ehr�v�n� m��ete p�esko�it anotaci
zah�jen�.
</p>
<p>
Chcete-li kdykoliv anotaci ukon�it, sta�� jen ukon�it re�im automatick�ho
p�ehr�v�n�, nap�. stiskem kl�vesy <b>Escape</b> v hlavn�m okn�.
</p>
<p>
V�imn�te si, �e pro zjednodu�en� je tla��tko <b>Anotace</b> p��stupn� jen v okn�
analytick�ho motoru 1. Jestli�e spust�te motor jako analytick� motor 2, nebudete
ho moci pou��t k anotaci partie.
</p>

<h3>Analytick� �achovnice</h3>
<p>
Stisk tla��tka ikony �achovnice v analytick�m okn� zobraz� nebo skryje
analytickou �achovnici, kter� zobrazuje pozici na konci aktu�ln� nejlep��
varianty hry nalezenou motorem. Funguje to pro v�t�inu motor� kompatibiln�ch se
Scidem, ale nemus� pro v�echny; z�le�� to na tom, jakou notaci tah� motor
pou��v�.
</p>

<h3>Priorita motoru</h3>
<p>
Jestli�e motor vyu��v� p��li� mnoho �asu CPU (tj. procesoru) a negativn�
tak ovliv�uje pou��v�n� Scidu nebo jin�ch aplikac�, m��e pomoct zapnut�
tla��tka <b>N�zk� CPU priorita</b>; t�m d�te motoru n�zkou prioritu p�i
pl�nov�n� CPU. </p>

<h3>Detaily rozhran�</h3>
<p>
Abyste mohli pou��vat analytick� okno, budete pot�ebovat �achov� program, kter�
podporuje <term>WinBoard/Xboard</term> protokol.
</p>
<p>
Scid pos�l� motoru p�i jeho startu p��kazy <b>xboard</b>, <b>post</b> a
<b>protover 2</b> a jestli�e motor svou odpov�d� indikuje, �e je podporuje, Scid
pou�ije pro efektivn�j�� komunikaci s motorem p��kazy <b>setboard</b> a
<b>analyze</b>.
Jestli�e motor nepodporuje p��kaz <b>setboard</b>, nebude schopen poskytovat
anal�zu ��dn� partie, kter� za��n� s nestandardn� po��te�n� pozic�.
</p>
<p>
Program�m, kter� nepodporuj� p��kaz <b>analyze</b>, Scid p�i ka�d� zm�n� pozice
pos�l� n�sleduj�c� p��kazy: <b>new</b> a <b>force</b>, t�m se p�esune do partie
do aktu�ln� pozice a pak <b>go</b>.
</p>
<p>
J� pou��v�m a doporu�uji pro analytick� okno Scidu znamenit� �achov� freeware
program <term>Crafty</term> od Boba Hyatta, ale se Scidem bylo �sp�n� pou�ito
mnoho dal��ch WinBoard nebo XBoard kompatibiln�ch program�. N�e je seznam
webov�ch str�nek pro sta�en� n�kolika motor�.
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

<p><footer>(Aktualizov�no: Scid 3.4, Z��� 2002)</footer></p>
}

###################
### EPD files help:

set helpTitle(C,EPD) "EPD soubory"
set helpText(C,EPD) {<h1>EPD soubory</h1>
<p>
EPD (extended position description, tj. roz���en� popisova� pozice) soubor je
kolekce pozic, kde ka�d� pozice m� n�jak� doprovodn� text. Jako <a PGN>PGN</a>,
je to obecn� standard pro �achov� informace.
</p>
<p>
EPD soubor m� po�et definovan�ch <term>opk�d� (opcodes)</term> (pol�), kter�
jsou ulo�eny v souboru odd�leny st�edn�kem(<b>;</b>), ale v okn� EPD Scidu jsou
kv�li jednodu�� editaci zobrazeny na samostatn�ch ��dc�ch.
St�edn�k uvnit� EPD pole je ulo�en Scidem jako "<b>\s</b>", aby byl odli�en od
znaku konce pole.
Ka�d� pozice a k n� asociovan� opk�dy jsou ulo�eny na jedn� ��dce v EPD
souboru.
</p>
<p>
Standardn� EPD opk�dy zahrnuj�:
<ul>
<li> <b>acd</b> analytick� po�et: hloubka vyhled�v�n�.</li>
<li> <b>acn</b> analytick� po�et: po�et uzl� (nodes) vyhled�v�n�.</li>
<li> <b>acs</b> analytick� po�et: doba vyhled�v�n� v sekund�ch.</li>
<li> <b>bm</b> nejlep�� tahy: tah(y) ocen�n�(�) nejl�pe z n�jak�ho d�vodu.</li>
<li> <b>ce</b> setinop�cov� hodnocen�: hodnocen� v setin�ch p�c� z perspektivy
     <b>strany, kter� je na tahu</b> -- v�imn�te si rozd�lu proti oknu anal�zy,
     kter� zobrazuje hodnocen� v p�c�ch z perspektivy b�l�ho.</li>
<li> <b>cX</b> koment�� (kde <b>X</b> je ��slo, 0-9).</li>
<li> <b>eco</b> k�d zah�jen� podle <a ECO>ECO</a> syst�mu.</li>
<li> <b>id</b> jedine�n� identifikace pro tuto pozici.</li>
<li> <b>nic</b> k�d zah�jen� podle <i>New In Chess</i> syst�mu.</li>
<li> <b>pm</b> p�edpokl�dan� tah: prvn� tah PV.</li>
<li> <b>pv</b> p�edpokl�dan� varianta: varianta nejlep�� hry.</li>
</ul>

<p>
EPD soubory maj� mnoho pou�it�: Scid pou��v� EPD soubor ke klasifikaci parti�
podle syst�mu <a ECO>Encyklopedie �achov�ch zah�jen�</a> (Encyclopedia of Chess
Openings, ECO) a vy sami si m��ete vytvo�it EPD soubor pro v� reperto�r
zah�jen� p�id�n�m koment��� k pozic�m, kter� se ve va�ich parti�ch pravideln�
vyskytuj�.
</p>
<p>
Vytvo�it nov� EPD soubor nebo otev��t u� existuj�c� m��ete p��kazy
<menu>Nov�</menu> a <menu>Otev��t</menu> z menu <menu>Soubor</menu>. Kdykoliv
m��e b�t otev�eno nejv��e �ty�i EPD soubory.
</p>

<h3>EPD okna</h3>
<p>
Pro ka�d� otev�en� EPD soubor uvid�te jedno okno, kter� zobrazuje text k
aktu�ln� pozici. Chcete-li ulo�it zm�ny v textu k pozici, nen� pot�eba
stisknout tla��tko Ulo�it; text bude ulo�en v�dy, kdy� se p�esunete k jin�
pozici v partii.
</p>

<h3>Navigace v EPD souborech</h3>
<p>
Chcete-li si prohl�dnout pozice v EPD souboru, pou�ijte p��kazy
<menu>Next position</menu> a <menu>Previous position</menu> z menu
<menu>Tools</menu> v EPD okn� nebo pou�ijte kl�vesov� zkratky
<b>Ctrl+�ipkaDol�</b> a <b>Ctrl+�ipkaNahoru</b>.
Tyto p��kazy zp�sob� p�esun na n�sleduj�c�/p�edch�zej�c� pozici v souboru spolu
s odstran�n�m aktu�ln� partie a nastaven�m jej� po��te�n� pozice.
</p>

<h3>Odstran�n� EPD pol�</h3>
<p>
EPD soubory, kter� naleznete na Internetu, mohou obsahovat pole, kter� v�s
nezaj�maj� a mohou tak zbyte�n� zab�rat mnoho m�sta v souboru.
Nap�. EPD soubor hodnocen� �achov�ho programu m��e m�t pole ce, acd, acn, pm, pv
a id, ale mo�n� budete pot�ebovat jen pole ce a pv.
</p>
<p>
EPD opk�d m��ete odstranit ze v�ech pozic v EPD souboru pou�it�m p��kazu
<menu>Strip out EPD field</menu> z menu <menu>Tools</menu> v EPD okn�.
</p>

<h3>Stavov� li�ta EPD okna</h3>
<p>
Stavov� li�ta ka�d�ho EPD okna ukazuje:
<ul>
<li>- status souboru (<b>--</b> znamen� nezm�n�n, <b>XX</b> znamen� zm�n�n
      a <b>%%</b> znamen� jen ke �ten�); </li>
<li>- jm�no souboru; </li>
<li>- po�et pozic v souboru; </li>
<li>- leg�ln� tahy z aktu�ln� pozici vedouc� do jin� pozice v tomto EPD
      souboru.</li>
</ul>

<p><footer>(Aktualizov�no: Scid 2.5, �erven 2001)</footer></p>
}

######################
### Email window help:

set helpTitle(C,Email) "Emailov� okno"
set helpText(C,Email) {<h1>Emailov� okno</h1>
<p>
Okno emailov�ho mana�era Scidu v�m poskytuje prost�edky ke spr�v�
koresponden�n�ch parti� hran�ch emailem.
Jestli�e nehrajete �achy p�es email, nebude v�s to zaj�mat.
Ale jestli�e hrajete koresponden�n� partie p�es email, m��ete emailov� zpr�vy
pos�lat p��mo ze Scidu!
</p>
<p>
Pou�it� emailov�ho mana�era:
<ul>
<li><b>1)</b> Vytvo�te v datab�zi partii(e) pro va�eho soupe�e. </li>
<li><b>2)</b> V okn� emailov�ho mana�era zvolte <b>Add</b> a zadejte �daje o
va�em soupe�i: jm�no, emailov� adresa a ��sla parti� v datab�zi. </li>
<li><b>3)</b> V emailov�m okn� zvolte <b>Send email</b> v�dy, kdy� jste p�idali
tahy do partie(�) a chcete odeslat zpr�vu. </li>
</ul>

<p>
P�i odesl�n� emailov� zpr�vy Scid vygeneruje zpr�vu s parti� v PGN form�tu
<b>bez</b> jak�chkoliv koment���, anotac� a variant, proto�e obvykle nebudete
cht�t, aby soupe� vid�l va�e anal�zy.
P�ed odesl�n�m m��ete zpr�vu editovat p�id�n�m podm�n�n�ch tah� nebo jin�ho
textu.
</p>
<p>
Pro ka�d�ho soupe�e m��ete m�t libovoln� po�et parti�; nej�ast�ji jednu nebo
dv�. Uv�domte si, �e Scid nekontroluje zm�ny ��sel parti�, tak�e po zadan� �daj�
o va�em soupe�i d�vejte pozor, abyste datab�zi va�ich emailov�ch parti�
net��dili ani v n� nemazali ��dn� partie, proto�e tak by do�lo k p�euspo��d�n�
parti� a ��sla parti� pro ka�d�ho soupe�e by byla �patn�.
</p>

<h3>Omezen�</h3>
<p>
Scid dosud nedisponuje ��dnou funkc� kontroly va�ich emailov�ch po�ada��, tak�e
je st�le nutn� p�id�vat tahy va�eho soupe�e do partie manu�ln�.</p>

<h3>Konfigurace</h3>
<p>
Kopie v�ech emailov�ch zpr�v odeslan�ch Scidem je ulo�ena v souboru
<b>~/.scid/scidmail.log</b>. Jestli�e chcete, aby byly ulo�eny v jin�m souboru,
budete muset editovat soubor <b>tcl/start.tcl</b> a rekompilovat Scid.
</p>
<p>
Scid m��e pos�lat zpr�vy pou�it�m SMTP serveru nebo p��kazu sendmail. Ke
specifikaci va�� volby pou�ijte tla��tko <b>Settings</b> v okn� emailov�ho
mana�era.
</p>
<p>
Scid ukl�d� �daje o soupe��ch z datab�ze va�ich emailov�ch parti� v
souboru se stejn�m jm�nem jako tato datab�ze a p��ponou "<b>.sem</b>".
</p>

<p><footer>(Aktualizov�no: Scid 3.0, Listopad 2001)</footer></p>
}

########################
### Reports help:

set helpTitle(C,Reports) "Profily"
set helpText(C,Reports) {<h1>Profily</h1>
<p>
<term>Profil</term> ve Scidu je dokument obsahuj�c� informace o ur�it� pozici nebo ur�it�m hr��i. Existuj� dva typy profil�, kter� m��e Scid generovat: profil zah�jen� a profil hr��e.
</p>

<h3><name Opening>Profily zah�jen�</name></h3>
<p>
Scid m��e vytvo�it <term>profil zah�jen�</term>, kter� zobrazuje zaj�mav�
informace o pozici zah�jen�. Chcete-li vytvo�it profil zah�jen�, nejprve se
ujist�te, �e zobrazen� pozice je ta, pro kterou profil chcete, a potom zvolte
<b>Profil zah�jen�</b> z menu <b>N�stroje</b>.
</p>
<p>
Okno <term>profilu zah�jen�</term> zobrazuje v�sledek profilu vygenerovan�ho
Scidem. Menu <b>Soubor</b> obsahuje p��kazy pro ulo�en� (vyti�t�n�) profilu do
textov�ho souboru, do HTML souboru nebo <a LaTeX>LaTeX</a> souboru.
</p>
<p>
Prvn� sekce profilu prezentuj� informace na parti�ch, kter� dos�hly pozice
profilu, a na taz�ch hran�ch od t�to pozice. Lze zde vid�t, jestli se zah�jen�
st�v� v�ce popul�rn�m, jestli m� mnoho kr�tk�ch rem�z a jak� po�ad� tah�
(transpozice) se pou��vaj� k jej� dosa�en�.
</p>
<p>
Sekce pozi�n�ch t�mat zobrazuje  frekvenci ur�it�ch b�n�ch pozi�n�ch t�mat v profilovan�ch parti�ch. K tomu se pou�ije prvn�ch 20 tah� ka�d� partie (tedy prvn�ch 40 pozic� ka�d� partie po po��te�n� pozici). Partie se zapo�te jako partie obsahuj�c� ur�it� t�ma, jestli�e obsahuje dan� t�ma alespo� ve 4 pozic�ch v prvn�ch 20 taz�ch partie. Tak se zabr�n� ovlivn�n� v�sledku kr�tk�m v�skytem t�mat (jako nap�. izolovan� d�msk� p�ec, kter� je okam�it� vzat�).
</p>
<p>
Posledn� a nejv�t�� ��st� profilu je tabulka teorie. P�i ukl�d�n� profilu do
souboru si m��ete vybrat mezi ulo�en�m jen tabulky teorie, kompaktn�m profilem
bez tabulky teorie nebo cel�m profilem.
</p>
<p>
Skoro v�echny sekce profilu mohou b�t zapnuty nebo vypnuty nebo upraveny
prost�ednictv�m voleb profilu zah�jen�, tak�e si m��ete profil p�izp�sobit
tak, aby zobrazoval jen informace, kter� v�s zaj�maj�.
</p>
<p>
V�t�ina informac� v profilu zah�jen�, kter� jsou zobrazeny barevn�, vyvolaj�
p�i v�b�ru lev�m tla��tkem my�i n�jakou akci. Nap��klad p�i kliknut� na
referenci partie dojde k jej� nata�en�, p�i kliknut� na pozi�n� motiv dojde k
nastaven� filtru tak, �e bude obsahovat jen partie profilu, ve kter�ch se tento
motiv vyskytl.
</p>

<h4>Obl�ben�</h4>
<p>
Menu <menu>Obl�ben�</menu> v okn� profilu umo��uje udr�ovat sb�rku obl�ben�ch pozic profilu zah�jen� a jednodu�e generovat profil zah�jen� pro v�echny tyto pozice. V�b�rem "Add Report..." z menu Obl�ben� p�id�te aktu�ln� pozici jako obl�benou profilovanou pozici; budete vyzv�ni k zad�n� jm�na, kter� bude pou�ito jako jm�no souboru p�i generov�n� obl�ben�ch profil�.
</p>
<p>
Chcete-li generovat profil pro ka�d� obl�ben� profil p�i pou�it� aktu�ln� datab�ze, zvolte z menu Obl�ben� "Generovat profil...". Objev� se dialogov� okno, kter� V�m umo�n� specifikovat typ a form�t profilu a adres��, kde budou ulo�eny soubory profil�. Podle form�tu, kter� jste zvolili, bude ke ka�d�mu souboru profilu p�id�na vhodn� p��pona (nap�. ".html" pro HTML form�t).
</p>

<h3><name Player>Profily hr���</name></h3>
<p>
<term>Profil hr��e</term> je velmi podobn� profilu zah�jen�, ale obsahuje informace o parti�ch jednoho hr��e b�l�mi nebo �ern�mi figurami. Profil hr��e m��ete generovat z menu N�stroje nebo z okna <a PInfo>Informac� o hr��i</a>.
</p>
<p>
Profil hr��e m��e b�t generov�n bu� pro v�echny partie dan�ho hr��e dan�mi figurami nebo jen pro podmno�inu t�ch parti�, kter� dos�hly aktu�ln� pozici na �achovnici v hlavn�m okn�.
</p>


<h3>Omezen�</h3>
<p>
Pro v�t�inu dat generovan�ch profilem existuje limit 2000 parti�, tak�e
jestli�e se pozice profilu vyskytuje ve v�ce ne� 2000 parti�ch, n�jak� v�sledky
mohou b�t trochu nespr�vn�.
</p>
<p>
Rovn� pro tabulku teorie existuje limit 500 parti�. Jestli�e se pozice profilu
vyskytuje ve v�ce ne� 500 parti�ch, jen 500 parti� s nejvy���m pr�m�rn�m Elo
ratingem se pou�ije ke generov�n� tabulky teorie. Po�et parti� pou�it�ch ke
generov�n� tabulky teorie m��ete upravit ve volb�ch Profilu zah�jen�.
</p>

<p><footer>(Aktualizov�no: Scid 3.5, �nor 2003)</footer></p>
}


#####################
### Player List help:

set helpTitle(C,PList) "Okno vyhled�va�e hr���"
set helpText(C,PList) {<h1>Okno vyhled�va�e hr���</h1>
<p>
Okno <term> vyhled�va�e hr���</term> zobrazuje seznam jmen
hr��� v aktu�ln� datab�zi. V�b�rem hr��e se otev�e okno
<a PInfo>informac� o hr��i</a> s podrobn�j��mi informacemi o tomto hr��i.
</p>
<p>
Zobrazuje se p�t sloupc�, kter� zobrazuj� jm�no ka�d�ho hr��e, jeho nejvy���
rating, po�et jeho parti� a rok jeho nejstar�� a nejnov�j�� partie.
Chcete-li set��dit seznam podle n�kter�ho sloupce, klikn�te na jeho titulek
naho�e v seznamu.
</p>
<p>
Obsah seznamu m��ete filtrovat pomoc� ovl�d�n� dole pod seznamem. M��ete zm�nit
limit seznamu, zadat bez ohledu na velikost p�smen p�edponu jm�na hr��e (jako
t�eba "ada" pro vyhled�n� "Adams") a omezit rozsah Elo ratingu a po�tu parti�.
</p>

<p><footer>(Aktualizov�no: Scid 3.4, �ervenec 2002)</footer></p>
}

#####################
### Player Info help:

set helpTitle(C,PInfo) "Okno informac� o hr��i"
set helpText(C,PInfo) {<h1>Okno informac� o hr��i</h1>
<p>
Okno <term>informac� o hr��i</term> se otev�e nebo aktualizuje v�dy, kdy�
kliknete lev�m tla��tkem my�i na jm�no hr��e v informa�n� z�n� partie (pod
�achovnic�) nebo v okn� <a Crosstable>turnajov� tabulky</a>.
</p>
<p>
Okno zobrazuje (douf�m) u�ite�n� informace o hr��i, zejm�na jejich �sp�nost
b�l�ma a �ern�ma, obl�ben� zah�jen� (podle <a ECO>k�du ECO</a>) a historii
ratingu.
</p>
<p>
V�echna zobrazen� procenta jsou o�ek�van� v�sledek (m�ra �sp�nosti) z
perspektivy hr��e -- tak�e vy��� procento je v�dy lep�� pro hr��e, nez�visle na
tom, je-li b�l� �i �ern�.
</p>
<p>
Stiskem tla��tka <a Graphs Rating>Graf ratingu</a> m��ete vid�t graf historie
ratingu hr��e.
</p>
<p>
Kliknut�m lev�m tla��tkem my�i na libovoln� �erven� ��slo nastav�te
<a Searches Filter>filtr</a> na ty partie, kter� dan� ��slo reprezentuje.
</p>

<p><footer>(Aktualizov�no: Scid 2.5, �erven 2001)</footer></p>
}

################
### Graphs help:

set helpTitle(C,Graphs) "Okna graf�"
set helpText(C,Graphs) {<h1>Okna graf�</h1>
<p>
Scid m� n�kolik oken, kter� zobrazuj� informace graficky.
Jsou vysv�tleny n�e.
</p>

<h3><name Filter>Okno grafu filtru</name></h3>
<p>
Okno <term>grafu filtru</term> zobrazuje trendy parti� v aktu�ln�m filtru ve
srovn�n� s celou datab�z�, a to podle podle data nebo podle Elo ratingu. Nap�.
kdy� m�te otev�en� <a Tree>strom</a>, okno grafu je u�ite�n� jako n�stroj
zobrazuj�c�, jak se m�nila popularita aktu�ln� pozice zah�jen� v posledn�ch
letech nebo dek�d�ch nebo jestli je zvl�t� obl�ben� mezi hr��i s v�t��m
ratingem jako velmistry.
Ka�d� bod grafu reprezentuje pro jednotliv� rozsah data nebo Elo ratingu po�et
parti� ve filtru na 1000 parti� v cel� datab�zi.
</p>
<p>
P�i kreslen� grafu filtru podle ratingu, Scid pou��v� pro ka�dou partii pr�m�rn�
(st�edn�) rating. Odhady rating� (jako nap�. ty z pravopisn�ho souboru) se
nepou�ij�. Jestli�e jeden hr�� partie rating m�, ale jeho soupe� nikoliv, pak se
a� do hranice 2200 Elo p�edpokl�d�, �e soupe� m� stejn� rating.
Nap�. jestli�e jeden hr�� m� 2500 Elo a soupe� nem� ��dn� rating, st�edn� rating
je (2500+2200)/2=2350.
</p>

<h3><name Rating>Okno grafu ratingu</name></h3>
<p>
Okno <term>grafu ratingu</term> zobrazuje historii ratingu jednoho nebo obou
hr��� aktu�ln� partie.
Pro jednoho hr��e m��ete graf vyvolat stiskem tla��tka <b>Graf ratingu</b> v
okn� <a PInfo>informac� o hr��i</a> nebo pro oba hr��e aktu�ln� partie v�b�rem
<b>Graf ratingu</b> z menu <menu>N�stroje</menu>.
</p>

<h3><name Score>Okno grafu sk�re</name></h3>
<p>
Okno <term>grafu sk�re</term> zobrazuje numerick� hodnocen� (sk�re) ulo�en� v
koment���ch aktu�ln� partie jako graf.
Kliknut�m lev�m tla��tkem my�i kdekoliv v grafu sk�re se m��ete dostat do
koresponduj�c� pozice partie.
</p>
<p>
Jsou rozezn�v�ny dva druhy hodnot�c�ch koment���: ty, kter� produkuje
<a Analysis>analytick�</a> okno Scidu (kter� maj� form�t
<ul>
<li><b>1.e4 {"+0.25 ...."}</b></li>
</ul>
a jsou br�ny v�dy z perspektivy b�l�ho) a ty, kter� jsou produkov�ny Craftyho
anota�n�m p��kazem (kter� maj� form�t
<ul>
<li><b>1.e4 ({9:+0.25} ....)</b></li>
</ul>
a jsou rovn� br�ny v�dy z perspektivy b�l�ho).
</p>

<h3><name Tree>Okno grafu stromu</name></h3>
<p>
Okno <term>grafu stromu</term> je dostupn� ze stromov�ho okna. Zobrazuje
�sp�nost nejpopul�rn�j��ch tah� v aktu�ln� pozici. V�ce informac� naleznete na
str�nce n�pov�dy <a Tree Graph>stromu</a>.
</p>

<p><footer>(Aktualizov�no: Scid 3.3, Duben 2002)</footer></p>
}

####################
### Tablebases help:

set helpTitle(C,TB) "Tabulky koncovek"
set helpText(C,TB) {<h1>Tabulky koncovek</h1>

<p>
<term>Tabulka koncovek</term> (tablebase) je soubor obsahuj�c�  p�esn� informace
o v�sledku v�ech pozic s ur�it�m materi�lem, jako nap�. kr�l a v� proti kr�li a
p�ci. Byly generov�ny tabulky v�ech koncovek s materi�lem a� do p�ti kamen�
(br�no i s kr�li) a jsou rovn� k dispozici i n�kter� �estikamenov� tabulky
koncovek.
</p>
<p>
Scid m��e pou��vat tabulky koncovek v Nalimovov� form�tu, kter� vyu��vaj� mnoh�
modern�ch �achov� motory. Tyto tabulky v�t�inou kon�� p��ponou <b>.nbw.emd</b>
nebo <b>.nbb.emd</b>. Ve Scidu mohou b�t pou�ity v�echny 3, 4 a 5 kamenov�
Nalimovovy tabulky koncovek.
</p>

<h3>Pou�it� tabulek koncovek ve Scidu</h3>
<p>
Chcete-li pou��vat ve Scidu tabulky koncovek, sta�� nastavit jejich adres��
v�b�rem <b>Adres�� pro tabulky koncovek ...</b> z menu <menu>Volby</menu>.
M��ete vybrat a� 4 adres��e, kde jsou va�e tabulky koncovek ulo�eny.
Stiskem tla��tka <b>...</b> napravo m��ete vybrat soubor a t�m ur�it, �e m� b�t
pou�it adres�� tohoto souboru.
</p>
<p>
Kdy� dos�hnete pozice, kter� je nalezen� v souboru tabulky koncovek, informa�n�
z�na partie (pod �achovnic�) zobraz� informace z tabulky. Mno�stv� zobrazen�ch
informac� m��ete konfigurovat kliknut�m prav�ho tla��tka my�i v t�to z�n� nebo
v�b�rem <b>Informace o partii</b> z menu <menu>Volby</menu>. Volba "v�sledek a
nejlep�� tahy" d�v� neju�ite�n�j�� informace, ale je velmi �asto pomalej�� ne�
volba "jen v�sledek".
</p>

<h3>Okno tabulky koncovek</h3>
<p>
Z tabulky koncovek m��ete z�skat je�t� v�ce informac� o aktu�ln� pozici
otev�en�m <term>okna tabulky koncovek</term> (menu <menu>Okna</menu>, kl�vesov�
zkratka: Ctrl+=). Toto okno zobrazuje v�sledek s precizn� hrou na v�echny mo�n�
tahy v aktu�ln� pozici.
</p>
<p>
Toto okno m� dv� hlavn� ��sti. Souhrnn� r�mec (nalevo) zobrazuje, kter� tabulky
koncovek Scid nalezl na va�em po��ta�i a p�ehled pro ka�dou tabulku. V�sledkov�
r�mec (napravo) zobrazuje optim�ln� v�sledky pro v�echny tahy v aktu�ln� pozici
v hlavn�m okn�.
</p>

<h4>Souhrnn� r�mec</h4>
<p>
Horn� ��st souhrnn�ho r�mce v�m umo��uje v�b�r konkr�tn� tabulky koncovek.
Tabulky, kter� m�te k dispozici, jsou zobrazeny mod�e a ty, kter� jsou
nedostupn�, jsou zobrazeny �ed�, ale m��ete vybrat libovolnou tabulku.
Doln� ��st souhrnn�ho r�mce zobrazuje p�ehled informac� pro zvolenou tabulku
koncovek. (Je�t� ne v�echny tabulky maj� ve Scidu ulo�en p�ehled).
</p>
<p>
P�ehled zahrnuje frekvenci (po�et parti� na mili�n, kter� dos�hly pozice s t�mto
materi�lem, spo�teno z datab�ze t�m�� 600,000 mistrovsk�ch parti�), nejdel�� mat
za ob� strany a po�et vz�jemn�ch (nebo "recipro�n�ch") zugzwang�. Vz�jemn�
zugwang je takov� pozice, kde b�l� p�i sv�m tahu remizuje a �ern� p�i sv�m tahu
prohraje nebo kde ta strana, kter� je na tahu, prohr�v�.
</p>
<p>
Pro n�kter� tabulky koncovek se vz�jemn�mi zugzwangy p�ehled zahrnuje tak� v��et
v�ech zugzwangov�ch pozic nebo jejich v�b�r. �pln� v��et pro ka�dou tabulku
koncovek nen� provediteln�, proto�e n�kter� tabulky maj� tis�ce vz�jemn�ch
zugzwang�.
</p>
<p>
Stiskem tla��tka <b>Random</b> m��ete nastavit n�hodnou pozici ze zvolen�
tabulky koncovek.
</p>

<h4>V�sledkov� r�mec</h4>
<p>
V�sledkov� r�mec je aktualizov�n kdykoliv se zm�n� pozice na �achovnici v
hlavn�m okn�. Prvn� ��dek ukazuje kolik tah� vyhr�v� (+), remizuje (=), prohr�v�
(-) nebo m� nezn�m� v�sledek(?). Zbytek r�mce ud�v� podrobn�j�� seznam v�sledk�,
v po�ad� od nejkrat��ch k nejdel��m v�hr�m, potom rem�zy a  nakonec od
nejdel��ch k nejkrat��m prohr�m. V�echny vzd�lenosti jsou po��t�ny k matu.
</p>

<h4>V�sledkov� �achovnice</h4>
<p>
V pozici obsa�en� v tabulk�ch koncovek je �asto u�ite�n�, jak� by byl v�sledek,
kdyby v�echny kameny v aktu�ln� pozici byly na sv�ch sou�asn�ch m�stech, ale
pozice jedn� ur�it� figury by byla jin�.
Nap�. m��ete cht�t rozhodnout, jak bl�zko mus� b�t kr�l k voln�mu p�ci, aby
ur�it� pozice byla vyhran� nebo rem�zov�. V knih�ch koncovek je tato informace
�asto naz�v�na jako <i>v�t�zn� z�na</i> nebo <i>rem�zov� z�na</i> figury v
pozici.
</p>
<p>
Tuto informaci m��ete zjistit ve Scidu stiskem tla��tka s obr�zkem
�achovnice, v okn� tabulky koncovek se pot� zobraz�
<term>v�sledkov� �achovnice</term>.
Stisknete-li lev� tla��tko my�i na kter�koliv figu�e na t�to �achovnici, na
ka�d�m pr�zdn�m poli se nakresl� symbol ur�uj�c� jak� by byl v�sledek (p�i tahu
stejn� strany jako v pozici v hlavn�m okn�), kdyby vybran� figura byla na
takov�m poli.
</p>
<p>
Je p�t druh� symbol�, kter� pole m��e m�t:
b�l� <b>#</b> znamen� v�hru b�l�ho;
�ern� <b>#</b> znamen� v�hru �ern�ho;
modr� <b>=</b> znamen�, �e pozice je rem�zov�;
�erven� <b>X</b> znamen�, �e pozice je ileg�ln� (kv�li soused�c�m kr�l�m nebo
proto�e strana na tahu d�v� �ach); a
�erven� <b>?</b> znamen�, �e v�sledek nen� zn�m, proto�e pot�ebn� soubor tabulek
koncovek nen� k dispozici.
</p>

<h3>Obstar�n� soubor� tabulek koncovek</h3>
<p>
Pro pomoc ohledn� vyhled�n� soubor� tabulek koncovek na internetu �t�te
<a Author Related>p��buzn� odkazy</a>.
</p>

<p><footer>(Aktualizov�no: Scid 3.4, Z��� 2002)</footer></p>
}

###################
### Bookmarks help:

set helpTitle(C,Bookmarks) "Z�lo�ky"
set helpText(C,Bookmarks) {<h1>Z�lo�ky</h1>
<p>
Scid v�m umo��uje pro snadn� budouc� p��stup pou��t pro d�le�it� partie
<term>z�lo�ky</term>. Menu z�lo�ek je dostupn� z menu <menu>Soubor</menu>, z
n�strojov� li�ty nebo prost�ednictv�m kl�vesov� zkratky <B>Ctrl+B</b>.
</p>
<p>
Kdy� z menu Z�lo�ky vyberete zalo�enou partii, Scid, jestli�e je to nutn�,
otev�e jej� datab�zi, nalezne tuto partii a p�esune se do t� pozice v partii, v
kter� byla zalo�ena.
</p>
<p>
Z�lo�ky mohou b�t pou�ity jen pro datab�ze ve form�tu Scidu (ne pro PGN soubory
nebo pro datab�zi schr�nka).
</p>
<p>
P�i t��d�n� nebo zhutn�n� datab�ze obsahuj�c� zalo�enou partii se detaily
z�lo�ky mohou st�t zastaral�mi. Kdy� se tak stane, p�i v�b�ru takov� z�lo�ky
Scid vyhled� v datab�zi nejl�pe odpov�daj�c� partii (srovn�n�m jmen hr���,
m�sta, atd.), tak�e zalo�en� partie by m�la i tak b�t nata�ena. Av�ak jestli�e
se zm�n� detaily zalo�en� partie, je mo�n�, �e detail�m z�lo�ky bude l�pe
odpov�dat jin� partie a bude nata�ena m�sto n�. Tak�e je dobrou my�lenkou znovu
zalo�it partii, jestli�e edituje jej� hr��e, m�sto, v�sledek, kolo nebo rok.
</p>

<h3>Editace z�lo�ek</h3>
<p>
Pomoc� editoru z�lo�ek m��ete zm�nit text menu zobrazen� pro ka�dou zalo�enou
partii a p�idat slo�ku ke kategorizaci z�lo�ek.
</p>

<h3>Rady</h3>
<p>
Z�lo�ky m��ete pou��vat pro rychl� p��stup k datab�z�m, kter� �asto pou��v�te, a
to tak, �e z ka�d� datab�ze si zalo��te partii. Dal��m dobr�m pou�it�m z�lo�ek
je p�id�v�n� d�le�it�ch parti� p�i studiu jednotliv�ch �achov�ch zah�jen�.
</p>
<p>
Menu z�lo�ek obsahuje polo�ku pro kontrolu zobrazov�n� slo�ek z�lo�ek: mohou b�t
zobrazov�ny jako podmenu (u�ite�n� p�i velk�m po�tu z�lo�ek) nebo jako jedin�
seznam.
</p>

<p><footer>(Aktualizov�no: Scid 3.0, Listopad 2001)</footer></p>
}

##############################
### Command-line options help:

set helpTitle(C,Cmdline) "Volby p��kazov�ho ��dku"
set helpText(C,Cmdline) {<h1>Volby p��kazov�ho ��dku</h1>
<p>
Kdy� spou�t�te Scid z shellu nebo z konsole, m��ete specifikovat r�zn� volby
p��kazov�ho ��dku. M��ete zadat datab�zi ve form�tu Scidu (s nebo bez p��pony
souboru jako nap�. ".si3") a PGN soubor, kter� se maj� otev��t, nap�. p��kaz:
<ul>
<li>scid mybase newgames.pgn</li>
</ul>
spust� Scid a otev�e datab�zi Scidu pojmenovanou mybase a PGN soubor pojmenovan�
newgames.pgn.
</p>
<p>
Jsou zde tak� voliteln� argumenty slou��c� ke kontrole soubor�, kter� m� Scid
prohledat a pou��t p�i sv�m startu. Volbou <b>-xtb</b> (nebo <b>-xt</b>) m��ete
vypnout pou��v�n� <a TB>tabulek koncovek</a>, volbou <b>-xeco</b> nebo
<b>-xe</b> m��ete zru�it natahov�n� souboru
<a ECO>klasifikace zah�jen� ECO</a> a volbou <b>-xspell</b> nebo <b>-xs</b>
m��ete zru�it natahov�n� <a Maintenance Spellcheck>pravopisn�ho souboru</a>.
Z�rove� existuje volba <b>-fast</b> nebo <b>-f</b>, kter� d�l� v�echno, co t�i
p�edchoz� volby dohromady, tak�e p��kaz <b>scid -f</b> je ekvivalentn� p��kazu
<b>scid -xeco -xspell -xtb</b>.
</p>

<p><footer>(Aktualizov�no: Scid 3.1, Listopad 2001)</footer></p>
}

#################
### Pgnscid help:

set helpTitle(C,Pgnscid) "Pgnscid"
set helpText(C,Pgnscid) {<h1>Pgnscid</h1>
<p>
<term>Pgnscid</term> je separ�tn� program, kter� je pot�eba ke konverzi PGN
(portable game notation) soubor� na datab�ze Scidu.
</p>
<p>
Chcete-li zkonvertovat soubor pojmenovan� <i>myfile.pgn</i>, jednodu�e zadejte:
<ul>
<li> <b>pgnscid myfile.pgn</b> </li>
</ul>
a datab�ze Scidu (skl�daj�c� se z <i>myfile.si3</i>, <i>myfile.sg3</i>
a <i>myfile.sn3</i>) bude vytvo�ena.
Ve�ker� chyby a varov�n� budou zaps�ny do souboru <i>myfile.err</i>.
</p>
<p>
Chcete-li, aby datab�ze byla vytvo�ena v jin�m adres��i nebo m�la jin� jm�no,
m��ete jm�no datab�ze p�idat do p��kazov�ho ��dku, nap�.:
<ul>
<li> <b>pgnscid myfile.pgn mybase</b> </li>
</ul>
vytvo�� datab�zi skl�daj�c� se ze soubor� <i>mybase.si3</i>,
<i>mybase.sg3</i> a <i>mybase.sn3</i>.
</p>
<p>
V�imn�te si, �e pgnscid (a scid) m��e ��st PGN soubory komprimovan� Gzipem
(t.j. <b>mybase.pgn.gz</b>) p��mo, tak�e m�te-li velk� PGN soubor k u�et�en�
m�sta komprimovan� Gzipem, nen� pot�eba ho nejprve dekomprimovat.
</p>

<h3>Volby</h3>
<p>
Pgnscid akceptuje p�ed jm�nem souboru dva voliteln� parametry: <b>-f</b> a
<b>-x</b>.
</p>
<p>
Pou�it�m parametru <b>-f</b> dojde k n�siln�mu p�epsan� existuj�c� datab�ze;
implicitn� pgnscid neprovede konverzi na datab�zi, kter� u� existuje.
</p>
<p>
Parametr <b>-x</b> zp�sob�, �e pgnscid bude ignorovat v�echen text mezi
partiemi.
Implicitn� je text mezi partiemi ulo�en jako p�edpartiov� koment�� k partii,
kter� n�sleduje. Tato volba ovliv�uje jen text mezi partiemi; standardn�
koment��e uvnit� ka�d� partie jsou i tak zkonvertov�ny a ulo�eny.
</p>

<h3>Form�tov�n� jmen hr���</h3>
<p>
Aby se zredukoval po�et v�cen�sobn�ho pravopisu jmen, kter� odkazuj� na stejn�ho
hr��e, pgnscid prov�d� n�kter� z�kladn� form�tov�n� jmen hr���. Nap�. po�et
mezer za ka�dou ��rkou je standardizov�n na jednu, v�echny mezery na za��tku a
na konci jm�na jsou odstran�ny a te�ka na konci jm�na je odstran�na.
Holandsk� p�edpony jako "van den" a "Van Der" jsou rovn� normalizov�ny tak, �e
maj� velk� p�smeno V a mal� d.
</p>
<p>
Jm�na hr���, turnaj�, m�st a kol lze ve Scidu editovat (a dokonce kontrolovat
jejich pravopis); detaily najdete na str�nce n�pov�dy
<a Maintenance Editing>�dr�ba</a>.
</p>

<p><footer>(Aktualizov�no: Scid 2.5, �erven 2001)</footer></p>
}


######################
### File formats help:

set helpTitle(C,Formats) "Form�ty soubor�"
set helpText(C,Formats) {<h1>Form�ty soubor� Scidu</h1>
<p>
Datab�ze Scidu se skl�daj� ze t�� z�kladn�ch soubor�: Indexov� soubor, Jmenn�
soubor a Partiov� soubor. V�echny maj� dvoup�smennou p��ponu za��naj�c� na "s":
".si" pro indexov� (index) soubory, ".sn" pro jmenn� (name) soubory a ".sg" pro
partiov� (game) soubory.
</p>

<h3>Indexov� (.si) soubor</h3>
<p>
Tento soubor obsahuje popis datab�ze a mal� z�znam pevn� velikosti pro ka�dou
partii. Sou�asn� velikost je 41 byt� na partii. 28 byt� z t�to velikosti jsou
z�kladn� informace jako nap�. v�sledek, datum, identifika�n� ��sla jmen hr���,
turnaje, m�sta (skute�n� jm�na jsou v Jmenn�m souboru), atd.
</p>
<p>
Zb�vaj�c�ch 13 byt� obsahuje nadbyte�n�, ale u�ite�n� informace o partii, kter�
se pou��vaj� k urychlen� vyhled�v�n� podle pozice, materi�lu a vzoru. Pro v�ce
informac� �t�te n�e sekci <a Formats Fast>Rychl� vyhled�v�n�</a>.
</p>

<h3>Jmenn� (.sn) soubor</h3>
<p>
Tento soubor obsahuje v�echny jm�na hr���, turnaj�, m�st a kol pou�it�ch v
datab�zi. Ka�d� jm�no je ulo�eno jen jednou, i kdy� se vyskytuje ve v�ce
parti�ch. Jmenn� soubor je obvykle nejmen�� ze t�� z�kladn�ch soubor� v
datab�zi.
</p>

<h3>Partiov� (.sg) soubor</h3>
<p>
Tento soubor obsahuje skute�n� tahy, varianty a koment��e ka�d� partie.
Form�t k�dov�n� tah� je velmi �sporn�: v�t�ina tah� zab�r� pouze jeden byte
m�sta.
</p>
<p>
Kdy� je partie nahrazena, je jej� nov� verze ulo�ena na <i>konec</i> partiov�ho
souboru, tak�e �asem m��e doj�t k nahromad�n� zbyte�n� nepou�it�ho m�sta.
Datab�zi m��ete navr�tit do jej� minim�ln� velikosti jej�m
<a Compact>zhutn�n�m</a>.
</p>

<h3>Ostatn� soubory Scidu</h3>
<p>
<a EPD>EPD</a> soubor (p��pona: ".epd") obsahuje mno�stv� �achov�ch pozic�,
ka�dou s textov�m koment��em.
Form�t EPD souboru je pops�n v <a Author Related>PGN standardu</a>.
</p>
<p>
V emailov�m (p��pona: ".sem") souboru pro datab�zi jsou ulo�eny detaily
oponent�, kter�m pos�l�te emailov� zpr�vy.
</p>
<p>
Soubor vyhled�vac�ch voleb (p��pona: ".sso") obsahuje nastaven� pro vyhled�v�n�
podle <a Searches Header>hlavi�ky</a> nebo podle
<a Searches Material>materi�lu/vzoru</a>.
</p>

<h3><name Fast>Rychl� vyhled�v�n� ve Scidu</name></h3>
<p>
Jak bylo �e�eno v��e, indexov� soubor uchov�v� n�kter� nadbyte�n�, ale u�ite�n�
informace o ka�d� partii za ��elem urychlen� vyhled�v�n� podle pozice nebo podle
materi�lu.
</p>
<p>
Nap�. je ulo�en materi�l kone�n� pozice. Jestli�e hled�te v�ov� a p�cov�
koncovky, pak v�echny partie, kter� kon�� s d�mou, st�elcem nebo jezdcem na
�achovnici (a nemaj� ��dn� prom�ny p�c�) budou rychle p�esko�eny.
</p>
<p>
Dal�� u�ite�n� informace, kter� je ulo�ena, je po�ad�, s jakou p�ci opou�t�j�
sv� po��te�n� postaven� (bu� sv�m tahem nebo vzet�m). To se pou�ije k urychlen�
stromov�ch vyhled�v�n� nebo vyhled�v�n� podle p�esn� pozice, zvl�t� pak pro
pozice zah�jen�. Nap�. hled�te-li po��te�n� pozici francouzsk� obrany (1.e4 e6),
ka�d� partie za��naj�c� 1.e4 c5 nebo 1.d4 atd. bude p�esko�ena, ale partie
za��naj�c� 1.e4 e5 bude t�eba je�t� prohledat.
</p>

<p><footer>(Aktualizov�no: Scid 2.5, �erven 2001)</footer></p>
}

###########################
### Options and Fonts help:

set helpTitle(C,Options) "Volby"
set helpText(C,Options) {<h1>Volby a preference</h1>
<p>
Mnoho voleb a preferenc� Scidu (jako nap�. velikost �achovnice, barvy, fonty a
implicitn� nastaven�) m��ete nastavit v menu <menu>Volby</menu>.
Kdy� z menu Volby zvol�te <b>Ulo�it volby</b>, tato nastaven� (a je�t� dal��,
jako nap�. posledn� adres��, z kter�ho se nat�hla datab�ze a velikosti n�kter�ch
oken) jsou ulo�eny do souboru voleb.
Tento soubor voleb se na�te p�i ka�d�m spu�t�n� Scidu.
</p>
<p>
Jestli�e pou��v�te Windows, soubor voleb je <b>scid.opt</b> v adres��i, kde se
nach�z� spustiteln� soubor Scidu <b>scid.exe</b>. Pro u�ivatele unixov�ch
opera�n�ch  syst�m� (jako nap�. Solaris nebo Linux) je soubor voleb
<b>~/.scid/scidrc</b>.
</p>

<h3><name MyPlayerNames>Nastaven� jmen va�ich hr���</name></h3>
<p>
M��e b�t takov� jm�no hr��e (nebo n�kolik jmen), pro kter� byste cht�li, aby kdykoliv se nat�hne jeho partie, �achovnice v hlavn�m okn� byla zobrazena z perspektivy tohoto hr��e. Pou�it�m <b>Jm�na m�ch hr���...</b> z menu <menu>Volby/�achovnice</menu> m��ete konfigurovat seznam takov�ch jmen. V dialogov�m okn�, kter� se objev�, zadejte na ka�d� ��dek jedno jm�no hr��e. Z�stupn� znaky ("<b>?</b>" pro p�esn� jeden znak a "<b>*</b>" pro sekvenci nula nebo v�ce znak�) mohou b�t pou�ity.
</p>

<h3><name Fonts>Nastaven� font�</name></h3>
<p>
Scid m� t�i z�kladn� fonty, kter� pou��v� ve v�t�in� sv�ch oken, a v�echny z
nich si m��ete p�izp�sobit. Naz�vaj� se <b>z�kladn�</b>, <b>mal�</b> a
<b>fixn�</b>.
</p>
<p>
Fixn� font mus� m�t pevnou ���ku fontu (neproporcion�ln�). Pou��v� se pro okna
<a Tree>stromu</a> a <a Crosstable>turnajov� tabulky</a>.
</p>

<p><footer>(Aktualizov�no: Scid 3.5, �nor 2003)</footer></p>
}

####################
### NAG values help:

set helpTitle(C,NAGs) "NAG hodnoty"
set helpText(C,NAGs) {<h1>Standardn� NAG hodnoty</h1>
<p>
Standardn� NAG (Numeric Annotation Glyph, tj. numerick� anota�n� piktograf)
hodnoty definovan� v <a Author Related>PGN standardu</a> jsou:
</p>
<cyan>
<ul>
<li>  1   siln� tah (!) </li>
<li>  2   �patn� tah (?) </li>
<li>  3   velmi siln� tah (!!) </li>
<li>  4   hrub� chyba (??) </li>
<li>  5   zaj�mav� tah (!?) </li>
<li>  6   pochybn� tah (?!) </li>
<li>  7   vynucen� tah </li>
<li>  8   jedin� tah; ��dn� rozumn� alternativy </li>
<li>  9   nejhor�� tah </li>
<li> 10   rem�zov� pozice (=) </li>
<li> 11   vyrovnan� �ance, klidn� pozice (=) </li>
<li> 12   vyrovnan� �ance, �iv� pozice (=) </li>
<li> 13   nejasn� pozice (~) </li>
<li> 14   b�l� m� malou v�hodu (+=) </li>
<li> 15   �ern� m� malou v�hodu (=+) </li>
<li> 16   b�l� m� v�hodu (+/-) </li>
<li> 17   �ern� m� v�hodu (-/+) </li>
<li> 18   b�l� m� rozhoduj�c� v�hodu (+-) </li>
<li> 19   �ern� m� rozhoduj�c� v�hodu (-+) </li>
<li> 20   b�l� m� drtivou v�hodu (+-) </li>
<li> 21   �ern� m� drtivou v�hodu (-+) </li>
<li> 22   b�l� je v nev�hod� tahu (zugzwang) </li>
<li> 23   �ern� je v nev�hod� tahu (zugzwang) </li>
<li> 24   b�l� m� malou prostorovou p�evahu </li>
<li> 25   �ern� m� malou prostorovou p�evahu </li>
<li> 26   b�l� m� prostorovou p�evahu </li>
<li> 27   �ern� m� prostorovou p�evahu </li>
<li> 28   b�l� m� rozhoduj�c� prostorovou p�evahu </li>
<li> 29   �ern� m� rozhoduj�c� prostorovou p�evahu </li>
<li> 30   b�l� m� mal� n�skok ve v�vinu </li>
<li> 31   �ern� m� mal� n�skok ve v�vinu </li>
<li> 32   b�l� m� n�skok ve v�vinu </li>
<li> 33   �ern� m� n�skok ve v�vinu </li>
<li> 34   b�l� m� rozhoduj�c� n�skok ve v�vinu </li>
<li> 35   �ern� m� rozhoduj�c� n�skok ve v�vinu </li>
<li> 36   b�l� m� iniciativu </li>
<li> 37   �ern� m� iniciativu </li>
<li> 38   b�l� m� trvalou iniciativu </li>
<li> 39   �ern� m� trvalou iniciativu </li>
<li> 40   b�l� m� �tok </li>
<li> 41   �ern� m� �tok </li>
<li> 42   b�l� m� nedostate�nou kompenzaci za materi�ln� �jmu </li>
<li> 43   �ern� m� nedostate�nou kompenzaci za materi�ln� �jmu </li>
<li> 44   b�l� m� dostate�nou kompenzaci za materi�ln� �jmu </li>
<li> 45   �ern� m� dostate�nou kompenzaci za materi�ln� �jmu </li>
<li> 46   b�l� m� v�ce ne� adekv�tn� kompenzaci za materi�ln� �jmu </li>
<li> 47   �ern� m� v�ce ne� adekv�tn� kompenzaci za materi�ln� �jmu </li>
<li> 48   b�l� s malou v�hodou kontroluje centrum </li>
<li> 49   �ern� s malou v�hodou kontroluje centrum </li>
<li> 50   b�l� s v�hodou kontroluje centrum </li>
<li> 51   �ern� s v�hodou kontroluje centrum </li>
<li> 52   b�l� s rozhoduj�c� v�hodou kontroluje centrum </li>
<li> 53   �ern� s rozhoduj�c� v�hodou kontroluje centrum </li>
<li> 54   b�l� s malou v�hodou kontroluje kr�lovsk� k��dlo </li>
<li> 55   �ern� s malou v�hodou kontroluje kr�lovsk� k��dlo </li>
<li> 56   b�l� s v�hodou kontroluje kr�lovsk� k��dlo </li>
<li> 57   �ern� s v�hodou kontroluje kr�lovsk� k��dlo </li>
<li> 58   b�l� s rozhoduj�c� v�hodou kontroluje kr�lovsk� k��dlo </li>
<li> 59   �ern� s rozhoduj�c� v�hodou kontroluje kr�lovsk� k��dlo </li>
<li> 60   b�l� s malou v�hodou kontroluje d�msk� k��dlo </li>
<li> 61   �ern� s malou v�hodou kontroluje d�msk� k��dlo </li>
<li> 62   b�l� s v�hodou kontroluje d�msk� k��dlo </li>
<li> 63   �ern� s v�hodou kontroluje d�msk� k��dlo </li>
<li> 64   b�l� s rozhoduj�c� v�hodou kontroluje d�msk� k��dlo </li>
<li> 65   �ern� s rozhoduj�c� v�hodou kontroluje d�msk� k��dlo </li>
<li> 66   b�l� m� slabou prvn� �adu </li>
<li> 67   �ern� m� slabou prvn� �adu </li>
<li> 68   b�l� m� dob�e chr�n�nou prvn� �adu </li>
<li> 69   �ern� m� dob�e chr�n�nou prvn� �adu </li>
<li> 70   b�l� m� �patn� chr�n�n�ho kr�le </li>
<li> 71   �ern� m� �patn� chr�n�n�ho kr�le </li>
<li> 72   b�l� m� dob�e chr�n�n�ho kr�le </li>
<li> 73   �ern� m� dob�e chr�n�n�ho kr�le </li>
<li> 74   b�l� m� �patn� postaven�ho kr�le </li>
<li> 75   �ern� m� slab� postaven�ho kr�le </li>
<li> 76   b�l� m� dob�e postaven�ho kr�le </li>
<li> 77   �ern� m� dob�e postaven�ho kr�le </li>
<li> 78   b�l� m� velmi �patnou p�covou strukturu </li>
<li> 79   �ern� m� velmi �patnou p�covou strukturu </li>
<li> 80   b�l� m� �patnou p�covou strukturu </li>
<li> 81   �ern� m� �patnou p�covou strukturu </li>
<li> 82   b�l� m� dobrou p�covou strukturu </li>
<li> 83   �ern� m� dobrou p�covou strukturu </li>
<li> 84   b�l� m� velmi dobrou p�covou strukturu </li>
<li> 85   �ern� m� velmi dobrou p�covou strukturu </li>
<li> 86   b�l� m� �patn� postaven�ho jezdce </li>
<li> 87   �ern� m� �patn� postaven�ho jezdce </li>
<li> 88   b�l� m� dob�e postaven�ho jezdce </li>
<li> 89   �ern� m� dob�e postaven�ho jezdce </li>
<li> 90   b�l� m� �patn� postaven�ho st�elce </li>
<li> 91   �ern� m� �patn� postaven�ho st�elce </li>
<li> 92   b�l� m� dob�e postaven�ho st�elce </li>
<li> 93   �ern� m� dob�e postaven�ho st�elce </li>
<li> 94   b�l� m� �patn� postavenou v� </li>
<li> 95   �ern� m� �patn� postavenou v� </li>
<li> 96   b�l� m� dob�e postavenou v� </li>
<li> 97   �ern� m� dob�e postavenou v� </li>
<li> 98   b�l� m� �patn� postavenou d�mu </li>
<li> 99   �ern� m� �patn� postavenou d�mu </li>
<li>100   b�l� m� dob�e postavenou d�mu </li>
<li>101   �ern� m� dob�e postavenou d�mu </li>
<li>102   b�l� m� �patnou souhru figur </li>
<li>103   �ern� m� �patnou souhru figur </li>
<li>104   b�l� m� dobrou souhru figur </li>
<li>105   �ern� m� dobrou souhru figur </li>
<li>106   b�l� sehr�l zah�jen� velmi slab� </li>
<li>107   �ern� sehr�l zah�jen� velmi slab� </li>
<li>108   b�l� sehr�l zah�jen� slab� </li>
<li>109   �ern� sehr�l zah�jen� slab� </li>
<li>110   b�l� sehr�l zah�jen� dob�e </li>
<li>111   �ern� sehr�l zah�jen� dob�e </li>
<li>112   b�l� sehr�l zah�jen� velmi dob�e </li>
<li>113   �ern� sehr�l zah�jen� velmi dob�e </li>
<li>114   b�l� sehr�l st�edn� hru velmi slab� </li>
<li>115   �ern� sehr�l st�edn� hru velmi slab� </li>
<li>116   b�l� sehr�l st�edn� hru slab� </li>
<li>117   �ern� sehr�l st�edn� hru slab� </li>
<li>118   b�l� sehr�l st�edn� hru dob�e </li>
<li>119   �ern� sehr�l st�edn� hru dob�e </li>
<li>120   b�l� sehr�l st�edn� hru velmi dob�e </li>
<li>121   �ern� sehr�l st�edn� hru velmi dob�e </li>
<li>122   b�l� sehr�l koncovku velmi slab� </li>
<li>123   �ern� sehr�l koncovku velmi slab� </li>
<li>124   b�l� sehr�l koncovku slab� </li>
<li>125   �ern� sehr�l koncovku slab� </li>
<li>126   b�l� sehr�l koncovku dob�e </li>
<li>127   �ern� sehr�l koncovku dob�e </li>
<li>128   b�l� sehr�l koncovku velmi dob�e </li>
<li>129   �ern� sehr�l koncovku velmi dob�e </li>
<li>130   b�l� m� m�rnou protihru </li>
<li>131   �ern� m� m�rnou protihru </li>
<li>132   b�l� m� protihru </li>
<li>133   �ern� m� protihru </li>
<li>134   b�l� m� rozhoduj�c� protihru </li>
<li>135   �ern� m� rozhoduj�c� protihru </li>
<li>136   b�l� m� �asovou t�se� </li>
<li>137   �ern� m� �asovou t�se� </li>
<li>138   b�l� m� obrovskou �asovou t�se� </li>
<li>139   �ern� m� obrovskou �asovou t�se� </li>
</ul>
</cyan>

<p>
Ostatn� p�edlo�en� NAG hodnoty pro symboly publikac� �achov�ho Inform�toru
(Chess Informant) obsahuj�:
</p>
<cyan>
<ul>
<li>140   s my�lenkou ... </li>
<li>141   nam��eno proti ... </li>
<li>142   lep�� tah </li>
<li>143   hor�� tah </li>
<li>144   rovnocenn� tah </li>
<li>145   pozn�mka redakce ("RR") </li>
<li>146   novinka ("N") </li>
<li>147   slab� bod </li>
<li>148   koncovka </li>
<li>149   sloupec; �ada </li>
<li>150   diagon�la </li>
<li>151   b�l� m� dvojici st�elc� </li>
<li>152   �ern� m� dvojici st�elc� </li>
<li>153   r�znobarevn� st�elci </li>
<li>154   stejnobarevn� st�elci </li>
</ul>
</cyan>

<p>
Ostatn� navr�en� hodnoty jsou:
</p>
<cyan>
<ul>
<li>190   atd. </li>
<li>191   zdvojen� p�ci </li>
<li>192   izolovan� p�ci </li>
<li>193   spojen� p�ci </li>
<li>194   vis�c� p�ci </li>
<li>195   opo�d�n� p�ec </li>
</ul>
</cyan>

<p>
Symboly definovan� Scidem pro jeho vlastn� pou�it� jsou:
</p>
<cyan>
<ul>
<li>201   Diagram ("D", n�kdy ozna�ovan� "#") </li>
</ul>
</cyan>

<p><footer>(Aktualizov�no: Scid 2.5, �erven 2001)</footer></p>
}

##############
### ECO guide:

set helpTitle(C,ECO) "ECO pr�vodce"
set helpText(C,ECO) {<h1>Klasifikace zah�jen� ECO</h1>
<p>
Scid m��e klasifikovat �achov� partie podle klasifikace �achov�ch zah�jen�
<b>ECO</b> (Encyclopedia of Chess Openings, tj. Encyklopedie �achov�ch
zah�jen�).
Standardn� ECO k�d se skl�d� z p�smene (A..E) n�sledovan�ho dv�ma ��slicemi,
tak�e existuje 500 rozd�ln�ch standardn�ch ECO k�d�.
</p>

<h3>Roz���en� ECO syst�mu podporovan� Scidem</h3>
<p>
ECO syst�m je velmi omezen� a nedostate�n� pro modern� partie: n�kter� z 500
k�d� se skoro v�bec nevyskytuj�, zat�mco n�kter� se vyskytuj� velmi �asto. Pro
zlep�en� t�to situace Scid umo��uje voliteln� roz���en� z�kladn�ch ECO k�d�:
ka�d� k�d m��e b�t roz���en p�smenem (a..z), dal�� roz���en� (��slic�, 1..4)
jsou mo�n�, ale je�t� nejsou pou�ity ve standardn�m ECO souboru Scidu.
Tak�e roz���en� ECO k�d Scidu vypad� asi jako "<b>A41e</b>" nebo "<b>E99b2</b>".
Mnoho nejb�n�j��ch ECO k�d� z modern�ch mistrovsk�ch parti� maj� roz���en�
definovan� v ECO souboru Scidu.
</p>

<h3><name Browser>Okno ECO prohl�e�e</name></h3>
<p>
Okno <term>ECO prohl�e�e</term> v�m zobrazuje pozice, kter� jsou pou��v�ny ke
klasifikaci ka�d�ho ECO k�du a �etnost a �sp�nost ECO k�d� v aktu�ln� datab�zi.
</p>
<p>
Horn� pole zobrazuje �etnost ka�d�ho ECO k�du v aktu�ln� datab�zi. Li�ta v grafu
m� t�i �seky: nejni��� (nejsv�tlej�� barva) je po�et v�her b�l�ho, prost�edn� je
po�et rem�z a nejvy��� (nejtmav��) je po�et v�her �ern�ho. To v�m umo��uje
rychle zjistit charakteristiky zah�jen�: nap�. jestli b�l� sk�ruj� velmi dob�e
nebo jestli jsou velmi �ast� rem�zy.
</p>
<p>
Chcete-li j�t do hlub�� ECO �rovn�, klikn�te lev�m tla��tkem my�i na li�tu v
grafu (nebo zadejte koresponduj�c� p�smeno nebo ��slici). Chcete-li j�t zp�t do
vy��� �rovn�, klikn�te prav�m tla��tkem my�i kamkoliv v grafu nebo stiskn�te
kl�vesu lev� �ipky (nebo Delete nebo Backspace).
</p>
<p>
Doln� pole zobrazuje pozice, kter� obsahuje jednotliv� ECO k�d, podle ECO
souboru, kter� jste nat�hli.
</p>

<h3>Nata�en� ECO souboru Scidu</h3>
<p>
ECO soubor distribuovan� spole�n� se Scidem se jmenuje <b>scid.eco</b> a Scid se
ho pokou�� p�i sv�m startu nat�hnout.
Jestli�e ho Scid nem��e naj�t, bude pot�eba, aby byla mo�n� ECO klasifikace,
ud�lat n�sleduj�c�:
<ul>
<li>(a) Ve Scidu, pou�ijte p��kaz menu
        <menu>Volby: Nat�hnout ECO
        soubor...</menu> a vyberte soubor <b>scid.eco</b>. </li>
<li>(b) Ulo�te volby (z menu <menu>Volby</menu>). </li>
</ul>
Pot�, co to provedete, ECO soubor bude nata�en p�i ka�d�m spu�t�n� Scidu.
</p>

<h3><name Codes>Syst�m k�d� ECO</name></h3>
<p>
Z�kladn� struktura ECO syst�mu je:
</p>
<p>
<b><blue><run updateEcoWin A>A</run></blue></b>
   1.d4 Jf6 2...;  1.d4 ...;  1.c4;  1.r�zn�
<ul>
<li>  <b>A0</b>  1.<i>r�zn�</i>
      (<b>A02-A03</b> 1.f4: <i>Birdovo zah�jen�</i>,
      <b>A04-A09</b>  1.Jf3: <i>R�tiho, Kr�lovsk� indick� �tok</i>) </li>
<li>  <b>A1</b>  1.c4 ...: <i>Anglick�</i> </li>
<li>  <b>A2</b>  1.c4 e5: <i>Anglick� kr�lovsk�</i> </li>
<li>  <b>A3</b>  1.c4 c5: <i>Anglick� symetrick�</i> </li>
<li>  <b>A4</b>  1.d4 ...: <i>D�msk�m p�cem</i> </li>
<li>  <b>A5</b>  1.d4 Jf6 2.c4 ..: <i>Indick� obrana</i> </li>
<li>  <b>A6</b>  1.d4 Nf6 2.c4 c5 3.d5 e6: <i>Modern� Benoni</i> </li>
<li>  <b>A7</b>  A6 + 4.Jc3 exd5 5.cxd5 d6 6.e4 g6 7.Jf3 </li>
<li>  <b>A8</b>  1.d4 f5: <i>Holandsk� obrana</i> </li>
<li>  <b>A9</b>  1.d4 f5 2.c4 e6: <i>Holandsk� obrana</i> </li>
</ul>

<p>
<b><blue><run updateEcoWin B>B</run></blue></b>
   1.e4 c5;  1.e4 c6;  1.e4 d6;  1.e4 <i>r�zn�</i>
<ul>
<li>  <b>B0</b>  1.e4 ...
      (<b>B02-B05</b>  1.e4 Jf6: <i>Alechinova obrana</i>;
      <b>B07-B09</b>  1.e4 d6: <i>Pircova</i>) </li>
<li>  <b>B1</b>  1.e4 c6: <i>Caro-Kann</i> </li>
<li>  <b>B2</b>  1.e4 c5: <i>Sicilsk� obrana</i> </li>
<li>  <b>B3</b>  1.e4 c5 2.Jf3 Jc6: <i>Sicilsk�</i> </li>
<li>  <b>B4</b>  1.e4 c5 2.Jf3 e6: <i>Sicilsk�</i> </li>
<li>  <b>B5</b>  1.e4 c5 2.Jf3 d6: <i>Sicilsk�</i> </li>
<li>  <b>B6</b>  B5 + 3.d4 cxd4 4.Jxd4 Jf6 5.Jc3 Jc6 </li>
<li>  <b>B7</b>  B5 + 4.Jxd4 Jf6 5.Jc3 g6: <i>Sicilsk� dra��</i> </li>
<li>  <b>B8</b>  B5 + 4.Nxd4 Nf6 5.Nc3 e6: <i>Sicilsk� Scheveningen</i> </li>
<li>  <b>B9</b>  B5 + 4.Nxd4 Nf6 5.Nc3 a6: <i>Sicilsk� Najdorf</i> </li>
</ul>

<p>
<b><blue><run updateEcoWin C>C</run></blue></b>
   1.e4 e5;  1.e4 e6
<ul>
<li>  <b>C0</b>  1.e4 e6: <i>Francouzsk� obrana</i> </li>
<li>  <b>C1</b>  1.e4 e6 2.d4 d5 3.Jc3: <i>Francouzsk�, Winawer/klasick�</i>
  </li>
<li>  <b>C2</b>  1.e4 e5: <i>Otev�en� hra</i> </li>
<li>  <b>C3</b>  1.e4 e5 2.f4: <i>Kr�lovsk� gambit</i> </li>
<li>  <b>C4</b>  1.e4 e5 2.Jf3: <i>Otev�en� hra</i> </li>
<li>  <b>C5</b>  1.e4 e5 2.Jf3 Jc6 3.Sc4: <i>Italsk�; Hra dvou jezdc�</i> </li>
<li>  <b>C6</b>  1.e4 e5 2.Jf3 Jc6 3.Sb5: <i>�pan�lsk�</i> </li>
<li>  <b>C7</b>  1.e4 e5 2.Jf3 Jc6 3.Sb5 a6 4.Sa4: <i>�pan�lsk�</i> </li>
<li>  <b>C8</b>  C7 + 4...Jf6 5.O-O: <i>�pan�lsk�, zav�en� a otev�en�</i>
      (<b>C80-C83</b>  5.O-O Jxe4: <i>�pan�lsk�, otev�en� syst�m</i>;
      <b>C84-C89</b>  5.O-O Se7: <i>�pan�lsk�, zav�en� syst�m</i>) </li>
<li>  <b>C9</b>  C8 + 5...Se7 6.Ve1 b5 7.Sb3 d6: <i>�pan�lsk�, zav�en�</i> </li>
</ul>

<p>
<b><blue><run updateEcoWin D>D</run></blue></b>
   1.d4 d5; 1.d4 Jf6 2.c4 g6 s 3...d5
<ul>
<li>  <b>D0</b>  1.d4 d5: <i>D�msk�m p�cem</i> </li>
<li>  <b>D1</b>  1.d4 d5 2.c4 c6: <i>Slovansk� obrana</i> </li>
<li>  <b>D2</b>  1.d4 d5 2.c4 dxc4: <i>D�msk� gambit p�ijat�</i> </li>
<li>  <b>D3</b>  1.d4 d5 2.c4 e6: <i>D�msk� gambit odm�tnut�</i> </li>
<li>  <b>D4</b>  D3 + 3.Jc3 Jf6 4.Jf3 c5/c6: <i>Semi-Tarraschova;
  Poloslovansk�</i>  </li>
<li>  <b>D5</b>  D3 + 3.Jc3 Jf6 4.Sg5: <i>D�msk� gambit odm�tnut� klasick�</i>
 </li>
<li>  <b>D6</b>  D5 + 4...Se7 5.e3 O-O 6.Jf3 Jbd7: <i>D�msk� gambit
 odm�tnut�  ortodoxn�</i> </li>
<li>  <b>D7</b>  1.d4 Jf6 2.c4 g6 s 3...d5: <i>Grunfeldova obrana</i> </li>
<li>  <b>D8</b>  1.d4 Jf6 2.c4 g6 3.Jc3 d5: <i>Grunfeldova</i> </li>
<li>  <b>D9</b>  1.d4 Jf6 2.c4 g6 3.Jc3 d5 4.Jf3: <i>Grunfeldova</i> </li>
</ul>

<p>
<b><blue><run updateEcoWin E>E</run></blue></b>
   1.d4 Jf6 2.c4 e6; 1.d4 Jf6 2.c4 g6 </li>
<ul>
<li>  <b>E0</b>  1.d4 Jf6 2.c4 e6: <i>Katal�nsk�, atd.</i> </li>
<li>  <b>E1</b>  1.d4 Jf6 2.c4 e6 3.Jf3 (b6): <i>D�msk� indick�, atd.</i> </li>
<li>  <b>E2</b>  1.d4 Jf6 2.c4 e6 3.Jc3 (Sb4): <i>Nimcovi�ova indick�, atd.</i>
 </li>
<li>  <b>E3</b>  E2 + 4.Sg5 nebo 4.Dc2: <i>Nimcovi�ova indick�</i> </li>
<li>  <b>E4</b>  E2 + 4.e3: <i>Nimcovi�ova indick�, Rubinstein</i> </li>
<li>  <b>E5</b>  E4 + 4...O-O 5.Jf3: <i>Nimcovi�ova indick�, hlavn� varianta</i>
 </li>
<li>  <b>E6</b>  1.d4 Jf6 2.c4 g6: <i>Kr�lovsk� indick�</i> </li>
<li>  <b>E7</b>  1.d4 Jf6 2.c4 g6 3.Jc3 Sg7 4.e4: <i>Kr�lovsk� indick�</i> </li>
<li>  <b>E8</b>  E7 + 4...d6 5.f3: <i>Kr�lovsk� indick�, Samisch</i> </li>
<li>  <b>E9</b>  E7 + 4...d6 5.Jf3: <i>Kr�lovsk� indick�, hlavn�
 varianty</i> </li>
</ul>

<p><footer>(Aktualizov�no: Scid 2.5, �erven 2001)</footer></p>
}

#################
### Contact info:


set helpTitle(C,Author) "Kontaktn� informace"
set helpText(C,Author) {<h1>Kontaktn� informace</h1>
<p>
Webov� str�nka Scidu je: <br>
<b><url http://scid.sourceforge.net/>http://scid.sourceforge.net/</url></b>
</p>
<p>
M��ete si tam st�hnout posledn� verzi Scidu a k dispozici jsou i jin� soubory.
</p>
<p>
Ve�ker� koment��e, dotazy, n�vrhy a informace o chyb�ch pos�lejte pros�m autorovi
Scidu, Shaneovi Hudsonovi, na emailovou adresu:<br>
<b>sgh@users.sourceforge.net</b>
</p>

<h3><name Related>P��buzn� odkazy</name></h3>
<p>
Jestli�e se v�m Scid l�b�, mo�n� v�s budou zaj�mat n�sleduj�c� webov� str�nky:
</p>
<ul>
<li><url http://www.tim-mann.org/chess.html>http://www.tim_mann.org/chess.html</url> --
Domovsk� str�nka programu Tima Manna <b>xboard & winboard</b>, kter� lze pou��t ke
�ten� PGN a jako rozhran� pro internetov� �achov� servery. Jeho str�nka obsahuje
rovn� dobr� informace o Crafty, GNUchess a dal��ch voln� �i�iteln�ch �achov�ch
programech. </li>

<li><url ftp://ftp.cis.uab.edu/pub/hyatt/>ftp://ftp.cis.uab.edu/pub/hyatt/</url> --
siln� �achy hraj�c� program Crafty. Podadres�� pojmenovan� <b>TB</b> obsahuje mnoho
soubor� tabulek koncovek (tablebase) v Nalimovov� form�tu, kter� lze pou��t v
n�kolika �achov�ch programech a rovn� ve Scidu.</li>

<li><url http://www.chesscenter.com/twic/>http://www.chesscenter.com/twic/</url> --
TWIC (the week in chess), znamenit� t�denn� zpravodaj mezin�rodn�ch �achov�ch
parti� dostupn� v PGN form�tu.</li>

<li><url http://scid.sourceforge.net/doc/standard.txt>http://scid.sourceforge.net/doc/standard.txt</url> --
<b>PGN Standard</b>, vytvo�en� Stevenem J. Edwardsem v roce 1994. Tento text
vysv�tluje detailn� form�ty PGN a EPD.</li> </ul>

<p><footer>(Aktualizov�no: Scid 2.6, Srpen 2001)</footer></p>
}

# end of czech.tcl
