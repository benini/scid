### italian.tcl:
# Italian language support for Scid.
# Added by Giancarlo Bassi.
# Updated by Paolo Montrasi.
# Updated by Michele Rinesi on 19/02/2004.
# Untranslated messages are marked with a "***" comment.

addLanguage I Italian 0 ; # iso8859-1

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
menuText I EditStripBegin "Mosse dall'inizio" 1 \
  {Elimina le mosse dall'inizio della partita}
menuText I EditStripEnd "Mosse rimanenti" 0 \
  {Elimina le mosse rimanenti}
menuText I EditReset "Vuota la Clipbase" 0 \
  {Svuota completamente la clipbase}
menuText I EditCopy "Copia questa partita nella Clipbase" 1 \
  {Copia questa partita nella clipbase}
menuText I EditPaste "Incolla l'ultima partita nella Clipbase" 0 \
  {Incolla qui la partita della clipbase}
menuText I EditPastePGN "Paste Clipboard text as PGN game..." 10 \
  {Interpret the clipboard text as a game in PGN notation and paste it here} ;# ***
menuText I EditSetup "Posizione definita..." 10 \
  {Definisce una posizione per la partita corrente}
menuText I EditCopyBoard "Copia posizione" 6 \
  {Copia la posizione della scacchiera corrente in notazione FEN come testo (clipboard)}
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
# ====== TODO To be translated ======
menuText I WindowsBook "Book Window" 0 {Open/close the Book window}
# ====== TODO To be translated ======
menuText I WindowsCorrChess "Correspondence Window" 0 {Open/close the Correspondence window}

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
# ====== TODO To be translated ======
menuText I ToolsAbsFilterGraph "Abs. Filter Graph" 7 {Open/close the filter graph window for absolute values}
menuText I ToolsOpReport "Rapporto di Apertura" 0 \
  {Genera un rapporto di apertura per l'attuale posizione}
# ====== TODO To be translated ======
menuText I ToolsOpenBaseAsTree "Open base as tree" 0   {Open a base and use it in Tree window}
# ====== TODO To be translated ======
menuText I ToolsOpenRecentBaseAsTree "Open recent base as tree" 0   {Open a recent base and use it in Tree window}
menuText I ToolsTracker "Piece Tracker"  0 {Apre la finestra Piece Tracker}
# ====== TODO To be translated ======
menuText I ToolsTraining "Training"  0 {Training tools (tactics, openings,...) }
# ====== TODO To be translated ======
menuText I ToolsTacticalGame "Tactical game"  0 {Play a game with tactics}
# ====== TODO To be translated ======
menuText I ToolsSeriousGame "Serious game"  0 {Play a serious game}
# ====== TODO To be translated ======
menuText I ToolsTrainOpenings "Openings"  0 {Train with a repertoire}
# ====== TODO To be translated ======
menuText I ToolsTrainTactics "Tactics"  0 {Solve tactics}
# ====== TODO To be translated ======
menuText I ToolsTrainCalvar "Calculation of variations"  0 {Calculation of variations training}
# ====== TODO To be translated ======
menuText I ToolsTrainFics "Play on internet"  0 {Play on freechess.org}
# ====== TODO To be translated ======
menuText I ToolsBookTuning "Book tuning" 0 {Book tuning}
# ====== TODO To be translated ======
menuText I ToolsNovagCitrine "Novag Citrine" 0 {Novag Citrine}
# ====== TODO To be translated ======
menuText I ToolsNovagCitrineConfig "Configuration" 0 {Novag Citrine configuration}
# ====== TODO To be translated ======
menuText I ToolsNovagCitrineConnect "Connect" 0 {Novag Citrine connect}
menuText I ToolsPInfo "Informazioni sul giocatore"  17 \
  {Apre/agiorna la finestra di Informazione del giocatore}
menuText I ToolsPlayerReport "Report del giocatore ..." 3 \
  {Genera un Report del giocatore}
menuText I ToolsRating "Grafico del punteggio Elo" 24 \
  {Grafico storico del punteggio Elo dei giocatori della corrente partita}
menuText I ToolsScore "Grafico dei punti" 12 {Nostra la finestra del grafico dei punti}
menuText I ToolsExpCurrent "Esporta la partita attuale" 0 \
  {Scrive la partita attuale in un file di testo}
menuText I ToolsExpCurrentPGN "Esporta partita in un file PGN..." 15 \
  {Scrive la partita attuale in un file PGN}
menuText I ToolsExpCurrentHTML "Esporta partita in un file HTML..." 15 \
  {Scrive la partita attuale in un file HTML}
# ====== TODO To be translated ======
menuText I ToolsExpCurrentHTMLJS "Export Game to HTML and JavaScript File..." 15 {Write current game to a HTML and JavaScript file}  
menuText I ToolsExpCurrentLaTeX "Esporta partita in un file LaTeX..." 15 \
  {Scrive la partita attuale in un file LaTeX}
menuText I ToolsExpFilter "Esporta tutte le partite del filtro" 1 \
  {Scrive tutte le partite filtrate in un file di testo}
menuText I ToolsExpFilterPGN "Esporta filtro in file PGN..." 17 \
  {Scrive tutte le partite filtrate in un file PGN}
menuText I ToolsExpFilterHTML "Esporta filtro in file HTML..." 17 \
  {Scrive tutte le partite filtrate in un file HTML}
# ====== TODO To be translated ======
menuText I ToolsExpFilterHTMLJS "Export Filter to HTML and JavaScript File..." 17 {Write all filtered games to a HTML and JavaScript file}  
menuText I ToolsExpFilterLaTeX "Esporta filtro in un file LaTeX..." 17 \
  {Scrive tutte le partite filtrate in un file LaTeX}
menuText I ToolsImportOne "Importa una partita in formato PGN..." 0 \
  {Importa una partita da testo PGN}
menuText I ToolsImportFile "Importa il file di partite PGN..." 11 \
  {Importa le partite da un file PGN}
# ====== TODO To be translated ======
menuText I ToolsStartEngine1 "Start engine 1" 0  {Start engine 1}
# ====== TODO To be translated ======
menuText I ToolsStartEngine2 "Start engine 2" 0  {Start engine 2}
# ====== TODO To be translated ======
menuText I Play "Play" 0
# ====== TODO To be translated ======
menuText I CorrespondenceChess "Correspondence Chess" 0 {Functions for eMail and Xfcc based correspondence chess}
# ====== TODO To be translated ======
menuText I CCConfigure "Configure..." 0 {Configure external tools and general setup}
# ====== TODO To be translated ======
menuText I CCOpenDB "Open Database..." 0 {Open the default Correspondence database}
# ====== TODO To be translated ======
menuText I CCRetrieve "Retrieve Games" 0 {Retrieve games via external (Xfcc-)helper}
# ====== TODO To be translated ======
menuText I CCInbox "Process Inobx" 0 {Process all files in scids Inbox}
# ====== TODO To be translated ======
menuText I CCPrevious "Previous Game" 0 {Go to previous game in Inbox}
# ====== TODO To be translated ======
menuText I CCNext "Next Game" 0 {Go to next game in Inbox}
# ====== TODO To be translated ======
menuText I CCSend "Send Move" 0 {Send your move via eMail or external (Xfcc-)helper}
# ====== TODO To be translated ======
menuText I CCResign "Resign" 0 {Resign (not via eMail)}
# ====== TODO To be translated ======
menuText I CCClaimDraw "Claim Draw" 0 {Send move and claim a draw (not via eMail)}
# ====== TODO To be translated ======
menuText I CCOfferDraw "Offer Draw" 0 {Send move and offer a draw (not via eMail)}
# ====== TODO To be translated ======
menuText I CCAcceptDraw "Accept Draw" 0 {Accept a draw offer (not via eMail)}
# ====== TODO To be translated ======
menuText I CCNewMailGame "New eMail Game..." 0 {Start a new eMail game}
# ====== TODO To be translated ======
menuText I CCMailMove "Mail Move..." 0 {Send the move via eMail to the opponent}

# Options menu:
menuText I Options "Opzioni" 0
menuText I OptionsBoard "Scacchiera" 0 {Opzioni di visualizzazione della scacchiera}
menuText I OptionsBoardSize "Dimensione della scacchiera" 0 {Cambia la dimensione della scacchiera}
menuText I OptionsBoardPieces "Stile dei pezzi" 6 \
  {Modifica lo stile dei pezzi della scacchiera}
menuText I OptionsBoardColors "Colori..." 0 {Cambia i colori della scacchiera}
# ====== TODO To be translated ======
menuText I OptionsBoardGraphics "Squares..." 0 {Select textures for squares}
# ====== TODO To be translated ======
translate I OptionsBGW {Select texture for squares}
# ====== TODO To be translated ======
translate I OptionsBoardGraphicsText {Select graphic files for white and black squares:}
menuText I OptionsBoardNames "I nomi dei miei giocatori ..." 0 {Edita i nomi dei miei giocatori}
menuText I OptionsExport "Esportazione" 2 {Cambia le opzioni di importazione testo}
menuText I OptionsFonts "Fonts" 0 {Cambia fonts}
menuText I OptionsFontsRegular "Regolare" 0 {Cambia il font in 'regular'}
menuText I OptionsFontsMenu "Menu" 0 {Cambia il font dei menu}
menuText I OptionsFontsSmall "Piccolo" 0 {Cambia il font 'small'}
menuText I OptionsFontsFixed "Fisso" 0 {Cambia il font di larghezza fissa}
menuText I OptionsGInfo "Informazioni sulla partita" 0 {Opzioni sulle informazioni della partita}
menuText I OptionsLanguage "Lingua" 0 {Sceglie una nuova lingua di menu}
# ====== TODO To be translated ======
menuText I OptionsMovesTranslatePieces "Translate pieces" 0 {Translate first letter of pieces}
menuText I OptionsMoves "Mosse" 0 {Opzioni di immissione di mosse}
menuText I OptionsMovesAsk "Conferma prima di sostituire le mosse" 0 \
  {Chiede prima di sovrascrivere ogni mossa esistente}
menuText I OptionsMovesAnimate "Intervallo di tempo per le mosse animate" 1 \
  {Definisce l'intervallo di tempo per le mosse animate}
menuText I OptionsMovesDelay "Intervallo di tempo per il gioco automatico..." 1 \
  {Definisce l'intervallo di tempo per il gioco automatico}
menuText I OptionsMovesCoord "Immissione mossa per coordinate" 0 \
  {Accetta l'input di mossa mediante coordinate ("g1f3")}
menuText I OptionsMovesSuggest "Mostra le mosse suggerite" 0 \
  {Attiva/Disattiva il suggerimento di mosse}
# ====== TODO To be translated ======
menuText I OptionsShowVarPopup "Show variations window" 0 {Turn on/off the display of a variations window}  
# ====== TODO To be translated ======
menuText I OptionsMovesSpace "Add spaces after move number" 0 {Add spaces after move number}  
menuText I OptionsMovesKey "Completamento da tastiera" 0 \
  {Attiva/Disattiva l'autocompletamento di mosse da tastiera}
menuText I OptionsNumbers "Formato del numero" 13 {Seglie il formato del numero}
menuText I OptionsStartup "Apertura all'avvio" 3 {Sceglie le finestre da aprire all'avvio}
menuText I OptionsWindows "Finestre" 2 {Opzioni di finestra}
menuText I OptionsWindowsIconify "Minimizza automaticamente" 5 \
  {Minimizza tutte le finestre quando la finestra principale viene minimizzata}
menuText I OptionsWindowsRaise "Auto-aumenta" 0 \
  {Aumenta alcune finestre (per es. le barre di progresso) ogni volta che sono oscurate}
menuText I OptionsSounds "Sounds..." 2 {Configure move announcement sounds} ;# ***
menuText I OptionsToolbar "Barra degli strumenti" 12 \
  {Mostra/nasconde la barra degli strumenti nella finestra principale}
menuText I OptionsECO "Carica il file ECO..." 15 {Carica il file di classificazione ECO}
menuText I OptionsSpell "Carica il file di controllo ortografico..." 28 \
  {Carica il file di controllo di Scid}
menuText I OptionsTable "Directory di Tablebase..." 13 \
  {Seglie un file tablebase; tutte le tablebases nella directory saranno utilizzate}
menuText I OptionsRecent "File utilizzati di recente..." 0 \
  {Cambia il numero di file recentemente utilizzati visualizzato nel menu file}
# ====== TODO To be translated ======
menuText I OptionsBooksDir "Books directory..." 0 {Sets the opening books directory}
# ====== TODO To be translated ======
menuText I OptionsTacticsBasesDir "Bases directory..." 0 {Sets the tactics (training) bases directory}
menuText I OptionsSave "Salva Opzioni" 0 \
  "Salva tutte le opzioni definibili nel file $::optionsFile"
menuText I OptionsAutoSave "Salva Opzioni all'uscita" 0 \
  {Salva automaticamente tutte le opzioni quando si esce da Scid}

# Help menu:
menuText I Help "Aiuto" 0
menuText I HelpContents "Contents" 0 {Mostra la pagina "contents" dell'aiuto}
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
menuText I GInfoPhotos "Visualizza foto" 5
menuText I GInfoTBNothing "Tablebases: nulla" 12
menuText I GInfoTBResult "Tablebases: solo risultato" 12
menuText I GInfoTBAll "Tablebases: risultato e mosse migliori" 19
menuText I GInfoDelete "Recupera/Cancella questa partita" 9
menuText I GInfoMark "Smarca/Marca questa partita" 7
# ====== TODO To be translated ======
menuText I GInfoInformant "Configure informant values" 0

# Main window buttons:
helpMsg I .button.start {Va all'inizio della partita  (chiave: Home)}
helpMsg I .button.end {Va alla fine della partita  (chiave: End)}
helpMsg I .button.back {Indietro di una mossa (chiave: LeftArrow)}
helpMsg I .button.forward {Avanti di una mossa (chiave: RightArrow)}
helpMsg I .button.intoVar {Entra in una variante  (chiave abbreviata: v)}
helpMsg I .button.exitVar {Lascia la variante attuale  (chiave abbreviata: z)}
helpMsg I .button.flip {Ruota la scacchiera (chiave abbreviata: .)}
helpMsg I .button.coords {Coordinate on/off  (chiave abbreviata: 0)}
helpMsg I .button.stm {Visualizza l'icona di chi ha la mossa (si/no)}
helpMsg I .button.autoplay {Mosse automatiche  (chiave: Ctrl+Z)}

# General buttons:
translate I Back {Indietro}
translate I Browse {Browse}
translate I Cancel {Cancella}
# ====== TODO To be translated ======
translate I Continue {Continue}
translate I Clear {Annulla}
translate I Close {Chiudi}
translate I Contents {Contents}
translate I Defaults {Defaults}
translate I Delete {Annulla}
translate I Graph {Grafico}
translate I Help {Aiuto}
translate I Import {Importa}
translate I Index {Indice}
translate I LoadGame {Carica partita}
translate I BrowseGame {Visualizza partita}
translate I MergeGame {Fondi partita}
# ====== TODO To be translated ======
translate I MergeGames {Merge Games}
translate I Preview {Anteprima}
translate I Revert {Rovescia}
translate I Save {Salva}
translate I Search {Cerca}
translate I Stop {Stop}
translate I Store {Memorizza}
translate I Update {Aggiorna}
translate I ChangeOrient {Modifica l'orientamento della finestra}
translate I ShowIcons {Show Icons} ;# ***
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
translate I Months {Gennaio Febbraio Marzo Aprile Maggio Giugno Luglio Agosto Settembre Ottobre Novembre Dicembre}
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
translate I readonly {sola-lettura}

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
translate I PInfoEditRatings {Edita i Ratings}

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
# ====== TODO To be translated ======
menuText I TreeFileFillWithBase "Fill Cache with base" 0 {Fill the cache file with all games in current base}
# ====== TODO To be translated ======
menuText I TreeFileFillWithGame "Fill Cache with game" 0 {Fill the cache file with current game in current base}
# ====== TODO To be translated ======
menuText I TreeFileSetCacheSize "Cache size" 0 {Set the cache size}
# ====== TODO To be translated ======
menuText I TreeFileCacheInfo "Cache info" 0 {Get info on cache usage}
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
# ====== TODO To be translated ======
menuText I TreeOptSlowmode "slow mode" 0 {Slow mode for updates (high accuracy)}
# ====== TODO To be translated ======
menuText I TreeOptFastmode "Fast mode" 0 {Fast mode for updates (no move transposition)}
# ====== TODO To be translated ======
menuText I TreeOptFastAndSlowmode "Fast and slow mode" 0 {Fast mode then slow mode for updates}
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
  {    Mossa  ECO       Frequenza    Punt.  AvElo Perf AvAnno %Patta}
translate I TreeTotal {TOTALE}

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
translate I FileFinder {Trova File}
translate I FinderDir {Trova Directory}
translate I FinderDirs {Trova Directories}
translate I FinderFiles {Trova Files}
translate I FinderUpDir {Su}

# Player finder:
menuText I PListFile "File" 0
menuText I PListFileUpdate "Aggiorna" 0
menuText I PListFileClose "Chiudi Player Finder" 0
menuText I PListSort "Ordina" 0
menuText I PListSortName "Nome" 0
menuText I PListSortElo "Elo" 0
menuText I PListSortGames "Partite" 0
menuText I PListSortOldest "Più vecchie" 0
menuText I PListSortNewest "Più recenti" 0

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
# ====== TODO To be translated ======
translate I GraphAbsFilterTitle "Filter Graph: frequency of the games"
# ====== TODO To be translated ======
translate I ConfigureFilter {Configure X-Axes for Year, Rating and Moves}
# ====== TODO To be translated ======
translate I FilterEstimate "Estimate"
# ====== TODO To be translated ======
translate I TitleFilterGraph "Scid: Filter Graph"

# Analysis window:
translate I AddVariation {Aggiungi variante}
translate I AddMove {Aggiunge una mossa}
translate I Annotate {Annota}
# ====== TODO To be translated ======
translate I ShowAnalysisBoard {Show analysis board}
# ====== TODO To be translated ======
translate I FinishGame {Finish game}
# ====== TODO To be translated ======
translate I StopEngine {Stop engine}
# ====== TODO To be translated ======
translate I StartEngine {Start engine}
translate I AnalysisCommand {Comando di analisi}
translate I PreviousChoices {Scelta precedente}
translate I AnnotateTime {Imposta il tempo tra le mosse in secondi}
translate I AnnotateWhich {Aggiungi varianti}
translate I AnnotateAll {Per mosse di entrambi i colori}
# ====== TODO To be translated ======
translate I AnnotateAllMoves {Annotate all moves}
translate I AnnotateWhite {Per solo le mosse del Bianco}
translate I AnnotateBlack {Per solo le mosse del Nero}
translate I AnnotateNotBest {Quando la mossa della partita non e' la migliore}
# ====== TODO To be translated ======
translate I AnnotateBlundersOnly {When game move is an obvious blunder}
# ====== TODO To be translated ======
translate I AnnotateBlundersOnlyScoreChange {Analysis reports blunder, with score change from/to: }
# ====== TODO To be translated ======
translate I BlundersThreshold {Threshold}
translate I LowPriority {Imposta la priorità della CPU a bassa}
# ====== TODO To be translated ======
translate I ClickHereToSeeMoves {Click here to see moves}
# ====== TODO To be translated ======
translate I ConfigureInformant {Configure Informant}
# ====== TODO To be translated ======
translate I Informant!? {Interesting move}
# ====== TODO To be translated ======
translate I Informant? {Poor move}
# ====== TODO To be translated ======
translate I Informant?? {Blunder}
# ====== TODO To be translated ======
translate I Informant?! {Dubious move}
# ====== TODO To be translated ======
translate I Informant+= {White has a slight advantage}
# ====== TODO To be translated ======
translate I Informant+/- {White has a moderate advantage}
# ====== TODO To be translated ======
translate I Informant+- {White has a decisive advantage}
# ====== TODO To be translated ======
translate I Informant++- {The game is considered won}
# ====== TODO To be translated ======
translate I Book {Book}

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
menuText I PgnFileCopy "Copia la partita verso la Clipboard" 0
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
menuText I PgnOptBoldMainLine "Usa il grassetto per le mosse della linea principale" 4
menuText I PgnColor "Colori" 0
menuText I PgnColorHeader "Intestazione..." 0
menuText I PgnColorAnno "Annotazioni..." 0
menuText I PgnColorComments "Commenti..." 0
menuText I PgnColorVars "Varianti..." 0
menuText I PgnColorBackground "Sfondo..." 0
# ====== TODO To be translated ======
menuText I PgnColorMain "Main line..." 0
# ====== TODO To be translated ======
menuText I PgnColorCurrent "Current move background..." 1
# ====== TODO To be translated ======
menuText I PgnColorNextMove "Next move background..." 0
menuText I PgnHelp "Aiuto" 0
menuText I PgnHelpPgn "Aiuto PGN" 0
menuText I PgnHelpIndex "Indice" 0
translate I PgnWindowTitle {Notazione - partita %u}

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
menuText I OprepFavorites "Preferiti" 1
menuText I OprepFavoritesAdd "Aggiungi Report..." 0
menuText I OprepFavoritesEdit "Edita i Report preferiti..." 0
menuText I OprepFavoritesGenerate "Genera Reports..." 0

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
translate I EndSideToMove {Side to move at end of game} ;# ***
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
# ====== TODO To be translated ======
translate I GlistRemoveThisGameFromFilter  {Remove this game from Filter}
# ====== TODO To be translated ======
translate I GlistRemoveGameAndAboveFromFilter  {Remove game (and all above it) from Filter}
# ====== TODO To be translated ======
translate I GlistRemoveGameAndBelowFromFilter  {Remove game (and all below it) from Filter}
# ====== TODO To be translated ======
translate I GlistDeleteGame {(Un)Delete this game} 
# ====== TODO To be translated ======
translate I GlistDeleteAllGames {Delete all games in filter} 
# ====== TODO To be translated ======
translate I GlistUndeleteAllGames {Undelete all games in filter} 

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

# ====== TODO To be translated ======
translate I TwinCheckUndelete {to flip; "u" undeletes both)}
# ====== TODO To be translated ======
translate I TwinCheckprevPair {Previous pair}
# ====== TODO To be translated ======
translate I TwinChecknextPair {Next pair}
# ====== TODO To be translated ======
translate I TwinChecker {Scid: Twin game checker}
# ====== TODO To be translated ======
translate I TwinCheckTournament {Games in tournament:}
# ====== TODO To be translated ======
translate I TwinCheckNoTwin {No twin  }
# ====== TODO To be translated ======
translate I TwinCheckNoTwinfound {No twin was detected for this game.\nTo show twins using this window, you must first use the "Delete twin games..." function. }
# ====== TODO To be translated ======
translate I TwinCheckTag {Share tags...}
# ====== TODO To be translated ======
translate I TwinCheckFound1 {Scid found $result twin games}
# ====== TODO To be translated ======
translate I TwinCheckFound2 { and set their delete flags}
# ====== TODO To be translated ======
translate I TwinCheckNoDelete {There are no games in this database to delete.}
# ====== TODO To be translated ======
translate I TwinCriteria1 { Your settings for finding twin games are potentially likely to\ncause non-twin games with similar moves to be marked as twins.}
# ====== TODO To be translated ======
translate I TwinCriteria2 {It is recommended that if you select "No" for "same moves", you should select "Yes" for the colors, event, site, round, year and month settings.\nDo you want to continue and delete twins anyway? }
# ====== TODO To be translated ======
translate I TwinCriteria3 {It is recommended that you specify "Yes" for at least two of the "same site", "same round" and "same year" settings.\nDo you want to continue and delete twins anyway?}
# ====== TODO To be translated ======
translate I TwinCriteriaConfirm {Scid: Confirm twin settings}
# ====== TODO To be translated ======
translate I TwinChangeTag "Change the following game tags:\n\n"
# ====== TODO To be translated ======
translate I AllocRatingDescription "This command will use the current spellcheck file to add Elo ratings to games in this database. Wherever a player has no currrent rating but his/her rating at the time of the game is listed in the spellcheck file, that rating will be added."
# ====== TODO To be translated ======
translate I RatingOverride "Overwrite existing non-zero ratings?"
# ====== TODO To be translated ======
translate I AddRatings "Add ratings to:"
# ====== TODO To be translated ======
translate I AddedRatings {Scid added $r Elo ratings in $g games.}
# ====== TODO To be translated ======
translate I NewSubmenu "New submenu"

# Comment editor:
translate I AnnotationSymbols  {Simboli di annotazione:}
translate I Comment {Commento:}
translate I InsertMark {Inserisci marcatore}
translate I InsertMarkHelp {
Inserisci/togli marcatore: Seleziona colore, tipo, casella.
Inserisci/togli freccia: Doppio-click due caselle.
}

# Nag buttons in comment editor:
translate I GoodMove {Mossa buona}
translate I PoorMove {Mossa debole}
translate I ExcellentMove {Mossa ottima}
translate I Blunder {Svista}
translate I InterestingMove {Mossa interessante}
translate I DubiousMove {Mossa dubbia}
translate I WhiteDecisiveAdvantage {Il Bianco è in vantaggio decisivo}
translate I BlackDecisiveAdvantage {Il Nero è in vantaggio decisivo}
translate I WhiteClearAdvantage {Il Bianco sta meglio}
translate I BlackClearAdvantage {Il Nero sta meglio}
translate I WhiteSlightAdvantage {Il Bianco sta leggermente meglio}
translate I BlackSlightAdvantage {Il Nero sta leggermente meglio}
translate I Equality {Parità}
translate I Unclear {Incerta}
translate I Diagram {Diagramma}

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

# Common endings in material search:
translate I EndingPawns {Pawn endings} ;# ***
translate I EndingRookVsPawns {Rook vs. Pawn(s)} ;# ***
translate I EndingRookPawnVsRook {Rook and 1 Pawn vs. Rook} ;# ***
translate I EndingRookPawnsVsRook {Rook and Pawn(s) vs. Rook} ;# ***
translate I EndingRooks {Rook vs. Rook endings} ;# ***
translate I EndingRooksPassedA {Rook vs. Rook endings with a passed a-pawn} ;# ***
translate I EndingRooksDouble {Double Rook endings} ;# ***
translate I EndingBishops {Bishop vs. Bishop endings} ;# ***
translate I EndingBishopVsKnight {Bishop vs. Knight endings} ;# ***
translate I EndingKnights {Knight vs. Knight endings} ;# ***
translate I EndingQueens {Queen vs. Queen endings} ;# ***
translate I EndingQueenPawnVsQueen {Queen and 1 Pawn vs. Queen} ;# ***
translate I BishopPairVsKnightPair {Two Bishops vs. Two Knights middlegame} ;# ***

# Common patterns in material search:
translate I PatternWhiteIQP {White IQP} ;# ***
translate I PatternWhiteIQPBreakE6 {White IQP: d4-d5 break vs. e6} ;# ***
translate I PatternWhiteIQPBreakC6 {White IQP: d4-d5 break vs. c6} ;# ***
translate I PatternBlackIQP {Black IQP} ;# ***
translate I PatternWhiteBlackIQP {White IQP vs. Black IQP} ;# ***
translate I PatternCoupleC3D4 {White c3+d4 Isolated Pawn Couple} ;# ***
translate I PatternHangingC5D5 {Black Hanging Pawns on c5 and d5} ;# ***
translate I PatternMaroczy {Maroczy Center (with Pawns on c4 and e4)} ;# ***
translate I PatternRookSacC3 {Rook Sacrifice on c3} ;# ***
translate I PatternKc1Kg8 {O-O-O vs. O-O (Kc1 vs. Kg8)} ;# ***
translate I PatternKg1Kc8 {O-O vs. O-O-O (Kg1 vs. Kc8)} ;# ***
translate I PatternLightFian {Light-Square Fianchettos (Bishop-g2 vs. Bishop-b7)} ;# ***
translate I PatternDarkFian {Dark-Square Fianchettos (Bishop-b2 vs. Bishop-g7)} ;# ***
translate I PatternFourFian {Four Fianchettos (Bishops on b2,g2,b7,g7)} ;# ***

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
# ====== TODO To be translated ======
translate I SaveAndContinue {Save and continue}
# ====== TODO To be translated ======
translate I DiscardChangesAndContinue {Discard changes\nand continue}
# ====== TODO To be translated ======
translate I GoBack {Go back}

# Replace move dialog:
translate I ReplaceMove {Sostituisci la mossa}
translate I AddNewVar {Aggiunge una nuova variante}
# ====== TODO To be translated ======
translate I NewMainLine {New Main Line}
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
# ====== TODO To be translated ======
translate I OverwriteExistingMoves {Overwrite existing moves ?}

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
translate I OprepMostFrequentOpponents {Avversari più frequenti}
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
translate I OprepMostFrequentEcoCodes {Codici ECO più frequenti}
translate I OprepThemes {Temi Posizionali}
translate I OprepThemeDescription {Frequenza dei Temi nelle prime %u mosse di ogni partita}
translate I OprepThemeSameCastling {Arrocco dallo stesso lato}
translate I OprepThemeOppCastling {Arrocchi eterogenei}
translate I OprepThemeNoCastling {Entrambi i re non arroccati}
translate I OprepThemeKPawnStorm {Attacco di pedoni sull'ala di re}
translate I OprepThemeQueenswap {Scambio di donne}
translate I OprepThemeWIQP {Pedone di donna Bianco isolato}
translate I OprepThemeBIQP {Pedone di donna Nero isolato}
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
translate I OprepViewHTML {Vedi HTML}
translate I OprepViewLaTeX {Vedi LaTeX}

# Player Report:
translate I PReportTitle {Report sul giocatore}
translate I PReportColorWhite {con i pezzi Bianchi}
translate I PReportColorBlack {con i pezzi Neri}
translate I PReportMoves {dopo %s}
translate I PReportOpenings {Aperture}
translate I PReportClipbase {Svuota la Clipbase e copia le partite risultanti in essa}

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
translate I TwinsNote {Per essere doppie, due partite devono almeno avere gli stessi due giocatori, e criteri che puoi definire sotto. Quando viene trovata una coppia di doppie, la partita piu' breve e' cancellata. Suggerimento: E' meglio controllare per caratteri il database prima di cancellare le doppie, per migliorare la ricerca delle doppie.}
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
# ====== TODO To be translated ======
translate I NoUnusedNames "There are no unused names, so the name file is already fully compacted."
# ====== TODO To be translated ======
translate I NoUnusedGames "The game file is already fully compacted."
# ====== TODO To be translated ======
translate I NameFileCompacted {The name file for the database "[file tail [sc_base filename]]" was compacted.}
# ====== TODO To be translated ======
translate I GameFileCompacted {The game file for the database "[file tail [sc_base filename]]" was compacted.}

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
 le [::utils::thousands $nGamesToCopy] partite dal filtro
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

# Sounds configuration:
translate I SoundsFolder {Sound Files Folder} ;# ***
translate I SoundsFolderHelp {The folder should contain the files King.wav, a.wav, 1.wav, etc} ;# ***
translate I SoundsAnnounceOptions {Move Announcement Options} ;# ***
translate I SoundsAnnounceNew {Announce new moves as they are made} ;# ***
translate I SoundsAnnounceForward {Announce moves when moving forward one move} ;# ***
translate I SoundsAnnounceBack {Announce when retracting or moving back one move} ;# ***

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

# My Player Names options:
translate I MyPlayerNamesDescription {
Inserisci sotto una lista di giocatori preferiti, un nome per linea. Wildcards (e.g. "?" per ogni singolo carattere, "*" per ogni sequenza di caratteri) sono accettati.

Ogni volta che viene caricata una partita con un giocatore nella lista, la finestra principale della scacchiera se necessario ruoterà e vi proporrà la partita dal punto di vista di quel giocatore.
}
# ====== TODO To be translated ======
translate I showblunderexists {show blunder exists}
# ====== TODO To be translated ======
translate I showblundervalue {show blunder value}
# ====== TODO To be translated ======
translate I showscore {show score}
# ====== TODO To be translated ======
translate I coachgame {coach game}
# ====== TODO To be translated ======
translate I configurecoachgame {configure coach game}
# ====== TODO To be translated ======
translate I configuregame {Game configuration}
# ====== TODO To be translated ======
translate I Phalanxengine {Phalanx engine}
# ====== TODO To be translated ======
translate I Coachengine {Coach engine}
# ====== TODO To be translated ======
translate I difficulty {difficulty}
# ====== TODO To be translated ======
translate I hard {hard}
# ====== TODO To be translated ======
translate I easy {easy}
# ====== TODO To be translated ======
translate I Playwith {Play with}
# ====== TODO To be translated ======
translate I white {white}
# ====== TODO To be translated ======
translate I black {black}
# ====== TODO To be translated ======
translate I both {both}
# ====== TODO To be translated ======
translate I Play {Play}
# ====== TODO To be translated ======
translate I Noblunder {No blunder}
# ====== TODO To be translated ======
translate I blunder {blunder}
# ====== TODO To be translated ======
translate I Noinfo {-- No info --}
# ====== TODO To be translated ======
translate I PhalanxOrCraftyMissing {Phalanx or Crafty not found}
# ====== TODO To be translated ======
# ====== TODO To be translated ======
translate I moveblunderthreshold {move is a blunder if loss is greater than}
# ====== TODO To be translated ======
translate I limitanalysis {limit engine analysis time}
# ====== TODO To be translated ======
translate I seconds {seconds}
# ====== TODO To be translated ======
translate I Abort {Abort}
# ====== TODO To be translated ======
translate I OutOfOpening {Out of opening}
# ====== TODO To be translated ======
translate I NotFollowedLine {You did not follow the line}
# ====== TODO To be translated ======
translate I DoYouWantContinue {Do you want yo continue ?}
# ====== TODO To be translated ======
translate I CoachIsWatching {Coach is watching}
# ====== TODO To be translated ======
translate I Ponder {Permanent thinking}
# ====== TODO To be translated ======
translate I DubiousMovePlayedTakeBack {Dubious move played, do you want to take back ?}
# ====== TODO To be translated ======
translate I WeakMovePlayedTakeBack {Weak move played, do you want to take back ?}
# ====== TODO To be translated ======
translate I BadMovePlayedTakeBack {Bad move played, do you want to take back ?}
# ====== TODO To be translated ======
translate I Iresign {I resign}
# ====== TODO To be translated ======
translate I yourmoveisnotgood {your move is not good}
# ====== TODO To be translated ======
translate I EndOfVar {End of variation}
# ====== TODO To be translated ======
translate I Openingtrainer {Opening trainer}
# ====== TODO To be translated ======
translate I DisplayCM {Display candidate moves}
# ====== TODO To be translated ======
translate I DisplayCMValue {Display candidate moves value}
# ====== TODO To be translated ======
translate I DisplayOpeningStats {Show statistics}
# ====== TODO To be translated ======
translate I ShowReport {Show report}
# ====== TODO To be translated ======
translate I PlayerBestMove  {Allow only best moves}
# ====== TODO To be translated ======
translate I OpponentBestMove {Opponent plays best moves}
# ====== TODO To be translated ======
translate I OnlyFlaggedLines {Only flagged lines}
# ====== TODO To be translated ======
translate I resetStats {Reset statistics}
# ====== TODO To be translated ======
translate I Repertoiretrainingconfiguration {Repertoire training configuration}
# ====== TODO To be translated ======
translate I Loadingrepertoire {Loading repertoire}
# ====== TODO To be translated ======
translate I Movesloaded {Moves loaded}
# ====== TODO To be translated ======
translate I Repertoirenotfound {Repertoire not found}
# ====== TODO To be translated ======
translate I Openfirstrepertoirewithtype {Open first a repertoire database with icon/type set to the right side}
# ====== TODO To be translated ======
translate I Movenotinrepertoire {Move not in repertoire}
# ====== TODO To be translated ======
translate I PositionsInRepertoire {Positions in repertoire}
# ====== TODO To be translated ======
translate I PositionsNotPlayed {Positions not played}
# ====== TODO To be translated ======
translate I PositionsPlayed {Positions played}
# ====== TODO To be translated ======
translate I Success {Success}
# ====== TODO To be translated ======
translate I DubiousMoves {Dubious moves}
# ====== TODO To be translated ======
translate I OutOfRepertoire {OutOfRepertoire}
# ====== TODO To be translated ======
# ====== TODO To be translated ======
# ====== TODO To be translated ======
# ====== TODO To be translated ======
translate I ConfigureTactics {Configure tactics}
# ====== TODO To be translated ======
translate I ResetScores {Reset scores}
# ====== TODO To be translated ======
translate I LoadingBase {Loading base}
# ====== TODO To be translated ======
translate I Tactics {Tactics}
# ====== TODO To be translated ======
translate I ShowSolution {Show solution}
# ====== TODO To be translated ======
translate I Next {Next}
# ====== TODO To be translated ======
translate I ResettingScore {Resetting score}
# ====== TODO To be translated ======
translate I LoadingGame {Loading game}
# ====== TODO To be translated ======
translate I MateFound {Mate found}
# ====== TODO To be translated ======
translate I BestSolutionNotFound {Best solution NOT found !}
# ====== TODO To be translated ======
translate I MateNotFound {Mate not found}
# ====== TODO To be translated ======
translate I ShorterMateExists {Shorter mate exists}
# ====== TODO To be translated ======
translate I ScorePlayed {Score played}
# ====== TODO To be translated ======
translate I Expected {expected}
# ====== TODO To be translated ======
translate I ChooseTrainingBase {Choose training base}
# ====== TODO To be translated ======
translate I Thinking {Thinking}
# ====== TODO To be translated ======
translate I AnalyzeDone {Analyze done}
# ====== TODO To be translated ======
translate I WinWonGame {Win won game}
# ====== TODO To be translated ======
translate I Lines {Lines}
# ====== TODO To be translated ======
translate I ConfigureUCIengine {Configure UCI engine}
# ====== TODO To be translated ======
translate I SpecificOpening {Specific opening}
# ====== TODO To be translated ======
translate I RandomLevel {Random level}
# ====== TODO To be translated ======
translate I StartFromCurrentPosition {Start from current position}
# ====== TODO To be translated ======
translate I FixedDepth {Fixed depth}
# ====== TODO To be translated ======
translate I Nodes {Nodes} 
# ====== TODO To be translated ======
translate I Depth {Depth}
# ====== TODO To be translated ======
translate I Time {Time} 
# ====== TODO To be translated ======
translate I SecondsPerMove {Seconds per move}
# ====== TODO To be translated ======
translate I TimeBonus {Time + bonus}
# ====== TODO To be translated ======
translate I WhiteTime {White time (minutes + sec/move)}
# ====== TODO To be translated ======
translate I BlackTime {Black time (minutes + sec/move)}
# ====== TODO To be translated ======
translate I AllExercisesDone {All exercises done}
# ====== TODO To be translated ======
translate I MoveOutOfBook {Move out of book}
# ====== TODO To be translated ======
translate I LastBookMove {Last book move}
# ====== TODO To be translated ======
translate I AnnotateSeveralGames {Annotate several games\nfrom current to :}
# ====== TODO To be translated ======
translate I FindOpeningErrors {Find opening errors}
# ====== TODO To be translated ======
translate I UseBook {Use book}
# ====== TODO To be translated ======
translate I MultiPV {Multiple variations}
# ====== TODO To be translated ======
translate I Hash {Hash memory}
# ====== TODO To be translated ======
translate I OwnBook {Use engine book}
# ====== TODO To be translated ======
translate I BookFile {Opening book}
# ====== TODO To be translated ======
translate I AnnotateVariations {Annotate variations}
# ====== TODO To be translated ======
translate I ShortAnnotations {Short annotations}
# ====== TODO To be translated ======
translate I addAnnotatorTag {Add annotator tag}
# ====== TODO To be translated ======
translate I AddScoreToShortAnnotations {Add score to short annotations}
# ====== TODO To be translated ======
translate I Export {Export}
# ====== TODO To be translated ======
translate I BookPartiallyLoaded {Book partially loaded}
# ====== TODO To be translated ======
translate I Calvar {Calculation of variations}
# ====== TODO To be translated ======
translate I ConfigureCalvar {Configuration}
# ====== TODO To be translated ======
# ====== TODO To be translated ======
translate I Reti {Reti}
# ====== TODO To be translated ======
translate I English {English}
# ====== TODO To be translated ======
translate I d4Nf6Miscellaneous {1.d4 Nf6 Miscellaneous}
# ====== TODO To be translated ======
translate I Trompowsky {Trompowsky}
# ====== TODO To be translated ======
translate I Budapest {Budapest}
# ====== TODO To be translated ======
translate I OldIndian {Old Indian}
# ====== TODO To be translated ======
translate I BenkoGambit {Benko Gambit}
# ====== TODO To be translated ======
translate I ModernBenoni {Modern Benoni}
# ====== TODO To be translated ======
translate I DutchDefence {Dutch Defence}
# ====== TODO To be translated ======
translate I Scandinavian {Scandinavian}
# ====== TODO To be translated ======
translate I AlekhineDefence {Alekhine Defence}
# ====== TODO To be translated ======
translate I Pirc {Pirc}
# ====== TODO To be translated ======
translate I CaroKann {Caro-Kann}
# ====== TODO To be translated ======
translate I CaroKannAdvance {Caro-Kann Advance}
# ====== TODO To be translated ======
translate I Sicilian {Sicilian}
# ====== TODO To be translated ======
translate I SicilianAlapin {Sicilian Alapin}
# ====== TODO To be translated ======
translate I SicilianClosed {Sicilian Closed}
# ====== TODO To be translated ======
translate I SicilianRauzer {Sicilian Rauzer}
# ====== TODO To be translated ======
translate I SicilianDragon {Sicilian Dragon}
# ====== TODO To be translated ======
translate I SicilianScheveningen {Sicilian Scheveningen}
# ====== TODO To be translated ======
translate I SicilianNajdorf {Sicilian Najdorf}
# ====== TODO To be translated ======
translate I OpenGame {Open Game}
# ====== TODO To be translated ======
translate I Vienna {Vienna}
# ====== TODO To be translated ======
translate I KingsGambit {King's Gambit}
# ====== TODO To be translated ======
translate I RussianGame {Russian Game}
# ====== TODO To be translated ======
translate I ItalianTwoKnights {Italian/Two Knights}
# ====== TODO To be translated ======
translate I Spanish {Spanish}
# ====== TODO To be translated ======
translate I SpanishExchange {Spanish Exchange}
# ====== TODO To be translated ======
translate I SpanishOpen {Spanish Open}
# ====== TODO To be translated ======
translate I SpanishClosed {Spanish Closed}
# ====== TODO To be translated ======
translate I FrenchDefence {French Defence}
# ====== TODO To be translated ======
translate I FrenchAdvance {French Advance}
# ====== TODO To be translated ======
translate I FrenchTarrasch {French Tarrasch}
# ====== TODO To be translated ======
translate I FrenchWinawer {French Winawer}
# ====== TODO To be translated ======
translate I FrenchExchange {French Exchange}
# ====== TODO To be translated ======
translate I QueensPawn {Queen's Pawn}
# ====== TODO To be translated ======
translate I Slav {Slav}
# ====== TODO To be translated ======
translate I QGA {QGA}
# ====== TODO To be translated ======
translate I QGD {QGD}
# ====== TODO To be translated ======
translate I QGDExchange {QGD Exchange}
# ====== TODO To be translated ======
translate I SemiSlav {Semi-Slav}
# ====== TODO To be translated ======
translate I QGDwithBg5 {QGD with Bg5}
# ====== TODO To be translated ======
translate I QGDOrthodox {QGD Orthodox}
# ====== TODO To be translated ======
translate I Grunfeld {Grünfeld}
# ====== TODO To be translated ======
translate I GrunfeldExchange {Grünfeld Exchange}
# ====== TODO To be translated ======
translate I GrunfeldRussian {Grünfeld Russian}
# ====== TODO To be translated ======
translate I Catalan {Catalan}
# ====== TODO To be translated ======
translate I CatalanOpen {Catalan Open}
# ====== TODO To be translated ======
translate I CatalanClosed {Catalan Closed}
# ====== TODO To be translated ======
translate I QueensIndian {Queen's Indian}
# ====== TODO To be translated ======
translate I NimzoIndian {Nimzo-Indian}
# ====== TODO To be translated ======
translate I NimzoIndianClassical {Nimzo-Indian Classical}
# ====== TODO To be translated ======
translate I NimzoIndianRubinstein {Nimzo-Indian Rubinstein}
# ====== TODO To be translated ======
translate I KingsIndian {King's Indian}
# ====== TODO To be translated ======
translate I KingsIndianSamisch {King's Indian Sämisch}
# ====== TODO To be translated ======
translate I KingsIndianMainLine {King's Indian Main Line}
# ====== TODO To be translated ======
translate I CCDlgConfigureWindowTitle {Configure Correspondence Chess}
# ====== TODO To be translated ======
translate I CCDlgCGeneraloptions {General Options}
# ====== TODO To be translated ======
translate I CCDlgDefaultDB {Default Database:}
# ====== TODO To be translated ======
translate I CCDlgInbox {Inbox (path):}
# ====== TODO To be translated ======
translate I CCDlgOutbox {Outbox (path):}
# ====== TODO To be translated ======
translate I CCDlgXfcc {Xfcc Configuration:}
# ====== TODO To be translated ======
translate I CCDlgExternalProtocol {External Protocol Handler (e.g. Xfcc)}
# ====== TODO To be translated ======
translate I CCDlgFetchTool {Fetch Tool:}
# ====== TODO To be translated ======
translate I CCDlgSendTool {Send Tool:}
# ====== TODO To be translated ======
translate I CCDlgEmailCommunication {eMail Communication}
# ====== TODO To be translated ======
translate I CCDlgMailPrg {Mail program:}
# ====== TODO To be translated ======
translate I CCDlgBCCAddr {(B)CC Address:}
# ====== TODO To be translated ======
translate I CCDlgMailerMode {Mode:}
# ====== TODO To be translated ======
translate I CCDlgThunderbirdEg {e.g. Thunderbird, Mozilla Mail, Icedove...}
# ====== TODO To be translated ======
translate I CCDlgMailUrlEg {e.g. Evolution}
# ====== TODO To be translated ======
translate I CCDlgClawsEg {e.g Sylpheed Claws}
# ====== TODO To be translated ======
translate I CCDlgmailxEg {e.g. mailx, mutt, nail...}
# ====== TODO To be translated ======
translate I CCDlgAttachementPar {Attachment parameter:}
# ====== TODO To be translated ======
translate I CCDlgInternalXfcc {Use internal Xfcc support}
# ====== TODO To be translated ======
translate I CCDlgSubjectPar {Subject parameter:}
# ====== TODO To be translated ======
translate I CCDlgStartEmail {Start new eMail game}
# ====== TODO To be translated ======
translate I CCDlgYourName {Your Name:}
# ====== TODO To be translated ======
translate I CCDlgYourMail {Your eMail Address:}
# ====== TODO To be translated ======
translate I CCDlgOpponentName {Opponents Name:}
# ====== TODO To be translated ======
translate I CCDlgOpponentMail {Opponents eMail Address:}
# ====== TODO To be translated ======
translate I CCDlgGameID {Game ID (unique):}
# ====== TODO To be translated ======
translate I CCDlgTitNoOutbox {Scid: Correspondence Chess Outbox}
# ====== TODO To be translated ======
translate I CCDlgTitNoInbox {Scid: Correspondence Chess Inbox}
# ====== TODO To be translated ======
translate I CCDlgTitNoGames {Scid: No Correspondence Chess Games}
# ====== TODO To be translated ======
translate I CCErrInboxDir {Correspondence Chess inbox directory:}
# ====== TODO To be translated ======
translate I CCErrOutboxDir {Correspondence Chess outbox directory:}
# ====== TODO To be translated ======
translate I CCErrDirNotUsable {does not exist or is not accessible!\nPlease check and correct the settings.}
# ====== TODO To be translated ======
translate I CCErrNoGames {does not contain any games!\nPlease fetch them first.}
# ====== TODO To be translated ======
translate I CCDlgTitNoCCDB {Scid: No Correspondence Database}
# ====== TODO To be translated ======
translate I CCErrNoCCDB {No Database of type 'Correspondence' is opened. Please open one before using correspondence chess functions.}
# ====== TODO To be translated ======
translate I DoneWithPosition {Done with position}
# ====== TODO To be translated ======
}

############################################################
#
# Italian tips section:

set tips(I) {
  {
    SCID ha oltre 30 <a Index>pagine di help</a>, e in molte finestre 
    premendo il tasto funzionale <b>F1</b> apparira' una pagina di help
    relativa alla finestra.
  }
  {
    Molte finestre di SCID (p.e. il database <a Switcher>database switcher</a>,
    ecc.) hanno un menu' collegato al pulsante destro del mouse. Prova a
    premerlo in ogni finestra per vedere se c'e' e quali funzionalita' permette.
  }
  {
    SCID ti consente piu' di una modalità per inserire le mosse, scegli
    quale preferisci. Puoi utilizzare il mouse (con o senza il suggerimento
    della mossa) o la tastiera (con o senza il completamento della mossa).
    Leggi la pagina di help <a Moves>inserire le mosse</a> per maggiori dettagli. 
  }
  {
    Se utilizzi pochi database che apri spesso, aggiungi un
    <a Bookmarks>segnalibro</a> a ognuno di essi e poi puoi aprirlo piu'
    velocemente con il Menu Segnalibri.
  }
  {
    Puoi visualizzare tutte le mosse della partita caricata (con ogni
    variante e/o commento) utilizzando la <a PGN>Finestra PGN</a>.
    Nella Finestra PGN puoi andare a ogni mossa premendo il tasto sinistro
    del mouse quando sei sulla mossa oppure visualizzare la posizione
    premendo il tasto centrale/destro del mouse.
  }
  {
    Puoi copiare partite da un database ad un'altro usando la tecnica del
    drag and drop utilizzando il tasto sinistro del mouse nella finestra 
    <a Switcher>database switcher</a>.
  }
  {
    SCID puo' aprire file PGN, anche se sono compressi con Gzip (con il
    suffisso .gz). I file PGN aperti sono a sola lettura cosi' puoi
    modificare un file PGN in SCID, creando un nuovo database SCID e copiando
    il file PGN in esso utilizzando il <a Switcher>database switcher</a>.
  }
  {
    Se hai un grosso database e usi spesso la finestra <a Tree>albero</a>,
    e' il caso di utilizzare <b>riempi il file cache</b> dalla Finestra
    Albero (menu file). Cio' memorizza le statistiche dell'albero delle
    piu' comuni posizioni di apertura rendendo piu' veloci gli accessi
    all'albero per quel database.
  }
  {
    La finestra <a Tree>albero</a> visualizza tutte le mosse giocate dalla
    posizione caricata, ma se vuoi vedere tutti gli ordini di mosse che
    raggiungono la posizione devi generare un <a OpReport>report di apertura</a>.
  }
  {
    Nella finestra <a GameList>elenco partite</a> premendo il tasto sinistro
    o desto del mouse sulla testata di ogni colonna puoi modificarne la
    larghezza.
  }
  {
    Con la finestra <a PInfo>informazioni sul giocatore</a> (che ottieni
    cliccando sui nomi dei giocatori nella info area sotto la finestra
    con la scacchiera) tu puoi facilmente, utilizzando il
    <a Searches Filter>filtro</a>, ottenere tutte le partite di un certo
    giocatore con i suoi risultati cliccando su ogni campo che appare
    <red>in rosso</red>.
  }
  {
    Quando studi un'apertura puo' essere utile effettuare una
    <a Searches Board>ricerca su scacchiera</a> con le opzioni
    <b>Pedoni</b> oppure <b>Colonne</b> sulla posizione che ti
    interessa, in maniera da evidenziarti se altre aperture 
    raggiungono la stessa struttura di pedoni.
  }
  {
    Nell'Area di informazioni sulla partita (sotto la scacchiera) tu puoi
    premere il tasto destro del mouse per ottenere un menu' per 
    personalizzarla. Per esempio puoi nascondere la prossima mossa e cio'
    e' utile quando visualizzi una partita per allenamento e vuoi pensare
    le mosse successive. 
  }
  {
    Se tu effettui spesso <a Maintenance>manutenzione</a> di un database
    di grosse dimensioni puoi effettuare tutte le attivita' in un colpo
    solo utilizzando il <a Maintenance Cleaner>pulitore</a>.
  }
  {
    Se tu hai un grosso database dove molte partite hanno il campo EventDate
    valorizzato e tu vuoi le partite in ordine di data utilizza
    <a Sorting>ordinamento</a> per EventDate/Event invece di Date/Event
    cosicche' otterrai insieme le partite dello stesso torneo anche se hanno
    date diverse (partendo dal presupposto che abbiano la stessa EventDate).
  }
  {
    Prima di <a Maintenance Twins>cancellare le partite doppie</a> e' meglio
    utilizzare il <a Maintenance Spellcheck>controllo ortografico</a> sul tuo
    database permettendo a SCID di identificare un numero maggiore di
    partite doppie e contrassegnarle per la cancellazione.
  }
  {
    <a Flags>Gli identificatori</a>  sono utili per evidenziare partite con
    caratteristiche particolari da ricercare successivamente (p.e. struttura
    di pedoni, tattica, ecc.). Puoi ricercare le partite contrassegnate
    utilizzando <a Searches Header>ricerca per intestazione</a>.
  }
  {
    Se stai visualizzando una partita e vuoi provare qualche altra mossa
    senza modificare la partita puoi entrare nel Modo Prova (con lo
    shortcut <b>Ctrl+space</b> oppure cliccando l'apposita icona).
    Quando hai finito puoi deselezionare il Modo Prova ritornando
    alla partita originale.
  }
  {
    Per cercare le partite maggiormente rilevanti (quelle con i giocatori
    con l'Elo piu' alto) in una posizione, apri la finestra <a Tree>albero</a>
    e da quella apri la Lista Migliori Partite.
    Puoi personalizzare la lista ottenendo solo le partite con un
    certo risultato che ti interessa.
  }
  {
    Un buon modo per studiare le aperture utilizzando un grosso database
    e' attivare il Modo Esercizio nella finestra <a Tree>albero</a> e
    giocare contro il database per vedere quali linee appaiono spesso.
  }
  {
    Se hai due database aperti e vuoi visualizzare le statistiche
    dell'<a Tree>albero</a> del primo database mentre esamini una
    partita del secondo database premi il pulsante <b>Blocca</b> nella
    finestra albero per bloccare il primo database ed allora selezionare
    il secondo database.
  }
  {
    Il <a Tmt>tournament finder</a> non e' solo utile per trovare un
    certo torneo, ma puo' essere usato anche per vedere quali tornei
    ha giocato recentemente un certo giocatore oppure vedere i tornei
    piu' importanti giocati in una certa nazione.
  }
  {
    La finestra <a Searches Material>Materiale/Schema</a> ti propone
    alcune possibilita', fra le piu' comuni, facilitandoti ricerche
    per aperture o centri partita a fine di studio.
  }
  {
    Quando effettui una ricerca per una particolare posizione
    nella finestra <a Searches Material>Materiale/Schema</a> e'
    spesso utile restringere la ricerca a partite che permangono
    nella posizione voluta almeno qualche mezza mossa eliminando
    partite che raggiungono la posizione voluta solo una volta. 
  }
  {
    Se tu hai un importante database e non vuoi correre il rischio
    di effettuare modifiche inopportune, seleziona <b>solo lettura...</b>
    dal <b>File</b> menu dopo averlo aperto, oppure cambia gli
    attributi a solo lettura.
  }
  {
    Se usi XBoard oppure WinBoard (oppure altri programmi scacchistici
    che possono copiare sulla clipboard la posizione attuale in notazione
    standard FEN) e vuoi copiare la tua posizione su SCID, il modo piu'
    facile e veloce e' selezionare <b>Copia Positione</b> dal menu File
    in XBoard/WinBoard e poi <b>Copia come posizione di partenza</b> dal
    menu Edita in SCID.  
  }
  {
    In una <a Searches Header>ricerca per intestazione</a>,
    giocatore/evento/luogo/turno non sono sensibili alle maiuscole e
    vengono cercate anche all'interno dei nomi. Puoi scegliere di
    fare una ricerca sensibile alle maiuscole (dove "?" = ogni singolo
    carattere e "*" = zero o piu' caratteri) digitando la stringa che
    vuoi trovare fra "virgolette". Per esempio digitando "*BEL" (con
    le virgolette) nel campo luogo otterrai tutte le partite giocate
    in Belgio ma non a Belgrado.
  }
  {
    Se vuoi correggere una mossa in una partita senza perdere le mosse
    giocate successivamente, apri la finestra <a Import>Importa</a>
    premi l'icona b>Incolla la partica corrente</b>, edita la mossa
    sbagliata e poi premi l'icona <b>Importa</b>.
  }
  {
    Se hai caricato un file di classificazione ECO, puoi andare alla
    posizione classificata piu' profonda della partita correntemente
    caricata con <b>Identifica apertura</b> nel menu <b>Partita</b>
    (shortcut: Ctrl+Shift+D).
  }
  {
    Se vuoi verificare le dimensioni di un file o la sua data di ultima
    modifica prima di aprirlo, utilizza <a Finder>file finder</a> per
    aprirlo.
  }
  {
    Un file di <a Repertoire>repertorio</a> e' un grande strumento per
    monitorare le tue aperture preferite e per trovare le partite nelle
    quali queste linee sono state giocate. Dopo aver memorizzato le tue
    aperture in un file di repertorio puoi effettuare ricerche tutte le
    volte che acquisisci nuovi file di partite e visualizzare le partite
    che ti interessano.
  }
  {
    Un <a OpReport>rapporto di apertura</a> e' molto utile per apprendere
    ulteriori informazioni su una particolare posizione. Puoi vedere il
    punteggio percentuale che raggiunge, se porta a rapide patte, i temi
    posizionali piu' comuni e molto altro.
  }
  {
    Puoi aggiungere i piu' comuni simboli di annotazione (!, !?, +=, ecc)
    alla posizione attualmente caricata con scorciatoie da tastiera senza
    necessita' di utilizzare <a Comment>l'editor di commenti<a>.
    Per esempio digitando "!" seguito dal tasto Conferma/Enter/Return
    aggiungerete il simbolo "!". Guarda la pagina di help
    <a Moves>Inserire le mosse</a> per maggiori informazioni.
  }
  {
    Se stai visualizzando un'apertura in un database con <a Tree>l'albero</a>
    puoi facilmente vedere i risultati percentuali dell'apertura che stai
    guardando (recenti e fra giocatori di Elo alto) aprendo la finestra
    Statistiche (shortcut: Ctrl+I).
  }
  {
    Puoi cambiare le dimensioni della scacchiera premendo i tasti
    <b>Ctrl</b> e <b>Shift</b>, e regolare le dimensioni premendo i tasti
    freccia <b>Left</b> o <b>Right</b> .
  }
  {
    Dopo una <a Searches>ricerca</a> puoi facilmente visualizzare tutte le
    partite trovate premendo <b>Ctrl</b> e con i tasti <b>Su</b> o <b>Giu'</b>
    caricare la precedente o successiva partita del <a Searches Filter>filtro</a>.
  }
}


# end of italian.tcl





