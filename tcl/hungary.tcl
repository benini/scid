# hungary.tcl:
# Hungarian text for menu names and status bar help messages for SCID
# Translated by: Gßbor Szts


addLanguage H Hungarian 0 ;# iso8859-2

proc setLanguage_H {} {

# File menu:
menuText H File "Fßjl" 0
menuText H FileNew "õj..." 0 {õj SCID-adatbßzis l‰trehozßsa}
menuText H FileOpen "Megnyit..." 3 {Megl‰v SCID-adatbßzis megnyitßsa}
menuText H FileClose "Bezßr" 2 {Az aktv SCID-adatbßzis bezßrßsa}
menuText H FileFinder "Fßjlkeres" 0 {Kinyitja a Fßjlkeres ablakot.}
menuText H FileBookmarks "K÷nyvjelzk" 0 {K÷nyvjelzmen’ (gyorsbillenty“: Ctrl+B)}
menuText H FileBookmarksAdd "õj k÷nyvjelz" 0 \
  {Megjel÷li az aktußlis jßtszmßt ‰s ßllßst.}
menuText H FileBookmarksFile "K÷nyvjelz ment‰se" 11 \
  {Az ßllßshoz tartoz k÷nyvjelzt k’l÷n mappßba teszi.}
menuText H FileBookmarksEdit "K÷nyvjelzk szerkeszt‰se..." 13 \
  {K÷nyvjelzk szerkeszt‰se}
menuText H FileBookmarksList "Megjelent‰s listak‰nt" 13 \
  {A k÷nyvjelzmappßk nem almen’k‰nt, hanem listak‰nt jelennek meg.}
menuText H FileBookmarksSub "Megjelent‰s almen’k‰nt" 13 \
  {A k÷nyvjelzmappßk nem listak‰nt, hanem almen’k‰nt jelennek meg.}
menuText H FileMaint "Gondozßs" 0 {SCID adatbßzisgondoz eszk÷z÷k}
menuText H FileMaintWin "Adatbßzisgondoz ablak" 0 \
  {Kinyitja/becsukja az SCID adatbßzisgondoz ablakot.}
menuText H FileMaintCompact "Adatbßzis t÷m÷rt‰se..." 10 \
  {Eltßvoltja az adatbßzisbl a t÷r÷lt jßtszmßkat ‰s a hasznßlaton kv’l ßll neveket.}
menuText H FileMaintClass "Osztßlyba sorolßs..." 0 \
  {õjra kiszßmtja az ÷sszes jßtszma ECO-kdjßt.}
menuText H FileMaintSort "Rendez‰s..." 0 \
  {Rendezi az adatbßzis ÷sszes jßtszmßjßt.}
menuText H FileMaintDelete "Ikerjßtszmßk t÷rl‰se..." 0 \
  {Megkeresi az ikerjßtszmßkat, ‰s megjel÷li ket t÷rl‰sre.}
menuText H FileMaintTwin "Ikerkeres ablak" 4 \
  {Kinyitja/becsukja az ikerkeres ablakot.}
menuText H FileMaintName "Nevek helyesrßsa" 0 {N‰vszerkeszt ‰s helyesrßsi eszk÷z÷k}
menuText H FileMaintNameEditor "N‰vszerkeszt" 0 \
  {Kinyitja/becsukja a n‰vszerkeszt ablakot.}
menuText H FileMaintNamePlayer "Jßt‰kosnevek ellenrz‰se..." 0 \
  {A helyesrßs-ellenrz fßjl segts‰g‰vel ellenrzi a jßt‰kosok nev‰t.}
menuText H FileMaintNameEvent "Esem‰nynevek ellenrz‰se..." 0 \
  {A helyesrßs-ellenrz fßjl segts‰g‰vel ellenrzi esem‰nyek nev‰t.}
menuText H FileMaintNameSite "Helynevek ellenrz‰se..." 0 \
  {A helyesrßs-ellenrz fßjl segts‰g‰vel ellenrzi a helysznek nev‰t.}
menuText H FileMaintNameRound "Fordulnevek ellenrz‰se..." 0 \
  {A helyesrßs-ellenrz fßjl segts‰g‰vel ellenrzi a fordulk nev‰t.}
menuText H FileReadOnly "Írßsv‰delem..." 0 \
  {Az aktußlis adatbßzist csak olvasni lehet, nehogy meg lehessen vßltoztatni.}
menuText H FileSwitch "Adatbßzisvßltßs" 0 \
  {Âtvßlt egy mßsik megnyitott adatbßzisra.}
menuText H FileExit "Kil‰p" 1 {Kil‰p SCID-bl.}

# Edit menu:
menuText H Edit "Szerkeszt‰s" 1
menuText H EditAdd "õj vßltozat" 0 {Enn‰l a l‰p‰sn‰l ”j vßltozatot sz”r be a jßtszmßba.}
menuText H EditDelete "Vßltozat t÷rl‰se" 9 {T÷r÷l egy vßltozatot enn‰l a l‰p‰sn‰l.}
menuText H EditFirst "Els vßltozattß tesz" 0 \
  {Els helyre teszi a vßltozatot a listßn.}
menuText H EditMain "Fvßltozattß tesz" 0 \
  {A vßltozatot fvßltozattß l‰pteti el.}
menuText H EditTrial "Vßltozat kiprbßlßsa" 11 \
  {Elindtja/megßlltja a prba’zemmdot, amellyel egy elgondolßst lehet a tßblßn kiprbßlni.}
menuText H EditStrip "Lecsupaszt" 2 {Eltßvoltja a megjegyz‰seket vagy a vßltozatokat ebbl a jßtszmßbl.}
menuText H EditStripComments "Megjegyz‰sek" 0 \
  {Eltßvoltja az ÷sszes megjegyz‰st ‰s elemz‰st ebbl a jßtszmßbl.}
menuText H EditStripVars "Vßltozatok" 0 {Eltßvoltja az ÷sszes vßltozatot ebbl a jßtszmßbl.}
menuText H EditReset "Ki’rti a Vßgasztalt" 2 \
  {Alaphelyzetbe hozza a Vßgasztalt, hogy az teljesen ’res legyen.}
menuText H EditCopy "A Vßgasztalra mßsolja ezt a jßtszmßt." 15 \
  {Ezt a jßtszmßt ßtmßsolja a Vßgasztal adatbßzisba.}
menuText H EditPaste "Beilleszti az utols jßtszmßt a Vßgasztalrl." 0 \
  {A Vßgasztal aktv jßtszmßjßt beilleszti ide.}
menuText H EditSetup "Kezdßllßs felßlltßsa..." 14 \
  {Felßlltja a kezdßllßst ehhez a jßtszmßhoz.}
menuText H EditCopyBoard "Âllßs mßsolßsa FEN-k‰nt" 17 \
  {Az aktußlis ßllßst FEN-jel÷l‰ssel a vßglapra mßsolja.}
menuText H EditPasteBoard "Kezdßllßs beilleszt‰se" 13 \
  {Felßlltja a kezdßllßst kijel÷lt sz÷veg (vßglap) alapjßn.}

# Game menu:
menuText H Game "Jßtszma" 0
menuText H GameNew "õj jßtszma" 0 \
  {õj jßtszmßt kezd; a vßltoztatßsokat elveti.}
menuText H GameFirst "Bet÷lti az els jßtszmßt." 11 {Bet÷lti az els sz“rt jßtszmßt.}
menuText H GamePrev "Bet÷lti az elz jßtszmßt." 12 {Bet÷lti az elz sz“rt jßtszmßt.}
menuText H GameReload "Ism‰t bet÷lti az aktußlis jßtszmßt." 0 \
  {õjra bet÷lti ezt a jßtszmßt; elvet minden vßltoztatßst.}
menuText H GameNext "Bet÷lti a k÷vetkez jßtszmßt." 10 {Bet÷lti a k÷vetkez sz“rt jßtszmßt.}
menuText H GameLast "Bet÷lti az utols jßtszmßt." 11 {Bet÷lti az utols sz“rt jßtszmßt.}
menuText H GameRandom "V‰letlenszer“en bet÷lt egy jßtszmßt." 0 {V‰letlenszer“en bet÷lt egy sz“rt jßtszmßt.}
menuText H GameNumber "Megadott sorszßm” jßtszma bet÷lt‰se..." 9 \
  {Bet÷lti a sorszßmmal megadott jßtszmßt.}
menuText H GameReplace "Ment‰s cser‰vel..." 7 \
  {Elmenti ezt a jßtszmßt; fel’lrja a r‰gi vßltozatot.}
menuText H GameAdd "Ment‰s ”j jßtszmak‰nt..." 0 \
  {Elmenti ezt a jßtszmßt; ”j jßtszmßt hoz l‰tre az adatbßzisban.}
menuText H GameDeepest "Megnyitßs azonostßsa" 10 \
  {Az ECO-k÷nyvben szerepl legnagyobb m‰lys‰gig megy bele a jßtszmßba.}
menuText H GameGotoMove "Ugrßs megadott sorszßm” l‰p‰shez..." 1 \
  {Megadott sorszßm” l‰p‰shez ugrik az aktußlis jßtszmßban.}
menuText H GameNovelty "õjtßs keres‰se..." 2 \
  {Megkeresi ebben a jßtszmßban az els olyan l‰p‰st, amely korßbban nem fordult el.}

# Search Menu:
menuText H Search "Keres‰s" 0
menuText H SearchReset "Sz“r t÷rl‰se" 6 {Alaphelyzetbe hozza a sz“rt, hogy az ÷sszes jßtszma benne legyen.}
menuText H SearchNegate "Sz“r negßlßsa" 6 {Negßlja a sz“rt, hogy csak a kizßrt jßtszmßk legyenek benne.}
menuText H SearchCurrent "Aktußlis ßllßs..." 0 {A tßblßn l‰v ßllßst keresi.}
menuText H SearchHeader "Fejl‰c..." 0 {Keres‰s fejl‰c (jßt‰kos, esem‰ny, stb.) alapjßn}
menuText H SearchMaterial "Anyag/motvum..." 6 {Keres‰s anyag vagy ßllßsszerkezet alapjßn}
menuText H SearchUsing "Keresfßjl hasznßlata..." 0 {Keres‰s SearchOptions fßjl hasznßlatßval}

# Windows menu:
menuText H Windows "Ablakok" 0
menuText H WindowsComment "Megjegyz‰sszerkeszt" 0 {Megnyitja/bezßrja a megjegyz‰sszerkesztt.}
menuText H WindowsGList "Jßtszmßk listßja" 9 {Kinyitja/becsukja a jßtszmßk listßjßt mutat ablakot.}
menuText H WindowsPGN "PGN-ablak" 0 \
  {Kinyitja/becsukja a PGN-(jßtszmajegyz‰s)-ablakot.}
menuText H WindowsPList "Jßt‰koskeres" 0 {Kinyitja/becsukja a jßt‰koskerest.}
menuText H WindowsTmt "Versenykeres" 0 {Kinyitja/becsukja a versenykerest.}
menuText H WindowsSwitcher "Adatbßzisvßlt" 0 \
  {Kinyitja/becsukja az adatbßzisvßlt ablakot.}
menuText H WindowsMaint "Adatbßzisgondoz ablak" 9 \
  {Kinyitja/becsukja az adatbßzisgondoz ablakot.}
menuText H WindowsECO "ECO-b÷ng‰sz" 0 {Kinyitja/becsukja az ECO-b÷ng‰sz ablakot.}
menuText H WindowsRepertoire "Repertoßrszerkeszt" 0 \
  {Megnyitja/bezßrja a megnyitßsi repertoßrszerkesztt.}
menuText H WindowsStats "Statisztika" 0 \
  {Kinyitja/becsukja a sz“r‰si statisztika ablakßt.}
menuText H WindowsTree "Fastrukt”ra-ablak" 0 {Kinyitja/becsukja a fastrukt”ra-ablakot.}
menuText H WindowsTB "V‰gjßt‰ktßblßzatok ablaka" 8 \
  {Kinyitja/becsukja a v‰gjßt‰ktßblßzatok ablakßt.}

# Tools menu:
menuText H Tools "Eszk÷z÷k" 0
menuText H ToolsAnalysis "Elemz motor..." 0 \
  {Elindt/leßllt egy sakkelemz programot.}
menuText H ToolsAnalysis2 "2. elemz motor..." 0 \
  {Elindtja/leßlltja a 2. sakkelemz programot.}
menuText H ToolsCross "Versenytßblßzat" 0 {Megmutatja az ehhez a jßtszmßhoz tartoz verseny tßblßzatßt.}
menuText H ToolsEmail "Levelez‰si sakk" 0 \
  {Kinyitja/becsukja az elektronikus sakklevelez‰s lebonyoltßsßra szolgßl ablakot.}
menuText H ToolsFilterGraph "Sz“rgrafikon" 5 \
  {Kinyitja/becsukja a sz“rgrafikont mutat ablakot.}
menuText H ToolsOpReport "Ùsszefoglal a megnyitßsrl" 0 \
  {Ismertett k‰szt az aktußlis ßllßshoz tartoz megnyitßsrl.}
menuText H ToolsTracker "Figurak÷vet"  0 {Kinyitja/becsukja a figurak÷vet ablakot.}
menuText H ToolsPInfo "Jßt‰kosinformßci"  0 \
  {Kinyitja/frissti a jßt‰kos adatait tartalmaz ablakot.}
menuText H ToolsRating "Ğrt‰kszßm alakulßsa" 0\
  {Grafikusan ßbrßzolja, hogyan alakult az aktußlis jßtszma r‰sztvevinek ‰rt‰kszßma.}
menuText H ToolsScore "Eredm‰ny alakulßsa" 1 {Megmutatja az eredm‰nygrafikont.}
menuText H ToolsExpCurrent "Az aktußlis jßtszma exportßlßsa" 21 \
  {Sz÷vegfßjlba rja az aktußlis jßtszmßt.}
menuText H ToolsExpCurrentPGN "Exportßlßs PGN-fßjlba..." 11 \
  {PGN-fßjlba rja az aktußlis jßtszmßt.}
menuText H ToolsExpCurrentHTML "Exportßlßs HTML-fßjlba..." 11 \
  {HTML-fßjlba rja az aktußlis jßtszmßt.}
menuText H ToolsExpCurrentLaTeX "Exportßlßs LaTeX-fßjlba..." 11 \
  {LaTeX-fßjlba rja az aktußlis jßtszmßt.}
menuText H ToolsExpFilter "Az ÷sszes sz“rt jßtszma exportßlßsa" 10 \
  {Sz÷vegfßjlba rja az ÷sszes sz“rt jßtszmßt.}
menuText H ToolsExpFilterPGN "Sz“r exportßlßsa PGN-fßjlba..." 18 \
  {PGN-fßjlba rja az ÷sszes sz“rt jßtszmßt.}
menuText H ToolsExpFilterHTML "Sz“r exportßlßsa HTML-fßjlba..." 18 \
  {HTML-fßjlba rja az ÷sszes sz“rt jßtszmßt.}
menuText H ToolsExpFilterLaTeX "Sz“r exportßlßsa LaTeX-fßjlba..." 18 \
  {LaTeX-fßjlba rja az ÷sszes sz“rt jßtszmßt.}
menuText H ToolsImportOne "PGN-jßtszma importßlßsa..." 0 \
  {PGN-formßtum” jßtszma importßlßsa}
menuText H ToolsImportFile "PGN-fßjl importßlßsa..." 2 \
  {PGN-fßjl ÷sszes jßtszmßjßnak importßlßsa}

# Options menu:
menuText H Options "Beßlltßsok" 0
menuText H OptionsSize "Tßblam‰ret" 0 {A tßbla m‰ret‰nek vßltoztatßsa}
menuText H OptionsPieces "Figurßk stlusa" 0 {A figurßk megjelen‰si formßjßnak vßltoztatßsa}
menuText H OptionsColors "Sznek..." 0 {A tßbla szneinek vßltoztatßsa}
menuText H OptionsExport "Exportßlßs" 1 {Exportßlßsi beßlltßsok vßltoztatßsa}
menuText H OptionsFonts "Karakterk‰szlet" 0 {Karakterk‰szlet vßltoztatßsa}
menuText H OptionsFontsRegular "Szokßsos" 0 {A szokßsos karakterk‰szlet vßltoztatßsa}
menuText H OptionsFontsMenu "Men’" 0 {A men’k karakterk‰szlet‰nek a vßltoztatßsa}
menuText H OptionsFontsSmall "Kisbet“s" 0 {A kisbet“s karakterk‰szlet vßltoztatßsa}
menuText H OptionsFontsFixed "R÷gztett" 0 {A r÷gztett sz‰less‰g“ karakterk‰szlet vßltoztatßsa}
menuText H OptionsGInfo "Jßtszmainformßci" 0 {Jßtszmainformßci vßltoztatßsa}
menuText H OptionsLanguage "Nyelv" 0 {A men’ nyelv‰nek kivßlasztßsa}
menuText H OptionsMoves "L‰p‰sek" 0 {L‰p‰sek bevitel‰nek beßlltßsai}
menuText H OptionsMovesAsk "L‰p‰s cser‰je eltt rßk‰rdez." 6 \
  {Mieltt ßtrna egy meglev l‰p‰st, rßk‰rdez.}
menuText H OptionsMovesDelay "Automatikus visszajßtszßs k‰sleltet‰se..." 0 \
  {Beßlltja a k‰sleltet‰st automatikus visszajßtszßshoz.}
menuText H OptionsMovesCoord "L‰p‰s megadßsa koordinßtßkkal" 15 \
  {Koordinßtßkkal megadott l‰p‰st ("g1f3") is elfogad.}
menuText H OptionsMovesSuggest "Javaslat" 0 \
  {Be/kikapcsolja a l‰p‰sjavaslatot.}
menuText H OptionsMovesKey "Billenty“-kieg‰szt‰s" 0 \
  {Be/kikapcsolja a billenty“zettel r‰szlegesen bevitt l‰p‰sek automatikus kieg‰szt‰s‰t.}
menuText H OptionsNumbers "Szßmformßtum" 1 {Szßmformßtum kivßlasztßsa}
menuText H OptionsStartup "Indtßs" 0 {Az indtßskor kinyitand ablakok kivßlasztßsa}
menuText H OptionsWindows "Ablakok" 0 {Ablakbeßlltßsok}
menuText H OptionsWindowsIconify "Automatikus ikonizßlßs" 12 \
  {A f ablak ikonizßlßsakor az ÷sszes t÷bbit is ikonizßlja.}
menuText H OptionsWindowsRaise "Automatikus elhozßs" 12 \
  {Elhoz bizonyos ablakokat (pl. elrehaladßs-sßvokat), amikor el vannak takarva.}
menuText H OptionsToolbar "Eszk÷ztßr" 0 {A f ablak eszk÷ztßrßnak ÷sszeßlltßsa}
menuText H OptionsECO "ECO-fßjl bet÷lt‰se..." 2 {Bet÷lti az ECO-osztßlyoz fßjlt.}
menuText H OptionsSpell "Helyesrßs-ellenrz fßjl bet÷lt‰se..." 0 \
  {Bet÷lti a helyesrßs-ellenrz fßjlt.}
menuText H OptionsTable "V‰gjßt‰ktßblßzatok k÷nyvtßra..." 0 \
  {V‰gjßt‰ktßblßzat-fßjl kivßlasztßsa; a k÷nyvtßrban lev ÷sszes v‰gjßt‰ktßblßzatot hasznßlatba veszi.}
menuText H OptionsRecent "Aktußlis fßjlok..." 3 \
  {A Fßjl-men’ben megjelentett aktußlis fßjlok szßmßnak megvßltoztatßsa}
menuText H OptionsSave "Beßlltßsok ment‰se" 12 \
  "Minden beßllthat ‰rt‰ket elment a $::optionsFile fßjlba."
menuText H OptionsAutoSave "Beßlltßsok automatikus ment‰se kil‰p‰skor." 0 \
  {Automatikusan elment minden beßlltßst, amikor kil‰psz SCID-bl.}

# Help menu:
menuText H Help "Segts‰g" 0
menuText H HelpIndex "Tartalom" 0 {Megjelenti a tartalomjegyz‰ket.}
menuText H HelpGuide "R÷vid ismertet" 0 {R÷vid ismertett ny”jt a program hasznßlatßrl.}
menuText H HelpHints "K‰rd‰s-felelet" 0 {N‰hßny hasznos tanßcs}
menuText H HelpContact "Cmek" 0 {Fontosabb internetcmek}
menuText H HelpTip "A nap tippje" 2 {Hasznos tipp SCID hasznßlatßhoz}
menuText H HelpStartup "Indul ablak" 0 {A program indtßsakor megjelen ablak}
menuText H HelpAbout "SCID-rl" 0 {Tßj‰koztatßs SCID-rl}

# Game info box popup menu:
menuText H GInfoHideNext "Elrejti a k÷vetkez l‰p‰st." 2
menuText H GInfoMaterial "Mutatja az anyagi helyzetet" 11
menuText H GInfoFEN "FEN-formßtum megmutatßsa" 0
menuText H GInfoMarks "Mutatja a sznes mezket ‰s nyilakat." 10
menuText H GInfoWrap "Hossz” sorok t÷rdel‰se" 0
menuText H GInfoFullComment "A teljes kommentßrt megmutatja." 9
menuText H GInfoPhotos "Show Photos" 5 ;# ***
menuText H GInfoTBNothing "V‰gjßt‰ktßblßzatok: nincs informßci" 20
menuText H GInfoTBResult "V‰gjßt‰ktßblßzatok: csak eredm‰ny" 25
menuText H GInfoTBAll "V‰gjßt‰ktßblßzatok: eredm‰ny ‰s a legjobb l‰p‰sek" 42
menuText H GInfoDelete "T÷rli/helyreßlltja ezt a jßtszmßt." 0
menuText H GInfoMark "Megjel÷li ezt a jßtszmßt/megsz’nteti a jel÷l‰st." 0

# Main window buttons:
helpMsg H .button.start {Ugrßs a jßtszma elej‰re  (billenty“: Home)}
helpMsg H .button.end {Ugrßs a jßtszma v‰g‰re  (billenty“: End)}
helpMsg H .button.back {Vissza egy l‰p‰ssel  (billenty“: balra mutat nyl)}
helpMsg H .button.forward {Elre egy l‰p‰ssel  (billenty“: jobbra mutat nyl)}
helpMsg H .button.intoVar {Bel‰p egy vßltozatba  (gyorsbillenty“: v).}
helpMsg H .button.exitVar {Kil‰p az aktußlis vßltozatbl  (gyorsbillenty“: z).}
helpMsg H .button.flip {Tßbla elforgatßsa  (gyorsbillenty“: .)}
helpMsg H .button.coords {Koordinßtßk be- vagy kikapcsolßsa  (gyorsbillenty“: 0)}
helpMsg H .button.autoplay {Automatikus visszajßtszßs  (billenty“: Ctrl+Z)}

# General buttons:
translate H Back {Vissza}
translate H Cancel {M‰gse}
translate H Clear {Ki’rt}
translate H Close {Bezßr}
translate H Defaults {Alap‰rt‰kek}
translate H Delete {T÷r÷l}
translate H Graph {Grafikon}
translate H Help {Segts‰g}
translate H Import {Import}
translate H Index {Tartalom}
translate H LoadGame {Jßtszma bet÷lt‰se}
translate H BrowseGame {Jßtszma n‰zeget‰se}
translate H MergeGame {Jßtszma beolvasztßsa}
translate H Preview {Eln‰zet}
translate H Revert {Visszat‰r}
translate H Save {Ment}
translate H Search {Keres}
translate H Stop {Âllj}
translate H Store {Tßrol}
translate H Update {Frisst}
translate H ChangeOrient {Ablak elhelyezked‰s‰nek vßltoztatßsa}
translate H None {Egyik sem}
translate H First {Els}
translate H Current {Aktußlis}
translate H Last {Utols}

# General messages:
translate H game {jßtszma}
translate H games {jßtszma}
translate H move {l‰p‰s}
translate H moves {l‰p‰s}
translate H all {mind}
translate H Yes {Igen}
translate H No {Nem}
translate H Both {Mindkett}
translate H King {Kirßly}
translate H Queen {Vez‰r}
translate H Rook {Bßstya}
translate H Bishop {Fut}
translate H Knight {Huszßr}
translate H Pawn {Gyalog}
translate H White {Vilßgos}
translate H Black {S÷t‰t}
translate H Player {Jßt‰kos}
translate H Rating {Ğrt‰kszßm}
translate H RatingDiff {Ğrt‰kszßmk’l÷nbs‰g (Vilßgos - S÷t‰t)}
translate H AverageRating {Âtlagos ‰rt‰kszßm}
translate H Event {Esem‰ny}
translate H Site {Helyszn}
translate H Country {Orszßg}
translate H IgnoreColors {A szn k÷z÷mb÷s.}
translate H Date {Dßtum}
translate H EventDate {Az esem‰ny dßtuma}
translate H Decade {Ğvtized}
translate H Year {Ğv}
translate H Month {Hnap}
translate H Months {janußr februßr mßrcius ßprilis mßjus j”nius
  j”lius augusztus szeptember oktber november december}
translate H Days {vasßrnap h‰tf kedd szerda cs’t÷rt÷k p‰ntek szombat}
translate H YearToToday {Az utols egy ‰vben}
translate H Result {Eredm‰ny}
translate H Round {Fordul}
translate H Length {Hossz}
translate H ECOCode {ECO-kd}
translate H ECO {ECO}
translate H Deleted {t÷r÷lt}
translate H SearchResults {A keres‰s eredm‰nye}
translate H OpeningTheDatabase {Adatbßzis megnyitßsa}
translate H Database {Adatbßzis}
translate H Filter {Sz“r}
translate H noGames {nincs jßtszma}
translate H allGames {az ÷sszes jßtszma}
translate H empty {’res}
translate H clipbase {vßgasztal}
translate H score {pontszßm}
translate H StartPos {Kezdßllßs}
translate H Total {Ùsszesen}

# Standard error messages:
translate H ErrNotOpen {Ez az adatbßzis nincs megnyitva.}
translate H ErrReadOnly {Ez az adatbßzis csak olvashat; nem lehet megvßltoztatni.}
translate H ErrSearchInterrupted {Keres‰s megszaktva; az eredm‰nyek hißnyosak.}

# Game information:
translate H twin {iker}
translate H deleted {t÷r÷lt}
translate H comment {megjegyz‰s}
translate H hidden {rejtett}
translate H LastMove {Utols l‰p‰s}
translate H NextMove {K÷vetkez}
translate H GameStart {Jßtszma eleje}
translate H LineStart {Elßgazßs eleje}
translate H GameEnd {Jßtszma v‰ge}
translate H LineEnd {Elßgazßs v‰ge}

# Player information:
translate H PInfoAll {Eredm‰nyek az <b>÷sszes</b> jßtszma alapjßn}
translate H PInfoFilter {Eredm‰nyek a <b>sz“rt</b> jßtszmßk alapjßn}
translate H PInfoAgainst {Eredm‰nyek, ha az ellenf‰l}
translate H PInfoMostWhite {Leggyakoribb megnyitßsok vilßgosk‰nt}
translate H PInfoMostBlack {Leggyakoribb megnyitßsok s÷t‰tk‰nt}
translate H PInfoRating {Ğrt‰kszßm alakulßsa}
translate H PInfoBio {Ğletrajz}

# Tablebase information:
translate H Draw {D÷ntetlen}
translate H stalemate {patt}
translate H withAllMoves {az ÷sszes l‰p‰ssel}
translate H withAllButOneMove {egy hjßn az ÷sszes l‰p‰ssel}
translate H with {with}
translate H only {csak}
translate H lose {vesztenek}
translate H loses {veszt}
translate H allOthersLose {minden mßs veszt}
translate H matesIn {mates in}
translate H hasCheckmated {mattot adott}
translate H longest {leghosszabb}
translate H WinningMoves {Nyer l‰p‰s}
translate H DrawingMoves {D÷ntetlenre vezet l‰p‰s}
translate H LosingMoves {Veszt l‰p‰s}
translate H UnknownMoves {Bizonytalan kimenetel“ l‰p‰s}

# Tip of the day:
translate H Tip {Tipp}
translate H TipAtStartup {Tipp indulßskor}

# Tree window menus:
menuText H TreeFile "Fßjl" 0
menuText H TreeFileSave "Cache-fßjl ment‰se" 11 {Elmenti a fastrukt”ra-cache-fßjlt (.stc)}
menuText H TreeFileFill "Cache-fßjl felt÷lt‰se" 14 \
  {Felt÷lti a cache-fßjlt gyakori megnyitßsokkal.}
menuText H TreeFileBest "Legjobb jßtszmßk listßja" 3 {Megmutatja a legjobb jßtszmßkat a fßrl.}
menuText H TreeFileGraph "Grafikon" 0 {Megmutatja ennek a faßgnak a grafikonjßt.}
menuText H TreeFileCopy "Sz÷veg mßsolßsa a vßglapra" 0 \
  {A kirt statisztikai adatokat a vßglapra mßsolja.}
menuText H TreeFileClose "Faablak bezßrßsa" 10 {Bezßrja a fastrukt”ra-ablakot.}
menuText H TreeSort "Rendez‰s" 0
menuText H TreeSortAlpha "ABC" 0
menuText H TreeSortECO "ECO-kd" 0
menuText H TreeSortFreq "Gyakorisßg" 0
menuText H TreeSortScore "Pontszßm" 0
menuText H TreeOpt "Beßlltßsok" 0
menuText H TreeOptLock "R÷gzt‰s" 0 {A fßt az aktußlis adatbßzishoz k÷ti ill. a k÷t‰st feloldja.}
menuText H TreeOptTraining "Edz‰s" 0 {Edz‰s’zemmd be- vagy kikapcsolßsa}
menuText H TreeOptAutosave "Cache-fßjl automatikus ment‰se" 11 \
  {A faablak bezßrßsakor automatikusan elmenti a cache-fßjlt.}
menuText H TreeHelp "Segts‰g" 0
menuText H TreeHelpTree "Segts‰g a fßhoz" 0
menuText H TreeHelpIndex "Tartalom" 0
translate H SaveCache {Cache ment‰se}
translate H Training {Edz‰s}
translate H LockTree {R÷gzt‰s}
translate H TreeLocked {r÷gztve}
translate H TreeBest {Legjobb}
translate H TreeBestGames {Legjobb jßtszmßk a fßrl}
translate H TreeTitleRow \
  {    L‰p‰s  ECO       Gyakorisßg  Eredm. ÂtlĞl Telj. Âtl.‰v}

# Finder window:
menuText H FinderFile "Fßjl" 0
menuText H FinderFileSubdirs "Keres‰s az alk÷nyvtßrakban" 0
menuText H FinderFileClose "A fßjlkeres bezßrßsa" 15
menuText H FinderSort "Rendez‰s" 0
menuText H FinderSortType "Tpus" 0
menuText H FinderSortSize "M‰ret" 0
menuText H FinderSortMod "Id" 0
menuText H FinderSortName "N‰v" 0
menuText H FinderSortPath "õtvonal" 0
menuText H FinderTypes "Tpusok" 0
menuText H FinderTypesScid "SCID-adatbßzisok" 0
menuText H FinderTypesOld "R‰gi formßtum” SCID-adatbßzisok" 0
menuText H FinderTypesPGN "PGN-fßjlok" 0
menuText H FinderTypesEPD "EPD-fßjlok" 0
menuText H FinderTypesRep "Repertoßrfßjlok" 0
menuText H FinderHelp "Segts‰g" 0
menuText H FinderHelpFinder "Segts‰g a fßjlkeresh÷z" 0
menuText H FinderHelpIndex "Tartalom" 0
translate H FileFinder {Fßjlkeres}
translate H FinderDir {K÷nyvtßr}
translate H FinderDirs {K÷nyvtßrak}
translate H FinderFiles {Fßjlok}
translate H FinderUpDir {fel}

# Player finder:
menuText H PListFile "Fßjl" 0
menuText H PListFileUpdate "Frisst" 0
menuText H PListFileClose "Jßt‰koskeres bezßrßsa" 16
menuText H PListSort "Rendez‰s" 0
menuText H PListSortName "N‰v" 0
menuText H PListSortElo "Ğl" 0
menuText H PListSortGames "Jßtszmßk" 0
menuText H PListSortOldest "Legr‰gibb" 0
menuText H PListSortNewest "Leg”jabb" 3

# Tournament finder:
menuText H TmtFile "Fßjl" 0
menuText H TmtFileUpdate "Frisst" 0
menuText H TmtFileClose "A versenykeres bezßrßsa" 18
menuText H TmtSort "Rendez‰s" 0
menuText H TmtSortDate "Dßtum" 0
menuText H TmtSortPlayers "Jßt‰kosok" 0
menuText H TmtSortGames "Jßtszmßk" 1
menuText H TmtSortElo "Ğl" 0
menuText H TmtSortSite "Helyszn" 0
menuText H TmtSortEvent "Esem‰ny" 1
menuText H TmtSortWinner "Gyztes" 0
translate H TmtLimit "Lista hossza"
translate H TmtMeanElo "Legkisebb ßtlagos Ğl"
translate H TmtNone "Nem talßltam hozzß versenyt."

# Graph windows:
menuText H GraphFile "Fßjl" 0
menuText H GraphFileColor "Ment‰s Color PostScript-k‰nt..." 7
menuText H GraphFileGrey "Ment‰s Greyscale PostScript-k‰nt..." 7
menuText H GraphFileClose "Ablak bezßrßsa" 8
menuText H GraphOptions "Beßlltßsok" 0
menuText H GraphOptionsWhite "Vilßgos" 0
menuText H GraphOptionsBlack "S÷t‰t" 0
menuText H GraphOptionsBoth "Mindkett" 1
menuText H GraphOptionsPInfo "A jßt‰kosinformßci jßt‰kosa" 0
translate H GraphFilterTitle "Sz“rgrafikon: gyakorisßg 1000 jßtszmßnk‰nt"

# Analysis window:
translate H AddVariation {Vßltozat besz”rßsa}
translate H AddMove {L‰p‰s besz”rßsa}
translate H Annotate {Jegyzetekkel lßt el}
translate H AnalysisCommand {Elemz‰sparancs}
translate H PreviousChoices {Korßbbi vßlasztßsok}
translate H AnnotateTime {K‰t l‰p‰s k÷z÷tti id mßsodpercben}
translate H AnnotateWhich {Vßltozatok hozzßadßsa}
translate H AnnotateAll {Mindk‰t f‰l l‰p‰seihez}
translate H AnnotateWhite {Csak vilßgos l‰p‰seihez}
translate H AnnotateBlack {Csak s÷t‰t l‰p‰seihez}
translate H AnnotateNotBest {Ha a jßtszmßban nem a legjobbat l‰pt‰k}

# Analysis Engine open dialog:
translate H EngineList {Elemz motorok listßja}
translate H EngineName {N‰v}
translate H EngineCmd {Parancs}
translate H EngineArgs {Param‰terek}
translate H EngineDir {K÷nyvtßr}
translate H EngineElo {Ğl}
translate H EngineTime {Dßtum}
translate H EngineNew {õj}
translate H EngineEdit {Szerkeszt‰s}
translate H EngineRequired {A vastagbet“s mezk sz’ks‰gesek, a t÷bbiek kihagyhatk.}

# Stats window menus:
menuText H StatsFile "Fßjl" 0
menuText H StatsFilePrint "Nyomtatßs fßjlba..." 0
menuText H StatsFileClose "Ablak bezßrßsa" 0
menuText H StatsOpt "Beßlltßsok" 0

# PGN window menus:
menuText H PgnFile "Fßjl" 0
menuText H PgnFilePrint "Nyomtatßs fßjlba..." 0
menuText H PgnFileClose "PGN-ablak bezßrßsa" 0
menuText H PgnOpt "Megjelent‰s" 0
menuText H PgnOptColor "Sznes sz÷veg" 0
menuText H PgnOptShort "R÷vid (3-soros) fejl‰c" 0
menuText H PgnOptSymbols "Szimblumok hasznßlata" 1
menuText H PgnOptIndentC "Megjegyz‰sek beh”zßsa" 0
menuText H PgnOptIndentV "Vßltozatok beh”zßsa" 0
menuText H PgnOptColumn "Oszlopok stlusa (soronk‰nt egy l‰p‰s)" 0
menuText H PgnOptSpace "Szk÷z a l‰p‰s sorszßma utßn" 3
menuText H PgnOptStripMarks "Sznes mezk ‰s nyilak kifejt‰se" 2
menuText H PgnColor "Sznek" 0
menuText H PgnColorHeader "Fejl‰c..." 0
menuText H PgnColorAnno "Jegyzetek..." 0
menuText H PgnColorComments "Megjegyz‰sek..." 0
menuText H PgnColorVars "Vßltozatok..." 0
menuText H PgnColorBackground "Hßtt‰r..." 0
menuText H PgnHelp "Segts‰g" 0
menuText H PgnHelpPgn "Segts‰g PGN-hez" 9
menuText H PgnHelpIndex "Tartalom" 0

# Crosstable window menus:
menuText H CrosstabFile "Fßjl" 0
menuText H CrosstabFileText "Nyomtatßs sz÷vegfßjlba..." 10
menuText H CrosstabFileHtml "Nyomtatßs HTML-fßjlba..." 10
menuText H CrosstabFileLaTeX "Nyomtatßs LaTeX-fßjlba..." 10
menuText H CrosstabFileClose "Ablak bezßrßsa" 0
menuText H CrosstabEdit "Szerkeszt‰s" 0
menuText H CrosstabEditEvent "Esem‰ny" 0
menuText H CrosstabEditSite "Helyszn" 0
menuText H CrosstabEditDate "Dßtum" 0
menuText H CrosstabOpt "Megjelent‰s" 0
menuText H CrosstabOptAll "K÷rm‰rkz‰s" 0
menuText H CrosstabOptSwiss "Svßjci" 0
menuText H CrosstabOptKnockout "Kies‰ses" 1
menuText H CrosstabOptAuto "Ø maga j÷n rß." 0
menuText H CrosstabOptAges "Ğletkor ‰vben" 0
menuText H CrosstabOptNats "Nemzetis‰g" 0
menuText H CrosstabOptRatings "Ğrt‰kszßmok" 1
menuText H CrosstabOptTitles "Cmek" 0
menuText H CrosstabOptBreaks "Pontszßm holtverseny eld÷nt‰s‰hez" 0
menuText H CrosstabOptDeleted "T÷r÷lt jßtszmßkkal egy’tt" 0
menuText H CrosstabOptColors "Sznek (csak svßjci rendszer eset‰n)" 2
menuText H CrosstabOptColumnNumbers "Szßmozott oszlopok (csak k÷rm‰rkz‰shez)" 2
menuText H CrosstabOptGroup "Pontcsoportok" 1
menuText H CrosstabSort "Rendez" 0
menuText H CrosstabSortName "N‰v" 0
menuText H CrosstabSortRating "Ğrt‰kszßm" 0
menuText H CrosstabSortScore "Pontszßm" 0
menuText H CrosstabColor "Szn" 0
menuText H CrosstabColorPlain "K÷z÷ns‰ges sz÷veg" 0
menuText H CrosstabColorHyper "Hypertext" 0
menuText H CrosstabHelp "Segts‰g" 0
menuText H CrosstabHelpCross "Segts‰g kereszttßblßzathoz" 0
menuText H CrosstabHelpIndex "Tartalom" 0
translate H SetFilter {Sz“r beßlltßsa}
translate H AddToFilter {Hozzßadja a sz“rh÷z}
translate H Swiss {Svßjci}
translate H Category {Kategria}

# Opening report window menus:
menuText H OprepFile "Fßjl" 0
menuText H OprepFileText "Nyomtatßs sz÷vegfßjlba..." 10
menuText H OprepFileHtml "Nyomtatßs HTML-fßjlba..." 10
menuText H OprepFileLaTeX "Nyomtatßs LaTeX-fßjlba..." 10
menuText H OprepFileOptions "Beßlltßsok..." 0
menuText H OprepFileClose "Ablak bezßrßsa" 0
menuText H OprepHelp "Segts‰g" 0
menuText H OprepHelpReport "Segts‰g a megnyitßsi ÷sszefoglalhoz" 0
menuText H OprepHelpIndex "Tartalom" 0

# Repertoire editor:
menuText H RepFile "Fßjl" 0
menuText H RepFileNew "õj" 0
menuText H RepFileOpen "Megnyitßs..." 3
menuText H RepFileSave "Ment‰s..." 0
menuText H RepFileSaveAs "Ment‰s mßsk‰nt..." 5
menuText H RepFileClose "Ablak bezßrßsa" 0
menuText H RepEdit "Szerkeszt‰s" 0
menuText H RepEditGroup "Csoport hozzßadßsa" 0
menuText H RepEditInclude "Beleveend elßgazßs" 0
menuText H RepEditExclude "Kizßrand elßgazßs" 0
menuText H RepView "N‰zet" 0
menuText H RepViewExpand "Az ÷sszes csoportot kibontja" 20
menuText H RepViewCollapse "Az ÷sszes csoportot ÷sszeh”zza" 20
menuText H RepSearch "Keres‰s" 0
menuText H RepSearchAll "Az eg‰sz repertoßrban..." 3
menuText H RepSearchDisplayed "Csak a megjelentett elßgazßsokban..." 0
#Ez igen gyan”s!
menuText H RepHelp "Segts‰g" 0
menuText H RepHelpRep "Segts‰g a repertoßrhoz" 0
menuText H RepHelpIndex "Tartalom" 0
translate H RepSearch "Keres‰s a repertoßrban"
translate H RepIncludedLines "beleveend elßgazßsok"
translate H RepExcludedLines "kizßrand elßgazßsok"
translate H RepCloseDialog {Ebben a repertoßrban elmentetlen vßltoztatßsok vannak.

T‰nyleg folytatni akarod, ‰s elvetni a l‰trehozott vßltoztatßsokat?
}

# Header search:
translate H HeaderSearch {Keres‰s fejl‰c alapjßn}
translate H GamesWithNoECO {Jßtszmßk ECO n‰lk’l?}
translate H GameLength {Jßtszmahossz}
translate H FindGamesWith {Megjel÷lt jßtszmßk}
translate H StdStart {K’l÷nleges indtßs}
translate H Promotions {Âtvßltozßsok}
translate H Comments {Megjegyz‰sek}
translate H Variations {Vßltozatok}
translate H Annotations {Jegyzetek}
translate H DeleteFlag {Megjel÷l‰s t÷rl‰se}
translate H WhiteOpFlag {Megnyitßs vilßgossal}
translate H BlackOpFlag {Megnyitßs s÷t‰ttel}
translate H MiddlegameFlag {K÷z‰pjßt‰k}
translate H EndgameFlag {V‰gjßt‰k}
translate H NoveltyFlag {õjtßs}
translate H PawnFlag {Gyalogszerkezet}
translate H TacticsFlag {Taktika}
translate H QsideFlag {Vez‰rszßrnyi jßt‰k}
translate H KsideFlag {Kirßlyszßrnyi jßt‰k}
translate H BrilliancyFlag {Csillogßs}
translate H BlunderFlag {Eln‰z‰s}
translate H UserFlag {Felhasznßl}
translate H PgnContains {A PGN-ben sz÷veg van.}

# Game list window:
translate H GlistNumber {Szßm}
translate H GlistWhite {Vilßgos}
translate H GlistBlack {S÷t‰t}
translate H GlistWElo {Vilßgos Ğlje}
translate H GlistBElo {S÷t‰t Ğlje}
translate H GlistEvent {Esem‰ny}
translate H GlistSite {Helyszn}
translate H GlistRound {Fordul}
translate H GlistDate {Dßtum}
translate H GlistYear {Ğv}
translate H GlistEDate {Az esem‰ny dßtuma}
translate H GlistResult {Eredm‰ny}
translate H GlistLength {Hossz}
translate H GlistCountry {Orszßg}
translate H GlistECO {ECO}
translate H GlistOpening {Megnyitßs}
translate H GlistEndMaterial {V‰gs anyagi helyzet}
translate H GlistDeleted {T÷r÷lt}
translate H GlistFlags {Megjel÷l‰sek}
translate H GlistVars {Variations}
translate H GlistComments {Megjegyz‰sek}
translate H GlistAnnos {Jegyzetek}
translate H GlistStart {Kezdet}
translate H GlistGameNumber {A jßtszma sorszßma}
translate H GlistFindText {Sz÷veg keres‰se}
translate H GlistMoveField {L‰p‰s}
translate H GlistEditField {Konfigurßlßs}
translate H GlistAddField {Hozzßad}
translate H GlistDeleteField {Eltßvolt}
translate H GlistWidth {Sz‰less‰g}
translate H GlistAlign {Igazt}
translate H GlistColor {Szn}
translate H GlistSep {Elvßlaszt}

# Maintenance window:
translate H DatabaseName {Az adatbßzis neve:}
translate H TypeIcon {Tpusikon:}
translate H NumOfGames {Jßtszmßk:}
translate H NumDeletedGames {T÷r÷lt jßtszmßk:}
translate H NumFilterGames {Sz“rt jßtszmßk:}
translate H YearRange {Ğvtartomßny:}
translate H RatingRange {Ğrt‰kszßmtartomßny:}
translate H Description {Lerßs}
translate H Flag {Megjel÷l‰s}
translate H DeleteCurrent {T÷rli az aktußlis jßtszmßt.}
translate H DeleteFilter {T÷rli a sz“rt jßtszmßkat.}
translate H DeleteAll {Minden jßtszmßt t÷r÷l.}
translate H UndeleteCurrent {Helyreßlltja az aktußlis jßtszmßt.}
translate H UndeleteFilter {Helyreßlltja a sz“rt jßtszmßkat.}
translate H UndeleteAll {Minden jßtszmßt helyreßllt.}
translate H DeleteTwins {T÷rli az ikerjßtszmßkat.}
translate H MarkCurrent {Kijel÷li az aktußlis jßtszmßt.}
translate H MarkFilter {Kijel÷li a sz“rt jßtszmßkat.}
translate H MarkAll {Minden jßtszmßt kijel÷l.}
translate H UnmarkCurrent {Megsz’nteti az aktußlis jßtszma kijel÷l‰s‰t.}
translate H UnmarkFilter {Megsz’nteti a sz“rt jßtszmßk kijel÷l‰s‰t.}
translate H UnmarkAll {Minden jßtszma kijel÷l‰s‰t megsz’nteti.}
translate H Spellchecking {Helyesrßs-ellenrz‰s}
translate H Players {Jßt‰kosok}
translate H Events {Esem‰nyek}
translate H Sites {Helysznek}
translate H Rounds {Fordulk}
translate H DatabaseOps {Adatbßzism“veletek}
translate H ReclassifyGames {ECO alapjßn osztßlyozza a jßtszmßkat.}
translate H CompactDatabase {Adatbßzis t÷m÷rt‰se}
translate H SortDatabase {Adatbßzis rendez‰se}
translate H AddEloRatings {Ğl-‰rt‰kszßmok hozzßadßsa}
translate H AutoloadGame {Jßtszmasorszßm automatikus bet÷lt‰se}
#Igaz ez?
translate H StripTags {PGN-cmk‰k elt’ntet‰se}
translate H StripTag {Cmke elt’ntet‰se}
translate H Cleaner {Takart}
translate H CleanerHelp {
SCID Takartja el fogja v‰gezni az aktußlis adatbßzison az ÷sszes olyan gondozßsi feladatot, amelyet az alßbbi listßrl kijel÷lsz.

Az ECO-osztßlyozßsra ‰s az ikert÷rl‰sre vonatkoz jelenlegi beßlltßsok akkor jutnak ‰rv‰nyre, ha ezeket a feladatokat is kijel÷l÷d.
}
translate H CleanerConfirm {
Ha a Takart mßr elindult, t÷bb‰ nem lehet megßlltani!

Nagy adatbßzison a kivßlasztott feladatoktl ‰s aktußlis beßlltßsaiktl f’ggen a m“velet sokßig eltarthat.

Biztos, hogy neki akarsz lßtni a kijel÷lt gondozßsi feladatoknak?
}

# Comment editor:
translate H AnnotationSymbols  {Jegyzetszimblumok:}
translate H Comment {Megjegyz‰s:}
translate H InsertMark {Jel÷l‰s besz”rßsa}

# Board search:
translate H BoardSearch {Âllßs keres‰se}
translate H FilterOperation {Elv‰gzend m“velet az aktußlis sz“rn:}
translate H FilterAnd {ĞS (Sz“r sz“kt‰se)}
translate H FilterOr {VAGY (Sz“r bvt‰se)}
translate H FilterIgnore {SEMMI (Sz“r t÷rl‰se)}
translate H SearchType {A keres‰s fajtßja:}
translate H SearchBoardExact {Pontos ßllßs (minden figura azonos mezn)}
translate H SearchBoardPawns {Gyalogok (azonos anyag, minden gyalog azonos mezn)}
translate H SearchBoardFiles {Vonalak (azonos anyag, minden gyalog azonos vonalon)}
translate H SearchBoardAny {Bßrmi (azonos anyag, gyalogok ‰s figurßk bßrhol)}
translate H LookInVars {Vßltozatokban is keres.}

# Material search:
translate H MaterialSearch {Keres‰s anyagra}
translate H Material {Anyag}
translate H Patterns {Alakzatok}
translate H Zero {Nulla}
translate H Any {Bßrmi}
translate H CurrentBoard {Aktußlis ßllßs}
translate H CommonEndings {Gyakori v‰gjßt‰kok}
translate H CommonPatterns {Gyakori alakzatok}
translate H MaterialDiff {Anyagk’l÷nbs‰g}
translate H squares {mezk}
translate H SameColor {Azonos szn}
translate H OppColor {Ellenkez szn}
translate H Either {Bßrmelyik}
translate H MoveNumberRange {L‰p‰startomßny}
translate H MatchForAtLeast {Egyezzen legalßbb}
translate H HalfMoves {f‰l l‰p‰sig.}
#Így kell?
# Game saving:
translate H Today {Ma}
translate H ClassifyGame {Jßtszma osztßlyozßsa}

# Setup position:
translate H EmptyBoard {Tßbla letakartßsa}
translate H InitialBoard {Alapßllßs}
translate H SideToMove {Ki l‰p?}
translate H MoveNumber {L‰p‰s szßma}
translate H Castling {Sßncolßs}
translate H EnPassantFile {"En passant" fßjl}
translate H ClearFen {FEN t÷rl‰se}
translate H PasteFen {FEN beilleszt‰se}

# Replace move dialog:
translate H ReplaceMove {L‰p‰s cser‰je}
translate H AddNewVar {õj vßltozat besz”rßsa}
translate H ReplaceMoveMessage {Itt mßr van l‰p‰s.

Kicser‰lheted, mißltal az ÷sszes t k÷vet l‰p‰s elv‰sz, vagy l‰p‰sedet besz”rhatod ”j vßltozatk‰nt.

(Ha a j÷vben nem akarod lßtni ezt az ’zenetet, kapcsold ki a Beßlltßsok:L‰p‰sek men’ben a "L‰p‰s cser‰je eltt rßk‰rdez." beßlltßst.)}

# Make database read-only dialog:
translate H ReadOnlyDialog {Ha ezt az adatbßzist kizßrlag olvashatvß teszed, nem lehet vßltoztatßsokat v‰gezni rajta. Nem lehet jßtszmßkat elmenteni vagy kicser‰lni, sem a t÷rl‰skijel÷l‰seket megvßltoztatni. Minden rendez‰s vagy ECO-osztßlyozßs csak ßtmeneti lesz.

K÷nnyen ”jra rhatvß teheted az adatbßzist, ha bezßrod, majd ”jbl megnyitod.

T‰nyleg kizßrlag olvashatvß akarod tenni ezt az adatbßzist?}

# Clear game dialog:
translate H ClearGameDialog {Ez a jßtszma megvßltozott.

T‰nyleg folytatni akarod, ‰s elvetni a l‰trehozott vßltoztatßsokat?
}

# Exit dialog:
translate H ExitDialog {T‰nyleg ki akarsz l‰pni SCID-bl?}
translate H ExitUnsaved {A k÷vetkez adatbßzisokban elmentetlen jßtszmavßltoztatßsok vannak. Ha most kil‰psz, ezek a vßltoztatßsok elvesznek.}

# Import window:
translate H PasteCurrentGame {Beilleszti az aktußlis jßtszmßt.}
translate H ImportHelp1 {Bevisz vagy beilleszt egy PGN-formßtum” jßtszmßt a fenti keretbe.}
translate H ImportHelp2 {Itt jelennek meg az importßlßs k÷zben fell‰p hibßk.}

# ECO Browser:
translate H ECOAllSections {az ÷sszes ECO-szakasz}
translate H ECOSection {ECO-szakasz}
#Ez bizonyßra valami ’l‰sszak, szval amg foglalkozik vel’k.
translate H ECOSummary {Ùsszefoglalßs:}
translate H ECOFrequency {Alkdok gyakorisßga:}

# Opening Report:
translate H OprepTitle {Megnyitßsi ÷sszefoglal}
translate H OprepReport {Ùsszefoglal}
translate H OprepGenerated {K‰sztette:}
#Lehet, hogy ez "k‰sz’lt"?
translate H OprepStatsHist {Statisztika ‰s t÷rt‰net}
translate H OprepStats {Statisztika}
translate H OprepStatAll {Az ÷sszefoglal ÷sszes jßtszmßja}
translate H OprepStatBoth {Mindkett:}
translate H OprepStatSince {Idszak kezdete:}
translate H OprepOldest {A legr‰gibb jßtszmßk}
translate H OprepNewest {A leg”jabb jßtszmßk}
translate H OprepPopular {Jelenlegi n‰pszer“s‰g}
translate H OprepFreqAll {Gyakorisßg a teljes idszakban:   }
translate H OprepFreq1   {Az utbbi 1 ‰vben: }
translate H OprepFreq5   {Az utbbi 5 ‰vben: }
translate H OprepFreq10  {Az utbbi 10 ‰vben: }
translate H OprepEvery {minden %u jßtszmßban egyszer}
translate H OprepUp {%u%s n÷veked‰s az ‰vek sorßn}
translate H OprepDown {%u%s cs÷kken‰s az ‰vek sorßn}
translate H OprepSame {nincs vßltozßs az ‰vek sorßn}
translate H OprepMostFrequent {Leggyakoribb jßt‰kosok}
translate H OprepRatingsPerf {Ğrt‰kszßm ‰s teljestm‰ny}
translate H OprepAvgPerf {Âtlagos ‰rt‰kszßm ‰s teljestm‰ny}
translate H OprepWRating {Vilßgos ‰rt‰kszßma}
translate H OprepBRating {S÷t‰t ‰rt‰kszßma}
translate H OprepWPerf {Vilßgos teljestm‰nye}
translate H OprepBPerf {S÷t‰t teljestm‰nye}
translate H OprepHighRating {A legnagyobb ßtlag‰rt‰kszßm” jßtszmßk}
translate H OprepTrends {Tendencißk}
translate H OprepResults {Eredm‰ny hossz”sßg ‰s gyakorisßg szerint}
translate H OprepLength {Jßtszmahossz}
translate H OprepFrequency {Gyakorisßg}
translate H OprepWWins {Vilßgos nyer: }
translate H OprepBWins {S÷t‰t nyer: }
translate H OprepDraws {D÷ntetlen:      }
translate H OprepWholeDB {teljes adatbßzis}
translate H OprepShortest {A legr÷videbb gyzelmek}
translate H OprepMovesThemes {L‰p‰sek ‰s t‰mßk}
translate H OprepMoveOrders {A vizsgßlt ßllßshoz vezet l‰p‰ssorrendek}
translate H OprepMoveOrdersOne \
  {Csak egy l‰p‰ssorrend vezetett ehhez az ßllßshoz:}
translate H OprepMoveOrdersAll \
  {%u l‰p‰ssorrend vezetett ehhez az ßllßshoz:}
translate H OprepMoveOrdersMany \
  {%u l‰p‰ssorrend vezetett ehhez az ßllßshoz. Az els %u:}
translate H OprepMovesFrom {A vizsgßlt ßllßsban tett l‰p‰sek}
translate H OprepThemes {Pozcis t‰mßk}
translate H OprepThemeDescription {T‰mßk gyakorisßga a %u-ik l‰p‰sben}
translate H OprepThemeSameCastling {Sßncolßs azonos oldalra}
translate H OprepThemeOppCastling {Sßncolßs ellenkez oldalra}
translate H OprepThemeNoCastling {Egyik kirßly sem sßncolt.}
translate H OprepThemeKPawnStorm {Kirßlyszßrnyi gyalogroham}
translate H OprepThemeQueenswap {Vez‰rcsere}
translate H OprepThemeIQP {Elszigetelt vez‰rgyalog}
translate H OprepThemeWP567 {Vilßgos gyalog az 5./6./7. soron}
translate H OprepThemeBP234 {S÷t‰t gyalog a 4./3./2. soron}
translate H OprepThemeOpenCDE {Nylt c/d/e-vonal}
translate H OprepTheme1BishopPair {Csak az egyik f‰lnek van futpßrja.}
translate H OprepEndgames {V‰gjßt‰kok}
translate H OprepReportGames {Az ÷sszefoglal jßtszmßi}
translate H OprepAllGames    {Az ÷sszes jßtszma}
translate H OprepEndClass {Anyagi viszonyok az egyes jßtszmßk v‰g‰n}
translate H OprepTheoryTable {Elm‰lettßblßzat}
translate H OprepTableComment {a legnagyobb ‰rt‰kszßm” %u jßtszma alapjßn}
translate H OprepExtraMoves {A k’l÷n megjegyz‰ssel ellßtott l‰p‰sek szßma az elm‰lettßblßzatban}
translate H OprepMaxGames {Az elm‰lettßblßzat l‰trehozßsßhoz felhasznßlhat jßtszmßk maximßlis szßma}

# Piece Tracker window:
translate H TrackerSelectSingle {A bal eg‰rgomb kivßlasztja ezt a figurßt.}
translate H TrackerSelectPair {A bal eg‰rgomb kivßlasztja ezt a figurßt; a jobb eg‰rgomb a pßrjßt is kivßlasztja.}
translate H TrackerSelectPawn {A bal eg‰rgomb kivßlasztja ezt a gyalogot; a jobb eg‰rgomb az ÷sszes gyalogot kivßlasztja.}
translate H TrackerStat {Statisztika}
translate H TrackerGames {Jßtszmßk %-a, amelyekben erre a mezre l‰pett}
translate H TrackerTime {Id %-a, amelyet az egyes mezk÷n t÷lt÷tt}
translate H TrackerMoves {L‰p‰sek}
translate H TrackerMovesStart {Add meg a l‰p‰s szßmßt, amelyn‰l a nyomk÷vet‰snek el kell kezddnie.}
translate H TrackerMovesStop {Add meg a l‰p‰s szßmßt, amelyn‰l a nyomk÷vet‰snek be kell fejezdnie.}

# Game selection dialogs:
translate H SelectAllGames {Az adatbßzis ÷sszes jßtszmßja}
translate H SelectFilterGames {Csak a sz“rt jßtszmßk}
translate H SelectTournamentGames {Csak az aktußlis verseny jßtszmßi}
translate H SelectOlderGames {Csak r‰gebbi jßtszmßk}

# Delete Twins window:
translate H TwinsNote {K‰t jßtszma akkor iker, ha ugyanazok jßtsszßk ket, ‰s megfelelnek az alant meghatßrozhat krit‰riumoknak. Az ikerpßrbl a r÷videbb jßtszma t÷rldik.
Javaslat: ikrek t÷rl‰se eltt ‰rdemes helyesrßs-ellenrz‰st v‰gezni az adatbßzison, mert az javtja az ikerfeldert‰st.}
translate H TwinsCriteria {Krit‰riumok: Az ikerjßtszmßk k÷z÷s tulajdonsßgai...}
translate H TwinsWhich {Megvizsgßlja, melyik jßtszma}
translate H TwinsColors {Azonos szn?}
translate H TwinsEvent {Ugyanaz az esem‰ny?}
translate H TwinsSite {Azonos helyszn?}
translate H TwinsRound {Ugyanaz a fordul?}
translate H TwinsYear {Azonos ‰v?}
translate H TwinsMonth {Azonos hnap?}
translate H TwinsDay {Ugyanaz a nap?}
translate H TwinsResult {Azonos eredm‰ny?}
translate H TwinsECO {Azonos ECO-kd?}
translate H TwinsMoves {Azonos l‰p‰sek?}
translate H TwinsPlayers {A jßt‰kosok nev‰nek ÷sszehasonltßsakor:}
translate H TwinsPlayersExact {Teljes egyez‰s kell.}
translate H TwinsPlayersPrefix {El‰g az els 4 bet“nek egyeznie.}
translate H TwinsWhen {Ikerjßtszmßk t÷rl‰sekor:}
translate H TwinsSkipShort {Hagyjuk figyelmen kv’l az 5 l‰p‰sn‰l r÷videbb jßtszmßkat?}
translate H TwinsUndelete {Elsz÷r ßlltsuk helyre az ÷sszes jßtszmßt?}
translate H TwinsSetFilter {A sz“rt ßlltsuk az ÷sszes t÷r÷lt ikerjßtszmßra?}
translate H TwinsComments {A megjegyz‰sekkel ellßtott jßtszmßkat mindig tartsuk meg?}
translate H TwinsVars {A vßltozatokat tartalmaz jßtszmßkat mindig tartsuk meg?}
translate H TwinsDeleteWhich {Melyik jßtszmßt t÷r÷ljem?}
translate H TwinsDeleteShorter {A r÷videbbet}
translate H TwinsDeleteOlder {A kisebb sorszßm”t}
translate H TwinsDeleteNewer {A nagyobb sorszßm”t}
translate H TwinsDelete {Jßtszmßk t÷rl‰se}

# Name editor window:
translate H NameEditType {Szerkesztend n‰vtpus}
translate H NameEditSelect {Szerkesztend jßtszmßk}
translate H NameEditReplace {Amit cser‰l}
translate H NameEditWith {Amire cser‰li}
translate H NameEditMatches {Egyez‰sek: Ctrl+1...Ctrl+9 vßlaszt.}

# Classify window:
translate H Classify {Osztßlyoz}
translate H ClassifyWhich {Mely jßtszmßk ECO-osztßlyozßsßt v‰gezze el?}
translate H ClassifyAll {Az ÷sszes‰t (rja fel’l a r‰gi ECO-kdokat)}
translate H ClassifyYear {Az utbbi ‰vben jßtszott jßtszmßk‰t}
translate H ClassifyMonth {Az utbbi hnapban jßtszott jßtszmßk‰t}
translate H ClassifyNew {Csak az eddig m‰g nem osztßlyozott jßtszmßk‰t}
translate H ClassifyCodes {Hasznßland ECO-kdok:}
translate H ClassifyBasic {Csak az alapkdok ("B12", ...)}
translate H ClassifyExtended {Kiterjesztett SCID-kdok ("B12j", ...)}

# Compaction:
translate H NameFile {N‰vfßjl}
translate H GameFile {Jßtszmafßjl}
translate H Names {Nevek}
translate H Unused {Hasznßlaton kv’l}
translate H SizeKb {M‰ret (kB)}
translate H CurrentState {Jelenlegi ßllapot}
translate H AfterCompaction {T÷m÷rt‰s utßn}
translate H CompactNames {N‰vfßjl t÷m÷rt‰se}
translate H CompactGames {Jßtszmafßjl t÷m÷rt‰se}

# Sorting:
translate H SortCriteria {Krit‰riumok}
translate H AddCriteria {Krit‰riumok hozzßadßsa}
translate H CommonSorts {Szokßsos rendez‰sek}
translate H Sort {Rendez‰s}

# Exporting:
translate H AddToExistingFile {Jßtszmßk hozzßadßsa l‰tez fßjlhoz?}
translate H ExportComments {Megjegyz‰sek exportßlßsa?}
translate H ExportVariations {Vßltozatok exportßlßsa?}
translate H IndentComments {Megjegyz‰sek igaztßsa?}
translate H IndentVariations {Vßltozatok igaztßsa?}
translate H ExportColumnStyle {Oszlop stlusa (soronk‰nt egy l‰p‰s)?}
translate H ExportSymbolStyle {Szimblumok stlusa:}
translate H ExportStripMarks {Kivegye a megjegyz‰sekbl a mez- ‰s nylmegjel÷l‰seket?}

# Goto game/move dialogs:
translate H LoadGameNumber {A bet÷ltend jßtszma sorszßma:}
translate H GotoMoveNumber {Ugrßs a k÷vetkez l‰p‰shez:}

# Copy games dialog:
translate H CopyGames {Jßtszmßk mßsolßsa}
translate H CopyConfirm {
 T‰nyleg ßt akarod mßsolni
 a [thousands $nGamesToCopy] sz“rt jßtszmßt
 a "$fromName" adatbßzisbl
 a "$targetName" adatbßzisba?
}
translate H CopyErr {Nem tudom ßtmßsolni a jßtszmßkat.}
translate H CopyErrSource {forrßs}
translate H CopyErrTarget {c‰l}
translate H CopyErrNoGames {sz“rj‰ben nincsenek jßtszmßk.}
translate H CopyErrReadOnly {kizßrlag olvashat.}
translate H CopyErrNotOpen {nincs megnyitva.}

# Colors:
translate H LightSquares {Vilßgos mezk}
translate H DarkSquares {S÷t‰t mezk}
translate H SelectedSquares {Kivßlasztott mezk}
translate H SuggestedSquares {Javasolt l‰p‰sek mezi}
translate H WhitePieces {Vilßgos figurßk}
translate H BlackPieces {S÷t‰t figurßk}
translate H WhiteBorder {Vilßgos k÷rvonal}
translate H BlackBorder {S÷t‰t k÷rvonal}

# Novelty window:
translate H FindNovelty {õjtßs keres‰se}
translate H Novelty {õjtßs}
translate H NoveltyInterrupt {õjtßskeres‰s leßlltva}
translate H NoveltyNone {Ebben a jßtszmßban nem talßltam ”jtßst.}
translate H NoveltyHelp {
SCID megkeresi az aktußlis jßtszma els olyan l‰p‰s‰t, amely nem szerepel sem a kivßlasztott adatbßzisban, sem az ECO megnyitßstßrban.
}

# Upgrading databases:
translate H Upgrading {Fel”jtßs}
translate H ConfirmOpenNew {
Ez r‰gi formßtum” (SCID 2) adatbßzis, amelyet SCID 3 nem tud megnyitni, de mßr l‰trehozott egy ”j formßtum” (SCID 3) verzit.

Szeretn‰d megnyitni az adatbßzis ”j formßtum” verzijßt?
}
translate H ConfirmUpgrade {
Ez r‰gi formßtum” (SCID 2) adatbßzis. õj formßtum” verzit kell l‰trehozni belle, hogy SCID 3 hasznßlni tudja.

A fel”jtßs ”j verzit hoz l‰tre az adatbßzisbl. Az eredeti fßjlok s‰rtetlen’l megmaradnak.

Az eljßrßs eltarthat egy darabig, de csak egyszer kell elv‰gezni. Megszakthatod, ha t”l sokßig tart.

Szeretn‰d most fel”jtani ezt az adatbßzist?
}

# Recent files options:
translate H RecentFilesMenu {Az aktußlis fßjlok szßma a Fßjl-men’ben}
translate H RecentFilesExtra {Az aktußlis fßjlok szßma a kieg‰szt almen’ben}

}
# end of hungary.tcl


