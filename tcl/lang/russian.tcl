### russian.tcl:
#  Russian language support for Scid.
#  Contributed by Alex Sedykh.
#  Untranslated messages are marked with a "***" comment.
#  Untranslated help page sections are in <NEW>...</NEW> tags.

addLanguage R Russian 1 iso8859-5

proc setLanguage_R {} {

# File menu:
menuText R File "Файл" 0
menuText R FileNew "Новый..." 0 {Создать новую базу данных Scid}
menuText R FileOpen "Открыть..." 0 {Открыть базу данных Scid}
menuText R FileClose "Закрыть" 0 {Закрыть активную базу данных Scid}
menuText R FileFinder "Поиск" 0 {Открыть окно поиска файла}
menuText R FileBookmarks "Закладки" 2 {Меню закладок (комбинация: Ctrl+B)}
menuText R FileBookmarksAdd "Добавить закладку" 0 \
  {Отметить партию или позицию в текущей базе данных}
menuText R FileBookmarksFile "Архивировать закладка" 0 \
  {Архивировать закладку для текущей партии или позиции}
menuText R FileBookmarksEdit "Редактировать закладки..." 0 \
  {Редактировать меню закладок}
menuText R FileBookmarksList "Показать папки как простой список" 0 \
  {Показать папки закладок, как обычный список, а не подменю}
menuText R FileBookmarksSub "Показать папки как подменю" 1 \
  {Показать папки закладок как подменю, а не простой список}
menuText R FileMaint "Поддержка" 2 {Инструменты поддержки базы данных Scid}
menuText R FileMaintWin "Окно поддержки" 0 \
  {Открыть/закрыть окно поддержки базы данных Scid}
menuText R FileMaintCompact "Сжать базу данных..." 0 \
  {Сжать файлы базы данных, выкинуть удаленные партии и неиспользуемые имена}
menuText R FileMaintClass "ECO-Классификация партии..." 0 \
  {Перерасчитать коды ECO для всех партий}
menuText R FileMaintSort "Сортировать базу данных..." 2 \
  {Сортировать все партии в базе данных}
menuText R FileMaintDelete "Удалить партии-двойники..." 0 \
  {Найти партии-двойники и пометить их для удаления}
menuText R FileMaintTwin "Окно проверки двойников" 14 \
  {Открыть/обновить окно проверки двойников}
menuText R FileMaintName "Правописание имен" 0 {Редактирование имен и инструменты правописания}
menuText R FileMaintNameEditor "Редактор имен" 0 \
  {Открыть/закрыть окно редактора имен}
menuText R FileMaintNamePlayer "Проверка имен игроков..." 9 \
  {Проверка имен игроков с помощью файла правописания}
menuText R FileMaintNameEvent "Проверка названий турниров..." 18 \
  {Проверка названий турниров с помощью файла правописания}
menuText R FileMaintNameSite "Проверка названий мест..." 18 \
  {Проверка названий мест с помощью файла правописания}
menuText R FileMaintNameRound "Проверка названий раундов..." 20 \
  {Проверка названий раундов с помощью файла правописания}
menuText R FileReadOnly "Только для чтения..." 0 \
  {Трактовать текущую базу данных как только для чтения, предотвращать изменения}
menuText R FileSwitch "Переключить базу данных" 6 \
  {Переключить на другую открытую базу данных}
menuText R FileExit "Выход" 0 {Выход из Scid}
# ====== TODO To be translated ======
menuText R FileMaintFixBase "Fix corrupted base" 0 {Try to fix a corrupted base}

# Edit menu:
menuText R Edit "Редактирование" 0
menuText R EditAdd "Добавить вариант" 0 {Добавить вариант к этому ходу партии}
menuText R EditDelete "Удалить вариант" 0 {Удалить вариант для этого хода}
menuText R EditFirst "Сделать вариант первым" 0 \
  {Продвинуть вариант на первое место в списке}
menuText R EditMain "Заменить основную линию вариантом" 0 \
  {Сделать вариант основной линией партии}
menuText R EditTrial "Попробовать вариант" 0 \
  {Запустить/закончить пробный режим, для проверки идеи на доске}
menuText R EditStrip "Убрать" 1 {Убрать комментарии или варианты из партии}
menuText R EditStripComments "Комментарии" 0 \
  {Убрать все комментарии и аннотации из этой партии}
menuText R EditStripVars "Варианты" 0 {Убрать все варианты из этой партии}
menuText R EditStripBegin "Moves from the beginning" 1 \
  {Strip moves from the beginning of the game}
menuText R EditStripEnd "Moves to the end" 0 \
  {Strip moves to the end of the game}
menuText R EditReset "Очистить " 0 \
  {Полностью очистить буферную базу}
menuText R EditCopy "Скопировать эту партию в буферную базу" 1 \
  {Скопировать эту партию в буферную базу}
menuText R EditPaste "Вставить последнюю партию из буферной базы" 0 \
  {Вставить активную партию из буферной базы здесь}
# ====== TODO To be translated ======
menuText R EditPastePGN "Paste Clipboard text as PGN game..." 18 \
  {Interpret the clipboard text as a game in PGN notation and paste it here}
menuText R EditSetup "Установить позицию..." 2 \
  {Установить стартовую позицию для этой партии}
menuText R EditCopyBoard "Копировать позицию" 4 \
  {Копировать текущую позицию в нотации FEN в выбранный текст (буфер)}
menuText R EditPasteBoard "Вставить стартовую позицию" 3 \
  {Вставить стартовую позицию из текущего выбранного текста (буфера)}

# Game menu:
menuText R Game "Партия" 0
menuText R GameNew "Новая партия" 0 \
  {Установить партию в начальное положение, отбросив все изменения}
menuText R GameFirst "Загрузить первую партию" 0 {Загрузить первую отфильтрованную партию}
menuText R GamePrev "Загрузить предыдущую партию" 1 {Загрузить предыдущую отфильтрованную партию}
menuText R GameReload "Перезагрузить текущую партию" 1 \
  {Перезагрузить эту партию, сбросив все сделанные изменения}
menuText R GameNext "Загрузить следующую партию" 2 {Загрузить следующую отфильтрованную партию}
menuText R GameLast "Загрузить последнюю партию" 3 {Загрузить последнюю отфильтрованную партию}
menuText R GameRandom "Загрузить случайную партию" 4 {Загрузить случайную отфильтрованную партию}
menuText R GameNumber "Загрузить партию номер..." 6 \
  {Загрузить партию, набрав ее номер}
menuText R GameReplace "Сохранить: Заменить партию..." 0 \
  {Сохранить эту партию, заменив старую версию}
menuText R GameAdd "Сохранить: Добавить новую партию..." 2 \
  {Сохранить эту партию, как новую в базу данных}
menuText R GameDeepest "Определить дебют" 0 \
  {Найти самую позднюю позицию партии, имеющуюся в книге ECO}
menuText R GameGotoMove "Перейти к ходу номер..." 5 \
  {Перейти к определенному ходу текущей партии}
menuText R GameNovelty "Найти новинку..." 2 \
  {Найти первый ход в этой партии, который раньше не применялся}

# Search Menu:
menuText R Search "Поиск" 0
menuText R SearchReset "Сбросить фильтр" 0 {Сбросить фильтр, теперь все партии включены}
menuText R SearchNegate "Обратить фильтр" 0 {Обратить фильтр,  включить только исключенные партии}
menuText R SearchCurrent "Текущая позиция..." 0 {Поиск текущей позиции}
menuText R SearchHeader "Заголовок..." 0 {Поиск по заголовку (игрок, турнир, и т.д.)}
menuText R SearchMaterial "Материал/Образ..." 0 {Поиск по материалу или образцам позиции}
menuText R SearchUsing "Используя файл поиска..." 0 {Поиск с использованием файла с установками поиска}

# Windows menu:
menuText R Windows "Окна" 0
menuText R WindowsComment "Редактор комментариев" 0 {Открыть/закрыть редактор комментариев}
menuText R WindowsGList "Список партий" 0 {Открыть/закрыть окно списка партий}
menuText R WindowsPGN "Окно PGN" 0 \
  {Открыть/закрыть окно PGN (нотация партии)}
menuText R WindowsPList "Поиск игрока" 2 {Открыть/закрыть окно поиска игрока}
menuText R WindowsTmt "Поиск турниров" 0 {Открыть/закрыть окно поиска турниров}
menuText R WindowsSwitcher "Переключатель баз данных" 1 \
  {Открыть/закрыть окно переключателя баз данных}
menuText R WindowsMaint "Окно поддержки" 1 \
  {Открыть/закрыть окно поддержки}
menuText R WindowsECO "Просмотр ECO" 4 {Открыть/закрыть окно просмотра ECO}
menuText R WindowsRepertoire "Редактор репертуара" 2 \
  {Открыть/закрыть окно редактора репертуара дебютов}
menuText R WindowsStats "Окно статистики" 2 \
  {Открыть/закрыть окно фильтрованной статистики}
menuText R WindowsTree "Окно дерева" 10 {Открыть/закрыть окно дерева}
menuText R WindowsTB "Окно таблиц эндшпиля" 10 \
  {Открыть/закрыть окно таблиц эндшпиля}
# ====== TODO To be translated ======
menuText R WindowsBook "Book Window" 0 {Open/close the Book window}
# ====== TODO To be translated ======
menuText R WindowsCorrChess "Correspondence Window" 0 {Open/close the Correspondence window}

# Tools menu:
menuText R Tools "Инструменты" 0
menuText R ToolsAnalysis "Анализирующий движок..." 0 \
  {Запустить/остановить шахматный анализирующий движок}
menuText R ToolsAnalysis2 "Анализирующий движок №2..." 22 \
  {Запустить/остановить второй шахматный анализирующий движок}
menuText R ToolsCross "Турнирная таблица" 0 {Показать турнирную таблицу для этой партии}
menuText R ToolsEmail "Менеджер писем" 0 \
  {Открыть/закрыть окно шахматного менеджера писем}
menuText R ToolsFilterGraph "Фильтрованная диаграмма" 0 \
  {Открыть/закрыть окно фильтрованной диаграммы}
# ====== TODO To be translated ======
menuText R ToolsAbsFilterGraph "Abs. Filter Graph" 7 {Open/close the filter graph window for absolute values}
menuText R ToolsOpReport "Дебютный отчет" 0 \
  {Сгенерировать дебютный отчет для текущей позиции}
# ====== TODO To be translated ======
menuText R ToolsOpenBaseAsTree "Open base as tree" 0   {Open a base and use it in Tree window}
# ====== TODO To be translated ======
menuText R ToolsOpenRecentBaseAsTree "Open recent base as tree" 0   {Open a recent base and use it in Tree window}
menuText R ToolsTracker "Положение фигуры"  4 {Открыть окно положения фигуры}
# ====== TODO To be translated ======
menuText R ToolsTraining "Training"  0 {Training tools (tactics, openings,...) }
# ====== TODO To be translated ======
menuText R ToolsTacticalGame "Tactical game"  0 {Play a game with tactics}
# ====== TODO To be translated ======
menuText R ToolsSeriousGame "Serious game"  0 {Play a serious game}
# ====== TODO To be translated ======
menuText R ToolsTrainOpenings "Openings"  0 {Train with a repertoire}
# ====== TODO To be translated ======
menuText R ToolsTrainTactics "Tactics"  0 {Solve tactics}
# ====== TODO To be translated ======
menuText R ToolsTrainCalvar "Calculation of variations"  0 {Calculation of variations training}
# ====== TODO To be translated ======
menuText R ToolsTrainFindBestMove "Find best move"  0 {Find best move}
# ====== TODO To be translated ======
menuText R ToolsTrainFics "Play on internet"  0 {Play on freechess.org}
# ====== TODO To be translated ======
menuText R ToolsBookTuning "Book tuning" 0 {Book tuning}
# ====== TODO To be translated ======
menuText R ToolsConnectHardware "Connect Hardware" 0 {Connect external hardware}
# ====== TODO To be translated ======
menuText R ToolsConnectHardwareConfigure "Configure..." 0 {Configure external hardware and connection}
# ====== TODO To be translated ======
menuText R ToolsConnectHardwareNovagCitrineConnect "Connect Novag Citrine" 0 {Connect Novag Citrine}
# ====== TODO To be translated ======
menuText R ToolsConnectHardwareInputEngineConnect "Connect Input Engine" 0 {Connect Input Engine (e.g. DGT)}
# ====== TODO To be translated ======
menuText R ToolsNovagCitrine "Novag Citrine" 0 {Novag Citrine}
# ====== TODO To be translated ======
menuText R ToolsNovagCitrineConfig "Configuration" 0 {Novag Citrine configuration}
# ====== TODO To be translated ======
menuText R ToolsNovagCitrineConnect "Connect" 0 {Novag Citrine connect}
menuText R ToolsPInfo "Информация об игроке"  1 \
  {Открыть/обновить окно информации об игроке}
menuText R ToolsPlayerReport "Player Report..." 3 \
  {Generate a player report}
menuText R ToolsRating "Диаграмма рейтинга" 1 \
  {Диаграмма истории рейтинга для игроков текущей партии}
menuText R ToolsScore "Диаграмма счета" 2 {Показать окно диаграммы счета}
menuText R ToolsExpCurrent "Экспорт текущей партии" 0 \
  {Записать текущую партию в текстовый файл}
menuText R ToolsExpCurrentPGN "Экспорт партии в файл PGN..." 0 \
  {Записать текущую партию в файл PGN}
menuText R ToolsExpCurrentHTML "Экспорт партии в файл HTML..." 1 \
  {Записать текущую партию в файл HTML}
# ====== TODO To be translated ======
menuText R ToolsExpCurrentHTMLJS "Export Game to HTML and JavaScript File..." 15 {Write current game to a HTML and JavaScript file}  
menuText R ToolsExpCurrentLaTeX "Экспорт партии в файл LaTeX..." 2 \
  {Записать текущую партию в файл LaTeX}
menuText R ToolsExpFilter "Экспорт всех отфильтрованных партий" 11 \
  {Записать все отфильтрованные партии в текстовый файл}
menuText R ToolsExpFilterPGN "Экспорт отфильтрованных партий в файл PGN..." 1 \
  {Записать все отфильтрованные партии в файл PGN}
menuText R ToolsExpFilterHTML "Экспорт отфильтрованных партий в файл HTML..." 2 \
  {Записать все отфильтрованные партии в файл HTML}
# ====== TODO To be translated ======
menuText R ToolsExpFilterHTMLJS "Export Filter to HTML and JavaScript File..." 17 {Write all filtered games to a HTML and JavaScript file}  
menuText R ToolsExpFilterLaTeX "Экспорт отфильтрованных партий в файл LaTeX..." 3 \
  {Записать все отфильтрованные партии в файл LaTeX}
menuText R ToolsImportOne "Импорт одной партии PGN..." 0 \
  {Импорт партии из текстового файла PGN}
menuText R ToolsImportFile "Импорт файла партий PGN..." 9 \
  {Импорт партий из файла PGN}
# ====== TODO To be translated ======
menuText R ToolsStartEngine1 "Start engine 1" 0  {Start engine 1}
# ====== TODO To be translated ======
menuText R ToolsStartEngine2 "Start engine 2" 0  {Start engine 2}
# ====== TODO To be translated ======
menuText R Play "Play" 0
# ====== TODO To be translated ======
menuText R CorrespondenceChess "Correspondence Chess" 0 {Functions for eMail and Xfcc based correspondence chess}
# ====== TODO To be translated ======
menuText R CCConfigure "Configure..." 0 {Configure external tools and general setup}
# ====== TODO To be translated ======
menuText R CCOpenDB "Open Database..." 0 {Open the default Correspondence database}
# ====== TODO To be translated ======
menuText R CCRetrieve "Retrieve Games" 0 {Retrieve games via external (Xfcc-)helper}
# ====== TODO To be translated ======
menuText R CCInbox "Process Inobx" 0 {Process all files in scids Inbox}
# ====== TODO To be translated ======
menuText R CCPrevious "Previous Game" 0 {Go to previous game in Inbox}
# ====== TODO To be translated ======
menuText R CCNext "Next Game" 0 {Go to next game in Inbox}
# ====== TODO To be translated ======
menuText R CCSend "Send Move" 0 {Send your move via eMail or external (Xfcc-)helper}
# ====== TODO To be translated ======
menuText R CCResign "Resign" 0 {Resign (not via eMail)}
# ====== TODO To be translated ======
menuText R CCClaimDraw "Claim Draw" 0 {Send move and claim a draw (not via eMail)}
# ====== TODO To be translated ======
menuText R CCOfferDraw "Offer Draw" 0 {Send move and offer a draw (not via eMail)}
# ====== TODO To be translated ======
menuText R CCAcceptDraw "Accept Draw" 0 {Accept a draw offer (not via eMail)}
# ====== TODO To be translated ======
menuText R CCNewMailGame "New eMail Game..." 0 {Start a new eMail game}
# ====== TODO To be translated ======
menuText R CCMailMove "Mail Move..." 0 {Send the move via eMail to the opponent}

# Options menu:
menuText R Options "Установки" 0
menuText R OptionsBoard "Chessboard" 0 {Chess board appearance options}
menuText R OptionsBoardSize "Размер доски" 0 {Изменить размер доски}
menuText R OptionsBoardPieces "Стиль фигур" 0 {Изменить стиль фигур}
menuText R OptionsBoardColors "Цвета..." 0 {Изменить цвета доски}
# ====== TODO To be translated ======
menuText R OptionsBoardGraphics "Squares..." 0 {Select textures for squares}
# ====== TODO To be translated ======
translate R OptionsBGW {Select texture for squares}
# ====== TODO To be translated ======
translate R OptionsBoardGraphicsText {Select graphic files for white and black squares:}
menuText R OptionsBoardNames "My Player Names..." 0 {Edit my player names}
menuText R OptionsExport "Экспорт" 0 {Изменить установки экспорта}
menuText R OptionsFonts "Шрифты" 0 {Изменить шрифты}
menuText R OptionsFontsRegular "Нормальный" 0 {Изменить нормальные шрифты}
menuText R OptionsFontsMenu "Меню" 0 {Изменить шрифты меню}
menuText R OptionsFontsSmall "Малые" 1 {Изменить малые шрифты}
menuText R OptionsFontsFixed "Фиксированный" 0 {Изменить фиксированные шрифты}
menuText R OptionsGInfo "Информация о партии" 0 {Установки информации о партии}
menuText R OptionsLanguage "Язык" 0 {Меню выбора языка}
# ====== TODO To be translated ======
menuText R OptionsMovesTranslatePieces "Translate pieces" 0 {Translate first letter of pieces}
menuText R OptionsMoves "Ходы" 0 {Установки для ходов}
menuText R OptionsMovesAsk "Спросить перед заменой ходов" 0 \
  {Спросить перед перезаписью любых ходов}
menuText R OptionsMovesAnimate "Время анимации" 1 \
  {Установить количество времени, используемое для анимации ходов}
menuText R OptionsMovesDelay "Временная задержка автоигры..." 0 \
  {Установить время задержки для режима автоигры}
menuText R OptionsMovesCoord "Координаты ходов" 1 \
  {Принять стиль записи ходов с координатами ("g1f3")}
menuText R OptionsMovesSuggest "Показать советуемые ходы" 0 \
  {Включить/выключить советы о ходе}
# ====== TODO To be translated ======
menuText R OptionsShowVarPopup "Show variations window" 0 {Turn on/off the display of a variations window}  
# ====== TODO To be translated ======
menuText R OptionsMovesSpace "Add spaces after move number" 0 {Add spaces after move number}  
menuText R OptionsMovesKey "Клавиатурное завершение" 0 \
  {Включить/выключить автозавершение клавиатурных ходов}
menuText R OptionsNumbers "Числовой формат" 0 {Выбрать числовой формат}
menuText R OptionsStartup "Запуск" 0 {Выбрать окна, открывающиеся при запуске}
menuText R OptionsWindows "Окна" 0 {Установки окон}
menuText R OptionsWindowsIconify "Авто-иконизация" 0 \
  {Иконизировать все окна, когда иконизируется основное окно}
menuText R OptionsWindowsRaise "Авто-выдвижение" 1 \
  {Выдвигатьть определенные окна (например, полосу прогресса) всякий раз, когда они скрыты}
# ====== TODO To be translated ======
menuText R OptionsSounds "Sounds..." 2 {Configure move announcement sounds}
menuText R OptionsToolbar "Инструментальная панель" 0 {Конфигурация инструментальной панели основного окна}
menuText R OptionsECO "Загрузить файл ECO..." 2 { Загрузить файл классификации ECO}
menuText R OptionsSpell "Загрузить файл проверки правописания..." 4 \
  {Загрузить Scid файл проверки правописания}
menuText R OptionsTable "Директория таблиц..." 15 \
  {Выбрать файл таблицы; все таблицы в этой директории будут использованы}
menuText R OptionsRecent "Недавно используемые файлы..." 2 \
  {Изменить количество недавно используемых файлов в меню Файл}
# ====== TODO To be translated ======
menuText R OptionsBooksDir "Books directory..." 0 {Sets the opening books directory}
# ====== TODO To be translated ======
menuText R OptionsTacticsBasesDir "Bases directory..." 0 {Sets the tactics (training) bases directory}
menuText R OptionsSave "Сохранить установки" 0 \
  "Сохранить все установки в файл $::optionsFile"
menuText R OptionsAutoSave "Автосохранение установок при выходе" 0 \
  {Автосохранение всех установок при выходе из программы}

# Help menu:
menuText R Help "Помощь" 0
menuText R HelpContents "Contents" 0 {Show the help contents page}
menuText R HelpIndex "Индекс" 0 {Показать индесную страницу помощи}
menuText R HelpGuide "Быстрый тур" 0 {Показать страницу быстрого тура помощи}
menuText R HelpHints "Советы" 0 {Показать страницу советов}
menuText R HelpContact "Контактная информация" 0 {Показать контактную информацию}
menuText R HelpTip "Подсказка дня" 2 {Показать полезную подсказку}
menuText R HelpStartup "Окно запуска" 1 {Показать окно запуска}
menuText R HelpAbout "О Scid" 0 {Информация о Scid}

# Game info box popup menu:
menuText R GInfoHideNext "Спрятать следующий ход" 0
menuText R GInfoMaterial "Показать материальную оценку" 0
menuText R GInfoFEN "Показать FEN" 1
menuText R GInfoMarks "Показать цветом поля и стрелки" 3
menuText R GInfoWrap "Завернуть длинные строки" 0
menuText R GInfoFullComment "Показать полные комментарии" 7
menuText R GInfoPhotos "Показать фото" 9
menuText R GInfoTBNothing "Табличные базы: ничего" 0
menuText R GInfoTBResult "Табличные базы: только результат" 5
menuText R GInfoTBAll "Табличные базы: результат и лучшие ходы" 7
menuText R GInfoDelete "(Восстановить)Удалить эту партию" 1
menuText R GInfoMark "(Снять отметку)Отметить эту партию" 2
# ====== TODO To be translated ======
menuText R GInfoInformant "Configure informant values" 0

# Main window buttons:
helpMsg R .button.start {Перейти к началу партии  (клавиша: Home)}
helpMsg R .button.end {Перейти к концу партии  (клавиша: End)}
helpMsg R .button.back {Один ход назад  (клавиша: LeftArrow)}
helpMsg R .button.forward {Один ход вперед (клавиша: RightArrow)}
helpMsg R .button.intoVar {Перейти к варианту  (клавиша: v)}
helpMsg R .button.exitVar {Выйти из текущего варианта (клавиша: z)}
helpMsg R .button.flip {Перевернуть доску (клавиша: .)}
helpMsg R .button.coords {Включить/выключить координаты  (клавиша: 0)}
helpMsg R .button.stm {Включить/выключить иконку очередности хода}
helpMsg R .button.autoplay {Автоматическое выполнение ходов  (клавиши: Ctrl+Z)}

# General buttons:
translate R Back {Назад}
translate R Browse {Browse}
translate R Cancel {Отменить}
# ====== TODO To be translated ======
translate R Continue {Continue}
translate R Clear {Очистить}
translate R Close {Закрыть}
translate R Contents {Contents}
translate R Defaults {По умолчанию}
translate R Delete {Удалить}
translate R Graph {График}
translate R Help {Помощь}
translate R Import {Импорт}
translate R Index {Индекс}
translate R LoadGame {Загрузить партию}
translate R BrowseGame {Просмотреть партию}
translate R MergeGame {Соединить партию}
# ====== TODO To be translated ======
translate R MergeGames {Merge Games}
translate R Preview {Предварительный просмотр}
translate R Revert {Возвратиться}
translate R Save {Сохранить}
translate R Search {Искать}
translate R Stop {Остановить}
translate R Store {Отложить}
translate R Update {Обновить}
translate R ChangeOrient {Изменить ориентацию окна}
# ====== TODO To be translated ======
translate R ShowIcons {Show Icons}
translate R None {Нет}
translate R First {Первый}
translate R Current {Текущий}
translate R Last {Последний}

# General messages:
translate R game {партия}
translate R games {партий}
translate R move {ход}
translate R moves {ходов}
translate R all {все}
translate R Yes {Да}
translate R No {Нет}
translate R Both {Оба}
translate R King {Король}
translate R Queen {Ферзь}
translate R Rook {Ладья}
translate R Bishop {Слон}
translate R Knight {Конь}
translate R Pawn {Пешка}
translate R White {Белые}
translate R Black {Черные}
translate R Player {Игрок}
translate R Rating {Рейтинг}
translate R RatingDiff {Разница рейтингов (Белые - Черные)}
translate R AverageRating {Средний рейтинг}
translate R Event {Турнир}
translate R Site {Место}
translate R Country {Страна}
translate R IgnoreColors {Игнорировать цвета}
translate R Date {Дата}
translate R EventDate {Дата турнира}
translate R Decade {Декада}
translate R Year {Год}
translate R Month {Месяц}
translate R Months {Январь Февраль Март Апрель Май Июнь Июль Август Сентябрь Октябрь Ноябрь Декабрь}
translate R Days {Вск Пон Втр Срд Чтв Птн Суб}
translate R YearToToday {Текущий год}
translate R Result {Результат}
translate R Round {Раунд}
translate R Length {Длина}
translate R ECOCode {код ECO}
translate R ECO {ECO}
translate R Deleted {Удалена}
translate R SearchResults {Поиск результатов}
translate R OpeningTheDatabase {Открытие базы данных}
translate R Database {База данных}
translate R Filter {Фильтр}
translate R noGames {нет партий}
translate R allGames {все партии}
translate R empty {пусто}
translate R clipbase {буфербаза}
translate R score {счет}
translate R StartPos {Стартовая позиция}
translate R Total {Всего}
# ====== TODO To be translated ======
translate R readonly {read-only}

# Standard error messages:
translate R ErrNotOpen {Эта база данных не открыта.}
translate R ErrReadOnly {Эта база данных только для чтения; она не может быть изменена.}
translate R ErrSearchInterrupted {Поиск был прерван; результаты не полные.}

# Game information:
translate R twin {двойник}
translate R deleted {удалена}
translate R comment {комментарий}
translate R hidden {скрытый}
translate R LastMove {Последный ход}
translate R NextMove {Следующий}
translate R GameStart {Начало партии}
translate R LineStart {Начало строки}
translate R GameEnd {Конец партии}
translate R LineEnd {Конец строки}

# Player information:
translate R PInfoAll {Результаты <b>всех</b> партий}
translate R PInfoFilter {Результаты <b>отфильтрованных</b> партий}
translate R PInfoAgainst {Результаты против}
translate R PInfoMostWhite {Наиболее частые дебюты за Белых}
translate R PInfoMostBlack {Наиболее частые дебюты за Черных}
translate R PInfoRating {История рейтинга}
translate R PInfoBio {Биография}
translate R PInfoEditRatings {Edit Ratings}

# Tablebase information:
translate R Draw {Ничья}
translate R stalemate {Пат}
translate R withAllMoves {со всеми ходами}
translate R withAllButOneMove {со всеми кроме одного хода}
translate R with {с}
translate R only {только}
translate R lose {проиграно}
translate R loses {проиграли}
translate R allOthersLose {все остальные проиграны}
translate R matesIn {мат за}
translate R hasCheckmated {заматован}
translate R longest {самый длинный}
translate R WinningMoves {Выгрышные ходы}
translate R DrawingMoves {Ничейные ходы}
translate R LosingMoves {Проигрышные ходы}
translate R UnknownMoves {Ходы, приводящие к неизвестному результату}

# Tip of the day:
translate R Tip {Совет}
translate R TipAtStartup {Совет при загрузке}

# Tree window menus:
menuText R TreeFile "Файл" 0
# ====== TODO To be translated ======
menuText R TreeFileFillWithBase "Fill Cache with base" 0 {Fill the cache file with all games in current base}
# ====== TODO To be translated ======
menuText R TreeFileFillWithGame "Fill Cache with game" 0 {Fill the cache file with current game in current base}
# ====== TODO To be translated ======
menuText R TreeFileSetCacheSize "Cache size" 0 {Set the cache size}
# ====== TODO To be translated ======
menuText R TreeFileCacheInfo "Cache info" 0 {Get info on cache usage}
menuText R TreeFileSave "Сохранить кэш файл" 0 {Сохранить кэш файл дерева (.stc)}
menuText R TreeFileFill "Заполнить кэш файл" 0 \
  {Запольнить кэш файл с общими дебютными позициями}
menuText R TreeFileBest "Список лучших партий" 1 {Показать дерево списка лучших партий}
menuText R TreeFileGraph "Окно графика" 0 {Показать график для ветви этого дерева}
menuText R TreeFileCopy "Скопировать текст дерева в буфер" 1 \
  {Скопировать статистику дерева в буфер}
menuText R TreeFileClose "Закрыть окно дерева" 4 {Закрыть окно дерева}
# ====== TODO To be translated ======
menuText R TreeMask "Mask" 0
# ====== TODO To be translated ======
menuText R TreeMaskNew "New" 0 {New mask}
# ====== TODO To be translated ======
menuText R TreeMaskOpen "Open" 0 {Open mask}
# ====== TODO To be translated ======
menuText R TreeMaskSave "Save" 0 {Save mask}
# ====== TODO To be translated ======
menuText R TreeMaskClose "Close" 0 {Close mask}
# ====== TODO To be translated ======
menuText R TreeMaskFillWithGame "Fill with game" 0 {Fill mask with game}
# ====== TODO To be translated ======
menuText R TreeMaskFillWithBase "Fill with base" 0 {Fill mask with all games in base}
# ====== TODO To be translated ======
menuText R TreeMaskInfo "Info" 0 {Show statistics for current mask}
menuText R TreeSort "Сортировка" 0
menuText R TreeSortAlpha "Алфавитная" 0
menuText R TreeSortECO "По коду ECO" 3
menuText R TreeSortFreq "По частоте" 3
menuText R TreeSortScore "По результату" 3
menuText R TreeOpt "Установки" 0
# ====== TODO To be translated ======
menuText R TreeOptSlowmode "slow mode" 0 {Slow mode for updates (high accuracy)}
# ====== TODO To be translated ======
menuText R TreeOptFastmode "Fast mode" 0 {Fast mode for updates (no move transposition)}
# ====== TODO To be translated ======
menuText R TreeOptFastAndSlowmode "Fast and slow mode" 0 {Fast mode then slow mode for updates}
menuText R TreeOptLock "Блокировать" 0 {(Раз)блокировать дерево для текущей базы}
menuText R TreeOptTraining "Тренировка" 0 {Включить/выключить режим тренировки}
menuText R TreeOptAutosave "Автосохранение файла кеша" 0 \
  {Автосохранение файла кеша, когда закрывается окно дерева}
menuText R TreeHelp "Помощь" 0
menuText R TreeHelpTree "Помощь по дереву" 0
menuText R TreeHelpIndex "Индекс помощи" 0
translate R SaveCache {Сохранить кэш}
translate R Training {Тренировка}
translate R LockTree {Блокировка}
translate R TreeLocked {заблокировано}
translate R TreeBest {Лучший}
translate R TreeBestGames {Дерево лучших партий}
# Note: the next message is the tree window title row. After editing it,
# check the tree window to make sure it lines up with the actual columns.
translate R TreeTitleRow \
  {    Ход    ECO       Частота     Счет   СрElo Прзв СрГод  %Ничьих}
translate R TreeTotal {TOTAL}
# ====== TODO To be translated ======
translate R DoYouWantToSaveFirst {Do you want to save first}
# ====== TODO To be translated ======
translate R AddToMask {Add to Mask}
# ====== TODO To be translated ======
translate R RemoveFromMask {Remove from Mask}
# ====== TODO To be translated ======
translate R Nag {Nag code}
# ====== TODO To be translated ======
translate R Marker {Marker}
# ====== TODO To be translated ======
translate R Include {Include}
# ====== TODO To be translated ======
translate R Exclude {Exclude}
# ====== TODO To be translated ======
translate R MainLine {Main line}
# ====== TODO To be translated ======
translate R Bookmark {Bookmark}
# ====== TODO To be translated ======
translate R NewLine {New line}
# ====== TODO To be translated ======
translate R ToBeVerified {To be verified}
# ====== TODO To be translated ======
translate R ToTrain {To train}
# ====== TODO To be translated ======
translate R Dubious {Dubious}
# ====== TODO To be translated ======
translate R ToRemove {To remove}
# ====== TODO To be translated ======
translate R NoMarker {No marker}
# ====== TODO To be translated ======
translate R ColorMarker {Color}
# ====== TODO To be translated ======
translate R WhiteMark {White}
# ====== TODO To be translated ======
translate R GreenMark {Green}
# ====== TODO To be translated ======
translate R YellowMark {Yellow}
# ====== TODO To be translated ======
translate R BlueMark {Blue}
# ====== TODO To be translated ======
translate R RedMark {Red}
# ====== TODO To be translated ======
translate R CommentMove {Comment move}
# ====== TODO To be translated ======
translate R CommentPosition {Comment position}
# ====== TODO To be translated ======
translate R AddMoveToMaskFirst {Add move to mask first}
# ====== TODO To be translated ======
translate R OpenAMaskFileFirst {Open a mask file first}
# ====== TODO To be translated ======
translate R Positions {Positions}
# ====== TODO To be translated ======
translate R Moves {Moves}

# Finder window:
menuText R FinderFile "Файл" 0
menuText R FinderFileSubdirs "Смотреть в поддиректориях" 0
menuText R FinderFileClose "Закрыть поиск файлов" 0
menuText R FinderSort "Сортировка" 0
menuText R FinderSortType "Тип" 0
menuText R FinderSortSize "Размер" 0
menuText R FinderSortMod "Модифицированно" 0
menuText R FinderSortName "Имя" 0
menuText R FinderSortPath "Путь" 0
menuText R FinderTypes "Типы" 0
menuText R FinderTypesScid "База данных Scid" 0
menuText R FinderTypesOld "Старый формат базы данных Scid" 0
menuText R FinderTypesPGN "Файлы PGN" 0
menuText R FinderTypesEPD "Файлы EPD" 1
menuText R FinderTypesRep "Файлы репертуара" 6
menuText R FinderHelp "Помощь" 0
menuText R FinderHelpFinder "Помощь по поиску файлов" 0
menuText R FinderHelpIndex "Индекс помощи" 0
translate R FileFinder {Поиск файлов}
translate R FinderDir {Директория}
translate R FinderDirs {Директории}
translate R FinderFiles {Файлы}
translate R FinderUpDir {вверх}
# ====== TODO To be translated ======
translate R FinderCtxOpen {Open}
# ====== TODO To be translated ======
translate R FinderCtxBackup {Backup}
# ====== TODO To be translated ======
translate R FinderCtxCopy {Copy}
# ====== TODO To be translated ======
translate R FinderCtxMove {Move}
# ====== TODO To be translated ======
translate R FinderCtxDelete {Delete}

# Player finder:
menuText R PListFile "Файл" 0
menuText R PListFileUpdate "Обновить" 0
menuText R PListFileClose "Закрыть поиск игрока" 0
menuText R PListSort "Сортировка" 0
menuText R PListSortName "Имя" 0
menuText R PListSortElo "Elo" 0
menuText R PListSortGames "Партии" 0
menuText R PListSortOldest "Старейшая" 1
menuText R PListSortNewest "Новейшая" 0

# Tournament finder:
menuText R TmtFile "Файл" 0
menuText R TmtFileUpdate "Обновить" 0
menuText R TmtFileClose "Закрыть поиск турнира" 0
menuText R TmtSort "Сортировка" 0
menuText R TmtSortDate "Дата" 0
menuText R TmtSortPlayers "Игроки" 0
menuText R TmtSortGames "Партии" 0
menuText R TmtSortElo "Elo" 0
menuText R TmtSortSite "Место" 0
menuText R TmtSortEvent "Турнир" 0
menuText R TmtSortWinner "Победитель" 2
translate R TmtLimit "Ограниченный список"
translate R TmtMeanElo "Наименьшее значение Elo"
translate R TmtNone "Ни одного турнира не найдено."

# Graph windows:
menuText R GraphFile "Файл" 0
menuText R GraphFileColor "Сохранить как цветной PostScript..." 14
menuText R GraphFileGrey "Сохранить как черно-белый PostScript..." 14
menuText R GraphFileClose "Закрыть окно" 6
menuText R GraphOptions "Установки" 0
menuText R GraphOptionsWhite "Белые" 0
menuText R GraphOptionsBlack "Черные" 0
menuText R GraphOptionsBoth "Оба" 0
menuText R GraphOptionsPInfo "Игрок - информация об игроке" 0
translate R GraphFilterTitle "Фильтр графики: частота на 1000 партий"
# ====== TODO To be translated ======
translate R GraphAbsFilterTitle "Filter Graph: frequency of the games"
# ====== TODO To be translated ======
translate R ConfigureFilter {Configure X-Axes for Year, Rating and Moves}
# ====== TODO To be translated ======
translate R FilterEstimate "Estimate"
# ====== TODO To be translated ======
translate R TitleFilterGraph "Scid: Filter Graph"

# Analysis window:
translate R AddVariation {Добавить вариант}
# ====== TODO To be translated ======
translate R AddAllVariations {Add All Variations}
translate R AddMove {Добавить ход}
translate R Annotate {Аннотация}
# ====== TODO To be translated ======
translate R ShowAnalysisBoard {Show analysis board}
# ====== TODO To be translated ======
translate R ShowInfo {Show engine info}
# ====== TODO To be translated ======
translate R FinishGame {Finish game}
# ====== TODO To be translated ======
translate R StopEngine {Stop engine}
# ====== TODO To be translated ======
translate R StartEngine {Start engine}
# ====== TODO To be translated ======
translate R LockEngine {Lock engine to current position}
translate R AnalysisCommand {Команда анализа}
translate R PreviousChoices {Предыдущие выборы}
translate R AnnotateTime {Установить время между ходами в секундах}
translate R AnnotateWhich {Добавить варианты}
translate R AnnotateAll {Для ходов обоих сторон}
# ====== TODO To be translated ======
translate R AnnotateAllMoves {Annotate all moves}
translate R AnnotateWhite {Только для ходов Белых}
translate R AnnotateBlack {Только для ходов Черных}
translate R AnnotateNotBest {Когда ход в партии не самый лучший ход}
# ====== TODO To be translated ======
translate R AnnotateBlundersOnly {When game move is an obvious blunder}
# ====== TODO To be translated ======
translate R AnnotateBlundersOnlyScoreChange {Analysis reports blunder, with score change from/to: }
# ====== TODO To be translated ======
translate R BlundersThreshold {Threshold}
translate R LowPriority {Низкий приоритет CPU}
# ====== TODO To be translated ======
translate R ClickHereToSeeMoves {Click here to see moves}
# ====== TODO To be translated ======
translate R ConfigureInformant {Configure Informant}
# ====== TODO To be translated ======
translate R Informant!? {Interesting move}
# ====== TODO To be translated ======
translate R Informant? {Poor move}
# ====== TODO To be translated ======
translate R Informant?? {Blunder}
# ====== TODO To be translated ======
translate R Informant?! {Dubious move}
# ====== TODO To be translated ======
translate R Informant+= {White has a slight advantage}
# ====== TODO To be translated ======
translate R Informant+/- {White has a moderate advantage}
# ====== TODO To be translated ======
translate R Informant+- {White has a decisive advantage}
# ====== TODO To be translated ======
translate R Informant++- {The game is considered won}
# ====== TODO To be translated ======
translate R Book {Book}

# Analysis Engine open dialog:
translate R EngineList {Список анализирующих движков}
translate R EngineName {Название}
translate R EngineCmd {Команда}
translate R EngineArgs {Параметры}
translate R EngineDir {Директория}
translate R EngineElo {Elo}
translate R EngineTime {Дата}
translate R EngineNew {Новый}
translate R EngineEdit {Редактор}
translate R EngineRequired {Поля, отмеченные жирным шрифтом, заполнять обязательно, остальные по желанию}

# Stats window menus:
menuText R StatsFile "Файл" 0
menuText R StatsFilePrint "Печатать в файл..." 0
menuText R StatsFileClose "Закрыть окно" 0
menuText R StatsOpt "Установки" 0

# PGN window menus:
menuText R PgnFile "Файл" 0
menuText R PgnFileCopy "Copy Game to Clipboard" 0
menuText R PgnFilePrint "Печатать в файл..." 0
menuText R PgnFileClose "Закрыть окно PGN" 0
menuText R PgnOpt "Отображение" 0
menuText R PgnOptColor "Цветное отображение" 0
menuText R PgnOptShort "Короткий (трехстрочный) заголовок" 0
menuText R PgnOptSymbols "Символическая аннотация" 0
menuText R PgnOptIndentC "Комментарии с отступом" 2
menuText R PgnOptIndentV "Варианты с отступом" 0
menuText R PgnOptColumn "В колонку (один ход на строчку)" 4
menuText R PgnOptSpace "Пробел после номера хода" 0
menuText R PgnOptStripMarks "Удалить коды цветных полей/стрелок" 0
menuText R PgnOptBoldMainLine "Use Bold Text for Main Line Moves" 4
menuText R PgnColor "Цвета" 0
menuText R PgnColorHeader "Заголовок..." 0
menuText R PgnColorAnno "Аннотация..." 0
menuText R PgnColorComments "Комментарии..." 0
menuText R PgnColorVars "Варианты..." 0
menuText R PgnColorBackground "Фон..." 0
# ====== TODO To be translated ======
menuText R PgnColorMain "Main line..." 0
# ====== TODO To be translated ======
menuText R PgnColorCurrent "Current move background..." 1
# ====== TODO To be translated ======
menuText R PgnColorNextMove "Next move background..." 0
menuText R PgnHelp "Помощь" 0
menuText R PgnHelpPgn "Помощь по PGN" 0
menuText R PgnHelpIndex "Индекс" 0
translate R PgnWindowTitle {Game Notation - game %u}

# Crosstable window menus:
menuText R CrosstabFile "Файл" 0
menuText R CrosstabFileText "Печатать в текстовый файл..." 11
menuText R CrosstabFileHtml "Печатать в HTML файл..." 11
menuText R CrosstabFileLaTeX "Печатать в LaTeX файл..." 11
menuText R CrosstabFileClose "Закрыть окно турнирной таблицы" 0
menuText R CrosstabEdit "Редактор" 0
menuText R CrosstabEditEvent "Турнир" 0
menuText R CrosstabEditSite "Место" 0
menuText R CrosstabEditDate "Дата" 0
menuText R CrosstabOpt "Отображение" 0
menuText R CrosstabOptAll "Все против всех" 0
menuText R CrosstabOptSwiss "Швейцарская система" 0
menuText R CrosstabOptKnockout "На вылет" 0
menuText R CrosstabOptAuto "Авто" 0
menuText R CrosstabOptAges "Возвраст в годах" 2
menuText R CrosstabOptNats "Национальность" 2
menuText R CrosstabOptRatings "Рейтинг" 0
menuText R CrosstabOptTitles "Титул" 0
menuText R CrosstabOptBreaks "Счет тай-бреков" 0
menuText R CrosstabOptDeleted "Включить удаленные партии" 1
menuText R CrosstabOptColors "Цвета (только для швейцарской системы)" 0
menuText R CrosstabOptColumnNumbers "Цифровые колонки (Только для всех против всех)" 2
menuText R CrosstabOptGroup "Групповой счет" 0
menuText R CrosstabSort "Сортировка" 0
menuText R CrosstabSortName "Имя" 0
menuText R CrosstabSortRating "Рейтинг" 0
menuText R CrosstabSortScore "Счет" 0
menuText R CrosstabColor "Цвет" 0
menuText R CrosstabColorPlain "Обычный текст" 0
menuText R CrosstabColorHyper "Гипертекст" 0
menuText R CrosstabHelp "Помощь" 0
menuText R CrosstabHelpCross "Помощь по турнирной таблице" 0
menuText R CrosstabHelpIndex "Индекс помощи" 0
translate R SetFilter {Установить фильтр}
translate R AddToFilter {Добавить к фильтру}
translate R Swiss {Швейцарская система}
translate R Category {Категория}

# Opening report window menus:
menuText R OprepFile "Файл" 0
menuText R OprepFileText "Печатать в текстовый файл..." 11
menuText R OprepFileHtml "Печатать в HTML файл..." 11
menuText R OprepFileLaTeX "Печатать в LaTeX файл..." 11
menuText R OprepFileOptions "Установки..." 0
menuText R OprepFileClose "Закрыть окно дебытов" 0
menuText R OprepFavorites "Favorites" 1
menuText R OprepFavoritesAdd "Add Report..." 0
menuText R OprepFavoritesEdit "Edit Report Favorites..." 0
menuText R OprepFavoritesGenerate "Generate Reports..." 0
menuText R OprepHelp "Помощь" 0
menuText R OprepHelpReport "Помощь по дебютным отчетам" 0
menuText R OprepHelpIndex "Индекс помощи" 0

# Repertoire editor:
menuText R RepFile "Файл" 0
menuText R RepFileNew "Новый" 0
menuText R RepFileOpen "Открыть..." 0
menuText R RepFileSave "Сохранить.." 0
menuText R RepFileSaveAs "Сохранить как..." 2
menuText R RepFileClose "Закрыть окно" 0
menuText R RepEdit "Редактор" 0
menuText R RepEditGroup "Добавить группу" 9
menuText R RepEditInclude "Добавить включенные строки" 9
menuText R RepEditExclude "Добавить исключенные строки" 9
menuText R RepView "Вид" 0
menuText R RepViewExpand "Развернуть все группы" 0
menuText R RepViewCollapse "Сжать все группы" 0
menuText R RepSearch "Поиск" 0
menuText R RepSearchAll "Все репертуары..." 0
menuText R RepSearchDisplayed "Показанные строки только..." 0
menuText R RepHelp "Помощь" 4
menuText R RepHelpRep "Помощь по репертуару" 0
menuText R RepHelpIndex "Индекс помощи" 0
translate R RepSearch "Поиск репертуара"
translate R RepIncludedLines "включенные строки"
translate R RepExcludedLines "исключенный строки"
translate R RepCloseDialog {В этом репертуаре не сохранены изменения.

Вы действительно хотите продолжить не сохранив все изменения, которые вы сделали?
}

# Header search:
translate R HeaderSearch {Поиск по заголовку}
# ====== TODO To be translated ======
translate R EndSideToMove {Side to move at end of game}
translate R GamesWithNoECO {Партии без ECO?}
translate R GameLength {Длина партии}
translate R FindGamesWith {Найти партии с флагами}
translate R StdStart {Нестандартное начало}
translate R Promotions {Продвижения}
translate R Comments {Комментарии}
translate R Variations {Вариации}
translate R Annotations {Аннотации}
translate R DeleteFlag {Удалить флаг}
translate R WhiteOpFlag {Дебют белых}
translate R BlackOpFlag {Дебют черных}
translate R MiddlegameFlag {Мительшпиль}
translate R EndgameFlag {Эндшпиль}
translate R NoveltyFlag {Новинка}
translate R PawnFlag {Пешечная структура}
translate R TacticsFlag {Тактика}
translate R QsideFlag {Игра на ферзевом фланге}
translate R KsideFlag {Игра на королевском фланге}
translate R BrilliancyFlag {Великолепно}
translate R BlunderFlag {Ошибка}
translate R UserFlag {Пользователь}
translate R PgnContains {Текст PGN}

# Game list window:
translate R GlistNumber {Номер}
translate R GlistWhite {Белые}
translate R GlistBlack {Черные}
translate R GlistWElo {Б-Elo}
translate R GlistBElo {Ч-Elo}
translate R GlistEvent {Турнир}
translate R GlistSite {Место}
translate R GlistRound {Раунд}
translate R GlistDate {Дата}
translate R GlistYear {Год}
translate R GlistEDate {Дата турнира}
translate R GlistResult {Результат}
translate R GlistLength {Длина}
translate R GlistCountry {Страна}
translate R GlistECO {ECO}
translate R GlistOpening {Дебют}
translate R GlistEndMaterial {Конечный материал}
translate R GlistDeleted {Удаленные}
translate R GlistFlags {Флаги}
translate R GlistVars {Варианты}
translate R GlistComments {Комментарии}
translate R GlistAnnos {Аннотации}
translate R GlistStart {Старт}
translate R GlistGameNumber {Номер партии}
translate R GlistFindText {Найти текст}
translate R GlistMoveField {Переместить}
translate R GlistEditField {Конфигурация}
translate R GlistAddField {Добавить}
translate R GlistDeleteField {Удалить}
translate R GlistWidth {Ширина}
translate R GlistAlign {Выравнивание}
translate R GlistColor {Цвет}
translate R GlistSep {Разделитель}
# ====== TODO To be translated ======
translate R GlistRemoveThisGameFromFilter  {Remove this game from Filter}
# ====== TODO To be translated ======
translate R GlistRemoveGameAndAboveFromFilter  {Remove game (and all above it) from Filter}
# ====== TODO To be translated ======
translate R GlistRemoveGameAndBelowFromFilter  {Remove game (and all below it) from Filter}
# ====== TODO To be translated ======
translate R GlistDeleteGame {(Un)Delete this game} 
# ====== TODO To be translated ======
translate R GlistDeleteAllGames {Delete all games in filter} 
# ====== TODO To be translated ======
translate R GlistUndeleteAllGames {Undelete all games in filter} 

# Maintenance window:
translate R DatabaseName {Название базы данных:}
translate R TypeIcon {Тип иконки:}
translate R NumOfGames {Партии:}
translate R NumDeletedGames {Удаленные партии:}
translate R NumFilterGames {Партии в фильтре:}
translate R YearRange {Диапазон годов:}
translate R RatingRange {Диапазон рейтинга:}
translate R Description {Описание}
translate R Flag {Флаг}
translate R DeleteCurrent {Удалить текущую партию}
translate R DeleteFilter {Удалить отфильтрованные партии}
translate R DeleteAll {Удалить все партии}
translate R UndeleteCurrent {Восстановить текущую партию}
translate R UndeleteFilter {Восстановить отфильтрованные партии}
translate R UndeleteAll {Восстановить все партии}
translate R DeleteTwins {Удалить двойные партии}
translate R MarkCurrent {Отметить текущую партию}
translate R MarkFilter {Отметить отфильтрованные партии}
translate R MarkAll {Отметить все партии}
translate R UnmarkCurrent {Снять отметку с текущей партии}
translate R UnmarkFilter {Снять отметку с отфильтрованных партий}
translate R UnmarkAll {Снять отметку со всех партий}
translate R Spellchecking {Проверка правописания}
translate R Players {Игроки}
translate R Events {Турниры}
translate R Sites {Место}
translate R Rounds {Раунды}
translate R DatabaseOps {Операции с базой данных}
translate R ReclassifyGames {Партии с класифицированным ECO}
translate R CompactDatabase {Сжатая база данных}
translate R SortDatabase {Сортированная база данных}
translate R AddEloRatings {Добавить рейтинги Elo}
translate R AutoloadGame {Автозагрузка номера партии}
translate R StripTags {Удалить теги PGN}
translate R StripTag {Удалить теги}
translate R Cleaner {Чистильщик}
translate R CleanerHelp {
Чистильщик Scid произведен все поддерживаемые действия, которые вы выбрали в списке ниже, над текущей базой данных.

Текущие установки классификации ECO и двойные диалоги удаления будут применены, если вы выберите эти функции.
}
translate R CleanerConfirm {
Если поддержка чистильщика стартовала, она не может быть прервана!

Это может занять много времени на большой базе данных, в зависимости от функций, которые вы выбрали и их текущих установок.

Вы уверены, что хотите начать поддержку функций, которые вы выбрали?
}
# ====== TODO To be translated ======
translate R TwinCheckUndelete {to flip; "u" undeletes both)}
# ====== TODO To be translated ======
translate R TwinCheckprevPair {Previous pair}
# ====== TODO To be translated ======
translate R TwinChecknextPair {Next pair}
# ====== TODO To be translated ======
translate R TwinChecker {Scid: Twin game checker}
# ====== TODO To be translated ======
translate R TwinCheckTournament {Games in tournament:}
# ====== TODO To be translated ======
translate R TwinCheckNoTwin {No twin  }
# ====== TODO To be translated ======
translate R TwinCheckNoTwinfound {No twin was detected for this game.\nTo show twins using this window, you must first use the "Delete twin games..." function. }
# ====== TODO To be translated ======
translate R TwinCheckTag {Share tags...}
# ====== TODO To be translated ======
translate R TwinCheckFound1 {Scid found $result twin games}
# ====== TODO To be translated ======
translate R TwinCheckFound2 { and set their delete flags}
# ====== TODO To be translated ======
translate R TwinCheckNoDelete {There are no games in this database to delete.}
# ====== TODO To be translated ======
translate R TwinCriteria1 { Your settings for finding twin games are potentially likely to\ncause non-twin games with similar moves to be marked as twins.}
# ====== TODO To be translated ======
translate R TwinCriteria2 {It is recommended that if you select "No" for "same moves", you should select "Yes" for the colors, event, site, round, year and month settings.\nDo you want to continue and delete twins anyway? }
# ====== TODO To be translated ======
translate R TwinCriteria3 {It is recommended that you specify "Yes" for at least two of the "same site", "same round" and "same year" settings.\nDo you want to continue and delete twins anyway?}
# ====== TODO To be translated ======
translate R TwinCriteriaConfirm {Scid: Confirm twin settings}
# ====== TODO To be translated ======
translate R TwinChangeTag "Change the following game tags:\n\n"
# ====== TODO To be translated ======
translate R AllocRatingDescription "This command will use the current spellcheck file to add Elo ratings to games in this database. Wherever a player has no currrent rating but his/her rating at the time of the game is listed in the spellcheck file, that rating will be added."
# ====== TODO To be translated ======
translate R RatingOverride "Overwrite existing non-zero ratings?"
# ====== TODO To be translated ======
translate R AddRatings "Add ratings to:"
# ====== TODO To be translated ======
translate R AddedRatings {Scid added $r Elo ratings in $g games.}
# ====== TODO To be translated ======
translate R NewSubmenu "New submenu"

