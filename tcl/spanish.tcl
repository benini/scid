# spanish.tcl:
# Spanish translations for Scid.
# Contributed by Jordi González Boada.

addLanguage S Espanol 1

proc setLanguage_S {} {

# File menu:
menuText S File "Archivo" 0
menuText S FileNew "Nuevo..." 0 {Crea una nueva base de datos Scid vacía}
menuText S FileOpen "Abrir..." 1 {Abre una base de datos Scid ya existente}
menuText S FileClose "Cerrar" 0 {Cierra la base de datos Scid activa}
menuText S FileFinder "Visor..." 0 {Abre la ventana del visor de Archivos}
menuText S FileBookmarks "Bookmarks" 0 {Bookmarks menu (shortcut: Ctrl+B)}
menuText S FileBookmarksAdd "Añadir marcador" 0 \
  {Señala la partida y posición actual de la base de datos}
menuText S FileBookmarksFile "Archivar marcador" 8 \
  {Archiva un marcador para la partida y posición actual}
menuText S FileBookmarksEdit "Editar marcadores..." 0 \
  {Edita los menus de los marcadores}
menuText S FileBookmarksList "Mostrar las corpetas en una sola lista" 0 \
  {Muestrar las corpetas de marcadores en una sola lista, sin submenus}
menuText S FileBookmarksSub "Mostrar carpetas como submenus" 0 \
  {Muestrar las corpetas de marcadores como submenus, no una sola lista}
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
menuText S FileExit "Salir" 0 {Salir de Scid}

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
menuText S EditStripComments "Comentarios" 0 \
  {Strip all comments and annotations from this game}
menuText S EditStripVars "Variaciones" 0 {Strip all variations from this game}
menuText S EditReset "Poner a cero la base de trabajo" 0 \
  {Pone a cero la base de trabajo (clipbase) para que esté completamente vacía}
menuText S EditCopy "Copiar esta partida a la base de trabajo" 1 \
  {Copia esta partida a la base de trabajo (clipbase)}
menuText S EditPaste "Pegar la última partida de la base de trabajo" 2 \
  {Pega la partida activa en la base de trabajo (clipbase) aquí}
menuText S EditSetup "Iniciar tablero de posición..." 26 \
  {Inicia el tablero de posición con la posición de la partida}
menuText S EditPasteBoard "Pegar tablero inicial" 6 \
  {Coloca el tablero inicial de la selección de texto actual (clipboard)}

# Game menu:
menuText S Game "Partida" 0
menuText S GameNew "Limpiar partida" 0 \
  {Vuelve a una partida limpia, descartando cualquier cambio}
menuText S GameFirst "Cargar primera partida" 7 {Carga la primera partida filtrada}
menuText S GamePrev "Cargar partida anterior" 16 {Carga la anterior partida filtrada}
menuText S GameReload "Recargar partida actual" 0 \
  {Vuelve a cargar esta partida, descartando cualquier cambio hecho}
menuText S GameNext "Cargar siguiente partida" 7 {Carga la siguiente partida filtrada}
menuText S GameLast "Cargar última partida" 9 {Carga la última partida filtrada}
menuText S GameRandom "Load Random Game" 8 {Load a random filtered game} ;# ***
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
menuText S WindowsTree "Ventana de árbol" 6 {Abre/cierra la ventana de árbol}
menuText S WindowsTB "Ventana de TBs" 8 \
  {Abre/cierra la ventana de TBs}

# Tools menu:
menuText S Tools "Herramientas" 0
menuText S ToolsAnalysis "Motor de análisis..." 0 \
  {Inicia/para el análisis de un motor de ajedrez}
menuText S ToolsAnalysis2 "Motor de análisis #2..." 18 \
  {Inicia/para el análisis de un motor de ajedrez}
menuText S ToolsCross "Tabla cruzada" 0 {Muestra la tabla cruzada para esta partida}
menuText S ToolsEmail "Administrador de Email" 0 \
  {Abre/cierra la ventana del administrador de Email}
menuText S ToolsFilterGraph "Filter graph" 7 \
  {Open/close the filter graph window} ;# ***
menuText S ToolsOpReport "Informe de la apertura" 1 \
  {Crea un informe de la apertura para la posición actual}
menuText S ToolsTracker "Piece Tracker"  0 {Open the Piece Tracker window} ;# ***
menuText S ToolsPInfo "Información del Jugador" 16 \
  {Abrir/actualizar la ventana de Información del Jugador}
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
menuText S ToolsExpCurrentLaTeX "Exportar la partida a un archivo LaTeX..." 33 \
  {Escribe la partida actual en un archivo LaTeX}
menuText S ToolsExpFilter "Exportar todas las partidas filtradas" 1 \
  {Escribe todas las partidas filtradas en un archivo de texto}
menuText S ToolsExpFilterPGN "Exportar filtro a un archivo PGN..." 29 \
  {Escribe todas las partidas filtradas en un archivo PGN}
menuText S ToolsExpFilterHTML "Exportar filtro a un archivo HTML..." 29 \
  {Escribe todas las partidas filtradas en un archivo HTML}
menuText S ToolsExpFilterLaTeX "Exportar filtro a un archivo LaTeX..." 29 \
  {Escribe todas las partidas filtradas en un archivo LaTeX}
menuText S ToolsImportOne "Importar una partida PGN..." 0 \
  {Importa una partida de un texto PGN}
menuText S ToolsImportFile "Importar un archivo de partidas PGN..." 2 \
  {Importa partidas de un archivo PGN}

# Options menu:
menuText S Options "Opciones" 0
menuText S OptionsSize "Tamaño del tablero" 0 {Cambia el tamaño del tablero}
menuText S OptionsPieces "Board Piece Style" 6 \
  {Change the board piece style} ;# ***
menuText S OptionsColors "Colores..." 0 {Cambia los colores del tablero}
menuText S OptionsExport "Exportación" 0 {Cambia las opciones de exportación de texto}
menuText S OptionsFonts "Fuentes" 0 {Cambia las fuentes}
menuText S OptionsFontsRegular "Habitual" 0 {Cambia la fuente habitual}
menuText S OptionsFontsSmall "Pequeña" 0 {Cambia la fuente pequeña}
menuText S OptionsFontsFixed "Fijada" 0 {Cambia la anchura fijada de la fuente}
menuText S OptionsGInfo "Información de la partida" 0 {Información de la partida}
menuText S OptionsLanguage "Lenguaje" 0 {Selecciona el lenguaje del menú}
menuText S OptionsMoves "Movimientos" 0 {Opciones de la entrada de movimientos}
menuText S OptionsMovesAsk "Preguntar antes de reemplazar movimientos" 0 \
  {Pregunta antes de sobreescribir cualquier movimiento existente}
menuText S OptionsMovesDelay "Demora del automovimiento..." 0 \
  {Pone el tiempo de demora para el modo de automovimiento}
menuText S OptionsMovesCoord "Entrada de movimientos coordinada" 0 \
  {Acepta entrada de movimientos en sistema "coordinado" ("g1f3")}
menuText S OptionsMovesSuggest "Mostrar movimientos sugeridos" 20 \
  {Activa/desactiva la sugerencia de movimientos}
menuText S OptionsMovesKey "Teclado Inteligente" 0 \
{Activa/desactiva la función de autocompletado inteligente de movimientos
con teclado}
menuText S OptionsNumbers "Formato de números" 11 {Selecciona el formato de números}
menuText S OptionsStartup "Inicio" 3 {Seleccionar ventanas a abrir al inicio}
menuText S OptionsWindows "Ventanas" 0 {Opciones de ventana}
menuText S OptionsWindowsIconify "Auto-iconify" 5 \
  {Iconify all windows when the main window is iconified} ;# ***
menuText S OptionsWindowsRaise "Poner a la vista automáticamente" 0 \
  {Hace visibles ciertas ventanas (ej. barras de progreso) siempre que sean tapadas}
menuText S OptionsToolbar "Barra de herramientas ventana principal" 9 \
  {Muestra/oculta la barra de herramientas de la ventana principal}
menuText S OptionsECO "Cargar archivo ECO..." 7 \
  {Cargar el archivo de clasificación ECO}
menuText S OptionsSpell "Cargar archivo de comprobación ortográfica..." 2 \
  {Carga el archivo de comprobación ortográfica Scid}
menuText S OptionsTable "Directorio de las TB..." 19 \
  {Selecciona el directorio de finales; todas las TB de ese directorio serán usadas}
menuText S OptionsSave "Guardar opciones" 0 \
  "Guarda todas las opciones en el fichero $::optionsFile"
menuText S OptionsAutoSave "Autoguardar opciones al salir" 0 \
  {Guarda automáticamente todas las opciones cuando se sale de Scid}

# Help menu:
menuText S Help "Ayuda" 1
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
menuText S GInfoMarks "Show colored squares and arrows" 5 ;# ***
menuText S GInfoWrap "Dividir líneas largas" 0
menuText S GInfoFullComment "Mostrar comentarios completos" 8
menuText S GInfoTBNothing "TBs: nada" 5
menuText S GInfoTBResult  "TBs: sólo resultado" 10
menuText S GInfoTBAll "TBs: resultado y mejor movimiento" 23
menuText S GInfoDelete "(No)Borrar esta partida" 4
menuText S GInfoMark "(No)Marcar esta partida" 4

# Main window buttons:
helpMsg S .button.start {Ir al principio de la partida  (Tecla: Inicio)}
helpMsg S .button.end {Ir al final de la partida  (Tecla: Fin)}
helpMsg S .button.back {Ir atrás un movimiento  (Tecla: Flecha izquierda)}
helpMsg S .button.forward {Ir adelante un movimiento  (Tecla: Flecha derecha)}
helpMsg S .button.intoVar {Moverse dentro de una variación  (Tecla rápida: v)}
helpMsg S .button.exitVar {Dejar la variación actual  (Tecla rápida: z)}
helpMsg S .button.flip {Girar tablero  (Tecla rápida: .)}
helpMsg S .button.coords {Poner/quitar las coordenadas del tablero  (Tecla rápida: 0)}
helpMsg S .button.autoplay {Automovimiento de los movimientos  (Tecla: Ctrl+Z)}

# General buttons:
translate S Back {Atrás}
translate S Cancel {Cancelar}
translate S Clear {Limpiar}
translate S Close {Cerrar}
translate S Defaults {Por defecto}
translate S Delete {Borrar}
translate S Graph {Gráfico}
translate S Help {Ayuda}
translate S Import {Importar}
translate S Index {Índice}
translate S LoadGame {Cargar partida}
translate S BrowseGame {Browse game} ;# ***
translate S MergeGame {Merge game} ;# ***
translate S Preview {Preview} ;# ***
translate S Revert {Retroceder}
translate S Save {Guardar}
translate S Search {Buscar}
translate S Stop {Parar}
translate S Store {Almacenar}
translate S Update {Actualizar}
translate S ChangeOrient {Cambiar orientación de la ventana}
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
translate S White {Blanco}
translate S Black {Negro}
translate S Player {Jugador}
translate S Rating {Elo}
translate S RatingDiff {Diferencia de Elo (Blanco - Negro)}
translate S Event {Evento}
translate S Site {Lugar}
translate S Country {País}
translate S IgnoreColors {Ignorar colores}
translate S Date {Fecha}
translate S EventDate {Evento fecha}
translate S Decade {Decade} ;# ***
translate S Year {Año}
translate S Month {Mes}
translate S Months {enero febrero marzo abril mayo junio
  julio agosto septiembre octubre noviembre diciembre}
translate S Days {dom lun mar mié jue vie sáb}
translate S YearToToday {Último año hasta hoy}
translate S Result {Resultado}
translate S Round {Ronda}
translate S Length {Longitud}
translate S ECOCode {Código ECO}
translate S ECO {ECO}
translate S Deleted {Borrado}
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
translate S PInfoAgainst {Results against} ;# ***
translate S PInfoMostWhite {Aperturas más comunes con Blancas}
translate S PInfoMostBlack {Aperturas más comunes con Negras}
translate S PInfoRating {Historial de clasificación}
translate S PInfoBio {Biografía}

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

# Tip of the day:
translate S Tip {Sugerencia}
translate S TipAtStartup {Sugerencia al iniciar}

# Tree window menus: ***
menuText S TreeFile "Archivo" 0
menuText S TreeFileSave "Guardar archivo caché" 0 \
  {Guarda el archivo caché del árbol (.stc)}
menuText S TreeFileFill "Construir archivo caché" 2 \
  {Fill the cache file with common opening positions}
menuText S TreeFileBest "Best games list" 0 {Show the best tree games list}
menuText S TreeFileGraph "Ventana del gráfico" 0 \
  {Show the graph for this tree branch}
menuText S TreeFileCopy "Copiar texto del árbol al clipboard" 1 \
  {Copiar texto del árbol al clipboard}
menuText S TreeFileClose "Cerrar ventana del árbol" 0 \
  {Cerrar ventana del árbol}
menuText S TreeSort "Ordenar" 0
menuText S TreeSortAlpha "Alfabéticamente" 0
menuText S TreeSortECO "Por código ECO" 11
menuText S TreeSortFreq "Por frecuencia" 4
menuText S TreeSortScore "Por puntuación" 4
menuText S TreeOpt "Opciones" 1
menuText S TreeOptLock "Lock" 0 {Lock/unlock the tree to the current database}
menuText S TreeOptTraining "Training" 0 {Turn on/off tree training mode}
menuText S TreeOptAutosave "Autoguardar archivo caché" 0 \
  {Auto-save the cache file when closing the tree window}
menuText S TreeHelp "Ayuda" 1
menuText S TreeHelpTree "Ayuda del árbol" 4
menuText S TreeHelpIndex "Indice de la ayuda" 0
translate S SaveCache {Guardar caché}
translate S Training {Entrenamiento}
translate S LockTree {Bloquear}
translate S TreeLocked {locked}
translate S TreeBest {Best}
translate S TreeBestGames {Best tree games}

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
menuText S GraphOptionsWhite "Blanco" 0
menuText S GraphOptionsBlack "Negro" 0
menuText S GraphOptionsBoth "Ambos" 0
menuText S GraphOptionsPInfo "Jugador Información jugador" 0
translate S GraphFilterTitle "Filter graph: frequency per 1000 games" ;# ***

# Analysis window:
translate S AddVariation {Añadir variación}
translate S AddMove {Añadir movimiento}
translate S Annotate {Anotar}
translate S AnalysisCommand {Dirección de análisis}
translate S PreviousChoices {Elección previa}
translate S AnnotateTime {Poner el tiempo entre movimientos en segundos}
translate S AnnotateWhich {Añadir variaciones}
translate S AnnotateAll {Para movimientos de ambos lados}
translate S AnnotateWhite {Sólo para movimientos de las Blancas}
translate S AnnotateBlack {Sólo para movimientos de las Negras}
translate S AnnotateNotBest {Cuando el movimiento de la partida no es el mejor}

# Analysis Engine open dialog:
translate S EngineList {Analysis Engine List} ;# ***
translate S EngineName {Name} ;# ***
translate S EngineCmd {Command} ;# ***
translate S EngineArgs {Parameters} ;# ***
translate S EngineDir {Directory} ;# ***
translate S EngineElo {Elo}
translate S EngineTime {Fecha}
translate S EngineNew {New} ;# ***
translate S EngineEdit {Edit} ;# ***
translate S EngineRequired {Fields in bold are required; others are optional}

# Stats window menus:
menuText S StatsFile "Archivo" 0
menuText S StatsFilePrint "Imprimir en archivo..." 0
menuText S StatsFileClose "Cerrar ventana" 0
menuText S StatsOpt "Opciones" 0

# PGN window menus:
menuText S PgnFile "Archivo" 0
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
menuText S PgnOptStripMarks "Strip out colored square/arrow codes" 1 ;# ***
menuText S PgnColor "Colores" 1
menuText S PgnColorHeader "Encabezamiento..." 0
menuText S PgnColorAnno "Anotaciones..." 0
menuText S PgnColorComments "Comentarios..." 0
menuText S PgnColorVars "Variaciones..." 0
menuText S PgnColorBackground "Fondo..." 0
menuText S PgnHelp "Ayuda" 1
menuText S PgnHelpPgn "Ayuda de PGN" 9
menuText S PgnHelpIndex "Indice de la ayuda" 0

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
menuText S CrosstabOptBreaks "Tie-break scores" 4 ;# ***
menuText S CrosstabOptDeleted "Include deleted games" 8 ;# ***
menuText S CrosstabOptColors "Colores (sólo en tabla de Suizos)" 0
menuText S CrosstabOptColumnNumbers "Numbered columns (All-play-all table only)" 2 ;# ***
menuText S CrosstabOptGroup "Grupos de clasificación" 0
menuText S CrosstabSort "Ordenar" 0
menuText S CrosstabSortName "Por nombre" 4
menuText S CrosstabSortRating "Por Elo" 4
menuText S CrosstabSortScore "Por puntuación" 4
menuText S CrosstabColor "Color" 2
menuText S CrosstabColorPlain "Texto simple" 0
menuText S CrosstabColorHyper "Hypertexto" 0
menuText S CrosstabHelp "Ayuda" 1
menuText S CrosstabHelpCross "Ayuda de tabla cruzada" 9
menuText S CrosstabHelpIndex "Indice de la ayuda" 0
translate S SetFilter {Poner filtro}
translate S AddToFilter {Añadir al filtro}
translate S Swiss {Suizo}

# Opening report window menus:
menuText S OprepFile "Archivo" 0
menuText S OprepFileText "Imprimir en archivo texto..." 20
menuText S OprepFileHtml "Imprimir en archivo HTML..." 20
menuText S OprepFileLaTeX "Imprimir en archivo LaTeX..." 20
menuText S OprepFileOptions "Opciones..." 0
menuText S OprepFileClose "Cerrar ventana del informe de la apertura" 0
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
translate S PawnFlag {Estruvtura de peones}
translate S TacticsFlag {Tacticas}
translate S QsideFlag {Juego del lado de dama}
translate S KsideFlag {Juego del lado de rey}
translate S BrilliancyFlag {Genialidad}
translate S BlunderFlag {Error}
translate S UserFlag {Usuario}
translate S PgnContains {PGN contiene texto}

# Game list window:
translate S GlistNumber {Número}
translate S GlistWhite {Blanco}
translate S GlistBlack {Negro}
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

# Maintenance window:
translate S DatabaseName {Nombre de la base:}
translate S TypeIcon {Tipo de icono:}
translate S NumOfGames {Partidas:}
translate S NumDeletedGames {Partidas borradas:}
translate S NumFilterGames {Partidas en el filtro:}
translate S YearRange {Rango de años:}
translate S RatingRange {Rango de Elo:}
translate S Flag {Señal}
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
translate S StripTags {Strip PGN tags} ;# ***
translate S StripTag {Strip tag} ;# ***
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

# Comment editor:
translate S AnnotationSymbols  {Símbolos de anotación:}
translate S Comment {Comentario:}

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

# Game saving:
translate S Today {Hoy}
translate S ClassifyGame {Clasificar partida}

# Setup position:
translate S EmptyBoard {Tablero vacío}
translate S InitialBoard {Tablero inicial}
translate S SideToMove {Lado que mueve}
translate S MoveNumber {Movimiento número}
translate S Castling {Enroque}
translate S EnPassentFile {Columna al paso}
translate S ClearFen {Quitar FEN}
translate S PasteFen {Pegar FEN}

# Replace move dialog:
translate S ReplaceMove {Reemplazar movimiento}
translate S AddNewVar {Añadir nueva variación}
translate S ReplaceMoveMessage {Ya existe un movimiento.

Puedes reemplazarlo, descartando todos los movimientos posteriores, o añadirlo como una nueva variación.

(Puedes evitar seguir viendo este mensaje en el futuro desactivando la opción "Preguntar antes de reemplazar movimientos" en el menú Opciones: Movimientos.)}

# Make database read-only dialog:
translate S ReadOnlyDialog {Si haces que esta base de datos sea de sólo lectura no se permitirán hacer cambios. No se podrán guardar o reemplazar partidas, y no se podrán alterar las señales de borrada. Cualquier ordenación o clasificación por ECO será temporal.

Puedes hacer fácilmente escribible la base de datos otra vez cerrándola y abriéndola.

¿Realmente quieres hacer que esta base de datos sea de sólo lectura?}

# Clear game dialog:
translate S ClearGameDialog {Esta partida a sido cambiada.

¿Realmente quieres continuar y eliminar los cambios hechos en ella?
}

# Exit dialog:
translate S ExitDialog {¿Realmente quieres salir de Scid?}
translate S ExitUnsaved {The following databases have unsaved game changes. If you exit now, these changes will be lost.} ;# ***

# Import window:
translate S PasteCurrentGame {Pegar partida actual}
translate S ImportHelp1 \
  {Introducir o pegar una partida en formato PGN en el marco superior.}
translate S ImportHelp2 \
  {Cualquier error importando la partida será mostrado aquí.}

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
translate S OprepThemes {Temas Posicionales}
translate S OprepThemeDescription {Frecuencia de temas en el movimiento %u}
translate S OprepThemeSameCastling {Enroque al mismo lado}
translate S OprepThemeOppCastling {Enroque en lados opuestos}
translate S OprepThemeNoCastling {Ambos Reyes no enrocados}
translate S OprepThemeKPawnStorm {Avanzada de los peones del Rey}
translate S OprepThemeQueenswap {Damas intercambiadas}
translate S OprepThemeIQP {Peones de Dama aislados}
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

# Piece Tracker window:
translate S TrackerSelectSingle {Left mouse button selects this piece.} ;# ***
translate S TrackerSelectPair {Left mouse button selects this piece; right button also selects its sibling.}
translate S TrackerSelectPawn {Left mouse button selects this pawn; right button selects all 8 pawns.}
translate S TrackerStat {Statistic}
translate S TrackerGames {% games with move to square}
translate S TrackerTime {% time on each square}
translate S TrackerMoves {Moves}
translate S TrackerMovesStart {Enter the move number where tracking should begin.}
translate S TrackerMovesStop {Enter the move number where tracking should stop.}

# Game selection dialogs:
translate S SelectAllGames {Todas las partidas de la base de datos}
translate S SelectFilterGames {Sólo las partidas filtradas}
translate S SelectTournamentGames {Sólo las partidas del actual torneo}
translate S SelectOlderGames {Sólo partidas antiguas}

# Delete Twins window:
translate S TwinsNote {Para ser dobles, dos partidas deben de tener al menos los mismos dos jugadores, y los criterios que fijes debajo. Cuando un par de dobles es encontrado, la partida más corta es borrada.
Sugerencia: es mejor hacer la corrección ortográfica de la base de datos antes de iniciar el borrado de dobles, porque esto mejora su detección.}
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
translate S TwinsDeleteWhich {Delete which game:} ;# ***
translate S TwinsDeleteShorter {Shorter game} ;# ***
translate S TwinsDeleteOlder {Smaller game number} ;# ***
translate S TwinsDeleteNewer {Larger game number} ;# ***
translate S TwinsDelete {Borrar partidas}

# Name editor window:
translate S NameEditType {Tipo de nombre a editar}
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
translate S ExportStripMarks {Strip square/arrow mark codes from comments?} ;# ***

# Goto game/move dialogs:
translate S LoadGameNumber {Entra el número de la partida a cargar:}
translate S GotoMoveNumber {Ir al movimiento número:}

# Copy games dialog:
translate S CopyGames {Copiar partidas}
translate S CopyConfirm {
 Realmente deseas copiar las [thousands $nGamesToCopy] partidas fitradas
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

# Upgrading databases:
translate S Upgrading {Actualización}
translate S ConfirmOpenNew {
Este es un formato de base de datos antiguo (Scid 2) que no puede ser abierto con Scid 3, pero ya se ha creado una versión de formato nuevo (Scid 3).

¿Quieres abrir la versión de formato nuevo de la base de datos?
}
translate S ConfirmUpgrade {
Esta es una base de datos en un formato antiguo (Scid 2). Se debe crear una versión de formato nuevo de base de datos antes de poder ser usada en Scid 3.

La actualización creará una nueva versión de la base de datos; esta no corregirá o borrará los archivos originales.

Esto puede tomar un tiempo, pero sólo es necesario hacerlo una vez. Puedes cancelar si toma demasiado tiempo.

¿Quieres actualizar esta base de datos ahora?
}

}

############################################################

# Spanish help pages:

set helpTitle(S,Index) "Índice"
set helpText(S,Index) {<h1>Scid: Índice de la Ayuda</h1>

<h4>Comienzo y ayuda general</h4>
<ul>
<li><a Guide><b>Guía Rápida</b> para usar Scid</a> <red>(Lee esto primero)</red></li>
<li><a Hints><b>Sugerencias</b> para conseguir más de Scid</a></li>
<li><a MainWindow><b>Ventana principal</b> de Scid</a></li>
<li><a Menus><b>Menús</b> de Scid</a></li>
<li><a Moves>Entrada de <b>movimientos</b></a></li>
<li><a Searches><b>Búsquedas</b> en Scid</a></li>
<li><a Clipbase>Utilización de la <b>Base de Trabajo (Clipbase)</b></a></li>
</ul>

<h4>Otras ventanas de Scid</h4>
<ul>
<li><a Analysis>Ventana de <b>Análisis</b></a></li>
<li><a Comment>Ventana del <b>Editor de Comentarios</b></a></li>
<li><a Crosstable>Ventana de <b>Tablas Cruzadas</b></a></li>
<li><a Switcher>Ventana del <b>Intercambiador de Bases de Datos</b></a></li>
<li><a Email>Ventana del administrador de <b>Emails</b> de ajedrez</a></li>
<li><a Finder>Ventana del <b>Visor de Archivos</b></a> <red>(¡Nuevo!)</red></li>
<li><a GameList>Ventana del <b>Listado de Partidas</b></a></li>
<li><a Import>Ventana de <b>Importación de partidas</b></a></li>
<li><a OpReport><b>Ventana del <b>Informe de la apertura</b></a></li>
<li><a PGN>Ventana de <b>PGN</b> (partidas en texto)</a></li>
<li><a PInfo>Ventana de <b>Información del Jugador</b></a></li>
<li><a Repertoire><b>Editor de Repertorio</b></a> <red>(¡Nuevo!)</red></li>
<li><a Tmt>Ventana del <b>Visor de Torneos</b></a> <red>(¡Nuevo!)</red></li>
<li><a Tree>Ventana de <b>Árbol</b></a></li>
<li><a Graphs>Ventanas de <b>Gráficos</b></a></li>
<li><a TB>Uso de <b>Tablebases</b> en Scid</a> <red>(¡Nuevo!)</red></li>
</ul>

<h4>Otras utilidades e información</h4>
<ul>
<li><a Bookmarks><b>Bookmarks</b></a> <red>(¡Nuevo!)</red></li>
<li><a Cmdline>Command-line options</a> <red>(New!)</red></li>
<li><a Compact><b>Compactando</b> una base de datos</a></li>
<li><a Maintenance>Herramientas de <b>mantenimiento de la Base de Datos</b></a>
    <red>(cambios recientes)</red></li>
<li><a ECO>Clasificación de aberturas por <b>ECO</b></a></li>
<li><a EPD>Archivos de <b>EPD</b></a></li>
<li><a Export><b>Exportación</b> de partidas a archivos de texto</a></li>
<li><a Flags>Game <b>Flags</b></a> <red>(¡Nuevo!)</red></li>
<li><a LaTeX>Usando <b>LaTeX</b> con Scid</a></li>
<li><a Options><b>Opciones</b> y preferencias</a></li>
<li><a Sorting><b>Ordenando</b> una base de datos</a></li>
<li><a Pgnscid><b>Pgnscid</b>: conversión de archivos PGN</a></li>
<li><a NAGs>Valores de anotación <b>NAG</b> estándares</a></li>
<li><a Formats><b>Formatos de archivo</b> de las bases de datos Scid</a></li>
<li><a Author>Información de contacto</a></li>
</ul>

<p><footer>(Actualizado: Scid 3.0, Noviembre 2001)</footer></p>
}


####################
### Quick Guide help:

set helpTitle(S,Guide) "Guía rápida para usar Scid"
set helpText(S,Guide) {<h1>Guía rápida para usar Scid</h1>
<p>
Scid es una aplicación de base de datos de ajedrez; con ella puedes realizar búsquedas en bases de datos de partidas de ajedrez, editar partidas, y <a Searches>buscar</a> partidas por varios criterios.
</p>
<p>
Scid usa su propio <a Formats>formato de base de datos</a> de tres archivos, los cuales son muy compactos y rápidos, además puede convertir a y desde el formato estándar PGN (Portable Game Notation). La <a PGN>ventana PGN</a> de Scid muestra el texto de la partida actual en formato PGN.
</p>
<p>
Puedes usar Scid para añadir partidas a una base de datos, usando el teclado o el ratón para entrar los movimientos. Ver la página de ayuda de <a Moves>entrada de movimientos</a> para más detalles.
</p>
<p>
También puedes usar Scid como un buscador de archivos <a PGN>PGN</a>, colocando un texto PGN en la ventana de <a Import>Importación</a> de Scid o abriendo un archivo PGN con Scid. Sin embargo, Scid no puede editar archivos PGN (sólo puede abrirlos y leerlos) ocupándose, además, más memoria y tardándose más en cargar, por eso para grandes archivos PGN se recomienda crear primero una base de datos Scid de ellos con la utilidad <a Pgnscid>pgnscid</a>.
</p>
<p>
La <a MainWindow>Ventana Principal</a> de Scid (con el tablero gráfico de ajedrez) muestra los datos de la partida activa y de la base de datos. Puedes tener abiertas, al mismo tiempo, tres bases de datos (cuatro incluyendo la <a Clipbase>base de trabajo</a>),
y cada una puede tener abierta su propia partida activa. (Una partida numerada como 0 indica que es una partida que no forma parte de la actual base de datos).
Puedes intercambiar entre las bases de datos abiertas mediante el <a Menus File>menú Archivo</a>.
</p>
<p>
Para más información, por favor lee las otras páginas de ayuda mencionadas en el <a Index>Índice de la Ayuda</a>.
</p>
<p>
Mira la página de la <a Author>información de contacto</a> si necesitas contacta con el autor de Scid.
</p>

<p><footer>(Actualizado: Scid 2.5, Junio 2001)</footer></p>
}


####################
### Main window help:

set helpTitle(S,MainWindow) "Ventana principal de Scid"
set helpText(S,MainWindow) {<h1>Ventana principal de Scid</h1>
<p>
La ventana principal de Scid muestra la actual posición del tablero de la partida activa e información sobre la partida actual y la base de datos. Otras páginas de ayuda describen los <a Menus>menús</a> y las maneras de <a Moves>entrar los movimientos de ajedrez</a>.
</p>

<h3>Botones de navegación de la partida</h3>
<p>
Los botones de navegación que hay sobre el tablero tienen, de derecha a izquierda, los siguientes significados:
<ul>
<li> <button tb_start> Va al inicio de la partida. </li>
<li> <button tb_prev> Va un movimiento atrás. </li>
<li> <button tb_next> Va un movimiento adelante. </li>
<li> <button tb_end> Va al final de la partida. </li>
<li> <button tb_invar> Entra en una variación. </li>
<li> <button tb_outvar> Sale de la actual variación. </li>
<li> <button tb_addvar> Añade una variación. </li>
<li> <button autoplay_off> Inicia/para el modo de movimiento automático (ver más abajo). </li>
<li> <button tb_flip> Gira el tablero 180 grados. </li>
<li> <button tb_coords> Poner/quitar las coordenadas del tablero. </li>
</ul>

<h4><name Autoplay>Modo de Movimiento Automático</name></h4>
<p>
En el modo de Movimiento Automático, Scid automáticamente realiza los movimientos de la partida actual, moviendo hacia adelante hasta el final de la partida. El tiempo de demora entre los movimientos puede ser cambiado desde el menú <menu>Opciones: Movimientos</menu>, y es guardado en tu archivo de opciones cuando guardas las opciones.
</p>
<p>
La combinación de teclas <b>Control+Z</b> inicia o para el modo de movimiento automático, asimismo puedes parar el modo de movimiento automático apretando la tecla <b>Escape (Esc)</b>.
</p>
<p>
Si inicias el modo de movimiento automático cuando la <a Analysis>ventana de análisis</a> está abierta, la partida es <term>comentada</term>: la puntuación y el análisis para cada posición es añadido a la partida como comentarios justo antes de que se realice el siguiente movimiento. Ver la página de ayuda de la <a Analysis> ventana de análisis</a> para más detalles.
</p>

<h3>El área de información de la partida</h3>
<p>
El área debajo del tablero de ajedrez que muestra información sobre la partida se llama <term>área de información de la partida</term>.
Las dos primeras líneas muestran información sobre jugadores, resultado, fecha y lugar. La tercera línea indica la posición actual de la partida y cual es el siguiente movimiento.
</p>
<p>
La cuarta línea muestra el código <a ECO>ECO</a> (Encyclopaedia of Chess Openings) de la actual posición, si la posición aparece en el archivo ECO que se este usando.
</p>
<p>
El área de información de la partida tiene un menú que se activa con el botón derecho del ratón, con opciones para ocultar el siguiente movimiento (útil si estás entrenando usando una partida y quieres calcular cada movimiento), y para suprimir (borrar) o restaurar la partida actual. Puedes activar este menú sin usar el ratón, apretando la tecla de función <b>F9</b>.
</p>

<h4>Tablebases</h4>
<p>
El área de información de la partida también muestra resultados de las tablebases en cualquier momento en el que la posición mostrada alcanza una configuración de material que se encuentra en un archivo de tablebase (Tb). Ver la página de ayuda de <aTB>tablebases</a> para más detalles.

<h3>La barra de estado</h3>
<p>
La barra de estado muestra información sobre la base de datos actual. El primer campo indica el estado de la partida: <b>XX</b> significa que a sido alterada y aún no ha sido salvada, <b>--</b> significa que no ha sido alterada y <b>%%</b> indica que la base de datos sólo se puede leer (no es alterable).
</p>
<p>
Si quieres una base de datos que sólo se pueda leer pon los permisos de sus archivos Scid, o al menos de su archivo índice, por ejemplo: <br><li><b>chmod a-w miarchivo.si</b><br> como un comando de un interprete de ordenes para un sistema operativo, y será abierta por Scid como de sólo lectura.
</p>
<p>
La barra de estado también muestra cuántas partidas hay actualmente en el <a Searches Filter>filtro</a>.
</p>

<p><footer>(Actualizado: Scid 2.6, Agosto 2001)</footer></p>
}


####################
### Database switcher help:

set helpTitle(S,Switcher) "Intercambiador de Bases de Datos"
set helpText(S,Switcher) {<h1>La ventana del Intercambiador de Bases de Datos</h1>
<p>
La ventana del Intercambiador de Bases de Datos proporciona una presentación que hace fácil el intercambio entre bases de datos o la copia de partidas entre bases de datos. Se muestra el nombre, el estado del <a Searches Filter>filtro</a> y el tipo de icono gráfico de cada base de datos, siendo puesta de relieve la base de datos activa mediante un fondo amarillo.
</p>
<p>
Puedes abrir el intercambiador de bases de datos desde el menú <menu>Ventanas</menu>, o mediante la combinación de teclas: <b>Control+D</b>.
</p>
<p>
Para cambiar de base de datos tan sólo debes apretar el botón izquierdo del ratón cuando estés sobre ella.
</p>
<p>
Para copiar todas las partidas filtradas de una base de datos a otra debes arrastra con el botón izquierdo del ratón desde la base de datos fuente hasta la base de datos deseada; entonces verás un diálogo de confirmación, o un mensaje de error si las partidas no pueden ser copiadas.
</p>
<p>
Presionando el botón derecho del ratón sobre una base de datos se obtiene un menú emergente de atributos de la base de datos, desde el que puedes cambiar el tipo de icono de la base de datos o anular su <a Searches Filter>filtro</a>.
</p>

<p><footer>(Actualizado: Scid 2.5, Junio 2001)</footer></p>
}


####################
### Entering moves help:

set helpTitle(S,Moves) "Entrada de movimientos"
set helpText(S,Moves) {<h1>Entrada de movimientos de ajedrez</h1>
<p>
En Scid, puedes entrar los movimientos de una partida usando el ratón o el teclado. Cuando mueves el ratón sobre una casilla esta y otra casilla cambian de color si hay un movimiento legal a esta o desde esta casilla. Esto es el <term>movimiento sugerido</term>. Para hacer este movimiento simplemente aprieta el botón <term>izquierdo</term> del ratón. Si esta opción te molesta puedes desactivar el movimiento sugerido usando el menú Opciones.
</p>
<p>
Para hacer cualquier movimiento distinto del movimiento sugerido usa el botón <term>izquierdo</term> del ratón: presiona el botón sobre una casilla y suéltalo sobre la casilla deseada.
</p>
<p>
Si prefieres hacer los movimientos mediante dos clicks de ratón en vez de arrastrando puedes usar el botón <term>central</term>: aprieta en una casilla y luego en la otra.
</p>

<h4>Retroceder un atrás</h4>
<p>
Para volver atrás un movimiento aprieta el botón derecho del ratón, esto va hacia atrás un movimiento, y borra el movimiento si este es el último de la partida o variación.
</p>

<h4>Reemplazar movimientos existentes</h4>
<p>
Cuando introduces un movimiento en un punto de la partida donde ya existe un movimiento Scid muestra una caja de diálogo preguntando si realmente quieres reemplazar el movimiento existente (este y todos los movimientos posteriores se perderían), o si, por contra, quieres añadirlo como una variación. Algunas personas consideran molesta esta caja de diálogo puesto que siempre desean reemplazar el movimiento existente, si es así puedes desactivarla con la opción de menú "<i>Preguntar antes de reemplazar movimientos</i>" yendo al menú <menu>Opciones: Movimientos</menu>.
</p>

<h4>Trial mode</h4>
<p>
If you are studying a game and reach a position where you want to try
an alternative variation on the board without altering the game, select
<b>Try variation</b> from the <menu>Edit</menu> menu to enter trial
mode. In this mode, you can make temporary moves and changes to the
game, then return to the original position when you exit trial mode.
</p>

<h3><name Mistakes>Corrección de errores</name></h3>
<p>
Si estas introduciendo una partida y de pronto ves un movimiento incorrecto varios movimientos antes es posible corregirlo sin perder los movimientos posteriores que has introducido. La única manera es editando la representación PGN de la partida: abre la ventana <a Import>Importar</a>, selecciona "Pegar partida actual", corrige el movimiento equivocado y selecciona "Importar".
</p>

<h3>Entrada de movimientos con el teclado</h3>
<p>
Para entrar movimientos con el teclado únicamente se usan teclas de letras y dígitos. Observa que los movimientos aceptados deben de estar en <term>notación SAN</term>, <i>sin</i> el símbolo de captura (x) o de promoción (=). Los movimientos son identificados de manera insensible, por lo que puedes teclear, por ejemplo, <key>nf3</key> en vez de Nf3 -- mira la nota que hay más abajo sobre conflictos con movimientos de peones.
</p>
<p>
Para asegurar que ningún movimiento es un prefijo de algún otro movimiento la notación para el enroque corto y el enroque largo es <key>OK</key> y <key>OQ</key> respectivamente, en vez de la usual O-O y O-O-O.
</p>
<p>
Cuando entres un movimiento la barra de estado mostrará la lista de posibles movimientos. Puedes presionar la <key>barra espaciadora</key> en cualquier momento para escoger el primer movimiento mostrado en la lista y añadirlo a la partida. Para borrar un carácter presiona la tecla de <key>Borrar</key> (encima de Return) o <key>Suprimir</key>.
</p>
<p>
<b>Fijate</b> que una letra minúscula representa primero a un peón, por lo que como <key>b</key> puede representar a un peón o a un alfil, si hay un conflicto debes usar una <key>B</key> mayúscula para el movimiento del alfil.
</p>

<h4>Teclado Inteligente</h4>
<p>
En el menú opciones puedes activar o desactivar la opción <term>Teclado Inteligente</term>. Con la opción teclado inteligente se hace un movimiento en cuanto se a escrito lo suficiente para distinguirlo de otros movimientos legales. Por ejemplo, con teclado inteligente, sólo necesitaras teclear <key>nf</key> en vez de <key>nf3</key> para el movimiento <b>Nf3</b> en la posición inicial.
</p>

<h4>Entrada de símbolos comunes de comentario</h4>
<p>
Puedes también añadir <a NAGs>símbolos de comentario</a> comunes mediante el teclado en la ventana principal, sin necesidad de usar la ventana del <a Comment>editor de comentarios</a>. La siguiente lista muestra cuales son los símbolos que puedes añadir, y su secuencia de teclas:
<ul>
<li> !  : [!][Return] </li>
<li> ?  : [?][Return] </li>
<li> !? : [!][?][Return] </li>
<li> ?! : [?][!][Return] </li>
<li> !! : [!][!][Return] </li>
<li> ?? : [?][?][Return] </li>
<li> </li>
<li> +- : [+][-] </li>
<li> +/-        : [+][/] </li>
<li> += : [+][=] </li>
<li> =  : [=][Return] </li>
<li> -+ : [-][+] </li>
<li> -/+        : [-][/] </li>
<li> =+ : [=][+] </li>
</ul>

<p><footer>(Actualizado: Scid 2.6, Agosto 2001)</footer></p>
}

####################
### Hints page:
set helpTitle(S,Hints) "Sugerencias de Scid"
set helpText(S,Hints) {<h1>Sugerencias de Scid</h1>
<p>
Esta página contiene sugerencias en formato de preguntas y respuestas para ayudarte a usar Scid mejor. Si eres un nuevo usuario de Scid, por favor lee la <a Guide>guía rápida</a> primero. Mucha de la información de esta página esta disponible, con más detalle, en otras páginas mostradas en el <a Index>índice</a>. Si piensas una sugerencia útil para añadir a esta página, por favor envíala al <a Author>creador de Scid</a>.
</p>

<h4>¿Cómo puedo conseguir que Scid cargue una base de datos cuando se arranca?</h4>
<p>
Sí, puedes añadir bases de datos, archivos PGN o <a EPD>archivos de posiciones</a> en la línea de comandos. Por ejemplo:
<br><li><b>scid  mibase  partidas.pgn.gz</b>
<br>cargará la base de datos Scid mibase y además cargará el archivo PGN comprimido en Gzip <b>partidas.pgn.gz</b>.
</p>

<h4>¿Hay una manera más fácil de cambiar el tamaño del tablero que teniendo que usar el menú de opciones?</h4>
<p>
Sí, se puede usar la combinación de teclas <b>Control+Maysculas+flecha izquierda</b> y <b>Control+Maysculas+flecha derecha</b> para disminuir o aumentar el tamaño del tablero.
</p>

<h4>Estoy entrenando jugando a través de una partida, por lo que no quiero que Scid muestre el siguiente movimiento en el área de información de la partida. ¿Cómo puedo hacer que no se muestre?</h4>
<p>
Puedes hacer que no se muestre el siguiente movimiento presionando el botón <b>derecho</b> del ratón en el área de información de la partida, y seleccionando <b>Esconder el siguiente movimiento</b> en el menú que aparece.
</p>

<h4>¿Cómo puedo ver el código ECO de apertura de la posición actual?</h4>
<p>
El código ECO se muestra en la última línea del área de información de la partida, debajo del tablero de ajedrez en la <a MainWindow>ventana principal</a>, si tienes el archivo de clasificación ECO (<b>scid.eco</b>) cargado. <br>
La página de ayuda de los <a ECO>códigos ECO</a> explica cómo cargar el archivo de la clasificación ECO y cómo salvar la opción para que sea cargada cada vez que se inicie Scid.
</p>

<h4>Estoy introduciendo una partida y estoy en el movimiento 30, y entonces me doy cuenta que el número 10 está equivocado. ¿Cómo puedo corregirlo y conservar todos los movimientos posteriores?</h4>
<p>
Puedes usar la ventana de <a Import>Importación</a>; mira en la página de ayuda <a Moves Mistakes>entrada de movimientos</a> para obtener más ayuda.
</p>

<h4>¿Cómo puedo copiar partidas de una base de datos a otra?</h4>
<p>
Usa la <a Switcher>ventana del intercambiador de bases de datos</a>: arrastra desde la base de datos fuente a la base de datos elegida para copiar todas las partidas <a Searches Filter>filtradas</a> en la base de datos fuente.
</p>

<h4>Cada vez que entro un movimiento donde ya existe uno aparece  la caja de diálogo "¿Reemplazar movimiento?", ¿Cómo puedo evitarlo?</h4>
<p>
Desactívala con la opción <b>Preguntar antes de reemplazar movimientos</b> que hay en el menú <menu>Opciones: Movimientos</menu>. O adopta el hábito de suprimir movimientos usando el botón derecho del ratón, el cual realmente borra el movimiento de la partida si te encuentras en el último movimiento de la partida.
</p>

<h4>¿Cómo puedo cambiar la anchura de las columnas en la ventana del Listado de Partidas?</h4>
<p>
Aprieta el botón derecho o izquierdo del botón en cada título de las columnas.
</p>

<h4>¿Cómo puedo usar la ventana de árbol para las partidas seleccionadas, y no para toda la base de datos?</h4>
<p>
Usa la <a Clipbase>base de trabajo</a>. Haz el filtrado de la base de datos que contiene las partidas en las que quieres usar el árbol, y cópialo a la base de trabajo usando el <a Switcher>intercambiador de bases de datos</a>. Entonces sólo tienes que abrir la ventana de árbol en la base de trabajo.
</p>

<h4>El árbol es lento con bases de datos grandes. ¿Cómo puedo aumentar su velocidad?</h4>
<p>
Guardar el archivo caché con frecuencia, para guardar los resultados del árbol para su futuro uso. Ver la sección sobre cache de la página de ayuda del <a Tree>Árbol</a> para más detalles.
</p>

<h4>¿Cómo puedo editar la representación PGN de una partida directamente?</h4>
<p>
No puedes usar la ventana <a PGN>PGN</a> para editar la partida actual, pero aún así puedes editar su representación PGN usando la ventana <a Import>Importar partida</a>. Simplemente ábrela (combinación de teclas: <b>Control+Mayusculas+I</b>) y el botón <b>Pegar partida actual</b>, entonces edita la partida, y después aprieta <b>Importar</b>.
</p>

<h4>Mi base de datos tiene muchas ortografías distintas para algunos nombres de jugadores. ¿Cómo puedo corregirlas todas?</h4>
<p>
Puedes editar los nombres individualmente o chequear ortográficamente todos los nombres en una base de datos con los comandos que hay en el menú <menu>Archivo: Mantenimiento</menu>. Ver la página de <a Maintenance Editing>mantenimiento</a>.
</p>

<h4>Tengo dos bases de datos abiertas: una con mis partidas, y una gran base de datos de partidas de grandes maestros. ¿Cómo puedo comparar una de mis partidas con las de la base de datos grande?</h4>
<p>
En la base de datos grande abre la <a Tree>ventana de árbol</a> y presiona el botón <term>Bloqueo</term> para bloquear el árbol de esta base de datos. Entonces cambia a la otra base de datos, el árbol continua mostrando los datos de la base de datos grande.
</p>

<p><footer>(Actualizado: Scid 2.6, Agosto 2001)</footer></p>
}

####################
### Menus help screen:

set helpTitle(S,Menus) "Menús"
set helpText(S,Menus) {<h1>Menús de Scid</h1>

<h3><name File>Archivo</name></h3>
<ul>
<li><menu>Nuevo</menu>: Crea una nueva base de datos Scid vacía.</li>
<li><menu>Abrir</menu>: Abre una base de datos Scid ya existente.</li>
<li><menu>Cerrar</menu>: Cierra la base de datos Scid activa.</li>
<li><menu>Mantenimiento</menu>: Funciones de <a Maintenance>mantenimiento</a> de la base de datos.</li>
<ul>
  <li><menu>Ventana de mantenimiento</menu>: Abre/cierra la ventana de mantenimiento de la base de datos Scid.</li>
  <li><menu>Borrar partidas dobles</menu>: Encuentra partidas dobles y las marca como borradas.</li>
  <li><menu>Clasificar partidas por ECO</menu>: Recalcula el <a ECO>código ECO</a> de todas las partidas de la base de datos</li>
<li><menu>Editor de nombres</menu>: Reemplaza todos los diferentes nombres de un jugador, evento, sitio o ronda.</li>
</ul>
<li><menu>Read-Only</menu>: Hace que la actual base de datos sea de sólo lectura.</li>
<li><menu>Base 1/2/3/4</menu>: Estos comandos te permiten cambiar entre los tres lugares disponibles para bases de datos y la <a Clipbase>base de trabajo</a>.</li>
<li><menu>Archivos de posiciones (EPD)</menu>: Abre o crea un <a EPD>archivo de posiciones</a> Scid.</li>
<li><menu>Salir</menu>: Salir de Scid.
</ul>

<h3>Editar</h3>
<ul>
<li><menu>Añadir variación</menu>: Añade una nueva variación, vacía, para el siguiente movimiento, o para el movimiento previo si no hay todavía un siguiente movimiento.</li>
<li><menu>Borrar variación</menu>: Proporciona un submenú de variaciones para el movimiento actual, en el que puedes borrar las que quieras.</li>
<li><menu>Convertir en primera variación</menu>: Hace que una variación sea la primera en la lista para el movimiento actual.</li>
<br>
<li><menu>Poner a cero la base de trabajo</menu>: Vacía la <a Clipbase>base de trabajo</a> para que esté completamente vacia.</li>
<li><menu>Copiar esta partida a la base de trabajo</menu>: Copia la partida actual a la <a Clipbase>base de trabajo</a>.</li>
<li><menu>Pegar la última partida de la base de trabajo</menu>: Pega la partida activa de la <a Clipbase>base de trabajo</a> para que sea la partida activa en la actual base de datos.</li>
</ul>

<h3>Partida</h3>
<ul>
<li><menu>Limpiar partida</menu>: Devuelve la partida activa a un estado vacio, descartando cualquier cambio no salvado.</li>
<li><menu>Setup start board</menu>: Pone la posición inicial de la actual partida.</li>
<li><menu>Cargar partida anterior/siguiente</menu>: Carga la partida anterior/siguiente del <a Searches Filter>filtro</a>.</li>
<li><menu>Recargar partida actual</menu>: Vuelve a cargar la partida actual, descartando cualquier cambio hecho.</li>
<br>
<li><menu>Guardar: Reemplazar partida</menu>: Guarda esta partida, reemplazando la antigua versión en la base de datos.</li>
<li><menu>Guardar: Añadir nueva partida</menu>: Guarda esta partida como una nueva partida, anexionándola al final de la base de datos.</li>
<br>
<li><menu>Ir a la posición ECO más avanzada</menu>: Encuentra la posición más avanzada de la partida que está en el archivo ECO.</li>
</ul>

<h3>Buscar</h3>
<ul>
<li><menu>Poner a cero el filtro</menu>: Pone a cero el <a Searches Filter>filtro</a> para que todas la partidas esten incluidas.</li>
<li><menu>Invertir filtro</menu>: Invierte el filtro para que así sólo se incluyan las partidas que estaban excluidas.</li>
<br>
<li><menu>Tablero actual</menu>: Busca por la posición  del <a Searches Board>tablero actual</a>.</li>
<li><menu>Material/Patrón</menu>: Busca por <a Searches Material>material</a> o patrón del tablero</a>.</li>
<li><menu>Encabezamiento</menu>: Busca por la información del <a Searches Header>encabezamiento</a>, como puede ser, por ejemplo, nombre de jugadores.</li>
<br>
<li><menu>Usar archivo de búsqueda</menu>: Busca usando un archivo de <a Searches Settings>opciones</a> de búsqueda.</li>
</ul>

<h3>Ventanas</h3>
<ul>
<li><menu>Editor de Comentarios</menu>: Abre/cierra la ventana del <a Comment>Editor de Comentarios</a>.</li>
<li><menu>Ventana de Listado de partidas</menu>: Abre/cierra la <a GameList>Ventana de Listado de partidas</a>.</li>
<li><menu>Ventana PGN</menu>: Abre/cierra la <a PGN>ventana PGN</a>.</li>
<br>
<li><menu>Intercambiador de bases de datos</menu>: Abre/cierra la ventana del <a Switcher>Intercambiador de bases de datos</a>, el cual te permite cambiar a otra base de datos o copiar fácilmente partidas entre bases de datos.</li>
<li><menu>Ventana de mantenimiento</menu>: Abre/cierra la ventana de mantenimiento de la base de datos Scid.</li>
<br>
<li><menu>ECO Browser</menu>: Abre/cierra la ventana del <a ECO browser>Buscador ECO</a>.</li>
<li><menu>Repertoire editor</menu>: Abre/cierra el <a Repertoire>editor de repertorio</a>.</li>
<li><menu>Ventana de estadísticas</menu>: Abre/cierra la <term>Ventana de estadísticas del filtro</term> la cual muestra una recopilación de las partidas ganadas/perdidas dentro del <a Searches Filter>filtro</a>.</li>
<li><menu>Ventana de árbol</menu>: Abre/cierra la <a Tree>ventana de árbol</a>.</li>
<li><menu>Endgame Tablebase window</menu>: Abre/cierra la ventana que muestra información de las <a TB>tablebases</a>.</li>
</ul>

<h3>Herramientas</h3>
<ul>
<li><menu>Ventana de análisis</menu>: Inicia/para el análisis del motor de ajedrez, mostrando la valoración de la posición actual en la <a Analysis>ventana de análisis</a>.</li>
<li><menu>Tabla cruzada</menu>: Construye una <a Crosstable>tabla cruzada</a> del torneo de la partida actual.</li>
<li><menu>Administrador de Email</menu>: Abre/cierra la ventana del <a Email>administrador de Email</a>, para administrar la correspondencia de Email.</li>
<br>
<li><menu>Opening report</menu>: Genera un <a OpReport>informe de la apertura</a> para la actual posición.</li>
<li><menu>Player information</menu>: Muestra la <a PInfo>información del jugador</a> para uno o dos jugadores de la actual partida.</li>
<li><menu>Rating graph</menu>: Muestra el <a Graphs Rating>gráfico de clasificación</a>.</li>
<li><menu>Score graph</menu>: Muestra el <a Graphs Score>gráfico de puntuación</a>.</li>
<br>
<li><menu>Exportar la partida actual</menu>: Escribe la partida actual en un archivo de texto en formato PGN, HTML or LaTeX. Ver la ayuda de la página <a Export>exportar</a>.</li>
<li><menu>Exportar todas las partidas filtradas</menu>: Escribe todas las partidas del <a Searches Filter>filtro</a> de búsqueda en un archivo de texto en formato PGN, HTML or LaTeX. Ver la ayuda de la página <a Export>exportar</a>.</li>
<br>
<li><menu>Importar partida PGN</menu>: Abre la <a Import>ventana Importar</a> para anotar una partida escribiendo o pegando su texto en <a PGN>formato PGN</a>.</li>
</ul>

<h3>Opciones</h3>
<p>
Esta ventana proporciona el acceso para fijar la mayor parte de las opciones configurables de Scid.
La entrada de datos <menu>Guardar opciones</menu> guarda las opciones actuales en el archivo "<b>.scid</b>" de tu librería de uso (o para los usuario de Windows en <b>scid.opt</b> en el directorio del ejecutable de Scid).
</p>

<p><footer>(Actualizado: Scid 2.6, Agosto 2001)</footer></p>
}


########################################
### Searches help screen:

set helpTitle(S,Searches) "Búsquedas"
set helpText(S,Searches) {<h1>Búsquedas con Scid</h1>
<p>
Scid puede ejecutar muchos tipos diferentes de búsqueda en una base de datos. Los tres tipos de búsqueda principales son:
<ul>
<li><b>1)</b> para el tablero actual, </li>
<li><b>2)</b> por material especificado o modelo de distribución de piezas, y </li>
<li><b>3)</b> por información de la cabecera, como jugador, resultado, fecha,...</li>
</ul>
<p>
Además de estas, hay también un modo de búsqueda automática llamado <a Tree>ventana de Árbol</a> el cual se explicará separadamente.
</p>

