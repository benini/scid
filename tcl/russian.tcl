# russian.tcl:
# Russian language translations for Scid.

addLanguage R Russian 0 iso8859-5

proc setLanguage_R {} {

# File menu:
menuText R File "файл" 0
menuText R FileNew "Создать..." 0 {Создает новую базу данных Scid}
menuText R FileOpen "Открыть..." 0 {Открывает существующую базу данных Scid}
menuText R FileClose "Закрыть" 0 {Закрывает активную базу данных}
menuText R FileFinder "Поиск файлов" 0 {Окно поиска файлов}
menuText R FileBookmarks "Закладки" 0 {Меню Закладок (клавиши: Ctrl+B)}
menuText R FileBookmarksAdd "Добавить закладку" 0 \
  {Зделать закладку в этой партии в данной позиции}
menuText R FileBookmarksFile "Регистрация закладки" 0 \
  {Зарегистрировать закладку для этой партии в данной позиции}
menuText R FileBookmarksEdit "Редактировать закладки..." 0 \
  {Редактировать меню закладок}
menuText R FileBookmarksList "Показывать каталоги как единый лист" 0 \
  {Показывать каталоги закладок как единый лист без меню}
menuText R FileBookmarksSub "Показывать каталоги как меню" 0 \
  {Показывать каталоги закладок с подменю, а не как единый лист}
menuText R FileMaint "Сервис" 0 {Инструменты для обслуживания баз данных}
menuText R FileMaintWin "Сервисное окно" 0 \
  {Открыть/закрыть сервисное окно БД}
menuText R FileMaintCompact "Сжать БД..." 0 \
  {Сжать файлы БД удалив помеченные для удаления игры и неиспользуемые имена}
menuText R FileMaintClass "Переопределить ECO..." 2 \
  {Переопределить индекс ECO для всех партий}
menuText R FileMaintSort "Сортировать БД..." 0 \
  {Сортировать все игры в БД}
menuText R FileMaintDelete "Удалить партии-копии..." 0 \
  {Найти партии-копии и пометить их для удаления}
menuText R FileMaintTwin "Окно проверки партий-копий" 0 \
  {Открыть/обновить окно проверки партий-копий}
menuText R FileMaintName "Правописание имен" 0 {Инструменты для редактирования названий и имен}
menuText R FileMaintNameEditor "Редактор названий" 0 \
  {Открыть/закрыть окно редактора названий}
menuText R FileMaintNamePlayer "Проверка имен..." 11 \
  {Проверка имен игроков с помощью проверочного файла}
menuText R FileMaintNameEvent "Проверка названий соревнований..." 11 \
  {Проверка названий соревнований с помощью проверочного файла}
menuText R FileMaintNameSite "Проверка мест проведения..." 11 \
  {Проверка мест проведения соревнований с помощью проверочного файла}
menuText R FileMaintNameRound "Проверить название туров..." 11 \
  {Проверка туров соревнований с помощью проверочного файла}
menuText R FileReadOnly "Только для чтения..." 0 \
  {Запретить редактирование текущей БД}
menuText R FileExit "Выход" 1 {Выход из программы}

# Edit menu:
menuText R Edit "Редактировать" 0
menuText R EditAdd "Добавить вариант" 0 {Добавить вариант при данном ходе}
menuText R EditDelete "Удалить вариант" 0 {Удалить вариант к данному хода}
menuText R EditFirst "Сделать вариант первым" 5 \
  {Сделать вариант первым по списку}
menuText R EditMain "Сделать основным вариантом" 21 \
  {Сделать основным вариантом}
menuText R EditTrial "Пробный вариант" 0 \
  {Попробовать вариант на доске}
menuText R EditStrip "Удалить" 2 {Удалить комментарий или варианты из данной партии}
menuText R EditStripComments "Комментарий" 0 \
  {Удаляет все примечания и комментарии из данной игры}
menuText R EditStripVars "Варианты" 0 {Удалить все варианты из партии}
menuText R EditReset "Очистить временную БД" 0 \
  {Удалить все игры из временной БД}
menuText R EditCopy "Скопировать партию во временную БД" 0 \
  {Скопировать партию во временную БД}
menuText R EditPaste "Вставить последнюю партию из временной БД" 0 \
  {Вставить сюда последнюю партию из временной БД}
menuText R EditSetup "Задать начальную позицию..." 0 \
  {Задать начальную позицию для партии}
menuText R EditPasteBoard "Вставить начальную позицию" 12 \
  {Задать начальную позицию по выбранному месту во временной БД}

# Game menu:
menuText R Game "Партия" 0
menuText R GameNew "Новая партия" 0 \
  {Поставить новую партию, отменив все сделанные изменения}
menuText R GameFirst "Загрузить первую партию" 5 {Загрузить первую партию из фильтра}
menuText R GamePrev "Загрузить предыдущую партию" 5 {Загрузить предыдущую партию из фильтра}
menuText R GameReload "Загрузить текующую партию повторно" 3 \
  {Загрузить партию повторно, отменив все сделанные изменения}
menuText R GameNext "Загрузить следующую партию" 7 {Загрузить следующую партию из фильтра}
menuText R GameLast "Загрузить последнюю партию" 8 {Загрузить последнюю партию из фильтра}
menuText R GameRandom "Загрузить произвольную партию" 8 {Загрузить произвольную партию из фильтра}
menuText R GameNumber "Загрузить партию #..." 5 \
  {Загрузить партию по введенному номеру}
menuText R GameReplace "Сохранить: с заменой..." 6 \
  {Сохранить партию, заменив прежнюю}
menuText R GameAdd "Сохранить: добавить новую..." 6 \
  {Сохранить партию, введя ее как новую в БД}
menuText R GameDeepest "Перейти по ECO" 0 \
  {Перейти к самой продвинутой позиции, которая есть в библиотеке ECO}
menuText R GameGotoMove "Перейти к ходу #..." 5 \
  {Перейти к определенному ходу в партии}
menuText R GameNovelty "Найти ход-новинку..." 7 \
  {Найти первый ход, который является новым и не игрался до сих пор}

# Search Menu:
menuText R Search "Поиск" 0
menuText R SearchReset "Восстановить фильтр" 0 {Восстановить начальное состояние фильтра, когда в него входят все партии}
menuText R SearchNegate "Инвертировать фильтр" 0 {Включить в фильтр только те партии, которые были из него исключены}
menuText R SearchCurrent "Позиция на доске..." 0 {Поиск по позиции на доске}
menuText R SearchHeader "По заголовкам..." 0 {Поиск по информации в заголовках (игрок, турнир и т. д.)}
menuText R SearchMaterial "Материал/особенности позиции..." 0 {Поиск по материалу или особенностям позиции}
menuText R SearchUsing "С помощью установочного файла..." 0 {Поиск с помощью установочного файла}

# Windows menu:
menuText R Windows "Окна" 0
menuText R WindowsComment "Редактор примечаний" 0 {Открыть/закрыть окно редактирования примечаний}
menuText R WindowsGList "Список партий" 0 {Открыть/закрыть окно со списком партий}
menuText R WindowsPGN "Окно с PGN" 0 \
  {Открыть/закрыть окно с записью ходов в формате PGN}
menuText R WindowsTmt "Поиск турниров" 2 {Открыть/закрыть Open/close the tournament finder}
menuText R WindowsSwitcher "Переключатель БД" 0 \
  {Открыть/закрыть окно со списком баз данных}
menuText R WindowsMaint "Сервисное окно" 0 \
  {Открыть/закрыть сервисное окно}
menuText R WindowsECO "Окно просмотра ECO" 0 {Открыть/закрыть окно просмотра индексов ECO}
menuText R WindowsRepertoire "Редактор дебютного репертуара" 0 \
  {Открыть/закрыть окно редактора дебютного репертуара}
menuText R WindowsStats "Окно статистики" 0 \
  {Открыть/закрыть окно статистических данных}
menuText R WindowsTree "Окно с деревом" 0 {Открыть/закрыть окно с деревом ходов}
menuText R WindowsTB "Окно эндшпильных баз" 1 \
  {Открыть/закрыть окно эндшпильных баз данных}

# Tools menu:
menuText R Tools "Инструменты" 0
menuText R ToolsAnalysis "Движок анализа..." 0 \
  {Запустить/остановить движок анализа}
menuText R ToolsAnalysis2 "Движок анализа #2..." 17 \
  {Запустить/остановить второй движок анализа}
menuText R ToolsCross "Таблица результатов" 0 {Показать турнирную таблицу для данной партии}
menuText R ToolsEmail "Администратор электронной почты" 0 \
  {Открыть/закрыть окно администратора шахматной почты}
menuText R ToolsFilterGraph "График фильтра" 7 \
  {Открыть/закрыть окно графика фильтра}
menuText R ToolsOpReport "Отчет по дебюту" 0 \
  {Создать дебютный отчет по данной позиции}
menuText R ToolsTracker "Траектория фигур"  0 {Открыть окно слежения за траекторией фигур}
menuText R ToolsPInfo "Информацию об игроке"  0 \
  {Открыть/обновить окно с информацией об игроке}
menuText R ToolsRating "График рейтинга" 0 \
  {Построить график изменения рейтинга участников данной партии}
menuText R ToolsScore "График очков" 0 {Показать окно с графиком набранных очков}
menuText R ToolsExpCurrent "Экспорт текущей партии" 8 \
  {Записать текущую партию в текстовый файл}
menuText R ToolsExpCurrentPGN "Экспорт партии в файл PGN..." 15 \
  {Записать текущую партию в файл PGN}
menuText R ToolsExpCurrentHTML "Экспорт партии в файл HTML..." 15 \
  {Записать текущую партию в файл HTML}
menuText R ToolsExpCurrentLaTeX "Экспорт партии в файл LaTeX..." 15 \
  {Записать текущую партию в файл LaTeX}
menuText R ToolsExpFilter "Экспорт всех отфильтрованных партий" 1 \
  {Записать все партии фильтра в текстовый файл}
menuText R ToolsExpFilterPGN "Экспорт всех отфильтрованных партий в PGN..." 17 \
  {Записать все партии фильтра в файл PGN}
menuText R ToolsExpFilterHTML "Экспорт всех отфильтрованных партий в HTML..." 17 \
  {Записать все партии фильтра в файл HTML}
menuText R ToolsExpFilterLaTeX "Экспорт всех отфильтрованных партий в LaTeX..." 17 \
  {Записать все партии фильтра в файл LaTeX}
menuText R ToolsImportOne "Импортировать одну партию из PGN..." 0 \
  {Импортировать одну партию из записи PGN}
menuText R ToolsImportFile "Импортировать файл PGN..." 7 \
  {Импортировать партии из файла PGN}

# Options menu:
menuText R Options "Установки" 0
menuText R OptionsSize "Размер доски" 0 {Изменить размер доски}
menuText R OptionsPieces "Тип фигур" 6 {Изменить тип фигур}
menuText R OptionsColors "Цвета..." 0 {Изменить цвета доски и фигур}
menuText R OptionsExport "Экспорт" 0 {Изменить установки экспорта текстов}
menuText R OptionsFonts "Шрифты" 0 {Изменить шрифты}
menuText R OptionsFontsRegular "Обычный" 0 {Изменить обычный шрифт}
menuText R OptionsFontsMenu "Menu" 0 {Change the menu font} ;# ***
menuText R OptionsFontsSmall "Мелкий" 0 {Изменить мелкий шрифт}
menuText R OptionsFontsFixed "Фиксированный" 0 {Изменить фиксированный шрифт}
menuText R OptionsGInfo "Информация о партии" 0 {Установки информации о партии}
menuText R OptionsLanguage "Язык" 0 {Выбрать язык для программы}
menuText R OptionsMoves "Ходы" 0 {Установки ввода ходов}
menuText R OptionsMovesAsk "Предупреждать о замене хода" 0 \
  {Предупреждать о заменен уже существующих ходов}
menuText R OptionsMovesDelay "Интервал воспроизведения..." 1 \
  {Установить интервал автоматического воспроизведения ходов}
menuText R OptionsMovesCoord "Ход с указанием полей" 0 \
  {Принять ввод хода по полям ("g1f3")}
menuText R OptionsMovesSuggest "Показывать предполагаемые ходы" 0 \
  {Предлагать/не предлагать возможные ходы}
menuText R OptionsMovesKey "Автозавершение хода" 0 \
  {Включить/выключить автоматическое завершение хода}
menuText R OptionsNumbers "Формат чисел" 0 {Выбрать формат чисел}
menuText R OptionsStartup "Запуск" 3 {Выбрать окна для их открытия при запуске программы}
menuText R OptionsWindows "Окна" 0 {Window options}
menuText R OptionsWindowsIconify "Автосворачивание" 5 \
  {Автоматически сворачивать все окна, если свернуто главное окно}
menuText R OptionsWindowsRaise "Авторазворачивание" 5 \
  {Показать определенные окна (например, с полосой процесса), если они загорожены}
menuText R OptionsToolbar "Панель инструментов" 12 \
  {Выводить/убирать панель инструментов главного окна}
menuText R OptionsECO "Загрузить файл с ECO..." 7 {Загрузить файл с индексами ECO}
menuText R OptionsSpell "Загрузить проверочный файл..." 6 \
  {Загрузить проверочный файл}
menuText R OptionsTable "Каталог эншпильных баз..." 10 \
  {Для выбора файла эндшпильной базы; будут использованы все эндшпильные базы в его каталоге}
menuText R OptionsRecent "Recent files..." 0 \
  {Change the number of recent files displayed in the File menu} ;# ***
menuText R OptionsSave "Сохранить установки" 0 \
  "Сохранить все установки в файл $::optionsFile"
menuText R OptionsAutoSave "Автосохранение установок при выходе" 0 \
  {Аватоматически сохранять все установки при выходе из программы}

# Help menu:
menuText R Help "Справка" 0
menuText R HelpIndex "Указатель" 0 {Показать указатель справки}
menuText R HelpGuide "Вводный курс" 0 {Показать вводный курс}
menuText R HelpHints "Советы" 0 {Показать советы}
menuText R HelpContact "Контактная информация" 0 {Показать контактную информацию}
menuText R HelpTip "Совет дня" 0 {Показать полезный совет}
menuText R HelpStartup "Пусковое окно" 0 {Показать пусковое окно}
menuText R HelpAbout "О программе" 0 {О программе Scid}

# Game info box popup menu:
menuText R GInfoHideNext "Не показывать следующий ход" 0
menuText R GInfoMaterial "Показывать количество фигур" 0
menuText R GInfoFEN "Показывать FEN" 5
menuText R GInfoMarks "Показывать цветные квадраты и стрелки" 5
menuText R GInfoWrap "Перенос длинных строк" 0
menuText R GInfoFullComment "Показывать все примечание" 10
menuText R GInfoTBNothing "Эндшпильные базы: ничего" 12
menuText R GInfoTBResult "Эндшпильные базы: только результат" 12
menuText R GInfoTBAll "Эндшпильные базы: результат и лучшие ходы" 19
menuText R GInfoDelete "Удалить партию (или восстановить)" 4
menuText R GInfoMark "Пометить партию (или снять метку)" 4

# Main window buttons:
helpMsg R .button.start {К началу партии (клавиша: Home)}
helpMsg R .button.end {К концу партии (клавиша: End)}
helpMsg R .button.back {Ход назад (клавиша: LeftArrow)}
helpMsg R .button.forward {Ход вперед (клавиша: RightArrow)}
helpMsg R .button.intoVar {Перейти на вариант (клавиша: v)}
helpMsg R .button.exitVar {Выйти из варианта (клавиша: z)}
helpMsg R .button.flip {Вращать доску (клавиша: .)}
helpMsg R .button.coords {Показать/убрать координаты (клавиша: 0)}
helpMsg R .button.autoplay {Воспроизведение партии (клавиши: Ctrl+Z)}

# General buttons:
translate R Back {Назад}
translate R Cancel {Отмена}
translate R Clear {Очистить}
translate R Close {Закрыть}
translate R Defaults {По умолчанию}
translate R Delete {Удалить}
translate R Graph {График}
translate R Help {Справка}
translate R Import {Импорт}
translate R Index {Указатель}
translate R LoadGame {Загрузить партию}
translate R BrowseGame {Просмотр партии}
translate R MergeGame {Объединить партию}
translate R Preview {Предварительный просмотр}
translate R Revert {Возврат}
translate R Save {Сохранить}
translate R Search {Поиск}
translate R Stop {Стоп}
translate R Store {Сохранить}
translate R Update {Обновить}
translate R ChangeOrient {Изменить положение окна}
translate R None {Ни одного}
translate R First {Первый}
translate R Current {Текущий}
translate R Last {Последний}

# General messages:
translate R game {партия}
translate R games {партии}
translate R move {ход}
translate R moves {ходы}
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
translate R RatingDiff {Разница в рейтинге (Белые - Черные)}
translate R Event {Соревнование}
translate R Site {Место проведения}
translate R Country {Страна}
translate R IgnoreColors {Игнорировать цвет фигур}
translate R Date {Дата}
translate R EventDate {Дата проведения}
translate R Decade {Десятилетие}
translate R Year {Год}
translate R Month {Месяц}
translate R Months {Январь Февраль Март Апрель Май Июнь
  Июль Август Сентябрь Октябрь Ноябрь Декабрь}
translate R Days {Вс Пн Вт Ср Чт Пт Сб}
translate R YearToToday {За год}
translate R Result {Результат}
translate R Round {Тур}
translate R Length {Длина}
translate R ECOCode {Индекс ECO}
translate R ECO {ECO}
translate R Deleted {Удален}
translate R SearchResults {Результаты поиска}
translate R OpeningTheDatabase {Дебютная база}
translate R Database {База данных}
translate R Filter {Фильтр}
translate R noGames {нет партий}
translate R allGames {все партии}
translate R empty {пустой}
translate R clipbase {временная БД}
translate R score {очки}
translate R StartPos {Начальная позиция}
translate R Total {Всего}

# Game information:
translate R twin {копия}
translate R deleted {удален}
translate R comment {комментарий}
translate R hidden {скрытый}
translate R LastMove {Последний ход}
translate R NextMove {Следующий}
translate R GameStart {Начало партии}
translate R LineStart {Начало варианта}
translate R GameEnd {Конец партии}
translate R LineEnd {Конец варианта}

# Player information:
translate R PInfoAll {Результаты для <b>всех</b> игр}
translate R PInfoFilter {Результаты для <b>игр</b> фильтра}
translate R PInfoAgainst {Результаты против}
translate R PInfoMostWhite {Наиболее распространенные дебюты за белых}
translate R PInfoMostBlack {Наиболее распространенные дебюты за черных}
translate R PInfoRating {История рейтинга}
translate R PInfoBio {Биография}

# Tablebase information:
translate R Draw {Ничья}
translate R stalemate {пат}
translate R withAllMoves {всеми ходами}
translate R withAllButOneMove {всеми ходами кроме одного}
translate R with {с}
translate R only {только}
translate R lose {проигрывают}
translate R loses {проигрывает}
translate R allOthersLose {все другие проигрывают}
translate R matesIn {мат в}
translate R hasCheckmated {заматованы}
translate R longest {самое большее}

# Tip of the day:
translate R Tip {Совет}
translate R TipAtStartup {Совет при запуске}

# Tree window menus:
menuText R TreeFile "Файл" 0
menuText R TreeFileSave "Сохранить кэш-файл" 0 {Сохранить кэш-файл (.stc) с деревом ходов}
menuText R TreeFileFill "Заполнить кэш-файл" 0 \
  {Заполнить кэш-файл распространенными дебютными позициями}
menuText R TreeFileBest "Список лучших игр" 0 {Показать список лучших игра по положению в дереве ходов}
menuText R TreeFileGraph "Окно графика" 0 {Показать график для данной ветви дерева ходов}
menuText R TreeFileCopy "Скопировать статистику дерева ходов в буфер обмена" 1 \
  {Скопировать статистику дерева ходов в буфер обмена}
menuText R TreeFileClose "Закрыть дерево" 0 {Закрыть окно с деревом ходов}
menuText R TreeSort "Сортировать" 0
menuText R TreeSortAlpha "По алфавиту" 0
menuText R TreeSortECO "По ECO" 0
menuText R TreeSortFreq "По частоте" 0
menuText R TreeSortScore "По очкам" 0
menuText R TreeOpt "Установки" 0
menuText R TreeOptLock "Прикрепить" 0 {Прикрепить/открепить дерево ходов к/от текущей базе данных}
menuText R TreeOptTraining "Тренировка" 0 {Включить/выключить тренировочный режим по дереву ходов}
menuText R TreeOptAutosave "Автосохранение кэш-файла" 0 \
  {Автоматически сохранять кэш-файл при закрытии окна с деревом ходов}
menuText R TreeHelp "Справка" 0
menuText R TreeHelpTree "Справка по дереву" 0
menuText R TreeHelpIndex "Указатель" 0
translate R SaveCache {Сохранить кэш}
translate R Training {Тренировка}
translate R LockTree {Прикрепить}
translate R TreeLocked {прикреплено}
translate R TreeBest {Лучшие}
translate R TreeBestGames {Лечшие игры в дереве}

# Finder window:
menuText R FinderFile "Файл" 0
menuText R FinderFileSubdirs "Искать в подкаталогах" 0
menuText R FinderFileClose "Закрыть поиск файлов" 0
menuText R FinderSort "Сортировка" 0
menuText R FinderSortType "Тип" 0
menuText R FinderSortSize "Размер" 0
menuText R FinderSortMod "Время" 0
menuText R FinderSortName "Имя" 0
menuText R FinderSortPath "Путь" 0
menuText R FinderTypes "Типы" 0
menuText R FinderTypesScid "Базы данных Scid" 0
menuText R FinderTypesOld "БД старого формата Scid" 0
menuText R FinderTypesPGN "файлы PGN" 0
menuText R FinderTypesEPD "файлы EPD" 0
menuText R FinderTypesRep "Файлы репертуара" 0
menuText R FinderHelp "Справка" 0
menuText R FinderHelpFinder "Справка по поиску файлов" 0
menuText R FinderHelpIndex "Указатель" 0
translate R FileFinder {Поиск файлов}
translate R FinderDir {Каталог}
translate R FinderDirs {Каталоги}
translate R FinderFiles {Файлы}
translate R FinderUpDir {вверх}

# Tournament finder:
menuText R TmtFile "Файл" 0
menuText R TmtFileUpdate "Обновить" 0
menuText R TmtFileClose "Закрыть поиск турниров" 0
menuText R TmtSort "Сортировка" 0
menuText R TmtSortDate "Дата" 0
menuText R TmtSortPlayers "Игроки" 0
menuText R TmtSortGames "Игры" 0
menuText R TmtSortElo "Elo" 0
menuText R TmtSortSite "Место" 0
menuText R TmtSortEvent "Соревнование" 1
menuText R TmtSortWinner "Победитель" 0
translate R TmtLimit "Ограничение списка"
translate R TmtMeanElo "Наименьшее среднее значение Elo"
translate R TmtNone "Таких турниров не обнаружено."

# Graph windows:
menuText R GraphFile "Файл" 0
menuText R GraphFileColor "Сохранить как цветной PostScript..." 8
menuText R GraphFileGrey "Сохранить как PostScript с градациями серого..." 8
menuText R GraphFileClose "Закрыть окно" 6
menuText R GraphOptions "Установки" 0
menuText R GraphOptionsWhite "Белые" 0
menuText R GraphOptionsBlack "Черные" 0
menuText R GraphOptionsBoth "Оба" 1
menuText R GraphOptionsPInfo "Игрок Инфо игрок" 0
translate R GraphFilterTitle "График фильтра: периодичность на 1000 партий"

# Analysis window:
translate R AddVariation {Добавить вариант}
translate R AddMove {Добавить ход}
translate R Annotate {Комментарий}
translate R AnalysisCommand {команда Анализ}
translate R PreviousChoices {Предыдущий выбор}
translate R AnnotateTime {Установить время между ходами в сек.}
translate R AnnotateWhich {Добавить варианты}
translate R AnnotateAll {Для ходов обеих сторон}
translate R AnnotateWhite {Для ходов белых только}
translate R AnnotateBlack {Для ходов черных только}
translate R AnnotateNotBest {Когда ход не самый лучший}

# Analysis Engine open dialog:
translate R EngineList {Лист аналитических движков}
translate R EngineName {Имя}
translate R EngineCmd {Команда}
translate R EngineArgs {Параметры}
translate R EngineDir {Каталог}
translate R EngineElo {Elo}
translate R EngineTime {Дата}
translate R EngineNew {Новый}
translate R EngineEdit {Изменить}
translate R EngineRequired {Разделы, выделенные жирным, - необходимы; остальные можно пропустить}

# Stats window menus:
menuText R StatsFile "Файл" 0
menuText R StatsFilePrint "Сохранить как файл..." 0
menuText R StatsFileClose "Закрыть окно" 0
menuText R StatsOpt "Установки" 0

# PGN window menus:
menuText R PgnFile "Файл" 0
menuText R PgnFilePrint "Сохранить как файл..." 0
menuText R PgnFileClose "Закрыть окно PGN" 0
menuText R PgnOpt "Вид" 0
menuText R PgnOptColor "В цвете" 0
menuText R PgnOptShort "Укороченный (3 строки) заголовок" 0
menuText R PgnOptSymbols "Примечания с символами" 1
menuText R PgnOptIndentC "Отступ для комментарий" 0
menuText R PgnOptIndentV "Отступ для вариантов" 7
menuText R PgnOptColumn "В колонку (по одному ходу на строку)" 1
menuText R PgnOptSpace "Пробел после номера хода" 1
menuText R PgnOptStripMarks "Убрать обозначения квадратов/стрелок" 1
menuText R PgnColor "Цвета" 0
menuText R PgnColorHeader "Заголовок..." 0
menuText R PgnColorAnno "Примечания..." 0
menuText R PgnColorComments "Комментарии..." 0
menuText R PgnColorVars "Варианты..." 0
menuText R PgnColorBackground "Фон..." 0
menuText R PgnHelp "Справка" 0
menuText R PgnHelpPgn "Справка о PGN" 0
menuText R PgnHelpIndex "Указатель" 0

# Crosstable window menus:
menuText R CrosstabFile "Файл" 0
menuText R CrosstabFileText "Сохранить как текстовый файл..." 9
menuText R CrosstabFileHtml "Сохранить как файл HTML..." 9
menuText R CrosstabFileLaTeX "Сохранить как файл LaTeX..." 9
menuText R CrosstabFileClose "Закрыть окно с результатами" 0
menuText R CrosstabEdit "Редактировать" 0
menuText R CrosstabEditEvent "Соревнование" 0
menuText R CrosstabEditSite "Место" 0
menuText R CrosstabEditDate "Дата" 0
menuText R CrosstabOpt "Вид" 0
menuText R CrosstabOptAll "Круговой" 0
menuText R CrosstabOptSwiss "Швейцарка" 0
menuText R CrosstabOptKnockout "С выбыванием" 0
menuText R CrosstabOptAuto "Авто" 1
menuText R CrosstabOptAges "Возраст (лет)" 8
menuText R CrosstabOptNats "Национальность" 0
menuText R CrosstabOptRatings "Рейтинг" 0
menuText R CrosstabOptTitles "Звание" 0
menuText R CrosstabOptBreaks "Очки на тай-брейке" 4
menuText R CrosstabOptDeleted "Включить удаленные игры" 8
menuText R CrosstabOptColors "Цвета (Только для швейцарки)" 0
menuText R CrosstabOptColumnNumbers "Нумерация колонок (Только для круговых турниров)" 2
menuText R CrosstabOptGroup "Очки в группе" 0
menuText R CrosstabSort "Сортировать" 0
menuText R CrosstabSortName "Имя" 0
menuText R CrosstabSortRating "Рейтинг" 0
menuText R CrosstabSortScore "Очки" 0
menuText R CrosstabColor "Цвет" 0
menuText R CrosstabColorPlain "Только текст" 0
menuText R CrosstabColorHyper "Гипертекст" 0
menuText R CrosstabHelp "Справка" 0
menuText R CrosstabHelpCross "Справка по таблице" 0
menuText R CrosstabHelpIndex "Указатель справки" 0
translate R SetFilter {Установить фильтр}
translate R AddToFilter {Добавить в фильтр}
translate R Swiss {Швейцарка}

# Opening report window menus:
menuText R OprepFile "Файл" 0
menuText R OprepFileText "Сохранить как текстовый файл..." 9
menuText R OprepFileHtml "Сохранить как HTML..." 9
menuText R OprepFileLaTeX "Сохранить как LaTeX..." 9
menuText R OprepFileOptions "Установки..." 0
menuText R OprepFileClose "Закрыть окно отчета" 0
menuText R OprepHelp "Справка" 0
menuText R OprepHelpReport "Справка по дебютному отчету" 0
menuText R OprepHelpIndex "Указатель справки" 0

# Repertoire editor:
menuText R RepFile "Файл" 0
menuText R RepFileNew "Создать" 0
menuText R RepFileOpen "Открыть..." 0
menuText R RepFileSave "Сохранить..." 0
menuText R RepFileSaveAs "Сохранить как..." 5
menuText R RepFileClose "Закрыть окно" 0
menuText R RepEdit "Редактировать" 0
menuText R RepEditGroup "Добавить группу" 4
menuText R RepEditInclude "Добавить включенный вариант" 4
menuText R RepEditExclude "Добавить исключенный вариант" 4
menuText R RepView "Вид" 0
menuText R RepViewExpand "Раскрыть все группы" 0
menuText R RepViewCollapse "Свернуть все группы" 0
menuText R RepSearch "Поиск" 0
menuText R RepSearchAll "Весь репертуар..." 0
menuText R RepSearchDisplayed "Только выбранные варианты..." 0
menuText R RepHelp "Справка" 0
menuText R RepHelpRep "Справка по репертуару" 0
menuText R RepHelpIndex "Индекс справки" 0
translate R RepSearch "Поиск в репертуаре"
translate R RepIncludedLines "включенные варианты"
translate R RepExcludedLines "исключенные варианты"
translate R RepCloseDialog {Изменения в репертуаре не были сохранены.

Вы действительно хотите продолжить с потерей всех сделанных изменений?
}

# Header search:
translate R HeaderSearch {Поиск по заголовку}
translate R GamesWithNoECO {Игры без индекса ECO?}
translate R GameLength {Длина игры}
translate R FindGamesWith {Найти игры с признаками}
translate R StdStart {Нестандартное начало}
translate R Promotions {Пешка дошла до 8 горизонтали}
translate R Comments {Комментарии}
translate R Variations {Варианты}
translate R Annotations {Примечания}
translate R DeleteFlag {Удалить признак}
translate R WhiteOpFlag {Дебют за белых}
translate R BlackOpFlag {Дебют за черных}
translate R MiddlegameFlag {Миттельшпиль}
translate R EndgameFlag {Эндшпиль}
translate R NoveltyFlag {Новинка}
translate R PawnFlag {Пешечная структура}
translate R TacticsFlag {Тактика}
translate R QsideFlag {Игра на ферзевом фланге}
translate R KsideFlag {Игра на королевском фланге}
translate R BrilliancyFlag {Блестящий ход}
translate R BlunderFlag {Просмотр}
translate R UserFlag {Пользователь}
translate R PgnContains {в PGN имеется текст}

# Game list window:
translate R GlistNumber {Номер}
translate R GlistWhite {Белые}
translate R GlistBlack {Черные}
translate R GlistWElo {Б Elo}
translate R GlistBElo {Ч Elo}
translate R GlistEvent {Соревнование}
translate R GlistSite {Место}
translate R GlistRound {Тур}
translate R GlistDate {Дата}
translate R GlistYear {Год}
translate R GlistEDate {Дата проведения}
translate R GlistResult {Результат}
translate R GlistLength {Длина}
translate R GlistCountry {Страна}
translate R GlistECO {ECO}
translate R GlistOpening {Дебют}
translate R GlistEndMaterial {Оставшийся материал}
translate R GlistDeleted {Удалить}
translate R GlistFlags {Признаки}
translate R GlistVars {Варианты}
translate R GlistComments {Комментарии}
translate R GlistAnnos {Примечания}
translate R GlistStart {Начало}
translate R GlistGameNumber {Номер игры}
translate R GlistFindText {Найти текст}
translate R GlistMoveField {Ход}
translate R GlistEditField {Сконфигурировать}
translate R GlistAddField {Добавить}
translate R GlistDeleteField {Удалить}
translate R GlistWidth {Ширина}
translate R GlistAlign {Выравнивание}
translate R GlistColor {Цвет}
translate R GlistSep {Разделитель}

# Maintenance window:
translate R DatabaseName {Название БД:}
translate R TypeIcon {Тип пикт.:}
translate R NumOfGames {Партий:}
translate R NumDeletedGames {Удаленных партий:}
translate R NumFilterGames {Игр в фильтре:}
translate R YearRange {Период времени:}
translate R RatingRange {Рейтинговый диапазон:}
translate R Flag {Признак}
translate R DeleteCurrent {Удалить текущую партию}
translate R DeleteFilter {Удалить партии в фильтре}
translate R DeleteAll {Удалить все партии}
translate R UndeleteCurrent {Восстановить текущую партию}
translate R UndeleteFilter {Восстановить партии в фильтре}
translate R UndeleteAll {Восстановить все партии}
translate R DeleteTwins {Удалить копии}
translate R MarkCurrent {Пометить текущую партию}
translate R MarkFilter {Пометить все партии в фильтре}
translate R MarkAll {Пометить все партии}
translate R UnmarkCurrent {Убрать пометку с текущей партии}
translate R UnmarkFilter {Убрать пометку с партий в фильтре}
translate R UnmarkAll {Убрать пометку со всех партий}
translate R Spellchecking {Проверка названий}
translate R Players {Игроки}
translate R Events {Соревнование}
translate R Sites {Место}
translate R Rounds {Тур}
translate R DatabaseOps {Операции с БД}
translate R ReclassifyGames {Установить индекс ECO}
translate R CompactDatabase {Сжать БД}
translate R SortDatabase {Сортировать БД}
translate R AddEloRatings {Добавить рейтинг Elo}
translate R AutoloadGame {Автозагрузка партии #}
translate R StripTags {Убрать заголовки PGN}
translate R StripTag {Убрать заголовки}
translate R Cleaner {Очистка}
translate R CleanerHelp {
Будут произведены все операции по очистке текущей БД, которые вы выбрали в списке.

Для установки индекса ECO и удаления копий будут использованы уже выбранные вами установки.
}
translate R CleanerConfirm {
После запуска очистки она не может быть прервана!

Это может занять много времени, если БД большая в зависимости от операций, которые вы выбрали и сделанных вами установок.

Вы уверены, что хотите запустить выбранные вами операции?
}

# Comment editor:
translate R AnnotationSymbols  {Символы аннотации:}
translate R Comment {Комментарий:}

# Board search:
translate R BoardSearch {Поиск позиции}
translate R FilterOperation {Операции для данного фильтра:}
translate R FilterAnd {И (Ограничить фильтр)}
translate R FilterOr {ИЛИ (Добавить в фильтр)}
translate R FilterIgnore {ИГНОРИРОВАТЬ (Установить фильтр заново)}
translate R SearchType {Тип поиска:}
translate R SearchBoardExact {Точное соответствие (положение то же самое)}
translate R SearchBoardPawns {Пешки (тот же материал, все пешки на тех же полях)}
translate R SearchBoardFiles {Вертикали (тот же материал, все пешки на тех же вертикалях)}
translate R SearchBoardAny {Произвольное (тот же материал, расположение пешек и фигур произвольное)}
translate R LookInVars {Искать в вариантах}

# Material search:
translate R MaterialSearch {Поиск по материалу}
translate R Material {Материал}
translate R Patterns {Образцы}
translate R Zero {Нулевой}
translate R Any {Любой}
translate R CurrentBoard {Текущая позиция}
translate R CommonEndings {Распространенные окончания}
translate R CommonPatterns {Известные образцы}
translate R MaterialDiff {Различия в материале}
translate R squares {поля}
translate R SameColor {Того же цвета}
translate R OppColor {Другого цвета}
translate R Either {Любого}
translate R MoveNumberRange {Количество ходов}
translate R MatchForAtLeast {Соответствие по меньшей мере}
translate R HalfMoves {полуходы}

# Game saving:
translate R Today {Сегодня}
translate R ClassifyGame {Классификация партии}

# Setup position:
translate R EmptyBoard {Очистить доску}
translate R InitialBoard {Начальная позиция}
translate R SideToMove {Чей ход}
translate R MoveNumber {Ход номер}
translate R Castling {Рокировка}
translate R EnPassentFile {На проходе - вертикаль}
translate R ClearFen {Очистить FEN}
translate R PasteFen {Вставить FEN}

# Replace move dialog:
translate R ReplaceMove {Заменить ход}
translate R AddNewVar {Добавить новый вариант}
translate R ReplaceMoveMessage {Ход уже существует.

Вы можете заменить его, тем самым отменив имеющиеся после него ходы, или добавить ход как новый вариант.

(Вы можете отменить появление этого предупреждения убрав флаг "Запрос перед заменой ходов" в меню "Установки:Ходы".)}

# Make database read-only dialog:
translate R ReadOnlyDialog {Если вы определите БД как "только для чтения", ее невозможно будет изменить.
Партии невозможно будет сохранять или замещать, и нельзя будет изменять флаг "Удалить" для партии.
Сортировка или индексирование ECO будут временными.

Вы можете легко сделать БД опять редактируемой, закрыв ее и открыв повторно.

Вы действительно хотите определить эту БД как "только для чтения"?}

# Clear game dialog:
translate R ClearGameDialog {Эта партия была изменена.

Вы действительно хотите продолжить и отменить изменения?
}

# Exit dialog:
translate R ExitDialog {Вы действительно хотите закрыть программу Scid?}
translate R ExitUnsaved {В следующих базах данных есть партии, которые были изменены.
При закрытии эти изменения будут потеряны.}

# Import window:
translate R PasteCurrentGame {Вставить текущую партию}
translate R ImportHelp1 {Ввести или вставить партию в формате PGN в рамку наверху.}
translate R ImportHelp2 {Все ошибки при импорте партии будут показаны здесь.}

# ECO Browser:
translate R ECOAllSections {все разделы ECO}
translate R ECOSection {раздел ECO}
translate R ECOSummary {Сводка для}
translate R ECOFrequency {Частота индексов для}

# Opening Report:
translate R OprepTitle {Отчет по дебюту}
translate R OprepReport {Отчет}
translate R OprepGenerated {Сделан с помощью}
translate R OprepStatsHist {Статистика и история}
translate R OprepStats {Статистика}
translate R OprepStatAll {Всего партий}
translate R OprepStatBoth {Рейтинг обоих}
translate R OprepStatSince {С}
translate R OprepOldest {Самые старые}
translate R OprepNewest {Самые новые}
translate R OprepPopular {Текущая частотность}
translate R OprepFreqAll {Частотность за все годы:   }
translate R OprepFreq1   {За последний год: }
translate R OprepFreq5   {За 5 последних лет: }
translate R OprepFreq10  {За 10 последних лет: }
translate R OprepEvery {одна на каждые %u партий}
translate R OprepUp {увеличение %u%s за все годы}
translate R OprepDown {уменьшение %u%s за все годы}
translate R OprepSame {без изменений за все годы}
translate R OprepMostFrequent {Наиболее частотные игроки}
translate R OprepRatingsPerf {Рейтинги и перфоманс}
translate R OprepAvgPerf {Средние рейтинги и перфоманс}
translate R OprepWRating {Рейтинг белых}
translate R OprepBRating {Рейтинг черных}
translate R OprepWPerf {Перфоманс белых}
translate R OprepBPerf {Перфоманс черных}
translate R OprepHighRating {Партии с самым высоким средним рейтингом}
translate R OprepTrends {Тренды результатов}
translate R OprepResults {Длина и частота результатов}
translate R OprepLength {Длина партий}
translate R OprepFrequency {Частота}
translate R OprepWWins {Белые выиграли: }
translate R OprepBWins {Черные выиграли: }
translate R OprepDraws {Ничьи:      }
translate R OprepWholeDB {вся база данных}
translate R OprepShortest {Самый быстрый выигрыш}
translate R OprepMovesThemes {Ходы и темы}
translate R OprepMoveOrders {Последовательности ходов достижения данной позиции}
translate R OprepMoveOrdersOne \
  {Только одна последовательность ходов для данной позиции:}
translate R OprepMoveOrdersAll \
  {%u последовательности(-тей) ходов для данной позиции:}
translate R OprepMoveOrdersMany \
  {Было %u последовательностей ходов для данной позиции. Главные %u это:}
translate R OprepMovesFrom {Ходы в данной позиции}
translate R OprepThemes {Позиционные темы}
translate R OprepThemeDescription {Частота тем при ходе %u}
translate R OprepThemeSameCastling {Односторонняя рокировка}
translate R OprepThemeOppCastling {Разносторонняя рокировка}
translate R OprepThemeNoCastling {Оба короля не рокированы}
translate R OprepThemeKPawnStorm {Пешечная атака на королевском фланге}
translate R OprepThemeQueenswap {Размен ферзей}
translate R OprepThemeIQP {Изолированная пешка d}
translate R OprepThemeWP567 {Белая пешка на 5/6/7 ряду}
translate R OprepThemeBP234 {Черная пешка на 2/3/4 ряду}
translate R OprepThemeOpenCDE {Открытая линия c/d/e}
translate R OprepTheme1BishopPair {Преимущество двух слонов}
translate R OprepEndgames {Эндшпили}
translate R OprepReportGames {Партии отчета}
translate R OprepAllGames    {Все партии}
translate R OprepEndClass {Материал к концу каждой партии}
translate R OprepTheoryTable {Таблица ходов}
translate R OprepTableComment {Получена на основе %u партий с высшим рейтингом.}
translate R OprepExtraMoves {Дополнительные ходы в таблице ходов}
translate R OprepMaxGames {Максимальное количество партий в таблице ходов}

# Piece Tracker window:
translate R TrackerSelectSingle {Левая клавиша мыши для выбора этой фигуры.}
translate R TrackerSelectPair {Левая клавиша мыши для выбора этой фигуры; правая клавиша - для выбора также парной ей.}
translate R TrackerSelectPawn {Левая клавиша мыши для выбора этой пешки; правая клавиша мыши - для выбора всех 8 пешек.}
translate R TrackerStat {Статистика}
translate R TrackerGames {% игр с ходом на поле}
translate R TrackerTime {% раз на каждом поле}
translate R TrackerMoves {Ходы}
translate R TrackerMovesStart {Введите номер хода, с которого начнется траектория.}
translate R TrackerMovesStop {Введите номер хода, на котором закончится траектория.}

# Game selection dialogs:
translate R SelectAllGames {Все партии в БД}
translate R SelectFilterGames {Только партии в фильтре}
translate R SelectTournamentGames {Только партии данного соревнования}
translate R SelectOlderGames {Только прежние партии}

# Delete Twins window:
translate R TwinsNote {Партии будут признаны копиями, если сыграны теми же участниками и соответствуют тем критериям, которые вы выберете ниже. При обнаружении копий будет удалена та, в которой меньше ходов.
Подсказка: лучше всего провести проверку базы дынных перед удалением партий-копий, это поможет лучшему их определения. }
translate R TwinsCriteria {Критерии: Копии должны иметь...}
translate R TwinsWhich {Проверять игры, где}
translate R TwinsColors {Тот же цвет фигур у партнеров?}
translate R TwinsEvent {Тот же турнир?}
translate R TwinsSite {То же место?}
translate R TwinsRound {Тот же раунд?}
translate R TwinsYear {Тот же год?}
translate R TwinsMonth {Тот же месяц?}
translate R TwinsDay {Тот же день?}
translate R TwinsResult {Тот же результат?}
translate R TwinsECO {Тот же индекс ECO?}
translate R TwinsMoves {Те же ходы?}
translate R TwinsPlayers {При сравнении имен игроков:}
translate R TwinsPlayersExact {Точное соответствие}
translate R TwinsPlayersPrefix {Первые 4 буквы только}
translate R TwinsWhen {При удалении копий}
translate R TwinsSkipShort {Игнорировать все партии длиной менее 5 ходов?}
translate R TwinsUndelete {Вначале восстановить все удаленные партии?}
translate R TwinsSetFilter {Все партии-копии поместить в фильтр?}
translate R TwinsComments {Всегда сохранять партии комментарием?}
translate R TwinsVars {Всегда сохранять партии с вариантами?}
translate R TwinsDeleteWhich {Удалить какую игру:}
translate R TwinsDeleteShorter {Более короткую партию}
translate R TwinsDeleteOlder {Партию с меньшим номером}
translate R TwinsDeleteNewer {Партию с большим номером}
translate R TwinsDelete {Удалить партии}

# Name editor window:
translate R NameEditType {Тип редактируемого имени}
translate R NameEditSelect {Редактируемые игры}
translate R NameEditReplace {Заменить}
translate R NameEditWith {на}
translate R NameEditMatches {Соответствия: Нажмите клавиши с Ctrl+1 до Ctrl+9 для выбора}

# Classify window:
translate R Classify {Индексация}
translate R ClassifyWhich {Определять индекс ECO для партии}
translate R ClassifyAll {Всех партий (с заменой прежних индексов)}
translate R ClassifyYear {Всех партий последнего года}
translate R ClassifyMonth {Всех партий последнего месяца}
translate R ClassifyNew {Только партий без индекса}
translate R ClassifyCodes {Использовать индексы ECO}
translate R ClassifyBasic {Только основной индекс ("B12", ...)}
translate R ClassifyExtended {Дополнительный, для Scid ("B12j", ...)}

# Compaction:
translate R NameFile {Файл имен}
translate R GameFile {Файл партий}
translate R Names {Имена}
translate R Unused {Не используется}
translate R SizeKb {Размер (kb)}
translate R CurrentState {В настоящий момент}
translate R AfterCompaction {После сжатия}
translate R CompactNames {Сжать файл имен}
translate R CompactGames {Сжать файл партий}

# Sorting:
translate R SortCriteria {Признак}
translate R AddCriteria {Добавить признак}
translate R CommonSorts {Самая распространенная сортировка}
translate R Sort {Сортировать}

# Exporting:
translate R AddToExistingFile {Добавить партии в существующий файл?}
translate R ExportComments {Экспортировать комментарии?}
translate R ExportVariations {Экспортировать варианты?}
translate R IndentComments {Отступ для комментариев?}
translate R IndentVariations {Отступ для вариантов?}
translate R ExportColumnStyle {В колонку (по ходу на каждой строчке)?}
translate R ExportSymbolStyle {Стиль символьных примечаний:}
translate R ExportStripMarks {Убрать обозначения квадратов/стрелок из комментария?}

# Goto game/move dialogs:
translate R LoadGameNumber {Введите номер партии для ее загрузки:}
translate R GotoMoveNumber {Перейти к ходу номер:}

# Copy games dialog:
translate R CopyGames {КОпировать игры}
translate R CopyConfirm {
 Вы действительно хотите скопировать
 [thousands $nGamesToCopy] отфильтрованные партии
 из базы данных "$fromName"
 в базу "$targetName"?
}
translate R CopyErr {Не могу скопировать партии}
translate R CopyErrSource {исходная база данных}
translate R CopyErrTarget {выходная база данных}
translate R CopyErrNoGames {не имеет партий в фильтре}
translate R CopyErrReadOnly {только для чтения}
translate R CopyErrNotOpen {не открыта}

# Colors:
translate R LightSquares {Светлые поля}
translate R DarkSquares {Темные поля}
translate R SelectedSquares {Выбранные поля}
translate R SuggestedSquares {Предлагаемые для хода поля}
translate R WhitePieces {Белые фигуры}
translate R BlackPieces {Черные фигуры}
translate R WhiteBorder {Белая кайма}
translate R BlackBorder {Черная кайма}

# Novelty window:
translate R FindNovelty {Найти новый ход}
translate R Novelty {Новый ход}
translate R NoveltyInterrupt {Поиск нового хода прерван}
translate R NoveltyNone {В данной игре не обнаружено нового хода}
translate R NoveltyHelp {
Scid найдет первый ход в данной партии, при котором получается позиция, которой нет в выбранной базе данных или в дебютной библиотеке ECO.
}

# Upgrading databases:
translate R Upgrading {Конвертирование}
translate R ConfirmOpenNew {
Это база данных старого формата (Scid 2), которая не может быть открыта в Scid 3, однако база данных нового формата (Scid 3) уже была создана.

Вы хотите открыть базу данных нового формата?
}
translate R ConfirmUpgrade {
Это база данных старого формата (Scid 2). A new-format version of the database must be created before it can be used in Scid 3.
Scid 3 может открыть только базу данных нового формата, которую необходимо создать. 

После конвертирования будет создана база данных нового формата, при этом старая база данных также сохранится.

Это может занять некоторое время, однако требуется сделать только раз. Вы можете прервать операцию, если она займет слишком много времени.

Вы хотите сконвертировать эту базу данных прямо сейчас?
}

# Recent files options:
translate R RecentFilesMenu {Number of recent files in File menu} ;# ***
translate R RecentFilesExtra {Number of recent files in extra submenu} ;# ***

}
# end of russian.tcl