# Comment editor:
translate R AnnotationSymbols  {Символы аннотации:}
translate R Comment {Комментарии:}
translate R InsertMark {Вставить закладку}
translate R InsertMarkHelp {
Insert/remove mark: Select color, type, square.
Insert/remove arrow: Right-click two squares.
}

# Nag buttons in comment editor:
translate R GoodMove {Good move}
translate R PoorMove {Poor move}
translate R ExcellentMove {Excellent move}
# ====== TODO To be translated ======
translate R Blunder {Blunder}
translate R InterestingMove {Interesting move}
translate R DubiousMove {Dubious move}
translate R WhiteDecisiveAdvantage {White has a decisive advantage}
translate R BlackDecisiveAdvantage {White has a decisive advantage}
translate R WhiteClearAdvantage {White has a clear advantage}
translate R BlackClearAdvantage {White has a clear advantage}
translate R WhiteSlightAdvantage {White has a slight advantage}
translate R BlackSlightAdvantage {White has a slight advantage}
translate R Equality {Equality}
translate R Unclear {Unclear}
translate R Diagram {Diagram}

# Board search:
translate R BoardSearch {Поиск позиции}
translate R FilterOperation {Действия над текущем фильтром:}
translate R FilterAnd {AND (Ограничивающий фильтр)}
translate R FilterOr {OR (Добавить к фильтру)}
translate R FilterIgnore {IGNORE (Сбросить фильтр)}
translate R SearchType {Тип поиска:}
translate R SearchBoardExact {Точная позиция (все фигуры на тех же полях)}
translate R SearchBoardPawns {Пешки (тот же материал, все пешки на тех же полях)}
translate R SearchBoardFiles {Ряды (тот же материал, все пешки на тех же рядах)}
translate R SearchBoardAny {Любая (тот же материал, пешки и фигуры в любом месте)}
translate R LookInVars {Посмотреть в вариантах}

