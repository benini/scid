# portbr.tcl:
# Scid in Brazilian Portuguese.
# Translated by Gilberto de Almeida Peres.

addLanguage B {Brazil Portuguese} 0

proc setLanguage_B {} {

# File menu:
menuText B File "Arquivo" 0
menuText B FileNew "Novo..." 0 {Cria uma nova base de dados Scid}
menuText B FileOpen "Abrir..." 0 {Abre uma base de dados Scid existente}
menuText B FileClose "Fechar" 0 {Fecha a base de dados Scid ativa}
menuText B FileFinder "Buscador" 0 {Abre a janela do Buscador de Arquivos}
menuText B FileBookmarks "Favoritos" 0 {Menu de Favoritos (atalho: Ctrl+B)}
menuText B FileBookmarksAdd "Adicionar a Favoritos" 0 \
  {Adiciona o posicao do jogo do banco de dados atual}
menuText B FileBookmarksFile "Arquivar Favorito" 0 \
  {Arquiva um Favorito para a posicao do jogo atual}
menuText B FileBookmarksEdit "Editar favoritos..." 0 \
  {Editar o menu de favoritos}
menuText B FileBookmarksList "Mostrar pastas como lista" 0 \
  {Mostra as pastas de favoritos em lista unica}
menuText B FileBookmarksSub "Mostrar pastas como submenus" 0 \
  {Mostra as pastas de favoritos como submenus}
menuText B FileMaint "Manutencao" 0 {Ferramentas de manutencao de bases de dados Scid}
menuText B FileMaintWin "Janela de Manutencao" 0 \
  {Abre/Fecha a janela de manutencao de bases de dados Scid}
menuText B FileMaintCompact "Compactar base de dados..." 0 \
  {Compacta arquivos de bases de dados, removendo jogos deletados e nomes nao utilizados}
menuText B FileMaintClass "Classificar jogos por ECO..." 2 \
  {Recalcula o codigo ECO de todos os jogos}
menuText B FileMaintSort "Ordenar base de dados..." 0 \
  {Ordena todos os jogos da base de dados}
menuText B FileMaintDelete "Apagar jogos duplicados..." 13 \
  {Encontra jogos duplicados e os marca para exclusao}
menuText B FileMaintTwin "Janela de verificacao de duplicatas" 10 \
  {Abre/atualiza a janela de verificacao de duplicatas}
menuText B FileMaintName "Ortografia de nomes" 14 {Ferramentas de edicao e correcao ortografica de nomes}
menuText B FileMaintNameEditor "Editor de Nomes" 0 \
  {Abre/fecha a janela do editor de nomes}
menuText B FileMaintNamePlayer "Verificacao Ortografica de Nomes de Jogadores..." 11 \
  {Verifica a correcao dos nomes dos jogadores de acordo com o arquivo de correcao ortografica}
menuText B FileMaintNameEvent "Verificacao Ortografica de Nomes de Eventos..." 11 \
  {Verifica a correcao dos nomes de eventos de acordo com o arquivo de verificacao ortografica}
menuText B FileMaintNameSite "Verificacao Ortografica de Lugares..." 11 \
  {Verifica a correcao dos nomes de lugares usando o arquivo de correcao ortografica}
menuText B FileMaintNameRound "Verificacao Ortografica de Rodadas..." 11 \
  {Verificacao dos nomes de rodadas usando o arquivo de correcao ortografica}
menuText B FileReadOnly "Apenas Leitura..." 7 \
  {Trata a base de dados corrente como arquivo de leitura, impedindo mudancas}
menuText B FileExit "Sair" 0 {Encerrar o Scid}

# Edit menu:
menuText B Edit "Editar" 0
menuText B EditAdd "Adiciona variante" 0 {Adiciona variante do movimento}
menuText B EditDelete "Deleta Variante" 0 {Exclui variante do movimento}
menuText B EditFirst "Converte para Primeira Variante" 14 \
  {Faz com que uma variante seja a primeira da lista}
menuText B EditMain "Converte variante para Linha Principal" 24 \
  {Faz com que uma variante se torne a Linha Principal}
menuText B EditTrial "Experimentar variante" 0 \
  {Inicia/Para experimentacao, para testar alguma nova ideia no tabuleiro}
menuText B EditStrip "Limpar Comentarios e Variantes" 2 \
  {Limpa comentarios e variantes no jogo atual}
menuText B EditStripComments "Limpar Comentarios" 0 \
  {Limpa comentarios e anotacoes no jogo atual}
menuText B EditStripVars "Limpar Variantes" 0 \
  {Limpa todas as variantes no jogo atual}
menuText B EditReset "Limpar a base de trabalho" 0 \
  {Limpa completamente a base de trabalho}
menuText B EditCopy "Copiar jogo para a base de trabalho" 0 \
  {Copia o jogo corrente para a base de trabalho}
menuText B EditPaste "Colar jogo da base de trabalho" 1 \
  {Cola o jogo ativo da base de trabalho}
menuText B EditSetup "Configura posicao inicial..." 12 \
  {Configura a posicao inicial para o jogo}
menuText B EditPasteBoard "Colar Posicao" 12 \
  {Configura a posicao inicial a partir da area de transferencia}

# Game menu:
menuText B Game "Jogo" 0
menuText B GameNew "Limpar Jogo" 0 \
  {Limpa o jogo corrente, descartando qualquer alteracao}
menuText B GameFirst "Primeiro Jogo" 5 {Carrega o primeiro jogo filtrado}
menuText B GamePrev "Jogo Anterior" 5 {Carrega o jogo anterior}
menuText B GameReload "Recarrega o Jogo atual" 3 \
  {Recarrega o jogo, descartando qualquer alteracao}
menuText B GameNext "Proximo Jogo" 5 {Carrega o proximo jogo}
menuText B GameLast "Ultimo Jogo" 8 {Carrega o ultimo jogo}
menuText B GameNumber "Carrega Jogo Numero..." 5 \
  {Carrega um jogo pelo seu numero}
menuText B GameReplace "Salvar: Substituir Jogo..." 8 \
  {Salva o jogo e substitui a versao antiga}
menuText B GameAdd "Salvar: Adicionar Jogo..." 9 \
  {Salva este jogo como um novo jogo na base de dados}
menuText B GameDeepest "Identificar Abertura" 0 \
  {Vai para a posicao mais avancada da partida, de acordo com o codigo ECO}
menuText B GameGotoMove "Ir para o movimento numero..." 5 \
  {Avanca o jogo ate o movimento desejado}
menuText B GameNovelty "Pesquisa Novidade..." 7 \
  {Procura o primeiro movimento deste jogo que nao tenha sido jogado antes}

# Search Menu:
menuText B Search "Pesquisa" 0
menuText B SearchReset "Limpar Filtragem" 0 {Limpa o criterio de pesquisa para incluir todos os jogos}
menuText B SearchNegate "Inverter Filtragem" 0 {Inverte o criterio de pesquisa para incluir apenas os jogos que nao atendem o criterio}
menuText B SearchCurrent "Posicao Atual..." 0 {Pesquisa a posicao atual do tabuleiro}
menuText B SearchHeader "Cabecalho..." 0 {Pesquisa por cabecalho (jogador, evento, etc)}
menuText B SearchMaterial "Material/Padrao..." 0 {Pesquisa por material ou padrao de posicao}
menuText B SearchUsing "Usar arquivo de opcoes de filtro..." 0 {Pesquisa usando arquivo com opcoes de filtro}

# Windows menu:
menuText B Windows "Janelas" 0
menuText B WindowsComment "Editor de Comentarios" 0 {Abre/fecha o editor de comentarios}
menuText B WindowsGList "Lista de Jogos" 0 {Abre/fecha a janela com a lista de jogos}
menuText B WindowsPGN "Notacao PGN" 0 \
  {Abre/fecha a janela com a notacao PGN do jogo}
menuText B WindowsTmt "Buscador de Torneio" 2 {Abre/Fecha o buscador de torneio}
menuText B WindowsSwitcher "Intercambio de bases de dados" 0 \
  {Abre/fecha a janela de intercambio de bases de dados}
menuText B WindowsMaint "Manutencao" 0 \
  {Abre/fecha a janela de manutencao}
menuText B WindowsECO "Listagem ECO" 0 {Abre/fecha a janela de listagem de codigo ECO}
menuText B WindowsRepertoire "Editor de Repertorio" 0 \
  {Abre/fecha a janela do editor de repertorio}
menuText B WindowsStats "Estatisticas" 0 \
  {Abre/fecha a janela de estatisticas}
menuText B WindowsTree "Arvore" 0 {Abre/fecha a janela da Arvore de pesquisa}
menuText B WindowsTB "Tabela base de Finais" 1 \
  {Abre/fecha a janela da tabela base de finais}

# Tools menu:
menuText B Tools "Ferramentas" 0
menuText B ToolsAnalysis "Analisador #1..." 0 \
  {Inicia ou para o 1o. Analisador}
menuText B ToolsAnalysis2 "Analisador #2..." 17 \
  {Inicia ou para o 2o. Analisador}
menuText B ToolsCross "Tabela de Cruzamento" 0 {Mostra a tabela de cruzamentos do torneio para o jogo corrente}
menuText B ToolsEmail "Gerenciador de e-mails" 0 \
  {Abre/fecha a janela do gerenciador de e-mails}
menuText B ToolsFilterGraph "Filter graph" 7 \
  {Open/close the filter graph window} ;# ***
menuText B ToolsOpReport "Relatorio de abertura" 0 \
  {Gera um relatorio de abertura para a posicao corrente}
menuText B ToolsTracker "Piece Tracker"  0 {Open the Piece Tracker window} ;# ***
menuText B ToolsPInfo "Informacao do Jogador"  0 \
  {Abre/atualiza a janela de informacao do jogador}
menuText B ToolsRating "Grafico de Rating" 0 \
  {Mostra, em um grafico, a evolucao do rating de um jogador}
menuText B ToolsScore "Grafico de Resultados" 0 {Mostra a janela com o grafico dos resultados}
menuText B ToolsExpCurrent "Exporta jogo corrente" 8 \
  {Grava o jogo corrente em um arquivo texto}
menuText B ToolsExpCurrentPGN "Exporta para PGN..." 15 \
  {Grava o jogo corrente em um arquivo PGN}
menuText B ToolsExpCurrentHTML "Exporta para HTML..." 15 \
  {Grava o jogo corrente em um arquivo HTML}
menuText B ToolsExpCurrentLaTeX "Exporta para LaTex..." 15 \
  {Grava o jogo corrente em um arquivo LaTex}
menuText B ToolsExpFilter "Exporta jogos filtrados" 1 \
  {Exporta todos os jogos filtrados para um arquivo texto}
menuText B ToolsExpFilterPGN "Exporta jogos filtrados - PGN..." 17 \
  {Exporta todos os jogos filtrados para um arquivo PGN}
menuText B ToolsExpFilterHTML "Exporta jogos filtrados - HTML..." 17 \
  {Exporta todos os jogos filtrados para um arquivo HTML}
menuText B ToolsExpFilterLaTeX "Exporta jogos filtrados - LaTex..." 17 \
  {Exporta todos os jogos filtrados para um arquivo LaTex}
menuText B ToolsImportOne "Importa PGN texto..." 0 \
  {Importa jogo de um texto em PGN}
menuText B ToolsImportFile "Importa arquivo de jogos PGN..." 7 \
  {Importa jogos de um arquivo PGN}

# Options menu:
menuText B Options "Opcoes" 0
menuText B OptionsSize "Tamanho do Tabuleiro" 0 {Muda o tamanho do tabuleiro}
menuText B OptionsPieces "Estilo de Pecas no Tabuleiro" 10 \
  {Muda o estilo das pecas mostradas no tabuleiro}
menuText B OptionsColors "Cores..." 0 {Muda as cores do tabuleiro}
menuText B OptionsExport "Exportacao" 0 {Muda as opcoes de exportacao de texto}
menuText B OptionsFonts "Fontes" 0 {Muda os fontes}
menuText B OptionsFontsRegular "Normal" 0 {Fonte Normal}
menuText B OptionsFontsSmall "Pequeno" 0 {Fonte pequeno}
menuText B OptionsFontsFixed "Fixo" 0 {Fonte de largura fixa}
menuText B OptionsGInfo "Informacoes do Jogo" 0 {Opcoes de informacao do jogo}
menuText B OptionsLanguage "Linguagem" 0 {Menu de selecao de linguagem}
menuText B OptionsMoves "Movimentos" 0 {Opcoes para entrada dos movimentos}
menuText B OptionsMovesAsk "Perguntar antes de substituir movimentos" 0 \
  {Pergunta antes de substituir movimentos existentes}
menuText B OptionsMovesDelay "Tempo de atraso p/ Jogo automatico..." 1 \
  {Define o tempo de espera antes de entrar no modo de jogo automatico}
menuText B OptionsMovesCoord "Entrada de movimentos por coordenadas" 0 \
  {Aceita o estilo de entrada de movimentos por coordenadas ("g1f3")}
menuText B OptionsMovesSuggest "Mostrar movimentos sugeridos" 0 \
  {Liga/desliga sugestao de movimentos}
menuText B OptionsMovesKey "Auto completar" 0 \
  {Liga/desliga auto completar a partir do que for digitado}
menuText B OptionsNumbers "Formato de Numeros" 0 {Selecione o formato usado para numeros}
menuText B OptionsStartup "Iniciar" 1 \
  {Seleciona janelas que serao abertas ao iniciar o programa}
menuText B OptionsWindows "Janelas" 0 {Opcoes para Janelas}
menuText B OptionsWindowsIconify "Auto-iconizar" 5 \
  {Iconizar todas as janelas quando a janela principal eh iconizada}
menuText B OptionsWindowsRaise "Manter no topo" 0 \
  {Mantem no topo certas janelas (ex. barras de progresso) sempre que sao obscurecidas por outras}
menuText B OptionsToolbar "Barra de Ferramentas da Janela Principal" 12 \
  {Exibe/Oculta a barra de ferramentas da janela principal}
menuText B OptionsECO "Carregar arquivo ECO..." 7 {Carrega o arquivo com a classificacao ECO}
menuText B OptionsSpell "Carregar arquivo de verificacao ortografica..." 6 \
  {Carrega o arquivo de verificacao ortografica do Scid}
menuText B OptionsTable "Diretorio de tabelas de base..." 0 \
  {Selecione um arquivo de tabela de base; todas as tabelas nesse diretorio serao usadas}
menuText B OptionsSave "Salvar Configuracao" 0 \
  "Salva a configuracao no arquivo $::optionsFile"
menuText B OptionsAutoSave "Salva Opcoes ao sair" 0 \
  {Salva automaticamente todas as opcoes quando sair do Scid}

# Help menu:
menuText B Help "Ajuda" 0
menuText B HelpIndex "Indice" 0 {Indice da Ajuda}
menuText B HelpGuide "Consulta Rapida" 0 {Mostra a pagina de consulta rapida}
menuText B HelpHints "Dicas" 0 {Mostra a pagina de dicas}
menuText B HelpContact "Informacoes para contato" 0 {Mostra a pagina com informacoes para contato}
menuText B HelpTip "Dica do dia" 0 {Mostra uma dica util do Scid}
menuText B HelpStartup "Janela de Inicializacao" 0 {Mostra a janela de inicializacao}
menuText B HelpAbout "Sobre Scid" 0 {Informacoes sobre o Scid}

# Game info box popup menu:
menuText B GInfoHideNext "Ocultar proximo movimento" 0
menuText B GInfoMaterial "Mostra valor de material" 0
menuText B GInfoFEN "Mostra Diagrama FEN" 16
menuText B GInfoMarks "Mostra setas e casas coloridas" 7
menuText B GInfoWrap "Quebra de linhas longas" 0
menuText B GInfoFullComment "Mostrar comentario completo" 8
menuText B GInfoTBNothing "Tabelas de Base: nada" 12
menuText B GInfoTBResult "Tabelas de Base: apenas resultado" 12
menuText B GInfoTBAll "Tabelas de Base: resultado e melhores movimentos" 19
menuText B GInfoDelete "Recuperar este jogo" 0
menuText B GInfoMark "Desmarcar este jogo" 0

# Main window buttons:
helpMsg B .button.start {Ir para o inicio do jogo  (tecla: Home)}
helpMsg B .button.end {Ir para o final do jogo  (tecla: End)}
helpMsg B .button.back {Retroceder um movimento  (tecla: Seta Esquerda)}
helpMsg B .button.forward {Avancar um movimento  (tecla: Seta Direita)}
helpMsg B .button.intoVar {Entrar na variante  (tecla de atalho: v)}
helpMsg B .button.exitVar {Sair da variante  (tecla de atalho: z)}
helpMsg B .button.flip {Girar tabuleiro  (tecla de atalho: .)}
helpMsg B .button.coords {Liga/desliga coordenadas  (tecla de atalho: 0)}
helpMsg B .button.autoplay {Jogo automatico  (tecla: Ctrl+Z)}

# General buttons:
translate B Back {Voltar}
translate B Cancel {Cancelar}
translate B Clear {Limpar}
translate B Close {Fechar}
translate B Defaults {Defaults}
translate B Delete {Deletar}
translate B Graph {Grafico}
translate B Help {Ajuda}
translate B Import {Importar}
translate B Index {Indice}
translate B LoadGame {Carrega jogo}
translate B BrowseGame {Listar jogo}
translate B MergeGame {Fazer merge do jogo}
translate B Preview {Visualizacao}
translate B Revert {Reverter}
translate B Save {Salvar}
translate B Search {Pesquisar}
translate B Stop {Parar}
translate B Store {Guardar}
translate B Update {Atualizar}
translate B ChangeOrient {Muda orientacao da janela}
translate B None {Nenhum}
translate B First {Primeiro}
translate B Current {Atual}
translate B Last {Ultimo}

# General messages:
translate B game {jogo}
translate B games {jogos}
translate B move {movimento}
translate B moves {movimentos}
translate B all {tudo}
translate B Yes {Sim}
translate B No {Nao}
translate B Both {Ambos}
translate B King {Rei}
translate B Queen {Dama}
translate B Rook {Torre}
translate B Bishop {Bispo}
translate B Knight {Cavalo}
translate B Pawn {Peao}
translate B White {Branco}
translate B Black {Preto}
translate B Player {Jogador}
translate B Rating {Rating}
translate B RatingDiff {Diferenca de Rating (Brancas - Pretas)}
translate B Event {Evento}
translate B Site {Lugar}
translate B Country {Pais}
translate B IgnoreColors {Ignorar cores}
translate B Date {Data}
translate B EventDate {Evento data}
translate B Decade {Decade} ;# ***
translate B Year {Ano}
translate B Month {Mes}
translate B Months {Janeiro Fevereiro Marco Abril Maio Junho
  Julho Agosto Setembro Outubro Novembro Dezembro}
translate B Days {Dom Seg Ter Qua Qui Sex Sab}
translate B YearToToday {Anos ate hoje}
translate B Result {Resultado}
translate B Round {Rodada}
translate B Length {Tamanho}
translate B ECOCode {ECO}
translate B ECO {ECO}
translate B Deleted {Apagado}
translate B SearchResults {Resultados da Pesquisa}
translate B OpeningTheDatabase {Abrindo a Base de Dados}
translate B Database {Base de dados}
translate B Filter {Filtro}
translate B noGames {nenhum jogo}
translate B allGames {todos os jogos}
translate B empty {vazio}
translate B clipbase {base de trabalho}
translate B score {Pontuacao}
translate B StartPos {Posicao Inicial}
translate B Total {Total}

# Game information:
translate B twin {duplicata}
translate B deleted {apagado}
translate B comment {comentario}
translate B hidden {oculto}
translate B LastMove {Ultimo movimento}
translate B NextMove {Proximo}
translate B GameStart {Inicio do jogo}
translate B LineStart {Inicio da linha}
translate B GameEnd {Fim do jogo}
translate B LineEnd {Fim da linha}

# Player information:
translate B PInfoAll {Resultados para <b>todos</b> os jogos}
translate B PInfoFilter {Resultados para os jogos <b>filtrados</b>}
translate B PInfoAgainst {Resultados contra}
translate B PInfoMostWhite {Aberturas mais comuns com as Brancas}
translate B PInfoMostBlack {Aberturas mais comuns com as Pretas}
translate B PInfoRating {Historico de Rating}
translate B PInfoBio {Biografia}

# Tablebase information:
translate B Draw {Empate}
translate B stalemate {mate afogado}
translate B withAllMoves {com todos os movimentos}
translate B withAllButOneMove {com um movimento a menos}
translate B with {com}
translate B only {apenas}
translate B lose {derrota}
translate B loses {derrotas}
translate B allOthersLose {qualquer outro perde}
translate B matesIn {mate em}
translate B hasCheckmated {recebeu xeque-mate}
translate B longest {mais longo}

# Tip of the day:
translate B Tip {Dica}
translate B TipAtStartup {Dica ao iniciar}

# Tree window menus: ***
menuText B TreeFile "Arquivo" 0
menuText B TreeFileSave "Salvar arquivo de cache" 0 \
  {Salvar o arquivo de cache da arvore (.stc)}
menuText B TreeFileFill "Criar arquivo de cache" 0 \
  {Enche o arquivo de cache com as posicoes comuns na abertura}
menuText B TreeFileBest "Best games list" 0 \
  {Mostra a lista dos melhores jogos da arvore}
menuText B TreeFileGraph "Janela de Grafico" 0 \
  {Mostra o grafico para este galho da arvore}
menuText B TreeFileCopy "Copiar texto da arvore para a area de transferencia" \
  1 {Copiar texto da arvore para a area de transferencia}
menuText B TreeFileClose "Fechar janela de arvore" 0 {Fechar janela de arvore}
menuText B TreeSort "Ordenar" 0
menuText B TreeSortAlpha "Alfabetica" 0
menuText B TreeSortECO "ECO" 0
menuText B TreeSortFreq "Frequencia" 0
menuText B TreeSortScore "Pontuacao" 0
menuText B TreeOpt "Opcoes" 0
menuText B TreeOptLock "Lock" 0 {Trava/Destrava a arvore para o banco corrente}
menuText B TreeOptTraining "Treinamento" 0 \
  {Liga/Desliga o modo treinamento na arvore}
menuText B TreeOptAutosave "Salvar automaticamente arquivo de cache" 0 \
  {Salvar automaticamente o arquivo de cache quando fechar a janela de arvore}
menuText B TreeHelp "Ajuda" 0
menuText B TreeHelpTree "Ajuda para arvore" 0
menuText B TreeHelpIndex "Indice da Ajuda" 0
translate B SaveCache {Salvar Cache}
translate B Training {Treinamento}
translate B LockTree {Travamento}
translate B TreeLocked {Travada} ;# ***
translate B TreeBest {Melhor}
translate B TreeBestGames {Melhores jogos da arvore}

# Finder window:
menuText B FinderFile "Arquivo" 0
menuText B FinderFileSubdirs "Buscar nos subdiretorios" 0
menuText B FinderFileClose "Fecha buscador de arquivos" 0
menuText B FinderSort "Ordenar" 0
menuText B FinderSortType "Tipo" 0
menuText B FinderSortSize "Tamanho" 0
menuText B FinderSortMod "Modificado" 0
menuText B FinderSortName "Nome" 0
menuText B FinderSortPath "Caminho" 0
menuText B FinderTypes "Tipos" 0
menuText B FinderTypesScid "Bases Scid" 0
menuText B FinderTypesOld "Bases Scid antigas" 0
menuText B FinderTypesPGN "Arquivos PGN" 0
menuText B FinderTypesEPD "Arquivos EPD (book)" 0
menuText B FinderTypesRep "Arquivos de Repertorio" 0
menuText B FinderHelp "Ajuda" 0
menuText B FinderHelpFinder "Ajuda do Buscador" 0
menuText B FinderHelpIndex "Indice da Ajuda" 0
translate B FileFinder {Buscador de Arquivos}
translate B FinderDir {Diretorio}
translate B FinderDirs {Diretorios}
translate B FinderFiles {Arquivos}
translate B FinderUpDir {Acima}

# Tournament finder:
menuText B TmtFile "Arquivo" 0
menuText B TmtFileUpdate "Atualizar" 0
menuText B TmtFileClose "Fecha Buscador de Torneios" 0
menuText B TmtSort "Ordenar" 0
menuText B TmtSortDate "Data" 0
menuText B TmtSortPlayers "Jogadores" 0
menuText B TmtSortGames "Jogos" 0
menuText B TmtSortElo "Elo" 0
menuText B TmtSortSite "Lugar" 0
menuText B TmtSortEvent "Evento" 1
menuText B TmtSortWinner "Vencedor" 0
translate B TmtLimit "Limite de Lista"
translate B TmtMeanElo "Menor Elo"
translate B TmtNone "Nenhum torneio encontrado."

# Graph windows:
menuText B GraphFile "Arquivo" 0
menuText B GraphFileColor "Salvar como Postscript Colorido..." 12
menuText B GraphFileGrey "Salvar como Postscript Cinza..." 23
menuText B GraphFileClose "Fecha janela" 6
menuText B GraphOptions "Opcoes" 0
menuText B GraphOptionsWhite "Branco" 0
menuText B GraphOptionsBlack "Preto" 0
menuText B GraphOptionsBoth "Ambos" 0
menuText B GraphOptionsPInfo "Informacao do Jogador" 0
translate B GraphFilterTitle "Filter graph: frequency per 1000 games" ;# ***

# Analysis window:
translate B AddVariation {Adicionar variante}
translate B AddMove {Adicionar movimento}
translate B Annotate {Anotar}
translate B AnalysisCommand {Comando de Analise}
translate B PreviousChoices {Escolhas Anteriores}
translate B AnnotateTime {Define o tempo entre movimentos em segundos}
translate B AnnotateWhich {Adiciona variante}
translate B AnnotateAll {Para movimentos de ambos os lados}
translate B AnnotateWhite {Apenas para movimentos das Brancas}
translate B AnnotateBlack {Apenas para movimentos das Pretas}
translate B AnnotateNotBest {Quando o movimento do jogo nao for o melhor movimento}

# Analysis Engine open dialog:
translate B EngineList {Lista de Programas de Analise}
translate B EngineName {Nome}
translate B EngineCmd {Comando}
translate B EngineArgs {Parametros}
translate B EngineDir {Diretorio}
translate B EngineElo {Elo}
translate B EngineTime {Data}
translate B EngineNew {Novo}
translate B EngineEdit {Editar}
translate B EngineRequired {Fields in bold are required; others are optional}

# Stats window menus:
menuText B StatsFile "Arquivo" 0
menuText B StatsFilePrint "Imprimir para arquivo..." 0
menuText B StatsFileClose "Fecha janela" 0
menuText B StatsOpt "Opcoes" 0

# PGN window menus:
menuText B PgnFile "Arquivo" 0
menuText B PgnFilePrint "Imprimir para arquivo..." 0
menuText B PgnFileClose "Fechar janela PGN" 0
menuText B PgnOpt "Monitor" 0
menuText B PgnOptColor "Monitor Colorido" 0
menuText B PgnOptShort "Cabecalho curto (3 linhas)" 0
menuText B PgnOptSymbols "Anotacoes simbolicas" 0
menuText B PgnOptIndentC "Identar comentarios" 0
menuText B PgnOptIndentV "Identar variantes" 7
menuText B PgnOptColumn "Estilo Coluna (um movimento por linha)" 0
menuText B PgnOptSpace "Espaco apos o numero do movimento" 0
menuText B PgnOptStripMarks "Strip out colored square/arrow codes" 1 ;# ***
menuText B PgnColor "Cores" 0
menuText B PgnColorHeader "Cabecalho..." 0
menuText B PgnColorAnno "Anotacoes..." 0
menuText B PgnColorComments "Comentarios..." 0
menuText B PgnColorVars "Variantes..." 0
menuText B PgnColorBackground "Cor de fundo..." 0
menuText B PgnHelp "Ajuda" 0
menuText B PgnHelpPgn "Ajuda PGN" 0
menuText B PgnHelpIndex "Indice" 0

# Crosstable window menus:
menuText B CrosstabFile "Arquivo" 0
menuText B CrosstabFileText "Imprime para arquivo texto..." 9
menuText B CrosstabFileHtml "Imprime para arquivo HTML..." 9
menuText B CrosstabFileLaTeX "Imprime para arquivo LaTex..." 9
menuText B CrosstabFileClose "Fechar tabela de cruzamentos" 0
menuText B CrosstabEdit "Editar" 0
menuText B CrosstabEditEvent "Evento" 0
menuText B CrosstabEditSite "Lugar" 0
menuText B CrosstabEditDate "Data" 0
menuText B CrosstabOpt "Monitor" 0
menuText B CrosstabOptAll "Todos contra todos" 0
menuText B CrosstabOptSwiss "Swiss" 0
menuText B CrosstabOptKnockout "Knockout" 0
menuText B CrosstabOptAuto "Automatico" 0
menuText B CrosstabOptAges "Idade em anos" 0
menuText B CrosstabOptNats "Nacionalidades" 0
menuText B CrosstabOptRatings "Ratings" 0
menuText B CrosstabOptTitles "Titulos" 0
menuText B CrosstabOptBreaks "Scores de desempate" 0
menuText B CrosstabOptDeleted "Include deleted games" 8 ;# ***
menuText B CrosstabOptColors "Cores (apenas para tabela Swiss)" 0
menuText B CrosstabOptColumnNumbers "Numbered columns (All-play-all table only)" 2 ;# ***
menuText B CrosstabOptGroup "Pontuacao do Grupo" 0
menuText B CrosstabSort "Ordenar" 0
menuText B CrosstabSortName "Nome" 0
menuText B CrosstabSortRating "Rating" 0
menuText B CrosstabSortScore "Pontuacao" 0
menuText B CrosstabColor "Cor" 0
menuText B CrosstabColorPlain "Texto puro" 0
menuText B CrosstabColorHyper "Hipertexto" 0
menuText B CrosstabHelp "Ajuda" 0
menuText B CrosstabHelpCross "Ajuda para tabela de cruzamentos" 0
menuText B CrosstabHelpIndex "Indice da Ajuda" 0
translate B SetFilter {Setar filtro}
translate B AddToFilter {Adicionar ao filtro}
translate B Swiss {Swiss}

# Opening report window menus:
menuText B OprepFile "Arquivo" 0
menuText B OprepFileText "Imprimir para arquivo texto..." 9
menuText B OprepFileHtml "Imprimir para arquivo HTML..." 9
menuText B OprepFileLaTeX "Imprimir para arquivo LaTex..." 9
menuText B OprepFileOptions "Opcoes..." 0
menuText B OprepFileClose "Fechar janela de relatorio" 0
menuText B OprepHelp "Ajuda" 0
menuText B OprepHelpReport "Ajuda para Relatorio de abertura" 0
menuText B OprepHelpIndex "Indice da Ajuda" 0

# Repertoire editor:
menuText B RepFile "Arquivo" 0
menuText B RepFileNew "Novo" 0
menuText B RepFileOpen "Abrir..." 0
menuText B RepFileSave "Salvar..." 0
menuText B RepFileSaveAs "Salvar como..." 5
menuText B RepFileClose "Fechar janela" 0
menuText B RepEdit "Editar" 0
menuText B RepEditGroup "Adicionar grupo" 4
menuText B RepEditInclude "Adicionar linha incluida" 4
menuText B RepEditExclude "Adicionar linha excluida" 4
menuText B RepView "Visao" 0
menuText B RepViewExpand "Expandir todos os grupos" 0
menuText B RepViewCollapse "Contrair todos os grupos" 0
menuText B RepSearch "Pesquisa" 0
menuText B RepSearchAll "Tudo do repertorio..." 0
menuText B RepSearchDisplayed "Apenas linhas exibidas..." 0
menuText B RepHelp "Ajuda" 0
menuText B RepHelpRep "Ajuda de Repertorio" 0
menuText B RepHelpIndex "Indice da Ajuda" 0
translate B RepSearch "Pesquisa no repertorio"
translate B RepIncludedLines "linhas incluidas"
translate B RepExcludedLines "linhas excluidas"
translate B RepCloseDialog {Este repertorio sofreu alteracoes.

Voce realmente quer continuar e descartar as alteracoes que foram feitas?
}

# Header search:
translate B HeaderSearch {Busca por cabecalho}
translate B GamesWithNoECO {Jogos sem ECO?}
translate B GameLength {Tamanho do jogo}
translate B FindGamesWith {Encontrar jogos com}
translate B StdStart {Inicio padrao}
translate B Promotions {Promocoes}
translate B Comments {Comentarios}
translate B Variations {Variantes}
translate B Annotations {Anotacoes}
translate B DeleteFlag {Delete flag}
translate B WhiteOpFlag {Abertura Brancas}
translate B BlackOpFlag {Abertura Pretas}
translate B MiddlegameFlag {Meio-jogo}
translate B EndgameFlag {Final}
translate B NoveltyFlag {Novidade}
translate B PawnFlag {Estrutura de Peoes}
translate B TacticsFlag {Tatica}
translate B QsideFlag {Jogo na ala da Dama}
translate B KsideFlag {Jogo na ala do Rei}
translate B BrilliancyFlag {Brilhantismo}
translate B BlunderFlag {Erro!!!}
translate B UserFlag {Usuario}
translate B PgnContains {PGN contem texto}

# Game list window:
translate B GlistNumber {Numero}
translate B GlistWhite {Branco}
translate B GlistBlack {Preto}
translate B GlistWElo {B-Elo}
translate B GlistBElo {P-Elo}
translate B GlistEvent {Evento}
translate B GlistSite {Lugar}
translate B GlistRound {Rodada}
translate B GlistDate {Data}
translate B GlistYear {Ano}
translate B GlistEDate {Evento-Data}
translate B GlistResult {Resultado}
translate B GlistLength {Tamanho}
translate B GlistCountry {Pais}
translate B GlistECO {ECO}
translate B GlistOpening {Abertura}
translate B GlistEndMaterial {End-Material}
translate B GlistDeleted {Apagado}
translate B GlistFlags {Sinalizador}
translate B GlistVars {Variantes}
translate B GlistComments {Comentarios}
translate B GlistAnnos {Anotacoes}
translate B GlistStart {Iniciar}
translate B GlistGameNumber {Numero do Jogo}
translate B GlistFindText {Encontrar texto}
translate B GlistMoveField {Mover}
translate B GlistEditField {Configurar}
translate B GlistAddField {Adicionar}
translate B GlistDeleteField {Remover}
translate B GlistWidth {Largura}
translate B GlistAlign {Alinhar}
translate B GlistColor {Cor}
translate B GlistSep {Separador}

# Maintenance window:
translate B DatabaseName {Nome da base de dados:}
translate B TypeIcon {Icone de Tipo:}
translate B NumOfGames {Jogos:}
translate B NumDeletedGames {Jogos deletados:}
translate B NumFilterGames {Jogos no filtro:}
translate B YearRange {Faixa de Anos:}
translate B RatingRange {Faixa de Rating:}
translate B Flag {Sinalizador}
translate B DeleteCurrent {Deletar jogo corrente}
translate B DeleteFilter {Deletar jogos filtrados}
translate B DeleteAll {Deletar todos os jogos}
translate B UndeleteCurrent {Recuperar jogo corrente}
translate B UndeleteFilter {Recuperar jogos filtrados}
translate B UndeleteAll {Recuperar todos os jogos}
translate B DeleteTwins {Deletar duplicatas}
translate B MarkCurrent {Marcar jogo corrente}
translate B MarkFilter {Marcar jogos filtrados}
translate B MarkAll {Marcar todos os jogos}
translate B UnmarkCurrent {Desmarcar jogo corrente}
translate B UnmarkFilter {Desmarcar jogos filtrados}
translate B UnmarkAll {Desmarcar todos os jogos}
translate B Spellchecking {Verificacao Ortografica}
translate B Players {Jogadores}
translate B Events {Eventos}
translate B Sites {Lugares}
translate B Rounds {Rodadas}
translate B DatabaseOps {Operacoes na base de dados}
translate B ReclassifyGames {Jogos classificados por ECO}
translate B CompactDatabase {Compactar base de dados}
translate B SortDatabase {Ordenar base de dados}
translate B AddEloRatings {Adicionar ratings}
translate B AutoloadGame {Carregar autom. o jogo numero}
translate B StripTags {Strip PGN tags} ;# ***
translate B StripTag {Strip tag} ;# ***
translate B Cleaner {Limpador}
translate B CleanerHelp {
O Limpador do Scid executara todas as acoes de manutencao selecionadas da lista abaixo, no banco corrente.

As configuracoes atuais na classificacao por ECO e dialogos de exclusao de duplicatas serao aplicadas se voce escolher estas funcoes.
}
translate B CleanerConfirm {
Uma vez iniciado, o Limpador nao podera ser interrompido!

Esta operacao pode levar muito tempo para ser executada em uma grande base de dados, dependendo das funcoes selecionadas e das configuracoes atuais.

Voce esta certo de que quer iniciar as acoes de manutencao selecionadas?
}

# Comment editor:
translate B AnnotationSymbols  {Simbolos de Anotacao:}
translate B Comment {Comentario:}

# Board search:
translate B BoardSearch {Pesquisa Tabuleiro}
translate B FilterOperation {Operacao no filtro corrente:}
translate B FilterAnd {E (Filtro restrito)}
translate B FilterOr {OU (Adicionar ao filtro)}
translate B FilterIgnore {IGNORAR (Limpar filtro)}
translate B SearchType {Tipo de pesquisa:}
translate B SearchBoardExact {Posicao exata (todas as pecas nas mesmas casas)}
translate B SearchBoardPawns {Peoes (mesmo material, todos os peoes nas mesmas casas)}
translate B SearchBoardFiles {Colunas (mesmo material, todos os peoes na mesma coluna)}
translate B SearchBoardAny {Qualquer (mesmo material, peoes e pecas em qualquer posicao)}
translate B LookInVars {Olhar nas variantes}

# Material search:
translate B MaterialSearch {Pesquisa Material}
translate B Material {Material}
translate B Patterns {Padroes}
translate B Zero {Zero}
translate B Any {Qualquer}
translate B CurrentBoard {Tabuleiro corrente}
translate B CommonEndings {Finais comuns}
translate B CommonPatterns {Padroes comuns}
translate B MaterialDiff {Diferenca de Material}
translate B squares {casas}
translate B SameColor {Mesma cor}
translate B OppColor {Cor oposta}
translate B Either {Qualquer}
translate B MoveNumberRange {Faixa do numero de movimentos}
translate B MatchForAtLeast {Conferem por pelo menos}
translate B HalfMoves {meios movimentos}

# Game saving:
translate B Today {Hoje}
translate B ClassifyGame {Classificar Jogo}

# Setup position:
translate B EmptyBoard {Tabuleiro vazio}
translate B InitialBoard {Tabuleiro Inicial}
translate B SideToMove {Lado que move}
translate B MoveNumber {No. do Movimento}
translate B Castling {Roque}
translate B EnPassentFile {coluna En Passant}
translate B ClearFen {Limpar FEN}
translate B PasteFen {Colar FEN}

# Replace move dialog:
translate B ReplaceMove {Substituir movimento}
translate B AddNewVar {Adicionar nova variante}
translate B ReplaceMoveMessage {Um movimento ja existe nesta posicao.

Voce pode substitui-lo, descartar todos os movimentos que o seguem, ou adicionar seu movimento como uma nova variante.

(Voce pode evitar que esta mensagem apareca no futuro desligando a opcao "Perguntar antes de substituir movimentos" no menu Opcoes:Movimentos.)}

# Make database read-only dialog:
translate B ReadOnlyDialog {Se voce fizer esta base de dados apenas para leitura, nenhuma alteracao sera permitida.
Nenhum jogo podera ser salvo ou substituido, e nenhuma flag de exclusao podera ser alterada.
Qualquer ordenacao ou resultados de classificacao por ECO serao temporarios.

Para poder tornar a base de dados atualizavel novamente, feche-a e abra-a novamente.

Voce realmente quer que esta base de dados seja apenas de leitura?}

# Clear game dialog:
translate B ClearGameDialog {Este jogo foi alterado.

Voce realmente quer continuar e descartar as mudancas feitas?
}

# Exit dialog:
translate B ExitDialog {Voce quer realmente sair do Scid?}
translate B ExitUnsaved {The following databases have unsaved game changes. If you exit now, these changes will be lost.} ;# ***

# Import window:
translate B PasteCurrentGame {Colar jogo corrente}
translate B ImportHelp1 {Introduzir ou colar um jogo em formato PGN no quadro acima.}
translate B ImportHelp2 {Quaisquer erros ao importar o jogo serao mostrados aqui.}

# ECO Browser:
translate B ECOAllSections {todas as secoes ECO}
translate B ECOSection {secao ECO}
translate B ECOSummary {Resumo para}
translate B ECOFrequency {Frequencia de subcodigos para}

# Opening Report:
translate B OprepTitle {Relatorio de Abertura}
translate B OprepReport {Relatorio}
translate B OprepGenerated {Gerado por}
translate B OprepStatsHist {Estatisticas e Historico}
translate B OprepStats {Estatisticas}
translate B OprepStatAll {Todas as partidas do relatorio}
translate B OprepStatBoth {Ambos com rating}
translate B OprepStatSince {Desde}
translate B OprepOldest {Jogos mais antigos}
translate B OprepNewest {Jogos mais recentes}
translate B OprepPopular {Popularidade Atual}
translate B OprepFreqAll {Frequencia em todos os anos:   }
translate B OprepFreq1   {No ultimo ano: }
translate B OprepFreq5   {Nos ultimos 5 anos: }
translate B OprepFreq10  {Nos ultimos 10 anos: }
translate B OprepEvery {uma vez en cada %u jogos}
translate B OprepUp {ate %u%s de todos os anos}
translate B OprepDown {menos que %u%s de todos os anos}
translate B OprepSame {nenhuma mudanca em todos os anos}
translate B OprepMostFrequent {Jogadores mais frequentes}
translate B OprepRatingsPerf {Ratings e Desempenho}
translate B OprepAvgPerf {Ratings e desempenho medios}
translate B OprepWRating {Rating Brancas}
translate B OprepBRating {Rating Pretas}
translate B OprepWPerf {Desempenho Brancas}
translate B OprepBPerf {Desempenho Pretas}
translate B OprepHighRating {Jogos com o maior rating medio}
translate B OprepTrends {Tendencias de Resultados}
translate B OprepResults {Qtd. e frequencia de resultados}
translate B OprepLength {Tamanho do jogo}
translate B OprepFrequency {Frequencia}
translate B OprepWWins {Brancas vencem: }
translate B OprepBWins {Pretas vencem:  }
translate B OprepDraws {Empates:        }
translate B OprepWholeDB {toda a base de dados}
translate B OprepShortest {Vitorias mais rapidas}
translate B OprepMovesThemes {Movimentos e Temas}
translate B OprepMoveOrders {Ordem dos movimentos para atingir a posicao do relatorio}
translate B OprepMoveOrdersOne \
  {Houve apenas uma ordem de movimentos que atinge esta posicao: }
translate B OprepMoveOrdersAll \
  {Houve apenas %u ordens de movimentos que atingem esta posicao:}
translate B OprepMoveOrdersMany \
  {Houve %u ordens de movimentos que atingem esta posicao. As %u primeiras sao:}
translate B OprepMovesFrom {Movimentos da posicao do relatorio}
translate B OprepThemes {Temas Posicionais}
translate B OprepThemeDescription {Frequencia de temas no movimento %u}
translate B OprepThemeSameCastling {Roque do mesmo lado}
translate B OprepThemeOppCastling {Roques opostos}
translate B OprepThemeNoCastling {Ninguem efetuou o roque}
translate B OprepThemeKPawnStorm {Tempestade de Peoes no lado do Rei}
translate B OprepThemeQueenswap {Damas ja trocadas}
translate B OprepThemeIQP {Peao da Dama isolado}
translate B OprepThemeWP567 {Peao Branco na 5/6/7a fila}
translate B OprepThemeBP234 {Peao Preto na 2/3/4a fila}
translate B OprepThemeOpenCDE {Colunas c/d/e abertas}
translate B OprepTheme1BishopPair {Um lado tem o par de Bispos}
translate B OprepEndgames {Finais}
translate B OprepReportGames {Jogos no Relatorio}
translate B OprepAllGames {Todos os jogos}
translate B OprepEndClass {Material ao fim de cada jogo}
translate B OprepTheoryTable {Tabela de Teoria}
translate B OprepTableComment {Gerada a partir dos %u jogos com rating mais alto.}
translate B OprepExtraMoves {Movimentos com nota extra na Tabela de Teoria}
translate B OprepMaxGames {Qtde. Maxima de jogos na tabela de teoria}

# Piece Tracker window:
translate B TrackerSelectSingle {Left mouse button selects this piece.} ;# ***
translate B TrackerSelectPair {Left mouse button selects this piece; right button also selects its sibling.}
translate B TrackerSelectPawn {Left mouse button selects this pawn; right button selects all 8 pawns.}
translate B TrackerStat {Statistic}
translate B TrackerGames {% games with move to square}
translate B TrackerTime {% time on each square}
translate B TrackerMoves {Moves}
translate B TrackerMovesStart {Enter the move number where tracking should begin.}
translate B TrackerMovesStop {Enter the move number where tracking should stop.}

# Game selection dialogs:
translate B SelectAllGames {Todos os jogos na base de dados}
translate B SelectFilterGames {Apenas jogos no filtro}
translate B SelectTournamentGames {Somente jogos no torneio atual}
translate B SelectOlderGames {Somente jogos antigos}

# Delete Twins window:
translate B TwinsNote {Para serem duplicatas, dois jogos devem ter pelo menos os mesmos dois jogadores, alem de criterios que voce pode definir abaixo. Quando um par de duplicatas e encontrado, o jogo menor e deletado.
Dica: e melhor fazer a verificacao ortografica da base de dados antes de remover duplicatas, pois isso melhora o processo de deteccao de duplicatas. }
translate B TwinsCriteria {Criterio: Duplicatas devem ter...}
translate B TwinsWhich {Jogos a examinar}
translate B TwinsColors {Jogadores com a mesma cor?}
translate B TwinsEvent {Mesmo evento?}
translate B TwinsSite {Mesmo lugar?}
translate B TwinsRound {Mesma rodada?}
translate B TwinsYear {Mesmo ano?}
translate B TwinsMonth {Mesmo mes?}
translate B TwinsDay {Mesmo dia?}
translate B TwinsResult {Mesmo resultado?}
translate B TwinsECO {Mesmo codigo ECO?}
translate B TwinsMoves {Mesmos movimentos?}
translate B TwinsPlayers {Comparacao dos nomes dos jogadores:}
translate B TwinsPlayersExact {Comparacao exata}
translate B TwinsPlayersPrefix {Primeiras 4 letras apenas}
translate B TwinsWhen {Quando deletar duplicatas}
translate B TwinsSkipShort {Ignorar todos os jogos com menos de 5 movimentos?}
translate B TwinsUndelete {Recuperar todos os jogos antes?}
translate B TwinsSetFilter {Definir filtro para todas as duplicatas deletadas?}
translate B TwinsComments {Manter sempre os jogos com comentarios?}
translate B TwinsVars {Manter sempre os jogos com variantes?}
translate B TwinsDeleteWhich {Delete which game:} ;# ***
translate B TwinsDeleteShorter {Shorter game} ;# ***
translate B TwinsDeleteOlder {Smaller game number} ;# ***
translate B TwinsDeleteNewer {Larger game number} ;# ***
translate B TwinsDelete {Deletar jogos}

# Name editor window:
translate B NameEditType {Tipo de nome para editar}
translate B NameEditSelect {Jogos para editar}
translate B NameEditReplace {Substituir}
translate B NameEditWith {com}
translate B NameEditMatches {Confere: Pressione Ctrl+1 a Ctrl+9 para selecionar}

# Classify window:
translate B Classify {Classificar}
translate B ClassifyWhich {Que jogos devem ser classificados por ECO}
translate B ClassifyAll {Todos os Jogos (substituir codigos ECO antigos)}
translate B ClassifyYear {Todos os jogos do ultimo ano}
translate B ClassifyMonth {Todos os jogos do ultimo mes}
translate B ClassifyNew {Somente jogos ainda sem codigo ECO}
translate B ClassifyCodes {Codigos ECO a serem usados}
translate B ClassifyBasic {Codigos Basicos apenas ("B12", ...)}
translate B ClassifyExtended {Extensoes Scid ("B12j", ...)}

# Compaction:
translate B NameFile {Arquivo de nomes}
translate B GameFile {Arquivo de jogos}
translate B Names {Nomes}
translate B Unused {Nao usado}
translate B SizeKb {Tamanho (kb)}
translate B CurrentState {Estado Atual}
translate B AfterCompaction {Apos compactacao}
translate B CompactNames {Compactar arquivo de nomes}
translate B CompactGames {Compactar arquivo de nomes}

# Sorting:
translate B SortCriteria {Criterio}
translate B AddCriteria {Adicionar criterio}
translate B CommonSorts {Ordenacoes comuns}
translate B Sort {Ordenar}

# Exporting:
translate B AddToExistingFile {Adicionar jogos a um arquivo existente?}
translate B ExportComments {Exportar comentarios?}
translate B ExportVariations {Exportar variantes?}
translate B IndentComments {Identar Comentarios?}
translate B IndentVariations {Identar Variantes?}
translate B ExportColumnStyle {Estilo Coluna (um movimento por linha)?}
translate B ExportSymbolStyle {Estilo de anotacao simbolica:}
translate B ExportStripMarks {Strip square/arrow mark codes from comments?} ;# ***

# Goto game/move dialogs:
translate B LoadGameNumber {Entre o numero do jogo a ser carregado:}
translate B GotoMoveNumber {Ir p/ o lance no.:}

# Copy games dialog:
translate B CopyGames {Copiar jogos}
translate B CopyConfirm {
 Voce realmente quer copiar
 os [thousands $nGamesToCopy] jogos filtrados
 da base de dados "$fromName"
 para a base de dados "$targetName"?
}
translate B CopyErr {Copia nao permitida}
translate B CopyErrSource {a base de dados origem}
translate B CopyErrTarget {a base de dados destino}
translate B CopyErrNoGames {nao tem jogos que atendam o filtro}
translate B CopyErrReadOnly {e apenas de leitura}
translate B CopyErrNotOpen {nao esta aberta}

# Colors:
translate B LightSquares {Casas Brancas}
translate B DarkSquares {Casas Pretas}
translate B SelectedSquares {Casas selecionadas}
translate B SuggestedSquares {Casas Sugeridas}
translate B WhitePieces {Pecas Brancas}
translate B BlackPieces {Pecas Pretas}
translate B WhiteBorder {Borda Branca}
translate B BlackBorder {Borda Preta}

# Novelty window:
translate B FindNovelty {Buscar Novidade}
translate B Novelty {Novidade}
translate B NoveltyInterrupt {Busca interrompida}
translate B NoveltyNone {Nenhuma novidade encontrada}
translate B NoveltyHelp {
Scid buscara o primeiro movimento do jogo atual que alcanca uma posicao nao encontrada na base selecionada ou no arquivo ECO.
}

# Upgrading databases:
translate B Upgrading {Atualizando}
translate B ConfirmOpenNew {
Esta e uma base em formato antigo (Scid 2) que nao pode ser aberta pelo Scid 3, mas uma versao no novo formato (Scid 3) ja foi criada.

Voce quer abrir a nova versao da base Scid 3?
}
translate B ConfirmUpgrade {
Esta e uma base em formato antigo (Scid 2). Uma versao da base no novo formato deve ser criada antes de poder ser usada no Scid 3.

A atualizacao criara uma nova versao da base; isto nao altera nem remove os registros originais.

Este processo pode levar algum tempo, mas so precisa ser feito uma vez e pode ser cancelado se estiver demorando muito.

Voce quer atualizar esta base agora?
}

}

# end of portbr.tcl
