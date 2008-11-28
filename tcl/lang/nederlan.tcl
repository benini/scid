#  nederlan.tcl:
#  Dutch language support for Scid.
#  Added by J.Kees Hofkamp.
#  Changes by J. Krabbenbos.
#  Changes by Leander Laruelle.
# Untranslated messages are marked with a "***" comment.


addLanguage N Nederlands 0 ;#iso8859-1

proc setLanguage_N {} {

# File menu:
menuText N File "Bestand" 0
menuText N FileNew "Nieuw..." 0 {Maak een nieuwe Scid database}
menuText N FileOpen "Openen..." 0 {Open een bestaande Scid database}
menuText N FileClose "Sluiten" 0 {Sluit de  actieve Scid database}
menuText N FileFinder "Bestandzoeker" 0 {Open het bestandszoekvenster}
menuText N FileBookmarks "Bladwijzers" 0 {Bladwijzer menu (sneltoets: Ctrl+B)}
menuText N FileBookmarksAdd "Toevoegen bladwijzer" 0 \
  {Bladwijzer naar huidige databasepartij en positie}
menuText N FileBookmarksFile "Bladwijzer-bestand" 0 \
  {Maak een bladwijzerbestand voor de huidige partij en stelling}
menuText N FileBookmarksEdit "Wijzigen Bladwijzers..." 0 \
  {Bladwijzermenu's}
menuText N FileBookmarksList "Weergeven bladwijzerfolders als lijst" 0 \
  {Weergeven bladwijzerfolders als lijst, niet als submenu's}
menuText N FileBookmarksSub "Weergeven bladwijzerfolders als submenu's" 0 \
  {Weergeven bladwijzerfolders als submenu's, niet als lijst}
menuText N FileMaint "Onderhoud" 2 {Onderhoud Scid database}
menuText N FileMaintWin "Onderhoudsvenster" 2 \
  {Open/sluit het Scid onderhoudsvenster}
menuText N FileMaintCompact "Reorganiseer database..." 0 \
  {Reorganiseer database bestanden}
menuText N FileMaintClass "Partijen ECO-classificeren..." 10 \
  {Herbereken de ECO code van alle partijen}
menuText N FileMaintSort "Sorteren..." 0 \
  {Sorteer alle partijen in de database}
menuText N FileMaintDelete "Dubbels verwijderen..." 0 \
  {Vind dubbele partijen om ze te verwijderen}
menuText N FileMaintTwin "Dubbels-venster" 1 \
  {Open/bijwerken het dubbels-controle venster}
menuText N FileMaintName "Namen" 0 \
  {Corrigeer namen/spelling}
menuText N FileMaintNameEditor "Namen-bewerker" 6 \
  {Open/sluit het namen-correctie venster}
menuText N FileMaintNamePlayer "Corrigeer naam speler..." 15 \
  {Controleer spelling namen via het spellingcontrole bestand}
menuText N FileMaintNameEvent "Corrigeer naam evenement..." 15 \
  {Controleer spelling evenementen via spellingchecker bestand}
menuText N FileMaintNameSite "Corrigeer naam plaats..." 15 \
  {Controleer plaatsnamen via spellingchecker bestand}
menuText N FileMaintNameRound "Corrigeer ronde..." 10 \
  {Controleer rondenamen via spelling spellingchecker bestand}
menuText N FileReadOnly "Alleen lezen..." 7 \
  {Zet huidige database op alleen-lezen en voorkom veranderingen}
menuText N FileSwitch "Schakel naar andere  database" 0 \
  {Schakel naar een andere geopende database} 
menuText N FileExit "Einde programma" 0 {Einde Scid}
# ====== TODO To be translated ======
menuText N FileMaintFixBase "Fix corrupted base" 0 {Try to fix a corrupted base}

# Edit menu:
menuText N Edit "Bewerken" 0
menuText N EditAdd "Nieuwe variant" 8 \
 {Voeg op dit punt een variant toe}
menuText N EditDelete "Variant verwijderen" 11 \
 {Verwijder een variant voor deze zet}
menuText N EditFirst "Maak hoofdvariant" 5 \
  {Maak deze variant de eerste in de lijst}
menuText N EditMain "Variatie op hoofdvariant" 13 \
   {Promoveerd de variant als hoofdvariant}
menuText N EditTrial "Probeer variatie" 0 \
  {Start/stop probeer modus, om een idee op het bord te testen}
menuText N EditStrip "Verwijder analyse" 2 {Verwijder commentaar of varianten uit deze partij}
menuText N EditStripComments "Commentaar" 0 \
  {Verwijder alle commentaar en annotaties uit deze partij}
menuText N EditStripVars "Varianten" 0 {Verwijder alle varianten uit deze partij}
menuText N EditStripBegin " Zetten vanaf begin " 1 \
  {Verwijder alle zetten vanaf begin van de partij} ;
menuText N EditStripEnd " Zetten tot het einde  " 0 \
  {Verwijder alle verdere zetten tot het einde van de partij} ;
menuText N EditReset "Klembord leegmaken" 0 \
  {Maak het klembord helemaal leeg}
menuText N EditCopy "Partij naar klembord" 7 \
  {Kopieer deze partij naar het klembord}
menuText N EditPaste "Partij vanuit klembord" 7 \
  {Plak actieve klembord-partij hier}
menuText N EditPastePGN "Plak de Klipbord tekst als  PGN partij..." 10 \
  {Interpreteer de Klipbord tekst als een partij  in PGN notatie en plak die hier} ;
menuText N EditSetup "Stelling opzetten..." 0 \
  {Kies een start-stelling voor de partij}
menuText N EditCopyBoard "Copieer stelling " 6 \
  {Copieer de huidige stelling in FEN notatie naar de tekst het tekst clibbord } ;
menuText N EditPasteBoard "Invoegen start stelling" 12 \
  {Maak de start stelling van de huidige tekst selectie (klembord)}

# Game menu:
menuText N Game "Partij" 0
menuText N GameNew "Partij leegmaken" 7 \
  {Maak partij leeg; sla veranderingen niet op}
menuText N GameFirst "Eerste partij laden" 5 {Laad de eerste gefilterde partij}
menuText N GamePrev "Vorige partij laden" 0 \
  {Laad vorige partij in het filter}
menuText N GameReload "Partij opnieuw laden" 7 \
  {Laad partij opnieuw; sla veranderingen niet op}
menuText N GameNext "Volgende partij laden" 3 \
  {Laad volgende partij in het filter}
menuText N GameLast "Laatste partij laden" 6 {Laad de laatste gefilterde partijd}
menuText N GameRandom "Laad willekeurige partij" 8 {Laad een willekeurige partij}
menuText N GameNumber "Laad partij nummer..." 12 \
  {Laad partijnummer:}
menuText N GameReplace "Partij overschrijven..." 11 \
  {Bewaar partij; overschrijf oude versie}
menuText N GameAdd "Partij toevoegen..." 7 \
  {Bewaar partij en voeg toe aan de database}
menuText N GameDeepest "Opening bepalen" 8 \
  {Ga naar de diepste positie uit het ECO openingboek}
menuText N GameGotoMove "Zetnummer..." 0 \
  {Ga naar zetnummer .. in de partij}
menuText N GameNovelty "Vind nieuwtje..." 7 \
  {Vind de eerste zet in deze partij die nog niet eerder is gespeeld}

# Search menu:
menuText N Search "Selecteren" 0
menuText N SearchReset "Alle partijen" 0 \
  {Reset filter en toon alle partijen}
menuText N SearchNegate "Selectie omdraaien" 9 \
  {Draai filter om en toon de andere partijen uit de databse}
menuText N SearchCurrent "Zoek huidige stelling" 5 \
  {Zoek in database naar huidige stelling}
menuText N SearchHeader "Partijgegevens..." 5 \
  {Zoek op speciale informatie: speler, evenement enz.}
menuText N SearchMaterial "Materiaal/Kenmerken..." 0 \
  {Zoek op patroon: bord, materiaal enz.}
menuText N SearchUsing "Zoekopties" 0 \
  {Zoek met gebruikmaking van opgeslagen opties}

# Windows menu:
menuText N Windows "Venster" 0
menuText N WindowsComment "Bewerk commentaar" 0 \
 {Open/sluit commentaar bewerkings venster}
menuText N WindowsGList "Toon alle partijen" 0 \
  {Open/sluit lijst met partijen}
menuText N WindowsPGN "PGN-venster" 0 \
 {Open/sluit het PGN-notatie venster}
menuText N WindowsPList "Spelervinder" 2 {Open/sluit de spelervinder} ;
menuText N WindowsTmt "Toernooi Zoeker" 2 {Open/sluit het toernooi zoekvenster}
menuText N WindowsSwitcher  "Database wisselen" 0 \
  {Open/sluit het database-wisselen venster}
menuText N WindowsMaint "Onderhoudsvenster" 5 \
  {Open/sluit het onderhoudsvenster}
menuText N WindowsECO "ECO Browser" 0 {Open/sluit het ECO browser venster}
menuText N WindowsRepertoire "Repertoire editor" 0 {Open/sluit de openingsrepertoir editor}
menuText N WindowsStats "Statistiek" 0 \
  {Open/sluit het filter statieken-venster}
menuText N WindowsTree "Openingoverzicht" 0 {Open/sluit het Openingsoverzichtvenster}
menuText N WindowsTB "Tablebase venster" 1 \
  {Open/sluit het Tablebase venster}
menuText N WindowsBook "Boek Venster" 0 {Open/sluit het Boek venster}
# ====== TODO To be translated ======
menuText N WindowsCorrChess "Correspondence Window" 0 {Open/close the Correspondence window}

# Tools menu:
menuText N Tools "Gereedschappen" 0
menuText N ToolsAnalysis "Schaakmachiene ..." 3 \
  {Start/stop schaak-analyse programma 1}
menuText N ToolsAnalysis2 "Schaakmachiene #2..." 17 \
  {Start/stop  schaak-analyse programma 2}
menuText N ToolsCross "Kruistabel" 0 \
  {Toon toernooi-kruistabel voor huidige partij}
menuText N ToolsEmail "EmailBeheerder" 0 {Open/sluit het email venster}
menuText N ToolsFilterGraph "Filter grafiek" 7 \
  {Openen/sluiten grafisch filter venster}
# ====== TODO To be translated ======
menuText N ToolsAbsFilterGraph "Abs. Filter Graph" 7 {Open/close the filter graph window for absolute values}
menuText N ToolsOpReport "Openingen rapportering" 0 \
  {Genereer een openingenrapport voor de huidige positie}
# ====== TODO To be translated ======
menuText N ToolsOpenBaseAsTree "Open base as tree" 0   {Open a base and use it in Tree window}
# ====== TODO To be translated ======
menuText N ToolsOpenRecentBaseAsTree "Open recent base as tree" 0   {Open a recent base and use it in Tree window}
menuText N ToolsTracker "Stuk Spoorvolger "  0 {Open het Stuk Spoorvolger venster}
menuText N ToolsTraining "Training"  0 {Training gereedschappen (taktiek, openingen,...) }
menuText N ToolsTacticalGame "Taktische partij"  0 {Speel en taktische partij}
# ====== TODO To be translated ======
menuText N ToolsSeriousGame "Serious game"  0 {Play a serious game}
menuText N ToolsTrainOpenings "Openingen "  0 {Repertoriumtraining}
menuText N ToolsTrainTactics "Tactiek "  0 {Los taktische stellingen op }
# ====== TODO To be translated ======
menuText N ToolsTrainCalvar "Calculation of variations"  0 {Calculation of variations training}
# ====== TODO To be translated ======
menuText N ToolsTrainFindBestMove "Find best move"  0 {Find best move}
# ====== TODO To be translated ======
menuText N ToolsTrainFics "Play on internet"  0 {Play on freechess.org}
menuText N ToolsBookTuning "Openingenboek afstemming " 0 {Openingenboek afstemming}
# ====== TODO To be translated ======
menuText N ToolsConnectHardware "Connect Hardware" 0 {Connect external hardware}
# ====== TODO To be translated ======
menuText N ToolsConnectHardwareConfigure "Configure..." 0 {Configure external hardware and connection}
# ====== TODO To be translated ======
menuText N ToolsConnectHardwareNovagCitrineConnect "Connect Novag Citrine" 0 {Connect Novag Citrine}
# ====== TODO To be translated ======
menuText N ToolsConnectHardwareInputEngineConnect "Connect Input Engine" 0 {Connect Input Engine (e.g. DGT)}
menuText N ToolsPInfo "Speler Informatie"  7 \
  {Open/wijzig het spelerinformatievenster}
menuText N ToolsPlayerReport "Speler Rapport ..." 3 \
  {Genereer een Speler Rapport} ;
menuText N ToolsRating "Elo Klassering geschiedenis" 0 \
  {Grafiek van de Elo Klassering van de twee spelers}
menuText N ToolsScore "Partij score" 7 \
  {Laat het partij-score venster zien}
menuText N ToolsExpCurrent "Partij exporteren" 8 \
  {Exporteer huidige partij naar een bestand}
menuText N ToolsExpCurrentPGN "Partij in PGN-formaat exporteren..." 11 \
  {Schrijf huidige partij naar PGN-bestand}
menuText N ToolsExpCurrentHTML "Partij in HTML-formaat exporteren..." 11 \
  {Schrijf huidige partij naar HTML-bestand}
# ====== TODO To be translated ======
menuText N ToolsExpCurrentHTMLJS "Export Game to HTML and JavaScript File..." 15 {Write current game to a HTML and JavaScript file}  
menuText N ToolsExpCurrentLaTeX "Partij in LaTeX-formaat exporteren..." 11 \
  {Schrijf huidige partij naar LaTex-bestand}
menuText N ToolsExpFilter "Alle partijen in filter exporteren" 17 \
  {Exporteer alle geslecteerde partijen naar een bestand}
menuText N ToolsExpFilterPGN "Filter in PGN-formaat exporteren..." 10 \
  {Schrijf selectie naar PGN-bestand}
menuText N ToolsExpFilterHTML "Filter in HTML-formaat exporteren..." 10 \
  {Schrijf selectie naar HTML-bestand}
# ====== TODO To be translated ======
menuText N ToolsExpFilterHTMLJS "Export Filter to HTML and JavaScript File..." 17 {Write all filtered games to a HTML and JavaScript file}  
menuText N ToolsExpFilterLaTeX "Filter in LaTeX-formaat exporteren..." 10 \
  {Schrijf selectie naar LaTex-bestand}
menuText N ToolsImportOne "Een PGN partij importeren..." 4 \
  {Importeer PGN partij}
menuText N ToolsImportFile "PGN database importeren..." 4 \
  {Importeer PGN bestand}
# ====== TODO To be translated ======
menuText N ToolsStartEngine1 "Start engine 1" 0  {Start engine 1}
# ====== TODO To be translated ======
menuText N ToolsStartEngine2 "Start engine 2" 0  {Start engine 2}
# ====== TODO To be translated ======
menuText N Play "Play" 0
# ====== TODO To be translated ======
menuText N CorrespondenceChess "Correspondence Chess" 0 {Functions for eMail and Xfcc based correspondence chess}
# ====== TODO To be translated ======
menuText N CCConfigure "Configure..." 0 {Configure external tools and general setup}
# ====== TODO To be translated ======
menuText N CCOpenDB "Open Database..." 0 {Open the default Correspondence database}
# ====== TODO To be translated ======
menuText N CCRetrieve "Retrieve Games" 0 {Retrieve games via external (Xfcc-)helper}
# ====== TODO To be translated ======
menuText N CCInbox "Process Inobx" 0 {Process all files in scids Inbox}
# ====== TODO To be translated ======
menuText N CCPrevious "Previous Game" 0 {Go to previous game in Inbox}
# ====== TODO To be translated ======
menuText N CCNext "Next Game" 0 {Go to next game in Inbox}
# ====== TODO To be translated ======
menuText N CCSend "Send Move" 0 {Send your move via eMail or external (Xfcc-)helper}
# ====== TODO To be translated ======
menuText N CCResign "Resign" 0 {Resign (not via eMail)}
# ====== TODO To be translated ======
menuText N CCClaimDraw "Claim Draw" 0 {Send move and claim a draw (not via eMail)}
# ====== TODO To be translated ======
menuText N CCOfferDraw "Offer Draw" 0 {Send move and offer a draw (not via eMail)}
# ====== TODO To be translated ======
menuText N CCAcceptDraw "Accept Draw" 0 {Accept a draw offer (not via eMail)}
# ====== TODO To be translated ======
menuText N CCNewMailGame "New eMail Game..." 0 {Start a new eMail game}
# ====== TODO To be translated ======
menuText N CCMailMove "Mail Move..." 0 {Send the move via eMail to the opponent}

# Options menu:
menuText N Options "Opties" 0
menuText N OptionsBoard "Bord" 0 {Opties  Uitzicht Schaakbord} ;
menuText N OptionsBoardSize "Grootte van bord" 0 {Wijzig bord grootte}
menuText N OptionsBoardPieces "Bord Stukken Stijl" 6 \
  {Wijzig de stijl van bord en/of stukken}
menuText N OptionsBoardColors "Kleuren..." 0 {Wijzig bord kleuren}
# ====== TODO To be translated ======
menuText N OptionsBoardGraphics "Squares..." 0 {Select textures for squares}
# ====== TODO To be translated ======
translate N OptionsBGW {Select texture for squares}
# ====== TODO To be translated ======
translate N OptionsBoardGraphicsText {Select graphic files for white and black squares:}
menuText N OptionsBoardNames "Mijn Spelersnamen ..." 0 {Bewerk mijn spelersnamen} ;
menuText N OptionsExport "Export" 1 {Wijzig tekst export opties}
menuText N OptionsFonts "Lettertypes" 0 {Wijzig lettertype}
menuText N OptionsFontsRegular "Standaard" 0 {Wijzig het standaard lettertype}
menuText N OptionsFontsMenu "Menu" 0 {Wijzig het menu lettertype}
menuText N OptionsFontsSmall "Klein" 0 {Wijzig het kleine lettertype}
menuText N OptionsFontsFixed "Vaste grootte" 0 {Wijzig dit lettertype}
menuText N OptionsGInfo "Partij Informatie" 0 {Parij-informatie opties}
menuText N OptionsLanguage "Kies taal" 5 {Kies taal}
# ====== TODO To be translated ======
menuText N OptionsMovesTranslatePieces "Translate pieces" 0 {Translate first letter of pieces}
menuText N OptionsMoves "Zetten" 0 {Wijzig optie voor zet-invoer}
menuText N OptionsMovesAsk "Bevestiging voor overschrijven" 0 \
  {Bevestig het overschrijven van bestaande zetten}
menuText N OptionsMovesAnimate "Stuk Animatietijd " 1 \
  {Zet animatietijd van de stukkenbewegingen} ;
menuText N OptionsMovesDelay "Tijdinstelling voor auto-spelen" 10 \
  {Stel de tijd in voor het automatisch spelen van de zetten}
menuText N OptionsMovesCoord "Zet-ingave" 0 \
  {Accepteer de volgende manier van zetten invoeren ("g1f3")}
menuText N OptionsMovesSuggest "Toon hint" 0 \
  {Schakel hints aan of uit}
# ====== TODO To be translated ======
menuText N OptionsShowVarPopup "Show variations window" 0 {Turn on/off the display of a variations window} 
# ====== TODO To be translated ======
menuText N OptionsMovesSpace "Add spaces after move number" 0 {Add spaces after move number}  
menuText E OptionsMovesSpace "Add spaces after move number" 0 {Add spaces after move number}   
menuText N OptionsMovesKey "Auto-aanvullen" 0 \
  {Aan/uitschakelen van toetsenbordzet auto-aanvullen}
menuText N OptionsNumbers "Getalformaat" 5 \
  {Kies de manier waarop getallen te zien zijn}
menuText N OptionsStartup "Opstarten" 3 {Selecteer de vensters die tijdens starten geopend worden}
# ====== TODO To be translated ======
menuText N OptionsTheme "Theme" 0 {Change look of interface}
menuText N OptionsWindows "Vensters" 0 {Venster opties}
menuText N OptionsWindowsIconify "Auto-icoon" 5 \
  {Breng alle vensters in icoonvorm als het hoofdvenster naar icoon gaat.}
menuText N OptionsWindowsRaise "Auto-voorgrond" 0 \
  {Breng sommige vensters terug op de voorgrond (bvb. voortgangsbalken) gelijk wanneer ze verdwijnen.}
menuText N OptionsSounds "Geluiden ..." 2 {Configureer zet aankondigingsgeluiden} ;
# ====== TODO To be translated ======
menuText N OptionsWindowsDock "Dock windows" 0 {Dock windows}
# ====== TODO To be translated ======
menuText N OptionsWindowsSaveLayout "Save layout" 0 {Save layout}
# ====== TODO To be translated ======
menuText N OptionsWindowsRestoreLayout "Restore layout" 0 {Restore layout}
# ====== TODO To be translated ======
menuText N OptionsWindowsShowGameInfo "Show game info" 0 {Show game info}
menuText N OptionsToolbar "Gereedschappenbalk" 12 \
  {Weergeven/verbergen hoofdvenster gereedschappenbalk}
menuText N OptionsECO "ECO data laden..." 0 \
  {Laad het ECO classificatie bestand}
menuText N OptionsSpell "Laad spelling (namen)..." 5 \
  {Laad het Scid spellingbestand}
menuText N OptionsTable "Eindspel database laden..." 9 \
  {Kies een eindspel database, alle in de directory aanwezige worden gebruikt}
menuText N OptionsRecent "Recente bestanden..." 0 \
  {Wijzig het aantal recent gebruikte bestanden in het Bestand menu}
# ====== TODO To be translated ======
menuText N OptionsBooksDir "Books directory..." 0 {Sets the opening books directory}
# ====== TODO To be translated ======
menuText N OptionsTacticsBasesDir "Bases directory..." 0 {Sets the tactics (training) bases directory}
menuText N OptionsSave "Opties bewaren" 0 \
  "Bewaar alle instellingen in het bestand $::optionsFile"
menuText N OptionsAutoSave "Automatisch bewaren opties tijdens afsluiten" 0 \
  {Automatisch bewaren alle gewijzigde opties bij het afsluiten van Scid}

# Help menu:
menuText N Help "Help" 0
menuText N HelpContents "Inhoud" 0 {Toon de Help Inhoudstabel} ;
menuText N HelpIndex "Index" 0 {Toon de help inhouds pagina}
menuText N HelpGuide "Snelle hulp" 0 {Laat de snelle-hulp pagina zien}
menuText N HelpHints "Hints" 0 {Laat de hints-hulp pagina zien}
menuText N HelpContact "Contact-info" 0 {Laat de contact-infopagina zien}
menuText N HelpTip "Tip van de dag" 0 {Laat een handige Scid tip zien}
menuText N HelpStartup "Startvenster" 5 {Laat het startvenster zien}
menuText N HelpAbout "Over Scid" 0 {Informatie over Scid}

# Game info box popup menu:
menuText N GInfoHideNext "Verberg volgende zet" 0
menuText N GInfoMaterial "Materiaalverhouding" 0
menuText N GInfoFEN "FEN" 0
menuText N GInfoMarks "Toon gekleurde velden en pijlen. " 5
menuText N GInfoWrap "Lange regels op schermbreedte splitsen." 0
menuText N GInfoFullComment "Volledig commentaar weergeven" 10
menuText N GInfoPhotos "Toon Fotos" 5 ;
menuText N GInfoTBNothing "Eindspel Tablebases: niets" 12
menuText N GInfoTBResult  "Eindspel Tablebases: alleen resultaat" 12
menuText N GInfoTBAll "Eindspel Tablebases: resultaat en beste zetten" 19
menuText N GInfoDelete "Partij wissen/terughalen" 9
menuText N GInfoMark "Partij markeren/niet markeren" 7
# ====== TODO To be translated ======
menuText N GInfoInformant "Configure informant values" 0

# Main windows buttons:
helpMsg N .main.button.start {Naar begin van partij  (toets: home)}
helpMsg N .main.button.end {Naar eind van partij  (toets: end)}
helpMsg N .main.button.back {Een zet terug   (toets: pijl links)}
helpMsg N .main.button.forward {Een zet vooruit  (toets: pijl rechts)}
helpMsg N .main.button.intoVar {Naar variant  (toets: v)}
helpMsg N .main.button.exitVar {Verlaat variant  (toets: z)}
helpMsg N .main.button.flip {Draai bord  (toets: .)}
helpMsg N .main.button.coords {Coordinaten aan/uit  (toets: 0)}
helpMsg N .main.button.stm {Zet zijde-aan-zet ikoon aan ofaf} ;
helpMsg N .main.button.autoplay {Speel zetten automatisch  (toets: Ctrl+Z)}

# General buttons:
translate N Back {Terug}
translate N Browse {Bladeren} ;
translate N Cancel {Annuleren}
translate N Continue {Verder gaane}
translate N Clear {Leegmaken}
translate N Close {Sluiten}
translate N Contents {Inhoud} ;
translate N Defaults {Standaard}
translate N Delete {Wis}
translate N Graph {Grafiek}
translate N Help {Help}
translate N Import {Importeren}
translate N Index {Index}
translate N LoadGame {Partij laden}
translate N BrowseGame {Door de partij bladeren}
translate N MergeGame {Partij Samenvoegen}
# ====== TODO To be translated ======
translate N MergeGames {Merge Games}
translate N Preview {Proefbeeld}
translate N Revert {Terugkeren}
translate N Save {Bewaren}
translate N Search {Zoeken}
translate N Stop {Stop}
translate N Store {Opbergen}
translate N Update {Bijwerken}
translate N ChangeOrient {Wijzigen venster orientatie}
translate N ShowIcons {Toon Ikonen} ;
translate N None {Geen}
translate N First {Eerste}
translate N Current {Huidige}
translate N Last {Laatste}

# General messages:
translate N game {Partij}
translate N games {Partijen}
translate N move {Zet}
translate N moves {Zetten}
translate N all {Alle}
translate N Yes {Ja}
translate N No {Nee}
translate N Both {Beide}
translate N King {Koning}
translate N Queen {Dame}
translate N Rook {Toren}
translate N Bishop {Loper}
translate N Knight {Paard}
translate N Pawn {Pion}
translate N White {Wit}
translate N Black {Zwart}
translate N Player {Speler}
translate N Rating {Eloklassering}
translate N RatingDiff {EloklasseringsVerschil (Wit - Zwart)}
translate N AverageRating {Gemiddelde elo rangschikking} ;
translate N Event {Evenement}
translate N Site {Plaats}
translate N Country {Land}
translate N IgnoreColors {Kleuren negeren}
translate N Date {Datum}
translate N EventDate {Datum evenement}
translate N Decade {Decennium}
translate N Year {Jaar}
translate N Month {Maand}
translate N Months {Januari Februari Maart April Mei Juni Juli Augustus September October November December}
translate N Days {Zon Maa Din Woe Don Vri Zat}
translate N YearToToday {Een jaar geleden}
translate N Result {Uitslag}
translate N Round {Ronde}
translate N Length {Lengte}
translate N ECOCode {ECO Code}
translate N ECO {ECO}
translate N Deleted {Verwijderd}
translate N SearchResults {Zoekresultaten}
translate N OpeningTheDatabase {Database aan het Openen}
translate N Database {Database}
translate N Filter {Filter}
translate N noGames {Geen partijen}
translate N allGames {Alle partijen}
translate N empty {leeg}
translate N clipbase {Klembord}
translate N score {Score}
translate N StartPos {Start positie}
translate N Total {Totaal}
translate N readonly {alleen-lezen}

# Standard error messages:
translate N ErrNotOpen {Deze database is niet geopend.} ;
translate N ErrReadOnly {Deze database is alleen lezen; kan niet veranderd worded.} ;
translate N ErrSearchInterrupted {Zoeken werd onderbroken; de resultaten zijn onvolledig.} ;

# Game information:
translate N twin {Dubbele partijen}
translate N deleted {Gewist}
translate N comment {Commentaar}
translate N hidden {Verborgen}
translate N LastMove {Laatste zet}
translate N NextMove {Volgende zet}
translate N GameStart {Start partij}
translate N LineStart {Start variant}
translate N GameEnd {Einde partij}
translate N LineEnd {Einde variant}

# Player information:
translate N PInfoAll {Resultaten voor <b>alle</b> partijen}
translate N PInfoFilter {Resultaten voor <b>filter</b> partijen}
translate N PInfoAgainst {Resultaten tegen}
translate N PInfoMostWhite {Meest gespeelde opening als Wit}
translate N PInfoMostBlack {Meest gespeelde opening als Zwart}
translate N PInfoRating {Geschiedenis Elo Klassering}
translate N PInfoBio {Biografie}
translate N PInfoEditRatings {Bewerk elo rangschikking} ;

# Tablebase information:
translate N Draw {Remise}
translate N stalemate {Pat}
translate N withAllMoves {met alle zetten}
translate N withAllButOneMove {alle zetten behalve één}
translate N with {met}
translate N only {alleen}
translate N lose {verliezen}
translate N loses {verliest}
translate N allOthersLose {alle overigen verliezen}
translate N matesIn {Mat in}
translate N hasCheckmated {geeft mat}
translate N longest {langste}
translate N WinningMoves {Winnende zetten} ;
translate N DrawingMoves {Remise zetten} ;
translate N LosingMoves {Verliezende zetten} ;
translate N UnknownMoves {Onbekend resultaat zetten} ;

# Tip of the day:
translate N Tip {Tip}
translate N TipAtStartup {Tip bij opstarten}

# Tree window menus:
menuText N TreeFile "BoomDataBestand" 0
# ====== TODO To be translated ======
menuText N TreeFileFillWithBase "Fill Cache with base" 0 {Fill the cache file with all games in current base}
# ====== TODO To be translated ======
menuText N TreeFileFillWithGame "Fill Cache with game" 0 {Fill the cache file with current game in current base}
# ====== TODO To be translated ======
menuText N TreeFileSetCacheSize "Cache size" 0 {Set the cache size}
# ====== TODO To be translated ======
menuText N TreeFileCacheInfo "Cache info" 0 {Get info on cache usage}
menuText N TreeFileSave " BoomData Bewaren" 0 {Bewaar de boomdata in een boomcache (.stc) bestand}
menuText N TreeFileFill "Vullen boomcache bestand" 0 \
  {Vul het boomcache bestand met algemene openingsposities}
menuText N TreeFileBest "Lijst beste partijen" 0 {Weergeven van de lijst met beste partijen}
menuText N TreeFileGraph "Grafiek-venster" 0 \
  {Weergeven van de grafiek voor deze tak}
menuText N TreeFileCopy "Kopieer boom tekst naar klembord" 0 \
  {Kopieren van de boomstatistieken naar het klembord}
menuText N TreeFileClose "Zoekboom venster sluiten" 0 {Sluiten van het zoekboom venster}
# ====== TODO To be translated ======
menuText N TreeMask "Mask" 0
# ====== TODO To be translated ======
menuText N TreeMaskNew "New" 0 {New mask}
# ====== TODO To be translated ======
menuText N TreeMaskOpen "Open" 0 {Open mask}
# ====== TODO To be translated ======
menuText N TreeMaskSave "Save" 0 {Save mask}
# ====== TODO To be translated ======
menuText N TreeMaskClose "Close" 0 {Close mask}
# ====== TODO To be translated ======
menuText N TreeMaskFillWithGame "Fill with game" 0 {Fill mask with game}
# ====== TODO To be translated ======
menuText N TreeMaskFillWithBase "Fill with base" 0 {Fill mask with all games in base}
# ====== TODO To be translated ======
menuText N TreeMaskInfo "Info" 0 {Show statistics for current mask}
menuText N TreeSort "Sorteren" 0
menuText N TreeSortAlpha "Alfabetisch" 0
menuText N TreeSortECO "ECO code" 0
menuText N TreeSortFreq "Frequentie" 0
menuText N TreeSortScore "Punten" 0
menuText N TreeOpt "Opties" 0
# ====== TODO To be translated ======
menuText N TreeOptSlowmode "slow mode" 0 {Slow mode for updates (high accuracy)}
# ====== TODO To be translated ======
menuText N TreeOptFastmode "Fast mode" 0 {Fast mode for updates (no move transposition)}
# ====== TODO To be translated ======
menuText N TreeOptFastAndSlowmode "Fast and slow mode" 0 {Fast mode then slow mode for updates}
menuText N TreeOptLock "Vergrendelen" 0 {Vergrendelen/Ontgrendelen van de boom bij de huidige database}
menuText N TreeOptTraining "Training" 0 {Aan/Uit zetten training modus}
menuText N TreeOptAutosave "Autom.cache-data Bewaren" 4 \
  {Automatisch bewaren van het cache bestand bij sluiten boomvenster}
menuText N TreeHelp "Help" 0
menuText N TreeHelpTree "Hulp bij zoekboom" 0
menuText N TreeHelpIndex "Index" 0
translate N SaveCache {Cache Bewaren}
translate N Training {Training}
translate N LockTree {Boom Vergrendelen}
translate N TreeLocked {Vergrendeld}
translate N TreeBest {Beste}
translate N TreeBestGames {Boom Beste partijen}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate N TreeTitleRow \
  {    Zet   ECO       Frekwentie    Score  GemElo Prest GemJaar %Remises} ;
translate N TreeTotal {TOTAAL}
# ====== TODO To be translated ======
translate N DoYouWantToSaveFirst {Do you want to save first}
# ====== TODO To be translated ======
translate N AddToMask {Add to Mask}
# ====== TODO To be translated ======
translate N RemoveFromMask {Remove from Mask}
# ====== TODO To be translated ======
translate N AddThisMoveToMask {Add this move to Mask}
# ====== TODO To be translated ======
translate N Nag {Nag code}
# ====== TODO To be translated ======
translate N Marker {Marker}
# ====== TODO To be translated ======
translate N Include {Include}
# ====== TODO To be translated ======
translate N Exclude {Exclude}
# ====== TODO To be translated ======
translate N MainLine {Main line}
# ====== TODO To be translated ======
translate N Bookmark {Bookmark}
# ====== TODO To be translated ======
translate N NewLine {New line}
# ====== TODO To be translated ======
translate N ToBeVerified {To be verified}
# ====== TODO To be translated ======
translate N ToTrain {To train}
# ====== TODO To be translated ======
translate N Dubious {Dubious}
# ====== TODO To be translated ======
translate N ToRemove {To remove}
# ====== TODO To be translated ======
translate N NoMarker {No marker}
# ====== TODO To be translated ======
translate N ColorMarker {Color}
# ====== TODO To be translated ======
translate N WhiteMark {White}
# ====== TODO To be translated ======
translate N GreenMark {Green}
# ====== TODO To be translated ======
translate N YellowMark {Yellow}
# ====== TODO To be translated ======
translate N BlueMark {Blue}
# ====== TODO To be translated ======
translate N RedMark {Red}
# ====== TODO To be translated ======
translate N CommentMove {Comment move}
# ====== TODO To be translated ======
translate N CommentPosition {Comment position}
# ====== TODO To be translated ======
translate N AddMoveToMaskFirst {Add move to mask first}
# ====== TODO To be translated ======
translate N OpenAMaskFileFirst {Open a mask file first}
# ====== TODO To be translated ======
translate N Positions {Positions}
# ====== TODO To be translated ======
translate N Moves {Moves}

# Finder window:
menuText N FinderFile "Bestand" 0
menuText N FinderFileSubdirs "Kijken in subdirectories" 0
menuText N FinderFileClose "Sluiten bestandszoeker" 0
menuText N FinderSort "Sorteren" 0
menuText N FinderSortType "Type" 0
menuText N FinderSortSize "Grootte" 0
menuText N FinderSortMod "Gewijzigd" 0
menuText N FinderSortName "Naam" 0
menuText N FinderSortPath "Pad" 0
menuText N FinderTypes "Types" 0
menuText N FinderTypesScid "Scid databases" 0
menuText N FinderTypesOld "Oud formaat Scid databases" 0
menuText N FinderTypesPGN "PGN bestanden" 0
menuText N FinderTypesEPD "EPD (boek) bestanden" 0
menuText N FinderTypesRep "Repertorium bestanden" 0
menuText N FinderHelp "Help" 0
menuText N FinderHelpFinder "Bestandszoeker Help" 0
menuText N FinderHelpIndex " Bestandszoeker Help Inhoud" 0
translate N FileFinder {Bestandszoeker}
translate N FinderDir {Folder}
translate N FinderDirs {Folders}
translate N FinderFiles {Bestanden}
translate N FinderUpDir {Hogere Folder}
# ====== TODO To be translated ======
translate N FinderCtxOpen {Open}
# ====== TODO To be translated ======
translate N FinderCtxBackup {Backup}
# ====== TODO To be translated ======
translate N FinderCtxCopy {Copy}
# ====== TODO To be translated ======
translate N FinderCtxMove {Move}
# ====== TODO To be translated ======
translate N FinderCtxDelete {Delete}

# Player finder:
menuText N PListFile "Bestand" 0
menuText N PListFileUpdate "Bijwerken" 0
menuText N PListFileClose "Dichtbij Speler Vinder" 0 ;
menuText N PListSort "Sorteren" 0
menuText N PListSortName "Naam" 0 ;
menuText N PListSortElo "Elo" 0
menuText N PListSortGames "Partijen" 0 ;
menuText N PListSortOldest "Oudste" 0 ;
menuText N PListSortNewest "Niewste" 0 ;

# Tournament finder:
menuText N TmtFile "Bestand" 0
menuText N TmtFileUpdate "Bijwerken" 0
menuText N TmtFileClose "Sluiten Toernooi zoeker" 0
menuText N TmtSort "Sorteren" 0
menuText N TmtSortDate "Datum" 0
menuText N TmtSortPlayers "Spelers" 0
menuText N TmtSortGames "Partijen" 0
menuText N TmtSortElo "Elo" 0
menuText N TmtSortSite "Plaats" 0
menuText N TmtSortEvent "Evenement" 1
menuText N TmtSortWinner "Winnaar" 0
translate N TmtLimit "Limiet Lijst"
translate N TmtMeanElo "Laagste gem. Elo" 
translate N TmtNone "Geen toernooien gevonden."

# Graph windows:
menuText N GraphFile "Bestand" 0
menuText N GraphFileColor "Bewaren als kleuren Postscript..." 8
menuText N GraphFileGrey "Bewaren als grijze Postscript..." 8
menuText N GraphFileClose "Venster sluiten" 0
menuText N GraphOptions "Opties" 0
menuText N GraphOptionsWhite "Wit" 0
menuText N GraphOptionsBlack "Zwart" 0
menuText N GraphOptionsBoth "Beide" 1
menuText N GraphOptionsPInfo "Speler informatie" 0
translate N GraphFilterTitle "Filtergrafiek: frequentie per 1000 partijen"
# ====== TODO To be translated ======
translate N GraphAbsFilterTitle "Filter Graph: frequency of the games"
# ====== TODO To be translated ======
translate N ConfigureFilter {Configure X-Axes for Year, Rating and Moves}
# ====== TODO To be translated ======
translate N FilterEstimate "Estimate"
# ====== TODO To be translated ======
translate N TitleFilterGraph "Scid: Filter Graph"

# Analysis window:
translate N AddVariation {Toevoegen variant}
# ====== TODO To be translated ======
translate N AddAllVariations {Add All Variations}
translate N AddMove {Toevoegen zet}
translate N Annotate {Annotatie}
# ====== TODO To be translated ======
translate N ShowAnalysisBoard {Show analysis board}
# ====== TODO To be translated ======
translate N ShowInfo {Show engine info}
# ====== TODO To be translated ======
translate N FinishGame {Finish game}
# ====== TODO To be translated ======
translate N StopEngine {Stop engine}
# ====== TODO To be translated ======
translate N StartEngine {Start engine}
# ====== TODO To be translated ======
translate N LockEngine {Lock engine to current position}
translate N AnalysisCommand {Analyse commando}
translate N PreviousChoices {Voorgaande keuzes}
translate N AnnotateTime {Geef de analysetijd in seconden per zet}
translate N AnnotateWhich {Voeg varianten toe}
translate N AnnotateAll {Voor zetten van beide zijden}
# ====== TODO To be translated ======
translate N AnnotateAllMoves {Annotate all moves}
translate N AnnotateWhite {Alleen voor zetten door Wit}
translate N AnnotateBlack { Alleen voor zetten door Zwart}
translate N AnnotateNotBest {Als de partijzet niet de beste is.}
translate N AnnotateBlundersOnly {Als de partijzet een klaarblijjelijke blunder is}
translate N AnnotateBlundersOnlyScoreChange {Blunder Analyse rapport, met scorewijziging van/naar: }
translate N BlundersThreshold {Ondergrens}
translate N LowPriority {Lage CPU prioriteit} ;
# ====== TODO To be translated ======
translate N ClickHereToSeeMoves {Click here to see moves}
# ====== TODO To be translated ======
translate N ConfigureInformant {Configure Informant}
# ====== TODO To be translated ======
translate N Informant!? {Interesting move}
# ====== TODO To be translated ======
translate N Informant? {Poor move}
# ====== TODO To be translated ======
translate N Informant?? {Blunder}
# ====== TODO To be translated ======
translate N Informant?! {Dubious move}
# ====== TODO To be translated ======
translate N Informant+= {White has a slight advantage}
# ====== TODO To be translated ======
translate N Informant+/- {White has a moderate advantage}
# ====== TODO To be translated ======
translate N Informant+- {White has a decisive advantage}
# ====== TODO To be translated ======
translate N Informant++- {The game is considered won}
translate N Book {Openingenboek}
# ====== TODO To be translated ======
translate N OtherBookMoves {Other moves}
# ====== TODO To be translated ======
translate N OtherBookMovesTooltip {Moves not in the book but present in further positions}

# Analysis Engine open dialog:
translate N EngineList {Analyse Machiene Lijst}
translate N EngineName {Naam}
translate N EngineCmd {Commando}
translate N EngineArgs {Parameters}
translate N EngineDir {Folder}
translate N EngineElo {Elo}
translate N EngineTime {Datum}
translate N EngineNew {Nieuw}
translate N EngineEdit {Bewerk}
translate N EngineRequired {Velden in <b>vet</b> zijn vereist; de andere facultatief}

# Stats window menus:
menuText N StatsFile "Bestand" 0
menuText N StatsFilePrint "Data als tekstbestand Bewaren..." 0
menuText N StatsFileClose "Venster sluiten" 0
menuText N StatsOpt "Opties" 0

# PGN window menus:
menuText N PgnFile "Bestand" 0
menuText N PgnFileCopy "Copieer Partij naar Klipbord" 0 ;#
menuText N PgnFilePrint "Als pgn bestand Bewaren..." 0
menuText N PgnFileClose "PGN-venster sluiten" 0
menuText N PgnOpt "Opties" 0
menuText N PgnOptColor "Instellen kleuren" 10
menuText N PgnOptShort "Korte (3 regelige) kop" 0
menuText N PgnOptSymbols "Symbolen annotaties" 10
menuText N PgnOptIndentC "Inspringen (commentaar)" 12
menuText N PgnOptIndentV "Inspringen (variant)" 12
menuText N PgnOptColumn "Kolom stijl (een zet per regel)" 0
menuText N PgnOptSpace "Spatie na zetnummer" 0
menuText N PgnOptStripMarks "Verwijder gekleurde vierkante haken codes" 1
menuText N PgnOptBoldMainLine "Gebrui Dikke Tekst voo Hoofdvariant Zetten" 4 ;
menuText N PgnColor "Kleuren" 0
menuText N PgnColorHeader "Kop..." 0
menuText N PgnColorAnno "Annotaties..." 0
menuText N PgnColorComments "Commentaar..." 0
menuText N PgnColorVars "Varianten..." 0
menuText N PgnColorBackground "Achtergrond kleur..." 0
 
menuText N PgnColorMain "Main line..." 0
 
menuText N PgnColorCurrent "Current move background..." 1
 
menuText N PgnColorNextMove "Next move background..." 0
menuText N PgnHelp "Help" 0
menuText N PgnHelpPgn "PGN help" 0
menuText N PgnHelpIndex "Inhoud" 0
translate N PgnWindowTitle {Partij Notatie - partij %u} ;

# Crosstable window menus:
menuText N CrosstabFile "Bestand" 0
menuText N CrosstabFileText "Bewaren in tekstformaat..." 13
menuText N CrosstabFileHtml " Bewaren in HTML-formaat..." 13
menuText N CrosstabFileLaTeX " Bewaren in LaTeX-formaat..." 13
menuText N CrosstabFileClose "Kruistabel sluiten" 0
menuText N CrosstabEdit "Bewerken" 0
menuText N CrosstabEditEvent "Evenement" 0
menuText N CrosstabEditSite "Plaats" 0
menuText N CrosstabEditDate "Datum" 0
menuText N CrosstabOpt "Opties" 0
menuText N CrosstabOptAll "Gesloten" 0
menuText N CrosstabOptSwiss "Zwitsers" 0
menuText N CrosstabOptKnockout "Knockout" 0
menuText N CrosstabOptAuto "Auto" 0
menuText N CrosstabOptAges "Leeftijd in jaren" 8
menuText N CrosstabOptNats "Nationaliteiten" 1
menuText N CrosstabOptRatings "Elo" 0
menuText N CrosstabOptTitles "Titels" 0
menuText N CrosstabOptBreaks "Tie-break scores" 4
menuText N CrosstabOptDeleted "Inclusief gewiste partijen" 8
menuText N CrosstabOptColors "Kleuren (alleen bij Zwitsers)" 0
menuText N CrosstabOptColumnNumbers "Genummerde kolommen (Alleen bij gesloten tabel)" 2
menuText N CrosstabOptGroup "Punten (groep)" 0
menuText N CrosstabSort "Sorteren" 0
menuText N CrosstabSortName "Naam" 0
menuText N CrosstabSortRating "Elo" 0
menuText N CrosstabSortScore "Score" 0
menuText N CrosstabColor "Kleuren" 0
menuText N CrosstabColorPlain "Tekst" 0
menuText N CrosstabColorHyper "Hypertekst" 1
menuText N CrosstabHelp "Help" 0
menuText N CrosstabHelpCross "Help (kruistabel)" 0
menuText N CrosstabHelpIndex "Inhoud" 0
translate N SetFilter {Zet Filter}
translate N AddToFilter {Toevoegen aan selectie}
translate N Swiss {Zwitsers}
translate N Category {Categorie} ;

# Opening report window menus:
menuText N OprepFile "Bestand" 0
menuText N OprepFileText "Bewaren in tekstformaat..." 13
menuText N OprepFileHtml " Bewaren in HTML-formaat..." 13
menuText N OprepFileLaTeX " Bewaren in LaTeX-formaat..." 13
menuText N OprepFileOptions "Opties..." 0
menuText N OprepFileClose "Sluit rapportvenster" 0
menuText N OprepFavorites "Favorieten" 1 ;
menuText N OprepFavoritesAdd "Voeg Rapport toe..." 0 ;
menuText N OprepFavoritesEdit "Bewerk Favoriete Rapport..." 0 ;
menuText N OprepFavoritesGenerate "Genereer Rapporten..." 0 ;
menuText N OprepHelp "Help" 0
menuText N OprepHelpReport "Help (openingsrapport)" 0
menuText N OprepHelpIndex "Inhoud" 0

# Repertoire editor:
menuText N RepFile "Bestand" 0
menuText N RepFileNew "Nieuw" 0
menuText N RepFileOpen "Openen..." 0
menuText N RepFileSave "Bewaren..." 0
menuText N RepFileSaveAs "Bewaren als..." 5
menuText N RepFileClose "Sluit venster" 2
menuText N RepEdit "Bewerken" 0
menuText N RepEditGroup "Toevoegen Groep" 4
menuText N RepEditInclude "Toevoegen inclusief variant" 4
menuText N RepEditExclude "Toevoegen exclusief variant" 4
menuText N RepView "Bekijken" 0
menuText N RepViewExpand "Uitklappen alle groepen" 0
menuText N RepViewCollapse "Inklappen alle groepen" 0
menuText N RepSearch "Selecteren" 0
menuText N RepSearchAll "Alles van repertorium..." 0
menuText N RepSearchDisplayed "Alleen weergegeven varianten..." 0
menuText N RepHelp "Help" 0
menuText N RepHelpRep "Repertorium help" 0
menuText N RepHelpIndex "Inhoud" 0
translate N RepSearch "Zoeken repertorium"
translate N RepIncludedLines "inclusief varianten"
translate N RepExcludedLines "exclusief varianten"
translate N RepCloseDialog {Dit repetorium heeft onopgeslagen wijzigingen.

Wilt u echt doorgaan en de wijzigingen niet Bewaren?
}

# Header search:
translate N HeaderSearch {Zoek naar kop}
translate N EndSideToMove {Zijde aan zet bij partijeinde} ;
translate N GamesWithNoECO {Partijen zonder ECO?}
translate N GameLength {Lengte partij}
translate N FindGamesWith {Vind partijen met vlag}
translate N StdStart {Ab-normaal begin}
translate N Promotions {Promoties}
translate N Comments {Commentaar}
translate N Variations {Varianten}
translate N Annotations {Annotaties}
translate N DeleteFlag {Gewist-markeringen}
translate N WhiteOpFlag {Wit opening}
translate N BlackOpFlag {Zwart opening}
translate N MiddlegameFlag {Middenspel}
translate N EndgameFlag {Eindspel}
translate N NoveltyFlag {Nieuwtje}
translate N PawnFlag {Pionnenstructur}
translate N TacticsFlag {Tactiek}
translate N QsideFlag {Damevleugel}
translate N KsideFlag {Koningsvleugel}
translate N BrilliancyFlag {Briljant}
translate N BlunderFlag {Blunder}
translate N UserFlag {Gebruiker}
translate N PgnContains {PGN bevat tekst}

# Game list window:
translate N GlistNumber {Nummer}
translate N GlistWhite {Wit}
translate N GlistBlack {Zwart}
translate N GlistWElo {W-Elo}
translate N GlistBElo {Z-Elo}
translate N GlistEvent {Evenement}
translate N GlistSite {Plaats}
translate N GlistRound {Ronde}
translate N GlistDate {Datum}
translate N GlistYear {Jaar}
translate N GlistEDate {Datum evenement}
translate N GlistResult {Uitslag}
translate N GlistLength {Lengte}
translate N GlistCountry {Country}
translate N GlistECO {ECO}
translate N GlistOpening {Opening}
translate N GlistEndMaterial {Eind-Material}
translate N GlistDeleted {Verwijderd}
translate N GlistFlags {Markeringen}
translate N GlistVars {Varianten}
translate N GlistComments {Commentaar}
translate N GlistAnnos {Annotaties}
translate N GlistStart {Start}
translate N GlistGameNumber {Partij nummer}
translate N GlistFindText {Tekst vinden}
translate N GlistMoveField {Zet}
translate N GlistEditField {Configuratie}
translate N GlistAddField {Voeg toe}
translate N GlistDeleteField {Verwijder}
translate N GlistWidth {Breedte}
translate N GlistAlign {Uitlijnen}
translate N GlistColor {Kleuren}
translate N GlistSep {Separator}
 
translate N GlistRemoveThisGameFromFilter  {Remove this game from Filter}
 
translate N GlistRemoveGameAndAboveFromFilter  {Remove game (and all above it) from Filter}
 
translate N GlistRemoveGameAndBelowFromFilter  {Remove game (and all below it) from Filter}
# ====== TODO To be translated ======
translate N GlistDeleteGame {(Un)Delete this game} 
# ====== TODO To be translated ======
translate N GlistDeleteAllGames {Delete all games in filter} 
# ====== TODO To be translated ======
translate N GlistUndeleteAllGames {Undelete all games in filter} 

# Maintenance windows
translate N DatabaseName {Naam database:}
translate N TypeIcon {Type icoon:}
translate N NumOfGames {Partijen:}
translate N NumDeletedGames {Gewiste partijen:}
translate N NumFilterGames {Partijen in selectie:}
translate N YearRange {JaarBereik:}
translate N RatingRange {EloBereik (laag/hoog):}
translate N Description {Beschrijving} ;
translate N Flag {Markering}
translate N DeleteCurrent {Wis huidige partij}
translate N DeleteFilter {Wis geselecteerde partijen}
translate N DeleteAll {Wis alle partijen}
translate N UndeleteCurrent {Haal huidige partij terug}
translate N UndeleteFilter {Haal geselecteerde partijen terug}
translate N UndeleteAll {Haal alle partijen terug}
translate N DeleteTwins {Wis doublures}
translate N MarkCurrent {Markeer huidige partij}
translate N MarkFilter {Markeer geselecteerde partijen}
translate N MarkAll {Markeer alle partijen}
translate N UnmarkCurrent {Verwijder Markering huidige partij)}
translate N UnmarkFilter {Verwijder Markering geselecteerde partijen)}
translate N UnmarkAll {Verwijder Markering alle partijen)}
translate N Spellchecking {Spellingscontrole}
translate N Players {Spelers}
translate N Events {Evenementen}
translate N Sites {Plaatsen}
translate N Rounds {Rondes}
translate N DatabaseOps {Database bewerkingen}
translate N ReclassifyGames {Partijen ECO-classificeren...}
translate N CompactDatabase {Database compact maken = optimaliseren}
translate N SortDatabase {Database sorteren}
translate N AddEloRatings {Toevoegen Elo classificatie}
translate N AutoloadGame {Auto-laden partij nummer}
translate N StripTags {Verwijder PGN labels}
translate N StripTag {Verwijder label}
translate N Cleaner {Reiniger}
translate N CleanerHelp {
De Scid Reiniger zal alle onderhoudsactiviteiten die u selecteert uit onderstaande lijst, uitvoeren op de huidige database. 
De dialogen van de huidige instellingen in de ECO classificatie en verwijderen van doublures zullen worden toegepast indien u deze functies selecteert.
}
translate N CleanerConfirm {
Eens het Reiniger onderhoud is gestart, kan dit niet worden onderbroken!

Dit kan lang duren op een grote database, afhankelijk van de geselecteerde functies en de huidige instellingen.

Weet u zeker dat u de geselecteerde onderhoudsfuncties wilt uitvoeren?
}
# ====== TODO To be translated ======
translate N TwinCheckUndelete {to flip; "u" undeletes both)}
# ====== TODO To be translated ======
translate N TwinCheckprevPair {Previous pair}
# ====== TODO To be translated ======
translate N TwinChecknextPair {Next pair}
# ====== TODO To be translated ======
translate N TwinChecker {Scid: Twin game checker}
# ====== TODO To be translated ======
translate N TwinCheckTournament {Games in tournament:}
# ====== TODO To be translated ======
translate N TwinCheckNoTwin {No twin  }
# ====== TODO To be translated ======
translate N TwinCheckNoTwinfound {No twin was detected for this game.\nTo show twins using this window, you must first use the "Delete twin games..." function. }
# ====== TODO To be translated ======
translate N TwinCheckTag {Share tags...}
# ====== TODO To be translated ======
translate N TwinCheckFound1 {Scid found $result twin games}
# ====== TODO To be translated ======
translate N TwinCheckFound2 { and set their delete flags}
# ====== TODO To be translated ======
translate N TwinCheckNoDelete {There are no games in this database to delete.}
# ====== TODO To be translated ======
translate N TwinCriteria1 { Your settings for finding twin games are potentially likely to\ncause non-twin games with similar moves to be marked as twins.}
# ====== TODO To be translated ======
translate N TwinCriteria2 {It is recommended that if you select "No" for "same moves", you should select "Yes" for the colors, event, site, round, year and month settings.\nDo you want to continue and delete twins anyway? }
# ====== TODO To be translated ======
translate N TwinCriteria3 {It is recommended that you specify "Yes" for at least two of the "same site", "same round" and "same year" settings.\nDo you want to continue and delete twins anyway?}
# ====== TODO To be translated ======
translate N TwinCriteriaConfirm {Scid: Confirm twin settings}
# ====== TODO To be translated ======
translate N TwinChangeTag "Change the following game tags:\n\n"
# ====== TODO To be translated ======
translate N AllocRatingDescription "This command will use the current spellcheck file to add Elo ratings to games in this database. Wherever a player has no currrent rating but his/her rating at the time of the game is listed in the spellcheck file, that rating will be added."
# ====== TODO To be translated ======
translate N RatingOverride "Overwrite existing non-zero ratings?"
# ====== TODO To be translated ======
translate N AddRatings "Add ratings to:"
# ====== TODO To be translated ======
translate N AddedRatings {Scid added $r Elo ratings in $g games.}
# ====== TODO To be translated ======
translate N NewSubmenu "New submenu"