# Material search:
translate R MaterialSearch {Поиск материала}
translate R Material {Материал}
translate R Patterns {Образцы}
translate R Zero {Ноль}
translate R Any {Любой}
translate R CurrentBoard {Текущая позиция}
translate R CommonEndings {Общие эндшпили}
translate R CommonPatterns {Общие образцы}
translate R MaterialDiff {материальная разница}
translate R squares {поля}
translate R SameColor {Тот же цвет}
translate R OppColor {Противоположный цвет}
translate R Either {Или}
translate R MoveNumberRange {Диапазон номеров ходов}
translate R MatchForAtLeast {Совпадает по крайней мере}
translate R HalfMoves {полуходов}
# ====== TODO To be translated ======
translate R EndingPawns {Pawn endings}
# ====== TODO To be translated ======
translate R EndingRookVsPawns {Rook vs. Pawn(s)}
# ====== TODO To be translated ======
translate R EndingRookPawnVsRook {Rook and 1 Pawn vs. Rook}
# ====== TODO To be translated ======
translate R EndingRookPawnsVsRook {Rook and Pawn(s) vs. Rook}
# ====== TODO To be translated ======
translate R EndingRooks {Rook vs. Rook endings}
# ====== TODO To be translated ======
translate R EndingRooksPassedA {Rook vs. Rook endings with a passed a-pawn}
# ====== TODO To be translated ======
translate R EndingRooksDouble {Double Rook endings}
# ====== TODO To be translated ======
translate R EndingBishops {Bishop vs. Bishop endings}
# ====== TODO To be translated ======
translate R EndingBishopVsKnight {Bishop vs. Knight endings}
# ====== TODO To be translated ======
translate R EndingKnights {Knight vs. Knight endings}
# ====== TODO To be translated ======
translate R EndingQueens {Queen vs. Queen endings}
# ====== TODO To be translated ======
translate R EndingQueenPawnVsQueen {Queen and 1 Pawn vs. Queen}
# ====== TODO To be translated ======
translate R BishopPairVsKnightPair {Two Bishops vs. Two Knights middlegame}
# ====== TODO To be translated ======
translate R PatternWhiteIQP {White IQP}
# ====== TODO To be translated ======
translate R PatternWhiteIQPBreakE6 {White IQP: d4-d5 break vs. e6}
# ====== TODO To be translated ======
translate R PatternWhiteIQPBreakC6 {White IQP: d4-d5 break vs. c6}
# ====== TODO To be translated ======
translate R PatternBlackIQP {Black IQP}
# ====== TODO To be translated ======
translate R PatternWhiteBlackIQP {White IQP vs. Black IQP}
# ====== TODO To be translated ======
translate R PatternCoupleC3D4 {White c3+d4 Isolated Pawn Couple}
# ====== TODO To be translated ======
translate R PatternHangingC5D5 {Black Hanging Pawns on c5 and d5}
# ====== TODO To be translated ======
translate R PatternMaroczy {Maroczy Center (with Pawns on c4 and e4)}
# ====== TODO To be translated ======
translate R PatternRookSacC3 {Rook Sacrifice on c3}
# ====== TODO To be translated ======
translate R PatternKc1Kg8 {O-O-O vs. O-O (Kc1 vs. Kg8)}
# ====== TODO To be translated ======
translate R PatternKg1Kc8 {O-O vs. O-O-O (Kg1 vs. Kc8)}
# ====== TODO To be translated ======
translate R PatternLightFian {Light-Square Fianchettos (Bishop-g2 vs. Bishop-b7)}
# ====== TODO To be translated ======
translate R PatternDarkFian {Dark-Square Fianchettos (Bishop-b2 vs. Bishop-g7)}
# ====== TODO To be translated ======
translate R PatternFourFian {Four Fianchettos (Bishops on b2,g2,b7,g7)}

