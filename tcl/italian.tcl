### italian.tcl:
# Italian language support for Scid.
# Added by Giancarlo Bassi.
# Updated by Paolo Montrasi.
# Updated by Michele Rinesi on 01/08/2002.
# Untranslated messages are marked with a "***" comment.

addLanguage I Italian 0

proc setLanguage_I {} {

# File menu:
menuText I File "File" 0
menuText I FileNew "Nuovo..." 0 {Crea un nuovo database Scid}
menuText I FileOpen "Apri..." 0 {Apre un database Scid esistente}
menuText I FileClose "Chiudi" 0 {Chiude un database Scid attivo}
menuText I FileFinder "Finder" 0 {Apre la finestra per cercare i file}
menuText I FileBookmarks "Bookmarks" 0 {Menu' Bookmarks (chiave: Ctrl+B)}
menuText I FileBookmarksAdd "Aggiungi bookmark" 0 \
  {Memorizza la partita e la posizione del database attivo}
menuText I FileBookmarksFile "Memorizza bookmark" 0 \
  {Memorizza un bookmark per la partita e posizione corrente}
menuText I FileBookmarksEdit "Modifica bookmarks..." 0 \
  {Modifica il menu' dei bookmarks memorizzati}
menuText I FileBookmarksList "Mostra i bookmark come una lista" 0 \
  {Mostra le cartelle dei bookmarks come una lista, senza sottomenu'}
menuText I FileBookmarksSub "Mostra i bookmark come sottomenu'" 0 \
  {Mostra le cartelle dei bookmarks con sottomenu', non a lista}
menuText I FileMaint "Gestione" 0 {Strumenti di gestione di un database Scid}
menuText I FileMaintWin "Finestra di Gestione" 0 \
  {Apre/chiude la finestra di gestione di un database Scid}
menuText I FileMaintCompact "Compatta database..." 0 \
  {Compatta i file di database, rimuovendo le partite cancellate e i nomi non usati}
menuText I FileMaintClass "Classificazione ECO di partite..." 2 \
  {Ricalcola il codice ECO di tutte le partite}
menuText I FileMaintSort "Ordina database..." 0 \
  {Ordina tutte le partite nel database}
menuText I FileMaintDelete "Cancella le partite doppie..." 20 \
  {Cerca le partite duplicate e le seleziona per cancellarle}
menuText I FileMaintTwin "Finestra di controllo delle doppie" 0 \
  {Apre/aggiorna la finestra del controllo dei duplicati}
menuText I FileMaintName "Controllo di nomi" 13 {Editor di nomi e controllo ortografico}
menuText I FileMaintNameEditor "Finestra di editor dei nomi" 0 \
  {Apre/chiude la finestra di editor dei nomi}
menuText I FileMaintNamePlayer "Controllo di nomi dei giocatori..." 22 \
  {Controllo di nomi dei giocatori mediante il file di verifica di nomi}
menuText I FileMaintNameEvent "Controllo di nomi di Eventi..." 21 \
  {Controllo di nomi dei eventi mediante il file di verifica di eventi}
menuText I FileMaintNameSite "Controllo di nomi di siti..." 21 \
  {Controllo di nomi di siti mediante il file di verifica}
menuText I FileMaintNameRound "Controllo di nomi di turni..." 21 \
  {Controllo di nomi di turni mediante il file di verifica}
menuText I FileReadOnly "Sola-lettura..." 0 \
  {Tratta il database attuale in sola lettura, prevenendo variazioni}
menuText I FileSwitch "Attiva un database" 0 \
  {Attiva uno fra i database aperti}
menuText I FileExit "Esci" 0 {Esce da Scid}

# Edit menu:
menuText I Edit "Edita" 0
menuText I EditAdd "Aggiunge una variante" 0 {Aggiunge una variante a questa mossa nella partita}
menuText I EditDelete "Cancella Variante" 0 {Cancella una variante per questa mossa}
menuText I EditFirst "Variante principale" 5 \
  {Promuove a variante principale nella lista}
menuText I EditMain "Promuove una Variante a Linea Principale" 0 \
  {Promuove una variante a linea principale}
menuText I EditTrial "Prova una variante" 0 \
  {Attiva/disattiva la modalita' di prova di una variante, per provare idee direttamente sulla scacchiera}
menuText I EditStrip "Pulisci" 2 {Elimina commenti o varianti dalla partita corrente}
menuText I EditStripComments "Commenti" 0 \
  {Elimina tutti i commenti e le annotazioni dalla parita corrente}
menuText I EditStripVars "Varianti" 0 {Elimina tutte le varianti dalla partita corrente}
menuText I EditReset "Vuota la Clipbase" 0 \
  {Svuota completamente la clipbase}
menuText I EditCopy "Copia questa partita nella Clipbase" 1 \
  {Copia questa partita nella clipbase}
menuText I EditPaste "Incolla l'ultima partita nella Clipbase" 0 \
  {Incolla qui la partita della clipbase}
menuText I EditSetup "Posizione definita..." 10 \
  {Definisce una posizione per la partita corrente}
menuText I EditCopyBoard "Copy position" 6 \
  {Copy the current board in FEN notation to the text selection (clipboard)} ;# ***
menuText I EditPasteBoard "Incolla come posizione di partenza" 12 \
  {Imposta la posizione di partenza dalla selezione del testo corrente (clipboard)}

# Game menu:
menuText I Game "Partita" 0
menuText I GameNew "Annulla partita" 0 \
  {Torna alla posizione iniziale, rinunciando ai cambiamenti}
menuText I GameFirst "Carica la prima Partita" 13 {Carica la prima partita del filtro}
menuText I GamePrev "Carica la precedente Partita" 10 {Carica la precedente partita del filtro}
menuText I GameReload "Ricarica la Partita attuale" 0 \
  {Ricarica questa partita, eliminando ogni cambiamento eseguito}
menuText I GameNext "Carica la successiva Partita" 10 {Carica il successivo filtro di partite}
menuText I GameLast "Carica l'ultima partita" 9 {Carica l'ultima partita del filtro}
menuText I GameRandom "Carica una partica casuale" 8 {Carica una partita casuale del filtro}
menuText I GameNumber "Carica la partita numero..." 18 \
  {Carica una partita digitando il suo numero}
menuText I GameReplace "Salva: Sostituisce la partita..." 8 \
  {Salva questa partita, sostituendo la vecchia versione}
menuText I GameAdd "Save: Aggiunge la nuova partita..." 7 \
  {Salva questa partita come nuova partita nel database}
menuText I GameDeepest "Identifica apertura" 0 \
  {Va' alla posizione di partita piu' profonda listata nel libro ECO}
menuText I GameGotoMove "Vai alla mossa numero..." 0 \
  {Va' al numero di mossa specificato nella partita attuale}
menuText I GameNovelty "Trova Novita'..." 7 \
  {Cerca la prima mossa mai giocata della partita corrente}

# Search Menu:
menuText I Search "Cerca" 0
menuText I SearchReset "Annulla il filtro" 0 {Annulla il filtro per includere tutte le partite}
menuText I SearchNegate "Filtro Negato" 0 {Nega il filtro per comprendere solo partite escluse}
menuText I SearchCurrent "Posizione attuale..." 0 {Cerca la attuale posizione}
menuText I SearchHeader "Intestazione..." 0 {Ricerca per intestazione (giocatore, evento, etc)}
menuText I SearchMaterial "Materiale/Schema..." 0 {Ricerca per materiale o schema posizionale}
menuText I SearchUsing "Uso del file di ricerca..." 0 {Ricerca mediante un file di Opzioni}

# Windows menu:
menuText I Windows "Finestre" 2
menuText I WindowsComment "Editor di commenti" 10 {Apre/chiude l'editor di commenti}
menuText I WindowsGList "Lista di Partite" 0 {Apre/chiude la finestra di lista di partite}
menuText I WindowsPGN "Finestra PGN" 9 {Apre/chiude la finestra PGN (notazione di partita)}
menuText I WindowsPList "Player Finder" 2 {Apre/chiude la finestra Player Finder}
menuText I WindowsTmt "Tournament Finder" 2 {Apre/chiude la finestra Tournament Finder}
menuText I WindowsSwitcher "Scambio di Database" 11 {Apre/chiude la finestra di scambio di Database}
menuText I WindowsMaint "Finestra di gestione" 12 {Apre/chiude la finestra di gestione}
menuText I WindowsECO "Navigazione ECO" 12 {Apre/chiude la finestra di navigazione ECO}
menuText I WindowsRepertoire "Editor di repertorio" 10 \
  {Apre/chiude l'editor di repertorio di apertura}
menuText I WindowsStats "Finestra di statistica" 12 {Apre/chiude la finestra di filtro statistico}
menuText I WindowsTree "Finestra di albero" 12 {Apre/chiude la finestra di albero}
menuText I WindowsTB "Finestra di Tablebase di finale" 12 \
  {Apre/chiude la finestra Tablebase}

# Tools menu:
menuText I Tools "Strumenti" 0
menuText I ToolsAnalysis "Motore di analisi..." 10 \
  {Inizia/termina il motore di analisi scacchistica}
menuText I ToolsAnalysis2 "Motore di analisi #2..." 19 \
  {Inizia/termina il motore di analisi scacchistica}
menuText I ToolsCross "Tabella" 0 {Mostra la tabella di torneo per questa partita}
menuText I ToolsEmail "Gestione Email" 10 \
  {Apre/chiude la finestra di gestione di partite per posta elettronica}
menuText I ToolsFilterGraph "Filter graph" 7 \
  {Apre/chiude la finestra Filter Graph}
menuText I ToolsOpReport "Rapporto di Apertura" 0 \
  {Genera un rapporto di apertura per l'attuale posizione}
menuText I ToolsTracker "Piece Tracker"  0 {Apre la finestra Piece Tracker}
menuText I ToolsPInfo "Informazioni sul giocatore"  17 \
  {Apre/agiorna la finestra di Informazione del giocatore}
menuText I ToolsRating "Grafico del punteggio Elo" 24 \
  {Grafico storico del punteggio Elo dei giocatori della corrente partita}
menuText I ToolsScore "Grafico dei punti" 12 {Nostra la finestra del grafico dei punti}
menuText I ToolsExpCurrent "Esporta la partita attuale" 0 \
  {Scrive la partita attuale in un file di testo}
menuText I ToolsExpCurrentPGN "Esporta partita in un file PGN..." 15 \
  {Scrive la partita attuale in un file PGN}
menuText I ToolsExpCurrentHTML "Esporta partita in un file HTML..." 15 \
  {Scrive la partita attuale in un file HTML}
menuText I ToolsExpCurrentLaTeX "Esporta partita in un file LaTeX..." 15 \
  {Scrive la partita attuale in un file LaTeX}
menuText I ToolsExpFilter "Esporta tutte le partite del filtro" 1 \
  {Scrive tutte le partite filtrate in un file di testo}
menuText I ToolsExpFilterPGN "Esporta filtro in file PGN..." 17 \
  {Scrive tutte le partite filtrate in un file PGN}
menuText I ToolsExpFilterHTML "Esporta filtro in file HTML..." 17 \
  {Scrive tutte le partite filtrate in un file HTML}
menuText I ToolsExpFilterLaTeX "Esporta filtro in un file LaTeX..." 17 \
  {Scrive tutte le partite filtrate in un file LaTeX}
menuText I ToolsImportOne "Importa una partita in formato PGN..." 0 \
  {Importa una partita da testo PGN}
menuText I ToolsImportFile "Importa il file di partite PGN..." 11 \
  {Importa le partite da un file PGN}

# Options menu:
menuText I Options "Opzioni" 0
menuText I OptionsSize "Dimensione della scacchiera" 0 {Cambia la dimensione della scacchiera}
menuText I OptionsPieces "Stile dei pezzi" 6 \
  {Modifica lo stile dei pezzi della scacchiera}
menuText I OptionsColors "Colori..." 0 {Cambia i colori della scacchiera}
menuText I OptionsExport "Esportazione" 2 {Cambia le opzioni di importazione testo}
menuText I OptionsFonts "Fonts" 0 {Cambia fonts}
menuText I OptionsFontsRegular "Regolare" 0 {Cambia il font in 'regular'}
menuText I OptionsFontsMenu "Menu" 0 {Cambia il font dei menu}
menuText I OptionsFontsSmall "Piccolo" 0 {Cambia il font 'small'}
menuText I OptionsFontsFixed "Fisso" 0 {Cambia il font di larghezza fissa}
menuText I OptionsGInfo "Informazioni sulla partita" 0 {Opzioni sulle informazioni della partita}
menuText I OptionsLanguage "Lingua" 0 {Sceglie una nuova lingua di menu}
menuText I OptionsMoves "Mosse" 0 {Opzioni di immissione di mosse}
menuText I OptionsMovesAsk "Conferma prima di sostituire le mosse" 0 \
  {Chiede prima di sovrascrivere ogni mossa esistente}
menuText I OptionsMovesDelay "Intervallo di tempo per il gioco automatico..." 1 \
  {Definisce l'intervallo di tempo per il gioco automatico}
menuText I OptionsMovesCoord "Immissione mossa per coordinate" 0 \
  {Accetta l'input di mossa mediante coordinate ("g1f3")}
menuText I OptionsMovesSuggest "Mostra le mosse suggerite" 0 \
  {Attiva/Disattiva il suggerimento di mosse}
menuText I OptionsMovesKey "Completamento da tastiera" 0 \
  {Attiva/Disattiva l'autocompletamento di mosse da tastiera}
menuText I OptionsNumbers "Formato del numero" 13 {Seglie il formato del numero}
menuText I OptionsStartup "Apertura all'avvio" 3 {Sceglie le finestre da aprire all'avvio}
menuText I OptionsWindows "Finestre" 2 {Opzioni di finestra}
menuText I OptionsWindowsIconify "Minimizza automaticamente" 5 \
  {Minimizza tutte le finestre quando la finestra principale viene minimizzata}
menuText I OptionsWindowsRaise "Auto-aumenta" 0 \
  {Aumenta alcune finestre (per es. le barre di progresso) ogni volta che sono oscurate}
menuText I OptionsToolbar "Barra degli strumenti" 12 \
  {Mostra/nasconde la barra degli strumenti nella finestra principale}
menuText I OptionsECO "Carica il file ECO..." 15 {Carica il file di classificazione ECO}
menuText I OptionsSpell "Carica il file di controllo ortografico..." 28 \
  {Carica il file di controllo di Scid}
menuText I OptionsTable "Directory di Tablebase..." 13 \
  {Seglie un file tablebase; tutte le tablebases nella directory saranno utilizzate}
menuText I OptionsRecent "File utilizzati di recente..." 0 \
  {Cambia il numero di file recentemente utilizzati visualizzato nel menu file}
menuText I OptionsSave "Salva Opzioni" 0 \
  "Salva tutte le opzioni definibili nel file $::optionsFile"
menuText I OptionsAutoSave "Salva Opzioni all'uscita" 0 \
  {Salva automaticamente tutte le opzioni quando si esce da Scid}

# Help menu:
menuText I Help "Aiuto" 0
menuText I HelpIndex "Indice" 0 {Mostra la pagina dell'indice dell'aiuto}
menuText I HelpGuide "Guida Veloce" 0 {Mostra la pagina di aiuto per la guida veloce}
menuText I HelpHints "Suggerimenti" 0 {Mostra la pagina di aiuto dei suggerimenti}
menuText I HelpContact "Informazioni per contattare" 17 {Mostra la pagina dell'aiuto di informazione di contatto}
menuText I HelpTip "Suggerimento del giorno" 0 {Mostra utili suggerimenti riguardo Scid}
menuText I HelpStartup "Finestra di partenza" 0 {Mostra la finestra di partenza}
menuText I HelpAbout "Su Scid" 1 {Informazioni su Scid}

# partita info box popup menu:
menuText I GInfoHideNext "Nascondi la mossa successiva" 0
menuText I GInfoMaterial "Mostra i valori del materiale" 0
menuText I GInfoFEN "Mostra FEN" 5
menuText I GInfoMarks "Mostra caselle e frecce colorate" 5
menuText I GInfoWrap "A capo automatico" 0
menuText I GInfoFullComment "Mostra commenti completi" 10
menuText I GInfoPhotos "Show Photos" 5 ;# ***
menuText I GInfoTBNothing "Tablebases: nulla" 12
menuText I GInfoTBResult "Tablebases: solo risultato" 12
menuText I GInfoTBAll "Tablebases: risultato e mosse migliori" 19
menuText I GInfoDelete "Recupera/Cancella questa partita" 9
menuText I GInfoMark "Smarca/Marca questa partita" 7

# Main window buttons:
helpMsg I .button.start {Va all'inizio della partita  (chiave: Home)}
helpMsg I .button.end {Va alla fine della partita  (chiave: End)}
helpMsg I .button.back {Indietro di una mossa (chiave: LeftArrow)}
helpMsg I .button.forward {Avanti di una mossa (chiave: RightArrow)}
helpMsg I .button.intoVar {Entra in una variante  (chiave abbreviata: v)}
helpMsg I .button.exitVar {Lascia la variante attuale  (chiave abbreviata: z)}
helpMsg I .button.flip {Ruota la scacchiera (chiave abbreviata: .)}
helpMsg I .button.coords {Coordinate on/off  (chiave abbreviata: 0)}
helpMsg I .button.autoplay {Mosse automatiche  (chiave: Ctrl+Z)}

# General buttons:
translate I Back {Indietro}
translate I Cancel {Cancella}
translate I Clear {Annulla}
translate I Close {Chiudi}
translate I Defaults {Defaults} ;# ***
translate I Delete {Annulla}
translate I Graph {Grafico}
translate I Help {Aiuto}
translate I Import {Importa}
translate I Index {Indice}
translate I LoadGame {Carica partita}
translate I BrowseGame {Visualizza partita}
translate I MergeGame {Fondi partita}
translate I Preview {Anteprima}
translate I Revert {Rovescia}
translate I Save {Salva}
translate I Search {Cerca}
translate I Stop {Stop}
translate I Store {Memorizza}
translate I Update {Aggiorna}
translate I ChangeOrient {Modifica l'orientamento della finestra}
translate I None {Nessuno}
translate I First {Prima}
translate I Current {Attuale}
translate I Last {Ultima}

# General messages:
translate I game {partita}
translate I games {Partite}
translate I move {mossa}
translate I moves {mosse}
translate I all {tutto}
translate I Yes {Si'}
translate I No {No}
translate I Both {Entrambi}
translate I King {Re}
translate I Queen {Donna}
translate I Rook {Torre}
translate I Bishop {Alfiere}
translate I Knight {Cavallo}
translate I Pawn {Pedone}
translate I White {Bianco}
translate I Black {Nero}
translate I Player {Giocatori}
translate I Rating {Punteggio}
translate I RatingDiff {Differenza punteggio (Bianco - Nero)}
translate I AverageRating {Punteggio medio}
translate I Event {Evento}
translate I Site {Sito}
translate I Country {Paese}
translate I IgnoreColors {Ignora i colori}
translate I Date {Data}
translate I EventDate {Evento data}
translate I Decade {Decennio}
translate I Year {Anno}
translate I Month {Mese}
translate I Months {Gennaio Febbraio Marzo Aprile Maggio Giugno
  Luglio Agosto Settembre Ottobre Novembre Dicembre}
translate I Days {Dom Lun Mar Mer Gio Ven Sab}
translate I YearToToday {Anno ad oggi}
translate I Result {Risultato}
translate I Round {Turno}
translate I Length {Lunghezza}
translate I ECOCode {codice ECO}
translate I ECO {ECO}
translate I Deleted {Cancellato}
translate I SearchResults {Risultati della ricerca}
translate I OpeningTheDatabase {Database di aperture}
translate I Database {Database}
translate I Filter {Filtro}
translate I noGames {no partite}
translate I allGames {tutte le partite}
translate I empty {vuoto}
translate I clipbase {clipbase}
translate I score {score}
translate I StartPos {Posizione iniziale}
translate I Total {Totale}

# Standard error messages:
translate I ErrNotOpen {Questo database non è aperto.}
translate I ErrReadOnly {Questo database è a sola lettura; non puo' essere modificato.}
translate I ErrSearchInterrupted {Ricerca interrotta; il risultato e' incompleto.}

# Game information:
translate I twin {doppio}
translate I deleted {cancellato}
translate I comment {commento}
translate I hidden {nascosto}
translate I LastMove {Ultima mossa}
translate I NextMove {Mossa Successiva}
translate I GameStart {Inizio di partita}
translate I LineStart {Inizio di variante}
translate I GameEnd {Fine della partita}
translate I LineEnd {Fine della variante}

# Player information:
translate I PInfoAll {Risultati per <b>tutte</b> le partite}
translate I PInfoFilter {Risultati per le partite nel <b>filtro</b>}
translate I PInfoAgainst {Risultati contro}
translate I PInfoMostWhite {Le piu' frequenti aperture con il Bianco}
translate I PInfoMostBlack {Le piu' frequenti aperture con il Nero}
translate I PInfoRating {Variazioni dell'Elo}
translate I PInfoBio {Biografia}

# Tablebase information:
translate I Draw {Patta}
translate I stalemate {stallo}
translate I withAllMoves {con tutte le mosse}
translate I withAllButOneMove {con tutte le mosse tranne una}
translate I with {con}
translate I only {solo}
translate I lose {persa}
translate I loses {perse}
translate I allOthersLose {tutte le altre perse}
translate I matesIn {matto in}
translate I hasCheckmated {e' mattato}
translate I longest {la piu' lunga}
translate I WinningMoves {Mosse vincenti}
translate I DrawingMoves {Mosse pattanti}
translate I LosingMoves {Mosse perdenti}
translate I UnknownMoves {Mosse senza risultato}

# Tip of the day:
translate I Tip {Suggerimento}
translate I TipAtStartup {Suggerimento all'avvio}

# Tree window menus:
menuText I TreeFile "File" 0
menuText I TreeFileSave "Salva il file di cache" 0 \
  {Salva il file (.stc) della cache dell'albero}
menuText I TreeFileFill "Riempie il file di cache" 0 \
  {Riempie il file di cache con le piu' frequenti posizioni di apertura}
menuText I TreeFileBest "Lista delle migliori partite" 0 {Mostra l'albero delle migliori partite}
menuText I TreeFileGraph "Finestra di grafico" 0 \
  {Mostra il grafico per la corrente variante dell'albero}
menuText I TreeFileCopy "Copia il testo dell'albero nella clipboard" 1 \
  {Copia le statistiche dell'albero nella clipboard}
menuText I TreeFileClose "Chiudi la finestra dell'albero" 0 \
  {Chiudi la finestra dell'albero}
menuText I TreeSort "Ordina" 0
menuText I TreeSortAlpha "Alfabetico" 0
menuText I TreeSortECO "codice ECO" 0
menuText I TreeSortFreq "Frequenza" 0
menuText I TreeSortScore "Punti" 0
menuText I TreeOpt "Opzioni" 0
menuText I TreeOptLock "Blocca" 0 {Blocca/sblocca l'albero al database corrente}
menuText I TreeOptTraining "Training" 0 {Attiva/disattiva la modalita' di esercizio dell'albero}
menuText I TreeOptAutosave "File di cache per Auto-salvare" 0 \
  {Salva automaticamente il file di cache quando si chiude la finestra dell'albero}
menuText I TreeHelp "Aiuto" 0
menuText I TreeHelpTree "Aiuto per l'albero" 0
menuText I TreeHelpIndex "Indice di aiuto" 0
translate I SaveCache {Salva cache}
translate I Training {Esercizio}
translate I LockTree {Blocca}
translate I TreeLocked {Bloccato}
translate I TreeBest {Migliore}
translate I TreeBestGames {Migliori partite}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate I TreeTitleRow \
  {    Mossa  ECO       Frequenza    Punt.  AvElo Perf AvAnno}

# Finder window:
menuText I FinderFile "File" 0
menuText I FinderFileSubdirs "Cerca nelle sottodirectory" 0
menuText I FinderFileClose "Chiudi File Finder" 0
menuText I FinderSort "Ordina" 0
menuText I FinderSortType "Tipo" 0
menuText I FinderSortSize "Dimensione" 0
menuText I FinderSortMod "Modifica" 0
menuText I FinderSortName "Nome" 0
menuText I FinderSortPath "Percorso" 0
menuText I FinderTypes "Tipi" 0
menuText I FinderTypesScid "Database Scid" 0
menuText I FinderTypesOld "Vecchio formato database Scid" 0
menuText I FinderTypesPGN "File PGN" 0
menuText I FinderTypesEPD "EPD (book) files" 0
menuText I FinderTypesRep "File di Repertorio" 0
menuText I FinderHelp "Aiuto" 0
menuText I FinderHelpFinder "Aiuto su File Finder" 0
menuText I FinderHelpIndex "Indice di aiuto" 0
translate I FileFinder {File Finder}
translate I FinderDir {Directory} ;# ***
translate I FinderDirs {Directories} ;# ***
translate I FinderFiles {Files}
translate I FinderUpDir {Su}

# Player finder:
menuText I PListFile "File" 0
menuText I PListFileUpdate "Aggiorna" 0
menuText I PListFileClose "Chiudi Player Finder" 0
menuText I PListSort "Ordina" 0
menuText I PListSortName "Nome" 0
menuText I PListSortElo "Elo" 0
menuText I PListSortGames "Partite" 0
menuText I PListSortOldest "Più vecchie" 4
menuText I PListSortNewest "Più recenti" 4

# Tournament finder:
menuText I TmtFile "File" 0
menuText I TmtFileUpdate "Aggiorna" 0
menuText I TmtFileClose "Chiudi Tournament Finder" 0
menuText I TmtSort "Ordina" 0
menuText I TmtSortDate "Data" 0
menuText I TmtSortPlayers "Giocatori" 0
menuText I TmtSortGames "Partite" 0
menuText I TmtSortElo "Elo" 0
menuText I TmtSortSite "Siti" 0
menuText I TmtSortEvent "Eventi" 1
menuText I TmtSortWinner "Vincitore" 0
translate I TmtLimit "Limite della lista"
translate I TmtMeanElo "Media Elo piu' bassa"
translate I TmtNone "Non e' stato trovato nessun torneo."

# Graph windows:
menuText I GraphFile "File" 0
menuText I GraphFileColor "Salva come Color Postscript..." 8
menuText I GraphFileGrey "Salva come Greyscale Postscript..." 8
menuText I GraphFileClose "Chiudi la finestra" 6
menuText I GraphOptions "Opzioni" 0
menuText I GraphOptionsWhite "Bianco" 0
menuText I GraphOptionsBlack "Nero" 0
menuText I GraphOptionsBoth "Entrambi" 1
menuText I GraphOptionsPInfo "Info sul giocatore" 0
translate I GraphFilterTitle "Filter Graph: frequenza ogni 1000 partite"

# Analysis window:
translate I AddVariation {Aggiungi variante}
translate I AddMove {Aggiunge una mossa}
translate I Annotate {Annota}
translate I AnalysisCommand {Comando di analisi}
translate I PreviousChoices {Scelta precedente}
translate I AnnotateTime {Imposta il tempo tra le mosse in secondi}
translate I AnnotateWhich {Aggiungi varianti}
translate I AnnotateAll {Per mosse di entrambi i colori}
translate I AnnotateWhite {Per solo le mosse del Bianco}
translate I AnnotateBlack {Per solo le mosse del Nero}
translate I AnnotateNotBest {Quando la mossa della partita non e' la migliore}

# Analysis Engine open dialog:
translate I EngineList {Lista dei motori di analisi}
translate I EngineName {Nome}
translate I EngineCmd {Comando}
translate I EngineArgs {Parametri}
translate I EngineDir {Directory}
translate I EngineElo {Elo}
translate I EngineTime {Data}
translate I EngineNew {Nuovo}
translate I EngineEdit {Modifica}
translate I EngineRequired {I campi in grassetto sono obbligatori; gli altri sono opzionali}

# Stats window menus:
menuText I StatsFile "File" 0
menuText I StatsFilePrint "Stampa in file..." 0
menuText I StatsFileClose "Chiudi la finestra" 0
menuText I StatsOpt "Opzioni" 0

# PGN window menus:
menuText I PgnFile "File" 0
menuText I PgnFilePrint "Stampa in file..." 0
menuText I PgnFileClose "Chiudi la finestra PGN" 0
menuText I PgnOpt "Visualizza" 0
menuText I PgnOptColor "Visualizza il Colore" 0
menuText I PgnOptShort "Intestazione compatta (3-righe)" 0
menuText I PgnOptSymbols "Annotazioni simboliche" 0
menuText I PgnOptIndentC "Indenta i commenti" 0
menuText I PgnOptIndentV "Indenta le varianti" 1
menuText I PgnOptColumn "Stile della colonna (una mossa per riga)" 0
menuText I PgnOptSpace "Spazio dopo i numeri delle mosse" 0
menuText I PgnOptStripMarks "Elimina i codici colorati delle caselle/frecce" 0
menuText I PgnColor "Colori" 0
menuText I PgnColorHeader "Intestazione..." 0
menuText I PgnColorAnno "Annotazioni..." 0
menuText I PgnColorComments "Commenti..." 0
menuText I PgnColorVars "Varianti..." 0
menuText I PgnColorBackground "Sfondo..." 0
menuText I PgnHelp "Aiuto" 0
menuText I PgnHelpPgn "Aiuto PGN" 0
menuText I PgnHelpIndex "Indice" 0

# Crosstable window menus:
menuText I CrosstabFile "File" 0
menuText I CrosstabFileText "Stampa in un file di Testo..." 21
menuText I CrosstabFileHtml "Stampa in un file HTML..." 18
menuText I CrosstabFileLaTeX "Stampa in un file LaTeX..." 18
menuText I CrosstabFileClose "Chiudi la finestra della tabella" 0
menuText I CrosstabEdit "Edita" 0
menuText I CrosstabEditEvent "Evento" 0
menuText I CrosstabEditSite "Sito" 0
menuText I CrosstabEditDate "Data" 0
menuText I CrosstabOpt "Visualizza" 0
menuText I CrosstabOptAll "Girone all'italiana" 0
menuText I CrosstabOptSwiss "Girone Svizzero" 0
menuText I CrosstabOptKnockout "Knockout" 0
menuText I CrosstabOptAuto "Auto" 0
menuText I CrosstabOptAges "Eta' in anni" 8
menuText I CrosstabOptNats "Nazionalita'" 0
menuText I CrosstabOptRatings "Punteggi" 0
menuText I CrosstabOptTitles "Titoli" 0
menuText I CrosstabOptBreaks "Punteggi al Tie-break" 4
menuText I CrosstabOptDeleted "Inserisce le partite cancellate" 8
menuText I CrosstabOptColors "Colori (solo girone Svizzero)" 0
menuText I CrosstabOptColumnNumbers "A colonne (Solo la tabella dei tornei all'italiana)" 3
menuText I CrosstabOptGroup "Punti del gruppo" 0
menuText I CrosstabSort "Ordina" 0
menuText I CrosstabSortName "Nome" 0
menuText I CrosstabSortRating "Punteggio" 0
menuText I CrosstabSortScore "Punti" 0
menuText I CrosstabColor "Colore" 0
menuText I CrosstabColorPlain "Testo normale" 0
menuText I CrosstabColorHyper "Ipertesto" 0
menuText I CrosstabHelp "Aiuto" 0
menuText I CrosstabHelpCross "Aiuto tabella" 0
menuText I CrosstabHelpIndex "Indice di aiuto" 0
translate I SetFilter {Imposta filtro}
translate I AddToFilter {Aggiungi al filtro}
translate I Swiss {Svizzero}
translate I Category {Categoria}

# Opening report window menus:
menuText I OprepFile "File" 0
menuText I OprepFileText "Stampa in un file di testo..." 21
menuText I OprepFileHtml "Stampa in un file HTML..." 18
menuText I OprepFileLaTeX "Stampa in un file LaTeX..." 18
menuText I OprepFileOptions "Opzioni..." 0
menuText I OprepFileClose "Chiude la finestra del rapporto" 0
menuText I OprepHelp "Aiuto" 0
menuText I OprepHelpReport "Aiuto sul rapporto di apertura" 0
menuText I OprepHelpIndex "Indice di Aiuto" 0

# Repertoire editor:
menuText I RepFile "File" 0
menuText I RepFileNew "Nuovo" 0
menuText I RepFileOpen "Apri..." 0
menuText I RepFileSave "Salva..." 0
menuText I RepFileSaveAs "Salva con nome..." 3
menuText I RepFileClose "Close window" 0
menuText I RepEdit "Edita" 0
menuText I RepEditGroup "Aggiunge il gruppo" 12
menuText I RepEditInclude "Aggiunge la variante inclusa" 21
menuText I RepEditExclude "Aggiunge la variante esclusa" 21
menuText I RepView "Visualizza" 0
menuText I RepViewExpand "Espande tutti i gruppi" 0
menuText I RepViewCollapse "Collassa tutti i gruppi" 0
menuText I RepSearch "Cerca" 0
menuText I RepSearchAll "Tutto del repertorio..." 0
menuText I RepSearchDisplayed "Visualizza solo varianti..." 0
menuText I RepHelp "Aiuto" 0
menuText I RepHelpRep "Aiuto del repertorio" 0
menuText I RepHelpIndex "Indice di Aiuto" 0
translate I RepSearch "Ricerca nel repertorio"
translate I RepIncludedLines "varianti incluse"
translate I RepExcludedLines "varianti escluse"
translate I RepCloseDialog {Questo repertorio non e' stato salvato.

Vuoi veramente continuare ed eliminare le modifiche effettuate?
}

# Header search:
translate I HeaderSearch {Ricerca per Intestazione}
translate I GamesWithNoECO {Partite senza ECO?}
translate I GameLength {Lunghezza della partita}
translate I FindGamesWith {Cerca partite con}
translate I StdStart {Inizio standard}
translate I Promotions {Promozioni}
translate I Comments {Commenti}
translate I Variations {Varianti}
translate I Annotations {Annotazioni}
translate I DeleteFlag {Cancellato}
translate I WhiteOpFlag {Apertura del Bianco}
translate I BlackOpFlag {Apertura del Nero}
translate I MiddlegameFlag {Mediogioco}
translate I EndgameFlag {Finale}
translate I NoveltyFlag {Novita'}
translate I PawnFlag {Struttura pedonale}
translate I TacticsFlag {Tatticismi}
translate I QsideFlag {Gioco su lato di Donna}
translate I KsideFlag {Gioco su lato di Re}
translate I BrilliancyFlag {Brillantezza}
translate I BlunderFlag {Svista}
translate I UserFlag {User}
translate I PgnContains {PGN contiene testo}

# Game list window:
translate I GlistNumber {Numero}
translate I GlistWhite {Bianco}
translate I GlistBlack {Nero}
translate I GlistWElo {B-Elo}
translate I GlistBElo {N-Elo}
translate I GlistEvent {Evento}
translate I GlistSite {Sito}
translate I GlistRound {Turno}
translate I GlistDate {Data}
translate I GlistYear {Anno}
translate I GlistEDate {Evento-Data}
translate I GlistResult {Risultato}
translate I GlistLength {Lunghezza}
translate I GlistCountry {Paese}
translate I GlistECO {ECO}
translate I GlistOpening {Apertura}
translate I GlistEndMaterial {Materiale a fine partita}
translate I GlistDeleted {Cancellato}
translate I GlistFlags {Identificatore}
translate I GlistVars {Varianti}
translate I GlistComments {Commenti}
translate I GlistAnnos {Annotazioni}
translate I GlistStart {Inizio}
translate I GlistGameNumber {numero di Partita}
translate I GlistFindText {Cerca testo}
translate I GlistMoveField {Mossa}
translate I GlistEditField {Configura}
translate I GlistAddField {Aggiungi}
translate I GlistDeleteField {Elimina}
translate I GlistWidth {Larghezza}
translate I GlistAlign {Allinea}
translate I GlistColor {Colore}
translate I GlistSep {Separatore}

# Maintenance window:
translate I DatabaseName {Nome del Database:}
translate I TypeIcon {Icona tipo:}
translate I NumOfGames {Partite:}
translate I NumDeletedGames {partite cancellate:}
translate I NumFilterGames {Partite nel filtro:}
translate I YearRange {Intervallo di anni:}
translate I RatingRange {Intervallo di Punteggio:}
translate I Description {Descrizione}
translate I Flag {Identificatore}
translate I DeleteCurrent {Cancella la partita attuale}
translate I DeleteFilter {Cancella le partite del filtro}
translate I DeleteAll {Cancella tutte le partite}
translate I UndeleteCurrent {Recupera la partita attuale}
translate I UndeleteFilter {Recupera il filtro di partite}
translate I UndeleteAll {Recupera tutte le partite}
translate I DeleteTwins {Cancella le partite doppie}
translate I MarkCurrent {Marca la partita attuale}
translate I MarkFilter {Marca partite del filtro}
translate I MarkAll {Marca tutte le partite}
translate I UnmarkCurrent {Smarca la partita attuale}
translate I UnmarkFilter {Smarca le partite del filtro}
translate I UnmarkAll {Smarca tutte le partite}
translate I Spellchecking {Controllo nome}
translate I Players {Giocatori}
translate I Events {Eventi}
translate I Sites {Siti}
translate I Rounds {Turni}
translate I DatabaseOps {Operazioni sul Database}
translate I ReclassifyGames {Partite classificate ECO}
translate I CompactDatabase {Compatta database}
translate I SortDatabase {Ordina database}
translate I AddEloRatings {Aggiungi punteggio Elo}
translate I AutoloadGame {Numero della partita che si caricherà automaticamente}
translate I StripTags {Toglie i PGN tags}
translate I StripTag {Toglie i tag}
translate I Cleaner {Manutentore Globale}
translate I CleanerHelp {La finestra Manutentore Globale effettura' tutte le operazioni che verranno selezionate dalla lista sottostante, sul database corrente.

Le impostazioni correnti nelle finestre della classificazione ECO e della cancellazione delle partite doppie verranno applicate se selezionate.}
translate I CleanerConfirm {Una volta attivata l'operazione di pulizia questa non puo' piu' essere interrotta!

Questo puo' richiedere diverso tempo su un grosso database, a seconda delle funzioni selezionate e delle impostazioni correnti.

Sei sicuro di voler procedere con le funzioni selezionate?}

# Comment editor:
translate I AnnotationSymbols  {Simboli di annotazione:}
translate I Comment {Commento:}
translate I InsertMark {Inserisci marcatore}

# Board search:
translate I BoardSearch {Ricerca Posizione}
translate I FilterOperation {Operazione sul filtro corrente:}
translate I FilterAnd {AND (Restrizione del filtro)}
translate I FilterOr {OR (Aggiunta al filtro)}
translate I FilterIgnore {IGNORA (Annulla il filtro)}
translate I SearchType {Tipo di ricerca:}
translate I SearchBoardExact {Posizione Esatta (tutti i pezzi sulla stessa casa)}
translate I SearchBoardPawns {Pedoni (stesso materiale, tutti i pedoni sulla stessa casa)}
translate I SearchBoardFiles {File (stesso materiale, tutti i pedoni sulle stesse file)}
translate I SearchBoardAny {Dovunque (stesso materiale, pedoni e pezzi dovunque)}
translate I LookInVars {Osserva nelle varianti}

# Material search:
translate I MaterialSearch {Ricerca Materiale}
translate I Material {Materiale}
translate I Patterns {Schema}
translate I Zero {Nessuno}
translate I Any {Tutti}
translate I CurrentBoard {Posizione corrente}
translate I CommonEndings {Finali Comuni}
translate I CommonPatterns {Schemi Comuni}
translate I MaterialDiff {Differenze di materiale}
translate I squares {sulle case di}
translate I SameColor {Stesso colore}
translate I OppColor {Colore opposto}
translate I Either {Entrambi}
translate I MoveNumberRange {Intervallo del numero di mosse}
translate I MatchForAtLeast {Confronta per almeno}
translate I HalfMoves {semi-mosse}

# game saving:
translate I Today {Oggi}
translate I ClassifyGame {Classifica la partita}

# Setup position:
translate I EmptyBoard {Scacchiera vuota}
translate I InitialBoard {Posizione iniziale}
translate I SideToMove {Parte che muove}
translate I MoveNumber {Numero della mossa}
translate I Castling {Arrocco}
translate I EnPassantFile {Fila En Passant}
translate I ClearFen {Annulla FEN}
translate I PasteFen {Incolla FEN}

# Replace move dialog:
translate I ReplaceMove {Sostituisci la mossa}
translate I AddNewVar {Aggiunge una nuova variante}
translate I ReplaceMoveMessage {Esiste gia' una mossa qui.

Puoi sostituirla, rinunciando a tutte le mosse dopo di essa, o aggiungere la tua mossa come nuova variante.

(Puoi impedire di vedere questo messaggio in futuro ponendo ad off l'opzione "Domanda prima di sostiture le mosse" nel menu Opzioni:Mosse.)}

# Make database read-only dialog:
translate I ReadOnlyDialog {Se rendi questo database di sola lettura, nessuna variazione sara'permessa.
Nessuna partita puo' essere salvata o sostituita, e nessuna 'cancella identificatore' puo' essere alterato.
Ogni ordinamento o classificazione ECO resultera' essere temporaneo.

Puoi facilmente rendere ancora scrivibile il database, chiudendolo e riaprendolo.

Desideri veramente rendere questo database di sola lettura?}

# Clear game dialog:
translate I ClearGameDialog {Questa partita e' stata modificata.

Sei sicuro di voler continuare ed eliminare le modifiche effettuate?}

# Exit dialog:
translate I ExitDialog {Vuoi veramente uscire da Scid?}
translate I ExitUnsaved {Il database ha partite modificate e non salvate. Se esci adesso queste modifiche saranno perse.}

# Import window:
translate I PasteCurrentGame {Incolla la partita attuale}
translate I ImportHelp1 {Immetti o incolla una partita in formato PGN nella struttura precedente.}
translate I ImportHelp2 {Ogni errore di importazione di partita sara' visualizzato qui.}

# ECO Browser:
translate I ECOAllSections {tutte le sezioni ECO}
translate I ECOSection {sezione ECO}
translate I ECOSummary {Sommario per}
translate I ECOFrequency {Frequenze nell'ambito del}

# Opening Report:
translate I OprepTitle {Rapporto di apertura}
translate I OprepReport {Rapporto}
translate I OprepGenerated {Generato da}
translate I OprepStatsHist {Statistica e Storia}
translate I OprepStats {Statistica}
translate I OprepStatAll {tutte le partite della statistica}
translate I OprepStatBoth {Entrambe classificate}
translate I OprepStatSince {Da}
translate I OprepOldest {Le partite piu' vecchie}
translate I OprepNewest {Le partite piu' recenti}
translate I OprepPopular {Attuale popularita'}
translate I OprepFreqAll {Frequenza in tutti gli anni: }
translate I OprepFreq1   {Da  1 anno ad oggi:          }
translate I OprepFreq5   {Da  5 anni ad oggi:          }
translate I OprepFreq10  {Da 10 anni ad oggi:          }
translate I OprepEvery {una volta ogni %u partite}
translate I OprepUp {su %u%s da tutti gli anni}
translate I OprepDown {giu' %u%s da tutti gli anni}
translate I OprepSame {nessuna variazione da tutti gli anni}
translate I OprepMostFrequent {Giocatori piu' frequenti}
translate I OprepRatingsPerf {Punteggi e Performance}
translate I OprepAvgPerf {Punteggi medi e performance}
translate I OprepWRating {Punteggio del Bianco}
translate I OprepBRating {Punteggio del Nero}
translate I OprepWPerf {Performance del Bianco}
translate I OprepBPerf {Performance del Nero}
translate I OprepHighRating {Partite con il piu' alto punteggio medio}
translate I OprepTrends {Tendenze dei risultati}
translate I OprepResults {Risultato lunghezza e frequenza}
translate I OprepLength {Lunghezza della partita}
translate I OprepFrequency {Frequenza}
translate I OprepWWins {Vittorie del Bianco: }
translate I OprepBWins {Vittorie del Nero: }
translate I OprepDraws {Patte:      }
translate I OprepWholeDB {intero database}
translate I OprepShortest {Vittorie piu' brevi}
translate I OprepMovesThemes {Mosse e Temi}
translate I OprepMoveOrders {Ordini di mosse che raggiungono la posizione considerata}
translate I OprepMoveOrdersOne \
  {C'era solo un ordine di mosse che raggiungeva questa posizione:}
translate I OprepMoveOrdersAll \
  {C'erano %u ordini di mosse che raggiungevano questa posizione:}
translate I OprepMoveOrdersMany \
  {C'erano %u ordini di mossa che raggiungevano questa posizione. Le prime %u sono:}
translate I OprepMovesFrom {Mosse dalla posizione del rapporto}
translate I OprepThemes {Temi Posizionali}
translate I OprepThemeDescription {Frequenza di temi alla mossa %u}
translate I OprepThemeSameCastling {Arrocco dallo stesso lato}
translate I OprepThemeOppCastling {Arrocchi eterogenei}
translate I OprepThemeNoCastling {Entrambi i re non arroccati}
translate I OprepThemeKPawnStorm {Attacco di pedoni sull'ala di re}
translate I OprepThemeQueenswap {Scambio di donne}
translate I OprepThemeIQP {Pedone di donna isolato}
translate I OprepThemeWP567 {Pedone Bianco sulla 5/6/7ma traversa}
translate I OprepThemeBP234 {Pedone Nero sulla 2/3/4ta traversa}
translate I OprepThemeOpenCDE {Colonne c/d/e aperte}
translate I OprepTheme1BishopPair {Una parte ha la coppia degli alfieri}
translate I OprepEndgames {Finali}
translate I OprepReportGames {Partite del rapporto}
translate I OprepAllGames {tutte le partite}
translate I OprepEndClass {Materiale alla fine di ogni partita}
translate I OprepTheoryTable {Tabella della Teoria}
translate I OprepTableComment {Generato da %u partite piu' quotate.}
translate I OprepExtraMoves {Mosse Extra note nella tabella della teoria}
translate I OprepMaxGames {Numero massimo di partite nella tabella della teoria}

# Piece Tracker window:
translate I TrackerSelectSingle {Il tasto sinistro del mouse seleziona questo pezzo.}
translate I TrackerSelectPair {Il tasto sinistro del mouse seleziona questo pezzo; il tasto destro seleziona il suo sibling.}
translate I TrackerSelectPawn {Il tasto sinistro del mouse seleziona questo pedone; il tasto destro seleziona tutti gli 8 pedoni.}
translate I TrackerStat {Statistiche}
translate I TrackerGames {% di partite con mosse in questa casella}
translate I TrackerTime {% di tempo su ogni casella}
translate I TrackerMoves {Mosse}
translate I TrackerMovesStart {Inserisci il numero di mossa da dove iniziare il tracciamento.}
translate I TrackerMovesStop {Inserisci il numero di mossa dove finire il tracciamento.}

# Game selection dialogs:
translate I SelectAllGames {Tutte le partite nel database}
translate I SelectFilterGames {Solo le partite nel filtro}
translate I SelectTournamentGames {Solo le partite del torneo attuale}
translate I SelectOlderGames {Solo le partite piu' vecchie}

# Delete Twins window:
translate I TwinsNote {Per essere doppie, due partite devono almeno avere gli stessi due giocatori, e criteri che puoi definire sotto. Quando viene trovata una coppia di doppie, la partita piu' breve e' cancellata.
Suggerimento: E' meglio controllare per caratteri il database prima di cancellare le doppie, per migliorare la ricerca delle doppie.}
translate I TwinsCriteria {Criteri: Partite doppie devono avere...}
translate I TwinsWhich {Esamina quali partite}
translate I TwinsColors {Stessi colori?}
translate I TwinsEvent {Stesso evento?}
translate I TwinsSite {Stesso sito?}
translate I TwinsRound {Stesso turno?}
translate I TwinsYear {Stesso anno?}
translate I TwinsMonth {Stesso mese?}
translate I TwinsDay {Stesso giorno?}
translate I TwinsResult {Stesso result?}
translate I TwinsECO {Stesso codice ECO?}
translate I TwinsMoves {Stesse mosse?}
translate I TwinsPlayers {Confronta i nomi dei giocatori:}
translate I TwinsPlayersExact {Stretta uguaglianza}
translate I TwinsPlayersPrefix {Solo le prima 4 lettere}
translate I TwinsWhen {Quando cancellare partite doppie}
translate I TwinsSkipShort {Ignorare tutte le partite sotto le 5 mosse?}
translate I TwinsUndelete {Recupera prima tutte le partite?}
translate I TwinsSetFilter {Definisci il filtro a tutte le partite doppie cancellate?}
translate I TwinsComments {Mantieni sempre le partite con commenti?}
translate I TwinsVars {Mantieni sempre le partite con varianti?}
translate I TwinsDeleteWhich {Quale partita cancellare:}
translate I TwinsDeleteShorter {La partita più corta}
translate I TwinsDeleteOlder {La partita inserita prima nel database}
translate I TwinsDeleteNewer {La partita inserita dopo nel database}
translate I TwinsDelete {Cancella partite}

# Name editor window:
translate I NameEditType {Tipo di nome da editare}
translate I NameEditSelect {Partite da editare}
translate I NameEditReplace {Sostituisci}
translate I NameEditWith {con}
translate I NameEditMatches {Corrispondenze: Digita da Ctrl+1 ad Ctrl+9 per scegliere}

# Classify window:
translate I Classify {Classifica}
translate I ClassifyWhich {Quali partite classificare ECO}
translate I ClassifyAll {Tutte le partite (sovrascrivi i vecchi codici ECO)}
translate I ClassifyYear {Tutte le partite giocate nell'ultimo anno}
translate I ClassifyMonth {Tutte le partite giocate nell'ultimo mese}
translate I ClassifyNew {Solo partite ancora senza codice ECO}
translate I ClassifyCodes {Codici ECO da usare}
translate I ClassifyBasic {Solo codici di base ("B12", ...)}
translate I ClassifyExtended {estensioni Scid ("B12j", ...)}

# Compaction:
translate I NameFile {File di Nomi}
translate I GameFile {File Partite}
translate I Names {Nomi}
translate I Unused {Non usati}
translate I SizeKb {Dimensioni (kb)}
translate I CurrentState {Stato Attuale}
translate I AfterCompaction {Dopo la compattazione}
translate I CompactNames {Compatta il file di nomi}
translate I CompactGames {Compatta il file di partite}

# Sorting:
translate I SortCriteria {Criteri}
translate I AddCriteria {Aggiungi criteri}
translate I CommonSorts {Ordinamenti Comuni}
translate I Sort {Ordina}

# Exporting:
translate I AddToExistingFile {Aggiungi partite al file esistente?}
translate I ExportComments {Esporta commenti?}
translate I ExportVariations {Esporta varianti?}
translate I IndentComments {Indenta commenti?}
translate I IndentVariations {Indenta varianti?}
translate I ExportColumnStyle {Stile colonna (una mossa per riga)?}
translate I ExportSymbolStyle {Stile annotazione simbolica:}
translate I ExportStripMarks {Togliere i codici di casella/freccia dai commenti?}

# Goto game/move dialogs:
translate I LoadGameNumber {Inserire il numero della partita da caricare:}
translate I GotoMoveNumber {Vai alla mossa numero:}

# Copy games dialog:
translate I CopyGames {Copia partite}
translate I CopyConfirm {
 Vuoi veramente copiare
 le [thousands $nGamesToCopy] partite dal filtro
 del database "$fromName"
 nel database "$targetName"?
}
translate I CopyErr {Impossibile copiare le partite}
translate I CopyErrSource {il database origine}
translate I CopyErrTarget {il database destinazione}
translate I CopyErrNoGames {non contiene nessuna partita nel suo filtro}
translate I CopyErrReadOnly {e' di sola lettura}
translate I CopyErrNotOpen {non e' aperto}

# Colors:
translate I LightSquares {Case chiare}
translate I DarkSquares {Case scure}
translate I SelectedSquares {Case selezionate}
translate I SuggestedSquares {Case delle mosse suggerite}
translate I WhitePieces {Pezzi Bianchi}
translate I BlackPieces {Pezzi Neri}
translate I WhiteBorder {Bordi del Bianco}
translate I BlackBorder {Bordi del Nero}

# Novelty window:
translate I FindNovelty {Trova Novita'}
translate I Novelty {Novita'}
translate I NoveltyInterrupt {Ricerca novita' interrotta}
translate I NoveltyNone {Non e' stata trovata nessuna novita' per la partita corrente}
translate I NoveltyHelp {
Scid cerchera' la prima mossa della partita corrente che raggiungera' una posizione non presente nel database selezionato o nel libro delle aperure.
}

# Upgrading databases:
translate I Upgrading {Aggiornamento}
translate I ConfirmOpenNew {
Questo e' un vecchio formato (Scid 2) di database che non puo' essere aperto da Scid 3, ma e' stata appena creata una nuova versione nel formato (Scid 3).

Vuoi aprire la nuova versione del database?
}
translate I ConfirmUpgrade {
Questo e' un vecchio formato (Scid 2) di database. Prima di poter utilizzare il database in Scid 3 va' creata una nuova versione.

L'aggiornamento creera' una nuova versione del database; non verranno modificati o cancellati i files originali.

Questo richiedera' del tempo, ma necessita di essere fatto una volta sola. Puoi arrestare il processo se durera' a lungo.

Vuoi aggiornare il database ora?
}

# Recent files options:
translate I RecentFilesMenu {Numero di file recentemente utilizzati nel Menu File}
translate I RecentFilesExtra {Numero di file recentemente utilizzati nel submenu extra}

}
# end of italian.tcl
