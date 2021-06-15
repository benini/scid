# catalan.tcl:
# Catalan translation for Scid
# Contributed by Natalia Pares Vives (natalia%paresvives.net)
# Date: 2009-04-07
# Version: 1

proc setLanguage_K {} {

# File menu:
menuText K File "Arxiu" 0
menuText K FileNew "Nova..." 0 {Crea una nova base de dades Scid buida}
menuText K FileOpen "Obrir..." 1 {Obre una base de dades Scid existent}
menuText K FileClose "Tancar" 0 {Tanca la base de dades Scid activa}
menuText K FileFinder "Visor..." 0 {Obre la finestra del visor d'arxius}
menuText K FileBookmarks "Partides preferides" 0 {Seleccionar partides preferides (Ctrl+B)}
menuText K FileBookmarksAdd "Afegir" 0 \
  {Marca la partida i posici� actual de la base de dades}
menuText K FileBookmarksFile "Arxivar" 8 \
  {Arxiva un marcador de la partida i posici� actuals}
menuText K FileBookmarksEdit "Editar partides preferides..." 0 \
  {Edita els men�s de les partides preferides}
menuText K FileBookmarksList "Mostrar partides preferides" 0 \
  {Mostra les carpetes preferides a una sola llista, sense submen�s}
menuText K FileBookmarksSub "Mostrar partides marcades amb submen�s" 0 \
  {Mostrar les carpetes preferides com submen�s, no a una sola llista}
menuText K FileMaint "Manteniment" 0 \
  {Eines de manteniment de bases de dades Scid}
menuText K FileMaintWin "Finestra de manteniment" 0 \
  {Obre/tanca la finestra de manteniment de bases de dades Scid}
menuText K FileMaintCompact "Compactar base de dades..." 0 \
  {Compacta els arxius de la base de dades, treient-hi partides esborrades i noms sense utilitzar}
menuText K FileMaintClass "Classificar partides per ECO..." 24 \
  {Recalcula el codi ECO de totes les partides}
menuText K FileMaintSort "Ordenar base de dades..." 0 \
  {Ordena totes les partides de la base de dades}
menuText K FileMaintDelete "Esborrar partides duplicades..." 0 \
  {Cerca partides duplicades i les marca per ser esborrades}
menuText K FileMaintTwin "Finestra d'inspecci� de duplicades" 11 \
  {Obre/actualiza la finestra d'inspecci� de duplicades}
menuText K FileMaintName "Ortografia de noms" 0 {Eines d'ortografia i edici� de noms}
menuText K FileMaintNameEditor "Finestra d'edici� de noms" 22 \
  {Obre/tanca la finestra d'edici� de noms}
menuText K FileMaintNamePlayer "Comprovaci� ortogr�fica de noms de jugadors..." 39 \
  {Comprovaci� ortogr�fica de jugadors fent servir un arxiu de comprovaci� ortogr�fica}
menuText K FileMaintNameEvent "Comprovaci� ortogr�fica de noms de torneigs..." 39 \
  {Comprovaci� ortogr�fica de torneigs fent servir l'arxiu de comprovaci� ortogr�fica}
menuText K FileMaintNameSite "Comprovaci� ortogr�fica de noms de llocs..." 39 \
  {Comprovaci� ortogr�fica de llocs fent servir l'arxiu de comprovaci� ortogr�fica}
menuText K FileMaintNameRound "Comprovaci� ortogr�fica de rondes..." 28 \
  {Comprovaci� ortogr�fica de rondes fent servir l'arxiu de comprovaci� ortogr�fica}
menuText K FileReadOnly "Nom�s de lectura..." 5 \
  {Tracta la actual base de dades com nom�s de lectura, prevenint canvis}
menuText K FileSwitch "Canviar de base de dades" 0 \
  {Canvia a una base de dades oberta diferent}
menuText K FileExit "Sortir" 0 {Sortir de Scid}
menuText K FileMaintFixBase "Arreglar base corrupta" 0 {Intenta arreglar una base corrupta}

# Edit menu:
menuText K Edit "Editar" 0
menuText K EditAdd "Afegir variant" 0 \
  {Afegeix una variant amb aquesta jugada a la partida}
menuText K EditDelete "Esborrar variant" 0 {Esborra la variant d'aquesta jugada}
menuText K EditFirst "Convertir a primera variant" 0 \
  {Fa que una variant sigui la primera a la llista}
menuText K EditMain "Variant a l�nia principal" 0 \
   {Promou una variant per a que sigui la l�nia principal}
menuText K EditTrial "Provar variant" 1 \
  {Inicia/Atura el mode de prova, per a verificar una idea a l'escaquer}
menuText K EditStrip "Eliminar" 2 \
  {Eliminar comentaris o variants d'aquesta partida}
# ====== TODO To be translated ======
menuText K EditUndo "Undo" 0 {Undo last game change}
# ====== TODO To be translated ======
menuText K EditRedo "Redo" 0 {Redo last game change}
menuText K EditStripComments "Comentaris" 0 \
  {Treu tots els comentaris i variants d'aquesta partida}
menuText K EditStripVars "Variants" 0 {Treu totes les variants d'aquesta partida}
menuText K EditStripBegin "Jugades des del comen�ament" 1 \
  {Treu els moviments des del comen�ament de la partida}
menuText K EditStripEnd "Jugades fins el final" 0 \
  {Treu els moviments fins el final de la partida}
menuText K EditReset "Posa a zero la base de treball" 0 \
  {Posa a zero la base de treball (clipbase) per deixar-la completament bu�da}
menuText K EditCopy "Copiar aquesta partida a la base de treball" 1 \
  {Copia aquesta partida a la base de treball (clipbase)}
menuText K EditPaste "Pegar l'�ltima partida de la base de treball" 2 \
  {Pega al final de la base actual la partida activa de la base de treball (clipbase)}
menuText K EditPastePGN "Pega el text del Clipboard com una partida PGN..." 10 \
  {Interpreta el text de la base de treball (clipbase) com una partida en notaci� PGN i la pega}
menuText K EditSetup "Iniciar posici� a l'escaquer..." 26 \
  {Inicia una posici� a l'escaquer amb la posici� de la partida}
menuText K EditCopyBoard "Copiar posici�" 8 \
  {Copia l'escaquer actual en notaci� FEN a la selecci� de text (clipboard)}
menuText K EditPasteBoard "Pegar escaquer inicial" 6 \
  {Posa l'escaquer inicial des de la selecci� de text actual (clipboard)}
# ====== TODO To be translated ======
menuText K ConfigureScid "Preferences..." 0 {Configure all options for SCID}

# Game menu:
menuText K Game "Partida" 0
menuText K GameNew "Nova partida" 0 \
  {Nova partida, descarta canvis de la partida actual}
menuText K GameFirst "Cargar primera partida" 7 {Carga la primera partida filtrada}
menuText K GamePrev "Cargar partida anterior" 16 {Carga la anterior partida filtrada}
menuText K GameReload "Recargar partida actual" 0 \
  {Torna a carregar aquesta partida, descartant qualsevol canvi introdu�t}
menuText K GameNext "Carga seguent partida " 7 {Carga la seguent partida filtrada}
menuText K GameLast "Cargar �ltima partida" 9 {Carga la �ltima partida filtrada}
menuText K GameRandom "Cargar partida aleat�ria" 16 {Carga aleat�riamente una partida filtrada}
menuText K GameNumber "Cargar partida n�mero..." 3 \
  {Carga una partida possant el seu n�mero}
menuText K GameReplace "Salvar: Reempla�a la partida..." 10 \
  {Salva aquesta partida, reempla�ant la versi� anterior}
menuText K GameAdd "Salvar: Afegir nova partida..." 9 \
  {Enregistra aquesta partida com una nova partida a la base de dades}
menuText K GameDeepest "Identificar obertura" 1 \
  {Va a la posici� m�s avan�ada de la partida d'acord amb el llibre ECO}
menuText K GameGotoMove "Anar a la jugada n�mero..." 6 \
  {Anar al n�mero de jugada especificat dins la partida actual}
menuText K GameNovelty "Trovar Novetat..." 12 \
  {Cerca la primera jugada d'aquesta partida que no s'ha jugat abans}

# Search Menu:
menuText K Search "Cercar" 0
menuText K SearchReset "Posar a zero el filtre" 0 \
  {Posa a zero el filtre per incloure-hi totes les partides}
menuText K SearchNegate "Invertir filtre" 0 \
  {Inverteix el filtre per incloure nom�s les partides pr�viament excloses}
menuText K SearchCurrent "Escaquer actual..." 0 \
  {Cerca per la posici� actual de l'escaquer}
menuText K SearchHeader "Encap�alament..." 0 \
  {Cerca per la informaci� de l'encap�alament (jugador, torneig, etc)}
menuText K SearchMaterial "Material/Patr�..." 0 \
  {Cerca a l'escaquer per material o patr�}
menuText K SearchUsing "Fer servir arxiu de recerca..." 0 \
  {Cerca fent servir un arxiu d'opcions de recerca}

# Windows menu:
menuText K Windows "Finestres" 0
menuText K WindowsComment "Editor de comentaris" 0 \
  {Obre/tanca l'editor de comentaris}
menuText K WindowsGList "Llistat de partides" 0 \
  {Obre/tanca la  finestra de llistat de partides}
menuText K WindowsPGN "Finestra PGN" 8 \
  {Obre/tanca la finestra PGN (notaci� de partida)}
menuText K WindowsPList "Cercador de jugadors" 2 {Obre/tanca el cercador de jugadors}
menuText K WindowsTmt "Visor de Torneigs" 9 {Obre/tanca el visor de torneigs}
menuText K WindowsSwitcher "Bescanviador de bases de dades" 0 \
  {Obre/tanca la finestra del bescanviador de bases de dades}
menuText K WindowsMaint "Finestra de manteniment" 11 \
  {Obre/tanca la finestra de manteniment}
menuText K WindowsECO "Cercador ECO" 0 {Obre/tanca la finestra del cercador ECO}
menuText K WindowsStats "Finestra d'estad�stiques" 12 \
  {Obre/tanca la finestra d'estad�stiques del filtre}
menuText K WindowsTree "Finestra de l'�rbre d'Obertures" 6 {Obre/tanca la finestra de l'�rbre d'Obertures (Book)}
menuText K WindowsTB "Finestra de Taules de Finals (TBs)" 8 \
  {Obre/tanca la finestra de TBs}
menuText K WindowsBook "Finestra de Llibres d'Obertures" 0 {Obrir/Tancar la finestra de Llibres d'Obertures (Book)}
menuText K WindowsCorrChess "Finestra d'Escacs Postal" 0 {Obrir/Tancar la Finestra d'Escacs Postal}

# Tools menu:
menuText K Tools "Eines" 0
menuText K ToolsAnalysis "Motor d'an�lisi..." 0 \
  {Inicia/Atura un motor d'an�lisi d'escacs}
menuText K ToolsAnalysis2 "Motor d'an�lisi #2..." 18 \
  {Inicia/Atura el segon motor d'an�lisi d'escacs}
menuText K ToolsCross "Quadre" 0 {Mostra el Quadre del torneig per aquesta partida}
menuText K ToolsEmail "Gestor d'Emails" 0 \
  {Obre/tanca la finestra del Gestor d'Emails}
menuText K ToolsFilterGraph "Filtre Gr�fic Rel." 7 \
  {Obre/tanca la finestra del filtre gr�fic per valors relatius}
menuText K ToolsAbsFilterGraph "Filtre gr�fic Abs." 7 {Obrir/Tancar la finestra de filtre gr�fic per valors absoluts}
menuText K ToolsOpReport "Informe d'obertura" 1 \
  {Crea un informe de l'obertura per la posici� actual}
menuText K ToolsOpenBaseAsTree "Obrir base com arbre" 0   {Obrir una base i utilitzar-la a la Finestre Arbre (Tree)}
menuText K ToolsOpenRecentBaseAsTree "Obrir base recent com arbre" 0   {Obre una base recent i la utilitza a la Finestra Arbre (Tree)} 
menuText K ToolsTracker "Rastrejadorr de peces"  14 {Obre la finestra del rastrejador de peces}
menuText K ToolsTraining "Entrenament"  0 {Entrenament (t�ctica, obertures,...}
menuText K ToolsTacticalGame "Partida T�ctica"  0 {Jugar una partida t�ctica}
menuText K ToolsSeriousGame "Partida seriosa"  0 {Jugar una partida seriosa}
menuText K ToolsTrainOpenings "Obertures"  0 {Entrenament amb un repertori}
# ====== TODO To be translated ======
menuText K ToolsTrainReviewGame "Review game"  0 {Guess moves played in a game}
menuText K ToolsTrainTactics "T�ctica"  0 {Resoldre problemes de t�ctica}
menuText K ToolsTrainCalvar "C�lcul de variants"  0 {C�lcul de variants}
menuText K ToolsTrainFindBestMove "Trobar la millor jugada"  0 {Cerca la millor jugada}
menuText K ToolsTrainFics "Jugar a Internet"  0 {Jugar a freechess.org}
# ====== TODO To be translated ======
menuText K ToolsEngineTournament "Engine tournament"  0 {Start a tournament between chess engines}
menuText K ToolsBookTuning "Ajustar Llibre d'obertures" 0 {Ajustar Llibre (Book)}
menuText K ToolsConnectHardware "Connectar maquinari" 0 {Connectar maquinari extern}
menuText K ToolsConnectHardwareConfigure "Configuraci�" 1 {Configuraci�}
menuText K ToolsConnectHardwareNovagCitrineConnect "Connectar Novag" 0 {Connectar Novag}
menuText K ToolsConnectHardwareInputEngineConnect "Connectar dispositiu d'entrada" 0 {Connectar dispositiu d'entrada (com el de DGT) a Scid}
menuText K ToolsPInfo "Informaci� del Jugador" 16 \
  {Obrir/actualitzar la finestra d'Informaci� del Jugador}
menuText K ToolsPlayerReport "Informe del jugador..." 3 \
  {Crea un informe sobre un jugador}
menuText K ToolsRating "Gr�fic de l'Elo" 0 \
  {Gr�fic del historial Elo dels jugadors de la partida actual}
menuText K ToolsScore "Gr�fic de puntuaci�" 1 \
  {Mostra la finestra del gr�fic de puntuaci�}
menuText K ToolsExpCurrent "Exportar la partida actual" 0 \
  {Escriu la partida actual a un arxiu de text}
menuText K ToolsExpCurrentPGN "Exportar la partida a un arxiu PGN..." 33 \
  {Escriu la partida actual a un arxiu PGN}
menuText K ToolsExpCurrentHTML "Exportar la partida a un arxiu HTML..." 33 \
  {Escriu la partida actual a un arxiu HTML}
menuText K ToolsExpCurrentHTMLJS "Exportar la partida a un arxiu HTML i JavaScript..." 15 {Escriu la partida actual a un arxiu HTML i JavaScript} 
menuText K ToolsExpCurrentLaTeX "Exportar la partida a un arxiu LaTeX..." 33 \
  {Escriu la partida actual a un arxiu LaTeX}
menuText K ToolsExpFilter "Exportar totes les partides filtrades" 1 \
  {Escriu totes les partides filtrades a un arxiu de text}
menuText K ToolsExpFilterPGN "Exportar filtre a un arxiu PGN..." 29 \
  {Escriu totes les partides filtrades a un arxiu PGN}
menuText K ToolsExpFilterHTML "Exportar filtre a un arxiu HTML..." 29 \
  {Escriu totes les partides filtrades a un arxiu HTML}
menuText K ToolsExpFilterHTMLJS "Exportar filtre a un arxiu HTML i JavaScript..." 17 {Escriu totes les partides filtrades a un arxiu HTML i JavaScript}  
menuText K ToolsExpFilterLaTeX "Exportar filtre a un arxiu LaTeX..." 29 \
  {Escriu totes les partides filtrades a un arxiu LaTeX}
menuText K ToolsImportOne "Importar una partida PGN..." 0 \
  {Importa una partida de un text PGN}
menuText K ToolsImportFile "Importar un arxiu de partides PGN..." 2 \
  {Importa partides de un arxiu PGN}
menuText K ToolsStartEngine1 "Iniciar motor 1" 0  {Iniciar motor 1}
menuText K ToolsStartEngine2 "Iniciar motor 2" 0  {Iniciar Motor 2}
# ====== TODO To be translated ======
menuText K ToolsCaptureBoard "Capture Current Board..." 0  {Save the current board as an image.}
menuText K Play "Jugar" 0
menuText K CorrespondenceChess "Escacs Postal" 0 {Funcions d'Escacs Postal per a eMail i Xfcc}
menuText K CCConfigure "Configurar..." 0 {Configurar eines externes i Par�metres Generals}
# ====== TODO To be translated ======
menuText K CCConfigRelay "Configure observations..." 10 {Configure games to be observed}
menuText K CCOpenDB "Obrir base de dades..." 0 {Obrir la base per defecte d'Escac Postal}
menuText K CCRetrieve "Recuperar partides" 0 {Recuperar partides via programari extern (Xfcc)}
menuText K CCInbox "Processa B�stia D'Entrada" 0 {Processar tots els registres de la b�stia d'entrada (Inbox) d'Scid }
menuText K CCSend "Enviar jugada" 0 {Envia la teva jugada via EMail o amb programari extern (Xfcc)}
menuText K CCResign "Abandonar" 0 {Abandonar}
menuText K CCClaimDraw "Reclamar taules" 0 {Enviar un jugada i reclamar taules}
menuText K CCOfferDraw "Oferir taules" 0 {Enviar un jugada i oferir taules}
menuText K CCAcceptDraw "Acceptar taules" 0 {Acceptar un oferiment de taules}
menuText K CCNewMailGame "Nova partida per email..." 0 {Iniciar una nova partida eMail}
menuText K CCMailMove "Enviar jugada via email..." 0 {Envia la jugada via EMail al contrari}
menuText K CCGamePage "P�gina de la partida..." 0 {Obrir la partida al navegador}
# ====== TODO To be translated ======
menuText K CCEditCopy "Copy Gamelist to Clipbase" 0 {Copy the games as CSV list to clipbase}

# Options menu:
menuText K Options "Opcions" 0
menuText K OptionsBoardGraphics "Casselles..." 0 {Escollir textures per les casselles}
translate K OptionsBGW {Escollir textura per les casselles}
translate K OptionsBoardGraphicsText {Escollir arxiu gr�fic per casselles blanques i negres}
menuText K OptionsBoardNames "Els meus noms..." 0 {Edita els noms en que pot apar�ixer un jugador}
menuText K OptionsExport "Exportaci�" 0 {Canvia les opciones d'exportaci� de text}
menuText K OptionsFonts "Fonts" 0 {Canvia les fonts}
menuText K OptionsFontsRegular "Habitual" 0 {Canvia la font habitual}
menuText K OptionsFontsMenu "Men�" 0 {Canvia la font del men�}
menuText K OptionsFontsSmall "Petita" 0 {Canvia la font petita}
# ====== TODO To be translated ======
menuText K OptionsFontsTiny "Tiny" 0 {Change the tiny font}
menuText K OptionsFontsFixed "Fixa" 0 {Canvia la amplada de la font a fixa}
menuText K OptionsGInfo "Informaci� de la partida" 0 {Informaci� de la partida}
menuText K OptionsLanguage "Llenguatge" 0 {Selecciona el llenguatge del programa}
menuText K OptionsMovesTranslatePieces "Tradueix peces" 0 {Tradueix la primera lletra de les peces}
# ====== TODO To be translated ======
menuText K OptionsMovesHighlightLastMove "Highlight last move" 0 {Highlight last move}
# ====== TODO To be translated ======
menuText K OptionsMovesHighlightLastMoveDisplay "Show" 0 {Display last move Highlight}
# ====== TODO To be translated ======
menuText K OptionsMovesHighlightLastMoveWidth "Width" 0 {Thickness of line}
# ====== TODO To be translated ======
menuText K OptionsMovesHighlightLastMoveColor "Color" 0 {Color of line}
# ====== TODO To be translated ======
menuText K OptionsMovesHighlightLastMoveArrow "include Arrow" 0 {Include Arrow with Highlight}
menuText K OptionsMoves "Jugades" 0 {Opcions d'entrada de jugades}
menuText K OptionsMovesAnimate "Velocitat d'animaci�" 1 \
  {Posa el temps d'animaci� entre jugades}
menuText K OptionsMovesDelay "Retard de la jugada autom�tica..." 0 \
  {Posa el temps de retard per la modalitat de autojugada}
menuText K OptionsMovesCoord "Entrada de jugades per coordenades" 0 \
  {Accepta entrada de jugades pel sistema de "coordenades" ("g1f3")}
menuText K OptionsMovesSuggest "Mostrar suggeriments" 20 \
  {Activa/desactiva el suggeriment de jugades}
menuText K OptionsShowVarPopup "Mostrar finestra de variants" 0 {Activar/Desactivar la finestra de variants}
menuText K OptionsMovesSpace "Afegir espai despr�s del n�mero de jugada" 0 {Afegir espai despr�s del n�mero de jugada}  
menuText K OptionsMovesKey "Teclat Intel�ligent" 0 \
{Activa/desactiva la funci� d'autocompletat intel�ligent de jugades amb teclat}
# ====== TODO To be translated ======
menuText K OptionsMovesShowVarArrows "Show Arrows for Variations" 0 {Turn on/off arrows showing moves in variations}
# ====== TODO To be translated ======
menuText K OptionsMovesGlossOfDanger "Color Coded Gloss of Danger" 0 {Turn on/off color coded gloss of danger}
menuText K OptionsNumbers "Format de n�meros" 11 {Selecciona el format de n�meros}
menuText K OptionsTheme "Tema" 0 {Canviar l'aspecte del programari}
menuText K OptionsWindows "Finestres" 0 {Opcions de finestra}
menuText K OptionsSounds "Sons" 2 {Configura el so d'anunci de les jugades}
# ====== TODO To be translated ======
menuText K OptionsResources "Resources..." 0 {Choose resource files and folders}
menuText K OptionsWindowsDock "Bloqueja finestres" 0 {Bloqueja i agrupa finestres}
menuText K OptionsWindowsSaveLayout "Salvar disposici�" 0 {Salvar disposici�}
menuText K OptionsWindowsRestoreLayout "Restaurar disposici�" 0 {Restaurar disposici�}
menuText K OptionsWindowsShowGameInfo "Mostrar informaci� de la partida" 0 {Mostrar informaci� de la partida}
menuText K OptionsWindowsAutoLoadLayout "Auto cargar primera disposici�" 0 {Autocargar primera disposici� en comen�ar}
menuText K OptionsECO "Cargar arxiu ECO..." 7 \
  {Cargar l'arxiu de clasificaci� ECO}
menuText K OptionsSpell "Cargar arxiu de comprovaci� ortogr�fica..." 2 \
  {Carga l'arxiu de comprovaci� ortogr�fica Scid}
menuText K OptionsTable "Directori de les TB...(Taules de finals)" 19 \
  {Selecciona el directori de finals; s'utilitzaran totes les TB d'aquest directori}
menuText K OptionsRecent "Arxius recents..." 9 \
  {Canvia el nombre d'arxius recentes que es mostren al men� Arxiu}
menuText K OptionsBooksDir "Carpeta de llibres d'obertures..." 0 {Fixa la carpeta d'els llibres d'obertures (Books)}
menuText K OptionsTacticsBasesDir "Carpeta de bases de dades..." 0 {Fixa la carpeta de la base d'entrenament t�ctic}
# ====== TODO To be translated ======
menuText K OptionsPhotosDir "Photos directory..." 0 {Sets the photos bases directory}
# ====== TODO To be translated ======
menuText K OptionsThemeDir "Theme(s) File:"  0 { Load a GUI theme package file }
menuText K OptionsSave "Salvar opcions" 0 \
  {Salva totes les opcions a l'arxiu $::optionsFile}
menuText K OptionsAutoSave "Autoguardar opcions en sortir" 0 \
  {Guarda autom�ticament totes les opcions quan es surt de Scid}

# Help menu:
menuText K Help "Ajut" 1
menuText K HelpContents "Continguts" 0 {Mostra la p�gina de continguts de l'ajut}
menuText K HelpIndex "Index" 0 {Mostra la p�gina �ndex de l'ajut}
menuText K HelpGuide "Guia r�pida" 0 {Mostra la p�gina guia r�pida de l'ajut}
menuText K HelpHints "Suggeriments" 1 {Mostra la p�gina de suggeriments de l'ajut}
menuText K HelpContact "Informaci� de contacte" 15 \
  {Mostra la p�gina d'informaci� de contacte de l'ajut}
menuText K HelpTip "Suggeriment del dia" 0 {Mostra un pr�ctic suggerimentent de Scid}
menuText K HelpStartup "Finestra d'inici" 0 {Mostra la finestra d'inici}
menuText K HelpAbout "Al voltant de Scid" 10 {Informaci� al voltant de Scid}

# Game info box popup menu:
menuText K GInfoHideNext "Ocultar seg�ent jugada" 0
menuText K GInfoMaterial "Mostrar valor del material" 0
menuText K GInfoFEN "Mostrar FEN" 8
menuText K GInfoMarks "Mostrar casselles i fletxes de colors" 29
menuText K GInfoWrap "Dividir l�nies llargues" 0
menuText K GInfoFullComment "Mostrar comentaris complets" 8
menuText K GInfoPhotos "Mostrar fotografies" 5
menuText K GInfoTBNothing "TBs: res" 5
menuText K GInfoTBResult  "TBs: nom�s resultat" 10
menuText K GInfoTBAll "TBs: resultat i millor jugada" 23
menuText K GInfoDelete "(No)Esborrar aquesta partida" 4
menuText K GInfoMark "(No)Marcar aquesta partida" 4
menuText K GInfoInformant "Configurar valors d'informaci�" 0

# General buttons:
translate K Back {Enrera}
translate K Browse {Mirar}
translate K Cancel {Cancel�lar}
translate K Continue {Continuar}
translate K Clear {Netejar}
translate K Close {Tancar}
translate K Contents {Continguts}
translate K Defaults {Per defecte}
translate K Delete {Esborrar}
translate K Graph {Gr�fic}
translate K Help {Ajut}
translate K Import {Importar}
translate K Index {�ndex}
translate K LoadGame {Cargar partida}
translate K BrowseGame {Mirar partida}
translate K MergeGame {Incorporar partida}
translate K MergeGames {Barrejar o fusionar partides}
translate K Preview {Vista pr�via}
translate K Revert {Retrocedir}
translate K Save {Salvar}
translate K Search {Cercar}
translate K Stop {Aturar}
translate K Store {Enregistrar}
translate K Update {Actualitzar}
translate K ChangeOrient {Canviar l'orientaci� de la finestra}
translate K ShowIcons {Mostra Icones} 
translate K None {Cap}
translate K First {Primera}
translate K Current {Actual}
translate K Last {�ltima}

# General messages:
translate K game {partida}
translate K games {partides}
translate K move {jugada}
translate K moves {jugades}
translate K all {tod}
translate K Yes {S�}
translate K No {No}
translate K Both {Ambdos}
translate K King {Rei}
translate K Queen {Dama}
translate K Rook {Torre}
translate K Bishop {Alfil}
translate K Knight {Cavall}
translate K Pawn {Pe�}
translate K White {Blanques}
translate K Black {Negres}
translate K Player {Jugador}
translate K Rating {Elo}
translate K RatingDiff {Difer�ncia d'Elo (Blanques - Negres)}
translate K AverageRating {Elo promig}
translate K Event {Torneig}
translate K Site {Lloc}
translate K Country {Pais}
translate K IgnoreColors {Ignorar colors}
translate K Date {Data}
translate K EventDate {Data del torneig}
translate K Decade {D�cada}
translate K Year {Any}
translate K Month {Mes}
translate K Months {gener febrer mar� abril maig juny juliol agost setembre octubre novembre desembre}
translate K Days {diu dil dim dic dij div dis}
translate K YearToToday {Any fins avui}
# ====== TODO To be translated ======
translate K YearToTodayTooltip {Set date from 1 year back to today}
translate K Result {Resultat}
translate K Round {Ronda}
translate K Length {Longitut}
translate K ECOCode {Codi ECO}
translate K ECO {ECO}
translate K Deleted {Esborrar}
translate K SearchResults {Cercar resultats}
translate K OpeningTheDatabase {Obrint base de dades}
translate K Database {Base de dades}
translate K Filter {Filtre}
translate K noGames {no hi ha partides}
translate K allGames {totes les partides}
translate K empty {buida}
translate K clipbase {clipbase}
translate K score {puntuaci�}
translate K StartPos {Posici� inicial}
translate K Total {Total}
translate K readonly {nom�s de lectura}

# Standard error messages:
translate K ErrNotOpen {La base de dades no est� oberta.}
translate K ErrReadOnly {Aquesta base de dades es nom�s de lectura; no pot ser modificada.}
translate K ErrSearchInterrupted {Recerca aturada; els resultats den ser incomplets.}

# Game information:
translate K twin {doble}
translate K deleted {esborrades}
translate K comment {comentari}
translate K hidden {ocult}
translate K LastMove {�ltima jugada}
translate K NextMove {Seguent}
translate K GameStart {Inici de partida}
translate K LineStart {Inici de l�nia}
translate K GameEnd {Final de partida}
translate K LineEnd {Final de l�nia}

# Player information:
translate K PInfoAll {Resultats per <b>totes</b> les partides}
translate K PInfoFilter {Resultats per les partides <b>filtrades</b>}
translate K PInfoAgainst {Resultats en contra}
translate K PInfoMostWhite {Obertures m�s comuns amb Blanques}
translate K PInfoMostBlack {Obertures m�s comuns amb Negres}
translate K PInfoRating {Historial de classificaci�}
translate K PInfoBio {Biografia}
translate K PInfoEditRatings {Editar elos}
# ====== TODO To be translated ======
translate K PInfoEloFile {File}

# Tablebase information:
translate K Draw {Taules}
translate K stalemate {Ofegat}
translate K withAllMoves {amb totes les jugades}
translate K withAllButOneMove {amb totes les jugades menys una}
translate K with {amb}
translate K only {nom�s}
translate K lose {maneres de perdre}
translate K loses {fa perdre}
translate K allOthersLose {tots les dem�s perden}
translate K matesIn {mat a}
translate K hasCheckmated {escac i mat}
translate K longest {el mat m�s llarg}
translate K WinningMoves {Jugades guanyadores}
translate K DrawingMoves {Jugades per taules}
translate K LosingMoves {Jugades perdedores}
translate K UnknownMoves {Jugades de resultat desconegut}
# ====== TODO To be translated ======
translate K SideLongest {Side    Longest    %     %     %\n}
# ====== TODO To be translated ======
translate K toNoveMate {to move   mate    Win  Draw  Loss\n}
# ====== TODO To be translated ======
translate K NoSummary {\nNo summary for this tablebase.}
# ====== TODO To be translated ======
translate K MutualZugzwang {Mutual zugzwangs: }
# ====== TODO To be translated ======
translate K SelectetZugzwang {\nSelected zugzwang positions:}
# ====== TODO To be translated ======
translate K WdrawBloss {White draws, Black loses:}
# ====== TODO To be translated ======
translate K BdrawWloss {Black draws, White loses:}
# ====== TODO To be translated ======
translate K AllLoss {" Whoever moves loses:     " }

# Tip of the day:
translate K Tip {Suggeriment}
translate K TipAtStartup {Suggeriment en comen�ar}

# Tree window men�s:
menuText K TreeFile "Arxiu" 0
menuText K TreeFileFillWithBase "Omplir mem�ria cau amb base" 0 {Omplir la mem�ria cau amb totes les partides de la base actual}
menuText K TreeFileFillWithGame "Omplir mem�ria cau amb partida" 0 {Omple la mem�ria cau amb la partida actual de la base actual}
menuText K TreeFileSetCacheSize "Tamany de mem�ria cau" 0 {Estableix el tamany del mem�ria cau}
menuText K TreeFileCacheInfo "Informaci� de mem�ria cau" 0 {Informaci� i �s de la mem�ria cau}
menuText K TreeFileSave "Salvar arxiu mem�ria cau" 0 \
  {Salva l'arxiu mem�ria cau de l'arbre (.stc)}
menuText K TreeFileFill "Construir arbre a la mem�ria cau" 2 \
  {Construir arxiu mem�ria cau amb posiciones d'obertura comunes}
menuText K TreeFileBest "Llista de millors partides" 9 {Mostra la llista de l'arbre amb les millors partides}
menuText K TreeFileGraph "Finestra gr�fica de l'arbre" 0 \
  {Mostra un gr�fic per aquesta branca de l'arbre}
menuText K TreeFileCopy "Copiar text de l'arbre al clipboard" 1 \
  {Copiar text de l'arbre al clipboard}
menuText K TreeFileClose "Tancar finestra de l'arbre" 0 \
  {Tancar finestra de l'arbre}
menuText K TreeMask "M�scara" 0
menuText K TreeMaskNew "Nova" 0 {Nova m�scara}
menuText K TreeMaskOpen "Obrir" 0 {Obrir m�scara}
# ====== TODO To be translated ======
menuText K TreeMaskOpenRecent "Open recent" 0 {Open recent mask}
menuText K TreeMaskSave "Salvar" 0 {Salvar m�scara}
menuText K TreeMaskClose "Tancar" 0 {Tancar m�scara}
menuText K TreeMaskFillWithGame "Omplir amb partida" 0 {Omple la m�scara amb la partida}
menuText K TreeMaskFillWithBase "Omplir amb base" 0 {Omple la m�scara amb totes les partides de la base}
menuText K TreeMaskInfo "Info" 0 {Mostra estad�stiques per la m�scara actual}
# ====== TODO To be translated ======
menuText K TreeMaskDisplay "Display mask map" 0 {Show mask data in a tree form}
# ====== TODO To be translated ======
menuText K TreeMaskSearch "Search" 0 {Search in current mask}
menuText K TreeSort "Ordenar" 0
menuText K TreeSortAlpha "Alfab�ticament" 0
menuText K TreeSortECO "Per codi ECO" 11
menuText K TreeSortFreq "Per freq�encia" 4
menuText K TreeSortScore "Per puntuaci�" 4
menuText K TreeOpt "Opcions" 1
menuText K TreeOptSlowmode "Mode Lent" 0 {Jugada lenta per actualitzacions (Alta qualitat)}
menuText K TreeOptFastmode "Mode R�pid" 0 {Jugada r�pida per actualitzacions (no trasllada jugades)}
menuText K TreeOptFastAndSlowmode "Mode R�pid i Lent" 0 {Jugada r�pida i mode lent per actualitzacions}
menuText K TreeOptStartStop "Auto actualitzat" 0 {Actualizat autom�tic de la finestra de l'arbre}
menuText K TreeOptLock "Bloquejar" 1 {Bloqueja/desbloqueja l'arbre de la base de dades actual}
menuText K TreeOptTraining "Entrenament" 2 {Activa/desactiva el mode d'entrenament de l'arbre}
menuText K TreeOptAutosave "Autoguardar arxiu mem�ria cau" 0 \
  {Salvar autom�ticamente l'arxiu mem�ria cau quan es tanca la finestra de l'arbre}
menuText K TreeHelp "Ajut" 1
menuText K TreeHelpTree "Ajut de l'arbre" 4
menuText K TreeHelpIndex "�ndex de l'ajut" 0
translate K SaveCache {Salvar mem�ria cau}
translate K Training {Entrenament}
translate K LockTree {Bloquejar}
translate K TreeLocked {Bloquejat}
translate K TreeBest {Millor}
translate K TreeBestGames {Millors partides de l'arbre}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate K TreeTitleRow \
  {    Movim. ECO       Freq�encia   Puntu. EloPm Perf AnyPm %Taules}
translate K TreeTotal {TOTAL}
translate K DoYouWantToSaveFirst {Vols salvar-ho abans}
translate K AddToMask {Afegir a m�scara}
translate K RemoveFromMask {Elimina des de la m�scara}
translate K AddThisMoveToMask {Afegir aquesta jugada a la M�scara}
# ====== TODO To be translated ======
translate K SearchMask {Search in Mask}
# ====== TODO To be translated ======
translate K DisplayMask {Display Mask}
translate K Nag {Codi Nag}
translate K Marker {Marcador}
translate K Include {Incloure}
translate K Exclude {Excloure}
translate K MainLine {L�nia principal}
translate K Bookmark {Preferida}
translate K NewLine {L�nia nova}
translate K ToBeVerified {Per a verificar}
translate K ToTrain {Per a entrenar}
translate K Dubious {Dubt�s}
translate K ToRemove {Per a treure}
translate K NoMarker {Sense marcador}
translate K ColorMarker {Color}
translate K WhiteMark {Blanc}
translate K GreenMark {Verd}
translate K YellowMark {Groc}
translate K BlueMark {Blau}
translate K RedMark {Vermell}
translate K CommentMove {Comentar jugada}
translate K CommentPosition {Comentar posici�}
translate K AddMoveToMaskFirst {Afegir primer la jugada a la m�scara}
translate K OpenAMaskFileFirst {Obrir primer un arxiu de m�scara}
translate K Positions {Posicions}
translate K Moves {Jugades}

# Finder window:
menuText K FinderFile "Arxiu" 0
menuText K FinderFileSubdirs "Mirar als subdirectoris" 0
menuText K FinderFileClose "Tanca el visor d'Arxius" 0
menuText K FinderSort "Ordenar" 0
menuText K FinderSortType "Tipus" 0
menuText K FinderSortSize "Tamany" 0
menuText K FinderSortMod "Modificat" 0
menuText K FinderSortName "Nom" 0
menuText K FinderSortPath "Cam�" 0
menuText K FinderTypes "Tipus" 0
menuText K FinderTypesScid "Bases de dades Scid" 0
menuText K FinderTypesOld "Bases de dades Scid en format antic" 12
menuText K FinderTypesPGN "Arxius PGN" 9
menuText K FinderTypesEPD "Arxius EPD (llibre)" 0
menuText K FinderTypesRep "Arxius de Repertori" 12
menuText K FinderHelp "Ajut" 1
menuText K FinderHelpFinder "Ajut del visor d'Arxius" 0
menuText K FinderHelpIndex "�ndex de l'ajut" 0
translate K FileFinder {Visor d'Arxius}
translate K FinderDir {Directori}
translate K FinderDirs {Directoris}
translate K FinderFiles {Arxius}
translate K FinderUpDir {amunt}
translate K FinderCtxOpen {Obrir}
translate K FinderCtxBackup {C�pia de seguretat (Backup)}
translate K FinderCtxCopy {C�pia}
translate K FinderCtxMove {Jugada}
translate K FinderCtxDelete {Esborrar}

# Player finder:
menuText K PListFile "Arxiu" 0
menuText K PListFileUpdate "Actualitzar" 0
menuText K PListFileClose "Tanca el Cercador de Jugadors" 0
menuText K PListSort "Ordenar" 0
menuText K PListSortName "Nom" 0
menuText K PListSortElo "Elo" 0
menuText K PListSortGames "Partides" 0
menuText K PListSortOldest "M�s antiga" 10
menuText K PListSortNewest "M�s nova" 4

# Tournament finder:
menuText K TmtFile "Arxiu" 0
menuText K TmtFileUpdate "Actualitzar" 0
menuText K TmtFileClose "Tanca el Visor de Torneigs" 0
menuText K TmtSort "Ordenar" 0
menuText K TmtSortDate "Data" 0
menuText K TmtSortPlayers "Jugadors" 0
menuText K TmtSortGames "Partides" 0
menuText K TmtSortElo "Elo" 0
menuText K TmtSortSite "Lloc" 0
menuText K TmtSortEvent "Torneig" 1
menuText K TmtSortWinner "Guanyador" 0
translate K TmtLimit "L�mit de llista"
translate K TmtMeanElo "Promig d'Elo inferior"
translate K TmtNone "No s'han trovat torneig que coincideixin."

# Graph windows:
menuText K GraphFile "Arxiu" 0
menuText K GraphFileColor "Guardar com Postscript Color..." 24
menuText K GraphFileGrey "Guardar com Postscript escala de grisos..." 34
menuText K GraphFileClose "Tancar finestra" 7
menuText K GraphOptions "Opcions" 0
menuText K GraphOptionsWhite "Blanques" 0
menuText K GraphOptionsBlack "Negres" 0
menuText K GraphOptionsBoth "Ambdos" 0
menuText K GraphOptionsPInfo "Opcions informaci� jugador" 0
# ====== TODO To be translated ======
menuText K GraphOptionsEloFile "Elo from rating file" 0
# ====== TODO To be translated ======
menuText K GraphOptionsEloDB "Elo from database" 0
translate K GraphFilterTitle "Filtre gr�fic: freq�encia per 1000 partides"
translate K GraphAbsFilterTitle "Filtre gr�fic: freq�encia de les partides"
translate K ConfigureFilter {Configurar Eix-X per Any, Rating i Jugades}
translate K FilterEstimate "Estimar"
translate K TitleFilterGraph "Scid: Filtre Gr�fic"

# Analysis window:
translate K AddVariation {Afegir variant}
translate K AddAllVariations {Afegir totes les variants}
translate K AddMove {Afegir jugada}
translate K Annotate {Anotar}
translate K ShowAnalysisBoard {Mostrar escaquer d'an�lisi}
translate K ShowInfo {Mostra info del motor}
translate K FinishGame {Finalitzar partida}
translate K StopEngine {Parar motor}
translate K StartEngine {Iniciar motor}
translate K LockEngine {Bloqueja motor en la posici� actual}
translate K AnalysisCommand {Direcci� d'an�lisi}
translate K PreviousChoices {Eleccions pr�vies}
translate K AnnotateTime {Posar el temps entre jugades a segons}
translate K AnnotateWhich {Afegir variants}
translate K AnnotateAll {Per a jugades dels dos b�ndols}
translate K AnnotateAllMoves {Anotar totes les jugades}
translate K AnnotateWhite {Nom�s per jugades de les Blanques}
translate K AnnotateBlack {Nom�s per jugades de les Negres}
translate K AnnotateBlundersOnly {Quan la jugada de la partida es un error}
translate K AnnotateBlundersOnlyScoreChange {An�lisi informant d'errors, amb canvi de puntuaci� des de: }
translate K BlundersThreshold {Marge d'error }
# TODO: Translate
translate K ScoreAllMoves {Score all moves}
translate K LowPriority {Baixa prioritat del processador}
translate K ClickHereToSeeMoves {Clic aqu� per veure les jugades}
translate K ConfigureInformant {Informacions}
translate K Informant!? {Jugada interesant}
translate K Informant? {Jugada dolenta}
translate K Informant?? {Desastrosa}
translate K Informant?! {Jugada dubtosa}
translate K Informant+= {Les Blanques tenen un lleuger avantatge}
translate K Informant+/- {Les Blanques tenen avantatge}
translate K Informant+- {Les Blanques tenen un avantatge decisiu}
translate K Informant++- {La partida es considerada com guanyada}
translate K Book {Llibre}
translate K OtherBookMoves {Altres jugades del llibre}
translate K OtherBookMovesTooltip {Jugades a les que el contrari te una respuesta}

# Analysis Engine open dialog:
translate K EngineList {Llista de Motors d'An�lisi}
translate K EngineName {Nom}
translate K EngineCmd {Ordre}
translate K EngineArgs {Par�metres}
translate K EngineDir {Directori}
translate K EngineElo {Elo}
translate K EngineTime {Data}
translate K EngineNew {Nova}
translate K EngineEdit {Editar}
translate K EngineRequired {Els camps en negreta son obligatoris; la resta opcionals}

# PGN window men�s:
menuText K PgnFile "Arxiu" 0
menuText K PgnFileCopy "Copiar partida al portapapers" 0
menuText K PgnFilePrint "Imprimir a arxiu..." 0
menuText K PgnFileClose "Tancar finestra PGN" 0
menuText K PgnOpt "Presentaci�" 0
menuText K PgnOptColor "Color de la presentaci�" 0
menuText K PgnOptShort "Encap�alament petit (3 l�nies)" 13
menuText K PgnOptSymbols "Anotacions simb�liques" 0
menuText K PgnOptIndentC "Sangria a comentaris" 0
menuText K PgnOptIndentV "Sangria a variants" 11
menuText K PgnOptColumn "Estil de columna (un jugada per l�nia)" 1
menuText K PgnOptSpace "Espai despr�s del n�mero del jugada" 0
menuText K PgnOptStripMarks "Treure codis de color a cassella/fletxa" 3
menuText K PgnOptBoldMainLine "Utilitzar text en negreta per les jugades principals" 4
menuText K PgnColor "Colors" 1
menuText K PgnColorHeader "Encap�alament..." 0
menuText K PgnColorAnno "Annotacions..." 0
menuText K PgnColorComments "Comentaris..." 0
menuText K PgnColorVars "Variants..." 0
menuText K PgnColorBackground "Fons..." 0
menuText K PgnColorMain "L�nia principal..." 0
menuText K PgnColorCurrent "Color de fons de l'�ltima jugada..." 1
menuText K PgnHelp "Ajut" 1
menuText K PgnHelpPgn "Ajut de PGN" 9
menuText K PgnHelpIndex "�ndex de l'ajut" 0
translate K PgnWindowTitle {Planilla - partida %u}

# Crosstable window men�s:
menuText K CrosstabFile "Arxiu" 0
menuText K CrosstabFileText "Imprimir a arxiu text..." 20
menuText K CrosstabFileHtml "Imprimir a arxiu HTML..." 20
menuText K CrosstabFileLaTeX "Imprimir a arxiu LaTeX..." 20
menuText K CrosstabFileClose "Tancar finestra de graella" 0
menuText K CrosstabEdit "Editar" 0
menuText K CrosstabEditEvent "Torneig" 0
menuText K CrosstabEditSite "Lloc" 0
menuText K CrosstabEditDate "Data" 0
menuText K CrosstabOpt "Presentaci�" 0
menuText K CrosstabOptAll "Tots contra tots" 0
menuText K CrosstabOptSwiss "Su�s" 0
menuText K CrosstabOptKnockout "Eliminat�ria directa" 0
menuText K CrosstabOptAuto "Auto" 0
menuText K CrosstabOptAges "Edat en anys" 1
menuText K CrosstabOptNats "Nacionalitats" 0
menuText K CrosstabOptRatings "Elo" 0
menuText K CrosstabOptTitles "T�tols" 0
menuText K CrosstabOptBreaks "Puntuacions de desempat" 0
menuText K CrosstabOptDeleted "Incluore partides esborrades" 17
menuText K CrosstabOptColors "Colors (nom�s a la taula d'un Su�s)" 0
menuText K CrosstabOptColumnNumbers "Columnes numerades (Nom�s en la taula tots contra tots)" 11
menuText K CrosstabOptGroup "Grups de classificaci�" 0
menuText K CrosstabSort "Ordenar" 0
menuText K CrosstabSortName "Per nom" 4
menuText K CrosstabSortRating "Per Elo" 4
menuText K CrosstabSortScore "Per puntuaci�" 4
menuText K CrosstabColor "Color" 2
menuText K CrosstabColorPlain "Text simple" 0
menuText K CrosstabColorHyper "Hipertext" 0
menuText K CrosstabHelp "Ajut" 1
menuText K CrosstabHelpCross "Ajut de Classificaci�" 9
menuText K CrosstabHelpIndex "�ndex de l'ajut" 0
translate K SetFilter {Posar filtre}
translate K AddToFilter {Afegir al filtre}
translate K Swiss {Su�s}
translate K Category {Categor�a}

# Opening report window men�s:
menuText K OprepFile "Arxiu" 0
menuText K OprepFileText "Imprimir a arxiu text..." 20
menuText K OprepFileHtml "Imprimir a arxiu HTML..." 20
menuText K OprepFileLaTeX "Imprimir a arxiu LaTeX..." 20
menuText K OprepFileOptions "Opcions..." 0
menuText K OprepFileClose "Tancar finestra de l'informe d'obertura" 0
menuText K OprepFavorites "Preferits" 1
menuText K OprepFavoritesAdd "Afegir informe..." 0
menuText K OprepFavoritesEdit "Editar informe preferit..." 0
menuText K OprepFavoritesGenerate "Generar informe..." 0
menuText K OprepHelp "Ajut" 1
menuText K OprepHelpReport "Ajut de l'informe de l'obertura" 11
menuText K OprepHelpIndex "�ndex de l'ajut" 0

# Header search:
translate K HeaderSearch {Recerca per encap�alament}
translate K EndSideToMove {B�ndol a moure ver al final de la partida}
translate K GamesWithNoECO {Partides sense ECO?}
translate K GameLength {Duraci�:}
translate K FindGamesWith {Trobar partides amb}
translate K StdStart {Inici estandar}
translate K Promotions {Promocions}
translate K Comments {Comentaris}
translate K Variations {Variants}
translate K Annotations {Annotacions}
translate K DeleteFlag {Marques d'esborrat}
translate K WhiteOpFlag {Obertura de les blanques}
translate K BlackOpFlag {Obertura de les negres}
translate K MiddlegameFlag {Mig joc}
translate K EndgameFlag {Finals}
translate K NoveltyFlag {Novetat}
translate K PawnFlag {Estructura de peons}
translate K TacticsFlag {T�ctiques}
translate K QsideFlag {Joc de flanc de dama}
translate K KsideFlag {Joc de flanc de rei}
translate K BrilliancyFlag {Genialitat}
translate K BlunderFlag {Error}
translate K UserFlag {Usuari}
translate K PgnContains {PGN cont� text}
# ====== TODO To be translated ======
translate K Annotator {Annotator}
# ====== TODO To be translated ======
translate K Cmnts {Annotated games only}

# Game list window:
translate K GlistNumber {N�mero}
translate K GlistWhite {Blanques}
translate K GlistBlack {Negres}
translate K GlistWElo {Elo-B}
translate K GlistBElo {Elo-N}
translate K GlistEvent {Torneig}
translate K GlistSite {Lloc}
translate K GlistRound {Ronda}
translate K GlistDate {Data}
translate K GlistYear {Any}
translate K GlistEDate {Torneig-Data}
translate K GlistResult {Resultat}
translate K GlistLength {Longitud}
translate K GlistCountry {Pais}
translate K GlistECO {ECO}
translate K GlistOpening {Obertura}
translate K GlistEndMaterial {Material final}
translate K GlistDeleted {Esborrat}
translate K GlistFlags {Senyal}
translate K GlistVars {Variants}
translate K GlistComments {Comentaris}
translate K GlistAnnos {Annotacions}
translate K GlistStart {Inici}
translate K GlistGameNumber {N�mero de partida}
# ====== TODO To be translated ======
translate K GlistAverageElo {Average Elo}
# ====== TODO To be translated ======
translate K GlistRating {Rating}
translate K GlistFindText {Trovar text}
translate K GlistMoveField {Jugada}
translate K GlistEditField {Configurar}
translate K GlistAddField {Afegir}
translate K GlistDeleteField {Treure}
translate K GlistWidth {Amplada}
translate K GlistAlign {Alinear}
# ====== TODO To be translated ======
translate K GlistAlignL {Align: left}
# ====== TODO To be translated ======
translate K GlistAlignR {Align: right}
# ====== TODO To be translated ======
translate K GlistAlignC {Align: center}
translate K GlistColor {Color}
translate K GlistSep {Separador}
# ====== TODO To be translated ======
translate K GlistCurrentSep {-- Current --}
# ====== TODO To be translated ======
translate K GlistNewSort {New}
# ====== TODO To be translated ======
translate K GlistAddToSort {Add}
# ====== TODO To be translated ======
translate K GsortSort {Sort...}
# ====== TODO To be translated ======
translate K GsortDate {Date}
# ====== TODO To be translated ======
translate K GsortYear {Year}
# ====== TODO To be translated ======
translate K GsortEvent {Event}
# ====== TODO To be translated ======
translate K GsortSite {Site}
# ====== TODO To be translated ======
translate K GsortRound {Round}
# ====== TODO To be translated ======
translate K GsortWhiteName {White Name}
# ====== TODO To be translated ======
translate K GsortBlackName {Black Name}
# ====== TODO To be translated ======
translate K GsortECO {ECO}
# ====== TODO To be translated ======
translate K GsortResult {Result}
# ====== TODO To be translated ======
translate K GsortMoveCount {Move Count}
# ====== TODO To be translated ======
translate K GsortAverageElo {Average Elo}
# ====== TODO To be translated ======
translate K GsortCountry {Country}
# ====== TODO To be translated ======
translate K GsortDeleted {Deleted}
# ====== TODO To be translated ======
translate K GsortEventDate {Event Date}
# ====== TODO To be translated ======
translate K GsortWhiteElo {White Elo}
# ====== TODO To be translated ======
translate K GsortBlackElo {Black Elo}
# ====== TODO To be translated ======
translate K GsortComments {Comments}
# ====== TODO To be translated ======
translate K GsortVariations {Variations}
# ====== TODO To be translated ======
translate K GsortNAGs {NAGs}
# ====== TODO To be translated ======
translate K GsortAscending {Ascending}
# ====== TODO To be translated ======
translate K GsortDescending {Descending}
# ====== TODO To be translated ======
translate K GsortAdd {Add}
# ====== TODO To be translated ======
translate K GsortStore {Store}
# ====== TODO To be translated ======
translate K GsortLoad {Load}
translate K GlistRemoveThisGameFromFilter  {Treu aquesta partida del Filtre}
translate K GlistRemoveGameAndAboveFromFilter  {Treu aquesta partida i totes les de sobre del Filtre}
translate K GlistRemoveGameAndBelowFromFilter  {Treu aquesta partida i totes les de sota del Filtre}
translate K GlistDeleteGame {Elimina/Recupera aquesta partida de la base} 
translate K GlistDeleteAllGames {Elimina totes les partides de la base que hi son al Filtre} 
translate K GlistUndeleteAllGames {Recupera totes les partides esborrades de la base que hi son al filtre} 
translate K GlistMergeGameInBase {Barreja la partida a una altra base} 

# Maintenance window:
translate K DatabaseName {Nom de la base:}
translate K TypeIcon {Tipus d'icona:}
translate K NumOfGames {Partides:}
translate K NumDeletedGames {Partides esborrades:}
translate K NumFilterGames {Partides al filtre:}
translate K YearRange {Rang d'anys:}
translate K RatingRange {Rang d'Elo:}
translate K Description {Descripci�}
translate K Flag {Marca}
# ====== TODO To be translated ======
translate K CustomFlags {Custom flags}
translate K DeleteCurrent {Esborrar partida actual}
translate K DeleteFilter {Esborrar partides filtrades}
translate K DeleteAll {Esborrar totes les partides}
translate K UndeleteCurrent {No esborrar partida actual}
translate K UndeleteFilter {No esborrar partides filtrades}
translate K UndeleteAll {No esborrar totes les partides}
translate K DeleteTwins {Esborrar partides duplicades}
translate K MarkCurrent {Marcar partida actual}
translate K MarkFilter {Marcar partides filtrades}
translate K MarkAll {Marcar totes les partides}
translate K UnmarkCurrent {No marcar partida actual}
translate K UnmarkFilter {No marcar partides filtrades}
translate K UnmarkAll {No marcar totes les partides}
translate K Spellchecking {Revisi� ortogr�fica}
translate K Players {Jugadors}
translate K Events {Torneigs}
translate K Sites {Llocs}
translate K Rounds {Rondes}
translate K DatabaseOps {Operacions amb la base de dades}
translate K ReclassifyGames {Reclassificar partides per ECO...}
translate K CompactDatabase {Compactar base de dades}
translate K SortDatabase {Ordenar base de dades}
translate K AddEloRatings {Afegir classificaci� Elo}
translate K AutoloadGame {Autocargar n�mero de partida}
translate K StripTags {Treure etiquetes PGN}
translate K StripTag {Treure etiquetes}
translate K Cleaner {MultiEines}
translate K CleanerHelp {
Scid executar�, a l'actual base de dades, totes les accions de manteniment
que seleccionis de la seg�ent llista.

S'aplicar� l'estat actual a la classificaci� ECO i al di�leg d'esborrat de
duplicades si selecciones aquestes funcions.
}
translate K CleanerConfirm {
Un cop la MultiEina de manteniment comen�a no pot ser aturada!

En una base de dades gran pot trigar molt de temps, depenent de les funcions que s'hagi seleccionat i el seu estat actual.

N'est�s segur/a de voler comen�ar les funcions de manteniment que has escollit?
}
translate K TwinCheckUndelete {Prem "u" per no esborrar-ne cap (undelete)}
translate K TwinCheckprevPair {Parella previa}
translate K TwinChecknextPair {Pr�xima Parella}
translate K TwinChecker {Scid: Verificar partides duplicades}
translate K TwinCheckTournament {Partides d'un torneig:}
translate K TwinCheckNoTwin {No duplicada  }
translate K TwinCheckNoTwinfound {No s'han trovat duplicades per aquesta partida.\nper mostrar duplicades amb aquesta finestra fes servir la funci� "Esborrar partides duplicades..." }
translate K TwinCheckTag {Compartir etiquetes...}
translate K TwinCheckFound1 {Scid ha trobat $result partides duplicades}
translate K TwinCheckFound2 {i les marca com esborrades}
translate K TwinCheckNoDelete {No hi ha partides en aquesta base per esborrar.}
translate K TwinCriteria1 {Els teus par�metres per cercar duplicades potencialment poden fer que partides diferents amb jugades similars siguin marcades com a duplicades.}
translate K TwinCriteria2 {Es recomenable que escolleixis "No" per "algunes jugades", hauries d'escollir "S�"  pels par�metres colors, torneigs, lloc, ronda, any i mes.\nVols continuar, malgrat aix�, i esborrar les partides duplicades?}
translate K TwinCriteria3 {Es recomenable que especifiquis "S�" per al menys dos par�metres de "mateix lloc", "mateixa ronda" i "mateix any".\nVols continuar, malgrat aix�, i esborrar duplicades?}
translate K TwinCriteriaConfirm {Scid: Confirmar par�metres per partides duplicades}
translate K TwinChangeTag "Canviar les sig�ents etiquetes de les:\n\n partides"
translate K AllocRatingDescription "Aquesta ordre far� servir l'arxiu actual SpellCheck per afegir puntuacions ELO i partides a la base. On un jugador no tingui Elo per� si el tingui al llistat d'Spellcheck, se li afegir� l'Elo."
translate K RatingOverride "Sobre-escriure Elos existents no buits?"
translate K AddRatings "Afegir Elos a:"
translate K AddedRatings {Scid ha afegit $r ratings Elo a $g partides.}
translate K NewSubmenu "Nou submen�"

# Comment editor:
translate K AnnotationSymbols  {S�mbols d'annotaci�:}
translate K Comment {Comentari:}
translate K InsertMark {Insertar marca}
translate K InsertMarkHelp {
Insertar/treure marca: Selecciona color, tipus, cassella.
Insertar/treure fletxa: Bot� dret sobre dos casselles.
}

# Nag buttons in comment editor:
translate K GoodMove {Bona jugada}
translate K PoorMove {Mala jugada}
translate K ExcellentMove {Jugada excelent}
translate K Blunder {Error}
translate K InterestingMove {Jugada interessant}
translate K DubiousMove {Jugada dubtosa}
translate K WhiteDecisiveAdvantage {Les blanque tenen avantatge decisiu}
translate K BlackDecisiveAdvantage {Les negres tenen avantatge decisiu}
translate K WhiteClearAdvantage {Les blanques tenen clar avantatge}
translate K BlackClearAdvantage {Les negres tenen clar avantatge}
translate K WhiteSlightAdvantage {Les blanques tenen lleuger avantatge}
translate K BlackSlightAdvantage {Les negres tenen lleuger avantatge}
translate K Equality {Igualtat}
translate K Unclear {Poc clar}
translate K Diagram {Diagrama}

# Board search:
translate K BoardSearch {Escaquer de recerca}
translate K FilterOperation {Operaci� al filtre actual:}
translate K FilterAnd {Y (Restringir filtre)}
translate K FilterOr {O (Afegir al filtre)}
translate K FilterIgnore {IGNORAR (Posar a zero el filtre)}
translate K SearchType {Tipus de recerca:}
translate K SearchBoardExact {Posici� exacta (totes les peces a les mateixes casselles)}
translate K SearchBoardPawns {Peons (igual material, tots els peons a les mateixes casselles)}
translate K SearchBoardFiles {Columnes (igual material, tots els peons a les mateixes columnes)}
translate K SearchBoardAny {Qualsevol (igual material, peons i peces a qualsevol lloc)}
translate K SearchInRefDatabase { Cerca a la base }
translate K LookInVars {Mirar a les variants}

# Material search:
translate K MaterialSearch {Cerca per Material}
translate K Material {Material}
translate K Patterns {Patrons}
translate K Zero {Zero}
translate K Any {Qualsevol}
translate K CurrentBoard {Escaquer Actual}
translate K CommonEndings {Finals comuns}
translate K CommonPatterns {Patrons comuns}
translate K MaterialDiff {Diferencia de material}
translate K squares {casselles}
translate K SameColor {Igual color}
translate K OppColor {Color contrari}
translate K Either {Qualsevol}
translate K MoveNumberRange {Rang de nombre de jugades}
translate K MatchForAtLeast {Coincideix quan menys}
translate K HalfMoves {mitges jugades}

# Common endings in material search:
translate K EndingPawns {Finals de peons}
translate K EndingRookVsPawns {Torre vs. pe�(ns)}
translate K EndingRookPawnVsRook {Torre i 1 pe� vs. torre}
translate K EndingRookPawnsVsRook {Torre i pe�(ns) vs. torre}
translate K EndingRooks {Finals de torre vs. torre}
translate K EndingRooksPassedA {Finals de torre vs. torre amb pe� passat}
translate K EndingRooksDouble {Finals de dues torres}
translate K EndingBishops {Finals d'alfil vs. alfil}
translate K EndingBishopVsKnight {Finals d'alfil vs. cavall}
translate K EndingKnights {Finals de cavall vs. cavall}
translate K EndingQueens {Finals de dama vs. dama}
translate K EndingQueenPawnVsQueen {Dama i 1 pe� vs. dama}
translate K BishopPairVsKnightPair {Mig joc de dos alfils vs. dos cavalls}

# Common patterns in material search:
translate K PatternWhiteIQP {PDA blanc}
translate K PatternWhiteIQPBreakE6 {PDA blanc: d4-d5 ruptura vs. e6}
translate K PatternWhiteIQPBreakC6 {PDA blanc: d4-d5 ruptura vs. c6}
translate K PatternBlackIQP {PDA negre}
translate K PatternWhiteBlackIQP {PDA blanc vs. PDA negre}
translate K PatternCoupleC3D4 {Parella de peons a�llats blancs c3+d4}
translate K PatternHangingC5D5 {Peons suspessos negres a c5 i d5}
translate K PatternMaroczy {Centre Maroczy (amb peons a c4 i e4)}
translate K PatternRookSacC3 {Sacrifici de torre a c3}
translate K PatternKc1Kg8 {O-O-O vs. O-O (Rc1 vs. Rg8)}
translate K PatternKg1Kc8 {O-O vs. O-O-O (Rg1 vs. Rc8)}
translate K PatternLightFian {Fianchettos de casselles blanques (Alfil-g2 vs. Alfil-b7)}
translate K PatternDarkFian {Fianchettos de casselles negres (Alfil-b2 vs. Alfil-g7)}
translate K PatternFourFian {Quatre Fianchettos (Alfils a b2,g2,b7,g7)}

# Game saving:
translate K Today {Avui}
translate K ClassifyGame {Classificar partida}

# Setup position:
translate K EmptyBoard {Escaquer buit}
translate K InitialBoard {Escaquer inicial}
translate K SideToMove {B�ndol que mou}
translate K MoveNumber {Jugada n�mero}
translate K Castling {Enroc}
translate K EnPassantFile {Columna al pas}
translate K ClearFen {Treure FEN}
translate K PasteFen {Pegar FEN}
translate K SaveAndContinue {Salvar (enregistrar) i continuar}
translate K DiscardChangesAndContinue {Descartar \n canvis i continuar}
translate K GoBack {Tornar enrera}

# Replace move dialog:
translate K ReplaceMove {Substituir jugada}
translate K AddNewVar {Afegir nova variant}
translate K NewMainLine {Nova L�nia Principal}
translate K ReplaceMoveMessage {Ja existeix una jugada.

Pots substituir-la, descartant totes les jugades posteriors, o afegir-la com una nova variant.

(Pots evitar seguir veient aquest missatge en el futur desactivant l'opci� "Preguntar abans de substituir moviments" al men� Opcions: Jugades.)}

# Make database read-only dialog:
translate K ReadOnlyDialog {Si fas que aquesta base de dades sigui nom�s de lectura no es permetran fer canvis. No es podran salvar o substituir partides, i no es podra alterar les senyals d'esborrat. Qualsevol ordenaci� o classificaci� per ECO ser� temporal.

Pots altra cop fer de forma f�cil la base de dades d'escriptura tancant-la i obrint-la.

Realment vols fer que aquesta base de dades sigui nom�s de lectura?}

# Clear game dialog:
translate K ClearGameDialog {Aquesta partida ha estat modificada.

Realment vols continuar i eliminar els canvis fets?
}

# Exit dialog:
translate K ExitDialog {Vols sortir d'Scid?}
translate K ExitUnsaved {La seguent base de dades te canvis a partides no salvades. Si surts ara es perdran aquests canvis.}

# Import window:
translate K PasteCurrentGame {Pegar partida actual}
translate K ImportHelp1 \
  {Introduir o pegar una partida en format PGN al marc superior.}
translate K ImportHelp2 \
  {Qualsevol error important la partida es mostrar� aqu�.}
translate K OverwriteExistingMoves {SobreEscriure jugades existents?}

# ECO Browser:
translate K ECOAllSections {totes les divisions ECO}
translate K ECOSection {divisi� ECO}
translate K ECOSummary {Resum de}
translate K ECOFrequency {Freq�encia dels subcodis per}

# Opening Report:
translate K OprepTitle {Informe de l'obertura}
translate K OprepReport {Informe}
translate K OprepGenerated {Generat per}
translate K OprepStatsHist {Estad�stiques e Historia}
translate K OprepStats {Estad�stiques}
translate K OprepStatAll {Totes les partides referides}
translate K OprepStatBoth {Ambdues amb Elo}
translate K OprepStatSince {Des de}
translate K OprepOldest {Partides m�s antigues}
translate K OprepNewest {Partides m�s noves}
translate K OprepPopular {Popularitat actual}
translate K OprepFreqAll {Freq�encia a tots els anys: }
translate K OprepFreq1   {Des de l'�ltim any fins avui:     }
translate K OprepFreq5   {En els �ltims 5 anys fins avui:   }
translate K OprepFreq10  {En els �ltimos 10 anys fins avui:  }
translate K OprepEvery {un cop cada %u partides}
translate K OprepUp {puja un %u%s respecte al total d'anys}
translate K OprepDown {baixa un %u%s respecte al total d'anys}
translate K OprepSame {no hi han canvis respecte al total d'anys}
translate K OprepMostFrequent {Jugadors m�s freq�ents}
translate K OprepMostFrequentOpponents {Rivals m�s freq�entes}
translate K OprepRatingsPerf {Elo i Rendiment}
translate K OprepAvgPerf {Promig Elo i rendiment}
translate K OprepWRating {Elo de les blanques}
translate K OprepBRating {Elo de les negres}
translate K OprepWPerf {Rendiment de les blanques}
translate K OprepBPerf {Rendiment de les negres}
translate K OprepHighRating {Partida amb el promig d'Elo m�s gran}
translate K OprepTrends {Tendencies de Resultats}
translate K OprepResults {Resultat de duracions i freq�encies}
translate K OprepLength {Duraci� de la partida}
translate K OprepFrequency {Freq�encia}
translate K OprepWWins {Blanques guanyen: }
translate K OprepBWins {Negres guanyen:  }
translate K OprepDraws {Taules:        }
translate K OprepWholeDB {al conjunt de la base de dades}
translate K OprepShortest {Vict�ries m�s curtes}
translate K OprepMovesThemes {Jugades i temes}
translate K OprepMoveOrders {L�nies de jugades que arriben a la posici� de l'informe}
translate K OprepMoveOrdersOne \
  {Nom�s hi ha una l�nia de jugades que arriba fins aquesta posici�:}
translate K OprepMoveOrdersAll \
  {Hi han %u l�nies que arriben a aquesta posici�:}
translate K OprepMoveOrdersMany \
  {Hi han %u l�nies que arriben a aquesta posici�. Les %u m�s comuns son:}
translate K OprepMovesFrom {Jugades des de la posici� de l'informe}
translate K OprepMostFrequentEcoCodes {Obertures m�s freq�ents}
translate K OprepThemes {Temes Posicionals}
translate K OprepThemeDescription {Freq�encia dels temes a les primeres %u jugades de cada partida}
translate K OprepThemeSameCastling {Enroc al mateix flanc}
translate K OprepThemeOppCastling {Enrocs a flancs diferents}
translate K OprepThemeNoCastling {El dos Reis sense enrocar}
translate K OprepThemeKPawnStorm {Avalantxa dels peons del Rei}
translate K OprepThemeQueenswap {Canvi de Dames}
translate K OprepThemeWIQP {Pe� de dama a�llat de les blanques}
translate K OprepThemeBIQP {Pe�n de dama a�llat de les negres}
translate K OprepThemeWP567 {Peons blancs a 5/6/7� fila}
translate K OprepThemeBP234 {Peons negres a 2/3/4� fila}
translate K OprepThemeOpenCDE {Columnes c/d/e obertes}
translate K OprepTheme1BishopPair {Un b�ndol te parella d'alfils}
translate K OprepEndgames {Finals}
translate K OprepReportGames {Informe de partides}
translate K OprepAllGames {Totes les partides}
translate K OprepEndClass {Tipus de finales d'acord a l'�ltima posici� de les partides}
translate K OprepTheoryTable {Taula de Teoria}
translate K OprepTableComment {Generada a partir de les %u partides amb millor Elo.}
translate K OprepExtraMoves {Annotaci� extra de moviments a la taula de teoria}
translate K OprepMaxGames {M�xim de partides a la taula de teoria}
translate K OprepViewHTML {Veure HTML}
translate K OprepViewLaTeX {Veure LaTeX}

# Player Report:
translate K PReportTitle {Informe del jugador}
translate K PReportColorWhite {amb les peces blanques}
translate K PReportColorBlack {amb les peces negres}
translate K PReportMoves {%s despr�s}
translate K PReportOpenings {Obertures}
translate K PReportClipbase {Buidar el portapapers i copiar les partides}

# Piece Tracker window:
translate K TrackerSelectSingle {El bot� esquerra selecciona la pe�a.}
translate K TrackerSelectPair {El bot� esquerra selecciona la pe�a; el bot�n dret tamb� selecciona la germana.}
translate K TrackerSelectPawn {El bot� esquerra selecciona el pe�; el bot� dret selecciona els 8 peons.}
translate K TrackerStat {Estad�stica}
translate K TrackerGames {% de partides amb jugada a aquesta cassella}
translate K TrackerTime {% de temps cap aquesta cassella}
translate K TrackerMoves {Jugades}
translate K TrackerMovesStart {Escriu el n�mero de la jugada des d'on comen�ar la recerca.}
translate K TrackerMovesStop {Escriu el n�mero de la jugada on s'ha d'aturar la recerca.}

# Game selection dialogs:
translate K SelectAllGames {Totes les partides de la base de dades}
translate K SelectFilterGames {Nom�s les partides filtrades}
translate K SelectTournamentGames {Nom�s les partides de l'actual torneig}
translate K SelectOlderGames {Nom�s partides antigues}

# Delete Twins window:
translate K TwinsNote {Per a ser duplicades, dos partides han de tenir quan menys els mateixos dos jugadors i els criteris que fixis a sota. Quan es troba un parell de duplicades, es borra la partida m�s curta. Suggeriment: es millor fer la correcci� ortogr�fica de la base de dades abans d'iniciar l'esborrat de duplicades, per que millora la seva detecci�.}
translate K TwinsCriteria {Criteris: Les partides duplicades han de tenir...}
translate K TwinsWhich {Partides a examinar}
translate K TwinsColors {Jugadors amb igual color?}
translate K TwinsEvent {Mateix torneig?}
translate K TwinsSite {Mateix lloc?}
translate K TwinsRound {Mateixa ronda?}
translate K TwinsYear {Mateix any?}
translate K TwinsMonth {Mateix mes?}
translate K TwinsDay {Mateix d�a?}
translate K TwinsResult {Mateix resultat?}
translate K TwinsECO {Mateix codi ECO?}
translate K TwinsMoves {Mateixes jugades?}
translate K TwinsPlayers {Comparant noms de jugadors:}
translate K TwinsPlayersExact {Trobo exactes}
translate K TwinsPlayersPrefix {Nom�s les primeres 4 lletres}
translate K TwinsWhen {Quan es borren partides duplicades}
translate K TwinsSkipShort {Ignorar totes les partides amb menys de 5 jugades?}
translate K TwinsUndelete {Treure en primer lloc marques d'esborrat?}
translate K TwinsSetFilter {Posar al filtre totes les partides esborrades?}
translate K TwinsComments {Saltar sempre partides amb comentaris?}
translate K TwinsVars {Saltar sempre partides amb variants?}
translate K TwinsDeleteWhich {Quina partida esborrar:}
translate K TwinsDeleteShorter {Partida m�s curta}
translate K TwinsDeleteOlder {N�mero de partida m�s petit}
translate K TwinsDeleteNewer {N�mero de partida m�s gran}
translate K TwinsDelete {Esborrar partides}

# Name editor window:
translate K NameEditType {Tipus de dada a editar}
translate K NameEditSelect {Partides a editar}
translate K NameEditReplace {Reempla�ar}
translate K NameEditWith {amb}
translate K NameEditMatches {Ja hi son: Presionar Ctrl+1 a Ctrl+9 per seleccionar-ne}
# ====== TODO To be translated ======
translate K CheckGames {Check games}
# ====== TODO To be translated ======
translate K CheckGamesWhich {Check games}
# ====== TODO To be translated ======
translate K CheckAll {All games}
# ====== TODO To be translated ======
translate K CheckSelectFilterGames {Only games in filter}

# Classify window:
translate K Classify {Classificar}
translate K ClassifyWhich {Classificar per codi ECO}
translate K ClassifyAll {Totes les partides (sobreescriure codi ECO)}
translate K ClassifyYear {Totes les partides jugades a l'�ltim any}
translate K ClassifyMonth {Totes les partides jugades a l'�ltim mes}
translate K ClassifyNew {Nom�s les partides sense codi ECO}
translate K ClassifyCodes {Codi ECO a utilitzar}
translate K ClassifyBasic {Nom�s codi b�sic ("B12", ...)}
translate K ClassifyExtended {Extensions Scid ("B12j", ...)}

# Compaction:
translate K NameFile {Arxiu de noms}
translate K GameFile {Arxiu de partides}
translate K Names {Noms}
translate K Unused {No utilitzat}
translate K SizeKb {Tamany (kb)}
translate K CurrentState {Estat actual}
translate K AfterCompaction {Despr�s de la compactaci�}
translate K CompactNames {Compactar arxiu de noms}
translate K CompactGames {Compactar arxiu de partides}
translate K NoUnusedNames "No hi han noms sense utilitzar, per tant l'arxiu de noms ja est� compactat."
translate K NoUnusedGames "L'arxiu ja est� totalment compactat."
translate K GameFileCompacted {L'arxiu de partides de la base de dades ha estat compactada.}

# Sorting:
translate K SortCriteria {Criteri}
translate K AddCriteria {Afegir criteri}
translate K CommonSorts {Ordenacions habituals}
translate K Sort {Ordenar}

# Exporting:
translate K AddToExistingFile {Afegir partides a un arxiu existent?}
translate K ExportComments {Exportar comentaris?}
translate K ExportVariations {Exportar variants?}
translate K IndentComments {Sangrar comentaris?}
translate K IndentVariations {Sangrar variants?}
translate K ExportColumnStyle {Estil de columna (una jugada per l�nia)?}
translate K ExportSymbolStyle {Estil d'anotaci� simb�lica:}
translate K ExportStripMarks {Treure marca de codis de cassella/fletxa dels comentaris?}

# Goto game/move dialogs:
translate K LoadGameNumber {Entra el n�mero de la partida a carregar:}
translate K GotoMoveNumber {Anar a la jugada n�mero:}

# Copy games dialog:
translate K CopyGames {Copiar partides}
translate K CopyConfirm {
 Realment vols copiar les [::utils::thousands $nGamesToCopy] partides fitrades
 de la base de dades "$fromName"
 a la base de dades "$targetName"?
}
translate K CopyErr {No es poden copiar les partides}
translate K CopyErrSource {la base de dades font}
translate K CopyErrTarget {la base de dades de desti}
translate K CopyErrNoGames {no te partides al filtre}
translate K CopyErrReadOnly {es de nom�s lectura}
translate K CopyErrNotOpen {no est� oberta}

# Colors:
translate K LightSquares {Casselles blanques}
translate K DarkSquares {Casselles negres}
translate K SelectedSquares {Casselles seleccionades}
translate K SuggestedSquares {Casselles de jugada suggerida}
translate K WhitePieces {Peces blanques}
translate K BlackPieces {Peces negres}
translate K WhiteBorder {Vora blanques}
translate K BlackBorder {Vora negres}

# Novelty window:
translate K FindNovelty {Trobar Novetat}
translate K Novelty {Novetat}
translate K NoveltyInterrupt {Recerca de novetat interrompuda}
translate K NoveltyNone {Cap novetat trobada en aquesta partida}
translate K NoveltyHelp {
Scid trobar� la primera jugada de l'actual partida que representi una posici� no existent a la base de dades seleccionada o al llibre d'obertures ECO.
}

# Sounds configuration:
translate K SoundsFolder {Directori d'arxius de so}
translate K SoundsFolderHelp {El directori ha de tenir els arxius King.wav, a.wav, 1.wav, etc}
translate K SoundsAnnounceOptions {Opcions d'anunci de jugades}
translate K SoundsAnnounceNew {Anunciar noves jugades quan estiguin fetes}
translate K SoundsAnnounceForward {Anunciar jugades quan avancem una jugada}
translate K SoundsAnnounceBack {Anunciar jugada quan rectifiquem o retrocedim una jugada}
# ====== TODO To be translated ======
translate K SoundsSoundDisabled {Scid could not find the Snack audio package at startup;\nSound is disabled.}

# Upgrading databases:
translate K Upgrading {Actualitzaci�}
translate K ConfirmOpenNew {
Aquest es un format de base de dades antico (Scid 3) que no es pot obrir amb Scid 4, pero ja s'ha creat una versi�n en el format nou (Scid 4).

Vols abrir la versi� de format nou de la base de dades?
}
translate K ConfirmUpgrade {
Aquesta es una base de dades en un format antic (Scid 3). S'ha de crear una versi� amb el nou format abans de poder utilitzar-la a Scid 4.

L'actualitzaci� crear� una nova versi� de la base de dades.

Pot trigar temps, pero nom�s cal fer-ho un cop. Pots cancelar si triga massa temps.

Vols actualitzar aquesta base de dades ara?
}

# Recent files options:
translate K RecentFilesMenu {Nombre d'arxius recents al men� Arxiu}
translate K RecentFilesExtra {Nombre d'arxius recents al submen� extra}

# My Player Names options:
translate K MyPlayerNamesDescription {
Escriu una llista de noms alternatius per jugador, un nom per cada l�nia. Es permeten comodins (per exemple "?" per un caracter, "*" per varis caracters).

Cada cop que es carregui una partida amb un jugador de la llista es girar� l'escaquer, si fos necessari, per veure la partida des de la perspectiva del jugador.
}
translate K showblunderexists {Mostrar ficada de pota}
translate K showblundervalue {Mostrar valor de la ficada de pota}
translate K showscore {Mostrar marcador}
translate K coachgame {Entrenador}
translate K configurecoachgame {Configurar entrenador}
translate K configuregame {Configuraci� de partida}
translate K Phalanxengine {Motor Phalanx}
translate K Coachengine {Motor entrenador}
translate K difficulty {Dificultat}
translate K hard {Dur}
translate K easy {F�cil}
translate K Playwith {Juga amb}
translate K white {blanques}
translate K black {negres}
translate K both {ambdos}
translate K Play {Jugar}
translate K Noblunder {Sense errors}
translate K blunder {Ficades de pota}
translate K Noinfo {-- Sense informaci� --}
translate K PhalanxOrTogaMissing {No es troben ni Phalanx ni Toga}
translate K moveblunderthreshold {La jugada es un error si la p�rdua de puntuaci� es m�s gran que }
translate K limitanalysis {Temps l�mit per l'an�lisi del motor}
translate K seconds {segons}
translate K Abort {Abortar}
translate K Resume {Reanudar}
translate K OutOfOpening {Fora de l'obertura}
translate K NotFollowedLine {No segueixes la l�nia}
translate K DoYouWantContinue {Vols continuar?}
translate K CoachIsWatching {Entrenador}
translate K Ponder {Pensar sempre (motor)}
translate K LimitELO {Limitar for�a ELO}
translate K DubiousMovePlayedTakeBack {Jugada dubtosa, vols rectificar?}
translate K WeakMovePlayedTakeBack {Jugada fluixa, vols rectificar?}
translate K BadMovePlayedTakeBack {Jugada dolenta, vols rectificar?}
translate K Iresign {Abandono}
translate K yourmoveisnotgood {la teva jugada es dolenta}
translate K EndOfVar {Fi de la variant}
translate K Openingtrainer {Entrenador d'obertures}
translate K DisplayCM {Mostra jugades possibles}
translate K DisplayCMValue {Mostra valor de les jugades possibles}
translate K DisplayOpeningStats {Mostra estad�stiques}
translate K ShowReport {Mostra informe}
translate K NumberOfGoodMovesPlayed {jugades bones fetes}
translate K NumberOfDubiousMovesPlayed {jugades dubtoses fetes}
translate K NumberOfMovesPlayedNotInRepertoire {jugades fetes fora del repertori}
translate K NumberOfTimesPositionEncountered {vegades trobada la posici�}
translate K PlayerBestMove  {Permet �nicament les millors jugades}
translate K OpponentBestMove {El contrari juga les millors jugades}
translate K OnlyFlaggedLines {Nom�s l�nies marcades}
translate K resetStats {Reinicia estad�stiques}
translate K Repertoiretrainingconfiguration {Configuraci� del repertori d'entrenament}
translate K Loadingrepertoire {Carregant repertori}
translate K Movesloaded {Jugades carregades}
translate K Repertoirenotfound {Repertori no trobat}
translate K Openfirstrepertoirewithtype {Obrir primer una base amb una icona/tipus de repertori al costat dret}
translate K Movenotinrepertoire {La jugada no est� al repertori}
translate K PositionsInRepertoire {Posicions al repertori}
translate K PositionsNotPlayed {Posicions no jugades}
translate K PositionsPlayed {Posicions jugades}
translate K Success {Exits}
translate K DubiousMoves {Jugades dubtoses}
translate K OutOfRepertoire {Fora de repertori}
translate K ConfigureTactics {Configurar t�ctica}
translate K ResetScores {Reiniciar marcadors (puntuacions)}
translate K LoadingBase {Cargant base}
translate K Tactics {T�ctica}
translate K ShowSolution {Mostrar resposta}
# ====== TODO To be translated ======
translate K NextExercise {Next exercise}
# ====== TODO To be translated ======
translate K PrevExercise {previous exercise}
# ====== TODO To be translated ======
translate K StopTraining {Stop training}
translate K Next {Seg�ent}
translate K ResettingScore {Reiniciant marcador}
translate K LoadingGame {Cargant partida}
translate K MateFound {Trobat mat}
translate K BestSolutionNotFound { NO s'ha trobat la millor resposta!}
translate K MateNotFound {Mat no trobat}
translate K ShorterMateExists {Existeix un mat m�s curt}
translate K ScorePlayed {Marcador jugat}
translate K Expected {Esperat}
translate K ChooseTrainingBase {Escollir base d'entrenament}
translate K Thinking {Pensant}
translate K AnalyzeDone {An�lisi fet}
translate K WinWonGame {Guanya la partida guanyada}
translate K Lines {L�nies}
translate K ConfigureUCIengine {Configurar motor UCI}
translate K SpecificOpening {Obertura espec�fica}
translate K StartNewGame {Iniciar nova partida}
translate K FixedLevel {Nivell fix}
translate K Opening {Obrint}
translate K RandomLevel {Nivell aleatori}
translate K StartFromCurrentPosition {Iniciar des de la posici� actual}
translate K FixedDepth {Profunditat fixe}
translate K Nodes {Nodes} 
translate K Depth {Profunditat}
translate K Time {Temps} 
translate K SecondsPerMove {Segons per jugada}
translate K Engine {Motor}
translate K TimeMode {Mode de temps}
translate K TimeBonus {Temps + bonus}
translate K TimeMin {min}
translate K TimeSec {seg}
translate K AllExercisesDone {Tots els exercicis fets}
translate K MoveOutOfBook {Jugada fora del llibre}
translate K LastBookMove {�ltima jugada del llibre}
translate K AnnotateSeveralGames {Anotar les partides\ndes de l'actual fins la partida: }
translate K FindOpeningErrors {Trobar errors als primers }
translate K MarkTacticalExercises {Marca exercicis t�ctics}
translate K UseBook {Utilitzar llibre d'obertures}
translate K MultiPV {M�ltiples Variants}
translate K Hash {Mem�ria Hash}
translate K OwnBook {Utilitzar el llibre del motor}
translate K BookFile {Llibre d'obertures}
translate K AnnotateVariations {Anotar variants}
translate K ShortAnnotations {Anotacions curtes}
translate K addAnnotatorTag {Afegir etiqueta d'anotador}
translate K AddScoreToShortAnnotations {Afegir puntuaci� per anotaciones curtes}
translate K Export {Exportar}
translate K BookPartiallyLoaded {Llibre carregat parcialment}
translate K Calvar {C�lcul de variants}
translate K ConfigureCalvar {Configuraci�}
translate K Reti {Obertura Reti}
translate K English {Obertura anglesa}
translate K d4Nf6Miscellaneous {1.d4 Cf6 varis}
translate K Trompowsky {Obertura Trompowsky}
translate K Budapest {Gambit Budapest}
translate K OldIndian {Defensa India Antiga}
translate K BenkoGambit {Gambit Benko}
translate K ModernBenoni {Defensa Benoni Moderna}
translate K DutchDefence {Defensa Holandesa}
translate K Scandinavian {Defensa Escandinava}
translate K AlekhineDefence {Defensa Alekhine}
translate K Pirc {Defensa Pirc}
translate K CaroKann {Defensa Caro-Kann}
translate K CaroKannAdvance {Defensa Caro-Kann, Variant de l'avan�ament}
translate K Sicilian {Defensa Siciliana}
translate K SicilianAlapin {Defensa Siciliana, Variant Alapin}
translate K SicilianClosed {Defensa Siciliana, Variant Tancada}
translate K SicilianRauzer {Defensa Siciliana, Variant Rauzer}
translate K SicilianDragon {Defensa Siciliana, Variant del Drag�}
translate K SicilianScheveningen {Defensa Siciliana, Variant Scheveningen}
translate K SicilianNajdorf {Defensa Siciliana, Variant Najdorf}
translate K OpenGame {Obertura Oberta}
translate K Vienna {Obertura Vienesa}
translate K KingsGambit {Gambit de Rei}
translate K RussianGame {Partida Rusa}
translate K ItalianTwoKnights {Obertura Italiana, Variant dels Dos Cavalls}
translate K Spanish {Obertura Espanyola}
translate K SpanishExchange {Obertura Espanyola, Variant del canvi}
translate K SpanishOpen {Obertura Espanyola}
translate K SpanishClosed {Obertura Espanyola, Variant tancada}
translate K FrenchDefence {Defensa Francesa}
translate K FrenchAdvance {Defensa Francesa, Variant de l'Avan�ament}
translate K FrenchTarrasch {Defensa Francesa, Variant Tarrasch}
translate K FrenchWinawer {Defensa Francesa, Variant Winawer}
translate K FrenchExchange {Defensa Francesa, Variant del canvi}
translate K QueensPawn {Obertura de Pe� de Dama}
translate K Slav {Defensa Eslava}
translate K QGA {Gambit de Dama Acceptat}
translate K QGD {Gambit de Dama Declinat}
translate K QGDExchange {Gambit de Dama Declinat, Variant del Canvi}
translate K SemiSlav {Defensa Semi-Eslava del Gambit de Dama Declinat}
translate K QGDwithBg5 {Gambit de Dama Declinat amb Ag5}
translate K QGDOrthodox {Gambit de Dama Declinat,  Defensa Ortodoxa}
translate K Grunfeld {Defensa Gr�nfeld}
translate K GrunfeldExchange {Variant del canvi de la Defensa Gr�nfeld }
translate K GrunfeldRussian {Variant Rusa de la Defensa Gr�nfeld}
translate K Catalan {Catalana}
translate K CatalanOpen {Obertura Catalana}
translate K CatalanClosed {Obertura Catalana, Variant Tancada}
translate K QueensIndian {Defensa India de Dama}
translate K NimzoIndian {Obertura Nimzo-India}
translate K NimzoIndianClassical {Obertura Nimzo-India Cl�ssica}
translate K NimzoIndianRubinstein {Variante Rubinstein de la Nimzo-India}
translate K KingsIndian {India de Rei}
translate K KingsIndianSamisch {Atac S�mish de la India de Reiy}
translate K KingsIndianMainLine {Linia Principal India de Rei}
translate K ConfigureFics {Configurar FICS}
translate K FICSGuest {Autentificaci� com convidat}
translate K FICSServerPort {Port del servidor}
# ====== TODO To be translated ======
translate K FICSServerAddress {IP Address}
# ====== TODO To be translated ======
translate K FICSRefresh {Refresh}
translate K FICSTimesealPort {Port Timeseal}
translate K FICSSilence {Silenci}
translate K FICSOffers {Ofertes}
translate K FICSConsole {Consola}
translate K FICSGames {Partides}
translate K FICSUnobserve {Atura l'observaci� d'una partida}
translate K FICSProfile {Mostra la teva hist�ria i perfil}
translate K FICSRelayedGames {Partides ajornades}
translate K FICSFindOpponent {Cercar contrari}
translate K FICSTakeback {Retrocedeix}
translate K FICSTakeback2 {Retrocedeix 2}
translate K FICSInitTime {Temps inicial (min)}
translate K FICSIncrement {Increment (seg)}
translate K FICSRatedGame {Partida amb rating}
translate K FICSAutoColour {autom�tic}
translate K FICSManualConfirm {confirma manualment}
translate K FICSFilterFormula {Filtrar amb f�rmula}
translate K FICSIssueSeek {Panell de desafiaments}
translate K FICSChallenge {Desafiar}
translate K FICSAccept {acceptar}
translate K FICSDecline {refusar}
translate K FICSColour {Color}
translate K FICSSend {enviar}
translate K FICSConnect {Connectar}
translate K FICSdefaultuservars {Utilitza valors per defecte}
translate K FICSObserveconfirm {Vols observar la partida}
# ====== TODO To be translated ======
translate K FICSpremove {Enable premove}
# ====== TODO To be translated ======
translate K FICSObserve {Observe}
# ====== TODO To be translated ======
translate K FICSRatedGames {Rated Games}
# ====== TODO To be translated ======
translate K FICSUnratedGames {Unrated Games}
# ====== TODO To be translated ======
translate K FICSRated {Rated}
# ====== TODO To be translated ======
translate K FICSUnrated {Unrated}
# ====== TODO To be translated ======
translate K FICSRegisteredPlayer {Registered player only}
# ====== TODO To be translated ======
translate K FICSFreePlayer {Free player only}
# ====== TODO To be translated ======
translate K FICSNetError {Network error\nCan't connect to }
# ====== TODO To be translated ======
translate K GameReview {Game review}
# ====== TODO To be translated ======
translate K GameReviewTimeExtended {Time extended}
# ====== TODO To be translated ======
translate K GameReviewMargin {Error margin}
# ====== TODO To be translated ======
translate K GameReviewAutoContinue {Auto continue when move is correct}
# ====== TODO To be translated ======
translate K GameReviewReCalculate {Use extended time}
# ====== TODO To be translated ======
translate K GameReviewAnalyzingMovePlayedDuringTheGame {Analyzing move played during the game}
# ====== TODO To be translated ======
translate K GameReviewAnalyzingThePosition {Analyzing the position}
# ====== TODO To be translated ======
translate K GameReviewEnterYourMove {Enter your move}
# ====== TODO To be translated ======
translate K GameReviewCheckingYourMove {Checking your move}
# ====== TODO To be translated ======
translate K GameReviewYourMoveWasAnalyzed {Your move was analyzed}
# ====== TODO To be translated ======
translate K GameReviewYouPlayedSameMove {You played the same move as in match}
# ====== TODO To be translated ======
translate K GameReviewScoreOfYourMove {Score of your move}
# ====== TODO To be translated ======
translate K GameReviewGameMoveScore {Game move's score}
# ====== TODO To be translated ======
translate K GameReviewEngineScore {Engine's score}
# ====== TODO To be translated ======
translate K GameReviewYouPlayedLikeTheEngine {You played like the engine}
# ====== TODO To be translated ======
translate K GameReviewNotEngineMoveButGoodMove {Not the engine move, but is also a good move}
# ====== TODO To be translated ======
translate K GameReviewMoveNotGood {This move is not good, score is}
# ====== TODO To be translated ======
translate K GameReviewMovesPlayedLike {Moves played like}
# ====== TODO To be translated ======
translate K GameReviewMovesPlayedEngine {Moves played like engine}
translate K CCDlgConfigureWindowTitle {Configurar Escacs Postals}
translate K CCDlgCGeneraloptions {Opcions Generals}
translate K CCDlgDefaultDB {Base per defecte:}
translate K CCDlgInbox {Entrant (Carpeta):}
translate K CCDlgOutbox {Sortint (carpeta):}
translate K CCDlgXfcc {Configuraci� Xfcc:}
translate K CCDlgExternalProtocol {Protocol Extern de proc�s (ex. Xfcc)}
translate K CCDlgFetchTool {Eina de recuperaci�:}
translate K CCDlgSendTool {Eina de tramessa:}
translate K CCDlgEmailCommunication {Comunicaci� Email}
translate K CCDlgMailPrg {Programa de correu:}
translate K CCDlgBCCAddr {(B)CC Adre�a:}
translate K CCDlgMailerMode {Mode:}
translate K CCDlgThunderbirdEg {p.ex. Thunderbird, Mozilla Mail, Icedove...}
translate K CCDlgMailUrlEg {p.ex. Evolution}
translate K CCDlgClawsEg {p.ex. Sylpheed Claws}
translate K CCDlgmailxEg {p.ex. mailx, mutt, nail...}
translate K CCDlgAttachementPar {Adjunt:}
translate K CCDlgInternalXfcc {Utilitzar suport intern Xfcc}
# ====== TODO To be translated ======
translate K CCDlgConfirmXfcc {Confirma jugades}
translate K CCDlgSubjectPar {Assumpte:}
# ====== TODO To be translated ======
translate K CCDlgDeleteBoxes {Buida Entrant/Sortint}
# ====== TODO To be translated ======
translate K CCDlgDeleteBoxesText {Realment vols buidar les teves carpetes d'Entrada i Sortida d'Escacs per Correspond�ncia? Aix� requereix una nova sincronitzaci� per mostrar l'estat actual de les teves partides}
# ====== TODO To be translated ======
translate K CCDlgConfirmMove {Confirma jugada}
# ====== TODO To be translated ======
translate K CCDlgConfirmMoveText {Si ho confirmes, la propera jugada i comentari ser� enviada al servidor:}
# ====== TODO To be translated ======
translate K CCDlgDBGameToLong {L�nia principal inconsistent}
# ====== TODO To be translated ======
translate K CCDlgDBGameToLongError {la l�nia principal a la teva base es m�s llarga que la de la partida de la B�stia d'Entrada. Si la B�tia d'Entrada cont� partides actuals, p.ex. despr�s d'una sincronitzaci�, vol dir que s'han afegit jugades a la base err�niament.\nEn aquest cas escur�a la l�nia principal fins a (max) jugada\n}
translate K CCDlgStartEmail {Iniciar nova partida Email}
translate K CCDlgYourName {El teu nom:}
translate K CCDlgYourMail {La teva adre�a Email:}
translate K CCDlgOpponentName {Nom del Contrari:}
translate K CCDlgOpponentMail {Direcci� Email del Contrari:}
translate K CCDlgGameID {Partida ID (�nica):}
translate K CCDlgTitNoOutbox {Scid: Sortida del Correu d'Escacs}
translate K CCDlgTitNoInbox {Scid: Entrada del Correu d'Escacs}
translate K CCDlgTitNoGames {Scid: No hi han Partides d'Escacs Postal}
translate K CCErrInboxDir {Carpeta d'entrada del Correu d'Escacs (Entrant):}
translate K CCErrOutboxDir {Carpeta de sortida del Correu d'Escacs (Sortint):}
translate K CCErrDirNotUsable {No existeix o no es accessible!\nSi-us-plau, verifica els par�metres.}
translate K CCErrNoGames {No cont� cap partida!\nSi-us-plau, posa'n primer.}
translate K CCDlgTitNoCCDB {Scid: No es una Base d'Escacs Postals}
translate K CCErrNoCCDB {No hi ha una Base de tipus 'Correu' oberta. Si-us-plau, obre'n una abans d'utilitzar funcions d'escacs postals.}
translate K CCFetchBtn {Baixar partides des del servidor i processar correu entrant}
translate K CCPrevBtn {Anar a partida anterior}
translate K CCNextBtn {Anar a partida seg�ent }
translate K CCSendBtn {Enviar jugada}
translate K CCEmptyBtn {Correus entrants i sortints buits}
translate K CCHelpBtn {Ajut a icones e indicadors d'estatus. \n Per ajut general pr�mer F1!}
translate K CCDlgServerName {Nom del servidor:}
translate K CCDlgLoginName  {Nom de registre:}
translate K CCDlgPassword   {Contrasenya:}
# ====== TODO To be translated ======
translate K CCDlgShowPassword {Show password}
translate K CCDlgURL        {Xfcc-URL:}
translate K CCDlgRatingType {Tipus de puntuaci� (Rating):}
translate K CCDlgDuplicateGame {ID de partida no �nic}
translate K CCDlgDuplicateGameError {Aquesta partida existeix m�s d'un cop a la base. Si-us-plau esborra totes les duplicades i compacta el fitxer de partides (Arxiu/Manteniment/Compactar Base).}
# ====== TODO To be translated ======
translate K CCDlgSortOption {Sorting:}
# ====== TODO To be translated ======
translate K CCDlgListOnlyOwnMove {Only games I have the move}
# ====== TODO To be translated ======
translate K CCOrderClassicTxt {Site, Event, Round, Result, White, Black}
# ====== TODO To be translated ======
translate K CCOrderMyTimeTxt {My Clock}
# ====== TODO To be translated ======
translate K CCOrderTimePerMoveTxt {Time per move till next time control}
# ====== TODO To be translated ======
translate K CCOrderStartDate {Start date}
# ====== TODO To be translated ======
translate K CCOrderOppTimeTxt {Opponents Clock}
# ====== TODO To be translated ======
translate K CCDlgConfigRelay {Configure ICCF observations}
# ====== TODO To be translated ======
translate K CCDlgConfigRelayHelp {Go to the games page on http://www.iccf-webchess.com and display the game to be observed.  If you see the chessboard copy the URL from your browser to the list below. One URL per line only!\nExample: http://www.iccf-webchess.com/MakeAMove.aspx?id=266452}
translate K ExtHWConfigConnection {Configurar maquinari extern}
translate K ExtHWPort {Port}
translate K ExtHWEngineCmd {L�nia d'ordres del motor}
translate K ExtHWEngineParam {Par�metre del motor}
translate K ExtHWShowButton {Mostrar bot�}
translate K ExtHWHardware {Maquinari}
translate K ExtHWNovag {Novag Citrine}
translate K ExtHWInputEngine {Motor d'entrada}
translate K ExtHWNoBoard {Sense escaquer}
translate K NovagReferee {�rbitre}

# Input Engine dialogs
translate K IEConsole {Consola d'entrada del motor}
translate K IESending {Jugades enviades per}
translate K IESynchronise {Sincronitzar}
translate K IERotate  {Rotar}
translate K IEUnableToStart {Impossible comen�ar amb el motor d'entrada:}
translate K DoneWithPosition {Fet amb la posici�}
translate K Board {Escaquer}
translate K showGameInfo {Mostrar informaci� de la partida}
translate K autoResizeBoard {Tamany autom�tic de l'escaquer}
translate K DockTop {Moure amunt}
translate K DockBottom {Moure abaix}
translate K DockLeft {Moure a l'esquerra}
translate K DockRight {Moure a la dreta}
translate K Undock {Finestra flotant}
# ====== TODO To be translated ======
translate K ChangeIcon {Change icon...}
# ====== TODO To be translated ======
translate K NewGameListWindow {New Game List Window}
# ====== TODO To be translated ======
translate K LoadatStartup {Load at startup}
# ====== TODO To be translated ======
translate K ShowHideDB {Show/Hide databases}
# ====== TODO To be translated ======
translate K ChangeFilter {Change filter}
# ====== TODO To be translated ======
translate K ChangeLayout {Load/Save/Change sorting criteria and column layout}
# ====== TODO To be translated ======
translate K ShowHideStatistic {Show/Hide statistics}
# ====== TODO To be translated ======
translate K BoardFilter {Show only games that matches the current board position}
# ====== TODO To be translated ======
translate K CopyGameTo {Copy Game to}
# ====== TODO To be translated ======
translate K FindBar {Find Bar}
# ====== TODO To be translated ======
translate K FindCurrentGame {Find current game}
# ====== TODO To be translated ======
translate K DeleteGame {Delete game}
# ====== TODO To be translated ======
translate K UndeleteGame {Undelete game}
# ====== TODO To be translated ======
translate K ResetSort {Reset sort}
# ====== TODO To be translated ======
translate K ConvertNullMove {Convert null moves to comments}
# ====== TODO To be translated ======
translate K SetupBoard {Setup Board}
# ====== TODO To be translated ======
translate K Rotate {Rotate}
# ====== TODO To be translated ======
translate K SwitchColors {Switch colors}
# ====== TODO To be translated ======
translate K FlipBoard {Flip Board}
# ====== TODO To be translated ======
translate K ImportPGN {Import PGN game}
# ====== TODO To be translated ======
translate K ImportingFiles {Importing PGN files in}
# ====== TODO To be translated ======
translate K ImportingFrom {Importing from}
# ====== TODO To be translated ======
translate K ImportingIn {Import games in}
# ====== TODO To be translated ======
translate K UseLastTag {Use last\ngame's tags}
# ====== TODO To be translated ======
translate K Random {Random}
# ====== TODO To be translated ======
translate K BackToMainline {Go back to mainline}
# ====== TODO To be translated ======
translate K LeaveVariant {Leave variant}
# ====== TODO To be translated ======
translate K Autoplay {Autoplay}
# ====== TODO To be translated ======
translate K ShowHideCoords {Show/Hide Coord.}
# ====== TODO To be translated ======
translate K ShowHideMaterial {Show/Hide Material}
# ====== TODO To be translated ======
translate K FullScreen {Full Screen}
# ====== TODO To be translated ======
translate K FilterStatistic {Filter Statistics}
# ====== TODO To be translated ======
translate K MakeCorrections {Make Corrections}
# ====== TODO To be translated ======
translate K Surnames {Surnames}
# ====== TODO To be translated ======
translate K Ambiguous {Ambiguous}
translate K OptionsToolbar "Barra d'eines de la finestra principal"
translate K OptionsBoard "Escaquer"
# ====== TODO To be translated ======
translate K OptionsMenuColor "Menu colors"
translate K OptionsBoardSize "Tamany de l'escaquer"
translate K OptionsBoardPieces "Estil de peces"
# ====== TODO To be translated ======
translate K OptionsInternationalization "Internationalization"
# ====== TODO To be translated ======
translate K MenuColorForeground "Textcolor"
# ====== TODO To be translated ======
translate K MenuColorBackground "Background"
# ====== TODO To be translated ======
translate K MenuColorSelect "Select"
# ====== TODO To be translated ======
translate K OptionsTablebaseDir "Select up to 4 table base folders:"
}
# end of catalan.tcl