# Game saving:
translate R Today {Сегодня}
translate R ClassifyGame {Классифицированная партия}

# Setup position:
translate R EmptyBoard {Пустая доска}
translate R InitialBoard {Начальная позиция}
translate R SideToMove {Очередь хода}
translate R MoveNumber {Номер хода}
translate R Castling {Рокировка}
translate R EnPassantFile {Мимоходный файл}
translate R ClearFen {Очистить FEN}
translate R PasteFen {Вставить FEN}
# ====== TODO To be translated ======
translate R SaveAndContinue {Save and continue}
# ====== TODO To be translated ======
translate R DiscardChangesAndContinue {Discard changes\nand continue}
# ====== TODO To be translated ======
translate R GoBack {Go back}

# Replace move dialog:
translate R ReplaceMove {Заменить ход}
translate R AddNewVar {Добавить новый вариант}
# ====== TODO To be translated ======
translate R NewMainLine {New Main Line}
translate R ReplaceMoveMessage {Здесь уже есть ход.

Вы можете заменить его, уничтожив все ходы после него, или добавить ваш ход, как новый вариант.

(Вы можете избежать появления этого сообщения в будущем, выключив установку "Спросить перед заменной ходов" в меню Установки:Меню ходов.)}

# Make database read-only dialog:
translate R ReadOnlyDialog {Если вы сделаете эту базу данных только для чтения, не будет позволено никаких изменений.
Партии не могут быть изменены или заменены, и удаленные флаги не могут быть изменены.
Результаты любой сортировки и классификации ECO будут временными.

Вы можете легко сделать базу данных модифицируемой с помощью закрытия и перезагрузки.

Вы действительно желаете сделать эту базу данных только для чтения?}

