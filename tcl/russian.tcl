### russian.tcl:
#  Russian language support for Scid.
#  Contributed by Alex Sedykh.
#  Untranslated messages are marked with a "***" comment.
#  Untranslated help page sections are in <NEW>...</NEW> tags.

addLanguage R Russian 1

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
  {Strip moves from the beginning of the game} ;# ***
menuText R EditStripEnd "Moves to the end" 0 \
  {Strip moves to the end of the game} ;# ***
menuText R EditReset "Очистить " 0 \
  {Полностью очистить буферную базу}
menuText R EditCopy "Скопировать эту партию в буферную базу" 1 \
  {Скопировать эту партию в буферную базу}
menuText R EditPaste "Вставить последнюю партию из буферной базы" 0 \
  {Вставить активную партию из буферной базы здесь}
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
menuText R WindowsTB "Окно таблиц эндшпиля" 10\
  {Открыть/закрыть окно таблиц эндшпиля}

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
menuText R ToolsOpReport "Дебютный отчет" 0 \
  {Сгенерировать дебютный отчет для текущей позиции}
menuText R ToolsTracker "Положение фигуры"  4 {Открыть окно положения фигуры}
menuText R ToolsPInfo "Информация об игроке"  1 \
  {Открыть/обновить окно информации об игроке}
menuText R ToolsRating "Диаграмма рейтинга" 1 \
  {Диаграмма истории рейтинга для игроков текущей партии}
menuText R ToolsScore "Диаграмма счета" 2 {Показать окно диаграммы счета}
menuText R ToolsExpCurrent "Экспорт текущей партии" 0 \
  {Записать текущую партию в текстовый файл}
menuText R ToolsExpCurrentPGN "Экспорт партии в файл PGN..." 0 \
  {Записать текущую партию в файл PGN}
menuText R ToolsExpCurrentHTML "Экспорт партии в файл HTML..." 1 \
  {Записать текущую партию в файл HTML}
menuText R ToolsExpCurrentLaTeX "Экспорт партии в файл LaTeX..." 2 \
  {Записать текущую партию в файл LaTeX}
menuText R ToolsExpFilter "Экспорт всех отфильтрованных партий" 11 \
  {Записать все отфильтрованные партии в текстовый файл}
menuText R ToolsExpFilterPGN "Экспорт отфильтрованных партий в файл PGN..." 1 \
  {Записать все отфильтрованные партии в файл PGN}
menuText R ToolsExpFilterHTML "Экспорт отфильтрованных партий в файл HTML..." 2 \
  {Записать все отфильтрованные партии в файл HTML}
menuText R ToolsExpFilterLaTeX "Экспорт отфильтрованных партий в файл LaTeX..." 3 \
  {Записать все отфильтрованные партии в файл LaTeX}
menuText R ToolsImportOne "Импорт одной партии PGN..." 0 \
  {Импорт партии из текстового файла PGN}
menuText R ToolsImportFile "Импорт файла партий PGN..." 9 \
  {Импорт партий из файла PGN}

# Options menu:
menuText R Options "Установки" 0
menuText R OptionsSize "Размер доски" 0 {Изменить размер доски}
menuText R OptionsPieces "Стиль фигур" 0 {Изменить стиль фигур}
menuText R OptionsColors "Цвета..." 0 {Изменить цвета доски}
menuText R OptionsExport "Экспорт" 0 {Изменить установки экспорта}
menuText R OptionsFonts "Шрифты" 0 {Изменить шрифты}
menuText R OptionsFontsRegular "Нормальный" 0 {Изменить нормальные шрифты}
menuText R OptionsFontsMenu "Меню" 0 {Изменить шрифты меню}
menuText R OptionsFontsSmall "Малые" 1 {Изменить малые шрифты}
menuText R OptionsFontsFixed "Фиксированный" 0 {Изменить фиксированные шрифты}
menuText R OptionsGInfo "Информация о партии" 0 {Установки информации о партии}
menuText R OptionsLanguage "Язык" 0 {Меню выбора языка}
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
menuText R OptionsMovesKey "Клавиатурное завершение" 0 \
  {Включить/выключить автозавершение клавиатурных ходов}
menuText R OptionsNumbers "Числовой формат" 0 {Выбрать числовой формат}
menuText R OptionsStartup "Запуск" 0 {Выбрать окна, открывающиеся при запуске}
menuText R OptionsWindows "Окна" 0 {Установки окон}
menuText R OptionsWindowsIconify "Авто-иконизация" 0 \
  {Иконизировать все окна, когда иконизируется основное окно}
menuText R OptionsWindowsRaise "Авто-выдвижение" 1 \
  {Выдвигатьть определенные окна (например, полосу прогресса) всякий раз, когда они скрыты}
menuText R OptionsToolbar "Инструментальная панель" 0 {Конфигурация инструментальной панели основного окна}
menuText R OptionsECO "Загрузить файл ECO..." 2 { Загрузить файл классификации ECO}
menuText R OptionsSpell "Загрузить файл проверки правописания..." 4 \
  {Загрузить Scid файл проверки правописания}
menuText R OptionsTable "Директория таблиц..." 15 \
  {Выбрать файл таблицы; все таблицы в этой директории будут использованы}
menuText R OptionsRecent "Недавно используемые файлы..." 2 \
  {Изменить количество недавно используемых файлов в меню Файл}
menuText R OptionsSave "Сохранить установки" 0 \
  "Сохранить все установки в файл $::optionsFile"