# Comment editor:
translate N AnnotationSymbols  {Symbolen voor annotatie:}
translate N Comment {Commentaar:}
translate N InsertMark {Voeg markering toe} ;
translate N InsertMarkHelp {
Voeg toe/verwijder markering: Selecteer  kleur, type, veld.
Voeg toe/verwijder pijl: Rechtsklik twee velden.
} ;

# Nag buttons in comment editor:
translate N GoodMove {Goede zet} ;
translate N PoorMove {Slechte zet} ;
translate N ExcellentMove {Excellente zet} ;
translate N Blunder {Blunder}
translate N InterestingMove {Interessante zet} ;
translate N DubiousMove {Twijfelachtige zet} ;
translate N WhiteDecisiveAdvantage {Wit heeft beslissend voordeel} ;
translate N BlackDecisiveAdvantage {Zwart heeft beslissend voordee} ;
translate N WhiteClearAdvantage {Wit heeft duidelijk voordeel} ;
translate N BlackClearAdvantage {Zwart heeft beslissend voordeel} ;
translate N WhiteSlightAdvantage {Wit heeft licht voordeel} ;
translate N BlackSlightAdvantage {Zwart heeft licht voordee} ;
translate N Equality {Gelijk} ;
translate N Unclear {Onduidelijk} ;
translate N Diagram {Diagram} ;