# Clear game dialog:
translate R ClearGameDialog {Эта партия была изменена.

Вы действительно желаете продолжить, отменив все сделанные изменения?
}

# Exit dialog:
translate R ExitDialog {Вы действительно хотите выйти из Scid?}
translate R ExitUnsaved {Следующая база данных имеет не сохраненные измененные партии. Если вы выйдите сейчас, изменения будут утеряны.}

# Import window:
translate R PasteCurrentGame {Вставить текущую партию}
translate R ImportHelp1 {Ввести или вставить партию в формате PGN в область выше.}
translate R ImportHelp2 {Все ошибки импортирования партии будут показаны здесь.}
# ====== TODO To be translated ======
translate R OverwriteExistingMoves {Overwrite existing moves ?}

# ECO Browser:
translate R ECOAllSections {все секции ECO}
translate R ECOSection {секция ECO}
translate R ECOSummary {Всего для}
translate R ECOFrequency {Частота подкодов для}

# Opening Report:
translate R OprepTitle {Дебютный отчет}
translate R OprepReport {Отчет}
translate R OprepGenerated {Сгенерированный}
translate R OprepStatsHist {Статистика и история}
translate R OprepStats {Статистика}
translate R OprepStatAll {Все отчетные партии}
translate R OprepStatBoth {Оба с рейтингом}
translate R OprepStatSince {С}
translate R OprepOldest {Старейшие партии}
translate R OprepNewest {Новейшие партии}
translate R OprepPopular {Текущие популярные}
translate R OprepFreqAll {Частота во все года:   }
translate R OprepFreq1   {В последний год: }
translate R OprepFreq5   {В последнии пять лет: }
translate R OprepFreq10  {В последнии десять лет: }
translate R OprepEvery {один раз каждые %u партий}
translate R OprepUp {выше - %u%s из всех лет}
translate R OprepDown {ниже - %u%s из всех лет}
translate R OprepSame {нет изменений против всех годов}
translate R OprepMostFrequent {Наиболее часто у игроков}
translate R OprepMostFrequentOpponents {Most frequent opponents}
translate R OprepRatingsPerf {Рейтинги и производительность}
translate R OprepAvgPerf {Средние рейтинги и производительность}
translate R OprepWRating {Рейтинг белых}
translate R OprepBRating {Рейтинг черных}
translate R OprepWPerf {Производительность белых}
translate R OprepBPerf {Производительность черных}
translate R OprepHighRating {Партии с наибольшим среднем рейтингом}
translate R OprepTrends {Результирующие тенденции}
translate R OprepResults {Результирующие длины и частоты}
translate R OprepLength {Длина партии}
translate R OprepFrequency {Частота}
translate R OprepWWins {Белые выиграли: }
translate R OprepBWins {Черные выиграли: }
translate R OprepDraws {Ничьи:      }
translate R OprepWholeDB {вся база данных}
translate R OprepShortest {Самые короткие победы}
translate R OprepMovesThemes {Ходы и темы}
translate R OprepMoveOrders {Порядок ходов  для достижения отчетной позиции}
translate R OprepMoveOrdersOne \
  {Найден только один порядок ходов для достижения отчетной позиции:}
