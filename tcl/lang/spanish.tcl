# spanish.tcl:
# Spanish translations for Scid.
# Contributed by Jordi González Boada.
# Updated by Enrique Lopez.
# Updated by Benigno Hernández Bacallado
# Untranslated messages are marked with a "***" comment.

addLanguage S Español 1 ;#iso8859-1

proc setLanguage_S {} {

# File menu:
menuText S File "Archivo" 0
menuText S FileNew "Nuevo..." 0 {Crea una nueva base de datos Scid vacía}
menuText S FileOpen "Abrir..." 1 {Abre una base de datos Scid ya existente}
menuText S FileClose "Cerrar" 0 {Cierra la base de datos Scid activa}
menuText S FileFinder "Visor..." 0 {Abre la ventana del visor de Archivos}
menuText S FileBookmarks "Partidas favoritas" 0 {Seleccionar partidas favoritas (Ctrl+B)}
menuText S FileBookmarksAdd "Añadir" 0 \
  {Señala la partida y posición actual de la base de datos}
menuText S FileBookmarksFile "Archivar" 8 \
  {Archiva un marcador para la partida y posición actual}
menuText S FileBookmarksEdit "Editar partidas favoritas..." 0 \
  {Edita los menus de las partidas favoritas}
menuText S FileBookmarksList "Mostrar partidas favoritas" 0 \
  {Muestrar las carpetas de favoritas en una sola lista, sin submenus}
menuText S FileBookmarksSub "Mostrar partidas marcadas con submenus" 0 \
  {Muestrar las carpetas de favoritas como submenus, no una sola lista}
menuText S FileMaint "Mantenimiento" 0 \
  {Herramientas de mantenimiento de la base de datos Scid}
menuText S FileMaintWin "Ventana de mantenimiento" 0 \
  {Abre/cierra la ventana de mantenimiento de la base de datos Scid}
menuText S FileMaintCompact "Compactar base de datos..." 0 \
  {Compacta los archivos de la base de datos, quitando partidas borradas y nombres no usados}
menuText S FileMaintClass "Clasificar partidas por ECO..." 24 \
  {Recalcula el código ECO de todas las partidas}
menuText S FileMaintSort "Ordenar base de datos..." 0 \
  {Ordena todas las partidas de la base de datos}
menuText S FileMaintDelete "Borrar partidas dobles..." 0 \
  {Encuentra partidas dobles y las coloca para ser borradas}
menuText S FileMaintTwin "Ventana de inspección de dobles" 11 \
  {Abre/actualiza la ventana de inspección de dobles}
menuText S FileMaintName "Ortografía de nombres" 0 {Herramientas de ortografía y edición de nombres}
menuText S FileMaintNameEditor "Ventana de edición de nombres" 22 \
  {Abre/cierra la ventana de edición de nombres}
menuText S FileMaintNamePlayer "Comprobación ortográfica de nombres de jugadores..." 39 \
  {Comprobación ortográfica de jugadores usando archivo de comprobación ortográfica}
menuText S FileMaintNameEvent "Comprobación ortográfica de nombres de eventos..." 39 \
  {Comprobación ortográfica de eventos usando el archivo de comprobación ortográfica}
menuText S FileMaintNameSite "Comprobación ortográfica de nombres de lugares..." 39 \
  {Comprobación ortográfica de lugares usando el archivo de comprobación ortográfica}
menuText S FileMaintNameRound "Comprobación ortográfica de rondas..." 28 \
  {Comprobación ortográfica de rondas usando el archivo de comprobación ortográfica}
menuText S FileReadOnly "Sólo lectura..." 5 \
  {Trata la actual base de datos como de sólo lectura, previniendo cambios}
menuText S FileSwitch "Cambiar de base de datos" 0 \
  {Cambia a una base de dator abierta diferente}
menuText S FileExit "Salir" 0 {Salir de Scid}
menuText S FileMaintFixBase "Fijar base corrupta" 0 {Prueba a fijar una base corrupta}

# Edit menu:
menuText S Edit "Editar" 0
menuText S EditAdd "Añadir variación" 0 \
  {Añade una variación a este movimiento en la partida}
menuText S EditDelete "Borrar variación" 0 {Borra variación para este movimiento}
menuText S EditFirst "Convertir en primera variación" 0 \
  {Hace que una variación sea la primera en la lista}
menuText S EditMain "Variación a línea principal" 0 \
   {Promover una variación para que sea la línea principal}
menuText S EditTrial "Probar variación" 1 \
  {Inicia/para el modo de prueba, para ensayar una idea en el tablero}
menuText S EditStrip "Eliminar" 2 \
  {Eliminar comentarios o variaciones de esta partida}
# ====== TODO To be translated ======
menuText S EditUndo "Undo" 0 {Undo last game change}
menuText S EditStripComments "Comentarios" 0 \
  {Quita todos los comentarios y variaciones de esta partida}
menuText S EditStripVars "Variaciones" 0 {Quita todas las variaciones de esta partida}
menuText S EditStripBegin "Movimientos desde el principio" 1 \
  {Quita los movimientos desde el principio de la partida}
menuText S EditStripEnd "Movimientos hasta el final" 0 \
  {Quita los movimientos hasta el final de la partida}
menuText S EditReset "Poner a cero la base de trabajo" 0 \
  {Pone a cero la base de trabajo (clipbase) para que esté completamente vacía}
menuText S EditCopy "Copiar esta partida a la base de trabajo" 1 \
  {Copia esta partida a la base de trabajo (clipbase)}
menuText S EditPaste "Pegar la última partida de la base de trabajo" 2 \
  {Pega en la base actual la partida activa en la base de trabajo (clipbase)}
menuText S EditPastePGN "Paste Clipboard text as PGN game..." 10 \
  {Interpreta el texto  de la base de trabajo (clipbase) como una partida en notacion PGN y la pega aquí}
menuText S EditSetup "Iniciar tablero de posición..." 26 \
  {Inicia el tablero de posición con la posición de la partida}
menuText S EditCopyBoard "Copiar posición" 8 \
  {Copia el tablero actual en notación FEN a la selección de texto (clipboard)}
menuText S EditPasteBoard "Pegar tablero inicial" 6 \
  {Coloca el tablero inicial de la selección de texto actual (clipboard)}

# Game menu:
menuText S Game "Partida" 0
menuText S GameNew "Partida nueva" 0 \
  {Partida nueva, descarta cambios de la partida actual}
menuText S GameFirst "Cargar primera partida" 7 {Carga la primera partida filtrada}
menuText S GamePrev "Cargar partida anterior" 16 {Carga la anterior partida filtrada}
menuText S GameReload "Recargar partida actual" 0 \
  {Vuelve a cargar esta partida, descartando cualquier cambio hecho}
menuText S GameNext "Cargar siguiente partida" 7 {Carga la siguiente partida filtrada}
menuText S GameLast "Cargar última partida" 9 {Carga la última partida filtrada}
menuText S GameRandom "Cargar partida aleatoria" 16 {Carga aleatoriamente una partida filtrada}
menuText S GameNumber "Cargar partida número..." 3 \
  {Carga una partida poniendo su número}
menuText S GameReplace "Guardar: Reemplazar partida..." 10 \
  {Guarda esta partida, reemplazando la antigua versión}
menuText S GameAdd "Guardar: Añadir nueva partida..." 9 \
  {Guarda esta partida como una nueva partida en la base de datos}
menuText S GameDeepest "Identificar apertura" 1 \
  {Va a la posición más avanzada de la partida según el libro ECO}
menuText S GameGotoMove "Ir al movimiento número..." 6 \
  {Ir al número de movimiento especificado en la partida actual}
menuText S GameNovelty "Encontrar Novedad..." 12 \
  {Encuentra el primer movimiento de esta partida que no se ha jugado antes}

# Search Menu:
menuText S Search "Buscar" 0
menuText S SearchReset "Poner a cero el filtro" 0 \
  {Poner a cero el filtro para que todas la partidas estén incluidas}
menuText S SearchNegate "Invertir filtro" 0 \
  {Invierte el filtro para sólo incluir las partidas excluidas}
menuText S SearchCurrent "Tablero actual..." 0 \
  {Busca por la posición actual del tablero}
menuText S SearchHeader "Encabezamiento..." 0 \
  {Busca por información de encabezamiento (jugador, evento, etc)}
menuText S SearchMaterial "Material/Patrón..." 0 \
  {Busca por material o patrón del tablero}
menuText S SearchUsing "Usar archivo de búsqueda..." 0 \
  {Busca usando un archivo de opciones de búsqueda}

# Windows menu:
menuText S Windows "Ventanas" 0
menuText S WindowsComment "Editor de comentarios" 0 \
  {Abre/cierra el editor de comentarios}
menuText S WindowsGList "Listado de partidas" 0 \
  {Abre/cierra la  ventana de listado de partidas}
menuText S WindowsPGN "Ventana PGN" 8 \
  {Abre/cierra la ventana de PGN (notación de partida)}
menuText S WindowsPList "Buscador de jugadores" 2 {Abre/cierra el buscador de jugadores}
menuText S WindowsTmt "Visor de Torneos" 9 {Abre/cierra el visor de torneos}
menuText S WindowsSwitcher "Intercambiador de bases de datos" 0 \
  {Abre/cierra la ventana del intercambiador de bases de datos}
menuText S WindowsMaint "Ventana de mantenimiento" 11 \
  {Abre/cierra la ventana de mantenimiento}
menuText S WindowsECO "Buscador ECO" 0 {Abre/cierra la ventana del buscador ECO}
menuText S WindowsRepertoire "Editor de repertorio" 10 \
  {Abrir/cerrar el editor de repertorio de aperturas}
menuText S WindowsStats "Ventana de estadísticas" 12 \
  {Abre/cierra la ventana de estadísticas del filtro}
menuText S WindowsTree "Ventana de Árbol de Aperturas" 6 {Abre/cierra la ventana de Árbol de Aperturas (Book)}
menuText S WindowsTB "Ventana de Tablas de  Finales (TBs)" 8 \
  {Abre/cierra la ventana de TBs}
menuText S WindowsBook "Ventana de Libros de Aperturas (Book)" 0 {Abrir/Cerrar la ventana de Libros de Aperturas (Book)}
menuText S WindowsCorrChess "Ventana de Correo" 0 {Abrir/Cerrar la ventra de Correo}

# Tools menu:
menuText S Tools "Herramientas" 0
menuText S ToolsAnalysis "Motor de análisis..." 0 \
  {Inicia/para el análisis de un motor de ajedrez}
menuText S ToolsAnalysis2 "Motor de análisis #2..." 18 \
  {Inicia/para el análisis de un motor de ajedrez}
menuText S ToolsCross "Tabla cruzada" 0 {Muestra la tabla cruzada para esta partida}
menuText S ToolsEmail "Administrador de Email" 0 \
  {Abre/cierra la ventana del administrador de Email}
menuText S ToolsFilterGraph "Filtro gráfico" 7 \
  {Abre/cierra la ventana del filtro gráfico}
menuText S ToolsAbsFilterGraph "Filtro gráfico Abs." 7 {Abrir/Cerrar la ventana de filtro gráfica para valores absolutos}
menuText S ToolsOpReport "Informe de la apertura" 1 \
  {Crea un informe de la apertura para la posición actual}
menuText S ToolsOpenBaseAsTree "Abrir base como árbol" 0   {Abrir una base y usarla en la Ventana de arbol (Tree)}
menuText S ToolsOpenRecentBaseAsTree "Abrir base reciente como árbol" 0   {Abre una base reciente y la usa en Ventana de árbol (Tree)} 
menuText S ToolsTracker "Rastreador de piezas"  14 {Abre la ventana del rastreador de piezas}
menuText S ToolsTraining "Entrenamiento"  0 {Entrenamiento (táctica, aperturas,...}
menuText S ToolsTacticalGame "Partida Táctica"  0 {Jugar una partida táctica}
menuText S ToolsSeriousGame "Partida seria"  0 {Jugar una partida seria}
menuText S ToolsTrainOpenings "Entrenamiento de aperturas"  0 {Entrenamiento con un repertorio}
menuText S ToolsTrainReviewGame "Revisar partida"  0 {Adivinar movimientos jugados en una partida}
menuText S ToolsTrainTactics "Táctica (problemas)"  0 {Resover problemas de táctica}
menuText S ToolsTrainCalvar "Cálculo of variaciones"  0 {Calculo de variantes}
menuText S ToolsTrainFindBestMove "Encontrar la mejor jugada"  0 {Busca el movimiento mejor}
menuText S ToolsTrainFics "Jugar en internet"  0 {Jugar en freechess.org}
menuText S ToolsBookTuning "Sintonizar Libro de aperturas" 0 {Sintonizar Libro (Book)}
menuText S ToolsConnectHardware "Conectar hardware" 0 {Conectar hardware externo"}
menuText S ToolsConnectHardwareConfigure "Configuración" 1 {Configuración}
menuText S ToolsConnectHardwareNovagCitrineConnect "Conectar Novag" 0 {Conectar Novag}
menuText S ToolsConnectHardwareInputEngineConnect "Conectar motor de entrada" 0 {Conectar motor de entrada (e.d. DGT)}
menuText S ToolsPInfo "Información del Jugador" 16 \
  {Abrir/actualizar la ventana de Información del Jugador}
menuText S ToolsPlayerReport "Informe del jugador..." 3 \
  {Crea un informe sobre un jugador}
menuText S ToolsRating "Gráfico del Elo" 0 \
  {Gráfico de la historia del Elo de los jugadores de la actual partida}
menuText S ToolsScore "Gráfico de puntuación" 1 \
  {Muestra la ventana del gráfico de puntuación}
menuText S ToolsExpCurrent "Exportar la partida actual" 0 \
  {Escribe la partida actual en un archivo de texto}
menuText S ToolsExpCurrentPGN "Exportar la partida a un archivo PGN..." 33 \
  {Escribe la partida actual en un archivo PGN}
menuText S ToolsExpCurrentHTML "Exportar la partida a un archivo HTML..." 33 \
  {Escribe la partida actual en un archivo HTML}
menuText S ToolsExpCurrentHTMLJS "Exportar la partida a un archivo HTML y JavaScript..." 15 {Escribir partida actual a un fichero HTML y JavaScript} 
menuText S ToolsExpCurrentLaTeX "Exportar la partida a un archivo LaTeX..." 33 \
  {Escribe la partida actual en un archivo LaTeX}
menuText S ToolsExpFilter "Exportar todas las partidas filtradas" 1 \
  {Escribe todas las partidas filtradas en un archivo de texto}
menuText S ToolsExpFilterPGN "Exportar filtro a un archivo PGN..." 29 \
  {Escribe todas las partidas filtradas en un archivo PGN}
menuText S ToolsExpFilterHTML "Exportar filtro a un archivo HTML..." 29 \
  {Escribe todas las partidas filtradas en un archivo HTML}
menuText S ToolsExpFilterHTMLJS "Exportar Filtro a un archivo HTML y JavaScript..." 17 {Escribir todas las partidas filtradas a fichero HTML y JavaScript}  
menuText S ToolsExpFilterLaTeX "Exportar filtro a un archivo LaTeX..." 29 \
  {Escribe todas las partidas filtradas en un archivo LaTeX}
menuText S ToolsImportOne "Importar una partida PGN..." 0 \
  {Importa una partida de un texto PGN}
menuText S ToolsImportFile "Importar un archivo de partidas PGN..." 2 \
  {Importa partidas de un archivo PGN}
menuText S ToolsStartEngine1 "Empezar motor 1" 0  {Empezar motor 1}
menuText S ToolsStartEngine2 "Empezar motor 2" 0  {Empezar Motor 2}
menuText S Play "Jugar" 0
menuText S CorrespondenceChess "Ajedrez por Correo" 0 {Funciones para Ajedrez por Correo basado en eMail y Xfcc}
menuText S CCConfigure "Configurar..." 0 {Configurar herramientas externas y Setup general}
menuText S CCOpenDB "Abrir base de datos..." 0 {Abrir la base de Correo por defecto}
menuText S CCRetrieve "Reparar partidas" 0 {Reparar partidas via Ayuda externa (Xfcc)}
menuText S CCInbox "Procesar correo entrante" 0 {Procesar todos los ficheros en Correo entrante de Scid (Inbox)}
menuText S CCSend "Enviar movimiento" 0 {Enviar tu movimiento via eMail o ayuda externa (Xfcc)}
menuText S CCResign "Abandonar" 0 {Abandonar}
menuText S CCClaimDraw "Reclamar tablas" 0 {Enviar un movimiento y reclamar tablas}
menuText S CCOfferDraw "Ofrecer tablas" 0 {Enviar un movimiento y ofrecer tablas}
menuText S CCAcceptDraw "Aceptar tablas" 0 {Aceptar un ofrecimiento de tablas}
menuText S CCNewMailGame "Nueva partida email..." 0 {Empezar una nueva partida eMail}
menuText S CCMailMove "Enviar jugada via email..." 0 {Envía el movimiento via eMail al oponente}
menuText S CCGamePage "Página de la partida..." 0 {Abrir la partida desde el navegador}
# ====== TODO To be translated ======
menuText S CCEditCopy "Copy Gamelist to Clipbase" 0 {Copy the games as CSV list to clipbase}

# Options menu:
menuText S Options "Opciones" 0
menuText S OptionsBoard "Tablero" 0 {Opciones sobre el aspecto del tablero}
menuText S OptionsBoardSize "Tamaño del tablero" 0 {Cambia el tamaño del tablero}
menuText S OptionsBoardPieces "Estilo de piezas" 10 \
  {Cambia el estilo de piezas del tablero}
menuText S OptionsBoardColors "Colores..." 0 {Cambia los colores del tablero}
menuText S OptionsBoardGraphics "Escaques..." 0 {Elegir texturas para escaques}
translate S OptionsBGW {Elegir textura para escaques}
translate S OptionsBoardGraphicsText {Elegir fichero gráfico para escaques blancos y negros}
menuText S OptionsBoardNames "Mis nombres de jugador..." 0 {Edita mis nombres de jugador}
menuText S OptionsExport "Exportación" 0 {Cambia las opciones de exportación de texto}
menuText S OptionsFonts "Fuentes" 0 {Cambia las fuentes}
menuText S OptionsFontsRegular "Habitual" 0 {Cambia la fuente habitual}
menuText S OptionsFontsMenu "Menú" 0 {Cambia la fuente del menú}
menuText S OptionsFontsSmall "Pequeña" 0 {Cambia la fuente pequeña}
menuText S OptionsFontsFixed "Fijada" 0 {Cambia la anchura fijada de la fuente}
menuText S OptionsGInfo "Información de la partida" 0 {Información de la partida}
menuText S OptionsLanguage "Lenguaje" 0 {Selecciona el lenguaje del menú}
menuText S OptionsMovesTranslatePieces "Traducir piezas" 0 {Traducir la primera letra de las piezas}
menuText S OptionsMovesHighlightLastMove "Iluminar última jugada" 0 {Iluminar última jugada}
menuText S OptionsMovesHighlightLastMoveDisplay "Mostrar" 0 {Mostrar última jugada iluminada}
menuText S OptionsMovesHighlightLastMoveWidth "Ancho" 0 {Espesor de la línea}
menuText S OptionsMovesHighlightLastMoveColor "Color" 0 {Color de línea}
menuText S OptionsMoves "Movimientos" 0 {Opciones de la entrada de movimientos}
menuText S OptionsMovesAsk "Preguntar antes de reemplazar movimientos" 0 \
  {Pregunta antes de sobreescribir cualquier movimiento existente}
menuText S OptionsMovesAnimate "Velocidad de la animación" 1 \
  {Pone el tiempo usado para animar las jugadas}
menuText S OptionsMovesDelay "Demora del automovimiento..." 0 \
  {Pone el tiempo de demora para el modo de automovimiento}
menuText S OptionsMovesCoord "Entrada de movimientos coordinada" 0 \
  {Acepta entrada de movimientos en sistema "coordinado" ("g1f3")}
menuText S OptionsMovesSuggest "Mostrar movimientos sugeridos" 20 \
  {Activa/desactiva la sugerencia de movimientos}
menuText S OptionsShowVarPopup "Mostrar ventana de variaciones" 0 {Activar/Desactivar La ventana de variaciones}
menuText S OptionsMovesSpace "Añadir espacios detrás de número de movimiento" 0 {Añadir espacios detrás del número de movimiento}  
menuText S OptionsMovesKey "Teclado Inteligente" 0 \
{Activa/desactiva la función de autocompletado inteligente de movimientos con teclado}
# ====== TODO To be translated ======
menuText S OptionsMovesShowVarArrows "Show Arrows for Variations" 0 {Turn on/off arrows showing moves in variations}
menuText S OptionsNumbers "Formato de números" 11 {Selecciona el formato de números}
menuText S OptionsStartup "Inicio" 3 {Seleccionar ventanas a abrir al inicio}
menuText S OptionsTheme "Tema" 0 {Cambiar vista del interfaz}
menuText S OptionsWindows "Ventanas" 0 {Opciones de ventana}
menuText S OptionsWindowsIconify "Autominimizar" 4 \
  {Minimiza todas las ventanas cuando la ventana principal es minimizada}
menuText S OptionsWindowsRaise "Poner a la vista automáticamente" 0 \
  {Hace visibles ciertas ventanas (ej. barras de progreso) siempre que sean tapadas}
menuText S OptionsSounds "Sonidos..." 2 {Configura el sonido del anuncio de las jugadas}
menuText S OptionsWindowsDock "Ventanas en dique" 0 {Ventanas en dique}
menuText S OptionsWindowsSaveLayout "Salvar disposición" 0 {Salvar disposición}
menuText S OptionsWindowsRestoreLayout "Restaurar disposición" 0 {Restaurar disposición}
menuText S OptionsWindowsShowGameInfo "Mostrar información de la partida" 0 {Mostrar información de la partida}
menuText S OptionsWindowsAutoLoadLayout "Auto cargar primera disposición" 0 {Autocargar primera disposición al iniciar}
menuText S OptionsToolbar "Barra de herramientas ventana principal" 9 \
  {Muestra/oculta la barra de herramientas de la ventana principal}
menuText S OptionsECO "Cargar archivo ECO..." 7 \
  {Cargar el archivo de clasificación ECO}
menuText S OptionsSpell "Cargar archivo de comprobación ortográfica..." 2 \
  {Carga el archivo de comprobación ortográfica Scid}
menuText S OptionsTable "Directorio de las TB...(Tablas de finales)" 19 \
  {Selecciona el directorio de finales; todas las TB de ese directorio serán usadas}
menuText S OptionsRecent "Archivos recientes..." 9 \
  {Cambia el número de archivos recientes mostrados en el menú Archivo}
menuText S OptionsBooksDir "Carpeta de libros de aperturas..." 0 {Fija la carpeta de los libros de aperturas (Books)}
menuText S OptionsTacticsBasesDir "Carpeta de bases de datos..." 0 {Fija la carpeta de la base de entrenamiento táctico}
menuText S OptionsSave "Guardar opciones" 0 \
  "Guarda todas las opciones en el fichero $::optionsFile"
menuText S OptionsAutoSave "Autoguardar opciones al salir" 0 \
  {Guarda automáticamente todas las opciones cuando se sale de Scid}

# Help menu:
menuText S Help "Ayuda" 1
menuText S HelpContents "Contenidos" 0 {Show the help contents page}
menuText S HelpIndex "Indice" 0 {Muestra la página índice de la ayuda}
menuText S HelpGuide "Guía rápida" 0 {Muestra la página de la ayuda guía rápida}
menuText S HelpHints "Sugerencias" 1 {Muestra la página de la ayuda sugerencias}
menuText S HelpContact "Información de contacto" 15 \
  {Muestra la página de la ayuda de la información de contacto}
menuText S HelpTip "Sugerencia del día" 0 {Muestra una útil sugerencia Scid}
menuText S HelpStartup "Ventana de inicio" 0 {Muestra la ventana de inicio}
menuText S HelpAbout "Acerca de Scid" 10 {Información acerca de Scid}

# Game info box popup menu:
menuText S GInfoHideNext "Ocultar siguiente movimiento" 0
menuText S GInfoMaterial "Mostrar valor del material" 0
menuText S GInfoFEN "Mostrar FEN" 8
menuText S GInfoMarks "Mostrar casillas y flechas coloreadas" 29
menuText S GInfoWrap "Dividir líneas largas" 0
menuText S GInfoFullComment "Mostrar comentarios completos" 8
menuText S GInfoPhotos "Mostrar fotos" 5
menuText S GInfoTBNothing "TBs: nada" 5
menuText S GInfoTBResult  "TBs: sólo resultado" 10
menuText S GInfoTBAll "TBs: resultado y mejor movimiento" 23
menuText S GInfoDelete "(No)Borrar esta partida" 4
menuText S GInfoMark "(No)Marcar esta partida" 4
menuText S GInfoInformant "Configurar valores de información" 0

# Main window buttons:
helpMsg S .main.fbutton.button.start {Ir al principio de la partida  (Tecla: Inicio)}
helpMsg S .main.fbutton.button.end {Ir al final de la partida  (Tecla: Fin)}
helpMsg S .main.fbutton.button.back {Ir atrás un movimiento  (Tecla: Flecha izquierda)}
helpMsg S .main.fbutton.button.forward {Ir adelante un movimiento  (Tecla: Flecha derecha)}
helpMsg S .main.fbutton.button.intoVar {Moverse dentro de una variación  (Tecla rápida: v)}
helpMsg S .main.fbutton.button.exitVar {Dejar la variación actual  (Tecla rápida: z)}
helpMsg S .main.fbutton.button.flip {Girar tablero  (Tecla rápida: .)}
helpMsg S .main.fbutton.button.coords {Poner/quitar las coordenadas del tablero  (Tecla rápida: 0)}
helpMsg S .main.fbutton.button.stm {Activa/Desactiva el icono de Turno de Juego}
helpMsg S .main.fbutton.button.autoplay {Automovimiento de los movimientos  (Tecla: Ctrl+Z)}

# General buttons:
translate S Back {Atrás}
translate S Browse {Hojear}
translate S Cancel {Cancelar}
translate S Continue {Continuar}
translate S Clear {Limpiar}
translate S Close {Cerrar}
translate S Contents {Contenidos}
translate S Defaults {Por defecto}
translate S Delete {Borrar}
translate S Graph {Gráfico}
translate S Help {Ayuda}
translate S Import {Importar}
translate S Index {Índice}
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
translate S ChangeOrient {Cambiar orientación de la ventana}
translate S ShowIcons {Show Icons} ;# ***
translate S None {Ninguno}
translate S First {Primera}
translate S Current {Actual}
translate S Last {Última}

# General messages:
translate S game {partida}
translate S games {partidas}
translate S move {movimiento}
translate S moves {movimientos}
translate S all {todo}
translate S Yes {Sí}
translate S No {No}
translate S Both {Ambos}
translate S King {Rey}
translate S Queen {Dama}
translate S Rook {Torre}
translate S Bishop {Alfil}
translate S Knight {Caballo}
translate S Pawn {Peón}
translate S White {Blancas}
translate S Black {Negras}
translate S Player {Jugador}
translate S Rating {Elo}
translate S RatingDiff {Diferencia de Elo (Blancas - Negras)}
translate S AverageRating {Elo promedio}
translate S Event {Evento}
translate S Site {Lugar}
translate S Country {País}
translate S IgnoreColors {Ignorar colores}
translate S Date {Fecha}
translate S EventDate {Evento fecha}
translate S Decade {Década}
translate S Year {Año}
translate S Month {Mes}
translate S Months {enero febrero marzo abril mayo junio julio agosto septiembre octubre noviembre diciembre}
translate S Days {dom lun mar mié jue vie sáb}
translate S YearToToday {Último año hasta hoy}
translate S Result {Resultado}
translate S Round {Ronda}
translate S Length {Longitud}
translate S ECOCode {Código ECO}
translate S ECO {ECO}
translate S Deleted {Borrar}
translate S SearchResults {Buscar resultados}
translate S OpeningTheDatabase {Abriendo base de datos}
translate S Database {Base de datos}
translate S Filter {Filtro}
translate S noGames {no hay partidas}
translate S allGames {todas las partidas}
translate S empty {vacía}
translate S clipbase {clipbase}
translate S score {puntuación}
translate S StartPos {Posición inicial}
translate S Total {Total}
translate S readonly {sólo lectura}

# Standard error messages:
translate S ErrNotOpen {Esta base de datos no está abierta.}
translate S ErrReadOnly {Esta base de datos es de sólo lectura; no puede ser cambiada.}
translate S ErrSearchInterrupted {La busqueda se interrumpio; los resultados son incompletos.}

# Game information:
translate S twin {doble}
translate S deleted {borradas}
translate S comment {comentario}
translate S hidden {oculto}
translate S LastMove {Último movimiento}
translate S NextMove {Siguiente}
translate S GameStart {Inicio de partida}
translate S LineStart {Inicio de línea}
translate S GameEnd {Fin de partida}
translate S LineEnd {Fin de línea}

# Player information:
translate S PInfoAll {Resultados para <b>todas</b> las partidas}
translate S PInfoFilter {Resultados para las partidas <b>filtradas</b>}
translate S PInfoAgainst {Resultados contra}
translate S PInfoMostWhite {Aperturas más comunes con Blancas}
translate S PInfoMostBlack {Aperturas más comunes con Negras}
translate S PInfoRating {Historial de clasificación}
translate S PInfoBio {Biografía}
translate S PInfoEditRatings {Editar elos}

# Tablebase information:
translate S Draw {Tablas}
translate S stalemate {rey ahogado}
translate S withAllMoves {con todos los movimientos}
translate S withAllButOneMove {con todos los movimientos excepto uno}
translate S with {con}
translate S only {sólo}
translate S lose {formas de perder}
translate S loses {hace perder}
translate S allOthersLose {todos los demás hacen perder}
translate S matesIn {mate en}
translate S hasCheckmated {jaque mate}
translate S longest {el mate más largo}
translate S WinningMoves {Movimientos ganadores}
translate S DrawingMoves {Movimientos para tablas}
translate S LosingMoves {Movimientos perdedores}
translate S UnknownMoves {Movimientos de resultado desconocido}

# Tip of the day:
translate S Tip {Sugerencia}
translate S TipAtStartup {Sugerencia al iniciar}

# Tree window menus:
menuText S TreeFile "Archivo" 0
menuText S TreeFileFillWithBase "Rellenar Caché con base" 0 {Rellenar el archivo Caché con todas las partidas de la base actual}
menuText S TreeFileFillWithGame "Rellenar Caché con partida" 0 {Rellena el fichero Caché con movimientos de la partida actual en la base actual}
menuText S TreeFileSetCacheSize "Tamaño de Caché" 0 {Fija el tamaño del Caché}
menuText S TreeFileCacheInfo "Información de Caché" 0 {Información y uso del Caché}
menuText S TreeFileSave "Guardar archivo caché" 0 \
  {Guarda el archivo caché del árbol (.stc)}
menuText S TreeFileFill "Construir archivo caché" 2 \
  {Construir archivo caché con posiciones de apertura comunes}
menuText S TreeFileBest "Lista de mejores partidas" 9 {Muestra la lista del árbol de mejores partidas}
menuText S TreeFileGraph "Ventana del gráfico" 0 \
  {Muestra el gráfico para esta rama del árbol}
menuText S TreeFileCopy "Copiar texto del árbol al clipboard" 1 \
  {Copiar texto del árbol al clipboard}
menuText S TreeFileClose "Cerrar ventana del árbol" 0 \
  {Cerrar ventana del árbol}
menuText S TreeMask "Máscara" 0
menuText S TreeMaskNew "Nuevo" 0 {Nueva máscara}
menuText S TreeMaskOpen "Abrir" 0 {Abrir máscara}
menuText S TreeMaskOpenRecent "Abrir reciente" 0 {Abrir máscara reciente}
menuText S TreeMaskSave "Salvar" 0 {Salvar máscara}
menuText S TreeMaskClose "Cerrar" 0 {Cerrar máscara}
menuText S TreeMaskFillWithGame "Llenar con partida" 0 {Llenar máscara con partida}
menuText S TreeMaskFillWithBase "LLenar con base" 0 {Llenar máscar con todas las partidas de la base}
menuText S TreeMaskInfo "Info" 0 {Muestra estadísticas para la máscara actual}
menuText S TreeMaskDisplay "Mostrar mapa de la máscara" 0 {Mostrar máscara en forma de árbol}
menuText S TreeMaskSearch "Buscar" 0 {Buscar en máscara actual}
menuText S TreeSort "Ordenar" 0
menuText S TreeSortAlpha "Alfabéticamente" 0
menuText S TreeSortECO "Por código ECO" 11
menuText S TreeSortFreq "Por frecuencia" 4
menuText S TreeSortScore "Por puntuación" 4
menuText S TreeOpt "Opciones" 1
menuText S TreeOptSlowmode "Modo Lento" 0 {Movimiento lento para actualizaciones (Alta calidad)}
menuText S TreeOptFastmode "Modo Rápido" 0 {Movimiento rápido para actualizaciones (no transpone movimientos)}
menuText S TreeOptFastAndSlowmode "Modo Rápido y Lento" 0 {Movimiento rápido y modo lento para actualizaciones}
menuText S TreeOptStartStop "Auto actualizado" 0 {Actualizado automático de la ventana del árbol}
menuText S TreeOptLock "Bloquear" 1 {Bloquea/desbloquea el árbol de la base de datos actual}
menuText S TreeOptTraining "Entrenamiento" 2 {Activa/desactiva el modo de entrenamiento de árbol}
menuText S TreeOptAutosave "Autoguardar archivo caché" 0 \
  {Guarda automáticamente el archivo caché cuuando se cierra la ventana de árbol}
menuText S TreeHelp "Ayuda" 1
menuText S TreeHelpTree "Ayuda del árbol" 4
menuText S TreeHelpIndex "Indice de la ayuda" 0
translate S SaveCache {Guardar caché}
translate S Training {Entrenamiento}
translate S LockTree {Bloquear}
translate S TreeLocked {Bloqueado}
translate S TreeBest {Mejor}
translate S TreeBestGames {Mejores partidas del árbol}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate S TreeTitleRow \
  {    Movim. ECO       Frecuencia   Puntu. AvElo Perf AvAño %Tablas}
translate S TreeTotal {TOTAL}
translate S DoYouWantToSaveFirst {Quieres salvar primero}
translate S AddToMask {Añadir a máscara}
translate S RemoveFromMask {Elimina desde la máscara}
translate S AddThisMoveToMask {Añadir este movimiento a la Máscara}
translate S SearchMask {Buscar en máscara}
translate S DisplayMask {Mostrar máscara}
translate S Nag {Código de regaño}
translate S Marker {Marcador}
translate S Include {Incluir}
translate S Exclude {Excluir}
translate S MainLine {Línea principal}
translate S Bookmark {Favorito}
translate S NewLine {Línea nueva}
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
translate S CommentPosition {Comentar posición}
translate S AddMoveToMaskFirst {Añadir primero el movimiento a la máscara}
translate S OpenAMaskFileFirst {Abrir primero un fichero de máscara}
translate S Positions {Posiciones}
translate S Moves {Jugadas}

# Finder window:
menuText S FinderFile "Archivo" 0
menuText S FinderFileSubdirs "Mirar en subdirectorios" 0
menuText S FinderFileClose "Cierra visor de Archivos" 0
menuText S FinderSort "Ordenar" 0
menuText S FinderSortType "Tipo" 0
menuText S FinderSortSize "Tamaño" 0
menuText S FinderSortMod "Modificado" 0
menuText S FinderSortName "Nombre" 0
menuText S FinderSortPath "Camino" 0
menuText S FinderTypes "Tipos" 0
menuText S FinderTypesScid "Bases de datos Scid" 0
menuText S FinderTypesOld "Bases de datos Scid en antiguo formato" 12
menuText S FinderTypesPGN "Archivos PGN" 9
menuText S FinderTypesEPD "Archivos EPD (libro)" 0
menuText S FinderTypesRep "Archivos de Repertorio" 12
menuText S FinderHelp "Ayuda" 1
menuText S FinderHelpFinder "Ayuda del visor de Archivos" 0
menuText S FinderHelpIndex "Indice de la ayuda" 0
translate S FileFinder {Visor de Archivos}
translate S FinderDir {Directorio}
translate S FinderDirs {Directorios}
translate S FinderFiles {Archivos}
translate S FinderUpDir {arriba}
translate S FinderCtxOpen {Abrir}
translate S FinderCtxBackup {Copia de seguridad (Backup)}
translate S FinderCtxCopy {Copia}
translate S FinderCtxMove {Jugada}
translate S FinderCtxDelete {Borrar}

# Player finder:
menuText S PListFile "Archivo" 0
menuText S PListFileUpdate "Actualizar" 0
menuText S PListFileClose "Cierra el Buscador de Jugadores" 0
menuText S PListSort "Ordenar" 0
menuText S PListSortName "Nombre" 0
menuText S PListSortElo "Elo" 0
menuText S PListSortGames "Partidas" 0
menuText S PListSortOldest "Más antiguo" 10
menuText S PListSortNewest "Más nuevo" 4

# Tournament finder:
menuText S TmtFile "Archivo" 0
menuText S TmtFileUpdate "Actualizar" 0
menuText S TmtFileClose "Cierra el Visor de Torneos" 0
menuText S TmtSort "Ordenar" 0
menuText S TmtSortDate "Fecha" 0
menuText S TmtSortPlayers "Jugadores" 0
menuText S TmtSortGames "Partidas" 0
menuText S TmtSortElo "Elo" 0
menuText S TmtSortSite "Lugar" 0
menuText S TmtSortEvent "Evento" 1
menuText S TmtSortWinner "Ganador" 0
translate S TmtLimit "Límite de lista"
translate S TmtMeanElo "Media de Elo inferior"
translate S TmtNone "No se han encontrado torneos concordantes."

# Graph windows:
menuText S GraphFile "Archivo" 0
menuText S GraphFileColor "Guardar como Postscript Color..." 24
menuText S GraphFileGrey "Guardar como Postscript escala de grises..." 34
menuText S GraphFileClose "Cerrar ventana" 7
menuText S GraphOptions "Opciones" 0
menuText S GraphOptionsWhite "Blancas" 0
menuText S GraphOptionsBlack "Negras" 0
menuText S GraphOptionsBoth "Ambos" 0
menuText S GraphOptionsPInfo "Jugador Información jugador" 0
translate S GraphFilterTitle "Filtro gráfico: frecuencia por 1000 partidas"
translate S GraphAbsFilterTitle "Filtro gráfico: frecuencia de las partidas"
translate S ConfigureFilter {Configurar Eje-X para Año, Rating y Movimientos}
translate S FilterEstimate "Estimar"
translate S TitleFilterGraph "Scid: Filtro Gráfico"

# Analysis window:
translate S AddVariation {Añadir variación}
translate S AddAllVariations {Añadir todas las variaciones}
translate S AddMove {Añadir movimiento}
translate S Annotate {Anotar}
translate S ShowAnalysisBoard {Mostrar tablero de análisis}
translate S ShowInfo {Muestra info del motor}
translate S FinishGame {Finalizar partida}
translate S StopEngine {Parar motor}
translate S StartEngine {Empezar motor}
translate S LockEngine {Bloquea motor en posición actual}
translate S AnalysisCommand {Dirección de análisis}
translate S PreviousChoices {Elección previa}
translate S AnnotateTime {Poner el tiempo entre movimientos en segundos}
translate S AnnotateWhich {Añadir variaciones}
translate S AnnotateAll {Para movimientos de ambos lados}
translate S AnnotateAllMoves {Anotar todos los movimientos}
translate S AnnotateWhite {Sólo para movimientos de las Blancas}
translate S AnnotateBlack {Sólo para movimientos de las Negras}
translate S AnnotateNotBest {Cuando el movimiento de la partida no es el mejor}
translate S AnnotateBlundersOnly {Cuando el movimiento de la partida es un error}
translate S AnnotateBlundersOnlyScoreChange {Análisis reporta errores, con cambio de puntuación desde: }
translate S BlundersThreshold {Umbral del error }
translate S LowPriority {Baja prioridad del procesador}
translate S ClickHereToSeeMoves {Click aquí para ver movimientos}
translate S ConfigureInformant {Configurar informaciones}
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
translate S EngineList {Lista de Motores de Análisis}
translate S EngineName {Nombre}
translate S EngineCmd {Orden}
translate S EngineArgs {Parámetros}
translate S EngineDir {Directorio}
translate S EngineElo {Elo}
translate S EngineTime {Fecha}
translate S EngineNew {Nuevo}
translate S EngineEdit {Editar}
translate S EngineRequired {Los campos en negrita son obligatorios; los demás opcionales}

# Stats window menus:
menuText S StatsFile "Archivo" 0
menuText S StatsFilePrint "Imprimir en archivo..." 0
menuText S StatsFileClose "Cerrar ventana" 0
menuText S StatsOpt "Opciones" 0

# PGN window menus:
menuText S PgnFile "Archivo" 0
menuText S PgnFileCopy "Copiar partida al portapapeles" 0
menuText S PgnFilePrint "Imprimir en archivo..." 0
menuText S PgnFileClose "Cerrar ventana PGN" 0
menuText S PgnOpt "Presentación" 0
menuText S PgnOptColor "Color de la presentación" 0
menuText S PgnOptShort "Encabezado pequeño (3 líneas)" 13
menuText S PgnOptSymbols "Anotaciones simbólicas" 0
menuText S PgnOptIndentC "Sangría en comentarios" 0
menuText S PgnOptIndentV "Sangría en variaciones" 11
menuText S PgnOptColumn "Estilo de columna (un movimiento por línea)" 1
menuText S PgnOptSpace "Espacio después del número del movimiento" 0
menuText S PgnOptStripMarks "Quitar códigos de color en casilla/flecha" 3
menuText S PgnOptBoldMainLine "Usar texto en negrita para las jugadas principales" 4
menuText S PgnColor "Colores" 1
menuText S PgnColorHeader "Encabezamiento..." 0
menuText S PgnColorAnno "Anotaciones..." 0
menuText S PgnColorComments "Comentarios..." 0
menuText S PgnColorVars "Variaciones..." 0
menuText S PgnColorBackground "Fondo..." 0
menuText S PgnColorMain "Linea principal..." 0
menuText S PgnColorCurrent "Color de fondo del último movimiento..." 1
menuText S PgnColorNextMove "Color de fondo Next move background..." 0
menuText S PgnHelp "Ayuda" 1
menuText S PgnHelpPgn "Ayuda de PGN" 9
menuText S PgnHelpIndex "Indice de la ayuda" 0
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
menuText S CrosstabOpt "Presentación" 0
menuText S CrosstabOptAll "Todos contra todos" 0
menuText S CrosstabOptSwiss "Suizo" 0
menuText S CrosstabOptKnockout "Eliminatoria directa" 0
menuText S CrosstabOptAuto "Auto" 0
menuText S CrosstabOptAges "Edad en años" 1
menuText S CrosstabOptNats "Nacionalidades" 0
menuText S CrosstabOptRatings "Elo" 0
menuText S CrosstabOptTitles "Títulos" 0
menuText S CrosstabOptBreaks "Puntuaciones de desempate" 0
menuText S CrosstabOptDeleted "Incluir partidas borradas" 17
menuText S CrosstabOptColors "Colores (sólo en tabla de Suizos)" 0
menuText S CrosstabOptColumnNumbers "Columnas numeradas (Sólo en tabla todos contra todos)" 11
menuText S CrosstabOptGroup "Grupos de clasificación" 0
menuText S CrosstabSort "Ordenar" 0
menuText S CrosstabSortName "Por nombre" 4
menuText S CrosstabSortRating "Por Elo" 4
menuText S CrosstabSortScore "Por puntuación" 4
menuText S CrosstabColor "Color" 2
menuText S CrosstabColorPlain "Texto simple" 0
menuText S CrosstabColorHyper "Hipertexto" 0
menuText S CrosstabHelp "Ayuda" 1
menuText S CrosstabHelpCross "Ayuda de tabla cruzada" 9
menuText S CrosstabHelpIndex "Indice de la ayuda" 0
translate S SetFilter {Poner filtro}
translate S AddToFilter {Añadir al filtro}
translate S Swiss {Suizo}
translate S Category {Categoría}

# Opening report window menus:
menuText S OprepFile "Archivo" 0
menuText S OprepFileText "Imprimir en archivo texto..." 20
menuText S OprepFileHtml "Imprimir en archivo HTML..." 20
menuText S OprepFileLaTeX "Imprimir en archivo LaTeX..." 20
menuText S OprepFileOptions "Opciones..." 0
menuText S OprepFileClose "Cerrar ventana del informe de la apertura" 0
menuText S OprepFavorites "Favoritos" 1
menuText S OprepFavoritesAdd "Añadir informe..." 0
menuText S OprepFavoritesEdit "Editar informe favorito..." 0
menuText S OprepFavoritesGenerate "Generar informe..." 0
menuText S OprepHelp "Ayuda" 1
menuText S OprepHelpReport "Ayuda del informe de la apertura" 11
menuText S OprepHelpIndex "Indice de la ayuda" 0

# Repertoire editor:
menuText S RepFile "Archivo" 0
menuText S RepFileNew "Nuevo" 0
menuText S RepFileOpen "Abrir..." 0
menuText S RepFileSave "Guardar..." 0
menuText S RepFileSaveAs "Guardar como..." 1
menuText S RepFileClose "Cerrar ventana" 0
menuText S RepEdit "Editar" 0
menuText S RepEditGroup "Añadir grupo" 7
menuText S RepEditInclude "Añadir línea incluida" 13
menuText S RepEditExclude "Añadir línea excluida" 13
menuText S RepView "Ver" 0
menuText S RepViewExpand "Expandir todos los grupos" 0
menuText S RepViewCollapse "Colapsar todos los grupos" 0
menuText S RepSearch "Buscar" 0
menuText S RepSearchAll "Todo el repertorio..." 0
menuText S RepSearchDisplayed "Sólo las líneas mostradas..." 16
menuText S RepHelp "Ayuda" 1
menuText S RepHelpRep "Ayuda del repertorio" 10
menuText S RepHelpIndex "Indice de la ayuda" 0
translate S RepSearch "Búsqueda del repertorio"
translate S RepIncludedLines "Líneas incluidas"
translate S RepExcludedLines "Líneas excluidas"
translate S RepCloseDialog {Este repertorio tiene cambios no guardados.

¿Realmente quieres continuar y descartar los cambios que has hecho?
}

# Header search:
translate S HeaderSearch {Búsqueda por encabezamiento}
translate S EndSideToMove {Bando a mover al final de la partida}
translate S GamesWithNoECO {¿Partidas sin ECO?}
translate S GameLength {Duración:}
translate S FindGamesWith {Encontrar partidas con}
translate S StdStart {Inicio estándar}
translate S Promotions {Promociones}
translate S Comments {Comentarios}
translate S Variations {Variaciones}
translate S Annotations {Anotaciones}
translate S DeleteFlag {Señal de borrado}
translate S WhiteOpFlag {Apertura de las blancas}
translate S BlackOpFlag {Apertura de las negras}
translate S MiddlegameFlag {Mediojuego}
translate S EndgameFlag {Finales}
translate S NoveltyFlag {Novedad}
translate S PawnFlag {Estructura de peones}
translate S TacticsFlag {Tacticas}
translate S QsideFlag {Juego del lado de dama}
translate S KsideFlag {Juego del lado de rey}
translate S BrilliancyFlag {Genialidad}
translate S BlunderFlag {Error}
translate S UserFlag {Usuario}
translate S PgnContains {PGN contiene texto}

# Game list window:
translate S GlistNumber {Número}
translate S GlistWhite {Blancas}
translate S GlistBlack {Negras}
translate S GlistWElo {B-Elo}
translate S GlistBElo {N-Elo}
translate S GlistEvent {Evento}
translate S GlistSite {Lugar}
translate S GlistRound {Ronda}
translate S GlistDate {Fecha}
translate S GlistYear {Año}
translate S GlistEDate {Evento-Fecha}
translate S GlistResult {Resultado}
translate S GlistLength {Longitud}
translate S GlistCountry {País}
translate S GlistECO {ECO}
translate S GlistOpening {Apertura}
translate S GlistEndMaterial {Material final}
translate S GlistDeleted {Borrado}
translate S GlistFlags {Señal}
translate S GlistVars {Variaciones}
translate S GlistComments {Comentarios}
translate S GlistAnnos {Anotaciones}
translate S GlistStart {Inicio}
translate S GlistGameNumber {Número de partida}
translate S GlistFindText {Encontrar texto}
translate S GlistMoveField {Movimiento}
translate S GlistEditField {Configurar}
translate S GlistAddField {Añadir}
translate S GlistDeleteField {Quitar}
translate S GlistWidth {Anchura}
translate S GlistAlign {Alinear}
translate S GlistColor {Color}
translate S GlistSep {Separador}
translate S GlistRemoveThisGameFromFilter  {Quita esta partida del Filtro}
translate S GlistRemoveGameAndAboveFromFilter  {Quita esta partida y todas las de arriba del Filtro}
translate S GlistRemoveGameAndBelowFromFilter  {Quita esta partida y todas las de abajo del Filtro}
translate S GlistDeleteGame {Elimina/Recupera esta partida de la base} 
translate S GlistDeleteAllGames {Elimina todas las partidas de la base que aparecen en el Filtro} 
translate S GlistUndeleteAllGames {Recupera todas las partidas borradas de la base que aparecen en el filtro} 
translate S GlistMergeGameInBase {Fusionar la partida en otra base} 

# Maintenance window:
translate S DatabaseName {Nombre de la base:}
translate S TypeIcon {Tipo de icono:}
translate S NumOfGames {Partidas:}
translate S NumDeletedGames {Partidas borradas:}
translate S NumFilterGames {Partidas en el filtro:}
translate S YearRange {Rango de años:}
translate S RatingRange {Rango de Elo:}
translate S Description {Descripción}
translate S Flag {Señal}
# ====== TODO To be translated ======
translate S CustomFlags {Custom flags}
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
translate S Spellchecking {Revisión ortográfica}
translate S Players {Jugadores}
translate S Events {Eventos}
translate S Sites {Lugares}
translate S Rounds {Rondas}
translate S DatabaseOps {Operaciones con la base de datos}
translate S ReclassifyGames {Reclasificar partidas por ECO...}
translate S CompactDatabase {Compactar base de datos}
translate S SortDatabase {Ordenar base de datos}
translate S AddEloRatings {Añadir clasificación Elo}
translate S AutoloadGame {Autocargar número de partida}
translate S StripTags {Quitar etiquetas PGN}
translate S StripTag {Quitar etiquetas}
translate S Cleaner {MultiHerramienta}
translate S CleanerHelp {
Scid ejecutará, en la actual base de datos, todas las acciones de mantenimiento
que selecciones de la siguiente lista.

Se aplicará el estado actual en la clasificación ECO y el diálogo de borrado de
dobles si seleccionas esas funciones.
}
translate S CleanerConfirm {
¡Una vez que la MultiHerramienta de mantenimiento se inicia no puede ser interrumpida!

Esto puede tomar mucho tiempo en una base de datos grande, dependiendo de las funciones que hallas seleccionado y su estado actual.

¿Estás seguro de querer comenzar las funciones de mantenimiento que has seleccionado?
}
translate S TwinCheckUndelete {Pulsar "u" para no borrar ninguna (undelete)}
translate S TwinCheckprevPair {Pareja previa}
translate S TwinChecknextPair {Próxima Pareja}
translate S TwinChecker {Scid: Verificar partidas dobles}
translate S TwinCheckTournament {Partidas en torneo:}
translate S TwinCheckNoTwin {No doble  }
translate S TwinCheckNoTwinfound {No fueron detectados dobles para esta partida.\nto mostrar dobles usando esta ventana debes usar la función “Borrar partidas dobles..." }
translate S TwinCheckTag {Compartir etiquetas...}
translate S TwinCheckFound1 {Scid encontró $result partidas dobles}
translate S TwinCheckFound2 {y pone pone sus banderas de borrado}
translate S TwinCheckNoDelete {No hay partidas en esta base para borrar.}
translate S TwinCriteria1 {Tus parámetros para encontrar partidas dobles potencialmente pueden causar partidas no-dobles con movimientos similares a ser marcadas como dobles.}
translate S TwinCriteria2 {Es recomendable que si tu elijas  "No" para "algunos movimientos", tu deberías elegir "Sí"  para los parámetros colores, eventos, lugar, ronda, año y mes.\n¿Quieres continuar y borrar partidas dobles en cualquier caso?}
translate S TwinCriteria3 {Es recomendable que tú especifiques "Sí" para al menos dos parámetros de "mismo lugar", "misma ronda" y "mismo año".\n¿Quieres continuar y borrar dobles en todo caso?}
translate S TwinCriteriaConfirm {Scid: Confirmar parámetros para partidas dobles}
translate S TwinChangeTag "Cambiar las siguientes etiquetas de las:\n\n partidas"
translate S AllocRatingDescription "Este comando usará el actual fichero SpellCheck para añadir  puntuaciones ELO y partidas en esta base. Donde quiera que un jugador no tenga puntuación pero su puntuación en el listado del  fichero  spellcheck , su puntuación será añadida."
translate S RatingOverride "¿Sobre-escribir puntuaciones existentes no nulas?"
translate S AddRatings "Añadir puntuaciones a:"
translate S AddedRatings {Scid añació $r puntuaciones Elo en $g partidas.}
translate S NewSubmenu "Nuevo submenu"

# Comment editor:
translate S AnnotationSymbols  {Símbolos de anotación:}
translate S Comment {Comentario:}
translate S InsertMark {Insertar marca}
translate S InsertMarkHelp {
Insertar/quitar marca: Selecciona color, tipo, casilla.
Insertar/quitar flecha: Botón derecho sobre dos casillas.
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
translate S BoardSearch {Tablero de búsqueda}
translate S FilterOperation {Operación en filtro actual:}
translate S FilterAnd {Y (Restringir filtro)}
translate S FilterOr {O (Añadir al filtro)}
translate S FilterIgnore {IGNORAR (Poner a cero el filtro)}
translate S SearchType {Tipo de búsqueda:}
translate S SearchBoardExact {Posición exacta (todas las piezas en las mismas casillas)}
translate S SearchBoardPawns {Peones (igual material, todos los peones en las mismas casillas)}
translate S SearchBoardFiles {Columnas (igual material, todos los peones en las mismas columnas)}
translate S SearchBoardAny {Cualquiera (igual material, peones y piezas en cualquier parte)}
translate S SearchInRefDatabase {Búsqueda en la base de referencia}
translate S LookInVars {Mirar en variaciones}

# Material search:
translate S MaterialSearch {Búsqueda de Material}
translate S Material {Material}
translate S Patterns {Patrones}
translate S Zero {Cero}
translate S Any {Cualquiera}
translate S CurrentBoard {Tablero Actual}
translate S CommonEndings {Finales comunes}
translate S CommonPatterns {Patrones comunes}
translate S MaterialDiff {Diferencia de material}
translate S squares {casillas}
translate S SameColor {Igual color}
translate S OppColor {Color opuesto}
translate S Either {Cualquiera}
translate S MoveNumberRange {Rango de número de movimientos}
translate S MatchForAtLeast {Encuentro de al menos}
translate S HalfMoves {medios movimientos}

# Common endings in material search:
translate S EndingPawns {Finales de peones}
translate S EndingRookVsPawns {Torre vs. peon(es)}
translate S EndingRookPawnVsRook {Torre y 1 peón vs. torre}
translate S EndingRookPawnsVsRook {Torre y peon(es) vs. torre}
translate S EndingRooks {Finales de torre vs. torre}
translate S EndingRooksPassedA {Finales de torre vs. torre con peón pasado}
translate S EndingRooksDouble {Finales de dos torres}
translate S EndingBishops {Finales de alfil vs. alfil}
translate S EndingBishopVsKnight {Finales de alfil vs. caballo}
translate S EndingKnights {Finales de caballo vs. caballo}
translate S EndingQueens {Finales de dama vs. dama}
translate S EndingQueenPawnVsQueen {Dama y 1 peón vs. dama}
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
translate S EmptyBoard {Tablero vacío}
translate S InitialBoard {Tablero inicial}
translate S SideToMove {Lado que mueve}
translate S MoveNumber {Movimiento número}
translate S Castling {Enroque}
translate S EnPassantFile {Columna al paso}
translate S ClearFen {Quitar FEN}
translate S PasteFen {Pegar FEN}
translate S SaveAndContinue {Salvar (grabar) y continuar}
translate S DiscardChangesAndContinue {Descartar \n cambios y continuar}
translate S GoBack {Volver atrás}

# Replace move dialog:
translate S ReplaceMove {Reemplazar movimiento}
translate S AddNewVar {Añadir nueva variación}
translate S NewMainLine {Nueva Linea Principal}
translate S ReplaceMoveMessage {Ya existe un movimiento.

Puedes reemplazarlo, descartando todos los movimientos posteriores, o añadirlo como una nueva variación.

(Puedes evitar seguir viendo este mensaje en el futuro desactivando la opción "Preguntar antes de reemplazar movimientos" en el menú Opciones: Movimientos.)}

# Make database read-only dialog:
translate S ReadOnlyDialog {Si haces que esta base de datos sea de sólo lectura no se permitirán hacer cambios. No se podrán guardar o reemplazar partidas, y no se podrán alterar las señales de borrada. Cualquier ordenación o clasificación por ECO será temporal.

Puedes hacer fácilmente escribible la base de datos otra vez cerrándola y abriéndola.

¿Realmente quieres hacer que esta base de datos sea de sólo lectura?}

# Clear game dialog:
translate S ClearGameDialog {Esta partida ha sido cambiada.

¿Realmente quieres continuar y eliminar los cambios hechos en ella?
}

# Exit dialog:
translate S ExitDialog {¿Realmente quieres salir de Scid?}
translate S ExitUnsaved {La siguiente base de datos tiene cambios en partidas no guardados. Si sales ahora se perderán estos cambios.}

# Import window:
translate S PasteCurrentGame {Pegar partida actual}
translate S ImportHelp1 \
  {Introducir o pegar una partida en formato PGN en el marco superior.}
translate S ImportHelp2 \
  {Cualquier error importando la partida será mostrado aquí.}
translate S OverwriteExistingMoves {¿SobreEscribir movimientos existentes?}

# ECO Browser:
translate S ECOAllSections {todas las divisiones ECO}
translate S ECOSection {división ECO}
translate S ECOSummary {Resumen de}
translate S ECOFrequency {Frecuencia de los subcódigos para}

# Opening Report:
translate S OprepTitle {Informe de la apertura}
translate S OprepReport {Informe}
translate S OprepGenerated {Generado por}
translate S OprepStatsHist {Estadísticas e Historia}
translate S OprepStats {Estadísticas}
translate S OprepStatAll {Todas las partidas referidas}
translate S OprepStatBoth {Ambos con Elo}
translate S OprepStatSince {Desde}
translate S OprepOldest {Partidas más antiguas}
translate S OprepNewest {Partidas más nuevas}
translate S OprepPopular {Popularidad actual}
translate S OprepFreqAll {Frecuencia durante todos los años: }
translate S OprepFreq1   {Desde el último año hasta hoy:     }
translate S OprepFreq5   {En los últimos 5 años hasta hoy:   }
translate S OprepFreq10  {En los últimos 10 años hasta hoy:  }
translate S OprepEvery {una vez cada %u partidas}
translate S OprepUp {sube un %u%s respecto al total de años}
translate S OprepDown {baja un %u%s respecto al total de años}
translate S OprepSame {no hay cambios respecto al total de años}
translate S OprepMostFrequent {Jugadores más frecuentes}
translate S OprepMostFrequentOpponents {Rivales más frecuentes}
translate S OprepRatingsPerf {Elo y Rendimiento}
translate S OprepAvgPerf {Promedio de Elo y rendimiento}
translate S OprepWRating {Elo de las blancas}
translate S OprepBRating {Elo de las negras}
translate S OprepWPerf {Rendimiento de las blancas}
translate S OprepBPerf {Rendimiento de las negras}
translate S OprepHighRating {Partida con el mayor promedio de Elo}
translate S OprepTrends {Tendencias de Resultados}
translate S OprepResults {Resultado de duraciones y frecuencias}
translate S OprepLength {Duración de la partida}
translate S OprepFrequency {Frecuencia}
translate S OprepWWins {Blancas ganan: }
translate S OprepBWins {Negras ganan:  }
translate S OprepDraws {Tablas:        }
translate S OprepWholeDB {en el conjunto de la base de datos}
translate S OprepShortest {Triunfos más cortos}
translate S OprepMovesThemes {Movimientos y temas}
translate S OprepMoveOrders {Líneas de movimientos que alcanzan la posición del informe}
translate S OprepMoveOrdersOne \
  {Sólo hay una línea de movimientos que alcanza esta posición:}
translate S OprepMoveOrdersAll \
  {Hay %u líneas de movimiento que alcanzan esta posición:}
translate S OprepMoveOrdersMany \
  {Hay %u líneas de movimiento que alcanzan esta posición. Las %u más comunes son:}
translate S OprepMovesFrom {Movimientos desde la posición del informe}
translate S OprepMostFrequentEcoCodes {Aperturas más frecuentes}
translate S OprepThemes {Temas Posicionales}
translate S OprepThemeDescription {Frecuencia de los temas en las primeras %u jugadas de cada partida}
translate S OprepThemeSameCastling {Enroque al mismo lado}
translate S OprepThemeOppCastling {Enroque en lados opuestos}
translate S OprepThemeNoCastling {Ambos Reyes no enrocados}
translate S OprepThemeKPawnStorm {Avanzada de los peones del Rey}
translate S OprepThemeQueenswap {Damas intercambiadas}
translate S OprepThemeWIQP {Peón de dama aislado de las blancas}
translate S OprepThemeBIQP {Peón de dama aislado de las negras}
translate S OprepThemeWP567 {Peones blancos en 5/6/7ª fila}
translate S OprepThemeBP234 {Peones negros en 2/3/4ª fila}
translate S OprepThemeOpenCDE {Columnas c/d/e abiertas}
translate S OprepTheme1BishopPair {Un lado tiene los dos alfiles}
translate S OprepEndgames {Finales}
translate S OprepReportGames {Informe de partidas}
translate S OprepAllGames {Todas las partidas}
translate S OprepEndClass {Tipos de finales según la última posición de las partidas}
translate S OprepTheoryTable {Tabla Teórica}
translate S OprepTableComment {Generado a partir de las %u partidas con mejor Elo.}
translate S OprepExtraMoves {Anotación extra de movimientos en la tabla teórica}
translate S OprepMaxGames {Máximas partidas en la tabla teórica}
translate S OprepViewHTML {Ver HTML}
translate S OprepViewLaTeX {Ver LaTeX}

# Player Report:
translate S PReportTitle {Informe del jugador}
translate S PReportColorWhite {con las piezas blancas}
translate S PReportColorBlack {con las piezas negras}
translate S PReportMoves {%s después}
translate S PReportOpenings {Aperturas}
translate S PReportClipbase {Vaciar portapapeles y copiar las partidas}

# Piece Tracker window:
translate S TrackerSelectSingle {El botón izquierdo selecciona esta pieza.}
translate S TrackerSelectPair {El botón izquierdo selecciona esta pieza; el botón derecho también selecciona su hermana.}
translate S TrackerSelectPawn {El botón izquierdo selecciona este peón; el botón derecho selecciona los 8 peones.}
translate S TrackerStat {Estadística}
translate S TrackerGames {% de partidas con movimiento a esta casilla}
translate S TrackerTime {% de tiempo en esta casilla}
translate S TrackerMoves {Movimientos}
translate S TrackerMovesStart {Escribe el número del movimiento desde donde debe empezar el rastreo.}
translate S TrackerMovesStop {Escribe el número del movimiento donde debe parar el rastreo.}

# Game selection dialogs:
translate S SelectAllGames {Todas las partidas de la base de datos}
translate S SelectFilterGames {Sólo las partidas filtradas}
translate S SelectTournamentGames {Sólo las partidas del actual torneo}
translate S SelectOlderGames {Sólo partidas antiguas}

# Delete Twins window:
translate S TwinsNote {Para ser dobles, dos partidas deben de tener al menos los mismos dos jugadores, y los criterios que fijes debajo. Cuando un par de dobles es encontrado, la partida más corta es borrada. Sugerencia: es mejor hacer la corrección ortográfica de la base de datos antes de iniciar el borrado de dobles, porque esto mejora su detección.}
translate S TwinsCriteria {Criterios: Las partidas dobles deben tener...}
translate S TwinsWhich {Partidas a examinar}
translate S TwinsColors {¿Jugadores con igual color?}
translate S TwinsEvent {¿Mismo evento?}
translate S TwinsSite {¿Mismo sitio?}
translate S TwinsRound {¿Misma ronda?}
translate S TwinsYear {¿Mismo año?}
translate S TwinsMonth {¿Mismo mes?}
translate S TwinsDay {¿Mismo día?}
translate S TwinsResult {¿Mismo resultado?}
translate S TwinsECO {¿Mismo código ECO?}
translate S TwinsMoves {¿Mismos movimientos?}
translate S TwinsPlayers {Comparando nombres de jugadores:}
translate S TwinsPlayersExact {Encuentro exacto}
translate S TwinsPlayersPrefix {Sólo las primeras 4 letras}
translate S TwinsWhen {Cuando se borren partidas dobles}
translate S TwinsSkipShort {¿Ignorar todas las partidas con menos de 5 movimientos?}
translate S TwinsUndelete {¿Quitar marcas de borrado primero?}
translate S TwinsSetFilter {¿Poner filtro a todas las partidas borradas?}
translate S TwinsComments {¿Saltar siempre partidas con comentarios?}
translate S TwinsVars {¿Saltar siempre partidas con variaciones?}
translate S TwinsDeleteWhich {Qué partida borrar:}
translate S TwinsDeleteShorter {Partida más corta}
translate S TwinsDeleteOlder {Número de partida menor}
translate S TwinsDeleteNewer {Número de partida mayor}
translate S TwinsDelete {Borrar partidas}

# Name editor window:
translate S NameEditType {Tipo de dato a editar}
translate S NameEditSelect {Partidas a editar}
translate S NameEditReplace {Reemplazar}
translate S NameEditWith {con}
translate S NameEditMatches {Encuentros: Presionar Ctrl+1 a Ctrl+9 para seleccionarlo}

# Classify window:
translate S Classify {Clasificar}
translate S ClassifyWhich {Clasificar por códigos ECO}
translate S ClassifyAll {Todas las partidas (sobreescribir código ECO)}
translate S ClassifyYear {Todas las partidas jugadas en el último año}
translate S ClassifyMonth {Todas las partidas jugadas en el último mes}
translate S ClassifyNew {Sólo las partidas todabía sin código ECO}
translate S ClassifyCodes {Código ECO a usar}
translate S ClassifyBasic {Sólo código básico ("B12", ...)}
translate S ClassifyExtended {Extensiones Scid ("B12j", ...)}

# Compaction:
translate S NameFile {Archivo de nombres}
translate S GameFile {Archivo de partidas}
translate S Names {Nombres}
translate S Unused {No usado}
translate S SizeKb {Tamaño (kb)}
translate S CurrentState {Estado actual}
translate S AfterCompaction {Después de la compactación}
translate S CompactNames {Compactar archivo de nombres}
translate S CompactGames {Compactar archivo de partidas}
translate S NoUnusedNames "No hay nombres sin usar, por tanto el nombre del fichero está ya totalmente compactado."
translate S NoUnusedGames "El fichero ya está totalmente compactado."
translate S NameFileCompacted {El fichero de nombre para la base de datos "[file tail [sc_base filename]]" fue compactado.}
translate S GameFileCompacted {El fichero de partidas para la base de datos "[file tail [sc_base filename]]" fue compactado.}

# Sorting:
translate S SortCriteria {Criterio}
translate S AddCriteria {Añadir criterio}
translate S CommonSorts {Ordenaciones comunes}
translate S Sort {Ordenar}

# Exporting:
translate S AddToExistingFile {¿Añadir partidas a un archivo existente?}
translate S ExportComments {¿Exportar comentarios?}
translate S ExportVariations {¿Exportar variaciones?}
translate S IndentComments {¿Sangrar comentarios?}
translate S IndentVariations {¿Sangrar variaciones?}
translate S ExportColumnStyle {¿Estilo de columna (un movimiento por línea)?}
translate S ExportSymbolStyle {Estilo de anotación simbólico:}
translate S ExportStripMarks {¿Quitar marca de códigos de casilla/flecha de los comentarios?}

# Goto game/move dialogs:
translate S LoadGameNumber {Entra el número de la partida a cargar:}
translate S GotoMoveNumber {Ir al movimiento número:}

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
translate S CopyErrReadOnly {es sólo de lectura}
translate S CopyErrNotOpen {no está abierta}

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
translate S FindNovelty {Encontrar Novedad}
translate S Novelty {Novedad}
translate S NoveltyInterrupt {Busqueda de novedades interrumpida}
translate S NoveltyNone {Ninguna novedad encontrada para esta partida}
translate S NoveltyHelp {
Scid encontrará el primer movimiento de la actual partida que alcanza una posición no encontrada en la base de datos seleccionada o en el libro de aperturas ECO.
}

# Sounds configuration:
translate S SoundsFolder {Directorio de los archivos de sonido}
translate S SoundsFolderHelp {El directorio debe contener los archivos King.wav, a.wav, 1.wav, etc}
translate S SoundsAnnounceOptions {Opciones de anunciamiento de movimientos}
translate S SoundsAnnounceNew {Anunciar nuevos movimientos cuando sean hechos}
translate S SoundsAnnounceForward {Anunciar movimientos cuando avancemos un movimiento}
translate S SoundsAnnounceBack {Anunciar movimiento cuando rectifiquemos o retrocedamos una jugada}

# Upgrading databases:
translate S Upgrading {Actualización}
translate S ConfirmOpenNew {
Este es un formato de base de datos antiguo (Scid 3) que no puede ser abierto con Scid 4, pero ya se ha creado una versión de formato nuevo (Scid 4).

¿Quieres abrir la versión de formato nuevo de la base de datos?
}
translate S ConfirmUpgrade {
Esta es una base de datos en un formato antiguo (Scid 3). Se debe crear una versión de formato nuevo de base de datos antes de poder ser usada en Scid 4.

La actualización creará una nueva versión de la base de datos.

Esto puede tomar un tiempo, pero sólo es necesario hacerlo una vez. Puedes cancelar si toma demasiado tiempo.

¿Quieres actualizar esta base de datos ahora?
}

# Recent files options:
translate S RecentFilesMenu {Número de archivos recientes en el menú Archivo}
translate S RecentFilesExtra {Número de archivos recientes en submenú extra}

# My Player Names options:
translate S MyPlayerNamesDescription {
Escriba una lista de nombres de jugadores preferidos, un nombre por cada línea. Están permitidos los comodines (por ejemplo "?" para un sólo caracter, "*" para varios caracteres).

Cada vez que carge una partida con un jugador de la lista se girará el tablero, si fuese necesario, para ver la partida desde la perspectiva del jugador.
}
translate S showblunderexists {Mostrar metedura de pata}
translate S showblundervalue {Mostrar valor de la metedura de pata}
translate S showscore {Mostrar marcador}
translate S coachgame {Entrenador}
translate S configurecoachgame {Configurar entrenador}
translate S configuregame {Configuración de partida}
translate S Phalanxengine {Motor Phalanx}
translate S Coachengine {Motor entrenador}
translate S difficulty {Dificultad}
translate S hard {Duro}
translate S easy {Fácil}
translate S Playwith {Juega con}
translate S white {blancas}
translate S black {negras}
translate S both {ambos}
translate S Play {Jugar}
translate S Noblunder {Sin errores}
translate S blunder {Meteduras de pata}
translate S Noinfo {-- Sin información --}
translate S PhalanxOrTogaMissing {Phalanx o Toga no encontrado}
translate S moveblunderthreshold {El movimiento es una metedura de pata si la pérdida de puntuación es mayor que }
translate S limitanalysis {Tiempo límite para análisis del motor}
translate S seconds {segundos}
translate S Abort {Abortar}
translate S Resume {Reanudar}
translate S OutOfOpening {Fuera de apertura}
translate S NotFollowedLine {Tú no sigues la linea}
translate S DoYouWantContinue {¿Quieres continuar?}
translate S CoachIsWatching {Entrenador}
translate S Ponder {Pensar siempre (el motor)}
translate S LimitELO {Limitar fuerza ELO}
translate S DubiousMovePlayedTakeBack {Movimiento dudoso, ¿quieres rectificar?}
translate S WeakMovePlayedTakeBack {Movimiento flojo, ¿quieres rectificar ?}
translate S BadMovePlayedTakeBack {Movimiento malo, ¿quieres rectificar ?}
translate S Iresign {Yo abandono}
translate S yourmoveisnotgood {tu movimiento no es bueno}
translate S EndOfVar {Fin de la variante}
translate S Openingtrainer {Entrenador de aperturas}
translate S DisplayCM {Muestra posibles movimientos}
translate S DisplayCMValue {Muestra valor de posibles movimientos}
translate S DisplayOpeningStats {Muestra estadísticas}
translate S ShowReport {Muestra informe}
translate S NumberOfGoodMovesPlayed {buenos movimientos jugados}
translate S NumberOfDubiousMovesPlayed {dudosos momientos jugados}
translate S NumberOfMovesPlayedNotInRepertoire {movimientos jugados fuera de repertorio}
translate S NumberOfTimesPositionEncountered {veces encontrada la posición}
translate S PlayerBestMove  {Permite únicamente movimientos mejores}
translate S OpponentBestMove {Oponente juega mejores movimientos}
translate S OnlyFlaggedLines {Sólo lineas marcadas}
translate S resetStats {Reinicia estadísticas}
translate S Repertoiretrainingconfiguration {Configuración del repertorio de entrenamiento}
translate S Loadingrepertoire {Cargando repertorio}
translate S Movesloaded {Movimientos cargados}
translate S Repertoirenotfound {Repertorio no encontrado}
translate S Openfirstrepertoirewithtype {Abrir primero una base con icono/tipo de repertorio colocado en el lado derecho}
translate S Movenotinrepertoire {Movimiento no está en el repertorio}
translate S PositionsInRepertoire {Posiciones en repertorio}
translate S PositionsNotPlayed {Posiciones no jugadas}
translate S PositionsPlayed {Posiciones jugadas}
translate S Success {Éxitos}
translate S DubiousMoves {Movimientos dudosos}
translate S OutOfRepertoire {Fuera de repertorio}
translate S ConfigureTactics {Configurar táctica}
translate S ResetScores {Reiniciar marcadores (puntuaciones)}
translate S LoadingBase {Cargando base}
translate S Tactics {Tácticas}
translate S ShowSolution {Mostrar solución}
translate S Next {Siguiente}
translate S ResettingScore {Reiniciando marcador}
translate S LoadingGame {Cargando partida}
translate S MateFound {Mate encontrado}
translate S BestSolutionNotFound {¡NO fue encontrada la mejor solución!}
translate S MateNotFound {Mate no encontrado}
translate S ShorterMateExists {Esiste un mate más corto}
translate S ScorePlayed {Marcador jugado}
translate S Expected {Esperado}
translate S ChooseTrainingBase {Elegir base de entrenamiento}
translate S Thinking {Pensando}
translate S AnalyzeDone {Análisis hecho}
translate S WinWonGame {Gana la partida ganada}
translate S Lines {Lineas}
translate S ConfigureUCIengine {Configurar motor UCI}
translate S SpecificOpening {Apertura específica}
translate S StartNewGame {Empezar partida nueva}
translate S FixedLevel {Nivel fijado}
translate S Opening {Abriendo}
translate S RandomLevel {Nivel aleatorio}
translate S StartFromCurrentPosition {Empezar desde la posición actual}
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
translate S AllExercisesDone {Todos los ejercicio hechos}
translate S MoveOutOfBook {Movimiento fuera del libro}
translate S LastBookMove {Último movimiento del libro}
translate S AnnotateSeveralGames {Anotar las partidas\ndesde la actual hasta la partida: }
translate S FindOpeningErrors {Encontrar errores en los primeros }
translate S MarkTacticalExercises {Marca ejercicios tácticos}
translate S UseBook {Usar libro de aperturas (Book)}
translate S MultiPV {Variantes múltiples}
translate S Hash {Memoria Hash}
translate S OwnBook {Usar libro (book) del motor}
translate S BookFile {Libro de aperturas}
translate S AnnotateVariations {Anotar variantes}
translate S ShortAnnotations {Anotaciones cortas}
translate S addAnnotatorTag {Añadir etiqueta de anotador}
translate S AddScoreToShortAnnotations {Añadir puntuación para anotaciones cortas}
translate S Export {Exportar}
translate S BookPartiallyLoaded {Libro parcialmente cargado}
translate S Calvar {Cálculo de variantes}
translate S ConfigureCalvar {Configuración}
translate S Reti {Apertura Reti}
translate S English {Apertura inglesa}
translate S d4Nf6Miscellaneous {1.d4 Cf6 variadas}
translate S Trompowsky {Apertura Trompowsky}
translate S Budapest {Gambito Budapest}
translate S OldIndian {Defensa India Antigua}
translate S BenkoGambit {Gambito Benko}
translate S ModernBenoni {Defensa Benoni Moderna}
translate S DutchDefence {Defensa Holandesa}
translate S Scandinavian {Defensa Escandinava}
translate S AlekhineDefence {Defensa Alekhine}
translate S Pirc {Defensa Pirc}
translate S CaroKann {Defensa Caro-Kann}
translate S CaroKannAdvance {Defensa Caro-Kann, Variante del Avance}
translate S Sicilian {Defensa Siciliana}
translate S SicilianAlapin {Defensa Siciliana, Variante Alapin}
translate S SicilianClosed {Defensa Siciliana, Variante Cerrada}
translate S SicilianRauzer {Defensa Siciliana, Variante Rauzer}
translate S SicilianDragon {Defensa Siciliana, Variante del Dragon}
translate S SicilianScheveningen {Defensa Siciliana, Variante Scheveningen}
translate S SicilianNajdorf {Defensa Siciliana, Variante Najdorf}
translate S OpenGame {Apertura Abierta}
translate S Vienna {Apertura Vienesa}
translate S KingsGambit {Gambito de Rey}
translate S RussianGame {Partida Rusa}
translate S ItalianTwoKnights {Apertura Italiana, Variante de los Dos Caballos}
translate S Spanish {Apertura Española}
translate S SpanishExchange {Apertura Española, Variante del cambio}
translate S SpanishOpen {Apertura Española}
translate S SpanishClosed {Apertura Española, Variante Cerrada}
translate S FrenchDefence {Defensa Francesa}
translate S FrenchAdvance {Defensa Francesa, Variante del Avance}
translate S FrenchTarrasch {Defensa Francesa, Variante Tarrasch}
translate S FrenchWinawer {Defensa Francesa, Variante Winawer}
translate S FrenchExchange {Defensa Francesa, Variante del cambio}
translate S QueensPawn {Apertura de Peón de Dama}
translate S Slav {Defensa Eslava}
translate S QGA {Gambito de Dama Aceptado}
translate S QGD {Gambito de Dama Declinado}
translate S QGDExchange {Gambito de Dama Declinado, Variante del Cambio}
translate S SemiSlav {Defensa Semi-Eslava del Gambito de Dama Declinado}
translate S QGDwithBg5 {Gambito de Dama Declinado con Ag5}
translate S QGDOrthodox {Gambido de Dama Declinado,  Defensa Ortodoxa}
translate S Grunfeld {Defensa Grünfeld}
translate S GrunfeldExchange {Variante del cambio de la Defensa Grünfeld }
translate S GrunfeldRussian {Variante Rusa de la Defensa Grünfeld}
translate S Catalan {Catalana}
translate S CatalanOpen {Apertura Catalana}
translate S CatalanClosed {Apertura Catalana, Variante Cerrada}
translate S QueensIndian {Defensa India de Dama}
translate S NimzoIndian {Apertura Nimzo-India}
translate S NimzoIndianClassical {Apertura Nimzo-India Clásica}
translate S NimzoIndianRubinstein {Variante Rubinstein de la Nimzo-India}
translate S KingsIndian {India de Rey}
translate S KingsIndianSamisch {Ataque Sämish de la India de Rey}
translate S KingsIndianMainLine {Linea Principal India de Rey}
translate S ConfigureFics {Configurar FICS}
translate S FICSGuest {Autentificación como invitado}
translate S FICSServerPort {Puerto del servidor}
# ====== TODO To be translated ======
translate S FICSServerAddress {IP Address}
# ====== TODO To be translated ======
translate S FICSRefresh {Refresh}
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
translate S FICSAutoColour {automático}
translate S FICSManualConfirm {confirma manualmente}
translate S FICSFilterFormula {Filtrar con fórmula}
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
translate S GameReview {Game review}
translate S GameReviewTimeExtended {Tiempo extendido}
translate S GameReviewMargin {Margen de error}
translate S GameReviewAutoContinue {Auto-continuar cuando el movimiento es correcto}
translate S GameReviewReCalculate {Usar tiempo extendido}
translate S GameReviewAnalyzingMovePlayedDuringTheGame {Analizando movimiento jugado durante la partida}
translate S GameReviewAnalyzingThePosition {Analizando la posición}
translate S GameReviewEnterYourMove {Introduce tu movimiento}
translate S GameReviewCheckingYourMove {Chequeando tu movimiento}
translate S GameReviewYourMoveWasAnalyzed {Tu movimiento fue analizado}
translate S GameReviewYouPlayedSameMove {Jugaste el mismo momiento que en la partida}
translate S GameReviewScoreOfYourMove {Puntuación de tu movimiento}
translate S GameReviewGameMoveScore {Puntuación del movimiento de la partida}
translate S GameReviewEngineScore {Puntuación del motor}
translate S GameReviewYouPlayedLikeTheEngine {Tu jugaste como el motor}
translate S GameReviewNotEngineMoveButGoodMove {No es el movimiento del motor, pero es también un buen movimiento}
translate S GameReviewMoveNotGood {Este movimiento no es bueno, la puntuación es }
translate S GameReviewMovesPlayedLike {Movimientos jugados como}
translate S GameReviewMovesPlayedEngine {Movimientos jugados como motor}
translate S CCDlgConfigureWindowTitle {Configurar Ajedrez por Correo}
translate S CCDlgCGeneraloptions {Opciones Generales}
translate S CCDlgDefaultDB {Base por defecto:}
translate S CCDlgInbox {Entrante (Carpeta):}
translate S CCDlgOutbox {Saliente (carpeta):}
translate S CCDlgXfcc {Configuración Xfcc:}
translate S CCDlgExternalProtocol {Protocolo Externo de Manipulación (e.g. Xfcc)}
translate S CCDlgFetchTool {Herramienta de traer:}
translate S CCDlgSendTool {Herramienta de envio:}
translate S CCDlgEmailCommunication {Comunicación eMail}
translate S CCDlgMailPrg {Programa de correo:}
translate S CCDlgBCCAddr {(B)CC Dirección:}
translate S CCDlgMailerMode {Modo:}
translate S CCDlgThunderbirdEg {p.e. Thunderbird, Mozilla Mail, Icedove...}
translate S CCDlgMailUrlEg {p.e. Evolution}
translate S CCDlgClawsEg {p.e. Sylpheed Claws}
translate S CCDlgmailxEg {p.e. mailx, mutt, nail...}
translate S CCDlgAttachementPar {Parámetro Adhesión (Attachment):}
translate S CCDlgInternalXfcc {Usar soporte interno Xfcc}
translate S CCDlgConfirmXfcc {Confirmar jugadas}
translate S CCDlgSubjectPar {Parámetro Sujeto (Subject):}
translate S CCDlgDeleteBoxes {Vaciar Entrante/Saliente}
translate S CCDlgDeleteBoxesText {¿Quieres realmente vaciar tus carpetas Entrante y Saliente para Ajedrez por correspondencia? Esto requiere una nueva sincronización para mostrar el estado último de tus partidas}
translate S CCDlgConfirmMove {Confirmar jugada}
translate S CCDlgConfirmMoveText {Si tu confirmas, la siguiente jugada y comentario será enviado al servidor:}
translate S CCDlgDBGameToLong {Linea principal Inconsistente}
translate S CCDlgDBGameToLongError {La linea principal en tu base es más larga que de la partida en la bandeja de entrada. Si la bandeja de entrada contiene la partida actual, algunos movimientos fueron añadidos a la linea principal en la base erróneamente.\nEn este caso acorte la linea principal a la (max) jugada\n}
translate S CCDlgStartEmail {Empezar nueva partida eMail}
translate S CCDlgYourName {Tu nombre:}
translate S CCDlgYourMail {Tu dirección eMail:}
translate S CCDlgOpponentName {Nombre de Oponente:}
translate S CCDlgOpponentMail {Dirección eMail de Oponente:}
translate S CCDlgGameID {Partida ID (único):}
translate S CCDlgTitNoOutbox {Scid: Salida del Correo de Ajedrez}
translate S CCDlgTitNoInbox {Scid: Entrada del Correo de Ajedrez}
translate S CCDlgTitNoGames {Scid: No hay Partidas de Ajedrez por Correo}
translate S CCErrInboxDir {Carpeta de entrada del Correo de Ajedrez (Entrante):}
translate S CCErrOutboxDir {Carpeta de salida del Correo de Ajedrez (Saliente):}
translate S CCErrDirNotUsable {¡No existe o no está accesible!\nPor favor, chequee y corrigja los parámetros.}
translate S CCErrNoGames {¡No contiene ninguna partida!\nPor favor, traigala primero.}
translate S CCDlgTitNoCCDB {Scid: No es una Base de Ajedrez por Correo}
translate S CCErrNoCCDB {No hay una Base del tipo 'Correo' abierta. Por favor, abra una antes de usar funciones de ajedrez por Correo.}
translate S CCFetchBtn {Traer partidas desde el servidor y procesar correo entrante}
translate S CCPrevBtn {Ir a partida anterior}
translate S CCNextBtn {Ir a partida siguiente}
translate S CCSendBtn {Enviar movimiento}
translate S CCEmptyBtn {Correos entrante y saliente vacios}
translate S CCHelpBtn {Ayuda en iconos e indicadores de estatus. \n Para ayuda general pulse F1!}
translate S CCDlgServerName {Nombre del servidos:}
translate S CCDlgLoginName  {Nombre de registro:}
translate S CCDlgPassword   {Contraseña:}
translate S CCDlgURL        {Xfcc-URL:}
translate S CCDlgRatingType {Tipo de puntuación (Rating):}
translate S CCDlgDuplicateGame {El ID de la partida no es único}
translate S CCDlgDuplicateGameError {Esta partida existe más de una vez en tu base. Por favor, borra todos los duplicados y compacta tu fichero de partidas (Fichero/Mantenimiento/Compactar base de datos).}
translate S CCDlgSortOption {Ordenando:}
translate S CCDlgListOnlyOwnMove {Solo partidas que tienen el movimiento}
translate S CCOrderClassicTxt {Lugar, Evento, Ronda, Resultado, Blancas, Negras}
translate S CCOrderMyTimeTxt {Mi reloj}
translate S CCOrderTimePerMoveTxt {Tiempo por movimiento falta el próximo control de tiempo}
translate S CCOrderStartDate {Empezar fecha}
translate S CCOrderOppTimeTxt {Relo0j de los oponentesOpponents}
translate S ExtHWConfigConnection {Configurar hardware externo}
translate S ExtHWPort {Puerto}
translate S ExtHWEngineCmd {Comando del motor}
translate S ExtHWEngineParam {Parámetro del motor}
translate S ExtHWShowButton {Mostrar botón}
translate S ExtHWHardware {Hardware}
translate S ExtHWNovag {Novag Citrine}
translate S ExtHWInputEngine {Motor de entrada (Input Engine)}
translate S ExtHWNoBoard {Sin tablero}
translate S NovagReferee {Árbitro}
translate S IEConsole {Consola de entrada del motor}
translate S IESending {Movimientos enviados por}
translate S IESynchronise {Sincronizar}
translate S IERotate  {Rotar}
translate S IEUnableToStart {Imposible empezar con el motor de entrada:}
translate S DoneWithPosition {Hecho con la posición}
translate S Board {Tablero}
translate S showGameInfo {Mostrar información de la partida}
translate S autoResizeBoard {Tamaño automático del tablero}
translate S DockTop {Mover arriba}
translate S DockBottom {Mover abajo}
translate S DockLeft {Mover a la izquierda}
translate S DockRight {Mover a la derecha}
translate S Undock {Ventana flotante}
translate S ChangeIcon {Cambiar icono...}

}
# end of spanish.tcl






























