<h3><name Filter>Filtro de Búsqueda</name></h3>
<p>
En Scid las búsquedas se basan en el concepto de <term>filtro</term>.
El filtro representa un subconjunto de la base de datos actualmente en uso; en cualquier momento cada partida puede ser incluida o excluida del filtro.
</p>
<p>
Con cada tipo de búsqueda puedes optar por restringir el filtro existente, añadirlo a él, o ignorarlo y buscar en toda la base de datos. Esta capacidad de elección permite complejas búsquedas construidas por partes.
</p>
<p>
Además puedes copiar todas las partidas del filtro de una base de datos a otra, usando la ventana del <a Switcher>intercambiador de bases de datos</a>.
</p>
<p>
En las búsquedas por posición exacta, <a Tree>árbol</a> o material/modelo, es recordado el número de la primera posición coincidente de cada partida concordante, por lo que cuando cargas cada partida esta muestra automáticamente la posición coincidente.
</p>
<p>
<b>Nota</b> estas búsquedas sólo se aplican a la línea principal de movimientos de la partida, y no a los movimientos de las variaciones.
</p>

<h3><name Board>Búsqueda: Tablero Actual</name></h3>
<p>
Esta búsqueda encuentra partidas que contienen la posición actualmente mostrada, ignorando las reglas del enroque y <i>al paso</i>.
</p>
<p>
Hay cuatro tipos de búsquedas por tablero disponibles. Las cuatro precisan de una posición que tenga exactamente el mismo material y lado que mueva para poder corresponderse.
Los tipos son:
<ul>
<li>[1] exacta (las dos posiciones deben de corresponderse en cada casilla),</li>
<li>[2] peones (la estructura de peones debe corresponderse exactamente, pero las piezas pueden estar en cualquier sitio),</li>
<li>[3] columnas (el número de peones blancos y negros de cada columna debe ser exactamente el pedido, por contra las piezas pueden estar en cualquier sitio), y</li>
<li>[4] material (los peones y las piezas pueden estar en cualquier sitio).
La búsqueda por peones es útil para estudiar aperturas por estructura de peones, y las búsquedas por columnas y material son útiles para encontrar posiciones similares en un final de partida.</li>
</ul>
<p>
Para buscar una posición determinada puedes poner la posición primero (desde el menú <menu>Partida: Iniciar tablero de posición</menu>) y entonces iniciar la búsqueda.
</p>
<p>
Puedes pedir que la búsqueda mire en las variaciones (en vez de sólo la línea principal de las partidas)seleccionando la casilla <b>Mirar en variaciones</b>, pero esto puede hacer la búsqueda mucho más lenta si la base de datos es larga y tiene muchas partidas con variaciones.
</p>

