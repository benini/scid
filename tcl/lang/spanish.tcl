# spanish.tcl:
# Spanish translations for Scid.
# Contributed by Jordi Gonz�lez Boada.
# Updated by Enrique Lopez.
# Updated by Benigno Hern�ndez Bacallado.
# Updated by Pedro Reina.
# Untranslated messages are marked with a "***" comment.

proc setLanguage_S {} {

# File menu:
menuText S File "Archivo" 0
menuText S FileNew "Nuevo..." 0 {Crea una nueva base de datos Scid vac�a}
menuText S FileOpen "Abrir..." 1 {Abre una base de datos Scid ya existente}
menuText S FileClose "Cerrar" 0 {Cierra la base de datos Scid activa}
menuText S FileFinder "Visor..." 0 {Abre la ventana del visor de archivos}
menuText S FileBookmarks "Partidas favoritas" 0 {Seleccionar partidas favoritas (Ctrl+B)}
menuText S FileBookmarksAdd "A�adir" 0 \
  {Se�ala la partida y posici�n actual de la base de datos}
menuText S FileBookmarksFile "Archivar" 8 \
  {Archiva un marcador para la partida y posici�n actual}
menuText S FileBookmarksEdit "Editar partidas favoritas..." 0 \
  {Edita los men�s de las partidas favoritas}
menuText S FileBookmarksList "Mostrar partidas favoritas" 0 \
  {Muestra las carpetas de favoritas en una sola lista, sin submen�s}
menuText S FileBookmarksSub "Mostrar partidas marcadas con submen�s" 0 \
  {Muestra las carpetas de favoritas como submen�s, no una sola lista}
menuText S FileMaint "Mantenimiento" 0 \
  {Herramientas de mantenimiento de la base de datos Scid}
menuText S FileMaintWin "Ventana de mantenimiento" 0 \
  {Abre/cierra la ventana de mantenimiento de la base de datos Scid}
menuText S FileMaintCompact "Compactar base de datos..." 0 \
  {Compacta los archivos de la base de datos, quitando partidas borradas y nombres no usados}
menuText S FileMaintClass "Clasificar partidas por ECO..." 24 \
  {Recalcula el c�digo ECO de todas las partidas}
menuText S FileMaintSort "Ordenar base de datos..." 0 \
  {Ordena todas las partidas de la base de datos}
menuText S FileMaintDelete "Borrar partidas dobles..." 0 \
  {Encuentra partidas dobles y las coloca para ser borradas}
menuText S FileMaintTwin "Ventana de inspecci�n de dobles" 11 \
  {Abre/actualiza la ventana de inspecci�n de dobles}
menuText S FileMaintName "Ortograf�a de nombres" 0 {Herramientas de ortograf�a y edici�n de nombres}
menuText S FileMaintNameEditor "Ventana de edici�n de nombres" 22 \
  {Abre/cierra la ventana de edici�n de nombres}
menuText S FileMaintNamePlayer "Comprobaci�n ortogr�fica de nombres de jugadores..." 39 \
  {Comprobaci�n ortogr�fica de jugadores usando archivo de comprobaci�n ortogr�fica}
menuText S FileMaintNameEvent "Comprobaci�n ortogr�fica de nombres de eventos..." 39 \
  {Comprobaci�n ortogr�fica de eventos usando el archivo de comprobaci�n ortogr�fica}
menuText S FileMaintNameSite "Comprobaci�n ortogr�fica de nombres de lugares..." 39 \
  {Comprobaci�n ortogr�fica de lugares usando el archivo de comprobaci�n ortogr�fica}
menuText S FileMaintNameRound "Comprobaci�n ortogr�fica de rondas..." 28 \
  {Comprobaci�n ortogr�fica de rondas usando el archivo de comprobaci�n ortogr�fica}
menuText S FileReadOnly "S�lo lectura..." 5 \
  {Trata la actual base de datos como de s�lo lectura, previniendo cambios}
menuText S FileSwitch "Cambiar de base de datos" 0 \
  {Cambia a una base de datos abierta diferente}
menuText S FileExit "Salir" 0 {Salir de Scid}
menuText S FileMaintFixBase "Arreglar base corrupta" 0 {Intenta arreglar una base corrupta}

# Edit menu:
menuText S Edit "Editar" 0
menuText S EditAdd "A�adir variaci�n" 0 \
  {A�ade una variaci�n a este movimiento en la partida}
menuText S EditDelete "Borrar variaci�n" 0 {Borra variaci�n para este movimiento}
menuText S EditFirst "Convertir en primera variaci�n" 0 \
  {Hace que una variaci�n sea la primera en la lista}
menuText S EditMain "Variaci�n a l�nea principal" 0 \
   {Promover una variaci�n para que sea la l�nea principal}
menuText S EditTrial "Probar variaci�n" 1 \
  {Inicia/para el modo de prueba, para ensayar una idea en el tablero}
menuText S EditStrip "Eliminar" 2 \
  {Elimina comentarios o variaciones de esta partida}
menuText S EditUndo "Deshacer" 0 {Deshace el �ltimo cambio en la partida}
# ====== TODO To be translated ======
menuText S EditRedo "Redo" 0 {Redo last game change}
menuText S EditStripComments "Comentarios" 0 \
  {Quita todos los comentarios y variaciones de esta partida}
menuText S EditStripVars "Variaciones" 0 {Quita todas las variaciones de esta partida}
menuText S EditStripBegin "Movimientos desde el principio" 1 \
  {Quita los movimientos desde el principio de la partida}
menuText S EditStripEnd "Movimientos hasta el final" 0 \
  {Quita los movimientos hasta el final de la partida}
menuText S EditReset "Poner a cero la base de trabajo" 0 \
  {Pone a cero la base de trabajo (clipbase) para que est� completamente vac�a}
menuText S EditCopy "Copiar esta partida a la base de trabajo" 1 \
  {Copia esta partida a la base de trabajo (clipbase)}
menuText S EditPaste "Pegar la �ltima partida de la base de trabajo" 2 \
  {Pega en la base actual la partida activa en la base de trabajo (clipbase)}
menuText S EditPastePGN "Pegar el texto del portapapeles como partida PGN..." 10 \
  {Interpreta el texto de la base de trabajo (clipbase) como una partida en notaci�n PGN y la pega aqu�}
menuText S EditSetup "Iniciar tablero de posici�n..." 26 \
  {Inicia el tablero de posici�n con la posici�n de la partida}
menuText S EditCopyBoard "Copiar posici�n" 8 \
  {Copia el tablero actual en notaci�n FEN al portapapeles}
menuText S EditPasteBoard "Pegar tablero inicial" 6 \
  {Coloca el tablero inicial en el portapapeles}
# ====== TODO To be translated ======
menuText S ConfigureScid "Preferences..." 0 {Configure all options for SCID}

# Game menu:
menuText S Game "Partida" 0
menuText S GameNew "Partida nueva" 0 \
  {Partida nueva, descarta cambios de la partida actual}
menuText S GameFirst "Cargar primera partida" 7 {Carga la primera partida filtrada}
menuText S GamePrev "Cargar partida anterior" 16 {Carga la anterior partida filtrada}
menuText S GameReload "Recargar partida actual" 0 \
  {Vuelve a cargar esta partida, descartando cualquier cambio hecho}
menuText S GameNext "Cargar siguiente partida" 7 {Carga la siguiente partida filtrada}
menuText S GameLast "Cargar �ltima partida" 9 {Carga la �ltima partida filtrada}
menuText S GameRandom "Cargar partida aleatoria" 16 {Carga aleatoriamente una partida filtrada}
menuText S GameNumber "Cargar partida n�mero..." 3 \
  {Carga una partida poniendo su n�mero}
menuText S GameReplace "Guardar: reemplazar partida..." 10 \
  {Guarda esta partida, reemplazando la antigua versi�n}
menuText S GameAdd "Guardar: a�adir nueva partida..." 9 \
  {Guarda esta partida como una nueva partida en la base de datos}
menuText S GameDeepest "Identificar apertura" 1 \
  {Va a la posici�n m�s avanzada de la partida seg�n el libro ECO}
menuText S GameGotoMove "Ir al movimiento n�mero..." 6 \
  {Ir al n�mero de movimiento especificado en la partida actual}
menuText S GameNovelty "Encontrar novedad..." 12 \
  {Encuentra el primer movimiento de esta partida que no se ha jugado antes}

# Search Menu:
menuText S Search "Buscar" 0
menuText S SearchReset "Poner a cero el filtro" 0 \
  {Pone a cero el filtro para que todas la partidas est�n incluidas}
menuText S SearchNegate "Invertir filtro" 0 \
  {Invierte el filtro para s�lo incluir las partidas excluidas}
menuText S SearchCurrent "Tablero actual..." 0 \
  {Busca por la posici�n actual del tablero}
menuText S SearchHeader "Encabezamiento..." 0 \
  {Busca por informaci�n de encabezamiento (jugador, evento, etc.)}
menuText S SearchMaterial "Material/Patr�n..." 0 \
  {Busca por material o patr�n del tablero}
menuText S SearchUsing "Usar archivo de b�squeda..." 0 \
  {Busca usando un archivo de opciones de b�squeda}

# Windows menu:
menuText S Windows "Ventanas" 0
menuText S WindowsComment "Editor de comentarios" 0 \
  {Abre/cierra el editor de comentarios}
menuText S WindowsGList "Listado de partidas" 0 \
  {Abre/cierra la  ventana de listado de partidas}
menuText S WindowsPGN "Ventana PGN" 8 \
  {Abre/cierra la ventana de PGN (notaci�n de partida)}
menuText S WindowsPList "Buscador de jugadores" 2 {Abre/cierra el buscador de jugadores}
menuText S WindowsTmt "Visor de torneos" 9 {Abre/cierra el visor de torneos}
menuText S WindowsSwitcher "Bases de datos" 0 \
  {Abre/cierra la ventana de bases de datos}
menuText S WindowsMaint "Ventana de mantenimiento" 11 \
  {Abre/cierra la ventana de mantenimiento}
menuText S WindowsECO "Buscador ECO" 0 {Abre/cierra la ventana del buscador ECO}
menuText S WindowsStats "Ventana de estad�sticas" 12 \
  {Abre/cierra la ventana de estad�sticas del filtro}
menuText S WindowsTree "Ventana de �rbol de aperturas" 6 {Abre/cierra la ventana de �rbol de aperturas (Book)}
menuText S WindowsTB "Ventana de tablas de finales (TBs)" 8 \
  {Abre/cierra la ventana de TBs}
menuText S WindowsBook "Ventana de libros de aperturas (Book)" 0 {Abrir/Cerrar la ventana de libros de aperturas (Book)}
menuText S WindowsCorrChess "Ventana de Correo" 0 {Abrir/Cerrar la ventra de Correo}

# Tools menu:
menuText S Tools "Herramientas" 0
menuText S ToolsAnalysis "Motor de an�lisis #1..." 0 \
  {Inicia/para el an�lisis del motor de ajedrez #1}
menuText S ToolsAnalysis2 "Motor de an�lisis #2..." 18 \
  {Inicia/para el an�lisis del motor de ajedrez #2}
menuText S ToolsCross "Tabla cruzada" 0 {Muestra la tabla cruzada para esta partida}
menuText S ToolsEmail "Administrador de Email" 0 \
  {Abre/cierra la ventana del administrador de Email}
menuText S ToolsFilterGraph "Filtro gr�fico" 7 \
  {Abre/cierra la ventana del filtro gr�fico}
menuText S ToolsAbsFilterGraph "Filtro gr�fico Abs." 7 {Abrir/Cerrar la ventana de filtro gr�fico para valores absolutos}
menuText S ToolsOpReport "Informe de la apertura" 1 \
  {Crea un informe de la apertura para la posici�n actual}
menuText S ToolsOpenBaseAsTree "Abrir base como �rbol" 0   {Abrir una base y usarla en la ventana de �rbol (Tree)}
menuText S ToolsOpenRecentBaseAsTree "Abrir base reciente como �rbol" 0   {Abre una base reciente y la usa en ventana de �rbol (Tree)} 
menuText S ToolsTracker "Rastreador de piezas"  14 {Abre la ventana del rastreador de piezas}
menuText S ToolsTraining "Entrenamiento"  0 {Entrenamiento (t�ctica, aperturas,...)}
menuText S ToolsTacticalGame "Partida t�ctica..."  0 {Juega una partida t�ctica}
menuText S ToolsSeriousGame "Partida seria..."  0 {Juega una partida seria}
menuText S ToolsTrainOpenings "Entrenamiento de aperturas"  0 {Entrenamiento con un repertorio}
menuText S ToolsTrainReviewGame "Revisar partida"  0 {Adivina movimientos jugados en una partida}
menuText S ToolsTrainTactics "T�ctica (problemas)"  0 {Resuelve problemas de t�ctica}
menuText S ToolsTrainCalvar "C�lculo de variaciones"  0 {C�lculo de variaciones}
menuText S ToolsTrainFindBestMove "Encontrar la mejor jugada"  0 {Busca el movimiento mejor}
menuText S ToolsTrainFics "Jugar en internet..."  0 {Conecta a freechess.org}
# ====== TODO To be translated ======
menuText S ToolsEngineTournament "Engine tournament"  0 {Start a tournament between chess engines}
menuText S ToolsBookTuning "Sintonizar libro de aperturas" 0 {Sintoniza el libro (Book)}
menuText S ToolsConnectHardware "Conectar hardware" 0 {Conecta hardware externo"}
menuText S ToolsConnectHardwareConfigure "Configuraci�n..." 1 {Configuraci�n}
menuText S ToolsConnectHardwareNovagCitrineConnect "Conectar Novag" 0 {Conecta Novag}
menuText S ToolsConnectHardwareInputEngineConnect "Conectar motor de entrada" 0 {Conecta un motor de entrada (e.d. DGT)}
menuText S ToolsPInfo "Informaci�n del jugador" 16 \
  {Abre/actualiza la ventana de informaci�n del jugador}
menuText S ToolsPlayerReport "Informe del jugador..." 3 \
  {Crea un informe sobre un jugador}
menuText S ToolsRating "Gr�fico del Elo..." 0 \
  {Gr�fico de la historia del Elo de los jugadores de la actual partida}
menuText S ToolsScore "Gr�fico de puntuaci�n..." 1 \
  {Muestra la ventana del gr�fico de puntuaci�n}
menuText S ToolsExpCurrent "Exportar la partida actual..." 0 \
  {Escribe la partida actual en un archivo de texto}
menuText S ToolsExpCurrentPGN "Exportar la partida a un archivo PGN..." 33 \
  {Escribe la partida actual en un archivo PGN}
menuText S ToolsExpCurrentHTML "Exportar la partida a un archivo HTML..." 33 \
  {Escribe la partida actual en un archivo HTML}
menuText S ToolsExpCurrentHTMLJS "Exportar la partida a un archivo HTML y JavaScript..." 15 \
  {Escribe la partida actual a un fichero HTML y JavaScript} 
menuText S ToolsExpCurrentLaTeX "Exportar la partida a un archivo LaTeX..." 33 \
  {Escribe la partida actual en un archivo LaTeX}
menuText S ToolsExpFilter "Exportar todas las partidas filtradas..." 1 \
  {Escribe todas las partidas filtradas en un archivo de texto}
menuText S ToolsExpFilterPGN "Exportar filtro a un archivo PGN..." 29 \
  {Escribe todas las partidas filtradas en un archivo PGN}
menuText S ToolsExpFilterHTML "Exportar filtro a un archivo HTML..." 29 \
  {Escribe todas las partidas filtradas en un archivo HTML}
menuText S ToolsExpFilterHTMLJS "Exportar filtro a un archivo HTML y JavaScript..." 17 \
  {Escribe todas las partidas filtradas a ficheros HTML y JavaScript}  
menuText S ToolsExpFilterLaTeX "Exportar filtro a un archivo LaTeX..." 29 \
  {Escribe todas las partidas filtradas en un archivo LaTeX}
menuText S ToolsImportOne "Importar una partida PGN..." 0 \
  {Importa una partida de un texto PGN}
menuText S ToolsImportFile "Importar un archivo de partidas PGN..." 2 \
  {Importa partidas de un archivo PGN}
menuText S ToolsStartEngine1 "Empezar motor 1" 0  {Empieza el motor 1}
menuText S ToolsStartEngine2 "Empezar motor 2" 0  {Empieza el motor 2}
menuText S ToolsCaptureBoard "Capturar Tablero Actual..." 0  {Guardar el tablero actual como imagen.}
menuText S Play "Jugar" 0
menuText S CorrespondenceChess "Ajedrez por correo" 0 \
  {Funciones para ajedrez por correo basado en email y Xfcc}
menuText S CCConfigure "Configurar..." 0 \
  {Configura herramientas externas y configuraci�n general}
menuText S CCConfigRelay "Configurar observaciones..." 10 {Configurar partidas para ser observadas}
menuText S CCOpenDB "Abrir base de datos..." 0 \
  {Abrir la base de correo por defecto}
menuText S CCRetrieve "Reparar partidas" 0 \
  {Repara partidas v�a ayuda externa (Xfcc)}
menuText S CCInbox "Procesar correo entrante" 0 \
  {Procesa todos los ficheros en correo entrante de Scid (Inbox)}
menuText S CCSend "Enviar movimiento" 0 \
  {Envia tu movimiento via eMail o ayuda externa (Xfcc)}
menuText S CCResign "Abandonar" 0 {Abandona}
menuText S CCClaimDraw "Reclamar tablas" 0 \
  {Envia un movimiento y reclama tablas}
menuText S CCOfferDraw "Ofrecer tablas" 0 \
  {Envia un movimiento y ofrecer tablas}
menuText S CCAcceptDraw "Aceptar tablas" 0 {Acepta un ofrecimiento de tablas}
menuText S CCNewMailGame "Nueva partida email..." 0 \
  {Empeza una nueva partida por email}
menuText S CCMailMove "Enviar jugada via email..." 0 \
  {Env�a el movimiento via email al oponente}
menuText S CCGamePage "P�gina de la partida..." 0 \
  {Abre la partida desde el navegador}
menuText S CCEditCopy "Copiar lista de partidas a Clipbase" 0 \
  {Copia las partidas como una lista CSV a Clipbase}

# Options menu:
menuText S Options "Opciones" 0
menuText S OptionsBoardGraphics "Escaques..." 0 {Elige texturas para escaques}
translate S OptionsBGW {Elegir textura para escaques}
translate S OptionsBoardGraphicsText {Elegir fichero gr�fico para escaques blancos y negros}
menuText S OptionsBoardNames "Nombres de jugador..." 0 {Edita lista de nombres de jugador}
menuText S OptionsExport "Exportaci�n" 0 {Cambia las opciones de exportaci�n de texto}
menuText S OptionsFonts "Fuentes" 0 {Cambia las fuentes}
menuText S OptionsFontsRegular "Habitual" 0 {Cambia la fuente habitual}
menuText S OptionsFontsMenu "Men�" 0 {Cambia la fuente del men�}
menuText S OptionsFontsSmall "Peque�a" 0 {Cambia la fuente peque�a}
menuText S OptionsFontsTiny "Tiny" 0 {Cambia la fuente diminuta}
menuText S OptionsFontsFixed "Ancho fijo" 0 {Cambia la fuente de ancho fijo}
menuText S OptionsGInfo "Informaci�n de la partida" 0 {Informaci�n de la partida}
menuText S OptionsLanguage "Idioma" 0 {Selecciona el idioma del programa}
menuText S OptionsMovesTranslatePieces "Traducir piezas" 0 \
  {Traduce la primera letra de las piezas}
menuText S OptionsMovesHighlightLastMove "Iluminar �ltima jugada" 0 \
  {Ilumina la �ltima jugada}
menuText S OptionsMovesHighlightLastMoveDisplay "Mostrar" 0 \
  {Muestra la �ltima jugada iluminada}
menuText S OptionsMovesHighlightLastMoveWidth "Ancho" 0 {Espesor de la l�nea}
menuText S OptionsMovesHighlightLastMoveColor "Color" 0 {Color de l�nea}
# ====== TODO To be translated ======
menuText S OptionsMovesHighlightLastMoveArrow "include Arrow" 0 {Include Arrow with Highlight}
menuText S OptionsMoves "Movimientos" 0 {Opciones de la entrada de movimientos}
menuText S OptionsMovesAnimate "Velocidad de la animaci�n" 1 \
  {Pone el tiempo usado para animar las jugadas}
menuText S OptionsMovesDelay "Demora del automovimiento..." 0 \
  {Pone el tiempo de demora para el modo de automovimiento}
menuText S OptionsMovesCoord "Entrada de movimientos coordinada" 0 \
  {Acepta entrada de movimientos en sistema "coordinado" ("g1f3")}
menuText S OptionsMovesSuggest "Mostrar movimientos sugeridos" 20 \
  {Activa/desactiva la sugerencia de movimientos}
menuText S OptionsShowVarPopup "Mostrar ventana de variaciones" 0 \
  {Activa/desactiva la ventana de variaciones}
menuText S OptionsMovesSpace "A�adir espacios detr�s del n�mero de movimiento" 0 \
  {A�ade espacios detr�s del n�mero de movimiento}
menuText S OptionsMovesKey "Teclado inteligente" 0 \
  {Activa/desactiva la funci�n de autocompletado inteligente de movimientos con teclado}
menuText S OptionsMovesShowVarArrows "Mostrar flechas para las variaciones" 0 \
  {Activa/desactiva mostrar flechas para las variaciones}
# ====== TODO To be translated ======
menuText S OptionsMovesGlossOfDanger "Color Coded Gloss of Danger" 0 {Turn on/off color coded gloss of danger}
menuText S OptionsNumbers "Formato de n�meros" 11 \
  {Selecciona el formato de n�meros}
menuText S OptionsTheme "Tema" 0 {Cambia el aspecto del interfaz}
menuText S OptionsWindows "Ventanas" 0 {Opciones de ventana}
menuText S OptionsSounds "Sonidos" 2 \
  {Configura el sonido del anuncio de las jugadas}
# ====== TODO To be translated ======
menuText S OptionsResources "Resources..." 0 {Choose resource files and folders}
menuText S OptionsWindowsDock "Ventanas en dique" 0 {Ventanas en dique}
menuText S OptionsWindowsSaveLayout "Salvar disposici�n" 0 {Salva la disposici�n}
menuText S OptionsWindowsRestoreLayout "Restaurar disposici�n" 0 \
  {Restaura la disposici�n}
menuText S OptionsWindowsShowGameInfo "Mostrar informaci�n de la partida" 0 \
  {Muestrar informaci�n de la partida}
menuText S OptionsWindowsAutoLoadLayout "Auto cargar primera disposici�n" 0 \
  {Autocarga la primera disposici�n al iniciar}
menuText S OptionsECO "Cargar archivo ECO" 7 \
  {Cargar el archivo de clasificaci�n ECO}
menuText S OptionsSpell "Cargar archivo de comprobaci�n ortogr�fica" 2 \
  {Carga el archivo de comprobaci�n ortogr�fica Scid}
menuText S OptionsTable "Directorio de las tablas de finales (TB)" 19 \
  {Selecciona el directorio de tablas finales; todas las TB de ese directorio ser�n usadas}
menuText S OptionsRecent "Archivos recientes..." 9 \
  {Cambia el n�mero de archivos recientes mostrados en el men� Archivo}
menuText S OptionsBooksDir "Carpeta de libros de aperturas" 0 \
  {Fija la carpeta de los libros de aperturas (Books)}
menuText S OptionsTacticsBasesDir "Carpeta de bases de datos" 0 \
  {Fija la carpeta de la base de entrenamiento t�ctico}
# ====== TODO To be translated ======
menuText S OptionsPhotosDir "Photos directory" 0 {Sets the photos bases directory}
# ====== TODO To be translated ======
menuText S OptionsThemeDir "Theme(s) File:"  0 { Load a GUI theme package file }
menuText S OptionsSave "Guardar opciones" 0 \
  "Guarda todas las opciones en el fichero $::optionsFile"
menuText S OptionsAutoSave "Autoguardar opciones al salir" 0 \
  {Guarda autom�ticamente todas las opciones cuando se sale de Scid}

# Help menu:
menuText S Help "Ayuda" 1
menuText S HelpContents "Contenidos" 0 {Show the help contents page}
menuText S HelpIndex "�ndice" 0 {Muestra la p�gina �ndice de la ayuda}
menuText S HelpGuide "Gu�a r�pida" 0 {Muestra la p�gina de la ayuda gu�a r�pida}
menuText S HelpHints "Sugerencias" 1 {Muestra la p�gina de la ayuda sugerencias}
menuText S HelpContact "Informaci�n de contacto" 15 \
  {Muestra la p�gina de la ayuda de la informaci�n de contacto}
menuText S HelpTip "Sugerencia del d�a" 0 {Muestra una �til sugerencia para Scid}
menuText S HelpStartup "Ventana de inicio" 0 {Muestra la ventana de inicio}
menuText S HelpAbout "Acerca de Scid" 10 {Informaci�n acerca de Scid}

# Game info box popup menu:
menuText S GInfoHideNext "Ocultar siguiente movimiento" 0
menuText S GInfoMaterial "Mostrar valor del material" 0
menuText S GInfoFEN "Mostrar FEN" 8
menuText S GInfoMarks "Mostrar casillas y flechas coloreadas" 29
menuText S GInfoWrap "Dividir l�neas largas" 0
menuText S GInfoFullComment "Mostrar comentarios completos" 8
menuText S GInfoPhotos "Mostrar fotos" 5
menuText S GInfoTBNothing "TBs: nada" 5
menuText S GInfoTBResult  "TBs: s�lo resultado" 10
menuText S GInfoTBAll "TBs: resultado y mejor movimiento" 23
menuText S GInfoDelete "(No)Borrar esta partida" 4
menuText S GInfoMark "(No)Marcar esta partida" 4
menuText S GInfoInformant "Configurar valores de informaci�n" 0

# General buttons:
translate S Back {Atr�s}
translate S Browse {Hojear}
translate S Cancel {Cancelar}
translate S Continue {Continuar}
translate S Clear {Limpiar}
translate S Close {Cerrar}
translate S Contents {Contenidos}
translate S Defaults {Por defecto}
translate S Delete {Borrar}
translate S Graph {Gr�fico}
translate S Help {Ayuda}
translate S Import {Importar}
translate S Index {�ndice}
translate S LoadGame {Cargar partida}
translate S BrowseGame {Hojear partida}
translate S MergeGame {Incorporar partida}
translate S MergeGames {Mezclar o fusionar partidas}
translate S Preview {Vista previa}
translate S Revert {Retroceder}
translate S Save {Guardar}
translate S Search {Buscar}
translate S Stop {Parar}
translate S Store {Almacenar}
translate S Update {Actualizar}
translate S ChangeOrient {Cambiar orientaci�n de la ventana}
translate S ShowIcons {Mostrar iconos}
translate S None {Ninguno}
translate S First {Primera}
translate S Current {Actual}
translate S Last {�ltima}

# General messages:
translate S game {partida}
translate S games {partidas}
translate S move {movimiento}
translate S moves {movimientos}
translate S all {todo}
translate S Yes {S�}
translate S No {No}
translate S Both {Ambos}
translate S King {Rey}
translate S Queen {Dama}
translate S Rook {Torre}
translate S Bishop {Alfil}
translate S Knight {Caballo}
translate S Pawn {Pe�n}
translate S White {Blancas}
translate S Black {Negras}
translate S Player {Jugador}
translate S Rating {Elo}
translate S RatingDiff {Diferencia de Elo (Blancas - Negras)}
translate S AverageRating {Elo promedio}
translate S Event {Evento}
translate S Site {Lugar}
translate S Country {Pa�s}
translate S IgnoreColors {Ignorar colores}
translate S Date {Fecha}
translate S EventDate {Evento fecha}
translate S Decade {D�cada}
translate S Year {A�o}
translate S Month {Mes}
translate S Months {enero febrero marzo abril mayo junio julio agosto septiembre octubre noviembre diciembre}
translate S Days {dom lun mar mi� jue vie s�b}
translate S YearToToday {�ltimo a�o hasta hoy}
# ====== TODO To be translated ======
translate S YearToTodayTooltip {Set date from 1 year back to today}
translate S Result {Resultado}
translate S Round {Ronda}
translate S Length {Longitud}
translate S ECOCode {C�digo ECO}
translate S ECO {ECO}
translate S Deleted {Borrar}
translate S SearchResults {Buscar resultados}
translate S OpeningTheDatabase {Abriendo base de datos}
translate S Database {Base de datos}
translate S Filter {Filtro}
translate S noGames {no hay partidas}
translate S allGames {todas las partidas}
translate S empty {vac�a}
translate S clipbase {clipbase}
translate S score {puntuaci�n}
translate S StartPos {Posici�n inicial}
translate S Total {Total}
translate S readonly {s�lo lectura}

# Standard error messages:
translate S ErrNotOpen {Esta base de datos no est� abierta.}
translate S ErrReadOnly {Esta base de datos es de s�lo lectura; no puede ser cambiada.}
translate S ErrSearchInterrupted {La busqueda se interrumpi�; los resultados son incompletos.}

# Game information:
translate S twin {doble}
translate S deleted {borradas}
translate S comment {comentario}
translate S hidden {oculto}
translate S LastMove {�ltimo movimiento}
translate S NextMove {Siguiente}
translate S GameStart {Inicio de partida}
translate S LineStart {Inicio de l�nea}
translate S GameEnd {Fin de partida}
translate S LineEnd {Fin de l�nea}

# Player information:
translate S PInfoAll {Resultados para <b>todas</b> las partidas}
translate S PInfoFilter {Resultados para las partidas <b>filtradas</b>}
translate S PInfoAgainst {Resultados contra}
translate S PInfoMostWhite {Aperturas m�s comunes con blancas}
translate S PInfoMostBlack {Aperturas m�s comunes con negras}
translate S PInfoRating {Historial de clasificaci�n}
translate S PInfoBio {Biograf�a}
translate S PInfoEditRatings {Editar Elos}
# ====== TODO To be translated ======
translate S PInfoEloFile {File}

# Tablebase information:
translate S Draw {Tablas}
translate S stalemate {rey ahogado}
translate S withAllMoves {con todos los movimientos}
translate S withAllButOneMove {con todos los movimientos excepto uno}
translate S with {con}
translate S only {s�lo}
translate S lose {formas de perder}
translate S loses {hace perder}
translate S allOthersLose {todos los dem�s hacen perder}
translate S matesIn {mate en}
translate S hasCheckmated {jaque mate}
translate S longest {el mate m�s largo}
translate S WinningMoves {Movimientos ganadores}
translate S DrawingMoves {Movimientos para tablas}
translate S LosingMoves {Movimientos perdedores}
translate S UnknownMoves {Movimientos de resultado desconocido}
# ====== TODO To be translated ======
translate S SideLongest {Side    Longest    %     %     %\n}
# ====== TODO To be translated ======
translate S toNoveMate {to move   mate    Win  Draw  Loss\n}
# ====== TODO To be translated ======
translate S NoSummary {\nNo summary for this tablebase.}
# ====== TODO To be translated ======
translate S MutualZugzwang {Mutual zugzwangs: }
# ====== TODO To be translated ======
translate S SelectetZugzwang {\nSelected zugzwang positions:}
# ====== TODO To be translated ======
translate S WdrawBloss {White draws, Black loses:}
# ====== TODO To be translated ======
translate S BdrawWloss {Black draws, White loses:}
# ====== TODO To be translated ======
translate S AllLoss {" Whoever moves loses:     " }

# Tip of the day:
translate S Tip {Sugerencia}
translate S TipAtStartup {Sugerencia al iniciar}

# Tree window menus:
menuText S TreeFile "Archivo" 0
menuText S TreeFileFillWithBase "Rellenar cach� con base" 0 \
  {Rellena el archivo cach� con todas las partidas de la base actual}
menuText S TreeFileFillWithGame "Rellenar cach� con partida" 0 \
  {Rellena el fichero cach� con movimientos de la partida actual en la base actual}
menuText S TreeFileSetCacheSize "Tama�o de cach�" 0 {Fija el tama�o del cach�}
menuText S TreeFileCacheInfo "Informaci�n de cach�" 0 \
  {Informaci�n y uso del cach�}
menuText S TreeFileSave "Guardar archivo cach�" 0 \
  {Guarda el archivo cach� del �rbol (.stc)}
menuText S TreeFileFill "Construir archivo cach�" 2 \
  {Construye archivo cach� con posiciones de apertura comunes}
menuText S TreeFileBest "Lista de mejores partidas" 9 \
  {Muestra la lista del �rbol de mejores partidas}
menuText S TreeFileGraph "Ventana del gr�fico" 0 \
  {Muestra el gr�fico para esta rama del �rbol}
menuText S TreeFileCopy "Copiar texto del �rbol al portapapeles" 1 \
  {Copia texto del �rbol al portapapeles}
menuText S TreeFileClose "Cerrar ventana del �rbol" 0 \
  {Cerra ventana del �rbol}
menuText S TreeMask "M�scara" 0
menuText S TreeMaskNew "Nuevo" 0 {Nueva m�scara}
menuText S TreeMaskOpen "Abrir" 0 {Abre m�scara}
menuText S TreeMaskOpenRecent "Abrir reciente" 0 {Abre m�scara reciente}
menuText S TreeMaskSave "Salvar" 0 {Salva m�scara}
menuText S TreeMaskClose "Cerrar" 0 {Cierra m�scara}
menuText S TreeMaskFillWithGame "Llenar con partida" 0 \
  {Llena m�scara con partida}
menuText S TreeMaskFillWithBase "Llenar con base" 0 \
  {Llena m�scara con todas las partidas de la base}
menuText S TreeMaskInfo "Info" 0 {Muestra estad�sticas para la m�scara actual}
menuText S TreeMaskDisplay "Mostrar mapa de la m�scara" 0 \
  {Muestra m�scara en forma de �rbol}
menuText S TreeMaskSearch "Buscar" 0 {Busca en m�scara actual}
menuText S TreeSort "Ordenar" 0
menuText S TreeSortAlpha "Alfab�ticamente" 0
menuText S TreeSortECO "Por c�digo ECO" 11
menuText S TreeSortFreq "Por frecuencia" 4
menuText S TreeSortScore "Por puntuaci�n" 4
menuText S TreeOpt "Opciones" 1
menuText S TreeOptSlowmode "Modo Lento" 0 \
  {Movimiento lento para actualizaciones (alta calidad)}
menuText S TreeOptFastmode "Modo R�pido" 0 \
  {Movimiento r�pido para actualizaciones (no transpone movimientos)}
menuText S TreeOptFastAndSlowmode "Modo r�pido y lento" 0 \
  {Movimiento r�pido y modo lento para actualizaciones}
menuText S TreeOptStartStop "Auto actualizado" 0 \
  {Actualizado autom�tico de la ventana del �rbol}
menuText S TreeOptLock "Bloquear" 1 \
  {Bloquea/desbloquea el �rbol de la base de datos actual}
menuText S TreeOptTraining "Entrenamiento" 2 \
  {Activa/desactiva el modo de entrenamiento de �rbol}
menuText S TreeOptAutosave "Autoguardar archivo cach�" 0 \
  {Guarda autom�ticamente el archivo cach� cuando se cierra la ventana de �rbol}
menuText S TreeHelp "Ayuda" 1
menuText S TreeHelpTree "Ayuda del �rbol" 4
menuText S TreeHelpIndex "�ndice de la ayuda" 0
translate S SaveCache {Guardar cach�}
translate S Training {Entrenamiento}
translate S LockTree {Bloquear}
translate S TreeLocked {Bloqueado}
translate S TreeBest {Mejor}
translate S TreeBestGames {Mejores partidas del �rbol}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate S TreeTitleRow \
  {    Movim. ECO       Frecuencia   Puntu. AvElo Perf AvA�o %Tablas}
translate S TreeTotal {TOTAL}
translate S DoYouWantToSaveFirst {�Quieres salvar primero?}
translate S AddToMask {A�adir a m�scara}
translate S RemoveFromMask {Eliminar desde la m�scara}
translate S AddThisMoveToMask {A�adir este movimiento a la M�scara}
translate S SearchMask {Buscar en m�scara}
translate S DisplayMask {Mostrar m�scara}
translate S Nag {C�digo de rega�o}
translate S Marker {Marcador}
translate S Include {Incluir}
translate S Exclude {Excluir}
translate S MainLine {L�nea principal}
translate S Bookmark {Marcador}
translate S NewLine {L�nea nueva}
translate S ToBeVerified {Para ser verificado}
translate S ToTrain {Para entrenar}
translate S Dubious {Dudoso}
translate S ToRemove {Para quitar}
translate S NoMarker {Sin marcador}
translate S ColorMarker {Color}
translate S WhiteMark {Blanco}
translate S GreenMark {Verde}
translate S YellowMark {Amarillo}
translate S BlueMark {Azul}
translate S RedMark {Rojo}
translate S CommentMove {Comentar movimiento}
translate S CommentPosition {Comentar posici�n}
translate S AddMoveToMaskFirst {A�adir primero el movimiento a la m�scara}
translate S OpenAMaskFileFirst {Abrir primero un fichero de m�scara}
translate S Positions {Posiciones}
translate S Moves {Jugadas}

# Finder window:
menuText S FinderFile "Archivo" 0
menuText S FinderFileSubdirs "Mirar en subdirectorios" 0
menuText S FinderFileClose "Cierra visor de archivos" 0
menuText S FinderSort "Ordenar" 0
menuText S FinderSortType "Tipo" 0
menuText S FinderSortSize "Tama�o" 0
menuText S FinderSortMod "Modificado" 0
menuText S FinderSortName "Nombre" 0
menuText S FinderSortPath "Camino" 0
menuText S FinderTypes "Tipos" 0
menuText S FinderTypesScid "Bases de datos Scid" 0
menuText S FinderTypesOld "Bases de datos Scid en formato antiguo" 12
menuText S FinderTypesPGN "Archivos PGN" 9
menuText S FinderTypesEPD "Archivos EPD (libro)" 0
menuText S FinderTypesRep "Archivos de repertorio" 12
menuText S FinderHelp "Ayuda" 1
menuText S FinderHelpFinder "Ayuda del visor de archivos" 0
menuText S FinderHelpIndex "�ndice de la ayuda" 0
translate S FileFinder {Visor de archivos}
translate S FinderDir {Directorio}
translate S FinderDirs {Directorios}
translate S FinderFiles {Archivos}
translate S FinderUpDir {Arriba}
translate S FinderCtxOpen {Abrir}
translate S FinderCtxBackup {Copia de seguridad (Backup)}
translate S FinderCtxCopy {Copia}
translate S FinderCtxMove {Jugada}
translate S FinderCtxDelete {Borrar}

# Player finder:
menuText S PListFile "Archivo" 0
menuText S PListFileUpdate "Actualizar" 0
menuText S PListFileClose "Cierra el buscador de jugadores" 0
menuText S PListSort "Ordenar" 0
menuText S PListSortName "Nombre" 0
menuText S PListSortElo "Elo" 0
menuText S PListSortGames "Partidas" 0
menuText S PListSortOldest "M�s antiguo" 10
menuText S PListSortNewest "M�s nuevo" 4

# Tournament finder:
menuText S TmtFile "Archivo" 0
menuText S TmtFileUpdate "Actualizar" 0
menuText S TmtFileClose "Cierra el visor de torneos" 0
menuText S TmtSort "Ordenar" 0
menuText S TmtSortDate "Fecha" 0
menuText S TmtSortPlayers "Jugadores" 0
menuText S TmtSortGames "Partidas" 0
menuText S TmtSortElo "Elo" 0
menuText S TmtSortSite "Lugar" 0
menuText S TmtSortEvent "Evento" 1
menuText S TmtSortWinner "Ganador" 0
translate S TmtLimit "L�mite de lista"
translate S TmtMeanElo "Media de Elo inferior"
translate S TmtNone "No se han encontrado torneos concordantes."

# Graph windows:
menuText S GraphFile "Archivo" 0
menuText S GraphFileColor "Guardar como Postscript en color..." 24
menuText S GraphFileGrey "Guardar como Postscript en escala de grises..." 34
menuText S GraphFileClose "Cerrar ventana" 7
menuText S GraphOptions "Opciones" 0
menuText S GraphOptionsWhite "Blancas" 0
menuText S GraphOptionsBlack "Negras" 0
menuText S GraphOptionsBoth "Ambos" 0
menuText S GraphOptionsPInfo "Jugador Informaci�n jugador" 0
# ====== TODO To be translated ======
menuText S GraphOptionsEloFile "Elo from rating file" 0
# ====== TODO To be translated ======
menuText S GraphOptionsEloDB "Elo from database" 0
translate S GraphFilterTitle "Filtro gr�fico: frecuencia por 1000 partidas"
translate S GraphAbsFilterTitle "Filtro gr�fico: frecuencia de las partidas"
translate S ConfigureFilter {Configurar Eje-X para A�o, Rating y Movimientos}
translate S FilterEstimate "Estimar"
translate S TitleFilterGraph "Scid: Filtro Gr�fico"

# Analysis window:
translate S AddVariation {A�adir variaci�n}
translate S AddAllVariations {A�adir todas las variaciones}
translate S AddMove {A�adir movimiento}
translate S Annotate {Anotar}
translate S ShowAnalysisBoard {Mostrar tablero de an�lisis}
translate S ShowInfo {Muestra info del motor}
translate S FinishGame {Finalizar partida}
translate S StopEngine {Parar motor}
translate S StartEngine {Empezar motor}
translate S LockEngine {Bloquea motor en posici�n actual}
translate S AnalysisCommand {Direcci�n de an�lisis}
translate S PreviousChoices {Elecci�n previa}
translate S AnnotateTime {Poner el tiempo entre movimientos en segundos}
translate S AnnotateWhich {A�adir variaciones}
translate S AnnotateAll {Para movimientos de ambos lados}
translate S AnnotateAllMoves {Anotar todos los movimientos}
translate S AnnotateWhite {S�lo para movimientos de las blancas}
translate S AnnotateBlack {S�lo para movimientos de las negras}
translate S AnnotateBlundersOnly {Cuando el movimiento de la partida es un error}
translate S AnnotateBlundersOnlyScoreChange {An�lisis reporta errores, con cambio de puntuaci�n desde: }
translate S BlundersThreshold {Umbral del error }
translate S ScoreAllMoves {Puntuar todos los movimientos}
translate S LowPriority {Baja prioridad del procesador}
translate S ClickHereToSeeMoves {Pulsa aqu� para ver movimientos}
translate S ConfigureInformant {Informaciones}
translate S Informant!? {Movimiento interesante}
translate S Informant? {Movimiento malo}
translate S Informant?? {Desastroso}
translate S Informant?! {Movimiento dudoso}
translate S Informant+= {Blancas tienen una ligera ventaja}
translate S Informant+/- {Blancas tienen ventaja}
translate S Informant+- {Blancas tienen una ventaja decisiva}
translate S Informant++- {La partida es considerada ganada}
translate S Book {Libro}
translate S OtherBookMoves {Otros movimientos del libro}
translate S OtherBookMovesTooltip {Movimientos para los que el oponente tiene una respuesta}

# Analysis Engine open dialog:
translate S EngineList {Lista de motores de an�lisis}
translate S EngineName {Nombre}
translate S EngineCmd {Orden}
translate S EngineArgs {Par�metros}
translate S EngineDir {Directorio}
translate S EngineElo {Elo}
translate S EngineTime {Fecha}
translate S EngineNew {Nuevo}
translate S EngineEdit {Editar}
translate S EngineRequired {Los campos en negrita son obligatorios; los dem�s opcionales}

# PGN window menus:
menuText S PgnFile "Archivo" 0
menuText S PgnFileCopy "Copiar partida al portapapeles" 0
menuText S PgnFilePrint "Imprimir en archivo..." 0
menuText S PgnFileClose "Cerrar ventana PGN" 0
menuText S PgnOpt "Presentaci�n" 0
menuText S PgnOptColor "Color de la presentaci�n" 0
menuText S PgnOptShort "Encabezado peque�o (3 l�neas)" 13
menuText S PgnOptSymbols "Anotaciones simb�licas" 0
menuText S PgnOptIndentC "Sangr�a en comentarios" 0
menuText S PgnOptIndentV "Sangr�a en variaciones" 11
menuText S PgnOptColumn "Estilo de columna (un movimiento por l�nea)" 1
menuText S PgnOptSpace "Espacio despu�s del n�mero del movimiento" 0
menuText S PgnOptStripMarks "Quitar c�digos de color en casilla/flecha" 3
menuText S PgnOptBoldMainLine "Usar texto en negrita para las jugadas principales" 4
menuText S PgnColor "Colores" 1
menuText S PgnColorHeader "Encabezamiento..." 0
menuText S PgnColorAnno "Anotaciones..." 0
menuText S PgnColorComments "Comentarios..." 0
menuText S PgnColorVars "Variaciones..." 0
menuText S PgnColorBackground "Fondo..." 0
menuText S PgnColorMain "L�nea principal..." 0
menuText S PgnColorCurrent "Color de fondo del �ltimo movimiento..." 1
menuText S PgnHelp "Ayuda" 1
menuText S PgnHelpPgn "Ayuda de PGN" 9
menuText S PgnHelpIndex "�ndice de la ayuda" 0
translate S PgnWindowTitle {Planilla - partida %u}

# Crosstable window menus:
menuText S CrosstabFile "Archivo" 0
menuText S CrosstabFileText "Imprimir en archivo texto..." 20
menuText S CrosstabFileHtml "Imprimir en archivo HTML..." 20
menuText S CrosstabFileLaTeX "Imprimir en archivo LaTeX..." 20
menuText S CrosstabFileClose "Cerrar ventana de tabla cruzada" 0
menuText S CrosstabEdit "Editar" 0
menuText S CrosstabEditEvent "Evento" 0
menuText S CrosstabEditSite "Lugar" 0
menuText S CrosstabEditDate "Fecha" 0
menuText S CrosstabOpt "Presentaci�n" 0
menuText S CrosstabOptAll "Todos contra todos" 0
menuText S CrosstabOptSwiss "Suizo" 0
menuText S CrosstabOptKnockout "Eliminatoria directa" 0
menuText S CrosstabOptAuto "Auto" 0
menuText S CrosstabOptAges "Edad en a�os" 1
menuText S CrosstabOptNats "Nacionalidades" 0
menuText S CrosstabOptRatings "Elo" 0
menuText S CrosstabOptTitles "T�tulos" 0
menuText S CrosstabOptBreaks "Puntuaciones de desempate" 0
menuText S CrosstabOptDeleted "Incluir partidas borradas" 17
menuText S CrosstabOptColors "Colores (s�lo en tabla de suizos)" 0
menuText S CrosstabOptColumnNumbers "Columnas numeradas (S�lo en tabla todos contra todos)" 11
menuText S CrosstabOptGroup "Grupos de clasificaci�n" 0
menuText S CrosstabSort "Ordenar" 0
menuText S CrosstabSortName "Por nombre" 4
menuText S CrosstabSortRating "Por Elo" 4
menuText S CrosstabSortScore "Por puntuaci�n" 4
menuText S CrosstabColor "Color" 2
menuText S CrosstabColorPlain "Texto simple" 0
menuText S CrosstabColorHyper "Hipertexto" 0
menuText S CrosstabHelp "Ayuda" 1
menuText S CrosstabHelpCross "Ayuda de tabla cruzada" 9
menuText S CrosstabHelpIndex "�ndice de la ayuda" 0
translate S SetFilter {Poner filtro}
translate S AddToFilter {A�adir al filtro}
translate S Swiss {Suizo}
translate S Category {Categor�a}

# Opening report window menus:
menuText S OprepFile "Archivo" 0
menuText S OprepFileText "Imprimir en archivo texto..." 20
menuText S OprepFileHtml "Imprimir en archivo HTML..." 20
menuText S OprepFileLaTeX "Imprimir en archivo LaTeX..." 20
menuText S OprepFileOptions "Opciones..." 0
menuText S OprepFileClose "Cerrar ventana del informe de la apertura" 0
menuText S OprepFavorites "Favoritos" 1
menuText S OprepFavoritesAdd "A�adir informe..." 0
menuText S OprepFavoritesEdit "Editar informe favorito..." 0
menuText S OprepFavoritesGenerate "Generar informe..." 0
menuText S OprepHelp "Ayuda" 1
menuText S OprepHelpReport "Ayuda del informe de la apertura" 11
menuText S OprepHelpIndex "�ndice de la ayuda" 0

# Header search:
translate S HeaderSearch {B�squeda por encabezamiento}
translate S EndSideToMove {Bando a mover al final de la partida}
translate S GamesWithNoECO {�Partidas sin ECO?}
translate S GameLength {Duraci�n:}
translate S FindGamesWith {Encontrar partidas con}
translate S StdStart {Inicio est�ndar}
translate S Promotions {Promociones}
translate S Comments {Comentarios}
translate S Variations {Variaciones}
translate S Annotations {Anotaciones}
translate S DeleteFlag {Se�al de borrado}
translate S WhiteOpFlag {Apertura de las blancas}
translate S BlackOpFlag {Apertura de las negras}
translate S MiddlegameFlag {Mediojuego}
translate S EndgameFlag {Finales}
translate S NoveltyFlag {Novedad}
translate S PawnFlag {Estructura de peones}
translate S TacticsFlag {T�cticas}
translate S QsideFlag {Juego del lado de dama}
translate S KsideFlag {Juego del lado de rey}
translate S BrilliancyFlag {Genialidad}
translate S BlunderFlag {Error}
translate S UserFlag {Usuario}
translate S PgnContains {PGN contiene texto}
translate S Annotator {Comentarista}
translate S Cmnts {S�lo partidas comentadas}

# Game list window:
translate S GlistNumber {N�mero}
translate S GlistWhite {Blancas}
translate S GlistBlack {Negras}
translate S GlistWElo {B-Elo}
translate S GlistBElo {N-Elo}
translate S GlistEvent {Evento}
translate S GlistSite {Lugar}
translate S GlistRound {Ronda}
translate S GlistDate {Fecha}
translate S GlistYear {A�o}
translate S GlistEDate {Evento-Fecha}
translate S GlistResult {Resultado}
translate S GlistLength {Longitud}
translate S GlistCountry {Pa�s}
translate S GlistECO {ECO}
translate S GlistOpening {Apertura}
translate S GlistEndMaterial {Material final}
translate S GlistDeleted {Borrado}
translate S GlistFlags {Se�al}
translate S GlistVars {Variaciones}
translate S GlistComments {Comentarios}
translate S GlistAnnos {Anotaciones}
translate S GlistStart {Inicio}
translate S GlistGameNumber {N�mero de partida}
# ====== TODO To be translated ======
translate S GlistAverageElo {Average Elo}
# ====== TODO To be translated ======
translate S GlistRating {Rating}
translate S GlistFindText {Encontrar texto}
translate S GlistMoveField {Movimiento}
translate S GlistEditField {Configurar}
translate S GlistAddField {A�adir}
translate S GlistDeleteField {Quitar}
translate S GlistWidth {Anchura}
translate S GlistAlign {Alinear}
# ====== TODO To be translated ======
translate S GlistAlignL {Align: left}
# ====== TODO To be translated ======
translate S GlistAlignR {Align: right}
# ====== TODO To be translated ======
translate S GlistAlignC {Align: center}
translate S GlistColor {Color}
translate S GlistSep {Separador}
# ====== TODO To be translated ======
translate S GlistCurrentSep {-- Current --}
# ====== TODO To be translated ======
translate S GlistNewSort {New}
# ====== TODO To be translated ======
translate S GlistAddToSort {Add}
# ====== TODO To be translated ======
translate S GsortSort {Sort...}
# ====== TODO To be translated ======
translate S GsortDate {Date}
# ====== TODO To be translated ======
translate S GsortYear {Year}
# ====== TODO To be translated ======
translate S GsortEvent {Event}
# ====== TODO To be translated ======
translate S GsortSite {Site}
# ====== TODO To be translated ======
translate S GsortRound {Round}
# ====== TODO To be translated ======
translate S GsortWhiteName {White Name}
# ====== TODO To be translated ======
translate S GsortBlackName {Black Name}
# ====== TODO To be translated ======
translate S GsortECO {ECO}
# ====== TODO To be translated ======
translate S GsortResult {Result}
# ====== TODO To be translated ======
translate S GsortMoveCount {Move Count}
# ====== TODO To be translated ======
translate S GsortAverageElo {Average Elo}
# ====== TODO To be translated ======
translate S GsortCountry {Country}
# ====== TODO To be translated ======
translate S GsortDeleted {Deleted}
# ====== TODO To be translated ======
translate S GsortEventDate {Event Date}
# ====== TODO To be translated ======
translate S GsortWhiteElo {White Elo}
# ====== TODO To be translated ======
translate S GsortBlackElo {Black Elo}
# ====== TODO To be translated ======
translate S GsortComments {Comments}
# ====== TODO To be translated ======
translate S GsortVariations {Variations}
# ====== TODO To be translated ======
translate S GsortNAGs {NAGs}
# ====== TODO To be translated ======
translate S GsortAscending {Ascending}
# ====== TODO To be translated ======
translate S GsortDescending {Descending}
# ====== TODO To be translated ======
translate S GsortAdd {Add}
# ====== TODO To be translated ======
translate S GsortStore {Store}
# ====== TODO To be translated ======
translate S GsortLoad {Load}
translate S GlistRemoveThisGameFromFilter  {Quita esta partida del filtro}
translate S GlistRemoveGameAndAboveFromFilter  {Quita esta partida y todas las de arriba del filtro}
translate S GlistRemoveGameAndBelowFromFilter  {Quita esta partida y todas las de abajo del filtro}
translate S GlistDeleteGame {Elimina/recupera esta partida de la base}
translate S GlistDeleteAllGames {Elimina todas las partidas de la base que aparecen en el filtro}
translate S GlistUndeleteAllGames {Recupera todas las partidas borradas de la base que aparecen en el filtro}
translate S GlistMergeGameInBase {Fusionar la partida en otra base} 

# Maintenance window:
translate S DatabaseName {Nombre de la base:}
translate S TypeIcon {Tipo de icono:}
translate S NumOfGames {Partidas:}
translate S NumDeletedGames {Partidas borradas:}
translate S NumFilterGames {Partidas en el filtro:}
translate S YearRange {Rango de a�os:}
translate S RatingRange {Rango de Elo:}
translate S Description {Descripci�n}
translate S Flag {Se�al}
translate S CustomFlags {Se�ales personalizadas}
translate S DeleteCurrent {Borrar partida actual}
translate S DeleteFilter {Borrar partidas filtradas}
translate S DeleteAll {Borrar todas las partidas}
translate S UndeleteCurrent {No borrar partida actual}
translate S UndeleteFilter {No borrar partidas filtradas}
translate S UndeleteAll {No borrar todas las partidas}
translate S DeleteTwins {Borrar partidas dobles}
translate S MarkCurrent {Marcar partida actual}
translate S MarkFilter {Marcar partidas filtradas}
translate S MarkAll {Marcar todas las partidas}
translate S UnmarkCurrent {No marcar partida actual}
translate S UnmarkFilter {No marcar partidas filtradas}
translate S UnmarkAll {No marcar todas las partidas}
translate S Spellchecking {Revisi�n ortogr�fica}
translate S Players {Jugadores}
translate S Events {Eventos}
translate S Sites {Lugares}
translate S Rounds {Rondas}
translate S DatabaseOps {Operaciones con la base de datos}
translate S ReclassifyGames {Reclasificar partidas por ECO...}
translate S CompactDatabase {Compactar base de datos}
translate S SortDatabase {Ordenar base de datos}
translate S AddEloRatings {A�adir clasificaci�n Elo}
translate S AutoloadGame {Autocargar n�mero de partida}
translate S StripTags {Quitar etiquetas PGN}
translate S StripTag {Quitar etiquetas}
translate S Cleaner {MultiHerramienta}
translate S CleanerHelp {
Scid ejecutar�, en la actual base de datos, todas las acciones de mantenimiento
que selecciones de la siguiente lista.

Se aplicar� el estado actual en la clasificaci�n ECO y el di�logo de borrado de
dobles si seleccionas esas funciones.
}
translate S CleanerConfirm {
�Una vez que la MultiHerramienta de mantenimiento se inicia no puede ser interrumpida!

Esto puede tomar mucho tiempo en una base de datos grande, dependiendo de las funciones que hallas seleccionado y su estado actual.

�Est�s seguro de querer comenzar las funciones de mantenimiento que has seleccionado?
}
translate S TwinCheckUndelete {Pulsar "u" para no borrar ninguna (undelete)}
translate S TwinCheckprevPair {Pareja anterior}
translate S TwinChecknextPair {Pareja siguiente}
translate S TwinChecker {Scid: Verificar partidas dobles}
translate S TwinCheckTournament {Partidas en torneo:}
translate S TwinCheckNoTwin {No doble  }
translate S TwinCheckNoTwinfound {No fueron detectados dobles para esta partida.\nPara mostrar dobles usando esta ventana debes usar la funci�n Borrar partidas dobles..." }
translate S TwinCheckTag {Compartir etiquetas...}
translate S TwinCheckFound1 {Scid encontr� $result partidas dobles}
translate S TwinCheckFound2 {y pone pone sus banderas de borrado}
translate S TwinCheckNoDelete {No hay partidas en esta base para borrar.}
translate S TwinCriteria1 {Tus par�metros para encontrar partidas dobles potencialmente pueden causar partidas no-dobles con movimientos similares a ser marcadas como dobles.}
translate S TwinCriteria2 {Es recomendable que si elijes "No" para "algunos movimientos", elijas "S�" para los par�metros colores, eventos, lugar, ronda, a�o y mes.\n�Quieres continuar y borrar partidas dobles en cualquier caso?}
translate S TwinCriteria3 {Es recomendable que especifiques "S�" para al menos dos par�metros de "mismo lugar", "misma ronda" y "mismo a�o".\n�Quieres continuar y borrar dobles en todo caso?}
translate S TwinCriteriaConfirm {Scid: Confirmar par�metros para partidas dobles}
translate S TwinChangeTag "Cambiar las siguientes etiquetas de las:\n\n partidas"
translate S AllocRatingDescription "Este comando usar� el actual fichero SpellCheck para a�adir  puntuaciones ELO y partidas en esta base. Donde quiera que un jugador no tenga puntuaci�n pero su puntuaci�n en el listado del  fichero  spellcheck , su puntuaci�n ser� a�adida."
translate S RatingOverride "�Sobreescribir puntuaciones existentes no nulas?"
translate S AddRatings "A�adir puntuaciones a:"
translate S AddedRatings {Scid a�adi� $r puntuaciones Elo en $g partidas.}
translate S NewSubmenu "Nuevo submenu"

# Comment editor:
translate S AnnotationSymbols  {S�mbolos de anotaci�n:}
translate S Comment {Comentario:}
translate S InsertMark {Insertar marca}
translate S InsertMarkHelp {
Insertar/quitar marca: Selecciona color, tipo, casilla.
Insertar/quitar flecha: Bot�n derecho sobre dos casillas.
}

# Nag buttons in comment editor:
translate S GoodMove {Buena jugada}
translate S PoorMove {Mala jugada}
translate S ExcellentMove {Jugada excelente}
translate S Blunder {Error}
translate S InterestingMove {Jugada interesante}
translate S DubiousMove {Jugada dudosa}
translate S WhiteDecisiveAdvantage {Las blancas tienen decisiva ventaja}
translate S BlackDecisiveAdvantage {Las negras tienen decisiva ventaja}
translate S WhiteClearAdvantage {Las blancas tienen clara ventaja}
translate S BlackClearAdvantage {Las negras tienen clara ventaja}
translate S WhiteSlightAdvantage {Las blancas tienen ligera ventaja}
translate S BlackSlightAdvantage {Las negras tienen ligera ventaja}
translate S Equality {Igualdad}
translate S Unclear {Incierto}
translate S Diagram {Diagrama}

# Board search:
translate S BoardSearch {Tablero de b�squeda}
translate S FilterOperation {Operaci�n en filtro actual:}
translate S FilterAnd {Y (Restringir filtro)}
translate S FilterOr {O (A�adir al filtro)}
translate S FilterIgnore {IGNORAR (Poner a cero el filtro)}
translate S SearchType {Tipo de b�squeda:}
translate S SearchBoardExact {Posici�n exacta (todas las piezas en las mismas casillas)}
translate S SearchBoardPawns {Peones (igual material, todos los peones en las mismas casillas)}
translate S SearchBoardFiles {Columnas (igual material, todos los peones en las mismas columnas)}
translate S SearchBoardAny {Cualquiera (igual material, peones y piezas en cualquier parte)}
translate S SearchInRefDatabase {B�squeda en la base de referencia}
translate S LookInVars {Mirar en variaciones}

# Material search:
translate S MaterialSearch {B�squeda de material}
translate S Material {Material}
translate S Patterns {Patrones}
translate S Zero {Cero}
translate S Any {Cualquiera}
translate S CurrentBoard {Tablero actual}
translate S CommonEndings {Finales comunes}
translate S CommonPatterns {Patrones comunes}
translate S MaterialDiff {Diferencia de material}
translate S squares {casillas}
translate S SameColor {Igual color}
translate S OppColor {Color opuesto}
translate S Either {Cualquiera}
translate S MoveNumberRange {Rango de n�mero de movimientos}
translate S MatchForAtLeast {Encuentro de al menos}
translate S HalfMoves {medios movimientos}

# Common endings in material search:
translate S EndingPawns {Finales de peones}
translate S EndingRookVsPawns {Torre vs. peon(es)}
translate S EndingRookPawnVsRook {Torre y un pe�n vs. torre}
translate S EndingRookPawnsVsRook {Torre y peon(es) vs. torre}
translate S EndingRooks {Finales de torre vs. torre}
translate S EndingRooksPassedA {Finales de torre vs. torre con pe�n pasado}
translate S EndingRooksDouble {Finales de dos torres}
translate S EndingBishops {Finales de alfil vs. alfil}
translate S EndingBishopVsKnight {Finales de alfil vs. caballo}
translate S EndingKnights {Finales de caballo vs. caballo}
translate S EndingQueens {Finales de dama vs. dama}
translate S EndingQueenPawnVsQueen {Dama y un pe�n vs. dama}
translate S BishopPairVsKnightPair {Medio juego de dos alfiles vs. dos caballos}

# Common patterns in material search:
translate S PatternWhiteIQP {PDA blanco}
translate S PatternWhiteIQPBreakE6 {PDA blanco: d4-d5 ruptura vs. e6}
translate S PatternWhiteIQPBreakC6 {PDA blanco: d4-d5 ruptura vs. c6}
translate S PatternBlackIQP {PDA negro}
translate S PatternWhiteBlackIQP {PDA blanco vs. PDA negro}
translate S PatternCoupleC3D4 {Pareja de peones aislados blancos c3+d4}
translate S PatternHangingC5D5 {Peones colgantes negros en c5 y d5}
translate S PatternMaroczy {Centro Maroczy (con peones en c4 y e4)}
translate S PatternRookSacC3 {Sacrificio de torre en c3}
translate S PatternKc1Kg8 {O-O-O vs. O-O (Rc1 vs. Rg8)}
translate S PatternKg1Kc8 {O-O vs. O-O-O (Rg1 vs. Rc8)}
translate S PatternLightFian {Fianchettos de casillas claras (Alfil-g2 vs. Alfil-b7)}
translate S PatternDarkFian {Fianchettos de casillas oscuras (Alfil-b2 vs. Alfil-g7)}
translate S PatternFourFian {Cuatro Fianchettos (Alfiles en b2,g2,b7,g7)}

# Game saving:
translate S Today {Hoy}
translate S ClassifyGame {Clasificar partida}

# Setup position:
translate S EmptyBoard {Tablero vac�o}
translate S InitialBoard {Tablero inicial}
translate S SideToMove {Lado que mueve}
translate S MoveNumber {Movimiento n�mero}
translate S Castling {Enroque}
translate S EnPassantFile {Columna al paso}
translate S ClearFen {Quitar FEN}
translate S PasteFen {Pegar FEN}
translate S SaveAndContinue {Salvar (grabar) y continuar}
translate S DiscardChangesAndContinue {Descartar \n cambios y continuar}
translate S GoBack {Volver atr�s}

# Replace move dialog:
translate S ReplaceMove {Reemplazar movimiento}
translate S AddNewVar {A�adir nueva variaci�n}
translate S NewMainLine {Nueva l�nea principal}
translate S ReplaceMoveMessage {Ya existe un movimiento.

Puedes reemplazarlo, descartando todos los movimientos posteriores, o a�adirlo como una nueva variaci�n.

(Puedes evitar seguir viendo este mensaje en el futuro desactivando la opci�n "Preguntar antes de reemplazar movimientos" en el men� Opciones: Movimientos.)}

# Make database read-only dialog:
translate S ReadOnlyDialog {Si haces que esta base de datos sea de s�lo lectura no se permitir�n hacer cambios. No se podr�n guardar o reemplazar partidas y no se podr�n alterar las se�ales de borrada. Cualquier ordenaci�n o clasificaci�n por ECO ser� temporal.

Puedes hacer f�cilmente escribible la base de datos otra vez cerr�ndola y abri�ndola.

�Realmente quieres hacer que esta base de datos sea de s�lo lectura?}

# Clear game dialog:
translate S ClearGameDialog {Esta partida ha sido cambiada.

�Realmente quieres continuar y eliminar los cambios hechos en ella?
}

# Exit dialog:
translate S ExitDialog {�Realmente quieres salir de Scid?}
translate S ExitUnsaved {La siguiente base de datos tiene cambios en partidas no guardados. Si sales ahora se perder�n estos cambios.}

# Import window:
translate S PasteCurrentGame {Pegar partida actual}
translate S ImportHelp1 \
  {Introducir o pegar una partida en formato PGN en el marco superior.}
translate S ImportHelp2 \
  {Cualquier error importando la partida ser� mostrado aqu�.}
translate S OverwriteExistingMoves {�Sobreescribir movimientos existentes?}

# ECO Browser:
translate S ECOAllSections {todas las divisiones ECO}
translate S ECOSection {divisi�n ECO}
translate S ECOSummary {Resumen de}
translate S ECOFrequency {Frecuencia de los subc�digos para}

# Opening Report:
translate S OprepTitle {Informe de la apertura}
translate S OprepReport {Informe}
translate S OprepGenerated {Generado por}
translate S OprepStatsHist {Estad�sticas e historia}
translate S OprepStats {Estad�sticas}
translate S OprepStatAll {Todas las partidas referidas}
translate S OprepStatBoth {Ambos con Elo}
translate S OprepStatSince {Desde}
translate S OprepOldest {Partidas m�s antiguas}
translate S OprepNewest {Partidas m�s nuevas}
translate S OprepPopular {Popularidad actual}
translate S OprepFreqAll {Frecuencia durante todos los a�os: }
translate S OprepFreq1   {Desde el �ltimo a�o hasta hoy:     }
translate S OprepFreq5   {En los �ltimos 5 a�os hasta hoy:   }
translate S OprepFreq10  {En los �ltimos 10 a�os hasta hoy:  }
translate S OprepEvery {una vez cada %u partidas}
translate S OprepUp {sube un %u%s respecto al total de a�os}
translate S OprepDown {baja un %u%s respecto al total de a�os}
translate S OprepSame {no hay cambios respecto al total de a�os}
translate S OprepMostFrequent {Jugadores m�s frecuentes}
translate S OprepMostFrequentOpponents {Rivales m�s frecuentes}
translate S OprepRatingsPerf {Elo y rendimiento}
translate S OprepAvgPerf {Promedio de Elo y rendimiento}
translate S OprepWRating {Elo de las blancas}
translate S OprepBRating {Elo de las negras}
translate S OprepWPerf {Rendimiento de las blancas}
translate S OprepBPerf {Rendimiento de las negras}
translate S OprepHighRating {Partida con el mayor promedio de Elo}
translate S OprepTrends {Tendencias de resultados}
translate S OprepResults {Resultado de duraciones y frecuencias}
translate S OprepLength {Duraci�n de la partida}
translate S OprepFrequency {Frecuencia}
translate S OprepWWins {Blancas ganan: }
translate S OprepBWins {Negras ganan:  }
translate S OprepDraws {Tablas:        }
translate S OprepWholeDB {en el conjunto de la base de datos}
translate S OprepShortest {Triunfos m�s cortos}
translate S OprepMovesThemes {Movimientos y temas}
translate S OprepMoveOrders {L�neas de movimientos que alcanzan la posici�n del informe}
translate S OprepMoveOrdersOne \
  {S�lo hay una l�nea de movimientos que alcanza esta posici�n:}
translate S OprepMoveOrdersAll \
  {Hay %u l�neas de movimiento que alcanzan esta posici�n:}
translate S OprepMoveOrdersMany \
  {Hay %u l�neas de movimiento que alcanzan esta posici�n. Las %u m�s comunes son:}
translate S OprepMovesFrom {Movimientos desde la posici�n del informe}
translate S OprepMostFrequentEcoCodes {Aperturas m�s frecuentes}
translate S OprepThemes {Temas posicionales}
translate S OprepThemeDescription {Frecuencia de los temas en las primeras %u jugadas de cada partida}
translate S OprepThemeSameCastling {Enroque al mismo lado}
translate S OprepThemeOppCastling {Enroque en lados opuestos}
translate S OprepThemeNoCastling {Ambos reyes no enrocados}
translate S OprepThemeKPawnStorm {Avanzada de los peones del rey}
translate S OprepThemeQueenswap {Damas intercambiadas}
translate S OprepThemeWIQP {Pe�n de dama aislado de las blancas}
translate S OprepThemeBIQP {Pe�n de dama aislado de las negras}
translate S OprepThemeWP567 {Peones blancos en 5/6/7� fila}
translate S OprepThemeBP234 {Peones negros en 2/3/4� fila}
translate S OprepThemeOpenCDE {Columnas c/d/e abiertas}
translate S OprepTheme1BishopPair {Un lado tiene los dos alfiles}
translate S OprepEndgames {Finales}
translate S OprepReportGames {Informe de partidas}
translate S OprepAllGames {Todas las partidas}
translate S OprepEndClass {Tipos de finales seg�n la �ltima posici�n de las partidas}
translate S OprepTheoryTable {Tabla te�rica}
translate S OprepTableComment {Generado a partir de las %u partidas con mejor Elo.}
translate S OprepExtraMoves {Anotaci�n extra de movimientos en la tabla te�rica}
translate S OprepMaxGames {M�ximas partidas en la tabla te�rica}
translate S OprepViewHTML {Ver HTML}
translate S OprepViewLaTeX {Ver LaTeX}

# Player Report:
translate S PReportTitle {Informe del jugador}
translate S PReportColorWhite {con las piezas blancas}
translate S PReportColorBlack {con las piezas negras}
translate S PReportMoves {%s despu�s}
translate S PReportOpenings {Aperturas}
translate S PReportClipbase {Vaciar portapapeles y copiar las partidas}

# Piece Tracker window:
translate S TrackerSelectSingle {El bot�n izquierdo selecciona esta pieza.}
translate S TrackerSelectPair {El bot�n izquierdo selecciona esta pieza; el bot�n derecho tambi�n selecciona su hermana.}
translate S TrackerSelectPawn {El bot�n izquierdo selecciona este pe�n; el bot�n derecho selecciona los ocho peones.}
translate S TrackerStat {Estad�stica}
translate S TrackerGames {% de partidas con movimiento a esta casilla}
translate S TrackerTime {% de tiempo en esta casilla}
translate S TrackerMoves {Movimientos}
translate S TrackerMovesStart {Escribe el n�mero del movimiento desde donde debe empezar el rastreo.}
translate S TrackerMovesStop {Escribe el n�mero del movimiento donde debe parar el rastreo.}

# Game selection dialogs:
translate S SelectAllGames {Todas las partidas de la base de datos}
translate S SelectFilterGames {S�lo las partidas filtradas}
translate S SelectTournamentGames {S�lo las partidas del actual torneo}
translate S SelectOlderGames {S�lo partidas antiguas}

# Delete Twins window:
translate S TwinsNote {Para ser dobles, dos partidas deben de tener al menos los mismos dos jugadores y los criterios que fijes debajo. Cuando un par de dobles es encontrado, la partida m�s corta es borrada. Sugerencia: es mejor hacer la correcci�n ortogr�fica de la base de datos antes de iniciar el borrado de dobles, porque esto mejora su detecci�n.}
translate S TwinsCriteria {Criterios: Las partidas dobles deben tener...}
translate S TwinsWhich {Partidas a examinar}
translate S TwinsColors {�Jugadores con igual color?}
translate S TwinsEvent {�Mismo evento?}
translate S TwinsSite {�Mismo sitio?}
translate S TwinsRound {�Misma ronda?}
translate S TwinsYear {�Mismo a�o?}
translate S TwinsMonth {�Mismo mes?}
translate S TwinsDay {�Mismo d�a?}
translate S TwinsResult {�Mismo resultado?}
translate S TwinsECO {�Mismo c�digo ECO?}
translate S TwinsMoves {�Mismos movimientos?}
translate S TwinsPlayers {Comparando nombres de jugadores:}
translate S TwinsPlayersExact {Encuentro exacto}
translate S TwinsPlayersPrefix {S�lo las primeras 4 letras}
translate S TwinsWhen {Cuando se borren partidas dobles}
translate S TwinsSkipShort {�Ignorar todas las partidas con menos de cinco movimientos?}
translate S TwinsUndelete {�Quitar marcas de borrado primero?}
translate S TwinsSetFilter {�Poner filtro a todas las partidas borradas?}
translate S TwinsComments {�Saltar siempre partidas con comentarios?}
translate S TwinsVars {�Saltar siempre partidas con variaciones?}
translate S TwinsDeleteWhich {Qu� partida borrar:}
translate S TwinsDeleteShorter {Partida m�s corta}
translate S TwinsDeleteOlder {N�mero de partida menor}
translate S TwinsDeleteNewer {N�mero de partida mayor}
translate S TwinsDelete {Borrar partidas}

# Name editor window:
translate S NameEditType {Tipo de dato a editar}
translate S NameEditSelect {Partidas a editar}
translate S NameEditReplace {Reemplazar}
translate S NameEditWith {con}
translate S NameEditMatches {Encuentros: Presionar Ctrl+1 a Ctrl+9 para seleccionarlo}
translate S CheckGames {Revisar partidas}
translate S CheckGamesWhich {Revisar partidas}
translate S CheckAll {Todas las partidas}
translate S CheckSelectFilterGames {S�lo las partidas del filtro}

# Classify window:
translate S Classify {Clasificar}
translate S ClassifyWhich {Clasificar por c�digos ECO}
translate S ClassifyAll {Todas las partidas (sobreescribir c�digo ECO)}
translate S ClassifyYear {Todas las partidas jugadas en el �ltimo a�o}
translate S ClassifyMonth {Todas las partidas jugadas en el �ltimo mes}
translate S ClassifyNew {S�lo las partidas todav�a sin c�digo ECO}
translate S ClassifyCodes {C�digo ECO a usar}
translate S ClassifyBasic {S�lo c�digo b�sico ("B12", ...)}
translate S ClassifyExtended {Extensiones Scid ("B12j", ...)}

# Compaction:
translate S NameFile {Archivo de nombres}
translate S GameFile {Archivo de partidas}
translate S Names {Nombres}
translate S Unused {No usado}
translate S SizeKb {Tama�o (kb)}
translate S CurrentState {Estado actual}
translate S AfterCompaction {Despu�s de la compactaci�n}
translate S CompactNames {Compactar archivo de nombres}
translate S CompactGames {Compactar archivo de partidas}
translate S NoUnusedNames "No hay nombres sin usar, por tanto el nombre del fichero est� ya totalmente compactado."
translate S NoUnusedGames "El fichero ya est� totalmente compactado."
translate S GameFileCompacted {El fichero de partidas para la base de datos fue compactado.}

# Sorting:
translate S SortCriteria {Criterio}
translate S AddCriteria {A�adir criterio}
translate S CommonSorts {Ordenaciones comunes}
translate S Sort {Ordenar}

# Exporting:
translate S AddToExistingFile {�A�adir partidas a un archivo existente?}
translate S ExportComments {�Exportar comentarios?}
translate S ExportVariations {�Exportar variaciones?}
translate S IndentComments {�Sangrar comentarios?}
translate S IndentVariations {�Sangrar variaciones?}
translate S ExportColumnStyle {�Estilo de columna (un movimiento por l�nea)?}
translate S ExportSymbolStyle {Estilo de anotaci�n simb�lico:}
translate S ExportStripMarks {�Quitar marca de c�digos de casilla/flecha de los comentarios?}

# Goto game/move dialogs:
translate S LoadGameNumber {Escribe el n�mero de la partida a cargar:}
translate S GotoMoveNumber {Ir al movimiento n�mero:}

# Copy games dialog:
translate S CopyGames {Copiar partidas}
translate S CopyConfirm {
 Realmente deseas copiar las [::utils::thousands $nGamesToCopy] partidas fitradas
 de la base de datos "$fromName"
 a la base de datos "$targetName"?
}
translate S CopyErr {No se pueden copiar las partidas}
translate S CopyErrSource {la base de datos fuente}
translate S CopyErrTarget {la base de datos de destino}
translate S CopyErrNoGames {no tiene partidas en su filtro}
translate S CopyErrReadOnly {es s�lo de lectura}
translate S CopyErrNotOpen {no est� abierta}

# Colors:
translate S LightSquares {Casillas claras}
translate S DarkSquares {Casillas oscuras}
translate S SelectedSquares {Casillas seleccionadas}
translate S SuggestedSquares {Casillas de movimiento sugerido}
translate S WhitePieces {Piezas blancas}
translate S BlackPieces {Piezas negras}
translate S WhiteBorder {Borde blancas}
translate S BlackBorder {Borde negras}

# Novelty window:
translate S FindNovelty {Encontrar novedad}
translate S Novelty {Novedad}
translate S NoveltyInterrupt {Busqueda de novedades interrumpida}
translate S NoveltyNone {Ninguna novedad encontrada para esta partida}
translate S NoveltyHelp {
Scid encontrar� el primer movimiento de la actual partida que alcanza una posici�n no encontrada en la base de datos seleccionada o en el libro de aperturas ECO.
}

# Sounds configuration:
translate S SoundsFolder {Directorio de los archivos de sonido}
translate S SoundsFolderHelp {El directorio debe contener los archivos King.wav, a.wav, 1.wav, etc.}
translate S SoundsAnnounceOptions {Opciones de anunciamiento de movimientos}
translate S SoundsAnnounceNew {Anunciar nuevos movimientos cuando sean hechos}
translate S SoundsAnnounceForward {Anunciar movimientos cuando avancemos un movimiento}
translate S SoundsAnnounceBack {Anunciar movimiento cuando rectifiquemos o retrocedamos una jugada}
translate S SoundsSoundDisabled {Scid no pudo encontrar el paquete de audio de Snack al inicio.\nEl sonido est� desactivado.}

# Upgrading databases:
translate S Upgrading {Actualizaci�n}
translate S ConfirmOpenNew {
Este es un formato de base de datos antiguo (Scid 3) que no puede ser abierto con Scid 4, pero ya se ha creado una versi�n de formato nuevo (Scid 4).

�Quieres abrir la versi�n de formato nuevo de la base de datos?
}
translate S ConfirmUpgrade {
Esta es una base de datos en un formato antiguo (Scid 3). Se debe crear una versi�n de formato nuevo de base de datos antes de poder ser usada en Scid 4.

La actualizaci�n crear� una nueva versi�n de la base de datos.

Esto puede tomar un tiempo, pero s�lo es necesario hacerlo una vez. Puedes cancelar si toma demasiado tiempo.

�Quieres actualizar esta base de datos ahora?
}

# Recent files options:
translate S RecentFilesMenu {N�mero de archivos recientes en el men� Archivo}
translate S RecentFilesExtra {N�mero de archivos recientes en submen� extra}

# My Player Names options:
translate S MyPlayerNamesDescription {
Escriba una lista de nombres de jugadores preferidos, un nombre por cada l�nea. Est�n permitidos los comodines (por ejemplo "?" para un s�lo caracter, "*" para varios caracteres).

Cada vez que carge una partida con un jugador de la lista se girar� el tablero, si fuese necesario, para ver la partida desde la perspectiva del jugador.
}
translate S showblunderexists {Mostrar metedura de pata}
translate S showblundervalue {Mostrar valor de la metedura de pata}
translate S showscore {Mostrar marcador}
translate S coachgame {Entrenador}
translate S configurecoachgame {Configurar entrenador}
translate S configuregame {Configuraci�n de partida}
translate S Phalanxengine {Motor Phalanx}
translate S Coachengine {Motor entrenador}
translate S difficulty {Dificultad}
translate S hard {Duro}
translate S easy {F�cil}
translate S Playwith {Juega con}
translate S white {blancas}
translate S black {negras}
translate S both {ambos}
translate S Play {Jugar}
translate S Noblunder {Sin errores}
translate S blunder {Meteduras de pata}
translate S Noinfo {-- Sin informaci�n --}
translate S PhalanxOrTogaMissing {Phalanx o Toga no encontrado}
translate S moveblunderthreshold {El movimiento es una metedura de pata si la p�rdida de puntuaci�n es mayor que }
translate S limitanalysis {Tiempo l�mite para an�lisis del motor}
translate S seconds {segundos}
translate S Abort {Abortar}
translate S Resume {Reanudar}
translate S OutOfOpening {Fuera de apertura}
translate S NotFollowedLine {T� no sigues la l�nea}
translate S DoYouWantContinue {�Quieres continuar?}
translate S CoachIsWatching {Entrenador}
translate S Ponder {Pensar siempre (el motor)}
translate S LimitELO {Limitar fuerza Elo}
translate S DubiousMovePlayedTakeBack {Movimiento dudoso, �quieres rectificar?}
translate S WeakMovePlayedTakeBack {Movimiento flojo, �quieres rectificar ?}
translate S BadMovePlayedTakeBack {Movimiento malo, �quieres rectificar ?}
translate S Iresign {Yo abandono}
translate S yourmoveisnotgood {tu movimiento no es bueno}
translate S EndOfVar {Fin de la variante}
translate S Openingtrainer {Entrenador de aperturas}
translate S DisplayCM {Muestra posibles movimientos}
translate S DisplayCMValue {Muestra valor de posibles movimientos}
translate S DisplayOpeningStats {Muestra estad�sticas}
translate S ShowReport {Muestra informe}
translate S NumberOfGoodMovesPlayed {buenos movimientos jugados}
translate S NumberOfDubiousMovesPlayed {dudosos momientos jugados}
translate S NumberOfMovesPlayedNotInRepertoire {movimientos jugados fuera de repertorio}
translate S NumberOfTimesPositionEncountered {veces encontrada la posici�n}
translate S PlayerBestMove  {Permite �nicamente movimientos mejores}
translate S OpponentBestMove {Oponente juega mejores movimientos}
translate S OnlyFlaggedLines {S�lo l�neas marcadas}
translate S resetStats {Reinicia estad�sticas}
translate S Repertoiretrainingconfiguration {Configuraci�n del repertorio de entrenamiento}
translate S Loadingrepertoire {Cargando repertorio}
translate S Movesloaded {Movimientos cargados}
translate S Repertoirenotfound {Repertorio no encontrado}
translate S Openfirstrepertoirewithtype {Abrir primero una base con icono/tipo de repertorio colocado en el lado derecho}
translate S Movenotinrepertoire {Movimiento no est� en el repertorio}
translate S PositionsInRepertoire {Posiciones en repertorio}
translate S PositionsNotPlayed {Posiciones no jugadas}
translate S PositionsPlayed {Posiciones jugadas}
translate S Success {�xitos}
translate S DubiousMoves {Movimientos dudosos}
translate S OutOfRepertoire {Fuera de repertorio}
translate S ConfigureTactics {Configurar t�ctica}
translate S ResetScores {Reiniciar marcadores (puntuaciones)}
translate S LoadingBase {Cargando base}
translate S Tactics {T�cticas}
translate S ShowSolution {Mostrar soluci�n}
translate S NextExercise {Ejercicio siguiente}
translate S PrevExercise {Ejercicio anterior}
translate S StopTraining {Parar entrenamiento}
translate S Next {Siguiente}
translate S ResettingScore {Reiniciando marcador}
translate S LoadingGame {Cargando partida}
translate S MateFound {Mate encontrado}
translate S BestSolutionNotFound {�No fue encontrada la mejor soluci�n!}
translate S MateNotFound {Mate no encontrado}
translate S ShorterMateExists {Esiste un mate m�s corto}
translate S ScorePlayed {Marcador jugado}
translate S Expected {Esperado}
translate S ChooseTrainingBase {Elegir base de entrenamiento}
translate S Thinking {Pensando}
translate S AnalyzeDone {An�lisis hecho}
translate S WinWonGame {Gana la partida ganada}
translate S Lines {L�neas}
translate S ConfigureUCIengine {Configurar motor UCI}
translate S SpecificOpening {Apertura espec�fica}
translate S StartNewGame {Empezar partida nueva}
translate S FixedLevel {Nivel fijado}
translate S Opening {Abriendo}
translate S RandomLevel {Nivel aleatorio}
translate S StartFromCurrentPosition {Empezar desde la posici�n actual}
translate S FixedDepth {Profundidad fija}
translate S Nodes {Nodos} 
translate S Depth {Profundidad}
translate S Time {Tiempo} 
translate S SecondsPerMove {Segundos por movimiento}
translate S Engine {Motor}
translate S TimeMode {Modo de tiempo}
translate S TimeBonus {Tiempo + bonus}
translate S TimeMin {min}
translate S TimeSec {seg}
translate S AllExercisesDone {Todos los ejercicios hechos}
translate S MoveOutOfBook {Movimiento fuera del libro}
translate S LastBookMove {�ltimo movimiento del libro}
translate S AnnotateSeveralGames {Anotar las partidas\ndesde la actual hasta la partida: }
translate S FindOpeningErrors {Encontrar errores en los primeros }
translate S MarkTacticalExercises {Marca ejercicios t�cticos}
translate S UseBook {Usar libro de aperturas (Book)}
translate S MultiPV {Variantes m�ltiples}
translate S Hash {Memoria Hash}
translate S OwnBook {Usar libro (book) del motor}
translate S BookFile {Libro de aperturas}
translate S AnnotateVariations {Anotar variantes}
translate S ShortAnnotations {Anotaciones cortas}
translate S addAnnotatorTag {A�adir etiqueta de anotador}
translate S AddScoreToShortAnnotations {A�adir puntuaci�n para anotaciones cortas}
translate S Export {Exportar}
translate S BookPartiallyLoaded {Libro parcialmente cargado}
translate S Calvar {C�lculo de variantes}
translate S ConfigureCalvar {Configuraci�n}
translate S Reti {Apertura Reti}
translate S English {Apertura inglesa}
translate S d4Nf6Miscellaneous {1.d4 Cf6 variadas}
translate S Trompowsky {Apertura Trompowsky}
translate S Budapest {Gambito Budapest}
translate S OldIndian {Defensa india antigua}
translate S BenkoGambit {Gambito Benko}
translate S ModernBenoni {Defensa Benoni moderna}
translate S DutchDefence {Defensa holandesa}
translate S Scandinavian {Defensa escandinava}
translate S AlekhineDefence {Defensa Alekhine}
translate S Pirc {Defensa Pirc}
translate S CaroKann {Defensa Caro-Kann}
translate S CaroKannAdvance {Defensa Caro-Kann, variante del avance}
translate S Sicilian {Defensa Siciliana}
translate S SicilianAlapin {Defensa Siciliana, variante Alapin}
translate S SicilianClosed {Defensa Siciliana, variante cerrada}
translate S SicilianRauzer {Defensa Siciliana, variante Rauzer}
translate S SicilianDragon {Defensa Siciliana, variante del dragon}
translate S SicilianScheveningen {Defensa Siciliana, variante Scheveningen}
translate S SicilianNajdorf {Defensa Siciliana, Variante Najdorf}
translate S OpenGame {Apertura abierta}
translate S Vienna {Apertura Vienesa}
translate S KingsGambit {Gambito de rey}
translate S RussianGame {Partida rusa}
translate S ItalianTwoKnights {Apertura italiana, variante de los dos caballos}
translate S Spanish {Apertura espa�ola}
translate S SpanishExchange {Apertura espa�ola, variante del cambio}
translate S SpanishOpen {Apertura espa�ola}
translate S SpanishClosed {Apertura espa�ola, variante cerrada}
translate S FrenchDefence {Defensa francesa}
translate S FrenchAdvance {Defensa francesa, variante del avance}
translate S FrenchTarrasch {Defensa francesa, variante Tarrasch}
translate S FrenchWinawer {Defensa francesa, variante Winawer}
translate S FrenchExchange {Defensa francesa, variante del cambio}
translate S QueensPawn {Apertura de pe�n de dama}
translate S Slav {Defensa eslava}
translate S QGA {Gambito de dama aceptado}
translate S QGD {Gambito de dama declinado}
translate S QGDExchange {Gambito de dama declinado, variante del cambio}
translate S SemiSlav {Defensa semieslava del gambito de dama declinado}
translate S QGDwithBg5 {Gambito de dama declinado con Ag5}
translate S QGDOrthodox {Gambito de dama declinado, defensa ortodoxa}
translate S Grunfeld {Defensa Gr�nfeld}
translate S GrunfeldExchange {Variante del cambio de la defensa Gr�nfeld }
translate S GrunfeldRussian {Variante rusa de la defensa Gr�nfeld}
translate S Catalan {Catalana}
translate S CatalanOpen {Apertura catalana}
translate S CatalanClosed {Apertura catalana, variante cerrada}
translate S QueensIndian {Defensa india de dama}
translate S NimzoIndian {Apertura Nimzo-India}
translate S NimzoIndianClassical {Apertura Nimzo-India cl�sica}
translate S NimzoIndianRubinstein {Variante Rubinstein de la Nimzo-India}
translate S KingsIndian {India de rey}
translate S KingsIndianSamisch {Ataque S�mish de la india de rey}
translate S KingsIndianMainLine {L�nea principal india de rey}
translate S ConfigureFics {Configurar FICS}
translate S FICSGuest {Autentificaci�n como invitado}
translate S FICSServerPort {Puerto del servidor}
translate S FICSServerAddress {Direcci�n IP}
translate S FICSRefresh {Refrescar}
translate S FICSTimesealPort {Puerto Timeseal}
translate S FICSSilence {Silencio}
translate S FICSOffers {Ofertas}
translate S FICSConsole {Consola}
translate S FICSGames {Partidas}
translate S FICSUnobserve {Parar vistazo de partida}
translate S FICSProfile {Muestra tu historia y perfil}
translate S FICSRelayedGames {Partidas retransmitidas}
translate S FICSFindOpponent {Buscar oponente}
translate S FICSTakeback {Retrocede}
translate S FICSTakeback2 {Retrocede 2}
translate S FICSInitTime {Tiempo inicial (min)}
translate S FICSIncrement {Incremento (seg)}
translate S FICSRatedGame {Partida valorada}
translate S FICSAutoColour {autom�tico}
translate S FICSManualConfirm {confirma manualmente}
translate S FICSFilterFormula {Filtrar con f�rmula}
translate S FICSIssueSeek {Panel de retos}
translate S FICSChallenge {Retar}
translate S FICSAccept {aceptar}
translate S FICSDecline {rechazar}
translate S FICSColour {Color}
translate S FICSSend {enviar}
translate S FICSConnect {Conectar}
translate S FICSdefaultuservars {Usa valores por defecto}
translate S FICSObserveconfirm {Quieres observar la partida}
# ====== TODO To be translated ======
translate S FICSpremove {Enable premove}
# ====== TODO To be translated ======
translate S FICSObserve {Observe}
# ====== TODO To be translated ======
translate S FICSRatedGames {Rated Games}
# ====== TODO To be translated ======
translate S FICSUnratedGames {Unrated Games}
# ====== TODO To be translated ======
translate S FICSRated {Rated}
# ====== TODO To be translated ======
translate S FICSUnrated {Unrated}
# ====== TODO To be translated ======
translate S FICSRegisteredPlayer {Registered player only}
# ====== TODO To be translated ======
translate S FICSFreePlayer {Free player only}
# ====== TODO To be translated ======
translate S FICSNetError {Network error\nCan't connect to }
translate S GameReview {Revisi�n de partida}
translate S GameReviewTimeExtended {Tiempo extendido}
translate S GameReviewMargin {Margen de error}
translate S GameReviewAutoContinue {Autocontinuar cuando el movimiento es correcto}
translate S GameReviewReCalculate {Usar tiempo extendido}
translate S GameReviewAnalyzingMovePlayedDuringTheGame {Analizando movimiento jugado durante la partida}
translate S GameReviewAnalyzingThePosition {Analizando la posici�n}
translate S GameReviewEnterYourMove {Introduce tu movimiento}
translate S GameReviewCheckingYourMove {Comprobando tu movimiento}
translate S GameReviewYourMoveWasAnalyzed {Tu movimiento fue analizado}
translate S GameReviewYouPlayedSameMove {Jugaste el mismo movimiento que en la partida}
translate S GameReviewScoreOfYourMove {Puntuaci�n de tu movimiento}
translate S GameReviewGameMoveScore {Puntuaci�n del movimiento de la partida}
translate S GameReviewEngineScore {Puntuaci�n del motor}
translate S GameReviewYouPlayedLikeTheEngine {T� jugaste como el motor}
translate S GameReviewNotEngineMoveButGoodMove {No es el movimiento del motor, pero es tambi�n un buen movimiento}
translate S GameReviewMoveNotGood {Este movimiento no es bueno, la puntuaci�n es }
translate S GameReviewMovesPlayedLike {Movimientos jugados como}
translate S GameReviewMovesPlayedEngine {Movimientos jugados como motor}
translate S CCDlgConfigureWindowTitle {Configurar Ajedrez por correo}
translate S CCDlgCGeneraloptions {Opciones generales}
translate S CCDlgDefaultDB {Base por defecto:}
translate S CCDlgInbox {Entrante (Carpeta):}
translate S CCDlgOutbox {Saliente (carpeta):}
translate S CCDlgXfcc {Configuraci�n Xfcc:}
translate S CCDlgExternalProtocol {Protocolo externo (e.g. Xfcc)}
translate S CCDlgFetchTool {Herramienta de traer:}
translate S CCDlgSendTool {Herramienta de env�o:}
translate S CCDlgEmailCommunication {Comunicaci�n email}
translate S CCDlgMailPrg {Programa de correo:}
translate S CCDlgBCCAddr {(B)CC Direcci�n:}
translate S CCDlgMailerMode {Modo:}
translate S CCDlgThunderbirdEg {p.e. Thunderbird, Mozilla Mail, Icedove...}
translate S CCDlgMailUrlEg {p.e. Evolution}
translate S CCDlgClawsEg {p.e. Sylpheed Claws}
translate S CCDlgmailxEg {p.e. mailx, mutt, nail...}
translate S CCDlgAttachementPar {Par�metro Adjunto (Attachment):}
translate S CCDlgInternalXfcc {Usar soporte interno Xfcc}
translate S CCDlgConfirmXfcc {Confirmar jugadas}
translate S CCDlgSubjectPar {Par�metro Sujeto (Subject):}
translate S CCDlgDeleteBoxes {Vaciar Entrante/Saliente}
translate S CCDlgDeleteBoxesText {�Quieres realmente vaciar tus carpetas Entrante y Saliente para Ajedrez por correspondencia? Esto requiere una nueva sincronizaci�n para mostrar el estado �ltimo de tus partidas}
translate S CCDlgConfirmMove {Confirmar jugada}
translate S CCDlgConfirmMoveText {Si t� confirmas, la siguiente jugada y comentario ser� enviado al servidor:}
translate S CCDlgDBGameToLong {L�nea principal inconsistente}
translate S CCDlgDBGameToLongError {La l�nea principal en tu base es m�s larga que de la partida en la bandeja de entrada. Si la bandeja de entrada contiene la partida actual, algunos movimientos fueron a�adidos a la l�nea principal en la base err�neamente.\nEn este caso acorte la l�nea principal a la (max) jugada\n}
translate S CCDlgStartEmail {Empezar nueva partida por email}
translate S CCDlgYourName {Tu nombre:}
translate S CCDlgYourMail {Tu direcci�n email:}
translate S CCDlgOpponentName {Nombre de oponente:}
translate S CCDlgOpponentMail {Direcci�n email de oponente:}
translate S CCDlgGameID {Partida ID (�nico):}
translate S CCDlgTitNoOutbox {Scid: Salida del Correo de Ajedrez}
translate S CCDlgTitNoInbox {Scid: Entrada del Correo de Ajedrez}
translate S CCDlgTitNoGames {Scid: No hay partidas de Ajedrez por Correo}
translate S CCErrInboxDir {Carpeta de entrada del Correo de Ajedrez (Entrante):}
translate S CCErrOutboxDir {Carpeta de salida del Correo de Ajedrez (Saliente):}
translate S CCErrDirNotUsable {�No existe o no est� accesible!\nPor favor, compruebe y corrija los par�metros.}
translate S CCErrNoGames {�No contiene ninguna partida!\nPor favor, tr�igala primero.}
translate S CCDlgTitNoCCDB {Scid: No es una Base de Ajedrez por Correo}
translate S CCErrNoCCDB {No hay una Base del tipo 'Correo' abierta. Por favor, abra una antes de usar funciones de ajedrez por correo.}
translate S CCFetchBtn {Traer partidas desde el servidor y procesar correo entrante}
translate S CCPrevBtn {Ir a partida anterior}
translate S CCNextBtn {Ir a partida siguiente}
translate S CCSendBtn {Enviar movimiento}
translate S CCEmptyBtn {Correos entrante y saliente vac�os}
translate S CCHelpBtn {Ayuda en iconos e indicadores de estatus. \n Para ayuda general, pulse F1}
translate S CCDlgServerName {Nombre del servidor:}
translate S CCDlgLoginName  {Nombre de registro:}
translate S CCDlgPassword   {Contrase�a:}
# ====== TODO To be translated ======
translate S CCDlgShowPassword {Show password}
translate S CCDlgURL        {Xfcc-URL:}
translate S CCDlgRatingType {Tipo de puntuaci�n (Rating):}
translate S CCDlgDuplicateGame {El ID de la partida no es �nico}
translate S CCDlgDuplicateGameError {Esta partida existe m�s de una vez en tu base. Por favor, borra todos los duplicados y compacta tu fichero de partidas (Fichero/Mantenimiento/Compactar base de datos).}
translate S CCDlgSortOption {Ordenando:}
translate S CCDlgListOnlyOwnMove {S�lo partidas que tienen el movimiento}
translate S CCOrderClassicTxt {Lugar, Evento, Ronda, Resultado, Blancas, Negras}
translate S CCOrderMyTimeTxt {Mi reloj}
translate S CCOrderTimePerMoveTxt {Tiempo por movimiento falta el pr�ximo control de tiempo}
translate S CCOrderStartDate {Empezar fecha}
translate S CCOrderOppTimeTxt {Reloj de los oponentes}
translate S CCDlgConfigRelay {Configurar observaciones ICCF}
translate S CCDlgConfigRelayHelp {Ir a las partidas de la p�gina en http://www.iccf-webchess.com y mostrar la partida a ser observada. Si tu ves el tablero de ajedrez copia la URL desde tu explorador a la lista. !Una sola URL por l�nea!\nExample: http://www.iccf-webchess.com/MakeAMove.aspx?id=266452}
translate S ExtHWConfigConnection {Configurar hardware externo}
translate S ExtHWPort {Puerto}
translate S ExtHWEngineCmd {Comando del motor}
translate S ExtHWEngineParam {Par�metro del motor}
translate S ExtHWShowButton {Mostrar bot�n}
translate S ExtHWHardware {Hardware}
translate S ExtHWNovag {Novag Citrine}
translate S ExtHWInputEngine {Motor de entrada}
translate S ExtHWNoBoard {Sin tablero}
translate S NovagReferee {�rbitro}
translate S IEConsole {Consola de entrada del motor}
translate S IESending {Movimientos enviados por}
translate S IESynchronise {Sincronizar}
translate S IERotate  {Rotar}
translate S IEUnableToStart {Imposible empezar con el motor de entrada:}
translate S DoneWithPosition {Terminado con la posici�n}
translate S Board {Tablero}
translate S showGameInfo {Mostrar informaci�n de la partida}
translate S autoResizeBoard {Tama�o autom�tico del tablero}
translate S DockTop {Mover arriba}
translate S DockBottom {Mover abajo}
translate S DockLeft {Mover a la izquierda}
translate S DockRight {Mover a la derecha}
translate S Undock {Ventana flotante}
translate S ChangeIcon {Cambiar icono...}
# ====== TODO To be translated ======
translate S NewGameListWindow {New Game List Window}
# ====== TODO To be translated ======
translate S LoadatStartup {Load at startup}
# ====== TODO To be translated ======
translate S ShowHideDB {Show/Hide databases}
# ====== TODO To be translated ======
translate S ChangeFilter {Change filter}
# ====== TODO To be translated ======
translate S ChangeLayout {Load/Save/Change sorting criteria and column layout}
# ====== TODO To be translated ======
translate S ShowHideStatistic {Show/Hide statistics}
# ====== TODO To be translated ======
translate S BoardFilter {Show only games that matches the current board position}
# ====== TODO To be translated ======
translate S CopyGameTo {Copy Game to}
# ====== TODO To be translated ======
translate S FindBar {Find Bar}
# ====== TODO To be translated ======
translate S FindCurrentGame {Find current game}
# ====== TODO To be translated ======
translate S DeleteGame {Delete game}
# ====== TODO To be translated ======
translate S UndeleteGame {Undelete game}
# ====== TODO To be translated ======
translate S ResetSort {Reset sort}
# ====== TODO To be translated ======
translate S ConvertNullMove {Convert null moves to comments}
# ====== TODO To be translated ======
translate S SetupBoard {Setup Board}
# ====== TODO To be translated ======
translate S Rotate {Rotate}
# ====== TODO To be translated ======
translate S SwitchColors {Switch colors}
# ====== TODO To be translated ======
translate S FlipBoard {Flip Board}
# ====== TODO To be translated ======
translate S ImportPGN {Import PGN game}
# ====== TODO To be translated ======
translate S ImportingFiles {Importing PGN files in}
# ====== TODO To be translated ======
translate S ImportingFrom {Importing from}
# ====== TODO To be translated ======
translate S ImportingIn {Import games in}
# ====== TODO To be translated ======
translate S UseLastTag {Use last\ngame's tags}
# ====== TODO To be translated ======
translate S Random {Random}
# ====== TODO To be translated ======
translate S BackToMainline {Go back to mainline}
# ====== TODO To be translated ======
translate S LeaveVariant {Leave variant}
# ====== TODO To be translated ======
translate S Autoplay {Autoplay}
# ====== TODO To be translated ======
translate S ShowHideCoords {Show/Hide Coord.}
# ====== TODO To be translated ======
translate S ShowHideMaterial {Show/Hide Material}
# ====== TODO To be translated ======
translate S FullScreen {Full Screen}
# ====== TODO To be translated ======
translate S FilterStatistic {Filter Statistics}
# ====== TODO To be translated ======
translate S MakeCorrections {Make Corrections}
# ====== TODO To be translated ======
translate S Surnames {Surnames}
# ====== TODO To be translated ======
translate S Ambiguous {Ambiguous}
translate S OptionsToolbar "Barra de herramientas ventana principal"
translate S OptionsBoard "Tablero"
# ====== TODO To be translated ======
translate S OptionsMenuColor "Menu colors"
translate S OptionsBoardSize "Tama�o del tablero"
translate S OptionsBoardPieces "Estilo de piezas"
# ====== TODO To be translated ======
translate S OptionsInternationalization "Internationalization"
# ====== TODO To be translated ======
translate S MenuColorForeground "Textcolor"
# ====== TODO To be translated ======
translate S MenuColorBackground "Background"
# ====== TODO To be translated ======
translate S MenuColorSelect "Select"
translate S OptionsTablebaseDir "Seleccione hasta 4 carpetas de la tablas de finales:"
}
# end of spanish.tcl
