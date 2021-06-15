# swedish.tcl:
# Text for menu names and status bar help messages in Swedish.
# Part of Scid (Shane's Chess Information Database).
# Contributed by Martin Skj�ldebrand, martin@skjoldebrand.org
# Thanks to: Hans Eriksson, for looking over the translation file

proc setLanguage_W {} {

# File menu:
menuText W File "Arkiv" 0
menuText W FileNew "Ny..." 0 {Skapa en ny Scid databas}
menuText W FileOpen "�ppna..." 0 {�ppna en befintlig Scid databas}
menuText W FileClose "St�ng" 0 {St�ng den aktiva Scid databasen}
menuText W FileFinder "S�k filer" 4 {�ppna s�kdialogen}
menuText W FileBookmarks "Bokm�rken" 0 {Hantera bokm�rken (kortkommando: Ctrl+B)}
menuText W FileBookmarksAdd "Nytt bokm�rke" 0 \
  {Markera den aktiva st�llningen i partiet}
menuText W FileBookmarksFile "Spara bokm�rke" 0 \
  {Spara bokm�rket f�r den aktiva st�llningen i partiet}
menuText W FileBookmarksEdit "Redigera bokm�rken..." 0 \
  {Redigera bokm�rken}
menuText W FileBookmarksList "Visa bokm�rken som lista" 19 \
  {Visar bokm�rkena som lista, inte undermenyer}
menuText W FileBookmarksSub "Visa bokm�rken i undermenyer" 17 \
  {Visar bokm�rkena som undermenyer, inte lista}
menuText W FileMaint "Databasverktyg" 0 {Scids databasverktyg}
menuText W FileMaintWin "Verktygsf�nster" 0 \
  {�ppna/ st�ng verktygsf�nstret}
menuText W FileMaintCompact "Komprimera databasen..." 0 \
  {Komprimera databasen, avl�gsna raderade partier och oanv�nda namn}
menuText W FileMaintClass "Klassificera partier enligt ECO..." 2 \
  {Klassificera om alla partier enligt ECO-systemet}
menuText W FileMaintSort "Sortera databasen..." 0 \
  {Sortera partierna i den aktiva databasen}
menuText W FileMaintDelete "Radera dubbletter..." 0 \
  {S�k dubbletter och markera dem som raderingsbara}
menuText W FileMaintTwin "S�k dubbletter" 0 \
  {�ppna/ st�ng dubblettf�nstret f�r att s�ka dubblettpartier}
menuText W FileMaintName "Stavningskontroll" 0 {Namnredigering och stavningskontroll}
menuText W FileMaintNameEditor "Redigera namn" 0 \
  {Redigera spelarnamn utifr�n r�ttstavningsfilen}
menuText W FileMaintNamePlayer "Stavningskontrollera namn..." 22 \
  {Stavningskontrollera namn utifr�n r�ttstavningsfilen}
menuText W FileMaintNameEvent "Stavningskontrollera evenemang..." 21 \
  {Stavningskontrollera evenemang utifr�n r�ttstavningsfilen}
menuText W FileMaintNameSite "Stavningskontrollera platser..." 21 \
  {Stavningskontrollera platser utifr�n r�ttstavningsfilen}
menuText W FileMaintNameRound "Stavningskontrollera ronder..." 21 \
  {Stavningskontrollera ronder utifr�n r�ttstavningsfilen}
menuText W FileReadOnly "Enbart l�sbar..." 8 \
  {Avl�gsna tempor�rt redigeringsm�jligheterna till databasen}
menuText W FileSwitch "Byt databas" 0 \
  {Byt till en annan �ppnad databas} 
menuText W FileExit "Avsluta" 0 {Avsluta Scid}
menuText W FileMaintFixBase "Fixa trasig databas" 0 {F�rs�k att fixa en trasig databas}

# Edit menu:
menuText W Edit "Redigera" 0
menuText W EditAdd "L�gg till variant" 0 {Skapa en variant vid denna st�llning}
menuText W EditDelete "Radera variant" 0 {Radera en variant vid denna st�llning}
menuText W EditFirst "Skapa huvudvariant" 6 \
  {G�r en av varianterna till huvudvariant}
menuText W EditMain "Skapa nytt textdrag" 11 \
  {G�r en av varianterna till partiforts�ttning}
menuText W EditTrial "Testa variant" 6 \
  {Starta/ stoppa testl�ge, unders�k en id� p� br�det}
menuText W EditStrip "Ta bort" 3 {Avl�gsna kommentarer eller varianter fr�n partiet}
menuText W EditUndo "�ngra" 0 {�ngra senaste �ndring i parti}
# ====== TODO To be translated ======
menuText W EditRedo "Redo" 0 {Redo last game change}
menuText W EditStripComments "Kommentarer" 0 \
  {Avl�gsna alla kommentarer och noteringar fr�n partiet}
menuText W EditStripVars "Varianter" 0 {Avl�gsna alla varianter fr�n partiet}
menuText W EditStripBegin "Avl�gsna tidigare drag" 9 \
  {Avl�gsna dragen fram till den aktuella st�llningen} 
menuText W EditStripEnd "Avl�gsna resterande drag" 0 \
  {Avl�gsna partiets resterande drag} 
menuText W EditReset "T�m Clipbase" 1 \
  {T�mmer den tempor�ra databasen}
menuText W EditCopy "Kopiera partiet till Clipbase" 21 \
  {Kopierar det aktuella partiet till Clipbase}
menuText W EditPaste "Klistra in det senaste Clipbasepartiet" 8 \
  {Klistrar in det senaste tillagda i Clipbase i den aktiva databasen}
menuText W EditPastePGN "Klistra in Clipbasetext som PGNparti..." 10 \
  {Tolka Clipbasetexten som ett parti i PGN notation och klistra in det h�r}
menuText W EditSetup "Skapa st�llning..." 0 \
  {Skapa en utg�ngsst�llning f�r aktuellt parti}
menuText W EditCopyBoard "Kopiera st�llning" 0 \
  {Kopiera den aktuella st�llningen i FEN kod till urklippshanteraren} 
menuText W EditPasteBoard "Klistra in utg�ngsst�llning" 10 \
  {Klistra in st�llningen fr�n aktuellt parti i den tempor�ra databasen}
# ====== TODO To be translated ======
menuText W ConfigureScid "Preferences..." 0 {Configure all options for SCID}

# Game menu:
menuText W Game "Partier" 0
menuText W GameNew "Nytt parti" 0 \
  {�terst�ll br�det inf�r ett nytt parti (raderar alla �ndringar)}
menuText W GameFirst "Ladda det f�rsta partiet" 10 {Laddar det f�rsta partiet i filtret}
menuText W GamePrev "Ladda f�reg�ende parti" 7 {Ladda f�reg�ende parti i filtret}
menuText W GameReload "B�rja om partiet" 0 \
  {�terst�ll partiet (raderar alla �ndringar)}
menuText W GameNext "Ladda n�sta parti" 6 {Ladda n�sta parti i filtret}
menuText W GameLast "Ladda det sista partiet" 10 {Ladda det sista partiet i filtret}
menuText W GameRandom "Ladda parti slumpm�ssigt" 14 \
  {Ladda ett av datorn slumpm�ssigt valt parti} 
menuText W GameNumber "Ladda parti nummer..." 6 \
  {Ladda ett parti genom att ange dess nummer}
menuText W GameReplace "Spara: Ers�tt parti..." 7 \
  {Spara partiet och ers�tt tidigare version}
menuText W GameAdd "Spara: Nytt parti..." 1 \
  {Spara ett nytt parti}
menuText W GameDeepest "Identifiera �ppningen" 0 \
  {G� till den mest detaljerade st�llningen i ECO boken}
menuText W GameGotoMove "G� till drag nummer..." 8 \
  {G� till ett specifikt drag i partiet}
menuText W GameNovelty "Hitta nyhet..." 7 \
  {Hitta det f�rsta draget i partiet som inte spelats tidigare}

# Search Menu:
menuText W Search "S�k" 0
menuText W SearchReset "�terst�ll s�kfilter" 0 {�terst�ll s�kfiltret s� att alla partiet ing�r}
menuText W SearchNegate "Omv�nt filter" 0 {Ta med partier som utesluts av filtret}
menuText W SearchCurrent "Aktuell position..." 8 {S�k partier med aktuell position p� br�det}
menuText W SearchHeader "I huvud..." 2 {Anv�nd fast information (spelare, evenemang, plats, mm)}
menuText W SearchMaterial "Material/st�llning..." 0 {S�kning baserad p� material eller st�llning}
menuText W SearchUsing "Anv�nd s�kfil..." 10 {Anv�nd en fil med lagrade s�kvillkor}

# Windows menu:
menuText W Windows "F�nster" 0
menuText W WindowsComment "Kommentarseditor" 0 {�ppna/ st�ng kommentarseditorn}
menuText W WindowsGList "Partilista" 5 {�ppna/ st�ng partilistan}
menuText W WindowsPGN "PGN f�nster" 0 \
  {�ppna/ st�ng PGN f�nstret}
menuText W WindowsPList "Spelarf�rteckning" 7 {�ppna/ st�ng en f�rteckning �ver spelarna i den aktiva databasen} 
menuText W WindowsTmt "Turneringar" 0 {Lista turneringar}
menuText W WindowsSwitcher "Databasv�xlaren" 0 \
  {�ppna/ st�ng databasv�xlaren}
menuText W WindowsMaint "Verktygsf�nster" 0 \
  {�ppna/ st�ng verktygsf�nstret}
menuText W WindowsECO "ECO f�nster" 0 {�ppna/ st�ng ECO bl�ddraren}
menuText W WindowsStats "Statistikf�nster" 0 \
  {�ppna/ st�ng statistikf�nstret}
menuText W WindowsTree "Tr�df�nster" 2 {�ppna/ st�ng varianttr�dets f�nster}
menuText W WindowsTB "Slutspelsdatabas" 2 \
  {�ppna/ st�ng slutspelsdatabasf�nstret}
menuText W WindowsBook "Bokf�nster" 0 {�ppna/st�ng Bokf�nstret}
menuText W WindowsCorrChess "Korrespondensf�nster" 0 {�ppna/st�ng Korrespondensf�nstret}

# Tools menu:
menuText W Tools "Verktyg" 0
menuText W ToolsAnalysis "Analysmotor..." 6 \
  {Starta/ stoppa en analysmotor}
menuText W ToolsAnalysis2 "Analysmotor 2..." 12 \
  {Starta/ stoppa en andra analysmotor}
menuText W ToolsCross "Resultattabell" 0 {Visa en resultattabell f�r den aktuella turneringen}
menuText W ToolsEmail "Eposthanterare" 0 \
  {�ppna/ st�ng eposthanteraren}
menuText W ToolsFilterGraph "Filterdiagram" 7 \
  {�ppna/ st�ng filterdiagramf�nstret} 
menuText W ToolsAbsFilterGraph "Absolut Filtergraf" 7 {�ppna/st�ng filtergraff�nstret f�r absolutv�rden}
menuText W ToolsOpReport "�ppningsrapport" 0 \
  {Skapa en �ppningsrapport utifr�n den aktuella st�llningen}
menuText W ToolsOpenBaseAsTree "�ppna databas som tr�d" 0   {�ppna en databas och anv�nd den i Tr�df�nstret}
menuText W ToolsOpenRecentBaseAsTree "�ppna senaste databasen som tr�d" 0   {�ppna den senaste databasen och anv�nd den i Tr�df�nstret}
menuText W ToolsTracker "S�k material"  0 {�ppnar dialog f�r att s�ka efter en viss materiell balans} 
menuText W ToolsTraining "Tr�ning"  0 {Tr�ningsverktyg (taktik, �ppningar,...) }
menuText W ToolsTacticalGame "Taktiskt parti"  0 {Spela ett parti med taktik}
menuText W ToolsSeriousGame "Seri�st parti"  0 {Spela ett seri�st parti}
menuText W ToolsTrainOpenings "�ppningar"  0 {Tr�na med en repetoar}
menuText W ToolsTrainReviewGame "Granska parti"  0 {Gissa drag spelade i ett parti}
menuText W ToolsTrainTactics "Taktik"  0 {L�sa taktik}
menuText W ToolsTrainCalvar "Variantber�kning"  0 {Variantber�kningstr�ning}
menuText W ToolsTrainFindBestMove "Hitta b�st drag"  0 {Hitta b�sta draget}
menuText W ToolsTrainFics "Spela p� Internet"  0 {Spela p� freechess.org}
# ====== TODO To be translated ======
menuText W ToolsEngineTournament "Engine tournament"  0 {Start a tournament between chess engines}
menuText W ToolsBookTuning "Bokfininst�llning" 0 {Bokfininst�llning}
menuText W ToolsConnectHardware "Anslut H�rdvara" 0 {Anslut extern h�rdvara}
menuText W ToolsConnectHardwareConfigure  "Konfiguration" 0 {Konfiguration}
menuText W ToolsConnectHardwareNovagCitrineConnect "Anslut Novag Citrine" 0 {Anslut Novag Citrine}
menuText W ToolsConnectHardwareInputEngineConnect "Anslut Inmatningsschackmotor" 0 {Anslut Inmatningsschackmotor (t.ex. DGT)}
menuText W ToolsPInfo "Spelarinformation"  0 \
  {�ppna/ uppdatera spelarinformation}
menuText W ToolsPlayerReport "Spelarrapport..." 3 \
  {Skapa en spelarrapport}
menuText W ToolsRating "Ratingdiagram" 0 \
  {Skapa ett ratingdiagram f�r spelarna i partiet}
menuText W ToolsScore "Resultatdiagram" 8 {Visa resultatdiagrammet}
menuText W ToolsExpCurrent "Exportera aktuellt parti" 1 \
  {Spara aktuellt parti till en textfil}
menuText W ToolsExpCurrentPGN "Exportera till PGN..." 15 \
  {Spara aktuellt parti till en PGN-fil}
menuText W ToolsExpCurrentHTML "Exportera till HTML..." 15 \
  {Spara aktuellt parti till en HTML-fil}
menuText W ToolsExpCurrentHTMLJS "Exportera till HTML och JavaScript-fil..." 15 {Spara aktuellt parti till en HTML och JavaScript-fil}  
menuText W ToolsExpCurrentLaTeX "Exportera till LaTeX..." 15 \
  {Spara aktuellt parti till en LaTeX-fil}
menuText W ToolsExpFilter "Exportera alla filtrerade partier" 15 \
  {Spara alla filterade partier till en textfil}
menuText W ToolsExpFilterPGN "Exportera till PGN..." 15 \
  {Spara alla filterade partier till en PGN-fil}
menuText W ToolsExpFilterHTML "Exportera till HTML..." 15 \
  {Spara alla filterade partier till en HTML-fil}
menuText W ToolsExpFilterHTMLJS "Exportera filtrerade till HTML och JavaScript-fil..." 17 {Spara alla filtrerade partier till en HTML och JavaScript-fil}  
menuText W ToolsExpFilterLaTeX "Exportera till LaTeX..." 15 \
  {Spara alla filterade partier till en LaTeX-fil}
menuText W ToolsImportOne "Importera ett parti i PGN-format..." 0 \
  {Importera ett parti i PGN-format}
menuText W ToolsImportFile "Importera flera partier i PGN-format..." 16 \
  {Importera flera partier i PGN-format fr�n en fil}
menuText W ToolsStartEngine1 "Starta schackmotor 1" 0  {Starta schackmotor 1}
menuText W ToolsStartEngine2 "Starta schackmotor 2" 0  {Starta schackmotor 2}
menuText W ToolsCaptureBoard "Spara aktuellt schackbr�de..." 0  {Spara det aktuella schackbr�det som en bild.}
menuText W Play "Spela" 0
menuText W CorrespondenceChess "Korrespondensschack" 0 {Funktioner f�r eMail och Xfcc baserad Korrespondensschack}
menuText W CCConfigure "Konfigurera..." 0 {Konfigurera externa verktyg och generella inst�llningar}
menuText W CCConfigRelay "Konfigurera observationer..." 10 {Konfigurera partier att observera}
menuText W CCOpenDB "�ppna Databas..." 0 {�ppna standardkorrespondensdatabasen}
menuText W CCRetrieve "H�mta Partier" 0 {H�mta partier via extern (Xfcc-)hj�lpare}
menuText W CCInbox "Hantera Inkorg" 0 {Hantera alla filer i Scids Inkorg}
menuText W CCSend "Skicka Drag" 0 {Skicka ditt drag via eMail eller extern (Xfcc-)hj�lpare}
menuText W CCResign "Ge upp" 0 {Ge upp (inte via eMail)}
menuText W CCClaimDraw "H�vda Remi" 0 {Skicka drag och h�vda Remi (inte via eMail)}
menuText W CCOfferDraw "Erbjud Remi" 0 {Skicka drag och erbjud Remi (inte via eMail)}
menuText W CCAcceptDraw "Acceptera Remi" 0 {Acceptera en erbjuden Remi (inte via eMail)}
menuText W CCNewMailGame "Nytt eMail-parti..." 0 {Starta ett nytt eMail-parti}
menuText W CCMailMove "Skicka Drag..." 0 {Skicka draget via eMail till motst�ndaren}
menuText W CCGamePage "Partisida..." 0 {Starta upp partiet via webl�saren}
menuText W CCEditCopy "Kopiera partilista till Clipbase" 0 {Kopiera partierna som CSV-lista till Clipbase}

# Options menu:
menuText W Options "Alternativ" 2
menuText W OptionsBoardGraphics "Rutor..." 0 {V�lj texturer f�r rutor}
translate W OptionsBGW {V�lj textur f�r rutor}
translate W OptionsBoardGraphicsText {V�lj grafikfiler f�r vita och svarta rutor:}
menuText W OptionsBoardNames "Spelarnamn..." 0 {Redigera spelares namn}
menuText W OptionsExport "Export" 0 {�ndra exportalternativ}
menuText W OptionsFonts "Typsnitt" 0 {�ndra typsnitt}
menuText W OptionsFontsRegular "Normal" 0 {�ndra det normala typsnittet}
menuText W OptionsFontsMenu "Menu" 0 {�ndra menytypsnittet}
menuText W OptionsFontsSmall "Liten" 0 {�ndra det lilla typsnittet}
menuText W OptionsFontsTiny "Tiny" 0 {Change the tiny font}
menuText W OptionsFontsFixed "Fixerad" 0 {�ndra det fixerade typsnittet}
menuText W OptionsGInfo "Partiinformation" 0 {Alternativ f�r partiinformation}
menuText W OptionsLanguage "Spr�k" 0 {V�lj spr�k}
menuText W OptionsMovesTranslatePieces "�vers�tt pj�ser" 0 {�vers�tt f�rsta bokstaven f�r pj�ser}
menuText W OptionsMovesHighlightLastMove "Markera senaste draget" 0 {Markera senaste draget}
menuText W OptionsMovesHighlightLastMoveDisplay "Visa" 0 {Visa senaste markerade draget}
menuText W OptionsMovesHighlightLastMoveWidth "Bredd" 0 {Tjockhet p� rad}
menuText W OptionsMovesHighlightLastMoveColor "F�rg" 0 {F�rg p� rad}
# ====== TODO To be translated ======
menuText W OptionsMovesHighlightLastMoveArrow "include Arrow" 0 {Include Arrow with Highlight}
menuText W OptionsMoves "Drag" 0 {Alternativ f�r dragangivelse}
menuText W OptionsMovesAnimate "F�rdr�jning vid manuellt spel" 1 \
  {Ange tid mellan varje drag n�r dragen g�rs automatiskt}
menuText W OptionsMovesDelay "F�rdr�jning vid automatspel..." 1 \
  {Ange f�rdr�jning mellan dragen n�r datorn spelar sj�lv}
menuText W OptionsMovesCoord "Koordinater" 0 \
  {Acceptera koordinater ("g1f3") vid dragangivelse}
menuText W OptionsMovesSuggest "Visa f�reslagna drag" 0 \
  {Visa/ D�lj f�reslagna drag}
menuText W OptionsShowVarPopup "Visa Variantf�nster" 0 {Starta/Avsluta visningen av ett Variantf�nster}  
menuText W OptionsMovesSpace "L�gg till mellanslag efter dragnummer" 0 {L�gg till mellanslag efter dragnummer}  
menuText W OptionsMovesKey "Tangentkomplettering" 0 \
  {Starta/ st�ng av dragkomplettering vid tangentinmatning}
menuText W OptionsMovesShowVarArrows "Visa pilar f�r variationer" 0 {V�xlar p�/av pilar som visar drag i variationer}
# ====== TODO To be translated ======
menuText W OptionsMovesGlossOfDanger "Color Coded Gloss of Danger" 0 {Turn on/off color coded gloss of danger}
menuText W OptionsNumbers "Talformat" 3 {V�lj hur tal visas}
menuText W OptionsTheme "Tema" 0 {�ndra utseende p� gr�nssnitt}
menuText W OptionsWindows "F�nster" 1 {F�nsteralternativ}
menuText W OptionsSounds "Ljud" 2 {Konfigurera ljud f�r att annonsera drag}
# ====== TODO To be translated ======
menuText W OptionsResources "Resources..." 0 {Choose resource files and folders}
menuText W OptionsWindowsDock "Dockningsf�nster" 0 {Dockningsf�nster}
menuText W OptionsWindowsSaveLayout "Spara layout" 0 {Sparar layout}
menuText W OptionsWindowsRestoreLayout "�terst�ll layout" 0 {�terst�ller layout}
menuText W OptionsWindowsShowGameInfo "Visa partiinformation" 0 {Visar partiinformation}
menuText W OptionsWindowsAutoLoadLayout "Automatiskt �ppna f�rsta layouten" 0 {�ppnar automatiskt f�rsta layouten vid uppstart}
menuText W OptionsECO "Ladda ECO fil" 7 {Ladda ECO-klassificeringen vid start}
menuText W OptionsSpell "Ladda R�ttstavningsfil" 7 \
  {Ladda r�ttstavningsfilen vid start}
menuText W OptionsTable "Katalog f�r slutspelsdatabaser" 0 \
  {V�lj en fil som inneh�ller en slutspelsdatabas; alla �vriga filer i samma katalog kommer att anv�ndas}
menuText W OptionsRecent "Senast anv�nda filer..." 16 \
  {�ndra antalet senast anv�nda filer som visas i Arkivmenyn} 
menuText W OptionsBooksDir "�ppningsbokskatalog" 0 {Anger �ppningsbokskatalogen}
menuText W OptionsTacticsBasesDir "Taktikbaskatalog" 0 {Anger Taktikbaskatalog (f�r tr�ning)}
# ====== TODO To be translated ======
menuText W OptionsPhotosDir "Photos directory" 0 {Sets the photos bases directory}
# ====== TODO To be translated ======
menuText W OptionsThemeDir "Theme(s) File:"  0 { Load a GUI theme package file }
menuText W OptionsSave "Spara alternativ" 7 \
  "Spara alla alternativ till en inst�llningsfil"
menuText W OptionsAutoSave "Autospara vid avslut" 1 \
  {Spara alla alternativ n�r du avslutar Scid}

# Help menu:
menuText W Help "Hj�lp" 0
menuText W HelpContents "Inneh�ll" 0 {Visa inneh�ll} 
menuText W HelpIndex "Index" 0 {Hj�lpsystemets indexsida}
menuText W HelpGuide "Snabbguide" 0 {Visa snabbguiden}
menuText W HelpHints "Tips" 0 {Visa tips}
menuText W HelpContact "Kontaktinformation" 0 {Visa kontaktinformation}
menuText W HelpTip "Dagens tips" 0 {Anv�ndbara Scid tips}
menuText W HelpStartup "Startf�nster" 5 {Visa startf�nstret}
menuText W HelpAbout "Om Scid" 0 {Information om Scid}

# Game info box popup menu:
menuText W GInfoHideNext "D�lj n�sta drag" 0
menuText W GInfoMaterial "Visa materialv�rden" 0
menuText W GInfoFEN "Visa FEN" 5
menuText W GInfoMarks "Visa f�rgade f�lt och pilar" 22 
menuText W GInfoWrap "Radbrytning" 0
menuText W GInfoFullComment "Visa fullst�ndiga kommentarer" 18
menuText W GInfoPhotos "Visa bilder" 5 ;
menuText W GInfoTBNothing "Slutspelsdatabaser: inget" 20
menuText W GInfoTBResult "Slutspelsdatabaser: endast resultat" 28
menuText W GInfoTBAll "Slutspelsdatabaser: resultat och b�sta drag" 33
menuText W GInfoDelete "�terta/Radera detta parti" 0
menuText W GInfoMark "(Av-)Markera detta parti" 5
menuText W GInfoInformant "Konfigurera Informant-parametrar" 0

# General buttons:
translate W Back {Tillbaka}
translate W Browse {Bl�ddra}
translate W Cancel {Avbryt}
translate W Continue {Forts�tt}
translate W Clear {Rensa}
translate W Close {St�ng}
translate W Contents {Inneh�ll}
translate W Defaults {Standard}
translate W Delete {Radera}
translate W Graph {Diagram}
translate W Help {Hj�lp}
translate W Import {Importera}
translate W Index {Index}
translate W LoadGame {Ladda parti}
translate W BrowseGame {Bl�ddra genom partier}
translate W MergeGame {Sl� samman parti}
translate W MergeGames {Sl� samman partier}
translate W Preview {F�rhandsgranska}
translate W Revert {�ngra inmatning}
translate W Save {Spara}
translate W Search {S�k}
translate W Stop {Stoppa}
translate W Store {Spara}
translate W Update {Uppdatera}
translate W ChangeOrient {�ndra f�nstrets orientering}
translate W ShowIcons {Visa Ikoner} ;# ***
translate W None {Ingen}
translate W First {F�rsta}
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
translate W Both {B�da}
translate W King {Kung}
translate W Queen {Dam}
translate W Rook {Torn}
translate W Bishop {L�pare}
translate W Knight {Springare}
translate W Pawn {Bonde}
translate W White {Vit}
translate W Black {Svart}
translate W Player {Spelare}
translate W Rating {Rating}
translate W RatingDiff {Ratingskillnad (Vit - Svart)}
translate W AverageRating {Medelrating}
translate W Event {Evenemang}
translate W Site {Plats}
translate W Country {Land}
translate W IgnoreColors {Ignorera f�rger}
translate W Date {Datum}
translate W EventDate {Evenemangsdatum}
translate W Decade {Decennium}
translate W Year {�r}
translate W Month {M�nad}
translate W Months {Januari Februari Mars April Maj Juni Juli Augusti September Oktober November December}
translate W Days {S�n M�n Tis Ons Tor Fre L�r}
translate W YearToToday {Idag}
# ====== TODO To be translated ======
translate W YearToTodayTooltip {Set date from 1 year back to today}
translate W Result {Resultat}
translate W Round {Rond}
translate W Length {L�ngd}
translate W ECOCode {ECO kod}
translate W ECO {ECO}
translate W Deleted {Raderad}
translate W SearchResults {S�kresultat}
translate W OpeningTheDatabase {�ppnar databas}
translate W Database {Databas}
translate W Filter {Filter}
translate W noGames {inga partier}
translate W allGames {alla partier}
translate W empty {tom}
translate W clipbase {Clipbase}
translate W score {resultat}
translate W StartPos {Utg�ngsst�llning}
translate W Total {Totalt}
translate W readonly {bara l�sbar} ;# ***

# Standard error messages:
translate W ErrNotOpen {Databasen �r inte �ppen.}
translate W ErrReadOnly {Databasen �r skrivskyddad. Du kan inte �ndra i den.}
translate W ErrSearchInterrupted {S�kningen avbr�ts; resultatet �r inte fullst�ndigt.}

# Game information:
translate W twin {dubblett}
translate W deleted {raderad}
translate W comment {kommentar}
translate W hidden {dold}
translate W LastMove {Senaste draget}
translate W NextMove {N�sta}
translate W GameStart {Utg�ngsst�llning}
translate W LineStart {Varianten b�rjar}
translate W GameEnd {Slutst�llning}
translate W LineEnd {Varianten slut}

# Player information:
translate W PInfoAll {Resultat f�r <b>alla</b> partier}
translate W PInfoFilter {Resultat f�r <b>filtrerade</b> partier}
translate W PInfoAgainst {Resultat mot}
translate W PInfoMostWhite {De vanligaste �ppningarna som vit}
translate W PInfoMostBlack {De vanligaste �ppningarna som svart}
translate W PInfoRating {Ratinghistoria}
translate W PInfoBio {Biografisk information}
translate W PInfoEditRatings {Redigera rating} 
# ====== TODO To be translated ======
translate W PInfoEloFile {File}

# Tablebase information:
translate W Draw {Remi}
translate W stalemate {patt}
translate W withAllMoves {med alla drag}
translate W withAllButOneMove {med alla drag utom ett}
translate W with {med}
translate W only {bara}
translate W lose {f�rlust}
translate W loses {f�rluster}
translate W allOthersLose {alla andra drag f�rlorar}
translate W matesIn {med matt i}
translate W hasCheckmated {har satt matt}
translate W longest {l�ngst}
translate W WinningMoves {Vinstdrag} 
translate W DrawingMoves {Remidrag} 
translate W LosingMoves {F�rlustdrag} 
translate W UnknownMoves {Ok�nt resultat} 
# ====== TODO To be translated ======
translate W SideLongest {Side    Longest    %     %     %\n}
# ====== TODO To be translated ======
translate W toNoveMate {to move   mate    Win  Draw  Loss\n}
# ====== TODO To be translated ======
translate W NoSummary {\nNo summary for this tablebase.}
# ====== TODO To be translated ======
translate W MutualZugzwang {Mutual zugzwangs: }
# ====== TODO To be translated ======
translate W SelectetZugzwang {\nSelected zugzwang positions:}
# ====== TODO To be translated ======
translate W WdrawBloss {White draws, Black loses:}
# ====== TODO To be translated ======
translate W BdrawWloss {Black draws, White loses:}
# ====== TODO To be translated ======
translate W AllLoss {" Whoever moves loses:     " }

# Tip of the day:
translate W Tip {Tips}
translate W TipAtStartup {Tips vid start}

# Tree window menus:
menuText W TreeFile "Fil" 0
menuText W TreeFileFillWithBase "Fyll Cache med databas" 0 {Fyll Cachefilen med alla partier i den aktuella databasen}
menuText W TreeFileFillWithGame "Fyll Cache med parti" 0 {Fyll Cachefilen med aktuellt parti i den aktuella databasen}
menuText W TreeFileSetCacheSize "Cachestorlek" 0 {Ange Cachestorleken}
menuText W TreeFileCacheInfo "Cacheinformation" 0 {F� information om Cacheanv�ndning}
menuText W TreeFileSave "Spara cachefil" 0 {Spara tr�dcache (*.stc)-filen}
menuText W TreeFileFill "Fyll cachefil" 0 \
 {Fyll cachefilen med vanliga �ppningar}
menuText W TreeFileBest "Lista b�sta partier" 0 {Visa lista �ver de b�sta partierna i tr�det}
menuText W TreeFileGraph "Diagramf�nster" 0 {Visa diagrammet f�r denna gren i tr�det}
menuText W TreeFileCopy "Kopiera tr�d till urklipp" 1 \
  {Kopierar tr�drelaterad statistik till urklipp}
menuText W TreeFileClose "St�ng tr�df�nstret" 0 {St�ng tr�df�nstret}
menuText W TreeMask "S�kmask" 0
menuText W TreeMaskNew "Ny" 0 {Ny s�kmask}
menuText W TreeMaskOpen "�ppna" 0 {�ppna s�kmask}
menuText W TreeMaskOpenRecent "�ppna senaste" 0 {�ppna senaste s�kmasken}
menuText W TreeMaskSave "Spara" 0 {Spara s�kmask}
menuText W TreeMaskClose "St�ng" 0 {St�ng s�kmask}
menuText W TreeMaskFillWithGame "Fyll med parti" 0 {Fyll s�kmask med parti}
menuText W TreeMaskFillWithBase "Fyll med databas" 0 {Fyll s�kmask med alla partier i databasen}
menuText W TreeMaskInfo "Info om s�kmask" 0 {Visa statistik f�r aktuell s�kmask}
menuText W TreeMaskDisplay "Visa s�kmaskkarta" 0 {Visa s�kmaskdata i tr�dform}
menuText W TreeMaskSearch "S�k" 0 {S�k i aktuell s�kmask}
menuText W TreeSort "Sortera" 0
menuText W TreeSortAlpha "Alfabetiskt" 0
menuText W TreeSortECO "ECO kod" 0
menuText W TreeSortFreq "Frekvens" 0
menuText W TreeSortScore "Resultat" 0
menuText W TreeOpt "Alternativ" 0
menuText W TreeOptSlowmode "L�ngsam mod" 0 {L�ngsam mod f�r uppdateringar (h�g noggrannhet)}
menuText W TreeOptFastmode "Snabb mod" 0 {Snabb mod f�r uppdateringar (ingen dragtranspositionering)}
menuText W TreeOptFastAndSlowmode "Snabb och l�ngsam mod" 0 {Snabb mod sedan l�ngsam mod f�r uppdateringar}
menuText W TreeOptStartStop "Automatisk uppdatering" 0 {V�xlar automatisk uppdatering av tr�df�nstret}
menuText W TreeOptLock "L�s" 0 {L�s/ l�s upp tr�det f�r den aktuella databasen}
menuText W TreeOptTraining "Tr�na" 0 {Starta/ st�ng av tr�ningsl�ge}
menuText W TreeOptAutosave "Spara cache filen automatiskt" 0 \
  {Spara cachefilen automatiskt n�r tr�df�nstret st�ngs}
menuText W TreeHelp "Hj�lp" 0
menuText W TreeHelpTree "Tr�dhj�lp" 0
menuText W TreeHelpIndex "Hj�lpindex" 0
translate W SaveCache {Spara cache}
translate W Training {Tr�na}
translate W LockTree {L�s}
translate W TreeLocked {L�st}
translate W TreeBest {B�st}
translate W TreeBestGames {B�sta partier i tr�det}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate W TreeTitleRow \
  { Drag      ECO     Frekvens      Res.    Elo~  Niv�  �r~   %Remi} 
translate W TreeTotal {TOTALT} 
translate W DoYouWantToSaveFirst {Vill du spara f�rst}
translate W AddToMask {L�gg till i s�kmask}
translate W RemoveFromMask {Ta bort fr�n s�kmask}
translate W AddThisMoveToMask {L�gg till deta drag i s�kmask}
translate W SearchMask {S�k i s�kmask}
translate W DisplayMask {Visa s�kmask}
translate W Nag {NAG-kod}
translate W Marker {Markera}
translate W Include {Inkludera}
translate W Exclude {Exkludera}
translate W MainLine {Huvudvariant}
translate W Bookmark {Bokm�rke}
translate W NewLine {Ny variant}
translate W ToBeVerified {Att bli verifierad}
translate W ToTrain {Att tr�na}
translate W Dubious {Tveksam}
translate W ToRemove {Att ta bort}
translate W NoMarker {Ingen markering}
translate W ColorMarker {F�rg}
translate W WhiteMark {Vit}
translate W GreenMark {Gr�n}
translate W YellowMark {Gul}
translate W BlueMark {Bl�}
translate W RedMark {R�d}
translate W CommentMove {Kommentera drag}
translate W CommentPosition {Kommentera position}
translate W AddMoveToMaskFirst {L�gg till drag till s�kmask f�rst}
translate W OpenAMaskFileFirst {�ppna en s�kmaskmaskfil f�rst}
translate W Positions {Positioner}
translate W Moves {Drag}

# Finder window:
menuText W FinderFile "Fil" 0
menuText W FinderFileSubdirs "S�k i underkataloger" 0
menuText W FinderFileClose "St�ng Fils�karen" 0
menuText W FinderSort "Sortera" 0
menuText W FinderSortType "Typ" 0
menuText W FinderSortSize "Storlek" 0
menuText W FinderSortMod "F�r�ndrad" 0
menuText W FinderSortName "Namn" 0
menuText W FinderSortPath "S�kv�g" 0
menuText W FinderTypes "Typer" 0
menuText W FinderTypesScid "Sciddatabaser" 0
menuText W FinderTypesOld "Sciddatabaser i �ldre format" 0
menuText W FinderTypesPGN "PGN-filer" 0
menuText W FinderTypesEPD "EPD-filer" 0
menuText W FinderTypesRep "�ppningsfiler" 0
menuText W FinderHelp "Hj�lp" 0
menuText W FinderHelpFinder "Hj�lp f�r Fils�karen" 0
menuText W FinderHelpIndex "Hj�lpindex" 0
translate W FileFinder {Fils�karen}
translate W FinderDir {Katalog}
translate W FinderDirs {Kataloger}
translate W FinderFiles {Filer}
translate W FinderUpDir {upp}
translate W FinderCtxOpen {�ppna}
translate W FinderCtxBackup {Spara}
translate W FinderCtxCopy {Kopiera}
translate W FinderCtxMove {Flytta}
translate W FinderCtxDelete {Ta bort}

# Player finder:
menuText W PListFile "Fil" 0
menuText W PListFileUpdate "Uppdatera" 0
menuText W PListFileClose "St�ng spelarf�rteckningen" 1 
menuText W PListSort "Sortera" 0
menuText W PListSortName "Namn" 0
menuText W PListSortElo "Elo" 0
menuText W PListSortGames "Partier" 0
menuText W PListSortOldest "�ldst" 0 
menuText W PListSortNewest "Yngst" 0

# Tournament finder:
menuText W TmtFile "Fil" 0
menuText W TmtFileUpdate "Uppdatera" 0
menuText W TmtFileClose "St�ng turneringshanteraren" 0
menuText W TmtSort "Sortera" 0
menuText W TmtSortDate "Datum" 0
menuText W TmtSortPlayers "Spelare" 0
menuText W TmtSortGames "Partier" 0
menuText W TmtSortElo "Elo" 0
menuText W TmtSortSite "Plats" 0
menuText W TmtSortEvent "Evenemang" 1
menuText W TmtSortWinner "Vinnare" 0
translate W TmtLimit "Listbegr�nsningar"
translate W TmtMeanElo "L�gsta snitt Elo"
translate W TmtNone "Inga turneringar hittades."

# Graph windows:
menuText W GraphFile "Fil" 0
menuText W GraphFileColor "Spara som Postscript (i f�rg)" 8
menuText W GraphFileGrey "Spara som Postscript (i gr�skala)" 8
menuText W GraphFileClose "St�ng f�nster" 6
menuText W GraphOptions "Alternativ" 0
menuText W GraphOptionsWhite "Vit" 0
menuText W GraphOptionsBlack "Svart" 0
menuText W GraphOptionsBoth "B�da" 1
menuText W GraphOptionsPInfo "Spelarinformation" 0
# ====== TODO To be translated ======
menuText W GraphOptionsEloFile "Elo from rating file" 0
# ====== TODO To be translated ======
menuText W GraphOptionsEloDB "Elo from database" 0
translate W GraphFilterTitle "Filterdiagram: antal per 1000 partier"
translate W GraphAbsFilterTitle "Filtergraf: frekvens f�r partierna"
translate W ConfigureFilter {Konfigurera X-axlar f�r �r, Rating och Drag}
translate W FilterEstimate "Uppskatta"
translate W TitleFilterGraph "Scid: Filtergraf"

# Analysis window:
translate W AddVariation {L�gg till variation}
translate W AddAllVariations {L�gg till alla variationer}
translate W AddMove {L�gg till drag}
translate W Annotate {Kommentera}
translate W ShowAnalysisBoard {Visa Analysbr�de}
translate W ShowInfo {Visa schackmotorinformation}
translate W FinishGame {Avsluta parti}
translate W StopEngine {Stoppa schackmotor}
translate W StartEngine {Starta schackmotor}
translate W LockEngine {L�s schackmotor vid nuvarande position}
translate W AnalysisCommand {Analysera}
translate W PreviousChoices {F�reg�ende val}
translate W AnnotateTime {Ange tid mellan drag i sekunder}
translate W AnnotateWhich {L�gg till variationer}
translate W AnnotateAll {F�r b�da sidors drag}
translate W AnnotateAllMoves {Kommentera alla drag}
translate W AnnotateWhite {Endast vits drag}
translate W AnnotateBlack {Endast svarts drag}
translate W AnnotateBlundersOnly {N�r partidraget �r en uppenbar blunder}
translate W AnnotateBlundersOnlyScoreChange {Analysen rapporterar blunder, med v�rderingsf�r�ndringar fr�n/till: }
translate W BlundersThreshold {Tr�skelv�rde}
translate W ScoreAllMoves {Score all moves}
translate W LowPriority {K�r som l�gprioriterad process} 
translate W ClickHereToSeeMoves {Klicka h�r f�r att se drag}
translate W ConfigureInformant {Informant-parametrar}
translate W Informant!? {Intressant drag}
translate W Informant? {D�ligt drag}
translate W Informant?? {Blunder}
translate W Informant?! {Tveksamt drag}
translate W Informant+= {Vit har en mindre f�rdel}
translate W Informant+/- {Vit har en liten f�rdel}
translate W Informant+- {Vit har en avg�rande f�rdel}
translate W Informant++- {Partiet anses vara vunnet}
translate W Book {Bok}
translate W OtherBookMoves {Motst�ndarens bok}
translate W OtherBookMovesTooltip {Drag som motst�ndaren har ett svar p�}

# Analysis Engine open dialog:
translate W EngineList {Lista �ver schackprogram}
translate W EngineName {Namn}
translate W EngineCmd {Startkommando}
translate W EngineArgs {Parametrar} 
translate W EngineDir {Katalog}
translate W EngineElo {Elo}
translate W EngineTime {Datum}
translate W EngineNew {Ny}
translate W EngineEdit {Redigera}
translate W EngineRequired {Fet stil indikerar obligatoriska f�lt; �vriga f�lt �r frivilliga} 

# PGN window menus:
menuText W PgnFile "Fil" 0
menuText W PgnFileCopy "Kopiera partiet till Clipbase" 0
menuText W PgnFilePrint "Skriv ut till..." 0
menuText W PgnFileClose "St�ng PGN-f�nster" 0
menuText W PgnOpt "Presentation" 0
menuText W PgnOptColor "F�rg" 0
menuText W PgnOptShort "Kort (3-raders) huvud" 0
menuText W PgnOptSymbols "Symbolbaserad kommentar" 1
menuText W PgnOptIndentC "Indragna kommentarer" 0
menuText W PgnOptIndentV "Indragna variationer" 7
menuText W PgnOptColumn "Spaltstil (ett drag per rad)" 1
menuText W PgnOptSpace "Utrymme efter dragnummer" 1
menuText W PgnOptStripMarks "Avl�gsna koder f�r f�rgade f�lt och pilar" 1 
menuText W PgnOptBoldMainLine "Anv�nd Fet Text f�r Huvudvariationsdrag" 4
menuText W PgnColor "F�rger" 0
menuText W PgnColorHeader "Huvud..." 0
menuText W PgnColorAnno "Noteringar..." 0
menuText W PgnColorComments "Kommentarer..." 0
menuText W PgnColorVars "Variationer..." 0
menuText W PgnColorBackground "Bakgrund..." 0
menuText W PgnColorMain "Huvudvariation..." 0
menuText W PgnColorCurrent "Aktuellt drag bakgrund..." 1
menuText W PgnHelp "Hj�lp" 0
menuText W PgnHelpPgn "PGN-hj�lp" 0
menuText W PgnHelpIndex "Index" 0
translate W PgnWindowTitle {PGN-version av partiet %u} 

# Crosstable window menus:
menuText W CrosstabFile "Fil" 0
menuText W CrosstabFileText "Skriv ut till textfil..." 9
menuText W CrosstabFileHtml "Skriv ut till HTML-fil..." 9
menuText W CrosstabFileLaTeX "Skriv ut till LaTeX-fil..." 9
menuText W CrosstabFileClose "St�ng resultattabellsf�nstret" 0
menuText W CrosstabEdit "Redigera" 0
menuText W CrosstabEditEvent "Evenemang" 0
menuText W CrosstabEditSite "Plats" 0
menuText W CrosstabEditDate "Datum" 0
menuText W CrosstabOpt "Presentation" 0
menuText W CrosstabOptAll "Alla-m�ter-alla" 0
menuText W CrosstabOptSwiss "Schweizer" 0
menuText W CrosstabOptKnockout "Knock Out" 0
menuText W CrosstabOptAuto "Auto" 1
menuText W CrosstabOptAges "�lder i �r" 8
menuText W CrosstabOptNats "Nationalitet" 0
menuText W CrosstabOptRatings "Rating" 0
menuText W CrosstabOptTitles "Titlar" 0
menuText W CrosstabOptBreaks "Tie-break po�ng" 4
menuText W CrosstabOptDeleted "Inkludera raderade partier" 8 
menuText W CrosstabOptColors "F�rg (endast Schweizer)" 0
menuText W CrosstabOptColumnNumbers "Numrerade kolumner (Endast alla-mot-alla)" 2 
menuText W CrosstabOptGroup "Gruppresultat" 0
menuText W CrosstabSort "Sortera" 0
menuText W CrosstabSortName "Namn" 0
menuText W CrosstabSortRating "Rating" 0
menuText W CrosstabSortScore "Resultat" 0
menuText W CrosstabColor "F�rg" 0
menuText W CrosstabColorPlain "Ren text" 0
menuText W CrosstabColorHyper "Hypertext" 0
menuText W CrosstabHelp "Hj�lp" 0
menuText W CrosstabHelpCross "Hj�lp f�r resultattabell" 0
menuText W CrosstabHelpIndex "Hj�lpindex" 0
translate W SetFilter {Best�m filter}
translate W AddToFilter {Ut�ka filter}
translate W Swiss {Schweizer}
translate W Category {Kategori} 

# Opening report window menus:
menuText W OprepFile "Fil" 0
menuText W OprepFileText "Skriv ut till textfil..." 9
menuText W OprepFileHtml "Skriv ut till HTML-fil..." 9
menuText W OprepFileLaTeX "Skriv ut till LaTeX-fil..." 9
menuText W OprepFileOptions "Alternativ..." 0
menuText W OprepFileClose "St�ng rapportf�nstret" 0
menuText W OprepFavorites "Favoriter" 1 
menuText W OprepFavoritesAdd "L�gg till rapport..." 0 
menuText W OprepFavoritesEdit "Redigera favoritrapport..." 0 
menuText W OprepFavoritesGenerate "Skapa rapport..." 0 
menuText W OprepHelp "Hj�lp" 0
menuText W OprepHelpReport "Hj�lp f�r �ppningsrapporter" 0
menuText W OprepHelpIndex "Hj�lpindex" 0

# Header search:
translate W HeaderSearch {S�k i partihuvud}
translate W EndSideToMove {Sida vid draget vid slutet av partiet}
translate W GamesWithNoECO {Partier utan ECO-kod?}
translate W GameLength {Partil�ngd}
translate W FindGamesWith {Hitta flaggade partier}
translate W StdStart {Normal utg�ngsst�llning}
translate W Promotions {F�rvandlingar}
translate W Comments {Kommentarer}
translate W Variations {Variationer}
translate W Annotations {Noteringar}
translate W DeleteFlag {Raderingsflagga}
translate W WhiteOpFlag {Vits �ppning}
translate W BlackOpFlag {Svarts �ppning}
translate W MiddlegameFlag {Mittspel}
translate W EndgameFlag {Slutspel}
translate W NoveltyFlag {Nyhet}
translate W PawnFlag {Bondestruktur}
translate W TacticsFlag {Taktiska st�llningar}
translate W QsideFlag {Damflygelsinitiativ}
translate W KsideFlag {Kungsflygelsinitiativ}
translate W BrilliancyFlag {Utm�rkt parti}
translate W BlunderFlag {Borts�ttningar}
translate W UserFlag {Anv�ndare}
translate W PgnContains {PGN inneh�ller text}
translate W Annotator {Kommentator}
translate W Cmnts {Bara kommenterade partier}

# Game list window:
translate W GlistNumber {Nummer}
translate W GlistWhite {Vit}
translate W GlistBlack {Svart}
translate W GlistWElo {Elo, vit}
translate W GlistBElo {Elo, svart}
translate W GlistEvent {Evenemang}
translate W GlistSite {Plats}
translate W GlistRound {Rond}
translate W GlistDate {Datum}
translate W GlistYear {�r}
translate W GlistEDate {Startdatum}
translate W GlistResult {Resultat}
translate W GlistLength {L�ngd}
translate W GlistCountry {Land}
translate W GlistECO {ECO}
translate W GlistOpening {�ppning}
translate W GlistEndMaterial {Slutmaterial}
translate W GlistDeleted {Raderad}
translate W GlistFlags {Flaggor}
translate W GlistVars {Variationer}
translate W GlistComments {Kommentarer}
translate W GlistAnnos {Noteringar}
translate W GlistStart {Start}
translate W GlistGameNumber {Partinummer}
translate W GlistAverageElo {Medel-Elo}
translate W GlistRating {Rating}
translate W GlistFindText {S�k text}
translate W GlistMoveField {Drag}
translate W GlistEditField {Konfiguration}
translate W GlistAddField {L�gg till}
translate W GlistDeleteField {Ta bort}
translate W GlistWidth {Bredd}
translate W GlistAlign {Justering}
translate W GlistAlignL {Justera: v�nster}
translate W GlistAlignR {Justera: h�ger}
translate W GlistAlignC {Justera: centrera}
translate W GlistColor {F�rg}
translate W GlistSep {Separator}
translate W GlistCurrentSep {-- Aktuell --}
translate W GlistNewSort {Ny}
translate W GlistAddToSort {L�gg till}
translate W GsortSort {Sortera...}
translate W GsortDate {Datum}
translate W GsortYear {�r}
translate W GsortEvent {Evenemang}
translate W GsortSite {Plats}
translate W GsortRound {Runda}
translate W GsortWhiteName {Vits namn}
translate W GsortBlackName {Svarts namn}
translate W GsortECO {ECO}
translate W GsortResult {Resultat}
translate W GsortMoveCount {Antal drag}
translate W GsortAverageElo {Medel-Elo}
translate W GsortCountry {Land}
translate W GsortDeleted {Borttagen}
translate W GsortEventDate {Evenemangsdatum}
translate W GsortWhiteElo {Vits Elo}
translate W GsortBlackElo {Svarts Elo}
translate W GsortComments {Kommentarer}
translate W GsortVariations {Variationer}
translate W GsortNAGs {Kommentarssymboler}
translate W GsortAscending {Stigande}
translate W GsortDescending {Sjunkande}
translate W GsortAdd {L�gg till}
translate W GsortStore {Spara}
translate W GsortLoad {�ppna}
translate W GlistRemoveThisGameFromFilter  {Ta bort detta parti fr�n Filter}
translate W GlistRemoveGameAndAboveFromFilter  {Ta bort parti (och alla ovanf�r det) fr�n Filter}
translate W GlistRemoveGameAndBelowFromFilter  {Ta bort parti (och alla nedanf�r det) fr�n Filter}
translate W GlistDeleteGame {Ta tillbaka detta parti} 
translate W GlistDeleteAllGames {Ta bort alla partier i filtret} 
translate W GlistUndeleteAllGames {Ta tillbaka alla partier i filtret} 
translate W GlistMergeGameInBase {L�gg till parti i annan databas} 

# Maintenance window:
translate W DatabaseName {Databasnamn:}
translate W TypeIcon {Ikontyp:}
translate W NumOfGames {Partier:}
translate W NumDeletedGames {Raderade partier:}
translate W NumFilterGames {Partier i filter:}
translate W YearRange {Tidsperiod:}
translate W RatingRange {Ratingintervall:}
translate W Description {Beskrivning} 
translate W Flag {Flagga}
translate W CustomFlags {Anpassade flaggor}
translate W DeleteCurrent {Ta bort aktuellt parti}
translate W DeleteFilter {Ta bort partierna i filtret}
translate W DeleteAll {Ta bort alla partier}
translate W UndeleteCurrent {�terta aktuellt parti}
translate W UndeleteFilter {�terta partierna i filtret}
translate W UndeleteAll {�terta alla partier}
translate W DeleteTwins {Ta bort dubbletter}
translate W MarkCurrent {Markera aktuellt parti}
translate W MarkFilter {Markera partierna i filtret}
translate W MarkAll {Markera alla partier}
translate W UnmarkCurrent {Avmarkera aktuellt parti}
translate W UnmarkFilter {Avmarkera partierna i filtret}
translate W UnmarkAll {Avmarkera alla partier}
translate W Spellchecking {R�ttstava}
translate W Players {Spelare}
translate W Events {Evenemang}
translate W Sites {Platser}
translate W Rounds {Ronder}
translate W DatabaseOps {Databashantering}
translate W ReclassifyGames {ECO-klassificera partier}
translate W CompactDatabase {Komprimera databasen}
translate W SortDatabase {Sortera databasen}
translate W AddEloRatings {L�gg till Elorating}
translate W AutoloadGame {Ladda partinummer automatiskt}
translate W StripTags {Avl�gsna PGN-taggar}
translate W StripTag {Avl�gsna taggar}
translate W Cleaner {Snygga till databasen}
translate W CleanerHelp {
Databasst�daren i Scid genomf�r allt det underh�ll av databasen du v�ljer nedan p� den aktiva databasen.

De nuvarande inst�llningarna i ECO-klassificering och Radera dubbletter kommer att appliceras om du v�ljer dessa �tg�rder.
}
translate W CleanerConfirm {
N�r du v�l startat Databasst�daren kan du inte avbryta den!

P� en stor databas kan detta ta ett bra tag. Tids�tg�ngen beror p� valda �tg�rder och deras inst�llningar.

�r du s�ker p� att du vill p�b�rja databasunderh�llet nu?
}
translate W TwinCheckUndelete {att v�xla; "u" tar tillbaka b�da)}
translate W TwinCheckprevPair {Tidigare par}
translate W TwinChecknextPair {N�sta par}
translate W TwinChecker {Scid: Dublettpartikontrollerare}
translate W TwinCheckTournament {Partier i turnering:}
translate W TwinCheckNoTwin {Ingen dublett  }
translate W TwinCheckNoTwinfound {Ingen dublett detekterades f�r detta parti.\nF�r att visa dubletter med detta f�nster, m�ste du f�rst anv�nda "Ta bort dublettpartier..."-funktionen. }
translate W TwinCheckTag {Dela taggar...}
translate W TwinCheckFound1 {Scid hittade $result dublettpartier}
translate W TwinCheckFound2 { och ange deras borttagningsflaggor}
translate W TwinCheckNoDelete {Det finns inga partier i denna databas att ta bort.}
translate W TwinCriteria1 { Dina inst�llningar f�r att hitta dublettpartier �r potentiellt sannorlika att\norsaka att icke-dublettpartier med liknande drag blir markerade som dubletter.}
translate W TwinCriteria2 {Det �r rekommenderat att om du v�ljer "Nej" f�r "samma drag" och att du v�ljer "Ja" f�r F�rger, Evenemang, Plats, Runda, �r och M�nads inst�llningar.\nVill du forts�tta och ta bort dubletter �nd�? }
translate W TwinCriteria3 {Det �r rekommenderat att du specificerar "Ja" f�r �tminstonde tv� av "samma plats", "samma runda" och "samma �r" inst�llningar.\nVill du forts�tta och ta bort dubletter �nd�?}
translate W TwinCriteriaConfirm {Scid: Bekr�fta dublettinst�llningar}
translate W TwinChangeTag "�ndra f�ljande partitaggar:\n\n"
translate W AllocRatingDescription "Detta kommando kommer att anv�nda den aktuella stavningskontrollfilen f�r att l�gga till Elo-rating till partier i denna databas. D�r en spelare inte har en aktuell rating men hans/hennes rating vid tiden f�r partiet �r listat i stavningskontrollfilen, kommer denna rating att l�ggas till."
translate W RatingOverride "Skriv �ver existerande inte-noll rating?"
translate W AddRatings "L�gg till rating till:"
translate W AddedRatings {Scid lade till $r Elo-ratingar i $g partier.}
translate W NewSubmenu "Ny undermeny"

# Comment editor:
translate W AnnotationSymbols  {Symboler:}
translate W Comment {Kommentar:}
translate W InsertMark {Infoga symbol} 
translate W InsertMarkHelp {
Infoga/ta bort markering: V�lj f�rg, typ av markering samt ruta.
Infoga/ta bort pil: H�ger-klicka tv� rutor.
}

# Nag buttons in comment editor:
translate W GoodMove {Bra drag}
translate W PoorMove {D�ligt drag}
translate W ExcellentMove {Utm�rkt drag}
translate W Blunder {Blunder}
translate W InterestingMove {Intressant drag}
translate W DubiousMove {Tveksamt drag}
translate W WhiteDecisiveAdvantage {Vit har en avg�rande f�rdel}
translate W BlackDecisiveAdvantage {Svart har en avg�rande f�rdel}
translate W WhiteClearAdvantage {Vit har en klar f�rdel}
translate W BlackClearAdvantage {Svart har en klar f�rdel}
translate W WhiteSlightAdvantage {Vit har en liten f�rdel}
translate W BlackSlightAdvantage {Svart har en liten f�rdel}
translate W Equality {J�mnvikt}
translate W Unclear {Oklar}
translate W Diagram {Diagram}

# Board search:
translate W BoardSearch {Positionss�kningar}
translate W FilterOperation {Hantering av aktuellt filter:}
translate W FilterAnd {AND (Restriktivt filter)}
translate W FilterOr {OR (Ackumulativt filter)}
translate W FilterIgnore {IGNORE (Anv�nd ej filter)}
translate W SearchType {S�ktyp:}
translate W SearchBoardExact {Exakt position (alla pj�ser p� samma rutor)}
translate W SearchBoardPawns {B�nder (samma material, alla b�nder p� samma rutor)}
translate W SearchBoardFiles {Filer (samma material, alla b�nder p� samma filer)}
translate W SearchBoardAny {Obest�mt (samma material, b�nder och pj�ser p� valfria rutor)}
translate W SearchInRefDatabase {S�k i databas}
translate W LookInVars {S�k i variationer}

# Material search:
translate W MaterialSearch {Materials�kning}
translate W Material {Material}
translate W Patterns {St�llningar}
translate W Zero {Inga/-en}
translate W Any {Flera}
translate W CurrentBoard {Aktuell st�llning}
translate W CommonEndings {Vanliga slutspel}
translate W CommonPatterns {Vanliga st�llningar}
translate W MaterialDiff {Skillnad i material}
translate W squares {rutor}
translate W SameColor {Samma f�rg}
translate W OppColor {Motsatt f�rg}
translate W Either {Antingen eller}
translate W MoveNumberRange {Dragintervall}
translate W MatchForAtLeast {Tr�ffa minst}
translate W HalfMoves {halvdrag}

# Common endings in material search:
translate W EndingPawns {Bondeslutspel}
translate W EndingRookVsPawns {Torn mot Bonde (B�nder)}
translate W EndingRookPawnVsRook {Torn och 1 Bonde mot Torn}
translate W EndingRookPawnsVsRook {Torn och Bonde (B�nder) mot Torn}
translate W EndingRooks {Torn mot Torn slutspel}
translate W EndingRooksPassedA {Torn mot Torn slutspel med en fri a-bonde}
translate W EndingRooksDouble {Dubbla Torn slutspel}
translate W EndingBishops {L�pare mot L�pare slutspel}
translate W EndingBishopVsKnight {L�pare mot Springare slutspel}
translate W EndingKnights {Springare mot Springare slutspel}
translate W EndingQueens {Dam mot Dam slutspel}
translate W EndingQueenPawnVsQueen {Dam och 1 Bonde mot Dam}
translate W BishopPairVsKnightPair {Tv� L�pare mot Tv� Springare mittspel}

# Common patterns in material search:
translate W PatternWhiteIQP {Vit Isolerad dambonde}
translate W PatternWhiteIQPBreakE6 {Vit Isolerad dambonde: d4-d5 brott mot e6}
translate W PatternWhiteIQPBreakC6 {Vit Isolerad dambonde: d4-d5 brott mot c6}
translate W PatternBlackIQP {Svart Isolerad dambonde}
translate W PatternWhiteBlackIQP {Vit Isolerad dambonde mot Svart Isolerad dambonde}
translate W PatternCoupleC3D4 {Vit c3+d4 Isolaterat Bondepar}
translate W PatternHangingC5D5 {Svart H�ngande B�nder p� c5 och d5}
translate W PatternMaroczy {Maroczy Center (med B�nder p� c4 och e4)}
translate W PatternRookSacC3 {Tornoffer p� c3}
translate W PatternKc1Kg8 {O-O-O mot O-O (Kc1 mot Kg8)}
translate W PatternKg1Kc8 {O-O mot O-O-O (Kg1 mot Kc8)}
translate W PatternLightFian {Ljus-Ruta Fianchetton (L�pare-g2 mot L�pare-b7)}
translate W PatternDarkFian {M�rk-Ruta Fianchetton (L�pare-b2 mot L�pare-g7)}
translate W PatternFourFian {Fyra Fianchetton (L�pare p� b2,g2,b7,g7)}

# Game saving:
translate W Today {Idag}
translate W ClassifyGame {Klassificera parti}

# Setup position:
translate W EmptyBoard {T�m br�det}
translate W InitialBoard {Utg�ngsst�llning}
translate W SideToMove {F�rg vid draget}
translate W MoveNumber {Antal drag}
translate W Castling {Rockad}
translate W EnPassantFile {En Passant fil}
translate W ClearFen {Rensa FEN}
translate W PasteFen {Klistra in FEN}
translate W SaveAndContinue {Spara och forts�tt}
translate W DiscardChangesAndContinue {Ignorera �ndringar\noch forts�tt}
translate W GoBack {G� tillbaka}

# Replace move dialog:
translate W ReplaceMove {Ers�tt drag}
translate W AddNewVar {L�gg till ny variation}
translate W NewMainLine {Ny huvudvariation}
translate W ReplaceMoveMessage {Det finns redan ett drag i denna st�llning.

Du kan ers�tta detta drag, och f�rlora samtliga f�ljande, eller l�gga till ditt drag som en ny variation.

(Om du st�nger av "Fr�ga f�re ers�tt drag" i Alternativ:Drag menyn slipper du denna fr�ga i framtiden.)}

# Make database read-only dialog:
translate W ReadOnlyDialog {Om du ger denna databas endast l�sbar kan du inte g�ra n�gra �ndringar i den.
Inga partier kan sparas eller ers�ttas, och du kan inte �ndra flaggor f�r raderbara partier.
Alla sorteringsinst�llningar eller ECO-klassificeringar kommer att vara tempor�ra.

Du kan g�ra den skrivbar igen genom att helt enkelt st�nga och �ppna den igen.

Vill du verkligen ange att databasen endast ska vara l�sbar?}

# Clear game dialog:
translate W ClearGameDialog {Detta parti har �ndrats.

Vill du verkligen forts�tta och f�rlora �ndringarna?
}

# Exit dialog:
translate W ExitDialog {Vill du verkligen avsluta Scid?}
translate W ExitUnsaved {De f�ljande databaserna har osparade f�r�ndringar. Om du avslutar nu, kommer dessa f�r�ndringar att g� f�rlorade.} 

# Import window:
translate W PasteCurrentGame {Klistra in aktuellt parti}
translate W ImportHelp1 {Ange eller klistra in ett parti i PGN-format i omr�det ovan.}
translate W ImportHelp2 {Eventuella felaktigheter kommer att anges h�r.}
translate W OverwriteExistingMoves {Skriv �ver existerande drag ?}

# ECO Browser:
translate W ECOAllSections {alla ECO avdelningar}
translate W ECOSection {ECO avdelning}
translate W ECOSummary {Sammanfattning f�r}
translate W ECOFrequency {Underkodsfrekvens f�r}

# Opening Report:
translate W OprepTitle {�ppningsrapport}
translate W OprepReport {Rapport}
translate W OprepGenerated {Skapad av}
translate W OprepStatsHist {Statistik och historik}
translate W OprepStats {Statistik}
translate W OprepStatAll {Rapporterade partier}
translate W OprepStatBoth {B�da med rating}
translate W OprepStatSince {Sedan}
translate W OprepOldest {De �ldsta partierna}
translate W OprepNewest {De yngsta partierna}
translate W OprepPopular {Aktuell popularitet}
translate W OprepFreqAll {Frekvens totalt:   }
translate W OprepFreq1   {Under det senaste �ret: }
translate W OprepFreq5   {Under de 5 senaste �ren: }
translate W OprepFreq10  {Under de 10 senaste �ren: }
translate W OprepEvery {en g�ng var %u parti}
translate W OprepUp {�kat %u%s gentemot samtliga �r}
translate W OprepDown {minskat %u%s gentemot samtliga �r}
translate W OprepSame {ingen f�r�ndring gentemot samtliga �r}
translate W OprepMostFrequent {Spelas mest av}
translate W OprepMostFrequentOpponents {Vanligaste motst�ndaren}
translate W OprepRatingsPerf {Rating och resultat}
translate W OprepAvgPerf {Genomsnittrating och resultat}
translate W OprepWRating {Vits rating}
translate W OprepBRating {Svarts rating}
translate W OprepWPerf {Vits resultat}
translate W OprepBPerf {Svarts resultat}
translate W OprepHighRating {Partierna med h�gst genomsnittsrating}
translate W OprepTrends {Resultattrender}
translate W OprepResults {L�ngd och frekvens}
translate W OprepLength {Partiets l�ngd}
translate W OprepFrequency {Frekvens}
translate W OprepWWins {Vita vinster: }
translate W OprepBWins {Svarta vinster: }
translate W OprepDraws {Remier:      }
translate W OprepWholeDB {Hela databasen}
translate W OprepShortest {Kortaste vinster}
# translate W OprepShortWhite {De kortaste vita vinsterna}
# translate W OprepShortBlack {De kortaste svarta vinsterna}
translate W OprepMovesThemes {Drag och teman}
translate W OprepMoveOrders {Dragordning f�r att n� rapportst�llningen}
translate W OprepMoveOrdersOne \
  {St�llningen n�ddes bara genom en dragordning:}
translate W OprepMoveOrdersAll \
  {Det fanns %u dragordningar som ledde fram denna st�llning:}
translate W OprepMoveOrdersMany \
  {Det fanns %u dragordningar som ledde fram denna st�llning. De %u vanligaste �r:}
translate W OprepMovesFrom {Drag fr�n rapportst�llningen}
translate W OprepMostFrequentEcoCodes {De mest f�rekommande ECO-koderna}
translate W OprepThemes {Positionella teman}
translate W OprepThemeDescription {Temanfrekvens de f�rsta %u dragen av varje parti}
# translate W OprepThemeDescription {Antal teman vid drag %u}
translate W OprepThemeSameCastling {Rockad p� samma flygel}
translate W OprepThemeOppCastling {Rockad p� olika flyglar}
translate W OprepThemeNoCastling {Ingen har gjort rockad}
translate W OprepThemeKPawnStorm {Bondestorm p� kungsflygeln}
translate W OprepThemeQueenswap {Dambyte}
translate W OprepThemeWIQP {Isolerad vit dambonde} 
translate W OprepThemeBIQP {Isolerad svart dambonde}
translate W OprepThemeWP567 {Vit bonde p� 5e/6e/7e raden}
translate W OprepThemeBP234 {Svart bonde p� 2a/3e/4e raden}
translate W OprepThemeOpenCDE {�ppen c/d/e linje}
translate W OprepTheme1BishopPair {Endast den ena sidan har l�parparet}
translate W OprepEndgames {Slutspel}
translate W OprepReportGames {Antal partier i rapporten}
translate W OprepAllGames    {Samtliga partier}
translate W OprepEndClass {Material i slutst�llningen}
translate W OprepTheoryTable {Teorisammanst�llning}
translate W OprepTableComment {Skapad fr�n de %u h�gst rankade partierna.}
translate W OprepExtraMoves {Ytterligare antal drag i notf�rteckningen}
translate W OprepMaxGames {Maximalt antal partier i sammanst�llningen}
translate W OprepViewHTML {Visa HTML}
translate W OprepViewLaTeX {Visa LaTeX}

# Player Report:
translate W PReportTitle {Spelarrapport} 
translate W PReportColorWhite {med de vita pj�serna} 
translate W PReportColorBlack {med de svarta pj�serna} 
translate W PReportMoves {efter %s} 
translate W PReportOpenings {�ppningar} 
translate W PReportClipbase {T�m Clipbase och kopiera liknande partier dit} 


# Piece Tracker window:
translate W TrackerSelectSingle {V�nsterklicka f�r att v�lja denna pj�s.} 
translate W TrackerSelectPair {V�nsterklicka f�r att v�lja denna pj�s; anv�nd h�ger musknapp f�r att ocks� v�lja den relaterade pj�sen.}
translate W TrackerSelectPawn {V�nsterklicka f�r att v�lja denna pj�s; anv�nd h�ger musknapp f�r att v�lja alla �tta b�nder.}
translate W TrackerStat {Statistik}
translate W TrackerGames {% partier med drag till rutan}
translate W TrackerTime {% tid p� varje ruta}
translate W TrackerMoves {Drag}
translate W TrackerMovesStart {Ange vid vilket drag s�kningen ska b�rja.}
translate W TrackerMovesStop {Ange vid vilket drag s�kningen ska sluta.}

# Game selection dialogs:
translate W SelectAllGames {Alla partier i databasen}
translate W SelectFilterGames {Endast partierna i filtret}
translate W SelectTournamentGames {Endast partierna i den aktuella turneringen}
translate W SelectOlderGames {Endast �ldre partier}

# Delete Twins window:
translate W TwinsNote {Partier m�ste minst ha samma spelare f�r att kunna identifieras som dubbletter samt uppfylla andra kriterier du kan ange nedan. N�r dubbletter hittas raderas det kortare partiet. Tips: det b�sta �r att anv�nda r�ttstavningen innan dubblettj�mf�relsen eftersom detta f�rb�ttrar m�jligheten f�r uppt�ckt av dubbletter.}
translate W TwinsCriteria {Kriterium: Dubbletter m�ste ha...}
translate W TwinsWhich {Ange vilka partier som ska j�mf�ras}
translate W TwinsColors {Samma f�rger?}
translate W TwinsEvent {Samma evenemang?}
translate W TwinsSite {Samma plats?}
translate W TwinsRound {Samma rond?}
translate W TwinsYear {Samma �r?}
translate W TwinsMonth {Samma m�nad?}
translate W TwinsDay {Samma dag?}
translate W TwinsResult {Samma resultat?}
translate W TwinsECO {Samma ECO-kod?}
translate W TwinsMoves {Samma drag?}
translate W TwinsPlayers {J�mf�r spelarnas namn:}
translate W TwinsPlayersExact {Exakt kopia}
translate W TwinsPlayersPrefix {Endast de 4 f�rsta bokst�verna}
translate W TwinsWhen {N�r dubbletter tas bort}
translate W TwinsSkipShort {Ignorera alla partier som �r kortare �n 5 drag?}
translate W TwinsUndelete {�terta alla partier f�rst?}
translate W TwinsSetFilter {Filtrera alla borttagna dubbletter?}
translate W TwinsComments {Spara alltid partier med kommentarer?}
translate W TwinsVars {Spara alltid partier med variationer?}
translate W TwinsDeleteWhich {Ange vilket parti som ska tas bort:} 
translate W TwinsDeleteShorter {Det kortare partiet} 
translate W TwinsDeleteOlder {Partiet med l�gst nummer} 
translate W TwinsDeleteNewer {Partiet med h�gst nummer} 
translate W TwinsDelete {Ta bort partier}

# Name editor window:
translate W NameEditType {Typ av namn att redigera}
translate W NameEditSelect {Partier att redigera}
translate W NameEditReplace {Ers�tt}
translate W NameEditWith {med}
translate W NameEditMatches {Matchar: Tryck Ctrl+1 till Ctrl+9 f�r att v�lja}
translate W CheckGames {Kontrollera partier}
translate W CheckGamesWhich {Kontrollera partier}
translate W CheckAll {Alla partier}
translate W CheckSelectFilterGames {Bara partier i filter}

# Classify window:
translate W Classify {Klassificera}
translate W ClassifyWhich {ECO-klassificera vilka partier?}
translate W ClassifyAll {Alla partier (skriv �ver gamla ECO-koder)}
translate W ClassifyYear {Alla partier spelade under det senaste �ret}
translate W ClassifyMonth {Alla partier spelade den senaste m�naden}
translate W ClassifyNew {Endast partier som �nnu ej klassificerats}
translate W ClassifyCodes {ECO-koder som ska anv�ndas}
translate W ClassifyBasic {Enbart standardkoder ("B12", ...)}
translate W ClassifyExtended {Scidextensioner ("B12j", ...)}

# Compaction:
translate W NameFile {Namnfil}
translate W GameFile {Partifil}
translate W Names {Namn}
translate W Unused {Ej anv�nd}
translate W SizeKb {Storlek (kb)}
translate W CurrentState {Aktuell status}
translate W AfterCompaction {Efter komprimering}
translate W CompactNames {Namn, komprimera namnfil}
translate W CompactGames {Partier, komprimera partifil}
translate W NoUnusedNames "Det finns inga oanv�nda namn, s� namnfilen �r redan fullt komprimerad."
translate W NoUnusedGames "Partifilen �r redan fullt komprimerad."
translate W GameFileCompacted {Partifilen f�r databasen blev komprimerad.}

# Sorting:
translate W SortCriteria {Kriterium}
translate W AddCriteria {L�gg till kriterium}
translate W CommonSorts {Normal sortering}
translate W Sort {Sortering}

# Exporting:
translate W AddToExistingFile {L�gg till partier till en existerande fil?}
translate W ExportComments {Exportera kommentarer?}
translate W ExportVariations {Exportera variationer?}
translate W IndentComments {Dra in kommentarer?}
translate W IndentVariations {Dra in variationer?}
translate W ExportColumnStyle {Kolumnstil (ett drag per rad)?}
translate W ExportSymbolStyle {Symbolbaserade kommentarer:}
translate W ExportStripMarks {Avl�gsna koder f�r f�lt och pilar fr�n kommentarerna?} 

# Goto game/move dialogs:
translate W LoadGameNumber {Ange partiets nummer:}
translate W GotoMoveNumber {G� till drag nummer:}

# Copy games dialog:
translate W CopyGames {kopiera partier}
translate W CopyConfirm {
 Vill du verkligen kopiera
 de [::utils::thousands $nGamesToCopy] filtrerade partierna
 ur databasen "$fromName"
 till databasen "$targetName"?
}
translate W CopyErr {Kan ej kopiera partier}
translate W CopyErrSource {k�lldatabasen}
translate W CopyErrTarget {m�ldatabasen}
translate W CopyErrNoGames {har inga partier i filtret}
translate W CopyErrReadOnly {kan bara l�sas}
translate W CopyErrNotOpen {�r ej �ppen}

# Colors:
translate W LightSquares {Ljusa f�lt}
translate W DarkSquares {M�rka f�lt}
translate W SelectedSquares {Valda f�lt}
translate W SuggestedSquares {F�reslagna f�lt}
translate W WhitePieces {Vita pj�ser}
translate W BlackPieces {Svarta pj�ser}
translate W WhiteBorder {Vit kantlinje}
translate W BlackBorder {Svart kantlinje}

# Novelty window:
translate W FindNovelty {Hitta nyhet}
translate W Novelty {Nyhet}
translate W NoveltyInterrupt {Nyhetss�kningen avbr�ts}
translate W NoveltyNone {Inga nyheter hittades i detta parti}
translate W NoveltyHelp {
Scid kommer att f�rs�ka hitta det f�rsta draget som leder till en position som inte annars finns i denna databas eller i spel�ppingsboken baserad p� ECO.
}

# Sounds configuration:
translate W SoundsFolder {Ljudfilskatalog}
translate W SoundsFolderHelp {Katalogen ska ha filerna King.wav, a.wav, 1.wav, etc}
translate W SoundsAnnounceOptions {Inst�llningar f�r Dragannonsering}
translate W SoundsAnnounceNew {Annonsera nya drag n�r de g�rs}
translate W SoundsAnnounceForward {Annonsera drag n�r du g�r fram ett drag}
translate W SoundsAnnounceBack {Annonsera drag n�r du g�r fram eller tillbaka ett drag}
# ====== TODO To be translated ======
translate W SoundsSoundDisabled {Scid could not find the Snack audio package at startup;\nSound is disabled.}

# Upgrading databases:
translate W Upgrading {Uppdaterar}
translate W ConfirmOpenNew {
Denna databas �r i ett gammal format (Scid 3) och kan inte �ppnas i Scid 4, men en databas i det nya formatet (Scid 4) har redan skapats.

Vill du �ppna den senare databasen ist�llet?
}
translate W ConfirmUpgrade {
Denna databas �r i ett gammalt format (Scid 3). En databas i det nyare formatet m�ste skapas innan den kan anv�ndas i Scid 4.

Genom att uppdatera skapas en databas i det nya formatet med samma inneh�ll; uppdateringen �ndrar ingenting i den gamla databasen.

Detta kan ta ett tag men beh�ver bara g�ras en g�ng. Om du tycker att det tar alltf�r l�ng tid kan du avbryta processen.

Vill du uppdatera denna databas nu?
}

# Recent files options:
translate W RecentFilesMenu {Antal senast �ppnade filer i Arkivmenyn}
translate W RecentFilesExtra {Antal senast �ppnade filer i extra undermeny}

# My Player Names options:
translate W MyPlayerNamesDescription {
Ange en lista p� dina favoritspelare h�r nedanf�r. Skriv ett namn per rad. Jokertecken ("?", t ex, motsvarar ett enstaka tecken medan "*" st�r f�r flera tecken) �r till�tna.

Varje g�ng ett parti med en spelare vars namn st�r i denna lista �ppnas kommer br�det automatiskt att vridas s� att partiet visas fr�n spelarens perspektiv.
} 
translate W showblunderexists {visa blunder finns}
translate W showblundervalue {visa blunderv�rde}
translate W showscore {visa v�rdering}
translate W coachgame {tr�narparti}
translate W configurecoachgame {konfigurera tr�narparti}
translate W configuregame {Konfigurera parti}
translate W Phalanxengine {Phalanx schackmotor}
translate W Coachengine {Tr�narschackmotor}
translate W difficulty {sv�righetsgrad}
translate W hard {sv�r}
translate W easy {l�tt}
translate W Playwith {Spela med}
translate W white {vit}
translate W black {svart}
translate W both {b�da}
translate W Play {Spela}
translate W Noblunder {Ingen blunder}
translate W blunder {blunder}
translate W Noinfo {-- Ingen information --}
translate W PhalanxOrTogaMissing {Phalanx eller Toga hittades inte}
translate W moveblunderthreshold {drag �r en blunder om f�rlust �r st�rre �n}
translate W limitanalysis {begr�nsa schackmotors analystid}
translate W seconds {sekunder}
translate W Abort {Avbryt}
translate W Resume {Forts�tt}
translate W OutOfOpening {utanf�r �ppning}
translate W NotFollowedLine {Du f�ljde inte variationen}
translate W DoYouWantContinue {Vill du forts�tta ?}
translate W CoachIsWatching {Tr�naren observerar}
translate W Ponder {Permanent t�nkande}
translate W LimitELO {Begr�nsa ELO-styrka}
translate W DubiousMovePlayedTakeBack {Ett tveksamt drag spelades, vill du ta tillbaka det ?}
translate W WeakMovePlayedTakeBack {Ett svagt drag spelades, vill du ta tillbaka det ?}
translate W BadMovePlayedTakeBack {Ett d�ligt drag spelades, vill du ta tillbaka det ?}
translate W Iresign {Jag ger upp}
translate W yourmoveisnotgood {ditt drag �r inte bra}
translate W EndOfVar {Slut p� variation}
translate W Openingtrainer {�ppningstr�nare}
translate W DisplayCM {Visa kandidatdrag}
translate W DisplayCMValue {Visa kandidatdragens v�rden}
translate W DisplayOpeningStats {Visa statistik}
translate W ShowReport {Visa rapport}
translate W NumberOfGoodMovesPlayed {bra drag spelade}
translate W NumberOfDubiousMovesPlayed {tveksamma drag spelade}
translate W NumberOfMovesPlayedNotInRepertoire {drag spelade som inte finns i repetoar}
translate W NumberOfTimesPositionEncountered {g�nger positionen p�tr�ffats}
translate W PlayerBestMove  {Till�t bara b�sta dragen}
translate W OpponentBestMove {Motst�ndare spelar b�sta dragen}
translate W OnlyFlaggedLines {Bara markerade variationer}
translate W resetStats {Nollst�ll statistik}
translate W Repertoiretrainingconfiguration {Repetoartr�nings-konfiguration}
translate W Loadingrepertoire {�ppnar repetoar}
translate W Movesloaded {�ppnat drag}
translate W Repertoirenotfound {Repetoar hittades inte}
translate W Openfirstrepertoirewithtype {�ppna f�rst en repetoardatabas med ikon/typ angivet p� h�ger sida}
translate W Movenotinrepertoire {Drag finns inte i repetoar}
translate W PositionsInRepertoire {Positioner i repetoar}
translate W PositionsNotPlayed {Positioner inte spelade}
translate W PositionsPlayed {Positioner spelade}
translate W Success {Framg�ng}
translate W DubiousMoves {Tveksamma drag}
translate W OutOfRepertoire {Utanf�r repetoar}
translate W ConfigureTactics {Konfigurera taktik}
translate W ResetScores {Nollst�ll po�ng}
translate W LoadingBase {�ppnar bas}
translate W Tactics {Taktik}
translate W ShowSolution {Visa l�sning}
translate W NextExercise {N�sta �vning}
translate W PrevExercise {Tidigare �vning}
translate W StopTraining {Avbryt tr�ning}
translate W Next {N�sta}
translate W ResettingScore {Nollst�ller po�ng}
translate W LoadingGame {�ppnar parti}
translate W MateFound {Matt hittad}
translate W BestSolutionNotFound {B�sta l�sningen hittades INTE !}
translate W MateNotFound {Matt hittades inte}
translate W ShorterMateExists {En kortare matt finns}
translate W ScorePlayed {Po�ng spelad}
translate W Expected {f�rv�ntat}
translate W ChooseTrainingBase {V�lj tr�ningsbas}
translate W Thinking {T�nker}
translate W AnalyzeDone {Analys klar}
translate W WinWonGame {Vinn vunnet parti}
translate W Lines {Variationer}
translate W ConfigureUCIengine {Konfigurera UCI-schackmotor}
translate W SpecificOpening {Specifik �ppning}
translate W StartNewGame {Starta nytt parti}
translate W FixedLevel {Fast niv�}
translate W Opening {�ppning}
translate W RandomLevel {Slumpm�ssig niv�}
translate W StartFromCurrentPosition {Starta fr�n den aktuella positionen}
translate W FixedDepth {Fast s�kdjup}
translate W Nodes {Noder} 
translate W Depth {S�kdjup}
translate W Time {Tid} 
translate W SecondsPerMove {Sekunder per drag}
translate W Engine {Schackmotor}
translate W TimeMode {Tidsmod}
translate W TimeBonus {Tid + bonus}
translate W TimeMin {min}
translate W TimeSec {sek}
translate W AllExercisesDone {Alla �vningar gjorda}
translate W MoveOutOfBook {Drag utanf�r bok}
translate W LastBookMove {Sista bokdrag}
translate W AnnotateSeveralGames {Kommentera flera partier\nfr�n aktuellt till :}
translate W FindOpeningErrors {Hitta �ppningsfel}
translate W MarkTacticalExercises {Markera taktiska �vningar}
translate W UseBook {Anv�nd bok}
translate W MultiPV {Flera variationer}
translate W Hash {Hashminne}
translate W OwnBook {Anv�nd schackmotorbok}
translate W BookFile {�ppningsbok}
translate W AnnotateVariations {Kommentera variationer}
translate W ShortAnnotations {Korta kommentarer}
translate W addAnnotatorTag {L�gg till kommentator-tagg}
translate W AddScoreToShortAnnotations {L�gg till v�rdering till korta kommentarer}
translate W Export {Exportera}
translate W BookPartiallyLoaded {Bok delvis �ppnad}
translate W Calvar {Ber�kning av variationer}
translate W ConfigureCalvar {Konfiguration}
translate W Reti {Reti}
translate W English {Engelsk}
translate W d4Nf6Miscellaneous {1.d4 Nf6 Diverse}
translate W Trompowsky {Trompowsky}
translate W Budapest {Budapest}
translate W OldIndian {Gammalindisk}
translate W BenkoGambit {Benko-gambit}
translate W ModernBenoni {Modern Benoni}
translate W DutchDefence {Holl�ndskt f�rsvar}
translate W Scandinavian {Skandinaviskt}
translate W AlekhineDefence {Alekhines f�rsvar}
translate W Pirc {Pirc}
translate W CaroKann {Caro-Kann}
translate W CaroKannAdvance {Caro-Kann Avancemang}
translate W Sicilian {Siciliansk}
translate W SicilianAlapin {Siciliansk Alapin}
translate W SicilianClosed {St�ngd Siciliansk}
translate W SicilianRauzer {Siciliansk Rauzer}
translate W SicilianDragon {Siciliansk Drake}
translate W SicilianScheveningen {Siciliansk Scheveningen}
translate W SicilianNajdorf {Siciliansk Najdorf}
translate W OpenGame {�ppet parti}
translate W Vienna {Wiener}
translate W KingsGambit {Kungsgambit}
translate W RussianGame {Ryskt parti}
translate W ItalianTwoKnights {Italianskt/Tv�springar}
translate W Spanish {Spanskt}
translate W SpanishExchange {Spanskt Avbytesvariant}
translate W SpanishOpen {�pett Spanskt}
translate W SpanishClosed {St�ngt Spanskt}
translate W FrenchDefence {Franskt F�rsvar}
translate W FrenchAdvance {Fransk Avancemang}
translate W FrenchTarrasch {Fransk Tarrasch}
translate W FrenchWinawer {Fransk Winawer}
translate W FrenchExchange {Fransk Avbytesvariant}
translate W QueensPawn {Dambonde}
translate W Slav {Slav}
translate W QGA {Antagen Damgambit}
translate W QGD {Avb�jd Damgambit}
translate W QGDExchange {Avb�jd Damgambit Avbytesvariant}
translate W SemiSlav {Semi-Slav}
translate W QGDwithBg5 {Avb�jd Damgambit med Bg5}
translate W QGDOrthodox {Avb�jd Damgambit Ortodox}
translate W Grunfeld {Gr�nfeld}
translate W GrunfeldExchange {Gr�nfeld Avbytesvariant}
translate W GrunfeldRussian {Gr�nfeld Ryskt}
translate W Catalan {Catalan}
translate W CatalanOpen {�ppen Catalan}
translate W CatalanClosed {St�ngd Catalan}
translate W QueensIndian {Damindiskt}
translate W NimzoIndian {Nimzo-Indiskt}
translate W NimzoIndianClassical {Nimzo-Indiskt Klassiskt}
translate W NimzoIndianRubinstein {Nimzo-Indiskt Rubinstein}
translate W KingsIndian {Kungsindiskt}
translate W KingsIndianSamisch {Kungsindiskt S�misch}
translate W KingsIndianMainLine {Kungsindiskt Huvudvariation}
translate W ConfigureFics {Konfigurera FICS}
translate W FICSGuest {Logga in som G�st}
translate W FICSServerPort {Server-port}
translate W FICSServerAddress {IP-adress}
translate W FICSRefresh {Uppdatera}
translate W FICSTimesealPort {Timeseal-port}
translate W FICSSilence {Tystnad}
translate W FICSOffers {Erbjuder}
translate W FICSConsole {Konsol}
translate W FICSGames {Partier}
translate W FICSUnobserve {Sluta observera parti}
translate W FICSProfile {Visa din historik och profil}
translate W FICSRelayedGames {�teruts�nda partier}
translate W FICSFindOpponent {Hitta motst�ndare}
translate W FICSTakeback {Ta tillbaka}
translate W FICSTakeback2 {Ta tillbaka 2}
translate W FICSInitTime {Initialtid (minuter)}
translate W FICSIncrement {Inkrementering (sekunder)}
translate W FICSRatedGame {Ratingparti}
translate W FICSAutoColour {automatisk}
translate W FICSManualConfirm {bekr�fta manuellt}
translate W FICSFilterFormula {Filtrera med formel}
translate W FICSIssueSeek {S�kfr�ga}
translate W FICSChallenge {Utmana}
translate W FICSAccept {acceptera}
translate W FICSDecline {avb�j}
translate W FICSColour {f�rg}
translate W FICSSend {skicka}
translate W FICSConnect {Anslut}
translate W FICSdefaultuservars {Anv�nd standardvariabler}
translate W FICSObserveconfirm {Vill du observera parti} 
# ====== TODO To be translated ======
translate W FICSpremove {Enable premove}
# ====== TODO To be translated ======
translate W FICSObserve {Observe}
# ====== TODO To be translated ======
translate W FICSRatedGames {Rated Games}
# ====== TODO To be translated ======
translate W FICSUnratedGames {Unrated Games}
# ====== TODO To be translated ======
translate W FICSRated {Rated}
# ====== TODO To be translated ======
translate W FICSUnrated {Unrated}
# ====== TODO To be translated ======
translate W FICSRegisteredPlayer {Registered player only}
# ====== TODO To be translated ======
translate W FICSFreePlayer {Free player only}
# ====== TODO To be translated ======
translate W FICSNetError {Network error\nCan't connect to }
translate W GameReview {Parti�versikt}
translate W GameReviewTimeExtended {Ut�kad tid}
translate W GameReviewMargin {Felmarginal}
translate W GameReviewAutoContinue {Forts�tt automatiskt n�r drag �r korrekt}
translate W GameReviewReCalculate {Anv�nd ut�kad tid}
translate W GameReviewAnalyzingMovePlayedDuringTheGame {Analysera drag spelat under partiet}
translate W GameReviewAnalyzingThePosition {Analysera positionen}
translate W GameReviewEnterYourMove {Ange ditt drag}
translate W GameReviewCheckingYourMove {Kontrollerar ditt drag}
translate W GameReviewYourMoveWasAnalyzed {Ditt drag analyserades}
translate W GameReviewYouPlayedSameMove {Du speladade samma drag som i partiet}
translate W GameReviewScoreOfYourMove {V�rdering av ditt drag}
translate W GameReviewGameMoveScore {Partidragets v�rdering}
translate W GameReviewEngineScore {Schackmotorns v�rdering}
translate W GameReviewYouPlayedLikeTheEngine {Du spelade som schackmotorn}
translate W GameReviewNotEngineMoveButGoodMove {Inte schackmotordraget, men det �r ocks� ett bra drag}
translate W GameReviewMoveNotGood {Detta drag �r inte bra, v�rderingen �r}
translate W GameReviewMovesPlayedLike {Drag spelade som}
translate W GameReviewMovesPlayedEngine {Drag apelade som schackmotorn}
translate W CCDlgConfigureWindowTitle {Konfigurera Korrespondensschack}
translate W CCDlgCGeneraloptions {Generella inst�llningar}
translate W CCDlgDefaultDB {Standarddatabas:}
translate W CCDlgInbox {Inkorg (s�kv�g):}
translate W CCDlgOutbox {Utkorg (s�kv�g):}
translate W CCDlgXfcc {Xfcc-Konfiguration:}
translate W CCDlgExternalProtocol {Extern Protokollhanterare (t.ex. Xfcc)}
translate W CCDlgFetchTool {H�mtningsverktyg:}
translate W CCDlgSendTool {S�ndverktyg:}
translate W CCDlgEmailCommunication {eMail-kommunikation}
translate W CCDlgMailPrg {eMail-program:}
translate W CCDlgBCCAddr {(B)CC-address:}
translate W CCDlgMailerMode {Mod:}
translate W CCDlgThunderbirdEg {t.ex. Thunderbird, Mozilla Mail, Icedove...}
translate W CCDlgMailUrlEg {t.ex. Evolution}
translate W CCDlgClawsEg {t.ex Sylpheed Claws}
translate W CCDlgmailxEg {t.ex. mailx, mutt, nail...}
translate W CCDlgAttachementPar {Bilage-parameter:}
translate W CCDlgInternalXfcc {Anv�nd internt Xfcc-st�d}
translate W CCDlgConfirmXfcc {Bekr�fta drag}
translate W CCDlgSubjectPar {�mnes-parameter:}
translate W CCDlgDeleteBoxes {T�m In-/Utkorg} 
translate W CCDlgDeleteBoxesText {Vill du verkligen t�mma dina In- och Utkorgskataloger f�r Korrespondensschack? Detta kr�ver en ny synkronisering f�r att visa den seanaste statusen p� dina partier} 
translate W CCDlgConfirmMove {Bekr�fta drag} 
translate W CCDlgConfirmMoveText {Om du bekr�ftar, kommer f�ljande drag och kommentar att skickas till servern:} 
translate W CCDlgDBGameToLong {Inkonsekvent huvudvariation}
translate W CCDlgDBGameToLongError {Huvudvariationen i din databas �r l�ngre �n partiet i din Inkorg. Om Inkorgen inneh�ller aktuella partier, dvs precis efter en synkronisering, lades n�gra drag felaktigt till i huvudvariationen i databasen.\nI detta fall var god och f�rkorta huvudvariationen till (maximalt) drag\n}
translate W CCDlgStartEmail {Starta ett nytt eMail-parti}
translate W CCDlgYourName {Ditt Namn:}
translate W CCDlgYourMail {Din eMail-address:}
translate W CCDlgOpponentName {Motst�ndarnamn:}
translate W CCDlgOpponentMail {Motst�ndarens eMail-address:}
translate W CCDlgGameID {Parti-ID (unikt):}
translate W CCDlgTitNoOutbox {Scid: Korrespondensschackutkorg}
translate W CCDlgTitNoInbox {Scid: Korrespondensschackinkorg}
translate W CCDlgTitNoGames {Scid: Inga Korrespondensschackpartier}
translate W CCErrInboxDir {Korrespondensschacksinkorgskatalog:}
translate W CCErrOutboxDir {Korrespondensschacksutkorgskatalog:}
translate W CCErrDirNotUsable {finns inte eller �r inte m�jlig att anv�nda!\nVar god och kontrollera och korrigera inst�llningarna.}
translate W CCErrNoGames {inneh�ller inga partier!\nVar god och h�mta dem f�rst.}
translate W CCDlgTitNoCCDB {Scid: Ingen Korrespondensdatabas}
translate W CCErrNoCCDB {Ingen Databas av typ 'Korrespondens' �r �ppnad. Var god och �ppna en innan du anv�nder Korrespondensschackfunktioner.}
translate W CCFetchBtn {H�mta partier fr�n servern och bearbeta Inkorgen}
translate W CCPrevBtn {G� till tidigare parti}
translate W CCNextBtn {G� till n�sta parti}
translate W CCSendBtn {Skicka drag}
translate W CCEmptyBtn {T�m Inkorgen och Utkorgen}
translate W CCHelpBtn {Hj�lp med ikoner och statusindikatorer.\nF�r generell Hj�lp tryck p� F1!}
translate W CCDlgServerName {Servernamn:}
translate W CCDlgLoginName  {Inloggningsnamn:}
translate W CCDlgPassword   {L�senord:}
# ====== TODO To be translated ======
translate W CCDlgShowPassword {Show password}
translate W CCDlgURL        {Xfcc-URL:}
translate W CCDlgRatingType {Ratingtyp:}
translate W CCDlgDuplicateGame {Icke unikt parti-ID}
translate W CCDlgDuplicateGameError {Detta parti finns fler �n en g�ng i din databas. Var god och ta bort alla dubbletter och komprimera din partifil (Arkiv/Underh�ll/Komprimera Databas).}
translate W CCDlgSortOption {Sorterar:}
translate W CCDlgListOnlyOwnMove {Bara partier d�r jag �r vid draget}
translate W CCOrderClassicTxt {Plats, Evenemang, Runda, Resultat, Vit, Svart}
translate W CCOrderMyTimeTxt {Min klocka}
translate W CCOrderTimePerMoveTxt {Tid per drag till n�sta tidskontroll}
translate W CCOrderStartDate {Startdatum}
translate W CCOrderOppTimeTxt {Motst�ndarens klocka}
translate W CCDlgConfigRelay {Konfigurera ICCF-observationer}
translate W CCDlgConfigRelayHelp {G� till partisidan p� http://www.iccf-webchess.com och visa partiet att observera.  Om du ser schackbr�der kopiera webadressen fr�n din webl�sare till listan nedanf�r. Bara en webadress per rad!\nExempel: http://www.iccf-webchess.com/MakeAMove.aspx?id=266452}
translate W ExtHWConfigConnection {Konfigurera extern h�rdvara}
translate W ExtHWPort {Port}
translate W ExtHWEngineCmd {Schackmotorkommando}
translate W ExtHWEngineParam {Schackmotorparameter}
translate W ExtHWShowButton {Visa knapp}
translate W ExtHWHardware {H�rdvara}
translate W ExtHWNovag {Novag Citrine}
translate W ExtHWInputEngine {Inmatningsschackmotor}
translate W ExtHWNoBoard {Inget br�de}
translate W NovagReferee {Nedteckna bara dragen}
translate W IEConsole {Inmatningsschackmotorkonsol}
translate W IESending {Drag skickade f�r}
translate W IESynchronise {Synkronisera}
translate W IERotate  {Rotera}
translate W IEUnableToStart {Kunde inste starta Inmatningsschackmotor:}
translate W DoneWithPosition {Klar med position}
translate W Board {Br�de}
translate W showGameInfo {Visa partiinformation}
translate W autoResizeBoard {�ndra storleken p� br�det automatiskt}
translate W DockTop {Drag �verst}
translate W DockBottom {Drag nederst}
translate W DockLeft {Drag till v�nster}
translate W DockRight {Drag till h�ger}
translate W Undock {Avdocka}
translate W ChangeIcon {�ndra ikon...}
# ====== TODO To be translated ======
translate W NewGameListWindow {New Game List Window}
# ====== TODO To be translated ======
translate W LoadatStartup {Load at startup}
# ====== TODO To be translated ======
translate W ShowHideDB {Show/Hide databases}
# ====== TODO To be translated ======
translate W ChangeFilter {Change filter}
# ====== TODO To be translated ======
translate W ChangeLayout {Load/Save/Change sorting criteria and column layout}
# ====== TODO To be translated ======
translate W ShowHideStatistic {Show/Hide statistics}
# ====== TODO To be translated ======
translate W BoardFilter {Show only games that matches the current board position}
# ====== TODO To be translated ======
translate W CopyGameTo {Copy Game to}
# ====== TODO To be translated ======
translate W FindBar {Find Bar}
# ====== TODO To be translated ======
translate W FindCurrentGame {Find current game}
# ====== TODO To be translated ======
translate W DeleteGame {Delete game}
# ====== TODO To be translated ======
translate W UndeleteGame {Undelete game}
# ====== TODO To be translated ======
translate W ResetSort {Reset sort}
# ====== TODO To be translated ======
translate W ConvertNullMove {Convert null moves to comments}
# ====== TODO To be translated ======
translate W SetupBoard {Setup Board}
# ====== TODO To be translated ======
translate W Rotate {Rotate}
# ====== TODO To be translated ======
translate W SwitchColors {Switch colors}
# ====== TODO To be translated ======
translate W FlipBoard {Flip Board}
# ====== TODO To be translated ======
translate W ImportPGN {Import PGN game}
# ====== TODO To be translated ======
translate W ImportingFiles {Importing PGN files in}
# ====== TODO To be translated ======
translate W ImportingFrom {Importing from}
# ====== TODO To be translated ======
translate W ImportingIn {Import games in}
# ====== TODO To be translated ======
translate W UseLastTag {Use last\ngame's tags}
# ====== TODO To be translated ======
translate W Random {Random}
# ====== TODO To be translated ======
translate W BackToMainline {Go back to mainline}
# ====== TODO To be translated ======
translate W LeaveVariant {Leave variant}
# ====== TODO To be translated ======
translate W Autoplay {Autoplay}
# ====== TODO To be translated ======
translate W ShowHideCoords {Show/Hide Coord.}
# ====== TODO To be translated ======
translate W ShowHideMaterial {Show/Hide Material}
# ====== TODO To be translated ======
translate W FullScreen {Full Screen}
# ====== TODO To be translated ======
translate W FilterStatistic {Filter Statistics}
# ====== TODO To be translated ======
translate W MakeCorrections {Make Corrections}
# ====== TODO To be translated ======
translate W Surnames {Surnames}
# ====== TODO To be translated ======
translate W Ambiguous {Ambiguous}
# ====== TODO To be translated ======
translate W OptionsToolbar "Verktygsf�lt"
translate W OptionsBoard "Br�det"
# ====== TODO To be translated ======
translate W OptionsMenuColor "Menu colors"
translate W OptionsBoardSize "Br�dstorlek"
translate W OptionsBoardPieces "Pj�sutseende"
# ====== TODO To be translated ======
translate W OptionsInternationalization "Internationalization"
# ====== TODO To be translated ======
translate W MenuColorForeground "Textcolor"
# ====== TODO To be translated ======
translate W MenuColorBackground "Background"
# ====== TODO To be translated ======
translate W MenuColorSelect "Select"
# ====== TODO To be translated ======
translate W OptionsTablebaseDir "Select up to 4 table base folders:"
}

############################################################
#
# Swedish tips section:

set tips(W) {
  {
    Scid har �ver 30 <a Index>hj�lpsidor</a>, och i de flesta f�nster kan du
    genom att trycka <b>F1</b> f� hj�lp om det f�nster du f�r tillf�llet har
    aktivt.
  }
  {
    Vissa f�nster (t ex partiinformation och <a Switcher>databasv�ljaren</a>) 
    har en meny f�r h�ger musknapp. Prova att h�gerklicka i varje f�nster s�
    ser du vilka som har det och vilka funktioner du kommer �t den v�gen.
  }
  {
    Du kan ange drag p� mer �n ett s�tt, s� du kan v�lja vilket som passar dig
    b�st. Du kan anv�nda musen (med eller utan dragf�rslag) eller tangentbordet
    (med eller utan autokomplettering). L�s hj�lpsidan f�r 
    <a Moves>att ange drag</a> f�r mer information.
  }
  {
    Om du har databaser du ofta �ppnar s� kan du l�gga till ett 
    <a Bookmarks>bokm�rke</a> f�r varje databas. Du kommer d� att kunna �ppna 
    databaserna snabbare via bokm�rkesmenyn.
  }
  {
    Du kan se alla drag i det aktuella partiet (inklusive variationer och kommentarer)
    genom att �ppna <a PGN>PGN-f�nstret</a>.
    Du navigerar igenom partiet i PGN-f�nstret genom att klicka p� valfritt drag med
    v�nster musknapp. Genom att klicka p� draget med mellan- eller h�germusknapp s�
    f�r du en f�rhandsvisning av just den st�llningen.
  }
  {
    Du kan kopiera partier mellan databaserna i <a Switcher>databasv�ljaren</a> genom
    att dra-och-sl�ppa dem mellan respektive databas.
  }
  {
    Scid kan �ppna PGN filer, �ven de som �r komprimerade med Gzip (dvs har en .gz fil�ndelse). 
    PGN filer �ppnas med enbart l�sr�ttigheter, s� om du vill redigera en PGN fil i Scid 
    m�ste du kopiera filen till en Scid databas med hj�lp av <a Switcher>databasv�ljaren</a>.
  }
  {
    Om du ofta anv�nder <a Tree>Tr�df�nstret</a> med stora databaser, �r det v�rt att v�lja
    <b>Fyll cache fil</b> fr�n Arkivmenyn i Tr�df�nstret. Detta inneb�r att tr�dstatistik f�r 
    m�nga av de vanligare st�llningarna sparas, vilket ger en snabbare tr�d�tkomst f�r databasen
    ifr�ga.
  }
  {
    <a Tree>Tr�df�nstret</a> kan visa alla drag fr�n den aktuella st�llningen. Men om ocks� vill 
    se alla dragf�ljder som har lett till denna st�llning kan du f� fram det genom att skapa en
   <a OpReport>�ppningsrapport</a>.
  }
  {
    Du kan v�nster- eller h�gerklicka i en kolumn i <a GameList>partilistan</a> f�r att �ndra 
    dess bredd.
  }
  {
    Med <a PInfo>spelarinformationen</a> aktuell (klicka p� endera spelarens namn under br�det i 
    huvudf�nstret f�r att f� fram den) �r det enkelt att <a Searches Filter>filtrera</a> fram partier
    av en s�rskild spelares enskilda resultat. Klicka bara p� valfritt v�rde som har angivits med
    <red>r�d text</red>.
  }
  {
    N�r du studerar �ppningar kan det vara en po�ng att markera valen <b>B�nder</b> eller <b>Filer</b> i 
    <a Searches Board>S�k aktuell position</a>. Genom dessa val kan du hitta andra �ppningar som ger
    liknande bondestrukturer.
  }
  {
    Du kan h�gerklicka i partiinformationsdelen av huvudf�nstret (under br�det) f�r att f� fram en 
    kontextmeny. Du kan t ex g�ra s� att Scid d�ljer n�sta drag i ett parti, vilket kan vara anv�ndbart 
    om du vill tr�na genom att "gissa" n�sta drag.
  }
  {
    Om du ofta <a Maintenance>underh�ller</a> stora databaser kan du utf�ra flera underh�llsuppgifter 
    vid samma tillf�lle via <a Maintenance Cleaner>databasverktyget</a>.
  }
  {
    Om du har en stor databas d�r de flesta partierna har ett evenemangsdatum och du vill ha partierna i 
    datumordning b�r du �verv�ga att <a Sorting>sortera</a> den p� evenemangsdatum i f�rsta hand och 
    evenemang i andra hand, ist�llet f�r datum och evenemang, d� detta kommer att h�lla turneringspartierna
    fr�n olika datum samman. (Under f�ruts�ttning att alla partier har samma evenemangsdatum naturligtvis).
    Alternativt kan du se till att f�lten evenemang, rond och datum �r s� enhetliga och korrekta som m�jligt.
    (ms).
  }
  {
    Det kan vara en bra ide att <a Maintenance Spellcheck>stavningskontrollera</a> din databas innan du 
    <a Maintenance Twins>raderar dubbletter</a> d� Scid har st�rre m�jlighet att hitta dubbletterna och 
    markera dessa f�r borttagning.
  }
  {
    <a Flags>Flaggor</a> �r anv�ndbara f�r att markera upp partier med karakt�ristika du vill s�ka p� senare,
    s�som bondest�llning, taktiska finesser, osv. Du kan s�ka p� flaggor n�r du s�ker p� f�lt i partihuvudet.
  }
  {
    Om du g�r igenom ett parti, och helt enkelt vill testa en ny variation utan att f�r�ndra partiet i sig, kan 
    du sl� p� F�rs�ksl�get (Trial mode) genom att trycka <b>Ctrl+Mellanslag</b> eller fr�n verktygsraden. �terg� till
    ursprungspartiet n�r du �r klar.
  }
  {
    Om du vill hitta det mest betydelsefulla partiet (med h�gst rankade spelare) i en viss position kan du
    �ppna <a Tree>Tr�df�nstret</a> och i denna �ppna listan med de b�sta partierna. I tr�df�nstret kan du till
    och med begr�nsa partierna till endast ett s�rskilt resultat.
  }
  {
    Ett bra s�tt att studera en �ppning �r att i en stor databas sl� p� tr�ningsl�get i <a Tree>Tr�df�nstret</a>, 
    och sedan spela igenom databasen f�r att se vilka varianter som f�rekommer oftast.
  }
  {
    Om du har tv� databaser �ppna, och vill ha ett varianttr�d att studera medan du g�r igenom ett parti
    i den andra databasen kan du <b>l�sa</b> tr�det i den databasen och sedan byta till den andra.
  }
  {
    <a Tmt>Turneringss�karen (tournament finder)</a> �r inte bara anv�ndbar f�r att lokalisera en s�rskild 
    turnering. Du kan ocks� anv�nda den f�r att s�ka efter turneringar en specifik spelare nyligen deltagit 
    i, eller att bl�ddra genom turneringar som genomf�rts i ett visst land.
  }
  {
    Det finns ett antal vanliga st�llningstyper definierade i <a Searches Material>S�k material/st�llning</a>
    f�nstret som du kan ha nytta av n�r du studerar �ppningar och mittspel.
  }
  {
    N�r du s�ker p� <a Searches Material>material eller st�llning</a> kan det ofta vara f�rdelaktigt att begr�nsa
    s�kningen till s�dana partier d�r st�llningen eller materialet f�rekommit i �tminstone n�gra drag. Du slipper
    du f� med tr�ffar d�r situationen du s�ker uppkom helt tillf�lligt.
  }
  {
    Om du har en viktig databas du inte vill radera av misstag kan du v�lja  <b>Enbart l�sbar</b> fr�n <b>Arkiv</b>
    menyn efter att du har �ppnat den. Alternativt kan du s�tta dess filr�ttigheter till enbart l�sr�ttigheter.
  }
  {
    Om du anv�nder XBoard eller WinBoard (eller n�got annat program som kan hantera FEN notation via urklippshanteraren)
    och vill kopiera den aktuella st�llningen fr�n ditt program �r det snabbaste s�ttet att g�ra det s� h�r:
    V�lj <b>Copy Position</b> fr�n <b>File</b> menyn i Xboard/Winboard, v�lj sedan <b>Klistra in utg�ngsst�llning</b>
    i Redigera menyn i Scid.
  }
  {
    I <a Searches Header>S�k i huvud</a>, �r spelare-, evenemang-, plats-, och rondnamn ok�nsliga f�r stora eller sm�
    bokst�ver och ger tr�ffar varhelst de finns i ett namn. Om du vill kan du ange att du ist�llet vill att s�kningen <b>ska</b>
    ta versaler/gemener i beaktande. Genom att anv�nda jokertecken inom citationstecken (d�r "?" = motsvarar obest�mt
    enskilt tecken och "*" = noll eller flera tecken). Om du exempelvis anger "*BEL" (med citationstecken) i det platsf�ltet
    hittar du alla partier spelade i Belgien, men exkluderar de som spelats i Belgrad.
  }
  {
    Om du vill redigera ett drag i ett parti utan att f�rlora alla de drag som spelats efter detta kan du �ppna
    <a Import>Importera ett parti i PGN-format</a> f�nstret i Verktygsmenyn. Klicka d�r p� <b>Klistra in aktuellt parti</b> 
    , redigera partiet och avsluta med <b>Importera</b>.
  }
  {
    Om du har en ECO klassificeringsfil laddad, kan du n� den mest exakt klassificerade st�llningen f�r det aktuella partiet
    genom att v�lja <b>Identifiera �ppning</b> i <b>Partier</b> menyn (kortkommando: Ctrl+Shift+D).
  }
  {
    N�r du vill se hur stor en fil �r, eller vill se n�r den senast redigerades innan du �ppnar den kan du anv�nda
    <a Finder>file finder</a> (Arkiv - S�k filer).
  }
  {
    En <a repetoire>repetoarfil</a> �r ett utm�rkt s�tt att h�lla koll p� dina favorit�ppningar, eller hitta partier d�r
    d�r de har spelats. N�r du v�l har skapat en repetoarfil kan du genoms�ka nya filer utifr�n repetoarfilen, och titta 
    igenom alla partier med just dina �ppningar.
  }
  {
    Genom att skapa en <a OpReport>�ppningsrapport</a> har du en utm�rkt m�jlighet att l�ra dig en ny spel�ppning. Du kan f�
    information om resultat, hur remiaktig den �r, vilka vanliga positionella teman som dyker upp, och mycket mer.
  }
  {
    Du kan kommentera den aktuella st�llningen med de vanligaste symbolerna (!, !?, +=, etc) utan att beh�va anv�nda 
    <a Comment>kommentarseditorn<a>. D�r du exempelvis vill ange ett bra drag skriver du "!" och trycker sedan ENTER
    s� l�ggs "!" symbolen till draget. Se �ven hj�lpsidan <a Moves>ange drag</a> f�r mer detaljerad information.
  }
  {
    Om du bl�ddrar igenom �ppningarna i en databas i <a Tree>tr�df�nstret</a>, f�r du en anv�ndbar �verblick �ver hur
    v�l �ppningen fungerar i sentida partier mellan h�grankade spelare om du �ppnar statistikf�nstret (kortkommando: Ctrl+I).
  }
  {
    Du �ndrar enkelt huvudf�nstrets br�dstorlek genom att h�lla nere <b>Ctrl</b> och <b>Shift</b> tangenterna, samtidigt
    som du trycker h�ger- eller v�nster piltangent.
  }
  {
    Efter genomf�rd <a Searches>s�kning</a>, �r det enkelt att navigera genom urvalet genom att h�lla nere <b>Ctrl</b> 
    tangenten samtidigt som du trycker upp- eller nerpiltangenterna f�r att g� till f�reg�ende eller n�sta parti i 
    <a Searches Filter>urvalet</a>.
  }
{
  Du kan relativt enkelt rita pilar och f�rga rutor till dina kommentarer. �ppna <b>Kommentarseditorn</b>, klicka p� <b>Infoga symbol</b> och v�lj �nskad f�rg. Om du nu klicka p� en f�rsta ruta, och d�refter klickar p� en andra s� dras en pil i �nskad f�rg fr�n den f�rsta till den andra rutan. Klickar du bara p� en ruta, blir den f�rgad.
  }
}

##########
#
# ECO Opening name translations:

translateECO W {
  Accelerated {, Accelererad}
  {: Accelerated} Accelererad
  Accepted {, Antagen}
  {: Accepted} Antagen
  Advance Avancemang
  {as Black} {som Svart}
  Attack Angrepp
  Bishop L�pare
  Bishop's L�par
  Classical Klassisk
  Closed St�ngd
  {Closed System} {St�ngt system}
  Counterattack Motangrepp
  Countergambit Motgambit
  Declined {, Avb�jd}
  Defence F�rsvar
  deferred f�rv�grad
  Deferred {, f�rv�grad}
  Early Tidig
  Exchange Avbyte
  Game Parti
  Improved f�rb�ttrad
  King's Kung
  Knight Springar
  Line Variant
  {Main Line} Huvudvariant
  Open �ppen
  Opening �ppning
  Queen's Dam
  Queenswap Damavbyte
  Symmetrical Symmetrisk
  Variation Variation
  Wing Flygel
  with med
  without utan

  Alekhine Aljechin
  Averbakh Averbach
  Botvinnik Botvinnik
  Chigorin Chigorin
  Polugaevsky Polugajevski
  Rauzer Rauzer
  Sveshnikov Sveschnikov

  Austrian �sterrikisk
  Berlin Berlin
  Bremen Bremen
  Catalan Katalansk
  Czech Tjeckisk
  Dutch Holl�ndsk
  English Engelsk
  French Fransk
  Hungarian Ungersk
  Indian Indisk
  Italian Italiensk
  Latvian Lettisk
  Meran Meran
  Moscow Moskva
  Polish Polsk
  Prague Prag
  Russian Rysk
  Scandinavian Skandinavisk
  Scheveningen Scheveningen
  Scotch Skottsk
  Sicilian Siciliansk
  Slav Slavisk
  Spanish Spansk
  Swedish Svensk
  Swiss Schweizisk
  Vienna Wiener
  Yugoslav Jugoslavisk

  {Accelerated Fianchetto} {Accelererad Fianchetto}
  {Accelerated Pterodactyl} {Accelererad Pterodactyl}
  {Alekhine Defence} Aljechins F�rsvar
  {Alekhine Variation} Aljechin-Variant
  {Alekhine: S�misch Attack} {Aljechin: Wiener-system (S�misch-Angrepp)}
  {Anderssen Opening} Anderssen-�ppning
  {Anti-King's Indian} Anti-Kungsindisk
  {Austrian Attack} {�sterrikiskt Angrepp}
  {Benko Gambit} Volga-Gambit
  {Benko Opening} Benk�-�ppning
  {Berlin Defence} {Berlinf�rsvar}
  Chameleon Chamaleon
  Chelyabinsk Chelyabinsk
  {Classical Defence} {Klassiskt f�rsvar}
  {Spanish: Classical Defence} {Spanskt: Klassiskt (Cordel-) f�rsvar}
  {Classical Exchange} {Klassiskt Avbyte}
  {Classical Variation} {Klassisk Variant}
  {Closed Berlin} {St�ngd Berlin}
  {Open Berlin} {�ppen Berlin}
  {Bird's,} {Bird,}
  {Bird's Defence} Birds f�rsvar
  {Bird's Deferred} {F�rv�grad Bird}
  {Bishop's Opening} L�parspel
  {Botvinnik System} Botvinnik-system
  {Central Variation} Centralvariant
  {Centre Attack} Centrumsangrepp
  {Centre Game} Mittgambit
  {Danish Gambit} {Nordisk Gambit}
  Dragon Drake
  {Dutch Variation} {Holl�ndsk Variant}
  {Early Exchange} {Tidigt Avbyte}
  {Early Queenswap} {Tidigt Dambyte}
  {English Attack} {Engelskt Angrepp}
  {English: King's} {Engelskt: Kungsbonde}
  {English Variation} {Engelsk Variant}
  {Englund Gambit} Englunds Gambit
  {Exchange Variation} Avbytesvariant
  {Fianchetto Variation} Fianchettovariant
  {Flohr Variation} Flohr-Variant
  {Four Knights} Fyrspringar
  {Four Knights Game} Fyrspringarspel
  {Four Pawns} Fyrbonde
  {Four Pawns Attack} Fyrbondeangrepp
  {French Variation} {Fransk Variant}
  {From Gambit} {From-Gambit}
  {Goring Gambit} {G�ring-Gambit}
  {Grob Gambit} {Grobs Gambit}
  {Hungarian Defence} {Ungerskt f�rsvar}
  {Indian Variation} {Indisk Variant}
  {Italian Game} {Italienskt Parti}
  KGD {Avb�jd Kungssgambit}
  {Classical KGD} {Klassisk avb�jd Kungsgambit}
  {Keres Variation} Keres-Variant
  KGA {Antagen Kungsgambit}
  {KGA: Bishop's Gambit} Kungsl�pargambit
  {KGA: King's Knight Gambit} Kungsspringargambit
  {King's Gambit} Kungsgambit
  {King's Gambit Accepted} {Antagen Kungsgambit}
  {King's Gambit Accepted (KGA)} {Antagen Kungsgambit}
  {King's Indian} Kungsindisk
  KIA {Kungsindiskt Angrepp}
  {King's Knight Gambit} Kungsspringargambit
  {King's Pawn} Kungsbonde
  {Lasker Variation} {Lasker-Variant}
  {Latvian Gambit} {Lettisk Gambit}
  {Maroczy Bind} {Maroczy-bindning}
  {Marshall Variation} Marshall-Variant
  {Modern Attack} {Modernt Angrepp}
  {Modern Steinitz} {Modern Steinitz}
  {Modern Variation} {Modern Variant}
  {Moscow Variation} {Moskva-variant}
  Nimzo-Indian Nimzoindisk
  {Old Benoni} {Klassisk Benoni}
  {Old Indian} Gammalindisk
  {Old Indian Attack} {Gammalindisk Indisk attack}
  {Old Steinitz} Gammal Steinitz-�ppning
  {Open Game} {�ppet Parti}
  {Poisoned Pawn} {F�rgiftad Bonde}
  {Polish Variation} {Polsk Variant}
  {Polugaevsky Variation} {Polugajevski-Variant}
  {Queen's Gambit} Damgambit
  {Queen's Gambit Accepted} {Antagen Damgambit}
  QGA {Antagen Damgambit}
  {Queen's Gambit Accepted (QGA)} {Antagen Damgambit}
  {Reversed QGA} {Omv�nd antagen Damgambit}
  QGD {Avb�jd Damgambit}
  {Queen's Gambit Declined (QGD)} {Avb�jd Damgambit}
  {Reversed QGD} {Omv�nd avb�jd Damgambit}
  {Queen's Indian} Damindisk
  {Queen's Pawn} Dambonde
  {Queen's Pawn Game} Dambondespel
  {Reversed Slav} {Omv�nd Slavisk}
  {Rubinstein Variation} Rubinstein-Variant
  {Russian Game} {Ryskt Parti}
  {Russian Game (Petroff Defence)} {Ryskt Parti}
  {Russian-Three Knights Game} {Ryskt trespringarspel}
  {Scandinavian (Centre Counter)} Skandinavisk
  Schliemann J�nisch
  {Schliemann (J�nisch)} {J�nisch-Gambit (Schliemann)}
  {Scotch Opening} {Skottsk �ppning}
  {Sicilian Defence} {Sicilianskt f�rsvar}
  {Sicilian Variation} {Siciliansk Variant}
  {Slav Defence} {Slaviskt f�rsvar}
  Smith-Morra Morra
  {Smith-Morra Accepted} {Antagen Morra-Gambit}
  {Smith-Morra Gambit} Morra-Gambit
  {Spanish (Ruy Lopez)} {Spanskt Parti}
  {Start position} Utg�ngsst�llning
  {Steinitz Deferred} F�rv�grad Rubinstein
  {Swedish Variation} {Svensk Variant}
  {Swiss Variation} {Schweizisk Variant}
  {Tarrasch's Gambit} {Tarrasch-Gambit}
  {Three Knights} Trespringar
  {3 Knights} Trespringar
  {Three Knights Game} Trespringarspel
  {Three Pawns Attack} Trebondeangrepp
  {Two Knights} Tv�springar
  {Two Knights Defence} Tv�springar-f�rsvar
  {Two Knights Variation} Tv�springar-variant
  {Two Pawns} Tv�bonde
  {Two Pawns Attack} Tv�bondeangrepp
  {Wing Gambit} Flygel-Gambit
  {Yugoslav Attack} {Jugoslaviskt Angrepp}
}

############################################################
#
# Swedish help pages:

# Basic help pages completed, no links no other sections.

##########
# Contents
#
set helpTitle(W,Contents) "Inneh�llsf�rteckning"
set helpText(W,Contents) {<h1>Hj�lp med Scid: Inneh�llsf�rteckning</h1>

<h3>Komma ig�ng och allm�nt om Scid</h3>
<p>F�ljande texter och dess l�nkar �r under �vers�ttning. Detta p�b�rjades i Scid 3.4 beta 1 (2002 07 27). 
 /Martin S.</p>
Detta betyder att menyerna �r �versatta. Rubriktexterna b�r kunna vara �versatta till Scid 3.4 men alla l�nkar
fr�n rubriktexterna �r f�rmodligen inte det. /Martin S.</p>

<ul>
<li><a Guide><b>Komma ig�ng</b> med Scid</a> <red>(L�s detta f�rst)</red></li>
<li><a Hints><b>Tips</b> om hur du f�r ut mer av Scid</a></li>
<li><a MainWindow><b>Huvudf�nstret</b></a></li>
<li><a Menus><b>Menyerna</b></a> <red>(Uppdaterad!)</red></li>
<li><a Moves>Ange <b>drag</b></a> <red>(Uppdaterad!)</red></li>
<li><a Searches><b>S�ka</b> i Scid</a></li>
<li><a Clipbase>Att anv�nda <b>Clipbase (Urklippsdatabasen)</b></a></li>
<li><a Annotating><b>Kommentera partier</b></a> <red>(Ny!)</red></li>
</ul>

<h4>Andra Scid-f�nster</h4>

<ul>
<li><a Analysis><b>Analysf�nstret</a></li>
<li><a Book><b>Bokf�nstret</b></a></li>
<li><a CalVar><b>Ber�kning av variationer-f�nstret</b></a></li>
<li><a Comment><b>Kommentareditor</b> </a></li>
<li><a Crosstable><b>Korstabellf�nster</a></li>
<li><a Switcher><b>Databasv�xlaren</b> </a></li>
<li><a Email><b>Email-f�nster</a></li>
<li><a Finder><b>S�k filer</b> </a></li>
<li><a GameList><b>Partilistan</b> </a></li>
<li><a Import><b>Importf�nstret</a></li>
<li><a OpeningTrainer><b>�ppningstr�narf�nstret</b>  </a></li>
<li><a Reports><b>Rapporter</b></a> <red>(Uppdaterad!)</red></li>
<li><a PGN><b>PGN-f�nster</a></li>
<li><a PTracker><b>Pj�ssp�raren</b></a></li>
<li><a PList><b>Spelarlistan</b></a></li>
<li><a PInfo><b>Spelarinfo</b> </a></li>
<li><a Repertoire><b>Repetoar-Editor</a></li>
<li><a TacticalGame><b>Taktiskt partif�nstret</b> </a></li>
<li><a Tmt><b>S�k turneringar</a></li>
<li><a Tree><b>Tr�df�nstret</a></li>
<li><a Graphs><b>Graff�nster</a></li>
<li><a TB>Slutspelstabeller</a><red>(Uppdaterad!)</red></li>
</ul>

<h4>Andra funktioner och information</h4>
<ul>
<li><a Bookmarks><b>Bokm�rken</b></a></li>
<li><a Cmdline>Kommandorad-alternativ</a></li>
<li><a Compact><b>Komprimera databas</a></li>
<li><a Correspondence>Korrespondensschack</a></li>
<li><a Maintenance><b>Underh�ll databas</a></li>
<li><a ECO><b>ECO</a></li>
<li><a EPD><b>EPD</a></li>
<li><a Export><b>Exportera partier</a> <red>(Uppdaterad!)</red></li>
<li><a Flags>Parti-markeringarna</a></li>
<li><a LaTeX>Scid och LaTeX</a></li>
<li><a Options><b>Alternativ</a><red>(Uppdaterad!)</red></li>
<li><a Sorting><b>Sortera databas</a></li>
<li><a Pgnscid><b>Pgnscid</a></li>
<li><a NAGs>NAG-v�rden</a></li>
<li><a Formats>Filformat</a></li>
<li><a Author>Kontaktinformation</a></li>
</ul>

<p><footer>(Uppdaterad: Scid 3.6.1, December 2004)</footer></p>
}

###############
### Topic Index

set helpTitle(W,Index) "Hj�lp-index"
set helpText(W,Index) {<h1>Scid: Hj�lp-index</h1>

<h3>A</h3>
<ul>
<li><a Options>Alternativ</a></li>
<li><a Analysis>Analysf�nstret</a></li>
<li><a Moves>Ange drag</a></li>
</ul>

<h3>B</h3>
<ul>
<li><a CalVar>Ber�kning av variationer-f�nstret</a></li>
<li><a GameList Browsing>Bl�ddra partilistor</a></li>
<li><a Book>Bokf�nstret</a></li>
<li><a Bookmarks>Bokm�rken</a></li>
<li><a Tree Best>B�sta partier</a></li>
</ul>

<h3>D</h3>
<ul>
<li><a Sorting>Databassortering</a></li>
<li><a Maintenance>Databasunderh�ll</a></li>
<li><a Switcher>Databasv�xlaren</a></li>
<li><a Translator>Den svenska �vers�ttningen</a></li>
</ul>

<h3>E</h3>
<ul>
<li><a ECO>ECO</a></li>
<li><a ECO Browser>ECO-bl�ddrar</a>-f�nster</li>
<li><a ECO Codes>ECO kodsystem</a></li>
<li><a Email>Email-f�nster</a></li>
<li><a EPD>EPD-filer</a></li>
<li><a Export>Exportfilter</a></li>
<li><a Export>Exportera partier som text</a></li>
</ul>

<h3>F</h3>
<ul>
<li><a Formats>Filformat</a></li>
</ul>

<h3>G</h3>
<ul>
<li><a Graphs Filter>Graffilter</a></li>
<li><a Graphs>Graff�nster</a></li>
</ul>

<h3>H</h3>
<ul>
<li><a MainWindow>Huvudf�nstret</a></li>
</ul>

<h3>I</h3>
<ul>
<li><a Import>Importf�nstret</a></li>
<li><a Contents>Inneh�llsf�rteckning</a></li>
</ul>

<h3>K</h3>
<ul>
<li><a Guide>Komma ig�ng med Scid</a></li>
<li><a Cmdline>Kommandorad-alternativ</a></li>
<li><a Comment>Kommentareditor</a></li>
<li><a Annotating Null>Kommentera Nulldrag</a></li>
<li><a Annotating>Kommentera partier</a></li>
<li><a Compact>Komprimera databas</a></li>
<li><a Correspondence>Korrespondensschack</a></li>
<li><a Crosstable>Korstabellf�nster</a></li>
<li><a Author>Kontaktinformation</a></li>
</ul>

<h3>L</h3>
<ul>
<li><a LaTeX>LaTeX</a> utdataformat</li>
</ul>

<h3>M</h3>
<ul>
<li><a Menus>Menyerna</a></li>
<li><a Menus File>Meny Arkiv</a></li>
<li><a Menus Edit>Meny Redigera</a></li>
<li><a Menus Game>Meny Partier</a></li>
<li><a Menus Search>Meny S�k</a></li>
<li><a Menus Windows>Meny F�nster</a></li>
<li><a Menus Tools>Meny Verktyg</a></li>
<li><a Menus Options>Meny Alternativ</a></li>
<li><a Menus Help>Meny Hj�lp</a></li>
</ul>

<h3>N</h3>
<ul>
<li><a NAGs>NAG-v�rden</a></li>
</ul>

<h3>P</h3>
<ul>
<li><a GameList>Partilistan</a></li>
<li><a Flags>Partimarkeringarna</a></li>
<li><a PGN>PGN-f�nster</a></li>
<li><a Pgnscid>Pgnscid</a></li>
<li><a PTracker>Pj�ssp�raren</a></li>
</ul>

<h3>R</h3>
<ul>
<li><a Reports Opening>Rapporter</a></li>
<li><a Graphs Rating>Ratinggraf</a></li>
<li><a Repertoire>Repetoar-Editor</a></li>
</ul>

<h3>S</h3>
<ul>
<li><a Analysis List>Schackmotorlista</a></li>
<li><a LaTeX>Scid och LaTeX</a></li>
<li><a Hints>Scidtips</a></li>
<li><a MainWindow Autoplay>Sj�lvspelsmod</a></li>
<li><a TB>Slutspelstabeller</a></li>
<li><a Guide>Snabbguide till att anv�nda Scid</a></li>
<li><a Sorting>Sortera databas</a></li>
<li><a PInfo>Spelarinfo</a></li>
<li><a Reports Player>Spelarrapport</a></li>
<li><a Maintenance Spellcheck>Stavningskontrollera namn</a></li>
<li><a Finder>S�k filer</a></li>
<li><a Searches Filter>S�kfilter</a></li>
<li><a Searches Header>S�k partidata</a></li>
<li><a PList>S�k spelare</a></li>
<li><a Searches Board>S�k st�llning</a></li>
<li><a Searches>S�ka i Scid</a></li>
<li><a Searches Material>S�k material</a></li>
<li><a Tmt>S�k turneringar</a></li>
</ul>

<h3>T</h3>
<ul>
<li><a TacticalGame>Taktiskt partif�nstret</a></li>
<li><a Moves Trial>Testa variant mod</a></li>
<li><a Hints>Tips</a></li>
<li><a Tree>Tr�df�nstret</a></li>
<li><a Options Fonts>Typsnitt</a></li>
</ul>

<h3>U</h3>
<ul>
<li><a Maintenance>Underh�ll databas</a></li>
<li><a Maintenance Cleaner>Underh�ll: Databasrensaren</a></li>
<li><a Maintenance Editing>Underh�ll: �ndra spelarnamn</a></li>
<li><a Maintenance Twins>Underh�ll: Ta bort dubbletter</a></li>
<li><a Maintenance Spellcheck>Underh�ll: Stavningskontrollera spelarnamn</a></li>
<li><a Clipbase>Urklippsdatabasen</a></li>
</ul>

<h3>V</h3>
<ul>
<li><a Annotating Vars>Varianter</a></li>
</ul>

<h3>�</h3>
<ul>
<li><a ECO>�ppningsklassificering (ECO)</a></li>
<li><a Repertoire>�ppningsrepetoar</a></li>
<li><a Reports Opening>�ppningsrapport</a></li>
<li><a OpeningTrainer>�ppningstr�narf�nstret</a></li>
</ul>

<p><footer>(Uppdaterad: Scid 3.5, February 2003)</footer></p>
}

####################
### Quick Guide help:

set helpTitle(W,Guide) "Komma ig�ng med Scid"
set helpText(W,Guide) {<h1>Komma ig�ng med Scid</h1>
<p>
Scid �r en schackdatabashanterare som du kan anv�nda till att bl�ddra och <a Searches>s�ka</a> (enligt kriterier du st�ller upp) igenom 
databaser med schackpartier. Du kan ocks� redigera de partier du vill.
</p>
<p>
Scid anv�nder sitt eget <a Formats>databasformat</a> baserat p� tre filer. Det �r mycket kompakt och snabbt, men kan konvertera s�v�l 
till som fr�n PGN (Portable Game Notation) standarden om man s� �nskar. Scids <a PGN>PGN-f�nster</a> visar texten till det aktuella
partiet i PGN-format.
</p>
<p>
Du kan anv�nda Scid till att l�gga till och ta bort partier i en databas genom att anv�nda s�v�l mus som tangentbordet f�r att skriva in
drag. Se vidare <a Moves>att skriva in drag</a> f�r en noggrannare beskrivning.
</p>
<p>
Du kan ocks� anv�nda Scid f�r att hantera <a PGN>PGN</a> filer genom att klistra in PGN-text i Scids <a Import>Importf�nster</a> 
eller genom att �ppna en PGN-fil i Scid. PGN-filer kan dock inte redigeras av Scid (de �ppnas skrivskyddade). Eftersom PGN-filer
anv�nder mer minne och laddas l�ngsammare rekommenderas du att konvertera stora PGN-filer till en Scid databas med verktyget
<a Pgnscid>Pgnscid</a>.
</p>
<p>
Scids <a MainWindow>huvudf�nster</a> (det med schackbr�det) visar det aktuella partiet och databasen i detalj. Du kan n�r som helst �ppna 
upp till fyra databaser (fem om du r�knar med Urklippsdatabasen <a Clipbase>Clipbase</a>). Var och ett av dessa kommer att ha sitt eget aktuella
parti. (Partier med ID-numret 0 visar att detta �r ett parti som �nnu inte ing�r i den aktuella databasen). Du bl�ddrar mellan de �ppnade databaserna
via <a Menus File>Filmenyn</a>.
</p>
<p>
L�s g�rna �vriga hj�lpsidor i <a Index>Inneh�llsf�rteckningen</a> f�r mer information.
</p>
<p>
L�s <a Author>kontaktinformationssidan</a> om du vill komma i kontakt med skaparen av Scid. F�r fr�gor om den svenska �vers�ttningen ska du
<b>inte</b> kontakta upphovsmannen utan ist�llet <a Translator>�vers�ttaren</a>.
</p>

<p><footer>(Uppdaterad: Scid 3.1, December 2001)</footer></p>
}


set helpTitle(W,Author) "Kontaktinformation"
set helpText(W,Author) {<h1>Kontaktinformation</h1>
<p>
Scids webbsajt finns p�: <br>
<b><url http://scid.sourceforge.net/>http://scid.sourceforge.net/</url></b>
</p>
<p>
P� hemsidan kan du h�mta den senaste versionen av Scid och andra extrafiler som kan bli tillg�ngliga.
</p>
<p>Den mest uppdaterade hj�lpen kommer alltid att finnas tillg�nglig online hos:
<b><url http://scid.sourceforge.net/tutorial/>http://scid.sourceforge.net/tutorial/</url></b>
Typiskt kommer denna att vara mer uppdaterad �n den hj�lp som distribueras med Scid, eller dessa hj�lp-
sidor i Scid.
</p>

<p>Den svenska �vers�ttningen av Scid har gjorts av Martin Skj�ldebrand. Synpunkter p� �vers�ttningen ska <b>inte</b>
skickas till Shane. D�remot f�r du g�rna skicka kommentarer, fr�gor och f�rslag till r�ttningar till �vers�ttaren p� adressen:<br>
<b>martin@skjoldebrand.org</b>
</p>
}

####################
### Hints page:
set helpTitle(W,Hints) "Scid-tips"
set helpText(W,Hints) {<h1>Scid-tips</h1>
<p>
Denna sida inneh�ller anv�ndbara tips i form av fr�gor och svar. Genom att l�sa igenom denna sida, kan du senare komma att
anv�nda Scid b�ttre. Om du nyligen b�rjat anv�nda Scid, s� l�s till en b�rjan <a Guide>Kom ig�ng</a>.
Det mesta av informationen p� denna sida finns refererad mer utf�rligt p� andra sidor i hj�lpen. Du finner dem i <a Index>Inneh�llsf�rteckningen</a>.
Om har n�got du tips du tycker passar bra f�r denna sida, s� skicka den till <a Author>upphovsmannen</a>.
</p>

<h4>Kan Scid ladda en databas n�r den startas?</h4>
<p>
Ja, du kan ange databaser, PGN-filer eller <a EPD>EPD-filer</a>
p� kommandoraden som t ex;
<ul>
<li> <b>scid  mybase  games.pgn.gz</b> </li>
</ul>
som laddar Scid-databasen <b>mybase</b> och den Gzip-komprimerade PGN-filen <b>games.pgn.gz</b>.
</p>

<h4>Finns det enklare s�tt att �ndra storleken p� br�det �n via Alternativmenyn?</h4>
<p>
Ja, du kan anv�nda kortkommandorna <b>Ctrl+Shift+V�nsterPil</b> och <b>Ctrl+Shift+H�gerPil</b> f�r att f�rminska eller 
f�rstora br�dets storlek.
</p>

<h4>Jag brukar tr�na genom att spela igenom partier, s� jag vill inte att Scid visar n�sta drag i partiinformationen
nedanf�r br�det. Kan jag d�lja detta p� n�got s�tt?</h4>
<p>
Du kan d�lja n�sta drag genom att h�gerklicka partiinformationen och v�lja  <b>D�lj n�sta drag</b> i menyn som �ppnas.
</p>

<h4>Var finner jag ECO-koden f�r �ppningen p� br�det?</h4>
<p>
ECO-koden visas p� sista raden i partiinformationen nedanf�r br�det i  <a MainWindow>huvudf�nstret</a>,
om du har laddat ECO-klassificeringsfilen (<b>scid.eco</b>). <br>
Hj�lpsidan f�r <a ECO>ECO-koder</a> f�rklarar hur man laddar ECO-klassificeringsfilen och st�ller in programmet s� att
den laddas varje g�ng man startar Scid.
</p>

<h4>Jag h�ller p� och matar in ett parti och befinner mig nu vid drag 30. Nu ser jag att drag 10 blev fel. Hur kan jag �ndra
detta utan att g�ra om alltihop?</h4>
<p>
Du kan anv�nda <a Import>Importf�nstret</a>; se vidare <a Moves Mistakes>mata in drag</a> f�r mer information.
</p>

<h4>Hur kopierar jag partier fr�n en databas till en annan?</h4>
<p>
Anv�nd <a Switcher>Databasv�xlaren</a>. Drag fr�n k�lldatabasen till m�ldatabasen s� kopierar du allt i k�lldatabasen till
m�ldatabasen. Genom att anv�nda <a Searches Filter>Filter</a> kan du begr�nsa det du kopierar fr�n den ena databasen till den andra.
</p>

<h4>Varje g�ng jag anger ett drag som redan finns f�r jag fr�gan "Ers�tt drag?". Hur undviker jag detta?</h4>
<p>
Du kan antingen st�nga av <b>Fr�ga f�re ers�tt drag</b> valm�jligheten i menyn <menu>Altervativ: Drag</menu</menu>; eller
t�nka p� att g�ra �ndringarna genom att ta tillbaka dragen genom att h�gerklicka med musen. Det senare alternativet raderar dragen helt ur
partiet.
</p>

<h4>Hur �ndrar kolumnbredden i partilistan?</h4>
<p>
H�ger- eller v�nsterklicka p� kolumntiteln f�r den kolumn du vill �ndra.
</p>

<h4>Hur anv�nder jag tr�df�nstret f�r ett filtrerade partier - till skillnad mot att anv�nda den f�r hela databasen?</h4>
<p>
Anv�nd <a Clipbase>Urklippsdatabasen (Clipbase)</a>. Filtera databasen att visa endast de partier du vill anv�nda i tr�det, 
kopiera sedan partierna till Urklippsdatabasen (Clipbase) via <a Switcher>Databasv�xlaren</a>. �ppna d�refter tr�df�nstret
med den senare databasen som aktiv.
</p>

<h4>Tr�det �r l�ngsamt n�r jag jobbar med stora databaser. G�r det att snabba upp den?</h4>
<p>
Spara tr�dcachen ofta s� sparar du resultaten f�r framtida anv�ndning. Se vidare cache-sektionen i hj�lpen f�r 
<a Tree>tr�det</a> f�r mer detaljerad information.
</p>

<h4>Kan jag redigera PGN-texten f�r ett parti direkt?</h4>
<p>
Du kan inte anv�nda <a PGN>PGN-</a>f�nstret till att redigera det aktuella partiet, d�remot kan du anv�nda 
<a Import>Importf�nstret</a>. �ppna f�nstret (kortkommando: <b>Ctrl+Shift+I</b>) och klicka p� klistra in aktuellt parti
<b>Paste current game</b>, redigera partiet och klicka sedan p� <b>Importera</b>.
</p>

<h4>I min databas finns m�nga spelarnamn som �r felstavade. Hur r�ttar jag allt detta?</h4>
<p>
Du kan r�tta enstaka namn, eller g�ra en stavningskontroll f�r hela databasen via menyvalen i <menu>Arkiv: Databasverktyg</menu>.
Se vidare hj�lpen f�r <a Maintenance Editing>Databasunderh�ll</a>.
</p>

<h4>Jag har tv� databaser �ppna: den ena inneh�ller mina egna partier, den andra �r m�nga storm�starpartier.
Hur j�mf�r jag ett av mina egna partier mot partierna i databasen med storm�starpartier?</h4>
<p>
�ppna <a Tree>Tr�df�nstret</a> i databasen med storm�starpartier och v�lj <term>L�s</term> f�r att l�sa tr�det i den databasen. 
N�r du sedan byter till den andra databasen kommer tr�det att forts�tta visa informationen fr�n databasen med storm�starpartier.
</p>

<p><footer>(Uppdaterad: Scid 2.6,  augusti 2001)</footer></p>
}


#################
# Authors, translators
#

set helpTitle(W,Translator) "Den svenska �vers�ttningen"
set helpText(W,Translator) {<h1>Den svenska �vers�ttningen</h1>
<p>
Scids webbsajt finns p�: <br>
<b><url http://scid.sourceforge.net/>http://scid.sourceforge.net/</url></b>. D�r kan du h�mta den senaste versionen av Scid och 
de andra filerna till programmet som du kan ha behov av. D�r finns ocks� den senaste versionen av den svenska spr�kfilen.
</p>
<p>Den svenska �vers�ttningen av Scid har gjorts av Martin Skj�ldebrand. Skicka g�rna kommentarer, fr�gor och f�rslag till r�ttningar
till �vers�ttaren p� adressen:<br>
<b>martin@skjoldebrand.org</b>
</p>
}

####################
### Main window help:

set helpTitle(W,MainWindow) "Huvudf�nstret"
set helpText(W,MainWindow) {<h1>Scid: huvudf�nstret</h1>
<p>
P� br�det i huvudf�nstret visas den aktuella st�llningen i det aktiva partiet. Du f�r ocks� information om partiet och den
aktiva databasen. F�r ytterligare information om <a Menus>Menyerna</a> och olika s�tt att <a Moves>Ange drag</a> h�nvisas till
andra hj�lpsidor.
</p>

<h3>Att navigera i partier</h3>
<p>
Navigationsknapparna vid br�det har f�ljande funktioner (fr�n v�nster till h�ger):
</p>
<ul>
<li> <button tb_start> G� till utg�ngsst�llningen. </li>
<li> <button tb_prev> G� tillbaka ett drag. </li>
<li> <button tb_next> G� fram�t ett drag. </li>
<li> <button tb_end> G� till slutst�llningen. </li>
<li> <button tb_invar> G� in i varianten. </li>
<li> <button tb_outvar> G� ur varianten. </li>
<li> <button tb_addvar> L�gg till ny variant. </li>
<li> <button tb_play> Start/stopp f�r autospelsl�ge (se nedan). </li>
<li> <button tb_trial> Start/stopp f�r <a Moves Trial>F�rs�ksl�ge</a>. </li>
<li> <button tb_flip> Rotera br�det 180 grader. </li>
<li> <button tb_coords> Visa/d�lj koordinater. </li>
</ul>

<h4><name Autoplay>Autospelsl�ge</name></h4>
<p>
I autospelsl�ge g�r Scid automatiskt b�da spelarnas drag i det aktuella partiet. F�rdr�jningen mellan varje drag kan anges i
menyn <menu>Alternativ: Drag</menu> och sparas n�r du sparar �ndringarna av inst�llningsm�jligheterna.
</p>
<p>
Kortkommandot <b>Ctrl+Z</b> startar eller avbryter autospelsl�get. Du kan ocks� g� ur autospelsl�ge genom att trycka
 <b>Esc</b>-tangenten.
</p>
<p>
Om du startar autospelsl�ge n�r <a Analysis>Analysf�nstret</a> �r �ppet <term>kommenteras</term> partiet: st�llningsbed�mningen 
och analysen av varje st�llning l�ggs till som en ny variant vid varje drag.
Se hj�lpen f�r <a Analysis>Analysf�nstret</a> f�r mer information.
</p>

<h3>Partiinformation</h3>
<p>
Nedanf�r br�det visas information om det aktuella partiet. Denna del av huvudsk�rmen kallas <term>partiinformationsomr�det</term>.
P� de tre f�rsta raderna ges grundinformation s�som spelarnas namn, resultat, datum och spelplats. Den fj�rde raden aktuell
st�llning och n�sta drag.
</p>
<p>
Rad fem visar <a ECO>ECO</a> (Encyclopedia of Chess
Openings) koden f�r den aktuella st�llningen, om st�llningen ing�r i den ECO-fil som anv�nds.
</p>
<p>
N�r man h�gerklickar p� partiinformationsomr�det visas en meny med inst�llningsm�jligheter som �r relevanta f�r just denna del av
programmet. Du kan t ex v�lja att d�lja n�sta drag (anv�ndbart om du tr�nar genom att "gissa" n�sta drag i  partiet) eller ta bort
/�terta det aktuella partiet. Kortkommandot f�r denna funktion �r funktionsknappen F9.
</p>

<h4>Slutspelsdatabaser</h4>
<p>
Partiinformationsomr�det visar resultaten fr�n slutspelsdatabaserna om du har n�gra installerade och om st�llningen �terfinns 
i dessa. Se hj�lpsidan f�r <a TB>Slutspelsdatabaser</a> f�r mer information.
</p>

<h3>Statusraden</h3>
<p>
Statusraden (l�ngst ner i huvudf�nstret) visar information om den aktuella databasen.
Det f�rsta f�ltet visar partiets status: <b>XX</b> betyder att det har f�r�ndrats men �nnu inte sparats, medan <b>--</b> 
betyder att partiet inte har �ndrats, <b>%%</b>, slutligen, betyder att databasen �r skrivskyddad (det g�r inte att �ndra i partiet.).
</p>
<p>
Om du vill, kan du �ppna databasen skrivskyddad. �ndra r�ttigheterna till scid-filerna (eller enbart indexfilen) genom att i UNIX(-lika)
system ge kommandot:
<b>chmod a-w myfile.si3</b>
vid kommandoraden.I MS-DOS eller Windows �ndrar du filattributet Arkiv med Attrib filnamn +A (i MS-DOS) eller Filhanteraren/Utforskaren etc. (i Windows).)
</p>
<p>
Statusraden visar ocks� hur m�nga partiet som ing�r i det aktiva <a Searches Filter>Filtret</a>.
</p>

<p><footer>(Uppdaterad: 3.6.11-beta Januari 2007)</footer></p>
}

####################
### Menus help screen:

set helpTitle(W,Menus) "Menyerna"
set helpText(W,Menus) {<h1>Menyerna</h1>

<h3><name File>Arkiv</name></h3>
<ul>
<li><menu>Ny</menu>: Skapar en ny, tom, Scid databas.</li>
<li><menu>�ppna</menu>: �ppnar en befintlig Scid-databas.</li>
<li><menu>St�ng</menu>: St�nger den aktiva Scid-databasen.</li>
<li><menu>S�k filer</menu>: �ppnar <a Finder>S�kdialogen</a> f�r filer.</li>
<li><menu>Bokm�rken</menu>: Hanterar <a Bookmarks>bokm�rken</a>.</li>
<li><menu>Nytt bokm�rke</menu>: Markerar den aktiva st�llningen i partiet som ett bokm�rke.</li>
	<li><menu>Spara bokm�rke</menu>: Sparar bokm�rket f�r den aktiva st�llningen i partiet.</li>
	<li><menu>Redigera bokm�rken</menu>: Redigerar dina bokm�rken.</li>
	<li><menu>Visa bokm�rken som lista</menu>: Visar bokm�rkena som lista, inte som undermenyer.</li>
	<li><menu>Visa bokm�rken i undermenyer</menu>: Visar bokm�rkena som undermenyer, inte som en lista.</li>
	</ul>
<li><menu>Databasverktyg</menu>: <a Maintenance>Underh�ll</a> databasen.</li>
    </li>
	<ul>
	<li><menu>Verktygsf�nster</menu>: �ppnar/ st�nger verktygsf�nstret.</li>
	<li><menu>Klassificera partier enligt ECO</menu>: Klassificerar alla partier enligt ECO-systemet.</li>
	<li><menu>Ta bort dubbletter</menu>: Tar bort <a Maintenance Twins>Dubblettpartier</a> i databasen.</li>
	<li><menu>Namn</menu>: Ers�tter alle f�rekomster av en spelar-,
      resultat-, ort- eller rundeinmatning.</li>
      </ul>
      <li><menu>Skrivskyddad</menu>: Avl�gsnar tempor�rt redigeringsm�jligheterna till databasen.</li>
<li><menu>Byt databas</menu>: Byter till en annan �ppnad databas.</li>
	<ul>
		<li><menu>Base 1/2/3/4/5</menu>: H�r byter du mellan de olika databaserna i databasv�xlarna, inklusive <a Clipbase>Urklippsdatabasen</a>.</li>
	</ul>
	<ul>
	<li><menu>Komprimera databasen</menu>: Komprimerar databasen, avl�gsna borttagna partier och oanv�nda namn.</li>
	<li><menu>Sortera databasen</menu>: Sorterar partierna i den aktiva databasen.</li>
  	<li><menu>S�k dubbletter"</menu>: �ppnar/ st�nger dubblettf�nstret f�r att s�ka dubblettpartier.</li>
	<li><menu>Stavningskontroll</menu>: Namnredigerar och stavningskontrollerar.</li>
		<ul>
		<li><menu>Redigera namn</menu>: Redigerar spelarnamn utifr�n r�ttstavningsfilen.</li>
		<li><menu>Stavningskontrollera namn</menu>: Stavningskontrollerar namn utifr�n r�ttstavningsfilen.</li>
		<li><menu>Stavningskontrollera evenemang</menu>: Stavningskontrollerar evenemang utifr�n r�ttstavningsfilen.</li>
		<li><menu>Stavningskontrollera platser</menu>: Stavningskontrollerar platser utifr�n r�ttstavningsfilen.</li>
		<li><menu>Stavningskontrollera ronder</menu>: Stavningskontrollerar ronder utifr�n r�ttstavningsfilen.</li>
  		</ul>
	</ul>	
<li><menu>Avsluta</menu>: Avslutar Scid. </li>
</ul>

<h3>Redigera</h3>
<ul>
<li><menu>L�gg till variant</menu>: Skapar en variant vid denna st�llning. Antingen f�r n�sta drag, eller f�r f�reg�ende drag om det �r det f�rsta draget.</li>
<li><menu>Ta bort variant</menu>: Visar en undermeny med de borttagbara varianterna.</li>
<li><menu>Skapa huvudvariant</menu>: Upph�jer en av varianterna till huvudvariant.</li>
<li><menu>Skapa nytt textdrag</menu>: G�r en av varianterna till nytt partidrag.</li>
<li><menu>Testa en id�</menu>: Sl�r p� <a Moves Trial>Testl�ge</a> f�r att tillf�lligt testa en id�. F�r�ndrar inte partiet.</li>
<li><menu>Ta bort</menu>: Avl�gsnar kommentarer eller varianter ur partiet.</li>
<br>
<li><menu>T�m Clipbase</menu>: T�mmer Urklippsdatabasen <a Clipbase>Clipbase</a> p� partier.</li>
<li><menu>Kopiera partiet till Clipbase</menu>: Kopierar det aktuella partiet till Urklippsdatabasen <a Clipbase>Clipbase</a>.</li>
<li><menu>Klistra in det senaste Clipbasepartiet</menu>: Klistrar in det aktiva partiet i <a Clipbase>Clipbase</a> i den aktiva databasen och g�r det aktivt.</li>
<br>
<li><menu>Skapa st�llning</menu>: Skapar en utg�ngsst�llning f�r aktuellt parti.</li>
<li><menu>Kopiera st�llning</menu>: Kopierar den aktuella st�llningen i FEN-kod till Urklippsdatabasen.</li>
<li><menu>Klistra in utg�ngsst�llning</menu>: Klistrar in st�llningen fr�n aktuellt parti i den tempor�ra databasen.</li>
</ul>

<h3>Partier</h3>
<ul>
<li><menu>Nytt parti</menu>: �terst�ller br�det inf�r ett nytt parti (detta tar bort alla �ndringar).</li>
<li><menu>Ladda f�rsta/f�reg�ende/n�sta/sista partiet</menu>: Dessa laddar respektive parti i <a Searches Filter>S�kfiltret</a>.</li>
<li><menu>Ladda om partiet</menu>: Laddar om aktuellt parti och tar bort alla gjorda �ndringar..</li>
<li><menu>Ladda parti slumpm�ssigt</menu>:  Laddar ett av datorn slumpm�ssigt valt parti.</li> 
<li><menu>Ladda parti nummer...</menu>: Laddar ett parti genom att ange dess nummer.</li>
<br>
<li><menu>Spara: Ers�tt parti...</menu>: Sparar partiet och ers�tter tidigare version.</li>
<li><menu>Spara: Nytt parti...</menu>: Sparar det aktuella partiet och l�gger till det till databasen.</li>
<br>
<li><menu>Identifiera �ppningen</menu>: G�r till den mest detaljerade st�llningen i ECO-boken.</li>
<li><menu>G� till drag nummer...</menu>: G�r till ett specifikt drag i partiet.</li>
<li><menu>Hitta nyhet...</menu>: Hittar det f�rsta draget i partiet som inte spelats tidigare.</li>
</ul>

<h3>S�k</h3>
<ul>
<li><menu>�terst�ll s�kfilter</menu>: �terst�ller <a Searches Filter>S�kfiltret</a> s� att alla partiet ing�r i urvalet.</li>
<li><menu>Omv�nt filter</menu>: Tar med de partier som utesluts av filtret.</li>
<br>
<li><menu>Aktuell st�llning...</menu>: S�ker partier med <a Searches Board>Den aktuella st�llningen</a> p� br�det.</li>
<li><menu>I huvud...</menu>: Anv�nder <a Searches Header>Fast information</a> (spelare, evenemang, plats, mm).</li>
<li><menu>Material/St�llning...</menu>: S�ker baserad p� <a Searches Material>Material</a> eller <a Searches Pattern>St�llning</a>.</li>
<br>
<li><menu>Anv�nd s�kfil...</menu>: Anv�nder en fil med <a Searches Settings>lagrade</a>.</li>
</ul>

<h3>F�nster</h3>
<ul>
<li><menu>Kommentarseditor</menu>: �ppnar/ st�nger <a Comment>Kommentarseditorn</a>.</li>
<li><menu>Partilista</menu>: �ppnar/ st�nger <a GameList>Partilistan</a>.</li>
<li><menu>PGN f�nster</menu>: �ppnar/ st�nger <a PGN>PGN-f�nstret</a>.</li>
<li><menu>Spelarf�rteckning</menu>: �ppnar/ st�nger en f�rteckning �ver spelarna i den aktiva databasen.</li> 
<li><menu>Turneringar</menu>: Listar <a Tmt>Turneringar</a>.</li>
<br>
<li><menu>Databasv�xlaren</menu>: �ppnar/ st�nger <a Switcher>Databasv�xlaren</a>. Databasv�xlaren underl�ttar byte mellan olika databaser
och kopiering av partier fr�n den ena databasen till den andra.</li>
<li><menu>Databasverktyg</menu>: �ppnar/ st�nger <a Maintenance>Verktygsf�nstret</a>.</li>
<br>
<li><menu>ECO f�nster</menu>: �ppnar/ st�nger <a ECO browser>ECO bl�ddraren</a>.</li>
<li><menu>Repetoareditor</menu>: �ppnar/ st�nger verktyget f�r <a repetoire>Spel�ppningshantering</a>.</li>
<li><menu>Statistikf�nster</menu>: �ppnar/ st�nger <term>Statistikf�nstret</term>. H�r hittar du en statistisk sammanfattning av partierna i  
 <a Searches Filter>S�kfiltret</a>.</li>
<li><menu>Tr�df�nster</menu>: �ppnar/ st�nger <a Tree>Varianttr�det</a>.</li>
<li><menu>Slutspelsdatabas</menu>: �ppnar/ st�nger slutspelsdatabasf�nstret som ger dig viss information om <a TB>Slutspelsdatabaserna</a>.</li>
</ul>

<h3>Verktyg</h3>
<ul>
<li><menu>Analysmotor...</menu>: Startar/ stoppar en analysmotor, t ex Crafty, som kontinuerligt bed�mmer den aktuella st�llningen
p� br�det i ett <a Analysis>Analysf�nster</a>.</li>
<li><menu>Analysmotor 2...</menu>: Startar/ stoppar en andra analysmotor, t ex Crafty.</li>
<li><menu>Resultattabell</menu>: Skapar en <a Crosstable>Resultattabell</a> f�r den aktuella turneringen/matchen som det aktuella partiet ing�r i</li>
<li><menu>Eposthanteraren</menu>: �ppnar/ st�nger <a Email>Eposthanteraren</a> f�r hantering av korrespondensschack.</li>
<br>
<li><menu>�ppningsrapport</menu>: Skapar en <a OpReport>�ppningsrapport</a> utifr�n den aktuella st�llningen.</li>
<li><menu>S�k material</menu>: �ppnar dialog f�r att <a PTracker>S�ka efter en viss materiell balans</a>.</li>
<br>
<li><menu>Spelarinformation</menu>: Visar/ uppdaterar <a PInfo>Spelarinformation</a> f�r den ene av tv� spelare i det aktuella partiet.</li>
<li><menu>Ratingdiagram</menu>: Skapar ett <a Graphs Rating>Ratingdiagram</a> f�r spelarna i partiet.</li>
<li><menu>Resultatdiagram</menu>: Visar <a Graphs Score>Resultatdiagrammet</a>.</li>
<br>
<li><menu>Exportera aktuellt parti ...</menu>: Sparar aktuellt parti till olika format; text, HTML eller LaTeX. Se vidare
   hj�lpsidan f�r  att <a Export>Exportera</a> partier.</li>
<li><menu>Exportera alla filtrerade partier</menu>: Sparar alla <a Searches Filter>filterade</a> partier till olika format; text, HTML eller LaTeX. Se vidare
   hj�lpsidan f�r  att <a Export>Exportera</a> partier.</li>
<br>
<li><menu>Importera ett parti i PGN-format...</menu>: �ppnar <a Import>Importf�nstret</a> f�r att ange eller klistra in ett parti i 
 <a PGN>PGN-format</a> f�r import till en Scid databas.</li>
<li><menu>Importera flera partier i PGN-format...</menu>: Importerar flera partier i PGN-format fr�n en fil.</li>
</ul>

<h3>Alternativ</h3>
<p>
Denna meny ger tillg�ng till de flesta av de parametrar som styr hur Scid fungerar.
Menyvalet <menu>Spara alternativ</menu> sparar de aktuella inst�llningarna till filen
 "<b>~/.scid/scidrc</b>" (eller <b>scid.opt</b> i katalogen som inneh�ller den exekverbara
scid-filen, Scid.exe, om Windows); denna fil laddas varje g�ng du startar Scid.
</p>

<h3>Hj�lp</h3>
<p>
Denna meny inneh�ller hj�lpfunktioner och ger tillg�ng till bl a f�nstret "Dagens tips"
och startf�nstret som informerar om vilka filer Scid laddat vid uppstart. 
</p>

<p><footer>(Uppdaterad: Scid 3.5, februari 2003)</footer></p>
}
	
####################
### Entering moves help:

set helpTitle(W,Moves) "Ange drag"
set helpText(W,Moves) {<h1>Ange drag</h1>
<p>
I Scid, kan du ange partidrag s�v�l med musen som med tangentbordet. N�r du r�r musmark�ren �ver en ruta p�
br�det kommer du att m�rka att s�v�l rutan som ytterligare en ruta f�r en annan f�rg. Om det finns ett legalt
drag till eller fr�n den ruta du f�r musmark�ren �ver. Detta �r det <term>F�reslagna draget</term>.
Du utf�r detta drag genom att <term>V�nsterklicka</term> med musen. Om detta st�r dig kan du st�nga av denna funktion
i Alternativmenyn.

</p>
<p>
F�r att utf�ra ett annat drag kan du <term>klicka och h�lla nere v�nster</term> musknapp: flytta sedan musen till �nskad
 ruta och sl�pp musknappen.
</p>
<p>
Om du vill kan du utf�ra drag genom att klicka tv� g�nger ist�llet f�r att anv�nda klicka-och-drag tekniken. Klicka d� 
f�rst p� utg�ngsrutan med den <term>Mittersta musknappen</term> och klicka sedan med samma musknapp p� destinationsrutan.
(Tipset g�ller kanske framf�rallt anv�ndare av UNIX(-lika) system, som ofta har stor nytta av 3-knappsm�ss).
</p>

<h4>Ta tillbaka ett drag</h4>
<p>
Man kan ta tillbaka ett drag genom att h�gerklicka med musen. Detta g�r tillbaka ett drag och tar bort det senast utf�rda draget i partiet
eller varianten.
</p>

<h4>Ers�tt tidigare drag</h4>
<p>
Om du anger ett drag i en st�llning d�r ett drag redan angivits kommer Scid att fr�ga om du verkligen vill ers�tta den tidigare
draget (draget och alla varianter l�ngre fram som �r beroende av draget tas bort), eller om du vill skapa en ny variant ist�llet.
En del anv�nder tycker att fr�gan �r st�rande och vill alltid ers�tta det tidigare draget, s� man kan konfigurera Scid till att inte
st�lla denna fr�ga. Du hittar m�jligheten i  menyn <menu>Alternativ: Drag</menu> "<i>Fr�ga f�re ers�tt drag</i>".
</p>

<h4><name Trial>Testl�ge</name></h4>
<p>
Om du g�r igenom ett parti och kommer till en st�llning d�r du vill testa en id� utan att p�verka det registrerade partiet s� v�ljer du
<b>Testa en id�</b> fr�n menyn <menu>Redigera</menu> f�r att s�tta p� testl�ge. I testl�ge kan du g�ra drag och f�r�ndringar av partiet som
�r tempor�ra, dvs de sparas inte n�r du �terg�r fr�n testl�ge.
</p>

<h3><name Mistakes>R�tta fel</name></h3>
<p>
Om du skriver in ett parti och pl�tsligt uppt�cker ett fel flera drag tidigare �r det m�jligt att r�tta till detta utan att 
beh�va g�ra om alla drag efter feldraget. Det enda s�ttet �r att redigera PGN-versionen av partiet: �ppna <a Import>Importf�nstret</a>, 
v�lj Klistra in aktivt parti, korrigera felet och v�lj d�refter "Importera".
</p>

<h3>Ange drag via tangentbordet</h3>
<p>
Du kan ange drag via tangentbordet genom att helt enkelt skriva in dem med bokst�ver och siffror. L�gg m�rke till att dragen
ska anges i <term>SAN-notation</term>, <i>utan</i> (x) tecknet f�r slag eller (=) tecknet f�r promovering. Dragnotationen �r 
inte versal/gemenk�nslig s� t ex:
[n][f][3] �r samma drag som Nf3 -- men kontrollera med noten nedan f�r drag som st�r i konflikt med varandra.
</p>
<p>
F�r att s�kerst�lla att inga drag �r prefix f�r ett annat drag s� anv�nds en s�rskild metod att ange rockad. Kort och l�ng rockad
representeras med hj�lp av bokst�ver som f�ljer:
kort rockad anges med  [O][K]
l�ng rockad anges med [O][Q] ist�llet f�r det vanliga O-O och O-O-O.
</p>
<p>
N�r du anger drag kommer du i statusraden att se en lista �ver giltiga drag. Du kan, genom att trycka <b>[Mellanslag]</b> v�lja det f�rsta i listan och f�ra in det
i partiet. F�r att ta bort tecken anv�nder du de vanliga raderingstangenterna.
</p>
<p>
<b>OBS</b> gemena tecken kopplas i f�rsta hand till b�nder, vilket betyder att [b]kan betyda b-bonden ist�llet f�r l�paren (Bishop). Om du hamnar
i situationer n�r konflikter uppst�r m�ste du ist�llet ange pj�serna med versaler (B) i detta fallet.
</p>
<b>�vers�ttarens kommentar</b> Scid f�rst�r inte svenska. Detta betyder att du inte kan anv�nda de svenska f�rkortningarna till att ange drag. [s][f][6] 
f�rst�s inte av Scid (d�remot funkar [n][f][6] utm�rkt). Om du vill anv�nda tangentbordet att skriva in drag f�r du ist�llet anv�nda notationen [g][8][f][6] f�r
samma drag.
</p>
<h4>Autokomplettering</h4>
<p>
I Alternativmenyn kan du sl� p� eller av <term>Autokomplettering</term>
av drag.
Med denna p�slagen g�rs draget s� fort du skrivit in tillr�ckligt mycket f�r att s�rskilja det fr�n andra m�jliga drag. Exempelvis r�cker det att skriva [n][f] ist�llet
f�r [n][f][3] f�r draget <b>Nf3</b>i utg�ngsst�llningen.
</p>
<p><b>�vers�ttarens kommentar</b> Scid f�rst�r som sagt inte svenska. D�remot fungerar det med rutangivelsen om t ex pj�sen p� g1 bara har ett f�lt 
att g� till.</p>

<h3><name Null>Ange null-drag</name></h3>
<p>
<a Annotating Null>Null</a> (tomma, planerade) drag kan vara anv�ndbara i  kommentarer f�r att hoppa �ver den ena spelarens drag. Du anger null-drag
genom att sl� den ena kungen med den andra, eller via tangentbordet genom att skriva  "<b>--</b>" (minustecknet tv� g�nger).
</p>
<p><b>�vers�ttarens kommentar</b> "null" �r en dataterm f�r att beskriva ingenting (till skillnad mot noll som har ett v�rde om dock noll, null har inget v�rde).
Shane anv�nder termen null h�r, n�gon som har f�rslag p� b�ttre i den svenska �vers�ttningen? Kolla introduktionssidan f�r att f�resl� n�gonting.</p>

<h3>Ange de vanligaste kommentarsymbolerna</h3>
<p>
Du kan �ven ange <a NAGs>Kommentarsymboler</a> via tangentbordet utan att beh�va anv�nda <a Comment>Kommentarseditorn</a>. 
F�ljande lista kan anges via tangentbordet:
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

set helpTitle(W,Searches) "S�ka i Scid"
set helpText(W,Searches) {<h1>S�ka i Scid</h1>
<p>
I Scid kan man s�ka information p� flera olika s�tt. 
Det finns tre huvudmetoder att anv�nda sig av beroende p� vilken typ av information man
�r ute efter:
<ul>
<li><b>1)</b> utifr�n den aktuella st�llningen p� br�det, </li>
<li><b>2)</b> utifr�n specifikt material eller en specifik st�llningstyp; och </li>
<li><b>3)</b> utifr�n fast information, t ex spelare, ort, resultat eller datum. </li>
</ul>
<p>
Ut�ver dessa metoder kan man anv�nda sig av en automatisk s�kfunktion, <a Tree>Tr�df�nstret</a>, som f�rklaras
separat.
</p>

<h3><name Filter>S�kfiltret</name></h3>
<p>
S�kningar baseras i  Scid p� <term>Filter</term>.
Ett filter representerar en delm�ngd av den aktiva databasen. Vid varje specifikt tillf�lle kommer ett parti att antingen vara
del av denna delm�ngd (filtret) eller uteslutas av detta. I varje typ av s�kning (se ovan) kan du v�lja att begr�nsa, ut�ka eller
ignorera det aktiva filtret och ist�llet s�ka i hela databasen. Detta g�r att man stegvis kan bygga komplicerade s�kningar. 
Du kan ocks� kopiera alla filtrerade partier fr�n den ena databasen till den andra genom att anv�nda <a Switcher>Databasv�xlaren</a>.
</p>

<p>
N�r du s�ker p� exakt st�llning, <a Tree>Tr�d</a> eller Material/St�llningstyp, sparas dragnumret i den f�rsta st�llningen och varje
parti med identisk st�llning lagras i minnet s� att man, n�r man senare laddar de frams�kta partierna, automatiskt kommer till den st�llning
som var av intresse (som s�kningen grundades p�).
</p>
<p>
<b>OBS</b> s�kningen g�ller endast textdragen, inte varianterna.
</p>

<h3><name Board>S�k: Aktuell st�llning</name></h3>
<p>
Med denna metod hittas partier med samma st�llning som det p� br�det i huvudf�nstret. Rockadm�jligheter och 
r�ttigheter att g�ra <i>En passant</i> ignoreras. Det finns fyra undertyper att v�lja p�, samtliga kr�ver att st�llningen har exakt samma material och spelare vid draget f�r att en tr�ff ska
anses ha intr�ffat:
<ul>
<li> [1] exakt (de b�da st�llningarna m�ste vara exakt lika), </li>
<li> [2] b�nder (bondestrukturen m�ste vara identisk, men de �vriga pj�sernas placering kan variera), </li>
<li> [3] linjer (antalet vita och svarta b�nder p� varje linje m�ste vara identisk - i �vrigt kan pj�splaceringen variera), och slutligen; </li>
<li> [4] material (b�nder och pj�ser kan st� var som helst p� br�det.). </li>
</ul>
<p>
Att s�ka p� bondest�llning �r anv�ndbart n�r man studerar spel�ppningar med likartad bondstruktur, medan att s�ka p� linjer och material �r l�mpliga metoder f�r
att finna liknande st�llningar i slutspel. N�r man s�ker p� specifika st�llningar kan man skapa den f�rst (fr�n menyvalet <menu>Redigera: Skapa st�llning</menu>) och starta s�kningen d�rifr�n.
(Man kan naturligtvis ocks� spela upp st�llningen p� br�det, <i>�vers�ttarens anm�rkning</i>).
</p>
<p>
Du kan ange att s�kningen �ven ska leta i varianter (ist�llet f�r att bara inkludera de egentliga partidragen) genom att markera kryssrutan <b>S�k i varianter</b>, 
men detta kan g�ra s�kningen l�ngsammare om databasen �r stor och har m�nga partier med varianter.
</p>

<h3><name Material>S�k: Material/st�llningstyp</name></h3>
<p>
Denna s�kning �r anv�ndbar n�r man vill finna slut- eller mittspelsteman. Du kan specificera minimalt och maximalt antal av varje pj�styp, och hitta st�llningar
av typen "L�pare p� f7" eller "Bonde p� f-linjen". Det finns ett antal vanliga st�llningstyper f�rdefinierade, t ex "Torn och Bondeslutspel" eller "Isolerade d-b�nder".
</p>
<p>
<b>Tips:</b><br>
Tids�tg�ngen f�r denna typ av s�kning kan variera kraftigt. Man kan minska tiden som beh�vs genom att anv�nda sig av f�rnuftiga begr�nsningar.
Om man, som exempel,  vill unders�ka slutspel kan man s�tta det minimala antalet drag partiet ska inneh�lla till 20. D� kommer alla partier 
med f�rre �n 20 drag att ignoreras.
</p>

<h3><name Header>S�k: fasta uppgifter ("header search")</name></h3>
<p>
Denna s�kning anv�nds f�r att finna aspekter p� partier som lagras i partihuvudet (j�mf�r med eposthuvud) s�som datum, resultat, plats och ratingtal. Den
kr�ver ingen avkodning av dragen i partiet. F�r att en tr�ff ska registreras kr�vs att alla f�lt du specificerar st�mmer �verens. Namnf�lten  (Vit, Svart, 
Evenemang, Plats och Rond) �r versal/gementoleranta. Tr�ffar registrerars p� all text i dessa f�lt och mellanslag ignoreras .
</p>
<p>
Du kan generera exakta s�kningar och anv�nda jokertecken i huvudf�lten som n�mnts ovan. Jokertecknet  <b>?</b> betyder "Ett
valfritt tecken" medan <b>*</b> betyder "Inget eller flera valfria tecken". Man genererar exakta s�kningar genom att innesluta den text man
�nskar hitta i citattecken ("). Exempel:
</p>

<p>
En s�kning p� platsen <b>USA</b> kommer att generera amerikanska st�der, men �ven <b>Lausanne SUI</b>, vilket du f�rmodligen inte var ute efter! 
Detta l�ser man genom att ist�llet s�ka efter platsen <b>"*USA"</b> (notera citattecknen) som endast kommer att presentera st�der i USA.</p>
<p>
Om du s�ker efter en s�rskild spelare (eller tv� s�rskilda spelare) som vit eller svart och det inte spelar n�gon roll vet som har vilken f�rg v�ljer du med 
f�rdel <b>Ignorera f�rg</b> i st�llet f�r svart/vit i f�rgangivelsen.
</p>
<p>
Avslutningsvis kan fasta s�kningar g�ras f�r att hitta valfri text (VERSAL/gemen-k�nsligt och utan jokertecken) i PGN-versionen av partierna. Du kan
ange upp till tre textstr�ngar, och alla m�ste finnas i ett parti f�r att de ska r�knas som en tr�ff. Denna s�kning �r mycket anv�ndbar n�r det g�ller
kommentarsf�ltet eller extra m�rkord i partierna (exempelvis  <b>f�rlorar p� tid</b> eller <b>Kommentator</b>), eller f�r en dragf�ljd som 
<b>Bxh7+</b> och <b>Kxh7</b> n�r en l�pare har offrats (och accepterats) p� h7.

T�nk dock p� att denna typ av s�kningar kan vara <i>mycket</i> tidskr�vande eftersom alla partier som m�ter vissa kriterier m�ste avkodas och
genoms�kas efter textstr�ngen/-arna. Det �r d�rf�r en bra id� att begr�nsa denna typ av s�kning s� mycket som m�jligt. Exempel:
</p>

<p>
F�r att hitta partier med underpromovering till torn s�ker man p� <b>=R</b> och s�tter <b>F�rvandlingar</b> flaggan till Ja.
F�r att hitta text i kommentarer s�tter du flaggan <b>Kommentarer</b> till Ja.
Om du s�ker p� dragen <b>Bxh7+</b> och <b>Kxh7</b>, kan det vara en id� att begr�nsa partierna till de som har resultatet  1-0 resultatet och inneh�ller
minst 20 halvdrag. Eller g�r en Material-/St�llningstypss�kning f�r att hitta partier d�r l�paren flyttas till h7.
</p>

<h3><name Settings>Spara s�kkriterierna</name></h3>
<p>
I Material/St�llningstyp och Huvuds�kningsf�nstren finns valet att  
<term>Spara inst�llningarna</term>. Detta ger dig m�jligheten att spara de aktuella s�kkriterierna f�r senare anv�ndning.
Kriterierna sparas till en <term>S�kningsfil</term> med fil�ndelsen  .sso. F�r att �teranv�nda en tidigare sparad s�kningfil
v�ljer du <menu>�ppna ...</menu> fr�n menyn <menu>S�k</menu>.
</p>

<h3>S�ktider och ignorerade partier</h3>
<p>
De flesta s�kningar meddelar en hur l�ng tid s�kningen tog och hur m�nga partier som <term>Ignorerades</term>. Ignorerade partier
�r de som exkluderats fr�n en s�kning utan att n�got av dess drag har avkodats (fr�n Scids databasformat). Detta baseras p� information
som lagrats i index. Se vidare hj�lpfilen om <a Formats>Filformat</a> f�r ytterligare information. 
</p>

<p><footer>(Uppdaterad: Scid 3.0, november 2001)</footer></p>
}

#################
### Clipbase help:

set helpTitle(W,Clipbase) "Urklippsdatabasen"
set helpText(W,Clipbase) {<h1>Urklippsdatabasen</h1>
<p>
F�rutom de databaser du �ppnar sj�lv, �ppnar Scid ytterligare en - <term>Urklippsdatabasen</term>. Urklippsdatabasen,
fungerar precis som alla andra databaser, med ett undantag. Den existerar bara i datorns arbetsminne och sparar inte data
n�gonstans permanent. Urklippsdatabasen t�ms s�ledes n�r du st�nger av datorn.
</p>
<p>
Urklippsdatabasen �r anv�ndbar som en tillf�llig lagringsplats, f�r att sl� samman s�kresultat fr�n olika databaser, eller f�r att man d�r
kan behandla resultat fr�n en s�kning som en egen databas. 
</p>
<p>
Antag, exempelvis, att du vill f�rbereda dig f�r en s�rskild motst�ndare. Du har s�kt igenom databasen efter partier av denne d�r motst�ndaren
spelar vit. Kopiera alla partier i <a Searches Filter>S�kfiltret</a> till Urklippsdatabasen. Du kan g�ra det genom att i <a Switcher>Databasv�xlaren</a>
 dra dem fr�n deras ordinarie databas till Urklippsdatabasen. D�refter kan du �ppna Urklippsdatabasen och unders�ka partierna i  <a Tree>Tr�df�nstret</a>, 
till exempel f�r att kartl�gga motst�ndarens �ppningsrepetoar.
</p>
<p>
Observera att du kan kopiera partier fr�n en databas till en annan utan att anv�nda Urklippsdatabasen som mellanlagringsplats. Notera ocks� att
Urklippsdatabasen <i>inte</i> kan st�ngas via menyvalet <menu>Arkiv: St�ng</menu>medan du �r i Urklippsdatabasen. Det som h�nder d� �r
motsvarigheten till  <menu>Redigera: �terst�ll Urklippsdatabasen</menu>, dvs databasen t�ms.
</p>
<p>
Du kan maximalt ha 100000 partier i minnet samtidigt.
</p>

<p><footer>(Uppdaterad: Scid 2.5,  juni 2001)</footer></p>
}

#################################
### Variations and comments help:

set helpTitle(W,Annotating) "Kommentera partier"
set helpText(W,Annotating) {<h1>Kommentera partier</h1>
<p>
I Scid kan l�gga till noter till partierna. Det finns tre typer av anteckningar du kan l�gga till till varje drag:
symboler, kommentarer och varianter.
</p>

<h3>Symboler och kommentarer</h3>
<p>
Symboler anv�nds f�r st�llningsbed�mningar om vem som st�r b�st (t ex "+-" eller "=") , om draget som just gjordes var bra eller d�ligt
(t ex "!" eller "?") medan kommentarer kan best� av valfri text. F�r att l�gga till symboler och kommentarer anv�nder man
<a Comment>Kommentarseditorn</a>. Det finns ocks� en s�rskild hj�lpsida f�r <a NAGs>Standardsymbolerna</a>.
</p>
<p>
T�nk p� att �ven om varje drag kan ha fler symboler, kan det bara ha en kommentar. En kommentar f�r f�rsta draget skrivs ut som 
text f�re partidragen. 
</p>

<h3><name Vars>Varianter</name></h3>
<p>
En <term>variant</term> �r en alternativ forts�ttning av partiet som skulle ha kunnat utf�ras vid n�got
tillf�lle i partiet. Varianter kan inneh�lla kommentarer, symboler och varianter. Knappen m�rkt "<b>V</b>" 
ovanf�r br�det i huvudf�nstret, samt valm�jligheter fr�n menyn <menu>Redigera</menu> kan anv�ndas till att skapa,
navigera i och redigera varianter.
</p>

<h4>Kortkommandon</h4>
<p>
N�r det finns varianter till ett drag visas dem i partiinformationsomr�det. Den f�rsta varianten �r <b>v1</b>, den andra
�r <b>v2</b>, osv. F�r att f�lja en variant kan man klicka p� den, eller trycka  "<b>v</b>" f�ljt av variantens nummer 
(Om det bara finns en variant r�cker det med att trycka <b>v</b>.). Kortkommandot f�r att g� ur en variant �r "<b>z</b>".
</p>

<h3><name Null>Null-drag</name></h3>
<p>
Det kan ibland vara anv�ndbart att hoppa �ver drag i varianter. Du kan exempelvis till draget 14.Bd3 l�gga till en variant och
n�mna att det hotar 15.Bxh7+ Kxh7 16.Ng5+ med angrepp. Du kan ocks� g�ra detta genom att anv�nda <term>Null-drag</term>
mellan 14.Bd3 och 15.Bxh7+, i exemplet ovan. Ett null-drag visas som "<b>--</b>" och infogas genom att med musen utf�ra det
ogiltiga draget att med kungen sl� den andra kungen, eller att helt enkelt skriva in "<b>--</b>" (tv� minustecken).
</p>
<p>
Observera att null-drag inte ing�r i PGN standarden, s� om du vill exportera partier som inneh�ller null-drag till en PGN-fil m�ste du 
v�lja mellan att bevara null-dragen(-t) eller konvertera dem till kommentarer f�r att bibeh�lla exportm�jligheter till andra
program. Se hj�lpsidan f�r att <a Export>Exportera</a> partier f�r mer information.
</p>

<p><footer>(Uppdaterad: Scid 3.4, juli 2002)</footer></p>
}

####################
### Analysis window:

set helpTitle(W,Analysis) "Analysf�nstret"
set helpText(W,Analysis) {<h1>Scids Analysf�nster</h1>

<h3>Analysf�nster</h3>
<p>
Scids analysf�nster visar analysen fr�n en schackmotor
av den aktuella positionen. N�r positionen �ndras skickar Scid den 
nya positionen till schackmotorn samt visar dess v�rdering av 
denna position. 
</p>

<p>
V�rderingen som visas i analysf�nstret �r alltid fr�n vits perspektiv, 
s� en negativ v�rdering indikerar att svart st�r b�ttre. Den nedre delen av f�nstret 
(med scrollrutan) visar historiken f�r v�rderingar producerat av schackprogrammet f�r den 
aktuella positionen, s� att du kan se hur v�rderingen har �ndrats. 
</p>

<p>
F�r att l�gga till det b�sta draget valt av en schackmotor som ett nytt drag i det aktuella partiet 
klickar du p� L�gg till drag knappen. 
</p>

<h3>Schackmotorlistan</h3>

<p>
Scid beh�ller en lista p� de schackmotorer du har anv�nt, tillsammans med en uppskattad Elo-rating 
(om du antar en) och datumet n�r varje schackmotor sist anv�ndes. Du kan sortera schackmotorlistan 
efter namn, Elo-rating, eller datum. V�lj Ny eller �ndra knapparna f�r att l�gga till en ny schackmotor till 
listan eller �ndra detaljerna f�r en existerande schackmotor. 
</p>

<h3>Schackmotorkommandon och kataloger</h3>

<p>
F�r varje schackmotor m�ste du specificera den exekuterbara filen att k�ra samt i vilken katalog Scid ska 
k�ra den i. 
</p>

<p>
Den mest sannorlika orsaken till problem att starta en schackmotor �r valet av vilken katalog schackmotorn 
ska k�ra i. Vissa schackmotorer kr�ver en inst�llnings- eller �ppningsboksfil i sina startkataloger 
f�r att fungera bra. Andra schackmotorer (som Crafty) skriver loggfiler till katalogen de startar i, s� 
du m�ste k�ra dem i en katalog d�r du har tillst�nd att skriva i. Om kataloginst�llningarna f�r en 
schackmotor �r ".", kommer Scid att starta en schackmotor i den aktuella katalogen. 
</p>

<p>
S� om en schackmotor som borde fungera bra i Scid inte startar f�rs�k att �ndra dess kataloginst�llning. 
F�r att undvika att schackmotorer skapar loggfiler i m�nga olika kataloger rekommenderar jag att starta schackmotorer 
i katalogen med Scids anv�ndarfiler (detta �r d�r Scid.exe filen finns i Windows, 
eller ~/.scid/ i Unix); det finns en knapp i dialogrutan f�r att �ndra schackmotordetaljer med namnet 
Scid.exe-katalogen i Windows eller ~/.scid i Unix som l�ter dig v�lja vilken schackmotor som ska starta i denna katalog. 
</p>

<h3>Tr�ning</h3>

<p>
Med Tr�ningsknappen kan du spela drag mot schackprogrammet. Tiden f�r varje drag 
�r fixerad och analysresultet visas inte d�. 
</p>

<h3>Kommentera ett parti</h3>

<p>
L�gg till variation knappen i analysf�nstret l�gger till den aktuella v�rderingen och b�sta analyserade
dragf�ljd som en ny variation i partiet. 
</p>

<p>
Du kan g�ra detta automatiskt f�r ett antal drag (kommentera partiet) genom att klicka p� 
kommentarknappen. Detta fr�gar dig efter n�gra kommentarsalternativ och sedan startar 
sj�lvspelsmod. N�r sj�lvspelsmod anv�nds och analysf�nstret �r �ppet l�ggs 
en variation inneh�llande v�rderingen och b�sta dragf�ljden automatiskt till f�r varje 
position n�r sj�lvspelsmod g�r igenom partiet. Bara positioner fr�n den aktuella 
positionen till slutet av partiet (eller tills du l�mnar sj�lvspelsmod) kommenteras, 
s� du kan hoppa �ver att kommentera �ppningsdragen genom att g� till en mittspelsposition 
innan du startar sj�lvspel. 
</p>

<p>
F�r att avbryta kommentarer st�ng av sj�lvspelsmod, till exampel genom att trycka
ner Esc-tangenten i huvudf�nstret. 
</p>

<p>
Observera att f�r enkelhet finns kommentarknappen bara tillg�nglig i f�nstret �ppnat som 
schackmotor 1. Om du �ppnar en schackmotor som schackmotor 2 kan du inte anv�nda den f�r att
kommentera partiet. 
</p>

<h3>Analysbr�det</h3>

<p>
Genom att klicka p� schackbr�deknappen i ett analysf�nster visar du eller d�ljer du analysbr�det, 
som visar positionen vid slutet av den av den b�sta funna aktuella dragf�ljden hittad av 
schackmotorn. 
Detta fungerar f�r de flesta Scid-kompatibla schackmotorer men inte f�r alla; 
det beror p� den dragnotation som schackmotorn anv�nder. 
</p>

<h3>Schackmotorprioritet</h3>

<p>
Om en schackmotor anv�nder f�r mycket CPU-tid och p�verkar anv�ndningen av Scid eller 
andra program kan det hj�lpa att s�tta p� "L�g CPU-prioritet" i proxyn; 
det ger schackmotorn en l�g prioritet f�r CPU-anv�ndning. 
</p>

<h3>Gr�nssnittsdetaljer</h3>

<p>
F�r att anv�nda analysf�nstret beh�ver du ett schackprogram som st�der WinBoard/Xboard-protokollet. 
</p>

<p>
Scid skickar kommandorna <b>"xboard"</b>,<b>"post"</b> och <b>"protover 2"</b> till en schackmotor n�r den startar, 
och anv�nder <b>"setboard"</b> och <b>"analyze"</b> kommandorna f�r mer effektiv kommunikation 
om schackprogrammet svarar vilket indikerar att det st�der dem. Om en schackmotor inte st�der 
<b>"setboard"</b> kommandot kan det inte analysera ett parti som b�rjar med en 
ickestandard startposition. 
</p>

<p>
F�r program som inte st�der analyskommandot skickar Scid f�ljande 
kommandon varje g�ng positionen �ndras: <b>"new"</b> och <b>"force"</b>, 
sedan dragen i partiet till den aktuella position sedan <b>"go"</b>. 
</p>

<p>
Bob Hyatts utm�rkta gratis schackmotor Crafty �r vad jag anv�nder och rekommenderar f�r 
analysf�nstret, men m�nga andra WinBoard eller XBoard kompatibla schackmotorer har 
anv�nts framg�ngsrikt med Scid. N�gra nedladdningssajter f�r n�gra schackmotorer listas nedan. 
</p>

<p>
Crafty: <url ftp://ftp.cis.uab.edu/pub/hyatt/>ftp://ftp.cis.uab.edu/pub/hyatt/</url> 
</p>

<p>
Yace: <url http://home1.stofanet.dk/moq/>http://home1.stofanet.dk/moq/</url> 
</p>

<p>
Phalanx: <url ftp://ftp.math.muni.cz/pub/math/people/Dobes/>ftp://ftp.math.muni.cz/pub/math/people/Dobes/</url> 
</p>

<p>
Comet: <url http://members.aol.com/utuerke/comet/>http://members.aol.com/utuerke/comet/</url> 
</p>

<p>
Gnuchess: <url http://www.gnu.org/software/chess/chess.html>http://www.gnu.org/software/chess/chess.html</url> 
</p>

<p>
The Crazy Bishop: <url http://remi.coulom.free.fr/>http://remi.coulom.free.fr/</url> 
</p>
<p><footer>(Uppdaterat: Scid 3.4, September 2002)</footer></p>
}





###############################
### Comment editor window help:

set helpTitle(W,Comment) "Kommentareditor"
set helpText(W,Comment) {<h1>Scids Kommentareditor</h1>

<h3>Kommentarseditorf�nstret</h3>

<p>
Kommentareditorf�nstret l�ter dig l�gga till eller �ndra kommentarer och symboliska kommentarssymboler 
f�r drag i det aktuella schackpartiet. 
</p>

<h3>Kommentarsymboler</h3>

<p>
Scid anv�nder PGN-standarden f�r kommentarsymboler, accepterar NAGs (Numeriska annotationsglypfer) 
v�rden f�r kommentarer. N�gra av de mest vanliga symbolerna (som "!" eller "+-") visas 
som symboler och har en knapp i kommentarseditorf�nstret f�r snabb inmatning. F�r andra symboler, 
kan du skriva in det l�mpliga numeriska NAG-v�rdet som �r ett nummer fr�n 1 till 255. Till exempel, 
NAG-v�rdet 36 betyder "Vit har initiativet" och visas som "$36" i PGN-texten till partiet.  
</p>

<p>
Se hj�lpsidan om NAG-v�rden f�r NAG v�rden som definieras av bl a PGN-standard. 
</p>

<p>
Tips: Du kan l�gga till de vanligaste dragv�rderingssymbolerna (!, ?, !!, ??, !? och ?!) i huvudf�nstret 
utan att beh�va anv�nda kommentarseditorf�nstret, genom att skriva in symbolerna f�ljt av att trycka 
p� <b>[Enter]</b> tangenten. Detta �r speciellt anv�ndbart om du skriver in schackdrag genom att anv�nda
tangentbordet. 
</p>

<h3>Kommentarer</h3>

<p>
Du kan �ndra kommentarer genom att skriva in text och anv�nda Rensa, �ngra och Lagra 
knapparna. Du beh�ver inte trycka p� Lagra knappen f�r att uppdatera en kommentar; 
den uppdateras automatiskt n�r du g�r till en annan position i partiet. 
</p>

<h3>F�rga rutor</h3>

<p>
Du kan f�rga alla rutor med valfri f�rg genom att anv�nda ett specialkommando,som kan 
finnas varsomhelst i en kommentar. Kommandoformatet �r: 
</p>

<p>
[%mark square color]
</p>

<p>
d�r square �r ett rutnamn som d4 och f�rg �r varje definierat f�rgnamn 
(som red, blue, darkGreen, lightSteelBlue, etc) eller RGB-kod (a # f�ljt av 
sex hexadecimala siffror, som #a0b0c8). Om f�rgen utel�mnas blir rutan
r�d. 
</p>

<p>
En kommentar kan inneh�lla obegr�nsat antal f�rgkommandon, men varje m�ste ha sin 
egen [%mark ...] markering. Till exempel, kommentarstexten
</p>

<p>
Nu �r d6-rutan  [%mark d6] svag och springaren kan attackera den fr�n b5. [%mark b5 #000070] 
</p>

<p>
f�rgar rutan d6 r�d och rutan b5 f�rgas med den m�rkbl� f�rgen #000070. 
</p>

<h3>Rita pilar</h3>

<p>
Du kan rita en pil fr�n en ruta till en annan genom att anv�nda ett specialkommentarskommando 
liknande det f�r att f�rga rutor. Formatet �r: 
</p>

<p>
[%arrow fromSquare toSquare color]
</p>

<p>
d�r fromSquare och toSquare �r namn p� rutor som d4 och f�rg �r varje definierat 
f�rgnamn (som  red, blue, etc) eller RGB code (som #a0b0c0). Om f�rgen inte specificeras
blir den r�d. 
</p>

<p>
Till exempel, kommentarstexten 
</p>

<p>
C3-springaren och c4-l�paren kontrollerar den svaga d5 rutan. 
[%arrow c3 d5 red] [%arrow c4 d5 blue] 
</p>

<p>
kommer att rita en r�d pil fr�n c3 till d5 och en bl� pil fr�n c4 till d5. 
</p>

<p><footer>(Uppdaterat: Scid 3.2, February 2002)</footer></p>
}


###########################
### Crosstable window help:

set helpTitle(W,Crosstable) "Korstabellf�nster"
set helpText(W,Crosstable) {<h1>Scids korstabellf�nster</h1>

<h3>Korstabellf�nstret</h3>

<p>
Korstabellf�nstret visar turneringskorstabellen f�r det aktuella partiet. 
Varje g�ng du uppdaterar korstabellf�nstret (genom att trycka p� Uppdatera knappen, 
genom att trycka Enter tangenten i korstabellf�nstret, eller genom att trycka <b>Ctrl+Shift+X</b> 
i huvud- eller partilistef�nstren), s�ker Scid efter alla partier i samma turnering som det
aktuella partiet. 
</p>

<p>
Alla partier som spelas upp till tre m�nader f�re eller efter det aktuella partiet, 
med exakt samma Evenemangs- och Ortmarkeringar anses vara i turneringen. 
</p>

<p>
Ett enkelt klick med v�nstra musknappen p� ett resultat i korstabellen laddar detta  
parti. Du kan l�gga till alla partier i turneringen till filtret med L�gg till filter knappen
i korstabellen. 
</p>

<h3>Korstabellf�nstermenyer</h3>

<p>
<b>[Arkiv]</b> menyn l�ter dig spara den aktuella tabellen till en fil med text-, 
LaTeX- eller HTML-tabellformat. 
</p>

<p>
<b>[Visa]</b> menyn l�ter dig v�lja tabellformat: 
All-play-all, Swiss eller Knockout eller Auto. 
</p>

<p>
All-play-all formatet (f�r round-robin-typ evenemang) har en begr�nsning p� 30 spelare, 
men Swiss formatet (f�r turneringar med m�nga spelare) kan visa upp till 
200 spelare och upp till 20 rundor. Auto, som v�ljer det b�sta formatet automatiskt 
f�r varje turnering �r standardinst�llningen. 
</p>

<p>
Observera att Scid anv�nder Rundemarkeringen f�r varje parti f�r att producera en Swisskorstabell, 
s� du kommer inte att se n�gra partier i Swisskorstabellen f�r en turnering om dess partier inte 
har numeriska rundev�rden som: 1, 2, 3, etc. 
</p>

<p>
Visa menyn l�ter dig ocks� st�lla in de data som ska presenteras att inkludera eller exkludera rating, 
l�nder och spelartitlar. Du kan ocks� v�lja om f�rgallokationer i Swisstabeller ska synas. 
</p>

<p>
Separat po�nggrupps-alternativet p�verkar bara utseendet p� tabellen n�r spelarna sorteras
efter po�ng: det ger en tomrad mellan varje grupp av spelare med samma po�ng. 
</p>

<p>
<b>[Sortera]</b> menyn l�ter dig sortera spelarna efter namn, rating eller po�ng; 
efter po�ng �r standardinst�llningen. 
</p>

<p>
<b>[F�rg]</b> menyn l�ter dig s�tta p� eller av f�rg i hypertextvisning. Eftersom det kan ta l�ng tid att 
formattera och visa stora korstabeller i hypertext sparar det mycket tid att v�lja vanlig text
f�r stora evenemang. Men i enkel text kan du inte klicka p� spelare eller partier. 
</p>

<h3>Duplikerade partier i korstabeller</h3>

<p>
F�r att f� bra resultat med korstabeller b�r du markera dubblettpartier f�r borttagning och 
ha en konsistent stavning i partierna av namn p� spelare, ort och evenemang. Se Underh�ll 
databas f�r hj�lp med att ta bort dubbletter och �ndra (eller stavningskontrollera) 
spelar-/evenemangs-/ortsnamn. 
</p>

<p><footer>(Uppdaterat: Scid 3.1, December 2001)</footer></p>
}


###########################
### Database switcher help:

set helpTitle(W,Switcher) "Databasv�xlaren"
set helpText(W,Switcher) {<h1>Scids databasv�xlare</h1>

<h3>Databasv�xlaren</h3>

<p>
Databasv�xlaren ger en m�jlighet att enkelt byta mellan databaser 
eller kopiera partier mellan databaser. Namnet, filterinst�llningen 
pch en ikon f�r varje databas visas medan den aktiva databasen 
markeras med en gul bakgrund. 
</p>

<p>
Du kan �ppna databasv�xlaren fr�n  <b>[F�nster]</b> menyn eller genom att 
anv�nda dess tangentkombination: <b>Ctrl+D</b>. 
</p>

<p>
F�r att kopiera alla filtererade partier fr�n en databas till en annan, drag med den v�nstra 
musknappen nedtryckt fr�n k�lldatabasen till destinationsdatabasen. Du kommer d� att se en  
bekr�ftelsedialog (om destinationsdatabasen inte �r Clipbase) om partierna kan 
kopieras eller se ett felmeddelande om partierna inte kan kopieras (till exempel, 
om en vald databas inte �r �ppnad). 
</p>

<p>
Genom att klicka med h�ger musknapp p� en databas visas en popup-menu f�r 
denna databas, fr�n vilken du kan �ndra databasikon eller nollst�lla databasens 
filter. Du kan ocks� anv�nda denna meny f�r att �ndra orienteringen av den 
(f�r att arrangera databasen vertikalt eller horisontellt) vilket �r anv�ndbart f�r 
mindre bildsk�rmar. 
</p>

<p><footer>(Uppdaterat: Scid 3.1, December 2001)</footer></p>
}


######################
### Email window help:

set helpTitle(W,Email) "Email-f�nster"
set helpText(W,Email) {<h1>Scids Email-f�nster</h1>

<h3>Email-f�nstret</h3>

<p>
Scids email-f�nster ger en m�jlighet att hantera korrespondensschackpartier 
med email. Om du inte spelar emailschack har du inget intresse f�r detta. 
Men om du spelar korrespondensschack via email kan du skicka dina 
emailmeddelanden direkt fr�n Scid! 
</p>

<p>
F�r att anv�nda emailhanteraren f�lj f�ljande steg: 
</p>

<p>
<li>1) Skapa partierna f�r din motst�ndare i databasen. </li>
<li>2) I emailhanteringsf�nstret v�lj L�gg till och skriv in detaljerna om dina motst�ndare: 
namn, email-adress samt antal partier i databasen. </li>
<li>3) V�lj Skicka email i emailf�nstret varje g�ng du har lagt till drag till partierna 
och vill skicka ett meddelande. </li>
N�r du skickar ett email-meddelande genererar Scid meddelandet med partierna 
i PGN-format utan kommentarer eller variationer eftersom du vanligtvis inte vill att din 
motst�ndare ska se din analys. Du kan �ndra meddelandet innan du skickar det f�r att l�gga
till villkorade drag eller annan text. 
</p>

<p>
F�r varje motst�ndare kan du ha obegr�nsat antal partier; en eller tv� �r det mest vanliga. 
Observera att Scid inte kontrollerar om antalet partier �ndras, s� efter att ha st�llt in detaljerna 
om dina motst�ndare var noga att undvika att ta bort partier eller sortera din databas med emailpartier 
eftersom detta kommer att �ndra i partier och g�ra antalet partier f�r varje motst�ndare felaktigt. 
</p>

<h3>Begr�nsningar</h3>

<p>
Scid har inte �nnu m�jlighet att kontrollera din emailkatalog, s� du m�ste fortfarande l�gga till
dina motst�ndares drag till partierna manuellt. 
</p>

<h3>Konfiguration<h3>

<p>
En kopia av varje emailmeddelande som skickats av Scid sparas i filen ~/.scid/scidmail.log. 
Om du vill att de ska sparas i en annan fil beh�ver du �ndra i filen tcl/start.tcl 
och omkompilera Scid. 
</p>

<p>
Scid kan skicka emailmeddelanden genom att anv�nda en SMTP server eller sendmail. 
Anv�nd inst�llningsknappen i emailhanteraren f�r att specificera vilken du vill anv�nda. 
</p>

<p>
Scid lagrar motst�ndardetaljerna f�r en databas i en fil med samma namn som databasen
med fil�ndelsen  ".sem". 
</p>

<p><footer>(Uppdaterat: Scid 3.0, November 2001)</footer></p>
}


############################
### File Finder window help:

set helpTitle(W,Finder) "S�k filer"
set helpText(W,Finder) {<h1>S�k filer</h1>

<h3>S�k filer<h3>

<p>
S�k filer hj�lper dig att hitta filer som du kan anv�nda i Scid: 
databaser, PGN-filer, EPD-filer samt repetoarfiler. 
</p>

<p>
Den visar anv�ndbar information om varje fil, som dess storlek 
(see nedan) och datum f�r senaste �ndringen. Du kan �ppna varje visad 
fil genom att v�lja den genom att klicka en g�ng med v�nstra musknappen. 
</p>

<h3>S�ka i underkataloger</h3>

<p>
N�r du vill hitta alla filer i alla underkataloger till den aktuella katalogen, 
s� markerar du i markeringsrutan f�r Leta i underkataloger. Detta f�r Scid att rekursivt 
genoms�ka varje underkatalog efter filer som kan �ppnas i Scid. Detta kan 
ta l�ng tid om det finns m�nga underkataloger, s� du kanske inte vill g�ra detta 
f�r en katalog n�ra roten av filsystemet. Du kan avbryta fils�kningen genom att 
trycka p� Stoppknappen. 
</p>

<h3>Filstorlekar</h3>

<p>
Betydelsen av de filstorlekar som visas beror p� filtypen. 
F�r Scid-databaser och PGN-filer �r det antalet partier. F�r EPD-filer 
�r det antalet positioner. F�r repetoarfiler �r det antalet 
(inkludera- eller exkludera)�ppningar. 
</p>

<p>
F�r alla filtyper utom Scid-databaser �r den angivna filstorleken en uppskattning baserad p� 
de f�rsta 64 kilobytesen av filen, s� den angivna storleken kanske inte �r korrekt f�r 
filer som �r st�rre �n 64 kb. Uppskattade storlekar visas med ett ungef�rtecken (~) 
f�r att visa att de inte �r exakta. 
</p>

<p><footer>(Uppdaterat: Scid 2.7, September 2001)</footer></p>
}


#########################
### GameList window help:

set helpTitle(W,GameList) "Partilistan"
set helpText(W,GameList) {<h1>Partilistan</h1>
<p>
Partilistaf�nstret ger en enradig sammanfattning av varje
parti i det aktuella <term>Filtret</term> .
</p>

<h3>Navigationen i partilistan</h3>

<p>
Du kan bl�ddra i partilistan med skjutregulatorn eller med de fyra
knapparna i nedre delen av listan .
Du kan ocks� anv�nda tangenterna <b>[Pos1]</b>, <b>[End]</b>, <b>[Bild i]</b>, <b>[Bild ab]</b> s�v�l som
cursortangenterna , f�r att scrolla med tangentbordet.
</p>

<p>
Du kan hitta  n�sta parti i listan, som inneh�ller en best�md
text i Vit-, Svart-, Turnerings- eller Ortsf�ltet , med 
<b>S�k text</b>-inmatningsf�lten.
</p>

<h3>�tg�rder med partier i listan</h3>

<p>
F�r att ladda ett parti p� listan klickar du dubbelt med
den v�nstra musknappen.
Ett klick med dem mittersta musknappen visar de f�rsta dragen i partiet;
det �r nyttigt, n�r man vill se �ppningen f�re �ppnandet av ett parti.
</p>
<p>
Den h�gra musknappen ger en meny f�r det utvalda partiet,
d�r du kan ta bort partier (eller "ta tillbaka partier") eller utesluta partier fr�n 
filtret. Observera att borttagandet inte g�rs direkt utan det g�rs f�rst
n�r databasen  <a Compact>komprimeras</a>.
</p>

<h3>Konfigurera partilistan</h3>
<p>
F�r att konfigurera partilistan, klickar du med den v�nstra eller
h�gra musknappen i en kolumn�verskrift. Du kan �ven �ndra bredd,
, infoga eller ta bort samt �ndra f�rg p� varje kolumn.
</p>
<p>
N�r du bara vill �ndra kolumnbredden, finns det f�r detta en
tangentkombination: klickar du med nedtryckt <b>[Ctrl]</b>- (eller
<b>[Shift]</b>)-tangent med den v�nstra musknappen i 
den �versta delen av kolumnen  blir kolumnen mindre med den h�gra
musknappen blir den bredare.
</p>

<h3>�ndra storlek p� partilistan</h3>
<p>
Storleken p� partilistan blir sparat i alternativfilen varje g�ng,
som du sparar dina inst�llningar.
Du kan ocks� n�r du vill att partilistan standardm�ssigt ska visa 10 partier ,
f�r�ndra storleken p� partilistaf�nstret och v�lja
<b>Spara inst�llningar</b> i <menu>Alternativ</menu>-menyn.
</p>

<h3><name Browsing>Se partier och infoga variant</name></h3>
<p>
Kontextmenyn f�r Partilistan (och n�gra andra f�nster, som bl a
<a Reports Opening>�ppningsrapport</a>-F�nstren och listan med de
<a Tree Best>B�sta partierna</a> i <a Tree>Dragtr�d</a>-F�nstret)
till�ter val av parti att ladda, titta p� eller infogandet av en variant.
</p>
<p>
N�r <term>Betrakta parti</term> blir valt, blir dragen i
det utvalda partiet (utan kommentarer eller varianter) visat i ett
separat f�nster. Det �r en nyttig metod att titta p� ett annat parti
i f�rgrunden utan att �ndra i det aktuellt laddade partiet.
</p>
<p>
Funktionen <term>Infoga variant</term> g�r det m�jligt att infoga 
varianter i det utvalda partiet. Scid finner den
sista m�jliga tidpunkten, d� det valda partiet avvek fr�n det aktuella
(med betraktande av dragomkastningar), och infogar denna position
som en variant. 
</p>

<p><footer>(Uppdaterat: Scid 3.2, Februari 2002)</footer></p>
}


#######################
### Import window help:

set helpTitle(W,Import) "Importf�nstret"
set helpText(W,Import) {<h1>Importf�nstet</h1>
<p>
Scids Importf�nster m�jligg�r att enkelt infoga ett
parti i <a PGN>PGN-format</a> till Scid eller till ett annat 
program.
</p>
<p>
I det stora f�nsteromr�det skriver du  in eller infogar partitexten i
PGN-format och i det gr�a omr�det nedanf�r finns 
felmeddelanden eller varningar.
</p>

<h3>Bearbeta det aktuella partiet i Importf�nstret</h3>
<p>
Importf�nstret ger ocks� en ytterligare bekv�m m�jlighet f�r
�ndringar i det aktuella partiet: du kan i det aktuella partiet i
importf�nster infoga (med funktionen <b>Infoga aktuellt parti</b>), 
�ndra i texten och d�refter klicka p� <b>Importera</b> .
</p>

<h3>PGN-markeringar i Importf�nstret</h3>
<p>
Scid f�rv�ntar sig PGN-markeringar ("header tags") som
<ul>
<li> <b>[Resultat "*"]</b> </li>
</ul>
f�re dragen, men du kan ocks� infoga ett partifragment som
<ul>
<li> <b>1.e4 e5 2.Bc4 Bc5 3.Qh5?! Nf6?? 4.Qxf7# 1-0</b> </li>
</ul>
utan PGN-markeringar , och Scid importerar det.
</p>

<h3>Anv�nda PGN-filer i Scid</h3>
<p>
N�r du vill anv�nda en PGN-fil i Scid , utan att i f�rv�g konvertera den med
<a Pgnscid>Pgnscid</a> , finns det tv� m�jligheter.
</p>
<p>
I det f�rsta alternativet kan du importera parti-filen med menyalternativet
<menu>Verktyg: Importera PGN-partier ...</menu> .
</p>
<p>
Alternativet tv� vore att �ppna PGN-filen direkt i Scid . Dessutom
blir PGN-filen bara �ppnat f�r l�sande och beh�ver mer minnesutrymme �n
en j�mf�rbar Scid-databas, denna m�jlighet �r allts� bara att rekommendera
f�r relativt sm� PGN-filer .
</p>

<p><footer>(Uppdaterat: Scid 2.5, Juni 2001)</footer></p>
}


########################
### Reports help:

set helpTitle(W,Reports) "Rapporter"
set helpText(W,Reports) {<h1>Rapporter</h1>
<p>
Hos Scid �r en <term>Rapport</term> ett dokument, som inneh�ller information om
en best�md Position och/eller en best�md spelare . 
Scid kan skapa tv� typer av rapporter: 
�ppningsrapporter och Spelarrapporter.
</p>

<h3><name Opening>�ppningsrapport</name></h3>
<p>
Scid kan skapa en <term>�ppningsrapport</term> , som har interessant
information om den aktuella �ppningspositionen. F�r att skapa 
�ppningsrapporten f�rvissar du dig f�rst att den aktuella positionen �r den som
du vill ha rapporten f�r,
sedan v�ljer du <b>�ppningsrapport</b> i menyn <menu>Verktyg</menu>.
</p>
<p>
<term>�ppningsrapport</term>-f�nstret ger resulatet av rapporten. 
<b>Data</b>-menyn inneh�ller alternativ,
f�r att spara rapporten i Text-, HTML- eller
<a LaTeX>LaTeX</a>-format.
</p>
<p>
De f�rsta avsnitten i rapporten presenterar information om de
partier, som har rapportpositionen, och de drag som har spelats i denna
st�llning. Du kan se om �ppningen �r popul�r , om den leder till m�nga korta remier 
och med vilka dragf�ljder (dragomkastningar) den blir uppn�dd.
</p>
<p>
Avsnittet om positionella teman informerar om vanligheten av
best�mda typiska teman i rapportpartierna. Till detta blir
de f�rsta 20 dragen (allts� de f�rsta 40 positionerna fr�n utg�ngsst�llningen)
i varje parti unters�kt. F�r att ett parti ska finnas med som har ett best�mt tema
m�ste detta tema minst f�rekomma fyra g�nger inom de f�rsta 20 dragen i partiet. 
D�rmed undviks att ett kortsiktig f�rekomst av ett tema (som t ex en isolerad
dambonde, som genast blir slagen) att resultatet blir missvisande.
</p>
<p>
Den sista och l�ngsta delen av rapporten �r teoritabellerna. N�r du
sparar rapporten i en fil kan du v�lja om du bara vill ha teoritabellerna, 
en kompakt rapport utan teoritabellerna eller
hela rapporten.
</p>
<p>
N�stan alla avsnitt i rapporten kan st�llas in med �ppningsrapport-alternativ
eller st�ngas av eller p�.
Du kan allts� anpassa rapporten, s� att den bara inneh�ller den f�r dig intressanta 
informationen.
</p>
<p>
Med den mesta informationen i rapportf�nstret, som �r f�rgkodad, 
leder ett klick p� v�nster musknapp till en aktion. Till exempel kan du
ladda ett parti genom att klicka p� det eller st�lla in filtret genom att
klicka p� ett positionstema s� att rapporten bara inneh�ller partier med
detta tema .
</p>

<h4>Favoriter</h4>
<p>
Med  <menu>Favoriter</menu>-menyn i rapportf�nstret har du 
m�jlighet att f�rvalta en lista av f�rdefinierade �ppningsrapportpositioner 
och mycket enkelt skapa rapporter f�r exakt dessa positioner. 
N�r du v�ljer "Infoga i rapport..." im Favorit-menyn
blir den aktuella st�llningen vald som en s�rskild rapportposition. 
Du uppmanas d� att ange ett namn, som d� anv�nds n�r 
favoritrapporter skapas.
</p>
<p>
V�lj "Skapa rapport..." i Favorit-menyn, f�r att skapa en rapport
f�r varje vald position i den aktuella databasen . 
I ett dialogf�nster kan du d� ange typ och format p� rapporten 
s�v�l som den katalog, d�r rapportfilerna blir sparade. 
Den passande fil�ndelsen f�r det valda utdataformatet
blir d� automatiskt valt (till exempel ".html" f�r HTML-format).
</p>

<h3><name Player>Spelarrapport</name></h3>
<p>
En <term>Spelarrapport</term> liknar mycket en �ppningsrapport,
men inneh�ller information om partier f�r en enskild spelare med
vit eller med svart. Du kan antingen f� en spelarrapport via verktygs-menyn
eller fr�n <a PInfo>Spelarinformations</a>-f�nstret.
</p>
<p>
En Spelarrapport kan skapas antingen f�r alla partier/f�r en best�md spelare
/f�r en best�md f�rg eller bara f�r de partier, som
har f�tt den aktuella st�llningen p� huvudf�nster-br�det.
</p>

<h3>Inskr�nkningar</h3>
<p>
F�r de flesta �ppningsdata finns det en inskr�nkning till 2000 partier,
n�r �ppningsposition inneh�ller fler �n 2000 partier kan
n�gra resultat vara lite oklara.
</p>
<p>
Dessutom finns det en begr�nsning till 500 partier f�r teori-tabellerna. N�r
�ppningspositionen finns i fler �n 500 partier , anv�nds bara de 500 partier med de 
h�gsta genomsnittliga Elo-talen. Antalet partier f�r
uppbyggnaden av teoritabellerna �r inst�llningsbart.
</p>

<p><footer>(Uppdaterat: Scid 2.5, Juni 2001)</footer></p>
}


####################
### PGN window help:

set helpTitle(W,PGN) "PGN-f�nster"
set helpText(W,PGN) {<h1>PGN-f�nster</h1>
<p>
Scids PGN-f�nster ger inneh�llet i det aktuella partiet i 
Standard-PGN-format. I Partitexten syns kommentarer i
{icke runda} och varianter i (runda) klamrar.
</p>

<h3>PGN-format</h3>
<p>
PGN (Portable Game Notation) �r ett utbredd standard f�r �verf�ring
av schackpartier mellan datorprogram. En PGN-parti best�r
av tv� delar.
Den f�rsta delen �r PGN-markeringarna ("Header"), som inneh�ller inmatningar ("tags") som
till exempel
<b>[White "Kasparov, Gary"]</b>
och
<b>[Resultat "1/2-1/2"]</b> .
</p>
<p>
Den andra delen inneh�ller de egentliga partidragen i
algebraisk standardnotation (SAN) tillsammans med eventuella varianter,
<a NAGs>Kommentarsymboler</a> och <a Comment>Kommentarer</a>.
</p>

<h3>�tg�rder i PGN-f�nster</h3>
<p>
Du kan navigera i partiet med PGN-f�nstret: Med
ett klick med v�nstra musknappen p� ett drag g�r du till detta drag, med ett
klick med v�nstra musknappen i en Kommentar kan du �ndra i denna.
Cursortangenterna (liksom tangenterna <b>v</b> och <b>z</b> f�r
att b�rja respektive avsluta varianter) anv�nds f�r att navigera i 
partiet precis som i huvudf�nstret.
</p>

<h3>Inst�llningar f�r PGN-presentation</h3>
<p>
Menyn PGN-f�nster inneh�ller alternativ f�r f�nstret i PGN presentationen. 
Scid kan visa partiet i f�rg eller visa det som en ren text
-- se  <menu>Presentations</menu>-menyn i PGN-f�nstret.
Den f�rgade presentationen �r l�tt att l�sa och till�ter dig att v�lja drag och
kommentarer med musen, men de �r mycket l�ngsammare �n enkel text. 
F�r mycket l�nga partier b�r du kanske v�lja enkel text.
</p>
<p>
Ocks� formatet f�r kommentarer och varianten kan du f�r�ndra,
f�r att ge en b�ttre �versikt eller f�r att l�ta ge ut i separata delar.
</p>
<p>
PGN-presentationsalternativ och storleken p� PGN-f�nstret blir alltid sparat i
konfigurationsfilen n�r du v�ljer <b>Spara alternativ</b> i <menu>Alternativ</menu>-Menyn.
</p>

<p><footer>(Uppdaterat: Scid 3.1, December 2001)</footer></p>
}


#######################
### Piece Tracker help:

set helpTitle(W,PTracker) "Pj�ssp�raren"
set helpText(W,PTracker) {<h1>Pj�ssp�raren</h1>

<h3>Pj�ssp�raren</h3>

<p>
Pj�ssp�raren �r en funktion som sp�rar r�relserna f�r en s�rskild pj�s f�r alla partier 
i det aktuella filtret och genererar ett "fotavtryck" f�r att visa hur ofta varje pj�s 
har varit p� en viss ruta. 
</p>

<p>
F�r att anv�nda pj�ssp�raren se f�rst till att filtret inneh�ller de partier du �r 
intresserad av, som partier med en viss �ppningsposition eller alla partier 
d�r en viss spelare hade de vita pj�serna. V�lj sedan pj�s att sp�ra och 
st�ll in andra alternativ; som f�rklaras h�r nedan. Efter detta tryck p� 
Uppdateraknappen. 
</p>

<p>
Informationen om den sp�rade pj�sens r�relser visas p� tv� s�tt: ett grafiskt 
"fotavtryck" och en textlista med en rad med data per ruta. 
</p>

<h3>V�lja pj�s att sp�ra</h3>

<p>
Schackpj�serna visas i startpositionen nedanf�r fotavtrycksdiagrammet. En enkel pj�s 
(som den vita b1 springaren eller den svarta d7 bonden) 
kan v�ljas med den v�nstra musknappen och alla pj�ser av samma typ och f�rg 
(som alla vita b�nder eller b�da svarts torn) kan v�ljas med den h�gra musknappen. 
</p>

<h3>Andra pj�ssp�rarinst�llningar<h3>

<p>
Dragnummeromr�det kontrollerar n�r sp�rningen ska starta och stoppa i varje parti. 
Standardinst�llningen p� 1-20 (betyder att sp�rningen ska stoppas efter svarts drag nr 20) 
�r l�mpligt f�r att unders�ka �ppningsteman, men (till exempel) ett omr�de som 15-35 
�r b�ttre n�r man s�ker efter mittspelstrender. 
</p>

<p>
Det finns tv� typer av statistik som pj�ssp�raren kan generera: 
</p>

<p>
% games with move to square: visar vilken proportion av de filtrerade partierna som 
inneh�ller ett drag av den sp�rade pj�sen f�r varje ruta. Detta �r standardinst�llningen 
och vanligtvis det mest passande valet. 
% time in each square: visar proportionen av tid den sp�rade pj�sen har spenderat 
p� varje ruta. 
</p>

<h3>Tips</h3>

<p>
Det finns �tminstonde tre bra anv�ndningar av pj�ssp�raren: �ppningspreparering, 
mittspelsteman och spelarpreparering. 
</p>

<p>
F�r �ppningspreparering anv�nd pj�ssp�raren med dragtr�det �ppnat. Genom att f�lja
pj�ser kan du se trender i den aktuella �ppningen som vanliga bondeframst�tar, 
springarutposter samt var l�parna oftast placeras. Du kan �ven finna det 
anv�ndbart att s�tta dragantalet till att starta efter det aktuella draget i partiet, 
s� att dragen fram till och med den aktuella positionen inte inkluderas i statistiken. 
</p>

<p>
F�r mittspelsteman kan pj�ssp�raren vara anv�ndbar n�r filtret har st�llts in att 
inneh�lla en viss ECO-omfattning (genom en Partihuvuds�kning) eller kanske ett 
m�nster som en vit isolerad dambonde (genom en Material/m�nsters�kning). 
S�tt dragantalet till n�got l�mpligt (som 20-40) och sp�ra pj�ser f�r att t ex se 
bondeframst�tar i det sena mittspelet eller tidiga slutspelet. 
</p>

<p>
F�r spelarpreparering anv�nd en Partihuvuds�kning eller Spelarinformationsf�nstret
f�r att hitta alla partier av en viss spelare med en viss f�rg. Pj�ssp�raren kan d�
anv�ndas f�r att t ex uppt�cka hur sannorlikt det �r att spelaren fianchettar l�pare, 
g�r l�ng rockad eller st�ller upp b�nderna p� d5 eller e5. 
</p>

<p><footer>(Uppdaterat: Scid 3.3, April 2002)</footer></p>
}

#####################
### Player List help:

set helpTitle(W,PList) "Spelarlistan"
set helpText(W,PList) {<h1>Spelarlistan</h1>

<h3>Spelarlistan</h3>

<p>
Spelarlistan visar en lista p� spelarnamn i den aktuella databasen. 
Genom att v�lja en spelare �ppnas spelarinfof�nstret f�r att visa mer detaljerad
information om den spelaren. 
</p>

<p>
Fem kolumner som syns visar varje spelares namn, H�gsta uppn�dda ELO, 
antal spelade partier samt �ret f�r deras �ldsta och nyaste parti. 
Klicka p� valfri kolumntitel p� toppen av listan f�r att sortera listan efter den
kolumnen. 
</p>

<p>
Kontrollerna nedanf�r listan l�ter dig filtrera listinneh�llet. 
Du kan �ndra den maximala liststorleken, skriva in ett VERSAL-/gemenok�nsligt spelarnamn 
prefix (som "ada" f�r att s�ka efter "Adams"), 
och begr�nsa Elo-omfattningen och antalet spelade partier. 
</p>

<p><footer>(Uppdaterat: Scid 3.4, August 2002)</footer></p>
}

#####################
### Player Info help:

set helpTitle(W,PInfo) "Spelarinfo"
set helpText(W,PInfo) {<h1>Spelarinfo</h1>

<h3>Spelarinfof�nstret</h3>

<p>
Spelarinformationsf�nstret skapas eller uppdateras n�r du klickar med den v�nstra 
musknappen p� ett spelarnamn i spelinformationsytan (nedanf�r schackbr�det) 
eller i korstabellf�nstret. 
</p>

<p>
Den visar f�rhoppningsvis anv�ndbar information om spelaren, inklusive deras framg�ng 
med vit och svart, favorit�ppningar (med ECO-kod), och ratinghistoria. 
</p>

<p>
Alla procenttal som visas �r en f�rv�ntad po�ng (m�tt p� framg�ng), fr�n den spelarens 
perspektiv -- s� h�gre �r alltid b�ttre f�r spelaren oavsett om de �r vit eller svart. 
</p>

<p>
Du kan se spelarens ratinghistoria i en tabell genom att trycka p�  Ratingtabellknappen. 
</p>

<p>
Varje antal skrivet i r�tt kan klickas med den v�nstra musknappen f�r att st�lla in filtret f�r de
partier den representerar. 
</p>

<p><footer>(Uppdaterat: Scid 2.5, Juni 2001)</footer></p>
}


###########################
### Repertoire editor help:

set helpTitle(W,Repertoire) "Repetoar-Editor"
set helpText(W,Repertoire) {<h1>Repetoar-Editor</h1>

<h3>Repertoar-Editor</h3>

<p>
Repetoar-editorn l�ter dig skapa, se och �ndra repetoarfiler. 
En repetoarfil (*.sor) �r en lista p� de �ppningspositioner du vill n� eller 
f�rs�ker undvika, och du kan anv�nda den f�r att hantera dina 
schack�ppningspreferenser men den g�r �ven att anv�nda f�r att s�ka i
databaser med Scid. 
</p>

<h3>Repetoargrupper och linjer</h3>

<p>
En repetoar inneh�ller tv� typer av element: grupper och linjer. 
Grupper �r inte en del av din repetoar; de anv�nds bara f�r att 
strukturera den p� samma s�tt som kataloger ger struktur till filerna p� en h�rddisk,CD,DVD
eller diskett. 
</p>

<p>
Linjer i en repetoar finns i tv� typer: Inkludera linjer, som representerar de 
�ppningspositioner du �r intereserad av och f�rs�ker uppn� medan exkluderalinjer,som �r
de du inte �r intresserade av att spela och f�rs�ker undvika. 
Till exempel, om du spelar en accepterad damgambit (QGA) dvs 1.d4 d5 2.c4 dxc4 som svart
och du spelar alla drag efter 3.e4 utom 3...Sf6, m�ste du ha 1.d4 d5 2.c4 dxc4 3.e4 som en 
Inkluderalinje och 1.d4 d5 2.c4 dxc4 3.e4 Nf6 som en Exkluderalinje. 
</p>

<h3>Kommentarer och anteckningar</h3>

<p>
Varje grupp eller linje kan ha kommentarer anknytna till sig. 
Det finns tv� typer: korta (enrads-) kommentarer som syns med r�tt i repetoarhierarkin brevid 
dragen i en grupp eller linje medan l�nga (flerradiga-) kommentarer bara visas n�r gruppen  
eller linjen v�ljs. 
</p>

<p>

<h3>Anv�nda Repetoar-editorn</h3>

<p>
Den v�nstra sidan av f�nstret visar repetoarhierarkin. 
Du kan klicka p� folderikoner f�r att expandera och krympa grupper, 
och klicka p� dragen i en  grupp eller linje f�r att v�lja den och se dess kommentarer. 
Inkludelinjer visas med bl� accepteraikoner medan exkluderalinjer visas med r�da kors. 
</p>

<p>
Om en linje eller grupp har en kort kommentar, visas den efter dragen. 
Om den har en l�ng kommentar indikeras detta med ** efter dragen. 
Grupperna har en siffra inom parentes efter sina drag som visar det antal inkludera- och 
excluderalinjer de inneh�ller. 
</p>

<p>
Genom att klicka med h�ger musknapp p� en grupp eller linje ger det en meny med funktioner
f�r att ta bort den eller f�r�ndra dess status. 
</p>

<h3>Den h�gra sidan av f�nstret inneh�ller tre delar.</h3>

<p> 
Den f�rsta delen �r en lista p� dragen i den aktuellt valda linjen eller gruppen. 
Du kan klicka med v�nster musknapp p� den f�r att klistra in dragen i Importf�nstret, 
vilket �r anv�ndbart f�r att l�ta det aktuella partiet starta med en linje i repetoaren. 
Den andra delen inneh�ller en kort kommentar f�r linjen eller gruppen, 
och den tredje delen inneh�ller dess l�nga kommentar. 
</p>

<h3>L�gga till grupper och linjer till repetoaren</h3>

<p>
F�r att l�gga till en linje eller grupp till f�nstret mata bara in dragen p� schackbr�det i 
huvudf�nstret och anv�nd sedan <b>[Redigera]</b> menyn i Repetoar-editorn f�r att l�gga till det 
som en grupp, inkluderalinje eller excluderalinje. 
</p>

<p>
F�r att ta bort en grupp eller linje klicka med h�ger musknapp p� den och v�lj det l�mpliga 
kommandot fr�n menyn som visas. 
</p>

<h3>S�ka databaser med repetoarfiler</h3>

<p>
Repetoar-editorns <b>[S�k]</b> meny l�ter dig s�ka den aktuella databasen med repetoaren. 
Varje parti blir genoms�kt efter positionerna i repetoaren och blir bara matchade i s�kningen
om den djupaste repetoarpositionen som hittas �r en inkluderalinje. 
</p>

<p>
Du kan v�lja att s�ka genom att anv�nda hela repetoaren eller bara de visade linjerna. 
Att s�ka bara de visade linjerna �r anv�ndbart n�r du bara vill anv�nda en del av repetoaren. 
Till exempel kan en repetoar ha tv� huvudgrupper , 
en f�r 1.e4 och en f�r 1.d4. Om du �r bara interesserad av 1.e4 linjerna, 
krymp bara 1.d4 gruppen och s�k sedan bara de visade linjerna. 
</p>

<h3>Extra tips</h3>

<p>
En repetoarfil �r bra f�r att hitta nya partier i dina �ppningssystem. 
Till exempel varje g�ng du f�r en ny PGN-fil att l�gga till till din huvuddatabas 
(som den excellenta vecko PGN-filen fr�n The Week In Chess), 
�ppna bara PGN-filen i Scid och g�r en repetoars�kning. 
Sedan kan du bl�ddra i de filtrerade partierna f�r att se alla de spelade partierna som finns i 
din repetoar. 
</p>

<p>
Du kan vilja beh�lla tv� repertoarfiler: en f�r svart och en f�r vit, 
s� att du kan s�ka med varje fil separat. 
</p>

<p>
En repertoarfil kan �ppnas fr�n kommandoraden, till exempel: 
scid minbas vit.sor 
</p>

<p>
Du kan �ndra en repetoarfil (*.sor) i valfri texteditor, men var noga att bevara dess format 
s� att den f�rblir laddbar eller s�kbar i Scid. 
</p>

<p><footer>(Uppdaterat: Scid 2.6, Augusti 2001)</footer></p>
}


##################################
### Tournament Finder window help:

set helpTitle(W,Tmt) "S�k turneringar"
set helpText(W,Tmt) {<h1>S�k turneringar</h1>

<h3>S�k turneringar</h3>

<p>
S�k turneringar l�ter dig hitta turneringar i den aktuella databasen. 
Den s�ker i alla databasepartier och samlar data om de funna turneringarna. 
Observera att tv� partier anses vara i samma turnering om de har 
samma Evenemangsmarkering , samma Ortsmarkering och spelades inom tre m�nader. 
</p>

<p>
Du kan begr�nsa listan p� turneringar med antalet spelare och partier, 
datum, genomsnittling Elo rating och land genom att �ndra i f�lten nedanf�r turneringslistan 
och sedan trycka p� Uppdateraknappen. 
</p>

<p>
Den visade listan kan sorteras efter datum,antal spelare, antal partier, 
genomsnittlig Elo , Ort, Evenemang eller Namn . V�lj kategori 
i <b>[Sorterings]</b> menyn eller klicka p� en kolumntitel f�r att f�r�ndra i sorteringsf�ltet. 
</p>

<p>
F�r att ladda det f�rsta partiet i en visad turnering klicka bara med v�nster musknapp 
n�r dess rad markerats. Detta kommer ocks� att uppdatera Korstabellf�nstret om det
�r �ppnat. 
Om du ist�llet trycker h�ger musknapp kommer partiet att laddas och korstabellf�nstret
blir �ppnat �ven om det �r st�ngt. 
</p>

<p>
F�r att snabba upp turneringss�kningar �r det en bra id� att v�lja en ganska litet omr�de 
(som n�gra �r) eller v�lja ett speciellt land (efter dess trebokstavs standardkod). 
Genom detta minskas kraftigt det antal partier Scid m�ste g� igenom f�r att bilda 
turneringar av partierna i databasen. 
</p>

<p><footer>(Uppdaterat: Scid 3.3, April 2002)</footer></p>
}


####################
### Tree window help:

set helpTitle(W,Tree) "Tr�df�nstret"
set helpText(W,Tree) {<h1>Tr�df�nstret</h1>

<h3>Tr�df�nstret</h3>

<p>
Tr�df�nstret visar information om alla drag som gjorts fr�n den aktuella 
positionen i partier i databasen. I tr�dmoden uppdateras tr�df�nstret 
automatiskt n�r br�det p� huvudf�nstret �ndras. Detta kan vara l�ngsamt 
f�r stora databaser. 
</p>

<p>
Observera att n�r tr�df�nstret uppdateras nollst�lls filtret och bara de partier 
som inneh�ller den aktuella positionen inkluderas. 
</p>

<p>
Genom att trycka p� v�nster musknapp p� ett drag i tr�df�nstret s� adderas detta drag
till partiet. 
</p>

<h3>Tr�df�nstrets inneh�ll</h3>

<p>
Tr�df�nstret visar ECO koden (om den finns), frekvens (b�de som antal 
partier och en procentsats) och v�rderingen av varje drag. 
V�rderingen ber�knas alltid fr�n vits perspektiv, 
s� 100% betyder att vit vinner alla partier  
medan 0% betyder att svart vinner alla partier. 
</p>

<p>
Dragen i tr�df�nstret kan sorteras efter drag (alfabetiskt), 
ECO-kod, frekvens, eller v�rdering. Du kan �ndra sorteringsmetod i 
<b>[Sorterings]</b> menyn. 
</p>

<h3>B�sta partier</h3>

<p>
Tr�df�nstret har ett filmenykommando och knapp f�r att �ppna de 
B�sta partierna, vilka visar en lista p� de h�gst rankade partierna i 
den aktuellt visade tr�dgrenen. Partierna listas efter genomsnittlig 
rating och du kan begr�nsa listan till att visa partier med ett speciellt 
resultat. 
</p>

<h3>Tr�dgraff�nstret</h3>

<p>
Tr�df�nsterknapparna inkluderar en knapp markerad Graph som ger 
en grafisk visning av det relativa utfallet f�r varje drag fr�n den aktuella 
positionen. Alla drag som har spelat minst 1% och minst 5 g�nger visas. 
Procentsiffror �r alltid fr�n vits perspektiv �ven n�r det �r svarts drag. 
</p>

<p>
I tr�dgrafen plottas en r�d linje f�r att visa genomsnittet av alla partier 
fr�n den aktuella positionen och ytan mellan 50-55% (som de flesta 
standard�ppningar f�rv�ntas f�) �r markerad med bl�tt f�r att assistera 
j�mf�randet av drag. Observera att vit vanligtvis vinner cirka 55% av 
schackm�starpartierna. 
</p>

<h3>L�sa tr�df�nstret</h3>

<p>
L�sknappen i tr�df�nstret kan anv�ndas f�r att l�sa tr�det till den 
aktuella databasen. Detta betyder att tr�det kommer att forts�tta att
anv�nda denna databas �ven n�r du byter till en annan �ppnad databas. 
Detta �r anv�ndbart om du viss anv�nda en stor databas som en referens 
n�r du spelar igenom ett parti i en annan databas: 
bara �ppna tr�det i referensdatabasen, l�s det och v�xla sedan till
den andra databasen. 
</p>

<h3>Tr�ning</h3>

<p>
N�r Tr�ningscheckrutan i tr�df�nstret v�ljs kommer Scid  
slumpm�ssigt att g�ra ett drag varje g�ng du l�gger till ett drag till partiet. 
Draget som Scid v�ljer beror p� databasstatistiken, s� ett drag som spelats
i 80% av databaspartierna kommer att v�ljas av Scid med 80% 
sannorlikhet. Att starta denna funktion och sedan d�lja (eller ikonifiera)  
tr�df�nstret och spela �ppningar mot en stor databas �r ett bra s�tt att
testa din kunskap om �ppningsrepetoaren. 
</p>

<h3>Anv�nda Tr�det med �ppnade EPD-filer</h3>

<p>
F�r varje �ppnad EPD-fil kommer tr�df�nstret att inneh�lla en extra kolumn 
som visar en kort (fem tecken) sammanfattning av inneh�llet i 
EPD-filen f�r varje position som n�s fr�n de listade dragen. 
</p>

<p>
Sammanfattningen kan vara en v�rdering, en �ppnings ECO-kod eller ett f�reslaget drag; 
det kommer att vara inneh�llet i det f�rsta EPD-f�ltet hittat fr�n f�ljande lista: 
ce, eco, nic, pv, pm, bm, id
eller bara det f�rsta EPD-f�ltet om ingen av de ovan n�mnda finns. 
</p>

<p>
F�r en beskrivning av EPD f�lten, se EPD-fil hj�lpsidan. 
Observera att om sammanfattningen �r av ce f�ltet, 
visas det som en v�rdering i b�nder fr�n vits perspektiv
(ist�llet f�r som em v�rdering i hundradelsb�nder fr�n perspektivet av sidan vid draget, 
som det sparas i EPD-filen) f�r att f�rb�ttra l�sbarheten. 
</p>

<h3>Cache f�r snabbare resultat</h3>

<p>
Scid har en cache f�r tr�ds�kresultat f�r de positioner med de 
mest matchande partierna. Om du g�r fram�t och bak�t i ett parti 
i tr�dmod kommer du att se att tr�df�nstret uppdateras  n�stan omedelbart 
n�r positionen som s�ks finns i cachen. 
</p>

<p>
Tr�df�nstret har ett filmenykommando kallat Spara Cache. 
N�r du v�ljer detta kommer det aktuella inneh�llet i tr�dcachen att sparas till 
en fil (med fil�ndelsen * .stc) f�r att snabba upp framtida anv�ndning av 
Tr�dmoden med denna databas. 
</p>

<p>
Fyll cache filkommandot i filmenyn f�r tr�df�nstret fyller cachefilen med data f�r 
m�nga �ppningspositioner. Det g�r en tr�ds�kning f�r omkring 100 av de mest 
vanliga �ppningspositionerna och sparar sedan cachefilen. 
</p>

<p>
Observera att en tr�dcachefil (*.stc) �r helt �verfl�dig; 
du kan ta bort den utan att p�verka databasen, 
och den tas �ven bort av Scid n�r en �tg�rd g�rs som kan g�ra den icke uppdaterad 
som till exempel att l�gga till eller ers�tta ett parti eller sortera databasen. 
</p>

<p><footer>(Uppdaterat: Scid 3.0, November 2001)</footer></p>
}


################
### Graphs help:

set helpTitle(W,Graphs) "Graff�nster"
set helpText(W,Graphs) {<h1>Graff�nster</h1>

<h3>Graff�nster</h3>

<p>
Scid har ett antal f�nster som visar information grafiskt. 
De f�rklaras h�r nedanf�r. 
</p>

<h3>Filtergraff�nstret</h3>

<p>
Filtergraff�nstret visar trender efter datum eller efter Elo-rating f�r 
partierna i det aktuella filtret j�mf�rt med hela databasen. 
Till exempel �r det anv�ndbart n�r tr�det �r �ppnat som ett redskap 
f�r att visa hur den aktuella �ppningspositionen har f�r�ndrats i popularitet 
p� senare �r eller tiotal �r eller om det �r speciellt popul�rt bland h�gre-rankade 
spelare som storm�stare. Varje po�ng p� grafen representerar antalet partier i 
filtret per 1000 partier i hela databasen, 
f�r ett speciellt dator eller ett visst Eloratingomr�de. 
</p>

<p>
N�r filtergrafen plottas efter rating anv�nder Scid den genomsnittliga 
(aritmetiskt medelv�rde) ratingen f�r varje parti. Uppskattade ratings 
(som de som finns i stavningsfilen) anv�nds inte. Om en spelare i ett 
parti har en rating men motst�ndaren inte har det, 
antas motst�ndaren ha samma upp till 2200. 
Till exempel, om en spelare �r rankad 2500 och motst�ndaren inte 
har en rating blir genomsnittsratingen (2500+2200)/2=2350. 
</p>

<h3>Ratinggraff�nstret</h3>

<p>
Ratinggraff�nstret visar ratinghistorian f�r en spelare eller tv� 
spelare i det aktuella partiet. Du kan producera grafen f�r en spelare 
genom att trycka p� Ratinggrafknappen i spelarinformationsf�nstret 
eller skapa den f�r de tv� spelarna i de aktuella partiet genom att v�lja Ratinggraf 
fr�n <b>[Verktygs]</b> menyn. 
</p>

<h3>V�rderingsgraff�nstret</h3>

<p>
V�rderingsgraff�nstret visar de numeriska v�rderingarna (po�ng) 
sparade i kommentarerna till det aktuella partiet som en graf. 
Du kan klicka med v�nster musknapp n�gonstans i v�rderingsgrafen f�r att g� till
motsvarande position i partiet. 
</p>

<p>
Tv� typer av v�rderingskommentarer finns: dessa produceras av Scids analysf�nster
(som har formatet 1.e4 {"+0.25 ...."} �r alltid v�rderade fr�n vits perspektiv) 
och de som produceras av Craftys analyskommando 
(som har formatet 1.e4 ({9:+0.25} ....) och ocks� �r v�rderade fr�n vits perspektiv). 
</p>

<h3>Tr�dgraff�nstret</h3>

<p>
Tr�dgraff�nstret finns i tr�df�nstret. Det visar resultatet av de mest popul�ra
dragen fr�n den aktuella positionen. 
Mer information finns i avsnittet om tr�df�nster. 
</p>

<p><footer>(Uppdaterat: Scid 3.3, April 2002)</footer></p>
}


####################
### Tablebases help:

set helpTitle(W,TB) "Slutspelstabeller"
set helpText(W,TB) {<h1>Slutspelstabeller</h1>

<h3>Slutspelsdatabaser</h3>

<p>
En slutspelsdatabas �r en fil som inneh�ller den perfekta resultatinformationen om alla positioner 
med ett visst material , som Kung och Torn mot Kung och Bonde. 
Slutspelstabeller f�r alla materiella situationer med upp till fem pj�ser (inklusive Kungar) 
har genererats och n�gra enkla 6-pj�sslutspelstabeller finns ocks� tillg�ngliga. 
</p>

<p>
Scid kan anv�nda slutspelsdatabaser i Nalimov-format som anv�nds av m�nga nyare schackmotorer. 
Dessa slutar ofta med �ndelserna .nbw.emd eller .nbb.emd. Alla 3-, 4- och 5-pj�s 
Nalimov-slutspelstabeller kan anv�ndas i Scid. 
</p>

<h3>Anv�nda slutspelstabeller i Scid</h3>

<p>
F�r att anv�nda slutspelstabeller i Scid specificera bara deras kataloger
genom att v�lja Slutspelstabellkatalog i <b>[Alternativ]</b> menyn. Du kan v�lja upp till 
4 kataloger d�r dina slutspelstabeller �r sparade. Du kan trycka p� ... 
knappen till h�ger om en inmatning f�r att v�lja en katalog f�r att specificera att
katalogen till den ska anv�ndas. 
</p>

<p>
N�r en position som hittats i slutspelstabellen har n�tts visar partiinformationsytan 
nedanf�r schackbr�det slutspelstabellinformation. 
Du kan konfigurera m�ngden information som visas genom att klicka med den h�gra
musknappen i den eller v�lja Partiinformation fr�n  <b>[Alternativ]</b> menyn. 
Genom att v�lja "Resultat och b�sta drag"  ges den mest anv�ndbara informationen, 
men det �r ofta mycket l�ngsammare �n "Bara resultat". 
</p>

<h3>Slutspelstabellf�nster</h3>

<p>
Du kan f� �nnu mer slutspelstabellinformation om den aktuella positionen genom att 
�ppna Slutspelstabellf�nstet i ([F�nster] menyn, tangentkombination: <b>Ctrl+Shift+=</b>). 
Detta f�nster visar resultatet med perfekt spel av alla legala drag fr�n den 
aktuella positionen. 
</p>

<p>
F�nstret har tv� huvudsakliga delar. Sammanfattningsdelen (till v�nster) visar 
vilka slutspelstabeller Scid har hittat p� din dator och en sammanfattning f�r varje 
slutspelstabell. Resultatdelen (till h�ger) visar optimala resultat f�r alla drag fr�n den
aktuella positionen som visas i huvudf�nstret. 
</p>

<h3>Sammanfattningsdelen</h3>

<p>
Den �vre delen av sammanfattningsdelen l�ter dig v�lja en speciell slutspelstabell. 
De som du har tillg�ngliga visas i bl�tt och de slutspelstabeller som inte finns visas
i gr�tt. Den nedre delen av sammanfattningsdelen visar sammanfattningsinformation
f�r den valda slutspelstabellen. 
(Alla slutspelstabeller har inte en sammanfattning i Scid) 
</p>

<p>
Sammanfattningen inkluderar frekvensen(hur m�nga partier per million som n�r 
en position med detta material ber�knat fr�n en databas med mer �n 
600000 m�sterpartier), en l�ngsta matt f�r en sida samt antalet 
�msesidiga (eller "reciprokala") dragtv�ng. Ett �msesidigt dragtv�ng �r en 
position d�r vit vid draget f�r remi och svart vid draget f�rlorar eller d�r 
vit vid draget f�rlorar och svart vid draget f�r remi eller d�r den som �r vid draget
f�rlorar. 
</p>

<p>
F�r n�gra slutspelstabeller med �msesidiga dragtv�ng visar sammanfattningen 
ocks� en lista p� alla dragtv�ngspositioner eller ett urval av dem. En fullst�ndig
lista p� alla slutspelstabeller �r inte m�jlig eftersom vissa slutspelstabeller har 
tusentals �msesidiga dragtv�ng. 
</p>

<p>
Du kan s�tta upp en slumpm�ssig position fr�n den valda slutspelsdatabasen
genom att trycka p� Slumpknappen. 
</p>

<h3>Resultatdelen</h3>

<p>
Resultatdelen uppdateras n�r schackbr�det i huvudf�nstret �ndras. 
Den f�rsta linjen visar hur m�nga drag vinner (+), ger remi (=), f�rlorar (-), 
eller har ett ok�nt resultat (?). Resten av resultatdelen ger en mer detaljerad 
lista p� resultat, rangordnande dem fr�n kortaste till l�ngsta matt, sedan remier, 
sedan l�ngsta till kortaste f�rluster. Alla avst�nd �r till matt. 
</p>

<h3>Resultatbr�det</h3>

<p>
I en slutspelstabellposition �r det ofta anv�ndbart att se vad 
slutspelstabellresultatet skulle vara om alla pj�ser i den aktuella
positionen var p� sina aktuella rutor men en s�rskild pj�s flyttas n�gon 
annanstans. Till exempel kan du vilja best�mma hur n�ra en kung m�ste vara
till en fribonde f�r att vinna eller f� remi i en s�rskild position. I slutspelsb�cker
kallas denna information ofta vinstzonen eller remizonen f�r en pj�s i en position. 
</p>

<p>
Du kan hitta denna information i Scid genom att trycka p� knappen med en
bild p� schackbr�det f�r att visa resultatbr�det i slutspelstabellf�nstret. 
N�r du trycker p� v�nster musknapp p� n�gon av pj�serna p� br�det visas 
en symbol i varje tom ruta visande vad slutspelstabellresultatet blir 
(med samma sida vid draget som i den aktuella positionen p� huvudf�nstret) 
om den valda pj�sen var p� den rutan. 
</p>

<p>
Det finns fem olika symboler en ruta kan ha: en vit # betyder att vit vinner; 
ett svart  # betyder att svart vinner; ett bl�tt = betyder att positionen �r remi; 
ett r�tt X betyder  att positionen �r illegal (eftersom kungarna st�r brevid 
varandra eller sidan vid draget ger schack); och ett r�tt ? betyder att resultatet 
�r ok�nt beroende p� att den n�dv�ndiga slutspelstabellen inte finns tillg�nglig. 
</p>

<h3>F� tillg�ng till slutspelstabellsfiler</h3>

<p>
Se avsnittet om relaterade l�nkar f�r hj�lp med att hitta slutspelstabeller p� Internet. 
</p>

<p><footer>(Uppdaterat: Scid 3.4, September 2002)</footer></p>
}


###################
### Bookmarks help:

set helpTitle(W,Bookmarks) "Bokm�rken"
set helpText(W,Bookmarks) {<h1>Bokm�rken</h1>
<p>
Scid l�ter dig bokm�rka viktiga partier f�r enkel framtida referens. 
Bokm�rkesmenyn finns i <b>[Arkiv]</b> menyn och i verktygsraden och har
tangentkombinationen: 
<b>Ctrl+B</b> . 
</p>

<p>
N�r du v�ljer ett bokm�rkt parti fr�n Bokm�rkesmenyn 
kommer Scid att �ppna dess databas om det �r n�dv�ndigt, hitta partiet, 
och g� till den schackposition som var n�r den bokm�rktes. 
</p>

<p>
Bara partier i en Scidformaterad databas (inte en PGN-fil eller Clipbasen) 
kan bokm�rkas. 
</p>

<p>
Om databasen till ett bokm�rkt parti sorteras eller kompimeras kan 
bokm�rkesdetaljerna bli inaktuella. N�r det h�nder kommer Scid att
s�ka igenom databasen efter det b�st matchande partiet 
(j�mf�r Spelare, Ort, Resultat, �r etc) n�r bokm�rket v�ljs, 
s� att det bokm�rkta partiet fortfarande blir laddat. Men om 
detaljerna i det bokm�rkta partiet �ndras �r det m�jligt att ett annat 
parti kommer att matcha bokm�rkesdetaljerna b�ttre och laddas ist�llet. 
S� det �r en bra id� att om-bokm�rka ett parti om du �ndrar i dess 
Spelare, Ort, Resultat, Runda eller �r. 
</p>

<h3>�ndra bokm�rken</h3>
<p>
Med bokm�rkeseditorn kan du �ndra menytexten som visas f�r varje 
bokm�rkt parti och l�gga till kataloger f�r att kategorisera bokm�rken. 
</p>
<h3>Tips</h3>
<p>
Du kan anv�nda bokm�rken f�r snabb tillg�ng till databaser du ofta 
anv�nder genom att bokm�rka ett parti fr�n varje databas. En annan 
god anv�ndning f�r bokm�rken �r att l�gga till viktiga partier du hittar
n�r du studerar en viss schack�ppning. 
</p>

<p>
Bokm�rkesmenyn inneh�ller tv� alternativ f�r att kontrollera visandet av 
bokm�rkeskataloger : de kan visas som undermenyer 
(anv�ndbart n�r det finns m�nga bokm�rken) eller som en enkel lista. 
</p>

<p><footer>(Uppdaterat: Scid 3.0, November 2001)</footer></p>
}


##############################
### Command-line options help:

set helpTitle(W,Cmdline) "Kommandorad-alternativ"
set helpText(W,Cmdline) {<h1>Kommandorad-alternativ</h1>
<h3>Kommandorad-alternativ</h3>
<p>
N�r du startar Scid fr�n ett gr�nsnitt eller consol, 
finns det kommandorad-alternativ du kan specificera. 
Scid-format databaser (med eller utan en fil�ndelse som <b>"*.si3"</b>) 
och PGN-filer att �ppna kan anges, till exempel: 
<b>scid minbas nyapartier.pgn</b> 
kommer att starta Scid och �ppna Scid-databasen <b>mybase</b> och  
PGN-filen <b>nyapartier.pgn</b>. 
</p>

<p>
Det finns ocks� optionella argument f�r att kontrollera vilka filer Scid 
ska leta efter och anv�nda n�r det startar.
Du kan st�nga av anv�ndningen av slutspelstabeller med <b>-xtb</b> (eller <b>-xt</b>) alternativet, 
undvika att ladda in ECO �ppningsklassificeringsfiler med <b>-xeco</b> eller <b>-xe</b>, 
och undvika att ladda in stavningsfilen med -xspell eller -xs.
Ut�ver detta ger alternativet <b>-fast</b> eller <b>-f</b> alla dessa tre saker , 
s� <b>scid -f</b> �r samma som <b>scid -xeco -xspell -xtb</b>. 
</p>

(Updaterat: Scid 3.1, November 2001)


}


####################
### Compaction help:

set helpTitle(W,Compact) "Komprimera databas"
set helpText(W,Compact) {<h1>Komprimera databas</h1>
<p>
<h3>Komprimera databas</h3>

<p>
Att komprimera en databas �r en speciell typ av underh�ll 
som h�ller en databas s� liten och effektiv som m�jligt. 
Att komprimera en databas betyder att ta bort allt oanv�nt
utrymme i dess filer . Det finns tv� typer: namnfils- och partifilskomprimering. 
</p>

<h3>Namnfilskomprimering</h3>

<p>
�ver tiden kan du finna att databasen b�rjar att inneh�lla ett antal spelarnamn, 
evenemangs-, orts- eller rundenamn som inte l�ngre anv�nds i n�got parti. 
Detta h�nder ofta efter att du stavningskontrollerar namn. 
De oanv�nda namnen sl�sar utrymme i namnfilen och kan sakta mer namns�kningar. 
Namnfilskomprimering tar bort alla namn som inte anv�nds i n�got parti. 
</p>

<h3>Partifilskomprimering</h3>

<p>
N�r ett parti ers�tts eller tas bort l�mnas oanv�nt utrymme i partifilen
(den st�rsta av de tre filerna i en Scid databas). 
Partifilskomprimering tar bort allt oanv�nt utrymme och l�mnar inga borttagna partier
i databasen. Observera att denna operation �r slutgiltig:
efter komprimering �r de bortagna partierna borta f�r evigt! 
</p>

<p>
Partifilskomprimering rekommenderas ocks� efter att ha sorterat en databas f�r att
h�lla ordningen p� partifilen konsistent med den sorterade indexfilen. 
</p>

<p><footer>(Uppdaterat: Scid 2.5, Juni 2001)</footer></p>
}


####################################
### Database maintenance tools help:

set helpTitle(W,Maintenance) "Underh�ll databas"
set helpText(W,Maintenance) {<h1>Underh�ll databas</h1>

<h3>Underh�ll databas</h3>
<p>
Scid har ett antal redskap f�r att underh�lla databaser, 
tillg�ngliga fr�n Scids Arkivmeny. Databaskomprimeringen 
och sorteringsfunktionerna f�rklaras i separata avsnitt. 
</p>


<h3>Underh�llsf�nstret</h3>
<p>
Det mesta av Scids databasunderh�ll kan g�ras fr�n underh�llsf�nstret 
, som kan �ppnas fr�n 
<b>[Arkiv: Underh�ll]</b> eller <b>[F�nster]</b> menyerna eller med tangentkombinationen:
<b>Ctrl+M</b>. 
</p>

<p>
Du kan anv�nda detta f�nster f�r att underh�lla partimarkeringar, 
stavningskontrollera namn, komprimera eller sortera en databas. 
Observera att alla operationer som inte finns tillg�ngliga f�r den aktuella
databasen (till exempel, p� grund av att den �r skrivskyddad eller en 
PGN-fil) visas med gr� f�rg. 
</p>

<h3>Ta bort dubbla partier</h3>
<p>
I <b>[Arkiv: Underh�ll]</b> menyn finns ett kommando <b>[Ta bort dubbla partier...]</b> 
f�r att detektera extra kopior (dubbletter) av partier i databasen. 
Detta kommando hittar alla dubbletter och f�r varje par markeras det kortare 
partiet f�r borttagning medan det l�ngre partiet l�mnas kvar. 
Tv� partier anses vara dubbletter om spelarna 
(och alla andra markeringar som du kan specificera) matchar exakt.
</p>

<p>
Om du specificerar  "samma drag" alternativet m�ste varje par av partier ha 
samma drag upp till l�ngden av det kortare partiet 
(eller upp till drag 60) f�r att vara dubbletter. 
</p>

<p>
N�r du har tagit bort dubbletter �r det en bra id� att kontrollera att 
varje borttaget parti verkligen �r en kopia av ett annat parti. Du kan g�ra detta
enkelt om du valde "S�tt filter till alla borttagna partier" alternativet i ta bort
dubbletter dialogrutan. Filtret kommer d� att inneh�lla alla borttagna partier. 
Du kan bl�ddra genom dem  (med <b>p</b> och <b>n</b> tangenterna) med kontrollera 
dubbla partier f�nstret  (finns i underh�llsmenyn eller med tangentkombinationen <b>Ctrl+Shift+T</b>) 
f�r att verifiera att varje borttaget parti �r borttaget f�r att det faktiskt �r en dubblett av ett
annat parti. 
</p>

<h3>�ndra spelar, evenemang, ort och rundenamn</h3>

<p>
Du kan finna felstavade namn i din databas och vilja korrigera dem. 
Du kan g�ra detta i Scid med Namneditorf�nstret 
(tangentkombination: <b>Ctrl+Shift+N</b>), som finns i <b>[Arkiv: Underh�ll]</b>
undermenyn. 
</p>

<p>
Varje unikt namn lagras bara en g�ng i namnfilen, s� om du �ndrar ett namn s�
�ndrar du alla f�rekomster av det. 
</p>
<h3>Stavningskontrollera namn</h3>
<p>
Scid kommer med en stavningskontrollfil med namnet spelling.ssp, 
f�r att korrigera spelar-, evenemang-, orts- och rundenamn. 
Scid kommer att f�rs�ka ladda stavningskontrollfilen n�r det startar; 
om den inte laddas in d� kan du ladda in den fr�n <b>[Alternativ]</b> menyn. 
</p>

<p>
N�r stavningskontrollfilen �r laddad kan du anv�nda den p� en Scid databas med 
stavningskontrollkommandorna i  <b>[Arkiv: Underh�ll]</b> menyn eller fr�n 
underh�llsf�nstret. 
</p>

<p>
N�r du stavningskontrollerar en databas producerar Scid en lista p� korrektioner som du 
kan �ndra i innan n�gra �ndringar g�rs, s� att du kan ta bort alla korrektioner du inte
vill g�ra.
</p>

<p>
Stavningskontroll �r speciellt viktigt f�r att standardisera en databas s� att alla f�rekomster
av en speciell spelare stavas likadant. Till exampel, med standard stavningskontrollfilen, 
s� korrigeras namnen "Kramnik,V.", "Vladimir Kramnik", och "V. Kramnik" till "Kramnik, Vladimir". 
</p>

<p>
Stavningskontrollfilen har en ytterligare anv�ndning: n�r den laddas anv�nds dess spelardata
f�r att f�rb�ttra spelarinformationsf�nstret och korttabellf�nstret: : du kommer att se FIDE 
m�startitlar som (gm = Internationell Storm�stare, im = Internationell M�stare, etc) och 
landsinformation f�r spelarna listas i stavningskontrollfilen. 
�ver 6500 starka spelare fr�n historien och nutiden finns listade i <b>spelling.ssp</b> filen som 
kommer med Scid. 
</p>

<h3>L�gga till Elo rating till partier</h3>

<p>
"L�gg till Elo rating..." knappen i underh�llsf�nstret f�r Scid att s�ka igenom den aktuella 
databasen efter partier d�r en spelare inte har en rating, men d�r stavningskontrollfilen 
har en Elo rating listad f�r denna spelare vid tiden f�r partiet. Scid kommer att l�gga till all 
s�dan rating automatiskt. Detta �r mycket anv�ndbart f�r en databas med m�starpartier 
som har f� ratings.
</p>

<p>
Stavningskontrollfilen "spelling.ssp" som kommer med Scid inneh�ller inte Elo rating 
informationen som beh�vs f�r denna funktion, men en st�rre variant av den kallad "ratings.ssp" 
finns p� Scids webbsajt. 
</p>

<h3>Rensaren</h3>
<p>
Rensaren (som finns i Underh�llsf�nstret) �r ett redskap f�r att g�ra ett antal 
underh�llsarbeten p� en databas med en �tg�rd. Du kan v�lja vilka arbeten du vill 
g�ra och Scid kommer att utf�ra dem p� den aktuella databasen utan att kr�va
anv�ndarinteraktion. Detta �r speciallt anv�ndbart f�r underh�ll av stora databaser. 
</p>

<h3>St�lla in att databasen ska ladda in ett parti automatiskt</h3>
<p>
Vid automatiskt laddande av ett parti i en databas s� laddas detta parti in n�r denna 
databas �ppnas. F�r att �ndra det automatiska laddandet av partiet i databasen, 
anv�nd "Autoladda parti nummer..." knappen. Om du alltid vill att det sista partiet i en 
databas ska �ppnas  (oavsett om hur m�nga partier som finns i databasen),
s� st�ll in det till ett h�gt nummer som 9999999. 
</p>

<p><footer>(Uppdaterat: Scid 3.1, December 2001)</footer></p>
}


##############
### ECO guide:

set helpTitle(W,ECO) "ECO"
set helpText(W,ECO) {<h1>ECO-�ppningsklassificering</h1>

<h3>ECO �ppningsklassificering</h3>
<p>
Scid kan klassificera schackpartier enligt ECO 
(Encyclopedia of Chess Openings) schack�ppningsklassificering. 
En standard ECO-kod best�r av en bokstav (A-E) f�ljt av tv� siffror, 
s� det finns 500 distinkta standard ECO-coder. 
</p>

<h3>Scids utvidgningar av ECOs �ppningsklassificering</h3>

<p>
ECO klassificeringen �r v�ldigt begr�nsad och inte tillr�cklig f�r moderna partier:
n�gra av de 500 koderna syns n�stan aldrig, medan n�gra syns v�ldigt ofta. 
F�r att f�rb�ttra denna situation till�ter Scid en optionell ut�kning av de grundl�ggande 
ECO-koderna: varje kod kan bli ut�kad med en bokstav (a-z) som dessutom kan ut�kas
ytterligare (med en siffra fr�n 1-4)  men det anv�nds inte �nnu i standard Scid ECO-filen . 
S� en ut�kad Scid ECO-kod ser ut antingen som "A41e" eller som "E99b2". 
M�nga av de mest vanliga ECO-koderna som finns i moderna m�starpartier har
ut�kningar definerade i Scids ECO-fil. 
</p>

<h3>ECO Bl�ddrarf�nstret</h3>

<p>
ECO Bl�ddrarf�nstret visar dig de positioner som anv�nds f�r att klassificera varje ECO-kod, 
samt frekvensen och resultatet av ECO-koderna i den aktuella databasen. 
</p>

<p>
Den �vre delen visar frekvensen f�r varje ECO-kod i den aktuella databasen. 
F�rgerna i grafen finns i tre sektioner: den l�gsta (ljusaste f�rgen) visar antalet vita vinster, 
den mittersta visar antalet remier, och den h�gsta (m�rkaste f�rgen) visar antalet svarta vinster. 
Detta l�ter dig snabbt se om en �ppning �r bra eller d�lig f�r vit eller om remier �r mycket vanliga. 
</p>

<p>
F�r att g� till en djupare ECO niv� klicka med v�nster musknapp p� en del av grafen
(eller skriv den bokstav eller siffra den motsvarar). F�r att g� tillbaka till en h�gre niv�, 
klicka med h�ger musknapp i grafen eller tryck p� v�nsterpilen (eller delete eller bak�t). 
</p>

<p>
Den nedre delen visar de positioner som utg�r en speciell ECO-kod, 
enligt den ECO-fil som du har �ppnat. 
</p>

<h3>�ppna Scids ECO-fil</h3>
<p>
ECO-filen som kommer med Scid heter scid.eco och Scid f�rs�ker att �ppna den n�r det 
startar. Om Scid inte kan hitta den beh�ver du g�ra f�ljande f�r att anv�nda 
ECO-klassificeringen: 
</p>

<p>
(a) I Scid anv�nd menykommandot <b>[Alternativ: Ladda ECO-fil]</b> och v�lj filen <b>scid.eco</b>. 
(b) Spara alternativ (i  <b>[Alternativ]</b> menyn). 
Efter att du har gjort deta kommer ECO-filen att laddas varje g�ng du startar Scid. 
</p>

<h3>ECO-koderna</h3>
<p>
Den grundl�ggande strukturen i ECO �r:
</p>

A 1.d4 Nf6 2...; 1.d4 ...; 1.c4; 1.diverse
<ul>
<li>A0 1.diverse (A02-A03 1.f4: Birds �ppning, A04-A09 1.Nf3: Reti, Kungsindisk attack) </li>
<li>A1 1.c4 ...: Engelsk </li>
<li>A2 1.c4 e5: Kungsengelsk </li> 
<li>A3 1.c4 c5: Engelsk, Symmetriskt </li> 
<li>A4 1.d4 ...: Dambonde </li>
<li>A5 1.d4 Nf6 2.c4 ..: Indiskt f�rsvar </li> 
<li>A6 1.d4 Nf6 2.c4 c5 3.d5 e6: Modern Benoni </li> 
<li>A7 A6 + 4.Nc3 exd5 5.cxd5 d6 6.e4 g6 7.Nf3 </li>
<li>A8 1.d4 f5: Holl�ndskt f�rsvar </li>
<li>A9 1.d4 f5 2.c4 e6: Holl�ndskt f�rsvar </li>
</ul>
B 1.e4 c5; 1.e4 c6; 1.e4 d6; 1.e4 diverse 
<ul>
<li>B0 1.e4 ... (B02-B05 1.e4 Nf6: Alekhines f�rsvar; B07-B09 1.e4 d6: Pirc) </li>
<li>B1 1.e4 c6: Caro-Kann </li>
<li>B2 1.e4 c5: Sicilianskt f�rsvar </li> 
<li>B3 1.e4 c5 2.Nf3 Nc6: Sicilianskt </li>
<li>B4 1.e4 c5 2.Nf3 e6: Sicilianskt </li>
<li>B5 1.e4 c5 2.Nf3 d6: Sicilianskt </li>
<li>B6 B5 + 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 Nc6 </li>
<li>B7 B5 + 4.Nxd4 Nf6 5.Nc3 g6: Siciliansk Drake </li>
<li>B8 B5 + 4.Nxd4 Nf6 5.Nc3 e6: Siciliansk Scheveningen </li> 
<li>B9 B5 + 4.Nxd4 Nf6 5.Nc3 a6: Siciliansk Najdorf </li>
</ul>
C 1.e4 e5; 1.e4 e6 

<ul>
<li>C0 1.e4 e6: Franskt F�rsvar </li>
<li>C1 1.e4 e6 2.d4 d5 3.Nc3: Franskt, Winawer/Klassisk </li> 
<li>C2 1.e4 e5: �ppet parti </li>
<li>C3 1.e4 e5 2.f4: Kungsgambit </li>
<li>C4 1.e4 e5 2.Nf3: �ppet parti </li>
<li>C5 1.e4 e5 2.Nf3 Nc6 3.Bc4: Italienskt; Tv�springar </li>
<li>C6 1.e4 e5 2.Nf3 Nc6 3.Bb5: Spanskt (Ruy Lopez) </li>
<li>C7 1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4: Spanskt </li>
<li>C8 C7 + 4...Nf6 5.O-O: Spanskt, �ppet och St�ngt (C80-C83 5.O-O Nxe4: Spanskt, �ppet system; C84-C89 5.O-O Be7: Spanskt, St�ngt system) </li>
<li>C9 C8 + 5...Be7 6.Re1 b5 7.Bb3 d6: Spanskt, St�ngt </li>
</ul>
D 1.d4 d5; 1.d4 Nf6 2.c4 g6 med 3...d5 
<ul>
<li>D0 1.d4 d5: Dambonde </li>
<li>D1 1.d4 d5 2.c4 c6: Slaviskt f�rsvar </li> 
<li>D2 1.d4 d5 2.c4 dxc4: Antagen damgambit </li>
<li>D3 1.d4 d5 2.c4 e6: Avb�jd damgambit  </li>
<li>D4 D3 + 3.Nc3 Nf6 4.Nf3 c5/c6: Semi-Tarrasch; Semi-Slav </li>
<li>D5 D3 + 3.Nc3 Nf6 4.Bg5: Avb�jd klassisk damgambit</li>
<li>D6 D5 + 4...Be7 5.e3 O-O 6.Nf3 Nbd7: Avb�jd  ortodox damgambit </li>
<li>D7 1.d4 Nf6 2.c4 g6 with 3...d5: Gr�nfeld </li>
<li>D8 1.d4 Nf6 2.c4 g6 3.Nc3 d5: Gr�nfeld </li>
<li>D9 1.d4 Nf6 2.c4 g6 3.Nc3 d5 4.Nf3: Gr�nfeld </li>
</ul>
 
E 1.d4 Nf6 2.c4 e6; 1.d4 Nf6 2.c4 g6 

<ul>
<li>E0 1.d4 Nf6 2.c4 e6: Katalanskt, mm </li>
<li>E1 1.d4 Nf6 2.c4 e6 3.Nf3 (b6): Damindiskt, mm </li>
<li>E2 1.d4 Nf6 2.c4 e6 3.Nc3 (Bb4): Nimzo-Indiskt, mm </li>
<li>E3 E2 + 4.Bg5 or 4.Qc2: Nimzo-Indiskt </li>
<li>E4 E2 + 4.e3: Nimzo-Indiskt, Rubinstein </li>
<li>E5 E4 + 4...O-O 5.Nf3: Nimzo-Indiskt, huvudvariant </li> 
<li>E6 1.d4 Nf6 2.c4 g6: Kungindiskt </li>
<li>E7 1.d4 Nf6 2.c4 g6 3.Nc3 Bg7 4.e4: Kungsindiskt </li>
<li>E8 E7 + 4...d6 5.f3: Kungsindiskt, S�misch </li>
<li>E9 E7 + 4...d6 5.Nf3: Kungsindiskt, huvudvarianter </li>
</ul>

<p><footer>(Uppdaterat: Scid 2.5, Juni 2001)</footer></p>
}

####################
### Calvar window help:

set helpTitle(W,CalVar) "Ber�kning av variationer"
set helpText(W,CalVar) {<h1>Ber�kning av variationer-f�nstret</h1>
  <p>
Denna tr�nings�vning �r ocks� k�nd som Stoyko-�vningen.
Dess syfte �r att analysera en komplex position och utv�rdera s� m�nga sunda variationer som m�jligt,
och ge en korrekt v�rdering f�r varje av dem.
  </p>
<p><h3>Konfiguration</h3></p>
Tre parametrars anges :
<ul>
<li>Den UCI-schackmotor som kommer att analysera olika variationer</li>
<li>Den tid, i sekunder, som schackmotorn kommer att anv�nda f�r att analysera positionen</li>
<li>Den tid, i sekunder, som schackmotorn kommer att anv�nda f�r att analysera varje variation som har angivits av anv�ndaren</li>
</ul>
<p><h3>Ange variationer</h3></p>
Drag anges som vanligt med musklick p� br�det men de visas inte. Vid slutet p� varje variation beh�ver anv�ndaren ange en v�rdering genom att klicka p� en av knapparna med NAG-v�rden.
  <p><h3>V�rderingsverifikation</h3></p>
Varje g�ng en v�rdering anges till en variation berknar schackmotorn dess v�rde och l�gger till variationen och v�rderingen precis nedanf�r anv�ndarens.
  <p><h3>Klar med position</h3></p>
N�r anv�ndaren tror att han har hittat alla de b�sta variationerna, kommer tryckandet p� <b>Klar med position</b> att l�gga till i partiet
(med kommentaren <b>Missad variation</b>), de variationer som har en h�gre v�rdering �n de b�sta variationerna som har angetts av anv�ndaren.

  <p><footer>(Uppdaterat: Scid 3.6.21, December 2007)</footer></p>
}

####################
### EPD files help:

set helpTitle(W,EPD) "EPD"
set helpText(W,EPD) {<h1>EPD-filer</h1>

<h3>EPD filer</h3>
<p>
En EPD (extended position description) fil �r en samling av positioner, 
d�r varje position har n�gon tillh�rande text. Det �r precis som PGN �r det 
en vanlig standard f�r schackinformation. 
</p>

<p>
En EPD-fil har ett antal definierade <b>opcodes (f�lt)</b> som �r lagrade 
separade med semikolon <b>(;)</b> i filen men visas p� olika rader 
i ett Scid EPD-f�nster f�r att g�ra �ndringar l�ttarer. Ett semikolon inom ett 
EPD-f�lt lagras som <b>"\s"</b> av Scid f�r att skilja det fr�n en markering av slutet av f�ltet. 
Varje position och dess tillh�rande opcodes lagras p� en enkel rad i EPD-filen. 
</p>

<p>
Standard <b>EPD-opcodes</b> inkluderar: 
</p>

<p>
<li><b>acd</b> Analysr�kning: s�kdjup.</li> 
<li><b>acn</b> Analysr�kning: antal s�kta noder.</li> 
<li><b>acs</b> Analysr�kning: s�ktid i sekunder.</li> 
<li><b>bm</b> B�sta drag: drag som anses b�st av n�gon anledning.</li> 
<li><b>ce</b> Hundradelsbondev�rdering: v�rdering i hundradelar av en bonde f�r den sida 
som �r vid draget (Observera att detta skiljer sig fr�n Analysf�nstret som visar 
v�rderingen i b�nder fr�n vits perspektiv).</li> 
<li><b>cX</b> Kommentar (d�r <b>X</b> �r en siffra fr�n 0-9).</li> 
<li><b>eco</b> ECO �ppningskod.</li> 
<li><b>id</b> Unik identifikation av denna position.</li> 
<li><b>nic</b> New In Chess (NIC) �ppningskod.</li> 
<li><b>pm</b> F�rutsp�tt drag: det f�rsta draget i den f�rutsp�dda variationen (PV).</li> 
<li><b>pv</b> F�rutsp�dd variation: den b�sta dragf�ljden.</li>
</p>

<p>
EPD-filer har ett antal anv�ndningar: Scid anv�nder en EPD-fil f�r att klassificera
partier enligt Encyclopedia of Chess Openings (ECO) , 
och du kan skapa en EPD-fil f�r din �ppningsrepetoar samt 
l�gga till kommentarer f�r positioner du vanligtvis n�r i partier. 
</p>

<p>
Du kan skapa en ny EPD-fil eller �ppna en existerande fr�n  <b>[Ny]</b> och <b>[�ppna]</b> 
kommandorna i  <b>[Arkiv]</b> menyn. Som mest kan fyra EPD-filer vara �ppnade. 
</p>

<h3>EPD f�nster</h3>

<p>
F�r varje �ppnad EPD-fil ser du will ett f�nster som visar texten f�r den aktuella positionen. 
Du beh�ver inte trycka p� <b>Spara</b> knappen f�r att spara de f�r�ndringar du g�r med 
en positionstext; texten sparas n�r du g�r till en annan position i partiet. 
</p>

<h3>Navigera i EPD-filer</h3>

<p>
F�r att bl�ddra genom positionerna i en EPD-fil anv�nd <b>[N�sta position]</b> och <b>[Tidigare position]</b> 
kommandorna fr�n EPD-f�nstret i <b>[Verktygs]</b> menyn eller anv�nd tangentkombinationerna 
<b>Ctrl+NerPil</b> och <b>Ctrl+UppPil</b>. Dessa kommandon g�r till n�sta eller f�reg�ende position i filen, 
tar bort det aktuella partiet och st�ller in den nya startpositionen. 
</p>

<h3>Ta bort EPD-f�lt</h3>

<p>
EPD-filer du finner p� Internet kan inneh�lla f�lt som inte intresserar dig och de kan 
sl�sa mycket utrymme i filen. Till exempel, en EPD-fil med datorv�rderingar kan ha 
<b>ce</b>, <b>acd</b>, <b>acn</b>, <b>pm</b>, <b>pv</b> och <b>id</b> f�lt 
men du kanske bara beh�ver <b>ce</b> och <b>pv</b> f�lten. 
</p>

<p>
Du kan ta bort en EPD-opcode fr�n alla positioner i EPD-filen genom att anv�nda <b>[Ta bort EPD f�lt]</b> 
fr�n EPD-f�nstret i <b>[Verktygs]</b> menyn. 
</p>

<h3>EPD-f�nstrets resultat</h3>

<p>
Alla EPD-f�nster visar: 
</p>

<ul>
<li>- filstatus (-- betyder of�r�ndrad, <b>XX</b> betyder f�r�ndrad, och <b>%%</b> betyder skrivskyddad); </li>
<li>- filnamn; </li>
<li>- antal positioner i filen; </li>
<li>- legala drag fr�n den aktuella positionen f�r att n� en annan position i denna EPD-fil.</li> 
</ul>
<p><footer>(Uppdaterat: Scid 2.5, Juni 2001)</footer></p>
}


###################
### Exporting help:

set helpTitle(W,Export) "Exportera partier"
set helpText(W,Export) {<h1>Exportera partier</h1>
<p>
Du kan anv�nda funktionerna i <menu>Verktygs</menu>-menyn, f�r det
aktuella partiet eller f�r alla partier i det aktuella filtret f�r att exportera dragen
i en textfil.
</p>
<p>
Tre Textdata-format st�r till f�rfogande: <a PGN>PGN</a> (portable
game notation), HTML (f�r Webbsidor) och LaTeX (ett popul�rt
Textbearbetningssystem).
</p>
<p>
Vid export kan du v�lja att skapa en ny fil 
eller infoga partierna i en existierande partifil.
</p>

<h3>Diagram</h3>
<p>
N�r du exporterar i HTML- eller LaTeX-format , infogar Scid automatiskt
d�r ett diagram , d�r det finns en diagram-<a NAGs>NAG</a> ("D")
eller ett med tecknet "#" b�rjande <a Comment>Kommentar</a>
i partiet .
</p>

<h3><name Null>Null-drag vid PGN-Export</name></h3>
<p>
Scid till�ter att det sparas <a Annotating Null>Null- (inga drag)
drag</a> , d� dessa kan vara hj�lpsamma vid kommentarer av varianter. 
Det finns dock inga Null-drag i PGN-Standarden. 
N�r du d� exporterar Scid-partier med Null-drag i en PGN-fil
kan andra program oftast inte l�sa in partierna.
</p>
<p>
F�r att l�sa detta problem st�ller Scid en annan funktion till f�rfogande,
<b>Omvandla Null-drag till kommentarer</b>, n�r partier blir exporterade i 
PGN-format. N�r du vill skapa en PGN-fil, som kan anv�ndas av
andra program, anv�nder du denna funktion som omvandlar varianter med nolldrag 
till kommentarer.
N�r du �nd� vill skapa en PGN-fil, som senare kan importeras av Scid med bibeh�llande av
Null-drag st�nger du av denna funktion.
</p>

<h3>HTML-Export</h3>
<p>
Scid kan exportera partier i en HTML-filer. F�r att infoga diagram ,
m�ste diagrambilderna finnas (i katalogen "<b>bitmaps/</b>" )
i en underkatalog till "<b>bitmaps/</b>" i katalogen under  HTML-filen.
</p>

<h3>LaTeX-Export</h3>
<p>
Scid kan exportera partier i en LaTeX-fil. Partier blir sparade i
tv� kolumner per sida och dragen blir sparade i algebraisk
notation med symboler f�r pj�serna.
</p>
<p>
F�r mer information se hj�lpsidan <a LaTeX>Scid och LaTeX</a>.
</p>

<p><footer>(Uppdaterat: Scid 3.4, Juli 2002)</footer></p>
}


####################
### Flags help:

set helpTitle(W,Flags) "Parti-markeringarna"
set helpText(W,Flags) {<h1>Parti-markeringarna</h1>

<p>
En <term>Markering</term> ("Flags") �r ett K�nnetecken p� n�gon
schackegenskap, som kan markeras f�r varje parti i databasen. 
Det finns 13 av anv�ndare inst�llbara
markeringar, som du kan s�tta direkt i varje parti . Av dessa
har bara ta bort-markeringen en s�rskild betydelse: partier, som
�r markerade med ta bort-markeringen, �r markerade f�r att tas bort
och tas bort, n�r databasen blir
<a Compact>komprimerad</a> .
</p>
<p>
De andra 12 av anv�ndare inst�llbara markeringarna och deras
symboler �r:
</p>

<ul>
<li>�ppningen Vit (W)</li>
<li>�ppningen Svart (B)</li>
<li>Mittspelet (M)</li>
<li>Slutspelet (E)</li>
<li>Nyhet (N)</li>
<li>Bondestruktur (P)</li>
<li>Taktik (T)</li>
<li>Spel p� damflygeln (Q)</li>
<li>Spel p� Kungsflygeln (K)</li>
<li>Utomordentligt (!)</li>
<li>Blunder (?)</li>
<li>Anv�ndar-definierat (U)</li>
</ul>

<p>
En markering kan s�ttas f�r det aktuella partiet, f�r alla partier i
filtret eller f�r alla partier i databasen i
<a Maintenance>Underh�lls</a>-f�nstret.
</p>
<p>
Du kan anv�nda  <a Searches Header>S�kning efter Partidata</a> ,
f�r att finna alla datenbaspartier , som har en best�md markering 
eller anv�nda markeringarna som en del av en komplex s�kning.
</p>
<p>
D� alla av anv�ndare inst�llbara markeringar inte har n�gon betydelse f�r
Scid (med undantag av ta bort-markeringar), kan du anv�nda dessa f�r
dina egna syften. Till exempel kan anv�nda markeringen "Spel p� kungsflygeln" (K) 
f�r att leta efter bland annat bondestormar mot kungen , pj�sangrepp mot kungen 
eller slutspel med alla b�nder p� kungsflygeln.
</p>

<p><footer>(Uppdaterat: Scid 3.0, November 2001)</footer></p>
}


###############
### LaTeX help:

set helpTitle(W,LaTeX) "Scid och LaTeX"
set helpText(W,LaTeX) {<h1>Scid och LaTeX</h1>
<p>
Scid kan spara partier och �ppningsresultat i LaTeX-format i filer. 
LaTeX �r en utvidgning av TeX, ett popul�rt Textbehandlingssystem.
</p>
<p>
F�r att Scid ska kunna skapa LaTeX-filer , m�ste du
(naturligtvis) ha installerat LaTeX  och schackteckensnitts-paketet "chess12". 
Detta paket �r normalt inte en del av
LaTeX-Standardinstallation, dvs om du har LaTeX , har
du kanske inte schackteckensnittet.
</p>
<p>
Information om nedladdning och installation av
LaTeX-schackteckensnittet hittar du p� l�nken
<url http://scid.sourceforge.net/latex.html>Using LaTeX with Scid</url>
p� <url http://scid.sourceforge.net/>Scids Webbsida</url>.
</p>

<p><footer>(Uppdaterat: Scid 2.5, Juni 2001)</footer></p>
}


###########################
### Options and Fonts help:

set helpTitle(W,Options) "Alternativ"
set helpText(W,Options) {<h1>Alternativ och preferenser</h1>
<p>
M�nga alternativ och preferenser i Scid (som till exempel br�dstorleken, f�rger,
teckensnitt och standardinst�llningar) kan man �ndra i <menu>Alternativ</menu>-menyn. 
Alla dessa (och fler inst�llningar, som till exempel den sista katalogen i vilket du har l�st in en
databas och storleken p� n�gra f�nster)
blir sparat i en inst�llningsfil, n�r du v�ljer 
<b>Spara inst�llningar</b> i Alternativ-menyn.
Varje g�ng som Scid startar blir denna inst�llningsfil laddad.
</p>
<p>
N�r du arbetar med Windows , finns inst�llningsfilen <b>scid.opt</b>
i samma katalog som Scids programfil. F�r anv�ndare av
Unix-Operativsystem (som Solaris eller Linux) �r filen
<b>~/.scid/scidrc</b>.
</p>

<h3><name MyPlayerNames>Fastst�lla spelarnamn</name></h3>
<p>
Det kan vara s� att du vill se br�det i huvudf�nstret f�r en (eller flera) spelare 
fr�n dennes eller deras perspektiv n�r dennes eller deras partier �ppnas. 
Du kan ange en lista med s�dana namn med <b>Mina Spelarnamn...
</b> i Menyn <menu>Alternativ/Schachbr�de</menu>. 
I Dialogf�nstret matar du d� in ett spelarnamn per rad. 
Jokertecken som ("<b>?</b>" f�r ett ok�nt tecken och "<b>*</b>"
f�r en teckenkedja av noll eller flera tecken) �r till�tna.
</p>

<h3><name Fonts>St�lla in teckensnitt</name></h3>
<p>
Scid har tre teckensnitt som anv�nds i de flesta f�nster
och du kan anpassa alla tre individuellt. De heter
<b>normal</b>, <b>liten</b> och <b>fast</b>.
</p>
<p>
Det fasta teckensnittet borde vara ett teckensnitt med fast bredd
(inte-proportionellt) . Det anv�nds av <a Tree>Dragtr�det</a> och 
<a Crosstable>Korstabeller</a> .
</p>

<p><footer>(Uppdaterat: Scid 3.5, Februar 2003)</footer></p>
}


####################
### Pgnscid help:

set helpTitle(W,Pgnscid) "Pgnscid"
set helpText(W,Pgnscid) {<h1>Pgnscid</h1>
<p>
<term>Pgnscid</term> �r ett separat program, som du kan
anv�nda f�r att konvertera PGN-filer ("portable game notation") 
till Scid-Databaser.
</p>
<p>
F�r att konvertera en fil med namnet <i>partier.pgn</i> , skriver du
bara
<ul>
<li> <b>pgnscid partier.pgn</b> </li>
</ul>
och Scid-Databasen (best�ende av filerna
<i>partier.si3</i>, <i>partier.sg3</i> och <i>partier.sn3</i>) blir
skapade.
Felmeddelanden eller varningar blir skrivna i filen <i>partier.err</i>
.
</p>
<p>
N�r du vill att databasen ska skapas i en annan katalog eller
med ett annat namn, kan du ange datenbasnamnen
i kommandoraden, till exempel skapar
<ul>
<li> <b>pgnscid partier.pgn databas</b> </li>
</ul>
en databas best�ende av filerna <i>databas.si3</i>,
<i>databas.sg3</i> och <i>datenbas.sn3</i>.
</p>
<p>
Observera att pgnscid (och ocks� Scid) direkt kan l�sa gzip-komprimerade
PGN-filer som till exempel. <b>datenbas.pgn.gz</b>.
</p>

<h3>Alternativ</h3>
<p>
Pgnscid accepterar tv� optionella argument f�r filnamnen:
<b>-f</b> och <b>-x</b>.
</p>
<p>
Alternativet <b>-f</b> tvingar fram �verskrivandet av en existerande
databas; normalt �ndrar pgnscid inte i en redan
existerande databas.
</p>
<p>
Alternativet <b>-x</b> g�r att pgnscid ignorerar text mellan partierna. 
Normalt blir text mellan partierna sparat som en kommentar f�re det
f�ljande partiet. Detta alternativ g�ller bara text mellan partier; 
standardkommentarer i partierna blir dessutom konverterade och sparade.
</p>

<h3>Formatera spelarnamn</h3>
<p>
F�r att minska antalet olika stavningar av samma spelare
genomf�r pgnscid n�gra Grundformateringar
. Till exempel blir antalet mellanrum efter ett
komma satt till ett medan mellanrum i b�rjan eller slutet av ett namn
blir bortagna.
Holl�ndska Namn som "van den" och "Van Der" blir dessutom
normaliserade, s� att de har ett stort "V" och litet "d".
</p>
<p>
Du kan �ven �ndra Spelar-, Turnerings-, Orts- och Rundebeteckningar i Scid
(och till och med utf�ra automatisk skrivkorrektur);
f�r detaljerna se hj�lpsidan <a Maintenance Editing>Underh�ll</a>.
</p>

<p><footer>(Uppdaterat: Scid 2.5, Juni 2001)</footer></p>
}





#################
### Sorting help:

set helpTitle(W,Sorting) "Sortera databas"
set helpText(W,Sorting) {<h1>Sortera databas</h1>
<p>
<term>Sortera</term>-Funktionerna sorterar alla partier i en
databas. Du kan v�lja flera sorteringskriterier .
N�r tv� partier �r likv�rdiga efter ett kriterium, blir
de sorterade efter det andra kriteriet och s� vidare.
</p>

<h3>Sorteringskriterier</h3>
<p>
De tillg�ngliga sorteringskriterierna �r:
</p>
<ul>
<li> Datum (�ldsta partier f�rst)
<li> �r (som Datum, men bara �ret anv�nds)
<li> Turnering (Tilldragelse)
<li> Ort
<li> Land (de sista 3 bokst�verna i orten)
<li> Runda
<li> Vit
<li> Elo-tal (Genomsnitt av Vit och Svart, h�gst f�rst)
<li> Svart
<li> Resultat (Vit vinner, d�refter remier, d�refter Svart vinner)
<li> L�ngd (Antal hela drag i partiet)
<li> ECO-kod enligt <a ECO>Encyclopedia of Chess Openings</a>)
</ul>

<h3>Sorteringsresultatet</h3>
<p>
N�r du inte sorterar en skrivskyddad Scid-Databas , blir 
sorteringsresultatet s�krat genom att l�ngvarigt �ndra i ordningsf�ljden 
i databaspartierna. Om du bara vill g�ra en tempor�r sortering ,
skyddar du f�rst databasen mot �verskrivande med med menyfunktionen
<menu>Fil: Skrivskydd</menu>.
</p>
<p>
N�r du sorterar en databas , som �r skrivskyddad eller best�r av
en PGN-fil , kan sorteringsresultatet inte bli s�krat , vilket g�r att 
den sorterade partiordningsf�ljden g�r f�rlorad n�r filen
st�ngs.
</p>
<p>
Observera att sorteringen av en databas i
<a Searches filtret>S�kfilter</a> �ndrar i alla partier.
</p>

<h3>Viktig hj�lp f�r databas-sortering:</h3>
<p>
N�r en Databas blir sorterad , �r indexfilen �ndrad, men
partifilen �r of�r�ndrad. Det vill s�ga, sorteringen av en databas
l�mnar partidata-filen i en tillf�llig ordningsf�ljd relativ till 
indexfilen. Detta kan g�ra <a Tree>Dragtr�d</a>-,
Positions- och Material/M�nster-<a Searches>S�kningar</a> m�rkbart
<b>l�ngsammare</b>, du b�r d�rf�r efter att ha sorterat databasen
�ndra i partifilen genom att <a Compact>Komprimera</a> ,
f�r att f� bra s�kprestanda .
</p>

<p><footer>(Uppdaterat: Scid 2.5, Juni 2001)</footer></p>
}





####################
### NAG values help:

set helpTitle(W,NAGs) "NAG-v�rden"
set helpText(W,NAGs) {<h1>Standard-NAG-v�rden</h1>
<p>
Standard-NAG-v�rden (Numeric Annotation Glyph = "numeriska
Anm�rkningglyfer"), som definieras i <a Author Related>PGN-Standard</a> ,
�r:
</p>
<cyan>
<ul>
<li>  1   Bra drag (!) </li>
<li>  2   D�ligt drag (?) </li>
<li>  3   Utomordentligt drag (!!) </li>
<li>  4   Stort misstag / Blunder (??) </li>
<li>  5   Intressant drag (!?) </li>
<li>  6   Tveksamt drag (?!) </li>
<li>  7   Tvingat drag </li>
<li>  8   Det enda draget; det finns inga andra bra drag </li>
<li>  9   S�msta draget </li>
<li> 10   Utj�mnad position (=) </li>
<li> 11   Lika chanser, lugn st�llning (=) </li>
<li> 12   Lika chanser, aktiv st�llning (=) </li>
<li> 13   Oklar st�llning (~) </li>
<li> 14   Vit har en liten f�rdel, st�r n�got b�ttre (+=) </li>
<li> 15   Svart har en liten f�rdel, st�r n�got b�ttre (=+) </li>
<li> 16   Vit har f�rdel, st�r b�ttre (+/-) </li>
<li> 17   Svart har f�rdel, st�r b�ttre (-/+) </li>
<li> 18   Vit har en avg�rande f�rdel (+-) </li>
<li> 19   Svart har en avg�rande f�rdel (-+) </li>
<li> 20   Vit har en �verv�ldigande f�rdel (+-) </li>
<li> 21   Svart har en �verv�ldigande f�rdel (-+) </li>
<li> 22   Vit �r i dragtv�ng </li>
<li> 23   Svart �r i dragtv�ng </li>
<li> 24   Vit har en liten utrymmesf�rdel </li>
<li> 25   Svart har en liten utrymmesf�rdel </li>
<li> 26   Vit har en utrymmesf�rdel </li>
<li> 27   Svart har en utrymmesf�rdel </li>
<li> 28   Vit har en avg�rande utrymmesf�rdel </li>
<li> 29   Svart har en avg�rande utrymmesf�rdel </li>
<li> 30   Vit har ett litet Tids-(Utvecklings)f�rspr�ng </li>
<li> 31   Svart har ett litet Tids-(Utvecklings)f�rspr�ng </li>
<li> 32   Vit har ett Tids-(Utvecklings)f�rspr�ng </li>
<li> 33   Svart har ett Tids-(Utvecklings)f�rspr�ng </li>
<li> 34   Vit har ett avg�rande Tids-(Utvecklings)f�rspr�ng </li>
<li> 35   Svart har ett avg�rande Tids-(Utvecklings)f�rspr�ng </li>
<li> 36   Vit har initiativet </li>
<li> 37   Svart har initiativet </li>
<li> 38   Vit har ett uth�lligt initiativ </li>
<li> 39   Svart har ett uth�lligt initiativ </li>
<li> 40   Vit har ett angrepp </li>
<li> 41   Svart har ett angrepp </li>
<li> 42   Vit har ingen tillr�cklig kompensation f�r materialet </li>
<li> 43   Svart har ingen tillr�cklig kompensation f�r materialet </li>
<li> 44   Vit har tillr�cklig kompensation f�r materialet </li>
<li> 45   Svart har tillr�cklig kompensation f�r materialet </li>
<li> 46   Vit har mer �n tillr�cklig kompensation f�r materialet </li>
<li> 47   Svart har mer �n tillr�cklig kompensation f�r materialet </li>
<li> 48   Vit har en l�tt �vervikt i centrum </li>
<li> 49   Svart har en l�tt �vervikt i centrum </li>
<li> 50   Vit har en �vervikt i centrum </li>
<li> 51   Svart har en �vervikt i centrum </li>
<li> 52   Vit har en avg�rande �vervikt i centrum </li>
<li> 53   Svart har en avg�rande �vervikt i centrum </li>
<li> 54   Vit har en l�tt �vervikt p� kungsflygeln </li>
<li> 55   Svart har en l�tt �vervikt p� kungsflygeln </li>
<li> 56   Vit har en �vervikt p� kungsflygeln </li>
<li> 57   Svart har en �vervikt p� kungsflygeln </li>
<li> 58   Vit har en avg�rande �vervikt p� kungsflygeln </li>
<li> 59   Svart har en avg�rande �vervikt p� kungsflygeln </li>
<li> 60   Vit har en l�tt �vervikt p� damflygeln </li>
<li> 61   Svart har en l�tt �vervikt p� damflygeln </li>
<li> 62   Vit har en �vervikt p� damflygeln </li>
<li> 63   Svart har en �vervikt p� damflygeln </li>
<li> 64   Vit har en avg�rande �vervikt p� damflygeln </li>
<li> 65   Svart har en avg�rande �vervikt p� damflygeln </li>
<li> 66   Vit har en svag st�llning </li>
<li> 67   Svart har en svag st�llning </li>
<li> 68   Vit har en bra s�krad st�llning </li>
<li> 69   Svart har en bra s�krad st�llning </li>
<li> 70   Vit har en d�ligt s�krad kung </li>
<li> 71   Svart har en d�ligt s�krad kung </li>
<li> 72   Vit har en bra s�krad kung </li>
<li> 73   Svart har en bra s�krad kung </li>
<li> 74   Den vita kungen st�r d�ligt </li>
<li> 75   Den svarta kungen st�r d�ligt </li>
<li> 76   Den vita kungen st�r bra </li>
<li> 77   Den svarta kungen st�r bra </li>
<li> 78   Vit har en mycket svag bondestruktur </li>
<li> 79   Svart har en mycket svag bondestruktur </li>
<li> 80   Vit har en svag bondestruktur </li>
<li> 81   Svart har en svag bondestruktur </li>
<li> 82   Vit har en stark bondestruktur </li>
<li> 83   Svart har en stark bondestruktur </li>
<li> 84   Vit har en mycket stark bondestruktur </li>
<li> 85   Svart har en mycket stark bondestruktur </li>
<li> 86   Den vita springaren st�r d�ligt </li>
<li> 87   Den svarta springaren st�r d�ligt </li>
<li> 88   Den vita springaren st�r bra </li>
<li> 89   Den svarta springaren st�r bra </li>
<li> 90   Den vita l�paren st�r d�ligt </li>
<li> 91   Den svarta l�paren st�r d�ligt </li>
<li> 92   Den vita l�paren st�r bra </li>
<li> 93   Den svarta l�paren st�r bra </li>
<li> 94   Det vita tornet st�r d�ligt </li>
<li> 95   Det svarta tornet st�r d�ligt </li>
<li> 96   Det vita tornet st�r bra </li>
<li> 97   Det svarta tornet st�r bra </li>
<li> 98   Den vita damen st�r d�ligt </li>
<li> 99   Den svarta damen st�r d�ligt </li>
<li>100   Den vita damen st�r bra </li>
<li>101   Den svarta damen st�r bra </li>
<li>102   De vita pj�serna �r d�ligt koordinerade </li>
<li>103   De svarta pj�serna �r d�ligt koordinerade </li>
<li>104   De vita pj�serna �r bra koordinerade </li>
<li>105   De svarta pj�serna �r bra koordinerade </li>
<li>106   Vit har behandlat �ppningen mycket d�ligt  </li>
<li>107   Svart har nehandlat �ppningen mycket d�ligt </li>
<li>108   Vit har behandlat �ppningen d�ligt </li>
<li>109   Svart har behandlat �ppningen d�ligt </li>
<li>110   Vit har behandlat �ppningen bra  </li>
<li>111   Svart har behandlat �ppningen bra  </li>
<li>112   Vit har behandlat �ppningen mycket bra  </li>
<li>113   Svart har behandlat �ppningen mycket bra  </li>
<li>114   Vit har behandlat mittspelet mycket d�ligt </li>
<li>115   Svart har behandlat mittspelet mycket d�ligt  </li>
<li>116   Vit har behandlat mittspelet d�ligt  </li>
<li>117   Svart har behandlat mittspelet d�ligt </li>
<li>118   Vit har behandlat mittspelet bra  </li>
<li>119   Svart har behandlat mittspelet bra  </li>
<li>120   Vit har behandlat mittspelet mycket bra  </li>
<li>121   Svart har behandlat mittspelet mycket bra  </li>
<li>122   Vit har behandlat slutspelet mycket d�ligt  </li>
<li>123   Svart har behandlat slutspelet mycket d�ligt  </li>
<li>124   Vit har behandlat slutspelet d�ligt  </li>
<li>125   Svart har behandlat slutspelet d�ligt  </li>
<li>126   Vit har behandlat slutspelet bra  </li>
<li>127   Svart har behandlat slutspelet bra  </li>
<li>128   Vit har behandlat slutspelet mycket bra  </li>
<li>129   Svart har behandlat slutspelet mycket bra  </li>
<li>130   Vit har lite motspel </li>
<li>131   Svart har lite motspel </li>
<li>132   Vit har motspel </li>
<li>133   Svart har motspel </li>
<li>134   Vit har avg�rande motspel </li>
<li>135   Svart har avg�rande motspel </li>
<li>136   Vit �r i l�tt tidsn�d </li>
<li>137   Svart �r i l�tt tidsn�d </li>
<li>138   Vit �r i allvarlig tidsn�d </li>
<li>139   Svart �r i allvarlig tidsn�d </li>
</ul>
</cyan>

<p>
Fler f�reslagna Nag-v�rden f�r Schachinformator-symboler �r bland annat:
</p>
<cyan>
<ul>
<li>140   Med iden ... </li>
<li>141   Riktat mot ... </li>
<li>142   B�ttre �r </li>
<li>143   S�mre �r </li>
<li>144   Likv�rdigt �r </li>
<li>145   Redakt�rens anm�rkning ("RR") </li>
<li>146   Nyhet ("N") </li>
<li>147   Svag punkt </li>
<li>148   Slutspelet </li>
<li>149   Linje </li>
<li>150   Diagonal </li>
<li>151   Vit har l�parparet </li>
<li>152   Svart har l�parparet </li>
<li>153   Olikf�rgade l�pare </li>
<li>154   Likf�rgade l�pare </li>
</ul>
</cyan>

<p>
Andra f�rslag �r:
</p>
<cyan>
<ul>
<li>190   Etc. </li>
<li>191   Dubbelb�nder </li>
<li>192   Isolerade b�nder </li>
<li>193   F�renade b�nder </li>
<li>194   H�ngande b�nder </li>
<li>195   Bak�tv�nd bonde </li>
</ul>
</cyan>

<p>
Av Scid definierade symboler f�r internt bruk:
</p>
<cyan>
<ul>
<li>201   Diagram ("D", ibland ocks� "#") </li>
</ul>
</cyan>

<p><footer>(Uppdaterat: Scid 2.5, Juni 2001)</footer></p>
}


######################
### File formats help:

set helpTitle(W,Formats) "Filformat"
set helpText(W,Formats) {<h1>Scids Filformat</h1>
<p>
Scid-Databaser best�r av tre viktiga filer: en
Indexfil, en Namnfil och en Partidatafil. 
Alla filer har en trebokstavs�ndelse, 
som b�rjar med "s": 
<b>".si3"</b> f�r Indexfiler,
<b>".sn3"</b> f�r Namnfiler och 
<b>".sg3"</b> f�r Partidatafiler.
</p>

<h3>Indexfilen (.si3)</h3>
<p>
Denna fil inneh�ller en beskrivning av databasen d�r det finns en 
liten notering med fast l�ngd f�r varje parti. Den aktuella storleken 
�r 41 bytes per parti. Av dessa �r 28 bytes v�sentlig information 
som Resultat, Datum, Index f�r Spelar-, Turnerings- och
Ortsnamn (de aktuella namnen finns i  namnfilen) .
</p>
<p>
De resterande 13 bytes inneh�ller reduktant, men nyttig
information om partiet, som anv�nds f�r  Positions-,
Material- och M�nsters�kningar. 
Se avsnittet <a Formats Fast>S�ka snabbt</a> f�r mer
information.
</p>

<h3>Namnfilen (.sn3)</h3>
<p>
Denna fil inneh�ller alla Spelar-, Turnerings-, Orts- och Rundenamn, som
anv�nds i databasen. Varje Namn �r bara sparat en g�ng,
�ven om det f�rekommer i m�nga partier. Namnfilen �r vanligtvis
den minsta av de tre viktiga databasfilerna.
</p>

<h3>Partidatafilen (.sg3)</h3>
<p>
Denna fil inneh�ller de aktuella dragen, varianter och kommentarer f�r varje
parti. Dragkodningen �r mycket kompakt: de flesta dragen beh�ver bara en 
byte.
</p>
<p>
N�r ett parti blir ersatt, blir dess nya version sparat i <i>slutet</i>
av filen, s� att det inte �ver tiden ansamlar sig icke anv�nt sparutrymme. 
Du kan genom <a Compact>Komprimering</a>
�terst�lla den minimala storleken p� en databas.
</p>

<h3>Andra Scid-Filer</h3>
<p>
En <a EPD>EPD</a>-fil (Fil�ndelse: ".epd") inneh�ller en rad 
schackpositioner, varje med en textkommentar.
EDP-filformatet beskrivs i <a Author Related>PGN-Standard</a>.
</p>
<p>
En E-Mail-fil (Fil�ndelse: <b>".sem"</b>) sparas i en databas
av motst�ndaren, som ni skickar E-Mail till.
</p>
<p>
En S�kalternativfil (Fil�ndelse: <b>".sso"</b>) inneh�ller inst�llningar f�r
en <a Searches Header>Partidata</a>- eller
<a Searches Material>Material/M�nster</a>-s�kning.
</p>

<h3><name Fast>S�ka snabbt i Scid</name></h3>
<p>
Som ovan n�mns, inneh�ller Indexfilen n�gra reduktanta, men
nyttiga informationer om varje parti, som anv�nds av Positions- eller
Materials�kning.
</p>
<p>
Till exempel sparas materialet i slutst�llningen. Om du
vill s�ka efter Torn- och Bondeslutspel, blir alla partier, som har en
Dam, en L�pare eller en Springare p� br�det i slutst�llningen,
snabbt genoms�kta.
</p>
<p>
En annan nyttig delinformation som sparas �r ordningsf�ljden,
f�r B�nderna att l�mna sin utg�ngsst�llning (genom drag eller
genom att de blir tagna). Detta blir anv�nt f�r s�kningar av bondedrag 
eller exakta s�kningar, i synnerhet efter �ppningspositioner. Till exempel
blir vid s�kningen av utg�ngsst�llningen f�r den franska �ppningen
(1.e4 e6) varje Parti, som b�rjar med 1.e4 c5 eller 1.d4 etc.
genoms�kt, Partier, som b�rjar med 1.e4 e5 , m�ste �ven alltid
genoms�kas.
</p>

<p><footer>(Uppdaterat: Scid 2.5, Juni 2001)</footer></p>
}



################
### Contact info

set helpTitle(W,Author) "Kontaktinformation"
set helpText(W,Author) {<h1>Kontaktinformation</h1>
<p>
Scids webbsajt finns p�: <br>
<b><url http://scid.sourceforge.net/>http://scid.sourceforge.net/</url></b>
</p>
<p>
D�r kan du h�mta den senaste versionen av Scid och de andra filerna till Scid, som du kan ha behov av.
</p>
<p>Den svenska �vers�ttningen av Scid har gjorts av Martin Skj�ldebrand. Synpunkter p� �vers�ttningen ska <b>inte</b>
skickas till Shane. D�remot f�r du g�rna skicka kommentarer, fr�gor och f�rslag till r�ttningar till �vers�ttaren p� adressen:<br>
<b>martin@skjoldebrand.org</b>
</p>
<h3><name Related>L�nkar</name></h3>
<p>
Om Ni har gl�dje av Scid kan de f�ljande
Internetsidorna vara interessanta:
</p>
<ul>
<li><url http://www.tim-mann.org/chess.html>http://www.tim_mann.org/chess.html</url> --
Hemsida f�r Tim Mann's <b>xboard & winboard</b> program: grafiska
gr�nssnitt f�r schackprogram och anslutning till Internet Chess
Server. Den har ocks� bra information om Crafty, GNUchess och
andra schackprogram.</li>

<li><url ftp://ftp.cis.uab.edu/pub/hyatt/>ftp://ftp.cis.uab.edu/pub/hyatt/</url> --
Det starka schackprogrammet Crafty.  <b>TB</b> -
underkatalogerna  inneh�ller n�stan alla Nalimov-slutspelstabeller, som
anv�nds av n�gra schackprogram och �ven anv�nds av Scid.</li>

<li><url http://www.chesscenter.com/twic/twic.html>http://www.chesscenter.com/twic/twic.html</url> --
TWIC (the week in chess), �r ett framst�ende veckomagazin f�r
internationella schackpartier, tillg�ngliga i PGN-format. </li>

<li><url http://scid.sourceforge.net/doc/standard.txt>http://scid.sourceforge.net/doc/standard.txt</url> --
 <b>PGN-Standard</b>, skapad av Steven J. Edwards 1994.
Textfilen f�rklarar PGN- och EPD-Formaten i detalj.</li>
</ul>

<p><footer>(Uppdaterat: Scid 2.5, Juni 2001)</footer></p>
}

# Book window help
set helpTitle(W,Book) "Bokf�nstret"
set helpText(W,Book) {<h1>Bokf�nstret</h1>
  <p>
  Bokf�nstret visar en lista p� alla bokfiler som finns i Scids bokkatalog. Formatet p� b�ckerna �r
  det som anv�nds av Polyglot och schackmotorer som Fruit och Toga.
  </p>
  <p>
  F�r varje position, visar bokf�nstret alla m�jliga drag det inneh�ller och deras
  relativa vikter i procent. N�r ett drag g�rs, uppdateras bokf�nstret.
  Om det klickas p� ett drag i bokf�nstret g�rs detta drag i den aktuella positionen.
  </p>
  <p>
  Den aktuella boken som anv�nds kan snabbt �ndras genom att v�lja en annan bok i den �vre listan.
  </p>
  <p><footer>(Uppdaterat: Scid 3.6.5, Februari 2007)</footer></p>
}

# Tactical game window help
set helpTitle(W,TacticalGame) "Taktiskt parti-f�nstret"
set helpText(W,TacticalGame) {<h1>Taktiskt parti-f�nstret</h1>
  <p>
  Spela ett taktiskt parti mot en schackmotor som simulerar en motst�ndare med en angiven ELO-rating.
  Motst�ndaren spelas av Phalanx och tr�naren spelas av Crafty. De r�tta schackmotorerna v�ljs automatiskt
  genom sina namn, och b�r vara korrekt konfigurerade (detta �r standard n�r Scid installeras).
  </p>
  <p>
  De f�ljande parametrarna m�ste konfigureras :
  <ul>
  <li>sv�righet : ELO-rating p� motst�ndare</li>
  <li>specifik �ppning : motst�ndaren spelar en specifik �ppning (anv�ndbart f�r �ppningstr�ning)</li>
  <li>spelarens fel kontrolleras av en schackmotor som agerar som en tr�nare. Tiden som anv�nds f�r att bed�ma om ett
  drag �r bra eller inte kan begr�nsas</li>
  </ul>
  <p>N�r du �r klar klicka bara p� spela</p> 
  <p><footer>(Uppdaterat: Scid 3.6.5, Mars 2007)</footer></p>
}

# Opening Trainer window help
set helpTitle(W,OpeningTrainer) "�ppningstr�nare"
set helpText(W,OpeningTrainer) {<h1>�ppningstr�nare</h1>
  <p>
  En Sciddatabas kan anv�ndas som en repetoar, d�r varje parti representerar en �ppningsvariant.
  </p>
  
  <h3>�ppningstr�narstatistik</h3>
  <p>
  Fyra tal visas f�r att visa statistik f�r den aktuella positionen :
  <ul>
  <li>Gr�n : antalet drag som spelades av anv�ndaren som �r bra drag</li>
  <li>Gul : antalet tveksamma drag som spelades som �r repertoaren</li>
  <li>R�d : antalet drag som spelades som inte finns i repertoaren</li>
  <li>Vit : antalet g�nger positionen p�tr�ffades</li>
  </ul>
  </p>
  
  <h3>Rapporten</h3>
  <p>
  Rapporten visar statistik f�r hela repertoaren och ger information om anv�ndarens kunskaper :
  <ul>
  <li>Positioner i repertoaren : det totala antalet positioner i repertoaren (alla varianter i databasen)</li>
  <li>Positioner som inte spelats : de positioner som alldrig har p�tr�ffats</li>
  <li>Positioner spelade : de positioner som spelades och summan av antalet g�nger de har p�tr�ffats. Notera att
  detta antal representerar antalet f�rekomster av en position i alla �ppningsvarianter : detta antal kan snabbt bli stort
  f�r positioner som �r n�ra till startpositionen</li>
  <li>Bra drag : antalet bra drag gjorda av anv�ndaren</li>
  <li>Tveksamma drag : antalet svaga drag gjorda av anv�ndaren</li>
  <li>Utanf�r repertoaren : antalet drag som anv�ndaren har gjort som inte finns i repertoaren</li>
  </ul>
  </p> 
  <p><footer>(Uppdaterat: Scid 3.6.11, April 2007)</footer></p>
}

####################
### Correspondence Chess help:
set helpTitle(W,Correspondence) "Korrespondensschack"
set helpText(W,Correspondence) {<h1>Korrespondensschack</h1>

<p>
Scid erbjuder nu tv� huvudfunktioner f�r korrespondens-
schack.
</p>
<ul>
   <li><b>eMail-schack</b> g�r detta genom att skicka det aktuella partiet via eMail
   till din motst�ndare n�r du har gjort ditt drag. F�r detta skapas ett eMail-
   meddelande i ditt f�redragna email-program med det aktuella partiet
   bifogat till det i PGN-format. Givetvis tas alla kommentarer och
   variationer bort f�rst.
   </li>
   <li><b>Korrespondensschackservrar</b> st�ds med hj�lp av
   Xfcc-protokollet. H�r anv�nds externa verktyg f�r att h�mta partierna fr�n
   ditt/dina konto/konton och levererar dem till Scid f�r synkronisering. Efter
   du har gjort ditt drag skickas detta till din motst�ndare genom
   Xfcc. H�mtnings- och s�ndningsverktygen �r implementerade som externa verktyg f�r
   enkel ut�kning om andra protokoll kommer.
   </li>
</ul>

<p>
F�r att anv�nda korrespondensschackfuntioner m�ste en databas av typ
"Korrespondensschack" �ppnas innan n�gra
korrespondensschackfunktioner anv�nds. OM du inte har en s�dan databas
�n, skapa bara en ny databas och ange dess typ till "Korrespondensschack"
med funktionen <a Maintenance>Underh�ll</a>.
Det �r viktigt att ange typen s� att Scid kommer att k�nna igen databasen f�r
synkronisering genom denna typ. D� denna databas �r tom efter
skapandet kommer Scid att behandla alla korrespondensschackpartier det f�r vid
den f�rsta synkroniseringen som nya partier och l�gga till dem till denna databas.
</p>

<p>
Om ingen databas av typ "Korrespondensschack" �r nu �ppnad
kommer Scid att p�minna dig om att g�ra s�. Men, �ppna inte mer �n en
databas av denna typ d� Scid inte d� kan avg�ra vilken som ska anv�ndas.
</p>

<h3>Grundfunktionalitet</h3>

<p>
Om allting �r korrekt konfigurerat kan anv�ndningen av korrespondens-
schackfunktionerna l�tt n�s med f�ljande knappar:
<ul>
   <li><button tb_CC_Retrieve> H�mtar korrespondensschackpartier.
   F�r detta startas ett externt h�mtningsverktyg och alla partier h�mtas
   s� likv�l som andra partier som lagras i Scids Inkorg
   (se nedan) �r synkroniserade till den aktuella korrespondensschack-
   databasen.
   </li>
   <li><button tb_CC_Send> Skickar ditt drag till motst�ndaren genom att antingen
   skapa ett nytt eMail-meddelande i dett f�redragna email-program eller genom att
   skicka ett drag till en schackserver om Xfcc anv�nds.
   </li>
</ul>
</p>

<h3>Konfiguration</h3>

<p>
Korrespondensschack inom Scid �r baserat p� en normal Scid-
databas som har partierna och n�gra externa verktyg till Scid som
hanterar de "icke-schack-delarna". Dessa verktyg och deras parametrar m�ste st�llas
in en g�ng, och lagras sedan f�r framtida anv�ndning.
</p>

<p>
F�r att n� konfigurationsdialogen v�lj <menu>Spela</menu>
<menu>Korrespondensschack</menu><menu>Konfigurera</menu> fr�n
menyn. Detaljerna beskrivs i <a CCSetupDialog>Korrespondensschack-
inst�llningar</a>. N�r denna dialog avslutas med <b>[Ok]</b> knappen kommer
dina inst�llningar automatiskt att lagras.
</p>

<h3>H�mta partierna</h3>
<p>
Beroende p� om du spelar korrespondensschack via eMail eller via en
schackserver skiljer sig den aktuella h�mtningsprocessen lite. Generellt
resulterar den i ett antal partier i PGN-format placerade i Scids Inkorgs-
katalog. Detta erbjuder ocks� m�jligheten till automatisk h�mtning via
extern programvara.
</p>
<p>
N�r partierna finns i Scids Inkorg kommer <menu>Behandla Inkorg</menu>
fr�n menyn att bearbeta Inkorgen och l�gga till nya drag till
de partier som redan finns i databasen. Dessutom kommer den att l�gga till de partier
som inte hittas i den aktuella korrespondensschackdatabasen som nya partier.
</p>

<p><a CCeMailChess>Korrespondensschack via eMail</a> beskriver
detaljerna f�r anv�ndning av eMail, medan <a CCXfcc>Korrespondens-
schack via schackserverar</a> beskriver motsvarande f�r korrespondens-
schackservrar.
</p>

<h3>Stega igenom partier</h3>
<p>
Efter att partierna �r h�mtade laddas de i Scids klippboardsdatabas
och nya drag l�ggs till och lagras i den �ppnade korrespondensschack-
databasen. Skillnades i
funktionen fr�n menyn <menu>Partier</menu> �r, att dessa tv�
knappar scrollar bara mellan partierna i Scids Inkorg som �r
t�nkt att vara dina aktuella p�g�ende partier. Givetvis kan
Korrespondensschackdatabasen inneh�lla m�nga fler partier, men
normalt vill du inte g� igenom  dessa f�r att se vad din
motst�ndare har gjort f�r drag i ett aktuellt parti.
</p>
<p>
Notera att en taggs�kning kr�vs med n�gra f�lt som
inte �r indexerade av Scid. D�rf�r �r det , inte att rekommendera
att lagra partier i en stor referensdatabas d�
s�ktiderna kan bli ganska l�nga. Om du spelar mycket och din egen
databas blir ganska stor, kan s�ktiden reduceras genom att flytta
avslutade partier till en arkivdatabas, eller genom att bara skapa en ny
databas f�r de p�g�ende partierna. Scid kommer att behandla alla partier som inte finns
redan i korrespondensschackdatabasen som nya partier och l�gga till dem
automatiskt. D�rf�r, �r det tillr�ckligt att �ppna en tom databas av
typ "Korrespondensschack" och anv�nda <menu>Behandla Inkorg</menu> f�r att
importera alla nu p�g�ende partier.
</p>
<p>
Motsvarande till de tv� n�mnda knapparna �r <menu>Tidigare
Parti</menu> och <menu>N�sta Parti</menu> fr�n <menu>Korrepondens-
schack</menu> menyn.
</p>
<p>
Notera att om du anger dina spelarnamn korrekt (i menyn
<menu>Mina Spelarnamn</menu>) kommer Scid att rotera br�det f�r dig att
alltid spela upp�t. Du kan ha flera spelarnamn. Se ocks� <a
Options MyPlayerNames>Mina Spelarnamn</a> f�r detaljer.
</p>

<h3>Analysera och g�r ett drag</h3>
<p>
Alla analysfunktioner kan anv�ndas f�r korrespondensschackpartier.
Variationer, kommentarer etc. kan l�ggas till precis som i en normal partianalys.
N�r det �r klart, kommer Scid att ta den senaste halvdraget som lades till
partiet och behandla det som det aktuella draget att skicka. Ingen kontroll g�rs
h�r av om bara ett halvdrag lades till eller vilken sida som �r vid draget,
d�rf�r, m�ste bara ett halvdrag i huvudvarianten l�ggas till!  Om en
schackserver anv�nds skickar Scid ocks� den senaste kommentaren som lades till
servern vilket kan vara anv�ndbart f�r kommunikationen med motst�ndaren. I
eMail-schack kan detta g�ras med det normala email-meddelandet, s� d�r tas alla
kommmentarer bort.
</p>
<p>
Genom att trycka p� S�ndknappen <button tb_CC_Send> kommer Scid att m�sta
best�mma den typ av korrespondensschackparti som visas (eMail eller
ett serverparti) och starta antingen ditt eMail-program eller det externa skicka-
verktyget f�r att skicka ditt drag. Att anv�nda <menu>Skicka drag</menu> �r motsvarande
till denna knapp. Alternativt, kan <menu>eMail drag</menu> anv�ndas f�r att
skicka det aktuella draget via eMail. Om det �r ett eMail-parti �r denna
funktion motsvarande till <menu>Skicka drag</menu>. Om det �r ett server-
baserat parti genereras ett eMail-meddelande. Notera dock, att detta kommer
inte n�dv�ndigtvis att inneh�lla en riktig mottagare d� eMail-addresser inte byts ut
i serverbaserad korrespondensschack.
</p>

<p><footer>(Uppdaterat: Scid 3.6.23, Februari 2008)</footer></p>
}


set helpTitle(W,CCXfcc) "Korrespondensschackservrar"
set helpText(W,CCXfcc) {<h1>Korrespondensschackservrar</h1>

<p>
Det finns flera korrespondensschackserverar p�
Internet. Generellt, �r de anv�nda med en webbl�sare, s� ingen
specifik programvara kr�vs. Men m�nga av dem erbjuder ocks� ett
gr�nssnitt till specialiserad schackprogramvara via ett protokoll kallat Xfcc.
Integrationen av Xfcc g�rs i Scid via externa hj�lpverktyg angivna
i <a CCSetupDialog>Konfiguration</a>-dialogen f�r korrespondens-
schack.
</p>

<h3>Starta ett nytt parti</h3>
<p>
Xfcc till�ter inte sj�lv att ett nytt parti startas. Att s�ka efter en
motst�ndare och starta ett parti �r ist�llet hanterat av schackservern
p� dess hemsida. N�r partiet �r startat kan dock, Scid anv�ndas f�r att h�mta
motst�ndarens drag, l�gga till dem till den interna databasen,
analysera osv. Alla funktioner i Scid �r till anv�ndarnas f�rfogande
men speciella moder av spel kanske inte till�ter dem (t.ex.  normala partier
till�ter vanligtvis inte anv�ndande av schackmotorer f�r analys).
</p>

<h3>H�mta partier</h3>
<p>
�ppna en databas som ineh�ller korrespondensschackpartier. Denna databas
m�ste vara av typ "Korrespondensschack". 
</p>

Notera: 
<ul>
   <li>Om Scid inte hittar en korrespondensschackdatabas kommer den att
   informera dig att �ppna en.
   </li>
   <li>Om databasen inte har partierna som �r h�mtade fr�n
   servern behandlas de som nya partier och l�ggs till databasen
   automatiskt.
   </li>
   <li>Scid kommer att anv�nda den f�rsta databasen av typ "Korrespondensschack"
   som �r �ppnad. Av denna anledning b�r bara en s�dan databas i taget
   vara �ppnad.
   </li>
</ul>
<p>
Xfcc h�mtar alltid omedelbart alla partier som finns p� en specificerad server f�r ditt
anv�ndarnamn. F�r att h�mta partierna klicka bara p� <button tb_CC_Retrieve>
ikonen eller v�lj <menu>H�mta Partier</menu> fr�n
<menu>Korrespondensschack</menu>-menyn. D� en serveranslutning
kr�vs f�r att h�mta nya partier var s�ker p� att systemet har tillg�ng till n�tverket.
Scid kommer att starta h�mtningsverktyget som �r konfigurerat i 
<a CCSetupDialog>Konfiguration</a>-dialogen vilket kommer att placera
partierna i PGN-format i Scids inkorg. Det kan ta lite tid att h�mta
svaret, s� vat t�lmodig. Efter att partierna �r h�mtade uppdateras
korrespondensschackdatabasen med dem.
</p>
<p>
N�r partierna �r h�mtade s�ks deras motst�ndare i
korrespondensschackdatabasen och nya drag l�ggs till d�r. D� Xfcc
servrar kan erbjuda olika s�tt att infoga drag (via Internet eller mobil eller
andra program...) kan det vara s� att Scid m�ste l�gga till h�lften av
partiet till databasen. Detta inneb�r inget problem. Scid kommer att l�gga till alla drag
som fanns i partiet fr�n servern. Scid kommer dock inte att ers�tta
partiet fr�n b�rjan d� etta kan ta bort all din analys.
D�rf�r �r det <b>viktigt att notera</b> att du inte f�r infoga drag till
huvudvarianten bortom ditt sista drag! F�r att l�gga till forts�ttningar var god
och anv�nd variationer!
</p>
<p>
Notera att om andra k�llor har placerat partier i din inkorg (t.ex. fr�n
din eMail-korrespondensschack) synkroniseras de ocks� i
h�mtningen till databasen d� hela Inkorgen ocks� bearbetas.
Detta till�ter att eMail-partier l�ggs till i Inkorgen, sedan kan du v�xla till Scid,
klicka p� <button tb_CC_Retrieve> och alla partier �r uppdaterade.Partier som inte
�nnu finns i datasen behandlas som nya partier och l�ggs till
databasen.
</p>
<p>
<b>Notering f�r programmerare</b>: h�mtningsverktyget startas med Inkorgss�kv�gen som
parameter. Det �r t�nkt atrt fungera genom alla serverkonton och placera
korrekt formatterade PGN-filer i den s�kv�g som anges till den. Dessa filer
b�r inneh�lla ytteliggare f�lt som �r k�nda av cmail-verktyget.
 (Se <a CCeMailChess>Korrespondensschack via eMail</a> f�r
information om de kr�vda f�lten.)
</p>

<p><footer>(Uppdaterat: Scid 3.6.23, Februari 2008)</footer></p>
}

#############
# eMail Chess:
set helpTitle(W,CCeMailChess) "Korrespondensschack via eMail"
set helpText(W,CCeMailChess) {<h1>Korrespondensschack via eMail</h1>

<p>
eMail erbjuder ett v�ldigt bekv�mt s�tt att spela korrespondensschack.
Standardapplikationen f�r detta i Un*x-v�rden �r till idag xboard
tillsammans med dess cmail-hj�lpare. D� den till�ter n�stan automatisk
hantering av korrespondensschack-eMail och d�rut�ver inte l�gger till n�gonting
som inte �r PGN �r det ocks� modellen f�r Scid att hantera
eMail-schack. Genom att bara bevara hela PGN-huvudet kan s�dana partier
spelas med en motst�ndare som har ett verktyg f�r att hantera PGN.
</p>

<h3>eMail-schack</h3>
<p>
Scid kan hantera eMail-korrespondensschackpartier n�stan automatiskt.
Det s�tt p� hur detta g�rs h�lls kompatibelt med cmail-verktyget som
kommer med xboard p� Un*x system. (Att ha sagt detta antyder att du
kan spela mot en motst�ndare med cmail/xboard.) Det fungerar genom att skicka
partierna som hela PGN-filer till och fr�n som email-bilagor, medan
huvudet inneh�ller vissa huvudf�lt som l�ter dem k�nnas igen och
sorteras tillsammans. Av denna anledning m�ste anv�ndaren vara noggrann med
att �ndra i huvudf�lten.  Notera att f�lten med explicita v�rden m�ste
anges till exakt detta v�rde f�r eMail-schack. Att starta ett parti med
Scid g�r det automatiskt, men du <b>f�r inte</b> skriva �ver
eller ta bort dem!
</p>
<p>
N�dv�ndiga huvudf�lt �r:
</p>
<ul>
   <li><term>Event</term>: m�ste vara "Email correspondence game"
   </li>
   <li><term>Site</term>: m�ste vara "NET"
   </li>
   <li><term>Mode</term>: m�ste vara "EM"
   </li>
   <li><term>WhiteNA</term>: inneh�ller eMail-addressen f�r den vita spelaren. Notera
   att adressen bara lagras d�r i formen
   <term>user@host.org</term>.
   </li>
   <li><term>BlackNA</term>: inneh�ller eMail-addressen f�r den svarta spelaren
   liknande WhiteNA.
   </li>
   <li><term>CmailGameName</term>: Inneh�ller en <b>unik</b> identifierare f�r
   partiet. Detta anv�nds f�r att sortera partierna.
   <p>
   Medan Scid kan anv�nda n�got databasindex �r detta inte m�jligt f�r
   icke-DB-baserade verktyg som cmail. Av denna anledning �r
   <term>CmailGameName</term> parametern anv�ndarinmatad. Den m�ste vara
   unik! Det enklaste �r n�gonting avformen
   <term>xx-yy-yyyymmdd</term> d�r xx �r en beteckning p� den vita
   spelaren, yy en beteckning f�r den svarta spelaren, och yyyymmdd �r det aktuella datumet.
   </p>
   <p>F�r Xfcc-baserade partier m�ste detta f�lt anges till en unik
   identifierare men d�r kan servernamnet och det unika partinumret p�
   denna server anv�ndas, dvs denna identifierare �r av formen
   <term>MyXfccServer-12345</term>.
   </p>
   </li>
</ul>

<h3>Starta ett nytt parti</h3>
<p>
Detta �pppnar en dialog f�r inmatning av ditt eget och motst�ndarens namn som
de b�r vara i huvudet likv�l som eMail-addresserna f�r
b�da spelarna. Bessutom m�ste ett <b>unikt</b> game ID infogas.
Det enklaste s�ttet f�r detta Game ID �r n�gonting av formen
<term>xx-yy-yyyymmdd</term> d�r xx �r en f�rkortning f�r den vita
spelaren, yy f�r den svarta spelaren, och yyyymmdd �r det aktuella datumet.
Denna Game id �r en text och det �r viktigt f�r att identifiera partierna unikt.
Anv�ndare av cmail kommer ocks� att k�nna denna Game ID som <i>partinamn</i>. Det f�r
brar inneh�lla bokst�veroch sifror, minustecknet och understrykning.
Var god och undvik andra tecken.
</p>
<p>
Efter att dialogen �r avslutad genom att trycka p� <b>[Ok]</b> knappen l�ggs ett
nytt parti till den aktuella �ppnade korrespondensschackdatabasen
och PGN-huvudet fylls i ordentligt. G�r bara ditt drag och skicka det som
det beskrivs nedan.
</p>

<h3>H�mta partier</h3>

<p>
Scid hanterar inte din emailkorg automatiskt. Detta skulle,
med tanke p� den stora variationen p� m�jliga email-program idag, involvera
en stor m�ngd programkod. Av denna anledning anv�nder Scid ditt normala
eMail-program som �r mycket mer l�mpligt f�r detta syfte �n Scid
kan n�gonsin bli. F�r att h�mta ett parti till Scid spara bara den bifogade PGN-filen
i Scids inkorg och bearbeta inkorgen genom antingen <menu>H�mta
Partier</menu> eller  <button tb_CC_Retrieve> knappen eller
<menu>Bearbeta Inkorgen</menu>. Skillnaden mellan de tv� �r att
den f�rsta ocks� startar det externa h�mtningsverktyget och fyller
Inkorgen ytterliggare med partier fr�n andra k�llor (som Xfcc). D�rf�r �r
<button tb_CC_Retrieve> det mest bekv�ma s�ttet om du anv�nder b�da
typerna av korrespondensschackpartier.
</p>
<p>
<b>Notera</b> att <menu>H�mta Partier</menu> menyn eller  <button
tb_CC_Retrieve> knappen <b>inte</b> h�mtar dina eMail-meddelanden! Du
m�ste spara dina PGN-filer i Scids Inkorg f�r hand. Troligtvis kan detta
bli automatiserat av ditt eMail-program (p� Un*x system �r det enkelt att s�tta upp en
mime-hanterare genom <term>.mailcap</term>).
</p>

<h3>Skicka svaret</h3>

<p>
Efter att du har gjort ditt drag skicka det antingen med <menu>eMail drag</menu>
funktionen fr�n menyn via <menu>Skicka drag</menu> vilket �r motsvarande till
<button tb_CC_Send>. F�r det senare  m�ste Scid k�nna igen partiet
som eMail-korrespondens och skicka det med email medan den f�reg�ende metoden
kommer att f� Scid att generera ett eMail-meddelande.
</p>
<p>
Givetvis tar Scid bort alla kommentarer och variationer
innan det bifogas i det utg�ende eMailet d� du inte vill skicka med
din analys.
</p>
<p>
Om ett GUI-emailprogram anv�nds, �ppnas dess vanliga skapaf�nster.
Addressen p� din motst�ndare fylls i likv�l som ett generiskt �mne
som inneh�ller game id f�r enkel filtrering och bcc-addresses om den
�r specificerad i <a CCSetupDialog>Konfigurations</a>-dialogen. Email-
texten �r angiven till att inneh�lla FEN p� den sista positionen och listan p�
de tidigare gjorda dragen. P� detta s�tt kan motst�ndaren snabbt se ditt
drag. SlutligenFinally, bifogar Scid det aktuelkla partiet inklusive ditt drag i
PGN-format till email-meddelandet.
</p>
<p>
N�r ett mailx kompatibelt verktyg anv�nds �ppnas inget f�nster och emailet skickas
osynligt geonom att starta verktyget specificerat i bakgrunden. I
detta fall inneh�ller det genererade emailet PGN �ven i email-texten.
</p>
<p>
Notera att d� eMail-schack fungerar genom att skicka hela PGN-filen f�r du inte
l�gga till mer �n ditt drag. Scid kontrolerar inte h�r om
mer �n ett drag lades till huvudvarianten, d� Scid helt enkelt inte
vet vilket drag det �r, d� du skickar ditt drag.
</p>
<p><footer>(Uppdaterat: Scid 3.6.23, Februari 2008)</footer></p>
}

#############
# Correspondence Chess setup dialog help:
set helpTitle(W,CCSetupDialog) "Korrespondensschackinst�llningar"
set helpText(W,CCSetupDialog) {<h1>Korrespondensschackinst�llningar</h1>

<p>
Indata i konfigurationsdialogen finns f�rdefinierat till vissa standard-
parametrar men dessa m�ste inte n�dv�ndigtvis matcha ditt system, s�
anpassning kommer s�kert att vara n�dv�ndigt. Alla parametrar lagras i
konfigurationsfilen automatiskt n�r dialogen �r st�ngd via
<b>[Ok]</b> knappen. Parametrarna g�ller d� omedelbart.
</p>

<p>
<b>Standarddatabas</b>:
Detta definierar standarddatabasen f�r
korrespondensschackpartier. Den kan enkelt n�s via
<menu>�ppna Databas</menu> i  <menu>Korrespondensschack</menu>
menyn. F�rdelen med denna metod �r, att databasen inte
visas i <i>senaste databaser</i> listor och att du kan ha en
specifik fil f�r detta. Denna databas <b>m�ste vara</b> av typ
"Korrespondensschack". Att �ppna en databas av denna typ p� ett annat
s�tt �r ocks� ok, s� troligtvis vill du ignorera denna inst�llning
(t.ex. om du startar Scid med din korrespondensschackdatabas vid
uppstart.)
</p>

<p>
<b>Inkorg (s�kv�g)</b>:
I denna katalog s�ker Scid efter korrespondensschackpartier sparade
i PGN-format. Dessa partier anv�nds f�r synkroniseringen av
korrespondensschackdatabasen. Generellt, bryr sig inte Scid om hur
partierna kommer till denna katalog. Scid kommer bara att arbeta sig igenom alla PGN-filer
som finns d�r. Detta ger m�jlighet att anv�nda n�gra externa verktyg
f�r att h�mta partier till denna plats. D�rut�ver, i eMail-schack b�r man
bara spara PGN-filerna fr�n motst�ndaren i denna
katalog.
</p>
<p>
Scid kommer inte att l�sa en mailkorg, utan hanterar bara
alla PGN-filer som �r placerade i denna katalog. Notera ocks�, att Scid kommer att
synkronisera partie med den aktuella databasen. Men, om ett parti
fr�n denna katalog inte �nnu finns i databasen kommer det att
behandlas som ett nytt parti och l�ggas till databasen.
</p>
<p>
F�r att synkroniseringsprocessen ska fungera m�ste PGN-filerna inneh�lla
n�gon ytterliggare huvudinformation som �r i perfekt enlighet med
PGN-standarden. Var god och konsulera <a
CCeMailChess>)Korrespondensschack via eMail</a> om du vill skapa
ditt eget verktyg eller om du flyttar data fr�n n�got annat system.
</p>

<p>
<b>Utkorg (s�kv�g)</b>:
Motsatsen till <i>Inkorgen</i>. Scid placerar h�r PGN-filer f�r de
utg�nde partierna. F�r eMail-schack �r detta n�dv�ndigt d� PGN-filerna m�ste
bifogas till ett eMail-meddelande.  F�r Xfcc, d�r bara draget skickas
, �r detta inte n�dv�ndigt, men Utkorgskatalogen erbjuder
ett bekv�mt s�tt att koppla upp din PDA eller n�gon annan anv�ndning d�
PGN-filerna i Utkorgen ocks� kommer att inneh�lla ditt senaste drag.
</p>

<p>
<b>H�mtningsverktyg</b>:
Detta program startas f�r att h�mta korrespondensschack-
partier fr�n en korrespondensschackserver. Denna hj�lpare m�ste bara
h�mta partier fr�n den k�lla den tycker om, generera en korrekt PGN-
fil med de n�dv�ndiga PGN-taggarna. Verktyg f�r att h�mta partier
fr�n Xfcc-servrar finns som externa program och dessa �r de naturliga
verktygen att st�lla in h�r. F�r framtida protokoll kan man enkelt generera
ett externt h�mtningsverktyg som hanterar detta protokoll. �ven automatisering
�r m�jlig om denna funktionalitet �r gjord externt.
</p>
<p>
Notera: Detta verktug �r <b>inte</b> startat f�r h�mtning av eMailschack-
meddelanden!
</p>

<p>
<b>Skickaverktyg</b>: 
Detta �r motsatsen till h�mtningsverktygen, prim�rt �ven avsett f�r Xfcc
support eller n�gon annat framtida protokoll som kan dyka upp. Skickaverktyget,
dock, startas fr�n Scid med flera parametrar som ser ut som:
<term>
SendTool Outbox Name GameID MoveCount Move "Comment" resign claimDraw offerDraw acceptDraw
</term>
</p>

<p>
Betydelsen av parametrarna �r som f�ljer:
   <ul>
      <li><term>Outbox</term>: Utkorgss�kv�gen anges i denna dialog. Skicka-
      verktyget ska generera en korrekt formatterad PGN-fil
      d�r.
      </li>
      <li><term>Name</term>: Namnet p� spelaren vid draget som st�r
      i PGN-f�ltet. F�r Xfcc �r detta loginnamnet. Det �r
      identiskt som spelarnamnet i PGN-huvudet.
      </li>
      <li><term>MoveCount</term>: Dragnummer att skicka.
      </li>
      <li><term>Move</term>: Det aktuella draget i SAN.
      </li>
      <li><term>"Comment"</term>: En kommentar skickad till motst�ndaren. Scid
      infogar den sista kommentaren i partiet. Dvs dessa kommentarer �r
      behandlade som kommentarer till motst�ndaren. Notera att kommentaren �r
      citerad, s� flerradiga kommentarer b�r vara m�jligt.
      </li>
      <li><term>resign</term>: 0 eller 1, specificerar om anv�ndaren
      vill ge upp. Ange till 1 om anv�ndaren anv�nder
      <menu>Ge upp</menu> fr�n <menu>Korrespondensschack</menu>
      menyn.
      </li>
      <li><term>claimDraw</term>: 0 eller 1, specificerar om anv�ndaren
      vill ha kr�ver remi. Ange till 1 om anv�ndaren anv�nder
      <menu>Kr�v remi</menu> fr�n <menu>Korrespondensschack</menu>
      menyn.
      </li>
      <li><term>offerDraw</term>: 0 eller 1, specificerar om anv�ndaren
      vill erbjuda remi. Ange till 1 om anv�ndaren anv�nder <menu>Erbjud
      remi</menu> fr�n <menu>Korrespondensschack</menu> menyn.
      </li>
      <li><term>acceptDraw</term>: 0 eller 1, specificerar om anv�ndaren
      vill acceptera en remi som erbjuds av motst�ndaren. Ange till 1 om
      anv�ndaren anv�nder <menu>Acceptera remi</menu> fr�n
      <menu>Korrespondensschack</menu>
      menyn.
      </li>
   </ul>
</p>
<p>
Notera: Denna funktion �r <b>not</b> startat f�r eMail-schack!
</p>

<p>
<b>eMail-program</b>:
Detta anger s�kv�gen till ditt f�redragna eMail-program. Detta program startas
f�r eMail-schack f�r att skriva ett meddelande till motst�ndaren.
</p>

<p>
<b>(B)CC-Address</b>:
En kopia p� det utg�ene meddelandet skickas till denna address som en kopia.
Notera dock, att om ett GUI-emailprogram anv�nds har det normalt sin egen
utg�ende email-hantering. D�rf�r, kan angivande av denna address duplicera
meddelanden. Det kan dock anv�ndas f�r att skicka ett parti till en annan address.
</p>

<p>
<b>Mod</b>:
Olyckligtvis finns det ett stort antal email-klienter och de anv�nder
v�ldigt olika startkonventioner. N�gra vanliga konventioner, och
exempel p� program som anv�nder dem, listas h�r. Emailprogrammet
kommer att startas med den valda konventionen. Om det inte �r k�nt
vilken konvention som anv�nds kan en av alternativen kanske matcha och
fungera. Notera dock att ett stort antal emailprogram �r inte
kapabla att skicka bilagor n�r de startas av ett annat program. I
detta fall m�ste du antingen byta din email-klient eller l�gga till de bilagor
som har placerats i Scids Utkorg manuellt.
</p>
<p>Tips: mailx eller en av dess m�nga kloner b�r vara tillg�ngliga som en
kommandoradsapplikation p� n�stan alla system som ett enkelt att st�lla in
verktyg. Om ingen av dessa konventioner fungerar med din f�redragna
klient eller om denna klient inte kan hantera email med bilagor via startande fr�n
kommandoraden, kan installation av mailx vara ett alternativ.
</p>
<p>Tips: mutt anv�nder systemets emailtransport (dvs
sendmail/exim/postfix). Att st�lla in dem �r (troligtvis) inte enkelt
s� mutt �r ett perfekt alternativ. P� en ordentlig Un*x med riktiga
inst�llningar b�r det vara det mest enkla s�ttet att hantera eMail-schack.
(Men det finns inte m�nga korrekt inst�llda system , speciellt inte i
Linuxv�rlden.)
</p>
<p>
<b>Bilageparameter</b>: 
Denna parameter anv�nds f�r att specificera en bilaga. Detta anv�nds <b>bara</b>
i <term>mailx</term> mod.
</p>
<p>
<b>�mnesparameter</b>:
Denna parameter anv�nds f�r att specificera �mnet f�r email-meddelandet. Det
anv�nds <b>bara</b> i <term>mailx</term> mod.
</p>
<p><footer>(Uppdaterat: Scid 3.6.23, Februari 2008)</footer></p>
}
############################################################
#
# Swedish tip of the day:

set tips(W) {
  {
    Scid har �ver 30 <a Index>Hj�lpsidor</a>, och i de flesta f�nster kan du
    genom att trycka <b>F1</b> f� hj�lp om det f�nster du f�r tillf�llet har
    aktivt.
  }
  {
    Vissa f�nster (t ex Partiinformation och <a Switcher>Databasv�ljaren</a>) 
    har en meny f�r h�ger musknapp. Prova att h�gerklicka i varje f�nster s�
    ser du vilka som har det och vilka funktioner du kommer �t den v�gen.
  }
  {
    Du kan ange drag p� mer �n ett s�tt, s� du kan v�lja vilket som passar dig
    b�st. Du kan anv�nda musen (med eller utan dragf�rslag) eller tangentbordet
    (med eller utan autokomplettering). L�s hj�lpsidan f�r 
    <a Moves>Att ange drag</a> f�r mer information.
  }
  {
    Om du har databaser du ofta �ppnar s� kan du l�gga till ett 
    <a Bookmarks>Bokm�rke</a> f�r varje databas. Du kommer d� att kunna �ppna 
    databaserna snabbare via bokm�rkesmenyn.
  }
  {
    Du kan se alla drag i det aktuella partiet (inklusive varianter och kommentarer)
    genom att �ppna <a PGN>PGN-f�nstret</a>.
    Du navigerar igenom partiet i PGN-f�nstret genom att klicka p� valfritt drag med
    v�nster musknapp. Genom att klicka p� draget med mellan- eller h�germusknapp s�
    f�r du en f�rhandsvisning av just den st�llningen.
  }
  {
    Du kan kopiera partier mellan databaserna i <a Switcher>Databasv�ljaren</a> genom
    att dra-och-sl�ppa dem mellan respektive databas.
  }
  {
    Scid kan �ppna PGN filer, �ven de som �r komprimerade med Gzip (dvs har en .gz fil�ndelse). 
    PGN filer �ppnas med enbart l�sr�ttigheter, s� om du vill redigera en PGN-fil i Scid 
    m�ste du kopiera filen till en Scid-databas med hj�lp av <a Switcher>Databasv�ljaren</a>.
  }
  {
    Om du ofta anv�nder <a Tree>Tr�df�nstret</a> med stora databaser, �r det v�rt att v�lja
    <b>Fyll cachefil</b> fr�n Arkivmenyn i Tr�df�nstret. Detta inneb�r att tr�dstatistik f�r 
    m�nga av de vanligare st�llningarna sparas, vilket ger en snabbare tr�d�tkomst f�r databasen
    ifr�ga.
  }
  {
    <a Tree>Tr�df�nstret</a> kan visa alla drag fr�n den aktuella st�llningen. Men om ocks� vill 
    se alla dragf�ljder som har lett till denna st�llning kan du f� fram det genom att skapa en
   <a OpReport>�ppningsrapport</a>.
  }
  {
    Du kan v�nster- eller h�gerklicka i en kolumn i <a GameList>Partilistan</a> f�r att �ndra 
    dess bredd.
  }
  {
    Med <a PInfo>Spelarinformationen</a> aktuell (klicka p� endera spelarens namn under br�det i 
    huvudf�nstret f�r att f� fram den) �r det enkelt att <a Searches filtret>Filtrera</a> fram partier
    av en s�rskild spelares enskilda resultat. Klicka bara p� valfritt v�rde som har angivits med
    <red>r�d text</red>.
  }
  {
    N�r du studerar �ppningar kan det vara en po�ng att markera valen <b>B�nder</b> eller <b>Filer</b> i 
    <a Searches Board>S�k aktuell position</a>. Genom dessa val kan du hitta andra �ppningar som ger
    liknande bondestrukturer.
  }
  {
    Du kan h�gerklicka i partiinformationsdelen av huvudf�nstret (under br�det) f�r att f� fram en 
    kontextmeny. Du kan t ex g�ra s� att Scid d�ljer n�sta drag i ett parti, vilket kan vara anv�ndbart 
    om du vill tr�na genom att "gissa" n�sta drag.
  }
  {
    Om du ofta <a Maintenance>Underh�ller</a> stora databaser kan du utf�ra flera underh�llsuppgifter 
    vid samma tillf�lle via <a Maintenance Cleaner>Databasverktyget</a>.
  }
  {
    Om du har en stor databas d�r de flesta partierna har ett evenemangsdatum och du vill ha partierna i 
    datumordning b�r du �verv�ga att <a Sorting>Sortera</a> den p� evenemangsdatum i f�rsta hand och 
    evenemang i andra hand, ist�llet f�r datum och evenemang, d� detta kommer att h�lla turneringspartierna
    fr�n olika datum samman. (Under f�ruts�ttning att alla partier har samma evenemangsdatum naturligtvis).
    Alternativt kan du se till att f�lten evenemang, rond och datum �r s� enhetliga och korrekta som m�jligt.
    (ms).
  }
  {
    Det kan vara en bra id� att <a Maintenance Spellcheck>Stavningskontrollera</a> din databas innan du 
    <a Maintenance Twins>Tar bort dubbletter</a> d� Scid har st�rre m�jlighet att hitta dubbletterna och 
    markera dessa f�r borttagning.
  }
  {
    <a Flags>Flaggor</a> �r anv�ndbara f�r att markera upp partier med karakt�ristika du vill s�ka p� senare,
    s�som bondest�llning, taktiska finesser, osv. Du kan s�ka p� flaggor n�r du s�ker p� f�lt i partihuvudet.
  }
  {
    Om du g�r igenom ett parti, och helt enkelt vill testa en ny variant utan att f�r�ndra partiet i sig, kan 
    du sl� p� F�rs�ksl�get (Trial mode) genom att trycka <b>Ctrl+Mellanslag</b> eller fr�n verktygsraden. �terg� till
    ursprungspartiet n�r du �r klar.
  }
  {
    Om du vill hitta det mest betydelsefulla partiet (med h�gst rankade spelare) i en viss position kan du
    �ppna <a Tree>Tr�df�nstret</a> och i denna �ppna listan med de b�sta partierna. I tr�df�nstret kan du till
    och med begr�nsa partierna till endast ett s�rskilt resultat.
  }
  {
    Ett bra s�tt att studera en �ppning �r att i en stor databas sl� p� tr�ningsl�get i <a Tree>Tr�df�nstret</a>, 
    och sedan spela igenom databasen f�r att se vilka varianter som f�rekommer oftast.
  }
  {
    Om du har tv� databaser �ppna, och vill ha ett varianttr�d att studera medan du g�r igenom ett parti
    i den andra databasen kan du <b>L�sa</b> tr�det i den databasen och sedan byta till den andra.
  }
  {
    <a Tmt>Turneringss�karen</a> �r inte bara anv�ndbar f�r att lokalisera en s�rskild 
    turnering. Du kan ocks� anv�nda den f�r att s�ka efter turneringar en specifik spelare nyligen deltagit 
    i, eller att bl�ddra genom turneringar som genomf�rts i ett visst land.
  }
  {
    Det finns ett antal vanliga st�llningstyper definierade i <a Searches Material>S�k Material/St�llning</a>
    f�nstret som du kan ha nytta av n�r du studerar �ppningar och mittspel.
  }
  {
    N�r du s�ker p� <a Searches Material>Material eller St�llning</a> kan det ofta vara f�rdelaktigt att begr�nsa
    s�kningen till s�dana partier d�r st�llningen eller materialet f�rekommit i �tminstone n�gra drag. Du slipper
    du f� med tr�ffar d�r situationen du s�ker uppkom helt tillf�lligt.
  }
  {
    Om du har en viktig databas du inte vill radera av misstag kan du v�lja  <b>Enbart l�sbar</b> fr�n <b>Arkiv</b>
    menyn efter att du har �ppnat den. Alternativt kan du s�tta dess filr�ttigheter till enbart l�sr�ttigheter.
  }
  {
    Om du anv�nder XBoard eller WinBoard (eller n�got annat program som kan hantera FEN-notation via Urklippshanteraren)
    och vill kopiera den aktuella st�llningen fr�n ditt program �r det snabbaste s�ttet att g�ra det s� h�r:
    V�lj <b>Kopiera position</b> fr�n <b>Arkiv</b>-menyn i Xboard/Winboard, v�lj sedan <b>Klistra i utg�ngsst�llning</b>
    i Redigera menyn i Scid.
  }
  {
    I <a Searches Header>S�k i huvud</a>, �r spelare-, evenemang-, plats-, och rondnamn ok�nsliga f�r VERSALER och
    gemener och ger tr�ffar varhelst de finns i ett namn. Om du vill kan du ange att du ist�llet vill att s�kningen <b>ska</b>
    ta VERSALER/gemener i beaktande. Genom att anv�nda jokertecken inom citationstecken (d�r "?" = motsvarar obest�mt
    enskilt tecken och "*" = noll eller flera tecken). Om du exempelvis anger "*BEL" (med citationstecken) i det platsf�ltet
    hittar du alla partier spelade i Belgien, men exkluderar de som spelats i Belgrad.
  }
  {
    Om du vill redigera ett drag i ett parti utan att f�rlora alla de drag som spelats efter detta kan du �ppna
    <a Import>Importera ett parti i PGN-format</a> f�nstret i Verktygsmenyn. Klicka d�r p� <b>Klistra i aktuellt parti</b> 
    , redigera partiet och avsluta med <b>Importera</b>.
  }
  {
    Om du har en ECO klassificeringsfil laddad, kan du n� den mest exakt klassificerade st�llningen f�r det aktuella partiet
    genom att v�lja <b>Identifiera �ppning</b> i <b>Partier</b> menyn (kortkommando: <b>Ctrl+Shift+D</b>).
  }
  {
    N�r du vill se hur stor en fil �r, eller vill se n�r den senast redigerades innan du �ppnar den kan du anv�nda
    <a Finder>S�k filer</a> (Arkiv - S�k filer).
  }
  {
    En <a repetoire>Repetoarfil</a> �r ett utm�rkt s�tt att h�lla koll p� dina favorit�ppningar, eller hitta partier d�r
    d�r de har spelats. N�r du v�l har skapat en repetoarfil kan du genoms�ka nya filer utifr�n repetoarfilen, och titta 
    igenom alla partier med just dina �ppningar.
  }
  {
    Genom att skapa en <a OpReport>�ppningsrapport</a> har du en utm�rkt m�jlighet att l�ra dig en ny spel�ppning. Du kan f�
    information om resultat, hur remiaktig den �r, vilka vanliga positionella teman som dyker upp, och mycket mer.
  }
  {
    Du kan kommentera den aktuella st�llningen med de vanligaste symbolerna (!, !?, +=, etc) utan att beh�va anv�nda 
    <a Comment>Kommentarseditorn<a>. D�r du exempelvis vill ange ett bra drag skriver du "!" och trycker sedan ENTER
    s� l�ggs "!" symbolen till draget. Se �ven hj�lpsidan <a Moves>Ange drag</a> f�r mer detaljerad information.
  }
  {
    Om du bl�ddrar igenom �ppningarna i en databas i <a Tree>Tr�df�nstret</a>, f�r du en anv�ndbar �verblick �ver hur
    v�l �ppningen fungerar i sentida partier mellan h�gratade spelare om du �ppnar statistikf�nstret (kortkommando: Ctrl+I).
  }
  {
    Du �ndrar enkelt huvudf�nstrets br�dstorlek genom att h�lla nere <b>Ctrl</b> och <b>Shift</b> tangenterna, samtidigt
    som du trycker h�ger- eller v�nster piltangent.
  }
  {
    Efter genomf�rd <a Searches>S�kning</a>, �r det enkelt att navigera genom urvalet genom att h�lla nere <b>Ctrl</b> 
    tangenten samtidigt som du trycker upp- eller nerpiltangenterna f�r att g� till f�reg�ende eller n�sta parti i 
    <a Searches filtret>Urvalet</a>.
  }
{
  Du kan relativt enkelt rita pilar och f�rga rutor till dina kommentarer. �ppna <b>Kommentarseditorn</b>, klicka p� <b>Infoga symbol</b> och v�lj �nskad f�rg. Om du nu klickar p� en f�rsta ruta, och d�refter klickar p� en andra s� dras en pil i �nskad f�rg fr�n den f�rsta till den andra rutan. Klickar du bara p� en ruta, blir den f�rgad.
  }
}
#}