<h3><name Material>Búsqueda: Material/Modelo</name></h3>
<p>
Esta búsqueda es útil para encontrar temas de finales o medio juego. Puedes especificar la cantidad mínima y máxima para cada tipo de material, y encontrar modelos como un Alfil en f7, o un peón en la columna f.
</p>
<p>
Se facilitan algunas disposiciones comunes de material o de modelos, como finales de Torre contra peón, o peones de Dama aislados.
</p>
<p>
<b>Sugerencias:</b><br>
La velocidad de las búsquedas por modelo puede variar ampliamente. Puedes reducir el tiempo necesario para una búsqueda fijando restricciones de manera inteligente. Por ejemplo, si fijas el mínimo número de movimientos para un final en 20 todas las partidas que finalizan en menos de 20 movimientos serán saltadas.
</p>

<h3><name Header>Búsqueda: Cabecera</name></h3>
<p>
Esta búsqueda puede ser usada para encontrar características de una partida que se encuentran almacenadas en la cabecera (como puede ser fecha, resultado, nombres, señales y clasificaciones), las cuales no necesitan decodificar ningún movimiento.
</p>
<p>
Para que una partida se corresponda con una búsqueda por cabecera, <b>todos</b> los campos que especifiques se deben corresponder.
</p>
<p>
Los campos con nombre (blancas, negras, evento y lugar) corresponden con cualquier texto dentro del nombre, de manera insensible e ignorando espacios.
</p>
<p>
Puedes hacer búsquedas más ajustadas usando comodines (representando <b>?</b> un caracter y <b>*</b> representando cero o más caracteres) poniendo el texto entre comillas. Por ejemplo, una búsqueda para el lugar <b>USA</b> encontrará ciudades americanas pero también <b>Lausanne SUI</b>, ¡lo cual seguramente no es lo que buscas! Una búsqueda por el lugar <b>"*USA"</b> (acuérdate de usar las comillas) sólo mostrará ciudades de los Estados Unidos.
</p>
<p>
Si estas buscando un jugador en concreto (o pareja de oponentes) tanto para Blanco como para Negro (no importa con el color que jugó), selecciona la opción <b>Ignorar Colores</b>.
</p>