# Board search:
translate N BoardSearch {Zoeken Bord}
translate N FilterOperation {Toepassen op huidige selectie:}
translate N FilterAnd {AND (Selectie beperken)}
translate N FilterOr {OR (Selectie uitbreiden)}
translate N FilterIgnore {Selectie Ongedaan maken}
translate N SearchType {Zoek type stelling:}
translate N SearchBoardExact {Exacte positie (stukken op dezelfde velden)}
translate N SearchBoardPawns {Pionnen (hetzelfde materiaal, alle pionnen op dezelfde velden)}
translate N SearchBoardFiles {Lijnen (hetzelfde materiaal, alle pionnen op dezelfde lijnen)}
translate N SearchBoardAny {Willekeurig (hetzelfde materiaal, pionnen en stukken willekeurig)}
translate N LookInVars {Zoek in varianten}

# Material search:
translate N MaterialSearch {Zoeken Materiaal}
translate N Material {Materiaal}
translate N Patterns {Patroon}
translate N Zero {Niets}
translate N Any {Willekeurig}
translate N CurrentBoard {Huidige stelling}
translate N CommonEndings {Veel Voorkomende Eindspelen}
translate N CommonPatterns { Veel Voorkomende patronen}
translate N MaterialDiff {Material onevenwicht}
translate N squares {Velden}
translate N SameColor {Gelijke kleur}
translate N OppColor {Ongelijke kleur}
translate N Either {Beide}
translate N MoveNumberRange {Zet bereik }
translate N MatchForAtLeast {Op z'n minst gelijk}
translate N HalfMoves {halve zetten}

# Common endings in material search:
translate N EndingPawns {Pionnen eindspel} ;
translate N EndingRookVsPawns {Toren tegen Pion(nen)} ;
translate N EndingRookPawnVsRook {Toren en 1 Pion tegen Toren} ;
translate N EndingRookPawnsVsRook {Toren en Pionnen tegen Toren} ;
translate N EndingRooks {Toren tegen Toren Eindspel} ;
translate N EndingRooksPassedA {Toren tegen Toren met een vrije a-pion} ;
translate N EndingRooksDouble {Dubbele Toren eindspelen} ;
translate N EndingBishops {Loper tegen Loper eindspel} ;
translate N EndingBishopVsKnight {Loper tegen Paard eindspe} ;
translate N EndingKnights {Paard tegenPaard eindspel} ;
translate N EndingQueens {Dame tegen Dame eindspel} ;
translate N EndingQueenPawnVsQueen {Dame +1 pion tegen Dame} ;
translate N BishopPairVsKnightPair {Loperpaar tegen 2 Paarden middenspel} ;

# Common patterns in material search:
translate N PatternWhiteIQP {Witte Geïsoleerde pion} ;
translate N PatternWhiteIQPBreakE6 {Witte Geïsoleerde pion: d4-d5 doorbraak vs. e6} ;
translate N PatternWhiteIQPBreakC6 {Witte Geïsoleerde pion: d4-d5 doorbraak vs. c6} ;
translate N PatternBlackIQP {Zwarte Geïsoleerde pion} ;
translate N PatternWhiteBlackIQP {Witte Geïsoleerde pion  vs. Zwarte Geïsoleerde pion} ;
translate N PatternCoupleC3D4 {Witte hangende pionnen c3+d4 } ;
translate N PatternHangingC5D5 {Zwarte hangende pionnen c5+d5} ;
translate N PatternMaroczy {Maroczy Centrum ( Pionnen op c4 en e4)} ;
translate N PatternRookSacC3 {Torenoffer op c3} ;
translate N PatternKc1Kg8 {O-O-O vs. O-O (Kc1 vs. Kg8)} ;
translate N PatternKg1Kc8 {O-O vs. O-O-O (Kg1 vs. Kc8)} ;
translate N PatternLightFian {Light-Square Fianchettos (Loper-g2 vs. Loper-b7)} ;
translate N PatternDarkFian {Dark-Square Fianchettos (Loper-b2 vs. Loper-g7)} ;
translate N PatternFourFian {Four Fianchettos (Lopers op b2,g2,b7,g7)} ;

# Game saving:
translate N Today {Nu}
translate N ClassifyGame {Partij classificeren}

# Setup position:
translate N EmptyBoard {Bord leegmaken}
translate N InitialBoard {Beginstelling}
translate N SideToMove {Aan zet:}
translate N MoveNumber {Zetnummer}
translate N Castling {Rokade}
translate N EnPassantFile {En Passant lijn}
translate N ClearFen {FEN leegmaken}
translate N PasteFen {FEN plakken}
# ====== TODO To be translated ======
translate N SaveAndContinue {Save and continue}
# ====== TODO To be translated ======
translate N DiscardChangesAndContinue {Discard changes\nand continue}
# ====== TODO To be translated ======
translate N GoBack {Go back}

# Replace move dialog:
translate N ReplaceMove {Zet vervangen}
translate N AddNewVar {Voeg Nieuwe Variant Toe}
# ====== TODO To be translated ======
translate N NewMainLine {New Main Line}
translate N ReplaceMoveMessage {Hier is al een zet.  

U kunt hem vervangen en alle volgende zetten wissen, of uw zet toevoegen als een nieuwe variant.

(U kunt deze boodschap in de toekeomst vermijden door de optie "Zet vervangen bevestigen" uit te zetten in het menu:Zetten)}

# Make database read-only dialog:
translate N ReadOnlyDialog {Als u deze database "alleen-lezen" maakt, zijn geen veranderingen toegestaan.
Er kunnen geen partijen meer worden opgeslagen of veranderd en ook geen wis-markeringen toegevoegd of verwijderd.
Elke sortering of ECO-classificering zal tijdelijk zijn dan voor deze database.

U kunt de database weer schrijf-toegankelijk maken door hem te sluiten en weer te openen.

Wilt u echt deze database alleen-lezen maken?}

# Clear game dialog:
translate N ClearGameDialog {Deze partij is gewijzigd.

Wilt u echt doorgaan en de wijzigingen niet doorvoeren?
}

# Exit dialog:
translate N ExitDialog {Wilt u Scid werkelijk afsluiten?}
translate N ExitUnsaved {De volgende databases hebben nog onopgeslagen wijzigingen in hun partijen.  Als u nu afsluit zullen deze wijzigingen verloren gaan.}

# Import window:
translate N PasteCurrentGame {Plak huidige partij}
translate N ImportHelp1 {Invoeren of plak een PGN-formaat partij in het venster hierboven.}
translate N ImportHelp2 {Alle import-fouten worden hier weergegeven.}
# ====== TODO To be translated ======
translate N OverwriteExistingMoves {Overwrite existing moves ?}

# ECO Browser:
translate N ECOAllSections {alle ECO code secties}
translate N ECOSection {ECO sectie}
translate N ECOSummary {Samenvatting voor}
translate N ECOFrequency {Frequentie van subcodes voor}

# Opening Report:
translate N OprepTitle {Openings Rapportage}
translate N OprepReport {Rapportage}
translate N OprepGenerated {Samengesteld door }
translate N OprepStatsHist {Statistieken en Geschiedenis}
translate N OprepStats {Statistieken}
translate N OprepStatAll {Alle Rapportage Partijen}
translate N OprepStatBoth {Beide Spelers Elo}
translate N OprepStatSince {Sinds}
translate N OprepOldest {Oudste partijen}
translate N OprepNewest {Meest recente partijen}
translate N OprepPopular {Huidige Populariteit}
translate N OprepFreqAll {Frequentie over alle jaren: }
translate N OprepFreq1   {In het afgelopen jaar:      }
translate N OprepFreq5   {In de afgelopen 5 jaar:    }
translate N OprepFreq10  {In de afgelopen 10 jaar:    }
translate N OprepEvery {Eens per %u partijen}
translate N OprepUp {%u%s hoger dan alle jaren}
translate N OprepDown {%u%s lager dan alle jaren}
translate N OprepSame {zelfde als alle jaren}
translate N OprepMostFrequent {Meest frequente spelers}
translate N OprepMostFrequentOpponents {Frekwentste tegenstanders} ;
translate N OprepRatingsPerf {Elo Classificatie en Resultaten}
translate N OprepAvgPerf {Gemiddelde Elo Classificatie en Resultaten }
translate N OprepWRating {Witte Elo Classificatie }
translate N OprepBRating {Zwarte Elo Classificatie }
translate N OprepWPerf {Prestatie wit}
translate N OprepBPerf {Prestatie zwart}
translate N OprepHighRating {Partijen met de hoogste gemiddelde Elo Classificatie }
translate N OprepTrends {Resultaten trends}
translate N OprepResults {Resultaat lengtes en frequenties}
translate N OprepLength {Partij lengte}
translate N OprepFrequency {Frequentie}
translate N OprepWWins {Overwinningen wit:   }
translate N OprepBWins {Overwinningen zwart: }
translate N OprepDraws {Remises: }
translate N OprepWholeDB {hele database}
translate N OprepShortest {Kortste winst}
# translate N OprepShortWhite {Kortste witte overwinningen}
# translate N OprepShortBlack {Kortste zwarte overwinningen}
translate N OprepMovesThemes {Zetten en thema's}
translate N OprepMoveOrders {Zetvolgorde om rapportstelling te bereiken}
translate N OprepMoveOrdersOne \
  {Er was slechts 1 volgorde om deze stelling te bereiken:}
translate N OprepMoveOrdersAll \
  {Er waren %u zet-volgordes om deze stelling te bereiken:}
translate N OprepMoveOrdersMany \
  {Er waren %u zet-volgordes om deze stelling te bereiken. De top %u zijn:}
translate N OprepMovesFrom {Zetten vanuit de rapportpositie:}
translate N OprepMostFrequentEcoCodes {Frekwentste ECO codes} ;
translate N OprepThemes {Positionele Thema's}
translate N OprepThemeDescription {Frekwentie van  themas in de eerste %u zetten van elke partij} ;
translate N OprepThemeSameCastling {Gelijke rochades}
translate N OprepThemeOppCastling {Tegengestelde rochades}
translate N OprepThemeNoCastling {Beide zijden niet gerocheerd}
translate N OprepThemeKPawnStorm {Pionnenstorm op koningsvleugel}
translate N OprepThemeQueenswap {Dameruil}
translate N OprepThemeWIQP {Witte Geïsoleerde Damepion} ;
translate N OprepThemeBIQP {Zwarte Geïsoleerde Damepion} ;
translate N OprepThemeWP567 {Witte pion op de 5/6/7de rij}
translate N OprepThemeBP234 {Zwarte pion op de 2/3/4de rij}
translate N OprepThemeOpenCDE {Open c/d/e lijn}
translate N OprepTheme1BishopPair {Slechts 1 kant heeft loperpaar}
translate N OprepEndgames {Eindspelen}
translate N OprepReportGames {Rapportage partijen}
translate N OprepAllGames {Alle partijen}
translate N OprepEndClass {Materiaal classificatie van eindstellingen}
translate N OprepTheoryTable {Theorie tabel}
translate N OprepTableComment {Samengesteld uit de %u partijen met de hoogste Elo classificatie.}
translate N OprepExtraMoves {Extra zetten in theorie tabel}
translate N OprepMaxGames {Maximaal aantal partijen in theorie tabel}
translate N OprepViewHTML { HTML zicht} ;
translate N OprepViewLaTeX {LaTeX zicht} ;

# Player Report:
translate N PReportTitle {Speler Rapport} ;
translate N PReportColorWhite {met Wit} ;
translate N PReportColorBlack {mee Zwart} ;
translate N PReportMoves {na %s} ;
translate N PReportOpenings {Openingen} ;
translate N PReportClipbase {Maak klipbord leeg en copieer de aan voorwaarden vervullende partijen ernaar} ;

# Piece Tracker window:
translate N TrackerSelectSingle {Linkse muisknop selecteert dit stuk.}
translate N TrackerSelectPair { Linkse muisknop selecteert dit stuk; de rechtermuisknop selecteert zijn buur.}
translate N TrackerSelectPawn { Linkse muisknop selcteert deze pion; ; de rechtermuisknop selecteert alle 8 pionnen.}
translate N TrackerStat {Statistiek}
translate N TrackerGames {% partijen met zet naar dit veld.}
translate N TrackerTime {% keer op ieder veld.}
translate N TrackerMoves {Zetten}
translate N TrackerMovesStart {Voer de zet in waar de Spoorvolger moet beginnen.}
translate N TrackerMovesStop { Voer de zet in waar de Spoorvolger moet stoppen.}

# Game selection dialogs:
translate N SelectAllGames {Alle partijen in de database}
translate N SelectFilterGames {Alleen partijen uit selectiefilter}
translate N SelectTournamentGames {Alleen partijen in huidig toernooi}
translate N SelectOlderGames {Alleen oudere partijen}

# Delete Twins window:
translate N TwinsNote {Om een dubbele partij te zijn moet deze minimaal dezelfde twee spelers en de onderstaande te selecteren criteria bevatten. Bij vondst van twee dubbele partijen wordt de kortste verwijderd. Hint: Controleer de database op spelfouten voordat doublures worden verwijderd. Dit verhoogt de kans op vinden van dubbele partijen. }
translate N TwinsCriteria {Criteria: Dubbele partijen moeten hebben...}
translate N TwinsWhich {Onderzoek welke partijen}
translate N TwinsColors {Spelers dezelfde kleur?}
translate N TwinsEvent {Hetzelfde evenement?}
translate N TwinsSite {Dezelfde lokatie?}
translate N TwinsRound {Dezelfde ronde?}
translate N TwinsYear {Hetzelfde jaar?}
translate N TwinsMonth {Dezelfde maand?}
translate N TwinsDay {Dezelfde dag?}
translate N TwinsResult {Hetzelfde resultaat?}
translate N TwinsECO {Dezelfde ECO code?}
translate N TwinsMoves {Dezelfde zetten?}
translate N TwinsPlayers {Vergelijken speler namen:}
translate N TwinsPlayersExact {Exacte overeenkomst}
translate N TwinsPlayersPrefix {Alleen eerste 4 letters}
translate N TwinsWhen {Wanner doublures verwijderen}
translate N TwinsSkipShort {Negeer alle partijen korter dan 5 zetten?}
translate N TwinsUndelete {Haal alle voor wissen gemarkeerde partijen eerst terug?}
translate N TwinsSetFilter {Selecteer alle verwijderde dubbele partijen?}
translate N TwinsComments {Altijd partijen met commentaar bewaren?}
translate N TwinsVars {Altijd partijen met varianten bewaren?}
translate N TwinsDeleteWhich {Welke partij wissen:}
translate N TwinsDeleteShorter {Kortste partij}
translate N TwinsDeleteOlder {Laagste partijnummer}
translate N TwinsDeleteNewer {Hoogste partijnummer}
translate N TwinsDelete {Verwijder partijen}

# Name editor window:
translate N NameEditType {Type naam om te wijzigen}
translate N NameEditSelect {Partijen om te wijzigen}
translate N NameEditReplace {Vervangen}
translate N NameEditWith {met}
translate N NameEditMatches {Gelijken: Druk Ctrl+1 tot Ctrl+9 om te selecteren}

# Classify window:
translate N Classify {Classificeren}
translate N ClassifyWhich {ECO-Classificatie: welke partijen}
translate N ClassifyAll {Alle partijen (overschrijven oude ECO codes)}
translate N ClassifyYear {Alle partijen gespeeld in het afgelopen jaar}
translate N ClassifyMonth {Alle partijen gespeeld in de afgelopen maand}
translate N ClassifyNew {Alleen partijen zonder ECO code}
translate N ClassifyCodes {ECO Codes om te gebruiken}
translate N ClassifyBasic {Alleen basis codes ("B12", ...)}
translate N ClassifyExtended {Scid extenties ("B12j", ...)}

# Compaction:
translate N NameFile {Namen Bestand}
translate N GameFile {Partijen Bestand}
translate N Names {Namen}
translate N Unused {Ongebruikt}
translate N SizeKb {Grootte (Kb)}
translate N CurrentState {Huidige toestand}
translate N AfterCompaction {Na comprimeren}
translate N CompactNames {Gecomprimeerde namen bestand}
translate N CompactGames {Gecomprimeerd partijen bestand}
# ====== TODO To be translated ======
translate N NoUnusedNames "There are no unused names, so the name file is already fully compacted."
# ====== TODO To be translated ======
translate N NoUnusedGames "The game file is already fully compacted."
# ====== TODO To be translated ======
translate N NameFileCompacted {The name file for the database "[file tail [sc_base filename]]" was compacted.}
# ====== TODO To be translated ======
translate N GameFileCompacted {The game file for the database "[file tail [sc_base filename]]" was compacted.}

# Sorting:
translate N SortCriteria {Criteria}
translate N AddCriteria {Toevoegen criteria}
translate N CommonSorts {Algemene sorteringen}
translate N Sort {Sorteren}

# Exporting:
translate N AddToExistingFile {Toevoegen partijen aan bestaand bestand?}
translate N ExportComments {Exporteren commentaar?}
translate N ExportVariations {Exporteren varianten?}
translate N IndentComments {Inspringen commentaar?}
translate N IndentVariations {Inspringen varianten?}
translate N ExportColumnStyle {Kolomstijl (een zet per regel)?}
translate N ExportSymbolStyle {Symbolische annotatie stijl:}
translate N ExportStripMarks {Wis vierkante haken/pijlen markeer codes uit de commentaar?}

# Goto game/move dialogs:
translate N LoadGameNumber {Geef het nummer van de te laden partij:}
translate N GotoMoveNumber {Ga naar zetnummer:}

# Copy games dialog:
translate N CopyGames {Kopiëren partijen}
translate N CopyConfirm {
 Wilt u echt kopieren
 de [::utils::thousands $nGamesToCopy] geselecteerde partijen
 van database "$fromName"
 naar database "$targetName"?
}
translate N CopyErr {Kan partijen niet kopieren}
translate N CopyErrSource {de bron database}
translate N CopyErrTarget {de doel database}
translate N CopyErrNoGames {heeft geen partijen in het filter}
translate N CopyErrReadOnly {is alleen-lezen}
translate N CopyErrNotOpen {is niet geopend}

# Colors:
translate N LightSquares {Lichte velden}
translate N DarkSquares {Donkere velden}
translate N SelectedSquares {Geselecteerde velden}
translate N SuggestedSquares {Zetsuggestie velden}
translate N WhitePieces {Witte stukken}
translate N BlackPieces {Zwarte stukken}
translate N WhiteBorder {Witte rand}
translate N BlackBorder {Zwarte rand}

# Novelty window:
translate N FindNovelty {Vind Nieuwtje}
translate N Novelty {Nieuwtje}
translate N NoveltyInterrupt {Zoeken nieuwtje onderbroken}
translate N NoveltyNone {In deze partij is geen nieuwtje gevonden}
translate N NoveltyHelp {
Scid zal de eerste zet vinden in de huidige partij, waarna een stelling ontstaat die nog niet was gevonden in de database of in het ECO openingsboek.
}

# Sounds configuration:
translate N SoundsFolder {Geluidsbestanden Map} ;
translate N SoundsFolderHelp {De map moet de bestanden King.wav, a.wav, 1.wav, enz. bevatten} ;
translate N SoundsAnnounceOptions {Zet Aankondigingen Opties} ;
translate N SoundsAnnounceNew {Kondig nieuwe zetten aan als ze gedaan worden} ;
translate N SoundsAnnounceForward {Kondig  aan als één zet vooruit gedaan wordt} ;
translate N SoundsAnnounceBack {Kondig  aan als één zet terug gedaan of genomen wordt} ;

# Upgrading databases:
translate N Upgrading {Bijwerken}
translate N ConfirmOpenNew {
Dit is een oud formaat (Scid 2) database welke in Scid 3 niet kan worden geopend. Maar een nieuwe versie (Scid 3) is reeds aangemaakt.

Wilt u de database in het nieuwe formaat openen?
}
translate N ConfirmUpgrade {
Dit is een oud formaat (Scid 2) database. Een versie in het nieuwe formaat moet worden gemaakt, voordat het in Scid 3 kan worden gebruikt.

Bijwerken creëert een nieuwe versie van de database. De originele bestanden blijven bestaan en worden niet gewijzigd.

Dit kan enige tijd duren, maar het hoeft slechts eenmalig plaats te vinden. U kunt het afbreken indien het te lang duurt.

Wilt u de database nu bijwerken?
}

# Recent files options:
translate N RecentFilesMenu {Aantal recente bestanden in Bestand menu}
translate N RecentFilesExtra {Aantal recente bestand in extra submenu}

# My Player Names options:
translate N MyPlayerNamesDescription {Voeg hieronder een lijst met voorkeur spelernamen in, 1 speler per regel. Jokers (bvb "?" voor elke letter, "*" voor een reeks letters) zijn toegelaten.
Telkens een partij uit de lijst word geladen, zal het schaakbord worden gedraaid indien nodig om de partij vanuit die speler zijn perspektief te tonen.
} ;

translate N showblunderexists {toon dat er een blunder is}
translate N showblundervalue {toon blunder waarde}
translate N showscore {toon score}
translate N coachgame {coach partij}
translate N configurecoachgame {configureer coach partij}
# ====== TODO To be translated ======
translate N configuregame {Game configuration}
translate N Phalanxengine {Phalanx machiene}
translate N Coachengine {Coach machiene}
translate N difficulty {moeilijkheid}
translate N hard {erg moeilijk}
translate N easy {gemakkelijk}
translate N Playwith {Speel met}
 
translate N white {wit}
 
translate N black {zwart}
 
translate N both {beide}
 
translate N Play {Spel}
 
translate N Noblunder {Geen blunder}
 
translate N blunder {Blunder}
 
translate N Noinfo {-- Geen info --}
# ====== TODO To be translated ======
translate N PhalanxOrTogaMissing {Phalanx or Toga not found}
 
 
 
translate N moveblunderthreshold {zet is blunder als het verlies groter is dan}
 
translate N limitanalysis {limiet machiene analyse tijd}
 
translate N seconds {seconden}
 
translate N Abort {Geeft op}
# ====== TODO To be translated ======
translate N Resume {Resume}
 
translate N OutOfOpening {Uit de opening}
 
translate N NotFollowedLine {Je volgde de variant niet}
 
translate N DoYouWantContinue {Wil je verder gaan?}
# ====== TODO To be translated ======
translate N CoachIsWatching {Coach is watching}
# ====== TODO To be translated ======
translate N Ponder {Permanent thinking}
# ====== TODO To be translated ======
translate N LimitELO {Limit ELO strength}
# ====== TODO To be translated ======
translate N DubiousMovePlayedTakeBack {Dubious move played, do you want to take back ?}
# ====== TODO To be translated ======
translate N WeakMovePlayedTakeBack {Weak move played, do you want to take back ?}
# ====== TODO To be translated ======
translate N BadMovePlayedTakeBack {Bad move played, do you want to take back ?}
 
translate N Iresign {Ik geef op}
 
translate N yourmoveisnotgood {Je zet is niet goed}
 
translate N EndOfVar {Eind van variant}
 
translate N Openingtrainer {Opening trainer}
 
translate N DisplayCM {Toon kandidaat zetten}
 
translate N DisplayCMValue {Toon waarde kandidaat zetten}
# ====== TODO To be translated ======
translate N DisplayOpeningStats {Show statistics}
# ====== TODO To be translated ======
translate N ShowReport {Show report}
# ====== TODO To be translated ======
translate N NumberOfGoodMovesPlayed {good moves played}
# ====== TODO To be translated ======
translate N NumberOfDubiousMovesPlayed {dubious moves played}
# ====== TODO To be translated ======
translate N NumberOfMovesPlayedNotInRepertoire {moves played not in repertoire}
# ====== TODO To be translated ======
translate N NumberOfTimesPositionEncountered {times position encountered}
 
translate N PlayerBestMove  {Laat alleen beste zetten toe}
 
translate N OpponentBestMove {Tegenstander speelt beste zetten}
 
translate N OnlyFlaggedLines {Enkel gemarkeerde varianten}
# ====== TODO To be translated ======
translate N resetStats {Reset statistics}
 
translate N Repertoiretrainingconfiguration {Repertorium training configuratie}
 
translate N Loadingrepertoire {Repertorium Laden}
 
translate N Movesloaded {Zetten geladen}
 
translate N Repertoirenotfound {Repertorium niet gevonden}
 
translate N Openfirstrepertoirewithtype {Open eerste repertorium database met ikoon/type aanr rechterzijde gezet}
 
translate N Movenotinrepertoire {Zet niet in Repertorium}
# ====== TODO To be translated ======
translate N PositionsInRepertoire {Positions in repertoire}
# ====== TODO To be translated ======
translate N PositionsNotPlayed {Positions not played}
# ====== TODO To be translated ======
translate N PositionsPlayed {Positions played}
# ====== TODO To be translated ======
translate N Success {Success}
# ====== TODO To be translated ======
translate N DubiousMoves {Dubious moves}
# ====== TODO To be translated ======
translate N OutOfRepertoire {OutOfRepertoire}
  
translate N ConfigureTactics {Configureer takiek}
 
translate N ResetScores {Initialiseer scores}
 
translate N LoadingBase {Laad database}
 
translate N Tactics {Taktiek}
 
translate N ShowSolution {Toon oplossing}
 
translate N Next {Volgende}
 
translate N ResettingScore {Initialiseer score}
 
translate N LoadingGame {Laad partij}
 
translate N MateFound {Mat gevonden}
 
translate N BestSolutionNotFound {Beste oplossing NIET gevonden!}
 
translate N MateNotFound {Mat NIET gevonden}
 
translate N ShorterMateExists {Korter mat bestaat}
 
translate N ScorePlayed {Score gespeeld}
 
translate N Expected {verwacht}
 
translate N ChooseTrainingBase {Kies training base}
 
translate N Thinking {Denkend}
 
translate N AnalyzeDone {Analyse gedaan}
 
translate N WinWonGame {Win gewonnen partij}
 
translate N Lines {Varianten}
 
translate N ConfigureUCIengine {Configureer UCI machiene}
 
translate N SpecificOpening {Specifieke opening}
# ====== TODO To be translated ======
translate N StartNewGame {Start new game}
# ====== TODO To be translated ======
translate N FixedLevel {Fixed level}
# ====== TODO To be translated ======
translate N Opening {Opening}
# ====== TODO To be translated ======
translate N RandomLevel {Random level}
# ====== TODO To be translated ======
translate N StartFromCurrentPosition {Start from current position}
# ====== TODO To be translated ======
translate N FixedDepth {Fixed depth}
# ====== TODO To be translated ======
translate N Nodes {Nodes} 
# ====== TODO To be translated ======
translate N Depth {Depth}
# ====== TODO To be translated ======
translate N Time {Time} 
# ====== TODO To be translated ======
translate N SecondsPerMove {Seconds per move}
# ====== TODO To be translated ======
translate N Engine {Engine}
# ====== TODO To be translated ======
translate N TimeMode {Time mode}
# ====== TODO To be translated ======
translate N TimeBonus {Time + bonus}
# ====== TODO To be translated ======
# ====== TODO To be translated ======
translate N TimeMin {min}
# ====== TODO To be translated ======
translate N TimeSec {sec}
# ====== TODO To be translated ======
# ====== TODO To be translated ======
 
translate N AllExercisesDone {Alle oefeningen gedaan}
 
translate N MoveOutOfBook {Zet buiten boek}
 
translate N LastBookMove {Laatste zet boek}
 
translate N AnnotateSeveralGames {Becommentarieer verschillende partijen \n van huidig tot :}
 
translate N FindOpeningErrors {Vind openingsfouten}
# ====== TODO To be translated ======
translate N MarkTacticalExercises {Mark tactical exercises}
 
translate N UseBook {Gebruik boek}
 
translate N MultiPV {Meerder varianten}
 
translate N Hash {Hash Geheugentabel}
 
translate N OwnBook {Gebruik machiene boek}
 
translate N BookFile {Opening boek}
 
translate N AnnotateVariations {Becommentarieer varianten}
# ====== TODO To be translated ======
translate N ShortAnnotations {Short annotations}
# ====== TODO To be translated ======
translate N addAnnotatorTag {Add annotator tag}
# ====== TODO To be translated ======
translate N AddScoreToShortAnnotations {Add score to short annotations}
 
translate N Export {Export}
 
translate N BookPartiallyLoaded {Boek gedeeltelijk geladen}
# ====== TODO To be translated ======
translate N Calvar {Calculation of variations}
# ====== TODO To be translated ======
translate N ConfigureCalvar {Configuration}
 
 
translate N Reti {Reti}
 
translate N English {Engels}
 
translate N d4Nf6Miscellaneous {1.d4 Nf6 Verscheidene}
 
translate N Trompowsky {Trompowsky}
 
translate N Budapest {Boedapest}
 
translate N OldIndian {Oud Indisch}
 
translate N BenkoGambit {Benko Gambiet}
 
translate N ModernBenoni {Moderne Benoni}
 
translate N DutchDefence {Dutch Defence}
 
translate N Scandinavian {Scandinavian}
 
translate N AlekhineDefence {Alechin Verdediging}
 
translate N Pirc {Pirc}
 
translate N CaroKann {Caro-Kann}
 
translate N CaroKannAdvance {Caro-Kann Doorschuif}
 
translate N Sicilian {Siciliaans}
 
translate N SicilianAlapin {Siciliaans Alapin}
 
translate N SicilianClosed {Siciliaans Gesloten}
 
translate N SicilianRauzer {Siciliaans Rauzer}
 
translate N SicilianDragon {Siciliaans Draak}
 
translate N SicilianScheveningen {Siciliaans Scheveningen}
 
translate N SicilianNajdorf {Siciliaans Najdorf}
 
translate N OpenGame {Open Spel}
 
translate N Vienna {Weens}
 
translate N KingsGambit {Konings Gambiet}
 
translate N RussianGame {Russisch}
 
translate N ItalianTwoKnights {Italiaans/Tweepaardenspel}
 
translate N Spanish {Spaans}
 
translate N SpanishExchange {Spaans Ruil}
 
translate N SpanishOpen {Spaans Open}
 
translate N SpanishClosed {Spaans Gesloten}
 
translate N FrenchDefence {Frans}
 
translate N FrenchAdvance {Frans Doorschuif}
 
translate N FrenchTarrasch {Frans Tarrasch}
 
translate N FrenchWinawer {Frans Winawer}
 
translate N FrenchExchange {Frans Ruil}
 
translate N QueensPawn {Damepion}
 
translate N Slav {Slavisch}
 
translate N QGA {Aangenomen Damegambiet}
 
translate N QGD {Damegambiet}
 
translate N QGDExchange {Damegambiet Ruil}
 
translate N SemiSlav {Half-Slavisch}
 
translate N QGDwithBg5 {Damegambiet met Lg5}
 
translate N QGDOrthodox {Damegambiet Orthodox}
 
translate N Grunfeld {Grünfeld}
 
translate N GrunfeldExchange {Grünfeld Ruil}
 
translate N GrunfeldRussian {Grünfeld Russisch}
 
translate N Catalan {Catalaans}
 
translate N CatalanOpen {Catalaans Open}
 
translate N CatalanClosed {Catalaans Gesloten}
 
translate N QueensIndian {Dameindisch}
 
translate N NimzoIndian {Nimzo-Indisch}
 
translate N NimzoIndianClassical {Nimzo-Indisch Klassiek Dc2}
 
translate N NimzoIndianRubinstein {Nimzo-Indisch Rubinstein}
 
translate N KingsIndian {Koningsindisch}
 
translate N KingsIndianSamisch {Koningsindisch Sämisch}

translate N KingsIndianMainLine {Koningsindisch Hoofdvariant}
# ====== TODO To be translated ======
translate N CCDlgConfigureWindowTitle {Configure Correspondence Chess}
# ====== TODO To be translated ======
translate N CCDlgCGeneraloptions {General Options}
# ====== TODO To be translated ======
translate N CCDlgDefaultDB {Default Database:}
# ====== TODO To be translated ======
translate N CCDlgInbox {Inbox (path):}
# ====== TODO To be translated ======
translate N CCDlgOutbox {Outbox (path):}
# ====== TODO To be translated ======
translate N CCDlgXfcc {Xfcc Configuration:}
# ====== TODO To be translated ======
translate N CCDlgExternalProtocol {External Protocol Handler (e.g. Xfcc)}
# ====== TODO To be translated ======
translate N CCDlgFetchTool {Fetch Tool:}
# ====== TODO To be translated ======
translate N CCDlgSendTool {Send Tool:}
# ====== TODO To be translated ======
translate N CCDlgEmailCommunication {eMail Communication}
# ====== TODO To be translated ======
translate N CCDlgMailPrg {Mail program:}
# ====== TODO To be translated ======
translate N CCDlgBCCAddr {(B)CC Address:}
# ====== TODO To be translated ======
translate N CCDlgMailerMode {Mode:}
# ====== TODO To be translated ======
translate N CCDlgThunderbirdEg {e.g. Thunderbird, Mozilla Mail, Icedove...}
# ====== TODO To be translated ======
translate N CCDlgMailUrlEg {e.g. Evolution}
# ====== TODO To be translated ======
translate N CCDlgClawsEg {e.g Sylpheed Claws}
# ====== TODO To be translated ======
translate N CCDlgmailxEg {e.g. mailx, mutt, nail...}
# ====== TODO To be translated ======
translate N CCDlgAttachementPar {Attachment parameter:}
# ====== TODO To be translated ======
translate N CCDlgInternalXfcc {Use internal Xfcc support}
# ====== TODO To be translated ======
translate N CCDlgSubjectPar {Subject parameter:}
# ====== TODO To be translated ======
translate N CCDlgStartEmail {Start new eMail game}
# ====== TODO To be translated ======
translate N CCDlgYourName {Your Name:}
# ====== TODO To be translated ======
translate N CCDlgYourMail {Your eMail Address:}
# ====== TODO To be translated ======
translate N CCDlgOpponentName {Opponents Name:}
# ====== TODO To be translated ======
translate N CCDlgOpponentMail {Opponents eMail Address:}
# ====== TODO To be translated ======
translate N CCDlgGameID {Game ID (unique):}
# ====== TODO To be translated ======
translate N CCDlgTitNoOutbox {Scid: Correspondence Chess Outbox}
# ====== TODO To be translated ======
translate N CCDlgTitNoInbox {Scid: Correspondence Chess Inbox}
# ====== TODO To be translated ======
translate N CCDlgTitNoGames {Scid: No Correspondence Chess Games}
# ====== TODO To be translated ======
translate N CCErrInboxDir {Correspondence Chess inbox directory:}
# ====== TODO To be translated ======
translate N CCErrOutboxDir {Correspondence Chess outbox directory:}
# ====== TODO To be translated ======
translate N CCErrDirNotUsable {does not exist or is not accessible!\nPlease check and correct the settings.}
# ====== TODO To be translated ======
translate N CCErrNoGames {does not contain any games!\nPlease fetch them first.}
# ====== TODO To be translated ======
translate N CCDlgTitNoCCDB {Scid: No Correspondence Database}
# ====== TODO To be translated ======
translate N CCErrNoCCDB {No Database of type 'Correspondence' is opened. Please open one before using correspondence chess functions.}
# ====== TODO To be translated ======
translate N CCFetchBtn {Fetch games from the server and process the Inbox}
# ====== TODO To be translated ======
translate N CCPrevBtn {Goto previous game}
# ====== TODO To be translated ======
translate N CCNextBtn {Goto next game}
# ====== TODO To be translated ======
translate N CCSendBtn {Send move}
# ====== TODO To be translated ======
translate N CCEmptyBtn {Empty In- and Outbox}
# ====== TODO To be translated ======
translate N CCHelpBtn {Help on icons and status indicators.\nFor general Help press F1!}
# ====== TODO To be translated ======
translate N ExtHWConfigConnection {Configure external hardware}
# ====== TODO To be translated ======
translate N ExtHWPort {Port}
# ====== TODO To be translated ======
translate N ExtHWEngineCmd {Engine command}
# ====== TODO To be translated ======
translate N ExtHWEngineParam {Engine parameter}
# ====== TODO To be translated ======
translate N ExtHWShowButton {Show button}
# ====== TODO To be translated ======
translate N ExtHWHardware {Hardware}
# ====== TODO To be translated ======
translate N ExtHWNovag {Novag Citrine}
# ====== TODO To be translated ======
translate N ExtHWInputEngine {Input Engine}
# ====== TODO To be translated ======
translate N ExtHWNoBoard {No board}
# ====== TODO To be translated ======
translate N IEConsole {Input Engine Console}
# ====== TODO To be translated ======
translate N IESending {Moves sent for}
# ====== TODO To be translated ======
translate N IESynchronise {Synchronise}
# ====== TODO To be translated ======
translate N IERotate  {Rotate}
# ====== TODO To be translated ======
translate N IEUnableToStart {Unable to start Input Engine:}
# ====== TODO To be translated ======
translate N DoneWithPosition {Done with position}
# ====== TODO To be translated ======
translate N Board {Board}
# ====== TODO To be translated ======
translate N showGameInfo {Show game info}
# ====== TODO To be translated ======
translate N autoResizeBoard {Automatic resize of board}
# ====== TODO To be translated ======
translate N DockTop {Move to top}
# ====== TODO To be translated ======
translate N DockBottom {Move to bottom}
# ====== TODO To be translated ======
translate N DockLeft {Move to left}
# ====== TODO To be translated ======
translate N DockRight {Move to right}
# ====== TODO To be translated ======
translate N Undock {Undock}
# ====== TODO To be translated ======
}
# End of nederlan.tcl


