translate R OprepMoveOrdersAll \
  {Найдено %u порядков ходов  для достижения отчетной позиции:}
translate R OprepMoveOrdersMany \
  {Найдено %u порядков ходов  для достижения отчетной позиции. Верхнии %u:}
translate R OprepMovesFrom {Ходы из отчетной позиции}
translate R OprepMostFrequentEcoCodes {Most frequent ECO codes}
translate R OprepThemes {Позиционные темы}
translate R OprepThemeDescription {Frequency of themes in the first %u moves of each game}
translate R OprepThemeSameCastling {Односторонняя рокировка}
translate R OprepThemeOppCastling {Противосторонняя рокировка}
translate R OprepThemeNoCastling {Оба короля не рокированы}
translate R OprepThemeKPawnStorm {Штурм королевскими пешками}
translate R OprepThemeQueenswap {Ферзевой размен}
translate R OprepThemeWIQP {White Isolated Queen Pawn}
translate R OprepThemeBIQP {Black Isolated Queen Pawn}
translate R OprepThemeWP567 {Белые пешки на 5/6/7 горизонтали}
translate R OprepThemeBP234 {Черные пешки на 2/3/4 горизонтали}
translate R OprepThemeOpenCDE {Открыты c/d/e вертикали}
translate R OprepTheme1BishopPair {Только одна сторона имеет слоновую пару}
translate R OprepEndgames {Эндшпили}
translate R OprepReportGames {Отчетные партии}
translate R OprepAllGames    {Все партии}
translate R OprepEndClass {Материал в конце каждой партии}
translate R OprepTheoryTable {Теоретическая таблица}
translate R OprepTableComment {Сгенерировано из %u высокорейтинговых партий.}
translate R OprepExtraMoves {Внешние заметки к ходам в теоретической таблице}
translate R OprepMaxGames {Максимум партий в теоретической таблице}
translate R OprepViewHTML {View HTML}
translate R OprepViewLaTeX {View LaTeX}

# Player Report:
translate R PReportTitle {Player Report}
translate R PReportColorWhite {with the White pieces}
translate R PReportColorBlack {with the Black pieces}
translate R PReportMoves {after %s}
translate R PReportOpenings {Openings}
translate R PReportClipbase {Empty clipbase and copy matching games to it}

# Piece Tracker window:
translate R TrackerSelectSingle {Левая кнопка мышки выбирает эту фигуру.}
translate R TrackerSelectPair {Левая кнопка мышки выбирает эту фигуру; правая выбирает все одинаковые фигуры.}
translate R TrackerSelectPawn {Левая кнопка мышки выбирает эту фигуру; правая выбирает все 8 пешек.}
translate R TrackerStat {Статистика}
translate R TrackerGames {% партий с ходами на это поле}
translate R TrackerTime {% времени на каждом поле}
translate R TrackerMoves {Ходы}
translate R TrackerMovesStart {Введите номер хода, с которого трассировка начинается.}
translate R TrackerMovesStop {Введите номер хода, которым трассировка заканчивается.}

# Game selection dialogs:
translate R SelectAllGames {Все партии в базе данных}
translate R SelectFilterGames {Только отфильтрованные партии}
translate R SelectTournamentGames {Только партии текущего турнира}
translate R SelectOlderGames {Только партии старше}

# Delete Twins window:
translate R TwinsNote {Чтобы быть двойником, две партии должны как минимум иметь тех же игроков, и критерии, которые вы установите ниже. Когда пара двойников найдена, более короткая партия удаляется. Подсказка: перед поиском двойников лучше проверить правописание, это облегчит поиск двойников. }
translate R TwinsCriteria {Критерий: Двойники должны иметь...}
translate R TwinsWhich {Проверка какие партии}
translate R TwinsColors {Игрок играет тем же цветом?}
translate R TwinsEvent {Тот же турнир?}
translate R TwinsSite {То же место?}
translate R TwinsRound {Тот же раунд?}
translate R TwinsYear {Тот же год?}
translate R TwinsMonth {Тот же месяц?}
translate R TwinsDay {Тот же день?}
translate R TwinsResult {Тот же результат?}
translate R TwinsECO {Тот же код ECO?}
translate R TwinsMoves {Те же ходы?}
translate R TwinsPlayers {Сравнить имена игроков:}
translate R TwinsPlayersExact {Полное совпадение}
translate R TwinsPlayersPrefix {Только первые 4 буквы}
translate R TwinsWhen {Когда удалены двойные партии}
translate R TwinsSkipShort {Игнорировать все партии, где меньше 5 ходов?}
translate R TwinsUndelete {Восстановить все партии сначала?}
translate R TwinsSetFilter {Установить фильтр для всех удаленых двойников?}
translate R TwinsComments {Всегда держать партии с комментариями?}
translate R TwinsVars {Всегда держать партии с вариантами?}
translate R TwinsDeleteWhich {Удалить какую партию:}
translate R TwinsDeleteShorter {Более короткая партия}
translate R TwinsDeleteOlder {Меньший номер партии}
translate R TwinsDeleteNewer {Больший номер партии}
translate R TwinsDelete {Удалить партии}

# Name editor window:
translate R NameEditType {Тип имени для редактирования}
translate R NameEditSelect {Партии для редактирования}
translate R NameEditReplace {Заменить}
translate R NameEditWith {с}
translate R NameEditMatches {Совпадения: Нажмите Ctrl+1 - Ctrl+9 для выбора}

# Classify window:
translate R Classify {Классифицировать}
translate R ClassifyWhich {Партии с классифицироваными ECO}
translate R ClassifyAll {Все партии (переписать старые ECO)}
translate R ClassifyYear {Все партии, сыгранные за последний год}
translate R ClassifyMonth {Все партии, сыгранные за последний месяц}
translate R ClassifyNew {Только партии без кода ECO}
translate R ClassifyCodes {Коды ECO для использования}
translate R ClassifyBasic {Только основные коды ("B12", ...)}
translate R ClassifyExtended {Scid расширения ("B12j", ...)}

# Compaction:
translate R NameFile {Файл имен}
translate R GameFile {Файл партий}
translate R Names {Имена}
translate R Unused {Не использовано}
translate R SizeKb {Размер (kb)}
translate R CurrentState {Текущее состояние}
translate R AfterCompaction {После сжатия}
translate R CompactNames {Сжатый файл имен}
translate R CompactGames {Сжатый файл партий}
# ====== TODO To be translated ======
translate R NoUnusedNames "There are no unused names, so the name file is already fully compacted."
# ====== TODO To be translated ======
translate R NoUnusedGames "The game file is already fully compacted."
# ====== TODO To be translated ======
translate R NameFileCompacted {The name file for the database "[file tail [sc_base filename]]" was compacted.}
# ====== TODO To be translated ======
translate R GameFileCompacted {The game file for the database "[file tail [sc_base filename]]" was compacted.}