<h3><name Settings>Guardar opciones de búsqueda</name></h3>
<p>
Las ventanas de búsqueda por Material/Modelo y Cabecera facilitan un botón para <term>Guardar opciones</term>. Esto te permite guardar las opciones de búsqueda para usarlas posteriormente, en un archivo de <term>OpcionesBúsqueda</term> (extensión .sso).
Para búsquedas usando un archivo OpcionesBúsqueda (.sso) previamente guardado, selecciona <menu>Abrir</menu> desde el menú <menu>Búsqueda</menu>.
</p>

<h3>Tiempos de búsqueda y partidas saltadas</h3>
<p>
Muchas búsquedas proporcionan un mensaje indicando el tiempo usado y el número de partidas que se han <term>saltado</term>. Una partida saltada es aquella que puede se excluida de la búsqueda sin decodificar ninguno de sus movimientos, basándose en la información almacenada en su índice. Ver la página de ayuda de los <a Formats>formatos de archivos</a> para obtener más información.
</p>

<p><footer>(Actualizado: Scid 2.5, Junio 2001)</footer></p>
}


###############################
### Clipbase help:

set helpTitle(S,Clipbase) "La Base de Trabajo"
set helpText(S,Clipbase) {<h1>La base de datos Base de Trabajo</h1>
<p>
Además de las bases de datos que tienes abiertas, Scid proporciona una <term>base de trabajo</term>, la cual es como otra base de datos excepto que esta sólo existe en memoria y no tiene archivos para un almacenamiento permanente.
</p>
<p>
La base de trabajo es útil como base de datos temporal, para fusionar los resultados de búsqueda realizados en más de una base de datos o para procesar los resultados de una búsqueda como una base de datos separada.
</p>
<p>
Por ejemplo, supongamos que te estas preparando contra un oponente y has buscado una base de datos en la que el <a filter>filtro</a> contiene sólo partidas donde el oponente a jugado con blancas. Puedes copiar estas partidas a la base de trabajo (arrastrando desde su base de datos a la base de trabajo en la ventana del <a Switcher>intercambiador de bases de datos</a>); cambia a la base de trabajo, y entonces abre la <a Tree>Ventana de árbol</a> para examinar su repertorio de juego.
</p>
<p>
Observa que puedes copiar las partidas del filtro de una base de datos directamente a otra base de datos abierta (sin necesidad de usar la base de trabajo como ubicación intermedia) usando la ventana del <a Switcher>intercambiador de bases de datos</a>.
</p>
<p>
Observa que la base de trabajo <i>no puede</i> ser cerrada; seleccionando el comando <menu>Archivo: Cerrar</menu> en la base de trabajo esto equivale a <menu>Editar: Poner a cero la base de trabajo</menu> lo cual vacía la base de trabajo.
</p>
<p>
La base de trabajo tiene siempre un límite de 10000 partidas, desde que ella existe sólo en memoria.
</p>

<p><footer>(Actualizado: Scid 2.5, Junio 2001)</footer></p>
}


###############################
### Comment editor window help:

set helpTitle(S,Comment) "Ventana del Editor de Comentarios"
set helpText(S,Comment) {<h1>La ventana del Editor de Comentarios</h1>
<p>
La ventana del Editor de Comentarios permite añadir o editar comentarios y anotaciones de símbolos a los movimientos de la partida de ajedrez activa.
</p>

<h3>Anotaciones de símbolos</h3>
<p>
Scid usa el <a Author Related>estándar PGN</a> para la anotación de símbolos, aceptando valores <a NAGs>NAG (numeric annotation glyph)</a> para las anotaciones.
Algunos de los símbolos más comunes (como son "!" o "+-") son presentados como símbolos, y tienen un botón en la ventana del editor de comentarios para poder introducirlos rápidamente. Para otros símbolos, puedes introducir el valor numérico NAG apropiado, el cual es un número entre 1 y 255.
Por ejemplo, el valor NAG 36 significa "Blancas tienen la iniciativa" y será mostrado como "$36" en el <a PGN>texto PGN</a> de la partida.
</p>
<p>
Ver la página de ayuda de los <a NAGs>valores NAG</a> para ver los valores NAG definidos por el estándar PGN.
</p>
<p>
<b>Sugerencia:</b> Puedes añadir los símbolos de evaluación comunes (!, ?, !!, ??, !? y ?!) incluso en la ventana principal, sin necesidad de usar la ventana del editor de comentarios, escribiendo el símbolo seguido de la tecla <key>Return</key>. Esto es especialmente si estás <a Moves>anotando los movimientos</a> usando el teclado.
</p>

<h3>Comentarios</h3>
<p>
Puedes editar comentarios escribiendo en el área de texto que se facilita y usando los botones Limpiar, Retroceder y Almacenar.
No necesitas apretar el botón Almacenar para actualizar un comentario; este es automáticamente actualizado en cualquier momento que te muevas a otra posición de la partida.
</p>

<p><footer>(Actualizado: Scid 2.5, Junio 2001)</footer></p>
}

####################
### Crosstable window help:

set helpTitle(S,Crosstable) "Ventana de Tabla Cruzada"
set helpText(S,Crosstable) {<h1>La ventana de Tabla Cruzada</h1>
<p>
La ventana de tabla cruzada muestra la tabla cruzada del torneo al que pertenece la partida actual. Cada vez que actualices la ventana de tabla cruzada (apretando su botón de actualización, apretando la tecla <b>Return</b> en la ventana de tabla cruzada, o con <b>Control+Shift+X</b> en las ventanas <a MainWindow>principal</a> o <a GameList>listado de partidas</a>), Scid buscará todas las partidas jugadas en el mismo torneo que la partida actual.
</p>
<p>
Cualquier partida jugada <b>dos meses antes o después</b> que la partida actual, con <b>exactamente el mismo Evento y Lugar</b>, es considerada como perteneciente al torneo.
</p>
<p>
Un click del botón izquierdo del ratón sobre cualquier resultado de la tabla carga la partida correspondiente. Puedes añadir todas las partidas del torneo al <a Searches Filter>filtro</a> con el botón <b>Añadir al filtro</b> de la ventana de tabla cruzada.
</p>

<h4>Menús de la ventana de tabla cruzada</h4>
<p>
El menú <menu>Archivo</menu> permite guarda la tabla actual a un archivo de texto sin formato o a una tabla en formato HTML.
</p>
<p>
El menú <menu>Mostrar</menu> permite escoger el formato de la tabla:
<b>Todos contra todos</b>, <b>Suizo</b> o <b>Eliminatoria directa</b>.
</p>
<p>
El formato todos contra todos tiene un límite de 30 jugadores, pero el formato Suizo (para torneos con muchos jugadores) puede mostrar más de 200 jugadores y más de 20 rondas.
</p>
<p>
Obsérvese que Scid usa la entrada <b>Ronda</b> de cada partida para construir la tabla cruzada de Suizos, por lo que no se verá ninguna partida en la tabla de Suizo de un torneo si las partidas no tienen un valor numérico para la ronda: 1, 2, 3, etc.
</p>
<p>
El menú Mostrar además permite configurar los datos presentados a tu gusto, para incluir o excluir clasificaciones, países y tratamiento del jugador. Además puedes escoger si el color asignado en las tablas de Suizos es mostrado o no.
</p>
<p>
La opción <b>Separar por grupos de clasificación</b> sólo afecta a la presentación de la tabla cuando los jugadores son ordenados por su clasificación: inserta una línea en blanco entre cada grupo de jugadores con la misma clasificación.
</p>
<p>
El menú <menu>Ordenar</menu> te permite ordenar los jugadores por nombre, clasificación o puntuación; por defecto lo hace por puntuación.
</p>
<p>
El menú <menu>Texto</menu> te permite cambiar el color de presentación (hipertexto) entre encendido y apagado. Puesto que puede llevar mucho tiempo el dar forma y mostrar grandes tablas cruzadas en hipertexto, seleccionando <b>Texto sin formato</b> para los eventos largos se puede ganar mucho tiempo. Sin embargo con texto sin formato no se puede pinchar sobre los jugadores o las partidas.
</p>

<h4>Partidas duplicadas en la tabla cruzada</h4>
<p>
Para obtener buenos resultados con la tabla cruzada debes marcar las partidas duplicadas para ser borradas y tus partidas deben tener una ortografía uniforme de los nombres de los jugadores, lugares y eventos.
Ver la página de <a Maintenance>mantenimiento de la base de datos</a> para obtener ayuda sobre el borrado de partidas duplicadas y la edición (o comprobación ortográfica) de los nombres de jugadores/eventos/lugares.
</p>

<p><footer>(Actualizado: Scid 2.5, Junio 2001)</footer></p>
}