menuText R OptionsAutoSave "Автосохранение установок при выходе" 0 \
  {Автосохранение всех установок при выходе из программы}

# Help menu:
menuText R Help "Помощь" 0
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
translate R Cancel {Отменить}
translate R Clear {Очистить}
translate R Close {Закрыть}
translate R Defaults {По умолчанию}
translate R Delete {Удалить}
translate R Graph {График}
translate R Help {Помощь}
translate R Import {Импорт}
translate R Index {Индекс}
translate R LoadGame {Загрузить партию}
translate R BrowseGame {Просмотреть партию}
translate R MergeGame {Соединить партию}
translate R Preview {Предварительный просмотр}
translate R Revert {Возвратиться}
translate R Save {Сохранить}
translate R Search {Искать}
translate R Stop {Остановить}
translate R Store {Отложить}
translate R Update {Обновить}
translate R ChangeOrient {Изменить ориентацию окна}
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
translate R Months {Январь Февраль Март Апрель Май Июнь
  Июль Август Сентябрь Октябрь Ноябрь Декабрь}
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
translate R PInfoEditRatings {Edit ratings} ;# ***

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
menuText R TreeFileSave "Сохранить кэш файл" 0 {Сохранить кэш файл дерева (.stc)}
menuText R TreeFileFill "Заполнить кэш файл" 0 \
  {Запольнить кэш файл с общими дебютными позициями}
menuText R TreeFileBest "Список лучших партий" 1 {Показать дерево списка лучших партий}
menuText R TreeFileGraph "Окно графика" 0 {Показать график для ветви этого дерева}
menuText R TreeFileCopy "Скопировать текст дерева в буфер" 1 \
  {Скопировать статистику дерева в буфер}
menuText R TreeFileClose "Закрыть окно дерева" 4 {Закрыть окно дерева}
menuText R TreeSort "Сортировка" 0
menuText R TreeSortAlpha "Алфавитная" 0
menuText R TreeSortECO "По коду ECO" 3
menuText R TreeSortFreq "По частоте" 3
menuText R TreeSortScore "По результату" 3
menuText R TreeOpt "Установки" 0
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
translate R TreeElapsedTime {Time} ;# ***
translate R TreeFoundInCache {  (Found in cache)} ;# ***
translate R TreeTotal {TOTAL:     } ;# ***

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

# Analysis window:
translate R AddVariation {Добавить вариант}
translate R AddMove {Добавить ход}
translate R Annotate {Аннотация}
translate R AnalysisCommand {Команда анализа}
translate R PreviousChoices {Предыдущие выборы}
translate R AnnotateTime {Установить время между ходами в секундах}
translate R AnnotateWhich {Добавить варианты}
translate R AnnotateAll {Для ходов обоих сторон}
translate R AnnotateWhite {Только для ходов Белых}
translate R AnnotateBlack {Только для ходов Черных}
translate R AnnotateNotBest {Когда ход в партии не самый лучший ход}
translate R LowPriority {Низкий приоритет CPU}

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
menuText R PgnColor "Цвета" 0
menuText R PgnColorHeader "Заголовок..." 0
menuText R PgnColorAnno "Аннотация..." 0
menuText R PgnColorComments "Комментарии..." 0
menuText R PgnColorVars "Варианты..." 0
menuText R PgnColorBackground "Фон..." 0
menuText R PgnHelp "Помощь" 0
menuText R PgnHelpPgn "Помощь по PGN" 0
menuText R PgnHelpIndex "Индекс" 0
translate R PgnWindowTitle {PGN of game} ;# ***

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

# Comment editor:
translate R AnnotationSymbols  {Символы аннотации:}
translate R Comment {Комментарии:}
translate R InsertMark {Вставить закладку}

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

# Game saving:
translate R Today {Сегодня}
translate R ClassifyGame {Классифицированная партия}

# Setup position:
translate R EmptyBoard {Пустая доска}
translate R InitialBoard {Начальная позиция}
translate R SideToMove {Очередь хода}
translate R MoveNumber {Номер хода}
translate R Castling {Рокировка}
translate R EnPassentFile {Мимоходный файл}
translate R ClearFen {Очистить FEN}
translate R PasteFen {Вставить FEN}

# Replace move dialog:
translate R ReplaceMove {Заменить ход}
translate R AddNewVar {Добавить новый вариант}
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
translate R OprepThemes {Позиционные темы}
translate R OprepThemeDescription {Частота тем на ходе %u}
translate R OprepThemeSameCastling {Односторонняя рокировка}
translate R OprepThemeOppCastling {Противосторонняя рокировка}
translate R OprepThemeNoCastling {Оба короля не рокированы}
translate R OprepThemeKPawnStorm {Штурм королевскими пешками}
translate R OprepThemeQueenswap {Ферзевой размен}
translate R OprepThemeIQP {Изолированные ферзевые пешки}
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
translate R TwinsNote {Чтобы быть двойником, две партии должны как минимум иметь тех же игроков, и критерии, которые вы установите ниже. Когда пара двойников найдена, более короткая партия удаляется.
Подсказка: перед поиском двойников лучше проверить правописание, это облегчит поиск двойников. }
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
 [thousands $nGamesToCopy] отфильтрованных партий
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
translate R NoveltyHelp {
Scid найдет первый ход в текущей партии, который приведет к позиции, отсутствующей в текущей базе данных и дебютной книге.
}

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

}
# end of russian.tcl