# Sorting:
translate R SortCriteria {Критерий}
translate R AddCriteria {Добавить критерий}
translate R CommonSorts {Общие сортировки}
translate R Sort {Сортировка}

# Exporting:
translate R AddToExistingFile {Добавить партии в существующий файл?}
translate R ExportComments {Экспортировать комментарии?}
translate R ExportVariations {Экспортировать варианты?}
translate R IndentComments {Комментарии с отступом?}
translate R IndentVariations {Варианты с отступом?}
translate R ExportColumnStyle {В колонку (один ход на строку)?}
translate R ExportSymbolStyle {Стиль символической аннатации:}
translate R ExportStripMarks {Удалить маркированные коды полей/стрелок из комментариев?}

# Goto game/move dialogs:
translate R LoadGameNumber {Введите номер партии для загрузки:}
translate R GotoMoveNumber {Перейти к ходу номер:}

# Copy games dialog:
translate R CopyGames {Скопировать партии}
translate R CopyConfirm {
 Вы действительно желаете скопировать
 [::utils::thousands $nGamesToCopy] отфильтрованных партий
 из базы данных "$fromName"
 в базу данных "$targetName"?
}
translate R CopyErr {Не могу скопировать партии}
translate R CopyErrSource {исходная база данных}
translate R CopyErrTarget {целевая база данных}
translate R CopyErrNoGames {has no games in its filter}
translate R CopyErrReadOnly {только для чтения}
translate R CopyErrNotOpen {не открыта}

# Colors:
translate R LightSquares {Светлые поля}
translate R DarkSquares {Темные поля}
translate R SelectedSquares {Выбранные поля}
translate R SuggestedSquares {Поля подсказанных ходов}
translate R WhitePieces {Белые фигуры}
translate R BlackPieces {Черные фигуры}
translate R WhiteBorder {Белые границы}
translate R BlackBorder {Черные границы}

# Novelty window:
translate R FindNovelty {Найти новинку}
translate R Novelty {Новинка}
translate R NoveltyInterrupt {Поиск новинки прерван}
translate R NoveltyNone {В этой партии новинок не найдено}
translate R NoveltyHelp {Scid найдет первый ход в текущей партии, который приведет к позиции, отсутствующей в текущей базе данных и дебютной книге.}
# ====== TODO To be translated ======
translate R SoundsFolder {Sound Files Folder}
# ====== TODO To be translated ======
translate R SoundsFolderHelp {The folder should contain the files King.wav, a.wav, 1.wav, etc}
# ====== TODO To be translated ======
translate R SoundsAnnounceOptions {Move Announcement Options}
# ====== TODO To be translated ======
translate R SoundsAnnounceNew {Announce new moves as they are made}
# ====== TODO To be translated ======
translate R SoundsAnnounceForward {Announce moves when moving forward one move}
# ====== TODO To be translated ======
translate R SoundsAnnounceBack {Announce when retracting or moving back one move}

# Upgrading databases:
translate R Upgrading {Обновленный}
translate R ConfirmOpenNew {
Это старый формат (Scid 2) базы данных, который не может быть открыт в Scid 3, но формат новой версии (Scid 3) уже может быть создан.

Вы желаете открыть версию нового формата базы данных?
}
translate R ConfirmUpgrade {
Это старый формат (Scid 2) базы данных. Новый формат базы данных должен быть создан перед тем как использовать его в Scid 3.

Обновление создаст новый формат базы данных; это не изменит и не удалит оригинальные файлы.

Это может занять время, но это делается только один раз. Вы можете отзаться, если это занимает слишком много времени.

Вы желаете обновить базу данных сейчас?
}

# Recent files options:
translate R RecentFilesMenu {Число недавно загруженных файлов в файловом меню}
translate R RecentFilesExtra {Число недавно загруженных файлов во внешнем подменю}