####################
### File Finder window help:
set helpTitle(S,Finder) "Ventana del Visor de Archivos"
set helpText(S,Finder) {<h1>La ventana del Visor de Archivos</h1>
<p>
El <term>Visor de Archivos</term> te ayuda a ver cualquier tipo de archivo que p
uedas usar en Scid: bases de datos, archivos <a PGN>PGN</a>, archivos <a EPD>EP
D</a>, y archivos de <a Repertoire>repertorio</a>.
</p>
<p>
El visor muestra información útil sobre cada archivo, como su tamaño (ver más ab
ajo) y fecha de última modificación. Puedes abrir cualquier archivo mostrado sel
eccionándolo con el botón izquierdo del ratón.
</p>

<h3>Mirando en subdirectorios</h3>
<p>
Cuando desees comprobar todos los archivos de todos los subdirectorios del direc
torio actual, activa el recuadro <b>Mirar en subdirectorios</b>. Esto hará que S
cid examine recursivamente cada subdirectorio en busca de archivos que puedan se
r abiertos por Scid. Esto puede tomar largo tiempo si hay muchos subdirectorios,
 por lo que no debes hacer esto en un directorio cercano al directorio raíz. Pue
des interrumpir la búsqueda de archivos presionando el botón <b>Parar</b>.
</p>

<h3>Tamaños de archivo</h3>
<p>
El significado del tamaño del archivo mostrado por el visor depende del tipo de
archivo. Para bases de datos Scid y archivos PGN, es el número de partidas. Para
 archivos EPD, es el número de posiciones. Para archivos de repertorio, es el nú
mero de líneas (incluidas o excluidas.
</p>
<p>
Para todos los tipos de archivo excepto bases de datos Scid, el tamaño del archi
vo es una estimación tomando como muestra los primeros 64 kilobytes del archivo,
 por lo que el tamaño puede no ser correcto para archivos mayores de 64 kb. Los
tamaños estimados se muestran con una tilde (~) para indicar que no son exactos.
</p>

<p><footer>(Actualizado: Scid 2.7, Septiembre 2001)</footer></p>
}

####################
### Tournament Finder window help:

set helpTitle(S,Tmt) "Ventana del Visor de Torneos"
set helpText(S,Tmt) {<h1>La ventana del Visor de Torneos</h1>
<p>
El <term>Visor de Torneos</term> te permite encontrar torneos en la base de dato
s actual. Explora todas las partidas de la base de datos y compara los datos sob
re los torneos encontrados. Ten en cuenta que dos partidas se considera que son
del mismo torneo si tienen la misma etiqueta de Evento, la misma etiqueta de Lug
ar y han sido jugadas como máximo con dos meses de diferencia.
<p>
Puedes limitar la lista de torneos por el número de jugadores y partidas, fecha,
 media de Elo y país, editando los campos por debajo de la lista de torneos y pr
esionando el botón <b>Actualizar</b>.
</p>
<p>
La lista mostrada puede ser ordenada por fecha, número de jugadores, número de p
artidas, media de Elo, lugar, evento o el apellido del ganador. Selecciona el ti
po desde el menú <menu>Ordenar</menu> o pincha en el título de una columna para
cambiar el campo de ordenación.
</p>
<p>
Para cargar la primera partida de cualquier torneo que se muestre, simplemente p
incha con el botón izquierdo del ratón cuando este se encuentra resaltado. Esto
además actualiza la ventana de <a Crosstable>Tabla cruzada</a> si se encuentra a
bierta.
</p>
<p>
Para aumentar la velocidad del proceso de búsqueda de torneos, es una buena idea
 introducir un rango de fechas medianamente pequeño (como unos pocos años como m
ucho) o seleccionar un país concreto (mediante su código estándar de tres letras
). Haciendo esto se reducirá grandemente el número de partidas que Scid tiene qu
e considerar cuando trate de formar los torneos fuera de las partidas de la base
 de datos.
</p>

<p><footer>(Actualizado: Scid 2.7, Septiembre 2001)</footer></p>
}

####################
### GameList window help:

set helpTitle(S,GameList) "Ventana de Listado de partidas"
set helpText(S,GameList) {<h1>La ventana de Listado de partidas</h1>
<p>
La ventana de Listado de partidas muestra una línea sumario para cada partida incluida en el actual <term>filtro</term>.
</p>

<h3>Navegando por la lista de partidas</h3>
<p>
Puedes desplazarte por la lista de partidas usando la barra deslizante o los cuatro botones que hay debajo de la lista.
También puedes usar las teclas <key>Inicio</key>, <key>Fin</key>,
<key>Re Pág</key>, <key>Av Pág</key> y el teclado de flechas para desplazarte usando el teclado.
</p>
<p>
Puedes encontrar la siguiente partida de la lista que tenga cierto texto en los campos blancas, negras, Evento o Lugar usando la caja  <b>Encontrar texto</b>.
</p>

<h3>Acciones sobre las partidas de la lista</h3>
<p>
Para cargar una partida de la lista haz doble click con el botón izquierdo del ratón sobre la partida. Apretando el botón central del ratón se muestran los movimientos iniciales de una partida; esto puede ser útil para comprobar la apertura de una partida antes de cargarla.
</p>
<p>
El botón derecho del ratón genera un menú para la partida seleccionada, con el cual puedes borrar (o cancelar el borrado, restaurar) la partida, o excluirla del filtro. Observa que borrando una partida sólo se activa la marca de borrado; permanece en la base de datos hasta que esta sea compactada, ver <a Compact>compactar</a>.
</p>

<h3>Cambiando la anchura de las columnas en la lista de partidas</h3>
<p>
Aprieta el botón derecho del ratón sobre el título de una columna para hacerla más alargada, o aprieta el botón izquierdo para hacerla más corta.
</p>

<h3>Cambiando el tamaño del listado de partidas</h3>
<p>
El tamaño de la ventana del listado de partidas es guardado en el archivo de opciones siempre que salves las opciones. Por lo que si quieres que el listado de partidas muestre por defecto 10 partidas, sólo cambia el tamaño de la ventana del listado de partidas y selecciona <menu>Guardar opciones</menu> en el menú <menu>Opciones</menu>.
</p>

<p><footer>(Actualizado: Scid 2.5, Junio 2001)</footer></p>
}

####################
### Import window help:

set helpTitle(S,Import) "Ventana Importar"
set helpText(S,Import) {<h1>La ventana Importar</h1>
<p>
La ventana de Scid Importar proporciona una manera fácil para pegar una partida en <a PGN>formato PGN</a> dentro de Scid desde alguna otra aplicación o ventana.
</p>
<p>
El marco grande de la ventana es donde se escribe o pega el texto de una partida en formato PGN, y el marco gris de debajo proporciona la retroinformación de cualquier error o advertencia.
</p>

<h3>Edición de la partida actual con la Ventana Importar</h3>
<p>
La ventana Importar además es la manera más conveniente de hacer pequeños cambios en la partida actual: puedes pegar la partida actual en la ventana de Importación (con el botón <b>Pegar partida actual</b>), editar el texto, y apretar <b>Importar</b> cuando esté.
</p>

<h3>Etiquetas PGN en la ventana Importar</h3>
<p>
Scid anticipa las etiquetas de la cabecera PGN como
<ul>
<li> <b>[Result "*"]</b>
</ul>
antes de cualquier movimiento; pero puedes pegar solamente un fragmento de partida análogo a
<ul>
<li> <b>1.e4 e5 2.Bc4 Bc5 3.Qh5?! Nf6?? 4.Qxf7# 1-0</b>
</ul>
sin ninguna etiqueta de cabecera y Scid la importará.
</p>

<h3>Usando archivos PGN en Scid</h3>
<p>
Si quieres usar un archivo en formato PGN en Scid pero no quieres convertirlo primero con <a Pgnscid>pgnscid</a>, hay dos posibles maneras.
</p>
<p>
Primera, puedes importar partidas de un archivo a una base de datos existente con el comando del menú <menu>Herramientas: Importar archivo de partidas PGN...</menu>.
</p>
<p>
La alternativa es abrir el archivo PGN directamente en Scid. Sin embargo, los archivos de formato PGN son abiertos como de sólo lectura y consumen más memoria que una base de datos Scid comparable, por lo que esto es sólo recomendable para archivos PGN relativamente pequeños.
</p>

<p><footer>(Actualizado: Scid 2.5, Junio 2001)</footer></p>
}

####################
### Exporting help:

set helpTitle(S,Export) "Exportación de partidas"
set helpText(S,Export) {<h1>Exportación de partidas</h1>
<p>
Puedes usar comandos mediante el menú <menu>Herramientas</menu> para exportar la partida o todas las partidas del filtro actual a un archivo de texto.
</p>
<p>
Hay disponibles tres formatos de archivo: <a PGN>PGN</a> (portable game
notation), HTML (para páginas web) y LaTeX (un sistema popular de composición tipográfica).
</p>
<p>
Cuando exportes, puedes decidir crear un nuevo archivo, o añadir las partidas a un archivo ya existente de partidas exportadas por Scid.
</p>

<h3>Diagramas</h3>
<p>
Cuando se exporta a formato HTML o LaTeX, Scid automáticamente añadirá en la partida un diagrama allí donde aparezca un <a NAGs>nag</a> de diagrama ("D") o un <a Comment>comentario</a> que empiece con el caracter "#".
</p>

<h3>Exportación en HTML</h3>
<p>
Scid puede exportar partidas a un archivo HTML. Para que los diagramas aparezcan, necesitaras que las imágenes de diagrama (distribuidas con Scid, en el directorio "<b>bitmaps/</b>") estén en un subdirectorio <b>bitmaps/</b> dentro del directorio donde se encuentre el archivo HTML.
</p>

<h3>Exportación en LaTeX</h3>
<p>
Scid puede exportar partidas a archivos LaTeX. Las partidas serán impresas a dos columnas por página y los movimientos estarán en notación algebraica con figuritas.
</p>
<p>
Ver la página de ayuda <a LaTeX>Usando LaTeX con Scid</a> para más información.
</p>

<p><footer>(Actualizado: Scid 2.5, Junio 2001)</footer></p>
}

####################
### LaTeX help:

set helpTitle(S,LaTeX) "Scid y LaTeX"
set helpText(S,LaTeX) {<h1>Usando LaTeX con Scid</h1>
<p>
Scid puede guardar partidas e informes de aperturas en archivos en formato LaTeX. LaTeX es una extensión de TeX, un sistema popular de composición tipográfica.
</p>
<p>
Para componer los archivos LaTeX producidos con Scid, debes de tener (por supuesto) LaTeX y tener instalada la fuente "chess12". Esta fuente no es normalmente parte de la instalación estándar de LaTeX, por lo que si tienes LaTeX puedes no tener la fuente de ajedrez.
</p>
<p>
Para obtener información sobre como bajar e instalar la fuente de ajedrez usada con LaTeX, visita la página <url http://scid.sourceforge.net/latex.html>Usando LaTeX con Scid</url> en el <url http://scid.sourceforge.net/>sitio web de Scid</url>.
</p>

<p><footer>(Actualizado: Scid 2.5, Junio 2001)</footer></p>
}

####################
### PGN window help:

set helpTitle(S,PGN) "Ventana PGN"
set helpText(S,PGN) {<h1>La ventana PGN</h1>
<p>
La ventana PGN de Scid muestra en la representación estándar PGN el contenido de la partida actual. En el texto de los movimientos, los comentarios aparecen {entre corchetes} y las variaciones (entre paréntesis).
</p>

<h3>Formato PGN</h3>
<p>
PGN (Portable Game Notation) es el estándar común para transferir partidas de ajedrez entre programas de ordenador. Una partida PGN consiste en dos secciones. La primera es la cabecera, que contiene datos como son <br>
<b>[White "Kasparov, Gary"]</b>
y
<b>[Result "1/2-1/2"]</b>.
</p>
<p>
La segunda sección contiene los movimientos, actuales, de la partida en la notación algebraica estándar (standard algebraic notation (SAN)) junto con algunas variaciones, <a NAGs>símbolos de anotación</a> y <a Comment>comentarios</a>.
</p>

<h3>Acciones en la ventana PGN</h3>
<p>
Puedes usar la ventana PGN para navegar a través de la partida: apretando el botón izquierdo del ratón sobre un movimiento se salta hasta él. Apretando el botón izquierdo del ratón sobre un comentario se edita este.
</p>

<h3>Opciones de visualización PGN</h3>
<p>
Los menús de la ventana PGN contienen opciones que afectan a la visualización de esta.
</p>
<p>
Scid puede mostrar las partidas en color o en texto sin formato -- ver el menú
<menu>Presentación</menu> en la ventana PGN. La presentación en color es más fácil de leer, y permite seleccionar movimientos y comentarios con el ratón, pero es bastante más lenta actualizándose. Para partidas muy largas es preferible escoger la presentación con texto sin formato.
</p>
<p>
También puedes alterar el formato de los comentarios y las variaciones, pudiendo decidir si son mostrados con sangría en una línea aparte para que tengan una gran visibilidad.
</p>
<p>
Las opciones de presentación PGN, y el tamaño de la ventana PGN, son guardados en el archivo de opciones cada vez que usas en el menú de la ventana principal <menu>Opciones</menu> la opción  <b>Guardar Opciones</b>.
</p>

<p><footer>(Actualizado: Scid 2.5, Junio 2001)</footer></p>
}

####################
### Tree window help:

set helpTitle(S,Repertoire) "Editor de Repertorio"
set helpText(S,Repertoire) {<h1>La ventana del editor de Repertorio</h1>
<p>
El editor de repertorio te permite crear, ver y editar archivos de <term>repertorio</term>. Un archivo de repertorio (.sor) es una lista de posiciones de apertura que tratas de alcanzar o de evitar, puedes usarlo para administrar tus preferencias en las aperturas y también para buscar en las bases de datos con Scid.
</p>

<h3>Grupos y líneas de repertorio</h3>
<p>
Un repertorio contiene dos tipos de elementos: <term>grupos</term> y
<term>líneas</term>. Los grupos no son realmente parte de tu repertorio; sólo son usados para estructurarlo de la misma manera que los directorios dan la estructura a los archivos del disco duro de tu ordenador.
</p>
<p>
Las líneas en un repertorio se organizan en dos tipos: <term>incluir</term> líneas que representan posiciones de apertura en las que estás interesado e intentas alcanzar, y <term>excluir</term> líneas en las que no estás interesado en jugar y que tratas de evitar. Por ejemplo, si juegas QGA (1.d4 d5 2.c4 dxc4) con Negras y tu juegas todos los movimientos después de 3.e4 <i>excepto</i> 3...Nf6, deberás poner 1.d4 d5 2.c4 dxc4 3.e4 como línea incluida y 1.d4 d5 2.c4 dxc4 3.e4 Nf6 como línea excluida.
</p>

<h3>Comentarios y notas</h3>
<p>
Cada grupo o línea puede tener comentarios ligados a estos. Hay dos tipos: cortos (de una sola línea) aparecen (en rojo) en la estructura del repertorio al lado de los movimientos de un grupo o línea, por contra los comentarios largos (múltiples líneas) se muestran sólo cuando el grupo o línea es seleccionado.
</p>

<h3>Uso de la ventana del editor de repertorio</h3>
<p>
El lado <b>izquierdo</b> de la ventana muestra la estructura del repertorio. Puedes pinchar en los iconos de carpetas para expandir o colapsar los grupos, y pinchar en los movimientos de un grupo o línea para seleccionarla y ver sus comentarios. Las líneas incluidas se muestran con una marca azul, y las excluidas con una cruz roja.
</p>
<p>
Si una línea o grupo tiene un comentario corto este se mostrará después de los movimientos. Si tiene un comentario largo se indica con la marca <b><red>**</red></b> después de los movimientos. Los grupos tienen un número entre paréntesis después de sus movimientos que muestra el número de líneas (directas o indirectas) que contiene.
</p>
<p>
Pinchando con el botón derecho del ratón en un grupo o línea aparece un menú con funciones para él, como su borrado o el cambio de su estado.
</p>
<p>
El lado <b>derecho</b> de la ventana contiene tres marcos. El primer marco es una lista de los movimientos de la línea o grupo seleccionado. Puedes pinchar con el botón izquierdo del ratón en él para pegar los movimientos en la ventana de <a Import>Importar</a>, lo cual es útil para hacer que la partida actual empiece con una línea del repertorio. El segundo marco contiene el comentario corto de la línea o grupo, y el tercer marco contiene el comentario largo.
</p>

<h3>Añadir grupos y líneas al repertorio</h3>
<p>
Para añadir una línea o grupo en la ventana, simplemente haz sus movimientos en el tablero de ajedrez de la ventana principal, entonces usa el menú <menu>Editar</menu> del editor de repertorio para añadirlo como un grupo, una línea incluida o una línea excluida.
</p>
<p>
Para borrar un grupo o línea pínchala con el botón derecho del ratón y selecciona la orden apropiada en el menú que aparece.
</p>

<h3><name Search>Búsquedas en bases de datos usando archivos de repertorio</name></h3>
<p>
El menú <menu>Buscar</menu> del editor de repertorio permite buscar en la base de datos actual usando el repertorio. Cada partida será buscada para posiciones del repertorio y será mostrada sólo si la posición del repertorio de <i>mayor profundidad</i>es de una línea <i>incluida<i>.
</p>
<p>
Puedes escojer entre buscar usando todo el repertorio, o sólo las líneas mostradas. La búsqueda de las líneas mostradas es útil cuando sólo necesitas usar algunas del repertorio. Por ejemplo, un repertorio para las Negras puede tener dos grupos principales en el nivel superior, uno para 1.e4 y otro para 1.d4. Si sólo estas interesado en 1.e4, simplemente colapsa el grupo 1.d4 y entonces busca sólo para las líneas mostradas.
</p>

<h3>Otras Sugerencias</h3>
<p>
Un archivo de repertorio es muy útil para encontrar nuevas partidas con tus maneras de realizar las aperturas. Por ejemplo, cada vez que tengas un nuevo archivo PGN para añadir a tu base de datos principal (como el excelente archivo PGN semanal de <url http://www.chesscenter.com/twic/>The Week In Chess</url>), simplemente abre el archivo PGN con Scid y haz una búsqueda de repertorio. Entonces buscar entre las partidas filtradas para ver todas las partidas jugadas que están en tu repertorio.
</p>
<p>
Es una buena idea mantener dos archivos de repertorio: uno para las Negras y otro para las Blancas, para poder buscar en cada archivo separadamente.
</p>
<p>
Desde la línea de comandos puede abrirse un archivo de repertorio, por ejemplo: <br>
<b>scid mibase blancas.sor</b>
</p>
<p>
Puedes editar un archivo de repertorio (.sor) en cualquier editor de texto, pero ten cuidado en preservar su formato pues podría no poder cargarse o buscarse en él con Scid.
</p>

<p><footer>(Actualizado: Scid 2.6, Agosto 2001)</footer></p>
}

####################
### Tree window help:

set helpTitle(S,Tree) "Ventana de Árbol"
set helpText(S,Tree) {<h1>La ventana de Árbol</h1>
<p>
La ventana de <term>Árbol</term> muestra información sobre todos los movimientos hechos desde la posición actual en las partidas de la base de datos. En modo árbol, la ventana de árbol es actualizada automáticamente cada vez que el tablero de la ventana principal cambia. Esto puede ser lento para bases de datos grandes.
</p>
<p>
Fíjate que cada vez que la ventana de árbol es actualizada el <a Searches Filter>filtro</a> es restaurado y sólo las partidas que tienen la posición actual son incluidas en él.
</p>
<p>
Apretando el botón izquierdo del ratón sobre un movimiento en la ventana de árbol este se añade a la partida.
</p>

<h3>Contenidos de la ventana de Árbol</h3>
<p>
La ventana de árbol muestra el <a ECO>código ECO</a> (si hay alguno), frecuencia (en número de partidas, y en porcentajes) y la puntuación para cada movimiento. La <term>puntuación</term> siempre es calculada desde la perspectiva de las blancas, por lo que 100% significa que las blancas siempre han ganado y 0% que las negras siempre han ganado.
</p>
<p>
Los movimientos en la ventana de árbol pueden ser ordenados por el movimiento en si (alfabéticamente), código ECO, frecuencia, o puntuación. Puedes cambiar el método de ordenación en el menú <menu>Ordenar</menu>.
</p>

<h3><name Graph>Ventana gráfica del árbol</name></h3>
<p>
La ventana de árbol incluye un botón denominado <term>Gráfico</term> el cual muestra un gráfico producido a partir de la ejecución relativa, porcentajes, de cada movimiento en la posición actual. Son mostrados todos los movimientos que han sido jugados al menos un 1% de las veces, y al menos 5 veces. Los porcentajes son siempre desde la perspectiva de las blancas, incluso cuando son las negras las que mueven.
</p>
<p>
Una línea roja muestra en el gráfico del árbol el término medio de todas las partidas según la posición actual, y se muestra el área entre el 50 y 55% (donde se espera que puntúen la mayoría de las aperturas estándar) en color azul para ayudar a la comparación de los movimientos. Advierte que las blancas normalmente puntúan en torno a 55% en el ajedrez a nivel maestro.
</p>

<h3><name Lock>Bloqueo de la ventana de árbol</name></h3>
<p>
El botón <term>Bloquear</term> de la ventana de árbol puede ser usado para bloquear el árbol en la actual base de datos. De esta manera el árbol continuará usando esa base de datos aunque cambies a otra base de datos abierta. Esto es útil si necesitas usar una gran base de datos como referencia mientras juegas a traves de una partida en otra base de datos: simplemente abre el árbol en la base de datos de referencia, bloquéalo, y entonces cambia a la otra base.
</p>

<h3><name Training>Entrenamiento</name></h3>
<p>
Cuando se selecciona <term>Entrenamiento</term> en la ventana de árbol Scid hace un movimiento aleatoriamente cada vez que añades un movimiento a la partida. El movimiento que escoge Scid depende de las estadísticas de la base de datos, un movimiento jugado en el 80% de las partidas de la base de datos será escogido por Scid con una probabilidad del 80%. Es un buen sistema de probar tu conocimiento sobre aperturas: activa esta característica, esconde (o minimiza)  la ventana de árbol y juega aperturas contra una base de datos de gran extensión.
</p>

<h3>Uso del Árbol con archivos de Posición abiertos</h3>
<p>
Para cada <a EPD>archivo de Posición</a> abierto, la ventana de árbol contendrá una columna extra que muestra un corto resumen (cinco caracteres) del contenido del libro de posiciones para cada posición alcanzada desde los movimientos enumerados.
</p>
<p>
El resumen puede ser una valoración, un código de apertura o un movimiento sugerido; será el contenido del primer campo EPD encontrado de la siguiente lista: <b>ce, eco, nic, pv, pm, bm, id</b>, o simplemente el primer campo EPD si no se encuentra ninguno de los citados antes.
</p>
<p>
Para obtener una descripción de los campos EPD ver la página de ayuda de los <a EPD>archivos de Posición</a>. Date cuenta que si el resumen es del campo <b>ce</b>, este es mostrado como una evaluación en peones desde la perspectiva de las Blancas (en vez de como centésimas de peón desde la perspectiva del lado que mueve; que es el formato en los archivos de posición) para así aumentar su legibilidad.
</p>

<h3>Caché para unos resultados más rápidos</h3>
<p>
Scid mantiene una caché de los resultados de la búsqueda de árbol para las posiciones más usuales en las partidas. Si mueves hacia adelante o atrás en una partida en el modo de árbol, verás la ventana de árbol actualizada casi instantáneamente cuando la posición buscada está en la caché.
</p>
<p>
La ventana de árbol tiene un comando llamado <term>Guardar archivo Caché</term> en el menú archivo. Cuando lo seleccionas, se escriben los contenidos actuales de la caché que hay en la memoria a un archivo (con el sufijo <b>.stc</b>) para, en el futuro, aumentar la velocidad de uso del Árbol con esta base de datos.
</p>
<p>
Date cuenta que un archivo de caché del árbol (.stc) es totalmente repetitivo; puedes borrarlo sin afectar a la base de datos, y de hecho este es borrado por Scid cada vez que ocurre una acción que pueda dejarlo anticuado -- por ejemplo, al añadir o reemplazar una partida, u ordenar la base de datos.
</p>

<p><footer>(Actualizado: Scid 2.6, Agosto 2001)</footer></p>
}

####################
### Compaction help:

set helpTitle(S,Compact) "Compactación de la base de datos"
set helpText(S,Compact) {<h1>Compactación de la base de datos</h1>
<p>
<term>Compactación</term> de la base de datos es un tipo específico de <a Maintenance>mantenimiento</a> que hace una base de datos tan pequeña y eficiente como sea posible.
El compactar una base de datos significa que se borra cualquier espacio no utilizado en los archivos. Hay dos tipos: compactación del archivo de nombres y del archivo de partidas.
</p>

<h3>Compactación del archivo de nombres</h3>
<p>
Muchas veces puedes encontrar una base de datos que contiene una serie de nombres de jugadores, eventos, lugares o rondas que no son usados en ninguna partida. Esto amenudo sucede después de que compruebes ortográficamente los nombres. Los nombres no usados desaprovechan espacio en el archivo de nombres, y pueden enlentecer las búsquedas por nombres. La compactación del archivo de nombres borra todos los nombres que no son usados en ninguna partida.
</p>

<h3>Compactación del archivo de partidas</h3>
<p>
Siempre que una partida es reemplazada o borrada queda información no utilizada en el archivo de partidas (el más grande de los tres archivos de base de datos de Scid). La compactación del archivo de partidas elimina todo el espacio desaprovechado, quedando en la base de datos las partidas no borradas. Ten en cuenta que esta operación es irreversible: ¡después de la compactación, las partidas borradas se pierden para siempre!
</p>
<p>
La compactación del archivo de partidas también se aconseja después de <a Sorting>ordenar</a> una base de datos, para mantener el orden de las partidas de manera coherente con el archivo índice que se a ordenado.
</p>

<p><footer>(Actualizado: Scid 2.5, Junio 2001)</footer></p>
}

####################
### Database maintenance tools help:

set helpTitle(S,Maintenance) "Mantenimiento de la base de datos"
set helpText(S,Maintenance) {<h1>Mantenimiento de la base de datos</h1>
<p>
Scid proporciona una serie de herramientas para el mantenimiento de las bases de datos, accesibles desde el menú de Scid <a Menus File>Archivo</a>. Las funciones de base de datos <a Compact>compactar</a> and <a Sorting>ordenar</a> son explicadas en páginas de ayuda separadas.
</p>

<NEW>
<h3>Maintenance window</h3>
<p>
Most Scid database maintenance can be done from the Maintenance
window, which can be opened from the <menu>File: Maintenance</menu>
or <menu>Windows</menu> menus or the shortcut key <b>Ctrl+M</b>.
</p>
<p>
You can use this window to maintain <a Flags>game flags</a>,
spellcheck names, <a Compact>compact</a> or <a Sorting>sort</a>
a database. Note that any operations that are not available
for the current database (for example, because it may be read-only
or a PGN file) will be greyed out.
</p>
</NEW>

<h3><name Twins>Borrado de partidas dobles</name></h3>
<p>
El menú <menu>Archivo: Mantenimiento</menu> tiene el comando
<menu>Borrar partidas dobles...</menu> para detectar copias extra (dobles) de partidas en la base de datos. Este comando encuentra todos los pares de partidas que son dobles y, por cada par, señala la partida mas corta como borrada, dejando la más larga sin borrar. Dos partidas son consideradas como dobles si sus jugadores (y cualquier otra etiqueta que puedes opcionalmente especificar) están emparejados exactamente.
</p>
<p>
Si especificas la opción los "mismos movimientos", cada par de partidas debe tener los mismos movimientos hasta la longitud de la partida más corta (o hasta alcanzar el movimiento 40, lo primero que ocurra) para ser dobles.
</p>
<p>
Cuando tienes partidas dobles borradas, es una buena idea comprobar que cada partida borrada es realmente una copia de otra. Puedes hacer esto fácilmente si seleccionas la opción "<b>Poner filtro a todas las partidas borradas</b>" en la caja de diálogo borrar dobles. Entonces el filtro contendrá todas las partidas borradas. Puedes mirar a través de ellas (usando las teclas <b>p</b> y <b>n</b>) con la ventana <term>comprobador de dobles</term> (disponible desde el menú de mantenimiento, o la combinación de teclas <b>Ctrl+Shift+T</b>) para verificar que cada partida a sido borrada porque es doble de otra.
</p>

<h3><name Editing>Edición de nombres de jugadores, eventos, sitios y rondas</name></h3>
<p>
Puedes encontrar incorrecciones en los nombres de tu base de datos, las cuales puedes querer corregir. Puedes hacer esto en Scid con la ventana <term>Edición de nombres</term> (combinación de teclas: <b>Control+Shift+N</b>), disponible en el submenú <menu>Archivo: Mantenimiento</menu>.
</p>
<p>
Cada nombre es almacenado sólo una vez en el archivo de nombres, por lo que cambiando un nombre realmente cambias todas sus ocurrencias.
</p>

<h3><name Spellcheck>Corrección ortográfica de nombres</name></h3>
<p>
Scid viene con un archivo de <term>corrección ortográfica</term> llamado <b>spelling.ssp</b>, para la corrección de los nombres de jugadores, eventos, sitios y rondas. Scid intentará cargar el archivo de corrección ortográfica siempre que se inicie; si este no se carga, puedes cargarlo desde el menú <menu>Opciones</menu>.
</p>
<p>
Una vez que el archivo de corrección ortográfica es cargado, puedes usarlo en una base de datos Scid mediante los comandos del menú <menu>Archivo: Mantenimiento</menu>, o desde la ventana de mantenimiento.
</p>
<p>
Cuando corriges la ortografía de una base de datos, Scid produce una lista de correcciones que puedes editar antes de que realmente hagas alguna corrección, de esta manera puedes quitar cualquier corrección que no quieras que se realice.
</p>
<p>
La corrección ortográfica es especialmente útil para estandarizar una base de datos para que todos los ejemplos de un jugador en particular sean escritos de la misma manera. Por ejemplo, con el archivo de corrección ortográfica estándar, los nombres "Kramnik,V.", "Vladimir Kramnik", y "V. Kramnik" serán todos corregidos a "Kramnik, Vladimir".
</p>
<p>
El archivo de corrección ortográfica tiene un uso adicional: cuando es cargado, sus datos de jugadores son usados para enriquecer la ventana <a PInfo>información de los jugadores</a> y la ventana de <a Crosstable>tabla cruzada</a>: podrás ver los títulos de los maestros de la FIDE (<b>gm</b> = Gran Maestro Internacional, <b>im</b> = Maestro Internacional, etc) y la información del país de cualquier jugador que este listado en el archivo de corrección ortográfica. Más de 5000 grandes jugadores del pasado y el presente están listados en el archivo <b>spelling.ssp</b> que viene con Scid.
</p>

<h3><name Ratings>Añadiendo clasificación Elo a las partidas</name></h3>
<p>
El botón "Añadir clasificación Elo..." de la ventana de mantenimiento hace que Scid busque en la base de datos activa partidas en las que un jugador no tiene clasificación Elo, pero que en el archivo de corrección ortográfica tiene almacenada la clasificación Elo de ese jugador para la fecha en la que se jugó esa partida.
Scid añadirá todo este tipo de puntuaciones Elo automáticamente. Esto es muy útil para una base de datos con partidas de maestros en las que se encuentran pocas puntuaciones Elo.
</p>
<p>
El archivo de corrección ortográfica "spelling.ssp" que viene con Scid no contiene la información sobre el Elo necesaria para esta función, pero se encuentra disponible en el <a Author>sitio web de Scid</a> una versión de ella llamada "ratings.ssp".
</p>

<h3><name Cleaner>La MultiHerramienta</name></h3>
<p>
La  <term>MultiHerramienta</term> de Scid (disponible desde la ventana de Mantenimiento) es una herramienta para hacer una serie de tareas de mantenimiento en una base de datos en una sola acción. Puedes escoger que tareas deseas hacer, y Scid las ejecutará en la actual bases de datos sin requerir la interacción del usuario. Esto es especialmente útil para el mantenimiento de grandes bases de datos.

<p><footer>(Actualizado: Scid 3.0, Noviembre 2001)</footer></p>
}

####################
### Sorting help:

set helpTitle(S,Sorting) "Ordenar una base de datos"
set helpText(S,Sorting) {<h1>Ordenar una base de datos</h1>
<p>
La función <term>ordenar</term> clasifica todas las partidas en una base de datos. Puedes seleccionar una serie de criterios de ordenación. Cuando dos partidas son iguales según el primer criterio, son ordenadas usando el segundo criterio y así sucesivamente.
</p>

<h3>Criterios de ordenación</h3>
<p>
Los criterios de ordenación disponibles son:
</p>
<ul>
<li> Fecha (las partidas más antiguas primero) </li>
<li> Año (igual que fecha, pero usando sólo el año) </li>
<li> Nombre del evento </li>
<li> Nombre del lugar </li>
<li> Nación (las últimas 3 letras del nombre del lugar) </li>
<li> Nombre de la ronda </li>
<li> Nombre de las blancas </li>
<li> Elo (media del Elo de las blancas y las negras, el más alto primero) </li>
<li> Nombre de las negras </li>
<li> Resultado (primero blancas ganan, luego tablas y luego negras ganan) </li>
<li> Longitud (número total de movimientos de una partida) </li>
<li> ECO (el <a ECO>código de la Encycolpedia of Chess Openings</a>) </li>
</ul>

<h3>Resultados de la ordenación</h3>
<p>
Cuando ordenas una base de datos Scid que no es de sólo lectura, el resultado de la ordenación es guardado, por lo que el orden de las partidas en la base de datos cambia de manera permanente. Si quieres que el resultado de la ordenación sea temporal, haz primero que la base de datos sea de sólo lectura usando el comando del menú <b>Archivo: Sólo lectura</b>.
</p>
<p>
Cuando ordenas una base de datos que es de sólo lectura o que es un archivo PGN, el resultado de la ordenación no puede ser guardado por lo que el orden de las partidas se pierde cuando se cierra el archivo.
</p>
<p>
Ten encuenta que la ordenación de una base de datos anula el <a Searches Filter>filtro de búsqueda</a> para así contener todas las partidas.
</p>

<h3>Nota importante sobre la ordenación de bases de datos:</h3>
<p>
Cuando una base de datos es ordenada, se altera el archivo del índice, pero el archivo de partidas permanece inalterado. Esto significa que ordenando una base de datos el registro del archivo de partidas se queda desordenado en relación con el archivo del índice. Esto puede <b>enlentecer</b> el <a Tree>árbol</a>, las <a Searches>búsquedas</a> por posición y por material/modelo, por lo que deberías de reordenar el archivo de partidas mediante la <a Compact>compactación</a> después de la ordenación para así mantener el buen rendimiento de la búsqueda.
</p>

<p><footer>(Actualizado: Scid 2.5, Junio 2001)</footer></p>
}

####################
### Flags help:

set helpTitle(S,Flags) "Game Flags"
set helpText(S,Flags) {<h1>Game Flags</h1>

<p>
A <term>flag</term> is an indicator of some chess characteristic
that can be turned on or off for each game in the database.
There are 13 user-settable flags that you can directly set for
each game. Of these, only the Delete flag has any special
significance: games with the Delete flag turned on are marked
for deletion and will removed when the database is
<a Compact>compacted</a>.
</p>
<p>
The other 12 user-settable flags and their symbols are:
</p>

<ul>
<li>White opening (W)</li>
<li>Black opening (B)</li>
<li>Middlegame (M)</li>
<li>Endgame (E)</li>
<li>Novelty (N)</li>
<li>Pawn structure (P)</li>
<li>Tactics (T)</li>
<li>Queenside play (Q)</li>
<li>Kingside play (K)</li>
<li>Brilliancy (!)</li>
<li>Blunder (?)</li>
<li>User-defined (U)</li>
</ul>

<p>
A flag can be set for the current game, all filter games, or all
database games using the <a Maintenance>maintenance</a> window.
</p>
<p>
You can use a <a Searches Header>header search</a> to find all
games in a database that have a particular flag turned on or off,
or use flags as part of more complex searches.
</p>
<p>
Since all the user-settable flags (except the Delete flag) have
no significance to Scid, you can use them for any purpose that
suits your needs. For example, you could use the Kingside (K)
flag for kingside pawn storms, or kingside heavy piece attacks,
or even for endgames with all pawns on the kingside.
</p>

<p><footer>(Actualizado: Scid 3.0, Noviembre 2001)</footer></p>
}

####################
### Analysis window help:

set helpTitle(S,Analysis) "Ventana de Análisis"
set helpText(S,Analysis) {<h1>La ventana de Análisis</h1>
<p>
La ventana de análisis de Scid muestra el análisis que realiza un programa de ajedrez de la posición actual del tablero. Cada vez que el tablero cambia, Scid manda la nueva posición al programa de análisis.
</p>
<p>
La puntuación mostrada en la ventana de análisis es siempre desde la perspectiva de las blancas, por lo que una puntuación negativa indica que las negras están mejor.
</p>

<h3>Añadir el análisis a la partida</h3>
<p>
El botón <term>Añadir a comentario</term> en la ventana de análisis añade la puntuación y la mejor línea de juego actual al comentario del movimiento en la partida.
</p>
<p>
Puedes hacer esto automáticamente para una serie de movimientos anotando la partida, iniciando el <a MainWindow Autoplay>modo de automovimiento</a>.
Cuando se usa el modo de automovimiento, y la ventana de análisis está abierta, se añade automáticamente un comentario que contiene la puntuación y la mejor línea de juego de cada posición de la partida por la que pasa el modo de automovimiento. Sólo son anotadas las posiciones desde la actual hasta el final de la partida (o hasta salir del modo de automovimiento), por lo que puedes omitir la anotación de los movimientos de la apertura yendo a una posición media de la partida antes de iniciar el modo de automovimiento.
</p>
<p>
Puedes incrementar el tiempo de demora entre movimientos para aumentar la calidad del análisis desde el menú <menu>Opciones: Movimientos</menu>.
</p>
<p>
Para cancelar la anotación en cualquier momento, sólo desactiva el modo de automovimiento; por ejemplo presionando la tecla de escape en la ventana principal.
</p>

<h3>Detalles de la interconexión</h3>
<p>
Para usar la ventana de análisis necesitarás un programa de ajedrez que soporte los comandos estándar de <term>Xboard</term>. En concreto, Scid envía los comandos <b>xboard</b> y <b>post</b> al programa cuando este se inicia.
</p>
<p>
Si Scid distingue a "Crafty" al principio de una línea de salida del programa de ajedrez usará los comandos específicos de crafty, tales como <b>setboard</b> para actualizar cada posición.
</p>
<p>
Para todos los demás programas, Scid manda los siguientes comandos cada vez que la posición cambia:  <b>new</b> y <b>force</b>, luego los movimientos de la partida en la posición actual, y después <b>go</b>.
</p>
<p>
El excelente programa gratuito de Bob Hyatt <term>crafty</term> es el que yo uso y recomiendo para la ventana de análisis de Scid, pero yo también he usado otros programas exitosamente con Scid, como son Phalanx y Gnuchess.
</p>
<p>
Crafty puede ser descargado de: <br>
<url ftp://ftp.cis.uab.edu/pub/hyatt/>ftp://ftp.cis.uab.edu/pub/hyatt/</url>
</p>
<p>
Gnuchess está disponible: <br>
<url http://www.gnu.org/software/chess/chess.html>http://www.gnu.org/software/chess/chess.html</url>
</p>
<p>
El sitio de descarga de Phalanx es: <br>
<url ftp://ftp.math.muni.cz/pub/math/people/Dobes/>ftp://ftp.math.muni.cz/pub/math/people/Dobes/</url>
</p>

<p><footer>(Actualizado: Scid 2.5, Junio 2001)</footer></p>
}

####################
### EPD files help:

set helpTitle(S,EPD) "Archivos de posiciones"
set helpText(S,EPD) {<h1>Archivos posiciones</h1>
<p>
Un archivo de posiciones Scid (extensión ".epd") es simplemente una colección de posiciones, en el que cada posición tiene cierto texto asociado. Las antiguas versiones de Scid usaban un formato especial (extensión ".sbk") para los archivos de posiciones, pero desde la versión 1.6 Scid usa el formato estándar de archivos <term>EPD</term> (extended position description).
</p>
<p>
Un archivo EPD tiene un número definido de <term>opcodes</term> (campos), los cuales son almacenados separados por punto y coma (<b>;</b>) en el archivo, pero son mostrados en distintas líneas en la ventana de archivos de posiciones de Scid para facilitar su edición. Un punto y coma dentro de un campo EPD es almacenado por Scid como "<b>\s</b>" para distinguirlo de una marca de fin de campo. Cada posición y sus opcodes son almacenados en una línea en el archivo EPD.
</p>
<p>
Los opcodes EPD estándar incluyen:
<ul>
<li> <b>acd</b> Recuento de análisis: profundidad de búsqueda.</li>
<li> <b>acn</b> Recuento de análisis: número de nodos buscados.</li>
<li> <b>acs</b> Recuento de análisis: tiempo de búsqueda en segundos.</li>
<li> <b>bm</b> Mejores movimientos: movimiento(s) que se ha juzgado como mejor por alguna razón.</li>
<li> <b>ce</b> Evaluación en centésimas de peón: evaluación en centésimas de peón desde la perspectiva del <b>lado que mueve</b> -- date cuenta que esto difiere de la ventana de análisis, la cual muestra las evaluaciones en peones desde la perspectiva de las blancas. </li>
<li> <b>cX</b> Comentario (donde <b>X</b> es un número, 0-9).</li>
<li> <b>eco</b> Código del sistema de aperturas <a ECO>ECO</a>.</li>
<li> <b>id</b> Única Identificación para esta posición.</li>
<li> <b>nic</b> Código del sistema de aperturas <i>New In Chess</i>.</li>
<li> <b>pm</b> Movimiento previsto: el primer movimiento de la PV (variación prevista).</li>
<li> <b>pv</b> Variación prevista: la línea con mejor juego.</li>
</ul>

<p>
Los archivos de posiciones tienen distintos usos: Scid usa un archivo de posiciones para clasificar las partidas según el sistema de la <a ECO>Encyclopaedia of Chess Openings</a> (ECO), y tu puedes hacer un archivo de posiciones para tu repertorio de aperturas, añadiendo comentarios en las posiciones que alcanzas asiduamente en las partidas.
</p>
<p>
Puedes crear un nuevo archivo de posiciones o abrir uno desde el submenú
<menu>Archivo de posiciones</menu> del menú <menu>Archivo</menu>. Como máximo se pueden abrir cuatro archivos de posiciones al mismo tiempo.
</p>

<h3>Ventanas de posiciones</h3>
<p>
Para cada archivo de posiciones abierto se muestra una ventana que muestra el texto de la posición actual. No necesitas apretar el botón Almacenar para guardar los cambios hechos en el texto de una posición; el texto será almacenado cada vez que te muevas a una nueva posición de la partida.
</p>

<h3>Navegando por los archivos de posición</h3>
<p>
Para moverte a través de las posiciones usa los comandos <menu>Siguiente posición</menu> y <menu>Posición anterior</menu> del menú <menu>Herramientas</menu> de la ventana de posiciones, o usa las combinaciones de teclas <b>Ctrl+Flecha abajo</b> y <b>Ctrl+Flecha arriba</b>. Estos comandos mueven a la siguiente/anterior posición del archivo, quitando de en medio la partida actual y colocando su posición de inicio.
</p>

<h3>Eliminando campos EPD</h3>
<p>
Los archivos EPD que encuentras en internet pueden contener campos que no te interesan, los cuales pueden consumir gran cantidad de espacio en un archivo. Por ejemplo, un archivo EPD de evaluación de ordenadores puede tener los campos ce, acd, acn, pm, pv e id pero tu puedes necesitar tan sólo los campos ce y pv.
</p>
<p>
Puedes eliminar un opcode EPD de todas las posiciones del archivo usando <menu>Eliminar campos EPD</menu> desde el menú <menu>Herramientas</menu> de la ventana de posiciones.
</p>

<h3>La barra de estado de la ventana de posiciones</h3>
<p>
La barra de estado de cada ventana de posiciones muestra:
<ul>
<li>- el estado del archivo (<b>--</b> significa sin cambios, <b>XX</b> significa cambiado, y <b>%%</b> significa sólo lectura); </li>
<li>- el nombre del archivo; </li>
<li>- el número de posiciones del archivo; </li>
<li>- movimientos legales desde la posición actual que alcanzan otra posición de este archivo de posiciones.</li>
</ul>

<p><footer>(Actualizado: Scid 2.5, Junio 2001)</footer></p>
}

######################
### Email window help:

set helpTitle(S,Email) "Ventana de Email"
set helpText(S,Email) {<h1>Ventana de Email</h1>
<p>
La ventana de administración de emails te proporciona una manera para manejar
las partidas de ajedrez por correspondencia jugadas por email. Si no juegas
partidas de ajedrez por email esto no será de interés para ti. ¡Pero si juegas
al ajedrez mediante emails puedes mandar tus mensajes directamente desde Scid!
</p>
<p>
No olvides que el administrador de emails está actualmente solo disponible para
Scid en plataformas Unix/Linux. No está disponible para usuarios de Windows.
</p>
<p>
Para usar el administrador de emails:
<ul>
<li><b>1)</b> Crear la(s) partidas(s) para tu oponente en la base de datos.
</li>
<li><b>2)</b> En la ventana del administrador de email selecciona <b>Añadir</b>
e ingresa los detalles de tu oponente: nombre, dirección de email, y los números
de partida en la base de datos. </li>
<li><b>3)</b> Selecciona <b>Enviar email</b> en la ventana de email cada vez que
hayas añadido movimientos a la(s) partida(s) y quieras enviar un mensaje. </li>
</ul>

<p>
Cuando envías un mensaje de email, Scid crea el mensaje con las partidas en
formato PGN <b>sin</b> ningún comentario, anotación o variación, dado que
habitualmente tu no debes querer que tu oponente vea tus análisis. Puedes editar
el mensaje antes de enviarlo para añadir movimientos potenciales u otro texto.
</p>
<p>
Para cada oponente puedes tener cualquier número de partidas; una o dos es lo
más común. Advierte que Scid no comprueba si los números de partida cambian, así
que después de introducir los datos de tu oponente debes ser cuidadoso para
evitar borrar partidas u ordenar tu base de datos de partidas de email, puesto
que esto reubicaría las partidas, siendo el número de las partidas de cada
oponente incorrecto.
</p>

<h3>Limitaciones</h3>
<p>
Scid no tiene todavía ninguna capacidad para consultar tu carpeta de email, por lo que todavía necesitas añadir los movimientos de tu oponente a las partidas manualmente.
</p>

<h3>Configuración</h3>
<p>
Una copia de cada mensaje de email es guardada por Scid en el archivo <b>.scid_sent_emails</b> en tu directorio "home". Si deseas que sean guardados en un archivo diferente tendrás que editar el archivo <b>tcl/start.tcl</b> y recompilar Scid.
</p>
<p>
Para usar el administrador de email tienes que tener instalado en tu sistema
<term>sendmail</term>; muchos sistemas Unix/Linux usan <term>sendmail</term> para enviar los mensajes de email. Si tu programa sendmail no tiene la ruta <b>/usr/lib/sendmail</b> tendrás que editar <b>tcl/start.tcl</b> y recompilar Scid. La siguiente localización más común de sendmail es <b>/usr/sbin/sendmail</b>.
</p>
<p>
Scid guarda los detalles del oponente de una base de datos en un archivo con el mismo nombre que la base de datos con el sufijo "<b>.sem</b>".
</p>

<p><footer>(Actualizado: Scid 2.6, Agosto 2001)</footer></p>
}

####################
### Opening Report help:

set helpTitle(S,OpReport) "Informe de la Apertura"
set helpText(S,OpReport) {<h1>Informe de la Apertura</h1>
<p>
Scid puede generar un <term>informe de la apertura</term> que muestra datos interesantes sobre una apertura. Para producir un informe de la apertura, primero asegúrate que se muestra la posición de la cual quieres el informe, entonces selecciona <b>Informe de la Apertura</b> en el menú <b>Herramientas</b>.
</p>
<p>
La ventana del <term>Informe de la Apertura</term> muestra el resultado del informe producido por Scid. El menú <b>Archivo</b> tiene comandos para guardar el informe en archivos de texto sin formato, HTML o en formato <a LaTeX>LaTeX</a>.
</p>
<p>
Las primeras secciones del informe muestran información sobre las partidas que llegan hasta la posición del informe, y los movimientos realizados desde esa posición. Puedes ver si la apertura se está haciendo más popular, si tiene muchas tablas de corta duración, y que orden de movimientos (transposiciones)
se han usado para llegar a esa posición.
<p>
La parte última, y más larga, es la tabla teórica. Cuando guardes el informe en un archivo puedes escoger entre guardar sólo la tabla teórica, un informe compacto sin la tabla teórica o la totalidad del informe.

<h3>Límites</h3>
<p>
Hay un límite de 2000 partidas para la mayoría de los datos generados por el informe, así que si el informe de la posición tiene lugar en más de 2000 partidas algunos resultados pueden ser ligeramente incorrectos.
</p>
<p>
Además, hay un límite de 500 partidas para la tabla ECO. Si la posición del informe tiene lugar en más de 500 partidas sólo las 500 partidas con el mayor promedio de clasificación Elo serán utilizadas para producir la tabla ECO.
</p>

<h3>Exhibición preliminar LaTeX</h3>
<p>
El botón <b>Exhibición preliminar LaTeX</b> en la esquina inferior izquierda de la ventana del informe (no disponible en las versiones Windows) guarda el informe como un archivo temporal de formato LaTeX; pon a funcionar <b>latex</b> en él, y ejecuta <b>xdvi</b> para visualizar los resultados. Esto <b>sólo</b> funcionará si tienes latex, xdvi y todos los paquetes latex necesarios instalados en tu ordenador; ver la página de ayuda <a LaTeX>Usando LaTeX con Scid</a>.
</p>

<p><footer>(Actualizado: Scid 2.5, Junio 2001)</footer></p>
}