# My Player Names options:
translate R MyPlayerNamesDescription {
Enter a list of preferred player names below, one name per line. Wildcards (e.g. "?" for any single character, "*" for any sequence of characters) are permitted.

Every time a game with a player in the list is loaded, the main window chessboard will be rotated if necessary to show the game from that players perspective.
}
# ====== TODO To be translated ======
translate R showblunderexists {show blunder exists}
# ====== TODO To be translated ======
translate R showblundervalue {show blunder value}
# ====== TODO To be translated ======
translate R showscore {show score}
# ====== TODO To be translated ======
translate R coachgame {coach game}
# ====== TODO To be translated ======
translate R configurecoachgame {configure coach game}
# ====== TODO To be translated ======
translate R configuregame {Game configuration}
# ====== TODO To be translated ======
translate R Phalanxengine {Phalanx engine}
# ====== TODO To be translated ======
translate R Coachengine {Coach engine}
# ====== TODO To be translated ======
translate R difficulty {difficulty}
# ====== TODO To be translated ======
translate R hard {hard}
# ====== TODO To be translated ======
translate R easy {easy}
# ====== TODO To be translated ======
translate R Playwith {Play with}
# ====== TODO To be translated ======
translate R white {white}
# ====== TODO To be translated ======
translate R black {black}
# ====== TODO To be translated ======
translate R both {both}
# ====== TODO To be translated ======
translate R Play {Play}
# ====== TODO To be translated ======
translate R Noblunder {No blunder}
# ====== TODO To be translated ======
translate R blunder {blunder}
# ====== TODO To be translated ======
translate R Noinfo {-- No info --}
# ====== TODO To be translated ======
translate R PhalanxOrTogaMissing {Phalanx or Toga not found}
# ====== TODO To be translated ======
# ====== TODO To be translated ======
# ====== TODO To be translated ======
translate R moveblunderthreshold {move is a blunder if loss is greater than}
# ====== TODO To be translated ======
translate R limitanalysis {limit engine analysis time}
# ====== TODO To be translated ======
translate R seconds {seconds}
# ====== TODO To be translated ======
translate R Abort {Abort}
# ====== TODO To be translated ======
translate R Resume {Resume}
# ====== TODO To be translated ======
translate R OutOfOpening {Out of opening}
# ====== TODO To be translated ======
translate R NotFollowedLine {You did not follow the line}
# ====== TODO To be translated ======
translate R DoYouWantContinue {Do you want yo continue ?}
# ====== TODO To be translated ======
translate R CoachIsWatching {Coach is watching}
# ====== TODO To be translated ======
translate R Ponder {Permanent thinking}
# ====== TODO To be translated ======
translate R LimitELO {Limit ELO strength}
# ====== TODO To be translated ======
translate R DubiousMovePlayedTakeBack {Dubious move played, do you want to take back ?}
# ====== TODO To be translated ======
translate R WeakMovePlayedTakeBack {Weak move played, do you want to take back ?}
# ====== TODO To be translated ======
translate R BadMovePlayedTakeBack {Bad move played, do you want to take back ?}
# ====== TODO To be translated ======
translate R Iresign {I resign}
# ====== TODO To be translated ======
translate R yourmoveisnotgood {your move is not good}
# ====== TODO To be translated ======
translate R EndOfVar {End of variation}
# ====== TODO To be translated ======
translate R Openingtrainer {Opening trainer}
# ====== TODO To be translated ======
translate R DisplayCM {Display candidate moves}
# ====== TODO To be translated ======
translate R DisplayCMValue {Display candidate moves value}
# ====== TODO To be translated ======
translate R DisplayOpeningStats {Show statistics}
# ====== TODO To be translated ======
translate R ShowReport {Show report}
# ====== TODO To be translated ======
translate R NumberOfGoodMovesPlayed {good moves played}
# ====== TODO To be translated ======
translate R NumberOfDubiousMovesPlayed {dubious moves played}
# ====== TODO To be translated ======
translate R NumberOfMovesPlayedNotInRepertoire {moves played not in repertoire}
# ====== TODO To be translated ======
translate R NumberOfTimesPositionEncountered {times position encountered}
# ====== TODO To be translated ======
translate R PlayerBestMove  {Allow only best moves}
# ====== TODO To be translated ======
translate R OpponentBestMove {Opponent plays best moves}
# ====== TODO To be translated ======
translate R OnlyFlaggedLines {Only flagged lines}
# ====== TODO To be translated ======
translate R resetStats {Reset statistics}
# ====== TODO To be translated ======
translate R Repertoiretrainingconfiguration {Repertoire training configuration}
# ====== TODO To be translated ======
translate R Loadingrepertoire {Loading repertoire}
# ====== TODO To be translated ======
translate R Movesloaded {Moves loaded}
# ====== TODO To be translated ======
translate R Repertoirenotfound {Repertoire not found}
# ====== TODO To be translated ======
translate R Openfirstrepertoirewithtype {Open first a repertoire database with icon/type set to the right side}
# ====== TODO To be translated ======
translate R Movenotinrepertoire {Move not in repertoire}
# ====== TODO To be translated ======
translate R PositionsInRepertoire {Positions in repertoire}
# ====== TODO To be translated ======
translate R PositionsNotPlayed {Positions not played}
# ====== TODO To be translated ======
translate R PositionsPlayed {Positions played}
# ====== TODO To be translated ======
translate R Success {Success}
# ====== TODO To be translated ======
translate R DubiousMoves {Dubious moves}
# ====== TODO To be translated ======
translate R OutOfRepertoire {OutOfRepertoire}
# ====== TODO To be translated ======
# ====== TODO To be translated ======
# ====== TODO To be translated ======
# ====== TODO To be translated ======
translate R ConfigureTactics {Configure tactics}
# ====== TODO To be translated ======
translate R ResetScores {Reset scores}
# ====== TODO To be translated ======
translate R LoadingBase {Loading base}
# ====== TODO To be translated ======
translate R Tactics {Tactics}
# ====== TODO To be translated ======
translate R ShowSolution {Show solution}
# ====== TODO To be translated ======
translate R Next {Next}
# ====== TODO To be translated ======
translate R ResettingScore {Resetting score}
# ====== TODO To be translated ======
translate R LoadingGame {Loading game}
# ====== TODO To be translated ======
translate R MateFound {Mate found}
# ====== TODO To be translated ======
translate R BestSolutionNotFound {Best solution NOT found !}
# ====== TODO To be translated ======
translate R MateNotFound {Mate not found}
# ====== TODO To be translated ======
translate R ShorterMateExists {Shorter mate exists}
# ====== TODO To be translated ======
translate R ScorePlayed {Score played}
# ====== TODO To be translated ======
translate R Expected {expected}
# ====== TODO To be translated ======
translate R ChooseTrainingBase {Choose training base}
# ====== TODO To be translated ======
translate R Thinking {Thinking}
# ====== TODO To be translated ======
translate R AnalyzeDone {Analyze done}
# ====== TODO To be translated ======
translate R WinWonGame {Win won game}
# ====== TODO To be translated ======
translate R Lines {Lines}
# ====== TODO To be translated ======
translate R ConfigureUCIengine {Configure UCI engine}
# ====== TODO To be translated ======
translate R SpecificOpening {Specific opening}
# ====== TODO To be translated ======
translate R StartNewGame {Start new game}
# ====== TODO To be translated ======
translate R FixedLevel {Fixed level}
# ====== TODO To be translated ======
translate R Opening {Opening}
# ====== TODO To be translated ======
translate R RandomLevel {Random level}
# ====== TODO To be translated ======
translate R StartFromCurrentPosition {Start from current position}
# ====== TODO To be translated ======
translate R FixedDepth {Fixed depth}
# ====== TODO To be translated ======
translate R Nodes {Nodes} 
# ====== TODO To be translated ======
translate R Depth {Depth}
# ====== TODO To be translated ======
translate R Time {Time} 
# ====== TODO To be translated ======
translate R SecondsPerMove {Seconds per move}
# ====== TODO To be translated ======
translate R Engine {Engine}
# ====== TODO To be translated ======
translate R TimeMode {Time mode}
# ====== TODO To be translated ======
translate R TimeBonus {Time + bonus}
# ====== TODO To be translated ======
# ====== TODO To be translated ======
translate R TimeMin {min}
# ====== TODO To be translated ======
translate R TimeSec {sec}
# ====== TODO To be translated ======
# ====== TODO To be translated ======
# ====== TODO To be translated ======
translate R AllExercisesDone {All exercises done}
# ====== TODO To be translated ======
translate R MoveOutOfBook {Move out of book}
# ====== TODO To be translated ======
translate R LastBookMove {Last book move}
# ====== TODO To be translated ======
translate R AnnotateSeveralGames {Annotate several games\nfrom current to :}
# ====== TODO To be translated ======
translate R FindOpeningErrors {Find opening errors}
# ====== TODO To be translated ======
translate R MarkTacticalExercises {Mark tactical exercises}
# ====== TODO To be translated ======
translate R UseBook {Use book}
# ====== TODO To be translated ======
translate R MultiPV {Multiple variations}
# ====== TODO To be translated ======
translate R Hash {Hash memory}
# ====== TODO To be translated ======
translate R OwnBook {Use engine book}
# ====== TODO To be translated ======
translate R BookFile {Opening book}
# ====== TODO To be translated ======
translate R AnnotateVariations {Annotate variations}
# ====== TODO To be translated ======
translate R ShortAnnotations {Short annotations}
# ====== TODO To be translated ======
translate R addAnnotatorTag {Add annotator tag}
# ====== TODO To be translated ======
translate R AddScoreToShortAnnotations {Add score to short annotations}
# ====== TODO To be translated ======
translate R Export {Export}
# ====== TODO To be translated ======
translate R BookPartiallyLoaded {Book partially loaded}
# ====== TODO To be translated ======
translate R Calvar {Calculation of variations}
# ====== TODO To be translated ======
translate R ConfigureCalvar {Configuration}
# ====== TODO To be translated ======
# ====== TODO To be translated ======
translate R Reti {Reti}
# ====== TODO To be translated ======
translate R English {English}
# ====== TODO To be translated ======
translate R d4Nf6Miscellaneous {1.d4 Nf6 Miscellaneous}
# ====== TODO To be translated ======
translate R Trompowsky {Trompowsky}
# ====== TODO To be translated ======
translate R Budapest {Budapest}
# ====== TODO To be translated ======
translate R OldIndian {Old Indian}
# ====== TODO To be translated ======
translate R BenkoGambit {Benko Gambit}
# ====== TODO To be translated ======
translate R ModernBenoni {Modern Benoni}
# ====== TODO To be translated ======
translate R DutchDefence {Dutch Defence}
# ====== TODO To be translated ======
translate R Scandinavian {Scandinavian}
# ====== TODO To be translated ======
translate R AlekhineDefence {Alekhine Defence}
# ====== TODO To be translated ======
translate R Pirc {Pirc}
# ====== TODO To be translated ======
translate R CaroKann {Caro-Kann}
# ====== TODO To be translated ======
translate R CaroKannAdvance {Caro-Kann Advance}
# ====== TODO To be translated ======
translate R Sicilian {Sicilian}
# ====== TODO To be translated ======
translate R SicilianAlapin {Sicilian Alapin}
# ====== TODO To be translated ======
translate R SicilianClosed {Sicilian Closed}
# ====== TODO To be translated ======
translate R SicilianRauzer {Sicilian Rauzer}
# ====== TODO To be translated ======
translate R SicilianDragon {Sicilian Dragon}
# ====== TODO To be translated ======
translate R SicilianScheveningen {Sicilian Scheveningen}
# ====== TODO To be translated ======
translate R SicilianNajdorf {Sicilian Najdorf}
# ====== TODO To be translated ======
translate R OpenGame {Open Game}
# ====== TODO To be translated ======
translate R Vienna {Vienna}
# ====== TODO To be translated ======
translate R KingsGambit {King's Gambit}
# ====== TODO To be translated ======
translate R RussianGame {Russian Game}
# ====== TODO To be translated ======
translate R ItalianTwoKnights {Italian/Two Knights}
# ====== TODO To be translated ======
translate R Spanish {Spanish}
# ====== TODO To be translated ======
translate R SpanishExchange {Spanish Exchange}
# ====== TODO To be translated ======
translate R SpanishOpen {Spanish Open}
# ====== TODO To be translated ======
translate R SpanishClosed {Spanish Closed}
# ====== TODO To be translated ======
translate R FrenchDefence {French Defence}
# ====== TODO To be translated ======
translate R FrenchAdvance {French Advance}
# ====== TODO To be translated ======
translate R FrenchTarrasch {French Tarrasch}
# ====== TODO To be translated ======
translate R FrenchWinawer {French Winawer}
# ====== TODO To be translated ======
translate R FrenchExchange {French Exchange}
# ====== TODO To be translated ======
translate R QueensPawn {Queen's Pawn}
# ====== TODO To be translated ======
translate R Slav {Slav}
# ====== TODO To be translated ======
translate R QGA {QGA}
# ====== TODO To be translated ======
translate R QGD {QGD}
# ====== TODO To be translated ======
translate R QGDExchange {QGD Exchange}
# ====== TODO To be translated ======
translate R SemiSlav {Semi-Slav}
# ====== TODO To be translated ======
translate R QGDwithBg5 {QGD with Bg5}
# ====== TODO To be translated ======
translate R QGDOrthodox {QGD Orthodox}
# ====== TODO To be translated ======
translate R Grunfeld {Gr?nfeld}
# ====== TODO To be translated ======
translate R GrunfeldExchange {Gr?nfeld Exchange}
# ====== TODO To be translated ======
translate R GrunfeldRussian {Gr?nfeld Russian}
# ====== TODO To be translated ======
translate R Catalan {Catalan}
# ====== TODO To be translated ======
translate R CatalanOpen {Catalan Open}
# ====== TODO To be translated ======
translate R CatalanClosed {Catalan Closed}
# ====== TODO To be translated ======
translate R QueensIndian {Queen's Indian}
# ====== TODO To be translated ======
translate R NimzoIndian {Nimzo-Indian}
# ====== TODO To be translated ======
translate R NimzoIndianClassical {Nimzo-Indian Classical}
# ====== TODO To be translated ======
translate R NimzoIndianRubinstein {Nimzo-Indian Rubinstein}
# ====== TODO To be translated ======
translate R KingsIndian {King's Indian}
# ====== TODO To be translated ======
translate R KingsIndianSamisch {King's Indian S?misch}
# ====== TODO To be translated ======
translate R KingsIndianMainLine {King's Indian Main Line}
# ====== TODO To be translated ======
translate R CCDlgConfigureWindowTitle {Configure Correspondence Chess}
# ====== TODO To be translated ======
translate R CCDlgCGeneraloptions {General Options}
# ====== TODO To be translated ======
translate R CCDlgDefaultDB {Default Database:}
# ====== TODO To be translated ======
translate R CCDlgInbox {Inbox (path):}
# ====== TODO To be translated ======
translate R CCDlgOutbox {Outbox (path):}
# ====== TODO To be translated ======
translate R CCDlgXfcc {Xfcc Configuration:}
# ====== TODO To be translated ======
translate R CCDlgExternalProtocol {External Protocol Handler (e.g. Xfcc)}
# ====== TODO To be translated ======
translate R CCDlgFetchTool {Fetch Tool:}
# ====== TODO To be translated ======
translate R CCDlgSendTool {Send Tool:}
# ====== TODO To be translated ======
translate R CCDlgEmailCommunication {eMail Communication}
# ====== TODO To be translated ======
translate R CCDlgMailPrg {Mail program:}
# ====== TODO To be translated ======
translate R CCDlgBCCAddr {(B)CC Address:}
# ====== TODO To be translated ======
translate R CCDlgMailerMode {Mode:}
# ====== TODO To be translated ======
translate R CCDlgThunderbirdEg {e.g. Thunderbird, Mozilla Mail, Icedove...}
# ====== TODO To be translated ======
translate R CCDlgMailUrlEg {e.g. Evolution}
# ====== TODO To be translated ======
translate R CCDlgClawsEg {e.g Sylpheed Claws}
# ====== TODO To be translated ======
translate R CCDlgmailxEg {e.g. mailx, mutt, nail...}
# ====== TODO To be translated ======
translate R CCDlgAttachementPar {Attachment parameter:}
# ====== TODO To be translated ======
translate R CCDlgInternalXfcc {Use internal Xfcc support}
# ====== TODO To be translated ======
translate R CCDlgSubjectPar {Subject parameter:}
# ====== TODO To be translated ======
translate R CCDlgStartEmail {Start new eMail game}
# ====== TODO To be translated ======
translate R CCDlgYourName {Your Name:}
# ====== TODO To be translated ======
translate R CCDlgYourMail {Your eMail Address:}
# ====== TODO To be translated ======
translate R CCDlgOpponentName {Opponents Name:}
# ====== TODO To be translated ======
translate R CCDlgOpponentMail {Opponents eMail Address:}
# ====== TODO To be translated ======
translate R CCDlgGameID {Game ID (unique):}
# ====== TODO To be translated ======
translate R CCDlgTitNoOutbox {Scid: Correspondence Chess Outbox}
# ====== TODO To be translated ======
translate R CCDlgTitNoInbox {Scid: Correspondence Chess Inbox}
# ====== TODO To be translated ======
translate R CCDlgTitNoGames {Scid: No Correspondence Chess Games}
# ====== TODO To be translated ======
translate R CCErrInboxDir {Correspondence Chess inbox directory:}
# ====== TODO To be translated ======
translate R CCErrOutboxDir {Correspondence Chess outbox directory:}
# ====== TODO To be translated ======
translate R CCErrDirNotUsable {does not exist or is not accessible!\nPlease check and correct the settings.}
# ====== TODO To be translated ======
translate R CCErrNoGames {does not contain any games!\nPlease fetch them first.}
# ====== TODO To be translated ======
translate R CCDlgTitNoCCDB {Scid: No Correspondence Database}
# ====== TODO To be translated ======
translate R CCErrNoCCDB {No Database of type 'Correspondence' is opened. Please open one before using correspondence chess functions.}
# ====== TODO To be translated ======
translate R CCFetchBtn {Fetch games from the server and process the Inbox}
# ====== TODO To be translated ======
translate R CCPrevBtn {Goto previous game}
# ====== TODO To be translated ======
translate R CCNextBtn {Goto next game}
# ====== TODO To be translated ======
translate R CCSendBtn {Send move}
# ====== TODO To be translated ======
translate R CCEmptyBtn {Empty In- and Outbox}
# ====== TODO To be translated ======
translate R CCHelpBtn {Help on icons and status indicators.\nFor general Help press F1!}
# ====== TODO To be translated ======
translate R ExtHWConfigConnection {Configure external hardware}
# ====== TODO To be translated ======
translate R ExtHWPort {Port}
# ====== TODO To be translated ======
translate R ExtHWEngineCmd {Engine command}
# ====== TODO To be translated ======
translate R ExtHWEngineParam {Engine parameter}
# ====== TODO To be translated ======
translate R ExtHWShowButton {Show button}
# ====== TODO To be translated ======
translate R ExtHWHardware {Hardware}
# ====== TODO To be translated ======
translate R ExtHWNovag {Novag Citrine}
# ====== TODO To be translated ======
translate R ExtHWInputEngine {Input Engine}
# ====== TODO To be translated ======
translate R ExtHWNoBoard {No board}
# ====== TODO To be translated ======
translate R IEConsole {Input Engine Console}
# ====== TODO To be translated ======
translate R IESending {Moves sent for}
# ====== TODO To be translated ======
translate R IESynchronise {Synchronise}
# ====== TODO To be translated ======
translate R IESyncrhonise {Synchronise}
# ====== TODO To be translated ======
translate R IERotate  {Rotate}
# ====== TODO To be translated ======
translate R IEUnableToStart {Unable to start Input Engine:}
# ====== TODO To be translated ======
translate R DoneWithPosition {Done with position}
# ====== TODO To be translated ======
}
# end of russian.tcl