####################
### Player Info help:

set helpTitle(S,PInfo) "Ventana de Información del Jugador"
set helpText(S,PInfo) {<h1>La ventana de Información del Jugador</h1>
<p>
La ventana <term>Información del Jugador</term> es producida o actualizada cada vez que aprietas el botón izquierdo en el área de información (debajo del tablero) o en la ventan de <a Crosstable>tabla cruzada</a> sobre el nombre de un jugador.
</p>
<p>
Muestra (optimístamente) información de utilidad sobre el jugador, incluyendo sus éxitos con blancas y negras, aperturas favoritas (según <a ECO>códigos ECO</a>),
y la historia de su Elo.
</p>
<p>
Todos los porcentajes mostrados son una puntuación esperada (índice de acierto), desde la perspectiva del jugador -- por lo que cuanto más altos son mejor es para el jugador, tanto si juega con blancas como si lo hace con negras.
</p>
<p>
Puedes ver la historia del Elo de un jugador en un gráfico presionando el botón
<a Graphs Rating>Gráfico Elo</a>.
</p>
<p>
Cualquier número impreso en rojo puede se apretado con el botón izquierdo del ratón para poner las partidas que representa en el <a Searches Filter>filtro</a>.
</p>

<p><footer>(Actualizado: Scid 2.5, Junio 2001)</footer></p>
}

####################
### Graphs help:

set helpTitle(S,Graphs) "Ventanas de gráficos"
set helpText(S,Graphs) {<h1>Ventanas de gráficos</h1>
<p>
Scid tiene una serie de ventanas que muestran información de manera gráfica. Estas son explicadas a continuación.
</p>

<h3><name Rating>Ventana del Gráfico Elo</name></h3>
<p>
La ventana del <term>Gráfico Elo</term> muestra la historia del Elo de un jugador o de los dos jugadores de la partida actual. Puedes producir el gráfico para un único jugador presionando el botón <b>Gráfico Elo</b> en la ventana <a PInfo>información del jugador</a>, o generarlo para los dos jugadores de la partida actual seleccionando <b>Gráfico Elo</b> en el menú <menu>Herramientas</menu>.
</p>

<h3><name Score>Ventana del Gráfico de Puntuación</name></h3>
<p>
La ventana del <term>Gráfico de Puntuación</term> muestra la evaluación numérica (puntuación) almacenada en los comentarios de la actual partida en forma gráfica. Puedes apretar el botón izquierdo del ratón en cualquier parte del gráfico de puntuación para ir a la posición correspondiente de la partida.
</p>
<p>
Son reconocidos dos tipos de comentarios de evaluación: aquellos producidos por la ventana de <a Analysis>análisis</a> de Scid (que tienen el formato
<ul>
<li><b>1.e4 {"+0.25 ...."}</b></li>
</ul>
y son siempre puntuados desde la perspectiva de las blancas) y aquellos por el comando anotar de Crafty (el cual tiene el formato
<ul>
<li><b>1.e4 ({9:+0.25} ....)</b></li>
</ul>
y son puntuados desde la perspectiva de las blancas).
</p>

<h3><name Tree>Ventana del Gráfico de Árbol</name></h3>
<p>
La ventana del <term>Gráfico de Árbol</term> esta disponible desde la ventana de árbol. Muestra el rendimiento de los movimientos más usuales desde la posición actual. Hay más información disponible sobre esto en la página de ayuda del <a Tree Graph>Árbol</a>.
</p>

<p><footer>(Actualizado: Scid 2.5, Junio 2001)</footer></p>
}

####################
### Tablebases help:

set helpTitle(S,TB) "Tablebases"
set helpText(S,TB) {<h1>Tablebases</h1>

<p>
Una <term>tablebase</term> es un archivo que contiene la información de un resultado perfecto de todas las posiciones con una distribución de material concreta, como Rey y Torre contra Rey y Peón. Se han realizado tablebases de situaciones con material de hasta cinco piezas (incluidos los reyes), y algunas tablebases simples para seis piezas también están disponibles.
</p>
<p>
Scid puede usar tablebases en formato Nalimov, formato que es usado por muchos motores de ajedrez modernos. Estos amenudo terminan con el sufijo <b>.nbw.emd</b> o <b>.nbb.emd</b>.
</p>

<h3>Uso de las tablebases en Scid</h3>
<p>
Para usar un directorio de archivos de tablebase en Scid, simplemente ubica el directorio seleccionando <b>Directorio de las TB...</b> en el menú <menu>Opciones</menu>.
</p>
<p>
Cuando se encuentra una posición que se encuentra en un archivo de tablebase, el área de información de la partida (debajo del tablero de ajedrez) muestra información de la tablebase. Puedes configurar la cantidad de información mostrada pinchando con el botón derecho del ratón en este area o seleccionando   <b>Información de la partida</b> en el menú <menu>Opciones</menu>. Seleccionando la opción "resultado y mejor movimiento" se obtiene la mayor cantidad de información, pero es amenudo mucho más lento que la opción "sólo resultado".

<h3>La ventana de Tablebase</h3>
<p>
Puedes obtener más información sobre la posición actual abriendo la <term>ventana de Tablebase</term> (menú <menu>Ventanas</menu>,
atajo: Ctrl+Shift+T). Esta ventana muestra el resultado, con un juego perfecto, de todos los movimientos legales desde la actual posición.
</p>

<h3>Obtener archivos de Tablebases</h3>
<p>
Ver la sección de <a Author Related>links relacionados</a> para obtener ayuda para encontrar archivos de tablebases en internet.
</p>

<p><footer>(Actualizado: Scid 2.6, Agosto 2001)</footer></p>
}


####################
### Bookmarks help:

set helpTitle(S,Bookmarks) "Bookmarks"
set helpText(S,Bookmarks) {<h1>Bookmarks</h1>
<p>
Scid allows you to <term>bookmark</term> important games for easy
future reference. The bookmarks menu is available from the
<menu>File</menu> menu, the toolbar, or the <B>Ctrl+B</b> shortcut key.
</p>
<p>
When you select a bookmarked game from the Bookmarks menu, Scid will
open its database if necessary, find that game, and move to the game
position at which it was bookmarked.
</p>
<p>
Only games in a Scid format database (not a PGN file or the clipbase)
can be bookmarked.
</p>
<p>
If the database of a bookmarked game is sorted or compacted, the bookmark
details may become out of date. When that happens, Scid will search the
database for the best matching game (comparing player names, site, etc)
when the bookmark is selected, so the bookmarked game should still be
loaded. However, if details of the bookmarked game change, it is possible
that a different game will match the bookmark details better and be
loaded instead. So it is a good idea to re-bookmark a game if you edit
its players, site, result, round or year.
</p>

<h3>Editing bookmarks</h3>
<p>
With the bookmark editor, you can change the menu text displayed for
each bookmarked game and add folders to categorize bookmarks.
</p>

<h3>Hints</h3>
<p>
You can use bookmarks for fast access to databases you use often
by bookmarking a game from each database. Another good use for
bookmarks is to add important games you find when studying a
particular chess opening.
</p>
<p>
The bookmarks menu contains an entry for controlling the display of
bookmark folders: they can be shown as submenus (useful when there are
many bookmarks), or as a single list.
</p>

<p><footer>(Actualizado: Scid 3.0, Noviembre 2001)</footer></p>
}

#################
### Pgnscid help:

set helpTitle(S,Pgnscid) "Pgnscid"
set helpText(S,Pgnscid) {<h1>Pgnscid</h1>
<p>
<term>Pgnscid</term> es un programa aparte que necesitas usar (eso era antes) para convertir archivos PGN (portable game notation) en bases de datos Scid.
</p>
Para convertir un archivo llamado <i>miarchivo.pgn</i>, simplemente escribe:
<ul>
<li> <b>pgnscid miarchivo.pgn</b> </li>
</ul>
y la base de datos Scid (consistente en <i>miarchivo.si</i>, <i>miarchivo.sg</i> y <i>miarchivo.sn</i>) será creada. Cualquier error o advertencia será escrita en el archivo <i>miarchivo.err</i>.
</p>
<p>
Si quieres que la base de datos sea creada en un directorio diferente o que tenga un nombre diferente puedes añadir el nombre de la base de datos en la línea de comandos, por ejemplo:
<ul>
<li> <b>pgnscid miarchivo.pgn mibase</b> </li>
</ul>
creará una base de datos consistente en los archivos <i>mibase.si</i>,
<i>mibase.sg</i> y <i>mibase.sn</i>.
</p>
<p>
Advierte que pgnscid (y scid) pueden leer archivos comprimidos en Gzip (ej. <b>mibase.pgn.gz</b>) directamente, por lo que, si tienes un gran archivo PGN comprimido con Gzip para ahorrar espacio, no necesitas descomprimirlo primero.
</p>

<h3>Opciones</h3>
<p>
Hay dos argumentos opcionales que pgnscid puede aceptar delante del nombre del fichero:
<b>-f</b> y <b>-x</b>.
</p>
<p>
La opción <b>-f</b> fuerza a sobrescribir una base de datos existente; por defecto, pgnscid no convierte a una base de datos que ya existe.
</p>
<p>
La opción <b>-x</b> provoca que pgnscid ignore todo el texto entre partidas. Por defecto, el texto entre partidas es guardado como un comentario de la partida que le sigue. Esta opción sólo afecta al texto entre partidas; los comentarios estándar dentro de cada partida son, aún así, convertidos y guardados.
</p>

<h3>Formateo de nombres de jugadores</h3>
<p>
Para reducir el número de ortografías que hacen referencia al mismo jugador, pgnscid hace un formateo básico de los nombre de los jugadores. Por ejemplo, el número de espacios después de cada coma se estandariza a uno, se borra cualquier espacio al principio y final de un nombre, y se borran los puntos al final de un nombre. Los prefijos holandeses como "van den" y "Van Der" se normalizan para que tengan la V mayúscula y la d minúscula.
</p>
<p>
Puedes editar (e incluso revisar ortográficamente de manera automática) los nombres de los jugadores, eventos, lugares y rondas con Scid; ver las páginas de ayuda de <a Maintenance Editing>Mantenimiento</a> para obtener más detalles.
</p>

<p><footer>(Actualizado: Scid 2.5, Junio 2001)</footer></p>
}

####################
### Options and Fonts help:

set helpTitle(S,Options) "Opciones"
set helpText(S,Options) {<h1>Opciones y preferencias</h1>
<p>
Muchas opciones y preferencias de Scid (como pueden ser: tamaño del tablero, colores, fuentes y valores por defecto) son ajustables desde el menú  <menu>Opciones</menu>.
Todas estas (y más, como el último directorio desde el que tu cargaste una base de datos y el tamaño de algunas ventanas) son guardadas en el archivo opciones cuando seleccionas en el menú Opciones <b>Guardar opciones</b>. El archivo opciones es cargado cada vez que se inicia Scid.
</p>
<p>
Si usas Windows, el archivo opciones es <b>scid.opt</b> el cual se encuentra en el directorio donde se encuentra el archivo del programa Scid, <b>scid.exe</b>. Para los usuarios del sistema operativo Unix (como puede ser Solaris o Unix) el archivo es: <b>~/.scid</b> --
es decir, el archivo <b>.scid</b> de tu directorio personal.
</p>

<h3><name Fonts>Tipos de fuentes</name></h3>
<p>
Scid tiene tres tipos de fuentes básicas que usa en la mayoría de sus ventanas, y que puedes personalizar. Estas son llamadas <b>habitual</b>, <b>pequeña</b> y <b>fijada</b>.
</p>
<p>
La fuente fijada tiene una anchura de fuente fija (no proporcional). Es usada en las ventanas <a Tree>árbol</a> y <a Crosstable>tabla cruzada</a>.
</p>

<p><footer>(Actualizado: Scid 2.5, Junio 2001)</footer></p>
}

####################
### File formats help:

set helpTitle(S,Formats) "Formatos de archivo"
set helpText(S,Formats) {<h1>Los formatos de archivo de Scid</h1>
<p>
Las bases de datos Scid consisten en tres archivos esenciales: un archivo Índice, un archivo de Nombres y un archivo de Partidas. Todos tienen una extensión de dos letras que empieza con la letra "s": ".si" para los archivos índice, ".sn" para los archivos de nombres, y ".sg" para los archivos de partidas.
</p>

<h3>El archivo Índice (.si)</h3>
<p>
Este archivo contiene una descripción para la base de datos y pequeña entrada de tamaño fijo para cada partida. El actual tamaño es de 41 bytes por partida. De estos, alrededor de 28 bytes son información esencial como el resultado, fecha, números de identificación de los nombres del jugador/evento/lugar (el nombre existente está en el archivo de Nombres), etc.
</p>
<p>
Los 13 bytes restantes contienen información repetida, pero útil, sobre la partida; es usada para aumentar la velocidad de las búsquedas por posición, material y modelo. Ver la sección <a Formats Fast>Búsquedas rápidas</a> más adelante para obtener más información.
</p>

<h3>El archivo de Nombres (.sn)</h3>
<p>
Este archivo contiene todos los nombres de jugadores, eventos, lugares y rondas de la base de datos. Cada nombre es almacenado sólo una vez, incluso si este aparece en muchas partidas. El archivo de nombres normalmente es el más pequeño de los tres archivos esenciales de una base de datos.
</p>

<h3>El archivo de Partidas (.sg)</h3>
<p>
Este archivo contiene los movimientos, variaciones y comentarios de cada partida. El formato de codificación de los movimientos es muy compacto: la mayoría de los movimientos ocupan sólo un byte de almacenamiento.
</p>
<p>
Cuando una partida es reemplazada, su nueva versión es guardada al <i>final</i> del archivo de partidas, por lo que se puede acumular con el tiempo espacio inútil. Puedes restablecer una base de datos a su mínimo tamaño mediante su <a Compact>compactación</a>.
</p>

<h3>Otros archivos Scid</h3>
<p>
Un archivo <a EPD>EPD</a> (sufijo: ".epd") contiene una serie de posiciones, cada una con un comentario de texto. El formato de archivo EPD se describe en el <a Author Related>estándar PGN</a>.
</p>
<p>
Un archivo de E-mail (sufijo: ".sem") para una base de datos almacena detalles de los oponentes a los que mandas mensajes.
</p>
<p>
Un archivo de Opciones de Búsqueda (sufijo: ".sso") contiene opciones de búsqueda de Scid de <a Searches Header>cabecera</a> o de <a Searches Material>material/modelo</a>.
</p>

<h3><name Fast>Búsquedas rápidas en Scid</name></h3>
<p>
Como se a mencionado más arriba el archivo de índice almacena alguna información repetida pero útil sobre cada partida para acelerar las búsquedas de posición o material.
</p>
<p>
Por ejemplo, se guarda el material de la posición final. Si buscas finales de torre y peón, entonces todas las partidas que terminen con una dama, alfil o caballo sobre el tablero (y no tienen promoción de peones) serán rápidamente saltadas.
</p>
<p>
Otro segmento de información guardado de utilidad es el orden en el que los peones dejan su casilla inicial (por moverse o por ser capturados). Esto es usado para aumentar la velocidad del árbol o de las búsquedas por posición exacta, especialmente para posiciones de apertura. Por ejemplo, cuando se busca la posición inicial de la defensa francesa (1.e4 e6), se saltan todas las partidas que empiezan con 1.e4 c5, o 1.d4, etc, pero las partidas que empiezan con 1.e4 e5 todavía podrán ser utilizadas en la búsqueda.
</p>

<p><footer>(Actualizado: Scid 2.5, Junio 2001)</footer></p>
}

####################
### NAG values help:

set helpTitle(S,NAGs) "Valores NAG"
set helpText(S,NAGs) {<h1>Valores NAG estándares</h1>
<p>
Los valores NAG (Numeric Annotation Symbol) estándares definidos en el <a Author Related>estándar PGN</a> son:
</p>
<cyan>
<ul>
<li>  1   Buen movimiento (!) </li>
<li>  2   Mal movimiento (?) </li>
<li>  3   Excelente movimiento (!!) </li>
<li>  4   Error garrafal (??) </li>
<li>  5   Movimiento interesante (!?) </li>
<li>  6   Movimiento dudoso (?!) </li>
<li>  7   Movimiento forzado </li>
<li>  8   Movimiento singular; no hay alternativas razonables </li>
<li>  9   Movimiento que conlleva la derrota </li>
<li> 10   Posición de tablas (=) </li>
<li> 11   Oportunidades iguales, posición tranquila (=) </li>
<li> 12   Oportunidades iguales, posición activa (=) </li>
<li> 13   Posición incierta (~) </li>
<li> 14   Las blancas tienen una pequeña ventaja (+=) </li>
<li> 15   Las negras tienen una pequeña ventaja (=+) </li>
<li> 16   Las blancas tienen una moderada ventaja (+/-) </li>
<li> 17   Las negras tienen una moderada ventaja (-/+) </li>
<li> 18   Las blancas tienen una ventaja decisiva (+-) </li>
<li> 19   Las negras tienen una ventaja decisiva (-+) </li>
<li> 20   Las blancas tienen una ventaja aplastante (+-) </li>
<li> 21   Las negras tienen una ventaja aplastante (-+) </li>
<li> 22   Las blancas desearían pasar </li>
<li> 23   Las negras desearían pasar </li>
<li> 24   Las blancas tienen una pequeña ventaja espacial </li>
<li> 25   Las negras tienen una pequeña ventaja espacial </li>
<li> 26   Las blancas tienen una moderada ventaja espacial </li>
<li> 27   Las negras tienen una moderada ventaja espacial </li>
<li> 28   Las blancas tienen una ventaja espacial decisiva </li>
<li> 29   Las negras tienen una ventaja espacial decisiva </li>
<li> 30   Las blancas tienen una pequeña ventaja de tiempo (desarrollo) </li>
<li> 31   Las negras tienen una pequeña ventaja de tiempo (desarrollo) </li>
<li> 32   Las blancas tienen una moderada ventaja de tiempo (desarrollo) </li>
<li> 33   Las negras tienen una moderada ventaja de tiempo (desarrollo) </li>
<li> 34   Las blancas tienen una decisiva ventaja de tiempo (desarrollo) </li>
<li> 35   Las negras tienen una decisiva ventaja de tiempo (desarrollo) </li>
<li> 36   Las blancas tienen la iniciativa </li>
<li> 37   Las negras tienen la iniciativa </li>
<li> 38   Las blancas tienen una iniciativa duradera </li>
<li> 39   Las negras tienen una iniciativa duradera </li>
<li> 40   Las blancas llevan el ataque </li>
<li> 41   Las negras llevan el ataque </li>
<li> 42   Las blancas tienen una insuficiente compensación para el déficit de material </li>
<li> 43   Las negras tienen una insuficiente compensación para el déficit de material </li>
<li> 44   Las blancas tienen suficiente compensación para el déficit de material </li>
<li> 45   Las negras tienen suficiente compensación para el déficit de material </li>
<li> 46   Las blancas tienen una más que adecuada compensación para el déficit de material </li>
<li> 47   Las negras tienen una más que adecuada compensación para el déficit de material </li>
<li> 48   Las blancas tienen una pequeña ventaja en el control del centro </li>
<li> 49   Las negras tienen una pequeña ventaja en el control del centro </li>
<li> 50   Las blancas tienen una moderada ventaja en el control del centro </li>
<li> 51   Las negras tienen una moderada ventaja en el control del centro </li>
<li> 52   Las blancas tienen una ventaja decisiva en el control del centro </li>
<li> 53   Las negras tienen una ventaja decisiva en el control del centro </li>
<li> 54   Las blancas tienen una pequeña ventaja en el control del ala del rey </li>
<li> 55   Las negras tienen una pequeña ventaja en el control del ala del rey </li>
<li> 56   Las blancas tienen una moderada ventaja en el control del ala del rey </li>
<li> 57   Las negras tienen una moderada ventaja en el control del ala del rey </li>
<li> 58   Las blancas tienen una ventaja decisiva en el control del ala del rey </li>
<li> 59   Las negras tienen una ventaja decisiva en el control del ala del rey </li>
<li> 60   Las blancas tienen una pequeña ventaja en el control del ala de la dama </li>
<li> 61   Las negras tienen una pequeña ventaja en el control del ala de la dama </li>
<li> 62   Las blancas tienen una moderada ventaja en el control del ala de la dama </li>
<li> 63   Las negras tienen una moderada ventaja en el control del ala de la dama </li>
<li> 64   Las blancas tienen una ventaja decisiva en el control del ala de la dama </li>
<li> 65   Las negras tienen una ventaja decisiva en el control del ala de la dama </li>
<li> 66   Las blancas tienen una primera fila vulnerable </li>
<li> 67   Las negras tienen una primera fila vulnerable </li>
<li> 68   Las blancas tienen una primera fila bien protegida </li>
<li> 69   Las negras tienen una primera fila bien protegida </li>
<li> 70   Las blancas tienen un rey mal protegido </li>
<li> 71   Las negras tienen un rey mal protegido </li>
<li> 72   Las blancas tienen un rey bien protegido </li>
<li> 73   Las negras tienen un rey bien protegido </li>
<li> 74   Las blancas tienen un rey mal colocado </li>
<li> 75   Las negras tienen un rey mal colocado </li>
<li> 76   Las blancas tienen un rey bien colocado </li>
<li> 77   Las negras tienen un rey bien colocado </li>
<li> 78   Las blancas tienen una estructura de peones muy débil </li>
<li> 79   Las negras tienen una estructura de peones muy débil </li>
<li> 80   Las blancas tienen una estructura de peones moderadamente débil </li>
<li> 81   Las negras tienen una estructura de peones moderadamente débil </li>
<li> 82   Las blancas tienen una estructura de peones moderadamente fuerte </li>
<li> 83   Las negras tienen una estructura de peones moderadamente fuerte </li>
<li> 84   Las blancas tienen una estructura de peones muy fuerte </li>
<li> 85   Las negras tienen una estructura de peones muy fuerte </li>
<li> 86   Las blancas tienen un mal emplazamiento del caballo </li>
<li> 87   Las negras tienen un mal emplazamiento del caballo </li>
<li> 88   Las blancas tienen un buen emplazamiento del caballo </li>
<li> 89   Las negras tienen un buen emplazamiento del caballo </li>
<li> 90   Las blancas tienen un mal emplazamiento del alfil </li>
<li> 91   Las negras tienen un mal emplazamiento del alfil </li>
<li> 92   Las blancas tienen un buen emplazamiento del alfil </li>
<li> 93   Las negras tienen un buen emplazamiento del alfil </li>
<li> 94   Las blancas tienen un mal emplazamiento de la torre </li>
<li> 95   Las negras tienen un mal emplazamiento de la torre </li>
<li> 96   Las blancas tienen un buen emplazamiento de la torre </li>
<li> 97   Las negras tienen un buen emplazamiento de la torre </li>
<li> 98   Las blancas tienen un mal emplazamiento de la dama </li>
<li> 99   Las negras tienen un mal emplazamiento de la dama </li>
<li>100   Las blancas tienen un buen emplazamiento de la dama </li>
<li>101   Las negras tienen un buen emplazamiento de la dama </li>
<li>102   Las blancas tienen una mala coordinación de piezas </li>
<li>103   Las negras tienen una mala coordinación de piezas </li>
<li>104   Las blancas tienen una buena coordinación de piezas </li>
<li>105   Las negras tienen una buena coordinación de piezas </li>
<li>106   Las blancas han jugado una abertura muy mala </li>
<li>107   Las negras han jugado una abertura muy mala </li>
<li>108   Las blancas han jugado una abertura mala </li>
<li>109   Las negras han jugado una abertura mala </li>
<li>110   Las blancas han jugado una buena abertura </li>
<li>111   Las negras han jugado una buena abertura </li>
<li>112   Las blancas han jugado una muy buena abertura </li>
<li>113   Las negras han jugado una muy buena abertura </li>
<li>114   Las blancas han jugado el medio juego muy mal </li>
<li>115   Las negras han jugado el medio juego muy mal </li>
<li>116   Las blancas han jugado el medio juego mal </li>
<li>117   Las negras han jugado el medio juego mal </li>
<li>118   Las blancas han jugado el medio juego bien </li>
<li>119   Las negras han jugado el medio juego bien </li>
<li>120   Las blancas han jugado el medio juego muy bien </li>
<li>121   Las negras han jugado el medio juego muy bien </li>
<li>122   Las blancas han jugado el final muy mal </li>
<li>123   Las negras han jugado el final muy mal </li>
<li>124   Las blancas han jugado el final mal </li>
<li>125   Las negras han jugado el final mal </li>
<li>126   Las blancas han jugado el final bien </li>
<li>127   Las negras han jugado el final bien </li>
<li>128   Las blancas han jugado el final muy bien </li>
<li>129   Las negras han jugado el final muy bien </li>
<li>130   Las blancas tienen una débil oportunidad de contraatacar </li>
<li>131   Las negras tienen una débil oportunidad de contraatacar  </li>
<li>132   Las blancas tienen una pequeña oportunidad de contraatacar  </li>
<li>133   Las negras tienen una pequeña oportunidad de contraatacar  </li>
<li>134   Las blancas tienen una decisiva oportunidad de contraatacar  </li>
<li>135   Las negras tienen una decisiva oportunidad de contraatacar  </li>
<li>136   Las blancas tienen una moderada presión en el control de tiempo </li>
<li>137   Las negras tienen una moderada presión en el control de tiempo </li>
<li>138   Las blancas tienen una gran presión en el control de tiempo </li>
<li>139   Las negras tienen una gran presión en el control de tiempo </li>
</ul>
</cyan>

<p>
Otros valores NAG propuestos por Chess Informant incluyen:
</p>
<cyan>
<ul>
<li>140   con la idea ... </li>
<li>141   Apuntar contra ... </li>
<li>142   Mejor movimiento </li>
<li>143   Peor movimiento </li>
<li>144   Movimiento equivalente </li>
<li>145   Comentario del editor ("CE") </li>
<li>146   Novedad ("N") </li>
<li>147   Punto débil </li>
<li>148   Final de la partida </li>
<li>149   Línea </li>
<li>150   Diagonal </li>
<li>151   Las blancas tienen el par de alfiles </li>
<li>152   Las negras tienen el par de alfiles </li>
<li>153   Alfiles de colores opuestos </li>
<li>154   Alfiles de igual color </li>
</ul>
</cyan>

<p>
Otros valores sugeridos son:
</p>
<cyan>
<ul>
<li>190   Etc. </li>
<li>191   Peones doblados </li>
<li>192   Peón aislado </li>
<li>193   Peones conectados </li>
<li>194   Peones colgados </li>
<li>195   Peón trasero </li>
</ul>
</cyan>

<p>
Símbolos definidos por Scid para su propio uso:
</p>
<cyan>
<ul>
<il>201   Diagrama ("D", a veces designado con "#") </il>
</ul>
</cyan>

<p><footer>(Actualizado: Scid 2.5, Junio 2001)</footer></p>
}

###################
### ECO guide help:

set helpTitle(S,ECO) "Guía ECO"
set helpText(S,ECO) {<h1>Clasificación de aperturas por ECO</h1>
<p>
Scid puede clasificar las partidas de acuerdo con la clasificación de aperturas <b>ECO</b> (Encyclopaedia of Chess Openings).
Un código ECO estándar consiste en una letra (A..E) seguida por dos dígitos, por lo que hay 500 códigos ECO estándar distintos.
</p>
<p>
El sistema ECO es muy limitado y no es suficiente para las partidas actuales: algunos de los 500 códigos casi no se vuelven a ver más, mientras que otros se ven frecuentemente. Para mejorar esta situación, Scid permite una extensión opcional a los códigos ECO básicos: cada código puede ser ampliado con una letra (a..z), y con una extensión supletoria (otro dígito, 1..4) que no es usado todavía en el archivo ECO estándar de Scid. Por lo que un código ECO extendido por Scid se ve como "<b>A41e</b>" o "<b>E99b2</b>". Gran número de los códigos ECO más comúnmente encontrados en las partidas actuales de los maestros tienen una extensión definida en el archivo ECO de Scid.
</p>

<h3><name Browser>La ventana del Buscador ECO</name></h3>
<p>
La ventana del <term>Buscador ECO</term> muestra la posición que es usada para clasificar cada código ECO, y la frecuencia y rendimiento de los códigos ECO en la base de datos actual.
</p>
<p>
El panel superior muestra la frecuencia de cada código ECO en la base de datos actual. Las barras del gráfico tienen tres secciones: la inferior (de color más claro) muestra el número de partidas ganadas por las blancas, la del medio muestra el número de tablas, y la superior (la más oscura) muestra el número de las ganadas por las negras. Esto te permite ver de un vistazo las características de una apertura: por ejemplo, si las blancas puntúan muy bien, o si son muy comunes las tablas.
</p>
<p>
Para ir a un nivel ECO más profundo, aprieta el botón izquierdo del ratón sobre una barra del gráfico (o escribe la letra o el dígito que corresponda). Para retroceder al nivel superior, aprieta el botón derecho del ratón en cualquier sitio del gráfico, o aprieta la tecla de la flecha hacia la izquierda (o suprimir o espacio atrás (borrar)).
</p>
<p>
El panel inferior muestra las posiciones que incluye un código ECO en particular, según el archivo ECO que tengas cargado.
</p>

<h3>Cargando el archivo ECO de Scid</h3>
<p>
El archivo ECO que viene con Scid se llama <b>scid.eco</b>; Scid trata de cargarlo siempre que se enciende. Si Scid no puede encontrarlo, tendrás que hacer lo siguiente para habilitar la clasificación ECO:
<ul>
<li>(a) En Scid, usa el comando del menú
       <menu>Opciones: Cargar archivo ECO</menu>
       y selecciona el archivo <b>scid.eco</b>. </li>
<li>(b) Guardar opciones (desde el menú <menu>Opciones</menu>). </li>
</ul>
Después de hacer esto, el archivo ECO será cargado cada vez que inicies Scid.
</p>

<h3>Sistema de códigos ECO</h3>
<p>
La estructura básica del sistema ECO es:
</p>
<p>
<li><b><blue><run updateEcoWin A>A</run></blue></b>   1.d4 Nf6 2...;  1.d4 ...;  1.c4;  1.various
<ul>
<li>  <b>A0</b>  1.Nf3;  1.f4;  1.<i>various</i>
      (<b>A02-A03</b>  1.f4: <i>Bird's Opening</i>;
       <b>A04-A09</b>  1.Nf3: <i>Reti; King's Indian Attack</i>) </li>
<li>  <b>A1</b>  1.c4 ...: <i>English</i> </li>
<li>  <b>A2</b>  1.c4 e5: <i>King's English</i> </li>
<li>  <b>A3</b>  1.c4 c5: <i>English, Symmetrical </i> </li>
<li>  <b>A4</b>  1.d4 ...: <i>Queen's Pawn</i> </li>
<li>  <b>A5</b>  1.d4 Nf6 2.c4 ..: <i>Indian Defence </i> </li>
<li>  <b>A6</b>  1.d4 Nf6 2.c4 c5 3.d5 e6: <i>Modern Benoni</i> </li>
<li>  <b>A7</b>  A6 + 4.Nc3 exd5 5.cxd5 d6 6.e4 g6 7.Nf3 </li>
<li>  <b>A8</b>  1.d4 f5: <i>Dutch Defence</i> </li>
<li>  <b>A9</b>  1.d4 f5 2.c4 e6: <i>Dutch Defence</i> </li>
</ul>

<p>
<b><blue><run updateEcoWin B>B</run></blue></b>   1.e4 c5;  1.e4 c6;  1.e4 d6;  1.e4 <i>various</i>
<ul>
<li>  <b>B0</b>  1.e4 ...
      (<b>B02-B05</b>  1.e4 Nf6: <i>Alekhine Defence</i>;
       <b>B07-B09</b>  1.e4 d6: <i>Pirc</i>) </li>
<li>  <b>B1</b>  1.e4 c6: <i>Caro-Kann</i> </li>
<li>  <b>B2</b>  1.e4 c5: <i>Sicilian Defence </i> </li>
<li>  <b>B3</b>  1.e4 c5 2.Nf3 Nc6: <i>Sicilian</i> </li>
<li>  <b>B4</b>  1.e4 c5 2.Nf3 e6: <i>Sicilian</i> </li>
<li>  <b>B5</b>  1.e4 c5 2.Nf3 d6: <i>Sicilian</i> </li>
<li>  <b>B6</b>  B5 + 3.d4 cxd4 4.Nxd4 Nf6 5.Nc3 Nc6 </li>
<li>  <b>B7</b>  B5 + 4.Nxd4 Nf6 5.Nc3 g6: <i>Sicilian Dragon</i> </li>
<li>  <b>B8</b>  B5 + 4.Nxd4 Nf6 5.Nc3 e6: <i>Sicilian Scheveningen</i> </li>
<li>  <b>B9</b>  B5 + 4.Nxd4 Nf6 5.Nc3 a6: <i>Sicilian Najdorf</i> </li>
</ul>

<p>
<b><blue><run updateEcoWin C>C</run></blue></b>   1.e4 e5;  1.e4 e6
<ul>
<li>  <b>C0</b>  1.e4 e6: <i>French Defence</i> </li>
<li>  <b>C1</b>  1.e4 e6 2.d4 d5 3.Nc3: <i>French, Winawer/Classical</i> </li>
<li>  <b>C2</b>  1.e4 e5: <i>Open Game</i> </li>
<li>  <b>C3</b>  1.e4 e5 2.f4: <i>King's Gambit</i> </li>
<li>  <b>C4</b>  1.e4 e5 2.Nf3: <i>Open Game</i> </li>
<li>  <b>C5</b>  1.e4 e5 2.Nf3 Nc6 3.Bc4: <i>Italian; Two Knights</i> </li>
<li>  <b>C6</b>  1.e4 e5 2.Nf3 Nc6 3.Bb5: <i>Spanish (Ruy Lopez)<i> </li>
<li>  <b>C7</b>  1.e4 e5 2.Nf3 Nc6 3.Bb5 a6 4.Ba4: <i>Spanish</i> </li>
<li>  <b>C8</b>  C7 + 4...Nf6 5.O-O: <i>Spanish, Closed and Open</i>
        (<b>C80-C83</b>  5.O-O Nxe4: <i>Spanish, Open System</i>;
         <b>C84-C89</b>  5.O-O Be7: <i>Spanish, Closed System</i>) </li>
<li>  <b>C9</b>  C8 + 5...Be7 6.Re1 b5 7.Bb3 d6: <i>Spanish, Closed</i> </li>
</ul>

<p>
<b><blue><run updateEcoWin D>D</run></blue></b>   1.d4 d5; 1.d4 Nf6 2.c4 g6 with 3...d5
<ul>
<li>  <b>D0</b>   1.d4 d5: <i>Queen's Pawn</i> </li>
<li>  <b>D1</b>   1.d4 d5 2.c4 c6: <i>Slav Defence</i> </li>
<li>  <b>D2</b>  1.d4 d5 2.c4 dxc4: <i>Queen's Gambit Accepted (QGA)</i> </li>
<li>  <b>D3</b>  1.d4 d5 2.c4 e6: <i>Queen's Gambit Declined (QGD)</i> </li>
<li>  <b>D4</b>  D3 + 3.Nc3 Nf6 4.Nf3 c5/c6: <i>Semi-Tarrasch; Semi-Slav</i> </li>
<li>  <b>D5</b>  D3 + 3.Nc3 Nf6 4.Bg5: <i>QGD Classical</i> </li>
<li>  <b>D6</b>  D5 + 4...Be7 5.e3 O-O 6.Nf3 Nbd7: <i>QGD Orthodox</i> </li>
<li>  <b>D7</b>  1.d4 Nf6 2.c4 g6 with 3...d5: <i>Grunfeld</i> </li>
<li>  <b>D8</b>  1.d4 Nf6 2.c4 g6 3.Nc3 d5: <i>Grunfeld</i> </li>
<li>  <b>D9</b>  1.d4 Nf6 2.c4 g6 3.Nc3 d5 4.Nf3: <i>Grunfeld</i> </li>
</ul>

<p>
<b><blue><run updateEcoWin E>E</run></blue></b>   1.d4 Nf6 2.c4 e6; 1.d4 Nf6 2.c4 g6
<ul>
<li>  <b>E0</b>  1.d4 Nf6 2.c4 e6: <i>Catalan, etc</i> </li>
<li>  <b>E1</b>  1.d4 Nf6 2.c4 e6 3.Nf3 (b6): <i>Queen's Indian, etc</i> </li>
<li>  <b>E2</b>  1.d4 Nf6 2.c4 e6 3.Nc3 (Bb4): <i>Nimzo-Indian, etc</i> </li>
<li>  <b>E3</b>  E2 + 4.Bg5 or 4.Qc2: <i>Nimzo-Indian</i> </li>
<li>  <b>E4</b>  E2 + 4.e3: <i>Nimzo-Indian, Rubinstein</i> </li>
<li>  <b>E5</b>  E4 + 4...O-O 5.Nf3: <i>Nimzo-Indian, main line</i> </li>
<li>  <b>E6</b>  1.d4 Nf6 2.c4 g6: <i>King's Indian</i> </li>
<li>  <b>E7</b>  1.d4 Nf6 2.c4 g6 3.Nc3 Bg7 4.e4: <i>King's Indian</i> </li>
<li>  <b>E8</b>  E7 + 4...d6 5.f3: <i>King's Indian, Samisch</i> </li>
<li>  <b>E9</b>  E7 + 4...d6 5.Nf3: <i>King's Indian, main lines</i> </li>
</ul>

<p><footer>(Actualizado: Scid 2.5, Junio 2001)</footer></p>
}

#############################
### Contact information help:

set helpTitle(S,Author) "Información de contacto"
set helpText(S,Author) {<h1>Información de contacto</h1>
<p>
La página de Scid se encuentra en:: <br>
<li><b><url http://scid.sourceforge.net/>http://scid.sourceforge.net/</url></b>
</p>
<p>
Esta tiene la última versión de Scid para bajarse y cualquier otro archivo extra que esté disponible.
</p>
<p>
Por favor envía cualquier comentario, pregunta, sugerencia o informe de errores al autor de Scid, Shane Hudson, al E-mail:<br>
<li><b>shane@cosc.canterbury.ac.nz</b>
</p>

<h3><name Related>Links relacionados</name></h3>
<p>
Si disfrutas con Scid, encontrarás los siguientes sitios web interesantes:
</p>
<ul>
<li><url http://www.tim-mann.org/chess.html>http://www.tim_mann.org/chess.html</url> --
Página personal del programa <b>xboard y winboard</b> de Tim Mann, el cual es un lector PGN y un interfaz para los servidores de ajedrez de internet. Además tiene información interesante sobre Crafty, GNUchess y otros programas gratuitos.</li>

<li><url ftp://ftp.cis.uab.edu/pub/hyatt/>ftp://ftp.cis.uab.edu/pub/hyatt/</url> --
El fuerte programa de ajedrez Crafty: El subdirectorio llamado <b>TB</b> tiene gran número de archivos de finales (tablebase) en formato Nalimov, los cuales puedes usar en muchos programas de ajedrez y en Scid.</li>

<li><url http://www.chesscenter.com/twic/>http://www.chesscenter.com/twic/</url> -- TWIC (the week in chess), un excelente boletín semanal de partidas de ajedrez disponibles en formato PGN.</li>

<li><url http://scid.sourceforge.net/standard.txt>http://scid.sourceforge.net/standard.txt</url> -- El <b>Estándar PGN</b>, creado por Steven J. Edwards en 1994. Este archivo de texto explica los formatos PGN y EPD detalladamente.</li>
</ul>

<p><footer>(Actualizado: Scid 2.6, Agosto 2001)</footer></p>
}

# end of spanish.tcl
